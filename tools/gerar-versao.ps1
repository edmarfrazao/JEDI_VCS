# ==========================================================================
#  gerar-versao.ps1 - gera o cabecalho de versao a partir de tools\versao.ini
#
#  Uso:
#    gerar-versao.ps1 [-Brcc <brcc32.exe>] [-Rc <a.rc>,<b.rc>...]
#    gerar-versao.ps1 -Mostrar <Campo>
#
#  Sempre grava src\common\jvcsversao.rh (#define com FILEVERSION,
#  PRODUCTVERSION, FILEFLAGS e as strings do VERSIONINFO; BuildTimestamp =
#  agora). O arquivo e gerado (esta no .gitignore): NAO edite, edite o .ini.
#  Com -Rc, compila cada .rc com o brcc32 (-Brcc) para o .res de mesmo nome
#  ao lado dele (ex.: src\jedivcs\jvcsver.rc -> src\jedivcs\jvcsver.res).
#  -Mostrar so imprime um valor (FileVersion, Build, Stage, StageNumber,
#  InternalVersion, BuildType, VCS, Label, SetupBase - nome do instalador sem
#  .exe, o mesmo que o setup\JediVCS2026.iss monta com ReadIni) e sai, sem gravar nada - para os
#  .bat (for /f).
#
#  Chamado por tools\compilar.bat (gera os jvcsver.res do cliente, do Diff e
#  do console) e tools\compilar-expert.bat (so o cabecalho; o brcc32 do
#  JvcsExpertBDS_ver.rc fica com ele). Para compilar pela IDE sem os scripts,
#  rode antes:  powershell -File tools\gerar-versao.ps1 -Brcc <brcc32.exe>
#               -Rc src\jedivcs\jvcsver.rc,src\jedivcsdiff\jvcsver.rc,src\jvcs\jvcsver.rc
#
#  Codigo de saida: 0 = OK; 1 = versao.ini invalido ou falha do brcc32.
# ==========================================================================
param(
    [string]$Brcc,
    [string[]]$Rc,
    [string]$Mostrar
)
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$ini = Join-Path $PSScriptRoot 'versao.ini'
$rh = Join-Path $root 'src\common\jvcsversao.rh'

function Fail([string]$msg) {
    [Console]::Error.WriteLine("[ERRO] gerar-versao: $msg")
    exit 1
}

# ---- versao.ini --------------------------------------------------------------
if (-not (Test-Path -LiteralPath $ini)) { Fail "nao encontrado: $ini" }
$kv = @{}
$sec = ''
foreach ($line in Get-Content -LiteralPath $ini) {
    $l = $line.Trim()
    if ($l -eq '' -or $l.StartsWith(';')) { continue }
    if ($l -match '^\[(.+)\]$') { $sec = $Matches[1]; continue }
    if ($sec -ieq 'Versao' -and $l -match '^([^=]+)=(.*)$') { $kv[$Matches[1].Trim()] = $Matches[2].Trim() }
}

$build = 0
if (-not [int]::TryParse([string]$kv['Build'], [ref]$build) -or $build -lt 2000 -or $build -gt 2999) {
    Fail "Build invalido em versao.ini: '$($kv['Build'])' (esperado 2000..2999)"
}
$stage = [string]$kv['Stage']
$stageNum = 0
if ($stage -ieq 'Beta') {
    $stage = 'Beta'
    if (-not [int]::TryParse([string]$kv['StageNumber'], [ref]$stageNum) -or $stageNum -lt 1 -or $stageNum -gt 9) {
        Fail "StageNumber invalido em versao.ini: '$($kv['StageNumber'])' (1..9)"
    }
    $base = 2000 + $stageNum * 10
    if ($build -lt $base -or $build -gt $base + 9) {
        Fail "Build $build nao segue a regra da beta $stageNum ($base..$($base + 9)): beta N = 2000 + N*10, correcoes +1"
    }
} elseif ($stage -ieq 'Release') {
    $stage = 'Release'
    if ($build -lt 2100) { Fail "Build $build invalido para Release (versao final = 2100 ou maior)" }
} else {
    Fail "Stage invalido em versao.ini: '$stage' (Beta ou Release)"
}

# ---- valores ----------------------------------------------------------------
# 2.5.0 fixo: o PRODUCTVERSION numerico 2,5,0,0 vira a versao 250 do LOGIN
# (VCSProcBase.GetJVCSAppProductVersionInt) - nao mude.
$url = 'https://github.com/edmarfrazao/JEDI_VCS'
$fileVer = "2.5.0.$build"
if ($stage -eq 'Beta') {
    $internal = "2.5.0 Beta $stageNum (2026)"
    $vcs = "JVCS $fileVer Beta $stageNum (2026) $url"
    $buildType = 'Beta Build'
    $flags = '0x2L'   # VS_FF_PRERELEASE
    $label = "2.5.0 Beta $stageNum - build $build"
    $setupBase = "JediVCS-2.5.0-Beta$stageNum-build$build-Setup"
} else {
    $internal = '2.5.0 (2026)'
    $vcs = "JVCS $fileVer (2026) $url"
    $buildType = 'Release Build'
    $flags = '0x0L'
    $label = "2.5.0 - build $build"
    $setupBase = "JediVCS-2.5.0-build$build-Setup"
}

if ($Mostrar) {
    $v = switch ($Mostrar) {
        'FileVersion' { $fileVer }
        'Build' { "$build" }
        'Stage' { $stage }
        'StageNumber' { "$stageNum" }
        'InternalVersion' { $internal }
        'BuildType' { $buildType }
        'VCS' { $vcs }
        'Label' { $label }
        'SetupBase' { $setupBase }
        default { $null }
    }
    if ($null -eq $v) { Fail "campo desconhecido em -Mostrar: $Mostrar" }
    Write-Output $v
    exit 0
}

$stamp = Get-Date -Format 'dd.MM.yyyy HH:mm:ss'

# string do .rc: "\000" no fim; "/" vira \057 (o brcc32 trata // dentro de
# #define como comentario e cortaria a URL)
function RcStr([string]$s) { '"' + ($s -replace '\\', '\\' -replace '"', '\"' -replace '/', '\057') + '\000"' }

$lines = @(
    '/* GERADO por tools\gerar-versao.ps1 a partir de tools\versao.ini - NAO EDITE.'
    '   Fora do git (.gitignore). Incluido pelos jvcsver.rc e pelo JvcsExpertBDS_ver.rc. */'
    ''
    "#define JVCS_VER_FILEVERSION        2,5,0,$build"
    '#define JVCS_VER_PRODUCTVERSION     2,5,0,0'
    "#define JVCS_VER_FILEFLAGS          $flags"
    "#define JVCS_VER_FILEVERSION_STR    $(RcStr $fileVer)"
    "#define JVCS_VER_PRODUCTVERSION_STR $(RcStr '2.5.0.0')"
    "#define JVCS_VER_PRODUCTNAME_STR    $(RcStr 'JEDI Version Control System')"
    "#define JVCS_VER_COPYRIGHT_STR      $(RcStr 'Released under MPL 1.1')"
    "#define JVCS_VER_BUILDTYPE_STR      $(RcStr $buildType)"
    "#define JVCS_VER_BUILDTIMESTAMP_STR $(RcStr $stamp)"
    "#define JVCS_VER_INTERNAL_STR       $(RcStr $internal)"
    "#define JVCS_VER_VCS_STR            $(RcStr $vcs)"
)
[IO.File]::WriteAllText($rh, ($lines -join "`r`n") + "`r`n", (New-Object Text.ASCIIEncoding))
Write-Output "Versao  : $fileVer ($internal, $buildType) - $stamp -> $rh"

# ---- .rc -> .res -------------------------------------------------------------
# (powershell -File passa "a.rc,b.rc" como um texto so: separa aqui)
$Rc = @($Rc | ForEach-Object { $_ -split ',' } | Where-Object { $_.Trim() -ne '' })
if ($Rc.Count -gt 0) {
    if (-not $Brcc -or -not (Test-Path -LiteralPath $Brcc)) { Fail "brcc32 nao encontrado: '$Brcc'" }
    foreach ($r in $Rc) {
        $rcPath = if ([IO.Path]::IsPathRooted($r)) { $r } else { Join-Path $root $r }
        if (-not (Test-Path -LiteralPath $rcPath)) { Fail "nao encontrado: $rcPath" }
        $res = [IO.Path]::ChangeExtension($rcPath, '.res')
        Push-Location (Split-Path -Parent $rcPath)
        try {
            $out = & $Brcc "-fo$res" $rcPath 2>&1
            $rc = $LASTEXITCODE
        } finally {
            Pop-Location
        }
        if ($rc -ne 0) {
            $out | ForEach-Object { [Console]::Error.WriteLine("  $_") }
            Fail "brcc32 falhou ($rc) em $rcPath"
        }
        Write-Output "Recurso : $res"
    }
}
exit 0
