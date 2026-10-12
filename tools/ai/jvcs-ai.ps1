<#
.SYNOPSIS
    jvcs-ai.ps1 - wrapper seguro do console JEDI VCS 2.5.0.1030 (jvcs.exe) para a IA
    (Claude Code) e para humanos. Ver LEIAME.md.

.DESCRIPTION
    Comandos:
      identity [-Test]                  identidade salva em uso (nunca a senha)
      projects                          projetos do servidor
      list [-Project p]                 módulos do projeto (versão, lock, estado pelo CRC do console)
      locks [-All]                      módulos em checkout (meus ou de todos)
      status <arquivo...> | -Project p  estado exato (bytes) contra a última revisão do servidor
      checkout <arquivo...> [-Force]    checkout seguro (nunca deixa lock órfão)
      ensure-checkout <arquivo> [-CheckOnly]   para hooks: idempotente
      checkin <arquivo...> -Comment "texto"    check-in (sem mudança -> undocheckout)
      undocheckout <arquivo> [-Discard] desfaz checkout (só com local = base, ou -Discard)
      config list | get <chave> | set <chave> <valor>

    Opções comuns: -Project <nome.dpr>, -Identity <nome>, -Text (saída legível),
    -Agent (força contexto de agente), -Confirmed (aprovação humana já dada; em agente,
    escreva exatamente -Confirmed), -TimeoutSec <n> (por execução do jvcs.exe),
    -LockWaitSec <n> (espera pelo mutex), -Raw (inclui a saída bruta do console).

    Saída padrão: JSON numa linha {ok, command, project, modules:[...], message, exitCode}.
    Códigos de saída: 0 ok | 2 uso | 3 nada a fazer | 4 credencial | 5 não encontrado |
    6 travado por outro | 7 pré-condição | 8 conflito local | 9 servidor/console |
    10 confirmação necessária/recusada | 11 parcial | 12 ambiente.

    Este arquivo é UTF-8 COM BOM e CRLF (Windows PowerShell 5.1).
#>
[CmdletBinding(PositionalBinding = $false)]
param(
    [Parameter(Position = 0)][string]$Command = 'help',
    [Parameter(Position = 1, ValueFromRemainingArguments = $true)][string[]]$Rest = @(),
    [string]$Project = '',
    [string]$Comment = '',
    [string]$Identity = '',
    [switch]$Force,
    [switch]$Discard,
    [switch]$Confirmed,
    [switch]$Agent,
    [switch]$Text,
    [switch]$All,
    [switch]$AllowEncodingChange,
    [switch]$CheckOnly,
    [switch]$Test,
    [switch]$Raw,
    [int]$TimeoutSec = 0,
    [int]$LockWaitSec = 0
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib\jvcs-ai-common.ps1')

$script:WrapperPath = $MyInvocation.MyCommand.Path
$script:Cmd = $Command.ToLowerInvariant()
$script:Res = [ordered]@{
    ok       = $false
    command  = $script:Cmd
    project  = $null
    modules  = (New-Object System.Collections.ArrayList)
    message  = ''
    exitCode = 0
}
$script:Warnings = New-Object System.Collections.ArrayList
$script:RawOut = New-Object System.Collections.ArrayList
$script:IsAgent = Test-JaAgentContext -Forced $Agent.IsPresent
$script:Cfg = $null
$script:CfgInfo = $null
$script:Ident = $null
$script:Mutex = $null
$script:ConfirmedUsed = $false

# ======================================================================= utilidades

function Add-JaWarning { param([string]$Message) [void]$script:Warnings.Add($Message) }

function Get-FileArgs {
    param([int]$Min = 1, [int]$Max = 1000)
    $files = @($Rest | Where-Object { $_ -ne $null -and $_.Trim() -ne '' })
    if ($files.Count -lt $Min) { throw (New-JaError 2 "informe o(s) arquivo(s): jvcs-ai.ps1 $script:Cmd <arquivo>") }
    if ($files.Count -gt $Max) { throw (New-JaError 2 "o comando $script:Cmd aceita no máximo $Max arquivo(s)") }
    $out = New-Object System.Collections.ArrayList
    foreach ($f in $files) { [void]$out.Add([IO.Path]::GetFullPath($f)) }
    return , $out
}

function Get-ProjectNameFromArg {
    param([string]$Value)
    if (-not $Value) { return '' }
    # nada de CR/LF/controle nem aspas: o nome vai entre aspas numa linha do /input, e o
    # TStringList do console quebra linha em CR ou LF (injeção de comandos)
    if ($Value -match '[\x00-\x1f\x7f"]') { throw (New-JaError 2 'nome/caminho de projeto com caractere de controle ou aspas: recusado') }
    $leaf = $Value
    if ($Value -match '[\\/]') { $leaf = [IO.Path]::GetFileName($Value) }
    $leaf = $leaf.Trim().ToLowerInvariant()
    if (-not $leaf -or $leaf -match '[<>|*?:]') { throw (New-JaError 2 "nome de projeto inválido: '$leaf'") }
    return $leaf
}

function Assert-AnsiArg {
    param([string]$Value, [string]$What)
    if (-not (Test-JaAnsiText $Value)) {
        throw (New-JaError 2 "$What contém caractere fora da code page 1252 ($(Get-JaFirstNonAnsiChar $Value)); o console jvcs.exe 2.5 só aceita ANSI")
    }
}

# ======================================================================= identidade

function Get-JaIdentity {
    param([string]$Name)
    $base = 'HKCU:\Software\JEDI\JEDIVCS\Identities'
    if (-not (Test-Path -LiteralPath $base)) {
        throw (New-JaError 4 'nenhuma identidade salva (HKCU\Software\JEDI\JEDIVCS\Identities). Conecte uma vez pela GUI/IDE com "Store Password with identity".')
    }
    $root = Get-Item -LiteralPath $base
    $source = 'parâmetro -Identity'
    if (-not $Name) { $Name = [string]$script:Cfg.identity; $source = 'config.ini (identity)' }
    if ($Name -and ($Name -match '[\\/"\x00-\x1f]' -or $Name -eq '.' -or $Name -eq '..')) { throw (New-JaError 2 "nome de identidade inválido: '$Name'") }
    if (-not $Name) {
        $idx = $root.GetValue('LastUsedID')
        if ($null -eq $idx) { $idx = 0 }
        $Name = [string]$root.GetValue('ID' + $idx)
        $source = "LastUsedID=$idx"
    }
    if (-not $Name) { throw (New-JaError 4 'identidade não encontrada (LastUsedID sem ID correspondente)') }
    $subPath = Join-Path $base $Name
    if (-not (Test-Path -LiteralPath $subPath)) { throw (New-JaError 4 "identidade '$Name' não existe em Identities") }
    $sub = Get-Item -LiteralPath $subPath
    $h = [string]$sub.GetValue('HostName'); $p = [string]$sub.GetValue('Port'); $u = [string]$sub.GetValue('User')
    if (-not $p) { $p = '2106' }
    if (-not $h -or -not $u) { throw (New-JaError 4 "identidade '$Name' incompleta (HostName/User)") }
    $hasPw = -not [string]::IsNullOrEmpty([string]$sub.GetValue('Password'))
    return [pscustomobject]@{ Name = $Name; Host = $h; Port = $p; User = $u; HasPassword = $hasPw; Source = $source; RegPath = $subPath }
}

function Get-JaIdentityCached {
    if ($null -eq $script:Ident) { $script:Ident = Get-JaIdentity -Name $Identity }
    return $script:Ident
}

# Senha: só bytes (Base64 dos bytes ANSI, como grava o Create.pas). Nunca vira texto.
function Get-JaPasswordBytes {
    param($Id)
    $v = [string](Get-Item -LiteralPath $Id.RegPath).GetValue('Password')
    if (-not $v) { throw (New-JaError 4 "a identidade '$($Id.Name)' não tem senha salva; marque 'Store Password with identity' na GUI") }
    try { return , ([Convert]::FromBase64String($v)) } catch { throw (New-JaError 4 "senha salva da identidade '$($Id.Name)' está corrompida (Base64 inválido)") }
}

# ======================================================================= exclusão mútua

function Enter-JaLock {
    if ($null -ne $script:Mutex) { return }
    $id = Get-JaIdentityCached
    $key = ($id.Name + '.' + $id.User + '@' + $id.Host + '_' + $id.Port) -replace '[^A-Za-z0-9._@-]', '_'
    $name = 'Local\JEDI.JVCS.AI.' + $key
    $m = New-Object System.Threading.Mutex($false, $name)
    $ok = $false
    $wait = [int]$script:Cfg.lockWaitSec
    if ($LockWaitSec -gt 0) { $wait = $LockWaitSec }
    try { $ok = $m.WaitOne([TimeSpan]::FromSeconds($wait)) }
    catch [System.Threading.AbandonedMutexException] { $ok = $true; Add-JaWarning 'a chamada anterior terminou sem liberar o mutex (abandonado); seguindo' }
    if (-not $ok) {
        $m.Dispose()
        throw (New-JaError 12 "outra chamada do jvcs-ai com a identidade '$($id.Name)' está em andamento há mais de $wait s (mutex $name)")
    }
    $script:Mutex = $m
}

function Exit-JaLock {
    if ($null -ne $script:Mutex) {
        try { $script:Mutex.ReleaseMutex() } catch { }
        $script:Mutex.Dispose()
        $script:Mutex = $null
    }
}

# ======================================================================= execução do jvcs.exe

# Roda o jvcs.exe com um arquivo /input (comandos SEMPRE em minúsculas) e devolve as seções
# da saída, uma por linha de comando (o console ecoa "jvcs> <linha>" antes de cada uma).
function Invoke-Jvcs {
    param([string[]]$Lines)
    $id = Get-JaIdentityCached
    if (-not $id.HasPassword) { throw (New-JaError 4 "a identidade '$($id.Name)' não tem senha salva") }
    $exe = [string]$script:Cfg.jvcsExe
    if (-not (Test-Path -LiteralPath $exe -PathType Leaf)) { throw (New-JaError 12 "jvcs.exe não encontrado: $exe (ajuste: jvcs-ai.ps1 config set jvcsExe <caminho>)") }
    # a senha vai para o stdin deste executável: aceita só o console do JEDI VCS
    $vi = (Get-Item -LiteralPath $exe).VersionInfo
    if ([IO.Path]::GetExtension($exe) -ine '.exe' -or [string]$vi.OriginalFilename -ine 'jvcs.exe' -or [string]$vi.ProductName -notmatch 'JEDI') {
        throw (New-JaError 12 "o jvcsExe configurado ($exe) não se identifica como o console do JEDI VCS (OriginalFilename=jvcs.exe, ProductName JEDI...); a senha não será enviada")
    }
    foreach ($l in $Lines) {
        # o TStringList.LoadFromFile do console quebra linha em CR ou LF e para no #0: qualquer
        # caractere de controle numa linha viraria comando extra (injeção) - recusa sempre
        if ($l -match '[\x00-\x1f\x7f]') { throw (New-JaError 2 'linha do /input com caractere de controle (CR/LF/TAB/NUL) recusada') }
        Assert-AnsiArg $l 'comando'
        if ($l -match '^\s*exit\b') { throw (New-JaError 2 'linha exit não é permitida no /input') }
    }
    $timeout = [int]$script:Cfg.timeoutSec
    if ($TimeoutSec -gt 0) { $timeout = $TimeoutSec }

    $tmpDir = Join-Path ([IO.Path]::GetTempPath()) 'jvcs-ai'
    if (-not (Test-Path -LiteralPath $tmpDir)) { [void](New-Item -ItemType Directory -Path $tmpDir -Force) }
    $inFile = Join-Path $tmpDir ('in-' + [guid]::NewGuid().ToString('N') + '.txt')
    Assert-AnsiArg $inFile 'caminho temporário'

    $userArg = $id.User
    if ($userArg -match '"') { throw (New-JaError 12 'nome de usuário com aspas não é suportado pelo console') }
    if ($userArg -match '\s') { $userArg = '"' + $userArg + '"' }
    $arguments = ('{0}:{1} /user {2} /input "{3}"' -f $id.Host, $id.Port, $userArg, $inFile)
    # O console procura o nome do comando com StrPos (sensível a maiúsculas) na linha de comando
    # inteira (jvcs.dpr:623): nada antes de "/input" pode conter "input".
    $prefix = '"' + $exe + '" ' + ('{0}:{1} /user {2}' -f $id.Host, $id.Port, $userArg)
    if ($prefix.Contains('input')) { throw (New-JaError 12 "o caminho do jvcs.exe, o servidor ou o usuário contém 'input'; o console 2.5 confundiria com o comando /input") }

    [IO.File]::WriteAllText($inFile, (($Lines -join "`r`n") + "`r`n"), $script:JaEnc1252)

    $psi = New-Object Diagnostics.ProcessStartInfo $exe
    $psi.Arguments = $arguments
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.RedirectStandardInput = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.StandardOutputEncoding = $script:JaEnc1252
    $psi.StandardErrorEncoding = $script:JaEnc1252
    $psi.WorkingDirectory = $tmpDir

    # O .NET Framework grava o preâmbulo (BOM) do Console.InputEncoding no stdin do filho
    # assim que cria o StandardInput; com UTF-8 a senha chegaria como EF BB BF + senha.
    $oldIn = $null
    try {
        $cur = [Console]::InputEncoding
        if ($cur.GetPreamble().Length -gt 0) { $oldIn = $cur; [Console]::InputEncoding = $script:JaEnc1252 }
    } catch {
        throw (New-JaError 12 ('não foi possível ajustar a codificação da entrada padrão (o BOM iria junto com a senha): ' + $_.Exception.Message))
    }
    $p = $null
    try {
        try { $p = [Diagnostics.Process]::Start($psi) }
        finally { if ($null -ne $oldIn) { try { [Console]::InputEncoding = $oldIn } catch { } } }
        if ($null -ne $oldIn -and $p.StandardInput.Encoding.GetPreamble().Length -gt 0) {
            try { $p.Kill() } catch { }
            throw (New-JaError 12 'o stdin do jvcs.exe ficou com BOM; abortado para não enviar senha errada')
        }
        $oTask = $p.StandardOutput.ReadToEndAsync()
        $eTask = $p.StandardError.ReadToEndAsync()
        $pw = Get-JaPasswordBytes $id
        try {
            $s = $p.StandardInput.BaseStream
            $s.Write($pw, 0, $pw.Length)
            $s.Write([byte[]](13, 10), 0, 2)
            $s.Flush()
        } catch {
            # processo pode ter terminado antes (ex.: FVCSCrypt.dll ausente); a saída explica
        } finally {
            [Array]::Clear($pw, 0, $pw.Length)
            try { $p.StandardInput.Close() } catch { }
        }
        if (-not $p.WaitForExit($timeout * 1000)) {
            try { $p.Kill() } catch { }
            [void]$p.WaitForExit(5000)
            $te = New-JaError 9 "jvcs.exe não terminou em $timeout s (rede ou sessão interativa em laço); processo encerrado"
            $te.Data['jaTimeout'] = $true
            throw $te
        }
        $p.WaitForExit()
        $out = $oTask.Result
        $err = $eTask.Result
        $code = $p.ExitCode
    } finally {
        if ($null -ne $p) { $p.Dispose() }
        Remove-Item -LiteralPath $inFile -Force -ErrorAction SilentlyContinue
    }
    if ($Raw) { [void]$script:RawOut.Add($out) }
    return (ConvertFrom-JvcsOutput -Out $out -Err $err -ExitCode $code -Lines $Lines)
}

function ConvertFrom-JvcsOutput {
    param([string]$Out, [string]$Err, [int]$ExitCode, [string[]]$Lines)
    # StrAlign (jvcs.dpr:3611) usa StrLCopy, que grava #0 logo depois do texto de cada coluna:
    # troca por espaço para manter as posições fixas das colunas.
    $Out = $Out.Replace([string][char]0, ' ')
    $all = $Out -split "`r?`n"
    $sections = New-Object System.Collections.ArrayList
    $cur = $null
    foreach ($ln in $all) {
        if ($ln.StartsWith('jvcs> ')) {
            $cur = [pscustomobject]@{ Cmd = $ln.Substring(6); Lines = (New-Object System.Collections.ArrayList); Errors = (New-Object System.Collections.ArrayList); Usage = $false }
            [void]$sections.Add($cur)
            continue
        }
        if ($null -ne $cur) { [void]$cur.Lines.Add($ln) }
    }
    if ($sections.Count -eq 0) {
        # sem nenhum "jvcs> ": o login (ou a carga do console) falhou antes do /input
        $m = [regex]::Match($Out, '(?m)^\[(\w+)\] (.+)$')
        $msg = ''
        if ($m.Success) { $msg = $m.Groups[2].Value.Trim() } elseif ($Err) { $msg = $Err.Trim() } else { $msg = "saída inesperada (código $ExitCode)" }
        if ($msg -match 'Access denied|Invalid Password|Unknown user|not allowed|denied|password') {
            throw (New-JaError 4 "login recusado pelo servidor: $msg")
        }
        if ($msg -match 'Required library') { throw (New-JaError 12 "jvcs.exe: $msg") }
        throw (New-JaError 9 "falha ao conectar no servidor JEDI VCS: $msg")
    }
    foreach ($s in $sections) {
        $lns = $s.Lines
        for ($i = 0; $i -lt $lns.Count; $i++) {
            $mm = [regex]::Match($lns[$i], '^\[([A-Za-z_]\w*)\] (.*)$')
            if ($mm.Success) {
                $text = $mm.Groups[2].Value.Trim()
                $j = $i + 1
                while ($j -lt $lns.Count -and $lns[$j].Trim() -ne '' -and -not $lns[$j].StartsWith('[')) { $text += ' ' + $lns[$j].Trim(); $j++ }
                [void]$s.Errors.Add([pscustomobject]@{ Class = $mm.Groups[1].Value; Message = $text })
            }
        }
        $word = ($s.Cmd -split '\s+')[0]
        foreach ($l in $lns) { if ($l -match ('^' + [regex]::Escape($word) + ' [<\[]')) { $s.Usage = $true } }
    }
    if ($sections.Count -ne $Lines.Count) {
        throw (New-JaError 9 "saída inesperada do console: $($sections.Count) seções para $($Lines.Count) comandos")
    }
    return [pscustomobject]@{ ExitCode = $ExitCode; Out = $Out; Err = $Err; Sections = $sections }
}

function Get-SectionError {
    param($Section)
    if ($Section.Errors.Count -gt 0) { return (($Section.Errors | ForEach-Object { '[' + $_.Class + '] ' + $_.Message }) -join ' | ') }
    if ($Section.Usage) { return "sintaxe recusada pelo console para '$($Section.Cmd)'" }
    return ''
}

# ======================================================================= parsers das tabelas

function Get-Col {
    param([string]$Line, [int]$Start, [int]$Width)
    if ($Line.Length -le $Start) { return '' }
    $w = [Math]::Min($Width, $Line.Length - $Start)
    return $Line.Substring($Start, $w).Trim()
}

function Test-DataRow { param([string]$Line) return ($Line.Length -ge 9 -and $Line.Substring(0, 8).Trim() -match '^\d+$') }

# listproject: ID(8) Path(50) Name(30) Version(7) Out(3) Owner(20) Hid(3) Stamp(5) CRC(5)
function ConvertFrom-ListProject {
    param($Section)
    $rows = New-Object System.Collections.ArrayList
    foreach ($l in $Section.Lines) {
        if (-not (Test-DataRow $l)) { continue }
        [void]$rows.Add([pscustomobject]@{
                Id      = [int](Get-Col $l 0 8)
                Dir     = (Get-Col $l 9 50)
                File    = (Get-Col $l 60 30)
                Version = (Get-Col $l 91 7)
                Out     = ((Get-Col $l 99 3) -eq '*')
                Owner   = (Get-Col $l 103 20)
                Hidden  = ((Get-Col $l 124 3) -eq '*')
                Stamp   = (Get-Col $l 128 5)
                Crc     = (Get-Col $l 134 5)
            })
    }
    return , $rows
}

# listlocks: ID(8) Path(50) Name(30) Version(7) Owner(20) Locked(25)
function ConvertFrom-ListLocks {
    param($Section)
    $rows = New-Object System.Collections.ArrayList
    foreach ($l in $Section.Lines) {
        if (-not (Test-DataRow $l)) { continue }
        [void]$rows.Add([pscustomobject]@{
                Id = [int](Get-Col $l 0 8); Dir = (Get-Col $l 9 50); File = (Get-Col $l 60 30)
                Version = (Get-Col $l 91 7); Owner = (Get-Col $l 99 20); Locked = (Get-Col $l 120 25)
            })
    }
    return , $rows
}

# listprojects: ID(8) Name(30) Created(25) Creator(20) Del(3) Description(50)
function ConvertFrom-ListProjects {
    param($Section)
    $rows = New-Object System.Collections.ArrayList
    foreach ($l in $Section.Lines) {
        if (-not (Test-DataRow $l)) { continue }
        [void]$rows.Add([pscustomobject]@{
                Id = [int](Get-Col $l 0 8); Name = (Get-Col $l 9 30); Created = (Get-Col $l 40 25)
                Creator = (Get-Col $l 66 20); Deleted = ((Get-Col $l 87 3) -ne ''); Description = (Get-Col $l 91 50)
            })
    }
    return , $rows
}

# Compara um texto da tabela (talvez cortado com "..." pelo StrAlign) com o valor real.
function Test-TableMatch {
    param([string]$Shown, [string]$Actual, [int]$Width)
    if ($Shown.Length -eq $Width -and $Shown.EndsWith('...')) {
        $vis = $Shown.Substring(0, $Width - 3)
        return ($Actual.Length -gt ($Width - 3) -and $Actual.StartsWith($vis, [StringComparison]::OrdinalIgnoreCase))
    }
    return ($Shown -ieq $Actual)
}

function Test-IsMe {
    param([string]$Owner)
    $u = (Get-JaIdentityCached).User
    return (Test-TableMatch -Shown $Owner -Actual $u -Width 20)
}

# Agrupa as linhas por ID de módulo.
function Get-ModuleGroups {
    param($Rows)
    $map = [ordered]@{}
    foreach ($r in $Rows) {
        $k = [string]$r.Id
        if (-not $map.Contains($k)) { $map[$k] = New-Object System.Collections.ArrayList }
        [void]$map[$k].Add($r)
    }
    return $map
}

function Get-ModuleDisplayName {
    param($Rows)
    foreach ($ext in @('.pas', '.dpr', '.dpk', '.cpp', '.inc', '.dproj')) {
        foreach ($r in $Rows) { if ($r.File.ToLowerInvariant().EndsWith($ext)) { return $r.File } }
    }
    return $Rows[0].File
}

function New-ModuleItem {
    param($Rows, $Path = $null)
    $first = $Rows[0]
    $owner = ''
    foreach ($r in $Rows) { if ($r.Out) { $owner = $r.Owner } }
    return [ordered]@{
        id         = $first.Id
        name       = (Get-ModuleDisplayName $Rows)
        path       = $Path
        version    = $first.Version
        lockedBy   = $owner
        localState = $null
        state      = $null
        exitCode   = 0
        message    = ''
        pathCheck  = (Get-PathCheckLabel $Rows)
    }
}

# 'exact' quando a tabela mostra o caminho inteiro; 'prefix' quando truncado (só o começo bate;
# checkout/checkin/undocheckout provam com Assert-ServerPath e trocam para 'verified').
function Get-PathCheckLabel {
    param($Rows)
    foreach ($r in $Rows) { if ($r.Dir.Length -eq 50 -and $r.Dir.EndsWith('...')) { return 'prefix' } }
    return 'exact'
}

# ======================================================================= resolução projeto/módulo

function Get-ProjectListing {
    param([string[]]$Names)
    $lines = @($Names | ForEach-Object { 'listproject "' + $_ + '"' })
    $r = Invoke-Jvcs $lines
    $out = [ordered]@{}
    for ($i = 0; $i -lt $Names.Count; $i++) {
        $sec = $r.Sections[$i]
        $err = Get-SectionError $sec
        if ($err) {
            if ($err -match 'Project .* not found|deleted') { $out[$Names[$i]] = $null; continue }
            throw (New-JaError 9 "listproject $($Names[$i]): $err")
        }
        $out[$Names[$i]] = ConvertFrom-ListProject $sec
    }
    return $out
}

# Resolve o projeto e o módulo de um arquivo local.
# Status: versioned | notVersioned | noProject
function Resolve-FileContext {
    param([string]$FullPath)
    $dirL = ([IO.Path]::GetDirectoryName($FullPath)).ToLowerInvariant().TrimEnd('\') + '\'
    $nameL = ([IO.Path]::GetFileName($FullPath)).ToLowerInvariant()
    Assert-AnsiArg $FullPath 'caminho do arquivo'
    $cands = New-Object System.Collections.ArrayList
    if ($Project) {
        [void]$cands.Add([pscustomobject]@{ Name = (Get-ProjectNameFromArg $Project); Level = 0 })
    } else {
        foreach ($pf in (Find-JaProjectFiles $FullPath)) {
            if (-not ($cands | Where-Object { $_.Name -eq $pf.Name })) { [void]$cands.Add([pscustomobject]@{ Name = $pf.Name; Level = $pf.Level }) }
        }
    }
    $ctx = [pscustomobject]@{ Status = 'noProject'; FullPath = $FullPath; Project = $null; Rows = $null; ModuleRows = $null; Candidates = @($cands | ForEach-Object Name); Note = '' }
    if ($cands.Count -eq 0) { $ctx.Note = 'nenhum .dpr/.dpk na pasta do arquivo ou acima (use -Project)'; return $ctx }
    $listing = Get-ProjectListing -Names @($cands | ForEach-Object Name)
    $found = New-Object System.Collections.ArrayList
    $sameName = New-Object System.Collections.ArrayList
    $existing = 0
    foreach ($c in $cands) {
        $rows = $listing[$c.Name]
        if ($null -eq $rows) { continue }
        $existing++
        $byName = @($rows | Where-Object { Test-TableMatch -Shown $_.File -Actual $nameL -Width 30 })
        $match = @($byName | Where-Object { Test-TableMatch -Shown $_.Dir -Actual $dirL -Width 50 })
        if ($byName.Count -gt 0 -and $match.Count -eq 0) { [void]$sameName.Add($c.Name) }
        $ids = @($match | ForEach-Object Id | Sort-Object -Unique)
        if ($ids.Count -gt 1) {
            throw (New-JaError 5 "módulos homônimos no projeto $($c.Name) (IDs $($ids -join ', ')) e o caminho exibido pelo console está truncado; não dá para escolher com segurança")
        }
        if ($ids.Count -eq 1) {
            [void]$found.Add([pscustomobject]@{ Name = $c.Name; Level = $c.Level; Rows = $rows; ModuleRows = @($rows | Where-Object { $_.Id -eq $ids[0] }) })
        }
    }
    if ($existing -eq 0) { $ctx.Note = "projeto(s) $(@($cands | ForEach-Object Name) -join ', ') não existe(m) no servidor"; return $ctx }
    if ($found.Count -eq 0) {
        $ctx.Status = 'notVersioned'
        $ctx.Note = 'arquivo não é módulo do(s) projeto(s) ' + (@($cands | ForEach-Object Name) -join ', ')
        if ($sameName.Count -gt 0) { $ctx.Note += " (há módulo com o mesmo nome em outro caminho em $($sameName -join ', '))" }
        return $ctx
    }
    $best = $found[0]
    $tied = @($found | Where-Object { $_.Level -eq $best.Level })
    if ($tied.Count -gt 1 -and -not $Project) {
        throw (New-JaError 5 "o arquivo pertence a mais de um projeto ($(@($tied | ForEach-Object Name) -join ', ')); informe -Project")
    }
    $ctx.Status = 'versioned'
    $ctx.Project = $best.Name
    $ctx.Rows = $best.Rows
    $ctx.ModuleRows = $best.ModuleRows
    return $ctx
}

# Baixa a última revisão de cada módulo numa pasta nova e vazia (sem Prompt e sem noprompt).
function Get-JvcsBase {
    param([string]$ProjectName, [int[]]$Ids)
    $root = New-JaTempDir -Prefix 'base'
    try {
        $lines = New-Object System.Collections.ArrayList
        [void]$lines.Add('openproject "' + $ProjectName + '"')
        foreach ($id in $Ids) {
            $d = Join-Path $root ([string]$id)
            [void](New-Item -ItemType Directory -Path $d -Force)
            [void]$lines.Add('getmodule ' + $id + ' dest="' + $d + '"')
        }
        $r = Invoke-Jvcs ([string[]]$lines)
        $e0 = Get-SectionError $r.Sections[0]
        if ($e0) { throw (New-JaError 5 "openproject $($ProjectName): $e0") }
        $map = @{}
        for ($i = 0; $i -lt $Ids.Count; $i++) {
            $sec = $r.Sections[$i + 1]
            $e = Get-SectionError $sec
            if ($e) { throw (New-JaError 9 "getmodule $($Ids[$i]): $e") }
            $files = @(Get-ChildItem -LiteralPath (Join-Path $root ([string]$Ids[$i])) -File)
            if ($files.Count -eq 0) { throw (New-JaError 9 "getmodule $($Ids[$i]) não gravou nenhum arquivo") }
            $map[[string]$Ids[$i]] = $files
        }
        return [pscustomobject]@{ Root = $root; Map = $map }
    } catch {
        Remove-JaTempDir $root
        throw
    }
}

# Compara cada membro da base com o arquivo local de mesmo nome na pasta local.
function Compare-WithBase {
    param($BaseFiles, [string]$LocalDir)
    $members = New-Object System.Collections.ArrayList
    foreach ($bf in $BaseFiles) {
        $lp = Join-Path $LocalDir $bf.Name
        $m = [pscustomobject]@{ Name = $bf.Name; Base = $bf.FullName; Local = $lp; State = 'missing'; SameTime = $false; BaseTimeUtc = $bf.LastWriteTimeUtc; ReadOnly = $false; LocalTimeUtc = $null; Aligned = $false }
        if (Test-Path -LiteralPath $lp -PathType Leaf) {
            $lfi = New-Object IO.FileInfo $lp
            $m.ReadOnly = $lfi.IsReadOnly
            $m.LocalTimeUtc = $lfi.LastWriteTimeUtc
            $m.State = 'modified'
            if ($lfi.Length -eq $bf.Length -and (Test-JaBytesEqual ([IO.File]::ReadAllBytes($lp)) ([IO.File]::ReadAllBytes($bf.FullName)))) { $m.State = 'clean' }
            $m.SameTime = ([Math]::Abs(($lfi.LastWriteTimeUtc - $bf.LastWriteTimeUtc).TotalSeconds) -le 1.0)
        }
        [void]$members.Add($m)
    }
    $agg = 'clean'
    if (@($members | Where-Object { $_.State -eq 'modified' }).Count -gt 0) { $agg = 'modified' }
    elseif (@($members | Where-Object { $_.State -eq 'missing' }).Count -gt 0) { $agg = 'missing' }
    return [pscustomobject]@{ State = $agg; Members = $members }
}

function ConvertTo-FileItems {
    param($Cmp)
    $list = New-Object System.Collections.ArrayList
    foreach ($m in $Cmp.Members) {
        $ro = $false
        if (Test-Path -LiteralPath $m.Local -PathType Leaf) { $ro = (New-Object IO.FileInfo $m.Local).IsReadOnly }
        [void]$list.Add([ordered]@{ name = $m.Name; localState = $m.State; readOnly = $ro })
    }
    return , $list
}

# Alinha a data do arquivo local (conteúdo igual) à da base, para o console usar o caminho
# CHECKOUT_ONLY_MODULE / não perguntar "Overwrite?" (critério do console: data OU CRC).
function Sync-CleanMemberTimes {
    param($Cmp)
    $n = 0
    foreach ($m in $Cmp.Members) {
        if ($m.State -eq 'clean' -and -not $m.SameTime) {
            Set-LocalWriteTimeUtc -Path $m.Local -TimeUtc $m.BaseTimeUtc
            $m.SameTime = $true
            $m.Aligned = $true
            $n++
        }
    }
    return $n
}

# Depois do checkout, devolve a data original aos arquivos cuja data foi alinhada (o conteúdo é o
# mesmo). Assim o Edit do Claude Code não acusa "arquivo modificado desde a leitura".
function Restore-AlignedTimes {
    param($Cmp)
    foreach ($m in $Cmp.Members) {
        if ($m.Aligned -and $null -ne $m.LocalTimeUtc -and (Test-Path -LiteralPath $m.Local -PathType Leaf)) {
            try { Set-LocalWriteTimeUtc -Path $m.Local -TimeUtc $m.LocalTimeUtc; $m.Aligned = $false } catch { Add-JaWarning "não foi possível restaurar a data de $($m.Name): $($_.Exception.Message)" }
        }
    }
}

function Set-LocalWriteTimeUtc {
    param([string]$Path, [datetime]$TimeUtc)
    $fi = New-Object IO.FileInfo $Path
    $ro = $fi.IsReadOnly
    if ($ro) { $fi.IsReadOnly = $false }
    try { [IO.File]::SetLastWriteTimeUtc($Path, $TimeUtc) }
    finally { if ($ro) { (New-Object IO.FileInfo $Path).IsReadOnly = $true } }
}

# A tabela do console mostra só 47 caracteres do caminho do servidor ("..." no fim), e o console
# lê/grava o arquivo NO CAMINHO DO SERVIDOR (checkin jvcs.dpr:871/905-947; checkout :1292/:1383).
# Quando o caminho está truncado, a resolução por prefixo aceitaria qualquer cópia do projeto com
# o mesmo começo de caminho. Antes de mudar o servidor, prova que o arquivo local é o mesmo:
#  1. pré-checagem com a listagem já feita: Stamp 'N/A' (ausente no caminho do servidor) ou
#     coluna CRC incoerente com a comparação de bytes contra a base -> é outro arquivo;
#  2. sonda: muda a data do arquivo local em +-6 h (o console tolera 10 s, cTimeConvErr), roda
#     listproject e exige que o Stamp do membro mude para o valor previsto ('N' ou 'O'); a data
#     original é restaurada em seguida (finally).
# Devolve 'exact' (caminho visível inteiro) ou 'verified'; lança 5 quando não é o mesmo arquivo.
function Assert-ServerPath {
    param($Ctx, [string]$FullPath, $Cmp)
    $trunc = @($Ctx.ModuleRows | Where-Object { $_.Dir.Length -eq 50 -and $_.Dir.EndsWith('...') })
    if ($trunc.Count -eq 0) { return 'exact' }
    $nameL = [IO.Path]::GetFileName($FullPath).ToLowerInvariant()
    $pairs = New-Object System.Collections.ArrayList
    foreach ($mem in $Cmp.Members) {
        if ($mem.State -eq 'missing') { continue }
        $row = @($Ctx.ModuleRows | Where-Object { Test-TableMatch -Shown $_.File -Actual $mem.Name.ToLowerInvariant() -Width 30 })
        if ($row.Count -ne 1) { continue }
        $pair = [pscustomobject]@{ Row = $row[0]; Member = $mem }
        if ($mem.Name.ToLowerInvariant() -eq $nameL) { $pairs.Insert(0, $pair) } else { [void]$pairs.Add($pair) }
    }
    if ($pairs.Count -eq 0) {
        throw (New-JaError 5 "o console mostra o caminho do servidor truncado ('$($trunc[0].Dir)') e nenhum arquivo do módulo existe aqui para provar que é o mesmo caminho; nada foi feito")
    }
    $mismatch = "o caminho registrado no servidor (truncado: '$($pairs[0].Row.Dir)') não é o deste arquivo ($FullPath): o console leria/gravaria outra cópia. Nada foi feito; trabalhe na pasta registrada no JEDI VCS"
    foreach ($p in $pairs) {
        if ($p.Row.Stamp -eq 'N/A') { throw (New-JaError 5 ($mismatch + " ($($p.Member.Name) não existe no caminho do servidor)")) }
        $expCrc = ''
        if ($p.Member.State -eq 'modified') { $expCrc = '*' }
        if ($p.Row.Crc -ne $expCrc) { throw (New-JaError 5 ($mismatch + " (o CRC de $($p.Member.Name) no caminho do servidor não bate com o arquivo local)")) }
    }
    $pr = $pairs[0]
    $orig = (New-Object IO.FileInfo $pr.Member.Local).LastWriteTimeUtc
    $expect = 'N'; $probeTime = $pr.Member.BaseTimeUtc.AddHours(6)
    if ($pr.Row.Stamp -eq 'N') { $expect = 'O'; $probeTime = $pr.Member.BaseTimeUtc.AddHours(-6) }
    $seen = '(linha não encontrada)'
    try {
        Set-LocalWriteTimeUtc -Path $pr.Member.Local -TimeUtc $probeTime
        $l2 = Get-ProjectListing -Names @($Ctx.Project)
        $r2 = @($l2[$Ctx.Project] | Where-Object { $_.Id -eq $pr.Row.Id -and $_.File -eq $pr.Row.File })
        if ($r2.Count -eq 1) { $seen = $r2[0].Stamp }
    } finally {
        Set-LocalWriteTimeUtc -Path $pr.Member.Local -TimeUtc $orig
    }
    if ($seen -ne $expect) { throw (New-JaError 5 ($mismatch + " (sonda de data: esperado '$expect', o console viu '$seen')")) }
    return 'verified'
}

function New-BackupDir {
    param([string]$Tag)
    $d = Join-Path (Get-JaLocalDir) ('backup\' + (Get-Date).ToString('yyyyMMdd-HHmmss') + '-' + $Tag)
    [void](New-Item -ItemType Directory -Path $d -Force)
    return $d
}

# ======================================================================= política (modos)

# Em contexto de agente aplica os modos do config.ini. Humano (sem CLAUDECODE/AI_AGENT): livre.
function Assert-Mode {
    param([ValidateSet('checkout', 'checkin', 'release', 'discard')][string]$Kind, [string]$What)
    if (-not $script:IsAgent) { return }
    $mode = $script:Cfg.checkin
    if ($Kind -eq 'checkout') { $mode = $script:Cfg.checkout }
    $cmdHint = Get-JaCanonicalCommand 'jvcs-ai.ps1'
    if ($mode -eq 'manual') {
        throw (New-JaError 10 "modo $Kind=manual no config.ini: a IA não faz esta operação. Peça ao usuário para fazer '$What' (IDE/GUI do JEDI VCS ou o próprio jvcs-ai.ps1 no terminal dele).")
    }
    if ($Kind -eq 'release') { return }
    if ($Kind -eq 'discard' -or $mode -eq 'confirm') {
        $why = "modo $Kind=confirm"
        if ($Kind -eq 'discard') { $why = 'descartar alterações locais' }
        if (Assert-JaHumanApproval -IsAgent $true -ConfirmedSwitch $Confirmed.IsPresent -InvocationLine $script:InvocationLine -Why $why -CommandHint "$cmdHint $What") {
            $script:ConfirmedUsed = $true
        }
    }
}

# -Force e -AllowEncodingChange mudam o que vai para o servidor: pela IA, sempre com -Confirmed
# (em qualquer modo, inclusive auto).
function Assert-RiskyOption {
    param([string]$Option, [string]$What)
    if (-not $script:IsAgent) { return }
    $cmdHint = (Get-JaCanonicalCommand 'jvcs-ai.ps1') + " $What"
    if (Assert-JaHumanApproval -IsAgent $true -ConfirmedSwitch $Confirmed.IsPresent -InvocationLine $script:InvocationLine -Why "$Option pela IA" -CommandHint $cmdHint) {
        $script:ConfirmedUsed = $true
    }
}

function Test-JaTimeoutError {
    param($ErrorRecord)
    $ex = $ErrorRecord.Exception
    while ($null -ne $ex) {
        if ($ex.Data -and $ex.Data.Contains('jaTimeout')) { return $true }
        $ex = $ex.InnerException
    }
    return $false
}

# Estado real do módulo no servidor (usado depois de timeout/erro): {Version, LockedBy, Found}.
function Get-ModuleServerState {
    param([string]$ProjectName, [int]$Id)
    $l = Get-ProjectListing -Names @($ProjectName)
    $rows = @($l[$ProjectName] | Where-Object { $_.Id -eq $Id })
    if ($rows.Count -eq 0) { return [pscustomobject]@{ Found = $false; Version = $null; LockedBy = '' } }
    $m = New-ModuleItem $rows
    return [pscustomobject]@{ Found = $true; Version = $m.version; LockedBy = $m.lockedBy }
}

# Aplica Assert-Mode preenchendo o item em caso de recusa. Devolve $true se pode seguir.
function Test-ModeGate {
    param($Item, [string]$Kind, [string]$What)
    try { Assert-Mode -Kind $Kind -What $What; return $true }
    catch {
        $Item.state = 'needsConfirmation'
        $Item.exitCode = Get-JaErrorCode $_ 10
        $Item.message = Get-JaErrorMessage $_
        if ($Item.exitCode -ne 10) { throw }
        return $false
    }
}

# ======================================================================= comandos de leitura

function Invoke-CmdIdentity {
    $id = Get-JaIdentityCached
    $script:Res['identity'] = [ordered]@{ name = $id.Name; host = $id.Host; port = $id.Port; user = $id.User; hasPassword = $id.HasPassword; source = $id.Source }
    $script:Res.message = "identidade '$($id.Name)': $($id.User)@$($id.Host):$($id.Port)"
    if ($Test) {
        Enter-JaLock
        $r = Invoke-Jvcs @('listlocks')
        $srv = [regex]::Match($r.Out, 'JEDI VCS Server: (.+)').Groups[1].Value.Trim()
        $acc = [regex]::Match($r.Out, 'Access level: (.+)').Groups[1].Value.Trim()
        $script:Res['identity']['server'] = $srv
        $script:Res['identity']['accessLevel'] = $acc
        $script:Res.message += " - login ok ($srv; nível $acc)"
    }
}

function Invoke-CmdProjects {
    Enter-JaLock
    $r = Invoke-Jvcs @('listprojects')
    $e = Get-SectionError $r.Sections[0]
    if ($e) { throw (New-JaError 9 "listprojects: $e") }
    $rows = ConvertFrom-ListProjects $r.Sections[0]
    $list = New-Object System.Collections.ArrayList
    foreach ($p in $rows) {
        [void]$list.Add([ordered]@{ id = $p.Id; name = $p.Name; nameTruncated = ($p.Name.Length -eq 30 -and $p.Name.EndsWith('...')); created = $p.Created; creator = $p.Creator; deleted = $p.Deleted; description = $p.Description })
    }
    $script:Res['projects'] = $list
    $script:Res.message = "$($list.Count) projeto(s)"
}

function Get-DefaultProjectName {
    if ($Project) { return (Get-ProjectNameFromArg $Project) }
    $here = @(Get-ChildItem -LiteralPath (Get-Location).Path -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -ieq '.dpr' -or $_.Extension -ieq '.dpk' })
    if ($here.Count -eq 1) { return $here[0].Name.ToLowerInvariant() }
    throw (New-JaError 2 'informe -Project <nome.dpr> (não há um único .dpr/.dpk na pasta atual)')
}

function Get-ProjectDir {
    param([string]$ProjectName)
    if ($Project -and ($Project -match '[\\/]')) {
        $full = [IO.Path]::GetFullPath($Project)
        if (Test-Path -LiteralPath $full -PathType Leaf) { return (Split-Path -Parent $full) }
        if (Test-Path -LiteralPath $full -PathType Container) { return $full }
    }
    $d = (Get-Location).Path
    while ($d) {
        if (Test-Path -LiteralPath (Join-Path $d $ProjectName) -PathType Leaf) { return $d }
        $parent = [IO.Path]::GetDirectoryName($d)
        if (-not $parent -or $parent -eq $d) { break }
        $d = $parent
    }
    return $null
}

function Invoke-CmdList {
    $name = Get-DefaultProjectName
    Enter-JaLock
    $listing = Get-ProjectListing -Names @($name)
    if ($null -eq $listing[$name]) { throw (New-JaError 5 "projeto '$name' não existe no servidor") }
    $script:Res.project = $name
    $groups = Get-ModuleGroups $listing[$name]
    foreach ($k in $groups.Keys) {
        $rows = $groups[$k]
        $item = New-ModuleItem $rows
        $files = New-Object System.Collections.ArrayList
        $agg = 'clean'
        foreach ($r in $rows) {
            $st = 'clean'
            if ($r.Stamp -eq 'N/A') { $st = 'missing' } elseif ($r.Crc -eq '*') { $st = 'modified' }
            if ($st -eq 'modified') { $agg = 'modified' } elseif ($st -eq 'missing' -and $agg -eq 'clean') { $agg = 'missing' }
            [void]$files.Add([ordered]@{ name = $r.File; dir = $r.Dir; localState = $st; stamp = $r.Stamp; hidden = $r.Hidden })
        }
        $item.localState = $agg
        $item['files'] = $files
        [void]$script:Res.modules.Add($item)
    }
    $script:Res.message = "$($script:Res.modules.Count) módulo(s) em $name (estado local pelo CRC calculado pelo console no caminho do servidor; use status para comparação exata)"
}

function Invoke-CmdLocks {
    Enter-JaLock
    $line = 'listlocks'
    if ($All) { $line = 'listlocks all_users' }
    $r = Invoke-Jvcs @($line)
    $e = Get-SectionError $r.Sections[0]
    if ($e) { throw (New-JaError 9 "$($line): $e") }
    foreach ($row in (ConvertFrom-ListLocks $r.Sections[0])) {
        [void]$script:Res.modules.Add([ordered]@{ id = $row.Id; name = $row.File; dir = $row.Dir; version = $row.Version; lockedBy = $row.Owner; lockedAt = $row.Locked; localState = $null })
    }
    $who = 'meus'
    if ($All) { $who = 'de todos os usuários' }
    $script:Res.message = "$($script:Res.modules.Count) módulo(s) em checkout ($who)"
}

# Procura no disco o arquivo de um membro cujo caminho a tabela mostra truncado.
function Find-LocalMember {
    param($Row, [string]$ProjectDir)
    if (-not ($Row.Dir.Length -eq 50 -and $Row.Dir.EndsWith('...'))) {
        return [pscustomobject]@{ Path = (Join-Path $Row.Dir $Row.File); Exact = $true }
    }
    $vis = $Row.Dir.Substring(0, 47)
    $hits = @()
    if ($ProjectDir -and (Test-Path -LiteralPath $ProjectDir)) {
        $hits = @(Get-ChildItem -LiteralPath $ProjectDir -Recurse -File -Filter $Row.File -ErrorAction SilentlyContinue |
                Where-Object { ($_.DirectoryName.ToLowerInvariant() + '\').StartsWith($vis, [StringComparison]::OrdinalIgnoreCase) })
    }
    if ($hits.Count -eq 1) { return [pscustomobject]@{ Path = $hits[0].FullName; Exact = $false } }
    return [pscustomobject]@{ Path = $null; Exact = $false; Count = $hits.Count }
}

function Invoke-CmdStatus {
    Enter-JaLock
    $files = @($Rest | Where-Object { $_ -and $_.Trim() })
    if ($files.Count -gt 0) {
        foreach ($f in (Get-FileArgs)) {
            $ctx = Resolve-FileContext $f
            if ($ctx.Status -ne 'versioned') {
                $item = [ordered]@{ id = $null; name = [IO.Path]::GetFileName($f); path = $f; version = $null; lockedBy = $null; localState = 'notVersioned'; state = $ctx.Status; exitCode = 0; message = $ctx.Note }
                [void]$script:Res.modules.Add($item)
                continue
            }
            $script:Res.project = $ctx.Project
            $item = New-ModuleItem $ctx.ModuleRows $f
            $base = Get-JvcsBase -ProjectName $ctx.Project -Ids @($item.id)
            try {
                $cmp = Compare-WithBase -BaseFiles $base.Map[[string]$item.id] -LocalDir ([IO.Path]::GetDirectoryName($f))
                $item.localState = $cmp.State
                $item['files'] = ConvertTo-FileItems $cmp
                $item.state = 'ok'
            } finally { Remove-JaTempDir $base.Root }
            [void]$script:Res.modules.Add($item)
        }
        $script:Res.message = "$($script:Res.modules.Count) arquivo(s) verificado(s)"
        return
    }
    # status do projeto inteiro
    $name = Get-DefaultProjectName
    $listing = Get-ProjectListing -Names @($name)
    if ($null -eq $listing[$name]) { throw (New-JaError 5 "projeto '$name' não existe no servidor") }
    $script:Res.project = $name
    $pdir = Get-ProjectDir $name
    $groups = Get-ModuleGroups $listing[$name]
    $ids = @($groups.Keys | ForEach-Object { [int]$_ })
    if ($ids.Count -eq 0) { $script:Res.message = 'projeto sem módulos'; return }
    $base = Get-JvcsBase -ProjectName $name -Ids $ids
    try {
        foreach ($k in $groups.Keys) {
            $rows = $groups[$k]
            $item = New-ModuleItem $rows
            $localDir = $null; $unknown = $false
            foreach ($r in $rows) {
                $loc = Find-LocalMember -Row $r -ProjectDir $pdir
                if ($loc.Path) { $localDir = [IO.Path]::GetDirectoryName($loc.Path); $item.path = $loc.Path; break }
                $unknown = $true
            }
            if ($localDir) {
                $cmp = Compare-WithBase -BaseFiles $base.Map[$k] -LocalDir $localDir
                $item.localState = $cmp.State
                $item['files'] = ConvertTo-FileItems $cmp
                $item.state = 'ok'
            } else {
                $item.localState = 'unknown'
                $item.state = 'pathTruncated'
                $item.message = 'caminho do servidor truncado pelo console e arquivo não localizado sob a pasta do projeto; rode status <arquivo>'
            }
            [void]$script:Res.modules.Add($item)
        }
    } finally { Remove-JaTempDir $base.Root }
    $script:Res.message = "$($script:Res.modules.Count) módulo(s) em $name"
}

# ======================================================================= checkout

function Invoke-CheckoutOne {
    param([string]$FullPath, [bool]$Ensure)
    $item = [ordered]@{ id = $null; name = [IO.Path]::GetFileName($FullPath); path = $FullPath; version = $null; lockedBy = $null; localState = $null; state = $null; exitCode = 0; message = ''; pathCheck = $null }
    $ctx = Resolve-FileContext $FullPath
    if ($ctx.Status -ne 'versioned') {
        $item.state = 'notVersioned'; $item.localState = 'notVersioned'; $item.message = $ctx.Note
        if (-not $Ensure) { $item.exitCode = 5; $item.message = 'não versionado no JEDI VCS: ' + $ctx.Note }
        return $item
    }
    $script:Res.project = $ctx.Project
    $m = New-ModuleItem $ctx.ModuleRows $FullPath
    foreach ($k in @('id', 'name', 'version', 'lockedBy', 'pathCheck')) { $item[$k] = $m[$k] }
    if ($item.lockedBy) {
        if (Test-IsMe $item.lockedBy) { $item.state = 'alreadyMine'; $item.message = "já está em checkout por $($item.lockedBy)"; return $item }
        $item.state = 'lockedByOther'; $item.exitCode = 6; $item.message = "em checkout por '$($item.lockedBy)'"; return $item
    }
    if ($CheckOnly) { $item.state = 'needsCheckout'; $item.message = 'versionado e sem checkout'; return $item }

    if (-not (Test-ModeGate -Item $item -Kind 'checkout' -What ("checkout `"$FullPath`""))) { return $item }

    $base = Get-JvcsBase -ProjectName $ctx.Project -Ids @($item.id)
    $backup = $null
    $restoreMembers = New-Object System.Collections.ArrayList
    $cmp = $null
    try {
        $localDir = [IO.Path]::GetDirectoryName($FullPath)
        $cmp = Compare-WithBase -BaseFiles $base.Map[[string]$item.id] -LocalDir $localDir
        $item.localState = $cmp.State
        $modified = @($cmp.Members | Where-Object { $_.State -eq 'modified' })
        if ($modified.Count -gt 0) {
            if (-not $Force) {
                $item.state = 'localModified'; $item.exitCode = 8
                $item.message = 'arquivo local difere da última revisão do servidor (' + (@($modified | ForEach-Object Name) -join ', ') + '); nada foi travado. Use status, ou checkout -Force para travar mantendo a alteração local'
                $item['files'] = ConvertTo-FileItems $cmp
                return $item
            }
            try { Assert-RiskyOption -Option 'checkout -Force (travar mantendo uma alteração local que difere do servidor)' -What "checkout `"$FullPath`" -Force" }
            catch {
                $item.state = 'needsConfirmation'; $item.exitCode = Get-JaErrorCode $_ 10; $item.message = Get-JaErrorMessage $_
                $item['files'] = ConvertTo-FileItems $cmp
                return $item
            }
        }
        # caminho do servidor truncado na tabela: prova que é este arquivo antes de mudar o servidor
        try { $item.pathCheck = Assert-ServerPath -Ctx $ctx -FullPath $FullPath -Cmp $cmp }
        catch {
            $item.state = 'pathMismatch'; $item.exitCode = Get-JaErrorCode $_ 5; $item.message = Get-JaErrorMessage $_
            $item['files'] = ConvertTo-FileItems $cmp
            return $item
        }
        if ($modified.Count -gt 0) {
            # -Force: trava mantendo a alteração local (backup -> base -> checkout limpo -> devolve o local)
            $backup = New-BackupDir ("checkout-force-$($item.id)")
            foreach ($mm in $modified) {
                Copy-Item -LiteralPath $mm.Local -Destination (Join-Path $backup $mm.Name) -Force
                # a partir daqui, se algo falhar, o finally devolve o conteúdo do usuário
                [void]$restoreMembers.Add($mm)
                Set-JaReadOnly $mm.Local $false
                Copy-Item -LiteralPath $mm.Base -Destination $mm.Local -Force
                [IO.File]::SetLastWriteTimeUtc($mm.Local, $mm.BaseTimeUtc)
                $mm.State = 'clean'; $mm.SameTime = $true
            }
        }
        $aligned = Sync-CleanMemberTimes $cmp
        if ($aligned -gt 0) { Add-JaWarning "$($item.name): data local alinhada à da base em $aligned arquivo(s) durante o checkout (conteúdo idêntico; a data original foi restaurada depois)" }

        $r = $null
        try {
            $r = Invoke-Jvcs @(('openproject "' + $ctx.Project + '"'), ('checkout ' + $item.id), 'listlocks', ('listproject "' + $ctx.Project + '"'))
        } catch {
            if (-not (Test-JaTimeoutError $_)) { throw }
            # timeout: o console pode ter travado o módulo antes de morrer; confere e compensa
            $item.state = 'timeout'; $item.exitCode = 9
            $item.message = (Get-JaErrorMessage $_) + '; checkout não concluído'
            $st = Get-ModuleServerState -ProjectName $ctx.Project -Id $item.id
            $item.version = $st.Version; $item.lockedBy = $st.LockedBy
            if ($st.LockedBy -and (Test-IsMe $st.LockedBy)) {
                $left = Invoke-CompensateCheckout -ProjectName $ctx.Project -Id $item.id
                $item.lockedBy = $left
                if ($left) { $item.message += '; ATENÇÃO: o módulo ficou travado e a compensação falhou, rode undocheckout' }
                else { $item.message += '; o lock criado foi desfeito por compensação' }
            } else { $item.message += '; nenhum lock ficou no servidor' }
            $item['files'] = ConvertTo-FileItems (Compare-WithBase -BaseFiles $base.Map[[string]$item.id] -LocalDir $localDir)
            return $item
        }
        $eOpen = Get-SectionError $r.Sections[0]
        if ($eOpen) { throw (New-JaError 5 "openproject: $eOpen") }
        $eCo = Get-SectionError $r.Sections[1]
        $locks = ConvertFrom-ListLocks $r.Sections[2]
        $mine = @($locks | Where-Object { $_.Id -eq $item.id })
        $after = @((ConvertFrom-ListProject $r.Sections[3]) | Where-Object { $_.Id -eq $item.id })
        if ($after.Count -gt 0) { $a = New-ModuleItem $after; $item.version = $a.version; $item.lockedBy = $a.lockedBy }
        if ($eCo -and $eCo -match 'locked by user ''([^'']*)''' -and $mine.Count -eq 0) {
            $item.state = 'lockedByOther'; $item.exitCode = 6; $item.message = "em checkout por '$($Matches[1])'"
        } elseif ($eCo -and $mine.Count -gt 0) {
            # o console travou e depois falhou (Prompt com stdin redirecionado = EOSError; arquivo
            # aberto em modo exclusivo = EFCreateError; ...): desfaz para não deixar lock órfão
            $left = Invoke-CompensateCheckout -ProjectName $ctx.Project -Id $item.id
            $item.state = 'failedCompensated'; $item.exitCode = 7; $item.lockedBy = $left
            $item.message = "o checkout falhou depois de travar ($eCo); checkout desfeito por compensação"
            if ($left) { $item.exitCode = 9; $item.message += '; ATENÇÃO: o lock continua, rode undocheckout' }
        } elseif ($eCo) {
            $item.state = 'failed'; $item.exitCode = 9; $item.message = "checkout recusado: $eCo"
        } elseif ($mine.Count -eq 0) {
            $item.state = 'failed'; $item.exitCode = 9; $item.message = 'o console não relatou erro, mas o lock não aparece em listlocks'
        } else {
            $item.state = 'checkedOut'; $item.message = "checkout ok (versão $($item.version))"
            if ($restoreMembers.Count -gt 0) {
                foreach ($mm in $restoreMembers) {
                    Set-JaReadOnly $mm.Local $false
                    Copy-Item -LiteralPath (Join-Path $backup $mm.Name) -Destination $mm.Local -Force
                    # a cópia herda o somente leitura do original (sem checkout); em checkout fica gravável
                    Set-JaReadOnly $mm.Local $false
                }
                $restoreMembers.Clear()
                $item.state = 'checkedOutKeptLocal'
                $item.message += "; alteração local mantida (backup em $backup)"
            }
            if ($script:IsAgent) { Add-JaSessionCheckout $FullPath }
        }
        $cmp2 = Compare-WithBase -BaseFiles $base.Map[[string]$item.id] -LocalDir $localDir
        $item.localState = $cmp2.State
        $item['files'] = ConvertTo-FileItems $cmp2
        if ($item.exitCode -eq 0) {
            $ro = @($item['files'] | Where-Object { $_.readOnly })
            if ($ro.Count -gt 0) { Add-JaWarning "$($item.name): ainda somente leitura após o checkout: $(@($ro | ForEach-Object { $_.name }) -join ', ')" }
        }
        return $item
    } finally {
        if ($restoreMembers.Count -gt 0 -and $backup) {
            # falhou depois de trocar o local pela base: devolve o conteúdo do usuário
            foreach ($mm in $restoreMembers) {
                try { Set-JaReadOnly $mm.Local $false; Copy-Item -LiteralPath (Join-Path $backup $mm.Name) -Destination $mm.Local -Force } catch { }
            }
        }
        if ($null -ne $cmp) { Restore-AlignedTimes $cmp }
        Remove-JaTempDir $base.Root
    }
}

# Desfaz um checkout que o próprio wrapper acabou de fazer (local = base). Devolve o dono do lock
# que sobrou ('' = liberado).
function Invoke-CompensateCheckout {
    param([string]$ProjectName, [int]$Id)
    try {
        $r2 = Invoke-Jvcs @(('openproject "' + $ProjectName + '"'), ('undocheckout ' + $Id), 'listlocks')
        $still = @((ConvertFrom-ListLocks $r2.Sections[2]) | Where-Object { $_.Id -eq $Id })
        if ($still.Count -gt 0) { return [string]$still[0].Owner }
        return ''
    } catch {
        Add-JaWarning ('a compensação (undocheckout) falhou: ' + (Get-JaErrorMessage $_))
        return '?'
    }
}

function Invoke-CmdCheckout {
    param([bool]$Ensure)
    $max = 1000
    if ($Ensure) { $max = 1 }
    $files = Get-FileArgs -Min 1 -Max $max
    Enter-JaLock
    foreach ($f in $files) {
        try { [void]$script:Res.modules.Add((Invoke-CheckoutOne -FullPath $f -Ensure $Ensure)) }
        catch {
            [void]$script:Res.modules.Add([ordered]@{ id = $null; name = [IO.Path]::GetFileName($f); path = $f; version = $null; lockedBy = $null; localState = $null; state = 'error'; exitCode = (Get-JaErrorCode $_); message = (Get-JaErrorMessage $_) })
        }
    }
}

# ======================================================================= checkin

function Get-CheckinComment {
    $c = ([string]$Comment).Trim()
    if (-not $c) { throw (New-JaError 2 'informe -Comment "texto" (uma linha, o porquê da mudança)') }
    if ($c -match '[\r\n]') { throw (New-JaError 2 'comentário deve ter uma linha só') }
    if ($c.Contains('"')) { throw (New-JaError 2 'comentário não pode conter aspas duplas (o console 2.5 não tem escape)') }
    if ($c -match '[\x00-\x1f]') { throw (New-JaError 2 'comentário com caractere de controle') }
    if ($script:IsAgent) {
        $pfx = [string]$script:Cfg.commentPrefix
        if ($pfx -and -not $c.StartsWith($pfx)) { $c = $pfx + ' ' + $c }
    }
    Assert-AnsiArg $c 'comentário'
    if ($c.Length -gt 2000) { throw (New-JaError 2 'comentário muito longo (máximo 2000 caracteres)') }
    return $c
}

function Invoke-CheckinOne {
    param([string]$FullPath, [string]$CommentText)
    $item = [ordered]@{ id = $null; name = [IO.Path]::GetFileName($FullPath); path = $FullPath; version = $null; lockedBy = $null; localState = $null; state = $null; exitCode = 0; message = ''; pathCheck = $null }
    $ctx = Resolve-FileContext $FullPath
    if ($ctx.Status -ne 'versioned') { $item.state = 'notVersioned'; $item.exitCode = 5; $item.message = 'não versionado: ' + $ctx.Note; return $item }
    $script:Res.project = $ctx.Project
    $m = New-ModuleItem $ctx.ModuleRows $FullPath
    foreach ($k in @('id', 'name', 'version', 'lockedBy', 'pathCheck')) { $item[$k] = $m[$k] }
    if (-not $item.lockedBy) { $item.state = 'notCheckedOut'; $item.exitCode = 7; $item.message = 'o módulo não está em checkout; faça checkout antes de editar'; return $item }
    if (-not (Test-IsMe $item.lockedBy)) { $item.state = 'lockedByOther'; $item.exitCode = 6; $item.message = "em checkout por '$($item.lockedBy)'"; return $item }
    $versionBefore = $item.version

    $base = Get-JvcsBase -ProjectName $ctx.Project -Ids @($item.id)
    try {
        $localDir = [IO.Path]::GetDirectoryName($FullPath)
        $cmp = Compare-WithBase -BaseFiles $base.Map[[string]$item.id] -LocalDir $localDir
        $item.localState = $cmp.State
        $item['files'] = ConvertTo-FileItems $cmp
        $missing = @($cmp.Members | Where-Object { $_.State -eq 'missing' })
        if ($missing.Count -gt 0) {
            $item.state = 'localMissing'; $item.exitCode = 7
            $item.message = 'arquivo(s) local(is) ausente(s): ' + (@($missing | ForEach-Object Name) -join ', ')
            return $item
        }
        if ($cmp.State -eq 'clean') {
            # D7: sem mudança -> undocheckout
            if (-not (Test-ModeGate -Item $item -Kind 'checkin' -What ("checkin `"$FullPath`" -Comment `"$CommentText`""))) { return $item }
            try { $item.pathCheck = Assert-ServerPath -Ctx $ctx -FullPath $FullPath -Cmp $cmp }
            catch { $item.state = 'pathMismatch'; $item.exitCode = Get-JaErrorCode $_ 5; $item.message = Get-JaErrorMessage $_; return $item }
            [void](Sync-CleanMemberTimes $cmp)
            $r = Invoke-Jvcs @(('openproject "' + $ctx.Project + '"'), ('undocheckout ' + $item.id), ('listproject "' + $ctx.Project + '"'))
            $e = Get-SectionError $r.Sections[1]
            $after = @((ConvertFrom-ListProject $r.Sections[2]) | Where-Object { $_.Id -eq $item.id })
            if ($after.Count -gt 0) { $a = New-ModuleItem $after; $item.lockedBy = $a.lockedBy; $item.version = $a.version }
            if ($item.lockedBy) { $item.state = 'failed'; $item.exitCode = 9; $item.message = "sem mudança, mas o undocheckout falhou (lock '$($item.lockedBy)'): $e"; return $item }
            if ($e) { Add-JaWarning "undocheckout relatou '$e', mas o lock foi liberado" }
            $item.state = 'unchangedUndone'; $item.exitCode = 3
            $item.message = 'sem mudança em relação ao servidor: checkout desfeito (nada foi enviado)'
            $item['files'] = ConvertTo-FileItems (Compare-WithBase -BaseFiles $base.Map[[string]$item.id] -LocalDir $localDir)
            return $item
        }
        # codificação e quebras de linha contra a base
        $problems = New-Object System.Collections.ArrayList
        foreach ($mm in @($cmp.Members | Where-Object { $_.State -eq 'modified' })) {
            foreach ($p in (Compare-JaEncoding ([IO.File]::ReadAllBytes($mm.Base)) ([IO.File]::ReadAllBytes($mm.Local)))) { [void]$problems.Add("$($mm.Name): $p") }
        }
        if ($problems.Count -gt 0) {
            if (-not $AllowEncodingChange) {
                $item.state = 'encodingChanged'; $item.exitCode = 7
                $item.message = 'check-in recusado: codificação/quebras de linha mudaram em relação ao servidor: ' + ($problems -join '; ') + '. Corrija (edit-preserve.ps1 preserva a codificação) ou, se a mudança for intencional e o usuário pedir, use -AllowEncodingChange'
                return $item
            }
            try { Assert-RiskyOption -Option 'checkin -AllowEncodingChange (mudança de codificação/quebras de linha)' -What "checkin `"$FullPath`" -Comment `"$CommentText`" -AllowEncodingChange" }
            catch { $item.state = 'needsConfirmation'; $item.exitCode = Get-JaErrorCode $_ 10; $item.message = Get-JaErrorMessage $_; return $item }
            Add-JaWarning ('mudança de codificação aceita por -AllowEncodingChange: ' + ($problems -join '; '))
        }
        if (-not (Test-ModeGate -Item $item -Kind 'checkin' -What ("checkin `"$FullPath`" -Comment `"$CommentText`""))) { return $item }
        try { $item.pathCheck = Assert-ServerPath -Ctx $ctx -FullPath $FullPath -Cmp $cmp }
        catch { $item.state = 'pathMismatch'; $item.exitCode = Get-JaErrorCode $_ 5; $item.message = Get-JaErrorMessage $_; return $item }
        $r = $null
        try {
            $r = Invoke-Jvcs @(('openproject "' + $ctx.Project + '"'), ('checkin ' + $item.id + ' "' + $CommentText + '"'), ('listproject "' + $ctx.Project + '"'))
        } catch {
            if (-not (Test-JaTimeoutError $_)) { throw }
            # timeout: confere no servidor se a revisão entrou
            $tmsg = Get-JaErrorMessage $_
            $st = Get-ModuleServerState -ProjectName $ctx.Project -Id $item.id
            $item.version = $st.Version; $item.lockedBy = $st.LockedBy
            if ($st.Version -ne $versionBefore -and -not $st.LockedBy) {
                Add-JaWarning "$tmsg; mesmo assim a revisão entrou no servidor"
            } else {
                $item.state = 'timeout'; $item.exitCode = 9
                $item.message = "$tmsg; check-in não concluído (versão $($st.Version), lock '$($st.LockedBy)'); nada mudou no servidor, repita"
                return $item
            }
        }
        $e = ''
        if ($null -ne $r) {
            $eOpen = Get-SectionError $r.Sections[0]
            if ($eOpen) { throw (New-JaError 5 "openproject: $eOpen") }
            $e = Get-SectionError $r.Sections[1]
            $after = @((ConvertFrom-ListProject $r.Sections[2]) | Where-Object { $_.Id -eq $item.id })
            if ($after.Count -gt 0) { $a = New-ModuleItem $after; $item.lockedBy = $a.lockedBy; $item.version = $a.version }
        }
        if ($e) {
            $item.state = 'failed'; $item.exitCode = 9
            $item.message = "check-in: $e"
            if ($e -match 'not changed') {
                # o wrapper viu diferença em bytes e o console não: ele olhou outro arquivo (ou houve
                # corrida). Não é sucesso: o lock continua.
                $item.message = "o console não vê mudança no arquivo do caminho do servidor ($e), embora o arquivo local seja diferente da base; nada foi enviado e o lock continua. Confira com status"
            }
        } elseif ($item.version -eq $versionBefore -or $item.lockedBy) {
            $item.state = 'refused'; $item.exitCode = 7
            $item.message = "o servidor não aceitou o check-in (versão continua $($item.version), lock '$($item.lockedBy)'); o console 2.5 não mostra o motivo"
        } else {
            $item.state = 'checkedIn'
            $item.message = "check-in ok: $versionBefore -> $($item.version)"
        }
        if ($item.state -eq 'checkedIn') {
            # confere o arquivo local contra a revisão recém-criada
            $nb = Get-JvcsBase -ProjectName $ctx.Project -Ids @($item.id)
            try {
                $cmp3 = Compare-WithBase -BaseFiles $nb.Map[[string]$item.id] -LocalDir $localDir
                $item.localState = $cmp3.State
                $item['files'] = ConvertTo-FileItems $cmp3
                if ($cmp3.State -ne 'clean') { Add-JaWarning "$($item.name): depois do check-in o arquivo local difere da revisão $($item.version) do servidor" }
            } finally { Remove-JaTempDir $nb.Root }
        } else {
            $item['files'] = ConvertTo-FileItems (Compare-WithBase -BaseFiles $base.Map[[string]$item.id] -LocalDir $localDir)
        }
        return $item
    } finally { Remove-JaTempDir $base.Root }
}

function Invoke-CmdCheckin {
    $files = Get-FileArgs
    $c = Get-CheckinComment
    $script:Res['comment'] = $c
    Enter-JaLock
    foreach ($f in $files) {
        try { [void]$script:Res.modules.Add((Invoke-CheckinOne -FullPath $f -CommentText $c)) }
        catch {
            [void]$script:Res.modules.Add([ordered]@{ id = $null; name = [IO.Path]::GetFileName($f); path = $f; version = $null; lockedBy = $null; localState = $null; state = 'error'; exitCode = (Get-JaErrorCode $_); message = (Get-JaErrorMessage $_) })
        }
    }
}

# ======================================================================= undocheckout

function Invoke-UndoOne {
    param([string]$FullPath)
    $item = [ordered]@{ id = $null; name = [IO.Path]::GetFileName($FullPath); path = $FullPath; version = $null; lockedBy = $null; localState = $null; state = $null; exitCode = 0; message = ''; pathCheck = $null }
    $ctx = Resolve-FileContext $FullPath
    if ($ctx.Status -ne 'versioned') { $item.state = 'notVersioned'; $item.exitCode = 5; $item.message = 'não versionado: ' + $ctx.Note; return $item }
    $script:Res.project = $ctx.Project
    $m = New-ModuleItem $ctx.ModuleRows $FullPath
    foreach ($k in @('id', 'name', 'version', 'lockedBy', 'pathCheck')) { $item[$k] = $m[$k] }
    if (-not $item.lockedBy) { $item.state = 'notCheckedOut'; $item.exitCode = 7; $item.message = 'o módulo não está em checkout'; return $item }
    if (-not (Test-IsMe $item.lockedBy)) { $item.state = 'lockedByOther'; $item.exitCode = 6; $item.message = "em checkout por '$($item.lockedBy)'"; return $item }

    $base = Get-JvcsBase -ProjectName $ctx.Project -Ids @($item.id)
    try {
        $localDir = [IO.Path]::GetDirectoryName($FullPath)
        $cmp = Compare-WithBase -BaseFiles $base.Map[[string]$item.id] -LocalDir $localDir
        $item.localState = $cmp.State
        $changed = @($cmp.Members | Where-Object { $_.State -ne 'clean' })
        $line = 'undocheckout ' + $item.id
        $backup = $null
        if ($changed.Count -gt 0) {
            if (-not $Discard) {
                $item.state = 'localModified'; $item.exitCode = 8
                $item.message = 'arquivo local difere do servidor (' + (@($changed | ForEach-Object Name) -join ', ') + '); nada foi feito. Faça check-in, ou use -Discard para descartar a alteração (com backup)'
                $item['files'] = ConvertTo-FileItems $cmp
                return $item
            }
            if (-not (Test-ModeGate -Item $item -Kind 'discard' -What ("undocheckout `"$FullPath`" -Discard"))) { return $item }
        } elseif (-not (Test-ModeGate -Item $item -Kind 'release' -What ("undocheckout `"$FullPath`""))) { return $item }
        # caminho do servidor truncado: o console restaura/libera o arquivo do caminho do servidor
        try { $item.pathCheck = Assert-ServerPath -Ctx $ctx -FullPath $FullPath -Cmp $cmp }
        catch {
            $item.state = 'pathMismatch'; $item.exitCode = Get-JaErrorCode $_ 5; $item.message = Get-JaErrorMessage $_
            $item['files'] = ConvertTo-FileItems $cmp
            return $item
        }
        if ($changed.Count -gt 0) {
            $backup = New-BackupDir ("discard-$($item.id)")
            foreach ($mm in $changed) { if (Test-Path -LiteralPath $mm.Local) { Copy-Item -LiteralPath $mm.Local -Destination (Join-Path $backup $mm.Name) -Force } }
            $line = 'undocheckout ' + $item.id + ' noprompt'
        }
        [void](Sync-CleanMemberTimes $cmp)
        $e = ''
        try {
            $r = Invoke-Jvcs @(('openproject "' + $ctx.Project + '"'), $line, ('listproject "' + $ctx.Project + '"'))
            $eOpen = Get-SectionError $r.Sections[0]
            if ($eOpen) { throw (New-JaError 5 "openproject: $eOpen") }
            $e = Get-SectionError $r.Sections[1]
            $after = @((ConvertFrom-ListProject $r.Sections[2]) | Where-Object { $_.Id -eq $item.id })
            if ($after.Count -gt 0) { $a = New-ModuleItem $after; $item.lockedBy = $a.lockedBy; $item.version = $a.version }
        } catch {
            if (-not (Test-JaTimeoutError $_)) { throw }
            $e = Get-JaErrorMessage $_
            $st = Get-ModuleServerState -ProjectName $ctx.Project -Id $item.id
            $item.lockedBy = $st.LockedBy; $item.version = $st.Version
        }
        $cmp2 = Compare-WithBase -BaseFiles $base.Map[[string]$item.id] -LocalDir $localDir
        if ($backup -and $cmp2.State -eq 'clean') {
            # o console não repõe o somente leitura quando restaura (Break antes do laço): repõe aqui
            $filter = Get-JaWritableFilter
            foreach ($mm in $cmp2.Members) { if (-not (Test-JaAlwaysWritable -FileName $mm.Name -Filter $filter)) { Set-JaReadOnly $mm.Local $true } }
        }
        $item.localState = $cmp2.State
        $item['files'] = ConvertTo-FileItems $cmp2
        if ($item.lockedBy) {
            $item.state = 'failed'; $item.exitCode = 9
            $item.message = "undocheckout não concluído: o lock continua ('$($item.lockedBy)')"
            if ($e) { $item.message += ": $e" }
        } elseif ($cmp2.State -ne 'clean') {
            # o console libera o lock ANTES de restaurar o arquivo (jvcs.dpr:2851)
            $item.state = 'releasedButDirty'; $item.exitCode = 9
            $item.message = 'lock liberado, mas o arquivo local continua diferente do servidor'
            if ($e) { $item.message += " ($e)" }
            if ($backup) { $item.message += " (backup em $backup)" }
        } else {
            if ($e) { Add-JaWarning "o console relatou '$e', mas o lock foi liberado e o arquivo local é igual ao servidor" }
            $item.state = 'undone'; $item.message = 'checkout desfeito'
            if ($backup) { $item.state = 'discarded'; $item.message = "checkout desfeito e alteração local descartada (backup em $backup)" }
        }
        return $item
    } finally { Remove-JaTempDir $base.Root }
}

function Invoke-CmdUndo {
    $files = Get-FileArgs
    Enter-JaLock
    foreach ($f in $files) {
        try { [void]$script:Res.modules.Add((Invoke-UndoOne -FullPath $f)) }
        catch {
            [void]$script:Res.modules.Add([ordered]@{ id = $null; name = [IO.Path]::GetFileName($f); path = $f; version = $null; lockedBy = $null; localState = $null; state = 'error'; exitCode = (Get-JaErrorCode $_); message = (Get-JaErrorMessage $_) })
        }
    }
}

# ======================================================================= config

function Invoke-CmdConfig {
    $sub = ''
    if ($Rest.Count -gt 0) { $sub = $Rest[0].ToLowerInvariant() }
    switch ($sub) {
        'list' {
            $h = [ordered]@{}
            foreach ($k in $script:Cfg.Keys) { $h[$k] = [ordered]@{ value = $script:Cfg[$k]; source = $script:CfgInfo.Sources[$k] } }
            $script:Res['config'] = $h
            $script:Res['configPath'] = $script:CfgInfo.Path
            $script:Res.message = 'configuração efetiva (' + $script:CfgInfo.Path + ')'
        }
        'get' {
            if ($Rest.Count -lt 2) { throw (New-JaError 2 'uso: config get <chave>') }
            $name = Get-JaConfigKeyName $Rest[1]
            if (-not $name) { throw (New-JaError 2 "chave desconhecida: $($Rest[1])") }
            $script:Res['config'] = [ordered]@{ $name = [ordered]@{ value = $script:Cfg[$name]; source = $script:CfgInfo.Sources[$name] } }
            $script:Res.message = "$name=$($script:Cfg[$name])"
        }
        'set' {
            if ($Rest.Count -lt 3) { throw (New-JaError 2 'uso: config set <chave> <valor>') }
            if ($script:IsAgent) {
                throw (New-JaError 10 'a configuração da automação é do usuário: a IA não pode alterá-la. Peça ao usuário para rodar config set no terminal dele (ou usar a interface).')
            }
            $name = Set-JaConfigValue -Key $Rest[1] -Value (($Rest[2..($Rest.Count - 1)]) -join ' ')
            $info = Read-JaConfig
            $script:Res['config'] = [ordered]@{ $name = [ordered]@{ value = $info.Values[$name]; source = $info.Sources[$name] } }
            $script:Res.message = "$name gravado em $($info.Path)"
        }
        default { throw (New-JaError 2 'uso: config list | get <chave> | set <chave> <valor>') }
    }
}

# ======================================================================= saída

function Get-HelpText {
    return @'
jvcs-ai.ps1 <comando> [argumentos] [opções]
  identity [-Test]                    identidade salva em uso (nunca a senha)
  projects                            projetos do servidor
  list [-Project p]                   módulos do projeto
  locks [-All]                        módulos em checkout (meus | todos)
  status <arquivo...> | -Project p    estado local exato contra o servidor
  checkout <arquivo...> [-Force]      checkout seguro (-Force pela IA exige -Confirmed)
  ensure-checkout <arquivo> [-CheckOnly]   para hooks (idempotente)
  checkin <arquivo...> -Comment "..." [-AllowEncodingChange]   (esta opção pela IA exige -Confirmed)
  undocheckout <arquivo...> [-Discard]   (-Discard pela IA exige -Confirmed)
  config list | get <chave> | set <chave> <valor>   (set: só humano)
Opções: -Project -Identity -Text -Agent -Confirmed -TimeoutSec -LockWaitSec -Raw
Códigos: 0 ok, 2 uso, 3 nada a fazer, 4 credencial, 5 não encontrado, 6 travado por outro,
         7 pré-condição, 8 conflito local, 9 servidor/console, 10 confirmação, 11 parcial, 12 ambiente
'@
}

function Complete-Result {
    $mods = @($script:Res.modules)
    if ($script:Res.exitCode -eq 0 -and $mods.Count -gt 0) {
        $codes = @($mods | ForEach-Object { [int]$_.exitCode } | Sort-Object -Unique)
        if ($codes.Count -eq 1) { $script:Res.exitCode = $codes[0] }
        elseif ($codes.Count -eq 2 -and ($codes -contains 0) -and ($codes -contains 3)) { $script:Res.exitCode = 0 }
        else { $script:Res.exitCode = 11 }
        if (-not $script:Res.message) {
            if ($mods.Count -eq 1) { $script:Res.message = $mods[0].message }
            else { $script:Res.message = (@($mods | ForEach-Object { "$($_.name): $($_.message)" }) -join ' | ') }
        }
    }
    $script:Res.ok = ($script:Res.exitCode -eq 0 -or $script:Res.exitCode -eq 3)
    if ($script:Warnings.Count -gt 0) { $script:Res['warnings'] = $script:Warnings }
    if ($Raw -and $script:RawOut.Count -gt 0) { $script:Res['raw'] = $script:RawOut }
}

function Format-Text {
    $sb = New-Object Text.StringBuilder
    $tag = 'ERRO'
    if ($script:Res.ok) { $tag = 'OK' }
    [void]$sb.AppendLine("[$tag $($script:Res.exitCode)] $($script:Res.command)" + $(if ($script:Res.project) { " ($($script:Res.project))" } else { '' }))
    foreach ($m in $script:Res.modules) {
        $line = '  '
        if ($null -ne $m.id) { $line += "#$($m.id) " }
        $line += [string]$m.name
        if ($m.version) { $line += " v$($m.version)" }
        if ($m.lockedBy) { $line += " lock=$($m.lockedBy)" }
        if ($m.localState) { $line += " local=$($m.localState)" }
        if ($m.Contains('state') -and $m.state) { $line += " -> $($m.state)" }
        if ($m.Contains('message') -and $m.message -and @($script:Res.modules).Count -gt 1) { $line += " : $($m.message)" }
        [void]$sb.AppendLine($line)
    }
    if ($script:Res.Contains('identity')) { foreach ($k in $script:Res.identity.Keys) { [void]$sb.AppendLine("  $k = $($script:Res.identity[$k])") } }
    if ($script:Res.Contains('projects')) { foreach ($p in $script:Res.projects) { [void]$sb.AppendLine("  #$($p.id) $($p.name) $($p.description)") } }
    if ($script:Res.Contains('config')) { foreach ($k in $script:Res.config.Keys) { [void]$sb.AppendLine("  $k = $($script:Res.config[$k].value)   [$($script:Res.config[$k].source)]") } }
    if ($script:Res.message) { [void]$sb.AppendLine($script:Res.message) }
    if ($script:Res.Contains('warnings')) { foreach ($w in $script:Res.warnings) { [void]$sb.AppendLine("aviso: $w") } }
    return $sb.ToString().TrimEnd()
}

function Write-AuditEntry {
    if (@('help', 'identity', 'config') -contains $script:Cmd -and -not ($script:Cmd -eq 'config' -and $Rest.Count -gt 0 -and $Rest[0] -ieq 'set')) { return }
    $id = $script:Ident
    $mods = New-Object System.Collections.ArrayList
    foreach ($m in $script:Res.modules) {
        [void]$mods.Add([ordered]@{ id = $m.id; name = $m.name; version = $m.version; lockedBy = $m.lockedBy; state = $m.state; exitCode = $m.exitCode })
    }
    $e = [ordered]@{
        ts          = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
        winUser     = "$env:USERDOMAIN\$env:USERNAME"
        identity    = $(if ($id) { $id.Name } else { $null })
        jvcsUser    = $(if ($id) { $id.User } else { $null })
        server      = $(if ($id) { "$($id.Host):$($id.Port)" } else { $null })
        command     = $script:Cmd
        args        = @($Rest)
        project     = $script:Res.project
        modules     = $mods
        exitCode    = $script:Res.exitCode
        message     = $script:Res.message
        agent       = $script:IsAgent
        aiAgent     = $env:AI_AGENT
        sessionId   = $env:CLAUDE_CODE_SESSION_ID
        confirmed   = $script:ConfirmedUsed
        modes       = $(if ($script:Cfg) { "checkout=$($script:Cfg.checkout);checkin=$($script:Cfg.checkin)" } else { $null })
        pid         = $PID
    }
    if ($script:Res.Contains('comment')) { $e['comment'] = $script:Res.comment }
    Write-JaAudit $e
}

# ======================================================================= principal

$script:InvocationLine = $MyInvocation.Line
try {
    $script:CfgInfo = Read-JaConfig
    $script:Cfg = $script:CfgInfo.Values
    switch -Exact ($script:Cmd) {
        'help' { $script:Res.message = (Get-HelpText) }
        'identity' { Invoke-CmdIdentity }
        'projects' { Invoke-CmdProjects }
        'list' { Invoke-CmdList }
        'locks' { Invoke-CmdLocks }
        'status' { Invoke-CmdStatus }
        'checkout' { Invoke-CmdCheckout -Ensure $false }
        'ensure-checkout' { Invoke-CmdCheckout -Ensure $true }
        'checkin' { Invoke-CmdCheckin }
        'undocheckout' { Invoke-CmdUndo }
        'config' { Invoke-CmdConfig }
        default { throw (New-JaError 2 "comando desconhecido: '$Command'. Use: jvcs-ai.ps1 help") }
    }
    Complete-Result
} catch {
    $script:Res.exitCode = Get-JaErrorCode $_ 9
    $script:Res.message = Get-JaErrorMessage $_
    Complete-Result
} finally {
    Exit-JaLock
}

Write-AuditEntry
if ($Text) { Write-Output (Format-Text) }
else { Write-Output (ConvertTo-JaJson $script:Res -Ascii) }
exit $script:Res.exitCode
