program teste_codepage;

{ Testes da code page do fio (issue #1: Windows-1251 e outras alem da 1252):
  src\common\client\JVCSWireCodePage.pas e a conversao do RFormat (MWStrToBytes,
  MWBytesToStr, TMWBuffer). Nao usa servidor.
  Compilar e rodar: tests\cliente\teste-codepage.ps1 (usa o RFormat.dcu do build
  do console: rode antes tools\compilar.bat console Debug Win32). }

{$APPTYPE CONSOLE}

uses
  Windows,
  SysUtils,
  RFormat,
  JVCSWireCodePage in '..\..\src\common\client\JVCSWireCodePage.pas';

var
  OkN, FalhaN: Integer;

procedure Check(Cond: Boolean; const Msg: string);
begin
  if Cond then
  begin
    Inc(OkN);
    Writeln('[OK] ', Msg);
  end
  else
  begin
    Inc(FalhaN);
    Writeln('[FALHA] ', Msg);
  end;
end;

function Hex(const B: RawByteString): string;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(B) do
    Result := Result + IntToHex(Ord(B[I]), 2);
end;

function FromHex(const H: string): RawByteString;
var
  I: Integer;
begin
  SetLength(Result, Length(H) div 2);
  for I := 1 to Length(Result) do
    Result[I] := AnsiChar(StrToInt('$' + Copy(H, I * 2 - 1, 2)));
end;

procedure TestesParse;
var
  CP: Word;
begin
  Check(JVCSParseCodePage('1251', CP) and (CP = 1251), 'parse "1251"');
  Check(JVCSParseCodePage(' cp1251 ', CP) and (CP = 1251), 'parse "cp1251"');
  Check(JVCSParseCodePage('Windows-1250', CP) and (CP = 1250), 'parse "Windows-1250"');
  Check(JVCSParseCodePage('WIN1253', CP) and (CP = 1253), 'parse "WIN1253"');
  Check(not JVCSParseCodePage('', CP), 'parse vazio recusado');
  Check(not JVCSParseCodePage('abc', CP), 'parse "abc" recusado');
  Check(not JVCSParseCodePage('12-51', CP), 'parse "12-51" recusado');
  Check(not JVCSParseCodePage('99999', CP), 'parse "99999" recusado');
  Check(not JVCSParseCodePage('0', CP), 'parse "0" recusado');
end;

procedure TestesUsable;
begin
  Check(JVCSIsUsableCodePage(1251, False), '1251 utilizavel');
  Check(JVCSIsUsableCodePage(1252, False), '1252 utilizavel');
  Check(JVCSIsUsableCodePage(1250, False), '1250 utilizavel');
  Check(not JVCSIsUsableCodePage(65001, True), '65001 (UTF-8) recusada');
  Check(not JVCSIsUsableCodePage(1200, True), '1200 (UTF-16) recusada');
  Check(not JVCSIsUsableCodePage(0, True), '0 (CP_ACP) recusada');
  Check(not JVCSIsUsableCodePage(932, False), '932 recusada sem AllowMultiByte');
  if IsValidCodePage(932) then
    Check(JVCSIsUsableCodePage(932, True), '932 aceita com AllowMultiByte');
end;

procedure TestesLocal;
var
  Src: TJVCSCodePageSource;
  CP: Word;
begin
  SetEnvironmentVariable(cWireCodePageEnv, '1251');
  CP := JVCSLocalCodePage(Src);
  Check((CP = 1251) and (Src = cpsEnvironment), 'JVCS_WIRECODEPAGE=1251 escolhe 1251');
  SetEnvironmentVariable(cWireCodePageEnv, 'windows-1250');
  CP := JVCSLocalCodePage(Src);
  Check((CP = 1250) and (Src = cpsEnvironment), 'JVCS_WIRECODEPAGE=windows-1250 escolhe 1250');
  SetEnvironmentVariable(cWireCodePageEnv, '65001');
  CP := JVCSLocalCodePage(Src);
  Check(Src <> cpsEnvironment, 'JVCS_WIRECODEPAGE=65001 ignorado (cai no registro/ACP)');
  Check(JVCSIsUsableCodePage(CP, True), Format('sem ambiente valido: %d (%s)', [CP, JVCSCodePageSourceName(Src)]));
  SetEnvironmentVariable(cWireCodePageEnv, nil);
  CP := JVCSLocalCodePage(Src);
  if Src = cpsACP then
    Check(CP = GetACP, 'padrao = ACP de 1 byte')
  else
  if Src = cpsFallback then
    Check(CP = 1252, 'padrao = 1252 (ACP de varios bytes)')
  else
    Check(Src = cpsRegistry, Format('padrao vem do registro WireCodePage (%d)', [CP]));
end;

procedure TestesServidor;
var
  Err: string;
begin
  JVCSSetWireCodePage(1252, cpsACP);
  Check(not JVCSApplyServerWireCodePage('???', Err) and (MWCodePage = 1252) and (Err = ''),
    'servidor sem a chave ("???") nao muda');
  Check(not JVCSApplyServerWireCodePage('', Err) and (MWCodePage = 1252), 'servidor com valor vazio nao muda');
  Check(not JVCSApplyServerWireCodePage('utf8', Err) and (MWCodePage = 1252) and (Err <> ''),
    'servidor com valor invalido nao muda: ' + Err);
  Check(not JVCSApplyServerWireCodePage('65001', Err) and (MWCodePage = 1252) and (Err <> ''),
    'servidor com 65001 nao muda: ' + Err);
  Check(JVCSApplyServerWireCodePage('cp1251', Err) and (MWCodePage = 1251) and
    (JVCSWireCodePageSource = cpsServer), 'servidor cp1251 troca o fio para 1251');
  Check(not JVCSApplyServerWireCodePage('1251', Err) and (MWCodePage = 1251),
    'servidor 1251 de novo: sem mudanca');
  Check(JVCSWireCodePageInfo = '1251 (server)', 'info: ' + JVCSWireCodePageInfo);
end;

procedure TestesConversao;
const
  // "Поправка" (correcao, em bulgaro) em Windows-1251
  cPopravka1251 = 'CFEEEFF0E0E2EAE0';
var
  S: string;
  B: RawByteString;
  Buf: TMWBuffer;
begin
  S := #$041F#$043E#$043F#$0440#$0430#$0432#$043A#$0430; // Поправка
  JVCSSetWireCodePage(1251, cpsServer);
  B := MWStrToBytes(S);
  Check(Hex(B) = cPopravka1251, 'MWStrToBytes(Поправка) em 1251 = ' + Hex(B));
  Check(MWBytesToStr(FromHex(cPopravka1251)) = S, 'MWBytesToStr volta a Поправка em 1251');
  // o problema da issue: bytes 1251 do banco lidos como 1252
  JVCSSetWireCodePage(1252, cpsFallback);
  Check(MWBytesToStr(FromHex(cPopravka1251)) = #$CF#$EE#$EF#$F0#$E0#$E2#$EA#$E0,
    'mesmos bytes lidos em 1252 = mojibake da issue (Ïîïðàâêà)');
  Check(Hex(MWStrToBytes(S)) = '3F3F3F3F3F3F3F3F', 'Поправка em 1252 vira ???????? (perda da issue)');
  Check(not JVCSCanEncode(S, 1252), 'JVCSCanEncode(Поправка, 1252) = False');
  Check(JVCSCanEncode(S, 1251), 'JVCSCanEncode(Поправка, 1251) = True');
  Check(JVCSCanEncode('a'#$E7#$E3'o', 1252), 'JVCSCanEncode(ação, 1252) = True');
  Check(not JVCSCanEncode('a'#$E7#$E3'o', 1251), 'JVCSCanEncode(ação, 1251) = False');
  Check(JVCSCanEncode('', 1251), 'JVCSCanEncode vazio = True');

  // ida e volta por um TMWBuffer (o que vai e vem no fio)
  JVCSSetWireCodePage(1251, cpsServer);
  Buf := TMWBuffer.Create(nil);
  try
    Buf.Rewrite;
    Buf.WriteFields(True, [S, 42, 'x']);
    Buf.First;
    Check(Buf.Fields[0] = S, 'TMWBuffer em 1251: campo Поправка volta igual');
    Check(Buf.Fields[1] = '42', 'TMWBuffer em 1251: campo inteiro');
  finally
    Buf.Free;
  end;
  JVCSSetWireCodePage(1252, cpsFallback);
end;

begin
  OkN := 0;
  FalhaN := 0;
  TestesParse;
  TestesUsable;
  TestesLocal;
  TestesServidor;
  TestesConversao;
  Writeln;
  Writeln(OkN, ' OK, ', FalhaN, ' falha(s)');
  if FalhaN > 0 then
    ExitCode := 1;
end.
