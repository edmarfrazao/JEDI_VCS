# Plano de port: cliente JEDI VCS 2.5 → Delphi 13.2

Plano de execução, em fases ordenadas por dependência, para portar o **cliente** JEDI VCS 2.5 (Beta 3) para o Delphi 13.2 Florence Professional, mantendo a compilação em Delphi 11/12.

- **Base:** `doc\common\Inventario-Componentes.md`. As referências entre colchetes, como **[R7]**, remetem à linha de mesmo número (#7) da tabela da seção 4 do inventário ("Riscos de compatibilidade com o servidor 2.5 Beta 3"); "crítico 1.x/Cx" remete à seção 6.
- **Data:** 2026-10-12.
- **Situação de partida (2026-10-12):**
  - A árvore `v2026` já existe, com fontes base vindos das cópias de `jedivcsdll` e `.dpr` de `ConverterBackup` (ver `doc\common\LEIAME-Origem.md`).
  - No Delphi 13.2 estão instalados via GetIt: JCL/JVCL 2026.08, ICS 9.7, VirtualTreeView 8.3, SynEdit TurboPack 2025.03 e Abbrevia 2026.10 (`README.md`).
  - O `tools\compilar.bat` funciona em modo `dcc32`, mas nenhum dos 4 projetos compila ainda (primeiras falhas no `tools\LEIAME-compilar.md`).
  - O `3rdparty` já tem `fvcscrypt.dll`, os CHM e os binários de referência 2.5.0.1030, e o cliente oficial está instalado em `C:\Program Files (x86)\JEDI\JVCS`.
  - Ainda não há `.dproj`, linha de base golden nem consultas ao banco.

## 0. Premissas e decisões

### 0.1 Decisões já tomadas

| Decisão | Consequência no plano |
|---|---|
| Alvo Delphi 13.2 Professional, **mantendo a compilação em Delphi 11 e 12** | Cada fase só termina compilando em BDS 37, 23 e 22. Escolhas forçadas: SynEdit da linha **pyscripter** (a TurboPack/GetIt exige D12+); JCL/JVCL do **GitHub master** (mesma versão nos três); VT V8.5 (`Packages\RAD Studio 10.4+`); ICS V9 com grupos 11/12/13; `EncryptedZipFile` (o D11 não tem `IZipCryptor`); verificação manual de `'PK'#3#4` no lugar de `TZipFile.IsValid`; não contar com Deflate64 (só D12+). |
| Fase 1 só **Win32** (FVCSCrypt.dll 32 bits; a IDE de 32 bits continua no 13) | EXE, Diff, console e DLL da IDE são Win32. Win64/ARM64EC ficam na F6, **bloqueados** até reimplementar ou isolar a FVCSCrypt (crítico C6). |
| Só o cliente é portado; servidor 2.5 Beta 3 (Firebird) intocado; protocolo idêntico | Teste "golden" de tráfego contra o cliente oficial é critério de pronto das fases F1, F2, F4 e F5. Nenhuma alteração em servidor ou banco de produção: os testes usam servidor de teste com cópia do banco. |
| Preferência por componentes **nativos** | JVCL visual e não visual, DFS, FavOpenDialog, Abbrevia, JclPCRE, HtmlHlp, RegAcc, RekScan e ItemProp viram VCL/RTL. JCL/JVCL só como dependência de transição. |
| Midware (licença não comercial): portar agora, isolando o transporte | Midware portado em `src\comp\midware` e transporte atrás de `src\common\client\JVCSTransport.pas` (F1). As versões alteradas são marcadas como tais (`Licencas.md`). |
| Estrutura `v2026` existente | `src\jedivcs` (EXE + DLL), `src\jedivcsdiff`, `src\jvcs` (console), `src\common`, `src\common\client`, `src\comp\{midware,textdiff,mdmailslot,crc,mwtools}`, `src\packages`, `tools`, `setup`, `3rdparty`. Novos: `src\jvcsideexpert`, `src\comp\encryptedzip` e `src\comp\dxgettext`. |

### 0.2 Decisões a registrar na F0

Estas decisões foram propostas pelo inventário ou pelo crítico e precisam de confirmação.

| Tema | Proposta | Motivo |
|---|---|---|
| `REPORTDLL` | Desligar e remover a impressão de relatórios via `jedivcsreport.dll` (ou reescrever com `SimpleReport`) | DLL sem fonte e incompatível com D13; o ramo `{$ELSE}` usa `TVCSReport`, que não existe. |
| Plugins (`TJvPluginManager`) | Desligar por define (ex.: `JVCS_PLUGINS`, desligado) | Não há plugins recompiláveis; handlers divergem da JVCL atual; include `..\stdplugin\...` aponta para pasta inexistente. |
| `LZH`/CipherLz | Remover; resposta `#$FF` vira erro | Código morto dos dois lados (crítico C4). |
| `BRANCHING` | Manter desligado | Não definido em nenhum `.dof`/`.inc`; JvWizard só seria necessário com ele. |
| `LANGUAGE` | Manter, com `gnugettext.pas` do dxgettext (alternativa: desligar) | Não há `.po/.mo` no repositório; desligar não perde nada hoje. |
| Code page do fio | Fixar após a F0 (provável 1252), configurável | Depende do `lc_ctype` do servidor e da ACP das estações antigas **[R1]**. |
| Blowfish de blobs | Conforme a varredura do banco: desativar a opção ou recuperar o formato com o DEC 6.4.1 | **[R10]** |
| ShareMem na DLL | Plano A: remover depois de desligar `REPORTDLL` e testar no `bds.exe`. Plano B: manter como 1ª unit | Crítico C7; o histórico registra rollback "due to IDE crashes". |
| Nome da DLL | Fixar no `.dproj` o mesmo nome que o novo expert carrega. Sugestão: `JvcsExternalDll.dll`, o nome do binário original (`3rdparty\referencia-2.5.0.1030`), para o expert poder carregar a DLL original ou a nova sem mudança. O código tem `library JediVCSDLL` e `cJVCSFileName = 'jedivcsdll.dll'` (`src\jedivcs\VCSBase.pas:113`), e esse nome também precisa ser conferido. | Crítico C10 |
| Linha do SynEdit | Instalado: TurboPack 2025.03 (GetIt, só D13). Como o Delphi 11 é requisito, o inventário recomenda **pyscripter/SynEdit** nas três IDEs, desinstalando o do GetIt. A alternativa é TurboPack no 12/13 e o branch `11Alexandria` no 11, com risco de API divergente. | Família SynEdit |
| Versão do VirtualTreeView | Instalado: 8.3 (GetIt, só D13). Recomendado: **V8.5** do GitHub nas três IDEs (`Packages\RAD Studio 10.4+`). | Família VTV |
| Origem de JCL/JVCL no 11/12 | GitHub master num commit equivalente ao 2026.08 do GetIt, ou GitHub nas três IDEs. | Famílias JCL/JVCL, crítico C8 |
| Abbrevia | Fica instalado só como ponte para compilar cedo; sai na F2 (`System.Zip` + `EncryptedZipFile`). | Família Compressão, `README.md` |
| ABI expert↔DLL | Manter a ABI `PAnsiChar` atual; ABI v2 (com tamanho de buffer e versão do record) é opcional | Permite validar o expert novo com a DLL original. |

### 0.3 Regras transversais (valem para todas as fases)

- **Matriz de build:** Win32 em Delphi 13.2, 12 e 11. Debug com `DEBUG` (`{$R+,Q+,C+}`) e Release sem `DEBUG`; o `{$DEFINE DEBUG}` fixo sai do `compopt.inc` e passa para a configuração do `.dproj` (crítico 1.8).
- **Search path:** nunca incluir `src\comp\_legacy` (só referência). Toda unit de terceiros portada fica em `src\comp\<pacote>` com cabeçalho de licença preservado e marcação de modificação.
- **Base das units:** usar sempre as cópias já presentes na `v2026` (de `jedivcsdll`, sem as mutilações do port Lazarus). Não reimportar nada de `Fontes_JediVCS_2.5\Jedi VCS Client\2.5\jedivcs\` sem diff.
- **Regressão de protocolo:** toda mudança em `src\comp\midware` ou `src\common\client` reexecuta a suíte golden (F1) antes de seguir.
- **Downloads e extrações** (dependências, `innoextract`, binários do instalador) só com autorização explícita do usuário, cada um numa pasta isolada.

### 0.4 Visão geral das fases

| Fase | Objetivo | Depende de | Entregável principal |
|---|---|---|---|
| **F0** | Ambiente, dependências externas, `.dproj`/build e linha de base golden | — | Dependências alinhadas em BDS 22/23/37; `.dproj`; `tools\compilar.bat` (já existe) ajustado; capturas golden e consultas no banco |
| **F1** | Midware portado + `JVCSTransport.pas` + teste golden de tráfego | F0 | `src\comp\midware` compilando; suíte golden passando |
| **F2** | Núcleo do cliente (`common\client`, Checksum, Crypt, ZIP nativo) + console | F1 | `jvcs.exe` funcional contra o servidor 2.5 Beta 3 |
| **F3** | Infraestrutura comum de GUI + **JEDIVCSDiff** (piloto) | F2 | `JEDIVCSDiff.exe` sem JVCL/DFS |
| **F4** | EXE standalone (JVCL visual → nativo, DFS → nativo, SynEdit, VT V8) | F3 | `Jedivcs.exe` sem JVCL/DFS |
| **F5** | DLL da IDE + novo expert ToolsAPI (BDS 22/23/37) + setup | F4 (DLL); o expert corre em paralelo desde a F0 | `jedivcsdll.dll`, `JvcsExpertBDS22/23/37.dll`, instalador |
| **F6** | Win64 / ARM64EC (opcional) | F5 + reimplementação ou isolamento da FVCSCrypt | binários Win64 e expert "Experts x64" |

**Ordem em relação ao esboço inicial.** O Diff vem **antes** do EXE, como propõe o crítico: ele é menor, depende de um subconjunto da infraestrutura comum, usa SynEdit e a status bar DFS, e serve de piloto para a migração de DFM e SynEdit. O EXE também o usa como ferramenta de comparação.

Correspondência com a ordem do crítico:

| Crítico | Este plano |
|---|---|
| Fases 0 e 1 | F0 |
| Fase 2 | F1 e F2 |
| Fase 3 (console) | F2 |
| Fases 4 e 5 | F3 |
| Fase 6 | F4 |
| Fases 7, 8 e 9 | F5 |
| Fase 10 | F6 |

---

## F0 — Ambiente, dependências externas, build e linha de base

**Objetivo.** Deixar as três IDEs prontas, com as mesmas versões de terceiros (hoje só o D13.2 tem as dependências, via GetIt), os quatro projetos compilando até o primeiro erro de código do cliente (e não por pacote ou caminho ausente) e a linha de base de protocolo e dados capturada.

### Tarefas

**0.1 Ambiente.**
- O Delphi 13.2 já está instalado (`Studio\37.0\bin\bds.exe`, `dcc32.exe`, `brcc32.exe`, `cgrc.exe`; crítico C11). A plataforma Win64 não está instalada, o que não afeta a fase 1.
- Disponibilizar Delphi 11 (BDS 22) e 12 (BDS 23) para a matriz de build.

**0.2 Dependências externas** (mesma versão nas três IDEs):

| Dependência | Estado no D13.2 | Alvo (inventário) | O que falta |
|---|---|---|---|
| JCL | GetIt 2026.08 instalado | GitHub project-jedi/jcl master; mesma versão no 11/12/13 | No D11/D12: GitHub num commit equivalente (`git submodule update --init` para o `jedi.inc`; `jcl\install.bat`). |
| JVCL | GetIt 2026.08 instalado (só transição) | GitHub master: d37 (D13), d29 (D12), d28 (D11) | No D11/D12: GitHub. Se o GetIt der F2613, reinstalar pelo GitHub. |
| ICS | GetIt 9.7 instalado | 9.7 (GetIt) ou SVN `icsv9` (9.8 Beta, grupos 11/12/13) | No D11/D12: SVN na mesma versão. `OverbyteIcsDefs.inc` com `MSCRYPT_Clients/Servers/Tools` desligados se surgir E2203; `USE_SSL` opcional. |
| VirtualTreeView | GetIt 8.3 instalado | Tag **V8.5** (GitHub), `Packages\RAD Studio 10.4+` | Conforme a decisão 0.2: trocar por V8.5 nas três IDEs (o GetIt 8.3 só atende o D13). |
| SynEdit | GetIt TurboPack 2025.03 instalado | **pyscripter/SynEdit**, commit de 2025-11-24, `Packages\Alexandria+\Delphi` (única linha que compila no D11) | Conforme a decisão 0.2. Nunca deixar duas linhas no search path ao mesmo tempo. |
| Abbrevia | GetIt 2026.10 instalado | Remover na F2 | Usar só como ponte até `JVCSZipUtils` existir. |

Cópias locais a colocar na `v2026`:
- `src\comp\mwtools\mwPasLex.pas`, `mwPasLexTypes.pas` e `CastaliaParserDefines.inc`, a partir de `CastaliaPasLex*` (renomear, como exige o README do Castalia).
- `src\comp\encryptedzip\` (pasta nova): `uEncryptedZipFile.pas` e o cifrador PKWARE (Uwe Raabe, MIT).
- `src\comp\dxgettext\gnugettext.pas` (pasta nova): dxgettext r196.
- `src\common\jedi.inc`, fixado a partir de project-jedi/jedi (define VER370/DELPHI37 e não define `WINDOWS`).
- DEC 6.4.1: **só** se a varredura 0.7 achar blobs Blowfish.

**0.3 Projetos `.dproj` novos** (um por `.dpr`): `src\jedivcs\Jedivcs.dproj`, `src\jedivcs\JediVCSDLL.dproj`, `src\jedivcsdiff\JEDIVCSDiff.dproj`, `src\jvcs\jvcs.dproj`.

Defines por projeto:

| Projeto | Defines |
|---|---|
| EXE | `USECLIENTDISPATCHER;LANGUAGE;DelphiPersonalEdition;OVERBYTEV6_UP` |
| DLL | `IDEDLL;EXT_IDE_INTF;LANGUAGE;DelphiPersonalEdition;OVERBYTEV6_UP` |
| Diff | `LANGUAGE;DelphiPersonalEdition;OVERBYTEV6_UP` |
| Console | `DelphiPersonalEdition;OVERBYTEV6_UP` |

`DEBUG` fica só na configuração Debug. Notas sobre os defines:
- O `src\jedivcs\compopt.inc` é compartilhado por EXE e DLL e traz `IDEDLL`/`EXT_IDE_INTF` comentados. Se `EXT_IDE_INTF` se perder, a DLL cai no ramo OTA antigo, que não compila.
- `DelphiPersonalEdition` também no EXE, para o RFormat não depender de `Data.DB` (`TBookmark = TBytes`).

Demais configurações:
- **Unit scope names:** `Winapi;System.Win;System;Vcl;Vcl.Imaging;Vcl.Samples;Vcl.Shell;Data` (crítico 1.9).
- **Search path:** `..\common;..\common\client;..\comp\midware;..\comp\crc;..\comp\textdiff;..\comp\mdmailslot;..\comp\mwtools;..\comp\encryptedzip;..\comp\dxgettext`. O Diff mantém `..\jedivcs` até a F3.
- **Saída:** `bin\client\Win32`; DCUs em `dcu\Win32\<cfg>` (`README.md`).
- **"Include version information" desligado:** `jvcsver.rc` é a fonte única, com `ProductVersion` no formato `n.n.n.n` e resultado de pelo menos 2.2.0 **[R5]**.
- **DLL:** sem runtime packages. Tirar o `{$IMAGEBASE $00400000}` do `compopt.inc` (linha 30 em `src\jedivcs`; também em `src\jedivcsdiff\compopt.inc:25` e `src\jvcs\COMPOPT.INC:20`) e deixar no `.dproj` só onde fizer sentido (crítico 1.8). Nome de saída fixado (0.2).
- **EXE e Diff:** manifest gerado pelo `.dproj` com runtime themes e DPI começando em *GDI Scaling* ou *System Aware*, não PerMonitorV2.

**0.4 Build por linha de comando.** O `tools\compilar.bat` e o `tools\LEIAME-compilar.md` já existem: modo `dcc32` direto enquanto não há `.dproj`, ramo `msbuild` automático quando o `.dproj` existir.

Ajustes previstos:
- exercitar o ramo `msbuild` quando os `.dproj` da 0.3 forem criados;
- alinhar os defines da tabela do script com a 0.3 (hoje o `exe` não recebe `DelphiPersonalEdition`);
- acrescentar `..\comp\encryptedzip` e `..\comp\dxgettext` ao search path base quando essas pastas existirem;
- documentar a matriz 11/12 via `BDSROOT`/`JVCS_CATALOG`, que o script já aceita;
- tratar as pendências que o `LEIAME-compilar.md` já lista (FastMM4, `{$ifdef WINDOWS}` em `JVCSIDESettings`, units ausentes, `winxp.res`). Elas são as primeiras tarefas da F1–F3.

**0.5 Binários de referência.** **Feito**: copiados da instalação oficial 2.5.0.1030 para `3rdparty` (ver `3rdparty\LEIAME.md`):
- `fvcscrypt.dll` 1.0.0.19;
- `jedivcs.chm` e `jedivcsdiff.chm`;
- em `referencia-2.5.0.1030\`: `JvcsExternalDll.dll`, `JvcsExpertBDS19/20/21.dll` e os executáveis.

Falta só conferir, no registro da instalação ou no script do instalador, o valor `JVCSIDEClient` da chave `Experts`, que o inventário não reverificou.

**0.6 Linha de base golden** (crítico, Fase 0):
- Montar um servidor 2.5 Beta 3 de **teste** com cópia do banco. O cliente oficial já está instalado em `C:\Program Files (x86)\JEDI\JVCS`, com cópias em `3rdparty\referencia-2.5.0.1030`.
- Capturar com proxy TCP ou Wireshark:
  - `GET_SERVER_TIME`;
  - `LOGIN` do EXE e da DLL (anotar a versão enviada);
  - `GET_PROJECT_LIST`;
  - `CHECKIN_MODULE` (blob);
  - `GET_CHECKOUT_MODULE`;
  - textos acentuados;
  - uma chamada que gere erro no servidor.
- Guardar em `tools\golden\captures\` (proposta), com o roteiro exato usado.
- Se houver uma IDE antiga com o expert 2.5.0.1030 (até BDS 21), registrar o nome de projeto que ele devolve para um projeto de amostra **[R13]**.

**0.7 Consultas somente leitura no banco** (resultado registrado em `doc\server\`):
- `BLOBS.ORIGCRC` × CRC do diretório central do ZIP, numa amostra ampla **[R7]**;
- método (offset 8) e flags (bit 0) dos blobs **[R9]**;
- blobs que não começam com `PK` (Blowfish) **[R10]**;
- formato da property "Line History" (começa com `PK`?) **[R12]**;
- `lc_ctype`/charset do banco e da conexão **[R1]**;
- tamanho da coluna do header **[R11]**.

**0.8 Registrar as decisões** da seção 0.2.

### Critério de pronto

- [ ] Decisões da 0.2 registradas, inclusive a linha do SynEdit e a versão do VT.
- [ ] Dependências com as mesmas versões em BDS 37, 23 e 22 (hoje só o BDS 37 está pronto).
- [ ] Os 4 `.dproj` abrem e compilam, via `tools\compilar.bat`, até o primeiro erro de **código do cliente**, sem "file not found" de terceiros.
- [x] `3rdparty\fvcscrypt.dll`, CHM e binários de referência presentes.
- [ ] Capturas golden e resultados das consultas arquivados.

### Riscos

- **GetIt:** falhas de instalação e erro F2613 com JCL/JVCL. Mitigação: usar o GitHub.
- **Divergência entre IDEs:** o GetIt instala versões diferentes por IDE, ou só para o D13.
- **ARM64:** a instalação da JCL por `install.bat` em Windows 11 ARM64 (Delphi emulado) não foi validada.
- **ICS:** erro E2203 se `MSCRYPT_*` ficar ligado.
- **Expert antigo:** os experts de referência são para BDS 19/20/21. Sem uma IDE 10.2–10.4 instalada, o nome de projeto que eles devolvem **[R13]** tem de ser inferido por engenharia reversa ou pelo registro de projetos do servidor.

---

## F1 — Midware portado, transporte isolado e teste golden de tráfego

**Objetivo.** Ter a camada de protocolo compilando em D11/12/13 Win32, com range check ligado, e produzindo **bytes idênticos** aos do cliente oficial. Toda a comunicação passa por um ponto de troca próprio (`JVCSTransport.pas`).

### Tarefas

**1.1 `src\comp\midware\MWDefs.inc`.** Incluir o `OverbyteIcsDefs.inc` do ICS V9 no lugar do `IcsDefs.inc` V5 e manter `$B-,$T-,$X+,$H+,$J+`.

**1.2 `src\comp\midware\RFormat.pas`.** Port usando como referência o OverbyteRFormat 7.02 (midware20190414.zip ou SVN rev. 52):
- `FDataBuffer: PAnsiChar` e separadores `AnsiChar`;
- `type TJVCSWireString = type AnsiString(<cp>)`, configurável, nas conversões string↔bytes **[R1]**;
- `AppendFields` passa a tratar:
  - `vtUnicodeString` usando `Length`, sem truncar no `#0`;
  - `vtWideChar`, `vtPWideChar` e `vtInt64`;
  - `vtAnsiString` sem conversão;
  - `vtExtended` com `FloatToStrF(ffGeneral,18)`, preservando a semântica atual de separador decimal **[R3]**;
- corrigir `MoveEscaped` e `AppendStreamField`;
- manter os 3 bytes de separadores e os escapes **[R2]**;
- bookmarks: restaurar é opcional (não são usados);
- cabeçalho marcado como versão alterada ("JVCS edition").

**1.3 `src\comp\midware\ApsCli.pas`.** Port a partir do OverbyteApsCli 7.00:
- `Header: AnsiString`, eventos `PAnsiChar` (o `DBModule` já espera assim), `TIcsWndControl`, `LastReplyRXTime` e `RcvSizeInc`;
- `uses OverbyteIcsWSocket, OverbyteIcsTypes`;
- `SocketFamily := sfIPv4` **[R6]**;
- manter as propriedades publicadas `SocksAuthentication`, `MaxRetries` e `Answer`;
- conferir `PutDataInSendBuffer`/`Receive` e `SendStr(#13#10)` no V9.

**1.4 `src\comp\midware\CBroker.pas`.**
- `uses OverbyteIcsWSocket, OverbyteIcsTypes`;
- `FUserData: NativeInt` (`TClientObject` e `TResponseBroker`);
- `WaitForAnswer` igual ao original: polling, sem timeout.

**1.5 CipherLz/Lzh.** Não entram na `v2026` (já não foram copiados para `src\comp\midware`). A remoção dos ramos `{$DEFINE LZH}`/`Cipher` e a checagem de `#$FF` no `DBModule` ficam na F3 (3.6) **[R16]**.

**1.6 `src\common\client\JVCSTransport.pas`** (novo). Ponto único de troca do transporte:
- **Contrato mínimo** (interface, ex.: `IJVCSTransport`): conectar (com banner), desconectar, estado, enviar requisição (`FunctionCode` + corpo `TMWBuffer`) e receber status + corpo de resposta, `MaxRetries`/timeouts e eventos de sessão encerrada/erro.
- **Implementação inicial:** `TJVCSMidwareTransport`, sobre o `TAppSrvClient` portado, criada por uma fábrica única (ex.: `CreateJVCSTransport`).
- **Núcleo:** `JVCSConnect`, `CBroker.TClientObject` e `JVCSClientObjBase` passam a obter o cliente pela fábrica, sem instanciar `TAppSrvClient` diretamente.
- **GUI:** as 48 units que usam `DataModule1.AppSrvClient1` (~3856 ocorrências) continuam usando a fachada `TAppSrvClient`. A migração delas só é necessária se o Midware for trocado. Documentar quais membros da fachada podem ser usados fora do transporte (nada de nível de socket).
- **Limite:** o formato `TMWBuffer` (RFormat) também é código Midware. Trocar o Midware por completo exige uma reimplementação "clean-room" do `TMWBuffer` com a mesma API, validada por esta mesma suíte golden.

**1.7 Pacote design-time** `src\packages` (ex.: `JVCSMidwareD.dpk`). Registra `TAppSrvClient` e `TMWBuffer` com as propriedades publicadas (`SocksAuthentication`, `MaxRetries`, `Answer`, `DataBufferSize`, `HeaderSize`, `AutoExpand`), para abrir `DBModule`, `ChkInSingle`, `MergeVersion` e `ToDo` no designer. O `TmdSecureMail` entra na F3.

**1.8 Suíte golden** (`tools\golden\`, proposta):
- **(a)** Teste de ida e volta do `RFormat`: montar os campos e comparar com os corpos capturados; decodificar as respostas capturadas e comparar com os valores esperados.
- **(b)** Programa console de teste que executa o roteiro da 0.6 contra o servidor de teste usando `JVCSTransport` + `JVCSCrypt` (sem mudanças) e grava os bytes.
- **(c)** Comparador que ignora apenas campos legitimamente variáveis: hora, TransactionID e senha cifrada (depende da hora do servidor).
- Rodar em ACP 1252 e 65001 e em locale pt-BR e en-US.

### Critério de pronto

- [ ] `src\comp\midware` compila em D11/12/13 Win32 em Debug (`{$R+,Q+}`) e Release, sem warnings de conversão de string implícita.
- [ ] (a) passa para todas as capturas.
- [ ] (b)+(c) idênticos para `GET_SERVER_TIME`, `LOGIN`, `GET_PROJECT_LIST`, `CHECKIN_MODULE` (blob), `GET_CHECKOUT_MODULE` e textos acentuados, nas duas ACPs **[R1–R6]**.
- [ ] Nenhuma resposta iniciada por `#$FF` **[R16]**.

### Riscos

- **Code page errada:** mojibake e módulos duplicados. Mitigação: a decisão sai da 0.7 e é configurável.
- **Floats e locale:** dependem do separador decimal **[R3]**.
- **API do ICS V9:** diferenças em envio e recepção.
- **Modelo assíncrono:** baseado em mensagens. O console precisa de laço de mensagens, já atendido por `CBroker.WaitForAnswer` com `MsgWaitForMultipleObjects`.
- **Licença do Midware:** marcar as versões alteradas; a decisão comercial fica para depois.

---

## F2 — Núcleo do cliente e console

**Objetivo.** Ter o núcleo sem VCL completo (`src\common\client` + `src\comp\crc`) e o **console `jvcs.exe`** funcionando contra o servidor 2.5 Beta 3. É o primeiro binário completo e valida o protocolo de ponta a ponta; o console não usa JVCL, VT nem SynEdit e pode ficar sem JCL.

### Tarefas

**2.1 `src\comp\crc\Checksum.pas`** (recriar):
- funções `CRCInt(const FileName: string; var Err: string): Integer` e `CRCString(const FileName: string): string` (`'$' + IntToHex(crc, 8)`);
- `System.ZLib.crc32`, leitura em blocos com `fmShareDenyWrite`;
- cast explícito `Integer(crc)`, unit com `{$R-}{$Q-}`;
- validar contra o resultado da 0.7. Se não bater, é **bloqueante**: investigar o algoritmo antigo antes de seguir **[R7]**.

**2.2 `src\common\client\JVCSZipUtils.pas`** (novo, sobre `System.Zip.TZipFile`):
- `JVCSCompressFile`/`JVCSCompressFileList`: ZIP Deflate de 1 item, nome sem path e **data do arquivo**, gravado com `Add(FileName, ExtractFileName(FileName), zcDeflate)` ou com o overload `TZipHeader`, nunca com `Add(Stream, ...)` **[R8]**;
- `IsZipBlob` (`'PK'#3#4`);
- extração para stream, arquivo ou pasta aplicando a data do item;
- leitor de fallback se a 0.7 achar métodos legados **[R9]**;
- substituir o `TJVCSAbZipper` e as chamadas Abbrevia em `JVCSClientObjBase` (`BlobAsText`, `ExtractBlobToDir/File/Stream`) e corrigir o cast `FileSizes.Add(Pointer(...))`.

**2.3 `src\common\client\BFCrypt.pas`** (recriar):
- `Base64Encode/Decode` com `TBase64Encoding.Create(0)` sobre bytes ANSI; validar com valores reais do registro de uma estação 2.5 **[R21]**;
- `BlowFishEncode/Decode` conforme a decisão da 0.2: stub que devolve `False`, com a opção desativada na UI, ou DEC 6.4.1 com o formato recuperado **[R10]**.

**2.4 `src\common\client\JVCSClientObjBase.pas`:**
- `SafeStrToFloat` com `FormatSettings` (crítico 1.2) **[R3]**;
- `BlobAsText` com `TBytes` + `TEncoding` da code page do protocolo **[R18]**;
- `PUserData(FUserData)` com `NativeInt`;
- preservar `DoExecute` (TransactionID/UserID) e o `raise EJVCSClient` **[R17]**.

**2.5 Demais units do núcleo:**
- `JVCSClientObj.pas`: `TJVCSLogin.DoExecute` com `S: RawByteString`, enviado como `vtAnsiString` **[R4]**.
- `JVCSConnect.pas`: `OverbyteIcsTypes` (`socksNoAuthentication`), `Integer(@FUserData)` → `NativeInt` e carga da `FVCSCrypt.dll`.
- `JVCSClientDispatcher.pas`: `OVERBYTEV6_UP`, API `TIcsWndControl`.
- `JVCSNewClientObj.pas`, `JVCSTypes.pas`, `JVCSClientConsts.pas`, `TZHandling.pas`: cópia de `jedivcsdll`, já sem `{$ifdef WINDOWS}`.
- `JVCSCrypt.pas`: sem mudanças.
- `JVCSClientFunctions.pas`: `StrMatches` local com a semântica da JCL (só `*`/`?`, erro com padrão vazio, testes unitários), `IsFileDirtyCRC` e `GetModuleFileName`/`GetVolumeInformation` com tamanho em caracteres (crítico 1.10).
- `src\common\VCSCommon.pas`: cópia do cliente.

**2.6 Helpers nativos em `src\common`** (substituem a JCL no núcleo e no console):
- `JVCSTrace.pas`: `TraceMsg`/`TraceFmt` sobre `OutputDebugString`.
- `JVCSStrUtils.pas`: `StrToken`, `StrTokenToStrings`, `StrToStrings`, `StrMatches`, `StrReplace` (só a 1ª ocorrência), `StrSame` etc.
- `JVCSFileUtils.pas`: `PathAddSeparator`, `GetSizeOfFile` em Int64 e helper de versão de arquivo no lugar de `TJclFileVersionInfo`.

**2.7 `src\jvcs\jvcs.dpr`:**
- remover `FastMM4` (linha 140);
- `GetSizeOfFile` via `JVCSFileUtils` **[R15]**;
- usar `CRCInt` em vez de `StrToInt(CRCString)`;
- banner com o helper de versão;
- manter o `COMPOPT.INC` próprio, sem `IMAGEBASE`; o console envia a versão 239 fixa.

### Critério de pronto

- [ ] `jvcs.exe` compila em D11/12/13 Win32 **sem JCL nem JVCL**.
- [ ] Contra o servidor de teste: login, lista de projetos, sync por CRC sem falsos "modificados", e check-in/checkout de arquivos texto e binários com nomes e conteúdo acentuados.
- [ ] Cruzado com o cliente 2.5 Beta 3: check-in pelo novo → checkout pelo antigo e vice-versa, com conteúdo, data, CRC e tamanhos iguais **[R7, R8, R15]**.
- [ ] `CRCInt` validado contra a amostra de `ORIGCRC`; a suíte golden continua passando.

### Riscos

- **CRC divergente** (bloqueante) **[R7]**.
- **Blobs legados e Blowfish** **[R9, R10]**.
- **Base64 do registro:** a codificação usada pelo binário antigo é desconhecida.
- **Data no ZIP:** fica em hora local DOS e pode variar com fuso ou horário de verão.
- **`StrMatches`:** a semântica decide os filtros de check-in.

---

## F3 — Infraestrutura comum de GUI e JEDIVCSDiff (piloto)

**Objetivo.** Portar as units comuns de GUI e entregar o **JEDIVCSDiff.exe** sem JVCL/DFS. O Diff é o piloto da migração de DFM, SynEdit e status bar.

### Tarefas

**3.1 Recursos.**
- `jvcsver.rc` (`ProductVersion` `n.n.n.n` com resultado de pelo menos 2.2.0, mais as chaves `BuildTimestamp` e `VCS` lidas pelo About), `STRINGS.RC` e `CURSORS.RC` recompilados com brcc32/cgrc **[R5]**.
- Remover `{$R \Projects\...\winxp.res}` (`src\jedivcs\Jedivcs.dpr:268`, `src\jedivcsdiff\JEDIVCSDiff.dpr:80`).
- Garantir um único VERSIONINFO (`{$R *.res}` + `jvcsver.res`).

**3.2 Units base.**
- `src\common\JVCSForms.pas`, `src\jedivcs\ConfigStorage.pas`.
- `src\jedivcs\VCSBase.pas`: remover o `uses VCSProcBase` da implementação (linha 336), o que solta o Diff do núcleo da GUI (crítico 1.4).
- `JclDebug` → `JVCSTrace`: trocar o uses **e** o prefixo; ~190 `TraceMsg` e 19 `TraceFmt` na base da DLL.
- Tirar o `JVCSDebugView` do `.dpr`.
- Corrigir `DecimalSeparator`/`ThousandSeparator` (`VCSProcBase`, `ProjAdmin`, `Std_ListView`).

**3.3 Substitutos nativos da JVCL não visual.**
- `src\jedivcs\JVCSDialogs.pas` nativo: `CreateMessageDialog` + `TCheckBox`, mais wrappers `Msg*` com `MessageBox`. Preservar:
  - as chaves `<Filename>\<ID>\DontShow` e `LastResult`;
  - o estado invertido;
  - o diálogo suprimido devolvendo `DefaultResult`;
  - o caso `[mbIgnore, mbCancel]`;
  - `{$J+}`, ou trocar a constante por variável.
- `JVCSMruList.pas` (`TStringList` + `MaxSize`/`Mode`) e `src\common\JVCSThreads.pas` (`AllocateHWnd`).
- `src\common\JVCSLanguage.pas` + `gnugettext.pas`: trocar `JvGnugettext` → `gnugettext` nas ~180 cláusulas sob `LANGUAGE` e usar `GetCurrentLocaleName`.
- **Transição:** se o `JvDSADialogs` ficar temporariamente, incluir `JvDynControlEngineVCL` no uses de `JVCSDialogs` (senão dá Assert/AV).

**3.4 `src\jedivcs\VCSProcBase.pas`** (cópia `jedivcsdll`; revisar a 1 marca Lazarus apontada no manifesto):
- `HtmlHelpW` declarado localmente;
- `TFavOpenDialog` → `TOpenDialog` e `TFavSaveDialog` → `TSaveDialog`, com o MRU em `ExecuteFavOpenDialogWithMru`;
- `_StrToFloat` com `FormatSettings`;
- `GetSelfFileName` com tamanho em caracteres **[R5]**;
- `JclSysInfo` → `TPath` (mesmas pastas) **[R21]**.

**3.5 Helpers visuais compartilhados** (`src\common`, nomes sugeridos):
- status bar: `TStatusBar` + `TProgressBar` como gauge (`pbstMarquee`), painéis owner-draw com `DT_END_ELLIPSIS` e clique/hint por hit-test (usado por ProjAdmin, Syncronice e DiffMain);
- `JVCSBaseAboutDialog`: `TRichEdit` com `EM_AUTOURLDETECT`/`EN_LINK` e sem o bloco DelZip;
- `ListView.pas`: `TJvMemo` → `TMemo`.

**3.6 `src\jedivcs\DBModule.pas/.dfm`.**
- Remover `{$DEFINE LZH}`, CipherLz e o ramo `Cipher`.
- Resposta `#$FF` passa a gerar erro **[R16]**.
- Handlers `PAnsiChar`.
- Registrar `TmdSecureMail` no pacote de `src\packages`.

**3.7 JEDIVCSDiff** (`src\jedivcsdiff`):
- `JEDIVCSDiff.dpr`: tirar `FastMM4` (linha 54) e `winxp.res` (linha 80).
- `DiffMain.pas/.dfm`:
  - `TSynEditMark.Create(mwceSource)` (2 pontos) + `InvalidateGutter`;
  - tirar `Gutter.Width = 35` do DFM e ajustar a banda de marks;
  - `dfsStatusBar` → status bar nativa;
  - `TJvMruList` → MRU nativo no **mesmo formato** de registro (`HKCU\Software\JEDI\JEDIVCSDiff\MRU`, `MRUList` + a..j);
  - `TJvComboBox` sem `DotNetHighlighting`;
  - remover os blocos `ThemeMgr` e o `ItemProp` morto;
  - re-salvar o DFM com o `SynEditDD` instalado.
- `DiffHLProp.pas`: `TSynHighlighterAttributes.Create(AName, AFriendlyName)` (linhas 308/326); `TColorBox`.
- `DiffEditorProp.pas`: `TSpinEdit`/`TColorBox`.
- `DiffSimpleReport.pas`: `RegAcc` → helpers `TRegistry` tolerantes a tipo (mesma chave e nomes); `TSaveDialog`.
- `DiffHelp.pas`: `HtmlHelpW`.
- `DiffAbout.dfm`: corrigir `inherited Memo3`.
- `JVCSDiffResources.pas`: textos de versão.
- Avaliar mover `listview`, `vcsbase`, `configstorage` e `JVCSGUIClientResources` de `src\jedivcs` para `src\common`, para que o Diff não dependa da pasta do EXE (crítico 1.4).

### Critério de pronto

- [ ] `JEDIVCSDiff.exe` compila em D11/12/13 Win32, sem units `Jv*` nem `dfs*`.
- [ ] Todos os forms do Diff abrem no designer e em runtime sem `EReadError`.
- [ ] Compara dois arquivos locais e um arquivo contra uma revisão do servidor; LOGIN do Diff com 239.
- [ ] O MRU de uma instalação antiga aparece; o `CRCString` é igual ao do antigo.

### Riscos

- **API do SynEdit:** mudaram marks e gutter.
- **DFMs com propriedades órfãs:** geram `EReadError` em runtime, não na compilação.
- **gettext:** precedência de alias.
- **Semântica DSA.**
- **Ajuda:** o CHM com MOTW ou aberto de pasta de rede é bloqueado pelo Windows. Os CHM originais estão em `3rdparty`.

---

## F4 — EXE standalone (Jedivcs.exe)

**Objetivo.** Cliente GUI completo sem JVCL visual nem DFS, migrado em **lotes testados contra o servidor** (crítico, Fase 6).

### Tarefas

**Lote 4.1 — Esqueleto e login.**
- `src\jedivcs\Jedivcs.dpr`: tirar `FastMM4` (linha 129); `ExceptDlg` fica sob `JCL_DEBUG_DATA` desligado.
- `Create.pas`:
  - `OverbyteIcsPing`/`OverbyteIcsIcmp` (compilam sem mudanças);
  - `TJvEdit` → `TEdit`;
  - `EncryptServerData` continua `False`;
  - senha de identidade em Base64 **[R21]**;
  - versão do LOGIN **[R5]**;
  - `SyncToServerTime` sem `SeSystemtimePrivilege` em processo não elevado: tratar a falha.
- `ProjAdmin.pas/.dfm`:
  - `TJvToolBar` → `TToolBar`;
  - status bar nativa;
  - `elvModules` → componente compatível (abaixo);
  - plugins desligados por define, corrigindo também o `{$I ..\stdplugin\...}` da linha 315;
  - `REPORTDLL` desligado;
  - remover os blocos `ThemeMgr`;
  - `JclSecurity` → `EnablePrivilege` (sem `SE_DEBUG`);
  - `DragQueryFile` com tamanho em caracteres.
- `src\comp\mdmailslot\mdmailslot.pas`:
  - `AnsiString`/`PAnsiChar`, tamanhos em bytes, `NativeInt`;
  - `CalcCRC16` sem `ERangeError`;
  - `CharToOEM` corrigido **[R20]**.
- `ProjectTreeDockWnd`: `VirtualTrees.DrawTree` e `ItemHtDraw` local.
- **Componente compatível com a EnhListView** (nome sugerido `TJVCSListView`, unit em `src\common`, registro em `src\packages`):
  - `TListView` + `AutoColumnSort`, `ShowSortArrows`, `OnSortItems(TSortAs)`, `Resort` e `AutoResort`;
  - setas `HDF_SORTUP/DOWN` reaplicadas depois de ordenar, de `UpdateColumn` e de `RecreateWnd`;
  - custom draw;
  - **renomear os 9 handlers `OnDrawItem`**, que têm assinatura diferente da do `TListView`.
  - Cobre 18 listas em 15 forms do EXE.

**Lote 4.2 — Operações com o servidor.**
- `ChkInSingle`:
  - Checksum, `JVCSZipUtils` e Blowfish conforme a decisão;
  - `TJvArrowButton` → `TSpeedButton` + `PopupMenu`;
  - `TJvLED` → `TShape`.
- `ChkOutSingle`, `JVCSChkInOutCommon` (`StrReplace` só a 1ª ocorrência).
- `Syncronice`:
  - `TJvCheckTreeView` → `TTreeView` com `CheckBoxes`;
  - `TJvNetscapeSplitter` → `TSplitter`;
  - 4 listas;
  - gauge e LED na status bar.
- `HandleBlob`, `Distribution`, `MergeVersion`.
- `TextComp`: `GetArchiveCRC`; `JEDIVCSDiff.exe` ao lado como ferramenta de comparação.
- `Backup`:
  - `TEncryptedZipFile` e `Password.pas`;
  - restaurar backups antigos com senha, inclusive não ASCII;
  - nível de compressão.

**Lote 4.3 — History, Line History e Compressed Diff.**
- `History`/`ModuleHistoryWindow`: tirar `SortGrid` do uses; `ExtBugtracker` com `TRegEx` e `try/except` em `Groups['bug']`.
- `JVCSLineHistoryFrame`: banda `gbkCustom` (limpar as bandas padrão) e `GutterWidth`.
- `JVCSLineHistoryHighlighterUnit`: tirar o MPerl.
- `JVCSCompressedDiffSynProxy`:
  - `GetTokenLength` (obrigatório);
  - linha em base 1;
  - `SetLine` público;
  - `Get(Friendly)LanguageName`.
- `JVCSCompressedDiffFrame`.
- `JVCSLineHistorySettingsDialog`: cores, gradiente e `TColorDialog`.
- `JVCSBrowserFrame`: VT V8, `OnGetText` com `string`.
- `JVCSLineHistoryPropertyStorage`: manter a JclSimpleXml **[R11]**.
- `src\comp\textdiff`: `DiffUnit`/`HashUnit` portados (`TArray<Integer>` nos chamadores; hash sobre todos os bytes).
- `UsedUnits`/`ProjDependencies`/`ToDo` com `mwPasLex` (Castalia):
  - `UseDefines := False`;
  - `Origin := PChar(S)`, lendo o arquivo com `TEncoding`;
  - terminador no ramo do EXE **[R19]**.
- `JVCSProjectTreeUnit`: VT V8; `JclResources` → resourcestrings.

**Lote 4.4 — Forms de manutenção (JVCL visual → nativo).**
- **Forms:** AssignLabels, AddNewBug, AddNewGroup, AddNewMilestone, CheckfBuild, Description, DirectSQL, ListView, MaintainBugs, MaintainFFamilies, MaintainLabels, MaintainMilestones, MaintainUsers, NtfySend, ToDoEdit, ToDoFilter, Touch, WCViewFilter, SearchModules, ProjectRights, ServerOptions, Purge, ChangeUserPW, SelectList, UnitFilter, ListEdit, SimpleReport e SelectDrive.
- **Cuidados:**
  - ordem dos itens de `icbLevel`/`icbRight` **[R14]**;
  - spins para `Integer`;
  - remover as propriedades JVCL dos DFMs.
- **`Options`:**
  - `TJvFilenameEdit` → `TButtonedEdit` + `TOpenDialog`, reproduzindo `AddQuotes` e corrigindo o bug `edBMP`/`edRWS`;
  - `TColorBox` com `cbSystemColors`;
  - `TTrackBar`;
  - `TJvSearchFiles` → busca recursiva interrompível.

**Lote 4.5 — Restante.**
- `SelectFolder`: `TShellTreeView` criado em runtime, ou `TFileOpenDialog` com `fdoPickFolders`.
- `CompareFolders`: `RekScan` → `FindRecursive` própria (mesma grafia de `Path`, barra final).
- `LoadModule`: `ItemProp` → `SHOpenWithDialog`.
- `SMTPSend`: pasta em `%APPDATA%` ou opção desligada (crítico 1.11).
- `JVCSManageFavorites`; `OpenProject` e `Password`: blocos `{$ifdef FPC}`.
- Auditoria Unicode restante (crítico 1.10: `SimpleReport` `MS.Write(S[1], Length(S))`, `Char in [...]`); avisos do `FileCtrl`.

**4.6 Fechamento.**
- Nenhuma unit `Jv*` ou `dfs*` no fecho do EXE (conferir com grep e com o `.map`).
- JVCL fora do search path do EXE.

### Critério de pronto

- [ ] `Jedivcs.exe` compila em D11/12/13 Win32 sem JVCL nem DFS.
- [ ] Todos os forms abrem sem `EReadError`, com o build Debug.
- [ ] Checklist de compatibilidade (final deste documento) aprovado para o EXE.
- [ ] Teste lado a lado com o 2.5 Beta 3 nas operações dos lotes 4.1–4.3.

### Riscos

- **Assinaturas de evento ligadas via DFM:** a compilação não verifica. `OnGetText`/`OnHeaderClick` do VT e `OnDrawItem` da EnhListView corrompem memória em silêncio. Mitigação: abrir cada form no designer e exercitar com range check.
- **Ordem de itens enviada ao servidor** **[R14]**.
- **Proxy do SynEdit:** cores e realces somem sem `GetTokenLength`.
- **Volume:** 47 DFMs com JVCL visual no EXE/DLL (mais 3 no Diff) e 38 objetos EnhListView (18 no EXE, 20 na DLL).

---

## F5 — DLL da IDE, novo expert ToolsAPI e setup

**Objetivo.** Integração com a IDE de 32 bits do Delphi 13.2 (BDS 37), 12 (BDS 23) e 11 (BDS 22), mais o instalador.

> **Trilha paralela 5A:** o expert pode começar logo depois da F0, carregando a DLL **original** (`3rdparty\referencia-2.5.0.1030\JvcsExternalDll.dll`: mesma ABI e já fala com o servidor 2.5 Beta 3), para separar os erros do expert dos erros do port da DLL. Os experts originais `JvcsExpertBDS19/20/21.dll` da mesma pasta servem de referência de comportamento: menus, chamadas da ABI e nome de projeto devolvido.

### Tarefas

**5.1 DLL** (`src\jedivcs\JediVCSDLL.dpr` + `.dproj`):
- defines `IDEDLL;EXT_IDE_INTF` no `.dproj`;
- remover o ramo VCSManager (`JediVCSInit`/`ExitProc`) e os usos de `ToolIntf`/`VCSIntf`/`EditIntf`;
- `AnsiCrLf` → `sLineBreak` (`JediVCSDLL.dpr:1187`, `VerSet.pas:841/851`);
- remover `{$R ...winxp.res}` (linha 523); `cursors.res` já está em `src\jedivcs`;
- `REPORTDLL` desligado; remover ou reescrever o caminho `TVCSReport`;
- ShareMem (linha 213) conforme 0.2;
- `ExceptDlg` (linha 245) fica sob `JCL_DEBUG_DATA` desligado;
- finalização só pelo `JEDIVCSDLLFINALIZE` chamado pelo expert, nada pesado em `DLL_PROCESS_DETACH` (loader lock);
- sem runtime packages; nome de saída fixado.

**5.2 ABI.**
- `src\common\JVCSIDEInterfaceCommon.pas`: manter os records `PAnsiChar` e `{$Z1}`; ABI v2 opcional.
- `src\jedivcs\JVCSIDEInterface.pas`:
  - remover `INTERNAL_OLDOTA`;
  - buffers `array of AnsiChar` com tamanho;
  - `StrPas` sem ambiguidade (com `{$T-}`, o `@buffer` compila em silêncio);
  - corrigir `SourceReadString`.
- `JVCSDLLOperations`/`JVCSDLLFileHistoryImpl`: `PChar` → `PAnsiChar`, `StrPCopy` com tamanho.
- `JVCSDLLLineHistoryFrame`: tirar do `.dpr` (`LINEHISTORYFRAMEEXPORT` nunca definido).

**5.3 `src\common\JVCSIDESettings.pas`.**
- Linha 95: `{$ifdef WINDOWS}` → `MSWINDOWS`.
- BDS 22/23/37 e raiz `Software\Embarcadero\BDS`.
- Aceitar `bin64\bds.exe`; `IsIDEDelphi` para BDS.
- De preferência, receber `RootDir` e a chave base do expert (`IOTAServices`).

**5.4 Units consumidoras.**
- `UsedUnits`: `Library\Win32\Search Path` e `$(BDS)`.
- `ToDo`/`Options`: `delphi32.dci` não existe.
- `VerSet`: `.res` × VerInfo do `.dproj`; o `brcc32` existe.
- `Recent` (`Closed Projects`) e `UsedComponents`.
- `VCSProjAdmin` não modal dentro da IDE: `TAction.OnUpdate`/idle e navegação por teclado. Avaliar um timer de idle ou o uso modal.

**5.5 Expert** (`src\jvcsideexpert`, pasta nova; nomes sugeridos pela família IDE):
- `JVCSIDE_DxWizard.dpr`.
- `JVCSIDEWizard.pas`:
  - `IOTAWizard` (`INITWIZARD0001`);
  - `INTAServices` para menu e ações, `INTAServices280.AddImage` com 16/24/32 px;
  - `IOTAIDENotifier80` → `TIDEFileNotification`;
  - `IOTAKeyboardBinding` + `ioSupportsShortCuts` (sem hook `WH_KEYBOARD`);
  - `IOTAServices` para as configurações.
- `JVCSIDEFileHistoryImpl.pas`: `FileHistoryAPI.IOTAFileHistoryProvider`, chamado na thread principal → `JEDIVCSDLLHISTORYINIT`.
- `JVCSIDEProjectMenuImpl.pas`: `IOTAProjectMenuItemCreatorNotifier` → `JEDIVCSDLLOPERATIONINIT`.
- Compilar com `{$Z1}`.
- `GetProjectName` devolvendo o **mesmo arquivo** que o expert 2.5.0.1030 **[R13]**.
- `JEDIVCSDLLFINALIZE` antes do `FreeLibrary`.
- Um binário por IDE: `JvcsExpertBDS22/23/37.dll` via `{$IF CompilerVersion}` (designide 280/290/370).

**5.6 Setup** (`setup\`, Inno Setup):
- instalar a partir de `bin\client\Win32`: `Jedivcs.exe`, `JEDIVCSDiff.exe`, `jvcs.exe`, a DLL e `locale\`;
- instalar de `3rdparty`: `fvcscrypt.dll`, `jedivcs.chm`, `jedivcsdiff.chm`, os `*.jvcs` e `htm_rep.htm` (conforme `3rdparty\LEIAME.md`);
- gravar `HKCU\Software\Embarcadero\BDS\22.0|23.0|37.0\Experts` com o caminho do `JvcsExpertBDSnn.dll`;
- desinstalar limpando essas chaves;
- nunca distribuir `jedivcsreport.dll`;
- `Experts x64` só na F6.

### Critério de pronto

- [ ] Na IDE de 32 bits do D13.2 (e no D12/D11):
  - menu, ações e atalhos;
  - check-in/check-out a partir da IDE;
  - aba History com revisões e conteúdo;
  - menu do Project Manager.
- [ ] Projeto já cadastrado é reconhecido, com o mesmo ID usado pelo expert antigo **[R13]**.
- [ ] LOGIN da DLL com versão de pelo menos 220 **[R5]**.
- [ ] Fechar a IDE sem deadlock nem AV, com e sem sessão aberta.
- [ ] O instalador registra e desregistra nas três versões.

### Riscos

- **Expert:** o fonte se perdeu e o comportamento tem de ser inferido.
- **ABI ANSI com `{$T-}`:** erros silenciosos.
- **Loader lock** na finalização.
- **VCL da DLL dentro da IDE:** idle, temas e DPI.
- **ShareMem:** histórico de crash.
- **IDE de 64 bits:** não carrega a DLL de 32 bits, e a IDE de 64 bits do 13 não compila nem depura Win32.

---

## F6 — Win64 / ARM64EC (opcional)

**Objetivo.** Gerar binários Win64 (e, se desejado, Win ARM64EC, alvo desde o 13.1) e um expert para a IDE de 64 bits.

**Pré-condição bloqueante:** substituir a `FVCSCrypt.dll` (crítico C6), por um destes caminhos:
- **(a)** reimplementar `fvcs_Encrypt1/2` por caixa-preta, validando que o servidor aceita o login (`fvcs_CryptCompare` da `ServerCrypt.dll`) com a suíte golden;
- **(b)** criar um processo auxiliar de 32 bits que faça só a cifra.

### Tarefas

- Instalar a plataforma Win64 (hoje ausente em `lib\win64\release`).
- Revisar o código para 64 bits:
  - `PIntArray(TList.List)` em `JVCSCompressedDiffUnit`/`JVCSLineHistoryUnit`;
  - casts `Integer(Pointer)`;
  - `FUserData` (já `NativeInt`);
  - `mdMailSlot` com `NativeInt`;
  - `LibHandle: Integer` da JVCL, irrelevante se os plugins continuarem desligados.
- Floats: `Extended = Double` muda os dígitos de `FloatToStrF(ffGeneral,18)`. Rodar a suíte golden em Win64 **[R3]**.
- DLL Win64 + expert registrado em `Experts x64`; JCL/JVCL Win64, se ainda forem usadas.
- Opcionais listados pelo crítico (Fase 10):
  - retirar a JVCL residual;
  - PerMonitorV2;
  - tradução pt_BR (`.po/.mo`);
  - `BRANCHING` (`TCardPanel`);
  - plugin Version Insight (`IOTAVersionControlServices`);
  - provider de anotação ("blame") da `FileHistoryAPI`.

### Critério de pronto

- [ ] Checklist de compatibilidade completo aprovado com os binários Win64.
- [ ] Floats e datas idênticos aos do Win32 na suíte golden.

### Riscos

- **Cifra de login sem fonte:** reimplementação por caixa-preta.
- **Diferenças numéricas** de `Extended` em Win64.
- **Dupla manutenção** de expert 32/64 bits.

---

## Checklist de testes de compatibilidade com o servidor 2.5 Beta 3

Aplicar ao fim da F2 (console), da F3 (Diff), da F4 (EXE) e da F5 (DLL/IDE), e repetir a cada versão. Os itens entre colchetes remetem à seção 4 do inventário.

**Preparação**
- [ ] Servidor 2.5 Beta 3 de **teste**, com cópia do banco de produção; cliente oficial 2.5 Beta 3 numa estação de referência.
- [ ] Captura de tráfego ativa (proxy TCP ou Wireshark) e comparador da suíte golden.
- [ ] Rodadas em Windows com ACP 1252 e com "Beta: UTF-8" (ACP 65001); locale pt-BR e en-US; build Debug (`{$R+,Q+,C+}`).

**Conexão e sessão**
- [ ] Conexão por `localhost`, nome e IP (IPv4) **[R6]**.
- [ ] `GET_SERVER_TIME` idêntico byte a byte; data/hora decodificadas iguais às do cliente antigo **[R2, R3]**.
- [ ] LOGIN aceito:
  - EXE e DLL com a versão do VERSIONINFO (pelo menos 220), Diff e console com 239;
  - senhas com bytes >127 **[R4, R5]**.
- [ ] Senha errada e usuário inexistente geram a mesma mensagem de erro do cliente antigo (`EJVCSClient`); TransactionID/UserID presentes **[R17]**.
- [ ] Nenhuma resposta iniciada por `#$FF` **[R16]**.

**Projetos, módulos e cadastros**
- [ ] `GET_PROJECT_LIST` idêntico; nomes acentuados exibidos corretamente nas duas ACPs **[R1, R2]**.
- [ ] Projeto ou módulo com nome acentuado criado no novo aparece igual no antigo, e vice-versa, sem duplicar **[R1]**.
- [ ] Direitos de usuário (`ProjectRights`) e severidade de bug (`MaintainBugs`) gravados pelo novo conferem no banco e no antigo **[R14]**.
- [ ] Opções do servidor (timeouts, `LoginTO/1440`), DirectSQL (máx. de linhas), Purge e Sync (versão/revisão) enviam as mesmas strings do antigo, em pt-BR e en-US **[R3, R14]**.
- [ ] Browser (`LIST_FILES`), Labels, Milestones, ToDo e Bugs: teste de fumaça contra o servidor.

**Check-in, check-out e sincronização**
- [ ] `CHECKIN_MODULE`:
  - blob ZIP de 1 item, Deflate, nome sem path, data do arquivo;
  - `ORIGCRC` igual ao calculado pelo antigo;
  - `origsize`/`compsize` iguais **[R7, R8, R15]**.
- [ ] Revisão gravada pelo novo → checkout pelo antigo: conteúdo, nome e **data** corretos **[R8]**.
- [ ] Revisões gravadas pelo antigo (amostra ampla, incluindo as mais antigas) → checkout pelo novo **[R8, R9]**.
- [ ] Blobs Blowfish, se existirem: abertos pelo novo, ou opção desativada com mensagem clara **[R10]**.
- [ ] Projeto sincronizado pelo antigo não mostra arquivos "modificados" no novo (dirty-check e Sync por CRC) **[R7]**.
- [ ] Busca de revisões por CRC encontra revisões gravadas pelo antigo **[R7]**.
- [ ] Comentários de check-in e descrições acentuados idênticos no banco **[R1]**.
- [ ] `BlobAsText` de blob com acentos igual ao antigo **[R18]**.

**Line History**
- [ ] Header gravado pelo novo é lido pelo antigo, e vice-versa; primeiro byte `<`, sem BOM **[R11]**.
- [ ] Property "Line History" no mesmo formato que o antigo grava (`PK` ou não) **[R12]**.

**IDE (DLL + expert)**
- [ ] Nome e ID de projeto iguais aos do expert antigo para o mesmo projeto **[R13]**.
- [ ] Operações do Project Manager e aba History devolvem os mesmos dados que o cliente standalone.
- [ ] `UsedUnits`/`ProjDependencies` extraem a mesma lista de units que o antigo, em arquivos ANSI, UTF-8 e UTF-8 com BOM **[R19]**.

**Compatibilidade local (não envolve o servidor)**
- [ ] Notificação por mailslot novo → antigo e antigo → novo (mesma máquina) **[R20]**.
- [ ] Configurações, MRU, "não mostrar novamente" (DSA), senha lembrada e MRU do Diff preservados numa estação que já usava o 2.5 Beta 3 **[R21]**.
- [ ] Backup com senha criado pelo 2.5 Beta 3 restaurado pelo novo.

**Regressão**
- [ ] Suíte golden reexecutada e arquivada a cada fase e a cada mudança em `src\comp\midware` ou `src\common\client`.

---

## Apêndice — Arquivos novos previstos

Os nomes marcados com (s) são sugestões.

| Arquivo | Fase | Função |
|---|---|---|
| `src\jedivcs\Jedivcs.dproj`, `src\jedivcs\JediVCSDLL.dproj`, `src\jedivcsdiff\JEDIVCSDiff.dproj`, `src\jvcs\jvcs.dproj` | F0 | Projetos (defines, search path, saída, sem VerInfo) |
| `tools\compilar.bat`, `tools\LEIAME-compilar.md` (já existem) | F0 | Build por linha de comando; ajustes da 0.4 |
| `src\common\jedi.inc` | F0 | `jedi.inc` fixado |
| `src\comp\mwtools\mwPasLex.pas`, `mwPasLexTypes.pas`, `CastaliaParserDefines.inc` | F0 | Lexer (Castalia renomeado) |
| `src\comp\encryptedzip\*` | F0 | ZipCrypto para o Backup (MIT) |
| `src\comp\dxgettext\gnugettext.pas` | F0 | gettext standalone |
| `tools\golden\*` (s) | F0/F1 | Capturas, testes de ida e volta e comparador |
| `src\common\client\JVCSTransport.pas` | F1 | Interface de transporte + implementação Midware |
| `src\packages\JVCSMidwareD.dpk` (s) | F1/F3 | Registro design-time de `TAppSrvClient`, `TMWBuffer`, `TmdSecureMail` e da lista compatível |
| `src\comp\crc\Checksum.pas` | F2 | CRC compatível |
| `src\common\client\JVCSZipUtils.pas`, `src\common\client\BFCrypt.pas` | F2 | ZIP nativo; Base64/Blowfish |
| `src\common\JVCSTrace.pas`, `JVCSStrUtils.pas`, `JVCSFileUtils.pas` | F2 | Substitutos da JCL |
| Helper de status bar (s) e `TJVCSListView` (s) em `src\common` | F3/F4 | Substitutos DFS |
| `src\jvcsideexpert\JVCSIDE_DxWizard.dpr`, `JVCSIDEWizard.pas`, `JVCSIDEFileHistoryImpl.pas`, `JVCSIDEProjectMenuImpl.pas` | F5 | Expert ToolsAPI |
| `setup\*.iss` (s) | F5 | Instalador e registro das chaves `Experts` |
