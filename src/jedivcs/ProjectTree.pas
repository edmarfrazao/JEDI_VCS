(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: ProjectTree.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS: Thomas Huber (Thomas_D_Huber@gmx.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
ToDo
- dump without compression ?
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FreeVCS code to JEDI VCS
2003/02/12  USchuster - changed DSAMsg with JVCSDialogs in uses clause to use JvDSADialogs
2003/03/05  THensle   - changes for "ConfigStorage" unit
2003/03/08  USchuster - exchanged THistoryList with TJVCSMruList (mantis #727)
2003/03/26  USchuster - main changes for mantis #807
2003/04/16  USchuster - finished mantis #807 - now with dialog for output
                        structure and Backup Zip File selection
2003/11/09  USchuster - exchanged TextComp call with new procedure DoModuleCompare (mantis #1204)
                      - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use new constant)
2003/12/08  USchuster - modules checked out by you won't get the RO Flag (mantis #1220)
2003/12/27  THuber    - TimeConst now from JVCSClientConsts
2004/03/20  USchuster - changed to use internal images instead of .ico files in application path
                      - added dump function for Module and Module Version
                      - minor style cleaning (casing and comments)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/23  USchuster - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/11/02  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
2005/04/11  CSchuette - mantis #2815
2005/04/25  CSchuette - added call to "ResolveFileFamilies" to fix mantis #1205
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 released ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
2006/04/30  THuber    #3674 Z i p Master replaced with abbrevia
2007/06/30  USchuster - changes for large fonts (contraints and default size depend now on PixelsPerInch; analog to Mantis #3710)
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2009/01/01  USchuster - changes for D2009
2010/01/24  THuber    #4097 Defaultpath Windows VISTA/7 conform, Persistance for backfile introduced
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)
unit ProjectTree;

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
  StdCtrls, ExtCtrls, ComCtrls, Menus, Buttons, ImgList,
  AbArcTyp, AbZipTyp, AbZipPrc, AbUtils, JVCSForms;

type
  TTVData = record
    ID,
    State: Integer;
  end;

  TBackupTreeType = (btProject, btModule, btModuleVersion);

type
  TVCSProjectTree = class(TJVCSForm)
    Panel2: TPanel;
    btnClose: TButton;
    TreeView1: TTreeView;
    SysImageList: TImageList;
    TVStateImageList: TImageList;
    PopupMenu2: TPopupMenu;
    Remove1: TMenuItem;
    Removeversion1: TMenuItem;
    Removemodule1: TMenuItem;
    miGetmodule: TMenuItem;
    N1: TMenuItem;
    Collapse1: TMenuItem;
    Fullexpand1: TMenuItem;
    N2: TMenuItem;
    btnProjBackup: TButton;
    Revisionlabels1: TMenuItem;
    Help: TSpeedButton;
    spBtnGet: TSpeedButton;
    spBtnDelModule: TSpeedButton;
    spBtnDelVersion: TSpeedButton;
    spBtnDelRevision: TSpeedButton;
    spBtnLabels: TSpeedButton;
    lblProjectInfo: TLabel;
    CompareRevision1: TMenuItem;
    ModuleDescription1: TMenuItem;
    N3: TMenuItem;
    ProjectDescription1: TMenuItem;
    spBtnCompare: TSpeedButton;
    spBtnDescription: TSpeedButton;
    TVImageList: TImageList;
    spBtnDump: TSpeedButton;
    N4: TMenuItem;
    DumpModule1: TMenuItem;
    DumpVersion1: TMenuItem;
    DumpProject1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormActivate(Sender: TObject);
    procedure HelpTopic1Click(Sender: TObject);
    procedure Remove1Click(Sender: TObject);
    procedure PopupMenu2Popup(Sender: TObject);
    procedure Removemodule1Click(Sender: TObject);
    procedure Removeversion1Click(Sender: TObject);
    procedure miGetmoduleClick(Sender: TObject);
    procedure btnProjBackupClick(Sender: TObject);
    procedure Fullexpand1Click(Sender: TObject);
    procedure Collapse1Click(Sender: TObject);
    procedure Revisionlabels1Click(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure TreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure TreeView1Expanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure CompareRevision1Click(Sender: TObject);
    procedure ModuleDescription1Click(Sender: TObject);
    procedure ProjectDescription1Click(Sender: TObject);
    procedure spBtnDescriptionClick(Sender: TObject);
    procedure spBtnDumpClick(Sender: TObject);
  private
    { Private-Deklarationen }
    bFCreating,
    AutoFullExpand,
    bCompressBackup: Boolean;
    FVCSIcon,
    ZipIcon,
    LibIcon,
    IDEIcon,
    CommentIcon,
    NoFoundIcon,
    FolderIcon: Integer;
    SelectedProjectName,
    ActDir: string;
    FSystemImagesOffset: Integer;
    procedure SetupTreeViewByModule;
    function GetModuleName(MID: string): string;
    procedure HandleDescription(const DescType, ID: Integer;
      const DescCaption: string);
    procedure FreeTVData;
    function GetIsCheckedOutByMe(AModuleID: Integer): Boolean;
    function GetFileImageIndex(const AFileName: string): Integer;
    procedure BackupTree(const ABackupType: TBackupTreeType; const ATreeNode: TTreeNode);
    procedure AbBackup(const sBaseDir, sZipFile : String);
    procedure AbInsertHelper( Sender : TObject; Item : TAbArchiveItem;
                                        OutStream : TStream );
    procedure AbOnArchiveProgress(Sender : TObject; Progress : Byte; var Abort : Boolean);
  public
    { Public-Deklarationen }
    SelectedProjectID,
    SelectedModuleID: Integer;
    procedure RestrictSize(var Msg: TMessage); message WM_GETMINMAXINFO;
  end;

var
  VCSProjectTree: TVCSProjectTree;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  Vcsbase, Progress, VCSProcBase, JVCSClientConsts, JVCSDialogs, ShellAPI,
  HandleBlob, SelectFolder, DBModule, AssignLabels, Textcomp, CheckSum,
  Description, TZHandling, FavOpenDialog, ConfigStorage, BackupTreeOptions,
  JclFileUtils, JclSysInfo, JclStrings, JVCSGUIClientResources, JVCSClientFunctions;

var
  PTVData: ^TTVData;

{$R *.dfm}

procedure TVCSProjectTree.FormCreate(Sender: TObject);
var
  DlgTop,
  DlgLeft,
  DlgWidth,
  DlgHeight: Integer;
  sfi: TSHFileInfo;
begin
  try
    VCSProgress := nil;
    bFCreating := True;
    AutoFullExpand := False;

    // Store directory
    GetDir(0, ActDir);

    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    if not jvcsReadWindowPosAndSize(sBaseRegistryKey + crbWindows, 'ProjectTree',
      DlgTop, DlgLeft, DlgWidth, DlgHeight) then
    begin
      DlgTop := (Screen.Height - Height) div 2;
      DlgLeft := (Screen.Width - Width) div 2;
      DlgWidth := MulDiv(465, PixelsPerInch, 96);
      DlgHeight := MulDiv(250, PixelsPerInch, 96);
    end;
    Top := DlgTop;
    Left := DlgLeft;
    Width := DlgWidth;
    Height := DlgHeight;

    {$IFDEF CUSTOMDRIVE}
    sDriveSubst := RegReadString(HKCU, sBaseRegistryKey + crbProjects +
      ExtractFileName(sProjectName), 'LocalDrive', '');
    if (sDriveSubst = '') then
      sDriveSubst := RegReadString(HKCU, sBaseRegistryKey + crbOptions,
        'LocalDrive', '');
    {$ENDIF CUSTOMDRIVE}

    //Read Systemicons into TImageList
    SysImageList.Handle := SHGetFileInfo('', 0, sfi, SizeOf(TSHFileInfo),
      SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
    SysImageList.ShareImages := True;
    FSystemImagesOffset := 6;
    FVCSIcon := 0;
    FolderIcon := GetFileImageIndex(GetCurrentDir);
    ZipIcon := 1;
    CommentIcon := 2;
    NoFoundIcon := 3;
    IDEIcon := 4;
    LibIcon := 5;

    Screen.Cursors[cPopUpMCursor] := LoadCursor(hInstance, PChar('CURSORRM'));
    TreeView1.Cursor := cPopUpMCursor;
    lblProjectInfo.Caption := '';
    SelectedModuleID := 0;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectTree.FormActivate(Sender: TObject);
var
  I, J: Integer;
begin
  if Assigned(VCSProgress) then
    SetForeGroundWindow(VCSProgress.Handle);
  Application.ProcessMessages;
  if bFCreating then
  begin
    bFCreating := False;
    if SelectedProjectID <> 0 then
    begin
      SetupTreeViewByModule;
      Screen.Cursor := crHourGlass;
      if SelectedModuleID <> 0 then
      begin
        TreeView1.Items.BeginUpdate;
        try
          for I := 0 to TreeView1.Items.Count - 1 do
          begin
            if (TreeView1.Items[I].Level = 1) and
              (SelectedModuleID = TTVData(TreeView1.Items[I].Data^).ID) then
            begin
              TreeView1.Selected := TreeView1.Items[I];
              TreeView1.Selected.Expanded := True;
              TreeView1.Selected.MakeVisible;
              J := I + 1;
              while (J < TreeView1.Items.Count) and
                (TreeView1.Items[J].Level > 1) do
              begin
                Screen.Cursor := crHourGlass;
                TreeView1.Items[J].Expanded := True;
                TreeView1.Items[J].MakeVisible;
                Inc(J);
              end;
              Break;
            end; // if (TreeView1.Items[I].Level = 1) and...
          end; // for I := 0 to TreeView1.Items.Count - 1 do begin
        finally
          TreeView1.Items.EndUpdate;
        end;
      end; // if SelectedModuleID <> 0 then begin
      Screen.Cursor := crDefault;
    end; // if SelectedProjectID <> 0 then begin
  end; // if bFCreating then begin
end;

//------------------------------------------------------------------------------

procedure TVCSProjectTree.HelpTopic1Click(Sender: TObject);
begin
  PerformHelpCommand(Application, IDH_Project_tree);
end;

//------------------------------------------------------------------------------

procedure TVCSProjectTree.FreeTVData;
var 
  I: Integer;
begin
  // Release memory
  for I := TreeView1.Items.Count - 1 downto 0 do
    Dispose(TreeView1.Items[I].Data);
end;

//------------------------------------------------------------------------------

procedure TVCSProjectTree.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  FreeTVData;

  jvcsWriteWindowPosAndSize(sBaseRegistryKey + crbWindows, 'ProjectTree',
    Top, Left, Width, Height);

  // restore directory from which we started
  ChDir(ActDir);
end;

//------------------------------------------------------------------------------

procedure TVCSProjectTree.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then 
  begin
    btnClose.Click;
    Key := 0;
  end;    
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Project_tree);
end;

//------------------------------------------------------------------------------

procedure TVCSProjectTree.RestrictSize(var Msg: TMessage);
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
  P.ptMinTrackSize.x := MulDiv(465, PixelsPerInch, 96);
  P.ptMinTrackSize.y := MulDiv(300, PixelsPerInch, 96);
end;

//------------------------------------------------------------------------------

procedure TVCSProjectTree.SetupTreeViewByModule;
var
  Msg, DevState, CurrentPath, CurrentFile, ModuleID, Version, Revision: string;
  ModuleCount: Integer;
  FExists: Boolean;
  Node0, Node1, Node2, Node3: TTreeNode;
begin
  FreeTVData;
  with TreeView1 do 
  begin
    Items.BeginUpdate;
    Items.Clear;

    with DataModule1 do
    begin
      //--- get project info ---------------------------------------------------
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_PROJECT_INFORMATION';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [SelectedProjectID]);
      SetupTimeoutCounter;
      AppSrvClient1.Send;
      // Message Window

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
      SelectedProjectName := AppSrvClient1.Answer.Fields[1];
      Msg := Format(JVCSRES_VCS_Project_37s_45_ID58_37s_45_37s,
        [SelectedProjectName, AppSrvClient1.Answer.Fields[0],
        DateTimeToStr(GMTStr2LocalDateTime(AppSrvClient1.Answer.Fields[2]))]);
      DevState := DateTimeToStr(GMTStr2LocalDateTime(AppSrvClient1.Answer.Fields[4]));

      Node0 := TreeView1.Items.AddChild(TreeView1.Selected, Msg);
      Node0.ImageIndex := FVCSIcon;
      Node0.SelectedIndex := FVCSIcon;

      //--- get revisions ------------------------------------------------------
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_REVISION_LIST';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [SelectedProjectID]);
      AppSrvClient1.Request.WriteFields(False, [False]);
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
      ModuleCount := 0;
      while not AppSrvClient1.Answer.Eof do
      begin
        ModuleID := AppSrvClient1.Answer.Fields[0];
        CurrentFile := AppSrvClient1.Answer.Fields[1];
        {$IFDEF CUSTOMDRIVE}
        CurrentPath := ChangeDriveName(AppSrvClient1.Answer.Fields[2], sDriveSubst);
        {$ELSE}
        CurrentPath := AppSrvClient1.Answer.Fields[2];
        {$ENDIF CUSTOMDRIVE}
        FExists := FileExists(CurrentPath + CurrentFile);
        if FExists then
          Node1 := TreeView1.Items.AddChild(Node0,
            ExtractFileName(GetOriginalFileName(CurrentPath + CurrentFile)))
        else
          Node1 := TreeView1.Items.AddChild(Node0, CurrentFile);
        Inc(ModuleCount);
        //--- File Icon --------------------------------------------------------
        if FExists then
          Node1.ImageIndex := GetFileImageIndex(CurrentPath + CurrentFile)
        else
          Node1.ImageIndex := NoFoundIcon;
        Node1.SelectedIndex := Node1.ImageIndex;

        New(PTVData);
        PTVData^.ID := _StrToInt(ModuleID);
        PTVData^.State := 0;
        Node1.Data := PTVData;

        if DecodeBoolStr(AppSrvClient1.Answer.Fields[3]) then 
          Node1.StateIndex := 2
        else 
          Node1.StateIndex := 1;
        while (not AppSrvClient1.Answer.Eof) and
          (ModuleID = AppSrvClient1.Answer.Fields[0]) do 
        begin
          Version := AppSrvClient1.Answer.Fields[7];
          Node2 := TreeView1.Items.AddChild(Node1, Format(JVCSRES_Version_37s, [Version]));
          Node2.ImageIndex := FolderIcon;
          Node2.SelectedIndex := FolderIcon;
          while (not AppSrvClient1.Answer.Eof) and
            (ModuleID = AppSrvClient1.Answer.Fields[0]) and
            (Version = AppSrvClient1.Answer.Fields[7]) do
          begin
            Revision := AppSrvClient1.Answer.Fields[8];
            {Node3 := TreeView1.Items.AddChild(Node2, 'Revision ' + Revision +
                                ' [' + AppSrvClient1.Answer.Fields[6] + ']');}
            Node3 := TreeView1.Items.AddChild(Node2, Format(JVCSRES_Revision_37s, [Revision]));
            Node3.ImageIndex := ZipIcon;
            Node3.SelectedIndex := ZipIcon;
            Node3.HasChildren := True;

            New(PTVData);
            PTVData^.ID := _StrToInt(AppSrvClient1.Answer.Fields[6]);
            PTVData^.State := 0;
            Node3.Data := PTVData;

            {if DecodeBoolStr(AppSrvClient1.Answer.Fields[3])
              then Node3.StateIndex := 2 else Node3.StateIndex := 1;}
            AppSrvClient1.Answer.Next;
          end; // while (not AppSrvClient1.Answer.EoF) and (Version =...
        end; // while (not AppSrvClient1.Answer.EoF) and (ModuleID =...
      end; // while not AppSrvClient1.Answer.EoF do begin
      lblProjectInfo.Caption := Format(JVCSRES_37d_modules47_37d_revisions_45_State58_37s,
        [ModuleCount, AppSrvClient1.Answer.RecordCount, DevState]);
    end; // with DataModule1 do begin
    Caption := Caption + ' - ' + SelectedProjectName;
    Selected := Items.GetFirstNode;
    Selected.Expanded := True;
    Items.EndUpdate;
  end; // with TreeView1 do begin
end;

//------------------------------------------------------------------------------

function TVCSProjectTree.GetModuleName(MID: string): string;
begin
  Result := '';
  // Get Module name
  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_MODULE_NAME';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [MID]);
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

    Result := AppSrvClient1.Answer.Fields[0];
  end; // with DataModule1 do begin
end;

//------------------------------------------------------------------------------

procedure TVCSProjectTree.Remove1Click(Sender: TObject);
var
  SelectedIndex: Integer;
  ModuleID, RevisionID, ModuleVersion, ModuleRevision, ModuleName: string;
begin
  if TreeView1.Selected = nil then
    Exit;
  RevisionID := IntToStr(TTVData(TreeView1.Selected.Data^).ID);

  ModuleRevision := TreeView1.Selected.Text;
  while ModuleRevision[1] <> ' ' do 
    Delete(ModuleRevision, 1, 1);
  Delete(ModuleRevision, 1, 1);

  with TreeView1 do 
  begin
    SelectedIndex := Selected.AbsoluteIndex;
    while (SelectedIndex > 0) and (Items[SelectedIndex].Level > 2) do 
    begin
      Dec(SelectedIndex);
      if Items[SelectedIndex].Level = 2 then 
      begin
        ModuleVersion := Items[SelectedIndex].Text;
        while ModuleVersion[1] <> ' ' do
          Delete(ModuleVersion, 1, 1);
        Delete(ModuleVersion, 1, 1);
        Break;
      end;
    end;
    while (SelectedIndex > 0) and (Items[SelectedIndex].Level > 1) do
    begin
      Dec(SelectedIndex);
      if Items[SelectedIndex].Level = 1 then 
      begin
        ModuleID := IntToStr(TTVData(Items[SelectedIndex].Data^).ID);
        ModuleName := LowerCase(Items[SelectedIndex].Text);
        Break;
      end;
    end;
  end; // with TreeView1 do begin
  {while ModuleID[1] <> '[' do Delete(ModuleID, 1, 1);
  Delete(ModuleID, 1, 1);
  Delete(ModuleID, Length(ModuleID), 1);}

  {ShowMessage('RevisionID ' + RevisionID + #10#13 +
              'ModuleVersion ' + ModuleVersion + #10#13 +
              'ModuleID ' + ModuleID);
  Exit;}

  if MessageBox(WindowHandle, PChar(Format(JVCSRES_Are_you_sure_you_want_to_remove_6037s62_4037s41_from_the_archive63,
    [ModuleName + ' V ' + ModuleVersion + '.' + ModuleRevision, JVCSRES_all_members]) + #13#10 +
    JVCSRES_Warning33_This_process_is_not_reversible46),
    cMsgBoxCaption, MB_YESNOCANCEL or MB_DEFBUTTON2 or MB_ICONWARNING) <> id_Yes then
    Exit;

  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'REMOVE_REVISION';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [SelectedProjectID]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(False, [ModuleID]);
    AppSrvClient1.Request.WriteFields(False, [RevisionID]);
    AppSrvClient1.Request.WriteFields(False,
      [ModuleName + ' V ' + ModuleVersion + '.' + ModuleRevision]);
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
    if not DecodeBoolStr(AppSrvClient1.Answer.Fields[0]) then 
    begin
      MessageBox(Handle, PChar(Format('<%s>' + #13#10 +
        JVCSRES_This_module_is_already_used_by_other_projects46 + #13#10 +
        JVCSRES_Only_the_link_to_the_current_project_was_removed46_, [ModuleName])),
        cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
    end;
  end; // with DataModule1 do begin
  Dispose(TreeView1.Selected.Data);
  TreeView1.Selected.Delete;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectTree.PopupMenu2Popup(Sender: TObject);
begin
  ProjectDescription1.Enabled := (TreeView1.Selected <> nil) and
    (TreeView1.Selected.Level = 0);
  Removemodule1.Enabled := (TreeView1.Selected <> nil) and
    (TreeView1.Selected.Level = 1);
  spBtnDelModule.Enabled := Removemodule1.Enabled;
  ModuleDescription1.Enabled := Removemodule1.Enabled;
  Removeversion1.Enabled := (TreeView1.Selected <> nil) and
    (TreeView1.Selected.Level = 2);
  spBtnDelVersion.Enabled := Removeversion1.Enabled;
  miGetmodule.Enabled := (TreeView1.Selected <> nil) and
    (TreeView1.Selected.Level = 3);
  spBtnGet.Enabled := miGetmodule.Enabled;
  Remove1.Enabled := miGetmodule.Enabled;
  CompareRevision1.Enabled := miGetmodule.Enabled;
  spBtnCompare.Enabled := miGetmodule.Enabled;
  spBtnDelRevision.Enabled := Remove1.Enabled;
  Revisionlabels1.Enabled := miGetmodule.Enabled;
  spBtnLabels.Enabled := Revisionlabels1.Enabled;
  spBtnDescription.Enabled := ProjectDescription1.Enabled or
    ModuleDescription1.Enabled;
  DumpProject1.Enabled := (TreeView1.Selected <> nil) and
    (TreeView1.Selected.Level = 0);
  DumpModule1.Enabled := (TreeView1.Selected <> nil) and
    (TreeView1.Selected.Level = 1);
  DumpVersion1.Enabled := (TreeView1.Selected <> nil) and
    (TreeView1.Selected.Level = 2);
  spBtnDump.Enabled := DumpProject1.Enabled or DumpModule1.Enabled or DumpVersion1.Enabled;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectTree.Removemodule1Click(Sender: TObject);
var
  ModuleID, ModuleName: string;
begin
  if TreeView1.Selected = nil then 
    Exit;
  ModuleID := IntToStr(TTVData(TreeView1.Selected.Data^).ID);
  ModuleName := LowerCase(TreeView1.Selected.Text);

  if MessageBox(WindowHandle, PChar(Format(JVCSRES_Are_you_sure_you_want_to_remove_6037s62_4037s41_from_the_archive63,
    [ModuleName, JVCSRES_all_versions]) + #13#10 + JVCSRES_Warning33_This_process_is_not_reversible46),
    cMsgBoxCaption, MB_YESNOCANCEL or MB_DEFBUTTON2 or MB_ICONWARNING) <> id_Yes then
    Exit;

  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'REMOVE_MODULE';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [SelectedProjectID]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(False, [ModuleID]);
    AppSrvClient1.Request.WriteFields(False, [True]);
    AppSrvClient1.Request.WriteFields(False, [ModuleName]);
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
    if not DecodeBoolStr(AppSrvClient1.Answer.Fields[0]) then 
    begin
      MessageBox(Handle, PChar(Format('<%s>' + #13#10 +
        JVCSRES_This_module_is_already_used_by_other_projects46 + #13#10 +
        JVCSRES_Only_the_link_to_the_current_project_was_removed46_, [ModuleName])),
        cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
    end;
  end; // with DataModule1 do begin
  Dispose(TreeView1.Selected.Data);
  TreeView1.Selected.Delete;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectTree.Removeversion1Click(Sender: TObject);
var
  SelectedIndex: Integer;
  ModuleID, ModuleVersion, ModuleName: string;
begin
  if TreeView1.Selected = nil then 
    Exit;
  ModuleVersion := TreeView1.Selected.Text;
  while ModuleVersion[1] <> ' ' do 
    Delete(ModuleVersion, 1, 1);
  Delete(ModuleVersion, 1, 1);
  with TreeView1 do 
  begin
    SelectedIndex := Selected.AbsoluteIndex;
    while (SelectedIndex > 0) and (Items[SelectedIndex].Level > 1) do 
    begin
      Dec(SelectedIndex);
      if Items[SelectedIndex].Level = 1 then
      begin
        ModuleID := IntToStr(TTVData(Items[SelectedIndex].Data^).ID);
        ModuleName := LowerCase(Items[SelectedIndex].Text);
        Break;
      end;
    end;
  end; // with TreeView1 do begin

  if MessageBox(WindowHandle, PChar(Format(JVCSRES_Are_you_sure_you_want_to_remove_6037s62_4037s41_from_the_archive63,
    [ModuleName + ' V ' + ModuleVersion + '.x', JVCSRES_all_revisions]) + #13#10 +
    JVCSRES_Warning33_This_process_is_not_reversible46), cMsgBoxCaption,
    MB_YESNOCANCEL or MB_DEFBUTTON2 or MB_ICONWARNING) <> id_Yes then
    Exit;

  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'REMOVE_VERSION';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [SelectedProjectID]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(False, [ModuleID]);
    AppSrvClient1.Request.WriteFields(False, [ModuleVersion]);
    AppSrvClient1.Request.WriteFields(False,
      [ModuleName + ' V ' + ModuleVersion + '.x']);
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
    if not DecodeBoolStr(AppSrvClient1.Answer.Fields[0]) then
    begin
      MessageBox(Handle, PChar(Format('<%s>' + #13#10 +
        JVCSRES_This_module_is_already_used_by_other_projects46 + #13#10 +
        JVCSRES_Only_the_link_to_the_current_project_was_removed46_, [ModuleName])),
        cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
    end;
  end; // with DataModule1 do begin
  Dispose(TreeView1.Selected.Data);
  TreeView1.Selected.Delete;
end;

//------------------------------------------------------------------------------

function TVCSProjectTree.GetIsCheckedOutByMe(AModuleID: Integer): Boolean;
begin
  Result := False;
  if AModuleID > 0 then
    with DataModule1 do
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_REVISION_LIST_BY_ID';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [AModuleID]);
      AppSrvClient1.Request.WriteFields(False, [0]); // all projects !
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
        Result := DecodeBoolStr(AppSrvClient1.Answer.Fields[3]) and
          (StrToIntDef(AppSrvClient1.Answer.Fields[5], 0) = ServerUserID);
      end;
    end;
end;

function TVCSProjectTree.GetFileImageIndex(const AFileName: string): Integer;
var
  sfi: TSHFileInfo;
  I: Integer;
  Icon: TIcon;
begin
  SHGetFileInfo(PChar(AFileName), 0, sfi,
    SizeOf(sfi), SHGFI_SYSICONINDEX or
    SHGFI_SMALLICON or SHGFI_DISPLAYNAME);
  Result := sfi.iIcon + FSystemImagesOffset;
  if Pred(TVImageList.Count - FSystemImagesOffset) < sfi.iIcon then
    for I := TVImageList.Count - FSystemImagesOffset to sfi.iIcon do
    begin
      Icon := TIcon.Create;
      try
        SysImageList.GetIcon(I, Icon);
        TVImageList.AddIcon(Icon);
      finally
        Icon.Free;
      end;
    end;
end;

procedure TVCSProjectTree.miGetmoduleClick(Sender: TObject);
var
  Module, ModuleID, RevisionID, TargetDir, TargetFile, OldFile, OriginalPath, AffectedFiles,
  NotReadOnlyFilter, Mess, ErrMsg: string;
  TargetFDate: TDateTime;
  FuncRes: Integer;
  SetROFlag: Boolean;
  CheckedOutByMe, CheckedOut: Boolean;
begin
  if TreeView1.Selected = nil then
    Exit;
  RevisionID := IntToStr(TTVData(TreeView1.Selected.Data^).ID);
  if (_StrToInt(RevisionID) = 0) then
  begin
    ShowMessage(Format(JVCSRES_RevisionID58_37d, [RevisionID]));
    Exit;
  end;

  CheckedOutByMe := False;
  CheckedOut := False;

  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_REVISION_STATUS';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [RevisionID]);
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
      Module := AppSrvClient1.Answer.Fields[1];
      {$IFDEF CUSTOMDRIVE}
      OriginalPath := ChangeDriveName(AppSrvClient1.Answer.Fields[2], sDriveSubst);
      {$ELSE}
      OriginalPath := AppSrvClient1.Answer.Fields[2];
      {$ENDIF CUSTOMDRIVE}
      CheckedOut := DecodeBoolStr(AppSrvClient1.Answer.Fields[3]);
    end;

    if CheckedOut then
      CheckedOutByMe := GetIsCheckedOutByMe(StrToIntDef(ModuleID, 0));

    VCSSelectFolder := TVCSSelectFolder.Create(Application);
    try
      VCSSelectFolder.SetStatusText(JVCSRES_38Target_folder58);
      VCSSelectFolder.EnableRecursive(False);
      VCSSelectFolder.HelpContextID := IDH_Project_tree;
      VCSSelectFolder.SetInitialDir(OriginalPath);
      VCSSelectFolder.ShowModal;
      if VCSSelectFolder.Selection <> '' then 
      begin
        TargetDir := AnsiLowerCase(VCSSelectFolder.Selection);
      end // if VCSSelectFolder.Selection <> '' then begin
      else 
        TargetDir := '';
    finally
      VCSSelectFolder.Free;
    end;
    if TargetDir = '' then 
      Exit;
    TargetDir := SetBackSlash(TargetDir);

    AppSrvClient1.Answer.First;
    while not AppSrvClient1.Answer.Eof do
    begin
      OldFile := TargetDir + AppSrvClient1.Answer.Fields[1];
      OldFile := ChangeFileExt(OldFile, TrimRight(AppSrvClient1.Answer.Fields[10]));
      if FileExists(OldFile) then
      begin
        TargetFDate := FileGetUTCDateTime(OldFile) - cTimeConvErr;
        {$IFDEF DEBUGMSG}
        ShowMessage('File: ' + ExtractFileName(OldFile) +
          ' - TargetFDate: ' + DateTimeToStr(TargetFDate) +
          ' - ArchiveFDate: ' +
          DateTimeToStr(_StrToFloat(AppSrvClient1.Answer.Fields[6])));
        {$ENDIF DEBUGMSG}
        if _StrToFloat(AppSrvClient1.Answer.Fields[6]) < TargetFDate then 
        begin
          if _StrToInt(AppSrvClient1.Answer.Fields[8]) <> CRCInt(OldFile, Mess) then 
          begin
            BeepIfSet;
            if MessageBox(WindowHandle, PChar(Format(JVCSRES_Module_6037s62_on_disk_has_a_newer_date_than_the_module_in_the_archive33 + #13#10 +
              JVCSRES_Are_you_sure_you_want_to_overwrite_all_changes_of_the_existing_file63,
              [ExtractFileName(OldFile)])), cMsgBoxCaption, MB_YESNOCANCEL or
              MB_DEFBUTTON2 or MB_ICONWARNING) <> idYes then
              Exit;
          end;
          // if _StrToInt(AppSrvClient1.Answer.Fields[8]) <> CRCInt(OldFile, Mess) then begin
        end; // if FieldByName('FTIME').AsDateTime...
      end; // if FileExists(OldFile) then begin
      AppSrvClient1.Answer.Next;
    end; // while not AppSrvClient1.Answer.EoF do begin
  end; // with DataModule1 do begin

  TargetFile := TargetDir + Module;
  NotReadOnlyFilter :=
    jvcsReadString(sBaseRegistryKey + crbFilters, 'Writeable files', dfNotReadOnly);
  // readonly ?
  SetROFlag := (not CheckedOutByMe) and
    (not (MatchWithFilter(ExtractFileName(TargetFile), NotReadOnlyFilter)));

  FuncRes := GetBlobs( DBModule.GetJvcsConnection, SelectedProjectID, ServerUserID,
    StrToInt(ModuleID), StrToInt(RevisionID),
    False{CheckOut}, Application, Self,
    SetROFlag{SetReadOnly}, False{CloseIDEView},
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
    if Length(AffectedFiles) > 1 then
      Delete(AffectedFiles, Length(AffectedFiles), 1);
    Mess := Format('<%s>' + #13#10 + JVCSRES_successfully_created46,
      [TargetFile]) + #10#13 + Format(JVCSRES_40Affected_files58_37s41, [AffectedFiles]);
    MessageBox(WindowHandle, PChar(Mess),
      cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectTree.Revisionlabels1Click(Sender: TObject);
var
  RevisionID, ModuleID, ModuleName, Version, Revision: string;
begin
  if TreeView1.Selected = nil then
    Exit;
  RevisionID := IntToStr(TTVData(TreeView1.Selected.Data^).ID);
  if (_StrToInt(RevisionID) = 0) then
  begin
    ShowMessage(Format(JVCSRES_63RevisionID58_37d, [RevisionID]));
    Exit;
  end;

  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_REVISION_STATUS';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [RevisionID]);
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
      ModuleName := AppSrvClient1.Answer.Fields[1];
      Version := AppSrvClient1.Answer.Fields[4];
      Revision := AppSrvClient1.Answer.Fields[5];
    end;
  end; // with DataModule1 do begin

  VCSAssignLabels := TVCSAssignLabels.Create(Application);
  try
    VCSAssignLabels.Left := Left + 40;
    VCSAssignLabels.Top := Top + 40;
    VCSAssignLabels.RevisionID := RevisionID;
    VCSAssignLabels.ModuleID := ModuleID;
    VCSAssignLabels.ModuleName := ModuleName + ' V' + Version + '.' + Revision;
    VCSAssignLabels.ShowModal;
  finally
    VCSAssignLabels.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectTree.BackupTree(const ABackupType: TBackupTreeType;
  const ATreeNode: TTreeNode);
var
  RootDir, TMPDirectory, ActDir, FileName, TargetFile, TargetFileName, ModuleID, RevisionID,
  Version, Revision, Mess, ErrMsg, AffectedFiles: string;
  RevisionNumbers : TStringList;
  FuncRes, I: Integer;
  ShellInfo: {$IFDEF COMPILER12_UP}TSHFileOpStructW {$ELSE}TSHFileOpStructA {$ENDIF};

  FileDir: string;
  J: Integer;
  UseLegacyMethod: Boolean;
  OutputFormat,
  TargetFileFmt: string;
  OutputName: string;
  str_Options_Caption, str_Options_ZipFileCaption: string;
  str_collecting_revisions, str_get_revisions, str_compress: string;
begin
  if sBaseRegistryKey<>'' then
    FileDir := jvcsReadString(sBaseRegistryKey + crbOptions, 'BackupPath', '');
  if FileDir = '' then
    FileDir := jclSysInfo.GetCommonAppdataFolder + '\jedi\jvcs\backup\';

  if ABackupType = btProject then
  begin
    OutputName := SelectedProjectName;
    TargetFileName := FileDir + ChangeFileExt(OutputName, '.zip');

    str_Options_Caption := JVCSRES_Backup_Tree_Options;
    str_Options_ZipFileCaption := JVCSRES_Backup_40Zip41_File;
    str_collecting_revisions := JVCSRES_Project_backup_45_collecting_revisions464646;
    str_get_revisions := JVCSRES_Project_backup_45_get_revisions464646;
    str_compress := JVCSRES_Project_backup_45_compress_backup464646;
  end
  else
  if (ABackupType = btModule) and Assigned(ATreeNode) then
  begin
    OutputName := StrReplaceChars(ATreeNode.Text, ['.', ' '], '_');
    TargetFileName := FileDir + ChangeFileExt(OutputName, '.zip');

    str_Options_Caption := JVCSRES_Module_Dump_Options;
    str_Options_ZipFileCaption := JVCSRES_Dump_40Zip41_File;
    str_collecting_revisions := JVCSRES_Module_dump_45_collecting_revisions464646;
    str_get_revisions := JVCSRES_Module_dump_45_get_revisions464646;
    str_compress := JVCSRES_Module_dump_45_compress_dump464646;
  end
  else
  if (ABackupType = btModuleVersion) and Assigned(ATreeNode) and Assigned(ATreeNode.Parent) then
  begin
    OutputName := StrReplaceChars(ATreeNode.Parent.Text + '_' + ATreeNode.Text, ['.', ' '], '_');
    TargetFileName := FileDir + ChangeFileExt(OutputName, '.zip');

    str_Options_Caption := JVCSRES_Module_Version_Dump_Options;
    str_Options_ZipFileCaption := JVCSRES_Dump_40Zip41_File;
    str_collecting_revisions := JVCSRES_Module_Version_dump_45_collecting_revisions464646;
    str_get_revisions := JVCSRES_Module_Version_dump_45_get_revisions464646;
    str_compress := JVCSRES_Module_Version_dump_45_compress_dump464646;
  end
  else
    OutputName := '';

  if (OutputName <> '') and
      GetBackupTreeOptions( str_Options_Caption
                          , str_Options_ZipFileCaption
                          , TargetFileName
                          , OutputFormat
                          ) then
  begin
    GetDir(0, ActDir);
    jvcsWriteString(sBaseRegistryKey + crbOptions, 'BackupPath', ExtractFilePath(TargetFileName));
    try
      // TMP - Verzeichnis ?
      TMPDirectory := jvcsReadString(sBaseRegistryKey + crbOptions, 'TempDirectory', '');
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

      RootDir := TMPDirectory + '_' + OutputName + '_\';
      try
        RevisionNumbers := TStringList.Create;
        try
          VCSProgress := TVCSProgress.Create(Self);
          VCSProgress.SetText(str_collecting_revisions);
          if ABackupType = btProject then
            VCSProgress.SetPBMax(TreeView1.Items.Count)
          else
          if ABackupType in [btModule, btModuleVersion] then
            VCSProgress.SetPBMax(ATreeNode.Count);
          VCSProgress.SetPBPos(0);
          VCSProgress.Left := Left + 40;
          VCSProgress.Top := Top + 60;
          VCSProgress.Show;
          Application.ProcessMessages;
          if ABackupType = btProject then
          begin
            for I := 0 to TreeView1.Items.Count - 1 do
            begin
              if TreeView1.Items[I].Level = 3 then
              begin
                RevisionID := IntToStr(TTVData(TreeView1.Items[I].Data^).ID);
                RevisionNumbers.Add(RevisionID);
              end;
              VCSProgress.SetPBPos(I);
            end; // for I := 0 to TreeView1.Items.Count - 1 do begin
          end
          else
          if ABackupType = btModule then
          begin
            for I := 0 to ATreeNode.Count - 1 do
            begin
              for J := 0 to Pred(ATreeNode.Item[I].Count) do
              begin
                RevisionID := IntToStr(TTVData(ATreeNode.Item[I].Item[J].Data^).ID);
                RevisionNumbers.Add(RevisionID);
              end;
              VCSProgress.SetPBPos(I);
            end;
          end
          else
          if ABackupType = btModuleVersion then
          begin
            for I := 0 to ATreeNode.Count - 1 do
            begin
              RevisionID := IntToStr(TTVData(ATreeNode.Item[I].Data^).ID);
              RevisionNumbers.Add(RevisionID);
              VCSProgress.SetPBPos(I);
            end;
          end;

          VCSProgress.SetText(str_get_revisions);
          VCSProgress.SetPBMax(RevisionNumbers.Count);
          VCSProgress.SetPBPos(0);
          VCSProgress.Show;
          Application.ProcessMessages;
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
                Version := AppSrvClient1.Answer.Fields[4];
                Revision := AppSrvClient1.Answer.Fields[5];
                FileDir := AppSrvClient1.Answer.Fields[2];
              end;
            end; // with DataModule1 do begin

            {
              quick switch for changing between new and old version
              "if true then" or "if false then" would do the same but
              "if UseLegacyMethod then" is better
            }
            UseLegacyMethod := False;
            if UseLegacyMethod then
            begin
              TargetFile := RootDir + FileName + '\Version' + Version + '\Revision' +
                Revision + '\' + FileName;

              FuncRes := GetBlobs(DBModule.GetJvcsConnection , SelectedProjectID,
                ServerUserID, StrToInt(ModuleID), StrToInt(RevisionNumbers.Strings[I]),
                False{CheckOut}, Application, Self,
                False{SetReadOnly}, False{CloseIDEView},
                False{SetCurrentDate},
                TargetFile, ErrMsg, AffectedFiles);
            end
            else // if UseLegacyMethod then
            begin
              while Pos(':', FileDir) > 0 do
                FileDir[Pos(':', FileDir)] := '_';

          {
           LegacyVersion
           unit1.pas\Version0\Revision1\unit1.pas
           unit1.pas\Version0\Revision1\unit1.dfm
           unit1.pas\Version0\Revision2\unit1.pas
          }
          //      OutputFormat := '%MODNAME%.%MODEXT%\Version%VER%\Revision%REV%\%MODNAME%.%REVEXT%';
          {
            projectdir\unit1_00_001.pas
            projectdir\unit1_00_001.dfm
            projectdir\unit1_00_002.pas
          }
          //      OutputFormat := '%MODPATH%\%MODNAME%_%.2VER%_%.3REV%.%REVEXT%';

          {
            projectdir\unit1.pas.00.001
            projectdir\unit1.dfm.00.001
            projectdir\unit1.pas.00.002
          }
          //      OutputFormat := '%MODPATH%\%MODNAME%.%REVEXT%.%.2VER%.%.3REV%';

              TargetFile := OutputFormat;
              TargetFile := StringReplace(TargetFile, '%MODPATH%',
                ClearBackSlash(FileDir), [rfReplaceAll]);
              TargetFile := StringReplace(TargetFile, '%MODNAME%',
                ChangeFileExt(FileName, ''), [rfReplaceAll]);
              TargetFile := StringReplace(TargetFile, '%MODEXT%',
                ExtractFileExtWithoutDot(FileName), [rfReplaceAll]);
              TargetFile := StringReplace(TargetFile, '%VER%', Version, [rfReplaceAll]);
              TargetFile := StringReplace(TargetFile, '%.2VER%',
                Format('%.2d',[StrToIntDef(Version,0)]), [rfReplaceAll]);
              TargetFile := StringReplace(TargetFile, '%.3REV%',
                Format('%.3d',[StrToIntDef(Revision,0)]), [rfReplaceAll]);
              TargetFile := StringReplace(TargetFile, '%REV%', Revision, [rfReplaceAll]);

              TargetFile := RootDir + TargetFile;

              TargetFileFmt := TargetFile;

              TargetFile := StringReplace(TargetFile, '%REVEXT%',
                ExtractFileExtWithoutDot(FileName), [rfReplaceAll]);

              FuncRes := GetBlobsEx ( DBModule.GetJvcsConnection
                                    , SelectedProjectID
                                    , ServerUserID
                                    , StrToInt(ModuleID)
                                    , StrToInt(RevisionNumbers.Strings[I])
                                    , False{CheckOut}
                                    , Application
                                    , Self
                                    , False{SetReadOnly}
                                    , False{CloseIDEView}
                                    , False{SetCurrentDate}
                                    , TargetFile
                                    , ErrMsg
                                    , Nil{AffectedFilesList}
                                    , TargetFileFmt
                                    );
            end; // if UseLegacyMethod then

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
            end;
            VCSProgress.SetPBPos(I);
          end; // for I := 0 to RevisionNumbers.Count - 1 do begin

          // Prepare progress, Abbrevias progressor works with percentage so we
          // can set max to 100.
          VCSProgress.SetText(str_compress);
          VCSProgress.SetPBPos(0);
          VCSProgress.SetPBMax(100);
          Application.ProcessMessages;

          bCompressBackup := True;
          try
            // Store to Zipfile using abbrevia
            AbBackup(RootDir, TargetFileName);
          finally
            bCompressBackup := False;
          end;
        finally
          VCSProgress.Free;
          VCSProgress := nil;
          RevisionNumbers.Free;
        end;
      finally
        // ensure temporary files are deleted in the end
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
      end;
    finally
      ChDir(ActDir);
    end;
  end;
end;

procedure TVCSProjectTree.btnProjBackupClick(Sender: TObject);
begin
  BackupTree(btProject, nil);
end;

//------------------------------------------------------------------------------

procedure TVCSProjectTree.Fullexpand1Click(Sender: TObject);
begin
  TreeView1.Items.BeginUpdate;
  try
    AutoFullExpand := True;
    TreeView1.FullExpand;
    TreeView1.Selected := TreeView1.Items.GetFirstNode;
  finally
    AutoFullExpand := False;
    TreeView1.Items.EndUpdate;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectTree.Collapse1Click(Sender: TObject);
begin
  TreeView1.Items.BeginUpdate;
  try
    TreeView1.FullCollapse;
    TreeView1.Selected.Expanded := True;
  finally
    TreeView1.Items.EndUpdate;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectTree.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSProjectTree.TreeView1Change(Sender: TObject;
  Node: TTreeNode);
begin
  PopupMenu2Popup(Self);
end;

//------------------------------------------------------------------------------

procedure TVCSProjectTree.TreeView1Expanding(Sender: TObject;
  Node: TTreeNode; var AllowExpansion: Boolean);
var 
  I, RevisionID: Integer;
  NewNode: TTreeNode;
  CheckIComment, CheckOComment, ModuleBaseName, OriginalPath: string;
  MemberList: TStringList;
begin
  if (not AutoFullExpand) and (Node.Level = 3) and
    (TTVData(Node.Data^).State = 0) then
  begin
    CheckIComment := '';
    CheckOComment := '';
    TTVData(Node.Data^).State := 1;
    RevisionID := TTVData(Node.Data^).ID;
    MemberList := TStringList.Create;
    try
      with DataModule1 do 
      begin
        AppSrvClient1.Request.Rewrite;
        AppSrvClient1.FunctionCode := 'GET_REVISION_STATUS';
        AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
        AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
        AppSrvClient1.Request.WriteFields(True, [RevisionID]);
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
          ModuleBaseName := AppSrvClient1.Answer.Fields[1];
          OriginalPath := AppSrvClient1.Answer.Fields[2];
        end;
        while not AppSrvClient1.Answer.Eof do 
        begin
          MemberList.Add(ChangeFileExt(ModuleBaseName,
            TrimRight(AppSrvClient1.Answer.Fields[10])) + ' - ' +
            DateTimeToStr(GMTStr2LocalDateTime(AppSrvClient1.Answer.Fields[6])) + ' - ' +
            AppSrvClient1.Answer.Fields[7] + ' Bytes - $' +
            IntToHex(_StrToInt(AppSrvClient1.Answer.Fields[8]), 8)
            );
          AppSrvClient1.Answer.Next;
        end; // while not AppSrvClient1.Answer.EoF do begin

        AppSrvClient1.Request.Rewrite;
        AppSrvClient1.FunctionCode := 'GET_REVISION_COMMENT';
        AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
        AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
        AppSrvClient1.Request.WriteFields(True, [RevisionID]);
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
        if AppSrvClient1.Answer.Fields[0] <> '' then
          CheckIComment := AppSrvClient1.Answer.Fields[0];
        if AppSrvClient1.Answer.Fields[1] <> '' then
          CheckOComment := AppSrvClient1.Answer.Fields[1];
      end; // with DataModule1 do begin

      if OriginalPath <> '' then 
      begin
        NewNode := TreeView1.Items.AddChild(Node, OriginalPath);
        NewNode.ImageIndex := LibIcon;
        NewNode.SelectedIndex := LibIcon;
        NewNode.StateIndex := -1;
      end;
      if CheckIComment <> '' then 
      begin
        NewNode := TreeView1.Items.AddChild(Node, '<- ' + CheckIComment);
        NewNode.ImageIndex := CommentIcon;
        NewNode.SelectedIndex := CommentIcon;
        NewNode.StateIndex := -1;
      end;
      if CheckOComment <> '' then 
      begin
        NewNode := TreeView1.Items.AddChild(Node, '-> ' + CheckOComment);
        NewNode.ImageIndex := CommentIcon;
        NewNode.SelectedIndex := CommentIcon;
        NewNode.StateIndex := -1;
      end;
      for I := 0 to MemberList.Count - 1 do 
      begin
        NewNode := TreeView1.Items.AddChild(Node, MemberList.Strings[I]);
        NewNode.ImageIndex := IDEIcon;
        NewNode.SelectedIndex := IDEIcon;
        NewNode.StateIndex := -1;
      end; // for I := 0 to MemberList.Items.Count - 1 do begin

      AllowExpansion := True;
    finally
      MemberList.Free;
    end;
  end; // if (not AutoFullExpand) and (Node.Level = 3) and...
end;

//------------------------------------------------------------------------------

procedure TVCSProjectTree.CompareRevision1Click(Sender: TObject);
var 
  ModuleID, CompareFile: string;
  SelectedIndex, RevisionID: Integer;
begin
  if TreeView1.Selected = nil then 
    Exit;
  RevisionID := TTVData(TreeView1.Selected.Data^).ID;

  ModuleID := '';
  with TreeView1 do 
  begin
    SelectedIndex := Selected.AbsoluteIndex;
    while (SelectedIndex > 0) and (Items[SelectedIndex].Level > 1) do 
    begin
      Dec(SelectedIndex);
      if Items[SelectedIndex].Level = 1 then
      begin
        ModuleID := IntToStr(TTVData(Items[SelectedIndex].Data^).ID);
        Break;
      end;
    end;
  end; // with TreeView1 do begin

  if (ModuleID <> '') then
    CompareFile := GetModuleName(ModuleID)
  else
    Exit;

  if CompareFile = '' then
    Exit;
  ResolveFileFamilies(CompareFile);

  DoModuleCompare(CompareFile, CompareFile, RevisionID);
end;

//------------------------------------------------------------------------------

procedure TVCSProjectTree.spBtnDescriptionClick(Sender: TObject);
begin
  if ModuleDescription1.Enabled then
    ModuleDescription1Click(Self)
  else
    ProjectDescription1Click(Self);
end;

//------------------------------------------------------------------------------

procedure TVCSProjectTree.ModuleDescription1Click(Sender: TObject);
begin
  if TreeView1.Selected = nil then
    Exit;
  HandleDescription(2, TTVData(TreeView1.Selected.Data^).ID,
    Format(JVCSRES_38Module58_37s, [TreeView1.Selected.Text]));
end;

//------------------------------------------------------------------------------

procedure TVCSProjectTree.ProjectDescription1Click(Sender: TObject);
begin
  HandleDescription(1, SelectedProjectID, Format(JVCSRES_38Project58_37s, [SelectedProjectName]));
end;

//------------------------------------------------------------------------------

procedure TVCSProjectTree.HandleDescription(const DescType, ID: Integer;
  const DescCaption: string);
var
  Description: string;
begin
  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_UPDATE_DESCRIPTION';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [DescType]);
    AppSrvClient1.Request.WriteFields(False, [ID]); // id
    AppSrvClient1.Request.WriteFields(False, [False]); // update
    AppSrvClient1.Request.WriteFields(False, ['']); // text
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
    Description := '';
    if not AppSrvClient1.Answer.Eof then
      Description := AppSrvClient1.Answer.Fields[0];

    VCSDescription := TVCSDescription.Create(Application);
    try
      VCSDescription.Top := Top + 60;
      VCSDescription.Left := Left + 60;
      VCSDescription.DescType := DescType;
      VCSDescription.SetDescripCaption(DescCaption);
      VCSDescription.SetDescription(Description);
      VCSDescription.EnableCheckBox(False);
      VCSDescription.ShowModal;
      Description := VCSDescription.Description;
    finally
      VCSDescription.Free;
    end;

    if Description <> '' then
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_UPDATE_DESCRIPTION';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [DescType]);
      AppSrvClient1.Request.WriteFields(False, [ID]); // id
      AppSrvClient1.Request.WriteFields(False, [True]); // update
      AppSrvClient1.Request.WriteFields(False, [Description]); // text
      SetupTimeoutCounter;
      AppSrvClient1.Send;

      while WaitForAppSrvClient do
        Application.ProcessMessages;
      if (AppSrvClientErr = -99) then
      begin
        ShowServerTimeOut(WindowHandle);
      end;
      if (AppSrvClientErr <> 0) or
        (AppSrvClient1.AnswerStatus <> '200') then
      begin
        ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
          AppSrvClient1.AnswerStatus);
      end;
    end;
  end; // with DataModule1 do begin
end;

procedure TVCSProjectTree.spBtnDumpClick(Sender: TObject);
begin
  if Assigned(TreeView1.Selected) then
  begin
    case TreeView1.Selected.Level of
      0: BackupTree(btProject, nil);
      1: BackupTree(btModule, TreeView1.Selected);
      2: BackupTree(btModuleVersion, TreeView1.Selected);
    end;
  end;
end;

procedure TVCSProjectTree.AbBackup(const sBaseDir, sZipFile : String);
var
  AbArchive : TAbZipArchive;
begin
  Assert((trim(sBaseDir)<>'') and (Trim(sZipFile)<>''));

  AbArchive := TAbZipArchive.Create(sZipFile, fmCreate or fmShareDenyNone);
  try
    // set some basic options
    AbArchive.StoreOptions := [soRecurse];
    AbArchive.BaseDirectory := JclFileUtils.PathAddSeparator(sBaseDir);

    // now the event handlers
    AbArchive.InsertHelper := AbInsertHelper;
    AbArchive.OnArchiveProgress := AbOnArchiveProgress;

    // add all files from temporary directory
    AbArchive.AddFiles('*.*', 0);

    // and store to disk
    AbArchive.Save;
  finally
    AbArchive.free;
  end;
end;

//------------------------------------------------------------------------------
// Necessary Zip-Handler for TZipArchiver
procedure TVCSProjectTree.AbInsertHelper( Sender : TObject; Item : TAbArchiveItem;
                                        OutStream : TStream );
begin
  AbZip( TAbZipArchive(Sender), TAbZipItem(Item), OutStream );
end;


//------------------------------------------------------------------------------
// Storing progressor
procedure TVCSProjectTree.AbOnArchiveProgress(Sender : TObject; Progress : Byte; var Abort : Boolean);
begin
  if bCompressBackup then
  begin
    if Assigned(VCSProgress) then
    begin
      VCSProgress.SetPBPos(Progress);
    end;
  end;
end;



end.
