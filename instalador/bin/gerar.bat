@echo off
rem ==========================================================================
rem  gerar.bat - gera o instalador completo do JEDI VCS 2.5 Beta 2026.
rem
rem  Compila Release Win32 (Jedivcs.exe, JvcsExternalDll.dll, JEDIVCSDiff.exe,
rem  jvcs.exe e os experts dos Delphi instalados), confere as versoes e
rem  empacota com o Inno Setup (tools\gerar-instalador.bat). Se a pasta de
rem  distribuicao estiver configurada (instalador\config\distribuicao.bat),
rem  copia o setup para la com o SHA256.txt atualizado. No fim, mostra a
rem  conferencia (conferir.bat).
rem
rem  Uso: gerar.bat            (feche o Delphi antes)
rem  Saida: setup\Output\JediVCS-2.5.0-Beta<N>-build<Build>-Setup.exe
rem  Codigo de saida: 0 = ok; 1 = falha (veja tools\logs\gerar-instalador.log)
rem ==========================================================================
setlocal
call "%~dp0_comum.bat" || exit /b 1
call "%JI_TOOLS%\gerar-instalador.bat" %*
set "JI_RC=%ERRORLEVEL%"
if "%JI_RC%"=="0" call "%~dp0conferir.bat"
endlocal & exit /b %JI_RC%
