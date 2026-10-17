# Troubleshooting (summary for the AI)

Never work around a problem by touching attributes, the registry, `config.ini` or the settings: explain it
to the user and suggest their next step.

| Symptom | Likely cause | What to do |
|---|---|---|
| `localizar-wrapper.ps1` → 12 | `tools\ai` not installed | the user installs JEDI VCS 2.5 Beta 2026 with "AI tools" or sets `JVCS_AI_TOOLS` |
| `[ERRO 2] informe -Project <nome.dpr>` | folder with more than one `.dpr`/`.dpk` (e.g. `X - Copy.dpr`) | repeat with `-Project X.dpr` |
| `projeto '...' não existe no servidor` (5) | project not created in JEDI VCS, or a different name | `projects` to list them; the user creates it in the client |
| `notVersioned` | the file is not a module | edit without check-out; version it only if the user asks (`add`, 2026 console) |
| `local=unknown -> pathTruncated` | server path truncated (47 chars) and file not found under the project folder | run `status "<file>"` in the project folder |
| `pathMismatch` (5) | the local file is not the one registered on the server: project in another folder (e.g. Documents redirected to OneDrive, another drive letter, a copy) | do not insist; the user opens the project at the registered path or uses `subst`/a junction |
| `Project1`/`Unit1` refused | Delphi default names are forbidden in JEDI VCS | the user saves the project and units with proper names |
| 4 credential | identity missing, no saved password or login refused | the user connects in the GUI with *Store Password with identity* |
| 6 `lockedByOther` | another user holds the lock | do not edit; tell who holds the lock (`lockedBy`) |
| 8 `localModified` | file changed outside the VCS | ask; with approval `checkout -Force -Confirmed` (keeps the change, makes a backup) |
| 7 `notCheckedOut` | check-in without check-out | check out first (or the user did it in the IDE on another machine) |
| 7 `encodingChanged` | encoding/BOM/line breaks changed (e.g. `Edit` on an ANSI file) | restore the encoding with `edit-preserve`; `-AllowEncodingChange -Confirmed` only if the user asks |
| 7 `failedCompensated` | the console failed during check-out (e.g. file open and locked by the IDE) and the lock was undone | ask the user to close the file in the IDE and repeat |
| 9 `timeout` / connection | slow or unavailable server | `identity -Test`; retry once; check `status`/`locks` |
| 10 | `confirm` mode without `-Confirmed`, or `manual` mode | show the action and ask for approval; in manual mode, leave it to the user |
| 12 mutex | another call with the same identity in progress | wait and retry |
| 12 `jvcs.exe` | console missing or not recognized | the user checks `config get jvcsExe` |
| a hook denied the `Edit` | ANSI/UTF-16 file, ASCII receiving accented characters, or no check-out | use the command the hook suggested (edit-preserve or checkout) |
| `Edit`: "file modified since read" | check-out changed attribute/date | read it again and repeat |
| every call asks for approval | untrusted folder, or call form different from the `allow` rule | use the exact form of `wrapperCommand`; the user accepts the folder trust |
| module left checked out without changes | edit denied or abandoned | `undocheckout "<file>"` |
