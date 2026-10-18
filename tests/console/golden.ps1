# Roda um console do JEDI VCS (jvcs.exe) com /input e a senha da identidade DEFAULT pelo stdin.
# A senha sai do registro como bytes, vai direto para o stdin do processo e é apagada da memória:
# nunca vira texto, nunca vai para a linha de comando, para arquivo ou para log.
# Saída do console em <Saida>\<Nome>.txt (cp1252); o roteiro em <Saida>\<Nome>.in.txt.
# Não altera nada em HKCU\Software\JEDI\JEDIVCS\Identities (só lê a identidade DEFAULT).
param(
    [Parameter(Mandatory = $true)][string]$Nome,       # prefixo dos arquivos de saída
    [Parameter(Mandatory = $true)][string[]]$Linhas,   # linhas do /input
    [string]$Exe = '',                                 # console a usar (padrão: o compilado no repositório)
    [string]$Servidor = '',                            # padrão: HostName da identidade DEFAULT
    [int]$Porta = 0,                                   # padrão: Port da identidade DEFAULT
    [string]$Cwd = '',                                 # pasta atual do console (addmodule/checkin)
    [string]$Saida = (Join-Path $env:TEMP 'jvcs-testes\console'),
    [string]$Captura = '',                             # pasta do proxy de captura (grava prefix.txt), opcional
    [switch]$Utf8Bom                                   # grava o /input em UTF-8 com BOM (padrão: cp1252)
)
$ErrorActionPreference = 'Stop'
$Raiz = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if (-not $Exe) { $Exe = Join-Path $Raiz 'bin\client\Win32\jvcs.exe' }
if (-not (Test-Path -LiteralPath $Exe)) { throw "console não encontrado: $Exe" }
$enc = [Text.Encoding]::GetEncoding(1252)
$reg = 'HKCU:\Software\JEDI\JEDIVCS\Identities\DEFAULT'
if (-not (Test-Path -LiteralPath $reg)) { throw 'identidade DEFAULT não cadastrada (cadastre pelo cliente JEDI VCS)' }
$ident = Get-ItemProperty -LiteralPath $reg
$user = [string]$ident.User
if (-not $Servidor) { $Servidor = [string]$ident.HostName }
if (-not $Porta) { $Porta = [int]$ident.Port }
New-Item -ItemType Directory -Force $Saida | Out-Null
$in = Join-Path $Saida "$Nome.in.txt"
$encIn = $enc; if ($Utf8Bom) { $encIn = New-Object Text.UTF8Encoding($true) }
[IO.File]::WriteAllText($in, (($Linhas -join "`r`n") + "`r`n"), $encIn)
if ($Captura) { Set-Content -LiteralPath (Join-Path $Captura 'prefix.txt') -Value $Nome -Encoding ASCII }
$psi = New-Object Diagnostics.ProcessStartInfo $Exe
$psi.Arguments = "$($Servidor):$Porta /user $user /input `"$in`""
$psi.UseShellExecute = $false; $psi.CreateNoWindow = $true
$psi.RedirectStandardInput = $true; $psi.RedirectStandardOutput = $true; $psi.RedirectStandardError = $true
$psi.StandardOutputEncoding = $enc; $psi.StandardErrorEncoding = $enc
$psi.WorkingDirectory = $(if ($Cwd) { $Cwd } else { $Saida })
# com InputEncoding UTF-8 com BOM o .NET escreveria o BOM no stdin antes da senha
$old = [Console]::InputEncoding
if ($old.GetPreamble().Length -gt 0) { [Console]::InputEncoding = $enc }
try { $p = [Diagnostics.Process]::Start($psi) } finally { [Console]::InputEncoding = $old }
$o = $p.StandardOutput.ReadToEndAsync(); $e = $p.StandardError.ReadToEndAsync()
$pw = [Convert]::FromBase64String([string]$ident.Password)
$ident = $null
try { $s = $p.StandardInput.BaseStream; $s.Write($pw, 0, $pw.Length); $s.Write([byte[]](13, 10), 0, 2); $s.Flush() }
finally { [Array]::Clear($pw, 0, $pw.Length); $p.StandardInput.Close() }
if (-not $p.WaitForExit(180000)) { $p.Kill(); throw "$Nome : timeout" }
[IO.File]::WriteAllBytes((Join-Path $Saida "$Nome.txt"), $enc.GetBytes($o.Result + $e.Result))
"$Nome : código $($p.ExitCode), $(($o.Result + $e.Result).Length) caracteres"
