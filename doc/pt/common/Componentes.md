# Componentes e bibliotecas: tabela consolidada

Visão única de **todos** os componentes, bibliotecas, units e binários de runtime do cliente JEDI VCS 2.5 Beta 2026. Este documento resume e aponta; o detalhe (notas por unit, riscos, evidências) fica em [Inventario-Componentes.md](Inventario-Componentes.md), e a execução em [Plano-de-Port.md](Plano-de-Port.md). Versões do ambiente: [Versoes.md](Versoes.md).

Estado verificado em **12/10/2026** (leitura do registro da IDE, do `CatalogRepository`, do disco e do `git log`).

## Legenda

- **Situação**
  - `instalado`: presente e registrado na IDE do Delphi 13.2 (BDS 37.0).
  - `fixado`: fonte copiado para o repositório numa versão/commit exato e instalado a partir dele.
  - `a portar`: cópia local existente que precisa de ajustes (Unicode, Win64, API nova).
  - `a recriar`: unit ausente, sem fonte em lugar nenhum; precisa ser escrita.
  - `a substituir por nativo`: sai do cliente; entra VCL/RTL.
  - `remover`: código morto, resíduo do port Lazarus ou só do servidor.
  - `ponte`: instalado só para compilar cedo; sai numa fase posterior.
- **Onde está**: caminhos relativos a `D:\Delphi\JediVCS\v2026`, salvo indicação. `CatalogRepository` = `%USERPROFILE%\Documents\Embarcadero\Studio\37.0\CatalogRepository`. `<clone>` = `D:\Delphi\JediVCS\Fontes_JediVCS_2.5`.
- **Licença**: conforme [Licencas.md](Licencas.md) e os cabeçalhos dos fontes. "n/r" = o inventário não registra a licença; verificar antes de redistribuir.

---

## 1. Bibliotecas externas instaladas na IDE

| Nome | Versão exata | Origem | Onde está | Papel no cliente | Situação | Licença | Substituição nativa planejada |
|---|---|---|---|---|---|---|---|
| JCL (JEDI Code Library) | 2026.08 | GetIt `JEDICodeLibraryJCL-13` | `CatalogRepository\JEDICodeLibraryJCL-13\2026.08` (DCUs em `lib\d37\win32`; fontes em `source\*`) | Utilitários do núcleo (`TraceMsg`, `StrToken`, `StrMatches`, `JclSysInfo`, `JclSecurity`, `JclPCRE`, `JclSimpleXml` do Line History); experts da JCL na IDE | instalado; dependência externa de transição | MPL 1.1 | Helpers próprios `JVCSTrace`, `JVCSStrUtils`, `JVCSFileUtils` (F2); `TRegEx` no lugar de `JclPCRE`; `TPath`/`GetModuleFileName` no lugar de `JclSysInfo`. A `JclSimpleXml` do Line History é mantida (risco R11). O console `jvcs.exe` deve ficar sem JCL |
| JVCL (JEDI Visual Component Library) | 2026.08 | GetIt `JEDIVisualComponentLibraryJVCL-13` | `CatalogRepository\JEDIVisualComponentLibraryJVCL-13\2026.08` (DCUs em `lib\D37\win32`) | Controles visuais (47 DFMs do EXE/DLL e 3 do Diff) e não visuais (`JvDSADialogs`, `JvGnugettext`, `JvMRUList`, `JvSearchFiles`, `JvPluginManager`) | instalado; **ponte** (sai nas fases F2–F4) | MPL 1.1 | VCL nativa: `TEdit`, `TToolBar`, `TSpeedButton`+`PopupMenu`, `TShape`, `TTreeView` com `CheckBoxes`, `TSplitter`, `TButtonedEdit`+`TOpenDialog`, `TColorBox`, `TTrackBar`; `JvGnugettext` → `gnugettext.pas` do dxgettext; `JvDSADialogs` → `JVCSDialogs` nativo. Detalhe em [Inventário 3.4 e 3.5](Inventario-Componentes.md) |
| ICS for VCL (Overbyte) | 9.7 | GetIt `ICS_VCL-13` | `CatalogRepository\ICS_VCL-13\9.7` (DCUs em `Lib\<cfg>\<plat>\37.0`; `Source`, `Source\Include`) | Transporte TCP do Midware (`OverbyteIcsWSocket`, `OverbyteIcsTypes`); `OverbyteIcsPing`/`OverbyteIcsIcmp` (substituem `Ping`/`Icmp`) | instalado; **fica** | Freeware (Overbyte) | Nenhuma: é o transporte. O `OverbyteIcsDefs.inc` precisa de `MSCRYPT_*` desligados se aparecer E2203 |
| Abbrevia (TurboPack) | 2026.10 | GetIt `Abbrevia-13` | `CatalogRepository\Abbrevia-13\2026.10` (DCUs em `packages\11AndAbove\Delphi\<plat>\<cfg>`) | Compactação ZIP dos blobs e Backup com senha (`TJVCSAbZipper`, `BlobAsText`, `ExtractBlob*`) | instalado; **ponte** (sai na F2) | n/r no inventário (projeto TurboPack, código aberto) | `System.Zip.TZipFile` + `uEncryptedZipFile` (Uwe Raabe, MIT) + `JVCSZipUtils` (novo) |
| SynEdit (pyscripter) | commit `84391a3b9fd8ed86bf0d928703c0cf42d56524ac` (2025-11-24) | GitHub `pyscripter/SynEdit` | `src\comp\synedit` (`Source`, `Source\Highlighters`, `Packages\Alexandria+\Delphi`). Compilado em `lib\synedit\<plat>\<cfg>`; BPL em `lib\bpl\Win32` | Editor de texto do Diff, Line History, Compressed Diff e visualizações | fixado; instalado na IDE (`SynEditDD370.bpl`, runtime `SynEditDR370.bpl`) | MPL 1.1 / GPL 2 | Nenhuma (componente mantido). Não editar os fontes; ajustes vão em units do JVCS. Única linha que compila igual em Delphi 11, 12 e 13 |
| Virtual-TreeView (JAM Software) | V8.5 (commit `eb27351b454ce330007d6c80f13250aa7e939918`, 2026-10-01) | GitHub `JAM-Software/Virtual-TreeView` | `src\comp\virtualtreeview` (`Source`, `Design`, `Resources`, `Packages\RAD Studio 10.4+`). Compilado em `lib\virtualtreeview\<plat>\<cfg>`; BPL em `lib\bpl\Win32` | Árvores do Project Tree, Browser, History | fixado; instalado na IDE (`VirtualTreesD370.bpl`, runtime `VirtualTreesR370.bpl`) | MPL 1.1 / LGPL 2.1 | Nenhuma. Os handlers `OnGetText`/`OnHeaderClick` do V8 têm assinatura nova (risco de corrupção silenciosa de memória; ver Plano F4) |

### Removidos / substituídos na IDE (12/10/2026)

| Nome | Versão | Origem | Situação | Observação |
|---|---|---|---|---|
| SynEdit TurboPack | 2025.03 | GetIt `SynEdit-13` | **removido** | Pasta `SynEdit-13` não existe mais no `CatalogRepository`. BPL antigos em backup |
| Virtual Treeview (JAM) | 8.3 | GetIt `VirtualTreeview_by_JamSoftware-13` | **removido da IDE** | Os pacotes não estão mais em `Known Packages`, mas a pasta `CatalogRepository\VirtualTreeview_by_JamSoftware-13\8.3` ainda existe e o `EnvOptions.proj` ainda a cita no Library Path. Em 13/10/2026 o `EnvOptions.proj` já não citava a pasta |

---

## 2. Cópias locais em `src\comp` (a portar ou a obter)

| Nome | Versão exata | Origem | Onde está | Papel no cliente | Situação | Licença | Substituição nativa planejada |
|---|---|---|---|---|---|---|---|
| Midware: `ApsCli`, `RFormat`, `CBroker`, `MWDefs.inc` (F. Piette) | ApsCli 3.06, RFormat 1.48, CBroker 1.07a (V3 do clone). Referência do port: OverbyteApsCli 7.00 / OverbyteRFormat 7.02 (SVN rev. 52) | `<clone>\Components\` | `src\comp\midware` | Protocolo cliente-servidor: formato `TMWBuffer` e `TAppSrvClient`. Não compila no D13 e mandaria UTF-16 pela rede | a portar (F1): `PAnsiChar`, code page fixa (provável 1252), eventos `PAnsiChar`, ICS V9. Edições Lazarus (`-oFL`) a reverter | **Freeware só para uso não comercial**; versões alteradas devem ser marcadas; decisão comercial adiada | Não há nativo equivalente. Transporte isolado atrás de `src\common\client\JVCSTransport.pas` (a criar) para permitir troca futura mantendo os mesmos bytes (exige reimplementação "clean-room" do `TMWBuffer`) |
| mdMailSlot (`TmdMailSlot`, `TmdSecureMail`) | 1.17 (Martin Djernæs) | `<clone>\Components\mdmailslot.pas` | `src\comp\mdmailslot` | Notificação entre estações (mailslot). Recurso desligado por decisão ("só o básico") | a portar (F4), se o recurso voltar | n/r | Sem nativo. `AnsiString`/`PAnsiChar`, formato de rede preservado. Mailslot remoto vem desabilitado no Windows 11 24H2 |
| TDiff / HashUnit (`diffunit.pas`, `hashunit.pas`) | TDiff 2.5.1 (Angus Johnson, 22/06/2005) | `<clone>\Components\` | `src\comp\textdiff` | Algoritmo de diff do Compressed Diff e do Line History | a portar (F4): `TArray<Integer>` nos chamadores (Win64), hash sobre todos os bytes | n/r | Alternativa mantida: `rickard67/TextDiff` (commit 2026-08-10) |
| `Checksum.pas` (`CRCInt`, `CRCString`) | n/a (unit ausente) | Recriar | `src\comp\crc` (só `LEIAME.md` por ora) | CRC32 gravado no servidor (`BLOBS.ORIGCRC`) e comparado em check-out, sync, dirty-check e busca por CRC | **a recriar** (F2). Candidata: `System.ZLib.crc32`. **Bloqueante** se não bater com os CRCs reais | Código próprio | `System.ZLib.crc32` só se provado idêntico ao antigo |
| `mwPasLex`, `mwPasLexTypes` | n/a (ausentes). Substituto: CastaliaPasLex (commit único de 2011-10-12) | GitHub `jacobthurman/Castalia-Delphi-Parser` | `src\comp\mwtools` (só `LEIAME.md` por ora) | Lexer Pascal de `UsedUnits`, `ProjDependencies`, `ToDo`, `VerSet` | **a obter** (F0): copiar e **renomear** as units (exigência do README do Castalia para add-ins da IDE) | MPL 1.1 | Alternativa: `DelphiAST` `SimpleParser.Lexer` (sem `LineNumber`) |
| `uEncryptedZipFile` e cifrador PKWARE | n/a | GitHub `UweRaabe/EncryptedZipFile` | `src\comp\encryptedzip` (pasta a criar) | Backup com senha sem Abbrevia (ZipCrypto) | **a obter** (F0) | MIT | Complementa `System.Zip` |
| `gnugettext.pas` (dxgettext) | r196 (2026-08-19) | SourceForge `dxgettext` (trunk) | `src\comp\dxgettext` (pasta a criar) | Tradução (`LANGUAGE`); hoje `JvGnugettext` da JVCL | **a obter** (F0/F3). Recurso de tradução está desligado por decisão | n/r (dxgettext) | Pode ser desligado sem perda: não há `.po/.mo` no repositório |
| `jedi.inc` | fixado de `project-jedi/jedi` (define `VER370`/`DELPHI37`, não define `WINDOWS`) | GitHub `project-jedi/jedi` | `src\common\jedi.inc` (a criar) | Defines de versão do compilador usados pelas units do JVCS | **a obter** (F0) | MPL 1.1 | n/a |
| DEC (Delphi Encryption Compendium) | 6.4.1 | GitHub `MHumm/DelphiEncryptionCompendium` | (nenhuma cópia) | Blowfish dos blobs, **só se** a varredura do banco achar blobs Blowfish | condicional (F0 0.7 / F2 2.3) | n/r | Stub que devolve `False` e opção desativada na UI é a alternativa |
| `src\comp\_legacy` | `Components\` do clone, intacto | `<clone>` | `src\comp\_legacy` (`COM`, `Trash`, `Win32`, `Win64`) | **Somente referência**; fora do search path | referência | vários | n/a |

---

## 3. Units ausentes e sua destinação

Units que o código referencia e que **não existem** em lugar nenhum (nem fonte nem DCU). Lista de [LEIAME-Origem.md](LEIAME-Origem.md) e [tools\LEIAME-compilar.md](../../../tools/LEIAME-compilar.md); detalhes em [Inventário 3.8](Inventario-Componentes.md).

| Unit | Quem usa | Origem original | Situação | Licença | Substituição nativa planejada |
|---|---|---|---|---|---|
| `Checksum` | check-in/out, sync, dirty-check | FreeVCS ("Turbo Pascal Programmers Page") | a recriar (ver seção 2) | n/a | `System.ZLib.crc32`, se idêntico |
| `BFCrypt` (`Base64Encode/Decode`, `BlowFishEncode/Decode`) | `Create`, `Options`, `HandleBlob`, `ChkInSingle` | FreeVCS | a recriar (F2 2.3) em `src\common\client` | n/a | Base64: `TBase64Encoding.Create(0)`. Blowfish: conforme a varredura (stub ou DEC 6.4.1) |
| `mwPasLex`, `mwPasLexTypes` | `UsedUnits`, `ProjDependencies`, `ToDo`, `VerSet` | Martin Waldenburg (MPL) | a obter via Castalia (seção 2) | MPL 1.1 | n/a |
| `EnhListView` (`TdfsEnhListView` 3.72) | 18 listas em 15 forms do EXE; 20 objetos na DLL | DFS (Brad Stowers) | a substituir por nativo | DFS: proíbe redistribuir fonte modificado isolado | `TJVCSListView` próprio (`TListView` + `AutoColumnSort`, setas `HDF_SORTUP/DOWN`, `OnSortItems`, `Resort`); registro em `src\packages`. Os 9 handlers `OnDrawItem` precisam ser renomeados |
| `SystemTreeView`, `SystemControlPack` (`TdfsSystemTreeView` 0.98.5) | `SelectFolder` | DFS | a substituir por nativo | DFS (idem) | `TShellTreeView` criado em runtime, ou `TFileOpenDialog` com `fdoPickFolders` |
| `dfsStatusBar` (`TdfsStatusBar` 1.24) e `DFSKb` | `ProjAdmin`, `Syncronice`, `DiffMain` (gauge em 3 forms) | DFS | a substituir por nativo; `DFSKb` remover | DFS (idem) | `TStatusBar` + `TProgressBar` (`pbstMarquee`), painéis owner-draw com `DT_END_ELLIPSIS`, clique/hint por hit-test |
| `FavOpenDialog` (`TFavOpenDialog`, `TFavSaveDialog`, v0.2 Markus Stephany) e `myfdlg.res` | `VCSProcBase`, `DiffSimpleReport` | Markus Stephany | a substituir por nativo | n/r | `TOpenDialog` / `TSaveDialog` (o `TFavSaveDialog` **não** descende de `TSaveDialog`); MRU em `InitialDir` + lista própria |
| `HtmlHlp` | ajuda (DLL e Diff) | tradução de Marcel van Brakel (JEDI) | a substituir por nativo | n/r | `HtmlHelpW` declarado localmente (`HH_HELP_CONTEXT = $000F`) |
| `RegAcc` | `DiffSimpleReport` | FreeVCS | a substituir por nativo | n/r | `TRegistry` com helpers tolerantes a tipo, mesma chave `HKCU\Software\JEDI\JEDIVCSDiff` |
| `RekScan` (`FindRecursive`) | `CompareFolders` | FreeVCS | a substituir por nativo | n/r | `FindFirst`/`FindNext` próprio (semântica inferida: `Path` com barra final, `False` aborta) |
| `ItemProp` (`PerformDefaultAction`) | `LoadModule` ("Abrir com"); morta no `DiffMain` | FreeVCS | a substituir por nativo | n/r | `SHOpenWithDialog` ou `ShellExecute` com verbo `openas` |
| `SortGrid` | só no `uses` de `History` (referência morta) | terceiros | remover do `uses` | n/r | n/a |
| `FastMM4` | `Jedivcs.dpr`, `JEDIVCSDiff.dpr`, `jvcs.dpr` | `src\comp\fastmm` (não existe) | **remover** | MPL/LGPL (FastMM4); FastMM5 é GPL v3 ou comercial: não usar em binário distribuído | Gerenciador de memória embutido + `ReportMemoryLeaksOnShutdown` sob `DEBUG`. **Erro atual do build** |
| `Ping`, `Icmp` | `Create.pas` | ICS antigo | compilam com o define `OVERBYTEV6_UP` | freeware (ICS) | `OverbyteIcsPing`/`OverbyteIcsIcmp` do ICS V9 |
| `WSocket` (em `ApsCli.pas`, sem condicional) | Midware | ICS antigo | corrigir no port do Midware (F1) | freeware | `OverbyteIcsWSocket` |
| `CipherLz`, `Lzh` | Midware/`DBModule` (`{$DEFINE LZH}`) | Midware 1.01 / P. Lanzoni | **remover** (código morto; resposta `#$FF` vira erro explícito) | CipherLz exclui uso comercial | n/a |
| `ThemeMgr`, `ThemeSrv`, `winxp.res` | `Jedivcs.dpr:268`, `JEDIVCSDiff.dpr:80`, forms | Soft Gems | **remover** | n/r | `Vcl.Themes` + manifest |
| `ToolIntf`, `VCSIntf`, `EditIntf` (OTA antiga) | DLL, só sem `EXT_IDE_INTF` | Delphi antigo | **remover**; manter `IDEDLL;EXT_IDE_INTF` no `.dproj` | n/a | `ToolsAPI` no novo expert |
| `JVCSClient_TLB`, `JVCSCOMStream` | `COMVERSION` (não definido) | próprio | remover | n/a | n/a |
| `Report` (`jedivcsreport.dll`) | `REPORTDLL` (impressão de relatórios) | próprio, sem fonte | **desligar/remover**; nunca distribuir a DLL antiga | n/a | `SimpleReport` (opcional) |
| `ExceptDlg` | `JCL_DEBUG_DATA` (não definido) | template JCL | remover (desligado) | MPL 1.1 | opcional, do JCL atual |
| `StrUtilsD5`, `LOProp`, `LOPropIm`, `PrmProp`, `MemCheck`, `InterfaceBase`, `LCLIntf`/`LCLType`/`LMessages`, `SynHighlighterMPerl` | resíduos | Midware design-time, Lazarus, etc. | remover | n/r | `System.StrUtils`; `ReportMemoryLeaksOnShutdown`; `.dpr` de `ConverterBackup` (pré-Lazarus) |
| `ShareMem` | `JediVCSDLL.dpr:213` | RTL (`borlndmm.dll`) | decidir na F5 (plano A: remover com `EXT_IDE_INTF` e testar no `bds.exe`) | n/a | API plana com buffers do chamador |

---

## 4. Binários de runtime e de referência

| Arquivo | Versão | Origem | Onde está | Papel | Situação | Distribuir? | Observação |
|---|---|---|---|---|---|---|---|
| `fvcscrypt.dll` | 1.0.0.19 (63.488 bytes, 32 bits, fechada). SHA-256 `3EFC867A21B50055F345F880BDA8E3DB3766F4F749A73AE08E80E4EC4DD35D6F` | Instalação oficial 2.5.0.1030 | `3rdparty\fvcscrypt.dll`; cópia em `bin\ideclient\Win32` | Cifra da senha no login (`JVCSCrypt.pas`); o servidor compara com a `ServerCrypt.dll` | presente | **Sim**, ao lado do EXE/DLL | Binário fechado do FreeVCS/JEDI VCS. Sem fonte: **bloqueia Win64/ARM64EC** (F6) até reimplementar por caixa-preta ou isolar em processo de 32 bits |
| `ServerCrypt.dll` | n/a | Servidor 2.5 Beta 3 | no servidor (não portado) | Contraparte da `fvcscrypt` | n/a | n/a | Não faz parte do cliente |
| `jedivcs.chm`, `jedivcsdiff.chm` | n/a (358.704 e 20.444 bytes) | Instalação oficial | `3rdparty` | Ajuda (F1) | presente | Sim | CHM com MOTW ou em rede é bloqueado pelo Windows |
| `ffdef.jvcs`, `ulist.jvcs`, `vcllist.jvcs`, `vcllistbcb.jvcs`, `verinf.jvcs` | n/a | Instalação oficial | `3rdparty` | Listas e definições padrão | presente | Sim | |
| `htm_rep.htm` | n/a | Instalação oficial | `3rdparty` | Modelo de relatório HTML | presente | Sim | |
| `JvcsExternalDll.dll` | 2.5.0.1030 (5.938.688 bytes, Delphi 2007, ANSI) | Instalação oficial | `3rdparty\referencia-2.5.0.1030`; carregada pelo expert novo em `bin\ideclient\Win32` | Cliente completo dentro da IDE (ABI expert↔DLL) | referência; usada pelo expert enquanto a DLL não é portada | Só como referência/teste | Substituída pela `JediVCSDLL` portada na F5 |
| `JvcsExpertBDS19/20/21.dll` | 2.5.0.1030 | Instalação oficial | `3rdparty\referencia-2.5.0.1030` | Experts originais (Delphi 10.2/10.3/10.4); referência de comportamento | referência | Não | Análise em [Expert-IDE-Analise.md](../client/Expert-IDE-Analise.md) |
| `jedivcs.exe`, `jedivcsdiff.exe`, `jvcs.exe` | 2.5.0.1030 | Instalação oficial | `3rdparty\referencia-2.5.0.1030` | Cliente oficial para a captura "golden" de tráfego | referência | Não | |
| `JvcsExpertBDS37.dll` | 2.5.0.2026 (ProductVersion "2.5 Beta 2026") | Compilado aqui (`tools\compilar-expert.bat`) | `bin\ideclient\Win32` (fonte em `src\jvcsideexpert`) | Expert novo para BDS 37 | **em andamento** (compila; sem teste na IDE) | Futuramente, via instalador | Importa `rtl370`, `vcl370`, `designide370` |
| `zipdll.dll`, `unzdll.dll` | 1.4.0.0 (DelZip) | Instalação oficial | cópia em `bin\ideclient\Win32` (necessárias à `JvcsExternalDll` original) | Compactação da DLL original | só para a DLL original | **Não** no cliente novo | Substituído por `System.Zip` |
| `borlndmm.dll` | 6.0.6.163 | Instalação oficial | só na instalação oficial | Gerenciador de memória compartilhado (ShareMem) | não copiada | **Não** | |
| `jedivcsreport.dll` | n/a | n/a | não existe na instalação | Relatórios (`REPORTDLL`) | n/a | **Nunca** | RTL antiga causaria AV |
| `pcre3.dll` | n/a | JclPCRE | n/a | Regex da JCL | dispensada | Não | `TRegEx` elimina a dependência |

---

## 5. Plataforma e RTL/VCL nativas usadas

Delphi 13.2 Florence Professional (compilador 37.0.60952.8797; também Delphi 11 e 12 no futuro). Não são "componentes" instaláveis, mas são o destino das substituições:

- RTL: `System.Zip`, `System.ZLib`, `System.NetEncoding`, `System.Hash`, `System.RegularExpressions`, `System.StrUtils`, `System.IOUtils` (`TPath`), `System.Win.Registry`.
- VCL: `Vcl.ComCtrls`, `Vcl.StdCtrls`, `Vcl.ExtCtrls`, `Vcl.CheckLst`, `Vcl.Samples.Spin`/`Vcl.NumberBox`, `Vcl.Dialogs`, `Vcl.Shell.ShellCtrls`, `Vcl.Themes`, `Vcl.Printers`.
- ToolsAPI (designide 370/290/280 conforme a IDE) para o expert.

## 6. Código próprio novo previsto (sem origem externa)

`JVCSTransport.pas`, `JVCSZipUtils.pas`, `BFCrypt.pas`, `Checksum.pas`, `JVCSTrace.pas`, `JVCSStrUtils.pas`, `JVCSFileUtils.pas`, `TJVCSListView`, helper de status bar, `src\packages\JVCSMidwareD.dpk`, `src\jvcsideexpert\*` (existente, em andamento) e `setup\*.iss`. Lista completa no apêndice do [Plano-de-Port.md](Plano-de-Port.md).
