# compilar.bat - compilação do JEDI VCS v2026

Script de linha de comando para compilar os 4 projetos do JEDI VCS com o Delphi 13
(RAD Studio 37.0, padrão), 12 (23.0) ou 11 (22.0) no layout `v2026`. Estilo e convenções iguais ao modelo
`Documents\Embarcadero\Studio\Projects\Ex1\build.bat` (variáveis `BLD_*`, mensagens
`[OK]` / `[FALHOU]`, um log por alvo, `exit /b` com código, ASCII puro, CRLF).

## Uso

```
compilar.bat [/delphi:11|12|13 | /bds:22|23|37] [/info] [/msbuild] [exe|dll|diff|console|libs|all] [Debug|Release] [Win32|Win64]
```

### Versão do Delphi (Delphi 11, 12 e 13)

| Opção | Efeito |
|---|---|
| `/delphi:NN` ou `/bds:NN` | Delphi 11 (`/bds:22`), 12 (`/bds:23`) ou 13 (`/bds:37`, padrão). Também aceita `22.0` etc. Padrão alternativo: variável `JVCS_DELPHI=11\|12\|13`. Se `BDSROOT` terminar em `NN.N`, ela também escolhe a versão (e precisa bater com `/delphi`) |
| `/info` | Não compila: mostra a versão, se está instalada, as pastas de JCL/JVCL/ICS/Abbrevia encontradas (e como: `versoes.ini` ou procura automática), as pastas de DCUs (`[ok]`/`[falta]`) e as saídas |
| `/msbuild` | Compila os `.dproj` (ver "Projetos .dproj") em vez do `dcc32`/`dcc64` direto; saída em `bin\msbuild\<Dnn>\<plat>\<cfg>` |

Tudo o que muda por versão fica em **`tools\versoes.ini`** (lido por `tools\versao-delphi.bat`, usado também
pelo `compilar-expert.bat` e pelo `gerar-instalador.bat`): número do Delphi, subpasta de saída (`tag`), sufixo
de pacotes (`280`/`290`/`370`), pasta de DCUs da JCL/JVCL (`d28`/`d29`/`d37`), `CatalogRepository` e as pastas
de JCL, JVCL, ICS e Abbrevia (relativas ao `CatalogRepository` do GetIt ou absolutas). Se a pasta do `.ini` não
existir, o script procura sozinho no `CatalogRepository` do usuário e no comum
(`Public\Documents\Embarcadero\Studio\<BDS>\CatalogRepository`) por `JEDICodeLibraryJCL*`/`JCL*`,
`JEDIVisualComponentLibraryJVCL*`/`JVCL*`, `ICS_VCL*`/`ICS*` e `Abbrevia*`, aceitando a pasta ou a subpasta
de versão (layout do 13: `ICS_VCL-13\9.7`) que tiver o arquivo-marcador da biblioteca; vale a última em ordem
alfabética. Os valores do 11 e do 12 no `.ini` são prováveis; confira com `/info` depois de instalar o GetIt.

Saídas por versão (DCU/DCP de versões diferentes não se misturam):

| | Delphi 13 (referência) | Delphi 11 / 12 |
|---|---|---|
| EXE/DLL/Diff/console | `bin\client\<plat>` | `bin\client\D11\<plat>` / `bin\client\D12\<plat>` (só verificação) |
| DCUs | `dcu\<plat>\<cfg>\<alvo>` | `dcu\D11\<plat>\<cfg>\<alvo>` |
| SynEdit/VTV fixados (`libs`) | `lib\...` | `lib\D11\...` (BPL `...280.bpl`) / `lib\D12\...` (`...290.bpl`) |
| Logs | `tools\logs\compilar_<alvo>_<plat>_<cfg>.log` | `tools\logs\compilar_D11_<alvo>_...log` |
| Caminhos para os `.dproj` | `lib\paths\JediVCS2026-37.0.props` | `lib\paths\JediVCS2026-22.0.props` / `-23.0.props` |

O EXE, a DLL, o Diff e o console distribuídos são **um só binário para todas as IDEs** (ADR-001), compilado no
Delphi 13; compilar no 11/12 serve para verificar que o código continua compilando lá. O que muda por IDE é só
o expert (`JvcsExpertBDS22/23/37.dll`, ver `compilar-expert.bat` abaixo).

Versão pedida e não instalada (faltam `bin\rsvars.bat` ou `bin\dcc32.exe`): mensagem `[ERRO] Delphi 12 Athens
(BDS 23.0) nao esta instalado nesta maquina`, código 1, nada é compilado nem apagado.

Exemplos multi-versão:

```
compilar.bat /delphi:11 /info                 (o que o script achou no Delphi 11)
compilar.bat /delphi:11 libs Release Win32    (SynEdit/VTV para o Delphi 11: lib\D11\...)
compilar.bat /bds:23 all Release Win32        (os 4 alvos no Delphi 12: bin\client\D12\Win32)
compilar.bat /msbuild all Release Win32       (os .dproj no Delphi 13: bin\msbuild\D13\Win32\Release)
compilar-expert.bat /delphi:12 Release nova   (bin\ideclient\Win32\JvcsExpertBDS23.dll)
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
| `exe` | `Jedivcs.dpr` (EXE standalone) | `src\jedivcs` | `USECLIENTDISPATCHER;BRANCHING;JVCS_NOBRANCHUI;UNISYNEDIT` | - |
| `dll` | `JediVCSDLL.dpr` (DLL da IDE) | `src\jedivcs` | `IDEDLL;EXT_IDE_INTF;USECLIENTDISPATCHER;BRANCHING;JVCS_NOBRANCHUI;UNISYNEDIT` | - |
| `diff` | `JEDIVCSDiff.dpr` | `src\jedivcsdiff` | `DelphiPersonalEdition` (sem `LANGUAGE`) | - (não usa mais `..\jedivcs`) |
| `console` | `jvcs.dpr` | `src\jvcs` | `DelphiPersonalEdition;JVCSCONSOLECLIENT;BRANCHING` | `..\jedivcs` |

Para incluir/alterar projeto ou define, edite só as variáveis `PRJ_<chave>_*` e
`ALL_PROJECTS` no topo do `.bat`.

- `PRJ_<chave>_OUT` (opcional): nome final da saída. O dcc32 não tem opção de nome de saída, então
  o script renomeia `NAME.dll/.map/.drc` para `OUT.*` depois do build. Hoje só
  `PRJ_dll_OUT=JvcsExternalDll`: o `JediVCSDLL.dpr` vira `bin\client\<plat>\JvcsExternalDll.dll`
  (nome que o expert procura).
- Depois de cada build OK o script copia para `bin\client\<plat>` (se ainda não estiverem lá):
  `3rdparty\fvcscrypt.dll` (só Win32, necessária ao LOGIN) e a ajuda `3rdparty\jedivcs.chm`
  (cliente/DLL) e `3rdparty\jedivcsdiff.chm` (Diff).

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

- **Com `/msbuild`**: usa `msbuild` no `<projeto>.dproj`, `/p:Config` e `/p:Platform`, log em
  `tools\logs\compilar_msbuild_<Dnn>_<alvo>_<plat>_<cfg>.log`. Defines, caminhos e saídas vêm do `.dproj` +
  `tools\msbuild\JediVCS2026.props` (ver "Projetos .dproj"); `JVCS_EXTRA_PATH` e `JVCS_EXTRA_DEFS` também valem
  lá, `*_PATH` não. Antes de 13/10/2026 a simples existência do `.dproj` trocava o modo; agora só com a opção.
- **Padrão**: chama `DCC32.EXE`/`dcc64.exe` direto no `.dpr`, a partir da
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
(+ `..\jedivcs` em `console`). `src\comp\_legacy` NÃO entra (só referência).

## Projetos .dproj (abrir na IDE do Delphi 11, 12 ou 13)

| Arquivo | Alvo |
|---|---|
| `JediVCS2026.groupproj` (raiz) | grupo com os 5 projetos abaixo |
| `src\jedivcs\Jedivcs.dproj` | `exe` |
| `src\jedivcs\JediVCSDLL.dproj` | `dll` (o PostBuild copia para `JvcsExternalDll.dll`/`.map`) |
| `src\jedivcsdiff\JEDIVCSDiff.dproj` | `diff` |
| `src\jvcs\jvcs.dproj` | `console` |
| `src\jvcsideexpert\JvcsExpertBDS.dproj` | expert (`JvcsExpertBDS22/23/37.dll`) |

- Formato do Delphi 11 (`ProjectVersion` 19.5, só Win32/Win64): abre no 11 e as IDEs novas atualizam ao salvar
  (aceite; não precisa versionar a atualização). Sem `DCCReference`: a IDE monta a árvore a partir do `uses` do
  `.dpr`. **Não aceite** alterações no `.dpr` propostas pela IDE (ex.: acrescentar `{$R *.res}` no `jvcs.dpr`).
- Tudo o que é comum fica em `tools\msbuild\JediVCS2026.props`: versão pela `dcc32<pkg>.dll` de `$(BDS)\bin`;
  pastas de JCL/JVCL/ICS/Abbrevia (1. `lib\paths\JediVCS2026-<BDS>.props`, gravado pelo `compilar.bat` com o que
  ele encontrou; 2. variáveis `JVCS_JCL_DIR`, `JVCS_JVCL_DIR`, `JVCS_ICS_DIR`, `JVCS_ABBREVIA_DIR`; 3. padrão do
  GetIt), SynEdit/VTV de `lib[\D11|D12]`, search path, defines (`OVERBYTEV6_UP` + os do projeto), namespaces,
  codepage 1252. **Mantenha os defines dos `.dproj` iguais aos do `compilar.bat`.**
- Saídas sempre fora de `bin\client`: `bin\msbuild\<Dnn>\<plat>\<cfg>` (+ `fvcscrypt.dll` e ajudas pelo
  PostBuild) e DCUs em `dcu\msbuild\...`. O binário que vai para o instalador continua sendo o do `compilar.bat`.
- `SkipResGeneration=true`: o MSBuild não regrava os `.res` versionados em `src\` (`jedivcs.RES` etc.).
- `ImportEnvOptions=false` na linha de comando: o `EnvOptions.proj` (Library Path da IDE) traz as **fontes** do
  ICS e do Abbrevia que o GetIt pôs lá; com ele o MSBuild recompilava ~70 units dessas bibliotecas. Dentro da
  IDE vale o Library Path da IDE de qualquer forma. Para imitar a IDE na linha de comando: `/p:ImportEnvOptions=true`.
- Expert: `rtl;vcl;designide`, unit alias `ToolsAPI=JvcsToolsAPI;FileHistoryAPI=JvcsFileHistoryAPI` e PreBuild
  `tools\gerar-toolsapi.ps1` (ver `compilar-expert.bat`).
- Linha de comando: `rsvars.bat` da versão e `msbuild JediVCS2026.groupproj /p:Config=Release /p:Platform=Win32`
  (ou `compilar.bat [/delphi:NN] /msbuild all Release Win32`). Antes, uma vez por versão:
  `compilar.bat [/delphi:NN] libs Release Win32` (SynEdit/VTV) e um `compilar.bat [/delphi:NN] /info` (grava o
  `lib\paths\...props`; qualquer compilação dcc também grava).

Validação de 13/10/2026 (Delphi 13.2, Release Win32), MSBuild x `compilar.bat`:

| Alvo | dcc (`compilar.bat`) | MSBuild (`.dproj`) |
|---|---|---|
| exe | 461.852 linhas, 9.912.792 bytes de código, 1.089.240 de dados; EXE 18.647.040 bytes | idem (461.851 linhas); EXE 18.647.040 bytes |
| dll | 481.493 linhas, 10.029.244 / 1.089.828 | idem; `JvcsExternalDll.dll` 18.783.744 bytes nos dois |
| diff | 33.367 linhas, 4.753.368 / 322.572 | idem |
| console | 75.244 linhas, 3.021.232 / 616.624 | idem |
| expert 13.2 / 11.3 | `JvcsExpertBDS37.dll` 128.000 / `...22.dll` 127.488 bytes | idem, mesmos imports |

DCUs gerados: 159/165/14/17 nos dois modos (nenhuma unit de biblioteca recompilada). Funcional: `jvcs.exe` dos
dois modos lista os projetos com a identidade `DEFAULT` (`tools\ai\jvcs-ai.ps1 projects -Identity DEFAULT -Text`,
apontando o `jvcsExe` por um `config.ini` temporário), `testar-dll.bat ambas` e `testar-expert.bat` sem falhas.

## compilar-expert.bat (expert por versão do Delphi)

```
compilar-expert.bat [/delphi:11|12|13 | /bds:22|23|37] [Debug|Release] [nova|original]
```

- Gera `bin\ideclient\Win32\JvcsExpertBDS<nn>.dll` (22 = Delphi 11, 23 = 12, 37 = 13; todos na mesma pasta, o
  instalador pega os que existirem). DCUs em `dcu\Win32\expert` (13) ou `dcu\D11|D12\Win32\expert`.
- Versão não instalada: `[ERRO] ... nao esta instalado`, código 1, nada muda.
- O expert **não importa nada de design-time**: compila uma cópia local da ToolsAPI sem `DockForm`
  (`tools\gerar-toolsapi.ps1`, gerada do `source\ToolsAPI` da instalação, em `dcu\...\expert\toolsapi`, fora do git)
  via unit alias. Motivo: com runtime packages cada unit de pacote no grafo de `uses` vira import da sua
  `initialization`, e o grafo do `DockForm` muda entre atualizações (o expert do 13.2 não carregava no 13.1).
  Detalhes e política: `doc\client\Port-DLL-IDE.md`, seção 5A.
- Verificação a cada build: export `INITWIZARD0001`, imports `rtl<pkg>`/`vcl<pkg>`, **nenhum** `designide<pkg>`
  e `tools\verificar-expert.ps1 -Permitidos rtl,vcl,xmlrtl -Inits` contra os `.bpl` da própria instalação.
  O Delphi 11 não traz `llvm-objdump`: o script usa o do 13/12 se existir.

### Política de build do expert (todas as atualizações)

1. Só `rtl`, `vcl` e `xmlrtl` importados; nada de genéricos da RTL no expert; funcionalidade nova vai para a
   `JvcsExternalDll.dll`.
2. Ideal: compilar na atualização **mais antiga** suportada (13.0, 12.0, 11.0).
3. Obrigatório antes de publicar: `tools\verificar-expert.ps1 -Expert <dll> -BplDir <.bpl de cada atualização>`
   com 0 ausentes (guarde os `rtl`/`vcl`/`xmlrtl<pkg>.bpl` de cada update em `D:\Delphi\JediVCS\ref-bpl\<versão>`).

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
- Versão do Delphi: `/delphi:NN` / `/bds:NN` (ou `JVCS_DELPHI`, ou a pasta final do `BDSROOT`).
  No 11/12 as saídas vão para `lib\D11\...` / `lib\D12\...` (DCU/DCP de versões diferentes
  do Delphi são incompatíveis e o `.dcp` não leva sufixo de versão); os BPL já têm o sufixo
  da versão (`...280.bpl`, `...290.bpl`, `...370.bpl`). Validado em 13/10/2026 no Delphi 11.3:
  `libs Release Win32` e `libs Debug Win32` compilam os 4 pacotes (`lib\D11\bpl\Win32\SynEditDD280.bpl` etc.).
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
| `JVCS_DELPHI` | Versão padrão (`11`, `12`, `13`) quando não há `/delphi` nem `/bds`. |
| `BDSROOT` | Pasta raiz do RAD Studio (padrão `%ProgramFiles(x86)%\Embarcadero\Studio\<BDS>`). O script chama `bin\rsvars.bat` dali. Se a última pasta for `NN.N` (ex.: `22.0`), ela escolhe a versão (e tem de bater com `/delphi`/`/bds`). |
| `JVCS_CATALOG` | Pasta `CatalogRepository` do GetIt (padrão: chave `catalog` do `versoes.ini` ou `%USERPROFILE%\Documents\Embarcadero\Studio\<BDS>\CatalogRepository`). Só JCL, JVCL, ICS e Abbrevia. |
| `JVCS_JCL_DIR`, `JVCS_JVCL_DIR`, `JVCS_ICS_DIR`, `JVCS_ABBREVIA_DIR` | Só para os `.dproj`/MSBuild: pasta raiz da biblioteca (o `compilar.bat` usa o `versoes.ini`). |
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

**Atualização (port do console, 12/10/2026):** o `console` já compila em Win32 Debug e
Release e passa no golden contra o servidor de teste (ver `doc\client\Port-Console.md`).
Por que `JVCSCONSOLECLIENT` vai no `-D`: as units de `..\jedivcs` (ex.: `JVCSClasses.pas`)
leem o `compopt.inc` da própria pasta, não o do console. Depois de um build Win32 OK o
script copia `3rdparty\fvcscrypt.dll` para `bin\client\Win32` (se ainda não estiver lá).
O restante desta seção continua valendo para `exe`, `dll` e `diff`.

Nenhum dos 4 projetos compilava no diagnóstico; o script e os caminhos funcionam e o compilador
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
