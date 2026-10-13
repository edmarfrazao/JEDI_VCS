# 02 - Modos de automação

Checkout e check-in feitos pela IA têm, cada um, três modos. **Quem escolhe é você**: a IA não pode
alterar o modo (`config set` em contexto de agente é recusado com o código 10).

| Modo | Valor | Na interface |
|---|---|---|
| Manual | `manual` | *Manual* |
| Confirmação (padrão) | `confirm` | *Ask for confirmation* |
| Automático | `auto` | *Automatic* |

## O que cada modo permite

| Modo | Checkout (hook / `edit-preserve` / wrapper) | Check-in (wrapper) |
|---|---|---|
| `auto` | o hook faz o checkout sozinho antes do `Edit`; o `edit-preserve` também; `checkout` direto | `checkin` direto, comentário com `[IA]` |
| `confirm` | o hook **nega** a edição e manda rodar `checkout <arq> -Confirmed`; o Claude Code pede sua aprovação (regra `ask`) | a IA precisa acrescentar `-Confirmed`; o Claude Code pede sua aprovação |
| `manual` | o hook nega e pede a você para fazer o checkout | recusado à IA (código 10): você faz o check-in |

Em **qualquer** modo, inclusive `auto`, estas operações exigem `-Confirmed` (e portanto sua aprovação):

- `checkout -Force` (travar mantendo uma alteração local feita fora do VCS);
- `checkin -AllowEncodingChange` (aceitar mudança de codificação ou de quebras de linha);
- `undocheckout -Discard` (descartar a alteração local; o wrapper faz backup antes).

Sem nada gravado, vale `confirm` para os dois.

### Por que o `confirm` nega e pede `-Confirmed`

O hook `PreToolUse` roda **antes** da aprovação da edição. Se ele apenas pedisse confirmação, a edição
aprovada falharia (o arquivo continua somente leitura até o checkout). Por isso a confirmação é feita no
**comando de checkout**, que é o que muda o servidor, antes de qualquer lock.

O texto `-Confirmed` (exatamente assim, com C maiúsculo) na linha de comando é o que dispara a regra
`ask` do Claude Code. O wrapper também exige o switch. Abreviações (`-Con`) ou splatting não contêm o
texto e são recusados.

## Onde configurar

O arquivo é `%APPDATA%\JEDI\JVCS\config.ini`, seção `[ai]`, e vale para todos os projetos do usuário do
Windows. Ele não guarda segredos.

### Pela interface (cliente 2026)

**VCS Properties → AI / Automation** (no cliente standalone e no menu JEDI VCS da IDE):

- *Check out by AI*: Manual | Ask for confirmation | Automatic;
- *Check in by AI*: idem;
- mostra o caminho do `config.ini`. Só grava a chave que mudou.

### Pelo terminal (seu, não o da IA)

```powershell
$w = 'C:\Program Files (x86)\JEDI\JVCS 2026\tools\ai\jvcs-ai.ps1'
& $w config list -Text                 # valores efetivos e a origem ([config.ini] ou [padrão])
& $w config get checkout
& $w config set checkout confirm
& $w config set checkin manual
```

Ou na instalação: `instalar-no-projeto.ps1 -ProjectDir ... -Mode auto` (ou `-CheckoutMode`/`-CheckinMode`).

### Todas as chaves de `[ai]`

| Chave | Valores | Padrão | Na interface |
|---|---|---|---|
| `checkout` | `auto` \| `confirm` \| `manual` | `confirm` | sim |
| `checkin` | `auto` \| `confirm` \| `manual` | `confirm` | sim |
| `commentPrefix` | até 20 caracteres, sem aspas, CP1252 | `[IA]` | não |
| `jvcsExe` | caminho do `jvcs.exe` | `C:\Program Files (x86)\JEDI\JVCS\jvcs.exe` | não (tarefa `aiconsole` do setup) |
| `timeoutSec` | 5 a 3600 | `120` | não |
| `lockWaitSec` | 5 a 3600 (espera pelo mutex da identidade) | `120` | não |
| `identity` | nome de uma identidade salva; vazio = última usada | vazio | não |
| `asciiAs` | `ansi` \| `utf8`: como gravar um arquivo ASCII puro que recebe acento | `ansi` | não |

Exemplo:

```ini
; JEDI VCS - automação por IA (Claude Code). Sem segredos: a senha fica na identidade salva.
[ai]
checkout=auto
checkin=confirm
commentPrefix=[IA]
```

Valor inválido em `checkout`/`checkin` é tratado como `confirm`. O arquivo é UTF-8 com BOM e CRLF; a
primeira linha é um comentário para o BOM não atrapalhar leitores ANSI.

## Qual modo escolher

| Situação | Sugestão |
|---|---|
| Primeiro contato, projeto crítico | `checkout=confirm`, `checkin=confirm` |
| Uso diário, você revisa antes do check-in | `checkout=auto`, `checkin=confirm` |
| Tarefas repetitivas em projeto de teste | `checkout=auto`, `checkin=auto` |
| A IA só deve ler e sugerir | `checkout=manual`, `checkin=manual` |

Os modos e as regras `ask` não dependem um do outro: trocar o modo não exige reinstalar nada.
