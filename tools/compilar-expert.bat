@echo off
rem ==========================================================================
rem  compilar-expert.bat - Compila o expert de IDE do JEDI VCS (wizard DLL)
rem
rem  Uso:   compilar-expert.bat [/delphi:11|12|13 | /bds:22|23|37] [Debug ou Release] [nova ou original]
rem         Padrao: Delphi 13 (ou JVCS_DELPHI), Release nova
rem         /delphi:NN ou /bds:NN escolhe o Delphi que compila (tools\versoes.ini,
rem         lido por tools\versao-delphi.bat); cada versao gera o seu
rem         JvcsExpertBDS<nn>.dll na mesma pasta bin\ideclient\Win32 (o instalador
rem         pega todos os que existirem). Versao nao instalada: mensagem e
rem         codigo 1, nada e alterado.
rem
rem  Compila src\jvcsideexpert\JvcsExpertBDS.dpr com dcc32 (Win32, runtime
rem  packages rtl;vcl;designide) e gera:
rem    bin\ideclient\Win32\JvcsExpertBDS<nn>.dll   (nn = numero BDS:
rem                                                22 = Delphi 11, 23 = Delphi 12,
rem                                                37 = Delphi 13)
rem  O nome sai do $LIBSUFFIX do .dpr (CompilerVersion); o script descobre o
rem  nn pela DLL gerada e confere com a versao pedida. DCUs e o .res de versao
rem  em dcu\Win32\expert (Delphi 13) ou dcu\<D11|D12>\Win32\expert.
rem
rem  A DLL e compilada em dcu[\<tag>]\Win32\expert\out e so e copiada para
rem  bin\ideclient\Win32 se a compilacao e a verificacao do PE derem certo:
rem  um build com falha NAO apaga o expert que a IDE ja usa.
rem
rem  Depois copia para bin\ideclient\Win32 a JvcsExternalDll.dll e o runtime
rem  dela: fvcscrypt.dll, zipdll.dll, unzdll.dll, htm_rep.htm, *.jvcs, *.chm
rem  (e, se existir, jedivcsdiff.exe - usado pela DLL para Compare/Diff).
rem  JvcsExternalDll.dll (parametro 2):
rem    nova     (padrao, F5) = a DLL portada para o Delphi 13, de
rem               bin\client\Win32 (tools\compilar.bat dll Release Win32); so
rem               se exportar JEDIVCSDLLINIT e NAO for a 2.5.0.1030;
rem    original = a 2.5.0.1030 (Delphi 2007), SOMENTE de
rem               3rdparty\referencia-2.5.0.1030\ ou da instalacao original
rem               (JVCS_INSTALL), e so se o SHA-256 for o da 2.5.0.1030.
rem  Demais arquivos, nesta ordem: 3rdparty\, 3rdparty\referencia-2.5.0.1030\,
rem  JVCS_INSTALL.
rem
rem  A verificacao do PE usa o llvm-objdump do Delphi (bin64): a DLL deve
rem  exportar INITWIZARD0001 e importar rtlNNN/vclNNN/designideNNN.bpl.
rem
rem  O script NAO grava no registro. Para registrar na IDE de 32 bits, veja
rem  src\jvcsideexpert\LEIAME.md (valor JVCSIDEClient em ...\BDS\<ver>\Experts).
rem
rem  Variaveis de ambiente opcionais:
rem    BDSROOT      = pasta raiz do RAD Studio (sobrescreve o caminho padrao
rem                   ProgramFiles(x86)\Embarcadero\Studio\BDSVER). Se a pasta
rem                   final for numerica (ex.: ...\Studio\23.0) ela define a versao
rem                   (e precisa bater com /delphi ou /bds).
rem    JVCS_DELPHI  = versao padrao (11, 12, 13) sem /delphi nem /bds.
rem    JVCS_INSTALL = pasta da instalacao original do JEDI VCS 2.5
rem                   (padrao: ProgramFiles(x86)\JEDI\JVCS)
rem
rem  Log: tools\logs\compilar-expert_Win32_CONFIG.log
rem  Codigo de saida: 0 = tudo OK; 1 = falha de compilacao/ambiente ou DLL
rem                   em uso (IDE aberta); 2 = compilou, mas falta arquivo de
rem                   runtime, a JvcsExternalDll.dll nao e a pedida ou a
rem                   verificacao do PE falhou (nesse caso a DLL anterior e
rem                   mantida).
rem ==========================================================================
setlocal EnableExtensions DisableDelayedExpansion

rem ---- Configuracao (ajuste aqui) -------------------------------------------
rem  (versao do Delphi: /delphi:, /bds:, JVCS_DELPHI ou BDSROOT - ver versoes.ini)
set "BLD_PROJ=JvcsExpertBDS"
set "BLD_RCNAME=JvcsExpertBDS_ver"
set "BLD_CODEPAGE=65001"
set "BLD_PACKAGES=rtl;vcl;designide"
set "BLD_NS=Winapi;System.Win;System;Vcl;Vcl.Imaging;Xml"
set "BLD_MAXERR=5"
set "BLD_MAXWARN=20"
rem  SHA-256 da JvcsExternalDll.dll do JEDI VCS 2.5.0.1030 (referencia e instalacao)
set "BLD_EXTDLL_SHA256=7d9d1d35648003d8ce73c20e1bcaa64593933f650fd85fec14fade4d055a10a3"

rem ---- Pastas -----------------------------------------------------------------
for %%I in ("%~dp0..") do set "BLD_ROOT=%%~fI"
for %%I in ("%~dp0.") do set "BLD_TOOLS=%%~fI"
set "BLD_LOGDIR=%BLD_TOOLS%\logs"
set "BLD_SRCDIR=%BLD_ROOT%\src\jvcsideexpert"
set "BLD_OUTDIR=%BLD_ROOT%\bin\ideclient\Win32"
set "BLD_3RD=%BLD_ROOT%\3rdparty"
set "BLD_3RDREF=%BLD_ROOT%\3rdparty\referencia-2.5.0.1030"
if not defined JVCS_INSTALL set "JVCS_INSTALL=%ProgramFiles(x86)%\JEDI\JVCS"
set "JVCS_INSTALL=%JVCS_INSTALL:"=%"
if "%JVCS_INSTALL:~-1%"=="\" set "JVCS_INSTALL=%JVCS_INSTALL:~0,-1%"

rem ---- Parametros -----------------------------------------------------------
rem  /delphi:NN ou /bds:NN em qualquer posicao; o resto e posicional (config, dll)
set "BLD_VERARG="
set "BLD_CFG="
set "BLD_EXTDLL="
set "BLD_NPOS=0"
:args
if "%~1"=="" goto :args_done
set "BLD_A=%~1"
if "%BLD_A%"=="/?" goto :usage
if /i "%BLD_A%"=="-h" goto :usage
if /i "%BLD_A%"=="--help" goto :usage
if /i "%BLD_A:~0,8%"=="/delphi:" (
    set "BLD_VERARG=%BLD_A:~8%"
) else if /i "%BLD_A:~0,5%"=="/bds:" (
    set "BLD_VERARG=%BLD_A:~5%"
) else if "%BLD_A:~0,1%"=="/" (
    goto :bad_opt
) else (
    call :posarg
)
shift
goto :args
:args_done

if not defined BLD_CFG set "BLD_CFG=Release"
if not defined BLD_EXTDLL set "BLD_EXTDLL=nova"
if /i "%BLD_EXTDLL%"=="nova" (
    set "BLD_EXTDLL=nova"
) else if /i "%BLD_EXTDLL%"=="original" (
    set "BLD_EXTDLL=original"
) else (
    goto :bad_extdll
)
set "BLD_NEWDLLDIR=%BLD_ROOT%\bin\client\Win32"
if /i "%BLD_CFG%"=="Debug" (
    set "BLD_CFG=Debug"
) else if /i "%BLD_CFG%"=="Release" (
    set "BLD_CFG=Release"
) else (
    goto :bad_cfg
)

rem ---- Versao do Delphi (tools\versoes.ini) e instalacao do RAD Studio -------
call "%BLD_TOOLS%\versao-delphi.bat" "%BLD_VERARG%"
if errorlevel 1 goto :bad_ver
set "BLD_BDSDIR=%VD_BDSDIR%"
if not "%VD_INSTALLED%"=="1" goto :not_installed
rem  DCUs, .res e preparacao por versao (Delphi 13 sem subpasta, como antes)
set "BLD_TAGP="
set "BLD_TAGL="
if defined VD_TAG set "BLD_TAGP=\%VD_TAG%"
if defined VD_TAG set "BLD_TAGL=%VD_TAG%_"
set "BLD_DCUDIR=%BLD_ROOT%\dcu%BLD_TAGP%\Win32\expert"
set "BLD_STAGE=%BLD_DCUDIR%\out"
rem  (o numero BDS do nome da DLL vem da DLL gerada - :find_output - e tem de
rem  ser o da versao pedida, VD_BDSNUM; o sufixo dos pacotes vem do versoes.ini)

rem ---- Opcoes do compilador conforme a configuracao ------------------------
rem  -GD = .map detalhado (enderecos de AV dentro da IDE)
if /i "%BLD_CFG%"=="Debug" (
    set "BLD_DEFS=DEBUG"
    set "BLD_LIBCFG=debug"
    set "BLD_SW=-$O- -$Q+ -$R+ -$C+ -$D+ -$L+ -$Y+ -V -GD"
) else (
    set "BLD_DEFS=RELEASE"
    set "BLD_LIBCFG=release"
    set "BLD_SW=-$O+ -$Q- -$R- -$C- -$D- -$L- -$Y- -GD"
)
set "BLD_SW=%BLD_SW% -W+ -H+"

rem ---- Ambiente do RAD Studio (rsvars.bat) ----------------------------------
set "BLD_RSVARS=%BLD_BDSDIR%\bin\rsvars.bat"
call "%BLD_RSVARS%"
set "BLD_DCC=%BLD_BDSDIR%\bin\DCC32.EXE"
if not exist "%BLD_DCC%" goto :no_dcc
set "BLD_BRCC=%BLD_BDSDIR%\bin\brcc32.exe"
if not exist "%BLD_BRCC%" goto :no_brcc
set "BLD_RELDIR=%BLD_BDSDIR%\lib\win32\release"
set "BLD_LIBDIR=%BLD_BDSDIR%\lib\win32\%BLD_LIBCFG%"
if not exist "%BLD_RELDIR%\designide.dcp" goto :no_lib
set "BLD_OBJDUMP=%BLD_BDSDIR%\bin64\llvm-objdump.exe"
rem  o Delphi 11 nao traz llvm-objdump: usa o de outra versao instalada (le qualquer PE)
for %%V in (37.0 23.0) do call :find_objdump %%V
rem  .bpl desta versao para tools\verificar-expert.ps1 (simbolos importados x exportados)
set "BLD_BPLREF=%BLD_BDSDIR%\bin"

if not exist "%BLD_LOGDIR%" mkdir "%BLD_LOGDIR%"
if not exist "%BLD_OUTDIR%" mkdir "%BLD_OUTDIR%"
if not exist "%BLD_DCUDIR%" mkdir "%BLD_DCUDIR%"
if not exist "%BLD_STAGE%" mkdir "%BLD_STAGE%"
set "BLD_LOG=%BLD_LOGDIR%\compilar-expert_%BLD_TAGL%Win32_%BLD_CFG%.log"

echo Raiz    : %BLD_ROOT%
echo Delphi  : %VD_NAME% - %BLD_BDSDIR% ^(BDS %BDSVER%, JvcsExpertBDS%VD_BDSNUM%.dll, pacotes %VD_PKG%^)
echo Config  : %BLD_CFG% Win32 ^(dcc32, pacotes %BLD_PACKAGES%^)
echo Saida   : %BLD_OUTDIR%\%BLD_PROJ%^<nn^>.dll ^(compilada antes em %BLD_STAGE%^)
echo DLL     : JvcsExternalDll.dll %BLD_EXTDLL% ^(nova = %BLD_NEWDLLDIR%^)
echo Runtime : %JVCS_INSTALL%

set "BLD_RESULT=0"
set "BLD_LOCKED=0"
call :now BLD_T0

rem ---- 1) VERSIONINFO (.rc -> .res) -------------------------------------------
echo.
echo ==== %BLD_PROJ% : Win32 %BLD_CFG% ====
>"%BLD_LOG%" echo # compilar-expert.bat - %BLD_PROJ%.dpr - Win32 %BLD_CFG% - %DATE% %TIME%
>>"%BLD_LOG%" echo # Compilador : %BLD_DCC%
>>"%BLD_LOG%" echo # Pacotes    : %BLD_PACKAGES%
>>"%BLD_LOG%" echo # Defines    : %BLD_DEFS%
>>"%BLD_LOG%" echo # Opcoes     : %BLD_SW%
>>"%BLD_LOG%" echo # Saida DLL  : %BLD_STAGE% -^> %BLD_OUTDIR%   DCU: %BLD_DCUDIR%
>>"%BLD_LOG%" echo.
>>"%BLD_LOG%" echo ---- brcc32 %BLD_RCNAME%.rc
"%BLD_BRCC%" -fo"%BLD_DCUDIR%\%BLD_RCNAME%.res" "%BLD_SRCDIR%\%BLD_RCNAME%.rc" >>"%BLD_LOG%" 2>&1
if errorlevel 1 goto :rc_fail

rem ---- 2) dcc32 ---------------------------------------------------------------
>>"%BLD_LOG%" echo.
>>"%BLD_LOG%" echo ---- dcc32 %BLD_PROJ%.dpr
rem  compila na pasta de preparacao (limpa): o expert em uso fica intacto
del /f /q "%BLD_STAGE%\*.*" >nul 2>&1
pushd "%BLD_SRCDIR%"
"%BLD_DCC%" --no-config -B -Q %BLD_SW% --codepage:%BLD_CODEPAGE% "-D%BLD_DEFS%" "-NS%BLD_NS%" "-U%BLD_LIBDIR%;%BLD_RELDIR%" "-I%BLD_SRCDIR%" "-R%BLD_DCUDIR%;%BLD_RELDIR%" "-E%BLD_STAGE%" "-NU%BLD_DCUDIR%" "-LU%BLD_PACKAGES%" "%BLD_PROJ%.dpr" >>"%BLD_LOG%" 2>&1
set "BLD_RC=%ERRORLEVEL%"
popd
call :elapsed BLD_T0 BLD_SECS
if not "%BLD_RC%"=="0" goto :dcc_fail
call :find_output
if not defined BLD_DLLNAME goto :no_output

call :count_msgs
echo [OK] %BLD_DLLNAME% Win32 %BLD_CFG% - %BLD_SECS% s - %BLD_NWARN% aviso^(s^), %BLD_NHINT% dica^(s^) - log: %BLD_LOG%
if not "%BLD_NWARN%"=="0" call :show_warnings

rem ---- 3) Verificacao do PE (exports/imports) --------------------------------
echo.
echo ==== Verificacao do PE ====
set "BLD_PEFAIL=0"
call :verify_pe
call :verify_syms

rem ---- 4) Instala a DLL em bin\ideclient\Win32 -------------------------------
echo.
echo ==== Instalacao em %BLD_OUTDIR% ====
if "%BLD_PEFAIL%"=="1" (
    echo [FALHOU] verificacao do PE: %BLD_DLLNAME% NAO foi copiada - o expert anterior foi mantido
    set "BLD_RESULT=2"
) else (
    call :install_dll
)
if "%BLD_LOCKED%"=="1" goto :dll_locked

rem ---- 5) JvcsExternalDll.dll (nova ou original) e runtime -------------------
echo.
echo ==== JvcsExternalDll ^(%BLD_EXTDLL%^) e runtime ====
rem  (chamadas explicitas: um FOR expandiria *.jvcs/*.chm na pasta atual)
if "%BLD_EXTDLL%"=="nova" (call :copy_newdll) else (call :copy_extdll)
call :copy_rt "fvcscrypt.dll" req
call :copy_rt "zipdll.dll" req
call :copy_rt "unzdll.dll" req
call :copy_rt "htm_rep.htm" req
call :copy_rt "*.jvcs" req
call :copy_rt "*.chm" req
call :copy_rt "jedivcsdiff.exe" opt

echo.
if "%BLD_RESULT%"=="0" (
    echo Expert pronto em: %BLD_OUTDIR%
) else (
    echo Expert compilado, mas com pendencias - codigo %BLD_RESULT%. Veja as mensagens acima.
)
echo Registro ^(IDE 32 bits, NAO feito por este script^):
echo   HKCU\Software\Embarcadero\BDS\%BLD_BDSNUM%.0\Experts  valor JVCSIDEClient = %BLD_DLL%
endlocal & exit /b %BLD_RESULT%

rem ==========================================================================
rem  :find_output  - DLL gerada em BLD_STAGE -> nome, numero BDS e pacotes
rem  (o nome vem do $LIBSUFFIX do .dpr, escolhido por CompilerVersion)
rem ==========================================================================
:find_output
set "BLD_DLLNAME="
for %%F in ("%BLD_STAGE%\%BLD_PROJ%*.dll") do set "BLD_DLLNAME=%%~nxF"
if not defined BLD_DLLNAME goto :eof
set "BLD_BDSNUM=%BLD_DLLNAME:.dll=%"
call set "BLD_BDSNUM=%%BLD_BDSNUM:%BLD_PROJ%=%%"
set "BLD_PKGVER=%VD_PKG%"
if not "%BLD_BDSNUM%"=="%VD_BDSNUM%" echo [AVISO] o $LIBSUFFIX gerou %BLD_DLLNAME%, mas a versao pedida e BDS %VD_BDSNUM% ^(confira o .dpr^)
set "BLD_DLLSTG=%BLD_STAGE%\%BLD_DLLNAME%"
set "BLD_DLL=%BLD_OUTDIR%\%BLD_DLLNAME%"
goto :eof

rem ==========================================================================
rem  :install_dll  - copia DLL, .map e .drc da preparacao para BLD_OUTDIR
rem ==========================================================================
:install_dll
set "BLD_LOCKED=0"
copy /y "%BLD_DLLSTG%" "%BLD_OUTDIR%\" >nul 2>&1
if errorlevel 1 (
    set "BLD_LOCKED=1"
    goto :eof
)
for %%F in ("%BLD_STAGE%\%BLD_PROJ%*.map" "%BLD_STAGE%\%BLD_PROJ%*.drc") do copy /y "%%~fF" "%BLD_OUTDIR%\" >nul 2>&1
echo [OK] %BLD_DLLNAME% ^(e .map/.drc^) copiada para %BLD_OUTDIR%
goto :eof

rem ==========================================================================
rem  :verify_pe  - confere export INITWIZARD0001 e imports dos pacotes
rem ==========================================================================
:verify_pe
if not exist "%BLD_OBJDUMP%" (
    echo [AVISO] llvm-objdump nao encontrado - verificacao do PE ignorada.
    goto :eof
)
set "BLD_PE=%BLD_DCUDIR%\%BLD_PROJ%_pe.txt"
"%BLD_OBJDUMP%" -p "%BLD_DLLSTG%" >"%BLD_PE%" 2>&1
>>"%BLD_LOG%" echo.
>>"%BLD_LOG%" echo ---- llvm-objdump -p %BLD_DLLNAME% ^(imports/exports^)
findstr /i /c:"DLL Name:" /c:"INITWIZARD0001" "%BLD_PE%" >>"%BLD_LOG%" 2>&1
call :pe_check "INITWIZARD0001" "export INITWIZARD0001"
call :pe_check "DLL Name: rtl%BLD_PKGVER%.bpl" "import rtl%BLD_PKGVER%.bpl"
call :pe_check "DLL Name: vcl%BLD_PKGVER%.bpl" "import vcl%BLD_PKGVER%.bpl"
call :pe_check "DLL Name: designide%BLD_PKGVER%.bpl" "import designide%BLD_PKGVER%.bpl"
goto :eof

rem ---- :find_objdump VER  - llvm-objdump de outra versao, se faltar o desta ----
:find_objdump
if exist "%BLD_OBJDUMP%" goto :eof
set "BLD_OBJDUMP=%ProgramFiles(x86)%\Embarcadero\Studio\%~1\bin64\llvm-objdump.exe"
goto :eof

rem ==========================================================================
rem  :verify_syms  - todo simbolo importado dos .bpl existe nos .bpl desta
rem  instalacao? (tools\verificar-expert.ps1; mesma resolucao do LoadLibrary)
rem ==========================================================================
:verify_syms
>>"%BLD_LOG%" echo.
>>"%BLD_LOG%" echo ---- verificar-expert.ps1 %BLD_DLLNAME% contra %BLD_BPLREF%
powershell -NoProfile -ExecutionPolicy Bypass -File "%BLD_TOOLS%\verificar-expert.ps1" -Expert "%BLD_DLLSTG%" -BplDir "%BLD_BPLREF%" >>"%BLD_LOG%" 2>&1
if errorlevel 1 (
    echo [FALHOU] simbolos importados ausentes nos .bpl de "%BLD_BPLREF%" ^(veja o log^)
    set "BLD_RESULT=2"
    set "BLD_PEFAIL=1"
    goto :eof
)
for /f "tokens=1,* delims=:" %%A in ('findstr /b /c:"Pacotes importados:" "%BLD_LOG%"') do set "BLD_SYMLINE=%%B"
echo [OK] simbolos importados resolvidos nos .bpl desta instalacao -%BLD_SYMLINE%
goto :eof

:pe_check
findstr /i /c:"%~1" "%BLD_PE%" >nul 2>&1
if errorlevel 1 (
    echo [FALHOU] %~2 nao encontrado
    set "BLD_RESULT=2"
    set "BLD_PEFAIL=1"
) else (
    echo [OK] %~2
)
goto :eof

rem ==========================================================================
rem  :copy_extdll  - JvcsExternalDll.dll ORIGINAL (SHA-256 da 2.5.0.1030),
rem  somente da referencia ou da instalacao original
rem ==========================================================================
:copy_extdll
set "BLD_CPSRC="
call :try_extdll "%BLD_3RDREF%"
if not defined BLD_CPSRC call :try_extdll "%JVCS_INSTALL%"
if not defined BLD_CPSRC (
    echo [FALHOU] JvcsExternalDll.dll original ^(2.5.0.1030^) nao encontrada em "%BLD_3RDREF%" nem em "%JVCS_INSTALL%"
    set "BLD_RESULT=2"
    goto :eof
)
copy /y "%BLD_CPSRC%\JvcsExternalDll.dll" "%BLD_OUTDIR%\" >nul 2>&1
if errorlevel 1 (
    echo [FALHOU] nao foi possivel copiar JvcsExternalDll.dll de "%BLD_CPSRC%" ^(arquivo em uso pela IDE?^)
    set "BLD_RESULT=2"
    goto :eof
)
call :sha256 "%BLD_OUTDIR%\JvcsExternalDll.dll" BLD_HASH
if /i not "%BLD_HASH%"=="%BLD_EXTDLL_SHA256%" (
    echo [FALHOU] JvcsExternalDll.dll copiada com SHA-256 diferente: %BLD_HASH%
    set "BLD_RESULT=2"
    goto :eof
)
echo [OK] JvcsExternalDll.dll - de %BLD_CPSRC% ^(SHA-256 da 2.5.0.1030 confere^)
goto :eof

rem ==========================================================================
rem  :copy_newdll  - JvcsExternalDll.dll NOVA (port Delphi 13, F5) de
rem  bin\client\Win32: precisa exportar JEDIVCSDLLINIT e nao ser a 2.5.0.1030
rem ==========================================================================
:copy_newdll
set "BLD_NEWDLL=%BLD_NEWDLLDIR%\JvcsExternalDll.dll"
if not exist "%BLD_NEWDLL%" (
    echo [FALHOU] JvcsExternalDll.dll nova nao encontrada: "%BLD_NEWDLL%"
    echo          Gere com: tools\compilar.bat dll Release Win32  ^(ou use: %~nx0 %BLD_CFG% original^)
    set "BLD_RESULT=2"
    goto :eof
)
call :sha256 "%BLD_NEWDLL%" BLD_HASH
if /i "%BLD_HASH%"=="%BLD_EXTDLL_SHA256%" (
    echo [FALHOU] "%BLD_NEWDLL%" e a 2.5.0.1030 original, nao a nova
    set "BLD_RESULT=2"
    goto :eof
)
if exist "%BLD_OBJDUMP%" (
    "%BLD_OBJDUMP%" -p "%BLD_NEWDLL%" 2>nul | findstr /c:"JEDIVCSDLLINIT" >nul
    if errorlevel 1 (
        echo [FALHOU] "%BLD_NEWDLL%" nao exporta JEDIVCSDLLINIT
        set "BLD_RESULT=2"
        goto :eof
    )
)
copy /y "%BLD_NEWDLL%" "%BLD_OUTDIR%\" >nul 2>&1
if errorlevel 1 (
    echo [FALHOU] nao foi possivel copiar "%BLD_NEWDLL%" ^(arquivo em uso pela IDE?^)
    set "BLD_RESULT=2"
    goto :eof
)
if exist "%BLD_NEWDLLDIR%\JvcsExternalDll.map" copy /y "%BLD_NEWDLLDIR%\JvcsExternalDll.map" "%BLD_OUTDIR%\" >nul 2>&1
echo [OK] JvcsExternalDll.dll NOVA - de %BLD_NEWDLLDIR% ^(SHA-256 %BLD_HASH%^)
goto :eof

:try_extdll
if not exist "%~1\JvcsExternalDll.dll" goto :eof
call :sha256 "%~1\JvcsExternalDll.dll" BLD_HASH
if /i "%BLD_HASH%"=="%BLD_EXTDLL_SHA256%" (
    set "BLD_CPSRC=%~1"
) else (
    echo [AVISO] "%~1\JvcsExternalDll.dll" ignorada: nao e a 2.5.0.1030 ^(SHA-256 %BLD_HASH%^)
)
goto :eof

rem ---- :sha256 ARQUIVO VAR  - SHA-256 em hexadecimal minusculo (certutil) ----
:sha256
set "%~2="
for /f "delims=" %%H in ('certutil -hashfile "%~1" SHA256 ^| findstr /r /x /c:"[0-9a-fA-F ]*"') do set "%~2=%%H"
call set "%~2=%%%~2: =%%"
goto :eof

rem ==========================================================================
rem  :copy_rt PADRAO req^|opt  - copia arquivo(s) de runtime para BLD_OUTDIR
rem ==========================================================================
:copy_rt
set "BLD_CPSRC="
if exist "%BLD_3RD%\%~1" set "BLD_CPSRC=%BLD_3RD%"
if not defined BLD_CPSRC if exist "%BLD_3RDREF%\%~1" set "BLD_CPSRC=%BLD_3RDREF%"
if not defined BLD_CPSRC if exist "%JVCS_INSTALL%\%~1" set "BLD_CPSRC=%JVCS_INSTALL%"
if not defined BLD_CPSRC goto :copy_missing
copy /y "%BLD_CPSRC%\%~1" "%BLD_OUTDIR%\" >nul 2>&1
if errorlevel 1 goto :copy_err
echo [OK] %~1 - de %BLD_CPSRC%
goto :eof
:copy_missing
if /i "%~2"=="opt" (
    echo [AVISO] %~1 nao encontrado ^(opcional^)
    goto :eof
)
echo [FALHOU] %~1 nao encontrado em 3rdparty nem em "%JVCS_INSTALL%"
set "BLD_RESULT=2"
goto :eof
:copy_err
echo [FALHOU] nao foi possivel copiar %~1 de %BLD_CPSRC% ^(arquivo em uso pela IDE?^)
set "BLD_RESULT=2"
goto :eof

rem ---- :count_msgs  - conta avisos e dicas no log -----------------------------
:count_msgs
set "BLD_NWARN=0"
set "BLD_NHINT=0"
for /f %%N in ('findstr /i /c:" Warning: " "%BLD_LOG%" ^| "%SystemRoot%\System32\find.exe" /c /v ""') do set "BLD_NWARN=%%N"
for /f %%N in ('findstr /i /c:" Hint: " "%BLD_LOG%" ^| "%SystemRoot%\System32\find.exe" /c /v ""') do set "BLD_NHINT=%%N"
goto :eof

rem ---- :show_warnings  - mostra os primeiros BLD_MAXWARN avisos ---------------
:show_warnings
setlocal EnableDelayedExpansion
set /a "BLD_N=0"
for /f "usebackq delims=" %%L in (`findstr /i /c:" Warning: " "!BLD_LOG!"`) do (
    set /a "BLD_N+=1"
    if !BLD_N! leq %BLD_MAXWARN% (
        set "BLD_LINE=%%L"
        echo     !BLD_LINE!
    )
)
endlocal
goto :eof

rem ---- :show_errors  - mostra as primeiras BLD_MAXERR mensagens de erro --------
:show_errors
setlocal EnableDelayedExpansion
set /a "BLD_N=0"
for /f "usebackq delims=" %%L in (`findstr /i /c:"Fatal:" /c:"Error:" /c:"error F" /c:"error E" "!BLD_LOG!"`) do (
    set /a "BLD_N+=1"
    if !BLD_N! leq %BLD_MAXERR% (
        set "BLD_LINE=%%L"
        echo     !BLD_LINE!
    )
)
endlocal
goto :eof

rem ---- :posarg  - parametro posicional (config, dll) ---------------------------
:posarg
set /a "BLD_NPOS+=1"
if %BLD_NPOS% equ 1 set "BLD_CFG=%BLD_A%"
if %BLD_NPOS% equ 2 set "BLD_EXTDLL=%BLD_A%"
if %BLD_NPOS% gtr 2 echo [AVISO] parametro ignorado: %BLD_A%
goto :eof

rem ---- :now VAR  - hora atual em centesimos de segundo ----------------------
:now
set "BLD_TM=%TIME: =0%"
for /f "tokens=1-4 delims=:.," %%a in ("%BLD_TM%") do set /a "%~1=((1%%a-100)*3600+(1%%b-100)*60+(1%%c-100))*100+(1%%d-100)"
goto :eof

rem ---- :elapsed VAR_INICIO VAR_SAIDA  - segundos decorridos (ex.: 3,07) ----
:elapsed
call :now BLD_T1
set /a "BLD_D=BLD_T1-%~1"
if %BLD_D% lss 0 set /a "BLD_D+=8640000"
set /a "BLD_S=BLD_D/100, BLD_C=BLD_D%%100"
if %BLD_C% lss 10 set "BLD_C=0%BLD_C%"
set "%~2=%BLD_S%,%BLD_C%"
goto :eof

rem ---- Mensagens de uso/erro ------------------------------------------------
:usage
echo Uso: %~nx0 [/delphi:11^|12^|13 ^| /bds:22^|23^|37] [Debug^|Release] [nova^|original]
echo      Padrao: Delphi 13 ^(ou JVCS_DELPHI^), Release nova. Versoes em tools\versoes.ini.
echo      Gera bin\ideclient\Win32\JvcsExpertBDS^<nn^>.dll ^(22, 23 ou 37^) e copia
echo      a JvcsExternalDll.dll ^(nova = bin\client\Win32, port Delphi 13; original =
echo      2.5.0.1030 de 3rdparty\referencia-2.5.0.1030^) e o runtime para a mesma pasta.
echo      Defina BDSROOT para usar outra instalacao do RAD Studio ^(ex.: ...\Studio\23.0^).
echo      Defina JVCS_INSTALL se o JEDI VCS 2.5 nao estiver em ProgramFiles^(x86^)\JEDI\JVCS.
endlocal & exit /b 0

:bad_cfg
echo [ERRO] Configuracao invalida: "%BLD_CFG%". Use Debug ou Release.
endlocal & exit /b 1

:bad_extdll
echo [ERRO] DLL invalida: "%BLD_EXTDLL%". Use nova ou original.
endlocal & exit /b 1

:bad_opt
echo [ERRO] Opcao invalida: "%BLD_A%". Use /delphi:NN ou /bds:NN ^(%~nx0 /? para ajuda^).
endlocal & exit /b 1

:bad_ver
echo [ERRO] %VD_ERR%
endlocal & exit /b 1

:not_installed
echo [ERRO] %VD_NAME% ^(BDS %BDSVER%^) nao esta instalado nesta maquina:
echo        faltam "%BLD_BDSDIR%\bin\rsvars.bat" ou "%BLD_BDSDIR%\bin\dcc32.exe".
echo        Instale o %VD_NAME% ou defina BDSROOT com a pasta raiz correta
echo        ^(ex.: set BDSROOT=D:\Embarcadero\Studio\%BDSVER%^). Nada foi alterado.
endlocal & exit /b 1

:no_dcc
echo [ERRO] Compilador nao encontrado: "%BLD_DCC%"
endlocal & exit /b 1

:no_brcc
echo [ERRO] Compilador de recursos nao encontrado: "%BLD_BRCC%"
endlocal & exit /b 1

:no_lib
echo [ERRO] designide.dcp nao encontrado em "%BLD_RELDIR%"
endlocal & exit /b 1

:rc_fail
echo [FALHOU] brcc32 %BLD_RCNAME%.rc ^(veja o log: %BLD_LOG%^)
endlocal & exit /b 1

:dll_locked
echo [FALHOU] "%BLD_DLL%" esta em uso ^(IDE aberta com o expert carregado?^). Feche a IDE e repita.
endlocal & exit /b 1

:dcc_fail
echo [FALHOU] %BLD_PROJ%.dpr Win32 %BLD_CFG% ^(veja o log: %BLD_LOG%^) - codigo %BLD_RC%
echo          O expert anterior em %BLD_OUTDIR% foi mantido.
call :show_errors
endlocal & exit /b %BLD_RC%

:no_output
echo [FALHOU] dcc32 terminou sem erro, mas nenhuma %BLD_PROJ%*.dll foi gerada em "%BLD_STAGE%" ^(veja o log: %BLD_LOG%^)
endlocal & exit /b 1
