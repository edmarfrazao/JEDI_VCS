# jvcs.exe console (without the wrapper)

Reference for **humans** and build scripts. The AI must use the `jvcs-ai.ps1` wrapper: the console on its
own returns 0 even on errors, does not show the server's refusal, changes the server state before asking
questions it cannot ask with redirected input, and its documented form takes the password on the command
line.

Program: `jvcs.exe` 2.5.0.1030 (original, `C:\Program Files (x86)\JEDI\JVCS`) or 2.5.0.20xx (2.5.0.2050 = beta 5) (new,
`C:\Program Files (x86)\JEDI\JVCS 2026`), with `fvcscrypt.dll` next to it. The 2026 console has the same
commands as the original plus the ones in "New commands of the 2026 console".

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

Not available in either console: `diff`, `log`, `whoami` (`jvcs-ai.ps1` offers `diff`, `show`, `sync`,
`history`, `changes` and `identity`).

## New commands of the 2026 console

Only in the 2026 `jvcs.exe` (`jvcs help <command>` shows the full syntax). The administration commands **do
not ask for confirmation** (the project ones only require the literal word `confirm`): through AI, always use
the wrapper command listed, which runs the preview, makes the backup and asks for approval.

| Command | Does | Effect | In the wrapper |
|---|---|---|---|
| `addproject <project> [<description>]` | creates the project | server | `addproject` |
| `addmodule <file> [<description>]` | registers the file (with its folder) in the open project | server | `add` |
| `setmodulepath <module\|id> <folder>` | stores the module's local folder on the server | server | — |
| `history <module\|id>` | revisions: file date, user, family, comment | read | `history`, `blame` |
| `projectlog <project\|id> [since=] [user=] [max=] [norev]` | check-ins of the project from the server log (real time) | read | `changes` |
| `searchmodules <mask>` | modules by name/mask in all projects | read | `search` |
| `searchcomments <text> <project\|id> [maxmodules=]` | text in the check-in/check-out comments | read | `search -InComments` |
| `listlabels [<project\|id>]` | labels of the server / used in the project | read | `labels` |
| `labelrevs <project\|id> <label>\|#id` | revision of each module in the label | read | `labels -Label`, `sync -Label` |
| `modulelabels <module\|id>` | labels of each revision of the module | read | `labels <file>`, `history` |
| `projectrevs <project\|id> latest\|label=\|version=\|date= [includehidden]` | revision of each module in a state (as the Synchronize/Restore tabs) | read | `sync -Date`, `sync -Dest` |
| `sharedby <module\|id>`, `sharedmodules <project\|id>` | projects that have the module / shared modules of the project | read | `shared` |
| `listtodo [project=] [user=] [category=] [priority=] [due=] [includedone]` | ToDo items | read | `todo` |
| `addtodo <project\|id> "<description>" [...]`, `donetodo <id> [reopen]` | creates / completes or reopens a ToDo | server | `todo-add`, `todo-done` |
| `listmilestones [<project\|id>\|all]` | defined and reached milestones | read | `milestones` |
| `listbugs [module ...\|project ...\|bug <id>]`, `bugsummary modules\|projects` | bugs and the most severe per module/project | read | `bugs` |
| `addbug`, `updatebug <id>`, `assignbug <id> module\|project ...` | creates, changes, links/unlinks a bug | server | `bug-add`, `bug-update`, `bug-link` |
| `listmodules [<project\|id>]`, `listdeserted` | every module of the project (flags `H` `B` `N` `P`) / deserted (`D`) | read | `modules`, `cleanup` |
| `removemodule <module\|id> [archive]` | removes from the project / with `archive`, **deletes from the archive** (irreversible) | server | `rm-module`, `cleanup` |
| `renamemodule <module\|id> <new>`, `hidemodule <module\|id> [unhide]` | renames (all projects) / hides in the project | server | `rename-module`, `hide` |
| `getcomment <revision_id>`, `setcomment <module\|id> <revision_id> in\|out "<text>"` | reads / changes the comment of a revision | read / server | `comment` |
| `projectinfo <project\|id>` | project and its links (also of a removed project) | read | preview of `rm-project`/`rename-project` |
| `removeproject`, `restoreproject`, `renameproject ... [renamefiles]` (+ `confirm`) | removes / restores / renames the project | server | `rm-project`, `restore-project`, `rename-project` |
| `linkmodule <id> <path\name> [hidden]`, `projectgroups`, `setprojectgroup <project> <group> add\|remove` | links a module again / project groups | server | `restore-project -Relink` |

Changes in existing commands:
- `checkin <module|id> [comment] [keep]`: with `keep` it is a **Put** (new revision, the lock stays and the
  files stay writable; wrapper `checkin -Keep`). A check-in refused by the server is now an error with the
  reason (`refused by server: ...`) instead of passing silently.
- `labelproject`: last column `added` or `kept x.y` (the server does not move a label already on another revision).
- `getmodule`: accepts `rev=` + `dest=` + `noprompt` together.
- 2.5 server with branches (Firebird): `removemodule ... archive` only deletes a module **without revisions**;
  with revisions the server answers 400 and nothing changes (a server limitation).

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
