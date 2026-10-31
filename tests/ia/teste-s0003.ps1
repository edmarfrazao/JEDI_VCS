# Testes do wrapper tools\ai\jvcs-ai.ps1 para a solicitação S0003: módulos homônimos pelo nome
# truncado em 30 pelo console (Estrutura.Firma.Sesiag.NotaFiscalEntrada.pas x ...NotaFiscalSaida.pas
# na mesma pasta). status/checkout/checkin/undocheckout resolvem o ID certo pelo nome completo
# (listmodules), id:<n> -Project nos comandos de arquivo e arquivo não versionado com o mesmo prefixo.
# ATENÇÃO: cria no servidor o projeto zz-teste-s0003<Sufixo>.dpr com 3 módulos e faz checkout/checkin
# neles. Só rode contra um servidor de TESTE.
# Usa um APPDATA temporário (config.ini próprio, [ai] identity=DEFAULT); não toca no config.ini
# real nem nas identidades do registro. Gravar COM BOM (PowerShell 5.1 + acentos).
param(
    [string]$Trabalho = (Join-Path $env:TEMP 'jvcs-testes'),
    [string]$Console = '',              # padrão: bin\client\Win32\jvcs.exe do repositório
    [string]$Sufixo = (Get-Date -Format 'yyMMddHHmm')
)
$ErrorActionPreference = 'Stop'
$Raiz = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$W = Join-Path $Raiz 'tools\ai\jvcs-ai.ps1'
if (-not $Console) { $Console = Join-Path $Raiz 'bin\client\Win32\jvcs.exe' }
$runner = Join-Path $Raiz 'tests\console\golden.ps1'
$S = Join-Path $Trabalho 'ia'
New-Item -ItemType Directory -Force $S | Out-Null
$S = (Get-Item -LiteralPath $S).FullName
$enc = [Text.Encoding]::GetEncoding(1252)
$okN = 0; $falhas = 0
function Ok($c, $m) { if ($c) { "[OK] $m"; $script:okN++ } else { "[FALHA] $m"; $script:falhas++ } }

$AD = Join-Path $S 'appdata-s0003'
New-Item -ItemType Directory -Force "$AD\JEDI\JVCS" | Out-Null
[IO.File]::WriteAllText("$AD\JEDI\JVCS\config.ini", "[ai]`r`njvcsExe=$Console`r`nidentity=DEFAULT`r`ncheckout=auto`r`ncheckin=auto`r`n", (New-Object Text.UTF8Encoding($true)))
$appdataOriginal = $env:APPDATA
$env:APPDATA = $AD
Remove-Item Env:\CLAUDECODE -ErrorAction SilentlyContinue
Remove-Item Env:\AI_AGENT -ErrorAction SilentlyContinue
function J {
    param([string]$Dir, [string[]]$A)
    Push-Location $Dir
    try {
        $out = & powershell -NoProfile -ExecutionPolicy Bypass -File $W @A 2>&1 | Out-String
        $code = $LASTEXITCODE
    } finally { Pop-Location }
    $obj = $null
    try { $obj = $out | ConvertFrom-Json } catch { }
    return [pscustomobject]@{ Code = $code; Json = $obj; Out = $out }
}
function M($r) { if ($r.Json -and @($r.Json.modules).Count -gt 0) { return $r.Json.modules[0] } return $null }

try {
$prj = "zz-teste-s0003$Sufixo.dpr"
"projeto de teste: $prj"
# pasta longa: o console também corta a pasta (50) e o checkout prova o caminho pela sonda de data
$G = Join-Path $S "zz-teste-s0003$Sufixo\src\Compartilhado\Firma\Sesiag"
if (Test-Path -LiteralPath (Join-Path $S "zz-teste-s0003$Sufixo")) {
    Get-ChildItem -LiteralPath (Join-Path $S "zz-teste-s0003$Sufixo") -Recurse -Force | ForEach-Object { $_.Attributes = 'Normal' }
    Remove-Item -Recurse -Force -LiteralPath (Join-Path $S "zz-teste-s0003$Sufixo")
}
New-Item -ItemType Directory -Force $G | Out-Null
$G = (Get-Item -LiteralPath $G).FullName
$fE = "$G\Estrutura.Firma.Sesiag.NotaFiscalEntrada.pas"
$fS = "$G\Estrutura.Firma.Sesiag.NotaFiscalSaida.pas"
$fO = "$G\Estrutura.Firma.Sesiag.NotaFiscalOutra.pas"   # nunca versionado, mesmo prefixo de 27
[IO.File]::WriteAllText("$G\$prj", "program x;`r`nbegin`r`nend.`r`n", $enc)
[IO.File]::WriteAllText($fE, "unit Estrutura.Firma.Sesiag.NotaFiscalEntrada;`r`n// entrada`r`ninterface`r`nimplementation`r`nend.`r`n", $enc)
[IO.File]::WriteAllText($fS, "unit Estrutura.Firma.Sesiag.NotaFiscalSaida;`r`n// saida`r`ninterface`r`nimplementation`r`nend.`r`n", $enc)
[IO.File]::WriteAllText($fO, "unit Estrutura.Firma.Sesiag.NotaFiscalOutra;`r`nend.`r`n", $enc)
& $runner -Nome 's0003_proj' -Exe $Console -Saida $S -Cwd $G -Linhas @("addproject $prj ""[zz-teste] S0003 homonimos - pode apagar""") | Out-Null

# add um de cada vez: antes da S0003 o 2º já parecia versionado (prefixo igual ao 1º)
$r = J $G @('add', "$G\$prj", $fE, '-Comment', '[zz-teste] versao inicial', '-Project', $prj)
Ok ($r.Code -eq 0 -and @($r.Json.modules | Where-Object { $_.state -eq 'added' }).Count -eq 2) "add do .dpr e da Entrada ($($r.Json.message))"
$r = J $G @('add', $fS, '-Comment', '[zz-teste] versao inicial', '-Project', $prj)
Ok ($r.Code -eq 0 -and (M $r).state -eq 'added') "add da Saida com a Entrada já no projeto ($($r.Json.message))"

$r = J $G @('modules', '-Project', $prj)
$idE = @($r.Json.modules | Where-Object { $_.name -ieq 'estrutura.firma.sesiag.notafiscalentrada.pas' } | ForEach-Object { $_.id })
$idS = @($r.Json.modules | Where-Object { $_.name -ieq 'estrutura.firma.sesiag.notafiscalsaida.pas' } | ForEach-Object { $_.id })
Ok ($idE.Count -eq 1 -and $idS.Count -eq 1 -and $idE[0] -ne $idS[0]) "modules: Entrada id $idE, Saida id $idS"
$idE = [int]$idE[0]; $idS = [int]$idS[0]

# --- status pelo arquivo: cada um no seu ID; o não versionado com o mesmo prefixo = notVersioned
$r = J $G @('status', $fE)
Ok ($r.Code -eq 0 -and (M $r).id -eq $idE -and (M $r).localState -eq 'clean') "status Entrada -> id $((M $r).id), $((M $r).localState) ($($r.Json.message))"
$r = J $G @('status', $fS)
Ok ($r.Code -eq 0 -and (M $r).id -eq $idS -and (M $r).localState -eq 'clean') "status Saida -> id $((M $r).id), $((M $r).localState) ($($r.Json.message))"
$r = J $G @('status', $fO)
Ok ($r.Code -eq 0 -and $null -eq (M $r).id -and (M $r).localState -eq 'notVersioned') "status Outra (não versionada, mesmo prefixo) -> $((M $r).localState) ($((M $r).message))"
$r = J $G @('status', $fE, $fS, '-Text')
Ok ($r.Code -eq 0) "status -Text dos dois: código $($r.Code)"

# --- checkout / checkin / undocheckout pelo arquivo
$r = J $G @('checkout', $fE)
Ok ($r.Code -eq 0 -and (M $r).id -eq $idE) "checkout Entrada -> id $((M $r).id) ($($r.Json.message))"
$r = J $G @('locks', '-NoLocalState')
$lk = @($r.Json.modules | ForEach-Object { [int]$_.id })
Ok (($lk -contains $idE) -and -not ($lk -contains $idS)) 'lock só na Entrada'
Set-ItemProperty $fE -Name IsReadOnly -Value $false
[IO.File]::AppendAllText($fE, "// S0003 alterado`r`n", $enc)
$r = J $G @('checkin', $fE, '-Comment', '[zz-teste] S0003 checkin da Entrada')
Ok ($r.Code -eq 0 -and (M $r).id -eq $idE) "checkin Entrada -> id $((M $r).id) ($($r.Json.message))"
$r = J $G @('history', $fE, '-Max', '1')
Ok ([string]$r.Json.modules[0].revisions[0].comment -match 'S0003 checkin da Entrada') 'history da Entrada tem o check-in novo'
$r = J $G @('history', $fS, '-Max', '5')
Ok (@($r.Json.modules[0].revisions | Where-Object { [string]$_.comment -match 'S0003 checkin' }).Count -eq 0) 'history da Saida não tem o check-in da Entrada'
$r = J $G @('checkout', $fS)
Ok ($r.Code -eq 0 -and (M $r).id -eq $idS) "checkout Saida -> id $((M $r).id) ($($r.Json.message))"
$r = J $G @('undocheckout', $fS)
Ok ($r.Code -eq 0 -and (M $r).id -eq $idS) "undocheckout Saida -> id $((M $r).id) ($($r.Json.message))"
$r = J $G @('ensure-checkout', $fS, '-CheckOnly')
Ok ((M $r).id -eq $idS) "ensure-checkout -CheckOnly Saida -> id $((M $r).id) (código $($r.Code))"

# --- módulo com .pas e .dfm de nome longo (as duas linhas do listproject aparecem cortadas iguais)
$fF = "$G\Estrutura.Firma.Sesiag.FormularioCadastro.pas"
$fD = "$G\Estrutura.Firma.Sesiag.FormularioCadastro.dfm"
[IO.File]::WriteAllText($fF, "unit Estrutura.Firma.Sesiag.FormularioCadastro;`r`ninterface`r`nimplementation`r`n{`$R *.dfm}`r`nend.`r`n", $enc)
[IO.File]::WriteAllText($fD, "object Form1: TForm1`r`n  Caption = 'Cadastro'`r`nend`r`n", $enc)
$r = J $G @('add', $fF, '-Comment', '[zz-teste] form', '-Project', $prj)
Ok ($r.Code -eq 0 -and (M $r).state -eq 'added') "add do .pas com .dfm ($($r.Json.message))"
$r = J $G @('status', $fD)
$idF = (M $r).id
Ok ($r.Code -eq 0 -and $idF -and (M $r).localState -eq 'clean') "status do .dfm -> id $idF, $((M $r).localState)"
$r = J $G @('checkout', $fF)
Ok ($r.Code -eq 0 -and (M $r).id -eq $idF -and (M $r).pathCheck -eq 'verified') "checkout .pas+.dfm com pasta cortada -> $((M $r).pathCheck) ($($r.Json.message))"
Set-ItemProperty $fF -Name IsReadOnly -Value $false; Set-ItemProperty $fD -Name IsReadOnly -Value $false
[IO.File]::AppendAllText($fD, "// mudou so o dfm`r`n", $enc)
$r = J $G @('checkin', $fF, '-Comment', '[zz-teste] S0003 form')
Ok ($r.Code -eq 0 -and (M $r).id -eq $idF) "checkin .pas+.dfm ($($r.Json.message))"
# cópia em pasta irmã com o mesmo começo de caminho: nunca pode virar checkout do módulo do servidor
$G2 = "$G" + 'Copia'
New-Item -ItemType Directory -Force $G2 | Out-Null
Copy-Item -LiteralPath $fF, $fD -Destination $G2
Get-ChildItem -LiteralPath $G2 | ForEach-Object { $_.IsReadOnly = $false }
$r = J $G2 @('checkout', "$G2\Estrutura.Firma.Sesiag.FormularioCadastro.pas", '-Project', $prj)
Ok ($r.Code -ne 0) "checkout da cópia em outra pasta é recusado (código $($r.Code): $((M $r).message)$($r.Json.message))"
$r = J $G @('locks', '-NoLocalState')
Ok (@($r.Json.modules | Where-Object { [int]$_.id -eq [int]$idF }).Count -eq 0) 'sem lock no módulo do formulário'

# --- id:<n> -Project nos comandos de arquivo
$r = J $S @('status', "id:$idS", '-Project', $prj)
Ok ($r.Code -eq 0 -and (M $r).id -eq $idS -and [string](M $r).path -like '*NotaFiscalSaida.pas') "status id:$idS -> $((M $r).path)"
$r = J $S @('checkout', "id:$idE", '-Project', $prj)
Ok ($r.Code -eq 0 -and (M $r).id -eq $idE) "checkout id:$idE ($($r.Json.message))"
$r = J $S @('undocheckout', "id:$idE", '-Project', $prj)
Ok ($r.Code -eq 0 -and (M $r).id -eq $idE) "undocheckout id:$idE ($($r.Json.message))"
$r = J $S @('diff', "id:$idS", '-Project', $prj)
Ok ($r.Code -eq 0 -or $r.Code -eq 3) "diff id:$idS (código $($r.Code))"
$r = J $S @('status', "id:$idS")
Ok ($r.Code -ne 0 -and (M $r).exitCode -eq 2 -or $r.Code -eq 2) "id:<n> sem -Project -> 2 ($($r.Code))"
$r = J $S @('checkout', 'id:999999', '-Project', $prj)
Ok ($r.Code -eq 5 -and [string]$r.Json.message -match 'não pertence') "id fora do projeto -> 5 ($($r.Json.message))"
$r = J $G @('add', 'id:1', '-Comment', 'x', '-Project', $prj)
Ok ($r.Code -eq 2) "add id:1 -> 2"
$r = J $S @('checkout', '#id:5', '-Project', $prj)
Ok ($r.Code -eq 2 -or (M $r).exitCode -eq 2) "#id:5 -> 2"

# --- nada ficou em checkout
$r = J $S @('locks', '-NoLocalState')
$lk = @($r.Json.modules | ForEach-Object { [int]$_.id })
Ok (-not ($lk -contains $idE) -and -not ($lk -contains $idS)) 'nenhum lock restante nos módulos do teste'
} finally {
    $env:APPDATA = $appdataOriginal
}

"==== OK: $okN  FALHA: $falhas"
if ($falhas -gt 0) { exit 1 } else { exit 0 }
