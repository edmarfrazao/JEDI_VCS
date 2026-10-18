@echo off
rem ==========================================================================
rem  _comum.bat - uso interno dos scripts de instalador\bin (chamado com CALL).
rem  Define JI_ROOT (raiz do repositorio), JI_TOOLS, JI_SETUPBASE e JI_SETUP
rem  (setup da versao de tools\versao.ini) e carrega a configuracao local
rem  instalador\config\distribuicao.bat, se existir (fora do git; ver
rem  instalador\config\distribuicao.exemplo.bat).
rem ==========================================================================
for %%I in ("%~dp0..\..") do set "JI_ROOT=%%~fI"
set "JI_TOOLS=%JI_ROOT%\tools"
if exist "%~dp0..\config\distribuicao.bat" call "%~dp0..\config\distribuicao.bat"
set "JI_SETUPBASE="
for /f "usebackq delims=" %%V in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%JI_TOOLS%\gerar-versao.ps1" -Mostrar SetupBase`) do set "JI_SETUPBASE=%%V"
if not defined JI_SETUPBASE (
    echo [ERRO] nao foi possivel ler tools\versao.ini ^(tools\gerar-versao.ps1 -Mostrar SetupBase^)
    exit /b 1
)
set "JI_SETUP=%JI_ROOT%\setup\Output\%JI_SETUPBASE%.exe"
exit /b 0
