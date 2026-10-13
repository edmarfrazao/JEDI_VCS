<#
.SYNOPSIS
  Gera JvcsToolsAPI.pas e JvcsFileHistoryAPI.pas (copias locais do ToolsAPI.pas e
  do FileHistoryAPI.pas da instalacao do Delphi) SEM a unit DockForm, para o expert.

.DESCRIPTION
  Por que: com runtime packages, todo unit de pacote que entra no grafo de uses
  gera um import da sua initialization. O ToolsAPI.pas usa DockForm, e o grafo
  do DockForm (designide<nn>.bpl) muda entre atualizacoes do Delphi: o expert
  compilado no 13.2 importava @Ideeditorcontrolbridge@initialization$qqrv, que
  nao existe no designide370.bpl do 13.1 -> LoadLibrary falha (erro 127) e a
  IDE mostra "Could not find Wizard".

  O expert passa a compilar estas copias (unit alias ToolsAPI=JvcsToolsAPI,
  FileHistoryAPI=JvcsFileHistoryAPI no tools\compilar-expert.bat): mesmas
  interfaces, mesmos GUIDs e mesma ordem de metodos (vtable identica), so que
  TDockableForm vira TForm (o expert nao usa) e DockForm sai do uses.

  As copias vem da instalacao do Delphi de quem compila (fonte licenciada da
  Embarcadero) e sao gravadas so na pasta de saida (dcu\..., fora do git). Nada
  da Embarcadero e versionado no repositorio.

.PARAMETER Bds
  Raiz do RAD Studio (ex.: C:\Program Files (x86)\Embarcadero\Studio\37.0).
.PARAMETER Out
  Pasta de saida (criada se nao existir).
.NOTES
  Codigo de saida: 0 = OK; 1 = fonte nao encontrado ou padrao nao reconhecido.
#>
param(
    [Parameter(Mandatory = $true)][string]$Bds,
    [Parameter(Mandatory = $true)][string]$Out
)
$ErrorActionPreference = 'Stop'
$src = Join-Path $Bds 'source\ToolsAPI'
$tapi = Join-Path $src 'ToolsAPI.pas'
$fh = Join-Path $src 'FileHistoryAPI.pas'
foreach ($f in $tapi, $fh) {
    if (-not (Test-Path -LiteralPath $f)) { Write-Host "[ERRO] fonte nao encontrado: $f"; exit 1 }
}
if (-not (Test-Path -LiteralPath $Out)) { [void](New-Item -ItemType Directory -Path $Out -Force) }

# os fontes da Embarcadero sao ASCII/ANSI: le e grava em 1252 sem mudar bytes
$enc = [Text.Encoding]::GetEncoding(1252)
$hdr = "{ GERADO por tools\gerar-toolsapi.ps1 a partir de `"{0}`" - NAO EDITE e NAO VERSIONE.`r`n  Copia local do fonte da Embarcadero (instalacao de quem compila), sem a unit`r`n  DockForm: ver o cabecalho de tools\gerar-toolsapi.ps1. }`r`n"

# ---- ToolsAPI.pas -> JvcsToolsAPI.pas -----------------------------------------
$t = $enc.GetString([IO.File]::ReadAllBytes($tapi))
$n0 = $t.Length
$t = [regex]::Replace($t, '(?m)^unit ToolsAPI;', 'unit JvcsToolsAPI;')
if ($t.Length -eq $n0 -and $t -notmatch '(?m)^unit JvcsToolsAPI;') { Write-Host '[ERRO] "unit ToolsAPI;" nao encontrado'; exit 1 }
$cnt = ([regex]::Matches($t, 'TypInfo, DockForm, DesignIntf')).Count
if ($cnt -lt 1) { Write-Host '[ERRO] uses com "DockForm" nao reconhecido no ToolsAPI.pas'; exit 1 }
$t = $t.Replace('TypInfo, DockForm, DesignIntf', 'TypInfo, DesignIntf')
# alias de TDockableForm logo depois do bloco de uses ({$IFDEF MSWINDOWS} uses ... {$ELSE} uses ... {$ENDIF})
$m = [regex]::Match($t, '(?s)\{\$IFDEF MSWINDOWS\}\s*uses .*?\{\$ENDIF\}')
if (-not $m.Success) { Write-Host '[ERRO] bloco de uses do ToolsAPI.pas nao reconhecido'; exit 1 }
$alias = "`r`n`r`n// v2026: TDockableForm vinha da unit DockForm (designide); so aparece em`r`n// parametros/resultados de INTA* que o expert nao usa. Ponteiro de objeto VCL:`r`n// a vtable das interfaces nao muda.`r`ntype`r`n  TDockableForm = Vcl.Forms.TForm;"
$t = $t.Insert($m.Index + $m.Length, $alias)
[IO.File]::WriteAllBytes((Join-Path $Out 'JvcsToolsAPI.pas'), $enc.GetBytes($hdr.Replace('{0}', $tapi) + $t))

# ---- FileHistoryAPI.pas -> JvcsFileHistoryAPI.pas -----------------------------
$h = $enc.GetString([IO.File]::ReadAllBytes($fh))
if ($h -notmatch '(?m)^unit FileHistoryAPI;') { Write-Host '[ERRO] "unit FileHistoryAPI;" nao encontrado'; exit 1 }
$h = [regex]::Replace($h, '(?m)^unit FileHistoryAPI;', 'unit JvcsFileHistoryAPI;')
$h = [regex]::Replace($h, '(?m)^(uses .*?)\bToolsAPI;', '$1JvcsToolsAPI;')
[IO.File]::WriteAllBytes((Join-Path $Out 'JvcsFileHistoryAPI.pas'), $enc.GetBytes($hdr.Replace('{0}', $fh) + $h))

Write-Host "[OK] JvcsToolsAPI.pas e JvcsFileHistoryAPI.pas gerados em $Out (de $src)"
exit 0
