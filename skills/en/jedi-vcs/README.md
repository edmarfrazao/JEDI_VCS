# `jedi-vcs` skill for Claude Code

Teaches Claude Code to work with **JEDI VCS** in Delphi projects: show status and locks, check out before
editing, edit without breaking the encoding (ANSI 1252, UTF-8, BOM, CRLF) and check in with an `[IA]`
comment. The skill does not talk to the server by itself: it uses the `jvcs-ai.ps1` wrapper from the
**AI tools** component of JEDI VCS 2.5 Beta 2026.

This is the **English** version. The Portuguese version is in
[`skills/pt/jedi-vcs`](../../pt/jedi-vcs/README.md). Both are named `jedi-vcs`: install **only one** of
them in the same destination (see [`skills/README.md`](../../README.md)).

```text
skills/en/jedi-vcs/
  SKILL.md                          instructions (loaded when the subject is JEDI VCS)
  references/commands.md            quick reference for the wrapper and edit-preserve
  references/troubleshooting.md
  references/jvcs-console.md        jvcs.exe commands for those who do not use the wrapper
  scripts/localizar-wrapper.ps1     finds the installed tools\ai (read-only)
```

## Requirements

- Windows with Windows PowerShell 5.1.
- **JEDI VCS 2.5 Beta 2026** installed with the **AI tools** component
  (`C:\Program Files (x86)\JEDI\JVCS 2026\tools\ai`), or the `tools\ai` folder of this repository
  anywhere, with the `JVCS_AI_TOOLS` environment variable pointing to it.
- An **identity saved with its password** in the JEDI VCS client (Server Login → *Store Password with identity*).
- A Delphi project already in JEDI VCS, opened in the same folder registered on the server.
- Claude Code 2.1.295 or newer (if you use the installer hooks).

## Installation

Choose **one** of the options.

### Global (all projects of this user)

```powershell
$dst = "$env:USERPROFILE\.claude\skills\jedi-vcs"
New-Item -ItemType Directory -Force $dst | Out-Null
Copy-Item -Recurse -Force 'C:\path\to\JEDI_VCS\skills\en\jedi-vcs\*' $dst
```

### In one project (versioned together with the project)

```powershell
$dst = 'C:\path\to\project\.claude\skills\jedi-vcs'
New-Item -ItemType Directory -Force $dst | Out-Null
Copy-Item -Recurse -Force 'C:\path\to\JEDI_VCS\skills\en\jedi-vcs\*' $dst
```

From the installer, the source is `<install folder>\tools\ai\skills\en\jedi-vcs`, for example (close
Claude Code first):

```
robocopy "C:\Program Files (x86)\JEDI\JVCS 2026\tools\ai\skills\en\jedi-vcs" "%USERPROFILE%\.claude\skills\jedi-vcs" /E
```

Copy byte by byte: `scripts\localizar-wrapper.ps1` is UTF-8 with BOM (required by PowerShell 5.1).

### Full protection: `instalar-no-projeto.ps1`

The skill only **guides** the AI. To also get the hooks (automatic check-out before `Edit`, blocking edits
that would break the encoding, a reminder of pending locks) and the `allow`/`ask`/`deny` rules, run in
**your own** terminal:

```powershell
& 'C:\Program Files (x86)\JEDI\JVCS 2026\tools\ai\instalar-no-projeto.ps1' -ProjectDir 'C:\path\to\project' -Mode confirm
```

The script copies the **per-project** variant of the skill (`.claude\skills\jvcs`, in Portuguese), already
with the absolute paths that the `allow` rules recognize. When it is present, `jedi-vcs` defers to `jvcs`.
See [Using with AI](../../../doc/en/05-Using-with-AI.md).

| | `jedi-vcs` (this one) | `jvcs` (from the script) |
|---|---|---|
| Scope | global or per project, copied by hand | per project |
| Wrapper path | found by `localizar-wrapper.ps1` | written at install time |
| Hooks and rules | no | yes |
| Content | same workflow and same rules | same |

## How to test

1. Open Claude Code in a versioned project folder (`claude`, or the desktop app) and accept the folder
   trust.
2. Ask: **"show the JEDI VCS status of this project"**.
3. Expected: the AI loads the skill, finds the wrapper and shows something like

   ```text
   [OK 0] status (exemplo01.dpr)
     #4 uprincipal.pas v0.14 local=clean -> ok
     #1 exemplo01.dpr v0.1 local=clean -> ok
   ```

Read-only test without the user interface:

```powershell
cd C:\path\to\project
claude -p "use the jedi-vcs skill and show the JEDI VCS status of this project" --allowedTools PowerShell Read Grep Glob --max-turns 10
```

Wrapper locator only:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.claude\skills\jedi-vcs\scripts\localizar-wrapper.ps1" -Text
```

`localizar-wrapper.ps1` looks for `tools\ai` in this order: the `JVCS_AI_TOOLS` variable, the project
manifest written by `instalar-no-projeto.ps1`, the installation (uninstall registry key), the default
folders and, last, a `tools\ai` folder above the current folder (repository).

## Compatibility

| Item | Support |
|---|---|
| System | Windows 10/11 (PowerShell 5.1). No Linux/macOS support: the console is Win32 |
| JEDI VCS server | 2.5 (Firebird), tested with 2.50 Beta 3 |
| Console | `jvcs.exe` 2.5.0.1030 (original) and 2.5.0.2026 |
| Delphi | any version: the skill works on the files, not in the IDE |
| AI tools (`tools\ai`) | 1.1.1 or newer |
| Claude Code | skills: current versions; installer hooks: 2.1.295+ |
| Other agents | they do not use Claude Code skills; see [`doc/pt/ia/07-Outros-Agentes.md`](../../../doc/pt/ia/07-Outros-Agentes.md) (Portuguese) |

Full guide: [Using with AI](../../../doc/en/05-Using-with-AI.md) (English) and
[`doc/pt/ia/`](../../../doc/pt/ia/README.md) (Portuguese).
