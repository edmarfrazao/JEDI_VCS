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
| `checkin <arq...> -Comment "texto" [-AllowEncodingChange]` | check-in; sem mudança desfaz o checkout | sim |
| `undocheckout <arq...> [-Discard]` | desfaz o checkout (só com local igual ao servidor, ou `-Discard`) | sim |
| `config list \| get <chave> \| set <chave> <valor>` | configuração (`set` só por humano) | não |

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

Campos extras conforme o comando: `identity`, `projects`, `config`, `configPath`, `comment`, `warnings`, `raw`.

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
