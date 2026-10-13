# JEDI VCS v2026 — cliente para Delphi 13.2

Port do **cliente** do JEDI VCS 2.5 (Beta 3) para Delphi 13.2 Florence, mantendo compilável em Delphi 11/12.
O **servidor não é portado**: o cliente novo precisa falar exatamente o mesmo protocolo do servidor 2.5 Beta 3 (Firebird).

## Origem
- Base: clone de `github.com/Libaud/JediVCS` em `D:\Delphi\JediVCS\Fontes_JediVCS_2.5` (código 2.5 de ~2012, compilava até XE2).
- O clone tinha edições de um port Lazarus. Esta árvore usa, para cada arquivo, a cópia com **menos** edições Lazarus
  e os `.dpr`/`compopt.inc` originais de `ConverterBackup`. Detalhes: `doc\common\LEIAME-Origem.md` e `doc\common\manifesto-origem.csv`.

## Estrutura (layout original do JVCS)
| Pasta | Conteúdo |
|---|---|
| `src\jedivcs` | `Jedivcs.dpr` (EXE) e `JediVCSDLL.dpr` (DLL da IDE, `IDEDLL;EXT_IDE_INTF`) + forms do cliente |
| `src\jedivcsdiff` | `JEDIVCSDiff.dpr` + forms do Diff |
| `src\jvcs` | `jvcs.dpr` (console) |
| `src\common`, `src\common\client` | units compartilhadas (como os `.dpr` esperam: `..\common\…`) |
| `src\comp\<pacote>` | componentes de terceiros que ficam locais e serão portados (midware, textdiff, mdmailslot, crc, mwtools) |
| `src\comp\_legacy` | cópia intacta do `Components\` do clone — **somente referência, fora do search path** |
| `src\packages` | pacote design-time local (TAppSrvClient/TMWBuffer) — a criar |
| `bin\client\<plat>` | saída dos binários |
| `dcu\<plat>\<cfg>` | DCUs |
| `3rdparty` | DLLs de runtime (ex.: `FVCSCrypt.dll`, a extrair do instalador 2.50 Beta 3) |
| `doc\` | `common\` (inventário, plano, origem, licenças), `client\`, `server\`, `original\` |
| `tools\` | `compilar.bat` e utilitários |
| `setup\` | instalador / registro por versão de Delphi — a criar |

## Dependências externas (instaladas no Delphi 13.2 via GetIt em 12/10/2026)
| Biblioteca | Versão | Pasta em `%USERPROFILE%\Documents\Embarcadero\Studio\37.0\CatalogRepository` |
|---|---|---|
| JCL | 2026.08 | `JEDICodeLibraryJCL-13\2026.08` |
| JVCL (só na transição; UI vai para VCL nativa) | 2026.08 | `JEDIVisualComponentLibraryJVCL-13\2026.08` |
| ICS for VCL | 9.7 | `ICS_VCL-13\9.7` |
| Virtual Treeview (JAM Software) | 8.3 | `VirtualTreeview_by_JamSoftware-13\8.3` |
| SynEdit (TurboPack) | 2025.03 | `SynEdit-13\2025.03` |
| Abbrevia (TurboPack) — ponte da fase 1; meta: `System.Zip` nativo | 2026.10 | `Abbrevia-13\2026.10` |

O `dcc32` de linha de comando não lê o Library Path da IDE; o `tools\compilar.bat` inclui esses caminhos.
Ver `doc\common\Inventario-Componentes.md`.

## Compilar
```
tools\compilar.bat [exe|dll|diff|console|all] [Debug|Release] [Win32|Win64]
```
Ver `tools\LEIAME-compilar.md`. Fase 1: somente **Win32** (FVCSCrypt.dll é 32 bits; a IDE 32 bits continua no Delphi 13).

## Status
- [x] Estrutura e fontes base (este commit)
- [ ] Dependências externas instaladas
- [ ] Midware portado (PAnsiChar, code page fixa) + teste "golden" de tráfego contra o servidor 2.5 Beta 3
- [ ] Cliente standalone compilando
- [ ] DLL da IDE + novo expert ToolsAPI (BDS 22/23/37)

## Licença
- Código do JEDI VCS: **Mozilla Public License 1.1** — ver [`LICENSE`](LICENSE) e [`doc/original/license.txt`](doc/original/license.txt).
- Algumas partes têm licença própria, indicada no cabeçalho de cada arquivo. Resumo em [`doc/common/Licencas.md`](doc/common/Licencas.md).
- **MidWare (F. Piette) — uso não comercial.** O transporte do cliente (`src/comp/midware`: `ApsCli`, `CBroker`, `RFormat`)
  é uma versão **alterada** (port Unicode para Delphi 13 / ICS 9) do MidWare, freeware **somente para uso não comercial**.
  Uso em aplicação comercial exige acordo com o autor. A substituição por um transporte próprio está planejada.

  This product is based on MidWare. Freeware source code is available at http://www.overbyte.be.
