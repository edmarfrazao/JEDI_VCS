# JEDI VCS IDE Expert v2026 (`JvcsExpertBDSnn.dll`)

Expert de IDE (wizard DLL, export `INITWIZARD0001`) para **Delphi 13.2 Florence (BDS 37.0), IDE de
32 bits** (`Studio\37.0\bin\bds.exe`). O mesmo fonte também compila para Delphi 11 (BDS 22) e 12
(BDS 23), mas só o Delphi 13 foi testado.

Ele substitui o `JvcsExpertBDS21.dll` (Delphi 10.4) e carrega a **`JvcsExternalDll.dll` ORIGINAL**
do JEDI VCS 2.5.0.1030 (Delphi 2007, ANSI). Assim o cliente JEDI VCS completo passa a funcionar dentro
do Delphi 13, falando com o servidor 2.5 Beta 3, antes do port do cliente.

O comportamento do expert original foi obtido por engenharia reversa estática, documentada em
[`doc\client\Expert-IDE-Analise.md`](../../doc/client/Expert-IDE-Analise.md). As referências como
"3.4" e "6.3" neste texto e nos fontes apontam para seções desse documento.

## Arquivos

| Arquivo | Papel |
|---|---|
| `JvcsExpertBDS.dpr` | `library`; exporta `InitWizard` como `INITWIZARD0001` (`WizardEntryPoint`). `$LIBSUFFIX` por `CompilerVersion` gera `JvcsExpertBDS37.dll`, `…BDS23.dll` ou `…BDS22.dll` |
| `JvcsExpertBDS_ver.rc` | VERSIONINFO. O dcc32 não compila `.rc`: o script gera o `.res` em `dcu\Win32\expert` |
| `JVCSExpertABI.pas` | Cópia fiel dos tipos e records de `src\common\JVCSIDEInterfaceCommon.pas` (ver "ABI") |
| `JVCSExpertUtils.pas` | Log, conversões ANSI/UTF-8, cópia limitada para buffers, guarda de fronteira (FPU e DPI), helpers de ToolsAPI |
| `JVCSExpertCallbacks.pas` | As 24 callbacks `stdcall` de `TExternalIDEFunctionRec` (DLL → IDE) |
| `JVCSExpertDllBridge.pas` | Localiza, carrega, inicializa e finaliza a DLL; wrappers protegidos de todas as funções da DLL (IDE → DLL) |
| `JVCSExpertNotifiers.pas` | `IOTAIDENotifier`/`50`/`80` → `ifn*`/`ien*`; `IOTAModuleNotifier` de fechamento de projeto |
| `JVCSExpertHistory.pas` | `IOTAFileHistoryProvider` "JEDI VCS File History Provider" (aba History) |
| `JVCSExpertProjMenu.pas` | Menu de contexto do Project Manager (`IOTAProjectMenuItemCreatorNotifier`) |
| `JVCSExpertWizard.pas` | `TJVCSWizard` (`IOTAWizard`): menu, ações, imagens, atalhos, splash/About, `InitWizard`/`FinalizeWizard` |
| `tests\` | Teste de fumaça **fora da IDE**, com uma `JvcsExternalDll` falsa, e conferência independente da ABI contra a unit original (`JvcsAbiCrossCheck.pas` + includes vazios em `tests\abi-stub`). Ver "Teste de fumaça" |
| `..\..\tools\compilar-expert.bat` | Compila e monta a pasta `bin\ideclient\Win32` |

## Arquitetura

```
 IDE (bds.exe 32 bits, ToolsAPI)                expert (JvcsExpertBDS37.dll,          JvcsExternalDll.dll
                                                runtime packages rtl/vcl/designide)   (Delphi 2007, VCL própria,
                                                                                       sem ShareMem)
 INITWIZARD0001 ───────────────────────────────► InitWizard
                                                 TJVCSWizard.Create
                                                   TJVCSDllBridge.Load ─ LoadLibraryEx(pasta do expert)
                                                     JEDIVCSDLLINIT(@IDE,@VCS,@Notif) ─────► preenche VCS (10) e Notifier (2)
                                                     JEDIVCSDLLHISTORYINIT(@History) ──────► preenche 9 funções
                                                     JEDIVCSDLLOPERATIONINIT(@Oper) ───────► preenche 10 funções
                                                   History provider, imagens, menu,
                                                   ações, IOTAIDENotifier, key binding,
                                                   menu do Project Manager
 menu/atalho/notificação ──────────────────────► wrappers do bridge ──────────────────────► ExecuteVerb, FileNotification…
 IOTAActionServices, IOTAModuleServices… ◄────── 24 callbacks stdcall ◄──────────────────── CloseFile, GetProjectName…
 Terminate (FinalizeWizard) ───────────────────► Shutdown: desregistra tudo, zera os
                                                 records, JEDIVCSDLLFINALIZE ──────────────► LibExit
                                                 e só então FreeLibrary
```

- Os cinco records da ABI são **campos do objeto `TJVCSDllBridge`**, com endereço estável. A DLL
  guarda o ponteiro de `TExternalIDEFunctionRec` até o `FINALIZE`.
- `TJVCSDllBridge` é instanciado uma única vez (variável `JVCSBridge`). Notifiers, History e o menu do
  Project Manager passam sempre por ele, e cada um verifica se a DLL continua carregada.
- Ciclo de vida:
  1. `InitWizard` registra o splash e o About, cria o wizard e o registra com
     `IOTAWizardServices.AddWizard`. O expert também guarda a própria referência, de modo que o
     objeto vive até o `Terminate`.
     - **INIT adiado.** Com `ShowLoad = True` em `HKCU\Software\JEDI\JEDIVCS\Options` (só leitura),
       a DLL abriria o diálogo de conexão dentro do `JEDIVCSDLLINIT`, ainda com o splash na tela.
       Nesse caso a carga da DLL e todo o registro na IDE (History, menu, notifiers, atalhos, menu
       do Project Manager) esperam a janela principal da IDE ficar visível (timer de 500 ms, dois
       ticks seguidos). Depois do INIT, a abertura do projeto ativo é reproduzida para a DLL:
       `ifnProjectOpening(.dproj)`, `ProjectChange`, `ifnProjectOpened(.dpr)` e o notifier de
       fechamento. `JVCS_EXPERT_DEFERINIT=on|off` força ou desliga o adiamento.
  2. `FinalizeWizard` (`Terminate`) chama `Shutdown` explicitamente e só depois chama `RemoveWizard`.
  3. `Shutdown` desfaz tudo, nesta ordem: key binding, menu do Project Manager, History provider,
     notifiers, menu e ações. Depois zera os records VCS, Notifier, History e Operation, chama
     `JEDIVCSDLLFINALIZE` e termina com `FreeLibrary`.
  4. Se a IDE descarregar o expert **sem** chamar o `Terminate`, a `finalization` abandona o wizard
     (vazamento intencional) em vez de destruí-lo sob o loader lock. A `JvcsExternalDll` se
     finaliza no próprio `DLL_PROCESS_DETACH`.

## ABI expert ↔ `JvcsExternalDll.dll`

Origem: `src\common\JVCSIDEInterfaceCommon.pas` (lado da DLL: `src\jedivcs\JediVCSDLL.dpr`,
`JVCSIDEInterface.pas`, `JVCSDLLOperations.pas` e `JVCSDLLFileHistoryImpl.pas`).

**Por que existe a cópia `JVCSExpertABI.pas`.** A unit original inclui `jedi.inc` e `compopt.inc`.
O `compopt.inc` força diretivas que não podem valer para o expert: `$IMAGEBASE $00400000`,
`$APPTYPE GUI`, `$MINSTACKSIZE`, `$T-` e `DEBUG`/`MEMCHECK`. A cópia mantém os mesmos layouts e tem
asserções de compilação que quebram o build se algo divergir: 24, 10, 2, 9 e 10 ponteiros, e enums,
sets e `Boolean` de 1 byte. Quem alterar uma das duas units precisa alterar a outra também.

A equivalência é conferida de forma **independente** pelo teste F (`tests\JvcsAbiCrossCheck.pas`),
que compila a unit **original** com includes vazios (`tests\abi-stub`):

- cada campo dos cinco records recebe, pelo nome, um marcador com o seu índice; o slot *k* tem de
  conter o marcador *k* no record original, na cópia e na tabela 3.4;
- atribuição campo a campo entre os records das duas units, que só compila se convenção de chamada,
  parâmetros e retorno forem idênticos;
- tamanhos e ordinais dos enums e do set, constantes `ivs*` e nomes dos exports.

| Item | Valor |
|---|---|
| Convenção | `stdcall` em todas as funções; strings `PAnsiChar` (CP_ACP, convertidas **sem "best fit"**: caractere fora da página de código vira `?`, nunca um parecido como `Ł` → `L`, que levaria a DLL a outro arquivo); `Boolean` em AL; enums e set (`TIDEInterfaceOptions`) de 1 byte; `Word` para estado e `TShortCut`; `TDateTime` por referência |
| Exports da DLL | `JEDIVCSDLLINIT` (obrigatório), `JEDIVCSDLLFINALIZE`, `JEDIVCSDLLHISTORYINIT`, `JEDIVCSDLLOPERATIONINIT` (opcionais) |
| Ordem | `INIT(@IDE, @VCS, @Notifier)` → `HISTORYINIT(@History)` → `OPERATIONINIT(@Operation)`; no fim, `FINALIZE` e depois `FreeLibrary` |
| Memória | Nada gerenciado atravessa a fronteira (sem ShareMem nem `borlndmm`). Quem chama aloca os buffers |
| Buffers que a DLL entrega ao expert | `array[0..255]` (256 bytes) em GetProjectName, GetUnitName, GetFormName, GetCurrentFile, GetModuleName, GetComponentName, GetBaseRegistryKey e GetModuleComponent. O expert copia **no máximo 255 bytes + #0**. **Caminhos** (projeto, units, forms, arquivo atual) que não cabem **não são truncados**, porque um caminho cortado é outro caminho válido para a DLL: GetProjectName e GetCurrentFile devolvem `''`, e as listas de units e forms omitem o item (o log registra). **Texto** (pacotes, componentes, chave de registro) é truncado sem cortar caractere DBCS, também com registro no log |
| Buffers que o expert entrega à DLL | A DLL faz `StrPCopy` **sem limite** do lado dela. Por isso o expert usa 4 KB em GetMenuName, GetVerb, autor, versão e label; 16 KB + folga no comentário (`AMaxCommentSize = 16384`); 128 KB em GetVerbImages; e o tamanho informado + 64 KB no conteúdo do histórico |
| `SourceReadString` | A DLL lê blocos de 2048 bytes a partir da posição 0. O expert lê o buffer inteiro do editor (UTF-8), converte para ANSI, guarda em cache por arquivo (renovado em `APos = 0` ou após 10 s) e serve fatias. As posições são posições no texto ANSI |
| `SourceWriteString` | O conteúdo ANSI é convertido para UTF-8 antes do `Insert`, e a posição ANSI é convertida para posição UTF-8. Usa `CreateUndoableWriter`, então o usuário pode desfazer |
| Exceções | Toda callback tem `try/except` e nenhuma exceção sai do expert. Toda chamada à DLL tem `try/except` **sem** `on E: Exception`, porque o objeto de exceção do Delphi 2007 é incompatível; ele é identificado pelo módulo da VMT e não é inspecionado |
| Retornos ignorados | Como no original, o `Boolean` de `INIT` só vai para o log. `HISTORYINIT` e `OPERATIONINIT` só habilitam History e o menu do Project Manager quando os ponteiros vêm preenchidos |

Callbacks (`TExternalIDEFunctionRec`), conforme 3.4 da análise:

- **Arquivos.** `CloseFile`, `SaveFile` e `OpenFile` vão para `IOTAActionServices`. `CloseProject`
  chama `CloseFile(<.dpr>)`; se a IDE recusar, tenta o `.dproj`.
- **Projeto.** `GetProjectName` é o projeto ativo. Em `Delphi.Personality` devolve o **.dpr/.dpk**;
  durante o fechamento do projeto devolve o nome em cache.
- **Listas.** `GetUnitCount`/`GetUnitName` usam a lista ordenada do original: projeto, `.res`,
  editores do projeto e `GetModule(i).FileName`. `GetUnitCount` reconstrói a lista e `GetUnitName`
  usa a última. `GetFormCount`/`GetFormName` devolvem o `FileName` dos módulos que têm `FormName`.
- **Arquivo atual.** `GetCurrentFile` é `CurrentModule.FileName`; `IsFileOpen` é
  `FindModule <> nil`; `IsFileOpenAndWriteable` é `not IOTAEditBuffer.IsReadOnly`, ou o atributo
  do arquivo quando não há buffer.
- **Pacotes.** `GetModuleCount`/`Name` e `GetComponentCount`/`Name` usam `IOTAPackageServices`, a
  mesma semântica da antiga ToolIntf.
- **Erros.** `RaiseException` **não** levanta exceção: mostra um MessageBox
  "JEDI VCS - Application Error", como o original.
- **IDE.** `GetParentHandle` e `GetBaseRegistryKey` usam `IOTAServices`.
- **Componentes.** `GetModuleComponentCount`/`GetModuleComponent` usam
  `IOTAFormEditor.GetRootComponent` e `INTAComponent.GetComponent.Name`.
- **Opções.** `GetOptions` devolve `[ioSupportsShortCuts]`, para que a DLL não instale o hook de
  teclado.

## Compilação

```
tools\compilar-expert.bat [Debug|Release]          (padrão: Release)
```

- **Saída.**
  - `bin\ideclient\Win32\JvcsExpertBDS37.dll`, mais `.map` (`-GD`) para localizar AVs.
  - DCUs e `.res` de versão em `dcu\Win32\expert`.
  - Log em `tools\logs\compilar-expert_Win32_<Config>.log`.
- **Linha do compilador (resumo).** O script também chama `rsvars.bat` e o `brcc32` do `.rc`:
  `dcc32 --no-config -B -Q … --codepage:65001 -NSWinapi;System.Win;System;Vcl;Vcl.Imaging;Xml
  -U<lib\win32\release> -R<dcu\Win32\expert> -E bin\ideclient\Win32 -NU dcu\Win32\expert
  -LUrtl;vcl;designide JvcsExpertBDS.dpr`.
- **Pacotes.** Basta `-LUrtl;vcl;designide`. O compilador acrescenta sozinho `vclactnband`,
  `xmlrtl`, `vclimg` e `vclwinx`, que são exigidos pelo `designide`.
- **Verificação.** O script confere com `Studio\37.0\bin64\llvm-objdump.exe` que a DLL exporta
  `INITWIZARD0001` e importa `rtl370.bpl`, `vcl370.bpl` e `designide370.bpl`.
- **Runtime copiado** para a pasta da DLL: `JvcsExternalDll.dll`, `fvcscrypt.dll`, `zipdll.dll`,
  `unzdll.dll`, `htm_rep.htm`, `*.jvcs` e `*.chm`. Opcionalmente também `jedivcsdiff.exe`, que a DLL
  usa em Compare/Diff.
  - Ordem de origem: `3rdparty\`, depois `3rdparty\referencia-2.5.0.1030\`, depois
    `C:\Program Files (x86)\JEDI\JVCS` (ou `JVCS_INSTALL`).
  - A DLL resolve tudo relativo à **própria** pasta, então expert, DLL e runtime ficam juntos.
- **Outras versões do Delphi.** Com `set BDSROOT=C:\Program Files (x86)\Embarcadero\Studio\23.0`,
  o script gera `JvcsExpertBDS23.dll` e confere os imports `…290.bpl`. Para BDS 22, os imports são
  `…280.bpl`. Esses builds não foram testados.
- **Códigos de saída.**
  - `0`: OK.
  - `1`: falha de compilação ou de ambiente. Isso inclui a DLL em uso porque a IDE está aberta com o
    expert.
  - `2`: compilou, mas falta arquivo de runtime ou a verificação do PE falhou.

## Registro na IDE (manual; o script não grava no registro)

Somente na **IDE de 32 bits**. **Não** registre em `Experts x64`: a `JvcsExternalDll.dll` é 32 bits.

```
reg add "HKCU\Software\Embarcadero\BDS\37.0\Experts" /v JVCSIDEClient /t REG_SZ ^
    /d "D:\Delphi\JediVCS\v2026\bin\ideclient\Win32\JvcsExpertBDS37.dll" /f
```

- O nome de valor `JVCSIDEClient` é o mesmo que o instalador do JEDI VCS usa (seção 5 da análise).
  Um instalador futuro substitui ou remove exatamente essa entrada.
- Para remover: `reg delete "HKCU\Software\Embarcadero\BDS\37.0\Experts" /v JVCSIDEClient /f`.
- **Teste isolado (opcional).** `bin\bds.exe -rJVCSTeste` usa
  `HKCU\Software\Embarcadero\JVCSTeste\37.0`. Registre o expert em `…\JVCSTeste\37.0\Experts` para
  não tocar no perfil principal.
- Com a IDE aberta, a DLL fica travada e não dá para recompilar. Feche a IDE antes de rodar o script.
- A configuração do cliente fica em `HKCU\Software\JEDI\JEDIVCS`, a mesma do JEDI VCS 2.5 instalado:
  servidor, usuário, atalhos, `ShowLoad` (auto-login) e `AcceptDisclaimer`.

## Variáveis de ambiente (opcionais, lidas na carga do expert)

| Variável | Efeito |
|---|---|
| `JVCS_EXPERT_LOG=<arquivo>` | Grava o log do expert em UTF-8: carga da DLL, verbos executados, notificações, erros e truncamentos. Sem ela o log só sai por `OutputDebugString` (visível no DebugView) com o prefixo `[JVCS Expert]` |
| `JVCS_EXPERT_DPI=off\|unaware\|gdiscaled` | Contexto de DPI das janelas da DLL. O padrão é `gdiscaled` (`DPI_AWARENESS_CONTEXT_UNAWARE_GDISCALED`, com fallback para `unaware`). `off` desliga a troca de contexto, como no original |

## Diferenças em relação ao `JvcsExpertBDS21.dll`

1. Buffers limitados nas 8 callbacks que escrevem em `array[0..255]`. O original fazia `StrPCopy`
   sem limite e estourava a pilha da DLL com caminhos de 256 ou mais caracteres.
2. Do lado do expert, os buffers que a DLL preenche são grandes. Um `GetVerb` com nome de arquivo
   longo estourava o buffer de 256 bytes do original.
3. O editor é convertido entre UTF-8 e ANSI em `SourceReadString`/`SourceWriteString`. O original
   passava UTF-8 cru, o que corrompia acentos na expansão de keywords, na marcação de check-in e na
   análise de units e componentes.
4. **DPI.** Chamadas com UI (ExecuteVerb, notificações, operações, INIT/FINALIZE, ProjectChange e
   History) rodam em contexto *unaware/GDI-scaled*. As callbacks voltam ao contexto da IDE. As janelas
   VCL 2007 da DLL ficam escaladas por bitmap em vez de minúsculas.
5. A palavra de controle da FPU e o MXCSR são restaurados depois de cada chamada à DLL.
6. O menu do Project Manager usa `IOTAProjectMenuItemCreatorNotifier`/`IOTAProjectManagerMenu`. O
   original usava `INTAProjectMenuCreatorNotifier`, que está deprecated no Delphi 13. Os itens e as
   operações são os mesmos, mas sem ícones, porque a `IOTALocalMenu` não tem imagem. `.fmx` também é
   mapeado para `.pas`.
7. **`IOTAIDENotifier80`.** O expert implementa `IOTAIDENotifier80` além do `50`. Um flag de
   "compilação pendente" garante um único `ienAfterCompile` por `BeforeCompile`, qualquer que seja a
   versão de `AfterCompile` que a IDE chamar.
8. `FileNotification` passa à DLL uma **cópia** de `Cancel`. A DLL sempre devolve `False`, e o
   original apagava o `Cancel = True` de outros experts.
9. **Atualização dos verbos.** `OnUpdate` das ações tem *throttle* de 1 s, e a atualização é forçada
   ao abrir o menu e antes de um atalho.
   - Se, depois de um `ExecuteVerb`, a quantidade de verbos ou algum atalho mudar, o menu e o key
     binding são reconstruídos. A reconstrução é **adiada por mensagem** e nunca roda dentro do
     OnClick ou do KeyProc que a disparou.
10. Se a DLL não carregar, o menu "JEDI VCS" mostra o item "JvcsExternalDll.dll not loaded -
    details…" com os caminhos tentados e o erro do Windows. O original deixava o menu vazio.
11. **History.**
    - Os índices são validados antes de chamar a DLL, que não verifica limites.
    - As chamadas vão para a thread principal (`TThread.Synchronize`), porque a DLL usa sockets ICS.
    - Há contagem de referência real (`TInterfacedObject` com stubs de `IDispatch`).
12. O bitmap do splash e do About é desenhado em tempo de execução, sem recurso binário.

## Limitações e riscos conhecidos

- **Só a IDE de 32 bits.** O `bin64\bds.exe` não carrega DLL de 32 bits, nem o expert nem a
  `JvcsExternalDll`. Isso só muda depois do port da DLL para Win64.
- **DLL antiga, ANSI.** Nomes de arquivo e textos fora da página de código do Windows (CP_ACP, 1252
  aqui) viram `?`. O conteúdo do editor também passa por CP_ACP, e caracteres sem equivalente se
  perdem na expansão de keywords e na marcação de check-in.
- **Duas VCLs no processo** (2007 dentro do Delphi 13):
  - As janelas da DLL não seguem tema nem VCL Styles da IDE (tema escuro).
  - Em formulários **não modais** da DLL, como o Project Manager do JVCS, Tab, atalhos, hints e
    `OnIdle` podem falhar, porque o laço de mensagens é o da IDE.
  - O `Application.ProcessMessages` da DLL também bombeia mensagens da IDE (reentrância). Já era
    assim nos IDEs anteriores.
- **DPI.** O contexto GDI-scaled resolve o tamanho, mas o texto fica levemente borrado em escalas
  altas.
  - Janelas que a DLL criar fora das chamadas protegidas (timers e eventos internos dela) nascem com
    o contexto da IDE.
  - Se algo ficar estranho, teste com `JVCS_EXPERT_DPI=off`.
- **`bds.exe` é LARGEADDRESSAWARE.** Código antigo da DLL que faz aritmética de ponteiro em `Integer`
  pode falhar com endereços acima de 2 GB. Uma AV aleatória dentro da DLL é forte indício disso.
- **Detecção da IDE pela DLL** (`JVCSIDESettings`). O BDS 37 fica `IDEUnknown` e é tratado como
  Delphi; funciona por acidente.
- **Auto-login.** Com `ShowLoad = True`, a DLL abre o diálogo de conexão durante a carga da IDE,
  dentro do `INITWIZARD0001`, como no original.
- **Duas notificações de fechamento.** O projeto recebe `ifnProjectClosing` duas vezes, por
  `ofnFileClosing` e pelo `Destroyed` do módulo, como no original. A DLL ignora a segunda.
- **Ordem do shutdown.** Ela difere do original, que chamava `FINALIZE`/`FreeLibrary` antes de
  remover o notifier e o key binding. Aqui os ganchos da IDE saem primeiro. Assim nada da IDE chama a
  DLL durante o `FINALIZE`, e a DLL ainda pode chamar as callbacks.
- **Pequenos vazamentos intencionais.** Os dois `HBITMAP` entregues ao splash e ao About não são
  liberados, para evitar `DeleteObject` duplo se a IDE assumir a posse. As imagens `JEDIVCS<n>`
  ficam no ImageList da IDE, que não tem API de remoção.
- **Não testado ainda.** Comportamento dentro do `bds.exe` (requer teste manual), Delphi 11/12 e
  monitores com DPI misto.

## Teste de fumaça (fora da IDE)

```
tools\compilar-expert.bat
src\jvcsideexpert\tests\testar-expert.bat
```

O teste compila `tests\FakeJvcsExternalDll.dpr`, uma DLL **falsa** com a mesma ABI que não é o cliente
JEDI VCS. Também compila `tests\JvcsExpertSmokeTest.dpr`, um host console com
`rtl;vcl;designide`. Tudo vai para `dcu\Win32\expert-test`, e nenhum binário do JVCS nem a IDE são
executados. São 69 verificações:

- **A) O `JvcsExpertBDS37.dll` real.**
  - `INITWIZARD0001` com um `IBorlandIDEServices` vazio, depois `Terminate` e `FreeLibrary`.
  - No log da DLL falsa: a ordem `INIT → HISTORYINIT → OPERATIONINIT → FINALIZE → DLL_PROCESS_DETACH`
    e as 24 callbacks, com guardas depois dos buffers de 256 bytes.
  - Leitura de um fonte UTF-8 em blocos de 2048, chegando como ANSI 1252.
  - O wizard vive até o `Terminate`.
- **B) `TJVCSDllBridge` direto.**
  - Verbos com 1500 caracteres e exceção lançada dentro da DLL.
  - Preservação de `Cancel`, notificações, History (também a partir de outra thread) e operações.
  - Menu do Project Manager com 10 itens por arquivo e 4 por projeto.
- **C) Conversões.** Truncamento em 255 + #0 e UTF-8 → ANSI, incluindo o €.
- **D) Pasta sem a DLL.** `InitWizard` continua `True` e o erro de carga vai para o log.

## Roteiro de teste manual (na IDE de 32 bits)

1. Feche a IDE. Rode `tools\compilar-expert.bat` e confira `[OK]` e a pasta `bin\ideclient\Win32`.
   Registre o valor `JVCSIDEClient` (seção "Registro"). Opcional:
   `set JVCS_EXPERT_LOG=%TEMP%\jvcs-expert.log` antes de abrir a IDE pelo mesmo prompt.
2. Abra `Studio\37.0\bin\bds.exe` (**32 bits**).
   - Splash: aparece "JEDI Version Control System".
   - Help > About: aparece o plugin, com a licença MPL 1.1.
3. Menu **JEDI VCS** logo depois de Tools.
   - Legenda acelerada vinda da DLL e 27 itens com ícones (29 se a DLL tiver sido compilada com
     `BRANCHING`).
   - Separadores nos lugares certos.
   - Itens desabilitados enquanto não houver conexão nem projeto.
   - Tools > Options > Keyboard / Customize: as ações ficam na categoria "JEDI VCS".
4. **Connect Server…** abre o diálogo de login da DLL, já escalado em DPI alto. Na primeira vez
   aparece o disclaimer, porque `AcceptDisclaimer = 0`. Conecte ao servidor 2.5 Beta 3.
5. Abra um `.dproj` que já esteja no arquivo do JVCS.
   - No log: `FileNotification(3, …dproj)`, depois `ProjectChange`, depois
     `FileNotification(4, …dpr)`.
   - O nome do projeto na DLL deve ser o `.dpr`.
   - O **Project Manager** do JVCS mostra os módulos.
6. Check Out e Check In de uma unit de teste pelo menu e pelos atalhos configurados no JVCS.
   - Confira o arquivo read-only e writeable no editor.
   - Se "Mark source" estiver ativo, confira o comentário inserido no início do fonte: acentos
     corretos e Ctrl+Z desfaz.
7. Botão direito numa unit no **Project Manager da IDE** > JEDI VCS > Check In, Check Out, Get,
   Reload, Compare, Diff e History. No nó do projeto: Manager, History e Synchronize/Restore.
8. Aba **History** de uma unit versionada: revisões "JEDI VCS" com autor, data, comentário e labels,
   e conteúdo/diff de uma revisão.
9. Compile o projeto com "VerInfoHandle" ativo no JVCS. O build do `.res` deve ser incrementado
   (`ienAfterCompile`) uma única vez por compilação.
10. Feche o projeto: `ifnProjectClosing` aparece no log e o Project Manager do JVCS fecha. Feche a
    IDE: não deve haver AV. No log devem aparecer `FinalizeWizard`, `JVCS Expert finalizando` e
    `JvcsExternalDll descarregada`.
11. Renomeie temporariamente a `JvcsExternalDll.dll` e abra a IDE. O menu deve mostrar "not loaded -
    details…" com o motivo, e a IDE não pode travar.
