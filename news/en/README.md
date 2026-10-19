[🇧🇷 Português](../pt/README.md) · 🇺🇸 English

# What's new — JEDI VCS 2.5 Beta 2026

> ⚠️ **Disclaimer:** this product is provided without any warranty of operation. Test and validate it in your own environment, with a backup and a copy of your JEDI VCS database, and apply any local fixes you need before deploying to production. Read the [full disclaimer](../../DISCLAIMER.md).

Release notes for each beta of **JEDI VCS 2.5 Beta 2026**, the JEDI VCS 2.5 client ported to modern
Delphi. The 2.5 Beta 3 server is not changed and the protocol is identical.

Each release has an English page in this folder.

| Version | Date | Status | Highlights |
|---|---|---|---|
| [Beta 6, build 2063](2026-10-19-build2063.md) | 2026-10-19 | [released](https://github.com/edmarfrazao/JEDI_VCS/releases/tag/v2.5.0.2026-beta6-build2063) | **build 2063**: `verify` with no project (search in all projects, `ambiguous`, extension filter, single files); `status` sum; wrapper security fixes; template 1.4.0 |
| [Beta 6](2026-10-17-beta6.md) | 2026-10-17 | [released](https://github.com/edmarfrazao/JEDI_VCS/releases/tag/v2.5.0.2026-beta6) (pre-release) | **build 2061**: the 2026 `jvcs.exe` console in the installer (projects and modules without the IDE, history, search, labels, ToDo, bugs, administration); AI wrapper 1.4.0; the AI uses the new console by default; S0002 (untracked, verify, doctor) |
| [Beta 5](2026-10-13-beta5.md) | 2026-10-13 | [released](https://github.com/edmarfrazao/JEDI_VCS/releases/tag/v2.5.0.2026-beta5) (pre-release) | **build 2050**: XE3 crash fixed; installed version visible (title, About, Control Panel); pt/en docs and skills |
| [Beta 4](2026-10-13-beta4.md) | 2026-10-13 | [released](https://github.com/edmarfrazao/JEDI_VCS/releases/tag/v2.5.0.2026-beta4) (pre-release) | choose each Delphi; older IDEs (7 to 10.4); AI skill; pt/en docs — XE3: toolbar crash (next beta) |
| [Beta 2](2026-10-13-beta2.md) | 2026-10-13 | [released](https://github.com/edmarfrazao/JEDI_VCS/releases/tag/v2.5.0.2026-beta2) (pre-release) | Delphi 11, 12 and 13 (any update), fixed dark theme, appearance and AI options, many fixes |
| [Beta 1](2026-10-13-beta1.md) | 2026-10-13 | [released](https://github.com/edmarfrazao/JEDI_VCS/releases/tag/v2.5.0.2026-beta1) — replaced by Beta 2 | First installer: client, Diff, console and expert for Delphi 13.2 |

## Summaries

### Beta 6 (2026-10-18)

- **Console:** the installer now ships the 2026 `jvcs.exe` console, with about 50 commands: projects and
  modules without the IDE, history, search, labels, ToDo, milestones, bugs and administration.
- **AI:** wrapper 1.4.0 (`diff`, `sync`, `changes`, `search`, `blame`, `revert`, labels, ToDo, bugs and
  administration with preview and approval). The installer task that points the AI to the new console is now
  checked by default.

### Beta 4 (2026-10-13)

- **Older IDEs:** every Delphi supported by the original 2.5.0.1030 (Delphi 7 to 10.4 Sydney) gets the new
  core through its original thin expert. Each detected IDE can be selected in the installer; uninstall
  restores the previous expert. Delphi 5 and 6 are not covered.
- **AI:** the `jedi-vcs` skill for Claude Code is included in the installer; the wrapper `status` ignores
  Windows copies such as `X - Copy.dpr`.
- **Performance:** the Project Manager opens faster in the IDE (from about 21 s to less than 1 s in the
  test).
- **Documentation:** README, port process, sources, AI guide, release notes and the English guide.

### Beta 2 (2026-10-13)

- **IDE integration for Delphi 11, 12 and 13, any update**, without third-party components in the IDE.
- **Appearance:** fixed dark theme, "Follow Delphi" with the real IDE theme, Appearance page (scale, fonts,
  theme).
- **AI / Automation page** in VCS Properties.
- **Fixes:** slow project opening, Compare all, password-protected backup, Line History, saved password
  cleared on login, windows cut at 150–200%, error logs in `%LOCALAPPDATA%\JEDI\JVCS\logs`.
- Known issues: the 64-bit IDE is not supported; default project names
  (`Project1`) are refused.

### Beta 1 (2026-10-13)

- First public build: standalone client, Diff, console and an IDE expert for Delphi 13.2.
- Replaced by Beta 2: the Beta 1 expert does not load on Delphi 13.1, the dark theme hides project names,
  and Delphi 11/12 were not supported.

The technical changelog is in Portuguese: [CHANGELOG.md](../../CHANGELOG.md). English user guide:
[doc/en](../../doc/en/README.md).

## Download

Always from the [Releases](https://github.com/edmarfrazao/JEDI_VCS/releases) page. Check the SHA-256 shown on
each version page before you install.
