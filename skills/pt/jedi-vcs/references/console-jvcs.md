# Console jvcs.exe (sem o wrapper)

Referência para **humanos** e scripts de build. A IA deve usar o wrapper `jvcs-ai.ps1`: o console
sozinho devolve 0 mesmo com erro, não mostra a recusa do servidor, muda o estado do servidor antes de
perguntar coisas que não consegue perguntar com a entrada redirecionada, e a forma documentada recebe
a senha na linha de comando.

Programa: `jvcs.exe` 2.5.0.1030 (original, `C:\Program Files (x86)\JEDI\JVCS`) ou 2.5.0.20xx (2.5.0.2050 = beta 5) (novo,
`C:\Program Files (x86)\JEDI\JVCS 2026`), com `fvcscrypt.dll` ao lado. O 2026 tem os mesmos comandos do
original e mais os da seção "Comandos novos do console 2026".

## Sintaxe

```text
jvcs servidor:porta /user Usuario /password Senha /comando argumentos...
jvcs servidor:porta -user Usuario -password Senha -comando argumentos...
```

- Sem `servidor:porta`: `localhost:2106`.
- Sem `/password` e com a entrada redirecionada, o console lê a senha da primeira linha da entrada
  padrão (é assim que o wrapper faz, sem expor a senha). **Evite `/password`**: a linha de comando
  aparece na lista de processos, no histórico do shell e em transcrições de IA.
- Sem comando: modo interativo (`jvcs>`), saia com `exit`.
- Vários comandos: arquivo de texto e `/input arquivo.txt` (dentro do arquivo, sem `/`).
- Comandos de módulo exigem `openproject` antes (na mesma sessão / no mesmo `/input`).
- Códigos de saída: 1 erro não especificado, 2 parâmetros inválidos, 3 nada sincronizado (só com
  `extexitcode`). Erros dentro de `/input` **não** mudam o código: leia a saída (linhas `[EClasse] ...`).

## Comandos

| Comando | Faz | Efeito |
|---|---|---|
| `listprojects` | lista projetos | leitura |
| `listproject <nome\|id> [includehidden]` | módulos do projeto (caminho truncado em 47 caracteres) | leitura |
| `listlocks [<usuário>\|all_users]` | módulos em checkout | leitura |
| `openproject <nome\|id>` | abre o projeto para os comandos seguintes | sessão |
| `checkout <módulo\|id>` | checkout | servidor e disco |
| `checkin <módulo\|id> [comentário]` | check-in; sem mudança não faz nada | servidor |
| `undocheckout <módulo\|id>` | desfaz o checkout | **sobrescreve o arquivo local** |
| `getmodule <módulo\|id> [rev=v.r] [dest="pasta"] [noprompt]` | baixa uma revisão | disco |
| `labelproject <projeto> <"label">` | aplica label | servidor |
| `syncproject <projeto> [noprompt] [stamp\|crc] [crossref] [includehidden\|deletehidden] [extexitcode] [label="nome"]` | sincroniza a pasta | **grava/apaga no disco** |
| `syncprojectgroup <grupo> [mesmas opções]` | sincroniza um grupo | **grava/apaga no disco** |
| `input <arquivo>` | executa comandos de um arquivo | |
| `help [<comando>]`, `exit` | ajuda, sair | |

Não existem em nenhum dos dois: `diff`, `log`, `whoami` (o `jvcs-ai.ps1` oferece `diff`, `show`, `sync`,
`history`, `changes` e `identity`).

## Comandos novos do console 2026

Só no `jvcs.exe` 2026 (`jvcs help <comando>` mostra a sintaxe completa). Os de administração **não pedem
confirmação** (os de projeto exigem só a palavra `confirm`): pela IA, use sempre o comando do wrapper indicado,
que faz a prévia, o backup e pede a aprovação.

| Comando | Faz | Efeito | No wrapper |
|---|---|---|---|
| `addproject <projeto> [<descrição>]` | cria o projeto | servidor | `addproject` |
| `addmodule <arquivo> [<descrição>]` | cadastra o arquivo (com a pasta) no projeto aberto | servidor | `add` |
| `setmodulepath <módulo\|id> <pasta>` | grava a pasta local do módulo no servidor | servidor | — |
| `history <módulo\|id>` | revisões: data do arquivo, usuário, família, comentário | leitura | `history`, `blame` |
| `projectlog <projeto\|id> [since=] [user=] [max=] [norev]` | check-ins do projeto pelo log do servidor (hora real) | leitura | `changes` |
| `searchmodules <máscara>` | módulos por nome/máscara em todos os projetos | leitura | `search` |
| `searchcomments <texto> <projeto\|id> [maxmodules=]` | texto nos comentários de check-in/check-out | leitura | `search -InComments` |
| `listlabels [<projeto\|id>]` | labels do servidor / usados no projeto | leitura | `labels` |
| `labelrevs <projeto\|id> <label>\|#id` | revisão de cada módulo no label | leitura | `labels -Label`, `sync -Label` |
| `modulelabels <módulo\|id>` | labels de cada revisão do módulo | leitura | `labels <arq>`, `history` |
| `projectrevs <projeto\|id> latest\|label=\|version=\|date= [includehidden]` | revisão de cada módulo num estado (como as abas do Synchronize/Restore) | leitura | `sync -Date`, `sync -Dest` |
| `sharedby <módulo\|id>`, `sharedmodules <projeto\|id>` | projetos que têm o módulo / módulos compartilhados do projeto | leitura | `shared` |
| `listtodo [project=] [user=] [category=] [priority=] [due=] [includedone]` | itens de ToDo | leitura | `todo` |
| `addtodo <projeto\|id> "<descrição>" [...]`, `donetodo <id> [reopen]` | cria / conclui ou reabre ToDo | servidor | `todo-add`, `todo-done` |
| `listmilestones [<projeto\|id>\|all]` | milestones definidos e atingidos | leitura | `milestones` |
| `listbugs [module ...\|project ...\|bug <id>]`, `bugsummary modules\|projects` | bugs e o mais grave por módulo/projeto | leitura | `bugs` |
| `addbug`, `updatebug <id>`, `assignbug <id> module\|project ...` | cria, altera, liga/desliga bug | servidor | `bug-add`, `bug-update`, `bug-link` |
| `listmodules [<projeto\|id>]`, `listdeserted` | todos os módulos do projeto (flags `H` `B` `N` `P`) / abandonados (`D`) | leitura | `modules`, `cleanup` |
| `removemodule <módulo\|id> [archive]` | tira do projeto / com `archive`, **apaga do arquivo** (irreversível) | servidor | `rm-module`, `cleanup` |
| `renamemodule <módulo\|id> <novo>`, `hidemodule <módulo\|id> [unhide]` | renomeia (todos os projetos) / oculta no projeto | servidor | `rename-module`, `hide` |
| `getcomment <revision_id>`, `setcomment <módulo\|id> <revision_id> in\|out "<texto>"` | lê / troca o comentário de uma revisão | leitura / servidor | `comment` |
| `projectinfo <projeto\|id>` | projeto e vínculos (também de projeto removido) | leitura | prévia de `rm-project`/`rename-project` |
| `removeproject`, `restoreproject`, `renameproject ... [renamefiles]` (+ `confirm`) | remove / restaura / renomeia o projeto | servidor | `rm-project`, `restore-project`, `rename-project` |
| `linkmodule <id> <caminho\nome> [hidden]`, `projectgroups`, `setprojectgroup <projeto> <grupo> add\|remove` | religa módulo / grupos de projeto | servidor | `restore-project -Relink` |

Mudanças em comandos que já existiam:
- `checkin <módulo|id> [comentário] [keep]`: com `keep` é o **Put** (revisão nova, o lock continua e os
  arquivos ficam graváveis; wrapper `checkin -Keep`). Check-in recusado pelo servidor agora vira erro com o
  motivo (`refused by server: ...`) em vez de passar em silêncio.
- `labelproject`: última coluna `added` ou `kept x.y` (o servidor não move label que já está noutra revisão).
- `getmodule`: aceita `rev=` + `dest=` + `noprompt` juntos.
- Servidor 2.5 com ramos (Firebird): `removemodule ... archive` só apaga módulo **sem revisão**; com revisão
  o servidor responde 400 e nada muda (limitação do servidor).

## Exemplo seguro (senha pelo stdin, sem /password)

```powershell
# cmds.txt (CP1252):
#   openproject exemplo01.dpr
#   listlocks
$exe = 'C:\Program Files (x86)\JEDI\JVCS 2026\jvcs.exe'
$cred = Get-Credential -UserName usuario -Message 'Senha do JEDI VCS'
$cred.GetNetworkCredential().Password | & $exe servidor:2106 /user usuario /input cmds.txt
```

Cuidados conhecidos:

- Com o console em UTF-8 (`chcp 65001`, ou dentro de ferramentas de IA) o .NET pode mandar um BOM
  antes da senha e o login falha; o wrapper contorna isso.
- `checkout`, `undocheckout` e `getmodule` podem mudar o estado (lock, arquivo) e **depois** perguntar
  algo; com a entrada redirecionada a pergunta falha e o lock pode ficar pendurado.
- `checkin` não mostra a recusa do servidor: confira a versão depois com `listproject`.
- `syncproject ... noprompt crc` sobrescreve qualquer arquivo local que não esteja em checkout seu.
- Comentário e caminhos em ANSI (CP1252); comentário sem aspas duplas.

Referência completa: `doc/pt/client/jvcs_params.txt` e `doc/pt/manual/06-Linha-de-Comando.md` do repositório.
