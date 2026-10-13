@echo off
rem ==========================================================================
rem  testar-dll.bat - harness da JvcsExternalDll.dll REAL, FORA da IDE
rem
rem  Uso:   testar-dll.bat [nova|original|ambas] [verbos]
rem         Padrao: ambas. verbos = indices separados por virgula (opcional;
rem         padrao: About, VCS Properties, Connect Server, Recent Projects,
rem         Project Manager - nenhum conecta ao servidor nem altera o arquivo).
rem
rem  nova     = bin\client\Win32\JvcsExternalDll.dll (tools\compilar.bat dll ...)
rem  original = 3rdparty\referencia-2.5.0.1030\JvcsExternalDll.dll (2.5.0.1030)
rem
rem  Compila JvcsDllHarness.dpr (host console com rtl;vcl;designide, usa o
rem  TJVCSDllBridge e as callbacks reais do expert) em dcu\Win32\dll-harness e
rem  executa uma copia do host em uma pasta por DLL, com o runtime
rem  (fvcscrypt.dll, zipdll.dll, unzdll.dll, htm_rep.htm, *.jvcs, *.chm).
rem  Saida: dcu\Win32\dll-harness\bin\<nova|original>\harness.txt
rem  Codigo de saida: 0 = OK; >0 = falhas.
rem ==========================================================================
setlocal EnableExtensions DisableDelayedExpansion

set "BDSVER=37.0"
for %%I in ("%~dp0..\..\..") do set "TST_ROOT=%%~fI"
for %%I in ("%~dp0.") do set "TST_SRC=%%~fI"
set "TST_EXPSRC=%TST_ROOT%\src\jvcsideexpert"
set "TST_OUT=%TST_ROOT%\dcu\Win32\dll-harness"
set "TST_BIN=%TST_OUT%\bin"
set "TST_3RD=%TST_ROOT%\3rdparty"
set "TST_3RDREF=%TST_ROOT%\3rdparty\referencia-2.5.0.1030"

set "TST_WHICH=%~1"
if not defined TST_WHICH set "TST_WHICH=ambas"
set "TST_VERBS=%~2"

set "TST_BDSDIR=%ProgramFiles(x86)%\Embarcadero\Studio\%BDSVER%"
if defined BDSROOT set "TST_BDSDIR=%BDSROOT:"=%"
if "%TST_BDSDIR:~-1%"=="\" set "TST_BDSDIR=%TST_BDSDIR:~0,-1%"
if not exist "%TST_BDSDIR%\bin\rsvars.bat" goto :no_rsvars
call "%TST_BDSDIR%\bin\rsvars.bat"
set "TST_DCC=%TST_BDSDIR%\bin\DCC32.EXE"
set "TST_LIB=%TST_BDSDIR%\lib\win32\release"

if not exist "%TST_OUT%\dcu" mkdir "%TST_OUT%\dcu"
if not exist "%TST_BIN%" mkdir "%TST_BIN%"
echo ---- JvcsDllHarness.dpr
"%TST_BDSDIR%\bin\brcc32.exe" -fo"%TST_OUT%\dcu\JvcsDllHarness.res" "%TST_SRC%\JvcsDllHarness.rc" >nul
if errorlevel 1 goto :build_fail_rc
pushd "%TST_SRC%"
"%TST_DCC%" --no-config -B -Q -$C+ -$R+ "-U%TST_LIB%;%TST_EXPSRC%" "-R%TST_OUT%\dcu" -NSWinapi;System.Win;System;Vcl;Xml -LUrtl;vcl;designide "-E%TST_BIN%" "-NU%TST_OUT%\dcu" JvcsDllHarness.dpr
if errorlevel 1 goto :build_fail
popd

set "TST_RC=0"
if /i "%TST_WHICH%"=="ambas" (
    call :run nova "%TST_ROOT%\bin\client\Win32"
    call :run original "%TST_3RDREF%"
) else if /i "%TST_WHICH%"=="nova" (
    call :run nova "%TST_ROOT%\bin\client\Win32"
) else if /i "%TST_WHICH%"=="original" (
    call :run original "%TST_3RDREF%"
) else (
    echo [ERRO] use nova, original ou ambas
    endlocal & exit /b 1
)
echo.
if "%TST_RC%"=="0" echo [OK] harness da JvcsExternalDll - saidas em %TST_BIN%
if not "%TST_RC%"=="0" echo [FALHOU] harness da JvcsExternalDll - %TST_RC% falha^(s^) - saidas em %TST_BIN%
endlocal & exit /b %TST_RC%

rem ---- :run NOME PASTA_DA_DLL --------------------------------------------------
:run
set "TST_D=%TST_BIN%\%~1"
if not exist "%~2\JvcsExternalDll.dll" (
    echo [FALHOU] %~1: "%~2\JvcsExternalDll.dll" nao existe
    set /a "TST_RC+=1"
    goto :eof
)
if not exist "%TST_D%" mkdir "%TST_D%"
copy /y "%TST_BIN%\JvcsDllHarness.exe" "%TST_D%\" >nul
copy /y "%~2\JvcsExternalDll.dll" "%TST_D%\" >nul
for %%F in (fvcscrypt.dll zipdll.dll unzdll.dll htm_rep.htm) do call :rt "%%F" "%TST_D%"
call :rt "*.jvcs" "%TST_D%"
call :rt "*.chm" "%TST_D%"
echo.
echo ==== %~1: %~2\JvcsExternalDll.dll ====
set "JVCS_EXPERT_LOG=%TST_D%\expert.log"
if exist "%JVCS_EXPERT_LOG%" del /q "%JVCS_EXPERT_LOG%"
"%TST_D%\JvcsDllHarness.exe" %TST_VERBS% >"%TST_D%\harness.txt" 2>&1
set "TST_R=%ERRORLEVEL%"
type "%TST_D%\harness.txt"
if not "%TST_R%"=="0" set /a "TST_RC+=TST_R"
goto :eof

:rt
if exist "%TST_3RD%\%~1" (copy /y "%TST_3RD%\%~1" "%~2\" >nul & goto :eof)
if exist "%TST_3RDREF%\%~1" copy /y "%TST_3RDREF%\%~1" "%~2\" >nul
goto :eof

:build_fail_rc
echo [FALHOU] brcc32 JvcsDllHarness.rc
endlocal & exit /b 1

:build_fail
popd
echo [FALHOU] compilacao do harness
endlocal & exit /b 1

:no_rsvars
echo [ERRO] rsvars.bat nao encontrado em "%TST_BDSDIR%\bin"
endlocal & exit /b 1
