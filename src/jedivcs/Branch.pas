(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: Branch.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS: Thomas Huber (Thomas_D_Huber@t-online.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FreeVCS code to JEDI VCS
2003/03/02  THensle   - changes for "ConfigStorage" unit
2003/03/08  USchuster - exchanged THistoryList with TJVCSMruList (mantis #727)
2003/12/27  USchuster - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use constant)
                      - fixed memory leak  
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/09  THuber    - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
                      - jedistyle clean
                      - use jvcl msgBoxes
2007/07/01  USchuster - style cleaning
                      - changes for large fonts (contraints and default size depend now on PixelsPerInch; analog to Mantis #3710)
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit Branch;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  {$IFDEF DEBUG}
  JclDebug,
  {$ENDIF DEBUG}
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, Buttons, ExtCtrls, ImgList, Menus, JVCSForms;

type
  TVCSBranch = class(TJVCSForm)
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    edBranchProj: TEdit;
    cbAncestor: TComboBox;
    spBtnBrowse: TSpeedButton;
    Panel2: TPanel;
    btnBranch: TButton;
    btnCancel: TButton;
    lvBranchFiles: TListView;
    StateImageList: TImageList;
    SysImageList: TImageList;
    PopupMenu1: TPopupMenu;
    BranchAll1: TMenuItem;
    ShareAll1: TMenuItem;
    SkipAll1: TMenuItem;
    Help: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure spBtnBrowseClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure cbAncestorChange(Sender: TObject);
    procedure lvBranchFilesMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edBranchProjChange(Sender: TObject);
    procedure btnBranchClick(Sender: TObject);
    procedure BranchAll1Click(Sender: TObject);
    procedure ShareAll1Click(Sender: TObject);
    procedure SkipAll1Click(Sender: TObject);
    procedure lvBranchFilesKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure HelpClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FCreating: Boolean;
    ActDir: string;
    procedure SetWindowsCaption;
    procedure SetupListBox;
    function CheckTarget(const FileName: string): Boolean;
  public
    { Public declarations }
    procedure RestrictSize(var msg: TMessage); Message WM_GETMINMAXINFO;
  end;

var
  VCSBranch: TVCSBranch;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  ShellAPI, VCSBase, VCSProcBase, HandleBlob, DBModule, Description, Std_ListView, TZHandling,
  FavOpenDialog, ConfigStorage, JvJVCLUtils, JVCSGUIClientResources;

{$R *.dfm}

//------------------------------------------------------------------------------
{- New class of items to insert in a list }
type
  TIDItem = class
    I: Integer;
    constructor Create(I1: Integer);
  end;

  {- Create a new instance of TIDItem }
constructor TIDItem.Create(I1: Integer);
begin
  I := I1;                { Save integer parameter }
  inherited Create;       { Call inherited Create }
end;

//------------------------------------------------------------------------------

procedure TVCSBranch.FormCreate(Sender: TObject);
var
  sfi: TSHFileInfo;
  DlgTop,
  DlgLeft,
  DlgWidth,
  DlgHeight: Integer;
begin
  try
    FCreating := True;
    // Aktuelles Verzeichnis speichern
    GetDir(0, ActDir);
    Screen.Cursor := crHourGlass;
    //Systemsymbole in eine TImageList-Komponente einlesen
    SysImageList.Handle := SHGetFileInfo('', 0,sfi, SizeOf(TSHFileInfo),
      SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
    SysImageList.ShareImages := True;

    if not jvcsReadWindowPosAndSize(sBaseRegistryKey + crbWindows, 'Branch',
      DlgTop, DlgLeft, DlgWidth, DlgHeight) then
    begin
      DlgTop := (Screen.Height - Height) div 2;
      DlgLeft := (Screen.Width - Width) div 2;
      DlgWidth := MulDiv(420, PixelsPerInch, 96);
      DlgHeight := MulDiv(250, PixelsPerInch, 96);
    end;
    Top := DlgTop;
    Left := DlgLeft;
    Width := DlgWidth;
    Height := DlgHeight;

    with lvBranchFiles do
    begin
      Columns[0].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'Branch_Col1.0', 100);
      Columns[1].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'Branch_Col1.1', 70);
      Columns[2].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'Branch_Col1.2', 40);
      Columns[3].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'Branch_Col1.3', 150);
      Columns[4].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'Branch_Col1.4', 75);
      Columns[5].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'Branch_Col1.5', 40);
      {$IFNDEF SHOWIDS}
      Columns[5].Width := 0;
      Columns[6].Width := 0;
      {$ENDIF ~SHOWIDS}
    end;

    {$IFDEF CUSTOMDRIVE}
    sDriveSubst := RegReadString(HKCU, sBaseRegistryKey + crbProjects +
      ExtractFileName(sProjectName), 'LocalDrive', '');
    if (sDriveSubst = '') then
      sDriveSubst := RegReadString(HKCU, sBaseRegistryKey + crbOptions,
        'LocalDrive', '');
    {$ENDIF CUSTOMDRIVE}

    btnBranch.Enabled := False;
    lvBranchFiles.Enabled := False;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
    Screen.Cursor := crDefault;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSBranch.FormActivate(Sender: TObject);
var 
  I: Integer;
  IDItem: TIDItem;
begin
  Application.ProcessMessages;
  if not FCreating then 
    Exit;
  Screen.Cursor := crHourGlass;

  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_PROJECT_LIST';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(False, ['']);    
    AppSrvClient1.Request.WriteFields(True, [False]); // incl. details    
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
      if AppSrvClient1.Answer.Fields[2] <> '1' then 
      begin
        IDItem := TIDItem.Create(_StrToInt(AppSrvClient1.Answer.Fields[0]));
        cbAncestor.Items.AddObject(AppSrvClient1.Answer.Fields[1], IDItem);
      end; // if AppSrvClient1.Answer.Fields[2] <> '1' then begin
      AppSrvClient1.Answer.Next;
    end;
  end; // with DataModule1 do begin
  for I := 0 to cbAncestor.Items.Count - 1 do
  begin
    if TIDItem(cbAncestor.Items.Objects[I]).I = ServerProjectID then
    begin
      cbAncestor.ItemIndex := I;
      Break;
    end;
  end;

  SetupListBox;
  FCreating := False;
end;

//------------------------------------------------------------------------------

procedure TVCSBranch.SetupListBox;
var 
  ModuleID, CurrentProjectID: Integer;
  CurrentFile, CurrentFileBase, CurrentPath: string;
  FExists: Boolean;
  LVItem: TListItem;
  sfi: TSHFileInfo;
begin
  CurrentProjectID := TIDItem(cbAncestor.Items.Objects[cbAncestor.ItemIndex]).I;

  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_LATEST_REVISIONS';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [CurrentProjectID]);
    AppSrvClient1.Request.WriteFields(False, [False]);
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

    lvBranchFiles.Items.BeginUpDate;
    try
      lvBranchFiles.Items.Clear;
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
          // Parent?
          if CurrentFile = CurrentFileBase then 
          begin
            FExists := FileExists(CurrentPath + CurrentFile);
            // NewItem
            LVItem := lvBranchFiles.Items.Add;
            // File
            if FExists then
              LVItem.Caption := ExtractFileName(GetOriginalFileName(CurrentPath +
                CurrentFile))
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
            LVItem.StateIndex := 0;
            // belong to
            LVItem.SubItems.Add(JVCSRES_Both_40share41);
            // Version
            LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[4] + '.' +
              AppSrvClient1.Answer.Fields[5]);
            // Path
            LVItem.SubItems.Add(CurrentPath);
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
      lvBranchFiles.Items.EndUpDate;
    end;
  end; // with DataModule1 do begin
  SetWindowsCaption;
  edBranchProjChange(Self);
end;

//------------------------------------------------------------------------------

procedure TVCSBranch.RestrictSize(var msg: TMessage);
var
  P: PMinMaxInfo;
begin
  // The lParam contains a pointer on a structure of type TMinMaxInfo
  P := PMinMaxInfo(msg.lParam);
  // This represents the size of the Window when Maximized
  P.ptMaxSize.X := trResDesktop.Right;
  P.ptMaxSize.Y := trResDesktop.Bottom;
  // This represents the position of the Window when Maximized
  P.ptMaxPosition.X := 0;
  P.ptMaxPosition.Y := 0;
  // This represents the minimum size of the Window
  P.ptMinTrackSize.X := MulDiv(420, PixelsPerInch, 96);
  P.ptMinTrackSize.Y := MulDiv(250, PixelsPerInch, 96);
end;

//------------------------------------------------------------------------------

procedure TVCSBranch.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  jvcsWriteWindowPosAndSize(sBaseRegistryKey + crbWindows, 'Branch',
    Top, Left, Width, Height);

  with lvBranchFiles do
  begin
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'Branch_Col1.0',
      Columns[0].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'Branch_Col1.1',
      Columns[1].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'Branch_Col1.2',
      Columns[2].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'Branch_Col1.3',
      Columns[3].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'Branch_Col1.4',
      Columns[4].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'Branch_Col1.5',
      Columns[5].Width);
  end;

  // Restore actual directory 
  ChDir(ActDir);
end;

//------------------------------------------------------------------------------

function TVCSBranch.CheckTarget(const FileName: string): Boolean;
var
  SearchRec: TSearchRec;
  DirEmpty: Boolean;
begin
  Result := False;
  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_PROJECT_ID';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [ExtractFileName(FileName)]);
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
      BeepIfSet;
      MsgWarn ( WindowHandle
              , Format( JVCSRES_There_is_already_a_project_named_6037s62_in_the_archive46 + #13+#10+
                        JVCSRES_You_cannot_have_different_projects_with_the_same_name_in_the_archive46
                      , [ExtractFileName(FileName)]
                      )
              , cMsgBoxCaption
              );
      Exit;
    end
    else
      TransactionNr := _StrToInt(AppSrvClient1.Answer.Fields[2]);
  end; // with DataModule1 do begin
  if FileExists(FileName) then
  begin
    BeepIfSet;
    MsgWarn ( WindowHandle
            , JVCSRES_You_cannot_select_an_existing_project_name46_Select_a_new44_unused_name_and_retry46
            , cMsgBoxCaption
            );
    Exit;
  end;
  // Directory empty?
  DirEmpty := True;
  if FindFirst(ExtractFilePath(FileName) + '*.*', faAnyFile, SearchRec) = 0 then
  begin
    if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
    begin
      DirEmpty := False;
    end;
    while FindNext(SearchRec) = 0 do
    begin
      if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
      begin
        DirEmpty := False;
      end;
    end;
    FindClose(SearchRec);
  end; // if FindFirst(TMPDirectory + 'qrp*.tmp', faAnyfile, SearchRec) = 0 then
  if not DirEmpty then
  begin
    BeepIfSet;
    MsgWarn ( WindowHandle
            , JVCSRES_Target_directory_must_be_empty46
            , cMsgBoxCaption
            );
    Exit;
  end;
  Result := True;
end;

//------------------------------------------------------------------------------

procedure TVCSBranch.spBtnBrowseClick(Sender: TObject);
var 
  DlgResult: Boolean;
  FavSaveDialog: TFavSaveDialog;
begin
  FavSaveDialog := TFavSaveDialog.Create(Application);
  try
    with FavSaveDialog do
    begin
      Title := JVCSRES_Branch_target_project_file_name;
      Options := [ofHideReadOnly, ofEnableSizing];
      FileName := '';
      Filter := Format( JVCSRES_37s_projects_40424637s41124424637s
                      , [sIDEName, sIDEProject, sIDEProject]
                      );
      DefaultExt := sIDEProject;

      //FavSaveDialog is inherited from FavOpenDialog and thatswhy
      //ExecuteFavOpenDialogWithMru also works here
      DlgResult := ExecuteFavOpenDialogWithMru(FavSaveDialog,
        sBaseRegistryKey + crbMRU + '17');
    end; // with SaveDialog1 do begin
    if DlgResult then 
    begin
      if CheckTarget(FavSaveDialog.FileName) then
        edBranchProj.Text := FavSaveDialog.FileName;
    end;
  finally
    FavSaveDialog.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSBranch.btnCancelClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSBranch.cbAncestorChange(Sender: TObject);
begin
  if FCreating then 
    Exit;
  SetupListBox;
end;

//------------------------------------------------------------------------------

procedure TVCSBranch.lvBranchFilesMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  HitTest: THitTests;
  HitItem: TListItem;
begin
  HitTest := lvBranchFiles.GetHitTestInfoAt(X, Y);
  if (Button = mbLeft) and (htOnStateIcon in HitTest) then 
  begin
    HitItem := lvBranchFiles.GetItemAt(X, Y);
    case HitItem.StateIndex of
      0: 
        begin
          HitItem.StateIndex := 1;
          HitItem.SubItems[0] := ExtractFileName(edBranchProj.Text);
        end;
      1: 
        begin
          HitItem.StateIndex := 2;
          HitItem.SubItems[0] := JVCSRES_None_40skip41;
        end;
      2:
        begin
          HitItem.StateIndex := 0;
          HitItem.SubItems[0] := JVCSRES_Both_40share41;
        end;
    end; // case HitItem.StateIndex of
    SetWindowsCaption;
  end; // if (Button = mbLeft) and (htOnStateIcon in HitTest) then begin
end;

//------------------------------------------------------------------------------

procedure TVCSBranch.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Branching_projects);
  if Key = VK_ESCAPE then 
  begin
    btnCancel.Click;
    Key := 0;
  end;    
end;

//------------------------------------------------------------------------------

procedure TVCSBranch.edBranchProjChange(Sender: TObject);
var 
  I: Integer;
  OldProject, ItemName: string;
begin
  OldProject := AnsiLowerCase(ExtractFileName(cbAncestor.Text));
  lvBranchFiles.Enabled := edBranchProj.Text <> '';
  btnBranch.Enabled := lvBranchFiles.Enabled;
  for I := 0 to lvBranchFiles.Items.Count - 1 do 
  begin
    ItemName := LowerCase(lvBranchFiles.Items[I].Caption);
    if (ItemName = OldProject) or
      (ItemName = ChangeFileExt(OldProject, '.res')) or
      (ItemName = ChangeFileExt(OldProject, '.dsk')) or
      (ItemName = ChangeFileExt(OldProject, '.cfg')) or
      (ItemName = ChangeFileExt(OldProject, '.dof')) then 
    begin
      lvBranchFiles.Items[I].StateIndex := 3;
      lvBranchFiles.Items[I].SubItems[0] := ExtractFileName(edBranchProj.Text);
    end 
    else 
      lvBranchFiles.Items[I].StateIndex := 0;
  end; // for i := 0 to lvBranchFiles.Items.Count - 1 do begin
  SetWindowsCaption;
end;

//------------------------------------------------------------------------------

procedure TVCSBranch.btnBranchClick(Sender: TObject);
var 
  I, J, OldProjectID, NewProjectID, FuncRes: Integer;
  CurrToken, CurrFile, OldProject, NewProject, NewPath, NewModule, ProjectDescr, ModuleDescr,
  ResultString, AffectedFiles, Mess, ErrMsg: string;
  DPRContent: TStringList;
  F: file;
label
  NextModule;
begin
  OldProject := AnsiLowerCase(ExtractFileName(cbAncestor.Text));
  OldProjectID := TIDItem(cbAncestor.Items.Objects[cbAncestor.ItemIndex]).I;

  NewProject := AnsiLowerCase(ExtractFileName(edBranchProj.Text));
  NewPath := AnsiLowerCase(ExtractFilePath(edBranchProj.Text));
  if MsgYesNoCancel ( WindowHandle
                    , Format( JVCSRES_Create_branch_project_6037s62 + #13+#10+
                              JVCSRES_in_6037s62_with_all_selected_modules63
                            , [NewProject, NewPath]
                            )
                    , cMsgBoxCaption
                    ) <> idYes then
    Exit; // !!!

  Screen.Cursor := crHourGlass;
  // New project
  ProjectDescr := '';
  with DataModule1 do
  begin
    if not jvcsReadBool(sBaseRegistryKey + crbOptions, 'SkipProjectDescr', False) then
    begin
      VCSDescription := TVCSDescription.Create(Application);
      try
        VCSDescription.Top := Top + 80;
        VCSDescription.Left := Left + 80;
        VCSDescription.DescType := 1;
        VCSDescription.SetDescripCaption(Format(JVCSRES_38Project58_37s, [NewProject]));
        VCSDescription.ShowModal;
        ProjectDescr := VCSDescription.Description;
        jvcsWriteBool(sBaseRegistryKey + crbOptions, 'SkipProjectDescr',
          VCSDescription.cbState);
      finally
        VCSDescription.Free;
      end;
    end; // if not RegReadBool(....

    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'ADD_NEW_PROJECT';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(False, [NewProject]);
    AppSrvClient1.Request.WriteFields(False, [ProjectDescr]);
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
    if DecodeBoolStr(AppSrvClient1.Answer.Fields[0]) then 
    begin
      NewProjectID := _StrToInt(AppSrvClient1.Answer.Fields[1]);
      Mess := Format( JVCSRES_Project_successfully_created46_Project_ID58_37s
                    , [AppSrvClient1.Answer.Fields[1]]
                    );
      MsgInfo(Handle, Mess, cMsgBoxCaption);
    end // if not DecodeBoolStr(....
    else
    begin
      // known project
      BeepIfSet;
      MsgWarn ( WindowHandle
              , JVCSRES_Projectname_is_already_in_use46 + #13+#10 +
                JVCSRES_Access_denied46
              , cMsgBoxCaption
              );
      Exit;
    end;
    if NewProjectID = 0 then 
      Exit;

    // new modules
    for I := 0 to lvBranchFiles.Items.Count - 1 do 
    begin
      // Skip?
      if lvBranchFiles.Items[I].StateIndex <> 2 then 
      begin
        //No
        if (lvBranchFiles.Items[I].StateIndex = 0) then // share
          NewModule := lvBranchFiles.Items[I].SubItems[2] +
            LowerCase(lvBranchFiles.Items[I].Caption);

        if (lvBranchFiles.Items[I].StateIndex = 1) then // branch
          NewModule := NewPath + LowerCase(lvBranchFiles.Items[I].Caption);

        if (lvBranchFiles.Items[I].StateIndex = 3) then // project file
          NewModule := NewPath + ChangeFileExt(NewProject,
            ExtractFileExt(LowerCase(lvBranchFiles.Items[I].Caption)));

        // Add Module
        ModuleDescr := '';
        if (lvBranchFiles.Items[I].StateIndex = 3) then 
        begin
          if not jvcsReadBool(sBaseRegistryKey + crbOptions, 'SkipModuleDescr',
            False) then
          begin
            VCSDescription := TVCSDescription.Create(Application);
            try
              VCSDescription.Top := Top + 80;
              VCSDescription.Left := Left + 80;
              VCSDescription.DescType := 2;
              VCSDescription.SetDescripCaption( Format( JVCSRES_38Module58_37s
                                                      , [ExtractFileName(NewModule)]
                                                      )
                                              );
              VCSDescription.ShowModal;
              ModuleDescr := VCSDescription.Description;
              jvcsWriteBool(sBaseRegistryKey + crbOptions, 'SkipModuleDescr',
                VCSDescription.cbState);
            finally
              VCSDescription.Free;
            end;
          end; // if not RegReadBool(....
        end; // if (lvBranchFiles.Items[i].StateIndex = 3) then begin
        AppSrvClient1.Request.Rewrite;
        AppSrvClient1.FunctionCode := 'ADD_NEW_MODULE';
        AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
        AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
        AppSrvClient1.Request.WriteFields(True, [NewProjectID]);
        AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
        AppSrvClient1.Request.WriteFields(False, [NewModule]);
        AppSrvClient1.Request.WriteFields(False, [moVer200]); // flags
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
      end; // if lvBranchFiles.Items[i].StateIndex <> 2 then begin
    end; // for i := 0 to lvBranchFiles.Items.Count - 1 do begin
  end; // with DataModule1 do begin

  // get all not shared modules to the new directory
  ResultString := '';
  for I := 0 to lvBranchFiles.Items.Count - 1 do 
  begin
    if lvBranchFiles.Items[I].StateIndex <> 2 then 
    begin
      if (lvBranchFiles.Items[I].StateIndex = 1) or
        (lvBranchFiles.Items[I].StateIndex = 3) then
      begin
        NewModule := NewPath + LowerCase(lvBranchFiles.Items[I].Caption);

        FuncRes := GetBlobs(DBModule.GetJvcsConnection, OldProjectID, ServerUserID,
          StrToInt(lvBranchFiles.Items[I].SubItems[4]){ModuleID},
          StrToInt(lvBranchFiles.Items[I].SubItems[5]){RevisionID},
          False{CheckOut}, Application, Self,
          False{SetReadOnly}, False{CloseIDEView},
          False{SetCurrentDate},
          NewModule, ErrMsg, AffectedFiles);
        if FuncRes <> 0 then 
        begin
          case FuncRes of
            1: Mess := JVCSRES_91CreateTargetDir93;
            2: Mess := JVCSRES_91AppSrvClient46Request93;
            3: Mess := JVCSRES_91GET95CHECKOUT95MODULE93;
            4: Mess := JVCSRES_91Get_compressed_size93;
            5: Mess := JVCSRES_91TFileStream_access93;
            6: Mess := JVCSRES_91Extract_zip_file93;
            7: Mess := JVCSRES_91Set_original_timestamp93;
            8: Mess := JVCSRES_91Replace_local_copy93;
            else
              Mess := JVCSRES_91Unknown93;
          end; // case FuncRes of
          BeepIfSet;
          MsgError( WindowHandle
                  , Format( '<%s>' + #13+#10 +
                            JVCSRES_JEDI_VCS_is_unable_to_create_a_local_copy_of_this_file46 + #13+#10 +
                            JVCSRES_Exception58_37s_in_37s46
                          , [NewModule, ErrMsg, Mess]
                          )
                  , cMsgBoxCaption
                  );
          Exit;
        end // if FuncRes <> 0 then begin
        else 
        begin
          // <%s>\n\rsuccessfully created.
          if Length(AffectedFiles) > 1 then
            Delete(AffectedFiles, Length(AffectedFiles), 1);
          ResultString := ResultString + NewModule + ';' + AffectedFiles + ';|';
        end;
      end // if (lvBranchFiles.Items[i].StateIndex = 1) or
      else
    end; // if lvBranchFiles.Items[i].StateIndex <> 2 then begin
  end; // for i := 0 to lvBranchFiles.Items.Count - 1 do begin
  VCSStdListView := TVCSStdListView.Create(Application);
  try
    VCSStdListView.LVRepID := 1;
    VCSStdListView.Caption := JVCSRES_Branch_result;
    VCSStdListView.Left := Left + 30;
    VCSStdListView.Top := Top + 30;
    VCSStdListView.LVType := 0;
    VCSStdListView.HelpContextID := IDH_Branching_projects;
    VCSStdListView.AddListColumn(JVCSRES_Branch_module, False);
    VCSStdListView.AddListColumn(JVCSRES_Affected_files, False);
    VCSStdListView.SetUpItems(ResultString);
    VCSStdListView.ShowModal;
  finally
    VCSStdListView.Free;
  end;

  // Project rename
  CurrFile := NewPath + OldProject;
  if FileExists(CurrFile) then
  begin
    AssignFile(F, CurrFile);
    Rename(F, NewPath + NewProject);
  end;
  CurrFile := ChangeFileExt(NewPath + OldProject, '.res');
  if FileExists(CurrFile) then
  begin
    AssignFile(F, CurrFile);
    Rename(F, ChangeFileExt(NewPath + NewProject, '.res'));
  end;
  CurrFile := ChangeFileExt(NewPath + OldProject, '.dof');
  if FileExists(CurrFile) then
  begin
    AssignFile(F, CurrFile);
    Rename(F, ChangeFileExt(NewPath + NewProject, '.dof'));
  end;
  CurrFile := ChangeFileExt(NewPath + OldProject, '.dsk');
  if FileExists(CurrFile) then
  begin
    AssignFile(F, CurrFile);
    Rename(F, ChangeFileExt(NewPath + NewProject, '.dsk'));
  end;
  CurrFile := ChangeFileExt(NewPath + OldProject, '.cfg');
  if FileExists(CurrFile) then
  begin
    AssignFile(F, CurrFile);
    Rename(F, ChangeFileExt(NewPath + NewProject, '.cfg'));
  end;

  // Update .dpr
  DPRContent := TStringList.Create;
  try
    if FileExists(NewPath + NewProject) then
    begin
      try
        DPRContent.LoadFromFile(NewPath + NewProject);
      except
        on E :
        Exception do
        begin
          DPRContent.Clear;
          BeepIfSet;
          MsgError( Handle
                  , Format( JVCSRES_Reading_file_6037s62 + #13+#10+
                            JVCSRES_raised_exception58_37s46
                          , [NewPath + NewProject, E.Message]
                          )
                  , cMsgBoxCaption
                  );
        end;
      end; // try except
    end; // if FileExists() then begin

    // Projektname austauschen
    for J := 0 to DPRContent.Count - 1 do 
    begin
      CurrToken := SearchAndChange(DPRContent.Strings[J],
        Copy(OldProject, 1, Pos('.', OldProject) - 1),
        Copy(NewProject, 1, Pos('.', NewProject) - 1));
      DPRContent.Strings[J] := CurrToken;
    end; // for j := 0 to DPRContent.Count - 1 do begin

    for I := 0 to lvBranchFiles.Items.Count - 1 do 
    begin
      if lvBranchFiles.Items[I].StateIndex = 0 then
      begin
        for J := 0 to DPRContent.Count - 1 do 
        begin
          CurrToken := SearchAndChange(DPRContent.Strings[J],
            'in ' + Chr(39) + lvBranchFiles.Items[I].Caption + Chr(39),
            'in ' + Chr(39) + lvBranchFiles.Items[I].SubItems[2] +
            lvBranchFiles.Items[I].Caption + Chr(39));
          DPRContent.Strings[J] := CurrToken;
          if (Pos('{$R *.RES}{', DPRContent.Strings[J]) <> 0) or
            (Pos('procedure ', DPRContent.Strings[J]) <> 0) then 
            Break;
        end; // for j := 0 to DPRContent.Count - 1 do begin
      end; // if lvBranchFiles.Items[i].StateIndex = 0 then begin
    end; // for i := 0 to lvBranchFiles.Items.Count - 1 do begin

    try
      DPRContent.SaveToFile(NewPath + NewProject);
    except
      BeepIfSet;
      MsgError( WindowHandle
              , Format( JVCSRES_Be_sure_that_the_file_is_not_opened_by_another_application44 +#13+#10+
                        JVCSRES_that_there_is_enough_free_space_on_the_disk +#13+#10+
                        JVCSRES_and_that_you_have_the_required_access_rights46
                      , [NewPath + NewProject]
                      )
              , cMsgBoxCaption
              );
    end;
  finally
    DPRContent.Free;
  end;

  btnBranch.Enabled := False;
  btnCancel.Caption := JVCSRES_38Close;
end;

//------------------------------------------------------------------------------

procedure TVCSBranch.SetWindowsCaption;
var 
  I, BranchMod, ShareMod, SkipMod: Integer;
begin
  BranchMod := 0;
  ShareMod := 0;
  SkipMod := 0;
  for I := 0 to lvBranchFiles.Items.Count - 1 do 
  begin
    if (lvBranchFiles.Items[I].StateIndex = 3) or
      (lvBranchFiles.Items[I].StateIndex = 1) then
      Inc(BranchMod);
    if (lvBranchFiles.Items[I].StateIndex = 0) then 
      Inc(ShareMod);
    if (lvBranchFiles.Items[I].StateIndex = 2) then 
      Inc(SkipMod);
  end; // for i := 0 to lvBranchFiles.Items.Count - 1 do begin
  Caption :=  Format( JVCSRES_VCS_Branch_45_37s_45_Share58_37d_47Branch58_37d_47Skip58_37d
                    , [ cbAncestor.Text
                      , ShareMod
                      , BranchMod
                      , SkipMod
                      ]
                    );
end;

//------------------------------------------------------------------------------

procedure TVCSBranch.BranchAll1Click(Sender: TObject);
var 
  I: Integer;
begin
  for I := 0 to lvBranchFiles.Items.Count - 1 do 
  begin
    if lvBranchFiles.Items[I].StateIndex <> 3 then 
    begin
      lvBranchFiles.Items[I].StateIndex := 1;
      lvBranchFiles.Items[I].SubItems[0] := ExtractFileName(edBranchProj.Text);
    end;
  end; // for i := 0 to lvBranchFiles.Items.Count - 1 do begin
  SetWindowsCaption;
end;

//------------------------------------------------------------------------------

procedure TVCSBranch.ShareAll1Click(Sender: TObject);
var 
  I: Integer;
begin
  for I := 0 to lvBranchFiles.Items.Count - 1 do 
  begin
    if lvBranchFiles.Items[I].StateIndex <> 3 then 
    begin
      lvBranchFiles.Items[I].StateIndex := 0;
      lvBranchFiles.Items[I].SubItems[0] := JVCSRES_Both_40share41;
    end;
  end; // for i := 0 to lvBranchFiles.Items.Count - 1 do begin
  SetWindowsCaption;
end;

//------------------------------------------------------------------------------

procedure TVCSBranch.SkipAll1Click(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to lvBranchFiles.Items.Count - 1 do
  begin
    if lvBranchFiles.Items[I].StateIndex <> 3 then
    begin
      lvBranchFiles.Items[I].StateIndex := 2;
      lvBranchFiles.Items[I].SubItems[0] := JVCSRES_None_40skip41;
    end;
  end; // for i := 0 to lvBranchFiles.Items.Count - 1 do begin
  SetWindowsCaption;
end;

//------------------------------------------------------------------------------

procedure TVCSBranch.lvBranchFilesKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (lvBranchFiles.Selected <> nil) and (Key = VK_SPACE) then 
  begin
    case lvBranchFiles.Selected.StateIndex of
      0:
        begin
          lvBranchFiles.Selected.StateIndex := 1;
          lvBranchFiles.Selected.SubItems[0] := ExtractFileName(edBranchProj.Text);
        end;
      1:
        begin
          lvBranchFiles.Selected.StateIndex := 2;
          lvBranchFiles.Selected.SubItems[0] := JVCSRES_None_40skip41;
        end;
      2:
        begin
          lvBranchFiles.Selected.StateIndex := 0;
          lvBranchFiles.Selected.SubItems[0] := JVCSRES_Both_40share41;
        end;
    end; // case lvBranchFiles.Selected.StateIndex of
    SetWindowsCaption;

    {if lvBranchFiles.Selected.StateIndex > 1 then Exit;
    if lvBranchFiles.Selected.StateIndex = 0
      then lvBranchFiles.Selected.StateIndex := 1
        else lvBranchFiles.Selected.StateIndex := 0;}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSBranch.HelpClick(Sender: TObject);
var
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

procedure TVCSBranch.FormDestroy(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to cbAncestor.Items.Count - 1 do
  begin
    cbAncestor.Items.Objects[I].Free;
    cbAncestor.Items.Objects[I] := nil;
  end;
end;

end.
