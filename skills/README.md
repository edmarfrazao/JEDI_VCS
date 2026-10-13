# Skills for AI assistants / Skills para assistentes de IA

🇺🇸 [English](#english) · 🇧🇷 [Português](#português)

| Language · Idioma | Folder · Pasta | Installed by the setup in · Instalada pelo setup em |
|---|---|---|
| English | [`skills/en/jedi-vcs`](en/jedi-vcs/README.md) | `<install folder>\tools\ai\skills\en\jedi-vcs` |
| Português | [`skills/pt/jedi-vcs`](pt/jedi-vcs/README.md) | `<pasta de instalação>\tools\ai\skills\pt\jedi-vcs` |

## English

A **skill** is a folder with a `SKILL.md` file (plus references and scripts) that Claude Code loads when
the subject matches its description. The `jedi-vcs` skill teaches the AI to work with **JEDI VCS** in
Delphi projects: status and locks, check-out before editing, editing that preserves the encoding (ANSI
1252, UTF-8, BOM, CRLF) and check-in with an `[IA]` comment, always through the `jvcs-ai.ps1` wrapper of
the **AI tools** component.

Both versions have the **same name** (`name: jedi-vcs`) and the same workflow and rules; only the
language changes. **Install only one of them** in the same destination:

```powershell
# English (global, all projects of this user; close Claude Code first)
$dst = "$env:USERPROFILE\.claude\skills\jedi-vcs"
New-Item -ItemType Directory -Force $dst | Out-Null
Copy-Item -Recurse -Force 'C:\path\to\JEDI_VCS\skills\en\jedi-vcs\*' $dst
# from the installer: 'C:\Program Files (x86)\JEDI\JVCS 2026\tools\ai\skills\en\jedi-vcs\*'
```

For a single project, use `<project>\.claude\skills\jedi-vcs` as the destination. To switch language,
delete the destination folder and copy the other version. Copy byte by byte:
`scripts\localizar-wrapper.ps1` is UTF-8 with BOM. Details: [en/jedi-vcs/README.md](en/jedi-vcs/README.md)
and [Using with AI](../doc/en/05-Using-with-AI.md).

The per-project skill `jvcs` (hooks and `allow`/`ask`/`deny` rules) is a different thing: it is installed
by `tools\ai\instalar-no-projeto.ps1` from `tools\ai\claude\skills\jvcs`.

## Português

Uma **skill** é uma pasta com um `SKILL.md` (mais referências e scripts) que o Claude Code carrega quando
o assunto bate com a descrição dela. A skill `jedi-vcs` ensina a IA a trabalhar com o **JEDI VCS** em
projetos Delphi: status e locks, checkout antes de editar, edição que preserva a codificação (ANSI 1252,
UTF-8, BOM, CRLF) e check-in com comentário `[IA]`, sempre pelo wrapper `jvcs-ai.ps1` das
**Ferramentas da IA**.

As duas versões têm o **mesmo nome** (`name: jedi-vcs`), o mesmo fluxo e as mesmas regras; só muda o
idioma. **Instale só uma delas** no mesmo destino:

```powershell
# Português (global, todos os projetos deste usuário; feche o Claude Code antes)
$dst = "$env:USERPROFILE\.claude\skills\jedi-vcs"
New-Item -ItemType Directory -Force $dst | Out-Null
Copy-Item -Recurse -Force 'C:\caminho\do\JEDI_VCS\skills\pt\jedi-vcs\*' $dst
# pelo instalador: 'C:\Program Files (x86)\JEDI\JVCS 2026\tools\ai\skills\pt\jedi-vcs\*'
```

Para um projeto só, use `<projeto>\.claude\skills\jedi-vcs` como destino. Para trocar de idioma, apague a
pasta de destino e copie a outra versão. Copie byte a byte: `scripts\localizar-wrapper.ps1` é UTF-8 com
BOM. Detalhes: [pt/jedi-vcs/README.md](pt/jedi-vcs/README.md) e [doc/pt/ia](../doc/pt/ia/README.md).

A skill por projeto `jvcs` (hooks e regras `allow`/`ask`/`deny`) é outra coisa: é instalada pelo
`tools\ai\instalar-no-projeto.ps1` a partir de `tools\ai\claude\skills\jvcs`.
