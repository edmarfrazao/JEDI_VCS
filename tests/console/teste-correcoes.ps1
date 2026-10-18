# Testes do console jvcs.exe: ciclo checkout/checkin com /input em cp1252 e em UTF-8 com BOM
# (acentos no comentário), conferência do comentário em cp1252 no fio (opcional, com o proxy de
# captura) e leitura da revisão nova pelo console original 2.5 (opcional).
# ATENÇÃO: faz checkout/checkin de verdade no módulo de exemplo (acrescenta uma linha de comentário
# ao arquivo local e grava duas revisões novas). Só rode contra um servidor de TESTE.
# Gravar COM BOM (PowerShell 5.1 + acentos).
param(
    [string]$Trabalho = (Join-Path $env:TEMP 'jvcs-testes'),
    [string]$Console = '',            # console em teste (padrão: bin\client\Win32\jvcs.exe do repositório)
    [string]$ProjetoExemplo = '',     # projeto existente no servidor de teste (ex.: exemplo.dpr)
    [string]$ModuloExemplo = '',      # ID do módulo desse projeto que recebe o checkin
    [string]$ArquivoExemplo = '',     # caminho local do arquivo desse módulo (pasta de trabalho do projeto)
    [string]$ConsoleOriginal = (Join-Path ${env:ProgramFiles(x86)} 'JEDI\JVCS\jvcs.exe'),  # console 2.5 original
    [string]$Captura = '',            # pasta do proxy de captura (arquivos <nome>_*_c2s.bin)
    [int]$PortaCaptura = 0            # porta local do proxy de captura
)
$ErrorActionPreference = 'Stop'
$Raiz = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$runner = Join-Path $PSScriptRoot 'golden.ps1'
if (-not $Console) { $Console = Join-Path $Raiz 'bin\client\Win32\jvcs.exe' }
$Saida = Join-Path $Trabalho 'console'
New-Item -ItemType Directory -Force $Saida | Out-Null
$enc = [Text.Encoding]::GetEncoding(1252)
$okN = 0; $falhas = 0; $pulados = 0
function Ok($c, $m) { if ($c) { "[OK] $m"; $script:okN++ } else { "[FALHA] $m"; $script:falhas++ } }
function Pular($m) { Write-Warning "[PULADO] $m"; $script:pulados++ }
function Fim { "==== OK: $okN  FALHA: $falhas  PULADO: $pulados"; if ($falhas -gt 0) { exit 1 } else { exit 0 } }
function Corpo($n) { $t = [IO.File]::ReadAllText((Join-Path $Saida "$n.txt"), $enc).Replace([string][char]0, ' '); $i = $t.IndexOf('jvcs> '); if ($i -ge 0) { $t.Substring($i) } else { $t } }
function Fio($nome) { $f = Get-ChildItem $Captura -Filter "$($nome)_*_c2s.bin" | Select-Object -First 1; if ($f) { [IO.File]::ReadAllBytes($f.FullName) } else { [byte[]]@() } }
function TemBytes($b, [byte[]]$p) { for ($i = 0; $i -le $b.Length - $p.Length; $i++) { $ok = $true; for ($j = 0; $j -lt $p.Length; $j++) { if ($b[$i + $j] -ne $p[$j]) { $ok = $false; break } }; if ($ok) { return $true } }; return $false }
function Rodar([string]$nome, [string[]]$linhas, [switch]$Bom) {
    $a = @{ Nome = $nome; Linhas = $linhas; Exe = $Console; Saida = $Saida }
    if ($Bom) { $a.Utf8Bom = $true }
    if ($usaCaptura) { $a.Porta = $PortaCaptura; $a.Captura = $Captura }
    & $runner @a | Out-Null
    Corpo $nome
}
function Revisao($texto) {
    $m = [regex]::Match($texto, '(?i)' + [regex]::Escape($nomeArq) + '\s+(\d+)\.(\d+)\s')
    if ($m.Success) { return [pscustomobject]@{ Maior = [int]$m.Groups[1].Value; Menor = [int]$m.Groups[2].Value; Texto = "$($m.Groups[1].Value).$($m.Groups[2].Value)" } }
    return $null
}
$acao = [byte[]](0x61, 0xE7, 0xE3, 0x6F)   # "ação" em cp1252
Ok ('ação'.Length -eq 4) 'roteiro lido com os acentos certos (BOM)'

if (-not ($ProjetoExemplo -and $ModuloExemplo -and $ArquivoExemplo)) {
    Pular 'ciclo checkout/checkin com /input: informe -ProjetoExemplo, -ModuloExemplo e -ArquivoExemplo'
    Fim
}
if (-not (Test-Path -LiteralPath $ArquivoExemplo)) { Ok $false "arquivo de exemplo existe: $ArquivoExemplo"; Fim }
$nomeArq = Split-Path -Leaf $ArquivoExemplo
$usaCaptura = [bool]($Captura -and $PortaCaptura -and (Test-Path -LiteralPath $Captura))
if (-not $usaCaptura) { Pular 'conferência do fio (cp1252): informe -Captura e -PortaCaptura do proxy de captura' }

# 1. checkin com /input cp1252
Rodar 'c_co1' @("openproject $ProjetoExemplo", "checkout $ModuloExemplo") | Out-Null
[IO.File]::WriteAllBytes($ArquivoExemplo, [byte[]]([IO.File]::ReadAllBytes($ArquivoExemplo) + $enc.GetBytes("`r`n// [zz-teste] /input cp1252 - ação")))
$c = Rodar 'c_ci1' @("openproject $ProjetoExemplo", "checkin $ModuloExemplo ""[zz-teste] /input cp1252 - ação, revisão (ç, ã)""")
$r1 = Revisao $c
Ok ($null -ne $r1) "checkin com /input cp1252 gravou revisão ($(if ($r1) { $r1.Texto }))"
Ok ($c.Contains('ação, revisão (ç, ã)')) 'eco do comando com os acentos certos'
if ($usaCaptura) { Ok (TemBytes (Fio 'c_ci1') $acao) 'comentário em cp1252 no fio (E7 E3)' }

# 2. checkin com /input UTF-8 com BOM
Rodar 'c_co2' @("openproject $ProjetoExemplo", "checkout $ModuloExemplo") | Out-Null
[IO.File]::WriteAllBytes($ArquivoExemplo, [byte[]]([IO.File]::ReadAllBytes($ArquivoExemplo) + $enc.GetBytes("`r`n// [zz-teste] /input UTF-8 com BOM - ação")))
$c = Rodar 'c_ci2' @("openproject $ProjetoExemplo", "checkin $ModuloExemplo ""[zz-teste] /input UTF-8 BOM - ação, revisão (ç, ã)""") -Bom
$r2 = Revisao $c
Ok ($r1 -and $r2 -and $r2.Maior -eq $r1.Maior -and $r2.Menor -eq $r1.Menor + 1) "checkin com /input UTF-8 BOM gravou a revisão seguinte ($(if ($r2) { $r2.Texto }))"
Ok ($c.Contains('ação, revisão (ç, ã)')) 'eco com os acentos certos (BOM detectado)'
if ($usaCaptura) { Ok (TemBytes (Fio 'c_ci2') $acao) 'comentário do /input UTF-8 BOM chega em cp1252 no fio' }

# 3. o console original lê a revisão nova igual à cópia local
if (-not ($ConsoleOriginal -and (Test-Path -LiteralPath $ConsoleOriginal))) {
    Pular "leitura pelo console original: não encontrado ($ConsoleOriginal); informe -ConsoleOriginal"
} elseif (-not $r2) {
    Pular 'leitura pelo console original: revisão do 2o checkin desconhecida'
} else {
    $dRev = Join-Path $Saida "get-$($r2.Texto)"
    New-Item -ItemType Directory -Force $dRev | Out-Null
    & $runner -Nome 'c_orig' -Exe $ConsoleOriginal -Saida $Saida -Linhas @("openproject $ProjetoExemplo", "getmodule $ModuloExemplo rev=$($r2.Texto) dest=$dRev", "listproject $ProjetoExemplo") | Out-Null
    $baixado = Join-Path $dRev $nomeArq
    Ok ((Test-Path -LiteralPath $baixado) -and (Get-FileHash -LiteralPath $ArquivoExemplo).Hash -eq (Get-FileHash -LiteralPath $baixado).Hash) "original lê a $($r2.Texto) igual à cópia local"
    Ok ((Corpo 'c_orig') -match ('(?mi)^' + [regex]::Escape($ModuloExemplo) + '\s+\S+\s+' + [regex]::Escape($nomeArq) + '\s+' + [regex]::Escape($r2.Texto) + '\s*$')) "listproject do original: $($r2.Texto) com Stamp/CRC vazios"
}
Fim
