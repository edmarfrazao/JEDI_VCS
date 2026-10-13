# De onde veio cada arquivo

Origem: `D:\Delphi\JediVCS\Fontes_JediVCS_2.5` (clone de github.com/Libaud/JediVCS, commit `f6a777d`, 28/12/2017).
A lista completa (destino, origem, MD5, nº de marcas Lazarus, nota) está em **`manifesto-origem.csv`** (separador `;`).

## Por que uma regra de escolha
No clone, cada projeto tinha sua própria cópia das units compartilhadas (`jedivcs`, `jedivcsdll`, `jedivcsdiff`, console),
e várias foram editadas por um port para Lazarus/FPC (F. Libaud). Algumas edições **desligam lógica** — por exemplo:
- `jedivcs\JVCSClientObjBase.pas`: constructor sem `inherited`, `DoExecute` sem TransactionID/UserID, `raise EJVCSClient` comentado → quebra o protocolo;
- `jedivcs\JVCSDialogs.pas`: resultado de `DSAMessageDlg` comentado;
- `jedivcs\VCSProcBase.pas`: `HtmlHelp` e `Printer.GetPrinter` comentados;
- todos os `.dpr` atuais: `LCLIntf/LCLType/LMessages` sem condição e `OpenDocument` (LCL) no lugar de `ShellExecute`.

## Regra aplicada
1. **`.dpr` e `compopt.inc`**: versões originais de `ConverterBackup\` (pré-Lazarus).
2. **Units referenciadas pelos `.dpr` com `..\common\…` / `..\jedivcs\…`**: uma única cópia, no local que o `.dpr` espera;
   entre todas as cópias do clone, vence a com **menos marcas Lazarus** (`Libaud`, `-oFL`, `{$ifdef FPC|LCL|WINDOWS|VCL|BORLAND}`, `LCLIntf`);
   empate → ordem `jedivcsdll` > `jedivcsdiff` > console > `jedivcs`.
3. **`src\jedivcs`**: união de `jedivcsdll` (preferida) com os arquivos **exclusivos** de `jedivcs`.
4. **Diff e console**: só arquivos que não existem em outro lugar; os `jvcsver.rc/.res` próprios de cada um foram mantidos.
5. **Ignorados**: `*.ctpr`, `*.lps` (Lazarus/CodeTyphon), `*.old`, `*.masked`, pastas `ConverterBackup`.
6. **`Components\`** inteiro → `src\comp\_legacy\` (referência). Cópias de trabalho: `src\comp\midware` (ApsCli, RFormat, CBroker, MWDefs.inc),
   `src\comp\textdiff` (diffunit, hashunit), `src\comp\mdmailslot`.

## Pendências conhecidas (arquivos com marcas Lazarus que ainda precisam de revisão manual no port)
- Exclusivos do EXE: `src\jedivcs\OpenProject.pas`, `src\jedivcs\Password.pas`.
- Compartilhadas: `src\common\JVCSIDESettings.pas` (`{$ifdef WINDOWS}` → uses quebrado), `src\jedivcs\VCSProcBase.pas`.
- Componentes: `src\comp\midware\{ApsCli,RFormat,CBroker}.pas` (RFormat com GetBookmark/GotoBookmark esvaziados), `textdiff`, `mdmailslot`.

## Ausentes no clone (precisam ser obtidos ou recriados)
| Unit | Usada por | Destino | Ação |
|---|---|---|---|
| `FastMM4` | `jvcs.dpr`, `Jedivcs.dpr`, `JEDIVCSDiff.dpr` | — | remover (usar o MM embutido) |
| `Checksum` (CRCInt/CRCString) | check-in/out, sync, dirty-check | `src\comp\crc` | **recriar bit a bit compatível** com os CRCs já gravados no servidor |
| `BFCrypt` (Base64/Blowfish) | Create, Options, HandleBlob | `src\common\client` | Base64 nativo; Blowfish só se houver blobs cifrados |
| `mwPasLex`, `mwPasLexTypes` | UsedUnits, ProjDependencies, ToDo, VerSet | `src\comp\mwtools` | CastaliaPasLex (fork do mwPasLex) |
| `Ping`, `Icmp` | Create.pas | — | ICS V9 (`OverbyteIcsPing`) |
| `EnhListView`, `SystemTreeView`, `SystemControlPack`, `SortGrid` (DFS) | ~20 forms | — | TListView / TShellTreeView nativos |
| `HtmlHlp`, `RegAcc`, `RekScan`, `ItemProp` | ajuda, Diff, CompareFolders, LoadModule | — | API nativa (HtmlHelpW, TRegistry, FindFirst, SHOpenWithDialog) |
| `FVCSCrypt.dll` (binário 32 bits) | login | `3rdparty` | extrair do instalador 2.50 Beta 3 |
| expert da IDE (`jvcside_dxwizard`) | carrega a DLL na IDE | `src\jvcsideexpert` (novo) | reescrever com ToolsAPI |
