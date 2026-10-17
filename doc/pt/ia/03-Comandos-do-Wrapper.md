# 03 - Comandos do wrapper

`jvcs-ai.ps1` envolve o console `jvcs.exe` e devolve **JSON numa linha** (ou texto legível com `-Text`).
`edit-preserve.ps1` edita fontes sem mudar a codificação. Os dois ficam em `tools\ai`.

## Forma de chamar

```text
powershell -NoProfile -ExecutionPolicy Bypass -File "<tools/ai>/jvcs-ai.ps1" <comando> [argumentos] [opções]
```

- Para a IA (Claude Code), use **exatamente** essa forma, com barras normais no caminho: é a que a regra
  `allow` instalada reconhece. Outra forma funciona, mas cai no fluxo normal (pede aprovação).
- Um comando por chamada (sem `;`, `&&` ou pipe junto).
- No seu terminal você pode usar `& '<tools\ai>\jvcs-ai.ps1' <comando> ...`.
- Caminhos relativos são resolvidos pela pasta atual do PowerShell.

## Comandos

| Comando | O que faz | Muda o servidor? |
|---|---|---|
| `help` | resumo dos comandos | não |
| `identity [-Test]` | identidade em uso (nome, host, porta, usuário, se tem senha, origem). `-Test` faz login. Nunca mostra a senha | não |
| `projects` | projetos do servidor | não |
| `list [-Project p]` | módulos do projeto: versão, lock e estado local pelo CRC que o console calcula (rápido, aproximado) | não |
| `locks [-All]` | módulos em checkout: os meus, ou de todos | não |
| `status <arq...>` / `status [-Project p]` | estado **exato**: baixa a última revisão numa pasta temporária e compara bytes | não |
| `checkout <arq...> [-Force]` | checkout seguro | sim |
| `ensure-checkout <arq> [-CheckOnly]` | para hooks: idempotente. `-CheckOnly` só informa | sim (sem `-CheckOnly`) |
| `checkin <arq...> -Comment "texto" [-AllowEncodingChange] [-SkipBuild]` | check-in; sem mudança desfaz o checkout; com `buildCheck` compila antes | sim |
| `checkin <arq...> -Comment "texto" -Keep` | **Put**: revisão nova e o checkout continua (console 2026) | sim |
| `undocheckout <arq...> [-Discard]` | desfaz o checkout (só com local igual ao servidor, ou `-Discard`) | sim |
| `diff <arq> [-Rev x.y]` | diff do arquivo local contra a revisão do servidor (padrão: a última) | não |
| `diff <arq> -Rev x.y -Rev2 y.z` | diff entre duas revisões do servidor | não |
| `history <arq> [-Max n]` | revisões com data, usuário, família, comentário e labels (console 2026) | não |
| `show <arq> -Rev x.y [-Dest pasta]` | grava a revisão numa pasta de consulta fora do projeto | não |
| `changes [-Project p] [-Since d] [-User u] [-Max n]` | check-ins do projeto desde a data (padrão `7d`), com a hora real (console 2026) | não |
| `search <padrão> [-Project p] [-Max n]` | módulos por nome/máscara em todos os projetos (console 2026) | não |
| `search "<texto>" -InComments [-Project p] [-Max n] [-MaxModules n]` | texto nos comentários das revisões do projeto (console 2026) | não |
| `blame <arq> [-Lines a-b] [-Max n] [-Rev x.y] [-IgnoreWhitespace]` | revisão, usuário, data e comentário de cada linha (console 2026) | não |
| `sync [-Project p] [-Apply [-Force]]` | prévia / atualiza a cópia local pelas últimas revisões, com backup | não (só a pasta local) |
| `sync -Label <nome> \| -Date <data> [-Project p] [-Apply [-Force]]` | prévia / volta a cópia local ao label ou ao estado da data, com backup (console 2026) | não (só a pasta local) |
| `sync -Dest <pasta> [-Label l \| -Date d] [-Project p] [-Apply]` | grava o estado numa pasta nova ou vazia, como cópia de leitura (console 2026) | não |
| `revert <arq> -Rev x.y [-Force] [-AllowEncodingChange]` | grava a revisão (família) na cópia local, em checkout, com backup | sim (checkout) |
| `revert <arq> -Rev x.y -Checkin -Comment "motivo" [-SkipBuild]` | e publica `[IA] revert para x.y: motivo` (pela IA sempre com `-Confirmed`) | sim |
| `labels [-Project p]` / `labels -All` / `labels <arq>` / `labels -Label <nome>\|#id` | labels do projeto, do servidor, das revisões do módulo, ou a revisão de cada módulo num label (console 2026) | não |
| `label <nome> [-Project p]` | rotula a última revisão do servidor de cada módulo (console 2026) | sim |
| `shared <arq>` / `shared [-Project p]` | compartilhamento do módulo / módulos compartilhados do projeto (console 2026) | não |
| `todo [-Project p \| -All] [-User login\|me\|all] [-Category c] [-Priority 1-9] [-Due aaaa-mm-dd] [-IncludeDone]` | itens de ToDo (console 2026) | não |
| `todo-add "texto" [...]` / `todo-done <id> [-Reopen]` | cria / conclui ou reabre item de ToDo (console 2026) | sim |
| `milestones [-Project p \| -All]` | milestones definidos e atingidos (console 2026) | não |
| `bugs [<arq>] \| -Project p \| -All \| -Bug n \| -Summary [-OpenOnly]` | bugs do módulo/projeto/servidor (console 2026) | não |
| `bug-add -Title "..." [...]` / `bug-update -Bug n [...]` / `bug-link -Bug n <arq...> \| -Project p [-Remove \| -Done \| -Reopen]` | cria e liga / altera / liga, desliga ou marca bug (console 2026) | sim |
| `addproject <proj.dpr> [-Comment "descrição"]` | cria o projeto no servidor (console 2026) | sim |
| `add <arq...> -Comment "texto"` | cadastra e faz o 1º check-in 0.1 com a família (console 2026) | sim |
| `modules -Project p [-Deserted]` | todos os módulos ligados ao projeto, com flags; `-Deserted`: abandonados (console 2026) | não |
| `rm-module`, `rename-module`, `hide`, `comment`, `cleanup` | administração de módulos: prévia; `-Apply` exige `moduleAdmin` (console 2026) | só com `-Apply` |
| `rm-project`, `restore-project`, `rename-project` | administração de projetos: prévia; `-Apply` exige `projectAdmin=on` (console 2026) | só com `-Apply` |
| `config list \| get <chave> \| set <chave> <valor>` | configuração (`set` só por humano) | não |

Os modos valem para o que muda alguma coisa: `label`, `todo-add`/`todo-done`, `bug-*`, `addproject`, `add` e
`checkin -Keep` seguem o modo de **check-in** (a administração de projetos também: `checkin=manual` → 10);
`sync -Apply` (todas as formas) e `revert` seguem o modo de **checkout** (o `revert -Checkin`, os dois). A
administração depende ainda da chave `moduleAdmin`/`projectAdmin`, que só você liga. Pela IA, exigem `-Confirmed` em
**qualquer** modo: `checkout -Force`, `checkin -AllowEncodingChange`, `undocheckout -Discard`,
`sync -Apply -Force`, `revert -Checkin`/`-Force`/`-AllowEncodingChange`, `-SkipBuild` e todo `-Apply` de
administração. Detalhes de cada comando novo: `tools/ai/LEIAME.md`, seções 11 a 17.

### Opções

| Opção | Efeito |
|---|---|
| `-Project <nome.dpr\|caminho>` | projeto explícito (obrigatório se a pasta tiver mais de um `.dpr`/`.dpk` com nome próprio) |
| `-Identity <nome>` | outra identidade salva |
| `-Text` | saída legível em vez de JSON |
| `-Confirmed` | aprovação humana já dada (escreva exatamente assim) |
| `-Agent` | força o contexto de agente (prefixo `[IA]`, modos) |
| `-TimeoutSec <n>` | limite por execução do `jvcs.exe` |
| `-LockWaitSec <n>` | espera máxima pelo mutex da identidade |
| `-Raw` | inclui a saída bruta do console (não contém senha) |
| `-Rev`, `-Rev2`, `-Max`, `-Since`, `-User`, `-Date`, `-Label`, `-Dest`, `-Apply`, `-Force`, `-Keep`, `-All` | revisões, datas, sync e check-in |
| `-InComments`, `-MaxModules` | busca nos comentários |
| `-Priority`, `-Category`, `-Due`, `-IncludeDone`, `-Reopen` | ToDo |
| `-Bug`, `-Title`, `-Severity`, `-Status`, `-Keywords`, `-ReportedBy`, `-Description`, `-DescriptionFile`, `-Workaround`, `-WorkaroundFile`, `-Summary`, `-OpenOnly`, `-Remove`, `-Done` | bugs |
| `-Lines`, `-IgnoreWhitespace`, `-Checkin`, `-SkipBuild` | blame, revert e compilação |
| `-Relink`, `-RenameFiles`, `-Archive`, `-Unhide`, `-OutComment`, `-Deserted` | administração |

Escreva as opções **por extenso**: `-Pr`, `-De` e `-Ti` são ambíguas.

**Contexto de agente** = `-Agent`, variável `CLAUDECODE=1`, variável `AI_AGENT` não vazia, **ou entrada
padrão redirecionada** (as ferramentas de shell das IAs rodam assim; um humano no terminal, não). Nesse
contexto valem os modos, o `-Confirmed` e o prefixo `[IA]`.

### Como o projeto e o módulo são encontrados

- **Projeto:** o `.dpr`/`.dpk` mais próximo na pasta do arquivo ou acima, ou `-Project`. Candidatos que
  não existem no servidor são ignorados. Sem arquivo (`status`, `list`), vale o único `.dpr`/`.dpk` da
  pasta atual; `Project1`/`Package1` são ignorados na escolha automática.
- **Módulo:** pelo nome **e** pelo caminho registrados no servidor. `.dfm`/`.fmx` resolvem para o
  módulo da família (`.pas`).

## Detalhes por comando

### `status`

```powershell
jvcs-ai.ps1 status uPrincipal.pas
jvcs-ai.ps1 status -Project Exemplo01.dpr -Text
```

`localState`: `clean` (igual ao servidor), `modified`, `missing`, `notVersioned` ou `unknown`.
`pathCheck`: `exact` (caminho inteiro visível), `prefix` (o console mostra o caminho truncado; não
provado) ou `verified` (provado por checkout/check-in).

### `checkout`

1. Recusa se o lock é de outro usuário (6).
2. Baixa a base e compara bytes. Local diferente → **8, sem pedir lock**. Conteúdo igual com data
   diferente → alinha a data durante o checkout e restaura depois.
3. Prova que o arquivo local é o mesmo registrado no servidor (se não for: 5 `pathMismatch`, nada é feito).
4. Roda o checkout e confere em `listlocks`/`listproject`. Qualquer erro com o lock já pego → desfaz o
   lock (7 `failedCompensated`; 9 se a compensação falhar). Timeout → confere e compensa (9).

`-Force` trava mantendo a alteração local: backup em `%LOCALAPPDATA%\JEDI\JVCS\backup`, troca pela base,
checkout, devolve o seu conteúdo. Pela IA, só com `-Confirmed`.

### `ensure-checkout`

Usado pelo hook. Não versionado → ok (nada a fazer); já é meu → ok; de outro → 6; local alterado → 8.
`-CheckOnly` só informa (`state=needsCheckout`).

### `checkin`

1. Exige lock meu (7 sem checkout; 6 de outro).
2. Sem mudança em bytes → desfaz o checkout, código **3** (`unchangedUndone`).
3. Valida a codificação contra a base. Recusa (7 `encodingChanged`): BOM que some ou aparece, UTF-16
   trocado, ANSI/ASCII que virou UTF-8 sem BOM, UTF-8 que virou ANSI, troca de quebras de linha,
   caractere U+FFFD novo. `-AllowEncodingChange` aceita (pela IA, só com `-Confirmed`).
4. Comentário: **uma linha, sem aspas duplas, em CP1252**, até 2000 caracteres. Em contexto de agente
   recebe o prefixo `[IA] `.
5. Prova o caminho, faz o check-in e confere a versão nova e o lock liberado (versão igual = recusado, 7).

### `undocheckout`

- Sem `-Discard`: só quando o local é igual à base; senão 8 e o lock fica.
- `-Discard` (pela IA, só com `-Confirmed`): backup, desfaz e restaura a base como somente leitura.

### `config`

```powershell
jvcs-ai.ps1 config list -Text
jvcs-ai.ps1 config get checkout
jvcs-ai.ps1 config set checkin confirm     # só no seu terminal
```

## Saída JSON

Uma linha, ASCII (acentos como `\uXXXX`). Campos fixos:

| Campo | Tipo | Conteúdo |
|---|---|---|
| `ok` | bool | verdadeiro para os códigos 0 e 3 |
| `command` | string | comando executado |
| `project` | string/null | projeto usado |
| `modules` | lista | um item por módulo/arquivo |
| `message` | string | resumo legível |
| `exitCode` | int | o mesmo código de saída do processo |

Campos extras conforme o comando: `identity`, `projects`, `config`, `configPath`, `comment`, `warnings`, `raw`
e, nos comandos novos, `changes`, `labels`/`label`, `todos`/`todo`, `milestones`, `bugs`/`bug`, `backup`,
`build`, `target`, `dest`, `keep`, `next` (comando para aplicar uma prévia), entre outros (ver
`skills/pt/jedi-vcs/references/comandos.md` e o `tools/ai/LEIAME.md`).

Cada item de `modules`: `id`, `name`, `path`, `version`, `lockedBy`, `localState`, `state`, `exitCode`,
`message`, `pathCheck` e `files[]` (`name`, `localState`, `readOnly`).

Exemplos (`identity` e `status` reais de 13/10/2026; `checkin` resumido do teste de 12/10/2026;
caminhos, servidor e usuário trocados por marcadores):

```json
{"ok":true,"command":"identity","project":null,"modules":[],"message":"identidade 'DEFAULT': usuario@servidor:2106","exitCode":0,"identity":{"name":"DEFAULT","host":"servidor","port":"2106","user":"usuario","hasPassword":true,"source":"LastUsedID=0"}}
```

```json
{"ok":true,"command":"status","project":"exemplo01.dpr","modules":[{"id":4,"name":"uprincipal.pas","path":"C:\\...\\Ex1\\uPrincipal.pas","version":"0.14","lockedBy":"","localState":"clean","state":"ok","exitCode":0,"message":"","pathCheck":"prefix","files":[{"name":"uPrincipal.dfm","localState":"clean","readOnly":true},{"name":"uPrincipal.pas","localState":"clean","readOnly":true}]}],"message":"1 arquivo(s) verificado(s)","exitCode":0}
```

```json
{"ok":true,"command":"checkin","project":"exemplo01.dpr","modules":[{"id":4,"name":"uprincipal.pas","version":"0.4","lockedBy":"","localState":"clean","state":"checkedIn","exitCode":0,"message":"check-in ok: 0.3 -> 0.4","pathCheck":"verified"}],"message":"check-in ok: 0.3 -> 0.4","exitCode":0,"comment":"[IA] Corrige o texto do rodapé"}
```

### `modules[].state`

| Grupo | Estados |
|---|---|
| sucesso | `ok`, `checkedOut`, `checkedOutKeptLocal`, `alreadyMine`, `checkedIn`, `unchangedUndone`, `undone`, `discarded`, `notVersioned` |
| informativo | `needsCheckout`, `pathTruncated` |
| impedimento | `lockedByOther`, `localModified`, `needsConfirmation`, `pathMismatch`, `notCheckedOut`, `localMissing`, `encodingChanged`, `refused` |
| falha | `releasedButDirty`, `failedCompensated`, `failed`, `timeout`, `error` |
| Put, revert e compilação | `checkedInKept`, `unchangedKept`, `reverted`, `revertedCheckedIn`, `revertedNotCheckedIn`, `alreadyAtRevision`, `memberNotInRevision`, `encodingConflict`, `checkoutFailed`, `readOnly`, `buildFailed`, `lockLost`, `changedDuringBuild` |
| labels, sync e ToDo/bugs | `labeled`, `notInLabel`, `hidden`, `keptOld`, `notLabeled`, `mismatch`, `shared`, `notInTarget`, `export`, `exported`, `noPath`, `badPath`, `created`, `done`, `reopened`, `linked`, `alreadyLinked`, `unlinked`, `notLinked`, `open` |
| administração de módulos | `listed`, `candidate`, `notCandidate`, `preview`, `locked`, `backupFailed`, `removedFromProject`, `removedFromArchive`, `archiveRefused`, `linkRemoved`, `renamed`, `conflict`, `unhidden`, `changed`, `unchanged`, `refused` |
| administração de projetos | `preview`, `removed`, `restored`, `relinked`, `renamed`, `alreadyDeleted`, `notDeleted`, `nameInUse`, `noRecord`, `partial` |

A tabela traz os estados principais; os de cada comando novo estão no `tools/ai/LEIAME.md` (seções 13 a 17).

## Códigos de saída (estáveis)

| Código | Significado | O que fazer |
|---|---|---|
| 0 | ok | seguir |
| 2 | uso/parâmetro inválido (comentário com aspas, texto fora do CP1252, falta `-Project`) | corrigir a chamada |
| 3 | nada a fazer (check-in sem mudança → checkout desfeito) | nada; é sucesso |
| 4 | credencial: identidade ausente/incompleta, sem senha salva, login recusado | o usuário salva a identidade na GUI |
| 5 | não encontrado: projeto/módulo, não versionado, ambiguidade, caminho do servidor diferente (`pathMismatch`) | conferir pasta e `-Project`; não insistir |
| 6 | travado por outro usuário | não editar; avisar |
| 7 | pré-condição: sem checkout, codificação mudou, servidor recusou, checkout compensado | ler `message`/`state` |
| 8 | conflito local: arquivo local difere do servidor (nada travado nem liberado) | perguntar ao usuário |
| 9 | servidor/console: conexão, timeout, saída inesperada | repetir depois; avisar se persistir |
| 10 | aprovação necessária (`-Confirmed`), modo manual, `config set` por agente | mostrar ao usuário e pedir aprovação, ou deixar com ele |
| 11 | lote parcial (resultados diferentes por arquivo) | ver cada item de `modules` |
| 12 | ambiente: `jvcs.exe` ausente ou não reconhecido, mutex ocupado | conferir instalação/`jvcsExe`; esperar |

O `jvcs.exe` original devolve 0 mesmo com erro; o wrapper ignora o código dele e interpreta a saída.

## edit-preserve.ps1

```powershell
edit-preserve.ps1 -Path X.pas -Old "texto atual" -New "texto novo" [-All] [-Regex]
edit-preserve.ps1 -Path X.pas -OldFile old.txt -NewFile new.txt        # textos em arquivos UTF-8
edit-preserve.ps1 -Path X.pas -ContentFile conteudo.txt                 # regrava tudo na codificação do alvo
edit-preserve.ps1 -Path Novo.pas -ContentFile c.txt -NewFileEncoding Ansi|Utf8Bom|Utf8|Utf16
edit-preserve.ps1 -Path X.pas -Old "a" -New "b" -DryRun                 # só simula
```

- Detecta `utf8bom`, `utf16le`/`utf16be`, `ascii`, `utf8`, `ansi` (1252); recusa binário.
- Converte as quebras de linha de `-Old`/`-New`/`-ContentFile` para as do arquivo.
- Alvo ANSI: caractere fora do 1252 → 6. Alvo ASCII que recebe acento → grava em 1252 (`asciiAs=ansi`).
- Nunca tira o somente leitura. Em fonte de projeto JEDI VCS aplica o modo de checkout
  (`auto` → `ensure-checkout`; `confirm`/`manual` → exige checkout prévio, código 10).
- Pela IA só grava `.pas .dfm .fmx .dpr .dpk .dproj .inc .rc .groupproj .bpg .txt .sql .iss`, nunca em
  `tools\ai`, `%APPDATA%\JEDI`, `%LOCALAPPDATA%\JEDI`, `.claude` ou `.git`.

Saída: `{ok, path, encoding, eol, replacements, bytesBefore, bytesAfter, checkout, message, exitCode}`.

| Código | Significado |
|---|---|
| 0 | ok |
| 2 | uso |
| 3 | nada mudou |
| 4 | `-Old` não encontrado |
| 5 | `-Old` não é único (use `-All` ou um trecho maior) |
| 6 | caractere não representável na codificação do arquivo |
| 7 | E/S: arquivo inexistente ou somente leitura (sem checkout) |
| 8 | arquivo não suportado (binário, não faz ida e volta) |
| 9 | JEDI VCS: o checkout falhou |
| 10 | checkout exige confirmação, modo manual, ou caminho/opção proibidos para a IA |
