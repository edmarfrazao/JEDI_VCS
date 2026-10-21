# Changelog

English: see [news/en](news/en/README.md) and each release page (English summary).

Todas as mudanças relevantes do **JEDI VCS 2.5 Beta 2026**. Formato baseado em
[Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/). Anúncios com mais detalhes em [`news/pt/`](news/pt/README.md).

## [Não publicado]

### Adicionado
- Links para o **jvcs2git** (https://github.com/edmarfrazao/jvcs2git), exportador dos projetos para Git com todo o histórico, no README (en/pt), nos índices de `doc/pt` e `doc/en` e nas skills `jedi-vcs` (pt/en).

## [Beta 6, build 2063] — 2026-10-19

### Corrigido (build 2063)
- Wrapper da IA, `verify -Text`: a linha mostra o veredito (`ambiguous`, `notVersioned`...), não o `state` do status, e
  `projetos:` lista os nomes do `ambiguous` (antes `projetos: , `).
- Wrapper da IA, `verify <arquivo>...`: confere arquivos avulsos sem o Git, com a mesma lógica (o filtro de extensões
  não vale para eles).
- Segurança do wrapper (revisão de 17/10; detalhes em `tools/ai/LEIAME.md` §20):
  - `config set` exige "SIM" digitado no console (a detecção de IA é heurística);
  - `-Confirmed` vindo de um script chamador não vale como aprovação;
  - `-Identity` diferente da padrão, pela IA, exige `-Confirmed`;
  - `jvcs.exe` fora de Arquivos de Programas fica preso ao SHA-256 (`jvcsExeSha256`);
  - `undocheckout` sem alteração vale também com `checkin=manual`;
  - `sync`: arquivo mais antigo, gravável e diferente do servidor é conflito, não atualização;
  - `show -Dest` recusa pasta do projeto ou de módulo;
  - hook: `Write` que recriaria um módulo apagado é negado;
  - template de permissões 1.4.0 (`deny` para `Software\JEDI`/`reg export`; `ask` para `-Identity` e cópia/remoção
    forçada) e skills com `sync -Dest ... -Apply`, os estados que faltavam e o código 1.
- Testes novos `tests/ia/teste-seguranca.ps1` e `teste-verify.ps1` ampliado.

### Problemas conhecidos
- Pela IA, `-Identity` igual à identidade que o mapa `[identities]` do `config.ini` dá para a pasta ainda pede
  `-Confirmed` (a comparação é com a identidade padrão). Fica para o próximo build.

### Corrigido (build 2062, interno, não publicado)
- Wrapper da IA, `verify` sem projeto definido (pasta sem `-Project`, `.jvcsproject`, mapa nem `.dpr`): todos os
  arquivos saíam `notVersioned`, inclusive módulos em checkout. Agora:
  - o módulo é procurado em todos os projetos não excluídos (como o `untracked`); em 1 projeto usa esse, em 2+ sai
    `ambiguous` com os projetos;
  - os arquivos que nunca vão ao JEDI VCS (`.md`, `.ps1`...) são ignorados: por padrão só confere as extensões que
    existem como módulo no servidor; a chave nova `verifyExtensions` do `config.ini` muda o filtro (`all` ou lista);
  - `counts` traz `checked`, `unresolved` e `ignored`; só arquivos sem projeto definido → 11.
- Wrapper da IA, resumo do `status` (e `list`/`locks`, `status -AllProjects`): o módulo com erro contava duas vezes
  (no estado local e em `error`) e a soma passava do total. Agora `error` é exclusivo; o `-Only` continua achando o
  módulo pelos dois.
- Teste novo `tests/ia/teste-verify.ps1` (no `tests\executar.bat`).

### Documentação
- Tópico novo **Créditos e direitos** ([`doc/pt/common/Creditos-e-Direitos.md`](doc/pt/common/Creditos-e-Direitos.md),
  em inglês [`doc/en/08-Credits-and-Rights.md`](doc/en/08-Credits-and-Rights.md)). Ele cobre:
  - os criadores e mantenedores do FreeVCS/JEDI VCS, os direitos da MPL 1.1 e os componentes de terceiros;
  - a exigência da `FVCSCrypt.dll` (32 bits, sem fonte, obrigatória para o login) e por que não há cliente de 64 bits;
  - como o port de 2026 foi feito (análise, alterações e testes com o Claude Code, modelo Claude Opus 5.5).
  Links no `README`, nos índices de `doc/` e no `Licencas.md`.
- Plano de Port: a F7 (IDE de 64 bits do Delphi 13.2) ficou **adiada**; a IDE de 64 bits usa o cliente standalone.
- Pasta `instalador/` (`bin`, `config`, `doc`) com os bats para gerar, conferir, copiar e versionar o setup à mão
  ([`instalador/doc/COMO-GERAR.md`](instalador/doc/COMO-GERAR.md)).
- Pasta `tests/` com os testes automatizados (console, wrapper da IA e instalador isolado), sem caminhos fixos nem
  senha (a senha vem da identidade DEFAULT pelo stdin): [`tests/LEIAME.md`](tests/LEIAME.md). Rodam por `tests\executar.bat`.
- O repositório passa a ter só os fontes, a documentação oficial (incluindo como compilar e como testar), os
  instaladores e os binários. Notas de ambiente local, `.reg` de desenvolvimento e registros de sessões saíram do Git
  (`.gitignore`), e os documentos foram revisados para não depender deles.

## [Beta 6] — 2026-10-17 (build 2061)

### Adicionado
- Wrapper da IA (requisitos S0002, no build 2061; ainda 1.4.0). Ver `tools/ai/LEIAME.md` §19.
  - `untracked` (fontes fora do JEDI, por pasta ou pelo `.xbp` do xBuild) e `verify -FromGit|-Since` (o que mudou no Git
    e está atrás no JEDI).
  - `status -AllProjects`, `locks -OlderThan` (com `lockedAtLocal`/`lockAgeDays`; a hora do lock vem em UTC) e
    `doctor`/`ping`.
  - `add -Preview`, `checkin -CommentFromGit` e `diff -Encoding oem|ansi`.
- Instalador com o console `jvcs.exe` 2026 (os comandos novos abaixo) e o wrapper da IA 1.4.0; versão
  `2.5.0.2061` (`tools/versao.ini`; o 2060 foi o 1º setup do beta 6, testado nas IDEs; o 2061 é a recompilação de
  correção, com as correções do console e a S0002). Novidades: [`news/pt/2026-10-17-beta6.md`](news/pt/2026-10-17-beta6.md).
- Console `jvcs.exe`: criar projeto e módulos **sem IDE** — `addproject`, `addmodule` (grava também a
  pasta local) e `setmodulepath`; `checkin` faz o 1º check-in (0.1) de módulo recém-criado. Ver
  `doc/pt/client/Port-Console.md` §5.
- 1º check-in pelo console envia também a família do módulo (o `.dfm` de uma unit), como o standalone.
- Wrapper da IA `tools/ai/jvcs-ai.ps1` 1.2.0: `diff <arq> [-Rev x.y]` (diff contra a revisão do
  servidor; funciona com o console original), `addproject` e `add` (cadastro + 1º check-in; exigem o
  console 2026 e seguem o modo de check-in). Skills pt/en e guias atualizados.
- Console `jvcs.exe`: comando `history <módulo>` (revisões com data, usuário, família e comentário de
  check-in, como a janela History do standalone).
- Wrapper da IA 1.3.0: `history` (console 2026), `show -Rev` (revisão antiga numa pasta de consulta),
  `diff -Rev x.y -Rev2 y.z` (entre duas revisões) e `sync` (prévia; `-Apply` baixa e atualiza a cópia local
  com backup, nunca mexe no checkout do usuário e não sobrescreve alteração local sem `-Force`). Ver
  `tools/ai/LEIAME.md` §12.
- Wrapper da IA 1.4.0, grupo B (recursos do servidor; console 2026): `changes` (check-ins do projeto desde uma
  data, com a hora real, pelo log do servidor), `search` (módulos por máscara em todos os projetos, ou texto nos
  comentários com `-InComments`), `labels`/`label`/`sync -Label`/`shared`, `todo`/`todo-add`/`todo-done`/
  `milestones` e `bugs`/`bug-add`/`bug-update`/`bug-link`. Console: `projectlog`, `searchmodules`,
  `searchcomments`, `listlabels`, `labelrevs`, `modulelabels`, `sharedby`, `sharedmodules`, `listtodo`, `addtodo`,
  `donetodo`, `listmilestones`, `listbugs`, `bugsummary`, `addbug`, `updatebug`, `assignbug`. Ver
  `tools/ai/LEIAME.md` §13.
- Grupo D, administração de módulos: `modules`, `rm-module`, `rename-module`, `hide`, `comment` (trocar o
  comentário de uma revisão) e `cleanup` (lixo de teste e módulos quebrados), sempre com prévia, backup e
  aprovação; o `-Apply` exige `moduleAdmin=on|archive` no `config.ini`. Console: `listmodules`, `listdeserted`,
  `removemodule`, `renamemodule`, `hidemodule`, `getcomment`, `setcomment`. Ver §14.
- Grupo D, administração de projetos: `rm-project`, `restore-project [-Relink]` (religa módulos e grupos pelo
  registro gravado antes da remoção) e `rename-project [-RenameFiles]`; o `-Apply` exige `projectAdmin=on`.
  Console: `projectinfo`, `removeproject`, `restoreproject`, `renameproject` (com a palavra `confirm`),
  `linkmodule`, `projectgroups`, `setprojectgroup`. Ver §15.
- Grupo A: `blame` (revisão, usuário e comentário de cada linha, como o Line History), `revert -Rev x.y
  [-Checkin]` (volta a uma revisão com checkout e backup) e compilação antes do check-in (`buildCheck`
  `off|warn|block`, só com o script registrado pelo usuário em `buildCommand`, conferido por SHA-256). Ver §16.
- Grupo E: `sync -Date` (rollback ao estado de uma data, como a aba Rollback), `sync -Dest` (exporta o estado
  para uma pasta nova, como cópia de leitura) e `checkin -Keep` (Put: revisão nova mantendo o checkout).
  Console: `projectrevs` e `checkin ... keep`. Ver §17.
- Requisitos S0001 (acervo xHarbour), ainda no wrapper 1.4.0. Ver §18.
  - R1: `status`/`sync` toleram falha por módulo: o módulo sai com `error`, os outros seguem, código 11 parcial e
    manifesto `complete`/`skipped`.
  - R4: projeto e identidade por pasta sem `.dpr`, por `.jvcsproject` ou pelos mapas `projectMap`/`identityMap`
    do `config.ini`; `addproject` aceita nome sem extensão.
  - R5: filtro `-Only` em `status`, `list` e `locks`.
  - R6: `locks` com `localState` (`-NoLocalState` desliga).
  - R7: operação em lote com `-FromList`, com prévia, `-ListHash` e um único `-Confirmed`.
- Skills pt/en (bloco "Mais recursos"), referências do console e guias `doc/pt/ia` atualizados; modelo de
  settings 1.3.0 com regras `ask` para a administração.

### Alterado
- Wrapper: opção desconhecida vira erro de uso (2), em vez de ser lida como nome de arquivo; a falha de conexão diz se a
  porta do servidor responde.
- `tools/gerar-instalador.bat`: com a variável `JVCS_COPIA_SETUP`, copia o setup gerado para a pasta de distribuição
  e regrava o `SHA256.txt` dela (`tools/copiar-setup.ps1`).
- Instalador: a tarefa "Usar o console novo na automação por IA" (`aiconsole`) vem **marcada** e grava
  `jvcsExe` no `config.ini` da IA. Numa atualização de versão anterior ao build 2060 (em que vinha desmarcada)
  ela é marcada uma vez e pode ser desmarcada, mesmo que a pasta mude; com `/TASKS=`, `/MERGETASKS=` ou `/LOADINF=` vale o
  que foi pedido.
- Console: check-in recusado pelo servidor deixa de passar em silêncio e vira erro com o motivo
  (`refused by server: ...`); `labelproject` mostra `added` ou `kept x.y` por módulo.
- Console: `removemodule <módulo> archive` passa a exigir a palavra `confirm` (`removemodule <módulo> archive confirm`),
  como `removeproject` e `renameproject`: apagar do arquivo não tem volta.
- Console: o `/input` sem BOM é lido em cp1252 (a code page do fio) em qualquer ACP do Windows, como no 2.5.0.1030;
  com "UTF-8 beta" (ACP 65001) os acentos chegavam trocados ao servidor. Com BOM, vale o BOM.

### Problemas conhecidos (servidor 2.5)
- Com ramos (Firebird), `REMOVE_MODULE` com `archive` só apaga módulo **sem revisão**: com revisão responde 400 e
  desfaz (o standalone tem a mesma limitação). Tirar do projeto, renomear, ocultar e trocar comentário funcionam.
- `RENAME_PROJECT` responde "renamed" mas não renomeia os módulos (o console usa `RENAME_MODULE` módulo a módulo).
- A recusa por checkout de `REMOVE_PROJECT`/`RENAME_PROJECT` olha uma coluna antiga; quem protege é a checagem
  do console. `REMOVE_MODULE` não confere lock e, em módulo compartilhado, apaga o vínculo mesmo respondendo
  `False` (o console confere antes).
- O servidor não move label que já está em outra revisão; `ADD_UPDATE_TODO_ENTRIES` regrava todos os campos do
  item; `CHANGE_REVISION_COMMENT` não grava log. Lista completa: `doc/pt/ia/08-Plano-de-Recursos.md` §7.

### Corrigido
- Console: `getmodule` recusava `rev=` + `dest=` + `noprompt` juntos (bug do original).
- Console: `checkin`/`checkout`/`undocheckout`/`getmodule` pelo nome curto de módulo com pasta gravada.
- Console: `addmodule` de um arquivo que já é módulo (mesma pasta, na forma longa, 8.3 ou mista) criava um módulo
  duplicado sem revisão. Agora avisa `Module already in project`; se o módulo é de outro projeto, liga-o ao projeto
  aberto (`Module linked`).
- Console: 1º check-in recusado pelo servidor, `addproject` de projeto que já existe e pasta não gravada (`addmodule`,
  `setmodulepath`) mostravam a ajuda do comando e saíam com código 0. Agora o 1º check-in recusado é erro com o motivo
  (`refused by server: ...`), o projeto existente é avisado sem a ajuda e a pasta não gravada é erro.
- Console: `removemodule` com resposta `False` sem a lista de projetos anunciava "project link removed"; agora é erro.
- Console: `getmodule ... dest=` recusava qualquer nome com `..` no meio (ex.: `a..b.pas`); agora recusa só um segmento
  `..`.

## [Beta 5] — 2026-10-13 (build 2050)

### Adicionado
- Numeração de versão no padrão do JEDI VCS original (`2.5.0.<build>`, beta 5 = 2050) com fonte única `tools/versao.ini`; versão visível no título, About, console, Painel de Controle e nome do instalador. `PRODUCTVERSION` fixo em 2.5.0.0 (login 250).


### Alterado
- Documentação e skill organizadas por idioma: `doc/pt` (toda a documentação em português), `doc/en` e
  `doc/README.md` como seletor de idioma; skill `jedi-vcs` em `skills/pt/jedi-vcs` e, nova, em inglês em
  `skills/en/jedi-vcs` (mesmo nome: instale só uma). O instalador copia as duas para
  `tools\ai\skills\pt\jedi-vcs` e `tools\ai\skills\en\jedi-vcs` e remove a pasta antiga `tools\ai\skills\jedi-vcs`.

### Corrigido
- AV ao clicar na barra de ferramentas, no Get do diálogo de revisões e em menus do JEDI VCS dentro de IDEs antigas (ex.: XE3): o núcleo agora tem a própria janela de aplicação.

## [Beta 4] — 2026-10-13

### Adicionado
- Instalador: escolha individual de cada Delphi (11, 12, 13 e antigas); aviso de isenção de garantia com aceite obrigatório.
- Instalador integra as IDEs antigas suportadas pelo 2.5.0.1030 (Delphi 7, 2005–2010, XE–XE8, 10 Seattle–10.4) com o
  expert original + núcleo novo; detecção por IDE e restauração na desinstalação.
- Skill `jedi-vcs` para o Claude Code no instalador; guia de uso com IA (`doc/pt/ia`).
- Documentação: README, processo do port, fontes, novidades e changelog.

### Corrigido
- Wrapper da IA: `status` sem `-Project` ignora cópias `X - Copia.dpr` / `X - Copy.dpr`.

## [Beta 2] — 2026-10-13

### Adicionado
- Experts para Delphi 11, 12 e 13 (qualquer atualização); expert sem pacotes de design da IDE; `tools/verificar-expert.ps1`.
- Builds multi-versão (`compilar.bat /delphi:11|12|13`), `.dproj` e `JediVCS2026.groupproj`.
- Páginas Appearance e AI / Automation em VCS Properties; View → Appearance / Font Size.
- Tema "seguir o Delphi" com o tema real da IDE (`JVCS_IDE_THEME`).
- Log de erros do cliente, da DLL e do expert em `%LOCALAPPDATA%\JEDI\JVCS\logs`.

### Corrigido
- Tema escuro com nomes de projetos/módulos invisíveis; menus em branco na IDE escura; janelas atrás da IDE no Alt+Tab.
- Lentidão (~21 s) ao abrir projeto na IDE.
- Login apagava a senha salva da identidade.
- Aviso "sem projeto" e Server Login abertos ao mesmo tempo.
- Compare all, Backup com senha, Line History, Used Units, ExtBugtracker (TRegEx), Save WIP.
- Janelas cortadas a 150–200%; access violation ao sair.

### Alterado
- Componentes visuais da JVCL trocados por VCL nativa em 36 formulários (troca gradual).

## [Beta 1] — 2026-10-13

### Adicionado
- Port do cliente JEDI VCS 2.5 para Delphi 13: standalone, Diff, console e núcleo da IDE com protocolo idêntico ao
  2.5.0.1030 (validado por "golden test").
- Expert do Delphi 13.2; instalador Inno Setup; ferramentas de IA (`tools/ai`).
- Aviso de licença do MidWare no About e no console.

[Beta 6, build 2063]: https://github.com/edmarfrazao/JEDI_VCS/releases/tag/v2.5.0.2026-beta6-build2063
[Beta 6]: https://github.com/edmarfrazao/JEDI_VCS/releases/tag/v2.5.0.2026-beta6
[Beta 5]: https://github.com/edmarfrazao/JEDI_VCS/releases/tag/v2.5.0.2026-beta5
[Beta 4]: https://github.com/edmarfrazao/JEDI_VCS/releases/tag/v2.5.0.2026-beta4
[Beta 2]: https://github.com/edmarfrazao/JEDI_VCS/releases/tag/v2.5.0.2026-beta2
[Beta 1]: https://github.com/edmarfrazao/JEDI_VCS/releases/tag/v2.5.0.2026-beta1
