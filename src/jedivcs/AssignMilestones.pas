(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: AssignMilestones.pas

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
2003/03/03  THensle   - changes for "ConfigStorage" unit
2003/12/27  USchuster - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use constant)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/08  THuber    - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
                      - removed shortcuts for add/remove bugs
                      - jedistyle clean
                      - use jvcl msgBoxes
2005/07/16  USchuster - minor style cleaning (casing and comments)
                      - now Actions are used for the ShortCuts
2007/07/01  USchuster - changes for large fonts (contraints and default size depend now on PixelsPerInch; analog to Mantis #3710)
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit AssignMilestones;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, Buttons, ActnList, Menus, JVCSForms;

type
  TVCSAssignMilestones = class(TJVCSForm)
    lvAssignedMStones: TListView;
    Splitter2: TSplitter;
    Panel3: TPanel;
    Panel2: TPanel;
    Panel1: TPanel;
    spBtnAdd: TSpeedButton;
    spBtnRemove: TSpeedButton;
    spBtnMaintain: TSpeedButton;
    Label1: TLabel;
    Help: TSpeedButton;
    btnCancel: TButton;
    edConfirm: TEdit;
    meLabelDescr: TMemo;
    Splitter1: TSplitter;
    lvMilestones: TListView;
    ActionList1: TActionList;
    acAdd: TAction;
    acRemove: TAction;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvAssignedMStonesChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure spBtnAddClick(Sender: TObject);
    procedure spBtnRemoveClick(Sender: TObject);
    procedure lvMilestonesChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure spBtnMaintainClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure HelpClick(Sender: TObject);
  private
    { Private declarations }
    FCreating: Boolean;
    procedure GetArchiveMStones;
  public
    { Public declarations }
    LabelsChanged: Boolean;
  end;

var
  VCSAssignMilestones: TVCSAssignMilestones;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSBase, VCSProcBase, DBModule, CommCtrl, Description, MaintainMilestones, TZHandling,
  ConfigStorage, JvJVCLUtils, JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSAssignMilestones.FormCreate(Sender: TObject);
var
  ToolTipHandle: HWND;
  DlgWidth, DlgHeight: Integer;
begin
  try
    Constraints.MinHeight := MulDiv(285, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(300, PixelsPerInch, 96);
    FCreating := True;
    LabelsChanged := False;
    // ListView Tooltips
    SendMessage(lvAssignedMStones.Handle, LVM_SETEXTENDEDLISTVIEWSTYLE, LVS_EX_INFOTIP,
      LVS_EX_INFOTIP);
    ToolTipHandle := SendMessage(lvAssignedMStones.Handle, LVM_GETTOOLTIPS, 0, 0);
    SendMessage(ToolTipHandle, TTM_SETDELAYTIME, TTDT_AUTOMATIC, 1);
    SendMessage(ToolTipHandle, TTM_SETDELAYTIME, TTDT_AUTOPOP, 3000);

    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    if not jvcsReadWindowSize(sBaseRegistryKey + crbWindows, 'AssignMilestones',
      DlgWidth, DlgHeight) then
    begin
      DlgWidth := MulDiv(310, PixelsPerInch, 96);
      DlgHeight := MulDiv(300, PixelsPerInch, 96);
    end;
    Width := DlgWidth;
    Height := DlgHeight;

    Panel3.Height :=
      jvcsReadInteger(sBaseRegistryKey + crbWindows, 'AssignMilestones_Pn1', 200);
    Panel2.Height :=
      jvcsReadInteger(sBaseRegistryKey + crbWindows, 'AssignMilestones_Pn2', 100);

    with lvAssignedMStones do
    begin
      Columns[0].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'AssignMilestones_Col1.0', 100);
      Columns[1].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'AssignMilestones_Col1.1', 80);
      Columns[2].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'AssignMilestones_Col1.2', 80);
    end;

    {$IFNDEF SHOWIDS}
    lvAssignedMStones.Columns[3].Width := 0;
    lvMilestones.Columns[1].Width := 0;
    {$ENDIF ~SHOWIDS}
    acAdd.ShortCut := ShortCut(Word('A'), [ssCtrl]);
    acRemove.ShortCut := ShortCut(Word('R'), [ssCtrl]);
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSAssignMilestones.GetArchiveMStones;
var
  LVItem: TListItem;
begin
  lvMilestones.Items.Clear;
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
        LVItem.Caption := AppSrvClient1.Answer.Fields[2];
        LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[0]);
        LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[3]);
        AppSrvClient1.Answer.Next;
      end; // while (not AppSrvClient1.Answer.EoF)
      if lvMilestones.Items.Count > 0 then 
        lvMilestones.Items[0].Selected := True;
    finally
      lvMilestones.Items.EndUpdate;
    end;
  end; // with DataModule1 do begin
end;

//------------------------------------------------------------------------------

procedure TVCSAssignMilestones.FormActivate(Sender: TObject);
var 
  LVItem: TListItem;
begin
  Application.ProcessMessages;
  if FCreating then 
  begin
    FCreating := False;
    Caption := Format ( JVCSRES_Milestones_assigned_to_37s
                      , [ExtractFileName(sProjectName)]
                      );
    GetArchiveMStones;

    with DataModule1 do
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_PROJECT_MILESTONES';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [ServerProjectID]);
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
      lvAssignedMStones.Items.BeginUpdate;
      try
        while (not AppSrvClient1.Answer.Eof) do
        begin
          LVItem := lvAssignedMStones.Items.Add;
          LVItem.Caption := AppSrvClient1.Answer.Fields[6];
          LVItem.SubItems.Add(DateTimeToStr(GMTStr2LocalDateTime(AppSrvClient1.Answer.Fields[3])));
          LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[2]);
          LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[1]);
          LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[4]);
          AppSrvClient1.Answer.Next;
        end; // while (not AppSrvClient1.Answer.EoF)
        if lvAssignedMStones.Items.Count > 0 then
          lvAssignedMStones.Items[0].Selected := True;
      finally
        lvAssignedMStones.Items.EndUpdate;
      end;
    end; // with DataModule1 do begin
  end; // if FCreating then begin
end;

//------------------------------------------------------------------------------

procedure TVCSAssignMilestones.btnCancelClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSAssignMilestones.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Milestones);
  if Key = VK_ESCAPE then 
  begin
    btnCancelClick(Self);
    Key := 0;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSAssignMilestones.lvMilestonesChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  if lvMilestones.Selected = nil then 
    Exit;
  meLabelDescr.Text := lvMilestones.Selected.SubItems[1];
end;

//------------------------------------------------------------------------------

procedure TVCSAssignMilestones.lvAssignedMStonesChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
begin
  if lvAssignedMStones.Selected = nil then
    Exit;
  meLabelDescr.Text := lvAssignedMStones.Selected.SubItems[3];
end;

//------------------------------------------------------------------------------

procedure TVCSAssignMilestones.spBtnAddClick(Sender: TObject);
var 
  NewMilestoneID, Description: string;
  LVItem: TListItem;
begin
  if lvMilestones.Selected = nil then
    Exit;
  if edConfirm.Text = '' then 
  begin
    MsgWarn ( WindowHandle
            , Format( JVCSRES_6037s6246_This_value_cannot_be_blank46
                    , [JVCSRES_Confirm_by]
                    )
            , cMsgBoxCaption
            );
    edConfirm.SetFocus;
    Exit;
  end; // if edConfirm.Text = '' then begin
  VCSDescription := TVCSDescription.Create(Application);
  try
    VCSDescription.Top := Top + 40;
    VCSDescription.Left := Left + 40;
    VCSDescription.DescType := 3;
    VCSDescription.SetDescripCaption( Format( JVCSRES_38Milestone58_37s
                                            , [lvMilestones.Selected.Caption]
                                            )
                                    );
    VCSDescription.SetDescription ( Format( JVCSRES_Project_has_reached_milestone58_
                                          , [lvMilestones.Selected.Caption]
                                          )
                                  );
    VCSDescription.EnableCheckBox(False);
    VCSDescription.ShowModal;
    Description := VCSDescription.Description;
  finally
    VCSDescription.Free;
  end;
  if Description = '' then 
    Exit;
  NewMilestoneID := lvMilestones.Selected.SubItems[0];
  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'ASSIGN_PROJECT_MILESTONE';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [ServerProjectID]);
    AppSrvClient1.Request.WriteFields(False, [NewMilestoneID]);
    AppSrvClient1.Request.WriteFields(False, [edConfirm.Text]);
    AppSrvClient1.Request.WriteFields(False, [Description]);
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

    LVItem := lvAssignedMStones.Items.Add;
    LVItem.Caption := lvMilestones.Selected.Caption;
    LVItem.SubItems.Add(DateTimeToStr(Now));
    LVItem.SubItems.Add(edConfirm.Text);
    LVItem.SubItems.Add(NewMilestoneID);
    LVItem.SubItems.Add(Description);
  end; // with DataModule1 do begin
  LabelsChanged := True;
end;

//------------------------------------------------------------------------------

procedure TVCSAssignMilestones.spBtnRemoveClick(Sender: TObject);
var 
  Msg, RemoveMStoneID: string;
begin
  if lvAssignedMStones.Selected = nil then 
    Exit;
  Msg := Format ( JVCSRES_Are_you_sure_to_remove_milestone_6037s6263
                , [lvAssignedMStones.Selected.Caption]
                );
  if MsgYesNoCancel ( WindowHandle
                    , Msg
                    , cMsgBoxCaption
                    , MB_DEFBUTTON2 or MB_ICONQUESTION
                    ) <> IDYES then
    Exit; // !!!

  RemoveMStoneID := lvAssignedMStones.Selected.SubItems[2];
  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'REMOVE_PROJECT_MILESTONE';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [ServerProjectID]);
    AppSrvClient1.Request.WriteFields(False, [RemoveMStoneID]);
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

    lvAssignedMStones.Selected.Delete;
  end; // with DataModule1 do begin
  LabelsChanged := True;
end;

//------------------------------------------------------------------------------

procedure TVCSAssignMilestones.spBtnMaintainClick(Sender: TObject);
var
  ArchiveMStonesChanged: Boolean;
begin
  VCSMaintainMilestones := TVCSMaintainMilestones.Create(Application);
  try
    VCSMaintainMilestones.Left := Left + 40;
    VCSMaintainMilestones.Top := Top + 40;
    VCSMaintainMilestones.ShowModal;
    ArchiveMStonesChanged := VCSMaintainMilestones.LabelsChanged;
  finally
    VCSMaintainMilestones.Free;
  end;
  if ArchiveMStonesChanged then
    GetArchiveMStones;
end;

//------------------------------------------------------------------------------

procedure TVCSAssignMilestones.FormResize(Sender: TObject);
begin
  {$IFNDEF SHOWIDS}
  //  lvAssignedMStones.Columns[0].Width := Width - 35;
  lvMilestones.Columns[0].Width := Width - 35;
  {$ENDIF ~SHOWIDS}
end;

//------------------------------------------------------------------------------

procedure TVCSAssignMilestones.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  jvcsWriteWindowSize(sBaseRegistryKey + crbWindows, 'AssignMilestones',
    Width, Height);

  jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'AssignMilestones_Pn1',
    Panel3.Height);
  jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'AssignMilestones_Pn2',
    Panel2.Height);

  with lvAssignedMStones do
  begin
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'AssignMilestones_Col1.0',
      Columns[0].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'AssignMilestones_Col1.1',
      Columns[1].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'AssignMilestones_Col1.2',
      Columns[2].Width);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSAssignMilestones.HelpClick(Sender: TObject);
var
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyUp(Self, HelpKey, []);
end;

end.
