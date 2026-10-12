program JvcsExpertSmokeTest;
{ Teste de fumaca (FORA da IDE) do JvcsExpertBDSnn.dll com uma JvcsExternalDll
  FALSA (FakeJvcsExternalDll.dpr, mesma ABI). Nao executa a IDE nem nenhum
  binario do JEDI VCS. Rodar com src\jvcsideexpert\tests\testar-expert.bat.

  A) carrega o expert compilado, chama INITWIZARD0001 com um
     IBorlandIDEServices vazio, Terminate e FreeLibrary; confere no log da DLL
     falsa a ordem INIT -> HISTORYINIT -> OPERATIONINIT -> FINALIZE -> DETACH
     e as 24 callbacks (guardas apos os buffers de 256 bytes, UTF-8 -> ANSI,
     leitura em blocos de 2048);
  B) TJVCSDllBridge direto: verbos (buffer de 4 KB), excecao dentro da DLL,
     notificacoes, History (inclusive de outra thread), operacoes, menu do
     Project Manager;
  C) conversoes de string (sem "best fit"; caminho longo nao e truncado);
  D) expert sem a DLL na pasta; E) INIT adiado (JVCS_EXPERT_DEFERINIT=on):
  nada da DLL e chamado dentro do INITWIZARD0001; F) ABI conferida contra a
  unit ORIGINAL src\common\JVCSIDEInterfaceCommon.pas e a tabela 3.4
  (JvcsAbiCrossCheck.pas). }
{$APPTYPE CONSOLE}
uses
  Winapi.Windows, Winapi.ActiveX, System.SysUtils, System.Classes, ToolsAPI, FileHistoryAPI,
  JVCSExpertABI, JVCSExpertUtils, JVCSExpertDllBridge, JVCSExpertHistory,
  JVCSExpertProjMenu, JvcsAbiCrossCheck in 'JvcsAbiCrossCheck.pas';

type
  TFakeServices = class(TInterfacedObject, IBorlandIDEServices70, IBorlandIDEServices)
    function SupportsService(const Service: TGUID): Boolean;
    function GetService(const Service: TGUID): IInterface; overload;
    function GetService(const Service: TGUID; out Svc): Boolean; overload;
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
  ExpertDll: string = 'JvcsExpertBDS37.dll';

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

function ReadLog(const AFile: string): string;
begin
  if FileExists(AFile) then
    with TStringList.Create do
    try
      LoadFromFile(AFile);
      Result := Text;
    finally
      Free;
    end
  else
    Result := '';
end;

procedure WriteUtf8Test(const AFile: string);
var
  SL: TStringList;
  I: Integer;
begin
  SL := TStringList.Create;
  try
    SL.Add(#$E7#$E3'o '#$E9#$E1#$FC);
    for I := 1 to 200 do
      SL.Add('linha de teste numero ' + IntToStr(I) + ' com acentuacao: '#$E3' '#$F5' '#$E7);
    SL.Add('Z');
    SL.WriteBOM := True;
    SL.SaveToFile(AFile, TEncoding.UTF8);
  finally
    SL.Free;
  end;
  // remove o CRLF final para o ultimo byte ser 'Z'
  with TFileStream.Create(AFile, fmOpenReadWrite) do
  try
    Size := Size - 2;
  finally
    Free;
  end;
end;

procedure TestExpertDll(const ADir: string);
var
  H: HMODULE;
  Init: TWizardInitProc;
  Term: TWizardTerminateProc;
  OK: Boolean;
  Log: string;
begin
  Writeln('== A) ' + ExpertDll + ': INITWIZARD0001 / Terminate / FreeLibrary');
  H := LoadLibrary(PChar(ADir + ExpertDll));
  Check(H <> 0, 'LoadLibrary(' + ExpertDll + ') ' + SysErrorMessage(GetLastError));
  if H = 0 then
    Exit;
  @Init := GetProcAddress(H, WizardEntryPoint);
  Check(Assigned(Init), 'GetProcAddress(INITWIZARD0001)');
  Term := nil;
  OK := Init(TFakeServices.Create, nil, Term);
  Check(OK, 'InitWizard = True');
  Check(Assigned(Term), 'Terminate atribuido');
  if Assigned(Term) then
    Term();
  ToolsAPI.BorlandIDEServices := nil;
  Check(FreeLibrary(H), 'FreeLibrary(expert)');
  Log := ReadLog(ADir + 'fake.log');
  Check(Pos('JEDIVCSDLLINIT', Log) > 0, 'fake: INIT chamado');
  Check(Pos('JEDIVCSDLLHISTORYINIT', Log) > Pos('JEDIVCSDLLINIT', Log), 'fake: HISTORYINIT depois de INIT');
  Check(Pos('JEDIVCSDLLOPERATIONINIT', Log) > Pos('JEDIVCSDLLHISTORYINIT', Log), 'fake: OPERATIONINIT depois de HISTORYINIT');
  Check(Pos('JEDIVCSDLLFINALIZE', Log) > Pos('JEDIVCSDLLOPERATIONINIT', Log), 'fake: FINALIZE no Terminate');
  Check(Pos('DLL_PROCESS_DETACH (FINALIZE antes? True)', Log) > 0, 'fake: FreeLibrary DEPOIS do FINALIZE');
  Check(Pos('RESULTADO_FAKE fails=0', Log) > 0, 'fake: callbacks sem falhas');
  Check(Pos('FAIL', Log) = 0, 'fake: nenhum FAIL no log');
  Log := ReadLog(GetEnvironmentVariable('JVCS_EXPERT_LOG'));
  Check((Pos('FinalizeWizard', Log) > 0) and
    (Pos('FinalizeWizard', Log) < Pos('JVCS Expert finalizando', Log)),
    'wizard vive ate o Terminate (sem IOTAWizardServices)');
end;

procedure TestMissingDll(const ADir: string);
var
  H: HMODULE;
  Init: TWizardInitProc;
  Term: TWizardTerminateProc;
  Log: string;
begin
  Writeln('== D) expert sem JvcsExternalDll.dll na pasta');
  H := LoadLibrary(PChar(ADir + ExpertDll));
  Check(H <> 0, 'LoadLibrary(expert em pasta sem a DLL)');
  if H = 0 then
    Exit;
  @Init := GetProcAddress(H, WizardEntryPoint);
  Term := nil;
  Check(Init(TFakeServices.Create, nil, Term) and Assigned(Term), 'InitWizard = True mesmo sem a DLL');
  if Assigned(Term) then
    Term();
  ToolsAPI.BorlandIDEServices := nil;
  Check(FreeLibrary(H), 'FreeLibrary(expert)');
  Log := ReadLog(GetEnvironmentVariable('JVCS_EXPERT_LOG'));
  Check(Pos('A JvcsExternalDll.dll nao foi carregada', Log) > 0, 'erro de carga registrado (menu mostraria o item de erro)');
end;

procedure TestUtils;
type
  TBuf = packed record
    Data: array[0..255] of AnsiChar;
    Guard: array[0..7] of Byte;
  end;
var
  B: TBuf;
  I: Integer;
  OK: Boolean;
  A: AnsiString;
  U: RawByteString;
begin
  Writeln('== C) utilitarios de string');
  FillChar(B, SizeOf(B), $CC);
  OK := JvcsCopyToAnsiBuffer(@B.Data[0], StringOfChar('a', 400), cDllNameBufferMaxLen);
  Check(not OK, 'JvcsCopyToAnsiBuffer(400 chars) reporta truncamento');
  Check((B.Data[255] = #0) and (B.Data[254] = 'a'), 'truncado em 255 + #0');
  OK := True;
  for I := 0 to High(B.Guard) do
    OK := OK and (B.Guard[I] = $CC);
  Check(OK, 'guarda apos o buffer de 256 bytes intacta');
  OK := JvcsCopyToAnsiBuffer(@B.Data[0], 'c:\projeto\a'#$E7#$E3'o.pas', cDllNameBufferMaxLen);
  Check(OK and (AnsiString(PAnsiChar(@B.Data[0])) = AnsiString('c:\projeto\a'#$E7#$E3'o.pas')), 'string -> CP_ACP (1252)');
  Check(JvcsFromAnsi(PAnsiChar(AnsiString('a'#$E7#$E3'o'))) = 'a'#$E7#$E3'o', 'CP_ACP -> string');
  U := UTF8Encode('a'#$E7#$E3'o '#$20AC);
  A := JvcsUtf8BytesToAnsi(U);
  Check(A = AnsiString('a'#$E7#$E3'o '#$80), 'UTF-8 -> ANSI (inclui euro 0x80)');
  U := RawByteString(#$E7#$E3'o');  // nao e UTF-8 valido
  A := JvcsUtf8BytesToAnsi(U);
  Check(A = AnsiString(#$E7#$E3'o'), 'bytes nao-UTF-8 passam sem conversao');
  Check(JvcsFromAnsi(nil) = '', 'JvcsFromAnsi(nil) = vazio');
  if GetACP = 1252 then
  begin
    // AnsiString(S) faria "best fit": L-barrado -> 'L', barra fullwidth -> '\'
    A := JvcsToAnsiEx('c:\'#$0141'odz'#$FF3C'a.pas', OK);
    Check((not OK) and (A = AnsiString('c:\?odz?a.pas')),
      'sem best fit: caractere fora de CP_ACP vira "?" (nunca outro caminho valido)');
  end;
  FillChar(B, SizeOf(B), $CC);
  OK := JvcsCopyPathToAnsiBuffer(@B.Data[0], 'c:\' + StringOfChar('p', 300) + '.pas',
    cDllNameBufferMaxLen);
  Check((not OK) and (B.Data[0] = #0) and (B.Data[1] = AnsiChar($CC)) and (B.Guard[0] = $CC),
    'caminho > 255 bytes: callback devolve vazio (nao trunca)');
  OK := JvcsCopyPathToAnsiBuffer(@B.Data[0], 'c:\' + StringOfChar('p', 248) + '.pas',
    cDllNameBufferMaxLen);
  Check(OK and (Length(AnsiString(PAnsiChar(@B.Data[0]))) = 255) and (B.Guard[0] = $CC),
    'caminho de exatamente 255 bytes: copiado inteiro');
end;

procedure TestDeferredInit(const ADir: string);
var
  H: HMODULE;
  Init: TWizardInitProc;
  Term: TWizardTerminateProc;
  OK: Boolean;
  Log: string;
begin
  Writeln('== E) INIT adiado (JVCS_EXPERT_DEFERINIT=on; sem janela principal visivel)');
  DeleteFile(ADir + 'fake.log');
  SetEnvironmentVariable('JVCS_EXPERT_DEFERINIT', 'on');
  try
    H := LoadLibrary(PChar(ADir + ExpertDll));
    Check(H <> 0, 'LoadLibrary(' + ExpertDll + ')');
    if H = 0 then
      Exit;
    @Init := GetProcAddress(H, WizardEntryPoint);
    Term := nil;
    OK := Init(TFakeServices.Create, nil, Term);
    Check(OK and Assigned(Term), 'InitWizard = True com o INIT adiado');
    Check(Pos('JEDIVCSDLLINIT', ReadLog(ADir + 'fake.log')) = 0,
      'JEDIVCSDLLINIT NAO chamado dentro do INITWIZARD0001');
    if Assigned(Term) then
      Term();
    ToolsAPI.BorlandIDEServices := nil;
    Check(FreeLibrary(H), 'FreeLibrary(expert) com o timer pendente');
    Check(Pos('JEDIVCSDLLINIT', ReadLog(ADir + 'fake.log')) = 0,
      'Terminate antes da IDE ficar visivel: a DLL nunca foi inicializada');
    Log := ReadLog(GetEnvironmentVariable('JVCS_EXPERT_LOG'));
    Check(Pos('INIT da JvcsExternalDll adiado', Log) > 0, 'adiamento registrado no log');
  finally
    SetEnvironmentVariable('JVCS_EXPERT_DEFERINIT', 'off');
  end;
end;

procedure TestBridge(const ADir: string);
var
  Bridge: TJVCSDllBridge;
  Cancel: Boolean;
  D: TDateTime;
  MS: TMemoryStream;
  S: string;
  Hist: IOTAFileHistory;
  Prov: IOTAFileHistoryProvider;
  ThreadAuthor: string;
  T: TThread;
  Done: Boolean;
  Creator: IOTAProjectMenuItemCreatorNotifier;
  Idents: TStringList;
  Items: IInterfaceList;
  Log: string;
begin
  Writeln('== B) TJVCSDllBridge com a DLL falsa (pasta do host)');
  Bridge := TJVCSDllBridge.Create;
  JVCSBridge := Bridge;
  try
    Check(Bridge.Load, 'Load: ' + Bridge.LoadError);
    Check(SameText(Bridge.DllPath, ADir + 'JvcsExternalDll.dll'), 'DLL encontrada na pasta do modulo: ' + Bridge.DllPath);
    Check(Bridge.HasHistory and Bridge.HasOperations, 'HISTORYINIT e OPERATIONINIT ok');
    Check(Bridge.GetMenuName = '&JEDI VCS (fake)', 'GetMenuName');
    Check(Bridge.GetVerbCount = 3, 'GetVerbCount = 3');
    Check(Bridge.GetVerb(0) = 'C&onnect Server...', 'GetVerb(0)');
    Check(Bridge.GetVerb(1) = '', 'GetVerb(1) = vazio (separador)');
    Check(Bridge.GetVerb(2) = StringOfChar('V', 1500), 'GetVerb(2) com 1500 chars (buffer de 4 KB)');
    Check(Bridge.GetVerbState(0) = ivsEnabled or ivsChecked, 'GetVerbState(0)');
    Check(Bridge.GetVerbShortCut(1) = $6049, 'GetVerbShortCut(1)');
    Check(Bridge.GetVerbImageIndex(0) = -1, 'GetVerbImageIndex');
    MS := TMemoryStream.Create;
    try
      Check(Bridge.GetVerbImages(MS, 16, 16) = gvirContainsNoImages, 'GetVerbImages sem imagens');
    finally
      MS.Free;
    end;
    Bridge.ExecuteVerb(2);
    Check(True, 'ExecuteVerb(2) com excecao dentro da DLL nao derrubou o host');
    Bridge.ExecuteVerb(1);
    Check(True, 'ExecuteVerb(1) chamando as callbacks de dentro da DLL');
    Cancel := True;
    Bridge.FileNotification(ifnProjectOpened, 'c:\proj\a'#$E7#$E3'o.dpr', Cancel);
    Check(Cancel, 'FileNotification preserva Cancel=True de outro expert');
    Cancel := True;
    Bridge.EventNotification(ienAfterCompile, Cancel);
    Bridge.ProjectChange;
    Check(Bridge.HistoryCount('c:\p\u.pas') = 2, 'HistoryCount');
    Check(Bridge.HistoryAuthor('c:\p\u.pas', 1) = 'autor1', 'HistoryAuthor');
    Check(Bridge.HistoryVersionRevision('c:\p\u.pas', 1) = '1.001', 'HistoryVersionRevision');
    Check(Bridge.HistoryLabelCount('c:\p\u.pas', 0) = 1, 'HistoryLabelCount');
    Check(Bridge.HistoryLabel('c:\p\u.pas', 0, 0) = 'REL_1', 'HistoryLabel');
    Check(Bridge.HistoryDate('c:\p\u.pas', 0, D) and (D = EncodeDate(2011, 9, 21)), 'HistoryDate');
    S := Bridge.HistoryComment('c:\p\u.pas', 0);
    Check((Length(S) = 5003) and (Copy(S, 5001, 3) = #$E7#$E3'o'), Format('HistoryComment com acentos (%d chars)', [Length(S)]));
    MS := TMemoryStream.Create;
    try
      Check(Bridge.HistoryContent('c:\p\u.pas', 0, MS) and (MS.Size = 10), 'HistoryContent (10 bytes)');
    finally
      MS.Free;
    end;
    Check(Bridge.OpGetProjectID('c:\p\x.dpr') = 42, 'OpGetProjectID');
    Check(Bridge.OpCompareModule(42, 'c:\p\u.pas', '.dfm'), 'OpCompareModule');
    Check(Bridge.OpDiffModule(42, 'c:\p\u.pas', '.pas'), 'OpDiffModule');
    Check(Bridge.OpShowProjectManager(42), 'OpShowProjectManager');

    // History provider via interfaces (thread principal e outra thread)
    Prov := TJVCSFileHistoryProvider.Create;
    Check(Prov.Get_Ident = cJVCSHistoryProviderIdent, 'Provider.Ident');
    Hist := Prov.GetFileHistory('c:\p\u.pas');
    Check(Assigned(Hist) and (Hist.Get_Count = 2), 'IOTAFileHistory.Count');
    Check(Hist.GetIdent(1) = '1.001', 'IOTAFileHistory.GetIdent');
    Check(Hist.GetAuthor(5) = '', 'indice fora do intervalo -> vazio (sem chamar a DLL)');
    Check(Hist.GetHistoryStyle(0) = hsRemoteRevision, 'hsRemoteRevision');
    Check(Hist.GetLabels(0, 0) = 'REL_1', 'GetLabels');
    Check(Assigned(Hist.GetContent(0)), 'GetContent -> IStream');
    Done := False;
    ThreadAuthor := '';
    T := TThread.CreateAnonymousThread(
      procedure
      begin
        ThreadAuthor := Hist.GetAuthor(0);
        Done := True;
      end);
    T.FreeOnTerminate := True;
    T.Start;
    while not Done do
    begin
      CheckSynchronize(10);
    end;
    Check(ThreadAuthor = 'autor0', 'IOTAFileHistory chamado de outra thread (Synchronize)');
    Hist := nil;
    Prov := nil;

    // menu do Project Manager
    Creator := TJVCSProjectMenuCreator.Create;
    Idents := TStringList.Create;
    Items := TInterfaceList.Create;
    try
      Idents.Add(sFileContainer);
      Idents.Add('c:\p\u.dfm');
      Creator.AddMenu(nil, Idents, Items, False);
      Check(Items.Count = 10, Format('menu de arquivo: %d itens (esperado 10)', [Items.Count]));
      Items.Clear;
      Idents.Clear;
      Idents.Add(sProjectContainer);
      Creator.AddMenu(nil, Idents, Items, False);
      Check(Items.Count = 4, Format('menu de projeto: %d itens (esperado 4)', [Items.Count]));
    finally
      Idents.Free;
    end;
    Items := nil;
    Creator := nil;

    Bridge.Unload;
    Check(not Bridge.Loaded, 'Unload');
  finally
    JVCSBridge := nil;
    Bridge.Free;
  end;
  Log := ReadLog(ADir + 'fake.log');
  Check(Pos('excecao', Log) = 0, 'log da DLL falsa sem lixo');
  Check(Pos('FileNotification(4, "c:\proj\a', Log) > 0, 'FileNotification chegou com o nome');
  Check(Pos('EventNotification(1, Cancel=True)', Log) > 0, 'EventNotification(ienAfterCompile, True)');
  Check(Pos('CompareOrDiff(42, c:\p\u.pas, .dfm)', Log) > 0, 'CompareModule(id, modulo, member)');
  Check(Pos('DLL_PROCESS_DETACH (FINALIZE antes? True)', Log) > 0, 'FINALIZE antes do FreeLibrary');
  Check(Pos('RESULTADO_FAKE fails=0', Log) > 0, 'callbacks sem falhas (INIT e dentro de ExecuteVerb)');
end;

var
  Dir: string;
begin
  try
    Dir := ExtractFilePath(ParamStr(0));
    if ParamStr(1) <> '' then
      ExpertDll := ParamStr(1);
    WriteUtf8Test(Dir + 'utf8test.pas');
    WriteUtf8Test(Dir + 'a\utf8test.pas');
    DeleteFile(Dir + 'fake.log');
    DeleteFile(Dir + 'a\fake.log');
    TestExpertDll(Dir + 'a\');
    TestMissingDll(Dir + 'b\');
    TestDeferredInit(Dir + 'a\');
    TestUtils;
    TestBridge(Dir);
    Writeln('== F) ABI: JVCSExpertABI x JVCSIDEInterfaceCommon.pas original x tabela 3.4');
    RunAbiCrossCheck(Check);
  except
    on E: Exception do
    begin
      Inc(Fails);
      Writeln('EXCECAO NO HOST: ', E.ClassName, ': ', E.Message);
    end;
  end;
  Writeln;
  Writeln('RESULTADO HOST fails=', Fails);
  ExitCode := Fails;
end.
