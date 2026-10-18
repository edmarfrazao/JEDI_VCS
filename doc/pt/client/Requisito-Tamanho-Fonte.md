# Requisito — Aparência: fonte, tamanho e tema claro/escuro

Requisito (12/10/2026): em monitor de 32" QHD (2560×1440, escala 100%), menus e textos do JEDI VCS ficam pequenos.
Deve existir uma forma de **alterar o tamanho da fonte** no cliente **standalone** e na versão **integrada ao Delphi**.

## 1. Situação atual (binários originais 2.5.0.1030)
`jedivcs.exe`, `jedivcsdiff.exe` e a `JvcsExternalDll.dll` (Delphi 2007) têm fontes fixas no DFM compilado e não são DPI-aware.
Em escala 100% o Windows não amplia nada (o fator é 1), então nenhuma opção de compatibilidade de DPI resolve.
Paliativos até o port:
- **Configurações → Acessibilidade → Tamanho do texto** (afeta menus/títulos de todos os apps), ou
- **Configurações → Sistema → Tela → Escala 125%** no monitor de 32" (com `JVCS_EXPERT_DPI=gdiscaled`, padrão do expert, as janelas da DLL
  são ampliadas pelo Windows com texto nítido; para o `jedivcs.exe`: Propriedades → Compatibilidade → Alterar configurações de DPI alto →
  "Substituir comportamento de dimensionamento" = **Sistema (Avançado)**).

## 2. Implementação no port (v2026)
**Preferência única, compartilhada** por EXE, Diff, console (n/a) e DLL da IDE:
`HKCU\Software\JEDI\JEDIVCS\Options` → `UIFontScale` (inteiro, %, padrão 100; valores 100/125/150/175/200 ou livre 80–250)
e opcionalmente `UIFontName` (padrão: fonte do sistema, `Screen.MessageFont`). Lido/gravado via `ConfigStorage` (jvcsReadInteger/jvcsWriteInteger).

**Interface**
- Standalone: menu **Exibir → Tamanho da fonte** (Normal / 125% / 150% / 175% / 200% / Personalizar…) + controles em **VCS Properties → User Interface** (`Options.pas`; ver `img\options-user-interface-2.5.0.1030.png`): "Tamanho da fonte da interface" (combo de %), "Fonte" (padrão do sistema) e "Tamanho da fonte dos editores" (Diff/Line History, preferência `EditorFontSize` separada), ao lado das cores de listview já existentes. A mesma página serve à DLL na IDE.
- Integrado ao Delphi: item **JEDI VCS → Tamanho da fonte…** criado pelo expert (`src\jvcsideexpert\JVCSExpertWizard.pas`), que grava a mesma
  chave e notifica a DLL (novo verbo/notificação) para reaplicar nas janelas abertas. Os menus da **IDE** (o próprio menu "JEDI VCS") seguem
  a fonte/tema da IDE e não são alterados.

**Aplicação técnica (unit nova `src\common\JVCSUIScale.pas`)**
- Janelas: em `TJVCSForm` (base comum, `src\common\JVCSForms.pas`) aplicar no `Loaded`/`DoShow`: `Font.Height := MulDiv(Base, Scale, 100)`
  com `ParentFont` nos controles, e `ScaleBy(Scale,100)` só para tamanhos fixos que não acompanham a fonte; listas (`TListView`, VirtualTree)
  ajustam `DefaultNodeHeight`/`Header.Height`; SynEdit ajusta `Font.Size` do editor separadamente (preferência própria opcional).
- Menus: VCL `TMainMenu`/`TPopupMenu` usam a fonte de menu do sistema; para escalar, usar **owner-draw** (`OwnerDraw := True` +
  `OnMeasureItem`/`OnAdvancedDrawItem` com `Screen.MenuFont` escalado) ou trocar por `TActionMainMenuBar` (propriedade `Font`).
  Recomendação: helper genérico em `JVCSUIScale` que percorre os itens e liga o owner-draw, para não editar cada DFM.
- DPI: projetos com manifesto **Per-Monitor V2** (já previsto no Plano-de-Port F0); a escala do usuário multiplica a do monitor.
- Fase do plano: infraestrutura em **F3** (comum de GUI, piloto no Diff), aplicada em **F4** (EXE) e **F5** (DLL + item no expert).

## 2.1 Escolha explícita de fonte e tamanho
Além da escala em %, a página **VCS Properties → User Interface** terá:
- **Fonte da interface…** — botão que abre um TFontDialog (família + tamanho em pontos, sem cor/efeitos), com prévia ao lado e botão **Padrão do sistema**. Grava UIFontName e UIFontSize (pt).
- **Fonte dos editores…** — idem para Diff/Line History/visualizadores (EditorFontName, EditorFontSize; padrão Consolas 10).
- **Fonte dos menus** — por padrão acompanha a fonte da interface; opção de família/tamanho próprios (MenuFontName, MenuFontSize).
- Regra: se UIFontSize estiver definido, ele prevalece sobre UIFontScale; a escala em % fica como atalho rápido (menu Exibir → Tamanho da fonte).
- Aplicação imediata ao clicar **Apply** (todas as janelas abertas, standalone e IDE), sem reiniciar.

## 2.2 Tema claro/escuro seguindo o Delphi
- **Integrado ao Delphi:** o expert lê o tema ativo da IDE via ToolsAPI (`IOTAIDEThemingServices.ActiveTheme`: Light / Dark / Mountain Mist) e registra um notifier (`IOTAIDEThemingServicesNotifier.ChangedTheme`) para acompanhar a troca em tempo real. Ele repassa o tema à DLL (novo valor na ABI v2 ou notificação `ifn*` nova; na DLL original 2007 não é possível).
  Como a DLL portada tem a **própria VCL** (linkada estática, sem runtime packages), o `ApplyTheme` da IDE não estiliza os forms dela; a DLL aplica um **VCL Style equivalente** com o seu `TStyleManager`: Light → padrão/"Windows11 Modern Light", Dark → "Windows11 Modern Dark" (ou o style escuro mais próximo do tema da IDE), Mountain Mist → claro. Os .vsf vêm de `Studio\37.0\Redist\styles\vcl` e são embutidos como recurso.
- **Standalone:** opção **Tema: Seguir o Windows / Claro / Escuro** (`UITheme`) em VCS Properties → User Interface; "Seguir o Windows" lê `HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize\AppsUseLightTheme` e reage a `WM_SETTINGCHANGE`. Barra de título escura no Windows 11 via `DwmSetWindowAttribute(DWMWA_USE_IMMERSIVE_DARK_MODE)`.
- **Cuidados:** cores personalizadas da listview (New / In work by you / by others) precisam de versão para tema escuro (`ListColorsDark`); owner-draw dos menus e listas usa `StyleServices` para fundo/texto; SynEdit (Diff/Line History) troca o esquema de cores do highlighter; VirtualTree acompanha o style.
- Fase: infraestrutura junto com `JVCSUIScale` (unit `JVCSUITheme.pas`) na **F3**, aplicada na F4/F5.

## 3. Critério de aceite
No monitor de 32" QHD a 100%: ao escolher outra fonte/tamanho (ex.: Segoe UI 12 pt) ou 150%, menus, listas, diálogos e o editor do Diff ficam proporcionalmente maiores, sem cortes de
texto, e a escolha persiste entre sessões e vale tanto no `jedivcs.exe` quanto nas janelas abertas pelo menu JEDI VCS no Delphi.
- Tema: com a IDE em Dark, as janelas do JEDI VCS abertas pelo menu ficam escuras e mudam junto ao trocar o tema da IDE; o standalone segue o tema do Windows (ou a escolha fixa).
