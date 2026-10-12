(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: ToDoFilter.pas

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
2003/03/15  THuber    - use TJvComboBox instead of TComboBox
2003/12/28  USchuster - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use constant)
                      - AutoComplete in ComboBox now False
2004/02/24  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/06/12  USchuster - set Category ComboBox back to Style = csDropDownList
                      - minor style cleaning (casing and comments)
2004/09/17  FHasovic  - Added dxGetText support for localization                      
2004/10/08  USchuster - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/10/31  USchuster - moved resourcestrings to JVCSGUIClientResources.pas                      
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit ToDoFilter;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Buttons, JvCombobox, JvExStdCtrls, JVCSForms;

type
  TFilterDefinition = record
    FilterValue: string;
    FilterProject,
    FilterModule,
    FilterUser: Integer;
    FilterStartDate,
    FilterEndDate: Double;
  end;

type
  TVCSToDoFilter = class(TJVCSForm)
    btnOk: TButton;
    btnCancel: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    dtpTargetDate: TDateTimePicker;
    rbAllUsers: TRadioButton;
    rbCurrentUser: TRadioButton;
    cbUser: TJvComboBox;
    rbSelectUser: TRadioButton;
    rbAllProject: TRadioButton;
    rbCurrentProject: TRadioButton;
    cbProjects: TJvComboBox;
    rbSelectProject: TRadioButton;
    cbCategory: TJvComboBox;
    Label1: TLabel;
    cbNotDone: TCheckBox;
    Label2: TLabel;
    cbPriority: TJvComboBox;
    rbIgnoreOverdue: TRadioButton;
    rbOverdueAt: TRadioButton;
    rbOverdueNow: TRadioButton;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Help: TSpeedButton;
    procedure btnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FCreating: Boolean;
  public
    { Public declarations }
  end;

var
  VCSToDoFilter: TVCSToDoFilter;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  DBModule, VCSBase, VCSProcBase, ToDo, ConfigStorage, JVCSGUIClientResources;

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

procedure TVCSToDoFilter.FormCreate(Sender: TObject);
begin
  try
    FCreating := True;
    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSToDoFilter.FormActivate(Sender: TObject);
var
  I: Integer;
  CurrentEntry, CurrentType, CurrentID: string;
  IDItem: TIDItem;
begin
  Application.ProcessMessages;
  if not FCreating then
    Exit;
  FCreating := False;
  PageControl1.ActivePage := TabSheet1;

  cbCategory.Items.Add(JVCSRES_All_categories);
  for I := 0 to VCSToDo.FilterBuffer.Count - 1 do 
  begin
    CurrentEntry := VCSToDo.FilterBuffer.Strings[I];
    CurrentType := Copy(CurrentEntry, 1, Pos('|', CurrentEntry) - 1);
    Delete(CurrentEntry, 1, Pos('|', CurrentEntry));
    CurrentID := Copy(CurrentEntry, 1, Pos('|', CurrentEntry) - 1);
    Delete(CurrentEntry, 1, Pos('|', CurrentEntry));

    if CurrentType = 'p' then 
    begin
      IDItem := TIDItem.Create(_StrToInt(CurrentID));
      cbProjects.Items.AddObject(CurrentEntry, IDItem);
      if CurrentID = IntToStr(ServerProjectID) then
        rbCurrentProject.Caption := rbCurrentProject.Caption + ' (' +
          CurrentEntry + ')';
    end;
    if CurrentType = 'c' then
    begin
      if CurrentEntry <> '' then 
        cbCategory.Items.Add(CurrentEntry);
    end;
    if CurrentType = 'u' then 
    begin
      IDItem := TIDItem.Create(_StrToInt(CurrentID));
      cbUser.Items.AddObject(CurrentEntry, IDItem);
      if CurrentID = IntToStr(ServerUserID) then
        rbCurrentUser.Caption := rbCurrentUser.Caption + ' (' +
          CurrentEntry + ')';
    end;
  end; // for I := 0 to VCSToDo.FilterBuffer.Count - 1 do begin

  if cbProjects.Items.Count > 0 then 
    cbProjects.ItemIndex := 0;
  if cbUser.Items.Count > 0 then 
    cbUser.ItemIndex := 0;
  cbCategory.ItemIndex := 0;
  cbPriority.ItemIndex := 0;

  with VCSToDo.FilterDefinition do 
  begin
    // projects
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
      for I := 0 to cbProjects.Items.Count - 1 do 
      begin
        if TIDItem(cbProjects.Items.Objects[I]).I = FilterProject then 
        begin
          cbProjects.ItemIndex := I;
          Break;
        end; // if _StrToInt(CurrentID) = FilterProject then begin
      end; // for I := 0 to cbProjects.Items.Count - 1 do begin
    end; // if FilterProject = 0 then begin
    // Users
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
      for I := 0 to cbUser.Items.Count - 1 do 
      begin
        if TIDItem(cbUser.Items.Objects[I]).I = FilterUser then 
        begin
          cbUser.ItemIndex := I;
          Break;
        end; // if _StrToInt(CurrentID) = FilterUser then begin
      end; // for I := 0 to cbUser.Items.Count - 1 do begin
    end; // if FilterUser = 0 then begin
    // target date
    rbOverdueNow.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbWindows, 'ToDoFilter_OverdueNow', False);
    if not rbOverdueNow.Checked then
    begin
      if FilterDate <> 0 then 
      begin
        rbOverdueAt.Checked := True;
        dtpTargetDate.Date := FilterDate;
      end
      else 
        rbIgnoreOverdue.Checked := True;
    end; // if not rbOverdueNow.Checked then begin
    // value
    if FilterValue <> '' then
      if cbCategory.Items.IndexOf(FilterValue) > 0 then
        cbCategory.ItemIndex := cbCategory.Items.IndexOf(FilterValue);
    // priority
    cbPriority.ItemIndex := FilterPriority;
    // done items
    cbNotDone.Checked := FilterDoneItems;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSToDoFilter.btnOkClick(Sender: TObject);
  //var CurrentSelection: String;

  function CheckComboBox(CB: TJvComboBox; ErrMsg: string): Boolean;
  begin
    Result := False;
    if CB.Text = '' then 
    begin
      MessageBox(Handle, PChar(Format(JVCSRES_You_have_selected_option_6037s6246 + #13#10 +
        JVCSRES_The_coresponding_value_cannot_be_blank46, [ErrMsg])),
        cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
      Exit;
    end;
    Result := True;
  end;  
begin
  // projects
  with VCSToDo.FilterDefinition do 
  begin
    if rbAllProject.Checked then 
      FilterProject := 0;
    if rbCurrentProject.Checked then 
      FilterProject := ServerProjectID;
    if rbSelectProject.Checked then 
    begin
      if not CheckComboBox(cbProjects, JVCSRES_Project) then 
        Exit;
      FilterProject := TIDItem(cbProjects.Items.Objects[cbProjects.ItemIndex]).I;
    end;
    if rbAllUsers.Checked then 
      FilterUser := 0;
    if rbCurrentUser.Checked then 
      FilterUser := ServerUserID;
    if rbSelectUser.Checked then 
    begin
      if not CheckComboBox(cbUser, JVCSRES_User) then 
        Exit;
      FilterUser := TIDItem(cbUser.Items.Objects[cbUser.ItemIndex]).I;
    end;

    jvcsWriteBool(sBaseRegistryKey + crbWindows, 'ToDoFilter_OverdueNow',
      rbOverdueNow.Checked);
    if not rbOverdueNow.Checked then
    begin
      if rbIgnoreOverdue.Checked then
        FilterDate := 0 
      else 
        FilterDate := dtpTargetDate.Date;
    end 
    else 
      FilterDate := Now;
    if cbCategory.ItemIndex > 0 then
      FilterValue := cbCategory.Text 
    else 
      FilterValue := '';
    FilterPriority := cbPriority.ItemIndex;
    FilterDoneItems := cbNotDone.Checked;
  end; // with PHFilterDefinition do begin
  ModalResult := mrOk;
end;

//------------------------------------------------------------------------------

procedure TVCSToDoFilter.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSToDoFilter.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_ToDo_list);
end;

//------------------------------------------------------------------------------

procedure TVCSToDoFilter.FormDestroy(Sender: TObject);
var 
  I: Integer;
begin
  for I := 0 to cbProjects.Items.Count - 1 do
    cbProjects.Items.Objects[I].Free;
  for I := 0 to cbUser.Items.Count - 1 do
    cbUser.Items.Objects[I].Free;
end;

end.
