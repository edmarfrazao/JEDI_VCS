unit Checksum;

{ JEDI VCS 2.5 Beta 2026 - recriacao fiel da unit Checksum do JEDI VCS 2.5.
  Ver doc\pt\client\Algoritmos-Recuperados.md, secao 1.

  CRC-32 IEEE (polinomio refletido $EDB88320, inicio $FFFFFFFF, XOR final
  $FFFFFFFF) = System.ZLib.crc32 = CRC do ZIP. O arquivo e lido em blocos de
  $8000 com fmOpenRead or fmShareDenyNone. CRCInt devolve o CRC como Integer
  com sinal (como o original grava em BLOBS.ORIGCRC); CRCString devolve
  '$' + IntToHex(CRC, 8) ou, se o CRC for 0, a mensagem de status ('OK' para
  arquivo vazio).

  Diferenca intencional: o original guardava o handle em Word (defeito); aqui
  o handle e completo e a falha de abertura e detectada (mesma mensagem que o
  original produzia nesse caso). }

{$R-}{$Q-}

interface

const
  CRC32_INIT = Cardinal($FFFFFFFF);

/// Atualiza o registrador CRC (sem inversoes). Use CRC32_INIT no inicio e "not" no fim.
function CRC32Update(ACrc: Cardinal; const ABuffer; ACount: NativeInt): Cardinal;
/// CRC-32 completo de um bloco de memoria.
function CRC32OfBuffer(const ABuffer; ACount: NativeInt): Cardinal;

/// Igual ao original: CRC-32 do arquivo como Integer (com sinal); 0 em erro; Err = 'OK' ou mensagem.
function CRCInt(const FileName: string; var Err: string): Integer;
/// Igual ao original: '$' + IntToHex(CRC, 8); se CRC = 0 devolve Err ('OK' para arquivo vazio).
function CRCString(const FileName: string): string;

implementation

uses
  System.SysUtils;

var
  GCrcTable: array [Byte] of Cardinal;

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
  if H = THandle(-1) then
  begin
    // o original nao detectava a falha (handle em Word); o efeito visivel era este:
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
        Result := Integer(not Crc);  // valores >= $80000000 ficam negativos
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
    Result := '$' + IntToHex(Crc, 8)
  else
    Result := Err;
end;

initialization
  InitCrcTable;
end.
