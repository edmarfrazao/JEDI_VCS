<#
.SYNOPSIS
    Localiza as ferramentas da IA do JEDI VCS (tools\ai: jvcs-ai.ps1 e edit-preserve.ps1).

.DESCRIPTION
    Só leitura: não chama o jvcs.exe, não lê senha, não grava nada.
    Ordem de busca (a primeira pasta com jvcs-ai.ps1 vence):
      1. variável de ambiente JVCS_AI_TOOLS (pasta tools\ai);
      2. <projeto>\.claude\jvcs-ai.managed.json (gravado por instalar-no-projeto.ps1), da pasta
         atual para cima: mesma pasta que as regras "allow" do projeto usam;
      3. instalação do JEDI VCS 2.5 Beta 2026 (registro de desinstalação, InstallLocation);
      4. pastas padrão: %ProgramFiles(x86)%\JEDI\JVCS 2026, %ProgramFiles%\JEDI\JVCS 2026,
         %LOCALAPPDATA%\Programs\JEDI\JVCS 2026 (+ \tools\ai);
      5. repositório do JEDI VCS: tools\ai a partir da pasta atual para cima.

    Saída: JSON numa linha
      {ok, toolsAi, wrapper, editPreserve, source, wrapperCommand, editPreserveCommand, checked, message, exitCode}
    Códigos: 0 encontrado | 12 não encontrado.
    Uso: powershell -NoProfile -ExecutionPolicy Bypass -File "<skill>/scripts/localizar-wrapper.ps1" [-Text]

    Este arquivo é UTF-8 COM BOM e CRLF (Windows PowerShell 5.1).
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

# 1. variável de ambiente
if (-not $found) { [void](Test-ToolsDir $env:JVCS_AI_TOOLS 'JVCS_AI_TOOLS') }

# 2. manifesto da instalação no projeto
if (-not $found) {
    foreach ($a in $ancestors) {
        $mf = Join-Path $a '.claude\jvcs-ai.managed.json'
        if (Test-Path -LiteralPath $mf -PathType Leaf) {
            try {
                $j = [IO.File]::ReadAllText($mf) | ConvertFrom-Json
                if ($j.toolsAi -and (Test-ToolsDir ([string]$j.toolsAi) "manifesto $mf")) { break }
            } catch { [void]$checked.Add("manifesto ilegível: $mf") }
        }
    }
}

# 3. registro de desinstalação do JEDI VCS 2.5 Beta 2026
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
                if ($loc -and (Test-ToolsDir (Join-Path $loc 'tools\ai') "instalação ($k)")) { break }
            }
        } catch { }
    }
}

# 4. pastas padrão
if (-not $found) {
    $bases = @(${env:ProgramFiles(x86)}, $env:ProgramFiles) | Where-Object { $_ } | ForEach-Object { Join-Path $_ 'JEDI\JVCS 2026' }
    if ($env:LOCALAPPDATA) { $bases += (Join-Path $env:LOCALAPPDATA 'Programs\JEDI\JVCS 2026') }
    foreach ($b in $bases) { if (Test-ToolsDir (Join-Path $b 'tools\ai') 'pasta padrão') { break } }
}

# 5. repositório (pasta atual e acima)
if (-not $found) {
    foreach ($a in $ancestors) { if (Test-ToolsDir (Join-Path $a 'tools\ai') 'repositório') { break } }
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
    $res.message = "tools\ai encontrado ($($found.Source))"
    $res.exitCode = 0
} else {
    $res.message = 'jvcs-ai.ps1 não encontrado. Instale o JEDI VCS 2.5 Beta 2026 com o componente "Ferramentas da IA", ou defina JVCS_AI_TOOLS com a pasta tools\ai.'
}

if ($Text) {
    if ($res.ok) {
        Write-Output "[OK 0] $($res.message)"
        Write-Output "  wrapper: $($res.wrapperCommand)"
        if ($res.editPreserveCommand) { Write-Output "  edit-preserve: $($res.editPreserveCommand)" }
    } else {
        Write-Output "[ERRO 12] $($res.message)"
        foreach ($c in $checked) { Write-Output "  verificado: $c" }
    }
} else {
    # JSON numa linha, só ASCII (acentos como \uXXXX), como o jvcs-ai.ps1
    $json = $res | ConvertTo-Json -Compress -Depth 4
    $sb = New-Object Text.StringBuilder
    foreach ($ch in $json.ToCharArray()) {
        if ([int]$ch -gt 127) { [void]$sb.AppendFormat('\u{0:x4}', [int]$ch) } else { [void]$sb.Append($ch) }
    }
    Write-Output $sb.ToString()
}
exit $res.exitCode
