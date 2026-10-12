(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: Create.pas

The Initial Developer of the Original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS: Thomas Huber (Thomas_D_Huber@gmx.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
ToDo
- better solution for D2005 project extensions
-----------------------------------------------------------------------------

Unit history:

2001/11/17  THuber     - Started Migration of FreeVCS code for JEDI FreeVCS
2003/02/12  USchuster  - changed DSAMsg with JVCSDialogs in uses clause to use
                         JvDSADialogs
2003/02/18  MGosselink - emptied some .text props
2003/02/18  THuber     - fixed mru bug (not hosts in combo), Taborder
2003/03/01  THensle    - added 'Server Identities' selection and storage
2003/03/02  THuber     - changed client/server handling. see vcscommon
                         (verconst.inc no longer holds ExpectedXXXServer
                         according to that, also server part changed
2003/03/05  THensle    - changes for "ConfigStorage" unit
                       - moved 'Server Identities' storage from 'Indenties.ini'
                         to standard storage object
                       - all options moved to seperated tab
                       - 'Socks' tab switched to invisible
2003/03/10  USchuster  - removed rest of Mru stuff
2003/03/11  THensle    - change to work around the missing TComboBox.OnCloseUp
                         event in D5
2003/03/15  THuber     - compilerwarnings/hints
2003/04/08  USchuster  - changes for IDEInterface
2003/05/27  USchuster  - fixed bug in server detection
                         (ExpectedServer wasn't set in non DEBUG mode)
                       - changed JEDI-VCS to JEDI VCS in unit header,
                         message boxes and in form
2003/08/31  USchuster  - fixed IDE Productionversion stuff and move it to
                         VCSProcBase.pas
2003/10/17  USchuster  - use SelfFileName for versioninformation
                       - use new constant for messagebox caption
2003/12/27  THuber     - JVCSClientFunctions included in uses
                       - Versionno passed to server now from resource
                       - CryptDLL loaded over JVCSCrypt now
2004/02/24  THuber     - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/06/28  THuber     - for #1289: server version now stored in global var
2004/07/04  USchuster  - changed server version check into a range (mantis #1899)
                       - minor style cleaning (casing and comments)
2004/09/17  FHasovic   - Added dxGetText support for localization
2004/10/31  USchuster  - localization of Fikret Hasovic from newideas project
                         with over IFDEF LANGUAGE
                       - res strings and displayed strings changed to resourcestrings
2004/11/05  USchuster  - moved resourcestrings to JVCSGUIClientResources.pas
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC1 was released ^^^^^^^^^^^^^^^^^^^^^^^^^^^
2005/02/26  THuber     - s A p p D i r e c t o r y no more necessary
2005/04/11  CSchuette  - mantis #2815
2005/04/17  USchuster  - temporary workaround for D2005 in order to support
                         Delphi.Net and C# Personality
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC2 was released ^^^^^^^^^^^^^^^^^^^^^^^^^^^
2005/06/04  USchuster  - set label charset to DEFAULT_CHARSET(necessary for LANGUAGE version)
2005/06/30  CSchuette  - fixed displayed version number - same as ProjAdmin Caption now.
2007/04/27  USchuster  - changes for D2007
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.41 stable was released ^^^^^^^^^^^^^^^^^^^^^^^^
2007/05/12  CSchiffler - fixed Mantis #4124 - Ping component is now dynamic.
2007/06/17  USchuster  - fixed self handled shortcuts
2007/06/21  USchuster  - changes for C++Builder 2007 (Mantis #4157)
2007/08/13  USchuster  - Trace -> TraceMsg
2008/07/01  USchuster  - moved crbIdentity to VCSBase.pas
2008/12/22  THuber     - Baseclass changed to TJVCSForm
2009/01/01  USchuster  - changes for D2009
2009/01/18  THuber     - changed caption & application.title to have identity included #4618
2010/01/24  THuber     - Directive B L O W F I S H removed as we use Blowfish-encryption always
2011/01/15  USchuster  - changed font to Tahoma
2012/07/08  AKroeber   - read settings for external bugtracker
2012/09/02  AKroeber   - read settings for SaveWIP

-----------------------------------------------------------------------------*)

unit Create;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  BFCrypt,
  {$IFDEF DEBUG}
  JclDebug,
  {$ENDIF DEBUG}
  {$IFDEF OVERBYTEV6_UP}
  OverbyteIcsPing, OverbyteIcsIcmp,
  {$ELSE}
  Ping, Icmp,
  {$ENDIF OVERBYTEV6_UP}
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Menus, Buttons, ComCtrls, RFormat,
  ApsCli,
  JvCombobox, JvEdit, JvExStdCtrls, JVCSForms;

type
  TVCSLoad = class(TJVCSForm)
    btnCancel: TButton;
    btnOpen: TButton;
    Panel1: TPanel;
    Label2: TLabel;
    lblVersion: TLabel;
    lblOs: TLabel;
    PageControl1: TPageControl;
    SheetAppServer: TTabSheet;
    SheetSocks: TTabSheet;
    GroupBox3: TGroupBox;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    SocksServerEdit: TEdit;
    SocksPortEdit: TEdit;
    SocksUsercodeEdit: TEdit;
    SocksPasswordEdit: TEdit;
    SocksAuthCheckBox: TCheckBox;
    lblSrvMsg: TLabel;
    LoginTimer: TTimer;
    Help: TSpeedButton;
    ReConnectTimer: TTimer;
    SheetOptions: TTabSheet;
    spBtnPing: TSpeedButton;
    GroupBox1: TGroupBox;
    Label3: TLabel;
    cbxIdentity: TComboBox;
    spBtnAddID: TSpeedButton;
    spBtnRmvID: TSpeedButton;
    PortEdit: TEdit;
    Label6: TLabel;
    ServerEdit: TEdit;
    Label4: TLabel;
    Label1: TLabel;
    Label12: TLabel;
    pwUserPasswordEdit: TJvEdit;
    UserEdit: TEdit;
    GroupBox2: TGroupBox;
    cbUseCurrentIP: TCheckBox;
    cbAutologin: TCheckBox;
    cbSavePW: TCheckBox;
    cbSyncServerTime: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnOpenClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure HelpTopic1Click(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure LoginTimerTimer(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure spBtnPingClick(Sender: TObject);
    procedure Ping1EchoReply(Sender, Icmp: TObject; Error: Integer);
    procedure UserPasswordEditChange(Sender: TObject);
    procedure ReConnectTimerTimer(Sender: TObject);
    procedure cbSyncServerTimeClick(Sender: TObject);
    procedure cbUseCurrentIPClick(Sender: TObject);
    procedure spBtnAddIDClick(Sender: TObject);
    procedure spBtnRmvIDClick(Sender: TObject);
    procedure IDChanged(Sender: TObject);
    procedure cbxIdentityKeyPress(Sender: TObject; var Key: Char);
    procedure cbSavePWClick(Sender: TObject);
    procedure cbxIdentityChange(Sender: TObject);
  private
    { Private-Deklarationen }
    OpenDelay: Integer;
    FCreating,
    FAutoOpen,
    Connected,
    ReConnectFlag,
    Send_Messages,
    Send_SMTP: Boolean;
    IdCBIndex: Integer;
    ServerTime: Double;
    // CSchiffler: moved ping here to be dynamically created (Mantis #4124)
    Ping1: TPing;
    function SyncToServerTime: Boolean;
    function GetLocalIP: string;
    procedure ConnectOK;
    procedure EnableControls(const Enable: Boolean);
    //THe improved Identies function
    procedure UseCurrentIP;
    procedure PrepareIdentityBox;
    procedure ReadIdentity(IdentityName: string);
    procedure UpdateIdentity;
    {procedure GetGlobalSettings;}

  public
    { Public-Deklarationen }
  end;

//  TfvcsEncrypt2 = function(Value: ShortString; Key: Double): ShortString;

var
  VCSLoad: TVCSLoad;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  Vcsbase, VCSCommon, VCSProcBase, JVCSDialogs, mdMailSlot, DBModule, ShellAPI,
  Winsock, SMTPSend, TZHandling, GetGlobalSettings,
  JVCSClientFunctions, JVCSCrypt, JVCSClientConsts,
  JclSysInfo, JclFileUtils, JclSecurity, JclWin32, ConfigStorage, JVCSGUIClientResources;

{$R *.dfm}

//------------------------------------------------------------------------------
procedure TVCSLoad.FormCreate(Sender: TObject);
var
  DlgTop,
  DlgLeft: Integer;
  JclFileVersionInfo: TJclFileVersionInfo;
begin
  try
    FCreating := True;
    Connected := False;
    ReConnectFlag := False;
    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);
    // Abfrage nach Zeitverzögerung (Registry-Hack)
    if jvcsReadBool(sBaseRegistryKey, 'DlgNoWait', False) then
      LoginTimer.Interval := 1;

    // Version
    //THu - changed to TJclFileVersionInfo
    if FileExists(GetSelfFileName) then
    begin
      JclFileVersionInfo := TJclFileVersionInfo.Create(GetSelfFileName);
      try
        sProductVer := JclFileVersionInfo.FileVersion;
        jvcsWriteString(cRegSwJVCSBase, 'ProgramVersion', sProductVer);
        if Pos('dev', sProductVer) > 0 then
        begin
          lblVersion.Caption := 'V ' + sProductVer + '   **Developer Version**';
          lblVersion.Font.Color := clRed;
        end
        else
          lblVersion.Caption := 'V ' + sProductVer;

        lblOs.Caption := GetProductAndOSVersionString;
        {$IFDEF IDEDLL}
        iDelphiVer := GetDelphiVersion;
        {$ENDIF IDEDLL}
      finally
        JclFileVersionInfo.Free;
      end;
    end
    else
      lblVersion.Caption := JVCSRES_Unable_to_determine_version464646;

    LocalIPAddr := GetLocalIP;
    if LocalIPAddr <> '' then
      Caption := Caption + ' - [' + LocalIPAddr + ']'
    else
    if sCurrentMachine <> '' then
      Caption := Caption + ' - [' + sCurrentMachine + ']';

    if not jvcsReadWindowPos(sBaseRegistryKey + crbWindows, 'Login',
      DlgTop, DlgLeft) then
    begin
      DlgTop := (Screen.Height - Height) div 2;
      DlgLeft := (Screen.Width - Width) div 2;
    end;
    Top := DlgTop;
    Left := DlgLeft;

    SrvTimeOutVal :=
      jvcsReadInteger(sBaseRegistryKey + crbOptions, 'SrvTimeOut', 120000);
    {$IFDEF DEBUG}
    if ShowDebugMsg then
      JclDebug.TraceMsg(PChar(cPrgType + 'ServerTimeOut: ' +
        IntToStr(SrvTimeOutVal div 1000) + #0));
    {$ENDIF DEBUG}

    cbSyncServerTime.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'SyncServerTime', False);
    cbAutologin.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'Autologin', False);
    cbUseCurrentIP.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'UseCurrentIP', False);
    cbSavePW.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'SavePassword', False);

    OpenDelay :=
      (jvcsReadInteger(sBaseRegistryKey + crbOptions, 'AutoOpenDel', 3000) div 1000);

    Send_Messages :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'NotifyActive', False) and
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'MessConnect', False);

    Send_SMTP :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'SMTPMessages', False) and
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'MessConnect', False);

    sBugtrackerURL :=
      jvcsReadString(sBaseRegistryKey + crbOptions, 'BugtrackerURL', '');
    sBugtrackerRegEx :=
      jvcsReadString(sBaseRegistryKey + crbOptions, 'BugtrackerRegEx', '');

    sSaveWIPcommand :=
      jvcsReadString(sBaseRegistryKey + crbOptions, 'SaveWIPcommand', '');
    bSaveWIPauto :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'SaveWIPauto', False);


    //THe: improved 'Identies' functionality
    PrepareIdentityBox;
    spBtnAddID.Enabled := False;

    PageControl1.ActivePage := SheetAppServer;
    ServerTime := 0;
    {$IFDEF IDEDLL}
    sProjectName := IDEInterface.GetProjectName;
    {$ENDIF IDEDLL}
    FCreating := False;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSLoad.FormActivate(Sender: TObject);
{$IFDEF IDEDLL}
var
  Ext: string;
{$ENDIF IDEDLL}
begin
  Application.ProcessMessages;
  {$IFDEF IDEDLL}
  sProjectName := IDEInterface.GetProjectName;
  Ext := ExtractFileExt(sProjectName);
  // Projektdatei geöffnet?
  if bIsCppBuilder then
    bProjectOpen := (sProjectName <> '') and
      ((AnsiLowerCase(Ext) = '.cpp') or
      (AnsiLowerCase(Ext) = ('.' + sIDEProject)) or
      (AnsiLowerCase(Ext) = ('.' + sIDEPackage)))
  else
    bProjectOpen := (sProjectName <> '') and
      ((AnsiLowerCase(Ext) = ('.' + sIDEProject)) or
      (AnsiLowerCase(Ext) = ('.bdsproj')) or
      (AnsiLowerCase(Ext) = ('.cbproj')) or
      (AnsiLowerCase(Ext) = ('.dproj')) or
      (AnsiLowerCase(Ext) = ('.' + sIDEPackage)));

  if not bProjectOpen then
  begin
    UseRegistry := True;
    DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
    DSAIdentsMessageDlg(JVCSRES_IDE_returns_no_active_IDE_project46 + #10#13 +
      JVCSRES_JEDI_VCS39s_functionality_will_be_only_partly_available46
      , mtWarning
      , [mbOK]
      , 0
      , sBaseRegistryKey + crbMRU + 'Dlgs'
      , 'NoProjOpen'
      , idOk
      );
  end;
  {$ENDIF IDEDLL}
  pwUserPasswordEdit.SetFocus;
  if cbAutologin.Checked then
  begin
    lblSrvMsg.Caption := JVCSRES_Hit_60DEL62_to_stop_Auto_login;
    LoginTimer.Enabled := True;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSLoad.LoginTimerTimer(Sender: TObject);
begin
  LoginTimer.Enabled := False;
  if btnOpen.Enabled then
    btnOpenClick(Self)
  else
    ConnectOK;
end;

//------------------------------------------------------------------------------

procedure TVCSLoad.btnOpenClick(Sender: TObject);
{const
    AuthMethod: array [Boolean] of TSocksAuthentication =
        (socksNoAuthentication, socksAuthenticateUsercode);}
var
  EncryptPassword: ShortString;
  ServerType, LocalServerPath: string;
  ServerGMTTime: Double;
  ExpectedServer: tSrvIdentifier;
  ExpectedServerVersion: Integer;

//  ServerVersion,
  ExecResult: Integer;

  SyncLocal2Server: Boolean;
begin
  spBtnAddIDClick(Self);
  try
    // Win2K warning
    if (ServerEdit.Text = '127.0.0.1') or
      (LowerCase(ServerEdit.Text) = 'localhost') then
    begin
      UseRegistry := True;
      DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
      if DSAIdentsMessageDlg(Format(JVCSRES_Do_not_use_34localhost34_or_3412746046046134_if_your_PC_is_running_Win200033 + #13#10 +
        JVCSRES_Use_the_machines_real_IP_number_4037s41_to_connect_a_local_server46, [LocalIPAddr])
        , mtWarning
        , [mbIgnore, mbCancel]
        , 0
        , sBaseRegistryKey + crbMRU + 'Dlgs'
        , 'W2KWarning'
        , idIgnore
        ) <> idIgnore then
        Exit;
    end; // if (ServerEdit.Text = '127.0.0.1') or

    // AppSvrClient Settings
    lblSrvMsg.Caption := '';
    lblOs.Caption := JVCSRES_Connecting_server44_please_wait464646;
    EnableControls(False);
    ServerGMTTime := 0;
    nServerVersion := 100;
  //thu 28.06.2004   ServerVersion := 100;
    if nServerVersion = 100 then ; //compilerhint
    ServerType := '';

    //  EncryptServerData := EncryptCheckBox.Checked;
    EncryptServerData := False;

    with DataModule1 do
    begin
      try
        AppSrvClient1.Close;
        AppSrvClient1.Port := PortEdit.Text;
        AppSrvClient1.Server := ServerEdit.Text;
        //THe be sure that we don't provide invalid names here (i.e the *name* of
        //    the edit fields due to copy or other edit actions on the form
        //AppSrvClient1.SocksPort := SocksPortEdit.Text;
        //AppSrvClient1.SocksServer := SocksServerEdit.Text;
        //AppSrvClient1.SocksUsercode := SocksUsercodeEdit.Text;
        //AppSrvClient1.SocksPassword := SocksPasswordEdit.Text;
        //AppSrvClient1.SocksAuthentication := AuthMethod[SocksAuthCheckBox.Checked];
        // Get Server time
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
        begin
          ServerTime := _StrToFloat(AppSrvClient1.Answer.Fields[0]);
          _StrToFloat(AppSrvClient1.Answer.Fields[1]);  //THu Test?
          ServerGMTTime := _StrToFloat(AppSrvClient1.Answer.Fields[2]);
        end;
        if ServerTime = 0 then
        begin
          Windows.Beep(500, 100);
          MessageBox(Application.Handle, PChar(Format(JVCSRES_JEDI_VCS_cannot_retrieve_the_servers_local_time46 + #13#10 +
            JVCSRES_This_value_is_necessary_around_client_password_encryption46 + #13#10 +
            JVCSRES_Server_response58_6037s62,
            [AppSrvClient1.Answer.Fields[0]])), cMsgBoxCaption, MB_OK or MB_ICONSTOP);
          Exit;
        end;

        // Call from JVCSCrypt
        if LoadFVCSCrypt(sDLLDirectory + cCryptDLLName) then
        begin
          EncryptPassword := fvcsCliEncrypt2(pwUserPasswordEdit.Text, ServerTime);
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

        AppSrvClient1.Request.Rewrite;
        AppSrvClient1.FunctionCode := 'LOGIN';
        AppSrvClient1.Request.WriteFields(True,  [UserEdit.Text]);
        AppSrvClient1.Request.WriteFields(False, [EncryptPassword]);
        AppSrvClient1.Request.WriteFields(False, [GetJVCSAppProductVersionInt]);
        AppSrvClient1.Request.WriteFields(False, [GetNowUTC]);
        SetupTimeoutCounter;
        AppSrvClient1.Send;

        while WaitForAppSrvClient do
          Application.ProcessMessages;
        if (AppSrvClientErr <> 0) or
          (AppSrvClient1.AnswerStatus <> '200') then
        begin
          ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
            AppSrvClient1.AnswerStatus);
          Exit;
        end;

        AppSrvClient1.Answer.First;
        // Accepted?
        if DecodeBoolStr(AppSrvClient1.Answer.Fields[0]) then
        begin
          //yes
          Connected := True;
          ServerUserID := _StrToInt(AppSrvClient1.Answer.Fields[1]);
          TransactionNr := _StrToInt(AppSrvClient1.Answer.Fields[2]);
          lblOs.Caption := AppSrvClient1.Answer.Fields[3];
          nServerVersion := _StrToInt(AppSrvClient1.Answer.Fields[4]);
          if (nServerVersion <> 0) then
            ServerType := AppSrvClient1.Answer.Fields[5];
          bGlobalSettings := DecodeBoolStr(AppSrvClient1.Answer.Fields[6]);
          lblSrvMsg.Caption := AppSrvBanner;
          iServTraffic := 0;
          iServerReqCount := 0;
          dServerLogin := Now;
          //store current server/host (used by IDE DLL)
          jvcsWriteString(sBaseRegistryKey, 'CurrentServer',  ServerEdit.Text);
          jvcsWriteString(sBaseRegistryKey, 'CurrentPort', PortEdit.Text);
        end
        else
        begin
          //no
          EnableControls(True);
          FAutoOpen := False;
          TransactionNr := -1;
          ServerUserID := -1;
          lblSrvMsg.Caption := AppSrvClient1.Answer.Fields[3];
          BeepIfSet;
          MessageBox(Handle, PChar(Format(JVCSRES_Access_denied46_4040341 + #13#10 +
            JVCSRES_Unknown_user_name44_wrong_password_or_invalid_client_IP46 + #13#10 +
            JVCSRES_Re45check_your_login_data_and_retry46, [lblSrvMsg.Caption])),
            PChar(JVCSRES_JEDI_VCS_Application_Server), MB_OK or MB_ICONWARNING);
          pwUserPasswordEdit.SetFocus;
          pwUserPasswordEdit.SelectAll;
          cbAutologin.Checked := False;
          Exit;
        end;
      except
        on E: Exception do
        begin
          EnableControls(True);
          LocalServerPath :=
            jvcsReadString(sBaseRegistryKey + crbOptions, 'LocalServer', '');
          if (not ReConnectFlag) and FileExists(LocalServerPath) and
            ((ServerEdit.Text = '127.0.0.1') or
            (ServerEdit.Text = LocalIPAddr) or
            (LowerCase(ServerEdit.Text) = 'localhost')) then
          begin
            FAutoOpen := False;
            BeepIfSet;
            lblSrvMsg.Caption := JVCSRES_No_response_from_server46_Try_to_start_local_server464646;
            Application.ProcessMessages;
            UseRegistry := True;
            DontShowMsgText := JVCSRES_38Start_the_local_server_without_prompting_from_now_on46;
            if DSAIdentsMessageDlg(Format(JVCSRES_Connect_failed46_4037s4146 + #13#10 +
               JVCSRES_The_JEDI_VCS_server_on_host_6037s62_did_not_answer46 + #13#10 +
               JVCSRES_Should_JEDI_VCS_try_to_start_the_local_server6346, [E.Message, ServerEdit.Text])
              , mtWarning
              , [mbYes, mbNo, mbCancel]
              , 0
              , sBaseRegistryKey + crbMRU + 'Dlgs'
              , 'LocalReconnect'
              , idYes
              ) <> idYes then
              Exit;

            ExecResult := ShellExecute( Application.Handle, 'open'
                                      , PChar(LocalServerPath)
                                      , PChar('')
                                      , PChar(ExtractFileDir(LocalServerPath))
                                      , sw_ShowNormal
                                      );
            if ExecResult < 32 then
            begin
              BeepIfSet;
              MessageBox(WindowHandle, PChar(Format(JVCSRES_ShellExecute_Error_6037s62,
                [ExtractFileName(LocalServerPath)]) + #10#13 +
                DecodeShellErr(ExecResult)),
                cMsgBoxCaption, MB_OK or MB_ICONWARNING);
            end // if ExecResult < 32 then begin
            else
              ReConnectTimer.Enabled := True;
            SetForeGroundWindow(Handle);
            Exit;
          end // if (Lowercase(ServerEdit.Text) = '127.0.0.1') or...
          else
          begin
            FAutoOpen := False;
            BeepIfSet;
            MessageBox(Handle, PChar(Format(JVCSRES_Connect_failed46_4037s4146 + #13#10 +
              JVCSRES_The_JEDI_VCS_server_on_host_6037s62_did_not_answer46 + #13#10 +
              JVCSRES_Perhaps_the_server_is_not_running44_you_have_entered_an_invalid_IP_or_port_number + #13#10 +
              JVCSRES_or_your_TCP47IP_network_is_not_properly_set46 + #13#10 +
              JVCSRES_Select_the_connect_dialog39s_help_button_for_more_information46,
              [E.Message, ServerEdit.Text,
              ServerEdit.Text])), cMsgBoxCaption, MB_OK or MB_ICONWARNING);
            lblSrvMsg.Caption := JVCSRES_No_response_from_server46;
            cbAutologin.Checked := False;
            Exit;
          end; // else if (Lowercase(ServerEdit.Text) = '127.0.0.1') or...
        end; // on E:Exception do begin
      end; // try except
    end; // with DataModule1 do begin

    if UserEdit.Text <> sCurrentUser then
      sCurrentUser := UserEdit.Text;

    // check server version
    {$IFDEF DEBUG}
    if ShowDebugMsg then
      JclDebug.TraceMsg(PChar(cPrgType + ': CheckIn - ServerType ' + ServerType + #0)); 
    {$ENDIF DEBUG}

    //THu - Changed to use now SrvId
    ExpectedServer := GetSrvIdFromPort(ServerType);

    //THu if (ExpectedServer = -1) then
    if (ExpectedServer = svIdUnknown) then
    begin
      BeepIfSet;
      MessageBox(Handle, PChar(Format(JVCSRES_JEDI_VCS_detects_an_unknown_server_type58_9137s9346 + #13#10 +
        JVCSRES_See_34Help124About124Version_Information34_for_a_list_of_known_server_types46 + #13#10 +
        JVCSRES_Warning33_Client_may_not_work_correctly33, [ServerType])),
        cMsgBoxCaption, MB_OK or MB_ICONWARNING);
    end
    else
    begin
      ExpectedServerVersion := GetSrvMinimumVersion(ExpectedServer);
      if (nServerVersion < ExpectedServerVersion) then
      begin
        BeepIfSet;
        MessageBox(Handle, PChar(Format(JVCSRES_The_server_you_have_connected_reports_9137s93_version_37d46372462d46 + #13#10 +
          JVCSRES_This_client_expects_at_least_a_server_from_version_37d46372462d46 + #13#10 +
          JVCSRES_Warning33_Client_will_not_work_correctly33, [ServerType, nServerVersion div 100,
          nServerVersion mod 100, ExpectedServerVersion div 100, ExpectedServerVersion mod 100])),
          cMsgBoxCaption, MB_OK or MB_ICONWARNING);
      end; // if InvalidServer then begin
    end;

    sArchiveSource := Format('%s Server V %d.%2.2d on %s [%s]',
      [ServerType, nServerVersion div 100, nServerVersion mod 100,
      ServerEdit.Text, PortEdit.Text]);

    jvcsWriteString(sBaseRegistryKey, 'LastConnectedTo',
      Format('%s Server V %d.%2.2d',
      [ServerType, nServerVersion div 100, nServerVersion mod 100]));

    jvcsWriteString(sBaseRegistryKey, 'LastConnectedAt',
      Format('%s:%s', [ServerEdit.Text, PortEdit.Text]));

    jvcsWriteFloat(sBaseRegistryKey, 'LastConnectTime', Now);

    // Global settings?
    if bGlobalSettings then
    begin
      GetGlobalUserSettings(Application, WindowHandle);
      UseRegistry := True;
      DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
      DSAIdentsMessageDlg(Format(JVCSRES_34Global_settings34_flag_set_by_admin_on_37s46 + #13#10 +
        JVCSRES_Some_local_options47features_may_be_overwritten_by_global_settings + #13#10 +
        JVCSRES_and_will_be_locked_as_long_as_you_are_connected_to_this_server46 + #13#10 +
        JVCSRES_Contact_your_archive_administrator_for_details46, [ServerEdit.Text])
        , mtInformation
        , [mbOK]
        , 0
        , sBaseRegistryKey + crbMRU + 'Dlgs'
        , 'GlobalSetting'
        , idOk
        );
    end;

    // translate servers time to local time
    // GMT -> Local
    if ServerGMTTime = 0 then
      cbSyncServerTime.Checked := False
    else
      ServerTime := GMTDT2LocalDT(ServerGMTTime);

    if not SettingIsGlobal(10) then
      SyncLocal2Server := cbSyncServerTime.Checked
    else
      SyncLocal2Server := GlobalSettingValue(10);

    if SyncLocal2Server then
      if not SyncToServerTime then
      begin
        BeepIfSet;
        MessageBox(WindowHandle,
          PChar(JVCSRES_JEDI_VCS_cannot_synchronize_your_local_time_with_the_server39s_time46
          + #13#10 + JVCSRES_Probably_you_don39t_have_the_required_rights_for_this46),
          cMsgBoxCaption, MB_OK or MB_ICONWARNING);
      end; // if not SyncToServerTime then begin
  finally
    if not (Connected) then
      sIdentityCaption := ''
    else
      sIdentityCaption := cbxIdentity.text;

    EnableControls(True);
    btnOpen.Enabled := False;
    btnCancel.Enabled := False;
    Screen.Cursor := crHourGlass;
    cbSyncServerTime.Enabled := False;
    LoginTimer.Interval := 2000;
    // Abfrage nach Zeitverzögerung (Registry-Hack)
    if jvcsReadBool(sBaseRegistryKey, 'DlgNoWait', False) then
      LoginTimer.Interval := 1;

    LoginTimer.Enabled := True;
  end;
end;

//------------------------------------------------------------------------------

function TVCSLoad.SyncToServerTime: Boolean;
var
  SystemTime: TSystemTime;
begin
  Result := False;
  if ServerTime > 0 then
  begin
    // NT ?
    if Win32Platform = VER_PLATFORM_WIN32_NT then
      //hu25.11.2002       if not S e t P rivilege(SE_SYSTEMTIME) then
      if not EnableProcessPrivilege(True, SE_SYSTEMTIME_NAME) then
      begin
        BeepIfSet;
        MessageBox(Handle, PChar(Format(JVCSRES_JEDI_VCS_cannot_get_the_privilege_6037s6246
          + #13#10 + JVCSRES_Access_denied_by_OS46, ['SE_SYSTEMTIME'])), cMsgBoxCaption,
          MB_OK or MB_ICONWARNING);
        Exit;
      end;
    // Set time
    DecodeDate(ServerTime, SystemTime.wYear, SystemTime.wMonth,
      SystemTime.wDay);
    DecodeTime(ServerTime, SystemTime.wHour, SystemTime.wMinute,
      SystemTime.wSecond, SystemTime.wMilliseconds);
    SystemTime.WDayOfWeek := DayOfWeek(ServerTime);
    if SystemTime.WDayOfWeek = 7 then
      SystemTime.WDayOfWeek := 0; // DOW Windows-konform
    Result := SetLocalTime(SystemTime);
  end; // if ServerTime > 0 then begin
end;

//------------------------------------------------------------------------------

procedure TVCSLoad.ConnectOK;
begin
  if sDLLDirectory[Length(sDLLDirectory)] <> '\' then
    sDLLDirectory := sDLLDirectory + '\';
  sCurrentProject := sProjectName;
  if Connected and Send_Messages then
  begin
    {  %d|%d|%d|%s|%s|%s|%s 162
       Nr|PjID|UsrID|UsrName|Time|Res|Msg  }
    SendSecureMail('*', sFVCSMailslot,
      Format(NtfyMsgStr, [1, ServerProjectID, ServerUserID, sCurrentUser,
      LocalDT2GMTStr(Now), LocalIPAddr,
      '(to: All) ' + 'connected to application server [' + ServerEdit.Text + ']']));
    // -- SMTP --
    if Send_SMTP then
      PrepareSMTP(sCurrentUser, LocalIPAddr, '*All*', 'FVCS Notify',
        '*None*', 'connected to application server [' + ServerEdit.Text + ']', 1);
    // -- SMTP --
  end;
  Screen.Cursor := crDefault;
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSLoad.EnableControls(const Enable: Boolean);
begin
  btnOpen.Enabled := Enable;
  btnCancel.Enabled := Enable;
  ServerEdit.Enabled := Enable;
  PortEdit.Enabled := Enable;
  UserEdit.Enabled := Enable;
  pwUserPasswordEdit.Enabled := Enable;
  cbAutologin.Enabled := Enable;
  cbSyncServerTime.Enabled := Enable;
  spBtnPing.Enabled := Enable;
  cbxIdentity.Enabled := Enable;
  spBtnAddID.Enabled := Enable;
  spBtnRmvID.Enabled := Enable;
  cbSavePW.Enabled := Enable;
end;

//------------------------------------------------------------------------------

procedure TVCSLoad.HelpTopic1Click(Sender: TObject);
begin
  PerformHelpCommand(Application, IDH_Open_Create_archives);
end;

//------------------------------------------------------------------------------

procedure TVCSLoad.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  jvcsWriteWindowPos(sBaseRegistryKey + crbWindows, 'Login', Top, Left);

  jvcsWriteBool(sBaseRegistryKey + crbOptions, 'SyncServerTime',
    cbSyncServerTime.Checked);
  jvcsWriteBool(sBaseRegistryKey + crbOptions, 'Autologin',
    cbAutologin.Checked);
  jvcsWriteBool(sBaseRegistryKey + crbOptions, 'UseCurrentIP',
   cbUseCurrentIP.Checked);
  jvcsWriteBool(sBaseRegistryKey + crbOptions, 'SavePassword',
    cbSavePW.Checked);

  if not jvcsUpdateStorageObject then
    MessageBox(
      WindowHandle,
      PChar(JVCSRES_Storage_Object_update_failed33),
      cMsgBoxCaption,
      MB_OK or MB_ICONWARNING);
end;

//------------------------------------------------------------------------------

procedure TVCSLoad.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_DELETE then
  begin
    LoginTimer.Enabled := False;
    cbAutologin.Checked := False;
  end;
  if Key = VK_ESCAPE then
  begin
    btnCancel.Click;
    Key := 0;
  end;
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Open_Create_archives);
  if spBtnPing.Enabled and (Shift * [ssShift, ssAlt, ssCtrl] = [ssCtrl]) and (Chr(Key) in ['P', 'p']) then
    if (not CtrlSCDisabled(WindowHandle)) then
      spBtnPingClick(Self);
  if spBtnAddID.Enabled and (Shift * [ssShift, ssAlt, ssCtrl] = [ssCtrl]) and (Chr(Key) in ['A', 'a']) then
    if (not CtrlSCDisabled(WindowHandle)) then
      spBtnAddIDClick(Self);
  if spBtnRmvID.Enabled and (Shift * [ssShift, ssAlt, ssCtrl] = [ssCtrl]) and (Chr(Key) in ['R', 'r']) then
    if (not CtrlSCDisabled(WindowHandle)) then
      spBtnRmvIDClick(Self);
end;

//------------------------------------------------------------------------------

procedure TVCSLoad.btnCancelClick(Sender: TObject);
begin
  LoginTimer.Enabled := False;
  bGoWithout := True;
  sIdentityCaption := '';
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSLoad.HelpClick(Sender: TObject);
var
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSLoad.spBtnPingClick(Sender: TObject);
begin
  // CSchiffler - Mantis 4124 fix
  try
    if not Assigned(Ping1) then
    begin
      // create ping object, will get freed by Form automatically.
      Ping1:= TPing.Create(self);
      with  Ping1 do
      begin
        Size := 56;
        Timeout := 4000;
        TTL := 64;
        Flags := 0;
        OnEchoReply := Ping1EchoReply;
      end;
    end;
  except
    on E: Exception do
    begin
      // will fail on Linux/wine because it can not get a handle when running as
      // non root user, so we want to display the error and bail out from here.
      MessageBox(Application.Handle, PChar(Format(JVCSRES_Execute_Ping_raised_exception58
        + #13#10 + '%s.', [E.Message])),
        cMsgBoxCaption, MB_OK or MB_ICONSTOP);
      exit;
    end;
  end;
  // CSchiffler - end of Mantis 4124 fix
  if ServerEdit.Text = '' then
    Exit;
  EnableControls(False);
  Ping1.Address := ServerEdit.Text;
  Screen.Cursor := crHourGlass;
  try
    Ping1.Ping;
  except
    on E: Exception do
    begin
      BeepIfSet;
      MessageBox(Application.Handle, PChar(Format(JVCSRES_Execute_Ping_raised_exception58
        + #13#10 + '%s.', [E.Message])),
        cMsgBoxCaption, MB_OK or MB_ICONSTOP);
      Screen.Cursor := crDefault;
      EnableControls(True);
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSLoad.Ping1EchoReply(Sender, Icmp: TObject; Error: Integer);
var
  PingResult, StatusMsg, RTTStr: string;
  //    PingTime: LongInt;
  mbIcon: Integer;
begin
  Screen.Cursor := crDefault;
  EnableControls(True);
  mbIcon := MB_ICONSTOP;
  PingResult := Format(JVCSRES_Execute_Ping_for_6037s62_with_32_Bytes_of_data46,
    [Ping1.Address]) + #10#13;
  case Ping1.Reply.Status of
    IP_SUCCESS:
      begin
        mbIcon := MB_ICONINFORMATION;
        if Ping1.Reply.RTT < 1 then
          RTTStr := '< 1'
        else
          RTTStr := IntToStr(Ping1.Reply.RTT);
        PingResult := PingResult + JVCSRES_Success46_Ping_reply_status58_No_error46 + #10#13 +
          Format(JVCSRES_Received_37d_Bytes44_Time_61_37s_msec44_TTL_61_12846,
          [Ping1.Reply.Datasize, RTTStr]);

        StatusMsg := Format(JVCSRES_Ping_6037s62_45_Success46, [Ping1.Address]);
      end;
    else
      begin
        PingResult := PingResult + Format(JVCSRES_Failed46_Ping_reply_status58_37s46, [Ping1.ErrorString]);
        StatusMsg := Format(JVCSRES_Ping_6037s62_45_Failed46_37s,
          [Ping1.Address, Ping1.ErrorString]);
      end;
  end; // case Ping1.Reply.Status of
  if mbIcon = MB_ICONSTOP then
    BeepIfSet;
  MessageBox(Application.Handle, PChar(PingResult), cMsgBoxCaption, MB_OK or mbIcon);

  lblOs.Caption := lblSrvMsg.Caption;
  lblSrvMsg.Caption := StatusMsg;
end;

//------------------------------------------------------------------------------

function TVCSLoad.GetLocalIP: string;
type
  TaPInAddr = array [0..10] of PInAddr;
  PaPInAddr = ^TaPInAddr;
var
  phe: PHostEnt;
  pptr: PaPInAddr;
  Buffer: array [0..63] of AnsiChar;
  I: Integer;
  GInitData: TWSAData;
begin
  try
    WSAStartup($101, GInitData);
    try
      Result := '';
      GetHostName(Buffer, SizeOf(Buffer));
      phe := GetHostByName(Buffer);
      if phe = nil then
        Exit;
      pptr := PaPInAddr(phe^.h_addr_list);
      I := 0;
      while pptr^[I] <> nil do
      begin
        Result := inet_ntoa(pptr^[I]^);
        Inc(I);
      end;
    finally
      WSACleanup;
    end;
  except
    Result := '';
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSLoad.UserPasswordEditChange(Sender: TObject);
begin
  if GetKeyState(VK_CAPITAL) then
    lblSrvMsg.Caption := JVCSRES_Remember_that_caps_lock_may_interfere_with_passwords46
  else
    lblSrvMsg.Caption := '';
  spBtnAddID.Enabled := True;
end;

//------------------------------------------------------------------------------

procedure TVCSLoad.ReConnectTimerTimer(Sender: TObject);
begin
  lblSrvMsg.Caption := JVCSRES_Try_to_connect_local_server464646;
  Application.ProcessMessages;
  ReConnectTimer.Enabled := False;
  ReConnectFlag := True;
  btnOpen.Click;
end;

//------------------------------------------------------------------------------

procedure TVCSLoad.cbSyncServerTimeClick(Sender: TObject);
begin
  if (not FCreating) and SettingIsGlobal(10) then
    ShowGlobalSettingsWarning(WindowHandle, GlobalSettingValue(10));
end;

//------------------------------------------------------------------------------

procedure TVCSLoad.cbUseCurrentIPClick(Sender: TObject);
begin
  UseCurrentIP;
end;

//------------------------------------------------------------------------------

procedure TVCSLoad.UseCurrentIP;
begin
  if cbUseCurrentIP.Checked then
  begin
    ServerEdit.Text := LocalIPAddr;
    ServerEdit.Enabled := False;
  end
  else
    ServerEdit.Enabled := True;
end;

//=== Identities function - Add button =========================================

procedure TVCSLoad.spBtnAddIDClick(Sender: TObject);
begin
  UpdateIdentity;
  spBtnAddID.Enabled := False;
end;

//=== Remove button ============================================================

procedure TVCSLoad.spBtnRmvIDClick(Sender: TObject);
var
  IdentityName: string;
  I, J: Integer;
begin
  IdentityName := cbxIdentity.Text;
  //need to get the related Items.Index by hand as we allow lower/upper case...
  I := -1;
  for J := 0 to cbxIdentity.Items.Count - 1 do begin
    if UpperCase(IdentityName) = UpperCase(cbxIdentity.Items[J]) then
    begin
      I := J;
      Break;
    end;
  end;
  if I > -1 then begin
    //found, get user permission
    if MessageBox(
         WindowHandle,
         PChar(Format(JVCSRES_Are_you_sure_you_want_to_remove_6037s62_37s_from_ + #13#10 +
           '<%s>?', [IdentityName, '(ID=' + IntToStr(I) + ')',
           JVCSRES_Server_Identies])),
         cMsgBoxCaption,
         MB_YESNOCANCEL or MB_DEFBUTTON2 or MB_ICONQUESTION) <> id_Yes then
      Exit;
    //OK, erase selected and put all entries behind one position downwards
    jvcsDeleteKey(sBaseRegistryKey + crbIdentity + '\' + IdentityName);
    while jvcsValueExists(sBaseRegistryKey + crbIdentity,
      'ID' + IntToStr(I + 1)) do
    begin
      jvcsWriteString(sBaseRegistryKey + crbIdentity, 'ID' + IntToStr(I),
        jvcsReadString(sBaseRegistryKey + crbIdentity, 'ID' + IntToStr(I + 1), ''));
      Inc(I);
    end;
    jvcsDeleteValue(sBaseRegistryKey + crbIdentity, 'ID' + IntToStr(I));
    //reset default
    jvcsWriteInteger(sBaseRegistryKey + crbIdentity, 'LastUsedID', 0);
    //last step: remove the ID from the combo and clear edit fields
    cbxIdentity.Items.Delete(cbxIdentity.Items.IndexOf(cbxIdentity.Text));
    ServerEdit.Text := '';
    PortEdit.Text := '';
    UserEdit.Text := '';
    //??? pwUserPasswordEdit.Text := ''; seems not to work
    pwUserPasswordEdit.Clear;
    cbxIdentity.ItemIndex := -1;
    IdCBIndex := -1;
  end;
end;

//=== one of the edit fields has changed - enable store button =================

procedure TVCSLoad.IDChanged(Sender: TObject);
begin
  spBtnAddID.Enabled := True;
end;

//=== catch "[", "]" (IniFile Headers) and "\" (Registry key switch char) ======

procedure TVCSLoad.cbxIdentityKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = '[') or (Key = ']') or (Key = '\') then
  begin
    Key := #0;
    BeepIfSet;
  end;
end;

//==============================================================================
// Dropdown combo - new ID selected
// we need a workaround here to decide whether the change was caused by
// entering chars or selecting a new item from the list

procedure TVCSLoad.cbxIdentityChange(Sender: TObject);
begin
  if (IdCBIndex <> cbxIdentity.ItemIndex) and
    (cbxIdentity.ItemIndex > -1) then
    ReadIdentity(cbxIdentity.Items[cbxIdentity.ItemIndex])
  else
    spBtnAddID.Enabled := True;
end;

//=== Window opened - read all ID's from the Ini file ==========================

procedure TVCSLoad.PrepareIdentityBox;
var
  S: string;
  I: Integer;
begin
  S := jvcsReadString(sBaseRegistryKey + crbIdentity, 'ID0', '');
  I := 1;
  if S <> '' then
  begin
    while S <> '' do
    begin
      cbxIdentity.Items.Add(S);
      S := jvcsReadString(sBaseRegistryKey + crbIdentity, 'ID' + IntToStr(I), '');
      Inc(I);
    end;
    cbxIdentity.ItemIndex :=
      jvcsReadInteger(sBaseRegistryKey + crbIdentity, 'LastUsedID', 0);
    ReadIdentity(cbxIdentity.Text);
  end else
  begin
    //nothing found, must be the first start
    cbxIdentity.Text := 'DEFAULT';
    ServerEdit.Text := GetLocalIP;
    PortEdit.Text := '2106';
    UserEdit.Text := 'sysdba';
    pwUserPasswordEdit.Clear;
  end;
  //we need this value later to decide if the index has changed
  IdCBIndex := cbxIdentity.ItemIndex;
end;

//=== Read data (host/port/ etc) for the selected ID ===========================

procedure TVCSLoad.ReadIdentity(IdentityName: string);
var
  Password: string;
begin
  if IdentityName <> '' then
  begin
    ServerEdit.Text :=
      jvcsReadString(sBaseRegistryKey + crbIdentity + '\' + IdentityName, 'HostName', '');
    spBtnAddID.Enabled := (ServerEdit.Text <> '');

    PortEdit.Text :=
      jvcsReadString(sBaseRegistryKey + crbIdentity + '\' + IdentityName, 'Port', '');
    UserEdit.Text :=
      jvcsReadString(sBaseRegistryKey + crbIdentity + '\' + IdentityName, 'User', '');
    Password :=
      jvcsReadString(sBaseRegistryKey + crbIdentity + '\' + IdentityName, 'Password', '');
    if Password <> '' then
      pwUserPasswordEdit.Text := Base64Decode(Password)
    else
      pwUserPasswordEdit.Clear;
  end
  else
  begin
    //Huh? IdentityName is blank?
    ServerEdit.Text := '';
    PortEdit.Text := '';
    UserEdit.Text := '';
    pwUserPasswordEdit.Clear;
  end;
  //check for local settings CB
  UseCurrentIP;
  IdCBIndex := cbxIdentity.ItemIndex;
end;

//=== Write changes to Ini file ================================================

procedure TVCSLoad.UpdateIdentity;
var
  NewIdentity: string;
  I, J: Integer;
begin
  if cbxIdentity.Text = '' then
  begin
    //user selected Add without specifying a name, get one first
    NewIdentity := InputBox(JVCSRES_New_Server_Identity, JVCSRES_Enter_Identity_Name, '');
    if Length(NewIdentity) = 0 then
      NewIdentity :='UNTITLED';
  end else
    NewIdentity := cbxIdentity.Text;

  // does this new ID already exist?
  //get the related Items.Index by hand as we allow lower/upper case...
  I := -1;
  for J := 0 to cbxIdentity.Items.Count - 1 do begin
    if UpperCase(NewIdentity) = UpperCase(cbxIdentity.Items[J]) then
    begin
      //yes, exists
      I := J;
      Break;
    end;
  end;
  if I = -1 then
  begin
    //no, create a new
    cbxIdentity.Items.Add(NewIdentity);
    I := cbxIdentity.Items.Count - 1;
  end;
  cbxIdentity.ItemIndex := I;
  IdCBIndex := I;

  //check for all required information
  if (ServerEdit.Text <> '') and (PortEdit.Text <> '') and (UserEdit.Text <> '') then
  begin
    jvcsWriteString(sBaseRegistryKey + crbIdentity, 'ID' + IntToStr(I), NewIdentity);
    jvcsWriteString(sBaseRegistryKey + crbIdentity + '\' + NewIdentity, 'HostName', ServerEdit.Text);
    jvcsWriteString(sBaseRegistryKey + crbIdentity + '\' + NewIdentity, 'Port', PortEdit.Text);
    jvcsWriteString(sBaseRegistryKey + crbIdentity + '\' + NewIdentity, 'User', UserEdit.Text);
    //save the PW?
    if cbSavePW.Checked then
      jvcsWriteString(sBaseRegistryKey + crbIdentity + '\' + NewIdentity, 'Password', Base64Encode(pwUserPasswordEdit.Text))
    else
      jvcsWriteString(sBaseRegistryKey + crbIdentity + '\' + NewIdentity, 'Password', '');
    jvcsWriteInteger(sBaseRegistryKey + crbIdentity, 'LastUsedID', I);
  end else
    //need more...
    MessageBox(WindowHandle, PChar(Format(JVCSRES_6037s6246_This_value_cannot_be_blank46,
      [JVCSRES_Host47Port47User])), cMsgBoxCaption,
      MB_OK or MB_ICONWARNING);
end;

//=== Weak password encryption - warn the user =================================

procedure TVCSLoad.cbSavePWClick(Sender: TObject);
begin
  if not FCreating then
  begin
    if cbSavePW.Checked then
    begin
      BeepIfSet;
      if MessageBox(
           WindowHandle,
           PChar(JVCSRES_Warning33_Storing_your_passwords_is_not_recommended33 + #13#10 +
             JVCSRES_Other_users_with_access_to_your_computer_may_be_able_to + #13#10 +
             JVCSRES_decode_or_use_them46_Continue_anyway63),
           cMsgBoxCaption,
           MB_YESNOCANCEL or MB_DEFBUTTON2 or MB_ICONWARNING) <> id_Yes then
        cbSavePW.Checked := False;
    end;
  end;
end;

end.
