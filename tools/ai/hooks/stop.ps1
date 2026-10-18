<#
.SYNOPSIS
    Hook Stop do Claude Code: lembra os checkouts JEDI VCS feitos pela IA nesta sessão que
    continuam presos (por exemplo: o hook PreToolUse fez o checkout e o usuário negou a edição,
    ou o Edit falhou).

.DESCRIPTION
    - O jvcs-ai.ps1 registra cada checkout feito em contexto de agente em
      %LOCALAPPDATA%\JEDI\JVCS\sessoes\<session_id>.txt.
    - Sem esse arquivo, o hook termina na hora (não chama o jvcs.exe).
    - Com ele, roda "jvcs-ai.ps1 status" nesses arquivos e mostra ao usuário (systemMessage) os
      que continuam em checkout: sem alteração (sugere undocheckout) ou com alteração (falta
      check-in). Os que já não estão em checkout saem do registro.
    - NUNCA bloqueia: sempre exit 0 (exit 2 num Stop faria o Claude continuar o turno).
      Não desfaz nada sozinho: só avisa.

    Este arquivo é UTF-8 COM BOM e CRLF (Windows PowerShell 5.1).
#>
$ErrorActionPreference = 'Stop'

function Write-Stdout {
    param([string]$S)
    $o = [Console]::OpenStandardOutput()
    $b = [Text.Encoding]::UTF8.GetBytes($S)
    $o.Write($b, 0, $b.Length)
    $o.Flush()
}

try {
    . (Join-Path (Split-Path -Parent $PSScriptRoot) 'lib\jvcs-ai-common.ps1')
    $wrapper = Join-Path (Split-Path -Parent $PSScriptRoot) 'jvcs-ai.ps1'

    $stdin = [Console]::OpenStandardInput()
    $ms = New-Object IO.MemoryStream
    $stdin.CopyTo($ms)
    $raw = (New-Object Text.UTF8Encoding($false)).GetString($ms.ToArray()).TrimStart([char]0xFEFF)
    $in = $null
    if ($raw.Trim()) { try { $in = $raw | ConvertFrom-Json } catch { $in = $null } }
    $sid = ''
    if ($in -and $in.session_id) { $sid = [string]$in.session_id }
    if ($in -and $in.stop_hook_active -eq $true) { exit 0 }

    $marker = Get-JaSessionMarkerPath -SessionId $sid
    if (-not (Test-Path -LiteralPath $marker)) { exit 0 }
    $files = @([IO.File]::ReadAllLines($marker, (New-Object Text.UTF8Encoding($false))) | Where-Object { $_ -and $_.Trim() } | Select-Object -Unique)
    if ($files.Count -eq 0) { Remove-Item -LiteralPath $marker -Force -ErrorAction SilentlyContinue; exit 0 }
    $existing = @($files | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf })

    $clean = New-Object System.Collections.Generic.List[string]
    $dirty = New-Object System.Collections.Generic.List[string]
    $unk = New-Object System.Collections.Generic.List[string]
    $keep = New-Object System.Collections.Generic.List[string]
    if ($existing.Count -gt 0) {
        $out = & $wrapper 'status' @existing -TimeoutSec 45 -LockWaitSec 20
        $res = (@($out) -join "`n") | ConvertFrom-Json
        foreach ($m in @($res.modules)) {
            # sem .dpr/.dpk, .jvcsproject nem mapa [projects] acima do arquivo (ex.: acervo xHarbour com checkout
            # por -Project): o status não acha o projeto; o checkout continua registrado e o usuário é avisado
            if ($m.state -eq 'noProject') {
                [void]$keep.Add([string]$m.path)
                [void]$unk.Add([IO.Path]::GetFileName([string]$m.path) + ' (projeto não identificado: status <arquivo> -Project <projeto>)')
                continue
            }
            # state=error (status 1.4.0 com o R1): a revisão não baixou, ou o arquivo não pôde ser resolvido
            # (sem lockedBy); não dá para dizer se mudou nem se o checkout continua: fica no registro e avisa
            if ($m.state -eq 'error') {
                [void]$keep.Add([string]$m.path)
                [void]$unk.Add([IO.Path]::GetFileName([string]$m.path))
                continue
            }
            if (-not $m.lockedBy) { continue }
            [void]$keep.Add([string]$m.path)
            $nm = [IO.Path]::GetFileName([string]$m.path)
            if ($m.localState -eq 'clean') { [void]$clean.Add($nm) } else { [void]$dirty.Add($nm) }
        }
        # status que falhou como um todo ou no meio (timeout, credencial, ambiente, mutex): nada sai do registro
        if (-not $res.ok -and [int]$res.exitCode -ne 11 -and @($res.modules).Count -lt $existing.Count) {
            foreach ($ef in $existing) { if ($keep -notcontains [string]$ef) { [void]$keep.Add([string]$ef) } }
            [void]$unk.Add("(status falhou: $($res.message))")
        }
    }
    if ($keep.Count -eq 0) { Remove-Item -LiteralPath $marker -Force -ErrorAction SilentlyContinue }
    else { [IO.File]::WriteAllText($marker, (($keep -join "`r`n") + "`r`n"), (New-Object Text.UTF8Encoding($false))) }

    $parts = New-Object System.Collections.Generic.List[string]
    if ($clean.Count -gt 0) { $parts.Add('em checkout SEM alteração (desfaça com undocheckout se não for editar): ' + ($clean -join ', ')) }
    if ($dirty.Count -gt 0) { $parts.Add('em checkout COM alteração (falta check-in): ' + ($dirty -join ', ')) }
    if ($unk.Count -gt 0) { $parts.Add('em checkout, NÃO verificados (confira com status): ' + ($unk -join ', ')) }
    if ($parts.Count -gt 0) {
        Write-Stdout (ConvertTo-JaJson ([ordered]@{ systemMessage = ('JEDI VCS - checkouts feitos pela IA nesta sessão: ' + ($parts -join ' | ')) }) -Ascii)
    }
    exit 0
} catch {
    try { Write-Stdout (ConvertTo-JaJson ([ordered]@{ systemMessage = ('JEDI VCS (hook Stop): não foi possível conferir os checkouts da sessão: ' + $_.Exception.Message) }) -Ascii) } catch { }
    exit 0
}
