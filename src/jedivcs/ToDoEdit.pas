(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: ToDoEdit.pas

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
2003/03/06  THensle   - changes for "ConfigStorage" unit
2003/03/09  USchuster - exchanged TjvMruList with TJVCSMruList (mantis #727)
                      - disabled the AutoSave property in rcbxCategory
                        and removed the regkeys (they where wrong and
                        loading and saving is no done with MruListCategory)
                      - removed rcbxCategory.AutoSave.SaveValue
2003/03/15  THuber    - AutoComplete now false for Combo where editing is allowed
                        (mantis #786)
2003/08/02  THuber    - mantis #861: replaced TMemo with TJvMemo
                      - better layout (form now sizable)
                      - FormStorage changed in configStorage
2003/10/30  THuber    - Fixed buggy FormLayout
                        due to FormResize which is no more necessary
2003/12/28  USchuster - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use constant)
2004/02/24  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/09  USchuster - style cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/10/31  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
2007/07/01  USchuster - changes for large fonts (contraints size depend now on PixelsPerInch; analog to Mantis #3710)
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit ToDoEdit;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, Menus, JvSpin, Buttons, JvCombobox, JVCSForms,
  JvEdit, JVCSMruList, Mask, JvMaskEdit, JvMemo, JvExStdCtrls, JvExMask;

type
  TVCSToDoEdit = class(TJVCSForm)
    pnlHead: TPanel;
    pnlButton: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    edDate: TEdit;
    Label4: TLabel;
    btnCancel: TButton;
    btnOK: TButton;
    PopupMenu1: TPopupMenu;
    Clearhistory1: TMenuItem;
    Label5: TLabel;
    dtpTarget: TDateTimePicker;
    spePriority: TJvSpinEdit;
    Label7: TLabel;
    cbxUser: TComboBox;
    cbxProject: TComboBox;
    Label8: TLabel;
    spBtnClrTarget: TSpeedButton;
    cbDone: TCheckBox;
    Help: TSpeedButton;
    btnToday: TSpeedButton;
    rcbxCategory: TJvComboBox;
    gbDescription: TGroupBox;
    meToDo: TJvMemo;
    procedure FormShow(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure spBtnClrTargetClick(Sender: TObject);
    procedure Clearhistory1Click(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure btnTodayClick(Sender: TObject);
  private
    { Private declarations }
    MruListCategory: TJVCSMruList;
  public
    { Public declarations }
    New: Boolean;
    Priority: Integer;
    Target,
    Done: Double;
    Created,
    Project,
    Responsible,
    Category,
    Description: string;
    UserList,
    ProjectList: TStringList;
  end;

var
  VCSToDoEdit: TVCSToDoEdit;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  ToDo, VCSBase, VCSProcBase, ConfigStorage, JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSToDoEdit.FormCreate(Sender: TObject);
//thu 03.08.2003
{
var
  DlgTop, DlgLeft, DlgWidth, DlgHeight: integer;
 }
begin
  try
    Constraints.MinHeight := MulDiv(260, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(296, PixelsPerInch, 96);
    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);
  //thu 03.08.2003
  { 
    if not jvcsReadWindowPosAndSize(sBaseRegistryKey + crbWindows, 'ToDoEditor',
      DlgTop, DlgLeft, DlgWidth, DlgHeight) then
    begin
      DlgTop := (Screen.Height - Height) div 2;
      DlgLeft := (Screen.Width - Width) div 2;
      DlgWidth := 295;
      DlgHeight := 260;
    end;
    Top := DlgTop;
    Left := DlgLeft;
    Width := DlgWidth;
    Height := DlgHeight;
     }

    UserList := TStringList.Create;
    ProjectList := TStringList.Create;

    MruListCategory := TJVCSMruList.CreateEx(sBaseRegistryKey + crbMRU + '14');
    rcbxCategory.Items.Assign(MruListCategory);

    Screen.Cursors[cPopUpMCursor] := LoadCursor(hInstance, PChar('CURSORRM'));
    rcbxCategory.Cursor := cPopUpMCursor;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSToDoEdit.FormShow(Sender: TObject);
var
  I: Integer;
begin
  //thu 03.08.2003
  jvcsLoadFormPosSize(Self);
  
  for I := 0 to UserList.Count - 1 do
    cbxUser.Items.Add(UserList.Strings[I]);
  for I := 0 to ProjectList.Count - 1 do
    cbxProject.Items.Add(ProjectList.Strings[I]);
  if New then 
  begin
    Caption := JVCSRES_Add_ToDo_item;
    edDate.Text := DateTimeToStr(Now);
    cbxUser.ItemIndex := cbxUser.Items.IndexOf(sCurrentUser);
    cbxProject.ItemIndex := cbxProject.Items.IndexOf(AnsiLowerCase(ExtractFileName(sProjectName)));
    dtpTarget.Date := 0;
  end 
  else 
  begin
    Caption := JVCSRES_Edit_ToDo_item;
    spePriority.Value := Priority;
    cbxUser.ItemIndex := cbxUser.Items.IndexOf(Responsible);
    cbxProject.ItemIndex := cbxProject.Items.IndexOf(Project);
    rcbxCategory.Text := Category;
    edDate.Text := Created;
    dtpTarget.Date := Target;
    cbDone.Checked := (Done > 0) and (Done <= Now);
    meToDo.Text := Description;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSToDoEdit.btnOKClick(Sender: TObject);
begin
  if cbxProject.Text = '' then 
  begin
    MessageBox(WindowHandle, PChar(Format(JVCSRES_6037s6246_This_value_cannot_be_blank46,
      [JVCSRES_Project])), cMsgBoxCaption,
      MB_OK or MB_ICONWARNING);
    cbxProject.SetFocus;
    Exit;
  end;
  if meToDo.Text = '' then
  begin
    MessageBox(WindowHandle, PChar(Format(JVCSRES_6037s6246_This_value_cannot_be_blank46,
      [JVCSRES_ToDo_text])), cMsgBoxCaption,
      MB_OK or MB_ICONWARNING);
    meToDo.SetFocus;
    Exit;
  end;
  Priority := spePriority.AsInteger;
  Responsible := cbxUser.Text;
  Project := cbxProject.Text;
  Category := rcbxCategory.Text;
  Target := dtpTarget.Date;
  if cbDone.Checked then 
    Done := Now 
  else 
    Done := 0;
  Description := meToDo.Text;
  MruListCategory.AddString(rcbxCategory.Text);
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSToDoEdit.btnCancelClick(Sender: TObject);
begin
  Priority := 0;
  Responsible := '';
  Project := '';
  Category := '';
  Target := 0;
  Done := 0;
  Description := '';
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSToDoEdit.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    btnCancel.Click;
    Key := 0;
  end;
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_ToDo_list);
end;

//------------------------------------------------------------------------------

procedure TVCSToDoEdit.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  //thu 03.08.2003
  { 
  jvcsWriteWindowPosAndSize(sBaseRegistryKey + crbWindows, 'ToDoEditor',
    Top, Left, Width, Height);
   }
  jvcsSaveFormPosSize(Self);
end;

//------------------------------------------------------------------------------

procedure TVCSToDoEdit.FormDestroy(Sender: TObject);
begin
  UserList.Free;
  ProjectList.Free;
  MruListCategory.Free;
end;

//------------------------------------------------------------------------------

procedure TVCSToDoEdit.spBtnClrTargetClick(Sender: TObject);
begin
  dtpTarget.Date := 0;
end;

//------------------------------------------------------------------------------

procedure TVCSToDoEdit.Clearhistory1Click(Sender: TObject);
begin
  if MessageBox(WindowHandle, PChar(JVCSRES_Are_you_sure_you_want_to_remove_all_categories_from_the_history_list63 + #13#10 +
    JVCSRES_40This_will_not_affect_already_created_ToDo_items41 + #13#10 +
    JVCSRES_Warning33_This_process_is_not_reversible46), cMsgBoxCaption,
    MB_YESNOCANCEL or MB_ICONWARNING) <> idYes then 
    Exit;
  {  --hu
  rcbxCategory.ClearMRU;
  rcbxCategory.ClearReg;
   }
end;

//------------------------------------------------------------------------------

procedure TVCSToDoEdit.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

procedure TVCSToDoEdit.btnTodayClick(Sender: TObject);
begin
  dtpTarget.Date := Now;
end;

end.
