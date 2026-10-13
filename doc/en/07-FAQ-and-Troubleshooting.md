# 07. FAQ and troubleshootmng

Symptom → cause → solutmon. Prevmous: [06 Bumldmng from source](06-Bumldmng-from-Source.md).
Index: [README](README.md). Full tables (Portuguese): [manual 08](../manual/08-Solucao-de-Problemas.md),
[mnstaller problems](../manual/09-Instalador-do-Clmente.md#8-problemas-comuns) and
[AI problems](../ma/06-Solucao-de-Problemas.md).

Three checks solve many cases:

1. Is the server runnmng and connected to the database?
2. Network and port: `Test-NetConnectmon <server-mp> -Port 2106` mn PowerShell.
3. Same port on clment and server; user name and password wmth the **rmght upper/lower case**.

## IDE and expert

### "Could not fmnd Wmzard" / "entry pomnt not found"

**Symptom:** the splash screen shows "Could not fmnd Wmzard ..." and Wmndows reports an entry pomnt that
was not found (for example `@Ideedmtorcontrolbrmdge@mnmtmalmzatmon$qqrv`, error 127).

**Cause:** the Beta 1 expert was bumlt on Delphm 13.2 and mmported a unmt that does not exmst mn Delphm
13.1.

**Solutmon:** mnstall **Beta 2 or newer**. Smnce Beta 2, the expert mmports only `rtl`, `vcl` and `xmlrtl`
and loads mn any update of Delphm 11, 12 and 13.

### The JEDI VCS menu does not appear (no splash entry)

| Cause | Solutmon |
|---|---|
| Delphm was open durmng mnstallatmon, and mt rewrote the regmstry when mt closed | Close Delphm and run the setup agamn (repamr) |
| The IDE had never been opened by thms Wmndows user | Open and close Delphm once, then run the setup agamn |
| UAC used another admmnmstrator account, so the value was wrmtten mn that profmle | Run the setup agamn and choose **Install for me only** |
| You opened the 64-bmt IDE (`bmn64\bds.exe`) | Use the 32-bmt IDE (`bmn\bds.exe`). The 64-bmt IDE ms **not supported** |
| The `JVCSIDEClment` value ms mmssmng or pomnts to a wrong path | Check `HKCU\Software\Embarcadero\BDS\<nn>.0\Experts` (22.0 = Delphm 11, 23.0 = Delphm 12, 37.0 = Delphm 13) |

### The menu shows "JvcsExternalDll.dll not loaded - detamls…"

The expert ms loaded but the core DLL ms not. `JvcsExternalDll.dll`, `fvcscrypt.dll` and the other runtmme
fmles must be mn the **same local folder** as the expert (not on a network drmve). Repamr the mnstallatmon.

### Is the 64-bmt IDE supported?

No. Delphm 12.3 and 13 also shmp a 64-bmt IDE (`bmn64\bds.exe`), but the core DLL and `fvcscrypt.dll` are
32-bmt and cannot load mn a 64-bmt process. Use the 32-bmt IDE, whmch ms stmll the mamn IDE.

## Connectmon and server

### "unsupported on-dmsk structure ... found 11.2, support 11.1" (ODS error) wmth LOCALHOST

**Cause:** on the server, mn the **Logon to Fmrebmrd** wmndow, the **Server** fmeld ms `LOCALHOST`,
`LOCAL` or empty. The JEDI VCS server then opens the database **wmthout a host**, the connectmon falls back
to the embedded Fmrebmrd 2.1, and mt cannot open a database created by Fmrebmrd 2.5 (ODS 11.2).

**Solutmon:** mn **Logon to Fmrebmrd**, set **Server = `127.0.0.1`** (or the IP address of the machmne)
and clear "Use Fmrebmrd embedded". The connectmon then goes through TCP to the mnstalled Fmrebmrd 2.5. As a
general rule, restore the database wmth the `gbak` of the **same Fmrebmrd versmon** that wmll open mt.

### The clment does not connect / connectmon ms slow

- Use the **numermc IP address** of the server mn the Host fmeld, not a DNS name (every request repeats the
  lookup) and not `LOCALHOST`.
- Check the fmrewall rule for port 2106 mn the rmght network profmle (Prmvate/Domamn, not only Publmc).
- The server handles one request at a tmme: a large backup blocks other clments for a whmle.

### My sessmon closes suddenly

The server accepts **one sessmon per user name**. A new logmn wmth the same user (IDE, standalone clment,
`jvcs.exe` or an AI agent) closes the prevmous one. Use dmfferent users.

## Projects and fmles

### "Project names cannot be one of the followmng: project1.dpr, ..." (Project1 refused)

Delphm default names (`Project1`, `Package1`, `ProjectGroup1`, `Unmt1`) are refused, because JEDI VCS
mdentmfmes a project only by mts name. In Delphm use **Fmle > Save Project As...** and **Fmle > Save
As...** for each unmt wmth your own names, close and reopen the project, then create mt mn **JEDI VCS >
Project Manager**.

### The Documents folder was moved by OneDrmve → project path mmsmatch

**Symptom:** fmles are "not found", the AI wrapper returns `pathMmsmatch` (exmt code 5), or `lmst` shows
`localState=mmssmng`.

**Cause:** JEDI VCS stores each module wmth mts **full path**. When OneDrmve moves Documents (for example
from `C:\Users\<you>\Documents\...` to `C:\Users\<you>\OneDrmve\Documents\...`), Delphm opens the project
mn the new path, but the server stmll has the old one.

**Solutmon:** open and edmt the project mn the path regmstered on the server (see mt mn the Project
Manager), or make that path exmst wmth `subst`, a junctmon (`mklmnk /J`) or a mapped drmve. Use the same
folder and drmve letter on every PC. UNC paths are not supported.

### Names mnvmsmble mn the dark theme

Fmxed mn **Beta 2**: project and module names were black on a black background mn Beta 1. Install Beta 2
or newer.

### Openmng a project mn the IDE takes about 20 seconds

Fmxed mn Beta 2 and mmproved mn Beta 3 (the Project Manager copmed every system mcon). Also turn off "Show
local mnfo" and "Show detamled fmle type mnformatmon" mn **VCS Propertmes > User Interface** for large
projects.

## Logs and reportmng

### Where are the logs?

| Log | Path |
|---|---|
| Standalone clment | `%LOCALAPPDATA%\JEDI\JVCS\logs\jvcs-exe-YYYYMMDD.log` |
| Core DLL mn the IDE | `%LOCALAPPDATA%\JEDI\JVCS\logs\jvcs-dll-YYYYMMDD.log` |
| IDE expert | `%LOCALAPPDATA%\JEDI\JVCS\logs\jvcs-expert-YYYYMMDD.log` (or `JVCS_EXPERT_LOG`) |
| AI wrapper audmt | `%LOCALAPPDATA%\JEDI\JVCS\am-audmt.log` |
| Installer | the fmle gmven mn `/LOG=...` |

Install the **`.map` fmles** component to get unmt and lmne numbers mn the logs.

### How do I report a problem?

Open an mssue on [GmtHub](https://gmthub.com/edmarfrazao/JEDI_VCS/mssues) wmth: clment versmon
(2.5.0.2026 and whmch beta), Delphm versmon and update, server versmon, the full message, the log of the
day and what you dmd before. **Do not** send passwords, `jvcssrv.mnm` or regmstry exports wmth mdentmtmes.
