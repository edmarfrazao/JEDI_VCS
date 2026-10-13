<#
.SYNOPSIS
    Locates the JEDI VCS AI tools (tools\ai: jvcs-ai.ps1 and edit-preserve.ps1).

.DESCRIPTION
    Read-only: does not call jvcs.exe, does not read any password, does not write anything.
    Search order (the first folder containing jvcs-ai.ps1 wins):
      1. environment variable JVCS_AI_TOOLS (tools\ai folder);
      2. <project>\.claude\jvcs-ai.managed.json (written by instalar-no-projeto.ps1), from the
         current folder upwards: the same folder used by the project's "allow" rules;
      3. JEDI VCS 2.5 Beta 2026 installation (uninstall registry key, InstallLocation);
      4. default folders: %ProgramFiles(x86)%\JEDI\JVCS 2026, %ProgramFiles%\JEDI\JVCS 2026,
         %LOCALAPPDATA%\Programs\JEDI\JVCS 2026 (+ \tools\ai);
      5. JEDI VCS repository: tools\ai from the current folder upwards.

    Output: one-line JSON
      {ok, toolsAi, wrapper, editPreserve, source, wrapperCommand, editPreserveCommand, checked, message, exitCode}
    Exit codes: 0 found | 12 not found.
    Usage: powershell -NoProfile -ExecutionPolicy Bypass -File "<skill>/scripts/localizar-wrapper.ps1" [-Text]

    This file is UTF-8 WITH BOM and CRLF (Windows PowerShell 5.1).
    English version of skills\pt\jedi-vcs\scripts\localizar-wrapper.ps1 (same logic and output fields).
#>
[CmdletBinding()]
param([switch]$Text)

$ErrorActionPreference = 'Stop'
$appId = '{FA4F41D9-F23B-4C34-8186-DCBB5DD86E45}_is1'
$checked = New-Object System.Collections.ArrayList
$found = $null

function Test-ToolsDir {
    param([string]$Dir, [string]$Source)
    if ([string]::IsNullOrWhiteSpace($Dir)) { return $false }
    $d = $Dir.Trim().Trim('"').TrimEnd('\', '/')
    [void]$checked.Add("$Source -> $d")
    if (Test-Path -LiteralPath (Join-Path $d 'jvcs-ai.ps1') -PathType Leaf) {
        $script:found = [pscustomobject]@{ Dir = (Resolve-Path -LiteralPath $d).Path.TrimEnd('\'); Source = $Source }
        return $true
    }
    return $false
}

function Get-Ancestors {
    $list = New-Object System.Collections.ArrayList
    $d = (Get-Location).ProviderPath
    while ($d) {
        [void]$list.Add($d)
        $p = [IO.Path]::GetDirectoryName($d)
        if (-not $p -or $p -eq $d) { break }
        $d = $p
    }
    return , $list
}

$ancestors = Get-Ancestors

# 1. environment variable
if (-not $found) { [void](Test-ToolsDir $env:JVCS_AI_TOOLS 'JVCS_AI_TOOLS') }

# 2. manifest of the installation in the project
if (-not $found) {
    foreach ($a in $ancestors) {
        $mf = Join-Path $a '.claude\jvcs-ai.managed.json'
        if (Test-Path -LiteralPath $mf -PathType Leaf) {
            try {
                $j = [IO.File]::ReadAllText($mf) | ConvertFrom-Json
                if ($j.toolsAi -and (Test-ToolsDir ([string]$j.toolsAi) "manifest $mf")) { break }
            } catch { [void]$checked.Add("unreadable manifest: $mf") }
        }
    }
}

# 3. uninstall registry key of JEDI VCS 2.5 Beta 2026
if (-not $found) {
    $keys = @(
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$appId",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$appId",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$appId"
    )
    foreach ($k in $keys) {
        try {
            if (Test-Path -LiteralPath $k) {
                $loc = [string](Get-ItemProperty -LiteralPath $k -Name 'InstallLocation' -ErrorAction Stop).InstallLocation
                if ($loc -and (Test-ToolsDir (Join-Path $loc 'tools\ai') "installation ($k)")) { break }
            }
        } catch { }
    }
}

# 4. default folders
if (-not $found) {
    $bases = @(${env:ProgramFiles(x86)}, $env:ProgramFiles) | Where-Object { $_ } | ForEach-Object { Join-Path $_ 'JEDI\JVCS 2026' }
    if ($env:LOCALAPPDATA) { $bases += (Join-Path $env:LOCALAPPDATA 'Programs\JEDI\JVCS 2026') }
    foreach ($b in $bases) { if (Test-ToolsDir (Join-Path $b 'tools\ai') 'default folder') { break } }
}

# 5. repository (current folder and above)
if (-not $found) {
    foreach ($a in $ancestors) { if (Test-ToolsDir (Join-Path $a 'tools\ai') 'repository') { break } }
}

$res = [ordered]@{ ok = $false; toolsAi = $null; wrapper = $null; editPreserve = $null; source = $null; wrapperCommand = $null; editPreserveCommand = $null; checked = $checked; message = ''; exitCode = 12 }
if ($found) {
    $fwd = $found.Dir -replace '\\', '/'
    $res.ok = $true
    $res.toolsAi = $found.Dir
    $res.wrapper = Join-Path $found.Dir 'jvcs-ai.ps1'
    $ep = Join-Path $found.Dir 'edit-preserve.ps1'
    if (Test-Path -LiteralPath $ep -PathType Leaf) { $res.editPreserve = $ep }
    $res.source = $found.Source
    $res.wrapperCommand = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$fwd/jvcs-ai.ps1`""
    if ($res.editPreserve) { $res.editPreserveCommand = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$fwd/edit-preserve.ps1`"" }
    $res.message = "tools\ai found ($($found.Source))"
    $res.exitCode = 0
} else {
    $res.message = 'jvcs-ai.ps1 not found. Install JEDI VCS 2.5 Beta 2026 with the "AI tools" component, or set JVCS_AI_TOOLS to the tools\ai folder.'
}

if ($Text) {
    if ($res.ok) {
        Write-Output "[OK 0] $($res.message)"
        Write-Output "  wrapper: $($res.wrapperCommand)"
        if ($res.editPreserveCommand) { Write-Output "  edit-preserve: $($res.editPreserveCommand)" }
    } else {
        Write-Output "[ERROR 12] $($res.message)"
        foreach ($c in $checked) { Write-Output "  checked: $c" }
    }
} else {
    # one-line JSON, ASCII only (non-ASCII as \uXXXX), like jvcs-ai.ps1
    $json = $res | ConvertTo-Json -Compress -Depth 4
    $sb = New-Object Text.StringBuilder
    foreach ($ch in $json.ToCharArray()) {
        if ([int]$ch -gt 127) { [void]$sb.AppendFormat('\u{0:x4}', [int]$ch) } else { [void]$sb.Append($ch) }
    }
    Write-Output $sb.ToString()
}
exit $res.exitCode
