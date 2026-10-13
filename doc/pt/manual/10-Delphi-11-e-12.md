# 10. Delphi 11 e 12: checklist depois de instalar

Roteiro curto para deixar o Delphi 11 Alexandria (BDS 22.0) ou o 12 Athens (BDS 23.0) prontos para compilar o
JEDI VCS 2.5 Beta 2026 e usar o expert. Detalhes: [tools\LEIAME-compilar.md](../../../tools/LEIAME-compilar.md),
[Ambiente](../common/Ambiente.md) e [Versões](../common/Versoes.md).

> **Atenção:** feche a IDE (`bds.exe`) antes de mexer em pacotes, registro ou `EnvOptions.proj`.

## 1. Instalar o Delphi

1. Instale a última atualização da versão (11.3 / 12.3), plataforma **Win32** (Win64 é opcional).
2. Abra e feche a IDE **uma vez** com o seu usuário (cria `HKCU\Software\Embarcadero\BDS\22.0` ou `23.0`;
   sem isso o instalador do JEDI VCS não registra o expert).
3. Confira: `tools\compilar.bat /delphi:11 /info` (ou `/delphi:12`) mostra `[instalado]`.

Estado em 13/10/2026: **Delphi 11.3 instalado** (`28.0.48361.3236`), ainda sem GetIt; Delphi 12 não instalado.

## 2. Bibliotecas do GetIt (para o EXE, a DLL e o console)

O expert não depende delas; o EXE, a DLL da IDE e o console sim (o Diff precisa da JCL por causa do `jedi.inc`).

| Biblioteca | No 13 (referência) | O que instalar no 11/12 |
|---|---|---|
| JCL | GetIt `JEDICodeLibraryJCL-13` 2026.08 | GetIt "JEDI Code Library" (a versão que o GetIt oferecer; se for antiga, o clone do GitHub num commit equivalente ao 2026.08) |
| JVCL | GetIt `JEDIVisualComponentLibraryJVCL-13` 2026.08 | GetIt "JEDI Visual Component Library" (mesma regra) |
| ICS for VCL | GetIt `ICS_VCL-13` 9.7 | GetIt "ICS for VCL" 9.7 (ou o SVN `icsv9`) |
| Abbrevia | GetIt `Abbrevia-13` 2026.10 | GetIt "Abbrevia" (TurboPack) |
| SynEdit / VirtualTreeView | **não** usar os do GetIt | os fixados no repositório (passo 3) |

Depois de instalar:

1. `tools\compilar.bat /delphi:11 /info` — as quatro linhas "Raiz ..." devem mostrar uma pasta (não
   `NAO ENCONTRADA`) e as pastas de DCUs `[ok]`. Se não achar, ajuste `jcl`, `jvcl`, `ics`, `abbrevia` (e
   `jcl_lib`, `catalog`) na seção `[22.0]`/`[23.0]` de `tools\versoes.ini` — os valores de lá são prováveis.
2. Anote em [Versões](../common/Versoes.md), seção 3, as versões que o GetIt instalou.
3. Se a IDE tiver instalado SynEdit/VirtualTreeView do GetIt por dependência, desinstale-os (passo 3 usa os
   fixados; duas versões no Library Path dão conflito).

## 3. SynEdit e VirtualTreeView fixados

1. Feche a IDE e rode `tools\compilar.bat /delphi:11 libs Release Win32` (e `libs Debug Win32`).
   Saída: `lib\D11\bpl\Win32\SynEditDR280.bpl`, `SynEditDD280.bpl`, `VirtualTreesR280.bpl`, `VirtualTreesD280.bpl`
   (no 12: `lib\D12\...290.bpl`). **Já feito no 11.3 em 13/10/2026.**
2. Só se for editar formulários na IDE: *Component > Install Packages > Add...* `SynEditDD280.bpl` e
   `VirtualTreesD280.bpl`; ponha `D:\Delphi\JediVCS\v2026\lib\D11\bpl\Win32` no PATH da IDE e as pastas
   `lib\D11\synedit\Win32\Release` e `lib\D11\virtualtreeview\Win32\Release` no Library Path (como no 13,
   [Ambiente](../common/Ambiente.md), seção 4).

## 4. Compilar e conferir

| Passo | Comando | Esperado |
|---|---|---|
| Expert | `tools\compilar-expert.bat /delphi:11 Release nova` | `[OK] JvcsExpertBDS22.dll`, `[OK] sem import de designide280.bpl`, `[OK] simbolos importados resolvidos` (feito no 11.3) |
| Os 4 alvos | `tools\compilar.bat /delphi:11 all Release Win32` | 4 `[OK]`; binários em `bin\client\D11\Win32` (só verificação: o distribuído é o do 13) |
| Projetos na IDE | abrir `JediVCS2026.groupproj` no Delphi 11 | compila; saída em `bin\msbuild\D11\Win32\<cfg>`; aceite a atualização do `.dproj` se a IDE pedir, **não** aceite mudanças no `.dpr` |
| MSBuild | `tools\compilar.bat /delphi:11 /msbuild all Release Win32` | mesmos tamanhos de código do passo anterior |

## 5. Expert na IDE

1. Gere o instalador no 13 (`tools\gerar-instalador.bat`): ele compila também o `JvcsExpertBDS22/23.dll` das
   versões instaladas e confere os imports de cada um. O setup registra o expert em
   `HKCU\Software\Embarcadero\BDS\22.0\Experts` (ou `23.0`), valor `JVCSIDEClient` — **só** na IDE de 32 bits.
2. Delphi 12.3: existe também a IDE de 64 bits (`bin64\bds.exe`, chave `Experts x64`); o expert é 32 bits e
   não aparece nela (o instalador não registra lá). Use a IDE de 32 bits.
3. Teste como no Delphi 13: [capítulo 03](03-Integracao-com-o-Delphi.md).

## 6. Várias atualizações (11.0–11.3, 12.0–12.3)

O expert só importa `rtl`, `vcl` e `xmlrtl` (nada de design-time), o que o faz carregar em todas as
atualizações. Para conferir uma atualização sem instalá-la: copie de lá `rtl<pkg>.bpl`, `vcl<pkg>.bpl` e
`xmlrtl<pkg>.bpl` (de `Studio\<BDS>\bin`) para `D:\Delphi\JediVCS\ref-bpl\<versão>` e rode

```
powershell -NoProfile -ExecutionPolicy Bypass -File tools\verificar-expert.ps1 ^
  -Expert bin\ideclient\Win32\JvcsExpertBDS22.dll -BplDir D:\Delphi\JediVCS\ref-bpl\11.0 -Inits
```

`[OK] ... 0 ausentes` = carrega. Política completa: [Port-DLL-IDE](../client/Port-DLL-IDE.md), seção 5A.

## 7. Pendências que dependem desta instalação

- [ ] GetIt no 11 (JCL, JVCL, ICS, Abbrevia) e `compilar.bat /delphi:11 all Release Win32` com 4 `[OK]`.
- [ ] Ajustar `[22.0]` em `tools\versoes.ini` com as pastas reais (se a procura automática não bastar).
- [ ] Abrir o `JediVCS2026.groupproj` na IDE do 11 (o `.dproj` foi validado só por MSBuild).
- [ ] Expert do 11 dentro da IDE (registro pelo instalador; teste do capítulo 03).
- [ ] Delphi 12: repetir tudo com `/delphi:12` (`[23.0]` no `versoes.ini`).
- [ ] `.bpl` de referência das atualizações anteriores (11.0–11.2, 12.0–12.2, 13.0–13.1) para o
      `verificar-expert.ps1`.
