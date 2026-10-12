(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSExpertDllBridge.pas (JEDI VCS v2026)

-----------------------------------------------------------------------------

Unit JVCSExpertDllBridge - carga e chamadas da JvcsExternalDll.dll

  - Localiza a DLL SOMENTE na pasta do proprio expert, na ordem do original:
    JvcsExternalDll.dll, jedivcsexternaldll.dll, jedivcsdll.dll
    (LoadLibraryEx com LOAD_WITH_ALTERED_SEARCH_PATH).
  - Os 5 records da ABI sao campos deste objeto (endereco estavel): a DLL
    guarda o ponteiro de TExternalIDEFunctionRec ate o FINALIZE.
  - Ordem: JEDIVCSDLLINIT(@IDE,@VCS,@Notifier) -> JEDIVCSDLLHISTORYINIT ->
    JEDIVCSDLLOPERATIONINIT. Na descarga: zera VCS/Notifier/History/Operation,
    chama JEDIVCSDLLFINALIZE e SO ENTAO FreeLibrary.
  - Toda chamada para a DLL: try/except SEM "on E: Exception" (o objeto de
    excecao do Delphi 2007 e incompativel), FPU restaurada e, nas chamadas com
    UI, contexto de DPI "unaware" (ver JVCSExpertUtils).
  - Buffers que a DLL preenche (StrPCopy sem limite do lado dela) sao sempre
    bem maiores que o necessario.

  Historico:
  2026/10/12  v2026 - nova unit
-----------------------------------------------------------------------------*)

unit JVCSExpertDllBridge;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, JVCSExpertABI;

const
  cJvcsExternalDllNames: array[0..2] of string =
    ('JvcsExternalDll.dll', 'jedivcsexternaldll.dll', 'jedivcsdll.dll');

  // buffers que a DLL preenche com StrPCopy sem limite
  cDllOutBufferSize = 4096;
  // GetModuleHistoryComment: a DLL copia ate AMaxCommentSize chars + #0
  cHistoryMaxCommentSize = 16384;
  // GetVerbImages (como o original: 128 KB)
  cVerbImagesBufferSize = $20000;

type
  TJVCSDllBridge = class
  private
    FHandle: HMODULE;
    FDllPath: string;
    FExpertDir: string;
    FLoadError: string;
    FInitCalled: Boolean;
    FInitResult: Boolean;
    FFinalizeProc: TJediVCSDLLFinalize;
    FIDERec: TExternalIDEFunctionRec;
    FVCSRec: TExternalVCSFunctionRec;
    FNotifierRec: TExternalNotifierFunctionRec;
    FHistoryRec: TExternalVCSModuleHistoryFunctionRec;
    FOperationRec: TExternalVCSOperationFunctionRec;
    FHasHistory: Boolean;
    FHasOperations: Boolean;
    procedure ClearDllFunctionRecs;
    procedure DllFailure(const AFunc: string);
    function GetLoaded: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    // Localiza, carrega e inicializa. Em falha, LoadError descreve o motivo.
    function Load: Boolean;
    // Zera os records, chama JEDIVCSDLLFINALIZE e FreeLibrary.
    procedure Unload;

    property Loaded: Boolean read GetLoaded;
    property DllPath: string read FDllPath;
    property ExpertDir: string read FExpertDir;
    property LoadError: string read FLoadError;
    property InitResult: Boolean read FInitResult;
    property HasHistory: Boolean read FHasHistory;
    property HasOperations: Boolean read FHasOperations;

    { TExternalVCSFunctionRec }
    function GetMenuName: string;
    function GetVerbCount: Integer;
    function GetVerb(AIndex: Integer): string;
    function GetVerbState(AIndex: Integer): Word;
    procedure ExecuteVerb(AIndex: Integer);
    function GetVerbImageIndex(AIndex: Integer): Integer;
    function GetVerbShortCut(AIndex: Integer): Word;
    // Devolve o BMP (tira de imagens AWidth x AHeight) em AStream
    function GetVerbImages(AStream: TStream; AWidth, AHeight: Integer): TGetVerbImagesResult;
    procedure ProjectChange;
    function HasProjectChange: Boolean;

    { TExternalNotifierFunctionRec }
    function HasFileNotification: Boolean;
    procedure FileNotification(ACode: TIDEFileNotification; const AFileName: string;
      var ACancel: Boolean);
    procedure EventNotification(ACode: TIDEEventNotification; var ACancel: Boolean);

    { TExternalVCSModuleHistoryFunctionRec (AModule = nome em CP_ACP) }
    function HistoryCount(const AModule: AnsiString): Integer;
    function HistoryAuthor(const AModule: AnsiString; AIndex: Integer): string;
    function HistoryVersionRevision(const AModule: AnsiString; AIndex: Integer): string;
    function HistoryLabelCount(const AModule: AnsiString; AIndex: Integer): Integer;
    function HistoryLabel(const AModule: AnsiString; AIndex, ALabelIndex: Integer): string;
    function HistoryDate(const AModule: AnsiString; AIndex: Integer; out ADate: TDateTime): Boolean;
    function HistoryComment(const AModule: AnsiString; AIndex: Integer): string;
    // Conteudo da revisao; AStream recebe os bytes crus (como estao no arquivo)
    function HistoryContent(const AModule: AnsiString; AIndex: Integer; AStream: TStream): Boolean;

    { TExternalVCSOperationFunctionRec }
    function OpGetProjectID(const AProjectName: string): Integer;
    function OpCheckInModule(AProjectID: Integer; const AModuleName: string): Boolean;
    function OpCheckOutModule(AProjectID: Integer; const AModuleName: string): Boolean;
    function OpGetModule(AProjectID: Integer; const AModuleName: string): Boolean;
    function OpCompareModule(AProjectID: Integer; const AModuleName, AMember: string): Boolean;
    function OpDiffModule(AProjectID: Integer; const AModuleName, AMember: string): Boolean;
    function OpShowModuleHistory(AProjectID: Integer; const AModuleName: string): Boolean;
    function OpShowProjectManager(AProjectID: Integer): Boolean;
    function OpShowProjectHistory(AProjectID: Integer): Boolean;
    function OpSyncProject(AProjectID: Integer): Boolean;
  end;

var
  // instancia unica (criada/destruida pelo wizard); usada pelos notifiers,
  // pelo History provider e pelo menu do Project Manager.
  JVCSBridge: TJVCSDllBridge = nil;

implementation

uses
  JVCSExpertUtils, JVCSExpertCallbacks;

{ TJVCSDllBridge }

constructor TJVCSDllBridge.Create;
begin
  inherited Create;
  FHandle := 0;
  FExpertDir := ExtractFilePath(GetModuleName(HInstance));
  FillChar(FIDERec, SizeOf(FIDERec), 0);
  ClearDllFunctionRecs;
end;

destructor TJVCSDllBridge.Destroy;
begin
  Unload;
  inherited Destroy;
end;

function TJVCSDllBridge.GetLoaded: Boolean;
begin
  Result := (FHandle <> 0) and FInitCalled;
end;

procedure TJVCSDllBridge.ClearDllFunctionRecs;
begin
  FillChar(FVCSRec, SizeOf(FVCSRec), 0);
  FillChar(FNotifierRec, SizeOf(FNotifierRec), 0);
  FillChar(FHistoryRec, SizeOf(FHistoryRec), 0);
  FillChar(FOperationRec, SizeOf(FOperationRec), 0);
  FHasHistory := False;
  FHasOperations := False;
end;

procedure TJVCSDllBridge.DllFailure(const AFunc: string);
begin
  JvcsLogCurrentException('JvcsExternalDll.' + AFunc);
end;

function TJVCSDllBridge.Load: Boolean;
var
  I: Integer;
  Path, Tried: string;
  H: HMODULE;
  Err: DWORD;
  Scope: TJvcsCallScope;
  InitProc: TJediVCSDLLInit;
  HistoryInitProc: TJediVCSDLLHistoryInit;
  OperationInitProc: TJediVCSDLLOperationInit;
  OK: Boolean;
  P: PPointer;
begin
  Result := Loaded;
  if Result then
    Exit;
  FLoadError := '';
  Tried := '';
  H := 0;
  for I := Low(cJvcsExternalDllNames) to High(cJvcsExternalDllNames) do
  begin
    Path := FExpertDir + cJvcsExternalDllNames[I];
    if not FileExists(Path) then
    begin
      Tried := Tried + sLineBreak + '  ' + Path + ' - nao encontrado';
      Continue;
    end;
    Scope.Enter(ckDllUI);
    try
      H := LoadLibraryEx(PChar(Path), 0, LOAD_WITH_ALTERED_SEARCH_PATH);
      Err := GetLastError;
    finally
      Scope.Leave;
    end;
    if H <> 0 then
    begin
      FDllPath := Path;
      Break;
    end;
    Tried := Tried + sLineBreak + '  ' + Path + ' - LoadLibrary falhou: ' +
      SysErrorMessage(Err) + Format(' (%d)', [Err]);
  end;
  if H = 0 then
  begin
    FLoadError := 'A JvcsExternalDll.dll nao foi carregada. Procurada somente na pasta do expert:' +
      Tried + sLineBreak + sLineBreak +
      'Copie JvcsExternalDll.dll, fvcscrypt.dll, zipdll.dll, unzdll.dll, *.jvcs e *.chm ' +
      'para a pasta do expert (tools\compilar-expert.bat faz isso) e reinicie a IDE (32 bits).';
    JvcsLog(FLoadError);
    Exit;
  end;

  FHandle := H;
  JvcsExternalModule := H;
  JvcsLog('JvcsExternalDll carregada: ' + FDllPath);

  @InitProc := GetProcAddress(H, cJediVCSDLLInitFuncName);
  @FFinalizeProc := GetProcAddress(H, cJediVCSDLLFinalizeFuncName);
  @HistoryInitProc := GetProcAddress(H, cJediVCSDLLInitHistoryFuncName);
  @OperationInitProc := GetProcAddress(H, cJediVCSDLLInitOperationFuncName);
  if not Assigned(InitProc) then
  begin
    FLoadError := Format('%s nao exporta %s - nao e uma JvcsExternalDll compativel.',
      [FDllPath, cJediVCSDLLInitFuncName]);
    JvcsLog(FLoadError);
    Scope.Enter(ckDll);
    try
      try
        FreeLibrary(H);
      except
        DllFailure('FreeLibrary');
      end;
    finally
      Scope.Leave;
    end;
    FHandle := 0;
    JvcsExternalModule := 0;
    Exit;
  end;

  ClearDllFunctionRecs;
  JvcsFillIDEFunctionRec(FIDERec);

  // JEDIVCSDLLINIT: a DLL preenche VCS (10) e Notifier (2) e roda
  // JediVCSInternalInit (GetOptions, GetParentHandle, GetBaseRegistryKey,
  // DataModule, auto-login eventual). O original ignora o retorno.
  FInitCalled := True;
  Scope.Enter(ckDllUI);
  try
    try
      FInitResult := InitProc(@FIDERec, @FVCSRec, @FNotifierRec);
    except
      DllFailure(cJediVCSDLLInitFuncName);
      FInitResult := False;
      FLoadError := 'JEDIVCSDLLINIT gerou uma excecao (veja o log).';
    end;
  finally
    Scope.Leave;
  end;
  JvcsLogFmt('JEDIVCSDLLINIT = %s', [BoolToStr(FInitResult, True)]);
  if FLoadError <> '' then
  begin
    Unload;
    FLoadError := 'JEDIVCSDLLINIT falhou com excecao; a DLL foi descarregada (veja o log).';
    Exit;
  end;

  if Assigned(HistoryInitProc) then
  begin
    Scope.Enter(ckDll);
    try
      try
        OK := HistoryInitProc(@FHistoryRec);
        // so habilita se os 9 ponteiros vieram
        P := @FHistoryRec;
        for I := 1 to SizeOf(FHistoryRec) div SizeOf(Pointer) do
        begin
          OK := OK and (P^ <> nil);
          Inc(P);
        end;
        FHasHistory := OK;
      except
        DllFailure(cJediVCSDLLInitHistoryFuncName);
        FillChar(FHistoryRec, SizeOf(FHistoryRec), 0);
        FHasHistory := False;
      end;
    finally
      Scope.Leave;
    end;
  end;

  if Assigned(OperationInitProc) then
  begin
    Scope.Enter(ckDll);
    try
      try
        OK := OperationInitProc(@FOperationRec);
        FHasOperations := OK and Assigned(FOperationRec.GetProjectID);
      except
        DllFailure(cJediVCSDLLInitOperationFuncName);
        FillChar(FOperationRec, SizeOf(FOperationRec), 0);
        FHasOperations := False;
      end;
    finally
      Scope.Leave;
    end;
  end;

  JvcsLogFmt('History=%s, Operacoes=%s, verbos=%d',
    [BoolToStr(FHasHistory, True), BoolToStr(FHasOperations, True), GetVerbCount]);
  Result := True;
end;

procedure TJVCSDllBridge.Unload;
var
  Scope: TJvcsCallScope;
begin
  if FHandle = 0 then
    Exit;
  // 1) nenhuma chamada nova para a DLL a partir daqui
  ClearDllFunctionRecs;
  // 2) FINALIZE (a DLL ainda pode chamar as callbacks do record IDE)
  if FInitCalled and Assigned(FFinalizeProc) then
  begin
    Scope.Enter(ckDllUI);
    try
      try
        FFinalizeProc();
      except
        DllFailure(cJediVCSDLLFinalizeFuncName);
      end;
    finally
      Scope.Leave;
    end;
  end;
  FFinalizeProc := nil;
  FInitCalled := False;
  // 3) so entao FreeLibrary
  Scope.Enter(ckDllUI);
  try
    try
      FreeLibrary(FHandle);
    except
      DllFailure('FreeLibrary');
    end;
  finally
    Scope.Leave;
  end;
  JvcsLog('JvcsExternalDll descarregada');
  FHandle := 0;
  JvcsExternalModule := 0;
  FillChar(FIDERec, SizeOf(FIDERec), 0);
end;

{ ---- VCS ------------------------------------------------------------------- }

function TJVCSDllBridge.GetMenuName: string;
var
  Scope: TJvcsCallScope;
  Buf: array[0..cDllOutBufferSize - 1] of AnsiChar;
begin
  Result := '';
  if not Assigned(FVCSRec.GetMenuName) then
    Exit;
  Buf[0] := #0;
  Scope.Enter(ckDll);
  try
    try
      FVCSRec.GetMenuName(@Buf[0]);
      Buf[High(Buf)] := #0;
      Result := JvcsFromAnsi(@Buf[0]);
    except
      DllFailure('GetMenuName');
      Result := '';
    end;
  finally
    Scope.Leave;
  end;
end;

function TJVCSDllBridge.GetVerbCount: Integer;
var
  Scope: TJvcsCallScope;
begin
  Result := 0;
  if not Assigned(FVCSRec.GetVerbCount) then
    Exit;
  Scope.Enter(ckDll);
  try
    try
      Result := FVCSRec.GetVerbCount();
      if (Result < 0) or (Result > 1000) then
        Result := 0;
    except
      DllFailure('GetVerbCount');
      Result := 0;
    end;
  finally
    Scope.Leave;
  end;
end;

function TJVCSDllBridge.GetVerb(AIndex: Integer): string;
var
  Scope: TJvcsCallScope;
  Buf: array[0..cDllOutBufferSize - 1] of AnsiChar;
begin
  Result := '';
  if not Assigned(FVCSRec.GetVerb) then
    Exit;
  Buf[0] := #0;
  Scope.Enter(ckDll);
  try
    try
      FVCSRec.GetVerb(AIndex, @Buf[0]);
      Buf[High(Buf)] := #0;
      Result := JvcsFromAnsi(@Buf[0]);
    except
      DllFailure('GetVerb');
      Result := '';
    end;
  finally
    Scope.Leave;
  end;
end;

function TJVCSDllBridge.GetVerbState(AIndex: Integer): Word;
var
  Scope: TJvcsCallScope;
begin
  Result := 0;
  if not Assigned(FVCSRec.GetVerbState) then
    Exit;
  Scope.Enter(ckDll);
  try
    try
      Result := FVCSRec.GetVerbState(AIndex);
    except
      DllFailure('GetVerbState');
      Result := 0;
    end;
  finally
    Scope.Leave;
  end;
end;

procedure TJVCSDllBridge.ExecuteVerb(AIndex: Integer);
var
  Scope: TJvcsCallScope;
begin
  if not Assigned(FVCSRec.ExecuteVerb) then
    Exit;
  JvcsLogFmt('ExecuteVerb(%d)', [AIndex]);
  Scope.Enter(ckDllUI);
  try
    try
      FVCSRec.ExecuteVerb(AIndex);
    except
      DllFailure('ExecuteVerb');
    end;
  finally
    Scope.Leave;
  end;
end;

function TJVCSDllBridge.GetVerbImageIndex(AIndex: Integer): Integer;
var
  Scope: TJvcsCallScope;
begin
  Result := -1;
  if not Assigned(FVCSRec.GetVerbImageIndex) then
    Exit;
  Scope.Enter(ckDll);
  try
    try
      Result := FVCSRec.GetVerbImageIndex(AIndex);
    except
      DllFailure('GetVerbImageIndex');
      Result := -1;
    end;
  finally
    Scope.Leave;
  end;
end;

function TJVCSDllBridge.GetVerbShortCut(AIndex: Integer): Word;
var
  Scope: TJvcsCallScope;
begin
  Result := 0;
  if not Assigned(FVCSRec.GetVerbShortCut) then
    Exit;
  Scope.Enter(ckDll);
  try
    try
      Result := FVCSRec.GetVerbShortCut(AIndex);
    except
      DllFailure('GetVerbShortCut');
      Result := 0;
    end;
  finally
    Scope.Leave;
  end;
end;

function TJVCSDllBridge.GetVerbImages(AStream: TStream; AWidth,
  AHeight: Integer): TGetVerbImagesResult;
var
  Scope: TJvcsCallScope;
  Buf: Pointer;
  Size: Integer;
begin
  Result := gvirUnknown;
  if (AStream = nil) or not Assigned(FVCSRec.GetVerbImages) then
    Exit;
  GetMem(Buf, cVerbImagesBufferSize);
  try
    Size := 0;
    Scope.Enter(ckDll);
    try
      try
        Result := FVCSRec.GetVerbImages(Buf, cVerbImagesBufferSize, AWidth, AHeight, Size);
      except
        DllFailure('GetVerbImages');
        Result := gvirUnknown;
      end;
    finally
      Scope.Leave;
    end;
    if (Result = gvirOkay) and (Size > 0) and (Size <= cVerbImagesBufferSize) then
      AStream.WriteBuffer(Buf^, Size)
    else if Result = gvirOkay then
      Result := gvirContainsNoImages;
  finally
    FreeMem(Buf);
  end;
end;

function TJVCSDllBridge.HasProjectChange: Boolean;
begin
  Result := Assigned(FVCSRec.ProjectChange);
end;

procedure TJVCSDllBridge.ProjectChange;
var
  Scope: TJvcsCallScope;
begin
  if not Assigned(FVCSRec.ProjectChange) then
    Exit;
  Scope.Enter(ckDllUI);
  try
    try
      FVCSRec.ProjectChange();
    except
      DllFailure('ProjectChange');
    end;
  finally
    Scope.Leave;
  end;
end;

{ ---- Notifier ---------------------------------------------------------------- }

function TJVCSDllBridge.HasFileNotification: Boolean;
begin
  Result := Assigned(FNotifierRec.FileNotification);
end;

procedure TJVCSDllBridge.FileNotification(ACode: TIDEFileNotification;
  const AFileName: string; var ACancel: Boolean);
var
  Scope: TJvcsCallScope;
  Name: AnsiString;
  LCancel: Boolean;
begin
  if not Assigned(FNotifierRec.FileNotification) then
    Exit;
  // A DLL so le o nome (StrPas): nao ha limite de 256 aqui.
  Name := JvcsToAnsi(AFileName);
  // A DLL sempre devolve Cancel = False ("better not cancel"); uma copia
  // local evita apagar o Cancel = True de outro expert.
  LCancel := False;
  JvcsLogFmt('FileNotification(%d, %s)', [Ord(ACode), AFileName]);
  Scope.Enter(ckDllUI);
  try
    try
      FNotifierRec.FileNotification(ACode, PAnsiChar(Name), LCancel);
    except
      DllFailure('FileNotification');
    end;
  finally
    Scope.Leave;
  end;
  if LCancel then
    ACancel := True;
end;

procedure TJVCSDllBridge.EventNotification(ACode: TIDEEventNotification;
  var ACancel: Boolean);
var
  Scope: TJvcsCallScope;
  LCancel: Boolean;
begin
  if not Assigned(FNotifierRec.EventNotification) then
    Exit;
  LCancel := ACancel;
  JvcsLogFmt('EventNotification(%d, %s)', [Ord(ACode), BoolToStr(ACancel, True)]);
  Scope.Enter(ckDllUI);
  try
    try
      FNotifierRec.EventNotification(ACode, LCancel);
    except
      DllFailure('EventNotification');
    end;
  finally
    Scope.Leave;
  end;
  ACancel := LCancel;
end;

{ ---- History ------------------------------------------------------------------ }

function TJVCSDllBridge.HistoryCount(const AModule: AnsiString): Integer;
var
  Scope: TJvcsCallScope;
begin
  Result := 0;
  if not FHasHistory then
    Exit;
  Scope.Enter(ckDllUI);
  try
    try
      Result := FHistoryRec.GetModuleHistoryCount(PAnsiChar(AModule));
      if Result < 0 then
        Result := 0;
    except
      DllFailure('GetModuleHistoryCount');
      Result := 0;
    end;
  finally
    Scope.Leave;
  end;
end;

function TJVCSDllBridge.HistoryAuthor(const AModule: AnsiString; AIndex: Integer): string;
var
  Scope: TJvcsCallScope;
  Buf: array[0..cDllOutBufferSize - 1] of AnsiChar;
begin
  Result := '';
  if not FHasHistory then
    Exit;
  Buf[0] := #0;
  Scope.Enter(ckDll);
  try
    try
      if FHistoryRec.GetModuleHistoryAuthor(PAnsiChar(AModule), AIndex, @Buf[0]) then
      begin
        Buf[High(Buf)] := #0;
        Result := JvcsFromAnsi(@Buf[0]);
      end;
    except
      DllFailure('GetModuleHistoryAuthor');
      Result := '';
    end;
  finally
    Scope.Leave;
  end;
end;

function TJVCSDllBridge.HistoryVersionRevision(const AModule: AnsiString;
  AIndex: Integer): string;
var
  Scope: TJvcsCallScope;
  Buf: array[0..cDllOutBufferSize - 1] of AnsiChar;
begin
  Result := '';
  if not FHasHistory then
    Exit;
  Buf[0] := #0;
  Scope.Enter(ckDll);
  try
    try
      if FHistoryRec.GetModuleHistoryVersionRevisionStr(PAnsiChar(AModule), AIndex, @Buf[0]) then
      begin
        Buf[High(Buf)] := #0;
        Result := JvcsFromAnsi(@Buf[0]);
      end;
    except
      DllFailure('GetModuleHistoryVersionRevisionStr');
      Result := '';
    end;
  finally
    Scope.Leave;
  end;
end;

function TJVCSDllBridge.HistoryLabelCount(const AModule: AnsiString;
  AIndex: Integer): Integer;
var
  Scope: TJvcsCallScope;
begin
  Result := 0;
  if not FHasHistory then
    Exit;
  Scope.Enter(ckDll);
  try
    try
      Result := FHistoryRec.GetModuleHistoryLabelCount(PAnsiChar(AModule), AIndex);
      if Result < 0 then
        Result := 0;
    except
      DllFailure('GetModuleHistoryLabelCount');
      Result := 0;
    end;
  finally
    Scope.Leave;
  end;
end;

function TJVCSDllBridge.HistoryLabel(const AModule: AnsiString; AIndex,
  ALabelIndex: Integer): string;
var
  Scope: TJvcsCallScope;
  Buf: array[0..cDllOutBufferSize - 1] of AnsiChar;
begin
  Result := '';
  if not FHasHistory then
    Exit;
  Buf[0] := #0;
  Scope.Enter(ckDll);
  try
    try
      if FHistoryRec.GetModuleHistoryLabel(PAnsiChar(AModule), AIndex, ALabelIndex, @Buf[0]) then
      begin
        Buf[High(Buf)] := #0;
        Result := JvcsFromAnsi(@Buf[0]);
      end;
    except
      DllFailure('GetModuleHistoryLabel');
      Result := '';
    end;
  finally
    Scope.Leave;
  end;
end;

function TJVCSDllBridge.HistoryDate(const AModule: AnsiString; AIndex: Integer;
  out ADate: TDateTime): Boolean;
var
  Scope: TJvcsCallScope;
  D: TDateTime;
begin
  Result := False;
  ADate := 0;
  if not FHasHistory then
    Exit;
  D := 0;
  Scope.Enter(ckDll);
  try
    try
      Result := FHistoryRec.GetModuleHistoryDate(PAnsiChar(AModule), AIndex, D);
      if Result then
        ADate := D;
    except
      DllFailure('GetModuleHistoryDate');
      Result := False;
    end;
  finally
    Scope.Leave;
  end;
end;

function TJVCSDllBridge.HistoryComment(const AModule: AnsiString; AIndex: Integer): string;
var
  Scope: TJvcsCallScope;
  Buf: PAnsiChar;
  Size: Integer;
begin
  Result := '';
  if not FHasHistory then
    Exit;
  // a DLL copia ate AMaxCommentSize caracteres + #0
  Size := cHistoryMaxCommentSize + 16;
  GetMem(Buf, Size);
  try
    Buf^ := #0;
    Scope.Enter(ckDll);
    try
      try
        if FHistoryRec.GetModuleHistoryComment(PAnsiChar(AModule), AIndex, Buf,
          cHistoryMaxCommentSize) then
        begin
          Buf[Size - 1] := #0;
          Result := JvcsFromAnsi(Buf);
        end;
      except
        DllFailure('GetModuleHistoryComment');
        Result := '';
      end;
    finally
      Scope.Leave;
    end;
  finally
    FreeMem(Buf);
  end;
end;

function TJVCSDllBridge.HistoryContent(const AModule: AnsiString; AIndex: Integer;
  AStream: TStream): Boolean;
const
  cSlack = 64 * 1024;
var
  Scope: TJvcsCallScope;
  Size: Integer;
  Buf: Pointer;
begin
  Result := False;
  if (AStream = nil) or not FHasHistory then
    Exit;
  Scope.Enter(ckDllUI);
  try
    try
      Size := FHistoryRec.GetModuleHistoryContentSize(PAnsiChar(AModule), AIndex);
    except
      DllFailure('GetModuleHistoryContentSize');
      Size := 0;
    end;
  finally
    Scope.Leave;
  end;
  if Size <= 0 then
    Exit;
  // folga: o blob vem de cache na DLL, mas a chamada nao recebe tamanho
  GetMem(Buf, Size + cSlack);
  try
    Scope.Enter(ckDllUI);
    try
      try
        Result := FHistoryRec.GetModuleHistoryContent(PAnsiChar(AModule), AIndex, Buf);
      except
        DllFailure('GetModuleHistoryContent');
        Result := False;
      end;
    finally
      Scope.Leave;
    end;
    if Result then
      AStream.WriteBuffer(Buf^, Size);
  finally
    FreeMem(Buf);
  end;
end;

{ ---- Operacoes (menu do Project Manager) ---------------------------------------- }

function TJVCSDllBridge.OpGetProjectID(const AProjectName: string): Integer;
var
  Scope: TJvcsCallScope;
  Name: AnsiString;
begin
  Result := -1;
  if not FHasOperations then
    Exit;
  Name := JvcsToAnsi(AProjectName);
  Scope.Enter(ckDllUI);
  try
    try
      Result := FOperationRec.GetProjectID(PAnsiChar(Name));
    except
      DllFailure('GetProjectID');
      Result := -1;
    end;
  finally
    Scope.Leave;
  end;
end;

function TJVCSDllBridge.OpCheckInModule(AProjectID: Integer;
  const AModuleName: string): Boolean;
var
  Scope: TJvcsCallScope;
  Name: AnsiString;
begin
  Result := False;
  if not (FHasOperations and Assigned(FOperationRec.CheckInModule)) then
    Exit;
  Name := JvcsToAnsi(AModuleName);
  Scope.Enter(ckDllUI);
  try
    try
      Result := FOperationRec.CheckInModule(AProjectID, PAnsiChar(Name));
    except
      DllFailure('CheckInModule');
      Result := False;
    end;
  finally
    Scope.Leave;
  end;
end;

function TJVCSDllBridge.OpCheckOutModule(AProjectID: Integer;
  const AModuleName: string): Boolean;
var
  Scope: TJvcsCallScope;
  Name: AnsiString;
begin
  Result := False;
  if not (FHasOperations and Assigned(FOperationRec.CheckOutModule)) then
    Exit;
  Name := JvcsToAnsi(AModuleName);
  Scope.Enter(ckDllUI);
  try
    try
      Result := FOperationRec.CheckOutModule(AProjectID, PAnsiChar(Name));
    except
      DllFailure('CheckOutModule');
      Result := False;
    end;
  finally
    Scope.Leave;
  end;
end;

function TJVCSDllBridge.OpGetModule(AProjectID: Integer;
  const AModuleName: string): Boolean;
var
  Scope: TJvcsCallScope;
  Name: AnsiString;
begin
  Result := False;
  if not (FHasOperations and Assigned(FOperationRec.GetModule)) then
    Exit;
  Name := JvcsToAnsi(AModuleName);
  Scope.Enter(ckDllUI);
  try
    try
      Result := FOperationRec.GetModule(AProjectID, PAnsiChar(Name));
    except
      DllFailure('GetModule');
      Result := False;
    end;
  finally
    Scope.Leave;
  end;
end;

function TJVCSDllBridge.OpCompareModule(AProjectID: Integer; const AModuleName,
  AMember: string): Boolean;
var
  Scope: TJvcsCallScope;
  Name, Member: AnsiString;
begin
  Result := False;
  if not (FHasOperations and Assigned(FOperationRec.CompareModule)) then
    Exit;
  Name := JvcsToAnsi(AModuleName);
  Member := JvcsToAnsi(AMember);
  Scope.Enter(ckDllUI);
  try
    try
      Result := FOperationRec.CompareModule(AProjectID, PAnsiChar(Name), PAnsiChar(Member));
    except
      DllFailure('CompareModule');
      Result := False;
    end;
  finally
    Scope.Leave;
  end;
end;

function TJVCSDllBridge.OpDiffModule(AProjectID: Integer; const AModuleName,
  AMember: string): Boolean;
var
  Scope: TJvcsCallScope;
  Name, Member: AnsiString;
begin
  Result := False;
  if not (FHasOperations and Assigned(FOperationRec.DiffModule)) then
    Exit;
  Name := JvcsToAnsi(AModuleName);
  Member := JvcsToAnsi(AMember);
  Scope.Enter(ckDllUI);
  try
    try
      Result := FOperationRec.DiffModule(AProjectID, PAnsiChar(Name), PAnsiChar(Member));
    except
      DllFailure('DiffModule');
      Result := False;
    end;
  finally
    Scope.Leave;
  end;
end;

function TJVCSDllBridge.OpShowModuleHistory(AProjectID: Integer;
  const AModuleName: string): Boolean;
var
  Scope: TJvcsCallScope;
  Name: AnsiString;
begin
  Result := False;
  if not (FHasOperations and Assigned(FOperationRec.ShowModuleHistory)) then
    Exit;
  Name := JvcsToAnsi(AModuleName);
  Scope.Enter(ckDllUI);
  try
    try
      Result := FOperationRec.ShowModuleHistory(AProjectID, PAnsiChar(Name));
    except
      DllFailure('ShowModuleHistory');
      Result := False;
    end;
  finally
    Scope.Leave;
  end;
end;

function TJVCSDllBridge.OpShowProjectManager(AProjectID: Integer): Boolean;
var
  Scope: TJvcsCallScope;
begin
  Result := False;
  if not (FHasOperations and Assigned(FOperationRec.ShowProjectManager)) then
    Exit;
  Scope.Enter(ckDllUI);
  try
    try
      Result := FOperationRec.ShowProjectManager(AProjectID);
    except
      DllFailure('ShowProjectManager');
      Result := False;
    end;
  finally
    Scope.Leave;
  end;
end;

function TJVCSDllBridge.OpShowProjectHistory(AProjectID: Integer): Boolean;
var
  Scope: TJvcsCallScope;
begin
  Result := False;
  if not (FHasOperations and Assigned(FOperationRec.ShowProjectHistory)) then
    Exit;
  Scope.Enter(ckDllUI);
  try
    try
      Result := FOperationRec.ShowProjectHistory(AProjectID);
    except
      DllFailure('ShowProjectHistory');
      Result := False;
    end;
  finally
    Scope.Leave;
  end;
end;

function TJVCSDllBridge.OpSyncProject(AProjectID: Integer): Boolean;
var
  Scope: TJvcsCallScope;
begin
  Result := False;
  if not (FHasOperations and Assigned(FOperationRec.SyncProject)) then
    Exit;
  Scope.Enter(ckDllUI);
  try
    try
      Result := FOperationRec.SyncProject(AProjectID);
    except
      DllFailure('SyncProject');
      Result := False;
    end;
  finally
    Scope.Leave;
  end;
end;

end.
