(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSWireCodePage.pas

The Initial Developer of the original code (JEDI VCS v2026) is the JEDI VCS
port team (2026).

Purpose:
  Code page dos textos no fio (comentarios de check-in, nomes, labels,
  descricoes), a RFormat.MWCodePage.
  O servidor 2.5 grava os bytes como recebe (Firebird com lc_ctype NONE): a
  code page e uma propriedade do BANCO, e todas as estacoes precisam usar a
  mesma. O cliente ANSI original (Delphi 2007) usava a ACP de cada estacao.
  Ordem de escolha:
    1. servidor: chave WireCodePage da secao [GlobalUserData] do ini do
       servidor, lida com READ_CONFIG_DATA logo depois do login (funciona com
       qualquer servidor 2.x, sem mudar o protocolo);
    2. estacao: variavel de ambiente JVCS_WIRECODEPAGE ou o valor
       WireCodePage (texto) em HKCU\Software\JEDI\JEDIVCS;
    3. padrao: a ACP do Windows, se for de 1 byte (como o cliente original);
       senao 1252 (ACP 65001, "Beta: UTF-8").
  Valores aceitos: "1251", "cp1251", "windows-1251", "win1251". UTF-7/8/16/32
  sao recusados (o servidor e os campos de tamanho fixo contam bytes); as
  ANSI de 2 bytes (932, 936, 949, 950, 1361) so por configuracao explicita.
  A escolha local (2 e 3) tambem e a code page do console jvcs.exe (stdin,
  stdout, /input, descriptionfile): as ferramentas tools\ai passam
  JVCS_WIRECODEPAGE ao jvcs.exe para ler e gravar na mesma code page.

Unit history:

2026/11/17  v2026      - nova unit (issue #1: code pages diferentes de 1252)

-----------------------------------------------------------------------------*)

unit JVCSWireCodePage;

interface

uses
  Windows, SysUtils, Registry, RFormat;

const
  cWireCodePageName = 'WireCodePage';           // [GlobalUserData] do servidor e valor do registro
  cWireCodePageEnv = 'JVCS_WIRECODEPAGE';       // variavel de ambiente (estacao)
  cWireCodePageRegKey = 'Software\JEDI\JEDIVCS'; // HKCU
  cWireCodePageFallback = 1252;

type
  TJVCSCodePageSource = (cpsFallback, cpsACP, cpsRegistry, cpsEnvironment, cpsServer);

{ Converte "1251", "cp1251", "windows-1251" ou "win1251" no numero. }
function JVCSParseCodePage(const S: string; out CodePage: Word): Boolean;
{ Code page instalada e utilizavel no fio. AllowMultiByte: aceita as de 2 bytes. }
function JVCSIsUsableCodePage(CodePage: Word; AllowMultiByte: Boolean): Boolean;
{ Escolha da estacao: ambiente > registro > ACP de 1 byte > 1252. }
function JVCSLocalCodePage(out Source: TJVCSCodePageSource): Word; overload;
function JVCSLocalCodePage: Word; overload;
{ Ajusta RFormat.MWCodePage e guarda a origem. }
procedure JVCSSetWireCodePage(CodePage: Word; Source: TJVCSCodePageSource);
{ Ajusta MWCodePage pela escolha da estacao; devolve a code page. }
function JVCSApplyLocalWireCodePage: Word;
{ Valor de WireCodePage devolvido pelo servidor ('???' ou vazio = nao
  configurado). True se a code page do fio mudou para a do servidor. Valor
  invalido nao muda nada (Error recebe o motivo). }
function JVCSApplyServerWireCodePage(const ServerValue: string; out Error: string): Boolean;
function JVCSWireCodePageSource: TJVCSCodePageSource;
function JVCSCodePageSourceName(Source: TJVCSCodePageSource): string;
{ Texto para log e Sobre: "1251 (server)". }
function JVCSWireCodePageInfo: string;
{ True se S cabe inteiro em CodePage (sem '?' de substituicao nem "best fit"). }
function JVCSCanEncode(const S: string; CodePage: Word): Boolean;

implementation

var
  GWireSource: TJVCSCodePageSource = cpsFallback;

function JVCSParseCodePage(const S: string; out CodePage: Word): Boolean;
var
  T: string;
  N: Integer;
begin
  Result := False;
  CodePage := 0;
  T := LowerCase(Trim(S));
  if Copy(T, 1, 8) = 'windows-' then
    Delete(T, 1, 8)
  else
  if Copy(T, 1, 3) = 'win' then
    Delete(T, 1, 3)
  else
  if Copy(T, 1, 2) = 'cp' then
    Delete(T, 1, 2);
  T := Trim(T);
  if (T = '') or (Length(T) > 5) then
    Exit;
  for N := 1 to Length(T) do
    if not CharInSet(T[N], ['0'..'9']) then
      Exit;
  N := StrToIntDef(T, 0);
  if (N > 0) and (N <= 65535) then
  begin
    CodePage := N;
    Result := True;
  end;
end;

function JVCSIsUsableCodePage(CodePage: Word; AllowMultiByte: Boolean): Boolean;
var
  Info: TCPInfo;
begin
  Result := False;
  case CodePage of
    0, 1, 2, 3, 42,            // CP_ACP, CP_OEMCP, CP_MACCP, CP_THREAD_ACP, CP_SYMBOL
    1200, 1201, 12000, 12001,  // UTF-16/32
    65000, 65001:              // UTF-7/8
      Exit;
  end;
  if not IsValidCodePage(CodePage) then
    Exit;
  if not GetCPInfo(CodePage, Info) then
    Exit;
  if Info.MaxCharSize = 1 then
    Result := True
  else
    { as ANSI de 2 bytes do Windows (mesma lista do tools\ai\lib\jvcs-ai-common.ps1) }
    Result := AllowMultiByte and (Info.MaxCharSize = 2) and
      ((CodePage = 932) or (CodePage = 936) or (CodePage = 949) or (CodePage = 950) or (CodePage = 1361));
end;

function ReadRegistryCodePage(out CodePage: Word): Boolean;
var
  Reg: TRegistry;
begin
  Result := False;
  CodePage := 0;
  try
    Reg := TRegistry.Create(KEY_READ);
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKeyReadOnly(cWireCodePageRegKey) and Reg.ValueExists(cWireCodePageName) then
      begin
        case Reg.GetDataType(cWireCodePageName) of
          rdString, rdExpandString:
            Result := JVCSParseCodePage(Reg.ReadString(cWireCodePageName), CodePage);
          rdInteger:
            Result := JVCSParseCodePage(IntToStr(Reg.ReadInteger(cWireCodePageName)), CodePage);
        end;
      end;
    finally
      Reg.Free;
    end;
  except
    Result := False;
  end;
end;

function JVCSLocalCodePage(out Source: TJVCSCodePageSource): Word;
var
  CP: Word;
begin
  if JVCSParseCodePage(GetEnvironmentVariable(cWireCodePageEnv), CP) and
    JVCSIsUsableCodePage(CP, True) then
  begin
    Source := cpsEnvironment;
    Exit(CP);
  end;
  if ReadRegistryCodePage(CP) and JVCSIsUsableCodePage(CP, True) then
  begin
    Source := cpsRegistry;
    Exit(CP);
  end;
  CP := GetACP;
  if JVCSIsUsableCodePage(CP, False) then
  begin
    Source := cpsACP;
    Exit(CP);
  end;
  Source := cpsFallback;
  Result := cWireCodePageFallback;
end;

function JVCSLocalCodePage: Word;
var
  Source: TJVCSCodePageSource;
begin
  Result := JVCSLocalCodePage(Source);
end;

procedure JVCSSetWireCodePage(CodePage: Word; Source: TJVCSCodePageSource);
begin
  MWCodePage := CodePage;
  GWireSource := Source;
end;

function JVCSApplyLocalWireCodePage: Word;
var
  Source: TJVCSCodePageSource;
begin
  Result := JVCSLocalCodePage(Source);
  JVCSSetWireCodePage(Result, Source);
end;

function JVCSApplyServerWireCodePage(const ServerValue: string; out Error: string): Boolean;
var
  CP: Word;
  V: string;
begin
  Result := False;
  Error := '';
  V := Trim(ServerValue);
  if (V = '') or (V = '???') then
    Exit;
  if not JVCSParseCodePage(V, CP) then
  begin
    Error := Format('invalid %s "%s" on the server', [cWireCodePageName, V]);
    Exit;
  end;
  if not JVCSIsUsableCodePage(CP, True) then
  begin
    Error := Format('%s %d from the server is not installed or not supported', [cWireCodePageName, CP]);
    Exit;
  end;
  Result := CP <> MWCodePage;
  JVCSSetWireCodePage(CP, cpsServer);
end;

function JVCSWireCodePageSource: TJVCSCodePageSource;
begin
  Result := GWireSource;
end;

function JVCSCodePageSourceName(Source: TJVCSCodePageSource): string;
begin
  case Source of
    cpsACP: Result := 'Windows ANSI code page';
    cpsRegistry: Result := 'registry';
    cpsEnvironment: Result := cWireCodePageEnv;
    cpsServer: Result := 'server';
  else
    Result := 'default';
  end;
end;

function JVCSWireCodePageInfo: string;
begin
  Result := Format('%d (%s)', [MWCodePage, JVCSCodePageSourceName(GWireSource)]);
end;

function JVCSCanEncode(const S: string; CodePage: Word): Boolean;
var
  UsedDefault: BOOL;
  Back: string;
  B: RawByteString;
  Len, WLen: Integer;
begin
  Result := True;
  if S = '' then
    Exit;
  UsedDefault := False;
  Len := WideCharToMultiByte(CodePage, WC_NO_BEST_FIT_CHARS, PWideChar(S), Length(S),
    nil, 0, nil, @UsedDefault);
  if (Len <= 0) or UsedDefault then
    Exit(False);
  { ida e volta: pega o que o "default char" nao denuncia }
  SetLength(B, Len);
  WideCharToMultiByte(CodePage, WC_NO_BEST_FIT_CHARS, PWideChar(S), Length(S),
    PAnsiChar(B), Len, nil, nil);
  WLen := MultiByteToWideChar(CodePage, 0, PAnsiChar(B), Len, nil, 0);
  SetLength(Back, WLen);
  if WLen > 0 then
    MultiByteToWideChar(CodePage, 0, PAnsiChar(B), Len, PWideChar(Back), WLen);
  Result := Back = S;
end;

end.
