(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: FileFamilies.pas

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
2003/12/28  USchuster - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use constant)
2004/03/14  USchuster - 'ffdef.fvc' -> cSelectionFileFamiliesFile
                      - minor style cleaning (casing and comments)
2004/04/17  USchuster - restricted minimum size in form
                      - moved some strings to JVCSGUIClientResources.pas
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/30  USchuster - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/11/05  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
2007/06/17  USchuster - fixed self handled shortcuts
2007/06/30  USchuster - changes for large fonts (contraints size depend now on PixelsPerInch; analog to Mantis #3710)
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit FileFamilies;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IniFiles, StdCtrls, Buttons, ExtCtrls, ComCtrls, ImgList, Menus, JVCSForms;

type
  TVCSFileFamilies = class(TJVCSForm)
    lvFileFamilies: TListView;
    Panel1: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    spBtnAdd: TSpeedButton;
    spBtnRemove: TSpeedButton;
    spBtnEdit: TSpeedButton;
    PopupMenu1: TPopupMenu;
    Add1: TMenuItem;
    Remove1: TMenuItem;
    Edit1: TMenuItem;
    ImageList1: TImageList;
    spBtnClearAll: TSpeedButton;
    Help: TSpeedButton;
    EditFilterCaption1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure spBtnAddClick(Sender: TObject);
    procedure spBtnRemoveClick(Sender: TObject);
    procedure spBtnEditClick(Sender: TObject);
    procedure HelpTopic1Click(Sender: TObject);
    procedure spBtnClearAllClick(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure EditFilterCaption1Click(Sender: TObject);
  private
    { Private declarations }
    FCreated: Boolean;
    FF_FileName: string;
    FF_F: TIniFile;
    procedure ReadFF;
    procedure WriteFF;
  public
    { Public declarations }
  end;

var
  VCSFileFamilies: TVCSFileFamilies;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSBase, VCSProcBase, ListEdit, ConfigStorage, JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSFileFamilies.FormCreate(Sender: TObject);
begin
  try
    Constraints.MinHeight := MulDiv(180, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(340, PixelsPerInch, 96);
    FCreated := False;
    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);
    FF_FileName := sDLLDirectory + cSelectionFileFamiliesFile;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSFileFamilies.FormActivate(Sender: TObject);
begin
  if FCreated then
    Exit;
  Application.ProcessMessages;
  Screen.Cursor := crHourGlass;
  FCreated := True;
  try
    FF_F := TIniFile.Create(FF_FileName);
  except
    BeepIfSet;
    MessageBox(Handle, PChar(Format(JVCSRES_JEDI_VCS_cannot_open_the_file46_40Invalid_path_or_access_denied4158 + #13#10 +
      '<%s>.' + #13#10 +
      JVCSRES_Make_sure_that_the_file_exists44_that_it_is_not_opened_by_another_application + #13#10 +
      JVCSRES_and_that_you_have_the_required_access_rights46, [FF_FileName])),
      cMsgBoxCaption, MB_OK or MB_ICONSTOP);
    btnOK.Enabled := False;
    Screen.Cursor := crDefault;
    Exit;
  end;
  ReadFF;
  Screen.Cursor := crDefault;
end;

//------------------------------------------------------------------------------

procedure TVCSFileFamilies.ReadFF;
var 
  I: Integer;
  CurrEntry: string;
  NewLVItem: TListItem;
begin
  for I := 0 to 9 do 
  begin
    CurrEntry := FF_F.ReadString('File Families', IntToStr(I), 'Not set');
    if CurrEntry <> 'Not set' then 
    begin
      NewLVItem := lvFileFamilies.Items.Add;
      NewLVItem.Caption := Copy(CurrEntry, 1, Pos('|', CurrEntry) - 1);
      NewLVItem.ImageIndex := 0;
      Delete(CurrEntry, 1, Pos('|', CurrEntry));
      NewLVItem.SubItems.Add(CurrEntry);
    end;
  end; // for I := 0 to 9 do begin
end;

//------------------------------------------------------------------------------

procedure TVCSFileFamilies.WriteFF;
var 
  CurrEntry: string;
  I: Integer;
begin
  for I := 0 to 9 do 
    FF_F.WriteString('File Families', IntToStr(I), 'Not set');
  with lvFileFamilies do 
  begin
    for I := 0 to Items.Count - 1 do 
    begin
      if (Items[I].Caption <> '') and (Items[I].SubItems[0] <> '') then
      begin
        CurrEntry := Items[I].Caption + '|' + Items[I].SubItems[0];
        FF_F.WriteString('File Families', IntToStr(I), CurrEntry);
      end 
      else 
        FF_F.WriteString('File Families', IntToStr(I), 'Not set');
    end; // for I := 0 to Items.Count - 1 do begin
  end; // with lvFileFamilies do begin
end;

//------------------------------------------------------------------------------

procedure TVCSFileFamilies.btnOKClick(Sender: TObject);
begin
  if lvFileFamilies.IsEditing then 
  begin
    lvFileFamilies.Selected.CancelEdit;
    Exit;
  end;
  WriteFF;
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSFileFamilies.btnCancelClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSFileFamilies.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  FF_F.Free;
end;

//------------------------------------------------------------------------------

procedure TVCSFileFamilies.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    btnCancel.Click;
    Key := 0;
  end;
  if Key = VK_F1 then 
  begin
    PerformHelpCommand(Application, IDH_Custom_select_modules);
  end;
  if spBtnAdd.Enabled and (Shift * [ssShift, ssAlt, ssCtrl] = [ssCtrl]) and (Chr(Key) in ['A', 'a']) then
    if (not CtrlSCDisabled(WindowHandle)) then
      spBtnAddClick(Self);
  if spBtnRemove.Enabled and (Shift * [ssShift, ssAlt, ssCtrl] = [ssCtrl]) and (Chr(Key) in ['R', 'r']) then
    if (not CtrlSCDisabled(WindowHandle)) then
      spBtnRemoveClick(Self);
end;

//------------------------------------------------------------------------------

procedure TVCSFileFamilies.spBtnAddClick(Sender: TObject);
var 
  NewItem: TListItem;
begin
  if lvFileFamilies.Items.Count = 10 then
  begin
    BeepIfSet;
    MessageBox(Handle, PChar(Format(JVCSRES_Max46_37d_entries_in_the_current_version46_Sorry46,
      [10])), cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
    Exit;
  end;
  NewItem := lvFileFamilies.Items.Add;
  NewItem.Caption := JVCSRES_Enter_caption;
  NewItem.SubItems.Add('');
  NewItem.ImageIndex := 0;
  lvFileFamilies.Selected := NewItem;
  NewItem.MakeVisible(True);
  //  lvFileFamiliesClick(self);
end;

//------------------------------------------------------------------------------

procedure TVCSFileFamilies.spBtnRemoveClick(Sender: TObject);
begin
  if lvFileFamilies.Selected = nil then 
    Exit;
  if MessageBox(WindowHandle, PChar(JVCSRES_Are_you_sure_you_want_to_delete_the_selected_items63),
    cMsgBoxCaption, MB_YESNOCANCEL or MB_ICONQUESTION) <> idYes then 
    Exit;
  lvFileFamilies.Selected.Delete;
end;

//------------------------------------------------------------------------------

procedure TVCSFileFamilies.spBtnEditClick(Sender: TObject);
var 
  CurrFilter: string;
  DlgResult: Integer;
begin
  if lvFileFamilies.Selected = nil then 
    Exit;
  CurrFilter := lvFileFamilies.Selected.SubItems[0];
  VCSListEdit := TVCSListEdit.Create(Application);
  try
    VCSListEdit.Left := Left + 40;
    VCSListEdit.Top := Top + 40;
    VCSListEdit.SetHint(JVCSRES_Edit_select_filter_extensions);
    VCSListEdit.EnablePathButton(False);
    VCSListEdit.ListString := CurrFilter;
    DlgResult := VCSListEdit.ShowModal;
    CurrFilter := VCSListEdit.ListString;
  finally
    VCSListEdit.Free;
  end;
  if DlgResult = mrOk then
    lvFileFamilies.Selected.SubItems[0] := CurrFilter;
end;

//------------------------------------------------------------------------------

procedure TVCSFileFamilies.spBtnClearAllClick(Sender: TObject);
begin
  if MessageBox(WindowHandle, PChar(JVCSRES_Are_you_sure_you_want_to_delete_all_items63),
    cMsgBoxCaption, MB_YESNOCANCEL or MB_DEFBUTTON2 or MB_ICONQUESTION) <> idYes then
    Exit;
  lvFileFamilies.Items.Clear;
end;

//------------------------------------------------------------------------------

procedure TVCSFileFamilies.HelpTopic1Click(Sender: TObject);
begin
  PerformHelpCommand(Application, IDH_Custom_select_modules);
end;

//------------------------------------------------------------------------------

procedure TVCSFileFamilies.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSFileFamilies.EditFilterCaption1Click(Sender: TObject);
begin
  if lvFileFamilies.Selected = nil then 
    Exit;
  lvFileFamilies.Selected.EditCaption;
end;

end.
