@echo off
rem ==========================================================================
rem  compilar.bat - Compila os projetos do JEDI VCS v2026
rem
rem  Uso:   compilar.bat [exe, dll, diff, console, libs ou all] [Debug ou Release] [Win32 ou Win64]
rem         Padrao: all Debug Win32
rem
rem  Se existir PROJETO.dproj ao lado do .dpr, usa MSBuild (como o build.bat
rem  modelo). Senao, chama dcc32 (Win32) ou dcc64 (Win64) direto no .dpr, com
rem  os defines e caminhos da tabela abaixo (portados dos .dof do Delphi 7).
rem
rem  Alvo "libs": compila (MSBuild) os pacotes do SynEdit e do VirtualTreeView
rem  FIXADOS no repositorio (src\comp\synedit e src\comp\virtualtreeview):
rem    - runtime (SynEditDR, VirtualTreesR): Win32 ou Win64, Debug ou Release
rem    - design-time (SynEditDD, VirtualTreesD): so Win32 (para instalar na IDE)
rem    - DCUs em lib\<lib>\<plataforma>\<config>; design em lib\<lib>\design\...
rem    - BPL em lib\bpl\<plataforma> e DCP em lib\dcp\<plataforma>
rem      (JVCS_BPLDIR / JVCS_DCPDIR mudam estas duas pastas)
rem  "all" e os projetos isolados chamam "libs" sozinhos (so os pacotes runtime)
rem  quando faltam os DCUs da config/plataforma pedida; "libs" sempre recompila.
rem
rem  Variaveis de ambiente opcionais:
rem    BDSROOT         = pasta raiz do RAD Studio (sobrescreve o caminho padrao
rem                      ProgramFiles(x86)\Embarcadero\Studio\BDSVER). Se a pasta final
rem                      for numerica (ex.: ...\Studio\22.0) ela define o BDSVER.
rem    JVCS_CATALOG    = pasta CatalogRepository do GetIt (JCL, JVCL, ICS, Abbrevia;
rem                      padrao: USERPROFILE\Documents\Embarcadero\Studio\BDSVER\CatalogRepository)
rem    JCL_PATH, JVCL_PATH, ICS_PATH, SYNEDIT_PATH, VTV_PATH, ABBREVIA_PATH = DCUs de cada
rem                      biblioteca (e *_INC = fontes/includes); substituem o padrao.
rem                      SYNEDIT_PATH/VTV_PATH definidos desligam a compilacao automatica.
rem    JVCS_BPLDIR, JVCS_DCPDIR = pastas de saida dos BPL e dos DCP/BPI/LIB (alvo libs);
rem                      padrao lib\bpl\<plat> e lib\dcp\<plat>.
rem    JVCS_EXTRA_DEFS = defines extras (separados por ponto e virgula) para todos os projetos
rem    JVCS_EXTRA_PATH = caminhos ABSOLUTOS (separados por ponto e virgula) de
rem                      de outras bibliotecas (as acima ja entram por padrao).
rem                      Acrescentados a -U, -I e -R (so no modo dcc).
rem    JVCS_CBUILDER   = DCC_CBuilderOutput dos pacotes (padrao None = sem .hpp/.obj/.bpi/.lib)
rem
rem  Gera um log por projeto: tools\logs\compilar_PROJ_PLATAFORMA_CONFIG.log
rem  (pacotes: tools\logs\compilar_lib_PACOTE_PLATAFORMA_CONFIG.log)
rem  Codigo de saida: 0 = tudo OK; diferente de zero = alguma falha.
rem ==========================================================================
setlocal EnableExtensions DisableDelayedExpansion

rem ---- Configuracao geral (ajuste aqui) -------------------------------------
rem  BDSVER = versao do Delphi usada por padrao (37.0 = Delphi 13). BLD_DEFVER e a
rem  versao "de referencia": lib\ fica sem subpasta de versao; com outro BDSROOT
rem  (ex.: 22.0 / 23.0) as saidas vao para lib\<BDSVER>\ (DCU/DCP de versoes
rem  diferentes do Delphi sao incompativeis entre si).
set "BDSVER=37.0"
set "BLD_DEFVER=37.0"
set "BLD_CODEPAGE=1252"
set "BLD_MAXERR=3"
set "BLD_ALIASES=WinTypes=Windows;WinProcs=Windows;DbiTypes=BDE;DbiProcs=BDE;DbiErrs=BDE"
set "BLD_NS=Winapi;System.Win;Data.Win;Datasnap.Win;Web.Win;Soap.Win;Xml.Win;Bde;System;Data;Datasnap;Web;Soap;Xml;Vcl;Vcl.Imaging;Vcl.Touch;Vcl.Samples;Vcl.Shell"

rem ---- Caminhos de busca comuns (relativos a pasta do .dpr) -----------------
rem  Usados em -U, -I e -R. NAO incluir src\comp\_legacy (so referencia).
set "BLD_BASEPATH=..\common;..\common\client;..\comp\midware;..\comp\textdiff;..\comp\mdmailslot;..\comp\crc;..\comp\mwtools"

rem ---- Pastas do projeto e dos logs -----------------------------------------
for %%I in ("%~dp0..") do set "BLD_ROOT=%%~fI"
for %%I in ("%~dp0.") do set "BLD_TOOLS=%%~fI"
set "BLD_LOGDIR=%BLD_TOOLS%\logs"

rem ---- Instalacao do RAD Studio ---------------------------------------------
rem  BDSROOT (se definida) vem antes de tudo: o nome da pasta final (ex.: 22.0)
rem  define o BDSVER, que entra no caminho do CatalogRepository e nas saidas de lib\.
set "BLD_BDSDIR=%ProgramFiles(x86)%\Embarcadero\Studio\%BDSVER%"
if defined BDSROOT set "BLD_BDSDIR=%BDSROOT:"=%"
if "%BLD_BDSDIR:~-1%"=="\" set "BLD_BDSDIR=%BLD_BDSDIR:~0,-1%"
if defined BDSROOT for %%I in ("%BLD_BDSDIR%") do call :ver_from_leaf "%%~nxI"

rem ---- Bibliotecas de terceiros instaladas via GetIt (CatalogRepository) ----
rem  JCL, JVCL, ICS e Abbrevia. (SynEdit e VirtualTreeView NAO vem mais do GetIt:
rem  usam as fontes fixadas no repositorio, ver "Bibliotecas fixadas" abaixo.)
rem  O dcc32/dcc64 de linha de comando NAO le o Library Path da IDE, entao as
rem  pastas abaixo entram por padrao no search path:
rem    -U (units)  : pasta de DCUs da config/plataforma de cada biblioteca
rem    -I e -R     : pastas de fontes (.inc, .res, .dfm)
rem  Os .pas das bibliotecas NAO entram em -U de proposito: como o script usa -B,
rem  eles seriam recompilados (o ICS, por exemplo, nao compila com -J+ global).
rem  JVCS_CATALOG pode ser definida no ambiente para apontar outra pasta.
if not defined JVCS_CATALOG set "JVCS_CATALOG=%USERPROFILE%\Documents\Embarcadero\Studio\%BDSVER%\CatalogRepository"
set "JVCS_JCL_REL=JEDICodeLibraryJCL-13\2026.08"
set "JVCS_JVCL_REL=JEDIVisualComponentLibraryJVCL-13\2026.08"
set "JVCS_ICS_REL=ICS_VCL-13\9.7"
set "JVCS_ABBREVIA_REL=Abbrevia-13\2026.10"
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
if "%~1"=="/?" goto :usage
if /i "%~1"=="-h" goto :usage
if /i "%~1"=="--help" goto :usage

set "BLD_WHAT=%~1"
if not defined BLD_WHAT set "BLD_WHAT=all"
set "BLD_CFG=%~2"
if not defined BLD_CFG set "BLD_CFG=Debug"
set "BLD_PLAT=%~3"
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

rem ---- Ambiente do RAD Studio (rsvars.bat) ----------------------------------
set "BLD_RSVARS=%BLD_BDSDIR%\bin\rsvars.bat"
if not exist "%BLD_RSVARS%" goto :no_rsvars
call "%BLD_RSVARS%"
set "BLD_DCC=%BLD_BDSDIR%\bin\%BLD_DCCEXE%"
if not exist "%BLD_DCC%" goto :no_dcc
set "BLD_LIBDIR=%BLD_BDSDIR%\lib\%BLD_LIBPLAT%\%BLD_LIBCFG%"
if not exist "%BLD_LIBDIR%" goto :no_lib

rem ---- Bibliotecas de terceiros - monta as listas ---------------------------
if "%JVCS_CATALOG:~-1%"=="\" set "JVCS_CATALOG=%JVCS_CATALOG:~0,-1%"
for /f "delims=." %%V in ("%BDSVER%") do set "BLD_DVER=%%V"
set "BLD_JCLDIR=%JVCS_CATALOG%\%JVCS_JCL_REL%"
set "BLD_JVCLDIR=%JVCS_CATALOG%\%JVCS_JVCL_REL%"
set "BLD_ICSDIR=%JVCS_CATALOG%\%JVCS_ICS_REL%"
set "BLD_ABBDIR=%JVCS_CATALOG%\%JVCS_ABBREVIA_REL%"

rem  SynEdit / VirtualTreeView fixados: DCUs em lib\<lib>\<plat>\<cfg>, fontes em src\comp.
rem  BLD_USER_<lib> marca quem foi redefinido no ambiente (nao compila automatico).
set "BLD_LIBROOT=%BLD_ROOT%\lib"
if not "%BDSVER%"=="%BLD_DEFVER%" set "BLD_LIBROOT=%BLD_ROOT%\lib\%BDSVER%"
set "BLD_USER_synedit="
if defined SYNEDIT_PATH set "BLD_USER_synedit=1"
set "BLD_USER_virtualtreeview="
if defined VTV_PATH set "BLD_USER_virtualtreeview=1"
for %%L in (%ALL_LIBS%) do set "BLD_DCU_%%L=%BLD_LIBROOT%\%%L\%BLD_PLAT%\%BLD_CFG%"

if not defined JCL_PATH set "JCL_PATH=%BLD_JCLDIR%\lib\d%BLD_DVER%\%BLD_LIBPLAT%"
if not defined JCL_INC set "JCL_INC=%BLD_JCLDIR%\source\include;%BLD_JCLDIR%\source\include\jedi"
if not defined JVCL_PATH set "JVCL_PATH=%BLD_JVCLDIR%\lib\D%BLD_DVER%\%BLD_LIBPLAT%"
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
rem  O -R tambem precisa da pasta release da RTL/VCL (ex.: controls.res so existe la).
set "BLD_RELDIR=%BLD_BDSDIR%\lib\%BLD_LIBPLAT%\release"

rem ---- Saidas dos pacotes (alvo libs) ---------------------------------------
rem  Padrao: tudo dentro da v2026 (lib\bpl\<plat>, lib\dcp\<plat>). JVCS_BPLDIR e
rem  JVCS_DCPDIR (ambiente) mudam essas duas pastas.
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

if not exist "%BLD_LOGDIR%" mkdir "%BLD_LOGDIR%"
call :norm_extra

rem ---- Quais bibliotecas fixadas compilar -----------------------------------
set "BLD_LIBLIST="
if "%BLD_LIBMODE%"=="force" set "BLD_LIBLIST=%ALL_LIBS%"
if "%BLD_LIBMODE%"=="auto" for %%L in (%ALL_LIBS%) do call :lib_needed %%L

set "BLD_SHOWT=%BLD_TARGETS%"
if "%BLD_LIBMODE%"=="force" set "BLD_SHOWT=libs"

echo Raiz    : %BLD_ROOT%
echo Delphi  : %BLD_BDSDIR% ^(BDSVER %BDSVER%^)
echo Config  : %BLD_CFG% %BLD_PLAT% ^(compilador: %BLD_DCCEXE%^)
echo Alvos   : %BLD_SHOWT%
if defined BLD_TARGETS echo Catalog : %JVCS_CATALOG%
if defined BLD_TARGETS echo Libs    : JCL, JVCL, ICS, Abbrevia ^(GetIt^); SynEdit, VTV ^(repositorio, DCUs de %BLD_CFG% %BLD_PLAT%^)
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
echo ==== Resumo: %BLD_CFG% %BLD_PLAT% ====
for %%K in (%BLD_PKGDONE%) do call :sumpkg %%K
for %%K in (%BLD_TARGETS%) do call :sumline %%K
echo.
if "%BLD_RESULT%"=="0" echo Compilacao concluida sem erros - %BLD_NOK% alvo^(s^) OK.
if not "%BLD_RESULT%"=="0" echo Compilacao terminou com falhas: %BLD_NOK% OK, %BLD_NFAIL% FALHOU - codigo %BLD_RESULT%.
if not "%BLD_RESULT%"=="0" echo Logs em: %BLD_LOGDIR%
endlocal & exit /b %BLD_RESULT%

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
set "BLD_LOG=%BLD_LOGDIR%\compilar_%BLD_K%_%BLD_PLAT%_%BLD_CFG%.log"

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
set "BLD_EXEOUT=..\..\bin\client\%BLD_PLAT%"
rem  DCUs separados por projeto: units compartilhadas mudam com os defines de cada alvo
set "BLD_DCUOUT=..\..\dcu\%BLD_PLAT%\%BLD_CFG%\%BLD_K%"

echo.
echo ==== %BLD_K% : %BLD_NAME% - %BLD_PLAT% %BLD_CFG% ====
if not exist "%BLD_PROJDIR%\%BLD_NAME%.dpr" goto :bo_noproj

call :now BLD_T0
set "BLD_RC=0"
pushd "%BLD_PROJDIR%"
if exist "%BLD_NAME%.dproj" (call :run_msbuild) else (call :run_dcc)
popd
call :elapsed BLD_T0 BLD_SECS

if not "%BLD_RC%"=="0" goto :bo_fail
set /a "BLD_NOK+=1"
set "BLD_RES_%BLD_K%=OK"
set "BLD_SEC_%BLD_K%=%BLD_SECS%"
echo [OK] %BLD_K% %BLD_PLAT% %BLD_CFG% - %BLD_SECS% s - log: %BLD_LOG%
call set "BLD_OUTNAME=%%PRJ_%BLD_K%_OUT%%"
if defined BLD_OUTNAME call :rename_out
rem  FVCSCrypt.dll (32 bits) e necessaria ao lado do EXE/DLL para o LOGIN
if /i "%BLD_PLAT%"=="Win32" if exist "%BLD_ROOT%\3rdparty\fvcscrypt.dll" if not exist "%BLD_ROOT%\bin\client\Win32\fvcscrypt.dll" copy /y "%BLD_ROOT%\3rdparty\fvcscrypt.dll" "%BLD_ROOT%\bin\client\Win32\" >nul
rem  Ajuda: jedivcs.chm (cliente/DLL) e jedivcsdiff.chm (Diff), se existirem em 3rdparty
for %%H in (jedivcs.chm jedivcsdiff.chm) do if exist "%BLD_ROOT%\3rdparty\%%H" if not exist "%BLD_ROOT%\bin\client\%BLD_PLAT%\%%H" copy /y "%BLD_ROOT%\3rdparty\%%H" "%BLD_ROOT%\bin\client\%BLD_PLAT%\" >nul
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

rem ---- :rename_out  - renomeia NAME.dll/.map/.drc para PRJ_chave_OUT ---------
rem  (o dcc32 nao tem opcao de nome de saida; a library continua JediVCSDLL)
:rename_out
set "BLD_OUTDIR=%BLD_ROOT%\bin\client\%BLD_PLAT%"
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
>"%BLD_LOG%" echo # compilar.bat - %BLD_K% - %BLD_NAME%.dpr - %BLD_PLAT% %BLD_CFG% - %DATE% %TIME%
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
rem  :run_msbuild  - compila o .dproj com MSBuild (modelo: Ex1\build.bat)
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
set "BLD_LOG=%BLD_LOGDIR%\compilar_lib_%BLD_PN%_%BLD_PLAT%_%BLD_CFG%.log"
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

rem ---- :ver_from_leaf NOME  - se NOME for NN.N define BDSVER (ex.: 22.0) --------
:ver_from_leaf
echo %~1| findstr /r /x "[0-9][0-9]*\.[0-9][0-9]*" >nul && set "BDSVER=%~1"
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
echo Uso: %~nx0 [exe^|dll^|diff^|console^|libs^|all] [Debug^|Release] [Win32^|Win64]
echo      Padrao: all Debug Win32. Projetos: %ALL_PROJECTS%
echo      libs: compila SynEdit e VirtualTreeView fixados em src\comp ^(DCUs em lib\^),
echo            runtime Win32/Win64 e design-time ^(so Win32^). BPL em lib\bpl\^<plat^>,
echo            DCP em lib\dcp\^<plat^> ^(JVCS_BPLDIR / JVCS_DCPDIR mudam as pastas^).
echo            "all"/projetos chamam libs sozinhos se faltarem os DCUs.
echo      Com .dproj ao lado do .dpr usa MSBuild; senao usa dcc32/dcc64 no .dpr.
echo      Defina BDSROOT para usar outra instalacao do RAD Studio.
echo      Defina JVCS_CATALOG ^(GetIt^) e JVCS_EXTRA_PATH ^(outras libs^) se preciso.
echo      Opcional: JVCS_EXTRA_DEFS ^(defines extras em todos os projetos^).
endlocal & exit /b 0

:bad_what
echo [ERRO] Projeto invalido: "%BLD_WHAT%". Use: %ALL_PROJECTS%, libs ou all.
endlocal & exit /b 1

:bad_cfg
echo [ERRO] Configuracao invalida: "%BLD_CFG%". Use Debug ou Release.
endlocal & exit /b 1

:bad_plat
echo [ERRO] Plataforma invalida: "%BLD_PLAT%". Use Win32 ou Win64.
endlocal & exit /b 1

:no_rsvars
echo [ERRO] rsvars.bat nao encontrado em:
echo        "%BLD_RSVARS%"
echo        Verifique a instalacao do RAD Studio %BDSVER% ou defina BDSROOT
echo        com a pasta raiz correta (ex.: set BDSROOT=D:\Embarcadero\Studio\%BDSVER%).
endlocal & exit /b 1

:no_dcc
echo [ERRO] Compilador nao encontrado: "%BLD_DCC%"
endlocal & exit /b 1

:no_lib
echo [ERRO] Pasta de DCUs da RTL/VCL nao encontrada: "%BLD_LIBDIR%"
endlocal & exit /b 1
