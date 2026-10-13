# Port do cliente standalone `jedivcs.exe` para Delphi 13.2 (F4, 1ª etapa)

Estado em **12/10/2026**. O cliente GUI (`src\jedivcs\Jedivcs.dpr`) compila no Delphi 13.2 Win32
(Debug e Release, 0 erros). Ele foi testado contra o servidor de teste JEDI VCS 2.50
(127.0.0.1:2106, Firebird 2.5) com: login, abrir projeto, listar módulos, checkout, check-in com
comentário acentuado, histórico de revisões e undo checkout.

Esta etapa usa a JVCL 2026.08 do GetIt como **ponte**: os forms ainda têm controles `TJv*`. As DFS,
o FavOpenDialog, o RekScan, o ItemProp, o HtmlHlp, o BFCrypt e o mwPasLex foram trocados por código
nativo ou novo. A troca da JVCL visual (lotes 4.4/4.5), a auditoria completa de forms e as opções
de fonte/tema/IA ficam para as próximas etapas.

Referências: [Plano-de-Port.md](../common/Plano-de-Port.md) (F4 e adendo),
[Decisoes.md](../common/Decisoes.md), [Port-Console.md](Port-Console.md),
[Algoritmos-Recuperados.md](Algoritmos-Recuperados.md) (§2 BFCrypt, §3.5 LOGIN).

## 1. Como compilar

```
tools\compilar.bat exe Debug Win32
tools\compilar.bat exe Release Win32
```

- Saída: `bin\client\Win32\Jedivcs.exe` (+ `.map`/`.drc`). Log: `tools\logs\compilar_exe_Win32_<cfg>.log`.
- A `fvcscrypt.dll` é copiada para `bin\client\Win32` (necessária para o LOGIN).
- Resultado atual: 0 erros, ~313 avisos (Debug) e ~312 (Release), em sua maioria `W1057`/`W1058`
  (`string` ↔ `ShortString` dos registros do núcleo) e `W1000` (símbolos obsoletos).
- **DCUs agora vão para `dcu\<plat>\<cfg>\<alvo>`** (antes `dcu\<plat>\<cfg>`). As units
  compartilhadas (`src\jedivcs`, `src\common`) mudam com os defines de cada alvo, e dois builds em
  paralelo (exe e diff, por exemplo) não se atropelam mais.
- Recursos (gerar com `brcc32` na pasta `src\jedivcs`):
  - `brcc32 -fojvcsver.res jvcsver.rc`: FileVersion 2.5.0.2026, PRODUCTVERSION 2,5,0,2026,
    ProductVersion "2.5 Beta 2026", `FILEFLAGS VS_FF_PRERELEASE`;
  - `brcc32 -fojedivcsmanifest.res jedivcsmanifest.rc`: manifest `jedivcs.manifest` (comctl32 v6,
    asInvoker, Windows 7–11, **DPI unaware + gdiScaling**), no lugar do `winxp.res` com caminho
    absoluto do ambiente antigo.

### Defines do alvo `exe`

`DEBUG`/`RELEASE` (pela configuração), `USECLIENTDISPATCHER`, `BRANCHING`, `JVCS_NOBRANCHUI`,
`UNISYNEDIT` e `OVERBYTEV6_UP` (comum).

| Define | Situação | Efeito |
|---|---|---|
| `LANGUAGE` | **desligado** (saiu do `.dof`) | sem tradução (gettext) |
| `REPORTDLL` | **desligado** (saiu do `compopt.inc`) | o `compopt.inc` liga `JVCS_NOREPORTS`: sem `jedivcsreport.dll`, sem unit `Report`, item "Print reports" oculto |
| `JVCS_PLUGINS` | não definido | `TJvPluginManager` continua no DFM, mas `LoadPlugins` não é chamado e o menu **Plug-ins** fica oculto |
| `JVCS_NOTIFY` | não definido | notificação entre estações (mailslot) e SMTP desligadas: `jvcsReadBool` devolve sempre `False` para `NotifyActive`, `SMTPMessages` e `ProjMan_NotifyActive`; `GlobalSettingValue(16)` = `False`; menu **Notify** oculto. Os valores gravados no registro não mudam |
| `BRANCHING` | **ligado** | protocolo igual ao do 2.5.0.1030 contra o servidor 2.50 (`ServerBranchID`/`sBranchName = 'HEAD'`), como no console |
| `JVCS_NOBRANCHUI` | **ligado** | decisão do usuário: menu **Branch** oculto e itens desabilitados; a GUI fica no HEAD (o título mostra `[Branch: HEAD]`), sem troca de branch |
| `UNISYNEDIT` | ligado | API do SynEdit Unicode (pyscripter) nos frames de Line History e Compressed Diff |
| `DEBUG`/`RELEASE` | pela linha de comando | o `compopt.inc` não força mais `{$DEFINE DEBUG}`/`{$DEFINE RELEASE}`; `MEMCHECK`/`IMAGEBASE` removidos |

Recursos de 2012 mantidos (ExtBugtracker, Save WIP, Compare all local/archive): compilam como
estão. O ExtBugtracker ainda usa a JclPCRE do GetIt (troca por `TRegEx` pendente).

## 2. O que mudou

### 2.1 Substitutos novos (sem código de terceiros)

| Arquivo | Substitui | Observações |
|---|---|---|
| `src\common\JVCSListView.pas` (`TJVCSListView`) | `TdfsEnhListView` 3.72 (18 listas em 15 forms) | `TListView` + `AutoColumnSort`, `AutoSortAscending`, `ShowSortArrows` (`HDF_SORTUP/DOWN`), `NoColumnResize`, `Style = lvOwnerDrawFixed`, `Resort`, `AutoResort`, `BeginUpdate/EndUpdate`, `CurrentSortAscending`, `LastColumnClicked`. Os eventos `OnSortItems` (`TSortAs`), `OnDrawItem`, `OnDrawSubItem` e `OnDrawHeader` mantêm a **assinatura da DFS** (escondem os do `TListView`), então os 9 handlers dos forms não mudaram. O desenho usa o custom draw da VCL (os handlers só mudam fonte/cor). DFMs e `.pas`: `TdfsEnhListView` → `TJVCSListView`, unit `EnhListView` → `JVCSListView` |
| `src\jedivcs\JVCSStatusBar.pas` (`TJVCSStatusBar`) | `TdfsStatusBar` 1.24 (`ProjAdmin`, `Syncronice`) | `TStatusBar` com painéis `TJVCSStatusPanel` (`Enabled`, `AutoFit`, `Hint`, `OnClick`, `OnDrawPanel`, `PanelType`, `GaugeAttrs`); gauge = `TProgressBar` sobre o painel (`pbstMarquee` no modo indeterminado); hint e clique por painel |
| `src\common\FavOpenDialog.pas` | `FavOpenDialog` 0.2 (Markus Stephany) | reimplementação: `TFavOpenDialog = class(TOpenDialog)` e `TFavSaveDialog` (executa um `TSaveDialog`); a lista de favoritos vira pasta inicial/MRU |
| `src\jedivcs\JVCSFolderTree.pas` (`TJVCSFolderTreeView`) | `TdfsSystemTreeView` (`SelectFolder`) | `TShellTreeView` com `Selection`, `RootFolder`, `AddNewNode`, `Reset`, `PopupMenuMethod` |
| `src\common\JVCSFileSearch.pas` | `RekScan.FindRecursive` | arquivos da pasta primeiro, depois subpastas; `Path` com barra final; callback `False` interrompe |
| `src\common\client\BFCrypt.pas` + `BFCryptTables.inc` | `BFCrypt` (CryptoLib) | código de Algoritmos-Recuperados §2.5: Base64 sobre bytes ANSI (senha da identidade) e Blowfish ECB/zeros. `ChkInSingle`/`HandleBlob` passam a chave como `TBytes` (`Base64DecodeBytes` do registro `EncodeKey`). **Blowfish não testado** (o servidor de teste não tem blobs cifrados) |
| `src\comp\mwtools\mwPasLex.pas` + `mwPasLexTypes.pas` | mwPasLex 2.2 | lexer mínimo novo (não é o Castalia, cujo download depende de autorização): tokens `ptUnit/ptUses/ptProgram/ptLibrary/ptIn/ptExport(s)/ptExternal/ptIdentifier/ptSemiColon/ptComma/ptIncludeDirect/ptResourceDirect`, comentários e diretivas como token inteiro, `NextNoJunk`, `LineNumber` base 0. Os chamadores (`UsedUnits`, `ProjDependencies`, `ToDo`, `VerSet`) acrescentam o terminador `#0` ao stream (R19) |
| `src\common\client\JVCSSynEditUtils.pas` | `Gutter.Width` do SynEdit antigo | `SetCustomGutterBandWidth`: oculta as bandas padrão e usa uma banda `gbkCustom` com a largura pedida |

### 2.2 Ajustes no código existente

| Arquivo | Mudança |
|---|---|
| `Jedivcs.dpr` | sem `FastMM4`; `JvDynControlEngineVCL` no `uses` (sem ele os diálogos DSA da JVCL dão "DefaultDynControlEngine not defined"); `winxp.res` → `jedivcsmanifest.res` |
| `compopt.inc` | sem `DEBUG`/`RELEASE`/`REPORTDLL`/`MEMCHECK`/`IMAGEBASE` fixos; `JVCS_NOREPORTS` quando não há `REPORTDLL` |
| `VCSProcBase.pas` | `GetJVCSAppProductVersionInt` lê o PRODUCTVERSION **numérico** (2,5,0,2026 → 2·100+5·10+0 = **250**, igual ao 2.5.0.1030); `HtmlHelpW` declarado localmente (`delayed`, sai `HtmlHlp`); `FormatSettings.DecimalSeparator`; `GlobalSettingValue(16)` sob `JVCS_NOTIFY` |
| `ConfigStorage.pas` | filtro de notificação em `jvcsReadBool` (ver tabela de defines) |
| `DBModule.pas` | LZH/CipherLz removidos; resposta iniciada por `#$FF` e `EncryptServerData` viram exceção explícita |
| `ProjAdmin.pas` | `JVCS_NOREPORTS`, `JVCS_PLUGINS`, `JVCS_NOBRANCHUI`, menus Plug-ins/Notify ocultos, include `JEDIVCSPluginMsgConst.inc` local, `FormatSettings.ThousandSeparator`, status bar nativa |
| `Std_ListView.pas`, `Syncronice.pas` | `FormatSettings`; status bar nativa |
| `History.pas` | `SortGrid` fora do `uses` |
| `LoadModule.pas` | `ItemProp.PerformDefaultAction` → `ShellExecute(..., 'openas', ...)` local |
| `SelectFolder.pas`, `CompareFolders.pas` | `JVCSFolderTree`/`JVCSFileSearch` |
| `ChkInSingle.pas`, `HandleBlob.pas` | chave Blowfish em bytes |
| `UsedUnits`, `ProjDependencies`, `ToDo`, `VerSet` | terminador `#0` antes do `Origin` do lexer |
| VTV V8.5 (`JVCSBrowserFrame`, `JVCSBranchTreeViewFrame`, `JVCSProjectTreeUnit`, `ProjectTreeDockWnd`, `JVCSLineHistoryFrame`, `JVCSLineHistorySettingsDialog`) | `VirtualTrees.Types` (e `VirtualTrees.DrawTree` no `ProjectTreeDockWnd`) no `uses`; **`OnGetText` com `var CellText: string`** (era `WideString`; assinatura ligada pelo DFM, o compilador não confere); `OnHeaderClick` com `TVTHeaderHitInfo`. Conferi todos os eventos VTV ligados nos DFMs contra o V8.5 |
| `JVCSLineHistoryFrame`, `JVCSCompressedDiffFrame` | `Gutter.Width` → `GutterWidth`/banda `gbkCustom` |
| `JVCSCompressedDiffSynProxy` | `GetTokenLength`, `GetLanguageName`/`GetFriendlyLanguageName`; sem `GetExpandedToken*`; `LineNumber` em base 1 na pintura (`Find(LineNumber - 1)`) |
| `src\comp\mdmailslot\mdmailslot.pas` | só para compilar: `{$IFDEF VER200}` → `{$IFDEF UNICODE}` (pula `CharToOEM`/`OemToChar`). **Não é um port**: com a notificação desligada o código não roda |
| `tools\compilar.bat` | defines do `exe`; DCUs por alvo |

## 3. Testes (12/10/2026)

Automação: PowerShell + UI Automation (`BM_CLICK`/`WM_SETTEXT` nos controles com handle) +
`SendKeys` só com a janela do cliente em primeiro plano (atalhos `Alt+P O`, `Ctrl+Shift+O/I/G`,
`Alt+M U`) + captura de tela. Os scripts ficaram no scratchpad da sessão (não versionados).

| Passo | Resultado |
|---|---|
| Abrir (Debug) | abre, mostra o login com a identidade salva DEFAULT |
| Conectar | **LOGIN aceito** (Archive Admin). Captura pelo proxy (`tools\golden\console\proxy.ps1`, build Release): `LOGIN … sysdba|<senha cifrada>|250|<GetNowUTC>` → **versão 250**, igual ao GUI 2.5.0.1030 |
| Abrir `exemplo01.dpr` | 4 módulos listados com versão, estado, tamanho local e datas |
| Checkout `uPrincipal.pas` (0.8) | lock de `sysdba` (conferido no console novo: `listlocks all_users`); arquivos `.pas`/`.dfm` graváveis e iguais à 0.8 |
| Alteração | comentário final do `uPrincipal.pas` trocado por texto com `ação, revisão, ç, ã, é` (cp1252, CRLF) |
| Check-in com comentário `teste GUI portado F4 - ação, revisão (ç, ã, é)` | **versão 0.9**, lock liberado, arquivos somente leitura. Console: `listproject` mostra 0.9 com Stamp/CRC vazios (local = servidor); `getmodule 4` traz `uPrincipal.pas` (MD5 `084fec9e…`) e `.dfm` **byte a byte iguais** ao enviado |
| Histórico (`Ctrl+Shift+G`) | a revisão 0.9 mostra o comentário com os acentos corretos |
| Checkout + **Undo checkout** (build com a correção da JVCL) | mensagens DSA corretas; arquivo restaurado (somente leitura, igual à 0.9); sem locks |
| VCS Properties | abre |
| Menus | Branch, Plug-ins e Notify ocultos; título `JEDI VCS (2.5.0.2026) >> DEFAULT >> [Branch: HEAD] >> exemplo01.dpr` |
| Release | compila, conecta (LOGIN 250) |
| Console | `tools\compilar.bat console Debug|Release Win32` continua 0 erros (248 avisos); `listprojects`/`listproject`/`listlocks`/`getmodule` funcionam |

**Estado final:** sem locks; cópia local de `uPrincipal.pas`/`.dfm` = revisão 0.9 (somente leitura).
No servidor de teste o módulo 4 foi de 0.8 para **0.9** (check-in pelo GUI novo).

**Registro do usuário:** um teste de captura trocou Host/Port no diálogo de login, e o **Connect
grava Host/Port na identidade selecionada** (comportamento original do `Create.pas`). A identidade
DEFAULT foi restaurada do backup (`reg export` antes do teste) e o diff de
`HKCU\Software\JEDI\JEDIVCS` contra o backup ficou vazio (só restam `UITheme`/`UIFontScale`,
gravados pelo port do Diff). `tools\ai\jvcs-ai.ps1 identity -Text` e `locks -All -Text` funcionam.
**Regra para os próximos testes:** usar uma identidade de teste separada (ex.: `JVCS2026TEST`) e
apagar só ela no fim; nunca editar Host/Port com a DEFAULT selecionada.

Observações:
- A primeira montagem da lista de módulos levou 22 s numa execução do build Debug com manifest
  DPI-aware; nas seguintes (e com o manifest atual) leva 0,2 s. Não reapareceu.
- Com o manifest DPI-aware o `ProjAdmin` (`Scaled = False`) ficava minúsculo em 200%; o manifest
  atual é DPI unaware + gdiScaling (como o 2.5.0.1030, mas com texto nítido). A escala própria
  (`UIFontScale`) entra junto com as opções de fonte/tema.
- O GUI grava `ProgramVersion = 2.5.0.2026` na chave compartilhada com o cliente 2.5.0.1030.

## 4. Pendências

- **JVCL visual** ainda presente (47 DFMs): lotes 4.4/4.5 do plano; `JvPluginManager` ainda no DFM do
  ProjAdmin. JCL ainda usada (`JclDebug`, `JclFileUtils`, `JclStrings`, `JclSecurity`, `JclPCRE` no
  ExtBugtracker → `TRegEx`).
- **Auditoria de forms**: abrir todos os forms em Debug procurando `EReadError` e handlers ligados
  pelo DFM com assinatura errada (JVCL 2026 × 3.x). Feito só para VTV e a lista DFS.
- **Testes não feitos**: Syncronice, Backup/restore (senha), Blowfish de blobs, Line History,
  Compressed Diff, UsedUnits/ToDo com o lexer novo, SelectFolder com `TShellTreeView`, ordenação por
  coluna e setas, gauge da status bar, ExtBugtracker, Save WIP, Compare all.
- **mdMailSlot** não portado (só compila); `SMTPSend` intacto.
- **Opções de fonte/tema/aba IA** (dependem de `JVCSUIScale`/`JVCSUITheme` da F3): próxima etapa.
- `.dproj` do EXE (F0) e builds em D11/D12.
- Exceção no lugar da cifragem LZH: se algum servidor exigir `EncryptServerData`, a conexão falha
  com mensagem explícita.
