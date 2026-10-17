# 01. História e motivação

Por que este port existe, de onde veio o código e por que só o **cliente** foi portado.
Próximo: [02 Linha do tempo](02-Linha-do-Tempo.md). Índice do processo: [README](README.md).

## 1. O JEDI VCS

O **JEDI VCS** (sucessor do FreeVCS) é um sistema de controle de versão cliente/servidor feito em Delphi
para equipes Delphi. A linha 2.x é do Project JEDI; os principais autores foram **Thomas Huber**,
**Uwe Schuster** e equipe (ver [`doc/original/credits.txt`](../../original/credits.txt)). Peças:

| Peça | O que faz |
|---|---|
| Servidor (`JVCSSrv.exe`) | Aplicação ou serviço Windows, porta TCP **2106**, banco **Firebird** (também havia variantes para outros SGBDs) |
| Cliente standalone (`jedivcs.exe`) | GUI completa: projetos, check-in/check-out, histórico, labels, backup, usuários |
| Integração com a IDE | expert ToolsAPI (`JvcsExpertBDS<nn>.dll`) + `JvcsExternalDll.dll` (o mesmo cliente compilado como DLL) |
| `jedivcsdiff.exe` | comparador de arquivos/revisões |
| `jvcs.exe` | console para scripts |

O protocolo entre cliente e servidor é o **MidWare** (F. Piette) sobre ICS: requisições com nome de
função (`LOGIN`, `CHECKIN_MODULE`...), campos delimitados e blobs ZIP.

## 2. A situação em 2026

| Fato | Consequência |
|---|---|
| O último instalador oficial é o **2.50 Beta 3** (cliente 2.5.0.1030, "Refresh till 10.4 Sydney"), compilado com Delphi 2007 (a DLL) e com expert só até o BDS 21 (Delphi 10.4) | Não há expert para Delphi 11, 12 e 13; o cliente não tem tema escuro nem escala de fonte |
| O **fonte oficial do 2.5 se perdeu** junto com a infraestrutura antiga do projeto (SourceForge/SVN) | Não existe uma árvore "canônica" para continuar |
| Restaram **forks** no GitHub (base usada: `Libaud/JediVCS`), com código de ~2012 que compilava até XE2, misturado a um port inacabado para Lazarus | A árvore precisou ser **reconstruída arquivo a arquivo**, escolhendo em cada caso a cópia com **menos** edições Lazarus ([LEIAME-Origem](../common/LEIAME-Origem.md), [manifesto](../common/manifesto-origem.csv)) |
| Várias units de terceiros usadas pelo binário não estavam no fork (DFS EnhListView, SystemTreeView, `Checksum`, `BFCrypt`, `RekScan`, `mwPasLex`...) | Os algoritmos foram **recuperados do binário 2.5.0.1030** por engenharia reversa ([Algoritmos-Recuperados](../client/Algoritmos-Recuperados.md)) e reescritos sem dependências |
| Servidores 2.5 Beta 3 continuam em produção e funcionam até o Firebird 5 | Não havia motivo para mexer no servidor |

## 3. Decisão: portar só o cliente, com protocolo idêntico

Registrada em 12/10/2026 ([Decisoes](../common/Decisoes.md)):

- **Escopo:** portar o **cliente** (EXE, DLL da IDE, Diff e console). O **servidor 2.5 Beta 3 (Firebird)
  permanece** como está.
- **Compatibilidade:** o cliente novo precisa produzir **os mesmos bytes no fio** que o 2.5.0.1030. Isso
  foi tratado como requisito de teste (golden de tráfego, ver [04 Testes](04-Testes-e-Validacao.md)):
  - code page fixa **1252** nos campos de texto do MidWare, mesmo com o Delphi Unicode;
  - CRC-32, Blowfish, Base64 e formato do blob ZIP idênticos ao original;
  - versão enviada no `LOGIN` aceita pelo servidor (250 no EXE/DLL; 239 no console, como o original).
- **Convivência:** o cliente original e o novo podem estar instalados juntos e compartilham as mesmas
  identidades (`HKCU\Software\JEDI\JEDIVCS`); o instalador novo não toca no original.
- **Alvo:** Delphi 13 Florence (referência), mantendo compilação em Delphi 11 e 12; **Win32** (a
  `fvcscrypt.dll` do login é 32 bits e fechada).
- **Só o básico:** relatórios, tradução, notificação entre estações, plugins e a UI de branching ficaram
  desligados (sem efeito no protocolo); os recursos úteis do trunk de 2012 (External Bugtracker, Save WIP,
  Compare all) foram mantidos.

## 4. Motivação prática

1. Continuar usando um servidor JEDI VCS existente a partir do **Delphi 11, 12 e 13**, com menu
   **JEDI VCS** na IDE, check-in/check-out e histórico.
2. Um cliente legível em **telas de alta resolução** (escala 100–200%) e com **tema claro/escuro**
   seguindo o Delphi ou o Windows ([Requisito-Tamanho-Fonte](../client/Requisito-Tamanho-Fonte.md)).
3. Permitir que um **assistente de IA** (Claude Code) faça checkout/check-in com segurança, preservando a
   codificação dos fontes ([ADR-001](../common/ADR-001-CLI-IA-e-Plugin-Multi-Delphi.md),
   [documentação de IA](../ia/README.md)).
4. Uma base **compilável hoje**, documentada e com testes, publicada como software livre (MPL 1.1).

## 5. Como o trabalho foi feito

O port foi feito em dois dias intensos (12 e 13/10/2026) por **Edmar Frazão** com o **Claude Code**
(Anthropic) como par de programação: análise estática dos binários, port das units, scripts de build,
testes contra um servidor 2.5 Beta 3 local e documentação em português. Cada decisão relevante foi
registrada em [Decisoes](../common/Decisoes.md) e cada fase no [Plano de Port](../common/Plano-de-Port.md) e nos
documentos `doc/pt/client/Port-*.md`.
