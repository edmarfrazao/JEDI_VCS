# Testes do console jvcs.exe: addmodule sem duplicar (mesma pasta na forma 8.3 e na longa),
# ligar módulo existente a outro projeto, addproject existente e removemodule ... archive confirm.
# ATENÇÃO: cria no servidor os projetos zz-teste-mod<Sufixo>.dpr e zz-teste-mod<Sufixo>d.dpr
# e os módulos x.txt e semrev.txt. Só rode contra um servidor de TESTE.
# Gravar COM BOM (PowerShell 5.1 + acentos).
param(
    [string]$Trabalho = (Join-Path $env:TEMP 'jvcs-testes'),
    [string]$Console = '',                              # padrão: bin\client\Win32\jvcs.exe do repositório
    [string]$Sufixo = (Get-Date -Format 'yyMMddHHmm')   # cada rodada cria projetos novos
)
$ErrorActionPreference = 'Stop'
$Raiz = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$runner = Join-Path $PSScriptRoot 'golden.ps1'
if (-not $Console) { $Console = Join-Path $Raiz 'bin\client\Win32\jvcs.exe' }
$Saida = Join-Path $Trabalho 'console'
$enc = [Text.Encoding]::GetEncoding(1252)
$base = "zz-teste-mod$Sufixo"
$prj = "$base.dpr"; $prj2 = "$($base)d.dpr"
$okN = 0; $falhas = 0; $pulados = 0
function Ok($c, $m) { if ($c) { "[OK] $m"; $script:okN++ } else { "[FALHA] $m"; $script:falhas++ } }
function Pular($m) { Write-Warning "[PULADO] $m"; $script:pulados++ }
function Corpo($n) { $t = [IO.File]::ReadAllText((Join-Path $Saida "$n.txt"), $enc).Replace([string][char]0, ' '); $i = $t.IndexOf('jvcs> '); if ($i -ge 0) { $t.Substring($i) } else { $t } }
function Rodar($nome, $cwd, [string[]]$linhas) { & $runner -Nome $nome -Exe $Console -Saida $Saida -Cwd $cwd -Linhas $linhas | Out-Null; Corpo $nome }
$q = [regex]::Escape($prj); $q2 = [regex]::Escape($prj2)

# pasta do projeto de teste; a forma 8.3 é pedida ao Windows (não é fixa)
$Plongo = Join-Path $Saida $base
if (Test-Path -LiteralPath $Plongo) { Remove-Item -Recurse -Force -LiteralPath $Plongo }
New-Item -ItemType Directory -Force $Plongo | Out-Null
$Plongo = (Get-Item -LiteralPath $Plongo).FullName
$Pcurto = (New-Object -ComObject Scripting.FileSystemObject).GetFolder($Plongo).ShortPath
$tem83 = ($Pcurto -and ($Pcurto -ine $Plongo))
if (-not $tem83) {
    Pular "a pasta não tem nome 8.3 (volume sem nomes curtos?): $Plongo; o addmodule usa só a forma longa"
    $Pcurto = $Plongo
}
"projetos de teste: $prj e $prj2"
"pasta longa: $Plongo"
"pasta curta: $Pcurto"
[IO.File]::WriteAllText("$Plongo\$prj", "program x;`r`nbegin`r`nend.`r`n", [Text.Encoding]::ASCII)
[IO.File]::WriteAllText("$Plongo\x.txt", "x`r`n", [Text.Encoding]::ASCII)

# 1. addmodule com a pasta atual na forma 8.3
$c = Rodar "m_add1" $Pcurto @("addproject $prj ""[zz-teste] addmodule 8.3 x longo - pode apagar""", "openproject $prj", 'addmodule x.txt', 'checkin x.txt "versao inicial"')
$m = [regex]::Match($c, 'Module added: x\.txt \(ID (\d+)\)'); Ok $m.Success 'addmodule x.txt criou o módulo'
$xid = $m.Groups[1].Value
if ($tem83) { Ok ($c -match ('(?i)Module path: ' + [regex]::Escape($Pcurto))) 'pasta gravada na forma 8.3' }

# 2. addmodule de novo, pasta na forma longa: não duplica
$c = Rodar "m_add2" $Plongo @("openproject $prj", 'addmodule x.txt', "addproject $prj", "listmodules $prj")
Ok ($xid -and $c -match "Module already in project: .*x\.txt \(ID $xid\)") 'addmodule de novo (pasta na forma longa): "Module already in project" com o mesmo ID'
Ok ($c -notmatch 'Module added') 'nenhum módulo novo criado'
Ok ($c -match "Project already exists: $q") 'addproject existente: "Project already exists"'
Ok ($c -notmatch 'addproject <project_name>') 'addproject existente sem o bloco de ajuda'
Ok ($c -match '1 module\(s\)') 'listmodules: 1 módulo no projeto'

# 3. ligar o módulo existente a outro projeto
$c = Rodar "m_link" $Plongo @("addproject $prj2 ""[zz-teste] ligar módulo existente - pode apagar""", "openproject $prj2", 'addmodule x.txt', "sharedby $xid", 'addmodule x.txt')
Ok ($xid -and $c -match "Module linked: .*x\.txt \(ID $xid\)") 'addmodule em outro projeto: "Module linked" com o mesmo ID'
Ok (($c -match $q) -and ($c -match $q2) -and ($c -match '2 project\(s\)')) "sharedby $xid mostra os dois projetos"
Ok ($xid -and $c -match "Module already in project: .*x\.txt \(ID $xid\)") 'addmodule de novo no 2o projeto: "Module already in project"'

# 4. removemodule ... archive exige confirm (módulo sem revisão)
[IO.File]::WriteAllText("$Plongo\semrev.txt", "sem revisao`r`n", [Text.Encoding]::ASCII)
$c = Rodar "m_semrev" $Plongo @("openproject $prj", 'addmodule semrev.txt')
$m = [regex]::Match($c, 'Module added: semrev\.txt \(ID (\d+)\)'); Ok $m.Success 'addmodule semrev.txt'
$sid = $m.Groups[1].Value
if ($sid) {
    $c = Rodar "m_rm1" $Plongo @("openproject $prj", "removemodule $sid archive", "listmodules $prj")
    Ok ($c -match '\[archive confirm\]') 'removemodule ... archive sem confirm: mostra a sintaxe'
    Ok (($c -notmatch 'Module removed') -and ($c -match "(?m)^$sid\s")) 'sem confirm: nada removido, o módulo continua'
    $c = Rodar "m_rm2" $Plongo @("openproject $prj", "removemodule $sid archive confirm", "listmodules $prj")
    Ok ($c -match "Module removed from archive: .*\(ID $sid\)") 'archive confirm: módulo sem revisão apagado do arquivo'
    $i = $c.LastIndexOf('jvcs> listmodules')
    Ok ($i -ge 0 -and $c.Substring($i) -notmatch "(?m)^$sid\s") 'o módulo saiu do projeto'
}
# marca a pasta para o teste da IA (untracked com pasta gravada em 8.3)
if ($tem83) { [IO.File]::WriteAllText((Join-Path $Plongo 'zz-teste-83.ok'), "$prj`r`n", [Text.Encoding]::ASCII) }

"==== OK: $okN  FALHA: $falhas  PULADO: $pulados"
if ($falhas -gt 0) { exit 1 } else { exit 0 }
