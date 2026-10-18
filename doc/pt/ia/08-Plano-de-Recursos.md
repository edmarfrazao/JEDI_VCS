# 08. Plano: mais recursos do JEDI VCS para a IA

Plano para a IA (Claude Code e outros agentes) usar os recursos do servidor JEDI VCS que hoje só o
cliente standalone usa. Criado em 17/10/2026. Situação de cada item na tabela da seção 7.

Anterior: [07 - Outros agentes](07-Outros-Agentes.md). Roteiro de longo prazo: [ADR-001](../common/ADR-001-CLI-IA-e-Plugin-Multi-Delphi.md).

## 1. Ponto de partida (wrapper 1.3.0)

| Já existe | Comando |
|---|---|
| Estado, módulos e locks | `status`, `list`, `locks` |
| Checkout e check-in seguros, desfazer | `checkout`, `ensure-checkout`, `checkin`, `undocheckout` |
| Diff contra o servidor e entre revisões | `diff <arq> [-Rev x.y [-Rev2 y.z]]` |
| Histórico com comentários | `history <arq> [-Max n]` (console 2026) |
| Revisão antiga para leitura | `show <arq> -Rev x.y` |
| Sincronizar a cópia local | `sync` (prévia) e `sync -Apply [-Force]` (com backup) |
| Criar projeto e módulo | `addproject`, `add` (console 2026) |

O servidor oferece muito mais (log do projeto, busca, bugs, ToDo, milestones, labels, módulos
compartilhados, administração), mas o console `jvcs.exe` não expõe esses recursos. O caminho é o mesmo
do `history`: **um comando novo no console 2026 para cada requisição do servidor + um comando no
wrapper** que valida, aplica os modos e devolve JSON.

## 2. Princípios

- **Leitura é livre; mudar o servidor passa pelo modo de check-in** (`manual` → a IA não faz;
  `confirm` → `-Confirmed`). **Destrutivo** (remover, renomear, purgar) exige aprovação humana em
  **qualquer** modo e uma chave no `config.ini` (padrão desligada), com prévia, recusa quando há lock
  ou compartilhamento e registro do que foi removido.
- Texto vindo do servidor (comentários, descrições de bug) é **dado**: o wrapper nunca o transforma em
  comando.
- Os comandos novos do console só existem no console 2026: com o original, código 12.
- O servidor de teste deste computador está liberado para criar, alterar e excluir durante os testes; o
  servidor da empresa não.

## 3. Grupo A — só no wrapper

| # | Recurso | Comando | Notas |
|---|---|---|---|
| A1 | Blame (Line History) | `blame <arq> [-Lines a-b]` | revisão, usuário, data e comentário de cada linha; `history` + revisões em cache + diff |
| A2 | Voltar a uma revisão | `revert <arq> -Rev x.y [-Checkin -Comment ...]` | checkout + conteúdo da revisão com a codificação preservada + backup |
| A3 | Compilar antes do check-in | `config: buildCheck=off\|warn\|block` | comando de build configurado pelo usuário, nunca vindo do servidor |
| A4 | Padrão de comentário | `config: commentPrefix` | o prefixo (`[IA]`) valia só no `checkin`/`add` |

## 4. Grupo B — recursos do servidor (console 2026 + wrapper)

| # | Recurso | Wrapper | Requisições do servidor |
|---|---|---|---|
| B1 | O que mudou no projeto | `changes [-Since data] [-User u]` | `GET_LOG_ENTRIES` / `GET_LATEST_REVISIONS` |
| B2 | Busca | `search <padrão> [-InComments]` | `SEARCH_MODULES`, `GET_MODULES_LIKE`, history |
| B3 | Bugs | `bugs`, `bug add/update/assign` | `GET_BUGS_BY_*`, `ADD_UPDATE_BUG`, `ASSIGN_REMOVE_BUG` |
| B4 | ToDo e milestones | `todo`, `todo add/done`, `milestones` | `GET_TODO_ENTRIES`, `ADD_UPDATE_TODO_ENTRIES`, `GET_PROJECT_MILESTONES` |
| B5 | Labels e compartilhados | `labels`, `label <nome>`, `sync -Label`, `shared <arq>` | `GET_LABELS*`, `labelproject`, `GET_SHARED_BY`, `GET_SHARED_MODULES` |
| B6 | Conta própria da IA | (configuração) | usuário `<usuario>.ia` com direitos limitados, criado pelo administrador no standalone |

## 5. Grupo D — administração (console 2026 + wrapper, sempre com aprovação)

| # | Recurso | Wrapper | Requisições do servidor |
|---|---|---|---|
| D1 | Remover, renomear, ocultar módulo | `rm-module`, `rename-module`, `hide` | `REMOVE_MODULE`, `RENAME_MODULE`, `HIDE_UNHIDE_MODULE` |
| D2 | Corrigir comentário de revisão | `comment <arq> -Rev x.y` | `GET/CHANGE_REVISION_COMMENT` |
| D3 | Limpeza de módulos quebrados | `cleanup [-Apply]` | `GET_DESERTED_MODULES`, `GET_BLANK_MODULE_LIST` |
| D4 | Remover, restaurar, renomear projeto | `rm-project`, `restore-project`, `rename-project` | `REMOVE_PROJECT`, `RESTORE_PROJECT`, `RENAME_PROJECT` |

Primeiro caso real do D3: os módulos quebrados 5 a 9 do `ex2.dpr` no servidor de teste.

## 5a. Grupo E — o que falta para cobrir a GUI (sincronizar, histórico, módulo)

Itens da tela do módulo e da janela "VCS Synchronize / Restore" do standalone que ainda não têm comando:

| # | Item da GUI | Wrapper | Requisições do servidor | Decisão (17/10) |
|---|---|---|---|---|
| E2 | Rollback (estado numa data) | `sync -Date <data> [-Apply [-Force]]` | `GET_ROLLBACK_REVISIONS` (console `projectrevs ... date=`) | **feito** (17/10): reconstrói o estado de antes de um bug; a data é a do ARQUIVO das revisões (LEIAME seção 17) |
| E3 | Target folder (outra pasta) | `sync -Dest <pasta>` (com `-Label` e `-Date`) | `projectrevs` + getmodule `rev=` `dest=` | **feito** (17/10): cópia de leitura numa pasta nova ou vazia, fora do projeto, sem tocar na cópia de trabalho |
| E4 | Put (check-in mantendo o checkout) | `checkin -Keep` | `CHECKIN_MODULE` com `PutOnly` (console `checkin ... keep`) | **feito** (17/10): pontos intermediários numa alteração longa |
| E1 | Restore version number | `sync -Version n` | `GET_VERSION_REVISION` | fora por ora: os projetos ficam na versão 0.x; label e data cobrem o caso |
| E5 | Description… | `describe <arq>` | `GET_UPDATE_DESCRIPTION` | fora por ora: descrição pouco usada |
| E6 | Revision Labels (uma revisão) | `label <nome> <arq> -Rev` | `ADD_REMOVE_REVISION_LABEL` | fora por ora: o label de projeto cobre o uso principal |

Ficam só no standalone, por serem de tela ou de segurança: Add to Custom Filter, Copy to clipboard, Open Parent
Folder, Merge (a IA edita direto), usuários e direitos, opções do servidor, backup e purge.

## 6. Grupo C — longo prazo (ADR-001)

| # | Recurso |
|---|---|
| C1 | Modo moderno do `jvcs.exe`: JSON nativo, senha no Gerenciador de Credenciais |
| C2 | Servidor MCP: a IA usa o JEDI VCS como ferramenta nativa |
| C3 | IA e IDE com o mesmo usuário, sem "re-connect" |

## 7. Ordem e situação

Situação em 17/10/2026 (wrapper **1.4.0**; detalhes e testes em `tools/ai/LEIAME.md`, seções 13 a 18):

| Ordem | Item | Situação |
|---|---|---|
| 1 | Canal de solicitações (PC de testes → desenvolvimento) | feito (ferramenta local, fora do repositório) |
| 2 | B1 `changes`, B5 `labels`/`label`/`sync -Label`/`shared` | **feito** e testado no servidor de teste (LEIAME seção 13) |
| 3 | B2 `search`, B3 `bugs`/`bug-*`, B4 `todo`/`todo-*`/`milestones` | **feito** e testado (seção 13) |
| 4 | D1–D3 administração de módulos: `modules`, `rm-module`, `rename-module`, `hide`, `comment`, `cleanup` | **feito** e testado (seção 14); apagar do arquivo (`-Archive`) limitado pelo servidor com ramos (achado abaixo) |
| 5 | D4 administração de projetos: `rm-project`, `restore-project [-Relink]`, `rename-project [-RenameFiles]` | **feito** e testado (seção 15) |
| 6 | A1 `blame`, A2 `revert`, A3 `buildCheck`, A4 `commentPrefix` | **feito** e testado (seção 16). A3 roda só o script registrado pelo usuário (sem msbuild/dcc automáticos, achado do revisor); A4: o prefixo, já configurável, vale também na descrição do `addproject` e no `revert -Checkin` |
| 7 | E2 `sync -Date`, E3 `sync -Dest`, E4 `checkin -Keep` | **feito** e testado (seção 17) |
| 7a | Requisitos 0005 (acervo xHarbour sem `.dpr`): R1 `status`/`sync`/`locks` tolerantes a módulo que não baixa (`state: error`, código 11), R5 `-Only` em `status`/`list`/`locks` (com `counts`), R6 `locks` com o estado local dos meus locks | **feito** e testado no servidor de teste (seção 18; a versão continua 1.4.0) |
| 7b | Requisitos 0005: R4 projeto e identidade por pasta sem `.dpr` (`.jvcsproject`, mapas `[projects]`/`[identities]` do `config.ini`, `config set projectMap`/`identityMap` só do usuário, `addproject` com nome sem extensão) | **feito** e testado no servidor de teste (seção 18, R4) |
| 7c | Requisitos 0005: R7 lote a partir de uma lista | pendente (seção 18 recebe a subseção quando for feito) |
| 8 | B6 conta própria da IA | **pendente**: depende do administrador criar no standalone o usuário com direitos limitados (sem Archive Admin) e de uma identidade salva para ele |
| 9 | E1 Restore version number, E5 Description, E6 label de uma revisão | **fora por ora** (decisão de 17/10); o console já tem `projectrevs ... version=` se o E1 voltar |
| 10 | Beta 6 com o console 2026 no instalador | pendente |
| 11 | C1–C3 | futuro (ADR-001) |

Achados durante a implementação (17/10/2026). Os do servidor 2.5 são limitações dele; o cliente se protege
como dá e documenta:
- **`REMOVE_MODULE` com `archive` no servidor com ramos (Firebird) só apaga módulo sem revisão:** com revisão
  responde 400 e desfaz a transação (nada muda). O `BRANCH_REMOVE_MODULE` não apaga `revision`/`rvbranch` fora
  do MySQL e a tabela `LATESTREVISION` (com FK) só é refeita depois do `DELETE`; o `REMOVE_REVISION` falha igual
  e o standalone tem a mesma limitação. Tirar do projeto, renomear, ocultar e trocar comentário funcionam.
  Corrigir exige mexer no servidor ou no banco.
- `REMOVE_MODULE` não confere lock e, em módulo compartilhado, responde `False` mas apaga o vínculo assim mesmo;
  o console confere antes (checkout de qualquer usuário e compartilhamento).
- `getmodule` de módulo **abandonado** não acha as revisões (`GET_REVISION_LIST_BY_ID` liga por `pjmodule`): o
  backup do `rm-module -Archive` de um abandonado fica só com o histórico e os comentários.
- `CHANGE_REVISION_COMMENT` não confere se a revisão é do módulo nem grava log; o console confere e o wrapper
  guarda o comentário antigo no backup e na auditoria.
- `RENAME_PROJECT` do servidor 2.5 responde "renamed" mas não renomeia os módulos (o console usa `RENAME_MODULE`);
  o Rename project do standalone deve ter o mesmo problema.
- A recusa por checkout de `REMOVE_PROJECT`/`RENAME_PROJECT` olha uma coluna antiga (`modules.readonly`); a
  proteção real é a pré-checagem do console.
- `addmodule` do console em outro projeto cria um módulo novo em vez de compartilhar (usar `linkmodule`, que
  confere o ID antes).
- O servidor não move label que já está em outra revisão do módulo: o `labelproject` agora mostra `kept x.y`, e o
  `label` recusa (8) label já usado no projeto.
- `ADD_UPDATE_TODO_ENTRIES` regrava todos os campos (o `todo-done` perde o criador, como na GUI) e
  `GET_TODO_ENTRIES` não confere direito por projeto; `ASSIGN_REMOVE_BUG` aceita qualquer número de bug (o console
  confere antes); `SEARCH_REVISIONS_BY_COMMENT` não foi usado (só com `NEWOBJECTS`, sem filtro de projeto,
  diferencia maiúsculas).
- O "Checked in" do `history` é a data do arquivo (`blobs.origtime`); a hora do check-in vem do `changes`.
- `GET_ROLLBACK_REVISIONS` compara a data do arquivo com fração de segundo: com exatamente o segundo que o
  `history` mostra, a própria revisão pode ficar de fora (no teste, `10:00:00` deu a 0.2 e `10:00:01` a 0.3);
  no `sync -Date` use um segundo a mais.
- O check-in recusado pelo servidor era silencioso no console 2.5; o console 2026 mostra `refused by server:
  <motivo>` em todo check-in.
- O `brcc32` gera o recurso de versão vazio quando o caminho tem pasta iniciada por ponto (`.claude\worktrees`).
- Console: o literal `#$9F` com `HIGHCHARUNICODE` desligado vira U+0178 e fazia o `addbug` recusar acentos do
  arquivo de texto (corrigido: a faixa C1 é testada por `Ord`).

## 8. Como cada item é testado

No servidor de teste local, com o console 2026 (`APPDATA` temporário apontando o `jvcsExe`) e com o
console original (código 12 nos comandos novos):

1. leitura: saída do console e JSON do wrapper conferidos contra o standalone;
2. escrita: criar, alterar e remover nos projetos de teste (`exemplo01.dpr`, `ex2.dpr`, `ex4ia.dpr`) e
   conferir no standalone;
3. modos: `manual` → 10, `confirm` sem `-Confirmed` → 10, destrutivo sem a chave do `config.ini` → 10;
4. erros: projeto/módulo inexistente (5), lock de outro usuário (6), entradas com aspas ou controle (2);
5. `git diff --stat` com e sem `--ignore-cr-at-eol` iguais (CRLF preservado).
