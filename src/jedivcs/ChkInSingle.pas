(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: ChkInSingle.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS: Thomas Huber (Thomas_D_Huber@t-online.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
May/03:
- maybe it's necessary to call GET_PROJECT_ID if CheckinProjectID <> ServerProjectID
  in order to get a new TransactionNr
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FreeVCS code to JEDI VCS
2003/02/12  USchuster - changed DSAMsg with JVCSDialogs in uses clause to use JvDSADialogs
2003/02/18  MGosselink- emptied some .text props, changed Led color green to lime
2003/02/18  THuber    - changed TJvHTComboBox => TJvComboBox
2003/03/03  THensle   - changes for "ConfigStorage" unit
2003/03/15  THuber    - compilerwarnings/most hints removed
2003/04/08  USchuster - changes for IDEInterface
2003/04/11  MGosselink- Added a compare button, mantis ID 857
2003/04/11  FBouwmans - Added multiple projectid for local project admin
2003/05/18  USchuster - fixed multiple projectid (mantis #880/1.&2.)
2003/07/18  THuber    - JEDI-VCS => JEDI VCS
2003/08/02  THuber    - mantis #861: replaced TMemo with TJvMemo
2003/10/05  THuber    - compiler hints & warnings
2003/11/09  USchuster - exchanged TextComp call with new procedure DoCompareModule
                      - now with constant instead of 'JEDI VCS' in messageboxes
2004/02/24  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/04/12  USchuster - AutoComplete in ComboBox now False and Style is
                        csDropDownList again(lost in migration from FreeVCS to JEDI VCS)
                      - minor style cleaning (casing and comments)
2004/06/02  USchuster - check in comment memo is now locked while retrieving the
                        module state and last check out comment (mantis #1773)
2004/07/28  USchuster - fixed bug (check in description is "please wait...") which was
                        introduced with the changes for mantis #1773 (mantis #1957)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/10  THuber    - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
                      - use jvcl msgBoxes
2004/10/12  USchuster - mantis #2205
2004/10/19  THuber    - #1954 replaced zipmaster with abbrevia over JVCSCompressFile
2005/01/24  CSchuette - changed TTimer interval from 500 to 50 to speed up CheckOn/CheckOut of multiple files
2005/04/11  CSchuette - mantis #2815
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC2 was released ^^^^^^^^^^^^^^^^^^^^^^^^^^^
2005/04/25  CSchuette - added call to "ResolveFileFamilies" to fix mantis #1205
2005/05/22  USchuster - added comment history feature (mantis #2713)
2005/06/30  CSchuette - added option "check in comment required"
2005/07/15  THuber    #3091 reactivated again Shortcuthandling
2005/09/22  THuber    #3211 adjust AutoExpand Buffer for Blob transfer (Checkin)
                      added min buffer size to size calculation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 released ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
2006/10/03  USchuster - fixed check in with an already assigned label (mantis #3830)
2007/04/08  USchuster - fixed self handled shortcuts (mantis #4087)
2007/06/29  USchuster - changes for large fonts (contraints and default size depend now on PixelsPerInch; Mantis #3710)
2007/09/12  USchuster - improved empty comment check (Mantis #4227)
2007/09/25  USchuster - added check out IP comment check to empty comment check (Mantis #4227)
2010/01/23  USchuster - little speedup of check in preparation (Mantis #5082)
2010/01/24  THuber - Directive B L O W F I S H removed as we use Blowfish-encryption always
2010/01/24  USchuster - added "Diff" speed buttons (Mantis #5101)
2010/01/28  USchuster - images for "Diff" speed buttons (Mantis #5101)
2010/02/06  USchuster - D5 fix
2011/01/15  USchuster - changed font to Tahoma
2012/07/08  AKroeber  - changed AnsiCrLf to sLineBreak (avoid using of JclAnsiString.pas - should work from Delphi 6 to XE2)

-----------------------------------------------------------------------------*)

unit ChkInSingle;

{$I jedi.inc}
{$I compopt.inc}

{$IFDEF DELPHI6_UP}
  {$WARN UNIT_PLATFORM OFF}
  {$WARN SYMBOL_PLATFORM OFF}
{$ENDIF DELPHI6_UP}

{$IFNDEF DEBUG}
  {$UNDEF CHIDEBUG}
{$ENDIF ~DEBUG}

interface

uses
  {$IFDEF DEBUG}
  JclDebug,
  {$ENDIF DEBUG}
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ImgList, Buttons, ComCtrls, RFormat, JvLED, JvComponent,
  JvCombobox, JvMemo, JvExStdCtrls, JvExControls, JvArrowButton, JVCSChkInOutCommon,
  Menus;

type
  TVCSChkInSingle = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    Label2: TLabel;
    meComment: TJvMemo;
    Delay: TTimer;
    spBtnKeyword: TSpeedButton;
    lblQueue: TLabel;
    pbQueue: TProgressBar;
    cbAutoClose: TCheckBox;
    cbAll: TCheckBox;
    Panel3: TPanel;
    spBtnGetLComment: TJvArrowButton;
    spBtnGetToDoComment: TSpeedButton;
    Help: TSpeedButton;
    spBtnUndo: TSpeedButton;
    cbPut: TCheckBox;
    cbUnlockUnchanged: TCheckBox;
    Panel4: TPanel;
    Panel5: TPanel;
    lblState: TLabel;
    StateLED: TJvLED;
    lblModule: TLabel;
    Panel6: TPanel;
    lblVer: TLabel;
    ecbxKeyword: TJvComboBox;
    LabelBuffer: TMWBuffer;
    spBtnCompare: TSpeedButton;
    spbtnDiff1: TSpeedButton;
    spbtnDiff2: TSpeedButton;
    spbtnDiff3To5: TJvArrowButton;
    pmDiff: TPopupMenu;
    mnDiff3: TMenuItem;
    mnDiff4: TMenuItem;
    mnDiff5: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DelayTimer(Sender: TObject);
    procedure spBtnKeywordClick(Sender: TObject);
    procedure btnGeLlMemoClick(Sender: TObject);
    procedure btnGetFromToDoClick(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure spBtnUndoClick(Sender: TObject);
    procedure cbPutClick(Sender: TObject);
    procedure cbUnlockUnchangedClick(Sender: TObject);
    procedure spBtnCompareClick(Sender: TObject);
    procedure spbtnDiff1Click(Sender: TObject);
  private
    bFCreating,
    bMarkSource,
    bPromptfMemo,
    bMemoRequired,
    Send_Messages,
    Send_SMTP,
    CancelOperation,
    SkipROCheck,
    Yes2all,
    ExpandKeywords: Boolean;
    Yes2allRes: Integer;
    ModuleInProgress: Integer;
    ActDir,
    MemoBuffer,
    CheckinModuleName,
    KWExpandFilter: string;
    CheckinModuleID,
    CheckinProjectID,
    CheckinRevisionID,
    CheckinLabelID,
    CheckinVersion,
    CheckinRevision: Integer;
    CheckinComment: string;
    FLastCommentHandler: TLastCommentHandler;
    FCurrentModuleFileNames: TStringList;
    { Private declarations }
    procedure EnableButtons(Enable: Boolean);
    procedure GetKeywordList;
    function PrepareModuleInfo(ModuleKey: string; ProjectID: Integer): Boolean;
    procedure InitCheckIn;
    function Checkin(ModuleName: string; const ModuleID, ProjectID, LabelID,
      Version, Revision: Integer; Comment: string;
      var AffectedFiles: string): Boolean;
    function SetupZipFile(const SourceFile: string; var ZipFile: string;
      var ErrMsg: string): Boolean;
    procedure UpdateDiffButtons;
  public
    { Public declarations }
    SelectModuleList: TStringList;
    AsChild,
    HasErrors,
    ArchiveChanged: Boolean;
    procedure RestrictSize(var Msg: TMessage); Message WM_GETMINMAXINFO;
  end;

var
  VCSChkInSingle: TVCSChkInSingle;

implementation

uses
    VCSBase
  , VCSProcBase
  , JVCSDialogs
  , mdMailSlot
  , IniFiles
  , Checksum
  , Yes2allDlg
  , TZHandling
  , ApsCli
  , DBModule
  , MaintainLabels
  , JVCSClientConsts
  , SelectList
  , KWExpansion
  , SMTPSend
  , ConfigStorage
  , TextComp
  {$IFDEF IDEDLL}
  , JVCSIDEInterface
  {$ENDIF IDEDLL}
  , BFCrypt
  , JclStrings
  , JvJVCLUtils
  , JVCSGUIClientResources
  , JVCSClientFunctions
  , JVCSClientObjBase
{$IFDEF LANGUAGE}
  , JvGnugettext
{$ENDIF LANGUAGE}
  , JVCSCompressedDiffDialog, JVCSGUIClientImages
  ;

{$R *.dfm}

//------------------------------------------------------------------------------

function RemoveCheckOutIP(AStr: string): string;
var
  S, S1, S2: string;
  P1, P2, P2C, I: Integer;
begin
  S := JVCSRES_40Checked_out_to_37s41;
  P1 := Pos('%s', S);
  Result := AStr;
  if P1 > 0 then
  begin
    S1 := Copy(S, 1, P1 - 1);
    S2 := Copy(S, P1 + 2, Length(S) - P1 - 1);
    if (S1 <> '') and (S2 <> '') then
    begin
      S := AStr;
      P1 := Pos(S1, S);
      if P1 > 0 then
      begin
        P2C := 0;
        Delete(S, 1, P1 - 1 + Length(S1));
        Inc(P2C, P1 - 1 + Length(S1));
        I := 1;
        while (I <= Length(S)) and (S[I] in ['0'..'9', '.']) do
          Inc(I);
        if I > 1 then
        begin
          Delete(S, 1, I - 1);
          Inc(P2C, I - 1);
        end;
        P2 := Pos(S2, S);
        if P2 > 0 then
        begin
          Inc(P2, P2C);
          S := AStr;
          Delete(S, P1, P2 - P1 + 1);
          Result := S;
        end;
      end;
    end;
  end;
end;

procedure TVCSChkInSingle.FormCreate(Sender: TObject);
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
    cbAutoClose.Enabled := False;
    {$ENDIF ~IDEDLL}
    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    if not jvcsReadWindowPosAndSize(sBaseRegistryKey + crbWindows, 'CheckIn',
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
      'CheckIn_OneComment', True);
    {$IFDEF IDEDLL}
    cbAutoClose.Checked := jvcsReadBool(sBaseRegistryKey + crbWindows,
      'CheckIn_CloseFiles', True);
    {$ENDIF IDEDLL}
    bPromptfMemo := jvcsReadBool(sBaseRegistryKey + crbOptions, 'PromptFMemo', True);
    KWExpandFilter := jvcsReadString(sBaseRegistryKey + crbOptions,  'KWExpFiles', dfKWExp);

    //??? GlobalSettings
    if not SettingIsGlobal(18) then
      bMemoRequired := jvcsReadBool(sBaseRegistryKey + crbOptions, 'MemoRequired', False)
    else
      bMemoRequired := GlobalSettingValue(18);
    if not SettingIsGlobal(13) then
      cbUnlockUnchanged.Checked := jvcsReadBool(sBaseRegistryKey + crbOptions,
        'UnlockUnchangedFiles', True)
    else
      cbUnlockUnchanged.Checked := GlobalSettingValue(13);
    if not SettingIsGlobal(4) then
      ExpandKeywords := jvcsReadBool(sBaseRegistryKey + crbOptions,
        'KWExpCheckIn', False)
    else
      ExpandKeywords := GlobalSettingValue(4);
    if not SettingIsGlobal(16) then
      Send_Messages := jvcsReadBool(sBaseRegistryKey + crbOptions,
        'NotifyActive', False) and jvcsReadBool(sBaseRegistryKey + crbOptions,
        'MessChkIn', False)
    else
      Send_Messages := GlobalSettingValue(16);
    if not SettingIsGlobal(17) then
      SkipROCheck := jvcsReadBool(sBaseRegistryKey + crbOptions, 'NoROCheck', False)
    else
      SkipROCheck := GlobalSettingValue(17);
    if not SettingIsGlobal(1) then
      bMarkSource := jvcsReadBool(sBaseRegistryKey + crbOptions,
        'MarkSource_I', False) and jvcsReadBool(sBaseRegistryKey + crbOptions,
        'MarkSource', False)
    else
      bMarkSource := GlobalSettingValue(1);

    Send_SMTP := jvcsReadBool(sBaseRegistryKey + crbOptions, 'SMTPMessages',
      False) and jvcsReadBool(sBaseRegistryKey + crbOptions, 'MessChkIn', False);

    {$IFDEF CUSTOMDRIVE}
    sDriveSubst := RegReadString(HKCU, sBaseRegistryKey + crbProjects +
      ExtractFileName(sProjectName), 'LocalDrive', '');
    if (sDriveSubst = '') then
      sDriveSubst := RegReadString(HKCU, sBaseRegistryKey + crbOptions,
        'LocalDrive', '');
    {$ENDIF CUSTOMDRIVE}

    SelectModuleList := TStringList.Create;
    ModuleInProgress := 0;
    ArchiveChanged := False;
    AsChild := False;
    CancelOperation := False;
    Yes2all := False;
    CheckinModuleName := '';
    CheckinProjectID := ServerProjectID;
    CheckinModuleID := 0;
    CheckinLabelID := 0;
    CheckinVersion := 0;
    CheckinRevision := 0;
    CheckinComment := '';
    HasErrors := False;
    DSAIdentsSetState(sBaseRegistryKey + crbMRU + 'Dlgs', 'PutMsg', True);
    FLastCommentHandler := TLastCommentHandler.CreateEx(Self, 'ChkIn', meComment);
    spBtnGetLComment.DropDown := FLastCommentHandler.PopupMenu;
    FCurrentModuleFileNames := TStringList.Create;

    {$IFDEF DELPHI6_UP}
    if GetToolImageList.GetBitmap(51, spbtnDiff1.Glyph) then
      spbtnDiff1.Caption := '';
    if GetToolImageList.GetBitmap(52, spbtnDiff2.Glyph) then
      spbtnDiff2.Caption := '';
    if GetToolImageList.GetBitmap(50, spbtnDiff3To5.Glyph) then
      spbtnDiff3To5.Caption := '';
    {$ELSE ~DELPHI6_UP}
    if GetToolImageList.HandleAllocated and (GetToolImageList.Count > 52) then
    begin
      GetToolImageList.GetBitmap(51, spbtnDiff1.Glyph); 
      spbtnDiff1.Caption := '';
      GetToolImageList.GetBitmap(52, spbtnDiff2.Glyph);
      spbtnDiff2.Caption := '';
      GetToolImageList.GetBitmap(50, spbtnDiff3To5.Glyph); 
      spbtnDiff3To5.Caption := '';
    end;
    {$ENDIF ~DELPHI6_UP}
    if ShowMenuBitmaps then
    begin
      pmDiff.Images := GetToolImageList;
      mnDiff3.ImageIndex := 53;
      mnDiff4.ImageIndex := 54;
      mnDiff5.ImageIndex := 55;
    end;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSChkInSingle.spBtnKeywordClick(Sender: TObject);
var 
  Changed: Boolean;
begin
  VCSMaintainLabels := TVCSMaintainLabels.Create(Application);
  try
    VCSMaintainLabels.Left := Left + 60;
    VCSMaintainLabels.Top := Top + 60;
    VCSMaintainLabels.ShowModal;
    Changed := VCSMaintainLabels.LabelsChanged;
  finally
    VCSMaintainLabels.Free;
  end;
  if Changed then 
    GetKeywordList;
end;

//------------------------------------------------------------------------------

procedure TVCSChkInSingle.GetKeywordList;
begin
  ecbxKeyword.Items.Clear;
  ecbxKeyword.Items.Add(JVCSRES_4545_None_4545); // = ItemIndex 0
  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_LABELS';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [False]); // incl. descriprion
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

    AppSrvClient1.Answer.First;
    // Labels
    LabelBuffer.Rewrite;
    while (not AppSrvClient1.Answer.Eof) do
    begin
      LabelBuffer.WriteFields(True, [AppSrvClient1.Answer.Fields[0],
        AppSrvClient1.Answer.Fields[1]]);
      ecbxKeyword.Items.Add(AppSrvClient1.Answer.Fields[1]);
      AppSrvClient1.Answer.Next;
    end; // while (not AppSrvClient1.Answer.EoF)
  end; // with DataModule1 do begin
end;

//------------------------------------------------------------------------------

procedure TVCSChkInSingle.FormActivate(Sender: TObject);
var //Msg,
  CurrentFile: string;
begin
  Application.ProcessMessages;
  if bFCreating then
  begin
    bFCreating := False;
    Screen.Cursor := crHourGlass;

    // Keywörter lesen
    GetKeywordList;

    if SelectModuleList.Count > 0 then
    begin
      if AsChild then
        Caption := Format(JVCSRES_Check_In_45_14737d, [SelectModuleList.Count])
      else
        Caption := Format(JVCSRES_VCS_Check_In_45_14737d, [SelectModuleList.Count]);
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
        Caption := Format(JVCSRES_Check_In_45_14737d, [1])
      else
        Caption := Format(JVCSRES_VCS_Check_In_45_14737d, [1]);
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

    Screen.Cursor := crDefault;
  end; // if bFCreating then begin
end;

//------------------------------------------------------------------------------

procedure TVCSChkInSingle.EnableButtons(Enable: Boolean);
begin
  btnOK.Enabled := Enable;
  btnCancel.Enabled := Enable;
  ecbxKeyword.Enabled := Enable;
  spBtnKeyword.Enabled := Enable;
  spBtnGetLComment.Enabled := Enable;
  spBtnGetToDoComment.Enabled := Enable;
  spBtnUndo.Enabled := Enable;
  spBtnCompare.Enabled := Enable;
  UpdateDiffButtons;
end;

//------------------------------------------------------------------------------

function TVCSChkInSingle.PrepareModuleInfo(ModuleKey: string;
  ProjectID: Integer): Boolean;
var
  UserID: Integer;
  ModuleOwner: string;
  ChkOutComment: string;
  IsCheckedOut: Boolean;
  TimeStamp: TDateTime;
  IsNewModule, AsID: Boolean;
  OldMemoText: string;
begin
  Result := False;
  Screen.Cursor := crHourGlass;
  StateLED.ColorOn := clYellow;
  lblModule.Caption := JVCSRES_Searching464646Please_wait;
  ChkOutComment := '';
  CheckinRevisionID := 0;
  if ProjectID > 0 then
  begin
    CheckinProjectID := ProjectID;
  end
  else
  begin
    CheckinProjectID := ServerProjectID;
  end;

  if (cbAll.Enabled and cbAll.Checked and (MemoBuffer <> '')) or
    jvcsReadBool(sBaseRegistryKey + crbOptions, 'LastOutDescr', False) then
  begin
    meComment.Enabled := False;
    OldMemoText := meComment.Text;
    meComment.Text := JVCSRES_Please_wait464646;
  end;
  try
    AsID := (ModuleKey[1] = '>');
    if AsID then
    begin
      Delete(ModuleKey, 1, 1);
      CheckinModuleID := _StrToInt(ModuleKey);
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
          CheckinModuleID := _StrToInt(AppSrvClient1.Answer.Fields[0])
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
      AppSrvClient1.Request.WriteFields(True, [CheckinModuleID]);
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
  //    _StrToInt(AppSrvClient1.Answer.Fields[0]);
        if AsID then 
          lblModule.Hint := AppSrvClient1.Answer.Fields[2] +
            AppSrvClient1.Answer.Fields[1]
        else 
          lblModule.Hint := ModuleKey;
        IsCheckedOut := DecodeBoolStr(AppSrvClient1.Answer.Fields[3]);
        TimeStamp := GMTStr2LocalDateTime(AppSrvClient1.Answer.Fields[4]);
        UserID := _StrToInt(AppSrvClient1.Answer.Fields[5]);
        while not AppSrvClient1.Answer.Eof do 
        begin
          CheckinRevisionID := _StrToInt(AppSrvClient1.Answer.Fields[6]);
          CheckinVersion := _StrToInt(AppSrvClient1.Answer.Fields[7]);
          CheckinRevision := _StrToInt(AppSrvClient1.Answer.Fields[8]) + 1; // new Revision
          if IsCheckedOut then 
            ModuleOwner := AppSrvClient1.Answer.Fields[9]
          else 
            ModuleOwner := '';
          AppSrvClient1.Answer.Next;
        end; // while not AppSrvClient1.Answer.EoF do begin
        lblModule.Caption := CutPathStr(lblModule.Hint, 45);
        if IsCheckedOut then
        begin
          if UserID = ServerUserID then
            StateLED.ColorOn := clLime
          else
            StateLED.ColorOn := clRed;
          lblState.Caption := JVCSRES_Locked_
        end
        else
        begin
          StateLED.ColorOn := clYellow;
          lblState.Caption := JVCSRES_Unlocked_;
        end;
        if ModuleOwner <> '' then
          lblState.Caption := lblState.Caption + Format(JVCSRES_by_37s_, [ModuleOwner]);
        lblState.Caption := lblState.Caption + '[' +
          DateTimeToStr(TimeStamp) + '] - ID: ';
        lblState.Caption := lblState.Caption + IntToStr(CheckinRevisionID);
        lblVer.Caption := IntToStr(CheckinVersion) + '.' + IntToStr(CheckinRevision);
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
            AppSrvClient1.Request.WriteFields(True, [CheckinModuleID]);
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
            CheckinModuleName := lblModule.Hint;
          end; // with DataModule1 do begin
        end // if AsID then begin
        else
        begin
          lblModule.Hint := ModuleKey;
        end; // else if AsID then begin
        // no revisions in the archive
        lblModule.Caption := CutPathStr(lblModule.Hint, 45);
        StateLED.ColorOn := clLime;
        lblState.Caption := JVCSRES_No_revisions_in_the_archive;
        lblVer.Caption := '0.1';
        CheckinRevisionID := 0;
        CheckinVersion := 0;
        CheckinRevision := 1;
        ModuleOwner := '';
      end; // else if not AppSrvClient1.Answer.EoF then begin
    end; // with DataModule1 do begin

    {$IFDEF CUSTOMDRIVE}
    lblModule.Caption := ChangeDriveName(lblModule.Caption, sDriveSubst);
    lblModule.Hint := ChangeDriveName(lblModule.Hint, sDriveSubst);
    CheckinModuleName := lblModule.Hint;
    {$ELSE}
    CheckinModuleName := lblModule.Hint;
    {$ENDIF CUSTOMDRIVE}

    if cbAll.Enabled and cbAll.Checked and
      (MemoBuffer <> '') then
    begin
      meComment.Text := MemoBuffer;
    end // if cbAll.Checked then begin
    else
    begin
      if (CheckinRevisionID <> 0) and
        jvcsReadBool(sBaseRegistryKey + crbOptions, 'LastOutDescr', False) then
      begin
        with DataModule1 do
        begin
          AppSrvClient1.Request.Rewrite;
          AppSrvClient1.FunctionCode := 'GET_REVISION_COMMENT';
          AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
          AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
          AppSrvClient1.Request.WriteFields(True, [CheckinRevisionID]);
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

          AppSrvClient1.Answer.First;
          if not AppSrvClient1.Answer.Eof then
            meComment.Text := AppSrvClient1.Answer.Fields[1];
        end; // with DataModule1 do begin
      end; // if (RevisionID <> 0) and....
    end; // else if cbAll.Checked then begin}
  finally
    if not meComment.Enabled then
    begin
      meComment.Enabled := True;
      if meComment.Text = JVCSRES_Please_wait464646 then
        meComment.Text := OldMemoText;
      meComment.SetFocus;
      meComment.SelStart := Length(meComment.Text);
    end;
  end;
  Screen.Cursor := crDefault;
  Result := True;
end;

//------------------------------------------------------------------------------

procedure TVCSChkInSingle.btnOKClick(Sender: TObject);
begin
  MemoBuffer := meComment.Text;
  if Trim(RemoveCheckOutIP(MemoBuffer)) <> '' then
  begin
    jvcsWriteString(sBaseRegistryKey + crbMRU, 'ChkInComment', MemoBuffer);
    FLastCommentHandler.AddString(MemoBuffer);
  end;
  Delay.Enabled := False;
  EnableButtons(False);
  InitCheckIn;
  if CancelOperation then
  begin
    EnableButtons(True);
    Exit;
  end;
  Inc(ModuleInProgress);
  if pbQueue.Enabled then
  begin
    pbQueue.StepIt;
  end;
  while ModuleInProgress < SelectModuleList.Count do
  begin
    Caption := Format ( JVCSRES_Check_In_45_37d4737d
                      , [ModuleInProgress + 1, SelectModuleList.Count]
                      );
    PrepareModuleInfo ( SelectModuleList.Strings[ModuleInProgress]
                      , Integer(SelectModuleList.Objects[ModuleInProgress])
                      );
    if CancelOperation then
    begin
      Close;
    end;
    if cbAll.Enabled and cbAll.Checked then
    begin
      meComment.SetFocus;
      Delay.Enabled := True;
    end
    else
    begin
      EnableButtons(True);
    end;
    Exit;
  end; // while ModuleInProgress < SelectModuleList.Count do begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSChkInSingle.DelayTimer(Sender: TObject);
begin
  btnOKClick(Self);
end;

//------------------------------------------------------------------------------

procedure TVCSChkInSingle.InitCheckIn;
var
  DlgMsg, AffectedFiles: string;
begin
  HasErrors := False;
  CancelOperation := False;

  //--- Has checkin comment? ---------------------------------------------------

  if bPromptfMemo then
  begin
    if Trim(RemoveCheckOutIP(meComment.Lines.Text)) = '' then
    begin

      // New option: CheckIn required?
      if bMemoRequired then
      begin
        BeepIfSet;
        ErrorMessageBox(JVCSRES_Check_In_comment_cannot_be_empty);
        HasErrors := True;
        CancelOperation := True;
        Exit;
      end;

      if not Yes2all then
      begin
        // Yes 2 All dialog
        VCSYes2AllDlg := TVCSYes2AllDlg.Create(Application);
        try
          VCSYes2AllDlg.SetMessageText( Format( '<%s>' + sLineBreak +
                                                JVCSRES_Missing_description_40check_in_memo4146 + sLineBreak +
                                                JVCSRES_Check_in_anyway63
                                              , [ExtractFileName(CheckinModuleName)]
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
          mrYes :;
          mrAll :
            Yes2all := True;
          mrNo :
            begin
              HasErrors := True;
              Exit;
            end;
          mrCancel :
            begin
              CancelOperation := True;
              HasErrors := True;
              Exit;
            end;
        end; // case Yes2allRes of
      end; // if not Yes2all then begin
    end; // if meComment.Lines.Count < 1 then begin
  end; // if bPromptfMemo then begin

  //--- Is file readonly? ------------------------------------------------------

  if (not SkipROCheck) and ((FileGetAttr(CheckinModuleName) and faReadOnly) = faReadOnly) then
  begin
    BeepIfSet;
    case MsgYesNoCancel ( WindowHandle
                        , Format ('%s <%s>.'+ sLineBreak +
                                  JVCSRES_JEDI_VCS_expects_the_local_file_to_be_37s44_but_the_file_is_37s46 + sLineBreak +
                                  JVCSRES_Continue_anyway63
                                 ,[ JVCSRES_Check_In
                                  , CheckinModuleName
                                  , JVCSRES_writeable
                                  , JVCSRES_read45only
                                  ]
                                 )
                        , cMsgBoxCaption
                        , MB_DEFBUTTON2 or MB_ICONWARNING
                        ) of
      idYes:;
      idNo:
        begin
          HasErrors := True;
          Exit;
        end;
      else
        begin
          CancelOperation := True;
          HasErrors := True;
          Exit;
        end;
    end; // case
  end; // if (FileGetAttr(...
  //--- Labels -----------------------------------------------------------------
  CheckinLabelID := 0;
  if ecbxKeyword.ItemIndex > 0 then
  begin
    LabelBuffer.First;
    while not LabelBuffer.Eof do
    begin
      if (ecbxKeyword.Text = LabelBuffer.Fields[1]) then
      begin
        CheckinLabelID := _StrToInt(LabelBuffer.Fields[0]);
        Break;
      end;
      LabelBuffer.Next;
    end;
  end; // if ecbxKeyword.Items.ItemIndex <> 0 then begin
  if CheckinLabelID <> 0 then
  begin
    with DataModule1 do
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'ADD_REMOVE_REVISION_LABEL';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [CheckinModuleID]);
      AppSrvClient1.Request.WriteFields(False, [0]); // not needed
      AppSrvClient1.Request.WriteFields(False, [CheckinLabelID]);
      AppSrvClient1.Request.WriteFields(False, [True]); // add the label
      AppSrvClient1.Request.WriteFields(False, [True]); // only a check?
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

      if not DecodeBoolStr(AppSrvClient1.Answer.Fields[0]) then
      begin
        BeepIfSet;
        DlgMsg := Format( JVCSRES_Label_6037s62_is_already_assigned_to_V_37s46_37s_of_this_module46_ + sLineBreak +
                          JVCSRES_Access_denied46
                        , [ ecbxKeyword.Text
                          , AppSrvClient1.Answer.Fields[2]
                          , AppSrvClient1.Answer.Fields[3]
                          ]
                        );
        ErrorMessageBox(DlgMsg);
        HasErrors := True;
        Exit;
      end; // if not DecodeBoolStr(....
    end; // with DataModule1 do begin
  end; // if CheckinLabelID <> 0 then begin

  // comment
  CheckinComment := meComment.Text;

  {$IFDEF DEBUGMSG}
  ShowMessage('CheckinModuleName: ' + CheckinModuleName + #10#13 +
    'CheckinModuleID: ' + IntToStr(CheckinModuleID) + #10#13 +
    'CheckinVersion: ' + IntToStr(CheckinVersion) + #10#13 +
    'CheckinRevision: ' + IntToStr(CheckinRevision) + #10#13 +
    'CheckinLabelID: ' + IntToStr(CheckinLabelID));
  {$ENDIF DEBUGMSG}

  if Checkin(CheckinModuleName, CheckinModuleID, CheckinProjectID, CheckinLabelID,
    CheckinVersion, CheckinRevision, CheckinComment, AffectedFiles) then
  begin
    UseRegistry := True;
    DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
    if cbPut.Checked then
      DlgMsg := Format( JVCSRES_Module_6037s62_successfully_checked_in46
                      , [ExtractFileName(CheckinModuleName)]
                      )
    else
      DlgMsg := Format( JVCSRES_Module_6037s62_successfully_updated46
                      , [ExtractFileName(CheckinModuleName)]
                      );
    DlgMsg := DlgMsg + sLineBreak + Format(JVCSRES_Affected_files58_37s, [AffectedFiles]);
    DSAIdentsMessageDlg(DlgMsg
      , mtInformation
      , [mbOK]
      , 0
      , sBaseRegistryKey + crbMRU + 'Dlgs'
      , 'ChkInSuc'
      , idOk
      );
  end
  else
  begin
    DlgMsg := Format(JVCSRES_6037s62_not_added46, [ExtractFileName(CheckinModuleName)]);
    WarnMessageBox(DlgMsg);
  end;
end;

{-------------------------------------------------------------------------------

 //thu 01.07.2003 vvv
 @@@Todo: Bug on checkin with file family file
 Eg.: 1) Checkout dpr/dof/res
      2) change res/dof -but not dpr-
      3) checkin: check checkbutton cbUnlockUnchanged!
      4) => bugs in result:
            a) res/dof are not checked in
            b) res/dof still remain checked out
 ^^^
 ------------------------------------------------------------------------------}

function TVCSChkInSingle.Checkin(ModuleName: string; const ModuleID, ProjectID,
  LabelID, Version, Revision: Integer; Comment: string;
  var AffectedFiles: string): Boolean;
var 
  Members: TStringList;
  DlgMsg, FamilyExt, CurrentExt, CurrentMemberFile, NotReadOnlyFilter, LabelName, StoredCRC,
  LocalCRC, ZipFile: string;
  FileIsChanged: Boolean;
  I, FamilyID, hFHandle, mbIcon: Integer;
  FileData: TFileStream;
  TimeStamp: Double;
  {$IFDEF IDEDLL}
  FileWasOpen: Boolean;
  {$ENDIF IDEDLL}
  //--- Cipher begin -----------------------------------------------------------
  EncryptModuleData: Boolean;
  EncodeKey: string;
  nAutoExpand : Integer;
  //--- Cipher end -------------------------------------------------------------
begin
  Result := False;
  FamilyID := 0;
  TimeStamp := GetNowUTC;

  // path information available?
  if (ExtractFilePath(ModuleName) = '') then
  begin
    BeepIfSet;
    ErrorMessageBox(Format('%s'+sLineBreak+
                      JVCSRES_No_path_information_available46 + sLineBreak+
                      JVCSRES_JEDI_VCS_cannot_add_or_checkin_the_module_without_path_information46
                    , [ModuleName]
                    ));
    HasErrors := True;
    Exit;
  end; // if not FileExists(ModuleName) then begin

  // file available?
  if not FileExists(ModuleName) then
  begin
    BeepIfSet;
    ErrorMessageBox(Format( JVCSRES_JEDI_VCS_cannot_find_the_file58 + sLineBreak + '<%s>', [ModuleName]));
    HasErrors := True;
    Exit;
  end; // if not FileExists(ModuleName) then begin

  NotReadOnlyFilter := jvcsReadString ( sBaseRegistryKey + crbFilters
                                      , 'Writeable files'
                                      , dfNotReadOnly
                                      );
  //--- Cipher begin -----------------------------------------------------------
  //??? GlobalSettings
  if not SettingIsGlobal(7) then
  begin
    EncryptModuleData := jvcsReadBool ( sBaseRegistryKey + crbOptions
                                      , 'EncryptModuleData'
                                      , False
                                      );
  end
  else
  begin
    EncryptModuleData := GlobalSettingValue(7);
  end;

  if EncryptModuleData then
  begin
    EncodeKey := jvcsReadString(sBaseRegistryKey + crbOptions, 'EncodeKey', '');
    if EncodeKey <> '' then
      EncodeKey := Base64Decode(EncodeKey)
    else
      EncryptModuleData := False;
  end;
  //--- Cipher end -------------------------------------------------------------
  // prepare history, save file etc.
  Screen.Cursor := crHourGlass;
  try
    ArchiveChanged := True;
    {$IFDEF IDEDLL}
    if (not AsChild) then
      if bPJM_Created then 
        bPJM_NeedRefresh := True;
    FileWasOpen := IDEInterface.IsFileOpen(ModuleName);
    if not ((FileGetAttr(ModuleName) and faReadOnly) = faReadOnly) then
      IDEInterface.SaveFile(ModuleName);
    {$ELSE}
    bPJM_NeedRefresh := True;
    {$ENDIF IDEDLL}

    ModuleName := AnsiLowerCase(ModuleName);
    // get all members of the family
    with DataModule1 do
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_FAMILY_EXTENSIONS';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [ExtractFileExt(ModuleName)]);
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

      // File families?
      Screen.Cursor := crHourGlass;
      Members := TStringList.Create;
      try
        Members.Add(ModuleName);
        AffectedFiles := ExtractFileName(ModuleName) + '/';
        AppSrvClient1.Answer.First;
        if not AppSrvClient1.Answer.Eof then
        begin
          FamilyExt := AppSrvClient1.Answer.Fields[0];
          FamilyID := _StrToInt(AppSrvClient1.Answer.Fields[1]);
          if FamilyExt <> '' then 
          begin
            while Pos(';', FamilyExt) > 0 do 
            begin
              CurrentExt := Copy(FamilyExt, 1, Pos(';', FamilyExt) - 1);
              Delete(FamilyExt, 1, Length(CurrentExt) + 1);
              CurrentMemberFile := ChangeFileExt(ModuleName, CurrentExt);
              if FileExists(CurrentMemberFile) then 
              begin
                Members.Add(CurrentMemberFile);
                AffectedFiles :=
                  AffectedFiles + ExtractFileName(CurrentMemberFile) + '/';
              end;
            end; // while Pos(';', FamilyExt) > 0 do begin
          end; // if FamilyExt <> '' then begin
        end; // if not AppSrvClient1.Answer.EoF then begin
        Delete(AffectedFiles, Length(AffectedFiles), 1);

        // file[s] could be opened exclusively?
        for I := 0 to Members.Count - 1 do
        begin
          hFHandle := FileOpen(Members.Strings[I], fmOpenRead or fmShareExclusive);
          if hFHandle = -1 then
          begin
            BeepIfSet;
            ErrorMessageBox(Format( '<%s>' + sLineBreak +
                              JVCSRES_Could_not_open_the_file_as_ShareExclusive46 + sLineBreak +
                              JVCSRES_Probably_the_file_is_locked_by_another_application46
                            , [Members.Strings[I]]
                            ));
            HasErrors := True;
            Exit;
          end
          else
          begin
            FileClose(hFHandle);
          end;
        end; // for I := 0 to Members.Count - 1 do begin
        //@@@ hu 01.07.2003 checked ok

        // just unlock unchanged files => has to check for family files!
        if cbUnlockUnchanged.Checked then
        begin
          FileIsChanged := False;
          if CheckinRevisionID > 0 then
          begin
            // Get all CRC's
            AppSrvClient1.Request.Rewrite;
            AppSrvClient1.FunctionCode := 'GET_REVISION_STATUS';
            AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
            AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
            AppSrvClient1.Request.WriteFields(True, [CheckinRevisionID]);
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
            // FOR all filefamily members
            for I := 0 to Members.Count - 1 do
            begin
              // get stored CRC
              AppSrvClient1.Answer.First;
              StoredCRC := '0';
              while not AppSrvClient1.Answer.Eof do
              begin
                if ExtractFileExt(Members.Strings[I]) =
                  TrimRight(AppSrvClient1.Answer.Fields[10]) then
                begin
                  try
                    StoredCRC := IntToHex(StrToInt(AppSrvClient1.Answer.Fields[8]), 8);
                  except
                    StoredCRC := '0';
                  end;
                  Break;  //thu 01.07.2003
                end; // if ExtractFileExt(CompareFile) =
                AppSrvClient1.Answer.Next;
              end; // while not AppSrvClient1.Answer.EoF do begin

              // IF file changed?
              if (StoredCRC = '0') or (StoredCRC = '00000000') then
              begin
                FileIsChanged := True;  // first checkin
                Break;
              end // if StoredCRC = '0' then begin
              else
              begin
                LocalCRC := IntToHex(CRCInt(Members.Strings[I], DlgMsg), 8);
                if LocalCRC = '00000000' then
                begin
                  FileIsChanged := True;
                  Break;
                end;
                if StoredCRC <> LocalCRC then
                begin
                  FileIsChanged := True;  // file different
                  Break;
                end;
              end; // else if StoredCRC = '0' then begin
            end; // for I := 0 to Members.Count - 1 do begin
          end // if CheckinRevisionID > 0 then begin
          else
          begin
            FileIsChanged := True;
          end;

          // IF file[s] not changed, -> undo checkout
          //@@@ hu 01.07.2003 => CHECK: if only one file changed?
          if not FileIsChanged then
          begin
            // not changed, -> Put?
            if cbPut.Checked then
            begin
              UseRegistry := True;
              DontShowMsgText := JVCSRES_38Don3939t_show_this_message_again_in_the_current_queue;
              DlgMsg := Format( '<%s>' + sLineBreak +
                                JVCSRES_Module_is_unchanged46_Nothing_to_do46
                              , [ModuleName]
                              );
              DSAIdentsMessageDlg ( DlgMsg
                                  , mtInformation
                                  , [mbOK]
                                  , 0
                                  , sBaseRegistryKey + crbMRU + 'Dlgs'
                                  , 'PutMsg'
                                  , idOk
                                  );
              Result := True;
              Screen.Cursor := crDefault;
              Exit;
            end;
            {$IFDEF IDEDLL}
            if (not IsIDEProject(ModuleName, sProjectName)) and
              (not IsIDEPackage(ModuleName)) then
              IDEInterface.CloseFile(ModuleName);
            {$ENDIF IDEDLL}
            // undo check out
            AppSrvClient1.Request.Rewrite;
            AppSrvClient1.FunctionCode := 'UNDO_CHECKOUT_MODULE';
            AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
            AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
            AppSrvClient1.Request.WriteFields(True, [ProjectID]);
            AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
            AppSrvClient1.Request.WriteFields(False, [ModuleID]);
            AppSrvClient1.Request.WriteFields(False, [ExtractFileName(ModuleName)]);
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
              if not DecodeBoolStr(AppSrvClient1.Answer.Fields[0]) then
              begin
                if AppSrvClient1.Answer.Fields[1] <> '' then
                begin
                  DlgMsg := Format( JVCSRES_Module_is_checked_out_by_37s
                                  , [AppSrvClient1.Answer.Fields[1]]
                                  );
                  mbIcon := MB_ICONWARNING;
                  BeepIfSet;
                end
                else
                begin
                  DlgMsg := Format( '<%s> ' + sLineBreak +
                                    JVCSRES_Module_is_unchanged_and_not_checked_out46 + sLineBreak +
                                    JVCSRES_Nothing_to_do46
                                  , [ModuleName]
                                  );
                  mbIcon := MB_ICONINFORMATION;
                end;
                if mbIcon = MB_ICONWARNING then
                begin
                  DlgMsg := DlgMsg + sLineBreak + AppSrvClient1.Answer.Fields[2];
                  MsgOk ( WindowHandle
                        , DlgMsg
                        , cMsgBoxCaption
                        , mbIcon
                        );
                end
                else
                begin
                  UseRegistry := True;
                  DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
                  DSAIdentsMessageDlg ( DlgMsg
                                      , mtInformation
                                      , [mbOK]
                                      , 0
                                      , sBaseRegistryKey + crbMRU + 'Dlgs'
                                      , 'SkipNotCheckedOut'
                                      , idOk
                                      );
                end;
                Screen.Cursor := crDefault;
                Result := (mbIcon = MB_ICONINFORMATION);
                Exit;
              end; // if not DecodeBoolStr(AppSrvClient1.Answer.Fields[0]) then begin
            end; // if not AppSrvClient1.Answer.EoF do begin
            // user message
            UseRegistry := True;
            DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
            DSAIdentsMessageDlg ( Format( '<%s>' + sLineBreak +
                                          JVCSRES_Module_is_unchanged46_Just_unlocked_the_latest_revision46
                                        , [ModuleName]
                                        )
                                , mtInformation
                                , [mbOK]
                                , 0
                                , sBaseRegistryKey + crbMRU + 'Dlgs'
                                , 'SkipUnchanged'
                                , idOk
                                );
            // set readonly?
            for I := 0 to Members.Count - 1 do
            begin
              if not MatchWithFilter(ExtractFileName(Members.Strings[I]), NotReadOnlyFilter) then
                FileSetAttr(Members.Strings[I],
                (FileGetAttr(Members.Strings[I]) or faReadOnly));
            end; // for I := 0 to Members.Count - 1 do begin
            {$IFDEF IDEDLL}
            // reload
            if (not IsIDEProject(ModuleName, sProjectName)) and
              (not IsIDEPackage(ModuleName)) then
            begin
              if FileWasOpen and (not cbAutoClose.Checked) then
              begin
                IDEInterface.OpenFile(GetOriginalFileName(ModuleName));
                BringWindowToTop(WindowHandle);
              end;
            end;
            {$ENDIF IDEDLL}
            if Send_Messages then
            begin
              {  %d|%d|%d|%s|%s|%s|%s 162
                 Nr|PjID|UsrID|UsrName|Time|Res|Msg  }
              SendSecureMail( '*'
                            , sFVCSMailslot
                            , Format( NtfyMsgStr
                                    , [ 2
                                      , ProjectID
                                      , ServerUserID
                                      , sCurrentUser
                                      , LocalDT2GMTStr(Now)
                                      , LocalIPAddr
                                      , Format( JVCSRES_40to58_All41_undo_check_out58_4037d4637d41_37s
                                              , [Version, Revision, ModuleName]
                                              )
                                      ]
                                    )
                            );
            end; // if Send_Messages then begin
            // -- SMTP --
            if Send_SMTP then
              PrepareSMTP ( sCurrentUser
                          , LocalIPAddr
                          , '*All*'
                          , 'FVCS Notify'
                          , ExtractFileName(sProjectName)
                          , Format( JVCSRES_undo_check_out58_4037d4637d41_37s
                                  , [Version, Revision, ModuleName]
                                  )
                          , 5
                          );
            // -- SMTP --
            Result := True;
            Screen.Cursor := crDefault;
            Exit;
          end; // if not FileIsChanged then begin
        end; // if UnlockUnchangedFiles then begin

        {$IFDEF IDEDLL}
        if bMarkSource and FileWasOpen then
        begin
          DlgMsg := sCurrentUser;
          if sCurrentMachine <> '' then
            DlgMsg := DlgMsg + ' on ' + sCurrentMachine;
          IDESourceWriteString(ModuleName, '{ ' + LocalDT2GMTStr(Now) + ' > [' + DlgMsg + '] ' +
            'checked in ' + Comment + ' ' + ' }');
        end; // if bMarkSource and IDEInterface.IsFileOpen(FileName) then begin

        if not ((FileGetAttr(ModuleName) and faReadOnly) = faReadOnly) then
          IDEInterface.SaveFile(ModuleName);
        if (not IsIDEProject(ModuleName, sProjectName)) and
          (not IsIDEPackage(ModuleName)) then
          IDEInterface.CloseFile(ModuleName);
        {$ENDIF IDEDLL}

        Screen.Cursor := crHourGlass;
        // IF KeywordExpansion
        if ExpandKeywords then
        begin
          DlgMsg := lblModule.Caption;
          lblModule.Caption := JVCSRES_Scanning_file_for_keywords464646;
          Application.ProcessMessages;
          for I := 0 to Members.Count - 1 do
          begin
            if LabelID > 0 then
              LabelName := ecbxKeyword.Text
            else
              LabelName := '';
            if MatchWithFilter(Members.Strings[I], KWExpandFilter) then
              ExpanseKeywords(Application, WindowHandle, kwexCheckIn,
                Members.Strings[I], sCurrentUser, Comment, LabelName, Version,
                Revision, ModuleID, 0);
          end; // for I := 0 to Members.Count - 1 do begin
          lblModule.Caption := DlgMsg;
          Application.ProcessMessages;
        end; // if ExpandKeywords then begin

        // prepare request
        AppSrvClient1.Request.Rewrite;
        AppSrvClient1.FunctionCode := 'CHECKIN_MODULE';
        AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
        AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
        AppSrvClient1.Request.WriteFields(False, [cbPut.Checked]);

        for I := 0 to Members.Count - 1 do
        begin
          // Project ID
          AppSrvClient1.Request.WriteFields(True, [ProjectID]); //0
          // User ID
          AppSrvClient1.Request.WriteFields(False, [ServerUserID]); //1
          // Module ID
          AppSrvClient1.Request.WriteFields(False, [ModuleID]); //2
          // Label ID
          AppSrvClient1.Request.WriteFields(False, [LabelID]); //3
          // Old revision ID
          AppSrvClient1.Request.WriteFields(False, [0]); //4
          // Version
          AppSrvClient1.Request.WriteFields(False, [Version]); //5
          // Revision
          AppSrvClient1.Request.WriteFields(False, [Revision]); //6
          // orig. time

          //??? GlobalSettings
          if not SettingIsGlobal(3) then 
          begin
            if (jvcsReadInteger(sBaseRegistryKey + crbOptions, 'ChkInDate', 0) = 0) then
              TimeStamp := FileGetUTCDateTime(Members.Strings[I])
            else
              TimeStamp := GetNowUTC;
          end 
          else 
          begin
            if GlobalSettingValue(3) then
              TimeStamp := GetNowUTC
            else
              TimeStamp := FileGetUTCDateTime(Members.Strings[I]);
          end;

          AppSrvClient1.Request.WriteFields(False, [TimeStamp]); //7
          // orig size
          AppSrvClient1.Request.WriteFields(False, [_GetFileSize(Members.Strings[I])]); //8
          // orig. crc
          try
            AppSrvClient1.Request.WriteFields(False, [CRCInt(Members.Strings[I], DlgMsg)]);
            //9
          except
            on E:
            Exception do
            begin
              BeepIfSet;
              MsgError( WindowHandle
                      , Format( JVCSRES_Calculating_CRC_checksum_for_6037s62 + sLineBreak +
                                JVCSRES_raised_exception58 + sLineBreak + '%s'
                              , [Members.Strings[I], E.Message]
                              )
                      , cMsgBoxCaption
                      );
              Screen.Cursor := crDefault;
              HasErrors := True;
              Exit;
            end;
          end;
          // remove RO attrib before checking in
          FileSetAttr(Members.Strings[I], (FileGetAttr(Members.Strings[I]) and not faReadOnly));

          // compress file
          if SetupZipFile(Members.Strings[I], ZipFile, DlgMsg) then
          begin
            //--- Cipher begin -------------------------------------------------
            if EncryptModuleData then
            begin
              if not BlowFishEncode(Self, EncodeKey, ZipFile,
                ChangeFileExt(ZipFile, '.bflck')) then
              begin
                BeepIfSet;
                ErrorMessageBox(Format( '<%s>' + sLineBreak +
                                  JVCSRES_JEDI_VCS_cannot_check_in_this_file46 + sLineBreak +
                                  JVCSRES_Exception58_37s46 + sLineBreak +
                                  JVCSRES_Access_denied_in_object_9137s9346
                                , [ ZipFile
                                  , JVCSRES_Blowfisch_encode_failed
                                  , 'ENCRYPT'
                                  ]
                                ));
                Screen.Cursor := crDefault;
                HasErrors := True;
                Exit;
              end
              else
              begin
                SysUtils.DeleteFile(ZipFile);
                ZipFile := ChangeFileExt(ZipFile, '.bflck');
              end;
            end;
            //--- Cipher end ---------------------------------------------------
            //push AutoExpand value
            nAutoExpand := AppSrvClient1.Request.AutoExpand;
            try
              FileData := TFileStream.Create(ZipFile, fmOpenRead + fmShareDenyNone);
              try
                FileData.Seek(0, 0);
                //#3211 adjust AutoExpand for blob transfer to avoid overhead of
                //             working with memory chunks. Added min buffer size
                AppSrvClient1.Request.AutoExpand := FileData.Size + (FileData.Size div 4) + 256;
                // compr. size
                AppSrvClient1.Request.WriteFields(False, [_GetFileSize(ZipFile)]); //10
                // extension
                AppSrvClient1.Request.WriteFields(False, [ExtractFileExt(Members.Strings[I])]);
                //11
                // binary
                AppSrvClient1.Request.WriteStreamField(False, mwBlob, FileData); //12
              finally
                FileData.Free;
              end;
            except
              on E:
              Exception do
              begin
                BeepIfSet;
                MsgError( WindowHandle
                        , Format( '<%s>' + sLineBreak +
                                  JVCSRES_BLOB_transfer_into_request_stream_raised_exception58 + sLineBreak +
                                  '%s.'
                                , [Members.Strings[I], E.Message]
                                )
                        , cMsgBoxCaption
                        );
                Screen.Cursor := crDefault;
                HasErrors := True;
                Exit;
              end;
            end; // try except
            //restore org. AutoExpand value
            AppSrvClient1.Request.AutoExpand :=  nAutoExpand;

            if FileExists(ZipFile) then
              SysUtils.DeleteFile(ZipFile);
          end // if SetupZipFile(Members.Strings[I]
          else
          begin
            BeepIfSet;
            MsgError( WindowHandle
                    , DlgMsg
                    , cMsgBoxCaption
                    );
            HasErrors := True;
            Exit;
          end; // else if SetupZipFile(Members.Strings[I]
          // comment
          //GlobalSetting for IncludeIPComment not set so we use lokal value
          if not SettingIsGlobal(14) then
          begin
            if jvcsReadBool(sBaseRegistryKey + crbOptions, 'IncludeIPComment', False)
            then
              Comment := Comment + sLineBreak + Format(JVCSRES_Checked_in_from_37s_41, [LocalIPAddr]);
          end
          else
          if GlobalSettingValue(14) then
            Comment := Comment + sLineBreak + Format(JVCSRES_Checked_in_from_37s_41, [LocalIPAddr]);

          if EncryptModuleData then
            Comment := Comment + JVCSRES__45_33Encrypted33;
          AppSrvClient1.Request.WriteFields(False, [Comment]); //13
          // ide version
          {$IFDEF IDEDLL}
          AppSrvClient1.Request.WriteFields(False, [400]); //14
          {$ELSE}
          AppSrvClient1.Request.WriteFields(False, [100]); //14
          {$ENDIF IDEDLL}
          // module name
          AppSrvClient1.Request.WriteFields(False, [Members.Strings[I]]); //15
          // family id
          AppSrvClient1.Request.WriteFields(False, [FamilyID]); //16
        end; // for I := 0 to Members.Count - 1 do begin
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
        if not DecodeBoolStr(AppSrvClient1.Answer.Fields[0]) then
        begin
          BeepIfSet;
          ErrorMessageBox(Format( '<%s>' + sLineBreak +
                            JVCSRES_JEDI_VCS_cannot_check_in_this_file46 + sLineBreak +
                            JVCSRES_Exception58_37s46 + sLineBreak +
                            JVCSRES_Access_denied_in_object_9137s9346
                          , [ ModuleName
                            , AppSrvClient1.Answer.Fields[1]
                            , 'CHECKIN_MODULE'
                            ]
                          ));
          HasErrors := True;
          Exit;
        end // if not DecodeBoolStr(...
        else
        begin
          // set readonly?
          for I := 0 to Members.Count - 1 do
          begin
            // orig. time ?
            if jvcsReadInteger(sBaseRegistryKey + crbOptions, 'ChkInDate', 0) <> 0 then
            begin
              hFHandle :=
                FileOpen(Members.Strings[I], fmOpenWrite or fmShareDenyNone);
              if hFHandle <> -1 then 
              begin
                FileSetDate(hFHandle, DateTimeToFileDate(TimeStamp));
                FileClose(hFHandle);
              end;
            end; // if RegReadInteger
            if (not cbPut.Checked) and
              (not MatchWithFilter(Members.Strings[I], NotReadOnlyFilter)) then
              FileSetAttr(Members.Strings[I],
              (FileGetAttr(Members.Strings[I]) or faReadOnly));
          end; // for I := 0 to Members.Count - 1 do begin
          {$IFDEF IDEDLL}
          // reload
          if (not IsIDEProject(ModuleName, sProjectName)) and
            (not IsIDEPackage(ModuleName)) then 
          begin
            if FileWasOpen and (not cbAutoClose.Checked) then 
            begin
              IDEInterface.OpenFile(GetOriginalFileName(ModuleName));
              BringWindowToTop(WindowHandle);
            end;
          end;
          {$ENDIF IDEDLL}
          if Send_Messages or Send_SMTP then 
          begin
            {  %d|%d|%d|%s|%s|%s|%s 162
               Nr|PjID|UsrID|UsrName|Time|Res|Msg  }
            if cbPut.Checked then 
            begin
              if Send_Messages then
                SendSecureMail( '*'
                              , sFVCSMailslot
                              , Format( NtfyMsgStr
                                      , [ 2
                                        , ProjectID
                                        , ServerUserID
                                        , sCurrentUser
                                        , LocalDT2GMTStr(Now)
                                        , LocalIPAddr
                                        , Format( JVCSRES_40to58_All41_checked_in58_4037d4637d41_37s
                                                , [Version, Revision, ModuleName]
                                                )
                                        ]
                                      )
                              );
              // -- SMTP --
              if Send_SMTP then
                if jvcsReadBool(sBaseRegistryKey + crbOptions, 'SMTPMessages', False) then
                  PrepareSMTP ( sCurrentUser
                              , LocalIPAddr
                              , '*All*'
                              , 'FVCS Notify'
                              , ExtractFileName(sProjectName)
                              , Format( JVCSRES_checked_in58_4037d4637d41_37s
                                      , [Version, Revision, ModuleName]
                                      )
                              , 3
                              );
              // -- SMTP --
            end
            else
            begin
              if Send_Messages then
                SendSecureMail( '*'
                              , sFVCSMailslot
                              , Format( NtfyMsgStr
                                      , [ 2
                                        , ProjectID
                                        , ServerUserID
                                        , sCurrentUser
                                        , LocalDT2GMTStr(Now)
                                        , LocalIPAddr
                                        , Format( JVCSRES_40to58_All41_updated_40Put4158_4037d4637d41_37s
                                                , [Version, Revision, ModuleName]
                                                )
                                        ]
                                      )
                              );
              // -- SMTP --
              if Send_SMTP then
                if jvcsReadBool(sBaseRegistryKey + crbOptions, 'SMTPMessages', False) then
                  PrepareSMTP ( sCurrentUser
                              , LocalIPAddr
                              , '*All*'
                              , 'FVCS Notify'
                              , ExtractFileName(sProjectName)
                              , Format( JVCSRES_updated_40Put4158_4037d4637d41_37s
                                      , [Version, Revision, ModuleName]
                                      )
                              , 6
                              );
              // -- SMTP --
            end;
          end; // if Send_Messages then begin
        end; // else if not DecodeBoolStr(...
      finally
        Members.Free;
      end;
    end; // with DataModule1 do begin}
    Result := True;
  finally
    Screen.Cursor := crDefault;
  end;
end;

//------------------------------------------------------------------------------

function TVCSChkInSingle.SetupZipFile(const SourceFile: string;
  var ZipFile: string;
  var ErrMsg: string): Boolean;
begin
  ErrMsg := '';
  result := JVCSCompressFile(SourceFile, ZipFile);
  if not result then
  begin
    ErrMsg := Format( JVCSRES_File_6037s62 + sLineBreak +
                      JVCSRES_could_not_be_added_to_temporary_Zip_file + sLineBreak +
                      '<%s>.'
                    , [SourceFile, ZipFile]
                    );
    HasErrors := True;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSChkInSingle.btnCancelClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSChkInSingle.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  jvcsWriteWindowPosAndSize(sBaseRegistryKey + crbWindows, 'CheckIn',
    Top, Left, Width, Height);

  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'CheckIn_OneComment',
    cbAll.Checked);
  {$IFDEF IDEDLL}
  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'CheckIn_CloseFiles',
    cbAutoClose.Checked);
  {$ENDIF IDEDLL}
  jvcsWriteBool(sBaseRegistryKey + crbOptions, 'UnlockUnchangedFiles',
    cbUnlockUnchanged.Checked);

//  Zip Master1.Unload_Zip_Dll;
  // Aktuelles Verzeichnis wiederherstellen
  ChDir(ActDir);
end;

//------------------------------------------------------------------------------

procedure TVCSChkInSingle.FormDestroy(Sender: TObject);
begin
  SelectModuleList.Free;
  FLastCommentHandler.Free;
  FCurrentModuleFileNames.Free;
end;

//------------------------------------------------------------------------------

procedure TVCSChkInSingle.RestrictSize(var Msg: TMessage);
var
  P: PMinMaxInfo;
begin
  P := PMinMaxInfo(Msg.lParam);
  P.ptMaxSize.X := trResDesktop.Right;
  P.ptMaxSize.Y := trResDesktop.Bottom;
  P.ptMaxPosition.X := 0;
  P.ptMaxPosition.Y := 0;
  P.ptMinTrackSize.X := MulDiv(340, PixelsPerInch, 96);
  P.ptMinTrackSize.Y := MulDiv(275, PixelsPerInch, 96);
end;

//------------------------------------------------------------------------------

procedure TVCSChkInSingle.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then 
  begin
    btnCancel.Click;
    Key := 0;
  end;
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_CheckInOut_In);
  // Default short-cut is also for localized version CTRL-L
  //@@@ToDo later: at the moment hard coded to CTRL-L, CTRL-T, if option
  //               for shortcut exist, change...
  if (Shift * [ssShift, ssAlt, ssCtrl] = [ssCtrl]) and (Chr(Key) in ['L', 'l']) then
    if (not CtrlSCDisabled(WindowHandle)) then
      btnGeLlMemoClick(self);
  if (Shift * [ssShift, ssAlt, ssCtrl] = [ssCtrl]) and (Chr(Key) in ['T', 't']) then
    if (not CtrlSCDisabled(WindowHandle)) then
      btnGetFromToDoClick(self);
end;

//------------------------------------------------------------------------------

procedure TVCSChkInSingle.btnGeLlMemoClick(Sender: TObject);
var 
  LastComment: string;
begin
  LastComment := jvcsReadString(sBaseRegistryKey + crbMRU, 'ChkInComment', '');
  if LastComment <> '' then
  begin
    meComment.Text := LastComment;
    meComment.SetFocus;
    meComment.SelStart := Length(meComment.Text);
  end 
  else
    MsgInfo ( WindowHandle
            , Format( JVCSRES_MRU_item_6037s62_is_blank46
                    , [JVCSRES_Last_Check_In_Comment]
                    )
            , cMsgBoxCaption
            );
end;

//------------------------------------------------------------------------------

procedure TVCSChkInSingle.btnGetFromToDoClick(Sender: TObject);
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
    AppSrvClient1.Request.WriteFields(False, [CheckinProjectID]);
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
      //@@@ToDo list contains no entries associated with this project. 80
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

procedure TVCSChkInSingle.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSChkInSingle.spBtnUndoClick(Sender: TObject);
begin
  meComment.Perform(EM_UNDO, 0, 0);
end;

procedure TVCSChkInSingle.UpdateDiffButtons;
var
  I: Integer;
  AdditionalFiles: TStringList;
  ModuleName, Diff3To5Hint: string;
  DiffActionItems: TList;
begin
  spbtnDiff1.Enabled := (CheckinRevisionID > 0) and spBtnCompare.Enabled;
  ModuleName := CheckinModuleName;
  if spbtnDiff1.Enabled and (ModuleName <> '') then
  begin
    FCurrentModuleFileNames.Clear;
    FCurrentModuleFileNames.AddObject(ModuleName, spbtnDiff1);
    spbtnDiff1.Hint := Format('Diff (%s)', [ExtractFileExt(ModuleName)]);
    DiffActionItems := TList.Create;
    AdditionalFiles := TStringList.Create;
    try
      DiffActionItems.Add(spbtnDiff1);
      DiffActionItems.Add(spbtnDiff2);
      DiffActionItems.Add(mnDiff3);
      DiffActionItems.Add(mnDiff4);
      DiffActionItems.Add(mnDiff5);
      GetAdditionalFilesFromFileFamily(ModuleName, AdditionalFiles);
      for I := 0 to Pred(AdditionalFiles.Count) do
        FCurrentModuleFileNames.Add(AdditionalFiles[I]);
      Diff3To5Hint := '';
      for I := 1 to Pred(DiffActionItems.Count) do
      begin
        if TObject(DiffActionItems[I]) is TSpeedButton then
        begin
          TSpeedButton(DiffActionItems[I]).Visible := FCurrentModuleFileNames.Count > I;
          if FCurrentModuleFileNames.Count > I then
          begin
            FCurrentModuleFileNames.Objects[I] := DiffActionItems[I];
            if I < 2 then
              TSpeedButton(DiffActionItems[I]).Hint := Format('Diff (%s)', [ExtractFileExt(FCurrentModuleFileNames[I])])
            else
              TSpeedButton(DiffActionItems[I]).Hint := ExtractFileExt(FCurrentModuleFileNames[I]);
          end;
        end
        else
        if TObject(DiffActionItems[I]) is TMenuItem then
        begin
          TMenuItem(DiffActionItems[I]).Visible := FCurrentModuleFileNames.Count > I;
          if FCurrentModuleFileNames.Count > I then
          begin
            FCurrentModuleFileNames.Objects[I] := DiffActionItems[I];
            if I < 2 then
              TMenuItem(DiffActionItems[I]).Caption := Format('Diff (%s)', [ExtractFileExt(FCurrentModuleFileNames[I])])
            else
              TMenuItem(DiffActionItems[I]).Caption := ExtractFileExt(FCurrentModuleFileNames[I]);
          end;
        end;
        if (I > 1) and (FCurrentModuleFileNames.Count > I) then
        begin
          if Diff3To5Hint <> '' then
            Diff3To5Hint := Diff3To5Hint + ', ';
          Diff3To5Hint := Diff3To5Hint + ExtractFileExt(FCurrentModuleFileNames[I]);          
        end;
      end;
      spbtnDiff3To5.Visible := AdditionalFiles.Count > 1;
      spbtnDiff3To5.Hint := Format('Diff (%s)', [Diff3To5Hint]);
    finally
      AdditionalFiles.Free;
      DiffActionItems.Free;
    end;
  end
  else
  begin
    spbtnDiff1.Hint := 'Diff';
    spbtnDiff2.Visible := False;
    spbtnDiff3To5.Visible := False;
    FCurrentModuleFileNames.Clear;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSChkInSingle.cbPutClick(Sender: TObject);
begin
  if cbPut.Checked then
    btnOK.Caption := JVCSRES_38Put
  else
    btnOK.Caption := JVCSRES_Check_38In;
  cbUnlockUnchanged.Enabled := not cbPut.Checked;
end;

//------------------------------------------------------------------------------

procedure TVCSChkInSingle.cbUnlockUnchangedClick(Sender: TObject);
begin
  if SettingIsGlobal(13) and (cbUnlockUnchanged.Checked <> GlobalSettingValue(13)) then 
  begin
    ShowGlobalSettingsWarning(WindowHandle, GlobalSettingValue(13));
    cbUnlockUnchanged.Checked := GlobalSettingValue(13);
    Exit;
  end;
end;

procedure TVCSChkInSingle.spBtnCompareClick(Sender: TObject);
begin
  DoModuleCompare(CheckinModuleName);
end;

procedure TVCSChkInSingle.spbtnDiff1Click(Sender: TObject);
var
  I, SelectedModuleID: Integer;
  SelectedModuleFileName, Extension: string;
begin
  SelectedModuleID := CheckinModuleID;
  SelectedModuleFileName := CheckinModuleName;
  if (SelectedModuleID > 0) and (SelectedModuleFileName <> '') and
    (FCurrentModuleFileNames.Count > 0) and (FCurrentModuleFileNames[0] = SelectedModuleFileName) then
  begin
    Extension := '';
    for I := 0 to Pred(FCurrentModuleFileNames.Count) do
      if Sender = FCurrentModuleFileNames.Objects[I] then
      begin
        Extension := ExtractFileExt(FCurrentModuleFileNames[I]);
        Break;
      end;
    if Extension <> '' then
      ShowCompressDiffDialogLocalToLatest(ChangeFileExt(SelectedModuleFileName, Extension), Extension,
        SelectedModuleID, CheckinRevisionID);
  end;
end;

end.

