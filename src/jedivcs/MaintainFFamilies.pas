(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: MaintainFFamilies.pas

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
2003/08/08  THuber    - mantis #861: replaced TMemo with TJvMemo
                      - formstorage changed
                      - JEDI VCS
2004/02/24  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/30  USchuster - style cleaning
                      - use constant for messagebox caption
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/11/03  USchuster - moved resourcestrings to JVCSGUIClientResources.pas                      
2005/08/05  FHasovic  - Fixed run-time error when compiled with Delphi 2005
2007/06/17  USchuster - fixed self handled shortcuts
2007/07/01  USchuster - changes for large fonts (contraints size depend now on PixelsPerInch; analog to Mantis #3710)
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit MaintainFFamilies;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, Buttons, Menus, JvMemo, JvExStdCtrls, JVCSForms;

type
  TVCSMaintainFFamilies = class(TJVCSForm)
    lvFamilies: TListView;
    Splitter1: TSplitter;
    PopupMenu2: TPopupMenu;
    Add1: TMenuItem;
    Edit1: TMenuItem;
    Delete1: TMenuItem;
    N1: TMenuItem;
    Labelusedby1: TMenuItem;
    Panel3: TPanel;
    Panel1: TPanel;
    spBtnAdd: TSpeedButton;
    spBtnRemove: TSpeedButton;
    Help: TSpeedButton;
    btnCancel: TButton;
    btnOK: TButton;
    Panel2: TPanel;
    meDescr: TJvMemo;
    Panel4: TPanel;
    Label1: TLabel;
    edParent: TEdit;
    Label2: TLabel;
    edChild: TEdit;
    spBtnEditChild: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvFamiliesChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure lvFamiliesEdited(Sender: TObject; Item: TListItem;
      var S: string);
    procedure meDescrChange(Sender: TObject);
    procedure spBtnAddClick(Sender: TObject);
    procedure spBtnRemoveClick(Sender: TObject);
    procedure edParentChange(Sender: TObject);
    procedure edChildChange(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Labelusedby1Click(Sender: TObject);
    procedure Edit1Click(Sender: TObject);
    procedure PopupMenu2Popup(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure spBtnEditChildClick(Sender: TObject);
  private
    { Private declarations }
    FCreating: Boolean;
    procedure SaveChanges;
  public
    { Public declarations }
    LabelsChanged: Boolean;
  end;

var
  VCSMaintainFFamilies: TVCSMaintainFFamilies;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSBase, VCSProcBase, DBModule, AddNewFamily, Std_ListView, ListEdit,
  ConfigStorage, JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSMaintainFFamilies.FormCreate(Sender: TObject);
//thu 08.08.2003 var
//thu 08.08.2003   DlgWidth, DlgHeight: Integer;
begin
  try
    Constraints.MinHeight := MulDiv(225, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(285, PixelsPerInch, 96);
    FCreating := True;
    LabelsChanged := False;

    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    //thu 08.08.2003
    { 
    if not jvcsReadWindowSize(sBaseRegistryKey + crbWindows, 'MaintainFFamilies',
      DlgWidth, DlgHeight) then
    begin
      DlgWidth := 300;
      DlgHeight := 240;
    end;
    Width := DlgWidth;
    Height := DlgHeight;
     }

    Panel3.Height :=
      jvcsReadInteger(sBaseRegistryKey + crbWindows, 'MaintainFFamilies_Pn1', 125);

    {$IFNDEF SHOWIDS}
    lvFamilies.Columns[1].Width := 0;
    {$ENDIF ~SHOWIDS}
    Screen.Cursors[cPopUpMCursor] := LoadCursor(hInstance, PChar('CURSORRM'));
    lvFamilies.Cursor := cPopUpMCursor;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainFFamilies.FormActivate(Sender: TObject);
var
  LVItem: TListItem;
begin
  jvcsLoadFormPosSize(Self);  //thu 08.08.2003
  Application.ProcessMessages;
  if FCreating then 
  begin
    FCreating := False;
    with DataModule1 do 
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_FILE_FAMILIES';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [True]); // incl. descriprion
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
      lvFamilies.Items.BeginUpdate;
      try
        while (not AppSrvClient1.Answer.Eof) do
        begin
          LVItem := lvFamilies.Items.Add;
          LVItem.Caption := AppSrvClient1.Answer.Fields[1];
          LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[0]);
          LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[4]);
          LVItem.SubItems.Add('0');
          LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[2]);
          LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[3]);
          AppSrvClient1.Answer.Next;
        end; // while (not AppSrvClient1.Answer.EoF)
      finally
        lvFamilies.Items.EndUpdate;
      end;
      if lvFamilies.Items.Count > 0 then
        lvFamilies.Items[0].Selected := True;
    end; // with DataModule1 do begin
  end; // if FCreating then begin
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainFFamilies.SaveChanges;
var 
  I: Integer;
begin
  for I := 0 to lvFamilies.Items.Count - 1 do 
  begin
    if (lvFamilies.Items[I].SubItems[2] = '1') then 
    begin
      with DataModule1 do 
      begin
        AppSrvClient1.Request.Rewrite;
        AppSrvClient1.FunctionCode := 'ADD_UPDATE_FILE_FAMILIES';
        AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
        AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
        AppSrvClient1.Request.WriteFields(True,
          [lvFamilies.Items[I].SubItems[0]]);
        AppSrvClient1.Request.WriteFields(False,
          [lvFamilies.Items[I].Caption]);
        AppSrvClient1.Request.WriteFields(False,
          [lvFamilies.Items[I].SubItems[3]]);
        AppSrvClient1.Request.WriteFields(False,
          [lvFamilies.Items[I].SubItems[4]]);
        AppSrvClient1.Request.WriteFields(False,
          [lvFamilies.Items[I].SubItems[1]]);
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
      LabelsChanged := True;
    end; // if lvFamilies.Items[I].SubItems[2] := '1' then begin
  end; // for I := 0 to lvFamilies.Items.Count - do begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainFFamilies.btnOKClick(Sender: TObject);
begin
  if lvFamilies.IsEditing then 
  begin
    lvFamilies.Selected.CancelEdit;
    Exit;
  end;
  SaveChanges;
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainFFamilies.btnCancelClick(Sender: TObject);
var 
  Changed: Boolean;
  I, DlgResult: Integer;
begin
  Changed := False;
  for I := 0 to lvFamilies.Items.Count - 1 do
    if (lvFamilies.Items[I].SubItems[2] = '1') then 
    begin
      Changed := True;
      Break;
    end;
  if Changed then 
  begin
    DlgResult := MessageBox(WindowHandle, PChar(JVCSRES_You_have_made_changes_that_have_not_been_applied46 + #13#10 +
      JVCSRES_Do_you_want_to_apply_these_now63), cMsgBoxCaption,
      MB_YESNOCANCEL or MB_ICONQUESTION);
    case DlgResult of
      id_Yes: 
        SaveChanges;
      id_Cancel: 
        Exit;
    end;
  end;
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainFFamilies.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_File_families);
  if Key = VK_ESCAPE then 
  begin
    btnCancelClick(Self);
    Key := 0;
  end;    
  if spBtnAdd.Enabled and (Shift * [ssShift, ssAlt, ssCtrl] = [ssCtrl]) and (Chr(Key) in ['A', 'a']) then
    if (not CtrlSCDisabled(WindowHandle)) then
      spBtnAddClick(Self);
  if spBtnRemove.Enabled and (Shift * [ssShift, ssAlt, ssCtrl] = [ssCtrl]) and (Chr(Key) in ['R', 'r']) then
    if (not CtrlSCDisabled(WindowHandle)) then 
      spBtnRemoveClick(Self);  
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainFFamilies.lvFamiliesChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
begin
  if lvFamilies.Selected = nil then 
    Exit;
  meDescr.Text := lvFamilies.Selected.SubItems[1];
  edParent.Text := lvFamilies.Selected.SubItems[3];
  edChild.Text := lvFamilies.Selected.SubItems[4];
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainFFamilies.lvFamiliesEdited(Sender: TObject;
  Item: TListItem; var S: string);
begin
  if lvFamilies.Selected = nil then 
    Exit;
  Item.SubItems[2] := '1';
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainFFamilies.meDescrChange(Sender: TObject);
begin
  if (lvFamilies.Selected = nil) or
    (lvFamilies.Selected.SubItems[1] = meDescr.Text) then 
    Exit;
  lvFamilies.Selected.SubItems[1] := meDescr.Text;
  lvFamilies.Selected.SubItems[2] := '1';
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainFFamilies.edParentChange(Sender: TObject);
begin
  if (lvFamilies.Selected = nil) or
    (lvFamilies.Selected.SubItems[3] = edParent.Text) then 
    Exit;
  lvFamilies.Selected.SubItems[3] := edParent.Text;
  lvFamilies.Selected.SubItems[2] := '1';
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainFFamilies.edChildChange(Sender: TObject);
begin
  if (lvFamilies.Selected = nil) or
    (lvFamilies.Selected.SubItems[4] = edChild.Text) then 
    Exit;
  lvFamilies.Selected.SubItems[4] := edChild.Text;
  lvFamilies.Selected.SubItems[2] := '1';
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainFFamilies.spBtnAddClick(Sender: TObject);
var 
  NewFamilyName, NewFamilyDescr, NewFamilyParent, NewFamilyChilds, NewFamilyID: string;
  LVItem: TListItem;
begin
  VCSAddFamily := TVCSAddFamily.Create(Application);
  try
    VCSAddFamily.Left := Left + 40;
    VCSAddFamily.Top := Top + 40;
    VCSAddFamily.ShowModal;
    NewFamilyName := VCSAddFamily.FamilyName;
    NewFamilyParent := VCSAddFamily.FamilyParent;
    NewFamilyChilds := VCSAddFamily.FamilyChilds;
    NewFamilyDescr := VCSAddFamily.FamilyDescr;
  finally
    VCSAddFamily.Free;
  end;
  if NewFamilyName <> '' then 
  begin
    NewFamilyID := '';
    with DataModule1 do 
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'ADD_UPDATE_FILE_FAMILIES';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [0]);
      AppSrvClient1.Request.WriteFields(False, [NewFamilyName]);
      AppSrvClient1.Request.WriteFields(False, [NewFamilyParent]);
      AppSrvClient1.Request.WriteFields(False, [NewFamilyChilds]);
      AppSrvClient1.Request.WriteFields(False, [NewFamilyDescr]);
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

      if DecodeBoolStr(AppSrvClient1.Answer.Fields[0]) then
        NewFamilyID := AppSrvClient1.Answer.Fields[1];
    end; // with DataModule1 do begin
    if NewFamilyID <> '' then 
    begin
      LVItem := lvFamilies.Items.Add;
      LVItem.Caption := NewFamilyName;
      LVItem.SubItems.Add(NewFamilyID);
      LVItem.SubItems.Add(NewFamilyDescr);
      LVItem.SubItems.Add('0');
      LVItem.SubItems.Add(NewFamilyParent);
      LVItem.SubItems.Add(NewFamilyChilds);
      LabelsChanged := True;
    end;
  end; // if NewFamilyName <> '' then begin
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainFFamilies.spBtnRemoveClick(Sender: TObject);
var 
  Msg: string;
begin
  if lvFamilies.Selected = nil then 
    Exit;
  if MessageBox(WindowHandle, PChar(Format(JVCSRES_Are_you_sure_you_want_to_remove_family_6037s62_from_the_archive63,
    [lvFamilies.Selected.Caption]) + #13#10 + JVCSRES_Warning33_This_process_is_not_reversible46),
    cMsgBoxCaption, MB_YESNOCANCEL or MB_DEFBUTTON2 or MB_ICONWARNING) <> id_Yes then 
    Exit;

  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'FAMILY_USED_BY';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [lvFamilies.Selected.SubItems[0]]);
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
    begin
      Msg := JVCSRES_There_are_already_modules_in_the_archive_checked_in_by_this_family_ID46 +
        #10#13 + JVCSRES_Access_denied46;
      MessageBox(WindowHandle, PChar(Msg), cMsgBoxCaption, MB_OK or MB_ICONWARNING);
      Exit;
    end; // if not AppSrvClient1.Answer.EoF then begin
  end; // with DataModule1 do begin

  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'REMOVE_FILE_FAMILIES';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [lvFamilies.Selected.SubItems[0]]);
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
  lvFamilies.Selected.Delete;
  edParent.Text := '';
  edChild.Text := '';
  meDescr.Text := '';
  LabelsChanged := True;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainFFamilies.FormResize(Sender: TObject);
begin
  {$IFNDEF SHOWIDS}
  if lvFamilies.HandleAllocated then
    lvFamilies.Columns[0].Width := Width - 35;
  {$ENDIF ~SHOWIDS}
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainFFamilies.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  //thu 08.08.2003
  { 
  jvcsWriteWindowSize(sBaseRegistryKey + crbWindows, 'MaintainFFamilies',
    Width, Height);
   }
  jvcsSaveFormPosSize(Self);

  jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'MaintainFFamilies_Pn1',
    Panel3.Height);
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainFFamilies.Labelusedby1Click(Sender: TObject);
var
  ResultString: string;
  ContainsRecords: Boolean;
begin
  if lvFamilies.Selected = nil then 
    Exit;
  ContainsRecords := False;
  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'FAMILY_USED_BY';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [lvFamilies.Selected.SubItems[0]]);
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
      ContainsRecords := True;
      ResultString := ResultString + AppSrvClient1.Answer.Fields[1] + ';' +
        AppSrvClient1.Answer.Fields[0] + ';|';
      AppSrvClient1.Answer.Next;
    end;
  end; // with DataModule1 do begin

  if not ContainsRecords then 
  begin
    MessageBox(Handle, PChar(Format(JVCSRES_There_were_no_37s_located_that_match_the_search_criteria46,
      [JVCSRES_records])), cMsgBoxCaption, MB_OK or
      MB_ICONINFORMATION);
    Exit;
  end;

  VCSStdListView := TVCSStdListView.Create(Application);
  try
    VCSStdListView.LVRepID := 4;
    VCSStdListView.Caption := lvFamilies.Selected.Caption;
    VCSStdListView.Left := Left + 60;
    VCSStdListView.Top := Top + 60;
    VCSStdListView.LVType := 0;
    VCSStdListView.HelpContextID := 0;    
    VCSStdListView.AddListColumn(JVCSRES_Modules_checked_in_by464646, False);
    VCSStdListView.AddListColumn(JVCSRES_ID, True);
    VCSStdListView.SetUpItems(ResultString);
    VCSStdListView.ShowModal;
  finally
    VCSStdListView.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainFFamilies.Edit1Click(Sender: TObject);
begin
  if lvFamilies.Selected = nil then 
    Exit;
  lvFamilies.Selected.EditCaption;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainFFamilies.PopupMenu2Popup(Sender: TObject);
begin
  Edit1.Enabled := lvFamilies.Selected <> nil;
  Delete1.Enabled := lvFamilies.Selected <> nil;
  Labelusedby1.Enabled := lvFamilies.Selected <> nil;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainFFamilies.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyUp(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainFFamilies.spBtnEditChildClick(Sender: TObject);
var 
  DlgResult: Integer;
  EditString: string;
begin
  EditString := edChild.Text;
  VCSListEdit := TVCSListEdit.Create(Application);
  try
    VCSListEdit.Left := Left + 40;
    VCSListEdit.Top := Top + 40;
    VCSListEdit.SetHint(JVCSRES_Child_extensions);
    VCSListEdit.EnablePathButton(False);
    VCSListEdit.ListString := EditString;
    DlgResult := VCSListEdit.ShowModal;
    EditString := VCSListEdit.ListString;
  finally
    VCSListEdit.Free;
  end;
  if DlgResult = mrOk then
    edChild.Text := EditString;
end;

end.
