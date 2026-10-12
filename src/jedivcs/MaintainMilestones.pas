(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: MaintainMilestones.pas

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

unit MaintainMilestones;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, Buttons, Menus, JvMemo, JvExStdCtrls, JVCSForms;

type
  TVCSMaintainMilestones = class(TJVCSForm)
    lvMilestones: TListView;
    Splitter1: TSplitter;
    PopupMenu2: TPopupMenu;
    Add1: TMenuItem;
    Panel2: TPanel;
    meDescr: TJvMemo;
    PopupMenu1: TPopupMenu;
    RemoveMilestone1: TMenuItem;
    Panel3: TPanel;
    spBtnInc: TSpeedButton;
    spBtnDec: TSpeedButton;
    Label1: TLabel;
    edName: TEdit;
    Panel1: TPanel;
    spBtnAdd: TSpeedButton;
    spBtnRemove: TSpeedButton;
    Help: TSpeedButton;
    btnCancel: TButton;
    btnOK: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvMilestonesChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure meDescrChange(Sender: TObject);
    procedure spBtnAddClick(Sender: TObject);
    procedure spBtnRemoveClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Edit1Click(Sender: TObject);
    procedure edNameChange(Sender: TObject);
    procedure spBtnIncClick(Sender: TObject);
    procedure spBtnDecClick(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure lvMilestonesCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
  private
    { Private declarations }
    FCreating: Boolean;
    function GetNewMilestoneOrder: Integer;
    procedure ReOrderMilestones;
    procedure SaveChanges;
  public
    { Public declarations }
    LabelsChanged: Boolean;
  end;

var
  VCSMaintainMilestones: TVCSMaintainMilestones;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSBase, VCSProcBase, DBModule, AddNewMilestone, ConfigStorage, JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSMaintainMilestones.FormCreate(Sender: TObject);
begin
  try
    Constraints.MinHeight := MulDiv(225, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(285, PixelsPerInch, 96);
    FCreating := True;
    LabelsChanged := False;

    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    Panel2.Height :=
      jvcsReadInteger(sBaseRegistryKey + crbWindows, 'MaintainMilestones_Pn1', 130);

    {$IFNDEF SHOWIDS}
    lvMilestones.Columns[2].Width := 0;
    {$ENDIF ~SHOWIDS}
    Screen.Cursors[cPopUpMCursor] := LoadCursor(hInstance, PChar('CURSORRM'));
    lvMilestones.Cursor := cPopUpMCursor;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainMilestones.FormActivate(Sender: TObject);
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
      AppSrvClient1.FunctionCode := 'GET_MILESTONES';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
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
      lvMilestones.Items.BeginUpdate;
      try
        while (not AppSrvClient1.Answer.Eof) do
        begin
          LVItem := lvMilestones.Items.Add;
          LVItem.Caption := AppSrvClient1.Answer.Fields[1];
          LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[2]);
          LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[0]);
          LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[3]);
          LVItem.SubItems.Add('0');
          AppSrvClient1.Answer.Next;
        end; // while (not AppSrvClient1.Answer.EoF)
      finally
        lvMilestones.Items.EndUpdate;
      end;
      if lvMilestones.Items.Count > 0 then
        lvMilestones.Items[0].Selected := True;
    end; // with DataModule1 do begin
  end; // if FCreating then begin
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainMilestones.SaveChanges;
var 
  I: Integer;
begin
  for I := 0 to lvMilestones.Items.Count - 1 do 
  begin
    if (lvMilestones.Items[I].SubItems[3] = '1') then 
    begin
      with DataModule1 do 
      begin
        AppSrvClient1.Request.Rewrite;
        AppSrvClient1.FunctionCode := 'ADD_UPDATE_MILESTONES';
        AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
        AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
        AppSrvClient1.Request.WriteFields(True,
          [lvMilestones.Items[I].SubItems[1]]);
        AppSrvClient1.Request.WriteFields(False,
          [lvMilestones.Items[I].Caption]);
        AppSrvClient1.Request.WriteFields(False,
          [lvMilestones.Items[I].SubItems[0]]);
        AppSrvClient1.Request.WriteFields(False,
          [lvMilestones.Items[I].SubItems[2]]);
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
    end; // if lvMilestones.Items[I].SubItems[2] := '1' then begin
  end; // for I := 0 to lvMilestones.Items.Count - do begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainMilestones.btnOKClick(Sender: TObject);
begin
  if lvMilestones.IsEditing then 
  begin
    lvMilestones.Selected.CancelEdit;
    Exit;
  end;
  SaveChanges;
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainMilestones.btnCancelClick(Sender: TObject);
var 
  Changed: Boolean;
  I, DlgResult: Integer;
begin
  Changed := False;
  for I := 0 to lvMilestones.Items.Count - 1 do
    if (lvMilestones.Items[I].SubItems[3] = '1') then 
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
      id_Cancel :
        Exit;
    end;
  end;
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainMilestones.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Milestones);
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

procedure TVCSMaintainMilestones.lvMilestonesChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
begin
  if lvMilestones.Selected = nil then 
    Exit;
  meDescr.Text := lvMilestones.Selected.SubItems[2];
  edName.Text := lvMilestones.Selected.SubItems[0];
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainMilestones.edNameChange(Sender: TObject);
begin
  if (lvMilestones.Selected = nil) or
    (lvMilestones.Selected.SubItems[0] = edName.Text) then 
    Exit;
  lvMilestones.Selected.SubItems[0] := edName.Text;
  lvMilestones.Selected.SubItems[3] := '1';
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainMilestones.meDescrChange(Sender: TObject);
begin
  if (lvMilestones.Selected = nil) or
    (lvMilestones.Selected.SubItems[2] = meDescr.Text) then 
    Exit;
  lvMilestones.Selected.SubItems[2] := meDescr.Text;
  lvMilestones.Selected.SubItems[3] := '1';
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainMilestones.spBtnIncClick(Sender: TObject);
var 
  CurrentOrder: Integer;
begin
  if (lvMilestones.Selected = nil) or
    (lvMilestones.Selected.Index >= (lvMilestones.Items.Count - 1)) then 
    Exit;
  CurrentOrder := _StrToInt(lvMilestones.Selected.Caption);
  try
    lvMilestones.Items[lvMilestones.Selected.Index + 1].Caption :=
      IntToStr(CurrentOrder);
    lvMilestones.Selected.Caption := IntToStr(CurrentOrder + 1);
    lvMilestones.Selected.SubItems[3] := '1';
    lvMilestones.Items[lvMilestones.Selected.Index + 1].SubItems[3] := '1';
    lvMilestones.AlphaSort;
  except
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainMilestones.spBtnDecClick(Sender: TObject);
var 
  CurrentOrder: Integer;
begin
  if (lvMilestones.Selected = nil) or
    (lvMilestones.Selected.Index < 1) then 
    Exit;
  CurrentOrder := _StrToInt(lvMilestones.Selected.Caption);
  try
    lvMilestones.Items[lvMilestones.Selected.Index - 1].Caption :=
      IntToStr(CurrentOrder);
    lvMilestones.Selected.Caption := IntToStr(CurrentOrder - 1);
    lvMilestones.Selected.SubItems[3] := '1';
    lvMilestones.Items[lvMilestones.Selected.Index - 1].SubItems[3] := '1';
    lvMilestones.AlphaSort;
  except
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainMilestones.ReOrderMilestones;
var
  I: Integer;
begin
  for I := 0 to lvMilestones.Items.Count - 1 do 
  begin
    lvMilestones.Items[I].Caption := IntToStr(I + 1);
    lvMilestones.Items[I].SubItems[3] := '1';
  end; // for I := 0 to lvMilestones.Items.Count - 1 do begin
end;

//------------------------------------------------------------------------------

function TVCSMaintainMilestones.GetNewMilestoneOrder: Integer;
var 
  I, MaxOrder: Integer;
begin
  MaxOrder := -1;
  for I := 0 to lvMilestones.Items.Count - 1 do
    if _StrToInt(lvMilestones.Items[I].Caption) > MaxOrder then
      MaxOrder := _StrToInt(lvMilestones.Items[I].Caption);
  Result := MaxOrder + 1;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainMilestones.spBtnAddClick(Sender: TObject);
var 
  NewMilestone, NewMilestoneDescr, NewMilestoneName, NewMilestoneID: string;
  LVItem: TListItem;
begin
  VCSAddMilestone := TVCSAddMilestone.Create(Application);
  try
    VCSAddMilestone.Left := Left + 40;
    VCSAddMilestone.Top := Top + 40;
    VCSAddMilestone.ShowModal;
    NewMilestoneName := VCSAddMilestone.MilestoneName;
    NewMilestoneDescr := VCSAddMilestone.MilestoneDescr;
  finally
    VCSAddMilestone.Free;
  end;
  if NewMilestoneName <> '' then 
  begin
    NewMilestone := IntToStr(GetNewMilestoneOrder);
    NewMilestoneID := '';
    with DataModule1 do 
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'ADD_UPDATE_MILESTONES';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [0]);
      AppSrvClient1.Request.WriteFields(False, [NewMilestone]);
      AppSrvClient1.Request.WriteFields(False, [NewMilestoneName]);
      AppSrvClient1.Request.WriteFields(False, [NewMilestoneDescr]);
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
        NewMilestoneID := AppSrvClient1.Answer.Fields[1];
    end; // with DataModule1 do begin
    if NewMilestoneID <> '' then 
    begin
      LVItem := lvMilestones.Items.Add;
      LVItem.Caption := NewMilestone;
      LVItem.SubItems.Add(NewMilestoneName);
      LVItem.SubItems.Add(NewMilestoneID);
      LVItem.SubItems.Add(NewMilestoneDescr);
      LVItem.SubItems.Add('0');
      LabelsChanged := True;
    end;
    Application.ProcessMessages;
    ReOrderMilestones;
  end; // if NewMilestoneName <> '' then begin
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainMilestones.spBtnRemoveClick(Sender: TObject);
begin
  if lvMilestones.Selected = nil then
    Exit;
  if MessageBox(WindowHandle, PChar(Format(JVCSRES_Are_you_sure_you_want_to_remove_milestone_6037s62_from_the_archive63,
    [lvMilestones.Selected.SubItems[0]]) + #13#10 + JVCSRES_Warning33_This_process_is_not_reversible46),
    cMsgBoxCaption, MB_YESNOCANCEL or MB_DEFBUTTON2 or MB_ICONWARNING) <> id_Yes then
    Exit;

  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'REMOVE_MILESTONE';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True,
      [lvMilestones.Selected.SubItems[1]]);
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
  lvMilestones.Selected.Delete;
  meDescr.Text := '';
  LabelsChanged := True;
  Application.ProcessMessages;
  ReOrderMilestones;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainMilestones.FormResize(Sender: TObject);
begin
  {$IFNDEF SHOWIDS}
  if lvMilestones.HandleAllocated then
    lvMilestones.Columns[1].Width := Width - lvMilestones.Columns[0].Width - 35;
  {$ENDIF ~SHOWIDS}
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainMilestones.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  jvcsSaveFormPosSize(Self);

  jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'MaintainMilestones_Pn1',
    Panel2.Height);
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainMilestones.Edit1Click(Sender: TObject);
begin
  if lvMilestones.Selected = nil then
    Exit;
  lvMilestones.Selected.EditCaption;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainMilestones.HelpClick(Sender: TObject);
var
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyUp(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainMilestones.lvMilestonesCompare(Sender: TObject;
  Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
var
  ItemStr1, ItemStr2: string;
begin
  ItemStr1 := Item1.Caption;
  ItemStr2 := Item2.Caption;
  while Length(ItemStr1) < 4 do
    ItemStr1 := '0' + ItemStr1;
  while Length(ItemStr2) < 4 do
    ItemStr2 := '0' + ItemStr2;
  Compare := AnsiCompareStr(ItemStr1, ItemStr2);
end;

end.
