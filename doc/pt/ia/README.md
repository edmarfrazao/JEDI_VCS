# JEDI VCS com IA

Guia para usar o **JEDI VCS 2.5 Beta 2026** com assistentes de IA que executam comandos (Claude Code e
outros). A IA consulta o estado dos fontes, faz checkout antes de editar, edita sem estragar a
codificação e faz check-in com comentário marcado `[IA]`. Os modos e as aprovações ficam com você.

> Referência técnica completa (implementação, testes, decisões): [`tools/ai/LEIAME.md`](../../../tools/ai/LEIAME.md).
> Este guia é a versão para quem vai **usar**.

## O que a IA pode fazer

| Ação | Como | Observação |
|---|---|---|
| Ver o estado dos fontes | `jvcs-ai.ps1 status`, `list`, `locks` | compara byte a byte com a última revisão do servidor |
| Fazer checkout | automático pelo hook ao editar, ou `jvcs-ai.ps1 checkout` | nunca trava um arquivo cujo conteúdo local difere do servidor |
| Editar preservando a codificação | `Edit` do Claude Code (UTF-8) ou `edit-preserve.ps1` (ANSI 1252, UTF-16, arquivo inteiro) | mantém BOM e quebras de linha (CRLF/LF/CR) |
| Fazer check-in | `jvcs-ai.ps1 checkin -Comment "..."` | prefixo `[IA]` automático; sem mudança → desfaz o checkout |
| Desfazer checkout | `jvcs-ai.ps1 undocheckout` | só quando o arquivo voltou a ser igual ao servidor (`-Discard` exige aprovação) |
| Ver o diff contra o servidor | `jvcs-ai.ps1 diff <arq> [-Rev x.y]` | diff unificado contra a última revisão (ou a pedida); só leitura |
| Criar projeto | `jvcs-ai.ps1 addproject <proj.dpr>` | segue o modo de check-in; exige o console 2026 |
| Adicionar arquivo novo | `jvcs-ai.ps1 add <arq> -Comment "..."` | cadastra e faz o 1º check-in 0.1 (com o `.dfm`); segue o modo de check-in; exige o console 2026 |

`addproject` e `add` precisam do console `jvcs.exe` **2026** (o original não cria projeto nem módulo):
`jvcs-ai.ps1 config set jvcsExe <caminho do jvcs.exe 2026>` no seu terminal.

Fora isso, a IA **não** faz sync, label
nem administra usuários.

## Arquitetura em camadas

```text
 Você ── aprova / recusa ──┐
                           ▼
 Claude Code (ou outro agente)
   │  skill jedi-vcs / jvcs ........ ensina o fluxo e as regras
   │  regras allow / ask / deny ..... o que roda sem perguntar, o que pergunta, o que é proibido
   │  hooks PreToolUse / Stop ....... checkout antes do Edit, guarda de codificação, lembrete de locks
   ▼
 tools\ai\jvcs-ai.ps1 (wrapper PowerShell)      tools\ai\edit-preserve.ps1
   │  identidade salva, senha pelo stdin,          edição com a codificação
   │  mutex, timeout, prova do caminho,            e as quebras de linha do arquivo
   │  modos auto/confirm/manual, JSON, auditoria
   ▼
 jvcs.exe (console JEDI VCS, original 2.5.0.1030 ou o novo 2.5.0.20xx (2.5.0.2050 = beta 5))
   ▼
 Servidor JEDI VCS (2.5, Firebird)
```

- **Camada 0 (hoje):** o console `jvcs.exe` atrás do wrapper. O console sozinho não serve para
  automação (devolve 0 em erro, não mostra recusa do servidor, pergunta coisas que não consegue
  perguntar com a entrada redirecionada). O wrapper resolve isso e devolve JSON.
- **Camadas futuras** (ADR-001): console portado com saída JSON nativa e senha no Gerenciador de
  Credenciais; servidor MCP com ferramentas tipadas. Ver
  [`doc/pt/common/ADR-001-CLI-IA-e-Plugin-Multi-Delphi.md`](../common/ADR-001-CLI-IA-e-Plugin-Multi-Delphi.md).

## Requisitos

- Windows com **Windows PowerShell 5.1** (`powershell.exe`).
- **JEDI VCS 2.5 Beta 2026** instalado com o componente **Ferramentas da IA** (ou uma cópia da pasta
  `tools\ai` deste repositório) e um `jvcs.exe` com `fvcscrypt.dll` ao lado.
- Uma **identidade salva com senha** (Server Login → *Store Password with identity*).
- Projeto Delphi já versionado no JEDI VCS e aberto na **mesma pasta registrada no servidor**.
- Para o Claude Code: versão **2.1.295 ou mais nova** (os hooks usam `"onFailure": "block"`).

## Guia

| Documento | Conteúdo |
|---|---|
| [01 - Instalação](01-Instalacao.md) | setup ou cópia manual, instalação no projeto, identidade, confiança da pasta, verificação |
| [02 - Modos de automação](02-Modos-de-Automacao.md) | manual, confirmação e automático; onde configurar |
| [03 - Comandos do wrapper](03-Comandos-do-Wrapper.md) | referência de `jvcs-ai.ps1` e `edit-preserve.ps1`, JSON e códigos de saída |
| [04 - Fluxo de trabalho](04-Fluxo-de-Trabalho.md) | passo a passo de uma alteração, exemplo real, boas práticas |
| [05 - Segurança](05-Seguranca.md) | senha, regras, hooks, codificação, auditoria, limites |
| [06 - Solução de problemas](06-Solucao-de-Problemas.md) | erros comuns e como resolver |
| [07 - Outros agentes](07-Outros-Agentes.md) | usar com outras IAs/CLIs: contrato JSON e regras mínimas |

## Skill distribuível

A skill **`jedi-vcs`** ([`skills/pt/jedi-vcs/`](../../../skills/pt/jedi-vcs/README.md); em inglês: [`skills/en/jedi-vcs/`](../../../skills/en/jedi-vcs/README.md)) ensina o fluxo a qualquer
sessão do Claude Code, em qualquer projeto Delphi, desde que o wrapper esteja instalado.

| | Skill global `jedi-vcs` | Skill por projeto `jvcs` |
|---|---|---|
| Origem | `skills\pt\jedi-vcs` ou `skills\en\jedi-vcs` (este repositório; instale só uma) | `tools\ai\claude\skills\jvcs`, copiada por `instalar-no-projeto.ps1` |
| Onde fica | `%USERPROFILE%\.claude\skills\jedi-vcs` ou `<projeto>\.claude\skills\jedi-vcs` | `<projeto>\.claude\skills\jvcs` |
| Caminho do wrapper | descoberto por `scripts\localizar-wrapper.ps1` | gravado na instalação (caminho absoluto) |
| Hooks e regras allow/ask/deny | não instala (a skill só orienta) | instalados junto no `.claude\settings.json` |
| Quando usar | conhecer/experimentar; projetos sem instalação; outros PCs | uso diário com proteção completa |

As duas seguem o mesmo fluxo e as mesmas regras. Quando o projeto tem a skill `jvcs`, ela prevalece
(os caminhos dela batem com as regras `allow` instaladas).
