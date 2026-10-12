(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: Distribution.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS: Thomas Huber (Thomas_D_Huber@gmx.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber     - 1st Migrationstep from FreeVCS code to JEDI VCS
2003/02/18  MGosselink - emptied some .text props
2003/03/05  THensle    - changes for "ConfigStorage" unit
2003/03/08  USchuster  - exchanged THistoryList and TjvMruList with
                         TJVCSMruList (mantis #727)
2003/03/09  USchuster  - removed rcbxTargetFile.AutoSave.SaveValue
                       - the TargetFileName will also be inserted into the
                         combobox now
2003/12/28  USchuster  - changed JEDI-VCS to JEDI VCS in unit header and
                         message boxes (use constant)
                       - AutoComplete in ComboBox now False
2004/02/24  THuber     - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/09/17  FHasovic   - Added dxGetText support for localization
2004/10/30  USchuster  - style cleaning
                       - localization of Fikret Hasovic from newideas project
                         with over IFDEF LANGUAGE
                       - res strings and displayed strings changed to resourcestrings
2004/11/05  USchuster  - moved resourcestrings to JVCSGUIClientResources.pas
2005/03/26  USchuster  - migration from ZipMaster to Abbrevia and added path
                         information support (mantis #2782)
2005/03/28  USchuster  - made it compatible with latest HandleBlob.pas                         
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 final released ^^^^^^^^^^^^^^^^^^^^^^^^^^
2006/04/30  THuber    #3611 config folder now windows user dependend (appdata shell folder)
2007/06/30  USchuster  - changes for large fonts (contraints and default size depend now on PixelsPerInch; analog to Mantis #3710)
2008/12/22  THuber     - Baseclass changed to TJVCSForm
2009/01/01  USchuster  - changes for D2009
2009/12/28  THuber    - added JVCSClientConsts to uses (as some consts were moved from VCSBase there)
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit Distribution;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ImgList, Buttons, ExtCtrls, JvCombobox,
  JVCSMruList, JvExStdCtrls, JVCSForms;

type
  TVCSDistribution = class(TJVCSForm)
    SysImageList: TImageList;
    lvModules: TListView;
    Panel1: TPanel;
    spBtnDelete: TSpeedButton;
    spBtnAdd: TSpeedButton;
    spBtnHelp: TSpeedButton;
    btnCreate: TButton;
    bntClose: TButton;
    spBtnBrowse: TSpeedButton;
    cbIncludeFolder: TCheckBox;
    Label1: TLabel;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    spBtnCheck: TSpeedButton;
    spBtnResult: TSpeedButton;
    rcbxTargetFile: TJvComboBox;
    procedure FormCreate(Sender: TObject);
    procedure spBtnAddClick(Sender: TObject);
    procedure btnCreateClick(Sender: TObject);
    procedure spBtnBrowseClick(Sender: TObject);
    procedure rcbxTargetFileChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure spBtnCheckClick(Sender: TObject);
    procedure bntCloseClick(Sender: TObject);
    procedure spBtnDeleteClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormActivate(Sender: TObject);
    procedure spBtnResultClick(Sender: TObject);
    procedure spBtnHelpClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    bCompressBackup,
    CustomFiles: Boolean;
    MruListTargetFile: TJVCSMruList;
    procedure SetupListBox;
    procedure CompressionAddProgress(Sender: TObject);
  public
    { Public declarations }
  end;

var
  VCSDistribution: TVCSDistribution;

implementation

{$R *.dfm}

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSBase, VCSProcBase, JVCSClientConsts, DBModule, ShellAPI, CommCtrl, FavOpenDialog,
  Progress, HandleBlob, CheckfBuild, LoadModule, ConfigStorage, JVCSGUIClientResources,
  JVCSClientObjBase, JVCSDialogs;

procedure TVCSDistribution.FormCreate(Sender: TObject);
var
  sfi: TSHFileInfo;
  ToolTipHandle: HWND;
  DlgTop,
  DlgLeft,
  DlgWidth,
  DlgHeight: Integer;
begin
  try
    Constraints.MinHeight := MulDiv(300, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(360, PixelsPerInch, 96);
    VCSProgress := nil;
    // ListView Tooltips
    SendMessage(lvModules.Handle, LVM_SETEXTENDEDLISTVIEWSTYLE, LVS_EX_INFOTIP,
      LVS_EX_INFOTIP);
    ToolTipHandle := SendMessage(lvModules.Handle, LVM_GETTOOLTIPS, 0, 0);
    SendMessage(ToolTipHandle, TTM_SETDELAYTIME, TTDT_AUTOMATIC, 1);
    SendMessage(ToolTipHandle, TTM_SETDELAYTIME, TTDT_AUTOPOP, 3000);

    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    if not jvcsReadWindowPosAndSize(sBaseRegistryKey + crbWindows, 'Distribition',
      DlgTop, DlgLeft, DlgWidth, DlgHeight) then
    begin
      DlgTop := (Screen.Height - Height) div 2;
      DlgLeft := (Screen.Width - Width) div 2;
      DlgWidth := MulDiv(360, PixelsPerInch, 96);
      DlgHeight := MulDiv(300, PixelsPerInch, 96);
    end;
    Top := DlgTop;
    Left := DlgLeft;
    Width := DlgWidth;
    Height := DlgHeight;

    with lvModules do
    begin
      Columns[0].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'Distribition_Col1.0', 130);
      Columns[1].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'Distribition_Col1.1', 60);
      Columns[2].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'Distribition_Col1.2', 100);
    end;
    {$IFNDEF SHOWIDS}
    lvModules.Columns[3].Width := 0;
    lvModules.Columns[4].Width := 0;
    {$ENDIF ~SHOWIDS}

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

    CustomFiles := False;
    MruListTargetFile := TJVCSMruList.CreateEx(sBaseRegistryKey + crbMRU + '27');
    rcbxTargetFile.Items.Assign(MruListTargetFile);
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSDistribution.SetupListBox;
var
  I, ModuleID: Integer;
  AddFileName, CurrentFileBase, CurrentFile, CurrentPath: string;
  AddFileNames: TStringList;
  FExists: Boolean;
  LVItem: TListItem;
  sfi: TSHFileInfo;
begin
  //  lblScanResult.Caption := 'Scanning version archive...';
  with DataModule1 do
  begin
    //--- get revisions --------------------------------------------------------
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_LATEST_REVISIONS';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [ServerProjectID]);
    AppSrvClient1.Request.WriteFields(False, [True]);
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
      //      lblScanResult.Caption := 'Error...';
      Exit;
    end;

    Screen.Cursor := crHourGlass;
    lvModules.Items.BeginUpDate;
    try
      lvModules.Items.Clear;
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

        while (not AppSrvClient1.Answer.Eof) and
          (ModuleID = _StrToInt(AppSrvClient1.Answer.Fields[0])) do 
        begin
          CurrentFile :=
            ChangeFileExt(CurrentFileBase, TrimRight(AppSrvClient1.Answer.Fields[7]));
          FExists := FileExists(CurrentPath + CurrentFile);
          // NewItem
          LVItem := lvModules.Items.Add;
          // File
          if FExists then
            LVItem.Caption :=
              ExtractFileName(GetOriginalFileName(CurrentPath + CurrentFile))
          else
            LVItem.Caption := CurrentFile;
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
          // Path
          LVItem.SubItems.Add(CurrentPath);
          // Module ID
          LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[0]);
          // Revision ID
          LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[3]);
          AppSrvClient1.Answer.Next;
        end; // while (not Answer.EoF) and....
      end; // while not AppSrvClient1.Answer.EoF do begin
    finally
      lvModules.Items.EndUpDate;
    end;
  end; // with DataModule1 do begin


  AddFileName := sConfigFolder + ChangeFileExt(ExtractFileName(sProjectName), '.sdl');
  if FileExists(AddFileName) then
  begin
    AddFileNames := TStringList.Create;
    try
      try
        AddFileNames.LoadFromFile(AddFileName);
      except
        on E: 
        Exception do 
        begin
          BeepIfSet;
          MessageBox(Handle, PChar(Format(JVCSRES_Reading_file_6037s62 + #13#10 +
            JVCSRES_raised_exception58 + #13#10 + '%s.', [AddFileName, E.Message])),
            cMsgBoxCaption, MB_OK or MB_ICONSTOP);
          Exit;
        end;
      end;
      for I := 0 to AddFileNames.Count - 1 do 
      begin
        CurrentFile := ExtractFileName(AddFileNames.Strings[I]);
        CurrentPath := ExtractFilePath(AddFileNames.Strings[I]);
        FExists := FileExists(CurrentPath + CurrentFile);
        if FExists then 
        begin
          // NewItem
          LVItem := lvModules.Items.Add;
          // File
          LVItem.Caption := CurrentFile;
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
          LVItem.SubItems.Add('-.-');
          // Path
          LVItem.SubItems.Add(LowerCase(CurrentPath));
          // Module ID
          LVItem.SubItems.Add('-1');
          // Revision ID
          LVItem.SubItems.Add('-1');
        end; // if FExists then begin
      end;
    finally
      AddFileNames.Free;
    end;
  end; // if FileExists(PCFFileName) then begin

  Screen.Cursor := crDefault;
end;

//------------------------------------------------------------------------------

procedure TVCSDistribution.spBtnAddClick(Sender: TObject);
var 
  CustomFilter, Filter1, Filter2: string;
  I: Integer;
  CurrentFile, CurrentPath: string;
  FExists: Boolean;
  LVItem: TListItem;
  sfi: TSHFileInfo;
  DlgResult: Boolean;
  FavOpenDialog: TFavOpenDialog;
begin
  Filter1 :=
    jvcsReadString(sBaseRegistryKey + crbFilters, 'Delphi files', dfDelphiMod);
  Filter2 :=
    jvcsReadString(sBaseRegistryKey + crbFilters, 'AddProjectFiles', dfAddMod);

  FavOpenDialog := TFavOpenDialog.Create(Application);
  try
    with FavOpenDialog do
    begin
      Scaled := False;
      Title := JVCSRES_Add_external_files;
      Options := [ofHideReadOnly, ofAllowMultiSelect, ofPathMustExist,
        ofFileMustExist, ofEnableSizing];
      InitialDir := ExtractFilePath(GetCurrentDir);
      FileName := '';
      {$IFDEF IDEDLL}
      Filter := Format(JVCSRES_37s_source_files_4037s4112437s, [sIDEName, Filter1, Filter1]) +
        '|' + Format(JVCSRES_Other_source_files_4037s4112437s, [Filter2, Filter2]) +
        '|' + JVCSRES_All_files_4042464241124424642;
      {$ELSE}
      Filter := JVCSRES_All_files_4042464241124424642 +
        '|' + Format(JVCSRES_37s_source_files_4037s4112437s, [sIDEName, Filter1, Filter1]) +
        '|' + Format(JVCSRES_Other_source_files_4037s4112437s, [Filter2, Filter2]);
      {$ENDIF IDEDLL}
      I := 0;
      repeat
        Inc(I);
        CustomFilter :=
          jvcsReadString(sBaseRegistryKey + crbFilters + '\Custom', 'Custom' + IntToStr(I), '');
        if (CustomFilter <> '') then
        begin
          Filter := Filter + '|' + Copy(CustomFilter, 1, Pos('|', CustomFilter) - 1);
          System.Delete(CustomFilter, 1, Pos('|', CustomFilter));
          Filter := Filter + ' (' + CustomFilter + ')|' + CustomFilter;
        end;
      until (CustomFilter = '');

      FilterIndex :=
        jvcsReadInteger(sBaseRegistryKey + crbMRU, 'FileDlgFI', 1);

      DlgResult := ExecuteFavOpenDialogWithMru(FavOpenDialog,
        sBaseRegistryKey + crbMRU + '18');

      jvcsWriteInteger(sBaseRegistryKey + crbMRU, 'FileDlgFI', FilterIndex);
    end; // with FavOpenDialog1 do begin

    if DlgResult then
    begin
      try
        Screen.Cursor := crHourGlass;
        // Add the files
        for I := 0 to FavOpenDialog.Files.Count - 1 do
        begin
          CustomFiles := True;
          CurrentFile := ExtractFileName(FavOpenDialog.Files[I]);
          CurrentPath := ExtractFilePath(FavOpenDialog.Files[I]);

          FExists := FileExists(CurrentPath + CurrentFile);
          // NewItem
          LVItem := lvModules.Items.Add;
          // File
          LVItem.Caption := CurrentFile;
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
          LVItem.SubItems.Add('-.-');
          // Path
          LVItem.SubItems.Add(LowerCase(CurrentPath));
          // Module ID
          LVItem.SubItems.Add('-1');
          // Revision ID
          LVItem.SubItems.Add('-1');
        end;
      finally
        Screen.Cursor := crDefault;
      end;
    end; // if DlgResult then begin
  finally
    FavOpenDialog.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSDistribution.btnCreateClick(Sender: TObject);
var
  RootDir, TMPDirectory, ActDir, FileName, ModulePath, TargetFile, TargetFileName, ModuleID,
  RevisionID, Mess, ErrMsg: string;
  AffectedFiles: TStringList;
  RevisionNumbers, ArchiveFiles: TStringList;
  FuncRes, I, J, SuccessCount: Integer;
  ShellInfo: {$IFDEF COMPILER12_UP}TSHFileOpStructW {$ELSE}TSHFileOpStructA {$ENDIF};
  CompressionOkay, ExceptionInCompression: Boolean;
  StripPath, StripPathOptionOkay: Boolean;
begin
  StripPath := not cbIncludeFolder.Checked;
  StripPathOptionOkay := True;
  if StripPath then
  begin
    ArchiveFiles := TStringList.Create;
    try
      ArchiveFiles.Sorted := True;
      for I := 0 to Pred(lvModules.Items.Count) do
        if ArchiveFiles.IndexOf(lvModules.Items[I].Caption) = -1 then
          ArchiveFiles.Add(lvModules.Items[I].Caption)
        else
        begin
          StripPathOptionOkay := False;
          Break;
        end;
    finally
      ArchiveFiles.Free;
    end;
  end;

  if not StripPathOptionOkay then
  begin
    WarnMessageBox(JVCSRES_It_is_not_possible_to_create_the_source_distribution_file_without_path_information44 + #13
      + JVCSRES_because_the_current_project_contains_at_least_one_file_with_the_same_name_in_different_paths46 + #13#13
      + JVCSRES_34Include_path_information34_will_be_enabled_now_in_order_to_create_the_source_distribution_file_for_this_project46);
    cbIncludeFolder.Checked := True;
    StripPath := not cbIncludeFolder.Checked;    
  end;

  TargetFileName := rcbxTargetFile.Text;
  GetDir(0, ActDir);
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
      MessageBox(WindowHandle, PChar(JVCSRES_JEDI_VCS_cannot_detect_the_name_of_the_local_temporary_directory46 + #13#10 +
        JVCSRES_Try_to_define_a_temporary_directory_in_34Properties124Folders34_and_retry46),
        cMsgBoxCaption, MB_OK or MB_ICONWARNING);
      Exit;
    end;
    SetLength(TMPDirectory, StrLen(PChar(TMPDirectory)));
  end; // if TMPDirectory = '' then begin

  RootDir := TMPDirectory + '_' + 'source' + '_';

  RevisionNumbers := TStringList.Create;
  ArchiveFiles := TStringList.Create;
  try
    VCSProgress := TVCSProgress.Create(Self);
    VCSProgress.SetText(JVCSRES_Project_backup_45_collecting_revisions464646);
    VCSProgress.SetPBMax(lvModules.Items.Count);
    VCSProgress.SetPBPos(0);
    VCSProgress.Left := Left + 40;
    VCSProgress.Top := Top + 60;
    VCSProgress.Show;
    Application.ProcessMessages;
    for I := 0 to lvModules.Items.Count - 1 do
    begin
      if lvModules.Items[I].SubItems[0] <> '-.-' then
      begin
        RevisionID := lvModules.Items[I].SubItems[3];
        if RevisionNumbers.IndexOf(RevisionID) = -1 then
          RevisionNumbers.Add(RevisionID);
      end;
      VCSProgress.SetPBPos(I);
    end; // for I := 0 to TreeView1.Items.Count - 1 do begin

    VCSProgress.SetText(JVCSRES_Project_backup_45_get_revisions464646);
    VCSProgress.SetPBMax(RevisionNumbers.Count);
    VCSProgress.SetPBPos(0);
    VCSProgress.Show;
    Application.ProcessMessages;
    AffectedFiles := TStringList.Create;
    try
      for I := 0 to RevisionNumbers.Count - 1 do
      begin
        with DataModule1 do
        begin
          AppSrvClient1.Request.Rewrite;
          AppSrvClient1.FunctionCode := 'GET_REVISION_STATUS';
          AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
          AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
          AppSrvClient1.Request.WriteFields(True, [RevisionNumbers.Strings[I]]);
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
            ModuleID := AppSrvClient1.Answer.Fields[0];
            FileName := AppSrvClient1.Answer.Fields[1];
            {$IFDEF CUSTOMDRIVE}
            ModulePath := ChangeDriveName(AppSrvClient1.Answer.Fields[2], sDriveSubst);
            {$ELSE}
            ModulePath := AppSrvClient1.Answer.Fields[2];
            {$ENDIF CUSTOMDRIVE}
          end;
        end; // with DataModule1 do begin


        Delete(ModulePath, 1, Length(ExtractFileDrive(ModulePath)));
        TargetFile := RootDir + ModulePath + FileName;

        FuncRes := GetBlobsEx(DBModule.GetJvcsConnection, ServerProjectID, ServerUserID,
          StrToIntDef(ModuleID, 0), StrToIntDef(RevisionNumbers.Strings[I], 0),
          False{CheckOut}, Application, Self,
          False{SetReadOnly}, False{CloseIDEView},
          False{SetCurrentDate},
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
          MessageBox(WindowHandle,
            PChar(Format('<%s>' + #13#10 +
              JVCSRES_JEDI_VCS_is_unable_to_create_a_local_copy_of_this_file46 + #13#10 +
              JVCSRES_Exception58_37s_in_37s46_, [TargetFile, ErrMsg, Mess])),
            cMsgBoxCaption, MB_OK or MB_ICONSTOP);
          Exit;
        end // if FuncRes <> 0 then begin
        else
        begin
          for J := 0 to Pred(AffectedFiles.Count) do
            if ArchiveFiles.IndexOf(AffectedFiles[J]) = -1 then
              ArchiveFiles.Add(AffectedFiles[J]);
        end;
        VCSProgress.SetPBPos(I);
      end; // for I := 0 to RevisionNumbers.Count - 1 do begin
    finally
      AffectedFiles.Free;
    end;

    VCSProgress.SetText(JVCSRES_Project_backup_45_compress_backup464646);
    VCSProgress.SetPBMax(ArchiveFiles.Count);
    VCSProgress.SetPBPos(0);
    Application.ProcessMessages;

    bCompressBackup := True;

    for I := 0 to lvModules.Items.Count - 1 do
    begin
      if (lvModules.Items[I].SubItems[0] = '-.-') and
        (ArchiveFiles.IndexOf(lvModules.Items[I].SubItems[1] +
          lvModules.Items[I].Caption) = -1) then
        ArchiveFiles.Add(lvModules.Items[I].SubItems[1] +
          lvModules.Items[I].Caption);
    end; // for I := 0 to TreeView1.Items.Count - 1 do begin

    try
      CompressionOkay := JVCSCompressFileList(ArchiveFiles, RootDir, TargetFileName,
        StripPath, SuccessCount, CompressionAddProgress);
      ExceptionInCompression := False;
    except
      BeepIfSet;
      CompressionOkay := False;
      ExceptionInCompression := True;
      MessageBox(Handle, PChar(Format(JVCSRES_Unable_to_add_backup_files_to + #13#10 +
        '<%s>.' + #13#10 + JVCSRES_Perhaps_the_ZIP_is_corrupt46, [TargetFileName])),
        cMsgBoxCaption, MB_OK or MB_ICONSTOP);
    end;
    bCompressBackup := False;
  finally
    VCSProgress.Free;
    VCSProgress := nil;
    RevisionNumbers.Free;
    ArchiveFiles.Free;
  end;

  Application.ProcessMessages;
  if RootDir[Length(RootDir)] = '\' then
    Delete(RootDir, Length(RootDir), 1);
  if RootDir[Length(RootDir)] <> ':' then 
  begin
    RootDir := RootDir + #0 + #0;
    with ShellInfo do 
    begin
      Wnd := Handle;
      WFunc := FO_DELETE;
      pFrom := PChar(RootDir);
      pTo := #0;
      fFlags := FOF_NOCONFIRMATION;
      lpszProgressTitle := PChar(JVCSRES_Removing_temporary_files464646);
    end;
    SHFileOperation(ShellInfo);
  end; // if RootDir[Length(RootDir)] <> ':' then begin
  ChDir(ActDir);
  if CompressionOkay then
    MessageBox(WindowHandle,
      PChar(Format('<%s>' + #13#10 +
        JVCSRES_Archive_file_successfully_created_4037d_files4146,
        [rcbxTargetFile.Text, SuccessCount])),
      cMsgBoxCaption, MB_OK or MB_ICONINFORMATION)
  else
  if not ExceptionInCompression then
    MessageBox(Handle, PChar(Format(JVCSRES_Unable_to_add_backup_files_to + #13#10 +
      '<%s>.' + #13#10 + JVCSRES_Perhaps_the_ZIP_is_corrupt46, [TargetFileName])),
      cMsgBoxCaption, MB_OK or MB_ICONSTOP);
  spBtnResult.Enabled := True;
end;

//------------------------------------------------------------------------------

procedure TVCSDistribution.spBtnBrowseClick(Sender: TObject);
begin
  with SaveDialog1 do 
  begin
    Title := JVCSRES_Save_source_distribution;
    Options := [ofHideReadOnly, ofPathMustExist, ofEnableSizing];
    if ExtractFilePath(rcbxTargetFile.Text) <> '' then
      InitialDir := ExtractFilePath(rcbxTargetFile.Text)
    else
      InitialDir := ExtractFilePath(GetCurrentDir);
    FileName := rcbxTargetFile.Text;
    if Execute then
      rcbxTargetFile.Text := LowerCase(FileName);
    MruListTargetFile.AddString(rcbxTargetFile.Text);
    rcbxTargetFile.Items.Insert(0, rcbxTargetFile.Text);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSDistribution.rcbxTargetFileChange(Sender: TObject);
begin
  btnCreate.Enabled := (rcbxTargetFile.Text <> '');
end;

//------------------------------------------------------------------------------

procedure TVCSDistribution.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  jvcsWriteWindowPosAndSize(sBaseRegistryKey + crbWindows, 'Distribition',
    Top, Left, Width, Height);

  with lvModules do
  begin
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'Distribition_Col1.0',
      Columns[0].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'Distribition_Col1.1',
      Columns[1].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'Distribition_Col1.2',
      Columns[2].Width);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSDistribution.spBtnCheckClick(Sender: TObject);
begin
  VCSCheckfBuild := TVCSCheckfBuild.Create(Application);
  try
    VCSCheckfBuild.Top := Top + 60;
    VCSCheckfBuild.Left := Left + 60;
    VCSCheckfBuild.ShowModal;
  finally
    VCSCheckfBuild.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSDistribution.bntCloseClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSDistribution.spBtnDeleteClick(Sender: TObject);
begin
  if lvModules.Selected <> nil then 
  begin
    lvModules.Selected.Delete;
    CustomFiles := True;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSDistribution.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var 
  AddFileName: string;
  I: Integer;
  AddFileNames: TStringList;
begin
  CanClose := False;
  if CustomFiles then 
  begin
    case MessageBox(Handle, PChar(JVCSRES_You_have_added_or_changed_custom_files_to_the_list46 + #13#10 +
      JVCSRES_Save_these_files_and_and_restore_the_list_the_next_time_you_open_the_dialog63),
      cMsgBoxCaption, MB_YESNOCANCEL or MB_ICONQUESTION) of
      idYes:
        begin
          AddFileName := sConfigFolder + ChangeFileExt(ExtractFileName(sProjectName), '.sdl');
          AddFileNames := TStringList.Create;
          try
            for I := 0 to lvModules.Items.Count - 1 do 
            begin
              if lvModules.Items[I].SubItems[0] = '-.-' then
                AddFileNames.Add(lvModules.Items[I].SubItems[1] +
                  lvModules.Items[I].Caption);
            end;
            try
              AddFileNames.SaveToFile(AddFileName);
            except
              MessageBox(WindowHandle, PChar(Format(JVCSRES_JEDI_VCS_cannot_save_the_file + #13#10 +
                '<%s>.' + #13#10 +
                JVCSRES_Be_sure_that_the_file_is_not_opened_by_another_application44 + #13#10 +
                JVCSRES_that_there_is_enough_free_space_on_the_disk + #13#10 +
                JVCSRES_and_that_you_have_the_required_access_rights46,
                [AddFileName])), cMsgBoxCaption, MB_OK or MB_ICONSTOP);
            end;
          finally
            AddFileNames.Free;
          end;
        end;
      idNo:;
      else
        Exit;
    end;
  end;
  CanClose := True;
end;

//------------------------------------------------------------------------------

procedure TVCSDistribution.FormActivate(Sender: TObject);
var 
  Year, Month, Day: Word;
  sMonth, sDay: string;
begin
  if Assigned(VCSProgress) then
    SetForeGroundWindow(VCSProgress.Handle);
  if lvModules.Items.Count > 0 then 
    Exit;
  Update;
  Application.ProcessMessages;
  SetupListBox;
  // TargetFileName
  DecodeDate(Now, Year, Month, Day);
  sMonth := IntToStr(Month);
  if Month < 10 then 
    sMonth := '0' + sMonth;
  sDay := IntToStr(Day);
  if Day < 10 then 
    sDay := '0' + sDay;
  rcbxTargetFile.Text := LowerCase(GetCurrentDir + '\' +
    ExtractFileName(ChangeFileExt(sProjectName, '')) + IntToStr(Year) +
    sMonth + sDay + '.zip');
end;

//------------------------------------------------------------------------------

procedure TVCSDistribution.spBtnResultClick(Sender: TObject);
var 
  Msg: string;
begin
  ViewTheModule(WindowHandle, rcbxTargetFile.Text, Msg);
end;

//------------------------------------------------------------------------------

procedure TVCSDistribution.spBtnHelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSDistribution.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Source_distribution);
end;

procedure TVCSDistribution.FormDestroy(Sender: TObject);
begin
  MruListTargetFile.Free;
end;

procedure TVCSDistribution.CompressionAddProgress(Sender: TObject);
begin
  if not bCompressBackup then
    Exit;
  if Assigned(VCSProgress) then
    VCSProgress.SetPBStepIt;
end;

end.
