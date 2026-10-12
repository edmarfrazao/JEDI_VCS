(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: SelectProjectID.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS: Thomas Huber (Thomas_D_Huber@gmx.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FreeVCS code to JEDI VCS
2003/02/14  USchuster - Bugfix: the user of last write access should now be shown correct
2003/02/20  USchuster - fixed mantis bug #726
2003/03/05  THensle   - changes for "ConfigStorage" unit
2003/03/08  USchuster - exchanged THistoryList with TJVCSMruList (mantis #727)
2003/10/22  USchuster - omit deleted projects in group hierarchy (mantis #1181)
                      - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use new constant)
2003/11/10  THuber    - #1218: Adding multiple projects to projectgroup, added
                        shortcuts ctrl-ins, ctrl-del for adding/deleting projects
                        from projectgroups.
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/17  USchuster - style cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/10/31  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
2004/12/29  USchuster - changes to suppress projects without at least
                        read only access (mantis #2254)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC3 was released ^^^^^^^^^^^^^^^^^^^^^^^^^^^
2005/12/31  USchuster - added menu item "Hide projects without any rights" and
                        project groups will be tried to load with guest accounts as well (mantis #3193)
2007/06/04  USchuster - improved treeview performance (mantis #4072)
2007/06/05  USchuster - readded lost DefaultID handling (got lost due last improvement)
2007/06/17  USchuster - fixed self handled shortcuts
2007/06/29  USchuster - changes for large fonts (set AutoScroll to False and changed contraints; Mantis #1034)                        
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit SelectProjectID;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, Buttons, Menus, JVCSMruList, ImgList, JVCSDataClasses,
  JVCSProjectTreeUnit, JVCSForms;

type
  TVCSSelectProject = class(TJVCSForm)
    PopupMenu1: TPopupMenu;
    Description1: TMenuItem;
    PageControl1: TPageControl;
    SheetArchive: TTabSheet;
    SheetRecent: TTabSheet;
    lvArchive: TListView;
    lvRecent: TListView;
    Splitter1: TSplitter;
    Panel2: TPanel;
    ProjectDescription: TMemo;
    Panel3: TPanel;
    StateImageList: TImageList;
    edProjectInfo: TEdit;
    SheetHierarchy: TTabSheet;
    tvHierachy: TTreeView;
    PopupMenu2: TPopupMenu;
    CreatenewCategory1: TMenuItem;
    CreatenewSubCategory1: TMenuItem;
    RemoveCategory1: TMenuItem;
    AddProject1: TMenuItem;
    RemoveProject1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    HierachyImageList: TImageList;
    RenameProjectGroup1: TMenuItem;
    N3: TMenuItem;
    FullExpand1: TMenuItem;
    Collapse1: TMenuItem;
    ProjectDescription1: TMenuItem;
    N4: TMenuItem;
    BugTracking1: TMenuItem;
    BugTracking2: TMenuItem;
    ImportDelphiProjectGroup1: TMenuItem;
    N5: TMenuItem;
    Panel1: TPanel;
    Help: TSpeedButton;
    spBtnGetLDescr: TSpeedButton;
    spBtnDescription: TSpeedButton;
    btnCancel: TButton;
    btnOK: TButton;
    cbShowDescr: TCheckBox;
    N6: TMenuItem;
    ExportSMTPProjectList1: TMenuItem;
    cbAutoOpen: TCheckBox;
    N7: TMenuItem;
    mnHideprojectswithoutanyrights: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure lvArchiveChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure HelpClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure spBtnGetLDescrClick(Sender: TObject);
    procedure spBtnDescriptionClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cbShowDescrClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure CreatenewCategory1Click(Sender: TObject);
    procedure CreatenewSubCategory1Click(Sender: TObject);
    procedure RemoveCategory1Click(Sender: TObject);
    procedure AddProject1Click(Sender: TObject);
    procedure RemoveProject1Click(Sender: TObject);
    {procedure test1Click(Sender: TObject);}
    procedure PopupMenu2Popup(Sender: TObject);
    procedure tvHierachyChange(Sender: TObject; Node: TTreeNode);
    procedure RenameProjectGroup1Click(Sender: TObject);
    procedure FullExpand1Click(Sender: TObject);
    procedure Collapse1Click(Sender: TObject);
    procedure BugTracking1Click(Sender: TObject);
    procedure ImportDelphiProjectGroup1Click(Sender: TObject);
    procedure lvArchiveChanging(Sender: TObject; Item: TListItem;
      Change: TItemChange; var AllowChange: Boolean);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure ExportSMTPProjectList1Click(Sender: TObject);
    procedure mnHideprojectswithoutanyrightsClick(Sender: TObject);
    procedure tvHierachyMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    FCreating,
    ChangeInProgress,
    GroupsAvailable,
    UnAssgndCreated: Boolean;
    DescrPanelHeight: Integer;
    RecentProjectList: TJVCSMruList;
    FAccessLevel: Integer;
    FProjectTreeContainer: TProjectTreeContainer;
    FTreeUpdateCount: Integer;
    procedure BeginTreeUpdate;
    procedure EndTreeUpdate;
    function GetDefaultAccessLevel: Integer;
    procedure SelectProject;
    function GetDescription(const ID: string): string;
    function GetInfo(const ID: string): string;
    procedure UpdateProjectInfo;
    procedure ShowDescrMemo(const ShowWin: Boolean);
    procedure ReadTree;
    function AddProjectGroup(const ParentID, GroupLevel,
      Flags: Integer; const GroupName, GroupDescription: string): Integer;
  public
    { Public declarations }
    HierarchyOnly: Boolean;
    DefaultID,
    SelectedID: Integer;
    SelectedName: string;
    procedure SetDlgCaption(const Value: string);
  end;

var
  VCSSelectProject: TVCSSelectProject;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  Progress, VCSBase, VCSProcBase, DBModule, LoadModule, Description,
  AddNewGroup, SelectList, AssignBugs, FavOpenDialog, ParsePG, TZHandling,
  ConfigStorage, JclStrings, JVCSGUIClientResources, JVCSClientObj, JVCSClasses;

{$R *.dfm}

procedure TVCSSelectProject.FormCreate(Sender: TObject);
var
  DlgWidth, DlgHeight: Integer;
begin
  try
    Constraints.MinHeight := Height;
    Constraints.MinWidth := Width;
    FCreating := True;
    GroupsAvailable := False;
    UnAssgndCreated := False;
    HierarchyOnly := False;
    SelectedID := 0;
    SelectedName := '';
    FAccessLevel := -1;
    FTreeUpdateCount := 0;
    FProjectTreeContainer := TProjectTreeContainer.Create;

    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    if not jvcsReadWindowSize(sBaseRegistryKey + crbWindows, 'SelectProjectID',
      DlgWidth, DlgHeight) then
    begin
      DlgWidth := MulDiv(365, PixelsPerInch, 96);
      DlgHeight := MulDiv(310, PixelsPerInch, 96);
    end;
    Width := DlgWidth;
    Height := DlgHeight;

    case jvcsReadInteger(sBaseRegistryKey + crbWindows, 'SelectProjectID_Tab', 0) of
      0:
        PageControl1.ActivePage := SheetArchive;
      1:
        PageControl1.ActivePage := SheetHierarchy;
      2:
        PageControl1.ActivePage := SheetRecent;
      else
        PageControl1.ActivePage := SheetArchive;
    end;

    DescrPanelHeight :=
      jvcsReadInteger(sBaseRegistryKey + crbWindows, 'SelectProjectID_Pn1', MulDiv(120, PixelsPerInch, 96));

    cbAutoOpen.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbWindows, 'SelectProjectID_AutoOpen', False);

    cbShowDescr.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbWindows, 'SelectProjectID_ShowDescr', False);

    mnHideprojectswithoutanyrights.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbWindows, 'SelectProjectID_HideProjectsWithoutRights', True);

    {$IFNDEF SHOWIDS}
    lvArchive.Columns[1].Width := 0;
    lvRecent.Columns[1].Width := 0;
    {$ENDIF ~SHOWIDS}
    {$IFDEF IDEDLL}
    cbAutoOpen.Visible := False;
    cbShowDescr.Top := 12;
    {$ENDIF IDEDLL}
    RecentProjectList := TJVCSMruList.Create;
    Screen.Cursors[cPopUpMCursor] := LoadCursor(hInstance, PChar('CURSORRM'));
    tvHierachy.Cursor := cPopUpMCursor;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectProject.FormShow(Sender: TObject);
begin
  if HierarchyOnly then
  begin
    SheetArchive.TabVisible := False;
    SheetRecent.TabVisible := False;
    SheetHierarchy.Caption := JVCSRES_Hierarchy;
    PageControl1.ActivePage := SheetHierarchy;
    btnOK.Visible := False;
    spBtnDescription.Left := spBtnDescription.Left + 90;
    spBtnGetLDescr.Left := spBtnGetLDescr.Left + 90;
    btnCancel.Caption := JVCSRES_38Done;
    btnCancel.Default := True;
    tvHierachy.SetFocus;
    cbAutoOpen.Visible := False;
    cbShowDescr.Top := 12;
  end;
  ShowDescrMemo(cbShowDescr.Checked);
  ImportDelphiProjectGroup1.Caption := Format(JVCSRES_38Import_37s_Project_Group464646, [sIDEName]);
end;

//------------------------------------------------------------------------------

procedure TVCSSelectProject.SetDlgCaption(const Value: string);
begin
  if HierarchyOnly then
    Caption := JVCSRES_Project_Hierarchy
  else
    Caption := Format(JVCSRES_Select_a_Project_4037s41, [Value]);
end;

//------------------------------------------------------------------------------

procedure TVCSSelectProject.FormActivate(Sender: TObject);
begin
  Application.ProcessMessages;
  if FCreating then
  begin
    SelectProject;
    if PageControl1.ActivePage = SheetHierarchy then
    begin
      if not GroupsAvailable then 
        ReadTree;
      btnOK.Enabled := (tvHierachy.Selected <> nil) and
        Assigned(tvHierachy.Selected.Data) and (TObject(tvHierachy.Selected.Data) is TProjectTreeProject);
      spBtnDescription.Enabled := btnOK.Enabled;
    end;
    FCreating := False;
  end; // if FCreating then begin
end;

//------------------------------------------------------------------------------

procedure TVCSSelectProject.btnOKClick(Sender: TObject);
var 
  GrantedRight: Integer;
  CurrentLV: TListView;
  ProjectData: TProjectTreeProjectData;
begin
  if FCreating or ChangeInProgress then
    Exit;

  if PageControl1.ActivePage = SheetHierarchy then
  begin
    if (tvHierachy.Selected = nil) or (not Assigned(tvHierachy.Selected.Data)) or
      (not (TObject(tvHierachy.Selected.Data) is TProjectTreeProject)) then
      Exit;
    ProjectData := TProjectTreeProject(tvHierachy.Selected.Data).ProjectData;
    SelectedID := ProjectData.ProjectID;
    SelectedName := ProjectData.ProjectName;
  end // if PageControl1.ActivePage = SheetHierarchy then begin
  else 
  begin
    if PageControl1.ActivePage = SheetArchive then
      CurrentLV := lvArchive
    else
      CurrentLV := lvRecent;

    if CurrentLV.Selected = nil then 
      Exit;
    SelectedID := _StrToInt(CurrentLV.Selected.SubItems[0]);
    SelectedName := CurrentLV.Selected.Caption;
  end; // else if PageControl1.ActivePage = SheetHierarchy then begin

  RecentProjectList.AddString(SelectedName);
  RecentProjectList.SaveToStorage(sBaseRegistryKey + crbMRU + '22');

  GrantedRight := 0;
  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_PROJECT_RIGHT';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [SelectedID]);
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
      BeepIfSet;
      MessageBox(Handle, PChar(AppSrvClient1.Answer.Fields[0]), cMsgBoxCaption,
        MB_OK or MB_ICONSTOP);
      Exit;
    end;

    AppSrvClient1.Answer.First;
    if not AppSrvClient1.Answer.Eof then
      GrantedRight := _StrToInt(AppSrvClient1.Answer.Fields[0])
  end; // with DataModule1 do begin
  if GrantedRight < 1 then 
  begin
    BeepIfSet;
    MessageBox(Handle, PChar(Format(JVCSRES_Access_denied46_4037s41 + #13#10 +
      JVCSRES_Project_6037s62_is_not_enabled_for_your_account46 + #13#10 +
      JVCSRES_Please_contact_the_archive_administrator_for_more_information46,
      ['403', SelectedName])),
      PChar(JVCSRES_JEDI_VCS_Application_Server), MB_OK or MB_ICONWARNING); 
    SelectedID := 0;
    SelectedName := '';
    Exit;
  end;

  {$IFDEF IDEDLL}
  jvcsWriteString(sBaseRegistryKey + crbMRU, 'LastIDEProject', SelectedName);
  {$ELSE}
  jvcsWriteString(sBaseRegistryKey + crbMRU, 'LastSTDProject', SelectedName);
  {$ENDIF IDEDLL}
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectProject.btnCancelClick(Sender: TObject);
begin
  SelectedID := 0;
  SelectedName := '';
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectProject.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  jvcsWriteWindowSize(sBaseRegistryKey + crbWindows, 'SelectProjectID',
    Width, Height);

  if not HierarchyOnly then
  begin
    if PageControl1.ActivePage = SheetArchive then
      jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'SelectProjectID_Tab', 0);
    if PageControl1.ActivePage = SheetHierarchy then
      jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'SelectProjectID_Tab', 1);
    if PageControl1.ActivePage = SheetRecent then
      jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'SelectProjectID_Tab', 2);
  end;

  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'SelectProjectID_AutoOpen',
    cbAutoOpen.Checked);
  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'SelectProjectID_ShowDescr',
    cbShowDescr.Checked);

  if cbShowDescr.Checked then
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'SelectProjectID_Pn1', Panel2.Height);

  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'SelectProjectID_HideProjectsWithoutRights',
    mnHideprojectswithoutanyrights.Checked);
end;

//------------------------------------------------------------------------------

procedure TVCSSelectProject.SelectProject;
var
  LVItem: TListItem;
  I, J: Integer;
  BugIndex, CurrentProject: string;
  ProjectBugs: TStringList;
  ProjectList: TProjects;
  DefaultAccessLevel: Integer;
begin
  ProjectBugs := TStringList.Create;
  try
    with DataModule1 do
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_MOST_SEVERE_BUGS';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [False]); // Module based?
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
      while not AppSrvClient1.Answer.Eof do
      begin
        ProjectBugs.Add(AppSrvClient1.Answer.Fields[0] + '=' +
          AppSrvClient1.Answer.Fields[2]);
        AppSrvClient1.Answer.Next;
      end;

      lvArchive.Items.BeginUpdate;
      lvArchive.Items.Clear;
      ProjectList := TProjects.Create;
      try
        DefaultAccessLevel := GetDefaultAccessLevel;
        if (not mnHideprojectswithoutanyrights.Checked) and (DefaultAccessLevel = 0) then
          DefaultAccessLevel := 1;
        ProjectList.Load(DefaultAccessLevel);
        for I := 0 to Pred(ProjectList.ItemCount) do
        begin
          LVItem := lvArchive.Items.Add;
          LVItem.Caption := ProjectList[I].Name;
          LVItem.SubItems.Add(IntToStr(ProjectList[I].ID));
          BugIndex := ProjectBugs.Values[IntToStr(ProjectList[I].ID)];
          if BugIndex <> '' then
            LVItem.StateIndex := _StrToInt(BugIndex)
          else
            LVItem.StateIndex := -1;
        end;
      finally
        ProjectList.Free;
      end;
      if DefaultID <> 0 then
      begin
        for I := 0 to lvArchive.Items.Count - 1 do
          if _StrToInt(lvArchive.Items[I].SubItems[0]) = DefaultID then
            lvArchive.Items[I].Selected := True;
      end; // if DefaultID <> 0 then begin
      lvArchive.Items.EndUpdate;
    end; // with DataModule1 do begin
  finally
    ProjectBugs.Free;
  end;

  RecentProjectList.MaxSize := 10;
  RecentProjectList.LoadFromStorage(sBaseRegistryKey + crbMRU + '22');
  for I := 0 to RecentProjectList.Count - 1 do 
  begin
    CurrentProject := RecentProjectList.Strings[I];
    for J := 0 to lvArchive.Items.Count - 1 do 
    begin
      if LowerCase(CurrentProject) = lvArchive.Items[J].Caption then 
      begin
        LVItem := lvRecent.Items.Add;
        LVItem.Caption := lvArchive.Items[J].Caption;
        LVItem.SubItems.Add(lvArchive.Items[J].SubItems[0]);
        LVItem.StateIndex := lvArchive.Items[J].StateIndex;
      end; // if Lowercase(CurrentProject) = lvArchive.Items[J].Caption then begin
    end; // for J := 0 to lvArchive.Items.Count - 1 do begin
  end; // for I := 0 to RecentProjectList.Count - 1 do begin
  if (lvRecent.Items.Count > 0) and
    (lvRecent.Selected = nil) then
    lvRecent.Items[0].Selected := True;

  if (lvArchive.Items.Count = 0) then 
    Exit;
  if lvArchive.Selected = nil then 
  begin
    lvArchive.Items[0].Selected := True;
    btnOK.Enabled := True;
    spBtnDescription.Enabled := btnOK.Enabled;
    Exit;
  end;
  // show selected Item
  with lvArchive do 
  begin
    // Selected = nil ?
    if Selected = nil then 
      Exit;
    // Selected = TopItem ?
    if Selected = TopItem then 
      Exit;
    // zurück auf Position 0
    Items.BeginUpdate;
    try
      I := Items.Count;
      while (TopItem <> Items[0]) and (I > 0) do 
      begin
        Scroll(0, - 10); // Texthöhe = 8
        Dec(I);
      end;
      Items.EndUpdate;
      Items.BeginUpdate;
      I := Items.Count;
      while (TopItem <> Selected) and (I > 0) do
      begin
        Scroll(0, 10);
        Dec(I);
      end;
    finally
      Items.EndUpdate;
    end;
  end; // with elvModules do begin

  btnOK.Enabled := True;
  spBtnDescription.Enabled := btnOK.Enabled;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectProject.FormResize(Sender: TObject);
begin
  {$IFNDEF SHOWIDS}
  lvArchive.Columns[0].Width := Width - 40;
  lvRecent.Columns[0].Width := Width - 40;
  {$ENDIF ~SHOWIDS}
end;

//------------------------------------------------------------------------------

procedure TVCSSelectProject.UpdateProjectInfo;
var 
  CurrentLV: TListView;

  procedure ClearDescription;
  begin
    ProjectDescription.Text := '';
    edProjectInfo.Text := '';
    edProjectInfo.Hint := '';
  end;
var
  ProjectData: TProjectTreeProjectData;
begin
  ChangeInProgress := True;
  try
    if cbShowDescr.Checked then
    begin
      if PageControl1.ActivePage = SheetHierarchy then
      begin
        if (tvHierachy.Selected = nil) or not Assigned(tvHierachy.Selected.Data) then
        begin
          ClearDescription;
          Exit;
        end;
        if TObject(tvHierachy.Selected.Data) is TProjectTreeGroup then
        begin
          ProjectDescription.Text := TProjectTreeGroup(tvHierachy.Selected.Data).GroupDescription;
          edProjectInfo.Text := Format(JVCSRES_Project_group_3437s34, [tvHierachy.Selected.Text]);
          edProjectInfo.Hint := '';
        end // if (not TTVData(tvHierachy.Selected.Data^).IsProject) then begin
        else
        if TObject(tvHierachy.Selected.Data) is TProjectTreeProject then
        begin
          ProjectData := TProjectTreeProject(tvHierachy.Selected.Data).ProjectData;
          ProjectDescription.Text :=
            GetDescription(IntToStr(ProjectData.ProjectID));
          edProjectInfo.Text :=
            GetInfo(IntToStr(ProjectData.ProjectID));
          edProjectInfo.Hint := edProjectInfo.Text;
        end; // else if (not TTVData(tvHierachy.Selected.Data^).IsProject) then begin
      end // if PageControl1.ActivePage = SheetHierarchy then begin
      else 
      begin
        if PageControl1.ActivePage = SheetArchive then
          CurrentLV := lvArchive
        else
          CurrentLV := lvRecent;
        if CurrentLV.Selected = nil then 
        begin
          ClearDescription;
          Exit;
        end;
        ProjectDescription.Text := GetDescription(CurrentLV.Selected.SubItems[0]);
        edProjectInfo.Text := GetInfo(CurrentLV.Selected.SubItems[0]);
        edProjectInfo.Hint := edProjectInfo.Text;
      end; // else if PageControl1.ActivePage = SheetHierarchy then begin
    end 
    else 
      ClearDescription;
  finally
    ChangeInProgress := False;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectProject.lvArchiveChanging(Sender: TObject;
  Item: TListItem; Change: TItemChange; var AllowChange: Boolean);
begin
  AllowChange := not ChangeInProgress;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectProject.lvArchiveChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
var
  CurrentLV: TListView;
begin
  if ChangeInProgress then 
    Exit;
  btnOK.Enabled := False;
  if PageControl1.ActivePage = SheetArchive then
    CurrentLV := lvArchive
  else
    CurrentLV := lvRecent;

  UpdateProjectInfo;
  btnOK.Enabled := (CurrentLV.Selected <> nil);
  spBtnDescription.Enabled := btnOK.Enabled;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectProject.ShowDescrMemo(const ShowWin: Boolean);
begin
  if ShowWin then 
  begin
    Panel2.Constraints.MinHeight := MulDiv(90, PixelsPerInch, 96);
    Panel2.Height := DescrPanelHeight;
    Splitter1.Visible := True;
  end 
  else 
  begin
    Panel2.Constraints.MinHeight := Panel1.Height;
    Panel2.Height := Panel1.Height;
    Splitter1.Visible := False;
  end;
  ProjectDescription.TabStop := ShowWin;
  edProjectInfo.TabStop := ShowWin;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectProject.cbShowDescrClick(Sender: TObject);
begin
  ShowDescrMemo(cbShowDescr.Checked);
  UpdateProjectInfo;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectProject.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSSelectProject.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Select_project);
  if (Shift * [ssShift, ssAlt, ssCtrl] = [ssCtrl]) and (Chr(Key) in ['L', 'l']) then
    if (not CtrlSCDisabled(WindowHandle)) then
      spBtnGetLDescrClick(Self);
  if (Shift * [ssShift, ssAlt, ssCtrl] = [ssCtrl]) and (Chr(Key) in ['D', 'd']) then
    if (not CtrlSCDisabled(WindowHandle)) then 
      spBtnDescriptionClick(Self);
  if Key = VK_ESCAPE then 
  begin
    btnCancelClick(Self);
    Key := 0;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectProject.spBtnGetLDescrClick(Sender: TObject);
var 
  LastProject: string;
  LVItem: TListItem;
  I: Integer;
begin
  {$IFDEF IDEDLL}
  LastProject := jvcsReadString(sBaseRegistryKey + crbMRU, 'LastIDEProject', '');
  {$ELSE}
  LastProject := jvcsReadString(sBaseRegistryKey + crbMRU, 'LastSTDProject', '');
  {$ENDIF IDEDLL}
  if LastProject <> '' then
  begin
    if PageControl1.ActivePage = SheetHierarchy then
    begin
      for I := 0 to tvHierachy.Items.Count - 1 do
      begin
        if tvHierachy.Items[I].Text = LastProject then
        begin
          tvHierachy.Selected := tvHierachy.Items[I];
          tvHierachy.Selected.MakeVisible;
          Break;
        end; // if tvHierachy.Items[I].Text = LastProject then begin
      end; // for I := 0 to tvHierachy.Items.Count - 1 do begin
    end // if PageControl1.ActivePage = SheetHierarchy then begin
    else 
    begin
      LVItem := lvArchive.FindCaption(0, LastProject, True, True, False);
      if LVItem <> nil then 
      begin
        LVItem.Selected := True;
        btnOKClick(Self);
      end // if LVItem <> nil then begin
      else
        MessageBox(WindowHandle, PChar(Format(JVCSRES_JEDI_VCS_cannot_find_the_MRU_item_6037s62_in_the_list46,
          [LastProject])), cMsgBoxCaption,
          MB_OK or MB_ICONINFORMATION);
    end; // else if PageControl1.ActivePage = SheetHierarchy then begin
  end // if LastProject <> '' then begin
  else
    MessageBox(WindowHandle, PChar(Format(JVCSRES_MRU_item_6037s62_is_blank46,
      [JVCSRES_Last_Project])), cMsgBoxCaption,
      MB_OK or MB_ICONINFORMATION);
end;

//------------------------------------------------------------------------------

function TVCSSelectProject.GetDescription(const ID: string): string;
begin
  Result := '';
  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_UPDATE_DESCRIPTION';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [1]);
    AppSrvClient1.Request.WriteFields(False, [ID]); // id
    AppSrvClient1.Request.WriteFields(False, [False]); // update
    AppSrvClient1.Request.WriteFields(False, ['']); // text
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
    if not AppSrvClient1.Answer.Eof then
      Result := AppSrvClient1.Answer.Fields[0];
  end; // with DataModule1 do begin
end;

//------------------------------------------------------------------------------

function TVCSSelectProject.GetInfo(const ID: string): string;
begin
  Result := '';
  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_PROJECT_INFORMATION';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [ID]);
    SetupTimeoutCounter;
    AppSrvClient1.Send;
    // Message Window

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
    Result := Format(JVCSRES_Created58_37s_by_37s_45_Last_write_access58_37s_by_37s,
      [DateTimeToStr(GMTStr2LocalDateTime(AppSrvClient1.Answer.Fields[2])),
      AppSrvClient1.Answer.Fields[3],
      DateTimeToStr(GMTStr2LocalDateTime(AppSrvClient1.Answer.Fields[4])),
      AppSrvClient1.Answer.Fields[5]]);
  end; // with DataModule1 do begin
end;

//------------------------------------------------------------------------------

procedure TVCSSelectProject.spBtnDescriptionClick(Sender: TObject);
var
  SelectedName, Description: string;
  CurrentLV: TListView;
  CurrentSelectedID: Integer;
  ProjectData: TProjectTreeProjectData;
begin
  if PageControl1.ActivePage = SheetHierarchy then
  begin
    if (tvHierachy.Selected = nil) or (not Assigned(tvHierachy.Selected.Data)) or
      (not (TObject(tvHierachy.Selected.Data) is TProjectTreeProject)) then
      Exit;
    ProjectData := TProjectTreeProject(tvHierachy.Selected.Data).ProjectData;
    CurrentSelectedID := ProjectData.ProjectID;
    SelectedName := ProjectData.ProjectName;
  end // if PageControl1.ActivePage = SheetHierarchy then begin
  else 
  begin
    if PageControl1.ActivePage = SheetArchive then
      CurrentLV := lvArchive
    else
      CurrentLV := lvRecent;
    if CurrentLV.Selected = nil then 
      Exit;
    CurrentSelectedID := _StrToInt(CurrentLV.Selected.SubItems[0]);
    SelectedName := CurrentLV.Selected.Caption;
  end; // else if PageControl1.ActivePage = SheetHierarchy then begin

  Description := GetDescription(IntToStr(CurrentSelectedID));
  VCSDescription := TVCSDescription.Create(Application);
  try
    VCSDescription.Top := Top + 60;
    VCSDescription.Left := Left + 60;
    VCSDescription.DescType := 1;
    VCSDescription.SetDescripCaption(Format(JVCSRES_38Project58_37s, [SelectedName]));
    VCSDescription.SetDescription(Description);
    VCSDescription.EnableCheckBox(False);
    VCSDescription.ShowModal;
    Description := VCSDescription.Description;
  finally
    VCSDescription.Free;
  end;
  if Description = '' then 
  begin
    Exit;
  end;

  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_UPDATE_DESCRIPTION';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [1]);
    AppSrvClient1.Request.WriteFields(False, [CurrentSelectedID]); // id
    AppSrvClient1.Request.WriteFields(False, [True]); // update
    AppSrvClient1.Request.WriteFields(False, [Description]); // text
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
    end;
  end; // with DataModule1 do begin
  UpdateProjectInfo;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectProject.FormDestroy(Sender: TObject);
begin
  RecentProjectList.Free;
  FProjectTreeContainer.Free;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectProject.PageControl1Change(Sender: TObject);
begin
  if PageControl1.ActivePage = SheetHierarchy then
  begin
    if not GroupsAvailable then
      ReadTree;
    btnOK.Enabled := (tvHierachy.Selected <> nil) and
      Assigned(tvHierachy.Selected.Data) and (TObject(tvHierachy.Selected.Data) is TProjectTreeProject);
    spBtnDescription.Enabled := btnOK.Enabled;
  end;
  UpdateProjectInfo;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectProject.PopupMenu2Popup(Sender: TObject);
var
  ItemIsGroup: Boolean;
  ItemIsProject: Boolean;
begin
  ItemIsGroup := (tvHierachy.Selected <> nil) and
    Assigned(tvHierachy.Selected.Data) and (TObject(tvHierachy.Selected.Data) is TProjectTreeGroup);
  ItemIsProject := (tvHierachy.Selected <> nil) and
    Assigned(tvHierachy.Selected.Data) and (TObject(tvHierachy.Selected.Data) is TProjectTreeProject);
  CreatenewSubCategory1.Enabled := ItemIsGroup;
  RenameProjectGroup1.Enabled := CreatenewSubCategory1.Enabled;
  RemoveCategory1.Enabled := CreatenewSubCategory1.Enabled;
  AddProject1.Enabled := ItemIsGroup;
  RemoveProject1.Enabled := ItemIsProject;
  ProjectDescription1.Enabled := RemoveProject1.Enabled;
  BugTracking1.Enabled := RemoveProject1.Enabled;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectProject.FullExpand1Click(Sender: TObject);
begin
  tvHierachy.Items.BeginUpdate;
  try
    tvHierachy.FullExpand;
    tvHierachy.Selected := tvHierachy.Items.GetFirstNode;
  finally
    tvHierachy.Items.EndUpdate;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectProject.Collapse1Click(Sender: TObject);
begin
  tvHierachy.Items.BeginUpdate;
  try
    tvHierachy.FullCollapse;
    tvHierachy.Selected.Expanded := True;
  finally
    tvHierachy.Items.EndUpdate;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectProject.tvHierachyChange(Sender: TObject;
  Node: TTreeNode);
begin
{
  (*
    USchuster 2003/02/20 - commented - why exit ?
    - if this is enabled then you see no projectdescription with an guestaccount
      and the OK Button is still disabled
    - disabling this doesn't seems to cause any other problems
  *)
  if not GroupsAvailable then
    Exit;
}
  if FTreeUpdateCount = 0 then
  begin
    btnOK.Enabled := (tvHierachy.Selected <> nil) and
      Assigned(tvHierachy.Selected.Data) and (TObject(tvHierachy.Selected.Data) is TProjectTreeProject);
    spBtnDescription.Enabled := btnOK.Enabled;
    UpdateProjectInfo;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectProject.ReadTree;
var
  I: Integer;
  Node: TTreeNode;
begin
  BeginTreeUpdate;
  try
    FProjectTreeContainer.Clear;
    FProjectTreeContainer.Read(GetJvcsConnection, mnHideprojectswithoutanyrights.Checked);
    FProjectTreeContainer.Apply(tvHierachy);
  finally
    EndTreeUpdate;
  end;
  if DefaultID <> 0 then
  begin
    for I := 0 to tvHierachy.Items.Count - 1 do
    begin
      Node := tvHierachy.Items[I];
      if Assigned(Node.Data) and (TObject(Node.Data) is TProjectTreeProject) and
        (TProjectTreeProject(Node.Data).ProjectData.ProjectID = DefaultID) then
      begin
        tvHierachy.Selected := Node;
        tvHierachy.Selected.MakeVisible;
        Break;
      end;
    end; // for I := 0 to tvHierachy.Items.Count - 1 do begin
  end; // if DefaultID <> 0 then begin
  GroupsAvailable := True;
end;

//------------------------------------------------------------------------------

function TVCSSelectProject.AddProjectGroup(const ParentID, GroupLevel,
  Flags: Integer; const GroupName, GroupDescription: string): Integer;
begin
  Result := -1;
  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'ADD_UPDATE_PROJECT_GROUP';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [0]); // id
    AppSrvClient1.Request.WriteFields(False, [ParentID]);
    AppSrvClient1.Request.WriteFields(False, [GroupLevel]);
    AppSrvClient1.Request.WriteFields(False, [Flags]);
    AppSrvClient1.Request.WriteFields(False, [GroupName]);
    AppSrvClient1.Request.WriteFields(False, [GroupDescription]);
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
    if not AppSrvClient1.Answer.Eof then
      Result := _StrToInt(AppSrvClient1.Answer.Fields[0]);
  end; // with DataModule1 do begin
end;

//------------------------------------------------------------------------------

procedure TVCSSelectProject.CreatenewCategory1Click(Sender: TObject);
var 
  NewCategoryName, NewCategoryDescr: string;
  NewID: Integer;
begin
  VCSAddNewGroup := TVCSAddNewGroup.Create(Application);
  try
    VCSAddNewGroup.Top := Top + 60;
    VCSAddNewGroup.Left := Left + 60;
    VCSAddNewGroup.SetupInfo(JVCSRES_Add_new_Group, JVCSRES_Parent, JVCSRES_Root);
    VCSAddNewGroup.ShowModal;
    NewCategoryName := VCSAddNewGroup.NewName;
    NewCategoryDescr := VCSAddNewGroup.NewDescription;
  finally
    VCSAddNewGroup.Free;
  end;
  if NewCategoryName = '' then 
    Exit;

  NewID := AddProjectGroup(0, 0, 0, NewCategoryName, NewCategoryDescr);
  if NewID <> -1 then
  begin
    BeginTreeUpdate;
    try
      FProjectTreeContainer.IncrementalInsertGroup(NewID, 0, NewCategoryName, NewCategoryDescr, tvHierachy);
    finally
      EndTreeUpdate;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectProject.CreatenewSubCategory1Click(Sender: TObject);
var 
  NewCategoryName, NewCategoryDescr: string;
  NewID, ParentID, ParentLevel: Integer;
  Group: TProjectTreeGroup;
begin
  if (tvHierachy.Selected = nil) or (not Assigned(tvHierachy.Selected.Data)) or
    (not (TObject(tvHierachy.Selected.Data) is TProjectTreeGroup)) then
    Exit;
  Group := TProjectTreeGroup(tvHierachy.Selected.Data);
  if Group.GroupIsUnassigned then
  begin
    MessageBox(Handle, PChar(JVCSRES_60Unassigned62_is_an_auto_generated_group_and_not_part_of_the_archive46 + #13#10 +
      JVCSRES_You_cannot_edit44_rename_or_remove_this_group46 + #13#10 +
      JVCSRES_Please_refer_to_the_online_help_file46), cMsgBoxCaption,
      MB_OK or MB_ICONWARNING);
    Exit;
  end;

  VCSAddNewGroup := TVCSAddNewGroup.Create(Application);
  try
    VCSAddNewGroup.Top := Top + 60;
    VCSAddNewGroup.Left := Left + 60;
    VCSAddNewGroup.SetupInfo(JVCSRES_Add_new_Sub_Group, JVCSRES_Parent,
      tvHierachy.Selected.Text);
    VCSAddNewGroup.ShowModal;
    NewCategoryName := VCSAddNewGroup.NewName;
    NewCategoryDescr := VCSAddNewGroup.NewDescription;
  finally
    VCSAddNewGroup.Free;
  end;
  if NewCategoryName = '' then
    Exit;

  ParentID := Group.GroupID;
  ParentLevel := Group.Level;

  NewID := AddProjectGroup(ParentID, ParentLevel + 1, 0, NewCategoryName,
    NewCategoryDescr);
  if NewID <> -1 then
  begin
    BeginTreeUpdate;
    try
      FProjectTreeContainer.IncrementalInsertGroup(NewID, ParentID, NewCategoryName, NewCategoryDescr, tvHierachy);
    finally
      EndTreeUpdate;
    end;
    tvHierachy.Selected.Expand(False);
  end; // if NewID <> -1 then begin
end;

//------------------------------------------------------------------------------

procedure TVCSSelectProject.RenameProjectGroup1Click(Sender: TObject);
var 
  NewCategoryName, NewCategoryDescr: string;
  GroupID: Integer;
  Group: TProjectTreeGroup;
begin
  if (tvHierachy.Selected = nil) or (not Assigned(tvHierachy.Selected.Data)) or
    (not (TObject(tvHierachy.Selected.Data) is TProjectTreeGroup)) then
    Exit;
  Group := TProjectTreeGroup(tvHierachy.Selected.Data);
  if Group.GroupIsUnassigned then
  begin
    MessageBox(Handle, PChar(JVCSRES_60Unassigned62_is_an_auto_generated_group_and_not_part_of_the_archive46 + #13#10 +
      JVCSRES_You_cannot_edit44_rename_or_remove_this_group46 + #13#10 +
      JVCSRES_Please_refer_to_the_online_help_file46), cMsgBoxCaption,
      MB_OK or MB_ICONWARNING);
    Exit;
  end;

  VCSAddNewGroup := TVCSAddNewGroup.Create(Application);
  try
    VCSAddNewGroup.Top := Top + 60;
    VCSAddNewGroup.Left := Left + 60;
    VCSAddNewGroup.SetupInfo(JVCSRES_Rename_Group, JVCSRES_Current, tvHierachy.Selected.Text);
    VCSAddNewGroup.SetupValues(tvHierachy.Selected.Text, Group.GroupDescription);
    VCSAddNewGroup.ShowModal;
    NewCategoryName := VCSAddNewGroup.NewName;
    NewCategoryDescr := VCSAddNewGroup.NewDescription;
  finally
    VCSAddNewGroup.Free;
  end;
  if NewCategoryName = '' then 
    Exit;

  GroupID := Group.GroupID;

  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'ADD_UPDATE_PROJECT_GROUP';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [GroupID]); // id
    AppSrvClient1.Request.WriteFields(False, [0]);
    AppSrvClient1.Request.WriteFields(False, [0]);
    AppSrvClient1.Request.WriteFields(False, [0]);
    AppSrvClient1.Request.WriteFields(False, [NewCategoryName]);
    AppSrvClient1.Request.WriteFields(False, [NewCategoryDescr]);
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
  end; // with DataModule1 do begin

  BeginTreeUpdate;
  try
    FProjectTreeContainer.IncrementalRenameGroup(GroupID, NewCategoryName, NewCategoryDescr, tvHierachy);
  finally
    EndTreeUpdate;
  end;
  UpdateProjectInfo;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectProject.RemoveCategory1Click(Sender: TObject);
var
  DeleteGroupIDs: TStringList;
  CurrentNode: TTreeNode;
  I, CurrentLevel: Integer;
  Group: TProjectTreeGroup;
begin
  if (tvHierachy.Selected = nil) or (not Assigned(tvHierachy.Selected.Data)) or
    (not (TObject(tvHierachy.Selected.Data) is TProjectTreeGroup)) then
    Exit;
  Group := TProjectTreeGroup(tvHierachy.Selected.Data);
  if Group.GroupIsUnassigned then
  begin
    MessageBox(Handle, PChar(JVCSRES_60Unassigned62_is_an_auto_generated_group_and_not_part_of_the_archive46 + #13#10 +
      JVCSRES_You_cannot_edit44_rename_or_remove_this_group46 + #13#10 +
      JVCSRES_Please_refer_to_the_online_help_file46), cMsgBoxCaption,
      MB_OK or MB_ICONWARNING);
    Exit;
  end;

  if MessageBox(WindowHandle, PChar(Format(JVCSRES_Are_you_sure_you_want_to_remove_group_6037s62 + #13#10 +
    JVCSRES_with_all_sub_groups_and_assigned_projects63, [tvHierachy.Selected.Text]) + #13#10 +
    JVCSRES_Warning33_This_process_is_not_reversible46), cMsgBoxCaption, MB_YESNOCANCEL or MB_DEFBUTTON2 or MB_ICONWARNING) <> id_Yes then
    Exit;

  DeleteGroupIDs := TStringList.Create;
  try
    DeleteGroupIDs.Add(IntToStr(Group.GroupID));
    CurrentLevel := tvHierachy.Selected.Level;
    CurrentNode := tvHierachy.Selected.GetNext;
    while (CurrentNode <> nil) and
      (CurrentNode.Level > CurrentLevel) do
    begin
      if Assigned(CurrentNode.Data) and (TObject(tvHierachy.Selected.Data) is TProjectTreeGroup) then
        DeleteGroupIDs.Add(IntToStr(TProjectTreeGroup(CurrentNode.Data).GroupID));
      CurrentNode := CurrentNode.GetNext;
    end;

    for I := 0 to DeleteGroupIDs.Count - 1 do
    begin
      with DataModule1 do 
      begin
        AppSrvClient1.Request.Rewrite;
        AppSrvClient1.FunctionCode := 'REMOVE_PROJECT_GROUP';
        AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
        AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
        AppSrvClient1.Request.WriteFields(True, [DeleteGroupIDs.Strings[I]]); // id
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
      end; // with DataModule1 do begin
    end; // for I := 0 to DeleteGroupIDs.Count - 1 do begin
    BeginTreeUpdate;
    try
      FProjectTreeContainer.IncrementalRemoveGroup(Group.GroupID, tvHierachy);
    finally
      EndTreeUpdate;
    end;
  finally
    DeleteGroupIDs.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectProject.AddProject1Click(Sender: TObject);
var
  NewProjectName, sProjectName: string;
  NewProjectID, I, K, GroupID: Integer;
  slProjects: TStringList;
  Group: TProjectTreeGroup;
begin
  if (tvHierachy.Selected = nil) or (not Assigned(tvHierachy.Selected.Data)) or
    (not (TObject(tvHierachy.Selected.Data) is TProjectTreeGroup)) then
    Exit;
  Group := TProjectTreeGroup(tvHierachy.Selected.Data);
  if Group.GroupIsUnassigned then
  begin
    MessageBox(Handle, PChar(JVCSRES_60Unassigned62_is_an_auto_generated_group_and_not_part_of_the_archive46 + #13#10 +
      JVCSRES_You_cannot_edit44_rename_or_remove_this_group46 + #13#10 +
      JVCSRES_Please_refer_to_the_online_help_file46), cMsgBoxCaption,
      MB_OK or MB_ICONWARNING);
    Exit;
  end;
  GroupID := Group.GroupID;

  VCSSelectList := TVCSSelectList.Create(Application);
  try
    VCSSelectList.Top := Top + 60;
    VCSSelectList.Left := Left + 60;
    VCSSelectList.HelpContextID := 0;
    VCSSelectList.SetCaption(Format(JVCSRES_Add_to_3437s34, [tvHierachy.Selected.Text]));
    for I := 0 to lvArchive.Items.Count - 1 do
      VCSSelectList.AddListItem(lvArchive.Items[I].Caption);
    VCSSelectList.MultiSelect := True;
    VCSSelectList.ShowModal;
    NewProjectName := VCSSelectList.ResultString;
  finally
    VCSSelectList.Free;
  end;
  if NewProjectName = '' then
    Exit;

  slProjects := TStringList.Create;
  try
    StrTokenToStrings(NewProjectName, ';', slProjects);

    for K := 0 to slProjects.Count-1 do
    begin
      NewProjectID := 0;
      sProjectName := slProjects[K];
      for I := 0 to lvArchive.Items.Count - 1 do
      begin
        if sProjectName = lvArchive.Items[I].Caption then
        begin
          NewProjectID := _StrToInt(lvArchive.Items[I].SubItems[0]);
          Break;
        end;
      end;

      if NewProjectID <> 0 then
      begin
        with DataModule1 do
        begin
          AppSrvClient1.Request.Rewrite;
          AppSrvClient1.FunctionCode := 'ADD_REMOVE_PROJECT_TO_GROUP';
          AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
          AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
          AppSrvClient1.Request.WriteFields(True, [NewProjectID]);
          AppSrvClient1.Request.WriteFields(False, [GroupID]);
          AppSrvClient1.Request.WriteFields(False, [True]); // Add
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
          if DecodeBoolStr(AppSrvClient1.Answer.Fields[0]) then
          begin
            BeginTreeUpdate;
            try
              FProjectTreeContainer.IncrementalAddProject(GroupID, NewProjectID, tvHierachy);
            finally
              EndTreeUpdate;
            end;
          end;
        end; // with DataModule1 do begin
        tvHierachy.Selected.Expand(False);
      end; // if NewProjectID <> 0 then begin
    end;  // for K...
  finally
    slProjects.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectProject.RemoveProject1Click(Sender: TObject);
var
  DelProjectID, GroupID: Integer;
  Project: TProjectTreeProject;
  Group: TProjectTreeGroup;
begin
  if (tvHierachy.Selected = nil) or (not Assigned(tvHierachy.Selected.Data)) or
    (not (TObject(tvHierachy.Selected.Data) is TProjectTreeProject)) then
    Exit;
  Project := TProjectTreeProject(tvHierachy.Selected.Data);
  Group := nil;
  if Project.Parent is TProjectTreeGroup then
    Group := TProjectTreeGroup(Project.Parent);
  if (Assigned(Group) and Group.GroupIsUnassigned) or Project.Unassigned then
  begin
    MessageBox(Handle, PChar(JVCSRES_60Unassigned62_is_an_auto_generated_group_and_not_part_of_the_archive46 + #13#10 +
      JVCSRES_You_cannot_edit44_rename_or_remove_this_group46 + #13#10 +
      JVCSRES_Please_refer_to_the_online_help_file46), cMsgBoxCaption,
      MB_OK or MB_ICONWARNING);
    Exit;
  end;

  DelProjectID := Project.ProjectData.ProjectID;
  GroupID := Group.GroupID;

  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'ADD_REMOVE_PROJECT_TO_GROUP';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [DelProjectID]);
    AppSrvClient1.Request.WriteFields(False, [GroupID]);
    AppSrvClient1.Request.WriteFields(False, [False]); // Add
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
  end; // with DataModule1 do begin
  BeginTreeUpdate;
  try
    FProjectTreeContainer.IncrementalRemoveProject(GroupID, DelProjectID, tvHierachy);
  finally
    EndTreeUpdate;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectProject.BugTracking1Click(Sender: TObject);
var 
  SelectedName, BugIndex: string;
  CurrentLV: TListView;
  I, CurrentSelectedID: Integer;
  ProjectBugs: TStringList;
  ProjectData: TProjectTreeProjectData;
begin
  if PageControl1.ActivePage = SheetHierarchy then
  begin
    if (tvHierachy.Selected = nil) or (not Assigned(tvHierachy.Selected.Data)) or
      (not (TObject(tvHierachy.Selected.Data) is TProjectTreeProject)) then
      Exit;
    ProjectData := TProjectTreeProject(tvHierachy.Selected.Data).ProjectData;
    CurrentSelectedID := ProjectData.ProjectID;
    SelectedName := ProjectData.ProjectName;
  end // if PageControl1.ActivePage = SheetHierarchy then begin
  else 
  begin
    if PageControl1.ActivePage = SheetArchive then
      CurrentLV := lvArchive
    else
      CurrentLV := lvRecent;
    if CurrentLV.Selected = nil then 
      Exit;
    CurrentSelectedID := _StrToInt(CurrentLV.Selected.SubItems[0]);
    SelectedName := CurrentLV.Selected.Caption;
  end; // else if PageControl1.ActivePage = SheetHierarchy then begin

  VCSAssignBugs := TVCSAssignBugs.Create(Application);
  try
    VCSAssignBugs.Left := Left + 60;
    VCSAssignBugs.Top := Top + 60;
    VCSAssignBugs.ModuleBased := False;
    VCSAssignBugs.ItemID := IntToStr(CurrentSelectedID);
    VCSAssignBugs.ItemName := SelectedName;
    VCSAssignBugs.ShowModal;
  finally
    VCSAssignBugs.Free;
  end;

  ProjectBugs := TStringList.Create;
  try
    with DataModule1 do 
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_MOST_SEVERE_BUGS';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [False]); // Module based?
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

      ProjectBugs.Clear;
      AppSrvClient1.Answer.First;
      while not AppSrvClient1.Answer.Eof do 
      begin
        ProjectBugs.Add(AppSrvClient1.Answer.Fields[0] + '=' +
          AppSrvClient1.Answer.Fields[2]);
        AppSrvClient1.Answer.Next;
      end;
    end; // with DataModule1 do begin

    BugIndex := ProjectBugs.Values[IntToStr(CurrentSelectedID)];
  finally
    ProjectBugs.Free;
  end;

  // lvArchive
  for I := 0 to lvArchive.Items.Count - 1 do
    if CurrentSelectedID = _StrToInt(lvArchive.Items[I].SubItems[0]) then
    begin
      if BugIndex <> '' then
        lvArchive.Items[I].StateIndex := _StrToInt(BugIndex)
      else
        lvArchive.Items[I].StateIndex := -1;
      Break;
    end;
  // lvRecent
  for I := 0 to lvRecent.Items.Count - 1 do
    if CurrentSelectedID = _StrToInt(lvRecent.Items[I].SubItems[0]) then 
    begin
      if BugIndex <> '' then
        lvRecent.Items[I].StateIndex := _StrToInt(BugIndex)
      else
        lvRecent.Items[I].StateIndex := -1;
      Break;
    end;
  // tvHierachy
  BeginTreeUpdate;
  try
    FProjectTreeContainer.IncrementalUpdateBugIndex(CurrentSelectedID, _StrToInt(BugIndex), tvHierachy);
  finally
    EndTreeUpdate;
  end;
end;

//------------------------------------------------------------------------------
{procedure TVCSSelectProject.test1Click(Sender: TObject);
var Messg: String;
begin
  Messg := 'ID ' + IntToStr(TTVData(tvHierachy.Selected.Data^).ID) + #10#13 +
           'Level ' + IntToStr(TTVData(tvHierachy.Selected.Data^).Level) + #10#13 +
           'ParentID ' + IntToStr(TTVData(tvHierachy.Selected.Data^).ParentID) + #10#13 +
           'State ' + IntToStr(TTVData(tvHierachy.Selected.Data^).State) + #10#13 +
           'GroupDescription ' + TTVData(tvHierachy.Selected.Data^).Description + #10#13;
  if TTVData(tvHierachy.Selected.Data^).IsProject then
    Messg := Messg + 'Project'
  else
    Messg := Messg + 'Category';

  showmessage(Messg);
end;}
//------------------------------------------------------------------------------

procedure TVCSSelectProject.ImportDelphiProjectGroup1Click(Sender: TObject);
var
  I, J, ParentID, ParentLevel, NewProjectID, NewGroupID: Integer;
  ParseStr, GroupName, NewParentGroup: string;
  ProjectList: TStringList;
  DlgResult: Boolean;
  FavOpenDialog: TFavOpenDialog;
begin
  if bIsCppBuilder then
  begin
    MessageBox(WindowHandle, PChar(JVCSRES_This_feature_is_currently_not_supported_by_the_C4343_Builder_version46_Sorry46),
      cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
    Exit;
  end;
  FavOpenDialog := TFavOpenDialog.Create(Application);
  try
    with FavOpenDialog do
    begin
      Title := JVCSRES_Select_project_group;
      Options := [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing];
      InitialDir := ExtractFileDir(sProjectName);
      FileName := '';
      Filter := JVCSRES_Project_groups_404246bpg411244246bpg124All_files_4042464241124424642;

      DlgResult := ExecuteFavOpenDialogWithMru(FavOpenDialog,
        sBaseRegistryKey + crbMRU + '18');

      if DlgResult then
        GroupName := FileName;
    end; // with FavOpenDialog1 do begin
  finally
    FavOpenDialog.Free;
  end;
  if not DlgResult then 
    Exit;

  ParseStr := ParseProjectGroup(GroupName, WindowHandle);
  ProjectList := TStringList.Create;
  try
    while (Length(ParseStr) > 1) and (Pos('|', ParseStr) > 0) do
    begin
      ProjectList.Add(Copy(ParseStr, 1, Pos('|', ParseStr) - 1));
      Delete(ParseStr, 1, Pos('|', ParseStr));
    end; // while Pos('|', ParseStr) > 1 do begin

    VCSSelectList := TVCSSelectList.Create(Application);
    try
      VCSSelectList.Top := Top + 60;
      VCSSelectList.Left := Left + 60;
      VCSSelectList.HelpContextID := 0;
      VCSSelectList.SetCaption(Format(JVCSRES_Select_parent_for_3437s34, [ExtractFileName(GroupName)]));
      VCSSelectList.AddListItem(JVCSRES_45_Root_45);
      for I := 0 to tvHierachy.Items.Count - 1 do
        if Assigned(tvHierachy.Items[I].Data) and (TObject(tvHierachy.Items[I].Data) is TProjectTreeGroup) then
          VCSSelectList.AddListItem(TProjectTreeGroup(tvHierachy.Items[I].Data).GroupName);
      VCSSelectList.ShowModal;
      NewParentGroup := VCSSelectList.ResultString;
    finally
      VCSSelectList.Free;
    end;
    if NewParentGroup = '' then
      Exit;

    ParentID := 0;
    ParentLevel := -1;
    if NewParentGroup <> JVCSRES_45_Root_45 then
    begin
      for I := 0 to tvHierachy.Items.Count - 1 do 
      begin
        if Assigned(tvHierachy.Items[I].Data) and (TObject(tvHierachy.Items[I].Data) is TProjectTreeGroup) and
          (TProjectTreeGroup(tvHierachy.Items[I].Data).GroupName = NewParentGroup) then
        begin
          ParentID := TProjectTreeGroup(tvHierachy.Items[I].Data).GroupID;
          ParentLevel := TProjectTreeGroup(tvHierachy.Items[I].Data).Level;
          tvHierachy.Selected := tvHierachy.Items[I];
          Break;
        end; // if TTVData(tvHierachy.Items[I].Data^).IsProject and...
      end; // for I := 0 to tvHierachy.Items.Count - 1 do begin
    end;

    NewGroupID := AddProjectGroup(ParentID, ParentLevel + 1, 0,
      ExtractFileName(GroupName), Format(JVCSRES_37s_project_group, [sIDEName]));
    if NewGroupID <> -1 then
    begin
      BeginTreeUpdate;
      try
        FProjectTreeContainer.IncrementalInsertGroup(NewGroupID, ParentID, ExtractFileName(GroupName), Format(JVCSRES_37s_project_group, [sIDEName]), tvHierachy);
      finally
        EndTreeUpdate;
      end;
      tvHierachy.Selected.Expand(False);
    end; // if NewID <> -1 then begin

    for I := 0 to ProjectList.Count - 1 do
    begin
      NewProjectID := 0;
      for J := 0 to lvArchive.Items.Count - 1 do
        if ProjectList.Strings[I] = lvArchive.Items[J].Caption then 
        begin
          NewProjectID := _StrToInt(lvArchive.Items[J].SubItems[0]);
          Break;
        end;

      if NewProjectID <> 0 then 
      begin
        with DataModule1 do 
        begin
          AppSrvClient1.Request.Rewrite;
          AppSrvClient1.FunctionCode := 'ADD_REMOVE_PROJECT_TO_GROUP';
          AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
          AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
          AppSrvClient1.Request.WriteFields(True, [NewProjectID]);
          AppSrvClient1.Request.WriteFields(False, [NewGroupID]);
          AppSrvClient1.Request.WriteFields(False, [True]); // Add
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
          if DecodeBoolStr(AppSrvClient1.Answer.Fields[0]) then
          begin
            BeginTreeUpdate;
            try
              FProjectTreeContainer.IncrementalAddProject(NewGroupID, NewProjectID, tvHierachy);
            finally
              EndTreeUpdate;
            end;
          end;
        end; // with DataModule1 do begin
      end; // if NewProjectID <> 0 then begin
    end; // for I := 0 to ProjectList.Count - 1 do begin

  finally
    ProjectList.Free;
  end;
  if NewParentGroup <> JVCSRES_45_Root_45 then
    tvHierachy.Selected.Expand(False);
end;

//------------------------------------------------------------------------------

procedure TVCSSelectProject.PopupMenu1Popup(Sender: TObject);
begin
  ExportSMTPProjectList1.Enabled := (PageControl1.ActivePage = SheetArchive) and
    (lvArchive.Items.Count > 0);
end;

//------------------------------------------------------------------------------

procedure TVCSSelectProject.ExportSMTPProjectList1Click(Sender: TObject);
var 
  ProjectNames: TStringList;
  Mess: string;
  I: Integer;
begin
  ProjectNames := TStringList.Create;
  try
    ProjectNames.Add('[FVCSProjects]');
    for I := 0 to lvArchive.Items.Count - 1 do
      ProjectNames.Add(IntToStr(I) + '=' + lvArchive.Items[I].Caption);
    try
      ProjectNames.SaveToFile(sDLLDirectory + 'FVCSProjects.txt');
    except
      MessageBox(WindowHandle, PChar(Format(JVCSRES_JEDI_VCS_cannot_save_the_file + #13#10 +
        '<%s>.' + #13#10 +
        JVCSRES_Be_sure_that_the_file_is_not_opened_by_another_application44 + #13#10 +
        JVCSRES_that_there_is_enough_free_space_on_the_disk + #13#10 +
        JVCSRES_and_that_you_have_the_required_access_rights46,
        [sDLLDirectory + 'FVCSProjects.txt'])), cMsgBoxCaption, MB_OK or MB_ICONSTOP);
    end;
  finally
    ProjectNames.Free;
  end;
  MessageBox(WindowHandle, PChar(Format(JVCSRES_37s_saved_to_file + #13#10 +
    '<%s>.', [JVCSRES_Project_list,
    sDLLDirectory + 'FVCSProjects.txt'])), cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
  ViewTheModule(WindowHandle, sDLLDirectory + 'FVCSProjects.txt', Mess);
end;

procedure TVCSSelectProject.BeginTreeUpdate;
begin
  Inc(FTreeUpdateCount);
end;

procedure TVCSSelectProject.EndTreeUpdate;
begin
  if FTreeUpdateCount > 0 then
  begin
    Dec(FTreeUpdateCount);
    if FTreeUpdateCount = 0 then
      tvHierachyChange(tvHierachy, tvHierachy.Selected);
  end;
end;

function TVCSSelectProject.GetDefaultAccessLevel: Integer;
var
  Whoami: TJVCSWhoami;
begin
  if FAccessLevel = -1 then
  begin
    Whoami := TJVCSWhoami.Create(nil);
    try
      DataModule1.ClientObjectSendRequest(Whoami);
      FAccessLevel := Whoami.AccessLevel;
    finally
      Whoami.Free;
    end;
  end;
  Result := FAccessLevel;
end;

procedure TVCSSelectProject.mnHideprojectswithoutanyrightsClick(
  Sender: TObject);
begin
  mnHideprojectswithoutanyrights.Checked := not mnHideprojectswithoutanyrights.Checked;
  GroupsAvailable := False;
  SelectProject;
  ReadTree;
end;

procedure TVCSSelectProject.tvHierachyMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Node: TTreeNode;
begin
  if Button = mbRight then
  begin
     Node := tvHierachy.GetNodeAt(X, Y);
     tvHierachy.Selected := Node;
  end;
end;

end.
