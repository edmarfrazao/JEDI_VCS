(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: Whoami.pas

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
2003/03/06  THensle   - changes for "ConfigStorage" unit
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/05  USchuster - style cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/10/31  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
2007/06/05  USchuster - as of now the icon will be replaced with the OS icon
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit Whoami;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, JVCSForms;

type
  TVCSWhoami = class(TJVCSForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lblUser: TLabel;
    lblDefaultRight: TLabel;
    lblProjectRight: TLabel;
    lblServer: TLabel;
    lblArchive: TLabel;
    lblStoredIP: TLabel;
    lblCurrentIP: TLabel;
    lblLogin: TLabel;
    lblLoginRemain: TLabel;
    btnClose: TButton;
    Label10: TLabel;
    lblServerLoc: TLabel;
    Label11: TLabel;
    lblProject: TLabel;
    Image1: TImage;
    Label12: TLabel;
    lblServerLogin: TLabel;
    btnStatistic: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnStatisticClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  VCSWhoami: TVCSWhoami;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSBase, DBModule, VCSProcBase, TZHandling, ConfigStorage, JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSWhoami.FormCreate(Sender: TObject);
var
  LoginTimeRemain: Double;
begin
  try
    Image1.Picture.Icon.Handle := LoadIcon(0, IDI_ASTERISK);
    with DataModule1 do
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'WHOAMI';
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
      if (AppSrvClientErr <> 0) or (AppSrvClient1.AnswerStatus <> '200') then
      begin
        ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
          AppSrvClient1.AnswerStatus);
        Exit;
      end;

      AppSrvClient1.Answer.First;
      if not AppSrvClient1.Answer.Eof then
      begin
        lblUser.Caption := AppSrvClient1.Answer.Fields[1] + ', ID: ' +
          AppSrvClient1.Answer.Fields[0];
        lblDefaultRight.Caption := AppSrvClient1.Answer.Fields[2] + ' [' +
          AppSrvClient1.Answer.Fields[3] + ']';
        if sProjectName <> '' then
        begin
          lblProjectRight.Caption := AppSrvClient1.Answer.Fields[11] + ' [' +
            AppSrvClient1.Answer.Fields[12] + ']';
          lblProject.Caption := '(' + ExtractFileName(sProjectName) + ')';
        end
        else
        begin
          lblProjectRight.Caption := JVCSRES_NA;
          lblProject.Caption := JVCSRES_40none41;
        end;
        lblProject.Hint := lblProject.Caption;
        lblServer.Caption := AppSrvClient1.Answer.Fields[9];
        Caption := lblServer.Caption;

        lblServerLoc.Caption :=
          jvcsReadString(sBaseRegistryKey, 'LastConnectedAt', '') + ' ' +
          AppSrvClient1.Answer.Fields[13];

        lblArchive.Caption := AppSrvClient1.Answer.Fields[10];
        lblStoredIP.Caption := AppSrvClient1.Answer.Fields[7];
        lblCurrentIP.Caption := AppSrvClient1.Answer.Fields[8];
        if DecodeBoolStr(AppSrvClient1.Answer.Fields[4]) then
        begin
          LoginTimeRemain := (GMTStr2LocalDateTime(AppSrvClient1.Answer.Fields[5]) +
            _StrToFloat(AppSrvClient1.Answer.Fields[6])) - Now;
          lblLogin.Caption :=
            DateTimeToStr(GMTStr2LocalDateTime(AppSrvClient1.Answer.Fields[5]) +
            LoginTimeRemain);
          if LoginTimeRemain > 0 then
            lblLoginRemain.Caption := Format(JVCSRES_37d_min46, [Round(LoginTimeRemain * 1440)])
          else
            lblLoginRemain.Caption := '?';
        end  // if DecodeBoolStr(AppSrvClient1.Answer.Fields[4]) then begin
        else
        begin
          lblLogin.Caption := JVCSRES_not_active46;
          lblLoginRemain.Caption := JVCSRES_not_active46;
        end;
        lblServerLogin.Caption := DateTimeToStr(LocalDT2GMTDT(dServerLogin));
      end; // if not AppSrvClient1.Answer.EoF then begin
    end; // with DataModule1 do begin
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSWhoami.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Whoami);
  if Key = VK_ESCAPE then
  begin
    btnClose.Click;
    Key := 0;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSWhoami.btnStatisticClick(Sender: TObject);
var
  MDldCaption: string;
begin
  MDldCaption := lblServer.Caption;
  MessageBox(WindowHandle, PChar(Format(JVCSRES_37d_requests_transfered_37s_bytes_of_data_between_server_and_client46 + #13#10 +
    JVCSRES_Log_in_time58_37s + #13#10 +
    JVCSRES_Log_started_at_37s46, [iServerReqCount,
    FormatFloat('#,', iServTraffic),
    GetUpTimeStr,
    LocalDT2GMTStr(dServerLogin)])),
    PChar(MDldCaption), MB_OK or MB_ICONINFORMATION);
end;

end.
