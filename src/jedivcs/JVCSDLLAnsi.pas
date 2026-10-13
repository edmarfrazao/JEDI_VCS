(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSDLLAnsi.pas (JEDI VCS v2026)

-----------------------------------------------------------------------------

Unit JVCSDLLAnsi - conversoes string <-> PAnsiChar da ABI externa da IDE

  A ABI JvcsExternalDll <-> expert e ANSI (PAnsiChar, CP_ACP) desde o Delphi 7.
  No Delphi 13 string e UTF-16: estas funcoes fazem a fronteira explicita.
  - JvcsToAnsi: CP_ACP SEM "best fit" (caractere fora da pagina de codigo vira
    '?', nunca um parecido - um nome de arquivo aproximado e OUTRO arquivo).
  - JvcsFromAnsi: PAnsiChar terminado em #0 (CP_ACP) -> string.
  - JvcsAnsiCopy: StrPCopy para o buffer do expert (sem limite, como o
    original; o expert v2026 entrega buffers grandes) ou com limite AMax.

  Historico:
  2026/10/12  v2026 - nova unit (F5)
-----------------------------------------------------------------------------*)

unit JVCSDLLAnsi;

interface

function JvcsToAnsi(const S: string): AnsiString;
function JvcsFromAnsi(P: PAnsiChar): string;
// Copia S (em ANSI) + #0 para ADest. AMax < 0 = sem limite; senao no maximo
// AMax bytes de texto + #0.
procedure JvcsAnsiCopy(ADest: PAnsiChar; const S: string; AMax: Integer = -1);

implementation

uses
  Windows;

function JvcsToAnsi(const S: string): AnsiString;
var
  Len: Integer;
begin
  Result := '';
  if S = '' then
    Exit;
  Len := WideCharToMultiByte(CP_ACP, WC_NO_BEST_FIT_CHARS, PWideChar(S), Length(S),
    nil, 0, nil, nil);
  if Len <= 0 then
  begin
    Result := AnsiString(S);
    Exit;
  end;
  SetLength(Result, Len);
  WideCharToMultiByte(CP_ACP, WC_NO_BEST_FIT_CHARS, PWideChar(S), Length(S),
    PAnsiChar(Result), Len, nil, nil);
end;

function JvcsFromAnsi(P: PAnsiChar): string;
begin
  if P = nil then
    Result := ''
  else
    Result := string(AnsiString(P));
end;

procedure JvcsAnsiCopy(ADest: PAnsiChar; const S: string; AMax: Integer);
var
  A: AnsiString;
  Len: Integer;
begin
  if ADest = nil then
    Exit;
  A := JvcsToAnsi(S);
  Len := Length(A);
  if (AMax >= 0) and (Len > AMax) then
    Len := AMax;
  if Len > 0 then
    Move(PAnsiChar(A)^, ADest^, Len);
  ADest[Len] := #0;
end;

end.
