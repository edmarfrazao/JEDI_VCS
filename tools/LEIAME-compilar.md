# compilar.bat - compilação do JEDI VCS v2026

Script de linha de comando para compilar os 4 projetos do JEDI VCS com o Delphi 13
(RAD Studio 37.0) no layout `v2026`. Estilo e convenções iguais ao modelo
`Documents\Embarcadero\Studio\Projects\Ex1\build.bat` (variáveis `BLD_*`, mensagens
`[OK]` / `[FALHOU]`, um log por alvo, `exit /b` com código, ASCII puro, CRLF).

## Uso

```
compilar.bat [exe|dll|diff|console|libs|all] [Debug|Release] [Win32|Win64]
```

| Parâmetro | Valores | Padrão | Observação |
|---|---|---|---|
| 1 - projeto | `exe`, `dll`, `diff`, `console`, `libs`, `all` | `all` | `all` compila os quatro, na ordem acima, e continua mesmo se um falhar; `libs` compila só SynEdit e VirtualTreeView (ver "Alvo libs") |
| 2 - config | `Debug`, `Release` | `Debug` | |
| 3 - plataforma | `Win32`, `Win64` | `Win32` | Win32 usa `DCC32.EXE`, Win64 usa `dcc64.exe` |

Exemplos:

```
compilar.bat                      (all Debug Win32)
compilar.bat dll Release Win32
compilar.bat console Debug Win64
compilar.bat libs Release Win32   (SynEdit + VirtualTreeView, runtime e design-time)
cmd.exe /c D:\Delphi\JediVCS\v2026\tools\compilar.bat all Debug Win32
```

`compilar.bat /?` mostra a ajuda. Código de saída: `0` = tudo OK; diferente de zero =
pelo menos um projeto falhou (ou parâmetro/instalação inválidos).

### Projetos (tabela no topo do script)

| Chave | Projeto | Pasta | Defines do projeto (além de DEBUG/RELEASE e comuns) | Caminhos extras |
|---|---|---|---|---|
| `exe` | `Jedivcs.dpr` (EXE standalone) | `src\jedivcs` | `USECLIENTDISPATCHER;LANGUAGE` | - |
| `dll` | `JediVCSDLL.dpr` (DLL da IDE) | `src\jedivcs` | `IDEDLL;EXT_IDE_INTF;LANGUAGE;DelphiPersonalEdition` | - |
| `diff` | `JEDIVCSDiff.dpr` | `src\jedivcsdiff` | `LANGUAGE;DelphiPersonalEdition` | `..\jedivcs` |
| `console` | `jvcs.dpr` | `src\jvcs` | `DelphiPersonalEdition` | `..\jedivcs` |

Para incluir/alterar projeto ou define, edite só as variáveis `PRJ_<chave>_*` e
`ALL_PROJECTS` no topo do `.bat`.

Defines passados ao compilador (`-D`): `DEBUG` (config Debug) ou `RELEASE` (config
Release) + defines do projeto + `OVERBYTEV6_UP` (comum, ver abaixo) + `JVCS_EXTRA_DEFS`.
Observação: o `compopt.inc` do próprio código também faz `{$DEFINE DEBUG}` e
`{$DEFINE RELEASE}` e liga `J+`, então o `-D` só reforça.

## Saídas

| O quê | Onde |
|---|---|
| EXE / DLL / .map / .drc | `bin\client\<Win32\|Win64>` |
| DCUs | `dcu\<Win32\|Win64>\<Debug\|Release>` (compartilhado pelos 4 projetos; como o script usa `-B`, cada projeto recompila tudo) |
| Bibliotecas fixadas (alvo `libs`) | `lib\...` (ver "Alvo libs"; pasta ignorada pelo git) |
| Logs | `tools\logs\compilar_<chave>_<plat>_<cfg>.log` (cabeçalho com compilador, defines e caminhos usados + saída do compilador); pacotes: `tools\logs\compilar_lib_<pacote>_<plat>_<cfg>.log` |

As pastas de saída são criadas se não existirem. Em caso de falha o script mostra no
console as primeiras `BLD_MAXERR` (3) mensagens `Fatal:`/`Error:` do log.

## Como compila

- **Se existir `<projeto>.dproj` ao lado do `.dpr`**: usa `msbuild` (como o `build.bat`
  modelo), `/p:Config` e `/p:Platform`, log em `tools\logs\...`. Neste modo os defines e
  caminhos vêm do `.dproj`/IDE; `JVCS_EXTRA_PATH`, `*_PATH` e `JVCS_EXTRA_DEFS` são
  ignorados. (Ramo ainda não exercitado: hoje não há `.dproj`.)
- **Senão** (situação atual): chama `DCC32.EXE`/`dcc64.exe` direto no `.dpr`, a partir da
  pasta do `.dpr`, com `--no-config -B -Q`, `--codepage:1252`, os aliases de unit do
  `.dof` (`WinTypes=Windows;...`), os namespaces `-NS` (Winapi;System.Win;...;Vcl.Shell),
  `-D`, `-U`, `-I`, `-R`, `-E..\..\bin\client\<plat>` e `-NU..\..\dcu\<plat>\<cfg>`.
  - Debug: `-$O- -$Q+ -$R+ -$C+ -$D+ -$L+ -$Y+ -V -GD`, DCUs de debug da RTL/VCL
    (`lib\win32\debug`).
  - Release: `-$O+ -$Q- -$R- -$C- -$D- -$L- -$Y-`, DCUs `lib\win32\release`.
  - `--no-config` evita o `dcc32.cfg`, que aponta para o caminho padrão da instalação e
    para `lib\...\release` (assim `BDSROOT` e a config Debug funcionam).
  - `-R` inclui também `lib\<plat>\release`: o `controls.res` só existe lá e o
    link falha sem isso na config Debug.
  - **Não** se usa `-$J+` global (o `.dof` tinha `J=1`): o `compopt.inc` do JVCS já faz
    `{$J+}` por unit, e o `-$J+` global quebra o ICS (`E2203 $WEAKPACKAGEUNIT contains
    global data`).

Search path base (relativo à pasta do `.dpr`, usado em `-U`, `-I` e `-R`):
`..\common;..\common\client;..\comp\midware;..\comp\textdiff;..\comp\mdmailslot;..\comp\crc;..\comp\mwtools`
(+ `..\jedivcs` em `diff` e `console`). `src\comp\_legacy` NÃO entra (só referência).

## Alvo libs (SynEdit e VirtualTreeView fixados no repositório)

SynEdit e VirtualTreeView **não vêm mais do GetIt**: o script usa as fontes fixadas em
`src\comp\synedit` (pyscripter/SynEdit, `Packages\Alexandria+\Delphi`) e
`src\comp\virtualtreeview` (JAM-Software V8.5, `Packages\RAD Studio 10.4+`), as mesmas
para Delphi 11, 12 e 13. O alvo `libs` compila os pacotes com `msbuild` (os `.dproj` das
bibliotecas, sem alterar nada em `src\`):

| Pacote | Tipo | Plataformas | Quando |
|---|---|---|---|
| `SynEditDR`, `VirtualTreesR` | runtime | Win32 e Win64 | sempre |
| `SynEditDD`, `VirtualTreesD` | design-time (para a IDE) | só Win32 | só no alvo `libs` (não na compilação automática) |

Saídas (dentro da v2026, pasta `lib\` ignorada pelo git):

| O quê | Onde |
|---|---|
| DCUs runtime (usados em `-U` pelos projetos) | `lib\synedit\<plat>\<cfg>` e `lib\virtualtreeview\<plat>\<cfg>` (ex.: `lib\synedit\Win32\Debug\SynEdit.dcu`) |
| DCUs design-time | `lib\synedit\design\Win32\<cfg>` e `lib\virtualtreeview\design\Win32\<cfg>` |
| BPL | `lib\bpl\<plat>` (ex.: `lib\bpl\Win32\SynEditDR370.bpl`, `SynEditDD370.bpl`, `VirtualTreesR370.bpl`, `VirtualTreesD370.bpl`) |
| DCP | `lib\dcp\<plat>` (`SynEditDR.dcp`, `SynEditDD.dcp`, `VirtualTreesR.dcp`, `VirtualTreesD.dcp`) |
| `.res` gerados pelo MSBuild | `lib\res\<plat>\<cfg>` (assim nada é gravado em `src\`) |

- BPL e DCP **não** têm subpasta de configuração: Debug e Release gravam nos mesmos
  `lib\bpl\<plat>` / `lib\dcp\<plat>` (vale o da última execução). Para os pacotes que
  vão para a IDE, rode `libs Release Win32` por último. Feche a IDE antes, senão o BPL
  carregado fica travado e o build falha ao gravar.
- Os `.dproj` das bibliotecas apontam saídas para dentro de `src\` (`..\cpp`, `..\..\Source`);
  o script sobrepõe tudo por propriedades do MSBuild (`DCC_DcuOutput`, `DCC_BplOutput`,
  `DCC_DcpOutput`, `DCC_BpiOutput`, `DCC_ObjOutput`, `DCC_HppOutput`, `BRCC_OutputDir`) e
  desliga a saída de C++Builder (`DCC_CBuilderOutput=None`; `set JVCS_CBUILDER=All`
  religa, com `.hpp` em `lib\hpp` e `.bpi/.lib/.obj` ao lado dos DCP).
- `/t:Build` do MSBuild já recompila tudo (equivale ao `-B`).
- **Compilação automática**: `all` e os projetos isolados (`exe`, `dll`, ...) rodam `libs`
  sozinhos (só os pacotes runtime) quando falta `SynEdit.dcu` ou `VirtualTrees.dcu` na
  pasta da config/plataforma pedida. Se `SYNEDIT_PATH`/`VTV_PATH` forem definidas no
  ambiente, não há compilação automática. `compilar.bat libs ...` sempre recompila.
- Fontes/includes (`.inc`, `.dfm`, `.res`) para `-I`/`-R`: `src\comp\synedit\Source`,
  `src\comp\synedit\Source\Highlighters` e `src\comp\virtualtreeview\Source` (os `.pas` não
  entram em `-U`, só os DCUs de `lib\`).
- Versão do Delphi: o `BDSVER` (padrão `37.0`) é deduzido do nome da pasta final do
  `BDSROOT` quando ela é numérica (ex.: `set BDSROOT=D:\Embarcadero\Studio\22.0` -> `22.0`).
  Para `BDSVER` diferente do padrão, as saídas vão para `lib\<BDSVER>\...` (DCU/DCP de
  versões diferentes do Delphi são incompatíveis e o `.dcp` não leva sufixo de versão);
  os BPL já têm o sufixo da versão (`...370.bpl`).
- Pasta de BPL/DCP diferente: `set JVCS_BPLDIR=<pasta>` e `set JVCS_DCPDIR=<pasta>`
  (ver abaixo).

### Instalar SynEditDD e VirtualTreesD na IDE (passo a passo)

O script **não** instala nada na IDE nem mexe no registro; a instalação é manual:

1. Feche a IDE e rode `compilar.bat libs Release Win32`. Confirme `[OK]` nos 4 pacotes e
   os arquivos em `lib\bpl\Win32`.
2. Abra o Delphi 13 e **desinstale os do GetIt** (senão haverá duas versões):
   *Component > Install Packages*, remova/desmarque "TurboPack SynEdit" e
   "VirtualTreeView Controls" (os do GetIt; os BPL antigos `SynEdit*370.bpl`/
   `VirtualTrees*370.bpl` ficavam em `C:\Users\Public\Documents\Embarcadero\Studio\37.0\Bpl`)
   e, se quiser, desinstale-os pelo GetIt.
3. *Component > Install Packages > Add...* e escolha
   `D:\Delphi\JediVCS\v2026\lib\bpl\Win32\SynEditDD370.bpl`; repita com
   `D:\Delphi\JediVCS\v2026\lib\bpl\Win32\VirtualTreesD370.bpl`. Os componentes aparecem
   nas paletas "SynEdit" e "Virtual Controls".
4. Os pacotes de design dependem dos runtime (`SynEditDR370.bpl`, `VirtualTreesR370.bpl`),
   que o carregador da IDE procura no `PATH`. Se aparecer "não foi possível carregar o
   pacote ... não encontrado", escolha uma das opções:
   - acrescente `D:\Delphi\JediVCS\v2026\lib\bpl\Win32` ao `PATH` do Windows (ou da IDE) e
     reinicie a IDE; ou
   - gere os BPL/DCP direto na pasta pública da IDE, que já está no `PATH` dela:
     `set JVCS_BPLDIR=C:\Users\Public\Documents\Embarcadero\Studio\37.0\Bpl` e
     `set JVCS_DCPDIR=C:\Users\Public\Documents\Embarcadero\Studio\37.0\Dcp` antes de
     `compilar.bat libs Release Win32` (isso grava fora da v2026, faça só se quiser), e
     instale o `SynEditDD370.bpl` / `VirtualTreesD370.bpl` dali.
5. Para abrir/editar formulários com esses componentes na IDE, acrescente em *Tools >
   Options > Language > Delphi > Library > Library path* (Win32) as pastas de DCUs
   `D:\Delphi\JediVCS\v2026\lib\synedit\Win32\Release` e
   `D:\Delphi\JediVCS\v2026\lib\virtualtreeview\Win32\Release`, e em *Browsing path* as
   fontes `D:\Delphi\JediVCS\v2026\src\comp\synedit\Source` (e `\Highlighters`) e
   `D:\Delphi\JediVCS\v2026\src\comp\virtualtreeview\Source`.
6. Depois de recompilar as bibliotecas (outro `libs`), feche a IDE antes (BPL travado) e
   reabra; não é preciso reinstalar se o caminho dos BPL for o mesmo.

## Variáveis de ambiente (todas opcionais)

| Variável | Efeito |
|---|---|
| `BDSROOT` | Pasta raiz do RAD Studio (padrão `%ProgramFiles(x86)%\Embarcadero\Studio\37.0`). O script chama `bin\rsvars.bat` dali. Se a última pasta for `NN.N` (ex.: `22.0`), vira o `BDSVER` (CatalogRepository e `lib\<BDSVER>`). |
| `JVCS_CATALOG` | Pasta `CatalogRepository` do GetIt (padrão `%USERPROFILE%\Documents\Embarcadero\Studio\37.0\CatalogRepository`). Só JCL, JVCL, ICS e Abbrevia. |
| `JVCS_BPLDIR`, `JVCS_DCPDIR` | Pastas de saída dos BPL e dos DCP/BPI/LIB no alvo `libs` (padrão `lib\bpl\<plat>` e `lib\dcp\<plat>`). |
| `JVCS_CBUILDER` | `DCC_CBuilderOutput` dos pacotes (padrão `None`; `All` gera `.hpp/.obj/.bpi/.lib`). |
| `JVCS_EXTRA_PATH` | Caminhos **absolutos**, separados por `;`, acrescentados a `-U`, `-I` e `-R` (modo dcc). Ex.: `set JVCS_EXTRA_PATH=D:\libs\outra\Source;D:\libs\mais`. Aspas e `;`/`\` finais são removidos. |
| `JVCS_EXTRA_DEFS` | Defines extras (separados por `;`) para todos os projetos. Ex.: `set JVCS_EXTRA_DEFS=WINDOWS`. |
| `JCL_PATH`, `JVCL_PATH`, `ICS_PATH`, `SYNEDIT_PATH`, `VTV_PATH`, `ABBREVIA_PATH` | Pasta(s) de **DCUs** da biblioteca (entra em `-U`). Substituem o padrão montado a partir de `JVCS_CATALOG` (ou de `lib\` para SynEdit/VTV), config e plataforma. `SYNEDIT_PATH`/`VTV_PATH` definidas desligam a compilação automática do `libs`. |
| `JCL_INC`, `JVCL_INC`, `ICS_INC`, `SYNEDIT_INC`, `VTV_INC`, `ABBREVIA_INC` | Pastas de **fontes/includes** (`.inc`, `.res`, `.dfm`; entram em `-I` e `-R`). |

Para apontar para outra instalação, por exemplo:

```
set BDSROOT=D:\Embarcadero\Studio\37.0
set JVCS_EXTRA_PATH=D:\Delphi\JediVCS\v2026\3rdparty\outra\Source
compilar.bat all Debug Win32
```

## O que precisa estar instalado antes

O `dcc32`/`dcc64` de linha de comando **não lê o Library Path da IDE**, por isso o
script monta os caminhos sozinho. JCL, JVCL, ICS e Abbrevia vêm do `CatalogRepository`:
instale (GetIt) antes de compilar. SynEdit e VirtualTreeView vêm do repositório (alvo
`libs`, ver acima). Versões usadas no diagnóstico:

| Biblioteca | Versão | Pasta no CatalogRepository | DCUs (`-U`) | Fontes/includes (`-I`/`-R`) |
|---|---|---|---|---|
| JCL | 2026.08 | `JEDICodeLibraryJCL-13\2026.08` | `lib\d37\win32` (ou `win64`) | `source\include`, `source\include\jedi` (`jedi.inc`, `jcl.inc`) |
| JVCL | 2026.08 | `JEDIVisualComponentLibraryJVCL-13\2026.08` | `lib\D37\win32` | `common` (`jvcl.inc`), `Resources` |
| ICS V9 | 9.7 | `ICS_VCL-13\9.7` | `Lib\<Debug\|Release>\<Win32\|Win64>\37.0` | `Source\Include` (`OverbyteIcsDefs.inc`), `Source` |
| SynEdit | pyscripter 2025-11-24 (fixado) | `src\comp\synedit` (repositório) | `lib\synedit\<plat>\<cfg>` | `src\comp\synedit\Source`, `...\Source\Highlighters` |
| VirtualTreeView | V8.5 JAM (fixado) | `src\comp\virtualtreeview` (repositório) | `lib\virtualtreeview\<plat>\<cfg>` | `src\comp\virtualtreeview\Source` |
| Abbrevia | 2026.10 | `Abbrevia-13\2026.10` | `packages\11AndAbove\Delphi\<plat>\<cfg>` | `source` |

Os `.pas` dessas bibliotecas **não** entram em `-U` de propósito: com `-B` eles seriam
recompilados com as opções do JVCS (isso quebra o ICS). Só os DCUs pré-compilados são
usados. Se faltar o DCU de uma config/plataforma, o script avisa com `[AVISO] ...
pasta de DCUs nao encontrada` (para JCL, JVCL, ICS e Abbrevia: compile a biblioteca na
IDE para essa config; para SynEdit/VTV: `compilar.bat libs <cfg> <plat>`).

### Define OVERBYTEV6_UP (comum a todos os projetos)

O código antigo usa as units `WSocket`, `Ping` e `Icmp` (ramo `{$ELSE}` de
`{$IFDEF OVERBYTEV6_UP}`). Com o ICS 9 elas se chamam `OverbyteIcsWSocket`,
`OverbyteIcsPing` e `OverbyteIcsIcmp`. Por isso `OVERBYTEV6_UP` é acrescentado a todos
os projetos (variável `BLD_COMMONDEFS` no topo do `.bat`; remova para voltar ao
comportamento antigo). Exceção conhecida: `src\comp\midware\ApsCli.pas` usa `WSocket`
sem condicional (ver pendências).

## Pendências conhecidas (diagnóstico de 12/10/2026, Debug Win32)

Nenhum dos 4 projetos compila ainda; o script e os caminhos funcionam e o compilador
para no primeiro erro fatal:

- **FastMM4**: não existe `src\comp\fastmm` no layout novo. `exe` e `diff` falham com
  `F2613 Unit 'FastMM4' not found`; `console` com `F1026 File not found:
  '..\comp\fastmm\FastMM4.pas'`.
- **dll**: `JVCSIDESettings.pas(99)` usa `{$ifdef WINDOWS}` (símbolo que o Delphi 13 não
  define; só existe `MSWINDOWS`) -> `E2029` e cascata (`DelphiHKEY`, `RegKeyExists`...).
  Contorno só no script: `set JVCS_EXTRA_DEFS=WINDOWS`. Correção definitiva: trocar por
  `MSWINDOWS` no fonte.
- Units antigas/terceiros ainda sem fonte nem DCU em lugar nenhum (com os defines atuais):
  `EnhListView`, `dfsStatusBar`, `FavOpenDialog`, `Checksum`, `BFCrypt`, `CipherLz`,
  `SortGrid`, `SystemTreeView`, `SystemControlPack`, `RekScan`, `HtmlHlp`, `mwPasLex`,
  `mwPasLexTypes`, `ItemProp`, `RegAcc`, `SynHighlighterMPerl` (o SynEdit fixado também não tem),
  e `WSocket` em `ApsCli.pas`.
- Outro: `.dpr` ainda referencia `{$R \Projects\Jedivcs\src\comp\soft-gems\thememanager\Resources\winxp.res}`
  (caminho absoluto do ambiente antigo).

## Dicas

- Erros de unit não encontrada (`F2613`) ou arquivo não encontrado (`F1026`): veja o
  cabeçalho do log (`# Unit path`, `# Include`, `# Res path`) para conferir os caminhos.
- Os projetos compartilham `dcu\<plat>\<cfg>`; como o script usa `-B`, não há mistura de
  DCUs entre projetos com defines diferentes.
- O comprimento da linha de comando do `cmd` é limitado (8191 caracteres). Hoje fica em
  ~4 KB; se acrescentar muitos caminhos em `JVCS_EXTRA_PATH`, prefira caminhos curtos.
- `libs` imprime o aviso `Hint warning H2675: Directory not found: .\Win32\<cfg>` nos
  pacotes do VirtualTreeView: vem do `DCC_UnitSearchPath` do `.dproj` deles (pasta que
  não existe); é inofensivo.
- Se o build dos pacotes deixar `VirtualTreesR.res` / `VirtualTreesD.res` (ou outro
  arquivo) dentro de `src\comp\...`, é sobra de uma versão antiga do script: o script atual
  grava os `.res` em `lib\res` e não escreve em `src\`. Confira com `git status`.
- Resumo da última verificação (12/10/2026, Delphi 13.2): `libs Debug Win32`,
  `libs Release Win32` e `exe Debug Win64` (compilação automática) compilam os pacotes sem
  erro; `all Debug Win32` segue falhando só por código do cliente (FastMM4, `WINDOWS`).
