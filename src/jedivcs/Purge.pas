(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: Purge.pas

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
2003/02/24  FBouwmans - Replaced TSpinEdit by TJvSpinEdit
2003/02/25  FBouwmans - Changed JvSpinEDit to standard style (not diagonal)
2003/03/05  THensle   - changes for "ConfigStorage" unit
2003/12/28  USchuster - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use constant)
2004/02/24  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/03/27  USchuster - bugfix: TJvSpinEdit.Value -> TJvSpinEdit.AsInteger
                        (- caused error in "...FmtLoadStr(349..." [Format function] because
                           TJvSpinEdit.Value is Extended which is not compatible with "%d"
                         - was introduced with the change from TSpinEdit to
                           TJvSpinEdit on 2003/02/24)
                      - minor style cleaning (casing and comments)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/17  USchuster - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/11/02  USchuster - moved resourcestrings to JVCSGUIClientResources.pas                      
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit Purge;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, JvSpin, ExtCtrls, Buttons, Mask, JvMaskEdit, JvEdit, JvExMask,
  JVCSForms;

type
  TVCSPurge = class(TJVCSForm)
    btnPurge: TButton;
    btnCancel: TButton;
    Image1: TImage;
    Label1: TLabel;
    lblPurgeProj: TLabel;
    LabelRevisions: TLabel;
    SpinEditRevisions: TJvSpinEdit;
    Help: TSpeedButton;
    procedure btnPurgeClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure HelpClick(Sender: TObject);
  private
    { Private declarations }
    FCreating: Boolean;
  public
    { Public declarations }
    SelectedProj: string;
    Purged: Boolean;
    SelectedProjID: Integer;
  end;

var
  VCSPurge: TVCSPurge;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSBase, VCSProcBase, DBModule, Std_ListView, TZHandling, ConfigStorage,
  JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSPurge.FormCreate(Sender: TObject);
begin
  try
    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);
    FCreating := True;
    SelectedProj := '';
    Purged := False;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSPurge.FormActivate(Sender: TObject);
begin
  Application.ProcessMessages;
  if not FCreating then
    Exit;
  lblPurgeProj.Caption := Format(JVCSRES_Purge_project58_6037s62, [SelectedProj]);
  FCreating := False;
end;

//------------------------------------------------------------------------------

procedure TVCSPurge.btnPurgeClick(Sender: TObject);
var
  Affected, Deleted: Integer;
  ResultString: string;
  CanPurge: Boolean;
begin
  if MessageBox(WindowHandle, PChar(Format(JVCSRES_Really_purge_project_6037s62_and_keep_37d_revisions_at_maximum63,
    [SelectedProj, SpinEditRevisions.AsInteger])), cMsgBoxCaption, MB_YESNOCANCEL or
    MB_ICONQUESTION or MB_DEFBUTTON2) <> ID_YES then
    Exit;

  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_LOCKED_MODULES';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [SelectedProjID]);
    AppSrvClient1.Request.WriteFields(False, [0]); // all users
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

    ResultString := '';
    AppSrvClient1.Answer.First;
    CanPurge := AppSrvClient1.Answer.Eof;
    while not AppSrvClient1.Answer.Eof do 
    begin
      ResultString := ResultString + AppSrvClient1.Answer.Fields[1] + ';' +
        AppSrvClient1.Answer.Fields[3] + ';' +
        AppSrvClient1.Answer.Fields[4] + ';' +
        DateTimeToStr(GMTStr2LocalDateTime(AppSrvClient1.Answer.Fields[5])) +
        ';' +
        AppSrvClient1.Answer.Fields[6] + ';|';
      AppSrvClient1.Answer.Next;
    end; // while not AppSrvClient1.Answer.EoF do begin
  end; // with DataModule1 do begin
  if not CanPurge then 
  begin
    MessageBox(WindowHandle, PChar(Format(JVCSRES_Access_denied_4037s4146 + #13#10 +
      JVCSRES_The_project_still_contains_checked_out_modules46 + #13#10 +
      JVCSRES_Check_In_all_related_modules_and_retry46, [JVCSRES_Purge_project])),
      cMsgBoxCaption, MB_OK or MB_ICONWARNING);
    btnPurge.Enabled := False;

    VCSStdListView := TVCSStdListView.Create(Application);
    try
      VCSStdListView.LVRepID := 16;
      VCSStdListView.Caption := JVCSRES_Checked_Out;
      VCSStdListView.Left := Left + 60;
      VCSStdListView.Top := Top + 60;
      VCSStdListView.LVType := 0;
      VCSStdListView.HelpContextID := IDH_Purge_project_;
      VCSStdListView.AddListColumn(JVCSRES_Module, False);
      VCSStdListView.AddListColumn(JVCSRES_Version, True);
      VCSStdListView.AddListColumn(JVCSRES_Revision, True);
      VCSStdListView.AddListColumn(JVCSRES_Timestamp, False);
      VCSStdListView.AddListColumn(JVCSRES_Owner, False);
      VCSStdListView.SetUpItems(ResultString);
      VCSStdListView.ShowModal;
    finally
      VCSStdListView.Free;
    end;
    Exit;
  end; // if not CanMerge then begin

  btnPurge.Enabled := False;
  btnCancel.Enabled := False;

  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'PURGE_PROJECT';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [SelectedProjID]);
    AppSrvClient1.Request.WriteFields(False, [SpinEditRevisions.AsInteger]);
    AppSrvClient1.Request.WriteFields(False, [False]); // just ask
    SetupTimeoutCounter;
    AppSrvClient1.Send;

    while WaitForAppSrvClient do 
      Application.ProcessMessages;
    if (AppSrvClientErr = -99) then 
    begin
      ShowServerTimeOut(WindowHandle);
      btnPurge.Enabled := True;
      btnCancel.Enabled := True;      
      Exit;
    end;
    if (AppSrvClientErr <> 0) or (AppSrvClient1.AnswerStatus <> '200') then 
    begin
      ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
        AppSrvClient1.AnswerStatus);
      btnPurge.Enabled := True;
      btnCancel.Enabled := True;
      Exit;
    end;

    AppSrvClient1.Answer.First;
    Affected := _StrToInt(AppSrvClient1.Answer.Fields[0]);
  end; // with DataModule1 do begin

  if Affected > 0 then 
  begin
    if MessageBox(WindowHandle, PChar(Format(JVCSRES_This_will_affect_37d_modules46,
      [Affected]) + #13#10 + JVCSRES_Remember_that_Purge_may_take_several_minutes_on_large_projects46 +
      #10#13 + JVCSRES_Continue63), cMsgBoxCaption, MB_YESNOCANCEL or MB_ICONQUESTION or
      MB_DEFBUTTON2) <> ID_YES then
    begin
      btnPurge.Enabled := True;
      btnCancel.Enabled := True;
      Exit;
    end;
  end 
  else 
  begin
    MessageBox(WindowHandle, PChar(Format(JVCSRES_This_will_affect_37d_modules46,
      [Affected])), cMsgBoxCaption,
      MB_OK or MB_ICONINFORMATION);
    btnPurge.Enabled := True;
    btnCancel.Enabled := True;
    Exit;
  end;

  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'PURGE_PROJECT';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [SelectedProjID]);
    AppSrvClient1.Request.WriteFields(False, [SpinEditRevisions.AsInteger]);
    AppSrvClient1.Request.WriteFields(False, [True]); // purge
    SetupTimeoutCounter;
    AppSrvClient1.Send;

    while WaitForAppSrvClient do 
      Application.ProcessMessages;
    if (AppSrvClientErr = -99) then 
    begin
      ShowServerTimeOut(WindowHandle);
      btnPurge.Enabled := True;
      btnCancel.Enabled := True;
      Exit;
    end;
    if (AppSrvClientErr <> 0) or (AppSrvClient1.AnswerStatus <> '200') then 
    begin
      ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
        AppSrvClient1.AnswerStatus);
      btnPurge.Enabled := True;
      btnCancel.Enabled := True;
      Exit;
    end;

    AppSrvClient1.Answer.First;
    Affected := _StrToInt(AppSrvClient1.Answer.Fields[0]);
    Deleted := _StrToInt(AppSrvClient1.Answer.Fields[1]);
  end; // with DataModule1 do begin}

  MessageBox(WindowHandle, PChar(Format(JVCSRES_Purge_removed_37d_revisions_40affected_modules58_37d41_from_project_6037s6246,
    [Deleted, Affected, SelectedProj])),
    cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
  btnCancel.Enabled := True;
  Purged := True;
end;

//------------------------------------------------------------------------------

procedure TVCSPurge.btnCancelClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSPurge.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then 
  begin
    btnCancel.Click;
    Key := 0;
  end;
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Purge_project_);
end;

//------------------------------------------------------------------------------

procedure TVCSPurge.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

end.
