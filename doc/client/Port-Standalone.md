# Port do cliente standalone `jedivcs.exe` para Delphi 13.2 (F4, 1ª e 2ª etapas)

Estado em **12/10/2026**. O cliente GUI (`src\jedivcs\Jedivcs.dpr`) compila no Delphi 13.2 Win32
(Debug e Release, 0 erros). Ele foi testado contra o servidor de teste JEDI VCS 2.50
(127.0.0.1:2106, Firebird 2.5) com: login, abrir projeto, listar módulos, checkout, check-in com
comentário acentuado, histórico de revisões e undo checkout.

Esta etapa usa a JVCL 2026.08 do GetIt como **ponte**: os forms ainda têm controles `TJv*`. As DFS,
o FavOpenDialog, o RekScan, o ItemProp, o HtmlHlp, o BFCrypt e o mwPasLex foram trocados por código
nativo ou novo. A troca da JVCL visual (lotes 4.4/4.5) e a auditoria completa de forms ficam para as
próximas etapas. A 2ª etapa (13/10/2026) trouxe as opções de aparência e de IA e o log de erros
(seção 4).

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

## 4. Aparência e IA (F4, 2ª etapa, 13/10/2026)

### 4.1 O que entrou

| Arquivo | Mudança |
|---|---|
| `src\common\JVCSForms.pas` | `TJVCSForm.DoCreate` (antes do `OnCreate`, que restaura posição/tamanho salvos) aplica fonte/escala (`JVCSUIApplyToForm`), fonte dos popup menus e dos SynEdit (reconhecidos pelo nome da classe) e o tema, quando `JVCSFormsApplyAppearance = True`. Com a fonte padrão o form fica como no DFM. Forms que não herdam de `TJVCSForm` (mensagens, diálogos da JVCL) são tratados por `Screen.OnActiveFormChange` (encadeado). A aplicação é idempotente |
| 19 forms + `JVCSCompressedDiffDialog` | `class(TForm)` → `class(TJVCSForm)` (ProjAdmin, check-in/out, dock forms, Recent, VerSet, UsedUnits...) |
| `src\jedivcs\JVCSClientAppearance.pas` (nova) | liga `JVCSUIScale`/`JVCSUITheme` na `ConfigStorage` (`sBaseRegistryKey + crbOptions`), `JVCSUIInitialize`, tema; no EXE `JVCSUIStartFollowingSystem` (troca do tema do Windows em tempo real) |
| `Jedivcs.dpr` | `JVCSErrorLogInstall(False)` e `JVCSClientAppearanceInit` logo depois do `Application.Initialize` |
| `Options.pas/.dfm`, `VCSBase.pas` | páginas **Appearance** (`cspAppearance = 19`) e **AI / Automation** (`cspAI = 20`), no fim da lista (os índices antigos não mudam) |
| `src\common\client\JVCSAIConfig.pas` (nova) | lê/grava `%APPDATA%\JEDI\JVCS\config.ini` `[ai] checkout=/checkin=` exatamente como `Read-JaIniSection`/`Set-JaConfigValue` do `tools\ai\lib\jvcs-ai-common.ps1`: UTF-8 com BOM, CRLF, troca só a linha da chave, preserva o resto; arquivo novo com o cabeçalho do wrapper; valor inválido = `confirm` |
| `src\common\client\JVCSErrorLog.pas` (nova) | log de erros (ver 4.3) |
| `JVCSDialogs.pas` | diálogos DSA reentrantes (ver 4.3) |
| `JVCSBaseAboutDialog.pas/.dfm` | `TJvRichEdit` → `TRichEdit` (`EnableURLs`/`OnLinkClick`); versão lida com `GetFileVersionInfo` (sem `JclFileUtils`) |

**Appearance**: escala (100–200%, ou digitada 80–250), fonte da interface, dos menus e dos editores
(TFontDialog, botões *Font...* e *Default*), tema *Follow Windows* (na DLL: *Follow Delphi*) | *Light* |
*Dark*, *Restore defaults*. Grava `UIFontScale`, `UIFontName`, `UIFontSize`, `MenuFontName/Size`,
`EditorFontName/Size` e `UITheme` (Port-Diff.md §4.1) só se algo mudou, e reaplica em todas as janelas
abertas (`JVCSClientAppearanceApplyAll`). No EXE o tema escuro é o VCL Style global "Windows Modern
Dark" (embutido); o claro é o estilo nativo.

**AI / Automation**: *Check out by AI* e *Check in by AI* = Manual | Ask for confirmation | Automatic
(`manual`/`confirm`/`auto`), texto curto de cada modo e o caminho do `config.ini`. Só grava a chave que
mudou. Os demais valores do `[ai]` (`commentPrefix`, `identity`, `asciiAs`, `jvcsExe`, timeouts) continuam
só pelo `jvcs-ai.ps1 config set`.

`JVCS_NOBRANCHUI` (branch oculta) foi conferido: continua no `exe` e no `dll` do `compilar.bat`.

### 4.2 Testes (13/10/2026)

| Passo | Resultado |
|---|---|
| Build `exe`/`dll`/`diff`/`console` Debug e Release Win32 | 0 erros (avisos: exe 313/312, dll 328/327, diff 0, console 248) |
| Options → Appearance e AI / Automation (captura da janela) | páginas aparecem; IA mostra `Automatic/Automatic` (config.ini desta máquina) |
| Gravar 150% + Dark + IA confirm/confirm, OK | registro `UIFontScale=150`, `UITheme=2`; config.ini só com `checkout=confirm`/`checkin=confirm` trocados (324 → 330 bytes, BOM e CRLF mantidos); a janela principal foi recriada no tema escuro |
| `jvcs-ai.ps1 config list -Text` | `checkout = confirm [config.ini]`, `checkin = confirm [config.ini]` |
| Reabrir o EXE | login e Options em escuro, fonte 150% (Segoe UI 14 pt), página Appearance com 150% e Dark |
| Restauração | `HKCU\Software\JEDI\JEDIVCS` reimportado do backup (export idêntico) e `config.ini` copiado de volta (auto/auto, hash igual) |

### 4.3 Controle de erros

- `JVCSErrorLog`: `%LOCALAPPDATA%\JEDI\JVCS\logs\jvcs-<exe|dll>-AAAAMMDD.log` (UTF-8). Cada linha: data/hora,
  processo, módulo e versão, contexto, classe e mensagem, endereço (módulo+offset) e unit/rotina/linha
  quando o `.map` está ao lado do módulo (JclDebug, sem hook de exceções). Instalado por
  `Application.OnException` (encadeado; no EXE a mensagem continua a mesma) e `ExceptProc`. Nunca grava
  senha (só a mensagem da exceção).
- `JVCSDialogs.DSAIdentsMessageDlg/GetState/SetState`: antes todos usavam o ID DSA 0 e o texto de marca
  `ctkOwnDSAMsg`; um segundo diálogo aberto por um `TTimer` enquanto o primeiro estava aberto levantava
  `EJvDSADialog: CheckMarkText ID 99 already registered` (reproduzido no host interativo da DLL, com o
  `LoginTimer`). Agora cada uso pega um ID livre e o texto tem contador de referências.

`Options` crashou uma vez (`0EEDFADE`) ao abrir por teclado numa sessão em que o login tinha sido feito
automaticamente; não reproduziu nas execuções seguintes (com o log ligado). Ver 4.4 (causas prováveis
corrigidas).

### 4.4 Correções de 13/10/2026 (lentidão, crash, senha, layout, menu)

| Bug | Causa | Correção | Evidência |
|---|---|---|---|
| **Lentidão ao abrir projeto** (~21–24 s com 4 módulos na DLL dentro da IDE; uma vez 22 s no EXE), entre `Local: (File size & attributes)` e `Server request: (Modules without revision …)` | `ProjAdmin.GetFileImageIndex`/`GetCorrectedImageIndex` copiava **todos** os ícones da lista de imagens do sistema, do índice 0 até o índice do arquivo (posição = índice do sistema + 1). A lista do sistema é do processo e é preenchida sob demanda: cada `GetIcon` obriga o shell a extrair ícones que o projeto nem usa. Dentro do `bds.exe` (que já pediu centenas/milhares de ícones) o custo explode | só o ícone usado é copiado, uma vez; `FSysIconMap` guarda índice do sistema → posição no `ModuleImageList` | log de DEBUG com o tempo de cada etapa do laço (`FillListView laco local: …` em `%LOCALAPPDATA%\JEDI\JVCS\logs`). Host interativo com 306 ícones pré-carregados (`-primeicons 600`): **209 ms → 49 ms** (ícones 192 ms/151 cópias → 30 ms/4 cópias). EXE: **188 ms → 44 ms**. DLL Release no host: `Local … /0,06 s` → `Modules without revision … /0,16 s`. As demais etapas (SHGetFileInfo do tipo, labels, tamanho, atributos, plugin, gauge, ProcessMessages) somam < 15 ms |
| **Crash ao abrir Options** (não reproduzido do mesmo jeito) | reproduzido um crash parecido: valor de aparência com outro tipo no registro (`UIFontScale` REG_SZ, como gravaria outra versão ou a mão) → `ERegistryException: Failed to get data for 'UIFontScale'` não tratada → 0EEDFADE. Candidato ao caso original: a janela `AllocateHWnd` que segue o tema do Windows não tinha `try/except`; o `WM_SETTINGCHANGE` chega por `SendMessage` de outro processo e uma exceção na troca do VCL Style (recria todas as janelas, inclusive o Options modal) atravessava o user32 sem passar pelo `Application.OnException` | leitura tolerante (`JVCSClientAppearance`: tipo esperado → outro tipo → padrão); `JVCSClientAppearanceInit` em `try/except` com log no EXE e na DLL; troca de tema adiada com `PostMessage` e exceções para `Application.HandleException` (log); `Options` carrega/grava aparência e IA em `try/except` (log; o diálogo abre com os padrões); `ProjAdmin.ShowVCSOptions` com `try/except` e `bStopRefresh` restaurado; `config.ini` lido com `fmShareDenyNone` | com `UIFontScale`=REG_SZ "150", `UITheme`=REG_SZ "abc" e `UIFontName`=DWORD o EXE abre, aplica 150% e o Options abre (antes: crash na partida) |
| **Senha apagada** ao conectar/trocar de identidade | `btnOpenClick` chama `UpdateIdentity` em todo Connect; com "Store Password with identity" desmarcado ele gravava a senha **vazia** na identidade selecionada. O checkbox era o padrão global `SavePassword` (= 0 nesta máquina), não o estado da identidade (a DEFAULT tem senha salva pelo `jvcs-ai.ps1`) | o checkbox mostra se a identidade selecionada tem senha salva (sem senha: padrão global); marcado = grava a senha digitada (vazia só se o usuário apagou a senha); desmarcado **por clique** = apaga; desmarcado sem clique = não mexe; `SavePassword` só é gravado se o usuário clicou | reproduzido antes da correção (o primeiro Connect com `JVCS2026TEST` apagou a senha). Depois: Connect direto, troca TEST2→TEST→TEST2→TEST + Connect e Connect com TEST2 (sem senha) mantêm a senha de TEST; desmarcar + Connect apaga só a de TEST; DEFAULT intacta |
| **Rótulos cortados a 150%** | o `OnCreate` dos forms restaura o tamanho salvo em pixels de outra escala (o VCS Properties ficava 430×335 com conteúdo a 150%); rótulos `AutoSize = False` com altura para Tahoma 8; caminho do `config.ini` sem espaços não quebra | `TJVCSForm.DoCreate`: forms redimensionáveis (menos a principal) ficam no mínimo com o tamanho do DFM já escalado (limitado à área de trabalho); Appearance: rótulos de fonte com 18 px e reticências; AI: caminho em linha própria com reticências no meio (`epPathEllipsis`, completo no hint); User Interface: combos de cor afastados dos rótulos | capturas a 150% das páginas User Interface, Common Options, Appearance e AI / Automation sem cortes |
| **Atalho para a fonte** | requisito do monitor 32" QHD | item **View → Appearance / Font Si&ze...** (`mmiAppearance`) abre o VCS Properties direto na página Appearance (também no Project Manager da DLL) | `Alt+V Z` abre a página Appearance |

Host interativo: novos parâmetros `-project <arquivo.dpr>` (projeto "aberto" na Fake IDE, devolvido pela
callback `GetProjectName`) e `-primeicons <n>` (pede ícones de `System32\*.exe` ao shell antes de carregar a
DLL, como a IDE já aberta).

## 5. Pendências

- **JVCL visual** ainda presente (47 DFMs): lotes 4.4/4.5 do plano; `JvPluginManager` ainda no DFM do
  ProjAdmin. JCL ainda usada (`JclDebug`, `JclFileUtils`, `JclStrings`, `JclSecurity`, `JclPCRE` no
  ExtBugtracker → `TRegEx`).
- **Auditoria de forms**: abrir todos os forms em Debug procurando `EReadError` e handlers ligados
  pelo DFM com assinatura errada (JVCL 2026 × 3.x). Feito só para VTV e a lista DFS.
- **Testes não feitos**: Syncronice, Backup/restore (senha), Blowfish de blobs, Line History,
  Compressed Diff, UsedUnits/ToDo com o lexer novo, SelectFolder com `TShellTreeView`, ordenação por
  coluna e setas, gauge da status bar, ExtBugtracker, Save WIP, Compare all.
- **mdMailSlot** não portado (só compila); `SMTPSend` intacto.
- ~~Opções de fonte/tema/aba IA~~: feitas (seção 4); ~~View → Font size~~ e o VCS Properties a 150%
  feitos (4.4). Faltam: ícones da toolbar para o tema escuro, esquema escuro dos highlighters do
  SynEdit, `ImageList` escalada pelo DPI, revisão de layout a 175–200% nos demais forms (conferidos só
  Project Manager, login e VCS Properties), `DiffAbout` voltar a herdar de `JVCSBaseAboutDialog`, e os
  demais valores do `[ai]` (prefixo, identidade, `asciiAs`) na página AI / Automation.
- `.dproj` do EXE (F0) e builds em D11/D12.
- Exceção no lugar da cifragem LZH: se algum servidor exigir `EncryptServerData`, a conexão falha
  com mensagem explícita.
