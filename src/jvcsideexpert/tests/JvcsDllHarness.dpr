program JvcsDllHarness;
{ Harness (FORA da IDE) da JvcsExternalDll.dll REAL - a nova (port Delphi 13,
  F5) ou a original 2.5.0.1030 - pela MESMA sequencia do expert: usa o
  TJVCSDllBridge e as 24 callbacks reais do expert (JVCSExpertCallbacks), com
  um IBorlandIDEServices vazio (as callbacks devolvem vazio/0 sem IDE).

  Sequencia: Load (LoadLibraryEx na pasta do host -> JEDIVCSDLLINIT ->
  HISTORYINIT -> OPERATIONINIT) -> menu/verbos/estados/atalhos/imagens ->
  notificacoes -> ExecuteVerb de verbos com janela (About, Properties,
  Connect, ...) -> History/operacoes sem conexao -> Unload (FINALIZE e so
  entao FreeLibrary).

  Janelas: uma thread fecha (WM_CLOSE; em caixas de mensagem tambem
  IDCANCEL/IDNO) toda janela visivel do processo e registra classe e titulo -
  prova que o verbo abriu a janela.
  Access violation: um vectored exception handler conta TODA
  EXCEPTION_ACCESS_VIOLATION do processo (primeira chance, tratada ou nao).

  Uso: JvcsDllHarness.exe [verbos]  (verbos = indices separados por virgula;
  padrao: os verbos "seguros" por nome). Rodar com tests\testar-dll.bat.
  Saida: codigo = numero de falhas. NAO conecta ao servidor. }
{$APPTYPE CONSOLE}
{$R JvcsDllHarness.res} // VERSIONINFO (gerado pelo testar-dll.bat com brcc32)
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, ToolsAPI,
  JVCSExpertABI, JVCSExpertUtils, JVCSExpertDllBridge;

type
  TFakeServices = class(TInterfacedObject, IBorlandIDEServices70, IBorlandIDEServices)
    function SupportsService(const Service: TGUID): Boolean;
    function GetService(const Service: TGUID): IInterface; overload;
    function GetService(const Service: TGUID; out Svc): Boolean; overload;
  end;

  TWindowCloser = class(TThread)
  protected
    procedure Execute; override;
  end;

function TFakeServices.SupportsService(const Service: TGUID): Boolean;
begin
  Result := False;
end;

function TFakeServices.GetService(const Service: TGUID): IInterface;
begin
  Result := nil;
end;

function TFakeServices.GetService(const Service: TGUID; out Svc): Boolean;
begin
  Pointer(Svc) := nil;
  Result := False;
end;

var
  Fails: Integer = 0;
  AVCount: Integer = 0;
  WinLock: TRTLCriticalSection;
  WinSeen: TStringList;

procedure Check(Cond: Boolean; const What: string);
begin
  if Cond then
    Writeln('  ok   ', What)
  else
  begin
    Inc(Fails);
    Writeln('  FAIL ', What);
  end;
end;

function AVHandler(ExceptionInfo: PExceptionPointers): Longint; stdcall;
begin
  if (ExceptionInfo <> nil) and (ExceptionInfo^.ExceptionRecord <> nil) and
    (ExceptionInfo^.ExceptionRecord^.ExceptionCode = EXCEPTION_ACCESS_VIOLATION) then
    InterlockedIncrement(AVCount);
  Result := 0; // EXCEPTION_CONTINUE_SEARCH
end;

function AddVectoredExceptionHandler(First: ULONG; Handler: Pointer): Pointer; stdcall;
  external kernel32 name 'AddVectoredExceptionHandler';

{ TWindowCloser }

type
  PCloseState = ^TCloseState;
  TCloseState = record
    Pid: DWORD;
    Found: Boolean;
  end;

function WndText(H: HWND; AClass: Boolean): string;
var
  Buf: array[0..511] of Char;
begin
  if AClass then
    GetClassName(H, Buf, Length(Buf))
  else
    GetWindowText(H, Buf, Length(Buf));
  Result := Buf;
end;

function DlgText(H: HWND): string;
var
  C: HWND;
  S: string;
begin
  // texto da caixa de mensagem (controle Static)
  Result := '';
  C := GetWindow(H, GW_CHILD);
  while C <> 0 do
  begin
    if SameText(WndText(C, True), 'Static') then
    begin
      S := Trim(WndText(C, False));
      if S <> '' then
        Result := Result + ' ' + S;
    end;
    C := GetWindow(C, GW_HWNDNEXT);
  end;
  Result := Trim(StringReplace(StringReplace(Result, #13, ' ', [rfReplaceAll]), #10, ' ', [rfReplaceAll]));
  if Length(Result) > 160 then
    Result := Copy(Result, 1, 160) + '...';
end;

function EnumProc(H: HWND; LParam: LPARAM): BOOL; stdcall;
var
  St: PCloseState;
  Pid: DWORD;
  Cls, Txt, Key: string;
begin
  Result := True;
  St := PCloseState(LParam);
  GetWindowThreadProcessId(H, Pid);
  if (Pid <> St^.Pid) or not IsWindowVisible(H) then
    Exit;
  Cls := WndText(H, True);
  if (Cls = 'ConsoleWindowClass') or (Cls = 'TApplication') or (Cls = 'IME') then
    Exit;
  St^.Found := True;
  Txt := WndText(H, False);
  if Cls = '#32770' then
    Txt := Txt + ' | ' + DlgText(H);
  Key := Format('%s "%s"', [Cls, Txt]);
  EnterCriticalSection(WinLock);
  try
    if WinSeen.IndexOf(Key) < 0 then
    begin
      WinSeen.Add(Key);
      Writeln('       [janela] ', Key);
    end;
  finally
    LeaveCriticalSection(WinLock);
  end;
  PostMessage(H, WM_CLOSE, 0, 0);
  if Cls = '#32770' then
  begin
    PostMessage(H, WM_COMMAND, IDCANCEL, 0);
    PostMessage(H, WM_COMMAND, IDNO, 0);
  end;
end;

procedure TWindowCloser.Execute;
var
  St: TCloseState;
begin
  St.Pid := GetCurrentProcessId;
  while not Terminated do
  begin
    Sleep(700);
    St.Found := False;
    EnumWindows(@EnumProc, LPARAM(@St));
  end;
end;

function WindowsSeenSince(AStart: Integer): string;
var
  I: Integer;
begin
  Result := '';
  EnterCriticalSection(WinLock);
  try
    for I := AStart to WinSeen.Count - 1 do
      Result := Result + WinSeen[I] + '; ';
  finally
    LeaveCriticalSection(WinLock);
  end;
end;

function SeenCount: Integer;
begin
  EnterCriticalSection(WinLock);
  try
    Result := WinSeen.Count;
  finally
    LeaveCriticalSection(WinLock);
  end;
end;

function FileVer(const AFile: string; AProductText: Boolean): string;
var
  Size, Dummy: DWORD;
  Buf: TBytes;
  FI: PVSFixedFileInfo;
  P: PChar;
  L: UINT;
begin
  Result := '?';
  Size := GetFileVersionInfoSize(PChar(AFile), Dummy);
  if Size = 0 then
    Exit;
  SetLength(Buf, Size);
  if not GetFileVersionInfo(PChar(AFile), 0, Size, @Buf[0]) then
    Exit;
  if AProductText then
  begin
    if VerQueryValue(@Buf[0], '\StringFileInfo\040904E4\ProductVersion', Pointer(P), L) then
      Result := P;
  end
  else
  if VerQueryValue(@Buf[0], '\', Pointer(FI), L) then
    Result := Format('%d.%d.%d.%d', [HiWord(FI.dwFileVersionMS), LoWord(FI.dwFileVersionMS),
      HiWord(FI.dwFileVersionLS), LoWord(FI.dwFileVersionLS)]);
end;

function StripAccel(const S: string): string;
begin
  Result := StringReplace(S, '&', '', [rfReplaceAll]);
end;

var
  Bridge: TJVCSDllBridge;
  Closer: TWindowCloser;
  I, N, AV0, W0, Idx: Integer;
  S, Verb, VerbsArg: string;
  Verbs: TStringList;
  ToRun: TList;
  Cancel: Boolean;
  MS: TMemoryStream;
  T0: Cardinal;
begin
  ExitCode := 0;
  InitializeCriticalSection(WinLock);
  WinSeen := TStringList.Create;
  AddVectoredExceptionHandler(1, @AVHandler);
  ToolsAPI.BorlandIDEServices := TFakeServices.Create;
  Closer := TWindowCloser.Create(False);
  Verbs := TStringList.Create;
  ToRun := TList.Create;
  try
    try
      VerbsArg := ParamStr(1);
      Bridge := TJVCSDllBridge.Create;
      JVCSBridge := Bridge;
      try
        Writeln('== 1) Load: LoadLibraryEx + JEDIVCSDLLINIT/HISTORYINIT/OPERATIONINIT');
        T0 := GetTickCount;
        Check(Bridge.Load, 'Load ' + Bridge.LoadError);
        if not Bridge.Loaded then
          Exit;
        Writeln('       DLL: ', Bridge.DllPath);
        Writeln(Format('       versao: arquivo %s, produto "%s" - INIT em %d ms',
          [FileVer(Bridge.DllPath, False), FileVer(Bridge.DllPath, True), GetTickCount - T0]));
        Check(Bridge.InitResult, 'JEDIVCSDLLINIT = True');
        Check(Bridge.HasHistory, 'HISTORYINIT: 9 funcoes de History');
        Check(Bridge.HasOperations, 'OPERATIONINIT: funcoes de operacao');
        Check(AVCount = 0, Format('nenhuma AV no INIT (AVs=%d)', [AVCount]));

        Writeln('== 2) Menu e verbos');
        S := Bridge.GetMenuName;
        Writeln('       GetMenuName = "', S, '"');
        Check(Pos('JEDI', StripAccel(S)) > 0, 'GetMenuName contem JEDI');
        N := Bridge.GetVerbCount;
        Writeln('       GetVerbCount = ', N);
        Check(N >= 27, 'GetVerbCount >= 27');
        for I := 0 to N - 1 do
        begin
          Verb := Bridge.GetVerb(I);
          Verbs.Add(Verb);
          Writeln(Format('       %2d  estado=%d  atalho=$%.4x  img=%2d  "%s"',
            [I, Bridge.GetVerbState(I), Bridge.GetVerbShortCut(I), Bridge.GetVerbImageIndex(I), Verb]));
        end;
        MS := TMemoryStream.Create;
        try
          Check(Bridge.GetVerbImages(MS, 16, 16) = gvirOkay, 'GetVerbImages 16x16');
          Writeln('       BMP das imagens: ', MS.Size, ' bytes');
        finally
          MS.Free;
        end;
        Check(AVCount = 0, Format('nenhuma AV nos verbos (AVs=%d)', [AVCount]));

        Writeln('== 3) Notificacoes (sem projeto aberto)');
        Cancel := False;
        Bridge.FileNotification(ifnFileOpened, 'c:\nao\existe\unit1.pas', Cancel);
        Bridge.EventNotification(ienBeforeCompile, Cancel);
        Bridge.EventNotification(ienAfterCompile, Cancel);
        Bridge.ProjectChange;
        Check(not Cancel, 'Cancel continua False');
        Check(Bridge.HistoryCount('c:\nao\existe\unit1.pas') = 0, 'HistoryCount sem conexao = 0');
        Check(AVCount = 0, Format('nenhuma AV nas notificacoes (AVs=%d)', [AVCount]));

        Writeln('== 4) ExecuteVerb (janelas fechadas automaticamente)');
        if VerbsArg <> '' then
        begin
          with TStringList.Create do
          try
            CommaText := VerbsArg;
            for I := 0 to Count - 1 do
              ToRun.Add(Pointer(StrToInt(Strings[I])));
          finally
            Free;
          end;
        end
        else
          for I := 0 to Verbs.Count - 1 do
          begin
            S := StripAccel(Verbs[I]);
            // so verbos que nao precisam de servidor/projeto e nao alteram nada
            if (Pos('About', S) = 1) or (Pos('VCS Properties', S) = 1) or
              (Pos('Connect Server', S) = 1) or (Pos('Recent Projects', S) = 1) or
              (Pos('Project Manager', S) = 1) then
              ToRun.Add(Pointer(I));
          end;
        for I := 0 to ToRun.Count - 1 do
        begin
          Idx := Integer(ToRun[I]);
          if (Idx < 0) or (Idx >= Verbs.Count) then
            Continue;
          AV0 := AVCount;
          W0 := SeenCount;
          Writeln(Format('     ExecuteVerb(%d) "%s"', [Idx, Verbs[Idx]]));
          T0 := GetTickCount;
          Bridge.ExecuteVerb(Idx);
          Writeln(Format('       voltou em %d ms', [GetTickCount - T0]));
          Check(AVCount = AV0, Format('ExecuteVerb(%d) sem AV (AVs=%d)', [Idx, AVCount - AV0]));
          if SeenCount = W0 then
            Writeln('       (nenhuma janela nova)');
        end;

        Writeln('== 5) Operacoes sem conexao');
        AV0 := AVCount;
        Writeln('       OpGetProjectID = ', Bridge.OpGetProjectID('c:\nao\existe\proj.dpr'));
        Check(AVCount = AV0, 'OpGetProjectID sem AV');

        Writeln('== 6) Unload: JEDIVCSDLLFINALIZE e FreeLibrary');
        AV0 := AVCount;
        Bridge.Unload;
        Check(not Bridge.Loaded, 'Unload');
        Check(AVCount = AV0, Format('FINALIZE/FreeLibrary sem AV (AVs=%d)', [AVCount - AV0]));
      finally
        JVCSBridge := nil;
        Bridge.Free;
      end;
    except
      on E: Exception do
      begin
        Inc(Fails);
        Writeln('EXCECAO NO HOST: ', E.ClassName, ': ', E.Message);
      end;
    end;
  finally
    Closer.Terminate;
    Closer.WaitFor;
    Closer.Free;
    ToolsAPI.BorlandIDEServices := nil;
    Verbs.Free;
    ToRun.Free;
  end;
  Writeln;
  Writeln('Janelas abertas pela DLL: ', WinSeen.Count);
  Check(AVCount = 0, Format('TOTAL de access violations no processo = %d', [AVCount]));
  Writeln('RESULTADO HARNESS fails=', Fails);
  WinSeen.Free;
  ExitCode := Fails;
end.
