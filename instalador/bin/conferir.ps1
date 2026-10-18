param([string]$Root, [string]$Setup, [string]$Destino = '')
# Conferência do instalador (chamado por conferir.bat): versão de tools\versao.ini, versão e data
# dos binários em bin\, o setup com o SHA-256 e a cópia na pasta de distribuição. Só lê.
# Código de saída: 0 = tudo coerente; 1 = algo não bate (binário com outra versão, setup ausente,
# cópia diferente).
$ErrorActionPreference = 'Stop'
$ruim = 0
$fv = (& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Root 'tools\gerar-versao.ps1') -Mostrar FileVersion | Out-String).Trim()
$iv = (& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Root 'tools\gerar-versao.ps1') -Mostrar InternalVersion | Out-String).Trim()
''
"Versão (tools\versao.ini): $fv - $iv"
''
'Binários:'
$bins = @('bin\client\Win32\Jedivcs.exe', 'bin\client\Win32\JEDIVCSDiff.exe', 'bin\client\Win32\jvcs.exe',
    'bin\ideclient\Win32\JvcsExternalDll.dll', 'bin\ideclient\Win32\JvcsExpertBDS22.dll',
    'bin\ideclient\Win32\JvcsExpertBDS23.dll', 'bin\ideclient\Win32\JvcsExpertBDS37.dll')
foreach ($b in $bins) {
    $p = Join-Path $Root $b
    if (-not (Test-Path -LiteralPath $p)) { '  {0,-45} (não existe)' -f $b; continue }
    $i = Get-Item -LiteralPath $p
    $v = $i.VersionInfo.FileVersion
    $ok = 'ok'
    if ($v -ne $fv) { $ok = "DIFERENTE de $fv"; $ruim++ }
    '  {0,-45} {1,-12} {2:dd/MM/yyyy HH:mm}  {3}' -f $b, $v, $i.LastWriteTime, $ok
}
''
'Setup:'
$h = $null
if (Test-Path -LiteralPath $Setup) {
    $s = Get-Item -LiteralPath $Setup
    $h = (Get-FileHash -LiteralPath $Setup -Algorithm SHA256).Hash
    "  $Setup"
    '  {0:N0} bytes, {1:dd/MM/yyyy HH:mm}' -f $s.Length, $s.LastWriteTime
    "  SHA-256 $h"
} else { "  não gerado ainda: $Setup"; $ruim++ }
''
'Pasta de distribuição:'
if (-not $Destino) { '  não configurada (instalador\config\distribuicao.bat)' }
elseif (-not (Test-Path -LiteralPath $Destino -PathType Container)) { "  não encontrada: $Destino"; $ruim++ }
else {
    $c = Join-Path $Destino (Split-Path -Leaf $Setup)
    if (-not (Test-Path -LiteralPath $c)) { "  $Destino : sem este setup (rode copiar.bat)"; $ruim++ }
    elseif ($h -and (Get-FileHash -LiteralPath $c -Algorithm SHA256).Hash -ne $h) { "  $c : DIFERENTE do setup gerado (rode copiar.bat)"; $ruim++ }
    else { "  $c : igual ao gerado" }
}
''
if ($ruim -gt 0) { "$ruim problema(s)"; exit 1 }
'tudo coerente'
exit 0
