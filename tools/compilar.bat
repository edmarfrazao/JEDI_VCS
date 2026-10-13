@echo off
rem ==========================================================================
rem  compilar.bat - Compila os projetos do JEDI VCS v2026
rem
rem  Uso:   compilar.bat [opcoes] [exe, dll, diff, console, libs ou all] [Debug ou Release] [Win32 ou Win64]
rem         Padrao: all Debug Win32, Delphi 13
rem
rem  Opcoes (em qualquer posicao):
rem    /delphi:NN  versao do Delphi: 11, 12 ou 13 (padrao 13 ou JVCS_DELPHI)
rem    /bds:NN     o mesmo pelo numero do BDS: 22, 23 ou 37 (ou 22.0, 23.0, 37.0)
rem    /info       so mostra a versao, os caminhos resolvidos e se existem (nao compila)
rem    /msbuild    compila os .dproj com MSBuild em vez do dcc32/dcc64 (saida em
rem                bin\msbuild\<Dnn>\<plat>\<cfg>; nao toca em bin\client)
rem  As versoes, os sufixos e as pastas do GetIt ficam em tools\versoes.ini
rem  (lido por tools\versao-delphi.bat).
rem
rem  Modo normal (padrao): chama dcc32 (Win32) ou dcc64 (Win64) direto no .dpr,
rem  com os defines e caminhos da tabela abaixo (portados dos .dof do Delphi 7).
rem  Os .dproj ao lado dos .dpr (abrir na IDE) NAO sao usados, so com /msbuild.
rem
rem  Saidas por versao (DCU/DCP de versoes diferentes sao incompativeis):
rem    Delphi 13 (referencia, tag vazia no versoes.ini): como sempre -
rem      bin\client\<plat>, dcu\<plat>\<cfg>\<alvo>, lib\<lib>\<plat>\<cfg>
rem    Delphi 11/12 (tag D11/D12): bin\client\<tag>\<plat>, dcu\<tag>\<plat>\<cfg>\<alvo>,
rem      lib\<tag>\<lib>\<plat>\<cfg>. O binario distribuido (EXE/DLL/Diff/console)
rem      continua sendo o do Delphi 13 (ADR-001); os de 11/12 sao so verificacao.
rem
rem  Alvo "libs": compila (MSBuild) os pacotes do SynEdit e do VirtualTreeView
rem  FIXADOS no repositorio (src\comp\synedit e src\comp\virtualtreeview):
rem    - runtime (SynEditDR, VirtualTreesR): Win32 ou Win64, Debug ou Release
rem    - design-time (SynEditDD, VirtualTreesD): so Win32 (para instalar na IDE)
rem    - DCUs em lib[\<tag>]\<lib>\<plataforma>\<config>; design em ...\<lib>\design\...
rem    - BPL em lib[\<tag>]\bpl\<plataforma> e DCP em lib[\<tag>]\dcp\<plataforma>
rem      (JVCS_BPLDIR / JVCS_DCPDIR mudam estas duas pastas)
rem  "all" e os projetos isolados chamam "libs" sozinhos (so os pacotes runtime)
rem  quando faltam os DCUs da config/plataforma pedida; "libs" sempre recompila.
rem
rem  Variaveis de ambiente opcionais:
rem    JVCS_DELPHI     = versao padrao (11, 12, 13) quando /delphi e /bds nao sao usados.
rem    BDSROOT         = pasta raiz do RAD Studio (sobrescreve o caminho padrao
rem                      ProgramFiles(x86)\Embarcadero\Studio\BDSVER). Se a pasta final
rem                      for numerica (ex.: ...\Studio\22.0) ela define a versao e
rem                      precisa bater com /delphi ou /bds.
rem    JVCS_CATALOG    = pasta CatalogRepository do GetIt (JCL, JVCL, ICS, Abbrevia;
rem                      padrao: chave catalog do versoes.ini ou
rem                      USERPROFILE\Documents\Embarcadero\Studio\BDSVER\CatalogRepository)
rem    JCL_PATH, JVCL_PATH, ICS_PATH, SYNEDIT_PATH, VTV_PATH, ABBREVIA_PATH = DCUs de cada
rem                      biblioteca (e *_INC = fontes/includes); substituem o padrao.
rem                      SYNEDIT_PATH/VTV_PATH definidos desligam a compilacao automatica.
rem    JVCS_BPLDIR, JVCS_DCPDIR = pastas de saida dos BPL e dos DCP/BPI/LIB (alvo libs);
rem                      padrao lib[\<tag>]\bpl\<plat> e lib[\<tag>]\dcp\<plat>.
rem    JVCS_EXTRA_DEFS = defines extras (separados por ponto e virgula) para todos os projetos
rem    JVCS_EXTRA_PATH = caminhos ABSOLUTOS (separados por ponto e virgula) de
rem                      de outras bibliotecas (as acima ja entram por padrao).
rem                      Acrescentados a -U, -I e -R (so no modo dcc).
rem    JVCS_CBUILDER   = DCC_CBuilderOutput dos pacotes (padrao None = sem .hpp/.obj/.bpi/.lib)
rem
rem  Gera um log por projeto: tools\logs\compilar_[<tag>_]PROJ_PLATAFORMA_CONFIG.log
rem  (pacotes: tools\logs\compilar_[<tag>_]lib_PACOTE_PLATAFORMA_CONFIG.log)
rem  Tambem grava lib\paths\JediVCS2026-<BDSVER>.props com as pastas de JCL, JVCL,
rem  ICS e Abbrevia encontradas (lido pelos .dproj via tools\msbuild\JediVCS2026.props).
rem  Codigo de saida: 0 = tudo OK; diferente de zero = alguma falha (ou versao
rem  do Delphi nao instalada).
rem ==========================================================================
setlocal EnableExtensions DisableDelayedExpansion

rem ---- Configuracao geral (ajuste aqui) -------------------------------------
set "BLD_CODEPAGE=1252"
set "BLD_MAXERR=3"
set "BLD_ALIASES=WinTypes=Windows;WinProcs=Windows;DbiTypes=BDE;DbiProcs=BDE;DbiErrs=BDE"
set "BLD_NS=Winapi;System.Win;Data.Win;Datasnap.Win;Web.Win;Soap.Win;Xml.Win;Bde;System;Data;Datasnap;Web;Soap;Xml;Vcl;Vcl.Imaging;Vcl.Touch;Vcl.Samples;Vcl.Shell"

rem ---- Caminhos de busca comuns (relativos a pasta do .dpr) -----------------
rem  Usados em -U, -I e -R. NAO incluir src\comp\_legacy (so referencia).
rem  (os .dproj repetem esta lista em tools\msbuild\JediVCS2026.props)
set "BLD_BASEPATH=..\common;..\common\client;..\comp\midware;..\comp\textdiff;..\comp\mdmailslot;..\comp\crc;..\comp\mwtools"

rem ---- Pastas do projeto e dos logs -----------------------------------------
for %%I in ("%~dp0..") do set "BLD_ROOT=%%~fI"
for %%I in ("%~dp0.") do set "BLD_TOOLS=%%~fI"
set "BLD_LOGDIR=%BLD_TOOLS%\logs"

rem ---- Bibliotecas de terceiros instaladas via GetIt (CatalogRepository) ----
rem  JCL, JVCL, ICS e Abbrevia. (SynEdit e VirtualTreeView NAO vem mais do GetIt:
rem  usam as fontes fixadas no repositorio, ver "Bibliotecas fixadas" abaixo.)
rem  O dcc32/dcc64 de linha de comando NAO le o Library Path da IDE, entao as
rem  pastas abaixo entram por padrao no search path:
rem    -U (units)  : pasta de DCUs da config/plataforma de cada biblioteca
rem    -I e -R     : pastas de fontes (.inc, .res, .dfm)
rem  Os .pas das bibliotecas NAO entram em -U de proposito: como o script usa -B,
rem  eles seriam recompilados (o ICS, por exemplo, nao compila com -J+ global).
rem  A pasta raiz de cada biblioteca vem do versoes.ini (chaves jcl, jvcl, ics,
rem  abbrevia) ou da procura automatica no CatalogRepository (:find_cat), que
rem  confere o arquivo-marcador abaixo. Padroes de nome usados na procura (prefixos, + "*"):
set "CAT_jcl_PAT=JEDICodeLibraryJCL JCL"
set "CAT_jcl_MARK=source\include\jedi\jedi.inc"
set "CAT_jvcl_PAT=JEDIVisualComponentLibraryJVCL JVCL"
set "CAT_jvcl_MARK=common\jvcl.inc"
set "CAT_ics_PAT=ICS_VCL ICS"
set "CAT_ics_MARK=Source\Include\OverbyteIcsDefs.inc"
set "CAT_abbrevia_PAT=Abbrevia"
set "CAT_abbrevia_MARK=source\AbBase.pas"
rem  Cada biblioteca tem uma variavel de DCUs (JCL_PATH, JVCL_PATH, ICS_PATH,
rem  SYNEDIT_PATH, VTV_PATH, ABBREVIA_PATH) e uma de fontes/includes (JCL_INC,
rem  JVCL_INC, ICS_INC, SYNEDIT_INC, VTV_INC, ABBREVIA_INC). Se definidas no
rem  ambiente, substituem o padrao.

rem ---- Bibliotecas fixadas no repositorio (alvo "libs") ----------------------
rem  chave = nome da pasta em lib\ (DCUs em lib\chave\plataforma\config)
rem  LIB_chave_DIR   pasta dos .dproj, relativa a raiz do projeto
rem  LIB_chave_RUN   pacote runtime  (Win32 e Win64)
rem  LIB_chave_DES   pacote design-time (so Win32, so no alvo libs)
rem  LIB_chave_MARK  DCU que indica "ja compilada" (decide a compilacao automatica)
rem  LIB_chave_SRC   pasta de fontes/includes (relativa a raiz) - entra em *_INC
rem  As mesmas fontes e .dproj servem para Delphi 11, 12 e 13.
set "ALL_LIBS=synedit virtualtreeview"

set "LIB_synedit_DIR=src\comp\synedit\Packages\Alexandria+\Delphi"
set "LIB_synedit_RUN=SynEditDR"
set "LIB_synedit_DES=SynEditDD"
set "LIB_synedit_MARK=SynEdit.dcu"
set "LIB_synedit_SRC=src\comp\synedit\Source"

set "LIB_virtualtreeview_DIR=src\comp\virtualtreeview\Packages\RAD Studio 10.4+"
set "LIB_virtualtreeview_RUN=VirtualTreesR"
set "LIB_virtualtreeview_DES=VirtualTreesD"
set "LIB_virtualtreeview_MARK=VirtualTrees.dcu"
set "LIB_virtualtreeview_SRC=src\comp\virtualtreeview\Source"

rem  Saida dos pacotes em C++Builder (.hpp/.obj/.bpi/.lib): desligada por padrao.
if not defined JVCS_CBUILDER set "JVCS_CBUILDER=None"

rem ---- Defines comuns a TODOS os projetos (alem dos da tabela abaixo) -------
rem  OVERBYTEV6_UP: o codigo antigo usa WSocket/Ping/Icmp (ramo ELSE); com este
rem  define passa a usar OverbyteIcsWSocket/OverbyteIcsPing/OverbyteIcsIcmp (ICS 9).
set "BLD_COMMONDEFS=OVERBYTEV6_UP"

rem ---- Outros caminhos (opcional) ---------------------------------------------
rem  Defina JVCS_EXTRA_PATH no ambiente (ou descomente/ajuste a linha abaixo).
rem  Use caminhos ABSOLUTOS (o compilador roda na pasta do .dpr). Entra em -U, -I e -R.
rem set "JVCS_EXTRA_PATH=D:\Delphi\JediVCS\v2026\3rdparty\outra_lib\Source"

rem ---- Tabela de projetos (manutencao) --------------------------------------
rem  chave = nome usado no parametro 1 e nos logs
rem  PRJ_chave_DIR      pasta do .dpr, relativa a raiz do projeto (pai de tools)
rem  PRJ_chave_NAME     nome do .dpr / .dproj (sem extensao)
rem  PRJ_chave_DEFINES  defines do .dof (DEBUG ou RELEASE e acrescentado pela config)
rem  PRJ_chave_PATH     caminhos extras, relativos a pasta do .dpr
rem  (os .dproj repetem estes defines/caminhos; mantenha os dois iguais)
set "ALL_PROJECTS=exe dll diff console"

set "PRJ_exe_DIR=src\jedivcs"
set "PRJ_exe_NAME=Jedivcs"
rem  exe (F4): sem REPORTDLL/LANGUAGE/plugins/notificacao (Decisoes.md, "so o basico").
rem  BRANCHING fica ligado (protocolo igual ao 2.5.0.1030 com servidor 2.50) e
rem  JVCS_NOBRANCHUI esconde o menu Branch e fixa a GUI em HEAD.
set "PRJ_exe_DEFINES=USECLIENTDISPATCHER;BRANCHING;JVCS_NOBRANCHUI;UNISYNEDIT"
set "PRJ_exe_PATH="

rem  dll (F5): mesmas fontes e defines do exe + IDEDLL;EXT_IDE_INTF (ABI externa
rem  do expert). Sem LANGUAGE/REPORTDLL. PRJ_chave_OUT renomeia a saida: a DLL
rem  do expert se chama JvcsExternalDll.dll (nome que o expert procura).
set "PRJ_dll_DIR=src\jedivcs"
set "PRJ_dll_NAME=JediVCSDLL"
set "PRJ_dll_DEFINES=IDEDLL;EXT_IDE_INTF;USECLIENTDISPATCHER;BRANCHING;JVCS_NOBRANCHUI;UNISYNEDIT"
set "PRJ_dll_PATH="
set "PRJ_dll_OUT=JvcsExternalDll"

rem  diff (F3): sem LANGUAGE (dxgettext ainda nao portado; a JVCL nao entra no Diff)
rem  e sem ..\jedivcs (o Diff nao depende mais das units do EXE)
set "PRJ_diff_DIR=src\jedivcsdiff"
set "PRJ_diff_NAME=JEDIVCSDiff"
set "PRJ_diff_DEFINES=DelphiPersonalEdition"
set "PRJ_diff_PATH="

set "PRJ_console_DIR=src\jvcs"
set "PRJ_console_NAME=jvcs"
set "PRJ_console_DEFINES=DelphiPersonalEdition;JVCSCONSOLECLIENT;BRANCHING"
set "PRJ_console_PATH=..\jedivcs"

rem ---- Parametros -----------------------------------------------------------
rem  Opcoes (/delphi:, /bds:, /info, /msbuild) em qualquer posicao; o resto e
rem  posicional: projeto, config, plataforma.
set "BLD_VERARG="
set "BLD_INFO=0"
set "BLD_MODE=dcc"
set "BLD_WHAT="
set "BLD_CFG="
set "BLD_PLAT="
set "BLD_NPOS=0"
:args
if "%~1"=="" goto :args_done
set "BLD_A=%~1"
if "%BLD_A%"=="/?" goto :usage
if /i "%BLD_A%"=="-h" goto :usage
if /i "%BLD_A%"=="--help" goto :usage
if /i "%BLD_A:~0,8%"=="/delphi:" (
    set "BLD_VERARG=%BLD_A:~8%"
) else if /i "%BLD_A:~0,5%"=="/bds:" (
    set "BLD_VERARG=%BLD_A:~5%"
) else if /i "%BLD_A%"=="/info" (
    set "BLD_INFO=1"
) else if /i "%BLD_A%"=="/msbuild" (
    set "BLD_MODE=msbuild"
) else if "%BLD_A:~0,1%"=="/" (
    goto :bad_opt
) else (
    call :posarg
)
shift
goto :args
:args_done

if not defined BLD_WHAT set "BLD_WHAT=all"
if not defined BLD_CFG set "BLD_CFG=Debug"
if not defined BLD_PLAT set "BLD_PLAT=Win32"

rem  BLD_LIBMODE: force = alvo "libs" (sempre recompila); auto = so se faltarem DCUs
set "BLD_TARGETS="
set "BLD_LIBMODE="
if /i "%BLD_WHAT%"=="libs" (
    set "BLD_LIBMODE=force"
) else if /i "%BLD_WHAT%"=="all" (
    set "BLD_TARGETS=%ALL_PROJECTS%"
    set "BLD_LIBMODE=auto"
) else (
    for %%P in (%ALL_PROJECTS%) do if /i "%%P"=="%BLD_WHAT%" set "BLD_TARGETS=%%P" & set "BLD_LIBMODE=auto"
)
if not defined BLD_LIBMODE goto :bad_what

if /i "%BLD_CFG%"=="Debug" (
    set "BLD_CFG=Debug"
) else if /i "%BLD_CFG%"=="Release" (
    set "BLD_CFG=Release"
) else (
    goto :bad_cfg
)

if /i "%BLD_PLAT%"=="Win32" (
    set "BLD_PLAT=Win32"
    set "BLD_LIBPLAT=win32"
    set "BLD_DCCEXE=DCC32.EXE"
) else if /i "%BLD_PLAT%"=="Win64" (
    set "BLD_PLAT=Win64"
    set "BLD_LIBPLAT=win64"
    set "BLD_DCCEXE=dcc64.exe"
) else (
    goto :bad_plat
)

rem ---- Versao do Delphi (tools\versoes.ini) ----------------------------------
call "%BLD_TOOLS%\versao-delphi.bat" "%BLD_VERARG%"
if errorlevel 1 goto :bad_ver
set "BLD_BDSDIR=%VD_BDSDIR%"
set "BLD_TAG=%VD_TAG%"
rem  BLD_TAGP = "\<tag>" (vazio na versao de referencia); BLD_TAGL = "<tag>_" (logs)
set "BLD_TAGP="
set "BLD_TAGL="
if defined BLD_TAG set "BLD_TAGP=\%BLD_TAG%"
if defined BLD_TAG set "BLD_TAGL=%BLD_TAG%_"
set "BLD_MSBTAG=%BLD_TAG%"
if not defined BLD_MSBTAG set "BLD_MSBTAG=D%VD_DELPHI%"

rem ---- Opcoes do compilador conforme a configuracao ------------------------
rem  Base: Jedivcs.dof (C+ D+ L+ Q+ R+ Y+ O-). Debug usa os DCUs de debug da RTL/VCL.
rem  Obs.: NAO usar -$J+ global (breaks ICS: WEAKPACKAGEUNIT); o compopt.inc do JVCS ja liga J+ por unit.
if /i "%BLD_CFG%"=="Debug" (
    set "BLD_DEFCFG=DEBUG"
    set "BLD_LIBCFG=debug"
    set "BLD_SW=-$O- -$Q+ -$R+ -$C+ -$D+ -$L+ -$Y+ -V -GD"
) else (
    set "BLD_DEFCFG=RELEASE"
    set "BLD_LIBCFG=release"
    set "BLD_SW=-$O+ -$Q- -$R- -$C- -$D- -$L- -$Y-"
)
set "BLD_SW=%BLD_SW% -W+ -H-"

rem ---- Bibliotecas de terceiros - pastas raiz (GetIt / versoes.ini) ----------
rem  CatalogRepository: JVCS_CATALOG > chave catalog do .ini > padrao do usuario.
rem  Tambem procura na pasta comum (Public\Documents\...\CatalogRepository).
if not defined JVCS_CATALOG if defined VD_CATALOG set "JVCS_CATALOG=%VD_CATALOG%"
if not defined JVCS_CATALOG set "JVCS_CATALOG=%USERPROFILE%\Documents\Embarcadero\Studio\%BDSVER%\CatalogRepository"
set "JVCS_CATALOG=%JVCS_CATALOG:"=%"
if "%JVCS_CATALOG:~-1%"=="\" set "JVCS_CATALOG=%JVCS_CATALOG:~0,-1%"
set "BLD_CATALL=%PUBLIC%\Documents\Embarcadero\Studio\%BDSVER%\CatalogRepository"
call :find_cat jcl "%VD_JCL%"
call :find_cat jvcl "%VD_JVCL%"
call :find_cat ics "%VD_ICS%"
call :find_cat abbrevia "%VD_ABBREVIA%"
set "BLD_JCLDIR=%CAT_jcl_DIR%"
set "BLD_JVCLDIR=%CAT_jvcl_DIR%"
set "BLD_ICSDIR=%CAT_ics_DIR%"
set "BLD_ABBDIR=%CAT_abbrevia_DIR%"

rem  SynEdit / VirtualTreeView fixados: DCUs em lib[\<tag>]\<lib>\<plat>\<cfg>, fontes em src\comp.
rem  BLD_USER_<lib> marca quem foi redefinido no ambiente (nao compila automatico).
set "BLD_LIBROOT=%BLD_ROOT%\lib%BLD_TAGP%"
set "BLD_USER_synedit="
if defined SYNEDIT_PATH set "BLD_USER_synedit=1"
set "BLD_USER_virtualtreeview="
if defined VTV_PATH set "BLD_USER_virtualtreeview=1"
for %%L in (%ALL_LIBS%) do set "BLD_DCU_%%L=%BLD_LIBROOT%\%%L\%BLD_PLAT%\%BLD_CFG%"

rem  Pastas que nao foram encontradas ficam com o nome "<nao encontrada>" no
rem  caminho: o compilador avisa (H2675) e :chk_libdirs mostra [AVISO].
if not defined BLD_JCLDIR set "BLD_JCLDIR=%JVCS_CATALOG%\JCL-nao-encontrada"
if not defined BLD_JVCLDIR set "BLD_JVCLDIR=%JVCS_CATALOG%\JVCL-nao-encontrada"
if not defined BLD_ICSDIR set "BLD_ICSDIR=%JVCS_CATALOG%\ICS-nao-encontrado"
if not defined BLD_ABBDIR set "BLD_ABBDIR=%JVCS_CATALOG%\Abbrevia-nao-encontrada"
if not defined JCL_PATH set "JCL_PATH=%BLD_JCLDIR%\lib\%VD_JCLLIB%\%BLD_LIBPLAT%"
if not defined JCL_INC set "JCL_INC=%BLD_JCLDIR%\source\include;%BLD_JCLDIR%\source\include\jedi"
if not defined JVCL_PATH set "JVCL_PATH=%BLD_JVCLDIR%\lib\%VD_JCLLIB%\%BLD_LIBPLAT%"
if not defined JVCL_INC set "JVCL_INC=%BLD_JVCLDIR%\common;%BLD_JVCLDIR%\Resources"
if not defined ICS_PATH set "ICS_PATH=%BLD_ICSDIR%\Lib\%BLD_CFG%\%BLD_PLAT%\%BDSVER%"
if not defined ICS_INC set "ICS_INC=%BLD_ICSDIR%\Source\Include;%BLD_ICSDIR%\Source"
if not defined SYNEDIT_PATH set "SYNEDIT_PATH=%BLD_DCU_synedit%"
if not defined SYNEDIT_INC set "SYNEDIT_INC=%BLD_ROOT%\%LIB_synedit_SRC%;%BLD_ROOT%\%LIB_synedit_SRC%\Highlighters"
if not defined VTV_PATH set "VTV_PATH=%BLD_DCU_virtualtreeview%"
if not defined VTV_INC set "VTV_INC=%BLD_ROOT%\%LIB_virtualtreeview_SRC%"
if not defined ABBREVIA_PATH set "ABBREVIA_PATH=%BLD_ABBDIR%\packages\11AndAbove\Delphi\%BLD_PLAT%\%BLD_CFG%"
if not defined ABBREVIA_INC set "ABBREVIA_INC=%BLD_ABBDIR%\source"
set "BLD_LIB_U=%JCL_PATH%;%JVCL_PATH%;%ICS_PATH%;%SYNEDIT_PATH%;%VTV_PATH%;%ABBREVIA_PATH%"
set "BLD_LIB_I=%JCL_INC%;%JVCL_INC%;%ICS_INC%;%SYNEDIT_INC%;%VTV_INC%;%ABBREVIA_INC%"

rem ---- Saidas dos pacotes (alvo libs) ---------------------------------------
rem  Padrao: tudo dentro da v2026 (lib[\<tag>]\bpl\<plat>, lib[\<tag>]\dcp\<plat>).
rem  JVCS_BPLDIR e JVCS_DCPDIR (ambiente) mudam essas duas pastas.
set "BLD_BPLDIR=%BLD_LIBROOT%\bpl\%BLD_PLAT%"
set "BLD_DCPDIR=%BLD_LIBROOT%\dcp\%BLD_PLAT%"
if defined JVCS_BPLDIR set "BLD_BPLDIR=%JVCS_BPLDIR:"=%"
if defined JVCS_DCPDIR set "BLD_DCPDIR=%JVCS_DCPDIR:"=%"
if "%BLD_BPLDIR:~-1%"=="\" set "BLD_BPLDIR=%BLD_BPLDIR:~0,-1%"
if "%BLD_DCPDIR:~-1%"=="\" set "BLD_DCPDIR=%BLD_DCPDIR:~0,-1%"
set "BLD_HPPDIR=%BLD_LIBROOT%\hpp\%BLD_PLAT%\%BLD_CFG%"
rem  .res gerados pelo MSBuild (versao/icone dos pacotes): fora de src\.
set "BLD_RESDIR=%BLD_LIBROOT%\res\%BLD_PLAT%\%BLD_CFG%"
rem  Pacotes de design-time: so no alvo libs e so em Win32 (a IDE e 32 bits).
set "BLD_DODESIGN=0"
if "%BLD_LIBMODE%"=="force" if /i "%BLD_PLAT%"=="Win32" set "BLD_DODESIGN=1"
rem  Saida dos projetos (EXE/DLL) e dos DCUs, relativas a pasta do .dpr
set "BLD_EXEOUT=..\..\bin\client%BLD_TAGP%\%BLD_PLAT%"
set "BLD_OUTDIR=%BLD_ROOT%\bin\client%BLD_TAGP%\%BLD_PLAT%"
set "BLD_DCUBASE=..\..\dcu%BLD_TAGP%\%BLD_PLAT%\%BLD_CFG%"
set "BLD_MSBOUT=%BLD_ROOT%\bin\msbuild\%BLD_MSBTAG%\%BLD_PLAT%\%BLD_CFG%"

if "%BLD_INFO%"=="1" goto :show_info

rem ---- Ambiente do RAD Studio (rsvars.bat) ----------------------------------
if not "%VD_INSTALLED%"=="1" goto :not_installed
set "BLD_RSVARS=%BLD_BDSDIR%\bin\rsvars.bat"
call "%BLD_RSVARS%"
set "BLD_DCC=%BLD_BDSDIR%\bin\%BLD_DCCEXE%"
if not exist "%BLD_DCC%" goto :no_dcc
set "BLD_LIBDIR=%BLD_BDSDIR%\lib\%BLD_LIBPLAT%\%BLD_LIBCFG%"
if not exist "%BLD_LIBDIR%" goto :no_lib
rem  O -R tambem precisa da pasta release da RTL/VCL (ex.: controls.res so existe la).
set "BLD_RELDIR=%BLD_BDSDIR%\lib\%BLD_LIBPLAT%\release"

if not exist "%BLD_LOGDIR%" mkdir "%BLD_LOGDIR%"
call :norm_extra
call :write_props

rem ---- Quais bibliotecas fixadas compilar -----------------------------------
set "BLD_LIBLIST="
if "%BLD_LIBMODE%"=="force" set "BLD_LIBLIST=%ALL_LIBS%"
if "%BLD_LIBMODE%"=="auto" for %%L in (%ALL_LIBS%) do call :lib_needed %%L

set "BLD_SHOWT=%BLD_TARGETS%"
if "%BLD_LIBMODE%"=="force" set "BLD_SHOWT=libs"

echo Raiz    : %BLD_ROOT%
echo Delphi  : %VD_NAME% - %BLD_BDSDIR% ^(BDSVER %BDSVER%^)
echo Config  : %BLD_CFG% %BLD_PLAT% ^(compilador: %BLD_DCCEXE%, modo %BLD_MODE%^)
echo Alvos   : %BLD_SHOWT%
if defined BLD_TARGETS echo Catalog : %JVCS_CATALOG%
if defined BLD_TARGETS echo Libs    : JCL, JVCL, ICS, Abbrevia ^(GetIt^); SynEdit, VTV ^(repositorio, DCUs de %BLD_CFG% %BLD_PLAT%^)
if defined BLD_TARGETS if "%BLD_MODE%"=="dcc" echo Saida   : %BLD_OUTDIR%
if defined BLD_TARGETS if "%BLD_MODE%"=="msbuild" echo Saida   : %BLD_MSBOUT% ^(.dproj^)
if defined BLD_LIBLIST echo Libs a compilar ^(%BLD_LIBMODE%^):%BLD_LIBLIST%
if defined BLD_LIBLIST echo Pacotes : BPL em %BLD_BPLDIR% - DCP em %BLD_DCPDIR%
if defined BLD_EXTRA echo Extra   : %BLD_EXTRA%

rem ---- Compilacao -----------------------------------------------------------
set "BLD_RESULT=0"
set "BLD_NOK=0"
set "BLD_NFAIL=0"
set "BLD_PKGDONE="
if defined BLD_LIBLIST for %%L in (%BLD_LIBLIST%) do call :build_lib %%L
if "%BLD_LIBMODE%"=="force" if "%BLD_DODESIGN%"=="0" echo [INFO] Pacotes de design-time ^(SynEditDD, VirtualTreesD^) so sao compilados em Win32 - ignorados.

if defined BLD_TARGETS call :chk_libdirs
for %%K in (%BLD_TARGETS%) do call :build_one %%K

echo.
echo ==== Resumo: %VD_NAME% - %BLD_CFG% %BLD_PLAT% ====
for %%K in (%BLD_PKGDONE%) do call :sumpkg %%K
for %%K in (%BLD_TARGETS%) do call :sumline %%K
echo.
if "%BLD_RESULT%"=="0" echo Compilacao concluida sem erros - %BLD_NOK% alvo^(s^) OK.
if not "%BLD_RESULT%"=="0" echo Compilacao terminou com falhas: %BLD_NOK% OK, %BLD_NFAIL% FALHOU - codigo %BLD_RESULT%.
if not "%BLD_RESULT%"=="0" echo Logs em: %BLD_LOGDIR%
endlocal & exit /b %BLD_RESULT%

rem ==========================================================================
rem  :posarg  - parametro posicional (projeto, config, plataforma)
rem ==========================================================================
:posarg
set /a "BLD_NPOS+=1"
if %BLD_NPOS% equ 1 set "BLD_WHAT=%BLD_A%"
if %BLD_NPOS% equ 2 set "BLD_CFG=%BLD_A%"
if %BLD_NPOS% equ 3 set "BLD_PLAT=%BLD_A%"
if %BLD_NPOS% gtr 3 echo [AVISO] parametro ignorado: %BLD_A%
goto :eof

rem ==========================================================================
rem  :build_one CHAVE  - compila um projeto da tabela (BLD_CFG / BLD_PLAT)
rem ==========================================================================
:build_one
set "BLD_K=%~1"
call set "BLD_DIR=%%PRJ_%BLD_K%_DIR%%"
call set "BLD_NAME=%%PRJ_%BLD_K%_NAME%%"
call set "BLD_DEFS=%%PRJ_%BLD_K%_DEFINES%%"
call set "BLD_XPATH=%%PRJ_%BLD_K%_PATH%%"
set "BLD_PROJDIR=%BLD_ROOT%\%BLD_DIR%"
set "BLD_LOG=%BLD_LOGDIR%\compilar_%BLD_TAGL%%BLD_K%_%BLD_PLAT%_%BLD_CFG%.log"
if "%BLD_MODE%"=="msbuild" set "BLD_LOG=%BLD_LOGDIR%\compilar_msbuild_%BLD_MSBTAG%_%BLD_K%_%BLD_PLAT%_%BLD_CFG%.log"

set "BLD_ALLDEFS=%BLD_DEFCFG%"
if defined BLD_DEFS set "BLD_ALLDEFS=%BLD_ALLDEFS%;%BLD_DEFS%"
if defined BLD_COMMONDEFS set "BLD_ALLDEFS=%BLD_ALLDEFS%;%BLD_COMMONDEFS%"
if defined JVCS_EXTRA_DEFS set "BLD_ALLDEFS=%BLD_ALLDEFS%;%JVCS_EXTRA_DEFS%"
set "BLD_PPATH=%BLD_BASEPATH%"
if defined BLD_XPATH set "BLD_PPATH=%BLD_PPATH%;%BLD_XPATH%"
set "BLD_UPATH=%BLD_LIBDIR%;%BLD_PPATH%;%BLD_LIB_U%"
set "BLD_IPATH=%BLD_PPATH%;%BLD_LIB_I%"
if defined BLD_EXTRA set "BLD_UPATH=%BLD_UPATH%;%BLD_EXTRA%"
if defined BLD_EXTRA set "BLD_IPATH=%BLD_IPATH%;%BLD_EXTRA%"
set "BLD_RPATH=%BLD_RELDIR%;%BLD_IPATH%"
rem  DCUs separados por projeto: units compartilhadas mudam com os defines de cada alvo
set "BLD_DCUOUT=%BLD_DCUBASE%\%BLD_K%"

echo.
echo ==== %BLD_K% : %BLD_NAME% - %BLD_PLAT% %BLD_CFG% ====
if not exist "%BLD_PROJDIR%\%BLD_NAME%.dpr" goto :bo_noproj
if "%BLD_MODE%"=="msbuild" if not exist "%BLD_PROJDIR%\%BLD_NAME%.dproj" goto :bo_nodproj

call :now BLD_T0
set "BLD_RC=0"
pushd "%BLD_PROJDIR%"
if "%BLD_MODE%"=="msbuild" (call :run_msbuild) else (call :run_dcc)
popd
call :elapsed BLD_T0 BLD_SECS

if not "%BLD_RC%"=="0" goto :bo_fail
set /a "BLD_NOK+=1"
set "BLD_RES_%BLD_K%=OK"
set "BLD_SEC_%BLD_K%=%BLD_SECS%"
echo [OK] %BLD_K% %BLD_PLAT% %BLD_CFG% - %BLD_SECS% s - log: %BLD_LOG%
rem  modo msbuild: o .dproj ja renomeia a DLL e copia o runtime (PostBuildEvent)
if "%BLD_MODE%"=="msbuild" goto :eof
call set "BLD_OUTNAME=%%PRJ_%BLD_K%_OUT%%"
if defined BLD_OUTNAME call :rename_out
rem  FVCSCrypt.dll (32 bits) e necessaria ao lado do EXE/DLL para o LOGIN
if /i "%BLD_PLAT%"=="Win32" if exist "%BLD_ROOT%\3rdparty\fvcscrypt.dll" if not exist "%BLD_OUTDIR%\fvcscrypt.dll" copy /y "%BLD_ROOT%\3rdparty\fvcscrypt.dll" "%BLD_OUTDIR%\" >nul
rem  Ajuda: jedivcs.chm (cliente/DLL) e jedivcsdiff.chm (Diff), se existirem em 3rdparty
for %%H in (jedivcs.chm jedivcsdiff.chm) do if exist "%BLD_ROOT%\3rdparty\%%H" if not exist "%BLD_OUTDIR%\%%H" copy /y "%BLD_ROOT%\3rdparty\%%H" "%BLD_OUTDIR%\" >nul
goto :eof

:bo_fail
set /a "BLD_NFAIL+=1"
set "BLD_RES_%BLD_K%=FALHOU"
set "BLD_SEC_%BLD_K%=%BLD_SECS%"
set "BLD_RESULT=%BLD_RC%"
echo [FALHOU] %BLD_K% %BLD_PLAT% %BLD_CFG% ^(veja o log: %BLD_LOG%^) - codigo %BLD_RC%
call :show_errors
goto :eof

:bo_noproj
set /a "BLD_NFAIL+=1"
set "BLD_RES_%BLD_K%=FALHOU"
set "BLD_SEC_%BLD_K%=0,00"
set "BLD_RESULT=1"
echo [FALHOU] %BLD_K% - projeto nao encontrado: "%BLD_PROJDIR%\%BLD_NAME%.dpr"
goto :eof

:bo_nodproj
set /a "BLD_NFAIL+=1"
set "BLD_RES_%BLD_K%=FALHOU"
set "BLD_SEC_%BLD_K%=0,00"
set "BLD_RESULT=1"
echo [FALHOU] %BLD_K% - /msbuild sem .dproj: "%BLD_PROJDIR%\%BLD_NAME%.dproj"
goto :eof

rem ---- :rename_out  - renomeia NAME.dll/.map/.drc para PRJ_chave_OUT ---------
rem  (o dcc32 nao tem opcao de nome de saida; a library continua JediVCSDLL)
:rename_out
for %%E in (dll map drc) do if exist "%BLD_OUTDIR%\%BLD_NAME%.%%E" (
    if exist "%BLD_OUTDIR%\%BLD_OUTNAME%.%%E" del /f /q "%BLD_OUTDIR%\%BLD_OUTNAME%.%%E"
    move /y "%BLD_OUTDIR%\%BLD_NAME%.%%E" "%BLD_OUTDIR%\%BLD_OUTNAME%.%%E" >nul
)
echo      Saida: %BLD_OUTDIR%\%BLD_OUTNAME%.dll
goto :eof

rem ==========================================================================
rem  :run_dcc  - compila o .dpr com dcc32/dcc64 (pasta atual = pasta do .dpr)
rem ==========================================================================
:run_dcc
if not exist "%BLD_EXEOUT%" mkdir "%BLD_EXEOUT%"
if not exist "%BLD_DCUOUT%" mkdir "%BLD_DCUOUT%"
>"%BLD_LOG%" echo # compilar.bat - %BLD_K% - %BLD_NAME%.dpr - %BLD_PLAT% %BLD_CFG% - %VD_NAME% - %DATE% %TIME%
>>"%BLD_LOG%" echo # Compilador : %BLD_DCC%
>>"%BLD_LOG%" echo # Defines    : %BLD_ALLDEFS%
>>"%BLD_LOG%" echo # Opcoes     : %BLD_SW%
>>"%BLD_LOG%" echo # Unit path  : %BLD_UPATH%
>>"%BLD_LOG%" echo # Include    : %BLD_IPATH%
>>"%BLD_LOG%" echo # Res path   : %BLD_RPATH%
>>"%BLD_LOG%" echo # Saida EXE  : %BLD_EXEOUT%   DCU: %BLD_DCUOUT%
"%BLD_DCC%" --no-config -B -Q %BLD_SW% --codepage:%BLD_CODEPAGE% "-A%BLD_ALIASES%" "-D%BLD_ALLDEFS%" "-NS%BLD_NS%" "-U%BLD_UPATH%" "-I%BLD_IPATH%" "-R%BLD_RPATH%" "-E%BLD_EXEOUT%" "-NU%BLD_DCUOUT%" "%BLD_NAME%.dpr" >>"%BLD_LOG%" 2>&1
set "BLD_RC=%ERRORLEVEL%"
goto :eof

rem ==========================================================================
rem  :run_msbuild  - compila o .dproj com MSBuild (/msbuild). Defines, caminhos
rem  e saidas vem do .dproj + tools\msbuild\JediVCS2026.props (+ o Library
rem  Path da IDE, que o MSBuild le do EnvOptions.proj).
rem ==========================================================================
:run_msbuild
where msbuild.exe >nul 2>&1 || goto :rm_nomsbuild
msbuild "%BLD_NAME%.dproj" /t:Build /p:Config=%BLD_CFG% /p:Platform=%BLD_PLAT% /v:minimal /nologo /fl "/flp:logfile=%BLD_LOG%;verbosity=normal"
set "BLD_RC=%ERRORLEVEL%"
goto :eof
:rm_nomsbuild
echo [ERRO] msbuild.exe nao encontrado no PATH apos executar rsvars.bat.
>"%BLD_LOG%" echo msbuild.exe nao encontrado no PATH.
set "BLD_RC=1"
goto :eof

rem ==========================================================================
rem  :build_lib CHAVE  - compila os pacotes de uma biblioteca fixada (SynEdit, VTV)
rem    runtime (sempre) + design-time (so se BLD_DODESIGN=1)
rem ==========================================================================
:build_lib
set "BLD_LK=%~1"
call set "BLD_LDIR=%%LIB_%BLD_LK%_DIR%%"
call set "BLD_LRUN=%%LIB_%BLD_LK%_RUN%%"
call set "BLD_LDES=%%LIB_%BLD_LK%_DES%%"
call set "BLD_LDCU=%%BLD_DCU_%BLD_LK%%%"
set "BLD_LDCUD=%BLD_LIBROOT%\%BLD_LK%\design\%BLD_PLAT%\%BLD_CFG%"
call :build_pkg "%BLD_LRUN%" runtime "%BLD_LDIR%" "%BLD_LDCU%"
if not "%BLD_PRC%"=="0" goto :eof
rem recursos (.res/.dfm) ao lado dos DCUs, como fazem os instaladores das libs:
rem quem usa so a pasta de DCUs no Library Path precisa deles ({$R SynEdit.res} etc.)
call set "BLD_LSRC=%%LIB_%BLD_LK%_SRC%%"
for %%E in (res dfm) do if exist "%BLD_ROOT%\%BLD_LSRC%\*.%%E" copy /y "%BLD_ROOT%\%BLD_LSRC%\*.%%E" "%BLD_LDCU%\" >nul
if "%BLD_DODESIGN%"=="1" call :build_pkg "%BLD_LDES%" design "%BLD_LDIR%" "%BLD_LDCUD%"
goto :eof

rem ==========================================================================
rem  :build_pkg NOME TIPO PASTA DCUOUT  - compila um .dproj de pacote com MSBuild
rem    PASTA relativa a raiz; DCUs em DCUOUT; BPL/DCP em BLD_BPLDIR/BLD_DCPDIR.
rem    As propriedades /p: tem prioridade sobre as do .dproj (que apontam para
rem    dentro de src\), por isso nada e gravado nas pastas das bibliotecas.
rem ==========================================================================
:build_pkg
set "BLD_PN=%~1"
set "BLD_PKIND=%~2"
set "BLD_PDIR=%BLD_ROOT%\%~3"
set "BLD_PDCU=%~4"
set "BLD_LOG=%BLD_LOGDIR%\compilar_%BLD_TAGL%lib_%BLD_PN%_%BLD_PLAT%_%BLD_CFG%.log"
set "BLD_PRC=0"

echo.
echo ==== lib : %BLD_PN% ^(%BLD_PKIND%^) - %BLD_PLAT% %BLD_CFG% ====
if not exist "%BLD_PDIR%\%BLD_PN%.dproj" goto :bp_noproj
where msbuild.exe >nul 2>&1 || goto :bp_nomsbuild
if not exist "%BLD_PDCU%" mkdir "%BLD_PDCU%"
if not exist "%BLD_BPLDIR%" mkdir "%BLD_BPLDIR%"
if not exist "%BLD_DCPDIR%" mkdir "%BLD_DCPDIR%"
if not exist "%BLD_RESDIR%" mkdir "%BLD_RESDIR%"
set "BLD_PARGS=/p:Config=%BLD_CFG% /p:Platform=%BLD_PLAT% "/p:DCC_DcuOutput=%BLD_PDCU%" "/p:DCC_BplOutput=%BLD_BPLDIR%" "/p:DCC_DcpOutput=%BLD_DCPDIR%""
set "BLD_PARGS=%BLD_PARGS% "/p:DCC_BpiOutput=%BLD_DCPDIR%" "/p:DCC_ObjOutput=%BLD_DCPDIR%" "/p:DCC_HppOutput=%BLD_HPPDIR%" "/p:BRCC_OutputDir=%BLD_RESDIR%\\" /p:DCC_CBuilderOutput=%JVCS_CBUILDER%"

call :now BLD_PT0
pushd "%BLD_PDIR%"
msbuild "%BLD_PN%.dproj" /t:Build %BLD_PARGS% /v:minimal /nologo /fl "/flp:logfile=%BLD_LOG%;verbosity=normal"
set "BLD_PRC=%ERRORLEVEL%"
popd
call :elapsed BLD_PT0 BLD_PSECS

set "BLD_PKGDONE=%BLD_PKGDONE% %BLD_PN%"
set "BLD_SEC_%BLD_PN%=%BLD_PSECS%"
set "BLD_KIND_%BLD_PN%=%BLD_PKIND%"
if not "%BLD_PRC%"=="0" goto :bp_fail
set /a "BLD_NOK+=1"
set "BLD_RES_%BLD_PN%=OK"
echo [OK] %BLD_PN% ^(%BLD_PKIND%^) %BLD_PLAT% %BLD_CFG% - %BLD_PSECS% s - log: %BLD_LOG%
for %%F in ("%BLD_BPLDIR%\%BLD_PN%*.bpl") do echo      BPL: %%~fF
goto :eof

:bp_fail
set /a "BLD_NFAIL+=1"
set "BLD_RES_%BLD_PN%=FALHOU"
set "BLD_RESULT=%BLD_PRC%"
echo [FALHOU] %BLD_PN% ^(%BLD_PKIND%^) %BLD_PLAT% %BLD_CFG% ^(veja o log: %BLD_LOG%^) - codigo %BLD_PRC%
call :show_errors
goto :eof

:bp_noproj
set /a "BLD_NFAIL+=1"
set "BLD_PRC=1"
set "BLD_RESULT=1"
set "BLD_PKGDONE=%BLD_PKGDONE% %BLD_PN%"
set "BLD_RES_%BLD_PN%=FALHOU"
set "BLD_SEC_%BLD_PN%=0,00"
set "BLD_KIND_%BLD_PN%=%BLD_PKIND%"
echo [FALHOU] %BLD_PN% - pacote nao encontrado: "%BLD_PDIR%\%BLD_PN%.dproj"
goto :eof

:bp_nomsbuild
set /a "BLD_NFAIL+=1"
set "BLD_PRC=1"
set "BLD_RESULT=1"
set "BLD_PKGDONE=%BLD_PKGDONE% %BLD_PN%"
set "BLD_RES_%BLD_PN%=FALHOU"
set "BLD_SEC_%BLD_PN%=0,00"
set "BLD_KIND_%BLD_PN%=%BLD_PKIND%"
echo [ERRO] msbuild.exe nao encontrado no PATH apos executar rsvars.bat.
goto :eof

rem ---- :lib_needed CHAVE  - acrescenta a BLD_LIBLIST se faltar o DCU marcador ----
rem  Nao compila sozinha se o usuario redefiniu SYNEDIT_PATH/VTV_PATH no ambiente.
:lib_needed
if defined BLD_USER_%~1 goto :eof
call set "BLD_LNDIR=%%BLD_DCU_%~1%%"
call set "BLD_LNMARK=%%LIB_%~1_MARK%%"
if exist "%BLD_LNDIR%\%BLD_LNMARK%" goto :eof
set "BLD_LIBLIST=%BLD_LIBLIST% %~1"
goto :eof

rem ==========================================================================
rem  :find_cat CHAVE "VALOR_DO_INI"  - pasta raiz de uma biblioteca do GetIt
rem    -> CAT_<chave>_DIR (vazio = nao encontrada) e CAT_<chave>_HOW
rem  1) VALOR_DO_INI relativo ao CatalogRepository (do usuario e o comum) ou
rem     absoluto: a propria pasta ou a ultima subpasta com o marcador;
rem  2) procura CAT_<chave>_PAT nos dois CatalogRepository (pasta ou subpasta).
rem ==========================================================================
:find_cat
set "FC_R="
set "FC_V=%~2"
call set "FC_MARK=%%CAT_%~1_MARK%%"
call set "FC_PAT=%%CAT_%~1_PAT%%"
set "CAT_%~1_HOW=versoes.ini"
if defined FC_V call :fc_ini
if defined FC_R goto :fc_done
set "CAT_%~1_HOW=procura automatica"
for %%C in ("%JVCS_CATALOG%" "%BLD_CATALL%") do if not defined FC_R for %%P in (%FC_PAT%) do for /d %%D in ("%%~C\%%P*") do call :fc_dir "%%~fD"
:fc_done
set "CAT_%~1_DIR=%FC_R%"
if not defined FC_R set "CAT_%~1_HOW=NAO ENCONTRADA"
goto :eof

:fc_ini
if exist "%JVCS_CATALOG%\%FC_V%\" call :fc_dir "%JVCS_CATALOG%\%FC_V%"
if defined FC_R goto :eof
if exist "%BLD_CATALL%\%FC_V%\" call :fc_dir "%BLD_CATALL%\%FC_V%"
if defined FC_R goto :eof
rem  absoluto (tem ":" ou comeca com "\\")
set "FC_T=%FC_V::=%"
if "%FC_T%"=="%FC_V%" if not "%FC_V:~0,2%"=="\\" goto :eof
if exist "%FC_V%\" call :fc_dir "%FC_V%"
goto :eof

rem ---- :fc_dir PASTA  - PASTA ou a ultima subpasta dela com o marcador -> FC_R ---
:fc_dir
if exist "%~1\%FC_MARK%" set "FC_R=%~f1" & goto :eof
for /d %%S in ("%~1\*") do if exist "%%~fS\%FC_MARK%" set "FC_R=%%~fS"
goto :eof

rem ==========================================================================
rem  :write_props  - grava lib\paths\JediVCS2026-<BDSVER>.props com as pastas
rem    raiz de JCL/JVCL/ICS/Abbrevia encontradas (para os .dproj: ver
rem    tools\msbuild\JediVCS2026.props). So as que foram encontradas.
rem ==========================================================================
:write_props
set "BLD_PROPSDIR=%BLD_ROOT%\lib\paths"
set "BLD_PROPS=%BLD_PROPSDIR%\JediVCS2026-%BDSVER%.props"
if not exist "%BLD_PROPSDIR%" mkdir "%BLD_PROPSDIR%" 2>nul
>"%BLD_PROPS%" echo ^<?xml version="1.0" encoding="utf-8"?^>
>>"%BLD_PROPS%" echo ^<!-- Gerado por tools\compilar.bat em %DATE% %TIME% - %VD_NAME% (BDS %BDSVER%). Nao edite: rode o compilar.bat de novo. --^>
>>"%BLD_PROPS%" echo ^<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003"^>
>>"%BLD_PROPS%" echo   ^<PropertyGroup^>
if defined CAT_jcl_DIR >>"%BLD_PROPS%" echo     ^<JvcsJclDir Condition="'$(JvcsJclDir)'==''"^>%CAT_jcl_DIR%^</JvcsJclDir^>
if defined CAT_jvcl_DIR >>"%BLD_PROPS%" echo     ^<JvcsJvclDir Condition="'$(JvcsJvclDir)'==''"^>%CAT_jvcl_DIR%^</JvcsJvclDir^>
if defined CAT_ics_DIR >>"%BLD_PROPS%" echo     ^<JvcsIcsDir Condition="'$(JvcsIcsDir)'==''"^>%CAT_ics_DIR%^</JvcsIcsDir^>
if defined CAT_abbrevia_DIR >>"%BLD_PROPS%" echo     ^<JvcsAbbreviaDir Condition="'$(JvcsAbbreviaDir)'==''"^>%CAT_abbrevia_DIR%^</JvcsAbbreviaDir^>
>>"%BLD_PROPS%" echo     ^<JvcsJclLib Condition="'$(JvcsJclLib)'==''"^>%VD_JCLLIB%^</JvcsJclLib^>
>>"%BLD_PROPS%" echo   ^</PropertyGroup^>
>>"%BLD_PROPS%" echo ^</Project^>
goto :eof

rem ==========================================================================
rem  :show_info  - /info: versao, caminhos resolvidos e se existem
rem ==========================================================================
:show_info
echo Raiz          : %BLD_ROOT%
echo Delphi        : %VD_NAME% ^(BDS %BDSVER%, pacotes %VD_PKG%, JvcsExpertBDS%VD_BDSNUM%.dll^)
if "%VD_INSTALLED%"=="1" echo RAD Studio    : %BLD_BDSDIR% [instalado]
if not "%VD_INSTALLED%"=="1" echo RAD Studio    : %BLD_BDSDIR% [NAO INSTALADO - falta bin\rsvars.bat ou bin\dcc32.exe]
echo Config        : %BLD_CFG% %BLD_PLAT%
echo Catalog       : %JVCS_CATALOG%
echo Catalog comum : %BLD_CATALL%
call :info_cat "JCL     " jcl
call :info_cat "JVCL    " jvcl
call :info_cat "ICS     " ics
call :info_cat "Abbrevia" abbrevia
echo.
echo Pastas de DCUs ^(-U^):
call :info_dir "JCL     " "%JCL_PATH%"
call :info_dir "JVCL    " "%JVCL_PATH%"
call :info_dir "ICS     " "%ICS_PATH%"
call :info_dir "Abbrevia" "%ABBREVIA_PATH%"
call :info_dir "SynEdit " "%SYNEDIT_PATH%"
call :info_dir "VTV     " "%VTV_PATH%"
echo.
echo Saidas:
echo   EXE/DLL     : %BLD_OUTDIR%
echo   DCUs        : %BLD_ROOT%\dcu%BLD_TAGP%\%BLD_PLAT%\%BLD_CFG%\^<alvo^>
echo   libs        : %BLD_LIBROOT% ^(BPL %BLD_BPLDIR%^)
echo   /msbuild    : %BLD_MSBOUT%
echo   expert      : %BLD_ROOT%\bin\ideclient\Win32\JvcsExpertBDS%VD_BDSNUM%.dll
echo   props .dproj: %BLD_ROOT%\lib\paths\JediVCS2026-%BDSVER%.props ^(gravado na compilacao^)
endlocal & exit /b 0

:info_cat
call set "BLD_ICD=%%CAT_%~2_DIR%%"
call set "BLD_ICH=%%CAT_%~2_HOW%%"
if defined BLD_ICD echo Raiz %~1 : %BLD_ICD% ^(%BLD_ICH%^)
if not defined BLD_ICD echo Raiz %~1 : NAO ENCONTRADA - instale pelo GetIt ou ajuste tools\versoes.ini
goto :eof

:info_dir
if exist "%~2\" echo   [ok]    %~1 %~2
if not exist "%~2\" echo   [falta] %~1 %~2
goto :eof

rem ---- :chk_libdirs  - avisa se faltam DCUs das bibliotecas (apos o alvo libs) ----
:chk_libdirs
call :chkdir JCL "%JCL_PATH%"
call :chkdir JVCL "%JVCL_PATH%"
call :chkdir ICS "%ICS_PATH%"
call :chkdir SynEdit "%SYNEDIT_PATH%"
call :chkdir VTV "%VTV_PATH%"
call :chkdir Abbrevia "%ABBREVIA_PATH%"
goto :eof

rem ---- :sumpkg PACOTE  - linha do resumo final (pacotes) ----------------------
:sumpkg
call set "BLD_SR=%%BLD_RES_%~1%%"
call set "BLD_SS=%%BLD_SEC_%~1%%"
call set "BLD_SK=%%BLD_KIND_%~1%%"
echo   [%BLD_SR%] lib %~1 ^(%BLD_SK%^) - %BLD_SS% s
goto :eof

rem ---- :sumline CHAVE  - linha do resumo final --------------------------------
:sumline
call set "BLD_SR=%%BLD_RES_%~1%%"
call set "BLD_SS=%%BLD_SEC_%~1%%"
call set "BLD_SN=%%PRJ_%~1_NAME%%"
echo   [%BLD_SR%] %~1 ^(%BLD_SN%^) - %BLD_SS% s
goto :eof

rem ---- :show_errors  - mostra as primeiras BLD_MAXERR mensagens do log -------
:show_errors
setlocal EnableDelayedExpansion
set /a "BLD_N=0"
for /f "usebackq delims=" %%L in (`findstr /i /c:"Fatal:" /c:"Error:" /c:"error F" /c:"error E" "!BLD_LOG!"`) do (
    set /a "BLD_N+=1"
    if !BLD_N! leq %BLD_MAXERR% (
        set "BLD_LINE=%%L"
        echo     !BLD_LINE!
    )
)
endlocal
goto :eof

rem ---- :norm_extra  - limpa JVCS_EXTRA_PATH (sem aspas, sem ; ou \ no fim) ----
:norm_extra
set "BLD_EXTRA="
if not defined JVCS_EXTRA_PATH goto :eof
set "BLD_EXTRA=%JVCS_EXTRA_PATH:"=%"
:norm_loop
if not defined BLD_EXTRA goto :eof
if "%BLD_EXTRA:~-1%"==";" set "BLD_EXTRA=%BLD_EXTRA:~0,-1%" & goto :norm_loop
if "%BLD_EXTRA:~-1%"=="\" set "BLD_EXTRA=%BLD_EXTRA:~0,-1%" & goto :norm_loop
goto :eof

rem ---- :chkdir NOME DIRETORIO  - avisa se a pasta de DCUs nao existe -----------
:chkdir
set "BLD_T=%~2"
if not "%BLD_T:;=%"=="%BLD_T%" goto :eof
if not exist "%~2" echo [AVISO] %~1: pasta de DCUs nao encontrada: %~2
goto :eof

rem ---- :now VAR  - hora atual em centesimos de segundo ----------------------
:now
set "BLD_TM=%TIME: =0%"
for /f "tokens=1-4 delims=:.," %%a in ("%BLD_TM%") do set /a "%~1=((1%%a-100)*3600+(1%%b-100)*60+(1%%c-100))*100+(1%%d-100)"
goto :eof

rem ---- :elapsed VAR_INICIO VAR_SAIDA  - segundos decorridos (ex.: 3,07) ----
:elapsed
call :now BLD_T1
set /a "BLD_D=BLD_T1-%~1"
if %BLD_D% lss 0 set /a "BLD_D+=8640000"
set /a "BLD_S=BLD_D/100, BLD_C=BLD_D%%100"
if %BLD_C% lss 10 set "BLD_C=0%BLD_C%"
set "%~2=%BLD_S%,%BLD_C%"
goto :eof

rem ---- Mensagens de uso/erro ------------------------------------------------
:usage
echo Uso: %~nx0 [/delphi:11^|12^|13 ^| /bds:22^|23^|37] [/info] [/msbuild]
echo                 [exe^|dll^|diff^|console^|libs^|all] [Debug^|Release] [Win32^|Win64]
echo      Padrao: all Debug Win32, Delphi 13 ^(ou JVCS_DELPHI^). Projetos: %ALL_PROJECTS%
echo      /delphi, /bds: versao do Delphi ^(tools\versoes.ini^). 11/12 gravam em
echo            bin\client\D11^|D12, dcu\D11^|D12 e lib\D11^|D12 ^(o 13 sem subpasta^).
echo      /info: mostra versao, pastas das bibliotecas e saidas, e sai.
echo      /msbuild: compila os .dproj ^(saida em bin\msbuild\Dnn\^<plat^>\^<cfg^>^).
echo      libs: compila SynEdit e VirtualTreeView fixados em src\comp ^(DCUs em lib\^),
echo            runtime Win32/Win64 e design-time ^(so Win32^). BPL em lib\bpl\^<plat^>,
echo            DCP em lib\dcp\^<plat^> ^(JVCS_BPLDIR / JVCS_DCPDIR mudam as pastas^).
echo            "all"/projetos chamam libs sozinhos se faltarem os DCUs.
echo      Defina BDSROOT para usar outra instalacao do RAD Studio.
echo      Defina JVCS_CATALOG ^(GetIt^) e JVCS_EXTRA_PATH ^(outras libs^) se preciso.
echo      Opcional: JVCS_EXTRA_DEFS ^(defines extras em todos os projetos^).
endlocal & exit /b 0

:bad_opt
echo [ERRO] Opcao invalida: "%BLD_A%". Use /delphi:NN, /bds:NN, /info ou /msbuild ^(%~nx0 /? para ajuda^).
endlocal & exit /b 1

:bad_ver
echo [ERRO] %VD_ERR%
endlocal & exit /b 1

:bad_what
echo [ERRO] Projeto invalido: "%BLD_WHAT%". Use: %ALL_PROJECTS%, libs ou all.
endlocal & exit /b 1

:bad_cfg
echo [ERRO] Configuracao invalida: "%BLD_CFG%". Use Debug ou Release.
endlocal & exit /b 1

:bad_plat
echo [ERRO] Plataforma invalida: "%BLD_PLAT%". Use Win32 ou Win64.
endlocal & exit /b 1

:not_installed
echo [ERRO] %VD_NAME% ^(BDS %BDSVER%^) nao esta instalado nesta maquina:
echo        faltam "%BLD_BDSDIR%\bin\rsvars.bat" ou "%BLD_BDSDIR%\bin\dcc32.exe".
echo        Instale o %VD_NAME% ou defina BDSROOT com a pasta raiz correta
echo        ^(ex.: set BDSROOT=D:\Embarcadero\Studio\%BDSVER%^). Nada foi compilado.
endlocal & exit /b 1

:no_dcc
echo [ERRO] Compilador nao encontrado: "%BLD_DCC%"
if /i "%BLD_PLAT%"=="Win64" echo        A plataforma Win64 do %VD_NAME% esta instalada?
endlocal & exit /b 1

:no_lib
echo [ERRO] Pasta de DCUs da RTL/VCL nao encontrada: "%BLD_LIBDIR%"
endlocal & exit /b 1
