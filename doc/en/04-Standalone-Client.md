# 04. Standalone client

The standalone client `Jedivcs.exe` has every JEDI VCS 2.5 feature. Use it for administration (users,
rights, server properties), for projects that are not Delphi projects, and when Delphi is not open.
Previous: [03 Delphi IDE integration](03-Delphi-IDE-Integration.md). Next: [05 Using with AI](05-Using-with-AI.md).
Full details (Portuguese): [manual 02](../pt/manual/02-Cliente-Primeiro-Acesso.md) and
[manual 04](../pt/manual/04-Opcoes-do-Cliente.md).

## 1. Main window

Start it from Start menu → **JEDI VCS 2026** → client (or the desktop shortcut). The **Server Login** window
opens first (see [03, section 3](03-Delphi-IDE-Integration.md#3-first-login)). After login, open a project.

- The main window is the **Project Manager**: the list of modules of the open project, with version,
  revision, lock owner and local state. Colors show **modules checked out by you** and **modules checked
  out by others**.
- The title bar shows `[Branch: HEAD]`: the 2026 client always works on the HEAD branch.
- Main menus:

  | Menu | Typical commands |
  |---|---|
  | **Project** | New, Open, Synchronize/Restore, History, labels, backup |
  | **Module** | Add, Check In, Check Out, Undo Check Out, Get, Compare, History, Line History |
  | **Server** | Connect, Whoami, Administration (users, groups, project rights, server properties) |
  | **View** | **Appearance / Font Size...** (shortcut `Alt+V Z`) and other views |
  | **Options** | **Properties** (VCS Properties) |

- In the standalone client the project name is free (up to 50 characters). Create it with **Project >
  New...**, then **Module > Add...**, then check in.
- The same rules as in the IDE apply: check out before editing, never remove the read-only flag by hand,
  same folder and drive letter on every PC.

## 2. Appearance

**VCS Properties > Appearance** (or **View → Appearance / Font Size...**). Applies to all open windows
when you click **OK** or **Apply**, without restarting. The settings are shared by the standalone client and
the JEDI VCS windows in the IDE (`HKCU\Software\JEDI\JEDIVCS\Options`).

| Option | What it does | Suggestion |
|---|---|---|
| Interface font scale | 100%, 125%, 150%, 175%, 200% (or type 80–250). Dialogs and lists grow with it | 125% or 150% on a large monitor at 100% Windows scaling |
| Interface font: **Font...** / **Default** | Font family and size. When a size is chosen it replaces the scale. **Default** returns to the system font | Use the scale; choose a font only if you want another family |
| Menu font | Font of the menus; default = same as the interface | Keep "Same as interface" |
| Editor font (Diff, Line History) | Font of the text editors; default Consolas 10 | A monospaced font (Consolas, Cascadia Mono) |
| Theme | **Follow Windows** (standalone) or **Follow Delphi** (in the IDE), **Light**, **Dark** | Follow Windows / Delphi |
| Restore defaults | 100%, system fonts, follow the host | |

### Dark theme

- Project and module names are readable in the dark theme (this was a bug in Beta 1, fixed in Beta 2), and
  the icons are adapted to the dark background.
- Known limitations: some toolbar icons are still the old ones; the syntax highlight colors of
  Diff/Line History do not change; in the standalone client, the main menu bar does not grow with the scale
  (only the submenus do).

## 3. VCS Properties pages

Open with **Options > Properties** (standalone) or **JEDI VCS > VCS Properties...** (IDE). The options are
shared by the standalone client and the IDE; the console `jvcs.exe` does not use them. An administrator can
enforce some options for everyone (global settings).

| Page | Main options |
|---|---|
| User Interface | Double-click action, local file info, list colors. Turn off "Show local info" and "detailed file type" in large projects for faster opening |
| Common Options | Auto connect, "Undo Check Out unchanged", check module state on menu pull-down (slow — keep it off) |
| Comments | Mandatory comments; version history in source files (keep off) |
| Folders | Keep the registry storage; **do not** use "Use file storage (JVCS.INI)" |
| Time Stamps | Date handling for check-in/out |
| Keyword Expansion | `$Revision$`-style keywords; keep off unless needed (never for binary files) |
| Project Backup | Local backup of the project; use another disk |
| Internal Editors, Filter Values, Compare Tools | Editors, writable file lists (`.dpr`, `.res`, `.dproj`), external diff tools |
| Notify, Shortcut Keys, DSA Dialogs, Internal Printer, MRU Lists | Notifications (disabled in this edition), shortcuts, "don't show again" dialogs, printing, recent lists |
| Data Encryption | Traffic encryption; keep off on a LAN (LZH encryption is not supported) |
| Special/Debug | Request timeout (default 120 s), workarounds |
| External Bugtracker | Link check-ins to an external bug tracker |
| Save WIP | Run a command (for example 7-Zip) to save a copy of checked-out files |
| **Appearance** (new) | Scale, fonts and theme (section 2) |
| **AI / Automation** (new) | Manual / Ask for confirmation / Automatic for check-out and check-in by AI ([05](05-Using-with-AI.md)) |

Page by page with all options (Portuguese): [manual 04](../pt/manual/04-Opcoes-do-Cliente.md).
