# 03. Decisões de arquitetura

Resumo navegável das decisões do port. A fonte é o registro datado em [Decisoes](../common/Decisoes.md)
e o [ADR-001](../common/ADR-001-CLI-IA-e-Plugin-Multi-Delphi.md); aqui estão agrupadas por tema, com o
motivo e onde ler o detalhe. Anterior: [02 Linha do tempo](02-Linha-do-Tempo.md). Próximo:
[04 Testes](04-Testes-e-Validacao.md).

## Mapa rápido

| # | Decisão | Em uma frase |
|---|---|---|
| D-1 | [Só o cliente, protocolo idêntico](#d-1-só-o-cliente-protocolo-idêntico) | O servidor 2.5 Beta 3 não muda; o cliente novo manda os mesmos bytes |
| D-2 | [Núcleo único + expert fino por versão](#d-2-núcleo-único--expert-fino-por-versão) | EXE/DLL/Diff/console compilados uma vez; só o expert é por Delphi |
| D-3 | [Expert sem `designide`](#d-3-expert-sem-designide) | O expert importa só `rtl`, `vcl` e `xmlrtl` e carrega em todas as atualizações |
| D-4 | [cp1252 no fio](#d-4-cp1252-no-fio) | Texto do MidWare sempre em Windows-1252, independentemente do Delphi Unicode |
| D-5 | [BRANCHING](#d-5-branching) | Ligado no console (saída idêntica); na GUI, ligado com o menu Branch oculto |
| D-6 | [Opções desligadas](#d-6-opções-desligadas) | Relatórios, tradução, notificação, plugins e LZH fora |
| D-7 | [Recursos de 2012 mantidos](#d-7-recursos-de-2012-mantidos) | External Bugtracker, Save WIP e Compare all |
| D-8 | [Bibliotecas](#d-8-bibliotecas) | SynEdit e VTV fixados no repositório; JCL/JVCL/ICS/Abbrevia do GetIt (JVCL e Abbrevia são ponte) |
| D-9 | [Plataforma e versão](#d-9-plataforma-e-versão) | Win32; `2.5.0.2026` / "2.5 Beta 2026" |
| D-10 | [IA](#d-10-ia) | Identidade salva, prefixo `[IA]`, codificação preservada, modos manual/confirmação/auto |
| D-11 | [MidWare e licença](#d-11-midware-e-licença) | Mantido com o aviso obrigatório; transporte será isolado |

## D-1. Só o cliente, protocolo idêntico

- **Decisão (12/10):** portar EXE, DLL da IDE, Diff e console; o servidor **2.5 Beta 3 (Firebird)** fica.
- **Por quê:** servidores em produção, banco estável, nenhum ganho em mexer no servidor; o cliente antigo
  é que não roda nas IDEs novas.
- **Consequência:** todo o port é validado contra o fio do 2.5.0.1030 (golden). Ver
  [01 História](01-Historia-e-Motivacao.md) e [04 Testes](04-Testes-e-Validacao.md).

## D-2. Núcleo único + expert fino por versão

- **Decisão (13/10, "opção 1"):** `Jedivcs.exe`, `jvcs.exe`, `JEDIVCSDiff.exe` e `JvcsExternalDll.dll`
  são compilados **uma vez**, no Delphi 13, com JCL/JVCL/ICS/Abbrevia/SynEdit/VTV linkados
  **estaticamente** (sem runtime packages). Só o expert `JvcsExpertBDS<nn>.dll` (~128 KB) é compilado por
  versão (22 = Delphi 11, 23 = 12, 37 = 13).
- **Por quê:** o Delphi do usuário **não precisa de nenhum componente de terceiros**; a DLL não divide
  objetos VCL com a IDE; uma correção no cliente vale para todas as IDEs.
- **Descartadas:** expert único sem pacotes (objetos VCL da IDE atravessando módulos = instável) e cliente
  fora do processo (fica para o futuro, ADR-001 §4–5).
- **Detalhe:** [ADR-001 §4](../common/ADR-001-CLI-IA-e-Plugin-Multi-Delphi.md),
  [Arquitetura dos fontes](../fontes/Arquitetura.md).

## D-3. Expert sem `designide`

- **Problema (13/10):** o expert compilado no 13.2 não carregava no 13.1 ("Could not find Wizard", erro
  127). Com runtime packages, cada unit de pacote no grafo de `uses` vira import da sua `initialization`;
  o `ToolsAPI.pas` puxa `DockForm`, cujo grafo mudou no 13.2.
- **Decisão:** cópia local da ToolsAPI **sem `DockForm`**, gerada na hora do build a partir da instalação
  de quem compila (`tools\gerar-toolsapi.ps1`, fora do git), via unit alias. O expert importa só `rtl`,
  `vcl` e `xmlrtl`; nada de genéricos da RTL; funcionalidade nova vai para a DLL.
- **Garantia:** `tools\verificar-expert.ps1` confere os imports contra os `.bpl` de cada atualização.
- **Detalhe:** [Port-DLL-IDE §5A](../client/Port-DLL-IDE.md), commit `c1d0ddc`.

## D-4. cp1252 no fio

- **Decisão:** o MidWare portado usa `PAnsiChar` e uma code page **fixa** (`MWCodePage = 1252`) para os
  campos de texto, inclusive comentários de check-in acentuados.
- **Por quê:** o servidor e os clientes 2.5 gravam e leem bytes Windows-1252; qualquer outra codificação
  corromperia comentários e nomes vistos pelos clientes antigos.
- **Prova:** no `CHECKIN_MODULE`, `ç` = `E7` e `ã` = `E3` nos dois consoles
  ([Port-Console §3.2](../client/Port-Console.md)).
- A ABI expert↔DLL também é ANSI (`PAnsiChar`, sem "best fit") — ver
  [Arquitetura](../fontes/Arquitetura.md#3-abi-expert--dll).

## D-5. BRANCHING

- **Console (12/10):** define `BRANCHING` **ligado** no `jvcs.dpr`: com o servidor 2.50 a saída e o
  tráfego ficam idênticos ao original (que imprime "Branch: HEAD").
- **EXE/DLL:** `BRANCHING` + `JVCS_NOBRANCHUI` — o código de branch fica (o servidor exige), mas o menu
  Branch é oculto e o branch é sempre `HEAD`. A DLL tem 27 verbos (a original, 29).

## D-6. Opções desligadas

"Só o básico" (12/10), sem efeito no protocolo:

| Recurso | Como foi desligado |
|---|---|
| Relatórios (`jedivcsreport.dll`) | `REPORTDLL` desligado, `JVCS_NOREPORTS` |
| Tradução (gettext) | `LANGUAGE` desligado |
| Notificação entre estações (mailslot/SMTP) | não portada (`mdmailslot` só compila) |
| Plugins (`TJvPluginManager`) | desligados |
| Cifra LZH / CipherLz | removida (código morto, licença não comercial); resposta cifrada vira erro explícito |
| FastMM4 | removido; gerenciador de memória embutido do Delphi |

## D-7. Recursos de 2012 mantidos

O trunk de 2012 tinha recursos que o binário 2.5.0.1030 não tem; foram **mantidos** (12/10):
**External Bugtracker** (URL + regex no comentário, agora com `System.RegularExpressions.TRegEx`),
**Save WIP** (backup dos arquivos em check-out) e **Compare all local/archive**. Ver
[Cliente-Standalone-Analise §6](../client/Cliente-Standalone-Analise.md).

## D-8. Bibliotecas

| Biblioteca | Decisão |
|---|---|
| SynEdit | pyscripter `84391a3`, **fixado** em `src\comp\synedit` (mesmo fonte para 11/12/13) |
| VirtualTreeView | JAM V8.5, **fixado** em `src\comp\virtualtreeview` |
| JCL / JVCL | GetIt 2026.08 no 13; JVCL é **ponte** (sai do EXE aos poucos) |
| ICS | 9.7 (GetIt) |
| Abbrevia | 2026.10 (GetIt), ponte; meta: `System.Zip` |
| DFS (EnhListView, SystemTreeView, StatusBar) | **não reaproveitar** (licença) → controles nativos (`TJVCSListView`, `TJVCSFolderTree`, `TJVCSStatusBar`) |

Tabela completa: [Componentes](../common/Componentes.md).

## D-9. Plataforma e versão

- **Win32** na fase 1: a `fvcscrypt.dll` (cifra do login) é 32 bits e fechada; a IDE de 32 bits continua
  no Delphi 12.3/13. O expert é registrado só em `Experts` (nunca em `Experts x64`).
- **Versão:** FileVersion `2.5.0.2026`, ProductVersion "2.5 Beta 2026", flag pré-lançamento. O LOGIN do
  EXE/DLL envia 250 (aceito pelo servidor). Ver [Versoes](../common/Versoes.md).

## D-10. IA

Do ADR-001 e de [Decisoes](../common/Decisoes.md):

- a IA usa a **identidade já salva** do usuário (o servidor com branching aceita duas sessões do mesmo
  usuário) e marca os check-ins com `[IA]`;
- **preservar a codificação** de cada fonte (ANSI 1252 ou UTF-8, CRLF): o `Edit` do Claude Code corrompe
  ANSI, por isso há hook e um editor que preserva bytes;
- checkout/check-in em **três modos** configuráveis: manual, **confirmação** (padrão) e auto;
- primeiro o wrapper sobre o `jvcs.exe`, depois o port.

Documentação de uso: [doc/pt/ia](../ia/README.md).

## D-11. MidWare e licença

O transporte (`ApsCli`, `RFormat`, `CBroker`) é uma versão **alterada** do MidWare, freeware **somente
para uso não comercial**. Decisão (13/10): manter no repositório público cumprindo a licença (aviso no
README, LICENSE, About e console) e isolar o transporte atrás de `JVCSTransport.pas` para poder trocá-lo.
Ver [Licencas](../common/Licencas.md).
