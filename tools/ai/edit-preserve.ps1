<#
.SYNOPSIS
    edit-preserve.ps1 - edita um fonte preservando a codificação (ANSI 1252, UTF-8 com/sem
    BOM, UTF-16) e as quebras de linha (CRLF/LF). Ver LEIAME.md.

.DESCRIPTION
    Substituição:   -Path <arq> -Old <texto> -New <texto> [-All] [-Regex]
                    (ou -OldFile/-NewFile com o texto em arquivos UTF-8)
    Conteúdo todo:  -Path <arq> -ContentFile <arquivo UTF-8> [-NewFileEncoding Ansi|Utf8Bom|Utf8|Utf16]

    - Falha se -Old não existir ou não for único (sem -All).
    - Quebras de linha em -Old/-New/-ContentFile são convertidas para as do arquivo.
    - Alvo ANSI (ou ASCII puro, tratado como ANSI por padrão: o compilador Delphi lê fonte
      sem BOM na code page ANSI) recusa caractere não representável em 1252.
    - Em fonte Delphi de projeto JEDI VCS, aplica o mesmo modo de checkout do hook:
      auto -> jvcs-ai.ps1 ensure-checkout antes de gravar; confirm/manual -> exige checkout prévio.
      -NoCheckout pula essa etapa (só humano; o arquivo somente leitura continua recusado).
    - Nunca remove o atributo somente leitura.
    - Em contexto de agente (CLAUDECODE, AI_AGENT ou stdin redirecionado): só grava fonte Delphi
      (.pas .dfm .fmx .dpr .dpk .dproj .inc) ou .rc .groupproj .bpg .txt .sql .iss, nunca em
      tools\ai, %APPDATA%\JEDI, %LOCALAPPDATA%\JEDI, .claude ou .git, e recusa -NoCheckout (10).

    Saída: JSON {ok, path, encoding, eol, replacements, bytesBefore, bytesAfter, checkout, message, exitCode}
    Códigos: 0 ok | 2 uso | 3 nada mudou | 4 -Old não encontrado | 5 -Old não é único |
             6 caractere não representável | 7 E/S (inexistente, somente leitura) |
             8 arquivo não suportado (binário, não faz ida e volta) | 9 JEDI VCS (checkout falhou) |
             10 checkout exige confirmação/manual

    Este arquivo é UTF-8 COM BOM e CRLF (Windows PowerShell 5.1).
#>
[CmdletBinding(PositionalBinding = $false)]
param(
    [Parameter(Mandatory = $true)][string]$Path,
    [string]$Old,
    [string]$New,
    [string]$OldFile,
    [string]$NewFile,
    [string]$ContentFile,
    [switch]$All,
    [switch]$Regex,
    [ValidateSet('Ansi', 'Utf8Bom', 'Utf8', 'Utf16')][string]$NewFileEncoding = 'Ansi',
    [ValidateSet('', 'ansi', 'utf8')][string]$AsciiAs = '',
    [switch]$NoCheckout,
    [switch]$DryRun,
    [switch]$Text
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\jvcs-ai-common.ps1')

$script:Res = [ordered]@{
    ok           = $false
    command      = 'edit-preserve'
    path         = $null
    encoding     = $null
    eol          = $null
    replacements = 0
    bytesBefore  = 0
    bytesAfter   = 0
    checkout     = $null
    message      = ''
    exitCode     = 0
}

function Read-Utf8File {
    param([string]$P)
    if (-not (Test-Path -LiteralPath $P -PathType Leaf)) { throw (New-JaError 2 "arquivo não encontrado: $P") }
    $b = [IO.File]::ReadAllBytes($P)
    $off = 0
    if ($b.Length -ge 3 -and $b[0] -eq 0xEF -and $b[1] -eq 0xBB -and $b[2] -eq 0xBF) { $off = 3 }
    try { return $script:JaUtf8Strict.GetString($b, $off, $b.Length - $off) }
    catch { throw (New-JaError 2 "$P não é UTF-8 válido (grave o texto em UTF-8)") }
}

function Convert-Eol {
    param([string]$S, [string]$Eol)
    if ($null -eq $S) { return $null }
    return [regex]::Replace($S, "`r`n|`r|`n", $Eol)
}

function Get-Encoder {
    param([string]$Kind)
    switch ($Kind) {
        'ansi' { return $script:JaEnc1252Strict }
        'utf8' { return (New-Object Text.UTF8Encoding($false, $true)) }
        'utf8bom' { return (New-Object Text.UTF8Encoding($false, $true)) }
        'utf16le' { return (New-Object Text.UnicodeEncoding($false, $false, $true)) }
        'utf16be' { return (New-Object Text.UnicodeEncoding($true, $false, $true)) }
    }
    throw (New-JaError 8 "codificação não suportada: $Kind")
}

function Get-Preamble {
    param([string]$Kind)
    switch ($Kind) {
        'utf8bom' { return [byte[]](0xEF, 0xBB, 0xBF) }
        'utf16le' { return [byte[]](0xFF, 0xFE) }
        'utf16be' { return [byte[]](0xFE, 0xFF) }
    }
    return [byte[]]@()
}

function ConvertTo-Bytes {
    param([string]$S, [string]$Kind)
    $enc = Get-Encoder $Kind
    try { $body = $enc.GetBytes($S) }
    catch {
        $bad = @()
        $lineNo = 1
        foreach ($ch in $S.ToCharArray()) {
            if ($ch -eq "`n") { $lineNo++; continue }
            if (-not (Test-JaAnsiText ([string]$ch))) { $bad += ('U+{0:X4} (linha {1})' -f [int]$ch, $lineNo); if ($bad.Count -ge 5) { break } }
        }
        throw (New-JaError 6 ("caractere(s) não representável(is) na codificação do arquivo ($Kind): " + ($bad -join ', ') + '. Use só caracteres de Windows-1252 ou converta o arquivo conscientemente'))
    }
    $pre = Get-Preamble $Kind
    if ($pre.Length -eq 0) { return , $body }
    $all = New-Object byte[] ($pre.Length + $body.Length)
    [Array]::Copy($pre, 0, $all, 0, $pre.Length)
    [Array]::Copy($body, 0, $all, $pre.Length, $body.Length)
    return , $all
}

# Aplica a política de checkout do JEDI VCS (mesma do hook).
function Invoke-JvcsGate {
    param([string]$Full)
    if ($NoCheckout) { return 'skipped' }
    $extL = [IO.Path]::GetExtension($Full).ToLowerInvariant()
    if (-not (Test-JaDelphiSource $Full) -and $script:JaExtraTextExtensions -notcontains $extL) { return 'notDelphiSource' }
    if ((Find-JaProjectFiles $Full).Count -eq 0) { return 'noProject' }
    $cfg = (Read-JaConfig).Values
    $wrapper = Join-Path $PSScriptRoot 'jvcs-ai.ps1'
    $mode = $cfg.checkout
    $out = $null
    if ($mode -eq 'auto') { $out = & $wrapper 'ensure-checkout' $Full }
    else { $out = & $wrapper 'ensure-checkout' $Full -CheckOnly }
    $code = $LASTEXITCODE
    $json = $null
    try { $json = ConvertTo-JaHashtable ((@($out) -join "`n") | ConvertFrom-Json) } catch { throw (New-JaError 9 "resposta inválida do jvcs-ai.ps1: $out") }
    $m = $null
    if ($json.modules -and $json.modules.Count -gt 0) { $m = $json.modules[0] }
    $state = ''
    if ($m) { $state = [string]$m.state }
    if ($code -ne 0) { throw (New-JaError 9 ("JEDI VCS: " + $json.message)) }
    if (@('notVersioned', 'alreadyMine', 'checkedOut', 'checkedOutKeptLocal') -contains $state) { return $state }
    if ($state -eq 'needsCheckout') {
        if ($mode -eq 'manual') { throw (New-JaError 10 "JEDI VCS (checkout=manual): '$Full' não está em checkout. Peça ao usuário para fazer o checkout.") }
        throw (New-JaError 10 ("JEDI VCS (checkout=confirm): '$Full' não está em checkout. Rode: " + (Get-JaCanonicalCommand 'jvcs-ai.ps1') + " checkout `"$Full`" -Confirmed  (o Claude Code pedirá aprovação ao usuário) e repita."))
    }
    throw (New-JaError 9 "JEDI VCS: estado inesperado '$state': $($json.message)")
}

try {
    $full = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
    $script:Res.path = $full
    if (Test-JaAgentContext) {
        # a IA não pode usar este script para contornar as regras deny do settings
        if ($NoCheckout) { throw (New-JaError 10 '-NoCheckout não é permitido à IA: o modo de checkout do config.ini vale para todas as edições') }
        $why = Get-JaProtectedPathReason $full
        if ($why) { throw (New-JaError 10 "edição recusada à IA: '$full' fica em $why") }
        $extL = [IO.Path]::GetExtension($full).ToLowerInvariant()
        if (-not (Test-JaDelphiSource $full) -and $script:JaExtraTextExtensions -notcontains $extL) {
            throw (New-JaError 10 "edição recusada à IA: edit-preserve só grava fontes Delphi ($($script:JaDelphiExtensions -join ' ')) e $($script:JaExtraTextExtensions -join ' '); '$extL' não está na lista")
        }
    }
    $modeContent = [bool]$ContentFile
    $modeReplace = ($PSBoundParameters.ContainsKey('Old') -or [bool]$OldFile)
    if ($modeContent -eq $modeReplace) { throw (New-JaError 2 'use -Old/-New (ou -OldFile/-NewFile) OU -ContentFile') }
    if ($modeReplace -and -not ($PSBoundParameters.ContainsKey('New') -or [bool]$NewFile)) { throw (New-JaError 2 'informe -New (ou -NewFile); para apagar use -New ""') }
    if ($OldFile) { $Old = Read-Utf8File $OldFile }
    if ($NewFile) { $New = Read-Utf8File $NewFile }
    if ($modeReplace -and [string]::IsNullOrEmpty($Old)) { throw (New-JaError 2 '-Old não pode ser vazio') }
    if ($null -eq $New) { $New = '' }

    $cfgAscii = (Read-JaConfig).Values.asciiAs
    if ($AsciiAs) { $cfgAscii = $AsciiAs }

    $exists = Test-Path -LiteralPath $full -PathType Leaf
    if (-not $exists) {
        if (-not $modeContent) { throw (New-JaError 7 "arquivo não encontrado: $full") }
        $dir = Split-Path -Parent $full
        if (-not (Test-Path -LiteralPath $dir -PathType Container)) { throw (New-JaError 7 "pasta não existe: $dir") }
        $kind = @{ Ansi = 'ansi'; Utf8Bom = 'utf8bom'; Utf8 = 'utf8'; Utf16 = 'utf16le' }[$NewFileEncoding]
        $newText = Convert-Eol (Read-Utf8File $ContentFile) "`r`n"
        $bytes = ConvertTo-Bytes $newText $kind
        $script:Res.encoding = $kind; $script:Res.eol = 'crlf'; $script:Res.bytesAfter = $bytes.Length
        $script:Res.checkout = 'newFile'
        if (-not $DryRun) { [IO.File]::WriteAllBytes($full, $bytes) }
        $script:Res.message = "arquivo novo criado ($kind, CRLF)"
        if ($DryRun) { $script:Res.message = "simulação: criaria arquivo novo ($kind, CRLF)" }
        $script:Res.ok = $true
    } else {
        $orig = [IO.File]::ReadAllBytes($full)
        $info = Get-JaTextInfo $orig
        $script:Res.bytesBefore = $orig.Length
        $script:Res.eol = $info.Eol
        if ($info.Kind -eq 'binary') { throw (New-JaError 8 'arquivo binário (ex.: DFM binário, .res): não é editável como texto') }
        $kind = $info.Kind
        $script:Res.encoding = $kind
        # ida e volta: o arquivo precisa ser reproduzido byte a byte antes de editar
        $encKind = $kind
        if ($kind -eq 'ascii') { $encKind = 'ansi' }
        $rt = ConvertTo-Bytes $info.Text $encKind
        if (-not (Test-JaBytesEqual $rt $orig)) { throw (New-JaError 8 "o arquivo não faz ida e volta na codificação detectada ($kind); edição recusada para não corromper") }

        $eol = "`r`n"
        if ($info.Eol -eq 'cr') { $eol = "`r" }
        elseif ($info.Lf -gt $info.CrLf -and $info.Lf -ge $info.Cr) { $eol = "`n" }
        elseif ($info.Cr -gt $info.CrLf -and $info.Cr -gt $info.Lf) { $eol = "`r" }
        $srcText = $info.Text
        $count = 0
        if ($modeContent) {
            $newText = Convert-Eol (Read-Utf8File $ContentFile) $eol
            $count = 1
        } elseif ($Regex) {
            $NewN = Convert-Eol $New $eol
            try { $rx = New-Object System.Text.RegularExpressions.Regex($Old) } catch { throw (New-JaError 2 "expressão regular inválida: $($_.Exception.Message)") }
            $count = $rx.Matches($srcText).Count
            if ($count -eq 0) { throw (New-JaError 4 'padrão -Old não encontrado') }
            if ($count -gt 1 -and -not $All) { throw (New-JaError 5 "padrão -Old ocorre $count vezes; torne-o único ou use -All") }
            if ($All) { $newText = $rx.Replace($srcText, $NewN) } else { $newText = $rx.Replace($srcText, $NewN, 1) }
        } else {
            $OldN = Convert-Eol $Old $eol
            $NewN = Convert-Eol $New $eol
            $idx = 0
            while (($idx = $srcText.IndexOf($OldN, $idx, [StringComparison]::Ordinal)) -ge 0) { $count++; $idx += $OldN.Length }
            if ($count -eq 0) {
                $hint = ''
                if ($srcText.IndexOf($OldN, [StringComparison]::OrdinalIgnoreCase) -ge 0) { $hint = ' (existe com outra capitalização)' }
                throw (New-JaError 4 "texto -Old não encontrado$hint")
            }
            if ($count -gt 1 -and -not $All) { throw (New-JaError 5 "texto -Old ocorre $count vezes; inclua mais contexto ou use -All") }
            if ($All) { $newText = $srcText.Replace($OldN, $NewN) }
            else { $p = $srcText.IndexOf($OldN, [StringComparison]::Ordinal); $newText = $srcText.Substring(0, $p) + $NewN + $srcText.Substring($p + $OldN.Length) }
        }
        $script:Res.replacements = $count
        if ($newText -ceq $srcText) { throw (New-JaError 3 'nada mudou (o resultado é idêntico ao arquivo)') }

        $outKind = $kind
        if ($kind -eq 'ascii') {
            if ($cfgAscii -eq 'utf8') { $outKind = 'utf8' } else { $outKind = 'ansi' }
        }
        $bytes = ConvertTo-Bytes $newText $outKind
        $script:Res.bytesAfter = $bytes.Length
        if ($outKind -ne $kind -and [regex]::IsMatch($newText, '[^\x00-\x7f]')) { $script:Res.encoding = "$kind->$outKind" }

        # política do JEDI VCS antes de gravar
        $script:Res.checkout = Invoke-JvcsGate $full
        $now = [IO.File]::ReadAllBytes($full)
        if (-not (Test-JaBytesEqual $now $orig)) { throw (New-JaError 7 'o arquivo mudou durante o checkout; leia de novo e repita a edição') }
        if ((New-Object IO.FileInfo $full).IsReadOnly) {
            throw (New-JaError 7 'arquivo somente leitura: faça checkout no JEDI VCS (jvcs-ai.ps1 checkout). Não remova o atributo.')
        }
        if (-not $DryRun) { [IO.File]::WriteAllBytes($full, $bytes) }
        $script:Res.ok = $true
        $script:Res.message = "$count substituição(ões); codificação $($script:Res.encoding), quebras $($info.Eol) preservadas"
        if ($modeContent) { $script:Res.message = "conteúdo regravado na codificação $($script:Res.encoding) com quebras $($info.Eol)" }
        if ($DryRun) { $script:Res.message = 'simulação: ' + $script:Res.message }
    }
} catch {
    $script:Res.ok = $false
    $script:Res.exitCode = Get-JaErrorCode $_ 9
    $script:Res.message = Get-JaErrorMessage $_
    if ($script:Res.exitCode -eq 3) { $script:Res.ok = $true }
}

if ($Text) {
    $tag = 'ERRO'
    if ($script:Res.ok) { $tag = 'OK' }
    Write-Output ("[$tag $($script:Res.exitCode)] $($script:Res.path): $($script:Res.message)")
} else {
    Write-Output (ConvertTo-JaJson $script:Res -Ascii)
}
exit $script:Res.exitCode
