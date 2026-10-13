# 01. Overview

What JEDI VCS is, the words it uses, and what the 2026 edition changes.
Index: [README](README.md). Next: [02 Installation](02-Installation.md).

## 1. Architecture

```text
 Delphi IDE (JEDI VCS menu)     Jedivcs.exe        jvcs.exe        AI agent (wrapper)
          │                         │                 │                  │
          └──────────── TCP port 2106 (MidWare protocol) ────────────────┘
                                    ▼
                      JEDI VCS server 2.5 Beta 3 (JVCSSrv.exe)
                                    ▼
                         Firebird database (the archive)
```

All clients talk to the same server and the same database. The 2026 edition replaces only the
**clients**; the server and the database stay as they are.

## 2. Concepts

| Term | Meaning |
|---|---|
| **Server** | `JVCSSrv.exe`, a Windows application or service that listens on TCP port **2106** (default). Version 2.5 Beta 3 uses **Firebird**. It handles one request at a time |
| **Archive** | The database where the server stores all projects, modules and revisions (`JEDIVCS.FDB`). Back it up regularly |
| **Project** | A named set of files on the server. In Delphi, the project name is the name of the Delphi project (`.dpr`/`.dpk`). Project names are stored **without a path**, so they must be unique |
| **Module** | A file in a project. It is stored with its **full path and drive letter**, so all team members must keep the files in the same folder (use `subst` or a junction if needed; UNC paths are not accepted) |
| **Revision** | A version of a module, numbered `version.revision` (for example `v1.4`) |
| **Check out** | Locks a module for you and makes the local file writable. Other users cannot check it in while you hold the lock |
| **Check in** | Sends the new revision to the server with a comment and releases the lock. The local file becomes read-only again |
| **Undo check out** | Restores the last server revision and releases the lock |
| **Get** | Copies the latest (or a chosen) revision to disk without locking |
| **Lock** | The check-out mark on the server. Files that are not checked out stay **read-only** on disk; never remove the read-only flag by hand — check the file out instead |
| **File family** | Files that travel together, for example `.pas` + `.dfm` + `.fmx` |
| **Label** | A name attached to a set of revisions (for example a release) |
| **Identity** | A saved login: server address, port, user and (optionally) password. Stored in `HKCU\Software\JEDI\JEDIVCS` and shared by the original and the new client |
| **User and access level** | Users are defined on the server, with levels from Guest to Archive Administrator and optional rights per project. User names and passwords are **case-sensitive**. The server accepts **one session per user name** |
| **Branching** | The 2.5 server supports branches. The 2026 client always works on the **`HEAD`** branch; the title bar shows `[Branch: HEAD]` and the branch UI is hidden |

### Daily routine

| I want to | Do |
|---|---|
| Edit a module | **Check Out** (Ctrl+Shift+O in the IDE) |
| Save my change on the server | **Check In** (Ctrl+Shift+I), with a comment |
| Cancel | **Undo Check Out** |
| Get the latest version | **Get** (Ctrl+Shift+G) or **Project > Synchronize/Restore** |
| See the history | **Module History** or the **History** tab of the Delphi editor |

## 3. The parts of the 2026 edition

| File | What it is |
|---|---|
| `Jedivcs.exe` | Standalone GUI client |
| `JvcsExternalDll.dll` | The same client built as a DLL: the **core** used inside the IDE |
| `JvcsExpertBDS22/23/37.dll` | New thin IDE experts for Delphi 11 / 12 / 13 |
| `JvcsExpertD7.dll`, `JvcsExpertBDS<n>.dll` | **Original** 2.5.0.1030 thin experts for older IDEs (Delphi 7 to 10.4), used with the new core (Beta 4) |
| `JEDIVCSDiff.exe` | Diff tool |
| `jvcs.exe` | Console client |
| `fvcscrypt.dll` | Original password encryption library (32-bit, redistributed) |
| `tools\ai` | Wrapper, hooks and skill for AI agents |

## 4. What changed in the 2026 edition

- **New Delphi versions:** IDE integration for Delphi 11, 12 and 13, in **any update** (for example 13.0,
  13.1 and 13.2). The expert imports only the `rtl`, `vcl` and `xmlrtl` packages of the IDE.
- **Older IDEs (Beta 4; on Delphi XE3 the JEDI VCS toolbar buttons still crash — fix in progress):** Delphi 7 to 10.4 Sydney get the new core through the original
  experts.
- **Same protocol:** the new client sends byte-identical requests to the 2.5 Beta 3 server, verified
  against the original 2.5.0.1030 client. The original and the new client can be used side by side.
- **Appearance:** UI scaling (100–200%), font choice, light/dark theme following Windows or the Delphi
  IDE.
- **Fixes:** dark theme, faster project opening in the IDE, Compare all, password-protected backup, Line
  History, saved passwords, windows cut at 150–200%, and more ([What's new](../../news/en/README.md)).
- **Error logs** in `%LOCALAPPDATA%\JEDI\JVCS\logs`.
- **AI workflow:** safe check-out/check-in by AI agents with human approval.
- **Installer:** Inno Setup, English or Portuguese, with clean uninstall.
- **Disabled on purpose:** reports, translations, plug-ins, notifications between workstations, branch UI.
  None of them affects the protocol.

More (Portuguese): [history and motivation](../pt/processo/01-Historia-e-Motivacao.md),
[architecture decisions](../pt/processo/03-Decisoes-de-Arquitetura.md).
