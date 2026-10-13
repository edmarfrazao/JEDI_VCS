# Units principais

As units que mais importam para entender e manter o cliente, por área. Uma linha por unit; caminho
relativo à raiz do repositório. Mapa geral: [README](README.md); como se ligam:
[Arquitetura](Arquitetura.md).

## Transporte (MidWare/ICS)

| Unit | Caminho | Papel |
|---|---|---|
| `ApsCli` | `src\comp\midware\ApsCli.pas` | `TAppSrvClient`: conexão TCP (ICS 9, IPv4), envio/recebimento de requisições MidWare |
| `RFormat` | `src\comp\midware\RFormat.pas` | `TMWBuffer`: serialização dos campos; code page fixa `MWCodePage = 1252` |
| `CBroker` | `src\comp\midware\CBroker.pas` | broker de clientes do MidWare |
| `MWDefs.inc` | `src\comp\midware\MWDefs.inc` | defines do MidWare sobre o `OverbyteIcsDefs.inc` |
| `DBModule` | `src\jedivcs\DBModule.pas` | data module do cliente GUI: instância do `TAppSrvClient`, envio de requisições, erro explícito para resposta cifrada LZH |
| `JVCSConnect` | `src\common\client\JVCSConnect.pas` | conexão do núcleo (servidor, porta, sessão) |
| `JVCSClientDispatcher` | `src\common\client\JVCSClientDispatcher.pas` | despacho das requisições por thread (`USECLIENTDISPATCHER`) |

## Núcleo do cliente (protocolo e dados)

| Unit | Caminho | Papel |
|---|---|---|
| `JVCSClientObjBase` | `src\common\client\JVCSClientObjBase.pas` | classe base dos objetos de requisição; blob ZIP com a data do arquivo |
| `JVCSClientObj` | `src\common\client\JVCSClientObj.pas` | um objeto por função do servidor (`LOGIN`, `CHECKIN_MODULE`, `GET_CHECKOUT_MODULE`...) |
| `JVCSBranchClientObj` | `src\common\client\JVCSBranchClientObj.pas` | requisições de branch (`BRANCHING`) |
| `JVCSClientFunctions` | `src\common\client\JVCSClientFunctions.pas` | utilitários (`IsTextStream`, `IsBinaryDFMStream`, `GetSelfFileName`) |
| `JVCSClientConsts` / `JVCSTypes` | `src\common\client\` | constantes e tipos do protocolo |
| `JVCSCrypt` | `src\common\client\JVCSCrypt.pas` | cifra da senha do login via `fvcscrypt.dll` |
| `BFCrypt` | `src\common\client\BFCrypt.pas` | Base64 e Blowfish recriados do binário 2.5.0.1030 (blobs cifrados, backup) |
| `Checksum` | `src\comp\crc\Checksum.pas` | `CRCInt`/`CRCString` (CRC-32 idêntico ao original) |
| `TZHandling` | `src\common\client\TZHandling.pas` | conversão de datas local/UTC do servidor |
| `VCSCommon` | `src\common\VCSCommon.pas` | tipos e rotinas comuns a todos os alvos |
| `VCSBase` / `VCSProcBase` | `src\jedivcs\` | estado global do cliente, versão do LOGIN (`GetJVCSAppProductVersionInt`), rotinas compartilhadas |
| `ConfigStorage` | `src\jedivcs\ConfigStorage.pas` | leitura/gravação das opções em `HKCU\Software\JEDI\JEDIVCS` |
| `diffunit` / `hashunit` | `src\comp\textdiff\` | algoritmo de diff (Compare, Line History) |
| `mwPasLex` | `src\comp\mwtools\mwPasLex.pas` | lexer Pascal mínimo (Used Units) |

## GUI do cliente

| Unit | Caminho | Papel |
|---|---|---|
| `ProjAdmin` | `src\jedivcs\ProjAdmin.pas` | janela principal (Project Manager): árvore de projetos, lista de módulos |
| `Create` | `src\jedivcs\Create.pas` | `TVCSLoad`: Server Login, identidades, aviso de projeto ausente na DLL |
| `ChkInSingle` / `ChkOutSingle` | `src\jedivcs\` | diálogos de check-in e checkout |
| `JVCSChkInOutCommon` | `src\jedivcs\JVCSChkInOutCommon.pas` | lógica comum de check-in e checkout |
| `Syncronice` | `src\jedivcs\Syncronice.pas` | sincronização do projeto local com o servidor |
| `Backup` / `SaveWIP` | `src\jedivcs\` | backup do projeto (com senha) e Save WIP (recurso de 2012) |
| `ExtBugtracker` | `src\jedivcs\ExtBugtracker.pas` | link do comentário para o bugtracker externo (`TRegEx`) |
| `Options` | `src\jedivcs\Options.pas` | VCS Properties (inclui as páginas Appearance e AI / Automation) |
| `JVCSListView` | `src\common\JVCSListView.pas` | `TJVCSListView`, substituto nativo do DFS EnhListView |
| `JVCSStatusBar` / `JVCSFolderTree` | `src\jedivcs\` | substitutos nativos do dfsStatusBar e do SystemTreeView |
| `JVCSFileSearch` / `FavOpenDialog` | `src\common\` | substitutos do RekScan e do FavOpenDialog |
| `JVCSDialogs` / `JVCSMruList` | `src\jedivcs\` | diálogos "não mostrar de novo" (DSA) e lista MRU sem JVCL não visual |
| `JVCSBaseAboutDialog` | `src\common\JVCSBaseAboutDialog.pas` | About comum (créditos, aviso do MidWare) |
| `DiffMain` | `src\jedivcsdiff\DiffMain.pas` | janela do `JEDIVCSDiff` |

## Aparência e tema

| Unit | Caminho | Papel |
|---|---|---|
| `JVCSUIScale` | `src\common\client\JVCSUIScale.pas` | fonte, tamanho e escala da interface, menus owner-draw e editores |
| `JVCSUITheme` | `src\common\client\JVCSUITheme.pas` | tema seguir host/claro/escuro; Windows e IDE (`JVCS_IDE_THEME`) |
| `JVCSUIStyles.rc` | `src\common\client\JVCSUIStyles.rc` | VCL Style "Windows Modern Dark" embutido (`styles\WindowsModernDark.vsf`) |
| `JVCSForms` | `src\common\JVCSForms.pas` | `TJVCSForm`: aplica a aparência e o tamanho mínimo a cada form |
| `JVCSClientAppearance` | `src\jedivcs\JVCSClientAppearance.pas` | inicializa e reaplica a aparência no EXE e na DLL |

## IA e diagnóstico

| Unit | Caminho | Papel |
|---|---|---|
| `JVCSAIConfig` | `src\common\client\JVCSAIConfig.pas` | lê/grava `%APPDATA%\JEDI\JVCS\config.ini` (`[ai]`), preservando o formato |
| `JVCSErrorLog` | `src\common\client\JVCSErrorLog.pas` | log de exceções em `%LOCALAPPDATA%\JEDI\JVCS\logs` (nunca levanta exceção) |
| `JVCSDebug` | `src\common\JVCSDebug.pas` | mensagens de depuração |
| `JVCSFormSweep` | `src\jedivcs\JVCSFormSweep.pas` | **só Debug**: `-formsweep` e automação `JVCS_DEBUG_AUTOMATION` |

## DLL da IDE (lado DLL da ABI)

| Unit | Caminho | Papel |
|---|---|---|
| `JediVCSDLL.dpr` | `src\jedivcs\JediVCSDLL.dpr` | exports `JEDIVCSDLLINIT/FINALIZE/HISTORYINIT/OPERATIONINIT`, verbos do menu |
| `JVCSIDEInterfaceCommon` | `src\common\JVCSIDEInterfaceCommon.pas` | records e tipos da ABI (`stdcall`, `PAnsiChar`, `{$Z1}`) |
| `JVCSIDEInterface` | `src\jedivcs\JVCSIDEInterface.pas` | uso das 24 callbacks do expert pela DLL |
| `JVCSDLLAnsi` | `src\jedivcs\JVCSDLLAnsi.pas` | conversões ANSI sem "best fit" e cópia limitada para buffers do expert |
| `JVCSDLLFileHistoryImpl` | `src\jedivcs\JVCSDLLFileHistoryImpl.pas` | 9 funções de History |
| `JVCSDLLOperations` | `src\jedivcs\JVCSDLLOperations.pas` | 10 operações do menu do Project Manager |
| `JVCSIDESettings` | `src\common\JVCSIDESettings.pas` | detecção da IDE e chaves de registro dela |

## Expert (ToolsAPI)

| Unit | Caminho | Papel |
|---|---|---|
| `JvcsExpertBDS.dpr` | `src\jvcsideexpert\JvcsExpertBDS.dpr` | entrada `INITWIZARD0001` |
| `JVCSExpertWizard` | `src\jvcsideexpert\JVCSExpertWizard.pas` | wizard: splash, menu JEDI VCS, ações, atalhos (sem genéricos) |
| `JVCSExpertDllBridge` | `src\jvcsideexpert\JVCSExpertDllBridge.pas` | `TJVCSDllBridge`: carrega a DLL da pasta do expert e chama os exports |
| `JVCSExpertCallbacks` | `src\jvcsideexpert\JVCSExpertCallbacks.pas` | as 24 callbacks implementadas sobre a ToolsAPI |
| `JVCSExpertABI` | `src\jvcsideexpert\JVCSExpertABI.pas` | cópia dos records da ABI no lado do expert |
| `JVCSExpertNotifiers` | `src\jvcsideexpert\JVCSExpertNotifiers.pas` | notificações de arquivo/compilação e do tema da IDE (`JVCS_IDE_THEME`) |
| `JVCSExpertHistory` | `src\jvcsideexpert\JVCSExpertHistory.pas` | `IOTAFileHistoryProvider` sobre o `HistoryRec` |
| `JVCSExpertProjMenu` | `src\jvcsideexpert\JVCSExpertProjMenu.pas` | menu de contexto do Project Manager |
| `JVCSExpertUtils` | `src\jvcsideexpert\JVCSExpertUtils.pas` | log do expert, guarda de FPU, utilitários |

## Testes

| Unit / projeto | Caminho | Papel |
|---|---|---|
| `JvcsDllHarness` | `src\jvcsideexpert\tests\JvcsDllHarness.dpr` | host console da DLL com as callbacks reais; conta AVs |
| `JvcsDllInterativo` | `src\jvcsideexpert\tests\JvcsDllInterativo.dpr` | "Fake IDE" interativa |
| `JvcsExpertSmokeTest` | `src\jvcsideexpert\tests\JvcsExpertSmokeTest.dpr` | carrega o expert com a ToolsAPI real |
| `FakeJvcsExternalDll` | `src\jvcsideexpert\tests\FakeJvcsExternalDll.dpr` | DLL falsa para testar o expert |
| `JvcsAbiCrossCheck` | `src\jvcsideexpert\tests\JvcsAbiCrossCheck.pas` | confere `JVCSExpertABI` × `JVCSIDEInterfaceCommon` |
| golden do console | `tools\golden\console\` | `proxy.ps1`, `norm.pl`, `blobs.pl`, `g.sh` |
