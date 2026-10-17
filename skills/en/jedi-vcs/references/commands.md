# Quick reference: jvcs-ai.ps1 and edit-preserve.ps1

Form: `powershell -NoProfile -ExecutionPolicy Bypass -File "<tools/ai>/jvcs-ai.ps1" <command> [args] [options]`

## Commands

| Command | Does | Changes the server |
|---|---|---|
| `help` | summary | no |
| `identity [-Test]` | identity in use (never the password); `-Test` logs in | no |
| `projects` | projects on the server | no |
| `list [-Project p]` | modules: version, lock, state by the console CRC (fast) | no |
| `locks [-All]` | checked-out modules (mine / everyone's) | no |
| `status <file...>` / `status [-Project p]` | exact state (bytes) against the latest revision | no |
| `checkout <file...> [-Force]` | safe check-out; local file differs → 8 without lock | yes |
| `ensure-checkout <file> [-CheckOnly]` | idempotent (for hooks) | yes |
| `checkin <file...> -Comment "..." [-AllowEncodingChange]` | check-in; no change → undoes the check-out (3) | yes |
| `undocheckout <file...> [-Discard]` | undoes it if local = base; `-Discard` discards (backup) | yes |
| `diff <file> [-Rev x.y]` | unified diff of the local file against a server revision (default: latest) | no |
| `diff <file> -Rev x.y -Rev2 y.z` | diff between two server revisions | no |
| `history <file> [-Max n]` | revisions with date, user, family and check-in comment; newest first (2026 console) | no |
| `show <file> -Rev x.y [-Dest folder]` | writes that revision (with its family) to a reference folder outside the project | no |
| `sync [-Project p]` | preview: missing files, older copies and conflicts | no |
| `sync [-Project p] -Apply [-Force]` | fetches/updates the local copy with a backup; never touches your check-outs; `-Force` overwrites local changes made without check-out | no (local folder only) |
| `addproject <proj.dpr> [-Comment "..."]` | creates the project on the server (2026 console) | yes |
| `add <file...> -Comment "..."` | registers the file and does the first check-in 0.1 with its family (2026 console) | yes |
| `config list \| get <key>` | configuration (`set` is for the user only) | no |

Options: `-Project <name.dpr|path>`, `-Identity <name>`, `-Rev`, `-Rev2`, `-Max`, `-Dest`, `-Apply`, `-Text`, `-Confirmed`, `-Agent`,
`-TimeoutSec <n>`, `-LockWaitSec <n>`, `-Raw`.

Require `-Confirmed` (user approval): everything that changes the server in `confirm` mode;
`checkout -Force`, `checkin -AllowEncodingChange`, `undocheckout -Discard` and `sync -Apply -Force` in
any mode. `sync -Apply` follows the check-out mode (`manual` → 10).

`sync -Apply`: exit code 3 = nothing changed; 8 = conflicts only (nothing overwritten); 11 = partly
updated. Replaced files are kept in `%LOCALAPPDATA%\JEDI\JVCS\backup\<date>-sync\<id>\` (field `backup`).

## JSON

```json
{"ok":true,"command":"status","project":"exemplo01.dpr",
 "modules":[{"id":4,"name":"uprincipal.pas","path":"C:\\...\\uPrincipal.pas","version":"0.14","lockedBy":"",
             "localState":"clean","state":"ok","exitCode":0,"message":"","pathCheck":"prefix",
             "files":[{"name":"uPrincipal.pas","localState":"clean","readOnly":true}]}],
 "message":"1 arquivo(s) verificado(s)","exitCode":0}
```

The wrapper's `message` texts are in Portuguese; rely on `exitCode` and `state`, which are stable identifiers.

- `ok` = exit code 0 or 3. Extras: `identity`, `projects`, `config`, `configPath`, `comment`, `warnings`, `raw`.
- `localState`: `clean`, `modified`, `missing`, `notVersioned`, `unknown`.
- `pathCheck`: `exact`, `prefix` (truncated, not proven), `verified`.
- `state`: `ok`, `checkedOut`, `checkedOutKeptLocal`, `alreadyMine`, `needsCheckout`, `notVersioned`,
  `lockedByOther`, `localModified`, `needsConfirmation`, `pathMismatch`, `checkedIn`, `unchangedUndone`,
  `refused`, `encodingChanged`, `notCheckedOut`, `localMissing`, `undone`, `discarded`,
  `releasedButDirty`, `failedCompensated`, `failed`, `timeout`, `error`, `pathTruncated`.

## Exit codes

0 ok · 2 usage · 3 nothing to do · 4 credential · 5 not found/`pathMismatch` · 6 locked by someone else ·
7 precondition · 8 local conflict · 9 server/console/timeout · 10 confirmation/manual ·
11 partial batch · 12 environment.

## Configuration (`%APPDATA%\JEDI\JVCS\config.ini`, section `[ai]`)

`checkout`/`checkin` = `auto|confirm|manual` (default `confirm`) · `commentPrefix` (`[IA]`) · `jvcsExe` ·
`timeoutSec` (120) · `lockWaitSec` (120) · `identity` (empty = last one used) · `asciiAs` (`ansi|utf8`).
User interface: VCS Properties → AI / Automation.

## edit-preserve.ps1

```text
edit-preserve.ps1 -Path X.pas -Old "current" -New "new" [-All] [-Regex] [-DryRun]
edit-preserve.ps1 -Path X.pas -OldFile old.txt -NewFile new.txt
edit-preserve.ps1 -Path X.pas -ContentFile content.txt
edit-preserve.ps1 -Path New.pas -ContentFile c.txt -NewFileEncoding Ansi|Utf8Bom|Utf8|Utf16
```

Output `{ok, path, encoding, eol, replacements, bytesBefore, bytesAfter, checkout, message, exitCode}`.
Exit codes: 0 ok · 2 usage · 3 nothing changed · 4 `-Old` not found · 5 `-Old` not unique · 6 character
outside the encoding · 7 I/O or read-only · 8 unsupported file · 9 check-out failed · 10 confirmation,
manual mode or forbidden path.
