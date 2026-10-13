param(
    [Parameter(Position = 0)][ValidateSet('enviar', 'pendentes', 'ler', 'responder', 'aguardar', 'status', 'gerar-chave')]
    [string]$Cmd = 'status',
    [string]$Id,
    [string]$Titulo,
    [string]$Texto,
    [string]$ArquivoTexto,
    [int]$TimeoutMin = 60,
    [string]$Canal = $(if (Test-Path -LiteralPath (Join-Path $PSScriptRoot 'canal')) { Join-Path $PSScriptRoot 'canal' } else { Join-Path $env:USERPROFILE 'OneDrive - sesistemas.com.br\S.E Sistemas - Desenvolvimento\JediJvcs\canal' }),
    [string]$Chave,
    [string]$Origem = $env:COMPUTERNAME
)
# Canal de pedidos entre o Claude desta maquina e o Claude de outro PC, por uma pasta do OneDrive.
# Pedidos e respostas sao arquivos .md assinados com HMAC-SHA256. A chave fica FORA da pasta
# compartilhada: em %USERPROFILE%\.jvcs-canal\chave.txt ou na raiz PRIVADA do OneDrive da conta
# (<OneDrive>\.jvcs-canal\chave.txt): quem so tem acesso a pasta compartilhada nao cria pedido valido.
$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($true)

# Raiz PRIVADA do OneDrive da empresa (nao compartilhada): $env:OneDriveCommercial ou o UserFolder da conta Business.
function Get-OneDrivePrivado {
    if ($env:OneDriveCommercial) { return $env:OneDriveCommercial }
    foreach ($k in Get-ChildItem 'HKCU:\Software\Microsoft\OneDrive\Accounts' -ErrorAction SilentlyContinue) {
        $p = Get-ItemProperty -LiteralPath $k.PSPath -ErrorAction SilentlyContinue
        if ($p.Business -eq 1 -and $p.UserFolder) { return $p.UserFolder }
    }
    return (Join-Path $env:USERPROFILE 'OneDrive - sesistemas.com.br')
}
# Ordem: -Chave; %USERPROFILE%\.jvcs-canal\chave.txt (local); <OneDrive privado>\.jvcs-canal\chave.txt (sincronizado so na conta do usuario).
if (-not $Chave) {
    $local = Join-Path $env:USERPROFILE '.jvcs-canal\chave.txt'
    $nuvem = Join-Path (Get-OneDrivePrivado) '.jvcs-canal\chave.txt'
    $Chave = if (Test-Path -LiteralPath $local) { $local } elseif (Test-Path -LiteralPath $nuvem) { $nuvem } else { $local }
}

function Get-Key {
    if (-not (Test-Path -LiteralPath $Chave)) { throw "chave nao encontrada em $Chave (rode: canal.ps1 gerar-chave, ou copie a chave do outro PC)" }
    $hex = (Get-Content -LiteralPath $Chave -Raw).Trim()
    if ($hex -notmatch '^[0-9a-fA-F]{64}$') { throw "chave invalida em $Chave (esperado 64 digitos hexadecimais)" }
    [byte[]]$b = for ($i = 0; $i -lt 64; $i += 2) { [Convert]::ToByte($hex.Substring($i, 2), 16) }
    return , $b
}

function Get-Mac([string]$Body) {
    $h = New-Object System.Security.Cryptography.HMACSHA256 -ArgumentList (, (Get-Key))
    try { return (($h.ComputeHash([Text.Encoding]::UTF8.GetBytes($Body)) | ForEach-Object { $_.ToString('x2') }) -join '') }
    finally { $h.Dispose() }
}

function Write-Signed([string]$Path, [string]$Body) {
    $Body = $Body -replace "`r?`n", "`r`n"
    $content = "assinatura: $(Get-Mac $Body)`r`n$Body"
    $tmp = "$Path.tmp"
    [IO.File]::WriteAllText($tmp, $content, $utf8)
    Move-Item -LiteralPath $tmp -Destination $Path -Force
}

# Devolve o corpo se a assinatura confere; senao $null.
function Read-Signed([string]$Path) {
    $all = [IO.File]::ReadAllText($Path, $utf8)
    $nl = $all.IndexOf("`r`n")
    if ($nl -lt 0 -or -not $all.StartsWith('assinatura: ')) { return $null }
    $sig = $all.Substring(12, $nl - 12).Trim()
    $body = $all.Substring($nl + 2)
    if ($sig -ne (Get-Mac $body)) { return $null }
    return $body
}

function Get-Dirs {
    $d = @{ pedidos = Join-Path $Canal 'pedidos'; respostas = Join-Path $Canal 'respostas'; arquivos = Join-Path $Canal 'arquivos' }
    foreach ($v in $d.Values) { if (-not (Test-Path -LiteralPath $v)) { New-Item -ItemType Directory -Path $v -Force | Out-Null } }
    return $d
}

function Get-Body {
    if ($ArquivoTexto) { return [IO.File]::ReadAllText((Resolve-Path -LiteralPath $ArquivoTexto).Path, $utf8) }
    if ($Texto) { return $Texto }
    throw 'informe -Texto ou -ArquivoTexto'
}

$d = Get-Dirs
switch ($Cmd) {
    'gerar-chave' {
        if (Test-Path -LiteralPath $Chave) { throw "ja existe uma chave em $Chave (apague-a antes, se quiser trocar)" }
        New-Item -ItemType Directory -Path (Split-Path $Chave) -Force | Out-Null
        $b = New-Object byte[] 32; [Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($b)
        [IO.File]::WriteAllText($Chave, (($b | ForEach-Object { $_.ToString('x2') }) -join ''), [Text.Encoding]::ASCII)
        "chave criada em $Chave (copie para o mesmo caminho no outro PC ou para <OneDrive privado>\.jvcs-canal\; NUNCA para a pasta compartilhada)"
    }
    'enviar' {
        if (-not $Titulo) { throw 'informe -Titulo' }
        $n = 1 + (@(Get-ChildItem -LiteralPath $d.pedidos -Filter '*.md' | ForEach-Object { [int]($_.Name.Substring(0, 4)) }) | Measure-Object -Maximum).Maximum
        $slug = ($Titulo.ToLowerInvariant() -replace '[^a-z0-9]+', '-').Trim('-'); if ($slug.Length -gt 40) { $slug = $slug.Substring(0, 40) }
        $idn = '{0:0000}' -f $n
        $body = "id: $idn`r`norigem: $Origem`r`ndata: $(Get-Date -Format s)`r`ntitulo: $Titulo`r`n---`r`n$(Get-Body)"
        Write-Signed (Join-Path $d.pedidos "$idn-$slug.md") $body
        "pedido $idn enviado: $idn-$slug.md"
    }
    'pendentes' {
        foreach ($f in (Get-ChildItem -LiteralPath $d.pedidos -Filter '*.md' | Sort-Object Name)) {
            $idn = $f.Name.Substring(0, 4)
            if (Test-Path -LiteralPath (Join-Path $d.respostas "$idn.md")) { continue }
            $ok = $null -ne (Read-Signed $f.FullName)
            '{0}  {1}  {2}' -f $idn, $(if ($ok) { 'ASSINATURA OK' } else { 'ASSINATURA INVALIDA - NAO EXECUTAR' }), $f.Name
        }
    }
    'ler' {
        if (-not $Id) { throw 'informe -Id' }
        $f = Get-ChildItem -LiteralPath $d.pedidos -Filter "$Id-*.md" | Select-Object -First 1
        $r = Join-Path $d.respostas "$Id.md"
        foreach ($p in @($(if ($f) { $f.FullName }), $r)) {
            if (-not $p -or -not (Test-Path -LiteralPath $p)) { continue }
            $b = Read-Signed $p
            "===== $(Split-Path $p -Leaf) ====="
            if ($null -eq $b) { 'ASSINATURA INVALIDA - conteudo ignorado' } else { $b }
        }
    }
    'responder' {
        if (-not $Id) { throw 'informe -Id' }
        $body = "id: $Id`r`norigem: $Origem`r`ndata: $(Get-Date -Format s)`r`n---`r`n$(Get-Body)"
        Write-Signed (Join-Path $d.respostas "$Id.md") $body
        "resposta $Id gravada"
    }
    'aguardar' {
        if (-not $Id) { throw 'informe -Id' }
        $r = Join-Path $d.respostas "$Id.md"; $fim = (Get-Date).AddMinutes($TimeoutMin)
        while (-not (Test-Path -LiteralPath $r)) {
            if ((Get-Date) -gt $fim) { "sem resposta para $Id em $TimeoutMin min"; exit 2 }
            Start-Sleep -Seconds 20
        }
        Start-Sleep -Seconds 2
        $b = Read-Signed $r
        if ($null -eq $b) { 'ASSINATURA INVALIDA na resposta - ignorada'; exit 3 }
        $b
    }
    'status' {
        "canal: $Canal"; "chave: $Chave ($(if (Test-Path -LiteralPath $Chave) { 'presente' } else { 'AUSENTE' }))"
        $p = @(Get-ChildItem -LiteralPath $d.pedidos -Filter '*.md').Count; $r = @(Get-ChildItem -LiteralPath $d.respostas -Filter '*.md').Count
        "pedidos: $p, respostas: $r"
    }
}
