@echo off
rem ==========================================================================
rem  conferir.bat - mostra a versao (tools\versao.ini), a versao e a data dos
rem  binarios em bin\, o setup gerado com o SHA-256 e, se configurada, a copia
rem  na pasta de distribuicao. So le; nao muda nada.
rem
rem  Uso: conferir.bat
rem ==========================================================================
setlocal
call "%~dp0_comum.bat" || exit /b 1
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0conferir.ps1" -Root "%JI_ROOT%" -Setup "%JI_SETUP%" -Destino "%JVCS_COPIA_SETUP%"
set "JI_RC=%ERRORLEVEL%"
endlocal & exit /b %JI_RC%
