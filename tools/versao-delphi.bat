@echo off
rem ==========================================================================
rem  versao-delphi.bat - resolve a versao do Delphi para os scripts de build
rem  (uso interno de compilar.bat, compilar-expert.bat e gerar-instalador.bat;
rem  NAO usa setlocal: grava as variaveis no ambiente de quem chamou).
rem
rem  Uso:   call versao-delphi.bat [versao]
rem         versao = 11, 12, 13 (Delphi) ou 22, 23, 37 / 22.0, 23.0, 37.0 (BDS).
rem         Vazio: JVCS_DELPHI do ambiente; senao a pasta final do BDSROOT
rem         (se for NN.N); senao 37.0 (Delphi 13).
rem
rem  Le tools\versoes.ini (secao [BDSVER]). Saida:
rem    BDSVER       ex.: 22.0
rem    VD_BDSNUM    ex.: 22 (numero do BDS, sufixo de JvcsExpertBDS<nn>.dll)
rem    VD_DELPHI    ex.: 11
rem    VD_NAME      ex.: Delphi 11 Alexandria
rem    VD_TAG       subpasta de saida (vazio = versao de referencia, Delphi 13)
rem    VD_PKG       sufixo de pacotes (280, 290, 370)
rem    VD_JCLLIB    pasta de DCUs da JCL/JVCL (d28, d29, d37)
rem    VD_CATALOG, VD_JCL, VD_JVCL, VD_ICS, VD_ABBREVIA   valores do .ini
rem    VD_BDSDIR    raiz do RAD Studio (BDSROOT ou ProgramFiles(x86)\...\Studio\BDSVER)
rem    VD_INSTALLED 1 = bin\rsvars.bat e bin\dcc32.exe existem; 0 = nao
rem    VD_ERR       texto do erro (codigo 1)
rem  Codigo de saida: 0 = OK; 1 = versao invalida, fora do .ini ou BDSROOT
rem                   de outra versao.
rem ==========================================================================
set "VD_ERR="
set "VD_INI=%~dp0versoes.ini"
for %%V in (DELPHI NAME TAG PKG JCLLIB CATALOG JCL JVCL ICS ABBREVIA BDSNUM BDSDIR INSTALLED SEC CUR FIND LEAF ROOTVER) do set "VD_%%V="
for %%V in (delphi nome tag pkg jcl_lib catalog jcl jvcl ics abbrevia) do set "VD_I_%%V="
if not exist "%VD_INI%" (
    set "VD_ERR=arquivo de versoes nao encontrado: %VD_INI%"
    exit /b 1
)

rem ---- versao pedida --------------------------------------------------------
set "VD_IN=%~1"
if not defined VD_IN if defined JVCS_DELPHI set "VD_IN=%JVCS_DELPHI%"
rem  BDSROOT com pasta final NN.N: versao da pasta (padrao, e conferida abaixo)
if defined BDSROOT call :vd_rootleaf
if not defined VD_IN if defined VD_ROOTVER set "VD_IN=%VD_ROOTVER%"
if not defined VD_IN set "VD_IN=37.0"
set "VD_IN=%VD_IN:"=%"
set "VD_N=%VD_IN%"
if "%VD_N:~-2%"==".0" set "VD_N=%VD_N:~0,-2%"
echo %VD_N%| findstr /r /x "[0-9][0-9]*" >nul || goto :vd_bad

rem  menor que 20 = numero do Delphi (procura delphi=NN no .ini); senao = BDS
if %VD_N% lss 20 (
    set "VD_FIND=%VD_N%"
    for /f "usebackq eol=; tokens=1,* delims==" %%A in ("%VD_INI%") do call :vd_find "%%A" "%%B"
) else (
    set "VD_SEC=%VD_N%.0"
)
if not defined VD_SEC goto :vd_bad
set "BDSVER=%VD_SEC%"
for /f "delims=." %%V in ("%BDSVER%") do set "VD_BDSNUM=%%V"

rem ---- le a secao [BDSVER] ----------------------------------------------------
set "VD_CUR="
set "VD_FOUND="
for /f "usebackq eol=; tokens=1,* delims==" %%A in ("%VD_INI%") do call :vd_read "%%A" "%%B"
if not defined VD_FOUND (
    set "VD_ERR=versao %BDSVER% nao configurada em %VD_INI%"
    exit /b 1
)
set "VD_DELPHI=%VD_I_delphi%"
set "VD_NAME=%VD_I_nome%"
if not defined VD_NAME set "VD_NAME=BDS %BDSVER%"
set "VD_TAG=%VD_I_tag%"
set "VD_PKG=%VD_I_pkg%"
if not defined VD_PKG set "VD_PKG=%VD_BDSNUM%0"
set "VD_JCLLIB=%VD_I_jcl_lib%"
if not defined VD_JCLLIB set "VD_JCLLIB=d%VD_BDSNUM%"
set "VD_CATALOG=%VD_I_catalog%"
set "VD_JCL=%VD_I_jcl%"
set "VD_JVCL=%VD_I_jvcl%"
set "VD_ICS=%VD_I_ics%"
set "VD_ABBREVIA=%VD_I_abbrevia%"

rem ---- instalacao do RAD Studio ---------------------------------------------
if defined VD_ROOTVER if not "%VD_ROOTVER%"=="%BDSVER%" (
    set "VD_ERR=BDSROOT aponta para a versao %VD_ROOTVER%, mas foi pedida a %BDSVER% (%VD_NAME%). Ajuste ou apague BDSROOT."
    exit /b 1
)
set "VD_BDSDIR=%ProgramFiles(x86)%\Embarcadero\Studio\%BDSVER%"
if defined BDSROOT set "VD_BDSDIR=%BDSROOT:"=%"
if "%VD_BDSDIR:~-1%"=="\" set "VD_BDSDIR=%VD_BDSDIR:~0,-1%"
set "VD_INSTALLED=0"
if exist "%VD_BDSDIR%\bin\rsvars.bat" if exist "%VD_BDSDIR%\bin\dcc32.exe" set "VD_INSTALLED=1"
exit /b 0

:vd_bad
set "VD_ERR=versao invalida: "%VD_IN%". Use 11, 12 ou 13 (Delphi) ou 22, 23 ou 37 (BDS), conforme %VD_INI%"
exit /b 1

rem ---- :vd_rootleaf  - pasta final do BDSROOT -> :vd_leaf ----------------------
:vd_rootleaf
set "VD_K=%BDSROOT:"=%"
if "%VD_K:~-1%"=="\" set "VD_K=%VD_K:~0,-1%"
for %%I in ("%VD_K%") do call :vd_leaf "%%~nxI"
goto :eof

rem ---- :vd_leaf NOME  - NOME = NN.N -> VD_ROOTVER --------------------------
:vd_leaf
echo %~1| findstr /r /x "[0-9][0-9]*\.[0-9][0-9]*" >nul && set "VD_ROOTVER=%~1"
goto :eof

rem ---- :vd_find CHAVE VALOR  - secao cuja chave delphi = VD_FIND -------------
:vd_find
set "VD_K=%~1"
if "%VD_K:~0,1%"=="[" set "VD_CUR=%VD_K:~1,-1%" & goto :eof
if /i "%VD_K%"=="delphi" if "%~2"=="%VD_FIND%" set "VD_SEC=%VD_CUR%"
goto :eof

rem ---- :vd_read CHAVE VALOR  - guarda as chaves da secao BDSVER ------------
:vd_read
set "VD_K=%~1"
if "%VD_K:~0,1%"=="[" set "VD_CUR=%VD_K:~1,-1%" & goto :eof
if not "%VD_CUR%"=="%BDSVER%" goto :eof
set "VD_FOUND=1"
set "VD_I_%VD_K%=%~2"
goto :eof
