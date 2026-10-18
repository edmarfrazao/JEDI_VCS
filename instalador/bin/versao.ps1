param([string]$Ini, [string]$Build = '', [string]$Beta = '')
# Mostra ou muda Build/StageNumber de tools\versao.ini (chamado por versao.bat), preservando o
# resto do arquivo (ASCII, CRLF). Regra: beta N = 2000 + N*10 .. 2000 + N*10 + 9 (correções).
$ErrorActionPreference = 'Stop'
$t = [IO.File]::ReadAllText($Ini, [Text.Encoding]::ASCII)
function Valor([string]$Chave) { $m = [regex]::Match($t, "(?m)^$Chave=(.*?)\r?$"); if ($m.Success) { return $m.Groups[1].Value.Trim() } return '' }
$b0 = Valor 'Build'; $s0 = Valor 'Stage'; $n0 = Valor 'StageNumber'
if (-not $Build) { "tools\versao.ini: Build=$b0, Stage=$s0, StageNumber=$n0 (2.5.0.$b0)"; exit 0 }
if ($Build -notmatch '^\d{4}$' -or [int]$Build -lt 2000 -or [int]$Build -gt 2999) { "[ERRO] Build inválido: '$Build' (2000..2999)"; exit 1 }
$n = $n0
if ($Beta) {
    if ($Beta -notmatch '^\d{1,2}$') { "[ERRO] número da beta inválido: '$Beta'"; exit 1 }
    $n = $Beta
}
if ($s0 -eq 'Beta') {
    $lo = 2000 + 10 * [int]$n
    if ([int]$Build -lt $lo -or [int]$Build -gt $lo + 9) { "[ERRO] beta $n usa os builds $lo a $($lo + 9) (doc\pt\common\Versoes.md); informe o número da beta: versao.bat $Build <beta>"; exit 1 }
}
$t = [regex]::Replace($t, '(?m)^Build=.*?(\r?)$', "Build=$Build`$1")
if ($Beta) { $t = [regex]::Replace($t, '(?m)^StageNumber=.*?(\r?)$', "StageNumber=$Beta`$1") }
[IO.File]::WriteAllText($Ini, $t, [Text.Encoding]::ASCII)
"tools\versao.ini: Build $b0 -> $Build, StageNumber $n0 -> $n. Gere de novo com instalador\bin\gerar.bat."
exit 0
