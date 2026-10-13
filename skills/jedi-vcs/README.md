# Skill `jedi-vcs` para Claude Code

Ensina o Claude Code a trabalhar com o **JEDI VCS** em projetos Delphi: ver status e locks, fazer
checkout antes de editar, editar sem estragar a codificação (ANSI 1252, UTF-8, BOM, CRLF) e fazer
check-in com comentário `[IA]`. A skill não fala com o servidor sozinha: ela usa o wrapper
`jvcs-ai.ps1` das **Ferramentas da IA** do JEDI VCS 2.5 Beta 2026.

```text
skills/jedi-vcs/
  SKILL.md                          instruções (carregadas quando o assunto é JEDI VCS)
  references/comandos.md            referência rápida do wrapper e do edit-preserve
  references/solucao-de-problemas.md
  references/console-jvcs.md        comandos do jvcs.exe para quem não usa o wrapper
  scripts/localizar-wrapper.ps1     acha o tools\ai instalado (só leitura)
```

## Pré-requisitos

- Windows com Windows PowerShell 5.1.
- **JEDI VCS 2.5 Beta 2026** instalado com o componente **Ferramentas da IA**
  (`C:\Program Files (x86)\JEDI\JVCS 2026\tools\ai`), ou a pasta `tools\ai` deste repositório em
  qualquer lugar com a variável `JVCS_AI_TOOLS` apontando para ela.
- Uma **identidade salva com senha** no cliente JEDI VCS (Server Login → *Store Password with identity*).
- Projeto Delphi versionado no JEDI VCS, aberto na mesma pasta registrada no servidor.
- Claude Code 2.1.295 ou mais novo (se usar os hooks do instalador).

## Instalação

Escolha **uma** das formas.

### Global (todos os projetos deste usuário)

```powershell
$dst = "$env:USERPROFILE\.claude\skills\jedi-vcs"
New-Item -ItemType Directory -Force $dst | Out-Null
Copy-Item -Recurse -Force 'C:\caminho\do\JEDI_VCS\skills\jedi-vcs\*' $dst
```

### Num projeto (versionável junto com o projeto)

```powershell
$dst = 'C:\caminho\do\projeto\.claude\skills\jedi-vcs'
New-Item -ItemType Directory -Force $dst | Out-Null
Copy-Item -Recurse -Force 'C:\caminho\do\JEDI_VCS\skills\jedi-vcs\*' $dst
```

Copie byte a byte: `scripts\localizar-wrapper.ps1` é UTF-8 com BOM (necessário no PowerShell 5.1).

### Proteção completa: `instalar-no-projeto.ps1`

A skill só **orienta** a IA. Para ter também os hooks (checkout automático antes do `Edit`, bloqueio de
edição que estraga a codificação, lembrete de locks) e as regras `allow`/`ask`/`deny`, rode no **seu**
terminal:

```powershell
& 'C:\Program Files (x86)\JEDI\JVCS 2026\tools\ai\instalar-no-projeto.ps1' -ProjectDir 'C:\caminho\do\projeto' -Mode confirm
```

O instalador copia a variante **por projeto** da skill (`.claude\skills\jvcs`), já com os caminhos
absolutos que as regras `allow` reconhecem. Com ela presente, a `jedi-vcs` manda seguir a `jvcs`.
Ver [`doc/ia/01-Instalacao.md`](../../doc/ia/01-Instalacao.md).

| | `jedi-vcs` (esta) | `jvcs` (do instalador) |
|---|---|---|
| Escopo | global ou por projeto, copiada à mão | por projeto |
| Caminho do wrapper | descoberto por `localizar-wrapper.ps1` | gravado na instalação |
| Hooks e regras | não | sim |
| Conteúdo | mesmo fluxo e mesmas regras | idem |

## Como testar

1. Abra o Claude Code na pasta de um projeto versionado (`claude`, ou o app desktop) e aceite a
   confiança da pasta.
2. Peça: **"mostre o status do JEDI VCS deste projeto"**.
3. Esperado: a IA carrega a skill, localiza o wrapper e mostra algo como

   ```text
   [OK 0] status (exemplo01.dpr)
     #4 uprincipal.pas v0.14 local=clean -> ok
     #1 exemplo01.dpr v0.1 local=clean -> ok
   ```

Sem interface, só leitura:

```powershell
cd C:\caminho\do\projeto
claude -p "use a skill jedi-vcs e mostre o status do JEDI VCS deste projeto" --allowedTools PowerShell Read Grep Glob --max-turns 10
```

Teste só do localizador:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.claude\skills\jedi-vcs\scripts\localizar-wrapper.ps1" -Text
```

### Resultado registrado (13/10/2026)

Skill copiada para `<projeto>\.claude\skills\jedi-vcs` de um projeto de teste (`Exemplo01`, que também
tinha a skill `jvcs` do instalador) e o comando `claude -p` acima: a IA usou a skill, consultou o
wrapper e respondeu com os 4 módulos `clean` (uprincipal.pas v0.14, exemplo01.res/.dproj/.dpr v0.1),
nenhum checkout, e apontou que `Project1.dpr` usa nome padrão recusado pelo JEDI VCS. Só leitura;
nenhum lock criado. O Claude Code avisou que as regras `allow` foram ignoradas porque a pasta não tinha
a confiança aceita (as chamadas ao wrapper foram liberadas pelo `--allowedTools`).

`localizar-wrapper.ps1`: na pasta do projeto achou o `tools\ai` pelo manifesto do instalador; fora
dele, pela instalação (`C:\Program Files (x86)\JEDI\JVCS 2026\tools\ai`, registro de desinstalação).

## Compatibilidade

| Item | Suporte |
|---|---|
| Sistema | Windows 10/11 (PowerShell 5.1). Sem suporte a Linux/macOS: o console é Win32 |
| Servidor JEDI VCS | 2.5 (Firebird), testado com 2.50 Beta 3 |
| Console | `jvcs.exe` 2.5.0.1030 (original) e 2.5.0.2026 |
| Delphi | qualquer versão: a skill trabalha nos arquivos, não na IDE |
| Ferramentas da IA (`tools\ai`) | 1.1.1 ou mais nova |
| Claude Code | skills: versões atuais; hooks do instalador: 2.1.295+ |
| Outros agentes | não usam skills do Claude Code; ver [`doc/ia/07-Outros-Agentes.md`](../../doc/ia/07-Outros-Agentes.md) |

Documentação completa: [`doc/ia/`](../../doc/ia/README.md).
