# Changelog

English: see [news/en](news/en/README.md) and each release page (English summary).

Todas as mudanças relevantes do **JEDI VCS 2.5 Beta 2026**. Formato baseado em
[Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/). Anúncios com mais detalhes em [`news/pt/`](news/pt/README.md).

## [Não publicado]

### Corrigido
- (em andamento) AV ao clicar na barra de ferramentas do JEDI VCS dentro de IDEs antigas (ex.: XE3).

## [Beta 4] — 2026-10-13

### Adicionado
- Instalador: escolha individual de cada Delphi (11, 12, 13 e antigas); aviso de isenção de garantia com aceite obrigatório.
- Instalador integra as IDEs antigas suportadas pelo 2.5.0.1030 (Delphi 7, 2005–2010, XE–XE8, 10 Seattle–10.4) com o
  expert original + núcleo novo; detecção por IDE e restauração na desinstalação.
- Skill `jedi-vcs` para o Claude Code no instalador; guia de uso com IA (`doc/ia`).
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

[Beta 4]: https://github.com/edmarfrazao/JEDI_VCS/releases/tag/v2.5.0.2026-beta4
[Beta 2]: https://github.com/edmarfrazao/JEDI_VCS/releases/tag/v2.5.0.2026-beta2
[Beta 1]: https://github.com/edmarfrazao/JEDI_VCS/releases/tag/v2.5.0.2026-beta1
