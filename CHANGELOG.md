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
