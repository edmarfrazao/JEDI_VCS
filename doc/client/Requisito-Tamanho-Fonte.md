# Requisito — Tamanho da fonte da interface (menus e janelas)

Pedido do usuário (12/10/2026): em monitor de 32" QHD (2560×1440, escala 100%), menus e textos do JEDI VCS ficam pequenos.
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

## 3. Critério de aceite
No monitor de 32" QHD a 100%: ao escolher 150%, menus, listas, diálogos e o editor do Diff ficam proporcionalmente maiores, sem cortes de
texto, e a escolha persiste entre sessões e vale tanto no `jedivcs.exe` quanto nas janelas abertas pelo menu JEDI VCS no Delphi.
