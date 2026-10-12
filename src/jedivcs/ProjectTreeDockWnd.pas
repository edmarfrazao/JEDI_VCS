(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: ProjectTreeDockWnd.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
Jan/04:
- Is there a reason why bug images won't be used for unassigned projects ?
  (same behavior in SelectedProjectID.pas)
ToDo
- share code with SelectProjectID.pas or merge
-----------------------------------------------------------------------------

Unit history:

2003/09/15  USchuster - new unit (code moved from ProjAdmin.pas)
2003/10/21  THuber    - #1181 omit deleted projects in group hierarchy
2003/11/30  USchuster - replaced server function calls with ClientObjects
2004/01/11  USchuster - refresh is now done in a separate thread
2004/01/25  USchuster - TreeView is now readonly (it was possible to rename a project
                        and if you tryed to open it ProjAdmin reported a new project)
                      - bug images will now be shown
2004/02/26  USchuster - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/20  USchuster - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
                      - removed THREADREFRESH directive and matching code
2004/11/02  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
2004/12/29  USchuster - changes to suppress projects without at least
                        read only access (mantis #2254)
2005/03/05  USchuster - use TJVCSDockableForm.HandleThreadException to ignore
                        appserver result 403 in the thread (mantis #2714)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC3 was released ^^^^^^^^^^^^^^^^^^^^^^^^^^^
2005/12/31  USchuster - added menu items "Refresh" and "Hide projects without any rights" and
                        project groups will be tried to load with guest accounts as well (mantis #3193)
                      - the tree view state will now be restored after refresh (mantis #3398)
2006/01/04  USchuster - "disabled" state restore after reconnect
2007/04/23  USchuster - improved performance (mantis #4072)
2007/06/04  USchuster - BugIndexImageOffset (changes for project treeview dialog)
2008/12/19  USchuster - changes for new tree with filter (disabled [not yet finished])
2009/02/07  USchuster - fixed restore problem and behavior on disconnect with new tree
                        and enabled new tree with filter
2009/11/28  USchuster - the highlighted text color is now only used when the tree has the focus,
                        because otherwise white text on light gray background isn't that readable
                      - fixed unwanted refresh of the active project when the tree was refreshed
2011/01/15  USchuster - changed font to Tahoma                      

-----------------------------------------------------------------------------*)

unit ProjectTreeDockWnd;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  JVCSDockForm, ComCtrls, JvComCtrls, ImgList, Menus, JVCSInterfaces,
  JVCSDataClasses, JVCSThreads, JvExComCtrls, JVCSProjectTreeUnit,
  VirtualTrees, StdCtrls, ExtCtrls;

type
  TJVCSDockProjectTree = class(TJVCSDockableForm, IJVCSRefresh)
    tvHierachy: TJvTreeView;
    HierachyImageList: TImageList;
    ProjectFolderPopup: TPopupMenu;
    Expandall1: TMenuItem;
    Collapseall1: TMenuItem;
    StateImageList: TImageList;
    ForceRefresh1: TMenuItem;
    mnHideprojectswithoutanyrights: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    VSTHierarchy: TVirtualDrawTree;
    pnlFilter: TPanel;
    edFilterText: TEdit;
    cboxFilterKind: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tvHierachyClick(Sender: TObject);
    procedure tvHierachyKeyPress(Sender: TObject; var Key: Char);
    procedure Expandall1Click(Sender: TObject);
    procedure Collapseall1Click(Sender: TObject);
    procedure ProjectFolderPopupPopup(Sender: TObject);
    procedure ForceRefresh1Click(Sender: TObject);
    procedure mnHideprojectswithoutanyrightsClick(Sender: TObject);
    procedure VSTHierarchyGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure VSTHierarchyInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure VSTHierarchyInitChildren(Sender: TBaseVirtualTree;
      Node: PVirtualNode; var ChildCount: Cardinal);
    procedure VSTHierarchyGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure VSTHierarchyFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure FilterChange(Sender: TObject);
    procedure VSTHierarchyDrawNode(Sender: TBaseVirtualTree;
      const PaintInfo: TVTPaintInfo);
    procedure VSTHierarchyGetNodeWidth(Sender: TBaseVirtualTree;
      HintCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      var NodeWidth: Integer);
    procedure VSTHierarchyExpanded(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure VSTHierarchyCollapsed(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
  private
    { Private declarations }
    OpenProjectBusy: Boolean;
    FProjectManager: IJVCSProjectManager;
    GroupsAvailable: Boolean;
    UnAssgndCreated: Boolean;
    FInternalThread: TJVCSJobThread;
    FVCLSyncAction: Integer;
    FIsFilling: Boolean;
    FIsFilled: Boolean;
    FLastArchiveTimeStamp: TDateTime;
    FOpenGroups: TList;
    FTopItemID: Integer;
    FTopItemIsProject: Boolean;
    FHideProjectsWithoutRights: Boolean;
    FProjectTreeContainer: TProjectTreeContainer;
    FVSTContainer: TVSTContainer;
    FInFocusActiveProject: Boolean;
    FOldTree: Boolean;
    procedure DoFocusActiveProject;
    procedure DoOpenProject(ASelectedProjectID: Integer;
      ASelectedProjectName: string);
    procedure ThreadFillTreeView(AThreadJob: TJVCSThreadJob);
    procedure UpdateVST(ASetContainer: Boolean = False; AContainer: TProjectTreeContainer = nil);
    procedure VCLThreadSyncProc;
  public
    { Public declarations }
    procedure SimpleRefresh(ARefreshType: TJVCSRefreshType);
    property ProjectManager: IJVCSProjectManager read FProjectManager write FProjectManager;
  end;

var
  JVCSDockProjectTree: TJVCSDockProjectTree;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  DBModule, SelectProjectID, VCSBase, JVCSMruList, JVCSClientObj, JVCSGUIClientResources,
  JVCSTypes, ConfigStorage, JvJCLUtils;

{$R *.dfm}

const
  cSyncActionClearTreeView = 1;
  cSyncActionFillTreeView = 2;
  cSyncActionForceFillTreeView = 3;

procedure TJVCSDockProjectTree.ThreadFillTreeView(AThreadJob: TJVCSThreadJob);

  //equal to JVCSDataClasses::TModuleStateDataList.GetArchiveTimeStamp
  function GetArchiveTimeStamp: TDateTime;
  var
    GetArchiveTstamp: TJVCSGetArchiveTstamp;
  begin
    GetArchiveTstamp := TJVCSGetArchiveTstamp.Create(nil);
    try
      DataModule1.ClientObjectSendRequest(GetArchiveTstamp);
      Result := GetArchiveTstamp.Timestamp;
    finally
      GetArchiveTstamp.Free;
    end;
  end;

var
  CurrentArchiveTimeStamp: TDateTime;
  ReadedArchiveTimeStamp: Boolean;
  //equal to JVCSDataClasses::TModuleStateDataList.GetStateByName/GetCurrentArchiveTimeStamp
  function GetCurrentArchiveTimeStamp: TDateTime;
  begin
    if not ReadedArchiveTimeStamp then
    begin
      CurrentArchiveTimeStamp := GetArchiveTimeStamp;
      ReadedArchiveTimeStamp := True;
    end;
    Result := CurrentArchiveTimeStamp;
  end;

begin
  CurrentArchiveTimeStamp := 0;
  ReadedArchiveTimeStamp := False;
  if not FIsFilling then
  begin
    FIsFilling := True;
    try
      if (Integer(AThreadJob.Parameter) = cSyncActionClearTreeView) then
      begin
        FIsFilled := False;
        FLastArchiveTimeStamp := 0;
        FVCLSyncAction := cSyncActionClearTreeView;
        AThreadJob.Sync(VCLThreadSyncProc);
      end
      else
      if (ServerUserID > 0) and
        (Integer(AThreadJob.Parameter) in [cSyncActionFillTreeView, cSyncActionForceFillTreeView]) then
      begin
        if (not FIsFilled) or (Integer(AThreadJob.Parameter) = cSyncActionForceFillTreeView) or
          (FLastArchiveTimeStamp <> GetCurrentArchiveTimeStamp) then
        begin
          FIsFilled := False;
          FLastArchiveTimeStamp := GetCurrentArchiveTimeStamp;

          if FOldTree then
          begin
            FVCLSyncAction := cSyncActionClearTreeView;
            AThreadJob.Sync(VCLThreadSyncProc);
          end;

          FProjectTreeContainer.Clear;
          FProjectTreeContainer.Read(GetJvcsConnection, FHideProjectsWithoutRights);

          FVCLSyncAction := cSyncActionFillTreeView;
          AThreadJob.Sync(VCLThreadSyncProc);

          FIsFilled := True;
        end;
      end;
    finally
      FIsFilling := False;
    end;
  end;
end;

procedure TJVCSDockProjectTree.UpdateVST(ASetContainer: Boolean = False; AContainer: TProjectTreeContainer = nil);
begin
  VSTHierarchy.BeginUpdate;
  try
    FVSTContainer.SaveStateInfo(VSTHierarchy);
    if ASetContainer then
      FVSTContainer.ProjectTreeContainer := AContainer;
    VSTHierarchy.RootNodeCount := 0;
    case cboxFilterKind.ItemIndex of
      0: FVSTContainer.FilterItems(True, edFilterText.Text, '');
      1: FVSTContainer.FilterItems(True, '', edFilterText.Text);
      2, 3: FVSTContainer.FilterItems(True, edFilterText.Text, edFilterText.Text, cboxFilterKind.ItemIndex = 3);
    end;
    VSTHierarchy.RootNodeCount := FVSTContainer.RootTreeItem.Count;
    VSTHierarchy.ReinitNode(VSTHierarchy.RootNode, True);
    FInFocusActiveProject := True;
    try
      FVSTContainer.RestoreStateInfo(VSTHierarchy);
    finally
      FInFocusActiveProject := False;
    end;
  finally
    VSTHierarchy.EndUpdate;
  end;
end;

procedure TJVCSDockProjectTree.VCLThreadSyncProc;
begin
  if FVCLSyncAction = cSyncActionClearTreeView then
  begin
    if FOldTree then
    begin
      FProjectTreeContainer.SaveTreeViewState(tvHierachy);
      tvHierachy.Items.Clear;
    end
    else
      VSTHierarchy.RootNodeCount := 0;
    GroupsAvailable := False;
    UnAssgndCreated := False;
  end
  else
  if FVCLSyncAction = cSyncActionFillTreeView then
  begin
    GroupsAvailable := False;
    UnAssgndCreated := False;
    if FOldTree then
    begin
      FProjectTreeContainer.SaveTreeViewState(tvHierachy);
      tvHierachy.Items.Clear;
      FProjectTreeContainer.Apply(tvHierachy);
      FProjectTreeContainer.RestoreTreeViewState(tvHierachy);
    end
    else
      UpdateVST(True, FProjectTreeContainer);
  end;
end;

procedure TJVCSDockProjectTree.FormCreate(Sender: TObject);
begin
  try
    inherited;
    FProjectTreeContainer := TProjectTreeContainer.Create;
    FProjectTreeContainer.BugIndexImageOffset := 1;
    GroupsAvailable := False;
    UnAssgndCreated := False;
    FProjectManager := nil;
    OpenProjectBusy := False;
    FInternalThread := TJVCSJobThread.Create(False);
    FInternalThread.OnJobException := HandleThreadException;
    FIsFilling := False;
    FIsFilled := False;
    FLastArchiveTimeStamp := 0;
    FOpenGroups := TList.Create;
    FTopItemID := -1;
    FTopItemIsProject := False;
    mnHideprojectswithoutanyrights.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbWindows, 'DockProjectTree_HideProjectsWithoutRights', True);
    FHideProjectsWithoutRights := mnHideprojectswithoutanyrights.Checked;
    FVSTContainer := TVSTContainer.Create;
    FVSTContainer.ProjectTreeContainer.BugIndexImageOffset := 1;
    VSTHierarchy.NodeDataSize := SizeOf(TVSTTreeItem);
    FInFocusActiveProject := False;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
  FOldTree := False;
  if FOldTree then
  begin
    VSTHierarchy.Visible := False;
    pnlFilter.Visible := False;
    tvHierachy.Align := alClient;
    tvHierachy.Visible := True;
  end
  else
    cboxFilterKind.ItemIndex := 1;
end;

procedure TJVCSDockProjectTree.FormShow(Sender: TObject);
begin
  inherited;
  SimpleRefresh(rtRefresh);
end;

procedure TJVCSDockProjectTree.FormDestroy(Sender: TObject);
begin
  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'DockProjectTree_HideProjectsWithoutRights',
    mnHideprojectswithoutanyrights.Checked);
  FOpenGroups.Free;
  FInternalThread.Free;
  FProjectTreeContainer.Free;
  FVSTContainer.Free;
  inherited;
end;

procedure TJVCSDockProjectTree.tvHierachyClick(Sender: TObject);
var
  SelectedProjectID: Integer;
  SelectedProjectName: string;
  RecentProjectList: TJVCSMruList;
  Project: TProjectTreeProject;
begin
  // which one is selected, set as active project when not Open Project
  if (not OpenProjectBusy) and Assigned(tvHierachy.Selected) and
    Assigned(tvHierachy.Selected.Data) and (TObject(tvHierachy.Selected.Data) is TProjectTreeProject) then
  begin
    Project := TProjectTreeProject(tvHierachy.Selected.Data);
    SelectedProjectID := Project.ProjectData.ProjectID;
    SelectedProjectName := Project.ProjectName;
    RecentProjectList := TJVCSMruList.CreateEx(sBaseRegistryKey + crbMRU + '22');
    RecentProjectList.AddString(SelectedProjectName);
    RecentProjectList.Free;
    DoOpenProject(SelectedProjectID, SelectedProjectName);
  end;
end;

procedure TJVCSDockProjectTree.tvHierachyKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Chr(13) then
    tvHierachyClick(Sender);
end;

procedure TJVCSDockProjectTree.Expandall1Click(Sender: TObject);
begin
  if FOldTree then
    tvHierachy.FullExpand
  else
    VSTHierarchy.FullExpand;
end;

procedure TJVCSDockProjectTree.Collapseall1Click(Sender: TObject);
begin
  if FOldTree then
    tvHierachy.FullCollapse
  else
    VSTHierarchy.FullCollapse;
end;

procedure TJVCSDockProjectTree.ProjectFolderPopupPopup(Sender: TObject);
begin
  if FOldTree then
    Expandall1.Enabled := tvHierachy.Items.Count > 0
  else
    Expandall1.Enabled := FVSTContainer.RootTreeItem.Count > 0;
  Collapseall1.Enabled := Expandall1.Enabled;
end;

//------------------------------------------------------------------------------

procedure TJVCSDockProjectTree.DoFocusActiveProject;

  function FindProjectNode(ANode: PVirtualNode; AProjectID: Integer): PVirtualNode;
  var
    Data: ^TVSTTreeItem;
  begin
    Result := nil;
    while Assigned(ANode) do
    begin
      Data := VSTHierarchy.GetNodeData(ANode);
      if Data^.LinkedItem is TProjectTreeProject then
        if TProjectTreeProject(Data^.LinkedItem).ProjectData.ProjectID = AProjectID then
        begin
          Result := ANode;
          Break;
        end;
      ANode := VSTHierarchy.GetNext(ANode);
    end;
  end;

var
  ProjectNode: PVirtualNode;
begin
  if (not FOldTree) and (ServerProjectID > 0) then
  begin
    ProjectNode := FindProjectNode(VSTHierarchy.RootNode^.FirstChild, ServerProjectID);
    if Assigned(ProjectNode) then
    begin
      FInFocusActiveProject := True;
      try
        VSTHierarchy.FocusedNode := ProjectNode;
        VSTHierarchy.Selected[ProjectNode] := True;
      finally
        FInFocusActiveProject := False;
      end;
    end;
  end;
end;

procedure TJVCSDockProjectTree.DoOpenProject(ASelectedProjectID: Integer;
  ASelectedProjectName: string);
begin
  if not OpenProjectBusy then
    try
      OpenProjectBusy := True;
      if Assigned(FProjectManager) then
        FProjectManager.OpenProject(ASelectedProjectID, ASelectedProjectName);
    finally
      OpenProjectBusy := False;
    end;
end;

procedure TJVCSDockProjectTree.SimpleRefresh(ARefreshType: TJVCSRefreshType);
begin
  case ARefreshType of
    rtConnected, rtRefresh:
      begin
        if ARefreshType = rtConnected then
        begin
          FOpenGroups.Clear;
          FTopItemID := -1;
          FTopItemIsProject := False;
        end;
        FInternalThread.DisqueueAndAbortAllJobsAndWait;
        FInternalThread.AddJob(ThreadFillTreeView,
          Pointer(cSyncActionFillTreeView));
      end;
    rtDisconnected:
      begin
        FInternalThread.DisqueueAndAbortAllJobsAndWait;
        FInternalThread.AddJob(ThreadFillTreeView,
          Pointer(cSyncActionClearTreeView));
      end;
    rtSelectedProjectChanged:
      if not OpenProjectBusy then
        DoFocusActiveProject;
  end;
end;

procedure TJVCSDockProjectTree.ForceRefresh1Click(Sender: TObject);
begin
  inherited;
  FInternalThread.DisqueueAndAbortAllJobsAndWait;
  FInternalThread.AddJob(ThreadFillTreeView,
    Pointer(cSyncActionForceFillTreeView));
end;

procedure TJVCSDockProjectTree.mnHideprojectswithoutanyrightsClick(
  Sender: TObject);
begin
  inherited;
  mnHideprojectswithoutanyrights.Checked := not mnHideprojectswithoutanyrights.Checked;
  FHideProjectsWithoutRights := mnHideprojectswithoutanyrights.Checked;
  FInternalThread.DisqueueAndAbortAllJobsAndWait;
  FInternalThread.AddJob(ThreadFillTreeView,
    Pointer(cSyncActionForceFillTreeView));
end;

procedure TJVCSDockProjectTree.VSTHierarchyGetText(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType; var CellText: WideString);
var
  Data: ^TCustomProjectTreeItem;
begin
  inherited;
  Data := Sender.GetNodeData(Node);
  if Data^ is TProjectTreeGroup then
    CellText := TProjectTreeGroup(Data^).GroupName
  else
  if Data^ is TProjectTreeProject then
    CellText := TProjectTreeProject(Data^).ProjectName;
end;

procedure TJVCSDockProjectTree.VSTHierarchyInitNode(
  Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode;
  var InitialStates: TVirtualNodeInitStates);
var
  Data, ParentData: ^TVSTTreeItem;
  ParentTreeItem: TVSTTreeItem;
begin
  inherited;
  Data := Sender.GetNodeData(Node);
  if not Assigned(ParentNode) then
    ParentTreeItem := FVSTContainer.RootTreeItem
  else
  begin
    ParentData := Sender.GetNodeData(ParentNode);
    if ParentData^ is TVSTTreeItem then
      ParentTreeItem := TVSTTreeItem(ParentData^)
    else
      ParentTreeItem := nil;
  end;
  if Assigned(ParentTreeItem) then
  begin
    Data^ := ParentTreeItem[Node^.Index];
    if ParentTreeItem[Node^.Index].Count > 0 then
    begin
      Include(InitialStates, ivsHasChildren);
      if ParentTreeItem[Node^.Index].Expanded then
        Include(InitialStates, ivsExpanded);
    end;
  end
  else
    Data^ := nil;
end;

procedure TJVCSDockProjectTree.VSTHierarchyInitChildren(
  Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
var
  Data: ^TVSTTreeItem;
begin
  inherited;
  Data := Sender.GetNodeData(Node);
  ChildCount := TVSTTreeItem(Data^).Count;
end;

procedure TJVCSDockProjectTree.VSTHierarchyGetImageIndex(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind;
  Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
var
  Data: ^TVSTTreeItem;
begin
  inherited;
  Data := Sender.GetNodeData(Node);
  if Data^.LinkedItem is TProjectTreeGroup then
  begin
    case Kind of
      ikNormal: ImageIndex := 0;
      ikSelected: ImageIndex := 1;
      else
        ImageIndex := -1;
    end;
  end
  else
  if Data^.LinkedItem is TProjectTreeProject then
  begin
    case Kind of
      ikNormal: ImageIndex := 2;
      ikSelected: ImageIndex := 2;
      ikState: if TProjectTreeProject(Data^.LinkedItem).ProjectData.BugIndex >= 0 then
                 ImageIndex := TProjectTreeProject(Data^.LinkedItem).ProjectData.BugIndex + FVSTContainer.ProjectTreeContainer.BugIndexImageOffset
               else
                 ImageIndex := -1;
      else
        ImageIndex := -1;
    end;
  end
  else
    ImageIndex := -1;
end;

procedure TJVCSDockProjectTree.VSTHierarchyFocusChanged(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
var
  Data: ^TVSTTreeItem;
  SelectedProjectID: Integer;
  SelectedProjectName: string;
  RecentProjectList: TJVCSMruList;
  Project: TProjectTreeProject;
begin
  inherited;
  // which one is selected, set as active project when not Open Project
  if (not FInFocusActiveProject) and (not OpenProjectBusy) and Assigned(Node) then
  begin
    Data := Sender.GetNodeData(Node);
    if Data^.LinkedItem is TProjectTreeProject then
    begin
      Project := TProjectTreeProject(Data^.LinkedItem);
      SelectedProjectID := Project.ProjectData.ProjectID;
      SelectedProjectName := Project.ProjectName;
      RecentProjectList := TJVCSMruList.CreateEx(sBaseRegistryKey + crbMRU + '22');
      RecentProjectList.AddString(SelectedProjectName);
      RecentProjectList.Free;
      DoOpenProject(SelectedProjectID, SelectedProjectName);
    end;
  end;
end;

procedure TJVCSDockProjectTree.FilterChange(Sender: TObject);
begin
  inherited;
  UpdateVST;
end;

procedure TJVCSDockProjectTree.VSTHierarchyDrawNode(
  Sender: TBaseVirtualTree; const PaintInfo: TVTPaintInfo);
var
  Data: ^TVSTTreeItem;
  R: TRect;
begin
  inherited;
  Data := Sender.GetNodeData(PaintInfo.Node);
  R := PaintInfo.ContentRect;
  InflateRect(R, -TVirtualDrawTree(Sender).TextMargin, 0);
  R.Left := R.Left - 2;
  R.Top := R.Top + 2;
  R.Right := R.Left;
  if Sender.Selected[PaintInfo.Node] and Sender.Focused then
    PaintInfo.Canvas.Font.Color := clHighlightText
  else
    PaintInfo.Canvas.Font.Color := clWindowText;
  SetBKMode(PaintInfo.Canvas.Handle, TRANSPARENT);
  ItemHtDraw(PaintInfo.Canvas, R, [], Data^.Text, False);
end;

procedure TJVCSDockProjectTree.VSTHierarchyGetNodeWidth(
  Sender: TBaseVirtualTree; HintCanvas: TCanvas; Node: PVirtualNode;
  Column: TColumnIndex; var NodeWidth: Integer);
var
  Data: ^TVSTTreeItem;
begin
  inherited;
  Data := Sender.GetNodeData(Node);
  NodeWidth := ItemHtWidth(HintCanvas, Rect(0, 0, 0, 0), [], Data^.Text, False) + 5;
end;

procedure TJVCSDockProjectTree.VSTHierarchyExpanded(
  Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  Data: ^TVSTTreeItem;
begin
  inherited;
  Data := Sender.GetNodeData(Node);
  Data^.Expanded := True;
end;

procedure TJVCSDockProjectTree.VSTHierarchyCollapsed(
  Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  Data: ^TVSTTreeItem;
begin
  inherited;
  Data := Sender.GetNodeData(Node);
  Data^.Expanded := False;
end;

end.
