# Cliente standalone JEDI VCS 2.5.0.1030: inventário do build por engenharia reversa

> Escopo: análise **estática e somente leitura** de `jedivcs.exe` (GUI standalone), `jedivcsdiff.exe`
> (Diff/Merge) e `jvcs.exe` (console), em `3rdparty\referencia-2.5.0.1030` (instalador
> *JVCS v2.50 Client Setup Beta 3*). Nenhum binário do JVCS foi executado e nada foi gravado no
> registro.
>
> Método: o mesmo de [Expert-IDE-Analise.md](Expert-IDE-Analise.md). Um parser PE/recursos escrito em
> C# e carregado no PowerShell (`Add-Type`) lê cabeçalhos, seções, imports, `VS_VERSION_INFO` e
> `PACKAGEINFO`, extrai strings ASCII e UTF-16 e converte os DFM binários (`TPF0`) para texto.
> Complementa [Algoritmos-Recuperados.md](Algoritmos-Recuperados.md) (CRC, Base64/Blowfish, protocolo).
>
> Neste documento, **"fonte"** é a árvore `src\` da v2026 (origem: clone de 2017, ver
> [LEIAME-Origem.md](../common/LEIAME-Origem.md)). **"Binário"** é o build oficial de 2010.

---

## 1. Resumo executivo

1. **Compilador: Delphi 2007 (VER185, ANSI) nos três EXEs**, o mesmo da `JvcsExternalDll.dll`.
   - Os três foram linkados em sequência em 2010-02-07 18:25 UTC (`BuildTimestamp` 31.01.2010).
   - VERSIONINFO: 2.5.0.1030, "2.5.0 Beta 3".
   - Os três são monolíticos: sem runtime packages, imports só de DLLs do Windows, e o FastMM4 está
     linkado em todos.
2. **Bibliotecas e versões do build oficial:**

   | Biblioteca | Versão |
   |---|---|
   | JCL | **1.102 Build 3072** |
   | JVCL | 3.x (provável 3.34, a que saiu junto com a JCL 1.102) |
   | ICS | **TWSocket V5.31** (não 5.28) |
   | Midware | TMWBuffer **1.48**, TAppSrvClient **3.06**, TResponseBroker **1.07a**: batem com `src\comp\midware` |
   | Abbrevia | **3.05** |
   | SynEdit | 2.0.x, pré-Unicode |
   | Virtual Treeview | **soft-gems 4.8.x** ("© 1999, 2009 Mike Lischke") |
   | DFS | EnhListView 3.72, StatusBar 1.24, SystemTreeView 0.98.5 |
   | outras | mdMailSlot 1.17, mwPasLex 2.2, FavOpenDialog 0.2 |

3. **Units do PACKAGEINFO**: 485 (`jedivcs`), 289 (`jedivcsdiff`) e 114 (`jvcs`). Pontos que
   mudam o inventário:
   - **CipherLz/Lzh estão compilados** no GUI e no Diff (`{$DEFINE LZH}` ativo em `DBModule.pas:60`).
   - **BFCrypt traz `Blowunit` + `Cryptcon`** (CryptoLib `TBlowFish`) no GUI. O Diff e o console
     não têm BFCrypt.
   - O SystemTreeView arrasta `PidlHelp`, `FileChange`, `MaskSearch`, `SystemControlPack` e
     `_RES__IDS`.
   - O EnhListView arrasta `ExtListView`.
   - O `jedivcsdiff` usa `RegAcc` e `ItemProp`.
   - O `jvcs.exe` também linka a JCL (19 units Jcl\*) e a Abbrevia (31 units Ab\*).
4. **107 forms extraídos e convertidos** (98 do `jedivcs.exe` e 9 do `jedivcsdiff.exe`; o
   `jvcs.exe` não tem forms).
   - O round-trip binário→texto→binário canônico deu **107/107 idênticos**.
   - Só um form não tem `.dfm` no fonte: `TPASSWORDDLG`, o `TPassWordDlg` da unit **`AbDlgPwd`**
     da Abbrevia, usado pelo Backup.
5. **O fonte é mais novo que o binário.** Nenhuma classe foi trocada e nenhum handler `On*` difere.
   As divergências estruturais são todas recursos acrescentados no trunk em 2012/09 (AKroeber):
   - `SaveWIP`;
   - `ExtBugtracker` (aba de Options e itens de menu nos históricos);
   - "Compare all local/archive" no ProjAdmin e na janela de módulos bloqueados.

   O resto é cosmético: a fonte `MS Sans Serif` virou `Tahoma` em 89 forms, com o recálculo de
   larguras de `TLabel`, e os `ParentFont` foram limpos.
6. **Inventário de componentes**: as classes JVCL usadas nos DFMs são as mesmas 29 no fonte e no
   binário. `TdfsEnhListView` tem 18 instâncias em 15 forms, o que confirma o
   [Componentes.md](../common/Componentes.md).
   - **Nenhum `TSynEdit` nem `TAb*` nos DFMs do GUI**: são criados em runtime.
   - O SynEdit em DFM só aparece no `DiffMain`, com 2 editores, `TSynEditSearch` e 28 highlighters.

---

## 2. Binários: compilador, VERSIONINFO, seções e recursos

| Item | `jedivcs.exe` | `jedivcsdiff.exe` | `jvcs.exe` |
|---|---|---|---|
| Tamanho | 5 840 896 | 2 069 504 | 548 352 |
| TimeDateStamp | `4B6F058B` = 2010-02-07 18:25:15 UTC | `4B6F058D` = 18:25:17 | `4B6F0584` = 18:25:08 |
| Linker / subsystem | 2.25 / GUI (2) | 2.25 / GUI (2) | 2.25 / **console (3)** |
| ImageBase / EntryRVA | `$400000` / `$3FBA24` | `$400000` / `$198490` | `$400000` / `$737C0` |
| Seções | `.text .itext .data .bss .idata .tls .rdata .reloc .rsrc` | idem | idem |
| `.text` (VSize) | 4 165 520 | 1 661 220 | 464 272 |
| `.rsrc` (VSize) | 1 314 304 | 245 248 | 28 160 |
| DLLs importadas | advapi32, comctl32, comdlg32, gdi32, hhctrl.ocx, imm32, kernel32, mpr, ole32, oleacc, oleaut32, oledlg, shell32, user32, version, winmm, winspool.drv, wsock32 | as mesmas, menos oleacc, winmm e wsock32 | advapi32, kernel32, ole32, oleaut32, user32, version |
| FileDescription | JEDI VCS GUI client | JEDI VCS Diff/Merge Utility | JEDI VCS console client |
| InternalName / OriginalFilename | `Jedivcs.dpr/Jedivcsdll` / `Jedivcs.exe/Jedivcsdll.dll` | `Jedivcsdiff.dpr` / `Jedivcsdiff.exe` | `jvcs.dpr` / `jvcs.exe` |
| FileVersion / ProductVersion | 2.5.0.1030 / 2.5.0.0 | idem | idem |
| BuildType / BuildTimestamp / InternalVersion | Beta Build / 31.01.2010 23:00:00 / 2.5.0 Beta 3 | idem | idem |
| `VCS` (chave extra) | `JVCS 2.5.0.1030 Beta 3 http://jedivcs.sourceforge.net/` | idem | idem |
| Translation | `040904E4` (en-US, 1252) | idem | idem |

O `wsock32` do Diff aparece mesmo sem import direto, porque o ICS está linkado (o Diff tem
`TAppSrvClient`). A diferença está só na lista de imports, que o linker otimiza.

### 2.1 Evidências da versão do compilador

- **Units sem namespace** (`Windows`, `SysUtils`, `Forms`…).
- Presença de `DwmApi`, `TGlassFrame` e `TFileOpenDialog` (introduzidos no Delphi 2007).
- **Ausência** de `Character`, `AnsiStrings`, `TEncoding` e `UnicodeString` como tipo RTL (Delphi
  2009+). A única ocorrência da string "UnicodeString" (`jedivcs` RVA `$B52C`) é da tabela de tipos
  do FastMM4.
- APIs `…A` (`MessageBoxA` sim, `MessageBoxW` não). As poucas `…W` são do `WideStrings`/JCL.
- Chaves de locale do RTL: só `Software\Borland\Locales` e `Software\Borland\Delphi\Locales`. Não há
  `CodeGear`/`Embarcadero`, que aparecem a partir do 2009/2010.
- `.itext` e o "FastMM Borland Edition" embutido (BDS 2006+).
- Caminho do build gravado em asserts: `V:\projects\jedivcs\src\…`, com
  `comp\abbrevia\source`, `comp\dfs`, `comp\soft-gems\VirtualTreeview\Source`,
  `Comp\SynEdit\Source`, `Jcl\Source\{common,windows}`, `Jvcl\run` e `JediVcs`.

### 2.2 Tipos de recurso

| Tipo | `jedivcs` | `jedivcsdiff` | `jvcs` | Observações |
|---|---:|---:|---:|---|
| RT_CURSOR (1) / RT_GROUP_CURSOR (12) | 23 / 23 | 11 / 11 | – | `CURSORRM`, `JVDRAGCURSOR`, `JVHANDCURSOR`, `SRVWAIT`, `VT_HEADERSPLIT`, `VT_MOVE*` (12) |
| RT_BITMAP (2) | 60 | 39 | – | `BBABORT`, `BBALL`… (VCL/JVCL/SynEdit/VT) |
| RT_ICON (3) / RT_GROUP_ICON (14) | 4 / 2 | 2 / 1 | – | `MAINICON`, `TB_ICON` |
| RT_DIALOG (5) | 3 | 3 | – | `DLGTEMPLATE`, **`MYDLGO`** (o `myfdlg.res` do FavOpenDialog), `TEXTFILEDLG` |
| RT_STRING (6) | 172 | 58 | 25 | resourcestrings |
| RT_RCDATA (10) | 100 | 11 | 2 | `DVCLAL`, `PACKAGEINFO` e os DFMs (98 / 9 / 0) |
| RT_VERSION (16) | 1 | 1 | 1 | idioma `#1031`, conteúdo en-US |
| RT_MANIFEST (24) | 2 | 2 | – | `#1` **e** `#123`, idênticos (504 bytes, Common-Controls 6.0). Provável duplicação `WindowsXP.res` + `winxp.res` (ThemeMgr) |

---

## 3. Units compiladas (PACKAGEINFO)

| Binário | Offset do `PACKAGEINFO` | Bytes | Flags | Units | `main` | sem flag | `implicit` | `weak` |
|---|---|---:|---|---:|---|---:|---:|---:|
| `jedivcs.exe` | `0x0049558C` | 7 104 | `$CC100000` | 485 | `JediVCS` | 121 | 343 | 20 |
| `jedivcsdiff.exe` | `0x001CE534` | 3 960 | `$CC100000` | 289 | `JEDIVCSDiff` | 23 | 246 | 19 |
| `jvcs.exe` | `0x00085354` | 1 356 | `$CC100000` | 114 | `jvcs` | 22 | 79 | 12 |
| `JvcsExternalDll.dll` (referência) | `0x004ACBC8` | – | – | 488 | `JediVCSDLL` | | | |

`weak` (`weak,orgweak[,implicit]`) marca as units de import de API (`Windows`, `Messages`,
`CommCtrl`, `ShellAPI`, `WinSock`, `RichEdit`, `DBT`…). As listas completas estão em
`<pasta temporária>\cli\<bin>.units.csv` (não versionada).

**GUI × DLL**:
- só no EXE: `JediVCS`, `JVCSManageFavorites`, `ProjectTreeDockWnd`, `OpenProject`, `FastMM4`,
  `FastMM4Messages`;
- só na DLL: `JediVCSDLL`, `JVCSIDEInterface`, `JVCSIDEInterfaceCommon`, `JVCSIDESettings`,
  `JVCSDLLOperations`, `JVCSDLLFileHistoryImpl`, `VerSet`, `UsedComponents`, `Recent`;
- o resto é igual. Note que a DLL **não** linka o FastMM4.

### 3.1 (a) Units no binário e ausentes no fonte

Ficam de fora RTL/VCL e as units de JCL/JVCL/SynEdit/VirtualTrees/Abbrevia, que vêm das bibliotecas
(ver 3.3).

| Unit(s) | jedivcs | diff | jvcs | Origem / versão | Situação no [Componentes.md](../common/Componentes.md) e ajuste |
|---|:-:|:-:|:-:|---|---|
| `mwPasLex`, `mwPasLexTypes` | x | | | TmwPasLex 2.2 (Waldenburg) | "a obter" (Castalia). OK |
| `Ping`, `Icmp` | x | | | ICS V5 | OK (`OverbyteIcsPing`) |
| `SystemTreeView`, `SystemControlPack`, **`PidlHelp`, `FileChange`, `MaskSearch`, `_RES__IDS`** | x | | | DFS SystemTreeView 0.98.5 e dependências | **Acrescentar** as 4 units dependentes. Todas somem com `TShellTreeView`/`TFileOpenDialog` |
| `EnhListView`, **`ExtListView`** | x | | | DFS 3.72 (`TCustomExtListView` é o ancestral) | **Acrescentar** `ExtListView` |
| `dfsStatusBar`, `DFSKb` | x | x | | DFS 1.24 | OK |
| `ItemProp` | x | x | | FreeVCS | O Componentes.md diz "morta no `DiffMain`", mas ela **está linkada** no Diff (`DiffMain.pas:469`, uses incondicional). Manter a substituição |
| `WSocket`, `IcsLogger`, `WSockBuf` | x | x | x | **TWSocket V5.31**, IcsLogger V1.01, WSockBuf V5.02 | Corrigir a versão (o inventário cita 5.28) |
| **`CipherLz`, `Lzh`** | x | x | | Midware 1.01 / Lanzoni | **Estão compilados** (`{$DEFINE LZH}` ativo em `DBModule.pas:60`). "Código morto" vale só para o fluxo em execução: o transporte não usa LZH ([Algoritmos-Recuperados.md](Algoritmos-Recuperados.md)). A decisão de remover continua válida; registrar que o build oficial **tem** o código |
| `HtmlHlp` | x | x | | Brakel (JEDI) | OK |
| `FavOpenDialog` | x | x | | 0.2 (Stephany) + diálogo `MYDLGO` | OK |
| `Checksum` | x | x | x | CRC-32 IEEE | "a recriar". **Resolvido**: `System.ZLib.crc32` (ver Algoritmos-Recuperados §1) |
| `BFCrypt`, **`Blowunit`, `Cryptcon`** | x | | | **CryptoLib** (`TCrypto`→`TBlowFish`): ECB, sem IV, padding de zeros | **Acrescentar** `Blowunit`/`Cryptcon`. O DEC 6.4.1 só serve se configurado em ECB com padding de zeros e chave = bytes crus. Uma alternativa simples é portar o `TBlowFish` (cerca de 300 linhas) |
| `Rekscan` | x | | | FreeVCS | OK (`RekScan`) |
| `SortGrid` | x | | | terceiros | OK: está no uses do `History`, sem componente em DFM |
| `RegAcc` | | x | | FreeVCS | OK |
| `FastMM4`, `FastMM4Messages` | x | x | x | FastMM4 4.9x ("2004 - 2008") | OK (remover) |

Unidades de **bibliotecas** do build oficial que **não existem** (com esse nome) nas versões instaladas
hoje:

| Unit de 2010 | Situação hoje |
|---|---|
| `JvVCL5Utils` | removida da JVCL 2026.08 |
| `SynTextDrawer` | virou `SynDWrite` (DirectWrite) no SynEdit pyscripter |
| `SynRegExpr`, `SynHighlighterHashEntries`, `SynHighlighterMPerl` | removidas |
| `VTAccessibilityFactory` | `VirtualTrees.AccessibilityFactory` |
| `AbDlgPwd` | `Vcl.AbDlgPwd` (Abbrevia 2026.10) |
| `AbZipCry`, `AbTempFileStream` | não existem como unit na Abbrevia 2026.10 |

### 3.2 (b) Units do fonte que não entram em nenhum dos três EXEs

| Unit | Por quê | Consequência para o port |
|---|---|---|
| `JVCSIDEInterface`, `JVCSIDEInterfaceCommon`, `JVCSIDESettings`, `JVCSDLLOperations`, `JVCSDLLFileHistoryImpl`, `VerSet`, `UsedComponents`, `Recent` | **Só da DLL** (estão na `JvcsExternalDll.dll`) | Não são código morto. Ficam para a F5 (DLL) |
| `ExtBugtracker`, `SaveWIP` | **Mais novas que o build**: entraram em 2012/09 (AKroeber). No fonte, `ExtBugtracker` é usada **sem condição** por `History.pas:162` e `ModuleHistoryWindow.pas:140`; `SaveWIP` por `ProjAdmin`, `JVCSLockedModulesDockWnd` e `Options` | Não são mortas no fonte. São recursos que o 2.5.0.1030 **não tem**. Decidir se ficam (ver §6) |
| `JVCSCompressedDiffSynProxy` | Mais nova que o build (usa `UnicodeString` do SynEdit Unicode). É usada por `JVCSCompressedDiffFrame.pas:46` | Mantém; já é a versão Unicode |
| `JVCSDebug`, `JVCSDebugView` | Atrás de `{$IFDEF DEBUG}` (ex.: `DBModule.pas:120`) | Código morto no Release. Opcional |
| `JVCSLanguage` | Atrás de `{$IFDEF LANGUAGE}`, e **`JvGnugettext` também não está em nenhum binário** | Confirma que a tradução estava **desligada** no build oficial. Remover sem perda |
| `MemCheck` | Comentada desde 2004 | **Código morto confirmado**. Remover |
| `languagecodes` | Sem referência fora de si mesma | **Código morto confirmado**. Remover |
| `JVCSDLLLineHistoryFrame` | Listada em `JediVCSDLL.dpr:238`, mas **não está** na `JvcsExternalDll.dll` de 2011 | Mais nova ou condicional. Revisar na F5 |

Todas as units de `src\jedivcsdiff`, `src\comp\midware`, `src\comp\textdiff` e
`src\comp\mdmailslot` estão em algum binário.

### 3.3 (c) Bibliotecas e versões inferidas

| Biblioteca | Versão no build 2010 | Evidência (`jedivcs.exe`, RVA) | Units / uso |
|---|---|---|---|
| JCL | **1.102 Build 3072** | `$URL: …/jcl/tags/JCL-1.102-Build3072/…/JclBase.pas` em `$97B54`, mais 27 units com `$Revision` | `JclSysInfo`, `JclStrings`, `JclFileUtils`, `JclSecurity`, `JclShell`, `JclRegistry`, `JclSimpleXml` (Line History), `JclDebug`/`JclHookExcept`/`JclTD32`/`JclPeImage`, `JclMime`, `JclRTTI`, `JclGraphUtils`. **Sem `JclPCRE`**. O `jvcs.exe` linka 19 units Jcl* |
| JVCL | 3.x, provável **3.34** (par da JCL 1.102). O binário não grava a versão | `JVCLVer`, `AboutJVCL`, recurso `"JVCL Plugin Manager"` | 29 classes TJv* em DFM (§5); não visuais: `JvDSADialogs`, `JvMRUManager`/`JvMRUList`, `JvSearchFiles`, `JvPluginManager`, `JvFormPlacement`/`JvAppStorage`, `JvDynControlEngine*`. **Sem `JvGnugettext`** |
| ICS | **V5** (TWSocket 5.31, WSockBuf 5.02, IcsLogger 1.01) | `$12D14C` | Units sem prefixo `Overbyte` |
| Midware | TMWBuffer **1.48**, TAppSrvClient **3.06**, TResponseBroker **1.07a** | `$13C50C`, `$13E5B4`, `$1401E8` | iguais às de `src\comp\midware` |
| Abbrevia | **3.05** (créditos do About) | `.rsrc` `$4C5D68` | `AbZipper`, `AbZipPrc`, `AbUnzPrc`, `AbZipCry` (ZipCrypto), `AbDlgPwd` (form `TPassWordDlg`), `AbDf*` (deflate). `AbCabTyp`/`AbFciFdi` (CAB) entram de carona via `AbBrowse`. Os três binários |
| SynEdit | 2.0.x **pré-Unicode** (sem `SynUnicode`; com `SynTextDrawer`, `SynEditWordWrap`, `SynHighlighterMulti`) | caminhos `Comp\SynEdit\Source` | o GUI linka 58 units `SynHighlighter*` (via Line History/CompressedDiff); o Diff, 30 (28 instanciados no DFM) |
| Virtual Treeview | **soft-gems 4.8.x** | "Virtual Treeview © 1999, 2009 Mike Lischke" em `$273F2E` | `VirtualTrees`, `VTAccessibilityFactory` |
| DFS | EnhListView **3.72**, StatusBar **1.24**, SystemTreeView **0.98.5** | `$DF16C`, `$184FBC`, `.rsrc` `$4C5E12` | §3.1 |
| mdMailSlot | 1.17 | `.rsrc` `$4C5F4C` | `TmdSecureMail` (ProjAdmin) |
| mwPasLex | 2.2 | `.rsrc` `$4C6030` | §3.1 |
| FastMM4 | 4.9x ("© 2004 - 2008") | `$9788` | os 3 EXEs (a DLL não) |
| ThemeMgr (Soft Gems) | **não linkado** (`ThemeMgr`/`ThemeSrv` fora do PACKAGEINFO) | – | O `uses ThemeMgr` de `ProjAdmin.pas:273` e `DiffMain.pas:88` estava desligado no build. Os temas vêm do manifesto |

---

## 4. Forms extraídos

Os DFMs convertidos para texto estão em
`3rdparty\referencia-2.5.0.1030\dfm\<binario>\<RECURSO>.dfm.txt` (UTF-8 sem BOM, formato
`object … end` do Delphi). Strings ANSI foram decodificadas como **Windows-1252**, e `vaBinary` foi
gravado em hexadecimal. O diff completo contra o fonte está em
`3rdparty\referencia-2.5.0.1030\dfm\_comparacao-fonte.txt`, e o resumo por form em
`_comparacao-fonte.csv`.

Legenda da tabela:
- "Offset no arquivo": posição do bloco do recurso no `.exe`.
- Δcomp e Δprop: componentes e propriedades que divergem do fonte, já sem o ruído de §6.
- "Componentes": quantidade de componentes filhos (exclui o form raiz).

#### jedivcs.exe (98 forms)

| Recurso RCDATA | Offset no arquivo | Bytes | Classe raiz | .dfm do fonte (src\…) | Δcomp | Δprop | Componentes | Não-VCL (classe×n) |
|---|---|---:|---|---|---:|---:|---:|---|
| `TDATAMODULE1` | 0x0049714C | 599 | `TDataModule1` | jedivcs\DBModule.dfm | 0 | 0 | 2 | TAppSrvClient×1, TMWBuffer×1 |
| `TJVCSBACKUPTREEOPTIONS` | 0x004973A4 | 3520 | `TJVCSBackupTreeOptions` | jedivcs\BackupTreeOptions.dfm | 0 | 9 | 13 |  |
| `TJVCSBASEABOUTDLG` | 0x00498164 | 76853 | `TJVCSBaseAboutDlg` | common\JVCSBaseAboutDialog.dfm | 0 | 0 | 28 | TJvRichEdit×1 |
| `TJVCSBRANCHTREEVIEWFRM` | 0x004AAD9C | 1036 | `TJVCSBranchTreeViewFrm` | jedivcs\JVCSBranchTreeViewFrame.dfm | 0 | 1 | 1 | TVirtualStringTree×1 |
| `TJVCSBROWSERFRM` | 0x004AB1A8 | 2356 | `TJVCSBrowserFrm` | jedivcs\JVCSBrowserFrame.dfm | 0 | 1 | 19 | TVirtualStringTree×1 |
| `TJVCSCOMPRESSEDDIFFFRM` | 0x004ABADC | 94 | `TJVCSCompressedDiffFrm` | common\client\JVCSCompressedDiffFrame.dfm | 0 | 0 |  |  |
| `TJVCSCREATEBRANCHFORM` | 0x004ABB3C | 8436 | `TJVCSCreateBranchForm` | jedivcs\JVCSCreateBranchDialog.dfm | 0 | 23 | 24 | TJvMemo×1, TJvWizard×1, TJvWizardInteriorPage×6, TJvWizardRouteMapSteps×1 |
| `TJVCSDOCKABLEFORM` | 0x004ADC30 | 1437 | `TJVCSDockableForm` | jedivcs\JVCSDockForm.dfm | 0 | 1 |  |  |
| `TJVCSDOCKLOCKEDMODULESWINDOW` | 0x004AE1D0 | 6914 | `TJVCSDockLockedModulesWindow` | jedivcs\JVCSLockedModulesDockWnd.dfm | 2 | 1 | 26 | TdfsEnhListView×1 |
| `TJVCSDOCKPROJECTTREE` | 0x004AFCD4 | 19430 | `TJVCSDockProjectTree` | jedivcs\ProjectTreeDockWnd.dfm | 0 | 6 | 14 | TJvTreeView×1, TVirtualDrawTree×1 |
| `TJVCSDOCKTODOWINDOW` | 0x004B48BC | 19073 | `TJVCSDockToDoWindow` | jedivcs\ToDoDockWnd.dfm | 0 | 0 | 12 | TdfsEnhListView×1 |
| `TJVCSGUICLIENTIMAGESDATAMODULE` | 0x004B9340 | 63658 | `TJVCSGUIClientImagesDataModule` | jedivcs\JVCSGUIClientImages.dfm | 0 | 0 | 1 |  |
| `TJVCSLINEHISTORYFRM` | 0x004C8BEC | 25516 | `TJVCSLineHistoryFrm` | common\client\JVCSLineHistoryFrame.dfm | 0 | 1 | 62 | TVirtualStringTree×1 |
| `TJVCSLINEHISTORYSETTINGSDLG` | 0x004CEF98 | 9588 | `TJVCSLineHistorySettingsDlg` | common\client\JVCSLineHistorySettingsDialog.dfm | 0 | 25 | 21 | TJvColorDialog×1, TJvGradient×2, TJvOfficeColorButton×5, TVirtualStringTree×1 |
| `TJVCSSELECTBRANCHFORM` | 0x004D150C | 1953 | `TJVCSSelectBranchForm` | jedivcs\JVCSSelectBranchDialog.dfm | 0 | 1 | 5 | TJVCSBranchTreeViewFrm×1, TVirtualStringTree×1 |
| `TNTFYSENDFORM` | 0x004D1CB0 | 3545 | `TNtfySendForm` | jedivcs\NtfySend.dfm | 0 | 1 | 14 | TJvMemo×1 |
| `TPASSWORDDLG` | 0x004D2A8C | 1067 | `TPassWordDlg` | (sem fonte) |  |  | 7 |  |
| `TVCSABOUT` | 0x004D2EB8 | 55 | `TVCSAbout` | jedivcs\About.dfm | 0 | 0 |  |  |
| `TVCSADDBUG` | 0x004D2EF0 | 2832 | `TVCSAddBug` | jedivcs\AddNewBug.dfm | 0 | 8 | 19 | TJvMemo×2 |
| `TVCSADDCOMPARETOOL` | 0x004D3A00 | 1846 | `TVCSAddCompareTool` | jedivcs\AddNewCompareTool.dfm | 0 | 4 | 9 | TJvFilenameEdit×1 |
| `TVCSADDFAMILY` | 0x004D4138 | 2262 | `TVCSAddFamily` | jedivcs\AddNewFamily.dfm | 0 | 4 | 14 |  |
| `TVCSADDLABEL` | 0x004D4A10 | 1600 | `TVCSAddLabel` | jedivcs\AddNewLabel.dfm | 0 | 2 | 9 |  |
| `TVCSADDMILESTONE` | 0x004D5050 | 1659 | `TVCSAddMilestone` | jedivcs\AddNewMilestone.dfm | 0 | 1 | 9 | TJvMemo×1 |
| `TVCSADDNEWGROUP` | 0x004D56CC | 1803 | `TVCSAddNewGroup` | jedivcs\AddNewGroup.dfm | 0 | 3 | 11 | TJvMemo×1 |
| `TVCSADDSHAREDMODULE` | 0x004D5DD8 | 2658 | `TVCSAddSharedModule` | jedivcs\AddShareModule.dfm | 0 | 1 | 6 |  |
| `TVCSADDUSER` | 0x004D683C | 2706 | `TVCSAddUser` | jedivcs\AddNewUser.dfm | 0 | 10 | 18 |  |
| `TVCSASSIGNBUGS` | 0x004D72D0 | 23325 | `TVCSAssignBugs` | jedivcs\AssignBugs.dfm | 0 | 3 | 24 |  |
| `TVCSASSIGNLABELS` | 0x004DCDF0 | 6659 | `TVCSAssignLabels` | jedivcs\AssignLabels.dfm | 0 | 3 | 28 | TJvComboBox×1, TJvSplitter×2 |
| `TVCSASSIGNMILESTONES` | 0x004DE7F4 | 5034 | `TVCSAssignMilestones` | jedivcs\AssignMilestones.dfm | 0 | 2 | 18 |  |
| `TVCSBACKUP` | 0x004DFBA0 | 12444 | `TVCSBackup` | jedivcs\Backup.dfm | 0 | 8 | 42 | TJvComboBox×2, TJvLED×1 |
| `TVCSBRANCH` | 0x004E2C3C | 17128 | `TVCSBranch` | jedivcs\Branch.dfm | 0 | 5 | 17 |  |
| `TVCSBUGWINDOW` | 0x004E6F24 | 32385 | `TVCSBugWindow` | jedivcs\BugWindow.dfm | 0 | 0 | 15 | TdfsEnhListView×1 |
| `TVCSCHANGEUSERPW` | 0x004EEDA8 | 1605 | `TVCSChangeUserPW` | jedivcs\ChangeUserPW.dfm | 0 | 3 | 10 | TJvEdit×3 |
| `TVCSCHECKFBUILD` | 0x004EF3F0 | 3230 | `TVCSCheckfBuild` | jedivcs\CheckfBuild.dfm | 0 | 1 | 8 | TJvMemo×1 |
| `TVCSCHKINSINGLE` | 0x004F0090 | 7978 | `TVCSChkInSingle` | jedivcs\ChkInSingle.dfm | 0 | 5 | 36 | TJvArrowButton×2, TJvComboBox×1, TJvLED×1, TJvMemo×1, TMWBuffer×1 |
| `TVCSCHKOUTSINGLE` | 0x004F1FBC | 5944 | `TVCSChkOutSingle` | jedivcs\ChkOutSingle.dfm | 0 | 5 | 26 | TJvArrowButton×1, TJvComboBox×1, TJvLED×1, TJvMemo×1 |
| `TVCSCOMPAREFOLDERS` | 0x004F36F4 | 18742 | `TVCSCompareFolders` | jedivcs\CompareFolders.dfm | 0 | 5 | 26 | TdfsEnhListView×1, TJvComboBox×2 |
| `TVCSCOMPRESSEDDIFF` | 0x004F802C | 849 | `TVCSCompressedDiff` | common\client\JVCSCompressedDiffDialog.dfm | 0 | 1 | 4 | TJVCSCompressedDiffFrm×1 |
| `TVCSCUSTOMVIEWFILTER` | 0x004F8380 | 7257 | `TVCSCustomViewFilter` | jedivcs\CustViewFilter.dfm | 0 | 1 | 10 |  |
| `TVCSDELETEPH` | 0x004F9FDC | 3235 | `TVCSDeletePH` | jedivcs\DeletePH.dfm | 0 | 15 | 12 |  |
| `TVCSDESCRIPTION` | 0x004FAC80 | 3186 | `TVCSDescription` | jedivcs\Description.dfm | 0 | 2 | 10 | TJvMemo×1 |
| `TVCSDIRECTSQL` | 0x004FB8F4 | 5306 | `TVCSDirectSQL` | jedivcs\DirectSQL.dfm | 0 | 4 | 17 | TJvMemo×1, TJvSpinEdit×1 |
| `TVCSDIRWATCH` | 0x004FCDB0 | 11722 | `TVCSDirWatch` | jedivcs\DirWatch.dfm | 0 | 1 | 11 | TdfsEnhListView×1 |
| `TVCSDISTRIBUTION` | 0x004FFB7C | 5355 | `TVCSDistribution` | jedivcs\Distribution.dfm | 0 | 2 | 16 | TJvComboBox×1 |
| `TVCSEDITIP` | 0x00501068 | 2163 | `TVCSEditIP` | jedivcs\EditIP.dfm | 0 | 2 | 13 |  |
| `TVCSFILEFAMILIES` | 0x005018DC | 9158 | `TVCSFileFamilies` | jedivcs\FileFamilies.dfm | 0 | 1 | 17 |  |
| `TVCSHISTORY` | 0x00503CA4 | 8724 | `TVCSHistory` | jedivcs\History.dfm | 2 | 3 | 19 | TJvComboBox×1 |
| `TVCSINFO` | 0x00505EB8 | 10720 | `TVCSInfo` | jedivcs\ModuleInfo.dfm | 0 | 3 | 22 |  |
| `TVCSLABELHISTORY` | 0x00508898 | 1918 | `TVCSLabelHistory` | jedivcs\JVCSLabelHistory.dfm | 0 | 5 | 13 | TdfsEnhListView×1 |
| `TVCSLISTEDIT` | 0x00509018 | 4509 | `TVCSListEdit` | jedivcs\ListEdit.dfm | 0 | 1 | 14 | TJvListBox×1 |
| `TVCSLISTVIEW` | 0x0050A1B8 | 3300 | `TVCSListView` | jedivcs\ListView.dfm | 0 | 7 | 7 | TJvMemo×1 |
| `TVCSLOAD` | 0x0050AE9C | 6943 | `TVCSLoad` | jedivcs\Create.dfm | 0 | 22 | 43 | TJvEdit×1 |
| `TVCSMAINTAINBUGS` | 0x0050C9BC | 19705 | `TVCSMaintainBugs` | jedivcs\MaintainBugs.dfm | 0 | 6 | 32 | TJvImageComboBox×1, TJvMemo×1 |
| `TVCSMAINTAINFFAMILIES` | 0x005116B8 | 5102 | `TVCSMaintainFFamilies` | jedivcs\MaintainFFamilies.dfm | 0 | 3 | 23 | TJvMemo×1 |
| `TVCSMAINTAINLABELS` | 0x00512AA8 | 4262 | `TVCSMaintainLabels` | jedivcs\MaintainLabels.dfm | 0 | 1 | 16 | TJvMemo×1 |
| `TVCSMAINTAINMILESTONES` | 0x00513B50 | 5283 | `TVCSMaintainMilestones` | jedivcs\MaintainMilestones.dfm | 0 | 1 | 19 | TJvMemo×1 |
| `TVCSMAINTAINUSERS` | 0x00514FF4 | 23865 | `TVCSMaintainUsers` | jedivcs\MaintainUsers.dfm | 0 | 12 | 35 | TJvMemo×1 |
| `TVCSMANAGEFAVORITES` | 0x0051AD30 | 2455 | `TVCSManageFavorites` | jedivcs\JVCSManageFavorites.dfm | 0 | 0 | 8 |  |
| `TVCSMERGE` | 0x0051B6C8 | 18863 | `TVCSMerge` | jedivcs\MergeVersion.dfm | 0 | 8 | 31 | TMWBuffer×1 |
| `TVCSMODMOVE` | 0x00520078 | 17492 | `TVCSModMove` | jedivcs\MoveModules.dfm | 0 | 2 | 24 | TdfsEnhListView×1 |
| `TVCSMODULEHISTORYWINDOW` | 0x005244CC | 5884 | `TVCSModuleHistoryWindow` | jedivcs\ModuleHistoryWindow.dfm | 2 | 8 | 11 |  |
| `TVCSOPENPROJECT` | 0x00525BC8 | 1257 | `TVCSOpenProject` | jedivcs\OpenProject.dfm | 0 | 4 | 6 |  |
| `TVCSOPTIONS` | 0x005260B4 | 52286 | `TVCSOptions` | jedivcs\Options.dfm | 14 | 82 | 226 | TJvColorComboBox×4, TJvEdit×2, TJvFilenameEdit×4, TJvSearchFiles×1, TJvSpinEdit×7, TJvTextListBox×1, TJvxSlider×1 |
| `TVCSPASSWORD` | 0x00532CF4 | 956 | `TVCSPassword` | jedivcs\Password.dfm | 0 | 3 | 7 |  |
| `TVCSPHISTORYFILTER` | 0x005330B0 | 6586 | `TVCSPHistoryFilter` | jedivcs\PHFilter.dfm | 0 | 7 | 47 |  |
| `TVCSPLUGIN` | 0x00534A6C | 3099 | `TVCSPlugin` | jedivcs\Plugins.dfm | 0 | 1 | 12 |  |
| `TVCSPROGRESS` | 0x00535688 | 601 | `TVCSProgress` | jedivcs\Progress.dfm | 0 | 2 | 3 |  |
| `TVCSPROJADMIN` | 0x005358E4 | 112998 | `TVCSProjAdmin` | jedivcs\ProjAdmin.dfm | 2 | 36 | 390 | TdfsEnhListView×1, TdfsStatusBar×1, TJvPluginManager×1, TJvSplitter×1, TJvToolBar×1, TmdSecureMail×1 |
| `TVCSPROJECTDEPENDENCIES` | 0x0055124C | 15614 | `TVCSProjectDependencies` | jedivcs\ProjDependencies.dfm | 0 | 1 | 7 | TdfsEnhListView×1 |
| `TVCSPROJECTHISTORY` | 0x00554F4C | 17948 | `TVCSProjectHistory` | jedivcs\ProjectHist.dfm | 0 | 1 | 24 | TdfsEnhListView×1 |
| `TVCSPROJECTRIGHTS` | 0x00559568 | 17946 | `TVCSProjectRights` | jedivcs\ProjectRights.dfm | 0 | 2 | 25 | TJvImageComboBox×1 |
| `TVCSPROJECTTREE` | 0x0055DB84 | 24371 | `TVCSProjectTree` | jedivcs\ProjectTree.dfm | 0 | 1 | 35 |  |
| `TVCSPURGE` | 0x00563AB8 | 2921 | `TVCSPurge` | jedivcs\Purge.dfm | 0 | 3 | 8 | TJvSpinEdit×1 |
| `TVCSREMOVEPROJ` | 0x00564624 | 3284 | `TVCSRemoveProj` | jedivcs\RemoveProj.dfm | 0 | 1 | 7 |  |
| `TVCSRENAMEPROJ` | 0x005652F8 | 15897 | `TVCSRenameProj` | jedivcs\RenameProj.dfm | 0 | 1 | 12 |  |
| `TVCSSEARCHMODULES` | 0x00569114 | 4085 | `TVCSSearchModules` | jedivcs\SearchModules.dfm | 0 | 2 | 23 | TdfsEnhListView×1, TJvComboBox×1 |
| `TVCSSELCROSSREF` | 0x0056A10C | 3382 | `TVCSSelCrossRef` | jedivcs\CrossRefList.dfm | 0 | 0 | 14 |  |
| `TVCSSELECTDRIVE` | 0x0056AE44 | 1005 | `TVCSSelectDrive` | jedivcs\SelectDrive.dfm | 0 | 2 | 6 | TJvDriveCombo×1 |
| `TVCSSELECTFOLDER` | 0x0056B234 | 4531 | `TVCSSelectFolder` | jedivcs\SelectFolder.dfm | 0 | 1 | 25 | TdfsSystemTreeView×1, TJvComboBox×1 |
| `TVCSSELECTLIST` | 0x0056C3E8 | 2871 | `TVCSSelectList` | jedivcs\SelectList.dfm | 0 | 1 | 10 | TJvTextListBox×1 |
| `TVCSSELECTPROJECT` | 0x0056CF20 | 24310 | `TVCSSelectProject` | jedivcs\SelectProjectID.dfm | 0 | 1 | 46 |  |
| `TVCSSERVEROPTIONS` | 0x00572E18 | 6448 | `TVCSServerOptions` | jedivcs\ServerOptions.dfm | 0 | 17 | 38 | TJvSpinEdit×2 |
| `TVCSSHOWTIMELOG` | 0x00574748 | 4452 | `TVCSShowTimeLog` | jedivcs\ShowTimeLog.dfm | 0 | 3 | 20 |  |
| `TVCSSIMPLEREPORT` | 0x005758AC | 4060 | `TVCSSimpleReport` | jedivcs\SimpleReport.dfm | 0 | 1 | 21 | TJvxCheckListBox×1 |
| `TVCSSTDLISTVIEW` | 0x00576888 | 4929 | `TVCSStdListView` | jedivcs\Std_ListView.dfm | 0 | 1 | 42 | TdfsEnhListView×1 |
| `TVCSSYNC` | 0x00577BCC | 25491 | `TVCSSync` | jedivcs\Syncronice.dfm | 0 | 7 | 77 | TdfsEnhListView×4, TdfsStatusBar×1, TJvCheckTreeView×1, TJvComboBox×2, TJvLED×1, TJvNetscapeSplitter×1, TJvSpinEdit×2 |
| `TVCSTEXTCOMPARE` | 0x0057DF60 | 6509 | `TVCSTextCompare` | jedivcs\TextComp.dfm | 0 | 35 | 26 | TJvComboBox×1 |
| `TVCSTLFILTER` | 0x0057F8D0 | 1385 | `TVCSTLFilter` | jedivcs\TimeLogFilter.dfm | 0 | 5 | 8 |  |
| `TVCSTODO` | 0x0057FE3C | 21937 | `TVCSToDo` | jedivcs\ToDo.dfm | 0 | 1 | 37 | TdfsEnhListView×1, TMWBuffer×2 |
| `TVCSTODOEDIT` | 0x005853F0 | 4667 | `TVCSToDoEdit` | jedivcs\ToDoEdit.dfm | 0 | 10 | 24 | TJvComboBox×1, TJvMemo×1, TJvSpinEdit×1 |
| `TVCSTODOFILTER` | 0x0058662C | 4554 | `TVCSToDoFilter` | jedivcs\ToDoFilter.dfm | 0 | 7 | 28 | TJvComboBox×4 |
| `TVCSTOUCH` | 0x005877F8 | 14080 | `TVCSTouch` | jedivcs\Touch.dfm | 0 | 4 | 23 | TJvComboBox×1 |
| `TVCSUNITFILTER` | 0x0058AEF8 | 2611 | `TVCSUnitFilter` | jedivcs\UnitFilter.dfm | 0 | 4 | 14 | TJvTextListBox×1 |
| `TVCSUSEDUNITS` | 0x0058B92C | 12228 | `TVCSUsedUnits` | jedivcs\UsedUnits.dfm | 0 | 2 | 15 | TdfsEnhListView×1 |
| `TVCSWAITFORSERVER` | 0x0058E8F0 | 1713 | `TVCSWaitforServer` | jedivcs\WaitforServer.dfm | 0 | 3 | 3 |  |
| `TVCSWCVIEWFILTER` | 0x0058EFA4 | 3162 | `TVCSWCViewFilter` | jedivcs\WCViewFilter.dfm | 0 | 5 | 15 | TJvComboBox×1 |
| `TVCSWHOAMI` | 0x0058FC00 | 3362 | `TVCSWhoami` | jedivcs\Whoami.dfm | 0 | 33 | 27 |  |
| `TVCSYES2ALLDLG` | 0x00590924 | 1924 | `TVCSYes2AllDlg` | jedivcs\Yes2allDlg.dfm | 0 | 7 | 7 |  |

#### jedivcsdiff.exe (9 forms)

| Recurso RCDATA | Offset no arquivo | Bytes | Classe raiz | .dfm do fonte (src\…) | Δcomp | Δprop | Componentes | Não-VCL (classe×n) |
|---|---|---:|---|---|---:|---:|---:|---|
| `TCUSTOMKW` | 0x001CF4AC | 1022 | `TCustomKW` | jedivcsdiff\DiffCustomKW.dfm | 0 | 1 | 7 |  |
| `TDATAMODULE1` | 0x001CF8AC | 599 | `TDataModule1` | jedivcs\DBModule.dfm | 0 | 0 | 2 | TAppSrvClient×1, TMWBuffer×1 |
| `TFM_EDITORPROP` | 0x001CFB04 | 8775 | `Tfm_EditorProp` | jedivcsdiff\DiffEditorProp.dfm | 0 | 18 | 25 | TJvColorComboBox×4, TJvSpinEdit×4 |
| `TFM_HIGHLIGHTPROP` | 0x001D1D4C | 5823 | `Tfm_HighLightProp` | jedivcsdiff\DiffHLProp.dfm | 0 | 8 | 25 | TJvColorComboBox×2 |
| `TFM_MAIN` | 0x001D340C | 69833 | `Tfm_Main` | jedivcsdiff\DiffMain.dfm | 0 | 22 | 231 | TdfsStatusBar×1, TJvComboBox×2, TJvMruList×2, TSynAsmSyn×1, TSynBatSyn×1, TSynCacheSyn×1, TSynCACSyn×1, TSynCPMSyn×1, TSynCppSyn×1, TSynCssSyn×1, TSynDfmSyn×1, TSynEdit×2, TSynEditSearch×1, TSynFortranSyn×1, TSynFoxproSyn×1, TSynGeneralSyn×1, TSynHTMLSyn×1, TSynIdlSyn×1, TSynIniSyn×1, TSynInnoSyn×1, TSynJavaSyn×1, TSynJScriptSyn×1, TSynM3Syn×1, TSynPasSyn×1, TSynPerlSyn×1, TSynPHPSyn×1, TSynProgressSyn×1, TSynPythonSyn×1, TSynSQLSyn×1, TSynTclTkSyn×1, TSynVBScriptSyn×1, TSynVBSyn×1, TSynXMLSyn×1 |
| `TJVCSBASEABOUTDLG` | 0x001E44D8 | 76853 | `TJVCSBaseAboutDlg` | common\JVCSBaseAboutDialog.dfm | 0 | 0 | 28 | TJvRichEdit×1 |
| `TJVCSDIFFABOUT` | 0x001F7110 | 346 | `TJVCSDiffAbout` | jedivcsdiff\DiffAbout.dfm | 0 | 0 | 6 |  |
| `TVCSLISTVIEW` | 0x001F726C | 3300 | `TVCSListView` | jedivcs\ListView.dfm | 0 | 7 | 7 | TJvMemo×1 |
| `TVCSSIMPLEREPORT` | 0x001F7F50 | 2597 | `TVCSSimpleReport` | jedivcsdiff\DiffSimpleReport.dfm | 0 | 1 | 10 |  |

---

## 5. Inventário de classes de componentes nos forms

Contagem de instâncias por classe nos DFMs, sem o form raiz. Os frames JVCS embutidos
(`TJVCSBranchTreeViewFrm`, `TJVCSCompressedDiffFrm`) aparecem como "JVCS". A lista por form está na
coluna "Não-VCL" da §4.

#### jedivcs.exe

| Biblioteca | Classe | Instâncias | Forms |
|---|---|---:|---:|
| DFS | `TdfsEnhListView` | 18 | 15 |
| DFS | `TdfsStatusBar` | 2 | 2 |
| DFS | `TdfsSystemTreeView` | 1 | 1 |
| JVCL | `TJvComboBox` | 21 | 15 |
| JVCL | `TJvMemo` | 18 | 17 |
| JVCL | `TJvSpinEdit` | 14 | 6 |
| JVCL | `TJvEdit` | 6 | 3 |
| JVCL | `TJvWizardInteriorPage` | 6 | 1 |
| JVCL | `TJvFilenameEdit` | 5 | 2 |
| JVCL | `TJvOfficeColorButton` | 5 | 1 |
| JVCL | `TJvColorComboBox` | 4 | 1 |
| JVCL | `TJvLED` | 4 | 4 |
| JVCL | `TJvArrowButton` | 3 | 2 |
| JVCL | `TJvSplitter` | 3 | 2 |
| JVCL | `TJvTextListBox` | 3 | 3 |
| JVCL | `TJvGradient` | 2 | 1 |
| JVCL | `TJvImageComboBox` | 2 | 2 |
| JVCL | `TJvCheckTreeView` | 1 | 1 |
| JVCL | `TJvColorDialog` | 1 | 1 |
| JVCL | `TJvDriveCombo` | 1 | 1 |
| JVCL | `TJvListBox` | 1 | 1 |
| JVCL | `TJvNetscapeSplitter` | 1 | 1 |
| JVCL | `TJvPluginManager` | 1 | 1 |
| JVCL | `TJvRichEdit` | 1 | 1 |
| JVCL | `TJvSearchFiles` | 1 | 1 |
| JVCL | `TJvToolBar` | 1 | 1 |
| JVCL | `TJvTreeView` | 1 | 1 |
| JVCL | `TJvWizard` | 1 | 1 |
| JVCL | `TJvWizardRouteMapSteps` | 1 | 1 |
| JVCL | `TJvxCheckListBox` | 1 | 1 |
| JVCL | `TJvxSlider` | 1 | 1 |
| JVCS (frame/form) | `TJVCSBranchTreeViewFrm` | 1 | 1 |
| JVCS (frame/form) | `TJVCSCompressedDiffFrm` | 1 | 1 |
| mdMailSlot | `TmdSecureMail` | 1 | 1 |
| Midware | `TMWBuffer` | 5 | 4 |
| Midware | `TAppSrvClient` | 1 | 1 |
| VCL | `TMenuItem` | 548 | 41 |
| VCL | `TLabel` | 312 | 71 |
| VCL | `TButton` | 217 | 83 |
| VCL | `TSpeedButton` | 204 | 71 |
| VCL | `TPanel` | 171 | 67 |
| VCL | `TCheckBox` | 148 | 29 |
| VCL | `TEdit` | 74 | 39 |
| VCL | `TImageList` | 61 | 34 |
| VCL | `TRadioButton` | 61 | 19 |
| VCL | `TAction` | 60 | 6 |
| VCL | `TPopupMenu` | 57 | 41 |
| VCL | `TToolButton` | 53 | 4 |
| VCL | `TComboBox` | 41 | 18 |
| VCL | `TTabSheet` | 35 | 10 |
| VCL | `TListView` | 32 | 24 |
| VCL | `TGroupBox` | 24 | 18 |
| VCL | `TSplitter` | 18 | 15 |
| VCL | `TMemo` | 16 | 14 |
| VCL | `TImage` | 14 | 10 |
| VCL | `TTimer` | 12 | 9 |
| VCL | `TDateTimePicker` | 11 | 7 |
| VCL | `TPageControl` | 11 | 10 |
| VCL | `TListBox` | 7 | 6 |
| VCL | `TProgressBar` | 7 | 6 |
| VCL | `TActionList` | 6 | 6 |
| VCL | `THotKey` | 6 | 1 |
| VCL | `TToolBar` | 6 | 4 |
| VCL | `TOpenDialog` | 4 | 4 |
| VCL | `TSaveDialog` | 3 | 3 |
| VCL | `TUpDown` | 3 | 1 |
| VCL | `TBevel` | 2 | 2 |
| VCL | `TTreeView` | 2 | 2 |
| VCL | `TControlBar` | 1 | 1 |
| VCL | `TFindDialog` | 1 | 1 |
| VCL | `TFontDialog` | 1 | 1 |
| VCL | `TMainMenu` | 1 | 1 |
| VCL | `TPaintBox` | 1 | 1 |
| VCL | `TPrintDialog` | 1 | 1 |
| VCL | `TRichEdit` | 1 | 1 |
| VirtualTrees | `TVirtualStringTree` | 5 | 5 |
| VirtualTrees | `TVirtualDrawTree` | 1 | 1 |

Totais por biblioteca: DFS = 21 instâncias / 3 classes; JVCL = 110 instâncias / 28 classes; JVCS (frame/form) = 2 instâncias / 2 classes; mdMailSlot = 1 instâncias / 1 classes; Midware = 6 instâncias / 2 classes; VCL = 2233 instâncias / 39 classes; VirtualTrees = 6 instâncias / 2 classes.

#### jedivcsdiff.exe

| Biblioteca | Classe | Instâncias | Forms |
|---|---|---:|---:|
| DFS | `TdfsStatusBar` | 1 | 1 |
| JVCL | `TJvColorComboBox` | 6 | 2 |
| JVCL | `TJvSpinEdit` | 4 | 1 |
| JVCL | `TJvComboBox` | 2 | 1 |
| JVCL | `TJvMruList` | 2 | 1 |
| JVCL | `TJvMemo` | 1 | 1 |
| JVCL | `TJvRichEdit` | 1 | 1 |
| Midware | `TAppSrvClient` | 1 | 1 |
| Midware | `TMWBuffer` | 1 | 1 |
| SynEdit | `TSynEdit` | 2 | 1 |
| SynEdit | `TSynAsmSyn` | 1 | 1 |
| SynEdit | `TSynBatSyn` | 1 | 1 |
| SynEdit | `TSynCacheSyn` | 1 | 1 |
| SynEdit | `TSynCACSyn` | 1 | 1 |
| SynEdit | `TSynCPMSyn` | 1 | 1 |
| SynEdit | `TSynCppSyn` | 1 | 1 |
| SynEdit | `TSynCssSyn` | 1 | 1 |
| SynEdit | `TSynDfmSyn` | 1 | 1 |
| SynEdit | `TSynEditSearch` | 1 | 1 |
| SynEdit | `TSynFortranSyn` | 1 | 1 |
| SynEdit | `TSynFoxproSyn` | 1 | 1 |
| SynEdit | `TSynGeneralSyn` | 1 | 1 |
| SynEdit | `TSynHTMLSyn` | 1 | 1 |
| SynEdit | `TSynIdlSyn` | 1 | 1 |
| SynEdit | `TSynIniSyn` | 1 | 1 |
| SynEdit | `TSynInnoSyn` | 1 | 1 |
| SynEdit | `TSynJavaSyn` | 1 | 1 |
| SynEdit | `TSynJScriptSyn` | 1 | 1 |
| SynEdit | `TSynM3Syn` | 1 | 1 |
| SynEdit | `TSynPasSyn` | 1 | 1 |
| SynEdit | `TSynPerlSyn` | 1 | 1 |
| SynEdit | `TSynPHPSyn` | 1 | 1 |
| SynEdit | `TSynProgressSyn` | 1 | 1 |
| SynEdit | `TSynPythonSyn` | 1 | 1 |
| SynEdit | `TSynSQLSyn` | 1 | 1 |
| SynEdit | `TSynTclTkSyn` | 1 | 1 |
| SynEdit | `TSynVBScriptSyn` | 1 | 1 |
| SynEdit | `TSynVBSyn` | 1 | 1 |
| SynEdit | `TSynXMLSyn` | 1 | 1 |
| VCL | `TMenuItem` | 93 | 2 |
| VCL | `TLabel` | 31 | 5 |
| VCL | `TAction` | 30 | 1 |
| VCL | `TToolButton` | 30 | 1 |
| VCL | `TPanel` | 21 | 5 |
| VCL | `TButton` | 15 | 6 |
| VCL | `TCheckBox` | 12 | 3 |
| VCL | `TSpeedButton` | 9 | 3 |
| VCL | `TTabSheet` | 7 | 2 |
| VCL | `TMemo` | 5 | 3 |
| VCL | `TRadioButton` | 5 | 1 |
| VCL | `TPopupMenu` | 4 | 2 |
| VCL | `TComboBox` | 3 | 2 |
| VCL | `TBevel` | 2 | 1 |
| VCL | `TGroupBox` | 2 | 1 |
| VCL | `TImageList` | 2 | 1 |
| VCL | `TListBox` | 2 | 2 |
| VCL | `TOpenDialog` | 2 | 2 |
| VCL | `TPageControl` | 2 | 2 |
| VCL | `TToolBar` | 2 | 1 |
| VCL | `TActionList` | 1 | 1 |
| VCL | `TEdit` | 1 | 1 |
| VCL | `TFindDialog` | 1 | 1 |
| VCL | `TFontDialog` | 1 | 1 |
| VCL | `TImage` | 1 | 1 |
| VCL | `TMainMenu` | 1 | 1 |
| VCL | `TPrintDialog` | 1 | 1 |
| VCL | `TReplaceDialog` | 1 | 1 |
| VCL | `TRichEdit` | 1 | 1 |
| VCL | `TSaveDialog` | 1 | 1 |
| VCL | `TSplitter` | 1 | 1 |
| VCL | `TTimer` | 1 | 1 |

Totais por biblioteca: DFS = 1 instâncias / 1 classes; JVCL = 16 instâncias / 6 classes; Midware = 2 instâncias / 2 classes; SynEdit = 31 instâncias / 30 classes; VCL = 291 instâncias / 32 classes.

### 5.1 Confronto com o [Componentes.md](../common/Componentes.md)

| Afirmação no Componentes.md | Binário 2.5.0.1030 | Ajuste |
|---|---|---|
| JVCL visual em "47 DFMs do EXE/DLL e 3 do Diff" | 45 forms do `jedivcs.exe` têm TJv\* (o fonte `jedivcs`+`common` tem 47: inclui os forms só da DLL, como `VerSet` e `JVCSDebugView`). O `jedivcsdiff.exe` tem 5 (`TFM_EDITORPROP`, `TFM_HIGHLIGHTPROP`, `TFM_MAIN` e os compartilhados `TJVCSBASEABOUTDLG` e `TVCSLISTVIEW`); `src\jedivcsdiff` tem 3 | Precisar a contagem: "45 forms do EXE, +2 só da DLL; 5 no binário do Diff, 3 no fonte do Diff". O conjunto de classes TJv\* é o **mesmo** (29) no fonte e no binário |
| `TdfsEnhListView`: "18 listas em 15 forms do EXE" | 18 em 15 forms (TVCSSync tem 4) | Confirmado |
| `dfsStatusBar`: ProjAdmin, Syncronice, DiffMain | `TVCSPROJADMIN`, `TVCSSYNC`, `TFM_MAIN` | Confirmado |
| `TdfsSystemTreeView` em `SelectFolder` | `TVCSSELECTFOLDER` | Confirmado. Acrescentar as units dependentes (§3.1) |
| `TAppSrvClient`/`TMWBuffer` em `DBModule`, `ChkInSingle`, `MergeVersion`, `ToDo` | `TDATAMODULE1` (1+1), `TVCSCHKINSINGLE`, `TVCSMERGE`, `TVCSTODO` (2 buffers); no Diff, `TDATAMODULE1` | Confirmado. O pacote design-time (Plano 1.7) também abre o `DBModule` do Diff |
| `TmdSecureMail` | só `TVCSPROJADMIN` | Confirmado |
| `TJvPluginManager` | só `TVCSPROJADMIN` | Confirmado |
| SynEdit "Editor de texto do Diff, Line History, Compressed Diff" | Em DFM, só no `TFM_MAIN` do Diff (2× `TSynEdit` + `TSynEditSearch` + 28 highlighters). No GUI, o SynEdit é criado **em runtime** | Anotar que os forms do GUI não precisam do pacote SynEdit em design-time |
| Abbrevia "Compactação ZIP dos blobs e Backup com senha" | Nenhum `TAb*` em DFM. **Form `TPassWordDlg` (`AbDlgPwd`)** usado pelo `Backup.pas:89` | Acrescentar: ao sair da Abbrevia (F2), recriar o diálogo de senha do Backup |
| `JvGnugettext` "hoje" usado para tradução | **ausente** dos 3 binários | Registrar: o build oficial já saiu sem tradução (`LANGUAGE` desligado) |
| `JclPCRE` (para trocar por `TRegEx`) | **ausente** dos 3 binários e do fonte da v2026 | Retirar da lista ou marcar "não usado" |
| ICS "5.28" (inventário) | **5.31** | Corrigir |
| Console `jvcs.exe` "deve ficar sem JCL" | O binário 2010 linka 19 units Jcl\* e 31 units Ab\* (Abbrevia completa) | Meta mantida. A lista de units do console (`jvcs.units.csv`) é o ponto de partida |

---

## 6. Divergências fonte × binário

**Método.** Os dois lados foram reduzidos à mesma forma canônica e comparados por caminho de
componente e por propriedade:
- inteiros, floats, strings, identificadores, conjuntos ordenados, listas e coleções;
- binários representados por tamanho + MD5.

Fica fora o ruído de IDE (`Explicit*`, `PixelsPerInch`, `TextHeight`, `OldCreateOrder`,
`DesignSize`): 6 ocorrências.

**Resultado:** 630 diferenças em 107 forms. Nenhuma `CLASSE trocada`, nenhum `On*` diferente e
nenhum componente que exista só no binário.

| Categoria | Ocorrências | Leitura |
|---|---:|---|
| Geometria (`Left`/`Top`/`Width`/`Height`) | 330 | Quase tudo é `Width` de `TLabel` com AutoSize, recalculado pela troca de fonte. Também `Height` 21→22 de `TJvSpinEdit`/`TJvColorComboBox` e larguras de painéis do `TJVCSBackupTreeOptions`/`TJVCSDockProjectTree` |
| `Font.Name` `MS Sans Serif` (binário) → `Tahoma` (fonte) | 127 | Em 89 forms raiz e nos headers dos VirtualTrees/JvWizard |
| `Font`/`ParentFont=False` explícitos só no binário | 102 | O fonte limpou os overrides de fonte em labels/botões |
| **Componentes só no fonte** | 22 | Recursos de 2012 (abaixo) |
| `TJvSpinEdit` `Value/MinValue/MaxValue` inteiro → float | 15 | JVCL mais nova grava `Extended`. Atenção ao trocar por `TSpinEdit`/`TNumberBox` |
| `THotKey.InvalidKeys = [hcNone, hcShift]` só no binário | 6 | `Options` → aba Shortcut. Conferir o comportamento na troca de VCL |
| `Header.ParentFont = False` só no fonte (JvWizard) | 6 | cosmético |
| Bitmaps de `TImageList` diferentes | 5 | `LockedModules` (4390 vs 4368 bytes, +ícone SaveWIP), `History`, `ModuleHistoryWindow`, `Options` (State/Type) |
| Outros | 17 | ver abaixo |

### 6.1 Divergências estruturais (as que importam)

| Form (binário) | `.dfm` do fonte | Só no fonte | Origem |
|---|---|---|---|
| `TVCSOPTIONS` | `jedivcs\Options.dfm` | `PanelExtBugTrack` (+`edBugtrackerURL`, `edBugtrackerRegEx`, 4 labels), `PanelSaveWIP` (+`edSaveWIPcommand`, `cbSaveWIPauto`, 4 labels); `lbSelectSheet.Items` ganha "External Bugtracker" e "Save WIP" (17 → 19 abas) | 2012/09 AKroeber (`Options.pas:89`) |
| `TVCSPROJADMIN` | `jedivcs\ProjAdmin.dfm` | `PopupMenu1.miCompareAllLocalArchive`, `ActionList1.acCompareAllLocalArchive`; `MenuBar1.ButtonWidth` 50→44 e `Flat` removido | pós-2010 |
| `TJVCSDOCKLOCKEDMODULESWINDOW` | `jedivcs\JVCSLockedModulesDockWnd.dfm` | `ToolBar1.tbSaveWIP`, `popmSharedby.mnCompareAllLocalArchive` (+ bitmap da ImageList) | 2012/09 AKroeber |
| `TVCSHISTORY` | `jedivcs\History.dfm` | `PopupMenu1.BugtrackerSep`, `BugtrackerItem` | ExtBugtracker |
| `TVCSMODULEHISTORYWINDOW` | `jedivcs\ModuleHistoryWindow.dfm` | `BugtrackerSep`, `BugtrackerItem`; o form passa a gravar `ClientWidth/ClientHeight` em vez de `Width/Height` | ExtBugtracker |
| `TPASSWORDDLG` | **nenhum** | – | `AbDlgPwd` da Abbrevia (DFM da biblioteca, não do JVCS) |

Outras diferenças pontuais:
- `Options.pwedBFKey`/`pwedBFKeyConfirm.PasswordChar`: binário `'*'`, fonte `#207`. Num Delphi
  Unicode, `#207` é "Ï", e não um marcador. **Usar `'*'` ou `#$25CF`**.
- `TVCSTextCompare.Font.Color` e `Tfm_Main.Font.Color`: `clBlack` → `clWindowText` (bom para o tema
  escuro).
- `TVCSToDoEdit.Label1.Alignment = taRightJustify` só no binário.
- `JVCSCreateBranchForm.lbCreateBranch.Font.Name`: `Arial` → `Tahoma`.
- `FontDialog1.MinFontSize/MaxFontSize = 0` e `AutoScroll = False` só no binário (defaults gravados
  pelo Delphi 2007).

Há quatro `.dfm` do fonte **sem recurso** nos três EXEs: `jedivcs\VerSet.dfm`,
`jedivcs\UsedComponents.dfm` e `jedivcs\Recent.dfm` (os três só da DLL) e
`common\JVCSDebugView.dfm` (`DEBUG`).

**Conclusão:** a árvore `src\` corresponde ao trunk de ~2012. É um **superconjunto** do
2.5.0.1030 de 2010, sem nada removido em relação ao binário e com os mesmos componentes e eventos.
Os DFMs do binário servem de referência "golden" de layout. Para paridade estrita com o servidor
2.5 Beta 3, os recursos ExtBugtracker/SaveWIP/CompareAllLocalArchive são **extras** e não mexem no
protocolo, porque usam comandos locais e registro.

---

## 7. Ajustes sugeridos

### 7.1 [Componentes.md](../common/Componentes.md)

1. Seção 3 (units ausentes):
   - acrescentar `PidlHelp`, `FileChange`, `MaskSearch` e `_RES__IDS` (dependências do
     SystemTreeView) e `ExtListView` (base do EnhListView), todas "a substituir por nativo";
   - acrescentar `Blowunit` + `Cryptcon` (CryptoLib) ao lado de `BFCrypt`;
   - acrescentar `AbDlgPwd`/`TPassWordDlg` (Backup) à linha da Abbrevia.
2. `CipherLz`/`Lzh`: trocar "código morto" por "compilado no build 2.5.0.1030 (`{$DEFINE LZH}`), não
   usado pelo transporte". A decisão de remover continua.
3. `ItemProp`: retirar "morta no `DiffMain`" (está linkada no Diff).
4. Versões de referência do build oficial:

   | Biblioteca | Versão |
   |---|---|
   | JCL | 1.102 Build 3072 |
   | JVCL | ~3.34 |
   | ICS | V5.31 (não 5.28) |
   | Abbrevia | 3.05 |
   | SynEdit | 2.0.x pré-Unicode |
   | Virtual Treeview | soft-gems 4.8.x |
   | FastMM4 | 4.9x |

5. `JvGnugettext` e `JclPCRE`: ausentes do build oficial. A tradução já estava desligada.
6. JVCL: contagem "45 forms do EXE (+2 só da DLL), 5 no Diff". As classes visuais usadas são as 29
   da §5.1.
7. `Checksum`: marcar como resolvido (CRC-32 IEEE = `System.ZLib.crc32`).
8. Units de biblioteca renomeadas ou removidas nas versões instaladas: `JvVCL5Utils`,
   `SynTextDrawer`, `SynRegExpr`, `SynHighlighterHashEntries`, `SynHighlighterMPerl`,
   `VTAccessibilityFactory`, `AbDlgPwd`, `AbZipCry`, `AbTempFileStream` (tabela da §3.1).

### 7.2 [Plano-de-Port.md](../common/Plano-de-Port.md)

1. **Decisão nova:** escopo dos recursos pós-2010 (ExtBugtracker, SaveWIP, CompareAllLocalArchive).
   - Recomendação: manter, porque já estão no fonte e não afetam o protocolo.
   - Testar à parte, porque não há referência "golden" no binário oficial.
2. **Fontes de UI:** o binário usa `MS Sans Serif` e o fonte, `Tahoma`. No port com VCL nativa e
   HiDPI, padronizar `Segoe UI` (ou `ParentFont`/`Application.DefaultFont`). Os `Width` de `TLabel`
   com AutoSize vão mudar de novo; não usar o binário como referência de pixel.
3. **F2 (saída da Abbrevia):** incluir o diálogo de senha do Backup (`TPassWordDlg` de `AbDlgPwd`)
   na lista de telas a recriar.
4. **F2 (`BFCrypt`):** documentar o formato CryptoLib (ECB, padding de zeros, chave crua de 8–65
   bytes). Se o DEC for usado, configurá-lo exatamente assim.
5. **Troca `TJvSpinEdit` → nativo:** os DFMs do fonte gravam `Value/MinValue/MaxValue` como float.
   O `TJvSpinEdit` está em 7 forms (DirectSQL, Options, Purge, ServerOptions, Syncronice, ToDoEdit e
   DiffEditorProp). Só os 5 do `Options` divergem (inteiro no binário, float no fonte). Usar inteiro
   na troca.
6. **`PasswordChar = #207`** no `Options.dfm` do fonte: corrigir (§6.1).
7. **Console:** a lista de 114 units do `jvcs.exe` 2010 é a linha de base para o objetivo "console
   sem JCL". As units JCL usadas são as 19 Jcl\* de `jvcs.units.csv` (`JclSysInfo`, `JclFileUtils`,
   `JclStrings`, `JclSecurity`, `JclRegistry`…).

---

## 8. Evidências e artefatos

- **PACKAGEINFO** (offset de arquivo): `jedivcs` `0x0049558C` (7 104 B), `jedivcsdiff` `0x001CE534`
  (3 960 B), `jvcs` `0x00085354` (1 356 B), `JvcsExternalDll` `0x004ACBC8`.
- **DVCLAL**: `0x0049557C` / `0x001CE524` / `0x00085344`.
- **VERSIONINFO** (`#16/#1/#1031`): `0x005916D0` (1 240 B) / `0x001F8A78` (1 216 B) / `0x000858A0`
  (1 184 B).
- **Manifestos** `#24/#1` e `#24/#123`: `jedivcs` `0x00591BA8`/`0x00591DA0`; `jedivcsdiff`
  `0x001F8F38`/`0x001F9130`.
- **DFMs**: offsets e tamanhos na tabela da §4. Nome do recurso = classe do form em maiúsculas.
- **Strings de versão** (RVA em `jedivcs.exe`):

  | String | RVA |
  |---|---|
  | `FastMM4 (c) 2004 - 2008` | `$9788` |
  | `JCL-1.102-Build3072` | `$97B54` |
  | `TdfsEnhListView v3.72` | `$DF16C` |
  | `TWSocket … V5.31` | `$12D14C` |
  | `TMWBuffer … V1.48` | `$13C50C` |
  | `TAppSrvClient … V3.06` | `$13E5B4` |
  | `TResponseBroker … V1.07a` | `$1401E8` |
  | `TdfsStatusBar v1.24` | `$184FBC` |
  | `Virtual Treeview © 1999, 2009 Mike Lischke` | `$273F1C` |
  | `Theme manager © 2001, 2002 Mike Lischke` (`Themes` da VCL) | `$81448` |
  | créditos do About (`TJVCSBASEABOUTDLG`, Abbrevia 3.05 / DFS / mdMailSlot / mwPasLex) | `.rsrc` `$4C5D68`… |

  Os offsets equivalentes no Diff e no console estão nos `*.ascii.txt`.
- **Ferramentas** (pasta temporária não versionada, `cli\`):
  - `Dfm.cs`: leitor TPF0 com todos os `va*`, como `vaList`, `vaInt8/16/32/64`, `vaExtended` (80
    bits), `vaSingle/Double/Currency/Date`, `vaString/LString/WString/UTF8String`, `vaIdent`,
    `vaFalse/True`, `vaNil`, `vaBinary`, `vaSet`, `vaCollection` com índice, e flags
    `inherited`/`inline`/child-pos. Inclui também o escritor de DFM texto, o parser de DFM texto, a
    comparação canônica, VERSIONINFO e PACKAGEINFO;
  - `run1.ps1`: extração;
  - `run2.ps1`: round-trip e diff;
  - `run3.ps1`: DLL e offsets;
  - `inv.ps1`, `formtab.ps1`: inventário;
  - saídas `*.units.csv`, `*.rcdata.csv`, `*.classes.csv`, `src.classes.csv`, `cmp.detail.txt`.
- **Arquivos gravados no repositório:** `3rdparty\referencia-2.5.0.1030\dfm\jedivcs\*.dfm.txt` (98),
  `…\dfm\jedivcsdiff\*.dfm.txt` (9), `…\dfm\_comparacao-fonte.txt`, `…\dfm\_comparacao-fonte.csv` e
  este documento.
