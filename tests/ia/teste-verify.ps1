# Testes do verify sem projeto definido (pasta sem .dpr, .jvcsproject nem mapa): o módulo é procurado
# em todos os projetos (1 projeto = usa; 2+ = ambiguous), as extensões que não existem como módulo no
# servidor são ignoradas (verifyExtensions muda o filtro) e o resumo do status conta 'error' exclusivo.
# ATENÇÃO: cria no servidor os projetos zz-teste-vfa<Sufixo>.dpr e zz-teste-vfb<Sufixo>.dpr (2 módulos,
# 1 deles compartilhado). Só rode contra um servidor de TESTE.
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
$okN = 0; $falhas = 0; $pulados = 0
function Ok($c, $m) { if ($c) { "[OK] $m"; $script:okN++ } else { "[FALHA] $m"; $script:falhas++ } }
function Pular($m) { Write-Warning "[PULADO] $m"; $script:pulados++ }

$AD = Join-Path $S 'appdata-verify'
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
function ByName($r) { $h = @{}; foreach ($m in @($r.Json.modules)) { $h[[string]$m.name] = $m }; return $h }

try {
# --- contagem exclusiva do 'error' (funções isoladas do wrapper)
$ast = [System.Management.Automation.Language.Parser]::ParseFile($W, [ref]$null, [ref]$null)
foreach ($n in @('Get-ItemStateKeys', 'Get-StateCounts', 'Test-OnlyMatch')) {
    $fn = $ast.FindAll({ param($x) $x -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $x.Name -eq $n }, $true) | Select-Object -First 1
    . ([scriptblock]::Create($fn.Extent.Text))
}
function Test-IsMe { param($Owner) return $false }
$script:JaOnlyLocal = @('clean', 'modified', 'missing', 'unknown', 'notVersioned', 'error')
$script:JaOnlyLock = @('mine', 'others', 'unlocked', 'locked')
$mods = @(
    [ordered]@{ localState = 'clean'; state = 'ok'; lockedBy = ''; exitCode = 0 },
    [ordered]@{ localState = 'modified'; state = 'ok'; lockedBy = ''; exitCode = 0 },
    [ordered]@{ localState = 'missing'; state = 'error'; lockedBy = ''; exitCode = 9 },
    [ordered]@{ localState = 'unknown'; state = 'error'; lockedBy = ''; exitCode = 9 }
)
$c = Get-StateCounts $mods
$soma = 0; foreach ($est in $script:JaOnlyLocal) { $soma += $c[$est] }
Ok ($c['error'] -eq 2 -and $c['missing'] -eq 0 -and $c['unknown'] -eq 0 -and $soma -eq $c['total']) "contagem: error exclusivo, soma $soma = total $($c['total'])"
$f = [pscustomobject]@{ Local = @('missing'); Lock = @(); Result = @() }
Ok (Test-OnlyMatch (Get-ItemStateKeys $mods[2]) $f) '-Only missing ainda acha o módulo com erro cujo localState é missing'
$f = [pscustomobject]@{ Local = @('error'); Lock = @(); Result = @() }
Ok ((Test-OnlyMatch (Get-ItemStateKeys $mods[3]) $f) -and -not (Test-OnlyMatch (Get-ItemStateKeys $mods[1]) $f)) '-Only error acha só os módulos com erro'

# --- verify sem projeto definido
$git = Get-Command git.exe -ErrorAction SilentlyContinue
if (-not $git) { Pular 'verify sem projeto: git.exe não encontrado no PATH' }
else {
    $pa = "zz-teste-vfa$Sufixo.dpr"; $pb = "zz-teste-vfb$Sufixo.dpr"
    "projetos de teste: $pa e $pb"
    $T = Join-Path $S "zz-teste-vf$Sufixo"
    if (Test-Path -LiteralPath $T) { Get-ChildItem -LiteralPath $T -Recurse -Force | ForEach-Object { $_.Attributes = 'Normal' }; Remove-Item -Recurse -Force -LiteralPath $T }
    New-Item -ItemType Directory -Force "$T\src" | Out-Null
    $G = (Get-Item -LiteralPath "$T\src").FullName
    [IO.File]::WriteAllText("$G\a.prg", "// a`r`n", $enc)
    [IO.File]::WriteAllText("$G\b.prg", "// b`r`n", $enc)
    [IO.File]::WriteAllText("$G\n.prg", "// n`r`n", $enc)
    [IO.File]::WriteAllText("$G\x.zzq", "x`r`n", $enc)
    & $runner -Nome 'vf_proj' -Exe $Console -Saida $S -Cwd $G -Linhas @(
        "addproject $pa ""[zz-teste] verify sem projeto - pode apagar""", "openproject $pa",
        'addmodule a.prg', 'checkin a.prg "[zz-teste] inicial"', 'addmodule b.prg', 'checkin b.prg "[zz-teste] inicial"',
        "addproject $pb ""[zz-teste] verify sem projeto - pode apagar""", "openproject $pb", 'addmodule b.prg') | Out-Null
    $r = J $G @('list', '-Project', $pa)
    if (@($r.Json.modules).Count -ne 2) { Get-Content "$S\vf_proj.txt" | Select-Object -Last 15 }
    Ok (@($r.Json.modules).Count -eq 2) "$pa com 2 módulos ($($r.Json.message))"
    function RunGit { param([string[]]$A) & git.exe -C $G @A 2>&1 | Out-Null; if ($LASTEXITCODE -ne 0) { throw "git $A" } }
    RunGit @('init', '-q'); RunGit @('config', 'user.email', 'teste@exemplo.invalid'); RunGit @('config', 'user.name', 'teste')
    RunGit @('add', '.'); RunGit @('commit', '-q', '-m', 'inicial')
    foreach ($n in @('a.prg', 'b.prg', 'n.prg', 'x.zzq')) {
        Set-ItemProperty "$G\$n" -Name IsReadOnly -Value $false
        [IO.File]::AppendAllText("$G\$n", "// mudou no Git`r`n", $enc)
    }
    RunGit @('add', '.'); RunGit @('commit', '-q', '-m', 'mudancas')

    $r = J $G @('verify', '-FromGit', 'HEAD~1')
    $v = ByName $r
    Ok ($r.Code -eq 7) "verify sem projeto: código 7 ($($r.Json.message))"
    Ok ($v['a.prg'].verify -eq 'modifiedNoLock' -and [string]$v['a.prg'].project -ieq $pa) "a.prg: modifiedNoLock, achado no projeto $($v['a.prg'].project) ($($v['a.prg'].projectFrom))"
    Ok ($v['b.prg'].verify -eq 'ambiguous' -and @($v['b.prg'].projects).Count -eq 2) "b.prg (em 2 projetos): ambiguous ($($v['b.prg'].message))"
    Ok ($v['n.prg'].verify -eq 'notVersioned') "n.prg (não é módulo): notVersioned ($($v['n.prg'].message))"
    Ok (-not $v.ContainsKey('x.zzq') -and $r.Json.counts.ignored -eq 1) "x.zzq (extensão sem módulo no servidor) ignorado: counts.ignored $($r.Json.counts.ignored)"
    Ok ($r.Json.counts.problems -eq 2 -and $r.Json.counts.unresolved -eq 1) "counts: problems $($r.Json.counts.problems), unresolved $($r.Json.counts.unresolved)"

    $r = J $G @('verify', '-FromGit', 'HEAD~1', '-All')
    $v = ByName $r
    Ok ($v['x.zzq'].verify -eq 'ignored') "-All lista o ignorado: $($v['x.zzq'].message)"

    $r = J $G @('verify', '-FromGit', 'HEAD~1', '-Project', $pa)
    $v = ByName $r
    Ok ($v['b.prg'].verify -eq 'modifiedNoLock' -and $v['a.prg'].verify -eq 'modifiedNoLock') '-Project resolve a ambiguidade: a.prg e b.prg modifiedNoLock'

    # saída -Text: o veredito (campo verify) e os projetos do ambiguous como texto
    Push-Location $G
    try { $txt = & powershell -NoProfile -ExecutionPolicy Bypass -File $W verify -FromGit 'HEAD~1' -Text 2>&1 | Out-String } finally { Pop-Location }
    Ok ($txt -match 'b\.prg[^\r\n]*-> ambiguous' -and $txt -match 'n\.prg[^\r\n]*-> notVersioned' -and $txt -match 'a\.prg[^\r\n]*-> modifiedNoLock') '-Text mostra o verify (ambiguous, notVersioned, modifiedNoLock), não o state'
    Ok ($txt -match ('projetos: ' + [regex]::Escape($pa) + ', ' + [regex]::Escape($pb))) "-Text lista os projetos do ambiguous ($(([regex]::Match($txt, 'projetos: [^\r\n]*')).Value))"

    # arquivos avulsos (sem Git): mesma lógica; o filtro de extensões não vale para eles
    $r = J $G @('verify', "$G\a.prg", "$G\b.prg", "$G\n.prg", "$G\x.zzq", "$G\sumiu.prg")
    $v = ByName $r
    Ok ($r.Code -eq 7 -and $v['a.prg'].verify -eq 'modifiedNoLock' -and $v['b.prg'].verify -eq 'ambiguous' -and $v['n.prg'].verify -eq 'notVersioned') "verify avulso: a modifiedNoLock, b ambiguous, n notVersioned (código $($r.Code))"
    Ok ($v['x.zzq'].verify -eq 'notVersioned' -and $r.Json.counts.ignored -eq 0) 'verify avulso: x.zzq conferido (o filtro de extensões não vale para arquivo pedido pelo nome)'
    Ok ($v['sumiu.prg'].verify -eq 'localMissing') "verify avulso: arquivo inexistente = localMissing ($($v['sumiu.prg'].message))"
    $r = J $G @('verify', "$G\a.prg", '-Project', $pa)
    Ok ($r.Code -eq 7 -and $r.Json.modules[0].verify -eq 'modifiedNoLock') 'verify avulso com -Project'
    $r = J $G @('verify', "$G\a.prg", '-FromGit', 'HEAD~1')
    Ok ($r.Code -eq 2) 'verify avulso + -FromGit -> 2'
    $r = J $G @('verify')
    Ok ($r.Code -eq 2 -and $r.Json.message -match 'arquivo') "verify sem nada -> 2 ($($r.Json.message))"

    $r = J $G @('verify', '-FromGit', 'HEAD~1', '-Pattern', '*.zzq')
    Ok ($r.Code -eq 3) "só arquivos de extensão ignorada -> 3 ($($r.Json.message))"

    Config "verifyExtensions=all`r`n"
    $r = J $G @('verify', '-FromGit', 'HEAD~1')
    $v = ByName $r
    Ok ($v['x.zzq'].verify -eq 'notVersioned' -and $r.Json.counts.ignored -eq 0) 'verifyExtensions=all: x.zzq conferido (notVersioned)'
    Config "verifyExtensions=.zzq`r`n"
    $r = J $G @('verify', '-FromGit', 'HEAD~1')
    Ok ($r.Json.counts.ignored -eq 3 -and @($r.Json.modules).Count -eq 1) "verifyExtensions=.zzq: só x.zzq conferido ($($r.Json.counts.ignored) ignorados)"
    Config ''
    # validação do valor (o config set é do usuário: a IA recebe 10, por isso a função isolada)
    $astC = [System.Management.Automation.Language.Parser]::ParseFile((Join-Path $Raiz 'tools\ai\lib\jvcs-ai-common.ps1'), [ref]$null, [ref]$null)
    $fnC = $astC.FindAll({ param($x) $x -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $x.Name -eq 'Test-JaConfigValue' }, $true) | Select-Object -First 1
    . ([scriptblock]::Create($fnC.Extent.Text))
    Ok ((Test-JaConfigValue -Key 'verifyExtensions' -Value '*.prg') -and -not (Test-JaConfigValue -Key 'verifyExtensions' -Value '.prg;.ch') -and -not (Test-JaConfigValue -Key 'verifyExtensions' -Value 'all')) 'verifyExtensions: *.prg recusado; .prg;.ch e all aceitos'

    # status do projeto: a soma dos estados bate com o total
    $r = J $G @('status', '-Project', $pa)
    $sum = 0; foreach ($est in @('clean', 'modified', 'missing', 'unknown', 'notVersioned', 'error')) { if ($r.Json.counts.$est) { $sum += [int]$r.Json.counts.$est } }
    Ok ($sum -eq [int]$r.Json.counts.total) "status -Project: soma dos estados $sum = total $($r.Json.counts.total) ($($r.Json.message))"
}
} finally {
    $env:APPDATA = $appdataOriginal
}

"==== OK: $okN  FALHA: $falhas  PULADO: $pulados"
if ($falhas -gt 0) { exit 1 } else { exit 0 }
