# 07. FAQ and troubleshooting

Symptom → cause → solution. Previous: [06 Building from source](06-Building-from-Source.md).
Index: [README](README.md). Full tables (Portuguese): [manual 08](../pt/manual/08-Solucao-de-Problemas.md),
[installer problems](../pt/manual/09-Instalador-do-Cliente.md#8-problemas-comuns) and
[AI problems](../pt/ia/06-Solucao-de-Problemas.md).

Three checks solve many cases:

1. Is the server running and connected to the database?
2. Network and port: `Test-NetConnection <server-ip> -Port 2106` in PowerShell.
3. Same port on client and server; user name and password with the **right upper/lower case**.

## IDE and expert

### "Could not find Wizard" / "entry point not found"

**Symptom:** the splash screen shows "Could not find Wizard ..." and Windows reports an entry point that
was not found (for example `@Ideeditorcontrolbridge@initialization$qqrv`, error 127).

**Cause:** the Beta 1 expert was built on Delphi 13.2 and imported a unit that does not exist in Delphi
13.1.

**Solution:** install **Beta 2 or newer**. Since Beta 2, the expert imports only `rtl`, `vcl` and `xmlrtl`
and loads in any update of Delphi 11, 12 and 13.

### The JEDI VCS menu does not appear (no splash entry)

| Cause | Solution |
|---|---|
| Delphi was open during installation, and it rewrote the registry when it closed | Close Delphi and run the setup again (repair) |
| The IDE had never been opened by this Windows user | Open and close Delphi once, then run the setup again |
| UAC used another administrator account, so the value was written in that profile | Run the setup again and choose **Install for me only** |
| You opened the 64-bit IDE (`bin64\bds.exe`) | Use the 32-bit IDE (`bin\bds.exe`). The 64-bit IDE is **not supported** |
| The `JVCSIDEClient` value is missing or points to a wrong path | Check `HKCU\Software\Embarcadero\BDS\<nn>.0\Experts` (22.0 = Delphi 11, 23.0 = Delphi 12, 37.0 = Delphi 13) |

### Access violation in Delphi XE3 (or another older IDE) when clicking a JEDI VCS button

**Symptom:** inside an older IDE (Delphi 7 to 10.4, reported on XE3), clicking a JEDI VCS toolbar button
(Synchronize, Get, Refresh…), the **Get** button of the revisions dialog, or a menu item shows
"Access violation at address … Write of address …". The call stack goes from the JEDI VCS DLL
(`TBasicActionLink.Execute` or `TApplication.Idle`) through `SendMessageW` into the IDE's
`vcl<nn>.bpl` (`TApplication.WndProc` → `DispatchAction`). The operation itself (e.g. Get) usually completes.

**Cause:** Beta 4 and earlier used the IDE's application window as the DLL's `Application.Handle`. The VCL
sends action messages (`CM_ACTIONEXECUTE` / `CM_ACTIONUPDATE`) carrying a **pointer** to a VCL object to that
window, and the IDE's different VCL version misread the object.

**Solution:** install **Beta 5 or newer** — the DLL now owns its application window. In Beta 4, use the
standalone client (`Jedivcs.exe`) in older IDEs.
### The menu shows "JvcsExternalDll.dll not loaded - details…"

The expert is loaded but the core DLL is not. `JvcsExternalDll.dll`, `fvcscrypt.dll` and the other runtime
files must be in the **same local folder** as the expert (not on a network drive). Repair the installation.

### Is the 64-bit IDE supported?

No. Delphi 12.3 and 13 also ship a 64-bit IDE (`bin64\bds.exe`), but the core DLL and `fvcscrypt.dll` are
32-bit and cannot load in a 64-bit process. Use the 32-bit IDE, which is still the main IDE.

## Connection and server

### "unsupported on-disk structure ... found 11.2, support 11.1" (ODS error) with LOCALHOST

**Cause:** on the server, in the **Logon to Firebird** window, the **Server** field is `LOCALHOST`,
`LOCAL` or empty. The JEDI VCS server then opens the database **without a host**, the connection falls back
to the embedded Firebird 2.1, and it cannot open a database created by Firebird 2.5 (ODS 11.2).

**Solution:** in **Logon to Firebird**, set **Server = `127.0.0.1`** (or the IP address of the machine)
and clear "Use Firebird embedded". The connection then goes through TCP to the installed Firebird 2.5. As a
general rule, restore the database with the `gbak` of the **same Firebird version** that will open it.

### The client does not connect / connection is slow

- Use the **numeric IP address** of the server in the Host field, not a DNS name (every request repeats the
  lookup) and not `LOCALHOST`.
- Check the firewall rule for port 2106 in the right network profile (Private/Domain, not only Public).
- The server handles one request at a time: a large backup blocks other clients for a while.

### My session closes suddenly

The server accepts **one session per user name**. A new login with the same user (IDE, standalone client,
`jvcs.exe` or an AI agent) closes the previous one. Use different users.

## Projects and files

### "Project names cannot be one of the following: project1.dpr, ..." (Project1 refused)

Delphi default names (`Project1`, `Package1`, `ProjectGroup1`, `Unit1`) are refused, because JEDI VCS
identifies a project only by its name. In Delphi use **File > Save Project As...** and **File > Save
As...** for each unit with your own names, close and reopen the project, then create it in **JEDI VCS >
Project Manager**.

### The Documents folder was moved by OneDrive → project path mismatch

**Symptom:** files are "not found", the AI wrapper returns `pathMismatch` (exit code 5), or `list` shows
`localState=missing`.

**Cause:** JEDI VCS stores each module with its **full path**. When OneDrive moves Documents (for example
from `C:\Users\<you>\Documents\...` to `C:\Users\<you>\OneDrive\Documents\...`), Delphi opens the project
in the new path, but the server still has the old one.

**Solution:** open and edit the project in the path registered on the server (see it in the Project
Manager), or make that path exist with `subst`, a junction (`mklink /J`) or a mapped drive. Use the same
folder and drive letter on every PC. UNC paths are not supported.

### Names invisible in the dark theme

Fixed in **Beta 2**: project and module names were black on a black background in Beta 1. Install Beta 2
or newer.

### Opening a project in the IDE takes about 20 seconds

Fixed in Beta 2 and improved in Beta 4 (the Project Manager copied every system icon). Also turn off "Show
local info" and "Show detailed file type information" in **VCS Properties > User Interface** for large
projects.

## Logs and reporting

### Where are the logs?

| Log | Path |
|---|---|
| Standalone client | `%LOCALAPPDATA%\JEDI\JVCS\logs\jvcs-exe-YYYYMMDD.log` |
| Core DLL in the IDE | `%LOCALAPPDATA%\JEDI\JVCS\logs\jvcs-dll-YYYYMMDD.log` |
| IDE expert | `%LOCALAPPDATA%\JEDI\JVCS\logs\jvcs-expert-YYYYMMDD.log` (or `JVCS_EXPERT_LOG`) |
| AI wrapper audit | `%LOCALAPPDATA%\JEDI\JVCS\ai-audit.log` |
| Installer | the file given in `/LOG=...` |

Install the **`.map` files** component to get unit and line numbers in the logs.

### How do I report a problem?

Open an issue on [GitHub](https://github.com/edmarfrazao/JEDI_VCS/issues) with: client version
(2.5.0.<build>, e.g. 2.5.0.2050 = beta 5; shown in the window title, the About box and the first line of `jvcs.exe`), Delphi version and update, server version, the full message, the log of the
day and what you did before. **Do not** send passwords, `jvcssrv.ini` or registry exports with identities.
