(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: MergeVersion.pas

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
2003/08/30  MGosselink- mantis #1108: Move an already assigned label to another
                        revision of the same module
2003/12/28  USchuster - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use constant)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/26  USchuster - style cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/11/02  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
2004/12/27  USchuster - COPY_REVISION or MERGE_VER_REV_NR won't be called if the
                        module has still new version.revision (mantis #1284)
                      - bugfix in GetVersionMembers (I doubt that "Merge from one version"
                        worked with JEDI VCS/FreeVCS yet)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC2 was released ^^^^^^^^^^^^^^^^^^^^^^^^^
2005/05/22  THuber    - #2913 DSA message for current stamp queue
2007/06/30  USchuster - changes for large fonts (contraints and default size depend now on PixelsPerInch; analog to Mantis #3710)
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit MergeVersion;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, Menus, ImgList, ExtCtrls, RFormat, Buttons, JVCSForms;

type
  TVCSMerge = class(TJVCSForm)
    PopupMenu1: TPopupMenu;
    StateImageList: TImageList;
    SysImageList: TImageList;
    MergeBuffer: TMWBuffer;
    Panel3: TPanel;
    btnClose: TButton;
    cbInclHidden: TCheckBox;
    Panel1: TPanel;
    rbAllVersion: TRadioButton;
    lvMergeItems: TListView;
    Panel2: TPanel;
    Label3: TLabel;
    Label1: TLabel;
    Label4: TLabel;
    edFromVer: TEdit;
    updwnSource: TUpDown;
    edToVer: TEdit;
    edToRev: TEdit;
    updwnTargetRev: TUpDown;
    updwnTarget: TUpDown;
    btnMerge: TButton;
    SelectAll1: TMenuItem;
    UnselectAll1: TMenuItem;
    GroupBox1: TGroupBox;
    cbLabels: TComboBox;
    spBtnLabelMan: TSpeedButton;
    btnStamp: TButton;
    rb1Version: TRadioButton;
    Help: TSpeedButton;
    cbJustChangeNr: TCheckBox;
    Label2: TLabel;
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnMergeClick(Sender: TObject);
    procedure HelpTopic1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure rbAllVersionClick(Sender: TObject);
    procedure btnStampClick(Sender: TObject);
    procedure lvMergeItemsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edToVerChange(Sender: TObject);
    procedure cbInclHiddenClick(Sender: TObject);
    procedure spBtnLabelManClick(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);
    procedure UnselectAll1Click(Sender: TObject);
    procedure lvMergeItemsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure HelpClick(Sender: TObject);
    procedure cbLabelsChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private-Deklarationen }
    FCreated,
    Send_Messages: Boolean;
    MinVersion,
    MinRevision: Integer;
    LabelIDs: TStringList;
    function Mergef1Version: Boolean;
    function MergefAllVersion: Boolean;
    procedure FindMergeModules;
    procedure GetVersionMembers;
    procedure GetArchiveLabels;
    procedure EnableControls(const Enable: Boolean);
  public
    { Public-Deklarationen }
  end;

var
  VCSMerge: TVCSMerge;

implementation

uses
    ShellAPI
  {$IFDEF DEBUG}
  , JclDebug
  {$ENDIF DEBUG}
  {$IFDEF IDEDLL}
  , VerSet
  {$ENDIF IDEDLL}
  {$IFDEF LANGUAGE}
  , JvGnugettext
  {$ENDIF LANGUAGE}
  , Progress
  , VCSProcBase
  , TZHandling
  , VCSBase
  , DBModule
  , CommCtrl
  , JVCSDialogs
  , MaintainLabels
  , Std_ListView
  , ConfigStorage
  , JVCSGUIClientResources
  ;

{$R *.dfm}

//------------------------------------------------------------------------------
procedure TVCSMerge.FormCreate(Sender: TObject);
var
  sfi: TSHFileInfo;
  ToolTipHandle: HWND;
  DlgTop,
  DlgLeft,
  DlgWidth,
  DlgHeight: Integer;
begin
  try
    Constraints.MinHeight := MulDiv(315, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(410, PixelsPerInch, 96);
    VCSProgress := nil;
    // ListView Tooltips
    SendMessage(lvMergeItems.Handle, LVM_SETEXTENDEDLISTVIEWSTYLE, LVS_EX_INFOTIP,
      LVS_EX_INFOTIP);
    ToolTipHandle := SendMessage(lvMergeItems.Handle, LVM_GETTOOLTIPS, 0, 0);
    SendMessage(ToolTipHandle, TTM_SETDELAYTIME, TTDT_AUTOMATIC, 1);
    SendMessage(ToolTipHandle, TTM_SETDELAYTIME, TTDT_AUTOPOP, 3000);

    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    if not jvcsReadWindowPosAndSize(sBaseRegistryKey + crbWindows, 'MergeVersion',
      DlgTop, DlgLeft, DlgWidth, DlgHeight) then
    begin
      DlgTop := (Screen.Height - Height) div 2;
      DlgLeft := (Screen.Width - Width) div 2;
      DlgWidth := MulDiv(410, PixelsPerInch, 96);
      DlgHeight := MulDiv(315, PixelsPerInch, 96);
    end;
    Top := DlgTop;
    Left := DlgLeft;
    Width := DlgWidth;
    Height := DlgHeight;

    cbInclHidden.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbWindows, 'Merge_IncludeHidden', False);

    //??? GlobalSettings
    if not SettingIsGlobal(16) then
      Send_Messages :=
        jvcsReadBool(sBaseRegistryKey + crbOptions, 'NotifyActive', False) and
        jvcsReadBool(sBaseRegistryKey + crbOptions, 'MessExclusive', False)
    else
      Send_Messages := GlobalSettingValue(16);

    {$IFDEF CUSTOMDRIVE}
    sDriveSubst := RegReadString(HKCU, sBaseRegistryKey + crbProjects +
      ExtractFileName(sProjectName), 'LocalDrive', '');
    if (sDriveSubst = '') then
      sDriveSubst := RegReadString(HKCU, sBaseRegistryKey + crbOptions,
        'LocalDrive', '');
    {$ENDIF CUSTOMDRIVE}


    //Systemsymbole in eine TImageList-Komponente einlesen
    SysImageList.Handle := SHGetFileInfo('', 0, sfi, SizeOf(TSHFileInfo),
      SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
    SysImageList.ShareImages := True;
    {$IFNDEF SHOWIDS}
    lvMergeItems.Columns[3].Width := 0;
    lvMergeItems.Columns[4].Width := 0;
    {$ENDIF ~SHOWIDS}
    Screen.Cursors[cPopUpMCursor] := LoadCursor(hInstance, PChar('CURSORRM'));
    lvMergeItems.Cursor := cPopUpMCursor;
    LabelIDs := TStringList.Create;

    FCreated := False;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSMerge.FormActivate(Sender: TObject);
begin
  if Assigned(VCSProgress) then
    SetForeGroundWindow(VCSProgress.Handle);
  if FCreated then 
    Exit;
  FCreated := True;
  EnableControls(False);
  Application.ProcessMessages;
  GetArchiveLabels;
  FindMergeModules;
  rbAllVersion.Checked := True;
  EnableControls(True);
end;

//------------------------------------------------------------------------------

procedure TVCSMerge.FindMergeModules;
var 
  ModuleID, CurrentVersion, CurrentRevision: Integer;
  CurrentFile, CurrentFileBase, CurrentPath: string;
  FExists: Boolean;
  LVItem: TListItem;
  sfi: TSHFileInfo;
begin
  Caption := Format(JVCSRES_VCS_Merge_Query_45_37s,
    [AnsiLowerCase(ExtractFileName(sProjectName))]);

  with DataModule1 do 
  begin
    //--- get revisions --------------------------------------------------------
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_LATEST_REVISIONS';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [ServerProjectID]);
    AppSrvClient1.Request.WriteFields(False, [not cbInclHidden.Checked]);
    AppSrvClient1.Request.WriteFields(False, [0]); // LabelID = 0
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

    lvMergeItems.Items.BeginUpDate;
    try
      lvMergeItems.Items.Clear;
      MinVersion := -1;
      MinRevision := -1;
      AppSrvClient1.Answer.First;
      while not AppSrvClient1.Answer.Eof do 
      begin
        ModuleID := _StrToInt(AppSrvClient1.Answer.Fields[0]);
        CurrentFileBase := AppSrvClient1.Answer.Fields[1];
        {$IFDEF CUSTOMDRIVE}
        CurrentPath := ChangeDriveName(AppSrvClient1.Answer.Fields[2], sDriveSubst);
        {$ELSE}
        CurrentPath := AppSrvClient1.Answer.Fields[2];
        {$ENDIF CUSTOMDRIVE}

        // calculate min ver/rev
        CurrentVersion := _StrToInt(AppSrvClient1.Answer.Fields[4]);
        CurrentRevision := _StrToInt(AppSrvClient1.Answer.Fields[5]);
        if CurrentVersion > MinVersion then 
        begin
          MinVersion := CurrentVersion;
          MinRevision := -1;
        end;
        if CurrentVersion = MinVersion then
          if CurrentRevision > MinRevision then 
            MinRevision := CurrentRevision;

        while (not AppSrvClient1.Answer.Eof) and
          (ModuleID = _StrToInt(AppSrvClient1.Answer.Fields[0])) do 
        begin
          CurrentFile :=
            ChangeFileExt(CurrentFileBase, TrimRight(AppSrvClient1.Answer.Fields[7]));
          // Parent?
          if CurrentFile = CurrentFileBase then
          begin
            FExists := FileExists(CurrentPath + CurrentFile);
            // NewItem
            LVItem := lvMergeItems.Items.Add;
            // File
            if FExists then
              LVItem.Caption := ExtractFileName(GetOriginalFileName(CurrentPath +
                CurrentFile))
            else
              LVItem.Caption := CurrentFile;
            // Parent file ?
            LVItem.StateIndex := 0;
            // FileIcon
            if FExists then 
            begin
              SHGetFileInfo(PChar(CurrentPath + CurrentFile), 0, sfi, SizeOf(sfi),
                SHGFI_SYSICONINDEX or SHGFI_SMALLICON or SHGFI_DISPLAYNAME);
              LVItem.ImageIndex := sfi.IIcon;
            end 
            else 
              LVItem.ImageIndex := -1;
            // Version
            LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[4] + '.' +
              AppSrvClient1.Answer.Fields[5]);
            // Date
            LVItem.SubItems.Add(DateTimeToStr(GMTStr2LocalDateTime(AppSrvClient1.Answer.Fields[6])));
            // Module ID
            LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[0]);
            // Revision ID
            LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[3]);
          end; // if CurrentFile = CurrentFileBase then begin
          AppSrvClient1.Answer.Next;
        end; // while (not Answer.EoF) and....
      end; // while not AppSrvClient1.Answer.EoF do begin
    finally
      lvMergeItems.Items.EndUpDate;
    end;
  end; // with DataModule1 do begin

  updwnSource.Min := 0;
  updwnSource.Position := 0;
  updwnTarget.Min := MinVersion;
  updwnTarget.Position := MinVersion;
  updwnTargetRev.Min := MinRevision;
  updwnTargetRev.Position := MinRevision;

  Caption := Format(JVCSRES_VCS_Merge_45_37s, [AnsiLowerCase(ExtractFileName(sProjectName))]);
end;

//------------------------------------------------------------------------------

procedure TVCSMerge.EnableControls(const Enable: Boolean);
begin
  btnMerge.Enabled := Enable;
  btnStamp.Enabled := Enable and (cbLabels.Text <> '');
  btnClose.Enabled := Enable;
end;

//------------------------------------------------------------------------------

procedure TVCSMerge.btnMergeClick(Sender: TObject);
var 
  ResultString: string;
  CanMerge: Boolean;
begin
  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_LOCKED_MODULES';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [ServerProjectID]);
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
    CanMerge := AppSrvClient1.Answer.Eof;
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
  if not CanMerge then
  begin
    MessageBox(WindowHandle, PChar(Format(JVCSRES_You_cannot_37s_while_modules_are_checked_out46 + #13#10 +
      JVCSRES_Check_in_all_modules_and_retry46, [JVCSRES_merge])), cMsgBoxCaption,
      MB_OK or MB_ICONINFORMATION);
    btnMerge.Enabled := False;

    VCSStdListView := TVCSStdListView.Create(Application);
    try
      VCSStdListView.LVRepID := 8;
      VCSStdListView.Caption := JVCSRES_Locked_modules;
      VCSStdListView.Left := Left + 60;
      VCSStdListView.Top := Top + 60;
      VCSStdListView.LVType := 0;
      VCSStdListView.HelpContextID := IDH_Merge;
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

  if rb1Version.Checked and (updwnSource.Position > updwnTarget.Position) then
  begin
    BeepIfSet;
    MessageBox(WindowHandle, PChar(Format(JVCSRES_Cannot_merge_from_version_6037d62_to_6037d6246 + #13#10 +
      JVCSRES_Target_version_must_be_higher_than_source_version46, [updwnSource.Position,
      updwnTarget.Position])), cMsgBoxCaption, MB_OK or MB_ICONWARNING);
    Exit;
  end;
  if MessageBox(WindowHandle,
    PChar(Format(JVCSRES_Are_you_sure_you_want_to_create_a_complete_new_version_4037d4637d41_of_the_application63,
      [updwnTarget.Position, updwnTargetRev.Position])),
    cMsgBoxCaption, MB_YESNOCANCEL or MB_ICONQUESTION) <> idYes then 
    Exit;

  EnableControls(False);
  Screen.Cursor := crHourGlass;
  if rbAllVersion.Checked then
    MergefAllVersion
  else 
    Mergef1Version;
  FindMergeModules;
  {$IFDEF IDEDLL}
  // Version Info Resource
  SaveProjectFileInfo(sProjectName, updwnTarget.Position, 0, - 1, - 1, - 1);
  {$ENDIF IDEDLL}
  Screen.Cursor := crDefault;
  EnableControls(True);
end;

//------------------------------------------------------------------------------

procedure TVCSMerge.GetVersionMembers;
var 
  I: Integer;
begin
  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_REVISION_LIST_BY_VERSION';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [ServerProjectID]);
    AppSrvClient1.Request.WriteFields(False, [updwnSource.Position]); // Version
    AppSrvClient1.Request.WriteFields(False, [-1]); // Revision
    AppSrvClient1.Request.WriteFields(False, [not cbInclHidden.Checked]);
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

    MergeBuffer.Rewrite;
    AppSrvClient1.Answer.First;
    while not AppSrvClient1.Answer.Eof do
    begin
      for I := 0 to AppSrvClient1.Answer.FieldCount - 1 do
        MergeBuffer.WriteFields(I = 0, [AppSrvClient1.Answer.Fields[I]]);
      AppSrvClient1.Answer.Next;
    end;
  end; // with DataModule1 do begin
end;

//------------------------------------------------------------------------------

function TVCSMerge.Mergef1Version: Boolean;
var 
  I: Integer;
  Mess: string;
begin
  Result := False;
  GetVersionMembers;

  // Merge
  VCSProgress := TVCSProgress.Create(Self);
  try
    VCSProgress.SetText(JVCSRES_Merge_new_version464646);
    VCSProgress.SetPBMax(MergeBuffer.RecordCount);
    VCSProgress.SetPBPos(0);
    VCSProgress.Left := Left + 20;
    VCSProgress.Top := Top + 20;
    VCSProgress.Show;
    Application.ProcessMessages;

    I := 0;
    MergeBuffer.First;
    while not MergeBuffer.Eof do 
    begin
      if (StrToIntDef(MergeBuffer.Fields[6], -1) <> updwnTarget.Position) or
        (StrToIntDef(MergeBuffer.Fields[7], -1) <> updwnTargetRev.Position) then
        with DataModule1 do
        begin
          AppSrvClient1.Request.Rewrite;
          if cbJustChangeNr.Checked then
            AppSrvClient1.FunctionCode := 'MERGE_VER_REV_NR'
          else
            AppSrvClient1.FunctionCode := 'COPY_REVISION';
          AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
          AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
          AppSrvClient1.Request.WriteFields(True, [ServerProjectID]);
          AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
          // Module ID
          AppSrvClient1.Request.WriteFields(False, [MergeBuffer.Fields[0]]);
          // Source Revision ID
          AppSrvClient1.Request.WriteFields(False, [MergeBuffer.Fields[5]]);
          // Version
          AppSrvClient1.Request.WriteFields(False, [updwnTarget.Position]);
          // Revision
          AppSrvClient1.Request.WriteFields(False, [updwnTargetRev.Position]);
          // Module
          AppSrvClient1.Request.WriteFields(False, [MergeBuffer.Fields[1]]);
          // IDE Version
          AppSrvClient1.Request.WriteFields(False, [400]);
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
      Inc(I);
      VCSProgress.SetPBPos(I);
      MergeBuffer.Next;
    end; // while not MergeBuffer.EoF do begin
  finally
    FreeAndNil(VCSProgress);
  end;
  Mess := Format(JVCSRES_Project_6037s62_40Version_37d4637d41_successfully_merged46,
    [ExtractFileName(sProjectName), updwnTarget.Position, updwnTargetRev.Position]) + #13#10 +
    Format(JVCSRES_37d_modules46, [MergeBuffer.RecordCount]);
  Mess := Mess + #10#13 + JVCSRES_You_must_refresh_40F541_the_project_manager_view_to_see_the_changes46;
  MessageBox(WindowHandle, PChar(Mess), cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);

  Result := True;
end;

//------------------------------------------------------------------------------

function TVCSMerge.MergefAllVersion: Boolean;
var 
  I, ModuleCount: Integer;
  Mess: string;
  VerRevStr: string;
begin
  Result := False;
  ModuleCount := 0;
  // Merge
  VCSProgress := TVCSProgress.Create(Self);
  try
    VCSProgress.SetText(JVCSRES_Merge_new_version464646);
    VCSProgress.SetPBMax(lvMergeItems.Items.Count);
    VCSProgress.SetPBPos(0);
    VCSProgress.Left := Left + 20;
    VCSProgress.Top := Top + 20;
    VCSProgress.Show;
    Application.ProcessMessages;

    VerRevStr := Format('%d.%d', [updwnTarget.Position, updwnTargetRev.Position]);
    for I := 0 to lvMergeItems.Items.Count - 1 do
    begin
      Inc(ModuleCount);
      if (lvMergeItems.Items[I].StateIndex = 1) and
        (lvMergeItems.Items[I].SubItems[0] <> VerRevStr) then
      begin
        with DataModule1 do
        begin
          AppSrvClient1.Request.Rewrite;
          if cbJustChangeNr.Checked then
            AppSrvClient1.FunctionCode := 'MERGE_VER_REV_NR'
          else
            AppSrvClient1.FunctionCode := 'COPY_REVISION';
          AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
          AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
          AppSrvClient1.Request.WriteFields(True, [ServerProjectID]);
          AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
          // Module ID
          AppSrvClient1.Request.WriteFields(False,
            [lvMergeItems.Items[I].SubItems[2]]);
          // Source Revision ID
          AppSrvClient1.Request.WriteFields(False,
            [lvMergeItems.Items[I].SubItems[3]]);
          // Version
          AppSrvClient1.Request.WriteFields(False, [updwnTarget.Position]);
          // Revision
          AppSrvClient1.Request.WriteFields(False, [updwnTargetRev.Position]);
          // Module
          AppSrvClient1.Request.WriteFields(False,
            [LowerCase(lvMergeItems.Items[I].Caption)]);
          // IDE Version
          AppSrvClient1.Request.WriteFields(False, [400]);
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
        VCSProgress.SetPBPos(I);
      end; // if lvMergeItems.Items[I].StateIndex = 1 then begin
    end; // for I := 0 to lvMergeItems.Items.Count - 1 do begin
  finally
    FreeAndNil(VCSProgress);
  end;
  Mess := Format(JVCSRES_Project_6037s62_40Version_37d4637d41_successfully_merged46,
    [ExtractFileName(sProjectName), updwnTarget.Position, updwnTargetRev.Position]) + #13#10 +
    Format(JVCSRES_37d_modules46, [ModuleCount]);
  Mess := Mess + #10#13 + JVCSRES_You_must_refresh_40F541_the_project_manager_view_to_see_the_changes46;
  MessageBox(WindowHandle, PChar(Mess), cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
  Result := True;
end;

//------------------------------------------------------------------------------

procedure TVCSMerge.GetArchiveLabels;
begin
  cbLabels.Items.Clear;
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
    while (not AppSrvClient1.Answer.Eof) do 
    begin
      LabelIDs.Add(AppSrvClient1.Answer.Fields[1] + '=' +
        AppSrvClient1.Answer.Fields[0]);
      cbLabels.Items.Add(AppSrvClient1.Answer.Fields[1]);
      AppSrvClient1.Answer.Next;
    end; // while (not AppSrvClient1.Answer.EoF)
  end; // with DataModule1 do begin
end;

//------------------------------------------------------------------------------

procedure TVCSMerge.btnStampClick(Sender: TObject);
var
  I, SuccesCnt: Integer;
  Msg, NewLabelID, oldRevisionID: string;
  nLastStampRes : Integer;
begin
  if cbLabels.ItemIndex = -1 then
    Exit;
  // Restart DSA queue
  nLastStampRes := mrNone;
  DSAIdentsSetState(sBaseRegistryKey + crbMRU + 'Dlgs', 'StampSameLabelMsg', True);

  NewLabelID := LabelIDs.Values[cbLabels.Text];

  VCSProgress := TVCSProgress.Create(Self);
  VCSProgress.SetText(JVCSRES_Labeling464646);
  VCSProgress.SetPBMax(lvMergeItems.Items.Count - 1);
  VCSProgress.SetPBPos(0);
  VCSProgress.Left := Left + 40;
  VCSProgress.Top := Top + 60;
  VCSProgress.Show;
  Application.ProcessMessages;

  SuccesCnt := 0;
  Screen.Cursor := crHourGlass;
  try
    for I := 0 to lvMergeItems.Items.Count - 1 do
    begin
      if lvMergeItems.Items[I].StateIndex = 1 then
      begin
        with DataModule1 do
        begin
          AppSrvClient1.Request.Rewrite;
          AppSrvClient1.FunctionCode := 'ADD_REMOVE_REVISION_LABEL';
          AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
          AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
          AppSrvClient1.Request.WriteFields(True,
            [lvMergeItems.Items[I].SubItems[2]]);
          AppSrvClient1.Request.WriteFields(False,
            [lvMergeItems.Items[I].SubItems[3]]);
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

            VCSProgress.Hide;
            try
              // can not use default DSA functionality from JVCSDialogs as it
              // always returns default result, so if you click No for current
              // queue it will still return Yes
              // Need not already in Don't show again state?
              if DSAIdentsGetState(sBaseRegistryKey + crbMRU + 'Dlgs', 'StampSameLabelMsg') then
              begin
                UseRegistry := True;
                DontShowMsgText := JVCSRES_38Don3939t_show_this_message_again_in_the_current_queue;
                Msg := '<' + lvMergeItems.Items[I].Caption + '>' + #10#13 +
                  Format(JVCSRES_Label_6037s62_is_already_assigned_to_V_37s4637s_of_this_module46,
                  [cbLabels.Text, AppSrvClient1.Answer.Fields[2], AppSrvClient1.Answer.Fields[3]]) + #10#13 +
                  JVCSRES_Move_the_module_to_the_current_version63;
                nLastStampRes := DSAIdentsMessageDlg( Msg
                                                    , mtConfirmation
                                                    , [mbYes, mbNo]
                                                    , 0
                                                    , sBaseRegistryKey + crbMRU + 'Dlgs'
                                                    , 'StampSameLabelMsg'
                                                    , idYes
                                                    );
              end;

              if nLastStampRes = idYes then
              begin
                oldRevisionID := AppSrvClient1.Answer.Fields[1];

                // delete the label from the "old" version
                AppSrvClient1.Request.Rewrite;
                AppSrvClient1.FunctionCode := 'ADD_REMOVE_REVISION_LABEL';
                AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
                AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
                AppSrvClient1.Request.WriteFields(True,
                  [lvMergeItems.Items[I].SubItems[2]]);
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

                // now, add the label to the current version
                AppSrvClient1.Request.Rewrite;
                AppSrvClient1.FunctionCode := 'ADD_REMOVE_REVISION_LABEL';
                AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
                AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
                AppSrvClient1.Request.WriteFields(True,
                  [lvMergeItems.Items[I].SubItems[2]]);
                AppSrvClient1.Request.WriteFields(False,
                  [lvMergeItems.Items[I].SubItems[3]]);
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
                  VCSProgress.Hide;
                  Msg := '<' + lvMergeItems.Items[I].Caption + '>' + #10#13 +
                    Format(JVCSRES_Label_6037s62_is_already_assigned_to_V_37s4637s_of_this_module46,
                    [cbLabels.Text, AppSrvClient1.Answer.Fields[2], AppSrvClient1.Answer.Fields[3]]) + #10#13 +
                    JVCSRES_Move_the_module_to_the_current_version63;
                  MessageBox(WindowHandle, PChar(Msg), cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
                  VCSProgress.Show;
                end // if not DecodeBoolStr(....
                else
                  Inc(SuccesCnt);
              end;
            finally
              VCSProgress.Show;
            end;
          end // if not DecodeBoolStr(....
          else
            Inc(SuccesCnt);
        end; // with DataModule1 do begin
      end; // if lvMergeItems.Items[I].StateIndex = 1 then begin
      VCSProgress.SetPBPos(I);
    end; // for I := 0 to lvMergeItems.Items - 1 do begin
  finally
    Screen.Cursor := crDefault;
    VCSProgress.Free;
    VCSProgress := nil;
  end;
  MessageBox(WindowHandle, PChar(Format(JVCSRES_Label_6037s62_successfully_assigned_to_37d_modules46,
    [cbLabels.Text, SuccesCnt]) + #10#13 +
    JVCSRES_You_must_refresh_40F541_the_project_manager_view_to_see_the_changes46),
    cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
end;

//------------------------------------------------------------------------------

procedure TVCSMerge.HelpTopic1Click(Sender: TObject);
begin
  PerformHelpCommand(Application, IDH_Merge);
end;

//------------------------------------------------------------------------------

procedure TVCSMerge.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then 
  begin
    btnClose.Click;
    Key := 0;
  end;
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Merge);
end;

//------------------------------------------------------------------------------

procedure TVCSMerge.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  jvcsWriteWindowPosAndSize(sBaseRegistryKey + crbWindows, 'MergeVersion',
    Top, Left, Width, Height);

  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'Merge_IncludeHidden',
    cbInclHidden.Checked);
end;

//------------------------------------------------------------------------------

procedure TVCSMerge.rbAllVersionClick(Sender: TObject);
begin
  if (Sender as TRadioButton) = rbAllVersion then 
  begin
    rbAllVersion.Checked := True;
    rb1Version.Checked := False;
  end 
  else 
  begin
    rbAllVersion.Checked := False;
    rb1Version.Checked := True;
  end;
  Label3.Enabled := rb1Version.Checked;
  edFromVer.Enabled := rb1Version.Checked;
  updwnSource.Enabled := rb1Version.Checked;
  lvMergeItems.Enabled := not rb1Version.Checked;
  btnStamp.Enabled := (not rb1Version.Checked) and (cbLabels.Text <> '');
  cbLabels.Enabled := not rb1Version.Checked;
  spBtnLabelMan.Enabled := not rb1Version.Checked;
end;

//------------------------------------------------------------------------------

procedure TVCSMerge.lvMergeItemsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var 
  HitTest: THitTests;
  HitItem: TListItem;
begin
  HitTest := lvMergeItems.GetHitTestInfoAt(X, Y);
  if (Button = mbLeft) and (htOnStateIcon in HitTest) then 
  begin
    HitItem := lvMergeItems.GetItemAt(X, Y);
    if HitItem.StateIndex = 0 then 
      HitItem.StateIndex := 1 
    else 
      HitItem.StateIndex := 0;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSMerge.edToVerChange(Sender: TObject);
begin
  if updwnTarget.Position > MinVersion then 
  begin
    updwnTargetRev.Min := 0;
    updwnTargetRev.Position := 0;
  end 
  else
  begin
    updwnTargetRev.Min := MinRevision;
    updwnTargetRev.Position := MinRevision;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSMerge.cbInclHiddenClick(Sender: TObject);
begin
  if not FCreated then 
    Exit;
  FindMergeModules;
end;

//------------------------------------------------------------------------------

procedure TVCSMerge.spBtnLabelManClick(Sender: TObject);
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

procedure TVCSMerge.SelectAll1Click(Sender: TObject);
var 
  I: Integer;
begin
  for I := 0 to lvMergeItems.Items.Count - 1 do
    lvMergeItems.Items[I].StateIndex := 1;
end;

//------------------------------------------------------------------------------

procedure TVCSMerge.UnselectAll1Click(Sender: TObject);
var 
  I: Integer;
begin
  for I := 0 to lvMergeItems.Items.Count - 1 do
    lvMergeItems.Items[I].StateIndex := 0;
end;

//------------------------------------------------------------------------------

procedure TVCSMerge.lvMergeItemsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (lvMergeItems.Selected <> nil) and (Key = VK_SPACE) then 
  begin
    if lvMergeItems.Selected.StateIndex > 1 then 
      Exit;
    if lvMergeItems.Selected.StateIndex = 0 then 
      lvMergeItems.Selected.StateIndex := 1
    else 
      lvMergeItems.Selected.StateIndex := 0;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSMerge.HelpClick(Sender: TObject);
var
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSMerge.cbLabelsChange(Sender: TObject);
begin
  btnStamp.Enabled := (cbLabels.Text <> '');
end;

//------------------------------------------------------------------------------

procedure TVCSMerge.FormDestroy(Sender: TObject);
begin
  LabelIDs.Free;
end;

end.
