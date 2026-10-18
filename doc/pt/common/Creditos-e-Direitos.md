# Créditos, direitos dos criadores e a FVCSCrypt.dll

O **JEDI VCS 2.5 Beta 2026** é um port do cliente JEDI VCS 2.5 para o Delphi moderno. Ele **não é** um produto novo:
quase todo o código e todo o projeto vêm dos criadores e mantenedores originais, listados aqui. Os direitos e as
licenças deles continuam valendo e têm de ser respeitados por quem usar, modificar ou redistribuir este código.

## 1. Quem criou e quem manteve o JEDI VCS

| Quem | Papel | Onde aparece |
|---|---|---|
| **Thomas Hensle** | **Criador do FreeVCS**, a origem do JEDI VCS, e autor ("Initial Developer") do código FreeVCS. Ele abriu o código e o doou ao Project JEDI em 2003. Também é autor das DLLs de cifra `FVCSCrypt.dll` (cliente) e `ServerCrypt.dll` (servidor) | cabeçalho "The Initial Developer of the original FreeVCS-Code (FreeVCS) is: Thomas Hensle" em quase todas as units; `doc/original/credits.txt` |
| **Project JEDI** (Joint Endeavour of Delphi Innovators) | Comunidade que recebeu o FreeVCS e o publicou como **JEDI VCS** (JVCS), com o código no SourceForge (`jedivcs`) | `doc/original/license.txt`, `jedivcs.sourceforge.net` |
| **Holger Dors** e **Thomas Huber** | Migração do código FreeVCS para o JEDI VCS ("Code move to JEDI VCS") e manutenção | cabeçalhos das units |
| **Uwe Schuster** | Principal mantenedor do JEDI VCS 2.x: o maior número de alterações registradas no histórico das units, os ports do servidor e o porte para o Free Pascal | histórico das units (`USchuster`) |
| **Fikret Hasovic**, **Marco Gosselink**, **Ondrej Kelle (TOndrej)** | Mantenedores e contribuidores do JEDI VCS | cabeçalhos e histórico das units |
| Demais contribuidores registrados no histórico das units | CSchuette, AKroeber (recursos do trunk de 2012), FBouwmans, WKlein, KFitzner, PLauret, DBelanger, CSchiffler, LBrands e outros | histórico das units |
| **F. Libaud** | Port do JEDI VCS para Lazarus/Free Pascal (Linux), publicado em `github.com/Libaud/JediVCS`. O clone dele (commit `f6a777d`) é a base de fontes deste port | `doc/pt/common/LEIAME-Origem.md` |
| Autores dos componentes de terceiros | ver a seção 3 | `doc/original/credits.txt`, `Licencas.md` |

O port de 2026 (Delphi 11, 12 e 13) é mantido no repositório
[github.com/edmarfrazao/JEDI_VCS](https://github.com/edmarfrazao/JEDI_VCS). Ele preserva os cabeçalhos, os
créditos e o histórico originais de cada unit, e as mudanças do port são marcadas como `JVCS 2026` no código.

**Como o port de 2026 foi feito:** a análise do código original, as alterações do port e os testes foram feitos
com o **Claude Code** (modelo **Claude Opus 5.5**, da Anthropic), sob a direção e a validação do mantenedor do
repositório. O mantenedor conferiu cada beta no Delphi 11, 12 e 13 e num segundo PC antes da publicação. Esse
trabalho é só o port: o projeto, o desenho e quase todo o código continuam sendo dos criadores e mantenedores acima.

## 2. Licença e direitos

- **MPL 1.1:** a maior parte do código do JEDI VCS é publicada sob a Mozilla Public License 1.1
  (`doc/original/license.txt`). Ela vale para todo arquivo com o cabeçalho MPL ou sem outra indicação de licença.
- **Partes com outras licenças:** várias partes são doações ou derivações de outros desenvolvedores e bibliotecas,
  com licenças e restrições próprias, marcadas no cabeçalho de cada arquivo. Quem distribuir ou reutilizar o código,
  em parte ou no todo, tem de conferir o cabeçalho de cada unit e respeitar essas restrições.
- **Uso comercial:** a licença original avisa que várias partes **não podem** ser usadas para fins comerciais (ver
  Midware na seção 3).
- **O que este port faz para respeitar os direitos:**
  - mantém os cabeçalhos MPL e os créditos de cada arquivo;
  - publica o fonte das modificações;
  - marca as alterações;
  - redistribui os binários de terceiros sem modificar (seção 4);
  - mantém o aviso de licença do Midware no About e no console.

## 3. Componentes e bibliotecas de terceiros

Os créditos completos dos componentes usados pelo FreeVCS e pelo JEDI VCS estão em `doc/original/credits.txt`.
Os pontos de licença que afetam este port estão em [Licencas.md](Licencas.md). Os principais:

| Componente | Autor / projeto | Licença |
|---|---|---|
| Midware (ApsCli, RFormat, CBroker) | François Piette | freeware **só para uso não comercial**; uso em empresa exige licença |
| ICS (Internet Component Suite) | François Piette / Overbyte | freeware |
| JCL e JVCL | Project JEDI | MPL 1.1 |
| SynEdit | projeto SynEdit (base: mwEdit) | MPL 1.1 / GPL 2 |
| Virtual-TreeView | Mike Lischke e mantenedores (JAM Software) | MPL 1.1 / LGPL 2.1 |
| Motor de comparação do JEDIVCSDiff | Armin L. Biernaczyk (derivado do FC_Win) | conforme `credits.txt` |
| mdMailSlot | Martin Djernæs | conforme `credits.txt` |
| TmwPasLex | Martin Waldenburg | conforme `credits.txt` |
| Base da cifra de senha | TEncrypt © 1996, F. Millenaar (base da `FVCSCrypt.dll` e da `ServerCrypt.dll`) | conforme `credits.txt` |

## 4. A FVCSCrypt.dll: o que é e por que é obrigatória

| Item | Situação |
|---|---|
| O que é | DLL de cifra de senha do cliente FreeVCS / JEDI VCS. Exporta `fvcs_Encrypt1` (senha ao cadastrar ou trocar) e `fvcs_Encrypt2` (senha do LOGIN, com a hora do servidor) |
| Autor | FreeVCS (Thomas Hensle), com base no TEncrypt de F. Millenaar |
| Fonte | **não publicado.** Sempre foi distribuída só como binário, nos instaladores oficiais. Os fontes públicos (o JEDI VCS no SourceForge e o port de F. Libaud) têm só a unit de interface, `JVCSCrypt.pas` |
| Par no servidor | `ServerCrypt.dll` (mesmo autor, também fechada): `fvcs_CryptCompare` confere a senha enviada pelo cliente |
| Versão usada | 1.0.0.19, **o mesmo binário** do instalador oficial JVCS 2.50 Beta 3, sem nenhuma modificação (`3rdparty\fvcscrypt.dll`) |
| Por que é obrigatória | **Sem ela não há login.** O standalone, a DLL da IDE e o console a carregam da própria pasta para cifrar a senha antes de mandá-la ao servidor 2.5. Não há outra implementação compatível com a `ServerCrypt.dll` |
| Consequências | O cliente é de **32 bits** (uma DLL de 32 bits não carrega num processo de 64 bits). A IDE de 64 bits do Delphi 13 usa o cliente standalone. O instalador sempre instala a DLL ao lado do `Jedivcs.exe`, do `jvcs.exe` e da `JvcsExternalDll.dll` |
| Direitos | A DLL pertence aos seus autores. Ela é redistribuída como parte do runtime do JEDI VCS, como nos instaladores oficiais, sem alteração |

## 5. Por que não há cliente de 64 bits

O motivo é a exigência da `FVCSCrypt.dll`:

1. **Sem a DLL não há login**, e não há outra cifra que o servidor 2.5 aceite. A `ServerCrypt.dll` só reconhece a
   senha cifrada pela `FVCSCrypt.dll`.
2. **A DLL é de 32 bits e sem fonte.** É um binário PE32, com convenção `register` e parâmetros `ShortString`.
   O Windows não carrega uma DLL de 32 bits num processo de 64 bits, e não há fonte para recompilá-la em 64 bits.
3. **Reescrever a cifra não compensa.** Sem o fonte, seria preciso reconstruir o algoritmo a partir do binário e
   garantir que o resultado fosse idêntico byte a byte ao da DLL original. Levar o núcleo do cliente para 64 bits
   custaria ainda de 15 a 40 dias, com risco alto de quebrar o LOGIN de quem já usa o servidor.
4. **Mexer no servidor não é opção.** O modo `SRVCRYPTINTERNALDUMMY` do servidor desliga a autenticação (aceita
   qualquer senha), e trocar a `ServerCrypt.dll` quebraria a compatibilidade com os clientes existentes.
5. **A busca pelo fonte não achou nada publicado:** nem no JEDI VCS do SourceForge, nem na JCL ou na JVCL, nem no port
   de F. Libaud.

Por isso todo o cliente (standalone, DLL da IDE, Diff e console) continua em **Win32**:

- a IDE de 32 bits do Delphi 11, 12 e 13 usa o expert integrado;
- a IDE de 64 bits do Delphi 13 usa o **cliente standalone**.

O caminho técnico para uma integração com a IDE de 64 bits, se um dia for retomado, é um expert Win64 fino que fale
com um agente Win32. O agente carregaria a mesma `FVCSCrypt.dll`. Os detalhes estão no
[Plano de Port](Plano-de-Port.md), fase F7.

## 6. Onde estão os textos originais

- `doc/original/license.txt`: a licença do JEDI VCS.
- `doc/original/credits.txt` e `doc/original/credits_jedivcsdiff.txt`: os créditos de Thomas Hensle e dos componentes.
- `doc/original/HowToBuild.txt` e `doc/original/jvcs_directories.txt`: notas originais de compilação e estrutura.
- [LEIAME-Origem.md](LEIAME-Origem.md): de onde veio cada arquivo deste port.
- [Licencas.md](Licencas.md): os pontos de licença de cada componente.
- `DISCLAIMER.md` e `LICENSE` (raiz do repositório): o aviso de garantia e a licença deste port.
