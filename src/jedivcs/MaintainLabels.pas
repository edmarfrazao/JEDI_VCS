(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: MaintainLabels.pas

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

unit MaintainLabels;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, Buttons, Menus, JvMemo, JvExStdCtrls, JVCSForms;

type
  TVCSMaintainLabels = class(TJVCSForm)
    lvLabels: TListView;
    Splitter1: TSplitter;
    PopupMenu1: TPopupMenu;
    Labelusedby1: TMenuItem;
    Edit1: TMenuItem;
    N1: TMenuItem;
    Add1: TMenuItem;
    Delete1: TMenuItem;
    Panel2: TPanel;
    Panel1: TPanel;
    spBtnAdd: TSpeedButton;
    spBtnRemove: TSpeedButton;
    Help: TSpeedButton;
    btnCancel: TButton;
    btnOK: TButton;
    meLabelDescr: TJvMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvLabelsChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure lvLabelsEdited(Sender: TObject; Item: TListItem;
      var S: string);
    procedure meLabelDescrChange(Sender: TObject);
    procedure spBtnAddClick(Sender: TObject);
    procedure spBtnRemoveClick(Sender: TObject);
    procedure Edit1Click(Sender: TObject);
    procedure Labelusedby1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure HelpClick(Sender: TObject);
  private
    { Private declarations }
    FCreating: Boolean;
    procedure SaveChanges;
  public
    { Public declarations }
    LabelsChanged: Boolean;
  end;

var
  VCSMaintainLabels: TVCSMaintainLabels;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSBase, VCSProcBase, DBModule, AddNewLabel, Std_ListView, ConfigStorage,
  JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSMaintainLabels.FormCreate(Sender: TObject);
//thu 08.08.2003 var
//thu 08.08.2003   DlgWidth, DlgHeight: Integer;
begin
  try
    Constraints.MinHeight := MulDiv(220, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(285, PixelsPerInch, 96); 
    FCreating := True;
    LabelsChanged := False;

    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    //thu 08.08.2003
    { 
    if not jvcsReadWindowSize(sBaseRegistryKey + crbWindows, 'MaintainLabels',
      DlgWidth, DlgHeight) then
    begin
      DlgWidth := 285;
      DlgHeight := 220;
    end;
    Width := DlgWidth;
    Height := DlgHeight;
     }

    Panel2.Height :=
      jvcsReadInteger(sBaseRegistryKey + crbWindows, 'MaintainLabels_Pn1', 85);

    {$IFNDEF SHOWIDS}
    lvLabels.Columns[1].Width := 0;
    {$ENDIF ~SHOWIDS}
    Screen.Cursors[cPopUpMCursor] := LoadCursor(hInstance, PChar('CURSORRM'));
    lvLabels.Cursor := cPopUpMCursor;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainLabels.FormActivate(Sender: TObject);
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
      AppSrvClient1.FunctionCode := 'GET_LABELS';
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
      lvLabels.Items.BeginUpdate;
      try
        while (not AppSrvClient1.Answer.Eof) do
        begin
          LVItem := lvLabels.Items.Add;
          LVItem.Caption := AppSrvClient1.Answer.Fields[1];
          LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[0]);
          LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[2]);
          LVItem.SubItems.Add('0');
          AppSrvClient1.Answer.Next;
        end; // while (not AppSrvClient1.Answer.EoF)
      finally
        lvLabels.Items.EndUpdate;
      end;
      if lvLabels.Items.Count > 0 then
        lvLabels.Items[0].Selected := True;
    end; // with DataModule1 do begin
  end; // if FCreating then begin
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainLabels.SaveChanges;
var 
  I: Integer;
begin
  for I := 0 to lvLabels.Items.Count - 1 do 
  begin
    if (lvLabels.Items[I].SubItems[2] = '1') then 
    begin
      with DataModule1 do 
      begin
        AppSrvClient1.Request.Rewrite;
        AppSrvClient1.FunctionCode := 'ADD_UPDATE_LABEL';
        AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
        AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
        AppSrvClient1.Request.WriteFields(True, [lvLabels.Items[I].SubItems[0]]);
        AppSrvClient1.Request.WriteFields(False, [lvLabels.Items[I].Caption]);
        AppSrvClient1.Request.WriteFields(False, [lvLabels.Items[I].SubItems[1]]);
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
    end; // if lvLabels.Items[I].SubItems[2] := '1' then begin
  end; // for I := 0 to lvLabels.Items.Count - do begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainLabels.btnOKClick(Sender: TObject);
begin
  if lvLabels.IsEditing then 
  begin
    lvLabels.Selected.CancelEdit;
    Exit;
  end;
  SaveChanges;
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainLabels.btnCancelClick(Sender: TObject);
var
  Changed: Boolean;
  I, DlgResult: Integer;
begin
  Changed := False;
  for I := 0 to lvLabels.Items.Count - 1 do
    if (lvLabels.Items[I].SubItems[2] = '1') then 
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

procedure TVCSMaintainLabels.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Keywords);
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

procedure TVCSMaintainLabels.lvLabelsChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
begin
  if lvLabels.Selected = nil then 
    Exit;
  meLabelDescr.Text := lvLabels.Selected.SubItems[1];
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainLabels.lvLabelsEdited(Sender: TObject;
  Item: TListItem; var S: string);
begin
  if lvLabels.Selected = nil then 
    Exit;
  lvLabels.Selected.SubItems[2] := '1';
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainLabels.meLabelDescrChange(Sender: TObject);
begin
  if (lvLabels.Selected = nil) or
    (lvLabels.Selected.SubItems[1] = meLabelDescr.Text) then 
    Exit;
  lvLabels.Selected.SubItems[1] := meLabelDescr.Text;
  lvLabels.Selected.SubItems[2] := '1';
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainLabels.spBtnAddClick(Sender: TObject);
var 
  NewLabelName, NewLabelDescr, NewLabelID: string;
  LVItem: TListItem;
begin
  VCSAddLabel := TVCSAddLabel.Create(Application);
  try
    VCSAddLabel.Left := Left + 40;
    VCSAddLabel.Top := Top + 40;
    VCSAddLabel.ShowModal;
    NewLabelName := VCSAddLabel.LabelName;
    NewLabelDescr := VCSAddLabel.LabelDescr;
  finally
    VCSAddLabel.Free;
  end;
  if NewLabelName <> '' then 
  begin
    NewLabelID := '';
    with DataModule1 do 
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'ADD_UPDATE_LABEL';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [0]);
      AppSrvClient1.Request.WriteFields(False, [NewLabelName]);
      AppSrvClient1.Request.WriteFields(False, [NewLabelDescr]);
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
        NewLabelID := AppSrvClient1.Answer.Fields[1];
    end; // with DataModule1 do begin
    if NewLabelID <> '' then 
    begin
      LVItem := lvLabels.Items.Add;
      LVItem.Caption := NewLabelName;
      LVItem.SubItems.Add(NewLabelID);
      LVItem.SubItems.Add(NewLabelDescr);
      LVItem.SubItems.Add('0');
      LabelsChanged := True;
    end;
  end; // if NewLabelName <> '' then begin
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainLabels.spBtnRemoveClick(Sender: TObject);
var 
  Msg: string;
begin
  if lvLabels.Selected = nil then 
    Exit;
  if MessageBox(WindowHandle, PChar(Format(JVCSRES_Are_you_sure_you_want_to_remove_label_6037s62_from_the_archive63,
    [lvLabels.Selected.Caption]) + #13#10 + JVCSRES_Warning33_This_process_is_not_reversible46)
    , cMsgBoxCaption, MB_YESNOCANCEL or MB_DEFBUTTON2 or MB_ICONWARNING) <> id_Yes then
    Exit;

  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'REMOVE_LABEL';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [lvLabels.Selected.SubItems[0]]);
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

    if not DecodeBoolStr(AppSrvClient1.Answer.Fields[0]) then 
    begin
      BeepIfSet;
      Msg := Format(JVCSRES_Label_6037s62_is_already_in_use_by_some_revisions46,
        [lvLabels.Selected.Caption]) + #10#13 + JVCSRES_Access_denied46;
      MessageBox(Handle, PChar(Msg), cMsgBoxCaption, MB_OK or MB_ICONWARNING);
      Labelusedby1Click(Self);
      Exit;
    end;
  end; // with DataModule1 do begin
  lvLabels.Selected.Delete;
  meLabelDescr.Text := '';
  LabelsChanged := True;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainLabels.Edit1Click(Sender: TObject);
begin
  if lvLabels.Selected = nil then 
    Exit;
  lvLabels.Selected.EditCaption;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainLabels.Labelusedby1Click(Sender: TObject);
var 
  ResultString: string;
  ContainsRecords: Boolean;
begin
  if lvLabels.Selected = nil then 
    Exit;
  ContainsRecords := False;
  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'LABEL_USED_BY';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [lvLabels.Selected.SubItems[0]]);
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
      ResultString := ResultString + AppSrvClient1.Answer.Fields[0] + ';' +
        AppSrvClient1.Answer.Fields[1] + ';' +
        AppSrvClient1.Answer.Fields[2] + ';|';
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
    VCSStdListView.LVRepID := 5;
    VCSStdListView.Caption := lvLabels.Selected.Caption;
    VCSStdListView.Left := Left + 60;
    VCSStdListView.Top := Top + 60;
    VCSStdListView.LVType := 7;
    VCSStdListView.HelpContextID := IDH_Keywords;
    VCSStdListView.AddListColumn(JVCSRES_Modules_using_the_label, False);
    VCSStdListView.AddListColumn(JVCSRES_Version, True);
    VCSStdListView.AddListColumn(JVCSRES_Revision, True);
    VCSStdListView.SetUpItems(ResultString);
    VCSStdListView.ShowModal;
  finally
    VCSStdListView.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainLabels.FormResize(Sender: TObject);
begin
  {$IFNDEF SHOWIDS}
  if lvLabels.HandleAllocated then
    lvLabels.Columns[0].Width := Width - 35;
  {$ENDIF ~SHOWIDS}
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainLabels.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  //thu 08.08.2003
  { 
  jvcsWriteWindowSize(sBaseRegistryKey + crbWindows, 'MaintainLabels',
    Width, Height);
   }
  jvcsSaveFormPosSize(Self);

  jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'MaintainLabels_Pn1',
    Panel2.Height);
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainLabels.PopupMenu1Popup(Sender: TObject);
begin
  Edit1.Enabled := lvLabels.Selected <> nil;
  Delete1.Enabled := lvLabels.Selected <> nil;
  Labelusedby1.Enabled := lvLabels.Selected <> nil;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainLabels.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyUp(Self, HelpKey, []);
end;

end.
