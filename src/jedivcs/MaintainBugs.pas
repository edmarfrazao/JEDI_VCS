(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: MaintainBugs.pas

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
2003/03/08  USchuster - exchanged THistoryList with TJVCSMruList (mantis #727)
2003/03/15  THuber    - hints & warnings removed
2003/05/19  MGosselink- Added the Items of the Level component
2003/08/08  THuber    - mantis #861: replaced TMemo with TJvMemo
                      - formstorage changed
                      - JEDI VCS
2004/02/24  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/02/26  USchuster - reassigned dropped imagelist to TJvImageComboBox
                      - now with constant for message box caption
                      - minor style cleaning (casing and comments)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/30  USchuster - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/11/03  USchuster - moved resourcestrings to JVCSGUIClientResources.pas                      
2005/08/05  FHasovic  - Fixed run-time error when compiled with Delphi 2005
2007/06/17  USchuster - fixed self handled shortcuts
2007/07/01  USchuster - changes for large fonts (contraints size depend now on PixelsPerInch; analog to Mantis #3710)
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit MaintainBugs;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, Buttons, Menus, ImgList, JvListComb, JvMemo,
  JvExStdCtrls, JvCombobox, JVCSForms;

type
  TVCSMaintainBugs = class(TJVCSForm)
    lvBugs: TListView;
    Splitter1: TSplitter;
    Panel2: TPanel;
    meDescr: TJvMemo;
    PopupMenu2: TPopupMenu;
    Add1: TMenuItem;
    Edit1: TMenuItem;
    Delete1: TMenuItem;
    N1: TMenuItem;
    Labelusedby1: TMenuItem;
    StateImageList: TImageList;
    Report1: TMenuItem;
    N2: TMenuItem;
    SearchProjectforKeywords1: TMenuItem;
    Panel1: TPanel;
    spBtnAdd: TSpeedButton;
    spBtnRemove: TSpeedButton;
    Help: TSpeedButton;
    spBtnImport: TSpeedButton;
    btnCancel: TButton;
    btnOK: TButton;
    Panel3: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    rbDescription: TRadioButton;
    rbWorkaround: TRadioButton;
    edReported: TEdit;
    edKeywords: TEdit;
    Label4: TLabel;
    cbxState: TComboBox;
    icbLevel: TJvImageComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvBugsChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure lvBugsEdited(Sender: TObject; Item: TListItem;
      var S: string);
    procedure meDescrChange(Sender: TObject);
    procedure spBtnAddClick(Sender: TObject);
    procedure spBtnRemoveClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Labelusedby1Click(Sender: TObject);
    procedure PopupMenu2Popup(Sender: TObject);
    procedure Edit1Click(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure Report1Click(Sender: TObject);
    procedure edKeywordsChange(Sender: TObject);
    procedure edReportedChange(Sender: TObject);
    procedure rbDescriptionClick(Sender: TObject);
    procedure cbxStateChange(Sender: TObject);
    procedure SearchProjectforKeywords1Click(Sender: TObject);
    procedure icbLevelChange(Sender: TObject);
    procedure spBtnImportClick(Sender: TObject);
  private
    { Private declarations }
    FCreating: Boolean;
    procedure ReadBugList;
    procedure AddNewBug(BugName, BugKeywords, ReportedBy, Workaround,
      BugDescr: string; Status, Severity: Integer; var NewBugID: Integer);
    function AddProjectBug(ItemID, NewBugID: Integer): Boolean;
    function CheckChanges: Boolean;
    procedure SaveChanges;
  public
    { Public declarations }
    ArchiveBugsChanged: Boolean;
  end;


var
  VCSMaintainBugs: TVCSMaintainBugs;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSBase, VCSProcBase, DBModule, Std_ListView, SimpleReport, AddNewBug,
  FavOpenDialog, Yes2allDlg, ConfigStorage, JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSMaintainBugs.FormCreate(Sender: TObject);
var
  I: Integer;
//thu 08.08.2003   DlgWidth, DlgHeight: Integer;
begin
  try
    Constraints.MinHeight := MulDiv(225, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(295, PixelsPerInch, 96);
    FCreating := True;
    ArchiveBugsChanged := False;

    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    //thu 08.08.2003
    { 
    if not jvcsReadWindowSize(sBaseRegistryKey + crbWindows, 'MaintainBugs',
      DlgWidth, DlgHeight) then
    begin
      DlgWidth := 300;
      DlgHeight := 330;
    end;
    Width := DlgWidth;
    Height := DlgHeight;
     }

    Panel2.Height :=
      jvcsReadInteger(sBaseRegistryKey + crbWindows, 'MaintainBugs_Pn1', 190);

    {$IFNDEF SHOWIDS}
    lvBugs.Columns[1].Width := 0;
    {$ENDIF ~SHOWIDS}
    for I := 0 to icbLevel.Items.Count - 1 do
    begin
      icbLevel.Items[I].ImageIndex := I;
      // --hu icbLevel.SelectedIndex[I] := I;
    end;

    Screen.Cursors[cPopUpMCursor] := LoadCursor(hInstance, PChar('CURSORRM'));
    lvBugs.Cursor := cPopUpMCursor;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainBugs.FormActivate(Sender: TObject);
begin
  jvcsLoadFormPosSize(Self);  //thu 08.08.2003
  Application.ProcessMessages;
  if FCreating then 
  begin
    FCreating := False;
    ReadBugList;
  end; // if FCreating then begin
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainBugs.ReadBugList;
var 
  LVItem: TListItem;
begin
  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_BUGS';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [True]); // incl. Descr.
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
    lvBugs.Items.BeginUpdate;
    try
      lvBugs.Items.Clear;
      while (not AppSrvClient1.Answer.Eof) do 
      begin
        LVItem := lvBugs.Items.Add;
        // Name
        LVItem.Caption := AppSrvClient1.Answer.Fields[1];
        LVItem.StateIndex := _StrToInt(AppSrvClient1.Answer.Fields[3]);
        // Severity
        LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[3]);
        // Created by
        LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[5]);
        // Description
        LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[8]);
        // ID
        LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[0]);
        // Changed?
        LVItem.SubItems.Add('0');
        // Keywords
        LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[2]);
        // Reported
        LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[9]);
        // Workaround
        LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[10]);
        // Status
        LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[7]);
        AppSrvClient1.Answer.Next;
      end; // while (not AppSrvClient1.Answer.EoF)
    finally
      lvBugs.Items.EndUpdate;
    end;
    if lvBugs.Items.Count > 0 then
      lvBugs.Items[0].Selected := True;
  end; // with DataModule1 do begin
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainBugs.SaveChanges;
var
  I: Integer;
begin
  for I := 0 to lvBugs.Items.Count - 1 do 
  begin
    if (lvBugs.Items[I].SubItems[4] = '1') then 
    begin
      with DataModule1 do 
      begin
        AppSrvClient1.Request.Rewrite;
        AppSrvClient1.FunctionCode := 'ADD_UPDATE_BUG';
        AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
        AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
        AppSrvClient1.Request.WriteFields(True, [lvBugs.Items[I].SubItems[3]]);
        AppSrvClient1.Request.WriteFields(False, [lvBugs.Items[I].Caption]);
        AppSrvClient1.Request.WriteFields(False, [lvBugs.Items[I].SubItems[0]]);
        AppSrvClient1.Request.WriteFields(False, [0]);
        AppSrvClient1.Request.WriteFields(False, [lvBugs.Items[I].SubItems[2]]);
        AppSrvClient1.Request.WriteFields(False, [lvBugs.Items[I].SubItems[5]]);
        AppSrvClient1.Request.WriteFields(False, [lvBugs.Items[I].SubItems[6]]);
        AppSrvClient1.Request.WriteFields(False, [lvBugs.Items[I].SubItems[7]]);
        AppSrvClient1.Request.WriteFields(False, [lvBugs.Items[I].SubItems[8]]);
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

        {if not DecodeBoolStr(AppSrvClient1.Answer.Fields[0])
          then MessageBox(Handle, PChar(AppSrvClient1.Answer.Fields[1]),
                                               cMsgBoxCaption, mb_OK or mb_ICONStop);}
      end; // with DataModule1 do begin
      ArchiveBugsChanged := True;
    end; // if lvBugs.Items[I].SubItems[2] := '1' then begin
  end; // for I := 0 to lvBugs.Items.Count - do begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainBugs.btnOKClick(Sender: TObject);
begin
  if lvBugs.IsEditing then 
  begin
    lvBugs.Selected.CancelEdit;
    Exit;
  end;
  SaveChanges;
  Close;
end;

//------------------------------------------------------------------------------

function TVCSMaintainBugs.CheckChanges: Boolean;
var 
  Changed: Boolean;
  I, DlgResult: Integer;
begin
  Result := True;
  Changed := False;
  for I := 0 to lvBugs.Items.Count - 1 do
    if (lvBugs.Items[I].SubItems[4] = '1') then 
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
        Result := False;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainBugs.btnCancelClick(Sender: TObject);
begin
  if not CheckChanges then 
    Exit;
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainBugs.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Bug_tracking);
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

procedure TVCSMaintainBugs.lvBugsChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
begin
  if lvBugs.Selected = nil then 
    Exit;
  icbLevel.ItemIndex := _StrToInt(lvBugs.Selected.SubItems[0]);
  edKeywords.Text := lvBugs.Selected.SubItems[5];
  edReported.Text := lvBugs.Selected.SubItems[6];
  if rbDescription.Checked then
    meDescr.Text := lvBugs.Selected.SubItems[2]
  else
    meDescr.Text := lvBugs.Selected.SubItems[7];
  cbxState.ItemIndex := _StrToInt(lvBugs.Selected.SubItems[8]);
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainBugs.rbDescriptionClick(Sender: TObject);
begin
  if lvBugs.Selected = nil then 
    Exit;
  if rbDescription.Checked then
    meDescr.Text := lvBugs.Selected.SubItems[2]
  else
    meDescr.Text := lvBugs.Selected.SubItems[7];
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainBugs.lvBugsEdited(Sender: TObject;
  Item: TListItem; var S: string);
begin
  if lvBugs.Selected = nil then 
    Exit;
  Item.SubItems[4] := '1';
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainBugs.edKeywordsChange(Sender: TObject);
begin
  if (lvBugs.Selected = nil) or
    (lvBugs.Selected.SubItems[5] = edKeywords.Text) then 
    Exit;
  lvBugs.Selected.SubItems[5] := edKeywords.Text;
  lvBugs.Selected.SubItems[4] := '1';
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainBugs.edReportedChange(Sender: TObject);
begin
  if (lvBugs.Selected = nil) or
    (lvBugs.Selected.SubItems[6] = edReported.Text) then 
    Exit;
  lvBugs.Selected.SubItems[6] := edReported.Text;
  lvBugs.Selected.SubItems[4] := '1';
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainBugs.meDescrChange(Sender: TObject);
var 
  SelectedItem: Integer;
begin
  if rbDescription.Checked then
    SelectedItem := 2
  else
    SelectedItem := 7;

  if (lvBugs.Selected = nil) or
    (lvBugs.Selected.SubItems[SelectedItem] = meDescr.Text) then 
    Exit;
  lvBugs.Selected.SubItems[SelectedItem] := meDescr.Text;
  lvBugs.Selected.SubItems[4] := '1';
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainBugs.icbLevelChange(Sender: TObject);
begin
  if (lvBugs.Selected = nil) or
    (lvBugs.Selected.SubItems[0] = IntToStr(icbLevel.ItemIndex)) then 
    Exit;
  lvBugs.Selected.SubItems[0] := IntToStr(icbLevel.ItemIndex);
  lvBugs.Selected.StateIndex := icbLevel.ItemIndex;
  lvBugs.Selected.SubItems[4] := '1';
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainBugs.cbxStateChange(Sender: TObject);
begin
  if (lvBugs.Selected = nil) or
    (lvBugs.Selected.SubItems[8] = IntToStr(cbxState.ItemIndex)) then 
    Exit;
  lvBugs.Selected.SubItems[8] := IntToStr(cbxState.ItemIndex);
  lvBugs.Selected.SubItems[4] := '1';
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainBugs.AddNewBug(BugName, BugKeywords, ReportedBy, Workaround,
  BugDescr: string; Status, Severity: Integer; var NewBugID: Integer);
var 
  LVItem: TListItem;
begin
  NewBugID := 0;
  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'ADD_UPDATE_BUG';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [0]); // ID
    AppSrvClient1.Request.WriteFields(False, [BugName]);
    AppSrvClient1.Request.WriteFields(False, [Severity]);
    AppSrvClient1.Request.WriteFields(False, [0]); // Flags
    AppSrvClient1.Request.WriteFields(False, [BugDescr]);
    AppSrvClient1.Request.WriteFields(False, [BugKeywords]);
    AppSrvClient1.Request.WriteFields(False, [ReportedBy]);
    AppSrvClient1.Request.WriteFields(False, [Workaround]);
    AppSrvClient1.Request.WriteFields(False, [Status]);
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
      NewBugID := _StrToInt(AppSrvClient1.Answer.Fields[1])
    else
      MessageBox(Handle, PChar('<' + BugName + '>' + #10#13 +
        AppSrvClient1.Answer.Fields[2]), cMsgBoxCaption, MB_OK or MB_ICONWARNING);
  end; // with DataModule1 do begin

  if NewBugID <> 0 then 
  begin
    LVItem := lvBugs.Items.Add;
    LVItem.Caption := BugName;
    LVItem.StateIndex := Severity;
    LVItem.SubItems.Add(IntToStr(Severity));
    LVItem.SubItems.Add(sCurrentUser);
    LVItem.SubItems.Add(BugDescr);
    LVItem.SubItems.Add(IntToStr(NewBugID));
    LVItem.SubItems.Add('0');
    LVItem.SubItems.Add(BugKeywords);
    LVItem.SubItems.Add(ReportedBy);
    LVItem.SubItems.Add(Workaround);
    LVItem.SubItems.Add(IntToStr(Status));

    ArchiveBugsChanged := True;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainBugs.spBtnAddClick(Sender: TObject);
var 
  NewBugName, NewBugKeywords, NewReportedBy, NewWorkaround, NewBugDescr: string;
  NewBugID, NewStatus, NewSeverity: Integer;
begin
  VCSAddBug := TVCSAddBug.Create(Application);
  try
    VCSAddBug.Left := Left + 40;
    VCSAddBug.Top := Top + 40;
    VCSAddBug.ShowModal;
    NewBugName := VCSAddBug.BugName;
    NewBugKeywords := VCSAddBug.BugKeywords;
    NewBugDescr := VCSAddBug.BugDescr;
    NewSeverity := VCSAddBug.Severity;
    NewReportedBy := VCSAddBug.ReportedBy;
    NewWorkaround := VCSAddBug.Workaround;
    NewStatus := VCSAddBug.Status;
  finally
    VCSAddBug.Free;
  end;
  if NewBugName <> '' then 
  begin
    AddNewBug(NewBugName, NewBugKeywords, NewReportedBy, NewWorkaround,
      NewBugDescr, NewStatus, NewSeverity, NewBugID);
  end; // if NewFamilyName <> '' then begin
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainBugs.spBtnRemoveClick(Sender: TObject);
var 
  Msg: string;
begin
  if lvBugs.Selected = nil then 
    Exit;
  if MessageBox(WindowHandle, PChar(Format(JVCSRES_Are_you_sure_you_want_to_remove_bug_6037s62_from_the_archive63,
    [lvBugs.Selected.Caption])),
    cMsgBoxCaption, MB_YESNOCANCEL or MB_DEFBUTTON2 or MB_ICONQUESTION) <> id_Yes then 
    Exit;

  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'REMOVE_BUG';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [lvBugs.Selected.SubItems[3]]);
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
      Msg := Format(JVCSRES_Bug_6037s62_is_already_in_use46, [lvBugs.Selected.Caption]) + #10#13 +
        JVCSRES_Access_denied46;
      MessageBox(Handle, PChar(Msg), cMsgBoxCaption, MB_OK or MB_ICONWARNING);
      Labelusedby1Click(Self);
      Exit;
    end;
  end; // with DataModule1 do begin
  lvBugs.Selected.Delete;
  meDescr.Text := '';
  icbLevel.ItemIndex := -1;
  ArchiveBugsChanged := True;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainBugs.FormResize(Sender: TObject);
begin
  {$IFNDEF SHOWIDS}
  if lvBugs.HandleAllocated then
    lvBugs.Columns[0].Width := Width - 35;
  {$ENDIF ~SHOWIDS}
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainBugs.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  //thu 08.08.2003
  { 
  jvcsWriteWindowSize(sBaseRegistryKey + crbWindows, 'MaintainBugs',
    Width, Height);
   }
  jvcsSaveFormPosSize(Self);

  jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'MaintainBugs_Pn1',
    Panel2.Height);
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainBugs.Labelusedby1Click(Sender: TObject);
var 
  ResultString: string;
  ContainsRecords: Boolean;
begin
  if lvBugs.Selected = nil then 
    Exit;
  ContainsRecords := False;
  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'BUGS_USED_BY';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [lvBugs.Selected.SubItems[3]]);
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
      if LowerCase(AppSrvClient1.Answer.Fields[0]) = 'p' then
        ResultString := ResultString + JVCSRES_Project + ';'
      else
        ResultString := ResultString + JVCSRES_Module + ';';
      ResultString := ResultString + AppSrvClient1.Answer.Fields[2] + ';' +
        AppSrvClient1.Answer.Fields[1] + ';|';
      AppSrvClient1.Answer.Next;
    end;
  end; // with DataModule1 do begin

  if not ContainsRecords then 
  begin
    MessageBox(Handle, PChar(Format(JVCSRES_There_were_no_37s_located_that_match_the_search_criteria46,
      [JVCSRES_records])), cMsgBoxCaption,
      MB_OK or MB_ICONINFORMATION);
    Exit;
  end;

  VCSStdListView := TVCSStdListView.Create(Application);
  try
    VCSStdListView.LVRepID := 3;
    VCSStdListView.Caption := lvBugs.Selected.Caption;
    VCSStdListView.Left := Left + 60;
    VCSStdListView.Top := Top + 60;
    VCSStdListView.LVType := 4;
    VCSStdListView.ItemID := _StrToInt(lvBugs.Selected.SubItems[3]);
    VCSStdListView.HelpContextID := IDH_Bug_tracking;
    VCSStdListView.AddListColumn(JVCSRES_Type, False);
    VCSStdListView.AddListColumn(JVCSRES_Name, False);
    VCSStdListView.AddListColumn(JVCSRES_ID, True);
    VCSStdListView.SetUpItems(ResultString);
    VCSStdListView.ShowModal;
  finally
    VCSStdListView.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainBugs.PopupMenu2Popup(Sender: TObject);
begin
  Edit1.Enabled := (lvBugs.Selected <> nil);
  Delete1.Enabled := Edit1.Enabled;
  Labelusedby1.Enabled := Edit1.Enabled;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainBugs.Edit1Click(Sender: TObject);
begin
  if lvBugs.Selected = nil then 
    Exit;
  lvBugs.Selected.EditCaption;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainBugs.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyUp(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainBugs.Report1Click(Sender: TObject);
var 
  ResultString, CurrentText: string;
  I, J: Integer;
  oaColumnsWidth: array of Integer;
const 
  cr = Chr(13) + Chr(10);

  function SizeString(const Column: Integer; const CellString: string;
    const Fillchr: Char): string;
  var 
    K: Integer;
  begin
    Result := CellString;
    if Length(Result) > 0 then
      for K := 1 to Length(Result) do 
      begin
        if (Result[K] = Chr(10)) or (Result[K] = Chr(13)) then 
        begin
          System.Delete(Result, K, 1);
          System.Insert('\', Result, K);
        end;
      end;
    while Length(Result) < oaColumnsWidth[Column] do
      Result := Result + Fillchr;
  end;
begin
  ResultString := '';
  Screen.Cursor := crHourGlass;
  try
    with lvBugs do 
    begin
      if Items.Count = 0 then
      begin
        MessageBox(WindowHandle, PChar(JVCSRES_Requested_result_set_is_blank46_Nothing_to_do46),
          cMsgBoxCaption, MB_OK);
        Exit;
      end;
      // Textlänge in der Spalte?
      SetLength(oaColumnsWidth, Columns.Count);
      for I := 0 to Columns.Count - 1 do 
      begin
        oaColumnsWidth[I] := Length(Columns[I].Caption);
        for J := 0 to Items.Count - 1 do 
        begin
          if I = 0 then 
            CurrentText := Items[J].Caption
          else 
            CurrentText := Items[J].SubItems[I - 1];
          if Length(CurrentText) > oaColumnsWidth[I] then
            oaColumnsWidth[I] := Length(CurrentText);
        end; // for J := 0 to Items.Count - 1 do begin
      end; // for J := 0 to Columns.Count - 1 do begin

      ResultString := Caption + cr;
      CurrentText := '';
      while Length(CurrentText) < Length(Caption) do
        CurrentText := CurrentText + '=';
      ResultString := ResultString + CurrentText + cr + cr;
      ResultString := ResultString + Format(JVCSRES_37d_entries46, [Items.Count]) + cr + cr;

      for J := 0 to Columns.Count - 3 do 
      begin
        ResultString := ResultString + SizeString(J, Columns[J].Caption, ' ');
        if J < (Columns.Count - 3) then 
          ResultString := ResultString + ' | ';
      end;
      ResultString := ResultString + cr;
      for J := 0 to Columns.Count - 3 do 
      begin
        ResultString := ResultString + SizeString(J, '-', '-');
        if J < (Columns.Count - 3) then 
          ResultString := ResultString + ' | ';
      end;
      ResultString := ResultString + cr;

      for I := 0 to Items.Count - 1 do 
      begin
        for J := 0 to Columns.Count - 3 do 
        begin
          if J = 0 then
            CurrentText := Items[I].Caption
          else 
            CurrentText := Items[I].SubItems[J - 1];
          ResultString := ResultString + SizeString(J, CurrentText, ' ');
          if J < (Columns.Count - 3) then 
            ResultString := ResultString + ' | ';
        end; // for J := 0 to Columns.Count - 1 do begin
        ResultString := ResultString + cr;
      end; // for I := 0 to Items.Count - 1 do begin
    end; // with elv do begin

    ResultString := ResultString + cr + JVCSRES_Source58_ + sArchiveSource + cr +
      JVCSRES_JEDI_VCS_ + sProductVer + cProductInf + DateTimeToStr(Now) + cr;
  finally
    Screen.Cursor := crDefault;
    SetLength(oaColumnsWidth, 0);
  end;

  VCSSimpleReport := TVCSSimpleReport.Create(Application);
  try
    VCSSimpleReport.RepID := 5;  
    VCSSimpleReport.Left := Left + 60;
    VCSSimpleReport.Top := Top + 60;
    VCSSimpleReport.FullReportString := ResultString;
    VCSSimpleReport.SavePath := ExtractFileDir(sProjectName);
    VCSSimpleReport.SaveFileName := 'UserList.txt';
    VCSSimpleReport.LineCount := lvBugs.Items.Count + 8;
    VCSSimpleReport.ShowModal;
  finally
    VCSSimpleReport.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainBugs.SearchProjectforKeywords1Click(Sender: TObject);
begin
(* #fvcstodostart
   $priority = 1
   $responsible = Administrator
   $item = This feature has not been finished yet (Search bug keywords)
   #fvcstodoend *)
  MessageBox(WindowHandle, PChar(JVCSRES_This_feature_has_not_been_finished_yet_and_has_been_disabled + #13#10 +
    JVCSRES_until_it_has_been_fixed46_Sorry46), cMsgBoxCaption, MB_OK);
  Exit;
  //----------------------------------------------------------------------------
  if lvBugs.Selected = nil then
    Exit;
end;

//------------------------------------------------------------------------------

function TVCSMaintainBugs.AddProjectBug(ItemID, NewBugID: Integer): Boolean;
begin
  Result := False;
  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'ASSIGN_REMOVE_BUG';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [ItemID]);
    AppSrvClient1.Request.WriteFields(False, [NewBugID]);
    AppSrvClient1.Request.WriteFields(False, [True]); // Project based?
    AppSrvClient1.Request.WriteFields(False, [True]); // add the bug?
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
      Exit;
  end; // with DataModule1 do begin
  Result := True;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainBugs.spBtnImportClick(Sender: TObject);
var 
  BugFileName, CurrentBugEntry, CurrentBugProject, CurrentBugName, CurrentBugSeverity,
  CurrentBugDescription, CurrentBugReporter, CurrentBugWorkaround, DlgText: string;
  I, AddedBugs, Yes2allRes, NewBugID, ItemID: Integer;
  ReportTimeStamp: Double;
  ProjectIDs, BugFileContent: TStringList;
  Skip, Yes2all, DlgResult: Boolean;
  FavOpenDialog: TFavOpenDialog;

  // String auf Länge 80 Z
  function CutStr(Value: string; Len: Integer): string;
  var 
    _Pos: Integer;
  begin
    if Length(Value) > Len then 
    begin
      _Pos := Len - 10;
      while _Pos < Length(Value) do 
      begin
        if Value[_Pos] = ' ' then 
        begin
          Insert(#10#13 + ' ', Value, _Pos);
          Break;
        end;
        Inc(_Pos);
      end;
    end; // if Length(Value) > 80 then begin
    Result := Value;
  end;
begin
  if not CheckChanges then 
    Exit;
  FavOpenDialog := TFavOpenDialog.Create(Application);
  try
    try
      with FavOpenDialog do
      begin
        Title := JVCSRES_Select_bug_import_file;
        Options := [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing];
        InitialDir := ExtractFileDir(sProjectName);
        FileName := '';
        Filter := JVCSRES_Text_files_404246txt411244246txt124All_files_4042464241124424642;

        DlgResult := ExecuteFavOpenDialogWithMru(FavOpenDialog,
          sBaseRegistryKey + crbMRU + '18');

        if DlgResult then 
          BugFileName := FileName;
      end; // with FavOpenDialog1 do begin
    finally
      FavOpenDialog.Free;
    end;
    if not DlgResult then 
      Exit;

    // projectIDs
    ProjectIDs := TStringList.Create;
    try
      with DataModule1 do 
      begin
        AppSrvClient1.Request.Rewrite;
        AppSrvClient1.FunctionCode := 'GET_PROJECT_LIST';
        AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
        AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
        AppSrvClient1.Request.WriteFields(False, ['']);
        AppSrvClient1.Request.WriteFields(True, [False]); // incl. details
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
          if AppSrvClient1.Answer.Fields[2] <> '1' then 
          begin
            ProjectIDs.Add(AppSrvClient1.Answer.Fields[1] + '=' +
              AppSrvClient1.Answer.Fields[0]);
          end; // if AppSrvClient1.Answer.Fields[2] <> '1' then begin
          AppSrvClient1.Answer.Next;
        end;
      end; // with DataModule1 do begin

      BugFileContent := TStringList.Create;
      try
        try
          BugFileContent.LoadFromFile(BugFileName);
        except
          on E: 
          Exception do 
          begin
            BugFileContent.Clear;
            BeepIfSet;
            MessageBox(Handle, PChar(Format(JVCSRES_Reading_file_6037s62 + #13#10 +
              JVCSRES_raised_exception58 + #13#10 + '%s.', [BugFileName, E.Message])),
              cMsgBoxCaption, MB_OK or MB_ICONSTOP);
          end;
        end;

        {; PROJECTNAME(String50)|BUGNAME(String250)|SEVERITY(Int 0-4)|
           DESCRIPTION(String2000)|REPORTEDBY(String2000)|WORKAROUND(String200)|
           REPORTTIME(INT)}

        Yes2all := False;
        AddedBugs := 0;
        for I := 0 to BugFileContent.Count - 1 do 
        begin
          CurrentBugEntry := BugFileContent.Strings[I];
          if (CurrentBugEntry = '') or
            (CurrentBugEntry[1] = ';') then 
            Continue;

          CurrentBugProject := LowerCase(Copy(CurrentBugEntry, 1,
            Pos('|', CurrentBugEntry) - 1));
          System.Delete(CurrentBugEntry, 1, Pos('|', CurrentBugEntry));
          CurrentBugName := Copy(CurrentBugEntry, 1, Pos('|', CurrentBugEntry) - 1);
          System.Delete(CurrentBugEntry, 1, Pos('|', CurrentBugEntry));
          CurrentBugSeverity := Copy(CurrentBugEntry, 1, Pos('|', CurrentBugEntry) - 1);
          System.Delete(CurrentBugEntry, 1, Pos('|', CurrentBugEntry));
          CurrentBugDescription := Copy(CurrentBugEntry, 1, Pos('|', CurrentBugEntry) - 1);
          System.Delete(CurrentBugEntry, 1, Pos('|', CurrentBugEntry));
          CurrentBugReporter := Copy(CurrentBugEntry, 1, Pos('|', CurrentBugEntry) - 1);
          System.Delete(CurrentBugEntry, 1, Pos('|', CurrentBugEntry));
          CurrentBugWorkaround := Copy(CurrentBugEntry, 1, Pos('|', CurrentBugEntry) - 1);
          System.Delete(CurrentBugEntry, 1, Pos('|', CurrentBugEntry));
          if CurrentBugEntry[Length(CurrentBugEntry)] = '|' then
            System.Delete(CurrentBugEntry, Length(CurrentBugEntry), 1);

          ReportTimeStamp := 25569 + ((1 / 86400) * (_StrToInt(CurrentBugEntry)));
          CurrentBugReporter := CurrentBugReporter + ' (' +
            DateTimeToStr(ReportTimeStamp) + ')';

          if Length(CurrentBugDescription) >= 108 then
            DlgText := Copy(CurrentBugDescription, 1, 106) + '...'
          else
            DlgText := CurrentBugDescription;

          DlgText := CutStr(DlgText, 36);
          DlgText := CutStr(DlgText, 72);

          DlgText := Format(JVCSRES_Assign_bug_6037s62_to_6037s6263, [CurrentBugName, CurrentBugProject])
            + #10#13 + '>> ' + DlgText + #10#13 + '>> ' + CurrentBugReporter;

          Skip := False;
          if not Yes2all then 
          begin
            VCSYes2AllDlg := TVCSYes2AllDlg.Create(Application);
            try
              VCSYes2AllDlg.EnableYes2All(True);
              VCSYes2AllDlg.SetMessageText(DlgText);
              {VCSYes2AllDlg.ShowCheckBox(True);
              VCSYes2AllDlg.SetCheckBoxCaption('&Remove entry from file.');}
              Yes2allRes := VCSYes2AllDlg.ShowModal;
            finally
              VCSYes2AllDlg.Free;
            end;
            case Yes2allRes of
              mrYes:;
              mrAll:
                Yes2all := True;
              mrNo:
                Skip := True;
              mrCancel: 
                Break;
            end; // case Yes2allRes of
          end; // if not Yes2all then begin

          if not Skip then 
          begin
            AddNewBug(CurrentBugName, '', CurrentBugReporter, CurrentBugWorkaround,
              CurrentBugDescription, 0, _StrToInt(CurrentBugSeverity), NewBugID);

            ItemID := _StrToInt(ProjectIDs.Values[CurrentBugProject]);

            if (NewBugID <> 0) and (ItemID <> 0) then 
            begin
              AddProjectBug(ItemID, NewBugID);
              Inc(AddedBugs);
            end 
            else 
            begin
              if ItemID = 0 then
                MessageBox(WindowHandle, PChar('<' + CurrentBugProject + '>' +
                  #10#13 + JVCSRES_No_such_project_in_the_archive46), cMsgBoxCaption,
                  MB_OK or MB_ICONWARNING);
            end;
          end; // if not Skip then begin
        end; // for I := 0 to BugFileContent.Count - 1 do begin

      finally
        BugFileContent.Free;
      end;
    finally
      ProjectIDs.Free;
    end;
    MessageBox(WindowHandle, PChar(Format(JVCSRES_37d_bugs_added_to_version_archive46,
      [AddedBugs])), cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
  except
    on E: 
    Exception do
      MessageBox(WindowHandle, PChar(E.Message), cMsgBoxCaption, MB_OK or MB_ICONSTOP);
  end;
  ReadBugList;
end;

end.
