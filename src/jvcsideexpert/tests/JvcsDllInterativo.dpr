program JvcsDllInterativo;
{ Host INTERATIVO (fora da IDE) da JvcsExternalDll.dll real, para reproduzir o
  que o usuario faz dentro do Delphi: usa o TJVCSDllBridge e as callbacks reais
  do expert (como o JvcsDllHarness), mas NAO fecha as janelas sozinho.

  - Cria uma janela "Fake IDE" da classe TAppBuilder (como a janela principal
    do Delphi): os forms da DLL devem ficar com ela como dona (GW_OWNER).
  - Opcional: ativa um VCL Style no host (como os temas da IDE), com os
    SystemHooks padrao (menus/dialogos): reproduz os menus da DLL pintados pelo
    hook de menus do host.
  - Executa os verbos pedidos (nomes ou indices), roda o laco de mensagens ate
    o arquivo de parada existir (ou o tempo acabar) e entao chama
    JEDIVCSDLLFINALIZE + FreeLibrary, como o expert ao fechar a IDE.
  - Conta access violations e excecoes Delphi (primeira chance) do processo.

  Uso: JvcsDllInterativo.exe [-style <arquivo.vsf>] [-verbs "Connect Server,Project Manager"]
                             [-stop <arquivo>] [-timeout <s>] [-wait <ms entre verbos>]
                             [-hostmsg <texto>]  (caixa de mensagem do proprio host
                             depois dos verbos: deve seguir o tema do host, nao o da DLL)
                             [-project <arquivo.dpr>]  (projeto "aberto" na Fake IDE:
                             devolvido pela callback GetProjectName)
                             [-primeicons <n>]  (pede <n> icones de System32\*.exe ao
                             shell antes de carregar a DLL, como a IDE ja aberta)
                             [-click "ToolButton28,ToolButton38"]  (clica botoes da
                             toolbar do Project Manager, pelo Name do DFM)
                             [-menu "Refresh1,mmiWhoami"]  (itens do menu principal
                             do Project Manager, por WM_COMMAND)
                             [-login 1]  (no "Server Login" clica Open uma vez:
                             identidade atual com a senha salva)
                             [-closemodal 1] [-closedelay <ms>]  (fecha sozinho os
                             modais da DLL com Cancelar/Nao/WM_CLOSE; ligado com
                             -click/-menu)
  Checagens (falha = ExitCode > 0): a DLL usa como Application.Handle uma janela
  PROPRIA (classe TJVCSDllApplication, hInstance da DLL), nao a do TApplication
  do host (que GetParentHandle devolve, como a IDE); nenhuma CM_ACTIONEXECUTE/
  CM_ACTIONUPDATE/CM_APPKEYDOWN/CM_APPSYSCOMMAND da DLL chega as janelas do host
  (era o AV do XE3: a VCL da IDE recebia o TBasicAction da DLL); janelas
  visiveis da DLL com raiz dos donos = Fake IDE e sem WS_EX_APPWINDOW.
  Rodar com tests\testar-dll-interativo.bat. }
{$APPTYPE CONSOLE}
{$R JvcsDllHarness.res}
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, ToolsAPI,
  Vcl.Forms, Vcl.Themes, Vcl.Styles, Vcl.Controls, Vcl.ExtCtrls, Vcl.Menus, Winapi.ActiveX,
  JVCSExpertABI, JVCSExpertUtils, JVCSExpertDllBridge, JVCSExpertCallbacks, Winapi.ShellAPI;

type
  { IOTAServices so para GetParentHandle = janela do TApplication do host (como
    a IDE): sem ela a DLL antiga ficava com Application.Handle = 0 e o host nao
    reproduzia o AV do XE3 (CM_ACTIONEXECUTE/UPDATE na janela da IDE) }
  TFakeServices = class(TInterfacedObject, IBorlandIDEServices70, IBorlandIDEServices,
    IOTAServices50, IOTAServices60, IOTAServices70, IOTAServices100, IOTAServices110,
    IOTAServices140, IOTAServices160, IOTAServices)
    function SupportsService(const Service: TGUID): Boolean;
    function GetService(const Service: TGUID): IInterface; overload;
    function GetService(const Service: TGUID; out Svc): Boolean; overload;
    { IOTAServices }
    function AddNotifier(const Notifier: IOTAIDENotifier): Integer;
    procedure RemoveNotifier(Index: Integer);
    function GetBaseRegistryKey: string;
    function GetProductIdentifier: string;
    function GetParentHandle: HWND;
    function GetEnvironmentOptions: IOTAEnvironmentOptions;
    function GetActiveDesignerType: string;
    function GetRootDirectory: string;
    function GetBinDirectory: string;
    function GetTemplateDirectory: string;
    function GetApplicationDataDirectory: string;
    function GetLocalApplicationDataDirectory: string;
    function GetIDEPreferredUILanguages: string;
    function GetStartupDirectory: string;
    function IsProject(const FileName: string): Boolean;
    function IsProjectGroup(const FileName: string): Boolean;
    function SaveStream(const Stream: IStream): string;
    function ExpandRootMacro(const S: string): string;
  end;

  TAppBuilder = class(TForm)
  protected
    procedure WndProc(var Message: TMessage); override;
  end;

  { conta as mensagens da VCL com ponteiro de objeto (ou atalhos) que chegam
    as janelas do host vindas da DLL; com a correcao devem ser ZERO }
  THostSpy = class
    function AppHook(var Message: TMessage): Boolean;
    procedure HostAppWndProc(var Message: TMessage);
    procedure CloseModalTimer(Sender: TObject);
  end;

var
  CMActionExec: Integer = 0;     // CM_ACTIONEXECUTE na janela do host
  CMActionUpd: Integer = 0;      // CM_ACTIONUPDATE na janela do host
  CMAppOther: Integer = 0;       // CM_APPKEYDOWN / CM_APPSYSCOMMAND
  ModalClosed: Integer = 0;
  CheckFailures: Integer = 0;
  DllModule: HMODULE = 0;
  FakeWnd: HWND = 0;
  { janela que o host devolve em GetParentHandle (como a IDE devolve a do
    TApplication); Application.Handle do host quando existe, senao uma
    janela utilitaria do host que tambem conta as CM_* }
  HostAppWnd: HWND = 0;
  LoginWanted: Boolean = False;
  LoginTried: Boolean = False;

function CountHostMsg(var Message: TMessage): Boolean;
begin
  Result := True;
  case Message.Msg of
    CM_ACTIONEXECUTE: Inc(CMActionExec);
    CM_ACTIONUPDATE: Inc(CMActionUpd);
    CM_APPKEYDOWN, CM_APPSYSCOMMAND: Inc(CMAppOther);
  else
    Result := False;
  end;
  if Result then
    Message.Result := 0; // nao despacha o objeto da DLL na VCL do host
end;

procedure TAppBuilder.WndProc(var Message: TMessage);
begin
  if not CountHostMsg(Message) then
    inherited WndProc(Message);
end;

function THostSpy.AppHook(var Message: TMessage): Boolean;
begin
  Result := CountHostMsg(Message);
end;

procedure THostSpy.HostAppWndProc(var Message: TMessage);
begin
  if not CountHostMsg(Message) then
    Message.Result := DefWindowProc(HostAppWnd, Message.Msg, Message.WParam, Message.LParam);
end;

function TFakeServices.AddNotifier(const Notifier: IOTAIDENotifier): Integer;
begin
  Result := -1;
end;

procedure TFakeServices.RemoveNotifier(Index: Integer);
begin
end;

function TFakeServices.GetBaseRegistryKey: string;
begin
  Result := '';
end;

function TFakeServices.GetProductIdentifier: string;
begin
  Result := 'Delphi';
end;

function TFakeServices.GetParentHandle: HWND;
begin
  Result := HostAppWnd; // como a IDE: a janela oculta do TApplication
end;

function TFakeServices.GetEnvironmentOptions: IOTAEnvironmentOptions;
begin
  Result := nil;
end;

function TFakeServices.GetActiveDesignerType: string;
begin
  Result := 'dfm';
end;

function TFakeServices.GetRootDirectory: string;
begin
  Result := '';
end;

function TFakeServices.GetBinDirectory: string;
begin
  Result := '';
end;

function TFakeServices.GetTemplateDirectory: string;
begin
  Result := '';
end;

function TFakeServices.GetApplicationDataDirectory: string;
begin
  Result := '';
end;

function TFakeServices.GetLocalApplicationDataDirectory: string;
begin
  Result := '';
end;

function TFakeServices.GetIDEPreferredUILanguages: string;
begin
  Result := '';
end;

function TFakeServices.GetStartupDirectory: string;
begin
  Result := '';
end;

function TFakeServices.IsProject(const FileName: string): Boolean;
begin
  Result := False;
end;

function TFakeServices.IsProjectGroup(const FileName: string): Boolean;
begin
  Result := False;
end;

function TFakeServices.SaveStream(const Stream: IStream): string;
begin
  Result := '';
end;

function TFakeServices.ExpandRootMacro(const S: string): string;
begin
  Result := S;
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
  AVCount: Integer = 0;
  DelphiExcCount: Integer = 0;

function VEHandler(ExceptionInfo: PExceptionPointers): Longint; stdcall;
begin
  if (ExceptionInfo <> nil) and (ExceptionInfo^.ExceptionRecord <> nil) then
    case ExceptionInfo^.ExceptionRecord^.ExceptionCode of
      EXCEPTION_ACCESS_VIOLATION: InterlockedIncrement(AVCount);
      $0EEDFADE: InterlockedIncrement(DelphiExcCount);
    end;
  Result := 0; // EXCEPTION_CONTINUE_SEARCH
end;

function AddVectoredExceptionHandler(First: ULONG; Handler: Pointer): Pointer; stdcall;
  external kernel32 name 'AddVectoredExceptionHandler';

function Arg(const AName, ADefault: string): string;
var
  I: Integer;
begin
  Result := ADefault;
  for I := 1 to ParamCount - 1 do
    if SameText(ParamStr(I), '-' + AName) then
      Exit(ParamStr(I + 1));
end;

function StripAccel(const S: string): string;
begin
  Result := Trim(StringReplace(S, '&', '', [rfReplaceAll]));
end;

// Simula a IDE: o processo do Delphi ja pediu muitos icones ao shell (dialogos,
// Project Manager, Welcome Page), entao a lista de imagens do sistema do processo
// tem centenas/milhares de entradas e os indices novos ficam altos.
procedure PrimeSystemIcons(ACount: Integer);
var
  SR: TSearchRec;
  Sfi: TSHFileInfo;
  N: Integer;
  Dir: string;
begin
  N := 0;
  Dir := IncludeTrailingPathDelimiter(GetEnvironmentVariable('SystemRoot')) + 'System32\';
  if FindFirst(Dir + '*.exe', faAnyFile, SR) = 0 then
  try
    repeat
      SHGetFileInfo(PChar(Dir + SR.Name), 0, Sfi, SizeOf(Sfi), SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
      Inc(N);
    until (N >= ACount) or (FindNext(SR) <> 0);
  finally
    FindClose(SR);
  end;
  Writeln(Format('host: %d icones pedidos ao shell; indice do ultimo = %d', [N, Sfi.iIcon]));
end;

//=== checagens da janela de Application.Handle da DLL e dos donos ============

type
  TWndArray = array of HWND;
  TWinControlAccess = class(TWinControl);

function EnumCollect(W: HWND; L: LPARAM): BOOL; stdcall;
var
  A: ^TWndArray;
begin
  A := Pointer(L);
  SetLength(A^, Length(A^) + 1);
  A^[High(A^)] := W;
  Result := True;
end;

function ThreadWindows: TWndArray;
begin
  Result := nil;
  EnumThreadWindows(GetCurrentThreadId, @EnumCollect, LPARAM(@Result));
end;

function WndClass(W: HWND): string;
var
  Buf: array [0..255] of Char;
begin
  SetString(Result, Buf, GetClassName(W, Buf, Length(Buf)));
end;

function WndText(W: HWND): string;
var
  Buf: array [0..255] of Char;
begin
  SetString(Result, Buf, GetWindowText(W, Buf, Length(Buf)));
end;

function WndDesc(W: HWND): string;
begin
  if W = 0 then
    Result := '0'
  else
    Result := Format('$%x %s "%s"', [W, WndClass(W), WndText(W)]);
end;

function IsDllWindow(W: HWND): Boolean;
begin
  Result := (DllModule <> 0) and (HMODULE(GetWindowLongPtr(W, GWLP_HINSTANCE)) = DllModule);
end;

function FindDllWindow(const AClass: string): HWND;
var
  W: HWND;
begin
  Result := 0;
  for W in ThreadWindows do
    if SameText(WndClass(W), AClass) and IsDllWindow(W) then
      Exit(W);
end;

procedure CheckFail(const AMsg: string);
begin
  Inc(CheckFailures);
  Writeln('  [FALHA] ', AMsg);
end;

{ a janela que a DLL usa como Application.Handle deve ser DELA (classe
  TJVCSDllApplication, hInstance da DLL), nunca a do TApplication do host }
procedure CheckDllAppWindow(const AWhen: string);
var
  W: HWND;
  Pid: DWORD;
begin
  Writeln('checagem Application.Handle da DLL (', AWhen, '):');
  W := FindDllWindow('TJVCSDllApplication');
  if W = 0 then
  begin
    CheckFail('janela TJVCSDllApplication da DLL nao encontrada');
    Exit;
  end;
  Writeln('  DLL : ', WndDesc(W), ' thread=', GetWindowThreadProcessId(W, @Pid),
    ' visivel=', IsWindowVisible(W), ' dona=', WndDesc(GetWindow(W, GW_OWNER)));
  Writeln('  host: janela "Application" (GetParentHandle) = ', WndDesc(HostAppWnd));
  if W = HostAppWnd then
    CheckFail('a DLL usa a janela do host como Application.Handle');
  if GetWindowThreadProcessId(W, nil) <> GetCurrentThreadId then
    CheckFail('janela da DLL em outro thread');
  if IsWindowVisible(W) then
    CheckFail('janela TJVCSDllApplication visivel');
end;

{ janelas visiveis da DLL: raiz dos donos = Fake IDE e sem WS_EX_APPWINDOW }
procedure CheckDllWindowOwners(const AWhen: string);
var
  W, Owner, Root: HWND;
  App: Boolean;
begin
  Writeln('janelas visiveis da DLL (', AWhen, '):');
  for W in ThreadWindows do
    if IsWindowVisible(W) and (IsDllWindow(W) or (WndClass(W) = '#32770')) then
    begin
      Owner := GetWindow(W, GW_OWNER);
      // raiz da cadeia de donos (GA_ROOTOWNER usa GetParent, que nao devolve
      // o dono de janelas WS_OVERLAPPED)
      Root := W;
      while GetWindow(Root, GW_OWNER) <> 0 do
        Root := GetWindow(Root, GW_OWNER);
      App := GetWindowLong(W, GWL_EXSTYLE) and WS_EX_APPWINDOW <> 0;
      Writeln(Format('  %s  dono=%s  raiz=%s  APPWINDOW=%s',
        [WndDesc(W), WndDesc(Owner), WndDesc(Root), BoolToStr(App, True)]));
      if App then
        CheckFail('WS_EX_APPWINDOW (botao proprio na barra de tarefas)');
      if Root <> FakeWnd then
        CheckFail('raiz dos donos nao e a Fake IDE (TAppBuilder)');
    end;
end;

{ objeto VCL da DLL dono de uma janela (mesma versao de VCL do host: so
  campos/metodos estaticos de TComponent/TControl sao usados) }
function DllControl(W: HWND): TComponent;
var
  Atom: string;
begin
  Atom := Format('ControlOfs%.8X%.8X', [DllModule, GetCurrentThreadId]);
  Result := TComponent(GetProp(W, PChar(Atom)));
end;

procedure ClickToolButton(AForm: HWND; const AName: string);
var
  F, C: TComponent;
  Btn: TControl;
  TB: HWND;
  X, Y: Integer;
begin
  F := DllControl(AForm);
  C := nil;
  if F <> nil then
    C := F.FindComponent(AName);
  if C = nil then
  begin
    Writeln('  botao nao encontrado: ', AName);
    Exit;
  end;
  Btn := TControl(C);
  TB := 0;
  if Btn.Parent <> nil then
    TB := TWinControlAccess(Btn.Parent).WindowHandle;
  if TB = 0 then
  begin
    Writeln('  barra do botao sem janela: ', AName);
    Exit;
  end;
  X := Btn.Left + Btn.Width div 2;
  Y := Btn.Top + Btn.Height div 2;
  Writeln(Format('clique em %s (barra %s, %d,%d)  CM_ACTIONEXECUTE=%d CM_ACTIONUPDATE=%d',
    [AName, WndDesc(TB), X, Y, CMActionExec, CMActionUpd]));
  PostMessage(TB, WM_LBUTTONDOWN, MK_LBUTTON, MakeLParam(X, Y));
  PostMessage(TB, WM_LBUTTONUP, 0, MakeLParam(X, Y));
end;

procedure ClickMenuItem(AForm: HWND; const AName: string);
var
  F, C: TComponent;
begin
  F := DllControl(AForm);
  C := nil;
  if F <> nil then
    C := F.FindComponent(AName);
  if C = nil then
  begin
    Writeln('  item de menu nao encontrado: ', AName);
    Exit;
  end;
  Writeln(Format('menu %s (WM_COMMAND %d)  CM_ACTIONEXECUTE=%d CM_ACTIONUPDATE=%d',
    [AName, TMenuItem(C).Command, CMActionExec, CMActionUpd]));
  PostMessage(AForm, WM_COMMAND, TMenuItem(C).Command, 0);
end;

{ fecha (Cancelar/Nao/WM_CLOSE) o que estiver modal na DLL; roda dentro do laco
  modal da DLL (WM_TIMER do host despachado por ele) }
procedure THostSpy.CloseModalTimer(Sender: TObject);
var
  W: HWND;
  Txt: string;
  Btn: TComponent;
begin
  if FakeWnd = 0 then
    Exit;
  for W in ThreadWindows do
    // MessageBox (#32770) sempre; forms da DLL so com a Fake IDE desabilitada
    // (ShowModal da DLL desabilita as janelas do thread)
    if IsWindowVisible(W) and IsWindowEnabled(W) and
       ((WndClass(W) = '#32770') or
        (not IsWindowEnabled(FakeWnd) and IsDllWindow(W) and
         (WndClass(W) <> 'TJVCSDllApplication'))) then
    begin
      Inc(ModalClosed);
      SetLength(Txt, 1024);
      SetLength(Txt, GetDlgItemText(W, $FFFF, PChar(Txt), 1024));
      Writeln(Format('  modal: %s "%s" (CM_ACTIONUPDATE no host ate agora=%d)',
        [WndDesc(W), StringReplace(Txt, #13#10, ' ', [rfReplaceAll]), CMActionUpd]));
      CheckDllWindowOwners('modal aberto');
      // -login 1: no "Server Login" (TVCSLoad) clica Open uma vez (identidade
      // atual, senha salva); os demais modais sao cancelados
      if LoginWanted and not LoginTried and (WndClass(W) = 'TVCSLoad') then
      begin
        LoginTried := True;
        Btn := DllControl(W);
        if Btn <> nil then
          Btn := Btn.FindComponent('btnOpen');
        if (Btn <> nil) and (TWinControlAccess(Btn).WindowHandle <> 0) then
        begin
          Writeln('  login: clique em Open');
          PostMessage(TWinControlAccess(Btn).WindowHandle, BM_CLICK, 0, 0);
          Continue;
        end;
      end;
      if WndClass(W) = '#32770' then
      begin
        PostMessage(W, WM_COMMAND, IDCANCEL, 0);
        PostMessage(W, WM_COMMAND, IDNO, 0);
      end;
      PostMessage(W, WM_CLOSE, 0, 0);
    end;
end;

procedure Pump(AMs: Cardinal; const AStopFile: string);
var
  T0: UInt64;
begin
  T0 := GetTickCount64;
  while (GetTickCount64 - T0 < AMs) and not ((AStopFile <> '') and FileExists(AStopFile)) do
  begin
    Application.ProcessMessages;
    Sleep(10);
  end;
end;

var
  Bridge: TJVCSDllBridge;
  Fake: TAppBuilder;
  Verbs: TStringList;
  StyleFile, StopFile, S: string;
  I, J, Idx, Timeout, WaitMs: Integer;
  Spy: THostSpy;
  CloseTimer: TTimer;
  PM: HWND;
  Names: TStringList;
  W: HWND;
begin
  ExitCode := 0;
  AddVectoredExceptionHandler(1, @VEHandler);
  ToolsAPI.BorlandIDEServices := TFakeServices.Create;
  Application.Initialize;
  Spy := THostSpy.Create;
  Application.HookMainWindow(Spy.AppHook);
  if Application.Handle <> 0 then
    HostAppWnd := Application.Handle
  else
    HostAppWnd := AllocateHWnd(Spy.HostAppWndProc);
  CloseTimer := nil;
  StyleFile := Arg('style', '');
  if StyleFile <> '' then
  begin
    TStyleManager.SetStyle(TStyleManager.LoadFromFile(StyleFile));
    Writeln('host: VCL Style "', TStyleManager.ActiveStyle.Name, '" (SystemHooks padrao)');
  end;
  StopFile := Arg('stop', '');
  Timeout := StrToIntDef(Arg('timeout', '120'), 120);
  WaitMs := StrToIntDef(Arg('wait', '3000'), 3000);
  if (StopFile <> '') and FileExists(StopFile) then
    DeleteFile(StopFile);

  if Arg('project', '') <> '' then
  begin
    // a Fake IDE nao tem IOTAModuleServices: o nome em cache do "projeto em
    // fechamento" faz a callback GetProjectName devolver este arquivo
    JvcsSetClosingProject(True, ExpandFileName(Arg('project', '')));
    Writeln('host: projeto da Fake IDE = ', ExpandFileName(Arg('project', '')));
  end;

  if StrToIntDef(Arg('primeicons', '0'), 0) > 0 then
    PrimeSystemIcons(StrToIntDef(Arg('primeicons', '0'), 0));

  Fake := TAppBuilder.CreateNew(nil);
  Fake.Caption := 'Fake IDE (TAppBuilder) - JvcsDllInterativo';
  Fake.SetBounds(40, 40, 900, 600);
  Fake.Show;
  Writeln('host: janela TAppBuilder = $', IntToHex(Fake.Handle, 8));
  FakeWnd := Fake.Handle;
  LoginWanted := Arg('login', '') = '1';
  if (Arg('click', '') <> '') or (Arg('menu', '') <> '') or (Arg('closemodal', '') = '1') or
     LoginWanted then
  begin
    // fecha sozinho os dialogos modais da DLL (Cancelar/Nao/WM_CLOSE)
    CloseTimer := TTimer.Create(nil);
    CloseTimer.Interval := StrToIntDef(Arg('closedelay', '1500'), 1500);
    CloseTimer.OnTimer := Spy.CloseModalTimer;
    CloseTimer.Enabled := True;
  end;

  Verbs := TStringList.Create;
  Bridge := TJVCSDllBridge.Create;
  JVCSBridge := Bridge;
  try
    try
      if not Bridge.Load then
      begin
        Writeln('Load falhou: ', Bridge.LoadError);
        ExitCode := 1;
        Exit;
      end;
      Writeln('DLL: ', Bridge.DllPath);
      DllModule := GetModuleHandle(PChar(ExtractFileName(Bridge.DllPath)));
      CheckDllAppWindow('depois do INIT');
      for I := 0 to Bridge.GetVerbCount - 1 do
        Verbs.Add(StripAccel(Bridge.GetVerb(I)));
      with TStringList.Create do
      try
        StrictDelimiter := True;
        CommaText := Arg('verbs', '');
        for I := 0 to Count - 1 do
        begin
          S := Trim(Strings[I]);
          Idx := StrToIntDef(S, -1);
          if Idx < 0 then
            for J := 0 to Verbs.Count - 1 do
              if Pos(LowerCase(S), LowerCase(Verbs[J])) = 1 then
              begin
                Idx := J;
                Break;
              end;
          if (Idx < 0) or (Idx >= Verbs.Count) then
          begin
            Writeln('verbo nao encontrado: ', S);
            Continue;
          end;
          Writeln(Format('ExecuteVerb(%d) "%s"  (AVs=%d, exc. Delphi=%d)',
            [Idx, Verbs[Idx], AVCount, DelphiExcCount]));
          Bridge.ExecuteVerb(Idx);
          Pump(WaitMs, StopFile);
          CheckDllAppWindow('depois de "' + Verbs[Idx] + '"');
          CheckDllWindowOwners('depois de "' + Verbs[Idx] + '"');
        end;
      finally
        Free;
      end;
      // -click "ToolButton28,ToolButton38" (botoes da toolbar do Project
      // Manager, pelo Name do DFM) e -menu "Refresh1,mmiWhoami" (itens do menu
      // principal): o mesmo caminho do AV do XE3 (TBasicActionLink.Execute ->
      // SendAppMessage(CM_ACTIONEXECUTE) -> Application.Handle)
      if (Arg('click', '') <> '') or (Arg('menu', '') <> '') then
      begin
        PM := FindDllWindow('TVCSProjAdmin');
        Writeln('Project Manager: ', WndDesc(PM));
        if PM = 0 then
          CheckFail('Project Manager nao esta aberto (use -verbs "Project Manager")')
        else
        begin
          Names := TStringList.Create;
          try
            Names.CommaText := Arg('click', '');
            for I := 0 to Names.Count - 1 do
            begin
              ClickToolButton(PM, Trim(Names[I]));
              Pump(WaitMs, StopFile);
              PM := FindDllWindow('TVCSProjAdmin');
              if PM = 0 then
                Break;
            end;
            Names.CommaText := Arg('menu', '');
            for I := 0 to Names.Count - 1 do
            begin
              if PM = 0 then
                Break;
              ClickMenuItem(PM, Trim(Names[I]));
              Pump(WaitMs, StopFile);
              PM := FindDllWindow('TVCSProjAdmin');
            end;
          finally
            Names.Free;
          end;
          CheckDllAppWindow('depois dos cliques');
          CheckDllWindowOwners('depois dos cliques');
        end;
      end;
      if Arg('hostmsg', '') <> '' then
        // caixa de mensagem do PROPRIO host: com a DLL em tema escuro e o host
        // sem estilo ela deve continuar clara (o estilo da DLL nao vaza)
        MessageBox(Fake.Handle, PChar(Arg('hostmsg', '')), 'Host', MB_OK);
      Writeln('laco de mensagens: crie "', StopFile, '" (ou feche a Fake IDE) para finalizar');
      while Fake.Visible and not ((StopFile <> '') and FileExists(StopFile)) and (Timeout > 0) do
      begin
        Pump(1000, StopFile);
        Dec(Timeout);
      end;
      Writeln(Format('antes do FINALIZE: AVs=%d, exc. Delphi=%d', [AVCount, DelphiExcCount]));
      if CloseTimer <> nil then
        CloseTimer.Enabled := False;
      Bridge.Unload;
      Writeln(Format('depois do FINALIZE/FreeLibrary: AVs=%d, exc. Delphi=%d', [AVCount, DelphiExcCount]));
      for W in ThreadWindows do
        if WndClass(W) = 'TJVCSDllApplication' then
          CheckFail('janela TJVCSDllApplication continua existindo depois do FreeLibrary');
    except
      on E: Exception do
      begin
        ExitCode := 1;
        Writeln('EXCECAO NO HOST: ', E.ClassName, ': ', E.Message);
      end;
    end;
  finally
    JVCSBridge := nil;
    Bridge.Free;
    Verbs.Free;
    Fake.Free;
    ToolsAPI.BorlandIDEServices := nil;
  end;
  Application.UnhookMainWindow(Spy.AppHook);
  if HostAppWnd <> Application.Handle then
    DeallocateHWnd(HostAppWnd);
  CloseTimer.Free;
  Spy.Free;
  Writeln(Format('mensagens da DLL na janela do host: CM_ACTIONEXECUTE=%d CM_ACTIONUPDATE=%d ' +
    'CM_APPKEYDOWN/CM_APPSYSCOMMAND=%d; modais fechados=%d',
    [CMActionExec, CMActionUpd, CMAppOther, ModalClosed]));
  if CMActionExec + CMActionUpd + CMAppOther > 0 then
    CheckFail('mensagens CM_* da VCL da DLL chegaram a janela do host');
  if AVCount > 0 then
    ExitCode := ExitCode + AVCount;
  ExitCode := ExitCode + CheckFailures;
  Writeln('RESULTADO AVs=', AVCount, ' excecoes Delphi (1a chance)=', DelphiExcCount,
    ' falhas de checagem=', CheckFailures);
end.
