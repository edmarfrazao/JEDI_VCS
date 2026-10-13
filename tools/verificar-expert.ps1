<#
.SYNOPSIS
  Confere se um expert (JvcsExpertBDS<nn>.dll) carrega numa versao/atualizacao do
  Delphi: compara cada simbolo que ele importa dos pacotes (.bpl) com as
  exportacoes dos .bpl de referencia.

.DESCRIPTION
  O expert e uma DLL com runtime packages (rtl, vcl, designide...). O Windows
  resolve os imports por NOME: se um simbolo importado nao existir no .bpl da IDE
  (por exemplo, compilado no 13.2 e carregado no 13.1), o LoadLibrary falha
  (erro 127) e a IDE mostra "Could not find Wizard ...". Esta ferramenta faz a
  mesma resolucao sem a IDE, com um leitor de PE proprio (sem tdump/objdump):

    - le a tabela de imports (normal e delay-load) do expert;
    - para cada DLL importada que termine em .bpl, procura o arquivo em -BplDir
      (e nas pastas padrao da versao) e le a tabela de exports;
    - lista os simbolos importados que NAO existem (= falha de carga) e os .bpl
      nao encontrados.

  Imports de DLLs do Windows (kernel32, user32...) nao sao conferidos.

.PARAMETER Expert
  Caminho do expert. Padrao: o JvcsExpertBDS*.dll mais novo de bin\ideclient\Win32.

.PARAMETER BplDir
  Pasta(s) com os .bpl de referencia (ex.: D:\Delphi\JediVCS\ref-bpl\13.1). Se
  omitida: <RAD Studio da versao>\bin e Public\Documents\Embarcadero\Studio\<v>\Bpl,
  com a versao deduzida do nome do expert (22 -> 22.0, 23 -> 23.0, 37 -> 37.0).

.PARAMETER Listar
  Mostra tambem cada pacote importado com o numero de simbolos (resumo).

.PARAMETER Simbolos
  Mostra todos os simbolos importados de cada .bpl (longo).

.PARAMETER Inits
  Lista as units cuja initialization o expert importa (@<Unit>@initialization$qqrv),
  por pacote. Com runtime packages, toda unit de pacote no grafo de uses gera um
  desses imports; uma unit nova numa atualizacao (ex.: IdeEditorControlBridge no
  13.2) impede a carga nas atualizacoes anteriores.

.PARAMETER Permitidos
  Lista de pacotes (sem sufixo, separados por virgula) que o expert pode importar,
  ex.: rtl,vcl,xmlrtl. Importar outro pacote = falha (codigo 1).

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File tools\verificar-expert.ps1 -Listar
.EXAMPLE
  tools\verificar-expert.ps1 -Expert bin\ideclient\Win32\JvcsExpertBDS37.dll -BplDir D:\Delphi\JediVCS\ref-bpl\13.1

.NOTES
  Codigo de saida: 0 = todos os simbolos resolvidos; 1 = ha simbolos ou .bpl
  ausentes (o expert NAO carrega nessa IDE); 2 = erro de uso/arquivo.
#>
[CmdletBinding()]
param(
    [string]$Expert,
    [string[]]$BplDir,
    [switch]$Listar,
    [switch]$Simbolos,
    [switch]$Inits,
    [string]$Permitidos
)

$ErrorActionPreference = 'Stop'

if (-not ('JvcsPe.Reader' -as [type])) {
    Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace JvcsPe {
  public class ImportedDll {
    public string Name;
    public bool Delay;
    public List<string> Names = new List<string>();
    public List<int> Ordinals = new List<int>();
  }

  public static class Reader {
    class Sect { public uint Va, VSize, Raw, RawSize; }

    static uint U32(byte[] b, long o) { return BitConverter.ToUInt32(b, (int)o); }
    static ushort U16(byte[] b, long o) { return BitConverter.ToUInt16(b, (int)o); }

    static long Off(List<Sect> ss, uint rva) {
      foreach (Sect s in ss) {
        uint size = Math.Max(s.VSize, s.RawSize);
        if (rva >= s.Va && rva < s.Va + size) return (long)s.Raw + (rva - s.Va);
      }
      return -1;
    }

    static string Str(byte[] b, long o) {
      if (o < 0 || o >= b.Length) return "";
      long e = o;
      while (e < b.Length && b[e] != 0) e++;
      return Encoding.ASCII.GetString(b, (int)o, (int)(e - o));
    }

    static void Header(byte[] b, out bool pe64, out long optOff, out List<Sect> ss) {
      if (b.Length < 0x40 || b[0] != 'M' || b[1] != 'Z') throw new Exception("nao e um arquivo PE (MZ)");
      long pe = U32(b, 0x3C);
      if (U32(b, pe) != 0x00004550) throw new Exception("assinatura PE ausente");
      ushort nsec = U16(b, pe + 6);
      ushort optSize = U16(b, pe + 20);
      optOff = pe + 24;
      ushort magic = U16(b, optOff);
      pe64 = magic == 0x20B;
      long secOff = optOff + optSize;
      ss = new List<Sect>();
      for (int i = 0; i < nsec; i++) {
        long so = secOff + i * 40;
        ss.Add(new Sect { VSize = U32(b, so + 8), Va = U32(b, so + 12), RawSize = U32(b, so + 16), Raw = U32(b, so + 20) });
      }
    }

    static void Dir(byte[] b, bool pe64, long optOff, int idx, out uint rva, out uint size) {
      long dd = optOff + (pe64 ? 112 : 96) + idx * 8;
      rva = U32(b, dd); size = U32(b, dd + 4);
    }

    public static bool Is64(string path) {
      byte[] b = File.ReadAllBytes(path);
      bool pe64; long opt; List<Sect> ss;
      Header(b, out pe64, out opt, out ss);
      return pe64;
    }

    public static List<ImportedDll> Imports(string path) {
      byte[] b = File.ReadAllBytes(path);
      bool pe64; long opt; List<Sect> ss;
      Header(b, out pe64, out opt, out ss);
      var res = new List<ImportedDll>();
      uint rva, size;
      // imports normais
      Dir(b, pe64, opt, 1, out rva, out size);
      if (rva != 0) {
        long d = Off(ss, rva);
        while (d >= 0) {
          uint oft = U32(b, d), name = U32(b, d + 12), ft = U32(b, d + 16);
          if (oft == 0 && name == 0 && ft == 0) break;
          var dll = new ImportedDll { Name = Str(b, Off(ss, name)), Delay = false };
          Thunks(b, ss, pe64, oft != 0 ? oft : ft, dll, false, 0);
          res.Add(dll);
          d += 20;
        }
      }
      // delay-load (IMAGE_DELAYLOAD_DESCRIPTOR: atributos, nome, hmod, IAT, INT, ...)
      Dir(b, pe64, opt, 13, out rva, out size);
      if (rva != 0) {
        long d = Off(ss, rva);
        ulong imageBase = pe64 ? BitConverter.ToUInt64(b, (int)opt + 24) : U32(b, opt + 28);
        while (d >= 0) {
          uint attr = U32(b, d), name = U32(b, d + 4), intRva = U32(b, d + 16);
          if (name == 0 && intRva == 0) break;
          bool rvaBased = (attr & 1) != 0;
          uint nameRva = rvaBased ? name : (uint)(name - imageBase);
          uint intR = rvaBased ? intRva : (uint)(intRva - imageBase);
          var dll = new ImportedDll { Name = Str(b, Off(ss, nameRva)), Delay = true };
          Thunks(b, ss, pe64, intR, dll, !rvaBased, imageBase);
          res.Add(dll);
          d += 32;
        }
      }
      return res;
    }

    static void Thunks(byte[] b, List<Sect> ss, bool pe64, uint rva, ImportedDll dll, bool vaBased, ulong imageBase) {
      long t = Off(ss, rva);
      if (t < 0) return;
      while (true) {
        ulong v = pe64 ? BitConverter.ToUInt64(b, (int)t) : U32(b, t);
        if (v == 0) break;
        bool ord = pe64 ? (v & 0x8000000000000000UL) != 0 : (v & 0x80000000UL) != 0;
        if (ord) dll.Ordinals.Add((int)(v & 0xFFFF));
        else {
          uint hn = (uint)(vaBased ? v - imageBase : v);
          dll.Names.Add(Str(b, Off(ss, hn) + 2));
        }
        t += pe64 ? 8 : 4;
      }
    }

    public static HashSet<string> Exports(string path) {
      byte[] b = File.ReadAllBytes(path);
      bool pe64; long opt; List<Sect> ss;
      Header(b, out pe64, out opt, out ss);
      var res = new HashSet<string>(StringComparer.Ordinal);
      uint rva, size;
      Dir(b, pe64, opt, 0, out rva, out size);
      if (rva == 0) return res;
      long e = Off(ss, rva);
      uint n = U32(b, e + 24), names = U32(b, e + 32);
      long no = Off(ss, names);
      for (uint i = 0; i < n; i++) res.Add(Str(b, Off(ss, U32(b, no + i * 4))));
      return res;
    }
  }
}
'@
}

# ---- expert ----------------------------------------------------------------
$root = Split-Path -Parent $PSScriptRoot
if (-not $Expert) {
    $cand = Get-ChildItem -LiteralPath (Join-Path $root 'bin\ideclient\Win32') -Filter 'JvcsExpertBDS*.dll' -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $cand) { Write-Host '[ERRO] nenhum JvcsExpertBDS*.dll em bin\ideclient\Win32 (use -Expert)'; exit 2 }
    $Expert = $cand.FullName
}
if (-not (Test-Path -LiteralPath $Expert)) { Write-Host "[ERRO] expert nao encontrado: $Expert"; exit 2 }
$Expert = (Resolve-Path -LiteralPath $Expert).Path

# ---- pastas dos .bpl -------------------------------------------------------
$bdsNum = $null
if ([IO.Path]::GetFileNameWithoutExtension($Expert) -match '(\d+)$') { $bdsNum = $Matches[1] }
if (-not $BplDir -or $BplDir.Count -eq 0) {
    if (-not $bdsNum) { Write-Host '[ERRO] nao deu para deduzir a versao pelo nome do expert: use -BplDir'; exit 2 }
    $pf86 = ${env:ProgramFiles(x86)}
    $BplDir = @(
        (Join-Path $pf86 "Embarcadero\Studio\$bdsNum.0\bin"),
        (Join-Path $env:PUBLIC "Documents\Embarcadero\Studio\$bdsNum.0\Bpl")
    )
}
$dirs = @($BplDir | Where-Object { $_ -and (Test-Path -LiteralPath $_) })
if ($dirs.Count -eq 0) { Write-Host "[ERRO] nenhuma pasta de .bpl existe: $($BplDir -join '; ')"; exit 2 }

$fv = (Get-Item -LiteralPath $Expert).VersionInfo
Write-Host "Expert : $Expert"
Write-Host ("         {0} bytes, FileVersion {1}, {2}" -f (Get-Item -LiteralPath $Expert).Length, $fv.FileVersion, $(if ([JvcsPe.Reader]::Is64($Expert)) { 'PE32+ (64 bits)' } else { 'PE32 (32 bits)' }))
Write-Host "BPLs   : $($dirs -join '; ')"
Write-Host ''

$imports = [JvcsPe.Reader]::Imports($Expert)
$missingTotal = 0
$bplMissing = 0
$symTotal = 0
$rows = @()
foreach ($dll in $imports) {
    $isBpl = $dll.Name -match '\.bpl$'
    $count = $dll.Names.Count + $dll.Ordinals.Count
    if (-not $isBpl) {
        $rows += [pscustomobject]@{ Dll = $dll.Name; Tipo = $(if ($dll.Delay) { 'delay' } else { 'sistema' }); Simbolos = $count; Ausentes = '-'; Arquivo = '(Windows, nao conferido)' }
        continue
    }
    $symTotal += $count
    $file = $null
    foreach ($d in $dirs) { $p = Join-Path $d $dll.Name; if (Test-Path -LiteralPath $p) { $file = $p; break } }
    if (-not $file) {
        $bplMissing++
        $missingTotal += $count
        $rows += [pscustomobject]@{ Dll = $dll.Name; Tipo = 'bpl'; Simbolos = $count; Ausentes = 'BPL AUSENTE'; Arquivo = '' }
        continue
    }
    $exp = [JvcsPe.Reader]::Exports($file)
    $miss = @($dll.Names | Where-Object { -not $exp.Contains($_) })
    $missingTotal += $miss.Count + $dll.Ordinals.Count
    $bv = (Get-Item -LiteralPath $file).VersionInfo.FileVersion
    $rows += [pscustomobject]@{ Dll = $dll.Name; Tipo = 'bpl'; Simbolos = $count; Ausentes = ($miss.Count + $dll.Ordinals.Count); Arquivo = "$file ($bv)" }
    if ($miss.Count -gt 0) {
        Write-Host "[AUSENTES] $($dll.Name): $($miss.Count) simbolo(s) importado(s) nao existem em $file"
        $miss | Sort-Object | ForEach-Object { Write-Host "    $_" }
    }
    if ($dll.Ordinals.Count -gt 0) { Write-Host "[AVISO] $($dll.Name): $($dll.Ordinals.Count) import(s) por ordinal (nao conferiveis)" }
    if ($Simbolos) {
        Write-Host "---- $($dll.Name) ($count)"
        $dll.Names | Sort-Object | ForEach-Object { Write-Host "    $_" }
    }
}

if ($Inits) {
    Write-Host 'Units com initialization importada (por pacote):'
    foreach ($dll in ($imports | Where-Object { $_.Name -match '\.bpl$' })) {
        $u = @($dll.Names | Where-Object { $_ -match '@initialization\$qqrv$' } | ForEach-Object { ($_ -replace '^@', '' -replace '@initialization\$qqrv$', '') -replace '@', '.' } | Sort-Object)
        Write-Host ("  {0} ({1}): {2}" -f $dll.Name, $u.Count, ($u -join ', '))
    }
    Write-Host ''
}
$notAllowed = @()
if ($Permitidos) {
    $ok = @($Permitidos -split '[,; ]+' | Where-Object { $_ } | ForEach-Object { $_.ToLower() })
    foreach ($dll in ($imports | Where-Object { $_.Name -match '\.bpl$' })) {
        $base = ($dll.Name -replace '\d+\.bpl$', '').ToLower()
        if ($ok -notcontains $base) { $notAllowed += $dll.Name }
    }
    if ($notAllowed.Count -gt 0) { Write-Host ("[NAO PERMITIDO] o expert importa {0} (permitidos: {1})" -f ($notAllowed -join ', '), ($ok -join ', ')) }
}

if ($Listar -or $missingTotal -gt 0) {
    $rows | Format-Table -AutoSize Dll, Tipo, Simbolos, Ausentes, Arquivo | Out-String -Width 220 | Write-Host
}
$pk = @($imports | Where-Object { $_.Name -match '\.bpl$' } | ForEach-Object { $_.Name })
Write-Host ("Pacotes importados: {0} ({1}); simbolos de pacotes: {2}" -f $pk.Count, ($pk -join ', '), $symTotal)
if ($missingTotal -eq 0 -and $notAllowed.Count -eq 0) {
    Write-Host '[OK] todos os simbolos importados dos .bpl existem: o LoadLibrary do expert resolve nesta versao.'
    exit 0
}
if ($missingTotal -gt 0) { Write-Host ("[FALHOU] {0} simbolo(s) sem correspondencia e {1} .bpl ausente(s): o expert NAO carrega com estes .bpl." -f $missingTotal, $bplMissing) }
if ($notAllowed.Count -gt 0) { Write-Host '[FALHOU] pacote(s) fora da lista -Permitidos' }
exit 1
