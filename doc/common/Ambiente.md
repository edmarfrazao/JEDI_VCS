# Ambiente de desenvolvimento desta máquina

Como o ambiente do port do JEDI VCS 2.5 Beta 2026 foi montado, o que foi alterado na IDE e no registro, onde estão os backups e como reverter. Estado lido em **12/10/2026** (somente leitura). Versões: [Versoes.md](Versoes.md). Componentes: [Componentes.md](Componentes.md).

> **Regra de ouro: feche a IDE (`bds.exe`) antes de mexer no registro, no `EnvOptions.proj` ou nos BPL.** A IDE regrava essas configurações ao sair e desfaz qualquer alteração feita com ela aberta. Com os pacotes carregados, os BPL ficam travados e o build dos pacotes falha ao gravar.

## 1. Máquina e sistema

| Item | Valor |
|---|---|
| SO | Windows 11 Enterprise 10.0.26200, **ARM64** (o PATH do sistema inclui Parallels Tools: a máquina parece ser uma VM) |
| Delphi | 13.2 Florence **Professional**, BDS 37.0, build `37.0.60952.8797` ("Delphi 13 and C++Builder 13 Update 2"); roda por emulação x64; a Embarcadero não suporta oficialmente a IDE nesse SO |
| Raiz do Delphi (`$(BDS)`) | `C:\Program Files (x86)\Embarcadero\Studio\37.0` |
| Pasta comum (`$(BDSCOMMONDIR)`) | `C:\Users\Public\Documents\Embarcadero\Studio\37.0` (Bpl, Dcp, `GetItInstall.log`) |
| IDEs | `bin\bds.exe` (32 bits, **a que carrega o expert**) e `bin64\bds.exe` (64 bits, não carrega DLL de 32 bits) |
| Compiladores | `bin\DCC32.EXE` (usado pelo `compilar.bat`), `bin\dcc64.exe`, `bin64\*` |
| Plataforma Win64 | não instalada (`lib\win64\release` ausente); irrelevante para a fase 1 |
| Delphi 11 (BDS 22.0) | **instalado em 13/10/2026**: 11.3 (`28.0.48361.3236`) em `C:\Program Files (x86)\Embarcadero\Studio\22.0`; GetIt ainda sem JCL/JVCL/ICS/Abbrevia; SynEdit/VTV fixados compilados em `lib\D11`; nada registrado na IDE |
| Delphi 12 (BDS 23.0) | **não instalado** |
| Projeto | `D:\Delphi\JediVCS\v2026` (git local) |
| Clone de origem | `D:\Delphi\JediVCS\Fontes_JediVCS_2.5` |
| Cliente oficial instalado | `C:\Program Files (x86)\JEDI\JVCS` (2.5.0.1030) |
| Instalador oficial | `D:\Delphi\JediVCS\Instalador_2.50_Beta3_10.4Sydney\JVCSv2.50ClientSetupBeta3_Refresh_till_10_4Sydney.exe` |
| Claude Code CLI | 2.1.296 em `%USERPROFILE%\.local\bin\claude.exe` (está no PATH do usuário). A informação inicial era 2.1.168; o valor acima foi lido do executável |
| Skill Delphi | `D:\skills\delphi` (`SKILL.md`, `README.md`, `references\`, `scripts\build.bat`) |
| Servidor | **não portado**. O usuário vai montar um servidor 2.5 Beta 3 (Firebird) de teste com cópia do banco |

## 2. Ordem em que o ambiente foi montado (12/10/2026)

1. **Instalação via GetIt** (Delphi 13.2): JCL 2026.08, JVCL 2026.08, ICS for VCL 9.7, Abbrevia 2026.10, mais SynEdit TurboPack 2025.03 e Virtual Treeview 8.3. Os pacotes ficam em `CatalogRepository` e os BPL em `$(BDSCOMMONDIR)\Bpl` (Win32) e `...\Bpl\Win64`. O GetIt grava o Library Path no `EnvOptions.proj` e em `Library\Win32` (e `Win64`) do registro.
2. **Backup** antes de alterar a IDE (seção 5).
3. **Padronização das três IDEs** (decisão do usuário): SynEdit e Virtual-TreeView passam a vir das fontes fixadas em `src\comp`, iguais em Delphi 11, 12 e 13, e os do GetIt são removidos.
   - SynEdit: pyscripter/SynEdit commit `84391a3`, `Packages\Alexandria+\Delphi`.
   - Virtual-TreeView: V8.5, `Packages\RAD Studio 10.4+`.
4. **Compilação das bibliotecas fixadas** com `tools\compilar.bat libs Release Win32` (MSBuild; saídas dentro de `lib\`, pasta ignorada pelo git).
5. **Instalação na IDE** a partir de `lib\bpl\Win32`: `SynEditDD370.bpl` e `VirtualTreesD370.bpl`.
6. **Expert** `JvcsExpertBDS37.dll` compilado com `tools\compilar-expert.bat` em `bin\ideclient\Win32`. **Ainda não registrado** no `Experts` (ver seção 4) e em revisão.

## 3. O que está instalado e onde

`CatalogRepository` = `%USERPROFILE%\Documents\Embarcadero\Studio\37.0\CatalogRepository`. Conteúdo verificado:

| Pasta | Versão |
|---|---|
| `JEDICodeLibraryJCL-13` | 2026.08 |
| `JEDIVisualComponentLibraryJVCL-13` | 2026.08 |
| `ICS_VCL-13` | 9.7 |
| `Abbrevia-13` | 2026.10 |
| `VirtualTreeview_by_JamSoftware-13` | 8.3 (**resto**: o pacote foi removido da IDE, a pasta não) |

`SynEdit-13` não existe mais. Em `lib\`:

| Caminho | Conteúdo |
|---|---|
| `lib\bpl\Win32` | `SynEditDR370.bpl`, `SynEditDD370.bpl`, `VirtualTreesR370.bpl`, `VirtualTreesD370.bpl` |
| `lib\bpl\Win64` | `SynEditDR370.bpl`, `VirtualTreesR370.bpl` (runtime Win64; sem design-time) |
| `lib\dcp\<plat>`, `lib\res\<plat>\<cfg>` | DCP e `.res` gerados |
| `lib\synedit\<plat>\<cfg>`, `lib\virtualtreeview\<plat>\<cfg>` | DCUs (e `design\Win32` para design-time) |

## 4. Alterações feitas na IDE e no registro

Chave base: `HKCU\Software\Embarcadero\BDS\37.0`.

### 4.1 `Known Packages` (Win32)

Entradas adicionadas (apontam para as fontes fixadas):

| Valor (caminho do BPL) | Descrição registrada |
|---|---|
| `D:\Delphi\JediVCS\v2026\lib\bpl\Win32\VirtualTreesD370.bpl` | `Virtual Treeview V8.5 (v2026)` |
| `D:\Delphi\JediVCS\v2026\lib\bpl\Win32\SynEditDD370.bpl` | `SynEdit (pyscripter 84391a3 - v2026)` |

Continuam registrados (GetIt): JCL (experts `Jcl*Expert370.bpl`), JVCL (`Jv*Design370.bpl`), ICS (`IcsCommonNewDesign370.bpl`, `IcsVclNewDesign370.bpl`) e `AbbreviaVCLDDesign370.bpl`, todos em `C:\Users\Public\Documents\Embarcadero\Studio\37.0\Bpl`. Os pacotes do GetIt de SynEdit TurboPack e VTV 8.3 **não estão** mais na lista. Em `Known Packages x64` há só JCL, JVCL, ICS e Abbrevia (sem SynEdit nem VTV).

### 4.2 `Library\Win32`

- **Search Path**: além de `$(BDSLIB)\$(Platform)\release`, `$(BDS)\Imports`, `$(BDSCOMMONDIR)\Dcp`, `$(BDS)\include` etc., contém:
  - JCL: `...\JEDICodeLibraryJCL-13\2026.08\lib\d37\win32` e `...\source\include`;
  - JVCL: `...\JVCL-13\2026.08\lib\D37\win32`, `\common`, `\Resources`;
  - ICS: `$(BDSCatalogRepository)\ICS_VCL-13\9.7\source\` e `\source\Include`;
  - Abbrevia: `$(BDSCatalogRepository)\Abbrevia-13\2026.10\source\`;
  - **v2026** (adicionados pelo projeto): `D:\Delphi\JediVCS\v2026\lib\synedit\Win32\Release`, `D:\Delphi\JediVCS\v2026\lib\virtualtreeview\Win32\Release`, `D:\Delphi\JediVCS\v2026\lib\res\Win32\Release`, `D:\Delphi\JediVCS\v2026\lib\dcp\Win32`.
- **Browsing Path**: inclui, no final, as fontes JCL/JVCL do GetIt e as da v2026: `D:\Delphi\JediVCS\v2026\src\comp\synedit\Source`, `...\Source\Highlighters` e `D:\Delphi\JediVCS\v2026\src\comp\virtualtreeview\Source`.
- **Debug DCU Path**: inclui `...\lib\d37\win32\debug` da JCL e, da v2026, `lib\synedit\Win32\Debug` e `lib\virtualtreeview\Win32\Debug`.

### 4.3 `Environment Variables` (PATH da IDE)

Valor atual: `D:\Delphi\JediVCS\v2026\lib\bpl\Win32;$(PUBLIC)\Documents\Embarcadero\InterBase\redist\InterBase15\IDE_spoof;$(PATH)`.

O primeiro item foi acrescentado: os pacotes de design (`SynEditDD370`, `VirtualTreesD370`) dependem de `SynEditDR370.bpl` e `VirtualTreesR370.bpl`, que o carregador da IDE procura no PATH. Sem isso, a IDE reclama de pacote "não encontrado". As outras variáveis (`BDSCatalogRepositoryAllUsers`, `IBREDISTDIR`, `DEMOSDIR`) são da instalação.

### 4.4 `Experts`

Contém `Beyond Compare IDE Package` e, desde 12/10/2026 18:00, **`JVCSIDEClient`** = `D:\Delphi\JediVCS\v2026\bin\ideclient\Win32\JvcsExpertBDS37.dll` (backup da chave antes da gravação: `_backup_getit_20261012\Experts_antes_jvcs.reg`). Só na IDE de 32 bits; não registrar em `Experts x64`. Ver [src\jvcsideexpert\LEIAME.md](../../src/jvcsideexpert/LEIAME.md) para o comando de registro e a opção de teste isolado `bds.exe -rJVCSTeste`.

### 4.5 `EnvOptions.proj`

Arquivo: `%APPDATA%\Embarcadero\BDS\37.0\EnvOptions.proj` (última gravação 12/10/2026 16:52:59). É o Library Path que o **MSBuild** de linha de comando lê. Contém as entradas do GetIt por plataforma e **ainda cita** `$(BDSCatalogRepository)\VirtualTreeview_by_JamSoftware-13\8.3\source\` em várias plataformas. Como a pasta continua existindo, isso é inofensivo hoje, mas pode colocar duas versões do VTV no caminho. Está listado em [Status.md](Status.md) como pendência.

O `dcc32` de linha de comando **não lê** o Library Path da IDE nem o `EnvOptions.proj`; por isso o `tools\compilar.bat` monta os caminhos sozinho ([tools\LEIAME-compilar.md](../../tools/LEIAME-compilar.md)).

## 5. Backups e como reverter

### 5.1 Onde estão

Pasta: `C:\Users\Public\Documents\Embarcadero\Studio\37.0\_backup_getit_20261012`

| Item | Conteúdo |
|---|---|
| `BDS37_antes_instalacao.reg` | exportação do registro da IDE (`HKCU\Software\Embarcadero\BDS\37.0`) feita antes das alterações |
| `EnvOptions_antes_instalacao.proj` | cópia do `EnvOptions.proj` antes das alterações |
| `Bpl\` | `SynEditDD370.bpl`, `SynEditDR370.bpl`, `VirtualTreesD370.bpl`, `VirtualTreesR370.bpl` do GetIt e subpastas `Win64`, `Win64x` |
| `Dcp\` | `SynEditDD.dcp`, `SynEditDR.dcp`, `VirtualTreesD/R` (`.dcp`, `.bpi`, `.lib`) do GetIt e subpastas `Win64`, `Win64x` |

### 5.2 Reversão (somente com a IDE fechada)

Esta documentação **descreve** os passos; nada foi executado ao escrevê-la.

1. Feche o Delphi (confira no Gerenciador de Tarefas que não há `bds.exe`).
2. Registro:
   - `reg import` do `.reg` do backup **só acrescenta/sobrescreve** valores; não apaga o que foi criado depois. Por isso, antes ou depois, remova à mão os dois valores novos de `Known Packages` (`...\lib\bpl\Win32\SynEditDD370.bpl` e `...\VirtualTreesD370.bpl`), os caminhos `D:\Delphi\JediVCS\v2026\...` do `Search Path`, `Browsing Path` e `Debug DCU Path` de `Library\Win32` e o primeiro item do PATH em `Environment Variables`.
   - Atenção: se o `.reg` foi tirado antes da instalação das bibliotecas GetIt, importá-lo restaura também o estado anterior a elas; confira o conteúdo antes de importar.
3. `EnvOptions.proj`: copie `EnvOptions_antes_instalacao.proj` por cima de `%APPDATA%\Embarcadero\BDS\37.0\EnvOptions.proj`.
4. BPL/DCP do GetIt: copie de volta `Bpl\*.bpl` para `C:\Users\Public\Documents\Embarcadero\Studio\37.0\Bpl` (e `Win64`/`Win64x`) e `Dcp\*` para `...\Dcp` (e subpastas). Alternativa mais limpa: reinstalar pelo GetIt (SynEdit TurboPack 2025.03 e Virtual Treeview 8.3).
5. Não deixe duas versões de SynEdit nem de VTV ao mesmo tempo no search path.

### 5.3 Remover só o expert

```
reg delete "HKCU\Software\Embarcadero\BDS\37.0\Experts" /v JVCSIDEClient /f
```

(só faz sentido depois de registrado; com a IDE fechada).

## 6. Rotina de recompilação das bibliotecas fixadas

1. Feche a IDE.
2. `tools\compilar.bat libs Release Win32` (por último a `Release`: BPL e DCP não têm subpasta de configuração, vale a última execução).
3. Abra a IDE. Se o caminho dos BPL não mudou, não é preciso reinstalar os pacotes.

## 7. Cuidados

- Nunca versionar nem editar `lib\`, `dcu\`, logs e BPL: estão no `.gitignore`.
- Para Delphi 11/12: `tools\compilar.bat /delphi:11 ...` (ou `/delphi:12`, `/bds:22|23`; `JVCS_DELPHI` como padrão); as saídas vão para `lib\D11|D12`, `dcu\D11|D12` e `bin\client\D11|D12`. Pastas do GetIt e sufixos em `tools\versoes.ini`; `tools\compilar.bat /delphi:11 /info` mostra o que foi encontrado. Checklist: [manual, capítulo 10](../manual/10-Delphi-11-e-12.md).

## 8. Delphi 11 e 12: o que instalar

Mesmo conjunto do 13, cada um na sua IDE (DCU/BPL não servem entre versões):

| Item | Delphi 11 (22.0) | Delphi 12 (23.0) | Observação |
|---|---|---|---|
| Atualização | 11.3 | 12.3 | O expert carrega em todas as atualizações (só importa `rtl`/`vcl`/`xmlrtl`) |
| Plataforma | Win32 (Win64 opcional) | idem | |
| JCL / JVCL (GetIt) | DCUs em `lib\d28\win32` | `lib\d29\win32` | Se o GetIt oferecer versão antiga, usar o GitHub num commit equivalente ao 2026.08 ([Versões](Versoes.md)) |
| ICS for VCL (GetIt) | DCUs em `Lib\<cfg>\Win32\22.0` | `...\23.0` | 9.7 ou SVN `icsv9` |
| Abbrevia (GetIt) | `packages\11AndAbove\Delphi\Win32\<cfg>` | idem | |
| SynEdit / VTV | **fixados**: `compilar.bat /delphi:11 libs Release Win32` → `lib\D11\bpl\Win32\*280.bpl` | `lib\D12\...\*290.bpl` | Não usar os do GetIt |
| Expert | `JvcsExpertBDS22.dll` | `JvcsExpertBDS23.dll` | `compilar-expert.bat /delphi:NN`; registro só em `Experts` (não em `Experts x64`) |

Pastas do GetIt nessas versões: os nomes em `tools\versoes.ini` (`JEDICodeLibraryJCL-11` etc.) são prováveis;
o `compilar.bat` procura sozinho (`JEDICodeLibraryJCL*`, `JCL*`, `JEDIVisualComponentLibraryJVCL*`, `JVCL*`,
`ICS_VCL*`, `ICS*`, `Abbrevia*`, pasta ou subpasta de versão) e o `/info` mostra o resultado.

IDE de 64 bits (12.3 e 13): `bin64\bds.exe` usa chaves próprias `Experts x64`, `Known Packages x64`,
`Known IDE Packages x64` e o valor `App x64` em `HKCU\Software\Embarcadero\BDS\<v>` (conferido no 37.0 desta
máquina). DLL/BPL de 32 bits não carregam nela.
- Downloads e extrações só com autorização explícita do usuário, cada um numa pasta isolada.
- A instalação da JCL por `install.bat` em Windows 11 ARM64 (Delphi emulado) não foi validada; o GetIt foi o caminho usado.

## Pendência: EnvOptions.proj regravado pela IDE

Ao abrir/fechar, a IDE regrava `%APPDATA%\Embarcadero\BDS\37.0\EnvOptions.proj` com o Library Path antigo (com o VTV 8.3 do GetIt e sem os caminhos da v2026), embora o registro `Library\Win32` esteja correto. Isso afeta só builds via MSBuild fora da IDE (`tools\compilar.bat` usa caminhos explícitos e não é afetado). A investigar com a IDE fechada; provável origem: o GetIt ainda considera o VTV 8.3 instalado (pasta `CatalogRepository\VirtualTreeview_by_JamSoftware-13\8.3` e chave `CatalogRepository\Packages`). A DelphiLSP.exe falha (AV em dcc32370.dll) também antes do expert existir (16:08) — não é causada pelo expert.
