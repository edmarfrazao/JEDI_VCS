🇺🇸 English · [🇧🇷 Português](README.pt-BR.md)

# JEDI VCS 2.5 Beta 2026

> ⚠️ **Disclaimer:** this product is provided without any warranty of operation. Test and validate it in your own environment, with a backup and a copy of your JEDI VCS database, and apply any local fixes you need before deploying to production. Read the [full disclaimer](DISCLAIMER.md).

The **JEDI VCS** client (client/server version control for Delphi teams) ported to **Delphi 11, 12 and
13**, with IDE integration, light/dark theme, font scaling and support for AI coding assistants. It speaks
**exactly the same protocol** as the existing JEDI VCS **2.5 Beta 3** server (Firebird), which is not
changed.

[Download](https://github.com/edmarfrazao/JEDI_VCS/releases/latest) ·
[What's new](news/en/README.md) ·
[User guide (English)](doc/en/README.md) ·
[Full documentation (Portuguese)](doc/pt/README.md) ·
[AI](doc/en/05-Using-with-AI.md) ·
[License](LICENSE)

## What is JEDI VCS?

JEDI VCS (the successor of FreeVCS) is a client/server version control system written in Delphi, for Delphi
teams. The 2.x line was developed by Project JEDI; the main authors were **Thomas Huber** and **Uwe
Schuster**. It has these parts:

| Part | What it does |
|---|---|
| Server (`JVCSSrv.exe`) | Windows application or service, TCP port **2106**, **Firebird** database |
| Standalone client (`Jedivcs.exe`) | Full GUI: projects, check-in/check-out, history, labels, backup, users |
| IDE integration | A ToolsAPI expert (`JvcsExpertBDS<nn>.dll`) plus `JvcsExternalDll.dll` (the same client built as a DLL) |
| Diff tool (`JEDIVCSDiff.exe`) | Compares files and revisions |
| Console (`jvcs.exe`) | Command-line client for scripts and automation |

Work is based on **locks**: you *check out* a module (file) to edit it, and you *check in* the new revision
with a comment. Files that are not checked out stay read-only on disk.

## Why this edition exists

- The last official installer is **2.50 Beta 3** (client 2.5.0.1030). It has no IDE expert for Delphi 11,
  12 or 13, no dark theme and no font scaling.
- The official 2.5 source code was lost with the old project infrastructure. Only forks of older code
  remained.
- Many teams still run 2.5 Beta 3 servers in production.

**JEDI VCS 2.5 Beta 2026** rebuilds the 2.5 **client** (standalone GUI, IDE DLL, Diff and console) from the
remaining sources, ports it to modern Delphi and keeps it **wire-compatible** with the 2.5 Beta 3 server.
The server itself is not ported and does not need any change.

## Status

| Item | Status |
|---|---|
| Version | **2.5 Beta 2026** (`2.5.0.2026`), sixth public beta, **build 2063** (`2.5.0.2063`, tag `v2.5.0.2026-beta6-build2063`); Delphi 7 to 13 supported |
| Delphi | tested on **Delphi 11, 12 and 13** (32-bit IDE) |
| Platform | Win32 (runs on Windows x64 and ARM64 through emulation) |
| Server | JEDI VCS **2.5 Beta 3** (Firebird), not ported, unchanged |

This is a **beta**. Use it with a test server, or back up your database before you use it in production.

## Download

Download the installer of the [latest release](https://github.com/edmarfrazao/JEDI_VCS/releases/latest) (today `JediVCS-2.5.0-Beta6-build2063-Setup.exe`;
older betas are on the [Releases](https://github.com/edmarfrazao/JEDI_VCS/releases) page). Each release page and each
[news page](news/en/README.md) shows the SHA-256 of the installer; check it before you install.

## Features

- **Delphi IDE integration:** **JEDI VCS** menu, shortcuts (Ctrl+Shift+P/I/O/G/B), check-in and
  check-out from the IDE, **History** tab in the editor and a context menu in the IDE Project Manager.
- **Standalone client** (`Jedivcs.exe`) with all 2.5 features: projects, check-in/check-out, history,
  Line History, Compressed Diff, labels, password-protected backup, synchronization, users.
- **Compatible with the original:** works side by side with client 2.5.0.1030 and uses the same
  identities (saved logins).
- **Appearance:** UI scaling from 100% to 200%, font choice (interface, menus, editors), light/dark theme
  that follows Windows (standalone) or the Delphi IDE (integrated).
- **2012 features kept:** External Bugtracker, Save WIP, Compare all local/archive.
- **File families:** `.pas` + `.dfm` + `.fmx` in the same check-in.
- **Console** `jvcs.exe` for scripts and for AI agents.
- **AI:** a wrapper and a skill that let Claude Code (or another agent) check out and check in with human
  approval, while keeping the ANSI encoding of the source files.
- **Inno Setup installer** (English and Brazilian Portuguese) that registers the expert only in the
  installed IDEs and undoes everything on uninstall.

## Supported Delphi versions

| Delphi | How | Since (2026 beta) | Status |
|---|---|---|---|
| Delphi 7, 2005, 2006, 2007, 2009, 2010, XE–XE8, 10 Seattle, 10.1 Berlin, 10.2 Tokyo, 10.3 Rio, 10.4 Sydney (also C#Builder 1 and Delphi 8 for .NET) | **original** thin expert from 2.5.0.1030 + **new** core `JvcsExternalDll.dll` | 2026 beta 3 | **being tested** (installer tested; not yet tested in a real old IDE) |
| Delphi 11 Alexandria, 12 Athens, 13 Florence — **any update** | new expert `JvcsExpertBDS22/23/37.dll` + new core | 2026 beta 2 | tested on 11.3, 12, 13.1 and 13.2 |
| Delphi 5 and 6 (and C++Builder 5/6) | not supported (the original used a different full client) | — | keep the original installer |
| 64-bit IDE (`bin64\bds.exe`, Delphi 12.3+/13) | not supported (the core and `fvcscrypt.dll` are 32-bit) | — | use the 32-bit IDE |
| No IDE | standalone client, Diff and console | 2026 beta 1 | Windows 10/11 |

No third-party components need to be installed in the target IDE: JCL, JVCL, ICS, Abbrevia, SynEdit and
VirtualTreeView are compiled into the core DLL.

## Server compatibility (2.5 Beta 3)

- Same bytes on the wire: text in **Windows-1252**, CRC-32, Blowfish, Base64 and ZIP blobs identical to
  client 2.5.0.1030 (verified with golden traffic captures and cross-reading of revisions).
- The original client reads what the new client writes, and the other way round. Both can be connected at
  the same time (with different user names: the server accepts one session per user).
- Server features that depend on branching work with the `HEAD` branch; the branch UI is hidden.
- Not supported: LZH traffic encryption (if the server requires it, the connection fails with a clear
  message), external reports, notifications between workstations.

## Requirements

| For | You need |
|---|---|
| Using the client | Windows 10/11; a reachable JEDI VCS 2.5 Beta 3 server (port 2106) |
| IDE integration | A supported Delphi (see the table above), **32-bit IDE**; no third-party components |
| Building | Delphi 13 (reference) or 11/12; JCL, JVCL, ICS 9.7 and Abbrevia (GetIt); SynEdit and VirtualTreeView are in this repository |
| Server (if you do not have one) | JEDI VCS Firebird Server 2.50 Beta 3 + Firebird 2.5 — see [manual 01 (Portuguese)](doc/pt/manual/01-Servidor-Instalacao-e-Configuracao.md) |

## Quick install

1. Close Delphi.
2. Download the installer of the [latest release](https://github.com/edmarfrazao/JEDI_VCS/releases/latest)
   (`JediVCS-2.5.0-Beta6-build2063-Setup.exe`) and run it **from Explorer, as your own
   Windows user** (English or Portuguese; you can install for the current user only).
3. Start Delphi: the splash screen shows "JEDI Version Control System 2.5 Beta 2026" and the
   **JEDI VCS** menu appears.
4. **JEDI VCS → Connect Server**: enter the server address (prefer the numeric IP address), port `2106`,
   user and password. On a new database the initial user is `sysdba` / `admin` (the default of a new
   database — **change it after the first login**).
5. Open your project (with its own name, not `Project1`) and use **Project Manager**, **Check In** and
   **Check Out**.

Step by step: [Installation](doc/en/02-Installation.md) and
[Delphi IDE integration](doc/en/03-Delphi-IDE-Integration.md).

## AI integration

The project includes a workflow that lets AI assistants (Claude Code and other agents) use JEDI VCS
safely: automatic check-out only when the local file is equal to the server revision, check-in with
approval and an `[IA]` comment prefix, and editing that keeps the Windows-1252 encoding. Start with
[Using JEDI VCS with AI](doc/en/05-Using-with-AI.md). The skill is in
[skills](skills/README.md) (English: [skills/en/jedi-vcs](skills/en/jedi-vcs/README.md)).

## Migrating to Git

Moving a JEDI VCS archive to Git? **[jvcs2git](https://github.com/edmarfrazao/jvcs2git)** exports every project with the full history (revisions, authors, dates, comments, labels as tags) through the server protocol, so it works with any JEDI VCS database. It has a GUI, a CLI with JSON output for scripts and AI assistants, and its own skill. Download: [jvcs2git releases](https://github.com/edmarfrazao/jvcs2git/releases/latest).

## Building from source

```
tools\compilar.bat libs Release Win32        (once: SynEdit and VirtualTreeView)
tools\compilar.bat all Release Win32         (Jedivcs.exe, JvcsExternalDll.dll, JEDIVCSDiff.exe, jvcs.exe)
tools\compilar-expert.bat Release nova       (JvcsExpertBDS37.dll; use /delphi:11 or /delphi:12 for the others)
tools\gerar-instalador.bat                   (installer)
```

You can also open `JediVCS2026.groupproj` in the IDE. Summary in English:
[Building from source](doc/en/06-Building-from-Source.md). Full reference (Portuguese):
[Compilação](doc/pt/fontes/Compilacao.md) and [tools/LEIAME-compilar.md](tools/LEIAME-compilar.md).

## Repository layout

| Folder | Contents |
|---|---|
| `src\jedivcs` | GUI client: `Jedivcs.dpr` (EXE) and `JediVCSDLL.dpr` (IDE DLL) |
| `src\jedivcsdiff` | `JEDIVCSDiff.dpr` |
| `src\jvcs` | `jvcs.dpr` (console) |
| `src\jvcsideexpert` | ToolsAPI expert and tests |
| `src\common`, `src\common\client` | shared units and client core |
| `src\comp` | ported MidWare, CRC, textdiff, pinned SynEdit and VirtualTreeView |
| `tools` | build scripts, expert checker, protocol golden tests, test channel, AI tools |
| `setup` | Inno Setup installer and development `.reg` files |
| `3rdparty` | 2.5.0.1030 runtime (`fvcscrypt.dll`, help files, lists) and reference binaries |
| `skills\en`, `skills\pt` | `jedi-vcs` skill for AI assistants, in English and in Portuguese ([skills](skills/README.md)) |
| `news\en`, `news\pt` | release notes for each beta, per language |
| `doc\en`, `doc\pt` | documentation per language (below); `doc\original` = original JEDI VCS files |

## Documentation

The English guide covers what you need to install and use the client. The detailed technical
documentation is in Brazilian Portuguese.

| For | Read |
|---|---|
| Install and use (English) | [doc/en](doc/en/README.md) |
| What changed in each version (English) | [What's new](news/en/README.md) |
| Full user manual (Portuguese) | [doc/pt/manual](doc/pt/manual/README.md) |
| AI usage (Portuguese) | [doc/pt/ia](doc/pt/ia/README.md) |
| Source code: architecture, units, build, conventions (Portuguese) | [doc/pt/fontes](doc/pt/fontes/README.md) |
| History, decisions, tests and release process (Portuguese) | [doc/pt/processo](doc/pt/processo/README.md) |
| Technical changelog (Portuguese) | [CHANGELOG](CHANGELOG.md) |
| Full index (Portuguese) | [doc/pt/README.md](doc/pt/README.md) |

## Licenses

- JEDI VCS code is distributed under the **Mozilla Public License 1.1** — see [LICENSE](LICENSE) and
  [doc/original/license.txt](doc/original/license.txt). Some parts are donations or derived works with
  their own license, stated in the header of each file. Read the full notice before you reuse any code.
- **MidWare (François Piette) — non-commercial use only.** The client transport
  (`src/comp/midware`: `ApsCli`, `CBroker`, `RFormat`) is a **modified** version (Unicode port for
  Delphi 13 / ICS 9) of MidWare, which is freeware **for non-commercial use only**. The original notice is
  kept in each file. Use in a commercial application requires an agreement with the author. A replacement
  transport is planned.

  This product is based on MidWare. Freeware source code is available at http://www.overbyte.be.
- Components: JCL/JVCL (MPL 1.1), SynEdit (MPL 1.1/GPL 2), VirtualTreeView (MPL 1.1/LGPL 2.1), ICS
  (freeware), Abbrevia (MPL 1.1). `fvcscrypt.dll` is the original binary redistributed from the 2.50 Beta 3
  installer. Summary (Portuguese): [Licenças](doc/pt/common/Licencas.md) and
  [Componentes](doc/pt/common/Componentes.md).
- **Creators, rights and `fvcscrypt.dll`:** who created and maintained JEDI VCS, the license rights, why
  `fvcscrypt.dll` is required and why there is no 64-bit client: [Credits and rights](doc/en/08-Credits-and-Rights.md).

## Credits

- **Original JEDI VCS** (FreeVCS / JEDI VCS 2.x): **Thomas Huber**, **Uwe Schuster** and the Project JEDI
  team — see [doc/original/credits.txt](doc/original/credits.txt) and
  [credits_jedivcsdiff.txt](doc/original/credits_jedivcsdiff.txt).
- **MidWare and ICS:** François Piette (OverByte).
- **2026 port:** **Edmar Frazão**, with **Claude Code** (Anthropic) as pair programmer.

## Contributing

Issues and pull requests are welcome, in English or Portuguese. Before you submit: build the four targets
in Debug and Release, run the tests for the area you changed (console golden tests for protocol changes;
the harness for the DLL/expert; `-formsweep` for forms) and describe what you tested. Coding rules (sources
in Windows-1252 with CRLF line endings), defines and commit style:
[Convenções (Portuguese)](doc/pt/fontes/Convencoes.md).
