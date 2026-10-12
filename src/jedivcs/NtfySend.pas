(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: NtfySend.pas

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
2003/08/02  THuber    - mantis #861: replaced TMemo with TJvMemo
                      - better layout (form now sizable)
                      - FormStorage changed
2004/02/24  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/26  USchuster - style cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/11/02  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
2007/06/27  USchuster - changes for large fonts (set AutoScroll to False; Mantis #1034)
2007/06/30  USchuster - changes for large fonts (added contraints)                       
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit NtfySend;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, JvMemo, JvExStdCtrls, JVCSForms;

type
  TNtfySendForm = class(TJVCSForm)
    pnlButton: TPanel;
    Help: TSpeedButton;
    btnSendM: TButton;
    Button1: TButton;
    gbMessage: TGroupBox;
    meMessage: TJvMemo;
    pnlHead: TPanel;
    plFrom: TPanel;
    Panel1: TPanel;
    cbSMTPForward: TCheckBox;
    rbToAll: TRadioButton;
    rbSingle: TRadioButton;
    edRecipient: TEdit;
    spBtnRecipient: TSpeedButton;
    procedure btnSendMClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure meMessageChange(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure spBtnRecipientClick(Sender: TObject);
    procedure rbToAllClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbSMTPForwardClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    SendMailslot,
    SendSMTP: Boolean;
  public
    { Public declarations }
    ResultStr: string;
    MailType: Word;
    procedure SetUpUserList(Value: string);
    procedure SetUpMessage(Value: string);
  end;

var
  NtfySendForm: TNtfySendForm;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  mdMailSlot, VCSBase, VCSProcBase, DBModule, SelectList, SMTPSend, TZHandling,
  ConfigStorage, JVCSGUIClientResources;

{$R *.dfm}

procedure TNtfySendForm.FormCreate(Sender: TObject);
begin
  try
    Constraints.MinHeight := MulDiv(286, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(330, PixelsPerInch, 96);
    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);
    SendSMTP := jvcsReadBool(sBaseRegistryKey + crbOptions, 'SMTPMessages', False);
    //??? GlobalSettings
    if not SettingIsGlobal(16) then
      SendMailslot :=
        jvcsReadBool(sBaseRegistryKey + crbOptions, 'NotifyActive', False)
    else
      SendMailslot := GlobalSettingValue(16);

    cbSMTPForward.Enabled := SendSMTP;
    cbSMTPForward.Checked := SendSMTP;
    rbToAll.Enabled := SendSMTP;
    rbSingle.Enabled := SendSMTP;

    plFrom.Caption := Format(JVCSRES_From58_9137s_on_37s93_37s, [sCurrentUser, LocalIPAddr,
      DateTimeToStr(Now)]);
    if not SendMailslot then
      Panel1.Caption := JVCSRES_Mailslot_notifying_disabled;
    meMessage.MaxLength := 350;
    gbMessage.Caption := Format(JVCSRES_38Message58_40max_length_37d_chars41, [meMessage.MaxLength]);
    MailType := 0;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TNtfySendForm.SetUpUserList(Value: string);
begin
  if SendSMTP then
  begin
    rbSingle.Checked := True;
    rbToAllClick(Self);
    edRecipient.Text := Value;
  end;
end;

//------------------------------------------------------------------------------

procedure TNtfySendForm.SetUpMessage(Value: string);
begin
  meMessage.Text := Value;
end;

//------------------------------------------------------------------------------

procedure TNtfySendForm.FormActivate(Sender: TObject);
begin
  jvcsLoadFormPosSize(Self);  //thu 08.08.2003
  meMessage.SetFocus;
end;

//------------------------------------------------------------------------------

procedure TNtfySendForm.btnSendMClick(Sender: TObject);
var
  Recipient: string;
begin
  if SendMailslot then
  begin
    if rbToAll.Checked then
      Recipient := JVCSRES_40to58_All41_
    else
      Recipient := Format(JVCSRES_40to58_37s41_, [edRecipient.Text]);
    {  %d|%d|%d|%s|%s|%s|%s 162
       Nr|PjID|UsrID|UsrName|Time|Res|Msg  }
    if SendSecureMail('*', sFVCSMailslot,
      Format(NtfyMsgStr, [0, 0, ServerUserID, sCurrentUser,
      LocalDT2GMTStr(Now), LocalIPAddr, Recipient + JVCSRES_User_message58 + #10 +
      meMessage.Text])) then 
      ResultStr := JVCSRES_Notify58_Send_User_defined_message_45_Success
    else 
      ResultStr := JVCSRES_Notify58_Send_User_defined_message_45_Error;
  end;

  if cbSMTPForward.Checked then 
  begin
    if rbToAll.Checked then
      Recipient := JVCSRES_42All42
    else
      Recipient := edRecipient.Text;

    if Recipient <> '' then
      PrepareSMTP(sCurrentUser, LocalIPAddr, Recipient, JVCSRES_User_defined_message,
        JVCSRES_42None42, meMessage.Text, MailType);
  end;
  ModalResult := mrOk;
end;

//------------------------------------------------------------------------------

procedure TNtfySendForm.Button1Click(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

//------------------------------------------------------------------------------

procedure TNtfySendForm.meMessageChange(Sender: TObject);
begin
  btnSendM.Enabled := meMessage.Text <> '';
end;

//------------------------------------------------------------------------------

procedure TNtfySendForm.HelpClick(Sender: TObject);
var
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TNtfySendForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Properties_Notify);
  if Key = VK_ESCAPE then 
  begin
    Button1.Click;
    Key := 0;
  end;
end;

//------------------------------------------------------------------------------

procedure TNtfySendForm.spBtnRecipientClick(Sender: TObject);
var
  I: Integer;
  SelectedUser: string;
  UserList: TStringList;
begin
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
    if not AppSrvClient1.Answer.Eof then
    begin
      UserList := TStringList.Create;
      try
        while not AppSrvClient1.Answer.Eof do
        begin
          UserList.Add(AppSrvClient1.Answer.Fields[1]);
          AppSrvClient1.Answer.Next;
        end;

        VCSSelectList := TVCSSelectList.Create(Application);
        try
          VCSSelectList.Left := Left + 40;
          VCSSelectList.Top := Top + 40;
          VCSSelectList.MultiSelect := True;
          VCSSelectList.SetCaption(JVCSRES_Select_SMTP_recipient);
          for I := 0 to UserList.Count - 1 do
            VCSSelectList.AddListItem(UserList.Strings[I]);
          VCSSelectList.ShowModal;
          SelectedUser := VCSSelectList.ResultString;
        finally
          VCSSelectList.Free;
        end;
      finally
        UserList.Free;
      end;
    end; // if not AppSrvClient1.Answer.EoF then begin
  end; // with DataModule1 do begin

  if SelectedUser <> '' then 
  begin
    edRecipient.Text := SelectedUser;
    edRecipient.SetFocus;
  end;
end;

//------------------------------------------------------------------------------

procedure TNtfySendForm.rbToAllClick(Sender: TObject);
begin
  edRecipient.Enabled := rbSingle.Checked;
  spBtnRecipient.Enabled := rbSingle.Checked;
  if edRecipient.Enabled then
    edRecipient.Color := clWindow
  else
    edRecipient.Color := clBtnFace;
end;

//------------------------------------------------------------------------------

procedure TNtfySendForm.cbSMTPForwardClick(Sender: TObject);
begin
  rbToAll.Enabled := cbSMTPForward.Checked;
  rbSingle.Enabled := cbSMTPForward.Checked;
  rbToAllClick(Self);
end;

procedure TNtfySendForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  jvcsSaveFormPosSize(Self);  //thu 08.08.2003
end;

end.
