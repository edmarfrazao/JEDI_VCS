# Status do port

Situação por fase do [Plano-de-Port.md](Plano-de-Port.md) (F0 a F6), com o que já foi feito e os próximos passos. Estado em **12/10/2026**. Decisões: [Decisoes.md](Decisoes.md). Ambiente: [Ambiente.md](Ambiente.md).

## Resumo

| Fase | Objetivo | Situação |
|---|---|---|
| F0 | Ambiente, dependências, build e linha de base | **Em andamento** (cerca de metade: ambiente e dependências do D13 prontos; faltam `.dproj`, D11/D12, cópias locais e linha de base golden) |
| F1 | Midware portado, `JVCSTransport.pas`, teste golden | **Em andamento**: Midware portado (Unicode, cp1252, ICS 9) e golden de fio do console idêntico ao original; faltam `JVCSTransport.pas`, pacote design-time e suíte golden automatizada (ACP 65001, en-US) |
| F2 | Núcleo do cliente e console `jvcs.exe` | **Console pronto e validado** (Win32 Debug/Release, golden idêntico ao 2.5.0.1030, ver [Port-Console.md](../client/Port-Console.md)); faltam os helpers nativos (sem JCL/Abbrevia), `BFCrypt.pas` e testes de sync/arquivo vazio/binário |
| F3 | Infraestrutura comum de GUI e `JEDIVCSDiff.exe` | **Diff pronto** (Win32 Debug/Release, sem JVCL/JCL/DFS, testes por linha de comando iguais ao original) e **infraestrutura de aparência** (`JVCSUIScale`, `JVCSUITheme`); ver [Port-Diff.md](../client/Port-Diff.md) |
| F4 | EXE standalone `Jedivcs.exe` | **1ª etapa pronta**: compila (Win32 Debug/Release, 0 erros, JVCL como ponte) e passou no teste básico contra o servidor de teste (login 250, projeto, checkout/check-in acentuado, undo checkout); ver [Port-Standalone.md](../client/Port-Standalone.md) |
| F5 | DLL da IDE, novo expert ToolsAPI e setup | **Trilha 5A (expert) em andamento**; DLL e setup não iniciados |
| F6 | Win64 / ARM64EC (opcional) | Não iniciada; bloqueada pela `fvcscrypt.dll` |

**Console:** `tools\compilar.bat console Debug|Release Win32` gera `bin\client\Win32\jvcs.exe`, validado contra o servidor de teste (12/10/2026). **EXE standalone:** `tools\compilar.bat exe Debug|Release Win32` gera `bin\client\Win32\Jedivcs.exe` (1ª etapa da F4, ver [Port-Standalone.md](../client/Port-Standalone.md)). A `dll` ainda não compila. Só o expert (`JvcsExpertBDS37.dll`) e as bibliotecas fixadas (SynEdit, VTV) compilam.

## Erros atuais do `tools\compilar.bat all`

Fonte: logs em `tools\logs\compilar_<chave>_Win32_Debug.log`, gerados em 12/10/2026 às 16:41 (Debug Win32, Delphi 13.2, `dcc32 37.0`). Não foram reexecutados nesta consolidação. O compilador para no primeiro erro fatal, então cada projeto ainda esconde erros seguintes.

| Projeto | Erro | Causa e correção |
|---|---|---|
| `exe` (`Jedivcs.dpr`) | ~~`F2613 Unit 'FastMM4' not found`~~ **Resolvido** (F4, compila: ver Port-Standalone.md) | Os `.dpr` originais usam `FastMM4` e `src\comp\fastmm` não existe no layout novo. Remover a unit do `uses` e usar o gerenciador de memória embutido (`ReportMemoryLeaksOnShutdown` sob `DEBUG`). Previsto em F4 (4.1) |
| `diff` (`JEDIVCSDiff.dpr`) | ~~`F2613 Unit 'FastMM4' not found`~~ | **Resolvido** (F3: compila, ver [Port-Diff.md](../client/Port-Diff.md)) |
| `console` (`jvcs.dpr`) | ~~`F1026 File not found: '..\comp\fastmm\FastMM4.pas'`~~ | **Resolvido** (FastMM4 removido; compila e passa no golden, ver [Port-Console.md](../client/Port-Console.md)) |
| `dll` (`JediVCSDLL.dpr`) | `E2029 Identifier expected but ',' found` em `src\common\JVCSIDESettings.pas(99)`, seguido de `E2003` (`DelphiHKEY`, `RegKeyExists`, `RegGetKeyNames`, `RegReadString`), `E2012` e `F2063 Could not compile used unit 'JVCSIDESettings.pas'` (chamada em `JVCSIDEInterface.pas(2378)`) | `JVCSIDESettings.pas` usa `{$ifdef WINDOWS}`, símbolo que o Delphi 13 não define (só `MSWINDOWS`). Correção definitiva no fonte: trocar por `MSWINDOWS` (F5 5.3, na linha 95 conforme o plano). Contorno só no script, sem editar o fonte: `set JVCS_EXTRA_DEFS=WINDOWS` |

Pendências que aparecerão a seguir (units ainda sem fonte nem DCU, com os defines atuais), conforme [tools\LEIAME-compilar.md](../../tools/LEIAME-compilar.md): `EnhListView`, `dfsStatusBar`, `FavOpenDialog`, `Checksum`, `BFCrypt`, `CipherLz`, `SortGrid`, `SystemTreeView`, `SystemControlPack`, `RekScan`, `HtmlHlp`, `mwPasLex`, `mwPasLexTypes`, `ItemProp`, `RegAcc`, `SynHighlighterMPerl` e `WSocket` (em `ApsCli.pas`); mais o `{$R ...winxp.res}` com caminho absoluto do ambiente antigo nos `.dpr`. Destino de cada uma: [Componentes.md](Componentes.md), seção 3.

Verificações que passam (últimos logs): `libs Debug Win32`, `libs Release Win32` e a compilação automática dos pacotes runtime Win64 (`exe Debug Win64`) compilam SynEdit e VTV sem erro. `tools\compilar-expert.bat` gera `JvcsExpertBDS37.dll` e confere exports/imports do PE.

---

## F0: Ambiente, dependências, build e linha de base

- [x] Estrutura `v2026` e fontes base (cópia de menor edição Lazarus; `.dpr`/`compopt.inc` de `ConverterBackup`) — commit `3cb5f17`
- [x] Inventário de componentes (9 famílias, 201 units, 21 riscos) e Plano de Port — `62f9c8f`
- [x] Delphi 13.2 Professional instalado e verificado (`37.0.60952.8797`)
- [x] JCL 2026.08, JVCL 2026.08, ICS 9.7 e Abbrevia 2026.10 instalados via GetIt
- [x] SynEdit (pyscripter `84391a3`) e Virtual-TreeView V8.5 fixados em `src\comp` e instalados na IDE a partir de `lib\bpl\Win32`; SynEdit TurboPack e VTV 8.3 do GetIt removidos da IDE; backup em `C:\Users\Public\Documents\Embarcadero\Studio\37.0\_backup_getit_20261012`
- [x] `tools\compilar.bat` (modo `dcc32`, alvo `libs`, ramo `msbuild` previsto) e `tools\LEIAME-compilar.md`
- [x] Binários de referência 2.5.0.1030 e runtime em `3rdparty` (`fvcscrypt.dll`, CHM, `*.jvcs`, `htm_rep.htm`, `referencia-2.5.0.1030`)
- [x] Análise estática do expert original (`doc\client\Expert-IDE-Analise.md`), incluindo o valor de registro `JVCSIDEClient`
- [x] Decisões registradas: escopo, IDE alvo, SynEdit/VTV, dependências, recursos desligados (relatórios, tradução, notificação, plugins, branching), LZH, Midware, teste de protocolo, plataforma, nome da versão, Git
- [ ] Decisões da seção 0.2 ainda abertas: code page do fio (provável 1252), Blowfish de blobs, ShareMem na DLL, nome da DLL (sugestão `JvcsExternalDll.dll`), origem de JCL/JVCL no D11/D12
- [ ] Delphi 11 (BDS 22) e Delphi 12 (BDS 23) instalados, com as mesmas dependências (JCL/JVCL do GitHub num commit equivalente ao 2026.08, ICS 9.7, SynEdit e VTV fixados, Abbrevia)
- [ ] Os 4 `.dproj` (`Jedivcs`, `JediVCSDLL`, `JEDIVCSDiff`, `jvcs`) com defines, unit scope names, search path, saída, manifest e sem VerInfo; exercitar o ramo `msbuild` do `compilar.bat`; alinhar defines do script com a tabela da 0.3 (`DelphiPersonalEdition` no EXE)
- [ ] Cópias locais: `src\comp\mwtools\mwPasLex*.pas` e `CastaliaParserDefines.inc` (renomeados), `src\comp\encryptedzip`, `src\comp\dxgettext\gnugettext.pas`, `src\common\jedi.inc`
- [ ] Servidor 2.5 Beta 3 de teste montado pelo usuário (cópia do banco)
- [ ] Capturas golden (`GET_SERVER_TIME`, `LOGIN`, `GET_PROJECT_LIST`, `CHECKIN_MODULE`, `GET_CHECKOUT_MODULE`, textos acentuados, erro) arquivadas em `tools\golden\captures\` (proposta)
- [ ] Consultas somente leitura no banco (CRC, método/flags ZIP, blobs Blowfish, Line History, `lc_ctype`, tamanho do header)
- [ ] Limpar o `EnvOptions.proj`, que ainda cita `VirtualTreeview_by_JamSoftware-13\8.3\source` no Library Path (risco de duas versões do VTV)
- [ ] Commitar o estado atual: `doc/common/Decisoes.md` (modificado), `src/jvcsideexpert/`, `tools/compilar-expert.bat`, `bin/ideclient/` (tem `.gitignore` próprio) e a documentação consolidada em `doc\`

**Próximos passos:** (1) criar os `.dproj`; (2) remover `FastMM4` dos `.dpr` e trocar `WINDOWS` por `MSWINDOWS` para o build chegar a erros de código do cliente; (3) obter as cópias locais; (4) com o servidor de teste, capturar a linha de base golden e rodar as consultas 0.7; (5) instalar Delphi 11/12.

---

## F1: Midware portado e teste golden

- [x] `MWDefs.inc` com `OverbyteIcsDefs.inc` do ICS V9 (sem `USE_SSL`)
- [x] `RFormat.pas` (`PAnsiChar`, code page fixa configurável `MWCodePage` = 1252, `AppendFields` com `vtUnicodeString`/`vtWideString`/`vtWideChar`/`vtPWideChar`/`vtInt64`, `vtExtended` com `FloatToStrF(ffGeneral,18)`; bookmarks restaurados)
- [x] `ApsCli.pas` (`OverbyteIcsWSocket`, `SocketFamily := sfIPv4`, cabeçalho `AnsiString`, `AllocateHWnd` do `System.Classes`; sem migrar para `TIcsWndControl`)
- [x] `CBroker.pas` (`FUserData: NativeInt`)
- [x] Golden de fio do console (proxy de captura + normalizador em `tools\golden\console`): `GET_SERVER_TIME`, `LOGIN` (versão 239), `GET_PROJECT_INFORMATION`, `GET_LOCKED_MODULES`, `GET_CHECKOUT_MODULE` (blobs), `CHECKOUT_ONLY_MODULE`, `CHECKIN_MODULE` (blobs, comentário acentuado em cp1252) idênticos ao original — evidências em `doc\client\golden-console`
- [ ] `src\common\client\JVCSTransport.pas` (interface `IJVCSTransport` + `TJVCSMidwareTransport` + fábrica)
- [ ] Pacote design-time `src\packages\JVCSMidwareD.dpk` (`TAppSrvClient`, `TMWBuffer`)
- [ ] Suíte golden: ida e volta do `RFormat`, roteiro contra o servidor de teste, comparador que ignora hora, TransactionID e senha cifrada; rodar em ACP 1252 e 65001, pt-BR e en-US

**Estado:** Midware em `src\comp\midware` compila no D13 Win32 (Debug com `$R+ $Q+` e Release) e é usado pelo console validado.

## F2: Núcleo do cliente e console

- [x] **Console `jvcs.exe` compilando (Win32 Debug/Release) e validado**: `listprojects`, `listproject`, `listlocks`, `getmodule` (inclusive `rev=`), `checkout`/`checkin` com comentário acentuado; saída e fio idênticos ao 2.5.0.1030; leitura cruzada (o original lê as revisões gravadas pelo novo e vice-versa). Detalhes: [Port-Console.md](../client/Port-Console.md)
- [x] `Checksum.pas` recriada; validada contra o CRC gravado pelo original (`ORIGCRC` do `.dfm` igual nos dois consoles), contra o CRC do ZIP e os vetores de teste (`123456789` → `$CBF43926`, arquivo vazio → `'OK'`, 100 000 bytes = CRC do ZIP). Falta a varredura ampla do banco (0.7)
- [x] Blob ZIP do check-in com a data do arquivo (correção para o Abbrevia 2026 em `TJVCSAbZipper`)
- [x] `jvcs.dpr` sem `FastMM4`; `CRCInt` no check-in; versão `2.5 Beta 2026` no recurso; LOGIN continua 239
- [ ] `JVCSZipUtils.pas` sobre `System.Zip` (ZIP de 1 item, nome sem path, data do arquivo, `IsZipBlob`)
- [ ] `BFCrypt.pas` (Base64 nativo; Blowfish conforme a varredura)
- [ ] `JVCSClientObjBase.pas`, `JVCSClientObj.pas`, `JVCSConnect.pas`, `JVCSClientDispatcher.pas`, `JVCSClientFunctions.pas`, `JVCSCrypt.pas`, `VCSCommon.pas`
- [ ] Helpers `JVCSTrace`, `JVCSStrUtils`, `JVCSFileUtils` em `src\common`
- [ ] `jvcs.dpr` sem JCL (ainda usa `JclFileUtils`, `JclStrings`, `JclDebug` do GetIt) e sem Abbrevia; sem JVCL já está
- [ ] Confirmar com o usuário: `BRANCHING` ligado no console (necessário para saída idêntica ao original)
- [ ] Critério: login, lista de projetos, sync por CRC, check-in/checkout cruzado com o cliente 2.5 Beta 3

## F3: GUI comum e JEDIVCSDiff (piloto)

- [x] **`JEDIVCSDiff.exe` compilando (12/10/2026)**: `tools\compilar.bat diff Debug|Release Win32` com 0 erros e 0 avisos; sem `Jv*`, `Jcl*`, `dfs*`, FastMM4 e sem as units do EXE (`..\jedivcs` fora do search path; `LANGUAGE` desligado até o `gnugettext`). Recurso 2.5.0.2026 / "2.5 Beta 2026" / pré-lançamento + manifesto. Detalhes: [Port-Diff.md](../client/Port-Diff.md)
- [x] Diff (3.7): status bar nativa com gauge, MRU nativo no **mesmo formato** do `TJvMruList` (lido/gravado também pelo original), `TSpinEdit`/`TColorBox`, `TSynEditMark.Create(Editor)`, `Gutter.Bands` no DFM, `TSynHighlighterAttributes.Create(Name, FriendlyName)`, `RegAcc`/`FavSaveDialog`/`TVCSListView` → locais, `HtmlHelpW`, About próprio, leitura/gravação com detecção de codificação (ANSI/UTF-8/UTF-16)
- [x] Teste por linha de comando (`/s: /t: /autostart` + novos `/log:` e `/close` com exit code): pares ANSI cp1252 e UTF-8 com acentos dão o mesmo resultado do original; ANSI × UTF-8 com BOM do mesmo texto = iguais (o original acusava diferença). Todos os forms abrem sem `EReadError` (harness), tema claro/escuro e 150% conferidos por captura de tela
- [x] Infraestrutura de aparência: `src\common\client\JVCSUIScale.pas` (fonte/tamanho/escala da interface, menus owner-draw, fonte dos editores; chaves `UIFontScale`, `UIFontName`, `UIFontSize`, `MenuFontName`, `MenuFontSize`, `EditorFontName`, `EditorFontSize`) e `JVCSUITheme.pas` (`UITheme` 0 seguir host/1 claro/2 escuro; VCL Style "Windows Modern Dark" embutido; Windows via `AppsUseLightTheme` + `WM_SETTINGCHANGE`; IDE via `JVCSUISetHostTheme`). Aplicadas no Diff (grupo "User interface" em Editor Properties)
- [ ] Teste interativo de gravação UTF-8, relatórios e ajuda; build D11/D12; chamada do Diff pelo EXE (comparar com revisão do servidor)
- [ ] Desejado em units compartilhadas: `TJVCSForm` aplicar `JVCSUIApplyToForm`; `JVCSBaseAboutDialog` sem `TJvRichEdit`; `JVCSLanguage` com `gnugettext` (ver Port-Diff.md, seção 5)
- [ ] Recursos do EXE (`STRINGS.RC`, `CURSORS.RC`), units base (`ConfigStorage`, `VCSBase`, `JclDebug` → `JVCSTrace`), substitutos da JVCL não visual (`JVCSDialogs`, `JVCSMruList`, `JVCSThreads`), `VCSProcBase`, `DBModule`: seguem com o port do EXE (F4)

## F4: EXE standalone

- [x] **1ª etapa (12/10/2026)**: `tools\compilar.bat exe Debug|Release Win32` com 0 erros → `bin\client\Win32\Jedivcs.exe` (2.5.0.2026, "2.5 Beta 2026", pré-lançamento; LOGIN 250). Sem FastMM4, `REPORTDLL`, `LANGUAGE`, plugins e notificação; `BRANCHING` + `JVCS_NOBRANCHUI` (menu Branch oculto, HEAD fixo). Substitutos novos: `TJVCSListView` (EnhListView), `TJVCSStatusBar` (dfsStatusBar), `FavOpenDialog`, `TJVCSFolderTree` (SystemTreeView), `JVCSFileSearch` (RekScan), `BFCrypt`, `mwPasLex` mínimo; VTV V8.5 e SynEdit pyscripter ajustados. Teste contra o servidor: login, abrir `exemplo01.dpr`, checkout/check-in de `uPrincipal.pas` com comentário acentuado (0.8 → **0.9**, arquivo baixado pelo console igual ao enviado), histórico, undo checkout, sem locks. Detalhes e pendências: [Port-Standalone.md](../client/Port-Standalone.md)
- [ ] Lote 4.1 esqueleto e login (`Create`, `ProjAdmin`, `mdmailslot`, `TJVCSListView`) — compila e funciona; faltam `mdmailslot` (só compila), `TJvToolBar`/`TJvEdit` → nativos, `ThemeMgr`/`JclSecurity`
- [ ] Lote 4.2 operações com o servidor (`ChkInSingle`, `ChkOutSingle`, `Syncronice`, `Backup`, etc.)
- [ ] Lote 4.3 History, Line History, Compressed Diff (VT V8, SynEdit, `textdiff`, `mwPasLex`)
- [ ] Lote 4.4 forms de manutenção (JVCL visual → nativo)
- [ ] Lote 4.5 restante (`SelectFolder`, `CompareFolders`, `LoadModule`, `SMTPSend`)
- [ ] 4.6 sem units `Jv*`/`dfs*` no fecho do EXE

## F5: DLL da IDE, expert e setup

Trilha 5A (expert), em paralelo desde a F0, carregando a `JvcsExternalDll.dll` **original** 2.5.0.1030:

- [x] Fonte do expert em `src\jvcsideexpert` (`JvcsExpertBDS.dpr`, ABI, bridge, callbacks, notifiers, History, menu do Project Manager, wizard) e `LEIAME.md`
- [x] `tools\compilar-expert.bat` e saída em `bin\ideclient\Win32` (`JvcsExpertBDS37.dll` 2.5.0.2026, runtime copiado: `JvcsExternalDll.dll`, `fvcscrypt.dll`, `zipdll.dll`, `unzdll.dll`, CHM, `*.jvcs`)
- [x] Teste de fumaça fora da IDE com uma `JvcsExternalDll` falsa (`src\jvcsideexpert\tests`)
- [x] Revisão (ABI e IDE) e correções do expert aplicadas: 89 verificações fora da IDE, 0 falhas; build 0 avisos (commit `b18ce6c`)
- [x] Expert registrado em `HKCU\Software\Embarcadero\BDS\37.0\Experts` → `JVCSIDEClient` (12/10/2026 18:00; backup `Experts_antes_jvcs.reg`)
- [x] **Expert carregado na IDE de 32 bits do Delphi 13.2** (12/10/2026): splash "JEDI Version Control System 2.5 Beta 2026" e menu **JEDI VCS** com todos os verbos da JvcsExternalDll original e atalhos Ctrl+Shift+P/I/O/G/B. Configuração aplicada pelo usuário via `setup\Delphi13-JVCS-v2026.reg`.
- [ ] Teste funcional: Connect Server, Project Manager, check-in/out, History, menu do Project Manager
- [ ] Teste manual na IDE de 32 bits (idealmente com `bds.exe -rJVCSTeste`): menu, ações, atalhos, check-in/check-out, aba History, menu do Project Manager, fechamento sem deadlock, DPI
- [ ] `GetProjectName` igual ao do expert antigo (risco R13)
- [ ] Builds do expert para BDS 22/23 (`JvcsExpertBDS22/23.dll`), depois que as IDEs estiverem instaladas

DLL e setup:

- [ ] `JediVCSDLL.dproj` com `IDEDLL;EXT_IDE_INTF`; ramo VCSManager removido; ShareMem conforme decisão
- [ ] ABI `PAnsiChar` mantida; `JVCSIDESettings.pas` com `MSWINDOWS`, BDS 22/23/37
- [ ] Setup Inno em `setup\` (instala de `bin\client\Win32` e `3rdparty`, grava `Experts\JVCSIDEClient` por BDS)

## F6: Win64 / ARM64EC (opcional)

- [ ] Substituir ou isolar a `fvcscrypt.dll` (pré-condição bloqueante)
- [ ] Instalar a plataforma Win64 no Delphi (ausente hoje)
- [ ] Revisão para 64 bits (`PIntArray`, `Integer(Pointer)`, `mdMailSlot`)
- [ ] Floats (`Extended` = `Double` em Win64) na suíte golden
- [ ] DLL Win64 e expert em `Experts x64`

---

## Pendências transversais

- Servidor 2.5 Beta 3 (Firebird) **não portado**: o usuário vai montar um servidor de teste.
- Licença do Midware (uso não comercial): decisão adiada; transporte isolado em `JVCSTransport.pas`.
- Consultar [Componentes.md](Componentes.md) para o que cada unit ausente vira.
- Reconciliar a skill `D:\skills\delphi`, que cita Delphi 11 e 12 como instalados: hoje só existe o 13.2.

## Testes de integração com o servidor de teste (12/10/2026)
- [x] Servidor 2.50 (branching, HEAD) + Firebird 2.5.9; banco atualizado para a versão 250 (ver `doc\server\Servidor-Teste-Local.md`).
- [x] **Check-in pela IDE do Delphi 13.2** com o expert BDS37 + JvcsExternalDll original: projeto `Exemplo01` (4 módulos, `.pas`+`.dfm` pela família).
- [x] Standalone `jedivcs.exe` 2.5.0.1030 conectado ao mesmo tempo que a IDE.
- [x] **Duas sessões do mesmo usuário (IDE + CLI) convivem** neste servidor (build com branching): a IDE continuou conectada.
- [x] **CLI `jvcs.exe` original:** `listprojects`, `listproject`, `listlocks`, `checkout 4` (sem prompt: arquivo limpo → `CHECKOUT_ONLY_MODULE`), alteração, `checkin 4 "comentário"` → versão **0.1 → 0.2**, lock liberado, arquivos voltam a somente leitura.
- [ ] Próximo: wrapper `tools\ai\jvcs-ai.ps1` (ADR-001 §3, camada de curto prazo) para a IA usar a CLI com segurança (identidade salva, JSON, mutex, checagem de alteração local antes de bloquear).
