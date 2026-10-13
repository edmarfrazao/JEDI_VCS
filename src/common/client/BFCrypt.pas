(* JEDI VCS 2.5 Beta 2026 (port Delphi 13) - BFCrypt.pas. Licenca: MPL 1.1.
   Codigo novo (sem a CryptoLib original), conforme doc\pt\client\Algoritmos-Recuperados.md, secao 2.5. *)

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
    Exit;  // fiel ao original ($6EBBC3): chave fora de 8..65 bytes é ignorada (tabelas de pi sem chave)
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
