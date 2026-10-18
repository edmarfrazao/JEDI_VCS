# Compilação

Resumo consolidado de [tools/LEIAME-compilar.md](../../../tools/LEIAME-compilar.md) (referência completa,
com todas as variáveis de ambiente) e de [setup/LEIAME.md](../../../setup/LEIAME.md). Comandos rodam a partir
da raiz do repositório (`<pasta-do-projeto>`), num `cmd.exe`.

## 1. Pré-requisitos

| Item | Delphi 13 (referência) | Delphi 11 / 12 |
|---|---|---|
| Delphi | 13 Florence, plataforma Win32 | 11.3 / 12.x, Win32; abrir e fechar a IDE uma vez |
| JCL, JVCL, ICS 9.7, Abbrevia | GetIt | GetIt (ou GitHub num commit equivalente); conferir com `/info` |
| SynEdit, VirtualTreeView | **do repositório** (alvo `libs`), nunca os do GetIt | idem |
| Inno Setup 6 | só para gerar o instalador | — |

O `dcc32` de linha de comando **não lê o Library Path da IDE**: o script monta os caminhos a partir de
`tools\versoes.ini` e procura as bibliotecas no `CatalogRepository` do GetIt (inclusive com a pasta
Documentos redirecionada para o OneDrive). Checklist do 11/12: [manual 10](../manual/10-Delphi-11-e-12.md).

## 2. Scripts

| Script | Uso | Gera |
|---|---|---|
| `tools\compilar.bat` | `[/delphi:11\|12\|13] [/info] [/msbuild] [exe\|dll\|diff\|console\|libs\|all] [Debug\|Release] [Win32\|Win64]` | EXE, DLL, Diff, console; `libs` = SynEdit/VTV |
| `tools\compilar-expert.bat` | `[/delphi:11\|12\|13] [Debug\|Release] [nova\|original]` | `bin\ideclient\Win32\JvcsExpertBDS<nn>.dll` + runtime e a DLL (nova ou a 2.5.0.1030) |
| `tools\gerar-instalador.bat` | `[--sem-build]` | `setup\Output\JediVCS-2.5.0-Beta<N>-build<Build>-Setup.exe` (ex.: `...-Beta5-build2050-Setup.exe`) |
| `tools\gerar-versao.ps1` + `tools\versao.ini` | chamado pelos dois scripts de build | versão (`FILEVERSION 2.5.0.<Build>`, beta) de todos os binários: `src\common\jvcsversao.rh` e os `jvcsver.res` (fora do git) |
| `tools\verificar-expert.ps1` | `-Expert <dll> [-BplDir <pasta>] [-Inits] [-Permitidos rtl,vcl,xmlrtl]` | código 0 = o expert carrega naquela atualização |
| `tools\gerar-toolsapi.ps1` | chamado pelo build do expert | cópia local da ToolsAPI sem `DockForm` (fora do git) |
| `tools\versao-delphi.bat` + `tools\versoes.ini` | usados pelos scripts | tudo o que muda por versão do Delphi |

Padrões: Delphi 13, `all`, `Debug`, `Win32`. Código de saída 0 = tudo OK. `compilar.bat /?` mostra a ajuda.

**Gerar o instalador à mão:** `instalador\bin\gerar.bat` (ver [instalador/doc/COMO-GERAR.md](../../../instalador/doc/COMO-GERAR.md)).

**Subir a versão:** edite só `tools\versao.ini` (`Build=2050`, `Stage=Beta`, `StageNumber=5`; beta 6 = 2060,
correção da mesma beta = +1, final = 2100 com `Stage=Release`) e recompile; EXE, DLL, Diff, console,
experts e instalador saem com a nova versão. Regra e motivo: [Versoes.md, "Numeração de versões"](../common/Versoes.md#numeração-de-versões).
Pela IDE, sem os scripts, gere antes os `.res`: `powershell -File tools\gerar-versao.ps1 -Brcc <brcc32.exe> -Rc src\jedivcs\jvcsver.rc,src\jedivcsdiff\jvcsver.rc,src\jvcs\jvcsver.rc`.

## 3. Receitas

```
rem primeira vez em cada versão do Delphi (Delphi fechado)
tools\compilar.bat /info
tools\compilar.bat libs Release Win32

rem os 4 alvos
tools\compilar.bat all Release Win32

rem expert + DLL nova para testar na IDE
tools\compilar-expert.bat Release nova

rem Delphi 11 ou 12 (verificação; o binário distribuído é o do 13)
tools\compilar.bat /delphi:11 all Release Win32
tools\compilar-expert.bat /delphi:12 Release nova

rem pelos .dproj (MSBuild)
tools\compilar.bat /msbuild all Release Win32

rem pacote final
tools\gerar-instalador.bat
```

## 4. Projetos `.dproj` e a IDE

- `JediVCS2026.groupproj` (raiz) agrupa `Jedivcs`, `JediVCSDLL`, `JEDIVCSDiff`, `jvcs` e `JvcsExpertBDS`.
- Formato do Delphi 11 (abre em 11/12/13; as IDEs novas atualizam ao salvar — pode aceitar). **Não aceite**
  mudanças que a IDE propuser nos `.dpr`.
- O comum fica em `tools\msbuild\JediVCS2026.props` (versão pela `dcc32<pkg>.dll`, caminhos das
  bibliotecas via `lib\paths\JediVCS2026-<BDS>.props` gravado pelo `compilar.bat`, defines, codepage 1252).
- **Mantenha os defines dos `.dproj` iguais aos do `compilar.bat`.**
- Saída do MSBuild sempre fora de `bin\client`: `bin\msbuild\<Dnn>\<plat>\<cfg>`. O instalador usa o que o
  `compilar.bat` gera.

## 5. Defines por alvo

| Alvo | Defines (além de `DEBUG`/`RELEASE` e `OVERBYTEV6_UP`) |
|---|---|
| `exe` | `USECLIENTDISPATCHER;BRANCHING;JVCS_NOBRANCHUI;UNISYNEDIT` |
| `dll` | `IDEDLL;EXT_IDE_INTF;USECLIENTDISPATCHER;BRANCHING;JVCS_NOBRANCHUI;UNISYNEDIT` |
| `diff` | `DelphiPersonalEdition` |
| `console` | `DelphiPersonalEdition;JVCSCONSOLECLIENT;BRANCHING` |

Extras para todos: `set JVCS_EXTRA_DEFS=...`. Opções do compilador: `--codepage:1252`, `-B`,
`--no-config`; Debug com `$R+ $Q+ $C+` e `.map`, Release otimizado.

## 6. Saídas e logs

| O quê | Delphi 13 | Delphi 11 / 12 |
|---|---|---|
| EXE / DLL / Diff / console (+ `.map`) | `bin\client\Win32` | `bin\client\D11\Win32` / `bin\client\D12\Win32` |
| Expert + runtime para a IDE | `bin\ideclient\Win32` (`JvcsExpertBDS37.dll`) | mesma pasta (`...BDS22.dll` / `...BDS23.dll`) |
| DCUs | `dcu\Win32\<cfg>\<alvo>` | `dcu\D11\...` / `dcu\D12\...` |
| SynEdit/VTV (`libs`) | `lib\...` (BPL `...370.bpl`) | `lib\D11\...` (`280`) / `lib\D12\...` (`290`) |
| MSBuild | `bin\msbuild\D13\<plat>\<cfg>` | `bin\msbuild\D11\...` |
| Instalador | `setup\Output\` | — |
| Logs | `tools\logs\compilar_<alvo>_<plat>_<cfg>.log`, `compilar_D11_...`, `compilar_msbuild_...`, `gerar-instalador.log` | |

`bin\client\**`, `dcu\`, `lib\`, `bin\msbuild\`, `setup\Output\` e `tools\logs\` estão no `.gitignore`.
Depois de cada build o script copia para a saída o runtime de `3rdparty` (`fvcscrypt.dll`, ajudas `.chm`,
`*.jvcs`).

## 7. Verificar o expert

Política (vale para 11, 12 e 13): o expert só importa `rtl`, `vcl` e `xmlrtl`; sem genéricos da RTL;
compilar de preferência na atualização mais antiga suportada; antes de publicar, rodar
`verificar-expert.ps1 -BplDir <.bpl de cada atualização>` com 0 ausentes. Detalhe:
[Port-DLL-IDE §5A](../client/Port-DLL-IDE.md).

## 8. Problemas comuns

| Sintoma | O que fazer |
|---|---|
| `F2613 Unit '...' not found` / `jedi.inc` não encontrado | `compilar.bat /info`; conferir `tools\versoes.ini` ou `set JVCS_CATALOG=<CatalogRepository>` |
| `[ERRO] Delphi NN ... nao esta instalado` | versão pedida não existe nesta máquina |
| Build do expert falha ao gravar | Delphi aberto com o expert carregado: feche a IDE |
| `libs` falha ao gravar BPL | IDE aberta com o BPL carregado |
| MSBuild recompila ICS/Abbrevia | normal com `/p:ImportEnvOptions=true`; o padrão é `false` |

Mais em [06 Problemas conhecidos](../processo/06-Problemas-Conhecidos-e-Licoes.md).
