(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: Backup.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS:
  Thomas Huber (Thomas_D_Huber@gmx.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
- wrong password in restore continues unzip without error but with result = 0 files 

-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber     - 1st Migrationstep from FreeVCS code to JEDI VCS
2003/02/12  USchuster  - changed DSAMsg with JVCSDialogs in uses clause to use
                         JvDSADialogs
2003/02/18  MGosselink - emptied some .text props, changed Led color green to lime
2003/03/02  THensle    - changed configuration storage to "ConfigStorage.pas"
2003/03/09  USchuster  - changes in connection with mantis #727
                       - disabled the AutoSave property in rcbRestorePath
                         and removed the regkeys (they where wrong and
                         loading and saving is no done with MruListRestorePath)
                       - removed rcbRestorePath.AutoSave.SaveValue
                       - the RestorePath will also be inserted into the
                         combobox now after restoring (not after selecting)
                       - anchors of rcbRestorePath completely set
                       - fixed wrong jvcsRead... methods
                         (a float can't be read as integer and vice versa)
2003/03/15  THuber     - platform compilerwarnings
2003/04/08  USchuster  - changes for IDEInterface
2003/12/27  USchuster  - changed JEDI-VCS/JEDIFreeVCS to JEDI VCS in unit header and
                         message boxes (use constant)
                       - AutoComplete in ComboBox now False
2004/02/24  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/08  THuber    - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
                      - jedistyle clean
                      - use jvcl msgBoxes
2005/04/25  CSchuette - added calls to "ResolveFileFamilies" to fix mantis #1205
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 final released ^^^^^^^^^^^^^^^^^^^^^^^^^^
2006/04/30  THuber    #3611 config folder now windows user dependend (appdata shell folder)
2006/05/05  THuber    #3677 z i pmaster replaced with abbrevia components
2006/05/28  USchuster - D5 fix
2007/06/30  USchuster - style cleaning
                      - changes for large fonts (contraints size depend now on PixelsPerInch; analog to Mantis #3710)
2007/08/13  USchuster - Trace -> TraceMsg
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit Backup;

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
  StdCtrls, ComCtrls, ExtCtrls, Menus, JvLED, Buttons, ImgList,
  JvCombobox, JvComponent, JVCSMruList, JvExStdCtrls, JvExControls,
  AbArcTyp, AbZipTyp, AbZipPrc, AbUnzPrc, AbUtils, AbDlgPwd, JVCSForms;

type
  TVCSBackup = class(TJVCSForm)
    PageControl1: TPageControl;
    sheetBackup: TTabSheet;
    sheetRestore: TTabSheet;
    Panel1: TPanel;
    btnCancel: TButton;
    Panel3: TPanel;
    Label2: TLabel;
    lblPath: TLabel;
    TransLED1: TJvLED;
    lblChanged: TLabel;
    cbPW: TCheckBox;
    btnBackup: TButton;
    Panel4: TPanel;
    rbOverwrite: TRadioButton;
    rbDontOverwrite: TRadioButton;
    btnRestore: TButton;
    spBtnBrowse: TSpeedButton;
    rbUseFldNames: TCheckBox;
    Label4: TLabel;
    SheetInfo: TTabSheet;
    lbProgress: TListBox;
    Panel6: TPanel;
    ProgressBar1: TProgressBar;
    Label5: TLabel;
    Label6: TLabel;
    ProgressBar2: TProgressBar;
    lvBackup: TListView;
    StateImageList: TImageList;
    spBtnSelect: TSpeedButton;
    spBtnSelectRestore: TSpeedButton;
    SysImageList: TImageList;
    lvRestore: TListView;
    Timer1: TTimer;
    cbAutoClose: TCheckBox;
    spBtnCopyClipbrd: TSpeedButton;
    Help: TSpeedButton;
    cbDoBckUp: TCheckBox;
    PopupMenu1: TPopupMenu;
    HideUncheckedModules1: TMenuItem;
    Panel2: TPanel;
    cbxRestoreFile: TJvComboBox;
    rcbRestorePath: TJvComboBox;
    procedure FormCreate(Sender: TObject);
    procedure btnBackupClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure HelpTopic1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure spBtnSelectClick(Sender: TObject);
    procedure spBtnSelectRestoreClick(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure btnRestoreClick(Sender: TObject);
    procedure spBtnBrowseClick(Sender: TObject);
    procedure lvBackupMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lvRestoreMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure spBtnCopyClipbrdClick(Sender: TObject);
    procedure lvBackupKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvRestoreKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure HelpClick(Sender: TObject);
    procedure HideUncheckedModules1Click(Sender: TObject);
    procedure cbxRestoreFileChange(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure cbDoBckUpClick(Sender: TObject);
  private
    { Private-Deklarationen }
    FCreating,
    BackupProject,
    BackupSeq,
    AutoDelete,
    ShowProgr,
    ShowRestError,
    AllBChecked,
    AllRChecked: Boolean;
    RestoreFile,
    BackupPath: string;
    DeleteAfter: Double;
    OldSeqBackup,
    DelSeqBackup,
    ZipLevel: Integer;
    ZipPassword: string;
    ZipFiles: TStringList;
    ProjectModules: TStringList;
    MruListRestorePath: TJVCSMruList;
    procedure CollectAllBackupFiles;
    procedure AddLVItem(const CurrentModule: string);
    function CheckForChangedFiles: Integer;
    procedure GetCheckedFiles;
    procedure Backup;
    function ChckDDiffToStr(Diff: Double): string;
    procedure KillOldBackups(Project: string; FreshDate: Double);
    procedure CleanUp;

    procedure AbBackup(const sZipFile: string; var CompressedFiles: Integer);
    procedure AbInsertHelper(Sender: TObject; Item: TAbArchiveItem; OutStream: TStream);
    procedure AbExtractHelper(Sender: TObject; Item: TAbArchiveItem; const NewName: string);
    procedure AbOnArchiveProgress(Sender: TObject; Progress: Byte; var Abort: Boolean);
    procedure AbOnArchiveItemProgress(Sender: TObject; Item: TAbArchiveItem; Progress: Byte; var Abort: Boolean);
    procedure AbOnConfirmOverWrite(var Name: string; var Confirm: Boolean);
    procedure AbOnNeedPassword(Sender: TObject; var NewPassword: string);
  public
    { Public-Deklarationen }
    BackupProjectName: string;
    AutoBackup: Boolean;
    TotalSize1, TotalProgress1, TotalSize2, TotalProgress2: Int64;
  end;

var
  VCSBackup: TVCSBackup;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  ConfigStorage, ShellAPI, FileCtrl, VCSProcBase, VCSBase, Password, JVCSDialogs, ClipBrd,
  CommCtrl, SelectFolder, DBModule, Options, JvJVCLUtils, JVCSGUIClientResources, JclFileUtils;

{$R *.dfm}

procedure TVCSBackup.FormCreate(Sender: TObject);
var
  sfi: TSHFileInfo;
  ToolTipHandle: HWND;
  wTop, wLeft, wHeight, wWidth: Integer;
begin
  Screen.Cursor := crHourGlass;
  try
    Constraints.MinHeight := MulDiv(336, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(375, PixelsPerInch, 96);
    ZipFiles := TStringList.Create;
    ZipFiles.Sorted := True;
    ZipFiles.Duplicates := dupIgnore;
    //TStringList is casesensitive by default and that property does not exist in D5
    //ZipFiles.CaseSensitive := False;

    // Shell Image List
    SysImageList.Handle := SHGetFileInfo('', 0,sfi, SizeOf(TSHFileInfo),
      SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
    SysImageList.ShareImages := True;

    // ListView Tooltips
    SendMessage(lvBackup.Handle, LVM_SETEXTENDEDLISTVIEWSTYLE, LVS_EX_INFOTIP,
      LVS_EX_INFOTIP);
    ToolTipHandle := SendMessage(lvBackup.Handle, LVM_GETTOOLTIPS, 0, 0);
    SendMessage(ToolTipHandle, TTM_SETDELAYTIME, TTDT_AUTOMATIC, 1);
    SendMessage(ToolTipHandle, TTM_SETDELAYTIME, TTDT_AUTOPOP, 3000);
    SendMessage(lvRestore.Handle, LVM_SETEXTENDEDLISTVIEWSTYLE, LVS_EX_INFOTIP,
      LVS_EX_INFOTIP);
    ToolTipHandle := SendMessage(lvRestore.Handle, LVM_GETTOOLTIPS, 0, 0);
    SendMessage(ToolTipHandle, TTM_SETDELAYTIME, TTDT_AUTOMATIC, 1);
    SendMessage(ToolTipHandle, TTM_SETDELAYTIME, TTDT_AUTOPOP, 3000);

    if sBaseRegistryKey <> '' then
    begin
      ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions,
        'ShowToolTip', True);
      cbDoBckUp.Checked := jvcsReadBool(sBaseRegistryKey + crbOptions,
        'BackupActive', False);
      BackupProject := jvcsReadBool(sBaseRegistryKey + crbOptions,
        'BackupProject', True);
      BackupPath := jvcsReadString(sBaseRegistryKey + crbOptions,
        'BackupPath', '');
      ShowProgr := jvcsReadBool(sBaseRegistryKey + crbOptions,
        'BackupShowProgress', True);
      ZipLevel := jvcsReadInteger(sBaseRegistryKey + crbOptions,
        'BackupZipLevel', 9);
      AutoDelete := jvcsReadBool(sBaseRegistryKey + crbOptions,
        'BackupEraseSequentiel', False);
      DeleteAfter := jvcsReadInteger(sBaseRegistryKey + crbOptions,
        'BackupEraseAfterDays', 30);
      //??? GlobalSettings
      if not SettingIsGlobal(15) then
        BackupSeq := jvcsReadBool(sBaseRegistryKey + crbOptions, 'BackupSequentiel', False)
      else
        BackupSeq := GlobalSettingValue(15);
      //Window
      cbAutoClose.Checked := jvcsReadBool(sBaseRegistryKey + crbWindows, 'BackupAutoClose', False);
      if jvcsReadWindowPosAndSize(sBaseRegistryKey + crbWindows, 'Backup',
        wTop, wLeft, wHeight, wWidth) then
      begin
        Top := wTop;
        Left := wLeft;
        Height := wHeight;
        Width := wWidth;
      end else
      begin
        Top := (Screen.Height - Height) div 2;
        Left := (Screen.Width - Width) div 2;
      end;
      // ListView.Columns
      with lvBackup do
      begin
        Columns[0].Width := jvcsReadInteger(sBaseRegistryKey + crbWindows, 'Backup_Col1.0', 100);
        Columns[1].Width := jvcsReadInteger(sBaseRegistryKey + crbWindows, 'Backup_Col1.1', 250);
        Columns[2].Width := jvcsReadInteger(sBaseRegistryKey + crbWindows, 'Backup_Col1.2', 30);
      end;
      with lvRestore do
      begin
        Columns[0].Width := jvcsReadInteger(sBaseRegistryKey + crbWindows, 'Backup_Col2.0', 250);
        Columns[1].Width := jvcsReadInteger(sBaseRegistryKey + crbWindows, 'Backup_Col2.1', 60);
        Columns[2].Width := jvcsReadInteger(sBaseRegistryKey + crbWindows, 'Backup_Col2.2', 60);
      end;

      MruListRestorePath := TJVCSMruList.CreateEx(sBaseRegistryKey + crbMRU + '5');
      rcbRestorePath.Items.Assign(MruListRestorePath);

      rcbRestorePath.Text := ExtractFileDrive(sProjectName);
    end  // if DLL_BaseRegistryKey <> '' then begin
    else
      MruListRestorePath := nil;

    if (BackupPath <> '') and (BackupPath[Length(BackupPath)] <> '\') then
      BackupPath := BackupPath + '\';

    ProjectModules := TStringList.Create;
    ProjectModules.Sorted := True;
    //???
    ProjectModules.Duplicates := dupIgnore;
    spBtnCopyClipbrd.Enabled := False;

    FCreating := True;
    AllBChecked := False;
    Screen.Cursor := crDefault;
    ShowRestError := False;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
    Screen.Cursors[cPopUpMCursor] := LoadCursor(hInstance, PChar('CURSORRM'));
    lvBackup.Cursor := cPopUpMCursor;
  end;
end;

//------------------------------------------------------------------------------

function TVCSBackup.CheckForChangedFiles: Integer;
var
  I, ChangedFiles: Integer;
  OldBackup, CurrentFile: string;
  BackupContent: TStringList;
  AbZipArchive: TAbZipArchive;
begin
  ChangedFiles := 0;
  BackupContent := TStringList.Create;
  try
    // get content of last backup
    OldBackup := BackupPath +
      ChangeFileExt(ExtractFileName(BackupProjectName), '.zip');
    if FileExists(OldBackup) then
    begin
      AbZipArchive := TAbZipArchive.Create(OldBackup, fmOpenRead or fmShareDenyWrite);
      try
        AbZipArchive.Load;

        for I := 0 to AbZipArchive.Count - 1 do
          BackupContent.Add(AnsiLowerCase(AbZipArchive.Items[I].DiskFileName));

        ChangedFiles := 0;
        for I := 0 to lvBackup.Items.Count - 1 do
        begin
          lvBackup.Items[I].StateIndex := 0;
          CurrentFile := lvBackup.Items[I].SubItems[0] + lvBackup.Items[I].Caption;
          if (FileGetAttr(CurrentFile) and faArchive) = faArchive then
          begin
            lvBackup.Items[I].StateIndex := 1;
            Inc(ChangedFiles);
          end
          else
          begin
            Delete(CurrentFile, 1, Length(ExtractFileDrive(CurrentFile)));
            if CurrentFile[1] = '\' then
              Delete(CurrentFile, 1, 1);
            if BackupContent.IndexOf(CurrentFile) = -1 then
            begin
              lvBackup.Items[I].StateIndex := 1;
              Inc(ChangedFiles);
            end;
          end;
        end; // for i := 0 to lvBackup.Items.Count - do begin
      finally
        AbZipArchive.Free;
      end;
    end;
  finally
    BackupContent.Free;
  end;
  Result := ChangedFiles;

end;

//------------------------------------------------------------------------------

procedure TVCSBackup.AddLVItem(const CurrentModule: string);
var
  CurrentPath, CurrentFile, Attr: string;
  FExists: Boolean;
  NewItem: TListItem;
  sfi: TSHFileInfo;
begin
  CurrentPath := AnsiLowerCase(ExtractFilePath(CurrentModule));
  CurrentFile := AnsiLowerCase(ExtractFileName(CurrentModule));
  FExists := FileExists(CurrentModule);

  // Module
  NewItem := lvBackup.Items.Add;
  if FExists then
    NewItem.Caption := ExtractFileName(GetOriginalFileName(CurrentPath + CurrentFile))
  else
    NewItem.Caption := CurrentFile;
  SHGetFileInfo(PChar(CurrentModule), 0, sfi, SizeOf(sfi),
    SHGFI_SYSICONINDEX or SHGFI_SMALLICON or SHGFI_DISPLAYNAME);
  NewItem.ImageIndex := sfi.IIcon;
  // Path
  NewItem.SubItems.Add(CurrentPath);
  // Attr
  Attr := '';
  if FExists then
  begin
    Attr := GetAttrStrEx(CurrentModule);
    NewItem.SubItems.Add(Attr);
  end
  else
    NewItem.SubItems.Add('-');
end;

//------------------------------------------------------------------------------

procedure TVCSBackup.GetCheckedFiles;
var
  I, FileCount: Integer;
begin
  FileCount := 0;
  for I := 0 to lvBackup.Items.Count - 1 do
    if lvBackup.Items[I].StateIndex = 1 then
      Inc(FileCount);

  Caption := Format ( JVCSRES_VCS_Backup_45_37s_9137d_files93
                    , [ AnsiLowerCase(ExtractFileName(sProjectName))
                      , FileCount
                      ]
                    );
end;

//------------------------------------------------------------------------------

procedure TVCSBackup.FormActivate(Sender: TObject);
begin
  Application.ProcessMessages;
  if not FCreating then
    Exit;
  CollectAllBackupFiles;
end;

//------------------------------------------------------------------------------

procedure TVCSBackup.CollectAllBackupFiles;
var
  BKPFileName, BackupTarget, LastDate, S1, Num: string;
  LastBackup: Double;
  ChangedFiles, ProjectID, I: Integer;
  W: Word;
  BackupList: TStringList;
  nId: Integer;
begin
  PageControl1.ActivePage := sheetBackup;
  if (BackupPath = '') or (not DirectoryExists(BackupPath)) then
  begin
    nId := MsgYesNoCancel ( WindowHandle
                          , JVCSRES_You_do_not_have_a_valid_backup_path_defined46 +#13+#10+
                            JVCSRES_Would_you_like_to_do_this_now63
                          , cMsgBoxCaption
                          , MB_ICONQUESTION
                          );
    case nId of
      id_Yes :
        begin
          VCSOptions := TVCSOptions.Create(Application);
          try
            VCSOptions.DefaultSheet := cspBackup;
            VCSOptions.ShowModal;
          finally
            VCSOptions.Free;
          end;
        end;
      else
        begin
          btnBackup.Enabled := False;
          Exit;
        end;
    end;
    BackupPath := jvcsReadString(sBaseRegistryKey + crbOptions, 'BackupPath', '');
  end;
  if (BackupPath = '') or (not DirectoryExists(BackupPath)) then
  begin
    btnBackup.Enabled := False;
    Exit;
  end;
  Screen.Cursor := crHourGlass;

  if BackupSeq and AutoDelete then
  begin
    OldSeqBackup := 0;
    DelSeqBackup := 0;
    KillOldBackups(BackupProjectName, DeleteAfter);
  end;

  FCreating := False;
  LastBackup := jvcsReadFloat(sBaseRegistryKey + crbProjects +
    ExtractFileName(BackupProjectName), 'LastBackup', 0);
  if LastBackup <> 0 then
  begin
    LastDate := DateTimeToStr(LastBackup) + ' (- ' +
      ChckDDiffToStr(Now - LastBackup) + ')';
  end
  else
    LastDate := JVCSRES_Unknown;

  lvBackup.Items.Clear;
  ChangedFiles := 0;
  lblChanged.Caption := JVCSRES_Request_server_for_project_files464646;

  {$IFDEF CUSTOMDRIVE}
  if AutoBackup then
    sDriveSubst := RegReadString(HKCU, sBaseRegistryKey + crbProjects +
      ExtractFileName(BackupProjectName), 'LocalDrive', '')
  else
    sDriveSubst := RegReadString(HKCU, sBaseRegistryKey + crbProjects +
      ExtractFileName(sProjectName), 'LocalDrive', '');
  if (sDriveSubst = '') then
    sDriveSubst := RegReadString(HKCU, sBaseRegistryKey + crbOptions,
      'LocalDrive', '');
  {$ENDIF CUSTOMDRIVE}

  // projects sourcefiles in list
  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_PROJECT_ID';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    if AutoBackup then
      AppSrvClient1.Request.WriteFields(True,
        [ExtractFileName(BackupProjectName)])
    else
      AppSrvClient1.Request.WriteFields(True,
        [ExtractFileName(sProjectName)]);
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
    if AppSrvClient1.Answer.Fields[0] <> '0' then
    begin
      // known project
      TransactionNr := _StrToInt(AppSrvClient1.Answer.Fields[2]);
      ProjectID := _StrToInt(AppSrvClient1.Answer.Fields[0]);
    end
    else
    begin
      // unknown project
      TransactionNr := _StrToInt(AppSrvClient1.Answer.Fields[2]);
      if AutoBackup then
        CleanUp
      else
      begin
        {  <%s> This project is not registered by JEDI VCS.\n\r
           You must add the project to the version archive first. 342  }
        MsgInfo ( WindowHandle
                , Format( JVCSRES_6037s62_This_project_is_not_registered_by_JEDI_VCS46 + #13+#10+
                          JVCSRES_You_must_add_the_project_to_the_version_archive_first46
                        , [ExtractFileName(sProjectName)]
                        )
                , cMsgBoxCaption
                );
        btnBackup.Enabled := False;
        CleanUp;
      end;
      Exit;
    end;

    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_PROJECT_MODULE_LIST';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [ProjectID]);
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
      {$IFDEF CUSTOMDRIVE}
      if FileExists(ChangeDriveName(AppSrvClient1.Answer.Fields[2], sDriveSubst) +
        AppSrvClient1.Answer.Fields[1]) then
        ProjectModules.Add(ChangeDriveName(AppSrvClient1.Answer.Fields[2],
          sDriveSubst) +
          AppSrvClient1.Answer.Fields[1]);

      {$ELSE}
      if FileExists(AppSrvClient1.Answer.Fields[2] +
        AppSrvClient1.Answer.Fields[1]) then
        ProjectModules.Add(AppSrvClient1.Answer.Fields[2] +
          AppSrvClient1.Answer.Fields[1]);

      {$ENDIF CUSTOMDRIVE}
      AppSrvClient1.Answer.Next;
    end; // while not AppSrvClient1.Answer.Eof do begin
  end; // with DataModule1 do begin

  Screen.Cursor := crHourGlass;
  // Form-Dateien für User Module
  BackupList := TStringList.Create;
  try
    for I := 0 to ProjectModules.Count - 1 do
      GetAdditionalFilesFromFileFamily(ProjectModules.Strings[I], BackupList);
    for I := 0 to BackupList.Count - 1 do
      ProjectModules.Add(AnsiLowerCase(BackupList.Strings[I]));
  finally
    BackupList.Free;
  end;

  // Core Files aus Delphi Project in Liste
  if AutoBackup then
  begin
    // Autobackup -> Core aus Datei lesen
    BackupList := TStringList.Create;
    try
      BKPFileName := sConfigFolder + ChangeFileExt(ExtractFileName(BackupProjectName), '.bkp');
      if FileExists(BKPFileName) then
        BackupList.LoadFromFile(BKPFileName);
      for I := 0 to BackupList.Count - 1 do
        if FileExists(BackupList.Strings[I]) then
          ProjectModules.Add(AnsiLowerCase(BackupList.Strings[I]));
    finally
      BackupList.Free;
    end;
  end // if Auto then begin
  else
  begin
    {$IFDEF IDEDLL}
    // no Autobackup -> Core aus IDE lesen
    for I := 0 to IDEInterface.GetUnitCount - 1 do
      ProjectModules.Add(AnsiLowerCase(IDEInterface.GetUnitName(I)));
    for I := 0 to IDEInterface.GetFormCount - 1 do
      ProjectModules.Add(AnsiLowerCase(IDEInterface.GetFormName(I)));
    {$ENDIF IDEDLL}
  end; // else if Auto then begin

  lblChanged.Caption := JVCSRES_Scan_directories_for_changed_files464646;
  Application.ProcessMessages;

  lvBackup.Items.BeginUpdate;
  try
    for I := 0 to ProjectModules.Count - 1 do
      if FileExists(ProjectModules.Strings[I]) then
        AddLVItem(ProjectModules.Strings[I]);
  finally
    lvBackup.Items.EndUpdate;
  end;

  if not BackupSeq then
    ChangedFiles := CheckForChangedFiles
  else
  begin
    for I := 0 to lvBackup.Items.Count - 1 do
    begin
      lvBackup.Items[I].StateIndex := 1;
      Inc(ChangedFiles);
    end;
  end;

  if BackupSeq then
    lblChanged.Caption := Format( JVCSRES_37d_files_to_backup44_37d_old_archives44_37d_outdated_4562_37d_just_removed46
                                , [ ChangedFiles
                                  , OldSeqBackup
                                  , DelSeqBackup
                                  , DelSeqBackup
                                  ]
                                )
  else
    lblChanged.Caption := Format( JVCSRES_37d_files_changed_or_new_since_37s
                                , [ChangedFiles, LastDate]
                                );

  if ChangedFiles = 0 then
    TransLED1.ColorOn := clLime
  else
    TransLED1.ColorOn := clRed;

  GetCheckedFiles;
  if not BackupSeq then
    lblPath.Caption := BackupPath +
      ChangeFileExt(ExtractFileName(BackupProjectName), '.zip')
  else
  begin
    BackupTarget := BackupPath +
      ChangeFileExt(ExtractFileName(BackupProjectName), '') + '_000.zip';
    W := 1;
    S1 := ChangeFileExt(ExtractFileName(BackupProjectName), '');
    //get a filename
    while FileExists(BackupTarget) do
    begin
      Num := IntToStr(W);
      while Length(Num) < 3 do
        Num := '0' + Num;
      BackupTarget := BackupPath + S1 + '_' + Num + '.zip';
      Inc(W);
      if W > 900 then
      begin
        BeepIfSet;
        MsgWarn ( WindowHandle
                , Format( JVCSRES_Warning33_Sequentiel_backup_runs_out_of_free_numbers46 +#13+#10+
                          JVCSRES_You_have_more_than_900_recent_backupfiles_in_6037s62 +#13+#10+
                          JVCSRES_Please_remove_some_older_ones46
                        , [BackupPath]
                        )
                , cMsgBoxCaption
                );
        btnBackup.Enabled := False;
        Exit;
      end; // if w > 900 then begin
    end; // while FileExists(BackupTarget) do begin
    lblPath.Caption := BackupTarget;
  end;

  Screen.Cursor := crDefault;

  if AutoBackup and (TransLED1.ColorOn = clLime) then
    CleanUp;
end;

//------------------------------------------------------------------------------

procedure TVCSBackup.btnBackupClick(Sender: TObject);
var
  PWResult, I: Integer;
  Password: string;
  FilesSelected: Boolean;
begin
  FilesSelected := False;
  with lvBackup do
  begin
    for I := 0 to Items.Count - 1 do
    begin
      if Items[I].StateIndex = 1 then
      begin
        FilesSelected := True;
        Break;
      end;
    end; // for i := 0 to Items.Count - 1 do begin
  end; // with lvBackup do begin
  if not FilesSelected then
  begin
    MsgInfo ( WindowHandle
            , JVCSRES_Nothing_to_do46
            , cMsgBoxCaption
            );
    Exit;
  end;

  if cbPW.Checked then
  begin
    VCSPassword := TVCSPassword.Create(Application);
    try
      VCSPassword.Top := Top + 20;
      VCSPassword.Left := Left + 20;
      VCSPassword.GetPassword := False;
      VCSPassword.DlgCaption := JVCSRES_Enter_Password;
      PWResult := VCSPassword.ShowModal;
      ZipPassword := VCSPassword.Password;
    finally
      VCSPassword.Free;
    end;
    // Break or no Password empty
    if not (PWResult <> mrCancel) and (Password <> '') then
    begin
      ZipPassword := '';
      Exit;
    end;
  end; // if cbPW.Checked then begin
  Screen.Cursor := crHourGlass;
  btnBackup.Enabled := False;
  btnCancel.Enabled := False;

  Backup;

  btnBackup.Enabled := True;
  btnCancel.Enabled := True;
  spBtnCopyClipbrd.Enabled := True;
  with lvBackup do
    for I := 0 to Items.Count - 1 do
      Items[I].StateIndex := 0;
  // %d file[s] changed since %s
  lblChanged.Caption := FmtLoadStr(258, [0, DateTimeToStr(Now)]);
  TransLED1.ColorOn := clLime;
  Screen.Cursor := crDefault;
  btnCancel.Caption := JVCSRES_38Close;
  btnCancel.SetFocus;

  if cbAutoClose.Checked then
    CleanUp;
end;

//------------------------------------------------------------------------------

procedure TVCSBackup.Backup;
var
  ScsCount: Integer;
begin
  ScsCount := 0;
  Screen.Cursor := crHourGlass;
  lbProgress.Clear;
  lbProgress.Items.Add(JVCSRES_Preparing_Backup464646Please_wait);
  lbProgress.Items.Add(Format(JVCSRES_Target_file_name58_37s, [lblPath.Caption]));
  lbProgress.Items.Add(JVCSRES_Mode58_Add_4038_Replace41);
  lbProgress.Items.Add(Format(JVCSRES_AddCompLevel58_37d, [ZipLevel]));
  if cbPW.Checked then
    lbProgress.Items.Add(Format(JVCSRES_Encryption58_37s, [JVCSRES_On]))
  else
    lbProgress.Items.Add(Format(JVCSRES_Encryption58_37s, [JVCSRES_Off]));
  lbProgress.Items.Add('');
  if ShowProgr then
    PageControl1.ActivePage := SheetInfo;

  {$IFDEF DEBUG}
  if ShowDebugMsg then
    JclDebug.TraceMsg(PChar(cPrgType +
      'TVCSBackup Zipfile: ' + lblPath.Caption + #0));
  {$ENDIF DEBUG}

  ProgressBar2.Min := 0;
  ProgressBar2.Max := 100;

  AbBackup(lblPath.Caption, ScsCount);

  ProgressBar1.Position := 0;
  ProgressBar2.Position := 0;


  jvcsWriteFloat(sBaseRegistryKey + crbProjects + ExtractFileName(BackupProjectName),
    'LastBackup', Now);

  {$IFDEF DEBUG}
  if ShowDebugMsg then
    JclDebug.TraceMsg(PChar('Ready: Save Last Backup Time' + #0));
  {$ENDIF DEBUG}
  lbProgress.Items.Add( Format( JVCSRES_Zip_size58_37s_Bytes
                              , [ FormatFloat('#,', _GetFileSize(lblPath.Caption))  ]
                              )
                      );

  // Backup complete. %d files.
  if ShowProgr then
  begin
    lbProgress.Items.Add( Format( JVCSRES_Backup_complete46_37d_files_added47replaced46
                                , [ScsCount]
                                )
                        );
    lbProgress.TopIndex := lbProgress.Items.Count - 1;
  end
  else
  begin
    MsgInfo ( Handle
            , Format( JVCSRES_Backup_complete46_37d_files_added47replaced46
                    , [ScsCount]
                    )
            , cMsgBoxCaption
            );
    CleanUp;
  end;
end;

//------------------------------------------------------------------------------

function TVCSBackup.ChckDDiffToStr(Diff: Double): string;
var
  Days: string;
  DCount: Integer;
begin
  DCount := Round(Diff);
  if DCount > Diff then
    DCount := DCount - 1;
  Days := IntToStr(DCount);
  if Length(Days) = 1 then
  begin
    case Days[1] of
      '0' :
        Days := '';
      '1' :
        Days := Days + JVCSRES__day44_;
      else
        Days := Days + JVCSRES__days44_;
    end;
  end
  else
    Days := Days + JVCSRES__days44_;
  Diff := Diff * 24;
  Diff := Diff - (DCount * 24);
  if Diff < 0.0417 then
    Diff := 0.0417; // aufrunden auf 1 h
  ChckDDiffToStr := Days + FloatToStrF(Diff, ffFixed, 2, 0) + ' h';
end;

//------------------------------------------------------------------------------

procedure TVCSBackup.HelpTopic1Click(Sender: TObject);
begin
  PerformHelpCommand(Application, IDH_Backup);
end;

//------------------------------------------------------------------------------

procedure TVCSBackup.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Backup);
end;

//------------------------------------------------------------------------------

procedure TVCSBackup.CleanUp;
begin
  Screen.Cursor := crHourGlass;
  lvBackup.Cursor := crHourGlass;
  btnCancel.Enabled := False;
  btnBackup.Enabled := False;
  btnRestore.Enabled := False;
  Caption := JVCSRES_Clean_up44_please_wait464646;
  Timer1.Enabled := True;
end;

//------------------------------------------------------------------------------

procedure TVCSBackup.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSBackup.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Sleep(500);
  // ListView.Columns
  with lvBackup do
  begin
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'Backup_Col1.0', Columns[0].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'Backup_Col1.1', Columns[1].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'Backup_Col1.2', Columns[2].Width);
  end;
  with lvRestore do
  begin
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'Backup_Col2.0', Columns[0].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'Backup_Col2.1', Columns[1].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'Backup_Col2.2', Columns[2].Width);
  end;

  jvcsWriteWindowPosAndSize(sBaseRegistryKey + crbWindows, 'Backup',
      Top, Left, Height, Width);

  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'BackupAutoClose', cbAutoClose.Checked);
  jvcsWriteBool(sBaseRegistryKey + crbOptions, 'BackupActive', cbDoBckUp.Checked);

  Screen.Cursor := crDefault;
end;

//------------------------------------------------------------------------------

procedure TVCSBackup.FormDestroy(Sender: TObject);
begin
  ZipFiles.Free;
  ProjectModules.Free;
  MruListRestorePath.Free;
end;

//------------------------------------------------------------------------------

procedure TVCSBackup.spBtnSelectClick(Sender: TObject);
var
  I: Integer;
begin
  if AllBChecked then
  begin
    with lvBackup do
      for I := 0 to (Items.Count - 1) do
        if (Items[I].StateIndex < 2) then
          Items[I].StateIndex := 0;
    AllBChecked := False;
    spBtnSelect.Hint := JVCSRES_Select_All;
  end
  else
  begin
    with lvBackup do
      for I := 0 to (Items.Count - 1) do
        if (Items[I].StateIndex < 2) then
          Items[I].StateIndex := 1;
    AllBChecked := True;
    spBtnSelect.Hint := JVCSRES_Unselect_All;
  end;
  GetCheckedFiles;
end;

//------------------------------------------------------------------------------

procedure TVCSBackup.spBtnSelectRestoreClick(Sender: TObject);
var
  I: Integer;
begin
  if AllRChecked then
  begin
    with lvRestore do
      for I := 0 to (Items.Count - 1) do
        if (Items[I].StateIndex < 2) then
          Items[I].StateIndex := 0;
    AllRChecked := False;
    spBtnSelectRestore.Hint := JVCSRES_Select_All;
  end
  else
  begin
    with lvRestore do
      for I := 0 to (Items.Count - 1) do
        if (Items[I].StateIndex < 2) then
          Items[I].StateIndex := 1;
    AllRChecked := True;
    spBtnSelectRestore.Hint := JVCSRES_Unselect_All;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSBackup.PageControl1Change(Sender: TObject);
var
  I, i1: Integer;
  SRec: TSearchrec;
  SearchMask: string;
  AbZipArchive: TAbZipArchive;

  procedure AddRLVItem(CurrentModule, CurrDate, CurrSize: string);
  var
    NewItem: TListItem;
  begin
    // Module
    NewItem := lvRestore.Items.Add;
    NewItem.Caption := CurrentModule;
    NewItem.StateIndex := 0;
    // Date
    NewItem.SubItems.Add(CurrDate);
    // Size
    NewItem.SubItems.Add(CurrSize);
  end;
begin
  Application.ProcessMessages;
  HideUncheckedModules1.Enabled := (PageControl1.ActivePage = sheetBackup);
  if PageControl1.ActivePage = sheetRestore then
  begin
    if not BackupSeq then
    begin
      RestoreFile := AnsiLowerCase(BackupPath +
        ChangeFileExt(ExtractFileName(BackupProjectName), '.zip'));
      if FileExists(RestoreFile) then
      begin
        cbxRestoreFile.Items.Clear;
        cbxRestoreFile.Items.Add( ExtractFileName(RestoreFile) + ' | ' +
                                  DateTimeToStr(FileDateToDateTime(GetFileInformation(RestoreFile).Time)));
        cbxRestoreFile.ItemIndex := 0;
        cbxRestoreFile.Enabled := False;
        Screen.Cursor := crHourGlass;
        try
          AbZipArchive := TAbZipArchive.Create(RestoreFile, fmOpenRead or fmShareDenyWrite);
          try
            try
              AbZipArchive.Load;
              lvRestore.Items.BeginUpdate;
              try
                lvRestore.Items.Clear;
                if AbZipArchive.Count <> 0 then
                begin
                  for I := 0 to AbZipArchive.Count - 1 do
                  begin
                    AddRLVItem( AbZipArchive.Items[I].DiskFileName
                              , FormatDateTime('ddddd  t', AbZipArchive.Items[I].LastModTimeAsDateTime)
                              , IntToStr(AbZipArchive.Items[I].UncompressedSize)
                              );                                        
                  end;
                end;
              finally
                lvRestore.Items.EndUpdate;
              end;
            except
              MsgError( Handle
                      , Format( JVCSRES_UnzDLL46dll_Exception58_Cannot_access_zip_file_6037s62
                              , [RestoreFile]
                              )
                      , cMsgBoxCaption
                      );
              btnRestore.Enabled := False;
              Screen.Cursor := crDefault;
              Exit;
            end;
          finally
            AbZipArchive.Free;
          end;
        finally
          Screen.Cursor := crDefault;
          Caption := Format(JVCSRES_VCS_Restore_45_37s, [RestoreFile]);
        end;
      end // if FileExists(RestoreFile) then begin
      else
      begin
        if not ShowRestError then
        begin
          ShowRestError := True;
          MsgInfo ( Handle
                  , Format( JVCSRES_JEDI_VCS_cannot_find_the_Zip_file58_6037s6246 + #13+#10+
                            JVCSRES_There_is_no_recent_backup_available_for_this_project_to_restore_files46
                          , [RestoreFile]
                          )
                  , cMsgBoxCaption
                  );
        end; // if not ShowRestError then begin
        btnRestore.Enabled := False;
        Screen.Cursor := crDefault;
        Caption := Format(JVCSRES_VCS_Restore_45_37s, ['']);
      end; // else if FileExists(RestoreFile) then begin
    end //   if not BackupSeq then
    else 
    begin
      cbxRestoreFile.Items.Clear;
      SearchMask := BackupPath +
        ExtractFileName(ChangeFileExt(BackupProjectName, '')) + '*_???.zip';
      i1 := FindFirst(SearchMask, faAnyFile and (not faDirectory), SRec);
      try
        while i1 = 0 do 
        begin
          if (SRec.Name <> '.') and (SRec.Name <> '..') then 
          begin
            cbxRestoreFile.Items.Add(SRec.Name + ' | ' +
              DateTimeToStr(FileDateToDateTime(SRec.Time)));
          end;
          i1 := FindNext(SRec);
        end;
      finally
        FindClose(SRec);
      end;
      if cbxRestoreFile.Items.Count > 0 then 
      begin
        cbxRestoreFile.ItemIndex := 0;
        cbxRestoreFileChange(Self);
      end;
    end; // if not BackupSeq then
  end // if PageControl1.ActivePage = sheetRestore then begin
  else 
  begin
    GetCheckedFiles;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSBackup.cbxRestoreFileChange(Sender: TObject);
var 
  RestoreFile: string;
  I: Integer;
  AbZipArchive: TAbZipArchive;

  procedure AddRLVItem(CurrentModule, CurrDate, CurrSize: string);
  var
    NewItem: TListItem;
  begin
    // Module
    NewItem := lvRestore.Items.Add;
    NewItem.Caption := CurrentModule;
    NewItem.StateIndex := 0;
    // Date
    NewItem.SubItems.Add(CurrDate);
    // Size
    NewItem.SubItems.Add(CurrSize);
  end;
begin
  RestoreFile := BackupPath + Copy(cbxRestoreFile.Text, 1,
    Pos('|', cbxRestoreFile.Text) - 1);
  if FileExists(RestoreFile) then
  begin
    Screen.Cursor := crHourGlass;
    try
      AbZipArchive := TAbZipArchive.Create(RestoreFile, fmOpenRead or fmShareDenyWrite);
      try
        try
          AbZipArchive.Load;
          lvRestore.Items.BeginUpdate;
          try
            lvRestore.Items.Clear;
            if AbZipArchive.Count <> 0 then
            begin
              for I := 0 to AbZipArchive.Count - 1 do
              begin
                AddRLVItem( AbZipArchive.Items[I].DiskFileName
                          , FormatDateTime('ddddd  t', AbZipArchive.Items[I].LastModTimeAsDateTime)
                          , IntToStr(AbZipArchive.Items[I].UncompressedSize)
                          );
              end;
            end;
          finally
            lvRestore.Items.EndUpdate;
          end;
        except
          MsgError( Handle
                  , Format( JVCSRES_UnzDLL46dll_Exception58_Cannot_access_zip_file_6037s62
                          , [RestoreFile]
                          )
                  , cMsgBoxCaption
                  );
          btnRestore.Enabled := False;
          Screen.Cursor := crDefault;
          Exit;
        end;
      finally
        AbZipArchive.Free;
      end;
    finally
      Screen.Cursor := crDefault;
      Caption := Format(JVCSRES_VCS_Restore_45_37s, [RestoreFile]);
    end;
  end; // if FileExists(RestoreFile) then begin
end;

//------------------------------------------------------------------------------

procedure TVCSBackup.btnRestoreClick(Sender: TObject);
var
  Mess: string;
  nPos, ii, mbIcon, I: Integer;
  bCanRestore: Boolean;
  sMsg, RestoreFile: string;
  AbZipArchive: TAbZipArchive;

  function CheckFilesSelected: Boolean;
  var
    I: Integer;
  begin
    Result := False;
    with lvRestore do
    begin
      for I := 0 to Items.Count - 1 do
      begin
        if Items[I].StateIndex = 1 then
        begin
          Result := True;
          Break;
        end;
      end; // for i := 0 to Items.Count - 1 do begin
    end; // with lvRestore do begin
  end;

begin
  bCanRestore := True;
  // Check if files are selected for restore
  if not CheckFilesSelected then
  begin
    MsgInfo ( WindowHandle
            , JVCSRES_Nothing_to_do46
            , cMsgBoxCaption
            );
    bCanRestore := False;
  end
  else
  if (rcbRestorePath.Text = '') or (not DirectoryExists(rcbRestorePath.Text)) then
  begin
    MsgWarn ( Handle
            , Format( JVCSRES_JEDI_VCS_cannot_find_the_directory58_6037s6246
                    , [rcbRestorePath.Text]
                    )
            , cMsgBoxCaption
            );
    rcbRestorePath.SetFocus;
    bCanRestore := False;
  end else
  begin
    Mess := JVCSRES_Are_you_sure_you_want_to_restore_the_selected_files63;
    mbIcon := MB_ICONQUESTION;
    if rbOverwrite.Checked then
    begin
      Mess := Mess + #13+#10 + JVCSRES_Warning33_Existing_files_will_be_overwritten_without_prompting46;
      mbIcon := MB_ICONWARNING;
    end;
    if not MsgYesNo ( Handle, Mess, cMsgBoxCaption, mbIcon) then
      bCanRestore := False;
  end;
  if not bCanRestore then
    Exit; //!!!

  // Now Restore can be proceeded...
  RestoreFile := BackupPath + Copy( cbxRestoreFile.Text, 1
                                  , Pos('|', cbxRestoreFile.Text) - 1
                                  );
  AbZipArchive := TAbZipArchive.Create(RestoreFile, fmOpenRead or fmShareDenyWrite);
  try

    AbZipArchive.Load;

    // set unzip options
    AbZipArchive.BaseDirectory := rcbRestorePath.Text;
    if rbUseFldNames.Checked then
      AbZipArchive.ExtractOptions := [eoCreateDirs, eoRestorePath]
    else
      AbZipArchive.ExtractOptions := [eoCreateDirs];


    // set event handler
    AbZipArchive.ExtractHelper := AbExtractHelper;
    AbZipArchive.OnConfirmOverwrite := AbOnConfirmOverWrite;
    AbZipArchive.OnArchiveItemProgress := AbOnArchiveItemProgress;
    AbZipArchive.OnArchiveProgress := AbOnArchiveProgress;
    AbZipArchive.OnNeedPassword := AbOnNeedPassword;

    // Tag files for extraction
    with lvRestore do
    begin
      for I := 0 to Items.Count - 1 do
      begin
        if Items[I].StateIndex = 1 then
        begin
          AbZipArchive.TagItems(lvRestore.Items[I].Caption);
        end; // if Items[i].StateIndex = 1 then begin
      end; // for i := 0 to Items.Count - 1 do begin
    end; // with lvRestore do begin

    // Start uncompression
    ProgressBar2.Min := 0;
    ProgressBar2.Max := 100;
    ZipFiles.Clear;
    lbProgress.Clear;
    if ShowProgr then
      PageControl1.ActivePage := SheetInfo;

    Screen.Cursor := crHourGlass;
    try
      AbZipArchive.ExtractTaggedItems;
    except
      MsgError( Handle
              , Format( JVCSRES_UnzDLL46dll_Exception58_Cannot_access_zip_file_6037s62
                      , [RestoreFile]
                      )
              , cMsgBoxCaption
              );
      btnRestore.Enabled := False;
      Screen.Cursor := crDefault;
      Exit;
    end;
    ProgressBar2.Position := 1;
    Screen.Cursor := crDefault;

    // write Log
    lbProgress.Items.BeginUpdate;
    try
      for ii := 0 to AbZipArchive.Count-1 do
      begin
        nPos := ZipFiles.IndexOf(AbZipArchive.Items[ii].DiskFileName);
        if nPos<>-1 then
        begin
          lbProgress.Items.Add(AbZipArchive.Items[ii].DiskFileName);
          sMsg := Format( 'Unzipped file %s of size %d'
                        , [ AbZipArchive.Items[ii].DiskFileName
                          , AbZipArchive.Items[ii].UncompressedSize
                          ]
                        );
          lbProgress.Items.Add(sMsg);
        end;
      end;
    finally
      lbProgress.Items.EndUpdate;
    end;

    // %d file[s] succesfully restored.
    if ShowProgr then
    begin
      lbProgress.Items.Add(FmtLoadStr(304, [ZipFiles.Count]));
      lbProgress.TopIndex := lbProgress.Items.Count - 1;
    end
    else
    begin
      MsgInfo ( Handle
              , Format( JVCSRES_37d_files_successfully_restored46
                      , [ZipFiles.Count]
                      )
              , cMsgBoxCaption
              );
    end;

    with lvRestore do
      for I := 0 to Items.Count - 1 do
        Items[I].StateIndex := 0;

    if rcbRestorePath.Text <> '' then
    begin
      if Assigned(MruListRestorePath) then
        MruListRestorePath.AddString(rcbRestorePath.Text);
      rcbRestorePath.Items.Insert(0, rcbRestorePath.Text);
    end;
  finally
    AbZipArchive.Free;
    ProgressBar1.Position := 0;
    ProgressBar2.Position := 0;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSBackup.spBtnBrowseClick(Sender: TObject);
begin
  VCSSelectFolder := TVCSSelectFolder.Create(Application);
  try
    // Base restore folder:
    VCSSelectFolder.SetStatusText(LoadStr(306));
    VCSSelectFolder.EnableRecursive(False);
    VCSSelectFolder.HelpContextID := IDH_Backup;
    if rcbRestorePath.Text <> '' then 
      VCSSelectFolder.SetInitialDir(rcbRestorePath.Text);
    VCSSelectFolder.ShowModal;
    if VCSSelectFolder.Selection <> '' then 
    begin
      rcbRestorePath.Text := SetBackSlash(AnsiLowerCase(VCSSelectFolder.Selection));
    end; // if VCSSelectFolder.Selection <> '' then begin
  finally
    VCSSelectFolder.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSBackup.lvBackupMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var 
  HitTest: THitTests;
  HitItem: TListItem;
begin
  HitTest := lvBackup.GetHitTestInfoAt(X, Y);
  if (Button = mbLeft) and (htOnStateIcon in HitTest) then 
  begin
    HitItem := lvBackup.GetItemAt(X, Y);
    if HitItem.StateIndex > 1 then 
      Exit;
    if HitItem.StateIndex = 0 then 
      HitItem.StateIndex := 1 
    else 
      HitItem.StateIndex := 0;
    GetCheckedFiles;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSBackup.lvRestoreMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var 
  HitTest: THitTests;
  HitItem: TListItem;
begin
  HitTest := lvRestore.GetHitTestInfoAt(X, Y);
  if (Button = mbLeft) and (htOnStateIcon in HitTest) then 
  begin
    HitItem := lvRestore.GetItemAt(X, Y);
    if HitItem.StateIndex > 1 then 
      Exit;
    if HitItem.StateIndex = 0 then 
      HitItem.StateIndex := 1 
    else 
      HitItem.StateIndex := 0;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSBackup.spBtnCopyClipbrdClick(Sender: TObject);
var 
  I: Integer;
  ResultStr: string;
const
  cr = Chr(13) + Chr(10);
begin
  ResultStr := '';
  for I := 0 to lbProgress.Items.Count - 1 do
    ResultStr := ResultStr + lbProgress.Items[I] + cr;
  try
    ClipBoard.SetTextBuf(PChar(ResultStr));
  except
    MsgError( WindowHandle
            , JVCSRES_Cannot_access_clipboard46
            , cMsgBoxCaption
            );
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSBackup.lvBackupKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (lvBackup.Selected <> nil) and (Key = VK_SPACE) then
  begin
    if lvBackup.Selected.StateIndex > 1 then
      Exit;
    if lvBackup.Selected.StateIndex = 0 then
      lvBackup.Selected.StateIndex := 1
    else
      lvBackup.Selected.StateIndex := 0;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSBackup.lvRestoreKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (lvRestore.Selected <> nil) and (Key = VK_SPACE) then
  begin
    if lvRestore.Selected.StateIndex > 1 then
      Exit;
    if lvRestore.Selected.StateIndex = 0 then
      lvRestore.Selected.StateIndex := 1
    else
      lvRestore.Selected.StateIndex := 0;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSBackup.HelpClick(Sender: TObject);
var
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSBackup.HideUncheckedModules1Click(Sender: TObject);
var
  I: Integer;
begin
  UseRegistry := True;
  DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;

 if DSAIdentsMessageDlg ( JVCSRES_All_unchecked_items_will_be_invisible_until_you_reopen_the_dialog46 + #13+#10+
                          JVCSRES_Are_you_sure_you_want_to_remove_unchecked_items_from_the_list63
                        , mtConfirmation
                        , [mbYes, mbNo, mbCancel]
                        , 0
                        , sBaseRegistryKey + crbMRU + 'Dlgs'
                        , 'HideSyncFile'
                        , idYes
                        ) <> idYes then
    Exit;
  I := 0;
  lvBackup.Items.BeginUpdate;
  try
    while I < lvBackup.Items.Count do
    begin
      if lvBackup.Items[I].StateIndex <> 1 then
        lvBackup.Items[I].Delete
      else
        Inc(I);
    end;
  finally
    lvBackup.Items.EndUpdate;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSBackup.KillOldBackups(Project: string; FreshDate: Double);
var
  SRec: TSearchrec;
  KeepBackup, SearchMask: string;
  KeepDate, i1: Integer;
  SavedDate, GottenDate: Longint;
  SL1: TStringList;

  function DayNum(Indate: TDatetime): Integer;
  var
    Y, M, D: Word;
    LeapYearAdj: Integer;
  const
    MthEndAdj: array [1..12] of Integer = (0,1,0,1,1,2,2,3,4,4,5,5);
  begin
    DecodeDate(Indate, Y, M, D);
    if (M < 3) or ((Y mod 4) <> 0) then
      LeapYearAdj := -1
    else
      LeapYearAdj := 0;
    DayNum := (Y - 95) * 365 + ((Y - 93) div 4) + (M - 1) * 30 + MthEndAdj[M] +
      LeapYearAdj + D;
  end;
begin
  {fetch saved date}
  SavedDate := DayNum(Date) - Round(FreshDate);

  SearchMask := BackupPath +
    ExtractFileName(ChangeFileExt(Project, '')) + '*_???.zip';

  {start filecheck}
  SL1 := TStringList.Create;
  try
    KeepDate := Low(Integer);
    i1 := FindFirst(SearchMask, faAnyFile and (not faDirectory), SRec);
    try
      while i1 = 0 do
      begin
        if (SRec.Name <> '.') and (SRec.Name <> '..') then
        begin
          Inc(OldSeqBackup);
          if SRec.Time > KeepDate then
          begin
            KeepDate := SRec.Time;
            KeepBackup := BackupPath + SRec.Name;
          end;
          GottenDate := DayNum(FileDateToDateTime(SRec.Time));
          if GottenDate <= SavedDate then
            SL1.Add(BackupPath + SRec.Name);
        end;{if srecname}
        i1 := FindNext(SRec);
      end;{while}
    finally
      FindClose(SRec);
    end;{try ffirst}
    {now nuke files}
    for i1 := 0 to (SL1.Count - 1) do
      if KeepBackup <> SL1[i1] then
      begin
        DeleteToRecycleBin(WindowHandle, SL1[i1]);
        Inc(DelSeqBackup);
      end;
  finally
    SL1.Free;
  end;{try sl1}
end;

//------------------------------------------------------------------------------

procedure TVCSBackup.btnCancelClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSBackup.cbDoBckUpClick(Sender: TObject);
begin
  if (not FCreating) and SettingIsGlobal(8) and
    (cbDoBckUp.Checked <> GlobalSettingValue(8)) then
  begin
    ShowGlobalSettingsWarning(WindowHandle, GlobalSettingValue(8));
    cbDoBckUp.Checked := GlobalSettingValue(8);
    Exit;
  end;
end;


procedure TVCSBackup.AbBackup(const sZipFile: string; var CompressedFiles: Integer);
var
  AbArchive: TAbZipArchive;
  ii, nPos: Integer;
  sMsg: string;
begin
  Assert(Trim(sZipFile)<>'');

  AbArchive := TAbZipArchive.Create(sZipFile, fmCreate or fmShareDenyNone);
  try
    // set compression method, need translation from old value of Z i pMaster
    AbArchive.CompressionMethodToUse := smDeflated;
    case ZipLevel of
      2:  AbArchive.DeflationOption := doFast;
      5:  AbArchive.DeflationOption := doNormal;
    else
      AbArchive.DeflationOption := doMaximum;
    end;

    // Set Password, if Empty Zip is not password encrypted
    AbArchive.Password := ZipPassword;

    // now the event handlers
    AbArchive.InsertHelper := AbInsertHelper;
    AbArchive.OnArchiveProgress := AbOnArchiveProgress;
    AbArchive.OnArchiveItemProgress := AbOnArchiveItemProgress;

    ZipFiles.Clear;

    // add selected files ListView
    with lvBackup do
    begin
      for ii := 0 to Items.Count - 1 do
      begin
        if Items[ii].StateIndex = 1 then
        begin
          AbArchive.AddFiles(Items[ii].SubItems[0] + Items[ii].Caption, 0);

          //TODO - to early, should be set after zip file was written
          FileSetAttr(Items[ii].SubItems[0] + Items[ii].Caption,
            FileGetAttr(Items[ii].SubItems[0] + Items[ii].Caption) and not faArchive);
          Inc(CompressedFiles);
        end;
      end; // for ii := 0 to Items.Count - 1 do begin
    end; // with lvBackup do begin

    try
      // and store to disk, this does the real compression
      AbArchive.Save;

      // write Log...
      lbProgress.Items.BeginUpdate;
      try
        for ii := 0 to AbArchive.Count-1 do
        begin
          nPos := ZipFiles.IndexOf(AbArchive.Items[ii].DiskFileName);
          if nPos<>-1 then
          begin
            lbProgress.Items.Add(AbArchive.Items[ii].DiskFileName);
            sMsg := Format( '    deflated in=%d, out=%d, ratio=%2.0f%%'
                          , [ AbArchive.Items[ii].UncompressedSize
                            , AbArchive.Items[ii].CompressedSize
                            , AbArchive.Items[ii].CompressionRatio
                            ]
                          );
            lbProgress.Items.Add(sMsg);
          end;
        end;
      finally
        lbProgress.Items.EndUpdate;
      end;
    finally
      ZipFiles.Clear;
    end;
  finally
    AbArchive.Free;
  end;
end;

//------------------------------------------------------------------------------
// Necessary Zip-Handler for TZipArchiver
procedure TVCSBackup.AbExtractHelper(Sender: TObject; Item: TAbArchiveItem; const NewName: string);
begin
  AbUnzip(Sender, TAbZipItem(Item), NewName);
  ZipFiles.Add(Item.DiskFileName);
end;

//------------------------------------------------------------------------------
// Necessary Zip-Handler for TZipArchiver
procedure TVCSBackup.AbInsertHelper(Sender: TObject; Item: TAbArchiveItem; OutStream: TStream);
begin
  AbZip(TAbZipArchive(Sender), TAbZipItem(Item), OutStream);
  ZipFiles.Add(Item.DiskFileName);
end;

//------------------------------------------------------------------------------
// Archive progressor
procedure TVCSBackup.AbOnArchiveProgress(Sender: TObject; Progress: Byte; var Abort: Boolean);
begin
  ProgressBar2.Position := Progress;
end;

//------------------------------------------------------------------------------
// Item progressor
procedure TVCSBackup.AbOnArchiveItemProgress( Sender: TObject; Item: TAbArchiveItem;
                                        Progress: Byte; var Abort: Boolean);
begin
  ProgressBar1.Min := 0;
  ProgressBar1.Max := 100;
  ProgressBar1.Position := Progress;
end;

//------------------------------------------------------------------------------
// Overwrite event handler
procedure TVCSBackup.AbOnConfirmOverWrite(var Name: string; var Confirm: Boolean);
begin
  Confirm := rbOverwrite.Checked;
end;

//------------------------------------------------------------------------------
// Overwrite event handler
procedure TVCSBackup.AbOnNeedPassword(Sender: TObject; var NewPassword: string);
var
  Dlg: TPassWordDlg;
begin
  if NewPassword = '' then
  begin
    Dlg := TPassWordDlg.Create( Application );
    try
      Dlg.Edit1.Text := '';
      Dlg.Edit2.Text := '';
      Dlg.ShowModal;
      if Dlg.ModalResult = mrOK then
        NewPassword := Dlg.Edit1.Text;
    finally
      Dlg.Free;
    end;
  end;
end;

end.
