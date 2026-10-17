# Changelog

English: see [news/en](news/en/README.md) and each release page (English summary).

Todas as mudanças relevantes do **JEDI VCS 2.5 Beta 2026**. Formato baseado em
[Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/). Anúncios com mais detalhes em [`news/pt/`](news/pt/README.md).

## [Não publicado]

### Adicionado
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
- Skills pt/en (bloco "Mais recursos"), referências do console e guias `doc/pt/ia` atualizados; modelo de
  settings 1.3.0 com regras `ask` para a administração.

### Alterado
- Console: check-in recusado pelo servidor deixa de passar em silêncio e vira erro com o motivo
  (`refused by server: ...`); `labelproject` mostra `added` ou `kept x.y` por módulo.

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
- Canal de testes entre PCs (`tools/canal`).

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

[Beta 5]: https://github.com/edmarfrazao/JEDI_VCS/releases/tag/v2.5.0.2026-beta5
[Beta 4]: https://github.com/edmarfrazao/JEDI_VCS/releases/tag/v2.5.0.2026-beta4
[Beta 2]: https://github.com/edmarfrazao/JEDI_VCS/releases/tag/v2.5.0.2026-beta2
[Beta 1]: https://github.com/edmarfrazao/JEDI_VCS/releases/tag/v2.5.0.2026-beta1
