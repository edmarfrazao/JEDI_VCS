# 02. Installation

> ⚠️ **Disclaimer:** this product is provided without any warranty of operation. Test and validate it in your own environment, with a backup and a copy of your JEDI VCS database, and apply any local fixes you need before deploying to production. Read the [full disclaimer](../../DISCLAIMER.md).

How to install, repair and remove the client with `JediVCS-2.5-Beta2026-Setup.exe`.
Previous: [01 Overview](01-Overview.md). Next: [03 Delphi IDE integration](03-Delphi-IDE-Integration.md).
Full details (Portuguese): [manual 09](../manual/09-Instalador-do-Cliente.md) and
[setup/LEIAME.md](../../setup/LEIAME.md).

## 1. Before you install

1. Download the installer from [Releases](https://github.com/edmarfrazao/JEDI_VCS/releases) and compare
   its SHA-256 with the value on the release page or the [news page](../../news/en/README.md).
2. **Close Delphi** (every `bds.exe`; for Delphi 7, `delphi32.exe`). If Delphi is running, the installer
   asks you to close it (Retry/Cancel). Delphi rewrites its registry settings when it closes and would
   undo the registration.
3. Open each Delphi version **at least once** with your Windows user before you install. If the IDE has
   never been opened, the expert is not registered: the installer shows a warning; open and close Delphi
   and run the setup again.
4. You do **not** need to uninstall the original JEDI VCS 2.5.0.1030. Both can be installed together.

## 2. Run the installer as your own user

Run the setup **from Explorer, logged on as the Windows user who uses Delphi**. The expert is registered
in the registry of the user who runs the setup (`HKCU`).

- Choose **Install for all users** (needs administrator rights) or **Install for me only** (no
  administrator rights).
- If UAC asks for the password of **another** administrator account, the expert is registered in that
  other profile and will not appear for you. In that case choose **Install for me only**.

## 3. Folders

| Mode | Folder |
|---|---|
| All users (default) | `C:\Program Files (x86)\JEDI\JVCS 2026` |
| Current user only | `%LOCALAPPDATA%\Programs\JEDI\JVCS 2026` |

The folder of the original JEDI VCS (`...\JEDI\JVCS`) is refused, so the original installation is never
overwritten. Everything goes into one folder: the expert loads `JvcsExternalDll.dll` from its own folder,
and the DLL finds `fvcscrypt.dll`, the help files and `JEDIVCSDiff.exe` there.

## 4. Components

All components are selected by default.

| Component | What it installs |
|---|---|
| **Client** | `Jedivcs.exe` (standalone), `JEDIVCSDiff.exe`, `jvcs.exe` (console), help files |
| **Delphi expert** | **JEDI VCS** menu in the 32-bit IDE of Delphi 11, 12 and 13; the line shows the versions detected |
| **Older IDEs detected** (Beta 4) | Appears only if Delphi 7 to 10.4 Sydney is installed, with one line per IDE. Installs the **original** 2.5.0.1030 expert of that IDE connected to the new core |
| **`.map` files** | The error log then shows unit and line numbers (useful when you report a bug) |
| **AI tools** | `tools\ai` (wrapper, hooks) and the Claude Code skill `jedi-vcs` in `tools\ai\skills\jedi-vcs` |

Tasks: a desktop shortcut (selected) and **"Use the new console for AI"** (not selected: select it only if
AI automation should use the new `jvcs.exe` instead of the original one).

Start menu → **JEDI VCS 2026**: client, Diff, help files, AI tools folder and uninstall.

## 5. What changes in Delphi

Only one registry value per detected Delphi version:
`HKCU\Software\Embarcadero\BDS\<nn>.0\Experts` → `JVCSIDEClient` = `<install folder>\JvcsExpertBDS<nn>.dll`
(22.0 = Delphi 11, 23.0 = Delphi 12, 37.0 = Delphi 13).

- If a `JVCSIDEClient` value already existed (for example the original JEDI VCS), it is saved and
  **restored on uninstall**.
- The Library Path, packages and IDE environment variables are **not** changed.
- Nothing is written to `Experts x64`: the 64-bit IDE cannot load a 32-bit DLL.

## 6. Older IDEs (Delphi 7 to 10.4 Sydney) — Beta 4 (XE3: toolbar crash being fixed)

The original JEDI VCS 2.5.0.1030 had a thin expert for each Delphi from 7 to 10.4 Sydney. The 2026
installer reuses these **original** experts. They only connect the IDE to `JvcsExternalDll.dll`, which is
now the **new** core, so an old IDE gets the 2026 client (same windows, fixes and options).

- Covered: Delphi 7, 2005, 2006, 2007, 2009, 2010, XE to XE8, 10 Seattle, 10.1 Berlin, 10.2 Tokyo,
  10.3 Rio and 10.4 Sydney (also C#Builder 1 and Delphi 8 for .NET, as in the original).
- **Not covered:** Delphi 5 and 6 (and C++Builder 5/6). The original used a different full client there;
  keep using the original installer for them.
- **Status:** the installer was tested with simulated IDEs. The original expert with the new DLL has
  **not yet been tested in a real old IDE**. If something fails, run the setup again and clear that IDE:
  the previous `JVCSIDEClient` value comes back.
- Known limitations of the original experts: accented characters in the editor content may be wrong in
  operations that read or write the source (for example keyword expansion); the windows do not follow the
  dark theme of the IDE.

## 7. Repair, update, remove

- **Repair or update:** run the setup again (the same one or a newer one) with Delphi closed. It reuses
  the folder and the previous choices and replaces all files.
- **Remove only the expert:** run the setup again and clear **Delphi expert** (or the IDE under **Older
  IDEs detected**). The previous `JVCSIDEClient` value comes back.
- **Uninstall:** with Delphi closed, **Settings → Apps** → "JEDI VCS 2.5 Beta 2026" → Uninstall, or Start
  menu → JEDI VCS 2026 → Uninstall.

Uninstall removes the files and shortcuts and the `JVCSIDEClient` value **if it points to this
installation** (restoring the previous value). It does **not** delete identities, passwords and options
(`HKCU\Software\JEDI\JEDIVCS`), logs (`%LOCALAPPDATA%\JEDI\JVCS\logs`) or the AI `config.ini`.

## 8. Silent installation (administrators)

```
JediVCS-2.5-Beta2026-Setup.exe /VERYSILENT /SUPPRESSMSGBOXES /CURRENTUSER /COMPONENTS=client,ide,maps,ai /TASKS=desktopicon /LOG=%TEMP%\jvcs-setup.log
"<install folder>\unins000.exe" /VERYSILENT /SUPPRESSMSGBOXES
```

Without `/CURRENTUSER` it installs for all users (elevated prompt required). If Delphi is open, silent mode
stops without changing anything (setup: exit code 7; uninstall: exit code 1). Older IDEs are named
`ideold\d7` and `ideold\bds<n>` in `/COMPONENTS` (for example `ideold\bds10` = XE3, `ideold\bds21` = 10.4).

## 9. Coexistence with the original 2.5.0.1030

- The original installation (`C:\Program Files (x86)\JEDI\JVCS`) is not touched. The new shortcuts have
  "2026" in their names.
- Both clients share the same identities and options (`HKCU\Software\JEDI\JEDIVCS`). The installer never
  reads or writes this key.
- Both clients can be connected to the same server at the same time, with **different user names** (the
  server accepts one session per user).
