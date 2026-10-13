# tools\ai — JEDI VCS para a IA (Claude Code)

Versão **1.2.0** (13/10/2026). Camada 0 do ADR-001 (`doc\pt\common\ADR-001-CLI-IA-e-Plugin-Multi-Delphi.md`):
a IA faz checkout e check-in das units Delphi usando o console **original** `jvcs.exe` 2.5.0.1030
(Delphi 2007), sempre por trás de um wrapper PowerShell que torna o console seguro para automação.

| Arquivo | Para quê |
|---|---|
| `jvcs-ai.ps1` | Wrapper do `jvcs.exe`: identidade salva, senha pelo stdin, mutex, timeout, prova do caminho do servidor, pré-checagens, JSON |
| `edit-preserve.ps1` | Edição de fonte preservando codificação (ANSI 1252, UTF-8 com/sem BOM, UTF-16) e quebras de linha (CRLF/LF/CR) |
| `hooks\pretooluse.ps1` | Hook `PreToolUse` do Claude Code para `Edit\|MultiEdit\|Write` em fontes Delphi (codificação, checkout, somente leitura) |
| `hooks\stop.ps1` | Hook `Stop`: lembra os checkouts da sessão que ficaram presos (só avisa, nunca bloqueia) |
| `lib\jvcs-ai-common.ps1` | Funções comuns (JSON, config.ini, codificação, contexto de agente, aprovação, auditoria) |
| `claude\settings.template.json` | Modelo dos hooks e das regras `allow`/`ask`/`deny` |
| `claude\skills\jvcs\SKILL.md` | Skill que ensina a IA o fluxo (por projeto; a variante global distribuível é `skills\pt\jedi-vcs`, ou `skills\en\jedi-vcs` em inglês, na raiz do repositório) |
| `instalar-no-projeto.ps1` | Instala hooks, regras e skill num projeto e (se pedido) grava o modo |

Guia de uso (instalação, modos, fluxo, segurança, problemas): `doc\pt\ia\README.md`.

Requisitos: Windows PowerShell 5.1, `C:\Program Files (x86)\JEDI\JVCS\jvcs.exe` 2.5.0.1030 com
`FVCSCrypt.dll`, uma **identidade salva com senha** (GUI: Server Login → "Store Password with identity"),
Claude Code **2.1.295+** (por causa de `"onFailure": "block"` no hook).

Os `.ps1` são **UTF-8 com BOM e CRLF**. Sem BOM o PowerShell 5.1 lê o arquivo na code page ANSI e
estraga as mensagens acentuadas. Ao editar, mantenha o BOM (o `Edit` do Claude Code mantém; o `Write` não).

---

## 1. Instalação num projeto

No **seu** terminal (a IA tem regra `deny` para este script):

```powershell
$i = 'D:\Delphi\JediVCS\v2026\tools\ai\instalar-no-projeto.ps1'
& $i -ProjectDir C:\caminho\do\projeto                      # só hooks/regras/skill; não mexe no modo
& $i -ProjectDir C:\caminho\do\projeto -Mode confirm        # e grava checkout=confirm, checkin=confirm
& $i -ProjectDir C:\caminho\do\projeto -Mode auto -WhatIf   # simula e mostra o settings resultante
& $i -ProjectDir C:\caminho\do\projeto -Scope local         # grava em .claude\settings.local.json
```

| Opção | Efeito |
|---|---|
| `-Mode auto\|confirm\|manual` | grava `checkout` e `checkin` no `config.ini`. **Sem `-Mode` o modo não é alterado** (sem nada gravado, vale o padrão `confirm`) |
| `-CheckoutMode` / `-CheckinMode` | sobrepõem `-Mode` para cada operação |
| `-Scope project` (padrão) | `<projeto>\.claude\settings.json`, o arquivo compartilhado do projeto |
| `-Scope local` | `<projeto>\.claude\settings.local.json`, só desta máquina. Use quando a pasta `.claude` for versionada: o settings leva caminhos absolutos desta máquina. O instalador avisa quando acha `.git`/`.svn` |
| `-AllowEditPreserve` | acrescenta `allow` para o `edit-preserve.ps1` (as edições por ele deixam de pedir aprovação, como o modo `acceptEdits` faz com o `Edit`). Sem a opção, cada edição pelo `edit-preserve` pede aprovação no modo Manual, como o `Edit` |
| `-WhatIf` | não grava nada |

O instalador:

1. mescla o modelo no settings **sem apagar o que existe**. Remove só o que ele gerencia: as regras
   listadas em `.claude\jvcs-ai.managed.json` (manifesto gravado a cada instalação), as do modelo atual e
   as da versão 1.0.0; nos hooks, remove só os **itens** dele (`pretooluse.ps1`/`stop.ps1` de `tools\ai`)
   e descarta um grupo só se ele ficar vazio. Guarda `settings*.json.bak-<data>` antes. Se o outro escopo
   tiver itens do instalador, eles são removidos de lá (com backup). Pode rodar de novo (idempotente);
2. copia a skill para `<projeto>\.claude\skills\jvcs\SKILL.md`, com os caminhos absolutos de `tools\ai`;
3. grava o modo no `config.ini` **só** com `-Mode`/`-CheckoutMode`/`-CheckinMode`.

Depois abra o projeto no Claude Code e **aceite a confiança da pasta**: hooks e regras `allow` do
`.claude\settings.json` do projeto só valem depois disso (as `deny`/`ask` valem sempre).

Instalação de teste feita nesta máquina: `%USERPROFILE%\Documents\Embarcadero\Studio\Projects\Ex1`
com `-Mode auto` (decisão do usuário para esta máquina).

---

## 2. Modos (config.ini)

`%APPDATA%\JEDI\JVCS\config.ini` (UTF-8 com BOM; sem segredos):

```ini
; comentário na 1ª linha: o BOM não atrapalha leitores ANSI (GetPrivateProfileString)
[ai]
checkout=confirm      ; auto | confirm | manual   (padrão confirm)
checkin=confirm       ; auto | confirm | manual   (padrão confirm)
commentPrefix=[IA]    ; prefixo dos check-ins feitos em contexto de agente
jvcsExe=C:\Program Files (x86)\JEDI\JVCS\jvcs.exe
timeoutSec=120        ; por execução do jvcs.exe (kill no timeout)
lockWaitSec=120       ; espera máxima pelo mutex da identidade
identity=             ; vazio = LastUsedID; ou o nome de uma identidade salva
asciiAs=ansi          ; arquivo ASCII puro que recebe acento: ansi (1252) | utf8 (sem BOM)
```

Comandos: `jvcs-ai.ps1 config list | get <chave> | set <chave> <valor>`.
**`config set` é recusado em contexto de agente**: o modo é decisão do usuário. O `config.ini` vale para
o usuário do Windows inteiro (todos os projetos).

| Modo | Checkout (hook / edit-preserve / wrapper) | Check-in (wrapper) |
|---|---|---|
| `auto` | o hook roda `ensure-checkout` antes do Edit, sem perguntar; o wrapper faz `checkout` direto | `checkin` direto |
| `confirm` | o hook **nega** e manda rodar `checkout <arq> -Confirmed`; a regra `ask` faz o Claude Code pedir aprovação | exige `-Confirmed` do agente; a regra `ask` pede aprovação |
| `manual` | o hook nega e pede ao humano | recusado ao agente (código 10) |

Sempre exigem `-Confirmed` do agente, **em qualquer modo** (inclusive `auto`):
`undocheckout -Discard`, `checkout -Force` e `checkin -AllowEncodingChange`.

**`-Confirmed`**: o wrapper exige o switch **e** o texto `-Confirmed` exatamente assim (C maiúsculo) na
linha de comando. É esse texto que aciona as regras `ask` `PowerShell(*-Confirmed*)`/`Bash(*-Confirmed*)`;
as regras Bash diferenciam maiúsculas, e abreviação (`-Con`) ou splatting não contêm o texto. As regras
`ask` são genéricas (não dependem do caminho do script), e ficam sempre instaladas: trocar o modo no
`config.ini` não exige reinstalar.

**Regra `allow` do wrapper**: `PowerShell(powershell -NoProfile -ExecutionPolicy Bypass -File "D:/.../jvcs-ai.ps1" *)`
(e as variantes Bash e com barras invertidas). Sem ela, no modo Manual do Claude Code toda chamada ao
wrapper pedia aprovação, e `checkin=auto` não era automático. O `allow` é seguro em qualquer modo porque o
próprio wrapper aplica os modos, e `deny` > `ask` > `allow` (`-Confirmed`/`-Discard`/`config set`
continuam perguntando ou negados). A skill manda usar exatamente essa forma (barras normais); outra forma
cai no fluxo normal (pergunta).

**Desvio da especificação (registrar em `doc\pt\common\Decisoes.md`):** no modo `confirm` o hook **não**
devolve `permissionDecision: "ask"`. O PreToolUse roda antes da aprovação e não consegue agir depois dela;
aprovada a edição, o `Edit` falharia com `EPERM` no arquivo somente leitura (testado). A confirmação passa
para o **comando de checkout** (`-Confirmed` + regra `ask`), que é a ação que muda o servidor, e acontece
**antes** do lock.

**Futuro (cliente portado):** esses valores viram a aba **"IA / Automação"** em *VCS Properties*:
- "Checkout pela IA": Automático / Com confirmação / Manual → `checkout`;
- "Check-in pela IA": idem → `checkin`;
- "Prefixo do comentário" → `commentPrefix`;
- "Identidade usada pela IA" (lista das identidades salvas) → `identity`;
- "Arquivo ASCII que recebe acento" → `asciiAs`;
- avançado: caminho do console, timeouts.

A aba lê e grava o mesmo `config.ini`, com `TMemIniFile` + `TEncoding.UTF8`.

---

## 3. jvcs-ai.ps1

```text
powershell -NoProfile -ExecutionPolicy Bypass -File "D:/Delphi/JediVCS/v2026/tools/ai/jvcs-ai.ps1" <comando> [args] [opções]
```

| Comando | O que faz |
|---|---|
| `identity [-Test]` | Identidade em uso (nome, host, porta, usuário, origem). `-Test` faz login. **Nunca mostra a senha** |
| `projects` | Projetos do servidor (`listprojects`) |
| `list [-Project p]` | Módulos do projeto: versão, lock e estado local pelo **CRC que o console calcula** no caminho do servidor (rápido) |
| `locks [-All]` | Módulos em checkout: meus, ou de todos |
| `status <arq...>` / `status -Project p` | Estado **exato**: baixa a última revisão com `getmodule <id> dest="<pasta nova>"` e compara bytes. `localState` = `clean`, `modified`, `missing`, `notVersioned` ou `unknown` |
| `checkout <arq...> [-Force]` | Checkout seguro (ver abaixo) |
| `ensure-checkout <arq> [-CheckOnly]` | Para hooks, idempotente. Não versionado → ok (no-op); já é meu → ok; de outro → 6; local alterado → 8. `-CheckOnly` só informa (`needsCheckout`) |
| `checkin <arq...> -Comment "texto"` | Check-in (ver abaixo) |
| `undocheckout <arq...> [-Discard]` | Desfaz o checkout só se o local for igual à base; com `-Discard`, faz backup e restaura a base |
| `diff <arq> [-Rev x.y]` | Diff unificado do arquivo local contra a revisão do servidor (padrão: a última), com `getmodule <id> [rev=x.y] dest="<pasta nova>"` e `git diff --no-index` sobre o texto decodificado; diferença de codificação/quebras vai para `warnings`. Só leitura; funciona com o console original |
| `addproject <proj.dpr> [-Comment "descrição"]` | Cria o projeto no servidor (use o nome do `.dpr`, como a IDE). Passa pelo modo `checkin`. **Exige o console 2026** (`config set jvcsExe`), senão código 12 |
| `add <arq...> -Comment "texto"` | Cadastra o arquivo no projeto (com a pasta local) e faz o 1º check-in 0.1, com a família (o `.dfm` de uma unit). Já versionado → 3. Passa pelo modo `checkin`; exige o console 2026 |
| `config list\|get\|set` | Configuração |

Opções: `-Project <nome.dpr\|caminho>`, `-Identity <nome>`, `-Text` (saída legível), `-Agent` (força
contexto de agente), `-Confirmed`, `-AllowEncodingChange`, `-TimeoutSec <n>` (por execução do `jvcs.exe`),
`-LockWaitSec <n>` (espera pelo mutex), `-Raw` (inclui a saída bruta do console; não contém senha).

**Contexto de agente** (prefixo `[IA]`, modos, `-Confirmed`): `-Agent`, `CLAUDECODE=1`, `AI_AGENT`, **ou
entrada padrão redirecionada**. A última cobre a IA que apagou as variáveis: as ferramentas de shell do
Claude Code rodam com stdin redirecionado; um humano no terminal, não. Script de humano com stdin
redirecionado também é tratado como agente.

**Resolução de projeto e módulo:**
- projeto: `.dpr`/`.dpk` na pasta do arquivo ou acima (o mais próximo primeiro), ou `-Project`. Candidatos
  que não existem no servidor são ignorados. Se o arquivo estiver em dois projetos no mesmo nível, o
  resultado é 5 e é preciso informar `-Project`. Nome de projeto com caractere de controle ou aspas → 2;
- módulo: pelo nome **e** pelo caminho na tabela do `listproject`. `.dfm`/`.fmx` resolvem para o módulo da família.

**Caminho truncado (prova do caminho do servidor).** A tabela do console mostra só 47 caracteres do
caminho + "..." (o do Ex1 tem 63), e o console **lê e grava o arquivo no caminho registrado no servidor**
(checkin `jvcs.dpr:871/905-947`, checkout `:1292/:1383`). Pela comparação por prefixo, qualquer cópia do
projeto sob `...\Embarcadero\Stud...` pareceria o módulo. Por isso, antes de `checkout`, `checkin` e
`undocheckout`, o wrapper prova que o arquivo local é o do servidor:
1. pré-checagem com a listagem já feita: `Stamp`=`N/A` (arquivo ausente no caminho do servidor) ou coluna
   `CRC` incoerente com a comparação de bytes contra a base → outro arquivo;
2. sonda: muda a data do arquivo local em ±6 h (o console tolera 10 s, `cTimeConvErr`), roda `listproject`
   e exige que o `Stamp` do membro mude para o valor previsto (`N` ou `O`); a data original volta em seguida.

Se não for o mesmo arquivo: **5 `pathMismatch`, nada é feito**. O campo `pathCheck` dos módulos diz
`exact` (caminho visível inteiro), `prefix` (truncado, não provado: `status`, `list`, `ensure-checkout`
"já é meu") ou `verified` (provado). Custa uma execução a mais do `jvcs.exe` só quando o caminho é truncado.

**checkout:** recusa se o lock é de outro (6). Baixa a base e compara bytes:
- local diferente → **8, sem pedir lock** (`-Force` pela IA exige `-Confirmed`);
- conteúdo igual com data diferente → alinha a data à da base durante o checkout (o console decide
  "sujo" por data OU CRC; sujo faz o console travar e depois perguntar, e com stdin redirecionado a
  pergunta vira `EOSError`) e **restaura a data original** depois (o `Edit` não acusa "modificado desde a leitura").

Em seguida roda `checkout <id>` e confere em `listlocks`/`listproject`. Se o console relatar **qualquer**
erro com o módulo já travado por mim (`EOSError`, `EFCreateError` com o arquivo aberto pela IDE, ...), faz
`undocheckout` de compensação (7 `failedCompensated`; 9 se a compensação falhar). Em **timeout**, confere o
servidor e compensa o lock que tiver ficado (9 `timeout`). Checkout feito em contexto de agente é anotado
em `%LOCALAPPDATA%\JEDI\JVCS\sessoes\<sessão>.txt` para o hook Stop.

`-Force` trava **mantendo** a alteração local:
1. backup em `%LOCALAPPDATA%\JEDI\JVCS\backup`;
2. troca o local pela base (cada arquivo entra na lista de restauração assim que o backup dele existe);
3. faz o checkout pelo caminho limpo;
4. devolve o conteúdo do usuário (também se algo falhar no meio).

**checkin:**
1. exige lock meu (7 sem checkout; 6 de outro);
2. sem mudança em bytes → `undocheckout` (D7), código **3**;
3. valida a codificação de cada membro alterado contra a base. Recusa (7 `encodingChanged`):
   - BOM que some ou aparece;
   - UTF-16 trocado;
   - ANSI/ASCII que virou UTF-8 sem BOM;
   - UTF-8 que virou ANSI;
   - CRLF→LF/CR, LF→CRLF/CR, CR→CRLF/LF;
   - U+FFFD novo.

   `-AllowEncodingChange` aceita a mudança (pela IA, só com `-Confirmed`);
4. comentário: uma linha, sem `"`, CP1252, até 2000 caracteres. Em contexto de agente recebe o prefixo `[IA] `;
5. prova o caminho do servidor (acima);
6. confere a versão nova e o lock liberado no `listproject` (o console 2.5 não mostra a recusa do servidor:
   versão igual = recusado, 7). Se o console disser "not changed" com o local diferente da base, é **9**
   (ele olhou outro arquivo ou houve corrida; o lock continua), não sucesso. Em timeout, confere no
   servidor se a revisão entrou;
7. confere o arquivo local contra a revisão recém-criada.

**undocheckout:**
- sem `-Discard`: só quando o local é igual à base (senão 8, lock mantido); a data é alinhada antes;
- `-Discard` (pela IA, só com `-Confirmed`): backup, `undocheckout <id> noprompt`, depois repõe o somente
  leitura que o console não repõe nesse caminho (filtro `Writeable Files` do registro, só leitura);
- o console libera o lock **antes** de restaurar o arquivo (`jvcs.dpr:2851`): se ele relatar erro mas o
  lock estiver livre e o local igual ao servidor, o resultado é `undone` com aviso; com o local diferente,
  `releasedButDirty` (9).

### Saída JSON (padrão; uma linha, ASCII com `\uXXXX`)

```json
{"ok":true,"command":"checkin","project":"exemplo01.dpr",
 "modules":[{"id":4,"name":"uprincipal.pas","path":"C:\\...\\uPrincipal.pas","version":"0.4","lockedBy":"",
             "localState":"clean","state":"checkedIn","exitCode":0,"message":"check-in ok: 0.3 -> 0.4",
             "pathCheck":"verified",
             "files":[{"name":"uPrincipal.dfm","localState":"clean","readOnly":true},
                      {"name":"uPrincipal.pas","localState":"clean","readOnly":true}]}],
 "message":"check-in ok: 0.3 -> 0.4","exitCode":0,"comment":"[IA] ..."}
```

Campos extras conforme o comando: `identity`, `projects`, `config`, `configPath`, `comment`, `warnings`, `raw`.
`ok` é verdadeiro para 0 e 3.

`modules[].state`:
- `checkedOut`, `checkedOutKeptLocal`, `alreadyMine`, `needsCheckout`, `notVersioned`;
- `lockedByOther`, `localModified`, `needsConfirmation`, `pathMismatch`;
- `checkedIn`, `unchangedUndone`, `refused`, `encodingChanged`, `notCheckedOut`, `localMissing`;
- `undone`, `discarded`, `releasedButDirty`, `failedCompensated`, `failed`, `timeout`, `error`, `ok`, `pathTruncated`.

### Códigos de saída (estáveis)

| Código | Significado |
|---|---|
| 0 | ok |
| 2 | uso/parâmetro inválido (inclui comentário com aspas, texto fora do CP1252, `-Project` com CR/LF/aspas) |
| 3 | nada a fazer (check-in sem mudança → checkout desfeito) |
| 4 | credencial: identidade ausente/incompleta, sem senha salva, login recusado |
| 5 | não encontrado: projeto/módulo, arquivo não versionado, ambiguidade, **caminho do servidor diferente** (`pathMismatch`) |
| 6 | travado por outro usuário |
| 7 | pré-condição: sem checkout, codificação mudou, servidor recusou, compensação de checkout |
| 8 | conflito local: arquivo local difere do servidor (nada foi travado ou liberado) |
| 9 | servidor/console: conexão, timeout, saída inesperada, "not changed" incoerente |
| 10 | aprovação necessária (`-Confirmed`), modo manual, `config set` por agente |
| 11 | lote parcial (resultados diferentes por arquivo) |
| 12 | ambiente: `jvcs.exe` ausente ou não reconhecido, mutex ocupado além de `lockWaitSec` |

O `jvcs.exe` original devolve 0 mesmo com erro dentro de `/input`. Por isso o wrapper ignora o código
dele e interpreta a saída: linhas `[Classe] mensagem`, sintaxe impressa e tabelas de largura fixa (o
`StrAlign` grava um `#0` depois de cada coluna; o wrapper troca por espaço).

---

## 4. edit-preserve.ps1

```powershell
edit-preserve.ps1 -Path X.pas -Old "texto atual" -New "texto novo" [-All] [-Regex]
edit-preserve.ps1 -Path X.pas -OldFile old.txt -NewFile new.txt          # textos em arquivos UTF-8
edit-preserve.ps1 -Path X.pas -ContentFile conteudo.txt                   # regrava tudo na codificação do alvo
edit-preserve.ps1 -Path Novo.pas -ContentFile c.txt -NewFileEncoding Ansi|Utf8Bom|Utf8|Utf16
```

- Detecta: BOM UTF-8 → `utf8bom`; BOM UTF-16 → `utf16le`/`utf16be`; NUL → `binary` (recusa); sem byte
  ≥ 0x80 → `ascii`; UTF-8 estrito válido → `utf8`; senão `ansi` (1252).
- Antes de editar, exige que o arquivo faça ida e volta byte a byte na codificação detectada (código 8 se não fizer).
- `-Old` ausente → 4; mais de uma ocorrência sem `-All` → 5; resultado idêntico → 3.
- As quebras de linha de `-Old`/`-New`/`-ContentFile` são convertidas para as do arquivo (CRLF, LF ou CR isolado).
- Alvo ANSI: caractere fora do 1252 → 6. Alvo ASCII que recebe acento → grava em 1252 (`asciiAs=ansi`),
  porque o compilador Delphi lê fonte sem BOM como ANSI.
- Nunca tira o somente leitura (7). Em arquivo de projeto JEDI VCS aplica o modo de checkout:
  `auto` → `ensure-checkout`; `confirm`/`manual` → exige checkout prévio (10). `-DryRun` simula.
- **Pela IA** (contexto de agente): só grava fontes Delphi (`.pas .dfm .fmx .dpr .dpk .dproj .inc`) e
  `.rc .groupproj .bpg .txt .sql .iss`; nunca em `tools\ai`, `%APPDATA%\JEDI`, `%LOCALAPPDATA%\JEDI`,
  `.claude` ou `.git`; `-NoCheckout` é recusado (10). Assim o script não serve para contornar as regras
  `deny` (por exemplo, regravar o `config.ini`). Para humano, `-NoCheckout` pula a etapa de checkout.

Saída: `{ok, path, encoding, eol, replacements, bytesBefore, bytesAfter, checkout, message, exitCode}`.

---

## 5. Hooks

Formato conferido em code.claude.com/docs/en/hooks (12/10/2026): forma exec `"command": "powershell.exe"`
+ `"args": [...]` (é o exemplo Windows da própria documentação), `timeout` em segundos (padrão 600),
`onFailure: "block"` (2.1.295+; não vale para `Stop`).

### PreToolUse (`hooks\pretooluse.ps1`, matcher `Edit|MultiEdit|Write`, timeout 600, onFailure block)

- Entrada: JSON no stdin com `session_id`, `tool_name` e `tool_input.file_path`, `old_string`,
  `new_string`, `content`, `edits[]`.
- Negar: `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"..."}}`
  com exit 0. O motivo vai para o Claude.
- Seguir: stdout vazio, e o fluxo normal de permissões continua. Depois de um checkout automático, só
  `additionalContext` (para o Claude: reler se o Edit acusar mudança; check-in ou undocheckout ao fim) e
  `systemMessage` (aviso ao usuário).
- Erro interno: exit 2 com o motivo no stderr. É **falha fechada**: bloqueia a ferramenta. Com
  `"onFailure":"block"`, timeout e falha ao iniciar também bloqueiam.
- Chama o wrapper com `-TimeoutSec 45 -LockWaitSec 30`: o pior caso cabe nos 600 s do hook.

**Regras de codificação.** Comportamento testado neste Claude Code 2.1.295:
- o `Edit` **não recusa** arquivo ANSI. Ele grava e troca os acentos de linhas não editadas por U+FFFD;
- o `Edit` preserva BOM e CRLF, inclusive em linhas novas;
- o `Write` grava UTF-8 sem BOM e LF;
- o `Edit` falha com EPERM em arquivo somente leitura.

| Ferramenta | Arquivo | Decisão |
|---|---|---|
| Edit/MultiEdit | ANSI, UTF-16, binário | nega → edit-preserve |
| Edit/MultiEdit | ASCII e o texto novo tem não-ASCII | nega (viraria UTF-8 sem BOM), salvo `asciiAs=utf8` |
| Edit/MultiEdit | UTF-8 (com ou sem BOM), ASCII com texto ASCII | segue para o checkout |
| Write | existente que não é UTF-8 sem BOM/ASCII, ou com CRLF, ou ASCII + conteúdo não-ASCII | nega → `edit-preserve -ContentFile` |
| Write | novo com não-ASCII | nega → `edit-preserve -ContentFile -NewFileEncoding` |

**Checkout** (só se houver `.dpr`/`.dpk` na pasta ou acima), conforme o modo (§2).

**Somente leitura:** nega (e manda não remover o atributo) quando o arquivo está somente leitura e o
checkout não resolve: sem `.dpr`/`.dpk` acima (unit de biblioteca: checkout com `-Project`), não versionado,
"já é meu" mas somente leitura (checkout feito em outra pasta/máquina), ou checkout feito e o arquivo
continua somente leitura.

### Stop (`hooks\stop.ps1`, timeout 120)

O PreToolUse roda **antes** da aprovação da edição. No modo `auto`, se o usuário negar o Edit (ou o Edit
falhar), o módulo fica em checkout sem alteração. O hook Stop lê o registro da sessão
(`%LOCALAPPDATA%\JEDI\JVCS\sessoes\<session_id>.txt`, gravado pelo wrapper a cada checkout em contexto
de agente), roda `status` nesses arquivos e mostra ao usuário (`systemMessage`) os que continuam em
checkout: **sem alteração** (sugere `undocheckout`) ou **com alteração** (falta check-in). Os que não estão
mais em checkout saem do registro. Sem registro, termina na hora (não chama o `jvcs.exe`). Sempre exit 0:
nunca bloqueia nem faz o Claude continuar, e não desfaz nada sozinho.

---

## 6. Segurança

- **Senha:** lida da identidade salva (`HKCU\Software\JEDI\JEDIVCS\Identities`: `LastUsedID` → `ID<n>` →
  subchave `<nome>`, valor `Password` = Base64 dos bytes ANSI). Vira **bytes**, nunca string, e vai no
  stdin do `jvcs.exe` como primeira linha (`jvcs.dpr:3673-3681`). O buffer é zerado depois.
  Nunca vai para a linha de comando, o log, a saída ou um arquivo.
- **Armadilha corrigida:** o .NET Framework grava o BOM do `Console.InputEncoding` (UTF-8 no Claude Code)
  no stdin do processo filho. A senha chegaria como `EF BB BF`+senha e o login falharia. O wrapper troca
  temporariamente a codificação para 1252 em volta do `Process.Start` e confere. Efeito colateral aceito:
  `SetConsoleCP(1252)` vale por um instante para o console inteiro (outros processos ligados a ele).
- **Injeção no `/input`:** o `TStringList.LoadFromFile` do console quebra linha em CR ou LF. Qualquer
  linha do `/input` com caractere de controle é recusada (2), e `-Project`/`-Identity` com CR/LF/aspas
  também. Antes disso, `list -Project "x.dpr<LF>undocheckout 4 noprompt"` executava comandos extras.
- **`jvcsExe`:** como recebe a senha, o wrapper só aceita um `.exe` cujo recurso de versão diga
  `OriginalFilename=jvcs.exe` e `ProductName` com "JEDI".
- **Regras do settings:**
  - `allow`: só o wrapper, pelo caminho exato (barras normais e invertidas);
  - `ask`: `*-Confirmed*`, `*-Discard*`, `*-AllowEncodingChange*` (PowerShell e Bash);
  - `deny`: leitura de `JEDIVCS*Identities`; `jvcs* /password` e `-password`; `config set`; `*JVCS*config.ini*`;
    o instalador; `edit-preserve ... -NoCheckout`; comandos que citem `CLAUDECODE`/`AI_AGENT`;
    `settings.local.json` e `disableAllHooks` (a IA não pode desligar os hooks); `attrib`, `IsReadOnly`,
    `SetAttributes`, `-Name Attributes`, `.Attributes =`, `chmod`; `Edit` em `.claude/settings*.json`,
    `.claude/skills/jvcs/**`, `~/AppData/Roaming/JEDI/JVCS/**`, `~/AppData/Local/JEDI/JVCS/**` e `tools\ai\**`.
  - Não há regras `Write(caminho)`: o Claude Code as aceita mas nunca consulta (avisa na inicialização);
    `Edit(caminho)` cobre o Write.
- **Auditoria:** `%LOCALAPPDATA%\JEDI\JVCS\ai-audit.log`, uma linha JSON por comando (exceto `help`,
  `identity`, `config get/list`). Registra data UTC e usuário do Windows; identidade, usuário JVCS e
  servidor; comando, argumentos, projeto, módulos e versões, código; contexto de agente, `AI_AGENT` e
  `CLAUDE_CODE_SESSION_ID`; se houve `-Confirmed`, os modos e o comentário. Sem senha.
- **Mutex** `Local\JEDI.JVCS.AI.<identidade>.<usuário>@<host>_<porta>`: serializa todas as chamadas da
  mesma identidade, inclusive a do hook.
- **Timeout** com kill do `jvcs.exe` (`timeoutSec`, ou `-TimeoutSec`; o hook usa 45 s por execução e 30 s
  de mutex). Protege contra o laço da sessão interativa com stdin em EOF (`jvcs.dpr:3415-3439`). Depois de
  um timeout em checkout/check-in/undocheckout o wrapper confere o servidor (e compensa o checkout). Os
  comandos vão sempre em minúsculas via `/input`. O wrapper também recusa caminho de exe, servidor ou
  usuário que contenha "input", porque o console procura o comando com `StrPos` sensível a maiúsculas na
  linha de comando inteira.

**Limites conhecidos (regras por texto não são fronteira de segurança, R-10):**
- regras por texto não pegam formas alternativas (caminho montado em variável, `cmd /c`, .NET, script
  gravado em arquivo e executado). Ex.: um script `.ps1` escrito pela IA que chame o wrapper com
  `-Confirmed` passa pelo wrapper sem a regra `ask` disparar;
- a IA roda com o mesmo usuário do Windows: pode ler o registro (R-19) e gravar o `config.ini` ou o
  settings por caminhos que as regras não cobrem;
- o hook só vê `Edit/MultiEdit/Write`: gravação por comandos de shell não passa por ele. O somente leitura
  do JEDI VCS e as regras `attrib`/`IsReadOnly`/`Attributes` são a barreira prática;
- uma barreira real para `confirm` exigiria confirmação fora do alcance da IA (ex.: diálogo do Windows na
  área de trabalho, ou a futura aba do cliente); não implementado (o usuário escolheu "regra ask + flag").

---

## 7. Limitações

1. **Caminho truncado no `listproject`/`listlocks`:** só 47 caracteres + "...".
   - Operações que mudam o servidor provam o caminho (§3); `status`/`list` não (`pathCheck=prefix`).
   - `status -Project` procura o arquivo sob a pasta do `.dpr`. Se não achar, devolve `localState=unknown`.
   - A prova precisa de um arquivo do módulo existente localmente; sem nenhum → 5.
2. **Módulos homônimos** no mesmo projeto com o mesmo prefixo visível → erro 5. Não há como distinguir
   pelo console. Nome de arquivo com mais de 30 caracteres também aparece truncado (comparação por prefixo).
3. **Sessão única:**
   - O servidor sem branching apaga a sessão anterior do mesmo usuário no LOGIN (F-A). O servidor de teste
     (com branching) aceitou IDE e CLI juntas.
   - Como a IA usa a identidade do usuário (D1), "lock meu" = lock da identidade. **Um checkout feito pelo
     humano na IDE também conta como "meu"** para o hook, e a IA poderá editar e fazer check-in dele.
4. Sem `diff`, `log` e `whoami` no console original. Para ver a diferença: `status` e depois
   `getmodule` manual, ou `git diff --no-index` contra uma cópia.
5. Comentário de check-in em **uma linha**, sem aspas, em CP1252.
6. Caminhos fora do CP1252 são recusados (2): o console 2.5 é ANSI.
7. Módulo novo (`add`) não existe no console: a IA não adiciona arquivos ao JEDI VCS.
8. DFM binário não é editável por texto (hook e edit-preserve recusam).
9. Somente leitura depois do check-in depende de `HKCU\Software\JEDI\JEDIVCS\BaseRegistryKey` (existe nesta máquina).
10. `onFailure` exige Claude Code 2.1.295+. Em versões anteriores, timeout do hook não bloqueia. O script
    nega em erro interno, mas não em timeout.
11. `.dpr`/`.dproj` editados pela IDE sem checkout (não ficam somente leitura) fazem o checkout automático
    recusar com 8 (local difere do servidor); resolva com o usuário (`checkout -Force -Confirmed` ou check-in pela IDE).
12. A sonda de data muda a data do arquivo por cerca de 1 s; uma IDE que olhe a data nesse instante pode
    perguntar se recarrega o arquivo (o conteúdo não muda).

---

## 8. Versão 1.1 — achados dos revisores

| Achado | Decisão |
|---|---|
| S-ALTO-1 injeção de comandos no `/input` pelo `-Project` | aplicado (recusa de controle/aspas no nome e em qualquer linha do `/input`) |
| S-ALTO-2 caminho truncado aceita qualquer cópia com o mesmo prefixo | aplicado com ajuste: sonda de ±6 h (os 2 s sugeridos ficariam dentro da tolerância de 10 s do console) + pré-checagem CRC/`N/A`; "not changed" → 9 |
| S-MÉDIO-3 lock órfão em erro que não é `EOSError` | aplicado |
| S-MÉDIO-4 timeout sem conferir o servidor; hook 300 s | aplicado (conferência + compensação; hook 600 s, 45 s/30 s) |
| S-MÉDIO-5 somente leitura sem `.dpr` acima liberado | aplicado (e estendido a não versionado / "já é meu") |
| S-MÉDIO-6 lacunas de `ask`/`deny` | aplicado em parte: `*JEDI*JVCS*config*` rejeitado (bloquearia `jvcs-ai.ps1 config list`), trocado por `*JVCS*config.ini*`; `-NoCheckout` e `-AllowEncodingChange`/`-Force` tratados no código |
| S-MÉDIO-7 `confirm` só por texto | aplicado em parte: stdin redirecionado = agente, `-Confirmed` sensível a maiúsculas, `ask` genérica; diálogo do Windows não implementado (risco documentado) |
| S-MÉDIO-8 formato `args` do hook | **rejeitado**: a documentação atual mostra exatamente `command` + `args` para PowerShell no Windows |
| S-B-9 `-Force` sem restauração se falhar no meio | aplicado (lista incremental) |
| S-B-10 CR isolado vira CRLF | aplicado (edit-preserve e comparação de codificação) |
| S-B-11 instalador volta o modo para `confirm` | aplicado (só grava com `-Mode`) |
| S-B-12 mensagem enganosa no `undocheckout` | aplicado |
| S-B-13 `SetConsoleCP` global | documentado |
| S-B-14 / C-5 lock após edição negada | aplicado: hook Stop + mensagem do hook + data restaurada após o checkout |
| C-1 modo `auto` sem `allow` | aplicado para o wrapper; `edit-preserve` só com `-AllowEditPreserve` |
| C-2 `edit-preserve` grava qualquer caminho / `-NoCheckout` | aplicado |
| C-3 `ask` dependente do caminho | aplicado (`*-Confirmed*`, `*-Discard*`, `*-AllowEncodingChange*`) |
| C-4 `-confirmed` minúsculo escapa da regra Bash | aplicado |
| C-6 regras `Write(caminho)` ignoradas | aplicado (removidas; confirmado na documentação) |
| C-7 `deny` incompleto contra tirar o somente leitura | aplicado em parte (padrões específicos; `*Attributes*` amplo bloquearia `Get-ChildItem -Attributes`) |
| C-8 instalador reconhece só o modelo atual; remove o grupo inteiro | aplicado (manifesto + remoção por item) |
| C-9 caminhos absolutos no settings compartilhado | aplicado em parte (`-Scope local` e aviso; padrão continua `project`) |

---

## 9. Testes (12/10/2026, servidor 192.168.0.10:2106, identidade DEFAULT, Exemplo01)

- **Console falso** (`Invoke-Jvcs` trocado por um console que imita o `jvcs.dpr`, inclusive `Stamp`/`CRC`
  no caminho do servidor): 32/32 — D7, `-Discard`, `-Force` com e sem `-Confirmed`, lock de outro,
  confirm/manual, `-confirmed` minúsculo, compensação `EOSError` e `EFCreateError`, timeout no checkout,
  recusa silenciosa, "not changed" incoerente, codificação, homônimos, **cópia com o mesmo prefixo
  truncado** (checkout, `-Force`, check-in e `-Discard` pela cópia → 5, nada muda no servidor), sonda
  restaura a data.
- **edit-preserve:** recusas ao agente (`-NoCheckout`, `tools\ai`, `config.ini`, `.claude`, `.bat`) → 10;
  arquivo só com CR preservado.
- **Instalador** (projeto de rascunho com o settings 1.0.0 + itens do usuário): sem `-Mode` não grava o
  config; idempotente; mantém `model`, `PostToolUse`, hook do usuário no mesmo grupo e regra do usuário;
  remove legado e `Write(...)`; `-Scope local` move os itens e limpa o `settings.json`; `-WhatIf` não grava.
- **Servidor real**, `uPrincipal.pas` (ANSI 1252, CRLF):
  1. `identity -Test` (Firebird v.250, nível 4), `projects`, `list`, `locks -All` (0), `status` → tudo `clean`, v0.3;
  2. `checkout` (`pathCheck=verified`, 1,7 s) → `edit-preserve` trocando o comentário final (ANSI e CRLF
     preservados) → `checkin` `[IA] ...` → **0.3 → 0.4**, lock liberado, `.pas`/`.dfm` somente leitura;
  3. `checkout` + `checkin` sem mudança → 3 `unchangedUndone`, versão continua 0.4;
  4. `checkout` → alteração → `undocheckout` → 8; `-Discard` → 10; `-Discard -Confirmed` → `discarded`,
     arquivo idêntico à base, somente leitura;
  5. alteração fora do VCS → `checkout` → 8 sem lock; `-Force` sem `-Confirmed` → 10; check-in com o
     arquivo regravado em UTF-8/LF → 7 `encodingChanged` (lock mantido); `-AllowEncodingChange` → 10;
     desfeito e `undocheckout`;
  6. hook: Edit/Write no `.pas` ANSI → deny (codificação) em todos os modos; Edit com acento no `.dfm`
     ASCII → deny; Edit ASCII no `.dfm`: `auto` → checkout automático (1,9 s) e o hook Stop lembrou
     "SEM alteração"; depois do `undocheckout` o Stop ficou em silêncio; `confirm` → deny com `-Confirmed`;
     `manual` → deny; JSON inválido → exit 2; unit somente leitura fora de projeto → deny;
  7. instalação no Ex1 com `-Mode auto`;
  8. estado final: sem locks, 4 módulos `clean`, uprincipal v0.4.

## 10. Versão 1.1.1 — correções

- `status` do projeto rodado **fora** da pasta do projeto (`-Project exemplo01.dpr`) dava `local=unknown -> pathTruncated` em todos os módulos: quando a pasta do projeto não é encontrada, o arquivo agora é procurado a partir da maior pasta existente do prefixo visível do caminho truncado (profundidade 8), desempatando pela pasta que contém o `.dpr`.
- Caminhos relativos (arquivos e `-Project`) eram resolvidos pela pasta do **processo**, não pela pasta atual do PowerShell; agora usam `GetUnresolvedProviderPathFromPSPath` (também no `edit-preserve.ps1`).
- Sem `-Project`, numa pasta com mais de um `.dpr`/`.dpk`, os nomes padrão do Delphi (`Project1`, `Package1`), que o JEDI VCS recusa, são ignorados na escolha automática.
- Testado no Ex1: `status` (na pasta e fora dela), `status uPrincipal.pas`, `status -Project .\Exemplo01.dpr` → 4 módulos `clean`, sem locks.

## 11. Versão 1.2.0 — diff, addproject e add

- `diff <arq> [-Rev x.y]`: diff unificado contra a revisão do servidor (só leitura; funciona com o console
  original, porque `getmodule <id> rev= dest=` cabe no limite de opções dele).
- `addproject` e `add` (cadastro + 1º check-in 0.1 com a família, ex.: `.pas` + `.dfm`): usam os comandos
  novos do console **2026** (`addproject`, `addmodule`, 1º check-in). Com o console original → código 12.
  Passam pelo modo `checkin` (manual → 10; confirm → 10 até `-Confirmed`; auto → executa).
- Testado (13/10/2026, servidor de teste, `APPDATA` temporário com `jvcsExe` = console 2026):
  `addproject Ex4IA.dpr` → criado; `add Ex4IA.dpr uTeste4.pas` → 0.1 (revisão com `uTeste4.pas` e
  `uTeste4.dfm`); `add` de novo → 3; checkout → `edit-preserve` no `.dfm` → `diff` (só a linha do Caption) →
  check-in 0.1 → 0.2 → `diff` idêntico; modo confirm → `add`/`addproject` com 10 e nada criado; console
  original → `add` com 12; `diff -Rev 0.1` e revisão inexistente (5) com o console original.
