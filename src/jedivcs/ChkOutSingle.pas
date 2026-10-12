(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: ChkOutSingle.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS: Thomas Huber (Thomas_D_Huber@t-online.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
May/03:
- maybe it's necessary to call GET_PROJECT_ID if CheckOutProjectID <> ServerProjectID
  in order to get a new TransactionNr
- #3091: temp. solution for shortCuts: reactivated but change hint
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FreeVCS code to JEDI VCS
2003/02/12  USchuster - changed DSAMsg with JVCSDialogs in uses clause to use JvDSADialogs
2003/02/18  MGosselink- emptied some .text props, changed Led color green to lime
2003/03/03  THensle   - changes for "ConfigStorage" unit
2003/03/09  USchuster - exchanged TjvMruList with TJVCSMruList (mantis #727)
                      - disabled the AutoSave property in rcbxTargetFld
                        and removed the regkeys (they where wrong and
                        loading and saving is no done with MruListTargetFld)
                      - commented rcbxTargetFld.AutoSave.SaveValue
                      - the selected folder will also be inserted into the
                        combobox now
2003/03/15  THuber    - compilerwarnings/most hints removed
2003/04/08  USchuster - changes for IDEInterface
2003/04/11  FBouwmans - Added multiple projectid for local project admin
2003/05/18  USchuster - fixed multiple projectid (mantis #880/1.&2.)
2003/08/02  THuber    - mantis #861: replaced TMemo with TJvMemo
2003/12/27  THuber    - TimeConst now from JVCSClientConsts
2003/12/27  USchuster - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use constant)
                      - AutoComplete in ComboBox now False
2004/02/24  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/11/04  THuber    - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
                      - use jvcl msgBoxes
2005/01/24  CSchuette - changed TTimer interval from 500 to 50 to speed up CheckOn/CheckOut of multiple files
2005/03/27  FBouwmans - Prepare for use of JVCSConnection in HandleBlob
2005/04/11  CSchuette - mantis #2815
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC2 was released ^^^^^^^^^^^^^^^^^^^^^^^^^^^
2005/04/25  CSchuette - added call to "ResolveFileFamilies" to fix mantis #1205
2005/05/22  USchuster - minor style cleaning (casing and comments)
                      - added comment history feature (mantis #2713)
2005/06/22  CSchuette - added additional check if checked out file was *really* loaded from Delphi IDE, mantis #3061
                      - replaced MsgWarn with ErrorMessageBox or WarnMessageBox
2005/07/10  CSchuette - modified changes for #3061 again
2005/07/15  THuber    #3091 reactivated again Shortcuthandling
2007/04/08  USchuster - fixed self handled shortcuts (mantis #4087)
2007/06/29  USchuster - changes for large fonts (contraints and default size depend now on PixelsPerInch; Mantis #3710)
2007/09/12  USchuster - improved empty comment check (Mantis #4227)
2010/01/23  USchuster - little speedup of check out preparation (Mantis #5082)
2011/01/15  USchuster - changed font to Tahoma
2012/07/08  AKroeber  - changed AnsiCrLf to sLineBreak (avoid using of JclAnsiString.pas - should work from Delphi 6 to XE2)

-----------------------------------------------------------------------------*)

unit ChkOutSingle;

{$I jedi.inc}
{$I compopt.inc}

{$IFDEF DELPHI6_UP}
  {$WARN UNIT_PLATFORM OFF}
  {$WARN SYMBOL_PLATFORM OFF}
{$ENDIF DELPHI6_UP}

interface

uses
  {$IFDEF DEBUG}
  JclDebug,
  {$ENDIF DEBUG}
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, ComCtrls, JvLED, JvCombobox, JvComponent,
  JVCSMruList, JvMemo, JvExStdCtrls, JvExControls, JvArrowButton, JVCSChkInOutCommon;

type
  TVCSChkOutSingle = class(TForm)
    Panel1: TPanel;
    meComment: TJvMemo;
    Panel2: TPanel;
    btnCheckOut: TButton;
    btnCancel: TButton;
    Label2: TLabel;
    Delay: TTimer;
    spBtnBrowse: TSpeedButton;
    lblQueue: TLabel;
    pbQueue: TProgressBar;
    cbReload: TCheckBox;
    cbDontOverwriteLocal: TCheckBox;
    Panel3: TPanel;
    spBtnGetLComment: TJvArrowButton;
    spBtnGetToDoComment: TSpeedButton;
    cbAll: TCheckBox;
    Help: TSpeedButton;
    spBtnUndo: TSpeedButton;
    Panel4: TPanel;
    StateLED: TJvLED;
    lblState: TLabel;
    Panel5: TPanel;
    lblModule: TLabel;
    Panel6: TPanel;
    lblVer: TLabel;
    rcbxTargetFld: TJvComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnCheckOutClick(Sender: TObject);
    procedure spBtnBrowseClick(Sender: TObject);
    procedure DelayTimer(Sender: TObject);
    procedure btnGeLlMemoClick(Sender: TObject);
    procedure btnGetFromToDoClick(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure spBtnUndoClick(Sender: TObject);
    procedure cbDontOverwriteLocalClick(Sender: TObject);
  private
    { Private declarations }
    bFCreating,
    bMarkSource,
    bPromptfMemo,
    Send_Messages,
    Send_SMTP,
    ModuleIsCheckOut,
    CancelOperation,
    SkipROCheck,
    Yes2all,
    ExpandKeywords: Boolean;
    CheckOutModuleID,
    CheckOutProjectID,
    CheckOutVersion,
    CheckOutRevision,
    CheckOutRevisionID,
    Yes2allRes,
    ModuleInProgress: Integer;
    ActDir,
    MemoBuffer,
    CheckOutModuleOwner,
    KWExpandFilter: string;
    MruListTargetFld: TJVCSMruList;
    FLastCommentHandler: TLastCommentHandler;
    procedure EnableButtons(const Enable: Boolean);
    function PrepareModuleInfo(ModuleKey: string;
       ProjectID: Integer): Boolean;
    procedure InitCheckOut;
    function CheckOut: Boolean;
    procedure NotifyModuleOwner(const ModOwner, ModuleName: string);
  public
    { Public declarations }
    SelectModuleList: TStringList;
    AsChild,
    HasErrors,
    ArchiveChanged: Boolean;
    procedure RestrictSize(var Msg: TMessage); message WM_GETMINMAXINFO;
  end;

var
  VCSChkOutSingle: TVCSChkOutSingle;

implementation

uses
    VCSBase
  {$IFDEF IDEDLL}
  , JVCSIDEInterface
  , VerSet
  {$ENDIF IDEDLL}
  , VCSProcBase
  , JVCSDialogs
  , JVCSClientConsts
  , mdMailSlot
  , TZHandling
  , Yes2allDlg
  , SelectFolder
  , HandleBlob
  , DBModule
  , SelectList
  , KWExpansion
  , CheckSum
  , SMTPSend
  , NtfySend
  , ConfigStorage
  , JclStrings
  , JvJVCLUtils
  , JVCSGUIClientResources
  , JVCSClientFunctions
{$IFDEF LANGUAGE}
  , JvGnugettext
{$ENDIF LANGUAGE}
  , Menus
  ;

{$R *.dfm}

procedure TVCSChkOutSingle.FormCreate(Sender: TObject);
var
  DlgTop,
  DlgLeft,
  DlgWidth,
  DlgHeight: Integer;
begin
  try
    // Init
    bFCreating := True;
    // Aktuelles Verzeichnis speichern
    GetDir(0, ActDir);
    {$IFNDEF IDEDLL}
    cbReload.Enabled := False;
    {$ENDIF ~IDEDLL}

    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    if not jvcsReadWindowPosAndSize(sBaseRegistryKey + crbWindows, 'CheckOut',
      DlgTop, DlgLeft, DlgWidth, DlgHeight) then
    begin
      DlgTop := (Screen.Height - Height) div 2;
      DlgLeft := (Screen.Width - Width) div 2;
      DlgWidth := MulDiv(340, PixelsPerInch, 96);
      DlgHeight := MulDiv(275, PixelsPerInch, 96);
    end;
    Top := DlgTop;
    Left := DlgLeft;
    Width := DlgWidth;
    Height := DlgHeight;

    //#3091 - preperation for later localization of some shortcuts
    //@@@ToDo later: at the moment hard coded to CTRL-L, CTRL-T, if option
    //               for shortcut exist, change...
    spBtnGetLComment.Hint := Format(JVCSRES_Get_last_comment_4037s41, ['Ctrl+L']);
    spBtnGetToDoComment.Hint := Format(JVCSRES_Get_comment_from_ToDo_list_4037s41, ['Ctrl+T']);

    cbAll.Checked := jvcsReadBool(sBaseRegistryKey + crbWindows,
      'CheckOut_OneComment', True);
    {$IFDEF IDEDLL}
    cbReload.Checked := jvcsReadBool(sBaseRegistryKey + crbWindows,
      'CheckOut_ReloadFiles', True);
    {$ENDIF IDEDLL}
    cbDontOverwriteLocal.Checked := False;
    bPromptfMemo := jvcsReadBool(sBaseRegistryKey + crbOptions,
      'PromptFMemo2', True);

    //??? GlobalSettings
    if not SettingIsGlobal(5) then
      ExpandKeywords := jvcsReadBool(sBaseRegistryKey + crbOptions,
        'KeywordExp_CheckOut', False)
    else
      ExpandKeywords := GlobalSettingValue(5);
    KWExpandFilter := jvcsReadString(sBaseRegistryKey + crbOptions,
      'KWExpFiles', dfKWExp);
    if not SettingIsGlobal(16) then
      Send_Messages := jvcsReadBool(sBaseRegistryKey + crbOptions,
        'NotifyActive', False) and jvcsReadBool(sBaseRegistryKey + crbOptions,
        'MessChkOut', False)
    else
      Send_Messages := GlobalSettingValue(16);
    if not SettingIsGlobal(17) then
      SkipROCheck := jvcsReadBool(sBaseRegistryKey + crbOptions, 'NoROCheck', False)
    else
      SkipROCheck := GlobalSettingValue(17);
    if not SettingIsGlobal(2) then
      bMarkSource := jvcsReadBool(sBaseRegistryKey + crbOptions,
        'MarkSource_O', False) and jvcsReadBool(sBaseRegistryKey + crbOptions,
        'MarkSource', False)
    else
      bMarkSource := GlobalSettingValue(2);

    Send_SMTP := jvcsReadBool(sBaseRegistryKey + crbOptions, 'SMTPMessages',
      False) and jvcsReadBool(sBaseRegistryKey + crbOptions, 'MessChkOut', False);

    {$IFDEF CUSTOMDRIVE}
    sDriveSubst := RegReadString(HKCU, sBaseRegistryKey + crbProjects +
      ExtractFileName(sProjectName), 'LocalDrive', '');
    if (sDriveSubst = '') then
      sDriveSubst := RegReadString(HKCU, sBaseRegistryKey + crbOptions,
        'LocalDrive', '');
    {$ENDIF CUSTOMDRIVE}

    MruListTargetFld := TJVCSMruList.CreateEx(sBaseRegistryKey + crbMRU + '8');
    rcbxTargetFld.Items.Assign(MruListTargetFld);

    SelectModuleList := TStringList.Create;
    ModuleInProgress := 0;
    ArchiveChanged := False;
    AsChild := False;
    CancelOperation := False;
    HasErrors := False;
    Yes2all := False;
    CheckOutProjectID := ServerProjectID;
    FLastCommentHandler := TLastCommentHandler.CreateEx(Self, 'ChkOut', meComment);
    spBtnGetLComment.DropDown := FLastCommentHandler.PopupMenu;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSChkOutSingle.FormActivate(Sender: TObject);
var
  CurrentFile: string;
begin
  Application.ProcessMessages;
  if bFCreating then
  begin
    bFCreating := False;
    Screen.Cursor := crHourGlass;
    try
      if SelectModuleList.Count > 0 then
      begin
        if AsChild then
          Caption := Format ( JVCSRES_Check_Out_45_14737d
                            , [SelectModuleList.Count]
                            )
        else
          Caption := Format ( JVCSRES_VCS_Check_Out_45_14737d
                            , [SelectModuleList.Count]
                            );
        cbAll.Enabled := (SelectModuleList.Count > 1);
        lblQueue.Enabled := (SelectModuleList.Count > 1);
        pbQueue.Max := SelectModuleList.Count;
        pbQueue.Enabled := (SelectModuleList.Count > 1);
        EnableButtons(False);
        PrepareModuleInfo(SelectModuleList.Strings[0],
          Integer(SelectModuleList.Objects[0]));
        EnableButtons(True);
      end // if SelectedModuleList.Count > 0 then begin
      else
      begin
        if AsChild then
          Caption := Format ( JVCSRES_Check_Out_45_14737d
                            , [1]
                            )
        else
          Caption := Format ( JVCSRES_VCS_Check_Out_45_14737d
                            , [1]
                            );
        cbAll.Enabled := False;
        lblQueue.Enabled := False;
        pbQueue.Enabled := False;
        {$IFDEF IDEDLL}
        CurrentFile := AnsiLowerCase(IDEInterface.GetCurrentFile);
        ResolveFileFamilies(CurrentFile);
        {$ENDIF IDEDLL}
        EnableButtons(False);
        PrepareModuleInfo(CurrentFile, ServerProjectID);
        EnableButtons(True);
      end; // else if SelectedModuleList.Count > 0 then begin
    finally
      Screen.Cursor := crDefault;
    end;
  end; // if bFCreating then begin
end;

//------------------------------------------------------------------------------

procedure TVCSChkOutSingle.EnableButtons(const Enable: Boolean);
begin
  btnCheckOut.Enabled := Enable;
  btnCancel.Enabled := Enable;
  spBtnGetLComment.Enabled := Enable;
  spBtnGetToDoComment.Enabled := Enable;
  spBtnUndo.Enabled := Enable;
end;

//------------------------------------------------------------------------------

function TVCSChkOutSingle.PrepareModuleInfo(ModuleKey: string;
  ProjectID: Integer): Boolean;
var
  ChkOutComment: string;
  TimeStamp: TDateTime;
  GetFilesfromArchive, IsNewModule, AsID: Boolean;
begin
  Result := False;
  Screen.Cursor := crHourGlass;
  lblModule.Caption := JVCSRES_Searching464646Please_wait;
  StateLED.ColorOn := clYellow;
  ChkOutComment := '';
  GetFilesfromArchive := not cbDontOverwriteLocal.Checked;
  cbDontOverwriteLocal.Enabled := True;
  if ProjectID > 0 then
    CheckOutProjectID := ProjectID
  else
    CheckOutProjectID := ServerProjectID;

  AsID := (ModuleKey[1] = '>');
  if AsID then
  begin
    Delete(ModuleKey, 1, 1);
    CheckOutModuleID := _StrToInt(ModuleKey);
  end
  else
  begin
    // Get Module ID
    with DataModule1 do
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_MODULE_ID';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [ModuleKey]);
      SetupTimeoutCounter;
      AppSrvClient1.Send;

      while WaitForAppSrvClient do
        Application.ProcessMessages;
      if (AppSrvClientErr = -99) then
      begin
        ShowServerTimeOut(WindowHandle);
        HasErrors := True;
        Exit;
      end;
      if (AppSrvClientErr <> 0) or
        (AppSrvClient1.AnswerStatus <> '200') then
      begin
        ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
          AppSrvClient1.AnswerStatus);
        HasErrors := True;
        Exit;
      end;
      IsNewModule := (AppSrvClient1.Answer.Fields[0] = '0');
      if not IsNewModule then
        CheckOutModuleID := _StrToInt(AppSrvClient1.Answer.Fields[0])
      else
      begin
        // New module
        MsgInfo ( Handle
                , Format(JVCSRES_New_module58_37s, [ModuleKey])
                , cMsgBoxCaption
                );
        Exit;
      end;
    end; // with DataModule1 do begin
  end; // else if AsID

  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    if GetJvcsConnection.SupportsFunctionCode('GET_LATESTREVISION_BY_ID') then
      AppSrvClient1.FunctionCode := 'GET_LATESTREVISION_BY_ID'
    else
      AppSrvClient1.FunctionCode := 'GET_REVISION_LIST_BY_ID';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [CheckOutModuleID]);
    AppSrvClient1.Request.WriteFields(False, [0]); // all projects !
    SetupTimeoutCounter;
    AppSrvClient1.Send;

    while WaitForAppSrvClient do
      Application.ProcessMessages;
    if (AppSrvClientErr = -99) then
    begin
      ShowServerTimeOut(WindowHandle);
      HasErrors := True;
      Exit;
    end;
    if (AppSrvClientErr <> 0) or
      (AppSrvClient1.AnswerStatus <> '200') then
    begin
      ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
        AppSrvClient1.AnswerStatus);
      HasErrors := True;
      Exit;
    end;

    Screen.Cursor := crHourGlass;
    AppSrvClient1.Answer.First;
    if not AppSrvClient1.Answer.Eof then
    begin
      // revisions in the archive
      CheckOutModuleID := _StrToInt(AppSrvClient1.Answer.Fields[0]);
      if AsID then
        lblModule.Hint := AppSrvClient1.Answer.Fields[2] +
          AppSrvClient1.Answer.Fields[1]
      else
        lblModule.Hint := ModuleKey;
      ModuleIsCheckOut := DecodeBoolStr(AppSrvClient1.Answer.Fields[3]);
      TimeStamp := GMTStr2LocalDateTime(AppSrvClient1.Answer.Fields[4]);
      while not AppSrvClient1.Answer.Eof do
      begin
        CheckOutRevisionID := _StrToInt(AppSrvClient1.Answer.Fields[6]);
        CheckOutVersion := _StrToInt(AppSrvClient1.Answer.Fields[7]);
        CheckOutRevision := _StrToInt(AppSrvClient1.Answer.Fields[8]);
        if ModuleIsCheckOut then
          CheckOutModuleOwner := AppSrvClient1.Answer.Fields[9]
        else
          CheckOutModuleOwner := '';
        AppSrvClient1.Answer.Next;
      end; // while not AppSrvClient1.Answer.EoF do begin
      lblModule.Caption := CutPathStr(lblModule.Hint, 45);
      if ModuleIsCheckOut then
      begin
        lblState.Caption := JVCSRES_Locked_;
        StateLED.ColorOn := clRed;
      end
      else
      begin
        lblState.Caption := JVCSRES_Available_;
        StateLED.ColorOn := clLime;
      end;
      if CheckOutModuleOwner <> '' then
        lblState.Caption := lblState.Caption + Format ( JVCSRES_by_37s_
                                                      , [CheckOutModuleOwner]
                                                      );
      lblState.Caption := lblState.Caption + '[' +
        DateTimeToStr(TimeStamp) + '] - ID: ';
      lblState.Caption := lblState.Caption + IntToStr(CheckOutRevisionID);

      lblVer.Caption := IntToStr(CheckOutVersion) + '.' + IntToStr(CheckOutRevision);
      btnCheckOut.Caption := JVCSRES_Check_38Out;
    end // if not AppSrvClient1.Answer.EoF then begin
    else
    begin
      // no revisions in the archive
      if AsID then
      begin
        // Get Module name
        with DataModule1 do
        begin
          AppSrvClient1.Request.Rewrite;
          AppSrvClient1.FunctionCode := 'GET_MODULE_NAME';
          AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
          AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
          AppSrvClient1.Request.WriteFields(True, [CheckOutModuleID]);
          SetupTimeoutCounter;
          AppSrvClient1.Send;

          while WaitForAppSrvClient do
            Application.ProcessMessages;
          if (AppSrvClientErr = -99) then
          begin
            ShowServerTimeOut(WindowHandle);
            HasErrors := True;
            Exit;
          end;
          if (AppSrvClientErr <> 0) or
            (AppSrvClient1.AnswerStatus <> '200') then
          begin
            ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
              AppSrvClient1.AnswerStatus);
            HasErrors := True;
            Exit;
          end;

          lblModule.Hint := AppSrvClient1.Answer.Fields[0];
        end; // with DataModule1 do begin
      end // if AsID then begin
      else
      begin
        lblModule.Hint := ModuleKey;
      end; // else if AsID then begin
      // no revisions in the archive
      lblModule.Caption := CutPathStr(lblModule.Hint, 45);
      StateLED.ColorOn := clRed;
      lblState.Caption := JVCSRES_No_revisions_in_the_archive;
      lblVer.Caption := 'x.x';
      ModuleIsCheckOut := False;
      CheckOutRevisionID := 0;
      CheckOutVersion := 0;
      CheckOutRevision := 1;
      CheckOutModuleOwner := '';
      btnCheckOut.Caption := JVCSRES_38Skip;
    end; // else if not AppSrvClient1.Answer.EoF then begin
  end; // with DataModule1 do begin
  {$IFDEF CUSTOMDRIVE}
  lblModule.Caption := ChangeDriveName(lblModule.Caption, sDriveSubst);
  lblModule.Hint := ChangeDriveName(lblModule.Hint, sDriveSubst);
  {$ENDIF CUSTOMDRIVE}
  rcbxTargetFld.Text := AnsiLowerCase(ExtractFilePath(lblModule.Hint));

  if not FileExists(lblModule.Hint) then
  begin
    cbDontOverwriteLocal.Checked := False;
    cbDontOverwriteLocal.Enabled := False;
  end
  else
    cbDontOverwriteLocal.Checked := not GetFilesfromArchive;

  if cbAll.Enabled and cbAll.Checked then
    meComment.Text := MemoBuffer;

  Screen.Cursor := crDefault;
  Result := True;
end;

//------------------------------------------------------------------------------

procedure TVCSChkOutSingle.btnCheckOutClick(Sender: TObject);
begin
  if ExtractFilePath(lblModule.Hint) <> rcbxTargetFld.Text then
  begin
//  rcbxTargetFld.AutoSave.SaveValue(rcbxTargetFld.Text);
  end;

  MemoBuffer := meComment.Text;
  if MemoBuffer <> '' then
  begin
    jvcsWriteString(sBaseRegistryKey + crbMRU, 'ChkOutComment', MemoBuffer);
    FLastCommentHandler.AddString(MemoBuffer);
  end;
  Delay.Enabled := False;
  if (btnCheckOut.Caption <> JVCSRES_38Skip) then
  begin
    EnableButtons(False);
    InitCheckOut;
  end
  else
    EnableButtons(True);
  Inc(ModuleInProgress);
  if pbQueue.Enabled then
    pbQueue.StepIt;
  while ModuleInProgress < SelectModuleList.Count do
  begin
    Caption := Format ( JVCSRES_Check_Out_45_37d4737d
                      , [(ModuleInProgress + 1), SelectModuleList.Count]
                      );
    PrepareModuleInfo(SelectModuleList.Strings[ModuleInProgress],
      Integer(SelectModuleList.Objects[ModuleInProgress]));
    if CancelOperation then
      Close;
    if cbAll.Enabled and cbAll.Checked then
    begin
      meComment.SetFocus;
      Delay.Enabled := True;
    end
    else
      EnableButtons(True);
    Exit;
  end; // while ModuleInProgress < SelectModuleList.Count do begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSChkOutSingle.DelayTimer(Sender: TObject);
begin
  btnCheckOutClick(Self);
end;

//------------------------------------------------------------------------------

procedure TVCSChkOutSingle.InitCheckOut;
begin
  // description filled out?
  if bPromptfMemo then
  begin
    if Trim(meComment.Lines.Text) = '' then
    begin
      if not Yes2all then
      begin
        // Yes 2 All dialog
        VCSYes2AllDlg := TVCSYes2AllDlg.Create(Application);
        try
          VCSYes2AllDlg.SetMessageText( Format( '%s' + sLineBreak +
                                                JVCSRES_Missing_description_40check_out_memo4146 + sLineBreak +
                                                JVCSRES_Check_out_anyway63
                                              , [ExtractFileName(lblModule.Hint)]
                                              )
                                      );
          if cbAll.Enabled then
            VCSYes2AllDlg.EnableYes2All(True)
          else
            VCSYes2AllDlg.EnableYes2All(False);
          Yes2allRes := VCSYes2AllDlg.ShowModal;
        finally
          VCSYes2AllDlg.Free;
        end;
        case Yes2allRes of
          mrYes:;
          mrAll:
            Yes2all := True;
          mrNo:
            begin
              HasErrors := True;
              Exit;
            end;
          mrCancel:
            begin
              CancelOperation := True;
              HasErrors := True;
              Exit;
            end;
        end; // case Yes2allRes of
      end; // if not Yes2all then begin
    end; // if meComment.Lines.Count < 1 then begin
  end; // if bPromptfMemo then begin

  CheckOut;
  SetForeGroundWindow(Handle);
end;

//------------------------------------------------------------------------------

function TVCSChkOutSingle.CheckOut: Boolean;
var
  FuncRes, hFHandle: Integer;
  TargetDir, TargetFile, OldFile, AffectedFiles, ErrMsg, Comment, Mess: string;
  TargetFDate: TDateTime;
  CloseIDEView, SetROFlag, SetCurrentDate: Boolean;
  {$IFDEF IDEDLL}
  FileWasOpen,FileWasWriteable: Boolean;
  {$ENDIF IDEDLL}
begin
  Result := False;
  ArchiveChanged := True;
  Screen.Cursor := crHourGlass;
  {$IFDEF IDEDLL}
  if (not AsChild) then
    if bPJM_Created then
      bPJM_NeedRefresh := True;
  {$ELSE}
  if (not AsChild) then
    bPJM_NeedRefresh := True;
  {$ENDIF IDEDLL}
  TargetDir := rcbxTargetFld.Text;

  if not cbDontOverwriteLocal.Checked then
  begin
    with DataModule1 do
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_REVISION_STATUS';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [CheckOutRevisionID]);
      SetupTimeoutCounter;
      AppSrvClient1.Send;

      while WaitForAppSrvClient do
        Application.ProcessMessages;
      if (AppSrvClientErr = -99) then
      begin
        ShowServerTimeOut(WindowHandle);
        HasErrors := True;
        Exit;
      end;
      if (AppSrvClientErr <> 0) or
        (AppSrvClient1.AnswerStatus <> '200') then
      begin
        ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
          AppSrvClient1.AnswerStatus);
        HasErrors := True;
        Exit;
      end;

      Screen.Cursor := crHourGlass;
      AppSrvClient1.Answer.First;
      while not AppSrvClient1.Answer.Eof do
      begin
        OldFile := TargetDir + AppSrvClient1.Answer.Fields[1];
        OldFile := ChangeFileExt(OldFile, TrimRight(AppSrvClient1.Answer.Fields[10]));
        if FileExists(OldFile) then
        begin
          // could we rewrite the file?
          hFHandle := FileOpen(OldFile, fmOpenRead or fmShareExclusive);
          if hFHandle = -1 then
          begin
            BeepIfSet;
            ErrorMessageBox( Format( '%s' + sLineBreak +
                              JVCSRES_Could_not_open_the_file_as_ShareExclusive46 + sLineBreak +
                              JVCSRES_Probably_the_file_is_locked_by_another_application46
                            , [OldFile]
                            ));
            HasErrors := True;
            Exit;
          end
          else
            FileClose(hFHandle);

          TargetFDate := FileGetUTCDateTime(OldFile) - cTimeConvErr;
          if _StrToFloat(AppSrvClient1.Answer.Fields[6]) < TargetFDate then
          begin
            if _StrToInt(AppSrvClient1.Answer.Fields[8]) <> CRCInt(OldFile, Mess) then
            begin
              BeepIfSet;
              if MsgYesNoCancel ( WindowHandle
                                , Format( JVCSRES_Module_6037s62_on_disk_has_a_newer_date_than_the_module_in_the_archive33 + sLineBreak +
                                          JVCSRES_Are_you_sure_you_want_to_overwrite_all_changes_of_the_existing_file63
                                        , [ExtractFileName(OldFile)]
                                        )
                                , cMsgBoxCaption
                                , MB_DEFBUTTON2 or MB_ICONWARNING) <> idYes then
              begin
                Screen.Cursor := crDefault;
                HasErrors := True;
                Exit;
              end;
            end;
            // if _StrToInt(AppSrvClient1.Answer.Fields[8]) <> CRCInt(OldFile, Mess) then begin
          end; // if FieldByName('FTIME').AsDateTime...
        end; // if FileExists(OldFile) then begin
        AppSrvClient1.Answer.Next;
      end; // while not AppSrvClient1.Answer.EoF do begin
    end; // with DataModule1 do begin
  end; // if not cbDontOverwriteLocal.Checked then begin

  TargetFile := TargetDir + ExtractFileName(lblModule.Hint);
  CloseIDEView := False;
  //----------------------------------------------------------------------------
  // readonly ?
  SetROFlag := not (MatchWithFilter(ExtractFileName(TargetFile),
    jvcsReadString(sBaseRegistryKey + crbFilters, 'Writeable files', dfNotReadOnly)));
  if (not SkipROCheck) and SetROFlag and
    (not ((FileGetAttr(TargetFile) and faReadOnly) = faReadOnly)) then
  begin
    BeepIfSet;
    {  %s <%s>.\n\rJEDI VCS expects the local file to be %s, but the file is %s.\n\r
       Continue anyway? 383  }
    if MsgYesNoCancel ( WindowHandle
                      , Format( '%s <%s>.' + sLineBreak +
                                JVCSRES_JEDI_VCS_expects_the_local_file_to_be_37s44_but_the_file_is_37s46 + sLineBreak +
                                JVCSRES_Continue_anyway63
                              , [ JVCSRES_Check_Out
                                , TargetFile
                                , JVCSRES_read45only
                                , JVCSRES_writeable
                                ]
                              )
                      , cMsgBoxCaption
                      , MB_DEFBUTTON2 or MB_ICONWARNING
                      ) <> idYes then
    begin
      Screen.Cursor := crDefault;
      HasErrors := True;
      Exit;
    end;
  end;
  //----------------------------------------------------------------------------
  //??? GlobalSettings
  if not SettingIsGlobal(3) then
    SetCurrentDate := (jvcsReadInteger(sBaseRegistryKey + crbOptions,
      'ChkOutDate', 0) = 1)
  else
    SetCurrentDate := GlobalSettingValue(3);

  {$IFDEF IDEDLL}
  // check if file is already open and writeable
  //@@@ToDo fixed file extension!
  FileWasOpen := False;
  FileWasWriteable := False;
  if ((ExtractFileExt(TargetFile) = ('.' + sIDEUnit)) or
    (ExtractFileExt(TargetFile) = '.inc')) then
  begin
    FileWasOpen := IDEInterface.IsFileOpen(TargetFile);
    if FileWasOpen then
    begin
      FileWasWriteable := IDEInterface.IsFileOpenAndWriteable(TargetFile);
      CloseIDEView := True;
    end
    else
      FileWasWriteable := False;
  end;
  {$ENDIF IDEDLL}

  if not cbDontOverwriteLocal.Checked then
    FuncRes := GetBlobs(DBModule.GetJvcsConnection, CheckOutProjectID, ServerUserID,
      CheckOutModuleID, CheckOutRevisionID,
      True{CheckOut}, Application, Self,
      False{SetReadOnly}, CloseIDEView{CloseIDEView},
      SetCurrentDate,
      TargetFile, ErrMsg, AffectedFiles)
  else
    FuncRes := CheckOut_Only(DBModule.GetJvcsConnection, CheckOutProjectID, ServerUserID,
      CheckOutModuleID, CheckOutRevisionID,
      CloseIDEView{CloseIDEView},
      TargetFile, ErrMsg, AffectedFiles);


  if FuncRes <> 0 then
  begin
    case FuncRes of
      1:
        Mess := JVCSRES_91CreateTargetDir93;
      2:
        Mess := JVCSRES_91AppSrvClient46Request93;
      3:
        Mess := JVCSRES_91GET95CHECKOUT95MODULE93;
      4:
        Mess := JVCSRES_91Get_compressed_size93;
      5:
        Mess := JVCSRES_91TFileStream_access93;
      6:
        Mess := JVCSRES_91Extract_zip_file93;
      7:
        Mess := JVCSRES_91Set_original_timestamp93;
      8:
        Mess := JVCSRES_91Replace_local_copy93;
      else
        Mess := JVCSRES_91Unknown93;
    end; // case FuncRes of
    BeepIfSet;
    HasErrors := True;
    if (FuncRes = 3) and
      DSAIdentsGetState(sBaseRegistryKey + crbMRU + 'Dlgs', 'NotifyLocked') then
    begin
      UseRegistry := True;
      // &Don''t show this message again
      DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
      if DSAIdentsMessageDlg( Format( '%s'  + sLineBreak  +
                                      JVCSRES_JEDI_VCS_is_unable_to_create_a_local_copy_of_this_file46 + sLineBreak +
                                      JVCSRES_Exception58_37s_in_37s46 + sLineBreak + sLineBreak +
                                      JVCSRES_Request_check_in_from_the_current_module_owner63
                                    , [TargetFile, ErrMsg, Mess]
                                    )
                            , mtWarning
                            , [mbYes, mbNo, mbCancel]
                            , 0
                            , sBaseRegistryKey + crbMRU + 'Dlgs'
                            , 'NotifyLocked'
                            , idNo
                            ) = idYes then
      begin
        ErrMsg := Copy(ErrMsg, 1, Pos('>', ErrMsg) - 1);
        Delete(ErrMsg, 1, Pos('<', ErrMsg));
        NotifyModuleOwner(ErrMsg, ExtractFileName(TargetFile) + ' [' +
          ExtractFileName(sProjectName) + ']');
      end;
    end
    else
      ErrorMessageBox(Format( '%s'  + sLineBreak  +
                        JVCSRES_JEDI_VCS_is_unable_to_create_a_local_copy_of_this_file46 + sLineBreak +
                        JVCSRES_Exception58_37s_in_37s46
                      , [TargetFile, ErrMsg, Mess]
                      ));
    Exit;
  end; // if FuncRes <> 0 then begin
  // Check out comment
  Comment := meComment.Text;
  //??? GlobalSettings
  if not SettingIsGlobal(14) then
  begin
    if jvcsReadBool(sBaseRegistryKey + crbOptions, 'IncludeIPComment', False) then
      Comment := Comment + sLineBreak + Format(JVCSRES_40Checked_out_to_37s41, [LocalIPAddr]);
  end
  else
  if GlobalSettingValue(14) then
    Comment := Comment + sLineBreak + Format(JVCSRES_40Checked_out_to_37s41, [LocalIPAddr]);

  if Comment <> '' then
  begin
    with DataModule1 do
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'CHANGE_REVISION_COMMENT';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [CheckOutRevisionID]);
      AppSrvClient1.Request.WriteFields(False, ['o']);
      AppSrvClient1.Request.WriteFields(False, [Comment]);
      SetupTimeoutCounter;
      AppSrvClient1.Send;

      while WaitForAppSrvClient do
        Application.ProcessMessages;
      if (AppSrvClientErr = -99) then
      begin
        ShowServerTimeOut(WindowHandle);
        HasErrors := True;
      end;
      if (AppSrvClientErr <> 0) or
        (AppSrvClient1.AnswerStatus <> '200') then
      begin
        ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
          AppSrvClient1.AnswerStatus);
        HasErrors := True;
      end;
    end; // with DataModule1 do begin
  end; // if meComment.Text <> '' then begin

  // keyword expansion
  Screen.Cursor := crHourGlass;
  if ExpandKeywords then
  begin
    Mess := lblModule.Caption;
    lblModule.Caption := JVCSRES_Scanning_file_for_keywords464646;
    Application.ProcessMessages;
    if MatchWithFilter(ExtractFileName(TargetFile), KWExpandFilter) then
      ExpanseKeywords(Application, WindowHandle, kwexCheckOut, TargetFile,
        sCurrentUser, meComment.Text, '', 0, 0, CheckOutModuleID, CheckOutRevisionID);
    lblModule.Caption := Mess;
    Application.ProcessMessages;
  end; // if ExpandKeywords then begin

  {$IFDEF IDEDLL}
  if FileWasOpen then
  begin
    if cbReload.Checked then
    begin
      IDEInterface.OpenFile(GetOriginalFileName(TargetFile));
      if (not FileWasWriteable) and (not IDEInterface.IsFileOpenAndWriteable(TargetFile)) then
        WarnMessageBox(Format(JVCSRES_Module_6037s62_was_checked_out_but_is_still_cached_by_Delphi, [ExtractFileName(TargetFile)]));

      if bMarkSource then
      begin
        Mess := sCurrentUser;
        if sCurrentMachine <> '' then
          Mess := Mess + ' on ' + sCurrentMachine;
        try
          IDESourceWriteString( TargetFile
                              , Format( JVCSRES_123_37s_62_9137s93_checked_out_4737s125
                                      , [LocalDT2GMTStr(Now), Mess, meComment.Text]
                                      )
                              );
        except
          on E: Exception do
          begin
            Screen.Cursor := crDefault;
            MsgError( WindowHandle
                    , Format( JVCSRES_Exception_in_Check_Out46_Step58_37d + sLineBreak + '%s'
                            , [8, E.Message]
                            )
                    , cMsgBoxCaption
                    );
            Screen.Cursor := crDefault;
            Exit;
          end;
        end; // try except
      end; // if bMarkSource then begin
    end // if cbReload.Checked then begin
    else
      if IDEInterface.IsFileOpen(TargetFile) then
        WarnMessageBox(Format(JVCSRES_Module_6037s62_was_checked_out_but_is_still_cached_by_Delphi, [ExtractFileName(TargetFile)]));
  end; // if FileWasOpen
  {$ENDIF IDEDLL}

  if Length(AffectedFiles) > 1 then
    Delete(AffectedFiles, Length(AffectedFiles), 1);

  Mess := Format( JVCSRES_Module_6037s62_successfully_checked_out46 + sLineBreak +
                  JVCSRES_40Affected_files58_37s41
                , [ExtractFileName(TargetFile), AffectedFiles]
                );
  UseRegistry := True;
  DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
  DSAIdentsMessageDlg ( Mess
                      , mtInformation
                      , [mbOK]
                      , 0
                      , sBaseRegistryKey + crbMRU + 'Dlgs'
                      , 'ChkOutSuc'
                      , idOk
                      );
  {$IFDEF IDEDLL}
  if IsIDEProject(TargetFile, sProjectName) then
  begin
    MsgError( WindowHandle
            , Format( JVCSRES_Projectfile_6037s62_checked_out46 + sLineBreak +
                      JVCSRES_You_have_to_close_and_reload_the_project_for_this_change_to_take_effect46
                    , [ExtractFileName(TargetFile)]
                    )
            , cMsgBoxCaption
            );
  end;
  {$ENDIF IDEDLL}

  if Send_Messages then
  begin
    Mess := sCurrentUser;
    if sCurrentMachine <> '' then
      Mess := Mess + ' on ' + sCurrentMachine;
    {  %d|%d|%d|%s|%s|%s|%s 162
       Nr|PjID|UsrID|UsrName|Time|Res|Msg  }
    SendSecureMail('*', sFVCSMailslot, Format(NtfyMsgStr, [3, CheckOutProjectID,
      ServerUserID, sCurrentUser, LocalDT2GMTStr(Now), LocalIPAddr,
      '(to: All) ' + 'checked out: ' + TargetFile]));
  end; // if Send_Messages then begin
  // -- SMTP --
  if Send_SMTP then
    PrepareSMTP(sCurrentUser, LocalIPAddr, '*All*', 'FVCS Notify',
      ExtractFileName(sProjectName), 'checked out: ' + TargetFile, 4);
  // -- SMTP --

  Screen.Cursor := crDefault;
  Result := True;
end;

//------------------------------------------------------------------------------

procedure TVCSChkOutSingle.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    btnCancel.Click;
    Key := 0;
  end;
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_CheckInOut_Out);
  // Default short-cut is also for localized version CTRL-L
  //@@@ToDo later: at the moment hard coded to CTRL-L, CTRL-T, if option
  //               for shortcut exist, change...
  if (Shift * [ssShift, ssAlt, ssCtrl] = [ssCtrl]) and (Chr(Key) in ['L', 'l']) then
    if (not CtrlSCDisabled(WindowHandle)) then
      btnGeLlMemoClick(Self);
  if (Shift * [ssShift, ssAlt, ssCtrl] = [ssCtrl]) and (Chr(Key) in ['T', 't']) then
    if (not CtrlSCDisabled(WindowHandle)) then
      btnGetFromToDoClick(Self);
end;

//------------------------------------------------------------------------------

procedure TVCSChkOutSingle.btnCancelClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSChkOutSingle.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  jvcsWriteWindowPosAndSize(sBaseRegistryKey + crbWindows, 'CheckOut',
    Top, Left, Width, Height);

  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'CheckOut_OneComment',
    cbAll.Checked);
  {$IFDEF IDEDLL}
  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'CheckOut_ReloadFiles',
    cbReload.Checked);
  {$ENDIF IDEDLL}

  // Aktuelles Verzeichnis wiederherstellen
  ChDir(ActDir);
end;

//------------------------------------------------------------------------------

procedure TVCSChkOutSingle.FormDestroy(Sender: TObject);
begin
  SelectModuleList.Free;
  MruListTargetFld.Free;
  FLastCommentHandler.Free;
end;

//------------------------------------------------------------------------------

procedure TVCSChkOutSingle.spBtnBrowseClick(Sender: TObject);
begin
  VCSSelectFolder := TVCSSelectFolder.Create(Application);
  try
    // Target folder:
    VCSSelectFolder.SetStatusText(JVCSRES_38Target_folder58);
    VCSSelectFolder.EnableRecursive(False);
    VCSSelectFolder.HelpContextID := IDH_CheckInOut_Out;
    if rcbxTargetFld.Text <> '' then
      VCSSelectFolder.SetInitialDir(rcbxTargetFld.Text);
    VCSSelectFolder.ShowModal;
    if VCSSelectFolder.Selection <> '' then
    begin
      rcbxTargetFld.Text := SetBackSlash(AnsiLowerCase(VCSSelectFolder.Selection));
      MruListTargetFld.AddString(rcbxTargetFld.Text);
      rcbxTargetFld.Items.Insert(0, rcbxTargetFld.Text);
    end; // if VCSSelectFolder.Selection <> '' then begin
  finally
    VCSSelectFolder.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSChkOutSingle.RestrictSize(var Msg: TMessage);
var
  P: PMinMaxInfo;
begin
  // The lParam contains a pointer on a structure of type TMinMaxInfo
  P := PMinMaxInfo(Msg.lParam);
  // This represents the size of the Window when Maximized
  P.ptMaxSize.x := trResDesktop.Right;
  P.ptMaxSize.y := trResDesktop.Bottom;
  // This represents the position of the Window when Maximized
  P.ptMaxPosition.x := 0;
  P.ptMaxPosition.y := 0;
  // This represents the minimum size of the Window
  P.ptMinTrackSize.x := MulDiv(340, PixelsPerInch, 96);
  P.ptMinTrackSize.y := MulDiv(275, PixelsPerInch, 96);
end;

//------------------------------------------------------------------------------

procedure TVCSChkOutSingle.btnGeLlMemoClick(Sender: TObject);
var
  LastComment: string;
begin
  LastComment := jvcsReadString(sBaseRegistryKey + crbMRU, 'ChkOutComment', 'blank');
  if LastComment <> '' then
  begin
    meComment.Text := LastComment;
    meComment.SetFocus;
    meComment.SelStart := Length(meComment.Text);
  end
  else
    MsgInfo ( WindowHandle
            , Format( JVCSRES_MRU_item_6037s62_is_blank46
                    , [JVCSRES_Last_Check_Out_Comment]
                    )
            , cMsgBoxCaption
            );
end;

//------------------------------------------------------------------------------

procedure TVCSChkOutSingle.btnGetFromToDoClick(Sender: TObject);
var
  I: Integer;
  SelectedItem: string;
  ToDoItems: TStringList;
begin
  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_TODO_ENTRIES';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [0]);
    AppSrvClient1.Request.WriteFields(False, [CheckOutProjectID]);
    AppSrvClient1.Request.WriteFields(False, ['']);
    AppSrvClient1.Request.WriteFields(False, [0]);
    AppSrvClient1.Request.WriteFields(False, [True]);
    AppSrvClient1.Request.WriteFields(False, [0]);
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
      ToDoItems := TStringList.Create;
      try
        while not AppSrvClient1.Answer.Eof do
        begin
          ToDoItems.Add(AppSrvClient1.Answer.Fields[9]);
          AppSrvClient1.Answer.Next;
        end;

        VCSSelectList := TVCSSelectList.Create(Application);
        try
          VCSSelectList.Left := Left + 40;
          VCSSelectList.Top := Top + 40;
          VCSSelectList.SetCaption(JVCSRES_Select_ToDo_item);
          for I := 0 to ToDoItems.Count - 1 do
            VCSSelectList.AddListItem(ToDoItems.Strings[I]);
          VCSSelectList.ShowModal;
          SelectedItem := VCSSelectList.ResultString;
        finally
          VCSSelectList.Free;
        end;
      finally
        ToDoItems.Free;
      end;
    end // if not AppSrvClient1.Answer.EoF then begin
    else
    begin
      MsgInfo ( Handle
              , JVCSRES_ToDo_list_contains_no_entries_for_this_project46
              , cMsgBoxCaption
              );
      Exit;
    end;
  end; // with DataModule1 do begin

  if SelectedItem <> '' then
  begin
    meComment.Text := SelectedItem;
    meComment.SetFocus;
    meComment.SelStart := Length(meComment.Text);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSChkOutSingle.HelpClick(Sender: TObject);
var
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSChkOutSingle.spBtnUndoClick(Sender: TObject);
begin
  meComment.Perform(EM_UNDO, 0, 0);
end;

//------------------------------------------------------------------------------

procedure TVCSChkOutSingle.NotifyModuleOwner(const ModOwner, ModuleName: string);
begin
  NtfySendForm := TNtfySendForm.Create(Application);
  try
    NtfySendForm.MailType := 8;
    NtfySendForm.SetUpUserList(ModOwner + ';');
    NtfySendForm.SetUpMessage ( Format( JVCSRES_Please_finish_your_work_and_re45check_in_module58_37s
                                      , [ModuleName]
                                      )
                              );
    NtfySendForm.ShowModal;
  finally
    NtfySendForm.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSChkOutSingle.cbDontOverwriteLocalClick(Sender: TObject);
begin
  if SettingIsGlobal(9) and (cbDontOverwriteLocal.Checked <> GlobalSettingValue(9)) then
  begin
    ShowGlobalSettingsWarning(WindowHandle, GlobalSettingValue(9));
    cbDontOverwriteLocal.Checked := GlobalSettingValue(9);
    Exit;
  end;
  if (not bFCreating) and cbDontOverwriteLocal.Checked then
  begin
    UseRegistry := True;
    DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
    if DSAIdentsMessageDlg( Format( JVCSRES_This_is_a_potentially_dangerous_option_and_only_recommended_for_rexperienced_users46 + sLineBreak +
                                    JVCSRES_Inproper_use_may_cause_data_loss33 + sLineBreak +
                                    JVCSRES_Please_read_the_related_help_topic_before_enabling_this_option46 + sLineBreak +
                                    JVCSRES_Enable_3437s34_anyway63
                                  , [JVCSRES_Don39t_overwrite_local_files]
                                  )
                          , mtWarning
                          , [mbYes, mbNo, mbCancel]
                          , 0
                          , sBaseRegistryKey + crbMRU + 'Dlgs'
                          , 'DontOverwrLocal'
                          , idYes
                          ) <> idYes then
    begin
      cbDontOverwriteLocal.Checked := False;
    end;
  end; // if cbDontOverwriteLocal.Checked
end;

end.
