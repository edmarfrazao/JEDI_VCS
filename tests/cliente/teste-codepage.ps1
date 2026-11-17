# Compila (dcc32 do Delphi 13) e roda tests\cliente\teste-codepage.dpr: code page do fio
# (issue #1; src\common\client\JVCSWireCodePage.pas e RFormat). Nao usa servidor.
# Usa o RFormat.dcu do build do console (tools\compilar.bat console Debug Win32).
param(
    [string]$Dcc = 'C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\dcc32.exe',
    [string]$Dcu = (Join-Path $PSScriptRoot '..\..\dcu\Win32\Debug\console')
)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath (Join-Path $Dcu 'RFormat.dcu'))) {
    Write-Host "[FALHA] falta $Dcu\RFormat.dcu: rode tools\compilar.bat console Debug Win32"
    exit 1
}
$out = Join-Path $env:TEMP 'jvcs-testes\cliente'
New-Item -ItemType Directory -Force $out | Out-Null
Push-Location $PSScriptRoot
try {
    & $Dcc -Q -B "-E$out" "-NU$out" "-U$Dcu" '-NSSystem;System.Win;Winapi;Vcl;Data' 'teste-codepage.dpr'
    if ($LASTEXITCODE -ne 0) { Write-Host '[FALHA] compilacao'; exit 1 }
} finally { Pop-Location }
& (Join-Path $out 'teste-codepage.exe')
exit $LASTEXITCODE
