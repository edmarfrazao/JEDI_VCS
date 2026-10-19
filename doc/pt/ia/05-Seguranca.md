# 05 - Segurança

O que protege seus fontes e sua senha quando uma IA usa o JEDI VCS, e o que **não** protege.

## Senha

- A IA **nunca** recebe, digita ou vê a senha. O wrapper lê a **identidade salva** (a mesma da GUI e da
  IDE), converte a senha em bytes e a escreve na **entrada padrão** do `jvcs.exe` como primeira linha.
  O buffer é zerado em seguida.
- A senha nunca vai para a linha de comando (`/password`), para log, para a saída JSON, para a auditoria
  nem para arquivo. `identity` mostra só `hasPassword: true/false`.
- Regras `deny` impedem a IA de ler a chave `JEDIVCS\Identities` do registro e de chamar o console com
  `/password` ou `-password`.
- Limite: a identidade salva pelo cliente 2.5 fica em Base64 no registro do usuário. Qualquer processo
  do mesmo usuário do Windows pode lê-la; as regras dificultam, não impedem. A evolução prevista é o
  Gerenciador de Credenciais do Windows (`doc/pt/common/Credenciais.md`).

### Recomendações

- Para a IA, use uma **identidade com um usuário JEDI VCS de poucos direitos** (leitura geral, escrita só
  nos projetos liberados), em vez de `sysdba`. Configure com `config set identity <nome>`.
- Não reutilize no JEDI VCS a senha do Windows ou do domínio.
- O protocolo do servidor não tem TLS: use só em rede local ou VPN.

## Regras do Claude Code (allow / ask / deny)

Instaladas por `instalar-no-projeto.ps1` no `.claude\settings.json` do projeto. Prioridade:
**deny > ask > allow**.

| Tipo | Regras | Efeito |
|---|---|---|
| `allow` | o wrapper pelo caminho exato (`powershell -NoProfile -ExecutionPolicy Bypass -File "<tools/ai>/jvcs-ai.ps1" *`) | consultas e operações sem pedir aprovação; o próprio wrapper aplica os modos |
| `allow` (opcional) | `edit-preserve.ps1` (com `-AllowEditPreserve`) | edições sem aprovação |
| `ask` | `*-Confirmed*`, `*-Discard*`, `*-AllowEncodingChange*` (PowerShell e Bash) | você aprova cada uso |
| `ask` (template 1.4.0) | `*-Identity*`; `Copy-Item`/`Move-Item`/`Remove-Item` com `-Force`; `cp -f`, `mv -f`, `rm -f`, `rm -rf` | você aprova a troca de identidade e a cópia/remoção forçada (que poderia recriar um módulo sem checkout) |
| `ask` (administração de módulos) | `*rm-module*-Apply*`, `*rename-module*-Apply*`, `*cleanup*-Apply*` e as chamadas diretas ao console `*removemodule*`, `*renamemodule*` (PowerShell e Bash) | você aprova cada remoção/renomeação, mesmo se a detecção de IA falhar; além disso o `-Apply` exige `moduleAdmin=on` (ou `archive`) no `config.ini` |
| `ask` (administração de projetos) | `*rm-project*-Apply*`, `*restore-project*-Apply*`, `*rename-project*-Apply*` e as chamadas diretas `*removeproject*`, `*restoreproject*`, `*renameproject*` (PowerShell e Bash) | idem; o `-Apply` exige `projectAdmin=on` no `config.ini` |
| `deny` | leitura de `JEDIVCS*Identities` e de `*Software*JEDI*`, `reg export`; `jvcs* /password`/`-password`; `config set`; `*JVCS*config.ini*`; o instalador; `edit-preserve ... -NoCheckout`; `CLAUDECODE`/`AI_AGENT`; `settings.local.json`; `disableAllHooks`; `attrib`, `IsReadOnly`, `SetAttributes`, `Attributes =`, `chmod`; `Edit` em `.claude/settings*.json`, `.claude/skills/jvcs/**`, `%APPDATA%\JEDI\JVCS\**`, `%LOCALAPPDATA%\JEDI\JVCS\**` e `tools\ai\**` | a IA não muda modo, não lê a senha, não desliga hooks nem tira o somente leitura |

As regras `allow` só valem depois de você aceitar a **confiança da pasta**; `deny` e `ask` valem sempre.
As regras `ask` de administração vêm no modelo de settings 1.3.0: projetos instalados antes precisam rodar
o `instalar-no-projeto.ps1` de novo para recebê-las.

`hide -Apply` e `comment -Apply` não têm regra `ask` própria: como todo `-Apply` de administração, pela IA
eles exigem `-Confirmed`, e a regra `*-Confirmed*` pergunta. O mesmo vale para `sync -Apply -Force`,
`revert -Checkin`/`-Force`/`-AllowEncodingChange` e `-SkipBuild`, que exigem `-Confirmed` em qualquer modo.

## Chaves do config.ini que liberam recursos de risco

Ficam em `%APPDATA%\JEDI\JVCS\config.ini`, seção `[ai]`. Só **você** muda, no seu terminal
(`jvcs-ai.ps1 config set <chave> <valor>`): o `config set` é recusado à IA (código 10) e as regras `deny`
protegem o arquivo. Valor inválido no arquivo vale como o padrão (desligado).

| Chave | Valores (padrão) | O que libera |
|---|---|---|
| `moduleAdmin` | `off` \| `on` \| `archive` (`off`) | `on`: o `-Apply` de `rm-module` (tirar do projeto), `rename-module`, `hide`, `comment` e `cleanup`; `archive`: também `-Archive` (apagar módulo e revisões do arquivo, irreversível, com backup antes) |
| `projectAdmin` | `off` \| `on` (`off`) | o `-Apply` de `rm-project`, `restore-project` e `rename-project` (com registro antes de alterar). Pela IA, `checkin=manual` continua bloqueando |
| `buildCheck` | `off` \| `warn` \| `block` (`off`) | compilar antes de cada `checkin` (e do `revert -Checkin`): `warn` só avisa; `block` recusa o check-in (7 `buildFailed`) se a compilação falhar |
| `buildCommand` | caminho absoluto de um `.bat`/`.cmd`/`.ps1` seu, ou `none` | o **único** comando que o wrapper roda para compilar. Ao registrar, o SHA-256 do script vai para `buildCommandSha256`; se o arquivo mudar depois (inclusive pela IA), a compilação é recusada (12) até você registrar de novo. Nunca roda um `.dproj` vindo do servidor |
| `buildConfig`, `buildPlatform`, `buildTimeoutSec` | `Debug`, `Win32`/`Win64`, 30 a 7200 s (600) | parâmetros passados ao script |

Mesmo com a chave ligada, cada `-Apply` de administração feito pela IA exige `-Confirmed` (você aprova). As
chaves são defesa em profundidade: o servidor só exige direito de escrita no projeto (Archive Admin para
remover/restaurar projeto), e o standalone e o console continuam podendo fazer o mesmo sem elas. Por isso a
identidade da IA **não** deve ser Archive Admin. Guarde o script de compilação fora das pastas de projeto
(por exemplo em `%APPDATA%\JEDI\JVCS\`, que as regras protegem).

## Hooks

| Hook | Quando | O que faz |
|---|---|---|
| `PreToolUse` (`hooks\pretooluse.ps1`) | antes de `Edit`/`MultiEdit`/`Write` | nega edição que estragaria a codificação; faz ou exige o checkout conforme o modo; nega quando o arquivo está somente leitura e o checkout não resolve. Falha fechada: erro ou timeout bloqueiam a ferramenta (`onFailure: block`) |
| `Stop` (`hooks\stop.ps1`) | fim de cada resposta | lembra os módulos que a sessão deixou em checkout (com ou sem alteração). Só avisa; nunca desfaz nada |

O hook só vê as ferramentas de edição. Gravação por comando de shell não passa por ele: a barreira
prática é o atributo **somente leitura** que o JEDI VCS mantém em arquivo sem checkout, mais as regras
`deny` contra tirá-lo.

## Preservação de codificação

O compilador Delphi lê fonte sem BOM como ANSI. Um acento regravado em UTF-8 sem BOM vira lixo sem erro
de compilação. Por isso:

1. o hook nega `Edit`/`Write` em arquivo ANSI, UTF-16 ou binário, e em ASCII que receberia acento;
2. o `edit-preserve.ps1` grava na codificação e nas quebras de linha do arquivo, e recusa caractere que
   a codificação não representa;
3. o `checkin` compara com a base e recusa BOM que some ou aparece, ANSI que virou UTF-8, troca de
   CRLF/LF/CR e U+FFFD novo (`encodingChanged`, código 7).

Comportamento conferido no Claude Code 2.1.295: o `Edit` não recusa arquivo ANSI (troca os acentos de
linhas **não editadas** por U+FFFD); o `Write` grava UTF-8 sem BOM e LF.

## Integridade das operações

- **Nada de lock órfão:** checkout com erro ou timeout é conferido no servidor e desfeito.
- **Nada de perder alteração local:** o checkout recusa (8) quando o local difere do servidor;
  `-Force` e `-Discard` fazem backup em `%LOCALAPPDATA%\JEDI\JVCS\backup`, assim como `sync -Apply` (de todo
  arquivo substituído), `revert` e a administração (histórico, comentários e revisões antes de apagar).
- **Prévia antes de mudar:** `sync`, `rm-module`, `rename-module`, `hide`, `comment`, `cleanup`, `rm-project`,
  `restore-project` e `rename-project` só mostram o que fariam; nada muda sem `-Apply`.
- **Prova do caminho:** o console lê e grava no caminho registrado no servidor. Antes de mudar o
  servidor, o wrapper prova que o arquivo local é aquele (sonda de data); senão, 5 `pathMismatch`.
- **Mutex por identidade:** chamadas paralelas (IA, hook, você) são serializadas.
- **Timeout com kill** do `jvcs.exe` (`timeoutSec`); o hook usa 45 s por execução.
- **Injeção:** linhas com caractere de controle, comentários com aspas e nomes de projeto com CR/LF ou
  aspas são recusados (2).
- **Conteúdo de arquivo é dado, não instrução:** a skill orienta a IA a não obedecer textos dentro dos fontes.

## Auditoria

`%LOCALAPPDATA%\JEDI\JVCS\ai-audit.log`: uma linha JSON por comando (exceto `help`, `identity` e
`config get/list`). Registra data UTC, usuário do Windows, identidade, usuário JEDI VCS, servidor,
comando, argumentos, projeto, módulos e versões, código de saída, se era contexto de agente,
`AI_AGENT`, `CLAUDE_CODE_SESSION_ID`, se houve `-Confirmed`, os modos e o comentário. **Sem senha.**
Os comandos novos acrescentam o que é preciso para reconstituir a operação: o caminho do backup ou do
registro (`backup`, `record`) na administração, o comentário antigo no `comment`, `build` e `buildCheck` no
check-in, `target`/`dest` no `sync`, `keep` no Put.

```powershell
Get-Content "$env:LOCALAPPDATA\JEDI\JVCS\ai-audit.log" -Tail 20 | ForEach-Object { $_ | ConvertFrom-Json } |
  Format-Table ts, command, exitCode, agent, confirmed, comment
```

No servidor, os check-ins da IA ficam identificáveis pelo prefixo `[IA]` no comentário.

## Riscos e limites

- **Regras por texto não são fronteira de segurança.** Não pegam formas alternativas: caminho montado
  em variável, `cmd /c`, .NET, um script gravado pela IA que chame o wrapper com `-Confirmed`.
- **Mesmo usuário do Windows:** a IA pode ler o registro e gravar o `config.ini` ou o settings por
  caminhos que as regras não cobrem.
- **Identidade compartilhada:** com a sua identidade, um checkout seu na IDE conta como "meu" para a
  IA, e o histórico do servidor só distingue pelo `[IA]`.
- **Modo `confirm`** depende das regras `ask` do agente; outros agentes não têm essas regras
  (ver [07 - Outros agentes](07-Outros-Agentes.md)).
- **Não rode o agente como administrador.**

Para reduzir o risco: identidade de poucos direitos, `checkin=confirm`, revisão do diff, auditoria.
