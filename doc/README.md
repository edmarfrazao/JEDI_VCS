# Documentação do JEDI VCS 2.5 Beta 2026

Índice geral da documentação do port do **cliente** JEDI VCS 2.5 (Beta 3) para o Delphi 13.2 Florence, com compilação mantida em Delphi 11 e 12. O servidor 2.5 Beta 3 (Firebird) não é portado. Visão geral do projeto: [../README.md](../README.md).

## Comece por aqui

| Documento | O que contém |
|---|---|
| [common/Status.md](common/Status.md) | Situação atual por fase (F0 a F6), checklist do que foi feito, próximos passos e os erros atuais de `tools\compilar.bat all`. |
| [common/Plano-de-Port.md](common/Plano-de-Port.md) | Plano de execução em fases, critérios de pronto, riscos e checklist de compatibilidade com o servidor. |
| [common/Decisoes.md](common/Decisoes.md) | Registro datado das decisões do port (escopo, IDE alvo, bibliotecas, recursos desligados, nome da versão). |

## Manual de configuração (`manual`)

Manual prático, em português, para instalar o servidor JEDI VCS 2.5 Beta 3 (Firebird), configurar o cliente e integrar ao Delphi 13. Comece pelo [índice do manual](manual/README.md).

| Capítulo | O que contém |
|---|---|
| [manual/README.md](manual/README.md) | Índice, "por onde começar", mapa de caminhos desta máquina e convenções do manual. |
| [manual/01-Servidor-Instalacao-e-Configuracao.md](manual/01-Servidor-Instalacao-e-Configuracao.md) | Servidor (aplicação × serviço), Firebird instalado × embutido, restaurar o banco com `gbak`, tela "Logon to Firebird", `jvcssrv.ini`/VirtualStore, porta 2106 e firewall, backup, menus do servidor. |
| [manual/02-Cliente-Primeiro-Acesso.md](manual/02-Cliente-Primeiro-Acesso.md) | Identidade e Server Login, `sysdba`/`admin`, trocar senha, criar usuários (você e a IA), níveis de acesso, grupos, primeiro projeto e nomes proibidos. |
| [manual/03-Integracao-com-o-Delphi.md](manual/03-Integracao-com-o-Delphi.md) | Expert no Delphi 13 (32 bits): registro, verificação, reverter, variáveis `JVCS_EXPERT_*`, limitações. |
| [manual/04-Opcoes-do-Cliente.md](manual/04-Opcoes-do-Cliente.md) | VCS Properties, página por página, com recomendações (inclui External Bugtracker e Save WIP). |
| [manual/05-Familias-de-Arquivos.md](manual/05-Familias-de-Arquivos.md) | `.pas` + `.dfm` + `.fmx`, File Families Manager e famílias recomendadas. |
| [manual/06-Linha-de-Comando.md](manual/06-Linha-de-Comando.md) | `jvcs.exe`: sintaxe, comandos, exemplos seguros, senha na linha de comando, o que ainda não existe. |
| [manual/07-Senhas-Padrao-e-Seguranca.md](manual/07-Senhas-Padrao-e-Seguranca.md) | Senhas padrão, o que trocar e boas práticas. |
| [manual/08-Solucao-de-Problemas.md](manual/08-Solucao-de-Problemas.md) | Tabela sintoma, causa e solução. |

## Ambiente, versões e componentes (`common`)

| Documento | O que contém |
|---|---|
| [common/Ambiente.md](common/Ambiente.md) | Como esta máquina foi montada (Delphi, GetIt, bibliotecas fixadas), alterações no registro e na IDE, backups e como reverter. |
| [common/Versoes.md](common/Versoes.md) | Versão do produto, do Delphi (11/12/13), das dependências, dos binários de referência 2.5.0.1030 e histórico do git. |
| [common/Componentes.md](common/Componentes.md) | Tabela consolidada de todos os componentes, bibliotecas, units ausentes e binários de runtime, com situação, licença e substituto nativo. |
| [common/Inventario-Componentes.md](common/Inventario-Componentes.md) | Inventário completo por família (201 units), riscos de compatibilidade com o servidor, evidências e relatório do crítico. |
| [common/Licencas.md](common/Licencas.md) | Licenças de cada componente e os pontos de atenção (Midware não comercial, DFS, FastMM5). |
| [common/LEIAME-Origem.md](common/LEIAME-Origem.md) | De onde veio cada arquivo da árvore, a regra de escolha entre cópias e as units ausentes no clone. |
| [common/manifesto-origem.csv](common/manifesto-origem.csv) | Lista completa (destino, origem, MD5, marcas Lazarus, nota) usada na montagem da árvore; separador `;`. |

## Cliente (`client`)

| Documento | O que contém |
|---|---|
| [client/Expert-IDE-Analise.md](client/Expert-IDE-Analise.md) | Análise estática do expert original 2.5.0.1030: ABI com a `JvcsExternalDll.dll`, ToolsAPI usada e registro `JVCSIDEClient`. |
| [../src/jvcsideexpert/LEIAME.md](../src/jvcsideexpert/LEIAME.md) | Novo expert para BDS 37/23/22: arquitetura, ABI, compilação, registro manual e limitações (em revisão). |

## Servidor (`server`)

| Documento | O que contém |
|---|---|
| [server/LEIAME.md](server/LEIAME.md) | O servidor não é portado (JEDI VCS 2.5 Beta 3 com Firebird, funciona até o Firebird 5); a pasta receberá os resultados das consultas somente leitura no banco (Plano F0, 0.7). |
| [server/Servidor-Teste-Local.md](server/Servidor-Teste-Local.md) | Servidor de teste montado em 12/10/2026: versões, banco, configuração efetiva, problemas encontrados e bancos de reserva. Uso passo a passo: [manual](manual/README.md). |

## Build, bibliotecas e binários (fora de `doc`)

| Documento | O que contém |
|---|---|
| [../tools/LEIAME-compilar.md](../tools/LEIAME-compilar.md) | Uso do `tools\compilar.bat` (projetos, alvo `libs`, variáveis de ambiente, instalação de SynEdit/VTV na IDE, pendências). |
| [../3rdparty/LEIAME.md](../3rdparty/LEIAME.md) | Binários de runtime e de referência copiados da instalação 2.5.0.1030 e o que distribuir. |
| [../src/comp/synedit/LEIAME-v2026.md](../src/comp/synedit/LEIAME-v2026.md) | SynEdit fixado (pyscripter, commit `84391a3`). |
| [../src/comp/virtualtreeview/LEIAME-v2026.md](../src/comp/virtualtreeview/LEIAME-v2026.md) | Virtual-TreeView fixado (V8.5). |
| [../src/comp/midware/LEIAME.md](../src/comp/midware/LEIAME.md), [../src/comp/crc/LEIAME.md](../src/comp/crc/LEIAME.md), [../src/comp/mwtools/LEIAME.md](../src/comp/mwtools/LEIAME.md) | Notas de port do Midware, do `Checksum` (CRC) e do lexer Pascal. |
| [../src/packages/LEIAME.md](../src/packages/LEIAME.md), [../setup/LEIAME.md](../setup/LEIAME.md) | Pacote design-time e instalador (a criar). |

## Ordem de leitura sugerida

1. [Status](common/Status.md), para saber onde o projeto está.
2. [Decisoes](common/Decisoes.md) e [Plano-de-Port](common/Plano-de-Port.md), para entender o que e por quê.
3. [Componentes](common/Componentes.md) e [Versoes](common/Versoes.md), para a lista de materiais.
4. [Ambiente](common/Ambiente.md), antes de mexer na IDE ou no registro.
5. [Inventario-Componentes](common/Inventario-Componentes.md), quando precisar do detalhe de uma unit ou de um risco.
6. [Manual de configuração](manual/README.md), para instalar e configurar servidor, cliente e expert do Delphi.
