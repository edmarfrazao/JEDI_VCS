library FakeJvcsExternalDll;
{ DLL FALSA para teste de fumaca do expert: imita a ABI da JvcsExternalDll
  (stdcall, PAnsiChar, records 24/10/2/9/10). NAO e o cliente JEDI VCS. }
uses
  Winapi.Windows, System.SysUtils, System.AnsiStrings, System.Classes, JVCSExpertABI;

var
  IDE: PExternalIDEFunctionRec = nil;
  LogName: string;
  FinalizeCalled: Boolean = False;
  Fails: Integer = 0;

procedure Log(const S: string);
var F: TextFile;
begin
  AssignFile(F, LogName);
  if FileExists(LogName) then Append(F) else Rewrite(F);
  Writeln(F, S);
  CloseFile(F);
end;

procedure Check(Cond: Boolean; const What: string);
begin
  if Cond then Log('  ok   ' + What) else begin Inc(Fails); Log('  FAIL ' + What); end;
end;

type
  TGuardBuf = packed record
    Data: array[0..255] of AnsiChar;
    Guard: array[0..15] of Byte;
  end;

procedure InitGuard(var B: TGuardBuf);
begin
  FillChar(B.Data, SizeOf(B.Data), Ord('x'));
  FillChar(B.Guard, SizeOf(B.Guard), $CC);
end;

function GuardOK(const B: TGuardBuf): Boolean;
var I: Integer;
begin
  Result := True;
  for I := 0 to High(B.Guard) do
    if B.Guard[I] <> $CC then Exit(False);
end;

procedure TestCallbacks(const Phase: string);
var
  B, B2: TGuardBuf;
  Big: array[0..4096] of AnsiChar;
  N, Total, Pos: Integer;
  Content, Expected: AnsiString;
  FN: AnsiString;
begin
  Log('== callbacks (' + Phase + ')');
  Check(IDE^.GetOptions() = [ioSupportsShortCuts], 'GetOptions = [ioSupportsShortCuts]');
  Check(IDE^.GetParentHandle() = 0, 'GetParentHandle sem IDE = 0');
  InitGuard(B); IDE^.GetBaseRegistryKey(@B.Data[0]);
  Check((B.Data[0] = #0) and GuardOK(B), 'GetBaseRegistryKey sem IDE = vazio e guarda intacta');
  InitGuard(B); IDE^.GetProjectName(@B.Data[0]);
  Check((B.Data[0] = #0) and GuardOK(B), 'GetProjectName sem projeto = vazio');
  Check(IDE^.GetUnitCount() = 0, 'GetUnitCount = 0');
  InitGuard(B); IDE^.GetUnitName(5, @B.Data[0]);
  Check((B.Data[0] = #0) and GuardOK(B), 'GetUnitName fora do intervalo = vazio');
  Check(IDE^.GetFormCount() = 0, 'GetFormCount = 0');
  InitGuard(B); IDE^.GetFormName(0, @B.Data[0]); Check(B.Data[0] = #0, 'GetFormName = vazio');
  InitGuard(B); IDE^.GetCurrentFile(@B.Data[0]); Check((B.Data[0] = #0) and GuardOK(B), 'GetCurrentFile = vazio');
  Check(not IDE^.IsFileOpen('c:\nao\existe.pas'), 'IsFileOpen = False');
  Check(not IDE^.IsFileOpen(nil), 'IsFileOpen(nil) = False');
  Check(IDE^.GetModuleCount() = 0, 'GetModuleCount = 0');
  InitGuard(B); IDE^.GetModuleName(0, @B.Data[0]); Check(B.Data[0] = #0, 'GetModuleName = vazio');
  Check(IDE^.GetComponentCount(0) = 0, 'GetComponentCount = 0');
  InitGuard(B); IDE^.GetComponentName(0, 0, @B.Data[0]); Check(B.Data[0] = #0, 'GetComponentName = vazio');
  Check(IDE^.GetModuleComponentCount('x.pas') = 0, 'GetModuleComponentCount = 0');
  InitGuard(B); InitGuard(B2);
  Check(not IDE^.GetModuleComponent('x.pas', 0, @B.Data[0], @B2.Data[0]), 'GetModuleComponent = False');
  Check(not IDE^.SourceWriteString('x.pas', 0, 'abc'), 'SourceWriteString sem modulo = False');
  Check(not IDE^.IsFileOpenAndWriteable('x.pas'), 'IsFileOpenAndWriteable = False');
  Check(not IDE^.CloseFile('x.pas'), 'CloseFile sem IDE = False');
  Check(not IDE^.SaveFile('x.pas'), 'SaveFile sem IDE = False');
  Check(not IDE^.OpenFile('x.pas'), 'OpenFile sem IDE = False');
  Check(not IDE^.CloseProject(), 'CloseProject sem IDE = False');
  Check(IDE^.SourceReadString('c:\nao\existe.pas', 0, @Big[0], 2048) = 0, 'SourceReadString inexistente = 0');
  // arquivo UTF-8 com BOM em disco (fallback quando o modulo nao esta aberto)
  FN := AnsiString(ExtractFilePath(LogName) + 'utf8test.pas');
  Content := '';
  Total := 0;
  Pos := 0;
  repeat
    N := IDE^.SourceReadString(PAnsiChar(FN), Pos, @Big[0], 2048);
    Check((N >= 0) and (N <= 2048) and (Big[N] = #0),
      Format('SourceReadString bloco pos=%d n=%d terminado em #0', [Pos, N]));
    if N > 0 then
    begin
      SetLength(Content, Total + N);
      Move(Big[0], Content[Total + 1], N);
      Inc(Total, N);
    end;
    Inc(Pos, N);
  until N < 2048;
  Log(Format('  info SourceReadString total=%d bytes', [Total]));
  Expected := #$E7#$E3#$6F#$20#$E9#$E1#$FC;
  Check((Total > 2048) and (Copy(Content, 1, 7) = Expected),
    'UTF-8 -> ANSI 1252 (cao eau com acentos) e leitura em varios blocos');
  Check((Total > 0) and (Content[Total] = 'Z'), 'ultimo byte preservado');
end;

procedure GetIDString(AIDString: PAnsiChar); stdcall;
begin
  System.AnsiStrings.StrCopy(AIDString, 'FAKE');
end;

procedure ExecuteVerb(const AIndex: Integer); stdcall;
begin
  Log(Format('ExecuteVerb(%d)', [AIndex]));
  if AIndex = 2 then
    raise Exception.Create('excecao proposital dentro da DLL falsa');
  if AIndex = 1 then
    TestCallbacks('dentro de ExecuteVerb');
end;

procedure GetMenuName(AMenuName: PAnsiChar); stdcall;
begin
  System.AnsiStrings.StrCopy(AMenuName, '&JEDI VCS (fake)');
end;

procedure GetVerb(const AIndex: Integer; AVerb: PAnsiChar); stdcall;
var
  S: AnsiString;
begin
  case AIndex of
    0: S := 'C&onnect Server...';
    1: S := '';
    2: S := AnsiString(StringOfChar('V', 1500));  // > 256: o expert precisa de buffer grande
  else
    S := 'x';
  end;
  System.AnsiStrings.StrPCopy(AVerb, S);  // como a DLL real: sem limite
end;

function GetVerbCount: Integer; stdcall;
begin
  Result := 3;
end;

function GetVerbState(const AIndex: Integer): Word; stdcall;
begin
  Result := ivsEnabled;
  if AIndex = 0 then
    Result := Result or ivsChecked;
end;

procedure ProjectChange; stdcall;
begin
  Log('ProjectChange');
end;

function GetVerbImages(ABMPContent: Pointer; const AMaxBMPContentSize, AImageWidth,
  AImageHeight: Integer; var ABMPContentSize: Integer): TGetVerbImagesResult; stdcall;
begin
  ABMPContentSize := 0;
  Result := gvirContainsNoImages;
end;

function GetVerbImageIndex(const AIndex: Integer): Integer; stdcall;
begin
  Result := -1;
end;

function GetVerbShortCut(const AIndex: Integer): Word; stdcall;
begin
  if AIndex = 1 then
    Result := $6049
  else
    Result := 0;
end;

procedure FileNotification(const ANotifyCode: TIDEFileNotification;
  const AFileName: PAnsiChar; var ACancel: Boolean); stdcall;
begin
  Log(Format('FileNotification(%d, "%s", Cancel=%s)',
    [Ord(ANotifyCode), string(AnsiString(AFileName)), BoolToStr(ACancel, True)]));
  ACancel := False;
end;

procedure EventNotification(const ANotifyCode: TIDEEventNotification;
  var ACancel: Boolean); stdcall;
begin
  Log(Format('EventNotification(%d, Cancel=%s)', [Ord(ANotifyCode), BoolToStr(ACancel, True)]));
end;

function HCount(AModuleName: PAnsiChar): Integer; stdcall;
begin
  Log('GetModuleHistoryCount(' + string(AnsiString(AModuleName)) + ')');
  Result := 2;
end;

function HAuthor(AModuleName: PAnsiChar; AIndex: Integer; AnAuthor: PAnsiChar): Boolean; stdcall;
begin
  System.AnsiStrings.StrPCopy(AnAuthor, AnsiString(Format('autor%d', [AIndex])));
  Result := True;
end;

function HVer(AModuleName: PAnsiChar; AIndex: Integer; AVersionStr: PAnsiChar): Boolean; stdcall;
begin
  System.AnsiStrings.StrPCopy(AVersionStr, AnsiString(Format('1.%.3d', [AIndex])));
  Result := True;
end;

function HLabelCount(AModuleName: PAnsiChar; AIndex: Integer): Integer; stdcall;
begin
  Result := 1;
end;

function HLabel(AModuleName: PAnsiChar; AIndex: Integer; ALabelIndex: Integer;
  ALabelStr: PAnsiChar): Boolean; stdcall;
begin
  System.AnsiStrings.StrCopy(ALabelStr, 'REL_1');
  Result := True;
end;

function HDate(AModuleName: PAnsiChar; AIndex: Integer; var ADate: TDateTime): Boolean; stdcall;
begin
  ADate := EncodeDate(2011, 9, 21);
  Result := True;
end;

function HComment(AModuleName: PAnsiChar; AIndex: Integer; AComment: PAnsiChar;
  AMaxCommentSize: Integer): Boolean; stdcall;
var
  S: AnsiString;
begin
  S := AnsiString(StringOfChar('c', 5000)) + AnsiString(#$E7#$E3) + 'o';
  System.AnsiStrings.StrPCopy(AComment, Copy(S, 1, AMaxCommentSize));  // como a DLL real
  Result := True;
end;

function HContentSize(AModuleName: PAnsiChar; AIndex: Integer): Integer; stdcall;
begin
  Result := 10;
end;

function HContent(AModuleName: PAnsiChar; AIndex: Integer; AContentPtr: Pointer): Boolean; stdcall;
begin
  Move(PAnsiChar('0123456789')^, AContentPtr^, 10);
  Result := True;
end;

function OGetProjectID(AProjectName: PAnsiChar): Integer; stdcall;
begin
  Log('GetProjectID(' + string(AnsiString(AProjectName)) + ')');
  Result := 42;
end;

function OCheckIn(AProjectID: Integer; AModuleName: PAnsiChar): Boolean; stdcall;
begin
  Log(Format('ModuleOp(%d, %s)', [AProjectID, string(AnsiString(AModuleName))]));
  Result := True;
end;

function OCompare(AProjectID: Integer; AModuleName, AModuleMember: PAnsiChar): Boolean; stdcall;
begin
  Log(Format('CompareOrDiff(%d, %s, %s)', [AProjectID, string(AnsiString(AModuleName)),
    string(AnsiString(AModuleMember))]));
  Result := True;
end;

function OProj(AProjectID: Integer): Boolean; stdcall;
begin
  Log(Format('ProjectOp(%d)', [AProjectID]));
  Result := True;
end;

function JediVCSDLLInit(AIDE: PExternalIDEFunctionRec; AVCS: PExternalVCSFunctionRec;
  ANotifier: PExternalNotifierFunctionRec): Boolean; stdcall;
var
  I: Integer;
  P: PPointer;
begin
  Log('JEDIVCSDLLINIT');
  IDE := AIDE;
  P := PPointer(AIDE);
  for I := 1 to 24 do
  begin
    Check(P^ <> nil, Format('IDE rec ponteiro %d preenchido', [I]));
    Inc(P);
  end;
  AVCS^.GetIDString := GetIDString;
  AVCS^.ExecuteVerb := ExecuteVerb;
  AVCS^.GetMenuName := GetMenuName;
  AVCS^.GetVerb := GetVerb;
  AVCS^.GetVerbCount := GetVerbCount;
  AVCS^.GetVerbState := GetVerbState;
  AVCS^.ProjectChange := ProjectChange;
  AVCS^.GetVerbImages := GetVerbImages;
  AVCS^.GetVerbImageIndex := GetVerbImageIndex;
  AVCS^.GetVerbShortCut := GetVerbShortCut;
  ANotifier^.FileNotification := FileNotification;
  ANotifier^.EventNotification := EventNotification;
  TestCallbacks('INIT');
  Result := True;
end;

procedure JediVCSDLLFinalize; stdcall;
begin
  FinalizeCalled := True;
  Log('JEDIVCSDLLFINALIZE');
  Check(Assigned(IDE) and (IDE^.GetOptions() = [ioSupportsShortCuts]),
    'record IDE ainda valido durante FINALIZE');
  Log(Format('RESULTADO_FAKE fails=%d', [Fails]));
end;

function JediVCSDLLHistoryInit(ARec: PExternalVCSModuleHistoryFunctionRec): Boolean; stdcall;
begin
  Log('JEDIVCSDLLHISTORYINIT');
  ARec^.GetModuleHistoryCount := HCount;
  ARec^.GetModuleHistoryAuthor := HAuthor;
  ARec^.GetModuleHistoryVersionRevisionStr := HVer;
  ARec^.GetModuleHistoryLabelCount := HLabelCount;
  ARec^.GetModuleHistoryLabel := HLabel;
  ARec^.GetModuleHistoryDate := HDate;
  ARec^.GetModuleHistoryComment := HComment;
  ARec^.GetModuleHistoryContentSize := HContentSize;
  ARec^.GetModuleHistoryContent := HContent;
  Result := True;
end;

function JediVCSDLLOperationsInit(ARec: PExternalVCSOperationFunctionRec): Boolean; stdcall;
begin
  Log('JEDIVCSDLLOPERATIONINIT');
  ARec^.GetProjectID := OGetProjectID;
  ARec^.CheckInModule := OCheckIn;
  ARec^.CheckOutModule := OCheckIn;
  ARec^.GetModule := OCheckIn;
  ARec^.CompareModule := OCompare;
  ARec^.ShowModuleHistory := OCheckIn;
  ARec^.ShowProjectManager := OProj;
  ARec^.ShowProjectHistory := OProj;
  ARec^.SyncProject := OProj;
  ARec^.DiffModule := OCompare;
  Result := True;
end;

procedure DllEntry(Reason: Integer);
begin
  if Reason = DLL_PROCESS_DETACH then
    Log('DLL_PROCESS_DETACH (FINALIZE antes? ' + BoolToStr(FinalizeCalled, True) + ')');
end;

exports
  JediVCSDLLInit name 'JEDIVCSDLLINIT',
  JediVCSDLLFinalize name 'JEDIVCSDLLFINALIZE',
  JediVCSDLLHistoryInit name 'JEDIVCSDLLHISTORYINIT',
  JediVCSDLLOperationsInit name 'JEDIVCSDLLOPERATIONINIT';

begin
  LogName := ExtractFilePath(GetModuleName(HInstance)) + 'fake.log';
  DllProc := @DllEntry;
  Log('DLL_PROCESS_ATTACH');
end.
