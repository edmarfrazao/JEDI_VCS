(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: PHFilter.pas

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
2003/03/05  THensle   - changes for "ConfigStorage" unit
                      - fixed bug 'Clear all actions doesn't clear CB all actions'
2003/03/15  THuber    - set until now date to 'date' if checked
2003/05/18  USchuster - fixed mantis bug #903
2003/09/06  THuber    - Filtervalues are retrieved now on 'need', which means
                        that only if searching for specific project/module/user
                        which speeds up handling project history for those who
                        normaly only filter over dates/action over all projects
                        modules/users. (see also ProjectHist.pas)
2004/06/05  USchuster - if the project, module or user combobox is empty the
                        tabsheet with combobox will be actived before focusing
                        the combobox (mantis #1781)
                      - minor style cleaning (casing and comments)
                      - use constant for messagebox caption
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/24  USchuster - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
                      - fixed cbAllTypesClick (is still broken in FreeVCS)
2004/11/02  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
2007/06/27  USchuster - changes to store "Current project" and "Current user" explicitly (Mantis #4166)
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit PHFilter;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Buttons, JVCSForms;

type
  TVCSPHistoryFilter = class(TJVCSForm)
    btnOk: TButton;
    btnCancel: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    cbAdd: TCheckBox;
    cbRemove: TCheckBox;
    cbChkIn: TCheckBox;
    cbChkOut: TCheckBox;
    cbMerge: TCheckBox;
    cbSync: TCheckBox;
    cbUndoChkOut: TCheckBox;
    cbBranch: TCheckBox;
    cbProjRemove: TCheckBox;
    cbArchTest: TCheckBox;
    cbGet: TCheckBox;
    dtpStartDate: TDateTimePicker;
    Label3: TLabel;
    Label4: TLabel;
    dtpEndDate: TDateTimePicker;
    rbAllUsers: TRadioButton;
    rbCurrentUser: TRadioButton;
    cbUser: TComboBox;
    rbSelectUser: TRadioButton;
    rbAllModules: TRadioButton;
    cbModule: TComboBox;
    rbSelectModule: TRadioButton;
    rbAllProject: TRadioButton;
    rbCurrentProject: TRadioButton;
    cbProjects: TComboBox;
    rbSelectProject: TRadioButton;
    Label5: TLabel;
    cbUntilNow: TCheckBox;
    cbLastWeek: TCheckBox;
    cbLastMonth: TCheckBox;
    cbAllTypes: TCheckBox;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    btnSetAll: TButton;
    Label1: TLabel;
    btnClearAll: TButton;
    Label2: TLabel;
    Help: TSpeedButton;
    procedure btnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnSetAllClick(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure cbUntilNowClick(Sender: TObject);
    procedure cbLastWeekClick(Sender: TObject);
    procedure cbLastMonthClick(Sender: TObject);
    procedure cbAllTypesClick(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure rbProjectModuleUserClick(Sender: TObject);
  private
    { Private declarations }
    FCreating: Boolean;
    procedure SetFromFilterBuffer;  //thu 06.09.2003
  public
    { Public declarations }
  end;

var
  VCSPHistoryFilter: TVCSPHistoryFilter;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSBase, VCSProcBase, ProjectHist, ConfigStorage, JVCSGUIClientResources;

{$R *.dfm}

//------------------------------------------------------------------------------
{- New class of items to insert in a list }
type
  TIDItem = class
    I: Integer;
    constructor Create(I1: Integer);
  end;

  {- Create a new instance of TIDItem }
constructor TIDItem.Create(I1: Integer);
begin
  I := I1;                { Save integer parameter }
  inherited Create;       { Call inherited Create }
end;

//------------------------------------------------------------------------------

procedure TVCSPHistoryFilter.FormCreate(Sender: TObject);
begin
  try
    FCreating := True;

    ShowHint :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    cbUntilNow.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbWindows, 'ProjectHistory_Flt_UntilNow', True);
    cbLastWeek.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbWindows, 'ProjectHistory_Flt_LastWeek', True);
    cbLastMonth.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbWindows, 'ProjectHistory_Flt_LastMonth', True);
    dtpEndDate.Enabled :=
      not cbUntilNow.Checked;
    dtpStartDate.Enabled :=
      (not cbLastWeek.Checked) and (not cbLastMonth.Checked);
    cbAllTypes.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbWindows, 'ProjectHistory_Flt_All', True);
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSPHistoryFilter.FormActivate(Sender: TObject);
var
  ii: Integer;
begin
  Application.ProcessMessages;
  if not FCreating then
    Exit;
  FCreating := False;
  PageControl1.ActivePage := TabSheet1;

  SetFromFilterBuffer;  //thu 06.09.2003 

  if cbProjects.Items.Count > 0 then
    cbProjects.ItemIndex := 0;
  if cbModule.Items.Count > 0 then 
    cbModule.ItemIndex := 0;
  if cbUser.Items.Count > 0 then
    cbUser.ItemIndex := 0;

  with VCSProjectHistory.FilterDefinition do 
  begin
    if cbLastWeek.Checked or cbLastMonth.Checked then 
    begin
      if cbLastWeek.Checked then 
        dtpStartDate.Date := Now - 7;
      if cbLastMonth.Checked then
        dtpStartDate.Date := Now - 30;
    end 
    else
      dtpStartDate.Date := FilterStartDate;
    if cbUntilNow.Checked then
      dtpEndDate.Date := Date
    else 
      dtpEndDate.Date := FilterEndDate;
    // projects
    if FilterProject = ProjectHistoryCurrentSelection then
    begin
      rbAllProject.Checked := False;
      rbCurrentProject.Checked := True;
      rbSelectProject.Checked := False;
    end
    else
    if FilterProject = 0 then
    begin
      rbAllProject.Checked := True;
      rbCurrentProject.Checked := False;
      rbSelectProject.Checked := False;
    end // if FilterProject = 0 then begin
    else
    begin
      rbAllProject.Checked := False;
      rbCurrentProject.Checked := False;
      rbSelectProject.Checked := True;
      for ii := 0 to cbProjects.Items.Count - 1 do
      begin
        if TIDItem(cbProjects.Items.Objects[ii]).I = FilterProject then
        begin
          cbProjects.ItemIndex := ii;
          Break;
        end; // if _StrToInt(CurrentID) = FilterProject then begin
      end; // for ii := 0 to cbProjects.Items.Count - 1 do begin
    end; // if FilterProject = 0 then begin
    // modules
    if FilterModule = 0 then
    begin
      rbAllModules.Checked := True;
      rbSelectModule.Checked := False;
    end // if FilterModule = 0 then begin
    else 
    begin
      rbAllModules.Checked := False;
      rbSelectModule.Checked := True;
      for ii := 0 to cbModule.Items.Count - 1 do
      begin
        if TIDItem(cbModule.Items.Objects[ii]).I = FilterModule then
        begin
          cbModule.ItemIndex := ii;
          Break;
        end; // if _StrToInt(CurrentID) = FilterModule then begin
      end; // for ii := 0 to cbModule.Items.Count - 1 do begin
    end; // if FilterModule = 0 then begin
    // Users
    if FilterUser = ProjectHistoryCurrentSelection then
    begin
      rbAllUsers.Checked := False;
      rbCurrentUser.Checked := True;
      rbSelectUser.Checked := False;
    end
    else
    if FilterUser = 0 then
    begin
      rbAllUsers.Checked := True;
      rbCurrentUser.Checked := False;
      rbSelectUser.Checked := False;
    end // if FilterUser = 0 then begin
    else
    begin
      rbAllUsers.Checked := False;
      rbCurrentUser.Checked := False;
      rbSelectUser.Checked := True;
      for ii := 0 to cbUser.Items.Count - 1 do
      begin
        if TIDItem(cbUser.Items.Objects[ii]).I = FilterUser then
        begin
          cbUser.ItemIndex := ii;
          Break;
        end; // if _StrToInt(CurrentID) = FilterUser then begin
      end; // for ii := 0 to cbUser.Items.Count - 1 do begin
    end; // if FilterUser = 0 then begin
    // actions
    cbAdd.Checked := (Pos('a', FilterValue) > 0);
    cbRemove.Checked := (Pos('r', FilterValue) > 0);
    cbChkIn.Checked := (Pos('i', FilterValue) > 0);
    cbChkOut.Checked := (Pos('o', FilterValue) > 0);
    cbGet.Checked := (Pos('g', FilterValue) > 0);
    cbSync.Checked := (Pos('s', FilterValue) > 0);
    cbMerge.Checked := (Pos('m', FilterValue) > 0);
    cbBranch.Checked := (Pos('b', FilterValue) > 0);
    cbArchTest.Checked := (Pos('t', FilterValue) > 0);
    cbProjRemove.Checked := (Pos('p', FilterValue) > 0);
    cbUndoChkOut.Checked := (Pos('u', FilterValue) > 0);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSPHistoryFilter.btnOkClick(Sender: TObject);
  //var CurrentSelection: String;

  procedure ActivateControlParentTabSheet(AControl: TControl);
  begin
    while Assigned(AControl) do
    begin
      if AControl is TTabSheet then
      begin
        if PageControl1.ActivePage <> AControl then
          PageControl1.ActivePage := TTabSheet(AControl);
        Break;
      end;
      AControl := AControl.Parent;
    end;
  end;

  function CheckComboBox(CB: TComboBox; ErrMsg: string): Boolean;
  begin
    Result := False;
    if CB.Text = '' then
    begin
      MessageBox(Handle, PChar(Format(JVCSRES_You_have_selected_option_6037s6246 + #13#10 +
        JVCSRES_The_corresponding_value_cannot_be_blank46, [ErrMsg])),
        cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
      ActivateControlParentTabSheet(CB);
      if CB.CanFocus then
        CB.SetFocus;
      Exit;
    end;
    Result := True;
  end;  
begin
  // projects
  with VCSProjectHistory.FilterDefinition do
  begin
    if rbAllProject.Checked then 
      FilterProject := 0
    else
    if rbCurrentProject.Checked then
      FilterProject := ProjectHistoryCurrentSelection
    else
    if rbSelectProject.Checked then
    begin
      if not CheckComboBox(cbProjects, JVCSRES_Project) then
        Exit;
      FilterProject := TIDItem(cbProjects.Items.Objects[cbProjects.ItemIndex]).I;
    end;
    // modules
    if rbAllModules.Checked then
      FilterModule := 0
    else
    if rbSelectModule.Checked then
    begin
      if not CheckComboBox(cbModule, JVCSRES_Module) then
        Exit;
      FilterModule := TIDItem(cbModule.Items.Objects[cbModule.ItemIndex]).I;
    end;
    // users
    if rbAllUsers.Checked then
      FilterUser := 0
    else
    if rbCurrentUser.Checked then
      FilterUser := ProjectHistoryCurrentSelection
    else
    if rbSelectUser.Checked then
    begin
      if not CheckComboBox(cbUser, JVCSRES_User) then
        Exit;
      FilterUser := TIDItem(cbUser.Items.Objects[cbUser.ItemIndex]).I;
    end;
    //USc - trunc the Date because it should be only a Date and not a Date + X
    FilterStartDate := Trunc(dtpStartDate.Date);
    FilterEndDate := Trunc(dtpEndDate.Date);

    FilterValue := '';
    if not cbAllTypes.Checked then
    begin
      if cbAdd.Checked then 
        FilterValue := FilterValue + 'a;';
      if cbRemove.Checked then
        FilterValue := FilterValue + 'r;';
      if cbChkIn.Checked then
        FilterValue := FilterValue + 'i;';
      if cbChkOut.Checked then
        FilterValue := FilterValue + 'o;';
      if cbGet.Checked then
        FilterValue := FilterValue + 'g;';
      if cbSync.Checked then
        FilterValue := FilterValue + 's;';
      if cbMerge.Checked then
        FilterValue := FilterValue + 'm;';
      if cbBranch.Checked then
        FilterValue := FilterValue + 'b;';
      if cbArchTest.Checked then
        FilterValue := FilterValue + 't;';
      if cbProjRemove.Checked then
        FilterValue := FilterValue + 'p;';
      if cbUndoChkOut.Checked then
        FilterValue := FilterValue + 'u;';
    end // if not cbAllTypes.Checked then begin
    else 
      FilterValue := '';
  end; // with PHFilterDefinition do begin
  ModalResult := mrOk;
end;

//------------------------------------------------------------------------------

procedure TVCSPHistoryFilter.btnSetAllClick(Sender: TObject);
var 
  SetAll: Boolean;
begin
  SetAll := Sender = btnSetAll;
  cbAllTypes.Checked := SetAll;
  cbAdd.Checked := SetAll;
  cbRemove.Checked := SetAll;
  cbChkIn.Checked := SetAll;
  cbChkOut.Checked := SetAll;
  cbGet.Checked := SetAll;
  cbSync.Checked := SetAll;
  cbMerge.Checked := SetAll;
  cbBranch.Checked := SetAll;
  cbArchTest.Checked := SetAll;
  cbProjRemove.Checked := SetAll;
  cbUndoChkOut.Checked := SetAll;
end;

//------------------------------------------------------------------------------

procedure TVCSPHistoryFilter.PageControl1Change(Sender: TObject);
begin
  btnSetAll.Visible := (PageControl1.ActivePage = TabSheet5);
  Label1.Visible := btnSetAll.Visible;
  btnClearAll.Visible := btnSetAll.Visible;
  Label2.Visible := btnSetAll.Visible;
end;

//------------------------------------------------------------------------------

procedure TVCSPHistoryFilter.cbUntilNowClick(Sender: TObject);
begin
  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'ProjectHistory_Flt_UntilNow',
    cbUntilNow.Checked);
  dtpEndDate.Enabled := not cbUntilNow.Checked;
  //THu
  if cbUntilNow.Checked then
  begin
    dtpEndDate.Date := Date;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSPHistoryFilter.cbLastWeekClick(Sender: TObject);
begin
  if cbLastWeek.Checked then
  begin
    dtpStartDate.Date := Now - 7;
    cbLastMonth.Checked := False;
  end;
  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'ProjectHistory_Flt_LastWeek',
    cbLastWeek.Checked);
  dtpStartDate.Enabled :=
    (not cbLastWeek.Checked) and (not cbLastMonth.Checked);
end;

//------------------------------------------------------------------------------

procedure TVCSPHistoryFilter.cbLastMonthClick(Sender: TObject);
begin
  if cbLastMonth.Checked then
  begin
    dtpStartDate.Date := Now - 30;
    cbLastWeek.Checked := False;
  end;
  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'ProjectHistory_Flt_LastMonth',
    cbLastMonth.Checked);
  dtpStartDate.Enabled :=
    (not cbLastWeek.Checked) and (not cbLastMonth.Checked);
end;

//------------------------------------------------------------------------------

procedure TVCSPHistoryFilter.cbAllTypesClick(Sender: TObject);
var 
  I: Integer;
begin
  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'ProjectHistory_Flt_All',
    cbAllTypes.Checked);
  with TabSheet5 do 
  begin
    for I := 0 to ControlCount - 1 do
      if (Controls[I] is TCheckBox) and (Controls[I] <> cbAllTypes) then
        (Controls[I] as TCheckBox).Enabled := not cbAllTypes.Checked;
  end; // with TabSheet5 do begin
end;

//------------------------------------------------------------------------------

procedure TVCSPHistoryFilter.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSPHistoryFilter.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Project_history);
end;

//------------------------------------------------------------------------------

procedure TVCSPHistoryFilter.FormDestroy(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to cbProjects.Items.Count - 1 do
    cbProjects.Items.Objects[I].Free;
  for I := 0 to cbModule.Items.Count - 1 do
    cbModule.Items.Objects[I].Free;
  for I := 0 to cbUser.Items.Count - 1 do
    cbUser.Items.Objects[I].Free;
end;

//thu 06.09.2003
procedure TVCSPHistoryFilter.rbProjectModuleUserClick(Sender: TObject);
begin
  if Assigned(Sender) and (Sender is TRadioButton) then
  begin
    // due to limitation in GET_LOG_FILTER object, have to do it this way
    // in JVCS version after 2.4 should be added new/faster server object
    // if changed to rbSelectProject:
    // - now run the GET_LOG_FILTER entries
    if rbSelectProject.Checked or
       rbSelectModule.Checked or
       rbSelectUser.Checked then
    begin
      if Assigned(VCSProjectHistory.FilterBuffer) and
        (VCSProjectHistory.FilterBuffer.Count = 0) then
      begin
        VCSProjectHistory.LoadFilterBuffer;
        SetFromFilterBuffer;
      end;
    end;
    cbProjects.Enabled := rbSelectProject.Checked;
    cbModule.Enabled := rbSelectModule.Checked;
    cbUser.Enabled := rbSelectUser.Checked;
  end;
end;

//thu 06.09.2003
// Fill filtercombo's in PHFilter.pas from buffer
procedure TVCSPHistoryFilter.SetFromFilterBuffer;
var
  ii: Integer;
  CurrentEnty, CurrentType, CurrentID: string;
  IDItem: TIDItem;
begin
  for ii := 0 to VCSProjectHistory.FilterBuffer.Count - 1 do
  begin
    CurrentEnty := VCSProjectHistory.FilterBuffer.Strings[ii];
    CurrentType := Copy(CurrentEnty, 1, Pos('|', CurrentEnty) - 1);
    Delete(CurrentEnty, 1, Pos('|', CurrentEnty));
    CurrentID := Copy(CurrentEnty, 1, Pos('|', CurrentEnty) - 1);
    Delete(CurrentEnty, 1, Pos('|', CurrentEnty));

    if CurrentType = 'p' then
    begin
      IDItem := TIDItem.Create(_StrToInt(CurrentID));
      cbProjects.Items.AddObject(CurrentEnty, IDItem);
      if CurrentID = IntToStr(ServerProjectID) then
        rbCurrentProject.Caption := rbCurrentProject.Caption + ' (' +
          CurrentEnty + ')';
    end;
    if CurrentType = 'm' then
    begin
      IDItem := TIDItem.Create(_StrToInt(CurrentID));
      cbModule.Items.AddObject(CurrentEnty, IDItem);
    end;
    if CurrentType = 'u' then
    begin
      IDItem := TIDItem.Create(_StrToInt(CurrentID));
      cbUser.Items.AddObject(CurrentEnty, IDItem);
      if CurrentID = IntToStr(ServerUserID) then
        rbCurrentUser.Caption := rbCurrentUser.Caption + ' (' +
          CurrentEnty + ')';
    end;
  end; // for
end;

end.
