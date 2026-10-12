unit StrUtilsD5;

{$ifdef FPC}
  {$MODE DELPHI}
{$endif}

interface

uses
  SysUtils;

// UTF8-Routinen aus JvGnugetTextD5.pas Project-JEDI

type
  UTF8String = AnsiString;

function LeftStr(const Text: String; const Len: Integer): String;
function RightStr(const Text: String; const Len: Integer): String;
function MidStr(const Text: String; const Start, Len: Integer): String;
function DupeString(const Text: string; Len: Integer): string;
function IfThen(Value: Boolean; const TrueStr: String; const FalseStr: String = ''): String;  overload;
function Utf8Decode(const S: UTF8String): WideString;
function Utf8Encode(const WS: WideString): UTF8String;

implementation

uses
  Windows, JvGnugetText, JvGnugetTextD5;

function Utf8Decode(const S: UTF8String): WideString;
begin
  Result := JvGnugetTextD5.Utf8Decode(S);
end;

function Utf8Encode(const WS: WideString): UTF8String;
begin
  Result := JvGnugetTextD5.Utf8Encode(WS);
end;

function IfThen(Value: Boolean; const TrueStr: String; const FalseStr: String = ''): String;  overload;
begin
  if Value then
    Result := TrueStr
  else
    Result := FalseStr;
end;

function LeftStr(const Text: String; const Len: Integer): String;
begin
  Result := Copy(Text, 1, Len);
end;

function RightStr(const Text: String; const Len: Integer): String;
begin
  Result := Copy(Text, Length(Text) + 1 - Len, Len);
end;

function MidStr(const Text: String; const Start, Len: Integer): String;
begin
  Result := Copy(Text, Start, Len);
end;

function DupeString(const Text: string; Len: Integer): string;
var
   S : String;
   I : Integer;
begin
  S := '';
  for I := 0 to Len - 1 do S := S + Text;
  Result := S;
end;

end.
