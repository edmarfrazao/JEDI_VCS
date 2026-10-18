# Testes do wrapper tools\ai\jvcs-ai.ps1 (pedido S0002 e menores): opções inválidas, doctor/ping,
# Test-JaTcpPort, locks -OlderThan, status -AllProjects, untracked (pasta, 8.3 x longo, -FromXbp),
# add -Preview, verify (-FromGit, -Since), checkin -CommentFromGit e diff -Encoding oem.
# ATENÇÃO: cria no servidor o projeto zz-teste-ia<Sufixo>.dpr com 4 módulos e faz checkout/checkin
# neles. Só rode contra um servidor de TESTE.
# Usa um APPDATA temporário (config.ini próprio, [ai] identity=DEFAULT); não toca no config.ini
# real nem nas identidades do registro. Gravar COM BOM (PowerShell 5.1 + acentos).
param(
    [string]$Trabalho = (Join-Path $env:TEMP 'jvcs-testes'),
    [string]$Console = '',              # padrão: bin\client\Win32\jvcs.exe do repositório
    [string]$Sufixo = (Get-Date -Format 'yyMMddHHmm'),
    [string]$ProjetoExemplo = '',       # projeto existente com 2+ módulos (status -AllProjects / -Project)
    [string]$PastaExemplo = '',         # pasta local de um projeto versionado (untracked -Path)
    [string]$UnitNaoVersionada = '',    # arquivo *.pas dessa pasta que NÃO está no servidor
    [string]$UnitVersionada = '',       # arquivo *.pas dessa pasta que está no servidor
    [string]$PastaModulos = '',         # pasta criada pelo console\teste-modulos.ps1 (padrão: a mais recente)
    [int]$PortaFechada = 2109           # porta local sem ninguém escutando
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

# APPDATA de teste com checkout/checkin automáticos (a IA não é simulada: contexto humano)
$AD = Join-Path $S 'appdata'
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

try {
# --- menores: opções inválidas
$r = J $S @('status', 'x.pas', '-Foo', 'bar')
Ok ($r.Code -eq 2 -and $r.Json.message -match 'parâmetro desconhecido: -Foo') 'opção desconhecida -> 2 (parâmetro desconhecido)'
$r = J $S @('diff', 'x.pas', '-Encoding', 'xyz')
Ok ($r.Code -eq 2) '-Encoding inválido -> 2'
$r = J $S @('locks', '-OlderThan', 'ontem')
Ok ($r.Code -eq 2) '-OlderThan inválido -> 2'
$r = J $S @('list', '-AllProjects')
Ok ($r.Code -eq 2) '-AllProjects fora do status -> 2'

# --- doctor / ping
$r = J $S @('doctor')
Ok ($r.Code -eq 0 -and $r.Json.ok) "doctor ok: $($r.Json.message)"
$chk = @($r.Json.checks | ForEach-Object { $_.check })
Ok ((@('config', 'jvcsExe', 'fvcscrypt.dll', 'identity', 'port', 'login') | Where-Object { $chk -notcontains $_ }).Count -eq 0) 'doctor: config, jvcsExe, fvcscrypt.dll, identity, port e login'
Ok (@($r.Json.checks | Where-Object { $_.check -eq 'port' })[0].detail -match 'responde em \d+ ms') 'doctor: latência da porta'
$lg = [string](@($r.Json.checks | Where-Object { $_.check -eq 'login' })[0].detail)
Ok ($lg -match '\S') "doctor: detalhe do login ($lg)"
$r = J $S @('ping')
Ok ($r.Code -eq 0 -and $r.Json.command -eq 'ping') 'ping = doctor'
# Test-JaTcpPort isolado; host e porta lidos da identidade DEFAULT (só HostName e Port)
$ast = [System.Management.Automation.Language.Parser]::ParseFile($W, [ref]$null, [ref]$null)
$fn = $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq 'Test-JaTcpPort' }, $true) | Select-Object -First 1
. ([scriptblock]::Create($fn.Extent.Text))
$t = Test-JaTcpPort -HostName 'localhost' -Port $PortaFechada -TimeoutMs 2000
Ok ((-not $t.Open) -and $t.Error) "porta fechada detectada: $($t.Error)"
$idk = Get-Item -LiteralPath 'HKCU:\Software\JEDI\JEDIVCS\Identities\DEFAULT'
$t = Test-JaTcpPort -HostName ([string]$idk.GetValue('HostName')) -Port ([int]$idk.GetValue('Port')) -TimeoutMs 2000
Ok ($t.Open) "porta do servidor aberta ($($t.Ms) ms)"

# --- status -AllProjects
$r = J $S @('status', '-AllProjects')
Ok ($r.Code -eq 0 -or $r.Code -eq 11) "status -AllProjects: código $($r.Code); $($r.Json.message)"
$names = @($r.Json.projects | ForEach-Object { $_.name })
if ($ProjetoExemplo) {
    Ok ($names -contains $ProjetoExemplo) "projects[] com $ProjetoExemplo ($($names.Count) projetos)"
    $pe = @($r.Json.projects | Where-Object { $_.name -eq $ProjetoExemplo })[0]
    Ok ($pe -and $pe.total -ge 2) "$($ProjetoExemplo): total $($pe.total), clean $($pe.clean), modified $($pe.modified)"
    Ok ($pe -and @($r.Json.modules | Where-Object { $_.project -eq $ProjetoExemplo }).Count -eq $pe.total) 'módulos marcados com o projeto'
} else { Pular 'status -AllProjects com projeto conhecido: informe -ProjetoExemplo' }
$r = J $S @('status', '-AllProjects', '-Only', 'modified')
Ok (@($r.Json.modules | Where-Object { $_.localState -ne 'modified' }).Count -eq 0) 'status -AllProjects -Only modified filtra'

# --- untracked numa pasta de projeto versionado
if ($PastaExemplo -and $UnitNaoVersionada -and $UnitVersionada) {
    $r = J $S @('untracked', '-Path', $PastaExemplo, '-Pattern', '*.pas')
    $un = @($r.Json.modules | ForEach-Object { $_.name })
    Ok ($r.Code -eq 0 -and ($un -contains $UnitNaoVersionada) -and ($un -notcontains $UnitVersionada)) "untracked *.pas: $($un -join ', ') ($($r.Json.message))"
    $r = J $S @('untracked', '-Path', $PastaExemplo, '-All')
    Ok (@($r.Json.modules | Where-Object { $_.state -eq 'versioned' }).Count -ge 1) 'untracked -All mostra também os versionados'
} else { Pular 'untracked numa pasta de projeto: informe -PastaExemplo, -UnitNaoVersionada e -UnitVersionada' }

# --- untracked: pasta gravada em 8.3, pedida na forma longa (pasta do teste-modulos)
if (-not $PastaModulos) {
    $cand = Get-ChildItem -LiteralPath (Join-Path $Trabalho 'console') -Directory -Filter 'zz-teste-mod*' -ErrorAction SilentlyContinue |
        Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'zz-teste-83.ok') } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($cand) { $PastaModulos = $cand.FullName }
}
if ($PastaModulos -and (Test-Path -LiteralPath $PastaModulos)) {
    $r = J $S @('untracked', '-Path', $PastaModulos, '-Pattern', '*.txt', '-All')
    $x = @($r.Json.modules | Where-Object { $_.name -eq 'x.txt' })
    Ok ($x.Count -eq 1 -and $x[0].state -eq 'versioned') 'x.txt (pasta gravada em 8.3, pedida na forma longa) = versioned'
    $sr = @($r.Json.modules | Where-Object { $_.name -eq 'semrev.txt' })
    Ok ($sr.Count -eq 1 -and $sr[0].state -eq 'untracked') 'semrev.txt (apagado do arquivo) = untracked'
} else { Pular 'untracked com pasta em 8.3: rode antes console\teste-modulos.ps1 (com nomes 8.3) ou informe -PastaModulos' }

# --- untracked -FromXbp: .xbp com caminhos relativos à raiz
$X = Join-Path $S 'xbp'
if (Test-Path -LiteralPath $X) { Remove-Item -Recurse -Force -LiteralPath $X }
New-Item -ItemType Directory -Force "$X\APP\xhb", "$X\APP\SRC" | Out-Null
[IO.File]::WriteAllText("$X\APP\SRC\NOVO.PRG", "func x`r`n", $enc)
[IO.File]::WriteAllText("$X\APP\xhb\TESTE.exe.xbp", "[TESTE.exe]`r`nX=1`r`n[APP\SRC\NOVO.PRG]`r`n[APP\SRC\SUMIU.PRG]`r`n[APP\SRC\NOVO.PRG]`r`n", $enc)
$r = J $S @('untracked', '-FromXbp', "$X\APP\xhb\TESTE.exe.xbp")
$st = @{}; foreach ($m in $r.Json.modules) { $st[$m.name] = $m.state }
Ok ($st['NOVO.PRG'] -eq 'untracked' -and $st['SUMIU.PRG'] -eq 'localMissing' -and -not $st.ContainsKey('TESTE.exe')) "untracked -FromXbp: NOVO untracked, SUMIU localMissing, alvo ignorado ($($r.Json.message))"

# --- projeto de teste: add, add -Preview, locks -OlderThan, verify, -CommentFromGit, diff -Encoding
$prj = "zz-teste-ia$Sufixo.dpr"
"projeto de teste: $prj"
$G = Join-Path $S "zz-teste-ia$Sufixo"
if (Test-Path -LiteralPath $G) { Get-ChildItem -LiteralPath $G -Recurse -Force | ForEach-Object { $_.Attributes = 'Normal' }; Remove-Item -Recurse -Force -LiteralPath $G }
New-Item -ItemType Directory -Force $G | Out-Null
$G = (Get-Item -LiteralPath $G).FullName
[IO.File]::WriteAllText("$G\$prj", "program x;`r`nbegin`r`nend.`r`n", $enc)
[IO.File]::WriteAllText("$G\a.prg", "// a`r`nfunc a()`r`n", $enc)
[IO.File]::WriteAllText("$G\b.prg", "// b`r`n", $enc)
[IO.File]::WriteAllText("$G\lk.prg", "// lock`r`n", $enc)
$oem = [Text.Encoding]::GetEncoding(850)
[IO.File]::WriteAllBytes("$G\c.prg", $oem.GetBytes("// ação inicial`r`nfunc c()`r`n"))
& $runner -Nome 'ia_proj' -Exe $Console -Saida $S -Cwd $G -Linhas @("addproject $prj ""[zz-teste] S0002 verify - pode apagar""") | Out-Null
$r = J $G @('add', "$G\$prj", "$G\a.prg", "$G\c.prg", "$G\lk.prg", '-Comment', '[zz-teste] versao inicial', '-Project', $prj)
Ok ($r.Code -eq 0 -and @($r.Json.modules | Where-Object { $_.state -eq 'added' }).Count -eq 4) "add de 4 módulos ($($r.Json.message))"
$r = J $G @('add', "$G\b.prg", '-Comment', '[zz-teste] previa', '-Preview', '-Project', $prj)
Ok ($r.Code -eq 0 -and $r.Json.modules[0].state -eq 'wouldAdd') "add -Preview: wouldAdd ($($r.Json.modules[0].message))"
$r = J $G @('untracked')
Ok (@($r.Json.modules | Where-Object { $_.name -eq 'b.prg' -and $_.state -eq 'untracked' }).Count -eq 1) 'depois do -Preview, b.prg continua untracked (nada gravado)'

# locks -OlderThan com um lock recém-criado em lk.prg
$r = J $G @('checkout', "$G\lk.prg", '-Force', '-Confirmed')
Ok ($r.Code -eq 0) "checkout lk.prg: $($r.Json.message)"
try {
    $r = J $S @('locks', '-NoLocalState')
    $m = @($r.Json.modules | Where-Object { $_.name -eq 'lk.prg' -and $_.dir -like "*$(Split-Path -Leaf $G)*" })
    if ($m.Count -eq 0) { $m = @($r.Json.modules | Where-Object { $_.name -eq 'lk.prg' }) }
    Ok ($m.Count -ge 1 -and $m[0].lockedAtLocal -and $null -ne $m[0].lockAgeDays) "locks: lockedAtLocal $($m[0].lockedAtLocal), lockAgeDays $($m[0].lockAgeDays)"
    if ($m.Count -ge 1 -and $m[0].lockedAtLocal) {
        $local = [datetime]::ParseExact($m[0].lockedAtLocal, 'yyyy-MM-dd HH:mm:ss', $null)
        Ok ([Math]::Abs(((Get-Date) - $local).TotalMinutes) -lt 5) 'lockedAtLocal = hora local de agora (UTC convertido)'
        $lid = $m[0].id
        $r = J $S @('locks', '-NoLocalState', '-OlderThan', '1h')
        Ok ($r.Code -eq 0 -and @($r.Json.modules | Where-Object { $_.id -eq $lid }).Count -eq 0) 'locks -OlderThan 1h: o lock recém-criado não aparece'
        $r = J $S @('locks', '-All', '-NoLocalState', '-OlderThan', '0h')
        Ok (@($r.Json.modules | Where-Object { $_.id -eq $lid }).Count -eq 1) 'locks -All -OlderThan 0h: aparece'
    }
} finally {
    $r = J $G @('undocheckout', "$G\lk.prg")
    Ok ($r.Code -eq 0) "undocheckout lk.prg: $($r.Json.message)"
}

$git = Get-Command git.exe -ErrorAction SilentlyContinue
if (-not $git) {
    Pular 'verify -FromGit e checkin -CommentFromGit: git.exe não encontrado no PATH'
} else {
    function RunGit { param([string[]]$A) & git.exe -C $G @A 2>&1 | Out-Null; if ($LASTEXITCODE -ne 0) { throw "git $A" } }
    RunGit @('init', '-q'); RunGit @('config', 'user.email', 'teste@exemplo.invalid'); RunGit @('config', 'user.name', 'teste')
    RunGit @('add', '.'); RunGit @('commit', '-q', '-m', 'inicial')
    Set-ItemProperty "$G\a.prg" -Name IsReadOnly -Value $false
    [IO.File]::AppendAllText("$G\a.prg", "// mudou no Git`r`n", $enc)
    [IO.File]::AppendAllText("$G\b.prg", "// b mudou`r`n", $enc)
    RunGit @('add', '.'); RunGit @('commit', '-q', '-m', 'S0002: a.prg ajustado no Git - ação')
    $r = J $G @('verify', '-FromGit', 'HEAD~1')
    $v = @{}; foreach ($m in $r.Json.modules) { $v[$m.name] = $m.verify }
    Ok ($r.Code -eq 7 -and $v['a.prg'] -eq 'modifiedNoLock' -and $v['b.prg'] -eq 'notVersioned') "verify -FromGit HEAD~1: a.prg modifiedNoLock, b.prg notVersioned (código $($r.Code))"
    $r = J $G @('verify', '-FromGit', '--output=x')
    Ok ($r.Code -eq 2) 'verify -FromGit com opção do git é recusado (2)'
    # -CommentFromGit: checkout + checkin do a.prg com o assunto do último commit
    $r = J $G @('checkout', "$G\a.prg", '-Force', '-Confirmed')
    Ok ($r.Code -eq 0) "checkout -Force: $($r.Json.message)"
    $r = J $G @('checkin', "$G\a.prg", '-CommentFromGit')
    Ok ($r.Code -eq 0) "checkin -CommentFromGit: $($r.Json.message)"
    $r = J $G @('history', "$G\a.prg", '-Max', '1')
    Ok ([string]$r.Json.modules[0].revisions[0].comment -match 'S0002: a.prg ajustado no Git - ação$') "comentário da revisão = assunto do commit: '$($r.Json.modules[0].revisions[0].comment)'"
    $r = J $G @('checkin', "$G\a.prg", '-CommentFromGit', '-Comment', 'x')
    Ok ($r.Code -eq 2) '-Comment com -CommentFromGit -> 2'
}
$r = J $G @('verify', '-Since', '1h', '-Pattern', 'c.prg')
Ok ($r.Code -eq 0 -and $r.Json.modules[0].verify -eq 'ok') 'verify -Since 1h -Pattern c.prg: ok (igual ao servidor)'

# diff -Encoding oem (c.prg em CP850)
Set-ItemProperty "$G\c.prg" -Name IsReadOnly -Value $false
[IO.File]::WriteAllBytes("$G\c.prg", $oem.GetBytes("// ação inicial`r`nfunc c()`r`n// revisão local`r`n"))
$r = J $G @('diff', "$G\c.prg", '-Encoding', 'oem')
$d = [string]$r.Json.modules[0].diff
if (-not $d) { $d = [string]$r.Json.diff }
Ok ($d -match '\+// revisão local' -and $d -match 'ação') 'diff -Encoding oem mostra os acentos do CP850'
$r = J $G @('diff', "$G\c.prg")
$d2 = [string]$r.Json.modules[0].diff
if (-not $d2) { $d2 = [string]$r.Json.diff }
Ok ($d2 -notmatch 'revisão local') 'sem -Encoding, o CP850 sai como cp1252 (acentos trocados)'
[IO.File]::WriteAllBytes("$G\c.prg", $oem.GetBytes("// ação inicial`r`nfunc c()`r`n"))

# --- regressão rápida
if ($ProjetoExemplo) {
    $r = J $S @('status', '-Project', $ProjetoExemplo)
    Ok ($r.Code -eq 0 -and $r.Json.message -match ('módulo\(s\) em ' + [regex]::Escape($ProjetoExemplo))) "status -Project $($ProjetoExemplo): $($r.Json.message)"
} else { Pular 'status -Project: informe -ProjetoExemplo' }
$r = J $S @('locks')
Ok ($r.Code -eq 0) "locks: $($r.Json.message)"
} finally {
    $env:APPDATA = $appdataOriginal
}

"==== OK: $okN  FALHA: $falhas  PULADO: $pulados"
if ($falhas -gt 0) { exit 1 } else { exit 0 }
