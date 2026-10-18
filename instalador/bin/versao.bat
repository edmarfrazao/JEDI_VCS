@echo off
rem ==========================================================================
rem  versao.bat - mostra ou muda a versao em tools\versao.ini (fonte unica).
rem
rem  Uso: versao.bat                  mostra Build, Stage e StageNumber
rem       versao.bat <build>          muda o Build (ex.: 2062 = 2a correcao da beta 6)
rem       versao.bat <build> <beta>   muda o Build e o numero da beta (ex.: 2070 7)
rem  Regra (doc\pt\common\Versoes.md): beta N = 2000 + N*10; correcao = +1.
rem  Depois de mudar, gere de novo com gerar.bat (a versao entra nos binarios).
rem ==========================================================================
setlocal
call "%~dp0_comum.bat" || exit /b 1
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0versao.ps1" -Ini "%JI_TOOLS%\versao.ini" -Build "%~1" -Beta "%~2"
set "JI_RC=%ERRORLEVEL%"
endlocal & exit /b %JI_RC%
