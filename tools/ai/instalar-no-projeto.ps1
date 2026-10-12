<#
.SYNOPSIS
    Instala a integração JEDI VCS + Claude Code num projeto Delphi.

.DESCRIPTION
    instalar-no-projeto.ps1 -ProjectDir <pasta> [-Mode auto|confirm|manual]
                            [-CheckoutMode ...] [-CheckinMode ...]
                            [-Scope project|local] [-AllowEditPreserve] [-WhatIf]

    1. Mescla claude\settings.template.json no settings do projeto SEM apagar o que já existe:
       - -Scope project (padrão): <pasta>\.claude\settings.json (arquivo compartilhado do projeto);
       - -Scope local: <pasta>\.claude\settings.local.json (só desta máquina; use quando a pasta
         .claude for versionada, porque o settings leva caminhos absolutos desta máquina).
       Remove só o que este instalador gerencia (lista gravada em .claude\jvcs-ai.managed.json,
       regras do modelo atual e da versão 1.0.0) e só os itens de hook dele (pretooluse.ps1 e
       stop.ps1 de tools\ai); um grupo de hooks só some se ficar vazio. Backup antes.
    2. Copia a skill para <pasta>\.claude\skills\jvcs\SKILL.md.
    3. Grava o modo em %APPDATA%\JEDI\JVCS\config.ini ([ai] checkout/checkin) SÓ quando -Mode,
       -CheckoutMode ou -CheckinMode são informados. O modo vale para todos os projetos do usuário
       do Windows; sem nada gravado, o padrão é confirm.

    -AllowEditPreserve acrescenta regras "allow" para o edit-preserve.ps1 (as edições por ele deixam
    de pedir aprovação, como o modo acceptEdits faz com o Edit). Sem a opção, cada edição pelo
    edit-preserve pede aprovação no modo Manual, como o Edit.
    -WhatIf mostra o que seria feito sem gravar nada.
    Rode no seu terminal (a IA tem regra deny para este script).

    Este arquivo é UTF-8 COM BOM e CRLF (Windows PowerShell 5.1).
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)][string]$ProjectDir,
    [ValidateSet('', 'auto', 'confirm', 'manual')][string]$Mode = '',
    [ValidateSet('', 'auto', 'confirm', 'manual')][string]$CheckoutMode = '',
    [ValidateSet('', 'auto', 'confirm', 'manual')][string]$CheckinMode = '',
    [ValidateSet('project', 'local')][string]$Scope = 'project',
    [switch]$AllowEditPreserve
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\jvcs-ai-common.ps1')

$toolsAi = (Resolve-Path -LiteralPath $PSScriptRoot).Path.TrimEnd('\')
$toolsFwd = ($toolsAi -replace '\\', '/')
$toolsPosix = $toolsFwd
if ($toolsPosix -match '^([A-Za-z]):(.*)$') { $toolsPosix = $Matches[1].ToLowerInvariant() + $Matches[2] }

if (-not (Test-Path -LiteralPath $ProjectDir -PathType Container)) { throw "pasta do projeto não existe: $ProjectDir" }
$proj = (Resolve-Path -LiteralPath $ProjectDir).Path.TrimEnd('\')
$claudeDir = Join-Path $proj '.claude'
$settingsFiles = [ordered]@{ project = (Join-Path $claudeDir 'settings.json'); local = (Join-Path $claudeDir 'settings.local.json') }
$targetPath = $settingsFiles[$Scope]
$manifestPath = Join-Path $claudeDir 'jvcs-ai.managed.json'
$skillSrc = Join-Path $toolsAi 'claude\skills\jvcs\SKILL.md'
$skillDst = Join-Path $claudeDir 'skills\jvcs\SKILL.md'
$templatePath = Join-Path $toolsAi 'claude\settings.template.json'

$coMode = $Mode; if ($CheckoutMode) { $coMode = $CheckoutMode }
$ciMode = $Mode; if ($CheckinMode) { $ciMode = $CheckinMode }

$notes = New-Object System.Collections.Generic.List[string]
$dprs = @(Get-ChildItem -LiteralPath $proj -File | Where-Object { $_.Extension -ieq '.dpr' -or $_.Extension -ieq '.dpk' })
if ($dprs.Count -eq 0) { $notes.Add('aviso: nenhum .dpr/.dpk na pasta; o hook procura o projeto na pasta do arquivo editado e acima') }
$cfgInfo = Read-JaConfig
if (-not (Test-Path -LiteralPath $cfgInfo.Values.jvcsExe -PathType Leaf)) { $notes.Add("aviso: jvcs.exe não encontrado em $($cfgInfo.Values.jvcsExe) (config jvcsExe)") }
if (-not (Test-Path -LiteralPath 'HKCU:\Software\JEDI\JEDIVCS\Identities')) { $notes.Add('aviso: nenhuma identidade salva no registro; conecte uma vez pela GUI com "Store Password with identity"') }
if ($Scope -eq 'project' -and ((Test-Path -LiteralPath (Join-Path $proj '.git')) -or (Test-Path -LiteralPath (Join-Path $proj '.svn')))) {
    $notes.Add('aviso: a pasta parece versionada (git/svn) e o settings.json leva caminhos absolutos desta máquina; considere -Scope local')
}

# ------------------------------------------------------------------ modelo
function Expand-Placeholders {
    param($Value)
    if ($null -eq $Value) { return $null }
    if ($Value -is [string]) { return $Value.Replace('{{TOOLS_AI_POSIX}}', $toolsPosix).Replace('{{TOOLS_AI_FWD}}', $toolsFwd).Replace('{{TOOLS_AI}}', $toolsAi) }
    if ($Value -is [System.Collections.IDictionary]) {
        $h = [ordered]@{}
        foreach ($k in $Value.Keys) { $h[$k] = Expand-Placeholders $Value[$k] }
        return $h
    }
    if ($Value -is [System.Collections.IList]) {
        $l = New-Object System.Collections.ArrayList
        foreach ($i in $Value) { [void]$l.Add((Expand-Placeholders $i)) }
        return , $l
    }
    return $Value
}
$tpl = Expand-Placeholders (Read-JaJsonFile $templatePath)
$optionalAllow = @()
if ($tpl.Contains('x-jvcs-ai') -and $tpl['x-jvcs-ai'].Contains('allowEditPreserve')) { $optionalAllow = @($tpl['x-jvcs-ai']['allowEditPreserve']) }
$tplVersion = '?'
if ($tpl.Contains('x-jvcs-ai')) { $tplVersion = [string]$tpl['x-jvcs-ai']['version'] }

# regras a instalar
$install = [ordered]@{ allow = (New-Object System.Collections.ArrayList); ask = (New-Object System.Collections.ArrayList); deny = (New-Object System.Collections.ArrayList) }
foreach ($kind in @('allow', 'ask', 'deny')) {
    if ($tpl.permissions.Contains($kind)) { foreach ($r in $tpl.permissions[$kind]) { [void]$install[$kind].Add([string]$r) } }
}
if ($AllowEditPreserve) { foreach ($r in $optionalAllow) { [void]$install['allow'].Add([string]$r) } }

# regras gerenciadas = manifesto anterior + modelo atual (inclusive opcionais) + modelo 1.0.0
$legacy = @(
    'PowerShell(*jvcs-ai.ps1*-Confirmed*)', 'Bash(*jvcs-ai.ps1*-Confirmed*)', 'PowerShell(*jvcs-ai.ps1*-Discard*)', 'Bash(*jvcs-ai.ps1*-Discard*)',
    'Edit(~/AppData/Roaming/JEDI/JVCS/**)', 'Write(~/AppData/Roaming/JEDI/JVCS/**)',
    ('Edit(//' + $toolsPosix + '/**)'), ('Write(//' + $toolsPosix + '/**)')
)
$managed = New-Object System.Collections.Generic.HashSet[string]([StringComparer]::Ordinal)
foreach ($r in $legacy) { [void]$managed.Add($r) }
foreach ($kind in @('allow', 'ask', 'deny')) { foreach ($r in $install[$kind]) { [void]$managed.Add($r) } }
foreach ($r in $optionalAllow) { [void]$managed.Add([string]$r) }
if (Test-Path -LiteralPath $manifestPath -PathType Leaf) {
    try {
        $mf = Read-JaJsonFile $manifestPath
        if ($mf.Contains('rules')) { foreach ($r in $mf['rules']) { [void]$managed.Add([string]$r) } }
    } catch { $notes.Add("aviso: manifesto $manifestPath ilegível; usando só as regras do modelo") }
}

function Test-OurHookItem {
    param($Hook)
    if (-not ($Hook -is [System.Collections.IDictionary])) { return $false }
    $txt = ''
    if ($Hook.Contains('command')) { $txt += [string]$Hook['command'] }
    if ($Hook.Contains('args')) { $txt += ' ' + (@($Hook['args']) -join ' ') }
    return ($txt -match '(pretooluse|stop)\.ps1' -and $txt -match '(?i)jvcs|tools[\\/]+ai')
}

# Remove do settings (dicionário) os itens deste instalador. Devolve quantos itens saíram.
function Remove-Managed {
    param($Settings)
    $n = 0
    if ($Settings.Contains('hooks') -and $Settings['hooks'] -is [System.Collections.IDictionary]) {
        foreach ($ev in @($Settings['hooks'].Keys)) {
            $groups = New-Object System.Collections.ArrayList
            foreach ($g in @($Settings['hooks'][$ev])) {
                if ($g -is [System.Collections.IDictionary] -and $g.Contains('hooks')) {
                    $kept = New-Object System.Collections.ArrayList
                    foreach ($h in @($g['hooks'])) { if (Test-OurHookItem $h) { $n++ } else { [void]$kept.Add($h) } }
                    if ($kept.Count -eq 0) { continue }
                    $g['hooks'] = $kept
                }
                [void]$groups.Add($g)
            }
            if ($groups.Count -gt 0) { $Settings['hooks'][$ev] = $groups } else { $Settings['hooks'].Remove($ev) }
        }
        if ($Settings['hooks'].Count -eq 0) { $Settings.Remove('hooks') }
    }
    if ($Settings.Contains('permissions') -and $Settings['permissions'] -is [System.Collections.IDictionary]) {
        foreach ($kind in @('allow', 'ask', 'deny')) {
            if (-not $Settings['permissions'].Contains($kind)) { continue }
            $cur = New-Object System.Collections.ArrayList
            foreach ($r in @($Settings['permissions'][$kind])) { if ($managed.Contains([string]$r)) { $n++ } else { [void]$cur.Add($r) } }
            if ($cur.Count -gt 0) { $Settings['permissions'][$kind] = $cur } else { $Settings['permissions'].Remove($kind) }
        }
        if ($Settings['permissions'].Count -eq 0) { $Settings.Remove('permissions') }
    }
    return $n
}

function Read-SettingsFile {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $null }
    $s = $null
    try { $s = Read-JaJsonFile $Path }
    catch { throw "o $Path existente não é JSON válido; corrija-o antes (nada foi alterado): $($_.Exception.Message)" }
    if (-not ($s -is [System.Collections.IDictionary])) { throw "o $Path não contém um objeto JSON (nada foi alterado)" }
    return $s
}

# ------------------------------------------------------------------ settings de destino e o outro escopo
$target = Read-SettingsFile $targetPath
$targetExisted = ($null -ne $target)
if (-not $targetExisted) { $target = [ordered]@{} }
$removedTarget = Remove-Managed $target

$otherScope = 'local'; if ($Scope -eq 'local') { $otherScope = 'project' }
$otherPath = $settingsFiles[$otherScope]
$other = Read-SettingsFile $otherPath
$removedOther = 0
if ($null -ne $other) { $removedOther = Remove-Managed $other }

# hooks do modelo
if (-not $target.Contains('hooks') -or -not ($target['hooks'] -is [System.Collections.IDictionary])) { $target['hooks'] = [ordered]@{} }
foreach ($ev in $tpl.hooks.Keys) {
    $list = New-Object System.Collections.ArrayList
    if ($target['hooks'].Contains($ev)) { foreach ($g in @($target['hooks'][$ev])) { [void]$list.Add($g) } }
    foreach ($g in $tpl.hooks[$ev]) { [void]$list.Add($g) }
    $target['hooks'][$ev] = $list
}
# permissões do modelo
if (-not $target.Contains('permissions') -or -not ($target['permissions'] -is [System.Collections.IDictionary])) { $target['permissions'] = [ordered]@{} }
foreach ($kind in @('allow', 'ask', 'deny')) {
    $cur = New-Object System.Collections.ArrayList
    if ($target['permissions'].Contains($kind)) { foreach ($r in @($target['permissions'][$kind])) { [void]$cur.Add($r) } }
    foreach ($r in $install[$kind]) { if (-not ($cur -contains $r)) { [void]$cur.Add($r) } }
    if ($cur.Count -gt 0) { $target['permissions'][$kind] = $cur }
}

$json = (ConvertTo-JaJson $target -Pretty) + "`n"
$allRules = New-Object System.Collections.ArrayList
foreach ($kind in @('allow', 'ask', 'deny')) { foreach ($r in $install[$kind]) { [void]$allRules.Add($r) } }
$manifest = [ordered]@{
    comment      = 'Gerado por tools\ai\instalar-no-projeto.ps1: itens do settings que o instalador gerencia (não edite).'
    version      = $tplVersion
    scope        = $Scope
    settingsFile = $targetPath
    toolsAi      = $toolsAi
    rules        = $allRules
    hookScripts  = @((Join-Path $toolsAi 'hooks\pretooluse.ps1'), (Join-Path $toolsAi 'hooks\stop.ps1'))
}
$skillText = [IO.File]::ReadAllText($skillSrc, (New-Object Text.UTF8Encoding($false))).Replace('{{TOOLS_AI_FWD}}', $toolsFwd).Replace('{{TOOLS_AI}}', $toolsAi)

# ------------------------------------------------------------------ aplicar
$actions = New-Object System.Collections.Generic.List[string]
$stamp = (Get-Date).ToString('yyyyMMdd-HHmmss')
$utf8 = New-Object Text.UTF8Encoding($false)
if ($PSCmdlet.ShouldProcess($targetPath, 'mesclar hooks e permissões do JEDI VCS')) {
    if (-not (Test-Path -LiteralPath $claudeDir)) { [void](New-Item -ItemType Directory -Path $claudeDir -Force) }
    if ($targetExisted) {
        $bak = $targetPath + '.bak-' + $stamp
        Copy-Item -LiteralPath $targetPath -Destination $bak -Force
        $actions.Add("backup: $bak")
    }
    [IO.File]::WriteAllText($targetPath, $json, $utf8)
    $actions.Add("settings ($Scope): $targetPath ($removedTarget item(ns) antigo(s) do instalador substituído(s))")
    [IO.File]::WriteAllText($manifestPath, (ConvertTo-JaJson $manifest -Pretty) + "`n", $utf8)
    $actions.Add("manifesto: $manifestPath")
}
if ($removedOther -gt 0 -and $PSCmdlet.ShouldProcess($otherPath, "remover $removedOther item(ns) do instalador (outro escopo)")) {
    $bak2 = $otherPath + '.bak-' + $stamp
    Copy-Item -LiteralPath $otherPath -Destination $bak2 -Force
    [IO.File]::WriteAllText($otherPath, (ConvertTo-JaJson $other -Pretty) + "`n", $utf8)
    $actions.Add("settings ($otherScope): $otherPath ($removedOther item(ns) do instalador removido(s); backup $bak2)")
}
if ($PSCmdlet.ShouldProcess($skillDst, 'copiar skill jvcs')) {
    $sd = Split-Path -Parent $skillDst
    if (-not (Test-Path -LiteralPath $sd)) { [void](New-Item -ItemType Directory -Path $sd -Force) }
    [IO.File]::WriteAllText($skillDst, $skillText, $utf8)
    $actions.Add("skill: $skillDst")
}
if ($coMode -or $ciMode) {
    $what = @()
    if ($coMode) { $what += "checkout=$coMode" }
    if ($ciMode) { $what += "checkin=$ciMode" }
    if ($PSCmdlet.ShouldProcess((Get-JaConfigPath), ('gravar ' + ($what -join ' e ')))) {
        if ($coMode) { [void](Set-JaConfigValue -Key 'checkout' -Value $coMode) }
        if ($ciMode) { [void](Set-JaConfigValue -Key 'checkin' -Value $ciMode) }
        $actions.Add("config: $(Get-JaConfigPath) (" + ($what -join ', ') + ')')
    }
} else {
    $cur = $cfgInfo.Values
    $notes.Add("modo não alterado (sem -Mode): checkout=$($cur.checkout) [$($cfgInfo.Sources.checkout)], checkin=$($cur.checkin) [$($cfgInfo.Sources.checkin)]")
}

Write-Output "JEDI VCS + Claude Code: $proj"
foreach ($a in $actions) { Write-Output "  $a" }
foreach ($n in $notes) { Write-Output "  $n" }
if ($WhatIfPreference) {
    Write-Output "--- $([IO.Path]::GetFileName($targetPath)) resultante (simulação) ---"
    Write-Output $json
}
Write-Output 'Requisitos: Claude Code 2.1.295+ (onFailure "block"). Abra o projeto no Claude Code e aceite a confiança da pasta: hooks e regras "allow" do settings do projeto só valem depois disso.'
