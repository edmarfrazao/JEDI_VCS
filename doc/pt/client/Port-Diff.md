# Port do JEDIVCSDiff para Delphi 13.2 (F3)

Estado em **12/10/2026**. O `JEDIVCSDiff.exe` (`src\jedivcsdiff\JEDIVCSDiff.dpr`) compila no Delphi 13.2
Win32 (Debug e Release) com 0 erros e 0 avisos, sem JVCL, JCL, DFS, FastMM4 nem units do EXE.
Os testes de comparação por linha de comando dão o mesmo resultado do original 2.5.0.1030 nos
arquivos ANSI e UTF-8 testados. A fase também cria a infraestrutura comum de aparência:
`JVCSUIScale.pas` (fonte, tamanho e escala) e `JVCSUITheme.pas` (tema claro/escuro com VCL Styles).

Referências: [Plano-de-Port.md](../common/Plano-de-Port.md) (F3, item 3.7),
[Requisito-Tamanho-Fonte.md](Requisito-Tamanho-Fonte.md), [Port-Console.md](Port-Console.md),
[tools\LEIAME-compilar.md](../../../tools/LEIAME-compilar.md).

## 1. Como compilar

```
tools\compilar.bat diff Debug Win32
tools\compilar.bat diff Release Win32
```

- Saída: `bin\client\Win32\JEDIVCSDiff.exe` (+ `.map`/`.drc` em Debug). Log:
  `tools\logs\compilar_diff_Win32_<cfg>.log`.
- Defines do Diff: `DEBUG`/`RELEASE`, `DelphiPersonalEdition` e `OVERBYTEV6_UP` (comum).
  - **`LANGUAGE` foi tirado** do alvo `diff`: o código sob `LANGUAGE` usa `JvGnugettext` (JVCL) e
    `JVCSLanguage`, e o `gnugettext` (dxgettext) ainda não foi portado. A instalação 2.5.0.1030 não traz
    traduções do Diff (`locale` não existe), então nada se perde hoje.
  - **`..\jedivcs` saiu do search path** do Diff: ele não usa mais `ListView`, `VCSBase`,
    `ConfigStorage`, `JVCSGUIClientResources`, `FavOpenDialog`, `RegAcc` nem `ItemProp`.
- Units linkadas além de RTL/VCL/SynEdit (conferido no `.map`): `Checksum`, `Diff*`, `DiffUtils`,
  `Historylist`, `JVCSDiffResources`, `JVCSForms`, `JVCSUIScale`, `JVCSUITheme`.
- Recursos (fonte única: `src\jedivcsdiff\jvcsver.rc`):
  `brcc32 -fojvcsver.res jvcsver.rc` (na pasta `src\jedivcsdiff`). O `.res` leva o VERSIONINFO
  (FileVersion 2.5.0.2026, ProductVersion "2.5 Beta 2026", `VS_FF_PRERELEASE`) e o manifesto
  `JEDIVCSDiff.manifest` (Common Controls 6, `asInvoker`, DPI *System Aware*, Windows 7 a 11).
- Estilos VCL: `src\common\client\JVCSUIStyles.rc` → `brcc32 -foJVCSUIStyles.res JVCSUIStyles.rc`
  (na pasta `src\common\client`). Embute `styles\WindowsModernDark.vsf` (do
  `Studio\37.0\Redist\styles\vcl`, redistribuível). O `JVCSUITheme.pas` faz `{$R JVCSUIStyles.res}`.
- Build privado para iterar sem disputar `dcu\Win32\<cfg>` com outros alvos: o mesmo comando do log
  com `-NU`/`-E` em outra pasta.

## 2. O que mudou

| Arquivo | Mudança |
|---|---|
| `JEDIVCSDiff.dpr` | Sem `FastMM4`, `winxp.res` (caminho absoluto antigo) e `cursors.res` (não usado). Sem as units do EXE e do cliente de rede (o Diff não fala com o servidor). `Application.MainFormOnTaskbar := True` (no lugar do "Vista taskbar fix"). `JVCSUIInitialize`, `JVCSUIThemeInitialize`, `JVCSUIStartFollowingSystem`. |
| `compopt.inc` | Sem `{$IMAGEBASE}` e sem `MEMCHECK`/`USE_JEDI_JCL`. |
| `jvcsver.rc/.res`, `JEDIVCSDiff.manifest` (novo) | Versão 2.5 Beta 2026 + manifesto (ver seção 1). |
| `DiffUtils.pas` (nova) | Substitutos locais: `TDiffMruList` (MRU no **formato do TJvMruList/comctl32**: `MRUList` + valores `a`..`j` em `HKCU\Software\JEDI\JEDIVCSDiff\MRU\Base` e `\CompareTo`); `DiffRegRead/Write*` (registro tolerante a tipo, no lugar do `RegAcc`); `TDiffTextReader` (lê o arquivo inteiro e detecta a codificação: BOM UTF-8/UTF-16, UTF-8 válido sem BOM, senão ANSI do sistema); `DiffBestEncoding`; `DiffFileVersionValue` (no lugar do `TJclFileVersionInfo`); `DiffGetFileSize`, `DiffFileDateStr`; `DiffMakeImageList32` (ver abaixo). |
| `DiffMain.pas/.dfm` | `TdfsStatusBar` → `TStatusBar` (`StatusBar1`) + `TProgressBar` no painel 2 como gauge (`pbstMarquee` no modo indeterminado). `TJvComboBox` → `TComboBox`; `TJvMruList` → `TDiffMruList`. Sem `ThemeMgr`, `ItemProp`, `JclFileUtils`, `JvGnugettext` (fora de `LANGUAGE`). **Leitura**: `TextFile`/`Readln` (ANSI fixo) → `TDiffTextReader`; **gravação** (`SaveChanges`) na mesma codificação e BOM detectados. `IsTextFile` reescrito sobre bytes (o buffer de `Char` tinha 2 bytes por caractere; arquivo vazio dava range check); BOM UTF-8/UTF-16 = texto; bytes ≥ `$80` não são testados (aceita UTF-8). `set of Char` → `set of AnsiChar` + `CharInSet`. SynEdit pyscripter: `TSynEditMark.Create(Editor)`, `InvalidateGutter`, `Gutter.Width` saiu do DFM, **`Gutter.Bands` gravado no DFM** (o `ReadState` do SynEdit atual limpa as bandas e espera recebê-las do DFM; sem isso não há gutter nem marks), banda de marks com a largura das imagens; `ClearUndo` antes de `Modified := False` (o `Modified` agora deriva da lista de undo; na ordem antiga o Diff sempre perguntava "salvar alterações?" ao fechar). Imagens das marks e da toolbar convertidas para 32 bits com alfa (`DiffMakeImageList32`: o gutter desenha via Direct2D e as imagens antigas, sem alfa, ficavam invisíveis). Posição/tamanho da janela gravados em **unidades de 96 dpi** (como o original, que não era DPI-aware) e convertidos para o DPI atual. Parâmetros lidos só na primeira ativação (antes eram reaplicados ao fechar qualquer diálogo, e `/autostart` comparava de novo). Novos parâmetros `/log:` e `/close` (ver 3.1). Fonte/escala e tema (`ApplyAppearance`, cores "lógicas" `EditorColor`/`EditorTextColor`/`EditorSel*` traduzidas pelo estilo). |
| `DiffEditorProp.pas/.dfm` | `TJvSpinEdit` → `TSpinEdit`, `TJvColorComboBox` → `TColorBox`. Grupo novo **"User interface (all JEDI VCS windows)"**: tamanho da fonte da interface (100–200% ou livre 80–250), fonte da interface (TFontDialog + "System default font") e tema (Follow Windows / Light / Dark). OK grava e aplica na hora. A fonte do editor também vai para a preferência comum `EditorFontName/EditorFontSize`. |
| `DiffHLProp.pas/.dfm` | `TColorBox`; `TSynHighlighterAttributes.Create(Name, FriendlyName)` e o objeto temporário agora é liberado; índice -1 protegido. |
| `DiffSimpleReport.pas` | `TFavSaveDialog` → `TSaveDialog` (pastas recentes continuam em `JEDIVCSDiff\MRU`, valores `1..n`, e a mais recente vira a pasta inicial); `RegAcc` → `DiffRegRead/Write*` (mesmas chaves `SReportTarget`, `SReportShow`, `FileDlgMRU`); visualização própria (no lugar do `TVCSListView`). Relatório RTF gravado em bytes ANSI (antes gravava metade da string UTF-16); TXT/HTML em ANSI ou, se houver caractere fora da code page, UTF-8 com BOM. |
| `historylist.pas` | `SaveToReg` apaga só os valores `1..n` (o `DeleteKey` apagava junto as subchaves `MRU\Base` e `MRU\CompareTo`). |
| `DiffAbout.pas` (sem `.dfm`) | Diálogo próprio montado em código (versão, data do arquivo, créditos, parâmetros). Não herda mais de `JVCSBaseAboutDialog`, que usa `TJvRichEdit` e units do EXE. Observação: a remoção do `DiffAbout.dfm` acabou entrando no commit `94865dd` (do port do EXE), porque estava no índice quando ele foi feito. |
| `DiffHelp.pas` | `HtmlHelpW` declarado localmente (`hhctrl.ocx`, `delayed`); sem `JclDebug`. |
| `DiffCustomKW.pas`, `JVCSDiffResources.pas` | Fonte/escala; textos novos (About, "System default"); crédito do SynEdit atualizado. |
| `tools\compilar.bat` (bloco `diff`) | `PRJ_diff_DEFINES=DelphiPersonalEdition`, `PRJ_diff_PATH=` (vazio). |

Comportamento preservado: chaves do registro do Diff (`HKCU\Software\JEDI\JEDIVCSDiff\Window`,
`\Options`, `\Options\Highlighters\...`, `\MRU`), parâmetros `/s:` `/t:` `/sc:` `/tc:` `/autostart`,
algoritmo de comparação (Biernaczyk) e textos da interface (inglês).

## 3. Testes

### 3.1 Parâmetros (novo e original)

| Parâmetro | Original 2.5.0.1030 | Port |
|---|---|---|
| `/s:<arq>` `/t:<arq>` | base / comparar com (o texto vai em minúsculas) | igual |
| `/sc:<texto>` `/tc:<texto>` | texto do cabeçalho de cada lado | igual |
| `/autostart` | compara ao abrir e mostra a caixa de resultado | igual |
| `/log:<arq>` | — | **novo**: acrescenta o resultado (mensagem, codificações, nº de linhas, deltas, `Result: 0/1/2`) em UTF-8 e não mostra caixas de mensagem |
| `/close` | — | **novo**: com `/autostart`, fecha depois de comparar; **exit code** 0 = iguais, 1 = diferentes, 2 = erro (arquivo ausente etc.) |

### 3.2 Comparações (Release e Debug, 12/10/2026)

Arquivos de teste: par ANSI cp1252 com acentos (`ação`, `revisão`, `ç`, `ã`), par UTF-8 sem BOM com
acentos, grego e `€`, par idêntico, e o mesmo texto em ANSI × UTF-8 com BOM. Execução:
`JEDIVCSDiff.exe /s:A /t:B /autostart /log:log.txt /close`.

| Par | Port (log / exit code) | Original 2.5.0.1030 (caixa de resultado) |
|---|---|---|
| ANSI × ANSI | "differ by 3 lines (3 Blocks)", ANSI 1252/ANSI 1252, 9/10 linhas, exit 1 | "differ by 3 lines (3 Blocks)" |
| UTF-8 × UTF-8 | "differ by 4 lines (4 Blocks)", UTF-8/UTF-8, 10/11 linhas, exit 1 | "differ by 4 lines (4 Blocks)" |
| idênticos | "The files are equal.", exit 0 | iguais |
| ANSI × UTF-8 com BOM (mesmo texto) | **"The files are equal."**, ANSI 1252/UTF-8, exit 0 | "differ by 4 lines (3 Blocks)" (lê o UTF-8 como ANSI) — diferença intencional |
| arquivo inexistente | mensagem "not found" no log, exit 2 | caixa "not found" |

Capturas de tela (feitas com `PrintWindow`/`CopyFromScreen` num script PowerShell DPI-aware, em
monitor de 200%): janela principal com os acentos e o grego corretos nos dois editores, linhas
alinhadas e marks de diferença no gutter; tema escuro (`UITheme=2`) e escala 150% (`UIFontScale=150`)
aplicados (menus, combos, cabeçalhos, status bar e editores); submenu "File" aberto com owner-draw
em 150%.

### 3.3 Forms e MRU

- Harness que cria e mostra `Tfm_Main`, `Tfm_EditorProp`, `TCustomKW`, `TVCSSimpleReport`,
  `Tfm_HighLightProp` e `TJVCSDiffAbout` (tema claro e escuro, 150%): **todos sem `EReadError`**.
- MRU: o original lê a lista gravada pelo port e o port lê a gravada pelo original (`MRUList` + `a..j`).

### 3.4 Não testado ainda

- Gravação (`SaveChanges`) de um arquivo UTF-8 editado: o código grava na codificação/BOM detectados,
  mas o teste precisa de interação.
- Relatórios (TXT/HTML/RTF/impressão), ajuda (`jedivcsdiff.chm`: copiar de `3rdparty` para
  `bin\client\Win32`), D11/D12 e chamada pelo EXE/DLL.

## 4. Aparência: `JVCSUIScale` e `JVCSUITheme` (`src\common\client`)

### 4.1 Chaves de configuração

Chave padrão: `HKCU\Software\JEDI\JEDIVCS\Options` (`JVCSUIOptionsKey`).

| Valor | Tipo | Padrão | Significado |
|---|---|---|---|
| `UIFontScale` | DWORD | 100 | Escala da fonte da interface em % (80–250; o diálogo oferece 100/125/150/175/200) |
| `UIFontName` | String | `''` | Fonte da interface; vazio = fonte do sistema (`Screen.MessageFont`) |
| `UIFontSize` | DWORD | 0 | Tamanho em pt; se > 0 **prevalece** sobre `UIFontScale` |
| `MenuFontName` | String | `''` | Fonte dos menus; vazio = segue a interface |
| `MenuFontSize` | DWORD | 0 | Tamanho dos menus em pt; 0 = segue a interface |
| `EditorFontName` | String | `''` | Fonte dos editores (Diff, Line History, visualizadores); vazio = Consolas |
| `EditorFontSize` | DWORD | 0 | Tamanho dos editores em pt; 0 = 10 |
| `UITheme` | DWORD | 0 | 0 = seguir o host (Windows no standalone, IDE na DLL), 1 = claro, 2 = escuro |

No Diff, `EditorFontName/EditorFontSize` prevalecem sobre `JEDIVCSDiff\Options\FontName/FontSize`
quando definidos. O diálogo do Diff grava os dois.

### 4.2 API

`JVCSUIScale`:
- `JVCSUIInitialize` (carrega e ajusta `Screen.MenuFont`), `JVCSUILoadFontSettings`,
  `JVCSUISaveFontSettings`, `JVCSUIFontSettings`, `JVCSUISetFontSettings(S, ApplyNow)`.
- `JVCSUIApplyToForm(Form, KeepFormSize)`: troca o nome da fonte (form e controles com fonte própria
  que usavam a do form), `ScaleBy(novaAltura, alturaAtual)` e aplica aos menus do form. Pode ser
  chamada de novo (reaplica a partir do estado atual). `KeepFormSize = True` em janelas principais.
- `JVCSUIApplyToAllForms`, `JVCSUIApplyToMenu(Menu)`, `JVCSUIAssignEditorFont(Font)`,
  `JVCSUIAssignMenuFont(Font)`.
- Menus: com fonte/tamanho padrão nada muda (desenho nativo). Fora do padrão: popups viram owner-draw
  (`OnMeasureItem`/`OnAdvancedDrawItem` só onde não havia handler); no `TMainMenu` os **itens de nível 1
  ficam nativos** (a altura da barra é fixa em `SM_CYMENU` e o VCL não entrega o owner-draw desses
  itens) e os submenus viram owner-draw por meio de uma ImageList (regra do VCL para Vista+). Com VCL
  Style ativo não há owner-draw: os style hooks já desenham com `Screen.MenuFont`.
- Armazenamento trocável: `JVCSUIReadInteger/WriteInteger/ReadString/WriteString` têm as mesmas
  assinaturas de `jvcsReadInteger` etc. (ConfigStorage).

`JVCSUITheme`:
- `TJVCSUIThemeMode = (tmFollowHost, tmLight, tmDark)`; `JVCSUILoadThemeMode`/`JVCSUISaveThemeMode`;
  `JVCSUIThemeInitialize`; `JVCSUIApplyTheme(Mode)`; `JVCSUIIsDark`; `JVCSUIColor(clWindow...)` (cor
  de sistema traduzida pelo estilo); `JVCSUISetDarkTitleBar(HWND, Dark)` (DWM, para janelas sem estilo).
- Claro = estilo nativo `Windows`; escuro = `Windows Modern Dark` (embutido). O Redist do D13.2
  Professional não traz "Windows11 Modern"; os disponíveis são `WindowsModern*`, `Windows10*` e outros.
- Standalone: "seguir o host" lê `HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize\AppsUseLightTheme`
  (0 = escuro); `JVCSUIStartFollowingSystem` cria uma janela oculta que reaplica o tema no
  `WM_SETTINGCHANGE` "ImmersiveColorSet".
- **Dentro da IDE (F5)**: a DLL não lê o tema da IDE. O expert informa por `JVCSUISetHostTheme(IsDark)`
  (por exemplo no `IOTAIDEThemingServicesNotifier.ChangedTheme`, repassado por um verbo/notificação nova
  da ABI) ou atribui `JVCSUIHostIsDark` (função que devolve o tema atual). Com isso, "seguir o host"
  segue a IDE; a escolha fixa (claro/escuro) continua valendo.
- `JVCSUIOnThemeChanged`: evento chamado depois de cada troca efetiva (o Diff reaplica as cores dos
  editores).

### 4.3 Como o EXE e a DLL vão usar

1. No início (`.dpr` do EXE; inicialização da DLL): se usarem a ConfigStorage, atribuir
   `JVCSUIReadInteger := jvcsReadInteger` (e as outras três) e
   `JVCSUIOptionsKey := sBaseRegistryKey + crbOptions`; depois `JVCSUIInitialize` e
   `JVCSUIThemeInitialize`. No EXE, também `JVCSUIStartFollowingSystem`.
2. Em cada form: `JVCSUIApplyToForm(Self)` no `OnCreate`/`DoShow`. O ideal é fazê-lo uma vez em
   `TJVCSForm` (ver seção 5).
3. Editores SynEdit: `JVCSUIAssignEditorFont(Editor.Font)` e cores com `JVCSUIColor`.
4. "VCS Properties → User Interface" (`Options.pas`): mesmos controles do grupo do Diff; no Apply,
   `JVCSUISaveFontSettings` + `JVCSUISetFontSettings(S, True)` + `JVCSUISaveThemeMode` +
   `JVCSUIApplyTheme`.
5. DLL: tema por `JVCSUISetHostTheme` vindo do expert; item "JEDI VCS → Tamanho da fonte..." grava as
   chaves e manda a DLL chamar `JVCSUISetFontSettings(JVCSUILoadFontSettings, True)`.

### 4.4 Limitações conhecidas

- Tema escuro: os ícones antigos da toolbar (16 cores, traço escuro) quase somem no fundo escuro;
  as cores dos highlighters do SynEdit não são trocadas. Precisa de ícones novos e de um esquema
  escuro de highlighter (F4).
- A barra do menu principal não cresce sem VCL Style (só os submenus e popups crescem).
- `ImageList` das marks/toolbar não é escalada pelo DPI (16 px em 200%).

## 5. Mudanças desejadas em units compartilhadas (não feitas aqui)

- `src\common\JVCSForms.pas`: chamar `JVCSUIApplyToForm(Self)` em `TJVCSForm.DoShow` (ou `Loaded`),
  uma vez por form, para valer em todos os forms do EXE/DLL sem editar cada um.
- `src\common\JVCSBaseAboutDialog.pas/.dfm`: trocar `TJvRichEdit` (créditos) por `TRichEdit` e tirar
  `JclFileUtils`; depois o `DiffAbout` pode voltar a herdar dele.
- `src\common\JVCSLanguage.pas`: `JvGnugettext` → `gnugettext` para religar `LANGUAGE` no Diff.
- `tools\LEIAME-compilar.md`: linha do `diff` na tabela de projetos (sem `LANGUAGE`, sem `..\jedivcs`).

## 6. Pendências

- Critério do plano não coberto: "Compara um arquivo contra uma revisão do servidor" é feito pelo EXE
  (ele baixa a revisão e chama o Diff com `/s:` `/t:` `/sc:` `/tc:`); testar quando o EXE chamar o
  Diff. O Diff em si não faz LOGIN.
- Teste de gravação UTF-8, relatórios e ajuda; build em D11/D12.
- `.dproj` do Diff (manifesto já pronto no `.rc`).
