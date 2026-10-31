# Compila (dcc32 do Delphi 13) e roda tests\cliente\teste-pesquisa.dpr: relevancia da pesquisa
# de modulos do campo Find (src\common\client\JVCSModuleSearch.pas). Nao usa servidor.
param([string]$Dcc = 'C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\dcc32.exe')
$ErrorActionPreference = 'Stop'
$out = Join-Path $env:TEMP 'jvcs-testes\cliente'
New-Item -ItemType Directory -Force $out | Out-Null
Push-Location $PSScriptRoot
try {
    & $Dcc -Q -B "-E$out" "-NU$out" '-NSSystem;Winapi;Vcl' 'teste-pesquisa.dpr'
    if ($LASTEXITCODE -ne 0) { Write-Host '[FALHA] compilacao'; exit 1 }
} finally { Pop-Location }
& (Join-Path $out 'teste-pesquisa.exe')
exit $LASTEXITCODE
