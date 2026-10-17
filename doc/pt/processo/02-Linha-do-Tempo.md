# 02. Linha do tempo

Fases do [Plano de Port](../common/Plano-de-Port.md) (F0–F6) com datas e commits-chave, a partir do
`git log` e do [CHANGELOG](../../../CHANGELOG.md). Todas as datas são de 2026. Anterior:
[01 História](01-Historia-e-Motivacao.md). Próximo: [03 Decisões](03-Decisoes-de-Arquitetura.md).

## Resumo

| Fase | Objetivo | Quando | Situação |
|---|---|---|---|
| F0 | Ambiente, dependências, build, linha de base | 12/10 – 13/10 | Pronta no essencial (D13 e D11 montados, `.dproj` e build multi-versão) |
| F1 | MidWare portado e teste golden de tráfego | 12/10 | MidWare portado; golden do console idêntico ao original. Falta `JVCSTransport.pas` |
| F2 | Núcleo do cliente e console `jvcs.exe` | 12/10 | **Pronto e validado** (saída e fio idênticos ao 2.5.0.1030) |
| F3 | Infraestrutura de GUI e `JEDIVCSDiff.exe` | 12/10 | **Pronto** (Diff + `JVCSUIScale`/`JVCSUITheme`) |
| F4 | EXE standalone `Jedivcs.exe` | 12/10 – 13/10 | **Três etapas prontas**; JVCL mantida (decisão de 13/10) |
| F5 | DLL da IDE, expert ToolsAPI e instalador | 12/10 – 13/10 | **Beta publicado**; expert para BDS 22/23/37 |
| F6 | Win64 / ARM64EC (opcional) | — | Não iniciada (bloqueada pela `fvcscrypt.dll`) |

Releases: `v2.5.0.2026-beta1` (commit `5a31446`, 13/10) e `v2.5.0.2026-beta2` (commit `b59378b`, 13/10).

## 12/10 — Estrutura, análise e primeiros ports

| Etapa | Commits-chave | O que aconteceu |
|---|---|---|
| F0 — árvore base | `3cb5f17` | Estrutura `v2026` com a cópia de menor edição Lazarus de cada arquivo e os `.dpr`/`compopt.inc` originais |
| F0 — inventário e plano | `62f9c8f` | 201 units em 9 famílias, 21 riscos, plano F0–F6 ([Inventario](../common/Inventario-Componentes.md)) |
| F0 — bibliotecas fixadas | `e449770`, `f1e93e0` | SynEdit (pyscripter `84391a3`) e Virtual-TreeView V8.5 dentro do repositório; alvo `libs` no `compilar.bat` |
| F5A — expert novo com a DLL original | `2da6873`, `f7fb8c2`, `b18ce6c`, `e8de62e` | Análise do expert 2.5.0.1030 e novo `JvcsExpertBDS37.dll` carregando a `JvcsExternalDll.dll` **original** no Delphi 13.2 |
| Requisitos | `d2dd0ad`…`5a56e52`, `f51ba29`, `c09ecc3` | Tamanho de fonte, tema claro/escuro, famílias `.pas+.dfm/.fmx`, recursos de 2012 mantidos |
| Engenharia reversa | `d84aaf1`, `6c59cb8`, `3287ec1` | 107 DFMs extraídos; CRC, BFCrypt, protocolo e `mwPasLex` recuperados do binário |
| Servidor de teste | `92ed77a`, `bbaa80a`, `3480d71` | Servidor 2.50 Beta 3 + Firebird 2.5.9; banco atualizado para o esquema 2.5; causa raiz do erro ODS 11.2/11.1 |
| IA (camada 0) | `e4173b3`, `9e6b60e`, `672f94c`, `0351808`, `8b300de` | ADR-001, decisões da IA e wrapper `tools\ai\jvcs-ai.ps1` sobre o `jvcs.exe` original |
| F1 — MidWare | `8480966`, `7e87a67` | `Checksum.pas` recriado; `ApsCli`/`RFormat`/`CBroker` Unicode com cp1252 no fio, ICS 9 |
| F2 — console | `4ff6419`, `b809556`, `b4d60e6`, `fe5086d`, `2d62984` | `jvcs.dpr` compila; golden idêntico; blob ZIP com a data do arquivo; `BRANCHING` mantido no console |
| F4 — EXE (1ª etapa) | `94865dd`, `8a81efa`, `29fb256` | Substitutos nativos das units ausentes; `Jedivcs.dpr` compila e passa no teste básico |
| F3 — Diff e aparência | `97fb937`, `c55a861`, `b2a6f94` | `JVCSUIScale`/`JVCSUITheme`; `JEDIVCSDiff` compila sem JVCL/JCL/DFS |
| F5 — DLL | `3a67d79`, `3a5cf40`, `d8f20e0`, `2a7af98`, `6bf3700` | `JvcsExternalDll.dll` nova com a ABI ANSI; harness fora da IDE (nova e original, 0 AV) |

## 13/10 — Aparência, instalador, multi-Delphi e testes

| Etapa | Commits-chave | O que aconteceu |
|---|---|---|
| F4 — 2ª etapa | `bba5fea`, `ec0c488`, `5bbec45`, `ffe5d15`, `7c70277` | Páginas Appearance e AI / Automation; `TJVCSForm` em todos os forms; tema contido na IDE; log de erros |
| Testes da DLL | `127f329` | Host interativo (Fake IDE `TAppBuilder`) |
| Correções | `33e3cba`, `61bcef9`, `c037178`, `6f845ef`, `0a44cc2` | Lentidão ao abrir projeto, crash por valor no registro, senha da identidade apagada, layout a 150% |
| Instalador | `28e2743`, `f175cc4`, `646bd06`, `534bc8b` | Inno Setup + `gerar-instalador.bat`; capítulo 09 do manual |
| Licença e segurança | `cde6ae9`, `1aa4c0b`, `68adddb`, `5a31446` | `LICENSE` (MPL 1.1), `.gitignore`/`.claude/settings.json` contra credenciais, aviso do MidWare no README, About e console → **beta1** |
| Multi-Delphi | `0912562`, `d3a730a`, `c1d0ddc`, `85942a4`, `47d3584`, `e98ca78`, `f78b0ea` | `compilar.bat /delphi:NN` (11, 12 ou 13); expert sem `designide` (carrega em todas as atualizações); `.dproj` + `JediVCS2026.groupproj`; decisão "expert fino + núcleo único" |
| F4 — 3ª etapa | `bdcda0c`, `c439db7`, `b61088a`, `2378a76`, `e6455e2`, `2d8b2f8`, `04927fe`, `0202a19`, `361eba9`, `81e7058` | `-formsweep` e automação de teste; JVCL simples → VCL; escala 175–200%; bugs Unicode; ExtBugtracker com `TRegEx`; testes funcionais |
| Testes remotos | `0971f1c` | Canal assinado (HMAC) entre o Claude do PC de desenvolvimento e o do PC remoto (Delphi 11, 12, 13.1) |
| Ajustes finais | `55663f0`, `37a15a6`, `d0d9994`, `b59378b` | Mensagens do expert, aviso de projeto antes do login, tema real da IDE (`JVCS_IDE_THEME`), log padrão do expert, Documentos no OneDrive → **beta2** |

## O que ainda falta (resumo)

Detalhes no [CHANGELOG](../../../CHANGELOG.md) e nas seções "Pendências" de cada `doc/pt/client/Port-*.md`.

- `JVCSTransport.pas` (isolar o MidWare) e suíte golden automatizada em várias code pages.
- Restante da JVCL visual (~66 objetos, principalmente `TJvSpinEdit`) e da JCL.
- `mdMailSlot` (notificação) só compila; relatórios e tradução desligados.
- Win64/ARM64EC (F6) depende de substituir a `fvcscrypt.dll`.
