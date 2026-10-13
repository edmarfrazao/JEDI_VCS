(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSExpertWizard.pas (JEDI VCS v2026)

-----------------------------------------------------------------------------

Unit JVCSExpertWizard - o wizard (IOTAWizard), menu, acoes e atalhos

  Reproduz TJVCSWizard do expert JvcsExpertBDS21.dll
  (doc\pt\client\Expert-IDE-Analise.md, 1.2, 3.1, 4):
  - menu principal "JEDI VCS" (mnuJEDIVCS) logo depois de ToolsMenu, legenda
    de GetMenuName; subitens mnuJEDIVCS_<n> ligados a uma TAction por verbo
    (JEDIVCS_A<n>, categoria "JEDI VCS", Tag = 100 + n) na ActionList da IDE;
  - imagens de GetVerbImages (tira 16x16) -> INTAServices.AddMasked
    ('JEDIVCS<n>');
  - atalhos de GetVerbShortCut num IOTAKeyboardBinding parcial
    "JEDI VCS KeyBindings" (GetOptions = [ioSupportsShortCuts]);
  - History provider, menu do Project Manager e notifiers;
  - splash e About box ("JEDI Version Control System", licenca MPL 1.1).
  Diferencas: OnUpdate com throttle (1 s) + atualizacao forcada ao abrir o
  menu; reconstrucao do menu/atalhos adiada por mensagem (nunca dentro do
  OnClick/KeyProc que a originou); um verbo clicado enquanto a DLL bombeia
  mensagens dentro de RefreshVerbs (GetVerbState -> CanCheckIn) e executado
  depois, por mensagem; se a DLL nao carregar, o menu mostra um item com o
  erro.

  Ciclo de vida: InitWizard (INITWIZARD0001) cria o wizard e o registra com
  IOTAWizardServices.AddWizard; FinalizeWizard (Terminate) chama Shutdown
  explicitamente (desregistra tudo, JEDIVCSDLLFINALIZE, FreeLibrary) e depois
  RemoveWizard.

  INIT adiado: com ShowLoad = True (HKCU\Software\JEDI\JEDIVCS\Options) a DLL
  abre o dialogo de conexao dentro de JEDIVCSDLLINIT. Nesse caso (ou com
  JVCS_EXPERT_DEFERINIT=on) a carga da DLL e todo o registro na IDE esperam a
  janela principal da IDE ficar visivel (timer), e a abertura do projeto
  ativo e reproduzida para a DLL (ifnProjectOpening, ProjectChange,
  ifnProjectOpened). JVCS_EXPERT_DEFERINIT=off desliga.

  Historico:
  2026/10/12  v2026 - nova unit
-----------------------------------------------------------------------------*)

unit JVCSExpertWizard;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Menus, Vcl.ActnList,
  ToolsAPI, JVCSExpertDllBridge, JVCSExpertNotifiers;

const
  cJVCSWizardIDString = 'PROJECT JEDI.JEDI VCS IDE Wizard';
  cJVCSWizardName = 'JEDI VCS IDE Wizard';
  cJVCSKeyBindingName = 'JEDIVCS.KeyBindings';
  cJVCSKeyBindingDisplayName = 'JEDI VCS KeyBindings';
  cJVCSActionCategory = 'JEDI VCS';
  cJVCSActionTagBase = 100;
  cVerbRefreshIntervalMs = 1000;

type
  TJVCSWizard = class;

  TJVCSKeyBinding = class(TNotifierObject, IOTAKeyboardBinding)
  private
    FWizard: TJVCSWizard;
    procedure KeyProc(const Context: IOTAKeyContext; KeyCode: TShortCut;
      var BindingResult: TKeyBindingResult);
  protected
    { IOTAKeyboardBinding }
    function GetBindingType: TBindingType;
    function GetDisplayName: string;
    function GetName: string;
    procedure BindKeyboard(const BindingServices: IOTAKeyBindingServices);
  public
    constructor Create(AWizard: TJVCSWizard);
    procedure Detach;
  end;

  TJVCSVerbInfo = record
    Caption: string;
    State: Word;
    ImageIndex: Integer;  // indice no ImageList da IDE (-1 = nenhum)
    ShortCut: TShortCut;
  end;

  TJVCSWizard = class(TNotifierObject, IOTANotifier, IOTAWizard)
  private
    FBridge: TJVCSDllBridge;
    FNotifiers: TJVCSNotifierManager;
    FHistoryIndex: Integer;
    FProjMenuIndex: Integer;
    FKeyBinding: TJVCSKeyBinding;
    // referencia propria: o objeto vive ate RemoveKeyBinding mesmo que a IDE
    // ja tenha soltado a dela (Detach nunca escreve em memoria liberada)
    FKeyBindingIntf: IOTAKeyboardBinding;
    FKeyBindingIndex: Integer;
    FMenuItem: TMenuItem;
    // arrays dinamicos, nao TList<T>: os genericos importam metodos internos
    // do rtl<nn>.bpl (TListHelper) que mudam entre atualizacoes do Delphi e
    // impediriam o expert de carregar numa atualizacao diferente (ver
    // tools\verificar-expert.ps1)
    FSubItems: TArray<TMenuItem>;
    FActions: TArray<TAction>;
    FImageMap: TArray<Integer>;  // indice de imagem da DLL -> indice na IDE
    FVerbs: TArray<TJVCSVerbInfo>;
    FLastRefresh: UInt64;
    FRebuildPending: Boolean;
    FRefreshing: Boolean;
    FExecuting: Integer;
    FPendingExecute: Integer;  // verbo clicado durante RefreshVerbs (-1 = nenhum)
    FMsgWnd: HWND;
    FShutdown: Boolean;
    FDeferredInit: Boolean;    // INIT adiado ate a IDE ficar visivel
    FDeferTimer: UINT_PTR;
    FDeferTicks: Integer;
    procedure WndProc(var Msg: TMessage);
    procedure StartUp(AReplayProject: Boolean);
    procedure DeferredInitTick;
    procedure StopDeferTimer;
    procedure ReplayActiveProject;
    procedure ExecutePending(AIndex: Integer);
    procedure PostRebuild;
    procedure DoRebuild;
    procedure LoadMenuImages;
    procedure CreateMenu;
    procedure CreateVerbItems;
    procedure FreeVerbItems;
    procedure AddErrorItem;
    procedure RefreshVerbs(AForce: Boolean);
    procedure ApplyVerb(AIndex: Integer);
    procedure InstallKeyBinding;
    procedure RemoveKeyBinding;
    procedure RegisterHistoryProvider;
    procedure UnregisterHistoryProvider;
    procedure RegisterProjectMenu;
    procedure UnregisterProjectMenu;
    function ShortCutsSnapshot: TArray<TShortCut>;
    procedure MenuRootClick(Sender: TObject);
    procedure ErrorItemClick(Sender: TObject);
    procedure ActionExecute(Sender: TObject);
    procedure ActionUpdate(Sender: TObject);
  protected
    { IOTANotifier }
    procedure Destroyed;
    { IOTAWizard }
    function GetIDString: string;
    function GetName: string;
    function GetState: TWizardState;
    procedure Execute;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Shutdown;
    // chamado pelo key binding
    procedure ExecuteVerbFromKey(AIndex: Integer);
    function VerbCount: Integer;
    function VerbShortCut(AIndex: Integer): TShortCut;
  end;

// INITWIZARD0001
function InitWizard(const BorlandIDEServices: IBorlandIDEServices;
  RegisterProc: TWizardRegisterProc;
  var Terminate: TWizardTerminateProc): Boolean; stdcall;

implementation

uses
  System.Win.Registry, Vcl.Forms, JVCSExpertABI, JVCSExpertUtils,
  JVCSExpertCallbacks, JVCSExpertHistory, JVCSExpertProjMenu, FileHistoryAPI,
  JVCSAppVersion;

const
  WM_JVCS_REBUILD = WM_USER + $4A1;
  WM_JVCS_EXECUTE = WM_USER + $4A2;
  // titulo no splash/About da IDE: + " 2.5.0 Beta 5 - build 2050" (JvcsPluginTitle)
  cPluginTitle = 'JEDI Version Control System';
  cPluginLicense = 'MPL 1.1';
  cDeferTimerID = $4A1;
  cDeferTimerMs = 500;
  cDeferStableTicks = 2;  // janela principal visivel em 2 ticks seguidos
  cJvcsOptionsKey = 'Software\JEDI\JEDIVCS\Options';

var
  GWizard: TJVCSWizard = nil;       // referencia fraca (objeto)
  GWizardIntf: IOTAWizard = nil;    // referencia forte do proprio expert
  GWizardIndex: Integer = -1;
  GAboutIndex: Integer = -1;

// SplashScreenServices e uma variavel global da ToolsAPI que a IDE preenche
// na copia do designide<nn>.bpl. O expert compila uma copia propria da
// ToolsAPI (JvcsToolsAPI, sem DockForm - ver tools\gerar-toolsapi.ps1), cuja
// variavel fica nil: le a da IDE pelo export do pacote, em tempo de execucao
// (GetProcAddress nao cria import estatico: o expert carrega mesmo se faltar).
function IdeSplashScreenServices: IOTASplashScreenServices;
type
  PSplashIntf = ^IOTASplashScreenServices;
const
{$IF CompilerVersion >= 37.0}
  cDesignIde = 'designide370.bpl';
{$ELSEIF CompilerVersion >= 36.0}
  cDesignIde = 'designide290.bpl';
{$ELSE}
  cDesignIde = 'designide280.bpl';
{$IFEND}
var
  H: HMODULE;
  P: PSplashIntf;
begin
  Result := nil;
  H := GetModuleHandle(cDesignIde);
  if H = 0 then
    Exit;
  P := GetProcAddress(H, '@Toolsapi@SplashScreenServices');
  if P <> nil then
    Result := P^;
end;

procedure AppendMenuItem(var AList: TArray<TMenuItem>; AItem: TMenuItem);
var
  N: Integer;
begin
  N := Length(AList);
  SetLength(AList, N + 1);
  AList[N] := AItem;
end;

procedure AppendAction(var AList: TArray<TAction>; AAction: TAction);
var
  N: Integer;
begin
  N := Length(AList);
  SetLength(AList, N + 1);
  AList[N] := AAction;
end;

{ ---- bitmap para splash/About (24x24, desenhado em tempo de execucao) -------- }

function CreatePluginBitmapHandle: HBITMAP;
var
  Bmp: TBitmap;
begin
  Bmp := TBitmap.Create;
  try
    Bmp.PixelFormat := pf24bit;
    Bmp.SetSize(24, 24);
    with Bmp.Canvas do
    begin
      // pixel inferior esquerdo = cor transparente (regra do splash)
      Brush.Color := clFuchsia;
      FillRect(Rect(0, 0, 24, 24));
      Brush.Color := TColor($00A05A1E);  // azul
      Pen.Color := TColor($00602E0A);
      RoundRect(1, 1, 23, 23, 6, 6);
      Font.Name := 'Arial';
      Font.Style := [fsBold];
      Font.Height := -15;
      Font.Color := clWhite;
      Brush.Style := bsClear;
      TextOut((24 - TextWidth('J')) div 2, (24 - TextHeight('J')) div 2, 'J');
    end;
    // o handle e entregue a IDE e nao e liberado pelo expert (evita
    // DeleteObject duplo se a IDE assumir a posse)
    Result := Bmp.ReleaseHandle;
  finally
    Bmp.Free;
  end;
end;

{ ---- versao (VERSIONINFO do proprio expert: tools\versao.ini) ------------- }

// "2.5.0 Beta 5 - build 2050" (JVCSAppVersion: InternalVersion + build do FILEVERSION)
function JvcsExpertVersionLabel: string;
begin
  try
    Result := JVCSVersionLabel(JVCSModuleFileName);
  except
    Result := '';
  end;
end;

function JvcsPluginTitle: string;
var
  Ver: string;
begin
  Ver := JvcsExpertVersionLabel;
  if Ver <> '' then
    Result := cPluginTitle + ' ' + Ver
  else
    Result := cPluginTitle;
end;

procedure RegisterSplashAndAbout;
var
  Splash: IOTASplashScreenServices270;
  AboutSvc: IOTAAboutBoxServices;
  About120: IOTAAboutBoxServices120;
begin
  try
    Splash := nil;
    if Supports(IdeSplashScreenServices, IOTASplashScreenServices270, Splash) then
    begin
      Splash.AddPluginBitmap(JvcsPluginTitle, CreatePluginBitmapHandle, False,
        cPluginLicense, '');
      Splash.StatusMessage('Initializing JEDI Version Control System');
    end;
  except
    JvcsLogCurrentException('splash');
  end;
  try
    if Supports(BorlandIDEServices, IOTAAboutBoxServices, AboutSvc) then
    begin
      About120 := AboutSvc;
      GAboutIndex := About120.AddPluginInfo(JvcsPluginTitle,
        'JEDI VCS ' + JvcsExpertVersionLabel + ' - IDE Expert: ponte entre a ToolsAPI e a ' +
        'JvcsExternalDll.dll do JEDI VCS 2.5 (cliente Delphi 2007, ANSI).',
        CreatePluginBitmapHandle, False, cPluginLicense, '');
    end;
  except
    JvcsLogCurrentException('About box');
  end;
end;

procedure UnregisterAbout;
var
  AboutSvc: IOTAAboutBoxServices;
  About120: IOTAAboutBoxServices120;
begin
  try
    if (GAboutIndex >= 0) and Supports(BorlandIDEServices, IOTAAboutBoxServices, AboutSvc) then
    begin
      About120 := AboutSvc;
      About120.RemovePluginInfo(GAboutIndex);
    end;
  except
    JvcsLogCurrentException('RemovePluginInfo');
  end;
  GAboutIndex := -1;
end;

{ ---- INIT adiado (ShowLoad) ------------------------------------------------- }

// ShowLoad da DLL (jvcsReadBool = TRegistry.ReadBool, REG_DWORD <> 0), so
// leitura. Qualquer falha = False (comportamento padrao: INIT imediato).
function ReadJvcsShowLoad: Boolean;
var
  Reg: TRegistry;
begin
  Result := False;
  try
    Reg := TRegistry.Create(KEY_READ);
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKeyReadOnly(cJvcsOptionsKey) then
      begin
        if Reg.ValueExists('ShowLoad') then
          Result := Reg.ReadBool('ShowLoad');
        Reg.CloseKey;
      end;
    finally
      Reg.Free;
    end;
  except
    Result := False;
  end;
end;

// JVCS_EXPERT_DEFERINIT = on | off | auto (padrao: adia so com ShowLoad = True)
function JvcsShouldDeferInit: Boolean;
var
  Mode: string;
begin
  Mode := LowerCase(Trim(GetEnvironmentVariable('JVCS_EXPERT_DEFERINIT')));
  if (Mode = 'off') or (Mode = '0') or (Mode = 'no') or (Mode = 'false') then
    Exit(False);
  if (Mode = 'on') or (Mode = '1') or (Mode = 'yes') or (Mode = 'true') then
    Exit(True);
  Result := ReadJvcsShowLoad;
  if Result then
    JvcsLog('ShowLoad = True: a DLL abriria o dialogo de conexao durante o splash');
end;

function JvcsIdeMainWindowVisible: Boolean;
begin
  try
    Result := (Application <> nil) and (Application.MainForm <> nil) and
      Application.MainForm.Visible and Application.MainForm.HandleAllocated and
      IsWindowVisible(Application.MainForm.Handle);
  except
    Result := False;
  end;
end;

{ TJVCSKeyBinding }

constructor TJVCSKeyBinding.Create(AWizard: TJVCSWizard);
begin
  inherited Create;
  FWizard := AWizard;
end;

procedure TJVCSKeyBinding.Detach;
begin
  FWizard := nil;
end;

function TJVCSKeyBinding.GetBindingType: TBindingType;
begin
  Result := btPartial;
end;

function TJVCSKeyBinding.GetDisplayName: string;
begin
  Result := cJVCSKeyBindingDisplayName;
end;

function TJVCSKeyBinding.GetName: string;
begin
  Result := cJVCSKeyBindingName;
end;

procedure TJVCSKeyBinding.BindKeyboard(const BindingServices: IOTAKeyBindingServices);
var
  I: Integer;
  SC: TShortCut;
begin
  try
    if (FWizard = nil) or (BindingServices = nil) then
      Exit;
    for I := 0 to FWizard.VerbCount - 1 do
    begin
      SC := FWizard.VerbShortCut(I);
      if SC <> 0 then
        BindingServices.AddKeyBinding([SC], KeyProc, Pointer(NativeInt(I)), 0, '',
          'mnuJEDIVCS_' + IntToStr(I));
    end;
  except
    JvcsLogCurrentException('TJVCSKeyBinding.BindKeyboard');
  end;
end;

procedure TJVCSKeyBinding.KeyProc(const Context: IOTAKeyContext;
  KeyCode: TShortCut; var BindingResult: TKeyBindingResult);
var
  Index: Integer;
begin
  BindingResult := krUnhandled;
  try
    if (FWizard = nil) or (Context = nil) then
      Exit;
    Index := Integer(NativeInt(Context.Context));
    FWizard.ExecuteVerbFromKey(Index);
    BindingResult := krHandled;
  except
    JvcsLogCurrentException('TJVCSKeyBinding.KeyProc');
  end;
end;

{ TJVCSWizard }

constructor TJVCSWizard.Create;
begin
  inherited Create;
  FHistoryIndex := -1;
  FProjMenuIndex := -1;
  FKeyBindingIndex := -1;
  FPendingExecute := -1;
  FSubItems := nil;
  FActions := nil;
  FMsgWnd := AllocateHWnd(WndProc);

  JvcsInitDpiSupport;
  JvcsLogFmt('JVCS Expert iniciando (versao %s - %s, %s, BDS %s, DPI=%s)',
    [JVCSVersionString(JVCSModuleFileName, 'FileVersion'), JvcsExpertVersionLabel,
     GetModuleName(HInstance), FloatToStr(CompilerVersion), JvcsDpiModeDescription]);

  FBridge := TJVCSDllBridge.Create;
  JVCSBridge := FBridge;
  if JvcsShouldDeferInit then
  begin
    FDeferTimer := SetTimer(FMsgWnd, cDeferTimerID, cDeferTimerMs, nil);
    FDeferredInit := FDeferTimer <> 0;
  end;
  if FDeferredInit then
    JvcsLog('INIT da JvcsExternalDll adiado ate a janela principal da IDE ficar visivel')
  else
    StartUp(False);
end;

// Carga da DLL e registro na IDE. AReplayProject: INIT adiado - a DLL nao viu
// a abertura do projeto que a IDE ja carregou.
procedure TJVCSWizard.StartUp(AReplayProject: Boolean);
begin
  // tema aplicado pela IDE -> JVCS_IDE_THEME, antes do INIT (a DLL le no
  // "Follow Delphi"; o registro nem sempre reflete o tema em uso)
  JvcsThemeInstall;
  // INIT -> HISTORYINIT -> OPERATIONINIT
  if FBridge.Load then
  begin
    RegisterHistoryProvider;
    LoadMenuImages;
  end;
  if FShutdown then
    Exit;
  CreateMenu;
  if FBridge.Loaded then
  begin
    FNotifiers := TJVCSNotifierManager.Create;
    FNotifiers.Install;
    InstallKeyBinding;
    RegisterProjectMenu;
    if AReplayProject then
      ReplayActiveProject;
  end;
end;

procedure TJVCSWizard.StopDeferTimer;
begin
  if (FDeferTimer <> 0) and (FMsgWnd <> 0) then
    KillTimer(FMsgWnd, cDeferTimerID);
  FDeferTimer := 0;
end;

procedure TJVCSWizard.DeferredInitTick;
begin
  if not FDeferredInit or FShutdown then
  begin
    StopDeferTimer;
    Exit;
  end;
  if not JvcsIdeMainWindowVisible then
  begin
    FDeferTicks := 0;
    Exit;
  end;
  Inc(FDeferTicks);
  if FDeferTicks < cDeferStableTicks then
    Exit;
  // o timer para ANTES do INIT: o dialogo modal da DLL bombeia mensagens
  StopDeferTimer;
  FDeferredInit := False;
  JvcsLog('IDE visivel: executando o INIT adiado');
  StartUp(True);
end;

// Mesma sequencia que TJVCSIdeNotifier.FileNotification envia ao abrir um
// projeto (3.5): a DLL so marca sProjectName/bProjectOpen em ifnProjectOpening.
procedure TJVCSWizard.ReplayActiveProject;
var
  Project: IOTAProject;
  RawName, Name: string;
  Cancel: Boolean;
begin
  try
    Project := JvcsActiveProject;
    if (Project = nil) or not (Assigned(FBridge) and FBridge.Loaded) or
      not FBridge.HasFileNotification then
      Exit;
    RawName := Project.FileName;
    Name := JvcsProjectSourceName(Project);
    JvcsLogFmt('INIT adiado: reproduzindo a abertura do projeto ativo %s', [Name]);
    Cancel := False;
    FBridge.FileNotification(ifnProjectOpening, RawName, Cancel);
    if FShutdown or not FBridge.Loaded then
      Exit;
    FBridge.ProjectChange;
    if FShutdown or not FBridge.Loaded then
      Exit;
    FBridge.FileNotification(ifnProjectOpened, Name, Cancel);
    if Assigned(FNotifiers) then
      FNotifiers.AttachProjectCloseNotifier(Project, Name);
  except
    JvcsLogCurrentException('ReplayActiveProject');
  end;
end;

destructor TJVCSWizard.Destroy;
begin
  Shutdown;
  FSubItems := nil;
  FActions := nil;
  inherited Destroy;
end;

procedure TJVCSWizard.Shutdown;
begin
  if FShutdown then
    Exit;
  FShutdown := True;
  JvcsLog('JVCS Expert finalizando');
  FDeferredInit := False;
  StopDeferTimer;
  if FMsgWnd <> 0 then
  begin
    DeallocateHWnd(FMsgWnd);
    FMsgWnd := 0;
  end;
  try JvcsThemeUninstall; except JvcsLogCurrentException('Shutdown.ThemeUninstall'); end;
  try RemoveKeyBinding; except JvcsLogCurrentException('Shutdown.RemoveKeyBinding'); end;
  try UnregisterProjectMenu; except JvcsLogCurrentException('Shutdown.UnregisterProjectMenu'); end;
  try UnregisterHistoryProvider; except JvcsLogCurrentException('Shutdown.UnregisterHistoryProvider'); end;
  try
    if Assigned(FNotifiers) then
      FNotifiers.Uninstall;
    FreeAndNil(FNotifiers);
  except
    JvcsLogCurrentException('Shutdown.Notifiers');
  end;
  try
    FreeVerbItems;
    FreeAndNil(FMenuItem);
  except
    JvcsLogCurrentException('Shutdown.Menu');
  end;
  // por ultimo a DLL: zera records, JEDIVCSDLLFINALIZE, FreeLibrary
  try
    if Assigned(FBridge) then
      FBridge.Unload;
  except
    JvcsLogCurrentException('Shutdown.Unload');
  end;
  if JVCSBridge = FBridge then
    JVCSBridge := nil;
  FreeAndNil(FBridge);
  JvcsReleaseCallbackCaches;
end;

procedure TJVCSWizard.Destroyed;
begin
  // A IDE esta removendo o wizard: o indice de AddWizard deixa de valer
  // (FinalizeWizard nao deve chamar RemoveWizard com ele).
  if GWizard = Self then
    GWizardIndex := -1;
  Shutdown;
end;

function TJVCSWizard.GetIDString: string;
begin
  Result := cJVCSWizardIDString;
end;

function TJVCSWizard.GetName: string;
begin
  Result := cJVCSWizardName;
end;

function TJVCSWizard.GetState: TWizardState;
begin
  Result := [];
end;

procedure TJVCSWizard.Execute;
begin
  // nada (o original tambem nao faz nada)
end;

procedure TJVCSWizard.WndProc(var Msg: TMessage);
begin
  case Msg.Msg of
    WM_JVCS_REBUILD:
      begin
        try
          if not FShutdown then
            DoRebuild;
        except
          JvcsLogCurrentException('DoRebuild');
        end;
        Msg.Result := 0;
      end;
    WM_JVCS_EXECUTE:
      begin
        try
          if not FShutdown then
            ExecutePending(Integer(Msg.WParam));
        except
          JvcsLogCurrentException('ExecutePending');
        end;
        Msg.Result := 0;
      end;
    WM_TIMER:
      if Msg.WParam = cDeferTimerID then
      begin
        try
          DeferredInitTick;
        except
          JvcsLogCurrentException('DeferredInitTick');
        end;
        Msg.Result := 0;
      end
      else
        Msg.Result := DefWindowProc(FMsgWnd, Msg.Msg, Msg.WParam, Msg.LParam);
  else
    Msg.Result := DefWindowProc(FMsgWnd, Msg.Msg, Msg.WParam, Msg.LParam);
  end;
end;

// Verbo clicado (ou atalho) enquanto RefreshVerbs estava ativo: executa agora,
// fora do bombeamento de mensagens da DLL.
procedure TJVCSWizard.ExecutePending(AIndex: Integer);
begin
  if FShutdown or (AIndex < 0) or (AIndex >= Length(FActions)) then
    Exit;
  JvcsLogFmt('Executando o verbo %d adiado (clicado durante a atualizacao dos verbos)', [AIndex]);
  // TCustomAction.Execute chama Update e so executa se Enabled
  FActions[AIndex].Execute;
end;

procedure TJVCSWizard.PostRebuild;
begin
  if (FMsgWnd <> 0) and not FShutdown then
    PostMessage(FMsgWnd, WM_JVCS_REBUILD, 0, 0);
end;

procedure TJVCSWizard.DoRebuild;
begin
  if not (Assigned(FBridge) and FBridge.Loaded) then
    Exit;
  // Nunca destruir itens/atalhos enquanto um verbo esta executando (o laco
  // modal da DLL tambem despacha mensagens desta janela): fica pendente e
  // e repostado no fim de ActionExecute.
  if (FExecuting > 0) or FRefreshing then
  begin
    FRebuildPending := True;
    Exit;
  end;
  FRebuildPending := False;
  JvcsLog('Reconstruindo menu e atalhos (verbos/atalhos mudaram)');
  RemoveKeyBinding;
  FreeVerbItems;
  CreateVerbItems;
  InstallKeyBinding;
end;

function TJVCSWizard.VerbCount: Integer;
begin
  Result := Length(FVerbs);
end;

function TJVCSWizard.VerbShortCut(AIndex: Integer): TShortCut;
begin
  if (AIndex >= 0) and (AIndex < Length(FVerbs)) then
    Result := FVerbs[AIndex].ShortCut
  else
    Result := 0;
end;

function TJVCSWizard.ShortCutsSnapshot: TArray<TShortCut>;
var
  I: Integer;
begin
  SetLength(Result, Length(FVerbs));
  for I := 0 to High(FVerbs) do
    Result[I] := FVerbs[I].ShortCut;
end;

procedure TJVCSWizard.LoadMenuImages;
var
  NTA: INTAServices;
  MS: TMemoryStream;
  Strip, Bmp: TBitmap;
  I, N: Integer;
  Res: TGetVerbImagesResult;
begin
  SetLength(FImageMap, 0);
  try
    if not Supports(BorlandIDEServices, INTAServices, NTA) then
      Exit;
    MS := TMemoryStream.Create;
    try
      Res := FBridge.GetVerbImages(MS, 16, 16);
      if (Res <> gvirOkay) or (MS.Size = 0) then
      begin
        JvcsLogFmt('GetVerbImages = %d (sem imagens)', [Ord(Res)]);
        Exit;
      end;
      MS.Position := 0;
      Strip := TBitmap.Create;
      try
        Strip.LoadFromStream(MS);
        N := Strip.Width div 16;
        if (N <= 0) or (Strip.Height < 16) then
          Exit;
        SetLength(FImageMap, N);
        for I := 0 to N - 1 do
        begin
          FImageMap[I] := -1;
          Bmp := TBitmap.Create;
          try
            Bmp.PixelFormat := pf24bit;
            Bmp.SetSize(16, 16);
            Bmp.Canvas.CopyRect(Rect(0, 0, 16, 16), Strip.Canvas,
              Rect(I * 16, 0, I * 16 + 16, 16));
            FImageMap[I] := NTA.AddMasked(Bmp, Bmp.Canvas.Pixels[0, 15],
              'JEDIVCS' + IntToStr(I));
          finally
            Bmp.Free;
          end;
        end;
        JvcsLogFmt('%d imagens de menu registradas na IDE', [N]);
      finally
        Strip.Free;
      end;
    finally
      MS.Free;
    end;
  except
    JvcsLogCurrentException('LoadMenuImages');
  end;
end;

procedure TJVCSWizard.CreateMenu;
var
  NTA: INTAServices;
  Caption: string;
  Main: TMainMenu;
  I, Idx: Integer;
begin
  if not Supports(BorlandIDEServices, INTAServices, NTA) then
  begin
    JvcsLog('INTAServices indisponivel: menu nao criado');
    Exit;
  end;
  Caption := '';
  if FBridge.Loaded then
    Caption := FBridge.GetMenuName;
  if Caption = '' then
    Caption := cJvcsCaption;

  FMenuItem := TMenuItem.Create(nil);
  FMenuItem.Name := 'mnuJEDIVCS';
  FMenuItem.Caption := Caption;
  FMenuItem.OnClick := MenuRootClick;
  try
    NTA.AddActionMenu('ToolsMenu', nil, FMenuItem, True, False);
  except
    // ToolsMenu nao encontrado: insere direto no menu principal
    JvcsLogCurrentException('AddActionMenu(ToolsMenu)');
    Main := NTA.MainMenu;
    if Main <> nil then
    begin
      Idx := -1;
      for I := 0 to Main.Items.Count - 1 do
        if SameText(Main.Items[I].Name, 'ToolsMenu') then
        begin
          Idx := I + 1;
          Break;
        end;
      if FMenuItem.Parent = nil then
      begin
        if (Idx >= 0) and (Idx <= Main.Items.Count) then
          Main.Items.Insert(Idx, FMenuItem)
        else
          Main.Items.Add(FMenuItem);
      end;
    end;
  end;

  if FBridge.Loaded then
    CreateVerbItems
  else
    AddErrorItem;
end;

procedure TJVCSWizard.AddErrorItem;
var
  Item: TMenuItem;
begin
  if FMenuItem = nil then
    Exit;
  Item := TMenuItem.Create(nil);
  Item.Name := 'mnuJEDIVCS_Error';
  Item.Caption := 'JvcsExternalDll.dll not loaded - details...';
  Item.OnClick := ErrorItemClick;
  FMenuItem.Add(Item);
  AppendMenuItem(FSubItems, Item);
end;

procedure TJVCSWizard.ErrorItemClick(Sender: TObject);
var
  Msg: string;
begin
  try
    Msg := 'JEDI VCS IDE Expert' + sLineBreak + sLineBreak;
    if Assigned(FBridge) then
      Msg := Msg + FBridge.LoadError + sLineBreak + sLineBreak +
        'Pasta do expert: ' + FBridge.ExpertDir;
    MessageBox(JvcsIdeParentHandle, PChar(Msg), cJvcsCaption, MB_OK or MB_ICONWARNING);
  except
    JvcsLogCurrentException('ErrorItemClick');
  end;
end;

procedure TJVCSWizard.CreateVerbItems;
var
  NTA: INTAServices;
  Count, I: Integer;
  Action: TAction;
  Item: TMenuItem;
begin
  if (FMenuItem = nil) or not Supports(BorlandIDEServices, INTAServices, NTA) then
    Exit;
  Count := FBridge.GetVerbCount;
  SetLength(FVerbs, Count);
  for I := 0 to Count - 1 do
  begin
    FVerbs[I].Caption := #0;  // forca a primeira atribuicao
    FVerbs[I].State := $FFFF;
    FVerbs[I].ImageIndex := -2;
    FVerbs[I].ShortCut := 0;

    Action := TAction.Create(nil);
    Action.Name := 'JEDIVCS_A' + IntToStr(I);
    Action.Category := cJVCSActionCategory;
    Action.Tag := cJVCSActionTagBase + I;
    Action.Caption := '-';
    Action.OnExecute := ActionExecute;
    Action.OnUpdate := ActionUpdate;
    Action.ActionList := NTA.ActionList;
    AppendAction(FActions, Action);

    Item := TMenuItem.Create(nil);
    Item.Name := 'mnuJEDIVCS_' + IntToStr(I);
    Item.Action := Action;
    FMenuItem.Add(Item);
    AppendMenuItem(FSubItems, Item);
  end;
  RefreshVerbs(True);
  JvcsLogFmt('Menu criado com %d verbos', [Count]);
end;

procedure TJVCSWizard.FreeVerbItems;
var
  I: Integer;
begin
  for I := Length(FSubItems) - 1 downto 0 do
    FSubItems[I].Free;
  FSubItems := nil;
  for I := Length(FActions) - 1 downto 0 do
  begin
    FActions[I].ActionList := nil;
    FActions[I].Free;
  end;
  FActions := nil;
  SetLength(FVerbs, 0);
end;

procedure TJVCSWizard.ApplyVerb(AIndex: Integer);
var
  Action: TAction;
  Info: TJVCSVerbInfo;
begin
  if (AIndex < 0) or (AIndex >= Length(FActions)) or (AIndex >= Length(FVerbs)) then
    Exit;
  Action := FActions[AIndex];
  Info := FVerbs[AIndex];
  if Action.Caption <> Info.Caption then
    Action.Caption := Info.Caption;
  if Action.Enabled <> ((Info.State and ivsEnabled) <> 0) then
    Action.Enabled := (Info.State and ivsEnabled) <> 0;
  if Action.Checked <> ((Info.State and ivsChecked) <> 0) then
    Action.Checked := (Info.State and ivsChecked) <> 0;
  if Action.ImageIndex <> Info.ImageIndex then
    Action.ImageIndex := Info.ImageIndex;
  if Action.ShortCut <> Info.ShortCut then
    Action.ShortCut := Info.ShortCut;
end;

procedure TJVCSWizard.RefreshVerbs(AForce: Boolean);
var
  I, Img: Integer;
  Info: TJVCSVerbInfo;
begin
  if FRefreshing or FShutdown or not (Assigned(FBridge) and FBridge.Loaded) then
    Exit;
  if not AForce and (GetTickCount64 - FLastRefresh < cVerbRefreshIntervalMs) then
    Exit;
  FRefreshing := True;
  try
    for I := 0 to High(FVerbs) do
    begin
      Info.Caption := FBridge.GetVerb(I);
      if Info.Caption = '' then
        Info.Caption := '-';
      Info.State := FBridge.GetVerbState(I);
      Img := FBridge.GetVerbImageIndex(I);
      if (Img >= 0) and (Img < Length(FImageMap)) then
        Info.ImageIndex := FImageMap[Img]
      else
        Info.ImageIndex := -1;
      Info.ShortCut := FBridge.GetVerbShortCut(I);
      FVerbs[I] := Info;
      ApplyVerb(I);
    end;
  finally
    FLastRefresh := GetTickCount64;
    FRefreshing := False;
    // GetVerbState pode bombear mensagens (CanCheckIn -> ProcessMessages):
    // o que chegou nesse meio tempo e tratado agora, fora do laco da DLL.
    if FPendingExecute >= 0 then
    begin
      if (FMsgWnd <> 0) and not FShutdown then
        PostMessage(FMsgWnd, WM_JVCS_EXECUTE, WPARAM(FPendingExecute), 0);
      FPendingExecute := -1;
    end;
    if FRebuildPending and (FExecuting = 0) then
      PostRebuild;
  end;
end;

procedure TJVCSWizard.MenuRootClick(Sender: TObject);
begin
  try
    if not (Assigned(FBridge) and FBridge.Loaded) then
      Exit;
    // so atualiza legendas/estados; nada e destruido com o menu abrindo
    // (a reconstrucao, se preciso, e feita apos ExecuteVerb)
    RefreshVerbs(True);
  except
    JvcsLogCurrentException('MenuRootClick');
  end;
end;

procedure TJVCSWizard.ActionUpdate(Sender: TObject);
begin
  try
    RefreshVerbs(False);
  except
    JvcsLogCurrentException('ActionUpdate');
  end;
end;

procedure TJVCSWizard.ActionExecute(Sender: TObject);
var
  Index, I: Integer;
  OldShortCuts, NewShortCuts: TArray<TShortCut>;
  Changed: Boolean;
begin
  if FExecuting > 0 then
    Exit;
  if FRefreshing then
  begin
    // Estamos dentro do bombeamento de mensagens da DLL em GetVerbState
    // (pedido ao servidor pendente): ExecuteVerb aninhado reentraria no
    // cliente da DLL. Executa quando RefreshVerbs terminar.
    if Sender is TComponent then
      FPendingExecute := TComponent(Sender).Tag - cJVCSActionTagBase;
    Exit;
  end;
  Inc(FExecuting);
  try
    try
      if not (Assigned(FBridge) and FBridge.Loaded) or not (Sender is TComponent) then
        Exit;
      Index := TComponent(Sender).Tag - cJVCSActionTagBase;
      if (Index < 0) or (Index >= Length(FVerbs)) then
        Exit;
      OldShortCuts := ShortCutsSnapshot;
      FBridge.ExecuteVerb(Index);
      if FShutdown or not FBridge.Loaded then
        Exit;
      // como o original: se a quantidade de verbos ou algum atalho mudou,
      // reconstroi menu e key binding (adiado: estamos dentro do OnClick)
      Changed := FBridge.GetVerbCount <> Length(OldShortCuts);
      if not Changed then
      begin
        SetLength(NewShortCuts, Length(OldShortCuts));
        for I := 0 to High(OldShortCuts) do
        begin
          NewShortCuts[I] := FBridge.GetVerbShortCut(I);
          if NewShortCuts[I] <> OldShortCuts[I] then
            Changed := True;
        end;
      end;
      if Changed then
        FRebuildPending := True
      else
        FLastRefresh := 0;  // proxima atualizacao e imediata
    except
      JvcsLogCurrentException('ActionExecute');
    end;
  finally
    Dec(FExecuting);
    if FRebuildPending and (FExecuting = 0) then
      PostRebuild;
  end;
end;

procedure TJVCSWizard.ExecuteVerbFromKey(AIndex: Integer);
begin
  if FShutdown or (AIndex < 0) or (AIndex >= Length(FActions)) then
    Exit;
  RefreshVerbs(True);
  // TCustomAction.Execute chama Update e so executa se Enabled
  FActions[AIndex].Execute;
end;

procedure TJVCSWizard.InstallKeyBinding;
var
  KS: IOTAKeyboardServices;
begin
  if FKeyBindingIndex >= 0 then
    Exit;
  try
    if not Supports(BorlandIDEServices, IOTAKeyboardServices, KS) then
      Exit;
    FKeyBinding := TJVCSKeyBinding.Create(Self);
    FKeyBindingIntf := FKeyBinding;
    FKeyBindingIndex := KS.AddKeyboardBinding(FKeyBindingIntf);
  except
    JvcsLogCurrentException('AddKeyboardBinding');
    FKeyBindingIndex := -1;
    if Assigned(FKeyBinding) then
      FKeyBinding.Detach;
    FKeyBinding := nil;
    FKeyBindingIntf := nil;
  end;
end;

procedure TJVCSWizard.RemoveKeyBinding;
var
  KS: IOTAKeyboardServices;
begin
  try
    if (FKeyBindingIndex >= 0) and
      Supports(BorlandIDEServices, IOTAKeyboardServices, KS) then
      KS.RemoveKeyboardBinding(FKeyBindingIndex);
  finally
    FKeyBindingIndex := -1;
    // FKeyBindingIntf mantem o objeto vivo ate aqui: Detach e seguro mesmo
    // que a IDE ja tenha soltado a referencia dela
    if Assigned(FKeyBinding) then
      FKeyBinding.Detach;
    FKeyBinding := nil;
    FKeyBindingIntf := nil;
  end;
end;

procedure TJVCSWizard.RegisterHistoryProvider;
var
  Manager: IOTAFileHistoryManager;
  Provider: IOTAFileHistoryProvider;
begin
  if not FBridge.HasHistory then
    Exit;
  try
    if Supports(BorlandIDEServices, IOTAFileHistoryManager, Manager) then
    begin
      // referencia local: nunca passar "TObj.Create" direto para um
      // parametro const de interface
      Provider := TJVCSFileHistoryProvider.Create;
      FHistoryIndex := Manager.RegisterHistoryProvider(Provider);
      JvcsLogFmt('History provider registrado (indice %d)', [FHistoryIndex]);
    end;
  except
    JvcsLogCurrentException('RegisterHistoryProvider');
    FHistoryIndex := -1;
  end;
end;

procedure TJVCSWizard.UnregisterHistoryProvider;
var
  Manager: IOTAFileHistoryManager;
begin
  if FHistoryIndex < 0 then
    Exit;
  try
    if Supports(BorlandIDEServices, IOTAFileHistoryManager, Manager) then
      Manager.UnregisterHistoryProvider(FHistoryIndex);
  finally
    FHistoryIndex := -1;
  end;
end;

procedure TJVCSWizard.RegisterProjectMenu;
var
  PM: IOTAProjectManager;
  Creator: IOTAProjectMenuItemCreatorNotifier;
begin
  if not FBridge.HasOperations then
    Exit;
  try
    if Supports(BorlandIDEServices, IOTAProjectManager, PM) then
    begin
      Creator := TJVCSProjectMenuCreator.Create;
      FProjMenuIndex := PM.AddMenuItemCreatorNotifier(Creator);
      JvcsLogFmt('Menu do Project Manager registrado (indice %d)', [FProjMenuIndex]);
    end;
  except
    JvcsLogCurrentException('AddMenuItemCreatorNotifier');
    FProjMenuIndex := -1;
  end;
end;

procedure TJVCSWizard.UnregisterProjectMenu;
var
  PM: IOTAProjectManager;
begin
  if FProjMenuIndex < 0 then
    Exit;
  try
    if Supports(BorlandIDEServices, IOTAProjectManager, PM) then
      PM.RemoveMenuItemCreatorNotifier(FProjMenuIndex);
  finally
    FProjMenuIndex := -1;
  end;
end;

{ ---- entrada/saida da DLL do expert --------------------------------------------- }

procedure FinalizeWizard;
var
  WizardServices: IOTAWizardServices;
begin
  JvcsLog('FinalizeWizard');
  try
    if Assigned(GWizard) then
      GWizard.Shutdown;
  except
    JvcsLogCurrentException('FinalizeWizard.Shutdown');
  end;
  UnregisterAbout;
  try
    if (GWizardIndex >= 0) and Supports(BorlandIDEServices, IOTAWizardServices, WizardServices) then
      WizardServices.RemoveWizard(GWizardIndex);
  except
    JvcsLogCurrentException('FinalizeWizard.RemoveWizard');
  end;
  GWizardIndex := -1;
  GWizard := nil;
  // ultima referencia do expert: destroi o objeto aqui (deterministico)
  GWizardIntf := nil;
end;

function InitWizard(const BorlandIDEServices: IBorlandIDEServices;
  RegisterProc: TWizardRegisterProc;
  var Terminate: TWizardTerminateProc): Boolean; stdcall;
var
  Wizard: TJVCSWizard;
  WizardIntf: IOTAWizard;
  WizardServices: IOTAWizardServices;
begin
  Result := False;
  try
    if not Assigned(BorlandIDEServices) then
      Exit;
    ToolsAPI.BorlandIDEServices := BorlandIDEServices;
    RegisterSplashAndAbout;

    Wizard := TJVCSWizard.Create;
    WizardIntf := Wizard;
    // o expert mantem a propria referencia ate FinalizeWizard: o objeto nao
    // morre antes do Terminate mesmo se a IDE soltar a dela (Destroyed) ou se
    // nao houver IOTAWizardServices
    GWizardIntf := WizardIntf;
    GWizard := Wizard;
    if Supports(BorlandIDEServices, IOTAWizardServices, WizardServices) then
      GWizardIndex := WizardServices.AddWizard(WizardIntf)
    else if Assigned(RegisterProc) then
      RegisterProc(WizardIntf);
    Terminate := FinalizeWizard;
    Result := True;
  except
    JvcsLogCurrentException('InitWizard');
    try
      FinalizeWizard;
    except
    end;
    Result := False;
  end;
end;

initialization

finalization
  // So chega aqui com o wizard vivo se a IDE descarregou o expert SEM chamar
  // o Terminate (FinalizeWizard). Estamos em DLL_PROCESS_DETACH (loader lock):
  // destruir o wizard aqui chamaria ToolsAPI, JEDIVCSDLLFINALIZE e
  // FreeLibrary. Vazamento intencional; a JvcsExternalDll se finaliza no
  // proprio DLL_PROCESS_DETACH (NeedsFinalization).
  if GWizardIntf <> nil then
  begin
    JvcsLog('finalization sem Terminate: wizard abandonado (sem ToolsAPI/FINALIZE sob loader lock)');
    Pointer(GWizardIntf) := nil;
  end;
  GWizard := nil;

end.
