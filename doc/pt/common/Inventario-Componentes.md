# Inventário de componentes: cliente JEDI VCS 2.5 → Delphi 13.2

Consolidação do levantamento por famílias de componentes para o port do **cliente** JEDI VCS 2.5 (Beta 3) para o Delphi 13.2 Florence Professional, mantendo a compilação em Delphi 11/12. O servidor 2.5 Beta 3 (Firebird) **não** é portado e o protocolo tem de continuar idêntico.

- **Fonte dos dados:** workflow `wf_41a5e977-854`. Foram usadas só as 9 versões **revisadas** das famílias (correções marcadas com `[REVISÃO]`) e o resultado do crítico de completude (`critic:completude`). Onde a revisão discorda do inventário inicial, vale a revisão.
- **Data da consolidação:** 2026-10-12.
- **Plano de execução:** `doc\pt\common\Plano-de-Port.md`.
- **Documentos relacionados:** `README.md`, `doc\pt\common\LEIAME-Origem.md`, `doc\pt\common\Licencas.md`, `doc\pt\common\manifesto-origem.csv`.

## Convenções

- `<clone>` = `D:\Delphi\JediVCS\Fontes_JediVCS_2.5` (clone de github.com/Libaud/JediVCS). A coluna **Onde está** das tabelas de units se refere ao clone (`Components\...`, `Jedi VCS Client\2.5\...`), não à v2026.
- `v2026` = `D:\Delphi\JediVCS\v2026`. A coluna **Pasta na v2026** da tabela-síntese já está alinhada com a estrutura criada (`src\jedivcs` = EXE + DLL, `src\jvcs` = console, `src\common`, `src\common\client`, `src\comp\<pacote>`, `src\packages`, `3rdparty`, `setup`, `tools`).
- **Status D13** (por unit): `funciona` (compila/serve como está), `atualizar-versao` (trocar pela versão atual do mesmo componente), `substituir` (trocar por nativo ou outro componente), `portar-codigo` (cópia local com ajustes), `remover` (código morto, resíduo ou só do servidor), `incerto`.
- **Decisão** (por família): `substituir-por-nativo`, `manter-atualizado`, `portar-copia-local`.
- As notas das tabelas de units foram resumidas. Os riscos estão completos, com as marcações `[REVISÃO]` originais.

## 1. Resumo executivo

1. Foram inventariadas e revisadas **9 famílias** (201 units/itens). Nenhuma cópia de terceiros do clone (`Components\`) compila no Delphi 13 como está: são versões pré-Unicode (ICS V5, Midware V3, SynEdit 2.0.x, VT 4.8.5, Abbrevia 5.0) e várias foram editadas pelo port Lazarus.
2. **Preferência por nativo aplicada:** JVCL visual, DFS (EnhListView, SystemTreeView, StatusBar), FavOpenDialog, Abbrevia, JclPCRE, HtmlHlp, RegAcc, RekScan, ItemProp e os utilitários não visuais da JVCL viram VCL/RTL. JCL e JVCL ficam só como dependência externa de transição (GitHub master, pacotes d37).
3. **Atualizar para versão atual:** ICS V9.7/9.8 (transporte), VirtualTreeView V8.5, SynEdit (pyscripter, a única linha que cobre Delphi 11, 12 e 13) e CastaliaPasLex no lugar do mwPasLex ausente.
4. **Portar como cópia local:** o subconjunto cliente do Midware (ApsCli/RFormat/CBroker), com `PAnsiChar` e code page fixa, isolado atrás de `JVCSTransport.pas`; mdMailSlot; TDiff/HashUnit.
5. **Recriar:** `Checksum.pas` (CRC bit a bit idêntico ao já gravado no servidor), `BFCrypt.pas` (Base64 nativo; Blowfish só se houver blobs cifrados) e o expert ToolsAPI da IDE (fonte perdido).
6. **Remover:** CipherLz/Lzh (código morto dos dois lados), ThemeMgr/`winxp.res`, OTA antiga (VCSIntf/ToolIntf/EditIntf), FastMM4/MemCheck, units LCL, `jedivcsreport.dll` (REPORTDLL); plugins desativados por define.
7. **Bloqueio de plataforma:** `FVCSCrypt.dll` (login) é binária, fechada e só 32 bits. Por isso a fase 1 é **Win32 + IDE de 32 bits**; Win64/ARM64EC dependem de reimplementar a cifra.
8. **Maior risco:** compatibilidade de bytes e dados com o servidor 2.5 Beta 3 (code page, formato TMWBuffer, versão do cliente no LOGIN, CRC, formato e data dos blobs ZIP, header XML do Line History, nome do projeto devolvido pelo expert). Mitigação: teste "golden" de tráfego contra o cliente oficial 2.5 Beta 3 (seção 4).
9. **Crítico de completude:** 14 lacunas (3 críticas: versão do cliente no LOGIN, `DecimalSeparator`/`ThousandSeparator` removidos da RTL e units que faltavam à DLL, esta última já resolvida pela árvore v2026) e 12 contradições com veredito (seção 6).
10. **Esforço:** médio em 8 famílias e alto na integração com a IDE.

## 2. Tabela-síntese por família

| Família | Situação no Delphi 13.2 | Decisão | Origem/versão para D13 | Esforço | Pasta na v2026 |
|---|---|---|---|---|---|
| [ICS + Midware](#31-ics--midware-comunicação-cliente-servidor) | `misto`: ICS V5 e Midware V3 locais não compilam e mandariam UTF-16 pela rede; ICS V9 suporta D13 | `portar-copia-local` (Midware) + ICS V9 externo; transporte isolado em `JVCSTransport.pas` | ICS V9.7 (GetIt, 2026-05-19) ou V9.8 Beta (SVN); Midware portado com base em OverbyteRFormat 7.02 / OverbyteApsCli 7.00 | médio | `src\comp\midware` (ApsCli, RFormat, CBroker, MWDefs.inc); `src\common\client\JVCSTransport.pas` (novo); `src\packages` (design-time); ICS externo |
| [Compressão e criptografia](#32-compressão-e-criptografia) | `misto`: Abbrevia 5.0 local não compila; RTL cobre ZIP/CRC/Base64; FVCSCrypt.dll só Win32 | `substituir-por-nativo` | System.Zip, System.ZLib, System.NetEncoding, System.Hash; EncryptedZipFile (Uwe Raabe, MIT); FVCSCrypt.dll do instalador 2.50 Beta 3; DEC 6.4.1 só se houver Blowfish | médio | `src\comp\crc` (Checksum); `src\common\client` (JVCSCrypt; JVCSZipUtils e BFCrypt novos); `src\comp\encryptedzip` (novo); `3rdparty\FVCSCrypt.dll` |
| [JEDI Code Library (JCL)](#33-jedi-code-library-jcl) | `misto`: todas as units existem na JCL atual; 2 quebras reais na v2026 (AnsiCrLf e `{$ifdef WINDOWS}`) | `manter-atualizado` (externa) + troca pontual por nativo | GitHub project-jedi/jcl master (último merge 2026-09-21) ou GetIt 2026.08 | médio | externa (não copiar); `jedi.inc` fixado em `src\common`; helpers JVCSTrace/JVCSStrUtils/JVCSFileUtils em `src\common` |
| [JVCL não visuais e utilitários](#34-jvcl---não-visuais-e-utilitários) | `misto`: existem no JVCL d37, mas JvDSADialogs exige motor dinâmico e os handlers de plugin divergem | `substituir-por-nativo` (gettext mantido) | JVCL GitHub master d37 (2026-05-29) só na transição; gnugettext.pas do dxgettext r196 (2026-08-19) | médio | `src\common` e `src\jedivcs` (wrappers nativos); `src\comp\dxgettext` (novo) |
| [JVCL controles visuais](#35-jvcl---controles-visuais) | `atualizar-versao`: JVCL master já suporta RAD Studio 13 (d37) | `substituir-por-nativo` | VCL do Delphi 11/12/13 (StdCtrls, ExtCtrls, ComCtrls, CheckLst, Samples.Spin/NumberBox, WinXPanels, GraphUtil) | médio | sem pasta de componente: forms em `src\jedivcs` e `src\jedivcsdiff` |
| [VirtualTreeView + temas + listas DFS](#36-virtualtreeview--acessibilidade--temas--listas-dfs) | `misto`: VT 4.8.5 local cai em caminhos legados; V8 suporta 10–13; DFS ausente | `manter-atualizado` (VT V8) + DFS/ThemeMgr → nativo | VirtualTreeView V8.5 (JAM, tag 2026-10-02); TListView e TShellTreeView nativos | médio | VT externo (opcional vendorizar em `src\comp\virtualtreeview`); substituto da EnhListView em `src\common` + registro em `src\packages` |
| [SynEdit + mwPasLex + TextDrawer](#37-synedit--mwpaslex--textdrawer) | `misto`: SynEdit 2.0.x ANSI local não compila; upstream suporta D13; mwPasLex ausente | `manter-atualizado` | pyscripter/SynEdit master (commit 2025-11-24; D10.3+) — TurboPack/GetIt só D12+; CastaliaPasLex (commit 2011-10-12) | médio | SynEdit externo (opcional cópia fixada em `src\comp\synedit`); `src\comp\mwtools` (Castalia renomeado); consumidores em `src\common\client` |
| [Componentes pequenos e units ausentes](#38-componentes-pequenos-e-units-ausentes) | `misto`: quase tudo tem nativo; mailslot, TDiff e Checksum exigem código local | `substituir-por-nativo` | RTL/VCL; mdMailSlot 1.17 e TDiff 2.5.1/HashUnit portados (alternativa rickard67/TextDiff, 2026-08-10) | médio | `src\comp\mdmailslot`, `src\comp\textdiff`, `src\comp\crc`, `src\comp\mwtools`; substitutos em `src\jedivcs` e `src\jedivcsdiff` |
| [Integração com a IDE (DLL / ToolsAPI)](#39-integração-com-a-ide-dll--toolsapi) | `misto`: DLL portável (ABI PAnsiChar); expert perdido e OTA antiga inexistente no D13 | `portar-copia-local` (DLL) + expert novo | Código próprio; ToolsAPI/FileHistoryAPI do Delphi 13.2 (designide 370; 280/290 para BDS 22/23) | alto | DLL em `src\jedivcs` (`JediVCSDLL.dpr` + units só da DLL); ABI/settings em `src\common`; expert em `src\jvcsideexpert` (novo); registro em `setup` |

### Estado do ambiente em 2026-10-12 × recomendação do inventário

Segundo o `README.md`, o `tools\LEIAME-compilar.md` e o `3rdparty\LEIAME.md` (atualizados em 2026-10-12), as dependências já foram instaladas **no Delphi 13.2 via GetIt**. A tabela compara essa instalação com o que o inventário recomenda.

| Dependência | Instalado (D13.2, GetIt) | Recomendação do inventário | Observação |
|---|---|---|---|
| JCL | 2026.08 | GitHub master (mesma versão no 11/12/13) ou GetIt 2026.08 | Serve para o D13. No 11/12 o GetIt oferece versões antigas (RS12: 2023.11), então lá usar o GitHub num commit equivalente. |
| JVCL | 2026.08 (só transição) | GitHub master d37/d29/d28 | Igual à JCL. Há relatos de F2613 com o GetIt. |
| ICS | 9.7 | 9.7 (GetIt) ou 9.8 Beta (SVN) | OK. Desligar `MSCRYPT_*` no `OverbyteIcsDefs.inc` se surgir E2203. |
| VirtualTreeView | 8.3 (JAM) | **V8.5** (GitHub, 2026-10-02) | O GetIt 8.3 só lista o Delphi 13. Para o 11/12 é preciso o GitHub (`Packages\RAD Studio 10.4+`); convém padronizar na V8.5. |
| SynEdit | TurboPack 2025.03 | **pyscripter/SynEdit** (D10.3+), se o Delphi 11 for obrigatório | A TurboPack master exige D12+ e o Delphi 11 só tem o branch `11Alexandria`, desatualizado. Como manter a compilação no 11 é decisão tomada, escolher a linha (ver Plano, 0.2) e nunca misturar o GetIt com outra cópia no search path. |
| Abbrevia | 2026.10 (TurboPack) | Eliminar (System.Zip + EncryptedZipFile); Abbrevia TurboPack só como fallback | O README a trata como ponte da fase 1; a meta continua sendo `System.Zip`. |

`3rdparty` já contém, copiados da instalação oficial 2.5.0.1030 (`C:\Program Files (x86)\JEDI\JVCS`):
- `fvcscrypt.dll` (1.0.0.19, 32 bits) e os CHM `jedivcs.chm` e `jedivcsdiff.chm`;
- os arquivos de lista `*.jvcs`;
- em `referencia-2.5.0.1030\`: `JvcsExternalDll.dll`, `JvcsExpertBDS19/20/21.dll`, `jedivcs.exe`, `jedivcsdiff.exe` e `jvcs.exe`, só para referência e para o teste golden.

O `tools\compilar.bat` já existe (modo `dcc32` direto enquanto não houver `.dproj`). Nenhum dos 4 projetos compila ainda; as primeiras falhas estão listadas no `tools\LEIAME-compilar.md`.

### Divergências de destino resolvidas nesta consolidação

- **DLL da IDE:** a família IDE propunha `src\jedivcsdll`, e o crítico (C12), `src\jedivcsdll` e `src\console`. A v2026 já colocou a DLL em `src\jedivcs` (base única EXE + DLL a partir das cópias de `jedivcsdll`) e o console em `src\jvcs`. Mantida a estrutura existente.
- **Checksum:** a família Compressão sugeria `src\common\client`. Vale `src\comp\crc`, como já preparado na v2026 (`src\comp\crc\LEIAME.md`) e na família Componentes pequenos.
- **VirtualTreeView e SynEdit:** os inventários sugerem vendorizar; o `README.md` da v2026 os trata como dependências externas. Recomendação: dependência externa com versão/commit fixados, e cópia em `src\comp\<pacote>` só se for preciso garantir reprodutibilidade.
- **CipherLz/Lzh:** a família ICS dizia "só compilar"; a família Compressão e o crítico (C4) dizem "remover". Vale **remover**, coerente com `Licencas.md`.
- **mwPasLex:** a família Componentes pequenos sugeria recuperar o fonte do SVN do JVCS, que não existe mais. Vale o CastaliaPasLex renomeado (família SynEdit, crítico C9, `src\comp\mwtools\LEIAME.md`).

## 3. Famílias

### 3.1 ICS + Midware (comunicação cliente-servidor)

**Família no levantamento:** ICS + Midware (comunicação cliente-servidor)

**Situação no Delphi 13.2:** `misto` · **Decisão:** `portar-copia-local` · **Esforço:** médio

**Pasta na v2026:** `src\comp\midware` (ApsCli.pas, RFormat.pas, CBroker.pas, MWDefs.inc já copiados; nomes de unit mantidos). Interface de transporte nova em `src\common\client\JVCSTransport.pas`. Pacote design-time (TAppSrvClient, TMWBuffer e, segundo o crítico, TmdSecureMail) em `src\packages`. ICS V9 como dependência externa (GetIt/SVN), sem vendorizar subconjunto.

**Notas de consolidação:**
- **CipherLz/Lzh:** remover, e não portar (crítico C4, família Compressão, `Licencas.md`). No `DBModule` fica só uma checagem defensiva: resposta iniciada por `#$FF` gera erro.
- **Variáveis globais de formato:** `DecimalSeparator`/`ThousandSeparator` globais não existem no D13 e o código **não compila** (crítico 1.2/C2). Trocar por `FormatSettings.*`.
- **Versão do cliente no LOGIN:** vem do VERSIONINFO do binário (crítico 1.1; ver seção 4).
- **Cópias mutiladas pelo Lazarus:** a v2026 já usa as cópias de `jedivcsdll` para `JVCSClientObjBase`, `JVCSConnect`, `DBModule` etc. (manifesto: 0 marcas Lazarus), então o risco de tratamento de erro comentado não se aplica à árvore nova.

#### Resumo

O cliente embute o ICS V5 (WSocket 5.28, WSockBuf 5.02, IcsLogger 1.02 e IcsDefs.inc 1.07, que só reconhece compiladores até VER190) e o Midware V3 (ApsCli 3.06, RFormat 1.47/const 148, CBroker 1.07a, CipherLz e Lzh). Tudo isso é não-Unicode e tem edições do port FPC, então não compila no Delphi 13. Se fosse forçado a compilar, mandaria UTF-16 pela rede e quebraria o protocolo do servidor 2.5 Beta 3. Esse servidor é não-Unicode: repassa os bytes ANSI ao Firebird conforme o lc_ctype configurado. A revisão confirma a estratégia: ICS V9 (9.7 no GetIt, IDE Delphi 13; 9.8 Beta no SVN) para o transporte, e uma cópia local portada do subconjunto cliente do Midware, com buffer PAnsiChar e code page fixa e configurável, usando como referência o OverbyteRFormat 7.02 e o OverbyteApsCli 7.00. Correções principais: (1) SOCKS e o modo cifrado/LZH estão desativados no próprio cliente; (2) definir OVERBYTEV6_UP não basta, porque é preciso OverbyteIcsTypes e portar o ApsCli; (3) o ICS V9 não pode ser vendorizado só com um 'subconjunto' de ~10 units; (4) o código de Ping de Create.pas compila no V9 sem alterações; (5) a cópia de bookmarks no RFormat não é usada pelo cliente. O esforço foi revisado para médio: a maior parte da conversão Unicode já existe no Midware v7, e o grosso do trabalho são testes de protocolo.

#### Fonte recomendada

Transporte: ICS V9.7 pelo GetIt ('ICS for VCL for Delphi 9.7', IDE Delphi 13, atualizado em 2026-05-19, https://getitnow.embarcadero.com/ICS_VCL-13-9.7/) ou pelo SVN https://svn.magsys.co.uk/svn/icsv9 (ReadMe9 revisado em 08/10/2026, 'Release: V9.8 Beta', grupos de instalação para Delphi 10.4/11/12/13, que também atendem ao requisito Delphi 11/12). Use a pasta Source INTEIRA do ICS e um OverbyteIcsDefs.inc ajustado (MSCRYPT_Clients/Servers/Tools desligados; USE_SSL pode ser desligado, já que o cliente não usa TLS). Base de referência para o port do Midware: preferir o midware20190414.zip (ICS V8 / Delphi 10.3.1, http://www.overbyte.eu/eng/products/midware.html), por ser mais recente; na falta dele, o SVN https://svn.magsys.co.uk/svn/midware/trunk/Delphi/vc32 (rev. 52: OverbyteRFormat.pas 7.02, OverbyteApsCli.pas 7.00 com PAnsiChar/TIcsWndControl/LastReplyRXTime/RcvSizeInc). O OverbyteCipherLz.pas está em trunk/Delphi/Midware, mas continua PChar. CBroker e Lzh só existem nas cópias locais em Components\ (o lzh.pas local, versão LongWord de P. Lanzoni, é a referência correta). Como cliente de referência ('golden') para capturar tráfego, use o instalador oficial JVCSv2.50ClientSetupBeta3_Refresh_till_10_4Sydney.exe (SourceForge, 07/02/2021).

#### Alternativa nativa

Não há equivalente nativo para TMWBuffer/RFormat nem para a semântica do TAppSrvClient. Eles SÃO o protocolo do servidor 2.5 (banner; 'FUNC ' + corpo + CRLF; 'STATUS ' + corpo + CRLF; corpo com 3 bytes iniciais de separadores, ESC/FLD/REC). Por isso precisam ficar como código local portado. A superfície usada pelo cliente é pequena: Fields, WriteFields, FieldCount, FieldType, First/Next/Eof, Rewrite, RecordCount, AppendFields, GetStreamField, WriteStreamField, WriteRecord, DataBufferCount/Size, HeaderSize e AutoExpand. Para o transporte, dá para reescrever só a camada de socket do TAppSrvClient sobre Indy TIdTCPClient (vem com o RAD Studio) ou System.Net.Socket.TSocket. Correção: SOCKS NÃO é argumento contra essa troca, porque a aba Socks está invisível e as atribuições estão comentadas em Create.pas. O que segura o ICS na fase 1 é o modelo assíncrono por mensagens: JVCSClientDispatcher usa ThreadAttach/ThreadDetach/MultiThreaded/MessageLoop do TIcsWndControl, e CBroker.WaitForAnswer e DBModule.WaitForAppSrvClient fazem polling com ProcessMessages/MsgWaitForMultipleObjects. Trocar o transporte fica como fase 2 opcional. Ping: o OverbyteIcsPing do ICS V9 compila com o código atual; a alternativa nativa é um wrapper de ~80 linhas sobre IcmpSendEcho (iphlpapi.dll). MD5 (IcsMD5, não usado): System.Hash.THashMD5, se for necessário.

#### Destino proposto pelo inventário (texto original)

src\comp\midware: ApsCli.pas, RFormat.pas, CBroker.pas, CipherLz.pas, Lzh.pas e MWDefs.inc portados e marcados como 'JVCS edition', mantendo os nomes das units para não mexer nos uses das 48 units da GUI, mais um pacote design-time que registra TAppSrvClient/TMWBuffer. ICS V9: externo via GetIt ('ICS for VCL 9.7') ou vendorizado como pasta Source COMPLETA em src\comp\ics\Source (não um subconjunto), com um Include\OverbyteIcsDefs.inc ajustado (MSCRYPT_* desligados; USE_SSL opcionalmente desligado).

#### Riscos

- PONTO CRÍTICO, code page: o servidor 2.5 Beta 3 (fonte sem as mudanças de D2009, ou seja, não-Unicode) recebe e compara bytes ANSI e os repassa ao Firebird pela UIB, com o CharacterSet configurável (FirebirdCharacterSet/lc_ctype, SrvMain.pas l.2348). Se o cliente converter com CP_ACP e o Windows 11 estiver com 'Beta: UTF-8' (ACP=65001), os acentos saem como UTF-8: mojibake, buscas por nome falham e há risco de módulos duplicados. Solução: usar um tipo fixo (ex.: type TJVCSWireString = type AnsiString(1252)), configurável, em AppendFields, GetFields e no cabeçalho do ApsCli. Antes de fixar 1252, confira o lc_ctype do servidor e a ACP das máquinas que rodavam o cliente antigo.
- RFormat 1.47 local compilado em Unicode: FDataBuffer: PChar vira PWideChar, a indexação passa a contar chars e não bytes (AV/estouro e UTF-16 na rede), e os separadores viram WideChar. AppendFields não trata vtUnicodeString, vtWideChar nem vtPWideChar (toda string do D13 gera 'Unsupported data type'), e vtInt64 só é tratado em VER140/VER150. MoveEscaped (TBytes local = array[0..MaxInt-1] of Char) e AppendStreamField (PChar(TMemoryStream.Memory)+Position) corrompem blobs (zip de checkin/checkout).
- Midware v7.02 oficial: vtUnicodeString faz AnsiString(PChar(V.VUnicodeString)), que trunca no primeiro #0 e usa CP_ACP; vtWideChar faz AnsiChar(...), com perda; vtWideString não aparece tratado. No port local, corrigir para usar o Length do UnicodeString e a code page fixa.
- ApsCli 3.06 em Unicode: Header := FFunctionCode + ' ' é enviado com @Header[1]/Length, ou seja, UTF-16 e metade dos bytes. CrackHeader faz Move de bytes para AnswerStatus: String, o que gera lixo e faz StrToInt falhar. FRcvBuf: PChar procura #10 como WideChar. TProcessReplyEvent/TProcessBannerEvent são PChar, mas o DBModule ('changes for D2009') declara PAnsiChar, então nem compila. O OverbyteApsCli 7.00 já resolve isso (Header: AnsiString, eventos PAnsiChar) e já inclui as extensões de U. Schuster usadas pelo cliente (LastReplyRXTime, RcvSizeInc dinâmico).
- jedivcs\JVCSClientObjBase.pas (EXE) foi mutilado pelo port Lazarus: inherited Create, DoExecute (TransactionID/UserID), RequestDone, Execute e CopyFromReference estão comentados, o que quebra o protocolo. Use a cópia de jedivcsdll/jedivcsdiff/console (MD5 c653bcfc..., idênticas). Na mesma comparação, JVCSClientDispatcher, JVCSClientObj e JVCSNewClientObj são idênticos entre EXE e DLL; JVCSConnect/DBModule/Create diferem só em formatação.
- O snapshot do repositório está inconsistente: Ping.pas/Icmp.pas (ICS V5) não existem, então Create.pas (EXE e DLL) não compila. OVERBYTEV6_UP nunca é definido (nem em .dof nem em .inc). Os .dof apontam para ..\comp\overbyte e V:\projects\jedivcs\src\comp\overbyte, uma pasta que não está no repositório. O build D2009+/XE2 original usou um ICS/Midware 'JVCS edition' que se perdeu; o código-fonte original ficava no servidor JVCS vcs.delphi-jedi.org, hoje inexistente.
- [REVISÃO] Definir OVERBYTEV6_UP NÃO basta: Components\ApsCli.pas usa 'WinSock, WSocket, RFormat' sem IFDEF, e no ICS V9.3+ TSocksAuthentication/socksNoAuthentication ficam em OverbyteIcsTypes (confirmado no SVN). Portanto OverbyteIcsTypes precisa entrar nos uses de ApsCli, CBroker e JVCSConnect (l.531, socksNoAuthentication). O alias WSocket=OverbyteIcsWSocket também não resolve os tipos que mudaram de unit.
- [REVISÃO] Não dá para vendorizar 'só o subconjunto' do ICS: o OverbyteIcsWSocket V9.8 sempre usa OverbyteIcsWinsock, OverbyteIcsUtils, OverbyteIcsAvlTrees, OverbyteIcsDigestAuth, OverbyteIcsWndControl, OverbyteIcsSslBase, OverbyteIcsNtlmMsgs, OverbyteIcsWSockBuf, OverbyteIcsMimeUtils, OverbyteIcsTypes, OverbyteIcsUrl e OverbyteIcsTicks64. Com USE_SSL (padrão), também usa OverbyteIcsSSLEAY/LIBEAY e Masks; com MSCRYPT_Clients, OverbyteIcsMsSslUtils. Use a pasta Source completa (GetIt ou SVN).
- [REVISÃO] ICS 9.6 + Delphi 13.1 teve o erro E2203 ('OverbyteIcsWinCrypt contains global data'), resolvido desligando MSCRYPT_Clients/Servers/Tools no OverbyteIcsDefs.inc. O cliente JVCS não usa TLS nem o certificate store, então mantenha esses defines desligados. Desligar USE_SSL também é suportado ('remove the conditional define USE_SSL'), mas o autor avisa que versões futuras podem exigi-lo.
- [REVISÃO] SOCKS: a aba 'Socks' de Create.pas está invisível desde 2003 (histórico l.42), e as atribuições SocksServer/Port/Usercode/Password/Authentication estão comentadas (l.463-467). Sobra só SocksAuthentication=socksNoAuthentication no DBModule.dfm e em JVCSConnect. SOCKS não é requisito funcional, e o inventário anterior errou ao dizer que 'a tela de conexão expõe proxy SOCKS'.
- [REVISÃO] Modo cifrado/LZH é código morto em tempo de execução: Create.pas faz 'EncryptServerData := False' fixo (DLL l.452-453, EXE l.456-457; o checkbox está comentado), e o servidor só cifra a resposta quando a requisição veio cifrada (SrvMain.pas l.1681-1683 e l.1726-1738, CliWSocket.UserData). CipherLz/Lzh só precisam COMPILAR, com PAnsiChar nas assinaturas, porque o DBModule passa 'var Dst: PAnsiChar'. O teste byte a byte é opcional e de baixa prioridade.
- [REVISÃO] O tópico 11016 do delphipraxis NÃO relata bug do Delphi 12: o usuário pegou um lzh.pas da internet com Word, incompatível com o OverbyteCipherLz (Bytes_Got: LongWord). O lzh.pas local já é a versão LongWord (TReadProc/TWriteProc l.98/113) e é coerente com o cipherlz.pas local. Na mesma thread, F. Piette confirma que o Midware não tem suporte a Unicode nem a SSL e não é mais mantido (fev/2024).
- [REVISÃO] Ping no ICS V9: TPing (V9.3) continua expondo Reply: TIcmpEchoReply (Status/RTT/DataSize), e OverbyteIcsIcmp (V9.5) declara IP_SUCCESS = 0. O OnEchoReply mantém a assinatura (Sender, Icmp: TObject; Status: Integer). O código de Create.pas sob OVERBYTEV6_UP compila sem trocar para ReplyStatus/ReplyRTT. TPing.Ping continua síncrono, como no V5.
- [REVISÃO] GetBookmark/GotoBookmark esvaziados (-oFL) não afetam o cliente: nenhum código de jedivcsdll, jedivcsdiff ou console usa bookmarks do TMWBuffer. Restaurar é opcional. Como o EXE não define DelphiPersonalEdition (Jedivcs.dof: DEBUG;USECLIENTDISPATCHER;LANGUAGE), o RFormat usa Data.DB, onde TBookmark = TBytes (D2009+), e 'TBookmark(Tell)' passa a ser um cast perigoso. Recomendo definir DelphiPersonalEdition em todos os projetos: TBookmark vira TPosition e some a dependência de Data.DB.
- [REVISÃO] IPv4: o servidor 2.5 (ICS V5) só escuta IPv4, e o DBModule.dfm usa Server='localhost'. No ICS V9, fixe explicitamente SocketFamily := sfIPv4 no TWSocket interno do ApsCli; com sfAny, 'localhost' no Windows 11 pode resolver primeiro para ::1 e a conexão é recusada.
- [REVISÃO] Detalhe de protocolo que faltava: logo após HeaderSize, o corpo do TMWBuffer começa com 3 bytes de separadores, nesta ordem: ESC #127, FLD #18, REC #20 (SetHasData lê FDataBuffer[FHeaderSize+0..2], RFormat l.1446-1454). Os escapes são ESC+F/R/C/L/N e ESC ESC; o tipo de campo é ESC 'T' + dígito. O ApsCli separa as linhas por LF (#10, com CR opcional). Inclua esses casos no teste golden.
- [REVISÃO] DEBUG está sempre ligado (compopt.inc e Conditionals dos .dof), com {$Q+,R+}. Assim, JVCSDebug (que usa CBroker) e o JclDebug são sempre compilados, e as units JVCS rodam com range/overflow check. Teste o port do RFormat/Lzh também com range check ligado.
- Win64: CBroker TClientObject.FUserData/TResponseBroker.FUserData: LongInt guarda ponteiro (JVCSConnect faz Integer(@FUserData) em l.534/691/700/733; JVCSClientObjBase faz PUserData(FUserData)^), o que trunca em 64 bits; precisa virar NativeInt. Além disso, JVCSCrypt depende da FVCSCrypt.dll 32 bits (fvcsCliEncrypt2 devolve ShortString). EXE e DLL do expert devem continuar Win32, a menos que a criptografia seja portada. A IDE 64 bits (12.2+/13) exigiria uma DLL Win64.
- Login: a senha cifrada (ShortString com bytes >127) passa por 'S: string' em TJVCSLogin.DoExecute (JVCSClientObj.pas l.6274-6286) e volta a AnsiString no AppendFields; com ACP=65001 essa ida e volta perde bytes e o login falha. Mantenha S como AnsiString/RawByteString e envie como vtAnsiString, sem conversão.
- DFMs (DBModule, ChkInSingle, MergeVersion, ToDo) têm TAppSrvClient/TMWBuffer. Para abrir esses forms no designer do D13 é preciso um pacote design-time local que registre os componentes, mantendo as propriedades publicadas SocksAuthentication, MaxRetries, Answer, DataBufferSize, HeaderSize e AutoExpand. Em tempo de execução o streaming não precisa de RegisterComponents.
- TDateTime trafega como float em texto (FloatToStrEx = FloatToStrF ffGeneral 18) com o separador decimal do locale. [REVISÃO] SafeStrToFloat (JVCSClientObjBase l.194-211) e _StrToFloat (VCSProcBase l.707) usam a variável global DecimalSeparator, obsoleta desde o XE: troque por FormatSettings.DecimalSeparator (provavelmente nem compila no D13; confirmar). Em Win64, Extended = Double e muda os dígitos gerados.
- TJVCSClientObject.BlobAsText faz SetLength(Result, Stream.Size) + Stream.Read(Result[1], Size) com Result: string (UnicodeString), o que lê metade e deixa lixo. Use AnsiString/TBytes + TEncoding com a code page do protocolo.
- Licença: os cabeçalhos de ApsCli/CipherLz dizem 'excluding commercial applications... personal (or internal) use only', e o ReadMw.txt (2012) exige licença paga para uso empresarial (1100 EUR na época). A página atual do Midware diz apenas 'freeware'. Como há contradição, confirme com o autor se o uso for empresarial. As versões alteradas precisam ser marcadas como tais. O ICS é freeware.
- [REVISÃO] Contagem corrigida: 48 units da GUI (jedivcsdll) referenciam DataModule1.AppSrvClient1 (~3856 ocorrências), não 54/~4000. ChkInSingle.pas também usa ApsCli diretamente e faltava em usedBy.
- [REVISÃO] Esforço revisado de 'alto' para 'médio': o OverbyteRFormat 7.02 e o OverbyteApsCli 7.00 já fazem a maior parte da conversão PAnsiChar; CipherLz/Lzh só precisam compilar; CBroker tem ~650 linhas; e o JVCSClientDispatcher funciona sobre a API do TIcsWndControl do V9 (TCustomWSocket = class(TIcsWndControl)). O custo principal é a validação de protocolo.
- Validação: sem um teste golden de tráfego, mudanças sutis no escape ou na code page passam despercebidas. Capture com proxy TCP ou Wireshark os bytes do cliente oficial (JVCSv2.50ClientSetupBeta3_Refresh_till_10_4Sydney.exe) e os do novo, para GET_SERVER_TIME, LOGIN, GET_PROJECT_LIST, CHECKIN_MODULE (blob), GET_CHECKOUT_MODULE e textos acentuados, e compare byte a byte.

#### Units

| Unit | Onde está | Condição | Status D13 | Substituto | Notas |
|---|---|---|---|---|---|
| WSocket | Components\WSocket.pas (ICS V5.28, com edições FPC do F. Libaud, l.628-747) | sempre (ramo {$ELSE} de OVERBYTEV6_UP, que nunca é definido; no ApsCli, sem condição) | `substituir` | OverbyteIcsWSocket do ICS V9.7/9.8 + OverbyteIcsTypes nos uses | ICS V5 não-Unicode e inseguro em Win64; o IcsDefs.inc V5 não reconhece o D13. A API de threads (ThreadAttach/MessageLoop) continua no V9 via TIcsWndControl. |
| WSockBuf | Components\WSockBuf.pas (V5.02) | sempre (dependência do WSocket) | `substituir` | OverbyteIcsWSockBuf (ICS V9), entra automaticamente | Só serve ao WSocket V5; o equivalente V9 entra automaticamente. |
| WSocketE | Components\WSocketE.pas (cabeçalho V5.00, editor design-time com DesignIntf) | não usado pelo cliente | `remover` | OverbyteIcsWSocketE (ICS V9), só no pacote design do ICS | Editor design-time do ICS V5; o cliente não usa. |
| WSocketS | Components\WSocketS.pas (V5.04) | só servidor | `remover` | — | TWSocketServer, só do servidor. |
| IcsDefs.inc | Components\IcsDefs.inc (V1.07) | sempre | `substituir` | Source\Include\OverbyteIcsDefs.inc do ICS V9, com MSCRYPT_* desligados | Só conhece até VER190; no D13 nem COMPILER6_UP é definido e o RFormat perde até o uses de Variants. |
| icswinsock | Components\icswinsock.pas (IcsWinsock V1.00) | não usado pelo cliente | `remover` | OverbyteIcsWinsock (ICS V9), automático | Pertence ao ICS V7 parcial da pasta Trash; não usado. |
| IcsLogger | Components\IcsLogger.pas (V1.02) | sempre (NO_DEBUG_LOG só é definido para Delphi 1) | `substituir` | OverbyteIcsLogger (ICS V9), automático | O código JVCS não referencia diretamente; vem com o ICS V9. |
| IcsMD5 | Components\IcsMD5.pas (cabeçalho V1.05) | não usado | `remover` | System.Hash.THashMD5, se for necessário | Nenhum uses no cliente, console ou Diff. |
| WinSock | RTL/VCL (Winapi.Winsock) | sempre | `funciona` | — | [REVISÃO] Unit esquecida; RTL nativa (Winapi.Winsock) disponível no D13. |
| ApsCli | Components\ApsCli.pas (TAppSrvClient V3.06, fev/2007; edição FPC do Libaud) | sempre ({$IFDEF USE_SSL} nunca definido; NOFORMS não definido, então usa Forms/Classes.AllocateHWnd) | `portar-codigo` | Cópia local portada a partir do OverbyteApsCli 7.00 (PAnsiChar, Header AnsiString, TIcsWndControl, LastReplyRXTime, RcvSizeInc), adaptada ao ICS V9 e mantendo o nome ApsCli | Define o enquadramento do protocolo (banner, 'FUNC '+corpo+CRLF, 'STATUS '+corpo+CRLF, linhas por LF). Incluir OverbyteIcsTypes, fixar SocketFamily = sfIPv4 e conferir PutDataInSendBuffer/Receive no V9. |
| ApSrvCli | Components\ApSrvCli.pas (TClientWSocket V1.19) | só servidor | `remover` | — | Lado servidor. |
| ApServer | Components\ApServer.pas (TAppServer V2.04) | só servidor | `remover` | — | Lado servidor. |
| CBroker | Components\cbroker.pas (TResponseBroker/TClientObject V1.07a, correções 'PL 12/07/2003'; não existe no SVN do Midware v7) | sempre (uses de socket no ramo {$ELSE} de OVERBYTEV6_UP; {$IFNDEF NOFORMS} inclui StdCtrls) | `portar-codigo` | Manter cópia local (~650 linhas) | ~650 linhas, não existe no SVN do Midware v7. FUserData LongInt → NativeInt; WaitForAnswer faz polling sem timeout (comportamento original a preservar). |
| RBroker | Components\RBroker.pas (TRequestBroker V1.24) | só servidor | `remover` | — | Lado servidor. |
| RFormat | Components\RFormat.pas (cabeçalho V1.47, MWBufferVersion 148; GetBookmark/GotoBookmark esvaziados -oFL) | sempre; {$IFNDEF DelphiPersonalEdition} usa Db (DLL, Diff e Console definem; o EXE não) | `portar-codigo` | Cópia local portada (referência: OverbyteRFormat 7.02), com FDataBuffer PAnsiChar, separadores AnsiChar e code page fixa e configurável nas conversões string<->bytes | Formato binário imutável (3 bytes de separadores após HeaderSize, escapes ESC, blob 'ESC T', floats ffGeneral 18). Tratar vtUnicodeString/vtWideChar/vtPWideChar/vtInt64, corrigir MoveEscaped/AppendStreamField e definir DelphiPersonalEdition também no EXE. |
| MWDefs.inc | Components\MWDefs.inc | sempre | `portar-codigo` | MWDefs.inc local incluindo o OverbyteIcsDefs.inc do ICS V9 (equivale ao OverbyteMwDefs.inc do Midware v7) | Hoje inclui o IcsDefs.inc V5; passar a incluir o OverbyteIcsDefs.inc do V9 mantendo $B-,$T-,$X+,$H+,$J+. |
| TimeList | Components\TimeList.pas (V1.01) | só servidor | `remover` | — | Só servidor. |
| Wait | Components\Wait.pas (TWait V2.13) | não usado | `remover` | — | Componente obsoleto do ICS; nenhum uses. |
| WebSession | Components\WebSession.pas (V1.00) | só servidor | `remover` | — | Só servidor. |
| OverbyteIcsWSocket | Components\Trash\OverbyteIcsWSocket.pas (V7.89, parcial e quebrado; não usar) | {$IFDEF OVERBYTEV6_UP}, nunca definido (desligado) | `atualizar-versao` | OverbyteIcsWSocket do ICS V9.7 (GetIt) ou V9.8 Beta (SVN), a pasta Source completa | Alvo recomendado (pasta Source completa do V9). Definir OVERBYTEV6_UP é necessário mas não suficiente: faltam OverbyteIcsTypes e o port do ApsCli. |
| OverbyteIcsTypes | ausente (vem com o ICS V9.3+) | necessária quando se usa o ICS V9 (OVERBYTEV6_UP) | `atualizar-versao` | OverbyteIcsTypes (ICS V9.3+) | [REVISÃO] Unit esquecida: o V9.3 consolidou tipos/enums (TSocksAuthentication) nela. |
| OverbyteIcsWndControl | ausente (ICS V9; a cópia V7 da Trash não deve ser usada) | sempre que o ICS V9 for usado | `atualizar-versao` | OverbyteIcsWndControl (ICS V9) | [REVISÃO] Unit esquecida: TCustomWSocket herda de TIcsWndControl, o que garante a API de threads usada pelo dispatcher. |
| OverbyteIcsPing | ausente | {$IFDEF OVERBYTEV6_UP} (desligado) | `atualizar-versao` | OverbyteIcsPing V9.3 (ICS V9) | [REVISÃO] Compila sem mudanças no V9 (Reply: TIcmpEchoReply e OnEchoReply mantidos); TPing.Ping continua síncrono. |
| OverbyteIcsIcmp | ausente | {$IFDEF OVERBYTEV6_UP} (desligado) | `atualizar-versao` | OverbyteIcsIcmp (ICS V9.5) | [REVISÃO] Confirmado: declara IP_SUCCESS = 0 e TIcmpEchoReply. |
| Ping | ausente (unit do ICS V5 que não está no repositório) | sempre (ramo {$ELSE} de OVERBYTEV6_UP); hoje NÃO compila | `substituir` | OverbyteIcsPing (ICS V9) ou wrapper nativo sobre IcmpSendEcho (iphlpapi.dll) | Unit V5 ausente; hoje Create.pas não compila. Uso cosmético (botão Ping da conexão). |
| Icmp | ausente (unit do ICS V5 que não está no repositório) | sempre (ramo {$ELSE} de OVERBYTEV6_UP); hoje NÃO compila | `substituir` | OverbyteIcsIcmp (ICS V9) ou declarações próprias de IcmpCreateFile/IcmpSendEcho | Necessária só por IP_SUCCESS e TIcmpEchoReply. |
| CipherLz | Components\cipherlz.pas (V1.01, helper do Midware; existe OverbyteCipherLz.pas no SVN do Midware, ainda PChar) | {$DEFINE LZH} fixo no DBModule, então sempre compilado; em tempo de execução, nunca exercido: EncryptServerData := False fixo em Create.pas, e o servidor só cifra a resposta se a requisição veio cifrada | `portar-codigo` | Cópia local com PAnsiChar nas assinaturas (o DBModule passa 'var Dst: PAnsiChar') | [REVISÃO] Caminho morto em runtime (EncryptServerData := False fixo). Esta família propõe só compilar com PAnsiChar; a família Compressão e o crítico (C4) mandam remover — ver seção do crítico. |
| Lzh | Components\lzh.pas (LZHUF SWAG, versão LongWord de F. Piette/P. Lanzoni) | via CipherLz (compilado sempre, mas não exercido) | `portar-codigo` | Cópia local revisada (sem asm; só checar tipos e range check, porque DEBUG liga {$R+,Q+}) | [REVISÃO] Cópia local já coerente com cipherlz (LongWord); compila sempre, nunca é exercida. Remover junto com CipherLz (crítico C4). |
| Cipher | ausente | nunca ({$DEFINE LZH} fixo no DBModule) | `remover` | — | [REVISÃO] Unit esquecida, nunca compilada (ramo {$ELSE} de LZH); remover o ramo. |

### 3.2 Compressão e criptografia

**Família no levantamento:** Compressão e criptografia (Abbrevia, LZH/CipherLz, HashUnit, Checksum, BFCrypt/Blowfish, JVCSCrypt/FVCSCrypt.dll, IcsMD5, DelZip)

**Situação no Delphi 13.2:** `misto` · **Decisão:** `substituir-por-nativo` · **Esforço:** médio

**Pasta na v2026:**
- `src\comp\crc\Checksum.pas` (recriada; ver `src\comp\crc\LEIAME.md`).
- `src\common\client`: `JVCSCrypt.pas` (já presente); `JVCSZipUtils.pas` e `BFCrypt.pas` (novos).
- `src\comp\encryptedzip` (nova): `uEncryptedZipFile.pas`, MIT.
- `src\comp\textdiff\hashunit.pas` (já presente).
- `3rdparty\fvcscrypt.dll`: versão 1.0.0.19, já copiada da instalação 2.5.0.1030; vai para `bin\client\Win32` no build.

**Notas de consolidação:**
- **Blowfish:** o crítico (C5) confirma que é opt-in em runtime (`if EncryptModuleData then BlowFishEncode`). Só a compilação é incondicional, então prevalece esta família, não a de Componentes pequenos.
- **Tipo do ORIGCRC:** a DDL MySQL do clone (`Jedi VCS DB\2.5\mysql_create.sql`) mostra `origcrc int(11)` com sinal, o que confirma que o `CRCInt` com sinal deve ser preservado (crítico 1.14).

#### Resumo

Os blobs dos módulos são ZIP de um único item (Stored/Deflate). Eles são criados pelo TJVCSAbZipper (JVCSClientObjBase, nas 4 cópias) e lidos com TAbZipArchive (HandleBlob e ExtractBlobTo*). Os migradores JEDIVCSToGit e JcvsToGit leem esses mesmos blobs com System.Zip.TZipFile, o que confirma que é possível trocar pelo System.Zip nativo. Duas condições: preservar a data do item no ZIP (ExtractBlobToFile aplica essa data ao arquivo extraído) e confirmar no Firebird que nenhum blob antigo usa outro método de compressão ou Blowfish. O Abbrevia pode sair por completo, inclusive do Backup com senha: o TZipFile do Delphi 12/13 tem IZipCryptor mas não traz cifrador, e o Delphi 11 não tem nada. Para os três, a unit MIT EncryptedZipFile (Uwe Raabe) implementa o ZipCrypto. Correção principal da revisão: LZH/CipherLz é código morto dos dois lados (o cliente força EncryptServerData=False e o servidor só cifra a resposta se o pedido veio cifrado). Por isso recomendo remover em vez de portar. Além disso, a lzh.pas no Win64 não só muda o tamanho das tabelas: ela quebra o GetBit. Ficam como bloqueio real só a FVCSCrypt.dll (binária, 32 bits, sem fonte público), a recriação de Checksum.pas (o CRC precisa casar com o ORIGCRC já gravado) e a de BFCrypt.pas (Base64 nativo; Blowfish só se houver blobs cifrados).

#### Fonte recomendada

Nativo Delphi 11/12/13: System.Zip (TZipFile), System.ZLib (crc32), System.NetEncoding (TBase64Encoding.Create(0)), System.Hash. Para o Backup com senha (ZipCrypto/PKWARE tradicional) no 11/12/13: github.com/UweRaabe/EncryptedZipFile (MIT; TEncryptedZipFile tem código condicional para CompilerVersion<35, então cobre o Delphi 11). Isso dispensa o Abbrevia. Fallback, se preferir não usar a unit do Raabe: TurboPack Abbrevia (GetIt "Abbrevia 2025.11", 26/11/2025, listado para Delphi 13; dspec 13.0.0 cobre delphi11.0–12.0 win32/win64 e delphi13.0 win32/win64/winarm64ec; pacotes em packages\11AndAbove). Blowfish, somente se existirem blobs cifrados e o formato for recuperado: DEC 6.4.1 (github.com/MHumm/DelphiEncryptionCompendium, readme diz XE7 a 13.2 Florence). FVCSCrypt.dll (32 bits): extrair do instalador D:\Delphi\JediVCS\Instalador_2.50_Beta3_10.4Sydney\JVCSv2.50ClientSetupBeta3_Refresh_till_10_4Sydney.exe (Inno Setup; o mesmo arquivo está em sourceforge.net/projects/jedivcs/files/2.5x Beta 3/Client/), numa pasta isolada e em fase posterior. Não achei fonte público de fvcs_Encrypt1/2. Lzh/CipherLz: não buscar nenhuma fonte, porque a recomendação é remover. O MidWare oficial teve a última atualização em 04/2019 (Delphi 10.3.1 Rio), e em 02/2024 o autor declarou que não o mantém mais e que ele não suporta Unicode.

#### Alternativa nativa

Sim, cobre quase toda a família e vale trocar. (a) Blobs ZIP (check-in, check-out, ExtractBlobToDir/File/Stream, BlobAsText, Dump do ProjectTree, Distribution, cache ZXML com LINEINFOEX): System.Zip.TZipFile, isolado numa unit wrapper (ex.: JVCSZipUtils.pas). Três cuidados. Primeiro, gravar com Add(FileName, ExtractFileName(FileName), zcDeflate) ou com o overload que recebe TZipHeader, nunca com Add(Stream, nome), que grava a data como Now; a data do item é aplicada ao arquivo por ExtractBlobToFile no console e nos sync. Segundo, para substituir o VerifyZip, checar a assinatura 'PK'#3#4 manualmente: o TZipFile.IsValid(Stream) está documentado no Athens, mas não confirmei no Delphi 11. Terceiro, o TZipFile só descompacta Stored/Deflate (mais Deflate64 a partir do 12), enquanto o Abbrevia aceita métodos legados. (b) Backup/restore com senha: TZipFile + TEncryptedZipFile/TPKWAREZipCryptor (Uwe Raabe, MIT), compatível com o ZipCrypto do Abbrevia. Perde-se o nível de compressão (doFast/doNormal/doMaximum) e o TagItems, que precisam ser reimplementados. (c) CRC-32 de arquivo (Checksum.CRCInt/CRCString): System.ZLib.crc32 lendo em blocos, com fmShareDenyWrite, cast explícito Integer(crc) e a unit compilada com {$R-}{$Q-}, porque o compopt.inc em DEBUG liga R+ e Q+. (d) Base64 (BFCrypt): TBase64Encoding.Create(0), sem quebra de linha. (e) HashUnit (hash de linha do diff, só em memória): System.ZLib.crc32 sobre TEncoding.UTF8.GetBytes ou THashBobJenkins. (f) MD5 (IcsMD5, sem uso): THashMD5, se um dia precisar. Sem equivalente nativo: o Blowfish dos blobs (usar DEC depois de recuperar o formato) e a FVCSCrypt (algoritmo fechado que precisa casar com a ServerCrypt.dll). Para LZHUF não é preciso alternativa: é código morto e deve ser removido.

#### Destino proposto pelo inventário (texto original)

src\common\client (JVCSCrypt.pas único; Checksum.pas e BFCrypt.pas recriados com RTL nativa; wrapper novo JVCSZipUtils.pas sobre System.Zip) + src\comp\encryptedzip (uEncryptedZipFile.pas MIT de Uwe Raabe, só para Backup/restore com senha) + src\comp\textdiff (HashUnit corrigida, se não for substituída por crc32/BobJenkins) + bin\client (FVCSCrypt.dll de 32 bits redistribuída) + externo opcional: DEC 6.4.1 (somente se houver blobs Blowfish). Não levar para v2026: Lzh.pas, CipherLz.pas (código morto), IcsMD5, Components\COM, Components\Win32|Win64\\\*.obj e toda a cópia Ab* 5.0.

#### Riscos

- FVCSCrypt.dll (senha de login: fvcs_Encrypt1 para gravar e fvcs_Encrypt2 com a hora do servidor menos 1 s para o login; convenção register com ShortString/TDateTime) é binária, fechada e só de 32 bits. TJVCSConnection.Create gera exceção se ela não estiver ao lado do EXE/DLL, o que afeta o EXE, a DLL da IDE, o Diff e o console. Ela não está no repositório e precisa ser extraída do instalador 2.50 Beta 3.
- [REVISÃO] O impacto da FVCSCrypt no alvo principal é menor do que parecia. O RAD Studio 13 Florence continua instalando a IDE de 32 bits junto com a de 64 bits, e um EXE Win32 roda emulado no Windows 11 ARM64. Assim, o cliente Win32 e a JediVCSDLL Win32 (carregada na IDE de 32 bits) funcionam. Ficam bloqueados apenas a IDE de 64 bits, o Win64 e o Win ARM64EC (alvo Delphi desde o 13.1). Não encontrei fonte público de fvcs_Encrypt1/2.
- [REVISÃO] Lzh no Win64 é pior que "tabelas de tamanho diferente". Em TLZH.GetBit (lzh.pas:477-497), i2 := getbuf (WORD) é seguido de getbit := Int16(i2 < 0). Com Int16=Integer (WIN32 não definido no Win64), i2 nunca fica negativo, GetBit sempre devolve 0 e a decodificação LZHUF quebra por completo.
- [REVISÃO] LZH/CipherLz é código morto confirmado dos dois lados. O cliente força EncryptServerData := False nas duas cópias (jedivcsdll\Create.pas:453 e jedivcs\Create.pas:457), e o console e o Diff nem usam CipherLz. O servidor (SrvMain.pas:1682 e 1727-1737) só cifra a resposta quando o pedido chegou com #$FF. Recomendo remover CipherLz/Lzh do cliente e simplificar os handlers de DBModule (pode-se manter uma checagem defensiva de #$FF que gere erro), em vez de portar. Outros motivos: a licença da cipherlz.pas exclui uso comercial, e o ramo {$ELSE} do DBModule depende de uma unit 'Cipher' ausente.
- [REVISÃO] cipherlz.pas não é "a variante FPC". É o MidWare 1.01 original, pré-Unicode (PChar/String), com apenas um guard {$ifdef FPC}. O ApsCli.pas de Components também é PChar, enquanto o DBModule usa PAnsiChar. Ou seja, toda a cópia MidWare de Components é pré-Unicode e não é a que gerou o build Unicode original. Se mesmo assim decidirem portar, mudar para PAnsiChar/AnsiString.
- [REVISÃO] Status do MidWare corrigido: a última atualização oficial é de 14/04/2019 (Delphi 10.3.1 Rio), não de 2010. Em 11/02/2024 François Piette declarou que não mantém mais a biblioteca e que ela não suporta Unicode nem SSL.
- Checksum.pas e BFCrypt.pas não existem no clone nem no histórico git (3 commits, todos de 2017) e não foram achados na web. O CRC recriado precisa reproduzir exatamente o ORIGCRC já gravado (ChkInSingle.pas:1636 envia CRCInt; o servidor grava o valor como recebeu). Se divergir, Sync, Compare, ModuleInfo, ProjAdmin e IsFileDirtyCRC vão marcar arquivos como alterados. Validar comparando BLOBS.ORIGCRC com o CRC do diretório central do ZIP de vários blobs. Revisões com expansão de keywords no check-in podem divergir, então use uma amostra ampla.
- [REVISÃO] Na Checksum recriada, o compopt.inc em DEBUG liga {$R+,Q+}. Converter o crc32 (Cardinal) para Integer com atribuição implícita gera ERangeError em CRCs >= $80000000. Use cast explícito Integer(crc) e {$R-}{$Q-} na unit. Abra os arquivos com compartilhamento (podem estar abertos na IDE). No console (jvcs.dpr:930), prefira CRCInt a StrToInt(CRCString).
- Blobs cifrados com Blowfish (EncryptModuleData no registro ou GlobalSettingValue(7)) ficam ilegíveis sem o BFCrypt original. Antes de decidir, varrer BLOBS.FILEDATA: o que não começa com 'PK'#3#4 está cifrado. O console e o Diff (ExtractBlobToFile/Stream) já ignoram silenciosamente blobs não ZIP.
- [REVISÃO] Para recuperar o formato do BFCrypt sem o fonte, existe um caminho de caixa-preta. Num servidor ou projeto de teste, usar o cliente 2.5 Beta 3 instalado com EncryptModuleData ligado e uma chave conhecida para gerar pares texto claro/cifrado (o texto claro é o ZIP do próprio cliente). Depois, testar no DEC as combinações de modo (ECB/CBC/CFB8/OFB, IV zero) e de derivação de chave (chave crua, SHA1 ou MD5, no estilo DCPcrypt v2 InitStr). Se não houver blobs cifrados, desativar a opção.
- [REVISÃO] O TZipFile só descompacta Stored e Deflate (mais Deflate64 a partir do Delphi 12). Bancos que vieram de versões antigas podem ter blobs gravados pelo console com NanoZip (antes de 10/2004) ou pelo DelZip/FreeVCS. Varrer BLOBS.FILEDATA conferindo o método no local header (offset 8, que deve ser 0 ou 8) e o bit 0 de flags (cifrado ZIP, que deve ser 0). Se houver exceções, manter um leitor de fallback.
- [REVISÃO] Com TZipFile.Add(Stream, nome) a data do item vira Now. ExtractBlobToFile (4 cópias; usado pelo console em jvcs.dpr:1202/1364/2192/2945) aplica LastModTime do item ao arquivo extraído, então tanto clientes novos quanto 2.5 Beta 3 restaurariam a data errada. Gravar com Add(FileName, ...) ou com o overload TZipHeader, usando a data do arquivo.
- [REVISÃO] O TZipFile do Delphi 12/13 tem a propriedade Cryptor (IZipCryptor), mas não traz implementação ("no implementation delivered for legal reasons", Uwe Raabe). O Delphi 11 não tem nem a interface. A unit MIT EncryptedZipFile resolve os três, e com ela o Abbrevia pode ser eliminado também do Backup. Testar a restauração de backups antigos com senha não ASCII: o Abbrevia 5.0 usava senha AnsiString e a conversão para bytes precisa ser a mesma.
- [REVISÃO] A cópia local do Abbrevia 5.0 nem compila com o Backup.pas em Delphi Unicode. Em Components\AbZipTyp.pas:199-200, TAbNeedPasswordEvent usa var NewPassword: AnsiString, enquanto Backup.pas:198 declara AbOnNeedPassword(var NewPassword: string). No TurboPack atual é string. Isso reforça não levar a cópia 5.0 (que também liga .obj bzip2/LZMA/PPMd/WavPack da era XE2 via UnzipZipxSupport em AbDefine.inc:240).
- Os valores Base64 no registro (senha de identidade em Create.pas:1239/1301 e EncodeKey em Options.pas:791/1857) dependem de como o binário antigo convertia a string em bytes (ANSI ou UTF-16), o que é desconhecido. Testar com um registro real ou pedir de novo na primeira execução.
- HashUnit usa PChar + length em string Unicode e só faz hash do byte baixo de cada caractere, o que gera colisões em linhas não ASCII e diffs errados. JVCSCompressedDiffUnit.pas:225/414 e JVCSLineHistoryUnit.pas:1377 fazem cast de TList.List para PIntArray, o que dá errado no Win64. O hash não é persistido.
- [REVISÃO] Formato da property 'Line History' no servidor: com LINEINFOEX é ZXML (ZIP via Abbrevia); sem ele (o padrão, ausente de compopt.inc e dos .dof) é RevisionInfoSaveToStream. Não se sabe com que define o binário 2.5 Beta 3 foi compilado. Se for diferente do cliente novo, o cache de Line History gravado não carrega. Impacto baixo (é cache); verificar no banco se o conteúdo começa com 'PK'.
- [REVISÃO] Os .dpr apontam JVCSCrypt, JVCSCompressedDiffUnit e JVCSLineHistoryUnit para '..\common\client\\', pasta que não existe no clone ('Jedi VCS Client\2.5\common' está ausente). As 4 cópias de JVCSCrypt.pas são idênticas (md5 43f4fcf2...), e as de JVCSClientObjBase da DLL, do Diff e do console também. Unificar numa só pasta no v2026.
- TZipFile grava nomes em UTF-8 (bit 11) quando há caracteres não ASCII. O impacto é baixo porque HandleBlob e ExtractBlobToFile usam o nome do módulo como fallback quando o nome do item não bate.

#### Units

| Unit | Onde está | Condição | Status D13 | Substituto | Notas |
|---|---|---|---|---|---|
| AbZipTyp (TAbZipArchive, TAbZipItem, VerifyZip) | Components\AbZipTyp.pas (Abbrevia 5.0) | sempre; em JVCSLineHistoryUnit só sob {$IFDEF LINEINFOEX}, ausente de compopt.inc e dos .dof | `substituir` | System.Zip.TZipFile (Open/Read/Extract) + checagem manual de 'PK'#3#4 no lugar de VerifyZip (IsValid(Stream) não confirmado no Delphi 11) | Blob = ZIP de 1 item; JEDIVCSToGit/JcvsToGit leem com TZipFile, o que comprova a troca. ExtractBlobToFile aplica a data do item ao arquivo. |
| AbZipper (TAbZipper → TJVCSAbZipper) | Components\AbZipper.pas | sempre | `substituir` | TZipFile.Add(FileName, ExtractFileName(FileName), zcDeflate) ou o overload com TZipHeader; nunca Add(Stream, nome), que grava a data como Now | Único ponto que gera blobs novos: manter ZIP Deflate de 1 item, nome sem path e data do arquivo; nunca Add(Stream, nome), que grava Now. |
| AbArcTyp | Components\AbArcTyp.pas | sempre (LineHistory: LINEINFOEX) | `substituir` | System.Zip (sai junto com TAbArchive) | Tipos base do Abbrevia; saem com TAbArchive. |
| AbBase | Components\AbBase.pas | sempre | `remover` | nenhum | Só ancestral do TAbZipper. |
| AbUtils | Components\AbUtils.pas | sempre | `substituir` | StringReplace(S, '\\', '/', [rfReplaceAll]) e rotinas da RTL | AbFixName e utilitários; RTL resolve. |
| AbUnzPrc (AbUnzipToStream, AbUnzip) | Components\AbUnzPrc.pas | sempre; UnzipZipxSupport (AbDefine.inc:240) puxa AbBzip2, AbLZMA, AbPPMd, AbWavPack e os .obj de Components\Win32\|Win64 | `substituir` | TZipFile.Read(índice, Stream, Header) / Extract | Os .obj de zipx (era XE2) são desnecessários para blobs JVCS. |
| AbZipPrc (AbZip, AbZipFromStream) | Components\AbZipPrc.pas | sempre (LineHistory: LINEINFOEX) | `substituir` | TZipFile.Add | Com LINEINFOEX o ZIP 'LineHistory' vai ao servidor como property; confirmar com qual define o 2.5 Beta 3 foi compilado. |
| AbDlgPwd (TPassWordDlg) | Components\AbDlgPwd.pas/.dfm | sempre | `substituir` | Password.pas/TVCSPassword, que o Backup.pas já usa para pedir a senha do backup | Desnecessário se o restore usar TEncryptedZipFile; Password.pas já pede a senha. |
| Demais Ab* (AbConst, AbExcept, AbResString, AbDf*, AbSpanSt, AbSWStm, AbVMStrm, AbCharset, AbBitBkt, AbUnzOutStm, AbBrowse, AbZBrows, AbTarTyp, AbGzTyp, AbBzip2Typ, AbBzip2, AbLZMA, AbPPMd, AbWavPack, AbQ*, AbCab*, AbView...) + Components\Win32\|Win64\\\*.obj | Components\ (cópia completa do Abbrevia 5.0) | transitivo | `remover` | System.Zip (+ EncryptedZipFile para senha). Fallback: pacote TurboPack Abbrevia completo via GetIt/GitHub | Não levar a cópia 5.0 para a v2026. |
| Abbrevia COM (Abbrevia.dpr, Abbrevia_TLB.pas, Abbrevia.dll Win32/Win64) | Components\COM\ | não usado | `remover` | — | DLL COM do Abbrevia 5.0, sem uso. |
| ZipCrypto para Backup com senha (nova dependência proposta) | ausente; proposta: github.com/UweRaabe/EncryptedZipFile (uEncryptedZipFile.pas, PKWAREZipCryptor.pas, MIT) | sempre (só em runtime, quando o usuário informa senha) | `portar-codigo` | TEncryptedZipFile (Delphi 11, condicional para CompilerVersion<35) ou TZipFile.Cryptor := TPKWAREZipCryptor (Delphi 12+) | TZipFile do D12/13 não traz cifrador e o do D11 nem tem a interface; a unit MIT resolve os três. Validar a abertura de backups antigos com senha. |
| Lzh (TLZH: LZHPack/LZHUnpack) | Components\lzh.pas (o índice git tem Lzh.PAS e lzh.pas com o mesmo blob 90fe6131) | compilado sempre ({$DEFINE LZH} em DBModule.pas:60), mas em runtime é código morto | `remover` | nenhum (remover junto com CipherLz) | [REVISÃO] No Win64 o GetBit quebra (Int16=Integer); código morto, remover junto com CipherLz. |
| CipherLz (Encrypt/Decrypt do protocolo MidWare) | Components\cipherlz.pas (MidWare 1.01 pré-Unicode, PChar/String; licença exclui uso comercial) | {$DEFINE LZH} fixo. Encrypt só roda se EncryptServerData, que está forçado a False em Create.pas (jedivcsdll:453, jedivcs:457). Decrypt só roda se a resposta começa com #$FF, e o servidor só faz isso se o pedido veio cifrado (SrvMain.pas:1682/1727). Console e Diff não usam. | `remover` | nenhum; tirar dos handlers de DBModule (opcionalmente gerar erro se chegar #$FF) | [REVISÃO] Formato só como referência ([#$FF][8 hex][LZHUF com escape #4]). Remover sem impacto de protocolo; manter checagem de #$FF que gere erro. |
| HashUnit (HashLine, CRC-32 de Earl Glynn) | Components\hashunit.pas (TextDiff 4.1, Angus Johnson) | sempre | `portar-codigo` | System.ZLib.crc32 sobre TEncoding.UTF8.GetBytes(linha) ou THashBobJenkins.GetHashValue | Hash de linha só em memória; bug Unicode (só o byte baixo) e bug Win64 nos chamadores (PIntArray(TList.List)). |
| Checksum (CRCInt(FileName; var ErrMsg): Integer; CRCString(FileName): '$XXXXXXXX') | ausente (não está no clone, no histórico git nem na web) | sempre. Em jedivcs\JVCSClientFunctions.pas (port Lazarus) está sob {$ifdef BORLAND} e a chamada a CRCInt foi comentada (linha 271); usar a cópia de jedivcsdll. | `substituir` | Recriar com System.ZLib.crc32 (IEEE/PKZIP) lendo em blocos, com cast explícito Integer(crc), {$R-}{$Q-} e abertura compartilhada; CRCString = '$'+IntToHex(crc,8) | CRÍTICO: valor gravado em BLOBS.ORIGCRC e comparado por todos os clientes. Validar contra o CRC do diretório central do ZIP de vários blobs. |
| BFCrypt: Base64Encode/Base64Decode | ausente | sempre compilado (o define BLOWFISH não é mais usado desde 2010) | `substituir` | System.NetEncoding.TBase64Encoding.Create(0) sobre bytes ANSI (confirmar com um valor real do registro) | Codificação usada pelo binário antigo (ANSI ou UTF-16) desconhecida; testar com o registro de uma estação 2.5 Beta 3. |
| BFCrypt: BlowFishEncode/BlowFishDecode(Owner, Key, InFile, OutFile): Boolean | ausente (o HowToBuild cita DcpCrypt v2 beta2 e CryptoLib 1996; não achei fonte na web) | sempre compilado; em runtime só com EncryptModuleData (registro, padrão False) ou GlobalSettingValue(7) do servidor. Console e Diff não decifram. | `incerto` | DEC 6.4.1 TCipher_Blowfish, somente depois de recuperar o formato por caixa-preta com o cliente 2.5 Beta 3; senão, desativar a opção | Só ativo em runtime com EncryptModuleData/GlobalSettingValue(7). Varrer BLOBS.FILEDATA; se não houver blobs cifrados, desativar a opção. |
| JVCSCrypt (fvcsCliEncrypt1/fvcsCliEncrypt2, LoadFVCSCrypt) + FVCSCrypt.dll | 4 cópias idênticas (md5 43f4fcf2...) em jedivcs, jedivcsdll, jedivcsdiff e console; os .dpr apontam para ..\common\client\JVCSCrypt.pas, que não existe. FVCSCrypt.dll ausente do repositório. | sempre (FVCSCRYPT_STATICDLL não definido, então a carga é dinâmica) | `funciona` | nenhum; manter o wrapper e a DLL original (o servidor compara via ServerCrypt.dll/fvcs_CryptCompare) | Funciona em Win32 (ABI register com ShortString/TDateTime) e roda emulado no ARM64; bloqueia Win64/ARM64EC/IDE 64 bits. |
| IcsMD5 | Components\IcsMD5.pas (também Components\Trash\OverbyteIcsMD5.pas) | não usado | `remover` | System.Hash.THashMD5, se algum dia precisar | Órfã. |
| DelZip / ZipMaster (zipdll.dll, unzdll.dll) | ausente (só referências) | sempre (código residual) | `remover` | — | Código residual do About e resourcestrings de erro; remover o bloco e renomear as strings. |

### 3.3 JEDI Code Library (JCL)

**Família no levantamento:** JEDI Code Library (JCL)

**Situação no Delphi 13.2:** `misto` · **Decisão:** `manter-atualizado` · **Esforço:** médio

**Pasta na v2026:** a JCL fica externa (GitHub/GetIt), sem copiar para o repositório. O `jedi.inc` vai fixado em `src\common`. Os helpers nativos novos (`JVCSTrace.pas`, `JVCSStrUtils.pas`, `JVCSFileUtils.pas`, `EnablePrivilege`) vão em `src\common`.

**Notas de consolidação:**
- **VerSet/AnsiCrLf (crítico C1):** VerSet entra no EXE só sob `{$IFDEF IDEDLL}`, então a quebra `AnsiCrLf` afeta **só a DLL**. Na v2026 os pontos estão em `src\jedivcs\JediVCSDLL.dpr:1187` e `src\jedivcs\VerSet.pas:841/851`.
- **TZHandling do console:** a v2026 usa a cópia de `jedivcsdll` (`src\common\client\TZHandling.pas`, sem o `{$ifdef WINDOWS}` do console), conforme o manifesto. A quebra citada para o console não existe na árvore nova.
- **`{$ifdef WINDOWS}` restante:** fora de `_legacy`, o único caso na v2026 é `src\common\JVCSIDESettings.pas:95`.
- **Variáveis globais de formato (crítico C2):** `ThousandSeparator`/`DecimalSeparator` globais **não compilam** no D13 (não é só aviso).
- **GetIt x GitHub (crítico C8):** use o GitHub master para ter a mesma versão no 11, 12 e 13.

#### Resumo

O cliente usa de fato 10 units da JCL: JclDebug, JclFileUtils, JclStrings, JclSysInfo, JclSecurity, JclWin32, JclSimpleXml, JclResources, JclPCRE e JclRegistry (esta só na DLL). Usa também o include jedi.inc. JclOpenDialogFavorites, ExceptDlg e TJclDebugThread aparecem só em ramos desligados. Todas essas units existem na JCL atual, que suporta Delphi 13 Florence: GetIt 2026.08, de 18/08/2026, e GitHub master, com o último merge em 21/09/2026.

As quebras de compilação reais ligadas à família são três:

- AnsiCrLf em JediVCSDLL.dpr:1195 e em VerSet.pas:841/851. O VerSet só existe em jedivcsdll, mas o EXE também o usa.
- {$ifdef WINDOWS}, edição do port Lazarus, em JVCSIDESettings.pas (DLL).
- O mesmo {$ifdef WINDOWS} em TZHandling.pas do console, que deixa vazio o uses onde está a JclDebug.

A chamada JclDebug.Trace em JVCSIDEInterface.pas:721 NÃO quebra o build padrão. Ela fica no ramo INTERNAL_OLDOTA, que é código morto porque o JediVCSDLL.dof define EXT_IDE_INTF.

A JCL não altera o formato das mensagens MidWare trocadas com o servidor 2.5 Beta 3, mas produz dados que vão para ele: o header XML do line history (TJclSimpleXML) e, no console, os tamanhos enviados no check-in (GetSizeOfFile). Recomendação: manter a JCL externa e atualizada, já que a JVCL depende dela, e trocar por nativo só o que é trivial, testando os pontos que geram dados.

#### Fonte recomendada

GetIt no RAD Studio 13 Florence: 'JEDI Code Library (JCL)' 2026.08, atualizado em 18/08/2026 (https://getitnow.embarcadero.com/JEDICodeLibraryJCL-13-2026.08). É mais novo que o 2025.10 citado no inventário original. Deve ser instalado junto com a JVCL 2026.08 do mesmo GetIt, para que as versões casem.

Recomendado para ter as correções mais recentes e a MESMA versão no Delphi 11, 12 e 13: GitHub project-jedi/jcl master (https://github.com/project-jedi/jcl).

- Commits recentes: 17/09/2025 'proper packages for win64 support in RS13'; 05/2026 correções de noreturn/COMPILER37_UP; 22/06 e 02/09/2026 correções de JclDebug; último merge (PR #199) em 21/09/2026.
- Clonar com 'git submodule update --init' para obter o jedi.inc (project-jedi/jedi, que define DELPHI37/DELPHI_FLORENCE) e instalar com jcl\install.bat (o dcc32 existe na Professional).
- O GetIt do RS12 lista só a 2023.11 (https://tp.embarcadero.com/jedi-code-library), por isso o GitHub é a forma de padronizar a versão.

Não copiar a JCL para o repositório.

#### Alternativa nativa

Trocas que valem a pena, porque são baratas e não afetam o formato do protocolo:

- JclPCRE → System.RegularExpressions.TRegEx:
  - M := TRegEx.Match(S, sBugtrackerRegEx); if M.Success then LastBugReference := M.Groups['bug'].Value.
  - Envolver em try/except: Groups['bug'] levanta exceção se a regex configurada pelo usuário não tiver o grupo, e uma regex inválida também levanta.
  - Elimina a dependência de PCRE da JCL. O padrão do jcl.template.inc é PCRE_LINKONREQUEST, que carrega uma DLL sob demanda.
- JclRegistry → System.Win.Registry.TRegistry (OpenKeyReadOnly/GetKeyNames/ReadString), junto com a reescrita da detecção da IDE.
- JclWin32 → Winapi.Windows (SE_DEBUG_NAME, SE_SYSTEMTIME_NAME, VER_PLATFORM_WIN32_NT). Confirmar na primeira compilação.
- JclSecurity.EnableProcessPrivilege → helper local com OpenProcessToken/LookupPrivilegeValue/AdjustTokenPrivileges. O pedido de SE_DEBUG pode ser removido: não é necessário para OutputDebugString e altera o token do processo da IDE.
- JclSysInfo:
  - GetAppdataFolder → TPath.GetHomePath (%APPDATA% Roaming, sem barra final, igual à JCL).
  - GetCommonAppdataFolder → TPath.GetPublicPath (C:\ProgramData).
  - GetWindowsVersionString → TOSVersion.ToString (só exibição, em lblOs).
  - ExpandEnvironmentVar → wrapper de ExpandEnvironmentStrings.
- JclResources → resourcestrings locais.
- JclDebug (só TraceMsg/TraceFmt): unit local JVCSTrace sobre OutputDebugString.
  - Trocar também os uses, não só o prefixo 'JclDebug.': há chamadas sem qualificador, como JVCSIDEInterface.pas:445.
  - Não chamar a unit local de 'JclDebug', porque colidiria com a JclDebug que a JVCL usa.

Opcional, com mais trabalho e com testes:

- JclStrings:
  - StrToken / StrTokenToStrings: helper local. TStringList.DelimitedText trata aspas e difere da JCL.
  - StrMatches: reimplementar localmente, porque MatchesMask trata '['. A JCL levanta exceção com padrão vazio.
  - StrReplace(S, a, b) → StringReplace(S, a, b, []). Sem flags, a JCL troca só a PRIMEIRA ocorrência; NÃO usar rfReplaceAll se quiser comportamento idêntico.
  - StrSame → SameText; StrRestOf → Copy; StrRemoveChars/StrReplaceChars → laço; AnsiCrLf → sLineBreak.
- JclFileUtils:
  - PathAddSeparator → IncludeTrailingPathDelimiter; PathRemoveSeparator → ExcludeTrailingPathDelimiter.
  - PathCanonicalize: é textual na JCL. TPath.GetFullPath usa o diretório corrente; só equivale com caminho absoluto.
  - BuildFileList(faAnyFile) também lista subpastas; TDirectory.GetFiles não lista e devolve caminho completo.
  - FileCopy → TFile.Copy/CopyFile; IsDirectory → DirectoryExists.
  - GetFileCreation/GetFileLastWrite → TFile.GetCreationTime/FileAge.
  - GetSizeOfFile → Int64 via GetFileAttributesEx. No console, esse valor vai para o servidor.
  - GetFileInformation → FindFirst; FileGetOwnerName → GetNamedSecurityInfo + LookupAccountSid.
  - TJclFileVersionInfo → helper GetFileVersionInfo/VerQueryValue. Precisa ler ProductVersion, FileVersion, ProductName, FileDescription, CompanyName e as chaves 'BuildTimestamp' e 'ProductTitle'.
- JclSimpleXml → manter. Trocar por TXMLDocument só com teste de ida e volta dos headers.

Não vale tentar tirar a JCL do ambiente de build enquanto a JVCL estiver no EXE, na DLL e no Diff. Só o console pode ficar 100% livre da JCL.

#### Destino proposto pelo inventário (texto original)

externo via GetIt/GitHub (não copiar a JCL para o repositório); jedi.inc fixado em D:\Delphi\JediVCS\v2026\src\common (ou src\comp\jedi); helpers nativos novos (JVCSTrace.pas, JVCSStrUtils.pas/JVCSFileUtils.pas, EnablePrivilege) em D:\Delphi\JediVCS\v2026\src\common

#### Riscos

- Quebra de compilação 1 (confirmada): AnsiCrLf hoje só existe em JclAnsiStrings; JclStrings e JclBase expõem apenas NativeCrLf/NativeLineBreak. Ocorre em jedivcsdll\JediVCSDLL.dpr:1195 e jedivcsdll\VerSet.pas:841 e 851. Trocar por sLineBreak.
- [REVISÃO] VerSet.pas só existe em jedivcsdll, mas também é usado pelo EXE: jedivcs\ProjAdmin.pas:1123, ChkOutSingle.pas:194 e MergeVersion.pas:144. Portanto a quebra do AnsiCrLf afeta o EXE e a DLL, não só a DLL.
- [REVISÃO] Quebra 2 refutada: JclDebug.Trace em jedivcsdll\JVCSIDEInterface.pas:721 está dentro de {$IFDEF INTERNAL_OLDOTA} (linhas 467-772), e esse símbolo só é definido quando EXT_IDE_INTF NÃO está definido. O JediVCSDLL.dof define EXT_IDE_INTF (Conditionals=DEBUG;IDEDLL;EXT_IDE_INTF;LANGUAGE;...), então no build padrão é código morto. Além disso, o ramo OLDOTA depende de ToolIntf/EditIntf/VCSIntf (OTA antiga, ausente no ToolsAPI moderno) e não compilaria no D13 de qualquer forma. O risco real é o novo .dproj precisar definir IDEDLL e EXT_IDE_INTF, porque o compopt.inc deixa EXT_IDE_INTF comentado.
- Quebra de compilação 3 (confirmada): em jedivcsdll\JVCSIDESettings.pas:95-99, o JclRegistry fica dentro de {$ifdef WINDOWS}. Nem o Delphi nem o jedi.inc definem WINDOWS para o Delphi (o jedi.inc só o mapeia para Oxygene/Elements), então o uses vira ', JclFileUtils' e dá erro de sintaxe. Além disso, a detecção da IDE só conhece as chaves Software\Borland e CodeGear\BDS; para Delphi 11/12/13 precisa de Software\Embarcadero\BDS\22.0/23.0/37.0.
- [REVISÃO] Quebra esquecida: em Jedi vcs console\2.5\TZHandling.pas:56-66, o uses inteiro da implementação (Windows, SysUtils e JclDebug sob DEBUG) está dentro de {$ifdef WINDOWS}. No Delphi o uses fica vazio e o build quebra, e o console tem DEBUG ligado no jvcs.dof. A edição Lazarus também alcançou jedivcs\ProjAdmin.pas:265 ({$ifdef WINDOWS}Windows,{$endif}) e Jedivcs.dpr.
- [REVISÃO] A afirmação de que a pasta jedivcsdll tem as cópias originais do Delphi está só parcialmente correta. O próprio JediVCSDLL.dpr foi convertido pelo conversor Lazarus: tem LCLIntf, LCLType e LMessages incondicionais na linha 223 e blocos {$IFnDEF FPC}. O .dpr original do Delphi está em jedivcsdll\ConverterBackup\JediVCSDLL.dpr, e o do console em Jedi vcs console\2.5\ConverterBackup\jvcs.dpr. Usá-los como referência dos uses originais (FastMM4, Windows, ShellAPI).
- [REVISÃO] Protocolo: não é exato dizer que nenhuma função da JCL participa da comunicação com o servidor. No console, jvcs.dpr:927 e 931 usa JclFileUtils.GetSizeOfFile para calcular ModuleOriginalSize e ModuleCompressedSize, que vão para o servidor no TJVCSCheckinModule. O substituto tem de devolver o mesmo Int64 em bytes. O formato das mensagens MidWare não depende da JCL.
- JclSimpleXml em JVCSLineHistoryPropertyStorage (GetAsString/SetAsString) gera o header gravado no servidor via TJVCSAddUpdateProperties.Header; o servidor só armazena o texto (JVCSSrvOBJProperties.pas:639/676, coluna 'header'). [REVISÃO] Detalhes:
  - Com as opções padrão (sxoAutoIndent), a saída inclui prolog &lt;?xml ...?> e indentação.
  - Clientes 2.5 Beta 3 só leem o header se o primeiro caractere for '<'.
  - Um substituto que emita BOM ou espaço inicial faz os clientes antigos ignorarem o header e recalcularem o line history: não corrompe dados, mas gera tráfego.
  - A DDL da coluna não está no clone, então verificar o tamanho máximo antes de mudar o formato.
- [REVISÃO] Caminhos corrigidos: no clone, JVCSLineHistoryPropertyStorage.pas e JVCSDebug.pas não estão em 'common\client' nem em 'common'; estão em jedivcs\ e jedivcsdll\\. A pasta common do clone só tem VCSCommon.pas, e 'common\client' só aparece nos caminhos relativos dos .dpr/.dof originais.
- [REVISÃO] O JediVCSDLL.dof NÃO inclui ..\jedivcs no SearchPath. Por isso ExtBugtracker (JclPCRE) e SaveWIP (JclSysInfo), usados pela DLL em History, ModuleHistoryWindow, ProjAdmin e JVCSLockedModulesDockWnd, não seriam encontrados com o .dof do clone. O novo .dproj tem de incluí-los explicitamente.
- JclPCRE (confirmado e reforçado):
  - [REVISÃO] O padrão do jcl.template.inc atual é PCRE_LINKONREQUEST, que carrega a DLL PCRE em tempo de execução. Sem a DLL, a regex do bugtracker falha em runtime.
  - Trocar por TRegEx. Proteger Groups['bug'] com try/except, porque a regex é digitada pelo usuário.
- [REVISÃO] StrReplace: a JCL sem flags substitui só a PRIMEIRA ocorrência; o rfReplaceAll proposto no inventário mudaria o comportamento. Só há uma chamada (JVCSChkInOutCommon.pas:184, caption do menu MRU), então é inofensivo, mas para equivalência use StringReplace(..., []).
- [REVISÃO] StrMatches: a JCL é chamada em um único ponto, JVCSClientFunctions.MatchWithFilter:663 (nas cópias de DLL/EXE, Diff e console); as demais ocorrências são o StrMatches LOCAL de 4 parâmetros em JVCSProjectTreeUnit. Mesmo assim o uso é central, porque MatchWithFilter decide NotReadOnlyFilter e KWExpandFilter no check-in e a máscara em AssignLabels. A JCL aceita só '*' e '?' e levanta EJclStringError com padrão vazio (ex.: filtro 'a;;b'). Reimplementar com a mesma semântica e testes.
- [REVISÃO] Código morto esquecido: blocos {$IFDEF CUSTOMDRIVE} (desligado no compopt.inc) em cerca de 20 units (AddShareModule, Backup, Branch, ChkInSingle, ProjAdmin etc.) chamam RegReadString(HKCU, chave, valor, '') com 4 parâmetros sem importar JclRegistry. Não compilariam nem com a JCL atual: RegReadString tem 3 parâmetros e o equivalente com default é RegReadStringDef. Manter desligado ou remover.
- [REVISÃO] Na troca de JclDebug por JVCSTrace:
  - Há chamadas sem qualificador (ex.: JVCSIDEInterface.pas:445/453/458), então a troca precisa alterar também o uses, não só o prefixo 'JclDebug.'.
  - Os números reais na pasta jedivcsdll, sem ConverterBackup, são cerca de 190 TraceMsg e 19 TraceFmt; as cópias em jedivcs, jedivcsdiff e console se somam a isso.
  - JediVCSDLL.dpr (cerca das linhas 2542/2550) chama TraceMsg fora de {$IFDEF DEBUG}.
- MemCheck.pas (nas três pastas) chama JclDebug.MapOfAddr com AnsiString, mas a assinatura atual usa string e não compilaria. [REVISÃO] Observação: o compopt.inc define MEMCHECK via {$IFOPT D+}, portanto sempre que DEBUG está ligado, e define USE_JEDI_JCL. Mesmo assim não há efeito, porque nenhuma unit inclui MemCheck no uses (confirmado). Remover.
- JclOpenDialogFavorites está em {$ifdef JCLVER_2_UP}, que não é definido em lugar nenhum (confirmado). O ramo ativo usa FavOpenDialog (Components\favopendialog.pas). Remover o ifdef.
- Caminhos locais: sConfigFolder = PathAddSeparator(GetAppdataFolder)+'JEDI\JVCS\Config\\'; COMPARE\1 e \2 em %APPDATA%; backup e cache de line history em ProgramData\JEDI\JVCS. TPath.GetHomePath e TPath.GetPublicPath resolvem as mesmas pastas segundo a docwiki, mas vale testar para não perder as configurações do usuário.
- No Windows 10/11, o SeSystemtimePrivilege (Create.pas, SyncToServerTime) não está no token de um processo não elevado. O sincronismo de hora com o servidor falha sem elevação, independentemente da JCL.
- [REVISÃO] O RAD Studio 13 tem IDE de 64 bits (bin64), e um processo de 64 bits não carrega DLL de 32 bits. Se o usuário usar a IDE 64-bit, a JediVCSDLL tem de ser compilada para Win64, e com ela a JCL (pacotes Win64 para RS13 corrigidos em 17/09/2025) e a JVCL. Validar qual IDE será usada.
- A JVCL depende da JCL: retirar a JCL do código do cliente não a retira do ambiente de build enquanto JvGnugettext, JvExStdCtrls, JvCombobox, JvMruList etc. forem usadas (inclusive pelo Diff). O console não usa JVCL (confirmado) e é o único que pode ficar totalmente livre da JCL.
- Avisos e deprecações (não quebram o build): GetFileInformation(...).Time em Backup.pas:1096 (TSearchRec.Time está deprecado); o global ThousandSeparator em Std_ListView.pas:1169 e ProjAdmin.pas:10963; PChar passado a TraceMsg(string). As assinaturas array of Char de StrRemoveChars/StrReplaceChars aceitam os literais [ThousandSeparator] e ['.', ' '] usados.
- Algumas units importam JclStrings sem usar nenhuma rotina (confirmado: só aparece AnsiCrLf em comentários de histórico): CheckfBuild, ChkInSingle, ChkOutSingle, Options, ToDo e Syncronice. Create.pas importa JclSysInfo sem usá-la, mas usa TJclFileVersionInfo (JclFileUtils). São candidatos a limpeza.
- Instalação via install.bat da JCL exige dcc32, que a Professional tem. A máquina é Windows 11 ARM64, com o Delphi em emulação x64, o que ainda não foi validado. O GetIt é a via mais simples no RS13, mas para Delphi 11/12 o GetIt oferece versões mais antigas (RS12: 2023.11).

#### Units

| Unit | Onde está | Condição | Status D13 | Substituto | Notas |
|---|---|---|---|---|---|
| JclDebug | ausente (JCL externa: jcl\source\windows\JclDebug.pas) | Na maioria das units, {$IFDEF DEBUG}. DEBUG está LIGADO no compopt.inc e em todos os .dof, então na prática é sempre. Nos .dpr e em JVCSDebug, sempre. JVCSThreads: {$IFDEF JCL_DEBUG_DATA} (desligado). MemCheck: {$IFDEF USE_JEDI_JCL}, que fica ligado via MEMCHECK/{$IFOPT D+}, mas a unit não está em nenhum uses. JVCSIDEInterface.pas:721 (JclDebug.Trace): {$IFDEF INTERNAL_OLDOTA}, morto quando EXT_IDE_INTF está definido (JediVCSDLL.dof). ConfigStorage (12 chamadas de Trace): {$IFDEF USE_MEMINI}, desligado. Console TZHandling: {$ifdef WINDOWS}, nunca definido no Delphi. | `portar-codigo` | Unit local JVCSTrace com TraceMsg/TraceFmt sobre OutputDebugString (Winapi.Windows). Trocar tanto o uses (JclDebug → JVCSTrace) quanto o prefixo 'JclDebug.'. TJclDebugThread → TThread + TThread.NameThreadForDebugging. Stack trace (opcional) só com JCL_DEBUG_DATA. | Trocar por JVCSTrace local (uses e prefixo 'JclDebug.'); há ~190 TraceMsg e 19 TraceFmt só em jedivcsdll. [REVISÃO] JclDebug.Trace em JVCSIDEInterface.pas:721 é código morto (INTERNAL_OLDOTA). |
| ExceptDlg (template do diálogo de exceção da JCL) | ausente (gerado pelo repositório de objetos da JCL) | {$IFDEF JCL_DEBUG_DATA}: não está definido em nenhum .dof nem .inc (confirmado), portanto desligado | `remover` | Nenhum necessário. Se quiser relatório de exceção: Application.OnException próprio, ou madExcept/EurekaLog. | Código inativo (JCL_DEBUG_DATA nunca definido); pode ficar desligado ou ser removido. |
| JclFileUtils | ausente (JCL externa: jcl\source\common\JclFileUtils.pas) | sempre (exceto JVCSLineHistoryUnit: o uses é incondicional e as rotinas de XML ficam sob LINEINFOEX) | `funciona` | PathAddSeparator → IncludeTrailingPathDelimiter; PathRemoveSeparator → ExcludeTrailingPathDelimiter; PathCanonicalize → canonicalização textual local ou TPath.GetFullPath (só com caminho absoluto); BuildFileList → TDirectory.GetFiles + ExtractFileName (a JCL com faAnyFile também lista subpastas); FileCopy → TFile.Copy/CopyFile; IsDirectory → DirectoryExists; GetFileCreation → TFile.GetCreationTime; GetFileLastWrite → FileAge(Name, DateTime); GetSizeOfFile → Int64 via GetFileAttributesEx; GetFileInformation → FindFirst; FileGetOwnerName → GetNamedSecurityInfo + LookupAccountSid; TJclFileVersionInfo/VersionResourceAvailable → helper GetFileVersionInfo/VerQueryValue | Todas as rotinas existem no master. [REVISÃO] GetSizeOfFile do console alimenta ModuleOriginalSize/CompressedSize enviados ao servidor; PathCanonicalize da JCL é textual. |
| JclStrings | ausente (JCL externa: jcl\source\common\JclStrings.pas) | sempre | `portar-codigo` | Unit local JVCSStrUtils: StrToken: helper. StrTokenToStrings: helper baseado em StrToken (DelimitedText trata aspas e difere). StrToStrings: helper ou string.Split. StrMatches: reimplementar com '*'/'?' e tratamento de padrão vazio. StrReplace(S,a,b) → StringReplace(S,a,b,[]) (a JCL sem flags troca só a 1ª ocorrência). StrSame → SameText; StrRestOf → Copy(S,N,MaxInt). StrRemoveChars/StrReplaceChars → laço. EJclStringError → exceção própria. AnsiCrLf → sLineBreak. | AnsiCrLf não existe mais em JclStrings (quebra). [REVISÃO] StrMatches tem um só ponto de chamada (MatchWithFilter), central nos filtros de check-in; StrReplace sem flags troca só a 1ª ocorrência. |
| JclSysInfo | ausente (JCL externa: jcl\source\common\JclSysInfo.pas) | sempre | `funciona` | GetAppdataFolder → TPath.GetHomePath; GetCommonAppdataFolder → TPath.GetPublicPath; GetWindowsVersionString → TOSVersion.ToString; ExpandEnvironmentVar(var S) → wrapper de ExpandEnvironmentStrings | Mesmas assinaturas no master; as pastas devolvidas (sem barra final) precisam ser idênticas para não perder configurações e cache. |
| JclSecurity | ausente (JCL externa: jcl\source\windows\JclSecurity.pas) | sempre (as chamadas de SE_DEBUG ficam sob a opção do usuário OutputDebugStrActive) | `funciona` | Helper local EnablePrivilege com OpenProcessToken/LookupPrivilegeValue/AdjustTokenPrivileges (Winapi.Windows). Remover o pedido de SE_DEBUG. | Usa só EnableProcessPrivilege; SE_DEBUG altera o token da IDE sem necessidade e SeSystemtimePrivilege não existe em token não elevado. |
| JclWin32 | ausente (JCL externa: jcl\source\windows\JclWin32.pas) | sempre | `funciona` | Winapi.Windows (SE_DEBUG_NAME, SE_SYSTEMTIME_NAME, VER_PLATFORM_WIN32_NT); Win32Platform vem de SysUtils | Aparentemente só fornece constantes SE_*_NAME; remover e deixar o compilador apontar o resto. |
| JclRegistry | ausente (JCL externa: jcl\source\windows\JclRegistry.pas) | JVCSIDESettings: {$ifdef WINDOWS}, que o Delphi NÃO define (o jedi.inc só o mapeia para Oxygene), então hoje a unit fica fora e o uses vira ', JclFileUtils' (erro de sintaxe; edição Lazarus). Blocos RegReadString(HKCU,..,..,''): {$IFDEF CUSTOMDRIVE}, desligado. | `substituir` | System.Win.Registry.TRegistry (OpenKeyReadOnly/GetKeyNames/ReadString) | Hoje fica fora do build por {$ifdef WINDOWS} (erro de sintaxe no uses). A detecção de IDE é obsoleta; os blocos CUSTOMDRIVE com 4 parâmetros não compilariam. |
| JclSimpleXml | ausente (JCL externa: jcl\source\common\JclSimpleXml.pas) | JVCSLineHistoryPropertyStorage: sempre. JVCSLineHistoryUnit: {$IFDEF LINEINFOEX}, não definido em lugar nenhum (desligado). | `funciona` | Manter a JclSimpleXml. Se trocar: Xml.XMLDoc/TXMLDocument ou serialização manual, com saída que comece em '<' e leitura dos headers antigos. | Gera o header XML do Line History gravado no servidor; manter a JCL ou garantir saída começando com '<' e leitura dos headers antigos. |
| JclResources | ausente (JCL externa: jcl\source\common\JclResources.pas) | sempre | `funciona` | resourcestrings locais na própria unit + exceção própria no lugar de EJclStringError | Duas resourcestrings usadas no StrMatches local; troca trivial. |
| JclPCRE | ausente (JCL externa: jcl\source\common\JclPCRE.pas + pcre.pas) | sempre (só age quando sBugtrackerURL e sBugtrackerRegEx estão configurados) | `substituir` | System.RegularExpressions.TRegEx: M := TRegEx.Match(S, sBugtrackerRegEx); if M.Success then LastBugReference := M.Groups['bug'].Value. Envolver em try/except. | [REVISÃO] O padrão PCRE_LINKONREQUEST carrega DLL em runtime; TRegEx elimina isso e aceita (?i) e (?&lt;bug>...). Proteger Groups['bug'] com try/except. |
| JclOpenDialogFavorites | ausente (JCL externa: jcl\source\vcl\JclOpenDialogFavorites.pas, ainda existe) | {$ifdef JCLVER_2_UP}: não é definido em lugar nenhum (confirmado), então é código morto. O ramo ativo usa FavOpenDialog (Components\favopendialog.pas). | `remover` | Nenhum: remover o ifdef e tratar o FavOpenDialog na família própria (ou TFileOpenDialog nativo) | Código morto (JCLVER_2_UP nunca definido); o ramo ativo usa FavOpenDialog. |
| JclAnsiStrings (implícita: AnsiCrLf) | ausente (JCL externa: jcl\source\common\JclAnsiStrings.pas) | sempre (as units só importam JclStrings, por isso não compila) | `portar-codigo` | sLineBreak (System) | AnsiCrLf só existe em JclAnsiStrings; faltou trocar por sLineBreak em JediVCSDLL.dpr e VerSet.pas. |
| jedi.inc (include JEDI) | ausente (jcl\source\include\jedi\jedi.inc, submódulo project-jedi/jedi) | sempre | `atualizar-versao` | — | Necessário mesmo sem a JCL (BORLAND, DELPHI7_UP, UNICODE...). A versão atual define DELPHI37/DELPHI_FLORENCE e não define WINDOWS; fixar uma cópia na v2026. |
| JclBorlandTools | ausente (renomeada para JclIDEUtils na JCL 2.x) | não usada | `remover` | — | Só aparece em comentário. |

### 3.4 JVCL - não visuais e utilitários

**Família no levantamento:** JVCL - não visuais e utilitários

**Situação no Delphi 13.2:** `misto` · **Decisão:** `substituir-por-nativo` · **Esforço:** médio

**Pasta na v2026:**
- `src\jedivcs`: `JVCSDialogs.pas`, `JVCSMruList.pas`, `JVCSManageFavorites.pas`, `languagecodes.pas`, `JEDIVCSPluginMsgConst.inc`.
- `src\common`: `JVCSLanguage.pas`, `JVCSThreads.pas`.
- `src\comp\dxgettext` (nova): `gnugettext.pas`.

A JVCL fica só como dependência externa de transição (GitHub master d37), sem clone em `src\jvcl`.

**Nota de consolidação:** `JVCSDialogs.pas` da v2026 já é a cópia de `jedivcsdll`, com `DSAMessageDlg` ativo.

#### Resumo

Nenhuma unit Jv* está no repositório. A JVCL era externa (..\jvcl\run, ..\jvcl\common, ..\jvcl\resources nos .dof) e é usada pelo EXE, pela DLL e pelo Diff; o Console não usa a JVCL (confirmado). Na parte não visual, o cliente depende de JvGnugettext, JvDSADialogs, JvJVCLUtils, JvJCLUtils, JvMRUManager, JvMRUList, JvPluginManager/JvPlugin, JvSearchFiles e JvDialogs, além das bases JvComponent, JvComponentBase e JvExtComponent. Todas existem no JVCL master, que tem pacotes d37/d37_x64 para o Delphi 13 (d29 para o 12, d28 para o 11; último commit em 2026-05-29). Porém a "fase 1" (só atualizar a JVCL) NÃO é tão direta quanto o inventário dizia: na JVCL atual o JvDSADialogs exige um motor de controles dinâmicos registrado (JvDynControlEngineVCL), sem o qual há Assert/AV ao mostrar qualquer diálogo DSA; e os handlers do TJvPluginManager no ProjAdmin têm assinaturas divergentes (Cardinal x THandle e TBitmap x TJvBitmap), além de um {$I ..\stdplugin\\...} para uma pasta que não existe. Nada nesta família muda o formato das requisições ao servidor 2.5 Beta 3. A troca por código nativo dentro dos wrappers (JVCSDialogs, JVCSMruList, JVCSThreads, ProjectTreeDockWnd) continua recomendada; gettext (de preferência o gnugettext.pas do dxgettext) e o gerenciador de plugins (desativar) são as exceções.

#### Fonte recomendada

Fase 1 (compilar rápido): JVCL do GitHub project-jedi/jvcl, branch master (jvcl\packages\d37 e d37_x64 para Delphi 13, d29 para 12, d28 para 11; último commit 2026-05-29, "Adapt to JCL supporting the x64 IDE since Delphi 12.3"), instalada pelo instalador do GitHub junto com a JCL da mesma época (project-jedi/jcl, que também tem jcl\packages\d37). O GetIt lista JVCL 2025.10 e 2026.08 (os URLs de download contêm "13"), mas em 2025 houve falhas de instalação pelo GetIt e a própria Embarcadero indicou o GitHub para o Florence. Units por pacote (conferidas nos .dpk de d37): JvCore (JvGnugettext, JvJCLUtils, JvJVCLUtils, JvComponent, JvComponentBase, JvExtComponent), JvSystem (JvMRUManager, JvMRUList, JvSearchFiles), JvDlgs (JvDSADialogs, JvDialogs; exige JvCore, JvStdCtrls, JvSystem e JvCustom) e JvPluginSystem (JvPluginManager, JvPlugin). Se a fase 1 mantiver JvDSADialogs, acrescentar JvDynControlEngineVCL ao uses de JVCSDialogs. Fase 2 (alvo): gnugettext.pas standalone do dxgettext (SourceForge, svn trunk/dxgettext/sample/gnugettext.pas r196, 2026-08-19, autor twm) e languagecodes.pas (trunk/dxgettext/languages/languagecodes.pas). Não há confirmação explícita de compilação no Delphi 13 (o código usa CompilerVersion, sem teto de versão), então é preciso testar cedo. O restante vira código nativo RTL/VCL nos wrappers do próprio JVCS.

#### Alternativa nativa

Unit por unit, as alternativas nativas do Delphi 13.2 (todas também existem no 11 e no 12):

- JvDSADialogs: reimplementar DSAIdentsMessageDlg/GetState/SetState/Clear dentro de JVCSDialogs.pas. Há duas opções: (a) Vcl.Dialogs.CreateMessageDialog com um TCheckBox, que é o mesmo modelo do JvDSADialogs e aceita qualquer TMsgDlgButtons; ou (b) TTaskDialog com VerificationText e tfVerificationFlagChecked. No TTaskDialog, o caso [mbIgnore, mbCancel] (1 chamada) exige botão customizado com ModalResult=mrIgnore, porque não existe Ignore entre os CommonButtons. Regras a preservar: as chaves &lt;Filename>\\&lt;ID>\DontShow (bool) e LastResult (integer); GetState invertido ("not"); e, com DontShow=True, devolver DefaultResult sem mostrar o diálogo, porque o wrapper atual sobrescreve LastResult com DefaultResult antes de cada chamada. Vale a pena: elimina JvDlgs, JvDynControlEngine(+VCL), JvStdCtrls e JvCustom.
- JvJVCLUtils.Msg* (MsgOK/Info/Warn/Error/YesNo/YesNoCancel; ~52 chamadas em 11 units): funções de mesmo nome em JVCSDialogs.pas com MessageBox(Handle: HWND, ...). Vale a pena.
- AllocateHWndEx/DeallocateHWndEx: System.Classes.AllocateHWnd/DeallocateHWnd. Ninguém procura a classe 'JVCS_HWND' com FindWindow, então a troca é transparente. Vale a pena.
- JvJCLUtils.ItemHtDraw/ItemHtWidth: só tratam &lt;b>&lt;/b> (JVCSProjectTreeUnit.pas, linhas 709-717); trocar por uma rotina local de ~40 linhas com TCanvas.TextOut/TextWidth. Vale a pena.
- TJvRecentStrings: TJVCSMruList derivando de TStringList, com MaxSize (setter que corta o excesso), Mode/TRecentMode (rmInsert/rmAppend), Add e AddStrings override. A persistência já é própria (ConfigStorage). Vale a pena.
- TJvMruList (Diff): classe nativa com System.Win.Registry lendo e gravando o mesmo formato (HKCU\Software\JEDI\JEDIVCSDiff\MRU\Base e \CompareTo; valor MRUList + a..j). Vale a pena.
- TJvSearchFiles: busca recursiva com FindFirst/FindNext, parando no primeiro achado e pulando reparse points/junctions. Evitar TDirectory.GetFiles com soAllDirectories, que não pode ser interrompido e varreria o drive inteiro. Vale a pena.
- TJvColorDialog: Vcl.Dialogs.TColorDialog (TJvColorDialog descende dele; Ctl3D existe). Troca direta no .pas e no .dfm.
- JvComponent/JvComponentBase/JvExtComponent: somem quando os componentes que dependem delas forem trocados.
- JvGnugettext: não há nativo equivalente (a VCL Translation Support saiu do IDE no 12.0 e hoje vem do GetIt; usá-la exigiria refazer todo o fluxo). Manter gettext, de preferência o gnugettext.pas standalone.
- JvPluginManager: não há nativo; desativar por define ou remover.

#### Destino proposto pelo inventário (texto original)

src\common (wrappers nativos compartilhados por EXE/DLL/Diff: JVCSDialogs.pas, JVCSMruList.pas, JVCSLanguage.pas, languagecodes.pas, JVCSThreads.pas, JVCSManageFavorites.pas, JEDIVCSPluginMsgConst.inc se os plugins forem mantidos); src\comp\dxgettext (gnugettext.pas standalone); e, na fase 1 ou se a família visual mantiver a JVCL, src\jvcl (clone do GitHub project-jedi/jvcl, no layout dos .dof: ..\jvcl\run, ..\jvcl\common, ..\jvcl\resources). Não copiar Components\strutilsd5.pas, Components\compilers.inc nem Components\virtualtrees.pas.

#### Riscos

- A cópia de JVCSDialogs.pas na pasta jedivcs (port Lazarus) tem 'Result := DSAMessageDlg(...)' comentado SEM {$IFDEF} (TODO de F. Libaud): DSAIdentsMessageDlg devolve lixo no EXE. Usar a versão de jedivcsdll (confirmado por diff).
- JvPluginManager: o handler uilPluginManager1AfterLoad declara 'const ALibHandle: Cardinal', mas TJvAfterLoadEvent usa THandle. O designer deve reclamar de 'incompatible parameter list' ao abrir o DFM. SendMessage está marcado como deprecated (usar BroadcastMessage).
- Plugins: TJvPlugIn é um TDataModule trocado entre módulos. Plugins antigos (Delphi 7/2007, AnsiString) são binariamente incompatíveis. Sob IDEDLL o modo é plgPackage (BPL) com a DLL sem runtime packages, o que é frágil (checagens 'is' entre módulos falham). Não há nenhum projeto de plugin no repositório.
- O gettext faz hook em System.LoadResString (AddDomainForResourceString). Na DLL do IDE isso só é seguro porque a DLL é linkada estaticamente; com runtime packages o hook atingiria o RTL do próprio IDE.
- Não misturar JvGnugettext e gnugettext.pas no mesmo binário (hooks duplicados e duas DefaultInstance). A própria JVCL só usa JvGnugettext sob USE_DXGETTEXT, desligado em jvcl.inc, então manter a JVCL visual não traz o JvGnugettext junto.
- A cópia do gettext na JVCL é antiga (rev. 220, de 2010, vinda do berlios; os defines param no COMPILER17_UP, sem teto de versão). O upstream do dxgettext no SourceForge segue mantido (r196, 2026-08-19).
- Não há nenhum .po/.mo no repositório. Sem locale\\&lt;lang>\LC_MESSAGES\jedivcs.mo o menu 'Languages' fica oculto. Uma tradução pt_BR precisa ser criada do zero (dxgettext/ggdxgettext + Poedit).
- TJvMruList (Diff) usa funções não documentadas da comctl32 por ordinal (151-169, 400-403), com WantUnicode=False (conversão ANSI). A substituição deve ler o mesmo formato de registro para não perder o histórico.
- A substituição do JvDSADialogs precisa preservar a semântica invertida ('not GetDSAState') e as chaves DontShow/LastResult (FixKey troca 'DSA_State' por 'DontShow'), senão as preferências 'não mostrar novamente' se perdem.
- Imports sem uso (o Delphi não avisa): JvJVCLUtils em AddNewCompareTool, AddNewMilestone, AddShareModule, BugWindow e CheckfBuild; JvSearchFiles em SelectFolder (confirmado). Remover ao portar.
- A instalação da JVCL/JCL via GetIt falhou em 2025, e para o Florence a Embarcadero indicou o GitHub. Usar o instalador do GitHub, com a JCL da mesma época no library path.
- JVCSManageFavorites.pas só existe na pasta jedivcs (usada sob {$IFNDEF IDEDLL}) e depende de TJvRecentStrings/rmAppend. Precisa entrar na nova estrutura.
- [REVISÃO] Nova e crítica para a fase 1: na JVCL atual, DSAMessageDlg usa DefaultDynControlEngine, que faz Assert('JvDynControlEngine: DefaultDynControlEngine not defined') se nenhuma unit registrar um motor. Só JvDynControlEngineVCL/JVCL registram um na initialization. Nenhuma unit do JVCS nem das units JVCL usadas diretamente (conferidas ~40) o inclui. Com {$C+} (DEBUG em compopt.inc) dá EAssertionFailed; sem asserts, AV ao exibir qualquer diálogo DSA. Correção: incluir JvDynControlEngineVCL no uses de JVCSDialogs ou trocar por código nativo.
- [REVISÃO] Nova: TNewCommandEvent da JVCL atual declara 'ABitmap: TJvBitmap' (TJvBitmap = class(TBitmap), issue 4859), mas TVCSProjAdmin.uilPluginManager1NewCommand usa 'ABitmap: TBitmap'. O comentário da própria JVCL avisa que o IDE reclama ao abrir o form. Ajustar o handler junto com ALibHandle: THandle.
- [REVISÃO] Nova: ProjAdmin.pas (linha 315) faz {$I ..\stdplugin\jedivcspluginmsgconst.inc} de forma INCONDICIONAL, e a pasta stdplugin não existe (o .inc está em jedivcs\JEDIVCSPluginMsgConst.inc). As 12 chamadas SendMessage(pimsg*) dependem dessas constantes. Corrigir o caminho mesmo que os plugins sejam desativados, ou envolver include e chamadas no mesmo define.
- [REVISÃO] Corrigido o risco de Win64 do JvPluginManager: o ALibHandle do handler não é usado (só há log), então o efeito em runtime é nulo. O problema real é a própria JVCL: TJvPluginManager.LoadPlugin/UnloadLibrary guardam o HMODULE em 'LibHandle: Integer', o que trunca o endereço base de DLL/BPL em Win64. Relevante só se os plugins forem mantidos numa DLL 64 bits para o IDE x64.
- [REVISÃO] Corrigido: o risco de 'truncamento de HWND' em MsgOK etc. (Handle: Integer) foi superestimado. HWNDs só usam 32 bits significativos mesmo em Win64 (garantia de interoperabilidade do Windows), então funciona. A troca por wrappers com HWND é por tipagem e limpeza, não por bug.
- [REVISÃO] Corrigido: TJvMruList não tem risco específico de ARM64. A emulação x86/x64 do Windows 11 ARM64 não muda o comportamento ANSI/Unicode. O risco real é a API não documentada e a conversão ANSI (WantUnicode=False) de caracteres fora da code page.
- [REVISÃO] Corrigido: JvGnugetTextD5/strutilsd5 NÃO é 'só Delphi 5'. Components\compilers.inc só reconhece até VER200 (Delphi 2009) e só dentro de {$ifdef Win32}. No Delphi 11/12/13, DELPHI_6_UP fica indefinido, e o Components\virtualtrees.pas cairia no ramo StrUtilsD5, que usa JvGnugetText + JvGnugetTextD5 (inexistente), quebrando a compilação. O build original usava ..\comp\soft-gems\virtualtreeview\source (fora do repositório). Não reaproveitar Components\virtualtrees.pas/compilers.inc/strutilsd5.pas.
- [REVISÃO] Corrigidas as contagens de DSA: DLL = 54 DSAIdentsMessageDlg, 40 GetState, 10 SetState e 1 Clear, em 16 units + JediVCSDLL.dpr; EXE = 48/40/10/0 em 16 units + Jedivcs.dpr. O inventário dizia 50/42/13/5 em ~27-28 units (esse número é o de importadores de JVCSDialogs, ~29, que também usam Info/Error/WarnMessageBox).
- [REVISÃO] Semântica escondida a preservar: antes de cada exibição, DSAIdentsMessageDlg chama SetDSAState(0, GetDSAState(0), DefaultResult). Com 'não mostrar' ligado, LastResult é sobrescrito, e o diálogo suprimido devolve o DefaultResult do chamador (idOk/idYes...), NÃO a última escolha do usuário. A reimplementação nativa deve fazer o mesmo.
- [REVISÃO] TTaskDialog não tem botão comum Ignore. A chamada com [mbIgnore, mbCancel] exige botão customizado. Alternativa mais fiel: CreateMessageDialog + TCheckBox, o mesmo modelo do JvDSADialogs, que aceita qualquer TMsgDlgButtons e respeita VCL Styles.
- [REVISÃO] JVCSDialogs.pas altera uma constante tipada (Delete(DontShowMsgText, ...)) e só compila porque compopt.inc liga {$J+}, enquanto o padrão do Delphi 13 é J-. Manter {$I compopt.inc} ou, na versão nativa, trocar por variável/resourcestring.
- [REVISÃO] gnugettext.pas upstream: GetCurrentLanguage passou a ser 'deprecated' (usar GetCurrentLocaleName), o que gera warning W1000 em JVCSLanguage.pas. TP_GlobalIgnoreClass levanta EGGProgrammingError se a mesma classe for registrada duas vezes; hoje é chamado uma vez por processo (InitAndOpenConfigStorage / JediVCSInternalInit), então está OK. Não há confirmação pública de suporte ao Delphi 13: testar a compilação logo no início.
- [REVISÃO] Alias de unit 'JvGnugettext=gnugettext': se a JVCL continuar no Library Path (família visual), o JvGnugettext.dcu dela fica visível, e a precedência alias x unit real deve ser verificada. A alternativa segura é trocar mecanicamente as ~180 cláusulas uses, todas dentro de {$IFDEF LANGUAGE}.
- [REVISÃO] O Diff não chama UseLanguage (só TextDomain, AddDomainForResourceString, TranslateComponent e menu). Com um .mo pt_BR, ele trocaria de idioma pelo locale do Windows, sem a preferência gravada que EXE e DLL usam (chave Options\Language).
- [REVISÃO] Protocolo (confirmado): a família não altera requisições ao servidor 2.5 Beta 3. As únicas resourcestrings da camada cliente-servidor (JVCSClientObjBase) são mensagens de erro. Cuidado futuro: ao criar a tradução pt_BR, TranslateComponent traduz todas as strings de DFM (só TListColumn é ignorado). Revisar se algum texto de DFM ou resourcestring vai como dado ao servidor (comentários, descrições padrão) ou é comparado no código; isso muda dados, não o formato do protocolo.
- [REVISÃO] Baixo risco, testar no ARM64: os hooks de LoadResString do gettext aplicam um JMP rel32 via VirtualProtect, sem FlushInstructionCache, e rodam sob emulação x86/x64 no Windows 11 ARM64. Em tese a emulação trata código automodificável, mas convém validar a tradução de resourcestrings nesse ambiente.
- [REVISÃO] Confirmados na web e no código: pacotes d37/d37_x64 (JVCL) e d37 (JCL); último commit da JVCL em 2026-05-29; GetIt com JVCL 2025.10/2026.08; dxgettext r196 em 2026-08-19; 83/84/7 chamadas TranslateComponent (EXE/DLL/Diff); JvGnugettext 100% sob LANGUAGE (JVCSLanguage incondicional, mas incluída sob LANGUAGE nos .dpr); o MsgOK do About só sob BETA (desligado em compopt.inc); InitWakeMainThreadHandler só no JediVCSDLL.dpr.

#### Units

| Unit | Onde está | Condição | Status D13 | Substituto | Notas |
|---|---|---|---|---|---|
| JvGnugettext | ausente (externo: JVCL jvcl\run\JvGnugettext.pas, pacote JvCore) | {$IFDEF LANGUAGE} em todos os usos (JVCSLanguage usa sem condição, mas só é incluída sob LANGUAGE nos .dpr). LANGUAGE está ligado nos .dof de Jedivcs, JediVCSDLL e JEDIVCSDiff; o Console não usa. | `atualizar-versao` | gnugettext.pas standalone do dxgettext (SourceForge r196, 2026-08-19), mesma API; de preferência trocando o nome no uses (alias de unit só depois de testar a precedência com a JVCL no path); sem equivalente nativo adequado | APIs usadas: TranslateComponent, UseLanguage, TextDomain, AddDomainForResourceString etc.; não há .po/.mo no repositório e o Diff não chama UseLanguage. Alternativa radical: desligar LANGUAGE. |
| JVCSLanguage (unit do próprio JVCS) | Jedi VCS Client\2.5\jedivcs\JVCSLanguage.pas (cópias idênticas, mesmo MD5, em jedivcsdll e jedivcsdiff; os .dpr referenciam '..\common\JVCSLanguage.pas') | {$IFDEF LANGUAGE} nos .dpr e nos usuários | `funciona` | — | Depende só da API do gettext e de languagecodes; GetCurrentLanguage gera warning de deprecated no upstream. |
| languagecodes | Jedi VCS Client\2.5\jedivcs\languagecodes.pas (cópias idênticas em jedivcsdll e jedivcsdiff) | {$IFDEF LANGUAGE} (indireto) | `funciona` | manter (Pascal puro); opcional: nomes via GetLocaleInfoEx/TLanguages da RTL | Pascal puro gerado pelo dxgettext; manter. |
| JvGnugetTextD5 (+ JvGnugetText, via Components\strutilsd5.pas) | ausente (não existe mais na JVCL atual); usuário: Components\strutilsd5.pas | ramo {$ELSE} de DELPHI_6_UP em Components\virtualtrees.pas. ATENÇÃO: Components\compilers.inc só define DELPHI_6_UP até VER200 (Delphi 2009) e só sob Win32, então no Delphi 11/12/13 esse ramo FICARIA ATIVO se esses arquivos fossem reaproveitados | `remover` | System.StrUtils / UTF8ToString da RTL; na prática, usar o VirtualTreeView atual (família VirtualTrees) e descartar Components\virtualtrees.pas, compilers.inc e strutilsd5.pas | Não reaproveitar Components\virtualtrees.pas/compilers.inc/strutilsd5.pas (o ramo legado ficaria ativo no D11-13). |
| JvDSADialogs | ausente (externo: JVCL run, pacote JvDlgs, que exige JvCore, JvStdCtrls, JvSystem e JvCustom; usa JvDynControlEngine e JvAppStorage) | sempre (EXE e DLL); não usado no Diff nem no Console | `atualizar-versao` | JVCSDialogs.pas nativo: CreateMessageDialog + TCheckBox (fiel, aceita qualquer TMsgDlgButtons) ou TTaskDialog (VerificationText + tfVerificationFlagChecked; Ignore como botão customizado), mantendo a API e as chaves DontShow/LastResult | Semântica a preservar: chaves DontShow/LastResult, GetState invertido e diálogo suprimido devolvendo DefaultResult. A cópia jedivcs tinha DSAMessageDlg comentado (a v2026 usa a de jedivcsdll). |
| JvDynControlEngine / JvDynControlEngineVCL (transitivas, esquecidas no inventário) | ausente (externo: JVCL run; JvDynControlEngine vem no uses de JvDSADialogs; JvDynControlEngineVCL NÃO é usada por ninguém no cliente) | só se JvDSADialogs for mantido (fase 1) | `portar-codigo` | incluir JvDynControlEngineVCL no uses de JVCSDialogs.pas (fase 1) ou eliminar junto com JvDSADialogs (fase 2) | [REVISÃO] Na JVCL atual, sem JvDynControlEngineVCL linkada, qualquer diálogo DSA dá Assert/AV; incluir no uses de JVCSDialogs na transição. |
| JvJVCLUtils | ausente (externo: JVCL run, pacote JvCore) | sempre (EXE e DLL); MsgOK do About só com BETA; o handler de JVCSThreads só é instanciado na DLL | `atualizar-versao` | wrappers MsgOK/MsgInfo/MsgWarn/MsgError/MsgYesNo/MsgYesNoCancel(Handle: HWND; ...) em JVCSDialogs.pas com MessageBox; System.Classes.AllocateHWnd/DeallocateHWnd | ~52 chamadas Msg* em 11 units mais AllocateHWndEx em JVCSThreads; trocar por wrappers com MessageBox e AllocateHWnd. Remover os 5 imports sem uso. |
| JvJCLUtils | ausente (externo: JVCL run, pacote JvCore) | sempre na unit; ProjectTreeDockWnd só é usado no EXE ({$IFNDEF IDEDLL} em ProjAdmin), embora a unit também exista em jedivcsdll | `atualizar-versao` | rotina local que separa o texto em &lt;b>/&lt;/b> e desenha com TCanvas.TextOut/TextWidth (~40 linhas) | ItemHtDraw/ItemHtWidth só tratam &lt;b>&lt;/b>; rotina local de ~40 linhas. |
| JvMRUManager | ausente (externo: JVCL run, pacote JvSystem) | sempre (JVCSMruList); JVCSManageFavorites e o uses de ProjAdmin só no EXE ({$IFNDEF IDEDLL}) | `atualizar-versao` | TJVCSMruList derivando de TStringList, com MaxSize (setter que corta o excesso), Mode/TRecentMode próprios, Add com rmInsert/rmAppend, DeleteExceed e AddStrings | TJVCSMruList pode derivar de TStringList (MaxSize, Mode, Add/AddStrings); a persistência já é própria. |
| JvMRUList | ausente (externo: JVCL run, pacote JvSystem) | sempre (somente JEDIVCSDiff) | `atualizar-versao` | classe nativa com System.Win.Registry lendo e gravando o mesmo formato (valor MRUList + a..j em HKCU\Software\JEDI\JEDIVCSDiff\MRU\\...), ou TJVCSMruList/ConfigStorage com migração | MRU do Diff via ordinais não documentados da comctl32 (ANSI); o substituto deve ler o mesmo formato de registro. |
| JvPluginManager (+ JvPlugin transitivo) | ausente (externo: JVCL run, pacote JvPluginSystem); constantes em Jedi VCS Client\2.5\jedivcs\JEDIVCSPluginMsgConst.inc, incluídas sem condição em ProjAdmin.pas como {$I ..\stdplugin\jedivcspluginmsgconst.inc} (caminho inexistente) | sempre (EXE e DLL); o modo depende de {$IFDEF IDEDLL} | `portar-codigo` | sem nativo: desativar por define (ex.: {$IFDEF JVCS_PLUGINS}, desligado) envolvendo uses, componente, eventos, include e as 12 chamadas; ou remover. Só manter se o usuário tiver plugins recompiláveis. | Desativar por define (handlers com Cardinal/TBitmap divergem da JVCL atual e o {$I ..\stdplugin\\...} aponta para pasta inexistente). Plugins antigos não funcionam com o cliente D13. |
| JvSearchFiles | ausente (externo: JVCL run, pacote JvSystem) | sempre (EXE e DLL) | `atualizar-versao` | busca recursiva com FindFirst/FindNext, parando no primeiro achado e pulando reparse points; evitar TDirectory.GetFiles(soAllDirectories), que não pode ser interrompido | Só para localizar o servidor local (jvcssrv.exe); busca recursiva interrompível com FindFirst/FindNext. |
| JvDialogs | ausente (externo: JVCL run, pacote JvDlgs) | sempre (EXE e DLL) | `atualizar-versao` | Vcl.Dialogs.TColorDialog (troca direta de classe no .pas e no .dfm) | TJvColorDialog descende de TColorDialog; troca direta no .pas e no .dfm. |
| JvComponent | ausente (externo: JVCL run, pacote JvCore) | sempre | `atualizar-versao` | nenhum; some ao trocar os componentes Jv | Ancestral adicionada pelo IDE; some com a troca dos componentes Jv. |
| JvComponentBase | ausente (externo: JVCL run, pacote JvCore) | sempre | `atualizar-versao` | nenhum; some ao trocar TJvSearchFiles, TJvPluginManager e TJvMruList | Some ao trocar TJvSearchFiles, TJvPluginManager e TJvMruList. |
| JvExtComponent | ausente (externo: JVCL run, pacote JvCore) | sempre | `atualizar-versao` | nenhum; some se TJvGradient (família visual) for trocado, ex.: por TPaintBox + Vcl.GraphUtil.GradientFillCanvas | Some se TJvGradient for trocado (família visual). |

### 3.5 JVCL - controles visuais

**Família no levantamento:** JVCL - controles visuais

**Situação no Delphi 13.2:** `atualizar-versao` · **Decisão:** `substituir-por-nativo` · **Esforço:** médio

**Pasta na v2026:** não precisa de pasta de componente. Os forms convertidos ficam em `src\jedivcs` (base única EXE + DLL) e `src\jedivcsdiff`. Na transição, a JVCL/JCL é dependência externa (GitHub/JEDI Installer).

**Notas de consolidação:**
- **Wrapper do `compopt.inc` (risco do "wrapper `{$ifdef DELPHI}`"):** não se aplica à v2026. `src\jedivcs\compopt.inc` vem de `ConverterBackup` (pré-Lazarus, igual ao de `jedivcsdll`), e o crítico (C3) confirmou que o `jedi.inc` define `DELPHI`.
- **Defines por projeto:** como EXE e DLL compartilham o mesmo `compopt.inc`, onde `EXT_IDE_INTF` vem comentado, `IDEDLL;EXT_IDE_INTF` têm de ir no `.dproj` da DLL.

#### Resumo

O código do JVCL não está no repositório: não há nenhum Jv*.pas, nem pasta jvcl/jcl, nem jedi.inc. O cliente dependia de um JVCL 3 externo. O JVCL atual do GitHub (master) já suporta o RAD Studio 13: o PR #203 foi aceito em 2025, os pacotes estão em d37/d37_x64 com LIBSUFFIX 370 e o último commit é de 2026-05-29. Todas as units visuais usadas existem lá, em JvStdCtrls, JvControls, JvCore, JvHMI, JvMM e JvWizards. A família aparece em 47 DFMs do EXE/DLL (46 no EXE mais o VerSet, que só existe na DLL) e em 3 DFMs próprios do Diff, com cerca de 128 componentes; uns 70% deles são TJvComboBox, TJvMemo, TJvSpinEdit, TJvEdit, TJvFilenameEdit e TJvColorComboBox, todos com equivalente nativo direto. Recomendo trocar a família por controles nativos da VCL, que existem do Delphi 11 ao 13. A troca não altera o protocolo, mas é preciso preservar a ordem dos itens dos TJvImageComboBox, cujo ItemIndex vai ao servidor como direito ou severidade, e a semântica inteira dos spins enviados por WriteFields. Trocar só os visuais não elimina o JVCL/JCL: continuam JvGnugettext, JvDSADialogs, JvMRUManager/JvMRUList, JvSearchFiles, JvPluginManager, JvDialogs e JvJVCLUtils, além do jedi.inc, incluído em 141 units da DLL.

#### Fonte recomendada

O destino final são os controles nativos da VCL do Delphi 13.2, nas units Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.CheckLst, Vcl.Samples.Spin ou Vcl.NumberBox, Vcl.WinXPanels e Vcl.GraphUtil. Todos também existem no Delphi 11 e no 12. Para compilar antes das trocas (transição), usar JVCL e JCL do GitHub, branch master: github.com/project-jedi/jvcl tem os pacotes d37/d37_x64 com LIBSUFFIX '370'; o PR #203 "Add support for RAD Studio 13" foi aceito em 2025-07-31 e o último commit é de 2026-05-29. Em github.com/project-jedi/jcl o pacote d37 existe e o último commit é de 2026-09-21. O jedi.inc do repositório project-jedi/jedi já trata VER370, então vale para o Delphi 13.x, inclusive o 13.2, que usa o mesmo compilador 37.0. Instalar primeiro o JCL e depois o JVCL, pelo jvcl\install.bat (JEDI Installer). O GetIt mostra "JEDI Visual Component Library 2025.10" e "2026.08", com URL de download contendo "13", mas há relatos de erro F2613 por library path depois de instalar pelo GetIt. Por isso prefiro o GitHub.

#### Alternativa nativa

Vale a pena trocar. Quase tudo é troca de classe no DFM e no .pas, mais a remoção das propriedades exclusivas do JVCL.

- TJvComboBox: TComboBox, que já tem AutoComplete. Remover DotNetHighlighting do DiffMain.dfm.
- TJvMemo: TMemo. Remover MaxLines, HideCaret, ClipboardCommands e AutoSize.
- TJvSpinEdit: TSpinEdit (Vcl.Samples.Spin, Integer); trocar .AsInteger por .Value e converter no DFM os Min/Max/Value gravados como float. Se preferir TNumberBox (Mode=nbmInteger), usar ValueInt, porque Value é Double.
- TJvEdit: TEdit com PasswordChar. Remover Modified, ProtectPassword e ClipboardCommands do DFM.
- TJvFilenameEdit: TButtonedEdit (ou TEdit com botão) e um TOpenDialog. É preciso implementar o diálogo, porque os OnButtonClick atuais só configuram DialogTitle, DialogOptions e Filter e dependem do diálogo embutido do JVCL. Reproduzir também o AddQuotes=True padrão nos 4 campos do Options.
- TJvColorComboBox: TColorBox com Style [cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor, cbPrettyNames]; trocar .ColorValue por .Selected. O cbSystemColors corresponde ao coSysColors do DFM.
- TJvTextListBox e TJvListBox: TListBox (ScrollWidth para a rolagem horizontal).
- TJvSplitter e TJvNetscapeSplitter: TSplitter.
- TJvToolBar: TToolBar, que já tem Menu, EdgeInner e EdgeOuter nativos.
- TJvTreeView: TTreeView (StateImages é nativo; o LineColor sai).
- TJvCheckTreeView: TTreeView com CheckBoxes=True e TTreeNode.Checked (Delphi 11+). O CheckBox[Node] só recebe True, então não é preciso usar CheckState.
- TJvImageComboBox: TComboBoxEx com Images e ItemsEx, mantendo a ordem dos itens.
- TJvxCheckListBox: TCheckListBox.
- TJvxSlider: TTrackBar.
- TJvLED: TShape (stCircle) com Brush.Color.
- TJvArrowButton: TSpeedButton com PopupMenu.Popup, que mantém o controle gráfico sem foco, ou TButton com Style=bsSplitButton e DropDownMenu.
- TJvOfficeColorButton: TColorBox com cbIncludeNone e cbCustomColor, ou um botão com TColorDialog.
- TJvGradient: TPaintBox com GradientFillCanvas (Vcl.GraphUtil).
- TJvRichEdit: TRichEdit com EM_AUTOURLDETECT e tratamento de EN_LINK, ou TMemo com TLinkLabel.
- TJvDriveCombo: TComboBox preenchido com GetLogicalDriveStrings e GetDriveType=DRIVE_FIXED. O TDriveComboBox não filtra por tipo de disco.
- TJvWizard: TCardPanel. Só é necessário se BRANCHING for ligado.

Ganhos: sem pacotes JVCL de UI, melhor suporte a High-DPI e VCL Styles, e o mesmo código compila do Delphi 11 ao 13.

#### Destino proposto pelo inventário (texto original)

Esta família não precisa de pasta src\comp. Os forms convertidos para controles nativos ficam em v2026\src\jedivcs (base única para EXE e DLL, com IDEDLL) e v2026\src\jedivcsdiff. Se o JVCL/JCL for mantido na transição, tratar como dependência externa instalada pelo GitHub/JEDI Installer (ou clone em v2026\src\jvcl e v2026\src\jcl, espelhando o SearchPath antigo do Jedivcs.dof), sem copiar para src\comp. O jedi.inc precisa ficar acessível no search path enquanto as units o incluírem.

#### Riscos

- O JVCL não está no repositório. Sem a troca, qualquer build exige instalar o JVCL atual (d37) e o JCL. O JVCL 3 CVS de 2004-2012 não compila no Delphi 13.
- Trocar só os visuais NÃO remove a dependência de JVCL/JCL. Continuam: JvGnugettext (LANGUAGE ligado nos .dof do EXE, da DLL e do Diff), JvDSADialogs, JvMRUManager (TJVCSMruList herda de TJvRecentStrings), JvMRUList (Diff), JvSearchFiles, JvPluginManager, JvDialogs (TJvColorDialog), JvJVCLUtils (AllocateHWndEx em JVCSThreads) e JvJCLUtils. Essas famílias precisam de análise própria.
- Os DFMs gravam propriedades exclusivas do JVCL, que precisam ser removidas ao trocar a classe, senão aparece 'Property does not exist' em runtime. TJvSpinEdit grava MaxValue/MinValue/Value como float, que o TSpinEdit inteiro não lê.
- Herança de forms: JVCSBaseAboutDialog (TJvRichEdit Memo3 com OnURLClick) é a base do About (cliente) e do DiffAbout (Diff). O DiffAbout.dfm declara 'inherited Memo3: TMemo' e só zera Lines. Funciona em runtime, porque a classe de um componente herdado só é resolvida via tabela de campos e TMemo existe no form, mas convém corrigir junto.
- O código está triplicado: jedivcs (com edições FPC/Lazarus), jedivcsdll e cópias em jedivcsdiff (ListView, JVCSBaseAboutDialog, ConfigStorage, JVCSForms). Fazer as trocas uma única vez na base unificada em v2026.
- TJvArrowButton para TButton bsSplitButton: o visual muda e o TButton recebe foco e TabOrder. O Glyph trocado em runtime (spbtnDiff3To5.Glyph via GetToolImageList.GetBitmap) precisa virar Images/ImageIndex. Com TSpeedButton e PopupMenu o comportamento fica mais próximo do original.
- JvWizard e JvWizardRouteMapSteps só são compilados com {$IFDEF BRANCHING}, que não é definido em nenhum .dof, .inc ou .dpr. Se branching for ligado, reescrever com TCardPanel ou instalar o JvWizards d37, e testar contra o suporte a branches do servidor 2.5 Beta 3.
- Persistência local: as cores são TColor inteiro, os spins são inteiros e os MRU passam pelo TJVCSMruList (não visual). Continua compatível.
- [REVISÃO] Status na web: confirmado. O JVCL master tem d37/d37_x64 (LIBSUFFIX '370'), com JvStdCtrls, JvControls, JvCore, JvHMI (JvLED), JvMM (JvGradient) e JvWizards. O PR #203 'Add support for RAD Studio 13' foi aceito; a issue #224 (2026-10-06) diz que compila com dcc32/dcc64 no Delphi 13. O JCL tem d37 e commits até 2026-09-21, e o jedi.inc trata VER370. Nenhum commit cita o 13.2 explicitamente; risco baixo, porque o 13.2 mantém o compilador 37.0.
- [REVISÃO] Units esquecidas, todas resíduo do IDE: JvComponent (10 units: AssignLabels, Backup, ChkInSingle, ChkOutSingle, JVCSCreateBranchDialog, JVCSDebugView, Options, ProjAdmin, SimpleReport, Syncronice), JvComponentBase (Options, ProjAdmin, DiffMain) e JvExtComponent (JVCSLineHistorySettingsDialog). Foram incluídas no inventário. JvComponentBase continua necessária enquanto existirem TJvSearchFiles, TJvPluginManager e TJvMruList.
- [REVISÃO] jedi.inc ({$I jedi.inc}) é incluído em 141 units da DLL, 137 do EXE e 24 do Diff, e não está no repositório: vem do JCL/JVCL. Mesmo eliminando o JVCL visual, é preciso disponibilizar o jedi.inc atual (project-jedi/jedi, com suporte a VER370) ou substituir os testes DELPHIxx_UP.
- [REVISÃO] Corrigida a afirmação de que o TJvSpinEdit foi adotado 'para compatibilidade com o Delphi Personal'. Não há evidência disso: o define DelphiPersonalEdition só afeta Components\RFormat.pas, e o histórico diz apenas 'Replaced TSpinEdit by TJvSpinEdit' (FBouwmans, 2003-02-24).
- [REVISÃO] TJvFilenameEdit: o inventário dizia que o OnButtonClick do Options 'já tem código próprio', mas os 4 handlers só configuram DialogTitle, DialogOptions e Filter e dependem do diálogo embutido do JVCL. O substituto precisa abrir o TOpenDialog e preencher o Text. AddQuotes fica no padrão True nesses 4 campos, então caminhos com espaço são gravados entre aspas; reproduzir isso ou ajustar quem lança o editor. Bug original: edBMPButtonClick configura edRWS, não edBMP.
- [REVISÃO] TJvCheckTreeView: o risco estava superestimado. CheckBox[Node] só recebe True (Syncronice.pas linhas 691 e 714), então nenhum nó esconde a caixa e não é preciso usar CheckState/ncsNone. A troca é direta para Node.Checked, com CheckBoxes=True. CascadeOptions=[] e a cascata é manual (tv_Project_List_CheckBranch). Remover CheckBoxOptions.* e LineColor.
- [REVISÃO] TJvColorComboBox: os 4 combos do Options.dfm têm Options=[coText, coSysColors], então o TColorBox precisa de cbSystemColors (o padrão de ModuleListColor_New é clWindowText). Também saem do DFM Options, ColorValue, ColorDialogText, NewColorText, ColorNameMap e DroppedDownWidth. Os Items.Assign entre combos (Options.pas:536-538, DiffHLProp.pas:123) ficam redundantes com o TColorBox e podem ser removidos.
- [REVISÃO] Propriedades de DFM que faltavam na lista de remoção: TJvEdit 'Modified = False' (4x; no TEdit, Modified é public, não published); TJvEdit ClipboardCommands (Create.dfm); TJvComboBox DotNetHighlighting (DiffMain.dfm, 2x); TJvArrowButton FillFont.*; TJvNetscapeSplitter ButtonCursor/Maximized/Minimized; TJvDriveCombo DriveTypes/Offset; TJvImageComboBox ButtonStyle/DroppedWidth/ImageHeight/ImageWidth e Items (Brush/Indent); TJvRichEdit AutoSize; TJvFilenameEdit AddQuotes/DialogOptions/Filter/OnButtonClick.
- [REVISÃO] JVCSDebugView: o TJvLED desse form é código morto. A unit só entra com {$IFDEF DEBUG} no dpr, mas a chamada CreateClientDebugView está comentada no Jedivcs.dpr e não existe na DLL. Dá para tirar a unit do dpr em vez de portar.
- [REVISÃO] O jedivcs\compopt.inc (cópia do port Lazarus) está inteiro dentro de {$ifdef DELPHI} ... {$ENDIF ~DELPHI}, e o Delphi não predefine esse símbolo; o jedivcsdll\compopt.inc não tem o wrapper. Se a base unificada partir da pasta jedivcs, REPORTDLL, BLOWFISH, MIDWARE, DEBUG etc. deixam de ser definidos pelo .inc. O DEBUG, que controla o JVCSDebugView, vem dos .dof. Isso é transversal e não exclusivo desta família.
- [REVISÃO] Protocolo: o ItemIndex dos TJvImageComboBox é dado enviado ao servidor. icbRight.ItemIndex vira o nível de direito do usuário no projeto (ProjectRights.pas:454-461) e icbLevel.ItemIndex vira a severidade do bug (MaintainBugs.pas:414, 491-494). Ao migrar para TComboBoxEx, manter exatamente a ordem dos itens Minor..Fatal e dos níveis de direito; Items[I].ImageIndex vira ItemsEx[I].ImageIndex.
- [REVISÃO] Protocolo: os spins vão direto para AppSrvClient1.Request.WriteFields, em ServerOptions.pas:302-303 (speConnectTO.Value e speLoginTO.Value/1440), DirectSQL.pas:200 (speMaxRows.Value - 1), Purge.pas:221/277 e Syncronice.pas:2210-2211. O RFormat serializa vtInteger com IntToStr e vtExtended com FloatToStrF(ffGeneral,18), o que dá a mesma string para valores inteiros. Por isso trocar TJvSpinEdit (Value Extended) por TSpinEdit (Value Integer) não muda o que vai pelo fio. Com TNumberBox, usar ValueInt. O speLoginTO.Value/1440 continua float formatado com o separador decimal do locale; isso já existia e é da família Midware.
- [REVISÃO] Detalhes menores: os 6 tipos triviais somam cerca de 88 de 128 componentes (uns 70%, não 75%). O GetIt lista 2025.10 e 2026.08 sem nomear a versão do IDE na página, só no URL do download ('-13-'). O ProtectPassword do TJvEdit também bloqueia leitura dentro do processo; como a DLL roda dentro da IDE, com TEdit outros plugins do mesmo processo poderiam ler a senha. O risco é baixo.

#### Units

| Unit | Onde está | Condição | Status D13 | Substituto | Notas |
|---|---|---|---|---|---|
| JvCombobox (TJvComboBox) | ausente (JVCL externo: jvcl\run\JvCombobox.pas, pacote JvStdCtrls d37) | sempre | `substituir` | TComboBox (Vcl.StdCtrls) | Só usa Text, Items, ItemIndex, Enabled, Color e SetFocus (MRU comentado). Remover DotNetHighlighting do DiffMain.dfm e ajustar a assinatura de ToDoFilter.CheckComboBox. |
| JvMemo (TJvMemo) | ausente (JVCL externo: JvMemo.pas, pacote JvStdCtrls d37) | sempre (o de JVCSCreateBranchDialog só com BRANCHING) | `substituir` | TMemo (Vcl.StdCtrls) | Só usa Text, Lines, SelStart/SelLength, Modified e clipboard; tirar MaxLines, HideCaret, ClipboardCommands e AutoSize do DFM. Voltar ao TMemo é trivial. |
| JvSpin (TJvSpinEdit) | ausente (JVCL externo: JvSpin.pas, pacote JvStdCtrls d37) | sempre (VerSet só com IDEDLL) | `substituir` | TSpinEdit (Vcl.Samples.Spin, Integer); TNumberBox só usando ValueInt | ~28 usos de .AsInteger (vira .Value) e casts 'as TJvSpinEdit' em VerSet/Syncronice; converter Min/Max/Value float do DFM para inteiro. Vai ao servidor por WriteFields, mas com Integer o RFormat gera a mesma string. |
| JvEdit (TJvEdit) | ausente (JVCL externo: JvEdit.pas, pacote JvStdCtrls d37) | sempre (Create também entra na DLL) | `substituir` | TEdit com PasswordChar (Vcl.StdCtrls) | Campos de senha (ProtectPassword); usa só Text/Clear/SetFocus/SelectAll. Remover ProtectPassword, 'Modified = False' e ClipboardCommands do DFM; sem impacto no protocolo. |
| JvToolEdit (TJvFilenameEdit) | ausente (JVCL externo: JvToolEdit.pas, pacote JvStdCtrls d37) | sempre | `substituir` | TButtonedEdit (Vcl.ExtCtrls) com TOpenDialog, ou TEdit com TButton | Os OnButtonClick do Options só configuram o diálogo embutido; o substituto precisa abrir o TOpenDialog e preencher Text. Reproduzir AddQuotes=True nos 4 campos do Options (bug original: edBMPButtonClick configura edRWS). |
| JvColorCombo (TJvColorComboBox) | ausente (JVCL externo: JvColorCombo.pas, pacote JvStdCtrls d37) | sempre | `substituir` | TColorBox (Vcl.ExtCtrls) com cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor e cbPrettyNames | ColorValue vira Selected; os 4 combos do Options exigem cbSystemColors. Remover as propriedades JVCL do DFM; as TColor gravadas continuam compatíveis. |
| JvTextListBox (TJvTextListBox) | ausente (JVCL externo: JvTextListBox.pas, pacote JvStdCtrls d37) | sempre | `substituir` | TListBox (ScrollWidth para a rolagem horizontal) | Usa Items, ItemIndex, Selected, MultiSelect, ItemAtPos e Repaint, todos nativos. |
| JvListBox (TJvListBox) | ausente (JVCL externo: JvListBox.pas, pacote JvStdCtrls d37) | sempre | `substituir` | TListBox | Usa só Items e ItemIndex; remover Background.* do DFM. |
| JvSplitter (TJvSplitter) | ausente (JVCL externo: JvSplitter.pas, pacote JvControls d37) | sempre | `substituir` | TSplitter (Vcl.ExtCtrls) | Usa só Visible e Left; troca trivial. |
| JvSplit (TJvxSplitter) | ausente (JVCL externo: JvSplit.pas, pacote JvControls d37) | sempre | `remover` | — | Resíduo no uses do AssignLabels, sem componente no DFM. |
| JvNetscapeSplitter (TJvNetscapeSplitter) | ausente (JVCL externo: JvNetscapeSplitter.pas, pacote JvControls d37) | sempre | `substituir` | TSplitter | Perde o botão de recolher, que não é usado; remover ButtonCursor/Maximized/Minimized do DFM. |
| JvArrowButton (TJvArrowButton) | ausente (JVCL externo: JvArrowButton.pas, pacote JvControls d37) | sempre | `substituir` | TSpeedButton com PopupMenu.Popup (mais fiel), ou TButton com Style=bsSplitButton, DropDownMenu e Images | DropDown, Glyph, Caption, Hint atribuídos em runtime; TSpeedButton + PopupMenu é o mais fiel. Remover FillFont.* do DFM. |
| JvLED (TJvLED) | ausente (JVCL externo: JvLED.pas, pacote JvHMI d37) | sempre. JVCSDebugView só com DEBUG, que está nos .dof, e é código morto: CreateClientDebugView está comentado no Jedivcs.dpr e não é chamado na DLL | `substituir` | TShape (stCircle) mudando Brush.Color | Só atribui ColorOn e faz reparent (TransLED1); TShape resolve e elimina o pacote JvHMI. O uso em JVCSDebugView é código morto. |
| JvOfficeColorButton (TJvOfficeColorButton) | ausente (JVCL externo: JvOfficeColorButton.pas, pacote JvControls d37) | sempre | `substituir` | TColorBox com cbIncludeNone e cbCustomColor (OnChange), ou TButton/TPanel com TColorDialog | Usa SelectedColor (inclusive clNone), Enabled e OnColorChange; remover Properties.* e HotTrackFont.* do DFM. |
| JvGradient (TJvGradient) | ausente (JVCL externo: JvGradient.pas, pacote JvMM d37) | sempre | `substituir` | TPaintBox com Vcl.GraphUtil.GradientFillCanvas (gdHorizontal) no OnPaint | Só pré-visualiza StartColor/EndColor; trocar elimina o pacote JvMM. |
| JvColorBox / JvColorButton | ausente (JVCL externo: pacote JvControls d37) | sempre | `remover` | — | Resíduo do IDE nos uses; nenhum componente no DFM ou no código. |
| JvListComb (TJvImageComboBox) | ausente (JVCL externo: JvListComb.pas, pacote JvControls d37) | sempre | `substituir` | TComboBoxEx (Vcl.ComCtrls) com Images e ItemsEx (Caption e ImageIndex) | O ItemIndex é dado do servidor (nível de direito e severidade do bug): preservar exatamente a ordem dos itens. Items[I].ImageIndex vira ItemsEx[I].ImageIndex. |
| JvComCtrls (TJvTreeView) | ausente (JVCL externo: JvComCtrls.pas, pacote JvStdCtrls d37) | ProjectTreeDockWnd só com {$IFNDEF IDEDLL} (ProjAdmin.pas:1153-1155), ou seja, só no EXE | `substituir` | TTreeView (Vcl.ComCtrls) | Usa apenas API nativa de TTreeView; LineColor sai do DFM (ou TreeView_SetLineColor). Só no EXE. |
| JvCheckTreeView (TJvCheckTreeView) | ausente (JVCL externo: JvCheckTreeView.pas, pacote JvStdCtrls d37) | sempre | `substituir` | TTreeView com CheckBoxes=True e TTreeNode.Checked (VCL, Delphi 11+) | CheckBox[Node] só recebe True, então basta CheckBoxes=True + Node.Checked (Delphi 11+); cascata é manual. Testar a seleção de projetos no Sync. |
| JvListView | ausente (JVCL externo: JvListView.pas, pacote JvStdCtrls d37) | sempre | `remover` | — | Resíduo no uses do Syncronice; nenhum uso. |
| JvToolBar (TJvToolBar) | ausente (JVCL externo: JvToolBar.pas, pacote JvStdCtrls d37) | sempre | `substituir` | TToolBar (Vcl.ComCtrls), que tem Menu nativo | Todas as propriedades do DFM existem no TToolBar (inclusive Menu). Testar no form principal do EXE e da DLL. |
| JvRichEdit (TJvRichEdit) | ausente (JVCL externo: JvRichEdit.pas, pacote JvStdCtrls d37) | sempre | `substituir` | TRichEdit (Vcl.ComCtrls) com EM_AUTOURLDETECT e tratamento de EN_LINK, ou TMemo com TLinkLabel | Memo3URLClick só faz ShellExecute da URL; corrigir também o 'inherited Memo3: TMemo' do DiffAbout.dfm. |
| JvxCheckListBox (TJvxCheckListBox) | ausente (JVCL externo: JvxCheckListBox.pas, pacote JvStdCtrls d37) | sempre | `substituir` | TCheckListBox (Vcl.CheckLst) | Usa Checked[I], Items, Color, Cursor, Enabled e PopupMenu, todos nativos; remover InternalVersion do DFM. |
| JvxSlider (TJvxSlider) | ausente (JVCL externo: JvxSlider.pas, pacote JvStdCtrls d37) | sempre (o aviso de troca de acelerador só com IDEDLL) | `substituir` | TTrackBar (Min, Max, Position) | Usa .Value, Enabled e OnChange; mapear para Min/Max/Position. |
| JvDriveCtrls (TJvDriveCombo) | ausente (JVCL externo: JvDriveCtrls.pas, pacote JvControls d37) | sempre | `substituir` | TComboBox preenchido com GetLogicalDriveStrings e GetDriveType=DRIVE_FIXED (o Vcl.FileCtrl.TDriveComboBox não filtra por tipo) | Usa só .Drive; TDriveComboBox não filtra por tipo, por isso preencher com GetLogicalDriveStrings + DRIVE_FIXED. |
| JvWizard / JvWizardRouteMapSteps | ausente (JVCL externo: pacote JvWizards d37, confirmado) | {$IFDEF BRANCHING}, que não é definido em nenhum .dof, .inc ou .dpr; desligado no build padrão | `atualizar-versao` | TCardPanel (Vcl.WinXPanels) ou TPageControl com abas ocultas e botões Voltar/Avançar/Concluir | Só com BRANCHING (desligado). Se ligado, reescrever com TCardPanel ou instalar JvWizards d37 e testar contra o servidor. |
| JvMaskEdit | ausente (JVCL externo: JvMaskEdit.pas, pacote JvStdCtrls d37) | sempre | `remover` | — | Adicionada pelo IDE junto com o TJvSpinEdit; sai com a troca do spin. |
| JvExStdCtrls / JvExControls / JvExExtCtrls / JvExMask / JvExComCtrls | ausente (JVCL externo: pacote JvCore d37) | sempre | `remover` | — | Ancestrais adicionadas pelo IDE; saem dos uses quando os TJv* forem trocados. |
| JvComponent / JvComponentBase / JvExtComponent | ausente (JVCL externo: pacote JvCore d37) | sempre | `remover` | — | [REVISÃO] Units que faltavam. JvComponentBase continua necessária enquanto existirem TJvSearchFiles, TJvPluginManager e TJvMruList. |

### 3.6 VirtualTreeView + acessibilidade + temas + listas DFS

**Família no levantamento:** VirtualTreeView + acessibilidade + temas (VirtualTrees, VTAccessibility*, VTHeaderPopup, MSAAIntf, ThemeManager/ThemeSrv/UxTheme, winxp.res) + listas/árvores DFS (EnhListView, SystemTreeView/SystemControlPack) + SortGrid

**Situação no Delphi 13.2:** `misto` · **Decisão:** `manter-atualizado` · **Esforço:** médio

**Pasta na v2026:**
- VirtualTreeView V8.5: dependência externa com tag fixada. Vendorizar em `src\comp\virtualtreeview` (Source + Packages\RAD Studio 10.4+) é opcional.
- Substituto da EnhListView: componente compatível próprio. O inventário sugeria `src\common\client`; esta consolidação propõe a unit em `src\common` (o `src\common\client` fica reservado ao núcleo de protocolo sem VCL) e o registro no pacote de `src\packages`.
- ThemeManager, ThemeSrv, MSAAIntf, StrUtilsD5, compilers.inc, EnhListView/DFS e SortGrid: removidos.

**Notas de consolidação:**
- **`{$R *.res}`:** o `src\jedivcs\Jedivcs.dpr` da v2026 (de `ConverterBackup`) já tem `{$R *.res}` ativo (linha 263), seguido de `jvcsver.res`, `strings.res`, `cursors.res`, `icon.res` e do `winxp.res` de caminho absoluto (linha 268). O `{.$R *.res}` desativado citado abaixo é da cópia Lazarus.
- **VERSIONINFO duplicado (crítico 1.1):** continua valendo. Desligar "Include version information" nos `.dproj` e manter `jvcsver.rc` como fonte única.
- **`winxp.res` na v2026:** `src\jedivcs\Jedivcs.dpr:268`, `src\jedivcs\JediVCSDLL.dpr:523` e `src\jedivcsdiff\JEDIVCSDiff.dpr:80`.

#### Resumo

A revisão confirmou o núcleo do inventário. O VT do repositório é o 4.8.5 "JVCS Edition", adaptado ao FPC/LCL, e inclui o Components\compilers.inc de 2008, que só reconhece até VER200 e só sob {$ifdef Win32}; em Win64 ele cai no ramo Kylix/QT_CLX. Por isso o Delphi 13 compilaria os caminhos legados (MSAAIntf, ThemeSrv, StrUtilsD5, UnicodeString=WideString), e a troca pelo VirtualTreeView V8.5 da JAM é necessária: tag V8.5 publicada em 02/10/2026, README "RAD Studio 10 to 13", GetIt 8.3 para Delphi 13. Corrigi as contagens. A EnhListView tem 18 listas em 15 forms no EXE e 20 em 16 na DLL. São 5 handlers OnSortItems com TSortAs. Dos 5 OnGetText com WideString, só 3 estão ligados no build ativo: VSTHierarchyGetText não está ligado (TVirtualDrawTree não tem OnGetText) e o do BranchTreeViewFrame fica sob BRANCHING. Acrescentei riscos que faltavam. OnDrawItem tem o mesmo nome e assinatura diferente na EnhListView e no TListView. Propriedades da EnhListView que ficarem no DFM dão EReadError. O Jedivcs.dpr tem {.$R *.res} desativado, então o manifest gerado pelo projeto não entra no EXE sem ajuste. E o VCL apaga as setas HDF_SORT* quando atualiza as colunas. O inventário exagerou a licença DFS: ela não impede uso nem modificação privada. Mesmo assim a troca vale, porque a EnhListView 3.72 não funciona com segurança em Win64 e depende de DFS.INC/ExtListView, que não estão no repositório. Nada da família afeta o protocolo com o servidor 2.5 Beta 3.

#### Fonte recomendada

VirtualTreeView V8.5 da JAM-Software (tag V8.5, publicada em 2026-10-02, segundo a API de releases do GitHub): https://github.com/JAM-Software/Virtual-TreeView. Vendorizar em v2026 a pasta Source\ e Packages\\"RAD Studio 10.4+" (VirtualTreesR.dpk/VirtualTreesD.dpk com {$LIBSUFFIX AUTO}), o que serve para Delphi 11, 12 e 13 com uma única versão. Alternativas: GetIt "Virtual Treeview (Latest Version)" 8.3, que lista só "IDE: Delphi 13" e foi atualizado em 2026-01-19 (https://getitnow.embarcadero.com/virtual-treeview-latest-version) e está atrás do GitHub; ou DPM (JAM.VirtualTreeView.dspec, novo desde V8.4.1). Para EnhListView, SystemTreeView, SortGrid e ThemeManager não há fonte a obter: substituir ou remover. A cópia https://github.com/winghc/extlist_xe (EnhListView 3.72 para XE, último push em 2017) não serve: não roda com segurança em Win64 e depende de DFS.INC/ExtListView. Os pacotes de design do TShellTreeView estão em https://github.com/etheadev/delphishellcontrolspackages (D11/D12/D13); o fonte Vcl.Shell.ShellCtrls vem com o Delphi.

#### Alternativa nativa

VirtualTreeView: não há equivalente nativo à altura. O vstSummary do LineHistoryFrame é árvore com colunas e ordenação; o ProjectTreeDockWnd usa TVirtualDrawTree com filtro e desenho HTML (ItemHtDraw da JVCL). Atualizar para o V8 sai mais barato. JVCSBrowserFrame e JVCSLineHistorySettingsDialog são listas planas (só RootNodeCount, confirmado) e poderiam virar TListView (OwnerData + OnCustomDrawSubItem) mais tarde, mas sem ganho real, porque o VT continua necessário. Temas: o manifest do projeto (Project Options > Application > Manifest, Auto generate + Enable runtime themes) só é linkado via &lt;projeto>.res, então o Jedivcs.dpr precisa reativar {$R *.res}. DPI: comece com GDI Scaling ou System Aware e só depois PerMonitorV2. Vcl.Themes/StyleServices e Winapi.UxTheme se for preciso; VCL Styles é opcional, e o VT V8 tem VirtualTrees.StyleHooks. MSAA: Winapi.oleacc (o V8 já usa). EnhListView: Vcl.ComCtrls.TListView, e vale trocar. Ordenação por OnColumnClick + CustomSort/OnCompare. Setas por HDF_SORTUP/HDF_SORTDOWN via Header_GetItem/Header_SetItem, reaplicadas depois de UpdateColumn/RecreateWnd. Cores por OnCustomDrawItem/OnCustomDrawSubItem, mudando Canvas.Font.Color/Style. RowSelect=True substitui o FullRowSelect dos handlers. Como 38 objetos DFM (18+20) usam propriedades que o TListView não tem, a melhor opção é um componente compatível próprio, registrado num pacote de design, que publique AutoColumnSort/ShowSortArrows/OnSortItems(TSortAs) e preserve os handlers. A outra opção é limpar todos os DFMs. Um interposer não registrado não abre no designer. TJvListView (JVCL) ordena ao clicar (SortOnClick/SortMethod, com alternância asc/desc) e tem HeaderImages, mas não desenha setas automaticamente nem tem OnSortItems/TSortAs, então não compensa. SystemTreeView: Vcl.Shell.ShellCtrls.TShellTreeView (pacote de design de terceiros ou criado em runtime) ou um TTreeView próprio com carga preguiçosa. Criar pasta (AddNewNode) vira ForceDirectories + Refresh; renomear pode usar a edição in-place do shell. Alternativa de UX: TFileOpenDialog com fdoPickFolders. SortGrid: nada, basta tirar do uses.

#### Destino proposto pelo inventário (texto original)

src\comp\virtualtreeview (VT V8.5 vendorizado: Source\ + Packages\RAD Studio 10.4+\\; equivale ao antigo src\comp\soft-gems\virtualtreeview\source). Helper ou componente compatível de TListView, substituto da EnhListView, em src\common\client (com pacote de design próprio se a opção for o componente registrado). ThemeManager, ThemeSrv, MSAAIntf, StrUtilsD5, compilers.inc, vtconfig.inc, virtualtrees.res, EnhListView, ExtListView, DFS.INC, SystemTreeView, SystemControlPack e SortGrid ficam sem pasta: são removidos.

#### Riscos

- As assinaturas de eventos ligados via DFM não são verificadas na compilação nem em runtime. No VT V8, OnGetText usa 'var CellText: string' em vez de WideString, e OnHeaderClick passou a (Sender: TVTHeader; HitInfo: TVTHeaderHitInfo); os dois são binariamente incompatíveis e corrompem memória em silêncio. OnGetImageIndex passou a usar TImageIndex (= type Integer), que é binariamente compatível: a IDE só reclama ao abrir o form. Corrigir todos e abrir cada form na IDE.
- O V8 move tipos para VirtualTrees.Types e TVirtualDrawTree para VirtualTrees.DrawTree (ProjectTreeDockWnd). toAutoChangeScale mudou: agora o DPI escala sempre. Nos DFMs, 'WideText' dos Columns continua sendo lido (DefineProperty em VirtualTrees.Header), mas a IDE regrava como 'Text'.
- Os componentes de Components\\\* foram adaptados ao port FPC/LCL e dependem do compilers.inc de 2008. Copiá-los para o v2026 faria o Delphi 13 compilar caminhos legados: MSAAIntf, ThemeSrv, TmSchema, StrUtilsD5 (que redeclara UTF8String=AnsiString) e redeclarações de UnicodeString/PByte. Não reaproveitar nenhum desses arquivos.
- JediVCSDLL: compilar sem runtime packages, para que o VT fique linkado estaticamente e a DLL não dependa de BPLs instaladas na IDE.
- EnhListView e SystemTreeView são DFS (Brad Stowers) e exigem DFS.INC (sem VER370); a EnhListView também usa ExtListView. Nada disso está no repositório, então trocar por nativos.
- A troca da EnhListView atinge 18 listas em 15 forms no EXE e 20 em 16 na DLL, e o trabalho dobra se jedivcs\ e jedivcsdll\ continuarem como cópias separadas (as diferenças entre elas são só cabeçalhos FPC). 10 listas por cópia usam Style=lvOwnerDrawFixed e precisam migrar para custom draw.
- TShellTreeView: o pacote de design não vem instalado. AddNewNode/EditText/RootFolder/PopupMenuMethod do TdfsSystemTreeView precisam ser reimplementados. Testar com unidades de rede e OneDrive.
- winxp.res é referenciado por caminho absoluto inexistente nos 3 .dpr, e o build falha (arquivo não encontrado) enquanto não for removido. O manifest XP não declara DPI nem supportedOS. Na DLL, o manifest de ID 1 é ignorado e pode simplesmente sair.
- As setas HDF_SORTUP/HDF_SORTDOWN exigem comctl32 v6: manifest com runtime themes no EXE; dentro da IDE já está ativo.
- [REVISÃO] Contagem da EnhListView corrigida: 18 objetos TdfsEnhListView em 15 DFMs no EXE e 20 em 16 na DLL (não 19/21 em 16). No EXE, 16 units têm EnhListView no uses: as 15 + ModuleHistoryWindow, onde é referência morta porque lvHistory é TListView. Syncronice também usa o tipo TdfsEnhListView em parâmetros e casts.
- [REVISÃO] OnSortItems: são 5 handlers com TSortAs (DirWatch, ProjAdmin, Std_ListView ligado em código na linha 289, Syncronice compartilhado por 4 listas, UsedUnits), não 6. Há 29 chamadas a Resort e 24 atribuições a AutoResort (o inventário dizia ~47 chamadas). Também ShowSortArrows=True (17), AutoColumnSort=acsSortToggle (17), OnDrawItem (9 listas), OnDrawHeader (8), OnDrawSubItem (7).
- [REVISÃO] Dos 5 OnGetText com WideString, só 3 estão ligados no build ativo: BrowserFrame, LineHistoryFrame e LineHistorySettingsDialog. ProjectTreeDockWnd.VSTHierarchyGetText é handler morto (o DFM é TVirtualDrawTree, que não tem OnGetText) e JVCSBranchTreeViewFrame.vtBranchGetText fica sob BRANCHING. Os demais eventos usados (OnBeforeItemErase, OnAfterCellPaint, OnCompareNodes, OnInitNode, OnInitChildren, OnFocusChanged, OnDrawNode, OnGetNodeWidth com TDimension=Integer, OnExpanded/OnCollapsed) têm a mesma assinatura no V8.
- [REVISÃO] tsUpdating e Header.Treeview não são usados pelo cliente, então essas quebras do V8 não se aplicam aqui. Sobre enums: o V8 re-exporta em VirtualTrees as constantes ttNormal, sdAscending/sdDescending e NoColumn, mas não ikNormal/ikSelected/ikState, ivsExpanded/ivsHasChildren nem eaColor. Esses dão erro de compilação (não silencioso) até VirtualTrees.Types entrar no uses de BrowserFrame, LineHistoryFrame, LineHistorySettingsDialog e ProjectTreeDockWnd.
- [REVISÃO] Risco novo: TdfsEnhListView.OnDrawItem (Control; var ACanvas; Index; ARect; State; var DefaultDrawing, FullRowSelect) tem o mesmo nome do TListView.OnDrawItem (Sender; Item; Rect; State), mas outra assinatura. Ao trocar a classe no DFM, os 9 handlers continuam ligados sem erro de compilação. Se Style=lvOwnerDrawFixed virar OwnerDraw=True, eles serão chamados com parâmetros errados e o programa dá AV ou corrompe memória. É preciso renomear ou desligar esses handlers.
- [REVISÃO] Risco novo: Style, AutoColumnSort, NoColumnResize, ShowSortArrows, AutoSortAscending, OnSortItems, OnDrawHeader e OnDrawSubItem não existem no TListView. Se ficarem nos DFMs, causam EReadError 'Property ... does not exist' em runtime. Ou se limpam os 38 DFMs, ou se cria um componente compatível registrado num pacote de design; um interposer não registrado não abre no Form Designer.
- [REVISÃO] Risco novo: o VCL reaplica o formato das colunas do TListView (UpdateColumn/ListView_SetColumn, RecreateWnd em mudança de estilo ou DPI), o que pode apagar os flags HDF_SORTUP/DOWN do header. O helper deve reaplicar as setas depois de ordenar, de alterar colunas e de recriar o handle.
- [REVISÃO] winxp.res e manifest: o Delphi grava o manifest auto-gerado dentro de &lt;projeto>.res, e o Jedivcs.dpr tem '{.$R *.res}' desativado (linha 271). Só tirar o winxp.res deixa o EXE sem manifest, ou seja, sem comctl32 v6 e sem setas de ordenação. Reativar {$R *.res} e resolver duplicidade de VERSIONINFO/MAINICON com jvcsver.res/icon.res, ou linkar um .res de manifest próprio. JEDIVCSDiff.dpr e JediVCSDLL.dpr já têm {$R *.res}. Evitar começar em PerMonitorV2 (app com owner-draw e medidas fixas); preferir GDI Scaling ou System Aware na primeira etapa.
- [REVISÃO] Licença DFS corrigida: ela permite usar, modificar em privado e distribuir binários. O que proíbe é distribuir fonte modificado 'by itself' sem o arquivo original do site DFS (hoje fora do ar) e vender o fonte. O motivo forte da troca é técnico: a EnhListView 3.72 não funciona com segurança em Win64 (CustomSort com integer(Self), SetWindowLong(..., LongInt(...)), SendMessage com LongInt(@HTI)) e depende de DFS.INC e ExtListView, ausentes.
- [REVISÃO] ThemeMgr só é código morto se o jedi.inc vier de um JCL atual, com bloco VER370 ou fallback UNKNOWN_COMPILER_VERSION. Com um JCL antigo (o HowToBuild cita 1.91), DELPHI7_UP pode não ser definido e ProjAdmin/DiffMain voltariam a exigir ThemeMgr. Recomendo apagar os blocos {$IFNDEF DELPHI7_UP} em vez de depender do define.
- [REVISÃO] compilers.inc: além de parar no VER200, toda a detecção está sob {$ifdef Win32}. Em Win64, o ramo {$else} define QT_CLX/KYLIX, o que piora o caso de reaproveitar o VT 4.8.5 e confirma a remoção.
- [REVISÃO] Não confirmei que a IDE use VirtualTrees internamente; a justificativa de compilar a DLL sem runtime packages é só a autonomia da DLL. O RAD Studio 13 traz também uma IDE 64-bit (só Win64). A DLL e o pacote de design do VT (para abrir os forms no designer) precisam ser compilados na bitness da IDE que vai carregá-los. O mecanismo de carga da DLL (TIDEVCSClient/EXT_IDE_INTF) é de outra família.
- [REVISÃO] Uso indireto esquecido: SelectProjectID (EXE e DLL) usa TTreeView, mas puxa VirtualTrees via JVCSProjectTreeUnit (TVSTContainer.SaveStateInfo/RestoreStateInfo na interface). Por isso a DLL linka o VT mesmo sem ProjectTreeDockWnd.
- [REVISÃO] Os defaults do V8 diferem do 4.8.5: DFMs que não gravam AutoOptions/MiscOptions (BrowserFrame, SettingsDialog, BranchTreeView) herdam toAutoChangeScale, toAutoSort, toAutoHideButtons e toEditOnClick. Deve ser inofensivo aqui (SortColumn=NoColumn e sem toEditable), mas conferir visualmente. virtualtrees.res não é necessário no V8, que não tem {$R} nas units de Source.
- [REVISÃO] Fora desta família, mas relacionado: dfsStatusBar (Components\dfsstatusbar.pas, TdfsStatusBar 1.24) também é DFS e faz {$I DFS.INC}, que está ausente. É usado em ProjAdmin, Syncronice e DiffMain; confirmar que outra família o cobre.
- [REVISÃO] Protocolo confirmado sem risco: tudo é UI e não há SaveToStream/LoadFromStream de VT. O JVCSBrowserFrame depende da função de servidor LIST_FILES, que existe no servidor 2.5 (JVCSSrvOBJNewObjects.pas registra TServerObjectLIST_FILES), então não muda nada no servidor 2.5 Beta 3.
- [NOTA DO REVISOR] Durante a verificação, um comando curl gravou por engano uma cópia de leitura de JvListView.pas em %TEMP%\jvlv_check.txt. Não alterei nenhum arquivo do projeto; esse temporário pode ser apagado.

#### Units

| Unit | Onde está | Condição | Status D13 | Substituto | Notas |
|---|---|---|---|---|---|
| VirtualTrees (virtualtrees.pas + virtualtrees.res) | Components\virtualtrees.pas (v4.8.5 'JVCS Edition', com {$ifdef FPC/LCL} do port Lazarus) | sempre (EXE e DLL). ProjectTreeDockWnd só {$IFNDEF IDEDLL} no uses de implementação do ProjAdmin e não está no JediVCSDLL.dpr. Branch* só {$IFDEF BRANCHING}, que não é definido em compopt.inc nem nos .dof. | `atualizar-versao` | VirtualTrees V8.5 (JAM-Software). VirtualTrees.Types no uses onde houver ik*/ivs*/eaColor; VirtualTrees.DrawTree em ProjectTreeDockWnd. | O compilers.inc local faria o D13 compilar caminhos legados. Ajustes V8: 3 OnGetText WideString→string, vstSummaryHeaderClick com TVTHeaderHitInfo (obrigatórios), VirtualTrees.Types/DrawTree nos uses. |
| VTAccessibilityFactory | Components\vtaccessibilityfactory.pas | sempre (interno do VT 4.8.5); usa MSAAIntf sob {$ifndef COMPILER_10_UP} | `atualizar-versao` | VirtualTrees.AccessibilityFactory (vem com o V8) | Interna do VT 4.8.5; nenhum fonte do cliente a referencia. |
| VTAccessibility | Components\vtaccessibility.pas | não usado pelo cliente (nenhum uses em EXE/DLL/Diff/Console) | `remover` | VirtualTrees.Accessibility (V8; desde a V8.5 os provedores são registrados por padrão) | Não usada; no V8.5 os provedores MSAA passam a ser registrados por padrão (mudança benigna). |
| VTHeaderPopup | Components\vtheaderpopup.pas | não usado (nenhuma referência no cliente) | `remover` | VirtualTrees.HeaderPopup (V8), só se um dia for necessário | Arquivo órfão. |
| VTConfig.inc | Components\vtconfig.inc | sempre (interno do VT 4.8.5); define ThemeSupport | `remover` | nenhum (não existe no V8) | Não existe no V8. |
| Compilers.inc (soft-gems) | Components\compilers.inc | sempre (incluído pelas units do VT/ThemeSrv) | `remover` | nenhum (o V8 não usa; o cliente usa o jedi.inc do JCL atual) | Só reconhece até VER200 e só sob Win32 (em Win64 cai em Kylix/QT_CLX); o V8 não usa. |
| MSAAIntf | Components\msaaintf.pas | {$ifndef COMPILER_10_UP}, que fica ATIVO com o compilers.inc desatualizado | `remover` | Winapi.oleacc (RTL), que o V8 já usa | Para Delphi 2005 e anteriores; o V8 usa Winapi.oleacc. |
| StrUtilsD5 | Components\strutilsd5.pas | {$IFNDEF DELPHI_6_UP}, ativo com o compilers.inc desatualizado | `remover` | System.StrUtils (IfThen) | Redeclara UTF8String=AnsiString (perigoso em Unicode); some com o VT V8. |
| ThemeSrv | Components\themesrv.pas (Mike Lischke, adaptado para LCL) | {$ifdef ThemeSupport} + {$ifndef COMPILER_7_UP}, ativo com o compilers.inc desatualizado | `remover` | Vcl.Themes (StyleServices / TStyleManager) | Nenhum fonte do cliente o usa diretamente. |
| TmSchema | ausente no repo | mesmo caminho legado do ThemeSrv | `remover` | Winapi.UxTheme / Vcl.Themes (desnecessário com o VT V8) | Some junto com ThemeSrv e o VT 4.8.5. |
| UxTheme (uxtheme.pas.masked) | Components\uxtheme.pas.masked (renomeado para não sombrear a RTL) | arquivo mascarado, nunca compilado | `remover` | Winapi.UxTheme (RTL) | Arquivo mascarado, nunca compilado; não copiar para a v2026. |
| ThemeMgr (thememgr.pas.masked) | Components\thememgr.pas.masked (mascarado) | {$IFNDEF DELPHI7_UP}. Fica morto se o jedi.inc for de um JCL atual (VER370 define DELPHI37, e a cadeia chega a DELPHI7_UP). Com um jedi.inc antigo, voltaria a ser exigido. | `remover` | Manifest do projeto (Enable runtime themes) + Vcl.Themes; VCL Styles opcional | Apagar os blocos {$IFNDEF DELPHI7_UP} de ProjAdmin e DiffMain em vez de depender da versão do jedi.inc. |
| ThemeMgrDB (thememgrdb.pas.masked) | Components\thememgrdb.pas.masked | não usado | `remover` | — | Órfão. |
| winxp.res (recurso do ThemeManager) | ausente (caminho absoluto \Projects\Jedivcs\src\comp\soft-gems\thememanager\Resources\winxp.res) | sempre ({$R ...} sem IFDEF) | `substituir` | Manifest auto-gerado em Project Options > Application > Manifest (runtime themes; DPI começando em GDI Scaling ou System Aware) no EXE e no Diff; na DLL, apenas remover | Caminho absoluto inexistente nos 3 .dpr: o build falha até remover. O manifest auto-gerado vai em &lt;projeto>.res (no EXE e no Diff); na DLL basta remover. |
| EnhListView (TdfsEnhListView 3.72, DFS/Brad Stowers) | ausente | sempre (sem IFDEF) no EXE e na DLL; Diff e Console não usam | `substituir` | Vcl.ComCtrls.TListView + componente compatível próprio registrado em pacote de design (ou helper + limpeza dos DFMs): OnColumnClick/CustomSort, setas HDF_SORTUP/DOWN reaplicadas, OnCustomDrawItem/SubItem, RowSelect | 18 listas em 15 forms (EXE) e 20 em 16 (DLL); OnDrawItem com assinatura diferente do TListView e propriedades sem equivalente (EReadError). A 3.72 não é segura em Win64 e depende de DFS.INC/ExtListView. |
| ExtListView + DFS.INC (dependências transitivas da DFS) | ausente | só seria compilado se a EnhListView fosse ressuscitada | `remover` | nenhum (saem junto com a EnhListView; o dfsStatusBar fica com a família que o cobre) | Só seriam compiladas se a EnhListView fosse ressuscitada. |
| SystemTreeView (TdfsSystemTreeView 0.98.5, DFS) | ausente | sempre | `substituir` | Vcl.Shell.ShellCtrls.TShellTreeView (criado em runtime, ou com dclshlctrls de etheadev instalado), ou TTreeView próprio; alternativa de UX: TFileOpenDialog com fdoPickFolders | Usa RootFolder, Selection, AddNewNode, EditText, Reset e PopupMenuMethod, que precisam ser reimplementados no substituto. |
| SystemControlPack (DFS) | ausente | sempre | `remover` | sai junto com a troca do SystemTreeView (TShellTreeView: Root/ObjectTypes) | Sai junto com a troca do SystemTreeView. |
| SortGrid | ausente | sempre no uses, mas não há nenhum TSortGrid em History.dfm/.pas (o form usa TListView lvHistory) | `remover` | nenhum (basta tirar do uses) | Referência morta no uses do History. |

### 3.7 SynEdit + mwPasLex + TextDrawer

**Família no levantamento:** SynEdit + mwPasLex + TextDrawer

**Situação no Delphi 13.2:** `misto` · **Decisão:** `manter-atualizado` · **Esforço:** médio

**Pasta na v2026:**
- SynEdit: dependência externa, **pyscripter/SynEdit** fixado num commit, porque é a única linha que compila em Delphi 11, 12 e 13 (decisão: manter compilação em 11/12). A cópia em `src\comp\synedit` é opcional.
- `src\comp\mwtools`: `CastaliaPasLex`/`CastaliaPasLexTypes` renomeados para `mwPasLex.pas`/`mwPasLexTypes.pas`, mais `CastaliaParserDefines.inc` (ver `src\comp\mwtools\LEIAME.md`).
- Os consumidores `JVCSLineHistory*` e `JVCSCompressedDiff*` já estão em `src\common\client`.

#### Resumo

O cliente usa SynEdit em três lugares. O Line History e o Compressed Diff (EXE e DLL) criam os TSynEdit em runtime, com 56 highlighters (57 contando o MPerl condicional) e um highlighter proxy próprio. O JEDIVCSDiff tem 2 TSynEdit no DiffMain.dfm, 28 highlighters e um TSynEditSearch; DiffHLProp manipula atributos. O console não usa nada desta família. A cópia em Components\ é o SynEdit 2.0.x ANSI (2007, synedit.inc só reconhece compiladores até o Delphi 2006) com edições do port Lazarus: não compila no Delphi Unicode e deve ser descartada. A troca é pelo SynEdit DirectWrite atual: pyscripter/SynEdit (Delphi 10.3+, uma árvore só para 11/12/13) ou TurboPack master/GetIt (Delphi 12+, já salvo com o 13.2). A revisão confirmou as quebras de API apontadas e achou outras que não estavam no inventário: o proxy não sobrescreve GetTokenLength, a numeração de linha passada a SetLine mudou de 0 para 1, DiffHLProp chama TSynHighlighterAttributes.Create com 1 parâmetro, e o UNISYNEDIT não pode ser ligado pelo compopt.inc. O mwPasLex/mwPasLexTypes está ausente do repositório (também no GitHub Libaud/JediVCS), mas UsedUnits e ProjDependencies (EXE+DLL) usam sempre, e ToDo/VerSet usam sob IDEDLL. O substituto é o CastaliaPasLex, cópia local renomeada, com UseDefines := False e buffer Unicode correto. Nada disso afeta o protocolo com o servidor 2.5 Beta 3.

#### Fonte recomendada

SynEdit, uma de duas linhas, sem misturar: (A) pyscripter/SynEdit master (https://github.com/pyscripter/SynEdit), fixado no commit de 2025-11-24. O readme declara compatibilidade com Delphi 10.3 Rio ou superior, e o SynEditJedi.inc já reconhece o COMPILER37 (Delphi 13). Pacotes em Packages\Alexandria+\Delphi (SynEditDR.dpk com {$LIBSUFFIX AUTO} / SynEditDD.dpk). É a única opção de árvore única para Delphi 11+12+13, mas não foi validada no 13.2 (o último commit é anterior ao 13.1/13.2). (B) TurboPack/SynEdit master (https://github.com/TurboPack/SynEdit), que o readme diz exigir Delphi 12 Athens ou posterior. Commits de 2026-10-11 ("Saved with 13.2.", "Fixed memory leaks", TSynPopupMenu), pacotes em Packages\11AndAbove\Delphi. É o mesmo código do GetIt "SynEdit for VCL" 2025.03 (TurboPack, listado só para Delphi 13: https://getitnow.embarcadero.com/synedit-for-vcl/). O Delphi 11 só tem o branch 11Alexandria, desatualizado. Recomendação: se o Delphi 11 for obrigatório, use (A) para tudo; se bastarem 12/13, use (B) ou o GetIt. Nunca deixe o GetIt instalado com a cópia local no search path. mwPasLex: CastaliaPasLex.pas + CastaliaPasLexTypes.pas + CastaliaParserDefines.inc de https://github.com/jacobthurman/Castalia-Delphi-Parser (MPL 1.1, commit único de 2011-10-12). Como cópia local, RENOMEIE as units, como o README do Castalia exige para add-ins carregados na IDE (o JediVCSDLL é um). Sugestão: chamar as cópias de mwPasLex.pas/mwPasLexTypes.pas, o que não exige mexer no uses dos consumidores. Alternativa mantida (commit de 2026-01-25): DelphiAST, Source\SimpleParser\SimpleParser.Lexer(.Types).pas (https://github.com/RomanYankovsky/DelphiAST), com Origin: string, o que é melhor para Unicode, mas sem LineNumber e engolindo {$I} quando não há IncludeHandler.

#### Alternativa nativa

Não há substituto nativo razoável. A VCL/RTL do Delphi 13.2 não tem editor com syntax highlight, gutter, marks e plugins: TMemo/TRichEdit obrigariam a reescrever o Line History, o Compressed Diff e o JEDIVCSDiff inteiros, sem highlighters. A RTL também não tem lexer Pascal público. A ToolsAPI só existe dentro da IDE e não serve ao EXE standalone, e o FMX.ASE.Lexer é para modelos 3D, não para Pascal. A rota mais próxima de "nativo" é o SynEdit da TurboPack distribuído pela Embarcadero via GetIt (Delphi 13). O SynEdit atual já usa partes nativas: System.RegularExpressions no lugar de SynRegExpr (SynHighlighterMulti) e DirectWrite/Direct2D (SynDWrite) no lugar de SynTextDrawer. Não vale a pena trocar o SynEdit nem o lexer por algo nativo.

#### Destino proposto pelo inventário (texto original)

src\comp\synedit: cópia fixada da linha escolhida, com Source, Source\Highlighters e Packages\Alexandria+\Delphi (pyscripter) ou Packages\11AndAbove\Delphi (TurboPack), seguindo o antigo ..\comp\synedit\source dos .dof. src\comp\mwtools: CastaliaPasLex/CastaliaPasLexTypes renomeados para mwPasLex.pas/mwPasLexTypes.pas (ou JVCSPasLex*), mais CastaliaParserDefines.inc, mantendo o nome antigo MwTools. Os consumidores compartilhados (JVCSLineHistory*, JVCSCompressedDiff*) vão em src\common\client, como os .dpr esperam ('..\common\client\\'); essa pasta não existe no repositório atual. Alternativa à cópia do SynEdit: "externo via GetIt" (SynEdit for VCL 2025.03, só Delphi 13).

#### Riscos

- A cópia local Components\syn*.pas é o SynEdit 2.0.x ANSI (SynEdit.pas CVS 1.457.2.12, 2007). O synedit.pas usa {$ifdef WINDOWS}/{$ifdef VCL} (defines que o Delphi não tem) e cai em LCLIntf/LCLType/LMessages, e o synedit.inc só reconhece compiladores até o Delphi 2006. Não há como aproveitar: é preciso trocar a biblioteca inteira.
- API do gutter: TSynGutter.Width não existe mais. O gutter agora é feito de bandas (Bands, Band[Kind], RealGutterWidth), e TCustomSynEdit.GutterWidth é somente leitura. Afeta JVCSLineHistoryFrame (Gutter.Width := NextX: DLL linha 1211 / EXE 1215; leitura no ramo UNISYNEDIT: DLL 957 / EXE 961), JVCSCompressedDiffFrame (linhas 131 e 194) e DiffMain.dfm (Gutter.Width = 35). A largura deve ir para uma banda gbkCustom; a leitura passa a ser GutterWidth.
- TSynEditMark.Create agora exige o editor dono (Create(AOwner: TCustomSynEdit)), e a classe foi para SynEdit.pas. DiffMain.pas chama TSynEditMark.Create sem argumento nas linhas 1121 e 2239, dentro de with mwceSource: use Create(mwceSource). TSynEditMarkList agora herda de TObjectList&lt;TSynEditMark> (é dona dos objetos) e não notifica mais o editor no Add. Chame InvalidateGutter depois de inserir as marcas.
- JVCSCompressedDiffSynProxy sobrescreve GetExpandedToken/GetExpandedTokenPos (bloco UNISYNEDIT, linhas 136-137 e 393-403), que não existem mais em SynEditHighlighter: erro de compilação. Remova esses overrides.
- [REVISÃO] Defeito silencioso no proxy (compila, mas quebra o diff inline). O TCustomSynEdit.PaintTextLines novo usa Highlighter.GetTokenLength (SynEdit.pas, aprox. linha 3260). O proxy não sobrescreve esse método, e o da base devolve Run - fTokenPos do próprio proxy, ou seja, 0. Resultado: somem as cores de sintaxe e os realces de caractere inserido/removido. É obrigatório acrescentar 'function GetTokenLength: Integer; override;' retornando Length(FTokens[FIdx].Text).
- [REVISÃO] Base do número de linha mudou. O SynEdit 2.0.x chamava fHighlighter.SetLine(sLine, nLine - 1), base 0 (Components\synedit.pas linha 3314). O SynEdit novo chama FHighlighter.SetLine(SLine, Line) com Line base 1 em PaintTextLines; o ScanFrom ainda passa base 0. O proxy indexa FHighlightLines por base 0 (UpdateHighlight usa I) e, sem ajuste, os realces inline saem deslocados uma linha. Use FHighlightLines.Find(LineNumber - 1) no DoSetLine e reteste.
- [REVISÃO] Proxy: troque TSynCustomHighlighterAccess(FInternalHighlighter).DoSetLine por FInternalHighlighter.SetLine(NewValue, LineNumber). No SynEdit novo esse método é público e faz DoSetLine + Next; sem o Next, o primeiro token lido vem vazio ou com atributo velho. GetLanguageName/GetFriendlyLanguageName agora são class functions abstratas: implemente-as no proxy para evitar o warning W1020 e um EAbstractError, se algo consultar o nome. Opcional: repassar GetRange/SetRange ao highlighter interno, o que melhora comentários multilinha.
- [REVISÃO] DiffHLProp.pas, linhas 308 e 326: TSynHighlighterAttributes.Create('') e Create(cbxAttrSelect.Items[...]) com 1 parâmetro. O construtor novo é Create(AName, AFriendlyName), sem valor default: erro de compilação. Isso não estava no inventário.
- [REVISÃO] O define UNISYNEDIT NÃO pode ser ligado no compopt.inc. Os 4 consumidores (JVCSCompressedDiffSynProxy, JVCSCompressedDiffFrame, JVCSLineHistoryFrame, JVCSLineHistoryHighlighterUnit) só fazem {$I jedi.inc}, que vem da JCL. Além disso, em JVCSLineHistoryFrame (DLL 956-960 / EXE 960-964) e JVCSCompressedDiffFrame (130-134), o ramo UNISYNEDIT é justamente o que usa Gutter.Width e quebra; o ramo ELSE usa GutterWidth e compila. Recomendação: eliminar os IFDEF UNISYNEDIT, ficando só com o caminho do SynEdit novo, em vez de definir o símbolo. Se for definir, faça no DCC_Define dos .dproj (EXE e DLL), não no compopt.inc.
- [REVISÃO] O risco de o AfterPaint(TCanvas) não funcionar sob DirectWrite foi rebaixado. O código atual chama PluginsAfterPaint(Canvas, rcClip, nL1, nL2) DEPOIS de RT.EndDraw, com o Canvas GDI do controle (TCustomSynEdit.Paint), então o CopyRect/TextOut do TGutterInfoPlugin continua desenhando sobre o gutter. Não é preciso migrar para OnPaintLines/Direct2D: basta reservar a largura com uma banda gbkCustom (ou limpar as bandas padrão e deixar só ela) e ler GutterWidth.
- [REVISÃO] Corrigido: TSynEditPlugin.Create(AOwner) com um parâmetro já registra TODOS os handlers, phAfterPaint inclusive, por compatibilidade (SynEdit.pas, constructor TSynEditPlugin.Create). Passar [phAfterPaint, phLinesInserted, phLinesDeleted] é só uma otimização, não uma necessidade.
- DiffMain.dfm precisa ser aberto e re-salvo no IDE com o SynEditDD instalado. Gutter.Width = 35 geraria EReadError ('Property Width does not exist'). Sem esse valor, ajuste a largura da banda de marks para caber as imagens de MarkImages (BookMarkOptions.BookmarkImages). Os demais valores streamados (BookMarkOptions.EnableKeys/GlyphsVisible, MaxUndo, ScrollBars, keystrokes ecContextHelp, TSynGeneralSyn.Comments/IdentifierChars/DetectPreprocessor, TSynSQLSyn.SQLDialect = sqlSybase, TSynXMLSyn.WantBracesParsed) existem no upstream.
- [REVISÃO] Corrigido: o DiffMain.dfm NÃO streama SelectedColor (as cores vêm do registro, no código, linhas 588-594), então o risco de streaming de SelectedColor.Alpha/Opacity não se aplica a este dfm. Efeito cosmético: no SynEdit novo, SelectedColor tem Opacity (padrão 115), e as cores de seleção gravadas no registro passam a aparecer translúcidas.
- DiffMain sincroniza TopLine/LeftChar dos dois editores dentro do OnPaint (linhas 2190-2216). No SynEdit novo, o OnPaint (DoOnPaint) roda depois do EndDraw; o padrão já existia no 2.0.x e não deve entrar em loop, porque só atribui quando o valor difere. Mesmo assim, migrar para OnStatusChange (scTopLine/scLeftChar) é recomendável para evitar repaints extras.
- mwPasLex/mwPasLexTypes estão AUSENTES do repositório local e do GitHub Libaud/JediVCS. O SVN do SourceForge não existe mais, e lá só sobram instaladores binários. Vinham de src\comp\MwTools, conforme os .dof. Sem um substituto, UsedUnits e ProjDependencies (EXE e DLL, que o ProjAdmin usa nos dois ramos, linhas 1121-1126) não compilam. [REVISÃO] Components\MWDefs.inc é do Midware (F. Piette), não do MwTools; não confunda.
- [REVISÃO] Com o CastaliaPasLex, o construtor faz FUseDefines := True, e o InitDefines só conhece VER130..VER200. Com True, quase todo bloco condicional seria avaliado como falso e pulado (GetIsJunk inclui FDefineStack > 0). Por isso UseDefines := False é obrigatório. IsTokenIDJunk trata $IFDEF/$ENDIF etc. como lixo, mas NÃO ptIncludeDirect/ptResourceDirect, então o NextNoJunk de UsedUnits continua vendo {$I}/{$R}. Comentários multilinha voltam como um único token, com LineNumber incrementado, o que é compatível com o ToDo.
- [REVISÃO] Exigência do README do Castalia: se o código for usado em add-in carregado na IDE (é o caso do JediVCSDLL), os nomes das units DEVEM ser trocados. O Castalia foi incorporado à IDE do Delphi. Numa DLL com link estático não há conflito real, mas siga o README: nomeie as cópias mwPasLex/mwPasLexTypes (o que também evita editar os uses) ou JVCSPasLex/JVCSPasLexTypes.
- Buffer Unicode: hoje o código passa MS.Memory (bytes ANSI/UTF-8 do arquivo) como Origin. No Delphi Unicode, PChar = PWideChar, e a leitura sai errada. IDESource2Stream (JVCSIDEInterface.pas, linhas 398-440) grava Content[1] com ReadCount bytes de uma string UTF-16 (metade dos dados) e só 1 byte zero. [REVISÃO] No EXE (ramo não-IDEDLL de UsedUnits/ProjDependencies), o arquivo é copiado para o stream SEM nenhum terminador #0 (UsedUnits linhas 777-786), o que causa leitura além do fim. Solução para todos os casos: ler para string (TEncoding/TStreamReader com detecção de BOM e UTF-8 como padrão, e texto do editor da IDE em UTF-8) e passar PChar(S), que já termina em #0.
- Com o DelphiAST como alternativa: Origin passa a ser string, não há LineNumber (usa-se PosXY.Y) e, sem IncludeHandler, o lexer chama Next ao ver ptIncludeDirect, ou seja, engole o {$I} (SimpleParser.Lexer.pas, aprox. linhas 1651-1658). UsedUnits perderia os includes sem um adaptador.
- Há duas linhas upstream divergindo: TurboPack (2026, Delphi 12+, saved with 13.2, TSynPopupMenu, IME) e pyscripter (último commit 2025-11-24, Delphi 10.3+, não validado no 13.2). Escolha uma, fixe o commit e não misture com o GetIt instalado (conflito de DCU/BPL: SynEditDR/SynEditDD com LIBSUFFIX AUTO).
- O SynEdit atual exige DirectWrite/Direct2D (Windows 7+). O Delphi 13.2 (lançado em setembro de 2026) tem IDE 64 bits e alvo Windows Arm64EC. No Windows 11 ARM64, a IDE e os binários x86/x64 rodam emulados. Teste a renderização, o IME e o DoubleBuffered := True usado nos frames, principalmente na DLL hospedada pela IDE: a bitness da DLL precisa bater com a da IDE escolhida (32 ou 64 bits).
- [REVISÃO] Contagem corrigida: o Line History registra 56 highlighters (57 com o MPerl sob {$IFNDEF UNISYNEDIT}), não 54. Todos os 56 existem no pyscripter/SynEdit com os mesmos nomes de classe (TSynGWScriptSyn, TSynLDRSyn, TSynSMLSyn, TSynSTSyn, TSynDOTSyn, TSynURISyn, TSynVrml97Syn, TSynHP48Syn etc.).
- [REVISÃO] Protocolo: confirmado que não há impacto direto. ProjDependencies só LÊ GET_PROJECT_MODULE_LIST e compara o resultado com os nomes extraídos pelo lexer; os caminhos de UsedUnits vão ao servidor pelo fluxo normal de adicionar módulo do ProjAdmin. A conversão de encoding (UTF-16 no cliente novo x ANSI no servidor 2.5 Beta 3) dos nomes de módulo é transversal e pertence à família Midware/protocolo, não ao lexer. Mas um buffer Unicode decodificado errado gera nomes corrompidos, que acabariam enviados ao servidor.

#### Units

| Unit | Onde está | Condição | Status D13 | Substituto | Notas |
|---|---|---|---|---|---|
| SynEdit | Components\synedit.pas (SynEdit 2.0.x, CVS 1.457.2.12 de 2007, ANSI + edições Lazarus) | sempre | `atualizar-versao` | SynEdit.pas do pyscripter/SynEdit (Source) ou TurboPack master/GetIt SynEdit for VCL 2025.03 | A cópia local não compila no Delphi. Mudaram TSynEditMark.Create(AOwner), TSynEditMarkList (TObjectList, sem notificação), GutterWidth só leitura, e PaintTextLines usa GetTokenLength e SetLine em base 1. |
| SynEditHighlighter | Components\synedithighlighter.pas | sempre | `atualizar-versao` | SynEditHighlighter.pas (pyscripter/SynEdit ou TurboPack) | Create(AName, AFriendlyName) quebra o DiffHLProp; SetLine público faz DoSetLine+Next; GetExpandedToken* não existem mais e Get(Friendly)LanguageName são class functions abstratas. |
| SynEditTypes | Components\synedittypes.pas | sempre | `atualizar-versao` | SynEditTypes.pas (pyscripter/SynEdit) | TSynSearchOption e TBufferCoord continuam; TSynStatusChange(s) foi para SynEdit.pas. |
| SynEditSearch | Components\syneditsearch.pas | sempre | `atualizar-versao` | SynEditSearch.pas (pyscripter/SynEdit) | Existe no upstream; uso trivial. |
| SynEditMiscClasses | Components\syneditmiscclasses.pas | sempre | `atualizar-versao` | SynEditMiscClasses.pas (pyscripter/SynEdit) | Gutter reimplementado em bandas (TSynGutterBand, gbkCustom etc.); TSynGutter sem Width; TSynSelectedColor ganhou Opacity (padrão 115). |
| SynTextDrawer | Components\syntextdrawer.pas | sempre (transitivo) | `remover` | SynDWrite.pas (DirectWrite/Direct2D) do upstream; nenhuma ação no código do cliente | Substituída por SynDWrite (DirectWrite) no upstream; sem ação no código do cliente. |
| kTextDrawer | Components\ktextdrawer.pas | {$IFDEF SYN_CLX} (Kylix/CLX; o synedit.inc só define SYN_CLX com SYN_KYLIX): desligado | `remover` | — | Ramo CLX/Kylix, sem uso possível no D13 VCL. |
| SynEditKeyConst, SynEditMiscProcs, SynEditTextBuffer, SynEditKeyCmds, SynEditKbdHandler, SynEditStrConst, SynEditWordWrap | Components\ (syneditkeyconst.pas, syneditmiscprocs.pas, synedittextbuffer.pas, syneditkeycmds.pas, syneditkbdhandler.pas, syneditstrconst.pas, syneditwordwrap.pas) | sempre (transitivo) | `atualizar-versao` | mesmas units do pyscripter/SynEdit (todas existem em Source) | Transitivas do SynEdit; vêm com o pacote upstream. |
| SynHighlighterHashEntries | Components\synhighlighterhashentries.pas | sempre (transitivo) | `remover` | — | Não existe mais no upstream. |
| SynRegExpr | Components\synregexpr.pas | sempre (transitivo) | `remover` | System.RegularExpressions (RTL nativa), já usada pelo SynHighlighterMulti upstream (linha 48) | Substituída por System.RegularExpressions no SynHighlighterMulti upstream. |
| SynHighlighter* do Line History (56: ADSP21xx, Asm, AWK, Baan, Bat, CAC, Cache, Cobol, CPM, Cpp, CS, Css, Dfm, Dml, Fortran, Foxpro, Galaxy, General, GWS, Haskell, HC11, HP48, Html, IDL, Ini, Inno, Java, JScript, Kix, LDraw, M3, Modelica, Msg, Multi, Pas, Perl, PHP, Progress, Python, Ruby, SDD, Sml, SQL, ST, TclTk, TeX, UNIXShellScript, Unreal, VB, VBScript, XML, DOT, Eiffel, RC, URI, Vrml97) | Components\synhighlighter*.pas | sempre | `atualizar-versao` | Source\Highlighters do pyscripter/SynEdit (todos os 56 presentes, com os mesmos nomes de classe) | Todos os 56 existem no pyscripter/SynEdit com os mesmos nomes de classe; LanguageName agora é class function. |
| SynHighlighterMPerl | Components\synhighlightermperl.pas | {$IFNDEF UNISYNEDIT} (UNISYNEDIT não está definido em lugar nenhum do repo, então hoje está ATIVO) | `remover` | — | Não existe no upstream; apagar as duas referências (ligar UNISYNEDIT no compopt.inc não resolve). |
| SynHighlighter* do JEDIVCSDiff (28: Pas, General, HTML, Css, JScript, XML, Asm, VB, TclTk, SQL, Python, Progress, PHP, Perl, Bat, VBScript, M3, Java, Inno, Ini, Foxpro, Fortran, IDL, CPM, CAC, Cache, Cpp, Dfm) | Components\synhighlighter*.pas | sempre | `atualizar-versao` | Source\Highlighters do pyscripter/SynEdit | Propriedades streamadas continuam existindo; re-salvar o DiffMain.dfm com o pacote design-time instalado. |
| Units SynEdit não usadas (SynAutoCorrect, SynAutoCorrectEditor, SynCompletionProposal, SynDBEdit, SynEditAutoComplete, SynEditExport, SynEditKeyCmdEditor, SynEditKeyCmdsEditor, SynEditOptionsDialog, SynEditPlugins, SynEditPrint*, SynEditPropertyReg, SynEditPythonBehaviour, SynEditReg, SynEditRegexSearch, SynEditWildcardSearch, SynExportHTML/RTF/TeX, SynHighlighterManager, SynMacroRecorder, SynMemo, SynURIOpener) | Components\ | não usadas | `remover` | — | Fora do fecho transitivo do cliente; SynMemo e SynEditAutoComplete não existem mais. |
| mwPasLex | ausente (era src\comp\MwTools segundo Jedivcs.dof/JediVCSDLL.dof; também ausente no GitHub Libaud/JediVCS) | sempre em UsedUnits/ProjDependencies (ProjAdmin os usa nos dois ramos, linhas 1121-1126); {$IFDEF IDEDLL} em ToDo.pas, nas duas cópias (inativo no EXE); VerSet só existe e compila na DLL | `substituir` | CastaliaPasLex.pas (TmwPasLex) de jacobthurman/Castalia-Delphi-Parser, copiado e RENOMEADO (de preferência como mwPasLex.pas) em src\comp\mwtools; alternativa: DelphiAST SimpleParser.Lexer | Ausente no repo e no GitHub Libaud. Castalia tem a API usada; exige UseDefines := False e Origin = PChar de uma UnicodeString (não MS.Memory); renomear a cópia para mwPasLex.pas. |
| mwPasLexTypes | ausente (era src\comp\MwTools) | idem mwPasLex | `substituir` | CastaliaPasLexTypes.pas (TptTokenKind), renomeada (de preferência como mwPasLexTypes.pas) | Todos os tokens usados existem com a mesma grafia; IsTokenIDJunk não inclui ptIncludeDirect/ptResourceDirect. |
| JVCSLineHistoryHighlighterUnit (consumidor) | Jedi VCS Client\2.5\jedivcs\ e jedivcsdll\ (os .dpr apontam para ..\common\client\\, inexistente no repo) | sempre | `portar-codigo` | — | Remover SynHighlighterMPerl; o restante é compatível. |
| JVCSCompressedDiffSynProxy (consumidor) | jedivcs\ e jedivcsdll\ (..\common\client\\) | sempre | `portar-codigo` | — | Remover GetExpandedToken*, sobrescrever GetTokenLength (obrigatório, senão cores e realces somem) e corrigir a base da linha (SetLine em base 1). Retestar o diff inline. |
| JVCSCompressedDiffFrame (consumidor) | jedivcs\ e jedivcsdll\ (..\common\client\\) | sempre | `portar-codigo` | — | Trocar Gutter.Width por uma banda gbkCustom; o TGutterInfoPlugin pode continuar com Create(ASynEdit). |
| JVCSLineHistoryFrame (consumidor) | jedivcs\ e jedivcsdll\ (..\common\client\\; a cópia jedivcs só tem a mais o bloco {$ifdef FPC}{$MODE DELPHI}) | sempre | `portar-codigo` | — | Maior ponto de port: UpdateGutterWidth para banda gbkCustom (limpar as bandas padrão) e CurrentGutterWidth só via GutterWidth; AfterPaint(TCanvas) continua válido. |
| DiffMain / DiffHLProp / DiffEditorProp (consumidores JEDIVCSDiff) | Jedi VCS Client\2.5\jedivcsdiff\ | sempre | `portar-codigo` | — | DiffMain: TSynEditMark.Create(mwceSource) + InvalidateGutter e remover Gutter.Width do DFM. [REVISÃO] DiffHLProp: TSynHighlighterAttributes.Create com 2 parâmetros. |

### 3.8 Componentes pequenos e units ausentes

**Família no levantamento:** Componentes pequenos e units ausentes (DFS StatusBar/Kb, FavDlgs, mdMailSlot, TDiff/HashUnit, Checksum, StrUtilsD5, LOProp/LOPropIm/PrmProp, HtmlHlp, RegAcc, RekScan, Report, ExceptDlg, ItemProp, SortGrid, mwPasLex, InterfaceBase, units Lazarus dos .dpr, JVCSClient_TLB/JVCSComStream, ShareMem, MemCheck/FastMM4, Printers, ExtBugtracker) — inventário revisado

**Situação no Delphi 13.2:** `misto` · **Decisão:** `substituir-por-nativo` · **Esforço:** médio

**Pasta na v2026:**
- `src\comp\mdmailslot\mdmailslot.pas` e `src\comp\textdiff\{diffunit,hashunit}.pas`: já copiados, a portar.
- `src\comp\crc\Checksum.pas`: a recriar.
- `src\comp\mwtools`: lexer, ver 3.7.
- `src\jedivcs`: substitutos de `RekScan`, `ItemProp` e `ExtBugtracker` (este já em `src\jedivcs`).
- `src\jedivcsdiff`: helpers de registro no lugar do `RegAcc` e `HtmlHelpW` em `DiffHelp.pas`.

**Notas de consolidação:**
- **Base dos `.dpr`:** a v2026 já usa os `.dpr` de `ConverterBackup` (sem LCLIntf/LCLType/LMessages). Ainda referenciam FastMM4 (`Jedivcs.dpr:129`, `JEDIVCSDiff.dpr:54`, `jvcs.dpr:140`), e `src\comp\fastmm` não existe; remover.
- **Blowfish (crítico C5):** não está "sempre ativo"; ver 3.2.
- **mwPasLex (crítico C9):** usar o Castalia renomeado; o SVN do JVCS não existe mais.

#### Resumo

Nenhuma das units do inventário original participa do protocolo Midware com o servidor 2.5 Beta 3. Porém o inventário esqueceu a unit ausente Checksum (CRCInt/CRCString): o CRC32 que ela calcula vai ao servidor no check-in, fica gravado no banco e é comparado no checkout, no sync, em IsFileDirtyCRC e na busca por CRC. Por isso a reimplementação tem de reproduzir bit a bit o algoritmo antigo. Também foram corrigidos estes pontos: ItemProp não é referência morta (o LoadModule chama PerformDefaultAction para abrir o diálogo "Abrir com"); SortGrid é uma referência morta que ficou de fora; faltavam no inventário mwPasLex/mwPasLexTypes, FastMM4 e as units do Lazarus nos .dpr atuais (LCLIntf/LCLType/LMessages/Interfaces); e StrUtilsD5/ThemeSrv só ficam fora do build se não reaproveitarem o virtualtrees.pas/compilers.inc da pasta Components, que só reconhece compiladores até o Delphi 2009. O resto se confirma: a maioria tem substituto nativo no Delphi 13.2 (TStatusBar+TProgressBar, TOpenDialog/TSaveDialog, HtmlHelpW, TRegistry, FindFirst/FindNext, TRegEx). mdMailSlot, DiffUnit/HashUnit e Checksum exigem cópia local portada (Unicode/Win64). A JCL e o TextDiff (rickard67, commit de 10/08/2026) continuam mantidos e servem para o Delphi 13.

#### Fonte recomendada

Quase tudo vem da RTL/VCL do Delphi 13.2 Florence (também presente no 11/12): Vcl.ComCtrls (TStatusBar, TProgressBar com pbstMarquee), Vcl.Dialogs (TOpenDialog/TSaveDialog ou TFileOpenDialog/TFileSaveDialog), System.Win.Registry, System.SysUtils (FindFirst/FindNext), System.RegularExpressions, System.StrUtils, Vcl.Printers e a API HtmlHelpW (hhctrl.ocx) declarada localmente, ou Vcl.HtmlHelpViewer. Cópias locais portadas a partir do repo: Components\mdmailslot.pas (TmdMailSlot 1.17, sem upstream mantido) e Components\diffunit.pas + hashunit.pas (TDiff 2.5.1/HashUnit, Angus Johnson). Para o diff, a alternativa mantida é github.com/rickard67/TextDiff (src\Diff.pas, Diff_HashUnit.pas; último commit em 2026-08-10; API com TList&lt;Cardinal>). Reescrita própria e validada: Checksum.pas, mantendo o nome da unit. Créditos dizem que o CRC32 do FreeVCS veio de código sem autoria do "Turbo Pascal Programmers Page". Candidata: System.ZLib.crc32 (CRC-32 IEEE), que só pode ser adotada se bater com os CRCs já gravados no banco. Para mwPasLex 2.x (tokens pt*), o melhor é recuperar a versão original do SVN do JVCS (comp\mwtools); como plano B, adaptar DelphiAST SimpleParser.Lexer (MPL, TmwPasLex com NextNoJunk/TokenID/Token/Origin, sem LineNumber). JCL (ExceptDlg opcional, JclPCRE se mantido) pelo GitHub project-jedi/jcl, com suporte ao BDS37/RAD Studio 13 em jcl.inc; a instalação no 13 é pelo GitHub, ainda não pelo GetIt (comentário da Embarcadero de set/2025).

#### Alternativa nativa

Vale trocar quase tudo. (1) TdfsStatusBar vira TStatusBar com painéis psText/psOwnerDraw e um TProgressBar (pbstMarquee para gsIndeterminate2) com Parent no StatusBar. O gauge é usado em 3 forms: ProjAdmin.Panels[7], Syncronice.Panels[sbStatusText] e DiffMain.Panels[2]. Os demais recursos: sptEllipsisText via OnDrawPanel com DrawText DT_END_ELLIPSIS; clique e hint por painel via hit-test em OnMouseUp/OnMouseMove; o TJvLED do Syncronice continua com Parent no StatusBar. (2) TFavOpenDialog vira TOpenDialog. TFavSaveDialog descende de TFavOpenDialog, não de TSaveDialog, então troque explicitamente por TSaveDialog. Todos são criados em runtime, não há DFM para editar. O MRU de pastas (MaxCount/Favorites) passa para InitialDir + TJVCSMruList ou para TFileOpenDialog.FavoriteLinks. (3) HtmlHlp: declarar HtmlHelpW de hhctrl.ocx localmente é uma troca 1:1 da única chamada HH_HELP_CONTEXT. Vcl.HtmlHelpViewer + Application.HelpContext também funciona, mas há relatos de Ctrl+F/Ctrl+C quebrados no Win11. (4) RegAcc vira TRegistry com 4 helpers tolerantes a tipo, na mesma chave. (5) RekScan.FindRecursive vira uma unit própria com FindFirst/FindNext, ou TJvSearchFiles, que o SelectFolder já usa. (6) JclPCRE vira TRegEx. (7) ItemProp.PerformDefaultAction vira SHOpenWithDialog (Vista+, declarar localmente se Winapi.ShlObj não declarar) ou ShellExecute com o verbo 'openas'. (8) MemCheck/FastMM4 viram o FastMM embutido + ReportMemoryLeaksOnShutdown sob DEBUG. (9) StrUtilsD5 vira System.StrUtils. (10) ShareMem: dispensável com EXT_IDE_INTF, porque a API é plana e usa buffers do chamador. SimpleShareMem não ajuda, pois só compartilha quando os dois lados o usam, e o host da IDE não usa. Não há equivalente nativo para mailslot, para diff LCS nem para o CRC compatível. System.ZLib.crc32 só substitui o Checksum se for provado idêntico; a docwiki o marca como uso interno.

#### Destino proposto pelo inventário (texto original)

src\comp\mdmailslot (mdMailSlot.pas portado), src\comp\textdiff (DiffUnit.pas + HashUnit.pas portados, ou TextDiff do rickard67 com os chamadores adaptados) e src\comp\crc\Checksum.pas (reimplementação validada, com o mesmo nome da unit para não mexer em ~10 uses). Se nenhuma outra família cobrir mwPasLex, ele vai para src\comp\mwtools (mwPasLex.pas + mwPasLexTypes.pas). Units próprias: ExtBugtracker.pas com TRegEx em src\jedivcs (e no search path da DLL), RekScan reescrita em src\jedivcs ou src\common\client, e DiffHelp.pas com HtmlHelpW mais o substituto do RegAcc em src\jedivcsdiff. Alternativa aceitável para mexer menos no código: recriar RekScan.pas, RegAcc.pas e ItemProp.pas como shims com os mesmos nomes em src\comp\unknown. Ficam fora do v2026: dfsStatusBar, DFSKb, DFS.INC, FavOpenDialog, myfdlg.res, StrUtilsD5, LOProp/LOPropIm/PrmProp, MemCheck.pas, FastMM4, SortGrid, ThemeMgr/ThemeSrv, Components\virtualtrees.pas/compilers.inc e as units do Lazarus nos .dpr. Base dos .dpr: ConverterBackup\\\*.dpr.

#### Riscos

- As cópias em Components\ foram editadas no port Lazarus. Em favopendialog.pas, o TaskModalDialog está com o corpo comentado e o Template só é atribuído sob {$ifdef VCL}. Em dfsstatusbar.pas, HookMainWindow/RTLConsts ficam sob {$ifdef VCL}, ConstsExt vem do Lazarus e falta DFS.INC. Não reaproveite essas cópias como estão.
- jedivcs\VCSProcBase.pas (versão Lazarus) tem a chamada HtmlHelp comentada e o HtmlHlp sob {$ifdef VCL}: a ajuda nunca abre. Use como base jedivcsdll\VCSProcBase.pas.
- mdMailSlot sob Unicode: SendBufSecure/SendSecureMail usam Length(Mail) sobre UTF-16 e o cabeçalho de 8 chars vira 16 bytes, o que trunca e desalinha a mensagem. O CalcCRC16 indexa a tabela com Ord(WideChar). É preciso portar para AnsiString/PAnsiChar mantendo o formato 4 hex + 4 hex CRC + dados ANSI, compatível com clientes 2.5 e com o notificador. Só afeta a comunicação entre clientes, não o servidor.
- Mailslots remotos (broadcast '*') vêm desabilitados por padrão no Windows 11 24H2/Server 2025 e estão deprecados. Mailslot local (mesma máquina) continua funcionando. A notificação entre máquinas deve ficar como legado; o SMTP é a alternativa.
- DiffUnit/HashUnit em Win64: JVCSCompressedDiffUnit/JVCSLineHistoryUnit fazem PIntArray(TList.List) sobre ponteiros de 8 bytes, enquanto o TDiff lê Integer de 4. O diff sai errado em silêncio. Isso importa se a DLL de IDE tiver de ser 64-bit para a IDE 64-bit.
- REPORTDLL continua ligado. Um jedivcsreport.dll antigo (Delphi 7–XE2) na pasta seria carregado com TApplication/TScreen de outra RTL e daria access violation. O fonte do jedivcsreport não está no repo. Não distribua a DLL antiga.
- Trocar TdfsStatusBar por TStatusBar exige editar os DFMs de ProjAdmin, Syncronice e DiffMain: tirar PanelType, GaugeAttrs, Enabled, AutoFit, Hint e OnClick dos painéis. Os eventos por painel precisam ser religados por hit-test.
- O substituto do RegAcc deve manter HKCU\Software\JEDI\JEDIVCSDiff\ e os nomes SReportTarget/SReportShow/FileDlgMRU.
- Remover o ShareMem só é seguro com EXT_IDE_INTF. Se for mantido, ele deve ser a primeira unit do uses (como no .dpr original) e o borlndmm.dll precisa ter a mesma bitness do host.
- Fora do foco: TdfsEnhListView (EnhListView) e TdfsSystemTreeView/SystemControlPack também estão ausentes e são esforço bem maior (família listviews/DFS).
- [REVISÃO] Unit ESQUECIDA e crítica para compatibilidade: Checksum (ausente do repo e do servidor; search path comp\crc). CRCInt(FileName, Err) é enviado ao servidor no check-in como 'orig. crc' (ChkInSingle.pas:1636) e comparado com o CRC arquivado em ChkOutSingle:800, JVCSChkInOutCommon:445, IsFileDirtyCRC (JVCSClientFunctions:261-274), GetArchiveCRC/ProjAdmin, syncproject 'crc' do console e TJVCSSearchModuleRevisionsByCrc. Se o novo algoritmo (polinômio, valor inicial, XOR final, Integer com sinal, formatação IntToHex(…,8) e CRCString com '$') diferir do antigo, todos os módulos aparecem como modificados e a busca por CRC deixa de achar revisões. Antes de adotar System.ZLib.crc32, valide contra CRCs já gravados no banco Firebird ou gerados pelo cliente 2.5 Beta 3.
- [REVISÃO] ItemProp NÃO é referência morta: LoadModule.pas:347 (EXE e DLL) chama PerformDefaultAction(ShortModulName, WH) quando não há aplicativo associado à extensão (diálogo 'Abrir com'). Nada no repo define essa função. Só tirar do uses quebra o build; substitua por SHOpenWithDialog ou ShellExecute com 'openas'. No DiffMain.pas:469, sim, é referência morta.
- [REVISÃO] Unit esquecida: SortGrid (ausente), que aparece só no uses de History.pas:79 (EXE e DLL), sem nenhum TSortGrid no .pas/.dfm. Remover do uses.
- [REVISÃO] Units esquecidas: mwPasLex/mwPasLexTypes (ausentes; search path ..\comp\mwtools), usadas de fato em ProjDependencies, ToDo e UsedUnits (TmwPasLex, tokens pt*, NextNoJunk, Origin, LineNumber). PasParser.Origin := MS.Memory aponta para os bytes ANSI do arquivo como PChar: sob Unicode o lexer lê lixo, então é preciso converter para string antes. O SimpleParser.Lexer do DelphiAST não tem LineNumber. Se outra família (parser/mwTools) já cobre, consolidar; senão, entra aqui.
- [REVISÃO] Os .dpr atuais NÃO são os originais: jedivcs\Jedivcs.dpr, jedivcsdll\JediVCSDLL.dpr e jedivcsdiff\JEDIVCSDiff.dpr têm LCLIntf, LCLType e LMessages sem condição (units do Lazarus, inexistentes no Delphi). A DLL também troca ShellExecute por OpenDocument (LCL, ~linha 2254) e tira ShareMem da 1ª posição. Base correta: ConverterBackup\\\*.dpr (o original tem ShareMem primeiro na DLL e FastMM4 no EXE, no Diff e no console).
- [REVISÃO] FastMM4 (ausente; .dpr originais do EXE, Diff e console) não estava no inventário. Remover e usar o MM embutido. Atenção à licença do FastMM5: GPL v3 ou comercial, incompatível com distribuir binário de projeto MPL 1.1 sem licença comercial. Use FastMM4 (MPL/LGPL) ou FastMM5 apenas em depuração local.
- [REVISÃO] StrUtilsD5 'nunca compilado' é condicional: Components\compilers.inc só reconhece até VER200 (Delphi 2009), então no Delphi 13 nem DELPHI_6_UP nem COMPILER_7_UP são definidos. Se Components\virtualtrees.pas + compilers.inc forem reaproveitados, StrUtilsD5 (que depende do ausente JvGnugetTextD5) e ThemeSrv/TMSchema SÃO compilados e o build falha. Use o VirtualTreeView oficial (família VTV) e descarte esses arquivos.
- [REVISÃO] TFavSaveDialog = class(TFavOpenDialog), não TSaveDialog: 'trocar só o nome da classe' vale para TFavOpenDialog→TOpenDialog. Para salvar, use TSaveDialog. MaxCount/Favorites são usados em ExecuteFavOpenDialogWithMru e em DiffSimpleReport (linhas 267/496/756) e precisam ser reescritos. Os diálogos são criados só em runtime, sem DFM.
- [REVISÃO] O gauge do dfsStatusBar também é usado no Syncronice (ShowStatusBarGauge/StatusBarGaugePos em Panels[sbStatusText]), não só o painel owner-draw: são 3 forms com gauge.
- [REVISÃO] HtmlHlp: prefira HtmlHelpW declarado localmente, troca 1:1 do PerformHelpCommand/ShowHelpContext. Com Vcl.HtmlHelpViewer + Application.HelpContext há relatos (Delphi 11/Win11) de Ctrl+F/Ctrl+C não funcionarem. Um CHM aberto de compartilhamento de rede ou baixado com MOTW também é bloqueado pelo Windows.
- [REVISÃO] SimpleShareMem não serve aqui: só compartilha o MM quando EXE e DLL o usam. O host que carrega JediVCSDLL (pacote expert de IDE que chama JEDIVCSDLLINIT) NÃO está no repo. A interface do JVCSIDEInterfaceCommon usa PAnsiChar, mas os exports de histórico e operações usam PChar (=PWideChar no Delphi 13). O host precisa casar (fora desta família).
- [REVISÃO] EXT_IDE_INTF (e IDEDLL) precisam constar no novo .dproj da DLL. Sem eles, o caminho OLDOTA/INTERNAL_OLDOTA puxa ToolIntf/VCSIntf/EditIntf, units da Open Tools API antiga que não existem no Delphi 13.
- [REVISÃO] mdMailSlot tem mais problemas: SendToWinpopup só protege VER200, e no Delphi 13 CharToOEM(PChar(S), PChar(S)) não compila (destino LPSTR). Com $R+ (DEBUG está ligado no compopt.inc), o CalcCRC16 gera ERangeError, que é engolido e devolve CRC 0.
- [REVISÃO] Não dá para confirmar os tipos de valor gravados pelo RegAcc (unit ausente). TRegistry.ReadBool/ReadInteger lançam ERegistryException se o tipo não bater: leia com try/except e valor padrão.
- [REVISÃO] ExtBugtracker: o search path do JediVCSDLL.dof não inclui ..\jedivcs (inclua o caminho ou copie a unit). TRegEx.Match(...).Groups['bug'] lança exceção se a regex do usuário não tiver o grupo nomeado: proteja com try/except.
- [REVISÃO] RekScan (semântica inferida dos callbacks, a unit não existe): Path deve chegar com barra final e na mesma grafia da raiz passada. O CompareFolders compara rcbxBaseFolder.Text com Path diretamente e faz Delete(1, Length(raiz)). Só arquivos são reportados; False aborta tudo (resposta 'Não' ao aviso de 500 arquivos); os arquivos da pasta vêm antes das subpastas.
- [REVISÃO] Fora desta família mas igualmente ausente e crítico para dados: BFCrypt (BlowFishEncode/Decode dos blobs em HandleBlob, ChkInSingle, Create, Options; Blowfish sempre ativo desde 2010). Confirme que a família de criptografia o cobre.
- [REVISÃO] O tópico do DelphiPraxis sobre TDiff em 64-bit não confirma a causa raiz, só recomenda o TextDiff do rickard67. A causa PIntArray(TList.List) é análise deste código, não do tópico.

#### Units

| Unit | Onde está | Condição | Status D13 | Substituto | Notas |
|---|---|---|---|---|---|
| dfsStatusBar | Components\dfsstatusbar.pas (TdfsStatusBar v1.24, editada para Lazarus; DFS.INC ausente no repo) | sempre | `substituir` | Vcl.ComCtrls.TStatusBar (psText/psOwnerDraw) + TProgressBar (pbstNormal/pbstMarquee) com Parent no StatusBar; OnDrawPanel com DrawText DT_END_ELLIPSIS; clique e hint por painel via OnMouseUp/OnMouseMove | Gauge usado em 3 forms (ProjAdmin, Syncronice, DiffMain); a cópia local depende de DFS.INC ausente e tem caminhos VCL desligados. |
| DFSKb | Components\dfskb.pas | sempre (só via dfsStatusBar) | `remover` | — | Hook de teclado para painéis Caps/Num/Scroll, que o JVCS não usa. |
| FavOpenDialog | Components\favopendialog.pas (TFavOpenDialog = class(TOpenDialog); TFavSaveDialog = class(TFavOpenDialog); v0.2 de Markus Stephany, editado pelo JVCS e pelo Lazarus) | sempre ({$ifdef JCLVER_2_UP} JclOpenDialogFavorites em jedivcsdll\VCSProcBase nunca é definido; a JCL atual não define JCLVER_*) | `substituir` | TOpenDialog no lugar de TFavOpenDialog; TSaveDialog no lugar de TFavSaveDialog (troca explícita: não é descendente); InitialDir + TJVCSMruList para o MRU; opcional TFileOpenDialog/TFileSaveDialog.FavoriteLinks | [REVISÃO] TFavSaveDialog não descende de TSaveDialog; MaxCount/Favorites precisam ser reescritos. Todos os diálogos são criados em runtime. |
| myfdlg.res | Components\myfdlg.res (template MYDLGO + bitmaps FAVFOLD/FAVNOFOLD/FAVOVL) | sempre (via FavOpenDialog) | `remover` | — | Sai junto com o FavOpenDialog. |
| mdMailSlot | Components\mdmailslot.pas (Martin Djernæs, TmdMailSlot/TmdSecureMail 1.17) | sempre compilado; envio/recepção em runtime dependem de NotifyActive/Internal Notify | `portar-codigo` | Cópia local portada (AnsiString/RawByteString/PAnsiChar, tamanhos em bytes, NativeInt) mantendo o formato na rede; alternativa crua: CreateMailslot/WriteFile da Win32 | Bug Unicode no envio/CRC16 quebra a compatibilidade com clientes 2.5 e o notificador; CharToOEM não compila no D13. Mailslot remoto vem desabilitado no Windows 11 24H2. |
| DiffUnit | Components\diffunit.pas (TDiff 2.5.1, Angus Johnson, 22/06/2005, 'Delphi 3 - Delphi 7') | sempre | `portar-codigo` | Cópia local com os chamadores passando arrays de Integer/Cardinal (TArray&lt;Integer>) em vez de PIntArray(TList.List); alternativa: rickard67/TextDiff (Execute com TList&lt;Cardinal> ou strings, API renomeada) | Em Win32 funciona; em Win64 os chamadores passam ponteiros de 8 bytes como PIntArray (diff errado em silêncio). |
| HashUnit | Components\hashunit.pas (Angus Johnson) | sempre | `portar-codigo` | Cópia local: CalcCRC32 sobre Length(s)*SizeOf(Char) bytes (ou UTF-8), retornando Cardinal em vez de Pointer | HashLine lê só metade dos bytes da string UTF-16 (mais colisões); hashes só em memória. |
| Checksum | ausente (search path comp\crc; FreeVCS, 'CRC32 baseado em código do Turbo Pascal Programmers Page' segundo credits.txt; o console trocou crc32.pas por checksum.pas em 2003) | sempre (no port Lazarus sob {$ifdef BORLAND}) | `portar-codigo` | Reimplementar CRCInt(const FileName: string; var Err: string): Integer e CRCString(const FileName: string): string (formato '$XXXXXXXX') com algoritmo idêntico ao antigo. Testar System.ZLib.crc32 (CRC-32 IEEE) contra CRCs reais do banco antes de adotar. | [REVISÃO] Esquecida pelo inventário inicial e a única desta família com impacto em dados/protocolo: CRC gravado no servidor e comparado em checkout, sync, dirty-check e busca por CRC. |
| StrUtilsD5 | Components\strutilsd5.pas | {$IFNDEF DELPHI_6_UP}; [REVISÃO] com Components\compilers.inc (só conhece até VER200), DELPHI_6_UP NÃO é definido no Delphi 2010+, então seria compilado se essa cópia do VTV fosse reaproveitada | `remover` | System.StrUtils (via VirtualTreeView oficial) | Depende do JvGnugetTextD5 ausente; só seria compilada se Components\virtualtrees.pas fosse reaproveitado. |
| LOProp | Components\LOProp.pas/.dfm (editor de propriedade da Midware) | nenhum uso no cliente (design-time, DesignIntf) | `remover` | — | Design-time da Midware; não pode ser linkado em runtime. |
| LOPropIm | Components\LOPropIm.pas/.dfm | nenhum uso no cliente | `remover` | — | Design-time da Midware (usa BDE). |
| PrmProp | Components\PrmProp.pas/.dfm | nenhum uso no cliente | `remover` | — | Design-time da Midware. |
| HtmlHlp | ausente (tradução da API HtmlHelp de Marcel van Brakel/JEDI) | sempre na DLL e no Diff; no EXE da pasta jedivcs sob {$ifdef VCL} | `substituir` | Declaração local de HtmlHelpW (hhctrl.ocx) + HH_HELP_CONTEXT = $000F (troca 1:1). Alternativa: Vcl.HtmlHelpViewer + Application.HelpFile/HelpContext | [REVISÃO] HtmlHelpW direto é preferível (relatos de Ctrl+F/Ctrl+C quebrados com HtmlHelpViewer no Win11); CHM em rede ou com MOTW é bloqueado. |
| RegAcc | ausente (helper de registro do FreeVCS) | sempre (Diff) | `substituir` | System.Win.Registry (TRegistry) com 4 helpers locais tolerantes a tipo, ou ConfigStorage (jvcsReadInteger/jvcsWriteBool), já presente no Diff | Manter a chave HKCU\Software\JEDI\JEDIVCSDiff\ e os nomes de valor; ler com try/except porque o tipo gravado não é verificável. |
| RekScan | ausente | sempre | `substituir` | Unit própria FindRecursive(const Path, Mask: string; LogFunction: TLogFunct): Boolean com FindFirst/FindNext, ou TJvSearchFiles, que o SelectFolder já usa | Semântica inferida: False aborta, arquivos antes das subpastas, Path com barra final e na grafia da raiz. |
| Report | ausente | {$IFNDEF REPORTDLL}: REPORTDLL está definido no compopt.inc (no da pasta jedivcs dentro de {$ifdef DELPHI}, que vem do jedi.inc), então nunca é compilado | `remover` | — | Nunca compilado com REPORTDLL; não distribuir jedivcsreport.dll antiga. |
| ExceptDlg | ausente (template da JCL) | {$IFDEF JCL_DEBUG_DATA}: não definido em nenhum .inc/.dof | `remover` | Opcional: ExceptDlg.pas/.dfm da JCL atual (jcl/experts/repository/ExceptionDialog/StandardDialogs) + JclDebug | Manter desligado no port inicial. |
| ItemProp | ausente | sempre | `substituir` | SHOpenWithDialog (shell32, Vista+, OPENASINFO com OAIF_EXEC; declarar localmente se Winapi.ShlObj não declarar) ou ShellExecute(WH, 'openas', ...); retirar do uses do DiffMain | [REVISÃO] Não é referência morta: LoadModule chama PerformDefaultAction ('Abrir com'). No DiffMain é morta. |
| SortGrid | ausente | sempre (referência morta: nenhum TSortGrid no .pas nem no .dfm) | `remover` | Retirar do uses | [REVISÃO] Esquecida; sem a unit o build falha só pelo uses. |
| mwPasLex / mwPasLexTypes | ausente (search path ..\comp\mwtools; TmwPasLex 2.x de Martin Waldenburg, MPL) | sempre | `portar-codigo` | mwPasLex 2.x original (SVN do JVCS) portado para Unicode; plano B: DelphiAST SimpleParser.Lexer/SimpleParser.Lexer.Types (TmwPasLex, TptTokenKind), adaptando LineNumber | [REVISÃO] Esquecida; ver família SynEdit (CastaliaPasLex renomeado). Origin := MS.Memory é bug Unicode no chamador. |
| InterfaceBase | LCL (Lazarus), não existe no Delphi | {$ifdef LCL}: nunca no Delphi | `remover` | — | [REVISÃO] Também em jedivcs\JVCSDialogs.pas sob {$ifdef LCL}. |
| LCLIntf / LCLType / LMessages / Interfaces (Lazarus) | LCL (Lazarus), não existe no Delphi | LCLIntf/LCLType/LMessages SEM condição nos .dpr atuais; Interfaces sob {$ELSE} de FPC/WINDOWS | `remover` | Usar como base os ConverterBackup\\\*.dpr originais (ShareMem primeiro na DLL; ShellExecute no lugar de OpenDocument) | [REVISÃO] Esquecidas; a v2026 já usa os .dpr de ConverterBackup. |
| ThemeMgr / ThemeSrv | ausente (ThemeMgr: Soft Gems); Components\themesrv.pas | ThemeMgr nunca com o jedi.inc moderno (DELPHI7_UP definido); ThemeSrv seria compilado se Components\virtualtrees.pas + compilers.inc antigo fossem usados | `remover` | Vcl.Themes + manifest (nativo) | O tema nativo do D13 (manifest + Vcl.Themes) cobre. |
| ToolIntf / VCSIntf / EditIntf (OTA antiga) | ausente (removidas do Delphi moderno) | só sem EXT_IDE_INTF; o JediVCSDLL.dof define IDEDLL;EXT_IDE_INTF | `remover` | Manter EXT_IDE_INTF e IDEDLL definidos no novo .dproj | [REVISÃO] Se EXT_IDE_INTF se perder na migração .dof→.dproj, o build cai no caminho antigo, que não compila. |
| JVCSClient_TLB | ausente | {$IFDEF COMVERSION}: não definido em lugar nenhum (JVCSClientObj só inclui jedi.inc) | `remover` | — | Interfaces COM opcionais (COMVERSION desligado), sem relação com o protocolo. |
| JVCSCOMStream | ausente | {$IFDEF COMVERSION}: não definido | `remover` | — | Mesmo caso do JVCSClient_TLB. |
| ShareMem | RTL (System.ShareMem + borlndmm.dll) | sempre (DLL) | `funciona` | Remover com EXT_IDE_INTF (API plana com buffers do chamador); não usar SimpleShareMem | [REVISÃO] SimpleShareMem não serve (o host não o usa). Se mantido, ShareMem deve ser a 1ª unit e a borlndmm.dll da mesma bitness. |
| MemCheck | jedivcs, jedivcsdll e jedivcsdiff\MemCheck.pas (3 cópias idênticas por MD5, v2.67, asm x86) | nenhuma unit nem .dpr a usa. O define MEMCHECK (via {$IFOPT D+}) só liga $W+ e USE_JEDI_JCL | `remover` | ReportMemoryLeaksOnShutdown := True sob {$IFDEF DEBUG}; FastMM4 FullDebugMode só em depuração | Nenhum uses; usar ReportMemoryLeaksOnShutdown sob DEBUG. [REVISÃO] Não usar FastMM5 em binário distribuído (GPL v3/comercial). |
| FastMM4 | ausente (comp\fastmm) | sempre nos .dpr originais (removido nos editados pelo Lazarus) | `remover` | Gerenciador de memória embutido (FastMM desde o D2006) | [REVISÃO] Esquecida; usar o MM embutido (FastMM4 só em depuração). |
| Printers | RTL/VCL (Vcl.Printers) | sempre | `funciona` | — | Resolve via unit scope names (Vcl.Printers). |
| ExtBugtracker | jedivcs\ExtBugtracker.pas (2012; sem cópia em jedivcsdll) | sempre | `portar-codigo` | System.RegularExpressions: TRegEx.Match(S, sBugtrackerRegEx) e Groups['bug'].Value no lugar de JclPCRE.TJclRegEx | TRegEx elimina pcre3.dll; [REVISÃO] o .dof da DLL não tinha ..\jedivcs no search path e Groups['bug'] precisa de try/except. |
| EnhListView / SystemTreeView / SystemControlPack (DFS, fora do foco) | ausente (TdfsEnhListView 3.72, TdfsSystemTreeView 0.98.5) | sempre | `incerto` | Avaliar na família DFS/listviews (TListView vsReport, JvListView ou VTV) | Fora do foco desta família; tratado na família VirtualTreeView/DFS. |

### 3.9 Integração com a IDE (DLL / ToolsAPI)

**Família no levantamento:** Integração com a IDE (DLL / ToolsAPI)

**Situação no Delphi 13.2:** `misto` · **Decisão:** `portar-copia-local` · **Esforço:** alto

**Pasta na v2026:**
- `src\jedivcs`: `JediVCSDLL.dpr` (de `ConverterBackup`) e as units só da DLL (`JVCSIDEInterface`, `JVCSDLLOperations`, `JVCSDLLFileHistoryImpl`, `JVCSDLLLineHistoryFrame`, `Recent`, `UsedComponents`, `VerSet`, `CURSORS.RES`), como já está no manifesto. A família propunha `src\jedivcsdll`, que não foi adotado.
- `src\common`: `JVCSIDEInterfaceCommon.pas` e `JVCSIDESettings.pas`.
- `src\jvcsideexpert` (nova): expert ToolsAPI.
- `setup\`: instalador/registro das chaves `Experts`.

**Notas de consolidação:**
- **Nome do arquivo da DLL (crítico C10):** o código usa `library JediVCSDLL` e `cJVCSFileName = 'jedivcsdll.dll'` (`src\jedivcs\VCSBase.pas:113`), mas o binário instalado pelo 2.5.0.1030 é `JvcsExternalDll.dll` (cópia em `3rdparty\referencia-2.5.0.1030`, junto com os experts `JvcsExpertBDS19/20/21.dll`). Fixar no `.dproj` o mesmo nome que o novo expert carrega.
- **Win64 (crítico C6):** está **bloqueado**, não só adiado, até a FVCSCrypt ser reimplementada ou isolada num processo de 32 bits.
- **ShareMem (crítico C7):** remover só depois de desligar REPORTDLL e testar dentro do `bds.exe`; manter como plano B.

#### Resumo

A integração tem duas camadas. A primeira é a JvcsExternalDll.dll, gerada pelo JediVCSDLL.dpr com IDEDLL;EXT_IDE_INTF (mais LANGUAGE;DEBUG;DelphiPersonalEdition no .dof). Ela contém o cliente inteiro e exporta JEDIVCSDLLINIT, JEDIVCSDLLFINALIZE, JEDIVCSDLLHISTORYINIT e JEDIVCSDLLOPERATIONINIT, numa ABI stdcall/PAnsiChar definida em JVCSIDEInterfaceCommon.pas. A segunda é um expert fino, um binário por IDE (jvcside_dxwizard.dpr, instalado como JvcsExpertBDSnn.dll), registrado na chave Experts. O fonte desse expert ficava no servidor JVCS privado (src\jedivcside\delphi_wizard) e não está no GitHub nem no SourceForge, então precisa ser reescrito com a ToolsAPI nativa: o Delphi 13 não tem VCSIntf/VCSManager, mas carrega experts por INITWIZARD0001 nas chaves "Experts" e "Experts x64". Do lado da DLL, o port exige: ABI Unicode/ANSI explícita, remoção do ramo OLDOTA e das edições Lazarus, correção do JVCSIDESettings, e uma decisão sobre REPORTDLL. O REPORTDLL está ATIVO por padrão e depende de uma jedivcsreport.dll sem fonte, e o ramo alternativo, que usa TVCSReport, não compila. A família não altera o protocolo com o servidor 2.5 Beta 3, mas há dois riscos de compatibilidade de dados/protocolo: (1) usar as cópias das units da pasta jedivcs, que têm o tratamento de erros do cliente comentado pelo port Lazarus; (2) o novo expert devolver um nome de projeto diferente do expert 2.5.0.1030.

#### Fonte recomendada

Código próprio do repositório, sem nada a obter via GetIt.

DLL:

- Partir de "Jedi VCS Client\2.5\jedivcsdll\ConverterBackup\JediVCSDLL.dpr" (original Delphi, em ISO-8859). Ele difere do atual só em três pontos: Interfaces, LCLIntf/LCLType/LMessages e OpenDocument no lugar de ShellExecute.
- Usar as units da PRÓPRIA pasta jedivcsdll: JVCSIDEInterface, JVCSIDEInterfaceCommon, JVCSIDESettings, JVCSDLLOperations, JVCSDLLFileHistoryImpl, Recent, UsedComponents e VerSet. As units compartilhadas com o EXE também devem vir das cópias de jedivcsdll, não das de jedivcs (ver riscos).

Expert:

- Reescrever com a ToolsAPI/DesignIDE do Delphi 13.2: designide.dcp em Studio\37.0\lib\win32\release, unidades ToolsAPI e FileHistoryAPI.
- Usar {$IF CompilerVersion} para gerar também BDS22 (designide280) e BDS23 (designide290).

Referência de comportamento:

- jvcs_directories.txt (nomes jvcside_dxwizard.dpr e jvcside_dxvcsintf.dpr).
- Binários 2.5.0.1030 do instalador JVCSv2.50ClientSetupBeta3_Refresh_till_10_4Sydney.exe (SourceForge, "2.5x Beta 3/Client", 07/02/2021). É o último setup publicado: não existe nenhum para 11, 12 ou 13.

#### Alternativa nativa

Sim. Vale trocar toda a OTA antiga (VCSIntf/ToolIntf/EditIntf) pela ToolsAPI nativa no expert. Interfaces, todas conferidas no source\ToolsAPI do 37.0:

- IOTAWizard (WizardEntryPoint = 'INITWIZARD0001').
- INTAServices para o menu e as TAction. Para ícones em HighDPI, usar INTAServices280.AddImage(nome, TGraphicArray). A ABI GetVerbImages já aceita largura e altura, então dá para pedir 16, 24 e 32 px.
- IOTAIDENotifier/50/80 para eventos de arquivo e de compilação.
- IOTAProjectMenuItemCreatorNotifier via IOTAProjectManager.AddMenuItemCreatorNotifier. AddMenuCreatorNotifier/INTAProjectMenuCreatorNotifier estão marcados como deprecated.
- IOTAKeyboardBinding para os atalhos, eliminando o hook WH_KEYBOARD.
- IOTAModuleServices/IOTASourceEditor/IOTAEditReader/IOTAEditWriter/IOTAFormEditor para ler e gravar fonte e componentes.
- IOTAServices (GetBaseRegistryKey/GetRootDirectory) para alimentar o JVCSIDESettings.

[REVISÃO] IOTAFileHistoryManager e IOTAFileHistoryProvider ficam na unit FileHistoryAPI, não na ToolsAPI. São IDispatch/safecall com WideString e alimentam a aba History (historyide370.bpl). A mesma unit oferece IOTAAsynchronousAnnotationProvider e IOTAAnnotationLineProvider ("blame" na aba History). É o substituto nativo correto para o JVCSDLLLineHistoryFrame, em vez de INTACustomEditorView. Atenção: as variantes assíncronas rodam fora da thread principal, e a DLL usa Midware/ICS, que exigem a thread principal.

O plugin no framework Version Insight (IOTAVersionControlServices/Notifier, como gitide370/hgide370/svnide370) seria o caminho mais nativo, mas fica para uma fase 2. Não recomendo transformar o cliente inteiro num BPL design-time, por conflito de JVCL/JCL/SynEdit/ICS com os pacotes já instalados. Manter a arquitetura expert fino + DLL isolada. O expert fino pode ser DLL (chave Experts) ou BPL (Known IDE Packages); os dois são por versão de IDE.

A IDE 64 bits do 13 não compila nem depura alvos Win32. Portanto não substitui a IDE 32 bits para quem mantém projetos Win32.

#### Destino proposto pelo inventário (texto original)

Três destinos dentro de v2026 (a pasta já existe e está vazia):

- src\jedivcsdll: JediVCSDLL.dpr (gera bin\client\JvcsExternalDll.dll), JVCSIDEInterface.pas, JVCSDLLOperations.pas, JVCSDLLFileHistoryImpl.pas, e as units que só existem na DLL: Recent.pas, UsedComponents.pas, VerSet.pas, e cursors.res (copiar de jedivcs).
- src\common: JVCSIDEInterfaceCommon.pas e JVCSIDESettings.pas, onde o .dpr original espera ('..\common\\'). Ficam compartilhadas com o expert.
- src\jvcsideexpert (novo): JVCSIDE_DxWizard.dpr, JVCSIDEWizard.pas, JVCSIDEFileHistoryImpl.pas e JVCSIDEProjectMenuImpl.pas. Gera bin\client\JvcsExpertBDS22.dll, JvcsExpertBDS23.dll e JvcsExpertBDS37.dll; x64 numa fase 2.

As units do núcleo compartilhadas entre EXE e DLL devem vir das cópias de jedivcsdll. Não levar JVCSDLLLineHistoryFrame.pas nem as units de registro design-time de terceiros em Components\\.

#### Riscos

- O fonte do expert (jvcside_dxwizard.dpr, em src\jedivcside\delphi_wizard no servidor JVCS privado vcs.delphi-jedi.org) não está no repositório nem no SourceForge. É preciso reescrevê-lo a partir dos records de JVCSIDEInterfaceCommon.pas e do comportamento do binário 2.5.0.1030. Mapear: TIDEFileNotification, menu, imagens, atalhos, provider de History e menu do Project Manager.
- [REVISÃO] Compatibilidade de dados com o servidor 2.5 Beta 3: o nome do projeto JVCS é ExtractFileName(IDEInterface.GetProjectName) (JediVCSDLL.dpr 773–953; IsIDEProject aceita .dpr/.bpg/.bdsproj/.cbproj/.dproj). Se o novo expert devolver um arquivo diferente do que o expert 2.5.0.1030 devolvia (ex.: .dproj em vez de .dpr), os projetos já cadastrados no servidor não serão encontrados ou serão duplicados. É preciso validar com o binário antigo antes.
- [REVISÃO] Protocolo/consistência: 83 das 135 units comuns entre jedivcs e jedivcsdll diferem. As cópias de jedivcs têm edições do port Lazarus que desligam lógica. Em JVCSClientObjBase.pas estão comentados o inherited RequestDone, o raise EJVCSClient (SRequestFailed) e o CopyFromReference; em VCSProcBase.pas estão comentados HtmlHelp e Printer.GetPrinter. Erros do servidor seriam engolidos. A DLL (e o v2026 unificado) deve usar as cópias de jedivcsdll como base.
- A ABI expert↔DLL é ANSI (PAnsiChar). Em Delphi 13, JediVCSDLL.dpr, JVCSDLLOperations, JVCSDLLFileHistoryImpl, JVCSDLLLineHistoryFrame e TExternalIDEInterface passam PChar=PWideChar onde se espera PAnsiChar, o que dá E2010 (tipos incompatíveis); a revisão citava E2009 por engano. Nomes de arquivo fora do code page ANSI se perdem.
- [REVISÃO] Nem todos os pontos geram erro de compilação: compopt.inc liga {$T-}. Por isso as chamadas FFuncRecPtr.GetProjectName(@LProjectName) e similares, com 'array[0..255] of Char', compilam em silêncio com buffers de WideChar. No D13, StrPas tem overloads PAnsiChar (deprecated) e PWideChar (System.SysUtils, linhas 2054/2056), então StrPas(@buf) fica ambíguo ou lê errado. É preciso declarar os buffers como AnsiChar explicitamente e tratar o SourceReadString (GetMem em bytes + PByteArray).
- Os buffers fixos de 256 chars não levam tamanho no protocolo: caminhos longos causam overflow ou truncamento. Numa ABI v2, incluir o tamanho do buffer e a versão do record, com exports novos (ex.: JEDIVCSDLLINIT2).
- O JediVCSDLL.dpr atual tem LCLIntf, LCLType e LMessages fora de IFDEF (linha 223) e OpenDocument no lugar de ShellExecute; também removeu ShellAPI do uses. Usar a cópia em ConverterBackup, que está em ISO-8859.
- JVCSIDESettings.pas, linha 95: {$ifdef WINDOWS} não é definido pelo Delphi nem pelo jedi.inc, então o uses vira ', JclFileUtils' e dá erro de sintaxe. A detecção só conhece Borland BDS 1–5 e CodeGear 6.0 e exige bin\bds.exe. Resultado: Product=IDEUnknown, IsIDEDelphi=False, e o placeholder do UsedUnits fica vazio. Dica confirmada no registro local: HKCU\Software\Embarcadero\BDS\37.0 tem RootDir, App e 'App x64', e HKLM\SOFTWARE\WOW6432Node\Embarcadero\BDS\37.0 tem RootDir.
- [REVISÃO] REPORTDLL está ATIVO por padrão ({$DEFINE REPORTDLL} em jedivcsdll\compopt.inc). A DLL então carrega jedivcsreport.dll, cujo fonte (src\jedivcsreport) não está no repositório. Ela recebe TApplication/TScreen (fvcs_DLLInitProc) e PChar (fvcs_SelectReport). Uma DLL de relatório antiga é incompatível com objetos e PWideChar do D13. Desligar REPORTDLL também não basta: o ramo {$ELSE} usa TVCSReport (JediVCSDLL.dpr 1932, ProjAdmin.pas 7238), que não existe em nenhum arquivo. É preciso reescrever (ex.: SimpleReport) ou remover a função.
- [REVISÃO] Recursos: {$R cursors.res} não existe em jedivcsdll; CURSORS.RES está só em jedivcs e jedivcsdiff. {$R \Projects\Jedivcs\src\comp\soft-gems\thememanager\Resources\winxp.res} não existe no repositório. Numa DLL, um manifesto com ID 1 é ignorado (vale o contexto de ativação do bds.exe), então basta remover esse $R; não é caso de 'trocar por manifesto do projeto'.
- IDE 64 bits do Delphi 13 (bin64\bds.exe e chave 'Experts x64' existem na instalação local, onde o Beyond Compare já registra $(BDS)\Bin64\\...dll): exige expert e DLL Win64, e também FVCSCrypt.dll, DLLs de zip e jedivcsreport.dll. [REVISÃO] Ela não compila nem depura alvos Win32, e a instalação local ainda não tem lib\win64\release\rtl.dcp, System.dcu nem designide.dcp. Fase 1: somente a IDE 32 bits.
- [REVISÃO] ShareMem não é a primeira unit do uses (vem depois de Windows, que é inofensiva). O histórico do .dpr (2005/12/21–22) registra a troca por FastMM e um rollback para ShareMem 'due to IDE crashes'. Removê-lo é possível, porque a ABI do expert só passa PAnsiChar e records e o EXE não usa ShareMem, mas exige teste dentro da IDE e depende da decisão sobre REPORTDLL.
- [REVISÃO] O DllEntry chama JediVCSDLLFinalize/LibExit em DLL_PROCESS_DETACH, ou seja, sob o loader lock. LibExit libera forms, ConfigStorage e JVCSClient, o que pode envolver logout e sockets. O novo expert deve chamar JEDIVCSDLLFINALIZE explicitamente antes do FreeLibrary, ao fechar a IDE ou descarregar, para evitar deadlock.
- [REVISÃO] Forms não modais da DLL, como VCSProjAdmin.Show (JediVCSDLL.dpr 1385/1393), com dezenas de TAction no ProjAdmin.dfm, rodam com uma VCL própria. O laço de mensagens é o da IDE, então TApplication.Idle da DLL (TAction.OnUpdate), Tab/CM_DIALOGKEY e aceleradores podem não funcionar. Avaliar um timer de idle ou o uso modal.
- Os forms da DLL não seguem o tema da IDE (dark/VCL Styles) e dependem do Per-Monitor DPI v2 do bds.exe. O Application.Handle é trocado pelo handle da IDE.
- O hook global WH_KEYBOARD só é instalado quando o expert não informa ioSupportsShortCuts. O expert deve informar a opção e usar IOTAKeyboardBinding.
- Funcionalidades de IDE antiga nas units consumidoras: UsedUnits lê sIDERegistryKey+'\Library'\\'Search Path' (no 37.0 só existem Library\Win32, Win64, Win64x e outras plataformas) com placeholder $(delphi)/$(BCB), sem $(BDS). ToDo e Options usam IDEAppFileDir+'delphi32.dci'. VerSet/ienBeforeCompile mexe no .res, que conflita com o VerInfo do .dproj. A chave 'Closed Projects' do Recent não pôde ser confirmada (não existe numa instalação 37.0 recém-feita).
- Expert com runtime packages exige um binário por IDE: rtl/vcl/vclactnband/designide 280 (BDS22), 290 (BDS23) e 370 (BDS37). O 10.4 importava designide270.
- Validação rápida: o novo expert pode primeiro carregar a JvcsExternalDll.dll original do instalador, que tem a mesma ABI e já fala com o servidor 2.5 Beta 3. Isso isola erros do expert dos erros do port da DLL. [REVISÃO] O conteúdo do instalador (lista de DLLs e valor JVCSIDEClient) não foi reverificado nesta revisão: só foi confirmada a assinatura 'Inno Setup Setup Data (5.3.7) (u)', e o 7-Zip não abre esse formato.

#### Units

| Unit | Onde está | Condição | Status D13 | Substituto | Notas |
|---|---|---|---|---|---|
| VCSIntf (VcsIntf.pas – OTA legada, TIVCSClient/VCSManagerEntryPoint) | ausente (não existe em Studio\37.0\source\ToolsAPI nem no designide.dcp 37.0) | IDEDLL e NOT EXT_IDE_INTF. O JediVCSDLL.dof define EXT_IDE_INTF, então o ramo fica DESLIGADO. | `remover` | Expert ToolsAPI (IOTAWizard) + DLL externa (EXT_IDE_INTF) | Não existe no ToolsAPI do 37.0 nem no designide.dcp; o ramo VCSManager fica desligado com EXT_IDE_INTF. |
| ToolIntf (OTA legada: TIToolServices, TIAddInNotifier) | designide.dcp/source\ToolsAPI\ToolIntf.pas do Delphi 13 (legado); fora do repositório | IDEDLL e NOT EXT_IDE_INTF (desligado) | `remover` | ToolsAPI no expert (IOTAModuleServices, IOTAActionServices, IOTAServices, IOTAIDENotifier) | A unit ainda existe, mas o TIToolServices só vinha pelo init do VCSManager, que não existe mais. |
| EditIntf (TIModuleInterface/TIEditorInterface/TIEditReader/TIEditWriter) | designide.dcp/source\ToolsAPI\EditIntf.pas do Delphi 13 (legado); fora do repositório | INTERNAL_OLDOTA = IDEDLL e NOT EXT_IDE_INTF (desligado) | `remover` | No expert: IOTASourceEditor/IOTAEditReader/IOTAEditWriter/IOTAFormEditor, expostos à DLL pelos callbacks SourceReadString/SourceWriteString/GetModuleComponent* | No modo EXT_IDE_INTF essas operações já passam pelo TExternalIDEFunctionRec. |
| ExptIntf | não usado pelo cliente (existe como legado no source\ToolsAPI e no designide 37.0) | — | `remover` | IOTAWizard (ToolsAPI) | Nenhum uses no cliente. |
| ToolsAPI | Delphi 13 (designide.dcp em Studio\37.0\lib\win32\release; source\ToolsAPI\ToolsAPI.pas) | Somente no expert separado; não entra no EXE nem na DLL externa | `funciona` | — | Conferido no 37.0: INITWIZARD0001, IOTAWizard, IOTAIDENotifier80, INTAServices280.AddImage, IOTAKeyboardBinding, IOTAProjectMenuItemCreatorNotifier. As interfaces de histórico ficam em FileHistoryAPI. |
| FileHistoryAPI | Delphi 13 (designide.dcp; source\ToolsAPI\FileHistoryAPI.pas) | Somente no expert | `funciona` | — | [REVISÃO] Unit esquecida: IOTAFileHistoryProvider (IDispatch/safecall) e providers de anotação (blame). As chamadas à DLL precisam ocorrer na thread principal (Midware/ICS). |
| DesignIntf / DesignEditors | Delphi designide (nativo) | Apenas pacotes design-time de componentes. Nenhuma unit do cliente usa. | `funciona` | — | Só pacotes design-time de terceiros; não copiar para a v2026. |
| JediVCSDLL.dpr (library, gera JvcsExternalDll.dll) | Jedi VCS Client\2.5\jedivcsdll\JediVCSDLL.dpr (original Delphi em jedivcsdll\ConverterBackup\JediVCSDLL.dpr) | Conditionals do .dof: DEBUG;IDEDLL;EXT_IDE_INTF;LANGUAGE;DelphiPersonalEdition. O compopt.inc da pasta acrescenta REPORTDLL, BLOWFISH, RELEASE, MIDWARE e {$Z1,T-,H+}. HISTORYAPISUPPORT e OPERATIONSSUPPORT ligam automaticamente com EXT_IDE_INTF. | `portar-codigo` | — | Partir do ConverterBackup (já na v2026), remover o ramo VCSManager, PChar→PAnsiChar (ou ABI v2) e tratar REPORTDLL, cursors.res, winxp.res, ShareMem, hook de teclado e DllEntry. |
| JVCSIDEInterface.pas | Jedi VCS Client\2.5\jedivcsdll\JVCSIDEInterface.pas (só existe em jedivcsdll) | IDEDLL (fica fora do EXE, do Diff e do Console) | `portar-codigo` | — | Remover INTERNAL_OLDOTA; buffers 'array[0..255] of Char' viram AnsiChar com tamanho. [REVISÃO] Com {$T-}, @buffer compila em silêncio com WideChar e StrPas fica ambíguo. |
| JVCSIDEInterfaceCommon.pas (contrato ABI expert↔DLL) | Jedi VCS Client\2.5\jedivcsdll\JVCSIDEInterfaceCommon.pas (o .dpr espera '..\common\\', pasta que não existe) | FUNCTIONRECS quando IDEDLL+EXT_IDE_INTF ou sem IDEDLL; OLDOTA só com IDEDLL sem EXT_IDE_INTF | `portar-codigo` | — | Records já em PAnsiChar (24/10/9 callbacks); o expert precisa compilar com o mesmo {$Z1}. Opcional: ABI v2 com tamanho de buffer e versão do record. |
| JVCSIDESettings.pas | Jedi VCS Client\2.5\jedivcsdll\JVCSIDESettings.pas (só existe em jedivcsdll) | IDEDLL | `portar-codigo` | Dados vindos do expert via IOTAServices (GetRootDirectory/GetBaseRegistryKey), ou leitura de HKCU\Software\Embarcadero\BDS\nn.0 (RootDir, App, 'App x64'), ou JclIDEUtils | {$ifdef WINDOWS}→MSWINDOWS (linha 95); acrescentar BDS 7.0–23.0 e 37.0, raiz Software\Embarcadero\BDS e bin64\bds.exe. |
| JVCSDLLOperations.pas | Jedi VCS Client\2.5\jedivcsdll\JVCSDLLOperations.pas | EXT_IDE_INTF (OPERATIONSSUPPORT) | `portar-codigo` | — | Callbacks em PChar passam a PAnsiChar; GetProjectID usa ExtractFileName(AProjectName) como chave no servidor. |
| JVCSDLLFileHistoryImpl.pas | Jedi VCS Client\2.5\jedivcsdll\JVCSDLLFileHistoryImpl.pas | EXT_IDE_INTF (HISTORYAPISUPPORT) | `portar-codigo` | — | Nove callbacks GetModuleHistory* em PChar; usa a mesma conexão do cliente, portanto só na thread principal. |
| JVCSDLLLineHistoryFrame.pas | Jedi VCS Client\2.5\jedivcsdll\JVCSDLLLineHistoryFrame.pas | LINEHISTORYFRAMEEXPORT, nunca definido em nenhum .pas, .dpr, .inc ou .dof (confirmado por grep) | `remover` | [REVISÃO] Se desejado: IOTAAsynchronousAnnotationProvider + IOTAAnnotationLineProvider (FileHistoryAPI), o blame nativo da aba History | LINEHISTORYFRAMEEXPORT nunca é definido (código experimental); a v2026 ainda tem a unit em src\jedivcs. [REVISÃO] Substituto nativo: providers de anotação da FileHistoryAPI. |
| jvcside_dxwizard.dpr / JVCSIDEWizard / JVCSIDEFileHistoryImpl / JVCSIDEProjectMenuImpl (expert JvcsExpertBDSnn.dll) | ausente no repositório. O jvcs_directories.txt aponta 'JEDI VCS.IDE/jvcside_dxwizard.dpr' em v:\\..\jedivcs\src\jedivcside\delphi_wizard\ no servidor JVCS privado. Há binários BDS6–BDS21 2.5.0.1030 no instalador. | Sempre que houver integração com a IDE | `substituir` | Novo expert reescrito com ToolsAPI + FileHistoryAPI: IOTAWizard + INTAServices, IOTAIDENotifier80, IOTAFileHistoryProvider, IOTAProjectMenuItemCreatorNotifier, IOTAKeyboardBinding. Um binário por IDE: BDS22, BDS23 e BDS37 (x64 numa fase 2). | Fonte ausente (servidor JVCS privado); reescrever a partir dos records de JVCSIDEInterfaceCommon e do comportamento do binário 2.5.0.1030. Chamar JEDIVCSDLLFINALIZE antes do FreeLibrary e devolver o mesmo nome de projeto. |
| Registro de carga (instalador): Experts\JVCSIDEClient e Version Control\VCSManager | Instalador Inno Setup 5.3.7 (u): JVCSv2.50ClientSetupBeta3_Refresh_till_10_4Sydney.exe | Componente 'IDE client' do setup | `atualizar-versao` | Novo instalador/registrador gravando HKCU\Software\Embarcadero\BDS\22.0, 23.0 e 37.0\Experts (valor = caminho do JvcsExpertBDSnn.dll) e, numa fase 2, 'Experts x64' | [REVISÃO] Só a assinatura Inno Setup 5.3.7 foi reverificada; nomes de DLL e o valor JVCSIDEClient vêm do inventário original. |
| Units consumidoras do IDEInterface (VCSBase, VCSProcBase, ChkInSingle, ChkOutSingle, ProjAdmin, ProjDependencies, UsedUnits, UsedComponents, ToDo, Options, VerSet, Recent, Backup, Create, HandleBlob, History, LoadModule, Syncronice, TextComp + [REVISÃO] Distribution, JVCSBrowserFrame, JVCSLockedModulesDockWnd, MergeVersion, RenameProj, SearchModules, SelectProjectID, Std_ListView, UnitFilter) | jedivcsdll\\\*.pas (UsedComponents, VerSet e Recent só existem lá) e jedivcs\\\*.pas (blocos {$IFDEF IDEDLL}) | IDEDLL (fica fora do EXE, do Diff e do Console) | `portar-codigo` | — | Dependem de TIDEInterface; ajustes de IDE moderna em UsedUnits (Library\Win32, $(BDS)), ToDo/Options (delphi32.dci), VerSet (.res x VerInfo) e Recent. [REVISÃO] Usar as cópias de jedivcsdll. |
| ShareMem (borlndmm.dll) | RTL | sempre (DLL) | `funciona` | Remover se nenhuma string ou objeto Delphi cruzar a fronteira. A ABI do expert é só PAnsiChar e records, mas a jedivcsreport.dll (REPORTDLL ativo) recebe TApplication/TScreen. | [REVISÃO] Histórico registra rollback de FastMM para ShareMem 'due to IDE crashes'; remover exige teste na IDE e depende de REPORTDLL. |
| jedivcsreport.dll (fronteira REPORTDLL: fvcs_DLLInitProc/fvcs_SelectReport) | ausente (fonte em src\jedivcsreport no servidor JVCS, segundo HowToBuild.txt) | REPORTDLL: ATIVO por padrão em jedivcsdll\compopt.inc (e em jedivcs) | `substituir` | Relatório interno (ex.: SimpleReport.pas, já no uses) ou remoção da função de impressão de relatórios | [REVISÃO] Item esquecido: REPORTDLL ativo, DLL sem fonte e incompatível com o D13, e o ramo sem REPORTDLL usa TVCSReport inexistente. Reescrever (SimpleReport) ou remover a função. |
| Recursos do JediVCSDLL.dpr ({$R *.res, jvcsver.res, strings.res, cursors.res, menuimages.res, winxp.res}) | jedivcsdll: JediVCSDLL.res, jvcsver.res, STRINGS.RES e menuimages.RES presentes; cursors.res ausente (CURSORS.RES só em jedivcs e jedivcsdiff); winxp.res ausente em todo o repositório (caminho absoluto \Projects\Jedivcs\\...) | sempre; menuimages.res só com EXT_IDE_INTF | `portar-codigo` | Copiar CURSORS.RES de jedivcs. Remover o $R do winxp.res: numa DLL, o manifesto com ID 1 é ignorado e vale o do bds.exe. | [REVISÃO] Copiar CURSORS.RES (a v2026 já tem em src\jedivcs) e remover o $R do winxp.res; gerar menuimages em 16/24/32 px para HighDPI. |

## 4. Riscos de compatibilidade com o servidor 2.5 Beta 3

Esta seção reúne tudo o que, nas famílias e no crítico, afeta o **protocolo** (bytes no fio) ou os **dados gravados** no servidor (ou lidos por clientes 2.5 Beta 3 que continuem em uso). O servidor não muda, então qualquer divergência tem de ser resolvida no cliente.

**Base comum de validação.** Use o cliente oficial `JVCSv2.50ClientSetupBeta3_Refresh_till_10_4Sydney.exe` como referência "golden":
- servidor de **teste** com cópia do banco Firebird de produção;
- captura de tráfego com proxy TCP ou Wireshark;
- comparação byte a byte com o cliente novo;
- consultas SQL somente leitura no banco.

Rode os testes com `DEBUG` (`{$R+,Q+,C+}`) ligado e em duas configurações de Windows: ACP 1252 e "Beta: UTF-8" (ACP 65001).

No `Plano-de-Port.md`, os itens desta tabela são citados como **[R1]** a **[R21]**, e o checklist final do plano os percorre.

| # | Item | Onde (código) | Risco | Como validar |
|---|---|---|---|---|
| 1 | **Code page / AnsiString no fio** (RFormat e ApsCli) | `RFormat.pas` (`AppendFields`, `GetFields`, `MoveEscaped`, `AppendStreamField`), `ApsCli.pas` (header `'FUNC '`, `CrackHeader`, `FRcvBuf`) | Compilado em Unicode, o Midware manda UTF-16 ou trunca. Com CP_ACP e ACP=65001, os acentos viram UTF-8 (mojibake, busca por nome falha, módulos duplicados). O servidor repassa bytes ANSI ao Firebird conforme `lc_ctype` (`SrvMain.pas` l.2348). | Conferir o `lc_ctype`/`FirebirdCharacterSet` do servidor e a ACP das estações antigas. Fixar `type TJVCSWireString = type AnsiString(1252)` (configurável). Golden com nomes de módulo, comentários de check-in e descrições acentuados, nas duas ACPs. |
| 2 | **Formato do TMWBuffer** | `RFormat.pas` l.1446-1454, escapes, `FloatToStrEx` | Mudança sutil em separadores (3 bytes `ESC #127`/`FLD #18`/`REC #20` após `HeaderSize`), escapes (`ESC`+F/R/C/L/N, `ESC ESC`), tipo `ESC 'T'`+dígito, blobs ou linhas LF (CR opcional) quebra o servidor sem erro óbvio. | Ida e volta do `RFormat` contra os bytes golden. Comparar byte a byte `GET_SERVER_TIME`, `LOGIN`, `GET_PROJECT_LIST`, `CHECKIN_MODULE` (blob), `GET_CHECKOUT_MODULE`. Testar também com range check ligado. |
| 3 | **Floats e TDateTime em texto** | `FloatToStrF(ffGeneral,18)` no RFormat; `SafeStrToFloat` (`JVCSClientObjBase.pas` l.194-211); `_StrToFloat` (`VCSProcBase.pas` l.707); `speLoginTO.Value/1440` (`ServerOptions.pas`) | Sai com o separador decimal do locale (comportamento original a preservar). As globais `DecimalSeparator`/`ThousandSeparator` não existem no D13 (crítico 1.2), e a troca precisa manter a mesma semântica. Em Win64, `Extended = Double` muda os dígitos. | Golden de `GET_SERVER_TIME` e de opções do servidor com locale pt-BR (vírgula) e en-US (ponto). Comparar a string enviada com a do cliente antigo no mesmo locale. |
| 4 | **Login / FVCSCrypt** | `JVCSCrypt.pas`, `JVCSConnect.pas` (carga da DLL), `TJVCSLogin.DoExecute` (`JVCSClientObj.pas` l.6274-6286) | A senha cifrada é `ShortString` com bytes >127 e passa por `S: string`; com ACP 65001 perde bytes e o login falha. A DLL é 32 bits e fechada (`fvcs_Encrypt2` usa a hora do servidor −1 s). | Manter `S` como `AnsiString`/`RawByteString` e enviar como `vtAnsiString`. Golden do LOGIN com senhas de bytes altos, nas duas ACPs. Usar exatamente a `FVCSCrypt.dll` do instalador 2.50 Beta 3. |
| 5 | **Versão do cliente no LOGIN** (crítico 1.1) | `Create.pas:534` (`Fields[2]`), `VCSProcBase.pas:1400-1416` (`ProductVersion` do módulo), servidor `SrvOBJMain.pas:407/419` com `ExpectedCliVersion` = 220 (`VCSCommon.pas:111`) | VerInfo padrão de `.dproj` (`1.0.0.0`) gera 100 e o servidor recusa com 403 ("outdated client"). `ProductVersion` com 3 partes dispara `Assert`. VERSIONINFO duplicado (`*.res` + `jvcsver.res`) decide o valor. Na DLL vale o VERSIONINFO da própria DLL. Console e Diff mandam 239 fixo. | `jvcsver.rc` como fonte única, "Include version information" desligado. `ProductVersion` `n.n.n.n` ≥ 2.2.0 (ex.: `2.5.0.x`). Golden do LOGIN do EXE, da DLL, do Diff e do console. Inspecionar o VERSIONINFO final com o Resource Hacker/`Get-Item .VersionInfo`. |
| 6 | **Endereço/IPv4** | `ApsCli` portado (TWSocket interno), `DBModule.dfm` (`Server='localhost'`) | O servidor 2.5 (ICS V5) só escuta IPv4; com `sfAny`, `localhost` pode resolver para `::1` e a conexão é recusada. | Fixar `SocketFamily := sfIPv4`. Testar conexão por `localhost`, nome e IP. |
| 7 | **CRC do Checksum (ORIGCRC)** | `Checksum.CRCInt`/`CRCString` (ausente; a recriar); `ChkInSingle.pas:1636` envia; comparado em `ChkOutSingle:800`, `JVCSChkInOutCommon:445`, `IsFileDirtyCRC`, `TextComp` (`GET_REVISION_STATUS`), `TJVCSSearchModuleRevisionsByCrc`, sync do console | Polinômio, valor inicial, XOR final, sinal ou formatação (`'$'+IntToHex(…,8)`) diferentes fazem tudo aparecer como modificado e a busca por CRC deixa de achar revisões. Coluna `origcrc int(11)` com sinal. | Comparar `BLOBS.ORIGCRC` com o CRC do diretório central do ZIP de uma amostra ampla de blobs; cuidado com revisões com expansão de keywords. Calcular `CRCInt` de arquivos conhecidos no cliente antigo e no novo. Rodar `{$R-}{$Q-}` na unit e usar cast explícito `Integer(crc)`. |
| 8 | **Formato dos blobs ZIP e data do item** | `TJVCSAbZipper`/`JVCSCompressFile(List)` → `JVCSZipUtils` (TZipFile); `ExtractBlobToFile` aplica `LastModTime` ao arquivo | O blob deve continuar ZIP de 1 item, Deflate, nome sem path e data do arquivo (hora local DOS). `TZipFile.Add(Stream, nome)` grava `Now`, e clientes novos e 2.5 Beta 3 restaurariam a data errada. Nomes não ASCII ganham flag UTF-8 (bit 11); impacto baixo. | Check-in pelo cliente novo → checkout pelo 2.5 Beta 3 (e vice-versa), comparando conteúdo, nome e data do arquivo restaurado. Abrir os blobs novos com o Abbrevia antigo. |
| 9 | **Blobs legados** | `HandleBlob`, `ExtractBlobTo*` | O TZipFile só lê Stored/Deflate (Deflate64 no D12+). Bancos antigos podem ter blobs de NanoZip/DelZip/FreeVCS ou com flag de criptografia ZIP. | SQL em `BLOBS.FILEDATA`: assinatura `'PK'#3#4`, método no offset 8 (0 ou 8) e bit 0 de flags = 0. Se houver exceções, manter leitor de fallback. |
| 10 | **Blowfish (EncryptModuleData)** | `ChkInSingle.pas:1662-1685`, `HandleBlob.pas:136-161`, `BFCrypt` ausente | Blobs cifrados ficam ilegíveis sem o formato original. A opção é opt-in (registro ou `GlobalSettingValue(7)`). | Varrer `BLOBS.FILEDATA` por conteúdo que não começa com `PK`. Se não houver, desativar a opção e esconder a página. Se houver, recuperar o formato por caixa-preta (cliente 2.5 Beta 3 + chave conhecida; testar modos/derivações no DEC 6.4.1). |
| 11 | **Header XML do Line History** | `JVCSLineHistoryPropertyStorage` (TJclSimpleXML) → `TJVCSAddUpdateProperties.Header`; servidor só armazena (`JVCSSrvOBJProperties.pas:639/676`) | Clientes 2.5 Beta 3 só leem o header se o 1º caractere for `<`. BOM ou espaço inicial fazem recalcular o cache (sem corromper dados). Tamanho máximo da coluna desconhecido. | Header gravado pelo cliente novo lido pelo 2.5 Beta 3 e vice-versa. Conferir no banco o primeiro byte e o tamanho. Manter a JclSimpleXml (prolog + indentação). |
| 12 | **Property "Line History" (LINEINFOEX)** | `JVCSLineHistoryUnit` (ZXML via ZIP com LINEINFOEX; senão `RevisionInfoSaveToStream`) | Não se sabe com qual define o 2.5 Beta 3 foi compilado; se diferir, o cache gravado não carrega (impacto baixo, é cache). | Verificar no banco se o conteúdo da property começa com `PK`. Usar o mesmo formato. |
| 13 | **Nome do projeto devolvido pelo expert** | `JediVCSDLL.dpr` 773–953 (`ExtractFileName(IDEInterface.GetProjectName)`), `JVCSDLLOperations.GetProjectID` | Se o novo expert devolver `.dproj` onde o antigo devolvia `.dpr` (ou outro arquivo), os projetos cadastrados não são encontrados ou são duplicados no servidor. | No mesmo projeto, registrar o nome devolvido pelo expert 2.5.0.1030 (IDE antiga) e pelo novo. Abrir um projeto já cadastrado pela IDE nova e confirmar que o ID é o mesmo. |
| 14 | **Valores de UI enviados ao servidor** | `ProjectRights.pas:454-461` (`icbRight.ItemIndex`), `MaintainBugs.pas:414/491-494` (`icbLevel.ItemIndex`); spins em `ServerOptions`, `DirectSQL`, `Purge`, `Syncronice` | Ao trocar TJvImageComboBox por TComboBoxEx, a ordem dos itens é o valor gravado (direito/severidade). Spins Integer geram a mesma string que hoje. | Gravar direitos e severidades pelo cliente novo e conferir no banco e no 2.5 Beta 3. Golden das funções com spins. |
| 15 | **Tamanhos no check-in do console** | `jvcs.dpr:927/931` (`GetSizeOfFile` → `ModuleOriginalSize`/`ModuleCompressedSize`) | O substituto precisa devolver o mesmo Int64 em bytes. O servidor tem `origsize`/`compsize int(11)` (trunca a partir de 2 GB, comportamento já existente). | Comparar os valores gravados pelo console antigo e pelo novo para os mesmos arquivos. |
| 16 | **Modo cifrado/LZH (`#$FF`)** | `DBModule` (Encrypt/Decrypt), `SrvMain.pas` l.1669-1738 | Removido no cliente; o servidor só cifra se o pedido veio cifrado. Uma resposta `#$FF` inesperada deve virar erro claro. | Golden: confirmar que nenhuma resposta começa com `#$FF`. Teste unitário da checagem defensiva. |
| 17 | **Tratamento de erro e cabeçalho da requisição** | `JVCSClientObjBase.DoExecute` (TransactionID/UserID), `raise EJVCSClient` | Nas cópias Lazarus esses trechos estavam comentados, o que quebra o protocolo e engole erros. A v2026 usa a cópia de `jedivcsdll`. | Golden com TransactionID/UserID. Forçar erro no servidor (ex.: projeto inexistente) e verificar a exceção. |
| 18 | **Decodificação de blobs como texto** | `TJVCSClientObject.BlobAsText` | `SetLength` + `Read` em `string` UTF-16 lê metade e deixa lixo. | Ler blobs com acentos e comparar com o cliente antigo. Implementar com `TBytes` + `TEncoding` da code page do protocolo. |
| 19 | **Nomes de módulo extraídos pelo lexer** | `UsedUnits`, `ProjDependencies` (`Origin := MS.Memory`), `JVCSIDEInterface.IDESource2Stream` | Buffer decodificado errado gera nomes corrompidos, que acabariam enviados ao servidor ao adicionar módulos. | Comparar a lista de units extraída pelo cliente novo e pelo antigo em projetos com BOM UTF-8, ANSI e nomes acentuados. |
| 20 | **Mailslot entre clientes** (não envolve o servidor) | `mdMailSlot` (`SendBufSecure`, `CalcCRC16`) | Formato 4 hex + 4 hex CRC + dados ANSI tem de ser lido pelos clientes 2.5 e pelo notificador. | Enviar notificação do cliente novo para um 2.5 Beta 3 e vice-versa (mailslot local). |
| 21 | **Dados locais do cliente 2.5** (não envolve o servidor) | `%APPDATA%\JEDI\JVCS\Config\`, `ProgramData\JEDI\JVCS`, chaves DSA `DontShow`/`LastResult`, MRU do Diff (`HKCU\Software\JEDI\JEDIVCSDiff\MRU`), RegAcc, Base64 no registro (`Create.pas:1239/1301`, `Options.pas:791/1857`) | Pastas ou formatos diferentes fazem o usuário perder configurações, preferências, cache e senha de identidade. | Rodar o cliente novo numa estação que já usava o 2.5 Beta 3 e conferir configurações, MRU, "não mostrar novamente" e senha lembrada. |

## 5. Evidências

Lista deduplicada das evidências citadas pelas 9 famílias revisadas e pelo crítico.

### 5.1 Arquivos locais

Os números de linha citados nas seções acima referem-se ao clone, salvo indicação em contrário.

**Clone, componentes de terceiros** (`<clone>\Components\`):
- `WSocket.pas`, `IcsDefs.inc`, `MWDefs.inc`, `ApsCli.pas`, `cbroker.pas`, `RFormat.pas`, `cipherlz.pas`, `lzh.pas`, `Trash\OverbyteIcsWSocket.pas`
- `AbZipTyp.pas`, `AbDefine.inc`, `hashunit.pas`, `diffunit.pas`, `mdmailslot.pas`, `favopendialog.pas`, `dfsstatusbar.pas`
- `virtualtrees.pas`, `compilers.inc`, `vtconfig.inc`, `msaaintf.pas`, `strutilsd5.pas`, `vtaccessibilityfactory.pas`
- `synedit.pas`, `synedit.inc`, `synedithighlighter.pas`, `ktextdrawer.pas`

**Clone, cliente** (`<clone>\Jedi VCS Client\2.5\`):
- `jedivcsdll\`:
  - projeto e opções: `JediVCSDLL.dpr`, `ConverterBackup\JediVCSDLL.dpr`, `JediVCSDLL.dof`, `compopt.inc`, `jvcs_directories.txt`
  - camada cliente-servidor: `DBModule.pas/.dfm`, `JVCSConnect.pas`, `JVCSClientDispatcher.pas`, `JVCSClientObjBase.pas`, `JVCSClientObj.pas`, `JVCSNewClientObj.pas`, `JVCSClientFunctions.pas`, `JVCSChkInOutCommon.pas`
  - forms e operações: `Create.pas`, `ChkInSingle.pas`, `ChkOutSingle.pas`, `HandleBlob.pas`, `Backup.pas`, `Distribution.pas`, `ProjectTree.pas`, `ProjAdmin.pas/.dfm`, `Options.pas/.dfm`, `ServerOptions.pas`, `ProjectRights.pas`, `MaintainBugs.pas`, `Syncronice.pas/.dfm`, `TextComp.pas`, `LoadModule.pas`, `History.pas`, `CompareFolders.pas`, `UsedUnits.pas`, `ProjDependencies.pas`, `ToDo.pas`, `VerSet.pas`
  - Line History e Compressed Diff: `JVCSLineHistoryUnit.pas`, `JVCSLineHistoryFrame.pas`, `JVCSLineHistoryHighlighterUnit.pas`, `JVCSLineHistoryPropertyStorage.pas`, `JVCSLineHistorySettingsDialog.pas/.dfm`, `JVCSCompressedDiffUnit.pas`, `JVCSCompressedDiffFrame.pas`, `JVCSCompressedDiffSynProxy.pas`
  - integração com a IDE: `JVCSIDEInterface.pas`, `JVCSIDEInterfaceCommon.pas`, `JVCSIDESettings.pas`, `JVCSDLLOperations.pas`, `JVCSDLLFileHistoryImpl.pas`, `JVCSDLLLineHistoryFrame.pas`
  - utilitários e infraestrutura: `JVCSDialogs.pas`, `JVCSLanguage.pas`, `JVCSThreads.pas`, `JVCSMruList.pas`, `JVCSProjectTreeUnit.pas`, `ProjectTreeDockWnd.pas`, `ConfigStorage.pas`, `VCSBase.pas`, `VCSProcBase.pas`, `MemCheck.pas`, `JVCSBaseAboutDialog.dfm`, `ChangeUserPW.dfm`, `Create.dfm`
  - `*.pas` / `*.dfm`: contagens de componentes JVCL, EnhListView e `{$I jedi.inc}`
- `jedivcs\`:
  - projeto e opções: `Jedivcs.dpr`, `ConverterBackup\Jedivcs.dpr`, `Jedivcs.dof`, `compopt.inc`, `jvcsver.rc`, `jedivcs.inc`, `STRINGS.RC`, `CURSORS.RES`, `HowToBuild.txt`
  - cópias com edições Lazarus: `JVCSClientObjBase.pas`, `VCSProcBase.pas`, `JVCSDialogs.pas`, `JVCSClientFunctions.pas`, `Create.pas`, `ProjAdmin.pas`
  - units só do EXE: `ExtBugtracker.pas`, `SaveWIP.pas`, `JVCSManageFavorites.pas`, `JEDIVCSPluginMsgConst.inc`
  - demais units citadas: `JVCSCrypt.pas`, `JVCSClientConsts.pas`, `JVCSBrowserFrame.pas/.dfm`, `ProjectTreeDockWnd.pas`, `ModuleHistoryWindow.pas`, `SelectFolder.pas`, `History.pas`, `DirWatch.pas`, `Std_ListView.pas`, `UsedUnits.pas`, `ProjDependencies.pas`, `ToDo.pas`
  - `*.dfm`: contagens de componentes
- `jedivcsdiff\`: `JEDIVCSDiff.dpr`, `JEDIVCSDiff.dof`, `DiffMain.pas/.dfm`, `DiffHLProp.pas`, `DiffHelp.pas`, `DiffSimpleReport.pas`, `JVCSDiffResources.pas`, `VCSBase.pas`, `credits.txt`

**Clone, console, servidor e banco:**
- `<clone>\Jedi vcs console\2.5\`: `jvcs.dpr`, `ConverterBackup\jvcs.dpr`, `jvcs.dof`, `TZHandling.pas`
- `<clone>\Jedi VCS Server\2.5\`: `SrvMain.pas`, `SrvOBJMain.pas`, `JVCSSrvOBJProperties.pas`, `JVCSSrvOBJNewObjects.pas`, `ServerCryptInt.pas`
- `<clone>\common\VCSCommon.pas`; `<clone>\Jedi VCS DB\2.5\mysql_create.sql`
- Histórico git do clone: 3 commits (2017), sem Checksum/BFCrypt/FVCSCrypt

**Instalador de referência:** `D:\Delphi\JediVCS\Instalador_2.50_Beta3_10.4Sydney\JVCSv2.50ClientSetupBeta3_Refresh_till_10_4Sydney.exe` (Inno Setup 5.3.7 (u)).

**Instalação local do Delphi 13** (`C:\Program Files (x86)\Embarcadero\Studio\37.0\`):
- `source\ToolsAPI\`: `ToolsAPI.pas`, `FileHistoryAPI.pas`, `ToolIntf`, `EditIntf`, `ExptIntf`; sem `VcsIntf.pas`
- `source\rtl\sys\System.SysUtils.pas`: linhas 983-1001 e 2054/2056
- `source\vcl\Vcl.Forms.pas`: linha 5915
- `lib\win32\release\designide.dcp`; `lib\win64\release` (sem rtl.dcp/System.dcu/designide.dcp)
- `bin\` e `bin64\`: `bds.exe`, `coreide370.bpl`, `gitide370`/`hgide370`/`svnide370`/`historyide370`, `dcc32.exe`, `brcc32.exe`, `cgrc.exe`

**Registro do Windows:**
- `HKCU\Software\Embarcadero\BDS\37.0`: `RootDir`, `App`, `App x64`, subchaves `Experts` e `Experts x64`, `Library\Win32`/`Win64`/`Win64x`
- `HKLM\SOFTWARE\WOW6432Node\Embarcadero\BDS\37.0\RootDir`

### 5.2 Endereços web (deduplicados, agrupados por assunto)

**JCL, JVCL e jedi.inc**

- <https://api.github.com/repos/project-jedi/jcl/commits?per_page=5>
- <https://api.github.com/repos/project-jedi/jcl/contents/jcl/experts/repository/ExceptionDialog/StandardDialogs>
- <https://api.github.com/repos/project-jedi/jcl/contents/jcl/packages>
- <https://api.github.com/repos/project-jedi/jcl/contents/jcl/source/common>
- <https://api.github.com/repos/project-jedi/jvcl/commits?per_page=5>
- <https://api.github.com/repos/project-jedi/jvcl/contents/jvcl/packages>
- <https://api.github.com/repos/project-jedi/jvcl/issues?state=all&per_page=15>
- <https://blogs.embarcadero.com/powerful-jedi-code-library-for-delphi-and-c-builder-developers-can-be-a-massive-productivity-boost>
- <https://getitnow.embarcadero.com/JEDICodeLibraryJCL-13-2025.10>
- <https://getitnow.embarcadero.com/JEDICodeLibraryJCL-13-2026.08>
- <https://getitnow.embarcadero.com/jedi-visual-component-library>
- <https://github.com/project-jedi/jcl>
- <https://github.com/project-jedi/jcl/commits/master>
- <https://github.com/project-jedi/jvcl/pull/203>
- <https://raw.githubusercontent.com/project-jedi/jcl/master/jcl/source/common/JclAnsiStrings.pas>
- <https://raw.githubusercontent.com/project-jedi/jcl/master/jcl/source/common/JclBase.pas>
- <https://raw.githubusercontent.com/project-jedi/jcl/master/jcl/source/common/JclFileUtils.pas>
- <https://raw.githubusercontent.com/project-jedi/jcl/master/jcl/source/common/JclPCRE.pas>
- <https://raw.githubusercontent.com/project-jedi/jcl/master/jcl/source/common/JclResources.pas>
- <https://raw.githubusercontent.com/project-jedi/jcl/master/jcl/source/common/JclSimpleXml.pas>
- <https://raw.githubusercontent.com/project-jedi/jcl/master/jcl/source/common/JclStrings.pas>
- <https://raw.githubusercontent.com/project-jedi/jcl/master/jcl/source/common/JclSysInfo.pas>
- <https://raw.githubusercontent.com/project-jedi/jcl/master/jcl/source/include/jcl.inc>
- <https://raw.githubusercontent.com/project-jedi/jcl/master/jcl/source/include/jcl.template.inc>
- <https://raw.githubusercontent.com/project-jedi/jcl/master/jcl/source/windows/JclDebug.pas>
- <https://raw.githubusercontent.com/project-jedi/jcl/master/jcl/source/windows/JclRegistry.pas>
- <https://raw.githubusercontent.com/project-jedi/jcl/master/jcl/source/windows/JclSecurity.pas>
- <https://raw.githubusercontent.com/project-jedi/jedi/master/jedi.inc>
- <https://raw.githubusercontent.com/project-jedi/jvcl/master/jvcl/common/jvcl.inc>
- <https://raw.githubusercontent.com/project-jedi/jvcl/master/jvcl/packages/d37/JvControls.dpk>
- <https://raw.githubusercontent.com/project-jedi/jvcl/master/jvcl/packages/d37/JvCore.dpk>
- <https://raw.githubusercontent.com/project-jedi/jvcl/master/jvcl/packages/d37/JvDlgs.dpk>
- <https://raw.githubusercontent.com/project-jedi/jvcl/master/jvcl/packages/d37/JvHMI.dpk>
- <https://raw.githubusercontent.com/project-jedi/jvcl/master/jvcl/packages/d37/JvMM.dpk>
- <https://raw.githubusercontent.com/project-jedi/jvcl/master/jvcl/packages/d37/JvPluginSystem.dpk>
- <https://raw.githubusercontent.com/project-jedi/jvcl/master/jvcl/packages/d37/JvStdCtrls.dpk>
- <https://raw.githubusercontent.com/project-jedi/jvcl/master/jvcl/packages/d37/JvSystem.dpk>
- <https://raw.githubusercontent.com/project-jedi/jvcl/master/jvcl/packages/d37/JvWizards.dpk>
- <https://raw.githubusercontent.com/project-jedi/jvcl/master/jvcl/run/JvComponent.pas>
- <https://raw.githubusercontent.com/project-jedi/jvcl/master/jvcl/run/JvDSADialogs.pas>
- <https://raw.githubusercontent.com/project-jedi/jvcl/master/jvcl/run/JvDynControlEngine.pas>
- <https://raw.githubusercontent.com/project-jedi/jvcl/master/jvcl/run/JvDynControlEngineVCL.pas>
- <https://raw.githubusercontent.com/project-jedi/jvcl/master/jvcl/run/JvGnugettext.pas>
- <https://raw.githubusercontent.com/project-jedi/jvcl/master/jvcl/run/JvJCLUtils.pas>
- <https://raw.githubusercontent.com/project-jedi/jvcl/master/jvcl/run/JvJVCLUtils.pas>
- <https://raw.githubusercontent.com/project-jedi/jvcl/master/jvcl/run/JvListView.pas>
- <https://raw.githubusercontent.com/project-jedi/jvcl/master/jvcl/run/JvMRUList.pas>
- <https://raw.githubusercontent.com/project-jedi/jvcl/master/jvcl/run/JvMRUManager.pas>
- <https://raw.githubusercontent.com/project-jedi/jvcl/master/jvcl/run/JvPluginManager.pas>
- <https://raw.githubusercontent.com/project-jedi/jvcl/master/jvcl/run/JvSearchFiles.pas>
- <https://tp.embarcadero.com/jedi-code-library>

**ICS e Midware**

- <http://www.overbyte.eu/eng/products/midware.html>
- <https://docwiki.embarcadero.com/Libraries/en/System.Net.Socket.TSocket>
- <https://en.delphipraxis.net/topic/11016-midware-midware-delphi-12/>
- <https://en.delphipraxis.net/topic/12269-ics-v93-announced>
- <https://en.delphipraxis.net/topic/14365-ics-and-rad-studio-13>
- <https://en.delphipraxis.net/topic/15409-ics-96-delphi-131-compiler-error-e2203-concerning-overbyteicswincrypt/>
- <https://en.delphipraxis.net/topic/969-midware-new-update-available-for-latest-delphi-and-ics/>
- <https://getitnow.embarcadero.com/ICS_VCL-13-9.7/>
- <https://svn.magsys.co.uk/svn/icsv9/ReadMe9.txt>
- <https://svn.magsys.co.uk/svn/icsv9/Source/OverbyteIcsIcmp.pas>
- <https://svn.magsys.co.uk/svn/icsv9/Source/OverbyteIcsPing.pas>
- <https://svn.magsys.co.uk/svn/icsv9/Source/OverbyteIcsTypes.pas>
- <https://svn.magsys.co.uk/svn/icsv9/Source/OverbyteIcsWSocket.pas>
- <https://svn.magsys.co.uk/svn/midware/trunk/Delphi/Midware/>
- <https://svn.magsys.co.uk/svn/midware/trunk/Delphi/Midware/OverbyteCipherLz.pas>
- <https://svn.magsys.co.uk/svn/midware/trunk/Delphi/vc32/>
- <https://svn.magsys.co.uk/svn/midware/trunk/Delphi/vc32/OverbyteApsCli.pas>
- <https://svn.magsys.co.uk/svn/midware/trunk/Delphi/vc32/OverbyteRFormat.pas>
- <https://svn.magsys.co.uk/svn/midware/trunk/ReadMw.txt>

**VirtualTreeView, listas DFS, temas e controles VCL nativos**

- <https://api.github.com/repos/JAM-Software/Virtual-TreeView/releases?per_page=8>
- <https://docwiki.embarcadero.com/Libraries/Alexandria/en/API:Vcl.ComCtrls.TTreeView.CheckBoxes>
- <https://docwiki.embarcadero.com/Libraries/Alexandria/en/Vcl.WinXPanels.TCardPanel>
- <https://docwiki.embarcadero.com/Libraries/Athens/en/Vcl.ComCtrls.TCustomTreeView.CheckBoxes>
- <https://docwiki.embarcadero.com/RADStudio/Sydney/en/Using_VCL_TNumberBox_Control>
- <https://getitnow.embarcadero.com/virtual-treeview-latest-version>
- <https://github.com/etheadev/delphishellcontrolspackages>
- <https://github.com/JAM-Software/Virtual-TreeView>
- <https://github.com/JAM-Software/Virtual-TreeView/releases>
- <https://github.com/JAM-Software/Virtual-TreeView/tree/master/Packages>
- <https://github.com/JAM-Software/Virtual-TreeView/wiki/Breaking-Changes-in-V8>
- <https://learn.microsoft.com/en-us/archive/msdn-magazine/2001/august/c-q-a-getting-the-text-of-a-window-in-another-application;-making-backspace-work-in-the-explorer-bar>
- <https://raw.githubusercontent.com/JAM-Software/Virtual-TreeView/master/Packages/RAD%20Studio%2010.4%2B/VirtualTreesR.dpk>
- <https://raw.githubusercontent.com/JAM-Software/Virtual-TreeView/master/Source/VirtualTrees.BaseTree.pas>
- <https://raw.githubusercontent.com/JAM-Software/Virtual-TreeView/master/Source/VirtualTrees.Header.pas>
- <https://raw.githubusercontent.com/JAM-Software/Virtual-TreeView/master/Source/VirtualTrees.pas>
- <https://raw.githubusercontent.com/JAM-Software/Virtual-TreeView/master/Source/VirtualTrees.Types.pas>
- <https://raw.githubusercontent.com/winghc/extlist_xe/master/EnhListView.pas>
- <https://www.finalbuilder.com/forums/t/cbuilder-xe-enable-runtime-themes-switched-off/3500>

**SynEdit, lexer Pascal e diff**

- <https://api.github.com/repos/pyscripter/SynEdit/commits?per_page=5>
- <https://api.github.com/repos/pyscripter/SynEdit/contents/Packages>
- <https://api.github.com/repos/pyscripter/SynEdit/contents/Source>
- <https://api.github.com/repos/rickard67/TextDiff/commits>
- <https://api.github.com/repos/TurboPack/SynEdit/commits?per_page=8>
- <https://en.delphipraxis.net/topic/4439-the-tdiff-component-does-not-work-in-64-bit-compiled-app/>
- <https://getitnow.embarcadero.com/synedit-for-vcl/>
- <https://github.com/jacobthurman/Castalia-Delphi-Parser>
- <https://github.com/rickard67/TextDiff>
- <https://github.com/RomanYankovsky/DelphiAST>
- <https://raw.githubusercontent.com/jacobthurman/Castalia-Delphi-Parser/master/CastaliaPasLex.pas>
- <https://raw.githubusercontent.com/jacobthurman/Castalia-Delphi-Parser/master/CastaliaPasLexTypes.pas>
- <https://raw.githubusercontent.com/pyscripter/SynEdit/master/readme.md>
- <https://raw.githubusercontent.com/pyscripter/SynEdit/master/Source/Highlighters/SynHighlighterGeneral.pas>
- <https://raw.githubusercontent.com/pyscripter/SynEdit/master/Source/Highlighters/SynHighlighterMulti.pas>
- <https://raw.githubusercontent.com/pyscripter/SynEdit/master/Source/SynEdit.pas>
- <https://raw.githubusercontent.com/pyscripter/SynEdit/master/Source/SynEditHighlighter.pas>
- <https://raw.githubusercontent.com/pyscripter/SynEdit/master/Source/SynEditJedi.inc>
- <https://raw.githubusercontent.com/pyscripter/SynEdit/master/Source/SynEditMiscClasses.pas>
- <https://raw.githubusercontent.com/pyscripter/SynEdit/master/Source/SynEditTypes.pas>
- <https://raw.githubusercontent.com/rickard67/TextDiff/master/src/Diff.pas>
- <https://raw.githubusercontent.com/RomanYankovsky/DelphiAST/master/Source/SimpleParser/SimpleParser.Lexer.pas>
- <https://raw.githubusercontent.com/TurboPack/SynEdit/master/readme.md>
- <https://raw.githubusercontent.com/TurboPack/SynEdit/master/Source/SynEdit.pas>

**Compressão, criptografia e gerenciador de memória**

- <https://docwiki.embarcadero.com/Libraries/Athens/en/System.Zip.TZipFile>
- <https://docwiki.embarcadero.com/Libraries/Athens/en/System.Zip.TZipFile.IsValid>
- <https://docwiki.embarcadero.com/Libraries/Florence/en/System.ZLib.crc32>
- <https://en.delphipraxis.net/topic/10681-extract-from-encrypted-zip/>
- <https://getitnow.embarcadero.com/abbrevia/>
- <https://github.com/DGH2112/JEDIVCSToGit/blob/master/Source/JVTGMainForm.pas>
- <https://github.com/hbannw/JcvsToGit/blob/master/uJVcsToGit.pas>
- <https://github.com/MHumm/DelphiEncryptionCompendium>
- <https://github.com/pleriche/FastMM5>
- <https://github.com/TurboPack/Abbrevia/tree/master/packages>
- <https://github.com/UweRaabe/EncryptedZipFile>
- <https://raw.githubusercontent.com/TurboPack/Abbrevia/master/source/AbZipTyp.pas>
- <https://raw.githubusercontent.com/TurboPack/Abbrevia/master/TurboPack.Abbrevia.dspec>
- <https://raw.githubusercontent.com/UweRaabe/EncryptedZipFile/main/uEncryptedZipFile.pas>
- <https://www.uweraabe.de/Blog/2023/10/04/tzipfile-improvements-in-delphi-12/>

**Tradução (gettext)**

- <https://blog.marcocantu.com/blog/2023-december-ide-language-delphi12.html>
- <https://docwiki.embarcadero.com/Libraries/Athens/en/Vcl.Dialogs.TTaskDialog.VerificationText>
- <https://docwiki.embarcadero.com/RADStudio/Florence/en/Editing_Resource_Files_in_the_Translation_Manager>
- <https://sourceforge.net/p/dxgettext/code/HEAD/tree/trunk/dxgettext/languages/>
- <https://sourceforge.net/p/dxgettext/code/HEAD/tree/trunk/dxgettext/sample/>
- <https://sourceforge.net/p/dxgettext/code/HEAD/tree/trunk/dxgettext/sample/gnugettext.pas?format=raw>
- <https://www.rathlev-home.de/tools/ggt-en/prog.html>

**Projeto JEDI VCS**

- <https://api.github.com/repos/Libaud/JediVCS/git/trees/master?recursive=1>
- <https://forums.adug.org.au/t/jedi-vcs-add-in-for-delphi-11/59057>
- <https://github.com/Libaud/JediVCS>
- <https://jedivcs.sourceforge.net/building_from_source.html>
- <https://jedivcs.sourceforge.net/downloads.html>
- <https://sourceforge.net/projects/jedivcs/files/>
- <https://sourceforge.net/projects/jedivcs/files/2.5x%20Beta%203/>
- <https://sourceforge.net/projects/jedivcs/files/2.5x%20Beta%203/Client/>
- <https://sourceforge.net/projects/jedivcs/files/OldFiles/>
- <https://sourceforge.net/projects/jedivcs/rss?path=/>
- <https://sourceforge.net/rest/p/jedivcs/>

**Embarcadero (docwiki, anúncios) e Delphi 13**

- <https://blog.dummzeuch.de/2025/09/28/gexperts-1-3-26-beta-for-delphi-13-64-bit-ide/>
- <https://blogs.embarcadero.com/announcing-the-availability-of-rad-studio-13-florence>
- <https://cloud.watch.impress.co.jp/docs/news/2142981.html>
- <https://docwiki.embarcadero.com/Libraries/Alexandria/en/ToolsAPI.IOTAProjectManager_Methods>
- <https://docwiki.embarcadero.com/Libraries/Athens/en/System.RegularExpressions.TGroupCollection>
- <https://docwiki.embarcadero.com/Libraries/Athens/en/Vcl.Dialogs.TFileSaveDialog.FavoriteLinks>
- <https://docwiki.embarcadero.com/Libraries/Florence/en/API:ToolsAPI.IOTAVersionControlServices.Items>
- <https://docwiki.embarcadero.com/Libraries/Rio/en/System.IOUtils.TPath.GetHomePath>
- <https://docwiki.embarcadero.com/Libraries/Rio/en/System.IOUtils.TPath.GetPublicPath>
- <https://docwiki.embarcadero.com/RADStudio/en/64-bit_IDE>
- <https://docwiki.embarcadero.com/RADStudio/en/ARM64EC>
- <https://docwiki.embarcadero.com/RADStudio/en/Compiler_Versions>
- <https://docwiki.embarcadero.com/RADStudio/Florence/en/What's_New>
- <https://docwiki.embarcadero.com/RADStudio/Rio/en/Sharing_Memory>
- <https://en.delphipraxis.net/topic/5836-deprecated-units/>
- <https://en.delphipraxis.net/topic/7956-html-help-ctrlf-not-working/>
- <https://www.componentsource.com/product/delphi-architect/releases/2920666>

**Microsoft e Windows**

- <https://learn.microsoft.com/en-us/windows/win32/api/shlobj_core/ns-shlobj_core-openasinfo>
- <https://learn.microsoft.com/en-us/windows-server/get-started/removed-deprecated-features-windows-server-2025>
- <https://learn.microsoft.com/ms-my/windows/win32/api/shlobj_core/nf-shlobj_core-shopenwithdialog>
- <https://thewindowsupdate.com/2023/03/08/the-beginning-of-the-end-of-remote-mailslots/>
- <https://visualitynq.com/resources/articles/remote-mailslots-disabled-by-default/>

## 6. Lacunas e contradições apontadas pelo crítico

Resultado do agente `critic:completude` do mesmo workflow, incorporado na íntegra. Só os títulos foram rebaixados para caber nesta seção, e o título original foi omitido. As correções que o crítico classificou como verificadas prevalecem sobre as famílias, conforme apontado nas notas de consolidação da seção 3. Ao final está a situação de cada apontamento na árvore v2026.

Somente leitura: nenhum arquivo foi criado ou alterado e nada foi compilado.

### Resumo

- **Lacunas.** Faltam 14 itens que nenhuma família cobriu. Três deles quebram a compatibilidade com o servidor 2.5 Beta 3 ou impedem o build:
  - a versão do cliente enviada no LOGIN vem do VERSIONINFO do binário;
  - as variáveis globais de formato (`DecimalSeparator`, `ThousandSeparator`) foram removidas da RTL;
  - na pasta `jedivcsdll` faltam units e includes de que a DLL precisa.
- **Contradições.** São 12. Em seis delas uma das famílias está comprovadamente errada:
  - VerSet no EXE;
  - variáveis globais de formato;
  - wrapper `DELPHI` do compopt;
  - Blowfish "sempre ativo";
  - Win64 na "fase 2";
  - Delphi "não instalado".
- **Ordem de port.** Primeiro o núcleo de protocolo sem VCL, validado pelo console. Depois a infraestrutura comum de GUI, o Diff, o EXE, a DLL e por fim o expert. Só o expert pode avançar em paralelo.

---

### 1. Itens não cobertos por nenhuma família

#### 1.1 [CRÍTICO, protocolo] A versão do cliente no LOGIN sai do VERSIONINFO do binário

- **Evidência no cliente:**
  - `jedivcsdll\Create.pas:534` envia `GetJVCSAppProductVersionInt` como `Fields[2]` do LOGIN.
  - `VCSProcBase.pas:1400-1416` lê o `ProductVersion` do próprio módulo (`GetSelfFileName`, via `GetModuleFileName(HInstance)`) e calcula `v0*100 + v1*10 + v2`.
  - O mesmo código faz `Assert(Count > 3)`: a string precisa ter o formato `n.n.n.n`.
- **Evidência no servidor:** `Jedi VCS Server\2.5\SrvOBJMain.pas:407/419` rejeita com 403 quando `StrToInt(CliVersion) < ExpectedCliVersion` (`common\VCSCommon.pas:111`, valor 220).
- **Hoje:** `jvcsver.rc` traz `ProductVersion "2.5.0.0"`, o que dá 250.
- **Comparação:** o console e o Diff mandam o valor fixo 239 (`JVCSConnect.pas:269`) e não são afetados.
- **Riscos:**
  - O VerInfo padrão de um `.dproj` novo é `1.0.0.0`, o que dá 100 e o login é recusado como "outdated client".
  - Um `ProductVersion` com 3 partes dispara o Assert, porque `DEBUG` liga `{$C+}`.
  - O VT reativar `{$R *.res}` no `Jedivcs.dpr:271` gera VERSIONINFO duplicado com `jvcsver.res`. O recurso que prevalecer decide o que vai para o servidor.
  - Na DLL, conta o VERSIONINFO da própria DLL.
- **O que fazer:**
  - Manter `jvcsver.rc` como fonte única (ele também tem as chaves `BuildTimestamp` e `VCS`, lidas pelo About).
  - Desligar "Include version information" nos `.dproj`.
  - `ProductVersion` sempre com 4 partes e resultado de pelo menos 2.2.0, por exemplo `2.5.0.x` ou `2.6.0.x`.
  - Incluir o LOGIN do EXE e da DLL no teste golden.

#### 1.2 [BLOQUEANTE, build] Variáveis globais de formato removidas

- **Evidência:** `C:\Program Files (x86)\Embarcadero\Studio\37.0\source\rtl\sys\System.SysUtils.pas` tem `DecimalSeparator`, `ThousandSeparator` etc. só como campos de `TFormatSettings` (linhas 983-1001). Não existe mais nenhuma variável global com esses nomes.
- **Pontos que geram E2003:**
  - `JVCSClientObjBase.pas:200/206`, nas 4 cópias. É o `SafeStrToFloat`, que decodifica floats e `TDateTime` vindos do servidor, portanto é protocolo.
  - `VCSProcBase.pas:718`.
  - `ProjAdmin.pas:10963-64`.
  - `Std_ListView.pas:1169-70` (na cópia `jedivcs`, 1174-75).
- **O que fazer:** trocar por `FormatSettings.DecimalSeparator` e `FormatSettings.ThousandSeparator`. O `TZHandling` já faz isso sob `RTL220_UP`.

#### 1.3 [BLOQUEANTE, build da DLL] Units, include e recurso que a DLL usa mas não estão em `jedivcsdll`

O `JediVCSDLL.dof` não tem `..\jedivcs` no SearchPath.

| Item | Onde existe | Quem usa na DLL |
|---|---|---|
| `JVCSForms.pas` (base `TJVCSForm` de quase todos os forms) | `jedivcs` e `jedivcsdiff` (MD5 idêntico) | ~65 units; o `.dpr:392` aponta para `..\common\JVCSForms.pas`, que não existe |
| `Password.pas`/`.dfm` | só `jedivcs` | `Backup.pas:215` (senha do backup) |
| `ParsePG.pas` | só `jedivcs` | `CrossRefList.pas:112`, `SelectProjectID.pas:196` |
| `jedivcs.inc` (IDs de contexto de ajuda) | só `jedivcs` | `VCSBase.pas:105` da DLL; `jedivcsdiff\VCSBase.pas:102` também |
| `CURSORS.RES`/`.RC` | `jedivcs`, `jedivcsdiff` | `JediVCSDLL.dpr:527` |

A família JCL cobriu só `ExtBugtracker` e `SaveWIP`.

**O que fazer:** na base unificada, levar para a pasta comum as 7 units que só existem no EXE (`ExtBugtracker`, `JVCSForms`, `JVCSManageFavorites`, `OpenProject`, `ParsePG`, `Password`, `SaveWIP`), além de `jedivcs.inc`, `CURSORS.RC`, `STRINGS.RC` e `ICON.RES`. Dessas units, só `OpenProject:46` e `Password:44` têm bloco `{$ifdef FPC}`.

#### 1.4 [ALTO, ordem de port] O Diff arrasta o núcleo da GUI e as cópias Lazarus

- `VCSBase.pas`, nas 3 cópias, faz `implementation uses VCSProcBase` sem usar nada dela. O `initialization` só usa `GetAppdataFolder`, `PathAddSeparator`, `FileCopyFiles` e `GetSelfFileLocation`, que estão em `JclSysInfo`, `JclFileUtils` e `JVCSClientFunctions`.
- Por causa disso o JEDIVCSDiff compila `VCSProcBase`, e com ela `DBModule`, `JVCSDialogs` (que puxa `JvDSADialogs`), `JVCSMruList`, `HtmlHlp`, `FavOpenDialog` e `JVCSClientObj`.
- `JVCSBaseAboutDialog` do Diff usa `JVCSFunctions`, e `JVCSConnect` usa `JVCSNewClientObj`. Nenhuma das duas está em `jedivcsdiff`.
- O `JEDIVCSDiff.dof` busca em `..\jedivcs`. Hoje essa pasta tem as cópias mutiladas pelo port Lazarus (`JVCSDialogs` com `DSAMessageDlg` comentado, `VCSProcBase` com `HtmlHelp` comentado).
- **O que fazer:** remover o `uses VCSProcBase` de `VCSBase` e dar ao Diff acesso explícito a `JVCSFunctions` e `JVCSNewClientObj`, nunca a `..\jedivcs`. Assim o Diff fica independente do EXE.

#### 1.5 [ALTO, build do console] Dependências do console fora da pasta

- `jvcs.dpr` e `JVCSConnect.pas` usam `JVCSNewClientObj` sem condição, e ela só existe em `jedivcs` e `jedivcsdll`.
- `JVCSBranchClientObj` também, mas só sob `BRANCHING`.
- O caminho `..\common\VCSCommon.pas` não resolve; a unit está em `Fontes_JediVCS_2.5\common`.
- `ConfigStorage` e `VCSBase` ficam fora, sob `{$IFNDEF JVCSCONSOLECLIENT}`.

#### 1.6 [MÉDIO] Tabela de strings `STRINGS.RES`

- O EXE e a DLL usam `LoadStr`/`FmtLoadStr` com IDs de 32 a ~310: 42 ocorrências em 26 units da DLL (Backup, MaintainUsers, Options, ProjAdmin etc.).
- `STRINGS.RC` está no repositório e recompila com brcc32/cgrc. Ele é declarado `LANG_GERMAN`, mas o conteúdo é inglês.
- Atenção: essas strings não passam pelo gettext. O hook do gettext pega `LoadResString`, não `LoadStr`.
- O próprio `Jedivcs.dpr:28` tem o TODO "replace strings.res => resource strings". Isso pode ficar para depois.

#### 1.7 [MÉDIO] Arquivos de ajuda

- O EXE e a DLL abrem `jedivcs.chm` em `sDLLDirectory` (`VCSBase.pas:125`, `VCSProcBase.pas:397`).
- O Diff abre `<exe>.chm`, ou seja, `JEDIVCSDiff.chm` (`DiffHelp.pas:62`).
- Nenhum CHM e nenhum fonte de ajuda (`.hhp`/`.rtf`) estão no repositório. Nas listagens do SourceForge só há PDFs de release notes.
- **O que fazer:** tentar extrair o CHM do instalador Inno 5.3.7, o que exige baixar o innoextract e portanto autorização do usuário. Se não houver CHM, esconder `Help`/F1, mantendo os IDs de `jedivcs.inc` e `jedivcsdiff.inc`.

#### 1.8 [MÉDIO] Quatro variantes de `compopt.inc` e diretivas problemáticas

- **Variantes:**
  - EXE: com o wrapper `{$ifdef DELPHI}`.
  - DLL: sem wrapper.
  - Diff: `DEBUG` comentado e `MEMCHECK`.
  - Console: `BETA`, `JVCSCONSOLECLIENT` e `APPTYPE CONSOLE`.
- Na base unificada, cada projeto precisa de uma pasta de include própria, e ela tem de vir antes no search path.
- **Diretivas a revisar:**
  - `{$IMAGEBASE $00400000}` entra no `JediVCSDLL.dpr:202`, então a DLL pede a mesma base do `bds.exe`. Remover e deixar no `.dproj`.
  - `{$DEFINE DEBUG}` fixo faz o build Release sair com `{$R+,Q+}` e com o JclDebug. Passar `DEBUG` para a configuração do `.dproj`.
  - Manter `{$J+}`, `{$T-}`, `{$Z1}`, `{$H+}` e `{$B-}`, que as famílias já pediram.

#### 1.9 [MÉDIO] Units RTL/VCL padrão

Nenhuma família tratou estas units: actnlist, buttons, checklst, classes, clipbrd, comctrls, commctrl, comobj, contnrs, controls, dialogs, extctrls, filectrl, forms, graphics, grids, imglist, inifiles, mask, math, menus, messages, registry, shellapi, stdctrls, syncobjs, sysutils, toolwin, variants, windows, além de activex, typinfo e consts.

- **Unit scope names no `.dproj`:** `Winapi;System.Win;System;Vcl;Vcl.Imaging;Vcl.Samples;Vcl.Shell;Data`. `Vcl.Samples` serve ao `TSpinEdit` e `Vcl.Shell` ao `TShellTreeView`.
- Todas existem do Delphi 11 ao 13.
- `FileCtrl` (8 units) gera os warnings W1005 de plataforma.
- `ComObj` só é usado sob `COMVERSION`, que está desligado.
- `IniFiles` é usado em `SMTPSend` e `FileFamilies`; `TIniFile` grava em ANSI.

#### 1.10 [MÉDIO] Auditoria Unicode do código próprio

As famílias cobriram os componentes, mas não fizeram uma varredura do código JVCS. Exemplos:

- `GetModuleFileName(HInstance, ModName, SizeOf(ModName))` passa um tamanho em bytes para uma API que espera caracteres:
  - `JVCSClientFunctions.pas:489` (`GetSelfFileName`, que alimenta o item 1.1);
  - `JVCSFunctions.pas:51`;
  - `VCSProcBase.pas:408`.
- O mesmo padrão aparece em `GetWindowsDirectory` (`JVCSBrowserFrame:186`), `GetVolumeInformation` (`JVCSClientFunctions:140`) e `DragQueryFile` (`ProjAdmin:5217`).
- `MS.Write(S[1], Length(S))` em `SimpleReport.pas:1010`.
- `Char in [...]` (W1050).

#### 1.11 [BAIXO] SMTP por pasta de saída

- `SMTPSend.PrepareSMTP` grava arquivos INI `fvcsmail_NNN.mail` em `<pasta do programa>\SMTP\` para um encaminhador SMTP externo, que não está no repositório.
- É ativado pela opção `SMTPMessages`. A pasta é criada em `Options.pas:3133`.
- Em `Program Files` a gravação cai na virtualização do UAC ou falha.
- **O que fazer:** manter desligado ou levar a pasta para `%APPDATA%`.

#### 1.12 [BAIXO] Artefatos de runtime não listados

- `JEDIVCSDiff.exe` ao lado do cliente: é a ferramenta de comparação padrão (`Options.pas:998`, `TextComp.pas:440`) e o About lê a versão dele.
- Migração legada: `VCSBase` copia `<exe>\Config\` para `%APPDATA%\JEDI\JVCS\Config\` (`VCSBase.pas:344-345`). Não é uma dependência, mas o comportamento deve ser preservado.
- `VerSet` chama `$(BDS)\bin\brcc32.exe`, que existe no 37.0.

#### 1.13 [BAIXO] Componentes que só aparecem em DFM

- Todas as 50 classes não-VCL encontradas nos DFMs de `jedivcs`, `jedivcsdll` e `jedivcsdiff` estão cobertas por alguma família. Todos os DFMs são texto.
- `OldCreateOrder` (93 DFMs) é ignorado pelo VCL 13 (`Vcl.Forms.pas:5915`, `DefineProperty ... IgnoreIdent`).
- Faltou dizer que `TmdSecureMail` (`ProjAdmin.dfm`), assim como `TAppSrvClient` e `TMWBuffer`, precisa de pacote design-time local para abrir o form no designer, ou então ser criado em código.

#### 1.14 [BAIXO, dados] DDL no clone

- Existe `Jedi VCS DB\2.5\mysql_create.sql`, apenas para MySQL, sem tabela de properties.
- Ele mostra `blobs.origcrc int(11)` com sinal, o que confirma que o `CRCInt` com sinal deve ser preservado.
- Mostra também `origsize`/`compsize int(11)`: o Int64 do console é truncado para 32 bits no servidor em arquivos de 2 GB ou mais.

---

### 2. Contradições entre famílias (com veredito)

| # | Tema | Conflito | Veredito (verificado) |
|---|---|---|---|
| C1 | VerSet/AnsiCrLf no EXE | JCL: "também usado pelo EXE". JVCL-visual e SynEdit: "só DLL". | Só DLL. As 3 referências do EXE estão sob `{$IFDEF IDEDLL}` (`jedivcs\ProjAdmin.pas:1122`, `ChkOutSingle.pas:190-193`, `MergeVersion.pas:141-143`). |
| C2 | Variáveis globais de formato | JCL: "só aviso". ICS: "provavelmente não compila". | Não compila (item 1.2). |
| C3 | Wrapper `{$ifdef DELPHI}` do `jedivcs\compopt.inc` | JVCL-visual: os defines "deixam de ser definidos". Componentes pequenos: "DELPHI vem do jedi.inc". | Componentes pequenos está correto. O jedi.inc define `DELPHI` sob `BORLAND`/não-BCB (https://raw.githubusercontent.com/project-jedi/jedi/master/jedi.inc), e um script confirmou que todas as `.pas`/`.dpr` incluem jedi.inc antes do compopt.inc. Mesmo assim, recomendo remover o wrapper. |
| C4 | CipherLz/Lzh | ICS: portar como cópia local com `PAnsiChar`. Compressão: remover. | Remover. As duas famílias concordam que é código morto (`EncryptServerData := False` fixo; o servidor só cifra se o pedido veio cifrado). Isso elimina a licença não comercial e o bug do `GetBit` em Win64. Deixar no `DBModule` só uma checagem de `#$FF` que gere erro. |
| C5 | Blowfish | Componentes pequenos: "sempre ativo desde 2010". Compressão: "opt-in em runtime". | Compressão está correta: `ChkInSingle.pas:1662`, `if EncryptModuleData then BlowFishEncode`. Só a compilação é incondicional. |
| C6 | Win64 da DLL e do expert | IDE: "x64 numa fase 2". JCL: "se usar a IDE 64, compilar a DLL Win64". Compressão e ICS: FVCSCrypt.dll só 32 bits, sem fonte; `FUserData: LongInt` trunca ponteiro. | Win64 está bloqueado, não é só adiado. Só existe com reimplementação da FVCSCrypt (caixa-preta) ou com um processo auxiliar de 32 bits. Escopo: Win32 e IDE de 32 bits. |
| C7 | ShareMem | Componentes pequenos: remover com `EXT_IDE_INTF`. IDE: exige teste (o histórico registra rollback por crash na IDE). | Remover só depois de desligar `REPORTDLL` e testar dentro do `bds.exe`; manter como plano B. |
| C8 | JCL/JVCL via GetIt no D13 | Componentes pequenos: "ainda não via GetIt (set/2025)". JCL e JVCL: "GetIt 2026.08". | A informação de 2026 é a mais nova, mas use o GitHub master para ter a mesma versão no 11, 12 e 13 (a JVCL relata erro F2613 vindo do GetIt). |
| C9 | Fonte do mwPasLex | Componentes pequenos: "recuperar do SVN do JVCS". SynEdit: "o SVN não existe mais". | Usar o CastaliaPasLex renomeado para `mwPasLex.pas` (família SynEdit). Consolidar o item numa família só. |
| C10 | Nome da DLL | IDE: "gera JvcsExternalDll.dll". Código: `library JediVCSDLL` e `cJVCSFileName = 'jedivcsdll.dll'` (`VCSBase.pas:117`); `JvcsExternalDll` só aparece em comentário (`dpr:145`). | O nome vem do instalador ou da saída do build. Fixá-lo no `.dproj` igual ao que o novo expert carrega. |
| C11 | Delphi instalado | Contexto da tarefa: "não instalado". Família IDE usa a instalação como evidência. | Está instalado: `Studio\37.0\bin\bds.exe`, `dcc32.exe`, `brcc32.exe` e `cgrc.exe` existem. A plataforma Win64 não está instalada. A regra de não compilar continua valendo. |
| C12 | Pastas de destino | JCL/JVCL-não-visuais: `src\common`. Compressão/SynEdit: `src\common\client`. Componentes pequenos: `src\comp\crc` e `src\comp\unknown`. JVCL-visual: `src\jedivcs` como base. IDE: units da DLL em `src\jedivcsdll`. | Layout único proposto: `src\comp\<terceiro>`; `src\common\client` (núcleo de protocolo para EXE, DLL, Diff e console); `src\common` (Language, VCSCommon do cliente); `src\jedivcs` (GUI única do EXE e da DLL, a partir das cópias de `jedivcsdll` mais as 7 units do item 1.3); `src\jedivcsdll` (só DLL); `src\jedivcsdiff`; `src\console`; `src\jvcsideexpert`; `src\res` (.rc); include por projeto para o `compopt.inc`. |

---

### 3. Ordem de port proposta (dependências primeiro)

#### Fase 0 — Linha de base e decisões (sem compilar)

1. **Captura golden** com o cliente oficial 2.5 Beta 3 contra o servidor Firebird do usuário: `GET_SERVER_TIME`, `LOGIN` (EXE e DLL), lista de projetos, check-in e check-out com blob, textos acentuados.
2. **Consultas no banco:**
   - `BLOBS.ORIGCRC` contra o CRC do ZIP, para validar o `Checksum`;
   - método do ZIP (0 ou 8);
   - blobs que não começam com `PK` (Blowfish);
   - formato do Line History;
   - `lc_ctype`.
3. **Decisões:**
   - Win32 com a IDE de 32 bits;
   - `REPORTDLL` desligado;
   - plugins desligados;
   - `LZH` removido;
   - `BRANCHING` desligado;
   - `LANGUAGE` usando `gnugettext.pas`.
4. **Montar a árvore v2026:**
   - base nas cópias de `jedivcsdll`, mais os itens do 1.3;
   - `.dpr` a partir de `ConverterBackup`;
   - jedi.inc fixado;
   - `compopt.inc` por projeto.
5. Com autorização do usuário: extrair do instalador `FVCSCrypt.dll`, os CHM e os binários de referência.

#### Fase 1 — Terceiros na IDE 37.0 (Win32)

1. JCL e depois a JVCL (para a transição).
2. ICS V9.7.
3. VirtualTreeView V8.5.
4. SynEdit, uma linha só.
5. `EncryptedZipFile`.
6. Castalia renomeado.

#### Fase 2 — Núcleo de protocolo sem VCL (`src\comp\midware` + `src\common\client`)

1. `MWDefs`/`RFormat` → `ApsCli` → `CBroker` (com o stub de `#$FF`).
2. `JVCSTypes`, `JVCSClientConsts`, `VCSCommon` (cópia do cliente) e `TZHandling` (corrigir `{$ifdef WINDOWS}`).
3. `Checksum` (validado contra o banco), `JVCSCrypt` com a DLL e `JVCSClientFunctions` (`StrMatches`).
4. `JVCSZipUtils` (`System.Zip`, preservando a data do item).
5. `JVCSClientObjBase` (com `FormatSettings` e `BlobAsText`).
6. `JVCSClientObj`, `JVCSNewClientObj`, `JVCSConnect`, `JVCSClientDispatcher` e `JVCSClasses`.

Testes: ida e volta do `RFormat` contra os bytes golden, CRC e leitura de blobs antigos.

#### Fase 3 — Console `jvcs.dpr`

Primeiro binário completo. Valida o protocolo de ponta a ponta (LOGIN com 239, sync por CRC, check-in e check-out). Não depende de JVCL, VT nem SynEdit, e é o único que pode ficar sem JCL.

#### Fase 4 — Infraestrutura comum da GUI

1. **Recursos:** `jvcsver.rc` com `ProductVersion` no formato `n.n.n.n` e resultado de pelo menos 2.2.0, `STRINGS.RC`, `CURSORS.RC`, ícone e manifesto.
2. **Units base:**
   - `JVCSForms`;
   - `VCSBase`, sem o `uses VCSProcBase`;
   - `ConfigStorage`;
   - `JVCSTrace` no lugar de `JVCSDebug`.
3. **Units com substituto nativo:**
   - `JVCSDialogs` (DSA nativo);
   - `JVCSMruList`;
   - `JVCSThreads`;
   - `JVCSLanguage` com gettext.
4. **Recursos de GUI e dados:**
   - `JVCSGUIClientResources` e `JVCSGUIClientImages`;
   - `DBModule`, com pacote design-time para `TAppSrvClient`, `TMWBuffer` e `TmdSecureMail`;
   - `VCSProcBase` (`HtmlHelpW`, `TOpenDialog`).
5. **Componentes pequenos:**
   - `RegAcc`, `RekScan`, `ItemProp`, `SMTPSend`;
   - `mdMailSlot` portado;
   - `ExtBugtracker` com `TRegEx`;
   - `SaveWIP`.

#### Fase 5 — JEDIVCSDiff

Depende das fases 2 e 4 (um subconjunto), do SynEdit e dos substitutos de `dfsStatusBar`, `FavOpenDialog` e `JvMruList`. É menor e serve de piloto para a migração de DFM e SynEdit. O EXE o chama como ferramenta de comparação.

#### Fase 6 — EXE `Jedivcs.dpr`, em lotes testados contra o servidor

1. Login/`Create` e o esqueleto do `ProjAdmin`: `TToolBar`, status bar, `EnhListView` compatível, mailslot e plugins desligados.
2. `ChkInSingle`, `ChkOutSingle`, `Syncronice`, `HandleBlob`, `Backup`.
3. History, Line History e Compressed Diff: VT V8, SynEdit, `DiffUnit`/`HashUnit`, `mwPasLex`.
4. Formulários de manutenção: troca dos controles JVCL visuais.
5. Restante.

#### Fase 7 — DLL `JediVCSDLL` (Win32, `IDEDLL;EXT_IDE_INTF`)

- `JVCSIDEInterface` e `JVCSIDEInterfaceCommon` (ABI `PAnsiChar`, `{$Z1}`).
- `JVCSIDESettings` (BDS 22, 23 e 37).
- `VerSet` (`AnsiCrLf` vira `sLineBreak`), `Recent`, `UsedComponents`.
- `JVCSDLLOperations` e `JVCSDLLFileHistoryImpl`.
- Decisões sobre ShareMem e sobre o nome do arquivo de saída.

#### Fase 8 — Expert ToolsAPI

Pode começar logo após a Fase 0, carregando a DLL original do instalador para isolar erros. Primeiro `JvcsExpertBDS37.dll` (IDE de 32 bits), depois BDS22 e BDS23.

#### Fase 9 — Delphi 11/12 e empacotamento

Instalador, chaves `Experts`, `FVCSCrypt.dll`, CHM, `locale`, mesma versão dos terceiros via GitHub.

#### Fase 10 — Opcional

Retirar a JVCL residual, PerMonitorV2, tradução pt_BR e branching. Win64 só com FVCSCrypt reimplementada.

---

### Evidências principais

**Locais:**
- `...\jedivcsdll\Create.pas:534`
- `...\jedivcsdll\VCSProcBase.pas:1400-1416`
- `...\Jedi VCS Server\2.5\SrvOBJMain.pas:407/419`
- `...\common\VCSCommon.pas:111`
- `...\jedivcs\jvcsver.rc`
- `...\jedivcsdll\JediVCSDLL.dof` (SearchPath)
- `...\jedivcsdiff\JEDIVCSDiff.dof` (SearchPath com `..\jedivcs`)
- `...\jedivcs\VCSBase.pas` / `...\jedivcsdiff\VCSBase.pas` (implementation `uses VCSProcBase`)
- `...\jedivcs\jedivcs.inc`
- `...\jedivcs\STRINGS.RC`
- `...\jedivcsdll\SMTPSend.pas`
- `...\Jedi VCS DB\2.5\mysql_create.sql`
- `C:\Program Files (x86)\Embarcadero\Studio\37.0\source\rtl\sys\System.SysUtils.pas:983-1001`
- `...\37.0\source\vcl\Vcl.Forms.pas:5915`

**Web:**
- https://raw.githubusercontent.com/project-jedi/jedi/master/jedi.inc
- https://sourceforge.net/projects/jedivcs/files/
- https://sourceforge.net/projects/jedivcs/files/2.5x%20Beta%203/
- https://sourceforge.net/projects/jedivcs/files/OldFiles/
- https://jedivcs.sourceforge.net/downloads.html

### Situação dos apontamentos do crítico na árvore v2026

Conferido em 2026-10-12 contra `doc\pt\common\manifesto-origem.csv`, `README.md`, `tools\LEIAME-compilar.md`, `3rdparty\` e `src\` (fora de `_legacy`), sem compilar:

| Apontamento | Situação na v2026 | Onde é tratado no plano |
|---|---|---|
| 1.1 Versão do cliente no LOGIN | Pendente. `src\jedivcs\Jedivcs.dpr` tem `{$R *.res}` (l.263) e `{$R jvcsver.res}` (l.264), então o risco de VERSIONINFO duplicado com o `.dproj` existe. | F0 (`.dproj` sem VerInfo) e F3 (recursos) |
| 1.2 `DecimalSeparator`/`ThousandSeparator` | Pendente (pontos de `JVCSClientObjBase`, `VCSProcBase`, `ProjAdmin`, `Std_ListView`). | F2 (núcleo) e F3/F4 (GUI) |
| 1.3 Units/includes que faltavam à DLL | **Resolvido pela estrutura.** `JVCSForms.pas` está em `src\common`. `Password`, `ParsePG`, `OpenProject`, `SaveWIP`, `ExtBugtracker`, `JVCSManageFavorites`, `jedivcs.inc`, `CURSORS.RC/.RES`, `STRINGS.RC/.RES` e `ICON.RES` estão em `src\jedivcs`, a pasta da DLL. | F5 (só conferir o search path do `.dproj`) |
| 1.4 Diff arrasta o núcleo da GUI | Parcial. As cópias Lazarus mutiladas não existem mais (a v2026 usa as de `jedivcsdll`). Mas o `JEDIVCSDiff.dpr` ainda referencia `..\jedivcs\listview.pas`, `vcsbase.pas`, `configstorage.pas` e `JVCSGUIClientResources.pas`, e o `uses VCSProcBase` de `VCSBase` continua. | F3 |
| 1.5 Dependências do console | **Resolvido pela estrutura.** `JVCSNewClientObj` está em `src\common\client` e `VCSCommon.pas` (cópia do cliente) em `src\common`; `jvcs.dpr` usa `..\Jedivcs\JVCSClasses.pas`. | F2 |
| 1.6 `STRINGS.RES` | Presente (`src\jedivcs\STRINGS.RC/.RES`). | F3 |
| 1.7 Arquivos de ajuda (CHM) | **Resolvido.** `jedivcs.chm` e `jedivcsdiff.chm` foram copiados da instalação 2.5.0.1030 para `3rdparty` (ver `3rdparty\LEIAME.md`). | F5 (instalador) |
| 1.8 Variantes de `compopt.inc` | `src\jedivcs\compopt.inc` é a versão `ConverterBackup` (sem wrapper `DELPHI`; `EXT_IDE_INTF` comentado; `REPORTDLL`, `BLOWFISH`, `DEBUG` e `MIDWARE` definidos) e é compartilhado por EXE e DLL. Diff e console têm o próprio. | F0 (defines por `.dproj`) |
| 1.9 Unit scope names | Parcial. O `tools\compilar.bat` já passa `-NS` (Winapi;System.Win;…;Vcl.Shell); falta nos `.dproj` novos. | F0 |
| 1.10 Auditoria Unicode do código próprio | Pendente. | F2–F5 (por lote) |
| 1.11 SMTP por pasta | Pendente (manter desligado ou levar para `%APPDATA%`). | F4 |
| 1.12 Artefatos de runtime | Pendente (`JEDIVCSDiff.exe` ao lado do cliente, migração de `Config\`, `brcc32`). | F4/F5 |
| 1.13 `TmdSecureMail` no designer | Pendente (pacote em `src\packages`). | F1/F3 |
| 1.14 DDL | Informativo (`origcrc` com sinal; `origsize`/`compsize` 32 bits). | Seção 4 |
| C10 Nome da DLL | O binário original instalado é `JvcsExternalDll.dll` (`3rdparty\referencia-2.5.0.1030`), confirmando a família IDE quanto ao nome distribuído. O código continua com `library JediVCSDLL` e `cJVCSFileName = 'jedivcsdll.dll'` (`src\jedivcs\VCSBase.pas:113`). Fixar o nome de saída no `.dproj`. | F0/F5 |
| C11 Delphi instalado | Confirmado. Além disso, JCL/JVCL 2026.08, ICS 9.7, VT 8.3, SynEdit 2025.03 e Abbrevia 2026.10 foram instalados via GetIt no D13.2 (`README.md`). | F0 |
| C12 Layout de pastas | Prevalece a estrutura já criada: `src\jedivcs` (EXE + DLL), `src\jvcs` (console), `src\common`, `src\common\client`, `src\comp\*`, `src\packages`, mais `src\jvcsideexpert` (a criar). Não serão criados `src\jedivcsdll`, `src\console` nem `src\res`. | — |
| TZHandling (família JCL) | A v2026 usa a cópia de `jedivcsdll` (`src\common\client\TZHandling.pas`), sem `{$ifdef WINDOWS}`. O único `{$ifdef WINDOWS}` restante está em `src\common\JVCSIDESettings.pas:95`. | F5 |
