(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSErrorLog.pas

The Initial Developer of the original code (JEDI VCS v2026) is the JEDI VCS
port team (2026).

Purpose:
  Log de erros do cliente GUI (EXE e DLL da IDE):
  %LOCALAPPDATA%\JEDI\JVCS\logs\jvcs-<exe|dll>-AAAAMMDD.log
  Cada entrada: data/hora, processo, modulo e versao, onde (contexto), classe
  e mensagem da excecao, endereco (modulo+offset) e, quando o .map/JDBG do
  modulo estiver disponivel, unit/rotina/linha (JclDebug). Nunca grava senha:
  so a mensagem da excecao e o contexto passado pelo chamador.
  - JVCSErrorLogInstall: Application.OnException (encadeado; mostra a
    mensagem como antes) e, na DLL, mensagem unica (sem cascata) por
    JVCSErrorLogShow.
  - JVCSLogException(E, Onde): para os try/except das entradas exportadas da
    DLL, callbacks do expert e fechamento de forms.

Unit history:

2026/10/13  v2026      - nova unit (F5: controle de erros)

-----------------------------------------------------------------------------*)

unit JVCSErrorLog;

interface

uses
  SysUtils;

{ grava a excecao no log (nunca levanta excecao) }
procedure JVCSLogException(E: TObject; const AWhere: string; AAddr: Pointer = nil);
{ grava uma linha informativa }
procedure JVCSLogMessage(const AText: string);
{ instala Application.OnException (log + mensagem); AIsDll = DLL na IDE }
procedure JVCSErrorLogInstall(AIsDll: Boolean);
procedure JVCSErrorLogUninstall;
{ mensagem amigavel unica (DLL): nao abre outra enquanto uma estiver aberta }
procedure JVCSErrorLogShow(E: TObject; const AWhere: string);
{ caminho do log de hoje }
function JVCSErrorLogFile: string;

implementation

uses
  Windows, Classes, Forms, JclDebug;

type
  TJVCSErrorHandler = class
  private
    FOldHandler: TExceptionEvent;
    FIsDll: Boolean;
  public
    procedure HandleException(Sender: TObject; E: Exception);
  end;

var
  GHandler: TJVCSErrorHandler = nil;
  GOldExceptProc: Pointer = nil;
  GLock: TRTLCriticalSection;
  GShowing: Boolean = False;
  GIsDll: Boolean = False;

function ModuleKind: string;
begin
  if IsLibrary then
    Result := 'dll'
  else
    Result := 'exe';
end;

function JVCSErrorLogFile: string;
var
  Dir: string;
begin
  Dir := GetEnvironmentVariable('LOCALAPPDATA');
  if Dir = '' then
    Dir := GetEnvironmentVariable('TEMP');
  Result := IncludeTrailingPathDelimiter(Dir) + 'JEDI\JVCS\logs\jvcs-' + ModuleKind +
    '-' + FormatDateTime('yyyymmdd', Now) + '.log';
end;

function ModuleVersion(const AFile: string): string;
var
  Size, Dummy: DWORD;
  Buf: TBytes;
  FI: PVSFixedFileInfo;
  L: UINT;
begin
  Result := '?';
  Size := GetFileVersionInfoSize(PChar(AFile), Dummy);
  if Size = 0 then
    Exit;
  SetLength(Buf, Size);
  if GetFileVersionInfo(PChar(AFile), 0, Size, @Buf[0]) and
     VerQueryValue(@Buf[0], '\', Pointer(FI), L) then
    Result := Format('%d.%d.%d.%d', [HiWord(FI.dwFileVersionMS), LoWord(FI.dwFileVersionMS),
      HiWord(FI.dwFileVersionLS), LoWord(FI.dwFileVersionLS)]);
end;

procedure AppendText(const AText: string);
var
  F, Dir: string;
  S: TFileStream;
  B: TBytes;
begin
  F := JVCSErrorLogFile;
  Dir := ExtractFileDir(F);
  if not DirectoryExists(Dir) then
    ForceDirectories(Dir);
  B := TEncoding.UTF8.GetBytes(AText);
  if FileExists(F) then
    S := TFileStream.Create(F, fmOpenReadWrite or fmShareDenyWrite)
  else
  begin
    S := TFileStream.Create(F, fmCreate or fmShareDenyWrite);
    S.WriteBuffer(TEncoding.UTF8.GetPreamble[0], 3);
  end;
  try
    S.Seek(0, soEnd);
    if Length(B) > 0 then
      S.WriteBuffer(B[0], Length(B));
  finally
    S.Free;
  end;
end;

function AddrText(AAddr: Pointer): string;
var
  Mbi: TMemoryBasicInformation;
  ModName: array [0..MAX_PATH] of Char;
  Info: string;
begin
  Result := '';
  if AAddr = nil then
    Exit;
  Result := Format('$%p', [AAddr]);
  if (VirtualQuery(AAddr, Mbi, SizeOf(Mbi)) > 0) and (Mbi.AllocationBase <> nil) and
     (GetModuleFileName(HMODULE(Mbi.AllocationBase), ModName, Length(ModName)) > 0) then
    Result := Result + Format(' (%s+$%x)', [ExtractFileName(ModName),
      NativeUInt(AAddr) - NativeUInt(Mbi.AllocationBase)]);
  try
    Info := GetLocationInfoStr(AAddr, False, True, True, True);
    if Info <> '' then
      Result := Result + ' ' + Info;
  except
  end;
end;

procedure JVCSLogMessage(const AText: string);
begin
  try
    EnterCriticalSection(GLock);
    try
      AppendText(FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + ' ' + AText + #13#10);
    finally
      LeaveCriticalSection(GLock);
    end;
  except
    // o log nunca derruba o programa
  end;
end;

procedure JVCSLogException(E: TObject; const AWhere: string; AAddr: Pointer);
var
  Msg, Cls, ModFile: string;
  Buf: array [0..MAX_PATH] of Char;
begin
  try
    if AAddr = nil then
      AAddr := ExceptAddr;
    if E is Exception then
      Msg := Exception(E).Message
    else
      Msg := '';
    if Assigned(E) then
      Cls := E.ClassName
    else
      Cls := '(nil)';
    GetModuleFileName(HInstance, Buf, Length(Buf));
    ModFile := Buf;
    JVCSLogMessage(Format('ERRO [%s] pid=%d %s %s | onde: %s | %s: %s | endereco: %s',
      [ModuleKind, GetCurrentProcessId, ExtractFileName(ModFile), ModuleVersion(ModFile),
       AWhere, Cls, StringReplace(Msg, #13#10, ' ', [rfReplaceAll]), AddrText(AAddr)]));
  except
  end;
end;

procedure JVCSErrorLogShow(E: TObject; const AWhere: string);
var
  Msg: string;
begin
  if GShowing then
    Exit; // sem cascata: uma mensagem por vez
  GShowing := True;
  try
    if E is Exception then
      Msg := Exception(E).Message
    else
      Msg := 'Unknown error';
    MessageBox(Application.Handle, PChar('JEDI VCS: ' + Msg + #13#10#13#10 +
      'Details were written to ' + JVCSErrorLogFile), 'JEDI VCS',
      MB_OK or MB_ICONERROR or MB_TASKMODAL);
  finally
    GShowing := False;
  end;
end;

{ excecao nao tratada (fora do laco de mensagens da VCL) }
procedure JVCSExceptProc(ExceptObject: TObject; ExceptAddr: Pointer);
type
  TExceptProcType = procedure(ExceptObject: TObject; ExceptAddr: Pointer);
begin
  JVCSLogException(ExceptObject, 'excecao nao tratada (ExceptProc)', ExceptAddr);
  if Assigned(GOldExceptProc) then
    TExceptProcType(GOldExceptProc)(ExceptObject, ExceptAddr);
end;

{ TJVCSErrorHandler }

procedure TJVCSErrorHandler.HandleException(Sender: TObject; E: Exception);
begin
  if Assigned(Sender) then
    JVCSLogException(E, 'Application.OnException (' + Sender.ClassName + ')')
  else
    JVCSLogException(E, 'Application.OnException');
  if E is EAbort then
    Exit;
  if FIsDll then
    JVCSErrorLogShow(E, 'Application')
  else
  if Assigned(FOldHandler) then
    FOldHandler(Sender, E)
  else
    Application.ShowException(E);
end;

procedure JVCSErrorLogInstall(AIsDll: Boolean);
begin
  GIsDll := AIsDll;
  if Assigned(GHandler) then
    Exit;
  GHandler := TJVCSErrorHandler.Create;
  GHandler.FIsDll := AIsDll;
  GHandler.FOldHandler := Application.OnException;
  Application.OnException := GHandler.HandleException;
  GOldExceptProc := ExceptProc;
  ExceptProc := @JVCSExceptProc;
  JVCSLogMessage(Format('inicio [%s] pid=%d', [ModuleKind, GetCurrentProcessId]));
end;

procedure JVCSErrorLogUninstall;
begin
  if not Assigned(GHandler) then
    Exit;
  if Assigned(Application) and
     (TMethod(Application.OnException).Data = Pointer(GHandler)) then
    Application.OnException := GHandler.FOldHandler;
  if ExceptProc = @JVCSExceptProc then
    ExceptProc := GOldExceptProc;
  FreeAndNil(GHandler);
end;

initialization
  InitializeCriticalSection(GLock);

finalization
  JVCSErrorLogUninstall;
  DeleteCriticalSection(GLock);

end.
