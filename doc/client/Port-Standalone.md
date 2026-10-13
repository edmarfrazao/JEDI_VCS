# Port do cliente standalone `jedivcs.exe` para Delphi 13.2 (F4, 1ª a 3ª etapas)

Estado em **12/10/2026**. O cliente GUI (`src\jedivcs\Jedivcs.dpr`) compila no Delphi 13.2 Win32
(Debug e Release, 0 erros). Ele foi testado contra o servidor de teste JEDI VCS 2.50
(127.0.0.1:2106, Firebird 2.5) com: login, abrir projeto, listar módulos, checkout, check-in com
comentário acentuado, histórico de revisões e undo checkout.

Esta etapa usa a JVCL 2026.08 do GetIt como **ponte**: os forms ainda têm controles `TJv*`. As DFS,
o FavOpenDialog, o RekScan, o ItemProp, o HtmlHlp, o BFCrypt e o mwPasLex foram trocados por código
nativo ou novo. A troca da JVCL visual (lotes 4.4/4.5) e a auditoria completa de forms ficam para as
próximas etapas. A 2ª etapa (13/10/2026) trouxe as opções de aparência e de IA e o log de erros
(seção 4).
A 3ª etapa (13/10/2026) trouxe a varredura de todos os forms, os testes funcionais dos recursos que
faltavam, correções Unicode, a troca da JVCL visual simples e o tema escuro legível (seção 5).

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
estão. O ExtBugtracker usa `System.RegularExpressions.TRegEx` (13/10, §5.5).

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

## 5. 3ª etapa (13/10/2026): varredura de forms, testes funcionais e tema escuro

### 5.1 Ferramentas de teste (só no build Debug)

`src\jedivcs\JVCSFormSweep.pas`, ligada ao `Jedivcs.dpr` sob `{$IFDEF DEBUG}`:

- **Varredura de forms**: `Jedivcs.exe -formsweep=<pasta> [-sweepscale=175] [-sweepfilter=X] [-sweepnoshow]`.
  Encontra por RTTI todos os forms/frames das units do JEDI VCS (95 classes com DFM), cria, mostra,
  fecha e destrói cada um sem login e grava `<pasta>\formsweep.log`: exceções (EReadError, AV) na
  criação/OnShow/fechamento/destruição com unit e linha (`.map`), **assinatura de cada handler ligado
  pelo DFM comparada com o tipo do evento** (parâmetros, var/out, tipos e convenção pela RTTI), cortes
  de layout na escala pedida (controle fora do pai, rótulo/botão/check com texto maior que a largura,
  rótulo por cima de campo, form maior que a área de trabalho), componentes JVCL por form e os
  diálogos que apareceram (fechados sozinhos com Cancelar/Não). A escala vale só na memória.
- **Automação de teste**: com `JVCS_DEBUG_AUTOMATION=1` no ambiente, um `TTimer` executa comandos de
  `%TEMP%\jvcs-debug-cmd.txt` e responde em `%TEMP%\jvcs-debug-out.txt`: `click`, `set`, `check`,
  `index` (combo/list/listview/radiogroup/pagecontrol), `get`, `dump`, `forms`, `stack` (pilha do
  thread principal), `shot`, `colclick`, `popup`, `gauge`, `stateidx`, `checkitem`. Funciona com
  diálogos modais abertos (o loop modal processa o timer). Sem a variável, nada é criado.

### 5.2 Resultado da varredura

| | 100% | 175% | 200% |
|---|---|---|---|
| EReadError / propriedade inexistente | 0 | 0 | 0 |
| Handlers com assinatura errada | **0** (3 avisos benignos: `TImageIndex`×`Integer` em 2 `OnGetImageIndex` do VTV; `TJvBitmap`×`TBitmap` no plugin manager) | 0 | 0 |
| Cortes de layout (1ª rodada → final) | 16 → 9 | 56 → 18 | 67 → 22 |

Os 10 "erros" restantes são de contexto da varredura (form filho aberto sem o chamador: `ChkInSingle`/
`ChkOutSingle` sem `ModuleKey`, `DeletePH`/`PHFilter`/`ToDoFilter` sem o form pai, `ShowTimeLog` sem
nome, `CompressedDiff` sem arquivo, `GET_BRANCH_LIST`/`GET_LABELS` 403 sem login) e não acontecem no uso
normal. Corrigido pela varredura:

- AV ao sair (`TRefreshDispatcher.RemoveClient` em `nil`: forms destruídos no `DoneApplication`, depois do
  `finalization` de `JVCSInterfaces`).
- 175–200%: muitos forms restauram o tamanho salvo no `OnShow`/`OnActivate` (`jvcsLoadFormPosSize`), em
  pixels de outra escala, depois do mínimo aplicado no `DoCreate` (§4.4). `TJVCSForm` agora aplica o
  mínimo (tamanho do DFM já escalado) também depois do `OnShow` e do `OnActivate`, inclusive a 100%
  (o Synchronize abria com 400×520 e cortava rótulos), encolhe o form que passa da área de trabalho e
  não mexe em forms acoplados (dock). Corrigidos AddLabel, AddUser, AddNewGroup, ToDoEdit,
  MaintainBugs, ProjectHistory, Std_ListView, NtfySend, BackupTreeOptions, Synchronize...
- `Options.dfm`: `PasswordChar = #207` ("Ï" num Delphi Unicode) → `*` nas senhas Blowfish.

Cortes que sobram (pequenos): a 200% numa área de trabalho de 1280×755 (esta VM) o Synchronize e o
Line History não cabem; rótulos de 2–4 px a mais na altura (login `lblOs`, `lblModule` do check-in,
`Purge`); `OpenProject` (rótulo sobre o campo a 175/200%); botões do `JvWizard` (Create Branch, oculto).

### 5.3 JVCL visual → VCL (lotes 4.4/4.5, baixo risco)

Trocados em 36 forms (53 objetos): `TJvMemo` → `TMemo` (18), `TJvComboBox` → `TComboBox` (21), `TJvEdit` →
`TEdit` (6), `TJvSplitter` → `TSplitter` (3), `TJvListBox`/`TJvTextListBox` → `TListBox` (4), `TJvTreeView`
→ `TTreeView` (1). Saíram dos DFMs as propriedades só da JVCL (`AutoSize`/`HideCaret`/`MaxLines`/
`ClipboardCommands`, `ProtectPassword`/`Modified`, `Background.*`, `LineColor`) e dos `uses` as units que
ficaram sem uso. Varredura: nenhum EReadError.

Restam 66 objetos: `TJvSpinEdit` 22 (Options, ServerOptions, Syncronice, ToDoEdit, Purge, DirectSQL e
VerSet da DLL; valores `Extended` no DFM), `TJvWizard`+páginas 8 (Create Branch, oculto), `TJvOfficeColorButton`
5, `TJvGradient` 2 e `TJvColorDialog` 1 (Line History Settings), `TJvLED` 5, `TJvFilenameEdit` 5, `TJvColorComboBox`
4, `TJvArrowButton` 3, `TJvImageComboBox` 2 (ordem dos itens enviada ao servidor, R14), `TJvxSlider`,
`TJvxCheckListBox`, `TJvSearchFiles`, `TJvDriveCombo`, `TJvCheckTreeView`, `TJvNetscapeSplitter`,
`TJvToolBar` e `TJvPluginManager` (1 cada). JVCL não visual: diálogos DSA (`JvDSADialogs`,
`JvDynControlEngineVCL`), `ItemHtDraw` (`JvJCLUtils`), MRU.

### 5.4 Tema escuro (pedido do usuário: textos invisíveis no Project Manager)

Reproduzido com `UITheme = 2` (árvore de projetos só com ícones, lista de módulos com linhas brancas, ícones
da toolbar sumindo). Causas e correções:

- `ProjectTreeDockWnd.VSTHierarchyDrawNode` (VirtualDrawTree) e o custom draw do `TJVCSListView`
  usavam `clWindowText`/`clHighlightText`/`clWindow` crus (preto/branco do sistema). Novas
  `JVCSUITextColor`/`JVCSUIBackColor` (`JVCSUITheme`) convertem pelas cores do estilo ativo e, no escuro,
  clareiam cores escuras demais para o fundo (as cores de "módulo em uso" do usuário, `clNavy`...).
  Também no painel de mensagens e no Module Info.
- Ícones: `JVCSUIAdaptImagesToTheme` (chamada por `JVCSUIApplyThemeToForm`) adapta, no tema escuro, as
  image lists das toolbars, menus e `StateImages`, e os `Glyph` de botões (`TSpeedButton`,
  `TJvArrowButton`...): pixels neutros têm a luminosidade invertida (contorno preto → claro,
  preenchimento branco → escuro), pixels coloridos escuros clareiam. No claro, volta o original
  (cópia guardada). Listas de 32 bits com alfa ficam como estão.
- Conferido por captura de janela: Project Manager (árvore, lista, abas Messages/ToDo/Module History/
  My Locked Modules, toolbar), login, VCS Properties, Check Out; troca em tempo real escuro → claro e o
  tema claro sem regressão.

### 5.5 Testes funcionais (servidor de teste 127.0.0.1:2106, identidade JVCS2026TEST, Exemplo01)

Automação: comandos da §5.1 + `PostMessage` nas caixas de mensagem do Windows. Build Debug.

| Recurso | Resultado | Detalhe |
|---|---|---|
| Ordenação por coluna | OK | nome asc/desc, tamanho numérico; seta no cabeçalho |
| Gauge da status bar | OK | Synchronize: "Working..." com barra e LED; Project Manager não capturado (operações rápidas) |
| Checkout / check-in / undo checkout | OK | 0.9 → 0.10 → 0.11 → 0.12; undo com "restaurar arquivo" pede confirmação quando o local é mais novo (correto) e restaura a revisão |
| Save WIP | OK | 7-Zip com `#y##m##d#`, `#vcsusername#`, `@#vcslistfile#`: `.pas`+`.dfm` do módulo bloqueado; corrigido vazamento de handles do `CreateProcess` |
| Compare all local/archive (Project Manager e My Locked Modules) | **corrigido** | `EInvalidImage: Invalid stream format` (bug Unicode em `IsTextStream`: todo arquivo parecia binário); `%3/%4` iam literais para a ferramenta. Agora abre o JEDIVCSDiff para `.pas` e `.dfm` com legendas "(local)"/"(archive)" |
| Backup sem senha | OK | 5 arquivos; `7z t` OK |
| Backup com senha | **corrigido** | Cancelar no pedido de senha fazia o backup **sem** senha; agora não faz. Senha ASCII e com acento (`Senhaçã1`): 7-Zip abre com a certa e falha com a errada; restauração (diálogo da Abbrevia) para pasta temporária byte a byte igual |
| Blowfish de blobs | OK | chave em Data Encryption → check-in 0.11 cifrado (histórico marca "!Encrypted!"); Get da 0.11 com a chave = enviado; com chave errada "not a PKZip file"; checkout da 0.11 decifra; 0.12 em texto puro. **Fica uma revisão cifrada (0.11 do uPrincipal.pas) no servidor de teste** |
| Line History | **corrigido** | AV no "Show History" (`DiffUnit`: alinhamento com aritmética de `PChar`); agora mostra autoria por linha |
| Compressed Diff | OK | local × última com realce inline (depois da correção do `IsTextStream`) |
| Used Units (lexer novo) | **corrigido** | nomes com ponto (`Winapi.Windows`) viravam duas units; no EXE o caminho de busca começava vazio (tudo "Not found"); filtro `ulist.jvcs` pelo último segmento |
| ToDo (scan) | não testável no EXE | o scan de `TODO` só existe na DLL (`{$IFDEF IDEDLL}`); o lexer foi exercitado pelo Used Units |
| SelectFolder (`TShellTreeView`) | OK | Get de revisão com "Select target folder" e Backup; janela pequena e árvore rola à direita em caminhos longos (cosmético) |
| Synchronize | OK | "pasta nova" (temporária): 4 módulos/5 arquivos; diálogo DSA reentrante com o mesmo nome corrigido (abaixo) |
| Labels | OK | criar label, atribuir à revisão 0.10 (aparece no histórico e na coluna Labels), remover a atribuição e apagar o label |
| Histórico / rollback para pasta temporária | OK | Module Info → Get da 0.8 numa pasta temporária (548 bytes, conteúdo da 0.8); cópia de trabalho intacta |
| ExtBugtracker (`TRegEx`) | OK | `(?i)MANTIS +#*(?<bug>[\d]+)` → "Open Bug \"4242\"" na 0.10; sem grupo nomeado (`MANTIS #(\d+)`) idem; regex inválida → item oculto, sem exceção |

Outras correções vindas dos testes:

- **DSA reentrante pelo nome**: a correção de 13/10 (§4.3) dava um ID por contador (não seguro fora de
  ordem) e o mesmo nome reentrante (`SyncRes` com o primeiro aberto; OK no VCS Properties com um DSA
  aberto) levantava `EJvDSADialog: DSA dialog named ... is already assigned to another dialog ID`. Agora:
  primeiro ID realmente livre e reutilização do registro existente pelo nome.
- `IsBinaryDFMStream` (mesmo defeito do `IsTextStream`) e `HashUnit` (CRC só do byte baixo de cada
  caractere).
- `Get` com chave Blowfish errada deixa `_vcsblob.ulock` na pasta de destino (não corrigido).

### 5.6 Item: "o EXE não fechou no primeiro WM_CLOSE"

Reproduzido duas vezes e analisado (pilhas com `cdb -pv` + `.map` e o comando `stack`): o processo **não
estava preso no fechamento**. O app estava **minimizado** antes do `WM_CLOSE`: com
`MainFormOnTaskBar = False` (como no 2.5.0.1030), minimizar esconde a janela principal e deixa só a janela
do `TApplication` (iconizada); o `Application.Run` seguia ocioso (`WaitMessage`). Os scripts procuravam a
janela principal **visível** e não mandavam o `WM_CLOSE`; um `WM_CLOSE` na janela principal oculta fecha
na hora (testado). Quem minimizou não foi identificado (não houve `SC_MINIMIZE` do próprio JEDI VCS
nos testes seguintes; a automação agora registra `Application.OnMinimize` com a pilha). Possíveis:
"Mostrar área de trabalho"/minimizar tudo por outro processo. Sugestão (não aplicada):
`Application.MainFormOnTaskBar := True` no `Jedivcs.dpr`, que é o padrão desde o Delphi 2007 e mantém a
janela principal como a janela da barra de tarefas.

### 5.7 Builds e DLL

- `exe`/`dll`/`diff`/`console` Debug e Release Win32: 0 erros (exe 313/312 avisos, dll 328/327).
- `tools\compilar-expert.bat Release nova`: `bin\ideclient\Win32` atualizado com a DLL Release nova.
- `src\jvcsideexpert\tests\testar-dll.bat ambas`: nova e original 21 ok, 0 falhas, 0 AV.
- Ambiente: em 13/10 a pasta Documentos passou para o OneDrive (`...\OneDrive - sesistemas.com.br\Documentos`);
  o `compilar.bat` procura o CatalogRepository em `%USERPROFILE%\Documents` e não acha a JCL/JVCL/ICS
  (`jedi.inc` não encontrado). Contorno usado: `JVCS_CATALOG` apontando para a pasta do OneDrive.
  O Exemplo01 está registrado no servidor com o caminho antigo (`C:\Users\...\Documents\...\Ex1`);
  para os testes foi usada uma junção temporária para a cópia no OneDrive (removida no fim).
- `bin\client\Win32` não recebia os `*.jvcs` (lista de filtros do Used Units etc.); copiados de
  `3rdparty` para os testes. O `compilar.bat exe` deveria copiar como o `compilar-expert.bat` faz.

## 6. Pendências

- **JVCL visual** restante: 66 objetos (§5.3), `TJvSpinEdit` o maior grupo; `JvPluginManager` no DFM do
  ProjAdmin. JCL ainda usada (`JclDebug`, `JclFileUtils`, `JclStrings`, `JclSecurity`). ~~`JclPCRE` no
  ExtBugtracker~~ (13/10: `TRegEx`).
- ~~Auditoria de forms~~ (13/10, §5.2: 95 forms/frames, 0 EReadError, 0 assinatura errada). Faltam os
  forms só da DLL (`VerSet`, `UsedComponents`, `Recent`) na varredura e a varredura no tema escuro.
- ~~Testes não feitos~~ (13/10, §5.5). Faltam: scan de ToDo (só na DLL, testar na IDE), gauge do Project
  Manager por captura, restauração de backups antigos (Abbrevia 3.05/ZipMaster) com senha.
- Cortes pequenos a 175–200% (§5.2) e Synchronize/Line History maiores que a área de trabalho em telas
  pequenas a 200%; `SelectFolder` pequeno para caminhos longos.
- `Get` com chave Blowfish errada deixa `_vcsblob.ulock` na pasta de destino.
- "Não fecha no primeiro WM_CLOSE" (§5.6): app minimizado por agente externo não identificado; avaliar
  `Application.MainFormOnTaskBar := True`.
- `compilar.bat`: achar o CatalogRepository na pasta Documentos real (OneDrive/KFM) e copiar `*.jvcs` para
  `bin\client\Win32` (§5.7).
- **mdMailSlot** não portado (só compila); `SMTPSend` intacto.
- ~~Opções de fonte/tema/aba IA~~ (seção 4); ~~ícones da toolbar no tema escuro~~ (§5.4). Faltam:
  esquema escuro dos highlighters do SynEdit, `ImageList` escalada pelo DPI, `DiffAbout` voltar a herdar
  de `JVCSBaseAboutDialog`, e os demais valores do `[ai]` (prefixo, identidade, `asciiAs`) na página
  AI / Automation.
- Builds em D11/D12.
- Exceção no lugar da cifragem LZH: se algum servidor exigir `EncryptServerData`, a conexão falha
  com mensagem explícita.
