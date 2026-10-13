@echo off
rem ==========================================================================
rem  testar-dll-interativo.bat - host INTERATIVO da JvcsExternalDll.dll NOVA
rem
rem  Uso:   testar-dll-interativo.bat [argumentos do JvcsDllInterativo.exe]
rem  Ex.:   testar-dll-interativo.bat -verbs "Connect Server,Project Manager" -stop %TEMP%\jvcs-stop.txt
rem         testar-dll-interativo.bat -style "C:\...\Redist\styles\vcl\WindowsModernDark.vsf" -verbs "Project Manager"
rem
rem  Compila JvcsDllInterativo.dpr (como o JvcsDllHarness: rtl;vcl;designide,
rem  TJVCSDllBridge e callbacks reais do expert), copia a DLL de
rem  bin\client\Win32 e o runtime para dcu\Win32\dll-harness\bin\interativo e
rem  executa. Uma janela "Fake IDE" (classe TAppBuilder) faz o papel do Delphi.
rem  Nao fecha janelas sozinho: o FINALIZE acontece quando o arquivo -stop
rem  existir, a Fake IDE for fechada ou o -timeout (s) acabar.
rem  Log de erros da DLL: %LOCALAPPDATA%\JEDI\JVCS\logs\jvcs-dll-AAAAMMDD.log
rem ==========================================================================
setlocal EnableExtensions DisableDelayedExpansion

set "BDSVER=37.0"
for %%I in ("%~dp0..\..\..") do set "TST_ROOT=%%~fI"
for %%I in ("%~dp0.") do set "TST_SRC=%%~fI"
set "TST_EXPSRC=%TST_ROOT%\src\jvcsideexpert"
set "TST_OUT=%TST_ROOT%\dcu\Win32\dll-harness"
set "TST_D=%TST_OUT%\bin\interativo"
set "TST_3RD=%TST_ROOT%\3rdparty"
set "TST_3RDREF=%TST_ROOT%\3rdparty\referencia-2.5.0.1030"

set "TST_BDSDIR=%ProgramFiles(x86)%\Embarcadero\Studio\%BDSVER%"
if defined BDSROOT set "TST_BDSDIR=%BDSROOT:"=%"
if "%TST_BDSDIR:~-1%"=="\" set "TST_BDSDIR=%TST_BDSDIR:~0,-1%"
if not exist "%TST_BDSDIR%\bin\rsvars.bat" goto :no_rsvars
call "%TST_BDSDIR%\bin\rsvars.bat"
set "TST_DCC=%TST_BDSDIR%\bin\DCC32.EXE"
set "TST_LIB=%TST_BDSDIR%\lib\win32\release"

if not exist "%TST_OUT%\dcu" mkdir "%TST_OUT%\dcu"
if not exist "%TST_D%" mkdir "%TST_D%"
echo ---- JvcsDllInterativo.dpr
"%TST_BDSDIR%\bin\brcc32.exe" -fo"%TST_OUT%\dcu\JvcsDllHarness.res" "%TST_SRC%\JvcsDllHarness.rc" >nul
if errorlevel 1 goto :build_fail_rc
pushd "%TST_SRC%"
"%TST_DCC%" --no-config -B -Q -$C+ -$R+ "-U%TST_LIB%;%TST_EXPSRC%" "-R%TST_OUT%\dcu" -NSWinapi;System.Win;System;Vcl;Xml -LUrtl;vcl;designide "-E%TST_D%" "-NU%TST_OUT%\dcu" JvcsDllInterativo.dpr
if errorlevel 1 goto :build_fail
popd

if not exist "%TST_ROOT%\bin\client\Win32\JvcsExternalDll.dll" goto :no_dll
copy /y "%TST_ROOT%\bin\client\Win32\JvcsExternalDll.dll" "%TST_D%\" >nul
if exist "%TST_ROOT%\bin\client\Win32\JvcsExternalDll.map" copy /y "%TST_ROOT%\bin\client\Win32\JvcsExternalDll.map" "%TST_D%\" >nul
for %%F in (fvcscrypt.dll zipdll.dll unzdll.dll htm_rep.htm) do call :rt "%%F"
call :rt "*.jvcs"
call :rt "*.chm"
set "JVCS_EXPERT_LOG=%TST_D%\expert.log"
if exist "%JVCS_EXPERT_LOG%" del /q "%JVCS_EXPERT_LOG%"
"%TST_D%\JvcsDllInterativo.exe" %*
set "TST_R=%ERRORLEVEL%"
endlocal & exit /b %TST_R%

:rt
if exist "%TST_3RD%\%~1" (copy /y "%TST_3RD%\%~1" "%TST_D%\" >nul & goto :eof)
if exist "%TST_3RDREF%\%~1" copy /y "%TST_3RDREF%\%~1" "%TST_D%\" >nul
goto :eof

:no_dll
echo [ERRO] bin\client\Win32\JvcsExternalDll.dll nao existe (tools\compilar.bat dll)
endlocal & exit /b 1

:build_fail_rc
echo [FALHOU] brcc32 JvcsDllHarness.rc
endlocal & exit /b 1

:build_fail
popd
echo [FALHOU] compilacao do JvcsDllInterativo
endlocal & exit /b 1

:no_rsvars
echo [ERRO] rsvars.bat nao encontrado em "%TST_BDSDIR%\bin"
endlocal & exit /b 1
