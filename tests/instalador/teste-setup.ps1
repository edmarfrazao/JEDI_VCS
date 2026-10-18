# Teste isolado do instalador: atualização de um beta anterior (sem a tarefa aiconsole) para o
# setup em teste, a tarefa aiconsole (jvcsExe no config.ini), /TASKS=, /MERGETASKS=, /LOADINF
# e a desinstalação restaurando o config.ini.
# Tudo por usuário (/CURRENTUSER), numa pasta temporária, com /BDSKEY e /OLDIDEROOT desviados para
# HKCU\Software\JVCS2026Teste e /AICONFIG apontando para uma CÓPIA do config.ini: não toca no
# registro real das IDEs nem no config.ini real. Feche o Delphi antes de rodar.
# Gravar COM BOM (PowerShell 5.1 + acentos).
param(
    [string]$Trabalho = (Join-Path $env:TEMP 'jvcs-testes'),
    [string]$Setup = '',            # setup em teste (padrão: o de setup\Output do build de tools\versao.ini)
    [string]$SetupAnterior = ''     # setup de um beta anterior, sem a tarefa aiconsole (teste de atualização)
)
$ErrorActionPreference = 'Stop'
$Raiz = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$okN = 0; $falhas = 0; $pulados = 0
function Ok($cond, $msg) { if ($cond) { "[OK] $msg"; $script:okN++ } else { "[FALHA] $msg"; $script:falhas++ } }
function Pular($m) { Write-Warning "[PULADO] $m"; $script:pulados++ }

# --- setup em teste e versão esperada do jvcs.exe
$saidaSetup = Join-Path $Raiz 'setup\Output'
if (-not $Setup) {
    $build = ''
    $ini = Join-Path $Raiz 'tools\versao.ini'
    if (Test-Path -LiteralPath $ini) {
        $mb = Select-String -LiteralPath $ini -Pattern '^Build=(\d+)' | Select-Object -First 1
        if ($mb) { $build = $mb.Matches[0].Groups[1].Value }
    }
    $cand = $null
    if ($build) { $cand = Get-ChildItem -LiteralPath $saidaSetup -Filter "JediVCS-*-build$build-Setup.exe" -ErrorAction SilentlyContinue | Select-Object -First 1 }
    if (-not $cand) { $cand = Get-ChildItem -LiteralPath $saidaSetup -Filter 'JediVCS-*-Setup.exe' -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1 }
    if (-not $cand) { throw "nenhum JediVCS-*-Setup.exe em $saidaSetup; informe -Setup" }
    $Setup = $cand.FullName
}
if (-not (Test-Path -LiteralPath $Setup)) { throw "setup não encontrado: $Setup" }
function VersaoDoSetup($exe) {
    $m = [regex]::Match((Split-Path -Leaf $exe), '(?i)build(\d+)')
    if ($m.Success) { return "2.5.0.$($m.Groups[1].Value)" }
    return ''
}
$verNovo = VersaoDoSetup $Setup
"setup em teste: $Setup (jvcs.exe esperado: $(if ($verNovo) { $verNovo } else { 'não conferido' }))"
$temAnterior = [bool]($SetupAnterior -and (Test-Path -LiteralPath $SetupAnterior))
if ($temAnterior) { "setup anterior: $SetupAnterior" }
else { Pular 'atualização de beta anterior (passos 1, 2, 8 e 9): informe -SetupAnterior com o setup de um beta sem a tarefa aiconsole' }

$T    = Join-Path $Trabalho 'setup'
$Dir  = Join-Path $T 'inst'
$Cfg  = Join-Path $T 'config.ini'
$Comuns = @('/VERYSILENT', '/SUPPRESSMSGBOXES', '/CURRENTUSER', '/NORESTART',
            '/BDSKEY=Software\JVCS2026Teste\BDS', '/OLDIDEROOT=Software\JVCS2026Teste',
            "/AICONFIG=$Cfg")
function Rodar($exe, $nome, $extra, $alvo = $Dir) {
    $log = Join-Path $T "$nome.log"
    $argv = $Comuns + @("/DIR=$alvo", "/LOG=$log") + $extra
    $p = Start-Process -FilePath $exe -ArgumentList ($argv | ForEach-Object { if ($_ -match ' ') { '"' + $_ + '"' } else { $_ } }) -Wait -PassThru
    "---- $nome (código $($p.ExitCode))" | Out-Host
    $txt = ''; if (Test-Path -LiteralPath $log) { $txt = Get-Content -LiteralPath $log -Raw }
    return @{ Code = $p.ExitCode; Log = $txt }
}
function Desinstalar($pasta) {
    $u = Join-Path $pasta 'unins000.exe'
    if (-not (Test-Path -LiteralPath $u)) { return -1 }
    $p = Start-Process -FilePath $u -ArgumentList '/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART' -Wait -PassThru
    Start-Sleep -Seconds 2
    return $p.ExitCode
}
function JvcsExe() {
    $m = Select-String -LiteralPath $Cfg -Pattern '^jvcsExe=(.*)$' -ErrorAction SilentlyContinue
    if ($m) { return $m.Matches[0].Groups[1].Value } else { return '' }
}
function Versao($exe) { if (Test-Path -LiteralPath $exe) { (Get-Item -LiteralPath $exe).VersionInfo.FileVersion } else { '' } }

if (Test-Path -LiteralPath $T) { Remove-Item -Recurse -Force -LiteralPath $T }
New-Item -ItemType Directory -Force $T | Out-Null
# cópia do config.ini real (ou um vazio, se não houver); o real nunca é alterado
$cfgReal = Join-Path $env:APPDATA 'JEDI\JVCS\config.ini'
if (Test-Path -LiteralPath $cfgReal) { Copy-Item -LiteralPath $cfgReal -Destination $Cfg }
else { [IO.File]::WriteAllText($Cfg, "[ai]`r`n", [Text.Encoding]::ASCII) }
$hashIni = (Get-FileHash -LiteralPath $Cfg).Hash
$base = JvcsExe
"jvcsExe inicial da cópia: '$base'"
$exeNovo = Join-Path $Dir 'jvcs.exe'

if ($temAnterior) {
    # 1. beta anterior sem a tarefa (como estava por padrão)
    $r = Rodar $SetupAnterior '1-anterior' @('/COMPONENTS=client,ai,maps', '/TASKS=')
    Ok ($r.Code -eq 0) 'beta anterior instalado'
    $verAnt = VersaoDoSetup $SetupAnterior
    if ($verAnt) { Ok ((Versao $exeNovo) -eq $verAnt) "jvcs.exe $verAnt" }
    Ok ((JvcsExe) -eq $base) 'config.ini sem jvcsExe depois do beta anterior'
    # 2. setup novo por cima, sem /TASKS nem /COMPONENTS (atualização comum)
    $r = Rodar $Setup '2-atualiza' @()
    Ok ($r.Code -eq 0) 'setup novo instalado por cima'
    Ok ($r.Log -match 'tarefa aiconsole marcada') 'log: tarefa marcada por ser atualização do beta anterior'
} else {
    # 2'. sem beta anterior: instalação nova, tarefa marcada por padrão
    $r = Rodar $Setup '2-nova' @('/COMPONENTS=client,ai,maps')
    Ok ($r.Code -eq 0) 'setup novo instalado (instalação nova)'
}
if ($verNovo) { Ok ((Versao $exeNovo) -eq $verNovo) "jvcs.exe $verNovo" }
Ok ((JvcsExe) -eq $exeNovo) "config.ini com jvcsExe=$exeNovo"
$v = (& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $Dir 'tools\ai\jvcs-ai.ps1') help 2>&1 | Out-String)
Ok ($v -match '"ok":true') 'wrapper instalado responde help'
foreach ($rel in 'jvcs-ai.ps1', 'lib\jvcs-ai-common.ps1', 'claude\settings.template.json') {
    $a = Join-Path $Dir "tools\ai\$rel"; $b = Join-Path $Raiz "tools\ai\$rel"
    Ok ((Test-Path -LiteralPath $a) -and (Get-FileHash -LiteralPath $a).Hash -eq (Get-FileHash -LiteralPath $b).Hash) "tools\ai\$rel igual ao repositório"
}
foreach ($lang in 'pt', 'en') {
    $a = Join-Path $Dir "tools\ai\skills\$lang\jedi-vcs\SKILL.md"; $b = Join-Path $Raiz "skills\$lang\jedi-vcs\SKILL.md"
    Ok ((Test-Path -LiteralPath $a) -and (Get-FileHash -LiteralPath $a).Hash -eq (Get-FileHash -LiteralPath $b).Hash) "skill $lang igual ao repositório"
}

# 3. reinstalar sem /TASKS: a tarefa continua (lembrada), sem forçar de novo
$r = Rodar $Setup '3-reinstala' @()
Ok ($r.Code -eq 0) 'setup novo reinstalado'
Ok ($r.Log -notmatch 'tarefa aiconsole marcada') 'log: não força de novo (a versão instalada já tem a tarefa)'
Ok ((JvcsExe) -eq $exeNovo) 'jvcsExe mantido'

# 4. reinstalar com /TASKS= (desmarcar): volta ao original
$r = Rodar $Setup '4-sem-tarefa' @('/TASKS=')
Ok ($r.Code -eq 0) 'setup novo sem a tarefa'
Ok ((JvcsExe) -eq $base) 'jvcsExe removido'
Ok ((Get-FileHash -LiteralPath $Cfg).Hash -eq $hashIni) 'config.ini com o hash original'

# 5. reinstalar sem /TASKS: a escolha "desmarcada" agora é respeitada
$r = Rodar $Setup '5-respeita' @()
Ok ($r.Code -eq 0) 'setup novo reinstalado'
Ok ((JvcsExe) -eq $base) 'desmarcada continua desmarcada'

# 6. com /MERGETASKS=aiconsole: grava de novo; desinstalar restaura
$r = Rodar $Setup '6-merge' @('/MERGETASKS=aiconsole')
Ok ((JvcsExe) -eq $exeNovo) 'MERGETASKS=aiconsole grava jvcsExe'
Ok ((Desinstalar $Dir) -eq 0) 'desinstalado'
Ok ((Get-FileHash -LiteralPath $Cfg).Hash -eq $hashIni) 'config.ini restaurado (hash original)'
Ok (-not (Test-Path -LiteralPath $exeNovo)) 'arquivos removidos'

# 7. instalação nova (sem versão anterior): tarefa marcada por padrão
$r = Rodar $Setup '7-nova' @('/COMPONENTS=client,ai')
Ok ($r.Code -eq 0) 'instalação nova'
Ok ($r.Log -notmatch 'tarefa aiconsole marcada') 'log: sem forçar (não é atualização)'
Ok ((JvcsExe) -eq $exeNovo) 'instalação nova grava jvcsExe (padrão marcado)'
Ok ((Desinstalar $Dir) -eq 0) 'desinstalado'
Ok ((Get-FileHash -LiteralPath $Cfg).Hash -eq $hashIni) 'desinstalado: config.ini restaurado'
Ok (-not (Test-Path -LiteralPath $exeNovo)) 'pasta limpa'

if ($temAnterior) {
    # 8. beta anterior numa pasta, setup novo em OUTRA pasta sem /TASKS: marca (dados anteriores, não a pasta)
    $DirB = Join-Path $T 'inst-b'
    $r = Rodar $SetupAnterior '8a-anterior' @('/COMPONENTS=client,ai', '/TASKS=')
    Ok ((JvcsExe) -eq $base) 'beta anterior sem jvcsExe'
    $r = Rodar $Setup '8b-outra-pasta' @() $DirB
    $exeB = Join-Path $DirB 'jvcs.exe'
    Ok ($r.Code -eq 0) 'setup novo em outra pasta'
    Ok ($r.Log -match 'tarefa aiconsole marcada') 'log: marcada mesmo com outra pasta'
    Ok ((JvcsExe) -eq $exeB) "jvcsExe=$exeB"
    Ok ((Desinstalar $DirB) -eq 0) 'desinstalado (outra pasta)'
    Ok ((Get-FileHash -LiteralPath $Cfg).Hash -eq $hashIni) 'desinstalado: config.ini restaurado'
    if (Test-Path -LiteralPath $Dir) { Remove-Item -Recurse -Force -LiteralPath $Dir }

    # 9. beta anterior -> setup novo com /LOADINF (Tasks vazio): vale o .inf, não força
    $r = Rodar $SetupAnterior '9a-anterior' @('/COMPONENTS=client,ai', '/TASKS=')
    $inf = Join-Path $T 'tarefas.inf'
    [IO.File]::WriteAllText($inf, "[Setup]`r`nTasks=`r`n", [Text.Encoding]::ASCII)
    $r = Rodar $Setup '9b-loadinf' @("/LOADINF=$inf")
    Ok ($r.Code -eq 0) 'setup novo com /LOADINF'
    Ok ($r.Log -notmatch 'tarefa aiconsole marcada') 'log: /LOADINF manda (não força)'
    Ok ((JvcsExe) -eq $base) 'jvcsExe continua vazio'
    Ok ((Desinstalar $Dir) -eq 0) 'desinstalado'
    Ok ((Get-FileHash -LiteralPath $Cfg).Hash -eq $hashIni) 'desinstalado: config.ini com o hash original'
    Ok (-not (Test-Path -LiteralPath $exeNovo)) 'pasta limpa'
}

"==== OK: $okN  FALHA: $falhas  PULADO: $pulados"
if ($falhas -gt 0) { exit 1 } else { exit 0 }
