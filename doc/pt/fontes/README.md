# Documentação dos fontes

Mapa do código do JEDI VCS 2.5 Beta 2026: o que cada projeto gera, o que há em cada pasta de `src\` e do
que cada alvo depende. Os caminhos são relativos à raiz do repositório (`<pasta-do-projeto>`).

| Página | Conteúdo |
|---|---|
| [Arquitetura](Arquitetura.md) | Diagrama dos módulos, fluxo de um check-in, ABI expert↔DLL |
| [Units principais](Units-Principais.md) | Tabela das units mais importantes por área |
| [Compilação](Compilacao.md) | `compilar.bat`, `compilar-expert.bat`, `gerar-instalador.bat`, Delphi 11/12/13, `.dproj`/MSBuild |
| [Convenções](Convencoes.md) | Codificação, defines, versão, commits, como contribuir |

## 1. Projetos e o que geram

| Projeto (`.dpr` + `.dproj`) | Pasta | Gera | Chave no `compilar.bat` |
|---|---|---|---|
| `Jedivcs` | `src\jedivcs` | `bin\client\Win32\Jedivcs.exe` — cliente standalone (GUI) | `exe` |
| `JediVCSDLL` | `src\jedivcs` | `bin\client\Win32\JvcsExternalDll.dll` — o mesmo cliente como DLL para a IDE (renomeada no build) | `dll` |
| `JEDIVCSDiff` | `src\jedivcsdiff` | `bin\client\Win32\JEDIVCSDiff.exe` — comparador | `diff` |
| `jvcs` | `src\jvcs` | `bin\client\Win32\jvcs.exe` — console | `console` |
| `JvcsExpertBDS` | `src\jvcsideexpert` | `bin\ideclient\Win32\JvcsExpertBDS22/23/37.dll` — expert ToolsAPI por versão do Delphi | `compilar-expert.bat` |
| `JediVCS2026.groupproj` | raiz | grupo com os 5 projetos acima, para abrir na IDE | `/msbuild` |

Projetos de teste em `src\jvcsideexpert\tests`: `JvcsDllHarness`, `JvcsDllInterativo`,
`JvcsExpertSmokeTest`, `FakeJvcsExternalDll` (ver [04 Testes](../processo/04-Testes-e-Validacao.md)).

## 2. Pastas de `src`

| Pasta | Conteúdo |
|---|---|
| `src\jedivcs` | Forms e lógica do cliente GUI (EXE e DLL): `ProjAdmin` (janela principal), `Create` (login), `ChkInSingle`/`ChkOutSingle`, `Options`, `Backup`, `Syncronice`, `DBModule`, `VCSBase`/`VCSProcBase`, `JVCSIDEInterface` e `JVCSDLL*` (só DLL), `JVCSFormSweep` (só Debug) — ~126 units |
| `src\jedivcsdiff` | `JEDIVCSDiff`: `DiffMain`, propriedades do editor/realce, relatório, MRU |
| `src\jvcs` | `jvcs.dpr` (console; usa units de `src\jedivcs` e `src\common`) |
| `src\jvcsideexpert` | Expert ToolsAPI: wizard, ponte com a DLL, 24 callbacks, notifiers, History, menu do Project Manager ([LEIAME](../../../src/jvcsideexpert/LEIAME.md)) |
| `src\common` | Units compartilhadas por EXE/DLL/Diff: `JVCSForms`, `JVCSListView`, `JVCSBaseAboutDialog`, `JVCSIDEInterfaceCommon` (ABI), `JVCSIDESettings`, `VCSCommon` |
| `src\common\client` | Núcleo do cliente sem VCL de forms: objetos de requisição (`JVCSClientObj*`), conexão, dispatcher, cripto (`JVCSCrypt`, `BFCrypt`), aparência (`JVCSUIScale`, `JVCSUITheme`), `JVCSAIConfig`, `JVCSErrorLog`, Line History e Compressed Diff |
| `src\comp\midware` | Transporte MidWare portado (`ApsCli`, `RFormat`, `CBroker`) — licença não comercial ([LEIAME](../../../src/comp/midware/LEIAME.md)) |
| `src\comp\crc` | `Checksum.pas` (CRC-32 idêntico ao 2.5.0.1030) |
| `src\comp\textdiff` | `diffunit`, `hashunit` (algoritmo de diff) |
| `src\comp\mwtools` | `mwPasLex` mínimo (lexer Pascal para Used Units) |
| `src\comp\mdmailslot` | mailslot (notificação; só compila) |
| `src\comp\synedit`, `src\comp\virtualtreeview` | Bibliotecas **fixadas** no repositório (SynEdit pyscripter `84391a3`, VTV V8.5) |
| `src\comp\_legacy` | Cópia intacta dos componentes do fork, **só referência** (fora do search path) |
| `src\packages` | Pacote design-time do MidWare (a criar) |

Fora de `src`: `tools\` (scripts de build, golden, canal, `ai`), `setup\` (Inno Setup e `.reg` de
desenvolvimento), `3rdparty\` (runtime do 2.5.0.1030 e binários de referência), `doc\`.

## 3. Dependências por alvo

| Alvo | MidWare + ICS | JCL | JVCL | Abbrevia | SynEdit | VTV | Runtime |
|---|---|---|---|---|---|---|---|
| `Jedivcs.exe` | sim | sim | sim (ponte) | sim | sim | sim | `fvcscrypt.dll`, `*.jvcs`, `htm_rep.htm`, `jedivcs.chm` |
| `JvcsExternalDll.dll` | sim | sim | sim (ponte) | sim | sim | sim | idem + `JEDIVCSDiff.exe` na mesma pasta |
| `JEDIVCSDiff.exe` | não | só `jedi.inc` | não | não | sim | não | `jedivcsdiff.chm` |
| `jvcs.exe` | sim | sim | não | sim | não | não | `fvcscrypt.dll` |
| `JvcsExpertBDS<nn>.dll` | não | não | não | não | não | não | `rtl`, `vcl`, `xmlrtl` da própria IDE + `JvcsExternalDll.dll` |

Tudo é linkado **estaticamente** (sem runtime packages), exceto o expert. Por isso o Delphi do usuário não
precisa de nenhum componente instalado. Versões exatas: [Versoes](../common/Versoes.md); licenças:
[Componentes](../common/Componentes.md) e [Licencas](../common/Licencas.md).
