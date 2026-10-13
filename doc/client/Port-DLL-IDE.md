# Port da DLL da IDE `JvcsExternalDll.dll` para Delphi 13.2 (F5)

Estado em **12/10/2026**. A DLL do cliente para a IDE (`src\jedivcs\JediVCSDLL.dpr`, as mesmas fontes
do `Jedivcs.exe` portado na F4) compila no Delphi 13.2 Win32 (Debug e Release, 0 erros) e gera
`bin\client\Win32\JvcsExternalDll.dll`. Ela substitui a `JvcsExternalDll.dll` 2.5.0.1030 (Delphi 2007)
atrás do expert novo `src\jvcsideexpert` (`JvcsExpertBDS37.dll`), com a mesma ABI.

O harness fora da IDE passou com a DLL nova e com a original (mesma sequência do expert, sem access
violation). **Ainda falta o teste dentro da IDE** (roteiro na seção 5).

Referências: [Plano-de-Port.md](../common/Plano-de-Port.md) (F5),
[Port-Standalone.md](Port-Standalone.md) (port do EXE), [Expert-IDE-Analise.md](Expert-IDE-Analise.md)
(ABI e callbacks), [`src\jvcsideexpert\LEIAME.md`](../../src/jvcsideexpert/LEIAME.md).

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
aparecem na barra de tarefas. `Application.Handle` não muda (ele é usado em `MessageBox` e por
`Application.Title/Icon`, que mexeriam na janela da IDE). Diálogos modais continuam com dono = form ativo.
Conferido no host interativo: `GetWindow(GW_OWNER)` do login, do Project Manager e do VCS Properties =
`TAppBuilder`.

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
