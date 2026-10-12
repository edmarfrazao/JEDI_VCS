(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSLockedModulesDockWnd.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2005/11/28  USchuster - new unit for mantis #3291
2005/12/11  USchuster - minor fixes (hint, multi checkin, refresh) (mantis #3349)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC3 was released ^^^^^^^^^^^^^^^^^^^^^^^^^^^
2005/12/28  USchuster - fixed checkin of multiple files(mantis #3380)
2005/12/30  USchuster - added "Undo Check Out" menu item (mantis #3381)
2006/01/02  THuber    #3404 align set to alClient
2006/12/10  USchuster - changes for menu bitmaps and added "View" function
2007/03/07  USchuster - replaced "Open Parent Folder" code by function ShellOpenParentFolder (mantis #4079)
2008/03/15  USchuster - added "Line History" menu item to the popup menu
2008/07/15  USchuster - added initial double click action support
2010/01/24  USchuster - added "Diff" menu items (Mantis #5101)
2010/01/28  USchuster - images for "Diff" menu items (Mantis #5101)
2012/09/02  AKroeber  - added SaveWIP
2015/04/04  USchuster - added "Diff All Local vs. Archive" menu item
2015/04/11  USchuster - fixed "Diff All Local vs. Archive" for modules of different projects 

-----------------------------------------------------------------------------*)

unit JVCSLockedModulesDockWnd;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  JVCSDockForm, ImgList, ComCtrls, ToolWin, EnhListView, JVCSInterfaces,
  JVCSThreads, VCSBase, Menus, JVCSCompressedDiffDialog;

type
  TJVCSDockLockedModulesWindow = class(TJVCSDockableForm, IJVCSRefresh)
    ToolBar1: TToolBar;
    tbRefresh: TToolButton;
    ToolImageList: TImageList;
    elvLockedModules: TdfsEnhListView;
    popmSharedby: TPopupMenu;
    mnCheckIn: TMenuItem;
    N5: TMenuItem;
    ShowsharedBy1: TMenuItem;
    N6: TMenuItem;
    mnCompare: TMenuItem;
    mnHistory: TMenuItem;
    N7: TMenuItem;
    mnOpenParentFolder: TMenuItem;
    N8: TMenuItem;
    mnOpenProject: TMenuItem;
    N1: TMenuItem;
    mnUndoCheckOut: TMenuItem;
    N2: TMenuItem;
    mnOpenFile: TMenuItem;
    mnLineHistory: TMenuItem;
    mnDiff1: TMenuItem;
    mnDiff2: TMenuItem;
    mnDiff3To5: TMenuItem;
    mnDiff3: TMenuItem;
    mnDiff4: TMenuItem;
    mnDiff5: TMenuItem;
    tbSaveWIP: TToolButton;
    mnCompareAllLocalArchive: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tbRefreshClick(Sender: TObject);
    procedure elvLockedModulesDrawHeader(Control: TWinControl;
      var ACanvas: TCanvas; Index: Integer; var ARect: TRect;
      Selected: Boolean; var DefaultDrawing: Boolean);
    procedure elvLockedModulesDrawItem(Control: TWinControl;
      var ACanvas: TCanvas; Index: Integer; ARect: TRect;
      State: TOwnerDrawState; var DefaultDrawing, FullRowSelect: Boolean);
    procedure elvLockedModulesDrawSubItem(Control: TWinControl;
      var ACanvas: TCanvas; Index, SubItem: Integer; ARect: TRect;
      State: TOwnerDrawState; var DefaultDrawing: Boolean);
    procedure popmSharedbyPopup(Sender: TObject);
    procedure mnCheckInClick(Sender: TObject);
    procedure ShowsharedBy1Click(Sender: TObject);
    procedure mnCompareClick(Sender: TObject);
    procedure mnHistoryClick(Sender: TObject);
    procedure mnOpenParentFolderClick(Sender: TObject);
    procedure mnOpenProjectClick(Sender: TObject);
    procedure mnUndoCheckOutClick(Sender: TObject);
    procedure mnOpenFileClick(Sender: TObject);
    procedure mnLineHistoryClick(Sender: TObject);
    procedure elvLockedModulesDblClick(Sender: TObject);
    procedure mnDiff1Click(Sender: TObject);
    procedure tbSaveWIPClick(Sender: TObject);
    procedure mnCompareAllLocalArchiveClick(Sender: TObject);
  private
    { Private declarations }
    FCurrentModuleProjects: string;
    FCurrentModuleID: Integer;
    FInternalThread: TJVCSJobThread;
    FIsFilling: Boolean;
    FLockedModules: TList;
    FOpenProjectBusy: Boolean;
    FProjectManager: IJVCSProjectManager;
    FVCLSyncAction: Integer;
    FCurrentModuleFileNames: TStringList;
    procedure ClearLockedModules;
    function GetSelectedModule(var AModuleID: Integer): Boolean;
    function GetSelectedModuleName(var AModuleModuleName: string): Boolean;    
    function GetSelectedModules(ASelectedModuleList: TList): Integer;
    procedure SetControlState(AEnabled: Boolean);    
    procedure ThreadFillListView(AThreadJob: TJVCSThreadJob);
    procedure ThreadSetControlState(AThreadJob: TJVCSThreadJob);
    procedure VCLThreadSyncProc;
  public
    { Public declarations }
    procedure SimpleRefresh(ARefreshType: TJVCSRefreshType);
    property ProjectManager: IJVCSProjectManager read FProjectManager write FProjectManager;
  end;

var
  JVCSDockLockedModulesWindow: TJVCSDockLockedModulesWindow;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  JVCSClientObj, DBModule, TZHandling, ChkInSingle, VCSProcBase, Std_ListView,
  History, JVCSGuiClientResources, TextComp, ConfigStorage, ShellAPI, JVCSDialogs,
  JVCSChkInOutCommon, LoadModule, JVCSGUIClientImages, Options, SaveWIP;

{$R *.dfm}

const
  cSyncActionClearListView = 1;
  cSyncActionFillListView = 2;
  cSyncActionAddModuleProjects = 3;
  cSyncActionSetControlStateFalse = 4;
  cSyncActionSetControlStateOnDepend = 5;

  sitPath = 0;
  sitMID = 1;
  sitProjects = 5;

procedure TJVCSDockLockedModulesWindow.ThreadFillListView(AThreadJob: TJVCSThreadJob);

  function GetProjects(AModuleID: Integer): string;
  var
    GetSharedBy: TJVCSGetSharedBy;
    I: Integer;
  begin
    Result := '';
    GetSharedBy := TJVCSGetSharedBy.Create(nil);
    try
      GetSharedBy.ModuleID := AModuleID;
      DataModule1.ClientObjectSendRequest(GetSharedBy);

      with GetSharedBy do
      begin
        for I := 0 to OutputItemCount - 1 do
        begin
          if Result <> '' then Result := Result + ', ';
          Result := Result + OutputItems[I].ProjectName;
        end;
      end;
    finally
      GetSharedBy.Free;
    end;
  end;

var
  GetLockedModules: TJVCSGetLockedModules;
  LockedModulePtr: PGetLockedModulesOutputItem;
  I: Integer;
begin
  if not FIsFilling then
  begin
    FIsFilling := True;
    try
      FVCLSyncAction := cSyncActionClearListView;
      AThreadJob.Sync(VCLThreadSyncProc);
      if (ServerUserID > 0) and
        (Integer(AThreadJob.Parameter) = cSyncActionFillListView) then
      begin
        ClearLockedModules;
        GetLockedModules := TJVCSGetLockedModules.Create(nil);
        try
          GetLockedModules.UserID := ServerUserID;
          DataModule1.ClientObjectSendRequest(GetLockedModules);

          with GetLockedModules do
            for I := 0 to OutputItemCount - 1 do
            begin
              New(LockedModulePtr);
              LockedModulePtr^ := OutputItems[I];
              FLockedModules.Add(LockedModulePtr);
            end;
        finally
          GetLockedModules.Free;
        end;
        if not AThreadJob.Aborted then
        begin
          FVCLSyncAction := Integer(AThreadJob.Parameter);
          AThreadJob.Sync(VCLThreadSyncProc);
        end;
        for I := 0 to Pred(FLockedModules.Count) do
          if not AThreadJob.Aborted then
          begin
            LockedModulePtr := FLockedModules[I];
            FCurrentModuleProjects := GetProjects(LockedModulePtr^.ModuleID);
            FCurrentModuleID := LockedModulePtr^.ModuleID;
            FVCLSyncAction := cSyncActionAddModuleProjects;
            AThreadJob.Sync(VCLThreadSyncProc);
          end;
        ClearLockedModules;
      end;
    finally
      FIsFilling := False;
    end;
  end;
end;

procedure TJVCSDockLockedModulesWindow.ThreadSetControlState(AThreadJob: TJVCSThreadJob);
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

procedure TJVCSDockLockedModulesWindow.VCLThreadSyncProc;
var
  I: Integer;
  ListItem: TListItem;
begin
  if FVCLSyncAction = cSyncActionClearListView then
    elvLockedModules.Items.Clear
  else
  if FVCLSyncAction = cSyncActionFillListView then
  begin
    elvLockedModules.BeginUpdate;
    try
      for I := 0 to Pred(FLockedModules.Count) do
        with PGetLockedModulesOutputItem(FLockedModules[I])^ do
        begin
          ListItem := elvLockedModules.Items.Add;
          ListItem.Data := Pointer(ModuleID);
          ListItem.Caption := ModuleName;
          ListItem.SubItems.Add(ModulePath);          
          ListItem.SubItems.Add(IntToStr(ModuleID));
          ListItem.SubItems.Add(IntToStr(Version));
          ListItem.SubItems.Add(IntToStr(Revision));
          ListItem.SubItems.Add(DateTimeToStr(GMTDT2LocalDT(LockedTimestamp)));
        end;
    finally
      elvLockedModules.EndUpdate;
    end;
    if elvLockedModules.Items.Count > 0 then
    begin
      elvLockedModules.Resort;
      elvLockedModules.Selected := nil;
      elvLockedModules.Invalidate;
    end; // if elvLockedModules.Items.Count > 0 then begin
  end
  else
  if FVCLSyncAction = cSyncActionAddModuleProjects then
  begin
    for I := 0 to Pred(elvLockedModules.Items.Count) do
      if elvLockedModules.Items[I].Data = Pointer(FCurrentModuleID) then
      begin
        elvLockedModules.Items[I].SubItems.Add(FCurrentModuleProjects);
        Break;
      end;
  end
  else
  if FVCLSyncAction = cSyncActionSetControlStateFalse then
    SetControlState(False)
  else
  if FVCLSyncAction = cSyncActionSetControlStateOnDepend then
    SetControlState(ServerUserID > 0);
end;

procedure TJVCSDockLockedModulesWindow.ClearLockedModules;
var
  I: Integer;
begin
  for I := 0 to Pred(FLockedModules.Count) do
    Dispose(FLockedModules[I]);
  FLockedModules.Clear;
end;

function TJVCSDockLockedModulesWindow.GetSelectedModule(var AModuleID: Integer): Boolean;
begin
  AModuleID := -1;
  if Assigned(elvLockedModules.Selected) then
    AModuleID := StrToIntDef(elvLockedModules.Selected.SubItems[sitMID], 0);
  Result := AModuleID > 0;
end;

function TJVCSDockLockedModulesWindow.GetSelectedModuleName(var AModuleModuleName: string): Boolean;
begin
  AModuleModuleName := '';;
  if Assigned(elvLockedModules.Selected) then
    AModuleModuleName := elvLockedModules.Selected.SubItems[sitPath] + elvLockedModules.Selected.Caption;
  Result := AModuleModuleName <> '';
end;

function TJVCSDockLockedModulesWindow.GetSelectedModules(ASelectedModuleList: TList): Integer;
var
  I: Integer;
begin
  Result := 0;
  if (elvLockedModules.SelCount > 0) and Assigned(ASelectedModuleList) then
    for I := 0 to Pred(elvLockedModules.Items.Count) do
      if elvLockedModules.Items[I].Selected then
      begin
        ASelectedModuleList.Add(elvLockedModules.Items[I]);
        Inc(Result);
      end;
end;

procedure TJVCSDockLockedModulesWindow.SetControlState(AEnabled: Boolean);
begin
  tbRefresh.Enabled := AEnabled;
end;

procedure TJVCSDockLockedModulesWindow.SimpleRefresh(ARefreshType: TJVCSRefreshType);
begin
  case ARefreshType of
    rtConnected, rtRefresh:
    begin
      FInternalThread.DisqueueAndAbortAllJobsAndWait;
      FInternalThread.AddJob(ThreadSetControlState,
        Pointer(cSyncActionSetControlStateOnDepend));
      FInternalThread.AddJob(ThreadFillListView, Pointer(cSyncActionFillListView));
    end;
    rtDisconnected:
    begin
      FInternalThread.DisqueueAndAbortAllJobsAndWait;
      FInternalThread.AddJob(ThreadSetControlState,
        Pointer(cSyncActionSetControlStateFalse));
      FInternalThread.AddJob(ThreadFillListView,
        Pointer(cSyncActionClearListView));
    end;
  end;
end;

procedure TJVCSDockLockedModulesWindow.FormShow(Sender: TObject);
begin
  inherited;
  SimpleRefresh(rtRefresh);
end;

procedure TJVCSDockLockedModulesWindow.FormCreate(Sender: TObject);
const
  ColumnWidthArray: array [0..6] of Integer = (150, 170, 50, 50, 50, 120, 300);
var
  I: Integer;
begin
  inherited;
  try
    with elvLockedModules do
      for I := 0 to Columns.Count -1 do
        if I <= High(ColumnWidthArray) then
          Columns[I].Width :=
            jvcsReadInteger(sBaseRegistryKey + crbWindows, 'LockedModulesWin_Col1.' + IntToStr(I), ColumnWidthArray[I]);
    FInternalThread := TJVCSJobThread.Create(False);
    FInternalThread.OnJobException := HandleThreadException;
    FIsFilling := False;
    FLockedModules := TList.Create;
    FOpenProjectBusy := False;
    FProjectManager := nil;
    FCurrentModuleFileNames := TStringList.Create;
    {$IFDEF IDEDLL}
    N8.Visible := False;
    mnOpenProject.Visible := False;
    {$ENDIF IDEDLL}
    if ShowMenuBitmaps then
      popmSharedby.Images := GetToolImageList;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

procedure TJVCSDockLockedModulesWindow.FormDestroy(Sender: TObject);
var
  I: Integer;
begin
  inherited;
  with elvLockedModules do
    for I := 0 to Columns.Count -1 do
      jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'LockedModulesWin_Col1.' + IntToStr(I),
        Columns[I].Width);
  ClearLockedModules;
  FCurrentModuleFileNames.Free;
  FLockedModules.Free;
  FInternalThread.Free;
end;

procedure TJVCSDockLockedModulesWindow.tbRefreshClick(Sender: TObject);
begin
  inherited;
  SimpleRefresh(rtRefresh);
end;

procedure TJVCSDockLockedModulesWindow.tbSaveWIPClick(Sender: TObject);
begin
  inherited;
  DoSaveWIP;
end;

procedure TJVCSDockLockedModulesWindow.elvLockedModulesDrawHeader(
  Control: TWinControl; var ACanvas: TCanvas; Index: Integer;
  var ARect: TRect; Selected: Boolean; var DefaultDrawing: Boolean);
begin
  inherited;
  DefaultDrawing := True;
end;

procedure TJVCSDockLockedModulesWindow.elvLockedModulesDrawItem(
  Control: TWinControl; var ACanvas: TCanvas; Index: Integer; ARect: TRect;
  State: TOwnerDrawState; var DefaultDrawing, FullRowSelect: Boolean);
begin
  inherited;
  DefaultDrawing := True;
  FullRowSelect := True;
end;

procedure TJVCSDockLockedModulesWindow.elvLockedModulesDrawSubItem(
  Control: TWinControl; var ACanvas: TCanvas; Index, SubItem: Integer;
  ARect: TRect; State: TOwnerDrawState; var DefaultDrawing: Boolean);
begin
  inherited;
  DefaultDrawing := True;
end;

procedure TJVCSDockLockedModulesWindow.popmSharedbyPopup(Sender: TObject);
var
  I, DummyInt: Integer;
  AdditionalFiles: TStringList;
  ModuleName: string;
  DiffMenuItems: TList;
begin
  mnCheckIn.Enabled := GetSelectedModule(DummyInt);
  mnUndoCheckOut.Enabled := mnCheckIn.Enabled;
  mnCompare.Enabled := mnCheckIn.Enabled and (elvLockedModules.SelCount = 1);
  mnCompareAllLocalArchive.Enabled := mnCheckIn.Enabled;
  mnOpenParentFolder.Enabled := mnCompare.Enabled;
  mnOpenProject.Enabled := mnCompare.Enabled;
  mnHistory.Enabled := mnCompare.Enabled;
  mnLineHistory.Enabled := mnCompare.Enabled and Assigned(FProjectManager);
  ShowsharedBy1.Enabled := mnCompare.Enabled;
  mnOpenFile.Enabled := mnCompare.Enabled;

  mnDiff1.Enabled := mnCompare.Enabled;
  GetSelectedModuleName(ModuleName);
  if mnDiff1.Enabled and (ModuleName <> '') then
  begin
    FCurrentModuleFileNames.Clear;
    FCurrentModuleFileNames.AddObject(ModuleName, mnDiff1);
    mnDiff1.Caption := Format('Diff (%s)', [ExtractFileExt(ModuleName)]);
    DiffMenuItems := TList.Create;
    AdditionalFiles := TStringList.Create;
    try
      DiffMenuItems.Add(mnDiff1);
      DiffMenuItems.Add(mnDiff2);
      DiffMenuItems.Add(mnDiff3);
      DiffMenuItems.Add(mnDiff4);
      DiffMenuItems.Add(mnDiff5);
      GetAdditionalFilesFromFileFamily(ModuleName, AdditionalFiles);
      for I := 0 to Pred(AdditionalFiles.Count) do
        FCurrentModuleFileNames.Add(AdditionalFiles[I]);
      for I := 1 to Pred(DiffMenuItems.Count) do
      begin
        TMenuItem(DiffMenuItems[I]).Visible := FCurrentModuleFileNames.Count > I;
        if FCurrentModuleFileNames.Count > I then
        begin
          FCurrentModuleFileNames.Objects[I] := DiffMenuItems[I];
          if I < 2 then
            TMenuItem(DiffMenuItems[I]).Caption := Format('Diff (%s)', [ExtractFileExt(FCurrentModuleFileNames[I])])
          else
            TMenuItem(DiffMenuItems[I]).Caption := ExtractFileExt(FCurrentModuleFileNames[I]);
        end;
      end;
      mnDiff3To5.Visible := AdditionalFiles.Count > 1;
    finally
      AdditionalFiles.Free;
      DiffMenuItems.Free;
    end;
  end
  else
  begin
    mnDiff1.Caption := 'Diff';
    mnDiff2.Visible := False;
    mnDiff3To5.Visible := False;
    FCurrentModuleFileNames.Clear;
  end;
end;

procedure TJVCSDockLockedModulesWindow.mnCheckInClick(Sender: TObject);
var
  I, J, CurrentModuleID: Integer;
  SelectedModuleList: TList;
  CurrentProjectState: TGUIClientProjectState;
  GetRevisionListById: TJVCSGetRevisionListById;
  CheckedOut: Boolean;
  CurrentItem: TListItem;
  S: string;
begin
  SelectedModuleList := TList.Create;
  try
    if GetSelectedModules(SelectedModuleList) > 0 then
    begin
      CurrentProjectState := SaveProjectState;
      try
        VCSChkInSingle := TVCSChkInSingle.Create(Application);
        try
          for I := 0 to Pred(SelectedModuleList.Count) do
          begin
            CurrentItem := TListItem(SelectedModuleList[I]);
            CurrentModuleID := StrToIntDef(CurrentItem.SubItems[sitMID], 0);
            if OpenFirstModuleProject(CurrentModuleID, 2) then
              VCSChkInSingle.SelectModuleList.AddObject('>' + IntToStr(CurrentModuleID), TObject(ServerProjectID))
            else
            begin
              //should only happen for guests and if the rw right was removed by admin after check out
              WarnMessageBox(Format(JVCSRES_File_6037s62, [CurrentItem.SubItems[sitPath] + CurrentItem.Caption]) + #13 +
                JVCSRES_JEDI_VCS_cannot_check_in_this_file46 + #13 +
                JVCSRES_Probably_you_don39t_have_the_required_rights_for_this46);
            end;
          end;
          if VCSChkInSingle.SelectModuleList.Count > 0 then
          begin
            VCSChkInSingle.AsChild := True;
            VCSChkInSingle.ShowModal;
            if VCSChkInSingle.ArchiveChanged then
            begin
              for I := 0 to Pred(SelectedModuleList.Count) do
              begin
                CurrentItem := TListItem(SelectedModuleList[I]);
                CurrentModuleID := StrToIntDef(CurrentItem.SubItems[sitMID], 0);
                ServerProjectID := -1;
                for J := 0 to Pred(VCSChkInSingle.SelectModuleList.Count) do
                begin
                  S := VCSChkInSingle.SelectModuleList[J];
                  Delete(S, 1, 1);
                  if CurrentModuleID = StrToIntDef(S, 0) then
                  begin
                    ServerProjectID := Integer(VCSChkInSingle.SelectModuleList.Objects[J]);
                    Break;
                  end;
                end;
                if ServerProjectID > 0 then
                begin
                  //check module state and remove from listview if it is not longer locked
                  GetRevisionListById := TJVCSGetRevisionListById.Create(nil);
                  try
                    GetRevisionListById.ProjectID := ServerProjectID;
                    GetRevisionListById.ModuleID := CurrentModuleID;
                    DataModule1.ClientObjectSendRequest(GetRevisionListById);
                    CheckedOut := (GetRevisionListById.OutputItemCount > 0) and
                      (GetRevisionListById.OutputItems[Pred(GetRevisionListById.OutputItemCount)].Owner <> '');
                    if not CheckedOut then
                      CurrentItem.Delete;
                  finally
                    GetRevisionListById.Free;
                  end;
                  if Assigned(FProjectManager) then
                    FProjectManager.RefreshSingleModule(CurrentModuleID);
                end;
              end;
            end;
          end;
        finally
          VCSChkInSingle.Free;
        end;
      finally
        RestoreProjectState(CurrentProjectState);
      end;
    end;
  finally
    SelectedModuleList.Free;
  end;
end;

procedure TJVCSDockLockedModulesWindow.ShowsharedBy1Click(Sender: TObject);
var 
  ResultString: string;
  VCSStdListView2: TVCSStdListView;
  SelectedModuleID: Integer;
begin
  if GetSelectedModule(SelectedModuleID) then
  begin
    with DataModule1 do
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_SHARED_BY';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [SelectedModuleID]);
      SetupTimeoutCounter;
      AppSrvClient1.Send;

      while WaitForAppSrvClient do 
        Application.ProcessMessages;
      if (AppSrvClientErr = -99) then 
      begin
        ShowServerTimeOut(WindowHandle);
        Exit;
      end;
      if (AppSrvClientErr <> 0) or
        (AppSrvClient1.AnswerStatus <> '200') then 
      begin
        ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
          AppSrvClient1.AnswerStatus);
        Exit;
      end;

      AppSrvClient1.Answer.First;
      ResultString := '';
      while not AppSrvClient1.Answer.Eof do
      begin
        ResultString := ResultString + AppSrvClient1.Answer.Fields[1] + ';' +
          AppSrvClient1.Answer.Fields[0] + ';|';
        AppSrvClient1.Answer.Next;
      end;
    end; // with DataModule1 do begin
    Application.CreateForm(TVCSStdListView, VCSStdListView2);
    try
      VCSStdListView2.Caption := elvLockedModules.Selected.Caption;
      VCSStdListView2.Left := Left + 60;
      VCSStdListView2.Top := Top + 60;
      VCSStdListView2.LVType := 0;
      VCSStdListView2.HelpContextID :=
        IDH_Sharing_modules_between_different_projects;
      VCSStdListView2.AddListColumn(JVCSRES_Shared_by_project__, False);
      VCSStdListView2.AddListColumn(JVCSRES_Project_ID, True);
      VCSStdListView2.SetUpItems(ResultString);
      VCSStdListView2.ShowModal;
    finally
      VCSStdListView2.Free;
    end;
  end;
end;

procedure TJVCSDockLockedModulesWindow.mnCompareAllLocalArchiveClick(Sender: TObject);
var
  I, CurrentModuleID: Integer;
  SelectedModuleList: TList;
  CurrentProjectState: TGUIClientProjectState;
  CurrentItem: TListItem;
  CompareModules: TCompareModuleList;
  CompareModule: TCompareModule;
  LastProjects: string;
begin
  SelectedModuleList := TList.Create;
  try
    if GetSelectedModules(SelectedModuleList) > 0 then
    begin
      CurrentProjectState := SaveProjectState;
      try
        CurrentItem := TListItem(SelectedModuleList[0]);
        CurrentModuleID := StrToIntDef(CurrentItem.SubItems[sitMID], 0);
        LastProjects := CurrentItem.SubItems[sitProjects];
        if OpenFirstModuleProject(CurrentModuleID, 1) then
        begin
          CompareModules := TCompareModuleList.Create;
          try
            for I := 0 to Pred(SelectedModuleList.Count) do
            begin
              CurrentItem := TListItem(SelectedModuleList[I]);
              if CurrentItem.SubItems[sitProjects] <> LastProjects then
              begin
                CurrentModuleID := StrToIntDef(CurrentItem.SubItems[sitMID], 0);
                OpenFirstModuleProject(CurrentModuleID, 1);
                LastProjects := CurrentItem.SubItems[sitProjects];
              end;
              CompareModule := CompareModules.Add(StrToIntDef(CurrentItem.SubItems[sitMID], 0),
                CurrentItem.SubItems[sitPath] + CurrentItem.Caption);
              CompareModule.Revision1.Kind := cmrkLocal;
              CompareModule.Revision2.Kind := cmrkLatest;
              CompareModule.ProjectID := ServerProjectID;
            end;
            CompareModules.Compare;
          finally
            CompareModules.Free;
          end;
        end;
      finally
        RestoreProjectState(CurrentProjectState);
      end;
    end;
  finally
    SelectedModuleList.Free;
  end;
end;

procedure TJVCSDockLockedModulesWindow.mnCompareClick(Sender: TObject);
var
  SelectedModuleID: Integer;
  SelectedModuleFileName: string;
  CurrentProjectState: TGUIClientProjectState;
  GetModuleName: TJVCSGetModuleName;
begin
  if GetSelectedModule(SelectedModuleID) then
  begin
    CurrentProjectState := SaveProjectState;
    try
      if OpenFirstModuleProject(SelectedModuleID, 1) then
      begin
        GetModuleName := TJVCSGetModuleName.Create(nil);
        try
          GetModuleName.ModuleID := SelectedModuleID;
          DataModule1.ClientObjectSendRequest(GetModuleName);
          SelectedModuleFileName := GetModuleName.ModuleName;
        finally
          GetModuleName.Free;
        end;
        DoModuleCompare(SelectedModuleFileName);
      end;
    finally
      RestoreProjectState(CurrentProjectState);
    end;
  end;
end;

procedure TJVCSDockLockedModulesWindow.mnDiff1Click(Sender: TObject);
var
  I, SelectedModuleID: Integer;
  SelectedModuleFileName, Extension: string;
  CurrentProjectState: TGUIClientProjectState;
begin
  if GetSelectedModule(SelectedModuleID) and GetSelectedModuleName(SelectedModuleFileName) and
    (FCurrentModuleFileNames.Count > 0) and (FCurrentModuleFileNames[0] = SelectedModuleFileName) then
  begin
    Extension := '';
    for I := 0 to Pred(FCurrentModuleFileNames.Count) do
      if Sender = FCurrentModuleFileNames.Objects[I] then
      begin
        Extension := ExtractFileExt(FCurrentModuleFileNames[I]);
        Break;
      end;
    if Extension <> '' then
    begin
      CurrentProjectState := SaveProjectState;
      try
        if OpenFirstModuleProject(SelectedModuleID, 1) then
          ShowCompressDiffDialogLocalToLatest(ChangeFileExt(SelectedModuleFileName, Extension), Extension, SelectedModuleID);
      finally
        RestoreProjectState(CurrentProjectState);
      end;
    end;
  end;
end;

procedure TJVCSDockLockedModulesWindow.mnHistoryClick(Sender: TObject);
var
  SelectedModuleID: Integer;
  SelectedModuleFileName: string;
  CurrentProjectState: TGUIClientProjectState;
  GetModuleName: TJVCSGetModuleName;
begin
  if GetSelectedModule(SelectedModuleID) then
  begin
    CurrentProjectState := SaveProjectState;
    try
      if OpenFirstModuleProject(SelectedModuleID, 1) then
      begin
        GetModuleName := TJVCSGetModuleName.Create(nil);
        try
          GetModuleName.ModuleID := SelectedModuleID;
          DataModule1.ClientObjectSendRequest(GetModuleName);
          SelectedModuleFileName := GetModuleName.ModuleName;
        finally
          GetModuleName.Free;
        end;
        VCSHistory := TVCSHistory.Create(Application);
        try
          VCSHistory.ModuleName := SelectedModuleFileName;
          VCSHistory.ModuleID := SelectedModuleID;
          VCSHistory.ShowModal;
        finally
          VCSHistory.Free;
        end;
      end;
    finally
      RestoreProjectState(CurrentProjectState);
    end;
  end;
end;

procedure TJVCSDockLockedModulesWindow.mnOpenParentFolderClick(
  Sender: TObject);
var
  SelectedModuleID: Integer;
  CurrentProjectState: TGUIClientProjectState;
  GetModuleName: TJVCSGetModuleName;
  SelectedModuleFileName: string;
begin
  if GetSelectedModule(SelectedModuleID) then
  begin
    CurrentProjectState := SaveProjectState;
    try
      if OpenFirstModuleProject(SelectedModuleID, 1) then
      begin
        GetModuleName := TJVCSGetModuleName.Create(nil);
        try
          GetModuleName.ModuleID := SelectedModuleID;
          DataModule1.ClientObjectSendRequest(GetModuleName);
          SelectedModuleFileName := GetModuleName.ModuleName;
        finally
          GetModuleName.Free;
        end;
        ShellOpenParentFolder(SelectedModuleFileName);
      end;
    finally
      RestoreProjectState(CurrentProjectState);
    end;
  end;
end;

procedure TJVCSDockLockedModulesWindow.mnOpenProjectClick(Sender: TObject);
{$IFNDEF IDEDLL}
var
  SelectedModuleID: Integer;
  CurrentProjectState: TGUIClientProjectState;
  FSelectedProjectID: Integer;
  FSelectedProjectName: string;
  FOpenProjectSelected: Boolean;
{$ENDIF ~IDEDLL}
begin
  {$IFNDEF IDEDLL}
  if GetSelectedModule(SelectedModuleID) then
  begin
    FOpenProjectSelected := False;
    FSelectedProjectID := -1;
    CurrentProjectState := SaveProjectState;
    try
      if OpenFirstModuleProject(SelectedModuleID, 1) then
      begin
        FSelectedProjectID := ServerProjectID;
        FSelectedProjectName := sProjectName;
        FOpenProjectSelected := True;
      end;
    finally
      RestoreProjectState(CurrentProjectState);
    end;
    if Assigned(FProjectManager) and FOpenProjectSelected then
    begin
      if not FOpenProjectBusy then
      begin
        FOpenProjectBusy := True;
        try
          FProjectManager.OpenProject(FSelectedProjectID, FSelectedProjectName);
        finally
          FOpenProjectBusy := False;
        end;
      end;
    end;
  end;
  {$ENDIF ~IDEDLL}
end;

procedure TJVCSDockLockedModulesWindow.mnUndoCheckOutClick(Sender: TObject);
var
  SelectedModuleList: TList;
  CurrentProjectState: TGUIClientProjectState;
  GetRevisionListById: TJVCSGetRevisionListById;
  CheckedOut: Boolean;
  CurrentItem: TListItem;
  UndoCheckOutModuleList: TUndoCheckOutModuleList;
  UndoCheckedOutModule: TUndoCheckOutModule;
  I, J, CurrentModuleID, CurrentRevisionID: Integer;
  DummyStopRefresh: Boolean;
begin
  SelectedModuleList := TList.Create;
  try
    if GetSelectedModules(SelectedModuleList) > 0 then
    begin
      CurrentProjectState := SaveProjectState;
      try
        UndoCheckOutModuleList := TUndoCheckOutModuleList.Create;
        try
          for I := 0 to Pred(SelectedModuleList.Count) do
          begin
            CurrentItem := TListItem(SelectedModuleList[I]);
            CurrentModuleID := StrToIntDef(CurrentItem.SubItems[sitMID], 0);
            if OpenFirstModuleProject(CurrentModuleID, 2) then
            begin
              CurrentRevisionID := -1;
              GetRevisionListById := TJVCSGetRevisionListById.Create(nil);
              try
                GetRevisionListById.ProjectID := ServerProjectID;
                GetRevisionListById.ModuleID := CurrentModuleID;
                DataModule1.ClientObjectSendRequest(GetRevisionListById);
                if GetRevisionListById.OutputItemCount > 0 then
                  CurrentRevisionID := GetRevisionListById.OutputItems[Pred(GetRevisionListById.OutputItemCount)].RevisionID;
              finally
                GetRevisionListById.Free;
              end;
              if CurrentRevisionID > 0 then
              begin
                UndoCheckedOutModule := UndoCheckOutModuleList.Add;
                UndoCheckedOutModule.Name := CurrentItem.Caption;
                UndoCheckedOutModule.Path := CurrentItem.SubItems[sitPath];
                UndoCheckedOutModule.ProjectID := ServerProjectID;
                UndoCheckedOutModule.ModuleID := CurrentModuleID;
                UndoCheckedOutModule.RevisionID := CurrentRevisionID;
                UndoCheckedOutModule.OwnerName := sCurrentUser;
              end
              else
                WarnMessageBox(Format(JVCSRES_Undo_Check_Out_of_6037s62_failed33, [CurrentItem.SubItems[sitPath] + CurrentItem.Caption]));
            end
            else
            begin
              //should only happen for guests and if the rw right was removed by admin after check out
              WarnMessageBox(Format(JVCSRES_Undo_Check_Out_of_6037s62_failed33, [CurrentItem.SubItems[sitPath] + CurrentItem.Caption]) + #13 +
                JVCSRES_Probably_you_don39t_have_the_required_rights_for_this46);
            end;
          end;
          if UndoCheckOutModuleList.Count > 0 then
          begin
            UndoCheckout(UndoCheckOutModuleList, False, DummyStopRefresh, WindowHandle);
            for I := 0 to Pred(SelectedModuleList.Count) do
            begin
              CurrentItem := TListItem(SelectedModuleList[I]);
              CurrentModuleID := StrToIntDef(CurrentItem.SubItems[sitMID], 0);
              ServerProjectID := -1;
              for J := 0 to Pred(UndoCheckOutModuleList.Count) do
                if UndoCheckOutModuleList[J].ModuleID = CurrentModuleID then
                begin
                  ServerProjectID := UndoCheckOutModuleList[J].ProjectID;
                  Break;
                end;
              if ServerProjectID > 0 then
              begin
                //check module state and remove from listview if it is not longer locked
                GetRevisionListById := TJVCSGetRevisionListById.Create(nil);
                try
                  GetRevisionListById.ProjectID := ServerProjectID;
                  GetRevisionListById.ModuleID := CurrentModuleID;
                  DataModule1.ClientObjectSendRequest(GetRevisionListById);
                  CheckedOut := (GetRevisionListById.OutputItemCount > 0) and
                    (GetRevisionListById.OutputItems[Pred(GetRevisionListById.OutputItemCount)].Owner <> '');
                  if not CheckedOut then
                    CurrentItem.Delete;
                finally
                  GetRevisionListById.Free;
                end;
                if Assigned(FProjectManager) then
                  FProjectManager.RefreshSingleModule(CurrentModuleID);
              end;
            end;
          end;
        finally
          UndoCheckOutModuleList.Free;
        end;
      finally
        RestoreProjectState(CurrentProjectState);
      end;
    end;
  finally
    SelectedModuleList.Free;
  end;
end;

procedure TJVCSDockLockedModulesWindow.mnOpenFileClick(Sender: TObject);
var
  SelectedModuleID: Integer;
  SelectedModuleFileName, Mess: string;
  CurrentProjectState: TGUIClientProjectState;
  GetModuleName: TJVCSGetModuleName;
begin
  if GetSelectedModule(SelectedModuleID) then
  begin
    CurrentProjectState := SaveProjectState;
    try
      if OpenFirstModuleProject(SelectedModuleID, 1) then
      begin
        GetModuleName := TJVCSGetModuleName.Create(nil);
        try
          GetModuleName.ModuleID := SelectedModuleID;
          DataModule1.ClientObjectSendRequest(GetModuleName);
          SelectedModuleFileName := GetModuleName.ModuleName;
        finally
          GetModuleName.Free;
        end;
        ViewTheModule(WindowHandle, SelectedModuleFileName, Mess);
        BringWindowToTop(WindowHandle);
        BringWindowToTop(Self.Handle);
      end;
    finally
      RestoreProjectState(CurrentProjectState);
    end;
  end;
end;

procedure TJVCSDockLockedModulesWindow.mnLineHistoryClick(Sender: TObject);
var
  SelectedModuleID: Integer;
  SelectedModuleFileName: string;
  CurrentProjectState: TGUIClientProjectState;
  GetModuleName: TJVCSGetModuleName;
begin
  if Assigned(FProjectManager) and GetSelectedModule(SelectedModuleID) then
  begin
    CurrentProjectState := SaveProjectState;
    try
      if OpenFirstModuleProject(SelectedModuleID, 1) then
      begin
        GetModuleName := TJVCSGetModuleName.Create(nil);
        try
          GetModuleName.ModuleID := SelectedModuleID;
          DataModule1.ClientObjectSendRequest(GetModuleName);
          SelectedModuleFileName := GetModuleName.ModuleName;
        finally
          GetModuleName.Free;
        end;
        FProjectManager.ShowLineHistory(SelectedModuleFileName);
      end;
    finally
      RestoreProjectState(CurrentProjectState);
    end;
  end;
end;

procedure TJVCSDockLockedModulesWindow.elvLockedModulesDblClick(
  Sender: TObject);
var
  DblClickAction: Integer;
  SelectedModuleID: Integer;
begin
  inherited;
  if GetSelectedModule(SelectedModuleID) then
  begin
    DblClickAction :=
      jvcsReadInteger(sBaseRegistryKey + crbOptions, 'PMDoubleClick', 0);
    if (DblClickAction < 1) then
    begin
      case MessageBox(WindowHandle, PChar(JVCSRES_You_do_not_have_a_double_click_action_defined46 + #13#10 +
        JVCSRES_Would_you_like_to_do_this_now63), cMsgBoxCaption,
        MB_YESNOCANCEL or MB_ICONQUESTION) of
        id_Yes :
          begin
            VCSOptions := TVCSOptions.Create(Application);
            try
              VCSOptions.DefaultSheet := cspInterface;
              VCSOptions.ShowModal;
            finally
              VCSOptions.Free;
            end;
            //todo ? GetVCSOptions;
          end;
        else
          Exit;
      end;
    end;
    DblClickAction :=
      jvcsReadInteger(sBaseRegistryKey + crbOptions, 'PMDoubleClick', 0);
    case DblClickAction of
      1:
        mnOpenFileClick(Self);
      2:
        mnCheckInClick(Self);
      3:
        InfoMessageBox('Sorry, but the "Check Out module" action is not supported here.'); //todo acCheckOutExecute(Self);
      4:
        InfoMessageBox('Sorry, but the "Get module" action is not yet supported here.'); //todo acModInfoExecute(Self);
      5:
        mnCompareClick(Self);
      6:
        mnHistoryClick(Self);
      7:
        InfoMessageBox('Sorry, but the "Maintain labels" action is not yet supported here.'); //todo acKeyAdminExecute(Self);
      8:
        mnOpenParentFolderClick(Self);
      else
        Exit;
    end;
  end;
end;

end.
