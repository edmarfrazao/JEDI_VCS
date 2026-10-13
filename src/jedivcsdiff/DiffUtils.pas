(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: DiffUtils.pas

The Initial Developer of the original code (JEDI VCS v2026) is the JEDI VCS
port team (2026).

Purpose:
  Substitutos nativos (sem JVCL/JCL/DFS e sem as units do EXE) usados so pelo
  JEDIVCSDiff:
  - TDiffMruList: MRU no mesmo formato do TJvMruList/comctl32
    (valor "MRUList" com as letras em ordem de uso + valores "a".."j");
  - DiffRegRead*/DiffRegWrite*: registro tolerante a tipo (no lugar do RegAcc);
  - TDiffTextReader: leitura de texto com deteccao de codificacao
    (BOM UTF-8/UTF-16, UTF-8 sem BOM ou ANSI do sistema);
  - DiffFileVersion / DiffGetFileSize.

Unit history:

2026/10/12  v2026      - nova unit (port Delphi 13, fase F3)

-----------------------------------------------------------------------------*)

unit DiffUtils;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, ImgList, CommCtrl;

type
  TDiffMruList = class
  private
    FSubKey: string;
    FMaxItems: Integer;
    FItems: TStringList;
  public
    constructor Create(const ASubKey: string; AMaxItems: Integer = 10);
    destructor Destroy; override;
    procedure Load;
    procedure Save;
    { coloca o valor no topo (sem diferenciar maiusculas) e grava }
    procedure AddString(const Value: string);
    property Items: TStringList read FItems;  // [0] = mais recente
    property SubKey: string read FSubKey;
  end;

  TDiffTextReader = class
  private
    FLines: TStringList;
    FPos: Integer;
    FEncoding: TEncoding;
    FHasBOM: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromFile(const FileName: string);
    function Eof: Boolean;
    function ReadLine: string;
    property Lines: TStringList read FLines;
    property Encoding: TEncoding read FEncoding;
    property HasBOM: Boolean read FHasBOM;
  end;

{ codificacao detectada: BOM, UTF-8 valido com acentos, senao ANSI (CP_ACP) }
function DiffDetectEncoding(const Bytes: TBytes; out PreambleLen: Integer;
  out HasBOM: Boolean): TEncoding;
function DiffDetectFileEncoding(const FileName: string; out HasBOM: Boolean): TEncoding;
function DiffEncodingName(AEncoding: TEncoding): string;
// ANSI se o texto cabe na code page do sistema; senao UTF-8 (com BOM)
function DiffBestEncoding(const S: string): TEncoding;

function DiffRegReadInteger(Root: HKEY; const Key, Name: string; Def: Integer): Integer;
function DiffRegReadBool(Root: HKEY; const Key, Name: string; Def: Boolean): Boolean;
procedure DiffRegWriteInteger(Root: HKEY; const Key, Name: string; Value: Integer);
procedure DiffRegWriteBool(Root: HKEY; const Key, Name: string; Value: Boolean);

{ valor de StringFileInfo (ex.: 'ProductVersion', 'BuildTimestamp') }
function DiffFileVersionValue(const FileName, ValueName: string): string;
{ imagens antigas (sem canal alfa) ficam invisiveis no gutter do SynEdit
  atual (Direct2D): converte a lista para 32 bits com alfa a partir da mascara }
procedure DiffMakeImageList32(IL: TImageList);
function DiffGetFileSize(const FileName: string): Int64;
// data/hora do arquivo (DateTimeToStr) ou ''
function DiffFileDateStr(const FileName: string): string;

implementation

uses
  Registry;

//=== MRU =======================================================================

constructor TDiffMruList.Create(const ASubKey: string; AMaxItems: Integer);
begin
  inherited Create;
  FSubKey := ASubKey;
  FMaxItems := AMaxItems;
  if FMaxItems < 1 then
    FMaxItems := 1;
  if FMaxItems > 26 then
    FMaxItems := 26;
  FItems := TStringList.Create;
end;

destructor TDiffMruList.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TDiffMruList.Load;
var
  Reg: TRegistry;
  Order, S: string;
  I: Integer;
begin
  FItems.Clear;
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKeyReadOnly(FSubKey) then
    begin
      Order := '';
      if Reg.ValueExists('MRUList') then
      try
        Order := Reg.ReadString('MRUList');
      except
        Order := '';
      end;
      for I := 1 to Length(Order) do
      begin
        S := '';
        if Reg.ValueExists(Order[I]) then
        try
          if Reg.GetDataType(Order[I]) in [rdString, rdExpandString] then
            S := Reg.ReadString(Order[I]);
        except
          S := '';
        end;
        if (S <> '') and (FItems.Count < FMaxItems) then
          FItems.Add(S);
      end;
    end;
  finally
    Reg.Free;
  end;
end;

procedure TDiffMruList.Save;
var
  Reg: TRegistry;
  Order: string;
  I: Integer;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey(FSubKey, True) then
    begin
      Order := '';
      for I := 0 to FItems.Count - 1 do
      begin
        Order := Order + Chr(Ord('a') + I);
        Reg.WriteString(Chr(Ord('a') + I), FItems[I]);
      end;
      // apaga sobras de listas maiores
      for I := FItems.Count to FMaxItems - 1 do
        if Reg.ValueExists(Chr(Ord('a') + I)) then
          Reg.DeleteValue(Chr(Ord('a') + I));
      Reg.WriteString('MRUList', Order);
    end;
  finally
    Reg.Free;
  end;
end;

procedure TDiffMruList.AddString(const Value: string);
var
  I: Integer;
begin
  if Value = '' then
    Exit;
  for I := FItems.Count - 1 downto 0 do
    if AnsiSameText(FItems[I], Value) then
      FItems.Delete(I);
  FItems.Insert(0, Value);
  while FItems.Count > FMaxItems do
    FItems.Delete(FItems.Count - 1);
  Save;
end;

//=== codificacao ===============================================================

function IsValidUTF8(const Bytes: TBytes; Start: Integer; out HasMultiByte: Boolean): Boolean;
var
  I, N, Len, Extra: Integer;
  B: Byte;
begin
  Result := True;
  HasMultiByte := False;
  Len := Length(Bytes);
  I := Start;
  while I < Len do
  begin
    B := Bytes[I];
    if B < $80 then
    begin
      Inc(I);
      Continue;
    end;
    if (B and $E0) = $C0 then
      Extra := 1
    else
    if (B and $F0) = $E0 then
      Extra := 2
    else
    if (B and $F8) = $F0 then
      Extra := 3
    else
      Exit(False);
    if (B = $C0) or (B = $C1) then
      Exit(False);
    for N := 1 to Extra do
    begin
      if I + N >= Len then
        Exit(True); // arquivo cortado no meio do caractere: aceita
      if (Bytes[I + N] and $C0) <> $80 then
        Exit(False);
    end;
    HasMultiByte := True;
    Inc(I, Extra + 1);
  end;
end;

function DiffDetectEncoding(const Bytes: TBytes; out PreambleLen: Integer;
  out HasBOM: Boolean): TEncoding;
var
  Enc: TEncoding;
  HasMulti: Boolean;
begin
  Enc := nil;
  PreambleLen := TEncoding.GetBufferEncoding(Bytes, Enc, nil);
  HasBOM := (PreambleLen > 0) and (Enc <> nil);
  if HasBOM then
    Result := Enc
  else
  begin
    PreambleLen := 0;
    if IsValidUTF8(Bytes, 0, HasMulti) and HasMulti then
      Result := TEncoding.UTF8
    else
      Result := TEncoding.ANSI;
  end;
end;

function ReadFileBytes(const FileName: string): TBytes;
var
  FS: TFileStream;
begin
  FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  try
    SetLength(Result, FS.Size);
    if Length(Result) > 0 then
      FS.ReadBuffer(Result[0], Length(Result));
  finally
    FS.Free;
  end;
end;

function DiffDetectFileEncoding(const FileName: string; out HasBOM: Boolean): TEncoding;
var
  P: Integer;
begin
  Result := DiffDetectEncoding(ReadFileBytes(FileName), P, HasBOM);
end;

function DiffEncodingName(AEncoding: TEncoding): string;
begin
  if AEncoding = nil then
    Result := ''
  else
  if AEncoding = TEncoding.UTF8 then
    Result := 'UTF-8'
  else
  if AEncoding = TEncoding.Unicode then
    Result := 'UTF-16LE'
  else
  if AEncoding = TEncoding.BigEndianUnicode then
    Result := 'UTF-16BE'
  else
  if AEncoding.CodePage = CP_UTF8 then
    Result := 'UTF-8'
  else
    Result := 'ANSI ' + IntToStr(AEncoding.CodePage);
end;

function DiffBestEncoding(const S: string): TEncoding;
begin
  if TEncoding.ANSI.GetString(TEncoding.ANSI.GetBytes(S)) = S then
    Result := TEncoding.ANSI
  else
    Result := TEncoding.UTF8;
end;

//=== TDiffTextReader ===========================================================

constructor TDiffTextReader.Create;
begin
  inherited Create;
  FLines := TStringList.Create;
  FEncoding := TEncoding.ANSI;
end;

destructor TDiffTextReader.Destroy;
begin
  FLines.Free;
  inherited Destroy;
end;

procedure TDiffTextReader.LoadFromFile(const FileName: string);
var
  Bytes: TBytes;
  P: Integer;
begin
  Bytes := ReadFileBytes(FileName);
  FEncoding := DiffDetectEncoding(Bytes, P, FHasBOM);
  FLines.Text := FEncoding.GetString(Bytes, P, Length(Bytes) - P);
  FPos := 0;
end;

function TDiffTextReader.Eof: Boolean;
begin
  Result := FPos >= FLines.Count;
end;

function TDiffTextReader.ReadLine: string;
begin
  if FPos < FLines.Count then
  begin
    Result := FLines[FPos];
    Inc(FPos);
  end
  else
    Result := '';
end;

//=== registro ==================================================================

function DiffRegReadInteger(Root: HKEY; const Key, Name: string; Def: Integer): Integer;
var
  Reg: TRegistry;
  Buf: array [0..7] of Byte;
  N: Integer;
begin
  Result := Def;
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := Root;
    if Reg.OpenKeyReadOnly(Key) and Reg.ValueExists(Name) then
    try
      case Reg.GetDataType(Name) of
        rdInteger: Result := Reg.ReadInteger(Name);
        rdString, rdExpandString: Result := StrToIntDef(Trim(Reg.ReadString(Name)), Def);
        rdBinary:
          begin
            FillChar(Buf, SizeOf(Buf), 0);
            N := Reg.GetDataSize(Name);
            if (N > 0) and (N <= SizeOf(Buf)) then
            begin
              Reg.ReadBinaryData(Name, Buf, N);
              Result := PInteger(@Buf[0])^;
            end;
          end;
      end;
    except
      Result := Def;
    end;
  finally
    Reg.Free;
  end;
end;

function DiffRegReadBool(Root: HKEY; const Key, Name: string; Def: Boolean): Boolean;
var
  Reg: TRegistry;
  S: string;
begin
  Result := Def;
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := Root;
    if Reg.OpenKeyReadOnly(Key) and Reg.ValueExists(Name) then
    try
      case Reg.GetDataType(Name) of
        rdString, rdExpandString:
          begin
            S := Trim(Reg.ReadString(Name));
            if SameText(S, 'True') or SameText(S, 'Yes') or (S = '1') then
              Result := True
            else
            if SameText(S, 'False') or SameText(S, 'No') or (S = '0') then
              Result := False;
          end;
      else
        Result := DiffRegReadInteger(Root, Key, Name, Ord(Def)) <> 0;
      end;
    except
      Result := Def;
    end;
  finally
    Reg.Free;
  end;
end;

procedure DiffRegWriteInteger(Root: HKEY; const Key, Name: string; Value: Integer);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := Root;
    if Reg.OpenKey(Key, True) then
      Reg.WriteInteger(Name, Value);
  finally
    Reg.Free;
  end;
end;

procedure DiffRegWriteBool(Root: HKEY; const Key, Name: string; Value: Boolean);
begin
  DiffRegWriteInteger(Root, Key, Name, Ord(Value));
end;

//=== imagens 32 bits ===========================================================

procedure DiffMakeImageList32(IL: TImageList);
type
  TPix = packed record
    B, G, R, A: Byte;
  end;
  PPix = ^TPix;
var
  Bmps: array of TBitmap;
  Msk: TBitmap;
  I, X, Y, W, H, N: Integer;
  P, M: PPix;
begin
  if (IL = nil) or (IL.Count = 0) then
    Exit;
  W := IL.Width;
  H := IL.Height;
  N := IL.Count;
  SetLength(Bmps, N);
  Msk := TBitmap.Create;
  try
    Msk.PixelFormat := pf32bit;
    Msk.SetSize(W, H);
    for I := 0 to N - 1 do
    begin
      Bmps[I] := TBitmap.Create;
      Bmps[I].PixelFormat := pf32bit;
      Bmps[I].SetSize(W, H);
      Bmps[I].Canvas.Brush.Color := clBlack;
      Bmps[I].Canvas.FillRect(Rect(0, 0, W, H));
      ImageList_Draw(IL.Handle, I, Bmps[I].Canvas.Handle, 0, 0, ILD_NORMAL);
      Msk.Canvas.Brush.Color := clWhite;
      Msk.Canvas.FillRect(Rect(0, 0, W, H));
      ImageList_Draw(IL.Handle, I, Msk.Canvas.Handle, 0, 0, ILD_MASK);
      for Y := 0 to H - 1 do
      begin
        P := Bmps[I].ScanLine[Y];
        M := Msk.ScanLine[Y];
        for X := 0 to W - 1 do
        begin
          if (M^.R = 0) and (M^.G = 0) and (M^.B = 0) then
            P^.A := 255  // opaco
          else
          begin
            P^.A := 0;
            P^.R := 0;
            P^.G := 0;
            P^.B := 0;
          end;
          Inc(P);
          Inc(M);
        end;
      end;
    end;
    IL.Clear;
    IL.ColorDepth := cd32Bit;
    IL.Masked := False;
    for I := 0 to N - 1 do
      IL.Add(Bmps[I], nil);
  finally
    Msk.Free;
    for I := 0 to High(Bmps) do
      Bmps[I].Free;
  end;
end;

//=== versao / tamanho ==========================================================

function DiffFileVersionValue(const FileName, ValueName: string): string;
type
  TLangCP = packed record
    Lang, CodePage: Word;
  end;
  PLangCP = ^TLangCP;
var
  Size, Dummy, Len: DWORD;
  Buf: TBytes;
  P: Pointer;
  Trans: PLangCP;
  SubBlock: string;
begin
  Result := '';
  Size := GetFileVersionInfoSize(PChar(FileName), Dummy);
  if Size = 0 then
    Exit;
  SetLength(Buf, Size);
  if not GetFileVersionInfo(PChar(FileName), 0, Size, @Buf[0]) then
    Exit;
  SubBlock := '\StringFileInfo\040904E4\' + ValueName;
  if VerQueryValue(@Buf[0], '\VarFileInfo\Translation', Pointer(Trans), Len) and
     (Len >= SizeOf(TLangCP)) then
    SubBlock := Format('\StringFileInfo\%.4x%.4x\%s', [Trans^.Lang, Trans^.CodePage, ValueName]);
  if VerQueryValue(@Buf[0], PChar(SubBlock), P, Len) and (Len > 0) then
    Result := PChar(P);
end;

function DiffFileDateStr(const FileName: string): string;
var
  DT: TDateTime;
begin
  if FileAge(FileName, DT) then
    Result := DateTimeToStr(DT)
  else
    Result := '';
end;

function DiffGetFileSize(const FileName: string): Int64;
var
  FAD: TWin32FileAttributeData;
begin
  Result := -1;
  if GetFileAttributesEx(PChar(FileName), GetFileExInfoStandard, @FAD) then
    Result := Int64(FAD.nFileSizeHigh) shl 32 or FAD.nFileSizeLow;
end;

end.
