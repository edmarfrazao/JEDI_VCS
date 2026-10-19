<#
.SYNOPSIS
    Hook PreToolUse do Claude Code para Edit|MultiEdit|Write em fontes Delphi
    (*.pas *.dfm *.fmx *.dpr *.dpk *.dproj *.inc) de projetos JEDI VCS.

.DESCRIPTION
    Entrada: JSON do Claude Code na entrada padrão (UTF-8):
      { session_id, cwd, permission_mode, hook_event_name: "PreToolUse",
        tool_name, tool_input: { file_path, old_string, new_string, content, edits[] }, tool_use_id }
    Saída (exit 0), conforme code.claude.com/docs/en/hooks:
      negar : {"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny",
                "permissionDecisionReason":"..."}}         (o motivo vai para o Claude)
      seguir: nada no stdout (fluxo normal de permissões), ou só additionalContext/systemMessage
              quando o hook fez o checkout automático.
    Erro interno: exit 2 com o motivo no stderr (o Claude Code bloqueia a chamada) = falha fechada.
    Configure com "onFailure": "block" (Claude Code 2.1.295+) para que timeout e falha ao
    iniciar também bloqueiem.

    Regras:
      1. Codificação (vale com ou sem JEDI VCS):
         - Edit/MultiEdit em arquivo ANSI (não UTF-8) ou UTF-16/binário: nega (o Edit troca os
           acentos por U+FFFD; testado no Claude Code 2.1.295) -> usar edit-preserve.ps1.
         - Edit em arquivo ASCII puro inserindo não-ASCII: nega (viraria UTF-8 sem BOM, que o
           compilador lê como ANSI), salvo config asciiAs=utf8.
         - Write em arquivo existente: nega se não for UTF-8 sem BOM/ASCII, se tiver CRLF (o
           Write grava LF) ou se for ASCII e o conteúdo tiver não-ASCII.
         - Write de arquivo novo com não-ASCII: nega (sugere edit-preserve -ContentFile).
      2. Checkout (só se houver .dpr/.dpk na pasta ou acima), conforme config.ini [ai] checkout:
         - auto    -> jvcs-ai.ps1 ensure-checkout (falha -> nega com o motivo)
         - confirm -> se não estiver em checkout: nega e orienta "checkout ... -Confirmed"
                      (a regra ask do settings faz o Claude Code pedir aprovação ao humano).
                      Não se usa permissionDecision "ask" aqui porque, aprovada a edição, o Edit
                      falharia com EPERM no arquivo somente leitura (testado).
         - manual  -> se não estiver em checkout: nega e pede ao humano.
      3. Somente leitura: nega a edição de arquivo somente leitura que não seja resolvido por
         checkout (fora de projeto, não versionado, ou "já é meu" mas somente leitura) e manda não
         remover o atributo (o Edit falharia com EPERM e a IA tenderia a contorná-lo).

    O wrapper é chamado com -TimeoutSec 45 -LockWaitSec 30, o que cabe no timeout do hook (600 s).

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

function Exit-Deny {
    param([string]$Reason)
    $obj = [ordered]@{ hookSpecificOutput = [ordered]@{ hookEventName = 'PreToolUse'; permissionDecision = 'deny'; permissionDecisionReason = $Reason } }
    Write-Stdout (ConvertTo-JaJson $obj -Ascii)
    exit 0
}

function Exit-Info {
    param([string]$Context, [string]$UserMessage)
    $obj = [ordered]@{}
    if ($UserMessage) { $obj['systemMessage'] = $UserMessage }
    $obj['hookSpecificOutput'] = [ordered]@{ hookEventName = 'PreToolUse'; additionalContext = $Context }
    Write-Stdout (ConvertTo-JaJson $obj -Ascii)
    exit 0
}

function Exit-Fail {
    param([string]$Message)
    try {
        $e = [Console]::OpenStandardError()
        $b = [Text.Encoding]::UTF8.GetBytes($Message + "`n")
        $e.Write($b, 0, $b.Length); $e.Flush()
    } catch { }
    exit 2
}

try {
    . (Join-Path (Split-Path -Parent $PSScriptRoot) 'lib\jvcs-ai-common.ps1')
    $wrapper = Join-Path (Split-Path -Parent $PSScriptRoot) 'jvcs-ai.ps1'
    $editPreserve = Join-Path (Split-Path -Parent $PSScriptRoot) 'edit-preserve.ps1'

    # JSON do Claude Code: lê os bytes (UTF-8), independente da code page do console
    $stdin = [Console]::OpenStandardInput()
    $ms = New-Object IO.MemoryStream
    $stdin.CopyTo($ms)
    $raw = (New-Object Text.UTF8Encoding($false)).GetString($ms.ToArray()).TrimStart([char]0xFEFF)
    if (-not $raw.Trim()) { Exit-Fail 'JEDI VCS hook: entrada vazia; edição bloqueada por segurança' }
    $in = $raw | ConvertFrom-Json
    # o registro de checkouts da sessão (lido pelo hook Stop) usa o mesmo session_id do JSON
    if ($in.session_id) { $env:CLAUDE_CODE_SESSION_ID = [string]$in.session_id }

    $tool = [string]$in.tool_name
    if (@('Edit', 'MultiEdit', 'Write') -notcontains $tool) { exit 0 }
    $ti = $in.tool_input
    $fp = [string]$ti.file_path
    if (-not $fp) { exit 0 }
    $full = [IO.Path]::GetFullPath($fp)
    if (-not (Test-JaDelphiSource $full)) { exit 0 }

    $cfgInfo = Read-JaConfig
    $cfg = $cfgInfo.Values
    $asciiAs = $cfg.asciiAs
    $ep = Get-JaCanonicalCommand 'edit-preserve.ps1'
    $wr = Get-JaCanonicalCommand 'jvcs-ai.ps1'
    $noRo = 'Não remova o atributo somente leitura (attrib/IsReadOnly/Attributes): somente leitura = sem checkout no JEDI VCS.'

    # textos novos que a ferramenta vai gravar
    $newTexts = New-Object System.Collections.Generic.List[string]
    if ($tool -eq 'Write') { $newTexts.Add([string]$ti.content) }
    else {
        if ($null -ne $ti.new_string) { $newTexts.Add([string]$ti.new_string) }
        if ($null -ne $ti.edits) { foreach ($e in $ti.edits) { if ($null -ne $e.new_string) { $newTexts.Add([string]$e.new_string) } } }
    }
    $hasNonAscii = $false
    foreach ($t in $newTexts) { if ([regex]::IsMatch($t, '[^\x00-\x7f]')) { $hasNonAscii = $true } }

    # ------------------------------------------------ 1. codificação
    if (-not (Test-Path -LiteralPath $full -PathType Leaf)) {
        if ($tool -eq 'Write' -and $hasNonAscii -and $asciiAs -eq 'ansi') {
            Exit-Deny ("JEDI VCS/codificação: o Write gravaria '$full' em UTF-8 sem BOM, que o compilador Delphi lê como ANSI (acentos corrompidos). " +
                "Grave o conteúdo num arquivo temporário UTF-8 e crie o fonte com: $ep -Path `"$full`" -ContentFile <tmp> -NewFileEncoding Ansi (ou Utf8Bom).")
        }
        # revisão Fable (8): apagar um módulo (Remove-Item -Force) e recriá-lo pelo Write contornaria o
        # somente leitura/checkout. Arquivo novo que já é módulo do projeto: só com checkout (ou já seu).
        if (Test-JaProjectContext -FullPath $full -ConfigInfo $cfgInfo) {
            $out = & $wrapper 'ensure-checkout' $full -CheckOnly -TimeoutSec 45 -LockWaitSec 30
            $code = $LASTEXITCODE
            $res = $null
            try { $res = (@($out) -join "`n") | ConvertFrom-Json } catch { Exit-Fail ("JEDI VCS hook: resposta inválida do jvcs-ai.ps1; edição bloqueada. Saída: " + (@($out) -join ' ')) }
            $state = ''
            if ($res.modules -and @($res.modules).Count -gt 0) { $state = [string]@($res.modules)[0].state }
            if ($code -eq 0 -and ($state -eq 'notVersioned' -or $state -eq 'alreadyMine')) { exit 0 }
            Exit-Deny ("JEDI VCS: '$full' não existe no disco, mas é módulo do JEDI VCS (estado '$state', código ${code}: " + [string]$res.message + "). " +
                "Recriar o arquivo pelo Write contornaria o checkout: rode $wr checkout `"$full`" (baixa a última revisão) e edite depois, ou pergunte ao usuário.")
        }
        exit 0
    }
    $info = Get-JaTextInfoFromFile $full
    $kind = $info.Kind
    if ($tool -eq 'Edit' -or $tool -eq 'MultiEdit') {
        if ($kind -eq 'ansi') {
            Exit-Deny ("JEDI VCS/codificação: '$full' está em ANSI (Windows-1252) e o Edit do Claude Code troca os acentos do arquivo por U+FFFD. " +
                "Use: $ep -Path `"$full`" -Old <texto> -New <texto>  (ou -OldFile/-NewFile com o texto em arquivos UTF-8).")
        }
        if ($kind -eq 'utf16le' -or $kind -eq 'utf16be' -or $kind -eq 'binary') {
            Exit-Deny ("JEDI VCS/codificação: '$full' é $kind; o Edit não preserva esse formato. Use $ep (texto UTF-16) ou edite pela IDE (DFM binário).")
        }
        if ($kind -eq 'ascii' -and $hasNonAscii -and $asciiAs -eq 'ansi') {
            Exit-Deny ("JEDI VCS/codificação: '$full' é ASCII puro (o Delphi lê como ANSI) e a edição insere caracteres não-ASCII, que o Edit gravaria em UTF-8 sem BOM (acentos corrompidos na compilação). " +
                "Use: $ep -Path `"$full`" -Old <texto> -New <texto>, que grava em Windows-1252.")
        }
    } else {
        $why = ''
        if ($kind -ne 'utf8' -and $kind -ne 'ascii') { $why = "o arquivo é $kind e o Write regrava em UTF-8 sem BOM" }
        elseif ($info.CrLf -gt 0) { $why = 'o arquivo usa CRLF e o Write grava LF' }
        elseif ($kind -eq 'ascii' -and $hasNonAscii -and $asciiAs -eq 'ansi') { $why = 'o conteúdo tem não-ASCII e viraria UTF-8 sem BOM (o Delphi lê como ANSI)' }
        if ($why) {
            Exit-Deny ("JEDI VCS/codificação: Write negado em '$full': $why. Para trocas pontuais use o Edit (preserva BOM e CRLF em UTF-8) ou $ep -Old/-New; " +
                "para regravar tudo, grave o conteúdo num arquivo temporário UTF-8 e rode: $ep -Path `"$full`" -ContentFile <tmp>.")
        }
    }

    # ------------------------------------------------ 2. checkout JEDI VCS
    $isRo = (New-Object IO.FileInfo $full).IsReadOnly
    if (-not (Test-JaProjectContext -FullPath $full -ConfigInfo $cfgInfo)) {
        if ($isRo) {
            Exit-Deny ("JEDI VCS: '$full' está somente leitura e não há .dpr/.dpk, .jvcsproject nem mapa [projects] na pasta dele nem acima. Se for unit versionada (ex.: biblioteca compartilhada), faça o checkout com: $wr checkout `"$full`" -Project <projeto> ; senão, pergunte ao usuário. $noRo")
        }
        exit 0
    }
    $mode = $cfg.checkout
    $out = $null
    if ($mode -eq 'auto') { $out = & $wrapper 'ensure-checkout' $full -TimeoutSec 45 -LockWaitSec 30 }
    else { $out = & $wrapper 'ensure-checkout' $full -CheckOnly -TimeoutSec 45 -LockWaitSec 30 }
    $code = $LASTEXITCODE
    $res = $null
    try { $res = (@($out) -join "`n") | ConvertFrom-Json } catch { Exit-Fail ("JEDI VCS hook: resposta inválida do jvcs-ai.ps1; edição bloqueada. Saída: " + (@($out) -join ' ')) }
    $m = $null
    if ($res.modules -and @($res.modules).Count -gt 0) { $m = @($res.modules)[0] }
    $state = ''
    if ($m) { $state = [string]$m.state }

    if ($code -ne 0) {
        $hint = ''
        if ($code -eq 8) { $hint = ' Confira com: jvcs-ai.ps1 status "' + $full + '"; se a alteração local for sua e intencional, faça checkout -Force (mantém o local).' }
        if ($code -eq 6) { $hint = ' Não edite: avise o usuário.' }
        Exit-Deny ("JEDI VCS: edição de '$full' bloqueada (código $code): " + [string]$res.message + $hint)
    }
    $isRo = (New-Object IO.FileInfo $full).IsReadOnly
    switch ($state) {
        'notVersioned' {
            if ($isRo) { Exit-Deny ("JEDI VCS: '$full' está somente leitura e não é módulo versionado do projeto (" + [string]$m.message + "). Pergunte ao usuário. $noRo") }
            exit 0
        }
        'alreadyMine' {
            if ($isRo) {
                Exit-Deny ("JEDI VCS: o módulo de '$full' está em checkout pela sua identidade ($($m.lockedBy)), mas este arquivo está somente leitura: o checkout foi feito em outra pasta/máquina, ou o arquivo foi restaurado. Confira com: $wr status `"$full`" e pergunte ao usuário. $noRo")
            }
            exit 0
        }
        { $_ -eq 'checkedOut' -or $_ -eq 'checkedOutKeptLocal' } {
            if ($isRo) { Exit-Deny ("JEDI VCS: o checkout de '$full' foi feito, mas o arquivo continua somente leitura (caminho do servidor diferente?). Confira com: $wr status `"$full`". $noRo") }
            Exit-Info -Context ("JEDI VCS: checkout automático de '$full' feito pelo hook (módulo $($m.id), versão $($m.version)). Se o Edit acusar que o arquivo mudou desde a leitura, leia-o de novo e repita. " +
                "Ao terminar, faça o check-in com: $wr checkin `"$full`" -Comment `"...`" ; se a edição for negada ou você desistir, rode: $wr undocheckout `"$full`" .") `
                -UserMessage ("JEDI VCS: checkout automático de $([IO.Path]::GetFileName($full)) (v$($m.version))")
        }
        'needsCheckout' {
            if ($mode -eq 'manual') {
                Exit-Deny ("JEDI VCS (checkout=manual): '$full' não está em checkout. Peça ao usuário para fazer o checkout (IDE/GUI do JEDI VCS ou jvcs-ai.ps1 no terminal dele). $noRo")
            }
            Exit-Deny ("JEDI VCS (checkout=confirm): '$full' não está em checkout. Mostre ao usuário o que vai editar e rode: $wr checkout `"$full`" -Confirmed  " +
                "(o Claude Code pedirá a aprovação do usuário); depois repita a edição. $noRo")
        }
        default { Exit-Deny ("JEDI VCS: estado inesperado '$state' ao verificar '$full': " + [string]$res.message) }
    }
} catch {
    Exit-Fail ("JEDI VCS hook: erro interno; edição bloqueada por segurança: " + $_.Exception.Message)
}
