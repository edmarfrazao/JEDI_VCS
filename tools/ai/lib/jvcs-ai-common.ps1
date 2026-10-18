# jvcs-ai-common.ps1 - funções compartilhadas por jvcs-ai.ps1, edit-preserve.ps1,
# hooks\pretooluse.ps1 e instalar-no-projeto.ps1.
#
# Uso: . (Join-Path $PSScriptRoot 'lib\jvcs-ai-common.ps1')   (dot-source)
#
# Requisitos: Windows PowerShell 5.1 (sem sintaxe do PowerShell 7). Este arquivo é
# gravado em UTF-8 COM BOM e CRLF; mantenha assim (o PowerShell 5.1 lê arquivo sem
# BOM na code page ANSI e corromperia os acentos das mensagens).
#
# Nada aqui lê ou imprime a senha da identidade; isso fica só em jvcs-ai.ps1.

$script:JaVersion = '1.4.0'

# Extensões de fonte Delphi protegidas pelo hook e pelo edit-preserve.
$script:JaDelphiExtensions = @('.pas', '.dfm', '.fmx', '.dpr', '.dpk', '.dproj', '.inc')
# Outros textos que o edit-preserve aceita editar quando chamado pela IA (além dos fontes Delphi).
$script:JaExtraTextExtensions = @('.rc', '.groupproj', '.bpg', '.txt', '.sql', '.iss')

# Pasta tools\ai (esta lib fica em tools\ai\lib).
$script:JaToolsDir = Split-Path -Parent $PSScriptRoot

# Padrão do console (JVCSClientConsts.dfNotReadOnly): tipos que nunca ficam somente leitura.
$script:JaDefaultWritableFilter = '*.prl;*.pcr;*.dof;*.dpr;*.bpr;*.res;*.fvc;*.jvcs;*.dpk;*.bpk;*.dsk;*.cfg;*.todo;*.tlb;*_tlb.pas;*.bdsproj;*.cbproj;*.dproj'

$script:JaConfigDefaults = [ordered]@{
    checkout      = 'confirm'
    checkin       = 'confirm'
    commentPrefix = '[IA]'
    jvcsExe       = 'C:\Program Files (x86)\JEDI\JVCS\jvcs.exe'
    timeoutSec    = '120'
    lockWaitSec   = '120'
    identity      = ''
    asciiAs       = 'ansi'
    moduleAdmin   = 'off'
    projectAdmin  = 'off'
    blameMaxRevisions  = '200'
    cacheMaxMB         = '500'
    buildCheck         = 'off'
    buildCommand       = ''
    buildConfig        = 'Debug'
    buildPlatform      = 'Win32'
    buildTimeoutSec    = '600'
    buildCommandSha256 = ''
}

# Codificações. 1252 estrita (exceção em caractere não representável) para gravar;
# a decodificação de 1252 no .NET mapeia todos os 256 bytes.
$script:JaEnc1252Strict = [Text.Encoding]::GetEncoding(1252, (New-Object Text.EncoderExceptionFallback), (New-Object Text.DecoderExceptionFallback))
$script:JaEnc1252 = [Text.Encoding]::GetEncoding(1252)
$script:JaUtf8Strict = New-Object Text.UTF8Encoding($false, $true)
$script:JaUtf8NoBom = New-Object Text.UTF8Encoding($false)
$script:JaLatin1 = [Text.Encoding]::GetEncoding(28591)

# ---------------------------------------------------------------- erros

# Cria uma exceção com código de saída estável (Data['jaCode']).
function New-JaError {
    param([int]$Code, [string]$Message, $Data = $null)
    $e = New-Object System.Exception $Message
    $e.Data['jaCode'] = $Code
    if ($null -ne $Data) { $e.Data['jaData'] = $Data }
    return $e
}

function Get-JaErrorCode {
    param($ErrorRecord, [int]$Default = 9)
    $ex = $ErrorRecord.Exception
    while ($null -ne $ex) {
        if ($ex.Data -and $ex.Data.Contains('jaCode')) { return [int]$ex.Data['jaCode'] }
        $ex = $ex.InnerException
    }
    return $Default
}

function Get-JaErrorMessage {
    param($ErrorRecord)
    $ex = $ErrorRecord.Exception
    $probe = $ex
    while ($null -ne $probe) {
        if ($probe.Data -and $probe.Data.Contains('jaCode')) { return $probe.Message }
        $probe = $probe.InnerException
    }
    $line = ''
    if ($ErrorRecord.InvocationInfo) { $line = ' (linha ' + $ErrorRecord.InvocationInfo.ScriptLineNumber + ')' }
    return ('erro interno: ' + $ex.Message + $line)
}

# ---------------------------------------------------------------- JSON

function ConvertTo-JaJsonString {
    param([string]$Value, [switch]$Ascii)
    if ($null -eq $Value) { return 'null' }
    $s = $Value.Replace('\', '\\').Replace('"', '\"').Replace("`r", '\r').Replace("`n", '\n').Replace("`t", '\t')
    $s = [regex]::Replace($s, '[\x00-\x1f]', { param($m) '\u{0:x4}' -f [int][char]$m.Value })
    if ($Ascii) {
        $s = [regex]::Replace($s, '[^\x00-\x7e]', { param($m) '\u{0:x4}' -f [int][char]$m.Value })
    }
    return '"' + $s + '"'
}

# Serializador JSON próprio: ordem das chaves preservada, sem as escapas estranhas do
# ConvertTo-Json do PS 5.1 e com -Ascii (tudo acima de 0x7E vira \uXXXX), o que torna a
# saída imune à code page do console.
function ConvertTo-JaJson {
    param($Value, [switch]$Pretty, [switch]$Ascii, [int]$Level = 0)
    $nl = ''; $ind = ''; $ind2 = ''; $sep = ':'
    if ($Pretty) { $nl = "`n"; $ind = '  ' * $Level; $ind2 = '  ' * ($Level + 1); $sep = ': ' }
    if ($null -eq $Value) { return 'null' }
    if ($Value -is [bool]) { if ($Value) { return 'true' } else { return 'false' } }
    if ($Value -is [string] -or $Value -is [char]) { return (ConvertTo-JaJsonString ([string]$Value) -Ascii:$Ascii) }
    if ($Value -is [enum]) { return (ConvertTo-JaJsonString $Value.ToString() -Ascii:$Ascii) }
    if ($Value -is [datetime]) { return (ConvertTo-JaJsonString $Value.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ') -Ascii:$Ascii) }
    if ($Value -is [int] -or $Value -is [long] -or $Value -is [int16] -or $Value -is [byte] -or $Value -is [uint32] -or $Value -is [uint64] -or $Value -is [double] -or $Value -is [single] -or $Value -is [decimal]) {
        return ([string]::Format([Globalization.CultureInfo]::InvariantCulture, '{0}', $Value))
    }
    if ($Value -is [System.Collections.IDictionary]) {
        $parts = New-Object System.Collections.Generic.List[string]
        foreach ($k in $Value.Keys) {
            $parts.Add($ind2 + (ConvertTo-JaJsonString ([string]$k) -Ascii:$Ascii) + $sep + (ConvertTo-JaJson $Value[$k] -Pretty:$Pretty -Ascii:$Ascii -Level ($Level + 1)))
        }
        if ($parts.Count -eq 0) { return '{}' }
        return '{' + $nl + ($parts -join (',' + $nl)) + $nl + $ind + '}'
    }
    if ($Value -is [System.Management.Automation.PSCustomObject]) {
        $parts = New-Object System.Collections.Generic.List[string]
        foreach ($p in $Value.PSObject.Properties) {
            $parts.Add($ind2 + (ConvertTo-JaJsonString $p.Name -Ascii:$Ascii) + $sep + (ConvertTo-JaJson $p.Value -Pretty:$Pretty -Ascii:$Ascii -Level ($Level + 1)))
        }
        if ($parts.Count -eq 0) { return '{}' }
        return '{' + $nl + ($parts -join (',' + $nl)) + $nl + $ind + '}'
    }
    if ($Value -is [System.Collections.IEnumerable]) {
        $parts = New-Object System.Collections.Generic.List[string]
        foreach ($i in $Value) {
            $parts.Add($ind2 + (ConvertTo-JaJson $i -Pretty:$Pretty -Ascii:$Ascii -Level ($Level + 1)))
        }
        if ($parts.Count -eq 0) { return '[]' }
        return '[' + $nl + ($parts -join (',' + $nl)) + $nl + $ind + ']'
    }
    return (ConvertTo-JaJsonString ([string]$Value) -Ascii:$Ascii)
}

# Converte o resultado do ConvertFrom-Json (PSCustomObject) em hashtables ordenadas e
# ArrayList, mais fáceis de alterar no PS 5.1.
function ConvertTo-JaHashtable {
    param($Value)
    if ($null -eq $Value) { return $null }
    if ($Value -is [System.Management.Automation.PSCustomObject]) {
        $h = [ordered]@{}
        foreach ($p in $Value.PSObject.Properties) { $h[$p.Name] = ConvertTo-JaHashtable $p.Value }
        return $h
    }
    if ($Value -is [string]) { return $Value }
    if ($Value -is [System.Collections.IDictionary]) {
        $h = [ordered]@{}
        foreach ($k in $Value.Keys) { $h[$k] = ConvertTo-JaHashtable $Value[$k] }
        return $h
    }
    if ($Value -is [System.Collections.IEnumerable]) {
        $list = New-Object System.Collections.ArrayList
        foreach ($i in $Value) { [void]$list.Add((ConvertTo-JaHashtable $i)) }
        return , $list
    }
    return $Value
}

function Read-JaJsonFile {
    param([string]$Path)
    $bytes = [IO.File]::ReadAllBytes($Path)
    $text = $script:JaUtf8NoBom.GetString($bytes)
    if ($text.Length -gt 0 -and $text[0] -eq [char]0xFEFF) { $text = $text.Substring(1) }
    if ($text.Trim().Length -eq 0) { return [ordered]@{} }
    return (ConvertTo-JaHashtable ($text | ConvertFrom-Json))
}

# ---------------------------------------------------------------- texto e codificação

function Test-JaAnsiText {
    param([string]$Value)
    try { [void]$script:JaEnc1252Strict.GetBytes($Value); return $true } catch { return $false }
}

function Get-JaFirstNonAnsiChar {
    param([string]$Value)
    foreach ($ch in $Value.ToCharArray()) {
        if (-not (Test-JaAnsiText ([string]$ch))) { return ('U+{0:X4}' -f [int]$ch) }
    }
    return ''
}

function Test-JaBytesEqual {
    param([byte[]]$A, [byte[]]$B)
    if ($A.Length -ne $B.Length) { return $false }
    if ($A.Length -eq 0) { return $true }
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        $ha = [Convert]::ToBase64String($sha.ComputeHash($A))
        $hb = [Convert]::ToBase64String($sha.ComputeHash($B))
    } finally { $sha.Dispose() }
    return ($ha -eq $hb)
}

# Classifica os bytes de um fonte:
#   utf8bom | utf16le | utf16be | utf8 (válido, sem BOM, com não-ASCII) | ascii | ansi | binary
# e as quebras de linha: crlf | lf | cr | mixed | none.
function Get-JaTextInfo {
    param([byte[]]$Bytes)
    $n = $Bytes.Length
    $kind = $null; $bom = 0
    if ($n -ge 3 -and $Bytes[0] -eq 0xEF -and $Bytes[1] -eq 0xBB -and $Bytes[2] -eq 0xBF) { $kind = 'utf8bom'; $bom = 3 }
    elseif ($n -ge 2 -and $Bytes[0] -eq 0xFF -and $Bytes[1] -eq 0xFE) { $kind = 'utf16le'; $bom = 2 }
    elseif ($n -ge 2 -and $Bytes[0] -eq 0xFE -and $Bytes[1] -eq 0xFF) { $kind = 'utf16be'; $bom = 2 }
    else {
        $latin = $script:JaLatin1.GetString($Bytes)
        if ($latin.IndexOf([char]0) -ge 0) { $kind = 'binary' }
        elseif (-not [regex]::IsMatch($latin, '[\x80-\xff]')) { $kind = 'ascii' }
        else {
            try { [void]$script:JaUtf8Strict.GetString($Bytes); $kind = 'utf8' } catch { $kind = 'ansi' }
        }
    }
    $text = $null
    switch ($kind) {
        'utf8bom' { try { $text = $script:JaUtf8Strict.GetString($Bytes, 3, $n - 3) } catch { $text = $script:JaUtf8NoBom.GetString($Bytes, 3, $n - 3) } }
        'utf16le' { $text = [Text.Encoding]::Unicode.GetString($Bytes, 2, $n - 2) }
        'utf16be' { $text = [Text.Encoding]::BigEndianUnicode.GetString($Bytes, 2, $n - 2) }
        'utf8' { $text = $script:JaUtf8Strict.GetString($Bytes) }
        'ascii' { $text = $script:JaLatin1.GetString($Bytes) }
        'ansi' { $text = $script:JaEnc1252.GetString($Bytes) }
        default { $text = '' }
    }
    $crlf = 0; $lf = 0; $cr = 0; $fffd = 0
    if ($kind -ne 'binary') {
        $crlf = [regex]::Matches($text, "`r`n").Count
        $lf = [regex]::Matches($text, "(?<!`r)`n").Count
        $cr = [regex]::Matches($text, "`r(?!`n)").Count
        $fffd = [regex]::Matches($text, [string][char]0xFFFD).Count
    }
    $eol = 'none'
    if ($crlf -gt 0 -and $lf -eq 0 -and $cr -eq 0) { $eol = 'crlf' }
    elseif ($lf -gt 0 -and $crlf -eq 0 -and $cr -eq 0) { $eol = 'lf' }
    elseif ($cr -gt 0 -and $crlf -eq 0 -and $lf -eq 0) { $eol = 'cr' }
    elseif (($crlf + $lf + $cr) -gt 0) { $eol = 'mixed' }
    return [pscustomobject]@{
        Kind = $kind; BomLength = $bom; Eol = $eol; CrLf = $crlf; Lf = $lf; Cr = $cr
        ReplacementChars = $fffd; Text = $text; Length = $n
    }
}

function Get-JaTextInfoFromFile {
    param([string]$Path)
    return (Get-JaTextInfo ([IO.File]::ReadAllBytes($Path)))
}

# Compara a codificação de um membro local com a base do servidor.
# Devolve a lista de problemas (vazia = ok). Arquivos binários são ignorados.
function Compare-JaEncoding {
    param([byte[]]$BaseBytes, [byte[]]$LocalBytes)
    $problems = New-Object System.Collections.Generic.List[string]
    $b = Get-JaTextInfo $BaseBytes
    $l = Get-JaTextInfo $LocalBytes
    if ($b.Kind -eq 'binary' -or $l.Kind -eq 'binary') {
        if ($b.Kind -ne $l.Kind) { $problems.Add("tipo mudou: base $($b.Kind), local $($l.Kind)") }
        return , $problems
    }
    $bU16 = ($b.Kind -like 'utf16*'); $lU16 = ($l.Kind -like 'utf16*')
    if ($b.Kind -eq 'utf8bom' -and $l.Kind -ne 'utf8bom') { $problems.Add("BOM UTF-8 removido (base utf8bom, local $($l.Kind))") }
    elseif ($b.Kind -ne 'utf8bom' -and $l.Kind -eq 'utf8bom') { $problems.Add("BOM UTF-8 acrescentado (base $($b.Kind))") }
    elseif ($bU16 -ne $lU16 -or ($bU16 -and $b.Kind -ne $l.Kind)) { $problems.Add("UTF-16 mudou (base $($b.Kind), local $($l.Kind))") }
    elseif (($b.Kind -eq 'ascii' -or $b.Kind -eq 'ansi') -and $l.Kind -eq 'utf8') {
        $problems.Add("fonte ANSI/ASCII regravado como UTF-8 sem BOM (o compilador Delphi lê sem BOM como ANSI e corrompe os acentos)")
    }
    elseif ($b.Kind -eq 'utf8' -and $l.Kind -eq 'ansi') { $problems.Add('fonte UTF-8 sem BOM regravado como ANSI') }
    if ($b.Eol -eq 'crlf' -and ($l.Lf -gt 0 -or $l.Cr -gt 0)) { $problems.Add("quebras de linha: base CRLF, local tem $($l.Lf) LF e $($l.Cr) CR isolados") }
    elseif ($b.Eol -eq 'lf' -and ($l.CrLf -gt 0 -or $l.Cr -gt 0)) { $problems.Add("quebras de linha: base LF, local tem $($l.CrLf) CRLF e $($l.Cr) CR isolados") }
    elseif ($b.Eol -eq 'cr' -and ($l.CrLf -gt 0 -or $l.Lf -gt 0)) { $problems.Add("quebras de linha: base CR, local tem $($l.CrLf) CRLF e $($l.Lf) LF") }
    if ($l.ReplacementChars -gt $b.ReplacementChars) { $problems.Add("caractere U+FFFD apareceu ($($l.ReplacementChars) no local, $($b.ReplacementChars) na base): sinal de corrupção de codificação") }
    return , $problems
}

function Test-JaDelphiSource {
    param([string]$Path)
    $ext = [IO.Path]::GetExtension($Path).ToLowerInvariant()
    return ($script:JaDelphiExtensions -contains $ext)
}

# Procura .dpr/.dpk na pasta do arquivo e nas pastas acima (mais próxima primeiro).
function Find-JaProjectFiles {
    param([string]$FullPath)
    $result = New-Object System.Collections.ArrayList
    $dir = [IO.Path]::GetDirectoryName($FullPath)
    $level = 0
    while ($dir) {
        if (Test-Path -LiteralPath $dir -PathType Container) {
            $found = @(Get-ChildItem -LiteralPath $dir -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -ieq '.dpr' -or $_.Extension -ieq '.dpk' } | Sort-Object Name)
            foreach ($f in $found) {
                [void]$result.Add([pscustomobject]@{ Name = $f.Name.ToLowerInvariant(); Path = $f.FullName; Dir = $dir; Level = $level })
            }
        }
        $parent = [IO.Path]::GetDirectoryName($dir)
        if (-not $parent -or $parent -eq $dir) { break }
        $dir = $parent
        $level++
    }
    return , $result
}

# ---------------------------------------------------------------- projeto/identidade por pasta (R4)
#
# Acervos sem .dpr/.dpk (xHarbour, scripts...) acham o projeto por:
#   1. arquivo-marcador .jvcsproject na pasta (ou acima): "project=<nome>" e, opcional, "identity=<nome>";
#   2. mapa [projects] do config.ini ("<pasta>=<projeto>"), gravado só pelo usuário (config set projectMap).
# A identidade por pasta vem SÓ do mapa [identities] do config.ini (config set identityMap, só humano).
# O identity= do .jvcsproject apenas CONFERE a identidade em uso (recusa se divergir), nunca a escolhe:
# o marcador fica na pasta do projeto, onde a IA, o Git ou o servidor (sync) podem gravá-lo.

$script:JaMarkerName = '.jvcsproject'
$script:JaMarkerCache = @{}

# Caracteres que, numa dica de comando (Assert-Mode/Assert-RiskyOption montam '-Project <nome>' SEM
# aspas, e a IA repete a dica com -Confirmed), virariam outro comando ou expansão no PowerShell, cmd ou
# bash. Nome vindo de arquivo (.jvcsproject, config.ini) é dado: não pode tê-los.
$script:JaHintUnsafeChars = '[`$;&|''(){}\[\]%!^,@#=<>]'

# '' = nome de projeto aceitável; senão, o motivo. O nome vai entre aspas numa linha do /input
# (openproject/listproject "<nome>") e sem aspas nas dicas de aprovação: nada de controle, aspas,
# caractere de caminho/máscara nem caractere especial de shell.
function Test-JaProjectNameText {
    param([string]$Name)
    if ([string]::IsNullOrWhiteSpace($Name)) { return 'nome vazio' }
    $n = $Name.Trim()
    if ($n -match '[\x00-\x1f\x7f"]') { return 'caractere de controle ou aspas' }
    if ($n -match '[<>|*?:\\/]') { return 'caractere de caminho ou máscara (< > | * ? : \ /)' }
    if ($n -match $script:JaHintUnsafeChars) { return 'caractere especial de shell (` $ ; & '' ( ) { } [ ] % ! ^ , @ # =)' }
    if ($n.StartsWith('-')) { return 'começa com -' }
    if ($n -match '^\d+$') { return 'só dígitos (o console trataria como ID)' }
    if ($n.Length -gt 50) { return 'mais de 50 caracteres' }
    if (-not (Test-JaAnsiText $n)) { return "caractere fora da code page 1252 ($(Get-JaFirstNonAnsiChar $n))" }
    return ''
}

# Mesmas regras do Get-JaIdentity (nome de subchave de HKCU\...\Identities).
function Test-JaIdentityNameText {
    param([string]$Name)
    if ([string]::IsNullOrWhiteSpace($Name)) { return 'nome vazio' }
    $n = $Name.Trim()
    if ($n -match '[\\/"\x00-\x1f\x7f]' -or $n -eq '.' -or $n -eq '..') { return 'caractere inválido (\ / aspas ou controle)' }
    if ($n.Length -gt 100) { return 'mais de 100 caracteres' }
    if (-not (Test-JaAnsiText $n)) { return "caractere fora da code page 1252 ($(Get-JaFirstNonAnsiChar $n))" }
    return ''
}

# Lê um .jvcsproject (até 4 KB; ANSI 1252, UTF-8 com ou sem BOM, UTF-16 com BOM - o ">" do PS 5.1 grava UTF-16).
#   ; comentário (ou #)
#   project=<nome do projeto no servidor>   obrigatório (ou a 1ª linha útil só com o nome, sem "=")
#   identity=<identidade salva>             opcional: só confere a identidade em uso
# O conteúdo é dado, não comando: o que fugir disso recusa o marcador (7). As mensagens não repetem o
# texto do arquivo (só o motivo e o caminho).
function Read-JaProjectMarker {
    param([string]$Path)
    $ck = $Path.ToLowerInvariant()
    if ($script:JaMarkerCache.ContainsKey($ck)) { return $script:JaMarkerCache[$ck] }
    $bad = "marcador $Path inválido"
    $b = $null
    try {
        $fi = New-Object IO.FileInfo $Path
        if ($fi.Length -le 4096) { $b = [IO.File]::ReadAllBytes($Path) }
    } catch { throw (New-JaError 7 "${bad}: não foi possível ler o arquivo") }
    if ($null -eq $b) { throw (New-JaError 7 "${bad}: mais de 4 KB") }
    $text = $null
    try {
        if ($b.Length -ge 3 -and $b[0] -eq 0xEF -and $b[1] -eq 0xBB -and $b[2] -eq 0xBF) { $text = $script:JaUtf8Strict.GetString($b, 3, $b.Length - 3) }
        elseif ($b.Length -ge 2 -and $b[0] -eq 0xFF -and $b[1] -eq 0xFE) { $text = (New-Object Text.UnicodeEncoding($false, $false, $true)).GetString($b, 2, $b.Length - 2) }
        elseif ($b.Length -ge 2 -and $b[0] -eq 0xFE -and $b[1] -eq 0xFF) { $text = (New-Object Text.UnicodeEncoding($true, $false, $true)).GetString($b, 2, $b.Length - 2) }
        else {
            try { $text = $script:JaUtf8Strict.GetString($b) } catch { $text = $script:JaEnc1252.GetString($b) }
        }
    } catch { throw (New-JaError 7 "${bad}: codificação ilegível") }
    $proj = $null; $ident = $null
    $unknown = New-Object System.Collections.ArrayList
    $n = 0
    foreach ($raw in ($text -split "`r`n|`n|`r")) {
        $n++
        $line = $raw.Trim()
        if ($line.Length -gt 0 -and $line[0] -eq [char]0xFEFF) { $line = $line.Substring(1).Trim() }
        if ($line -eq '' -or $line.StartsWith(';') -or $line.StartsWith('#')) { continue }
        if ($line -match '^([A-Za-z][A-Za-z0-9_]{0,29})\s*=\s*(.*)$') {
            $k = $Matches[1].ToLowerInvariant(); $v = $Matches[2].Trim()
            if ($k -eq 'project') {
                if ($null -ne $proj) { throw (New-JaError 7 "${bad}: project repetido (linha $n)") }
                $proj = $v
            } elseif ($k -eq 'identity') {
                if ($null -ne $ident) { throw (New-JaError 7 "${bad}: identity repetido (linha $n)") }
                $ident = $v
            } elseif ($unknown.Count -lt 5 -and -not $unknown.Contains($k)) { [void]$unknown.Add($k) }
        } elseif ($null -eq $proj -and $line -notmatch '=') { $proj = $line }
        else { throw (New-JaError 7 "${bad}: linha $n não reconhecida (use project=<nome> e, opcional, identity=<nome>)") }
    }
    if (-not $proj) { throw (New-JaError 7 "${bad}: falta project=<nome>") }
    $why = Test-JaProjectNameText $proj
    if ($why) { throw (New-JaError 7 "${bad}: project: $why") }
    if ($ident -eq '') { $ident = $null }
    if ($null -ne $ident) {
        $why = Test-JaIdentityNameText $ident
        # o identity= do marcador aparece nas mensagens/sugestões de comando: nada de caractere de shell
        if (-not $why -and ($ident -match $script:JaHintUnsafeChars -or $ident.Trim().StartsWith('-'))) { $why = 'caractere especial de shell ou começa com -' }
        if ($why) { throw (New-JaError 7 "${bad}: identity: $why") }
        $ident = $ident.Trim()
    }
    $m = [pscustomobject]@{ Path = $Path; Dir = [IO.Path]::GetDirectoryName($Path); Project = $proj.Trim().ToLowerInvariant(); Identity = $ident; Unknown = @($unknown) }
    $script:JaMarkerCache[$ck] = $m
    return $m
}

# Marcadores .jvcsproject da pasta $Dir e acima (mais próximo primeiro), com o nível (0 = a própria pasta).
function Find-JaProjectMarkers {
    param([string]$Dir)
    $out = New-Object System.Collections.ArrayList
    $level = 0
    while ($Dir) {
        $p = [IO.Path]::Combine($Dir, $script:JaMarkerName)
        if (Test-Path -LiteralPath $p -PathType Leaf) {
            $m = Read-JaProjectMarker $p
            [void]$out.Add([pscustomobject]@{ Path = $m.Path; Dir = $Dir; Level = $level; Project = $m.Project; Identity = $m.Identity; Unknown = $m.Unknown })
        }
        $parent = [IO.Path]::GetDirectoryName($Dir)
        if (-not $parent -or $parent -eq $Dir) { break }
        $Dir = $parent
        $level++
    }
    return , $out
}

# Pasta normalizada para chave dos mapas: absoluta (d:\... ou \\srv\share\...), minúsculas, sem barra
# final (exceto "d:\"). $null se não for caminho absoluto válido. O GetFullPath expande nomes 8.3 de
# pastas existentes; subst, junções e links NÃO são resolvidos.
function ConvertTo-JaDirKey {
    param([string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) { return $null }
    $p = $Path.Trim().Replace('/', '\')
    if ($p -notmatch '^([A-Za-z]:\\|\\\\[^\\]+\\[^\\]+)') { return $null }
    try { $p = [IO.Path]::GetFullPath($p) } catch { return $null }
    $p = $p.TrimEnd('\')
    if ($p -match '^[A-Za-z]:$') { $p += '\' }
    return $p.ToLowerInvariant()
}

# Entrada do mapa (chave = pasta normalizada) que vale para $Dir: a da pasta mais próxima, atual ou acima.
function Find-JaMapEntry {
    param($Map, [string]$Dir)
    if ($null -eq $Map -or $Map.Count -eq 0) { return $null }
    $k = ConvertTo-JaDirKey $Dir
    $level = 0
    while ($k) {
        if ($Map.Contains($k)) { return [pscustomobject]@{ Dir = $k; Value = [string]$Map[$k]; Level = $level } }
        $parent = [IO.Path]::GetDirectoryName($k)
        if (-not $parent -or $parent -eq $k) { break }
        $k = $parent.TrimEnd('\')
        if ($k -match '^[a-z]:$') { $k += '\' }
        $level++
    }
    return $null
}

# Pastas do mapa [projects] que apontam para o projeto (busca reversa: rodado fora da pasta).
function Get-JaMapDirsForProject {
    param($Map, [string]$ProjectName)
    $out = New-Object System.Collections.ArrayList
    if ($null -eq $Map) { return , $out }
    foreach ($k in @($Map.Keys)) { if ([string]$Map[$k] -ieq $ProjectName) { [void]$out.Add($k) } }
    return , $out
}

# Projetos candidatos de um arquivo, da pasta dele para cima. Em cada nível: .jvcsproject (Rank 1),
# mapa [projects] (Rank 2) e .dpr/.dpk (Rank 3). Ordem: nível, depois Rank; nome repetido fica no 1º.
function Get-JaProjectCandidates {
    param([string]$FullPath, $ProjectMap)
    $dir0 = [IO.Path]::GetDirectoryName($FullPath)
    $all = New-Object System.Collections.ArrayList
    foreach ($m in (Find-JaProjectMarkers $dir0)) {
        [void]$all.Add([pscustomobject]@{ Name = $m.Project; Level = $m.Level; Rank = 1; Source = '.jvcsproject'; Where = $m.Path })
    }
    if ($null -ne $ProjectMap -and $ProjectMap.Count -gt 0) {
        $k = ConvertTo-JaDirKey $dir0
        $level = 0
        while ($k) {
            if ($ProjectMap.Contains($k)) { [void]$all.Add([pscustomobject]@{ Name = [string]$ProjectMap[$k]; Level = $level; Rank = 2; Source = 'config.ini [projects]'; Where = $k }) }
            $parent = [IO.Path]::GetDirectoryName($k)
            if (-not $parent -or $parent -eq $k) { break }
            $k = $parent.TrimEnd('\')
            if ($k -match '^[a-z]:$') { $k += '\' }
            $level++
        }
    }
    foreach ($pf in (Find-JaProjectFiles $FullPath)) {
        [void]$all.Add([pscustomobject]@{ Name = $pf.Name; Level = $pf.Level; Rank = 3; Source = '.dpr/.dpk'; Where = $pf.Path })
    }
    $out = New-Object System.Collections.ArrayList
    foreach ($c in @($all | Sort-Object Level, Rank)) {
        if (-not ($out | Where-Object { $_.Name -eq $c.Name })) { [void]$out.Add($c) }
    }
    return , $out
}

# Para o hook e o edit-preserve: o arquivo pertence a algum projeto (.dpr/.dpk, .jvcsproject ou mapa)?
# Marcador inválido conta como "sim": o wrapper (ensure-checkout) explica o erro.
function Test-JaProjectContext {
    param([string]$FullPath, $ConfigInfo = $null)
    if ((Find-JaProjectFiles $FullPath).Count -gt 0) { return $true }
    $dir = [IO.Path]::GetDirectoryName($FullPath)
    try { if ((Find-JaProjectMarkers $dir).Count -gt 0) { return $true } } catch { return $true }
    if ($null -eq $ConfigInfo) { $ConfigInfo = Read-JaConfig }
    return ($null -ne (Find-JaMapEntry -Map $ConfigInfo.ProjectMap -Dir $dir))
}

# ---------------------------------------------------------------- contexto de agente

# Contexto de agente: -Agent, CLAUDECODE=1, AI_AGENT, ou entrada padrão redirecionada.
# A última cobre o agente que apagou as variáveis (R-24): as ferramentas de shell do Claude Code
# rodam com stdin redirecionado; um humano no terminal, não. Script de humano com stdin
# redirecionado também é tratado como agente (prefixo [IA], modos e -Confirmed valem).
function Test-JaAgentContext {
    param([bool]$Forced = $false)
    if ($Forced) { return $true }
    if ($env:CLAUDECODE -eq '1') { return $true }
    if (-not [string]::IsNullOrEmpty($env:AI_AGENT)) { return $true }
    try { if ([Console]::IsInputRedirected) { return $true } } catch { }
    return $false
}

# Exige aprovação humana explícita em contexto de agente: o switch -Confirmed E o texto
# "-Confirmed" (exatamente assim, C maiúsculo) na linha de comando. O texto é o que aciona a
# regra "ask" PowerShell(*-Confirmed*)/Bash(*-Confirmed*) do settings; as regras Bash
# diferenciam maiúsculas, por isso a checagem é sensível a maiúsculas.
function Assert-JaHumanApproval {
    param([bool]$IsAgent, [bool]$ConfirmedSwitch, [string]$InvocationLine, [string]$Why, [string]$CommandHint)
    if (-not $IsAgent) { return $false }
    if (-not $ConfirmedSwitch) {
        $msg = "$Why exige aprovação humana: repita o mesmo comando acrescentando -Confirmed (exatamente assim); o Claude Code pedirá a confirmação ao usuário."
        if ($CommandHint) { $msg += " Comando: $CommandHint -Confirmed" }
        throw (New-JaError 10 $msg)
    }
    $line = [Environment]::CommandLine + ' ' + [string]$InvocationLine
    if ($line -cnotmatch '-Confirmed\b') {
        throw (New-JaError 10 'escreva -Confirmed exatamente assim, por extenso e com C maiúsculo (abreviação, outra capitalização ou splatting não acionam a regra de aprovação do Claude Code)')
    }
    return $true
}

# Linha de comando canônica de um script de tools\ai (barras normais: é a forma que as regras
# "allow" do settings reconhecem).
function Get-JaCanonicalCommand {
    param([string]$Script)
    $p = (Join-Path $script:JaToolsDir $Script) -replace '\\', '/'
    return "powershell -NoProfile -ExecutionPolicy Bypass -File `"$p`""
}

# ---------------------------------------------------------------- checkouts da sessão (hook Stop)

# Registra (por sessão do Claude Code) os arquivos que a IA tirou em checkout, para o hook Stop
# lembrar dos que ficaram presos sem alteração (edição negada/cancelada depois do checkout).
function Get-JaSessionMarkerPath {
    param([string]$SessionId)
    if (-not $SessionId) { $SessionId = $env:CLAUDE_CODE_SESSION_ID }
    if (-not $SessionId) { $SessionId = 'sem-sessao' }
    $safe = $SessionId -replace '[^A-Za-z0-9_-]', '_'
    if ($safe.Length -gt 80) { $safe = $safe.Substring(0, 80) }
    $d = Join-Path (Get-JaLocalDir) 'sessoes'
    if (-not (Test-Path -LiteralPath $d)) { [void](New-Item -ItemType Directory -Path $d -Force) }
    return (Join-Path $d ($safe + '.txt'))
}

function Add-JaSessionCheckout {
    param([string]$Path)
    try {
        $m = Get-JaSessionMarkerPath
        $cur = @()
        if (Test-Path -LiteralPath $m) { $cur = @([IO.File]::ReadAllLines($m, $script:JaUtf8NoBom)) }
        if ($cur -notcontains $Path) { [IO.File]::AppendAllText($m, $Path + "`r`n", $script:JaUtf8NoBom) }
    } catch { }
}

# ---------------------------------------------------------------- configuração (config.ini)

function Get-JaDataDir {
    $d = Join-Path $env:APPDATA 'JEDI\JVCS'
    return $d
}

function Get-JaLocalDir {
    $d = Join-Path $env:LOCALAPPDATA 'JEDI\JVCS'
    if (-not (Test-Path -LiteralPath $d)) { [void](New-Item -ItemType Directory -Path $d -Force) }
    return $d
}

function Get-JaConfigPath {
    return (Join-Path (Get-JaDataDir) 'config.ini')
}

function Read-JaIniSection {
    param([string]$Path, [string]$Section)
    $values = [ordered]@{}
    if (-not (Test-Path -LiteralPath $Path)) { return $values }
    $lines = [IO.File]::ReadAllLines($Path, $script:JaUtf8NoBom)
    $inSec = $false
    foreach ($raw in $lines) {
        $line = $raw.Trim()
        if ($line.Length -gt 0 -and $line[0] -eq [char]0xFEFF) { $line = $line.Substring(1).Trim() }
        if ($line -eq '' -or $line.StartsWith(';') -or $line.StartsWith('#')) { continue }
        if ($line -match '^\[(.+)\]$') { $inSec = ($Matches[1].Trim() -ieq $Section); continue }
        if ($inSec -and $line -match '^([^=]+?)\s*=\s*(.*)$') { $values[$Matches[1].Trim().ToLowerInvariant()] = $Matches[2].Trim() }
    }
    return $values
}

# Configuração efetiva: padrões + [ai] do config.ini. Chaves desconhecidas são ignoradas.
function Read-JaConfig {
    $path = Get-JaConfigPath
    $file = Read-JaIniSection -Path $path -Section 'ai'
    $cfg = [ordered]@{}
    $src = [ordered]@{}
    foreach ($k in $script:JaConfigDefaults.Keys) {
        $lk = $k.ToLowerInvariant()
        if ($file.Contains($lk)) { $cfg[$k] = $file[$lk]; $src[$k] = 'config.ini' }
        else { $cfg[$k] = $script:JaConfigDefaults[$k]; $src[$k] = 'padrão' }
    }
    foreach ($k in @('checkout', 'checkin')) {
        $v = ([string]$cfg[$k]).ToLowerInvariant()
        if (@('auto', 'confirm', 'manual') -notcontains $v) { $v = 'confirm'; $src[$k] = 'padrão (valor inválido no config.ini)' }
        $cfg[$k] = $v
    }
    $cfg['asciiAs'] = ([string]$cfg['asciiAs']).ToLowerInvariant()
    if (@('ansi', 'utf8') -notcontains $cfg['asciiAs']) { $cfg['asciiAs'] = 'ansi' }
    # rm-project/restore-project/rename-project: desligados salvo projectAdmin=on (só o usuário liga)
    $cfg['projectAdmin'] = ([string]$cfg['projectAdmin']).ToLowerInvariant()
    if (@('on', 'off') -notcontains $cfg['projectAdmin']) { $cfg['projectAdmin'] = 'off'; $src['projectAdmin'] = 'padrão (valor inválido no config.ini)' }
    # administração de módulos (rm-module/rename-module/hide/comment/cleanup): off | on | archive
    $ma = ([string]$cfg['moduleAdmin']).ToLowerInvariant()
    if (@('off', 'on', 'archive') -notcontains $ma) { $ma = 'off'; $src['moduleAdmin'] = 'padrão (valor inválido no config.ini)' }
    $cfg['moduleAdmin'] = $ma
    foreach ($k in @('timeoutSec', 'lockWaitSec')) {
        $n = 0
        if (-not [int]::TryParse([string]$cfg[$k], [ref]$n) -or $n -lt 5 -or $n -gt 3600) { $n = [int]$script:JaConfigDefaults[$k] }
        $cfg[$k] = $n
    }
    $bc = ([string]$cfg['buildCheck']).ToLowerInvariant()
    if (@('off', 'warn', 'block') -notcontains $bc) { $bc = 'off'; $src['buildCheck'] = 'padrão (valor inválido no config.ini)' }
    $cfg['buildCheck'] = $bc
    foreach ($spec in @(@('blameMaxRevisions', 1, 5000), @('cacheMaxMB', 10, 100000), @('buildTimeoutSec', 30, 7200))) {
        $n = 0
        if (-not [int]::TryParse([string]$cfg[$spec[0]], [ref]$n) -or $n -lt $spec[1] -or $n -gt $spec[2]) { $n = [int]$script:JaConfigDefaults[$spec[0]] }
        $cfg[$spec[0]] = $n
    }
    $maps = Read-JaConfigMaps -Path $path
    return [pscustomobject]@{ Values = $cfg; Sources = $src; Path = $path; ProjectMap = $maps.ProjectMap; IdentityMap = $maps.IdentityMap; MapWarnings = $maps.MapWarnings }
}

# Mapas por pasta (R4): [projects] pasta=projeto e [identities] pasta=identidade. Só o usuário grava
# (config set projectMap/identityMap é recusado à IA; o settings nega editar o config.ini).
function Read-JaConfigMaps {
    param([string]$Path)
    $pm = [ordered]@{}; $im = [ordered]@{}
    $mw = New-Object System.Collections.ArrayList
    foreach ($spec in @(@('projects', $pm), @('identities', $im))) {
        $sec = Read-JaIniSection -Path $Path -Section $spec[0]
        foreach ($k in @($sec.Keys)) {
            $dk = ConvertTo-JaDirKey $k
            $v = ([string]$sec[$k]).Trim()
            $why = ''
            if (-not $dk) { $why = 'pasta inválida (use o caminho absoluto)' }
            elseif ($spec[0] -eq 'projects') { $why = Test-JaProjectNameText $v }
            else { $why = Test-JaIdentityNameText $v }
            if ($why) { [void]$mw.Add("config.ini [$($spec[0])] ${k}: $why; entrada ignorada"); continue }
            if ($spec[0] -eq 'projects') { $v = $v.ToLowerInvariant() }
            $spec[1][$dk] = $v
        }
    }
    return [pscustomobject]@{ ProjectMap = $pm; IdentityMap = $im; MapWarnings = $mw }
}

function Get-JaConfigKeyName {
    param([string]$Key)
    foreach ($k in $script:JaConfigDefaults.Keys) { if ($k -ieq $Key) { return $k } }
    return $null
}

function Test-JaConfigValue {
    param([string]$Key, [string]$Value)
    switch ($Key) {
        'checkout' { if (@('auto', 'confirm', 'manual') -notcontains $Value.ToLowerInvariant()) { return 'use auto, confirm ou manual' } }
        'checkin' { if (@('auto', 'confirm', 'manual') -notcontains $Value.ToLowerInvariant()) { return 'use auto, confirm ou manual' } }
        'asciiAs' { if (@('ansi', 'utf8') -notcontains $Value.ToLowerInvariant()) { return 'use ansi ou utf8' } }
        'projectAdmin' { if (@('on', 'off') -notcontains $Value.ToLowerInvariant()) { return 'use on ou off' } }
        'moduleAdmin' { if (@('off', 'on', 'archive') -notcontains $Value.ToLowerInvariant()) { return 'use off, on ou archive' } }
        'timeoutSec' { $n = 0; if (-not [int]::TryParse($Value, [ref]$n) -or $n -lt 5 -or $n -gt 3600) { return 'inteiro entre 5 e 3600' } }
        'lockWaitSec' { $n = 0; if (-not [int]::TryParse($Value, [ref]$n) -or $n -lt 5 -or $n -gt 3600) { return 'inteiro entre 5 e 3600' } }
        'commentPrefix' { if ($Value.Length -gt 20 -or $Value -match '["\x00-\x1f]' -or -not (Test-JaAnsiText $Value)) { return 'até 20 caracteres, sem aspas e representável em CP1252' } }
        'jvcsExe' { if ([string]::IsNullOrWhiteSpace($Value)) { return 'caminho do jvcs.exe obrigatório' } }
        'identity' { if ($Value -match '[\\/"]') { return 'nome de identidade inválido' } }
        'buildCheck' { if (@('off', 'warn', 'block') -notcontains $Value.ToLowerInvariant()) { return 'use off, warn ou block' } }
        'buildCommand' {
            # só um script do usuário (nunca um comando vindo do servidor); "none" desliga
            if ($Value -ine 'none') {
                if (-not [IO.Path]::IsPathRooted($Value) -or -not (Test-Path -LiteralPath $Value -PathType Leaf) -or
                    @('.bat', '.cmd', '.ps1') -notcontains [IO.Path]::GetExtension($Value).ToLowerInvariant()) {
                    return 'none ou o caminho absoluto de um .bat/.cmd/.ps1 existente'
                }
                if ($Value -match '[%&^|<>"!\x00-\x1f]') { return 'caminho com caractere especial para o cmd.exe (% & ^ | < > " !)' }
            }
        }
        'buildConfig' { if ($Value -notmatch '^[A-Za-z0-9_]{1,30}$') { return 'nome da configuração (ex.: Debug, Release)' } }
        'buildPlatform' { if (@('Win32', 'Win64') -notcontains $Value) { return 'use Win32 ou Win64' } }
        'buildTimeoutSec' { $n = 0; if (-not [int]::TryParse($Value, [ref]$n) -or $n -lt 30 -or $n -gt 7200) { return 'inteiro entre 30 e 7200' } }
        'blameMaxRevisions' { $n = 0; if (-not [int]::TryParse($Value, [ref]$n) -or $n -lt 1 -or $n -gt 5000) { return 'inteiro entre 1 e 5000' } }
        'cacheMaxMB' { $n = 0; if (-not [int]::TryParse($Value, [ref]$n) -or $n -lt 10 -or $n -gt 100000) { return 'inteiro entre 10 e 100000' } }
        'buildCommandSha256' { return 'gravado automaticamente por config set buildCommand' }
    }
    return ''
}

# Grava/atualiza uma chave da seção [ai] preservando o resto do arquivo.
# Arquivo em UTF-8 com BOM e CRLF; a primeira linha é comentário (assim o BOM não
# atrapalha leitores ANSI como GetPrivateProfileString).
function Set-JaConfigValue {
    param([string]$Key, [string]$Value, [switch]$Internal)
    $name = Get-JaConfigKeyName $Key
    if (-not $name) { throw (New-JaError 2 "chave de configuração desconhecida: '$Key'. Válidas: $(@($script:JaConfigDefaults.Keys) -join ', ')") }
    # o valor vira uma linha "chave=valor": CR/LF acrescentaria outra chave (ex.: moduleAdmin=archive)
    if ([string]$Value -match '[\x00-\x1f\x7f]') { throw (New-JaError 2 "valor inválido para ${name}: sem quebra de linha nem caractere de controle") }
    if (-not $Internal) {
        $why = Test-JaConfigValue -Key $name -Value $Value
        if ($why) { throw (New-JaError 2 "valor inválido para ${name}: $why") }
    }
    if (@('checkout', 'checkin', 'asciiAs', 'projectAdmin', 'moduleAdmin', 'buildCheck') -contains $name) { $Value = $Value.ToLowerInvariant() }
    $path = Get-JaConfigPath
    $dir = Split-Path -Parent $path
    if (-not (Test-Path -LiteralPath $dir)) { [void](New-Item -ItemType Directory -Path $dir -Force) }
    $lines = New-Object System.Collections.Generic.List[string]
    if (Test-Path -LiteralPath $path) {
        foreach ($l in [IO.File]::ReadAllLines($path, $script:JaUtf8NoBom)) { $lines.Add($l.TrimStart([char]0xFEFF)) }
    } else {
        $lines.Add('; JEDI VCS - automação por IA (Claude Code). Sem segredos: a senha fica na identidade salva.')
        $lines.Add('; Edite pela interface (futura aba "IA / Automação" em VCS Properties) ou com: jvcs-ai.ps1 config set <chave> <valor>')
        $lines.Add('; checkout/checkin = auto | confirm | manual   (padrão: confirm)')
        $lines.Add('; moduleAdmin = off | on | archive   (padrão: off; rm-module/rename-module/hide/comment/cleanup)')
        $lines.Add('; projectAdmin = on | off   (padrão: off; rm-project/restore-project/rename-project)')
    }
    $secStart = -1; $secEnd = $lines.Count; $keyLine = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $t = $lines[$i].Trim()
        if ($t -match '^\[(.+)\]$') {
            if ($secStart -ge 0 -and $secEnd -eq $lines.Count) { $secEnd = $i }
            if ($Matches[1].Trim() -ieq 'ai') { $secStart = $i; $secEnd = $lines.Count }
            continue
        }
        if ($secStart -ge 0 -and $i -gt $secStart -and $i -lt $secEnd -and $t -match '^([^=;#]+?)\s*=') {
            if ($Matches[1].Trim() -ieq $name) { $keyLine = $i }
        }
    }
    $newLine = "$name=$Value"
    if ($keyLine -ge 0) { $lines[$keyLine] = $newLine }
    elseif ($secStart -ge 0) {
        $insertAt = $secEnd
        while ($insertAt -gt $secStart + 1 -and $lines[$insertAt - 1].Trim() -eq '') { $insertAt-- }
        $lines.Insert($insertAt, $newLine)
    } else {
        if ($lines.Count -gt 0 -and $lines[$lines.Count - 1].Trim() -ne '') { $lines.Add('') }
        $lines.Add('[ai]')
        $lines.Add($newLine)
    }
    $text = ($lines -join "`r`n") + "`r`n"
    $bytes = (New-Object Text.UTF8Encoding($true)).GetPreamble() + $script:JaUtf8NoBom.GetBytes($text)
    [IO.File]::WriteAllBytes($path, $bytes)
    return $name
}

# Grava (ou remove, com $Value vazio) "pasta=valor" na seção [projects]/[identities] do config.ini,
# preservando o resto (UTF-8 com BOM e CRLF, como Set-JaConfigValue). As chaves existentes são
# comparadas já normalizadas; todas as que apontam para a mesma pasta saem. Devolve quantas saíram.
function Set-JaConfigMapValue {
    param([ValidateSet('projects', 'identities')][string]$Section, [string]$DirKey, [string]$Value)
    if (-not $DirKey -or $DirKey -match '[=\x00-\x1f\x7f"]' -or $DirKey -match '^[;#\[]') { throw (New-JaError 2 'pasta inválida para o mapa do config.ini') }
    if ([string]$Value -match '[\x00-\x1f\x7f]') { throw (New-JaError 2 'valor do mapa com caractere de controle') }
    $path = Get-JaConfigPath
    $dir = Split-Path -Parent $path
    if (-not (Test-Path -LiteralPath $dir)) { [void](New-Item -ItemType Directory -Path $dir -Force) }
    $lines = New-Object System.Collections.Generic.List[string]
    if (Test-Path -LiteralPath $path) {
        foreach ($l in [IO.File]::ReadAllLines($path, $script:JaUtf8NoBom)) { $lines.Add($l.TrimStart([char]0xFEFF)) }
    } else {
        $lines.Add('; JEDI VCS - automação por IA (Claude Code). Sem segredos: a senha fica na identidade salva.')
    }
    # Mesma leitura do Read-JaIniSection: comentário só no INÍCIO da linha (pasta pode ter '#' ou ';',
    # ex.: D:\Projetos\C#) e a seção pode aparecer em mais de um bloco (todos contam; grava no 1º).
    $secStart = -1; $secEnd = -1; $inSec = $false
    $hits = New-Object System.Collections.Generic.List[int]
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $t = $lines[$i].Trim()
        if ($t -match '^\[(.+)\]$') {
            if ($inSec -and $secEnd -lt 0) { $secEnd = $i }
            $inSec = ($Matches[1].Trim() -ieq $Section)
            if ($inSec -and $secStart -lt 0) { $secStart = $i }
            continue
        }
        if (-not $inSec -or $t -eq '' -or $t.StartsWith(';') -or $t.StartsWith('#')) { continue }
        if ($t -match '^([^=]+?)\s*=' -and (ConvertTo-JaDirKey $Matches[1].Trim()) -eq $DirKey) { $hits.Add($i) }
    }
    if ($secStart -ge 0 -and $secEnd -lt 0) { $secEnd = $lines.Count }
    $before = @($hits | Where-Object { $_ -lt $secEnd }).Count
    for ($j = $hits.Count - 1; $j -ge 0; $j--) { $lines.RemoveAt($hits[$j]) }
    if ($secStart -ge 0) { $secEnd -= $before }
    if ($Value) {
        $newLine = "$DirKey=$Value"
        if ($secStart -ge 0) {
            $insertAt = $secEnd
            while ($insertAt -gt $secStart + 1 -and $lines[$insertAt - 1].Trim() -eq '') { $insertAt-- }
            $lines.Insert($insertAt, $newLine)
        } else {
            if ($lines.Count -gt 0 -and $lines[$lines.Count - 1].Trim() -ne '') { $lines.Add('') }
            $lines.Add("[$Section]")
            $lines.Add($newLine)
        }
    }
    $text = ($lines -join "`r`n") + "`r`n"
    $bytes = (New-Object Text.UTF8Encoding($true)).GetPreamble() + $script:JaUtf8NoBom.GetBytes($text)
    [IO.File]::WriteAllBytes($path, $bytes)
    return $hits.Count
}

# ---------------------------------------------------------------- auditoria

function Write-JaAudit {
    param($Entry)
    try {
        $path = Join-Path (Get-JaLocalDir) 'ai-audit.log'
        $line = (ConvertTo-JaJson $Entry -Ascii) + "`r`n"
        [IO.File]::AppendAllText($path, $line, $script:JaUtf8NoBom)
    } catch {
        # auditoria nunca derruba o comando; o aviso vai no stderr
        [Console]::Error.WriteLine('jvcs-ai: falha ao gravar auditoria: ' + $_.Exception.Message)
    }
}

# ---------------------------------------------------------------- arquivos

function Get-JaWritableFilter {
    # Mesma regra do console (JVCSClientFunctions.GetAlwaysWritableFileTypes): registro só leitura.
    try {
        $k = Get-Item -LiteralPath 'HKCU:\Software\JEDI\JEDIVCS' -ErrorAction Stop
        $base = [string]$k.GetValue('BaseRegistryKey')
        if ($base) {
            $p = 'HKCU:\' + $base + '\Mask'
            if (Test-Path -LiteralPath $p) {
                $v = [string](Get-Item -LiteralPath $p).GetValue('Writeable Files')
                if ($v) { return $v }
            }
        }
    } catch { }
    return $script:JaDefaultWritableFilter
}

function Test-JaAlwaysWritable {
    param([string]$FileName, [string]$Filter)
    foreach ($mask in ($Filter -split ';')) {
        $m = $mask.Trim()
        if ($m -and ($FileName -like $m)) { return $true }
    }
    return $false
}

# Caminhos que a IA não pode gravar pelo edit-preserve (o script não pode servir para contornar
# as regras deny do settings): tools\ai, dados do JEDI VCS (config.ini, auditoria, backups) e
# pastas .claude/.git. Devolve o motivo ('' = permitido).
function Get-JaProtectedPathReason {
    param([string]$FullPath)
    $p = [IO.Path]::GetFullPath($FullPath).TrimEnd('\') + '\'
    $roots = @(
        @{ Dir = $script:JaToolsDir; Why = 'pasta tools\ai (ferramentas da IA)' },
        @{ Dir = (Join-Path $env:APPDATA 'JEDI'); Why = 'dados do JEDI VCS em %APPDATA% (config.ini)' },
        @{ Dir = (Join-Path $env:LOCALAPPDATA 'JEDI'); Why = 'dados do JEDI VCS em %LOCALAPPDATA% (auditoria, backups)' }
    )
    foreach ($r in $roots) {
        if (-not $r.Dir) { continue }
        $d = [IO.Path]::GetFullPath($r.Dir).TrimEnd('\') + '\'
        if ($p.StartsWith($d, [StringComparison]::OrdinalIgnoreCase)) { return $r.Why }
    }
    if ($p -match '(?i)\\\.(claude|git)\\') { return 'pasta .claude ou .git' }
    return ''
}

function Set-JaReadOnly {
    param([string]$Path, [bool]$ReadOnly)
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        $fi = New-Object IO.FileInfo $Path
        if ($fi.IsReadOnly -ne $ReadOnly) { $fi.IsReadOnly = $ReadOnly }
    }
}

function New-JaTempDir {
    param([string]$Prefix = 'jvcs-ai')
    $root = Join-Path ([IO.Path]::GetTempPath()) 'jvcs-ai'
    if (-not (Test-Path -LiteralPath $root)) { [void](New-Item -ItemType Directory -Path $root -Force) }
    $d = Join-Path $root ($Prefix + '-' + [guid]::NewGuid().ToString('N'))
    [void](New-Item -ItemType Directory -Path $d -Force)
    return $d
}

function Remove-JaTempDir {
    param([string]$Path)
    if ($Path -and (Test-Path -LiteralPath $Path)) {
        Get-ChildItem -LiteralPath $Path -Recurse -File -Force -ErrorAction SilentlyContinue | ForEach-Object { try { $_.IsReadOnly = $false } catch { } }
        Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# ---------------------------------------------------------------- codificação para gravar
# Mesma regra do edit-preserve (Get-Encoder/Get-Preamble/ConvertTo-Bytes), aqui para o revert.
# Escritas estritas: caractere não representável vira erro com o código pedido (o revert usa 8).

function Get-JaTextEncoder {
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

function ConvertTo-JaTextBytes {
    param([string]$Text, [string]$Kind, [int]$ErrorCode = 6)
    $enc = Get-JaTextEncoder $Kind
    try { $body = $enc.GetBytes($Text) }
    catch {
        $bad = @()
        $lineNo = 1
        foreach ($ch in $Text.ToCharArray()) {
            if ($ch -eq "`n") { $lineNo++; continue }
            if (-not (Test-JaAnsiText ([string]$ch))) { $bad += ('U+{0:X4} (linha {1})' -f [int]$ch, $lineNo); if ($bad.Count -ge 5) { break } }
        }
        throw (New-JaError $ErrorCode ("caractere(s) não representável(is) na codificação do arquivo ($Kind): " + ($bad -join ', ')))
    }
    $pre = [byte[]]@()
    switch ($Kind) {
        'utf8bom' { $pre = [byte[]](0xEF, 0xBB, 0xBF) }
        'utf16le' { $pre = [byte[]](0xFF, 0xFE) }
        'utf16be' { $pre = [byte[]](0xFE, 0xFF) }
    }
    if ($pre.Length -eq 0) { return , $body }
    $all = New-Object byte[] ($pre.Length + $body.Length)
    [Array]::Copy($pre, 0, $all, 0, $pre.Length)
    [Array]::Copy($body, 0, $all, $pre.Length, $body.Length)
    return , $all
}
