(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: AssignLabels.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS:
  Thomas Huber (Thomas_D_Huber@t-online.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FreeVCS code to JEDI VCS
2003/02/12  USchuster - changed DSAMsg with JVCSDialogs in uses clause to use JvDSADialogs
2003/03/02  THensle   - changes for "ConfigStorage" unit
2003/03/09  USchuster - changes in connection with mantis #727
                      - disabled the AutoSave property in rcbLabelMask
                        and removed the regkeys (they where wrong and
                        loading and saving is no done with MruListLabelMask)
                      - removed rcbLabelMask.AutoSave.SaveValue
                      - the LabelMask will also be inserted into the
                        combobox now
                      - anchors of rcbLabelMask completely set
2003/08/30  MGosselink- mantis #1108: Move an already assigned label to another
                        revision of the same module
2003/09/06  THuber    - better resizing, TSplitter replaced with TJvxSplitter,
                        use jvcsLoad/SaveFormPosSize
                      - ... seems that I was lost in jvcl ;) replaced TJvXSplitter
                        with TJvSplitter (JvX.. should not be used any more)
2003/12/27  USchuster - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use constant)
                      - AutoComplete in ComboBox now False
2004/02/23  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/08  THuber    - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
                      - jedistyle clean
                      - removed shortcuts for add/remove bugs
                      - use jvcl msgBoxes
                      - fix tweak if same label was assigned twice
2005/07/16  USchuster - minor style cleaning (casing and comments)
                      - now Actions are used for the ShortCuts
2006/12/10  USchuster - added JVCSClientFunctions to uses (as of now it is required for MatchWithFilter)
2007/07/01  USchuster - changes for large fonts (contraints size depend now on PixelsPerInch; analog to Mantis #3710)
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit AssignLabels;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Forms, StdCtrls, ComCtrls, ExtCtrls,
  Buttons, Menus, JvCombobox, Controls, Dialogs, JVCSMruList, JvComponent,
  JvSplit, JvSplitter, JvExStdCtrls, JvExExtCtrls, ActnList, JVCSForms;

type
  TVCSAssignLabels = class(TJVCSForm)
    lvAssignedLabels: TListView;
    PopupMenu1: TPopupMenu;
    PopupMenu2: TPopupMenu;
    RemoveLabel1: TMenuItem;
    Addlabel1: TMenuItem;
    pnlMiddle: TPanel;
    JvSplitterDesc: TJvSplitter;
    Panel1: TPanel;
    spBtnAdd: TSpeedButton;
    spBtnRemove: TSpeedButton;
    spBtnMaintain: TSpeedButton;
    Help: TSpeedButton;
    btnCancel: TButton;
    meLabelDescr: TMemo;
    JvSplitterTop: TJvSplitter;
    pnlSearchFind: TPanel;
    lvLabels: TListView;
    Panel3: TPanel;
    Label1: TLabel;
    spBtnGetLLabel: TSpeedButton;
    spBtnApply: TSpeedButton;
    edSearch: TEdit;
    cbMask: TCheckBox;
    rcbLabelMask: TJvComboBox;
    ActionList1: TActionList;
    acAdd: TAction;
    acRemove: TAction;
    acGetLLabel: TAction;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvAssignedLabelsChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure spBtnAddClick(Sender: TObject);
    procedure spBtnRemoveClick(Sender: TObject);
    procedure lvLabelsChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure spBtnMaintainClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure HelpClick(Sender: TObject);
    procedure edSearchChange(Sender: TObject);
    procedure edSearchEnter(Sender: TObject);
    procedure spBtnGetLLabelClick(Sender: TObject);
    procedure cbMaskClick(Sender: TObject);
    procedure spBtnApplyClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FCreating: Boolean;
    MruListLabelMask: TJVCSMruList;
    procedure GetArchiveLabels;
  public
    { Public declarations }
    RevisionID,
    ModuleID,
    ModuleName: string;
    LabelsChanged: Boolean;
  end;

var
  VCSAssignLabels: TVCSAssignLabels;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSBase, VCSProcBase, DBModule, MaintainLabels, JVCSDialogs, ConfigStorage, JvJVCLUtils,
  JVCSGUIClientResources, JVCSClientFunctions;

{$R *.dfm}

procedure TVCSAssignLabels.FormCreate(Sender: TObject);
begin
  try
    Constraints.MinHeight := MulDiv(300, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(300, PixelsPerInch, 96);
    FCreating := True;
    LabelsChanged := False;

    {$IFNDEF SHOWIDS}
    lvAssignedLabels.Columns[1].Width := 0;
    lvLabels.Columns[1].Width := 0;
    {$ENDIF ~SHOWIDS}

    MruListLabelMask := TJVCSMruList.CreateEx(sBaseRegistryKey + crbMRU + '28');
    rcbLabelMask.Items.Assign(MruListLabelMask);
    acAdd.ShortCut := ShortCut(Word('A'), [ssCtrl]);
    acRemove.ShortCut := ShortCut(Word('R'), [ssCtrl]);
    acGetLLabel.ShortCut := ShortCut(Word('L'), [ssCtrl]);
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSAssignLabels.GetArchiveLabels;
var
  lvItem: TListItem;
begin
  lvLabels.Items.Clear;
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

    while (not AppSrvClient1.Answer.Eof) do 
    begin
      if (not cbMask.Checked) or MatchWithFilter(AppSrvClient1.Answer.Fields[1],
        rcbLabelMask.Text) then 
      begin
        lvItem := lvLabels.Items.Add;
        lvItem.Caption := AppSrvClient1.Answer.Fields[1];
        lvItem.SubItems.Add(AppSrvClient1.Answer.Fields[0]);
        lvItem.SubItems.Add(AppSrvClient1.Answer.Fields[2]);
        lvItem.SubItems.Add('0');
      end; // if cbMask.Checked and MatchWithFilter(Name, rcbLabelMask.Text) then begin

      AppSrvClient1.Answer.Next;
    end; // while (not AppSrvClient1.Answer.EoF)
    if lvLabels.Items.Count > 0 then
      lvLabels.Items[0].Selected := True;
    lvLabels.Items.EndUpdate;
  end; // with DataModule1 do begin

  if rcbLabelMask.Text <> '' then
  begin
    MruListLabelMask.AddString(rcbLabelMask.Text);
    rcbLabelMask.Items.Insert(0, rcbLabelMask.Text);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSAssignLabels.FormActivate(Sender: TObject);
var
  lvItem: TListItem;
begin
  Application.ProcessMessages;
  if FCreating then
  begin
    FCreating := False;
    jvcsLoadFormPosSize(Self);

    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);
    pnlMiddle.Height := jvcsReadInteger ( sBaseRegistryKey + crbWindows
                                        , 'AssignLabels_Pn1'
                                        , pnlMiddle.Height
                                        );
    pnlSearchFind.Height := jvcsReadInteger ( sBaseRegistryKey + crbWindows
                                            , 'AssignLabels_Pn1'
                                            , pnlSearchFind.Height
                                            );
    cbMask.Checked := jvcsReadBool( sBaseRegistryKey + crbWindows
                                  , 'AssignLabels_Mask'
                                  , False
                                  );

    lvAssignedLabels.Columns[0].Caption := Format(JVCSRES_Labels_assigned_to_37s, [ModuleName]);
    GetArchiveLabels;

    with DataModule1 do
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_LABELS_BY_REVISION';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [RevisionID]);
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
      lvAssignedLabels.Items.BeginUpdate;
      while (not AppSrvClient1.Answer.Eof) do
      begin
        lvItem := lvAssignedLabels.Items.Add;
        lvItem.Caption := AppSrvClient1.Answer.Fields[1];
        lvItem.SubItems.Add(AppSrvClient1.Answer.Fields[0]);
        lvItem.SubItems.Add(AppSrvClient1.Answer.Fields[2]);
        lvItem.SubItems.Add('0');
        AppSrvClient1.Answer.Next;
      end; // while (not AppSrvClient1.Answer.EoF)
      if lvAssignedLabels.Items.Count > 0 then
        lvAssignedLabels.Items[0].Selected :=
          True;
      lvAssignedLabels.Items.EndUpdate;
    end; // with DataModule1 do begin
  end; // if FCreating then begin
end;

//------------------------------------------------------------------------------

procedure TVCSAssignLabels.btnCancelClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSAssignLabels.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Keywords);
  if Key = VK_ESCAPE then
  begin
    btnCancelClick(Self);
    Key := 0;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSAssignLabels.lvLabelsChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  if lvLabels.Selected = nil then
    Exit;
  meLabelDescr.Text := lvLabels.Selected.SubItems[1];
end;

//------------------------------------------------------------------------------

procedure TVCSAssignLabels.lvAssignedLabelsChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
begin
  if lvAssignedLabels.Selected = nil then
    Exit;
  meLabelDescr.Text := lvAssignedLabels.Selected.SubItems[1];
end;

//------------------------------------------------------------------------------

procedure TVCSAssignLabels.spBtnAddClick(Sender: TObject);
var
  NewLabelID: string;
  lvItem: TListItem;
  oldRevisionID: string;
begin
  if lvLabels.Selected = nil then
    Exit;
  NewLabelID := lvLabels.Selected.SubItems[0];
  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'ADD_REMOVE_REVISION_LABEL';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [ModuleID]);
    AppSrvClient1.Request.WriteFields(False, [RevisionID]);
    AppSrvClient1.Request.WriteFields(False, [NewLabelID]);
    AppSrvClient1.Request.WriteFields(False, [True]); // add the label
    AppSrvClient1.Request.WriteFields(False, [False]); // only a check?
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
      if not MsgYesNo ( WindowHandle
                      , Format( JVCSRES_Label_6037s62_is_already_assigned_to_V_37s4637s_of_this_module46 + #13+#10+
                                        JVCSRES_Only_one_version_of_a_module_can_be_assigned_with_the_same_label46 + #13+#10+
                                        JVCSRES_Move_the_label_to_the_current_revision63
                                      , [ lvLabels.Selected.Caption
                                        , AppSrvClient1.Answer.Fields[2]
                                        , AppSrvClient1.Answer.Fields[3]
                                        ]
                                      )
                      , cMsgBoxCaption
                      , MB_ICONQUESTION
                      ) then
      begin
        Exit; // !!!
      end
      else
      begin
        oldRevisionID := AppSrvClient1.Answer.Fields[1];

        // delete the "old" label
        AppSrvClient1.Request.Rewrite;
        AppSrvClient1.FunctionCode := 'ADD_REMOVE_REVISION_LABEL';
        AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
        AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
        AppSrvClient1.Request.WriteFields(True, [ModuleID]);
        AppSrvClient1.Request.WriteFields(False, [oldRevisionID]);
        AppSrvClient1.Request.WriteFields(False, [NewLabelID]);
        AppSrvClient1.Request.WriteFields(False, [False]); // delete the label
        AppSrvClient1.Request.WriteFields(False, [False]); // only a check?
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

        // tweak fixed, has to remove this from listview
        lvItem := lvAssignedLabels.FindCaption(0,lvLabels.Selected.Caption,False,True,True);
        if Assigned(lvItem) then
          lvItem.Delete;

        // add the label
        AppSrvClient1.Request.Rewrite;
        AppSrvClient1.FunctionCode := 'ADD_REMOVE_REVISION_LABEL';
        AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
        AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
        AppSrvClient1.Request.WriteFields(True, [ModuleID]);
        AppSrvClient1.Request.WriteFields(False, [RevisionID]);
        AppSrvClient1.Request.WriteFields(False, [NewLabelID]);
        AppSrvClient1.Request.WriteFields(False, [True]); // add the label
        AppSrvClient1.Request.WriteFields(False, [False]); // only a check?
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
          MsgInfo ( WindowHandle
                  , Format( JVCSRES_Label_6037s62_is_already_assigned_to_V_37s4637s_of_this_module46 + #13+#10+
                            JVCSRES_Only_one_version_of_a_module_can_be_assigned_with_the_same_label46
                          , [ lvLabels.Selected.Caption
                            , AppSrvClient1.Answer.Fields[2]
                            , AppSrvClient1.Answer.Fields[3]
                            ]
                          )
                  , cMsgBoxCaption
                  );
        end;
      end;
    end; // if not DecodeBoolStr(....

    lvItem := lvAssignedLabels.Items.Add;
    lvItem.Caption := lvLabels.Selected.Caption;
    lvItem.SubItems.Add(lvLabels.Selected.SubItems[0]);
    lvItem.SubItems.Add(lvLabels.Selected.SubItems[1]);
    lvItem.SubItems.Add('0');
  end; // with DataModule1 do begin
  LabelsChanged := True;
  jvcsWriteString(sBaseRegistryKey + crbMRU, 'Label', lvLabels.Selected.Caption);
end;

//------------------------------------------------------------------------------

procedure TVCSAssignLabels.spBtnRemoveClick(Sender: TObject);
var
  RemoveLabelID: string;
begin
  if lvAssignedLabels.Selected = nil then
    Exit;
  UseRegistry := True;

  DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
  if DSAIdentsMessageDlg( Format( JVCSRES_Are_you_sure_you_want_to_remove_label_6037s62 + #13+#10 +
                                  JVCSRES_from_6037s6263
                                , [lvAssignedLabels.Selected.Caption, ModuleName]
                                )
                        , mtConfirmation
                        , [mbYes, mbNo, mbCancel]
                        , 0
                        , sBaseRegistryKey + crbMRU + 'Dlgs'
                        , 'RmvRevLabel'
                        , idYes) <> idYes then
                        Exit;
  RemoveLabelID := lvAssignedLabels.Selected.SubItems[0];
  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'ADD_REMOVE_REVISION_LABEL';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [ModuleID]);
    AppSrvClient1.Request.WriteFields(False, [RevisionID]);
    AppSrvClient1.Request.WriteFields(False, [RemoveLabelID]);
    AppSrvClient1.Request.WriteFields(False, [False]); // remove the label
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

    lvAssignedLabels.Selected.Delete;
  end; // with DataModule1 do begin
  LabelsChanged := True;
end;

//------------------------------------------------------------------------------

procedure TVCSAssignLabels.spBtnMaintainClick(Sender: TObject);
var
  ArchiveLabelsChanged: Boolean;
begin
  VCSMaintainLabels := TVCSMaintainLabels.Create(Application);
  try
    VCSMaintainLabels.Left := Left + 40;
    VCSMaintainLabels.Top := Top + 40;
    VCSMaintainLabels.ShowModal;
    ArchiveLabelsChanged := VCSMaintainLabels.LabelsChanged;
  finally
    VCSMaintainLabels.Free;
  end;
  if ArchiveLabelsChanged then
    GetArchiveLabels;
end;

//------------------------------------------------------------------------------

procedure TVCSAssignLabels.FormResize(Sender: TObject);
begin
  {$IFNDEF SHOWIDS}
  lvAssignedLabels.Columns[0].Width := Width - 35;
  lvLabels.Columns[0].Width := Width - 35;
  {$ENDIF ~SHOWIDS}
end;

//------------------------------------------------------------------------------

procedure TVCSAssignLabels.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  jvcsSaveFormPosSize(Self);
  jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'AssignLabels_Pn1', pnlMiddle.Height);
  jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'AssignLabels_Pn1', pnlSearchFind.Height);  
  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'AssignLabels_Mask', cbMask.Checked);
end;

//------------------------------------------------------------------------------

procedure TVCSAssignLabels.HelpClick(Sender: TObject);
var
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyUp(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSAssignLabels.edSearchChange(Sender: TObject);
var 
  I: Integer;
  lvItem: TListItem;
begin
  if (lvLabels.Items.Count = 0) then 
    Exit;
  lvItem := lvLabels.FindCaption(0, edSearch.Text, True, True, False);
  if lvItem <> nil then 
  begin
    lvItem.Selected := True;
    with lvLabels do 
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
    end; // with lvLabels do begin
  end // if lvItem <> nil then begin
  else 
    lvLabels.Selected := nil;
end;

//------------------------------------------------------------------------------

procedure TVCSAssignLabels.edSearchEnter(Sender: TObject);
begin
  edSearch.SelStart := 0;
  edSearch.SelLength := Length(edSearch.Text);
end;

//------------------------------------------------------------------------------

procedure TVCSAssignLabels.spBtnGetLLabelClick(Sender: TObject);
var 
  LastLabel: string;
begin
  LastLabel := jvcsReadString(sBaseRegistryKey + crbMRU, 'Label', '');
  if LastLabel <> '' then
    edSearch.Text := LastLabel
  else
    MsgInfo ( WindowHandle
            , Format( JVCSRES_MRU_item_6037s62_is_blank46
                              , [JVCSRES_Last_Label]
                    )
            , cMsgBoxCaption
            );
end;

//------------------------------------------------------------------------------

procedure TVCSAssignLabels.cbMaskClick(Sender: TObject);
begin
  rcbLabelMask.Enabled := cbMask.Checked;
end;

//------------------------------------------------------------------------------

procedure TVCSAssignLabels.spBtnApplyClick(Sender: TObject);
begin
  GetArchiveLabels;
end;

procedure TVCSAssignLabels.FormDestroy(Sender: TObject);
begin
  MruListLabelMask.Free;
end;

end.
