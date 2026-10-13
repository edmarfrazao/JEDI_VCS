# jvcs.exe console (without the wrapper)

Reference for **humans** and build scripts. The AI must use the `jvcs-ai.ps1` wrapper: the console on its
own returns 0 even on errors, does not show the server's refusal, changes the server state before asking
questions it cannot ask with redirected input, and its documented form takes the password on the command
line.

Program: `jvcs.exe` 2.5.0.1030 (original, `C:\Program Files (x86)\JEDI\JVCS`) or 2.5.0.20xx (2.5.0.2050 = beta 5) (new,
`C:\Program Files (x86)\JEDI\JVCS 2026`), with `fvcscrypt.dll` next to it. The commands are the same.

## Syntax

```text
jvcs server:port /user User /password Password /command arguments...
jvcs server:port -user User -password Password -command arguments...
```

- Without `server:port`: `localhost:2106`.
- Without `/password` and with redirected input, the console reads the password from the first line of
  standard input (this is how the wrapper does it, without exposing the password). **Avoid `/password`**:
  the command line shows up in the process list, in the shell history and in AI transcripts.
- Without a command: interactive mode (`jvcs>`), leave with `exit`.
- Several commands: a text file and `/input file.txt` (inside the file, without `/`).
- Module commands require `openproject` first (in the same session / the same `/input`).
- Exit codes: 1 unspecified error, 2 invalid parameters, 3 nothing synchronized (only with
  `extexitcode`). Errors inside `/input` do **not** change the exit code: read the output (`[EClass] ...` lines).

## Commands

| Command | Does | Effect |
|---|---|---|
| `listprojects` | lists projects | read |
| `listproject <name\|id> [includehidden]` | project modules (path truncated to 47 characters) | read |
| `listlocks [<user>\|all_users]` | checked-out modules | read |
| `openproject <name\|id>` | opens the project for the following commands | session |
| `checkout <module\|id>` | check-out | server and disk |
| `checkin <module\|id> [comment]` | check-in; does nothing if unchanged | server |
| `undocheckout <module\|id>` | undoes the check-out | **overwrites the local file** |
| `getmodule <module\|id> [rev=v.r] [dest="folder"] [noprompt]` | downloads a revision | disk |
| `labelproject <project> <"label">` | applies a label | server |
| `syncproject <project> [noprompt] [stamp\|crc] [crossref] [includehidden\|deletehidden] [extexitcode] [label="name"]` | synchronizes the folder | **writes/deletes on disk** |
| `syncprojectgroup <group> [same options]` | synchronizes a group | **writes/deletes on disk** |
| `input <file>` | runs commands from a file | |
| `help [<command>]`, `exit` | help, leave | |

Not available in the console: `add` (new module), `diff`, `log`, `whoami`.

## Safe example (password through stdin, no /password)

```powershell
# cmds.txt (CP1252):
#   openproject exemplo01.dpr
#   listlocks
$exe = 'C:\Program Files (x86)\JEDI\JVCS 2026\jvcs.exe'
$cred = Get-Credential -UserName user -Message 'JEDI VCS password'
$cred.GetNetworkCredential().Password | & $exe server:2106 /user user /input cmds.txt
```

Known pitfalls:

- With the console in UTF-8 (`chcp 65001`, or inside AI tools) .NET may send a BOM before the password
  and the login fails; the wrapper works around it.
- `checkout`, `undocheckout` and `getmodule` may change the state (lock, file) and **then** ask something;
  with redirected input the question fails and the lock may be left hanging.
- `checkin` does not show the server's refusal: check the version afterwards with `listproject`.
- `syncproject ... noprompt crc` overwrites any local file that is not checked out by you.
- Comment and paths in ANSI (CP1252); comment without double quotes.

Full reference (Portuguese): `doc/pt/client/jvcs_params.txt` and `doc/pt/manual/06-Linha-de-Comando.md` in
the repository.
