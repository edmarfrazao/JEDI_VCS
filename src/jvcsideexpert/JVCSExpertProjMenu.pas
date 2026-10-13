(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSExpertProjMenu.pas (JEDI VCS v2026)

-----------------------------------------------------------------------------

Unit JVCSExpertProjMenu - menu de contexto do Project Manager

  Usa IOTAProjectMenuItemCreatorNotifier + IOTAProjectManagerMenu
  (AddMenuItemCreatorNotifier), e NAO a INTAProjectMenuCreatorNotifier
  (deprecated no Delphi 13) usada pelo expert BDS21. Mesmos itens e
  operacoes do original (doc\pt\client\Expert-IDE-Analise.md, 3.6):

  Arquivo (sFileContainer): submenu "JEDI VCS" com Check In/Put, Check Out,
    Get, -, Reload, -, Compare, Diff, History
    -> GetProjectID(projeto .dpr) + CheckInModule/CheckOutModule/GetModule/
       CompareModule(id, modulo, ext)/DiffModule/ShowModuleHistory;
       Reload = IOTAActionServices.ReloadFile.
    .dfm/.nfm/.xfm/.fmx -> modulo .pas; .h -> .cpp; o "member" passado a
    Compare/Diff e a extensao do arquivo selecionado.
  Projeto (sProjectContainer): submenu "JEDI VCS" com Manager, History e
    Synchronize/Restore -> ShowProjectManager/ShowProjectHistory/SyncProject.

  Historico:
  2026/10/12  v2026 - nova unit
-----------------------------------------------------------------------------*)

unit JVCSExpertProjMenu;

interface

uses
  System.SysUtils, System.Classes, ToolsAPI;

type
  TJVCSPMCommand = (pmcNone, pmcCheckIn, pmcCheckOut, pmcGet, pmcReload,
    pmcCompare, pmcDiff, pmcHistory, pmcManager, pmcProjectHistory, pmcSync);

  TJVCSProjectManagerMenu = class(TNotifierObject, IOTALocalMenu,
    IOTAProjectManagerMenu)
  private
    FCaption: string;
    FChecked: Boolean;
    FEnabled: Boolean;
    FHelpContext: Integer;
    FName: string;
    FParent: string;
    FPosition: Integer;
    FVerb: string;
    FIsMultiSelectable: Boolean;
    FCommand: TJVCSPMCommand;
    // False = nao adianta continuar com os demais itens selecionados (DLL
    // indisponivel ou projeto nao obtido no servidor)
    function ExecuteFor(const AProject: IOTAProject; const AIdent: string): Boolean;
  protected
    { IOTALocalMenu }
    function GetCaption: string;
    function GetChecked: Boolean;
    function GetEnabled: Boolean;
    function GetHelpContext: Integer;
    function GetName: string;
    function GetParent: string;
    function GetPosition: Integer;
    function GetVerb: string;
    procedure SetCaption(const Value: string);
    procedure SetChecked(Value: Boolean);
    procedure SetEnabled(Value: Boolean);
    procedure SetHelpContext(Value: Integer);
    procedure SetName(const Value: string);
    procedure SetParent(const Value: string);
    procedure SetPosition(Value: Integer);
    procedure SetVerb(const Value: string);
    { IOTAProjectManagerMenu }
    function GetIsMultiSelectable: Boolean;
    procedure SetIsMultiSelectable(Value: Boolean);
    procedure Execute(const MenuContextList: IInterfaceList); overload;
    function PreExecute(const MenuContextList: IInterfaceList): Boolean;
    function PostExecute(const MenuContextList: IInterfaceList): Boolean;
  public
    constructor Create(const ACaption, AVerb, AParent: string; APosition: Integer;
      ACommand: TJVCSPMCommand; AMultiSelect: Boolean);
  end;

  TJVCSProjectMenuCreator = class(TNotifierObject, IOTAProjectMenuItemCreatorNotifier)
  protected
    { IOTAProjectMenuItemCreatorNotifier }
    procedure AddMenu(const Project: IOTAProject; const IdentList: TStrings;
      const ProjectManagerMenuList: IInterfaceList; IsMultiSelect: Boolean);
  end;

implementation

uses
  Winapi.Windows, JVCSExpertUtils, JVCSExpertDllBridge;

const
  cVerbFileRoot = 'JEDIVCS.PM.File';
  cVerbProjectRoot = 'JEDIVCS.PM.Project';

function OperationsReady: Boolean;
begin
  Result := Assigned(JVCSBridge) and JVCSBridge.Loaded and JVCSBridge.HasOperations;
end;

// Arquivo selecionado -> (modulo para a DLL, member = extensao original)
function MapModuleName(const AFileName: string; out AMember: string): string;
var
  Ext: string;
begin
  Ext := LowerCase(ExtractFileExt(AFileName));
  AMember := Ext;
  if (Ext = '.dfm') or (Ext = '.nfm') or (Ext = '.xfm') or (Ext = '.fmx') then
    Result := ChangeFileExt(AFileName, '.pas')
  else if Ext = '.h' then
    Result := ChangeFileExt(AFileName, '.cpp')
  else
    Result := AFileName;
end;

procedure ShowInfo(const AMsg: string);
begin
  MessageBox(JvcsIdeParentHandle, PChar(AMsg), cJvcsCaption, MB_OK or MB_ICONINFORMATION);
end;

{ TJVCSProjectManagerMenu }

constructor TJVCSProjectManagerMenu.Create(const ACaption, AVerb, AParent: string;
  APosition: Integer; ACommand: TJVCSPMCommand; AMultiSelect: Boolean);
begin
  inherited Create;
  FCaption := ACaption;
  FVerb := AVerb;
  FParent := AParent;
  FPosition := APosition;
  FCommand := ACommand;
  FIsMultiSelectable := AMultiSelect;
  FEnabled := True;
  FName := 'JEDIVCSPM_' + StringReplace(AVerb, '.', '_', [rfReplaceAll]);
end;

function TJVCSProjectManagerMenu.GetCaption: string;
begin
  Result := FCaption;
end;

function TJVCSProjectManagerMenu.GetChecked: Boolean;
begin
  Result := FChecked;
end;

function TJVCSProjectManagerMenu.GetEnabled: Boolean;
begin
  Result := FEnabled;
end;

function TJVCSProjectManagerMenu.GetHelpContext: Integer;
begin
  Result := FHelpContext;
end;

function TJVCSProjectManagerMenu.GetIsMultiSelectable: Boolean;
begin
  Result := FIsMultiSelectable;
end;

function TJVCSProjectManagerMenu.GetName: string;
begin
  Result := FName;
end;

function TJVCSProjectManagerMenu.GetParent: string;
begin
  Result := FParent;
end;

function TJVCSProjectManagerMenu.GetPosition: Integer;
begin
  Result := FPosition;
end;

function TJVCSProjectManagerMenu.GetVerb: string;
begin
  Result := FVerb;
end;

procedure TJVCSProjectManagerMenu.SetCaption(const Value: string);
begin
  FCaption := Value;
end;

procedure TJVCSProjectManagerMenu.SetChecked(Value: Boolean);
begin
  FChecked := Value;
end;

procedure TJVCSProjectManagerMenu.SetEnabled(Value: Boolean);
begin
  FEnabled := Value;
end;

procedure TJVCSProjectManagerMenu.SetHelpContext(Value: Integer);
begin
  FHelpContext := Value;
end;

procedure TJVCSProjectManagerMenu.SetIsMultiSelectable(Value: Boolean);
begin
  FIsMultiSelectable := Value;
end;

procedure TJVCSProjectManagerMenu.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TJVCSProjectManagerMenu.SetParent(const Value: string);
begin
  FParent := Value;
end;

procedure TJVCSProjectManagerMenu.SetPosition(Value: Integer);
begin
  FPosition := Value;
end;

procedure TJVCSProjectManagerMenu.SetVerb(const Value: string);
begin
  FVerb := Value;
end;

function TJVCSProjectManagerMenu.PreExecute(const MenuContextList: IInterfaceList): Boolean;
begin
  Result := True;
end;

function TJVCSProjectManagerMenu.PostExecute(const MenuContextList: IInterfaceList): Boolean;
begin
  Result := True;
end;

procedure TJVCSProjectManagerMenu.Execute(const MenuContextList: IInterfaceList);
var
  I: Integer;
  Ctx: IOTAProjectMenuContext;
begin
  try
    if (FCommand = pmcNone) or (MenuContextList = nil) then
      Exit;
    for I := 0 to MenuContextList.Count - 1 do
      if Supports(MenuContextList[I], IOTAProjectMenuContext, Ctx) then
      begin
        // sem conexao/projeto: UMA mensagem, e nao uma por arquivo selecionado
        if not ExecuteFor(Ctx.Project, Ctx.Ident) then
          Break;
        if not FIsMultiSelectable then
          Break;
      end;
  except
    JvcsLogCurrentException('TJVCSProjectManagerMenu.Execute(' + FVerb + ')');
  end;
end;

function TJVCSProjectManagerMenu.ExecuteFor(const AProject: IOTAProject;
  const AIdent: string): Boolean;
var
  ProjectName, ModuleName, Member: string;
  ProjectID: Integer;
  AS_: IOTAActionServices;
begin
  Result := False;
  JvcsLogFmt('Project Manager: %s "%s"', [FVerb, AIdent]);
  if FCommand = pmcReload then
  begin
    if Supports(BorlandIDEServices, IOTAActionServices, AS_) then
      AS_.ReloadFile(AIdent);
    Exit(True);
  end;
  if not OperationsReady then
    Exit;
  if AProject = nil then
    Exit(True);  // so este item; os demais podem ter projeto
  ProjectName := JvcsProjectSourceName(AProject);
  // a DLL guarda o ID por nome de projeto (ProjectNameToIDList)
  ProjectID := JVCSBridge.OpGetProjectID(ProjectName);
  if ProjectID <= 0 then
  begin
    ShowInfo(Format('JEDI VCS: nao foi possivel obter o projeto "%s" no servidor.' +
      sLineBreak + sLineBreak +
      'Conecte-se (menu JEDI VCS > Connect Server...) e confira se o projeto ' +
      'esta no arquivo do JEDI VCS. (GetProjectID = %d)',
      [ExtractFileName(ProjectName), ProjectID]));
    Exit;
  end;
  Result := True;
  ModuleName := MapModuleName(AIdent, Member);
  case FCommand of
    pmcCheckIn: JVCSBridge.OpCheckInModule(ProjectID, ModuleName);
    pmcCheckOut: JVCSBridge.OpCheckOutModule(ProjectID, ModuleName);
    pmcGet: JVCSBridge.OpGetModule(ProjectID, ModuleName);
    pmcCompare: JVCSBridge.OpCompareModule(ProjectID, ModuleName, Member);
    pmcDiff: JVCSBridge.OpDiffModule(ProjectID, ModuleName, Member);
    pmcHistory: JVCSBridge.OpShowModuleHistory(ProjectID, ModuleName);
    pmcManager: JVCSBridge.OpShowProjectManager(ProjectID);
    pmcProjectHistory: JVCSBridge.OpShowProjectHistory(ProjectID);
    pmcSync: JVCSBridge.OpSyncProject(ProjectID);
  end;
end;

{ TJVCSProjectMenuCreator }

procedure TJVCSProjectMenuCreator.AddMenu(const Project: IOTAProject;
  const IdentList: TStrings; const ProjectManagerMenuList: IInterfaceList;
  IsMultiSelect: Boolean);

  procedure Add(const ACaption, AVerb, AParent: string; APos: Integer;
    ACommand: TJVCSPMCommand; AMulti: Boolean);
  var
    Item: IOTAProjectManagerMenu;
  begin
    Item := TJVCSProjectManagerMenu.Create(ACaption, AVerb, AParent, APos,
      ACommand, AMulti);
    ProjectManagerMenuList.Add(Item);
  end;

begin
  try
    if (IdentList = nil) or (ProjectManagerMenuList = nil) or not OperationsReady then
      Exit;
    if IdentList.IndexOf(sFileContainer) >= 0 then
    begin
      Add(cJvcsCaption, cVerbFileRoot, '', pmmpUserVersionControl, pmcNone, True);
      Add('Check In/Put', cVerbFileRoot + '.CheckIn', cVerbFileRoot, 1, pmcCheckIn, True);
      Add('Check Out', cVerbFileRoot + '.CheckOut', cVerbFileRoot, 2, pmcCheckOut, True);
      Add('Get', cVerbFileRoot + '.Get', cVerbFileRoot, 3, pmcGet, True);
      Add('-', cVerbFileRoot + '.Sep1', cVerbFileRoot, 4, pmcNone, True);
      Add('Reload', cVerbFileRoot + '.Reload', cVerbFileRoot, 5, pmcReload, True);
      Add('-', cVerbFileRoot + '.Sep2', cVerbFileRoot, 6, pmcNone, True);
      Add('Compare', cVerbFileRoot + '.Compare', cVerbFileRoot, 7, pmcCompare, False);
      Add('Diff', cVerbFileRoot + '.Diff', cVerbFileRoot, 8, pmcDiff, False);
      Add('History', cVerbFileRoot + '.History', cVerbFileRoot, 9, pmcHistory, False);
    end
    else if IdentList.IndexOf(sProjectContainer) >= 0 then
    begin
      Add(cJvcsCaption, cVerbProjectRoot, '', pmmpUserVersionControl, pmcNone, False);
      Add('Manager', cVerbProjectRoot + '.Manager', cVerbProjectRoot, 1, pmcManager, False);
      Add('History', cVerbProjectRoot + '.History', cVerbProjectRoot, 2, pmcProjectHistory, False);
      Add('Synchronize/Restore', cVerbProjectRoot + '.Sync', cVerbProjectRoot, 3, pmcSync, False);
    end;
  except
    JvcsLogCurrentException('TJVCSProjectMenuCreator.AddMenu');
  end;
end;

end.
