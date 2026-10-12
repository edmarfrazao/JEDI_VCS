# Status do port

Situação por fase do [Plano-de-Port.md](Plano-de-Port.md) (F0 a F6), com o que já foi feito e os próximos passos. Estado em **12/10/2026**. Decisões: [Decisoes.md](Decisoes.md). Ambiente: [Ambiente.md](Ambiente.md).

## Resumo

| Fase | Objetivo | Situação |
|---|---|---|
| F0 | Ambiente, dependências, build e linha de base | **Em andamento** (cerca de metade: ambiente e dependências do D13 prontos; faltam `.dproj`, D11/D12, cópias locais e linha de base golden) |
| F1 | Midware portado, `JVCSTransport.pas`, teste golden | Não iniciada |
| F2 | Núcleo do cliente e console `jvcs.exe` | Não iniciada |
| F3 | Infraestrutura comum de GUI e `JEDIVCSDiff.exe` | Não iniciada |
| F4 | EXE standalone `Jedivcs.exe` | Não iniciada |
| F5 | DLL da IDE, novo expert ToolsAPI e setup | **Trilha 5A (expert) em andamento**; DLL e setup não iniciados |
| F6 | Win64 / ARM64EC (opcional) | Não iniciada; bloqueada pela `fvcscrypt.dll` |

Nenhum dos 4 projetos do cliente (`exe`, `dll`, `diff`, `console`) compila ainda; `bin\client\Win32` está vazio. Só o expert (`JvcsExpertBDS37.dll`) e as bibliotecas fixadas (SynEdit, VTV) compilam.

## Erros atuais do `tools\compilar.bat all`

Fonte: logs em `tools\logs\compilar_<chave>_Win32_Debug.log`, gerados em 12/10/2026 às 16:41 (Debug Win32, Delphi 13.2, `dcc32 37.0`). Não foram reexecutados nesta consolidação. O compilador para no primeiro erro fatal, então cada projeto ainda esconde erros seguintes.

| Projeto | Erro | Causa e correção |
|---|---|---|
| `exe` (`Jedivcs.dpr`) | `F2613 Unit 'FastMM4' not found` | Os `.dpr` originais usam `FastMM4` e `src\comp\fastmm` não existe no layout novo. Remover a unit do `uses` e usar o gerenciador de memória embutido (`ReportMemoryLeaksOnShutdown` sob `DEBUG`). Previsto em F4 (4.1) |
| `diff` (`JEDIVCSDiff.dpr`) | `F2613 Unit 'FastMM4' not found` | Idem. Previsto em F3 (3.7) |
| `console` (`jvcs.dpr`) | `F1026 File not found: '..\comp\fastmm\FastMM4.pas'` | Idem (aqui a unit vem com caminho explícito). Previsto em F2 (2.7) |
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

- [ ] `MWDefs.inc` com `OverbyteIcsDefs.inc` do ICS V9
- [ ] `RFormat.pas` (`PAnsiChar`, code page fixa configurável, `AppendFields` com `vtUnicodeString`, `vtWideChar`, `vtInt64`, `vtExtended`; `MoveEscaped`/`AppendStreamField`; bookmarks)
- [ ] `ApsCli.pas` (`WSocket` → `OverbyteIcsWSocket`, `TIcsWndControl`, `SocketFamily := sfIPv4`)
- [ ] `CBroker.pas` (`FUserData: NativeInt`)
- [ ] `src\common\client\JVCSTransport.pas` (interface `IJVCSTransport` + `TJVCSMidwareTransport` + fábrica)
- [ ] Pacote design-time `src\packages\JVCSMidwareD.dpk` (`TAppSrvClient`, `TMWBuffer`)
- [ ] Suíte golden: ida e volta do `RFormat`, roteiro contra o servidor de teste, comparador que ignora hora, TransactionID e senha cifrada; rodar em ACP 1252 e 65001, pt-BR e en-US

**Depende de:** F0 (servidor de teste e capturas). Estado: apenas as cópias do Midware V3 em `src\comp\midware` (não compilam no D13).

## F2: Núcleo do cliente e console

- [ ] `Checksum.pas` recriada e validada contra `BLOBS.ORIGCRC` (bloqueante se divergir)
- [ ] `JVCSZipUtils.pas` sobre `System.Zip` (ZIP de 1 item, nome sem path, data do arquivo, `IsZipBlob`)
- [ ] `BFCrypt.pas` (Base64 nativo; Blowfish conforme a varredura)
- [ ] `JVCSClientObjBase.pas`, `JVCSClientObj.pas`, `JVCSConnect.pas`, `JVCSClientDispatcher.pas`, `JVCSClientFunctions.pas`, `JVCSCrypt.pas`, `VCSCommon.pas`
- [ ] Helpers `JVCSTrace`, `JVCSStrUtils`, `JVCSFileUtils` em `src\common`
- [ ] `jvcs.dpr` sem `FastMM4`, sem JCL/JVCL
- [ ] Critério: login, lista de projetos, sync por CRC, check-in/checkout cruzado com o cliente 2.5 Beta 3

## F3: GUI comum e JEDIVCSDiff (piloto)

- [ ] Recursos: `jvcsver.rc` (2.5.0.2026 / "2.5 Beta 2026" / pré-lançamento), `STRINGS.RC`, `CURSORS.RC`; remover `winxp.res`
- [ ] Units base (`JVCSForms`, `ConfigStorage`, `VCSBase`, `JclDebug` → `JVCSTrace`)
- [ ] Substitutos nativos da JVCL não visual (`JVCSDialogs`, `JVCSMruList`, `JVCSThreads`, `JVCSLanguage` + `gnugettext`)
- [ ] `VCSProcBase.pas` (`HtmlHelpW`, `TOpenDialog`/`TSaveDialog`, `FormatSettings`)
- [ ] Helpers visuais (status bar, About, `ListView`)
- [ ] `DBModule` sem LZH/CipherLz; `#$FF` vira erro
- [ ] `JEDIVCSDiff.exe` sem `Jv*` nem `dfs*`

## F4: EXE standalone

- [ ] Lote 4.1 esqueleto e login (`Create`, `ProjAdmin`, `mdmailslot`, `TJVCSListView`)
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
- [ ] **Teste manual na IDE de 32 bits em andamento pelo usuário** (menu JEDI VCS, conexão, check-in/out, History)
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
