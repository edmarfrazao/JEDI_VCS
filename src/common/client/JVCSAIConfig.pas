(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSAIConfig.pas

The Initial Developer of the original code (JEDI VCS v2026) is the JEDI VCS
port team (2026).

Purpose:
  Leitura/gravacao dos modos da automacao por IA no config.ini do wrapper
  tools\ai\jvcs-ai.ps1: %APPDATA%\JEDI\JVCS\config.ini, secao [ai],
  checkout= e checkin= (auto | confirm | manual; padrao confirm).
  O formato e o contrato com o wrapper; esta unit reproduz exatamente
  Read-JaIniSection / Read-JaConfig / Set-JaConfigValue de
  tools\ai\lib\jvcs-ai-common.ps1:
  - leitura: UTF-8 (BOM opcional), linhas iniciadas por ; ou # ignoradas,
    secao "[ai]" sem diferenciar maiusculas (todas as secoes [ai] contam),
    chave = texto antes do primeiro "=" (sem diferenciar maiusculas), valor
    aparado; a ultima ocorrencia vale; valor invalido = confirm;
  - gravacao: preserva o resto do arquivo; troca a ultima linha "chave=" da
    secao [ai] (chave sem ; nem #), ou insere antes das linhas em branco do
    fim da secao, ou cria "[ai]" no fim; grava UTF-8 COM BOM e CRLF, com
    CRLF no fim; arquivo novo comeca com as 3 linhas de comentario do wrapper.

Unit history:

2026/10/13  v2026      - nova unit (F4, aba "AI / Automation" de VCS Properties)

-----------------------------------------------------------------------------*)

unit JVCSAIConfig;

interface

uses
  SysUtils, Classes;

type
  TJVCSAIMode = (aimManual, aimConfirm, aimAuto);

const
  cJVCSAIModeText: array [TJVCSAIMode] of string = ('manual', 'confirm', 'auto');
  cJVCSAIDefaultMode = aimConfirm;
  cJVCSAIKeyCheckout = 'checkout';
  cJVCSAIKeyCheckin = 'checkin';

{ %APPDATA%\JEDI\JVCS\config.ini }
function JVCSAIConfigPath: string;
{ texto -> modo (False se invalido) }
function JVCSAITextToMode(const AText: string; out AMode: TJVCSAIMode): Boolean;
{ valor efetivo de uma chave do [ai] (checkout/checkin), como o wrapper le }
function JVCSAIReadMode(const AKey: string; const APath: string = ''): TJVCSAIMode;
{ grava uma chave do [ai] como o "jvcs-ai.ps1 config set" }
procedure JVCSAIWriteValue(const AKey, AValue: string; const APath: string = '');
procedure JVCSAIWriteMode(const AKey: string; AMode: TJVCSAIMode; const APath: string = '');

implementation

uses
  Windows, IOUtils;

const
  cNewFileHeader: array [0..2] of string = (
    '; JEDI VCS - automa'#$00E7#$00E3'o por IA (Claude Code). Sem segredos: a senha fica na identidade salva.',
    '; Edite pela interface (futura aba "IA / Automa'#$00E7#$00E3'o" em VCS Properties) ou com: jvcs-ai.ps1 config set <chave> <valor>',
    '; checkout/checkin = auto | confirm | manual   (padr'#$00E3'o: confirm)');

function JVCSAIConfigPath: string;
begin
  Result := IncludeTrailingPathDelimiter(GetEnvironmentVariable('APPDATA')) +
    'JEDI\JVCS\config.ini';
end;

function JVCSAITextToMode(const AText: string; out AMode: TJVCSAIMode): Boolean;
var
  M: TJVCSAIMode;
begin
  Result := False;
  AMode := cJVCSAIDefaultMode;
  for M := Low(TJVCSAIMode) to High(TJVCSAIMode) do
    if SameText(Trim(AText), cJVCSAIModeText[M]) then
    begin
      AMode := M;
      Exit(True);
    end;
end;

{ como [IO.File]::ReadAllLines: UTF-8 (BOM descartado), quebra em CR, LF ou
  CRLF; a quebra final nao gera linha vazia }
function ReadLines(const APath: string): TStringList;
var
  Bytes: TBytes;
  Text: string;
  I, Start: Integer;
begin
  Result := TStringList.Create;
  if not FileExists(APath) then
    Exit;
  Bytes := TFile.ReadAllBytes(APath);
  if (Length(Bytes) >= 3) and (Bytes[0] = $EF) and (Bytes[1] = $BB) and (Bytes[2] = $BF) then
    Text := TEncoding.UTF8.GetString(Bytes, 3, Length(Bytes) - 3)
  else
    Text := TEncoding.UTF8.GetString(Bytes);
  I := 1;
  Start := 1;
  while I <= Length(Text) do
  begin
    if (Text[I] = #13) or (Text[I] = #10) then
    begin
      Result.Add(Copy(Text, Start, I - Start));
      if (Text[I] = #13) and (I < Length(Text)) and (Text[I + 1] = #10) then
        Inc(I);
      Start := I + 1;
    end;
    Inc(I);
  end;
  if Start <= Length(Text) then
    Result.Add(Copy(Text, Start, MaxInt));
end;

function StripBom(const S: string): string;
begin
  Result := S;
  while (Result <> '') and (Result[1] = #$FEFF) do
    Delete(Result, 1, 1);
end;

function IsSectionHeader(const ATrimmed: string; out AName: string): Boolean;
begin
  // ^\[(.+)\]$
  Result := (Length(ATrimmed) >= 3) and (ATrimmed[1] = '[') and
    (ATrimmed[Length(ATrimmed)] = ']');
  if Result then
    AName := Trim(Copy(ATrimmed, 2, Length(ATrimmed) - 2));
end;

function JVCSAIReadMode(const AKey: string; const APath: string): TJVCSAIMode;
var
  Lines: TStringList;
  I, P: Integer;
  Line, Sec, Key, Value, Path: string;
  InSec, Found: Boolean;
begin
  Path := APath;
  if Path = '' then
    Path := JVCSAIConfigPath;
  Found := False;
  Value := '';
  Lines := ReadLines(Path);
  try
    InSec := False;
    for I := 0 to Lines.Count - 1 do
    begin
      Line := Trim(StripBom(Trim(Lines[I])));
      if (Line = '') or (Line[1] = ';') or (Line[1] = '#') then
        Continue;
      if IsSectionHeader(Line, Sec) then
      begin
        InSec := SameText(Sec, 'ai');
        Continue;
      end;
      // ^([^=]+?)\s*=\s*(.*)$
      P := Pos('=', Line);
      if InSec and (P > 1) then
      begin
        Key := Trim(Copy(Line, 1, P - 1));
        if SameText(Key, AKey) then
        begin
          Value := Trim(Copy(Line, P + 1, MaxInt));
          Found := True;
        end;
      end;
    end;
  finally
    Lines.Free;
  end;
  if not Found or not JVCSAITextToMode(Value, Result) then
    Result := cJVCSAIDefaultMode;
end;

procedure JVCSAIWriteValue(const AKey, AValue: string; const APath: string);
var
  Lines: TStringList;
  I, P, SecStart, SecEnd, KeyLine, InsertAt: Integer;
  T, Sec, Prefix, Path, NewLine, Text: string;
  Bytes: TBytes;
begin
  Path := APath;
  if Path = '' then
    Path := JVCSAIConfigPath;
  ForceDirectories(ExtractFileDir(Path));
  Lines := ReadLines(Path);
  try
    if not FileExists(Path) then
      for I := Low(cNewFileHeader) to High(cNewFileHeader) do
        Lines.Add(cNewFileHeader[I])
    else
      for I := 0 to Lines.Count - 1 do
        Lines[I] := StripBom(Lines[I]);
    SecStart := -1;
    SecEnd := Lines.Count;
    KeyLine := -1;
    for I := 0 to Lines.Count - 1 do
    begin
      T := Trim(Lines[I]);
      if IsSectionHeader(T, Sec) then
      begin
        if (SecStart >= 0) and (SecEnd = Lines.Count) then
          SecEnd := I;
        if SameText(Sec, 'ai') then
        begin
          SecStart := I;
          SecEnd := Lines.Count;
        end;
        Continue;
      end;
      // ^([^=;#]+?)\s*=
      P := Pos('=', T);
      if (SecStart >= 0) and (I > SecStart) and (I < SecEnd) and (P > 1) then
      begin
        Prefix := Copy(T, 1, P - 1);
        if (Pos(';', Prefix) = 0) and (Pos('#', Prefix) = 0) and
           SameText(Trim(Prefix), AKey) then
          KeyLine := I;
      end;
    end;
    NewLine := AKey + '=' + AValue;
    if KeyLine >= 0 then
      Lines[KeyLine] := NewLine
    else
    if SecStart >= 0 then
    begin
      InsertAt := SecEnd;
      while (InsertAt > SecStart + 1) and (Trim(Lines[InsertAt - 1]) = '') do
        Dec(InsertAt);
      Lines.Insert(InsertAt, NewLine);
    end
    else
    begin
      if (Lines.Count > 0) and (Trim(Lines[Lines.Count - 1]) <> '') then
        Lines.Add('');
      Lines.Add('[ai]');
      Lines.Add(NewLine);
    end;
    Text := '';
    for I := 0 to Lines.Count - 1 do
      Text := Text + Lines[I] + #13#10;
  finally
    Lines.Free;
  end;
  Bytes := TEncoding.UTF8.GetPreamble + TEncoding.UTF8.GetBytes(Text);
  TFile.WriteAllBytes(Path, Bytes);
end;

procedure JVCSAIWriteMode(const AKey: string; AMode: TJVCSAIMode; const APath: string);
begin
  JVCSAIWriteValue(AKey, cJVCSAIModeText[AMode], APath);
end;

end.
