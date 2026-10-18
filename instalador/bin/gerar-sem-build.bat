@echo off
rem ==========================================================================
rem  gerar-sem-build.bat - so empacota o que ja esta em bin\ (nao compila).
rem
rem  Use depois de compilar (tools\compilar.bat all Release Win32 e
rem  tools\compilar-expert.bat) ou quando so mudou o que nao e compilado
rem  (tools\ai, skills, textos do setup). As versoes dos binarios sao
rem  conferidas do mesmo jeito: precisam bater com tools\versao.ini.
rem
rem  Uso: gerar-sem-build.bat
rem ==========================================================================
setlocal
call "%~dp0_comum.bat" || exit /b 1
call "%JI_TOOLS%\gerar-instalador.bat" --sem-build
set "JI_RC=%ERRORLEVEL%"
if "%JI_RC%"=="0" call "%~dp0conferir.bat"
endlocal & exit /b %JI_RC%
