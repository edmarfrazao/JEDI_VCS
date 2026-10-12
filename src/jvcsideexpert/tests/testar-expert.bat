@echo off
rem ==========================================================================
rem  testar-expert.bat - teste de fumaca do expert FORA da IDE
rem
rem  Uso:   testar-expert.bat
rem         (rode antes tools\compilar-expert.bat - usa a DLL de bin\ideclient\Win32)
rem
rem  Compila FakeJvcsExternalDll.dpr (JvcsExternalDll FALSA, mesma ABI) e
rem  JvcsExpertSmokeTest.dpr (host console com runtime packages rtl;vcl;designide)
rem  em dcu\Win32\expert-test e executa o host. NAO executa a IDE nem nenhum
rem  binario do JEDI VCS.
rem
rem  Variavel opcional: BDSROOT (como em tools\compilar-expert.bat).
rem  Codigo de saida: 0 = todos os testes OK; >0 = numero de falhas.
rem ==========================================================================
setlocal EnableExtensions DisableDelayedExpansion

set "BDSVER=37.0"
for %%I in ("%~dp0..\..\..") do set "TST_ROOT=%%~fI"
for %%I in ("%~dp0.") do set "TST_SRC=%%~fI"
set "TST_EXPSRC=%TST_ROOT%\src\jvcsideexpert"
set "TST_OUT=%TST_ROOT%\dcu\Win32\expert-test"
set "TST_BIN=%TST_OUT%\bin"

set "TST_BDSDIR=%ProgramFiles(x86)%\Embarcadero\Studio\%BDSVER%"
if defined BDSROOT set "TST_BDSDIR=%BDSROOT:"=%"
if "%TST_BDSDIR:~-1%"=="\" set "TST_BDSDIR=%TST_BDSDIR:~0,-1%"
if defined BDSROOT for %%I in ("%TST_BDSDIR%") do call :ver_from_leaf "%%~nxI"
for /f "delims=." %%V in ("%BDSVER%") do set "TST_BDSNUM=%%V"
set "TST_EXPERT=JvcsExpertBDS%TST_BDSNUM%.dll"

if not exist "%TST_BDSDIR%\bin\rsvars.bat" goto :no_rsvars
call "%TST_BDSDIR%\bin\rsvars.bat"
set "TST_DCC=%TST_BDSDIR%\bin\DCC32.EXE"
set "TST_LIB=%TST_BDSDIR%\lib\win32\release"
if not exist "%TST_ROOT%\bin\ideclient\Win32\%TST_EXPERT%" goto :no_expert

if not exist "%TST_BIN%\a" mkdir "%TST_BIN%\a"
if not exist "%TST_BIN%\b" mkdir "%TST_BIN%\b"
if not exist "%TST_OUT%\dcu_fake" mkdir "%TST_OUT%\dcu_fake"
if not exist "%TST_OUT%\dcu_host" mkdir "%TST_OUT%\dcu_host"

echo ---- FakeJvcsExternalDll.dpr
pushd "%TST_SRC%"
"%TST_DCC%" --no-config -B -Q "-U%TST_LIB%;%TST_EXPSRC%" -NSWinapi;System.Win;System "-E%TST_BIN%" "-NU%TST_OUT%\dcu_fake" FakeJvcsExternalDll.dpr
if errorlevel 1 goto :build_fail
echo ---- JvcsExpertSmokeTest.dpr
rem  -U src\common + -I abi-stub: teste F compila a JVCSIDEInterfaceCommon.pas ORIGINAL
"%TST_DCC%" --no-config -B -Q -$C+ -$R+ -$Q+ "-U%TST_LIB%;%TST_EXPSRC%;%TST_ROOT%\src\common" "-I%TST_SRC%\abi-stub" -NSWinapi;System.Win;System;Vcl;Xml -LUrtl;vcl;designide "-E%TST_BIN%" "-NU%TST_OUT%\dcu_host" JvcsExpertSmokeTest.dpr
if errorlevel 1 goto :build_fail
popd

rem  pasta do host: DLL falsa (teste B); a\: expert + DLL falsa (teste A); b\: so o expert (teste D)
copy /y "%TST_BIN%\FakeJvcsExternalDll.dll" "%TST_BIN%\JvcsExternalDll.dll" >nul
copy /y "%TST_BIN%\FakeJvcsExternalDll.dll" "%TST_BIN%\a\JvcsExternalDll.dll" >nul
copy /y "%TST_ROOT%\bin\ideclient\Win32\%TST_EXPERT%" "%TST_BIN%\a\" >nul
copy /y "%TST_ROOT%\bin\ideclient\Win32\%TST_EXPERT%" "%TST_BIN%\b\" >nul
if exist "%TST_BIN%\b\JvcsExternalDll.dll" del /q "%TST_BIN%\b\JvcsExternalDll.dll"

echo ---- executando JvcsExpertSmokeTest %TST_EXPERT%
set "JVCS_EXPERT_LOG=%TST_BIN%\expert.log"
rem  testes A/B/D sem adiamento do INIT (independe de ShowLoad no registro);
rem  o teste E liga o adiamento no proprio processo
set "JVCS_EXPERT_DEFERINIT=off"
if exist "%JVCS_EXPERT_LOG%" del /q "%JVCS_EXPERT_LOG%"
"%TST_BIN%\JvcsExpertSmokeTest.exe" "%TST_EXPERT%"
set "TST_RC=%ERRORLEVEL%"
echo.
if "%TST_RC%"=="0" echo [OK] teste de fumaca do expert - logs em %TST_BIN%
if not "%TST_RC%"=="0" echo [FALHOU] teste de fumaca do expert - %TST_RC% falha^(s^) - logs em %TST_BIN%
endlocal & exit /b %TST_RC%

:ver_from_leaf
echo %~1| findstr /r /x "[0-9][0-9]*\.[0-9][0-9]*" >nul && set "BDSVER=%~1"
goto :eof

:build_fail
popd
echo [FALHOU] compilacao do teste
endlocal & exit /b 1

:no_rsvars
echo [ERRO] rsvars.bat nao encontrado em "%TST_BDSDIR%\bin"
endlocal & exit /b 1

:no_expert
echo [ERRO] "%TST_ROOT%\bin\ideclient\Win32\%TST_EXPERT%" nao existe - rode antes tools\compilar-expert.bat
endlocal & exit /b 1
