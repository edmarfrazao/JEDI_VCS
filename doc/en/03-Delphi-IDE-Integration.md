# 03. Delphi IDE integration

How to check that the expert is loaded and how to use JEDI VCS inside Delphi.
Previous: [02 Installation](02-Installation.md). Next: [04 Standalone client](04-Standalone-Client.md).
Full details (Portuguese): [manual 03](../pt/manual/03-Integracao-com-o-Delphi.md) and
[manual 02](../pt/manual/02-Cliente-Primeiro-Acesso.md).

## 1. Check that the expert is loaded

Start the **32-bit** IDE (`bin\bds.exe`). The 64-bit IDE (`bin64\bds.exe`) is not supported.

1. **Splash screen:** "JEDI Version Control System 2.5 Beta 2026".
2. **Help > About:** the JEDI VCS plug-in is listed.
3. **JEDI VCS menu** right after **Tools**.
4. **Tools > Options > Keyboard** (or Customize): the actions appear in the "JEDI VCS" category.

Without a connection and without a project, most menu items are disabled (grey). This is normal.

If the menu shows **"JvcsExternalDll.dll not loaded - details…"**, the expert is loaded but the core DLL
is not: click the item to see the paths that were tried. If **nothing** appears, see
[07 FAQ and troubleshooting](07-FAQ-and-Troubleshooting.md).

## 2. The JEDI VCS menu

| Menu item | Shortcut |
|---|---|
| Connect Server... | |
| Project Manager... | Ctrl+Shift+P |
| Check In/ Put... | Ctrl+Shift+I |
| Check Out... | Ctrl+Shift+O |
| Get... | Ctrl+Shift+G |
| Backup/ Restore... | Ctrl+Shift+B |
| Reload, Compare Modules..., Module History..., Project History..., Merge/ Stamp Projects..., VCS Properties..., ToDo List..., Time Log..., Touch..., Recent Projects..., Help Topics, About JEDI VCS | |

Also available inside the IDE:

- right-click a file in the **IDE Project Manager** → JEDI VCS → Check In, Check Out, Get, Reload,
  Compare, Diff, History;
- the **History** tab of the code editor shows the JEDI VCS revisions of the unit.

## 3. First login

1. **JEDI VCS > Connect Server...** opens the **Server Login** window. The first time, accept the program
   disclaimer.
2. Fill in the **Application server** tab:

   | Field | Value |
   |---|---|
   | Identity | A name for this saved login, for example `TEST` or `PRODUCTION` (no `[`, `]` or `\`) |
   | Host | The server address. **Use the numeric IP address** (for example `192.168.0.10`), not a DNS name and not `LOCALHOST` — see below |
   | Port | `2106` (must match the server) |
   | User / Password | Your JEDI VCS user. Both are **case-sensitive** |

3. Click **Ping** (Ctrl+P), then **Connect**. Click **Add/Update Identity** (Ctrl+A) to save the login.
4. On a **new** database the initial user is `sysdba` with password `admin`. **Change this password right
   after the first login** and create one user per person (and a separate low-privilege user for an AI
   agent).

**Why an IP address?** With a DNS name, every request does a new name lookup, which is slow. With
`LOCALHOST` the name can resolve to the IPv6 address `::1`, while the 2.5 server listens on IPv4 only. If
the server runs on the same PC, the original help also recommends the real IP address of the machine.

**Store Password with identity** (Options tab) saves the password in the registry in Base64 only (readable
by any process of your user). It is required for AI automation; otherwise prefer to leave it off.

## 4. Projects

1. Open a Delphi project with **its own name**. JEDI VCS **refuses Delphi default names**:
   `project1.dpr`, `project1.dproj`, `package1.dpk`, `projectgroup1.bpg`, `unit1.pas`, `unit1.dfm`. The
   project is identified only by its name, and every `Project1` on every PC would end up in the same
   server project.
   - Fix: **File > Save Project As...** (for example `Ex1.dproj`) and **File > Save As...** for each
     `UnitN` (for example `uEx1Main.pas`). Close and reopen the project.
2. **JEDI VCS > Project Manager...** (Ctrl+Shift+P). For a new project, accept to create it on the server
   and to add the main modules.
3. Check in all modules once. They become read-only on disk.
4. From then on: **Check Out** before editing, **Check In** with a comment when done.

Other naming rules: avoid accents and the characters `" / \ < > [ ] : ; | { } * % ?`; keep paths short
(less than 255 bytes); use the same folder and drive letter on every PC.

## 5. Theme and appearance in the IDE

**VCS Properties > Appearance** sets the scale, fonts and theme. **Follow Delphi** uses the real IDE theme
(Light, Dark, Mountain Mist), also when you change the theme with the IDE open. JEDI VCS menus and windows
follow the IDE in Alt+Tab. See [04 Standalone client](04-Standalone-Client.md#2-appearance).

## 6. Logs

| Log | Where |
|---|---|
| Core DLL (inside the IDE) | `%LOCALAPPDATA%\JEDI\JVCS\logs\jvcs-dll-YYYYMMDD.log` |
| Expert | `%LOCALAPPDATA%\JEDI\JVCS\logs\jvcs-expert-YYYYMMDD.log` (or the file set in `JVCS_EXPERT_LOG`) |
| Standalone client | `%LOCALAPPDATA%\JEDI\JVCS\logs\jvcs-exe-YYYYMMDD.log` |

Logs never contain passwords. When the **`.map` files** component is installed, errors show unit, routine
and line. Attach the log of the day when you report a problem.

## 7. Expert environment variables

Read when the expert loads; set them **before** you start the IDE.

| Variable | Values | Effect |
|---|---|---|
| `JVCS_EXPERT_LOG` | file path | Writes the expert log to this file |
| `JVCS_EXPERT_DPI` | `off`, `unaware`, `gdiscaled` | DPI context of the JEDI VCS windows |
| `JVCS_EXPERT_DEFERINIT` | `auto` (default), `on`, `off` | Waits until the IDE is visible before initializing (so the login dialog does not appear over the splash) |

## 8. Limitations

- **32-bit IDE only.** The core DLL and `fvcscrypt.dll` are 32-bit.
- File names outside the Windows-1252 code page become `?`: use ASCII names.
- In non-modal windows (such as the Project Manager), Tab, shortcuts and hints may sometimes behave
  differently, because the DLL has its own VCL.
- With a project group, automatic reopening covers only the **active** project.
