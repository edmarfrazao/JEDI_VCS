# 06. Building from source

Summary of the build scripts. Full reference (Portuguese): [doc/fontes/Compilacao.md](../fontes/Compilacao.md)
and [tools/LEIAME-compilar.md](../../tools/LEIAME-compilar.md).
Previous: [05 Using with AI](05-Using-with-AI.md). Next: [07 FAQ and troubleshooting](07-FAQ-and-Troubleshooting.md).

## 1. Requirements

| Item | Delphi 13 (reference) | Delphi 11 / 12 |
|---|---|---|
| Delphi | 13 Florence, Win32 platform | 11.3 / 12.x, Win32; open and close the IDE once |
| JCL, JVCL, ICS 9.7, Abbrevia | GetIt | GetIt (or GitHub at an equivalent commit) |
| SynEdit, VirtualTreeView | **from this repository** (target `libs`), never the GetIt versions | same |
| Inno Setup 6 | only to build the installer | — |

The command-line compiler (`dcc32`) does not read the IDE Library Path. The scripts build the paths from
`tools\versoes.ini` and find the libraries in the GetIt `CatalogRepository` (also when the Documents folder
was moved by OneDrive). If they are not found, run `tools\compilar.bat /info` or set
`JVCS_CATALOG=<CatalogRepository folder>`.

## 2. Scripts

Run them from the repository root in `cmd.exe`. Exit code 0 = OK. `compilar.bat /?` shows the help.

| Script | Usage | Output |
|---|---|---|
| `tools\compilar.bat` | `[/delphi:11\|12\|13] [/info] [/msbuild] [exe\|dll\|diff\|console\|libs\|all] [Debug\|Release] [Win32\|Win64]` | EXE, DLL, Diff, console; `libs` = SynEdit/VirtualTreeView |
| `tools\compilar-expert.bat` | `[/delphi:11\|12\|13] [Debug\|Release] [nova\|original]` | `bin\ideclient\Win32\JvcsExpertBDS<nn>.dll` + runtime + the core DLL (`nova` = new, `original` = 2.5.0.1030) |
| `tools\gerar-instalador.bat` | `[--sem-build]` | `setup\Output\JediVCS-2.5-Beta2026-Setup.exe` (`--sem-build` packs what is already in `bin\`) |
| `tools\verificar-expert.ps1` | `-Expert <dll> [-BplDir <folder>] [-Inits] [-Permitidos rtl,vcl,xmlrtl]` | exit code 0 = the expert loads in that Delphi update |

Defaults: Delphi 13, `all`, `Debug`, `Win32`.

## 3. Recipes

```
rem first time on each Delphi version (Delphi closed)
tools\compilar.bat /info
tools\compilar.bat libs Release Win32

rem the four targets
tools\compilar.bat all Release Win32

rem expert + new core DLL, to test in the IDE (close Delphi first)
tools\compilar-expert.bat Release nova

rem Delphi 11 or 12
tools\compilar.bat /delphi:11 all Release Win32
tools\compilar-expert.bat /delphi:12 Release nova

rem with the .dproj files (MSBuild)
tools\compilar.bat /msbuild all Release Win32

rem installer
tools\gerar-instalador.bat
```

You can also open `JediVCS2026.groupproj` in the IDE (projects `Jedivcs`, `JediVCSDLL`, `JEDIVCSDiff`,
`jvcs` and `JvcsExpertBDS`). Do **not** accept changes that the IDE proposes to the `.dpr` files.

## 4. Outputs

| What | Delphi 13 | Delphi 11 / 12 |
|---|---|---|
| EXE / DLL / Diff / console | `bin\client\Win32` | `bin\client\D11\Win32` / `bin\client\D12\Win32` |
| Expert + runtime for the IDE | `bin\ideclient\Win32` | same folder (`JvcsExpertBDS22/23.dll`) |
| Installer | `setup\Output\` | — |
| Build logs | `tools\logs\` | |

## 5. Expert rules (Delphi 11, 12 and 13)

So that one expert loads in **every update** of a Delphi version:

1. The expert may import only `rtl<nn>`, `vcl<nn>` and `xmlrtl<nn>` — no design-time packages. New
   features go into `JvcsExternalDll.dll` (self-contained, no packages).
2. No RTL generics in the expert (`TList<T>`, `TDictionary<K,V>`...).
3. Before a release, run `verificar-expert.ps1 -BplDir <.bpl of each supported update>` with 0 missing
   imports. `compilar-expert.bat` and `gerar-instalador.bat` run this check automatically.

Background: an expert built on 13.2 did not load on 13.1 ("Could not find Wizard"), because importing
design-time units pulls in a unit that exists only in 13.2. Details (Portuguese):
[Port-DLL-IDE §5A](../client/Port-DLL-IDE.md).

## 6. Conventions

Delphi sources are **Windows-1252 with CRLF** line endings (`.gitattributes` keeps the exact bytes). Keep
the defines of the `.dproj` files equal to those in `compilar.bat`. Before a pull request: build the four
targets in Debug and Release and run the tests of the area you changed. Details (Portuguese):
[Convenções](../fontes/Convencoes.md).
