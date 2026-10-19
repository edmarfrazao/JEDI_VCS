# Versões

Todas as versões relevantes do projeto num lugar só: produto, Delphi, dependências, binários de referência e histórico. Estado verificado em **12/10/2026**. Componentes e licenças: [Componentes.md](Componentes.md).

## 1. Versão do produto

| Item | Valor (beta 6, build 2063) |
|---|---|
| Nome | **JEDI VCS 2.5 Beta 2026** |
| FileVersion (numérico) | `2.5.0.2063` (`FILEVERSION 2,5,0,2063`) |
| ProductVersion | `2.5.0.0` (`PRODUCTVERSION 2,5,0,0`, **fixo**) |
| Flag | pré-lançamento nas betas (`VS_FF_PRERELEASE`, `FILEFLAGS 0x2`); sai na versão final |
| `BuildType` | `Beta Build` (`Release Build` na final) |
| `BuildTimestamp` | data/hora do build (`dd.mm.aaaa hh:nn:ss`), gerada a cada compilação |
| `InternalVersion` | `2.5.0 Beta 6 (2026)` |
| `VCS` | `JVCS 2.5.0.2063 Beta 6 (2026) https://github.com/edmarfrazao/JEDI_VCS` |
| `ProductName` | `JEDI Version Control System` |
| `LegalCopyright` | `Released under MPL 1.1` |
| Fonte única | `tools\versao.ini` (`Build`, `Stage`, `StageNumber`) |
| Instalador | `JediVCS-2.5.0-Beta6-build2063-Setup.exe`; Painel de Controle: "JEDI VCS 2.5 Beta 2026 (Beta 6, build 2063)", versão 2.5.0.2063 |

## Numeração de versões

Segue o **mesmo padrão do JEDI VCS original** (`jvcsver.rc` do 2.5.0.1030: `FILEVERSION 2,5,0,1030`,
`PRODUCTVERSION 2,5,0,0`, `BuildType "Beta Build"`, `BuildTimestamp`, `InternalVersion "2.5.0 Beta 3"`,
`VCS "JVCS 2.5.0.1030 Beta 3 ..."`). Adotado em 13/10/2026; substitui o esquema anterior
(`2.5.0.2026` fixo em todas as betas, que não dizia qual beta estava instalada).

- `PRODUCTVERSION` numérico **fixo em `2,5,0,0`**: o LOGIN do EXE e da DLL envia
  `VCSProcBase.GetJVCSAppProductVersionInt` = Maj×100 + Min×10 + Release = **250** (o 4º campo é ignorado),
  igual ao 2.5.0.1030. O Diff e o console enviam 239 fixo. Não mude.
- `FILEVERSION 2,5,0,<Build>`: o build diz qual versão está instalada.

| Versão | Build | FILEVERSION | `InternalVersion` | Setup |
|---|---|---|---|---|
| Beta 5 | **2050** | `2.5.0.2050` | `2.5.0 Beta 5 (2026)` | `JediVCS-2.5.0-Beta5-build2050-Setup.exe` |
| Beta 5, 1ª recompilação de correção | 2051 | `2.5.0.2051` | `2.5.0 Beta 5 (2026)` | `JediVCS-2.5.0-Beta5-build2051-Setup.exe` |
| Beta 6 | 2060 | `2.5.0.2060` | `2.5.0 Beta 6 (2026)` | `JediVCS-2.5.0-Beta6-build2060-Setup.exe` |
| Beta 6, 1ª recompilação de correção (18/10/2026) | 2061 | `2.5.0.2061` | `2.5.0 Beta 6 (2026)` | `JediVCS-2.5.0-Beta6-build2061-Setup.exe` |
| Beta 6, 2ª recompilação de correção (19/10/2026) | 2062 | `2.5.0.2062` | `2.5.0 Beta 6 (2026)` | `JediVCS-2.5.0-Beta6-build2062-Setup.exe` |
| Beta 6, 3ª recompilação de correção (19/10/2026) | 2063 | `2.5.0.2063` | `2.5.0 Beta 6 (2026)` | `JediVCS-2.5.0-Beta6-build2063-Setup.exe` |
| Versão final | 2100 | `2.5.0.2100` | `2.5.0 (2026)` | `JediVCS-2.5.0-build2100-Setup.exe` |

Regra: beta N → build `2000 + N×10`; recompilação de correção da mesma beta → +1 (2051, 2052, …); final
→ 2100 (`Stage=Release`, sem `VS_FF_PRERELEASE`, `BuildType "Release Build"`). Os builds ficam acima do
`1030` do original, então o 2.5.0.2050 é "mais novo" que o 2.5.0.1030 em qualquer comparação de
FileVersion; as betas anteriores (2.5.0.2026) são reconhecidas pelo instalador como desta linha
(build ≥ 2000).

**Como subir a versão:** edite só `tools\versao.ini` (`Build`, `Stage`, `StageNumber`) e recompile.
`tools\gerar-versao.ps1` (chamado por `compilar.bat` e `compilar-expert.bat`) gera
`src\common\jvcsversao.rh` e os `jvcsver.res` (fora do git, regenerados a cada build, com o
`BuildTimestamp` daquele build); o `setup\JediVCS2026.iss` lê o mesmo `.ini` com `ReadIni` e o
`gerar-instalador.bat` confere `FILEVERSION = 2.5.0.<Build>` em todos os binários. O script recusa um
`Build` fora da regra. Para compilar pela IDE sem os scripts, gere antes os `.res`:
`powershell -File tools\gerar-versao.ps1 -Brcc <brcc32.exe> -Rc src\jedivcs\jvcsver.rc,src\jedivcsdiff\jvcsver.rc,src\jvcs\jvcsver.rc`.

Onde o usuário vê a versão (lida do VERSIONINFO em tempo de execução, `src\common\JVCSAppVersion.pas`):

- título da janela principal (EXE e DLL na IDE): `JEDI VCS (2.5.0 Beta 6 – build 2063) >> ...`;
- About do cliente e do Diff: `V 2.5.0 Beta 6 – build 2063 - Buildtime <data/hora>`;
- 1ª linha do console: `JEDI VCS console client 2.5.0 Beta 6 - build 2063 (Project JEDI ...)`;
- expert: log `JVCS Expert iniciando (versao 2.5.0.2063 - 2.5.0 Beta 6 - build 2063, ...)`, splash e About
  da IDE (`JEDI Version Control System 2.5.0 Beta 6 - build 2063`);
- Windows: Propriedades > Detalhes do arquivo (Versão do arquivo 2.5.0.2063) e Painel de Controle.

Outros pontos:

- `2.5` = linha funcional do JEDI VCS (código-base 2.5 Beta 3, ~2012). O servidor continua sendo o **2.5 Beta 3** (Firebird) e não muda.
- "Beta 2026" (nome do produto e do instalador) identifica esta linha e a distingue de "2.50 Beta 3 Refresh till 10.4 Sydney" (instalador oficial).
- "Include version information" fica desligado nos `.dproj`; o `tools\versao.ini` é a fonte única.

## 2. Versões do Delphi

| Delphi | `VERxxx` | `CompilerVersion` | `RTLVersion` | BDS (registro/pasta) | Sufixo de pacote (`LIBSUFFIX AUTO`) | `jedi.inc` | Situação nesta máquina |
|---|---|---|---|---|---|---|---|
| 11 Alexandria | `VER350` | 35.0 | 35.00 | 22.0 | 280 | `DELPHI28` | **instalado em 13/10/2026**: 11.3, `rtl280.bpl` `28.0.48361.3236`; GetIt ainda vazio |
| 12 Athens | `VER360` | 36.0 | 36.0 (não confirmado em fonte primária) | 23.0 | 290 | `DELPHI29` | **não instalado** (será instalado depois) |
| 13 Florence | `VER370` | 37.0 | 37.00 | 37.0 | 370 | `DELPHI37` | **instalado**: 13.2 Professional, build `37.0.60952.8797` |

Observações:

- Não existe BDS 24–36: o 13 é BDS 37.0.
- A tabela "referência de comportamento" do expert original usa Delphi 10.2 (BDS 19, `VER320`, sufixo 250), 10.3 (BDS 20, `VER330`, 260) e 10.4 (BDS 21, `VER340`, 270). O `JvcsExternalDll.dll` original foi compilado em **Delphi 2007**.
- O código-base 2.5 compilava até XE2 (~2012).
- Fonte dos números: skill `D:\skills\delphi\references\versoes-e-defines.md` (conferida na DocWiki Florence) e `dcc32.exe`/`bds.exe` desta máquina (`37.0.60952.8797`). A skill cita Delphi 11 Enterprise e 12 como "outras versões" instaladas; **isso não se confirma**: `Studio\22.0` e `Studio\23.0` não existem em `C:\Program Files (x86)\Embarcadero` e não há chaves `BDS\22.0`/`BDS\23.0` no registro.
- Constantes extras do 13.x: `RTLVersion131` e `RTLVersion132` existem; teste update específico com `{$IF Declared(RTLVersion132)}`.
- Plataforma da fase 1: **Win32 apenas** (a `fvcscrypt.dll` é de 32 bits e a IDE de 32 bits continua no Delphi 13). Win64/ARM64EC ficam na F6.
- Matriz de build alvo: Win32 em Delphi 13.2, 12 e 11, Debug e Release.
- Nomes de saída do expert por `CompilerVersion`: `JvcsExpertBDS37.dll` (13), `JvcsExpertBDS23.dll` (12), `JvcsExpertBDS22.dll` (11).
- Pacotes de design-time da JVCL por IDE: `d37` (13), `d29` (12), `d28` (11). Pastas de DCUs da JCL/JVCL:
  `lib\d28|d29|d37\win32`; do ICS: `Lib\<cfg>\<plat>\<BDS>` (`22.0`, `23.0`, `37.0`).
- Compilador por versão: `bin\dcc32280.dll` (11), `dcc32290.dll` (12), `dcc32370.dll` (13) — é por ela que o
  `tools\msbuild\JediVCS2026.props` reconhece a versão. Tudo o que muda por versão nos scripts está em
  `tools\versoes.ini` (`/delphi:11|12|13` ou `/bds:22|23|37` no `compilar.bat` e no `compilar-expert.bat`).
- **Atualizações** (13.0/13.1/13.2, 12.0–12.3, 11.0–11.3): o expert precisa carregar em todas. Ele só importa
  `rtl<pkg>`, `vcl<pkg>` e `xmlrtl<pkg>` (ToolsAPI local sem `DockForm`; ver
  [Port-DLL-IDE](../client/Port-DLL-IDE.md), 5A): o do 13.2 importava `@Ideeditorcontrolbridge@initialization`
  do `designide370.bpl`, que o 13.1 não tem. Conferência: `tools\verificar-expert.ps1 -BplDir <.bpl da atualização>`.
- IDE de 64 bits (12.3 e 13, `bin64\bds.exe`): listas próprias `Experts x64` / `Known Packages x64`; o expert é
  32 bits e só vai em `Experts`.

## 3. Versões das dependências

| Dependência | Versão exata | Origem | Observação |
|---|---|---|---|
| JCL | 2026.08 (GetIt, atualizado em 18/08/2026) | GetIt `JEDICodeLibraryJCL-13` | No D11/D12, usar o GitHub num commit equivalente: o GetIt oferece versões antigas nessas IDEs |
| JVCL | 2026.08 | GetIt `JEDIVisualComponentLibraryJVCL-13` | Só transição. Mesma regra de JCL para D11/D12 |
| ICS for VCL | 9.7 (GetIt, atualizado em 19/05/2026) | GetIt `ICS_VCL-13` | Para D11/D12, a mesma 9.7 ou o SVN `icsv9` (9.8 Beta) |
| Abbrevia (TurboPack) | 2026.10 | GetIt `Abbrevia-13` | Ponte; sai na F2 |
| SynEdit (pyscripter) | commit `84391a3` (2025-11-24) | GitHub, fixado em `src\comp\synedit` | Mesma fonte nas três IDEs |
| Virtual-TreeView (JAM) | V8.5, commit `eb27351b` (2026-10-01; tag publicada em 2026-10-02) | GitHub, fixado em `src\comp\virtualtreeview` | Mesma fonte nas três IDEs |
| Midware (cópia local) | ApsCli 3.06, RFormat 1.48, CBroker 1.07a | `<clone>\Components` | Port com base em OverbyteApsCli 7.00 / OverbyteRFormat 7.02 |
| mdMailSlot | 1.17 | clone | |
| TDiff | 2.5.1 (2005) | clone | |
| CastaliaPasLex | commit único de 2011-10-12 | GitHub `jacobthurman/Castalia-Delphi-Parser` | A obter (F0) |
| dxgettext (`gnugettext.pas`) | r196 (2026-08-19) | SourceForge | A obter (F0/F3) |
| EncryptedZipFile (Uwe Raabe) | n/r (a obter) | GitHub | A obter (F0) |
| DEC | 6.4.1 | GitHub | Condicional |
| `fvcscrypt.dll` | 1.0.0.19 | instalação oficial | Binário fechado |
| Base do código do cliente | clone `Libaud/JediVCS`, commit `f6a777d` (28/12/2017) | `D:\Delphi\JediVCS\Fontes_JediVCS_2.5` | Ver [LEIAME-Origem.md](LEIAME-Origem.md) |

Quando as dependências forem instaladas em D11/D12, registrar aqui os commits equivalentes (e ajustar as
seções `[22.0]`/`[23.0]` de `tools\versoes.ini`; os valores de lá são prováveis). Checklist:
[manual, capítulo 10](../manual/10-Delphi-11-e-12.md).

## 4. Ferramentas

| Ferramenta | Versão |
|---|---|
| Windows | 11 Enterprise 10.0.26200, **ARM64** (Delphi 13.2 roda por emulação x64) |
| `dcc32.exe` / `bds.exe` | 37.0.60952.8797 |
| Claude Code CLI | 2.1.296 (`%USERPROFILE%\.local\bin\claude.exe`, verificado). A informação inicial dizia 2.1.168; vale o valor lido do executável |
| Skill Delphi | `D:\skills\delphi` (SKILL.md + `references`) |
| Git | repositório local em `D:\Delphi\JediVCS\v2026`, sem conversão de fim de linha (`.gitattributes: * -text`) |

## 5. Binários de referência 2.5.0.1030

Origem: instalador oficial **JVCS v2.50 Client Setup Beta 3 "Refresh till 10.4 Sydney"** (`JVCSv2.50ClientSetupBeta3_Refresh_till_10_4Sydney.exe`, SourceForge, 07/02/2021), instalado em `C:\Program Files (x86)\JEDI\JVCS` em 12/10/2026. Cópias em `3rdparty\referencia-2.5.0.1030` têm o mesmo SHA-256 dos instalados. `ProductVersion` dos executáveis: `2.5.0.0`; `FileVersion`: `2.5.0.1030`.

Copiados para `3rdparty\referencia-2.5.0.1030`:

| Arquivo | FileVersion | Tamanho (bytes) |
|---|---|---|
| `jedivcs.exe` | 2.5.0.1030 | 5.840.896 |
| `jedivcsdiff.exe` | 2.5.0.1030 | 2.069.504 |
| `jvcs.exe` | 2.5.0.1030 | 548.352 |
| `JvcsExternalDll.dll` | 2.5.0.1030 | 5.938.688 |
| `JvcsExpertBDS19.dll` | 2.5.0.1030 | 84.480 |
| `JvcsExpertBDS20.dll` | 2.5.0.1030 | 83.456 |
| `JvcsExpertBDS21.dll` | 2.5.0.1030 | 83.968 |

Copiados para `3rdparty` (runtime): `fvcscrypt.dll` 1.0.0.19 (63.488), `jedivcs.chm` (358.704), `jedivcsdiff.chm` (20.444), `ffdef.jvcs`, `ulist.jvcs`, `vcllist.jvcs`, `vcllistbcb.jvcs`, `verinf.jvcs`, `htm_rep.htm`.

Presentes só na instalação oficial (não copiados): `JvcsExpertD7.dll` e `JvcsExpertBDS1.dll` a `JvcsExpertBDS18.dll` (todos 2.5.0.1030; não existe BDS 13), `JvcsVcsManagerD5.dll` e `JvcsVcsManagerD6.dll` (2.5.0.1030), `zipdll.dll` e `unzdll.dll` (1.4.0.0, DelZip), `borlndmm.dll` (6.0.6.163), `Jvcs.Releasenotes.pdf`, `Setup.exe` e o desinstalador.

Compatibilidade de protocolo: o servidor 2.5 Beta 3 é o par obrigatório. O cliente novo precisa produzir bytes idênticos aos do 2.5.0.1030 (teste "golden", F1).

## 6. Binários gerados nesta árvore

| Arquivo | Versão | Estado |
|---|---|---|
| `bin\ideclient\Win32\JvcsExpertBDS37.dll` | 2.5.0.2063 (Beta 6, pré-lançamento) | Compilado no 13.2: importa só `rtl370`/`vcl370`/`xmlrtl370`, sem `designide370` |
| `bin\ideclient\Win32\JvcsExpertBDS22.dll` / `...BDS23.dll` | 2.5.0.2063 | Compilados no 11.3 / 12.x: só `rtl`/`vcl`/`xmlrtl` |
| `bin\client\Win32\Jedivcs.exe`, `JvcsExternalDll.dll`, `JEDIVCSDiff.exe`, `jvcs.exe` | 2.5.0.2063 (ProductVersion 2.5.0.0) | Versão de `tools\versao.ini` |
| `bin\client\D11\...`, `bin\client\D12\...` | n/a | Verificação do código nas outras IDEs (`compilar.bat /delphi:11`); não distribuídos (ADR-001) |
| `bin\msbuild\<Dnn>\...` | n/a | Saída dos `.dproj` (IDE/MSBuild); não distribuída |

## 7. Histórico

Origem: `git log` do repositório `D:\Delphi\JediVCS\v2026` (autor Edmar Frazão, todos em 12/10/2026, fuso -03:00). Atualizado em 12/10/2026.

| Commit | Hora | Descrição |
|---|---|---|
| `3cb5f17` | 16:17 | Estrutura v2026 e fontes base do cliente JEDI VCS 2.5: layout original do JVCS; fontes do clone `Libaud/JediVCS` (`f6a777d`) sem alterar conteúdo, com `.dpr`/`compopt.inc` de `ConverterBackup` (pré-Lazarus); `Components\` intacto em `src\comp\_legacy`; `tools\compilar.bat`; `3rdparty` com `fvcscrypt.dll` e binários de referência |
| `62f9c8f` | 16:19 | Inventário de componentes (9 famílias revisadas, 201 units, 21 riscos de compatibilidade) e Plano de Port (F0-F6, critérios de pronto e checklist de testes) |
| `e449770` | 16:25 | SynEdit (pyscripter `84391a3`) e Virtual-TreeView V8.5 fixados no repositório; padronização das 3 IDEs |
| `2da6873` | 16:34 | Análise do expert da IDE 2.5.0.1030 (`Expert-IDE-Analise.md`) e registro de decisões |
| `f1e93e0` | 16:46 | `tools`: alvo `libs` do `compilar.bat` compila SynEdit/VTV fixados em `lib\` e copia `.res`/`.dfm`; libs automáticas no `all`; `.gitignore` com `/lib/` |

Ainda **não commitado** (12/10/2026, na hora desta consolidação):

- `bin/ideclient/` (saída do expert), `src/jvcsideexpert/` (fonte do expert, `LEIAME.md` e testes) e `tools/compilar-expert.bat`.
- A documentação consolidada (`doc/pt/README.md`, `Componentes.md`, `Versoes.md`).

Marcos fora do git, 12/10/2026: dependências instaladas via GetIt; GetIt SynEdit TurboPack e VTV 8.3 removidos da IDE com backup; SynEdit e VTV fixados instalados a partir de `lib\bpl\Win32`.
