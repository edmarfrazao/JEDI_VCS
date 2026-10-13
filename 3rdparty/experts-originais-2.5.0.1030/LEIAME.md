# Experts originais do JEDI VCS 2.5.0.1030 (IDEs antigas)

Os 21 experts **finos** de IDE do JEDI VCS 2.5.0.1030, copiados byte a byte para o instalador do
JEDI VCS 2.5 Beta 2026 suportar as mesmas IDEs que o original suportava (Delphi 7 a 10.4 Sydney).
Eles carregam a `JvcsExternalDll.dll` **nova** (2.5.0.2026), que fica na mesma pasta. Não há fonte
destes experts em `D:\Delphi\JediVCS` (ver `doc\client\Expert-IDE-Analise.md`). Por isso eles entram
como binário de terceiros e não são recompilados.

## Origem

- Instalador oficial `JVCSv2.50ClientSetupBeta3_Refresh_till_10_4Sydney.exe` ("JVCS v2.50 Client
  Setup Beta 3 Refresh till 10.4 Sydney"), instalado em `C:\Program Files (x86)\JEDI\JVCS`.
- Todos têm `FileVersion` 2.5.0.1030, `FileDescription` "JEDI VCS IDE Expert",
  `InternalName` `JVCSIDE_DxWizard.dpr` e export `INITWIZARD0001`.
- Os hashes de `JvcsExpertBDS19/20/21.dll` são iguais aos de `..\referencia-2.5.0.1030`.
- Hashes SHA-256: [`SHA256SUMS.txt`](SHA256SUMS.txt). O `tools\gerar-instalador.bat` confere os 21
  arquivos contra esse arquivo antes de chamar o ISCC e falha se algum mudar.

## Licença

O JEDI VCS é software livre, distribuído sob a **Mozilla Public License 1.1** (MPL). O próprio expert
declara "MPL 1.1" na caixa About da IDE. O texto da licença está em `doc\original\license.txt`, e o
instalador grava esse arquivo como `license.txt` em `{app}`. Os experts são redistribuídos sem
modificação.

## Mapeamento confirmado: DLL → IDE → chave de registro

Como o mapeamento foi confirmado, por duas fontes independentes:

1. **Pacotes de runtime importados** (`tdump`): `rtl`/`vcl`/`designide<sufixo>.bpl`. O sufixo identifica
   a versão do Delphi.
2. **Log de desinstalação do instalador original** (`C:\Program Files (x86)\JEDI\JVCS\unins000.dat`).
   Ele lista os componentes `\BDS1`…`\BDS21`, os arquivos `JvcsExpertBDS<n>.dll` e as chaves
   `...\Experts` abaixo. O valor gravado é sempre **`JVCSIDEClient`** em **HKCU**.

| Arquivo | Pacotes importados | IDE | Chave (HKCU) onde o instalador registra `JVCSIDEClient` | SHA-256 (início) |
|---|---|---|---|---|
| `JvcsExpertD7.dll` | rtl70, vcl70, designide70 | Delphi 7 | `Software\Borland\Delphi\7.0\Experts` | `8273ba73…` |
| `JvcsExpertBDS1.dll` | …71 (+ vclactnband71) | C#Builder 1.0 | `Software\Borland\BDS\1.0\Experts` | `98a6da7c…` |
| `JvcsExpertBDS2.dll` | …71 | Delphi 8 for .NET | `Software\Borland\BDS\2.0\Experts` | `2f863665…` |
| `JvcsExpertBDS3.dll` | …90 (+ xmlrtl90) | Delphi 2005 | `Software\Borland\BDS\3.0\Experts` | `bbf244ae…` |
| `JvcsExpertBDS4.dll` | …100 | BDS 2006 | `Software\Borland\BDS\4.0\Experts` | `9523a366…` |
| `JvcsExpertBDS5.dll` | …100 | Delphi 2007 / RAD Studio 2007 | `Software\Borland\BDS\5.0\Experts` | `623662e7…` |
| `JvcsExpertBDS6.dll` | …120 | Delphi 2009 | `Software\CodeGear\BDS\6.0\Experts` | `7d704e82…` |
| `JvcsExpertBDS7.dll` | …140 | Delphi 2010 | `Software\CodeGear\BDS\7.0\Experts` | `bc914433…` |
| `JvcsExpertBDS8.dll` | …150 | Delphi XE | `Software\Embarcadero\BDS\8.0\Experts` | `6ece50b3…` |
| `JvcsExpertBDS9.dll` | …160 | Delphi XE2 | `Software\Embarcadero\BDS\9.0\Experts` | `9a9dd03a…` |
| `JvcsExpertBDS10.dll` | …170 | Delphi XE3 | `Software\Embarcadero\BDS\10.0\Experts` | `d7bddafe…` |
| `JvcsExpertBDS11.dll` | …180 | Delphi XE4 | `Software\Embarcadero\BDS\11.0\Experts` | `a7289a24…` |
| `JvcsExpertBDS12.dll` | …190 | Delphi XE5 | `Software\Embarcadero\BDS\12.0\Experts` | `269ce102…` |
| `JvcsExpertBDS14.dll` | …200 | Delphi XE6 | `Software\Embarcadero\BDS\14.0\Experts` | `92c98149…` |
| `JvcsExpertBDS15.dll` | …210 | Delphi XE7 | `Software\Embarcadero\BDS\15.0\Experts` | `19983bee…` |
| `JvcsExpertBDS16.dll` | …220 | Delphi XE8 | `Software\Embarcadero\BDS\16.0\Experts` | `63bed6ff…` |
| `JvcsExpertBDS17.dll` | …230 | Delphi 10 Seattle | `Software\Embarcadero\BDS\17.0\Experts` | `93e5b541…` |
| `JvcsExpertBDS18.dll` | …240 | Delphi 10.1 Berlin | `Software\Embarcadero\BDS\18.0\Experts` | `0dcebb97…` |
| `JvcsExpertBDS19.dll` | …250 | Delphi 10.2 Tokyo | `Software\Embarcadero\BDS\19.0\Experts` | `1f0f3ea8…` |
| `JvcsExpertBDS20.dll` | …260 | Delphi 10.3 Rio | `Software\Embarcadero\BDS\20.0\Experts` | `a409e1fd…` |
| `JvcsExpertBDS21.dll` | …270 | Delphi 10.4 Sydney | `Software\Embarcadero\BDS\21.0\Experts` | `f578669a…` |

Observações:

- **Não existe BDS 13.** A Embarcadero pulou esse número: o XE6 é o 14.0.
- O BDS4 e o BDS5 importam os mesmos pacotes `…100`. O Delphi 2007 era compatível em binário com os
  pacotes do 2006. O par arquivo ↔ chave vem do instalador original.
- **BDS1 (C#Builder 1.0) e BDS2 (Delphi 8 for .NET)**: são IDEs Win32 (com os pacotes `…71`) que
  editam só projetos .NET. O expert funciona com arquivos e não depende da personalidade, por isso foi
  mantido, como no original. Não há como testá-los hoje.

## Arquivos auxiliares de que os experts precisam

Os experts só procuram, na **própria pasta**, `JvcsExternalDll.dll`, depois `jedivcsexternaldll.dll` e
depois `jedivcsdll.dll`. Não há leitura de registro nem uso do search path, e o único import é
kernel32/user32 mais os pacotes da IDE. Uma varredura de strings dos 21 binários confirma que nenhum
deles cita `zipdll`, `unzdll` ou `borlndmm`. Por isso:

- `zipdll.dll`/`unzdll.dll` **não** vão para o pacote. Eram usadas pela DLL original (DelZip), e a nova
  usa o Abbrevia.
- `borlndmm.dll` **não** vai. Só os `JvcsVcsManagerD5/D6.dll` a importam (ShareMem).
- O resto do runtime é o da DLL nova, e o instalador já o coloca na pasta: `fvcscrypt.dll`, `*.jvcs`,
  `htm_rep.htm`, `*.chm` e `JEDIVCSDiff.exe`.

## O que ficou de fora: `JvcsVcsManagerD5.dll` e `JvcsVcsManagerD6.dll`

Esses dois arquivos (5,8 MB e 6,0 MB) **não** são experts finos. Cada um é o cliente JEDI VCS
2.5.0.1030 **inteiro**, compilado em Delphi 5/6 com a interface antiga `VCSIntf` (export
`INITVCS0014`, valor `VCSManager` em `...\Delphi|C++Builder\5.0|6.0\Version Control`), e importa
`borlndmm.dll`. Eles não carregam a `JvcsExternalDll.dll`. Instalar esses arquivos seria distribuir o
cliente antigo, não o núcleo 2026. Para Delphi 5/6 e C++Builder 5/6, use o instalador original
2.5.0.1030.
