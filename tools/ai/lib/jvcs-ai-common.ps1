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

$script:JaVersion = '1.1.0'

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
    foreach ($k in @('timeoutSec', 'lockWaitSec')) {
        $n = 0
        if (-not [int]::TryParse([string]$cfg[$k], [ref]$n) -or $n -lt 5 -or $n -gt 3600) { $n = [int]$script:JaConfigDefaults[$k] }
        $cfg[$k] = $n
    }
    return [pscustomobject]@{ Values = $cfg; Sources = $src; Path = $path }
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
        'timeoutSec' { $n = 0; if (-not [int]::TryParse($Value, [ref]$n) -or $n -lt 5 -or $n -gt 3600) { return 'inteiro entre 5 e 3600' } }
        'lockWaitSec' { $n = 0; if (-not [int]::TryParse($Value, [ref]$n) -or $n -lt 5 -or $n -gt 3600) { return 'inteiro entre 5 e 3600' } }
        'commentPrefix' { if ($Value.Length -gt 20 -or $Value -match '["\x00-\x1f]' -or -not (Test-JaAnsiText $Value)) { return 'até 20 caracteres, sem aspas e representável em CP1252' } }
        'jvcsExe' { if ([string]::IsNullOrWhiteSpace($Value)) { return 'caminho do jvcs.exe obrigatório' } }
        'identity' { if ($Value -match '[\\/"]') { return 'nome de identidade inválido' } }
    }
    return ''
}

# Grava/atualiza uma chave da seção [ai] preservando o resto do arquivo.
# Arquivo em UTF-8 com BOM e CRLF; a primeira linha é comentário (assim o BOM não
# atrapalha leitores ANSI como GetPrivateProfileString).
function Set-JaConfigValue {
    param([string]$Key, [string]$Value)
    $name = Get-JaConfigKeyName $Key
    if (-not $name) { throw (New-JaError 2 "chave de configuração desconhecida: '$Key'. Válidas: $(@($script:JaConfigDefaults.Keys) -join ', ')") }
    $why = Test-JaConfigValue -Key $name -Value $Value
    if ($why) { throw (New-JaError 2 "valor inválido para ${name}: $why") }
    if (@('checkout', 'checkin', 'asciiAs') -contains $name) { $Value = $Value.ToLowerInvariant() }
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
