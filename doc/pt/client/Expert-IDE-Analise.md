# Expert de IDE do JEDI VCS 2.5.0.1030: análise por engenharia reversa

> Escopo: análise **estática** (somente leitura) dos binários do instalador oficial
> *JVCS v2.50 Client Setup Beta 3 "Refresh till 10.4 Sydney"*. Nenhum binário do JVCS foi
> executado. Ferramentas: parser PE/recursos/RTTI escrito em C# e executado via PowerShell, e
> `llvm-objdump` (disassembler que acompanha o Delphi 13: `Studio\37.0\bin64\llvm-objdump.exe`).
> Os endereços citados são do `JvcsExpertBDS21.dll` (ImageBase `0x00400000`).
>
> Fonte do lado da DLL usado para confronto: `src\common\JVCSIDEInterfaceCommon.pas`,
> `src\jedivcs\JediVCSDLL.dpr`, `JVCSIDEInterface.pas`, `JVCSDLLOperations.pas`,
> `JVCSDLLFileHistoryImpl.pas`, `src\common\JVCSIDESettings.pas`. **O fonte do expert não existe**
> em `D:\Delphi\JediVCS` (confirmado por busca de nomes de arquivo).

Os binários de referência em `3rdparty\referencia-2.5.0.1030` têm o mesmo hash SHA-256 dos
instalados em `C:\Program Files (x86)\JEDI\JVCS`.

---

## 1. Resumo: o que o expert faz e como carrega a JvcsExternalDll

O expert (`JvcsExpertBDSnn.dll`, projeto original `JVCSIDE_DxWizard.dpr`, nome interno
`JvcsExpertDx.dll`) é um **wizard DLL fino**. Ele faz a ponte entre a ToolsAPI (OTA/NTA) do IDE e
o cliente JEDI VCS completo, que fica na `JvcsExternalDll.dll` (5,9 MB, compilada em **Delphi 2007**,
ANSI). O expert não tem nenhuma lógica de controle de versão.

As unidades do expert, extraídas do recurso `PACKAGEINFO`, são:

| Unidade | Papel |
|---|---|
| `JVCSIDE_DxWizard` (dpr) | Export `INITWIZARD0001`, splash, About, registro do wizard |
| `JVCSIDEWizard` | `TJVCSWizard`, `TIdeNotifier`, `TProjectCloseNotifier`, `TModuleNotifierList`; carga da DLL, menu, ações, atalhos, callbacks do IDE |
| `JVCSIDEProjectMenuImpl` | `TJVCSProjectMenuCreatorNotifier` (menu de contexto do Project Manager) |
| `JVCSIDEFileHistoryImpl` | `TJVCSFileHistoryProvider` / `TJVCSFileHistory` (aba History) |
| `JVCSIDEInterfaceCommon` | Mesmas declarações da ABI que estão em `src\common` |

### 1.1 Como a DLL é encontrada e carregada

A rotina é `TJVCSWizard.Create` (0x40A084), auxiliada por 0x409FFC:

1. Calcula o diretório **do próprio expert**: `GetModuleFileNameW(HInstance)` seguido de
   `ExtractFilePath`.
2. Tenta, nesta ordem e sempre com caminho completo, `LoadLibraryW(<dir do expert> + nome)` para:
   1. `JvcsExternalDll.dll`
   2. `jedivcsexternaldll.dll`
   3. `jedivcsdll.dll` (nome legado)
3. **Não há leitura de registro nem uso do search path** para localizar a DLL. Os imports de
   `TRegistry`, `SafeLoadLibrary` e `LoadLibraryA` vêm do RTL e de unidades de inicialização, não da
   lógica do expert. Por isso, o expert precisa ficar na mesma pasta da DLL (`{app}` =
   `C:\Program Files (x86)\JEDI\JVCS`).
4. Se nenhuma DLL carregar, o expert continua vivo, mas com uma funcionalidade mínima: o menu
   "JEDI VCS" aparece sem itens, e nem o History nem o menu do Project Manager são registrados.
5. A própria DLL resolve tudo relativo à **sua** pasta (`sDLLDirectory := GetDllLocation(HInstance)`):
   `FVCSCrypt.dll`, `zipdll.dll`, `unzdll.dll`, `jedivcsdiff.exe`, `jedivcs.chm`, `*.jvcs`
   (`ffdef`, `ulist`, `vcllist`, `verinf`) e `JVCS.ini`. A configuração fica em
   `HKCU\Software\JEDI\JEDIVCS` (`cRegSwJVCSBase`).

Pequeno defeito: `GetModuleFileNameW` recebe `nSize = 0x20A` (522) com um buffer de 522 **bytes**
(261 WideChars), o clássico `SizeOf` no lugar de `Length`. Isso pode estourar o buffer com caminhos
de mais de 261 caracteres.

### 1.2 Funcionalidades que o expert oferece ao IDE

- Item de menu principal **"JEDI VCS"**, inserido logo depois do `ToolsMenu`. A legenda vem de
  `GetMenuName` da DLL (fallback `'JEDI VCS'`) e o nome do componente é `mnuJEDIVCS`. Os subitens
  `mnuJEDIVCS_<n>` são reconstruídos no `OnClick` do item raiz a partir dos *verbs* da DLL.
- Uma **TAction por verb** (`JEDIVCS_A<n>`, categoria `JEDI VCS`, `Tag = 100 + índice`) inserida na
  `ActionList` do IDE, com `OnExecute` chamando `ExecuteVerb(i)` e `OnUpdate` chamando
  `GetVerb`/`GetVerbState`.
- **Imagens de menu**: `GetVerbImages` devolve um BMP em tira de 16×16, que o expert fatia e
  registra com `INTAServices.AddMasked(bmp, cor, 'JEDIVCS<n>')`.
- **Atalhos** pelo binding de teclado parcial `IOTAKeyboardBinding` "JEDI VCS KeyBindings". O
  expert declara `GetOptions = [ioSupportsShortCuts]`, o que faz a DLL **não** instalar o hook de
  teclado antigo.
- **Notificações do IDE** (abrir/fechar arquivo ou projeto, desktop, compilação) traduzidas para o
  enum `TIDEFileNotification`/`TIDEEventNotification` da DLL.
- **Aba History** (FileHistoryAPI): o provider "JEDI VCS File History Provider".
- **Menu de contexto do Project Manager** (submenu "JEDI VCS" para arquivo e para projeto).
- Bitmap de **splash** e entrada na caixa **About** (licença "MPL 1.1").

---

## 2. Exports, imports, runtime packages e versões

### 2.1 Experts (`JvcsExpert*.dll`): todos com FileVersion 2.5.0.1030

| Binário | IDE alvo | Tamanho | TimeDateStamp | String do compilador (.rdata) | Exports | Runtime packages importados |
|---|---|---:|---|---|---|---|
| JvcsExpertD7 | Delphi 7 | 35 328 | 1992-06-19¹ | — | `INITWIZARD0001` | rtl70, vcl70, designide70 |
| JvcsExpertBDS1 | C#Builder 1 | 40 448 | 1992-06-19¹ | — | idem | rtl71, vcl71, vclactnband71, designide71 |
| JvcsExpertBDS2 | Delphi 8 | 40 960 | 1992-06-19¹ | — | idem | …71 |
| JvcsExpertBDS3 | Delphi 2005 | 55 296 | 1992-06-19¹ | — | idem | …90 (+ xmlrtl90) |
| JvcsExpertBDS4 | BDS 2006 | 50 688 | 1992-06-19¹ | — | idem | …100 |
| JvcsExpertBDS5 | RAD Studio 2007 | 50 176 | 2010-02-07 | — | idem | …100 |
| JvcsExpertBDS6 | 2009 | 54 272 | 2010-02-07 | — | idem | …120 |
| JvcsExpertBDS7 | 2010 | 69 120 | 2010-02-07 | — | idem | …140 |
| JvcsExpertBDS8 | XE | 69 632 | 2010-09-29 | — | idem | …150 |
| JvcsExpertBDS9 | XE2 | 80 896 | 2011-09-03 | — | idem | …160 |
| JvcsExpertBDS10 | XE3 | 80 384 | 2012-09-05 | — | idem | …170 |
| JvcsExpertBDS11 | XE4 | 80 384 | 2013-08-20 | — | idem | …180 |
| JvcsExpertBDS12 | XE5 | 80 384 | 2014-04-16 | — | idem | …190 |
| JvcsExpertBDS14 | XE6 | 81 408 | 2014-04-16 | — | idem | …200 |
| JvcsExpertBDS15 | XE7 | 81 408 | 2015-01-13 | — | idem | …210 |
| JvcsExpertBDS16 | XE8 | 81 920 | 2015-04-19 | 29.0 (22.0.19027.8951) | idem | …220 |
| JvcsExpertBDS17 | 10 Seattle | 83 968 | 2015-09-13 | 30.0 (23.0.20618.2753) | idem + `__dbk_fcall_wrapper`, `dbkFCallWrapperAddr`² | …230 |
| JvcsExpertBDS18 | 10.1 Berlin | 84 480 | 2016-04-26 | 31.0 (24.0.22858.6822) | idem² | …240 |
| **JvcsExpertBDS19** | 10.2 Tokyo | 84 480 | 2017-03-29 | 32.0 (25.0.26309.314) | idem² | rtl250, vcl250, vclactnband250, xmlrtl250, designide250 |
| **JvcsExpertBDS20** | 10.3 Rio | 83 456 | 2018-11-24 | 33.0 (26.0.32429.4364) | idem² | …260 |
| **JvcsExpertBDS21** | 10.4 Sydney | 83 968 | 2020-06-07 | 34.0 (27.0.37889.9797) | idem² | rtl270, vcl270, vclactnband270, xmlrtl270, **designide270** |

¹ Os linkers Borland antigos gravavam esse valor fixo (`0x2A425E19`), que não é a data real do build.
² Exports gerados automaticamente pelo linker a partir do XE8/10 (suporte do debugger a chamada de
função). O IDE não os usa.

Outros detalhes comuns a todos os experts:

- **Nome no export directory**: `JVCSIDE_DxWizard.dll`.
- **VERSIONINFO**: `InternalName=JVCSIDE_DxWizard.dpr`, `OriginalFilename=JvcsExpertDx.dll`,
  `FileDescription=JEDI VCS IDE Expert`, `InternalVersion=2.5.0 Beta 3`.
- **Recursos**: `SPLASH` (bitmap), `DVCLAL`, `PACKAGEINFO`, `VS_VERSION_INFO`.
- **DLLs de sistema**: apenas kernel32 e user32. O D7 e os BDS1–5 usam funções `…A`. A partir do
  BDS6 (Delphi 2009) usam `…W`: `GetModuleFileNameW`, `LoadLibraryW`, `GetProcAddress`,
  `FreeLibrary`, `LoadBitmapW`, `FreeResource`, `MessageBoxW` e `GetWindowTextW`.
- **Níveis de funcionalidade**:
  - D7, BDS1, BDS2: só o wizard (menu, ações, atalhos, notificações).
  - BDS3+ (2005+): acrescentam `JVCSIDEFileHistoryImpl` (History) e `JVCSIDEProjectMenuImpl`
    (menu do Project Manager).

**BDS19 × BDS20 × BDS21**: o código é **idêntico**. As mesmas classes, os mesmos métodos, os mesmos
GUIDs e as mesmas strings UTF-16. As únicas diferenças são:

- o sufixo dos packages (250/260/270);
- a versão do compilador;
- imports de `initialization`/`finalization` de unidades RTL/VCL arrastadas transitivamente
  (Direct2D, Styles, Grids…);
- a assinatura de `FreeAndNil`, que no 10.4 passou a ser `const [ref] TObject`.

Não há `#IFDEF` de versão visível na lógica.

### 2.2 Imports de ToolsAPI do expert BDS21 (designide270.bpl)

`BorlandIDEServices`, `SplashScreenServices`, `TNotifierObject` (AfterSave/BeforeSave/Destroyed/
Modified) e os typeinfos de `IOTAWizard`, `IOTANotifier`, `IOTAIDENotifier`, `IOTAIDENotifier50`,
`IOTAKeyboardBinding`, `IOTAKeyBindingServices`, `IOTAKeyContext`, `TKeyBindingResult`,
`TBindingType`, `IOTAModuleNotifier`, `IOTAModule40`, `IOTAProject`, `IOTAComponent`,
`TOTAFileNotification`, `TWizardState`, `INTAProjectMenuCreatorNotifier`,
`Filehistoryapi.IOTAFileHistory` e `Filehistoryapi.IOTAFileHistoryProvider`.

### 2.3 JvcsExternalDll.dll (o cliente)

| Item | Valor |
|---|---|
| Tamanho / TimeDateStamp | 5 938 688 / 2011-09-21 23:14 UTC |
| Nome no export directory | `JedivcsDll.dll` |
| Exports | `JEDIVCSDLLINIT` (0x80C4B0), `JEDIVCSDLLFINALIZE` (0x80C578), `JEDIVCSDLLHISTORYINIT` (0x56A4CC), `JEDIVCSDLLOPERATIONINIT` (0x7F0E18) |
| Runtime packages | **nenhum** (RTL/VCL/JCL/JVCL/SynEdit/ICS/Abbrevia linkados estaticamente, 488 unidades) |
| DLLs importadas | só de sistema (advapi32, comctl32, comdlg32, gdi32, hhctrl.ocx, imm32, kernel32, mpr, ole32, oleacc, oleaut32, oledlg, shell32, user32, version, winmm, winspool.drv, wsock32) |
| `borlndmm.dll` / ShareMem | **não importa**, e a unidade `ShareMem` **não** está no PACKAGEINFO |
| Gerenciador de memória | próprio ("FastMM Borland Edition", o embutido no RTL 2006/2007) |
| Compilador | **Delphi 2007** (VER185, não Unicode; inferido) |

Evidências da versão do compilador:

- só usa APIs `…A` (`RegQueryValueExA`, `LoadStringA`, `MessageBoxA`, `CharNextA`);
- tem `TGlassFrame`, `TCustomFileDialog`/`TFileOpenDialog` e a unidade `DwmApi` (introduzidos no
  Delphi 2007);
- não tem `TEncoding`, `UnicodeString` nem as unidades `Character`/`AnsiStrings` (do 2009+);
- contém a string `Software\CodeGear\BDS\` (de `JVCSIDESettings`).

Logo, **não é Delphi XE**. A data de 2011 é só a do build.

Para comparação, `JvcsVcsManagerD5/D6.dll` (interface antiga `VCSIntf`, export `INITVCS0014`, para
D5/D6/BCB5/BCB6) **usam** ShareMem e importam `borlndmm.dll`, que está na pasta de instalação.

---

## 3. A ABI expert → DLL efetivamente usada

### 3.1 Sequência de chamadas (inferida do disassembly do BDS21)

```
IDE → INITWIZARD0001(BorlandIDEServices, RegisterProc, var Terminate)   [0x40B7C8]
  SplashScreenServices.AddPluginBitmap('JEDI Version Control System', SPLASH, False, 'MPL 1.1', '')
  SplashScreenServices.StatusMessage('Initializing JEDI Version Control System')
  IOTAAboutBoxServices.AddPluginInfo(...)              → índice guardado
  TJVCSWizard.Create                                   [0x40A084]
    ClearFunctionRecs (zera VCSRec e NotifierRec)
    LoadLibraryW(dir + 'JvcsExternalDll.dll' | 'jedivcsexternaldll.dll' | 'jedivcsdll.dll')
    preenche IDERec (24 callbacks do expert)
    JEDIVCSDLLINIT(@IDERec, @VCSRec, @NotifierRec)      ← retorno IGNORADO
      (a DLL preenche VCSRec (10 fns) e NotifierRec (2 fns) e roda JediVCSInternalInit:
       GetOptions, GetParentHandle, GetBaseRegistryKey, cria DataModule, eventual auto-login)
    JEDIVCSDLLHISTORYINIT(@HistoryRec)                  ← retorno ignorado
    IOTAFileHistoryManager.RegisterHistoryProvider(TJVCSFileHistoryProvider(@HistoryRec))
    GetVerbImages(buf[128 KB], $20000, 16, 16, size) → INTAServices.AddMasked(...'JEDIVCS<n>')
    TMenuItem 'mnuJEDIVCS', Caption := GetMenuName(buf[256]); insere após 'ToolsMenu'
    CreateActions: GetVerbCount; para cada i: GetVerb(i,buf[256]), GetVerbState(i),
                   GetVerbImageIndex(i), GetVerbShortCut(i)
    TIdeNotifier → IOTAServices.AddNotifier
    UpdateMenu (subitens)
    IOTAKeyboardServices.AddKeyboardBinding(Self)
    JEDIVCSDLLOPERATIONINIT(@OperationRec)              ← retorno ignorado
    IOTAProjectManager.AddMenuCreatorNotifier(TJVCSProjectMenuCreatorNotifier(@OpRec,@IDERec,@VCSRec))
  IOTAWizardServices.AddWizard(wizard)
  Terminate := FinalizeWizard                          [0x40B6D8]

Execução:
  Action.OnExecute → ExecuteVerb(Tag-100); se GetVerbCount ou algum GetVerbShortCut mudou
                     → reconstrói menu e refaz o keyboard binding
  Action.OnUpdate  → GetVerb / GetVerbState / GetVerbImageIndex / GetVerbShortCut
  Notificações     → NotifierRec.FileNotification / EventNotification, VCSRec.ProjectChange
  History view     → HistoryRec.*;  Project Manager → OperationRec.*

Finalização (FinalizeWizard → RemovePluginInfo; FinalizeAdditionalHandlers = RemoveKeyboardBinding;
             RemoveWizard → TJVCSWizard.Destroy [0x40A75C]):
  UnregisterHistoryProvider; RemoveMenuCreatorNotifier; ClearFunctionRecs (zera VCS/Notifier);
  JEDIVCSDLLFINALIZE; FreeLibrary; IOTAServices.RemoveNotifier; RemoveKeyboardBinding;
  libera menu, lista de imagens e ações criadas.
```

`VCSRec.GetIDString` **nunca é chamado** pelo expert. `ProjectChange` só é chamado pelo
`TIdeNotifier`/`TProjectCloseNotifier`, que trabalham sobre uma **cópia** de `VCSRec`.

### 3.2 Layout de `TJVCSWizard` (BDS21)

Os registros vivem **dentro do objeto wizard**, e a DLL guarda o ponteiro para `IDERec`. Por isso
o objeto precisa sobreviver até o `FINALIZE`.

| Offset | Campo (nome pela RTTI) | Conteúdo |
|---|---|---|
| +0x0C | `FMenuItem` | item "JEDI VCS" |
| +0x10 | `FNotifierIndex` | índice do `IOTAServices.AddNotifier` |
| +0x14 | `FNotifier` | `TIdeNotifier` |
| +0x18 | `FKeyboardBindingIndex` | |
| +0x1C | `DLLHandle` | |
| +0x20 | `VCSFunctionRec` | `TExternalVCSFunctionRec` (10 ponteiros) |
| +0x48 | `IDEFunctionRec` | `TExternalIDEFunctionRec` (24 ponteiros) |
| +0xA8 | `NotifierFunctionRec` | `TExternalNotifierFunctionRec` (2 ponteiros) |
| +0xB0 | `FMenuImageIndexList` | `TList` |
| +0xB4 | `FCreatedActions` | `TList` |
| +0xB8 | `FHistoryIndex` | |
| +0xBC | `HistoryFunctionRec` | `TExternalVCSModuleHistoryFunctionRec` (9 ponteiros) |
| +0xE0 | `FMenuCreatorIndex` | |
| +0xE4 | `OperationFunctionRec` | `TExternalVCSOperationFunctionRec` (10 ponteiros) |

Os tamanhos e a ordem dos cinco registros **batem exatamente** com `JVCSIDEInterfaceCommon.pas`.
Isso foi confirmado também do lado da DLL: o `JEDIVCSDLLINIT` (0x80C4B0) grava 10 ponteiros em
`VCSRec` e 2 em `NotifierRec`, o `HISTORYINIT` grava 9 e o `OPERATIONINIT` grava 10 (inclui
`DiffModule`).

### 3.3 Tipos de string: PAnsiChar em todo o lado

- **Experts BDS6+ (Unicode)**: toda string que vai para a DLL passa por `LStrFromUStr` (CP 0 =
  `CP_ACP`) e depois `StrPCopy(PAnsiChar, AnsiString)`. Toda string que vem da DLL passa por
  `StrPas(PAnsiChar)` e depois `UStrFromLStr`/`WStrFromLStr`. Os imports provam isso:
  `StrPCopy$qqrpcx27System@%AnsiStringT$us$i0$%`, `StrPas$qqrpxc`, `LStrFromUStr`,
  `UStrFromLStr`, `WStrFromLStr` e o typeinfo `PAnsiChar`.
- **DLL (Delphi 2007)**: declara os parâmetros como `PChar`, que nesse compilador é `PAnsiChar`, e
  por isso é compatível com os tipos `PAnsiChar` dos registros.
- **Não há ShareMem.** Nenhuma string Delphi, objeto ou interface cruza a fronteira: só ponteiros,
  `Integer`, `Word`, `Boolean` (em AL), enums de 1 byte, set de 1 byte (`TIDEInterfaceOptions`) e
  `TDateTime` por referência. Os buffers são sempre **alocados por quem chama**.

Tamanhos de buffer implícitos (não são passados na chamada):

| Direção | Função | Buffer |
|---|---|---|
| DLL → expert (expert preenche) | `GetProjectName`, `GetUnitName`, `GetFormName`, `GetCurrentFile`, `GetModuleName`, `GetComponentName`, `GetBaseRegistryKey`, `GetModuleComponent` (nome e tipo) | `array[0..255] of Char` na DLL (**256 bytes**). O expert faz `StrPCopy` **sem limite**: estoura o buffer com caminho de 256+ caracteres |
| DLL → expert | `SourceReadString` | `AReadSize + 1` (a DLL lê em blocos de 2048) |
| expert → DLL (DLL preenche) | `GetMenuName`, `GetVerb` | 256 bytes no expert |
| expert → DLL | `GetModuleHistoryAuthor`, `…VersionRevisionStr`, `…Label` | 256 bytes; nome do módulo enviado em buffer de 256 |
| expert → DLL | `GetModuleHistoryComment` | `AMaxCommentSize = 0x800` (2048) |
| expert → DLL | `GetVerbImages` | 0x20000 (128 KB) |

### 3.4 Implementação das 24 callbacks `TExternalIDEFunctionRec` no expert (BDS21)

| # | Campo | Endereço | Implementação |
|---|---|---|---|
| 0 | CloseProject | 0x409A58 | nome do projeto ativo → `IOTAActionServices.CloseFile` |
| 1 | CloseFile | 0x409908 | `IOTAActionServices.CloseFile` |
| 2 | SaveFile | 0x4099B0 | `IOTAActionServices.SaveFile` |
| 3 | OpenFile | 0x409860 | `IOTAActionServices.OpenFile` |
| 4 | GetParentHandle | 0x4088A8 | `IOTAServices.GetParentHandle` (com try/except → 0) |
| 5 | GetProjectName | 0x408EC4 | projeto ativo do project group (ou o único projeto); para `Delphi.Personality` devolve o arquivo **.dpr/.dpk** do projeto, não o .dproj. Durante o fechamento usa o nome em cache |
| 6 | GetUnitCount | 0x409130 | monta `TStringList` ordenada: arquivo do projeto, `.res` se existir, `IOTAProject.GetModule(i).FileName` e arquivos do módulo |
| 7 | GetUnitName | 0x409160 | item i da lista acima |
| 8 | GetFormCount | 0x409304 | lista de módulos com `FormName` |
| 9 | GetFormName | 0x409334 | item i |
| 10 | GetCurrentFile | 0x408B30 | `IOTAModuleServices.CurrentModule.FileName` |
| 11 | IsFileOpen | 0x4093E8 | `IOTAModuleServices.FindModule(nome) <> nil` |
| 12 | GetModuleCount | 0x409D38 | `IOTAPackageServices.PackageCount` (semântica da antiga ToolIntf = pacotes instalados) |
| 13 | GetModuleName | 0x409DB0 | `IOTAPackageServices.PackageNames[i]` |
| 14 | GetComponentCount | 0x409E7C | `IOTAPackageServices.ComponentCount[pkg]` |
| 15 | GetComponentName | 0x409F10 | `IOTAPackageServices.ComponentNames[pkg, i]` |
| 16 | RaiseException | 0x4089D4 | **não levanta exceção**: `MessageBoxW(parent, msg, 'JEDI VCS - Application Error', MB_ICONERROR)` |
| 17 | GetBaseRegistryKey | 0x408A5C | `IOTAServices.GetBaseRegistryKey` (p.ex. `Software\Embarcadero\BDS\21.0`) |
| 18 | GetModuleComponentCount | 0x409AEC | `FindModule` → `IOTAFormEditor.GetRootComponent.GetComponentCount` |
| 19 | GetModuleComponent | 0x409BB4 | `GetComponent(i)`: `GetComponentType` e `GetPropValueByName('Name')` |
| 20 | SourceWriteString | 0x409788 | `IOTASourceEditor.CreateWriter`: `CopyTo(pos)` e `Insert(PAnsiChar)` |
| 21 | SourceReadString | 0x4096B4 | `IOTASourceEditor.CreateReader.GetText(pos, buf, size)` |
| 22 | GetOptions | 0x409FF0 | constante `[ioSupportsShortCuts]` (byte 1) |
| 23 | IsFileOpenAndWriteable | 0x4094A0 | `FindModule` → editor → `IOTAEditBuffer.IsReadOnly = False` |

Uso do `TExternalVCSFunctionRec` pelo expert:

| Função | Uso |
|---|---|
| `ExecuteVerb` | ações e atalhos |
| `GetMenuName` | legenda do menu principal |
| `GetVerb` | legenda da ação; vazio vira `'-'` |
| `GetVerbCount` | quantidade de ações e itens |
| `GetVerbState` | bit 1 = Enabled, bit 2 = Checked |
| `GetVerbImages` / `GetVerbImageIndex` | imagens |
| `GetVerbShortCut` | `TShortCut` |
| `ProjectChange` | notificações |
| `GetIDString` | não é usado |

### 3.5 Tradução das notificações (`TIdeNotifier.FileNotification`, 0x407E28)

Só os códigos OTA 0, 1, 2, 5 e 9 são tratados. O expert classifica o arquivo como **project
group**, **projeto** ou **arquivo comum**:

- **Grupo**: extensões `.BPG`, `.BDSGROUP` e `.GROUPPROJ`, ou o módulo suporta `IOTAProjectGroup`.
- **Projeto**: extensões `.DPR`, `.DPK`, `.BDSPROJ`, `.CBPROJ`, `.CSPROJ`, `.DPROJ`, `.TGPROJ` e
  `.VBPROJ`, ou o módulo suporta `IOTAProject` (neste caso o nome vira o .dpr/.dpk).

| Evento OTA | Projeto | Arquivo comum | Grupo |
|---|---|---|---|
| `ofnFileOpening` (0) | `ifnProjectOpening` (3) | `ifnFileOpening` (0) | — |
| `ofnFileOpened` (1) | `ProjectChange`; `ifnProjectOpened` (4); anexa um `TProjectCloseNotifier` (`IOTAModuleNotifier`) ao módulo do projeto | `ifnFileOpened` (1) | — |
| `ofnFileClosing` (2) | `ifnProjectClosing` (5); `ProjectChange` | `ifnFileClosing` (2) | — |
| `ofnProjectDesktopLoad` (5) | `ifnProjectDesktopLoad` (10) | `ifnProjectDesktopLoad` (10) | — |
| `ofnActiveProjectChanged` (9) | `ProjectChange` | — | — |
| `IOTAModuleNotifier.Destroyed` do projeto | grava o nome em cache (usado por `GetProjectName`); `ifnProjectClosing` (5); `ProjectChange` | | |

Compilação (`IOTAIDENotifier50`):

- `BeforeCompile(Project, IsCodeInsight, var Cancel)` chama `EventNotification(ienBeforeCompile,
  Cancel)` quando **não** é Code Insight.
- `AfterCompile(Succeeded, IsCodeInsight)` faz `Cancel := True` e chama
  `EventNotification(ienAfterCompile, Cancel)` somente se `Succeeded` e não for Code Insight. A DLL
  interpreta `Cancel = True` como "compilou com sucesso" e incrementa o build no `ResFileInfo`.
- As versões de `IOTAIDENotifier` (sem o "50") são vazias.

**Nunca enviados à DLL**: `ifnAddedToProject`, `ifnRemovedFromProject`, `ifnDefaultDesktopLoad/Save`,
`ifnProjectDesktopSave`, `ifnPackageInstalled/Uninstalled`.

O nome passado em `ofnFileOpening`/`ofnProjectDesktopLoad` é o bruto (pode ser `.dproj`). Nos
eventos 1, 2 e 9 ele é normalizado para .dpr/.dpk.

### 3.6 History (`IOTAFileHistory`) e operações do Project Manager

| `TJVCSFileHistory` (`IDispatch`, safecall) | Função da DLL |
|---|---|
| `Get_Count` | `GetModuleHistoryCount(nome)` |
| `GetAuthor(i)` | `GetModuleHistoryAuthor` |
| `GetIdent(i)` | `GetModuleHistoryVersionRevisionStr` (`"v.rrr"`) |
| `GetComment(i)` | `GetModuleHistoryComment(…, 2048)` |
| `GetDate(i)` | `GetModuleHistoryDate(var TDateTime)` |
| `GetLabelCount(i)` / `GetLabels(i,j)` | `GetModuleHistoryLabelCount` / `GetModuleHistoryLabel` |
| `GetContent(i)` | `GetModuleHistoryContentSize`, depois `GetModuleHistoryContent` num `TMemoryStream` → `TStreamAdapter` (IStream) |
| `GetHistoryStyle(i)` | constante `hsRemoteRevision` (3) |

Provider: `Ident = 'PROJECT JEDI.JEDI VCS File History Provider'` e `Name = 'JEDI VCS File History
Provider'`. As classes derivam de `TComponent` só para herdar os stubs de `IDispatch`. Por isso não
há contagem de referência real.

Menu do Project Manager (`TJVCSProjectMenuCreatorNotifier`, com `TActionList` e `TImageList`
próprias carregadas de `GetVerbImages`):

- **`FileContainer`**: submenu "JEDI VCS" com *Check In/Put*, *Check Out*, *Get*, `-`, *Reload*,
  `-`, *Compare*, *Diff*, *History*.
  - Executam `GetProjectID(projeto)` seguido de `CheckInModule`/`CheckOutModule`/`GetModule`/
    `CompareModule(id, nome, ext)`/`DiffModule`/`ShowModuleHistory`.
  - *Reload* chama `IOTAActionServices.ReloadFile`.
  - `.dfm`/`.nfm`/`.xfm` são mapeados para `.pas` e `.h` para `.cpp`.
- **`ProjectContainer`**: submenu "JEDI VCS" com *Manager*, *History* e *Synchronize/Restore*, que
  chamam `ShowProjectManager`/`ShowProjectHistory`/`SyncProject`.
- O nome do projeto passa pela mesma regra .dproj → .dpr (`Delphi.Personality`).

### 3.7 Divergências e observações em relação a `JVCSIDEInterfaceCommon.pas` e ao fonte da DLL

1. **Estrutura**: nenhuma divergência de layout, ordem, convenção de chamada (`stdcall`) ou nomes
   de exports.
2. **Retornos ignorados**: o expert ignora o `Boolean` de `JEDIVCSDLLINIT`, `HISTORYINIT` e
   `OPERATIONINIT`.
3. **`RaiseException`**: só mostra uma MessageBox (a DLL espera uma exceção no IDE).
4. **Buffers fixos de 256 bytes sem verificação** (tabela 3.3): risco de estouro de pilha na DLL.
5. **`SourceReadString`/`SourceWriteString` passam UTF-8 cru.** `IOTAEditReader.GetText` devolve
   UTF-8 e `IOTAEditWriter.Insert` espera UTF-8, mas a DLL trata o conteúdo como ANSI (`CP_ACP`).
   Acentos são corrompidos na expansão de keywords, na marcação de comentário no fonte e na
   análise de units/componentes. As posições também são em bytes UTF-8.
6. **Conversões de nome via `CP_ACP`**: caminhos com caracteres fora da página de código do
   Windows viram `?`.
7. **`GetIDString` não é usado**, e várias `ifn*` nunca chegam à DLL (3.5).
8. **Armadilha no fonte da DLL, para quando ela for portada a Delphi Unicode.**
   `TExternalIDEInterface` usa `array[0..255] of Char` e `@LBuffer`. Com `{$T-}`, que o
   `compopt.inc` define, o `@` gera um `Pointer` não tipado. Isso **compila sem erro** no Unicode,
   mas faz o expert gravar ANSI num buffer de `WideChar`. Os `PChar(AFileName)` e as funções
   exportadas declaradas com `PChar` (`GetIDString(AIDString: PChar)` etc.) quebram a compilação.
   Todos precisam ser trocados para `AnsiChar`/`PAnsiChar` com conversão explícita.
9. **Detecção de IDE na DLL**: `JVCSIDESettings` só conhece até BDS6 (`Software\CodeGear\BDS\6.0`)
   e procura em HKLM `Borland`/`CodeGear`. Em BDS 21+ o produto fica `IDEUnknown`, e a DLL assume
   "Delphi". Funciona por acidente; não é preciso nada no expert.

---

## 4. ToolsAPI e recursos do IDE usados pelo expert

GUIDs encontrados no binário BDS21 (varredura de bytes contra os GUIDs dos fontes ToolsAPI do
Delphi 13; os de 10.4 são os mesmos):

| Interface | Uso |
|---|---|
| `IOTAWizard` + `IOTANotifier` (`TJVCSWizard`, `TInterfacedObject`) | `GetIDString = 'PROJECT JEDI.JEDI VCS IDE Wizard'`, `GetName = 'JEDI VCS IDE Wizard'`, `GetState = []`, `Execute` vazio |
| `IOTAKeyboardBinding` (no próprio wizard) | `GetBindingType = btPartial`, `GetDisplayName = 'JEDI VCS KeyBindings'`, `BindKeyboard`: para cada ação, `AddKeyBinding([ShortCut], KeyBindingCallback, nil, 0, '', 'mnuJEDIVCS_<i>')`; o callback executa a ação (`TBasicAction.Execute`) e devolve `krHandled` |
| `IOTAWizardServices` | `AddWizard` / `RemoveWizard` |
| `IOTASplashScreenServices` (`SplashScreenServices`) | `AddPluginBitmap`, `StatusMessage` |
| `IOTAAboutBoxServices` | `AddPluginInfo` / `RemovePluginInfo` |
| `INTAServices` | `GetMainMenu` (procura `ToolsMenu`), `GetActionList`, `AddMasked(bmp, cor, ident)` |
| `IOTAServices` | `AddNotifier`/`RemoveNotifier`, `GetBaseRegistryKey`, `GetParentHandle` |
| `IOTAIDENotifier`, `IOTAIDENotifier50` (`TIdeNotifier`, `TNotifierObject`) | notificações de arquivo e compilação |
| `IOTAModuleNotifier` (`TProjectCloseNotifier`) | `Destroyed` do módulo do projeto = fechamento de projeto |
| `IOTAModuleServices` | `CurrentModule`, `FindModule`, `ModuleCount`/`Modules` |
| `IOTAProjectGroup`, `IOTAProject` (`GetPersonality`, `GetModule*`, `ActiveProject`) | resolução do projeto ativo e do .dpr |
| `IOTAActionServices` | `OpenFile`, `CloseFile`, `SaveFile`, `ReloadFile` |
| `IOTAPackageServices` | `GetModuleCount`/`Name`, `GetComponentCount`/`Name` |
| `IOTASourceEditor`, `IOTAEditReader`, `IOTAEditWriter`, `IOTAEditBuffer` | leitura e escrita do buffer; `IsReadOnly` |
| `IOTAFormEditor`, `IOTAComponent` | componentes do form |
| `IOTAFileHistoryManager`, `IOTAFileHistoryProvider`, `IOTAFileHistory` (FileHistoryAPI) | aba History |
| `IOTAProjectManager` + **`INTAProjectMenuCreatorNotifier`** (`AddMenuCreatorNotifier`) | menu de contexto; esta API está `deprecated` no Delphi 13 em favor de `IOTAProjectMenuItemCreatorNotifier` |

Recursos de UI:

| Recurso | Valores |
|---|---|
| Menu principal | `mnuJEDIVCS`, subitens `mnuJEDIVCS_<n>` |
| Ações | `JEDIVCS_A<n>`, categoria `JEDI VCS`, `Tag` 100+ |
| Imagens no ImageList do IDE | `JEDIVCS<n>` |
| Bitmap | recurso `SPLASH` |
| Textos | "JEDI VCS", "Check In/Put", "Check Out", "Get", "Reload", "Compare", "Diff", "History", "Manager", "Synchronize/Restore", "JEDI Version Control System", "Initializing JEDI Version Control System", "JEDI VCS - Application Error" |
| Atalhos | definidos pela DLL (`cSCProjAdmin`, `cSCChkIn`, `cSCChkOut`, `cSCGet`, `cSCSync`, `cSCBckUp`), lidos de `HKCU\Software\JEDI\JEDIVCS\…` e expostos por `GetVerbShortCut`; não há atalhos fixos no expert |

---

## 5. Chaves de registro gravadas pelo setup (Inno Setup, `unins000.dat`)

O log de desinstalação registra as entradas a remover com a raiz `0x80000001` = **HKCU**:

| IDE | Chave (HKCU) | Valor | Dado (provável) |
|---|---|---|---|
| Delphi 5 / 6 | `Software\Borland\Delphi\5.0\Version Control` e `…\6.0\Version Control` | `VCSManager` | `{app}\JvcsVcsManagerD5.dll` / `D6.dll` |
| C++Builder 5 / 6 | `Software\Borland\C++Builder\5.0\Version Control` e `…\6.0\…` | `VCSManager` | `{app}\JvcsVcsManagerD5.dll` / `D6.dll` |
| Delphi 7 | `Software\Borland\Delphi\7.0\Experts` | `JVCSIDEClient` | `{app}\JvcsExpertD7.dll` |
| BDS 1.0–5.0 | `Software\Borland\BDS\<n>.0\Experts` | `JVCSIDEClient` | `{app}\JvcsExpertBDS<n>.dll` |
| BDS 6.0–7.0 | `Software\CodeGear\BDS\<n>.0\Experts` | `JVCSIDEClient` | idem |
| BDS 8.0–12.0, 14.0–21.0 | `Software\Embarcadero\BDS\<n>.0\Experts` | `JVCSIDEClient` | `{app}\JvcsExpertBDS<n>.dll` (não há BDS 13) |
| Configuração do cliente | `Software\JEDI\JEDIVCS` (e `Software\JEDI\JEDIVCSDIFF`) | removidas só se o usuário confirmar "Remove also JEDI VCS Client settings?" | |
| Migração FreeVCS | lê `Software\Borland\Delphi\{5,6,7}.0\Version Control\FreeVCS\Options\` e grava em `Software\JEDI\JEDIVCS\Options\` | | |

Outros detalhes do script (só nomes de funções `[Code]`):

- `REGISTERJVCSIDECLIENT`, `GETBDSDETECTED`, `GETBDS6_UPDETECTED`, `GETBDS8_UPDETECTED`,
  `GETDELPHIDETECTED` etc.;
- DLL auxiliar `jvcsinsthelper.dll` (`RegMigFreeVCS2JVCS`, `GETJVCSCLIENTMUTEXSTRINGS`);
- mutex `JediVCSAppMutex`;
- remoção de nomes antigos (`JvcsD5/6/7.dll`, `Jedivcsdll.dll`, `JVCSD7.DLL`).

O nome do valor **`JVCSIDEClient`** é a chave de compatibilidade a manter.

Nesta máquina existe `HKCU\Software\JEDI\JEDIVCS` com `BaseRegistryKey`, `ProgramVersion =
2.5.0.1030` e `AcceptDisclaimer = 0`. Só o BDS 37.0 está instalado, com as chaves `Experts` e
**`Experts x64`**; esta última é a do IDE de 64 bits.

---

## 6. Recomendações para o novo expert (Delphi 11 = BDS 22, 12 = BDS 23, 13 = BDS 37)

### 6.1 Formato e registro

- Manter o formato do original: **wizard DLL** com export `INITWIZARD0001` (`WizardEntryPoint`).
  - Compilar com **runtime packages** `rtl;vcl;designide`. O compilador acrescenta `vclactnband`,
    `xmlrtl` etc. sozinho.
  - Sufixos: BDS22 = 280, BDS23 = 290, BDS37 = 370 (`designide370.bpl` confirmado em
    `Studio\37.0\bin`).
  - Compiladores: 35.0, 36.0 e 37.0 (VER350/360/370).
- Saídas `JvcsExpertBDS22.dll`, `JvcsExpertBDS23.dll`, `JvcsExpertBDS37.dll`, com registro em
  `HKCU\Software\Embarcadero\BDS\<22.0|23.0|37.0>\Experts`, valor `JVCSIDEClient`. O instalador
  futuro deve usar o mesmo nome de valor, para substituir/remover o antigo.
- **IDE de 64 bits** (`Studio\37.0\bin64\bds.exe`, e o 12.x também tem): exige expert Win64,
  registrado em `Experts x64`, **e** uma `JvcsExternalDll` de 64 bits. A DLL de 2011 é 32 bits e
  **não carrega lá**. Planejar isso só depois do port da DLL.

### 6.2 Estrutura proposta (`src\jvcsideexpert`)

```
src\jvcsideexpert\
  JvcsIdeExpert.dpr            library; exports InitWizard name WizardEntryPoint
  JvcsIdeExpert.rc/.res        VERSIONINFO + bitmap SPLASH (+ PNGs para HiDPI)
  JVCSIDEAbi.pas               cópia sem $I da ABI (records/tipos de JVCSIDEInterfaceCommon) OU
                               reuso de ..\common\JVCSIDEInterfaceCommon.pas sem incluir compopt.inc
                               (ele força $IMAGEBASE/$APPTYPE/$T-)
  JVCSIDEDllBridge.pas         carga da DLL, records, as 24 callbacks IDE, conversões ANSI/UTF-8,
                               guarda de exceções e de DPI
  JVCSIDEWizard.pas            TJVCSWizard (IOTAWizard, IOTAKeyboardBinding), menu, ações, imagens
  JVCSIDENotifiers.pas         TIdeNotifier (IOTAIDENotifier80/50), TProjectCloseNotifier (IOTAModuleNotifier)
  JVCSIDEProjectMenu.pas       IOTAProjectMenuItemCreatorNotifier (substitui INTAProjectMenuCreatorNotifier)
  JVCSIDEFileHistory.pas       IOTAFileHistoryProvider / IOTAFileHistory
  projects\JvcsExpertBDS22.dproj, JvcsExpertBDS23.dproj, JvcsExpertBDS37.dproj  (mesmos fontes)
```

Units a usar: `ToolsAPI`, `FileHistoryAPI`, `Winapi.Windows`, `Winapi.ActiveX` (`IStream`),
`System.SysUtils`, `System.Classes`, `System.Win.Registry`, `Vcl.Menus`, `Vcl.ActnList`,
`Vcl.Graphics`, `Vcl.ImgList`, `Vcl.Controls` e `Vcl.AxCtrls`/`System.Classes.TStreamAdapter`.

Use `{$IF CompilerVersion >= 35}` só onde houver APIs novas, como
`INTAServices.AddImage(nome, TGraphicArray)` (`INTAServices280`, Delphi 11+) para ícones
multi-resolução.

### 6.3 Como manter a ABI com a `JvcsExternalDll` (original ou futura)

1. **Records idênticos** e na mesma ordem (24/10/2/9/10 ponteiros), `stdcall`, `PAnsiChar`,
   `Boolean`/enum/set de 1 byte e `Word` para `TShortCut`/estado. Guardar os records como **campos
   do objeto wizard** (endereço estável) e chamar na ordem `INIT → HISTORYINIT → OPERATIONINIT`. No
   fim: desregistrar tudo, zerar `VCSRec`/`NotifierRec`, chamar `FINALIZE` e só então `FreeLibrary`.
2. **Callbacks robustas.** Cada callback deve estar em `try…except` que nunca deixa exceção
   atravessar o `stdcall` e devolve um default. Toda cópia para a DLL deve ser limitada:
   `StrPLCopy(Buf, AnsiString(S), 255)` nos campos de 256 bytes. Nos buffers que o expert entrega à
   DLL, usar folga (por exemplo 1024 bytes para nomes e `AMaxCommentSize + 1`).
3. **Strings.** Converter `UnicodeString` em `AnsiString` (`CP_ACP`), como o original.
   - Em `SourceReadString`, ler o buffer inteiro via `IOTAEditReader`, converter de UTF-8 para
     ANSI, guardar em cache por módulo e servir fatias pela posição ANSI que a DLL pede.
   - Em `SourceWriteString`, converter de ANSI para UTF-8 antes do `Insert`.
   - Isso corrige a divergência 3.7-5 sem mudar a ABI.
4. **Localização da DLL.**
   - Ordem proposta: (a) valor configurável, por exemplo `HKCU\Software\JEDI\JEDIVCS\IDE\ExternalDll`
     (**proposta nova**, não existe hoje); (b) pasta do expert; (c) os três nomes legados.
   - Usar `LoadLibraryEx(Caminho, 0, LOAD_WITH_ALTERED_SEARCH_PATH)`.
   - A DLL precisa continuar na pasta do JVCS, junto de `FVCSCrypt.dll`, `zip/unzdll.dll`,
     `*.jvcs` e `jedivcsdiff.exe`.
   - Se não carregar, avisar uma vez (MessageBox ou Messages View) em vez de ficar mudo.
5. **Exceções da DLL.** Envolver cada chamada à DLL em `try…except` **sem** usar `on E: Exception`.
   O objeto de exceção do Delphi 2007 tem VMT e `Message` (AnsiString) incompatíveis com o RTL
   novo. Basta registrar "falha na JvcsExternalDll" e seguir.
6. **DPI.** A VCL 2007 não é DPI-aware, e o IDE 11+ é Per-Monitor v2. Antes de chamar `ExecuteVerb`
   ou as operações do Project Manager, fazer
   `SetThreadDpiAwarenessContext(DPI_AWARENESS_CONTEXT_UNAWARE_GDISCALED)` (ou `…UNAWARE`), e
   restaurar depois. Dentro das callbacks IDE chamadas pela DLL, voltar temporariamente ao contexto
   original. As janelas da DLL passam a ser escaladas por bitmap em vez de minúsculas.
7. **Notificações.** Replicar a tabela 3.5, incluindo a normalização .dproj → .dpr/.dpk e o
   `TProjectCloseNotifier`, porque o arquivo do JVCS identifica projetos pelo .dpr. Melhorias
   opcionais:
   - `IOTAIDENotifier80`;
   - enviar `ifnAddedToProject`/`ifnRemovedFromProject` (via `IOTAProjectNotifier`/
     `IOTAModuleNotifier80` ou comparando listas). A DLL já trata esses códigos (atualiza o
     Project Manager).
8. **History.** Implementar `IOTAFileHistoryProvider`/`IOTAFileHistory` com
   `TInterfacedObject` + stubs de `IDispatch` (`E_NOTIMPL`), mantendo `Ident`/`Name` e
   `hsRemoteRevision`. Como a DLL usa sockets ICS orientados a mensagens, garantir execução na
   thread principal (`TThread.Synchronize` se `GetCurrentThreadId <> MainThreadID`).
9. **Menu do Project Manager.** Migrar para `IOTAProjectMenuItemCreatorNotifier` +
   `IOTAProjectManagerMenu` (`AddMenuItemCreatorNotifier`), mantendo os mesmos itens e operações
   (3.6). `AddMenuCreatorNotifier` ainda existe no Delphi 13, mas está `deprecated`.
10. **Menu, ações e atalhos.** Manter os nomes `mnuJEDIVCS`, `JEDIVCS_A<n>`, a categoria
    `JEDI VCS`, `Tag = 100 + i` e o `IOTAKeyboardBinding` "JEDI VCS KeyBindings". Manter
    `GetOptions = [ioSupportsShortCuts]` para a DLL não instalar o hook de teclado
    (`SetWindowsHookEx`). Atenção: `OnUpdate` roda a cada ciclo ocioso e `GetVerbState` pode
    consultar o servidor. Considerar um throttle (por exemplo, no máximo 1 atualização por
    segundo).

### 6.4 Teste rápido: novo expert BDS37 carregando a `JvcsExternalDll.dll` ORIGINAL

**Viabilidade: sim, no IDE de 32 bits** (`Studio\37.0\bin\bds.exe`), com expert Win32. Motivos:

- a ABI é C pura (stdcall, ponteiros, PAnsiChar e tipos escalares);
- a DLL é autossuficiente (sem runtime packages, sem ShareMem e sem `borlndmm.dll`, cada lado com
  seu gerenciador de memória);
- o mesmo esquema já funcionou de 2010 a 2020, até o 10.4 (o expert BDS21, de 2020, carrega essa
  DLL de 2011).

**No IDE de 64 bits é inviável.**

Roteiro mínimo:

1. Criar um `JvcsIdeExpert.dpr` mínimo com:
   - `INITWIZARD0001`;
   - carga da DLL por caminho absoluto (`C:\Program Files (x86)\JEDI\JVCS\JvcsExternalDll.dll`);
   - as 24 callbacks (pode começar só com `GetParentHandle`, `GetBaseRegistryKey`,
     `GetProjectName`, `GetCurrentFile`, `IsFileOpen`, `GetOptions` e as de arquivo; as demais
     devolvem 0/False/"");
   - `JEDIVCSDLLINIT`;
   - menu e ações a partir dos verbs;
   - `TIdeNotifier`;
   - `JEDIVCSDLLFINALIZE` + `FreeLibrary` no `Destroy`.
2. Compilar Win32 com runtime packages `rtl;vcl;designide` (Delphi 13), gerando
   `bin\JvcsExpertBDS37.dll`.
3. O usuário registra `HKCU\Software\Embarcadero\BDS\37.0\Experts\JVCSIDEClient` com o caminho e
   abre o **bds.exe 32 bits**.
4. Verificar:
   1. o menu "JEDI VCS" com legendas e imagens;
   2. o diálogo de conexão/About (com `AcceptDisclaimer = 0`, a DLL mostra o disclaimer na primeira
      conexão);
   3. abrir um .dproj e conferir que `ifnProjectOpened` e `GetProjectName` resultam no `.dpr`;
   4. check-in/out de um arquivo de teste;
   5. ativar History/Project Manager numa segunda etapa;
   6. fechar o IDE sem AV (ordem do `FINALIZE`).

Riscos e cuidados:

| Risco | Impacto | Mitigação |
|---|---|---|
| ShareMem/`borlndmm` | **Nenhum.** A ExternalDll não usa ShareMem e a ABI não troca memória gerenciada | Não adicionar ShareMem ao expert. Nunca passar `string`/objetos/interfaces |
| PAnsiChar / páginas de código | Nomes fora do `CP_ACP` viram `?`; conteúdo do editor em UTF-8 tratado como ANSI | Conversões explícitas (6.3-3); documentar a limitação até portar a DLL para Unicode |
| Buffers de 256 bytes sem tamanho | Estouro de pilha na DLL com caminhos longos | `StrPLCopy(…, 255)` em todas as callbacks |
| Duas VCLs no processo (2007 dentro do 13) | Sem VCL Styles/tema escuro nas janelas da DLL. Em formulários **não modais** da DLL (Project Manager), Tab/atalhos/hints/`OnIdle`/`TAction.OnUpdate` podem falhar, porque o laço de mensagens é o do IDE. `Application.ProcessMessages` da DLL bombeia mensagens do IDE (reentrância) | Aceitável para o teste; já era assim nos IDEs anteriores. Resolver de vez no port da DLL |
| High DPI | Janelas da DLL minúsculas e com layout quebrado em monitores com escala | Contexto de DPI por thread (6.3-6) |
| Exceções cruzando módulos | Objeto de exceção D2007 incompatível com o RTL 13 → AV ao exibir | `try…except` genérico nas chamadas; nunca deixar escapar das callbacks |
| `bds.exe` é LARGEADDRESSAWARE | Código antigo (D2007, JVCL/ICS) com aritmética de ponteiro em `Integer` pode falhar com endereços > 2 GB | Monitorar; se houver AV aleatório, é um forte indício. Corrigir no port da DLL |
| Palavra de controle da FPU/estado global | A DLL Delphi pode reinicializar o 8087CW ao carregar | Baixo (o IDE usa o mesmo default `$1332`). Se necessário, salvar e restaurar o CW em volta do `LoadLibrary`/`INIT` |
| Detecção de IDE na DLL (`JVCSIDESettings`) | BDS 37 vira `IDEUnknown`, tratado como Delphi | Nada a fazer no expert |
| Auto-login no startup | Com `ShowLoad = True`, a DLL abre o diálogo de conexão durante o carregamento do IDE | Comportamento original; pode-se adiar a chamada a `INIT` para depois do splash |
| IDE 64 bits | Não carrega DLL 32 bits | Só após o port da DLL para Win64 (`Experts x64`) |

---

### Apêndice A: endereços úteis no `JvcsExpertBDS21.dll`

| Endereço | Rotina |
|---|---|
| 0x40B7C8 | `INITWIZARD0001` |
| 0x40B6D8 | `FinalizeWizard` (Terminate) |
| 0x40A084 | `TJVCSWizard.Create` |
| 0x40A75C | `TJVCSWizard.Destroy` |
| 0x409FFC | diretório do expert |
| 0x40A988 | `LoadMenuImages` |
| 0x40ABB0 | `GetVerbInfo` |
| 0x40ACF0 | `CreateActions` |
| 0x40AF7C | `UpdateMenu` / `OnClick` |
| 0x40B1D0 | `Action.OnUpdate` |
| 0x40B2FC | `Action.OnExecute` |
| 0x40B394 | `ClearFunctionRecs` |
| 0x40B434 | `BindKeyboard` |
| 0x40B504 | `KeyBindingCallback` |
| 0x40B560 / 0x40B614 | Add / Remove `KeyboardBinding` |
| 0x407E28 | `TIdeNotifier.FileNotification` |
| 0x40838C / 0x4083A8 | `BeforeCompile` / `AfterCompile` (50) |
| 0x4083C4 | fechamento de projeto (`TProjectCloseNotifier`) |
| 0x4057D8 | `TJVCSProjectMenuCreatorNotifier.AddMenu` |
| 0x404734–0x405044 | History |
| 0x4046DC / 0x4054F4 | chamadas a `JEDIVCSDLLHISTORYINIT` / `JEDIVCSDLLOPERATIONINIT` |

### Apêndice B: método

- **Parsing de PE**: cabeçalhos, seções, exports, imports, recursos, `VS_VERSION_INFO` e
  `PACKAGEINFO`.
- **Strings**: ASCII e UTF-16 com 5 caracteres ou mais, e literais `UnicodeString` do Delphi.
- **RTTI estendida do Delphi 2010+**: tabelas de métodos e de interfaces das VMTs, que dão nomes
  de classes e métodos, GUIDs implementados e vtables.
- **GUIDs**: varredura de bytes contra os GUIDs dos fontes `Studio\37.0\source\ToolsAPI\*.pas`.
- **Offsets de vtable**: calculados a partir desses fontes.
- **Disassembly**: `llvm-objdump -d -M intel`, anotado com nomes de IAT, thunks e literais.

O IDE de destino (`bds.exe` 32 e 64 bits, LAA) e a existência de `Experts x64` foram verificados
apenas por leitura de arquivos e do registro HKCU. Nada foi gravado fora de uma pasta temporária, exceto este
documento.
