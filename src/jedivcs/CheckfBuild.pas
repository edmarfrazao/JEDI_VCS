(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: CheckfBuild.pas

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
2003/08/02  THuber    - mantis #861: replaced TMemo with TJvMemo
                      - FormStorage changed in configStorage
2004/02/24  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/03/21  USchuster - 'JEDI-VCS ' -> 'JEDI VCS '
                      - minor style cleaning (casing and comments)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/09  THuber    - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
                      - use jvcl msgBoxes
2005/06/04  USchuster - set memo charset to DEFAULT_CHARSET(necessary for LANGUAGE version)
2007/06/30  USchuster - changes for large fonts (contraints size depend now on PixelsPerInch; analog to Mantis #3710)
2011/01/15  USchuster - changed font to Tahoma
2012/07/08  AKroeber  - changed AnsiCrLf to sLineBreak (avoid using of JclAnsiString.pas - should work from Delphi 6 to XE2)

-----------------------------------------------------------------------------*)

unit CheckfBuild;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  {$IFDEF DEBUG}
  JclDebug,
  {$ENDIF DEBUG}
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, Buttons, ExtCtrls, JvMemo, JvExStdCtrls, JVCSForms;

type
  TVCSCheckfBuild = class(TJVCSForm)
    Panel1: TPanel;
    btnCancel: TButton;
    meResult: TJvMemo;
    btnCheck: TButton;
    btnRef: TButton;
    Help: TSpeedButton;
    btnReport: TButton;
    spBtnMail: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCancelClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure btnCheckClick(Sender: TObject);
    procedure btnRefClick(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure btnReportClick(Sender: TObject);
    procedure spBtnMailClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FCreating,
    BuildOK: Boolean;
    ActDir: string;
    UserList,
    LockedProjectList,
    AssgndList: TStringList;
    procedure GetAssgndList;
    procedure CheckBuildOK;
    function GetReportString: string;    
  public
    { Public declarations }
  end;

var
  VCSCheckfBuild: TVCSCheckfBuild;

implementation

uses
    VCSBase
  , VCSProcBase
  , CrossRefList
  , DBModule
  , SimpleReport
  , NtfySend
  , ConfigStorage
  , JclStrings
  , JvJVCLUtils
  , JVCSGUIClientResources
{$IFDEF LANGUAGE}
  , JvGnugettext
{$ENDIF LANGUAGE}
  ;

{$R *.dfm}

procedure TVCSCheckfBuild.FormCreate(Sender: TObject);
begin
  FCreating := True;
  GetDir(0, ActDir);
  Screen.Cursor := crHourGlass;
  try
    Constraints.MinHeight := MulDiv(230, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(413, PixelsPerInch, 96);
    AssgndList := TStringList.Create;
    AssgndList.Sorted := True;
    AssgndList.Duplicates := dupIgnore;
    UserList := TStringList.Create;
    UserList.Sorted := True;
    UserList.Duplicates := dupIgnore;
    LockedProjectList := TStringList.Create;
    LockedProjectList.Sorted := True;
    LockedProjectList.Duplicates := dupIgnore;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
    Screen.Cursor := crDefault;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSCheckfBuild.FormActivate(Sender: TObject);
begin
  Application.ProcessMessages;
  if not FCreating then 
    Exit;
  Screen.Cursor := crHourGlass;
  GetAssgndList;
  Screen.Cursor := crDefault;
end;

//------------------------------------------------------------------------------

procedure TVCSCheckfBuild.GetAssgndList;
var 
  I: Integer;
begin
  AssgndList.Clear;
  meResult.Lines.Clear;
  meResult.Lines.Add( Format( JVCSRES_Project_references_for_37s58
                            , [AnsiLowerCase(ExtractFileName(sProjectName))]
                            )
                    );
  //--- Crossref list ----------------------------------------------------------
  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_PROJECT_REFERENCES';
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
    while not AppSrvClient1.Answer.Eof do 
    begin
      AssgndList.Add(AppSrvClient1.Answer.Fields[1] + ' [' +
        AppSrvClient1.Answer.Fields[0] + ']');
      AppSrvClient1.Answer.Next;
    end;
  end; // with DataModule1 do begin}

  if AssgndList.Count > 0 then 
  begin
    for I := 0 to AssgndList.Count - 1 do
      meResult.Lines.Add(' ' + IntToStr(I + 1) + '. ' +
        Copy(AssgndList.Strings[I], 1, Pos('[', AssgndList.Strings[I]) - 2));
  end // if AssgndList.Count > 0 then begin
  else 
    meResult.Lines.Add('No references defined');
end;

//------------------------------------------------------------------------------

procedure TVCSCheckfBuild.btnCheckClick(Sender: TObject);
begin
  CheckBuildOK;
end;

//------------------------------------------------------------------------------

procedure TVCSCheckfBuild.CheckBuildOK;
var 
  I, ErrCount, AllErrCount, UserCO, OtherCO: Integer;
  CurrentProject, CurrentProjectID: string;
begin
  Screen.Cursor := crHourGlass;
  BuildOK := False;
  spBtnMail.Enabled := False;
  UserList.Clear;
  LockedProjectList.Clear;
  AssgndList.Add(AnsiLowerCase(ExtractFileName(sProjectName)) + ' [' +
    IntToStr(ServerProjectID) + ']');
  BuildOK := True;
  UserCO := 0;
  OtherCO := 0;
  AllErrCount := 0;
  for I := 0 to AssgndList.Count - 1 do 
  begin
    CurrentProjectID := AssgndList.Strings[I];
    while CurrentProjectID[1] <> '[' do 
      Delete(CurrentProjectID, 1, 1);
    Delete(CurrentProjectID, 1, 1);
    Delete(CurrentProjectID, Length(CurrentProjectID), 1);
    CurrentProject := Copy(AssgndList.Strings[I], 1,
      Pos('[', AssgndList.Strings[I]) - 2);
    meResult.Lines.Add('');
    meResult.Lines.Add( Format( JVCSRES_Check_for_Build58 + ' %s' 
                              , [CurrentProject]
                              )
                      );
    ErrCount := 0;
    with DataModule1 do 
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_LOCKED_MODULES';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [CurrentProjectID]);
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

      AppSrvClient1.Answer.First;
      while not AppSrvClient1.Answer.Eof do 
      begin
        BuildOK := False;
        Inc(ErrCount);
        Inc(AllErrCount);
        meResult.Lines.Add( Format( JVCSRES_62_Checked_Out58_37s_V37s4637s_by_37s
                                  , [ AppSrvClient1.Answer.Fields[1]
                                    , AppSrvClient1.Answer.Fields[3]
                                    , AppSrvClient1.Answer.Fields[4]
                                    , AppSrvClient1.Answer.Fields[6]
                                    ]
                                  )
                          );
        if AppSrvClient1.Answer.Fields[6] = sCurrentUser then
          Inc(UserCO)
        else
        begin
          Inc(OtherCO);
          UserList.Add(AppSrvClient1.Answer.Fields[6]);
          LockedProjectList.Add(CurrentProject);
        end;
        AppSrvClient1.Answer.Next;
      end; // while not AppSrvClient1.Answer.EoF do begin
    end; // with DataModule1 do begin
    if ErrCount > 0 then
      meResult.Lines.Add( Format( JVCSRES_37s_45_37d_warnings
                                , [CurrentProject,  ErrCount]
                                )
                        )
    else
      meResult.Lines.Add( Format( JVCSRES_37s_45_project_ready
                                , [CurrentProject]
                                )
                        );
  end; // for I := 0 to AssgndList.Count - 1 do begin
  meResult.Lines.Add('');
  meResult.Lines.Add('----------------------------------------------');
  if not BuildOK then 
  begin
    spBtnMail.Enabled := True;
    meResult.Lines.Add( Format( JVCSRES_Project58_37s_is_not_ready_for_Build
                              , [AnsiLowerCase(ExtractFileName(sProjectName))]
                              )
                      );
    meResult.Lines.Add( Format( JVCSRES_currently_in_work58_37d_modules
                              , [AllErrCount]
                              )
                      );
    meResult.Lines.Add( Format( JVCSRES_by_yourself58_37d
                              , [UserCO]
                              )
                      );
    if OtherCO > 0 then
    begin
      meResult.Lines.Add( Format( JVCSRES_by_others__58_37d
                              , [OtherCO]
                              )
                      );
      meResult.Lines.Add(JVCSRES_Other_users_working_on_these_projects58);
      for I := 0 to UserList.Count - 1 do
      begin
        meResult.Lines.Add('- ' + UserList.Strings[I]);
      end; // for I := 0 to UserList.Count - 1 do begin
    end; // if OtherCO > 0 then begin
  end // if not BuildOK then begin
  else
    meResult.Lines.Add( Format( JVCSRES_Project58_37s_is_ready_for_Build
                              , [AnsiLowerCase(ExtractFileName(sProjectName))]
                              )
                      );
  meResult.Lines.Add('----------------------------------------------');
  Screen.Cursor := crDefault;
end;

//------------------------------------------------------------------------------

procedure TVCSCheckfBuild.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  jvcsSaveFormPosSize(Self);
  ChDir(ActDir);
end;

//------------------------------------------------------------------------------

procedure TVCSCheckfBuild.FormDestroy(Sender: TObject);
begin
  AssgndList.Free;
  UserList.Free;
  LockedProjectList.Free;
end;

//------------------------------------------------------------------------------

procedure TVCSCheckfBuild.btnCancelClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSCheckfBuild.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Check_for_Build_OK);
  if Key = VK_ESCAPE then
  begin
    btnCancel.Click;
    Key := 0;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSCheckfBuild.btnRefClick(Sender: TObject);
begin
  VCSSelCrossRef := TVCSSelCrossRef.Create(Application);
  try
    VCSSelCrossRef.Top := Top + 40;
    VCSSelCrossRef.Left := Left + 40;
    VCSSelCrossRef.ShowModal;
  finally
    VCSSelCrossRef.Free;
  end;
  GetAssgndList;
end;

//------------------------------------------------------------------------------

function TVCSCheckfBuild.GetReportString: string;
var
  CurrentText, CurrentModule: string;
  I, MaxModuleLength, MaxProjectLength: Integer;

  function SizeString(const MLength: Integer; const CellString: string;
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
    while Length(Result) < MLength do
      Result := Result + Fillchr;
  end;
begin
  Result := '';
  Screen.Cursor := crHourGlass;
  try
{Project references for fvcsappsrv.dpr:
 1. create_dbisam.dpr
 2. fvcsntappsrv.dpr

Check for Build: create_dbisam.dpr
create_dbisam.dpr - project ready

Check for Build: fvcsappsrv.dpr
> Checked Out: srvserviceunit.pas V0.3 by sysdba
> Checked Out: srvobjreport.pas V0.13 by sysdba
> Checked Out: srvobjmain.pas V0.13 by sysdba
> Checked Out: srvobjbugtrack.pas V0.1 by sysdba
> Checked Out: srvmain.pas V0.11 by sysdba
> Checked Out: srvconst.pas V0.7 by sysdba
> Checked Out: cond_def.inc V0.8 by sysdba
fvcsappsrv.dpr - 7 warnings

Check for Build: fvcsntappsrv.dpr
fvcsntappsrv.dpr - project ready

----------------------------------------------
Project: fvcsappsrv.dpr is not ready for build
currently in work: 7 modules
by yourself: 0
by others  : 7
Other users working on these projects:
- sysdba
----------------------------------------------
}
    Result := Caption + sLineBreak;
    CurrentText := '';
    while Length(CurrentText) < Length(Caption) do
      CurrentText := CurrentText + '=';
    Result := Result + CurrentText + sLineBreak + sLineBreak;

    // get project/module length
    MaxProjectLength := 0;
    MaxModuleLength := 0;
    for I := 0 to meResult.Lines.Count - 1 do
    begin
      CurrentText := meResult.Lines[I];
      if Pos(JVCSRES_62_Checked_Out58, CurrentText) > 0 then  // !!!
      begin
        Delete(CurrentText, 1, 15);
        CurrentModule := Copy(CurrentText, 1, Pos(JVCSRES__by_ , CurrentText) - 1); // !!!
        if Length(CurrentModule) > MaxModuleLength then
          MaxModuleLength := Length(CurrentModule);
      end; // if Pos('> Checked Out:', CurrentText) > 0 then begin
      if Pos(JVCSRES_Check_for_Build58, CurrentText) > 0 then
      begin
        Delete(CurrentText, 1, 16);
        if Length(CurrentText) > MaxProjectLength then
          MaxProjectLength := Length(CurrentText);
      end; // if Pos('Check for Build:', CurrentText) > 0 then begin
    end; // for I := 0 to meResult.Lines.Count - 1 do...

    if MaxProjectLength > MaxModuleLength then
      MaxModuleLength := MaxProjectLength;

    for I := 0 to meResult.Lines.Count - 1 do
    begin
      CurrentText := meResult.Lines[I];
      if (Pos(JVCSRES_Check_for_Build58, CurrentText) > 0) or
        (Pos(JVCSRES_62_Checked_Out58, CurrentText) > 0) then
      begin
        if Pos(JVCSRES_Check_for_Build58, CurrentText) > 0 then 
        begin
          Delete(CurrentText, 1, 17);
          Result := Result + Format ( JVCSRES_37s124User + sLineBreak
                                    , [SizeString(MaxModuleLength + 1, CurrentText, ' ')]
                                    );
          Result := Result + SizeString(MaxModuleLength + 1, '-', '-') +
            '|----' + sLineBreak;
        end; // if Pos('Check for Build:', CurrentText) > 0 then begin
        if Pos(JVCSRES_62_Checked_Out58, CurrentText) > 0 then 
        begin
          Delete(CurrentText, 1, 15);
          CurrentModule := Copy(CurrentText, 1, Pos(JVCSRES__by_, CurrentText) - 1);
          Delete(CurrentText, 1, Length(CurrentModule) + 4);
          Result := Result + Format ( JVCSRES_37s124locked_by_37s + sLineBreak
                                    , [ SizeString(MaxModuleLength + 1, CurrentModule, ' ')
                                      , CurrentText
                                      ]
                                    );
        end; // if Pos('> Checked Out:', CurrentText) > 0 then begin
      end // if (Pos('Check for Build:', CurrentText) > 0) or...
      else
      begin
        Result := Result + CurrentText + sLineBreak;
      end; // else if Pos('> Checked Out:', CurrentText) > 0 then begin
    end; // for I := 0 to meResult.Lines.Count - 1 do...

    Result := Result + sLineBreak + JVCSRES_Source58_ + sArchiveSource + sLineBreak +
      'JEDI VCS ' + sProductVer + cProductInf + DateTimeToStr(Now) + sLineBreak;
  finally
    Screen.Cursor := crDefault;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSCheckfBuild.btnReportClick(Sender: TObject);
var
  ResultString: string;
begin
  ResultString := GetReportString;
  if ResultString = '' then 
    Exit;

  VCSSimpleReport := TVCSSimpleReport.Create(Application);
  try
    VCSSimpleReport.RepID := 1;
    VCSSimpleReport.Left := Left + 60;
    VCSSimpleReport.Top := Top + 60;
    VCSSimpleReport.FullReportString := ResultString;
    VCSSimpleReport.SavePath := ExtractFileDir(sProjectName);
    VCSSimpleReport.LineCount := meResult.Lines.Count + 4;
    VCSSimpleReport.SaveFileName := 'CheckForBuild.txt';
    VCSSimpleReport.ShowModal;
  finally
    VCSSimpleReport.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSCheckfBuild.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSCheckfBuild.spBtnMailClick(Sender: TObject);
var 
  I: Integer;
  SendResult, Value: string;
begin
  NtfySendForm := TNtfySendForm.Create(Application);
  try
    NtfySendForm.MailType := 7;
    Value := '';
    for I := 0 to UserList.Count - 1 do
      Value := Value + UserList.Strings[I] + ';';
    NtfySendForm.SetUpUserList(Value);
    Value :=  JVCSRES_Please_finish_your_work_and_re45check_in_the_modules_locked_by_you46_Related_projects58_;
    for I := 0 to LockedProjectList.Count - 1 do
      Value := Value + AssgndList.Strings[I] + ', ';
    NtfySendForm.SetUpMessage(Value);
    NtfySendForm.ShowModal;
    SendResult := NtfySendForm.ResultStr;
  finally
    NtfySendForm.Free;
  end;
end;

procedure TVCSCheckfBuild.FormShow(Sender: TObject);
begin
  jvcsLoadFormPosSize(Self);
end;

end.
