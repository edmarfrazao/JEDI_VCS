@echo off
rem ==========================================================================
rem  compilar.bat - Compila os projetos do JEDI VCS v2026
rem
rem  Uso:   compilar.bat [exe, dll, diff, console ou all] [Debug ou Release] [Win32 ou Win64]
rem         Padrao: all Debug Win32
rem
rem  Se existir PROJETO.dproj ao lado do .dpr, usa MSBuild (como o build.bat
rem  modelo). Senao, chama dcc32 (Win32) ou dcc64 (Win64) direto no .dpr, com
rem  os defines e caminhos da tabela abaixo (portados dos .dof do Delphi 7).
rem
rem  Variaveis de ambiente opcionais:
rem    BDSROOT         = pasta raiz do RAD Studio (sobrescreve o caminho padrao
rem                      ProgramFiles(x86)\Embarcadero\Studio\BDSVER)
rem    JVCS_CATALOG    = pasta CatalogRepository do GetIt (JCL, JVCL, ICS, SynEdit, VTV,
rem                      Abbrevia; padrao: USERPROFILE\Documents\Embarcadero\Studio\BDSVER\CatalogRepository)
rem    JCL_PATH, JVCL_PATH, ICS_PATH, SYNEDIT_PATH, VTV_PATH, ABBREVIA_PATH = DCUs de cada
rem                      biblioteca (e *_INC = fontes/includes); substituem o padrao.
rem    JVCS_EXTRA_DEFS = defines extras (separados por ponto e virgula) para todos os projetos
rem    JVCS_EXTRA_PATH = caminhos ABSOLUTOS (separados por ponto e virgula) de
rem                      de outras bibliotecas (as acima ja entram por padrao).
rem                      Acrescentados a -U, -I e -R (so no modo dcc).
rem
rem  Gera um log por projeto: tools\logs\compilar_PROJ_PLATAFORMA_CONFIG.log
rem  Codigo de saida: 0 = tudo OK; diferente de zero = alguma falha.
rem ==========================================================================
setlocal EnableExtensions DisableDelayedExpansion

rem ---- Configuracao geral (ajuste aqui) -------------------------------------
set "BDSVER=37.0"
set "BLD_CODEPAGE=1252"
set "BLD_MAXERR=3"
set "BLD_ALIASES=WinTypes=Windows;WinProcs=Windows;DbiTypes=BDE;DbiProcs=BDE;DbiErrs=BDE"
set "BLD_NS=Winapi;System.Win;Data.Win;Datasnap.Win;Web.Win;Soap.Win;Xml.Win;Bde;System;Data;Datasnap;Web;Soap;Xml;Vcl;Vcl.Imaging;Vcl.Touch;Vcl.Samples;Vcl.Shell"

rem ---- Caminhos de busca comuns (relativos a pasta do .dpr) -----------------
rem  Usados em -U, -I e -R. NAO incluir src\comp\_legacy (so referencia).
set "BLD_BASEPATH=..\common;..\common\client;..\comp\midware;..\comp\textdiff;..\comp\mdmailslot;..\comp\crc;..\comp\mwtools"

rem ---- Bibliotecas de terceiros instaladas via GetIt (CatalogRepository) ----
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
set "JVCS_SYNEDIT_REL=SynEdit-13\2025.03"
set "JVCS_VTV_REL=VirtualTreeview_by_JamSoftware-13\8.3"
set "JVCS_ABBREVIA_REL=Abbrevia-13\2026.10"
rem  Cada biblioteca tem uma variavel de DCUs (JCL_PATH, JVCL_PATH, ICS_PATH,
rem  SYNEDIT_PATH, VTV_PATH, ABBREVIA_PATH) e uma de fontes/includes (JCL_INC,
rem  JVCL_INC, ICS_INC, SYNEDIT_INC, VTV_INC, ABBREVIA_INC). Se definidas no
rem  ambiente, substituem o padrao.

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
set "PRJ_exe_DEFINES=USECLIENTDISPATCHER;LANGUAGE"
set "PRJ_exe_PATH="

set "PRJ_dll_DIR=src\jedivcs"
set "PRJ_dll_NAME=JediVCSDLL"
set "PRJ_dll_DEFINES=IDEDLL;EXT_IDE_INTF;LANGUAGE;DelphiPersonalEdition"
set "PRJ_dll_PATH="

set "PRJ_diff_DIR=src\jedivcsdiff"
set "PRJ_diff_NAME=JEDIVCSDiff"
set "PRJ_diff_DEFINES=LANGUAGE;DelphiPersonalEdition"
set "PRJ_diff_PATH=..\jedivcs"

set "PRJ_console_DIR=src\jvcs"
set "PRJ_console_NAME=jvcs"
set "PRJ_console_DEFINES=DelphiPersonalEdition"
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

set "BLD_TARGETS="
if /i "%BLD_WHAT%"=="all" (
    set "BLD_TARGETS=%ALL_PROJECTS%"
) else (
    for %%P in (%ALL_PROJECTS%) do if /i "%%P"=="%BLD_WHAT%" set "BLD_TARGETS=%%P"
)
if not defined BLD_TARGETS goto :bad_what

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
set "BLD_BDSDIR=%ProgramFiles(x86)%\Embarcadero\Studio\%BDSVER%"
if defined BDSROOT set "BLD_BDSDIR=%BDSROOT:"=%"
if "%BLD_BDSDIR:~-1%"=="\" set "BLD_BDSDIR=%BLD_BDSDIR:~0,-1%"
set "BLD_RSVARS=%BLD_BDSDIR%\bin\rsvars.bat"
if not exist "%BLD_RSVARS%" goto :no_rsvars
call "%BLD_RSVARS%"
set "BLD_DCC=%BLD_BDSDIR%\bin\%BLD_DCCEXE%"
if not exist "%BLD_DCC%" goto :no_dcc
set "BLD_LIBDIR=%BLD_BDSDIR%\lib\%BLD_LIBPLAT%\%BLD_LIBCFG%"
if not exist "%BLD_LIBDIR%" goto :no_lib

rem ---- Bibliotecas de terceiros (CatalogRepository) - monta as listas -------
if "%JVCS_CATALOG:~-1%"=="\" set "JVCS_CATALOG=%JVCS_CATALOG:~0,-1%"
for /f "delims=." %%V in ("%BDSVER%") do set "BLD_DVER=%%V"
set "BLD_JCLDIR=%JVCS_CATALOG%\%JVCS_JCL_REL%"
set "BLD_JVCLDIR=%JVCS_CATALOG%\%JVCS_JVCL_REL%"
set "BLD_ICSDIR=%JVCS_CATALOG%\%JVCS_ICS_REL%"
set "BLD_SYNDIR=%JVCS_CATALOG%\%JVCS_SYNEDIT_REL%"
set "BLD_VTVDIR=%JVCS_CATALOG%\%JVCS_VTV_REL%"
set "BLD_ABBDIR=%JVCS_CATALOG%\%JVCS_ABBREVIA_REL%"
if not defined JCL_PATH set "JCL_PATH=%BLD_JCLDIR%\lib\d%BLD_DVER%\%BLD_LIBPLAT%"
if not defined JCL_INC set "JCL_INC=%BLD_JCLDIR%\source\include;%BLD_JCLDIR%\source\include\jedi"
if not defined JVCL_PATH set "JVCL_PATH=%BLD_JVCLDIR%\lib\D%BLD_DVER%\%BLD_LIBPLAT%"
if not defined JVCL_INC set "JVCL_INC=%BLD_JVCLDIR%\common;%BLD_JVCLDIR%\Resources"
if not defined ICS_PATH set "ICS_PATH=%BLD_ICSDIR%\Lib\%BLD_CFG%\%BLD_PLAT%\%BDSVER%"
if not defined ICS_INC set "ICS_INC=%BLD_ICSDIR%\Source\Include;%BLD_ICSDIR%\Source"
if not defined SYNEDIT_PATH set "SYNEDIT_PATH=%BLD_SYNDIR%\Packages\11AndAbove\Delphi\%BLD_PLAT%\%BLD_CFG%"
if not defined SYNEDIT_INC set "SYNEDIT_INC=%BLD_SYNDIR%\Source;%BLD_SYNDIR%\Source\Highlighters"
if not defined VTV_PATH set "VTV_PATH=%BLD_VTVDIR%\Packages\RAD Studio 10.4+\%BLD_PLAT%\%BLD_CFG%"
if not defined VTV_INC set "VTV_INC=%BLD_VTVDIR%\Source"
if not defined ABBREVIA_PATH set "ABBREVIA_PATH=%BLD_ABBDIR%\packages\11AndAbove\Delphi\%BLD_PLAT%\%BLD_CFG%"
if not defined ABBREVIA_INC set "ABBREVIA_INC=%BLD_ABBDIR%\source"
set "BLD_LIB_U=%JCL_PATH%;%JVCL_PATH%;%ICS_PATH%;%SYNEDIT_PATH%;%VTV_PATH%;%ABBREVIA_PATH%"
set "BLD_LIB_I=%JCL_INC%;%JVCL_INC%;%ICS_INC%;%SYNEDIT_INC%;%VTV_INC%;%ABBREVIA_INC%"
rem  O -R tambem precisa da pasta release da RTL/VCL (ex.: controls.res so existe la).
set "BLD_RELDIR=%BLD_BDSDIR%\lib\%BLD_LIBPLAT%\release"

rem ---- Pastas do projeto e dos logs -----------------------------------------
for %%I in ("%~dp0..") do set "BLD_ROOT=%%~fI"
for %%I in ("%~dp0.") do set "BLD_TOOLS=%%~fI"
set "BLD_LOGDIR=%BLD_TOOLS%\logs"
if not exist "%BLD_LOGDIR%" mkdir "%BLD_LOGDIR%"
call :norm_extra

echo Raiz    : %BLD_ROOT%
echo Delphi  : %BLD_BDSDIR%
echo Config  : %BLD_CFG% %BLD_PLAT% ^(compilador: %BLD_DCCEXE%^)
echo Alvos   : %BLD_TARGETS%
echo Catalog : %JVCS_CATALOG%
echo Libs    : JCL, JVCL, ICS, SynEdit, VTV, Abbrevia ^(DCUs de %BLD_CFG% %BLD_PLAT%^)
call :chkdir JCL "%JCL_PATH%"
call :chkdir JVCL "%JVCL_PATH%"
call :chkdir ICS "%ICS_PATH%"
call :chkdir SynEdit "%SYNEDIT_PATH%"
call :chkdir VTV "%VTV_PATH%"
call :chkdir Abbrevia "%ABBREVIA_PATH%"
if defined BLD_EXTRA echo Extra   : %BLD_EXTRA%

rem ---- Compilacao -----------------------------------------------------------
set "BLD_RESULT=0"
set "BLD_NOK=0"
set "BLD_NFAIL=0"
for %%K in (%BLD_TARGETS%) do call :build_one %%K

echo.
echo ==== Resumo: %BLD_CFG% %BLD_PLAT% ====
for %%K in (%BLD_TARGETS%) do call :sumline %%K
echo.
if "%BLD_RESULT%"=="0" echo Compilacao concluida sem erros - %BLD_NOK% projeto^(s^) OK.
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
set "BLD_DCUOUT=..\..\dcu\%BLD_PLAT%\%BLD_CFG%"

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
echo Uso: %~nx0 [exe^|dll^|diff^|console^|all] [Debug^|Release] [Win32^|Win64]
echo      Padrao: all Debug Win32. Projetos: %ALL_PROJECTS%
echo      Com .dproj ao lado do .dpr usa MSBuild; senao usa dcc32/dcc64 no .dpr.
echo      Defina BDSROOT para usar outra instalacao do RAD Studio.
echo      Defina JVCS_CATALOG ^(GetIt^) e JVCS_EXTRA_PATH ^(outras libs^) se preciso.
echo      Opcional: JVCS_EXTRA_DEFS ^(defines extras em todos os projetos^).
endlocal & exit /b 0

:bad_what
echo [ERRO] Projeto invalido: "%BLD_WHAT%". Use: %ALL_PROJECTS% ou all.
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
