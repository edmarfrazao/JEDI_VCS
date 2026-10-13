@echo off
rem ==========================================================================
rem  gerar-instalador.bat - Gera o instalador do JEDI VCS 2.5 Beta 2026
rem
rem  Uso:   gerar-instalador.bat [--sem-build]
rem
rem  Padrao: compila Release Win32 de todos os alvos e empacota:
rem    tools\compilar.bat exe     Release Win32
rem    tools\compilar.bat dll     Release Win32
rem    tools\compilar.bat diff    Release Win32
rem    tools\compilar.bat console Release Win32
rem    tools\compilar-expert.bat  Release nova   (expert + DLL nova em bin\ideclient\Win32)
rem    tools\compilar-expert.bat  /bds:22|23 Release nova  (so se o Delphi 11/12 estiver
rem                               instalado; senao vai o JvcsExpertBDS22/23.dll que ja
rem                               existir em bin\ideclient\Win32, se existir)
rem  Cada JvcsExpertBDS<nn>.dll e conferido com tools\verificar-expert.ps1: so pode
rem  importar rtl/vcl/xmlrtl e todos os simbolos tem de existir nos .bpl da versao.
rem  --sem-build: so empacota o que ja esta em bin\ (nao compila nada).
rem
rem  Depois confere que os binarios esperados existem e tem FileVersion
rem  2.5.0.2026 e roda o ISCC (Inno Setup 6) em setup\JediVCS2026.iss.
rem  Saida: setup\Output\JediVCS-2.5-Beta2026-Setup.exe
rem
rem  Variaveis de ambiente opcionais:
rem    JVCS_ISCC = caminho do ISCC.exe (padrao: ..\..\ferramentas\InnoSetup6\ISCC.exe,
rem                depois ProgramFiles(x86)\Inno Setup 6\ISCC.exe)
rem
rem  Log: tools\logs\gerar-instalador.log
rem  Codigo de saida: 0 = OK; 1 = falha de compilacao, de verificacao ou do ISCC.
rem ==========================================================================
setlocal EnableExtensions DisableDelayedExpansion

set "GI_VERSION=2.5.0.2026"

for %%I in ("%~dp0..") do set "GI_ROOT=%%~fI"
for %%I in ("%~dp0.") do set "GI_TOOLS=%%~fI"
set "GI_LOGDIR=%GI_TOOLS%\logs"
set "GI_LOG=%GI_LOGDIR%\gerar-instalador.log"
set "GI_ISS=%GI_ROOT%\setup\JediVCS2026.iss"
set "GI_OUT=%GI_ROOT%\setup\Output\JediVCS-2.5-Beta2026-Setup.exe"
set "GI_CLIENT=%GI_ROOT%\bin\client\Win32"
set "GI_IDE=%GI_ROOT%\bin\ideclient\Win32"
set "GI_RT=%GI_ROOT%\3rdparty"
rem  versoes do Delphi alem do 13 cujos experts sao compilados, se instaladas
set "GI_OTHERVERS=22 23"

rem ---- Parametros -----------------------------------------------------------
set "GI_BUILD=1"
:args
if "%~1"=="" goto :args_done
if /i "%~1"=="--sem-build" (
    set "GI_BUILD=0"
) else if "%~1"=="/?" (
    goto :usage
) else if /i "%~1"=="-h" (
    goto :usage
) else if /i "%~1"=="--help" (
    goto :usage
) else (
    echo [ERRO] Parametro desconhecido: %1
    goto :usage_err
)
shift
goto :args
:args_done

rem ---- ISCC -----------------------------------------------------------------
set "GI_ISCC="
if defined JVCS_ISCC set "GI_ISCC=%JVCS_ISCC:"=%"
if not defined GI_ISCC for %%I in ("%GI_ROOT%\..\ferramentas\InnoSetup6\ISCC.exe") do if exist "%%~fI" set "GI_ISCC=%%~fI"
if not defined GI_ISCC if exist "%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe" set "GI_ISCC=%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
if not defined GI_ISCC goto :no_iscc
if not exist "%GI_ISCC%" goto :no_iscc

if not exist "%GI_LOGDIR%" mkdir "%GI_LOGDIR%"
>"%GI_LOG%" echo # gerar-instalador.bat - %DATE% %TIME%
>>"%GI_LOG%" echo # Raiz : %GI_ROOT%
>>"%GI_LOG%" echo # ISCC : %GI_ISCC%
>>"%GI_LOG%" echo # Build: %GI_BUILD% ^(0 = --sem-build^)

echo Raiz  : %GI_ROOT%
echo ISCC  : %GI_ISCC%
echo Log   : %GI_LOG%

rem ---- 1) Compilacao Release Win32 -------------------------------------------
if "%GI_BUILD%"=="0" (
    echo.
    echo ==== Compilacao: pulada ^(--sem-build^) ====
    >>"%GI_LOG%" echo [INFO] compilacao pulada ^(--sem-build^)
    goto :verify
)
echo.
echo ==== Compilacao Release Win32 ====
call :build "%GI_TOOLS%\compilar.bat" exe Release Win32 || goto :build_fail
call :build "%GI_TOOLS%\compilar.bat" dll Release Win32 || goto :build_fail
call :build "%GI_TOOLS%\compilar.bat" diff Release Win32 || goto :build_fail
call :build "%GI_TOOLS%\compilar.bat" console Release Win32 || goto :build_fail
call :build "%GI_TOOLS%\compilar-expert.bat" Release nova || goto :build_fail
rem  experts das outras versoes do Delphi: so as INSTALADAS (tools\versoes.ini)
for %%V in (%GI_OTHERVERS%) do call :build_other %%V || goto :build_fail

rem ---- 2) Verificacao dos binarios -------------------------------------------
:verify
echo.
echo ==== Verificacao dos binarios ====
set "GI_FAIL=0"
call :check_ver "%GI_CLIENT%\Jedivcs.exe"
call :check_ver "%GI_CLIENT%\JEDIVCSDiff.exe"
call :check_ver "%GI_CLIENT%\jvcs.exe"
call :check_ver "%GI_IDE%\JvcsExternalDll.dll"
set "GI_NEXP=0"
for %%E in (22 23 37) do call :check_expert %%E
if "%GI_NEXP%"=="0" (
    call :log "[FALHOU] nenhum JvcsExpertBDS22/23/37.dll em %GI_IDE%"
    set "GI_FAIL=1"
)
for %%F in (fvcscrypt.dll jedivcs.chm jedivcsdiff.chm htm_rep.htm ffdef.jvcs ulist.jvcs vcllist.jvcs vcllistbcb.jvcs verinf.jvcs) do call :check_file "%GI_RT%\%%F"
call :check_file "%GI_ROOT%\tools\ai\jvcs-ai.ps1"
call :check_file "%GI_ROOT%\doc\original\license.txt"
if exist "%GI_CLIENT%\Jedivcs.map" (call :log "[OK] Jedivcs.map presente (componente .map)") else (call :log "[AVISO] Jedivcs.map ausente: o componente .map vai sem ele")
if exist "%GI_IDE%\JvcsExternalDll.map" (call :log "[OK] JvcsExternalDll.map presente (componente .map)") else (call :log "[AVISO] JvcsExternalDll.map ausente: o componente .map vai sem ele")

rem  avisos: Debug mais novo que Release e DLL do expert diferente da de bin\client
for %%T in (exe dll diff console) do call :check_cfg %%T
call :check_samedll

if "%GI_FAIL%"=="1" goto :verify_fail

rem ---- 3) ISCC ----------------------------------------------------------------
echo.
echo ==== ISCC ====
>>"%GI_LOG%" echo.
>>"%GI_LOG%" echo ---- ISCC "%GI_ISS%"
"%GI_ISCC%" "%GI_ISS%" >>"%GI_LOG%" 2>&1
if errorlevel 1 goto :iscc_fail
if not exist "%GI_OUT%" goto :iscc_fail
for %%F in ("%GI_OUT%") do set "GI_SIZE=%%~zF"
call :log "[OK] instalador gerado: %GI_OUT% (%GI_SIZE% bytes)"
echo.
echo Pronto. Para instalar: execute o setup ^(feche o Delphi antes^). Veja setup\LEIAME.md.
endlocal & exit /b 0

rem ==========================================================================
rem  :build_other BDS  - compila o expert da versao BDS (22, 23) se instalada
rem ==========================================================================
:build_other
call "%GI_TOOLS%\versao-delphi.bat" %~1
if errorlevel 1 (
    call :log "[AVISO] versao %~1: %VD_ERR%"
    exit /b 0
)
if not "%VD_INSTALLED%"=="1" (
    call :log "[INFO] %VD_NAME% nao instalado: JvcsExpertBDS%~1.dll nao compilado (o pacote leva o que ja existir em bin\ideclient\Win32)"
    exit /b 0
)
call :build "%GI_TOOLS%\compilar-expert.bat" /bds:%~1 Release nova
exit /b %ERRORLEVEL%

rem ==========================================================================
rem  :check_expert BDS  - expert existe: versao, PE e simbolos (so rtl/vcl/xmlrtl)
rem ==========================================================================
:check_expert
set "GI_EXP=%GI_IDE%\JvcsExpertBDS%~1.dll"
if not exist "%GI_EXP%" goto :eof
set /a GI_NEXP+=1
call :check_ver "%GI_EXP%"
set "GI_BPLDIR=%ProgramFiles(x86)%\Embarcadero\Studio\%~1.0\bin"
if not exist "%GI_BPLDIR%" (
    call :log "[AVISO] JvcsExpertBDS%~1.dll: BDS %~1.0 nao instalado aqui - simbolos nao conferidos"
    goto :eof
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%GI_TOOLS%\verificar-expert.ps1" -Expert "%GI_EXP%" -BplDir "%GI_BPLDIR%" -Permitidos rtl,vcl,xmlrtl >>"%GI_LOG%" 2>&1
if errorlevel 1 (
    call :log "[FALHOU] JvcsExpertBDS%~1.dll: imports nao resolvidos ou pacote nao permitido (veja o log)"
    set "GI_FAIL=1"
) else (
    call :log "[OK] JvcsExpertBDS%~1.dll: imports so de rtl/vcl/xmlrtl, todos resolvidos"
)
goto :eof

rem ==========================================================================
rem  :build SCRIPT ARGS...  - chama um script de compilacao e registra no log
rem ==========================================================================
:build
>>"%GI_LOG%" echo [BUILD] %~nx1 %2 %3 %4
call %*
set "GI_RC=%ERRORLEVEL%"
if not "%GI_RC%"=="0" (
    call :log "[FALHOU] %~nx1 %2 %3 %4 - codigo %GI_RC%"
    exit /b 1
)
call :log "[OK] %~nx1 %2 %3 %4"
exit /b 0

rem ---- :check_file ARQUIVO -----------------------------------------------------
:check_file
if exist "%~1" (
    call :log "[OK] %~1"
) else (
    call :log "[FALHOU] nao encontrado: %~1"
    set "GI_FAIL=1"
)
goto :eof

rem ---- :check_ver ARQUIVO  - existe e FileVersion numerico = GI_VERSION -------
:check_ver
if not exist "%~1" (
    call :log "[FALHOU] nao encontrado: %~1"
    set "GI_FAIL=1"
    goto :eof
)
set "GI_FV="
for /f "usebackq delims=" %%V in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "$v=(Get-Item -LiteralPath '%~1').VersionInfo; '{0}.{1}.{2}.{3}' -f $v.FileMajorPart,$v.FileMinorPart,$v.FileBuildPart,$v.FilePrivatePart"`) do set "GI_FV=%%V"
if "%GI_FV%"=="%GI_VERSION%" (
    call :log "[OK] %~nx1 %GI_FV% (%~z1 bytes)"
) else (
    call :log "[FALHOU] %~nx1 tem versao %GI_FV%, esperada %GI_VERSION%: %~1"
    set "GI_FAIL=1"
)
goto :eof

rem ---- :check_cfg ALVO  - avisa se o ultimo build do alvo foi Debug -----------
:check_cfg
set "GI_LD=%GI_LOGDIR%\compilar_%~1_Win32_Debug.log"
set "GI_LR=%GI_LOGDIR%\compilar_%~1_Win32_Release.log"
if not exist "%GI_LR%" (
    call :log "[AVISO] %~1: sem log Release (compilar_%~1_Win32_Release.log); confira se bin\ tem build Release"
    goto :eof
)
if not exist "%GI_LD%" goto :eof
set "GI_NEWER="
for /f "usebackq delims=" %%N in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "if ((Get-Item -LiteralPath '%GI_LD%').LastWriteTime -gt (Get-Item -LiteralPath '%GI_LR%').LastWriteTime) { 'debug' }"`) do set "GI_NEWER=%%N"
if "%GI_NEWER%"=="debug" call :log "[AVISO] %~1: o ultimo build foi Debug (log Debug mais novo que o Release); bin\ pode ter binario Debug"
goto :eof

rem ---- :check_samedll  - a DLL do expert e a mesma de bin\client? -------------
:check_samedll
if not exist "%GI_CLIENT%\JvcsExternalDll.dll" goto :eof
fc /b "%GI_CLIENT%\JvcsExternalDll.dll" "%GI_IDE%\JvcsExternalDll.dll" >nul 2>&1
if errorlevel 1 (
    call :log "[AVISO] bin\ideclient\Win32\JvcsExternalDll.dll difere da de bin\client\Win32 - o pacote usa a de bin\ideclient (rode compilar-expert.bat Release nova para alinhar)"
) else (
    call :log "[OK] JvcsExternalDll.dll de bin\ideclient igual a de bin\client"
)
goto :eof

rem ---- :log TEXTO  - mostra e grava no log -----------------------------------
:log
echo %~1
>>"%GI_LOG%" echo %~1
goto :eof

rem ---- Mensagens de uso/erro ------------------------------------------------
:usage
echo Uso: %~nx0 [--sem-build]
echo      Padrao: compila Release Win32 ^(exe, dll, diff, console e expert^) e gera
echo      setup\Output\JediVCS-2.5-Beta2026-Setup.exe. --sem-build so empacota bin\.
endlocal & exit /b 0

:usage_err
echo Uso: %~nx0 [--sem-build]
endlocal & exit /b 1

:no_iscc
echo [ERRO] ISCC.exe ^(Inno Setup 6^) nao encontrado. Defina JVCS_ISCC com o caminho.
endlocal & exit /b 1

:build_fail
echo [FALHOU] compilacao - instalador NAO gerado ^(veja os logs em %GI_LOGDIR%^)
endlocal & exit /b 1

:verify_fail
echo [FALHOU] verificacao dos binarios - instalador NAO gerado ^(log: %GI_LOG%^)
endlocal & exit /b 1

:iscc_fail
echo [FALHOU] ISCC - instalador NAO gerado. Ultimas linhas do log:
powershell -NoProfile -Command "Get-Content -LiteralPath '%GI_LOG%' -Tail 15"
endlocal & exit /b 1
