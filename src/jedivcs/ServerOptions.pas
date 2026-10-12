(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: ServerOptions.pas

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
2003/12/28  USchuster - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use constant)
2004/02/24  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/09/17  FHasovic  - Added dxGetText support for localization                      
2004/10/17  USchuster - style cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/10/31  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit ServerOptions;

{$I jedi.inc}
{$I compopt.inc}

{$IFDEF DELPHI6_UP}
  {$WARN UNIT_PLATFORM OFF}
  {$WARN SYMBOL_PLATFORM OFF}
{$ENDIF DELPHI6_UP}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, JvSpin, Buttons, ComCtrls, Mask, JvMaskEdit, JvEdit, JvExMask,
  JVCSForms;

type
  TVCSServerOptions = class(TJVCSForm)
    btnCancel: TButton;
    btnOK: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    speLoginTO: TJvSpinEdit;
    speConnectTO: TJvSpinEdit;
    Label5: TLabel;
    Label6: TLabel;
    TabSheet2: TTabSheet;
    rbCasCheckin: TRadioButton;
    Label3: TLabel;
    rbResCheckin: TRadioButton;
    Label4: TLabel;
    TabSheet3: TTabSheet;
    cbVCSLog: TCheckBox;
    cbServerLog: TCheckBox;
    lblSrvLogSize: TLabel;
    spBtnShowSrvLog: TSpeedButton;
    cbCheckIP: TCheckBox;
    cbLoginExpires: TCheckBox;
    TabSheet4: TTabSheet;
    edBackupPath: TEdit;
    Label8: TLabel;
    Label10: TLabel;
    btnBackup: TButton;
    Label7: TLabel;
    lblLastBackup: TLabel;
    spBtnClearLog: TSpeedButton;
    Label11: TLabel;
    cbLocalLogin: TCheckBox;
    cbAutologon: TCheckBox;
    Help: TSpeedButton;
    cbLogAccessFault: TCheckBox;
    btnStat: TButton;
    Label9: TLabel;
    Label12: TLabel;
    procedure FormActivate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure cbLoginExpiresClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnBackupClick(Sender: TObject);
    procedure spBtnShowSrvLogClick(Sender: TObject);
    procedure spBtnClearLogClick(Sender: TObject);
    procedure edBackupPathChange(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure btnStatClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OnValuesChanged(Sender: TObject);
  private
    { Private declarations }
    SrvUpTime,
    SrvRequests,
    RequestsAvg,
    SrvDrive,
    SrvAvailable,
    SrvTotal,
    CheckInCount,
    CheckOutCount,
    GetModulesCount,
    NewFilesCount,
    UserCount,
    Transmitted,
    Received: string;
    Initialized,
    ValuesChanged: Boolean;
    function SaveChanges: Boolean;
  public
    { Public declarations }
  end;

var
  VCSServerOptions: TVCSServerOptions;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  ShellAPI, RFormat, DBModule, VCSProcBase, VCSBase, Std_ListView,
  TZHandling, ConfigStorage, JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSServerOptions.FormCreate(Sender: TObject);
begin
  try
    Initialized := False;
    ValuesChanged := False;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSServerOptions.FormActivate(Sender: TObject);
var
  HoursUp: Double;
  UpTimeStr, NPart: string;
begin
  if not Initialized then
  begin
    PageControl1.ActivePage := TabSheet1;
    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);
    with DataModule1 do
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_SERVER_OPTIONS';
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
        speConnectTO.Value := _StrToInt(AppSrvClient1.Answer.Fields[0]);
        speLoginTO.Value := Round(_StrToFloat(AppSrvClient1.Answer.Fields[1]) * 1440);
        rbCasCheckin.Checked := DecodeBoolStr(AppSrvClient1.Answer.Fields[2]);
        rbResCheckin.Checked := not rbCasCheckin.Checked;
        cbVCSLog.Checked := DecodeBoolStr(AppSrvClient1.Answer.Fields[3]);
        cbCheckIP.Checked := DecodeBoolStr(AppSrvClient1.Answer.Fields[4]);
        cbLoginExpires.Checked := DecodeBoolStr(AppSrvClient1.Answer.Fields[5]);
        speLoginTO.Enabled := cbLoginExpires.Checked;
        Label2.Enabled := cbLoginExpires.Checked;
        cbServerLog.Checked := DecodeBoolStr(AppSrvClient1.Answer.Fields[6]);
        lblSrvLogSize.Caption :=
          FormatFloat('#,', _StrToInt(AppSrvClient1.Answer.Fields[7])) + 'k';
        edBackupPath.Text := AppSrvClient1.Answer.Fields[8];
        if (AppSrvClient1.Answer.Fields[9] <> '0') then 
          lblLastBackup.Caption :=
            DateTimeToStr(GMTStr2LocalDateTime(AppSrvClient1.Answer.Fields[9]))
        else 
          lblLastBackup.Caption := JVCSRES_unknown;
        cbLocalLogin.Checked := DecodeBoolStr(AppSrvClient1.Answer.Fields[10]);
        if DecodeBoolStr(AppSrvClient1.Answer.Fields[12]) then
          cbAutologon.Checked := DecodeBoolStr(AppSrvClient1.Answer.Fields[13])
        else 
        begin
          cbAutologon.Checked := True;
          cbAutologon.Enabled := False;
        end;
        cbLogAccessFault.Checked := DecodeBoolStr(AppSrvClient1.Answer.Fields[14]);

        if AppSrvClient1.Answer.Fields[15] <> '' then 
        begin
          SrvUpTime := AppSrvClient1.Answer.Fields[15];
          // parse UptimeStr
          HoursUp := 0;
          UpTimeStr := AppSrvClient1.Answer.Fields[15];
          try
            NPart := Copy(UpTimeStr, 1, Pos('d', UpTimeStr) - 2);
            Delete(UpTimeStr, 1, Pos('d', UpTimeStr) + 2);
            HoursUp := HoursUp + (_StrToInt(NPart) * 24);
            NPart := Copy(UpTimeStr, 1, Pos('h', UpTimeStr) - 2);
            Delete(UpTimeStr, 1, Pos('h', UpTimeStr) + 2);
            HoursUp := HoursUp + (_StrToInt(NPart));
            NPart := Copy(UpTimeStr, 1, Pos('m', UpTimeStr) - 2);
            HoursUp := HoursUp + (_StrToFloat(NPart) / 60);
          except
            HoursUp := 0;
          end;
          if HoursUp > 0 then 
          begin
            SrvRequests :=
              FormatFloat('#,', _StrToInt(AppSrvClient1.Answer.Fields[16]));
            RequestsAvg := Format(JVCSRES_37d47h,
              [Round(_StrToInt(AppSrvClient1.Answer.Fields[16]) / HoursUp)]);
          end 
          else 
          begin
            SrvRequests :=
              FormatFloat('#,', _StrToInt(AppSrvClient1.Answer.Fields[16]));
            RequestsAvg := '?';
          end;
        end 
        else 
        begin
          SrvUpTime := '';
        end;
        if AppSrvClient1.Answer.Fields[17] <> '' then
          SrvDrive := AppSrvClient1.Answer.Fields[17];
        if AppSrvClient1.Answer.Fields[18] <> '' then
          SrvAvailable := AppSrvClient1.Answer.Fields[18];
        if AppSrvClient1.Answer.Fields[19] <> '' then
          SrvTotal := AppSrvClient1.Answer.Fields[19];
        if AppSrvClient1.Answer.Fields[20] <> '' then
          CheckInCount := AppSrvClient1.Answer.Fields[20];
        if AppSrvClient1.Answer.Fields[21] <> '' then
          CheckOutCount := AppSrvClient1.Answer.Fields[21];
        if AppSrvClient1.Answer.Fields[22] <> '' then
          NewFilesCount := AppSrvClient1.Answer.Fields[22];
        if AppSrvClient1.Answer.Fields[23] <> '' then
          UserCount := AppSrvClient1.Answer.Fields[23];
        if AppSrvClient1.Answer.Fields[24] <> '' then
          Transmitted := AppSrvClient1.Answer.Fields[24];
        if AppSrvClient1.Answer.Fields[25] <> '' then
          Received := AppSrvClient1.Answer.Fields[25];
        if AppSrvClient1.Answer.Fields[26] <> '' then
          GetModulesCount := AppSrvClient1.Answer.Fields[26];
      end; // if not AppSrvClient1.Answer.EoF then begin
    end; // with DataModule1 do begin
    Initialized := True;
  end; // if not Initialized then begin
end;

//------------------------------------------------------------------------------

function TVCSServerOptions.SaveChanges: Boolean;
begin
  Result := False;
  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'SET_SERVER_OPTIONS';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [speConnectTO.Value]);
    AppSrvClient1.Request.WriteFields(False, [speLoginTO.Value / 1440]);
    AppSrvClient1.Request.WriteFields(False, [rbCasCheckin.Checked]);
    AppSrvClient1.Request.WriteFields(False, [cbVCSLog.Checked]);
    AppSrvClient1.Request.WriteFields(False, [cbCheckIP.Checked]);
    AppSrvClient1.Request.WriteFields(False, [cbLoginExpires.Checked]);
    AppSrvClient1.Request.WriteFields(False, [cbServerLog.Checked]);
    AppSrvClient1.Request.WriteFields(False, [SetBackSlash(edBackupPath.Text)]);
    AppSrvClient1.Request.WriteFields(False, [cbLocalLogin.Checked]);
    AppSrvClient1.Request.WriteFields(False, [cbAutologon.Checked]);
    AppSrvClient1.Request.WriteFields(False, [cbLogAccessFault.Checked]);
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
  Result := True;
end;

//------------------------------------------------------------------------------

procedure TVCSServerOptions.btnOKClick(Sender: TObject);
begin
  if ValuesChanged then 
  begin
    if SaveChanges then 
      Close;
  end 
  else 
    Close;
end;

//------------------------------------------------------------------------------

procedure TVCSServerOptions.btnCancelClick(Sender: TObject);
var 
  DlgResult: Integer;
begin
  if ValuesChanged then 
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

procedure TVCSServerOptions.cbLoginExpiresClick(Sender: TObject);
begin
  speLoginTO.Enabled := cbLoginExpires.Checked;
  Label2.Enabled := cbLoginExpires.Checked;
  if Initialized then 
    ValuesChanged := True;  
end;

//------------------------------------------------------------------------------

procedure TVCSServerOptions.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Application_server_options);
  if Key = VK_ESCAPE then 
  begin
    btnCancel.Click;
    Key := 0;
  end;    
end;

//------------------------------------------------------------------------------

procedure TVCSServerOptions.btnBackupClick(Sender: TObject);
var 
  ResultString: string;
  ArchiveSize: Longint;
begin
  ArchiveSize := 0;
  if edBackupPath.Text = '' then 
  begin
    MessageBox(WindowHandle, PChar(Format(JVCSRES_6037s6246_This_value_cannot_be_blank46,
      [JVCSRES_Backup_path])), cMsgBoxCaption,
      MB_OK or MB_ICONWARNING);
    edBackupPath.SetFocus;
    Exit;
  end;
  if MessageBox(WindowHandle, PChar(JVCSRES_Start_version_archive_live_backup_now63 + #13#10 +
    JVCSRES_Server_may_be_blocked_for_some_time46), cMsgBoxCaption, MB_YESNOCANCEL or
    MB_ICONQUESTION) <> idYes then 
    Exit;
  with DataModule1 do 
  begin
    btnCancel.Enabled := False;
    btnOK.Enabled := False;
    btnBackup.Enabled := False;
    try
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'LIVE_BACKUP';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [SetBackSlash(edBackupPath.Text)]);
      SetupTimeoutCounter;
      AppSrvClient1.Send;

      while WaitForAppSrvClient do 
        Application.ProcessMessages;
    finally
      btnCancel.Enabled := True;
      btnOK.Enabled := True;
      btnBackup.Enabled := True;
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
      if not DecodeBoolStr(AppSrvClient1.Answer.Fields[0]) then 
      begin
        MessageBox(Handle, PChar(AppSrvClient1.Answer.Fields[1]), cMsgBoxCaption,
          MB_OK or MB_ICONWARNING);
        Exit;
      end // if not DecodeBoolStr...
      else 
      begin
        AppSrvClient1.Answer.Next;
        ResultString := '';
        ArchiveSize := 0;
        while not AppSrvClient1.Answer.Eof do 
        begin
          ResultString := ResultString +
            LowerCase(AppSrvClient1.Answer.Fields[0]) + ';' +
            FormatFloat('#,', _StrToInt(AppSrvClient1.Answer.Fields[1])) + ';|';
          ArchiveSize := ArchiveSize + _StrToInt(AppSrvClient1.Answer.Fields[1]);
          AppSrvClient1.Answer.Next;
        end; // while not AppSrvClient1.Answer.EoF do begin
      end; // if not DecodeBoolStr...
    end; // if not AppSrvClient1.Answer.EoF then begin
  end; // with DataModule1 do begin

  lblLastBackup.Caption := DateTimeToStr(Now);
  ArchiveSize := ArchiveSize div 1024;

  VCSStdListView := TVCSStdListView.Create(Application);
  try
    VCSStdListView.LVRepID := 19;
    VCSStdListView.Caption := JVCSRES_Live_backup_result;
    VCSStdListView.Left := Left + 40;
    VCSStdListView.Top := Top + 40;
    VCSStdListView.LVType := 0;
    VCSStdListView.HelpContextID := IDH_Application_server_options;
    VCSStdListView.AddListColumn(JVCSRES_Version_archive_table, False);
    VCSStdListView.AddListColumn(JVCSRES_Size_91Bytes93, True);
    VCSStdListView.SetUpItems(ResultString);
    VCSStdListView.SetUpHint(Format(JVCSRES_SUM58_37s_KB, [FormatFloat('#,', ArchiveSize)]));
    VCSStdListView.ShowModal;
  finally
    VCSStdListView.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSServerOptions.spBtnShowSrvLogClick(Sender: TObject);
var 
  I: Integer;
  TargetFile, TMPDirectory, Mess: string;
  FS: TFileStream;
  FldType: TMWFieldType;
begin
  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_SERVER_LOG';
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
      if not DecodeBoolStr(AppSrvClient1.Answer.Fields[0]) then 
      begin
        MessageBox(Handle, PChar(JVCSRES_Server_error58_File_not_found46), cMsgBoxCaption,
          MB_OK or MB_ICONSTOP);
        Exit;
      end 
      else 
      begin
        // TMP - Verzeichnis ?
        TMPDirectory :=
          jvcsReadString(sBaseRegistryKey + crbOptions, 'TempDirectory', '');
        if TMPDirectory = '' then
        begin
          I := 255;
          SetLength(TMPDirectory, I);
          I := GetTempPath(I, PChar(TMPDirectory));
          if I = 0 then 
          begin
            BeepIfSet;
            MessageBox(WindowHandle, PChar(JVCSRES_JEDI_VCS_cannot_detect_the_name_of_the_local_temporary_directory46 + #13#10+
              JVCSRES_Try_to_define_a_temporary_directory_in_34Properties124Folders34_and_retry46), cMsgBoxCaption,
              MB_OK or MB_ICONWARNING);
            Exit;
          end;
          SetLength(TMPDirectory, StrLen(PChar(TMPDirectory)));
        end; // if TMPDirectory = '' then begin
        if TMPDirectory[Length(TMPDirectory)] <> '\' then
          TMPDirectory := TMPDirectory + '\';
        TargetFile := TMPDirectory + 'server.log';
        if FileExists(TargetFile) then
        begin
          if MessageBox(WindowHandle, PChar(Format(JVCSRES_There_is_already_a_file_6037s62_in_6037s6246 + #13#10 +
            JVCSRES_Delete_the_file_to_show_the_latest_version_of_6037s6263, ['server.log',
            TMPDirectory, 'server.log'])), cMsgBoxCaption,
            MB_YESNOCANCEL or MB_ICONQUESTION) <> idYes then
            Exit
          else 
          begin
            FileSetAttr(TargetFile, FileGetAttr(TargetFile) and not $00000001);
            SysUtils.DeleteFile(TargetFile);
          end;
        end; // if FileExists(TargetFile) then begin
        // get blob
        try
          FS := TFileStream.Create(TargetFile, fmCreate or fmShareExclusive);
          try
            FS.Seek(0, 0);
            AppSrvClient1.Answer.GetStreamField(1, FS, FldType);
          finally
            FS.Free;
          end;
        except
          on E: 
          Exception do 
          begin
            Mess := Format(JVCSRES_TFileStream_Error_4037s4158_37s, [TargetFile, E.Message]);
            MessageBox(WindowHandle, PChar(Mess), cMsgBoxCaption,
              MB_OK or MB_ICONSTOP);
            Exit;
          end;
        end; // try except
        ShellExecute(Application.Handle, 'open', PChar('notepad.exe'),
          PChar(TargetFile), PChar(ExtractFileDir(TargetFile)), sw_ShowNormal);
      end; // else if not DecodeBoolStr(AppSrvClient1.Answer.Fields[0]) then begin
    end; // if not AppSrvClient1.Answer.EoF then begin
  end; // with DataModule1 do begin
end;

//------------------------------------------------------------------------------

procedure TVCSServerOptions.spBtnClearLogClick(Sender: TObject);
begin
  if MessageBox(WindowHandle, PChar(JVCSRES_Are_you_sure_you_want_to_clear_the_server_log_file63 + #13#10 +
    JVCSRES_Remember_that_this_will_clear_the_original_file + #13#10 +
    JVCSRES_on_the_application_servers_machine46 + #13#10 +
    JVCSRES_Warning33_This_process_is_not_reversible46), cMsgBoxCaption,
    MB_YESNOCANCEL or MB_DEFBUTTON2 or MB_ICONWARNING) <> id_Yes then 
    Exit;
  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'CLEAR_SERVER_LOG';
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

    lblSrvLogSize.Caption := JVCSRES_0k;
  end; // with DataModule1 do begin
end;

//------------------------------------------------------------------------------

procedure TVCSServerOptions.edBackupPathChange(Sender: TObject);
begin
  btnBackup.Enabled := edBackupPath.Text <> '';
  if Initialized then 
    ValuesChanged := True;
end;

//------------------------------------------------------------------------------

procedure TVCSServerOptions.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSServerOptions.btnStatClick(Sender: TObject);
var 
  DlgMsg: string;
begin
  if SrvUpTime <> 'N/A' then 
  begin
    DlgMsg := JVCSRES_Bytes_received + ';' + Received + ';|' +
      JVCSRES_Bytes_transmitted + ';' + Transmitted + ';|' +
      JVCSRES_Modules_40get41 + ';' + GetModulesCount + ';|' +
      JVCSRES_Modules_40new41 + ';' + NewFilesCount + ';|' +
      JVCSRES_Modules_40checked_out41 + ';' + CheckOutCount + ';|' +
      JVCSRES_Modules_40checked_in41 + ';' + CheckInCount + ';|' +
      JVCSRES_Requests + '; ' + SrvRequests + ';|' +
      JVCSRES_Requests_40Avg41 + '; ' + RequestsAvg + ';|' +
      JVCSRES_Server_uptime + ';' + SrvUpTime + ';|' +
      JVCSRES_Space_40available41 + ';' + SrvAvailable + ';|' +
      JVCSRES_Space_40total41 + ';' + SrvTotal + ';|' +
      JVCSRES_Users_40Sum41 + ';' + UserCount + ';|';


    VCSStdListView := TVCSStdListView.Create(Application);
    try
      VCSStdListView.LVRepID := 20;
      VCSStdListView.Caption := JVCSRES_Server_Statistics;
      VCSStdListView.Left := Left + 40;
      VCSStdListView.Top := Top + 40;
      VCSStdListView.LVType := 0;
      VCSStdListView.HelpContextID := IDH_Application_server_options;
      VCSStdListView.AddListColumn(JVCSRES_Item + '   ', False);
      VCSStdListView.AddListColumn(JVCSRES_Value + '   ', True);
      VCSStdListView.SetUpItems(DlgMsg);
      VCSStdListView.SetUpHint(Format(JVCSRES_Archive58_37s, [SrvDrive]));
      VCSStdListView.ShowModal;
    finally
      VCSStdListView.Free;
    end;
  end 
  else 
  begin
    DlgMsg := JVCSRES_Information_not_available46 + #10#13 +
      JVCSRES_40Probably_you_don39t_have_the_required_right41;
    MessageBox(WindowHandle, PChar(DlgMsg), PChar(JVCSRES_JEDI_VCS_Application_Server),
      MB_OK or MB_ICONWARNING);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSServerOptions.OnValuesChanged(Sender: TObject);
begin
  if Initialized then 
    ValuesChanged := True;
end;

end.
