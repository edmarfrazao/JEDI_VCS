# Referência rápida: jvcs-ai.ps1 e edit-preserve.ps1

Forma: `powershell -NoProfile -ExecutionPolicy Bypass -File "<tools/ai>/jvcs-ai.ps1" <comando> [args] [opções]`

## Comandos

| Comando | Faz | Muda servidor |
|---|---|---|
| `help` | resumo | não |
| `identity [-Test]` | identidade em uso (nunca a senha); `-Test` faz login | não |
| `projects` | projetos do servidor | não |
| `list [-Project p]` | módulos: versão, lock, estado pelo CRC do console (rápido) | não |
| `locks [-All]` | módulos em checkout (meus / todos) | não |
| `status <arq...>` / `status [-Project p]` | estado exato (bytes) contra a última revisão | não |
| `checkout <arq...> [-Force]` | checkout seguro; local diferente → 8 sem lock | sim |
| `ensure-checkout <arq> [-CheckOnly]` | idempotente (para hooks) | sim |
| `checkin <arq...> -Comment "..." [-AllowEncodingChange]` | check-in; sem mudança → desfaz checkout (3) | sim |
| `undocheckout <arq...> [-Discard]` | desfaz se local = base; `-Discard` descarta (backup) | sim |
| `diff <arq> [-Rev x.y]` | diff unificado do local contra a revisão do servidor (padrão: a última) | não |
| `diff <arq> -Rev x.y -Rev2 y.z` | diff entre duas revisões do servidor | não |
| `history <arq> [-Max n]` | revisões com data, usuário, família e comentário; mais recente primeiro (console 2026) | não |
| `show <arq> -Rev x.y [-Dest pasta]` | grava a revisão (com a família) numa pasta de consulta fora do projeto | não |
| `sync [-Project p]` | prévia: o que falta, o que está mais antigo e os conflitos | não |
| `sync [-Project p] -Apply [-Force]` | baixa/atualiza a cópia local com backup; nunca mexe no seu checkout; `-Force` sobrescreve alteração local sem checkout | não (só a pasta local) |
| `addproject <proj.dpr> [-Comment "..."]` | cria o projeto no servidor (console 2026) | sim |
| `add <arq...> -Comment "..."` | cadastra e faz o 1º check-in 0.1 com a família (console 2026) | sim |
| `config list \| get <chave>` | configuração (`set` é só do usuário) | não |

Opções: `-Project <nome.dpr|caminho>`, `-Identity <nome>`, `-Rev`, `-Rev2`, `-Max`, `-Dest`, `-Apply`, `-Text`, `-Confirmed`, `-Agent`,
`-TimeoutSec <n>`, `-LockWaitSec <n>`, `-Raw`.

Exigem `-Confirmed` (aprovação do usuário): tudo que muda o servidor no modo `confirm`;
`checkout -Force`, `checkin -AllowEncodingChange`, `undocheckout -Discard` e `sync -Apply -Force` em
qualquer modo. `sync -Apply` segue o modo de checkout (`manual` → 10).

`sync -Apply`: código 3 = nada mudou; 8 = só conflitos (nada sobrescrito); 11 = parte atualizada e parte
não. Os arquivos substituídos ficam em `%LOCALAPPDATA%\JEDI\JVCS\backup\<data>-sync\<id>\` (campo `backup`).

## JSON

```json
{"ok":true,"command":"status","project":"exemplo01.dpr",
 "modules":[{"id":4,"name":"uprincipal.pas","path":"C:\\...\\uPrincipal.pas","version":"0.14","lockedBy":"",
             "localState":"clean","state":"ok","exitCode":0,"message":"","pathCheck":"prefix",
             "files":[{"name":"uPrincipal.pas","localState":"clean","readOnly":true}]}],
 "message":"1 arquivo(s) verificado(s)","exitCode":0}
```

- `ok` = código 0 ou 3. Extras: `identity`, `projects`, `config`, `configPath`, `comment`, `warnings`, `raw`.
- `localState`: `clean`, `modified`, `missing`, `notVersioned`, `unknown`.
- `pathCheck`: `exact`, `prefix` (truncado, não provado), `verified`.
- `state`: `ok`, `checkedOut`, `checkedOutKeptLocal`, `alreadyMine`, `needsCheckout`, `notVersioned`,
  `lockedByOther`, `localModified`, `needsConfirmation`, `pathMismatch`, `checkedIn`, `unchangedUndone`,
  `refused`, `encodingChanged`, `notCheckedOut`, `localMissing`, `undone`, `discarded`,
  `releasedButDirty`, `failedCompensated`, `failed`, `timeout`, `error`, `pathTruncated`.

## Códigos

0 ok · 2 uso · 3 nada a fazer · 4 credencial · 5 não encontrado/`pathMismatch` · 6 travado por outro ·
7 pré-condição · 8 conflito local · 9 servidor/console/timeout · 10 confirmação/manual ·
11 lote parcial · 12 ambiente.

## Configuração (`%APPDATA%\JEDI\JVCS\config.ini`, seção `[ai]`)

`checkout`/`checkin` = `auto|confirm|manual` (padrão `confirm`) · `commentPrefix` (`[IA]`) · `jvcsExe` ·
`timeoutSec` (120) · `lockWaitSec` (120) · `identity` (vazio = última usada) · `asciiAs` (`ansi|utf8`).
Interface: VCS Properties → AI / Automation.

## edit-preserve.ps1

```text
edit-preserve.ps1 -Path X.pas -Old "atual" -New "novo" [-All] [-Regex] [-DryRun]
edit-preserve.ps1 -Path X.pas -OldFile old.txt -NewFile new.txt
edit-preserve.ps1 -Path X.pas -ContentFile conteudo.txt
edit-preserve.ps1 -Path Novo.pas -ContentFile c.txt -NewFileEncoding Ansi|Utf8Bom|Utf8|Utf16
```

Saída `{ok, path, encoding, eol, replacements, bytesBefore, bytesAfter, checkout, message, exitCode}`.
Códigos: 0 ok · 2 uso · 3 nada mudou · 4 `-Old` ausente · 5 `-Old` não único · 6 caractere fora da
codificação · 7 E/S ou somente leitura · 8 arquivo não suportado · 9 checkout falhou · 10 confirmação,
modo manual ou caminho proibido.
