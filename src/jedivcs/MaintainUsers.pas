(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: MaintainUsers.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS: Thomas Huber (Thomas_D_Huber@gmx.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
ToDo
- make text in ExportUserList1Click resourcestrings?
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FreeVCS code to JEDI VCS
2003/03/05  THensle   - changes for "ConfigStorage" unit
2003/08/08  THuber    - mantis #861: replaced TMemo with TJvMemo
                      - formstorage changed
                      - JEDI VCS
2003/12/27  THuber    - CryptDLL loaded over JVCSCrypt now
                      - MsgDialogCaptions changed to const
2004/02/24  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/30  USchuster - style cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/11/03  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
2005/07/09  CSchuette - fixed problem loading listview columns (mantis #3063)
2005/07/11  FHasovic  - Fixed error made on fixing mantis #3063
                        Now JediVCS runs fine compiled with Delphi 2005
2007/06/17  USchuster - fixed self handled shortcuts
2007/06/30  USchuster - changes for large fonts (contraints size depend now on PixelsPerInch; analog to Mantis #3710)
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit MaintainUsers;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, Buttons, Menus, ImgList, JvMemo, JVCSForms,
  JvExStdCtrls;

const
  WM_REFRESHUSERLIST = WM_USER + 1;

type
  TVCSMaintainUsers = class(TJVCSForm)
    lvUsers: TListView;
    Splitter1: TSplitter;
    PopupMenu2: TPopupMenu;
    Add1: TMenuItem;
    Edit1: TMenuItem;
    Delete1: TMenuItem;
    N1: TMenuItem;
    Labelusedby1: TMenuItem;
    StateImageList: TImageList;
    ImageList1: TImageList;
    Logout1: TMenuItem;
    N2: TMenuItem;
    Changepassword1: TMenuItem;
    N3: TMenuItem;
    Report1: TMenuItem;
    Panel3: TPanel;
    Panel4: TPanel;
    Label1: TLabel;
    Label3: TLabel;
    edIP: TEdit;
    cbLevel: TComboBox;
    spBtnEditIP: TSpeedButton;
    meDescr: TJvMemo;
    Panel1: TPanel;
    spBtnAdd: TSpeedButton;
    spBtnRemove: TSpeedButton;
    spBtnPassword: TSpeedButton;
    Help: TSpeedButton;
    btnCancel: TButton;
    btnOK: TButton;
    ExportUserList1: TMenuItem;
    N4: TMenuItem;
    InsertEMailAddresse1: TMenuItem;
    HidedeletedUsers1: TMenuItem;
    N5: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvUsersChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure lvUsersEdited(Sender: TObject; Item: TListItem;
      var S: string);
    procedure meDescrChange(Sender: TObject);
    procedure spBtnAddClick(Sender: TObject);
    procedure spBtnRemoveClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Labelusedby1Click(Sender: TObject);
    procedure cbLevelChange(Sender: TObject);
    procedure PopupMenu2Popup(Sender: TObject);
    procedure Logout1Click(Sender: TObject);
    procedure edIPChange(Sender: TObject);
    procedure spBtnPasswordClick(Sender: TObject);
    procedure Edit1Click(Sender: TObject);
    procedure spBtnEditIPClick(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure Report1Click(Sender: TObject);
    procedure ExportUserList1Click(Sender: TObject);
    procedure InsertEMailAddresse1Click(Sender: TObject);
    procedure HidedeletedUsers1Click(Sender: TObject);
  private
    { Private declarations }
    FCreating: Boolean;
    procedure SaveChanges;
    procedure WMRefreshUserlist(var Msg: TMessage); message WM_REFRESHUSERLIST;
  public
    { Public declarations }
    LabelsChanged: Boolean;
  end;

var
  VCSMaintainUsers: TVCSMaintainUsers;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSBase, VCSProcBase, DBModule, AddNewUser, ChangeUserPW, Std_ListView,
  JVCSCrypt, JVCSClientConsts, 
  EditIP, LoadModule, SimpleReport, TZHandling, ConfigStorage, JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSMaintainUsers.FormCreate(Sender: TObject);
begin
  try
    Constraints.MinHeight := MulDiv(225, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(295, PixelsPerInch, 96);
    FCreating := True;
    LabelsChanged := False;

    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    Panel3.Height :=
      jvcsReadInteger(sBaseRegistryKey + crbWindows, 'MaintainUsers_Pn1', 145);

    HidedeletedUsers1.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'HideDelUsr', False);

    {$IFNDEF SHOWIDS}
    lvUsers.Columns[1].Width := 0;
    {$ENDIF ~SHOWIDS}
    Screen.Cursors[cPopUpMCursor] := LoadCursor(hInstance, PChar('CURSORRM'));
    lvUsers.Cursor := cPopUpMCursor;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainUsers.FormActivate(Sender: TObject);
begin
  PostMessage(Handle, WM_REFRESHUSERLIST, 0, 0);
  FormResize(Sender);
end;

procedure TVCSMaintainUsers.WMRefreshUserlist(var Msg: TMessage);
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
      AppSrvClient1.FunctionCode := 'GET_USERLIST';
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
      lvUsers.Items.BeginUpdate;
      while (not AppSrvClient1.Answer.Eof) do 
      begin
        if (not HidedeletedUsers1.Checked) or
          (AppSrvClient1.Answer.Fields[4] <> '1') then 
        begin
          LVItem := lvUsers.Items.Add;
          LVItem.Caption := AppSrvClient1.Answer.Fields[1];
          LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[0]);
          LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[5]);
          LVItem.SubItems.Add('0');
          LVItem.SubItems.Add('');
          LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[2]);
          LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[6]);
          LVItem.ImageIndex := _StrToInt(AppSrvClient1.Answer.Fields[2]);
          if AppSrvClient1.Answer.Fields[4] <> '1' then 
          begin
            if AppSrvClient1.Answer.Fields[0] = AppSrvClient1.Answer.Fields[3] then
              LVItem.StateIndex := 0 
            else 
              LVItem.StateIndex := -1;
          end 
          else 
            LVItem.StateIndex := 1;
        end; // if (not HidedeletedUsers1.Checked) or...
        AppSrvClient1.Answer.Next;
      end; // while (not AppSrvClient1.Answer.EoF)
      lvUsers.Items.EndUpdate;
      if lvUsers.Items.Count > 0 then 
        lvUsers.Items[0].Selected := True;
    end; // with DataModule1 do begin
  end; // if FCreating then begin
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainUsers.SaveChanges;
var
  I: Integer;
begin
  for I := 0 to lvUsers.Items.Count - 1 do 
  begin
    if (lvUsers.Items[I].SubItems[2] = '1') then 
    begin
      with DataModule1 do 
      begin
        AppSrvClient1.Request.Rewrite;
        AppSrvClient1.FunctionCode := 'ADD_UPDATE_USER';
        AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
        AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
        AppSrvClient1.Request.WriteFields(True,
          [lvUsers.Items[I].SubItems[0]]);
        AppSrvClient1.Request.WriteFields(False,
          [lvUsers.Items[I].Caption]);
        AppSrvClient1.Request.WriteFields(False,
          [lvUsers.Items[I].SubItems[3]]);
        AppSrvClient1.Request.WriteFields(False,
          [lvUsers.Items[I].SubItems[4]]);
        AppSrvClient1.Request.WriteFields(False,
          [lvUsers.Items[I].SubItems[1]]);
        AppSrvClient1.Request.WriteFields(False,
          [lvUsers.Items[I].SubItems[5]]);
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
          MessageBox(Handle, PChar(AppSrvClient1.Answer.Fields[1]),
            cMsgBoxCaption, MB_OK or MB_ICONSTOP);
      end; // with DataModule1 do begin
      LabelsChanged := True;
    end; // if lvUsers.Items[I].SubItems[2] := '1' then begin
  end; // for I := 0 to lvUsers.Items.Count - do begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainUsers.btnOKClick(Sender: TObject);
begin
  if lvUsers.IsEditing then 
  begin
    lvUsers.Selected.CancelEdit;
    Exit;
  end;
  SaveChanges;
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainUsers.btnCancelClick(Sender: TObject);
var 
  Changed: Boolean;
  I, DlgResult: Integer;
begin
  Changed := False;
  for I := 0 to lvUsers.Items.Count - 1 do
    if (lvUsers.Items[I].SubItems[2] = '1') then 
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

procedure TVCSMaintainUsers.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_VC_Administrator);
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

procedure TVCSMaintainUsers.lvUsersChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
begin
  if lvUsers.Selected = nil then 
    Exit;
  meDescr.Text := lvUsers.Selected.SubItems[1];
  cbLevel.ItemIndex := _StrToInt(lvUsers.Selected.SubItems[4]);
  edIP.Text := lvUsers.Selected.SubItems[5];
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainUsers.lvUsersEdited(Sender: TObject;
  Item: TListItem; var S: string);
begin
  if lvUsers.Selected = nil then 
    Exit;
  Item.SubItems[2] := '1';
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainUsers.meDescrChange(Sender: TObject);
begin
  if (lvUsers.Selected = nil) or
    (lvUsers.Selected.SubItems[1] = meDescr.Text) then 
    Exit;
  lvUsers.Selected.SubItems[1] := meDescr.Text;
  lvUsers.Selected.SubItems[2] := '1';
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainUsers.cbLevelChange(Sender: TObject);
begin
  if (lvUsers.Selected = nil) or
    (lvUsers.Selected.SubItems[4] = IntToStr(cbLevel.ItemIndex)) then 
    Exit;
  lvUsers.Selected.SubItems[4] := IntToStr(cbLevel.ItemIndex);
  lvUsers.Selected.ImageIndex := cbLevel.ItemIndex;
  lvUsers.Selected.SubItems[2] := '1';
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainUsers.edIPChange(Sender: TObject);
begin
  if (lvUsers.Selected = nil) or
    (lvUsers.Selected.SubItems[5] = edIP.Text) then
    Exit;
  lvUsers.Selected.SubItems[5] := edIP.Text;
  lvUsers.Selected.SubItems[2] := '1';
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainUsers.spBtnAddClick(Sender: TObject);
var 
  NewUserName, NewUserPW, NewUserIP, NewUserID, NewUserDescr: string;
  NewUserLevel: Integer;
  LVItem: TListItem;
begin
  VCSAddUser := TVCSAddUser.Create(Application);
  try
    VCSAddUser.Left := Left + 40;
    VCSAddUser.Top := Top + 40;
    VCSAddUser.ShowModal;
    NewUserName := VCSAddUser.UserName;
    NewUserPW := VCSAddUser.UserPW;
    NewUserIP := VCSAddUser.UserIP;
    NewUserDescr := VCSAddUser.UserDescr;
    NewUserLevel := VCSAddUser.UserLevel;
  finally
    VCSAddUser.Free;
  end;
  if NewUserName <> '' then 
  begin
    NewUserID := '';

    // Call from JVCSCrypt
    if LoadFVCSCrypt(sDLLDirectory + cCryptDLLName) then
    begin
      NewUserPW := fvcsCliEncrypt1(NewUserPW);
    end
    else
    begin
      MessageBox( Application.Handle
        , PChar(Format(JVCSRES_Fatal_Error58_JEDI_VCS_cannot_load_the_library58 + #13#10 +
        '<%s>.' + #13#10 +
        JVCSRES_Terminate_the_program44_make_sure_that_this_file_exists_in_the + #13#10 +
        JVCSRES_application_folder_and_retry46
                                    , [sDLLDirectory + cCryptDLLName]
                                    )
                        )
                , cMsgBoxCaption
                , MB_OK or MB_ICONSTOP
                );
      Exit;
    end;
    { 
    DLLHandle := LoadLibrary(PChar(sDLLDirectory + 'F V C S Crypt.dll'));
    try
      if DLLHandle = 0 then
      begin
        SysUtils.Beep;
        // Fatal Error: Unable to load library <%s>.
        MessageBox(Application.Handle, PChar(FmtLoadStr(36,
          [sDLLDirectory + 'F V C S Crypt.dll'])), cMsgBoxCaption, mb_OK or mb_IconStop);
        Exit;
      end;
      FuncPtr := GetProcAddress(DLLHandle, 'fvcs_Encrypt1');
      if FuncPtr <> nil then
      begin @fvcsEncrypt1 := FuncPtr;
        NewUserPW := fvcsEncrypt1(NewUserPW);
      end // if FuncPtr <> nil then begin
      else
      begin
        SysUtils.Beep;
        // Fatal Error: Unable to map the external procedure <%s>.
        MessageBox(Application.Handle, PChar(FmtLoadStr(37, ['fvcs_Encrypt1'])),
          'F V C S Crypt.dll', mb_OK or MB_IconStop);
        FreeLibrary(DLLHandle);
        Exit;
      end; // else if FuncPtr <> nil then begin
    finally
      FreeLibrary(DLLHandle);
    end;
     }

    with DataModule1 do 
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'ADD_UPDATE_USER';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [0]);
      AppSrvClient1.Request.WriteFields(False, [NewUserName]);
      AppSrvClient1.Request.WriteFields(False, [NewUserPW]);
      AppSrvClient1.Request.WriteFields(False, [NewUserLevel]);
      AppSrvClient1.Request.WriteFields(False, [NewUserDescr]);
      AppSrvClient1.Request.WriteFields(False, [NewUserIP]);
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

      NewUserID := '';
      if DecodeBoolStr(AppSrvClient1.Answer.Fields[0]) then
        NewUserID := AppSrvClient1.Answer.Fields[2]
      else 
        MessageBox(Handle, PChar(AppSrvClient1.Answer.Fields[1]),
          cMsgBoxCaption, MB_OK or MB_ICONSTOP);
    end; // with DataModule1 do begin
    if NewUserID <> '' then 
    begin
      LVItem := lvUsers.Items.Add;
      LVItem.Caption := NewUserName;
      LVItem.StateIndex := -1;
      LVItem.SubItems.Add(NewUserID);
      LVItem.SubItems.Add(NewUserDescr);
      LVItem.SubItems.Add('0');
      LVItem.SubItems.Add('');
      LVItem.SubItems.Add(IntToStr(NewUserLevel));
      LVItem.SubItems.Add(NewUserIP);
      LVItem.ImageIndex := NewUserLevel;
      LabelsChanged := True;
    end;
  end; // if NewFamilyName <> '' then begin
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainUsers.spBtnRemoveClick(Sender: TObject);
var 
  I, AAdmins: Integer;
  HasLockedModules: Boolean;
begin
  if lvUsers.Selected = nil then
    Exit;
  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_LOCKED_MODULES';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [0]); // from all projects
    AppSrvClient1.Request.WriteFields(False, [lvUsers.Selected.SubItems[0]]);
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
    HasLockedModules := not AppSrvClient1.Answer.Eof;
  end; // with DataModule1 do begin
  if HasLockedModules then 
  begin
    if MessageBox(WindowHandle, PChar(Format('<%s>' + #13#10 +
       JVCSRES_There_are_already_modules_locked_by_this_user46 + #13#10 +
       JVCSRES_If_you_delete_the_user_now_you_will_be_unable_to_check_in_these_modules46 + #13#10 +
       JVCSRES_Continue63, [lvUsers.Selected.Caption])),
      cMsgBoxCaption, MB_YESNOCANCEL or MB_DEFBUTTON2 or MB_ICONWARNING) <> id_Yes then 
      Exit;
  end;
  if lvUsers.Selected.SubItems[4] = '4' then
  begin
    AAdmins := 0;
    for I := 0 to lvUsers.Items.Count - 1 do
      if lvUsers.Items[I].SubItems[4] = '4' then 
        Inc(AAdmins);
    if AAdmins < 2 then 
    begin
      MessageBox(WindowHandle, PChar(Format('<%s>' + #13#10 +
        JVCSRES_This_is_the_only_archive_administrator_registered_in_the_archive46 + #13#10 +
        JVCSRES_You_cannot_delete_this_user_until_a_new_archive_administrator_is_defined46, [lvUsers.Selected.Caption])),
        cMsgBoxCaption, MB_OK or MB_ICONWARNING);
      Exit;
    end; // if AAdmin < 2 then begin
  end; // if lvUsers.Selected.SubItems[4] = '4' then begin

  if MessageBox(WindowHandle, PChar(Format(JVCSRES_Are_you_sure_you_want_to_remove_user_6037s62_from_the_archive63,
    [lvUsers.Selected.Caption])),
    cMsgBoxCaption, MB_YESNOCANCEL or MB_DEFBUTTON2 or MB_ICONQUESTION) <> id_Yes then 
    Exit;

  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'REMOVE_USER';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [lvUsers.Selected.SubItems[0]]);
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
  lvUsers.Selected.StateIndex := 1;
  LabelsChanged := True;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainUsers.FormResize(Sender: TObject);
begin
  {$IFNDEF SHOWIDS}
  if lvUsers.HandleAllocated then
    lvUsers.Columns[0].Width := Width - 35;
  {$ENDIF ~SHOWIDS}
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainUsers.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
//hu 08.08.2003
{ 
  jvcsWriteWindowSize(sBaseRegistryKey + crbWindows, 'MaintainUsers',
    Width, Height);
 }
  jvcsSaveFormPosSize(Self);

  jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'MaintainUsers_Pn1',
    Panel3.Height);
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainUsers.Labelusedby1Click(Sender: TObject);
var 
  ResultString: string;
  ContainsRecords: Boolean;
begin
  if lvUsers.Selected = nil then 
    Exit;
  ContainsRecords := False;
  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_LOCKED_MODULES';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [0]); // from all projects
    AppSrvClient1.Request.WriteFields(False, [lvUsers.Selected.SubItems[0]]);
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
        AppSrvClient1.Answer.Fields[0] + ';' +
        AppSrvClient1.Answer.Fields[3] + ';' +
        AppSrvClient1.Answer.Fields[4] + ';' +
        DateTimeToStr(GMTStr2LocalDateTime(AppSrvClient1.Answer.Fields[5])) + ';|';
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
    VCSStdListView.LVRepID := 7;
    VCSStdListView.Caption := lvUsers.Selected.Caption;
    VCSStdListView.Left := Left + 60;
    VCSStdListView.Top := Top + 60;
    VCSStdListView.LVType := 5;
    VCSStdListView.HelpContextID := 0;
    VCSStdListView.AddListColumn(JVCSRES_Modules_locked_by464646, False);
    VCSStdListView.AddListColumn(JVCSRES_ID, True);
    VCSStdListView.AddListColumn(JVCSRES_Version, True);
    VCSStdListView.AddListColumn(JVCSRES_Revision, True);
    VCSStdListView.AddListColumn(JVCSRES_Locked, False);
    VCSStdListView.SetUpItems(ResultString);
    VCSStdListView.ShowModal;
  finally
    VCSStdListView.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainUsers.PopupMenu2Popup(Sender: TObject);
begin
  if lvUsers.Selected <> nil then
    Logout1.Enabled := (lvUsers.Selected.StateIndex = 0)
  else
    Logout1.Enabled := False;

  Edit1.Enabled := (lvUsers.Selected <> nil);
  Delete1.Enabled := Edit1.Enabled;
  Changepassword1.Enabled := Edit1.Enabled;
  Labelusedby1.Enabled := Edit1.Enabled;
  InsertEMailAddresse1.Enabled := Edit1.Enabled;
  ExportUserList1.Enabled := (lvUsers.Items.Count > 0);
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainUsers.Logout1Click(Sender: TObject);
begin
  if lvUsers.Selected = nil then 
    Exit;
  if MessageBox(WindowHandle,
    PChar(Format(JVCSRES_Log_out_user_6037s62_63, [lvUsers.Selected.Caption])), cMsgBoxCaption,
    MB_YESNOCANCEL or MB_DEFBUTTON2 or MB_ICONQUESTION) <> id_Yes then
    Exit;

  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'LOGOUT';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [lvUsers.Selected.SubItems[0]]);
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

    lvUsers.Selected.StateIndex := -1;
  end; // with DataModule1 do begin
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainUsers.spBtnPasswordClick(Sender: TObject);
var 
  OldPassword, NewPassword: string;
  ServerTime: Double;
begin
  if lvUsers.Selected = nil then 
    Exit;
  VCSChangeUserPW := TVCSChangeUserPW.Create(Application);
  try
    VCSChangeUserPW.Left := Left + 40;
    VCSChangeUserPW.Top := Top + 40;
    VCSChangeUserPW.User := lvUsers.Selected.Caption;
    VCSChangeUserPW.ShowModal;
    OldPassword := VCSChangeUserPW.OldPassword;
    NewPassword := VCSChangeUserPW.NewPassword;
  finally
    VCSChangeUserPW.Free;
  end;
  if OldPassword <> '' then 
  begin
    with DataModule1 do
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_SERVER_TIME';
      AppSrvClient1.Request.WriteFields(True, [-1]);
      AppSrvClient1.Request.WriteFields(False, [-1]);
      SetupTimeoutCounter;
      AppSrvClient1.Send;

      while WaitForAppSrvClient do
        Application.ProcessMessages;
      if (AppSrvClientErr = -99) then 
      begin
        ShowServerTimeOut(WindowHandle);
        Exit;
      end;
      if (AppSrvClientErr <> 0) or (AppSrvClient1.AnswerStatus <> '200') then 
      begin
        ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
          AppSrvClient1.AnswerStatus);
        Exit;
      end;

      AppSrvClient1.Answer.First;
      ServerTime := 0;
      if not AppSrvClient1.Answer.Eof then
        ServerTime := _StrToFloat(AppSrvClient1.Answer.Fields[0]);

      // Call from JVCSCrypt
      if LoadFVCSCrypt(sDLLDirectory + cCryptDLLName) then
      begin
        OldPassword := fvcsCliEncrypt2(OldPassword, ServerTime);
        NewPassword := fvcsCliEncrypt1(NewPassword);
      end
      else
      begin
        MessageBox( Application.Handle
          , PChar(Format(JVCSRES_Fatal_Error58_JEDI_VCS_cannot_load_the_library58 + #13#10 +
          '<%s>.' + #13#10 +
          JVCSRES_Terminate_the_program44_make_sure_that_this_file_exists_in_the + #13#10 +
          JVCSRES_application_folder_and_retry46
                                      , [sDLLDirectory + cCryptDLLName]
                                      )
                          )
                  , cMsgBoxCaption
                  , MB_OK or MB_ICONSTOP
                  );
        Exit;
      end;

      (*
      DLLHandle := LoadLibrary(PChar(sDLLDirectory + 'FVCSCrypt.dll'));
      if DLLHandle = 0 then
      begin
        SysUtils.Beep;
        // Fatal Error: Unable to load library <%s>.
        MessageBox(Application.Handle, PChar(FmtLoadStr(36,
          [sDLLDirectory + 'FVCSCrypt.dll'])), cMsgBoxCaption, mb_OK or mb_IconStop);
        Exit;
      end;
      FuncPtr := GetProcAddress(DLLHandle, 'fvcs_Encrypt2');
      if FuncPtr <> nil then
      begin @fvcsEncrypt2 := FuncPtr;
        OldPassword := fvcsEncrypt2(OldPassword, ServerTime);
      end // if FuncPtr <> nil then begin
      else
      begin
        SysUtils.Beep;
        // Fatal Error: Unable to map the external procedure <%s>.
        MessageBox(Application.Handle, PChar(FmtLoadStr(37, ['fvcs_Encrypt2'])),
          'FVCSCrypt.dll', mb_OK or MB_IconStop);
        FreeLibrary(DLLHandle);
        Exit;
      end; // else if FuncPtr <> nil then begin}
      FuncPtr := GetProcAddress(DLLHandle, 'fvcs_Encrypt1');
      if FuncPtr <> nil then
      begin @fvcsEncrypt1 := FuncPtr;
        NewPassword := fvcsEncrypt1(NewPassword);
      end // if FuncPtr <> nil then begin
      else
      begin
        SysUtils.Beep;
        // Fatal Error: Unable to map the external procedure <%s>. 
        MessageBox(Application.Handle, PChar(FmtLoadStr(37, ['fvcs_Encrypt1'])),
          'FVCSCrypt.dll', mb_OK or MB_IconStop);
        FreeLibrary(DLLHandle);
        Exit;
      end; // else if FuncPtr <> nil then begin
      FreeLibrary(DLLHandle);
      *)

      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'CHANGE_PASSWORD';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [lvUsers.Selected.SubItems[0]]);
      AppSrvClient1.Request.WriteFields(False, [OldPassword]);
      AppSrvClient1.Request.WriteFields(False, [NewPassword]);
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
      begin
        MessageBox(Handle, PChar(JVCSRES_Password_successfully_changed46), cMsgBoxCaption,
          MB_OK or MB_ICONINFORMATION);
      end 
      else 
      begin
        BeepIfSet;
        MessageBox(Handle, PChar(AppSrvClient1.Answer.Fields[1]), cMsgBoxCaption,
          MB_OK or MB_ICONSTOP);
      end;
    end; // with DataModule1 do begin
  end; // if OldPassword <> '' then begin
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainUsers.Edit1Click(Sender: TObject);
begin
  if lvUsers.Selected = nil then
    Exit;
  lvUsers.Selected.EditCaption;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainUsers.spBtnEditIPClick(Sender: TObject);
begin
  VCSEditIP := TVCSEditIP.Create(Application);
  try
    VCSEditIP.Left := Left + 40;
    VCSEditIP.Top := Top + 40;
    VCSEditIP.IPAddress := edIP.Text;
    if VCSEditIP.ShowModal = mrOk then
      edIP.Text := VCSEditIP.IPAddress;
  finally
    VCSEditIP.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainUsers.HelpClick(Sender: TObject);
var
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyUp(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainUsers.Report1Click(Sender: TObject);
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
    with lvUsers do 
    begin
      if Items.Count = 0 then 
      begin
        MessageBox(WindowHandle, PChar(JVCSRES_Requested_result_set_is_blank46_Nothing_to_do46), cMsgBoxCaption, MB_OK);
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
      end; // for I := 0 to Columns.Count - 1 do begin

      ResultString := Caption + cr;
      CurrentText := '';
      while Length(CurrentText) < Length(Caption) do
        CurrentText := CurrentText + '=';
      ResultString := ResultString + CurrentText + cr + cr;
      ResultString := ResultString + Format(JVCSRES_37d_entries46, [Items.Count]) + cr + cr;

      for J := 0 to Columns.Count - 1 do
      begin
        ResultString := ResultString + SizeString(J, Columns[J].Caption, ' ');
        if J < (Columns.Count - 1) then 
          ResultString := ResultString + ' | ';
      end;
      ResultString := ResultString + cr;
      for J := 0 to Columns.Count - 1 do 
      begin
        ResultString := ResultString + SizeString(J, '-', '-');
        if J < (Columns.Count - 1) then 
          ResultString := ResultString + ' | ';
      end;
      ResultString := ResultString + cr;

      for I := 0 to Items.Count - 1 do
      begin
        for J := 0 to Columns.Count - 1 do 
        begin
          if J = 0 then 
            CurrentText := Items[I].Caption
          else 
            CurrentText := Items[I].SubItems[J - 1];
          ResultString := ResultString + SizeString(J, CurrentText, ' ');
          if J < (Columns.Count - 1) then 
            ResultString := ResultString + ' | ';
        end; // for J := 0 to Columns.Count - 1 do begin
        ResultString := ResultString + cr;
      end; // for I := 0 to Items.Count - 1 do begin
    end; // with elv do begin

    ResultString := ResultString + cr + JVCSRES_Source58_ + sArchiveSource + cr +
      cMsgBoxCaption + ' ' + sProductVer + cProductInf + DateTimeToStr(Now) + cr;
  finally
    Screen.Cursor := crDefault;
    SetLength(oaColumnsWidth, 0);
  end;

  VCSSimpleReport := TVCSSimpleReport.Create(Application);
  try
    VCSSimpleReport.RepID := 6;  
    VCSSimpleReport.Left := Left + 60;
    VCSSimpleReport.Top := Top + 60;
    VCSSimpleReport.FullReportString := ResultString;
    VCSSimpleReport.SavePath := ExtractFileDir(sProjectName);
    VCSSimpleReport.SaveFileName := 'UserList.txt';
    VCSSimpleReport.LineCount := lvUsers.Items.Count + 8;
    VCSSimpleReport.ShowModal;
  finally
    VCSSimpleReport.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainUsers.ExportUserList1Click(Sender: TObject);
var
  UserNames: TStringList;
  Mailaddr, Mess: string;
  I: Integer;
begin
  UserNames := TStringList.Create;
  try
    UserNames.Add('; If you miss some addresses in this file do not change this file,');
    UserNames.Add('; instead enter the missing addresses in the User List dialog.');
    UserNames.Add('; JEDI VCS will overwrite this file the next time you select');
    UserNames.Add('; "Export List" and your changes to this file will be lost.');
    UserNames.Add('');
    UserNames.Add('[FVCSUsers]');
    for I := 0 to lvUsers.Items.Count - 1 do
    begin
      if Pos('(Deleted)', lvUsers.Items[I].Caption) = 0 then //do not localize!!! 
      begin
        Mailaddr := lvUsers.Items[I].SubItems[1];
        if Pos('[mailto:', Mailaddr) > 0 then 
        begin
          System.Delete(Mailaddr, 1, Pos('[mailto:', Mailaddr) + 7);
          Mailaddr := Copy(Mailaddr, 1, Pos(']', Mailaddr) - 1);
        end 
        else 
          Mailaddr := '?';
        UserNames.Add(lvUsers.Items[I].Caption + '=' + Mailaddr);
      end; //if Pos('(Deleted)', lvUsers.Items[I].Caption) = 0 then begin
    end;
    try
      UserNames.SaveToFile(sDLLDirectory + 'FVCSUsers.txt')
    except
      MessageBox(WindowHandle, PChar(Format(JVCSRES_JEDI_VCS_cannot_save_the_file + #13#10 +
        '<%s>.' + #13#10 +
        JVCSRES_Be_sure_that_the_file_is_not_opened_by_another_application44 + #13#10 +
        JVCSRES_that_there_is_enough_free_space_on_the_disk + #13#10 +
        JVCSRES_and_that_you_have_the_required_access_rights46,
        [sDLLDirectory + 'FVCSUsers.txt'])), cMsgBoxCaption, MB_OK or MB_ICONSTOP);
    end;
  finally
    UserNames.Free;
  end;
  MessageBox(WindowHandle, PChar(Format(JVCSRES_37s_saved_to_file + #13#10 + '<%s>.',
    [JVCSRES_User_list, sDLLDirectory + 'FVCSUsers.txt'])), cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
  ViewTheModule(WindowHandle, sDLLDirectory + 'FVCSUsers.txt', Mess);
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainUsers.InsertEMailAddresse1Click(Sender: TObject);
var 
  Address, MemoStr: string;
  StPos, EndPos: Integer;
begin
  // [mailto:PIII_700@thensle.de]
  if (Pos('[mailto:', meDescr.Text) > 0) then 
  begin
    StPos := Pos('[mailto:', meDescr.Text);
    EndPos := Pos(']', meDescr.Text);
    Address := Copy(meDescr.Text, StPos + 8, EndPos - (StPos + 8));
    if InputQuery(JVCSRES_SMTP_Mail, JVCSRES_Enter_mail_address, Address) then
    begin
      MemoStr := meDescr.Text;
      Delete(MemoStr, StPos, EndPos - StPos + 1);
      Insert('[mailto:' + Address + ']', MemoStr, StPos);
      meDescr.Text := MemoStr;
    end;
  end
  else
  begin
    Address := '';
    if InputQuery(JVCSRES_SMTP_Mail, JVCSRES_Enter_mail_address, Address) then
      meDescr.Lines.Add('[mailto:' + Address + ']');
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSMaintainUsers.HidedeletedUsers1Click(Sender: TObject);
var 
  I: Integer;
begin
  HidedeletedUsers1.Checked := not HidedeletedUsers1.Checked;
  jvcsWriteBool(sBaseRegistryKey + crbOptions, 'HideDelUsr',
    HidedeletedUsers1.Checked);
  if not HidedeletedUsers1.Checked then
    MessageBox(Handle, PChar(Format(JVCSRES_This_change_will_not_take_effect_until_you_reopen_the_37s46,
      [JVCSRES_dialog])), cMsgBoxCaption,
      MB_OK or MB_ICONINFORMATION)
  else 
  begin
    I := 0;
    with lvUsers do
    begin
      while I <= Items.Count - 1 do
      begin
        if Items[I].StateIndex = 1 then
          Items[I].Delete
        else
          Inc(I);
      end; // while I <= Items.Count - 1 do begin
    end; // with lvUsers do
  end; // else if not HidedeletedUsers1.Checked then
end;

end.
