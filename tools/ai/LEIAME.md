# tools\ai — JEDI VCS para a IA (Claude Code)

Camada 0 do ADR-001 (`doc\common\ADR-001-CLI-IA-e-Plugin-Multi-Delphi.md`): a IA faz checkout e
check-in das units Delphi usando o console **original** `jvcs.exe` 2.5.0.1030 (Delphi 2007),
sempre por trás de um wrapper PowerShell que torna o console seguro para automação.

| Arquivo | Para quê |
|---|---|
| `jvcs-ai.ps1` | Wrapper do `jvcs.exe`: identidade salva, senha pelo stdin, mutex, timeout, pré-checagens, JSON |
| `edit-preserve.ps1` | Edição de fonte preservando codificação (ANSI 1252, UTF-8 com/sem BOM, UTF-16) e quebras de linha |
| `hooks\pretooluse.ps1` | Hook `PreToolUse` do Claude Code para `Edit\|MultiEdit\|Write` em fontes Delphi |
| `lib\jvcs-ai-common.ps1` | Funções comuns (JSON, config.ini, detecção de codificação, auditoria) |
| `claude\settings.template.json` | Modelo do hook e das regras de permissão |
| `claude\skills\jvcs\SKILL.md` | Skill que ensina a IA o fluxo |
| `instalar-no-projeto.ps1` | Instala hook, regras e skill num projeto e grava o modo |

Requisitos: Windows PowerShell 5.1, `C:\Program Files (x86)\JEDI\JVCS\jvcs.exe` 2.5.0.1030 com
`FVCSCrypt.dll`, uma **identidade salva com senha** (GUI: Server Login → "Store Password with identity"),
Claude Code **2.1.295+** (por causa de `"onFailure": "block"` no hook).

Os `.ps1` são **UTF-8 com BOM e CRLF**. Sem BOM o PowerShell 5.1 lê o arquivo na code page ANSI e
estraga as mensagens acentuadas. Ao editar, mantenha o BOM (o `Edit` do Claude Code mantém; o `Write` não).

---

## 1. Instalação num projeto

No **seu** terminal (a IA tem regra `deny` para este script):

```powershell
D:\Delphi\JediVCS\v2026\tools\ai\instalar-no-projeto.ps1 -ProjectDir C:\caminho\do\projeto -Mode confirm   # padrão
D:\Delphi\JediVCS\v2026\tools\ai\instalar-no-projeto.ps1 -ProjectDir C:\caminho\do\projeto -Mode auto -WhatIf
```

O instalador:

1. mescla o modelo em `<projeto>\.claude\settings.json` **sem apagar o que existe**. Ele troca só a entrada
   do hook `pretooluse.ps1` e as regras listadas no modelo; antes, guarda `settings.json.bak-<data>`.
   Pode rodar de novo (é idempotente);
2. copia a skill para `<projeto>\.claude\skills\jvcs\SKILL.md`, com o caminho absoluto de `tools\ai`;
3. grava `checkout=` e `checkin=` em `%APPDATA%\JEDI\JVCS\config.ini`. `-CheckoutMode`/`-CheckinMode`
   sobrepõem `-Mode`.

Depois abra o projeto no Claude Code e aceite a confiança da pasta. Os hooks de settings só rodam depois disso.

Instalação de teste feita nesta máquina: `C:\Users\edmarfrazao\Documents\Embarcadero\Studio\Projects\Ex1`
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
**`config set` é recusado em contexto de agente**: o modo é decisão do usuário.

| Modo | Checkout (hook/edit-preserve/wrapper) | Check-in (wrapper) |
|---|---|---|
| `auto` | O hook roda `ensure-checkout` antes do Edit, sem perguntar | `checkin` direto |
| `confirm` | O hook **nega** e manda rodar `checkout <arq> -Confirmed`; a regra `ask` faz o Claude Code pedir aprovação | Exige `-Confirmed` (por extenso) quando chamado por agente; a regra `ask` pede aprovação |
| `manual` | O hook nega e pede ao humano | Recusado ao agente (código 10) |

Descartar alteração (`undocheckout -Discard`) **sempre** exige `-Confirmed` do agente, em qualquer modo.

Por que o hook não devolve `permissionDecision: "ask"` no modo `confirm`: aprovar a edição não
adiantaria, porque o arquivo sem checkout é somente leitura e o `Edit` falha com `EPERM` (testado). A
confirmação passa para o **comando de checkout**, que é a ação que muda o servidor.

Regras `ask` do modelo: `PowerShell(*jvcs-ai.ps1*-Confirmed*)`, `Bash(*jvcs-ai.ps1*-Confirmed*)` e
as equivalentes com `-Discard`. Elas ficam **sempre** instaladas. No modo `auto` a IA não usa `-Confirmed`,
e nada é perguntado; no `confirm`, `-Confirmed` é obrigatório e dispara a pergunta. Assim, trocar o modo no
`config.ini` não exige reinstalar o settings. O wrapper confere que `-Confirmed` foi escrito por extenso
(o PowerShell aceitaria `-Con`, que escaparia da regra).

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
powershell -NoProfile -ExecutionPolicy Bypass -File D:\Delphi\JediVCS\v2026\tools\ai\jvcs-ai.ps1 <comando> [args] [opções]
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
| `config list\|get\|set` | Configuração |

Opções: `-Project <nome.dpr\|caminho>`, `-Identity <nome>`, `-Text` (saída legível), `-Agent` (força
contexto de agente), `-Confirmed`, `-AllowEncodingChange`, `-TimeoutSec <n>`, `-Raw` (inclui a saída
bruta do console; não contém senha).

**Resolução de projeto e módulo:**
- projeto: `.dpr`/`.dpk` na pasta do arquivo ou acima (o mais próximo primeiro), ou `-Project`. Candidatos
  que não existem no servidor são ignorados. Se o arquivo estiver em dois projetos no mesmo nível, o
  resultado é 5 e é preciso informar `-Project`;
- módulo: pelo nome **e** pelo caminho na tabela do `listproject`. O caminho aparece truncado em 47
  caracteres + "...", então a comparação é por prefixo. `.dfm`/`.fmx` resolvem para o módulo da família.

**checkout:** recusa se o lock é de outro (6). Baixa a base e compara bytes:
- local diferente → **8, sem pedir lock**;
- conteúdo igual com data diferente → alinha a data à da base (o console decide "sujo" por data OU CRC;
  sujo faz o console travar e depois perguntar, e com stdin redirecionado a pergunta vira `EOSError`).

Em seguida roda `checkout <id>` e confere em `listlocks`. Se mesmo assim aparecer `EOSError` com o módulo
travado, faz `undocheckout` de compensação (7).

`-Force` trava **mantendo** a alteração local:
1. backup em `%LOCALAPPDATA%\JEDI\JVCS\backup`;
2. troca o local pela base;
3. faz o checkout pelo caminho limpo;
4. devolve o conteúdo do usuário.

**checkin:**
1. exige lock meu (7 sem checkout; 6 de outro);
2. sem mudança em bytes → `undocheckout` (D7), código **3**;
3. valida a codificação de cada membro alterado contra a base. Recusa (7 `encodingChanged`):
   - BOM que some ou aparece;
   - UTF-16 trocado;
   - ANSI/ASCII que virou UTF-8 sem BOM;
   - UTF-8 que virou ANSI;
   - CRLF→LF;
   - U+FFFD novo.

   `-AllowEncodingChange` aceita a mudança;
4. comentário: uma linha, sem `"`, CP1252, até 2000 caracteres. Em contexto de agente recebe o prefixo `[IA] `;
5. confere a versão nova e o lock liberado no `listproject` (o console 2.5 não mostra a recusa do servidor:
   versão igual = recusado, 7);
6. confere o arquivo local contra a revisão recém-criada.

**undocheckout:**
- sem `-Discard`: só quando o local é igual à base (senão 8, lock mantido); a data é alinhada antes;
- `-Discard`: backup, `undocheckout <id> noprompt`, depois repõe o somente leitura que o console não repõe
  nesse caminho (filtro `Writeable Files` do registro, só leitura).

### Saída JSON (padrão; uma linha, ASCII com `\uXXXX`)

```json
{"ok":true,"command":"checkin","project":"exemplo01.dpr",
 "modules":[{"id":4,"name":"uprincipal.pas","path":"C:\\...\\uPrincipal.pas","version":"0.3","lockedBy":"",
             "localState":"clean","state":"checkedIn","exitCode":0,"message":"check-in ok: 0.2 -> 0.3",
             "files":[{"name":"uPrincipal.dfm","localState":"clean","readOnly":true},
                      {"name":"uPrincipal.pas","localState":"clean","readOnly":true}]}],
 "message":"check-in ok: 0.2 -> 0.3","exitCode":0,"comment":"[IA] ..."}
```

Campos extras conforme o comando: `identity`, `projects`, `config`, `configPath`, `comment`, `warnings`, `raw`.
`ok` é verdadeiro para 0 e 3.

`modules[].state`:
- `checkedOut`, `checkedOutKeptLocal`, `alreadyMine`, `needsCheckout`, `notVersioned`;
- `lockedByOther`, `localModified`, `needsConfirmation`;
- `checkedIn`, `unchangedUndone`, `refused`, `encodingChanged`, `notCheckedOut`, `localMissing`;
- `undone`, `discarded`, `releasedButDirty`, `failedCompensated`, `failed`, `error`, `ok`, `pathTruncated`.

### Códigos de saída (estáveis)

| Código | Significado |
|---|---|
| 0 | ok |
| 2 | uso/parâmetro inválido (inclui comentário com aspas e texto fora do CP1252) |
| 3 | nada a fazer (check-in sem mudança → checkout desfeito) |
| 4 | credencial: identidade ausente/incompleta, sem senha salva, login recusado |
| 5 | não encontrado: projeto/módulo, arquivo não versionado, ambiguidade |
| 6 | travado por outro usuário |
| 7 | pré-condição: sem checkout, codificação mudou, servidor recusou, compensação de prompt |
| 8 | conflito local: arquivo local difere do servidor (nada foi travado ou liberado) |
| 9 | servidor/console: conexão, timeout, saída inesperada |
| 10 | confirmação necessária (`confirm` sem `-Confirmed`), modo manual, `config set` por agente |
| 11 | lote parcial (resultados diferentes por arquivo) |
| 12 | ambiente: `jvcs.exe` ausente ou não reconhecido, mutex ocupado além de `lockWaitSec` |

O `jvcs.exe` original devolve 0 mesmo com erro dentro de `/input`. Por isso o wrapper ignora o código
dele e interpreta a saída: linhas `[Classe] mensagem`, sintaxe impressa e tabelas de largura fixa.

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
- As quebras de linha de `-Old`/`-New`/`-ContentFile` são convertidas para as do arquivo (CRLF ou LF).
- Alvo ANSI: caractere fora do 1252 → 6. Alvo ASCII que recebe acento → grava em 1252 (`asciiAs=ansi`),
  porque o compilador Delphi lê fonte sem BOM como ANSI.
- Nunca tira o somente leitura (7). Em fonte Delphi de projeto JEDI VCS aplica o modo de checkout:
  `auto` → `ensure-checkout`; `confirm`/`manual` → exige checkout prévio (10). `-NoCheckout` pula essa etapa.
  `-DryRun` simula.

Saída: `{ok, path, encoding, eol, replacements, bytesBefore, bytesAfter, checkout, message, exitCode}`.

---

## 5. Hook (hooks\pretooluse.ps1)

Formato conferido em code.claude.com/docs/en/hooks (12/10/2026).
- Entrada: JSON no stdin com `tool_name` e `tool_input.file_path`, `old_string`, `new_string`, `content`, `edits[]`.
- Negar: `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"..."}}`
  com exit 0. O motivo vai para o Claude.
- Seguir: stdout vazio, e o fluxo normal de permissões continua. Depois de um checkout automático, só
  `additionalContext` (para o Claude) e `systemMessage` (aviso ao usuário).
- Erro interno: exit 2 com o motivo no stderr. É **falha fechada**: bloqueia a ferramenta. Com
  `"onFailure":"block"` no settings, timeout e falha ao iniciar também bloqueiam.
- Regras `ask`/`deny` do settings continuam valendo mesmo que o hook não decida nada.

**Regras de codificação.** Comportamento testado neste Claude Code 2.1.295:
- o `Edit` **não recusa** arquivo ANSI. Ele grava e troca os acentos de linhas não editadas por U+FFFD;
- o `Edit` preserva BOM e CRLF, inclusive em linhas novas;
- o `Write` grava UTF-8 sem BOM e LF;
- o `Edit` falha com EPERM em arquivo somente leitura.

| Ferramenta | Arquivo | Decisão |
|---|---|---|
| Edit/MultiEdit | ANSI, UTF-16, binário | nega → edit-preserve |
| Edit/MultiEdit | ASCII e o texto novo tem não-ASCII | nega (viraria UTF-8 sem BOM), salvo `asciiAs=utf8` |
| Edit/MultiEdit | UTF-8 (com ou sem BOM), ASCII com texto ASCII | segue |
| Write | existente que não é UTF-8 sem BOM/ASCII, ou com CRLF, ou ASCII + conteúdo não-ASCII | nega → `edit-preserve -ContentFile` |
| Write | novo com não-ASCII | nega → `edit-preserve -ContentFile -NewFileEncoding` |

**Checkout:** só se houver `.dpr`/`.dpk` na pasta ou acima, conforme o modo (§2). Edições de arquivo do
projeto que não é módulo versionado seguem.

---

## 6. Segurança

- **Senha:** lida da identidade salva (`HKCU\Software\JEDI\JEDIVCS\Identities`: `LastUsedID` → `ID<n>` →
  subchave `<nome>`, valor `Password` = Base64 dos bytes ANSI). Vira **bytes**, nunca string, e vai no
  stdin do `jvcs.exe` como primeira linha (`jvcs.dpr:3673-3681`). O buffer é zerado depois.
  Nunca vai para a linha de comando, o log, a saída ou um arquivo.
- **Armadilha corrigida:** o .NET Framework grava o BOM do `Console.InputEncoding` (UTF-8 no Claude Code)
  no stdin do processo filho. A senha chegaria como `EF BB BF`+senha e o login falharia. O wrapper troca
  temporariamente a codificação para 1252 em volta do `Process.Start` e confere.
- **`jvcsExe`:** como recebe a senha, o wrapper só aceita um `.exe` cujo recurso de versão diga
  `OriginalFilename=jvcs.exe` e `ProductName` com "JEDI".
- **Regras do settings** (`deny`):
  - leitura de `JEDIVCS*Identities`;
  - `jvcs* /password` e `-password`;
  - `config set`;
  - o instalador;
  - comandos que citem `CLAUDECODE`/`AI_AGENT`, para a IA não esconder o contexto de agente;
  - `attrib` e `IsReadOnly`;
  - Edit/Write em `~/AppData/Roaming/JEDI/JVCS/**` e em `tools\ai\**`.

  `ask`: `-Confirmed` e `-Discard`.
- **Auditoria:** `%LOCALAPPDATA%\JEDI\JVCS\ai-audit.log`, uma linha JSON por comando (exceto `help`,
  `identity`, `config get/list`). Registra:
  - data UTC e usuário do Windows;
  - identidade, usuário JVCS e servidor;
  - comando, argumentos, projeto, módulos e versões, código;
  - contexto de agente, `AI_AGENT` e `CLAUDE_CODE_SESSION_ID`;
  - se houve `-Confirmed`, os modos e o comentário.

  Sem senha.
- **Mutex** `Local\JEDI.JVCS.AI.<identidade>.<usuário>@<host>_<porta>`: serializa todas as chamadas da
  mesma identidade, inclusive a do hook (testado: a segunda chamada esperou o mutex).
- **Timeout** com kill do `jvcs.exe` (`timeoutSec`, ou `-TimeoutSec`; o hook usa 60 s por execução).
  Protege contra o laço da sessão interativa com stdin em EOF (`jvcs.dpr:3415-3439`). Os comandos vão
  sempre em minúsculas via `/input`. O wrapper também recusa caminho de exe, servidor ou usuário que contenha
  "input", porque o console procura o comando com `StrPos` sensível a maiúsculas na linha de comando inteira.

**Limites conhecidos (não são fronteira de segurança):**
- regras por texto não pegam formas alternativas (caminho, `cmd /c`, .NET);
- a IA roda com o mesmo usuário do Windows e poderia ler o registro por outro caminho (R-19);
- as variáveis `CLAUDECODE`/`AI_AGENT` podem ser removidas (R-24);
- o hook só vê `Edit/MultiEdit/Write`: gravação por comandos de shell não passa por ele. O somente leitura
  do JEDI VCS e as regras `attrib`/`IsReadOnly` são a barreira.

---

## 7. Limitações

1. **Caminho truncado no `listproject`/`listlocks`:** só 47 caracteres + "...".
   - A resolução por arquivo usa nome + prefixo.
   - `status -Project` procura o arquivo sob a pasta do `.dpr`. Se não achar, devolve `localState=unknown`.
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

---

## 8. Versão 1.1 (12/10/2026) — correções dos revisores

- **Injeção no `/input`:** `-Project` com CR/LF/aspas é recusado (2), e qualquer linha do `/input` com
  caractere de controle também (o `TStringList` do console quebra linha em CR ou LF).
- **Caminho truncado (47 caracteres):** antes de checkout/check-in/undocheckout o wrapper prova que o
  arquivo local é o do caminho do servidor (o console lê/grava lá): coluna CRC/`N/A` coerente e sonda de
  data ±6 h no `listproject` (o console tolera 10 s), com a data restaurada. Se for outra cópia: 5
  `pathMismatch`, nada é feito. Campo `pathCheck` = `exact` | `prefix` | `verified`.
- Check-in em que o console diz "not changed" com local diferente → 9 (não é mais sucesso).
- Compensação (undocheckout) para **qualquer** erro do checkout depois do lock; timeout do `jvcs.exe`
  marca o erro, confere o servidor e compensa o checkout. `-LockWaitSec`; o hook usa 45 s/30 s e
  timeout 600.
- `-Confirmed` agora **exatamente assim** (C maiúsculo). `checkout -Force` e
  `checkin -AllowEncodingChange` pela IA exigem `-Confirmed` em qualquer modo.
- Contexto de agente inclui **stdin redirecionado** (cobre a IA que apaga `CLAUDECODE`/`AI_AGENT`).
- `edit-preserve` pela IA: só fontes Delphi e .rc/.groupproj/.bpg/.txt/.sql/.iss; nunca em tools\ai,
  dados do JEDI VCS, `.claude` ou `.git`; `-NoCheckout` recusado. Quebra CR isolada preservada.
- Hook: nega arquivo somente leitura que o checkout não resolve (fora de projeto, não versionado, "já é
  meu" mas somente leitura). Checkout automático restaura a data original do arquivo.
- Hook **Stop** (`hooks\stop.ps1`): lembra os checkouts da sessão que ficaram presos (ex.: edição negada
  após o checkout automático). Nunca bloqueia; não desfaz nada sozinho.
- Settings: regra **`allow`** exata para o wrapper (sem ela o modo `auto` ainda perguntava a cada
  chamada); `ask` genéricas `*-Confirmed*`, `*-Discard*`, `*-AllowEncodingChange*`; `deny` sem
  `Write(...)` (ignorado pelo Claude Code) e com `config.ini`, `settings.local.json`, `disableAllHooks`,
  `SetAttributes`/`.Attributes=`. Comandos canônicos com barras normais (`D:/.../jvcs-ai.ps1`).
- Instalador: só grava o modo com `-Mode`/`-CheckoutMode`/`-CheckinMode`; manifesto
  `.claude\jvcs-ai.managed.json`; remove só os itens de hook dele; `-Scope local`; `-AllowEditPreserve`.
- Mantido: `confirm` = o hook **nega** e manda rodar `checkout -Confirmed` (regra `ask`), em vez de
  `permissionDecision:"ask"` (o Edit aprovado falharia com EPERM). Registrar em `doc\common\Decisoes.md`.

## 9. Testes (12/10/2026, servidor 10.211.55.3:2106, identidade DEFAULT, Exemplo01)

- Console falso: 32/32 (inclui cópia com mesmo prefixo truncado → 5, compensação EFCreateError,
  timeout, "not changed", `-Force`/`-AllowEncodingChange` sem `-Confirmed`).
- Servidor real: identity/projects/list/locks/status ok; checkout (`verified`) → edit-preserve ANSI →
  check-in `[IA]` 0.3 → 0.4; check-in sem mudança → 3; `-Discard -Confirmed` restaura a base; checkout com
  local alterado → 8; check-in com UTF-8/LF → 7; hook auto fez checkout e o Stop lembrou; confirm/manual
  negam; instalação no Ex1 com `-Mode auto`. Estado final: sem locks, tudo `clean`, somente leitura.