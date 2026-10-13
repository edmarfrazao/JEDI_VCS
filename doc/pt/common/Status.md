# Status do port

Situação por fase do [Plano-de-Port.md](Plano-de-Port.md) (F0 a F6) e lista consolidada do que ficou pendente. Estado em **13/10/2026, fim do dia** (beta 5 publicado). Decisões: [Decisoes.md](Decisoes.md). Ambiente: [Ambiente.md](Ambiente.md). Roteiro da IA e do multi-Delphi: [ADR-001](ADR-001-CLI-IA-e-Plugin-Multi-Delphi.md).

## Resumo

| Fase | Objetivo | Situação |
|---|---|---|
| F0 | Ambiente, dependências, build e linha de base | **Concluída no essencial**: Delphi 11.3, 12 e 13.2 instalados; `.dproj` dos 4 alvos e do expert + `JediVCS2026.groupproj`; `tools\compilar.bat /delphi:11\|12\|13`; servidor de teste montado; decisões da 0.2 resolvidas (ver abaixo). Resta a varredura ampla do banco (0.7) |
| F1 | Midware portado, `JVCSTransport.pas`, teste golden | **Em andamento**: Midware portado (Unicode, cp1252, ICS 9) e golden de fio do console idêntico ao original; faltam `JVCSTransport.pas`, pacote design-time e suíte golden automatizada |
| F2 | Núcleo do cliente e console `jvcs.exe` | **Console pronto e validado** (golden idêntico ao 2.5.0.1030); JCL e JVCL ficam (decisão de 13/10); faltam `JVCSTransport` e testes de binário/arquivo vazio |
| F3 | GUI comum e `JEDIVCSDiff.exe` | **Diff pronto** (sem JVCL/JCL/DFS) e infraestrutura de aparência; faltam tradução (`gnugettext`) e testes interativos |
| F4 | EXE standalone `Jedivcs.exe` | **Funcional e publicado** (betas 1–5): todos os forms abrem, recursos testados contra o servidor, tema claro/escuro, escala 100–200%; JVCL mantida (decisão de 13/10); resta o lote 4.5 |
| F5 | DLL da IDE, expert e setup | **Concluída para Win32**: DLL nova + experts `JvcsExpertBDS22/23/37` (sem `designide`, carregam em todas as atualizações) + expert original 2.5.0.1030 para Delphi 7 a 10.4; instalador Inno Setup com escolha por Delphi; testado em XE3, 11.1, 11.3, 12, 13.1 e 13.2 |
| F6 | Win64 / ARM64EC (opcional) | Não iniciada; bloqueada pela `fvcscrypt.dll` (32 bits) |

**Versão publicada:** beta 5, `2.5.0.2050` (tag `v2.5.0.2026-beta5`, pre-release no GitHub). Numeração em [Versoes.md](Versoes.md); novidades em `news/pt` e `news/en`.

**Build:** `tools\compilar.bat all Release Win32` gera `Jedivcs.exe`, `JvcsExternalDll.dll`, `JEDIVCSDiff.exe` e `jvcs.exe` (0 erros); `tools\compilar-expert.bat` gera os experts por versão; `tools\gerar-instalador.bat` gera `setup\Output\JediVCS-2.5.0-Beta<N>-build<NNNN>-Setup.exe`.

**PCs de teste:** desenvolvimento (Delphi 11.3, 12, 13.2 + servidor de teste local); PC remoto com o servidor da empresa (Delphi 11, 12, 13.1, via canal OneDrive); PC com Delphi XE3 e 11.1 Enterprise.

---

## Pendências (lista consolidada)

Ordem sugerida de prioridade. Cada item remete à fase do plano ou ao marco do ADR-001.

### A. Próximas — validação

| # | Pendência | Origem |
|---|---|---|
| A1 | **Teste com o servidor da empresa (quinta, 15/10/2026)**: aplicar o [checklist de compatibilidade](Plano-de-Port.md#checklist-de-testes-de-compatibilidade-com-o-servidor-25-beta-3) com o banco real | Plano, checklist |
| A2 | Nomes de projeto/módulo acentuados criados no novo aparecem iguais no antigo (e vice-versa) | Checklist [R1] |
| A3 | Revisões antigas (amostra ampla do banco real) abertas pelo cliente novo; Sync por CRC sem falsos "modificados" | Checklist [R7–R9], F0 0.7 |
| A4 | Teste de fumaça de Labels, Milestones, ToDo, Bugs, Browser e opções do servidor contra o banco real | Checklist |
| A5 | Projeto já cadastrado reconhecido pela IDE com o mesmo ID do expert antigo (`GetProjectName`) | F5 [R13] |
| A6 | Rodar com ACP 65001 ("Beta: UTF-8") e locale en-US | Checklist, F1 |
| A7 | Teste ao vivo da skill em inglês (`skills/en/jedi-vcs`) | Docs/IA |

### B. Port — restante

**JVCL e JCL ficam** (decisão de 13/10/2026, [Decisoes.md](Decisoes.md)): são projetos livres e mantidos pela comunidade JEDI. Os 56 componentes JVCL que restam nos DFMs **não serão trocados**; continuam linkados estaticamente nos binários compilados no Delphi 13 (o Delphi de destino não precisa de nenhum componente instalado). Os antigos lotes 4.4/4.6 ("JVCL visual → nativo", "nenhuma unit `Jv*` no EXE") saem do plano.

| # | Pendência | Origem |
|---|---|---|
| B2 | Lote 4.5: `CompareFolders`, `LoadModule`, `SMTPSend`; `mdmailslot` só compila (notificação desligada) | F4 |
| B4 | (opcional) Abbrevia → `System.Zip`; o Abbrevia (TurboPack) também é livre e mantido, então só se trouxer ganho | F2 |
| B6 | `JVCSTransport.pas` (`IJVCSTransport` + Midware + fábrica) | F1 |
| B7 | Pacote design-time `JVCSMidwareD.dpk` (`TAppSrvClient`, `TMWBuffer`) para abrir `DBModule` e outros forms no designer | F1 1.7 |
| B8 | Suíte golden automatizada (ida e volta do `RFormat`, comparador; ACP 1252/65001, pt-BR/en-US) | F1 |
| B9 | Remover ramo `INTERNAL_OLDOTA`/VCSManager da DLL | F5 5.4 |
| B10 | Diff: tradução (`gnugettext`), teste interativo de gravação UTF-8 e comparação com revisão do servidor | F3 |

### C. IA e arquitetura (ADR-001)

| # | Pendência | Marco |
|---|---|---|
| C1 | `jvcs.exe` com **modo moderno**: saída JSON, códigos de saída 0–12, `status`/`diff`/`log`, credenciais no Windows Credential Manager (sem senha na linha de comando), mutex por conta — substitui o wrapper `tools\ai\jvcs-ai.ps1` sobre o console antigo | M3 |
| C2 | Servidor MCP no `jvcs.exe` (check-in sempre com aprovação humana) | M4a |
| C3 | Expert Win64 + `jvcs-agent.exe` (núcleo fora do processo) para a IDE de 64 bits — só se a IDE de 64 bits for usada | M1 (Win64), M2 |
| C4 | IA e GUI/IDE com o mesmo usuário sem "re-connect" (re-login transparente ou agente de sessão) — decidir na F4/F5 (ADR D11) | M6/M7 |
| C5 | Mensagens do wrapper `jvcs-ai.ps1` e da skill por projeto só em português | Docs/IA |
| C6 | Expor no wrapper `jvcs-ai.ps1` os comandos novos do console (`addproject`, `addmodule`, 1º check-in) e um `diff` contra a revisão do servidor (`getmodule rev= dest= noprompt`); hoje o wrapper usa o console original, que não tem esses comandos. Feito e testado no console novo em 13/10 (Port-Console.md §5) | M3 |
| C7 | Wrapper e `edit-preserve.ps1` deduzem o projeto pelos `.dpr` da pasta: com mais de um `.dpr` ou projeto com outro nome, exigem `-Project` (e o `edit-preserve` não faz o checkout automático) | Docs/IA |
| C8 | Remover pelo standalone os módulos de teste quebrados do projeto `ex2.dpr` no servidor de teste (IDs 5–9) | Teste |

### D. Decisões em aberto

| # | Decisão | Situação |
|---|---|---|
| D1 | Licença não comercial do Midware ao distribuir cliente, CLI e agente | Adiada; aviso no About, README e LICENSE (13/10) |
| D2 | Como a IA usa a conta do humano (ADR D11) | Decidir na F4/F5 |

### E. Opcional

| # | Pendência |
|---|---|
| E1 | F6 Win64/ARM64EC: substituir ou isolar a `fvcscrypt.dll`; revisão 64 bits; floats na suíte golden |
| E2 | Notificação entre estações (mailslot/SMTP), relatórios (`REPORTDLL`), tradução (`LANGUAGE`) e plugins: desligados por decisão ("só o básico") |

---

## Decisões da seção 0.2 (resolvidas)

| Tema | Resolução |
|---|---|
| Code page do fio | cp1252 fixa (`MWCodePage`), validada pelo golden do console e pelos testes com comentários acentuados |
| Blowfish de blobs | Suportado (`BFCrypt`), testado com o servidor (F4 3ª etapa) |
| ShareMem na DLL | Não usado; ABI plana `PAnsiChar` |
| Nome da DLL | `JvcsExternalDll.dll` (mesmo do original) |
| JCL/JVCL no D11/D12 | Desnecessário: opção 1 (Decisoes.md, 13/10) — tudo compilado uma vez no Delphi 13; só o expert é compilado por versão, importando apenas `rtl`/`vcl`/`xmlrtl` |

---

## Feito por fase

### F0 — Ambiente e linha de base
- [x] Estrutura `v2026`, fontes base, inventário de componentes e Plano de Port
- [x] Delphi 13.2 (`37.0.60952.8797`), **Delphi 11.3 e 12 instalados** (13/10)
- [x] JCL/JVCL 2026.08, ICS 9.7, Abbrevia 2026.10 (GetIt, só no D13); SynEdit pyscripter `84391a3` e VTV V8.5 fixados em `src\comp`; `EnvOptions.proj` sem a referência ao VTV 8.3
- [x] `.dproj` de `Jedivcs`, `JediVCSDLL`, `JEDIVCSDiff`, `jvcs` e `JvcsExpertBDS` + `JediVCS2026.groupproj`
- [x] `tools\compilar.bat` e `compilar-expert.bat` multi-versão (`/delphi:11|12|13`)
- [x] Binários de referência 2.5.0.1030 e runtime em `3rdparty`; experts originais em `3rdparty\experts-originais-2.5.0.1030` (21 DLLs + SHA256SUMS)
- [x] Servidor 2.5 Beta 3 de teste local (Firebird 2.5.9), ver `doc\pt\server\Servidor-Teste-Local.md`
- [x] Capturas golden do console (`doc\pt\client\golden-console`)
- [ ] Consultas somente leitura amplas no banco real (CRC, flags ZIP, blobs Blowfish, `lc_ctype`) → A3

### F1 — Midware
- [x] `MWDefs.inc`, `RFormat.pas` (cp1252), `ApsCli.pas` (ICS 9, IPv4), `CBroker.pas`
- [x] Golden de fio do console idêntico ao original
- [ ] B6, B7, B8

### F2 — Núcleo e console
- [x] `jvcs.exe` validado: `listprojects`, `listproject`, `listlocks`, `getmodule`, `checkout`/`checkin` acentuado; leitura cruzada com o original; `BRANCHING` ligado no console
- [x] `Checksum.pas` recriada e validada; blob ZIP com a data do arquivo; versão no banner
- [ ] B4 (opcional); testes de sync com arquivo binário e vazio

### F3 — Diff e GUI comum
- [x] `JEDIVCSDiff.exe` sem JVCL/JCL/DFS; MRU compatível; detecção de codificação; testes por linha de comando
- [x] `JVCSUIScale`, `JVCSUITheme`, `TJVCSForm`, About próprio
- [ ] B10

### F4 — EXE standalone
- [x] 1ª–3ª etapas (Port-Standalone.md §1–§5): compila, Appearance e AI/Automation em VCS Properties, log de erros, `-formsweep` (95 forms/frames), testes funcionais com o servidor (Save WIP, Compare all, Backup, Line History, Compressed Diff, Used Units, Sync, Labels, ExtBugtracker), tema escuro
- [x] JVCL simples → VCL em 36 forms
- [x] Lentidão ao abrir projeto corrigida (o Project Manager abre mais rápido); senha salva preservada
- [x] Versão instalada visível (título, About, Painel de Controle)
- [x] DFS fora do EXE (restam só nomes de objeto `dfsStatusBar`, agora `TJVCSStatusBar`)
- [ ] B2

### F5 — DLL, expert e setup
- [x] DLL nova (`JvcsExternalDll.dll`) com exports iguais aos do original; harness com 0 AV
- [x] Experts `JvcsExpertBDS22/23/37.dll` sem `designide` (`tools\verificar-expert.ps1` confere imports contra as `.bpl` de 13.1 e 12)
- [x] Delphi 7 a 10.4: expert original 2.5.0.1030 + DLL nova
- [x] Tema da IDE via `JVCS_IDE_THEME`; menus legíveis; janelas com dono = IDE
- [x] **AV no XE3** (barra, Get do histórico, menus): DLL com `Application.Handle` próprio (commit `a0b0b51`)
- [x] Testado na IDE: check-in/out, Get, History, Project Manager em 11.1, 11.3, 12, 13.1, 13.2 e XE3
- [x] Instalador Inno Setup: instalar/reinstalar/reparar, escolha por Delphi, aviso de garantia com aceite, skills pt/en, versão de `tools\versao.ini`
- [ ] A5, B9

### F6 — Win64
- [ ] E1

---

## Histórico

Detalhes de cada etapa: `doc\pt\client\Port-*.md`, `doc\pt\processo\` (linha do tempo, testes, lições) e `CHANGELOG.md`.
