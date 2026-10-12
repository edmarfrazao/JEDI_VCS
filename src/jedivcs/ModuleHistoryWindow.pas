(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: ModuleHistoryWindow.pas

The Initial Developer of the original code (JEDI VCS) is:
  Marco Gosselink (marcogosselink@xs4all.nl)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
ToDo
- share more code with History.pas?
-----------------------------------------------------------------------------

Unit history:

2003/06/18  MGosselink- initial release
2003/06/27  MGosselink- Added revision labels
2003/08/30  USchuster - changed JEDI-VCS to JEDI VCS in message boxes
                      - D5 fix (removed Variants from uses clause)
                      - added stateimagelist from History.pas
2003/09/01  MGosselink- If the message "WM_MODULE_CHANGED" is sent before the
                        FillListView procedure has ended an AV was shown.
                        Problem is now solved.
2003/09/10  MGosselink- Bug fixed in FillListView
2003/11/09  USchuster - exchanged TextComp call with new procedure DoModuleCompare (mantis #1204)
2003/11/23  USchuster - cleanup -> uses now interfaces for communication with projectmanager
2003/11/30  USchuster - replaced server function calls with ClientObjects
2004/01/11  USchuster - refresh is now done in a separate thread
                      - fixed column loading
2004/01/25  USchuster - secured popupmenu calls against AV when no item is selected in listview
                      - minor fix in listview filling (threadversion) -> show full
                        revision information only for first member
                      - popupmenu functions "Comments" and "Assign Labels" can now be used
                        with every revision member
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/26  USchuster - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
                      - removed THREADREFRESH directive and matching code
2004/11/02  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
2005/01/24  CSchuette - #2545 - added BeginUpdate/EndUpdate around .Clear call for
                        ListView. This makes it faster with XP themes.
2005/03/05  USchuster - use TJVCSDockableForm.HandleThreadException to ignore
                        appserver result 403 in the thread (mantis #2714)
2005/03/17  USchuster - changes to open the "Get Module" dialog with the selected
                        revision (mantis #2769)
2005/04/25  CSchuette - added call to "ResolveFileFamilies" to fix mantis #1205
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC3 was released ^^^^^^^^^^^^^^^^^^^^^
2006/01/09  USchuster - moved some code to JVCSHistoryCommon.pas (for mantis #3416)
                        and fixed AV in "Get Module" function
2006/12/10  USchuster - changes for menu bitmaps
2008/03/15  USchuster - added "Line History" menu item to the popup menu
2008/06/08  USchuster - fixed memory leak (Mantis #3082)
2008/11/15  USchuster - changes for TRevisionLabelStrs
2011/01/15  USchuster - changed font to Tahoma
2012/07/08  AKroeber   - call external bugtracker (via regex from checkin comment)

-----------------------------------------------------------------------------*)

unit ModuleHistoryWindow;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, JVCSDockForm, EnhListView, Menus, ImgList, JVCSInterfaces,
  JVCSThreads;

type
  TVCSModuleHistoryWindow = class(TJVCSDockableForm, IJVCSRefresh)
    lvHistory: TListView;
    PopupMenu1: TPopupMenu;
    GetModule1: TMenuItem;
    Compare1: TMenuItem;
    N1: TMenuItem;
    Comments1: TMenuItem;
    ChangeDescription2: TMenuItem;
    N2: TMenuItem;
    AssignLabels1: TMenuItem;
    StateImageList: TImageList;
    mnLineHistory: TMenuItem;
    BugtrackerSep: TMenuItem;
    BugtrackerItem: TMenuItem;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GetModule1Click(Sender: TObject);
    procedure Compare1Click(Sender: TObject);
    procedure Comments1Click(Sender: TObject);
    procedure ChangeDescription2Click(Sender: TObject);
    procedure AssignLabels1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure mnLineHistoryClick(Sender: TObject);
    procedure BugtrackerItemClick(Sender: TObject);
  private
    { Private declarations }
    FIsFilling: Boolean;
    FProjectManager: IJVCSProjectManager;
    FInternalThread: TJVCSJobThread;
    FVCLSyncAction: Integer;
    FModuleHistoryItems: TList;
    FCurrentRevisionLabels: string;
    FCurrentItemNr: Integer;
    procedure SetControlState(AEnabled: Boolean);
    procedure ThreadFillListView(AThreadJob: TJVCSThreadJob);
    procedure ThreadSetControlState(AThreadJob: TJVCSThreadJob);
    procedure VCLThreadSyncProc;
    procedure ClearModuleHistoryItems;
  public
    { Public declarations }
    procedure SimpleRefresh(ARefreshType: TJVCSRefreshType);
    property ProjectManager: IJVCSProjectManager read FProjectManager write FProjectManager;
  end;

var
  VCSModuleHistoryWindow: TVCSModuleHistoryWindow;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  DBModule, VCSBase, VCSProcBase, TZHandling, ConfigStorage, ModuleInfo,
  Textcomp, ListView, Description, JVCSDialogs, Checksum, AssignLabels, ExtBugtracker,
  JVCSClientObj, JVCSGUIClientResources, JVCSHistoryCommon, JVCSGUIClientImages;

{$R *.dfm}

const
  cSyncActionClearListView = 1;
  cSyncActionFillListView = 2;
  cSyncActionAddRevisionLabel = 3;
  cSyncActionSetControlStateFalse = 4;
  cSyncActionSetControlStateOnDepend = 5;

procedure TVCSModuleHistoryWindow.ThreadFillListView(AThreadJob: TJVCSThreadJob);
var
  ModuleID: Integer;
  I: Integer;
  ModuleHistory: TJVCSGetModuleHistory;
  LastVersion, LastRevision: Integer;
  ModuleHistoryItemPtr: PGetModuleHistoryOutputItem;
  RevisionLabelStrs: TRevisionLabelStrs;
begin
  if not FIsFilling then
  begin
    FIsFilling := True;
    try
      FVCLSyncAction := cSyncActionClearListView;
      AThreadJob.Sync(VCLThreadSyncProc);
      if (Integer(AThreadJob.Parameter) = cSyncActionFillListView) and
        (ServerUserID > 0) and Assigned(FProjectManager) then
      begin
        ModuleID := FProjectManager.GetSelectedModuleID;
        if ModuleID > 0 then
        begin
          ModuleHistory := TJVCSGetModuleHistory.Create(nil);
          try
            ModuleHistory.ModuleID := ModuleID;
            DataModule1.ClientObjectSendRequest(ModuleHistory);

            ClearModuleHistoryItems;
            for I := 0 to Pred(ModuleHistory.OutputItemCount) do
            begin
              New(ModuleHistoryItemPtr);
              ModuleHistoryItemPtr^ := ModuleHistory.OutputItems[I];
              FModuleHistoryItems.Add(ModuleHistoryItemPtr);
            end;

          finally
            ModuleHistory.Free;
          end;

          if not AThreadJob.Aborted then
          begin
            FVCLSyncAction := cSyncActionFillListView;
            AThreadJob.Sync(VCLThreadSyncProc);
          end;

          if FModuleHistoryItems.Count > 0 then
          begin
            LastVersion := -1;
            LastRevision := -1;
            RevisionLabelStrs := TRevisionLabelStrs.Create(ModuleID);
            try
              for I := 0 to Pred(FModuleHistoryItems.Count) do
                if not AThreadJob.Aborted then
                begin
                  ModuleHistoryItemPtr := FModuleHistoryItems[I];
                  if (LastVersion <> ModuleHistoryItemPtr^.Version) or
                    (LastRevision <> ModuleHistoryItemPtr^.Revision) then
                  begin
                    FCurrentRevisionLabels := RevisionLabelStrs.GetRevisionLabelsStr(ModuleHistoryItemPtr^.RevisionID);
                    FCurrentItemNr := I;
                    FVCLSyncAction := cSyncActionAddRevisionLabel;
                    if not AThreadJob.Aborted then
                      AThreadJob.Sync(VCLThreadSyncProc);
                  end;
                  LastVersion := ModuleHistoryItemPtr^.Version;
                  LastRevision := ModuleHistoryItemPtr^.Revision;
                end;
            finally
              RevisionLabelStrs.Free;
            end;
          end;

          ClearModuleHistoryItems;
        end; //if ModuleID > 0 then
      end; //if (Integer(AThreadJob.Parameter) = cSyncActionFillListView) and (ServerUserID > 0) and Assigned(FProjectManager) then
    finally
      FIsFilling := False;
    end;
  end;
end;

procedure TVCSModuleHistoryWindow.ThreadSetControlState(AThreadJob: TJVCSThreadJob);
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

procedure TVCSModuleHistoryWindow.VCLThreadSyncProc;
var
  LVItem: TListItem;
  I: Integer;
  CheckedOut: Boolean;
  LastVersion, LastRevision: Integer;
  FCurrentModuleHistoryItem: TGetModuleHistoryOutputItem;
begin
  if FVCLSyncAction = cSyncActionClearListView then
  begin
    lvHistory.Items.BeginUpdate;
    try
      lvHistory.Items.Clear
    finally
      lvHistory.Items.EndUpdate;
    end;
  end
  else
  if FVCLSyncAction = cSyncActionFillListView then
  begin
    LastVersion := -1;
    LastRevision := -1;
    lvHistory.Items.BeginUpdate;
    try
      lvHistory.Items.Clear;
      CheckedOut := False;
      for I := 0 to Pred(FModuleHistoryItems.Count) do
      begin
        FCurrentModuleHistoryItem := PGetModuleHistoryOutputItem(FModuleHistoryItems[I])^;
        if (LastVersion <> FCurrentModuleHistoryItem.Version) or
          (LastRevision <> FCurrentModuleHistoryItem.Revision) then
        begin
          CheckedOut := FCurrentModuleHistoryItem.CheckedOut;

          LVItem := lvHistory.Items.Add;
          // Ver/Rev
          LVItem.Caption := Format('%d.%d', [FCurrentModuleHistoryItem.Version,
            FCurrentModuleHistoryItem.Revision]);
          // by User
          LVItem.SubItems.Add(FCurrentModuleHistoryItem.UserName);
          // Member
          LVItem.SubItems.Add(FCurrentModuleHistoryItem.Extension);
          // Time
          LVItem.SubItems.Add(DateTimeToStr(GMTDT2LocalDT(FCurrentModuleHistoryItem.Timestamp)));
          // Size
          LVItem.SubItems.Add(FormatFloat('#,', FCurrentModuleHistoryItem.Size));
          // Comment I
          LVItem.SubItems.Add(RemoveCRLF(FCurrentModuleHistoryItem.CheckinComment));
          // Comment O
          LVItem.SubItems.Add(RemoveCRLF(FCurrentModuleHistoryItem.CheckoutComment));
          // Rev. ID
          LVItem.SubItems.Add(IntToStr(FCurrentModuleHistoryItem.RevisionID));
        end
        else
        begin
          LVItem := lvHistory.Items.Add;
          // Ver/Rev
          LVItem.Caption := '';
          // by User
          LVItem.SubItems.Add('');
          // Member
          LVItem.SubItems.Add(FCurrentModuleHistoryItem.Extension);
          // Time
          LVItem.SubItems.Add(DateTimeToStr(GMTDT2LocalDT(FCurrentModuleHistoryItem.Timestamp)));
          // Size
          LVItem.SubItems.Add(FormatFloat('#,', FCurrentModuleHistoryItem.Size));
          // Comment I
          LVItem.SubItems.Add('');
          // Comment O
          LVItem.SubItems.Add('');
          // Rev. ID
          LVItem.SubItems.Add(IntToStr(FCurrentModuleHistoryItem.RevisionID));
        end;
        LastVersion := FCurrentModuleHistoryItem.Version;
        LastRevision := FCurrentModuleHistoryItem.Revision;
      end;
      if CheckedOut then
        lvHistory.Items[lvHistory.Items.Count - 1].StateIndex := 1;
      { scroll to the latest entry, because in most cases the user would like
        to see the lastest comments instead of the oldest }
      if lvHistory.Items.Count > 0 then
        lvHistory.Items[lvHistory.Items.Count - 1].MakeVisible(False);
    finally
      lvHistory.Items.EndUpdate;
    end;
  end
  else
  if FVCLSyncAction = cSyncActionAddRevisionLabel then
    lvHistory.Items[FCurrentItemNr].SubItems.Add(FCurrentRevisionLabels)
  else
  if FVCLSyncAction = cSyncActionSetControlStateFalse then
    SetControlState(False)
  else
  if FVCLSyncAction = cSyncActionSetControlStateOnDepend then
    SetControlState((lvHistory.Items.Count > 0) and (ServerUserID > 0));
end;

procedure TVCSModuleHistoryWindow.ClearModuleHistoryItems;
var
  I: Integer;
begin
  for I := 0 to Pred(FModuleHistoryItems.Count) do
    Dispose(PGetModuleHistoryOutputItem(FModuleHistoryItems[I]));
  FModuleHistoryItems.Clear;
end;


procedure TVCSModuleHistoryWindow.FormDestroy(Sender: TObject);
var
  I: Integer;
begin
  inherited;

  with lvHistory do
    for I := 0 to Columns.Count -1 do
      jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ModuleHistoryWin_Col1.' + IntToStr(I),
        Columns[I].Width);
  ClearModuleHistoryItems;
  FModuleHistoryItems.Free;
  FInternalThread.Free;
end;

procedure TVCSModuleHistoryWindow.FormCreate(Sender: TObject);
const
  ColumnWidthArray: array [0..8] of Integer = (60, 60, 50, 75, 70, 150, 150, 0, 150);
var
  I: Integer;
begin
  try
    inherited;
    with lvHistory do
      for I := 0 to Columns.Count -1 do
        if I <= High(ColumnWidthArray) then
          Columns[I].Width :=
            jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ModuleHistoryWin_Col1.' + IntToStr(I), ColumnWidthArray[I]);
    FIsFilling := False;
    FProjectManager := nil;
    FInternalThread := TJVCSJobThread.Create(False);
    FInternalThread.OnJobException := HandleThreadException;    
    FModuleHistoryItems := TList.Create;
    if ShowMenuBitmaps then
      PopupMenu1.Images := GetToolImageList;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

procedure TVCSModuleHistoryWindow.GetModule1Click(Sender: TObject);
var
  ModuleID: Integer;
begin
  inherited;

  if Assigned(FProjectManager) then
  begin
    ModuleID := FProjectManager.GetSelectedModuleID;
    if ModuleID > 0 then
    begin
      VCSInfo := TVCSInfo.Create(Application);
      try
        VCSInfo.ModuleID := ModuleID;
        VCSInfo.GetEnabled := True;
        if Assigned(lvHistory.Selected) then
          VCSInfo.SelectedRevisionID := StrToIntDef(lvHistory.Selected.SubItems[6], 0);
        VCSInfo.ShowModal;
      finally
        VCSInfo.Free;
      end;
    end;
  end;
end;

procedure TVCSModuleHistoryWindow.Compare1Click(Sender: TObject);
var
  RevisionKey, CompareFile: string;
begin
  inherited;

  if Assigned(FProjectManager) and Assigned(lvHistory.Selected) then
  begin
    CompareFile := FProjectManager.GetSelectedModuleName;
    if CompareFile <> '' then
    begin
      ResolveFileFamilies(CompareFile);
      RevisionKey := lvHistory.Selected.SubItems[6];
      DoModuleCompare(CompareFile, lvHistory.Selected.SubItems[1],
        StrToIntDef(RevisionKey, 0));
    end;
  end;
end;

procedure TVCSModuleHistoryWindow.Comments1Click(Sender: TObject);
var
  ResultStr: string;
  ModuleName: string;
  FirstRevisionListItem: TListItem;
begin
  inherited;

  if Assigned(FProjectManager) and Assigned(lvHistory.Selected) then
  begin
    FirstRevisionListItem := GetFirstRevisionItemFromHistoryListView(lvHistory, lvHistory.Selected);
    
    ModuleName := FProjectManager.GetSelectedModuleName;
    if ModuleName <> '' then
    begin
      ResultStr := JVCSRES_Check_in_comment58 + ';' +
        FirstRevisionListItem.SubItems[4] + ';;' +
        JVCSRES_Check_out_comment58 + ';' +
        FirstRevisionListItem.SubItems[5] + ';';
      VCSListView := TVCSListView.Create(Application);
      try
        VCSListView.Caption := Format(JVCSRES_Comments_for_version_37s, [ExtractFileName(ModuleName)]);
        VCSListView.Left := Left + 60;
        VCSListView.Top := Top + 60;
        VCSListView.EnableWordWrap(True);
        VCSListView.SetUpListView(ResultStr);
        VCSListView.ShowModal;
      finally
        VCSListView.Free;
        VCSListView := nil;
      end;
    end;
  end;
end;

procedure TVCSModuleHistoryWindow.BugtrackerItemClick(Sender: TObject);
begin
  OpenExternalBugtracker;
end;

procedure TVCSModuleHistoryWindow.ChangeDescription2Click(Sender: TObject);
var
  ModuleID: Integer;
  ModuleCaption, Description: string;
  GetUpdateDescription: TJVCSGetUpdateDescription;
begin
  inherited;

  if Assigned(FProjectManager) then
  begin
    ModuleID := FProjectManager.GetSelectedModuleID;
    if ModuleID > 0 then
    begin
      ModuleCaption := ExtractFileName(FProjectManager.GetSelectedModuleName);

      GetUpdateDescription := TJVCSGetUpdateDescription.Create(nil);
      try
        GetUpdateDescription.ItemType := 2;
        GetUpdateDescription.ItemID := ModuleID;
        GetUpdateDescription.Update := False;
        GetUpdateDescription.UpdateDescription := '';
        DataModule1.ClientObjectSendRequest(GetUpdateDescription);

        Description := GetUpdateDescription.Description;
      finally
        GetUpdateDescription.Free;
      end;

      VCSDescription := TVCSDescription.Create(Application);
      try
        VCSDescription.Top := Top + 60;
        VCSDescription.Left := Left + 60;
        VCSDescription.DescType := 2;
        VCSDescription.SetDescripCaption(Format(JVCSRES_38Module58_37s, [ModuleCaption]));
        VCSDescription.SetDescription(Description);
        VCSDescription.EnableCheckBox(False);
        VCSDescription.ShowModal;
        Description := VCSDescription.Description;
      finally
        VCSDescription.Free;
      end;

      if Description <> '' then
      begin
        GetUpdateDescription := TJVCSGetUpdateDescription.Create(nil);
        try
          GetUpdateDescription.ItemType := 2;
          GetUpdateDescription.ItemID := ModuleID;
          GetUpdateDescription.Update := True;
          GetUpdateDescription.UpdateDescription := Description;
          DataModule1.ClientObjectSendRequest(GetUpdateDescription);
        finally
          GetUpdateDescription.Free;
        end;
      end; //if Description <> '' then
    end; //if ModuleID > 0 then
  end; //if Assigned(FProjectManager) then
end;

procedure TVCSModuleHistoryWindow.AssignLabels1Click(Sender: TObject);
var
  ModuleName: string;
  ModuleID: Integer;
  Revision, RevisionID: string;
  FirstRevisionListItem: TListItem;
begin
  inherited;

  if Assigned(FProjectManager) and Assigned(lvHistory.Selected) and
    (lvHistory.Selected.SubItems.Count >= 7)
  then
  begin
    FirstRevisionListItem := GetFirstRevisionItemFromHistoryListView(lvHistory, lvHistory.Selected);

    ModuleName := FProjectManager.GetSelectedModuleName;
    ModuleID := FProjectManager.GetSelectedModuleID;
    RevisionID := FirstRevisionListItem.SubItems[6];
    Revision := FirstRevisionListItem.Caption;

    if (ModuleID > 0) and (StrToIntDef(RevisionID, 0) > 0) then
    begin
      VCSAssignLabels := TVCSAssignLabels.Create(Application);
      try
        VCSAssignLabels.Left := Left + 40;
        VCSAssignLabels.Top := Top + 40;
        VCSAssignLabels.RevisionID := RevisionID;
        VCSAssignLabels.ModuleID := IntToStr(ModuleID);
        VCSAssignLabels.ModuleName := ExtractFileName(ModuleName) + ' V' + Revision;
        VCSAssignLabels.ShowModal;
      finally
        VCSAssignLabels.Free;
      end;
    end;
    FInternalThread.DisqueueAndAbortAllJobsAndWait;
    FInternalThread.AddJob(ThreadFillListView,
      Pointer(cSyncActionFillListView));
  end; //if Assigned(FProjectManager) and ...
end;

procedure TVCSModuleHistoryWindow.SimpleRefresh(ARefreshType: TJVCSRefreshType);
begin
  case ARefreshType of
    rtConnected, rtRefresh, rtSelectedModuleChanged:
    begin
      FInternalThread.DisqueueAndAbortAllJobsAndWait;
      FInternalThread.AddJob(ThreadSetControlState,
        Pointer(cSyncActionSetControlStateFalse));
      FInternalThread.AddJob(ThreadFillListView,
        Pointer(cSyncActionFillListView));
      FInternalThread.AddJob(ThreadSetControlState,
        Pointer(cSyncActionSetControlStateOnDepend));
    end;
    rtDisconnected, rtProjectClosing:
    begin
      FInternalThread.DisqueueAndAbortAllJobsAndWait;
      FInternalThread.AddJob(ThreadSetControlState,
        Pointer(cSyncActionSetControlStateFalse));
      FInternalThread.AddJob(ThreadFillListView,
        Pointer(cSyncActionClearListView));
    end;
    {
    rtSelectedModuleChanged:
    begin
      SetControlState(False);
      if lvHistory.Visible and not FIsFilling then
        FillListView;
      SetControlState((lvHistory.Items.Count > 0) and (ServerUserID > 0));
    end;
    }
  end;
end;

procedure TVCSModuleHistoryWindow.SetControlState(AEnabled: Boolean);
begin
  GetModule1.Enabled := AEnabled;
  Compare1.Enabled := AEnabled;
  Comments1.Enabled := AEnabled;
  ChangeDescription2.Enabled := AEnabled;
  AssignLabels1.Enabled := AEnabled;
end;

procedure TVCSModuleHistoryWindow.FormShow(Sender: TObject);
begin
  inherited;
  SimpleRefresh(rtRefresh);
end;

procedure TVCSModuleHistoryWindow.PopupMenu1Popup(Sender: TObject);
var
  HasItemsAndServerOkay, ItemSelected: Boolean;
begin
  inherited;
  HasItemsAndServerOkay := (lvHistory.Items.Count > 0) and (ServerUserID > 0);
  ItemSelected := Assigned(lvHistory.Selected);

  GetModule1.Enabled := HasItemsAndServerOkay;
  Compare1.Enabled := HasItemsAndServerOkay and ItemSelected;
  mnLineHistory.Enabled := HasItemsAndServerOkay and Assigned(FProjectManager);
  Comments1.Enabled := HasItemsAndServerOkay and ItemSelected;
  ChangeDescription2.Enabled := HasItemsAndServerOkay;
  AssignLabels1.Enabled := HasItemsAndServerOkay and ItemSelected;

  CheckCommentForExternalBugtrackerReference(lvHistory.Selected, BugtrackerItem, BugtrackerSep)
end;

procedure TVCSModuleHistoryWindow.mnLineHistoryClick(Sender: TObject);
var
  CompareFile, ModuleExtension: string;
begin
  inherited;
  if Assigned(FProjectManager) then
  begin
    CompareFile := FProjectManager.GetSelectedModuleName;
    if CompareFile <> '' then
    begin
      ModuleExtension := '';
      if Assigned(lvHistory.Selected) then
        ModuleExtension := lvHistory.Selected.SubItems[1];
      FProjectManager.ShowLineHistory(CompareFile, ModuleExtension);
    end;
  end;
end;

end.
