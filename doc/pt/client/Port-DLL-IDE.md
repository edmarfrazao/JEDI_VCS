# Port da DLL da IDE `JvcsExternalDll.dll` para Delphi 13.2 (F5)

Estado em **12/10/2026**. A DLL do cliente para a IDE (`src\jedivcs\JediVCSDLL.dpr`, as mesmas fontes
do `Jedivcs.exe` portado na F4) compila no Delphi 13.2 Win32 (Debug e Release, 0 erros) e gera
`bin\client\Win32\JvcsExternalDll.dll`. Ela substitui a `JvcsExternalDll.dll` 2.5.0.1030 (Delphi 2007)
atrás do expert novo `src\jvcsideexpert` (`JvcsExpertBDS37.dll`), com a mesma ABI.

O harness fora da IDE passou com a DLL nova e com a original (mesma sequência do expert, sem access
violation). **Ainda falta o teste dentro da IDE** (roteiro na seção 5).

Referências: [Plano-de-Port.md](../common/Plano-de-Port.md) (F5),
[Port-Standalone.md](Port-Standalone.md) (port do EXE), [Expert-IDE-Analise.md](Expert-IDE-Analise.md)
(ABI e callbacks), [`src\jvcsideexpert\LEIAME.md`](../../../src/jvcsideexpert/LEIAME.md).

## 1. Como compilar

```
tools\compilar.bat dll Debug Win32
tools\compilar.bat dll Release Win32
tools\compilar-expert.bat Release nova        (expert + DLL nova em bin\ideclient\Win32)
tools\compilar-expert.bat Release original    (volta para a 2.5.0.1030)
```

- Saída: `bin\client\Win32\JvcsExternalDll.dll` (+ `.map`/`.drc`). O dcc32 gera `JediVCSDLL.dll` e o
  `compilar.bat` renomeia para o nome que o expert procura (novo campo `PRJ_dll_OUT` da tabela).
- DCUs em `dcu\Win32\<cfg>\dll` (separados do EXE). Log: `tools\logs\compilar_dll_Win32_<cfg>.log`.
- Resultado: 0 erros; 328 avisos (Debug) e 327 (Release), os mesmos tipos do EXE (`W1057`/`W1058` dos
  registros `ShortString`, `W1050`, `W1000`).
- Tamanho: 18,2 MB (Release; a 2.5.0.1030 tinha 5,9 MB). Sem runtime packages.
- Versão: o `jvcsver.res` do EXE (FileVersion 2.5.0.2026, ProductVersion "2.5 Beta 2026",
  pré-lançamento), como a original usava o mesmo recurso do EXE.

### Defines do alvo `dll`

`DEBUG`/`RELEASE`, `IDEDLL`, `EXT_IDE_INTF`, `USECLIENTDISPATCHER`, `BRANCHING`, `JVCS_NOBRANCHUI`,
`UNISYNEDIT` e `OVERBYTEV6_UP` (comum): os do EXE mais os dois da DLL. `LANGUAGE` saiu (era do `.dof`)
e `REPORTDLL` continua desligado (`JVCS_NOREPORTS`).

## 2. O que mudou

| Arquivo | Mudança |
|---|---|
| `tools\compilar.bat` | alvo `dll` com os defines acima; `PRJ_chave_OUT` + `:rename_out` (`JediVCSDLL.*` → `JvcsExternalDll.*`) |
| `JediVCSDLL.dpr` | sem `ShareMem` (a 2.5.0.1030 não importava `borlndmm.dll`; nada gerenciado atravessa a ABI) e sem `winxp.res` (a DLL roda no contexto de ativação da IDE); `JvDynControlEngineVCL` (diálogos DSA, como no EXE); exports `GetIDString`/`GetMenuName`/`GetVerb`/`FileNotification` com `PAnsiChar`; `AnsiCrLf` → `sLineBreak`; **relatórios**: `DoPrintReport` não faz nada e o verbo fica desabilitado sob `JVCS_NOREPORTS`; **`JVCS_NOBRANCHUI`**: `MapVerbIndex`/`GetVerbCount` sem o "Select Branch" (27 verbos, como sem `BRANCHING`; a original tem 29) |
| `JVCSIDEInterface.pas` | lado DLL das 24 callbacks: `PChar` (= `PWideChar` no Delphi 13) → `PAnsiChar`; string → ANSI (CP_ACP) **sem "best fit"**; buffers de saída de 1 KB zerados e terminados (o expert escreve no máximo 255 + #0); `SourceReadString` com `AnsiString` e os bytes exatos (`IDESource2Stream` gravava UTF-16 no stream); `GetModuleComponents` com o nome convertido uma vez |
| `JVCSDLLAnsi.pas` (nova) | `JvcsToAnsi`, `JvcsFromAnsi`, `JvcsAnsiCopy` (StrPCopy para o buffer do expert, com limite opcional) |
| `JVCSDLLFileHistoryImpl.pas` | 9 funções de History com `PAnsiChar`; comentário limitado a `AMaxCommentSize` bytes ANSI |
| `JVCSDLLOperations.pas` | 10 operações com `PAnsiChar` |
| `VerSet.pas` | `AnsiCrLf` → `sLineBreak` |
| `src\common\JVCSIDESettings.pas` | `{$ifdef WINDOWS}` → `MSWINDOWS` (sem isso o `JclRegistry` não entrava). Detecção do BDS 37 **não** foi acrescentada: continua `IDEUnknown`, tratado como Delphi (igual à original) |
| `src\common\client\JVCSClientFunctions.pas` | `GetSelfFileName`: `Length` no lugar de `SizeOf` no `GetModuleFileName` (estouro de buffer com `Char` = `WideChar`; afeta EXE, console e DLL) |
| `tools\compilar-expert.bat` | 2º parâmetro `nova` (padrão) ou `original`: qual `JvcsExternalDll.dll` vai para `bin\ideclient\Win32` |

O expert (`src\jvcsideexpert\*.pas`) **não mudou**: a ABI é a mesma, a DLL nova é procurada pelo mesmo
nome na mesma pasta e o expert não confere versão.

### 2.1 LOGIN

A versão enviada no `LOGIN` vem de `GetJVCSAppProductVersionInt` (`VCSProcBase.pas`), chamado em
`Create.pas:534`. Ela lê o **PRODUCTVERSION numérico do próprio módulo** (`GetSelfFileName` →
`GetModuleFileName(HInstance)`, ou seja, a DLL, não o `bds.exe`): 2,5,0,2026 → 2·100 + 5·10 + 0 =
**250**. A original tem PRODUCTVERSION 2.5.0.0 → também **250**. O servidor aceita 250 (mesmo valor do
EXE portado, conferido no proxy na F4). Não conferido no fio com a DLL (o harness não conecta).

## 3. ABI: exports

`tdump -ee` (Delphi 13.2):

| Export | Original 2.5.0.1030 | Nova 2.5.0.2026 |
|---|---|---|
| `JEDIVCSDLLINIT` | ord 4 | ord 7 |
| `JEDIVCSDLLFINALIZE` | ord 3 | ord 6 |
| `JEDIVCSDLLHISTORYINIT` | ord 2 | ord 5 |
| `JEDIVCSDLLOPERATIONINIT` | ord 1 | ord 4 |
| `dbkFCallWrapperAddr`, `__dbk_fcall_wrapper` | — | ords 1 e 2 (RTL do Delphi moderno, para o depurador) |
| `bz_internal_error` | — | ord 3 (bzip2 do Abbrevia, linkado estático) |

Os quatro exports da ABI têm os mesmos nomes. Os ordinais mudaram, mas o expert (antigo e novo) usa
`GetProcAddress` por nome. Os três exports extras são inofensivos. Assinaturas: os records e tipos
vêm de `src\common\JVCSIDEInterfaceCommon.pas`, sem alteração (`stdcall`, `PAnsiChar`, `{$Z1}`). O
teste F do expert já confere a cópia `JVCSExpertABI.pas` contra essa unit.

## 4. Harness fora da IDE

```
src\jvcsideexpert\tests\testar-dll.bat [nova|original|ambas] [verbos]
```

`JvcsDllHarness.dpr` é um host console com `rtl;vcl;designide` que usa o **`TJVCSDllBridge` e as 24
callbacks reais do expert**, com um `IBorlandIDEServices` vazio. Sequência:

1. `Load`: `LoadLibraryEx` na pasta do host, `JEDIVCSDLLINIT(@IDE,@VCS,@Notifier)`,
   `JEDIVCSDLLHISTORYINIT`, `JEDIVCSDLLOPERATIONINIT`;
2. `GetMenuName`, `GetVerbCount`, e para cada verbo `GetVerb`/`GetVerbState`/`GetVerbShortCut`/
   `GetVerbImageIndex`; `GetVerbImages` 16×16;
3. `FileNotification`, `EventNotification` (before/after compile), `ProjectChange`, `HistoryCount`;
4. `ExecuteVerb` em Connect Server, Project Manager, VCS Properties, Recent Projects e About (ou nos
   índices passados). Uma thread registra e fecha toda janela visível do processo;
5. `OpGetProjectID` sem conexão;
6. `Unload`: `JEDIVCSDLLFINALIZE` e depois `FreeLibrary`.

Um *vectored exception handler* conta **toda** `EXCEPTION_ACCESS_VIOLATION` do processo (primeira
chance, tratada ou não). O host tem VERSIONINFO porque, no login, a DLL lê a versão do executável
(`Application.ExeName`, o `bds.exe` na IDE). Saídas em `dcu\Win32\dll-harness\bin\<nova|original>\
harness.txt`.

Resultado (12/10/2026, Debug e Release da nova; original 2.5.0.1030):

| | Nova (2.5.0.2026) | Original (2.5.0.1030) |
|---|---|---|
| INIT / HISTORYINIT / OPERATIONINIT | True / 9 ponteiros preenchidos / OK | igual |
| Menu | `JEDI &VCS ` | igual |
| Verbos | 27 (sem "Select Branch") | 29 |
| Atalhos padrão | Ctrl+Shift+P/I/O/G/B | igual |
| Imagens 16×16 | BMP de 7734 bytes | igual |
| Connect Server | aviso "IDE returns no active IDE project" (o host não tem projeto) + `TVCSLoad` "Server Login" | igual |
| Project Manager sem conexão | "Application server not connected" | igual |
| VCS Properties / Recent Projects / About | `TVCSOptions` / `TVCSRecentProjects` / `TVCSAbout` | igual |
| FINALIZE + FreeLibrary | OK | OK |
| Access violations no processo | **0** | **0** |
| Falhas | 0 | 0 |

O harness não conecta ao servidor: login, check-in/out, History e operações com projeto ficam para o
teste na IDE.

## 4A. Comportamento dentro da IDE: aparência, menus, janelas e erros (13/10/2026)

### 4A.1 Tema e fonte

- A DLL usa as mesmas opções do EXE (VCS Properties → **Appearance**, `HKCU\Software\JEDI\JEDIVCS\Options`),
  aplicadas por `JVCSClientAppearanceInit(sIDERegistryKey)` em `JediVCSInternalInit`.
- **"Follow Delphi"** (`UITheme = 0`): a DLL lê o tema da IDE no registro do processo hospedeiro, sem mudar
  a ABI: `HKCU\<chave base da IDE>\Theme`, valor `Theme` (nesta máquina, `HKCU\Software\Embarcadero\BDS\37.0\Theme`
  = `Dark`). `Dark` → escuro; `Light` e `Mountain Mist` → claro; `Custom` → escuro se o valor `VCLStyle`
  contiver "Dark". A chave base vem do expert (`GetBaseRegistryKey`, que respeita `bds.exe -r`); se vier
  vazia, `JVCSUIGuessDelphiBaseKey` monta `Software\Embarcadero\<-r ou BDS>\<versão do bds.exe>`. O tema é
  relido a cada janela do JEDI VCS que abre (`TJVCSForm.DoCreate/DoShow`) e repassado a
  `JVCSUISetHostTheme`; trocar o tema da IDE vale na próxima janela aberta (a IDE grava o registro ao
  trocar o tema; não há notificação em tempo real sem mudar a ABI).
- **Tema real da IDE (13/10/2026).** O valor do registro nem sempre é o tema em uso: no Delphi 11 do usuário a
  IDE estava **clara** e `HKCU\Software\Embarcadero\BDS\22.0\Theme\Theme` = `Dark`, e as janelas do JEDI VCS
  ficavam escuras. Agora o **expert** lê o tema aplicado pela ToolsAPI (`IOTAIDEThemingServices250`, igual no
  11, 12 e 13): `IDEThemingEnabled = False` → claro; senão luminância (ITU-R 601) de
  `StyleServices.GetSystemColor(clWindow)` < 128 → escuro; sem `StyleServices`, o nome de `ActiveTheme`
  contendo "Dark". O resultado vai para a variável de ambiente **do processo** `JVCS_IDE_THEME` = `Light` ou
  `Dark` (`SetEnvironmentVariable`), gravada em `TJVCSWizard.StartUp` **antes** do `JEDIVCSDLLINIT` e
  regravada pelo `INTAIDEThemingServicesNotifier.ChangedTheme` (existe no 11, 12 e 13) quando o usuário troca
  o tema. A DLL (`JVCSUIReadHostThemeEnv` em `JVCSUIRefreshHostTheme`) usa a variável se ela for `Light` ou
  `Dark`; senão cai na leitura do registro acima. ABI inalterada; código em `JVCSExpertNotifiers`
  (`JvcsThemeInstall`/`JvcsThemeUninstall`, log `JVCS_IDE_THEME=... (tema "...", clWindow=$..., luminancia N)`
  no log do expert). O expert continua só com `rtl`/`vcl`/`xmlrtl`: símbolos novos importados
  `Vcl.Themes.TCustomStyleServices.GetSystemColor` e `System.Pos` (presentes nos `.bpl` de 11.3, 12 e 13.1/13.2;
  `verificar-expert.ps1 -Permitidos rtl,vcl,xmlrtl` com 0 ausentes, inclusive contra `ref-bpl\13.1` e
  `ref-bpl\12`). Conferido no host interativo: com `JVCS_IDE_THEME=Dark` o login sai escuro com o
  host/Windows claros; sem a variável, claro.
- **Risco avaliado (VCL Style dentro da IDE):** a DLL tem a própria VCL (estática). O estilo global dela
  (`TStyleManager`) só pinta os controles VCL da DLL, **mas** o motor de estilos instala um hook
  `WH_CBT` no thread da IDE que estiliza janelas de sistema criadas no thread (`#32768` menus, `#32770`
  diálogos, e `Edit`/`Button`/`ScrollBar`/`ComboLBox`... cujo pai não é da VCL da DLL), isto é, também
  janelas da IDE. O estilo por form (`Form.StyleName`) não serve: no Delphi 13 ele só funciona com um
  estilo global ativo. Solução: `JVCSUIContainStyleHooks` desregistra todos os *sys style hooks* da VCL da
  DLL e zera `SystemHooks`; o hook fica sem efeito e o estilo da DLL só pinta os forms da DLL. Os menus
  suspensos e as caixas de mensagem da DLL ficam com o estilo **da IDE** (hook da própria IDE).
  Conferido no host interativo: com a DLL em tema escuro e o host sem estilo, a caixa de mensagem do
  host continua clara.

### 4A.2 Menus em branco no tema escuro (bug da DLL original também)

Causa (reproduzida no host interativo com `-style WindowsModernDark.vsf`): a IDE usa VCL Style com
`SystemHooks` de menus; o hook dela pinta **toda** janela de menu `#32768` do thread, inclusive os
submenus e popups dos forms da DLL. Como a VCL da DLL é outra, o hook da IDE não acha o `TMenuItem` e lê
o texto do item com `GetMenuItemInfo(MIIM_STRING)`; os itens com imagem são *owner-draw* (a VCL não
grava o texto) e saem em branco, só com separadores e setas. Vale para o tema claro da IDE também (ele
também é um VCL Style).

Correção (`JVCSForms.JVCSInstallHostMenuFix`, ligada só na DLL): a cada `WM_INITMENUPOPUP` (no form, para o
menu principal, e numa `TPopupList` própria, para os popups) os itens owner-draw recebem o `Caption`
(+ `Tab` + atalho) como texto (`SetMenuItemInfo(MIIM_STRING)`; continuam owner-draw). O hook da IDE passa
a desenhar o texto com as cores do tema da IDE. Os ícones dos itens não aparecem dentro da IDE
(o hook da IDE não acha a ImageList da DLL); fora de host estilizado nada muda (ícones e owner-draw da
VCL). Teste com uma DLL mínima (VCL estática, menu com Images) num host com VCL Style: sem a correção
os itens com imagem ficam em branco; com ela, legíveis em host escuro, claro e sem estilo.

### 4A.3 Janela do JEDI VCS sumindo atrás da IDE (Alt+Tab)

Causa: a DLL faz `Application.Handle := GetParentHandle` (a janela **oculta** do `TApplication` da IDE) e
os forms da DLL eram *owned* por ela. Desde que a IDE usa `MainFormOnTaskBar`, a janela visível é a
`TAppBuilder`, e o Windows não traz as janelas da DLL junto com ela. Correção (`TJVCSForm.CreateParams`,
`JVCSFormsOwnerClass = 'TAppBuilder'` só na DLL): quando a dona seria `Application.Handle`, passa a ser a
janela `TAppBuilder` visível do thread. Os forms ficam acima da IDE, minimizam/restauram com ela e não
aparecem na barra de tarefas. Diálogos modais continuam com dono = form ativo.
Conferido no host interativo: `GetWindow(GW_OWNER)` do login, do Project Manager e do VCS Properties =
`TAppBuilder`.

**Atualização (13/10/2026, AV no XE3, ver §4A.7):** a DLL **não** usa mais a janela da IDE como
`Application.Handle`. Ela cria uma janela própria e oculta (classe `TJVCSDllApplication`), cuja dona é a
`TAppBuilder` (`JVCSSyncOwnAppWindowOwner`, chamado em `JVCSClientAppearanceInit` e em
`TJVCSForm.CreateParams`). Os `MessageBox(Application.Handle, ...)` e os forms que não herdam de `TJVCSForm`
ficam com dono = essa janela, e a raiz da cadeia de donos continua sendo a IDE. Por isso o Alt+Tab e a
ausência de botão na barra de tarefas se mantêm.

### 4A.7 AV ao clicar na barra de ferramentas dentro de IDEs antigas (XE3) — 13/10/2026

**Sintoma.** No Delphi XE3, com o expert original `JvcsExpertBDS10.dll` e a DLL nova (Delphi 13), clicar
num botão da toolbar do Project Manager (Synchronize, Get...) dava "Access violation at address 0029F557.
Write of address 8F82C02A". Com o Get, a operação terminava (a revisão era baixada) e o AV vinha depois.
O mesmo AV aparecia no botão Get do diálogo "Revisions", com o `.pas` aberto no editor. A pilha do XE3
foi `TToolBar.WndProc` (DLL) → `TControl.WMLButtonUp` → `TBasicActionLink.Execute` → `SendMessageW` →
`TApplication.WndProc` **da vcl170** → `DispatchAction` → `TCustomForm.WndProc` → `???`. No diálogo
Revisions a pilha era outra: `TApplication.Idle` **da DLL** → `CM_ACTIONUPDATE` → `TApplication.WndProc`
da vcl170 → `TCustomForm.CMActionUpdate` → `ProcessUpdate` → `???`.

**Causa (no código).** `JediVCSDLL.dpr`, `JediVCSInternalInit`, fazia
`Application.Handle := IDEInterface.GetParentHandle` (código original do JEDI VCS). `GetParentHandle` devolve
a janela do `TApplication` **da IDE**. A VCL manda para `Application.Handle` mensagens com **ponteiros de
objetos VCL**:
- `TCustomAction.Execute`/`Update` (`Vcl.ActnList`) → `SendAppMessage(CM_ACTIONEXECUTE/CM_ACTIONUPDATE, 0,
  LPARAM(Self))` (`Vcl.Controls.SendAppMessage` = `SendMessage(Application.Handle, ...)`). Esse caminho vale
  para botão de toolbar, item de menu com `Action` e atalho de teclado, e também para o `TApplication.Idle`
  da DLL, que roda nos laços modais dela;
- `CM_APPKEYDOWN` e `CM_APPSYSCOMMAND` (atalhos e Alt+tecla dos forms da DLL): esses chegavam à IDE e
  podiam disparar atalhos e o menu **da própria IDE**.

A VCL da IDE (outra versão, `vcl170` no XE3) recebia um `TBasicAction` da VCL da DLL e chamava métodos e
campos com outro layout, o que dava o AV. No Delphi 13 o layout é igual, então funcionava por acaso. O erro
existe em qualquer versão.

**Correção.**
- `JVCSForms.JVCSCreateOwnAppWindow`: cria uma janela própria da DLL (classe `TJVCSDllApplication`,
  `hInstance` da DLL, oculta, `WS_EX_TOOLWINDOW`), e `Application.Handle` passa a ser essa janela.
  - O `WndProc` dela trata `CM_ACTIONEXECUTE`/`CM_ACTIONUPDATE` com a VCL da DLL, com o mesmo despacho de
    `TApplication.DispatchAction`: form ativo, depois `MainForm`, depois `DisableIfNoHandler`.
  - Ignora `CM_APPKEYDOWN`/`CM_APPSYSCOMMAND` (a DLL não tem `MainForm`).
  - O resto vai para `DefWindowProc`. Uma exceção nesse `WndProc` vai para `Application.HandleException`
    da DLL.
- A dona dessa janela é a `TAppBuilder` (§4A.3), e `JEDIVCSDLLFINALIZE` (e a `finalization` da unit) a
  destrói e zera `Application.Handle` antes do `FreeLibrary`.
- `JVCSDLLLineHistoryFrame.AddLineHistoryControl` não troca mais `Application.Handle` pelo handle recebido
  quando a janela própria existe.
- Nenhum outro ponto da DLL manda `SendMessage`/`PostMessage` com ponteiro de objeto para janela da IDE.
  Foram revisados os `MessageBox`/`ShellExecute(Application.Handle, ...)`: só usam o handle como dono.
  `ProjAdmin.pas` mexe em `Application.Handle` só fora da DLL (`{$IFNDEF IDEDLL}`).

**Regra (vale para mudanças futuras).** Dentro da IDE, a DLL nunca entrega a uma janela da IDE uma mensagem
que carregue ponteiro de objeto da VCL/RTL da DLL. A VCL da IDE é outra, mesmo quando a versão coincide.
`Application.Handle`, `MainForm` e `PopupParent` da DLL só podem ser janelas da DLL. A relação com a IDE é
feita só por dono de janela (`WndParent`/`GW_OWNER`), que o Windows trata sem passar pela VCL.

**Teste no host interativo** (`testar-dll-interativo.bat`, novas opções `-login 1`, `-click`, `-menu`,
`-closemodal`). A Fake IDE agora responde `IOTAServices.GetParentHandle` com uma janela do host, como a IDE
faz. Sem isso, a DLL antiga ficava com `Application.Handle = 0`, e o host não reproduzia o problema. O host
conta as `CM_ACTIONEXECUTE`/`CM_ACTIONUPDATE`/`CM_APPKEYDOWN`/`CM_APPSYSCOMMAND` que chegam às janelas
dele, e o resultado tem que ser **zero**. Ele também confere que a janela de `Application.Handle` da DLL é
`TJVCSDllApplication`, com `hInstance` da DLL, do mesmo thread, oculta e diferente da do host. Clica em
botões da toolbar e em itens de menu do Project Manager e fecha sozinho os modais (Cancelar/Não/`WM_CLOSE`),
conferindo os donos com o modal aberto (`TApplication.Idle` da DLL rodando). Confere também a raiz dos
donos (`GA_ROOTOWNER`) = Fake IDE e a ausência de `WS_EX_APPWINDOW`. Exemplo:

```
testar-dll-interativo.bat -project C:\...\Ex1\exemplo01.dpr -login 1 -verbs "Connect Server,Project Manager" ^
  -click "ToolButton28,ToolButton38,ToolButton20" -menu "Refresh1,mmiWhoami" -timeout 2 -wait 5000
```

**Resultados (13/10/2026, DLL Release Win32).** Login com a identidade atual e a senha salva, sem mudar
`HKCU\Software\JEDI\JEDIVCS\Identities` (o `reg export` antes e depois tem o mesmo SHA-256). Project
Manager com `exemplo01.dpr`. Cliques em Refresh (`ToolButton28`), Synchronize (`ToolButton38`), Whoami
(`ToolButton20`) e nos menus `Refresh1`/`mmiWhoami`. Os modais abertos (DSA "Information", `TVCSSync`,
`TVCSWhoami`) foram fechados sozinhos.

| DLL | CM_* na janela do host | Falhas de checagem | AVs |
|---|---|---|---|
| **Antiga** (com `Application.Handle := GetParentHandle`) | `CM_ACTIONUPDATE` = **3** (Idle e laço modal do Synchronize) | 6 | 0 (VCL do host = mesma versão) |
| **Corrigida** | **0** | **0** | **0** |

Na corrigida:
- `Application.Handle` da DLL é `TJVCSDllApplication`, oculta, com dona = Fake IDE;
- login, Project Manager, Synchronize e Whoami têm dono direto = `TAppBuilder`;
- o DSA e os `MessageBox` têm dono = `TJVCSDllApplication`, e a raiz da cadeia de donos é a Fake IDE;
- nenhuma janela tem `WS_EX_APPWINDOW`;
- depois do `FreeLibrary` a janela própria não existe mais.

`testar-dll.bat ambas`: fails=0, 0 AV (nova e original); `testar-expert.bat`: fails=0.

**Pendente na IDE real (usuário, XE3):** repetir o clique na toolbar (Synchronize/Get) e o Get do diálogo
Revisions com o arquivo aberto no editor. Atalhos e itens de menu com `Action` passam pelo mesmo caminho.

### 4A.4 Barra de status "Not connected"

O painel 4 do Project Manager mostra o servidor quando `AppSrvClientConnected` (evento de sessão do
socket). Na IDE ele mostrava "Not connected" com o projeto listado. Agora mostra o host também quando há
login (`ServerUserID > 0`). Não é o painel da notificação (`JVCS_NOTIFY` desligado escreve só na janela
de mensagens: "Internal Notify ... not active").

### 4A.5 Controle de erros

- Log: `%LOCALAPPDATA%\JEDI\JVCS\logs\jvcs-dll-AAAAMMDD.log` (e `jvcs-exe-...` para o standalone). Uma linha
  por evento: data/hora, pid, módulo e versão, onde, classe e mensagem, endereço (módulo+offset) e
  unit/rotina/linha quando o `JvcsExternalDll.map` está ao lado da DLL (`compilar-expert.bat` copia).
  Nunca grava senha. Para enviar: anexe o arquivo do dia (e o `JVCS_EXPERT_LOG`, se ligado).
- `Application.OnException` da VCL da DLL: registra e mostra **uma** mensagem por vez (sem cascata).
- Todas as entradas exportadas chamadas pelo expert (`GetIDString`, `ExecuteVerb`, `GetMenuName`,
  `GetVerb*`, `ProjectChange`, `FileNotification`, `EventNotification`, `JEDIVCSDLLINIT`,
  `JEDIVCSDLLFINALIZE`) têm `try/except`: nada atravessa a fronteira da DLL. O FINALIZE só registra
  (sem mensagem) e escreve "JEDIVCSDLLFINALIZE concluido". O `HandleException` antigo (que repassa a
  mensagem ao expert) também registra no log.
- Causa real encontrada: diálogos DSA reentrantes (`EJvDSADialog: CheckMarkText ID 99 already
  registered`), por exemplo um `TTimer` (login, `UpdateTimer`/`RefreshTimer` do Project Manager) abrindo
  um segundo diálogo enquanto outro estava aberto; corrigido em `JVCSDialogs` (ID livre por uso). É o
  candidato mais provável aos "erros ao fechar o Project Manager" relatados; o fechamento com projeto
  aberto pela IDE não foi reproduzido fora dela (o host não tem projeto da IDE). O log vai mostrar o
  resto.

### 4A.5b Correções de 13/10/2026 (mesmas fontes do EXE)

Detalhes em [Port-Standalone.md](Port-Standalone.md) §4.4:
- **Lentidão ao abrir o projeto** (~20 s com 4 módulos): o Project Manager copiava todos os ícones da
  lista de imagens do sistema do processo (`bds.exe`) até o índice de cada arquivo; agora copia só o
  ícone usado. Host com 306 ícones pré-carregados: laço local 209 ms → 49 ms.
- **Senha da identidade**: o Connect não grava mais senha vazia; o checkbox "Store Password with
  identity" reflete a identidade selecionada.
- **Aparência**: valores de outro tipo no registro não derrubam mais a DLL; `JVCSClientAppearanceInit`
  em `try/except` com log.
- **View → Appearance / Font Size...** também no Project Manager da DLL.

### 4A.5c 3ª etapa do EXE (13/10/2026, mesmas fontes)

Valem para a DLL (detalhes em [Port-Standalone.md](Port-Standalone.md) §5): tema escuro legível (árvore,
listas, ícones e glifos), `IsTextStream`/`IsBinaryDFMStream` Unicode (Compare all, Line History, Compressed
Diff, KWExpansion), AV do `DiffUnit` no Line History, DSA reentrante pelo nome, Backup com senha
(Cancelar), Used Units (nomes com ponto), ExtBugtracker com `TRegEx`, JVCL simples → VCL e tamanho mínimo
dos forms depois do `OnShow`/`OnActivate`. `compilar-expert.bat Release nova` atualizou
`bin\ideclient\Win32` (DLL Release) e `testar-dll.bat ambas` deu 21 ok, 0 falhas, 0 AV (nova e
original). Não testado na DLL: varredura de forms (o modo `-formsweep` é do EXE) e o scan de ToDo.
Observação: o `compilar-expert.bat` copia para `bin\ideclient\Win32` o `jedivcsdiff.exe` do 2.5.0.1030
(`3rdparty\referencia-2.5.0.1030`), não o Diff portado.

### 4A.5d Login e aviso "sem projeto" ao mesmo tempo (13/10/2026)

Sintoma (Delphi 11, sem projeto aberto): ao abrir o login pelo menu JEDI VCS apareciam juntos o "Server Login"
e o aviso "IDE returns no active IDE project. JEDI VCS's functionality will be only partly available."
(com "Don't show this message again"); o login ficava bloqueado até fechar o aviso. Causa: o aviso era
mostrado em `TVCSLoad.FormActivate` (`Create.pas`), isto é, com o login já na tela e modal, e voltava a cada
reativação do form. Correção: `TVCSLoad.CheckIDEProject(AWarn)` (só `IDEDLL`) lê o projeto da IDE e, com
`AWarn`, mostra o aviso; `TJVCSClient.DoOpen` (`JediVCSDLL.dpr`) chama `CheckIDEProject(True)` **antes** do
`ShowModal`, e o `FormActivate` só atualiza `sProjectName`/`bProjectOpen` (`CheckIDEProject(False)`).
Conferido no host interativo (`testar-dll-interativo.bat -verbs "Connect Server"`, sem `-project`) com
captura das janelas do processo: primeiro só o `TDSAMessageForm` "Warning" (Fake IDE desabilitada, nenhum
`TVCSLoad`); depois de fechá-lo, só o "Server Login"; 0 AV, 0 exceção Delphi.

### 4A.6 Host interativo

```
src\jvcsideexpert\tests\testar-dll-interativo.bat -verbs "Connect Server,Project Manager" -stop %TEMP%\jvcs-stop.txt
src\jvcsideexpert\tests\testar-dll-interativo.bat -style "C:\Program Files (x86)\Embarcadero\Studio\37.0\Redist\styles\vcl\WindowsModernDark.vsf" -verbs "Project Manager"
```

`-project <arquivo.dpr>` faz a callback `GetProjectName` devolver um projeto (o Project Manager abre o
projeto como na IDE) e `-primeicons <n>` enche a lista de ícones do sistema do processo antes de carregar
a DLL (simula a IDE já aberta). Ex.:
`testar-dll-interativo.bat -project C:\...\Ex1\exemplo01.dpr -primeicons 600 -verbs "Connect Server,Project Manager"`.

Mesmo bridge e callbacks do harness, com uma janela "Fake IDE" da classe `TAppBuilder`, VCL Style
opcional no host (simula o tema da IDE), sem fechar janelas sozinho; o FINALIZE + `FreeLibrary` acontece
quando o arquivo `-stop` existe ou a Fake IDE é fechada. Conta AVs e exceções Delphi de primeira
chance. `-hostmsg <texto>` mostra uma caixa de mensagem do próprio host.

Resultados (13/10/2026, DLL Debug): login com a identidade de teste `JVCS2026TEST` (127.0.0.1:2106,
apagada no fim), Project Manager aberto e fechado, FINALIZE com e sem o Project Manager aberto: 0 AV,
0 exceção Delphi; tema escuro na DLL com host escuro e com host claro; menus legíveis. Harness
`testar-dll.bat ambas`: 0 falhas, 0 AV (nova e original).

## 5. Teste na IDE (usuário)

A pasta `bin\ideclient\Win32` já está montada com o expert e a **DLL nova** (`compilar-expert.bat
Release nova`, 12/10/2026). O registro do expert é o mesmo de antes (`JVCSIDEClient`).

1. **Feche o Delphi 13.**
2. Se o expert ainda não estiver registrado: importe `setup\Delphi13-JVCS-DLL-nova.reg` (duplo
   clique). Quem já importou `setup\Delphi13-JVCS-v2026.reg` não precisa (é o mesmo valor).
3. Opcional, para o log: num prompt, `set JVCS_EXPERT_LOG=%TEMP%\jvcs-expert.log` e abra
   `"C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\bds.exe"` desse prompt.
4. Abra o Delphi 13 (**32 bits**). Help > About deve mostrar o plugin; o menu **JEDI VCS** deve ter
   27 itens (sem "Select Branch").
5. **JEDI VCS > Connect Server…**: escolha a identidade do servidor de teste (127.0.0.1:2106,
   `sysdba`) e conecte. Use uma identidade própria de teste (ex.: `JVCS2026TEST`) se for mudar
   Host/Port: o Connect grava Host/Port na identidade selecionada.
6. Abra o projeto Exemplo01 (Ex1) já cadastrado. O **Project Manager** do JVCS deve listar os 4
   módulos.
7. Abra `uPrincipal.pas`, **Check Out** (Ctrl+Shift+O), altere um comentário (com acentos),
   salve e **Check In** (Ctrl+Shift+I) com comentário acentuado. Confira a nova revisão na aba
   **History** da unit e no `Module History` do JVCS.
8. Feche o projeto e a IDE: sem AV nem travamento. No log devem aparecer `JEDIVCSDLLINIT = True`,
   `JvcsExternalDll carregada: …bin\ideclient\Win32\JvcsExternalDll.dll` e, no fim,
   `JvcsExternalDll descarregada`.

9. **Aparência e janelas (13/10/2026)**, com a IDE em tema **Dark** e depois **Light**:
   - os submenus do Project Manager (Server, Project, Module...) e os popups mostram o texto (sem ícones);
   - VCS Properties → **Appearance**: *Follow Delphi* deixa as janelas do JEDI VCS escuras com a IDE escura
     (vale na próxima janela aberta depois de trocar o tema); *Light*/*Dark* fixam; a escala 125/150%
     aumenta as janelas do JEDI VCS e **não** muda menus, diálogos ou o editor da IDE;
   - com o Project Manager aberto, Alt+Tab para outro programa e volte: o Project Manager volta junto,
     na frente da IDE; ele não aparece como botão separado na barra de tarefas;
   - a barra de status mostra o servidor (não "Not connected") depois do login;
   - feche o Project Manager (com e sem módulo selecionado) e depois a IDE; se aparecer erro, a mensagem
     indica o log `%LOCALAPPDATA%\JEDI\JVCS\logs\jvcs-dll-AAAAMMDD.log`: envie o arquivo.
10. VCS Properties → **AI / Automation** mostra os modos atuais do `config.ini` (nesta máquina, Automatic
    nos dois); trocar e confirmar com `tools\ai\jvcs-ai.ps1 config list -Text` (e voltar ao modo desejado).
11. **Correções de 13/10/2026** (DLL nova copiada para `bin\ideclient\Win32` às 08:27):
    - abrir o Exemplo01 no Project Manager: na janela Messages, `Local: (File size & attributes)` e
      `Server request: (Modules without revision …)` devem ter tempos quase iguais (antes: +21 s);
    - Connect com a DEFAULT e depois trocar de identidade no login e voltar: a senha da DEFAULT continua
      salva (`tools\ai\jvcs-ai.ps1 identity -Text` mostra `hasPassword=True`); o checkbox "Store Password
      with identity" aparece marcado nas identidades com senha salva;
    - Project Manager → **View → Appearance / Font Size...** abre o VCS Properties na página Appearance;
      a 150% as páginas User Interface, Appearance e AI / Automation não cortam rótulos.

Para voltar à DLL original: feche o Delphi e rode `tools\compilar-expert.bat Release original`.

## 5A. Expert em todas as atualizações do Delphi (11.x, 12.x, 13.x) — 13/10/2026

**Problema.** O `JvcsExpertBDS37.dll` compilado no 13.2 não carregou num Delphi 13.1: "Could not find
Wizard ..." no splash e, do Windows, "ponto de entrada `@Ideeditorcontrolbridge@initialization$qqrv` não
encontrado" (erro 127 do `LoadLibrary`). O expert usa runtime packages; com pacotes, **toda unit de pacote que
entra no grafo de `uses`** (direta ou indiretamente) gera um import, por nome, da sua `initialization`. O
`ToolsAPI.pas` usa `DockForm` (designide), e o grafo do `DockForm` ganhou no 13.2 a unit `IdeEditorControlBridge`,
que não existe no `designide370.bpl` do 13.1. Um `library` de teste só com `uses ToolsAPI` já reproduz.

**Correção (a partir de `c1d0ddc`).**

| | Antes | Depois |
|---|---|---|
| Pacotes importados | `rtl`, `vcl`, `designide`, `vclactnband`, `vclimg`, `vclwinx`, `xmlrtl` (7) | `rtl`, `vcl`, `xmlrtl` (3) |
| Símbolos importados dos `.bpl` (13.2) | 599 (com `TList<T>`) → 560 | 429 (11.3: 420) |
| Units do designide com `initialization` importada | 18 (`DockForm`, `IdeEditorControlBridge`, `DesignEditors`...) | 0 |

- `tools\gerar-toolsapi.ps1` gera, na hora do build, `JvcsToolsAPI.pas` e `JvcsFileHistoryAPI.pas` a partir do
  `source\ToolsAPI` **da instalação de quem compila**, sem `DockForm` (`TDockableForm = TForm`; o expert não usa
  essas funções). Mesmas interfaces, GUIDs e ordem de métodos (vtable idêntica). Gravado só em
  `dcu[\D11|D12]\Win32\expert\toolsapi` — nada da Embarcadero vai para o git.
- `tools\compilar-expert.bat` e `JvcsExpertBDS.dproj` usam unit alias `ToolsAPI=JvcsToolsAPI`,
  `FileHistoryAPI=JvcsFileHistoryAPI`; o fonte do expert continua com `uses ToolsAPI`. O `designide` fica no `-LU`
  só para `DesignIntf` (sem import em tempo de execução).
- `SplashScreenServices` é variável global da ToolsAPI que a IDE preenche na cópia dela; o expert lê
  `@Toolsapi@SplashScreenServices` por `GetProcAddress` no `designide<nn>.bpl` (sem import estático).
  `BorlandIDEServices` já vinha do parâmetro de `InitWizard`.
- `JVCSExpertWizard`: `TList<TMenuItem>`/`TList<TAction>` viraram arrays dinâmicos (os genéricos importavam
  `TListHelper` do `rtl<nn>.bpl`, interno e sujeito a mudança).
- Validação: `src\jvcsideexpert\tests\testar-expert.bat` (host com a ToolsAPI **real** do designide carregando o
  expert com a cópia: menus, ações, notificações, ABI) e `testar-dll.bat ambas` sem falhas no 13.2; expert do
  11.3 compilado e conferido (`JvcsExpertBDS22.dll`).

**Ferramenta.** `tools\verificar-expert.ps1` lê os imports (normais e delay-load) do expert e as exportações dos
`.bpl` com um leitor de PE próprio e lista o que falta — a mesma resolução que o `LoadLibrary` faz:

```
powershell -NoProfile -ExecutionPolicy Bypass -File tools\verificar-expert.ps1 ^
  -Expert bin\ideclient\Win32\JvcsExpertBDS37.dll -BplDir D:\Delphi\JediVCS\ref-bpl\13.1 -Inits -Permitidos rtl,vcl,xmlrtl
```

Sem `-BplDir` usa `Studio\<v>\bin` e `Public\Documents\...\Bpl` da versão do nome do expert. `-Inits` lista as
units cuja `initialization` é importada; `-Permitidos` reprova outros pacotes. Código 0 = carrega; 1 = não.
O `compilar-expert.bat` roda essa conferência a cada build (contra os `.bpl` da própria instalação) e o
`gerar-instalador.bat` confere todos os experts antes do ISCC.

**Política de build (vale para 11, 12 e 13).**

1. O expert só pode importar `rtl<nn>`, `vcl<nn>` e `xmlrtl<nn>` — nada de design-time (`designide`,
   `vclactnband`, `vclimg`, `vclwinx`...). Funcionalidade nova vai para a `JvcsExternalDll.dll`
   (autocontida, sem pacotes), não para o expert.
2. Sem genéricos da RTL no expert (`TList<T>`, `TDictionary<K,V>`...): use arrays dinâmicos ou `TList` clássico.
3. Preferência: compilar cada `JvcsExpertBDS<nn>.dll` na **atualização mais antiga suportada** daquela versão
   (13.0, 12.0, 11.0) — a Embarcadero só acrescenta exports em updates. Como esta máquina tem o 13.2 e o 11.3,
   a garantia vem do item 4.
4. Antes de publicar: `verificar-expert.ps1 -BplDir <.bpl de cada atualização suportada>` com 0 ausentes.
   Guarde os `.bpl` de referência (`rtl`, `vcl`, `xmlrtl`) de cada update em `D:\Delphi\JediVCS\ref-bpl\<versão>`
   (fora do git; são binários da Embarcadero). Pendente: `.bpl` do 13.0/13.1 (remoto), 12.x e 11.0–11.2.
5. As units de RTL/VCL que restam com `initialization` importada (`System.*`, `Vcl.Forms`, `Vcl.Menus`...)
   existem desde sempre; exceção a conferir com os `.bpl` do 13.0/13.1: `Winapi.Msctf.Pkghelper` e
   `Winapi.Windows.Pkghelper` (aparecem no 13.2, não no 11.3).

**IDE de 64 bits.** O Delphi 12.3 e o 13 trazem também `bin64\bds.exe`, que guarda à parte as listas de experts
e pacotes: `HKCU\Software\Embarcadero\BDS\<v>\Experts x64`, `Known Packages x64`, `Known IDE Packages x64`
(conferido no registro do 37.0 desta máquina; valor `App x64` aponta para `bin64\bds.exe`). Uma DLL de 32 bits
não carrega na IDE de 64 bits (erro 193), então o expert é registrado **só** em `Experts` e o instalador remove
um `JVCSIDEClient` nosso que esteja em `Experts x64`. Expert Win64 (futuro): a `JvcsExternalDll.dll` e a
`fvcscrypt.dll` são 32 bits e não carregam num processo de 64 bits; seria preciso um expert Win64 fino que fale
com o núcleo **fora do processo** (o caminho previsto no ADR-001: console/serviço local 32 bits por IPC), ou portar
a DLL para Win64 com um substituto da `fvcscrypt.dll`. Recomendação: manter o expert 32 bits (a IDE de 32 bits
continua sendo a principal no 12.3/13) e tratar o Win64 junto com a separação núcleo/IDE do ADR-001.

## 5B. IDEs antigas: expert original + núcleo novo (13/10/2026)

**Ideia.** O expert novo (`src\jvcsideexpert`) só é compilado para Delphi 11, 12 e 13. Para as IDEs que o
2.5.0.1030 suportava (Delphi 7 e BDS 1.0 a 21.0), o instalador reaproveita os **experts originais**. São
binários finos que só fazem a ponte com a ToolsAPI (análise em [Expert-IDE-Analise.md](Expert-IDE-Analise.md)),
e eles carregam a `JvcsExternalDll.dll` **nova** no lugar da antiga. Isso funciona porque a DLL nova
mantém a ABI da original:

- os mesmos 4 exports, por nome: `JEDIVCSDLLINIT`, `JEDIVCSDLLFINALIZE`, `JEDIVCSDLLHISTORYINIT` e
  `JEDIVCSDLLOPERATIONINIT` (conferidos com `tdump -ee` na DLL do pacote);
- registros de 24/10/2/9/10 ponteiros, `stdcall`, `PAnsiChar` e buffers alocados por quem chama;
- nenhum ShareMem: cada lado tem seu gerenciador de memória, e nada gerenciado atravessa a fronteira.

**Risco: mensagens que cruzam as VCLs.** A ABI de exports e callbacks não é o único canal entre a DLL e a
IDE. As mensagens de janela também são. Quando uma mensagem da DLL chega a uma janela da IDE, a VCL da IDE
a processa, e com o expert original a IDE tem **outra versão** de VCL (ex.: `vcl170` no XE3). Qualquer
mensagem que leve ponteiro de objeto VCL/RTL vira AV ou corrupção de memória.

Foi o caso de `CM_ACTIONEXECUTE`/`CM_ACTIONUPDATE`. Com `Application.Handle` = janela do `TApplication` da
IDE, o XE3 dava AV na toolbar do Project Manager e no Get do diálogo Revisions (§4A.7). A correção:
`Application.Handle` é uma janela própria da DLL.

Regra: nada de `Application.Handle`, `MainForm`, `PopupParent` ou `SendMessage`/`PostMessage` com
`LPARAM` de objeto apontando para janela da IDE. A relação com a IDE é só por dono de janela (`GW_OWNER`).

O expert original procura a DLL só na própria pasta (`JvcsExternalDll.dll`, `jedivcsexternaldll.dll`,
`jedivcsdll.dll`) e não confere a versão dela.

**Mapeamento confirmado** por dois caminhos: os pacotes importados de cada DLL (sufixo de
`designide<nn>.bpl`) e o `unins000.dat` do instalador original (componentes `\BDS1`…`\BDS21`, chaves
`...\Experts`, valor `JVCSIDEClient`). A tabela completa, com os SHA-256, está em
`3rdparty\experts-originais-2.5.0.1030\LEIAME.md`.

| Arquivo | Pacotes | IDE | Chave HKCU (`JVCSIDEClient`) |
|---|---|---|---|
| `JvcsExpertD7.dll` | …70 | Delphi 7 | `Software\Borland\Delphi\7.0\Experts` |
| `JvcsExpertBDS1.dll` / `BDS2` | …71 | C#Builder 1.0 / Delphi 8 for .NET | `Software\Borland\BDS\1.0` / `2.0\Experts` |
| `JvcsExpertBDS3.dll` | …90 | Delphi 2005 | `Software\Borland\BDS\3.0\Experts` |
| `JvcsExpertBDS4.dll` / `BDS5` | …100 | 2006 / 2007 | `Software\Borland\BDS\4.0` / `5.0\Experts` |
| `JvcsExpertBDS6.dll` / `BDS7` | …120 / …140 | 2009 / 2010 | `Software\CodeGear\BDS\6.0` / `7.0\Experts` |
| `JvcsExpertBDS8.dll` … `BDS12` | …150 … …190 | XE … XE5 | `Software\Embarcadero\BDS\8.0` … `12.0\Experts` |
| `JvcsExpertBDS14.dll` … `BDS21` | …200 … …270 | XE6 … 10.4 Sydney | `Software\Embarcadero\BDS\14.0` … `21.0\Experts` (não há 13) |

Ficaram **de fora** os `JvcsVcsManagerD5/D6.dll`. Cada um é o cliente 2.5.0.1030 inteiro para
D5/D6/BCB5/BCB6 (interface `VCSIntf`, `INITVCS0014`, com `borlndmm.dll`) e não usa a
`JvcsExternalDll.dll`.

**Instalador.** O componente "IDEs antigas" tem um subcomponente por IDE detectada. Para cada IDE
marcada, ele copia o expert original e o registra, guardando o valor anterior e restaurando esse valor
na desinstalação. O detalhamento está em `setup\LEIAME.md`, seção 4A.

**Testes feitos (sem IDE):**

- instalação, reinstalação e desinstalação silenciosas com chaves falsas de XE3, 10.4, 2007 e Delphi 7
  (`setup\LEIAME.md` 6.1, 43 verificações, 0 falhas, com o registro real do Delphi intacto);
- `src\jvcsideexpert\tests\testar-dll.bat nova`: o harness percorre toda a sequência da ABI com a DLL
  do pacote (a de `bin\client` é igual à de `bin\ideclient`). Resultado: init, 27 verbos, imagens,
  notificações, `ExecuteVerb` de Connect/Project Manager/Properties/Recent/About, operação sem conexão,
  `FINALIZE` + `FreeLibrary` com **0 access violations**, `fails=0`.

O harness usa a ponte do expert **novo**, não o binário do expert original. Esse binário só carrega
dentro da IDE dele, porque precisa de `designide<nn>.bpl`.

**Suporte por versão:**

| IDE | Status |
|---|---|
| Delphi 7, 2007, XE3, 10.4 | instalador testado com chaves falsas; **IDE real não testada** |
| C#Builder 1, Delphi 8, 2005, 2006, 2009, 2010, XE, XE2, XE4–XE8, 10–10.3 | mesmo código do instalador, não exercitado; **IDE real não testada** |

**Teste pendente na IDE real (usuário; XE3 em outro PC):**

1. Feche o XE3, instale o setup e confira:
   - `{app}\JvcsExpertBDS10.dll` existe;
   - `HKCU\Software\Embarcadero\BDS\10.0\Experts\JVCSIDEClient` aponta para ele.
2. Abra o XE3 e confira:
   - o splash e o About com "JEDI VCS";
   - o menu **JEDI VCS** com os 27 verbos e as imagens;
   - nenhum erro "Could not find Wizard".
3. Teste as operações:
   - Connect Server: login no servidor e versão 250 no `LOGIN`;
   - abrir um `.dproj`: o Project Manager do JEDI VCS mostra o `.dpr`;
   - Check In, Check Out e Get de um arquivo de teste;
   - Compare/Diff (`JEDIVCSDiff.exe` novo);
   - aba **History** do editor;
   - menu de contexto JEDI VCS no Project Manager da IDE.
4. Confira os acentos:
   - num comentário com acento no fonte, com a expansão de keywords ligada;
   - num caminho com acento.
5. Feche o XE3 com e sem sessão aberta e confira que não há access violation no fechamento.
6. Desinstale e confira que o `JVCSIDEClient` anterior, se havia, voltou.
7. Se possível, repita em um BDS ≤ 5 (2007) e no Delphi 7. Esses experts ANSI usam `LoadLibraryA` e
   têm menos recursos (D7: sem History nem menu do Project Manager).

Riscos a observar:

- a DLL nova (VCL do Delphi 13, 18 MB) dentro de uma IDE antiga que não é DPI-aware: tamanho e posição
  das janelas;
- `SourceReadString`/`SourceWriteString` com UTF-8 cru vindo do expert original (itens 3.7-5 da
  análise; o expert novo converte e o original não);
- falta do tema (`JVCS_IDE_THEME`, que só o expert novo define).

## 6. Pendências

- **Teste na IDE** (seção 5), incluindo History, menu do Project Manager, Compare/Diff, fechamento com
  e sem sessão, e conferir o LOGIN 250 no fio (proxy `tools\golden\console\proxy.ps1`).
- Verbos: a nova tem 27 e a original 29. As ações do expert se chamam `JEDIVCS_A<índice>`; um atalho
  **personalizado na IDE** para um verbo depois do índice 0 muda de verbo ao trocar de DLL (os atalhos
  padrão vêm da DLL e não mudam).
- `JVCSIDESettings` sem BDS 22/23/37 (`IDEUnknown`, tratado como Delphi); `UsedUnits`, `ToDo`,
  `VerSet`, `Recent` e `UsedComponents` com caminhos e chaves do Delphi 7 (plano 5.3/5.4) não foram
  revistos.
- `JVCSIDEInterface` ainda tem o ramo `INTERNAL_OLDOTA` (não compilado); `JVCSDLLLineHistoryFrame` não
  entra (`LINEHISTORYFRAMEEXPORT` nunca definido).
- Finalização: `DllEntry(DLL_PROCESS_DETACH)` ainda chama `JediVCSDLLFinalize` se o expert não chamou
  (sob o loader lock). O expert novo sempre chama o `FINALIZE` antes do `FreeLibrary`.
- `.dproj` da DLL, builds D11/D12, Win64 (F6) e setup Inno (5.6).
- ~~Opções de fonte/tema/aba IA na DLL~~: feitas (seção 4A). Faltam: troca de tema da IDE em tempo real
  (precisa de notificação nova do expert, `IOTAIDEThemingServicesNotifier`, e de verbo/ABI nova), item
  "JEDI VCS → Tamanho da fonte..." no expert, ícones nos menus dentro da IDE (hbmpItem a partir da
  ImageList), reproduzir o fechamento do Project Manager com projeto aberto pela IDE.
- ~~Lentidão ao abrir projeto~~ (21–24 s antes de `Modules without revision`): era o laço local do
  `FillListView`, copiando todos os ícones da lista do sistema do `bds.exe`; corrigido em 13/10/2026
  (Port-Standalone.md §4.4). **Conferir na IDE** com o log de DEBUG (`FillListView laco local: …`) ou
  pelas mensagens do Project Manager.
