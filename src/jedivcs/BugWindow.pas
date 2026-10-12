(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: BugWindow.pas

The Initial Developer of the original code (JEDI VCS) is:
  Marco Gosselink (marcogosselink@xs4all.nl)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:

-----------------------------------------------------------------------------

Unit history:

2003/05/20  MGosselink- initial release
2003/05/22  USchuster - changed parent class to TJVCSDockableForm
                      - changed unit header
                      - ProjAdmin now controls the docking
                      - D5 fix (removed Variants)
2003/11/23  USchuster - cleanup -> uses now interfaces for communication with projectmanager
                      - removed Windowpos saving (wasn't loaded and not necessary
                        for docked form) and an unnecessary imagelist
2003/11/30  USchuster - replaced server function calls with ClientObjects
2004/01/11  USchuster - refresh is now done in a separate thread
2004/01/25  USchuster - project bug refresh on rtSelectedProjectChanged will now only
                        be executed when the view is in project mode and vise versa
                        module bug refresh now only on rtSelectedModuleChanged
                        (after opening a project both refreshtypes will be dispatched
                         and thatswhy rtSelectedModuleChanged aborted the action from
                         rtSelectedProjectChanged and the project bug wasn't visible)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/09  THuber    - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
                      - jedistyle clean
                      - removed THREADREFRESH directive and matching code
2005/03/05  USchuster - use TJVCSDockableForm.HandleThreadException to ignore
                        appserver result 403 in the thread (mantis #2714)                      

-----------------------------------------------------------------------------*)

unit BugWindow;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  JVCSDockForm, StdCtrls, ExtCtrls, ComCtrls, EnhListView, ToolWin, ImgList,
  Menus, JVCSInterfaces, JVCSThreads;

const
  //MyBug-Listview columns
  colBugSeverity = 0;
  colBugName = 1;
  colBugDescription = 2;

var
  cSeverityDesc : array [0..4] of string;

type //USc 23.11.2003 should be moved into JVCSTypes because it's also defined in ProjAdmin.pas
  // Listview columns width
  TColWidth = record
    Col: array [0..12] of Word;
  end;

  TBugListType = (blLastBugType, blProjectBugs, blModuleBugs);

  TVCSBugWindow = class(TJVCSDockableForm, IJVCSRefresh)
    BugTypeImageList: TImageList;
    StateToDoImageImageList: TImageList;
    ToolBar2: TToolBar;
    tbRefresh: TToolButton;
    ToolButton41: TToolButton;
    ShowProjectBugsToolButton: TToolButton;
    ShowModuleBugsToolButton: TToolButton;
    elvBugs: TdfsEnhListView;
    Splitter2: TSplitter;
    mmoBug: TMemo;
    ToolButton1: TToolButton;
    tbShowProjectBugs: TToolButton;
    tbShowModuleBugs: TToolButton;
    tbShowBugManager: TToolButton;
    BugImageList: TImageList;
    procedure elvBugsDblClick(Sender: TObject);
    procedure elvBugsDrawHeader(Control: TWinControl; var ACanvas: TCanvas;
      Index: Integer; var ARect: TRect; Selected: Boolean;
      var DefaultDrawing: Boolean);
    procedure elvBugsDrawItem(Control: TWinControl; var ACanvas: TCanvas;
      Index: Integer; ARect: TRect; State: TOwnerDrawState;
      var DefaultDrawing, FullRowSelect: Boolean);
    procedure elvBugsDrawSubItem(Control: TWinControl;
      var ACanvas: TCanvas; Index, SubItem: Integer; ARect: TRect;
      State: TOwnerDrawState; var DefaultDrawing: Boolean);
    procedure elvBugsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure elvBugsDeletion(Sender: TObject; Item: TListItem);
    procedure ShowBugsToolButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tbShowProjectBugsClick(Sender: TObject);
    procedure tbShowBugManagerClick(Sender: TObject);
    procedure tbShowModuleBugsClick(Sender: TObject);
  private
    { Private declarations }
    ColWidthBugs: TColWidth;
    FProjectManager: IJVCSProjectManager;
    FInternalThread: TJVCSJobThread;
    FVCLSyncAction: Integer;
    FIsFilling: Boolean;
    FBugItems: TList;

    procedure AddBugLVItem(const LVItem: TListItem;
      ASeverity: Integer; BugName, Description: string; ADone: Boolean;
      const ID: Integer; const Changed: Boolean);
    procedure SetControlState(AEnabled: Boolean);
    procedure ThreadFillListView(AThreadJob: TJVCSThreadJob);
    procedure ThreadSetControlState(AThreadJob: TJVCSThreadJob);
    procedure VCLThreadSyncProc;
    procedure ClearBugItems;
  public
    { Public declarations }
    procedure SimpleRefresh(ARefreshType: TJVCSRefreshType);
    property ProjectManager: IJVCSProjectManager read FProjectManager write FProjectManager;
  end;

var
  VCSBugWindow: TVCSBugWindow;

implementation

uses
    DBModule
  , VCSBase
  , ConfigStorage
  , JVCSClientObj
  , JvJVCLUtils
  , JVCSGUIClientResources
{$IFDEF LANGUAGE}
  , JvGnugettext
{$ENDIF LANGUAGE}
  ;

{$R *.dfm}

const
  cSyncActionClearListView = 1;
  cSyncActionFillListViewProjectBugs = 2;
  cSyncActionFillListViewModuleBugs = 3;
  cSyncActionSetControlStateFalse = 4;
  cSyncActionSetControlStateOnDepend = 5;

procedure TVCSBugWindow.ThreadFillListView(AThreadJob: TJVCSThreadJob);
var
  SelectedModuleID: Integer;
  BugsByProject: TJVCSGetBugsByProject;
  BugsByModule: TJVCSGetBugsByModule;
  BugEntryPtr: PGetBugsByProjectOutputItem;
  I: Integer;
begin
  if not FIsFilling then
  begin
    FIsFilling := True;
    try
      FVCLSyncAction := cSyncActionClearListView;
      AThreadJob.Sync(VCLThreadSyncProc);
      if (ServerUserID > 0) and
        ((Integer(AThreadJob.Parameter) = cSyncActionFillListViewProjectBugs) or
        (Integer(AThreadJob.Parameter) = cSyncActionFillListViewModuleBugs)) then
      begin
        ClearBugItems;

        if Integer(AThreadJob.Parameter) = cSyncActionFillListViewProjectBugs then
        begin
          if ServerProjectID > 0 then
          begin
            BugsByProject := TJVCSGetBugsByProject.Create(nil);
            try
              BugsByProject.ProjectID := ServerProjectID;
              DataModule1.ClientObjectSendRequest(BugsByProject);

              with BugsByProject do
                for I := 0 to OutputItemCount - 1 do
                begin
                  New(BugEntryPtr);
                  BugEntryPtr^ := OutputItems[I];
                  FBugItems.Add(BugEntryPtr);
                end;
            finally
              BugsByProject.Free;
            end;
          end;
        end
        else // if TBugListType(elvBugs.Tag) = blProjectBugs then
        begin
          BugsByModule := TJVCSGetBugsByModule.Create(nil);
          try
            SelectedModuleID := -1;
            if Assigned(FProjectManager) then
              SelectedModuleID := FProjectManager.GetSelectedModuleID;
            if SelectedModuleID <> -1 then
            begin
              BugsByModule.ModuleID := SelectedModuleID;
              DataModule1.ClientObjectSendRequest(BugsByModule);

              with BugsByModule do
                for I := 0 to OutputItemCount - 1 do
                begin
                  New(BugEntryPtr);
                  BugEntryPtr^ := TGetBugsByProjectOutputItem(OutputItems[I]);
                  FBugItems.Add(BugEntryPtr);
                end;
            end;
          finally
            BugsByModule.Free;
          end;
        end;
        if not AThreadJob.Aborted then
        begin
          FVCLSyncAction := Integer(AThreadJob.Parameter);
          AThreadJob.Sync(VCLThreadSyncProc);
        end;
        ClearBugItems;
      end;
    finally
      FIsFilling := False;
    end;
  end;
end;

procedure TVCSBugWindow.ThreadSetControlState(AThreadJob: TJVCSThreadJob);
var
  ParameterInteger: Integer;
begin
  ParameterInteger := Integer(AThreadJob.Parameter);
  if (ParameterInteger = cSyncActionSetControlStateFalse) or
    (ParameterInteger = cSyncActionSetControlStateOnDepend) then
  begin
    FVCLSyncAction := ParameterInteger;
    AThreadJob.Sync(VCLThreadSyncProc);
  end;
end;

procedure TVCSBugWindow.VCLThreadSyncProc;
var
  I: Integer;
begin
  if FVCLSyncAction = cSyncActionClearListView then
    elvBugs.Items.Clear
  else
  if (FVCLSyncAction = cSyncActionFillListViewProjectBugs) or
    (FVCLSyncAction = cSyncActionFillListViewModuleBugs)
  then
  begin
    elvBugs.BeginUpdate;
    try
      for I := 0 to Pred(FBugItems.Count) do
        with PGetBugsByProjectOutputItem(FBugItems[I])^ do
          AddBugLVItem(nil,
            Severity,
            BugName,
            Description,
            Done,
            BugID,
            False);
    finally
      elvBugs.EndUpdate;
    end;
    if elvBugs.Items.Count > 0 then
    begin
      elvBugs.Resort;
      elvBugs.Selected := nil;
      elvBugs.Invalidate;
    end; // if elvBugs.Items.Count > 0 then begin
  end
  else
  if FVCLSyncAction = cSyncActionSetControlStateFalse then
    SetControlState(False)
  else
  if FVCLSyncAction = cSyncActionSetControlStateOnDepend then
    SetControlState(ServerUserID > 0);
end;

procedure TVCSBugWindow.ClearBugItems;
var
  I: Integer;
begin
  for I := 0 to Pred(FBugItems.Count) do
    Dispose(FBugItems[I]);
  FBugItems.Clear;
end;

type
  TLVBugData = record
    ID,
    Severity: Integer;
    Changed: Boolean;
    Done: Boolean;
  end;

var
  PLVBugData: ^TLVBugData;

procedure TVCSBugWindow.AddBugLVItem(const LVItem: TListItem;
  ASeverity: Integer; BugName, Description: string; ADone: Boolean;
  const ID: Integer; const Changed: Boolean);
var
  NewLVItem: TListItem;
  NewItem: Boolean;
  I: Integer;
begin
  NewItem := (LVItem = nil);
  if NewItem then
    NewLVItem := elvBugs.Items.Add
  else
    NewLVItem := LVItem;

  NewLVItem.ImageIndex := ASeverity;
  if ADone then
    NewLVItem.StateIndex := 1;
  NewLVItem.Caption := cSeverityDesc[ASeverity];
  if NewItem then
  begin
    NewLVItem.SubItems.Add(BugName);
    NewLVItem.SubItems.Add(Description);

    New(PLVBugData);
    PLVBugData^.ID := ID;
    PLVBugData^.Severity := 0;
    PLVBugData^.Changed := Changed;
    PLVBugData^.Done := ADone;
    NewLVItem.Data := PLVBugData;

    for I := 0 to elvBugs.Items.Count - 1 do
      elvBugs.Items[I].Selected := False;
    NewLVItem.Selected := True;
  end // if NewItem then begin
  else
  begin
    NewLVItem.SubItems[0] := cSeverityDesc[ASeverity];
    NewLVItem.SubItems[1] := BugName;
    NewLVItem.SubItems[2] := Description;

    TLVBugData(NewLVItem.Data^).ID := ID;
    TLVBugData(NewLVItem.Data^).Severity := 0;
    TLVBugData(NewLVItem.Data^).Changed := Changed;
    TLVBugData(NewLVItem.Data^).Done := ADone;
  end;
end;

procedure TVCSBugWindow.elvBugsDblClick(Sender: TObject);
begin
  if Assigned(FProjectManager) and Assigned(elvBugs.Selected) then
    if ShowProjectBugsToolButton.Down then
      FProjectManager.ExecuteProjectBugManager
    else
      FProjectManager.ExecuteModuleBugManager;
end;

procedure TVCSBugWindow.elvBugsDrawHeader(Control: TWinControl;
  var ACanvas: TCanvas; Index: Integer; var ARect: TRect;
  Selected: Boolean; var DefaultDrawing: Boolean);
begin
  DefaultDrawing := True;
end;

procedure TVCSBugWindow.elvBugsDrawItem(Control: TWinControl;
  var ACanvas: TCanvas; Index: Integer; ARect: TRect;
  State: TOwnerDrawState; var DefaultDrawing, FullRowSelect: Boolean);
begin
  DefaultDrawing := True;
  FullRowSelect := True;
end;

procedure TVCSBugWindow.elvBugsDrawSubItem(Control: TWinControl;
  var ACanvas: TCanvas; Index, SubItem: Integer; ARect: TRect;
  State: TOwnerDrawState; var DefaultDrawing: Boolean);
begin
  DefaultDrawing := True;
end;

procedure TVCSBugWindow.elvBugsSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if Selected and Assigned(Item) then
    mmoBug.Text := Item.SubItems[colBugDescription-1]
  else
    mmoBug.Text := '';
end;

procedure TVCSBugWindow.FormCreate(Sender: TObject);
begin
  try
    // same for ColWidthMyBug
    with ColWidthBugs do
    begin
      Col[colBugSeverity] :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_BugCol1.0', 60);
      Col[colBugName] :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_BugCol1.1', 70);
      Col[colBugDescription] :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_BugCol1.2', 200);
    end;
    // Set width of BugListView.columns
    with elvBugs do
    begin
      Columns[colBugSeverity].Width := ColWidthBugs.Col[colBugSeverity];
      Columns[colBugName].Width := ColWidthBugs.Col[colBugName];
      Columns[colBugDescription].Width := ColWidthBugs.Col[colBugDescription];
    end;

    elvBugs.Width := jvcsReadInteger(sBaseRegistryKey + crbWindows, 'splBugLeft', 500);

    FProjectManager := nil;
  {//USc - ProjAdmin now controls the docking of the bugwindow
    if jvcsReadBool(sBaseRegistryKey + crbWindows, 'ProjMan_BugWinDocked', True) then
      if Floating then
        ManualDock(VCSProjAdmin.pgStatus, VCSBugWindow, alClient);
  }
    FInternalThread := TJVCSJobThread.Create(False);
    FInternalThread.OnJobException := HandleThreadException;
    FIsFilling := False;
    FBugItems := TList.Create;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
    // Fill Resourcestrings
    cSeverityDesc[0] := JVCSRES_Minor;
    cSeverityDesc[1] := JVCSRES_Awkward;
    cSeverityDesc[2] := JVCSRES_Significant;
    cSeverityDesc[3] := JVCSRES_Serious;
    cSeverityDesc[4] := JVCSRES_Fatal;
  end;    
end;

procedure TVCSBugWindow.FormDestroy(Sender: TObject);
var
  ColBugsChanged: Boolean;
  I: Integer;
begin
  jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'splBugLeft', elvBugs.Width);
{//USc - ProjAdmin now controls the docking of the bugwindow
  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'ProjMan_BugWinDocked', not VCSBugWindow.Floating);
}
  ColBugsChanged := False;
  with elvBugs do
  begin
    for I := 0 to Columns.Count -1 do
    begin
      if ColWidthBugs.Col[I] <> Columns[I].Width then
      begin
        ColBugsChanged := True;
        Break;
      end;
    end;
    if ColBugsChanged then
    begin
      ColWidthBugs.Col[colBugSeverity] := Columns[colBugSeverity].Width;
      ColWidthBugs.Col[colBugName] := Columns[colBugName].Width;
      ColWidthBugs.Col[colBugDescription] := Columns[colBugDescription].Width;
    end; // if ColBugsChanged then begin
  end; // with elvBugs do begin

  if ColBugsChanged then
  begin
    with ColWidthBugs do
    begin
      jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjMan_BugCol1.0', Col[colBugSeverity]);
      jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjMan_BugCol1.1', Col[colBugName]);
      jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjMan_BugCol1.2', Col[colBugDescription]);
    end;
  end;
  ClearBugItems;
  FBugItems.Free;
  FInternalThread.Free;
end;

procedure TVCSBugWindow.elvBugsDeletion(Sender: TObject; Item: TListItem);
begin
  if Assigned(Item.Data) then
  begin
    Dispose(Item.Data);
    Item.Data := nil;
  end;
end;

procedure TVCSBugWindow.ShowBugsToolButtonClick(Sender: TObject);
var
  ButtonTag: Integer;
begin
  ButtonTag := (Sender as TToolButton).Tag;

  if TBugListType(ButtonTag) in [blProjectBugs, blModuleBugs] then
    elvBugs.Tag := ButtonTag;
  FInternalThread.DisqueueAndAbortAllJobsAndWait;
  if TBugListType(elvBugs.Tag) = blProjectBugs then
    FInternalThread.AddJob(ThreadFillListView,
      Pointer(cSyncActionFillListViewProjectBugs))
  else
  if TBugListType(elvBugs.Tag) = blModuleBugs then
    FInternalThread.AddJob(ThreadFillListView,
      Pointer(cSyncActionFillListViewModuleBugs));
end;

procedure TVCSBugWindow.SetControlState(AEnabled: Boolean);
begin
  tbRefresh.Enabled := AEnabled;
  ShowProjectBugsToolButton.Enabled := AEnabled;
  ShowModuleBugsToolButton.Enabled := AEnabled;
  tbShowBugManager.Enabled := AEnabled;
  tbShowProjectBugs.Enabled := AEnabled and bProjectOpen and (ServerProjectID > 0);
  tbShowModuleBugs.Enabled := AEnabled and Assigned(FProjectManager) and
    (FProjectManager.GetSelectedModuleID > 0);
end;

procedure TVCSBugWindow.SimpleRefresh(ARefreshType: TJVCSRefreshType);
begin
  case ARefreshType of
    rtConnected, rtRefresh:
    begin
      FInternalThread.DisqueueAndAbortAllJobsAndWait;
      FInternalThread.AddJob(ThreadSetControlState,
        Pointer(cSyncActionSetControlStateOnDepend));
      if ShowProjectBugsToolButton.Down then
        FInternalThread.AddJob(ThreadFillListView,
          Pointer(cSyncActionFillListViewProjectBugs))
      else
        FInternalThread.AddJob(ThreadFillListView,
          Pointer(cSyncActionFillListViewModuleBugs));
    end;
    rtDisconnected, rtProjectClosing:
    begin
      FInternalThread.DisqueueAndAbortAllJobsAndWait;
      FInternalThread.AddJob(ThreadSetControlState,
        Pointer(cSyncActionSetControlStateFalse));
      FInternalThread.AddJob(ThreadFillListView,
        Pointer(cSyncActionClearListView));
    end;
    rtSelectedProjectChanged:
    begin
      if ShowProjectBugsToolButton.Down then
      begin
        FInternalThread.DisqueueAndAbortAllJobsAndWait;
        FInternalThread.AddJob(ThreadSetControlState,
          Pointer(cSyncActionSetControlStateOnDepend));
        FInternalThread.AddJob(ThreadFillListView,
          Pointer(cSyncActionFillListViewProjectBugs));
      end;
    end;
    rtSelectedModuleChanged:
    begin
      if ShowModuleBugsToolButton.Down then
      begin
        FInternalThread.DisqueueAndAbortAllJobsAndWait;
        FInternalThread.AddJob(ThreadSetControlState,
          Pointer(cSyncActionSetControlStateOnDepend));
        FInternalThread.AddJob(ThreadFillListView,
          Pointer(cSyncActionFillListViewModuleBugs));
      end;
    end;
  end;
end;

procedure TVCSBugWindow.FormShow(Sender: TObject);
begin
  inherited;
  SimpleRefresh(rtRefresh);
end;

procedure TVCSBugWindow.tbShowProjectBugsClick(Sender: TObject);
begin
  inherited;
  if Assigned(FProjectManager) then
    FProjectManager.ExecuteProjectBugManager;
end;

procedure TVCSBugWindow.tbShowBugManagerClick(Sender: TObject);
begin
  inherited;
  if Assigned(FProjectManager) then
    FProjectManager.ExecuteBugManager;
end;

procedure TVCSBugWindow.tbShowModuleBugsClick(Sender: TObject);
begin
  inherited;
  if Assigned(FProjectManager) then
    FProjectManager.ExecuteModuleBugManager;
end;

end.
