@echo off
rem Roda os testes de tests\ (ver tests\LEIAME.md).
rem   executar.bat              console e ia (servidor de TESTE, identidade DEFAULT)
rem   executar.bat console      so os testes do console jvcs.exe
rem   executar.bat ia           so os testes do wrapper da IA
rem   executar.bat instalador   so o teste isolado do setup (feche o Delphi antes)
rem   executar.bat tudo         todos
rem Parametros dos scripts (projeto de exemplo etc.): rode o .ps1 direto.
rem Codigo de saida: 0 = tudo ok, 1 = alguma falha.
setlocal
set "T=%~dp0"
set "PS=powershell -NoProfile -ExecutionPolicy Bypass -File"
set "ALVO=%~1"
if "%ALVO%"=="" set "ALVO=padrao"
set FALHOU=0

if /i "%ALVO%"=="instalador" goto instalador
if /i "%ALVO%"=="ia" goto ia

:console
echo ==== console\teste-modulos.ps1
%PS% "%T%console\teste-modulos.ps1"
if errorlevel 1 set FALHOU=1
echo ==== console\teste-correcoes.ps1
%PS% "%T%console\teste-correcoes.ps1"
if errorlevel 1 set FALHOU=1
if /i "%ALVO%"=="console" goto fim

:ia
echo ==== ia\teste-s0002.ps1
%PS% "%T%ia\teste-s0002.ps1"
if errorlevel 1 set FALHOU=1
echo ==== ia\teste-verify.ps1
%PS% "%T%ia\teste-verify.ps1"
if errorlevel 1 set FALHOU=1
echo ==== ia\teste-seguranca.ps1
%PS% "%T%ia\teste-seguranca.ps1"
if errorlevel 1 set FALHOU=1
if /i not "%ALVO%"=="tudo" goto fim

:instalador
echo ==== instalador\teste-setup.ps1
%PS% "%T%instalador\teste-setup.ps1"
if errorlevel 1 set FALHOU=1

:fim
if "%FALHOU%"=="1" (
    echo ==== RESULTADO: FALHA
    exit /b 1
)
echo ==== RESULTADO: OK
exit /b 0
