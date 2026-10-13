# Algoritmos e protocolo recuperados dos binários do cliente JEDI VCS 2.5.0.1030

> Escopo: engenharia reversa **estática e somente leitura** de `jvcs.exe` (console), `jedivcs.exe`
> (standalone), `jedivcsdiff.exe` e `JvcsExternalDll.dll`, todos em
> `3rdparty\referencia-2.5.0.1030` (instalador *JVCS v2.50 Client Setup Beta 3*). Nenhum binário do
> JVCS foi executado e nada foi gravado no registro.
>
> Ferramentas: um parser PE/strings/VMT escrito em C# e carregado no PowerShell (`Add-Type`), e o
> `llvm-objdump` do Delphi 13 (`Studio\37.0\bin64\llvm-objdump.exe -d --x86-asm-syntax=intel`).
> O método é o mesmo de [Expert-IDE-Analise.md](Expert-IDE-Analise.md): lista de units no recurso
> `PACKAGEINFO`, nomes de classe nas VMTs, literais `AnsiString` (cabeçalho `FF FF FF FF` + tamanho)
> e referências absolutas (o código x86 de 32 bits usa endereços absolutos, então basta procurar o
> VA em little-endian).
>
> Todos os binários têm ImageBase `$00400000` e foram compilados com **Delphi 2007 (ANSI)**. Os
> endereços citados são VAs. Para converter em offset de arquivo, use `VA - $401000 + $400` na
> seção `.text`. Em `.data`, use `VA - VA(.data) + Raw(.data)`, por exemplo `$7FC000 → $3FB200` no
> `jedivcs.exe` e `$474000 → $72800` no `jvcs.exe`.
>
> SHA-256: `jvcs.exe` = `F4E21028…D84AE829`, `jedivcs.exe` = `8EB3FD2C…7CD6B06B`.

## Resumo dos achados

| Item | Conclusão | Confiança |
|---|---|---|
| `Checksum.CRCInt` / `CRCString` | **CRC-32 IEEE padrão** (polinômio refletido `$EDB88320`, início `$FFFFFFFF`, XOR final `$FFFFFFFF`). É igual a `System.ZLib.crc32`/PKZIP: `"123456789"` → `$CBF43926`, que como `Integer` vale `-873187034`. O arquivo é lido em blocos de `$8000` com `FileOpen(fmOpenRead or fmShareDenyNone)`. `CRCString` = `'$' + IntToHex(crc, 8)`, ou a mensagem de status quando o CRC é 0 (arquivo vazio → `'OK'`). | Alta: tabela inteira conferida e algoritmo lido instrução por instrução |
| `BFCrypt.Base64Encode/Decode` | Base64 RFC 4648 padrão (`A–Z a–z 0–9 + /`, padding `=`), **sem quebra de linha**, sobre os **bytes ANSI** da string (Delphi 2007). | Alta |
| `BFCrypt.BlowFishEncode/Decode` | Biblioteca **CryptoLib** (units `Cryptcon` + `Blowunit`, classes `TCrypto` → `TBlowFish`). **Não** é DCPcrypt. Blowfish padrão de 16 rodadas em big-endian (vetores de Schneier conferem), **modo ECB**, **sem IV**, sem cabeçalho e sem campo de tamanho, **padding com zeros** até múltiplo de 8. A chave são os bytes crus de `Base64Decode(EncodeKey)`. Uma chave com menos de 8 ou mais de 65 bytes é **descartada em silêncio** (cifra com as tabelas de π sem chave). | Alta |
| Protocolo Midware | `TMWBuffer` V1.48 (FldSep `#18`, RecSep `#20`, Esc `#127`; escapes `F R C L N`, Esc+Esc; blob = Esc `'T'` `'1'`), `TAppSrvClient` V3.06, **`TWSocket` V5.31** (o inventário cita 5.28). Tudo é byte a byte (ANSI, code page ACP). `LOGIN` envia `[usuário, senha cifrada FVCSCrypt, versão, GetNowUTC]`: versão **239** no console e **250** no GUI. | Alta (separadores, escapes, versão); média (enquadramento, lido do fonte de mesma versão) |
| mwPasLex | `TmwPasLex (2.2)`, © 1998-'99 Martin Waldenburg; units `mwPasLex` e `mwPasLexTypes`; hierarquia `TmwBasePasLex` (TObject) ← `TmwPasLex` (+4 bytes, o `FAheadLex`), a mesma do CastaliaPasLex. | Média-alta (sem RTTI do enum de tokens) |

---

## 1. Unit `Checksum`: `CRCInt` e `CRCString`

### 1.1 Localização

- `jvcs.exe`: no `PACKAGEINFO` (offset `$856CD`), a unit `Checksum` aparece entre `TZHandling` e
  `JVCSClientConsts`. As rotinas estão em `.text`:
  - `CRCString` em **`$004291C8`**
  - `CRCInt` em **`$004292A8`** (termina em `$00429492`)
  - Tabela CRC em **`$00475C70`** (`.data`, offset de arquivo `$74470`), referenciada só por
    `$004293CD` (`mov ecx, [4*ecx + $475C70]`).
  - A segunda tabela idêntica em `$004767F4` (refs `$443847`, `$44386C`) é do Abbrevia, não da
    `Checksum`.
- A mesma rotina, com os mesmos literais, aparece nos outros binários:

| Binário | Tabela | Laço que usa a tabela | Literal `'File read error (FileRead = -1)'` |
|---|---|---|---|
| `jvcs.exe` | `$475C70` | `$4293CD` | `$4294F8` |
| `jedivcs.exe` | `$800764` | `$528254` | `$52837C` |
| `JvcsExternalDll.dll` | `$813F3C` | `$517B74` | `$517C9C` |
| `jedivcsdiff.exe` | `$59DCCC` | `$56197C` | `$561AA4` |

No `jedivcs.exe` conferi as constantes e a forma do laço (`$8000`, `mov edx,$40`,
`xor cl,[ebp-$18]`, `shr ebx,8 / and ebx,$FFFFFF`, `not eax`): são iguais.

### 1.2 Tabela

Primeiras entradas (little-endian no arquivo):

```
$475C70: 00000000 77073096 EE0E612C 990951BA 076DC419 706AF48F E963A535 9E6495A3
         0EDB8832 79DCB8A4 ...
última ($47606C): 2D02EF8D
```

As 256 entradas foram comparadas por programa com a tabela gerada pelo polinômio refletido
`$EDB88320`, e **todas conferem**. É a tabela CRC-32 IEEE 802.3 / PKZIP / zlib.

### 1.3 Disassembly comentado (`jvcs.exe`)

```asm
; function CRCInt(const FileName: string; var Err: string): Integer;   EAX=FileName, EDX=@Err
4292A8: push ebp / mov ebp,esp / add esp,-$18
4292B1: mov [ebp-4],edx                ; @Err
4292B4: mov esi,eax                    ; FileName
4292B6: xor eax,eax / mov [ebp-8],eax  ; Result := 0
4292BB: xor ebx,ebx                    ; flag de erro de abertura := 0
4292C0: mov edx,$42949C ; call LStrAsg ; Err := 'OK'
4292CC: call FileExists($40BDE8)       ; GetFileAttributesA, retorna False para diretório
4292D3: jne ...                        ; não existe:
4292D8:   Err := 'File not found' ; Exit (Result = 0)
4292E7: mov eax,$8000 ; call GetMem    ; Buf := GetMem($8000)
4292F4: cmp [ebp-$C],0 ; jne           ; nil -> Result 0, Err := 'Out of memory', Exit
4292FA:
42931F: mov [ebp-$18],$FFFFFFFF        ; Crc := $FFFFFFFF
        ; try
429334: mov edx,$40                    ; Mode = fmOpenRead(0) or fmShareDenyNone($40)
42933B: call FileOpen($40BB8C)         ; CreateFileA(..., OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL)
429340: mov word ptr [ebp-$E],ax       ; !!! handle guardado como WORD (16 bits)
429344: movzx eax,word ptr [ebp-$E] / inc eax / jne +  ; "if hFile = -1" nunca é verdadeiro (Word+1 <> 0)
        ; except -> ebx := -1 ; Err := 'Handle not available'
429372: test ebx,ebx / jne $42945A     ; erro de abertura -> Result 0, Err := 'Handle not available'
        ; try try
429396: mov edx,[ebp-$C] / movzx eax,word ptr [ebp-$E] / mov ecx,$8000
4293A2: call FileRead($40BBE4)         ; ReadFile; retorna -1 em erro
4293A7: mov [ebp-$14],eax              ; ReadCount
4293AA: cmp [ebp-$14],0 / jle fim_bloco
4293B0..4293E9:                        ; for i := 0 to ReadCount-1 (contador de 16 bits):
4293C3:   movzx ecx,byte ptr [ebx+ecx] ;   b := Buf[i]
4293C7:   xor cl,byte ptr [ebp-$18]    ;   idx := b xor Lo(Crc)
4293CD:   mov ecx,[4*ecx+$475C70]      ;   T[idx]
4293D4:   mov ebx,[ebp-$18] / shr ebx,8 / and ebx,$FFFFFF
4293E0:   xor ecx,ebx / mov [ebp-$18],ecx ; Crc := T[idx] xor (Crc shr 8)
4293EB: cmp [ebp-$14],0 / jg $429396   ; repete enquanto ReadCount > 0
        ; finally
4293FE: movzx eax,word ptr [ebp-$E] / push eax / call CloseHandle   ; fecha o handle TRUNCADO
429410: cmp [ebp-$14],-1 / je erro_leitura
429416: mov eax,[ebp-$18] / not eax / mov [ebp-8],eax   ; Result := not Crc
429420: erro_leitura: Result := 0 ; Err := 'File read error (FileRead = -1)'
42943C: except: Result := 0 ; Err := 'File read error (Access denied)'
429479: FreeMem(Buf)
429489: mov eax,[ebp-8] ; Result
```

```asm
; function CRCString(const FileName: string): string;   EAX=FileName, EDX=@Result
4291C8: ...
4291F3: lea edx,[ebp-4] ; call CRCInt  ; try Crc := CRCInt(FileName, Err)
42920C:   except: Result := 'Error (unknown)'  (literal em $42928C)
429225: test ebx,ebx / je $42924A
429229: lea ecx,[ebp-$C] / mov edx,8 / mov eax,ebx / call IntToHex($40B8A0)  ; IntToHex(Crc, 8)
42923E: mov edx,$4292A4 ('$') / call LStrCat3   ; Result := '$' + IntToHex(Crc, 8)
42924A: Result := Err                  ; Crc = 0 -> devolve a mensagem ('OK', 'File not found', ...)
```

Literais (`AnsiString`, refcount -1): `$42928C 'Error (unknown)'`, `$4292A4 '$'`,
`$42949C 'OK'`, `$4294A8 'File not found'`, `$4294C0 'Out of memory'`,
`$4294D8 'Handle not available'`, `$4294F8 'File read error (FileRead = -1)'`,
`$429520 'File read error (Access denied)'`. Imports conferidos: `$4078DC` → `CreateFileA`,
`$4078BC` → `CloseHandle`.

### 1.4 Pseudocódigo exato

```
CRCInt(FileName, var Err):
  Result := 0 ; Err := 'OK'
  se não FileExists(FileName): Err := 'File not found' ; sair
  Buf := GetMem($8000)                         // 'Out of memory' se nil
  Crc := $FFFFFFFF
  h := Word(FileOpen(FileName, fmOpenRead or fmShareDenyNone))   // truncado para 16 bits
  repetir
    n := FileRead(h, Buf, $8000)               // -1 em erro
    para i := 0 até n-1: Crc := T[(Buf[i] xor Crc) and $FF] xor (Crc shr 8)
  até n <= 0
  CloseHandle(h)
  se n = -1: Result := 0 ; Err := 'File read error (FileRead = -1)'
  senão     Result := Integer(not Crc)
  (exceção na leitura -> Result := 0 ; Err := 'File read error (Access denied)')
  FreeMem(Buf)

CRCString(FileName):
  try c := CRCInt(FileName, Err) except Result := 'Error (unknown)'; sair end
  se c <> 0: Result := '$' + IntToHex(c, 8)    // 8 dígitos hexadecimais maiúsculos
  senão      Result := Err                     // 'OK' (arquivo vazio), 'File not found', ...
```

### 1.5 Conclusões e peculiaridades

1. **É o CRC-32 padrão.** Equivale a `System.ZLib.crc32(0, buf, len)`, ao CRC do diretório
   central do ZIP, ao `cksum -a crc32b` e ao `CRC32()` do zlib/PKZIP. Vetores:
   `"123456789"` → `$CBF43926`, `"a"` → `$E8B7BE43`,
   `"The quick brown fox jumps over the lazy dog"` → `$414FA339`.
2. **Sinal.** `CRCInt` devolve o CRC reinterpretado como `Integer`: `$CBF43926` → `-873187034`.
   O check-in (`ChkInSingle.pas:1636`, `WriteFields(False, [CRCInt(...)])`) manda o valor como
   `vtInteger`, ou seja, `IntToStr`, **decimal com sinal**, na rede: `'-873187034'`. As comparações
   (`_StrToInt(Answer.Fields[8]) <> CRCInt(...)`) também são feitas em `Integer`. Por isso a unit
   recriada precisa de `{$R-}{$Q-}` e de cast explícito `Integer(not Crc)`.
3. **Abertura compartilhada.** O modo `$40` é `fmOpenRead or fmShareDenyNone`, então lê arquivos
   abertos na IDE. A leitura é feita em blocos de 32 KiB (`$8000`).
4. **Arquivo vazio:** `CRCInt` = 0 com `Err = 'OK'`, e `CRCString` devolve a string **`'OK'`**, não
   `'$00000000'`. O `jvcs.dpr:928` faz `StrToInt(CRCString(...))` e quebraria com `EConvertError`
   nesse caso. Na F2, use `CRCInt` ali.
5. **Defeito do original (não reproduzir):** o handle é truncado para `Word`. Com um handle ≥ `$10000`,
   o que é plausível dentro da IDE, onde roda a `JvcsExternalDll.dll`, o `ReadFile` age sobre outro
   handle. Ou ele falha (CRC 0 e `'File read error (FileRead = -1)'`), ou lê outro objeto, e o
   `CloseHandle` fecha um handle alheio. A checagem de `-1` após o `FileOpen` nunca dispara. Se o
   arquivo existe mas não abre, o resultado é 0 com `Err = 'File read error (FileRead = -1)'`, e não
   `'Handle not available'`. **Consequência para os dados:** podem existir `ORIGCRC = 0` (ou, raramente,
   valores errados) gravados por check-ins feitos pela IDE. A validação precisa tolerar isso.
6. Com `CRCString`, mensagens de erro e o `'OK'` caem no mesmo campo que o CRC. Quem compara strings
   (CompareFolders, TextComp, DiffMain) trata dois arquivos vazios como iguais (`'OK' = 'OK'`), e esse
   comportamento convém manter.

### 1.6 Proposta de implementação (Delphi 11/12/13, sem dependências)

```pascal
unit Checksum;

{ Recriação fiel da unit Checksum do JEDI VCS 2.5 (ver doc\pt\client\Algoritmos-Recuperados.md, seção 1).
  CRC-32 IEEE (poly refletido $EDB88320, init $FFFFFFFF, xorout $FFFFFFFF) = System.ZLib.crc32. }

{$R-}{$Q-}

interface

const
  CRC32_INIT = Cardinal($FFFFFFFF);

/// Atualiza o registrador CRC (sem inversões). Use CRC32_INIT no início e "not" no fim.
function CRC32Update(ACrc: Cardinal; const ABuffer; ACount: NativeInt): Cardinal;
/// CRC-32 completo de um bloco de memória.
function CRC32OfBuffer(const ABuffer; ACount: NativeInt): Cardinal;

/// Igual ao original: CRC-32 do arquivo como Integer (com sinal); 0 em erro; Err = 'OK' ou mensagem.
function CRCInt(const FileName: string; var Err: string): Integer;
/// Igual ao original: '$' + IntToHex(CRC, 8); se CRC = 0 devolve Err ('OK' para arquivo vazio).
function CRCString(const FileName: string): string;

implementation

uses
  System.SysUtils;

var
  GCrcTable: array[Byte] of Cardinal;

procedure InitCrcTable;
var
  I, K: Integer;
  C: Cardinal;
begin
  for I := 0 to 255 do
  begin
    C := Cardinal(I);
    for K := 0 to 7 do
      if (C and 1) <> 0 then
        C := $EDB88320 xor (C shr 1)
      else
        C := C shr 1;
    GCrcTable[I] := C;
  end;
end;

function CRC32Update(ACrc: Cardinal; const ABuffer; ACount: NativeInt): Cardinal;
var
  P: PByte;
begin
  Result := ACrc;
  P := @ABuffer;
  while ACount > 0 do
  begin
    Result := GCrcTable[Byte(Result xor P^)] xor (Result shr 8);
    Inc(P);
    Dec(ACount);
  end;
end;

function CRC32OfBuffer(const ABuffer; ACount: NativeInt): Cardinal;
begin
  Result := not CRC32Update(CRC32_INIT, ABuffer, ACount);
end;

function CRCInt(const FileName: string; var Err: string): Integer;
const
  cBufSize = $8000;  // igual ao original
var
  H: THandle;
  Buf: TBytes;
  N: Integer;
  Crc: Cardinal;
begin
  Result := 0;
  Err := 'OK';
  if not FileExists(FileName) then
  begin
    Err := 'File not found';
    Exit;
  end;
  H := FileOpen(FileName, fmOpenRead or fmShareDenyNone);
  if H = THandle(-1) then   // INVALID_HANDLE_VALUE, sem depender de Winapi.Windows
  begin
    // O original não detectava a falha (handle em Word); o efeito visível era este:
    Err := 'File read error (FileRead = -1)';
    Exit;
  end;
  try
    try
      SetLength(Buf, cBufSize);
      Crc := CRC32_INIT;
      repeat
        N := FileRead(H, Buf[0], cBufSize);
        if N > 0 then
          Crc := CRC32Update(Crc, Buf[0], N);
      until N <= 0;
      if N = -1 then
        Err := 'File read error (FileRead = -1)'
      else
        Result := Integer(not Crc);   // cast explícito: valores >= $80000000 ficam negativos
    except
      Result := 0;
      Err := 'File read error (Access denied)';
    end;
  finally
    FileClose(H);
  end;
end;

function CRCString(const FileName: string): string;
var
  Crc: Integer;
  Err: string;
begin
  try
    Crc := CRCInt(FileName, Err);
  except
    Exit('Error (unknown)');
  end;
  if Crc <> 0 then
    Result := '$' + IntToHex(Crc, 8)   // IntToHex(Integer, 8): 8 dígitos maiúsculos, também p/ negativos
  else
    Result := Err;
end;

initialization
  InitCrcTable;
end.
```

> A alternativa `System.ZLib.crc32(Crc, @Buf[0], N)` (com `Crc` começando em 0 e
> **sem** `not`) dá o mesmo resultado. A tabela local evita depender da assinatura exata do `crc32`
> do `System.ZLib` em cada versão.

### 1.7 Testes (derivados estaticamente)

| Entrada | `CRCInt` | `Err` | `CRCString` |
|---|---|---|---|
| arquivo com `123456789` (9 bytes ASCII) | `-873187034` | `'OK'` | `'$CBF43926'` |
| arquivo com `a` | `-390611389` | `'OK'` | `'$E8B7BE43'` |
| arquivo com `The quick brown fox jumps over the lazy dog` | `1095738169` | `'OK'` | `'$414FA339'` |
| arquivo vazio | `0` | `'OK'` | `'OK'` |
| arquivo inexistente | `0` | `'File not found'` | `'File not found'` |
| arquivo de 100 000 bytes | igual a `System.ZLib.crc32` e ao CRC que `TZipFile` grava | `'OK'` | — |

Para conferir a leitura em blocos, use também um arquivo maior que 32 KiB e compare com
`System.Hash`/`System.ZLib.crc32` sobre o arquivo inteiro de uma vez.

---

## 2. Unit `BFCrypt`: Base64 e Blowfish

### 2.1 Localização e biblioteca

- No `PACKAGEINFO` do `jedivcs.exe`, as units `HandleBlob`, **`BFCrypt`**, **`Blowunit`**,
  **`Cryptcon`** e `Yes2allDlg` aparecem em sequência. A `JvcsExternalDll.dll` tem as mesmas units.
  `jvcs.exe` e `jedivcsdiff.exe` **não** têm BFCrypt nem Blowfish, o que confirma que o console e o Diff
  não decifram blobs.
- RTTI de `Cryptcon` (`$6EADCE`…`$6EB065`):
  - `TSourceType = (SourceFile, SourceByteArray, SourceString)`
  - `TCipherMode = (ECBMode, CBCMode, CFBMode)`
  - classe `TCrypto`, com as propriedades publicadas `InputType`, `InputFilePath`,
    `OutputFilePath`, `InputString`, `InputLength`, `CipherMode` e `IVector`.
- `Blowunit`: `TBlowFish = class(TCrypto)`, VMT `$6EBA2C`, `InstanceSize = $10AC`.
- Não há `TDCP_*`, `DCPcrypt` nem `TDCP_blowfish` em nenhum binário. A biblioteca é a do tipo
  **"CryptoLib" de 1996** citada no HowToBuild (componentes `TCrypto`/`TBlowFish`), e **não a DCPcrypt**.
  Os créditos do About não citam a lib de Blowfish.
- Constantes: P-array em **`$00805824`** (offset de arquivo `$404A24`), com `243F6A88 85A308D3 13198A2E
  03707344 … 8979FB1B`; S-boxes em **`$0080586C`** (`S0[0]=D1310BA6`, `S1[0]=4B7A70E9`,
  `S2[0]=E93D5A68`, `S3[0]=3A39CE37`, `S3[255]=3AC372E6`). São os dígitos de π do Blowfish padrão.
- A `JvcsExternalDll.dll` tem a mesma checagem de tamanho de chave
  (`83 F8 08 7C 05 83 F8 41 7E`) em `$58C48B`. No `jedivcs.exe` ela fica em `$6EBBC3`.

Mapa de rotinas (`jedivcs.exe`):

| Endereço | Rotina |
|---|---|
| `$6EC28C` | `BFCrypt.Base64Encode(const S: string): string` |
| `$6EC504` | `BFCrypt.Base64Decode(const S: string): string` |
| `$6EC73C` | `BFCrypt.BlowFishEncode(Owner: TComponent; Key, InFile, OutFile: string): Boolean` |
| `$6EC7F8` | `BFCrypt.BlowFishDecode(...)`: igual à anterior, mas chama `DecipherData` |
| `$6EB210` / `$6EB2D0` | `TCrypto.EncipherData` / `DecipherData` (despacho por `InputType`) |
| `$6EB1E0` | `TCrypto.Initialize`: chave e, só em CBC/CFB, IV aleatório (`$6EB1A0`/`$6EB124`) |
| `$6EB330` / `$6EB458` | processamento de arquivo (cifra/decifra) em blocos de `$1000` |
| `$6EB30C` / `$6EB434` | despacho por modo: ECB `$6EB76C`/`$6EB7E8`, CBC `$6EB864`/`$6EB924`, CFB `$6EB55C`/`$6EB660` |
| `$6EBAA0` | `TBlowFish.Create`: `BlockSize := 8`, `GetMem(P, $48)`, `GetMem(S, $1000)` |
| `$6EBBB4` | `TBlowFish` (VMT+`$38`): checagem do tamanho da chave + tabelas + key schedule |
| `$6EBB58` | copia P/S iniciais (π) |
| `$6EBC54` | key schedule |
| `$6EBBE8` | uma rodada (função F) |
| `$6EBE04` | `Encipher` (16 rodadas, palavras nativas) |
| `$6EC1C8` / `$6EC270` | `EncryptBlock` / `DecryptBlock` (VMT+`$30`/`$34`, com troca de bytes big-endian) |

Campos de `TCrypto`/`TBlowFish` usados: `+$30 IVector: string`, `+$34` buffer do IV, `+$38 Key: string`,
`+$3C InputType: TSourceType`, `+$3D CipherMode: TCipherMode`, `+$40 InputFilePath`,
`+$44 OutputFilePath`, `+$48`/`+$4C` ponteiros de entrada/saída, `+$54 Count: Word`,
`+$56 Buffer[$1000]`, `+$1057 Block[8]`, `+$1098 BlockSize: Byte`, `+$109C P`, `+$10A0 S`.

### 2.2 Base64 (`$6EC28C` / `$6EC504`)

```asm
; Base64Encode(S): Result   (S é AnsiString: 1 char = 1 byte, code page ACP)
6EC2E6: idiv 3 ; resto r
6EC2FB: r=1 -> S := S + #0 + #0        (LStrCatN com o literal #0 em $6EC4B4)
6EC31A: r=2 -> S := S + #0
6EC32C: laço i := 1, 4, 7 ... enquanto i < Length(S):
          c1 := b0 shr 2 ; c2 := ((b0 shl 4) and $30) or (b1 shr 4)
          c3 := ((b1 shl 2) and $3C) or (b2 shr 6) ; c4 := b2 and $3F
          Result := Result + Alfa[c1] + Alfa[c2] + Alfa[c3] + Alfa[c4]     ; Alfa em $6EC4C0
6EC42B: r := LengthOriginal mod 3
          r > 0  -> Result[Length]   := '='
          r = 1  -> Result[Length-1] := '='
```

```asm
; Base64Decode(S): Result
6EC543: laço i := 1, 5, 9 ... enquanto i < Length(S):
          bK := Pos(S[i+K], Alfa) - 1         ; inválido -> -1 -> byte $FF ; Alfa em $6EC6F8
          cnt := 3
          se S[i+3] = '=' : cnt := 2 ; b3 := 0 ; se S[i+2] = '=' : cnt := 1 ; b2 := 0
          Result := Result + Chr(b0 shl 2 or b1 shr 4)
          cnt > 1 -> + Chr(b1 shl 4 or b2 shr 2)
          cnt > 2 -> + Chr(b2 shl 6 or b3)
```

- O alfabeto é o padrão, `ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/`, com
  padding `=`, sem quebra de linha e sem ignorar espaços ou CR/LF. Um caractere inválido vira `$FF`
  e corrompe o byte sem gerar erro.
- Os dados são os **bytes da `AnsiString` do Delphi 2007**, isto é, o texto na code page ACP da
  estação. Esse ponto responde à dúvida do inventário: é ANSI, não UTF-16.
- Onde é usado: `EncodeKey` (Options.pas:1857, gravado em `...\Options\EncodeKey`) e a senha da
  identidade (Create.pas:1301, `...\Identity\<n>\Password`). Os dois são só ofuscação.

### 2.3 Blowfish: chave, rodadas e ordem de bytes

```asm
6EBBB4: ; TBlowFish.SetupKey (VMT+$38)
6EBBB7: mov eax,[ebx+$38] ; Length(Key)
6EBBC3: cmp eax,8  ; jl  descarta
6EBBC8: cmp eax,$41; jle ok
6EBBCD: descarta: Key := ''           ; chave < 8 ou > 65 bytes -> apagada sem aviso
6EBBD7: call $6EBB58                  ; P := P_INIT(π) ; S := S_INIT(π)
6EBBDE: call $6EBC54                  ; key schedule (sai logo se Key = '')

6EBC54: ; key schedule
        j := 0
        para i := 0 até 17:            ; 6EBCA6..6EBD33
          w := Key[j] shl 24 or Key[(j+1) mod n] shl 16 or Key[(j+2) mod n] shl 8 or Key[(j+3) mod n]
          P[i] := P[i] xor w ; j := (j+4) mod n
        FillChar(cópia da chave, 0)
        L := 0 ; R := 0
        para i := 0,2,...,16: Encipher(L,R); P[i] := L; P[i+1] := R
        para s := 0..3, i := 0,2,...,254: Encipher(L,R); S[s,i] := L; S[s,i+1] := R

6EBBE8: ; rodada: dst := dst xor (F(src) xor P[i])
        F(x) := ((S0[x shr 24] + S1[(x shr 16) and $FF]) xor S2[(x shr 8) and $FF]) + S3[x and $FF]

6EBE04: ; Encipher(L,R)
        L := L xor P[0]
        R ^= F(L)^P[1] ; L ^= F(R)^P[2] ; ... ; L ^= F(R)^P[16]
        R := R xor P[17] ; troca(L,R)

6EC1C8: ; EncryptBlock(Block[0..7])
        L := BigEndian(Block[0..3]) ; R := BigEndian(Block[4..7])   (troca de bytes explícita)
        Encipher ; grava L,R de volta em big-endian
```

A chave é **crua**: são os bytes da string recebida, sem MD5, SHA1 ou qualquer outra derivação.
A string recebida, por sua vez, é `Base64Decode(registro EncodeKey)`, ou seja, os bytes ANSI do texto
digitado nas Options. A UI exige pelo menos 16 caracteres (Options.pas:1647). O campo do DFM não tem
`MaxLength`, então uma chave com mais de 65 bytes é aceita pela UI e **descartada pela cifra**. Nesse
caso os dados ficam "cifrados" só com as tabelas de π, o que na prática é o mesmo que não ter chave.

Os vetores oficiais de Schneier conferem com a reconstrução, que usa as tabelas lidas do binário:

| Chave | Texto claro | Cifrado | Origem |
|---|---|---|---|
| `0000000000000000` (8 bytes zero) | `0000000000000000` | `4EF997456198DD78` | vetor oficial ✔ |
| `abcdefghijklmnopqrstuvwxyz` | `BLOWFISH` | `324ED0FEF413A203` | vetor oficial ✔ |

Logo, o núcleo é o **Blowfish padrão em big-endian**, compatível com DEC, OpenSSL e DCPcrypt para
chaves de 8 a 56 bytes. Para chaves de 57 a 65 bytes, o original segue o key schedule cíclico de 72
bytes, que o DEC recusa (limite de 56 bytes).

### 2.4 Modo, IV, padding e formato do arquivo

```asm
6EC73C: ; BlowFishEncode(Owner=EAX, Key=EDX, InFile=ECX, OutFile=[EBP+8]): Boolean
6EC75E: TBlowFish.Create(Owner)
6EC777: InputFilePath  := InFile        ; +$40
6EC784: OutputFilePath := OutFile       ; +$44
6EC792: mov byte ptr [eax+$3D],0        ; CipherMode := ECBMode   (InputType fica 0 = SourceFile)
6EC799: Key := Key                      ; +$38
6EC7A8: EncipherData(False)             ; DecipherData no Decode ($6EC864)
6EC7BD: Free
6EC7CA: Beep(1000, 50)                  ; só no sucesso (import Beep em $8225A0)
        Result := True ; em exceção -> Result := False
```

```asm
6EB330: ; cifra de arquivo (InputType = SourceFile)
        AssignFile(F, InputFilePath) ; Reset(F, 1)       ; usa a variável global FileMode
        FileClose(FileCreate(OutputFilePath))             ; cria/zera a saída
        AssignFile(G, OutputFilePath) ; Reset(G, 1)
        repetir
          BlockRead(F, Buffer, $1000, n) ; Count := n ; Ultimo := n <> $1000
          ProcessaModo                                     ; ECB: $6EB76C
          BlockWrite(G, Buffer, Count, w)                  ; Count pode ter crescido (padding)
        até Ultimo ou (w <> Count) ou Eof(F)
6EB76C: ; ECB
        enquanto Count mod 8 <> 0: Buffer[Count] := 0 ; Inc(Count)   ; padding com ZEROS
        para i := 0, 8, ... até Count: Block := Buffer[i..i+7]; EncryptBlock; Buffer[i..i+7] := Block
```

O formato do `.bflck` é **ECB puro**: `cifrado = BF_ECB(texto || 0x00 × ((8 - n mod 8) mod 8))`.

- Sem cabeçalho, sem IV, sem salt e sem campo de tamanho. Tamanho = `ceil(n / 8) × 8`.
- O `BlowFishDecode` devolve o texto **com os zeros de padding** (0 a 7 bytes), porque não sabe o
  tamanho original. O resultado é o ZIP com lixo zero depois do EOCD. O Abbrevia tolera isso. No
  `System.Zip.TZipFile` é preciso validar, ou então aparar o arquivo no fim do EOCD (ver 2.6).
- Como não há IV, blocos iguais geram cifrados iguais (fraqueza do ECB). O cabeçalho `PK\3\4…` do ZIP
  sempre gera o mesmo primeiro bloco para a mesma chave e os mesmos 8 bytes iniciais.
- `HandleBlob` decide se o blob está cifrado com `VerifyZip(FS) <> atZip`, ou seja, quando o arquivo
  não começa com a assinatura ZIP.
- Peculiaridades que **não** devem ser reproduzidas:
  - Arquivo de entrada vazio: com `Count = 0`, o laço ECB (contador `Word`, teste `<>`) roda 8192
    vezes e escreve até 64 KiB além do buffer de 4 KiB dentro do heap. É corrupção de memória, mas
    nunca acontece com ZIPs.
  - O `Reset` usa o `FileMode` global (padrão `fmOpenReadWrite`), então o arquivo de entrada precisava
    de permissão de escrita.
  - O `Beep(1000, 50)` a cada arquivo cifrado ou decifrado com sucesso.

### 2.5 Proposta de implementação (Delphi 11/12/13, sem dependências)

```pascal
unit BFCrypt;

{ Recriação compatível da unit BFCrypt do JEDI VCS 2.5 (doc\pt\client\Algoritmos-Recuperados.md, seção 2).
  - Base64: alfabeto padrão, '=' de padding, sem quebra de linha, sobre BYTES.
  - Blowfish (CryptoLib TBlowFish): 16 rodadas, big-endian, ECB, sem IV, padding de zeros a múltiplo
    de 8, chave = bytes crus (8..65 bytes; fora disso o original ignora a chave). }

{$R-}{$Q-}

interface

uses
  System.SysUtils, System.Classes;

function Base64EncodeBytes(const Data: TBytes): string;
function Base64DecodeBytes(const S: string): TBytes;

/// Compatíveis com as chamadas antigas para TEXTO (senha da identidade): texto <-> bytes ACP.
function Base64Encode(const S: string): string;
function Base64Decode(const S: string): string;

/// Key: bytes crus da chave = Base64DecodeBytes(<registro EncodeKey>). NÃO passe por string Unicode.
function BlowFishEncode(Owner: TComponent; const Key: TBytes; const InFile, OutFile: string): Boolean;
function BlowFishDecode(Owner: TComponent; const Key: TBytes; const InFile, OutFile: string): Boolean;

/// Remove o padding de zeros que o BlowFishDecode deixa após o fim de um ZIP (EOCD + comentário).
function TrimZipPadding(const FileName: string): Boolean;

implementation

{$I BFCryptTables.inc}  // BF_P_INIT[0..17] e BF_S_INIT[0..3, 0..255] (Apêndice A)

const
  B64Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

{ ---------------------------------------------------------------- Base64 }

function Base64EncodeBytes(const Data: TBytes): string;
var
  N, R, I, J: Integer;
  B0, B1, B2: Byte;
begin
  N := Length(Data);
  R := N mod 3;
  SetLength(Result, ((N + 2) div 3) * 4);
  I := 0;
  J := 1;
  while I < N do
  begin
    B0 := Data[I];
    if I + 1 < N then B1 := Data[I + 1] else B1 := 0;
    if I + 2 < N then B2 := Data[I + 2] else B2 := 0;
    Result[J]     := B64Alphabet[(B0 shr 2) + 1];
    Result[J + 1] := B64Alphabet[(((B0 shl 4) and $30) or (B1 shr 4)) + 1];
    Result[J + 2] := B64Alphabet[(((B1 shl 2) and $3C) or (B2 shr 6)) + 1];
    Result[J + 3] := B64Alphabet[(B2 and $3F) + 1];
    Inc(I, 3);
    Inc(J, 4);
  end;
  if R > 0 then
    Result[Length(Result)] := '=';
  if R = 1 then
    Result[Length(Result) - 1] := '=';
end;

function B64Index(C: Char): Byte;
begin
  case C of
    'A'..'Z': Result := Ord(C) - Ord('A');
    'a'..'z': Result := Ord(C) - Ord('a') + 26;
    '0'..'9': Result := Ord(C) - Ord('0') + 52;
    '+': Result := 62;
    '/': Result := 63;
  else
    Result := $FF;  // original: Pos(c, Alfa) - 1 = -1, truncado para byte
  end;
end;

function Base64DecodeBytes(const S: string): TBytes;
var
  I, Cnt, OutLen: Integer;
  B0, B1, B2, B3: Byte;

  function Ch(Idx: Integer): Char;
  begin
    if Idx <= Length(S) then Result := S[Idx] else Result := #0;
  end;

begin
  SetLength(Result, (Length(S) div 4 + 1) * 3);
  OutLen := 0;
  I := 1;
  while I < Length(S) do       // mesma condição do original (i < Length)
  begin
    B0 := B64Index(Ch(I));
    B1 := B64Index(Ch(I + 1));
    B2 := B64Index(Ch(I + 2));
    B3 := B64Index(Ch(I + 3));
    Cnt := 3;
    if Ch(I + 3) = '=' then
    begin
      Cnt := 2;
      B3 := 0;
      if Ch(I + 2) = '=' then
      begin
        Cnt := 1;
        B2 := 0;
      end;
    end;
    Result[OutLen] := Byte((B0 shl 2) or (B1 shr 4));
    Inc(OutLen);
    if Cnt > 1 then
    begin
      Result[OutLen] := Byte((B1 shl 4) or (B2 shr 2));
      Inc(OutLen);
    end;
    if Cnt > 2 then
    begin
      Result[OutLen] := Byte((B2 shl 6) or B3);
      Inc(OutLen);
    end;
    Inc(I, 4);
  end;
  SetLength(Result, OutLen);
end;

function Base64Encode(const S: string): string;
begin
  Result := Base64EncodeBytes(TEncoding.ANSI.GetBytes(S));   // ANSI = code page ACP, como no D2007
end;

function Base64Decode(const S: string): string;
begin
  Result := TEncoding.ANSI.GetString(Base64DecodeBytes(S));
end;

{ ---------------------------------------------------------------- Blowfish }

type
  TBFState = record
    P: array[0..17] of Cardinal;
    S: array[0..3, 0..255] of Cardinal;
  end;

function BF_F(const St: TBFState; X: Cardinal): Cardinal; inline;
begin
  Result := ((St.S[0, X shr 24] + St.S[1, (X shr 16) and $FF]) xor St.S[2, (X shr 8) and $FF])
            + St.S[3, X and $FF];
end;

procedure BF_Encipher(const St: TBFState; var L, R: Cardinal);
var
  I: Integer;
  T: Cardinal;
begin
  L := L xor St.P[0];
  I := 1;
  while I <= 16 do
  begin
    R := R xor BF_F(St, L) xor St.P[I];
    L := L xor BF_F(St, R) xor St.P[I + 1];
    Inc(I, 2);
  end;
  R := R xor St.P[17];
  T := L; L := R; R := T;
end;

procedure BF_Decipher(const St: TBFState; var L, R: Cardinal);
var
  I: Integer;
  T: Cardinal;
begin
  L := L xor St.P[17];
  I := 16;
  while I >= 1 do
  begin
    R := R xor BF_F(St, L) xor St.P[I];
    L := L xor BF_F(St, R) xor St.P[I - 1];
    Dec(I, 2);
  end;
  R := R xor St.P[0];
  T := L; L := R; R := T;
end;

procedure BF_Init(var St: TBFState; const Key: TBytes);
var
  I, J, N, B: Integer;
  W, L, R: Cardinal;
begin
  Move(BF_P_INIT, St.P, SizeOf(St.P));
  Move(BF_S_INIT, St.S, SizeOf(St.S));
  N := Length(Key);
  if (N < 8) or (N > 65) then
    Exit;  // fiel ao original ($6EBBC3): chave fora de 8..65 bytes é ignorada (tabelas de π sem chave)
  J := 0;
  for I := 0 to 17 do
  begin
    W := (Cardinal(Key[J]) shl 24) or (Cardinal(Key[(J + 1) mod N]) shl 16) or
         (Cardinal(Key[(J + 2) mod N]) shl 8) or Cardinal(Key[(J + 3) mod N]);
    St.P[I] := St.P[I] xor W;
    J := (J + 4) mod N;
  end;
  L := 0;
  R := 0;
  I := 0;
  while I < 18 do
  begin
    BF_Encipher(St, L, R);
    St.P[I] := L;
    St.P[I + 1] := R;
    Inc(I, 2);
  end;
  for B := 0 to 3 do
  begin
    I := 0;
    while I < 256 do
    begin
      BF_Encipher(St, L, R);
      St.S[B, I] := L;
      St.S[B, I + 1] := R;
      Inc(I, 2);
    end;
  end;
end;

procedure BF_ProcessECB(const St: TBFState; var Buf: TBytes; Count: Integer; Encrypt: Boolean);
var
  I: Integer;
  L, R: Cardinal;
begin
  I := 0;
  while I < Count do  // Count é múltiplo de 8
  begin
    L := (Cardinal(Buf[I]) shl 24) or (Cardinal(Buf[I + 1]) shl 16) or
         (Cardinal(Buf[I + 2]) shl 8) or Cardinal(Buf[I + 3]);
    R := (Cardinal(Buf[I + 4]) shl 24) or (Cardinal(Buf[I + 5]) shl 16) or
         (Cardinal(Buf[I + 6]) shl 8) or Cardinal(Buf[I + 7]);
    if Encrypt then BF_Encipher(St, L, R) else BF_Decipher(St, L, R);
    Buf[I]     := Byte(L shr 24); Buf[I + 1] := Byte(L shr 16);
    Buf[I + 2] := Byte(L shr 8);  Buf[I + 3] := Byte(L);
    Buf[I + 4] := Byte(R shr 24); Buf[I + 5] := Byte(R shr 16);
    Buf[I + 6] := Byte(R shr 8);  Buf[I + 7] := Byte(R);
    Inc(I, 8);
  end;
end;

function BlowFishProcessFile(const Key: TBytes; const InFile, OutFile: string; Encrypt: Boolean): Boolean;
const
  cChunk = $1000;  // igual ao original (múltiplo de 8: só o último bloco recebe padding)
var
  St: TBFState;
  Src, Dst: TFileStream;
  Buf: TBytes;
  N, Padded: Integer;
begin
  Result := False;
  try
    BF_Init(St, Key);
    try
      SetLength(Buf, cChunk);
      Src := TFileStream.Create(InFile, fmOpenRead or fmShareDenyWrite);
      try
        Dst := TFileStream.Create(OutFile, fmCreate);
        try
          repeat
            N := Src.Read(Buf[0], cChunk);
            if N <= 0 then
              Break;                       // arquivo vazio -> saída vazia (o original corrompia memória)
            Padded := (N + 7) and not 7;
            if Padded > N then
              FillChar(Buf[N], Padded - N, 0);
            BF_ProcessECB(St, Buf, Padded, Encrypt);
            Dst.WriteBuffer(Buf[0], Padded);
          until N < cChunk;
        finally
          Dst.Free;
        end;
      finally
        Src.Free;
      end;
    finally
      FillChar(St, SizeOf(St), 0);
    end;
    Result := True;                         // o original também fazia Beep(1000, 50) aqui
  except
    Result := False;
  end;
end;

function BlowFishEncode(Owner: TComponent; const Key: TBytes; const InFile, OutFile: string): Boolean;
begin
  Result := BlowFishProcessFile(Key, InFile, OutFile, True);
end;

function BlowFishDecode(Owner: TComponent; const Key: TBytes; const InFile, OutFile: string): Boolean;
begin
  Result := BlowFishProcessFile(Key, InFile, OutFile, False);
end;

function TrimZipPadding(const FileName: string): Boolean;
var
  FS: TFileStream;
  Tail: TBytes;
  Size, Start: Int64;
  I, CommentLen: Integer;
  EndPos: Int64;
begin
  Result := False;
  FS := TFileStream.Create(FileName, fmOpenReadWrite or fmShareExclusive);
  try
    Size := FS.Size;
    Start := Size - (22 + $FFFF + 7);
    if Start < 0 then Start := 0;
    SetLength(Tail, Size - Start);
    FS.Position := Start;
    FS.ReadBuffer(Tail[0], Length(Tail));
    for I := Length(Tail) - 22 downto 0 do
      if (Tail[I] = $50) and (Tail[I + 1] = $4B) and (Tail[I + 2] = 5) and (Tail[I + 3] = 6) then
      begin
        CommentLen := Tail[I + 20] or (Tail[I + 21] shl 8);
        EndPos := Start + I + 22 + CommentLen;
        if (EndPos <= Size) and (Size - EndPos < 8) then
        begin
          if EndPos < Size then
            FS.Size := EndPos;
          Exit(True);
        end;
      end;
  finally
    FS.Free;
  end;
end;

end.
```

Uso na F2, em ChkInSingle e HandleBlob:
`EncodeKey := Base64DecodeBytes(jvcsReadString(..., 'EncodeKey', ''))` com `EncodeKey: TBytes`.
**Nunca** faça `string(Base64Decode(...))` seguido de `TEncoding.X.GetBytes`. A chave original são os
bytes ANSI exatos que estavam no registro, e passar por Unicode só é seguro se o texto for 100% ASCII.
O parâmetro `Owner` fica só por compatibilidade de assinatura.

### 2.6 Vetores de teste (derivados estaticamente)

Base64 (bytes ANSI):

| Entrada | `Base64Encode` |
|---|---|
| `''` | `''` |
| `M` | `TQ==` |
| `Ma` | `TWE=` |
| `Man` | `TWFu` |
| `senha123` | `c2VuaGExMjM=` |
| `ação` em cp1252 (`61 E7 E3 6F`) | `Yefjbw==` (em UTF-8 seria `YcOnw6Nv`: **diferente**) |

Blowfish ECB com padding de zeros. Todos foram calculados por uma reimplementação independente em
C# que usa as tabelas P/S **lidas do binário** e reproduz a lógica desmontada. Os dois primeiros são
os vetores oficiais de Schneier.

| # | Chave (bytes ASCII) | Entrada | Saída hex | Observação |
|---|---|---|---|---|
| T1 | 8 bytes `00` | 8 bytes `00` | `4EF997456198DD78` | oficial ✔ |
| T2 | `abcdefghijklmnopqrstuvwxyz` (26) | `BLOWFISH` | `324ED0FEF413A203` | oficial ✔ |
| T3 | `JediVCS-Key-2026` (16) | `123456789` (9) | `01F64D7FA23B2A8CF014535A2ADF6B54` (16) | o padding vira 16 bytes; decifrar dá `313233343536373839` + 7×`00` |
| T4 | `short` (5, < 8) | `ABCDEFGH` | `AF4A1E9A8427D9FE` | chave ignorada (tabelas de π) |
| T5 | `PK-test!` (8) | `50 4B 03 04` | `DF5F43CB0053CC66` | 4 bytes → 8 |
| T6 | `abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ` (62) | `BLOWFISH` | `B3BD5002F93F57F3` | chave > 56 bytes: o DEC recusaria |
| T7 | a chave de T6 + `!@#$` (66, > 65) | `ABCDEFGH` | `AF4A1E9A8427D9FE` | igual a T4: chave descartada |
| T8 | `JediVCS-Key-2026` | 4099 bytes `i mod 256` (i = 0..4098) | 4104 bytes; início `AB187019762489C68FDDAD2D2497A704`, fim `9C1C9B12775CC199B1E4B49F4D42AFCC` | atravessa o bloco de 4096 |

---

## 3. Protocolo Midware (ICS + Midware) como está no binário

### 3.1 Versões (strings de copyright, iguais nos 4 binários)

| Componente | String | Endereço no `jvcs.exe` |
|---|---|---|
| `TMWBuffer` (RFormat) | ` TMWBuffer (c) 1998-2006 F. Piette V1.48 ` | `$4398A0` |
| `TAppSrvClient` (ApsCli) | ` TAppSrvClient (c) 1998-2007 F. Piette V3.06 ` | `$43B760` |
| `TWSocket` | `TWSocket (c) 1996-2008 Francois Piette V5.31` | `$42A4A5` |

> **Divergência:** o inventário cita WSocket 5.28 no `Components\`. Os binários 2.5.0.1030 usam a
> **V5.31**. Isso não afeta o protocolo (o WSocket é só transporte), mas a F2 deve partir da V5.31
> como referência de comportamento. RFormat 1.48 e ApsCli 3.06 batem com o fonte local
> (`MWBufferVersion = 148`, `AppSrvClientVersion = 306`).

### 3.2 Separadores e escapes, confirmados em código

```asm
; TMWBuffer.Create (jvcs.exe)
439A7F: mov byte ptr [esi+$48],$12     ; FFldSep := #18 (DC2)
439A83: mov byte ptr [esi+$49],$14     ; FRecSep := #20 (DC4)
439A87: mov byte ptr [esi+$4A],$7F     ; FEscSep := #127

; TMWBuffer.WriteDataBuffer: escape byte a byte (movzx byte -> 1 char = 1 byte)
43B283: cmp al,[ebx+$4A] -> grava Esc, Esc            ; Esc   -> #127 #127
43B2AE: cmp al,[ebx+$48] -> grava Esc, 'F' ($43B2C8)  ; #18   -> #127 'F'
                          ... 'R' ($43B2F0)            ; #20   -> #127 'R'
                          ... 'C' ($43B312)            ; #13   -> #127 'C'
                          ... 'L' ($43B334)            ; #10   -> #127 'L'
                          ... 'N' ($43B356)            ; #0    -> #127 'N'

; AppendStreamField / AppendBinaryField: marcador de tipo de campo
43B55B: Buf[n] := FEscSep ; Buf[n+1] := 'T' ($43B563) ; Buf[n+2] := Chr(Ord('0') + Ord(FldType))
        ; mwBlob = 1  ->  #127 'T' '1'  antes dos dados (escapados) do blob

; FloatToStrEx (vtExtended em WriteFields/AppendFields)
43B706: xor ecx,ecx / mov edx,$12 / xor eax,eax / call FloatToStrF   ; FloatToStrF(V, ffGeneral, 18, 0)
```

Consequências:

- Um buffer novo (`Rewrite`) começa com `#127 #18 #20` (Esc, Fld, Rec), seguido de `#20 #20` e `#0`.
  O leitor lê os 3 separadores dos 3 primeiros bytes (`SetHasData`).
- **Números de ponto flutuante** (`GetNowUTC` e qualquer `TDateTime` enviado com
  `WriteFields([...Double...])`) saem com `FloatToStrF(ffGeneral, 18)` e o `DecimalSeparator` **do
  locale do cliente**. Num Windows pt-BR sai algo como `46309,5123…`. O servidor lida com isso
  (`SafeStrToFloat`), mas o cliente novo precisa reproduzir o formato ou testar o que o servidor
  aceita.
- **Code page:** o `TMWBuffer` trabalha com `PChar = PAnsiChar` e comparações de byte. O
  `FileOpen`/`CreateFile` usa a API `A`, e não há conversão de code page no caminho. Portanto **toda
  string trafega como os bytes ANSI da ACP da estação** (tipicamente 1252 no pt-BR), e o servidor
  repassa os mesmos bytes ao Firebird. Isso confirma o risco R1.

### 3.3 Enquadramento da requisição (ApsCli 3.06; versão do fonte = versão do binário)

```
<FunctionCode> ' ' <corpo do TMWBuffer a partir de HeaderSize> #13#10
corpo = #127 #18 #20  { campo (#18 campo)* #20 }*  ...   (dados escapados como em 3.2)
```

Resposta: `<status> ' ' <parâmetros>`, com status `'200'` = OK (`CrackHeader`). Datagramas
começam com `'^'`. O primeiro "linha" recebido é o banner do servidor (`DoBannerReceived` → envia a
requisição). O transporte está sem SOCKS e sem cifra/LZH, como o inventário já registrava.

### 3.4 Funções de servidor usadas

**Console (`jvcs.exe`).** O código da função é derivado do **nome da classe** (`GetFunctionCode` em
`JVCSClientObjBase`: tira o `TJVCS`, põe em maiúsculas e insere `_` antes de cada maiúscula). Por isso
quase não há literais no binário. As classes de requisição encontradas nas VMTs são:

`ADD_REMOVE_REVISION_LABEL`, `ADD_UPDATE_LABEL`, `CHECKIN_MODULE`, `CHECKOUT_ONLY_MODULE`,
`GET_BRANCH_LIST`, `GET_CHECKOUT_MODULE`, `GET_FAMILY_EXTENSIONS`, `GET_LABELS`,
`GET_LATEST_REVISIONS`, `GET_LOCKED_MODULES`, `GET_MODULE_ID`, `GET_MODULE_NAME`,
`GET_PROJECT_GROUP_INFORMATION`, `GET_PROJECT_ID`, `GET_PROJECT_INFORMATION`,
`GET_PROJECT_REFERENCES`, `GET_REVISION_LIST_BY_ID`, `GET_REVISION_STATUS`, `GET_SERVER_TIME`,
`GET_USERS`, `GET_VERSION_LIST`, `LOGIN`, `LOGOUT`, `SELECT_BRANCH`, `UNDO_CHECKOUT_MODULE`
(mais os literais `'GET_SERVER_TIME'`, `'LOGIN'` e `'LOGOUT'` em `TJVCSConnection`).

**GUI (`jedivcs.exe`; a `JvcsExternalDll.dll` tem a mesma lista).** Literais `AnsiString` com cara de
função, já filtrados dos nomes de charset e das palavras-chave dos highlighters do SynEdit:

```
ADD_NEW_MODULE ADD_NEW_PROJECT ADD_REMOVE_PROJECT_TO_GROUP ADD_REMOVE_REVISION_LABEL ADD_UPDATE_BUG
ADD_UPDATE_FILE_FAMILIES ADD_UPDATE_LABEL ADD_UPDATE_MILESTONES ADD_UPDATE_PROJECT_GROUP
ADD_UPDATE_PROJECT_REFERENCES ADD_UPDATE_TODO_ENTRIES ADD_UPDATE_USER ASSIGN_PROJECT_MILESTONE
ASSIGN_REMOVE_BUG BUGS_USED_BY CHANGE_PASSWORD CHANGE_REVISION_COMMENT CHECKIN_MODULE
CHECKOUT_ONLY_MODULE CLEAR_SERVER_LOG COPY_REVISION ENABLE_MODULE_PROJECT_BUG EXECUTE_SQL
FAMILY_USED_BY GET_ARCHIVE_TSTAMP GET_BLANK_MODULE_LIST GET_BLOB_STATUS GET_BUGS GET_BUGS_BY_MODULE
GET_BUGS_BY_PROJECT GET_CHECKOUT_MODULE GET_DESERTED_MODULES GET_FAMILY_EXTENSIONS GET_FILE_FAMILIES
GET_LABELS GET_LABELS_BY_PROJECT GET_LABELS_BY_REVISION GET_LATEST_REVISIONS GET_LATESTREVISION_BY_ID
GET_LOCKED_MODULES GET_LOG_COMMENT GET_LOG_ENTRIES GET_LOG_FILTER GET_MILESTONES GET_MODULE_HISTORY
GET_MODULE_ID GET_MODULE_NAME GET_MOST_SEVERE_BUGS GET_PROJECT_ID GET_PROJECT_INFORMATION
GET_PROJECT_LIST GET_PROJECT_MILESTONES GET_PROJECT_MODULE_LIST GET_PROJECT_REFERENCES
GET_PROJECT_RIGHT GET_PROJECT_RIGHTS GET_REVISION_COMMENT GET_REVISION_LIST GET_REVISION_LIST_BY_ID
GET_REVISION_LIST_BY_VERSION GET_REVISION_STATUS GET_ROLLBACK_REVISIONS GET_SERVER_LOG
GET_SERVER_OPTIONS GET_SERVER_TIME GET_SHARED_BY GET_SHARED_MODULES GET_SINGLE_BLOB
GET_SPACE_BY_MODULES GET_SPACE_BY_PROJECTS GET_TODO_ENTRIES GET_TODO_FILTER GET_UPDATE_DESCRIPTION
GET_USERLIST GET_USERS GET_VERSION_LIST GET_VERSION_REVISION HIDE_UNHIDE_MODULE IS_MEMBER_OF_PROJECT
LABEL_USED_BY LIVE_BACKUP LOGIN LOGOUT MERGE_VER_REV_NR MOVE_MODULE PURGE_PROJECT READ_CONFIG_DATA
REMOVE_BUG REMOVE_FILE_FAMILIES REMOVE_LABEL REMOVE_LOG_ENTRIES REMOVE_MILESTONE REMOVE_MODULE
REMOVE_PROJECT REMOVE_PROJECT_GROUP REMOVE_PROJECT_MILESTONE REMOVE_REVISION REMOVE_TODO_ENTRIES
REMOVE_USER REMOVE_VERSION RENAME_MODULE RENAME_PROJECT RESTORE_PROJECT SEARCH_MODULES
SET_PROJECT_RIGHTS SET_SERVER_OPTIONS UNDO_CHECKOUT_MODULE WHOAMI
```

Funções que o GUI usa **só pelas classes TJVCS*** (nome derivado): `ADD_BRANCH`,
`ADD_UPDATE_PROPERTIES`, `GET_BRANCH_LIST`, `GET_BRANCHPOINT_REVISIONS`, `GET_LABELS_BY_MODULE`,
`GET_MODULE_REVISION_PROPERTIES`, `GET_PROPERTIES`, `GET_PROPERTY_LIST`, `GET_SUPPORTED_FUNCTIONS`,
`REMOVE_BRANCH`, `SELECT_BRANCH`. As demais classes (`GetArchiveTstamp`, `GetBugsByModule`, …) repetem
literais da lista acima. Essa lista confere com o `grep FunctionCode := '...'` em `src\jedivcs`.

### 3.5 O que o `LOGIN` envia (risco R5)

Antes do `LOGIN`, o cliente chama `GET_SERVER_TIME`. A senha é cifrada pela `FVCSCrypt.dll`
(`fvcsCliEnCrypt2(Senha, ServerTimestamp)`) e esse algoritmo está fora deste escopo.

**Console (`jvcs.exe`, `TJVCSConnection` → `TJVCSLogin`):**

```asm
4652C2: mov cl,$32 ; call ShortStrAsg   ; UserName     : string[50]   (Login +$80)
4652E0: mov cl,$C8 ; call ShortStrAsg   ; UserPassword : string[200]  (Login +$B3)
4652E7: mov dword ptr [esi+$17C],$EF    ; ClientVersion := 239
4652F1: ServerTimestamp := FLoginTime   ; (de GET_SERVER_TIME)
```

Registro único: `WriteFields(True, [UserName, fvcsCliEnCrypt2(Senha, ServerTimestamp), 239, GetNowUTC])`.

**GUI (`jedivcs.exe`, Create.pas, `$732D6D`…`$732E39`):** quatro chamadas `WriteFields` (a primeira
com `True` abre o registro), com estes tipos de `TVarRec`:

| Campo | Tipo | Valor |
|---|---|---|
| 1 | `vtAnsiString` (11) | usuário |
| 2 | `vtString` (4, ShortString) | `EncryptPassword` (FVCSCrypt) |
| 3 | `vtInteger` (0) | `GetJVCSAppProductVersionInt` (`$57455C`): `Maj*100 + Min*10 + Release` (`imul ebx,eax,$64` em `$5745F0`) a partir do **ProductVersion `2.5.0.0`** do VERSIONINFO, ou seja, **250** |
| 4 | `vtExtended` (3) | `GetNowUTC` (`TDateTime` em `FloatToStrF(ffGeneral, 18)`, com o separador decimal do locale) |

No fio, o `LOGIN` fica assim (pt-BR, ACP 1252, sem escapes necessários):

```
"LOGIN " #127 #18 #20 "usuario" #18 "<senha cifrada>" #18 "250" #18 "46309,51234..." #20 ... #13#10
```

As linhas de bytes exatas, incluindo os `#20` de fim e o posicionamento do `#0`, estão em
`TMWBuffer.Rewrite/WriteFields`, e o cliente novo deve **copiar esse comportamento do RFormat 1.48**.
Recomendação para a F2: enviar **250** no GUI/DLL e **239** no console (os valores que o servidor 2.5
já aceita hoje), até a validação dizer se o servidor checa um mínimo.

---

## 4. mwPasLex

Evidências no `jedivcs.exe` (e na DLL):

- Units `mwPasLex` e `mwPasLexTypes` no `PACKAGEINFO` (`$4959FF`, `$495A0A`).
- Nos créditos do About (DFM, offset `$4AA231`): *"Pascal Parser/ Tokenizer: TmwPasLex (2.2) Copyright ©
  1998-'99 by Martin Waldenburg"*.
- Hierarquia pelas VMTs:

| Classe | VMT | InstanceSize | Pai |
|---|---|---|---|
| `TmwBasePasLex` | `$736D4C` | `$E90` | `TObject` |
| `TmwPasLex` | `$736DD8` | `$E94` | `TmwBasePasLex` |

  `TmwPasLex` acrescenta exatamente 4 bytes (um ponteiro), que é o `FAheadLex: TmwBasePasLex` do
  desenho `TmwPasLex = class(TmwBasePasLex)` com `AheadNext`/`AheadTokenID`. O
  **CastaliaPasLex tem essa mesma hierarquia e esses mesmos nomes**, o que confirma a escolha do
  inventário.
- O enum `TptTokenKind` não tem RTTI no binário (não é publicado), então não dá para comparar a lista
  de tokens. A comparação precisa ser funcional (seção 5).
- `jvcs.exe` não usa mwPasLex. No `jedivcsdiff.exe` aparece só a string, sem as units.

---

## 5. O que ainda precisa ser validado com dados reais (teste de quinta-feira, 15/10/2026)

1. **CRC (R7):** para uma amostra ampla de módulos, compare `BLOBS.ORIGCRC` (`Integer` com sinal) com
   o `CRCInt` novo do arquivo extraído da revisão e com o CRC do diretório central do ZIP do blob.
   Separe e explique:
   - casos com `ORIGCRC = 0` (arquivos vazios ou o defeito do handle `Word` em check-ins pela IDE);
   - divergências por expansão de keywords.
2. **Base64/chave (R10):** **sem gravar no registro**, leia de uma estação 2.5 Beta 3 os valores
   `...\Options\EncodeKey`, `...\Options\EncryptModuleData` e `...\Identity\*\Password`. Decodifique
   com `Base64DecodeBytes` e confira que o texto em ACP é o esperado. Registre o tamanho da chave
   (fora de 8..65 bytes = sem chave efetiva).
3. **Blowfish (R10):** varra `BLOBS.FILEDATA`. Os blobs que não começam com `50 4B 03 04` devem ter
   tamanho múltiplo de 8. Para cada um, decifre com a chave da estação e confira se começa com
   `PK\3\4`. Abra com `TZipFile` antes e depois do `TrimZipPadding`. Se nenhum blob estiver cifrado,
   desative a opção na F2 e mantenha só a leitura.
4. **Protocolo (R1, R5):** capture com Wireshark um `GET_SERVER_TIME` + `LOGIN` do cliente 2.5 contra o
   servidor e confira:
   - o cabeçalho `LOGIN `, os bytes `#127 #18 #20`, o `CRLF` final e o separador decimal do
     `GetNowUTC`;
   - a versão **250** (GUI) e **239** (console);
   - os campos de resposta (`Fields[0..6]`).
   Teste também um nome de usuário ou comentário acentuado para confirmar que os bytes vão em cp1252.
5. **Versão mínima (R5):** veja se o servidor recusa `ClientVersion` abaixo de algum limite (por
   exemplo, mande 249 e 251 num servidor de teste, nunca no de produção).
6. **mwPasLex:** compare a saída de UsedUnits/ProjDependencies do cliente 2.5 com a da F2 (com o
   CastaliaPasLex e `UseDefines := False`) em 3 ou 4 projetos reais com `{$IFDEF}` e `{$I}`.

---

## Apêndice A: tabelas do Blowfish (`BFCryptTables.inc`)

Lidas byte a byte de `jedivcs.exe` (`.data`, VA `$00805824`, offset `$404A24`, 18 + 1024 `Cardinal`
little-endian). Coincidem com as constantes padrão do Blowfish (dígitos hexadecimais de π) e
reproduzem os vetores oficiais T1/T2.

```pascal
const
  // jedivcs.exe, VA $00805824 (offset de arquivo $404A24): P-array (18 x Cardinal)
  BF_P_INIT: array[0..17] of Cardinal = (
    $243F6A88, $85A308D3, $13198A2E, $03707344, $A4093822, $299F31D0,
    $082EFA98, $EC4E6C89, $452821E6, $38D01377, $BE5466CF, $34E90C6C,
    $C0AC29B7, $C97C50DD, $3F84D5B5, $B5470917, $9216D5D9, $8979FB1B
  );
  // VA $0080586C (offset $404A6C): S-boxes (4 x 256 x Cardinal)
  BF_S_INIT: array[0..3, 0..255] of Cardinal = (
    ( // S0
      $D1310BA6, $98DFB5AC, $2FFD72DB, $D01ADFB7, $B8E1AFED, $6A267E96,
      $BA7C9045, $F12C7F99, $24A19947, $B3916CF7, $0801F2E2, $858EFC16,
      $636920D8, $71574E69, $A458FEA3, $F4933D7E, $0D95748F, $728EB658,
      $718BCD58, $82154AEE, $7B54A41D, $C25A59B5, $9C30D539, $2AF26013,
      $C5D1B023, $286085F0, $CA417918, $B8DB38EF, $8E79DCB0, $603A180E,
      $6C9E0E8B, $B01E8A3E, $D71577C1, $BD314B27, $78AF2FDA, $55605C60,
      $E65525F3, $AA55AB94, $57489862, $63E81440, $55CA396A, $2AAB10B6,
      $B4CC5C34, $1141E8CE, $A15486AF, $7C72E993, $B3EE1411, $636FBC2A,
      $2BA9C55D, $741831F6, $CE5C3E16, $9B87931E, $AFD6BA33, $6C24CF5C,
      $7A325381, $28958677, $3B8F4898, $6B4BB9AF, $C4BFE81B, $66282193,
      $61D809CC, $FB21A991, $487CAC60, $5DEC8032, $EF845D5D, $E98575B1,
      $DC262302, $EB651B88, $23893E81, $D396ACC5, $0F6D6FF3, $83F44239,
      $2E0B4482, $A4842004, $69C8F04A, $9E1F9B5E, $21C66842, $F6E96C9A,
      $670C9C61, $ABD388F0, $6A51A0D2, $D8542F68, $960FA728, $AB5133A3,
      $6EEF0B6C, $137A3BE4, $BA3BF050, $7EFB2A98, $A1F1651D, $39AF0176,
      $66CA593E, $82430E88, $8CEE8619, $456F9FB4, $7D84A5C3, $3B8B5EBE,
      $E06F75D8, $85C12073, $401A449F, $56C16AA6, $4ED3AA62, $363F7706,
      $1BFEDF72, $429B023D, $37D0D724, $D00A1248, $DB0FEAD3, $49F1C09B,
      $075372C9, $80991B7B, $25D479D8, $F6E8DEF7, $E3FE501A, $B6794C3B,
      $976CE0BD, $04C006BA, $C1A94FB6, $409F60C4, $5E5C9EC2, $196A2463,
      $68FB6FAF, $3E6C53B5, $1339B2EB, $3B52EC6F, $6DFC511F, $9B30952C,
      $CC814544, $AF5EBD09, $BEE3D004, $DE334AFD, $660F2807, $192E4BB3,
      $C0CBA857, $45C8740F, $D20B5F39, $B9D3FBDB, $5579C0BD, $1A60320A,
      $D6A100C6, $402C7279, $679F25FE, $FB1FA3CC, $8EA5E9F8, $DB3222F8,
      $3C7516DF, $FD616B15, $2F501EC8, $AD0552AB, $323DB5FA, $FD238760,
      $53317B48, $3E00DF82, $9E5C57BB, $CA6F8CA0, $1A87562E, $DF1769DB,
      $D542A8F6, $287EFFC3, $AC6732C6, $8C4F5573, $695B27B0, $BBCA58C8,
      $E1FFA35D, $B8F011A0, $10FA3D98, $FD2183B8, $4AFCB56C, $2DD1D35B,
      $9A53E479, $B6F84565, $D28E49BC, $4BFB9790, $E1DDF2DA, $A4CB7E33,
      $62FB1341, $CEE4C6E8, $EF20CADA, $36774C01, $D07E9EFE, $2BF11FB4,
      $95DBDA4D, $AE909198, $EAAD8E71, $6B93D5A0, $D08ED1D0, $AFC725E0,
      $8E3C5B2F, $8E7594B7, $8FF6E2FB, $F2122B64, $8888B812, $900DF01C,
      $4FAD5EA0, $688FC31C, $D1CFF191, $B3A8C1AD, $2F2F2218, $BE0E1777,
      $EA752DFE, $8B021FA1, $E5A0CC0F, $B56F74E8, $18ACF3D6, $CE89E299,
      $B4A84FE0, $FD13E0B7, $7CC43B81, $D2ADA8D9, $165FA266, $80957705,
      $93CC7314, $211A1477, $E6AD2065, $77B5FA86, $C75442F5, $FB9D35CF,
      $EBCDAF0C, $7B3E89A0, $D6411BD3, $AE1E7E49, $00250E2D, $2071B35E,
      $226800BB, $57B8E0AF, $2464369B, $F009B91E, $5563911D, $59DFA6AA,
      $78C14389, $D95A537F, $207D5BA2, $02E5B9C5, $83260376, $6295CFA9,
      $11C81968, $4E734A41, $B3472DCA, $7B14A94A, $1B510052, $9A532915,
      $D60F573F, $BC9BC6E4, $2B60A476, $81E67400, $08BA6FB5, $571BE91F,
      $F296EC6B, $2A0DD915, $B6636521, $E7B9F9B6, $FF34052E, $C5855664,
      $53B02D5D, $A99F8FA1, $08BA4799, $6E85076A
    ),
    ( // S1
      $4B7A70E9, $B5B32944, $DB75092E, $C4192623, $AD6EA6B0, $49A7DF7D,
      $9CEE60B8, $8FEDB266, $ECAA8C71, $699A17FF, $5664526C, $C2B19EE1,
      $193602A5, $75094C29, $A0591340, $E4183A3E, $3F54989A, $5B429D65,
      $6B8FE4D6, $99F73FD6, $A1D29C07, $EFE830F5, $4D2D38E6, $F0255DC1,
      $4CDD2086, $8470EB26, $6382E9C6, $021ECC5E, $09686B3F, $3EBAEFC9,
      $3C971814, $6B6A70A1, $687F3584, $52A0E286, $B79C5305, $AA500737,
      $3E07841C, $7FDEAE5C, $8E7D44EC, $5716F2B8, $B03ADA37, $F0500C0D,
      $F01C1F04, $0200B3FF, $AE0CF51A, $3CB574B2, $25837A58, $DC0921BD,
      $D19113F9, $7CA92FF6, $94324773, $22F54701, $3AE5E581, $37C2DADC,
      $C8B57634, $9AF3DDA7, $A9446146, $0FD0030E, $ECC8C73E, $A4751E41,
      $E238CD99, $3BEA0E2F, $3280BBA1, $183EB331, $4E548B38, $4F6DB908,
      $6F420D03, $F60A04BF, $2CB81290, $24977C79, $5679B072, $BCAF89AF,
      $DE9A771F, $D9930810, $B38BAE12, $DCCF3F2E, $5512721F, $2E6B7124,
      $501ADDE6, $9F84CD87, $7A584718, $7408DA17, $BC9F9ABC, $E94B7D8C,
      $EC7AEC3A, $DB851DFA, $63094366, $C464C3D2, $EF1C1847, $3215D908,
      $DD433B37, $24C2BA16, $12A14D43, $2A65C451, $50940002, $133AE4DD,
      $71DFF89E, $10314E55, $81AC77D6, $5F11199B, $043556F1, $D7A3C76B,
      $3C11183B, $5924A509, $F28FE6ED, $97F1FBFA, $9EBABF2C, $1E153C6E,
      $86E34570, $EAE96FB1, $860E5E0A, $5A3E2AB3, $771FE71C, $4E3D06FA,
      $2965DCB9, $99E71D0F, $803E89D6, $5266C825, $2E4CC978, $9C10B36A,
      $C6150EBA, $94E2EA78, $A5FC3C53, $1E0A2DF4, $F2F74EA7, $361D2B3D,
      $1939260F, $19C27960, $5223A708, $F71312B6, $EBADFE6E, $EAC31F66,
      $E3BC4595, $A67BC883, $B17F37D1, $018CFF28, $C332DDEF, $BE6C5AA5,
      $65582185, $68AB9802, $EECEA50F, $DB2F953B, $2AEF7DAD, $5B6E2F84,
      $1521B628, $29076170, $ECDD4775, $619F1510, $13CCA830, $EB61BD96,
      $0334FE1E, $AA0363CF, $B5735C90, $4C70A239, $D59E9E0B, $CBAADE14,
      $EECC86BC, $60622CA7, $9CAB5CAB, $B2F3846E, $648B1EAF, $19BDF0CA,
      $A02369B9, $655ABB50, $40685A32, $3C2AB4B3, $319EE9D5, $C021B8F7,
      $9B540B19, $875FA099, $95F7997E, $623D7DA8, $F837889A, $97E32D77,
      $11ED935F, $16681281, $0E358829, $C7E61FD6, $96DEDFA1, $7858BA99,
      $57F584A5, $1B227263, $9B83C3FF, $1AC24696, $CDB30AEB, $532E3054,
      $8FD948E4, $6DBC3128, $58EBF2EF, $34C6FFEA, $FE28ED61, $EE7C3C73,
      $5D4A14D9, $E864B7E3, $42105D14, $203E13E0, $45EEE2B6, $A3AAABEA,
      $DB6C4F15, $FACB4FD0, $C742F442, $EF6ABBB5, $654F3B1D, $41CD2105,
      $D81E799E, $86854DC7, $E44B476A, $3D816250, $CF62A1F2, $5B8D2646,
      $FC8883A0, $C1C7B6A3, $7F1524C3, $69CB7492, $47848A0B, $5692B285,
      $095BBF00, $AD19489D, $1462B174, $23820E00, $58428D2A, $0C55F5EA,
      $1DADF43E, $233F7061, $3372F092, $8D937E41, $D65FECF1, $6C223BDB,
      $7CDE3759, $CBEE7460, $4085F2A7, $CE77326E, $A6078084, $19F8509E,
      $E8EFD855, $61D99735, $A969A7AA, $C50C06C2, $5A04ABFC, $800BCADC,
      $9E447A2E, $C3453484, $FDD56705, $0E1E9EC9, $DB73DBD3, $105588CD,
      $675FDA79, $E3674340, $C5C43465, $713E38D8, $3D28F89E, $F16DFF20,
      $153E21E7, $8FB03D4A, $E6E39F2B, $DB83ADF7
    ),
    ( // S2
      $E93D5A68, $948140F7, $F64C261C, $94692934, $411520F7, $7602D4F7,
      $BCF46B2E, $D4A20068, $D4082471, $3320F46A, $43B7D4B7, $500061AF,
      $1E39F62E, $97244546, $14214F74, $BF8B8840, $4D95FC1D, $96B591AF,
      $70F4DDD3, $66A02F45, $BFBC09EC, $03BD9785, $7FAC6DD0, $31CB8504,
      $96EB27B3, $55FD3941, $DA2547E6, $ABCA0A9A, $28507825, $530429F4,
      $0A2C86DA, $E9B66DFB, $68DC1462, $D7486900, $680EC0A4, $27A18DEE,
      $4F3FFEA2, $E887AD8C, $B58CE006, $7AF4D6B6, $AACE1E7C, $D3375FEC,
      $CE78A399, $406B2A42, $20FE9E35, $D9F385B9, $EE39D7AB, $3B124E8B,
      $1DC9FAF7, $4B6D1856, $26A36631, $EAE397B2, $3A6EFA74, $DD5B4332,
      $6841E7F7, $CA7820FB, $FB0AF54E, $D8FEB397, $454056AC, $BA489527,
      $55533A3A, $20838D87, $FE6BA9B7, $D096954B, $55A867BC, $A1159A58,
      $CCA92963, $99E1DB33, $A62A4A56, $3F3125F9, $5EF47E1C, $9029317C,
      $FDF8E802, $04272F70, $80BB155C, $05282CE3, $95C11548, $E4C66D22,
      $48C1133F, $C70F86DC, $07F9C9EE, $41041F0F, $404779A4, $5D886E17,
      $325F51EB, $D59BC0D1, $F2BCC18F, $41113564, $257B7834, $602A9C60,
      $DFF8E8A3, $1F636C1B, $0E12B4C2, $02E1329E, $AF664FD1, $CAD18115,
      $6B2395E0, $333E92E1, $3B240B62, $EEBEB922, $85B2A20E, $E6BA0D99,
      $DE720C8C, $2DA2F728, $D0127845, $95B794FD, $647D0862, $E7CCF5F0,
      $5449A36F, $877D48FA, $C39DFD27, $F33E8D1E, $0A476341, $992EFF74,
      $3A6F6EAB, $F4F8FD37, $A812DC60, $A1EBDDF8, $991BE14C, $DB6E6B0D,
      $C67B5510, $6D672C37, $2765D43B, $DCD0E804, $F1290DC7, $CC00FFA3,
      $B5390F92, $690FED0B, $667B9FFB, $CEDB7D9C, $A091CF0B, $D9155EA3,
      $BB132F88, $515BAD24, $7B9479BF, $763BD6EB, $37392EB3, $CC115979,
      $8026E297, $F42E312D, $6842ADA7, $C66A2B3B, $12754CCC, $782EF11C,
      $6A124237, $B79251E7, $06A1BBE6, $4BFB6350, $1A6B1018, $11CAEDFA,
      $3D25BDD8, $E2E1C3C9, $44421659, $0A121386, $D90CEC6E, $D5ABEA2A,
      $64AF674E, $DA86A85F, $BEBFE988, $64E4C3FE, $9DBC8057, $F0F7C086,
      $60787BF8, $6003604D, $D1FD8346, $F6381FB0, $7745AE04, $D736FCCC,
      $83426B33, $F01EAB71, $B0804187, $3C005E5F, $77A057BE, $BDE8AE24,
      $55464299, $BF582E61, $4E58F48F, $F2DDFDA2, $F474EF38, $8789BDC2,
      $5366F9C3, $C8B38E74, $B475F255, $46FCD9B9, $7AEB2661, $8B1DDF84,
      $846A0E79, $915F95E2, $466E598E, $20B45770, $8CD55591, $C902DE4C,
      $B90BACE1, $BB8205D0, $11A86248, $7574A99E, $B77F19B6, $E0A9DC09,
      $662D09A1, $C4324633, $E85A1F02, $09F0BE8C, $4A99A025, $1D6EFE10,
      $1AB93D1D, $0BA5A4DF, $A186F20F, $2868F169, $DCB7DA83, $573906FE,
      $A1E2CE9B, $4FCD7F52, $50115E01, $A70683FA, $A002B5C4, $0DE6D027,
      $9AF88C27, $773F8641, $C3604C06, $61A806B5, $F0177A28, $C0F586E0,
      $006058AA, $30DC7D62, $11E69ED7, $2338EA63, $53C2DD94, $C2C21634,
      $BBCBEE56, $90BCB6DE, $EBFC7DA1, $CE591D76, $6F05E409, $4B7C0188,
      $39720A3D, $7C927C24, $86E3725F, $724D9DB9, $1AC15BB4, $D39EB8FC,
      $ED545578, $08FCA5B5, $D83D7CD3, $4DAD0FC4, $1E50EF5E, $B161E6F8,
      $A28514D9, $6C51133C, $6FD5C7E7, $56E14EC4, $362ABFCE, $DDC6C837,
      $D79A3234, $92638212, $670EFA8E, $406000E0
    ),
    ( // S3
      $3A39CE37, $D3FAF5CF, $ABC27737, $5AC52D1B, $5CB0679E, $4FA33742,
      $D3822740, $99BC9BBE, $D5118E9D, $BF0F7315, $D62D1C7E, $C700C47B,
      $B78C1B6B, $21A19045, $B26EB1BE, $6A366EB4, $5748AB2F, $BC946E79,
      $C6A376D2, $6549C2C8, $530FF8EE, $468DDE7D, $D5730A1D, $4CD04DC6,
      $2939BBDB, $A9BA4650, $AC9526E8, $BE5EE304, $A1FAD5F0, $6A2D519A,
      $63EF8CE2, $9A86EE22, $C089C2B8, $43242EF6, $A51E03AA, $9CF2D0A4,
      $83C061BA, $9BE96A4D, $8FE51550, $BA645BD6, $2826A2F9, $A73A3AE1,
      $4BA99586, $EF5562E9, $C72FEFD3, $F752F7DA, $3F046F69, $77FA0A59,
      $80E4A915, $87B08601, $9B09E6AD, $3B3EE593, $E990FD5A, $9E34D797,
      $2CF0B7D9, $022B8B51, $96D5AC3A, $017DA67D, $D1CF3ED6, $7C7D2D28,
      $1F9F25CF, $ADF2B89B, $5AD6B472, $5A88F54C, $E029AC71, $E019A5E6,
      $47B0ACFD, $ED93FA9B, $E8D3C48D, $283B57CC, $F8D56629, $79132E28,
      $785F0191, $ED756055, $F7960E44, $E3D35E8C, $15056DD4, $88F46DBA,
      $03A16125, $0564F0BD, $C3EB9E15, $3C9057A2, $97271AEC, $A93A072A,
      $1B3F6D9B, $1E6321F5, $F59C66FB, $26DCF319, $7533D928, $B155FDF5,
      $03563482, $8ABA3CBB, $28517711, $C20AD9F8, $ABCC5167, $CCAD925F,
      $4DE81751, $3830DC8E, $379D5862, $9320F991, $EA7A90C2, $FB3E7BCE,
      $5121CE64, $774FBE32, $A8B6E37E, $C3293D46, $48DE5369, $6413E680,
      $A2AE0810, $DD6DB224, $69852DFD, $09072166, $B39A460A, $6445C0DD,
      $586CDECF, $1C20C8AE, $5BBEF7DD, $1B588D40, $CCD2017F, $6BB4E3BB,
      $DDA26A7E, $3A59FF45, $3E350A44, $BCB4CDD5, $72EACEA8, $FA6484BB,
      $8D6612AE, $BF3C6F47, $D29BE463, $542F5D9E, $AEC2771B, $F64E6370,
      $740E0D8D, $E75B1357, $F8721671, $AF537D5D, $4040CB08, $4EB4E2CC,
      $34D2466A, $0115AF84, $E1B00428, $95983A1D, $06B89FB4, $CE6EA048,
      $6F3F3B82, $3520AB82, $011A1D4B, $277227F8, $611560B1, $E7933FDC,
      $BB3A792B, $344525BD, $A08839E1, $51CE794B, $2F32C9B7, $A01FBAC9,
      $E01CC87E, $BCC7D1F6, $CF0111C3, $A1E8AAC7, $1A908749, $D44FBD9A,
      $D0DADECB, $D50ADA38, $0339C32A, $C6913667, $8DF9317C, $E0B12B4F,
      $F79E59B7, $43F5BB3A, $F2D519FF, $27D9459C, $BF97222C, $15E6FC2A,
      $0F91FC71, $9B941525, $FAE59361, $CEB69CEB, $C2A86459, $12BAA8D1,
      $B6C1075E, $E3056A0C, $10D25065, $CB03A442, $E0EC6E0E, $1698DB3B,
      $4C98A0BE, $3278E964, $9F1F9532, $E0D392DF, $D3A0342B, $8971F21E,
      $1B0A7441, $4BA3348C, $C5BE7120, $C37632D8, $DF359F8D, $9B992F2E,
      $E60B6F47, $0FE3F11D, $E54CDA54, $1EDAD891, $CE6279CF, $CD3E7E6F,
      $1618B166, $FD2C1D05, $848FD2C5, $F6FB2299, $F523F357, $A6327623,
      $93A83531, $56CCCD02, $ACF08162, $5A75EBB5, $6E163697, $88D273CC,
      $DE966292, $81B949D0, $4C50901B, $71C65614, $E6C6C7BD, $327A140A,
      $45E1D006, $C3F27B9A, $C9AA53FD, $62A80F00, $BB25BFE2, $35BDD2F6,
      $71126905, $B2040222, $B6CBCF7C, $CD769C2B, $53113EC0, $1640E3D3,
      $38ABBD60, $2547ADF0, $BA38209C, $F746CE76, $77AFA1C5, $20756060,
      $85CBFE4E, $8AE88DD8, $7AAAF9B0, $4CF9AA7E, $1948C25C, $02FB8A8C,
      $01C36AE4, $D6EBE1F9, $90D4F869, $A65CDEA0, $3F09252D, $C208E69F,
      $B74E6132, $CE77E25B, $578FDFE3, $3AC372E6
    )
  );
```

## Apêndice B: como reproduzir a análise

- Disassembly de uma faixa:
  `llvm-objdump -d --no-show-raw-insn --x86-asm-syntax=intel --start-address=0x4292A8 --stop-address=0x429493 jvcs.exe`.
- Para achar uma tabela ou constante, procure o `UInt32` em little-endian (por exemplo `96 30 07 77`
  para `$77073096`; `88 6A 3F 24` para `$243F6A88`) e depois o VA resultante nos operandos (referência
  absoluta).
- Literais `AnsiString` do Delphi 2007: `FF FF FF FF <len:4> <bytes> 00`. Shortstrings de nome de
  classe: `<len:1> <bytes>`. Na VMT do D2007, `vmtSelfPtr = -76`, `vmtInstanceSize = -40`,
  `vmtParent = -36` e `vmtClassName = -44`.
- Os scripts auxiliares (parser PE em C# via `Add-Type` e `dis.ps1`) ficaram no scratchpad da sessão
  e não fazem parte do repositório.
