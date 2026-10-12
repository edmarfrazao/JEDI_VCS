(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: AssignBugs.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS:
  Thomas Huber (Thomas_D_Huber@gmx.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FreeVCS code to JEDI VCS
2003/02/12  USchuster - changed DSAMsg with JVCSDialogs in uses clause to use JvDSADialogs
2003/03/02  THensle   - changes for "ConfigStorage" unit
2003/12/27  USchuster - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use constant)
                      - fixed strange layout with empty settings
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/03  THuber    - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
                      - jedistyle clean
                      - removed shortcuts for add/remove bugs
2004/10/08  THuber    - use jvcl msgBoxes
                      - resourcestring now in JVCSGUIClientResources
2007/07/01  USchuster - style cleaning
                      - changes for large fonts (contraints and default size depend now on PixelsPerInch; analog to Mantis #3710)
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit AssignBugs;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Forms, StdCtrls, ComCtrls, ExtCtrls,
  Buttons, Menus, ImgList, Controls, Dialogs, JVCSForms;

type
  TVCSAssignBugs = class(TJVCSForm)
    lvAssignedBugs: TListView;
    Splitter2: TSplitter;
    PopupMenu1: TPopupMenu;
    PopupMenu2: TPopupMenu;
    RemoveLabel1: TMenuItem;
    Addlabel1: TMenuItem;
    TypeImageList: TImageList;
    StateImageList: TImageList;
    Panel5: TPanel;
    Panel4: TPanel;
    Panel1: TPanel;
    spBtnAdd: TSpeedButton;
    spBtnRemove: TSpeedButton;
    spBtnMaintain: TSpeedButton;
    Help: TSpeedButton;
    btnCancel: TButton;
    meLabelDescr: TMemo;
    Splitter1: TSplitter;
    Panel2: TPanel;
    lvBugs: TListView;
    Panel3: TPanel;
    Label1: TLabel;
    spBtnGetLLabel: TSpeedButton;
    edSearch: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvAssignedBugsChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure spBtnAddClick(Sender: TObject);
    procedure spBtnRemoveClick(Sender: TObject);
    procedure lvBugsChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure spBtnMaintainClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure HelpClick(Sender: TObject);
    procedure edSearchChange(Sender: TObject);
    procedure edSearchEnter(Sender: TObject);
    procedure spBtnGetLLabelClick(Sender: TObject);
    procedure lvAssignedBugsMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure lvAssignedBugsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    FCreating: Boolean;
    procedure GetArchiveBugs;
    procedure ChangeBugState(HitItem: TListItem);
  public
    { Public declarations }
    ItemID,
    ItemName: string;
    BugsChanged,
    ModuleBased: Boolean;
  end;

var
  VCSAssignBugs: TVCSAssignBugs;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSBase, VCSProcBase, DBModule, MaintainBugs, ConfigStorage, JVCSDialogs, JvJVCLUtils,
  JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSAssignBugs.FormCreate(Sender: TObject);
var
  DlgWidth, DlgHeight: Integer;
begin
  try
    Constraints.MinHeight := MulDiv(300, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(300, PixelsPerInch, 96);
    FCreating := True;
    BugsChanged := False;

    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    if not jvcsReadWindowSize(sBaseRegistryKey + crbWindows, 'AssignBugs',
      DlgWidth, DlgHeight) then
    begin
      DlgWidth := MulDiv(310, PixelsPerInch, 96);
      DlgHeight := MulDiv(300, PixelsPerInch, 96);
    end;
    Width := DlgWidth;
    Height := DlgHeight;

    Panel5.Height := jvcsReadInteger(sBaseRegistryKey + crbWindows, 'AssignBugs_Pn1', 200);
    Panel4.Height := jvcsReadInteger(sBaseRegistryKey + crbWindows, 'AssignBugs_Pn2', 100);

    {$IFNDEF SHOWIDS}
    lvAssignedBugs.Columns[1].Width := 0;
    lvBugs.Columns[1].Width := 0;
    {$ENDIF ~SHOWIDS}
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSAssignBugs.GetArchiveBugs;
var 
  LVItem: TListItem;
begin
  lvBugs.Items.Clear;
  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_BUGS';
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
    lvBugs.Items.BeginUpdate;

    while (not AppSrvClient1.Answer.Eof) do 
    begin
      LVItem := lvBugs.Items.Add;
      LVItem.Caption := AppSrvClient1.Answer.Fields[1];
      LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[0]);
      LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[8]);
      LVItem.SubItems.Add('0');
      LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[3]);
      LVItem.ImageIndex := _StrToInt(AppSrvClient1.Answer.Fields[3]);
      AppSrvClient1.Answer.Next;
    end; // while (not AppSrvClient1.Answer.EoF)
    if lvBugs.Items.Count > 0 then
      lvBugs.Items[0].Selected := True;
    lvBugs.Items.EndUpdate;
  end; // with DataModule1 do begin
end;

//------------------------------------------------------------------------------

procedure TVCSAssignBugs.FormActivate(Sender: TObject);
var 
  LVItem: TListItem;
begin
  Application.ProcessMessages;
  if FCreating then 
  begin
    FCreating := False;
    if ModuleBased then
      Caption := JVCSRES_Module_related_Bugs
    else
      Caption := JVCSRES_Project_related_Bugs;

    lvAssignedBugs.Columns[0].Caption := Format(JVCSRES_Bugs_assigned_to_37s, [ItemName]);
    GetArchiveBugs;

    with DataModule1 do 
    begin
      AppSrvClient1.Request.Rewrite;
      if ModuleBased then
        AppSrvClient1.FunctionCode := 'GET_BUGS_BY_MODULE'
      else
        AppSrvClient1.FunctionCode := 'GET_BUGS_BY_PROJECT';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [ItemID]);
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
      lvAssignedBugs.Items.BeginUpdate;
      while (not AppSrvClient1.Answer.Eof) do 
      begin
        LVItem := lvAssignedBugs.Items.Add;
        LVItem.Caption := AppSrvClient1.Answer.Fields[1];
        LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[0]);
        LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[2]);
        LVItem.SubItems.Add('0');
        LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[3]);
        LVItem.ImageIndex := _StrToInt(AppSrvClient1.Answer.Fields[3]);
        if DecodeBoolStr(AppSrvClient1.Answer.Fields[4]) then
          LVItem.StateIndex := 1
        else
          LVItem.StateIndex := 0;
        AppSrvClient1.Answer.Next;
      end; // while (not AppSrvClient1.Answer.EoF)
      if lvAssignedBugs.Items.Count > 0 then 
        lvAssignedBugs.Items[0].Selected := True;
      lvAssignedBugs.Items.EndUpdate;
    end; // with DataModule1 do begin
  end; // if FCreating then begin
end;

//------------------------------------------------------------------------------

procedure TVCSAssignBugs.btnCancelClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSAssignBugs.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Bug_tracking);
  if Key = VK_ESCAPE then 
  begin
    btnCancelClick(Self);
    Key := 0;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSAssignBugs.lvBugsChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  if lvBugs.Selected = nil then 
    Exit;
  meLabelDescr.Text := lvBugs.Selected.SubItems[1];
end;

//------------------------------------------------------------------------------

procedure TVCSAssignBugs.lvAssignedBugsChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
begin
  if lvAssignedBugs.Selected = nil then 
    Exit;
  meLabelDescr.Text := lvAssignedBugs.Selected.SubItems[1];
end;

//------------------------------------------------------------------------------

procedure TVCSAssignBugs.spBtnAddClick(Sender: TObject);
var
  NewBugID: string;
  LVItem: TListItem;
begin
  if lvBugs.Selected = nil then 
    Exit;
  NewBugID := lvBugs.Selected.SubItems[0];
  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'ASSIGN_REMOVE_BUG';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [ItemID]);
    AppSrvClient1.Request.WriteFields(False, [NewBugID]);
    AppSrvClient1.Request.WriteFields(False, [not ModuleBased]);
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

    LVItem := lvAssignedBugs.Items.Add;
    LVItem.Caption := lvBugs.Selected.Caption;
    LVItem.SubItems.Add(lvBugs.Selected.SubItems[0]);
    LVItem.SubItems.Add(lvBugs.Selected.SubItems[1]);
    LVItem.SubItems.Add('0');
    LVItem.SubItems.Add(lvBugs.Selected.SubItems[3]);
    LVItem.ImageIndex := _StrToInt(lvBugs.Selected.SubItems[3]);
    LVItem.StateIndex := 0;
  end; // with DataModule1 do begin
  BugsChanged := True;
  jvcsWriteString(sBaseRegistryKey + crbMRU, 'Bug', lvBugs.Selected.Caption);
end;

//------------------------------------------------------------------------------

procedure TVCSAssignBugs.spBtnRemoveClick(Sender: TObject);
var 
  RemoveBugID: string;
begin
  if lvAssignedBugs.Selected = nil then
    Exit;
  UseRegistry := True;
  DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
  if DSAIdentsMessageDlg( Format( JVCSRES_Are_you_sure_you_want_to_remove_bug_6037s62 +#13+#10+
                                  JVCSRES_from_6037s6263
                                , [lvAssignedBugs.Selected.Caption, ItemName]
                                )
                        , mtConfirmation
                        , [mbYes, mbNo, mbCancel]
                        , 0
                        , sBaseRegistryKey + crbMRU + 'Dlgs'
                        , 'RmvRevLabel'
                        , idYes
                        ) <> idYes then
                          Exit;
  RemoveBugID := lvAssignedBugs.Selected.SubItems[0];
  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'ASSIGN_REMOVE_BUG';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [ItemID]);
    AppSrvClient1.Request.WriteFields(False, [RemoveBugID]);
    AppSrvClient1.Request.WriteFields(False, [not ModuleBased]);
    AppSrvClient1.Request.WriteFields(False, [False]); // add the bug?
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

    lvAssignedBugs.Selected.Delete;
  end; // with DataModule1 do begin
  BugsChanged := True;
end;

//------------------------------------------------------------------------------

procedure TVCSAssignBugs.spBtnMaintainClick(Sender: TObject);
var 
  ArchiveBugsChanged: Boolean;
begin
  VCSMaintainBugs := TVCSMaintainBugs.Create(Application);
  try
    VCSMaintainBugs.Left := Left + 60;
    VCSMaintainBugs.Top := Top + 60;
    VCSMaintainBugs.ShowModal;
    ArchiveBugsChanged := VCSMaintainBugs.ArchiveBugsChanged
  finally
    VCSMaintainBugs.Free;
  end;
  if ArchiveBugsChanged then 
    GetArchiveBugs;
end;

//------------------------------------------------------------------------------

procedure TVCSAssignBugs.FormResize(Sender: TObject);
begin
  {$IFNDEF SHOWIDS}
  lvAssignedBugs.Columns[0].Width := Width - 35;
  lvBugs.Columns[0].Width := Width - 35;
  {$ENDIF ~SHOWIDS}
end;

//------------------------------------------------------------------------------

procedure TVCSAssignBugs.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'AssignBugs_Pn1', Panel5.Height);
  jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'AssignBugs_Pn2', Panel4.Height);
  jvcsWriteWindowSize(sBaseRegistryKey + crbWindows, 'AssignBugs', Height, Width);
end;

//------------------------------------------------------------------------------

procedure TVCSAssignBugs.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyUp(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSAssignBugs.edSearchChange(Sender: TObject);
var 
  I: Integer;
  LVItem: TListItem;
begin
  if (lvBugs.Items.Count = 0) then
    Exit;
  LVItem := lvBugs.FindCaption(0, edSearch.Text, True, True, False);
  if LVItem <> nil then 
  begin
    LVItem.Selected := True;
    with lvBugs do 
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
    end; // with lvBugs do begin
  end // if LVItem <> nil then begin
  else
    lvBugs.Selected := nil;
end;

//------------------------------------------------------------------------------

procedure TVCSAssignBugs.edSearchEnter(Sender: TObject);
begin
  edSearch.SelStart := 0;
  edSearch.SelLength := Length(edSearch.Text);
end;

//------------------------------------------------------------------------------

procedure TVCSAssignBugs.spBtnGetLLabelClick(Sender: TObject);
var 
  LastLabel: string;
begin
  LastLabel := jvcsReadString(sBaseRegistryKey + crbMRU, 'Bug', '');
  if LastLabel <> '' then
    edSearch.Text := LastLabel
  else
    MsgInfo( WindowHandle
           , Format(JVCSRES_MRU_item_6037s62_is_blank46, [JVCSRES_Last_Bug])
           , cMsgBoxCaption
           );
end;

//------------------------------------------------------------------------------

procedure TVCSAssignBugs.ChangeBugState(HitItem: TListItem);
var 
  BugID: string;
begin
  BugID := HitItem.SubItems[0];
  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'ENABLE_MODULE_PROJECT_BUG';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [ItemID]);
    AppSrvClient1.Request.WriteFields(False, [BugID]);
    AppSrvClient1.Request.WriteFields(False, [not ModuleBased]);
    AppSrvClient1.Request.WriteFields(False, [(HitItem.StateIndex = 1)]); // done
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
  BugsChanged := True;
end;

//------------------------------------------------------------------------------

procedure TVCSAssignBugs.lvAssignedBugsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var 
  HitTest: THitTests;
  HitItem: TListItem;
begin
  HitTest := lvAssignedBugs.GetHitTestInfoAt(X, Y);
  if (Button = mbLeft) and (htOnStateIcon in HitTest) then 
  begin
    HitItem := lvAssignedBugs.GetItemAt(X, Y);
    if HitItem.StateIndex > 1 then 
      Exit;
    if HitItem.StateIndex = 0 then 
      HitItem.StateIndex := 1 
    else 
      HitItem.StateIndex := 0;
    ChangeBugState(HitItem);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSAssignBugs.lvAssignedBugsKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (lvAssignedBugs.Selected <> nil) and (Key = VK_SPACE) then 
  begin
    if lvAssignedBugs.Selected.StateIndex > 1 then 
      Exit;
    if lvAssignedBugs.Selected.StateIndex = 0 then
      lvAssignedBugs.Selected.StateIndex := 1
    else 
      lvAssignedBugs.Selected.StateIndex := 0;
    ChangeBugState(lvAssignedBugs.Selected);
  end;
end;

end.
