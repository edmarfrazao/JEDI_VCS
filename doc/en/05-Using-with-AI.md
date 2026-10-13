# 05. Using JEDI VCS with AI

How AI assistants that run commands (Claude Code and other agents) can use JEDI VCS safely. The AI checks
the state of the files, checks out before editing, edits without breaking the encoding and checks in with
a comment marked `[IA]`. **You** choose the modes and approve the operations.
Previous: [04 Standalone client](04-Standalone-Client.md). Next: [06 Building from source](06-Building-from-Source.md).
Full guide (Portuguese): [doc/pt/ia](../pt/ia/README.md); technical reference:
[tools/ai/LEIAME.md](../../tools/ai/LEIAME.md).

## 1. What the AI can do

| Action | How | Note |
|---|---|---|
| See the state of the files | `jvcs-ai.ps1 status`, `list`, `locks` | compares byte by byte with the last server revision |
| Check out | automatically by a hook before editing, or `jvcs-ai.ps1 checkout` | never locks a file whose local content differs from the server |
| Edit and keep the encoding | Claude Code `Edit` (UTF-8 files) or `edit-preserve.ps1` (ANSI 1252, UTF-16, whole file) | keeps BOM and line endings (CRLF/LF/CR) |
| Check in | `jvcs-ai.ps1 checkin -Comment "..."` | `[IA]` prefix added automatically; no change → the check-out is undone |
| Undo check-out | `jvcs-ai.ps1 undocheckout` | only when the file is equal to the server again (`-Discard` needs approval) |

The AI does **not** create projects, add modules, synchronize, set labels or manage users.

## 2. Layers

```text
 You ── approve / refuse ──┐
                           ▼
 Claude Code (or another agent)
   │  skill jedi-vcs / jvcs ........ teaches the workflow and the rules
   │  allow / ask / deny rules ...... what runs without asking, what asks, what is forbidden
   │  PreToolUse / Stop hooks ....... check-out before Edit, encoding guard, lock reminder
   ▼
 tools\ai\jvcs-ai.ps1 (PowerShell wrapper)        tools\ai\edit-preserve.ps1
   │  saved identity, password via stdin,            edits with the file's own
   │  mutex, timeout, path proof,                    encoding and line endings
   │  auto/confirm/manual modes, JSON, audit log
   ▼
 jvcs.exe (JEDI VCS console, original 2.5.0.1030 or new 2.5.0.2026)
   ▼
 JEDI VCS server 2.5 (Firebird)
```

The console alone is not good for automation (it returns 0 on errors and asks questions it cannot ask
with redirected input). The wrapper fixes this and returns JSON.

## 3. Requirements

- Windows with **Windows PowerShell 5.1** (`powershell.exe`).
- JEDI VCS 2.5 Beta 2026 installed with the **AI tools** component (or a copy of `tools\ai`), and a
  `jvcs.exe` with `fvcscrypt.dll` next to it.
- A **saved identity with password** (Server Login → *Store Password with identity*). The wrapper never
  asks for a password.
- A Delphi project already in JEDI VCS, opened in the **same folder that is registered on the server**.
- Claude Code **2.1.295 or newer** for the hooks.

## 4. Installation

1. **AI tools:** select the **AI tools** component in the installer. They go to
   `<install folder>\tools\ai`.
2. **Identity:** in the JEDI VCS client, open **Server Login**, choose or create the identity, type the
   password, select **Store Password with identity** and connect once. For the AI, prefer a JEDI VCS user
   with few rights (read everywhere, write only in the allowed projects).
3. **Project integration (full protection):** in **your own** terminal (the AI is not allowed to run the
   installer):

   ```powershell
   $i = 'C:\Program Files (x86)\JEDI\JVCS 2026\tools\ai\instalar-no-projeto.ps1'
   & $i -ProjectDir 'C:\path\to\project' -Mode confirm
   ```

   It merges hooks and allow/ask/deny rules into `<project>\.claude\settings.json` without deleting
   existing settings (a backup is kept), and copies the per-project skill `jvcs`. Use `-Scope local` to
   write `settings.local.json` instead, and `-WhatIf` to simulate.
4. **Folder trust:** open the project in Claude Code and **accept the folder trust**. Hooks and `allow`
   rules work only after that; `deny` and `ask` rules always work.
5. **Check:**

   ```powershell
   $w = 'C:\Program Files (x86)\JEDI\JVCS 2026\tools\ai\jvcs-ai.ps1'
   & $w identity -Text            # identity in use (never shows the password)
   & $w identity -Test -Text      # real login
   & $w config list -Text         # modes and where each value comes from
   & $w status -Text              # exact state of the project modules
   ```

   Then ask Claude Code: *"show the JEDI VCS status of this project"*.

### The `jedi-vcs` skill (optional, global)

The distributable skill [`skills/en/jedi-vcs`](../../skills/en/jedi-vcs/README.md) teaches the workflow to any
Claude Code session, in any Delphi project, as long as the wrapper is installed. The installer puts it in
`<install folder>\tools\ai\skills\en\jedi-vcs` (a Portuguese version is in `skills\pt\jedi-vcs`; install
only one of them, both are named `jedi-vcs`); copy it to your profile (close Claude Code first):

```
robocopy "C:\Program Files (x86)\JEDI\JVCS 2026\tools\ai\skills\en\jedi-vcs" "%USERPROFILE%\.claude\skills\jedi-vcs" /E
```

| | Global skill `jedi-vcs` | Per-project skill `jvcs` |
|---|---|---|
| Source | `skills\en\jedi-vcs` (or `skills\pt\jedi-vcs`) | copied by `instalar-no-projeto.ps1` |
| Wrapper path | found by `scripts\localizar-wrapper.ps1` | written at install time |
| Hooks and allow/ask/deny rules | no (the skill only guides) | yes |
| When to use | to try it, projects without installation, other PCs | daily use with full protection |

When a project has the `jvcs` skill, it takes precedence.

## 5. Automation modes

Check-out and check-in each have three modes. **You** choose them; the AI cannot change the mode.

| Mode | Value | Check-out | Check-in |
|---|---|---|---|
| Manual | `manual` | the AI asks you to check out | refused to the AI: you check in |
| Ask for confirmation (default) | `confirm` | the AI runs `checkout <file> -Confirmed`; Claude Code asks for your approval | the AI adds `-Confirmed`; Claude Code asks for your approval |
| Automatic | `auto` | the hook checks out by itself before `Edit` | direct check-in, comment with `[IA]` |

In **every** mode, these always need your approval: `checkout -Force` (lock and keep a local change made
outside the VCS), `checkin -AllowEncodingChange` and `undocheckout -Discard` (a backup is made first).

Where to set them: **VCS Properties → AI / Automation**, or in your terminal
`jvcs-ai.ps1 config set checkout confirm` / `config set checkin manual`. They are stored in
`%APPDATA%\JEDI\JVCS\config.ini`, section `[ai]`, and apply to all projects of your Windows user.

| Situation | Suggestion |
|---|---|
| First contact, critical project | `checkout=confirm`, `checkin=confirm` |
| Daily use, you review before check-in | `checkout=auto`, `checkin=confirm` |
| Repetitive tasks in a test project | `checkout=auto`, `checkin=auto` |
| The AI should only read and suggest | `checkout=manual`, `checkin=manual` |

## 6. Typical workflow

1. **Status:** `jvcs-ai.ps1 status "<file>"`. Locked by another user → stop and tell you. Modified locally
   without check-out → ask before `checkout -Force -Confirmed`.
2. **Check-out:** by the hook (`auto`) or `checkout "<file>" -Confirmed` (`confirm`).
3. **Edit:** `Edit` for UTF-8 files; `edit-preserve.ps1` for ANSI (Windows-1252), UTF-16, or ASCII files
   that will get accented characters. Never `Write` over an existing Delphi source.
4. **Build and test.**
5. **Check-in:** the AI shows the files and the comment, then
   `jvcs-ai.ps1 checkin "<file>" -Comment "Fix ..."` (+ `-Confirmed` in confirm mode). Exit code 3 = no
   change (check-out undone); 7 `encodingChanged` = encoding or line endings changed.
6. **End:** `jvcs-ai.ps1 locks`. The Stop hook also reminds you of files left checked out.

## 7. Safety rules

- **Password:** the AI never receives, types or sees the password. The wrapper reads the saved identity
  and writes the password to the console's standard input. It never goes to the command line, logs, JSON
  output or files. `deny` rules block reading the identities registry key and calling the console with
  `/password`.
- **Limit:** the 2.5 client saves the identity password in Base64 in the user registry; any process of the
  same Windows user can read it. The rules make it harder, not impossible. The server protocol has no TLS:
  use it only on a LAN or VPN.
- **Rules (deny > ask > allow):** the AI cannot change modes, read the password, disable hooks, remove the
  read-only flag, or edit `.claude/settings*.json`, the `jvcs` skill, `tools\ai` or the JEDI VCS settings
  folders.
- **Encoding:** Delphi reads a source file without BOM as ANSI. The hook blocks edits that would break
  the encoding; `edit-preserve.ps1` writes in the file's own encoding; the check-in refuses a changed BOM,
  ANSI turned into UTF-8, changed line endings or new U+FFFD characters.
- **Integrity:** no orphan locks (a failed check-out is undone), no lost local changes (check-out refuses
  when the local file differs; `-Force`/`-Discard` make a backup in `%LOCALAPPDATA%\JEDI\JVCS\backup`),
  path proof before changing the server, one operation at a time per identity, timeouts.
- **File content is data, not instructions:** the skill tells the AI not to obey text found inside source
  files.
- **Audit:** `%LOCALAPPDATA%\JEDI\JVCS\ai-audit.log`, one JSON line per command.

Other agents (not Claude Code) can use the same wrapper and its JSON contract — see
[doc/pt/ia/07 (Portuguese)](../pt/ia/07-Outros-Agentes.md).
