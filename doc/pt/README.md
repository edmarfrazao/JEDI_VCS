# Documentação do JEDI VCS 2.5 Beta 2026

> **English documentation:** [doc/en/README.md](../en/README.md) — user guide in English (overview,
> installation, IDE integration, standalone client, AI, build, FAQ).

Índice geral da documentação do port do **cliente** JEDI VCS 2.5 para o Delphi 11, 12 e 13 (referência:
Delphi 13 Florence). O servidor **2.5 Beta 3 (Firebird)** não é portado; o cliente novo fala o mesmo
protocolo. Visão geral do projeto, download e licenças: [README.pt-BR.md](../../README.pt-BR.md).

## Comece por aqui

| Você quer... | Leia |
|---|---|
| Instalar e usar | [Manual](manual/README.md) — comece pelo [09 Instalador](manual/09-Instalador-do-Cliente.md) |
| Usar com um assistente de IA | [IA](ia/README.md) e a skill [skills/pt/jedi-vcs](../../skills/pt/jedi-vcs/) |
| Migrar os projetos para o Git com todo o histórico | [jvcs2git](https://github.com/edmarfrazao/jvcs2git) (projeto separado: janela, CLI e skill para IA) |
| Entender o código ou compilar | [Fontes](fontes/README.md) |
| Saber por que e como o port foi feito | [Processo](processo/README.md) |
| Saber onde o projeto está | [CHANGELOG](../../CHANGELOG.md), [novidades](../../news/pt/README.md) e [decisões de arquitetura](processo/03-Decisoes-de-Arquitetura.md) |

## Manual de uso (`manual`)

Manual prático para instalar o servidor 2.5 Beta 3, configurar o cliente e integrar ao Delphi. Índice:
[manual/README.md](manual/README.md).

| Capítulo | O que contém |
|---|---|
| [01 Servidor](manual/01-Servidor-Instalacao-e-Configuracao.md) | Aplicação × serviço, Firebird instalado × embutido, `gbak`, "Logon to Firebird", `jvcssrv.ini`/VirtualStore, porta 2106, backup |
| [02 Cliente: primeiro acesso](manual/02-Cliente-Primeiro-Acesso.md) | Identidade e Server Login, `sysdba`, trocar senha, usuários (você e a IA), grupos, primeiro projeto |
| [03 Integração com o Delphi](manual/03-Integracao-com-o-Delphi.md) | Expert: registro, verificação, reverter, variáveis `JVCS_EXPERT_*`, limitações |
| [04 Opções do cliente](manual/04-Opcoes-do-Cliente.md) | VCS Properties página por página |
| [05 Famílias de arquivos](manual/05-Familias-de-Arquivos.md) | `.pas` + `.dfm` + `.fmx` |
| [06 Linha de comando](manual/06-Linha-de-Comando.md) | `jvcs.exe`: sintaxe, comandos, exemplos |
| [07 Senhas padrão e segurança](manual/07-Senhas-Padrao-e-Seguranca.md) | O que trocar e boas práticas |
| [08 Solução de problemas](manual/08-Solucao-de-Problemas.md) | Sintoma → causa → solução |
| [09 Instalador do cliente](manual/09-Instalador-do-Cliente.md) | Instalar, reparar, desinstalar, componentes, convivência com o original |
| [10 Delphi 11 e 12](manual/10-Delphi-11-e-12.md) | Checklist depois de instalar o Delphi 11/12 |

## IA (`ia`)

| Documento | O que contém |
|---|---|
| [ia/README.md](ia/README.md) | Como assistentes de IA usam o JEDI VCS: instalação, modos de automação, comandos do wrapper, fluxo, segurança |
| [skills/pt/jedi-vcs](../../skills/pt/jedi-vcs/) | Skill para o Claude Code e outros agentes (versão em inglês: [skills/en/jedi-vcs](../../skills/en/jedi-vcs/); ver [skills](../../skills/README.md)) |
| [../tools/ai/LEIAME.md](../../tools/ai/LEIAME.md) | Referência técnica do wrapper `jvcs-ai.ps1` e dos hooks |
| [common/ADR-001](common/ADR-001-CLI-IA-e-Plugin-Multi-Delphi.md) | Decisão de arquitetura: CLI para a IA e núcleo único para todos os Delphi |

## Processo do port (`processo`)

| Página | O que contém |
|---|---|
| [01 História e motivação](processo/01-Historia-e-Motivacao.md) | Fonte perdido, forks, por que só o cliente, protocolo idêntico |
| [02 Linha do tempo](processo/02-Linha-do-Tempo.md) | Fases F0–F6 com datas e commits-chave |
| [03 Decisões de arquitetura](processo/03-Decisoes-de-Arquitetura.md) | Resumo navegável de Decisões e ADR-001 |
| [04 Testes e validação](processo/04-Testes-e-Validacao.md) | Golden, harness, varredura de forms, IDEs, canal, `verificar-expert` |
| [05 Processo de release](processo/05-Processo-de-Release.md) | Gerar, testar no PC de desenvolvimento e no PC de testes, publicar; checklist |
| [06 Problemas conhecidos e lições](processo/06-Problemas-Conhecidos-e-Licoes.md) | O que deu errado e o que ficou de lição |

## Fontes (`fontes`)

| Página | O que contém |
|---|---|
| [fontes/README.md](fontes/README.md) | Projetos e o que geram, pastas de `src`, dependências por alvo |
| [Arquitetura](fontes/Arquitetura.md) | Diagramas, fluxo de um check-in, ABI expert↔DLL |
| [Units principais](fontes/Units-Principais.md) | Tabela das units por área |
| [Compilação](fontes/Compilacao.md) | Scripts, Delphi 11/12/13, `.dproj`/MSBuild, saídas e logs |
| [Convenções](fontes/Convencoes.md) | Codificação, defines, versão, commits, contribuição |

## Comum (`common`)

| Documento | O que contém |
|---|---|
| [CHANGELOG](../../CHANGELOG.md) | Mudanças por versão |
| [Plano-de-Port](common/Plano-de-Port.md) | Plano em fases, critérios de pronto, riscos, checklist de compatibilidade com o servidor |
| [ADR-001](common/ADR-001-CLI-IA-e-Plugin-Multi-Delphi.md) | IA fazendo check-in/check-out e núcleo único para todos os Delphi |
| [Versoes](common/Versoes.md) | Versão do produto, do Delphi, das dependências e dos binários de referência |
| [Componentes](common/Componentes.md) | Componentes, bibliotecas, units ausentes e substitutos nativos |
| [Inventario-Componentes](common/Inventario-Componentes.md) | Inventário completo (201 units), riscos e evidências |
| [Licencas](common/Licencas.md) | Licenças e pontos de atenção (MidWare não comercial, DFS, FastMM5) |
| [Creditos-e-Direitos](common/Creditos-e-Direitos.md) | Criadores e mantenedores, direitos da licença, exigência da `FVCSCrypt.dll` e por que não há 64 bits |
| [Credenciais](common/Credenciais.md) | Como o cliente guarda senhas e a proposta para CLI e IA |
| [LEIAME-Origem](common/LEIAME-Origem.md) e [manifesto-origem.csv](common/manifesto-origem.csv) | De onde veio cada arquivo da árvore |

## Cliente (`client`)

| Documento | O que contém |
|---|---|
| [Port-Console](client/Port-Console.md) | Port do `jvcs.exe` e o teste golden |
| [Port-Diff](client/Port-Diff.md) | Port do `JEDIVCSDiff` e a infraestrutura de aparência |
| [Port-Standalone](client/Port-Standalone.md) | Port do `Jedivcs.exe` (três etapas), varredura de forms, testes funcionais |
| [Port-DLL-IDE](client/Port-DLL-IDE.md) | Port da `JvcsExternalDll.dll`, harness, comportamento na IDE, expert em todas as atualizações |
| [Expert-IDE-Analise](client/Expert-IDE-Analise.md) | Engenharia reversa do expert 2.5.0.1030: ABI, ToolsAPI, registro |
| [Cliente-Standalone-Analise](client/Cliente-Standalone-Analise.md) | Engenharia reversa do cliente 2.5.0.1030: units, forms, divergências fonte × binário |
| [Algoritmos-Recuperados](client/Algoritmos-Recuperados.md) | CRC-32, BFCrypt (Base64/Blowfish), protocolo MidWare, `mwPasLex` |
| [Checkin-Familias-FMX](client/Checkin-Familias-FMX.md) | Check-in de famílias `.pas` + `.dfm`/`.fmx` |
| [Requisito-Tamanho-Fonte](client/Requisito-Tamanho-Fonte.md) | Requisito de fonte, escala e tema claro/escuro |
| [../src/jvcsideexpert/LEIAME.md](../../src/jvcsideexpert/LEIAME.md) | Expert: arquitetura, ABI, compilação, registro manual |

## Servidor (`server`)

| Documento | O que contém |
|---|---|
| [server/LEIAME.md](server/LEIAME.md) | O servidor não é portado; o cliente preserva o protocolo dele |

## Build, bibliotecas e binários (fora de `doc`)

| Documento | O que contém |
|---|---|
| [../tools/LEIAME-compilar.md](../../tools/LEIAME-compilar.md) | Referência completa do `compilar.bat`, `compilar-expert.bat`, `.dproj` e variáveis de ambiente |
| [../setup/LEIAME.md](../../setup/LEIAME.md) | Instalador Inno Setup: geração, componentes, o que muda na IDE, testes |
| [../3rdparty/LEIAME.md](../../3rdparty/LEIAME.md) | Runtime e binários de referência do 2.5.0.1030 |
| [../src/comp/synedit/LEIAME-v2026.md](../../src/comp/synedit/LEIAME-v2026.md), [../src/comp/virtualtreeview/LEIAME-v2026.md](../../src/comp/virtualtreeview/LEIAME-v2026.md) | SynEdit e VirtualTreeView fixados |
| [../src/comp/midware/LEIAME.md](../../src/comp/midware/LEIAME.md), [../src/comp/crc/LEIAME.md](../../src/comp/crc/LEIAME.md), [../src/comp/mwtools/LEIAME.md](../../src/comp/mwtools/LEIAME.md) | Notas de port do MidWare, do CRC e do lexer Pascal |
| [../src/packages/LEIAME.md](../../src/packages/LEIAME.md) | Pacote design-time do MidWare (a criar) |

## Documentos originais (`doc/original`)

Arquivos do JEDI VCS original (em inglês, sem alteração; ficam em `doc/original`, fora das pastas de
idioma, porque o instalador, o `LICENSE` e os fontes apontam para eles): [license.txt](../original/license.txt),
[credits.txt](../original/credits.txt), [credits_jedivcsdiff.txt](../original/credits_jedivcsdiff.txt),
[HowToBuild.txt](../original/HowToBuild.txt), [jvcs_directories.txt](../original/jvcs_directories.txt) e as
[release notes](../original/Jvcs.Releasenotes.pdf).

## Ordem de leitura sugerida (desenvolvimento)

1. [Processo: história](processo/01-Historia-e-Motivacao.md) e [decisões](processo/03-Decisoes-de-Arquitetura.md).
2. [Fontes: arquitetura](fontes/Arquitetura.md) e [compilação](fontes/Compilacao.md).
3. [CHANGELOG](../../CHANGELOG.md), para saber o que mudou em cada versão.
4. O `client/Port-*.md` da área em que for mexer.
5. [Convenções](fontes/Convencoes.md), antes do primeiro commit.
