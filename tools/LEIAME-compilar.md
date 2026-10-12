# compilar.bat - compilação do JEDI VCS v2026

Script de linha de comando para compilar os 4 projetos do JEDI VCS com o Delphi 13
(RAD Studio 37.0) no layout `v2026`. Estilo e convenções iguais ao modelo
`Documents\Embarcadero\Studio\Projects\Ex1\build.bat` (variáveis `BLD_*`, mensagens
`[OK]` / `[FALHOU]`, um log por alvo, `exit /b` com código, ASCII puro, CRLF).

## Uso

```
compilar.bat [exe|dll|diff|console|all] [Debug|Release] [Win32|Win64]
```

| Parâmetro | Valores | Padrão | Observação |
|---|---|---|---|
| 1 - projeto | `exe`, `dll`, `diff`, `console`, `all` | `all` | `all` compila os quatro, na ordem acima, e continua mesmo se um falhar |
| 2 - config | `Debug`, `Release` | `Debug` | |
| 3 - plataforma | `Win32`, `Win64` | `Win32` | Win32 usa `DCC32.EXE`, Win64 usa `dcc64.exe` |

Exemplos:

```
compilar.bat                      (all Debug Win32)
compilar.bat dll Release Win32
compilar.bat console Debug Win64
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
| Logs | `tools\logs\compilar_<chave>_<plat>_<cfg>.log` (cabeçalho com compilador, defines e caminhos usados + saída do compilador) |

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

## Variáveis de ambiente (todas opcionais)

| Variável | Efeito |
|---|---|
| `BDSROOT` | Pasta raiz do RAD Studio (padrão `%ProgramFiles(x86)%\Embarcadero\Studio\37.0`). O script chama `bin\rsvars.bat` dali. |
| `JVCS_CATALOG` | Pasta `CatalogRepository` do GetIt (padrão `%USERPROFILE%\Documents\Embarcadero\Studio\37.0\CatalogRepository`). |
| `JVCS_EXTRA_PATH` | Caminhos **absolutos**, separados por `;`, acrescentados a `-U`, `-I` e `-R` (modo dcc). Ex.: `set JVCS_EXTRA_PATH=D:\libs\outra\Source;D:\libs\mais`. Aspas e `;`/`\` finais são removidos. |
| `JVCS_EXTRA_DEFS` | Defines extras (separados por `;`) para todos os projetos. Ex.: `set JVCS_EXTRA_DEFS=WINDOWS`. |
| `JCL_PATH`, `JVCL_PATH`, `ICS_PATH`, `SYNEDIT_PATH`, `VTV_PATH`, `ABBREVIA_PATH` | Pasta(s) de **DCUs** da biblioteca (entra em `-U`). Substituem o padrão montado a partir de `JVCS_CATALOG`, config e plataforma. |
| `JCL_INC`, `JVCL_INC`, `ICS_INC`, `SYNEDIT_INC`, `VTV_INC`, `ABBREVIA_INC` | Pastas de **fontes/includes** (`.inc`, `.res`, `.dfm`; entram em `-I` e `-R`). |

Para apontar para outra instalação, por exemplo:

```
set BDSROOT=D:\Embarcadero\Studio\37.0
set JVCS_EXTRA_PATH=D:\Delphi\JediVCS\v2026\3rdparty\outra\Source
compilar.bat all Debug Win32
```

## O que precisa estar instalado antes

O `dcc32`/`dcc64` de linha de comando **não lê o Library Path da IDE**, por isso o
script monta os caminhos sozinho a partir do `CatalogRepository`. Instale (GetIt) antes
de compilar; versões usadas no diagnóstico:

| Biblioteca | Versão | Pasta no CatalogRepository | DCUs (`-U`) | Fontes/includes (`-I`/`-R`) |
|---|---|---|---|---|
| JCL | 2026.08 | `JEDICodeLibraryJCL-13\2026.08` | `lib\d37\win32` (ou `win64`) | `source\include`, `source\include\jedi` (`jedi.inc`, `jcl.inc`) |
| JVCL | 2026.08 | `JEDIVisualComponentLibraryJVCL-13\2026.08` | `lib\D37\win32` | `common` (`jvcl.inc`), `Resources` |
| ICS V9 | 9.7 | `ICS_VCL-13\9.7` | `Lib\<Debug\|Release>\<Win32\|Win64>\37.0` | `Source\Include` (`OverbyteIcsDefs.inc`), `Source` |
| SynEdit | 2025.03 | `SynEdit-13\2025.03` | `Packages\11AndAbove\Delphi\<plat>\<cfg>` | `Source`, `Source\Highlighters` |
| VirtualTreeView V8 | 8.3 (JAM) | `VirtualTreeview_by_JamSoftware-13\8.3` | `Packages\RAD Studio 10.4+\<plat>\<cfg>` | `Source` |
| Abbrevia | 2026.10 | `Abbrevia-13\2026.10` | `packages\11AndAbove\Delphi\<plat>\<cfg>` | `source` |

Os `.pas` dessas bibliotecas **não** entram em `-U` de propósito: com `-B` eles seriam
recompilados com as opções do JVCS (isso quebra o ICS). Só os DCUs pré-compilados são
usados. Se faltar o DCU de uma config/plataforma, o script avisa com `[AVISO] ...
pasta de DCUs nao encontrada` (compile a biblioteca na IDE para essa config).

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
  `mwPasLexTypes`, `ItemProp`, `RegAcc`, `SynHighlighterMPerl` (SynEdit 2025 não tem),
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
