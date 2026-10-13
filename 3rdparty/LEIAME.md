# 3rdparty

Arquivos de runtime copiados da instalação oficial **JEDI VCS 2.5.0.1030** (instalador `JVCSv2.50ClientSetupBeta3_Refresh_till_10_4Sydney.exe`,
instalado em `C:\Program Files (x86)\JEDI\JVCS` em 12/10/2026).

| Arquivo | Uso | Distribuir com o cliente novo? |
|---|---|---|
| `fvcscrypt.dll` (1.0.0.19, 32 bits, fechada) | cifra a senha no login (`JVCSCrypt.pas`); o servidor compara via ServerCrypt.dll | **Sim** — copiar para `bin\client\Win32` ao lado do EXE/DLL |
| `ffdef.jvcs`, `ulist.jvcs`, `vcllist.jvcs`, `vcllistbcb.jvcs`, `verinf.jvcs` | listas/definições padrão do cliente | Sim |
| `htm_rep.htm` | modelo de relatório HTML | Sim |
| `jedivcs.chm`, `jedivcsdiff.chm` | ajuda (F1) | Sim |

**Não distribuir**: `borlndmm.dll`, `zipdll.dll`/`unzdll.dll` (DelZip, substituído pelo Abbrevia), `jedivcsreport.dll` (não existe na instalação; RTL antiga).

## referencia-2.5.0.1030\
Binários originais **só para referência e testes de compatibilidade** (não fazem parte do build):
- `JvcsExternalDll.dll` — cliente IDE original (ABI expert↔DLL); permite testar o novo expert antes do port da DLL.
- `JvcsExpertBDS19/20/21.dll` — experts originais (10.2/10.3/10.4) para engenharia reversa da ABI (ver `doc\client\Expert-IDE-Analise.md`).
- `jedivcs.exe`, `jedivcsdiff.exe`, `jvcs.exe` — cliente 2.5.0.1030 para o teste "golden" de tráfego contra o servidor 2.5 Beta 3.

## experts-originais-2.5.0.1030\
Os 21 experts finos originais (`JvcsExpertD7.dll`, `JvcsExpertBDS1..21.dll`, sem 13), que **são distribuídos** pelo instalador no componente "IDEs antigas" (Delphi 7 a 10.4), junto com a `JvcsExternalDll.dll` nova. Origem, licença, SHA-256 e o mapeamento DLL → IDE → chave estão em [experts-originais-2.5.0.1030/LEIAME.md](experts-originais-2.5.0.1030/LEIAME.md).
