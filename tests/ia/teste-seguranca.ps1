# Testes das correções de segurança da revisão do wrapper (build 2063):
#  1 config set exige "SIM" digitado no console; 2 -Confirmed vindo de script chamador não vale;
#  3 -Identity diferente da padrão exige aprovação; 4 jvcs.exe fora de Arquivos de Programas preso ao SHA-256;
#  5 undocheckout sem alteração vale no modo manual; 6 sync: arquivo mais antigo, gravável e diferente = conflito;
#  7/8 regras do template e hook do Write de módulo apagado; 10 show -Dest dentro do projeto.
# ATENÇÃO: cria no servidor o projeto zz-teste-sg<Sufixo>.dpr (2 módulos) e faz checkout/undocheckout.
# Só rode contra um servidor de TESTE. APPDATA temporário; não toca no config.ini real nem nas identidades.
# Gravar COM BOM (PowerShell 5.1 + acentos).
param(
    [string]$Trabalho = (Join-Path $env:TEMP 'jvcs-testes'),
    [string]$Console = '',
    [string]$Sufixo = (Get-Date -Format 'yyMMddHHmm')
)
$ErrorActionPreference = 'Stop'
$Raiz = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$W = Join-Path $Raiz 'tools\ai\jvcs-ai.ps1'
$Hook = Join-Path $Raiz 'tools\ai\hooks\pretooluse.ps1'
$Lib = Join-Path $Raiz 'tools\ai\lib\jvcs-ai-common.ps1'
if (-not $Console) { $Console = Join-Path $Raiz 'bin\client\Win32\jvcs.exe' }
$runner = Join-Path $Raiz 'tests\console\golden.ps1'
$Base = Join-Path $Trabalho 'ia'
New-Item -ItemType Directory -Force $Base | Out-Null
$Base = (Get-Item -LiteralPath $Base).FullName
$enc = [Text.Encoding]::GetEncoding(1252)
$okN = 0; $falhas = 0; $pulados = 0
function Ok($c, $m) { if ($c) { "[OK] $m"; $script:okN++ } else { "[FALHA] $m"; $script:falhas++ } }
function Pular($m) { Write-Warning "[PULADO] $m"; $script:pulados++ }

$AD = Join-Path $Base 'appdata-seguranca'
New-Item -ItemType Directory -Force "$AD\JEDI\JVCS" | Out-Null
$cfgIni = "$AD\JEDI\JVCS\config.ini"
function Config([string]$Extra) {
    [IO.File]::WriteAllText($cfgIni, "[ai]`r`njvcsExe=$Console`r`nidentity=DEFAULT`r`ncheckout=auto`r`ncheckin=auto`r`n$Extra", (New-Object Text.UTF8Encoding($true)))
}
Config ''
$appdataOriginal = $env:APPDATA
$env:APPDATA = $AD
Remove-Item Env:\CLAUDECODE -ErrorAction SilentlyContinue
Remove-Item Env:\AI_AGENT -ErrorAction SilentlyContinue
# wrapper como processo; -Agente simula o Claude Code (CLAUDECODE=1)
function J {
    param([string]$Dir, [string[]]$A, [switch]$Agente)
    Push-Location $Dir
    try {
        if ($Agente) { $env:CLAUDECODE = '1' }
        $out = & powershell -NoProfile -ExecutionPolicy Bypass -File $W @A 2>&1 | Out-String
        $code = $LASTEXITCODE
    } finally { Remove-Item Env:\CLAUDECODE -ErrorAction SilentlyContinue; Pop-Location }
    $obj = $null
    try { $obj = $out | ConvertFrom-Json } catch { }
    return [pscustomobject]@{ Code = $code; Json = $obj; Out = $out }
}
function FuncaoDe([string]$Arquivo, [string]$Nome) {
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($Arquivo, [ref]$null, [ref]$null)
    $fn = $ast.FindAll({ param($x) $x -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $x.Name -eq $Nome }, $true) | Select-Object -First 1
    return $fn.Extent.Text
}

try {
# --- 1 e 2: funções isoladas (o processo deste teste não tem -Confirmed na linha de comando)
. ([scriptblock]::Create((FuncaoDe $Lib 'New-JaError')))
. ([scriptblock]::Create((FuncaoDe $Lib 'Assert-JaHumanApproval')))
. ([scriptblock]::Create((FuncaoDe $Lib 'Assert-JaInteractiveConfirm')))
$script:JaToolsDir = Join-Path $Raiz 'tools\ai'
$msg = ''
try { [void](Assert-JaInteractiveConfirm 'checkout auto'); $msg = 'gravou' } catch { $msg = $_.Exception.Message }
Ok ($msg -match 'não confirmado') "config set sem console interativo (stdin redirecionado) é recusado: $msg"
$r1 = $false
try { $r1 = Assert-JaHumanApproval -IsAgent $true -ConfirmedSwitch $true -InvocationLine '& jvcs-ai.ps1 checkin x -Confirmed' -InvocationScript '' -Why 'teste' } catch { }
Ok ($r1 -eq $true) '-Confirmed na linha de comando direta vale'
$msg = ''
try { [void](Assert-JaHumanApproval -IsAgent $true -ConfirmedSwitch $true -InvocationLine '& jvcs-ai.ps1 checkin x -Confirmed' -InvocationScript 'C:\temp\go.ps1' -Why 'teste'); $msg = 'aceitou' } catch { $msg = $_.Exception.Message }
Ok ($msg -match 'script chamador') "-Confirmed vindo de go.ps1 não vale: $msg"
$r1 = $false
try { $r1 = Assert-JaHumanApproval -IsAgent $true -ConfirmedSwitch $true -InvocationLine '& jvcs-ai.ps1 checkin x -Confirmed' -InvocationScript (Join-Path $Raiz 'tools\ai\hooks\stop.ps1') -Why 'teste' } catch { }
Ok ($r1 -eq $true) '-Confirmed vindo de um script do próprio tools\ai vale'

# --- 2 (processo real): go.ps1 chamando o wrapper com -Confirmed, em contexto de agente
$go = Join-Path $Base 'zz-teste-go.ps1'
[IO.File]::WriteAllText($go, "& '$W' projects -Identity zz-nao-existe -Confirmed`r`nexit `$LASTEXITCODE`r`n", (New-Object Text.UTF8Encoding($true)))
$env:CLAUDECODE = '1'
try { $out = & powershell -NoProfile -ExecutionPolicy Bypass -File $go 2>&1 | Out-String; $code = $LASTEXITCODE } finally { Remove-Item Env:\CLAUDECODE -ErrorAction SilentlyContinue }
$o = $null; try { $o = $out | ConvertFrom-Json } catch { }
Ok ($code -eq 10 -and $o.message -match 'script chamador') "go.ps1 + -Confirmed (agente) -> 10: $($o.message)"

# --- 3: -Identity diferente da padrão
$r = J $Base @('projects', '-Identity', 'zz-nao-existe') -Agente
Ok ($r.Code -eq 10 -and $r.Json.message -match 'identidade padrão') "-Identity diferente pela IA, sem -Confirmed -> 10 ($($r.Json.message))"
$r = J $Base @('projects', '-Identity', 'zz-nao-existe', '-Confirmed') -Agente
Ok ($r.Code -eq 4) "-Identity diferente com -Confirmed direto passa da aprovação (depois 4: não existe) -> $($r.Code)"
$r = J $Base @('projects', '-Identity', 'DEFAULT') -Agente
Ok ($r.Code -eq 0) '-Identity igual à padrão não pede aprovação'

# --- 4: jvcs.exe preso ao SHA-256 (fora de Arquivos de Programas)
$h = (Get-FileHash -LiteralPath $Console -Algorithm SHA256).Hash
Config "jvcsExeSha256=0000000000000000000000000000000000000000000000000000000000000000`r`n"
$r = J $Base @('projects')
Ok ($r.Code -eq 12 -and $r.Json.message -match 'mudou') "jvcs.exe com SHA-256 diferente do registrado -> 12 ($($r.Json.message))"
Config "jvcsExeSha256=$h`r`n"
$r = J $Base @('projects')
Ok ($r.Code -eq 0) 'jvcs.exe com o SHA-256 registrado -> 0'
Config ''

# --- projeto de teste
$prj = "zz-teste-sg$Sufixo.dpr"
"projeto de teste: $prj"
$P = Join-Path $Base "zz-teste-sg$Sufixo"
if (Test-Path -LiteralPath $P) { Get-ChildItem -LiteralPath $P -Recurse -Force | ForEach-Object { $_.Attributes = 'Normal' }; Remove-Item -Recurse -Force -LiteralPath $P }
New-Item -ItemType Directory -Force $P | Out-Null
$P = (Get-Item -LiteralPath $P).FullName
[IO.File]::WriteAllText("$P\$prj", "program x;`r`nbegin`r`nend.`r`n", $enc)
[IO.File]::WriteAllText("$P\u1.pas", "unit u1;`r`ninterface`r`nimplementation`r`nend.`r`n", $enc)
[IO.File]::WriteAllText("$P\m.prg", "// m`r`n", $enc)
& $runner -Nome 'sg_proj' -Exe $Console -Saida $Base -Cwd $P -Linhas @(
    "addproject $prj ""[zz-teste] seguranca - pode apagar""", "openproject $prj",
    'addmodule u1.pas', 'checkin u1.pas "[zz-teste] inicial"', 'addmodule m.prg', 'checkin m.prg "[zz-teste] inicial"') | Out-Null
$r = J $P @('list', '-Project', $prj)
Ok (@($r.Json.modules).Count -eq 2) "$prj com 2 módulos ($($r.Json.message))"

# --- 5: undocheckout sem alteração no modo manual
$r = J $P @('checkout', "$P\m.prg") -Agente
Ok ($r.Code -eq 0) "checkout m.prg (checkout=auto): $($r.Json.message)"
Config "checkin=manual`r`ncheckout=manual`r`n"
$r = J $P @('undocheckout', "$P\m.prg") -Agente
Ok ($r.Code -eq 0) "undocheckout sem alteração com checkin=manual (agente) -> 0: $($r.Json.message)"
$r = J $P @('checkout', "$P\m.prg") -Agente
Ok ($r.Code -eq 10) 'checkout com checkout=manual continua recusado (10)'
Config ''

# --- 6: sync com arquivo mais antigo, gravável e diferente do servidor
Set-ItemProperty "$P\m.prg" -Name IsReadOnly -Value $false
[IO.File]::WriteAllText("$P\m.prg", "// m editado sem checkout`r`n", $enc)
[IO.File]::SetLastWriteTime("$P\m.prg", (Get-Date).AddDays(-2))
$r = J $P @('sync', '-Project', $prj)
$m = @($r.Json.modules | Where-Object { $_.name -eq 'm.prg' })
Ok ($m.Count -eq 1 -and $m[0].action -eq 'conflict' -and $m[0].message -match 'somente leitura') "sync: m.prg mais antigo, gravável e diferente = conflict ($($m[0].message))"
Set-ItemProperty "$P\m.prg" -Name IsReadOnly -Value $true
$r = J $P @('sync', '-Project', $prj)
$m = @($r.Json.modules | Where-Object { $_.name -eq 'm.prg' })
Ok ($m.Count -eq 1 -and $m[0].action -eq 'update') "sync: o mesmo arquivo somente leitura = update ($($m[0].action))"

# --- 10: show -Dest dentro do projeto
$r = J $P @('show', "$P\u1.pas", '-Rev', '0.1', '-Dest', "$P\antigo")
Ok ($r.Code -eq 7) "show -Dest dentro da pasta do projeto -> 7 ($($r.Json.message))"
$fora = Join-Path $Base "zz-teste-sg-show$Sufixo"
$r = J $P @('show', "$P\u1.pas", '-Rev', '0.1', '-Dest', $fora)
Ok ($r.Code -eq 0 -and (Test-Path -LiteralPath (Join-Path $fora 'u1.pas'))) 'show -Dest fora do projeto grava'

# --- 8: hook, Write de módulo apagado e de unit nova
function Hook([string]$File) {
    $json = (@{ session_id = 'zz-teste'; hook_event_name = 'PreToolUse'; tool_name = 'Write'; tool_input = @{ file_path = $File; content = "unit x;`ninterface`nimplementation`nend.`n" } } | ConvertTo-Json -Compress)
    $out = $json | & powershell -NoProfile -ExecutionPolicy Bypass -File $Hook 2>&1 | Out-String
    return [pscustomobject]@{ Code = $LASTEXITCODE; Out = $out }
}
Set-ItemProperty "$P\u1.pas" -Name IsReadOnly -Value $false
Remove-Item -LiteralPath "$P\u1.pas" -Force
$hk = Hook "$P\u1.pas"
Ok ($hk.Code -eq 0 -and $hk.Out -match '"permissionDecision":\s*"deny"' -and $hk.Out -match 'Write contornaria') 'hook: Write de módulo apagado é negado'
$hk = Hook "$P\u2.pas"
Ok ($hk.Code -eq 0 -and $hk.Out -notmatch 'deny') 'hook: Write de unit nova (não é módulo) segue'

# --- 7: regras do template
$tj = Get-Content -Raw (Join-Path $Raiz 'tools\ai\claude\settings.template.json') | ConvertFrom-Json
Ok ((@('PowerShell(*Software*JEDI*)', 'Bash(*reg export*)') | Where-Object { $tj.permissions.deny -notcontains $_ }).Count -eq 0) 'template: deny para Software\JEDI e reg export'
Ok ((@('PowerShell(*-Identity*)', 'PowerShell(*Remove-Item*-Force*)') | Where-Object { $tj.permissions.ask -notcontains $_ }).Count -eq 0) 'template: ask para -Identity e Remove-Item -Force'
} finally {
    Remove-Item Env:\CLAUDECODE -ErrorAction SilentlyContinue
    $env:APPDATA = $appdataOriginal
}

"==== OK: $okN  FALHA: $falhas  PULADO: $pulados"
if ($falhas -gt 0) { exit 1 } else { exit 0 }
