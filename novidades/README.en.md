[🇧🇷 Português](README.md) · 🇺🇸 English

# What's new — JEDI VCS 2.5 Beta 2026

> ⚠️ **Disclaimer:** this product is provided without any warranty of operation. Test and validate it in your own environment, with a backup and a copy of your JEDI VCS database, and apply any local fixes you need before deploying to production. Read the [full disclaimer](../DISCLAIMER.md).

Release notes for each beta of **JEDI VCS 2.5 Beta 2026**, the JEDI VCS 2.5 client ported to modern
Delphi. The 2.5 Beta 3 server is not changed and the protocol is identical.

Each release page is written in Portuguese and starts with an **English summary**.

| Version | Date | Status | Highlights |
|---|---|---|---|
| [Beta 3](2026-10-xx-beta3.md) | being tested | **not released** | Older IDEs (Delphi 7 to 10.4 Sydney) with the original expert + new core; AI skill in the installer; faster Project Manager in the IDE |
| [Beta 2](2026-10-13-beta2.md) | 2026-10-13 | [released](https://github.com/edmarfrazao/JEDI_VCS/releases/tag/v2.5.0.2026-beta2) (pre-release) | Delphi 11, 12 and 13 (any update), fixed dark theme, appearance and AI options, many fixes |
| [Beta 1](2026-10-13-beta1.md) | 2026-10-13 | [released](https://github.com/edmarfrazao/JEDI_VCS/releases/tag/v2.5.0.2026-beta1) — replaced by Beta 2 | First installer: client, Diff, console and expert for Delphi 13.2 |

## Summaries

### Beta 3 (being tested)

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
- Known issues: some JVCL visual components remain; the 64-bit IDE is not supported; default project names
  (`Project1`) are refused.

### Beta 1 (2026-10-13)

- First public build: standalone client, Diff, console and an IDE expert for Delphi 13.2.
- Replaced by Beta 2: the Beta 1 expert does not load on Delphi 13.1, the dark theme hides project names,
  and Delphi 11/12 were not supported.

The technical changelog is in Portuguese: [CHANGELOG.md](../CHANGELOG.md). English user guide:
[doc/en](../doc/en/README.md).

## Download

Always from the [Releases](https://github.com/edmarfrazao/JEDI_VCS/releases) page. Check the SHA-256 shown on
each version page before you install.
