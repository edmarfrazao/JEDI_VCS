(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSExpertNotifiers.pas (JEDI VCS v2026)

-----------------------------------------------------------------------------

Unit JVCSExpertNotifiers - notificacoes da IDE -> ifn*/ien* da DLL

  Reproduz TIdeNotifier/TProjectCloseNotifier do expert BDS21
  (doc\client\Expert-IDE-Analise.md, 3.5):

  Evento OTA                 Projeto                         Arquivo comum
  ofnFileOpening (0)         ifnProjectOpening (nome bruto)  ifnFileOpening
  ofnFileOpened (1)          ProjectChange; ifnProjectOpened ifnFileOpened
                             (.dpr/.dpk); anexa close notifier
  ofnFileClosing (2)         ifnProjectClosing; ProjectChange ifnFileClosing
  ofnProjectDesktopLoad (5)  ifnProjectDesktopLoad           ifnProjectDesktopLoad
  ofnActiveProjectChanged(9) ProjectChange                   -
  Project group: nada.
  IOTAModuleNotifier.Destroyed do projeto: nome em cache (GetProjectName),
  ifnProjectClosing, ProjectChange.

  Compilacao (so quando NAO e Code Insight):
  BeforeCompile -> EventNotification(ienBeforeCompile, Cancel)
  AfterCompile  -> se Succeeded: EventNotification(ienAfterCompile, True)
  Implementa IOTAIDENotifier50 e IOTAIDENotifier80; um flag "compilacao
  pendente" garante UMA notificacao ienAfterCompile por BeforeCompile, seja
  qual for a versao de AfterCompile que a IDE chamar.

  Historico:
  2026/10/12  v2026 - nova unit
-----------------------------------------------------------------------------*)

unit JVCSExpertNotifiers;

interface

uses
  System.SysUtils, System.Classes, ToolsAPI;

type
  TJVCSNotifierManager = class;

  TJVCSIdeNotifier = class(TNotifierObject, IOTANotifier, IOTAIDENotifier,
    IOTAIDENotifier50, IOTAIDENotifier80)
  private
    FManager: TJVCSNotifierManager;
    FCompilePending: Boolean;
    procedure DoAfterCompile(Succeeded, IsCodeInsight: Boolean);
  protected
    { IOTAIDENotifier }
    procedure FileNotification(NotifyCode: TOTAFileNotification;
      const FileName: string; var Cancel: Boolean);
    procedure BeforeCompile(const Project: IOTAProject; var Cancel: Boolean); overload;
    procedure AfterCompile(Succeeded: Boolean); overload;
    { IOTAIDENotifier50 }
    procedure BeforeCompile(const Project: IOTAProject; IsCodeInsight: Boolean;
      var Cancel: Boolean); overload;
    procedure AfterCompile(Succeeded: Boolean; IsCodeInsight: Boolean); overload;
    { IOTAIDENotifier80 }
    procedure AfterCompile(const Project: IOTAProject; Succeeded: Boolean;
      IsCodeInsight: Boolean); overload;
  public
    constructor Create(AManager: TJVCSNotifierManager);
    procedure Detach;
  end;

  TJVCSProjectCloseNotifier = class(TModuleNotifierObject, IOTANotifier,
    IOTAModuleNotifier)
  private
    FManager: TJVCSNotifierManager;
    FModule: IOTAModule;
    FIndex: Integer;
    FProjectName: string;
    FDone: Boolean;
  protected
    { IOTANotifier }
    procedure Destroyed;
    { IOTAModuleNotifier }
    function CheckOverwrite: Boolean;
    procedure ModuleRenamed(const NewName: string);
  public
    constructor Create(AManager: TJVCSNotifierManager; const AModule: IOTAModule;
      const AProjectName: string);
    // Remove o notifier do modulo sem notificar a DLL (shutdown)
    procedure Detach;
    property Module: IOTAModule read FModule;
  end;

  TJVCSNotifierManager = class
  private
    FIdeNotifier: TJVCSIdeNotifier;
    FIdeNotifierIntf: IOTAIDENotifier;
    FIdeNotifierIndex: Integer;
    FCloseNotifiers: TInterfaceList;  // IOTAModuleNotifier (referencia forte)
    procedure RemoveCloseNotifier(ANotifier: TJVCSProjectCloseNotifier);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Install;
    procedure Uninstall;
    procedure AttachProjectCloseNotifier(const AModule: IOTAModule;
      const AProjectName: string);
  end;

implementation

uses
  System.StrUtils, JVCSExpertABI, JVCSExpertUtils, JVCSExpertDllBridge,
  JVCSExpertCallbacks;

function BridgeReady: Boolean;
begin
  Result := Assigned(JVCSBridge) and JVCSBridge.Loaded;
end;

{ TJVCSIdeNotifier }

constructor TJVCSIdeNotifier.Create(AManager: TJVCSNotifierManager);
begin
  inherited Create;
  FManager := AManager;
end;

procedure TJVCSIdeNotifier.Detach;
begin
  FManager := nil;
end;

procedure TJVCSIdeNotifier.FileNotification(NotifyCode: TOTAFileNotification;
  const FileName: string; var Cancel: Boolean);
var
  IsProject, IsGroup: Boolean;
  Name, Ext: string;
  Module: IOTAModule;
  Project: IOTAProject;
begin
  try
    if not BridgeReady or not JVCSBridge.HasFileNotification then
      Exit;
    if not (NotifyCode in [ofnFileOpening, ofnFileOpened, ofnFileClosing,
      ofnProjectDesktopLoad, ofnActiveProjectChanged]) then
      Exit;

    IsProject := False;
    IsGroup := False;
    Name := FileName;
    Module := nil;
    if NotifyCode in [ofnFileOpening, ofnProjectDesktopLoad] then
    begin
      // o modulo ainda nao existe: classifica pela extensao (nome bruto)
      Ext := UpperCase(ExtractFileExt(FileName));
      if MatchStr(Ext, ['.BPG', '.BDSGROUP', '.GROUPPROJ']) then
        IsGroup := True
      else if MatchStr(Ext, ['.DPR', '.DPK', '.BDSPROJ', '.CBPROJ', '.CSPROJ',
        '.DPROJ', '.TGPROJ', '.VBPROJ']) then
        IsProject := True;
    end
    else
    begin
      Module := JvcsFindOpenModule(FileName);
      if Module <> nil then
      begin
        if Supports(Module, IOTAProjectGroup) then
          IsGroup := True
        else if Supports(Module, IOTAProject, Project) then
        begin
          Name := JvcsProjectSourceName(Project);
          IsProject := True;
        end;
      end;
    end;

    if IsGroup then
      Exit;

    if IsProject then
    begin
      case NotifyCode of
        ofnFileOpening:
          JVCSBridge.FileNotification(ifnProjectOpening, Name, Cancel);
        ofnFileOpened:
          begin
            JVCSBridge.ProjectChange;
            if BridgeReady then
              JVCSBridge.FileNotification(ifnProjectOpened, Name, Cancel);
            if Assigned(FManager) and (Module <> nil) then
              FManager.AttachProjectCloseNotifier(Module, Name);
          end;
        ofnFileClosing:
          begin
            JVCSBridge.FileNotification(ifnProjectClosing, Name, Cancel);
            if BridgeReady then
              JVCSBridge.ProjectChange;
          end;
        ofnProjectDesktopLoad:
          JVCSBridge.FileNotification(ifnProjectDesktopLoad, Name, Cancel);
        ofnActiveProjectChanged:
          JVCSBridge.ProjectChange;
      end;
    end
    else
    begin
      case NotifyCode of
        ofnFileOpening:
          JVCSBridge.FileNotification(ifnFileOpening, Name, Cancel);
        ofnFileOpened:
          JVCSBridge.FileNotification(ifnFileOpened, Name, Cancel);
        ofnFileClosing:
          JVCSBridge.FileNotification(ifnFileClosing, Name, Cancel);
        ofnProjectDesktopLoad:
          JVCSBridge.FileNotification(ifnProjectDesktopLoad, Name, Cancel);
      end;
    end;
  except
    JvcsLogCurrentException('TJVCSIdeNotifier.FileNotification');
  end;
end;

procedure TJVCSIdeNotifier.BeforeCompile(const Project: IOTAProject;
  var Cancel: Boolean);
begin
  // versao sem IsCodeInsight: vazia, como no original
end;

procedure TJVCSIdeNotifier.AfterCompile(Succeeded: Boolean);
begin
  // versao sem IsCodeInsight: vazia, como no original
end;

procedure TJVCSIdeNotifier.BeforeCompile(const Project: IOTAProject;
  IsCodeInsight: Boolean; var Cancel: Boolean);
begin
  try
    if IsCodeInsight then
      Exit;
    FCompilePending := True;
    if BridgeReady then
      JVCSBridge.EventNotification(ienBeforeCompile, Cancel);
  except
    JvcsLogCurrentException('TJVCSIdeNotifier.BeforeCompile');
  end;
end;

procedure TJVCSIdeNotifier.DoAfterCompile(Succeeded, IsCodeInsight: Boolean);
var
  Cancel: Boolean;
begin
  try
    if IsCodeInsight or not FCompilePending then
      Exit;
    FCompilePending := False;
    // A DLL interpreta Cancel = True como "compilou com sucesso" e incrementa
    // o build no ResFileInfo (VerInfoHandle).
    if Succeeded and BridgeReady then
    begin
      Cancel := True;
      JVCSBridge.EventNotification(ienAfterCompile, Cancel);
    end;
  except
    JvcsLogCurrentException('TJVCSIdeNotifier.AfterCompile');
  end;
end;

procedure TJVCSIdeNotifier.AfterCompile(Succeeded, IsCodeInsight: Boolean);
begin
  DoAfterCompile(Succeeded, IsCodeInsight);
end;

procedure TJVCSIdeNotifier.AfterCompile(const Project: IOTAProject;
  Succeeded, IsCodeInsight: Boolean);
begin
  DoAfterCompile(Succeeded, IsCodeInsight);
end;

{ TJVCSProjectCloseNotifier }

constructor TJVCSProjectCloseNotifier.Create(AManager: TJVCSNotifierManager;
  const AModule: IOTAModule; const AProjectName: string);
begin
  inherited Create;
  FManager := AManager;
  FModule := AModule;
  FProjectName := AProjectName;
  FIndex := -1;
end;

function TJVCSProjectCloseNotifier.CheckOverwrite: Boolean;
begin
  Result := True;
end;

procedure TJVCSProjectCloseNotifier.ModuleRenamed(const NewName: string);
var
  Project: IOTAProject;
begin
  try
    if Supports(FModule, IOTAProject, Project) then
      FProjectName := JvcsProjectSourceName(Project);
  except
    JvcsLogCurrentException('TJVCSProjectCloseNotifier.ModuleRenamed');
  end;
end;

procedure TJVCSProjectCloseNotifier.Detach;
var
  Keep: IInterface;
  Idx: Integer;
  M: IOTAModule;
begin
  Keep := Self;
  FDone := True;
  M := FModule;
  Idx := FIndex;
  FModule := nil;
  FIndex := -1;
  if (M <> nil) and (Idx >= 0) then
    try
      M.RemoveNotifier(Idx);
    except
      JvcsLogCurrentException('TJVCSProjectCloseNotifier.Detach');
    end;
  if Assigned(FManager) then
    FManager.RemoveCloseNotifier(Self);
  FManager := nil;
end;

// O modulo do projeto foi destruido = projeto fechado.
procedure TJVCSProjectCloseNotifier.Destroyed;
var
  Keep: IInterface;
  Name: string;
  Cancel: Boolean;
begin
  Keep := Self;  // mantem o objeto vivo ate o fim deste metodo
  try
    if FDone then
      Exit;
    Name := FProjectName;
    Detach;
    if not BridgeReady or (Name = '') then
      Exit;
    Cancel := False;
    JvcsSetClosingProject(True, Name);
    try
      JVCSBridge.FileNotification(ifnProjectClosing, Name, Cancel);
    finally
      JvcsSetClosingProject(False, '');
    end;
    if BridgeReady then
      JVCSBridge.ProjectChange;
  except
    JvcsLogCurrentException('TJVCSProjectCloseNotifier.Destroyed');
  end;
end;

{ TJVCSNotifierManager }

constructor TJVCSNotifierManager.Create;
begin
  inherited Create;
  FIdeNotifierIndex := -1;
  FCloseNotifiers := TInterfaceList.Create;
end;

destructor TJVCSNotifierManager.Destroy;
begin
  Uninstall;
  FCloseNotifiers.Free;
  inherited Destroy;
end;

procedure TJVCSNotifierManager.Install;
var
  Services: IOTAServices;
begin
  if FIdeNotifierIndex >= 0 then
    Exit;
  if not Supports(BorlandIDEServices, IOTAServices, Services) then
    Exit;
  FIdeNotifier := TJVCSIdeNotifier.Create(Self);
  FIdeNotifierIntf := FIdeNotifier;
  FIdeNotifierIndex := Services.AddNotifier(FIdeNotifierIntf);
  JvcsLogFmt('IOTAIDENotifier instalado (indice %d)', [FIdeNotifierIndex]);
end;

procedure TJVCSNotifierManager.Uninstall;
var
  Services: IOTAServices;
  N: TJVCSProjectCloseNotifier;
begin
  // close notifiers: remove dos modulos sem notificar a DLL
  while FCloseNotifiers.Count > 0 do
  begin
    N := TJVCSProjectCloseNotifier(FCloseNotifiers[0] as TObject);
    N.FManager := nil;
    FCloseNotifiers.Delete(0);
    try
      N.Detach;
    except
      JvcsLogCurrentException('TJVCSNotifierManager.Uninstall(close)');
    end;
  end;
  if FIdeNotifierIndex >= 0 then
  begin
    try
      if Supports(BorlandIDEServices, IOTAServices, Services) then
        Services.RemoveNotifier(FIdeNotifierIndex);
    except
      JvcsLogCurrentException('TJVCSNotifierManager.Uninstall(ide)');
    end;
    FIdeNotifierIndex := -1;
  end;
  if Assigned(FIdeNotifier) then
    FIdeNotifier.Detach;
  FIdeNotifier := nil;
  FIdeNotifierIntf := nil;
end;

procedure TJVCSNotifierManager.AttachProjectCloseNotifier(const AModule: IOTAModule;
  const AProjectName: string);
var
  I: Integer;
  N: TJVCSProjectCloseNotifier;
  Intf: IOTAModuleNotifier;
begin
  if AModule = nil then
    Exit;
  // um notifier por modulo de projeto
  for I := 0 to FCloseNotifiers.Count - 1 do
  begin
    N := TJVCSProjectCloseNotifier(FCloseNotifiers[I] as TObject);
    if (N.Module <> nil) and ((N.Module = AModule) or
      SameText(N.Module.FileName, AModule.FileName)) then
    begin
      N.FProjectName := AProjectName;
      Exit;
    end;
  end;
  N := TJVCSProjectCloseNotifier.Create(Self, AModule, AProjectName);
  Intf := N;
  N.FIndex := AModule.AddNotifier(Intf);
  FCloseNotifiers.Add(Intf);
end;

procedure TJVCSNotifierManager.RemoveCloseNotifier(ANotifier: TJVCSProjectCloseNotifier);
var
  I: Integer;
begin
  for I := FCloseNotifiers.Count - 1 downto 0 do
    if (FCloseNotifiers[I] as TObject) = ANotifier then
      FCloseNotifiers.Delete(I);
end;

end.
