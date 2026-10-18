# JEDI VCS 2.5 Beta 2026 — English user guide

> ⚠️ **Disclaimer:** this product is provided without any warranty of operation. Test and validate it in your own environment, with a backup and a copy of your JEDI VCS database, and apply any local fixes you need before deploying to production. Read the [full disclaimer](../../DISCLAIMER.md).

This guide explains what you need to install and use **JEDI VCS 2.5 Beta 2026**: the JEDI VCS 2.5 client
ported to Delphi 11, 12 and 13, fully compatible with the existing **JEDI VCS 2.5 Beta 3 server**
(Firebird). Project overview, download and licenses: [README.md](../../README.md).

> **Note:** this English guide is a summary for users. The detailed technical documentation (full manual,
> server setup, source code, port history and decisions) is written in **Brazilian Portuguese**. The
> links to it are listed below; an automatic translator works well with those pages.

## Guide

| Chapter | Contents |
|---|---|
| [01 Overview](01-Overview.md) | JEDI VCS concepts (server, archive, projects, modules, locks, identities, branching) and what changed in the 2026 edition |
| [02 Installation](02-Installation.md) | Installer components, install folder, repair/uninstall, coexistence with 2.5.0.1030, older IDEs |
| [03 Delphi IDE integration](03-Delphi-IDE-Integration.md) | JEDI VCS menu, Project Manager, first login, server address, project names, logs |
| [04 Standalone client](04-Standalone-Client.md) | Main window, appearance options, dark theme, font and scaling, VCS Properties pages |
| [05 Using with AI](05-Using-with-AI.md) | The `jvcs-ai.ps1` wrapper, automation modes, the `jedi-vcs` skill, safety rules |
| [06 Building from source](06-Building-from-Source.md) | Build scripts, Delphi versions, third-party libraries |
| [07 FAQ and troubleshooting](07-FAQ-and-Troubleshooting.md) | Common problems and their solutions |
| [08 Credits and rights](08-Credits-and-Rights.md) | Creators and maintainers, license rights, the `FVCSCrypt.dll` requirement and why there is no 64-bit client |

## Where to start

| You want to... | Read |
|---|---|
| Install the client on your PC and use it from Delphi | [02](02-Installation.md) → [03](03-Delphi-IDE-Integration.md) |
| Understand how JEDI VCS works | [01](01-Overview.md) |
| Let an AI assistant check out and check in files | [05](05-Using-with-AI.md) |
| Fix a problem | [07](07-FAQ-and-Troubleshooting.md) |
| Know what changed in each version | [What's new](../../news/en/README.md) |

## Detailed documentation (Portuguese)

| Topic | Link |
|---|---|
| Full documentation index | [doc/pt/README.md](../pt/README.md) |
| User manual (server installation, first access, IDE, all client options, command line, passwords, troubleshooting, installer) | [manual](../pt/manual/README.md) |
| Server installation and configuration (Firebird, port 2106, backup) | [manual 01](../pt/manual/01-Servidor-Instalacao-e-Configuracao.md) |
| Client options, page by page | [manual 04](../pt/manual/04-Opcoes-do-Cliente.md) |
| Command line (`jvcs.exe`) | [manual 06](../pt/manual/06-Linha-de-Comando.md) |
| Default passwords and security | [manual 07](../pt/manual/07-Senhas-Padrao-e-Seguranca.md) |
| AI guide (full) | [ia](../pt/ia/README.md) |
| Source code, architecture and build | [fontes](../pt/fontes/README.md) |
| Port history, decisions, tests and release process | [processo](../pt/processo/README.md) |
| Installer (technical) | [setup/LEIAME.md](../../setup/LEIAME.md) |
| Technical changelog | [CHANGELOG.md](../../CHANGELOG.md) |
