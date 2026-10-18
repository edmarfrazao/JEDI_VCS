param(
    [Parameter(Mandatory = $true)][string]$Setup,
    [Parameter(Mandatory = $true)][string]$Destino
)
# Copia o instalador gerado para uma pasta de distribuição (ex.: a pasta compartilhada
# de onde o PC de testes instala) e regrava o SHA256.txt dessa pasta com o hash de
# cada JediVCS-*-Setup.exe que estiver nela. Chamado pelo gerar-instalador.bat quando
# a variável JVCS_COPIA_SETUP está definida; o caminho nunca fica no repositório.
# Código de saída: 0 = copiado e conferido; 1 = falha.
$ErrorActionPreference = 'Stop'
try {
    if (-not (Test-Path -LiteralPath $Setup -PathType Leaf)) { throw "setup não encontrado: $Setup" }
    if (-not (Test-Path -LiteralPath $Destino -PathType Container)) { throw "pasta de destino não encontrada: $Destino" }
    $alvo = Join-Path $Destino (Split-Path -Leaf $Setup)
    $h = (Get-FileHash -LiteralPath $Setup -Algorithm SHA256).Hash
    Copy-Item -LiteralPath $Setup -Destination $alvo -Force
    $h2 = (Get-FileHash -LiteralPath $alvo -Algorithm SHA256).Hash
    if ($h2 -ne $h) { throw "cópia com SHA-256 diferente ($h2 x $h)" }
    $linhas = foreach ($f in (Get-ChildItem -LiteralPath $Destino -Filter 'JediVCS-*-Setup.exe' -File | Sort-Object Name)) {
        "$((Get-FileHash -LiteralPath $f.FullName -Algorithm SHA256).Hash)  $($f.Name)"
    }
    [IO.File]::WriteAllText((Join-Path $Destino 'SHA256.txt'), (($linhas -join "`r`n") + "`r`n"), (New-Object Text.UTF8Encoding($false)))
    "[OK] setup copiado para $alvo (SHA-256 $h); SHA256.txt regravado"
    exit 0
} catch {
    "[FALHOU] cópia do setup: $($_.Exception.Message)"
    exit 1
}
