@echo off
rem ==========================================================================
rem  copiar.bat - copia o setup da versao atual para a pasta de distribuicao
rem  e regrava o SHA256.txt dela (tools\copiar-setup.ps1).
rem
rem  Uso: copiar.bat [pasta]
rem       sem pasta: usa JVCS_COPIA_SETUP (instalador\config\distribuicao.bat)
rem ==========================================================================
setlocal
call "%~dp0_comum.bat" || exit /b 1
set "JI_DEST=%~1"
if not defined JI_DEST set "JI_DEST=%JVCS_COPIA_SETUP%"
if not defined JI_DEST (
    echo [ERRO] informe a pasta ^(copiar.bat ^<pasta^>^) ou configure instalador\config\distribuicao.bat
    endlocal & exit /b 1
)
if not exist "%JI_SETUP%" (
    echo [ERRO] setup nao encontrado: %JI_SETUP% ^(rode gerar.bat^)
    endlocal & exit /b 1
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%JI_TOOLS%\copiar-setup.ps1" -Setup "%JI_SETUP%" -Destino "%JI_DEST%"
set "JI_RC=%ERRORLEVEL%"
endlocal & exit /b %JI_RC%
