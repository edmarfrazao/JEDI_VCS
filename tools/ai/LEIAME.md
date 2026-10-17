# tools\ai — JEDI VCS para a IA (Claude Code)

Versão **1.4.0** (17/10/2026). Camada 0 do ADR-001 (`doc\pt\common\ADR-001-CLI-IA-e-Plugin-Multi-Delphi.md`):
a IA faz checkout e check-in das units Delphi usando o console `jvcs.exe` (o **original** 2.5.0.1030, de
Delphi 2007, ou o console **2026**, que os comandos novos exigem), sempre por trás de um wrapper PowerShell que
torna o console seguro para automação. Nas versões 1.2.0 a 1.4.0 o wrapper ganhou, além do checkout e do
check-in: diff, histórico, log do projeto, busca, labels, ToDo, bugs, blame, revert, sincronização e
administração (tabela da seção 3; detalhes nas seções 11 a 17).

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
`FVCSCrypt.dll` (para os comandos novos, o console 2026 em `C:\Program Files (x86)\JEDI\JVCS 2026`, apontado
por `config set jvcsExe`), uma **identidade salva com senha** (GUI: Server Login → "Store Password with identity"),
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
projectAdmin=off      ; on | off (padrão off): rm-project/restore-project/rename-project com -Apply (seção 15)
moduleAdmin=off       ; administração de módulos: off | on | archive (padrão off; ver seção 14)
blameMaxRevisions=200 ; revisões que o blame percorre (1 a 5000; seção 16)
cacheMaxMB=500        ; tamanho máximo do cache de revisões do blame (10 a 100000)
buildCheck=off        ; off | warn | block: compilar antes do check-in (seção 16)
buildCommand=         ; script .bat/.cmd/.ps1 do usuário; o SHA-256 vai em buildCommandSha256
buildConfig=Debug
buildPlatform=Win32   ; Win32 | Win64
buildTimeoutSec=600   ; 30 a 7200
```

Comandos: `jvcs-ai.ps1 config list | get <chave> | set <chave> <valor>`.
**`config set` é recusado em contexto de agente**: o modo é decisão do usuário. O `config.ini` vale para
o usuário do Windows inteiro (todos os projetos).

| Modo | Checkout (hook / edit-preserve / wrapper) | Check-in (wrapper) |
|---|---|---|
| `auto` | o hook roda `ensure-checkout` antes do Edit, sem perguntar; o wrapper faz `checkout` direto | `checkin` direto |
| `confirm` | o hook **nega** e manda rodar `checkout <arq> -Confirmed`; a regra `ask` faz o Claude Code pedir aprovação | exige `-Confirmed` do agente; a regra `ask` pede aprovação |
| `manual` | o hook nega e pede ao humano | recusado ao agente (código 10) |

Seguem a coluna Checkout: `sync -Apply` (todas as formas) e `revert`. Seguem a coluna Check-in: `add`,
`addproject`, `label`, `todo-add`/`todo-done`, `bug-add`/`bug-update`/`bug-link`, `checkin -Keep`,
`revert -Checkin` e o `-Apply` da administração de projetos. As consultas (`history`, `changes`, `search`,
`labels`, `todo`, `bugs`, `blame`, prévias...) não passam pelos modos.

Sempre exigem `-Confirmed` do agente, **em qualquer modo** (inclusive `auto`):
`undocheckout -Discard`, `checkout -Force` e `checkin -AllowEncodingChange`; desde a 1.3.0/1.4.0 também
`sync -Apply -Force` (com ou sem `-Label`/`-Date`), `revert -Checkin`/`-Force`/`-AllowEncodingChange`,
`-SkipBuild` (com `buildCheck` ligado) e todo `-Apply` de administração de módulos e de projetos
(seções 14 e 15), que além disso exige a chave `moduleAdmin`/`projectAdmin`.

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

Todos os comandos (a mesma lista do `help`); "(seção n)" aponta o detalhe neste arquivo. "Console 2026" =
exige o `jvcs.exe` 2026 (`config set jvcsExe`); com o original, código 12.

| Comando | O que faz |
|---|---|
| `help` | Resumo dos comandos e opções |
| `identity [-Test]` | Identidade em uso (nome, host, porta, usuário, origem). `-Test` faz login. **Nunca mostra a senha** |
| `projects` | Projetos do servidor (`listprojects`) |
| `list [-Project p]` | Módulos do projeto: versão, lock e estado local pelo **CRC que o console calcula** no caminho do servidor (rápido) |
| `locks [-All]` | Módulos em checkout: meus, ou de todos |
| `status <arq...>` / `status -Project p` | Estado **exato**: baixa a última revisão com `getmodule <id> dest="<pasta nova>"` e compara bytes. `localState` = `clean`, `modified`, `missing`, `notVersioned` ou `unknown` |
| `checkout <arq...> [-Force]` | Checkout seguro (ver abaixo) |
| `ensure-checkout <arq> [-CheckOnly]` | Para hooks, idempotente. Não versionado → ok (no-op); já é meu → ok; de outro → 6; local alterado → 8. `-CheckOnly` só informa (`needsCheckout`) |
| `checkin <arq...> -Comment "texto" [-AllowEncodingChange] [-SkipBuild]` | Check-in (ver abaixo). Com `buildCheck=warn\|block`, compila antes com o script do usuário (seção 16) |
| `checkin <arq...> -Comment "texto" -Keep` | **Put**: revisão nova e o checkout continua; sem mudança → 3 sem desfazer o checkout. Modo `checkin`; console 2026 (seção 17) |
| `undocheckout <arq...> [-Discard]` | Desfaz o checkout só se o local for igual à base; com `-Discard`, faz backup e restaura a base |
| `diff <arq> [-Rev x.y]` | Diff unificado do arquivo local contra a revisão do servidor (padrão: a última), com `getmodule <id> [rev=x.y] dest="<pasta nova>"` e `git diff --no-index` sobre o texto decodificado; diferença de codificação/quebras vai para `warnings`. Só leitura; funciona com o console original |
| `diff <arq> -Rev x.y -Rev2 y.z` | Diff entre duas revisões do servidor; o arquivo local não precisa existir (seção 12) |
| `history <arq> [-Max n]` | Revisões do módulo, mais recente primeiro: data do arquivo, usuário, família, comentário e labels. Console 2026 (seções 12 e 13) |
| `changes [-Project p] [-Since d] [-User u] [-Max n]` | Check-ins do projeto desde a data (padrão `7d`), com a **hora real** do check-in, pelo log do servidor. Só leitura; console 2026 (seção 13) |
| `search <padrão> [-Project p] [-Max n]` | Módulos por nome ou máscara (`*`, `?`) em todos os projetos. Só leitura; console 2026 (seção 13) |
| `search "<texto>" -InComments [-Project p] [-Max n] [-MaxModules n]` | Texto nos comentários de check-in/check-out das revisões do projeto. Só leitura; console 2026 (seção 13) |
| `show <arq> -Rev x.y [-Dest pasta]` | Grava a revisão (com a família) numa pasta de consulta fora do projeto. Funciona com o console original (seção 12) |
| `sync [-Project p] [-Apply [-Force]]` | Prévia (padrão) / atualiza a cópia local pelas últimas revisões, com backup; nunca mexe no seu checkout. `-Apply` segue o modo `checkout` (seção 12) |
| `sync -Label <nome> [-Project p] [-Apply [-Force]]` | Prévia / volta a cópia local ao label, com backup. Console 2026 (seção 13) |
| `sync -Date <data> [-Project p] [-Apply [-Force]]` | Rollback: prévia / volta a cópia local ao estado da data (data do **arquivo** das revisões), com backup. Console 2026 (seção 17) |
| `sync -Dest <pasta> [-Label l \| -Date d] [-Project p] [-Apply]` | Grava o estado numa pasta **nova ou vazia** fora do projeto, como cópia de leitura; não toca no servidor nem na cópia de trabalho. Console 2026 (seção 17) |
| `labels [-Project p]` / `labels -All` / `labels <arq>` / `labels -Label <nome>\|#id [-Project p]` | Labels do projeto, do servidor, de cada revisão do módulo, ou a revisão de cada módulo num label. Só leitura; console 2026 (seção 13) |
| `label <nome> [-Project p]` | Rotula a última revisão **do servidor** de cada módulo; label já usado no projeto → 8. Modo `checkin`; console 2026 (seção 13) |
| `shared <arq>` / `shared [-Project p]` | Projetos que compartilham o módulo / módulos do projeto compartilhados com outros. Console 2026 (seção 13) |
| `todo [-Project p \| -All] [-User login\|me\|all] [-Category c] [-Priority 1-9] [-Due aaaa-mm-dd] [-IncludeDone]` | Itens de ToDo (padrão: abertos do projeto). Só leitura; console 2026 (seção 13) |
| `todo-add "texto" [-Project p] [-Priority 1-9] [-Category c] [-User login\|me] [-Due aaaa-mm-dd]` | Cria item de ToDo. Modo `checkin`; console 2026 (seção 13) |
| `todo-done <id> [-Reopen]` | Conclui (ou reabre) o item. Modo `checkin`; console 2026 (seção 13) |
| `milestones [-Project p \| -All]` | Milestones definidos e atingidos. Só leitura; console 2026 (seção 13) |
| `bugs [<arq>] \| -Project p \| -All \| -Bug n \| -Summary [-OpenOnly]` | Bugs do módulo/projeto/servidor, um bug com as ligações, ou o mais grave por módulo. Só leitura; console 2026 (seção 13) |
| `bug-add -Title "..." [-Severity s] [-Status s] [-Keywords ..] [-ReportedBy ..] [-Description ..\|-DescriptionFile f] [-Workaround ..\|-WorkaroundFile f] [<arq...> \| -Project p]` | Cria o bug e liga aos módulos (ou ao projeto); ligação falha → 11 com `bugId`. Modo `checkin`; console 2026 (seção 13) |
| `bug-update -Bug n [campos]` | Muda só os campos dados. Modo `checkin`; console 2026 (seção 13) |
| `bug-link -Bug n <arq...> \| -Project p [-Remove \| -Done \| -Reopen]` | Liga, desliga ou marca a ligação como resolvida/reaberta. Modo `checkin`; console 2026 (seção 13) |
| `addproject <proj.dpr> [-Comment "descrição"]` | Cria o projeto no servidor (use o nome do `.dpr`, como a IDE). Passa pelo modo `checkin`. **Exige o console 2026** (`config set jvcsExe`), senão código 12 |
| `add <arq...> -Comment "texto"` | Cadastra o arquivo no projeto (com a pasta local) e faz o 1º check-in 0.1, com a família (o `.dfm` de uma unit). Já versionado → 3. Passa pelo modo `checkin`; exige o console 2026 |
| `blame <arq> [-Lines a-b] [-Max n] [-Rev x.y] [-IgnoreWhitespace]` | Revisão, usuário, data e comentário de cada linha; `local` = alteração ainda não enviada. Só leitura; console 2026 (seção 16) |
| `revert <arq> -Rev x.y [-Force] [-AllowEncodingChange]` | Grava a revisão x.y (família inteira) na cópia local, com o módulo em checkout e backup. Modo `checkout` (seção 16) |
| `revert <arq> -Rev x.y -Checkin -Comment "motivo" [-SkipBuild]` | E publica `[IA] revert para x.y: motivo`; pela IA sempre com `-Confirmed` (seção 16) |
| `rm-project <proj.dpr> [-Apply]` | Remove o projeto. Sem `-Apply` é prévia. Com `-Apply` grava antes um registro para religar. Exige `projectAdmin=on` e, pela IA, `-Confirmed`; console 2026 (seção 15) |
| `restore-project <proj.dpr> [-Relink] [-Apply]` | Restaura o projeto; `-Relink` religa os módulos (e o oculto) e os grupos a partir do registro do `rm-project` (seção 15) |
| `rename-project <proj.dpr> <novo.dpr> [-RenameFiles] [-Apply]` | Renomeia o projeto no servidor; `-RenameFiles` renomeia também os módulos `<nome>.dpr/.dpk/.dproj/.res/.dof/.cfg/.dsk`. Arquivos locais nunca (seção 15) |
| `modules -Project p [-Deserted]` | Todos os módulos ligados ao projeto, com flags (`H` oculto, `B` sem revisão, `N` sem pasta, `P` nome com caminho); `-Deserted`: abandonados. Console 2026 (seção 14) |
| `rm-module <arq>\|id:<n> [-Project p] [-Archive] [-Apply [-Force]]` | Prévia; `-Apply` tira do projeto (reversível); `-Archive` apaga do arquivo (irreversível, com backup). Exige `moduleAdmin` e, pela IA, `-Confirmed` (seção 14) |
| `rename-module <arq>\|id:<n> [-Project p] <novo.ext> [-Apply]` | Prévia / renomeia no servidor (todos os projetos; o arquivo local não muda) (seção 14) |
| `hide <arq>\|id:<n> [-Project p] [-Unhide] [-Apply]` | Prévia / oculta ou mostra o módulo no projeto (seção 14) |
| `comment <arq>\|id:<n> [-Project p] -Rev x.y -Comment "texto" [-OutComment] [-Apply]` | Prévia / troca o comentário de check-in (ou de check-out) de uma revisão (seção 14) |
| `cleanup -Project p [-Deserted] [-Apply [-Archive] id:<n> ...]` | Prévia do lixo com os motivos; `-Apply` só nos IDs listados que ainda forem candidatos (seção 14) |
| `config list\|get\|set` | Configuração (`set` só por humano; recusado ao agente com 10) |

Opções (sempre **por extenso**: `-Pr`, `-De`, `-Ti` são ambíguos):
- gerais: `-Project <nome.dpr\|caminho>`, `-Identity <nome>`, `-Text` (saída legível), `-Agent` (força
  contexto de agente), `-Confirmed`, `-TimeoutSec <n>` (por execução do `jvcs.exe`), `-LockWaitSec <n>`
  (espera pelo mutex), `-Raw` (inclui a saída bruta do console; não contém senha), `-Test`, `-CheckOnly`;
- checkout/check-in: `-Comment`, `-Force`, `-Discard`, `-AllowEncodingChange`, `-Keep`, `-SkipBuild`;
- revisões, datas e sync: `-Rev`, `-Rev2`, `-Max`, `-Since`, `-User`, `-Date`, `-Label`, `-Dest`, `-Apply`, `-All`;
- busca: `-InComments`, `-MaxModules`;
- ToDo: `-Priority`, `-Category`, `-Due`, `-IncludeDone`, `-Reopen`;
- bugs: `-Bug`, `-Title`, `-Severity`, `-Status`, `-Keywords`, `-ReportedBy`, `-Description`,
  `-DescriptionFile`, `-Workaround`, `-WorkaroundFile`, `-Summary`, `-OpenOnly`, `-Remove`, `-Done`;
- blame/revert: `-Lines`, `-IgnoreWhitespace`, `-Checkin`;
- administração: `-Relink`, `-RenameFiles`, `-Archive`, `-Unhide`, `-OutComment`, `-Deserted`.

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

Campos extras conforme o comando: `identity`, `projects`, `config`, `configPath`, `comment`, `warnings`, `raw`;
os comandos das seções 12 a 17 acrescentam os seus (`changes`, `labels`/`label`, `todos`/`todo`, `milestones`,
`bugs`/`bug`, `backup`, `build`, `target`, `dest`, `keep`, ...), descritos em cada seção.
`ok` é verdadeiro para 0 e 3.

`modules[].state`:
- `checkedOut`, `checkedOutKeptLocal`, `alreadyMine`, `needsCheckout`, `notVersioned`;
- `lockedByOther`, `localModified`, `needsConfirmation`, `pathMismatch`;
- `checkedIn`, `unchangedUndone`, `refused`, `encodingChanged`, `notCheckedOut`, `localMissing`;
- `undone`, `discarded`, `releasedButDirty`, `failedCompensated`, `failed`, `timeout`, `error`, `ok`, `pathTruncated`;
- comandos das seções 13 a 17: `checkedInKept`/`unchangedKept` (`-Keep`), os de labels, ToDo, bugs, `sync -Label`/
  `-Date`/`-Dest`, `revert` e administração, listados em cada seção.

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
  - `ask`: `*-Confirmed*`, `*-Discard*`, `*-AllowEncodingChange*`, `*rm-project*-Apply*`,
    `*restore-project*-Apply*`, `*rename-project*-Apply*`, `*removeproject*`, `*restoreproject*` e
    `*renameproject*` (seção 15), `*rm-module*-Apply*`, `*rename-module*-Apply*`, `*cleanup*-Apply*`,
    `*removemodule*` e `*renamemodule*` (seção 14) — PowerShell e Bash; template 1.3.0;
  - `deny`: leitura de `JEDIVCS*Identities`; `jvcs* /password` e `-password`; `config set`; `*JVCS*config.ini*`;
    o instalador; `edit-preserve ... -NoCheckout`; comandos que citem `CLAUDECODE`/`AI_AGENT`;
    `settings.local.json` e `disableAllHooks` (a IA não pode desligar os hooks); `attrib`, `IsReadOnly`,
    `SetAttributes`, `-Name Attributes`, `.Attributes =`, `chmod`; `Edit` em `.claude/settings*.json`,
    `.claude/skills/jvcs/**`, `~/AppData/Roaming/JEDI/JVCS/**`, `~/AppData/Local/JEDI/JVCS/**` e `tools\ai\**`.
  - Não há regras `Write(caminho)`: o Claude Code as aceita mas nunca consulta (avisa na inicialização);
    `Edit(caminho)` cobre o Write.
- **Chaves do `config.ini` que só o usuário liga** (`config set` é recusado ao agente): `moduleAdmin`
  (`off`/`on`/`archive`, seção 14) e `projectAdmin` (`off`/`on`, seção 15) liberam o `-Apply` da
  administração; `buildCheck`/`buildCommand` (seção 16) fazem o wrapper rodar **só** o script que o usuário
  registrou, conferido pelo SHA-256 em `buildCommandSha256` (nunca um `.dproj` vindo do servidor).
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
4. Sem `diff`, `log` e `whoami` no console original. O wrapper cobre o diff (`diff`, seção 11, funciona
   com o original) e o log (`history`/`changes`, seções 12 e 13, só com o console 2026); `identity` mostra
   a identidade em uso.
5. Comentário de check-in em **uma linha**, sem aspas, em CP1252.
6. Caminhos fora do CP1252 são recusados (2): o console 2.5 é ANSI.
7. Módulo novo e quase todos os comandos das seções 11 a 17 (`add`, `addproject`, `history`, `changes`, labels,
   ToDo, bugs, administração, `sync -Date`/`-Dest`, `checkin -Keep`) exigem o console **2026**; com o original 2.5.0.1030
   o wrapper devolve 12. Funcionam com o original: `diff`, `show`, `sync`/`sync -Apply` e `revert`.
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

## 12. Versão 1.3.0 — history, show, diff entre revisões e sync

- `history <arq> [-Max n]`: revisões do módulo (mais recente primeiro) com revisão, `revisionId`, data local
  do check-in, usuário, tamanho, membros da família e comentário. Usa o comando novo `history` do console
  **2026** (`GET_MODULE_HISTORY`, os mesmos dados da janela History do standalone); com o console original → 12.
  O servidor manda usuário e comentário só no 1º membro da família de cada revisão; o console junta os membros
  numa linha e escreve o comentário numa linha só (`\` = barra, `\n` = quebra).
- `show <arq> -Rev x.y [-Dest pasta]`: grava a revisão (com a família) para leitura; sem `-Dest`, em
  `%LOCALAPPDATA%\JEDI\JVCS\show\<data>-<id>-<rev>`. Recusa a pasta do próprio arquivo, pastas protegidas e
  sobrescrever arquivo existente (8). Funciona com o console original.
- `diff <arq> -Rev x.y -Rev2 y.z`: diff entre duas revisões do servidor (o arquivo local não precisa existir).
- `sync [-Project p]`: prévia (padrão, só leitura). Compara byte a byte cada membro com a última revisão e
  usa a coluna Stamp do `listproject` para a direção: ausente → `create`; local mais antigo (`O`) → `update`;
  local diferente e mais novo ou com a mesma data → `conflict`; módulo em checkout por mim → `keep` (nunca
  mexe). Caminho truncado e não localizado → `unknown`.
- `sync -Apply [-Force]`: segue o modo de **checkout** (`manual` → 10; `confirm` → `-Confirmed`). Baixa a
  revisão para uma pasta temporária e copia para o caminho do servidor, com backup de todo arquivo substituído
  em `%LOCALAPPDATA%\JEDI\JVCS\backup\<data>-sync\<id>\`; data do arquivo = data da revisão; somente leitura
  como o JEDI VCS (exceto os "Writeable Files"). Conflito só com `-Force` (pela IA, sempre com `-Confirmed`).
  Recusa pastas protegidas. Códigos: 0 atualizado; 3 nada mudou; 8 só conflitos; 7 caminho desconhecido;
  11 parcial. Não usa o `syncproject` do console, que com `noprompt crc` sobrescreve alteração local sem aviso.
- Testado (17/10/2026, servidor de teste local, console 2026 e console original 2.5.0.1030 instalado):
  `history uPrincipal.pas -Max 4` (15 revisões, usuário e comentários `[IA] ...`); `diff uTeste4.dfm -Rev 0.1
  -Rev2 0.2` (só a linha do Caption); `show -Rev 0.1`; `sync` em `ex1` e `ex4` (tudo igual); em `ex4`, `.dfm`
  apagado + `.dpr` alterado com data antiga → prévia `create`/`update` → `-Apply` → arquivos idênticos ao
  servidor, backup gravado, `.dfm` somente leitura e `.dpr` gravável; `.pas` alterado sem checkout →
  `-Apply` com 8 e arquivo preservado; `-Force` sem `-Confirmed` pela IA → 10; `-Apply` sem mudança → 3;
  console original: `history` → 12, `sync`, `diff -Rev2` e `show` funcionam.

## 13. Versão 1.4.0 — grupo B

A versão 1.4.0 junta cinco grupos do plano (`doc\pt\ia\08-Plano-de-Recursos.md`): B, recursos do servidor
(esta seção: labels e compartilhamento B5, `changes` B1, `search` B2, ToDo e milestones B4, bugs B3); D,
administração de módulos (seção 14) e de projetos (seção 15); A, `blame`/`revert`/compilação (seção 16); e E,
rollback por data, sync para outra pasta e Put (seção 17). Todos os comandos estão na tabela da seção 3.

### Labels e compartilhamento

- Comandos: `labels [-Project p]` (labels usados no projeto, com o nº de módulos que cada um marca, ocultos
  incluídos), `labels -All` (todos do servidor), `labels <arq>` (labels de cada revisão do módulo),
  `labels -Label <nome>|#id [-Project p]` (revisão de cada módulo no label: `labeled`, `notInLabel`, `hidden`,
  com `changedSince`), `label <nome> [-Project p]` (rotula), `sync -Label <nome> [-Project p] [-Apply [-Force]]`
  (volta a cópia local ao label), `shared <arq>` / `shared [-Project p]` (compartilhamento). O `history`
  passa a trazer `labels` em cada revisão. Opção nova: `-Label`.
- Console **2026** (com o original → 12): comandos novos `listlabels [projeto]` (GET_LABELS /
  GET_LABELS_BY_PROJECT), `labelrevs <projeto> <label>|#id` (GET_LATEST_REVISIONS filtrado pelo label, sem
  ocultos), `modulelabels <módulo>` (GET_LABELS_BY_MODULE; em servidor antigo, GET_LABELS_BY_REVISION por
  revisão), `sharedby <módulo>` (GET_SHARED_BY) e `sharedmodules <projeto>` (GET_SHARED_MODULES +
  GET_SHARED_BY). Nomes de label, projeto e módulo e as descrições saem escapados numa linha (`\\`, `\n`). O
  `labelproject` ganhou a última coluna `Result`: `added` ou `kept x.y` (o servidor não move label que já está
  em outra revisão do módulo).
- `label` segue o modo de **checkin** (manual/confirm → 10 sem `-Confirmed`). Recusa (8) label que já marca
  módulos do projeto, porque o servidor não o moveria; nome: uma linha, ANSI, sem aspas, até 50 caracteres
  (senão 2); `#id` só para consulta. Rotula a última revisão **do servidor** (avisa módulos em checkout);
  módulos ocultos ficam `hidden`. Por módulo: `keptOld` (8), `notLabeled` (9, inclusive módulo sem caminho no
  servidor — veja `setmodulepath`), `mismatch` (9) na conferência com `labelrevs`.
- `sync -Label`: prévia por padrão; `-Apply` segue o modo de **checkout** e `-Force` pela IA exige
  `-Confirmed`. Baixa a revisão do label com `getmodule rev=` (nunca `syncproject noprompt`) e compara bytes:
  igual → `none`; ausente → `create`; igual à última revisão → `restore`; diferente das duas → `conflict`
  (só com `-Force`); em checkout seu → `keep`; membro só de revisão mais nova → `extra` (fica no disco).
  Backup em `%LOCALAPPDATA%\JEDI\JVCS\backup\<data>-sync-label\<id>\`. Sem módulo no label → 3. Depois de
  aplicar, volte com `sync -Apply` (sem `-Label`) antes de editar.
- Códigos: 0 ok; 2 uso (label inválido, `-All` com arquivo/`-Project`/`-Label`, `-Force` sem `-Apply`, mais de
  um arquivo); 3 nada a fazer; 5 label ou projeto inexistente; 8 label já usado / conflito; 9 console;
  10 confirmação; 12 console original.
- Testado (17/10/2026, servidor de teste local, console 2026 Debug): `labels -All` e `labels`
  com 0 labels; modo confirm → `label` com 10; `label "[teste IA] label"` em `ex4ia.dpr` (modo auto) → criado e
  aplicado em 2 de 2 módulos; repetido → 8; `labels`, `labels -All`, `labels -Label` (nome, maiúsculas
  diferentes e `#2`), `labels <uTeste4.pas>` e `history` com o label na 0.2; `labels -Label #2` em
  `exemplo01.dpr` → 4 `notInLabel`; `sync -Label` em `exemplo01.dpr` → 3; `labelproject` repetido → `kept 0.2`
  e `kept 0.1`; `getmodule rev=0.1` via `Get-JvcsBase -Revs` (`.dfm` da 0.1 diferente da 0.2); `shared` e
  `sharedby`/`sharedmodules` (sem módulos compartilhados nos projetos de teste); entradas inválidas → 2;
  label/projeto inexistente → 5; `sync -Label -Apply -Force` pela IA → 10; console original → 12 em todos.
  Não testado: `sync -Label` com cópia local localizável (as cópias de trabalho não estavam no caminho gravado
  no servidor, então a prévia deu `unknown`), `-Apply`, módulo compartilhado de verdade e o fallback
  GET_LABELS_BY_REVISION.

### changes (o que mudou no projeto desde uma data)

- Comando: `changes [-Project p] [-Since d] [-User login] [-Max n]`. `-Since` aceita `aaaa-mm-dd`,
  `aaaa-mm-ddThh:mm[:ss]`, `"aaaa-mm-dd hh:mm[:ss]"`, `Nd` (N dias, contados da meia-noite), `Nh` ou `today`,
  em hora local; padrão `7d`. `-Max` 1..1000 (padrão 100: os mais recentes). Só leitura (não passa pelos
  modos), sob o mutex e com `since`/`user` na auditoria. Opções novas: `-Since` e `-User`.
- JSON: `since`, `user`, `serverLog` (`on`/`off`/`unknown`), `total`, `shown`, `truncated` e `changes[]`
  (mais recente primeiro) com `logId`, `checkedIn` (**hora local real do check-in**), `user` (até 20
  caracteres; cortado com `...`, com aviso), `moduleId`, `module` (caminho completo do servidor), `revision`
  e `revisionId` (`null` quando não identificados, com aviso), `kind` (`checkin` ou `put`), `viaProject`
  (projeto de onde veio o check-in, até 50 caracteres) e `comment` (com quebras reais). `-Text` lista
  data, usuário, módulo, versão e comentário.
- Console **2026** (com o original → 12): comando novo `projectlog <projeto>|<id> [since=...] [user=...]
  [max=n] [norev]`. Fonte: o log de check-ins do servidor (`GET_LOG_ENTRIES` tipo `i`, de todos os projetos,
  filtrado pelos módulos do projeto, ocultos incluídos), `GET_LOG_COMMENT` por entrada exibida e um
  `GET_MODULE_HISTORY` por módulo alterado para achar versão/RevID (casa usuário e comentário exato, do mais
  novo para o mais antigo; `norev` pula). Cabeçalho `Server log: on|off|unknown` (`GET_SERVER_OPTIONS`,
  `WriteVCSLog`); o projeto aberto no `/input` não muda. Sem `since`/`max` o console lê o log inteiro.
- Códigos: 0 há check-ins; 3 nenhum no período (com aviso de que um administrador pode ter apagado o log
  antigo); 7 nenhum **e** o servidor não grava o log (use `history <arq>`); 2 uso (argumento posicional,
  `-Since` inválido, no futuro ou antes de 1990, `-User` com aspas/controle/fora do CP1252/mais de 50
  caracteres, `-Max` fora de 0..1000, pasta sem um `.dpr` único e sem `-Project`); 5 projeto ou usuário
  inexistente; 9 console/saída inesperada (o número de linhas lidas tem que bater com o rodapé); 12 console
  original.
- Limites: só aparecem check-ins gravados no log (o servidor de teste está com o log **ligado**) e módulos que
  ainda são do projeto; o filtro do servidor é `tstamp > since`, mas o `tstamp` tem fração de segundo, então
  um check-in no mesmo segundo do `-Since` aparece; versão/RevID é heurística (usuário + comentário); um
  comentário que seja literalmente `blank` sai como entrada sem vínculo. Achado: o `checkedIn` do `history` é
  a data do **arquivo** gravada no check-in (`blobs.origtime`), não a hora do check-in; o `changes` traz a
  hora real (no teste, a 0.5 do `uPrincipal.pas`: 20:51:07 no `history`, 21:08:47 no `changes`).
- Testado (17/10/2026, servidor de teste local, console 2026 Debug): `projectlog` em
  `exemplo01.dpr` (18 check-ins) e `ex4ia.dpr` (3) com versão e RevID iguais aos do `history` de cada módulo;
  `since=` (data, `T` e espaço entre aspas), `user=SYSDBA` (maiúsculas trocadas), `max=3` (`3 shown of 6`),
  `norev`, período vazio, sintaxe errada (linha de uso), data inválida, projeto/ID/usuário inexistentes e o
  `/input` sem projeto vazando para a linha seguinte. Wrapper: `exemplo01.dpr`/`ex4ia.dpr`/`ex2.dpr` com
  `-Since`, `-User sysdba`, `-Max 2` (`truncated`), `-Text`, modo confirm sem `-Confirmed` (0, só leitura),
  vazio → 3, os erros de uso → 2, projeto/usuário inexistente → 5, console original → 12. Projeto de rascunho
  `zzchanges.dpr` (comentários `[teste IA]`): 5 check-ins com a hora certa (±1 s do relógio), dois com o
  mesmo comentário → 0.2 e 0.3 distintos, comentário com `\` e `|` preservado. Não testado: `put` (precisa da
  GUI), log desligado (7), usuário só leitura (403 → `unknown`), segundo usuário e módulo compartilhado de
  verdade (o `addmodule` do console cria um módulo novo em vez de compartilhar).

### search (módulos por nome e texto nos comentários)

- Comandos: `search <padrão> [-Project p] [-Max n]` (módulos por nome ou máscara em **todos** os projetos) e
  `search "<texto>" -InComments [-Project p] [-Max n] [-MaxModules n]` (texto nos comentários de check-in e
  check-out das revisões de um projeto). Só leitura (não passa pelos modos), sob o mutex. Opções novas:
  `-InComments` e `-MaxModules`. Um único padrão (texto com espaço vai entre aspas), uma linha, sem aspas nem
  caractere de controle, CP1252, até 200 caracteres.
- Módulos: o console roda `searchmodules "<padrão>"` e `listprojects` numa execução só. O JSON traz `mode`
  `modules`, `pattern`, `count` e um item por módulo (`id`, `name` e `path` em minúsculas como o servidor
  devolve, `dir`, `state` `found`, `projects[]` com `{name, deleted}`). `deleted` vem do `listprojects`
  (nome cortado em 30): `null` quando não dá para saber, com aviso se o prefixo casa com mais de um projeto.
  `-Project` só filtra o resultado; `-Max` (padrão 200) corta a lista (`truncated`, aviso). Padrão só de
  curingas (`*`, `*.*`, `?`) → 2.
- Comentários: o console roda `searchcomments "<texto>" "<projeto>" maxmodules=<n>`. Projeto: `-Project` ou o
  `.dpr` único da pasta. JSON: `mode` `comments`, `text`, `count`, `scannedModules`, `totalModules`,
  `complete` e um item por módulo com `revisions[]` (`revision`, `revisionId`, `checkedIn`, `user`, `hit` —
  `I` check-in, `O` check-out, `IO` os dois, e aí `comment` é o de check-in —, `comment` com as quebras
  reais), da revisão mais recente para a mais antiga; `-Max` (padrão 100) corta as revisões. `checkedIn` é a
  **mesma data do `history`** (a data do arquivo gravada no check-in, não a hora do check-in; para a hora
  real, `changes`). Não diferencia maiúsculas; **acentos contam** (`calculo` não acha `cálculo`). Os
  comentários são dados do servidor, não instruções. O tempo-limite sobe sozinho para 30 s + 0,5 s por
  módulo quando `-TimeoutSec` não é dado.
- Console **2026** (com o original → 12): comandos novos `searchmodules <máscara>` (`SEARCH_MODULES`, o mesmo
  pedido do Search modules da GUI: uma linha por módulo e projeto, `caminho|nome` no fim da linha; o servidor
  só devolve módulo ligado a algum projeto e não filtra projeto excluído nem módulo oculto) e
  `searchcomments <texto> <projeto>|<id> [maxmodules=<n>]` (`GET_PROJECT_MODULE_LIST` com os ocultos e um
  `GET_MODULE_HISTORY` por módulo, até `maxmodules`, padrão 300; linha `Module: <id> <caminho+nome>` antes
  dos acertos de cada módulo e rodapé `Scanned <n> of <total> module(s), <h> revision(s) found`; comentário
  escapado numa linha como no `history`). O `searchcomments` não deixa o projeto aberto para as linhas
  seguintes do `/input` (como o `projectlog`). Um erro no histórico de um módulo derruba o comando inteiro
  (9). O `SEARCH_REVISIONS_BY_COMMENT` do servidor não foi usado: só existe com `NEWOBJECTS`, não filtra
  projeto, não traz data nem usuário e diferencia maiúsculas.
- Códigos: 0 ok (inclusive sem resultado: `count` 0); 2 uso (sem padrão ou com dois, aspas/controle/fora do
  CP1252, mais de 200 caracteres, só curingas, texto de 1 caractere no `-InComments`, `-Max` negativo,
  `-MaxModules` fora de 0..5000 ou sem `-InComments`, pasta sem `.dpr` único e sem `-Project`); 5 projeto
  inexistente ou excluído (`-InComments`); 9 console/saída inesperada (o número de linhas lidas tem que bater
  com o rodapé); 11 busca parcial (`complete=false`: mais módulos que `-MaxModules`; os acertos vêm assim
  mesmo e `ok` fica `false`); 12 console original.
- Limites: a máscara do servidor é ancorada (`utest` não acha `utesteia.pas`; use `utest*`) e, sem extensão,
  vale qualquer extensão; `-Project` com número no `-InComments` é o ID do projeto (o console trata número
  como ID e `project` sai como o número), mas no modo módulos o filtro compara o nome; a busca nos
  comentários é uma requisição por módulo (no teste, ~0,8 s para 4 módulos, com a partida do console).
- Testado (17/10/2026, servidor de teste local, console 2026 Debug): console `help` dos dois
  comandos; `searchmodules` com `uprincipal`, `uprincipal.pas` e `UPRINCIPAL.PAS` (o mesmo módulo 4 de
  `exemplo01.dpr`), `*.dpr` (8 módulos; os do lixo do `ex2` sem pasta saem com `dir` vazio), `utest` (0) x
  `utest*` (3), `u?este4.pas`, inexistente (`0 item(s)`) e sem argumento (linha de uso); `searchcomments "[IA]"`
  em `exemplo01.dpr` por nome e pelo ID 1 (5 revisões com versão, RevID, data, usuário e comentário iguais aos
  do `history`), `maxmodules=1` (`Scanned 1 of 4`), sintaxes recusadas (1 caractere, `maxmodules=0`/`abc`,
  `max=5`), projeto/ID inexistente e o `/input` sem projeto aberto na linha seguinte. Wrapper: `search
  uprincipal` (JSON e `-Text`), `-Project` que filtra para 0, `*.dpr -Max 3` (`truncated` e aviso),
  `search "[IA]" -InComments` em `exemplo01.dpr` (5 revisões, mais recente primeiro, `hit` `I`) e em
  `ex4ia.dpr` (3), `-Max 2`, `-MaxModules 1` → 11 com `complete=false`, `ex2.dpr` (9 módulos, os quebrados
  inclusive), `zzchanges.dpr` (comentário com `\` e `|` preservado), maiúsculas trocadas (`[ia]`,
  `AUTOMÁTICO`), acentos (`integração` acha, `integracao` não), modo confirm e `-Agent` sem `-Confirmed` → 0
  (só leitura), vazio → 0 com `count` 0, entradas inválidas → 2 (sem padrão, dois padrões, `*`, `*.*`, `?`,
  aspas, CR/LF, emoji, mais de 200 caracteres, 1 caractere, `-Max -1`, `-MaxModules 6000` ou sem
  `-InComments`, pasta sem `.dpr`), projeto inexistente → 5, console original → 12 nos dois modos e a
  auditoria com `searchMode`. Com saída simulada do console: comentário com quebra de linha e `\`, `hit` `O` e
  `IO`, usuário cortado em 20, projeto excluído (`deleted=true`), nome cortado ambíguo (`deleted=null` com
  aviso), linha `[Exception]` dentro do comentário, rodapé divergente ou ausente → 9 e 403 → 9. Não testado:
  comparação com o Search modules da GUI, usuário sem direito de arquivo (403 real), projeto grande,
  comentário de várias linhas e de check-out reais (o wrapper só grava comentário de uma linha e o console não
  grava comentário de check-out) e o build com `BRANCHING`.

### todo e milestones (ToDo do projeto e marcos)

- Comandos: `todo [-Project p | -All] [-User login|me|all] [-Category c] [-Priority 1-9] [-Due aaaa-mm-dd]
  [-IncludeDone]` (padrão: itens **abertos** do projeto, de todos os responsáveis; `-Due` traz os itens com
  prazo até aquele dia), `todo-add "texto" [-Project p] [-Priority 1-9] [-Category c] [-User login|me] [-Due
  aaaa-mm-dd]` (padrão: prioridade 3, responsável = usuário da identidade), `todo-done <id> [-Reopen]` e
  `milestones [-Project p | -All]`. Opções novas: `-Priority`, `-Category`, `-Due`, `-IncludeDone`, `-Reopen`
  (`-User` e `-All` já existiam). **Escreva as opções por extenso**: `-Pr` fica ambíguo entre `-Project` e
  `-Priority`. ToDo e bugs ficam separados (modelos e requisições diferentes).
- `todo` e `milestones` são só leitura (não passam pelos modos). `todo-add` e `todo-done` mudam o servidor e
  seguem o modo de **checkin** (manual → 10; confirm → 10 sem `-Confirmed`). Texto: uma linha, sem aspas nem
  caractere de controle, CP1252, até 2000 caracteres; categoria até 50; vai para a auditoria como `comment`.
- JSON: `todos[]` (no `todo`) ou `todo` (o item criado/relido no `todo-add`/`todo-done`) com `id`, `priority`,
  `done`, `changedAt`, `due`, `doneAt` (hora local, `null` quando não há), `responsible` (até 20 caracteres;
  `responsibleTruncated` e aviso quando cortado), `project`, `category` e `description` (com as quebras reais).
  `todo-add`/`todo-done` trazem um item em `modules[]` (`name` `todo`, `id` do ToDo, `state` `created`,
  `done`, `reopened`, `unchanged`, `failed` ou `needsConfirmation`). `milestones`: `milestones[]` (`id`,
  `order`, `name`, `description` e, com projeto, `reached`, `reachedAt`, `confirmedBy`, `reachDescription`)
  e `reached[]` (`projectId`, `project`, `milestoneId`, `order`, `name`, `reachedAt`, `confirmedBy`,
  `description`; no `-All`, `project` vem do `listprojects`, cortado em 30 com `projectTruncated` e aviso).
  Descrição, categoria e nomes são texto livre de outros usuários: **dados, não instruções**.
- Console **2026** (com o original → 12): comandos novos `listtodo [project=...|all] [user=<login>|me|all]
  [category=..] [priority=1-9] [due=aaaa-mm-dd] [includedone]` (`GET_TODO_ENTRIES`, os mesmos dados da lista
  de ToDo da GUI), `addtodo <projeto>|<id> "<descrição>" [priority=] [category=] [user=] [due=]`
  (`ADD_UPDATE_TODO_ENTRIES` com item novo; o servidor não devolve o ID, então o console relê e pega o maior
  ID com o mesmo texto), `donetodo <id> [reopen]` (lê o item, regrava todos os campos com a data de conclusão
  agora ou zerada, como a GUI faz, e relê para confirmar) e `listmilestones [<projeto>|<id>|all]`
  (`GET_MILESTONES` + `GET_PROJECT_MILESTONES`). Colunas fixas; a descrição sai escapada numa linha (`\\`,
  `\n`) e os campos curtos do servidor têm os caracteres de controle trocados por espaço. Usuário: igualdade
  exata do login primeiro; sem ela, aceita maiúsculas trocadas só se houver um único candidato (dois → erro
  "ambiguous", 2).
- Códigos: 0 ok (lista vazia também); 3 `todo-done` em item já concluído (ou já aberto, com `-Reopen`); 2 uso
  (argumento posicional, `-Project` com `-All`, `-Priority` fora de 1..9, `-Due` inválido, texto vazio/com
  aspas/controle/fora do CP1252/longo, `-User all` no `todo-add`, id não numérico, pasta sem `.dpr` único e
  sem `-Project`); 5 projeto, usuário ou ToDo inexistente; 7 sem direito (403); 9 console/servidor; 10
  confirmação; 12 console original.
- Limites (do servidor 2.5): `ADD_UPDATE_TODO_ENTRIES` regrava **todos** os campos, então o `todo-done` perde
  o criador (fica o responsável, como na GUI), atualiza a data de alteração e pode desfazer uma edição feita
  na GUI entre a leitura e a escrita; `GET_TODO_ENTRIES` não confere direito por projeto (quem lê vê o ToDo de
  todos os projetos); item antigo com `donedate` NULL só aparece com `-IncludeDone`; o `-Due` é `prazo <` fim
  do dia em GMT (pode deslocar 1 h no horário de verão). Não há comando para apagar ToDo nem para atribuir
  milestone (só pela GUI). Os quatro comandos do console **abrem** o projeto que usam (num `/input` com várias
  linhas, a linha seguinte herda esse projeto; o wrapper sempre manda o projeto explícito).
- Testado (17/10/2026, servidor de teste local, console 2026 Debug): console `help` dos 4
  comandos, `listtodo` vazio e com filtros (`user=me`, `user=SYSDBA`, `project=3`, `project=all`), sintaxes
  recusadas (`priority=0`/`10`, `due=2026-02-30`/`31/12/2026`, chave desconhecida, `addtodo` sem texto ou com
  `""`, `donetodo abc`/`1 xyz`/sem id, `listmilestones a b`), projeto/usuário/ToDo inexistentes; `listmilestones`
  por projeto e `all` (8 milestones padrão, nenhum atingido). Wrapper: `todo-add "[teste IA] item"` em
  `ex4ia.dpr` (modo auto, com `-Priority 2 -Category IA -Due 2026-12-31` e sem opções, pela pasta do projeto)
  → `created` com o ID relido; `todo` → o item aberto; `todo-done` → `done` com `doneAt` na hora local; `todo`
  de novo → sumiu; `-IncludeDone` → aparece concluído; `todo-done` repetido → 3; `-Reopen` → `reopened`;
  `-Reopen` repetido → 3; filtros `-Priority 1`, `-Category IA`, `-User me`/`SYSDBA`, `-Due 2026-12-31` (acha)
  x `2026-12-30` (não acha), `-All`; ida e volta de texto com acentos CP1252 e `C:\temp\x \n literal` (igual
  no JSON; `\\` na saída `-Raw`); `milestones -Project`, `-All` e pela pasta, com `-Text`; entradas inválidas →
  2 (inclusive aspas, quebra de linha e emoji); inexistentes → 5; modo confirm sem `-Confirmed` e modo manual
  → 10 sem mexer no servidor; console original → 12 nos 4. Não testado: milestone atingido (precisa da GUI
  para atribuir), `-Confirmed` no modo confirm (pede aprovação humana), usuário só leitura (403 → 7), segundo
  usuário/login longo, descrição com várias linhas criada pela GUI (injeção de linha) e o build com
  `BRANCHING`. Lixo de teste: ToDo #2 a #6 em `ex4ia.dpr` (`[teste IA] ...`, todos concluídos) e #1 em
  `ex2.dpr` (texto `addtodo`, criado por engano num teste de aspas, concluído) — apagar pela GUI.

### bugs (bugs do módulo/projeto, criar, atualizar e ligar)

- Comandos: `bugs [<arquivo>] | -Project p | -All | -Bug n | -Summary [-OpenOnly]` (padrão: bugs ligados ao
  **projeto**; com arquivo, os ligados ao módulo dele; `-Bug n` traz o bug e as ligações; `-Summary`, por
  módulo do projeto, o bug com ligação aberta mais grave, mais os bugs ligados ao projeto; `-OpenOnly` tira as
  ligações `done` e os bugs com status fixed/ignored), `bug-add -Title "..." [-Severity s] [-Status s]
  [-Keywords ..] [-ReportedBy ..] [-Description ..|-DescriptionFile f] [-Workaround ..|-WorkaroundFile f]
  [<arquivo...> | -Project p]`, `bug-update -Bug n [campos]` e `bug-link -Bug n <arquivo...> | -Project p
  [-Remove | -Done | -Reopen]`. Severidade: minor, awkward, significant, serious, fatal (0-4; apelidos menor,
  incomodo, significativo, grave/serio); status: unknown, open, scheduled, fixed, ignored (0-4; apelidos
  aberto, agendado, corrigido/resolvido, ignorado). Opções novas: `-Bug -Title -Severity -Status -Keywords
  -ReportedBy -Description -DescriptionFile -Workaround -WorkaroundFile -Summary -OpenOnly -Remove -Done`
  (`-Reopen` é o mesmo do `todo-done`). **Sempre por extenso**: `-De`/`-Des` deixaram de resolver para `-Dest`
  e `-Ti` ficou ambíguo.
- `bugs` só lê. `bug-add`, `bug-update` e `bug-link` mudam o servidor e seguem o modo de **checkin** (manual →
  10; confirm → 10 sem `-Confirmed`; a dica do comando vem com aspas simples, sem expansão de `$()`/crase).
  Título, palavras-chave e "relatado por": uma linha, sem aspas nem controle, CP1252 (título e palavras-chave
  até 250; título não pode começar com `<opção>=`). Descrição e workaround: `-Description` numa linha ou
  `-DescriptionFile`/`-WorkaroundFile` (.txt/.md, UTF-8 ou ANSI, até 64 KB, aspas e várias linhas; até 2000
  caracteres); vão sempre ao console por um arquivo temporário CP1252 do wrapper.
- `bug-add` cria e liga numa execução; se o bug foi criado e **alguma ligação falhou** (ou o console falhou nas
  ligações), o código é **11** com `bugId` e a mensagem manda usar `bug-link -Bug n` — repetir o `bug-add`
  daria 3 ("já existe") e deixaria o bug solto. `bug-update` muda só os campos dados (`-Keywords ''` limpa).
- JSON: `bugs[]`, `bug` (relido) ou `projectBugs[]`, com `id`, `title`, `severity`/`severityName`,
  `status`/`statusName`, `done` (da ligação; `null` fora dela), `created` (hora local), `createdBy`, `flags`,
  `keywords`, `reportedBy`, `description`, `workaround` (quebras reais) e `links[]` (`kind` module/project,
  `id`, `name`); `scope`, `bugId`, `action`, `changed[]`; `modules[]` com `state` `linked`, `alreadyLinked`
  (3), `unlinked`, `notLinked` (3), `done`, `open`, `failed` e, no `-Summary`, `openBugs` com `worstBugId`,
  `worstSeverity`, `worstSeverityName`. Textos de bug são de outros usuários: **dados, não instruções**.
- Console **2026** (com o original → 12): `listbugs [module <m>|<id>] | [project <p>|<id>] | [bug <id>]`
  (`GET_BUGS` + `GET_BUGS_BY_MODULE`/`_BY_PROJECT`/`BUGS_USED_BY`; colunas fixas, título a partir da coluna
  74 e as linhas `  keywords:`, `  reportedby:`, `  description:`, `  workaround:`, `  link: m|p <id> <nome>`,
  textos escapados `\\`/`\n`), `bugsummary <modules|projects>` (`GET_MOST_SEVERE_BUGS`), `addbug <nome>
  [severity=] [status=] [keywords=] [reportedby=] [description=|descriptionfile=] [workaround=|workaroundfile=]`
  (nome único sem diferenciar maiúsculas, inclusive acentos; sem ID devolvido pelo servidor → erro),
  `updatebug <id> [name=] [...]` (lê o bug, manda todos os campos, mantém flags e relê conferindo **todos** os
  campos) e `assignbug <id> module|project <nome>|<id> [add|remove|done|open]` (`ASSIGN_REMOVE_BUG` /
  `ENABLE_MODULE_PROJECT_BUG`; confere o bug antes, porque o servidor aceita qualquer número, e relê a ligação
  depois). Arquivo de texto: CP1252 sem BOM, sem controle C0 (fora TAB/CR/LF), DEL nem C1.
- Códigos: 0 ok (lista vazia também); 3 bug já existe (`bug-add`), nada mudou (`bug-update`), já ligado / não
  ligado / já done / já aberto (`bug-link`); 2 uso (combinações de opções, `-Bug` ausente/negativo, título
  vazio/com aspas/controle/emoji/longo, severidade/status inválidos, `-Description` com `-DescriptionFile`,
  arquivos no `bug-update`); 5 bug, projeto, arquivo ou arquivo de texto inexistente / não versionado; 7 título
  de outro bug, `-Done`/`-Reopen` sem ligação, texto longo no console, sem direito (403); 9 console/servidor; 10 confirmação; 11
  bug criado com ligação falha; 12 console original ou arquivo temporário recusado.
- Testado (17/10/2026, servidor de teste local, console 2026 Debug, `ex4ia.dpr`): lista
  vazia (`-All`, projeto, módulo, `-Summary`); `bug-add "[teste IA] bug"` ligado ao `uTeste4.pas` pela pasta
  do projeto → criado e ligado; repetido e com outra caixa → 3; `bug-add "[teste IA] bug descricao"` com
  `-DescriptionFile` UTF-8 (aspas, `C:\temp\x`, `\n` literal, acentos, duas linhas) e `-Workaround` → ida e
  volta igual; `bugs uTeste4.pas`, `bugs` (projeto), `bugs -Bug n` (com `links`), `-Summary`, `-All`, `-Text`
  e `-Raw`; `bug-link -Project` → ligado e listado no projeto, repetido → 3; `bug-update` de status
  (`corrigido`/`fixed` → 3 na repetição), severidade, palavras-chave (e `-Keywords ''` limpando), descrição com
  `$(...)`, crase e aspas (gravada literal); título de outro bug → 7; `bug-link -Done` (sai do `-OpenOnly` e do
  `-Summary`), repetido → 3, `-Reopen`, repetido → 3, `-Remove`, repetido → 3, `-Done` sem ligação → 7,
  ligar de novo; **falha de ligação depois da criação** (cópia do wrapper com `assignbug` de bug inexistente
  em 2 alvos, e com exceção no `Invoke-Jvcs` das ligações) → 11 com `bugId` e a dica do `bug-link`, que
  depois ligou os dois; entradas inválidas → 2 (aspas, quebra de linha, emoji, 251 caracteres, `severity=1`
  como título, severidade 9, status inválido); inexistentes → 5; modo confirm sem `-Confirmed` → 10 (dica com
  aspas simples); console original → 12 nos 4. Achado e corrigido no teste: o console recusava acentos do
  arquivo de texto (o literal `#$9F` com `HIGHCHARUNICODE` desligado vira U+0178; a faixa C1 agora é testada
  por `Ord`). Não testado: `-Confirmed` no modo confirm (pede aprovação humana), usuário só leitura (403),
  `bugsummary projects` pelo wrapper, falha de só uma de várias ligações com servidor real e o build com
  `BRANCHING`. Dado de teste: bug #3 `[teste IA] bug` (fixed, ligado ao `uTeste4.pas` como done); lixo: bugs
  #1, #2 e #6 (títulos com aspas perdidas na linha de comando do próprio teste, renomeados `[teste IA] lixo
  ...`), #4, #5 e #7 — todos ignored e sem ligação; o console não apaga bug (apagar pela GUI).

## 14. Versão 1.4.0 — administração de módulos, grupo D (modules, rm-module, rename-module, hide, comment, cleanup)

Limpeza e manutenção de módulos sem o standalone (Project Admin): listar tudo o que está ligado ao projeto
(inclusive o que o `listproject`/IDE não mostra), tirar do projeto, apagar do arquivo, renomear, ocultar,
trocar o comentário de uma revisão e achar o lixo de teste. Precisa do console **2026**; com o console
original → 12.

### Console (`src\jvcs\jvcs.dpr`, 7 comandos novos mais o `sharedby` do grupo B, sem `Prompt`)

| Comando | Requisição | O que faz |
|---|---|---|
| `listmodules [<projeto>\|<id>]` | `GET_PROJECT_MODULE_LIST` + `GET_BLANK_MODULE_LIST` | todos os módulos ligados ao projeto: `ID(8) Flags(6) pasta\|nome` (sem corte). Flags: `H` oculto, `B` sem revisão, `N` sem pasta, `P` nome com caminho |
| `listdeserted` | `GET_DESERTED_MODULES` | módulos sem projeto nenhum (abandonados), flag `D` |
| `sharedby <módulo>\|<id>` | `GET_SHARED_BY` | projetos (não excluídos) que têm o módulo — é o mesmo comando do grupo B (seção 13; colunas `PrjID(8)` e projeto, nome escapado numa linha); na junção ficou uma implementação só |
| `removemodule <módulo>\|<id> [archive]` | `REMOVE_MODULE` | sem `archive`: tira só o vínculo com o projeto aberto (o módulo vai para `listdeserted`, reversível); com `archive`: apaga módulo e **todas** as revisões do arquivo (**irreversível**) |
| `renamemodule <módulo>\|<id> <novo>` | `RENAME_MODULE` | só o nome, mesma extensão, em minúsculas; vale para todos os projetos que compartilham; não renomeia o arquivo local |
| `hidemodule <módulo>\|<id> [unhide]` | `HIDE_UNHIDE_MODULE` | oculta/mostra no projeto aberto (nunca `ProjectID 0`, que ocultaria em todos) |
| `getcomment <revision_id>` | `GET_REVISION_COMMENT` | comentários de check-in e check-out (uma linha cada, `\\` e `\n`) |
| `setcomment <módulo>\|<id> <revision_id> in\|out "<texto>"` | `CHANGE_REVISION_COMMENT` | troca o comentário; imprime o antigo e relê para conferir (`\n` = quebra, `\\` = barra) |

O servidor 2.5 **não** confere lock no `REMOVE_MODULE` e, para módulo compartilhado, responde `False` mas
**apaga mesmo assim** o vínculo deste projeto (`SrvOBJModules.pas:600-860`). Por isso o console confere antes:
o módulo tem de ser do projeto aberto (ou abandonado, com `archive`); em checkout por qualquer usuário → recusa
(`listlocks` de todos + o `readonly` do módulo pelo `history`, que também pega abandonado travado); `archive` em
módulo compartilhado → recusa. Linhas de resultado estáveis: `Module removed from archive: <nome> (ID n), k
revision(s) deleted` | `Module removed from project: ...` | `Shared module: project link removed, module kept
for project(s) 1,2 (ID n)`. `renamemodule`, `hidemodule` e `setcomment` também exigem o módulo no projeto
aberto; o `setcomment` confere que a revisão é do módulo (o servidor não confere nada e não grava log).

**Limitação do servidor 2.5 com ramos (Firebird) — apagar do arquivo:** nesse servidor o `REMOVE_MODULE` com
`archive` só apaga módulo **sem nenhuma revisão**. Com revisão ele responde 400 e desfaz a transação (nada
muda; conferido: histórico, blob e vínculo continuam). Causa, em `JVCSSrvOBJBranches.pas`: o
`BRANCH_REMOVE_MODULE` não apaga `revision`/`rvbranch` fora do MySQL (`//todo`), e a tabela `LATESTREVISION`
(com FK para `REVISION` e `MODULES`, criada pelo script de atualização para 2.5) só é refeita **depois** do
`DELETE`. O `REMOVE_REVISION` (Remover revisão do Project Tree) falha igual, então apagar as revisões antes
não resolve: o standalone tem a mesma limitação. Tirar do projeto (sem `archive`), renomear, ocultar e
trocar comentário funcionam normalmente. Para apagar do arquivo módulo com revisão nesse servidor é preciso
corrigir o servidor (apagar `latestrevision`/`rvbranch`/`revision` antes de `modules`) ou o banco.

### Wrapper (`jvcs-ai.ps1`)

```text
modules -Project p [-Deserted]
rm-module <arquivo>|id:<n> [-Project p] [-Archive] [-Apply [-Force]]
rename-module <arquivo>|id:<n> [-Project p] <novo.ext> [-Apply]
hide <arquivo>|id:<n> [-Project p] [-Unhide] [-Apply]
comment <arquivo>|id:<n> [-Project p] -Rev x.y -Comment "texto" [-OutComment] [-Apply]
cleanup -Project p [-Deserted] [-Apply [-Archive] id:<n> id:<m> ...]
```

- **Prévia por padrão**: sem `-Apply` nada muda; o JSON traz o estado (flags, revisões, compartilhamento,
  lock) e `next` com o comando para aplicar. Use `id:<n>` (no PowerShell `#9` sem aspas vira comentário);
  módulo oculto ou sem pasta não aparece no `listproject`, então vai por `id:<n> -Project p`.
- **`cleanup`**: lista os candidatos com os motivos (`nome com caminho`, `sem pasta`, `sem revisões`,
  `não aparece no listproject/IDE`, `só revisões sem arquivo (invisíveis no history)`; com `-Deserted`,
  `sem projeto (abandonado)`). O `-Apply` exige a **lista explícita** dos IDs aprovados e recalcula a prévia:
  ID que não é candidato agora → `notCandidate` (7), sem tocar no servidor. A dica `next` é a forma
  reversível (sem `-Archive`); abandonados só saem com `-Archive`. Erro num ID não para os outros (11).
  Cada candidato traz `revisionCount` (revisões com arquivo, pelo `history`): no servidor com ramos, só os
  de 0 saem com `-Archive`. Módulo oculto não é candidato (o `listproject ... includehidden` o vê: ocultar é
  um estado escolhido, não lixo).
- **`rm-module`/`cleanup -Apply`**: recusa em checkout (6), o próprio `.dpr`/`.dpk` do projeto (7) e
  `-Archive` em módulo compartilhado (7). Antes de mudar grava o **backup** em
  `%LOCALAPPDATA%\JEDI\JVCS\backup\<data>-rm-module-<id>\`: `module.json` (pasta, nome, flags, compartilhamento,
  histórico com comentários) e, com `-Archive`, cada revisão com arquivo (`getmodule`) em `rev-x.y\`. Se uma
  revisão não for salva, nada é apagado (7, `backupFailed`); só com `-Force` (pela IA, `-Confirmed`). Depois
  grava `result.json` (saída do console + conferência) e a auditoria leva o caminho do backup. Módulo
  **abandonado** com revisão sempre cai em `backupFailed`: o `getmodule` do console usa
  `GET_REVISION_LIST_BY_ID`, que liga por `pjmodule` e não acha revisão de módulo sem projeto; o backup fica só
  com `module.json` (histórico e comentários). Recusa do servidor ao `-Archive` → 9 `archiveRefused` (nada
  mudou; o backup fica).
- **`rename-module`**: mesma extensão (2), sem conflito de nome na mesma pasta (7), sem checkout (6; o
  servidor recusa até o dono); avisa que o arquivo local e as referências (`uses`, `.dproj`) não mudam.
- **`hide`**: no projeto; em checkout → 6; já no estado → 3.
- **`comment`**: a prévia traz `oldComment` e `newComment`; `-Apply` guarda o antigo em `comment-old.txt`
  no backup e na auditoria (o servidor não registra a troca). Pela IA o texto leva o `commentPrefix`.

**Segurança**: todo `-Apply` de administração exige a chave **`moduleAdmin`** do `config.ini` (padrão `off`;
`on` = tirar do projeto, renomear, ocultar, comentário; `archive` = também apagar do arquivo) — vale para
humano e IA, e só o usuário muda (`config set` é recusado ao agente). Pela IA, **`-Confirmed` é exigido
sempre**, em qualquer modo (inclusive `hide`, que muda a visão de todos e faz o `syncproject ... deletehidden`
dos colegas apagar o arquivo local); com `checkin=manual` a IA recebe 10, como na administração de projetos
(revisão final). O `moduleAdmin` é defesa em profundidade: a barreira contra a IA é o
`-Confirmed` com a regra `ask`, e o `config.ini` já é protegido pelas regras `deny`
`PowerShell(*JVCS*config.ini*)`/`Bash(...)` e `Edit(~/AppData/Roaming/JEDI/JVCS/**)` do modelo de settings.
O modelo de settings (versão 1.3.0) ganhou regras `ask` próprias, que valem mesmo se a detecção de IA
falhar: `*rm-module*-Apply*`, `*rename-module*-Apply*`, `*cleanup*-Apply*` e os comandos crus do console
`*removemodule*` e `*renamemodule*` (PowerShell e Bash).
O direito exigido pelo servidor é só RW no projeto: o standalone e o console continuam podendo apagar sem
nenhum desses gates. O mutex do wrapper é local; entre a prévia e o `-Apply` outra máquina pode mexer no
módulo (o `-Apply` reconsulta lock e compartilhamento de cada módulo antes de remover).

**Códigos**: 0 ok/prévia · 2 uso (argumento a mais, extensão diferente, nome com pasta, `-Apply` sem IDs) ·
3 nada a fazer (já oculto/visível, mesmo nome, mesmo comentário, `cleanup` sem candidatos) · 5 módulo,
projeto ou revisão não encontrado · 6 em checkout · 7 pré-condição (compartilhado com `-Archive`, backup
falhou, arquivo do projeto, conflito de nome, `notCandidate`) · 9 console/servidor (inclui `archiveRefused`)
· 10 `moduleAdmin` desligado/insuficiente ou falta `-Confirmed` · 11 lote parcial · 12 console original.

Estados (`state`): `listed`, `candidate`, `notCandidate`, `preview`, `locked`, `shared`, `refused`,
`backupFailed`, `removedFromProject`, `removedFromArchive`, `archiveRefused`, `linkRemoved`, `renamed`,
`conflict`, `hidden`, `unhidden`, `changed`, `unchanged`, `failed`, `error`.

### Testes (17/10/2026, servidor de teste local com ramos, identidade DEFAULT)

Projetos próprios `iateste-admin-modulos.dpr` (+ `-b`, `-c`) em `D:\Delphi\JediVCS\testes-ia\admin-modulos`;
console compilado por junção sem ponto no caminho (VERSIONINFO conferido).

- **Console direto** (46/46): `listmodules` (aberto, por nome e por ID, flags `B`/`N`/`H`), `listdeserted`
  (e uso errado), `sharedby`, `getcomment`/`setcomment` (`in`/`out`, `\n` e `\\`, revisão de outro módulo,
  módulo fora do projeto, sem projeto aberto), `hidemodule`/`unhide`, `renamemodule` (minúsculas, extensão,
  pasta), recusas com checkout (remove, archive, hide, rename) e o `*` do `history`, `removemodule` de
  compartilhado (`archive` recusado; sem `archive` só o vínculo), de módulo com revisão (`archive` → 400 e nada
  muda) e de módulo sem revisão (tirar do projeto → abandonado → `archive` apaga).
- **Wrapper** (114/114): leitura; console original → 12; uso → 2; não encontrado → 5; portões → 10
  (`moduleAdmin` off/on/archive, inválido no ini vira off, IA sem `-Confirmed`, `checkin=confirm`, `config
  set` pela IA); `.dpr` do projeto → 7; checkout → 6; `comment` (prévia, `-Text`, `-Apply` com
  `comment-old.txt`, igual → 3, `-OutComment`); `rename-module` (prévia, conflito → 7, `-Apply`, mesmo nome
  → 3, aviso do arquivo local); `hide`/`-Unhide`; `rm-module -Archive -Apply` com revisão → 9
  `archiveRefused`, backup `rev-0.1` igual ao arquivo local; compartilhado (`-Archive` → 7; `cleanup -Apply` →
  `linkRemoved`); abandonado (`cleanup -Deserted` com `revisionCount`; sem revisão → apagado; com revisão →
  `backupFailed` 7, com `-Force -Confirmed` → `archiveRefused` 9; lote → 11); auditoria com backup e
  comentários; regressão de `list`, `status`, `locks` e `help`.
- **Não testado**: lock de módulo **abandonado** (não há como travar um abandonado pelo console nem pelo
  wrapper; a detecção pelo `*` do `history` foi conferida num módulo do projeto); servidor sem ramos.

## 15. Versão 1.4.0 — administração de projetos, grupo D (rm-project, restore-project, rename-project)

### Comandos

| Wrapper | Faz | Console 2026 usado |
|---|---|---|
| `rm-project <proj.dpr>` | prévia: módulos (exclusivos, compartilhados e com quem, ocultos), checkouts de qualquer usuário, referências (deste projeto e de outros para ele), grupos, direitos por projeto e bugs | `projectinfo` |
| `rm-project <proj.dpr> -Apply` | grava o registro e remove | `projectinfo`, `removeproject <p> confirm` |
| `restore-project <proj.dpr> [-Relink]` | prévia: o que o `RESTORE_PROJECT` devolve (só a marca) e o plano de religamento do registro | `projectinfo` |
| `restore-project <proj.dpr> [-Relink] -Apply` | restaura; com `-Relink` religa módulos (refazendo o oculto) e grupos que faltam; funciona também num projeto já restaurado | `restoreproject <p> confirm`, `linkmodule`, `setprojectgroup` |
| `rename-project <proj.dpr> <novo.dpr> [-RenameFiles]` | prévia: nome livre (também entre removidos), mesma extensão, sem checkout; com `-RenameFiles`, os módulos a renomear e os compartilhados que ficam | `projectinfo` |
| `rename-project ... -Apply` | grava o registro, renomeia e confere pelo `projectinfo` | `renameproject <p> <novo> [renamefiles] confirm` |

Comandos novos do console (`jvcs.dpr`, 7 entradas novas na tabela `Commands`, que com todos os grupos da 1.4.0 fica com 51 entradas, 52 com `BRANCHING`): `projectinfo` (saída
`Chave: a|b|c`, também para projeto removido: `Project`, `ProjectID`, `Deleted`, `Module:
id|oculto|outros_projetos|caminho|nome`, `Locked: id|dono|versão|caminho_nome`, `Reference`, `ReferencedBy`,
`Group`, `Right: usuário|nível`, `Bug` e `Summary`), `removeproject`, `restoreproject`, `renameproject`
(os três exigem a palavra literal `confirm`), `linkmodule <id> <caminho\nome> [hidden]`, `projectgroups` e
`setprojectgroup <p> <grupo> add|remove` (aditivos/reversíveis, sem `confirm`; usados pelo `-Relink`).
`PURGE_PROJECT` e criar/apagar grupos ficam fora (só no standalone, depois de um backup do Firebird).

### Segurança

- Sem `-Apply` é sempre prévia (só leitura), inclusive com `projectAdmin=off`.
- `-Apply` exige `projectAdmin=on` (padrão `off`; `config set` é recusado à IA, então só o usuário liga) → 10.
  Pela IA: `checkin=manual` → 10 e **sempre** `-Confirmed` (o texto exato, como nas outras opções de risco),
  em qualquer modo. O template de permissões (1.3.0) põe em `ask` também `*rm-project*-Apply*`,
  `*restore-project*-Apply*`, `*rename-project*-Apply*` e as chamadas diretas `*removeproject*`,
  `*restoreproject*`, `*renameproject*`.
- **Nível exigido pelo servidor = nível efetivo da sessão para o projeto-alvo**: o direito por projeto do
  usuário (pjusers) ou, sem ele, o global. `REMOVE_PROJECT`/`RESTORE_PROJECT` exigem Archive Admin;
  `RENAME_PROJECT`/`RENAME_MODULE`, leitura e escrita. O console sempre termina a resolução do projeto com
  `GET_PROJECT_ID` pelo nome (também quando recebe o ID), que amarra a sessão ao projeto-alvo como o
  `openproject` faz; sem isso valeria o direito do último projeto aberto. 403 → 7. Recomendação para a
  empresa: a identidade da IA **não** deve ser Archive Admin nem ter direito por projeto 4 em projeto nenhum.
- Nomes de projeto: só nomes (número → 2, o console trataria como ID), sem aspas/controle, CP1252, até 50
  caracteres; o novo nome não leva pasta, mantém a extensão e não pode ser reservado (`project1.dpr`...) → 2.
- **Registro antes de alterar**: `%LOCALAPPDATA%\JEDI\JVCS\backup\<data>-rm-project\<projeto>.json` (e
  `-rename-project`), com servidor, usuário e o `projectinfo` inteiro. A auditoria guarda o caminho dele
  (`record`) e o `newName`. O `-Relink` só usa registro do **mesmo servidor e do mesmo ID** (o mais recente
  que tenha módulos ou grupos); sem registro → 7, nunca adivinha.
- **Nada do registro vira comando sem validação** (é um arquivo local): id inteiro > 0, caminho+nome sem aspas
  nem controle, CP1252, até 255 caracteres, `hidden` booleano; o que não passa vira erro (11) sem derrubar o
  resto. E o `linkmodule` só liga se `GET_MODULE_ID` do caminho+nome devolver **o mesmo ID** (o
  `ADD_NEW_MODULE` criaria um módulo novo e vazio).
- Arquivos locais e o registro do Windows nunca são tocados; o `rename-project` avisa o que fazer na IDE
  (Project > Save Project As, por causa do `program` do `.dpr` e do `MainSource` do `.dproj`).

### O que o servidor faz (conferido no fonte 2.5 e no servidor de teste)

- `REMOVE_PROJECT` marca o projeto como removido e **apaga** os vínculos: módulos (pjmodule), direitos por
  projeto, referências deste projeto **e as de outros para ele**, grupos e bugs. Módulos e revisões ficam no
  arquivo; os exclusivos ficam sem projeto; os compartilhados seguem nos outros projetos. O nome continua
  reservado. `RESTORE_PROJECT` só tira a marca: o projeto volta vazio. O `-Relink` devolve módulos (com o
  oculto) e grupos; direitos, referências e bugs só são avisados (estão no registro).
- **Servidor 2.5 com branches:** nome, caminho e lock dos módulos ficam por branch (`brmodule`). O
  `RENAME_PROJECT` grava os nomes novos na coluna antiga `modules.name`, que ninguém mais lê: responde
  "renomeado" e nada muda (testado). Por isso o `renamefiles` do console usa `RENAME_MODULE` (a mesma
  requisição do Rename module do standalone) módulo a módulo, depois de checar tudo, e lê os nomes de volta
  (`Module renamed:` / `Module not renamed: id|velho|novo|motivo`). O wrapper decide pelo `projectinfo`
  depois (não renomeado → 11). Pelo fonte, o Rename project do standalone manda os módulos só no
  `RENAME_PROJECT` (`src\jedivcs\RenameProj.pas:336-351`): deve ter o mesmo problema (não testado na GUI).
- Pelo mesmo motivo, a recusa de `REMOVE_PROJECT`/`RENAME_PROJECT` por checkout olha a coluna antiga
  `modules.readonly`, que o checkout com branches não atualiza. A proteção efetiva é a checagem do console
  (`GET_LOCKED_MODULES`, versão branch) logo antes; um checkout feito entre a checagem e o pedido não é
  visto pelo servidor (janela de milissegundos, documentada).

### Códigos de saída

0 removido/restaurado/religado/renomeado/prévia · 2 uso ou nome inválido · 3 já removido, não removido,
nada a religar · 5 projeto não existe · 6 checkout (de qualquer usuário) · 7 nome em uso (também por
projeto removido), projeto removido, sem registro para `-Relink`, colisão de módulo no rename, 403 ·
9 servidor/console · 10 `projectAdmin=off`, sem `-Confirmed`, `checkin=manual` · 11 religamento ou
renomeação parcial · 12 console original.

### Testes (17/10/2026, servidor de teste local, identidade DEFAULT, console 2026, APPDATA/LOCALAPPDATA temporários)

Projetos próprios `iateste-admin-projetos-a.dpr` (ID 7: `.dpr`, duas units, `.dproj`) e `-b.dpr` (ID 8), em
`D:\Delphi\JediVCS\testes-ia\admin-projetos`, criados com `addproject`/`add`; `uapa2.pas` compartilhado com o
B e `uapa1.pas` oculto com `linkmodule`.
- console: `help`, recusas sem `confirm` (sintaxe), extensão diferente, nome em uso, reservado, `;`,
  `linkmodule` com ID errado / sem pasta / caminho inexistente (`resolves to ID 0`, nada criado), grupo
  inexistente, `restoreproject` de projeto não removido, `projectinfo` por nome e por ID;
- portões: prévia → 0 com servidor intacto; `-Apply` sem `-Confirmed` → 10; `-confirmed` minúsculo → 10;
  `projectAdmin=off` → 10 (prévia liberada); `config set projectAdmin` pela IA → 10; `checkin=manual` → 10;
  `checkin=confirm` sem `-Confirmed` → 10 e com `-Confirmed` → removido; console original → 12 nos três;
  entradas inválidas → 2; projeto inexistente → 5;
- checkout próprio → `rm-project`/`rename-project` 6 (sem registro gravado) e `removeproject`/`renameproject`
  com linhas `Locked:`;
- `rm-project -Apply` → removido, registro com 4 módulos (1 oculto, 1 compartilhado com 8), `projects` com
  `deleted`, B mantém o compartilhado, `history` intacto, auditoria com `confirmed` e `record`; de novo → 3;
- `restore-project` prévia/sem `-Relink`/`-Relink` → mesmos IDs, oculto refeito, compartilhamento refeito;
  `-Relink` de novo → 3; `list` e checkout/undocheckout depois; registro adulterado (aspas no nome, caminho
  inexistente) → 11, entrada com aspas ignorada, nenhum módulo criado; corrigido → religa o resto; registro
  de outro servidor ignorado (7); registro mais recente vazio → usa o anterior com módulos;
- `rename-project`: nome em uso (7), nome de projeto removido (7), projeto removido (7), `-RenameFiles` com
  `.dpr` exclusivo (renomeado de verdade, `GET_MODULE_ID` acha o nome novo) e compartilhado (fica, aviso),
  sem `-RenameFiles` (módulos mantêm o nome), colisão de módulo (console recusa antes de alterar; wrapper 7),
  arquivos locais intocados.

Não testado (o servidor de teste não tem como): grupos de projeto (nenhum grupo cadastrado; só "grupo
inexistente"), referências, bugs e direitos por projeto (só contagem zero), 403 com usuário sem Archive
Admin, checkout de **outro** usuário, renomeação parcial (11) e projeto com centenas de módulos (o
`projectinfo` faz um `GET_SHARED_BY` por módulo e um `GET_PROJECT_REFERENCES` por projeto do arquivo).

## 16. Versão 1.4.0 — blame, revert e compilação antes do check-in (grupo A)

Tudo no wrapper; o console não mudou (usa `history` e `getmodule <id> rev=x.y`, que o console 2026 já tem).

### blame

```text
jvcs-ai.ps1 blame <arquivo> [-Lines a-b] [-Max n] [-Rev x.y] [-IgnoreWhitespace] [-Text]
```

- Para cada linha do arquivo local (ou da revisão `-Rev`): a revisão que a introduziu, o usuário, a data e o
  comentário do check-in. O algoritmo é o do *Line History* do standalone (`JVCSLineHistoryUnit.pas`,
  `TJVCSLineHistory.BuildInfo`): percorre da revisão mais antiga para a mais nova só as revisões que têm este
  membro da família (coluna Files do `history`), e cada linha igual herda a origem; linha nova ou alterada fica
  com a revisão atual. O arquivo local entra no fim: linha ainda não enviada = `local` (`localState=modified`).
- Diff: `git diff --no-index -U0 --diff-algorithm=histogram` sobre o texto decodificado (cp1252, UTF-8 ou
  UTF-16; quebras normalizadas). Sem git no PATH, uma LCS interna (até 1 milhão de células; acima disso, 12).
- `-Max n` (padrão `blameMaxRevisions`=200): só as n revisões mais novas; a mais antiga delas vira base e é
  marcada `boundary` ("esta revisão ou anterior", `^` no `-Text`). Revisão binária (DFM binário) quebra a
  continuidade: a próxima de texto vira base. Revisão cifrada no servidor (o console não grava arquivo) é
  pulada com aviso e a mudança fica com a próxima legível.
- Cache: `%LOCALAPPDATA%\JEDI\JVCS\cache\<host_porta>\<RevisionID>\`, com `.complete` = `id|revisão|data`
  conferido contra o `history` (servidor recriado reaproveita RevisionIDs). Revisões que faltam são baixadas
  em lotes de 20 `getmodule rev=` por execução do `jvcs.exe`. Revisão sem arquivo fica no cache negativo
  (`.unavailable`) por 24 h; erro de seção (falha transitória) não é guardado. O tamanho fica abaixo de
  `cacheMaxMB` (500), apagando as revisões usadas há mais tempo.
- JSON: `modules[0].blame` = trechos `{from,to,revision}`; `blameRevisions` = `{revision,revisionId,checkedIn,
  user,comment,boundary}`; `blameLines` = `{line,revision,text}` (com `-Lines`, `-Text` ou até 300 linhas);
  `lineCount`; `lines`. Revisões puladas vão em `warnings`. No `-Text`, texto, usuário e comentário (que vêm do
  servidor) saem sem caracteres de controle (ESC/ANSI vira `?`).
- Só leitura: não trava nada e não grava na pasta do projeto. Exige o console 2026 (`history`).
- Códigos: 0 ok; 2 uso (`-Lines` inválido ou além do fim, `-Max` negativo, `-Rev` inválida); 3 arquivo vazio;
  5 não versionado ou revisão inexistente; 7 todas as revisões binárias/indisponíveis; 9 `history` falhou;
  12 console original ou diff interno grande demais sem git.

### revert

```text
jvcs-ai.ps1 revert <arquivo> -Rev x.y [-Force] [-AllowEncodingChange]
jvcs-ai.ps1 revert <arquivo> -Rev x.y -Checkin -Comment "motivo" [-SkipBuild]
```

Grava na cópia local o conteúdo da revisão x.y da **família inteira** (`.pas` + `.dfm`), com o módulo em
checkout. Ordem:
1. `-Checkin` pela IA exige `-Confirmed` **em qualquer modo** (publica uma revisão que desfaz o trabalho
   posterior a x.y); `-Force`, `-AllowEncodingChange` e `-SkipBuild` também; `-Comment`/`-SkipBuild` sem
   `-Checkin` → 2;
2. travado por outro → 6; baixa a última revisão e a x.y sem travar nada;
3. conteúdo igual ao da última e local limpo → 3 `alreadyAtRevision` (nada travado);
4. membro que não existe na x.y (criado depois) → 7 `memberNotInRevision` (o revert nunca apaga arquivo);
5. local diferente da última revisão → 8 `localModified` (com `-Force` a alteração vai para o backup);
6. codificação: mantém a codificação e as quebras **atuais** (regra do `edit-preserve`): mesmo tipo = bytes
   exatos da revisão; tipo diferente = recodifica; caractere da revisão que não cabe na codificação atual →
   8 `encodingConflict`. `-AllowEncodingChange` grava os bytes exatos da revisão;
7. modo `checkin` (se `-Checkin`) e modo `checkout` + checkout seguro (`Invoke-CheckoutOne`, com a prova do
   caminho e a compensação de lock), se o módulo ainda não for meu. `manual` → 10; `confirm` → `-Confirmed`;
8. backup **sempre** em `%LOCALAPPDATA%\JEDI\JVCS\backup\<data>-revert-<id>-<rev>\` com `revert.json`
   (de/para, membros e estado local); falha no meio da gravação devolve o conteúdo anterior;
9. `-Checkin`: compila com o `buildCheck` **fora do mutex**, depois confere que o lock continua meu (7
   `lockLost`) e que os bytes gravados não mudaram (7 `changedDuringBuild`); falha de compilação em `block` →
   `buildFailed` (o conteúdo fica gravado em checkout, nada é enviado). O comentário vira
   `[IA] revert para x.y: motivo`.

Estados: `reverted`, `revertedCheckedIn`, `revertedNotCheckedIn`, `alreadyAtRevision`, `localModified`,
`memberNotInRevision`, `encodingConflict`, `needsConfirmation`, `lockedByOther`, `checkoutFailed`,
`readOnly`, `buildFailed`, `lockLost`, `changedDuringBuild`. Campos extras: `revision`, `backup`,
`checkout{}`, `checkin{}`. Funciona com o console original (não usa comando novo).

### Compilação antes do check-in (`buildCheck`)

```ini
[ai]
buildCheck=off            ; off | warn | block  (padrão off)
buildCommand=C:\Users\voce\AppData\Roaming\JEDI\JVCS\compilar-projeto.bat   ; .bat | .cmd | .ps1, caminho absoluto
buildCommandSha256=...    ; gravado pelo config set buildCommand (não edite)
buildConfig=Debug
buildPlatform=Win32       ; Win32 | Win64
buildTimeoutSec=600       ; 30 a 7200
```

- O wrapper **só roda o script que o usuário registrou** (`config set buildCommand <script>`; `config set` é
  recusado à IA com 10). Ao registrar, o SHA-256 do script fica em `buildCommandSha256`; se o arquivo mudar
  depois (inclusive pela IA), a compilação é recusada com 12 até o usuário revisar e registrar de novo.
  `config set buildCommand none` desliga.
- **Não existe** modo que execute o `.dproj` vindo do servidor (msbuild/dcc automáticos foram retirados do
  projeto, achado ALTA do revisor: um `.dproj` alterado por qualquer usuário do servidor rodaria código na
  máquina de quem faz o check-in, por `Exec`/`Import`/property functions). Se o script do usuário chamar o
  `msbuild`, o risco é dele: prefira `dcc32`/`dcc64` com os caminhos fixos no script.
- Contrato do script: `<script> "<projeto.dpr|.dpk>" "<pasta de saída temporária>" <Win32|Win64> <Debug|...>`;
  código 0 = compilou. Pasta de trabalho = pasta do projeto; stdin fechado; a saída vai para
  `%LOCALAPPDATA%\JEDI\JVCS\build\<data>-<projeto>.log`. Linhas `Error/Fatal E/Fnnnn` e `: error` viram
  `build[].errors` (até 20). Timeout → a árvore do processo é encerrada (`taskkill /T`).
- Guarde o script **fora das pastas de projeto** e sem depender de arquivos que a IA possa editar (o hash cobre
  só o arquivo registrado). Sugestão: `%APPDATA%\JEDI\JVCS\`, que o `edit-preserve` e as regras `deny` já
  protegem.
- O projeto compilado é o `.dpr`/`.dpk` mais próximo acima de cada arquivo (com `-Project`, o de mesmo nome);
  um build por projeto, **antes** do mutex (o hook espera só `lockWaitSec`). O modo `checkin` é conferido
  **antes** de compilar (`confirm` sem `-Confirmed` → 10 sem gastar a compilação).
- `warn`: falha vira aviso e o check-in segue. `block`: falha → 7 `buildFailed` em cada módulo, nada enviado e
  os locks continuam; script ausente, não registrado ou alterado → 12. `-SkipBuild` pela IA exige `-Confirmed`.
- Resultado em `build[]` = `{project, command, ok, exitCode, seconds, errors[], warnings, log}`; a auditoria
  registra `build` e `modes=...;buildCheck=...`.
- Limitação: compila a **cópia de trabalho inteira** (inclusive arquivos alterados que não vão neste check-in).

### commentPrefix

Já existia no `checkin`/`add` (`[IA] ` só em contexto de agente, sem duplicar). Agora também na descrição do
`addproject` e no comentário do `revert -Checkin` (`[IA] revert para x.y: ...`).

### Testes (17/10/2026, servidor de teste local, identidade DEFAULT, console 2026 do worktree)

Projeto `iateste-grupo-a.dpr` (ID 9) em `D:\Delphi\JediVCS\testes-ia\grupo-a`, `APPDATA`/`LOCALAPPDATA`
temporários, contexto de agente (stdin redirecionado):
- `addproject` com a descrição `[IA] ...`; `add` do `.dpr`, `u1.pas`, `u2.pas` (+ `.dfm`) e `u3.pas`;
- `u3.pas` (cp1252 com acentos, CRLF): 0.1 → 0.5 por checkout + `edit-preserve -ContentFile` + checkin;
  `blame` conferido **linha a linha** (19 linhas: 0.1/0.2/0.3/0.4/0.5); `-Lines 12-17`; `-Max 2` (base 0.4 com
  `boundary`); `-Rev 0.3` (15 linhas); `-Text`; `-IgnoreWhitespace`; sem git no PATH (LCS) com o mesmo
  resultado; 2ª execução pelo cache; `.dfm` de texto (Caption/ClientHeight na 0.2); alteração local → `local`;
  `-Lines 99`/`abc`, `-Max -1`, `-Rev x.y` → 2; `-Rev 9.9` e não versionado → 5; console original → 12;
- `revert -Rev 0.2` → bytes **idênticos** à 0.2 em cp1252 com acentos e ao `show -Rev 0.2`, backup com
  `revert.json`; de novo → 8; `-Force` sem `-Confirmed` → 10; check-in → 0.6 (`diff -Rev 0.2 -Rev2 0.6`
  idêntico); `revert -Rev 0.5 -Checkin -Confirmed` → 0.7 com `[IA] revert para 0.5: ...`; com o módulo já em
  checkout por mim (sem novo checkout); família `u2` (.pas + .dfm) → 0.1; revisão ANSI sobre atual ASCII →
  bytes exatos; já igual → 3; `-Rev 9.9` → 5; não versionado → 5; sem `-Rev`/`-Rev abc`/`-Comment` ou
  `-SkipBuild` sem `-Checkin`/comentário > 2000 → 2; `checkout=confirm` → 10; `checkout=manual` → 10;
  `-Checkin` sem `-Confirmed` (modo auto) → 10; `checkin=manual` com `-Confirmed` → 10; console original → 3;
- `buildCheck`: `block` + script com erro → 7 `buildFailed` com E2003/F2063 em `build[].errors`, lock mantido;
  hash diferente, script alterado em 1 byte e `block` sem script → 12; `checkin=confirm` → 10 antes de
  compilar; `-SkipBuild` sem `-Confirmed` → 10; timeout de 30 s → 7 e nenhum processo pendurado; `warn` →
  check-in com aviso; script ok (`.bat` e `.ps1`, recebendo dpr, pasta de saída, plataforma e config) →
  check-in; `revert -Checkin` com build falho (7, conteúdo em checkout) e com build ok / `-SkipBuild -Confirmed`;
  `config set buildCommand|buildCheck` pela IA → 10;
- sem servidor (funções extraídas do wrapper): revert com lock de outro → 6 (não há outro usuário no servidor
  de teste); conversões do revert (ANSI→UTF-8 BOM, LF→CRLF, binário, caractere fora do CP1252 → 8);
  `Format-Text` sem ESC; 40 pares aleatórios git × LCS; validação das chaves novas e `-Internal` do hash.
- Não testado: `config set buildCommand` pelo humano no terminal (o teste roda como agente; a gravação do hash
  foi testada pela função), revisão cifrada no cache negativo (não há uma no projeto de teste) e o hook
  `PreToolUse` junto com o `revert`.

## 17. Versão 1.4.0 — rollback por data, sync para outra pasta e Put (grupo E)

Itens da janela *VCS Synchronize / Restore* e do *Check In* do standalone que faltavam (plano:
`doc\pt\ia\08-Plano-de-Recursos.md`, seção 5a). O E1 (*Restore version number*), o E5 (*Description*) e o E6
(label de uma revisão) ficaram fora.

### Console 2026: `projectrevs` e `checkin ... keep`

```text
projectrevs <projeto>|<id> latest | label=<nome>|#<id> | version=<n>[.<m>] | date=aaaa-mm-dd[Thh:nn[:ss]] [includehidden]
checkin <módulo>|<id> [<comentário>] [keep]
```

- `projectrevs` lista a revisão de cada módulo do projeto num estado, como as abas do standalone:
  `latest` e `label=` (`GET_LATEST_REVISIONS`), `version=` (`GET_VERSION_REVISION`; `n` = a mais nova da versão
  n, `n.m` = exata; o wrapper não usa) e `date=` em hora local (`GET_ROLLBACK_REVISIONS`, aba *Rollback*).
  Saída: `Project:`, `State:` (eco que o wrapper confere), `Hidden modules:` e as colunas ID(8)@0
  Version(7)@9 RevID(8)@17 File date(19)@26 Files(30)@46 e `caminho|nome` livre@77 (escapado como no `history`:
  `\` vira `\\`), com o **caminho completo** do servidor (o `listproject` corta em 50 caracteres). Rodapé
  `<n> module(s)`. As linhas são agrupadas por ID de módulo (o `GET_VERSION_REVISION` ordena por nome). Só
  leitura. Data ou versão inválida → `[Exception] Invalid ...`; sem seletor → linha de uso.
- `checkin ... keep` (último parâmetro) = **Put**: `CHECKIN_MODULE` com `PutOnly`; revisão nova no servidor,
  o lock continua e os arquivos ficam graváveis (o console não põe somente leitura) e escreve
  `Put: module <id> '<nome>' checked in as x.y and still checked out`. Só para módulo em checkout **do próprio
  usuário** (o console recusa antes: `is not checked out` / `is locked by`; com o *CasuallyCheckin* do servidor,
  um Put num módulo livre o travaria). Não vale no 1º check-in (módulo sem revisão). Sem mudança no arquivo →
  `not changed` (nada é enviado, o lock fica). Comentário vazio: `checkin <id> keep`.
- Mudança para **todo** check-in do console 2026: a recusa do servidor (`CheckinAllowed = False`), que antes era
  silenciosa, vira `[Exception] Check-in of module <id> '<nome>' refused by server: <motivo>` (motivo do
  servidor, ou `no reason given by the server`).

### `sync -Date` (rollback, E2)

```text
jvcs-ai.ps1 sync -Date <aaaa-mm-dd | aaaa-mm-ddThh:mm[:ss] | "aaaa-mm-dd hh:mm[:ss]"> [-Project p] [-Apply [-Force]]
```

- Põe a cópia de trabalho no estado da data, como a aba *Rollback*: por módulo, a revisão **mais nova** cujos
  arquivos têm **todos** a data do arquivo até a data pedida. Mesmas regras, backup e mensagens do
  `sync -Label` (núcleo comum `Invoke-SyncToState`): igual à revisão-alvo `none`; ausente `create`; igual à
  última revisão `restore`; diferente das duas `conflict` (só com `-Force`; pela IA, `-Confirmed`); em checkout
  por mim `keep`; módulo sem revisão até a data `notInTarget` (não mexe e **não apaga**); membro que só existe
  em revisão mais nova `extra` (fica no disco). Backup em `backup\<data>-sync-date\<id>\`; a data do arquivo
  volta a ser a da revisão e o somente leitura segue o filtro *Writeable Files*.
- **A data comparada é a DATA DO ARQUIVO** gravada no check-in (`blobs.origtime`, a que o `history` mostra
  como "Checked in"), não a hora do check-in (para ela, `changes`). Um arquivo salvo antes da data e enviado
  depois entra como se já existisse. O servidor compara com fração de segundo: com exatamente o segundo que o
  `history` mostra, a própria revisão pode ficar de fora; use um segundo a mais.
- `aaaa-mm-dd` sem hora vale como **fim do dia** (23:59:59; hoje = agora). Futuro, antes de 1990, formato
  inválido ou junto com `-Label` → 2. O JSON traz `target {kind: date, value, state}` e, por módulo,
  `targetVersion`, `revisionId`, `targetFileDate` e `latestVersion`.
- Prévia por padrão. `-Apply` segue o modo **checkout** (`manual` → 10; `confirm` → 10 até `-Confirmed`);
  `-Force` exige `-Apply` (senão 2) e, pela IA, `-Confirmed` em qualquer modo. Depois do `-Apply` vem o aviso
  para voltar com `sync -Apply` (sem `-Date`) antes de editar.
- A pasta de cada módulo vem do caminho completo do `projectrevs` **mais o nome** (o nome pode trazer
  subpasta, como no `Find-LocalMember`); caminho relativo ou vazio → `unknown` (7 com `-Apply`). Pasta
  protegida → 7 **antes** de qualquer gravação (antes, no `sync -Label`, podia já ter gravado módulos).
- Exige o console 2026 (`projectrevs`); console original → 12.
- Códigos: 0 ok; 2 uso; 3 nada a fazer / nenhum módulo com revisão até a data; 5 projeto inexistente;
  7 pasta protegida ou caminho desconhecido; 8 só conflitos; 9 console; 10 confirmação; 11 parcial (parte
  aplicada e parte em conflito/sem caminho); 12 console antigo.

### `sync -Dest` (outra pasta, E3)

```text
jvcs-ai.ps1 sync -Dest <pasta> [-Label l | -Date d] [-Project p] [-Apply]
```

- Grava o estado pedido (padrão: as últimas revisões; ou o label; ou a data) numa pasta **nova ou vazia**, como
  **cópia de leitura**: não mexe na cópia de trabalho, em checkout nem no servidor; nada é registrado no JEDI VCS.
  Prévia por padrão (nada é gravado; a pasta não é criada). `-Apply` segue o modo **checkout**.
- Árvore relativa à pasta comum dos módulos no servidor (o standalone achata tudo numa pasta): os caminhos
  relativos do `.dpr` continuam valendo. Com unidades diferentes, as subpastas ficam `d\...` ou `unc\...`.
  O nome do módulo pode trazer subpasta: o arquivo final é calculado e **conferido dentro do -Dest** antes de
  gravar (nome com `..` → `badPath` 7, nada sai do destino).
- Recusas: `-Force` → 2; aspas, curinga ou controle → 2; destino que não seja `X:\pasta` (inclusive a raiz),
  pasta protegida (`tools\ai`, `%APPDATA%\JEDI`, `%LOCALAPPDATA%\JEDI`, `.git`, `.claude`), arquivo, a pasta do
  projeto, a de qualquer módulo (caminho completo, a pasta real com a subpasta do nome e o prefixo visível do
  caminho truncado) ou pasta que fique dentro delas ou as contenha → 7; pasta não vazia ou dois arquivos no
  mesmo destino → 8 (nada é gravado, nunca sobrescreve).
- Os bytes são os do `getmodule rev=` da versão que o `projectrevs` devolveu (o mesmo instantâneo, também no
  latest); data do arquivo = data da revisão; somente leitura pelo filtro *Writeable Files*. Grava
  `jvcs-export.json` (servidor, usuário, projeto, alvo, raiz, módulos com versão, revisionId e caminho, e nota de
  que não é pasta de trabalho). Módulo em checkout por mim exporta a revisão do servidor (a mensagem avisa).
- Módulo sem pasta absoluta no servidor → `noPath` (7 só com `-Apply`; os demais são exportados → 11).
- JSON: `dest`, `target`, `sourceRoot`, `manifest` e, por módulo, `state` `export`/`exported`/`noPath`/`badPath`,
  `path`, `version`, `revisionId`, `targetFileDate`, `targetFiles` e `files[]` (`name`, `path`, `action`,
  `size`). A auditoria registra `target` e `dest`; o `-Text` mostra `alvo:` e `destino:`.

### `checkin -Keep` (Put, E4)

```text
jvcs-ai.ps1 checkin <arquivo...> -Comment "..." -Keep
```

- Mesmo fluxo do `checkin` (lock meu, comparação por bytes com a base, codificação, prova do caminho,
  `buildCheck`, modo **checkin**), mandando `checkin <id> "<comentário>" keep`. Sucesso = versão subiu **e** o
  lock continua comigo → `checkedInKept` (0), com o arquivo conferido contra a revisão nova e aviso se ficou
  somente leitura. No fim do trabalho: `checkin` normal (ou `undocheckout`).
- Sem mudança → `unchangedKept` (3): nada é enviado e **não** há `undocheckout` (diferente do `checkin` normal).
- Erros: `refused by server: ...locked by` → `lockedByOther` 6; `...not checked out` → `notCheckedOut` 7; outro
  motivo → `refused` 7 com o texto do servidor (vale também sem `-Keep`). `-Keep` em outro comando → 2;
  comentário igual a `keep` → 2 (o console o leria como a palavra-chave). Exige o console 2026 (12 no original).
- JSON: `keep: true`; a auditoria registra `keep`. O `changes` mostra a revisão como `put`.

### Testes (17/10/2026, servidor de teste local, identidade DEFAULT, console 2026)

Projeto `iateste-grupo-e.dpr` (ID 14) em `D:\Delphi\JediVCS\testes-ia\grupo-e` (`.dpr`, `uGrupoE1.pas`+`.dfm`,
`uGrupoE2.pas`, `sub\uGrupoESub.pas`, depois `uGrupoE3.pas`), com as datas dos arquivos ajustadas antes de
cada check-in: 0.1 em 01/10, 0.2 em 05/10, 0.3 (Put) em 10/10, 0.4 em 12/10 (o `.dfm` da 0.4 ficou com 10/10),
`uGrupoE2` 0.3 em 14/10 e `uGrupoE3` 0.1 em 16/10; `APPDATA`/`LOCALAPPDATA` temporários, contexto de agente.
- Console: `projectrevs` `latest` (caminho completo escapado), `date=` 03/10 (tudo 0.1), 07/10T00:00 (0.2),
  `"2026-10-11 00:00:00"` (E1 0.3: a 0.4 tem membro de 12/10), por ID; `10:00:00` exato dá a 0.2 e `10:00:01`
  a 0.3 (fração de segundo); `1990-01-01` → 0 módulos; `2026-13-01` e `version=x` → `Invalid ...`;
  `latest foo` → uso; projeto e label inexistentes → `not found`; `includehidden`; `version=0.2`.
  `checkin <id> "x" keep` e `checkin <id> keep` sem checkout → `is not checked out`; `... foo` e `... keep extra`
  → uso.
- `checkin -Keep`: sem checkout → 7; `diff -Keep` → 2; sem mudança → 3 `unchangedKept` com o lock mantido;
  `checkin=confirm` sem `-Confirmed` → 10; Put 0.2 → 0.3 com lock `sysdba` mantido e arquivos graváveis;
  check-in normal depois → 0.4, lock liberado e somente leitura; `history` e `changes` (0.3 como `put`);
  console original → 12; comentário `keep` → 2 (função, sem prefixo).
- `sync -Date`: prévias de 07/10 (E1 `restore` para 0.2) e 11/10 (só o `.pas` volta; o `.dfm` é igual) sem
  alterar nenhum arquivo; `checkout=confirm` e `manual` → 10; `-Apply` → bytes iguais ao `show -Rev 0.2`, data
  05/10, somente leitura, backup `sync-date` e aviso; alteração local + data 03/10 → 11 (E2 voltou à 0.1 e E1 em
  conflito, arquivo preservado); `-Force` sem `-Apply` → 2; `-Apply -Force` sem `-Confirmed` → 10; com
  `-Confirmed` → substituído com backup; módulo criado depois da data → `notInTarget` e o arquivo continua;
  `2099-01-01`, `hoje`, `2026-02-30`, `1989-12-31`, `2026-10-15T25:00`, `-Date` com `-Label` e `-Date` em
  `changes` → 2; `1995-01-01` → 3; projeto inexistente → 5; console original → 12; hoje sem hora = agora.
- `sync -Dest`: prévia sem criar a pasta; `-Apply` em `confirm` → 10; `-Apply` → árvore com `sub\`, bytes
  iguais à cópia de trabalho (latest), `.pas`/`.dfm` somente leitura e `.dpr` gravável, manifesto válido,
  nenhum lock; de novo → 8; `-Label` (E2 na 0.2) e `-Date 2026-10-07` (E1 e E2 na 0.2) com bytes iguais ao
  `show -Rev`; recusas 7 (pasta do projeto, `sub`, subpasta nova dentro do projeto, pasta-mãe, `C:\`,
  `%LOCALAPPDATA%\JEDI\x`, `%APPDATA%\JEDI`, `tools\ai`, `.git`, arquivo), curinga e `-Force` → 2, console
  original → 12; `ex2.dpr` (módulos 5, 6 e 9 sem pasta) → `noPath` e 11.
- Sem servidor (funções do wrapper com `Invoke-Jvcs`/`Get-JvcsBase` simulados): módulo com nome `sub\x.pas`
  vai para `<pasta>\sub\x.pas` no `sync -Date` (prévia e `-Apply`; nada em `<pasta>\x.pas`) e para
  `<dest>\sub\x.pas` no `-Dest`; nome `..\..\evil.pas` → `badPath` 7, nada fora do destino, resultado 11; destino
  dentro da pasta real de um módulo com `..` no nome → 7.
- Regressão: `sync` normal (prévia e `-Apply` voltando à última revisão) e `sync -Label "[teste IA] label"` em
  `ex4ia.dpr` (prévia e `-Apply`, arquivos idênticos antes e depois); `sync -Label` com `restore` no projeto de
  teste; `sync -Label` em `exemplo01.dpr` → 3.
- Não testado: recusa real do servidor no check-in (`refused by server`, exige outro usuário com o lock ou o
  *CasuallyCheckin* desligado) e módulo com subpasta no nome **no servidor** (o console 2026 não cria mais esse
  tipo de módulo; os de `ex2` já foram removidos) — coberto pelo teste sem servidor.
