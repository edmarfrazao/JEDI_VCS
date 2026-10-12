(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: Syncronice.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS: Thomas Huber (Thomas_D_Huber@gmx.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
Dec/03
- Usc: Should there be a ESC hint while Verify in Caption and other
       handling when Verify was aborted ?
Oct/04
- USc: possible translation bug -> see icbReferencesChange
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FreeVCS code to JEDI VCS
2003/02/09  WKlein    - Fixed bug with "target folder = origin folder"
2003/02/12  USchuster - changed DSAMsg with JVCSDialogs in uses clause to use JvDSADialogs
2003/02/18  MGosselink- emptied some .text props, changed Led color green to lime
2003/02/18  THuber    - changed TJvHTComboBox => TJvComboBox
2003/02/24  FBouwmans - Replaced TSpinEdit by TJvSpinEdit
                      - Changed JvSpinEDit to standard style (not diagonal)
2003/03/05  THensle   - changes for "ConfigStorage" unit
2003/03/08  THensle   - changes for ConfigStorage unit (IDE DLL)
2003/03/10  USchuster - exchanged TjvMruList with TJVCSMruList (mantis #727)
                      - disabled the AutoSave property in rcbxNewFolder
                        and removed the regkeys (they where wrong and
                        loading and saving is no done with MruListNewFolder)
                      - removed rcbxNewFolder.AutoSave.SaveValue
                      - the selected folder will also be inserted into the
                        combobox now
                      - set anchors of ecbxKeyword and rcbxNewFolder
2003/03/15  THuber    - compilerwarnings/hints (most)
2003/03/23  USchuster - mantis #791
                        - now the verifymethod (CRC32 or not) will be saved
                          (currently 'newer' or 'different' in non CRC32 Mode
                           won't be saved !)
                        - now it is possible to remove hidden files in targetfolder
                          and you will get a Yes/No ConfirmationMsg before removing
                        - now files which are checked out by you will only
                          checked for synchronizing when
                          'Include M. checked out by me' is checked
                        - before overwriting a file which is checked out by you
                          you will get a No/Yes WarnMsg
                        - in 'Create From DB' Mode all these new issue #791 stuff
                          is disabled except the overwriting WarnMsg
2003/04/08  USchuster - changes for IDEInterface
2003/04/10  USchuster - fixed mantis bug #791/4.
2003/05/02  USchuster - selected module member will be delivered to
                        TextComp (mantis #880/4.)
                      - fixed GetHiddenAndChkOutByMeModules
2003/05/27  USchuster - fixed bug in connection with removed hidden modules in
                        sync result
                      - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes
2003/09/08  USchuster - added ability to ignore modules (mantis #1019)
                      - fixed mantis #1021
                      - fixed counting of the hidden modules
2003/10/21  USchuster - separated Select/Unselect of the listbox entrys and added
                        sorting of the listviews over column header (mantis #1160)
                      - use new constant for messagebox caption
2003/11/09  USchuster - exchanged TextComp call with new procedure DoModuleCompare (mantis #1204)
2003/12/08  USchuster - modules checked out by you won't get the RO Flag (mantis #1220)
                      - it's possible to abort the verify process (mantis #1214)
2003/12/27  THuber    - TimeConst now from JVCSClientConsts
2004/02/24  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/02/27  USchuster - reassigned dropped imagelist to TJvImageComboBox
                      - minor style cleaning (casing and comments)
                      - reenabled ImageIndex handling in project combobox
                      - moved some strings to JVCSGUIClientResources.pas and
                        use new messagebox procedures from JVCSDialogs.pas
                      - AutoComplete in ComboBoxes is now False and the style of the
                        LabelCheckBox is now csDropDownList
2004/04/12  USchuster - fixed bug in 'Create from DB' mode
                        (exception in access to icbReferences.Items[icbReferences.ItemIndex]
                         caused by an empty entry for icbReferences in .dfm)
                      - changed to use TJvSpinEdit.AsInteger instead of Round(TJvSpinEdit.Value)
                      - changed to use new sort function from VCSProcBase
2004/07/17  THuber    - AutoResort deactivated during possible long term loads
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/09  USchuster - style cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/10/17  THuber    - res string fixed
2004/10/27  Victorious - icbReferences, cbAllAtOnce is absolete
                       - Added Project Tree on left side of form
                       - rewriting code. Procedures from Button events (Sync, Resore Revision,
                         Labeled, Rollback) are born. Added support for multiple project processing
                       - Moved TransLED1 to Status Bar
2004/10/31  USchuster  - D5 fix and minor reformating
                       - moved resourcestrings to JVCSGUIClientResources.pas
2004/11/02  Victorious - resolved issue 0002030 + minor tweaks
                       - save cbROFlag state to registry
2004/11/03  Victorious - performance issues
                       - Added option to disable loading tree and ability to load tree manually.
                       - GetHiddenAndChkOutByMeModules_ByProject changed for using GET_LOCKED_MODULES
                         when Include hidden M. unchecked
                       - removed superfluous call of GetHiddenAndChkOutByMeModules in Sync_Project_List
2004/12/31  Victorious - issue 0002309: sychronize by RO flag fails if pas file has +R and dfm file has -R fixed
2005/01/07  DBelanger  - resolved mantis issue #2471
2005/01/09  USchuster  - changed to use KeyDown instead of KeyUp event and set
                         Cancel to False on Close button to prevent that pressing
                         ESC in Compare dialog closes Sync as well (mantis #2475)
                       - replaced OutputDebugString with JclDebug.Trace
2005/01/25  Victorious - restoring functionality of Mode Selection Box as in ver 0.31
2005/04/03  USchuster  - added ModuleID to DoModuleCompare call to fix mantis #2820
2005/04/11  CSchuette  - mantis #2815
2005/04/25  CSchuette  - added call to "ResolveFileFamilies" to fix mantis #1205
2005/06/30  CSchuette  - added additional check if file was *really* re-loaded from Delphi IDE, mantis #3061
                       - replaced MsgWarn with ErrorMessageBox or WarnMessageBox
                       - fixed mantis #2308
2005/07/10  CSchuette  - modified changes for #3061 again
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 released ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
2006/07/09  USchuster  - improved "remove hidden modules" question (mantis #3800)
2007/06/30  USchuster  - changes for large fonts (contraints and default size depend now on PixelsPerInch; analog to Mantis #3710)                      
2007/08/13  USchuster  - Trace -> TraceMsg
2008/12/22  THuber     - Baseclass changed to TJVCSForm
2009/11/27  USchuster  - added "Diff" button which shows a compressed Diff
2011/01/15  USchuster  - changed font to Tahoma
2012/07/08  AKroeber  - changed AnsiCrLf to sLineBreak (avoid using of JclAnsiString.pas - should work from Delphi 6 to XE2)

-----------------------------------------------------------------------------*)


unit Syncronice;

{$I jedi.inc}
{$I compopt.inc}

{$IFDEF DELPHI6_UP}
  {$WARN UNIT_PLATFORM OFF}
  {$WARN SYMBOL_PLATFORM OFF}
{$ENDIF DELPHI6_UP}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, Menus, ComCtrls, ImgList, JvSpin,
  JvLED, dfsStatusBar, JvCombobox, JvListView, JvComponent, JVCSMruList,
  Mask, JvMaskEdit, JvEdit, JVCSClasses, EnhListView, JvExMask,
  JvExControls, JvExStdCtrls, JvListComb, JvExComCtrls, JvComCtrls,
  JvCheckTreeView, JvExExtCtrls, JvNetscapeSplitter, JVCSForms;

type
  TProjectSearchRec = record
    All: Integer;
    Diff: Integer;
    NotFound: Integer;
    InSync: Integer;
  end;

  TTransState = (tsDisabled, tsGo, tsWait, tsStop);

  TVCSSync = class(TJVCSForm)
    Panel1: TPanel;
    btnSync: TButton;
    btnClose: TButton;
    Panel3: TPanel;
    GroupBox1: TGroupBox;
    rbChkInfld: TRadioButton;
    rbNewfldr: TRadioButton;
    spBtnBrowse: TSpeedButton;
    btnVerify: TButton;
    PopupMenu1: TPopupMenu;
    HelpTopicF11: TMenuItem;
    SelectAll1: TMenuItem;
    N1: TMenuItem;
    btnCompare: TButton;
    GroupBox3: TGroupBox;
    rbselOld: TRadioButton;
    rbSelDiff: TRadioButton;
    SysImageList: TImageList;
    StateImageList: TImageList;
    TimerCloseForm: TTimer;
    Panel5: TPanel;
    PageControl1: TPageControl;
    SheetDate: TTabSheet;
    lvDateItems: TdfsEnhListView;
    SheetKey: TTabSheet;
    Panel4: TPanel;
    Label2: TLabel;
    lvKWItems: TdfsEnhListView;
    Panel6: TPanel;
    cbReload: TCheckBox;
    cbSummary: TCheckBox;
    cbInclHidden: TCheckBox;
    SheetVer: TTabSheet;
    Panel7: TPanel;
    Label1: TLabel;
    lvVersion: TdfsEnhListView;
    speVer: TJvSpinEdit;
    speRev: TJvSpinEdit;
    Label4: TLabel;
    btnHistory: TButton;
    cbCRC32: TCheckBox;
    Help: TSpeedButton;
    mmiHideUncheckedModules: TMenuItem;
    N2: TMenuItem;
    btnReport: TButton;
    SheetRollBack: TTabSheet;
    Date: TLabel;
    lvRollBack: TdfsEnhListView;
    dtpRollbackDate: TDateTimePicker;
    dtpRollbackTime: TDateTimePicker;
    StatusBar: TdfsStatusBar;
    rcbxNewFolder: TJvComboBox;
    ecbxKeyword: TJvComboBox;
    cbRemoveHidden: TCheckBox;
    cbInclChkOutByMe: TCheckBox;
    N3: TMenuItem;
    mmiIgnoreModuleRevision: TMenuItem;
    UnselectAll1: TMenuItem;
    pm_tv_Project_List: TPopupMenu;
    FullExpand1: TMenuItem;
    FullCollapce1: TMenuItem;
    CheckAll1: TMenuItem;
    UncheckAll1: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    CheckBranch1: TMenuItem;
    UncheckBranch1: TMenuItem;
    JvNetscapeSplitter1: TJvNetscapeSplitter;
    btnSearchFiles: TButton;
    TransLED1: TJvLED;
    cbROFlag: TCheckBox;
    pan_Project_List: TPanel;
    tv_Project_List: TJvCheckTreeView;
    cbLoadProjectTree: TCheckBox;
    sbLoadProjectTree: TSpeedButton;
    btnDiff: TButton;
    procedure btnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure rbChkInfldClick(Sender: TObject);
    procedure spBtnBrowseClick(Sender: TObject);
    procedure btnVerifyClick(Sender: TObject);
    procedure btnSyncClick(Sender: TObject);
    procedure HelpTopicF11Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SelectAll1Click(Sender: TObject);
    procedure btnCompareClick(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure rbselOldClick(Sender: TObject);
    procedure lvDateItemsClick(Sender: TObject);
    procedure lvDateItemsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TimerCloseFormTimer(Sender: TObject);
    procedure lvDateItemsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure HelpClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure speVerChange(Sender: TObject);
    procedure btnHistoryClick(Sender: TObject);
    procedure ecbxKeywordChange(Sender: TObject);
    procedure mmiHideUncheckedModulesClick(Sender: TObject);
    procedure cbCRC32Click(Sender: TObject);
    procedure btnReportClick(Sender: TObject);
    procedure dtpRollbackDateChange(Sender: TObject);
    procedure cbInclHiddenClick(Sender: TObject);
    procedure mmiIgnoreModuleRevisionClick(Sender: TObject);
    procedure lvSortItems(Sender: TObject; Item1,
      Item2: TListItem; SortColumn: Integer; var SortAs: TSortAs;
      var CompResult: Integer);
    procedure CheckAll1Click(Sender: TObject);
    procedure UncheckAll1Click(Sender: TObject);
    procedure FullExpand1Click(Sender: TObject);
    procedure FullCollapce1Click(Sender: TObject);
    procedure CheckBranch1Click(Sender: TObject);
    procedure UncheckBranch1Click(Sender: TObject);
    procedure btnSearchFilesClick(Sender: TObject);
    procedure StatusBarPanels1DrawPanel(StatusBar: TdfsStatusBar;
      Panel: TdfsStatusPanel; const Rect: TRect);
    procedure sbLoadProjectTreeClick(Sender: TObject);
    procedure cbROFlagClick(Sender: TObject);
  private
    { Private-Deklarationen}
    FCreated,
    SkipROCheck,
    KWSet: Boolean;
    AllSyncP,
    AllSyncM,
    RootProjectID: Integer;
    SelectedProjectName,
    OriginalProjectName,
    SBTextBuffer,
    ActDir: string;
    LabelIDs: TStringList;
    ProjectIDChanged: Boolean;
    MruListNewFolder: TJVCSMruList;
    FHiddenModuleList,
    FChkOutByMeModuleList: TSortedIntegerList;
    FIgnoredModuleList: TIgnoredModuleList;
    FIsInVerify: Boolean;
    FPressedEsc: Boolean;
    FProject_Tree_Loaded: Boolean;
    FRemoveHiddenFilesYesToAll: Boolean;
    function GetCurrLV: TdfsEnhListView;
    procedure CheckMembers(CurrLV: TdfsEnhListView; SearchIndex, NewState: Integer;
      RevisionID: string; NewDiffType: string);
    function SelectModules(Project_ID: Integer; Target: string; var AIgnoredModules,
      AIgnoredFiles, ACheckedOutModules, ACheckedOutFiles: Integer): Integer;
    procedure HideUncheckedModules;
    function GetListViewString(LV: TdfsEnhListView): string;
    procedure ShowStatusBarGauge(const ShowGauge, Indeterminate: Boolean);
    procedure StatusBarGaugePos(Value: Word);

    function IsChkOutByMe(AModuleID: Integer): Boolean;
    function IsDontSyncChkOutByMeEnabled: Boolean;
    function IsHiddenFile(AModuleID: Integer): Boolean;
    function IsRemoveHiddenEnabled: Boolean;
    procedure GetHiddenAndChkOutByMeModules_ByProject(Project_ID: Integer);
    procedure GetHiddenAndChkOutByMeModules;
    function DeleteHiddenFiles(AModuleName: string; ARevisionID: Integer;
      var ErrMsg, AffectedFiles: string): Integer;
    function IsIgnoredModule(AModuleID, ARevisionID: Integer;
      APath: string): Boolean;
    function IsIgnoreModulesEnabled: Boolean;
    procedure CheckAllListViewItems(AListView: TdfsEnhListView; ANewState: Integer);
    procedure Fill_ProjectTree(Project_ID: Integer; Complete: Boolean);
    procedure Clear_ProjectTree;
    procedure tv_Project_List_CheckAll(Value: Boolean);
    procedure tv_Project_List_CheckBranch(Node: TTreeNode; Value: Boolean);
    procedure Reload_Wait4Server;
    procedure Reload_ProcessAnswer(Project_ID: Integer;
      var Res: TProjectSearchRec; Lv_Target: TdfsEnhListView);
    procedure Reload_Project(ProjectID: Integer; var Res: TProjectSearchRec);
    procedure Reload_Version(ProjectID: Integer; var Res: TProjectSearchRec);
    procedure Reload_Labeled(ProjectID: Integer; LabelID: string; var Res: TProjectSearchRec);
    procedure Reload_Rollback(ProjectID: Integer; var Res: TProjectSearchRec);
    procedure Reload_Project_Contents(Mode: Integer);
    procedure VerifyProject(Project_ID: Integer; var Mess: string; var Res: TProjectSearchRec);
    procedure VerifyProject_List(Mode: Integer);
    procedure SetSyncCaption;
    procedure Sync_Project(ProjectID: Integer; var Res: TProjectSearchRec; Target: string; var Mess: string);
    procedure Sync_Project_List(Mode: Integer);
    procedure SetTransState(Status: TTransState);
    function IsSyncROFlagEnabled: Boolean;
    procedure SetProject_Tree_Loaded(const Value: Boolean);
    property Project_Tree_Loaded: Boolean read FProject_Tree_Loaded write SetProject_Tree_Loaded;
  public
    AutoClose,
    NeedRefresh: Boolean;
    { Public-Deklarationen}
  end;

var
  VCSSync: TVCSSync;

implementation

uses
  {$IFDEF DEBUG}
  JclDebug,
  {$ENDIF DEBUG}
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  TextComp, JVCSDialogs, ShellAPI, VCSProcBase, VCSBase, SelectFolder,
  FileCtrl, HandleBlob, CheckSum, DBModule, SelectProjectID, Std_ListView,
  JVCSClientConsts, History, CommCtrl, SimpleReport, TZHandling, ConfigStorage,
  JVCSGUIClientResources, JVCSClientFunctions, JclStrings, JVCSCompressedDiffDialog;

const
  sbStatus = 0;
  sbState  = 1;
  sbStatusText = 2;
  (* List View SubItems const *)
  lvItem_Ver_Rev = 0;
  lvItem_Date = 1;
  lvItem_CRC32 = 2;
  lvItem_Original_Path = 3;
  lvItem_Module_ID = 4;
  lvItem_Revision_ID = 5;
  lvItem_Parent = 6;
  lvItem_Date_Val = 7;
  lvItem_Project_ID = 8;
  lvItem_Diff_Type = 9;

type
  TDiff_Types = (dtNoDiff, dtDateTime, dtCRC32, dtNotFound, dtReadOnly, dtReadWrite, dtRemoveHidden);
  TProject_Desc = class(TObject)
    Project_ID: Integer;
    Project_Name: string;
    LatestRes: TProjectSearchRec;
    VersionRes: TProjectSearchRec;
    LabeledRes: TProjectSearchRec;
    RollbackRes: TProjectSearchRec;
  end;

{$R *.dfm}

//------------------------------------------------------------------------------
procedure TVCSSync.FormCreate(Sender: TObject);
var
  sfi: TSHFileInfo;
  ToolTipHandle: HWND;
  DlgTop,
  DlgLeft,
  DlgWidth,
  DlgHeight: Integer;
begin
  try
    Constraints.MinHeight := MulDiv(400, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(520, PixelsPerInch, 96);
    // ListView Tooltips
    TransLED1.Parent := StatusBar;
    SetTransState(tsDisabled);
    SendMessage(lvDateItems.Handle, LVM_SETEXTENDEDLISTVIEWSTYLE, LVS_EX_INFOTIP,
      LVS_EX_INFOTIP);
    ToolTipHandle := SendMessage(lvDateItems.Handle, LVM_GETTOOLTIPS, 0, 0);
    SendMessage(ToolTipHandle, TTM_SETDELAYTIME, TTDT_AUTOMATIC, 1);
    SendMessage(ToolTipHandle, TTM_SETDELAYTIME, TTDT_AUTOPOP, 3000);
    SendMessage(lvVersion.Handle, LVM_SETEXTENDEDLISTVIEWSTYLE, LVS_EX_INFOTIP,
      LVS_EX_INFOTIP);
    ToolTipHandle := SendMessage(lvVersion.Handle, LVM_GETTOOLTIPS, 0, 0);
    SendMessage(ToolTipHandle, TTM_SETDELAYTIME, TTDT_AUTOMATIC, 1);
    SendMessage(ToolTipHandle, TTM_SETDELAYTIME, TTDT_AUTOPOP, 3000);
    SendMessage(lvKWItems.Handle, LVM_SETEXTENDEDLISTVIEWSTYLE, LVS_EX_INFOTIP,
      LVS_EX_INFOTIP);
    ToolTipHandle := SendMessage(lvKWItems.Handle, LVM_GETTOOLTIPS, 0, 0);
    SendMessage(ToolTipHandle, TTM_SETDELAYTIME, TTDT_AUTOMATIC, 1);
    SendMessage(ToolTipHandle, TTM_SETDELAYTIME, TTDT_AUTOPOP, 3000);
    SendMessage(lvRollBack.Handle, LVM_SETEXTENDEDLISTVIEWSTYLE, LVS_EX_INFOTIP,
      LVS_EX_INFOTIP);
    ToolTipHandle := SendMessage(lvRollBack.Handle, LVM_GETTOOLTIPS, 0, 0);
    SendMessage(ToolTipHandle, TTM_SETDELAYTIME, TTDT_AUTOMATIC, 1);
    SendMessage(ToolTipHandle, TTM_SETDELAYTIME, TTDT_AUTOPOP, 3000);

    //USc 21.10.2003 TdfsEnhListView doesn't publish RowSelect and thatwhy
    // we must set it here
    lvDateItems.RowSelect := True;
    lvVersion.RowSelect := True;
    lvKWItems.RowSelect := True;
    lvRollBack.RowSelect := True;

    // Aktuelles Verzeichnis speichern
    GetDir(0, ActDir);
    NeedRefresh := False;
    ProjectIDChanged := False;
    {$IFNDEF IDEDLL}
    cbReload.Enabled := False;
    {$ENDIF ~IDEDLL}

    // Abfrage nach Zeitverzögerung (Registry-Hack)
    if jvcsReadBool(sBaseRegistryKey + cRegSwJVCSBase, 'DlgNoWait', False) then
      TimerCloseForm.Interval := 1;

    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    //??? GlobalSettings
    if not SettingIsGlobal(17) then
      SkipROCheck := jvcsReadBool(sBaseRegistryKey + crbOptions, 'NoROCheck', False)
    else
      SkipROCheck := GlobalSettingValue(17);

    cbInclHidden.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbWindows, 'Sync_IncludeHidden', False);

    cbROFlag.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbWindows, 'Sync_RO_Flag', False);

    mmiHideUncheckedModules.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbWindows, 'Sync_HideValid', False);

    {$IFDEF IDEDLL}
    cbReload.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbWindows, 'Sync_AutoReload', False);
    {$ENDIF IDEDLL}

    cbSummary.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbWindows, 'Sync_ShowSummary', False);

    if not jvcsReadWindowPosAndSize(sBaseRegistryKey + crbWindows, 'Sync',
      DlgTop, DlgLeft, DlgWidth, DlgHeight) then
    begin
      DlgTop := (Screen.Height - Height) div 2;
      DlgLeft := (Screen.Width - Width) div 2;
      DlgWidth := MulDiv(520, PixelsPerInch, 96);
      DlgHeight := MulDiv(400, PixelsPerInch, 96);
    end;
    Top := DlgTop;
    Left := DlgLeft;
    Width := DlgWidth;
    Height := DlgHeight;

    with lvDateItems do
    begin
      Columns[0].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'Sync_Col1.0', 130);
      Columns[1].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'Sync_Col1.1', 60);
      Columns[2].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'Sync_Col1.2', 100);
      Columns[3].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'Sync_Col1.3', 80);
      Columns[4].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'Sync_Col1.4', 150);
    end;
    pan_Project_List.Width :=
      jvcsReadInteger(sBaseRegistryKey + crbWindows, 'tv_Project_List_Width',
        pan_Project_List.Width);
    cbLoadProjectTree.Checked:=
      jvcsReadBool(sBaseRegistryKey + crbWindows, 'Sync_Load_Project_Tree',
        False);
    Project_Tree_Loaded:= False;

    MruListNewFolder := TJVCSMruList.CreateEx(sBaseRegistryKey + crbMRU + '6');
    rcbxNewFolder.Items.Assign(MruListNewFolder);

    rbChkInfld.Checked := True;
    rcbxNewFolder.Enabled := False;
    spBtnBrowse.Enabled := False;
    btnSync.Enabled := False;
    btnCompare.Enabled := False;
    btnDiff.Enabled := False;    
    btnHistory.Enabled := False;
    KWSet := False;
    AllSyncP := 0;
    AllSyncM := 0;
    LabelIDs := TStringList.Create;

    //Systemsymbole in eine TImageList-Komponente einlesen
    SysImageList.Handle := SHGetFileInfo('', 0, sfi, SizeOf(TSHFileInfo),
      SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
    SysImageList.ShareImages := True;

    btnCompare.Visible := bProjectOpen;
    btnDiff.Visible := bProjectOpen;
    btnHistory.Visible := bProjectOpen;
    GroupBox3.Enabled := bProjectOpen;
    rbselOld.Enabled := bProjectOpen;
    rbSelDiff.Enabled := bProjectOpen;
    cbCRC32.Enabled := bProjectOpen;
    rbNewfldr.Enabled := bProjectOpen;
    if not bProjectOpen then
    begin
      btnSync.Caption := JVCSRES_C38reate;
      SheetKey.TabVisible := False;
      SheetVer.TabVisible := False;
      SheetRollBack.TabVisible := False;
      SheetDate.Caption := JVCSRES_Create_via_version47date;
    end;
    AutoClose := False;
    FCreated := False;
    // Breite ListView.Columns setzen
    with lvVersion do
    begin
      Columns[0].Width := lvDateItems.Columns[0].Width;
      Columns[1].Width := lvDateItems.Columns[1].Width;
      Columns[2].Width := lvDateItems.Columns[2].Width;
      Columns[3].Width := lvDateItems.Columns[3].Width;
      Columns[4].Width := lvDateItems.Columns[4].Width;
    end;
    with lvKWItems do
    begin
      Columns[0].Width := lvDateItems.Columns[0].Width;
      Columns[1].Width := lvDateItems.Columns[1].Width;
      Columns[2].Width := lvDateItems.Columns[2].Width;
      Columns[3].Width := lvDateItems.Columns[3].Width;
      Columns[4].Width := lvDateItems.Columns[4].Width;
    end;
    with lvRollBack do
    begin
      Columns[0].Width := lvDateItems.Columns[0].Width;
      Columns[1].Width := lvDateItems.Columns[1].Width;
      Columns[2].Width := lvDateItems.Columns[2].Width;
      Columns[3].Width := lvDateItems.Columns[3].Width;
      Columns[4].Width := lvDateItems.Columns[4].Width;
    end;

    {$IFNDEF SHOWIDS}
    lvDateItems.Columns[5].Width := 0;
    lvDateItems.Columns[6].Width := 0;
    lvVersion.Columns[5].Width := 0;
    lvVersion.Columns[6].Width := 0;
    lvKWItems.Columns[5].Width := 0;
    lvKWItems.Columns[6].Width := 0;
    lvRollBack.Columns[5].Width := 0;
    lvRollBack.Columns[6].Width := 0;
    {$ENDIF ~SHOWIDS}

    dtpRollbackDate.Date := Now;
    dtpRollbackTime.Time := Now;

    FHiddenModuleList := TSortedIntegerList.Create;
    FChkOutByMeModuleList := TSortedIntegerList.Create;
    FIgnoredModuleList := TIgnoredModuleList.Create;
    FIgnoredModuleList.LoadFromStorage(sBaseRegistryKey + '\IgnoredModules');

    if bProjectOpen then
    begin
      cbCRC32.Checked :=
        jvcsReadBool(sBaseRegistryKey + crbWindows, 'Sync_VerifyCRC32', False);
      cbCRC32Click(nil);

      cbRemoveHidden.Enabled := cbInclHidden.Checked;
      if cbRemoveHidden.Enabled then
        cbRemoveHidden.Checked :=
          jvcsReadBool(sBaseRegistryKey + crbWindows, 'Sync_RemoveHidden', False)
      else
        cbRemoveHidden.Checked := False;

      cbInclChkOutByMe.Checked :=
        jvcsReadBool(sBaseRegistryKey + crbWindows, 'Sync_IncludeChkOutByMe', False);
    end
    else
    begin
      cbInclChkOutByMe.Checked := True;
      cbInclChkOutByMe.Enabled := False;
      cbRemoveHidden.Checked := False;
      cbRemoveHidden.Enabled := False;
    end;
    FIsInVerify := False;
    FPressedEsc := False;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------
// Fill Project Dependencies Tree View
procedure TVCSSync.Fill_ProjectTree(Project_ID: Integer; Complete: Boolean);
var
  New_Node: TTreeNode;

  procedure Fill_Depends(Project_ID: Integer; ParentNode: TTreeNode);
  var
    New_Node: TTreeNode;
    I: Integer;
  begin
    if not Project_Tree_Loaded then
      Project_Tree_Loaded:= True;
    if (tv_Project_List.Items.Count mod 1000) = 0 then
      if NoYesMessageBox(JVCSRES_Possible_circular_reference_bug46_Continue63) then Abort;
    with DataModule1 do
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_PROJECT_REFERENCES';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [Project_ID]);
      SetupTimeoutCounter;
      AppSrvClient1.Send;

      while WaitForAppSrvClient do
        Application.ProcessMessages;
      if (AppSrvClientErr = -99) then
      begin
        ShowServerTimeOut(WindowHandle);
        FCreated := True;
        Exit;
      end;
      if (AppSrvClientErr <> 0) or
        (AppSrvClient1.AnswerStatus <> '200') then
      begin
        ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
          AppSrvClient1.AnswerStatus);
        FCreated := True;
        Exit;
      end;

      AppSrvClient1.Answer.First;
      while not AppSrvClient1.Answer.Eof do
      begin
        New_Node := tv_Project_List.Items.AddChildObject(ParentNode, AppSrvClient1.Answer.Fields[1], TProject_Desc.Create);
        TProject_Desc(New_Node.Data).Project_ID := StrToInt(AppSrvClient1.Answer.Fields[0]);
        TProject_Desc(New_Node.Data).Project_Name := AppSrvClient1.Answer.Fields[1];
        tv_Project_List.CheckBox[New_Node] := True;
        tv_Project_List.Checked[New_Node] := False;
        AppSrvClient1.Answer.Next;
      end;
      for I := 0 to ParentNode.Count - 1 do
        Fill_Depends(TProject_Desc(ParentNode.Item[I].Data).Project_ID, ParentNode.Item[I]);
    end; // with DataModule1 do begin}
  end;

begin
  {$IFDEF DEBUG}
  JclDebug.TraceMsg('Sync: Start load Tree');
  {$ENDIF DEBUG}
  try
    tv_Project_List.Items.BeginUpdate;
    tv_Project_List.Items.Clear;
    // Some TjvCheckTreeView posible bug
    tv_Project_List.CheckBoxes := True;
    New_Node :=  tv_Project_List.Items.AddObject(nil, Format(JVCSRES_Root_4037s41,
      [SelectedProjectName]), TProject_Desc.Create);
    TProject_Desc(New_Node.Data).Project_ID := Project_ID;
    TProject_Desc(New_Node.Data).Project_Name := SelectedProjectName;

    tv_Project_List.CheckBox[New_Node] := True;
    tv_Project_List.Checked[New_Node] := False;

    if Complete then Fill_Depends(Project_ID, New_Node);
  finally
    tv_Project_List.AlphaSort;
    tv_Project_List.Items.EndUpdate;
    tv_Project_List.Refresh;
    if tv_Project_List.Items.Count > 0 then
    begin
      tv_Project_List.Items[0].Expand(False);
      tv_Project_List.Items[0].Selected := True;
      tv_Project_List.Items[0].MakeVisible;
      tv_Project_List.Checked[tv_Project_List.Items[0]] := True;
    end;
  end;
  {$IFDEF DEBUG}
  JclDebug.TraceMsg('Sync: End load Tree');
  {$ENDIF DEBUG}
end;

//------------------------------------------------------------------------------

procedure TVCSSync.FormActivate(Sender: TObject);
begin
  if FCreated then
    Exit;
  Application.ProcessMessages;
  Screen.Cursor := crHourGlass;
  PageControl1.ActivePage := SheetDate;
  if not bProjectOpen then
  begin
    // Select a project
    VCSSelectProject := TVCSSelectProject.Create(Application);
    try
      VCSSelectProject.Top := Top + 60;
      VCSSelectProject.Left := Left + 60;
      VCSSelectProject.SetDlgCaption(JVCSRES_Create_from_DB);
      VCSSelectProject.DefaultID := ServerProjectID;
      VCSSelectProject.ShowModal;
      RootProjectID := VCSSelectProject.SelectedID;
      SelectedProjectName := VCSSelectProject.SelectedName;
    finally
      VCSSelectProject.Free;
    end;
    if RootProjectID = 0 then
    begin
      TimerCloseForm.Enabled:= True;
      Exit;
    end;
  end // if not bProjectOpen then begin
  else
  begin
    RootProjectID := ServerProjectID;
    SelectedProjectName := ExtractFileName(sProjectName);
    OriginalProjectName := SelectedProjectName;
    if AutoClose then
    begin
      SheetKey.TabVisible := False;
      SheetVer.TabVisible := False;
      SheetRollBack.TabVisible := False;
    end;
  end;

  Fill_ProjectTree(RootProjectID, cbLoadProjectTree.Checked);

  FCreated := True;
  Reload_Project_Contents(0);
  Screen.Cursor := crDefault;
end;

//------------------------------------------------------------------------------

function TVCSSync.GetCurrLV: TdfsEnhListView;
begin
  Result := lvDateItems;
  if PageControl1.ActivePage = SheetDate then
    Result := lvDateItems;
  if PageControl1.ActivePage = SheetVer then
    Result := lvVersion;
  if PageControl1.ActivePage = SheetKey then
    Result := lvKWItems;
  if PageControl1.ActivePage = SheetRollBack then
    Result := lvRollBack;
end;

//------------------------------------------------------------------------------

procedure TVCSSync.VerifyProject(Project_ID: Integer; var Mess: string; var Res: TProjectSearchRec);
var
  Count, IgnoredModules, IgnoredFiles, CheckedOutModules, CheckedOutFiles: Integer;
  Target: string;
begin
  {$IFDEF DEBUG}
  JclDebug.TraceFmt('Sync: Start VerifyProject %d', [Project_ID]);
  {$ENDIF DEBUG}
  Application.ProcessMessages;
  if rbNewfldr.Checked then
  begin
    if rcbxNewFolder.Text = '' then
    begin
      MessageBox(WindowHandle, PChar(JVCSRES_Target_folder_cannot_be_blank46_Define_a_target_folder_and_retry46), cMsgBoxCaption,
        MB_OK or MB_ICONEXCLAMATION);
      Abort;
    end
    else
      Target := rcbxNewFolder.Text;

    {  --hu
    rcbxNewFolder.AddMRUString(rcbxNewFolder.Text);
    rcbxNewFolder.MRUSaveToReg;
     }
    Count := SelectModules(Project_ID, rcbxNewFolder.Text, IgnoredModules, IgnoredFiles,
      CheckedOutModules, CheckedOutFiles);
  end
  else
  begin
    Count := SelectModules(Project_ID, '', IgnoredModules, IgnoredFiles,
      CheckedOutModules, CheckedOutFiles);
    Target := JVCSRES_Origin_folders;
  end;
  Res.Diff := Count;
  {$IFDEF DEBUG}
  if AutoClose then
    JclDebug.TraceMsg('Sync: AutoClose = true')
  else
    JclDebug.TraceMsg('Sync: AutoClose = false');
  JclDebug.TraceMsg('Sync: Count: ' + IntToStr(Count));
  {$ENDIF DEBUG}
  if Count > 0 then
  begin
    SetTransState(tsStop);
    if rbselOld.Checked and (PageControl1.ActivePage <> SheetRollBack) then
    begin
      Mess := Format(JVCSRES_Verify_37s_to_6037s6258 + #13#10 +
        JVCSRES_37d_files_in_the_target_folder91s93_not_up_to_date46,
        [JVCSRES_newer_files, Target, Count]);
    end
    else
    begin
      Mess := Format(JVCSRES_Verify_different_files_to_6037s6258, [Target]) + #10#13 +
        Format(JVCSRES_37d_different_files46, [Count]);
    end;
  end
  else
  begin
    if (PageControl1.ActivePage = SheetDate) then SetTransState(tsGo);
    Mess := JVCSRES_All_files_up45to45date_or_unchanged46;
  end;
  if (CheckedOutModules > 0) or (IgnoredModules > 0) then
  begin
    Mess := Mess + #13#13 + JVCSRES_skipped_in_verify_process58;
    if CheckedOutModules > 0 then
      Mess := Mess + #13 + Format(JVCSRES_37d_modules4037d_files41_are_checked_out_by_you46,
        [CheckedOutModules, CheckedOutFiles]);
    if IgnoredModules > 0 then
      Mess := Mess + #13 + Format(JVCSRES_37d_modules4037d_files41_were_ignored46,
        [IgnoredModules, IgnoredFiles]);
  end;
  {$IFDEF DEBUG}
  JclDebug.TraceFmt('Sync: Stop VerifyProject %d', [Project_ID]);
  {$ENDIF DEBUG}
end;

procedure TVCSSync.VerifyProject_List(Mode: Integer);
var
  ProjectID: Integer;
  Mess: string;
  Node: TTreeNode;
  TotalDiff: Integer;

  procedure Set_Caption(DiffCnt: Integer);
  begin
    if DiffCnt > 0 then
    begin
      if rbselOld.Checked and (Mode <> 3) then
        Caption := Format(JVCSRES_VCS_Synchronize47_Restore_45_37d_files_not_up_to_date, [DiffCnt])
      else
        Caption := Format(JVCSRES_VCS_Synchronize47_Restore_45_37d_different_files, [DiffCnt]);
    end
    else
      Caption := JVCSRES_VCS_Synchronize47_Restore_45_All_files_up45to45date_or_unchanged;
  end;

  procedure AfterVerify(Node: TTreeNode; Res: TProjectSearchRec);
  begin
    if Res.Diff = 0 then
    begin
      Node.ImageIndex := 5;
      Node.SelectedIndex := 5;
    end
    else
    begin
      Node.ImageIndex := 6;
      Node.SelectedIndex := 6;
    end;
    Node.MakeVisible;
    Inc(TotalDiff, Res.Diff);
    Set_Caption(TotalDiff);
    tv_Project_List.Repaint;
    Application.ProcessMessages;
  end;

begin
  if btnVerify.Caption = JVCSRES_Cancel then
  begin
    FPressedEsc := True;
    Exit;
  end;
  FPressedEsc := False;
  try
    try
      btnVerify.Caption := JVCSRES_Cancel;
      StatusBar.Panels[sbStatus].Text := JVCSRES_Compare464646;
      Screen.Cursor := crHourGlass;
      Application.ProcessMessages;
      if tv_Project_List.Items.Count = 0 then Exit;
      Node := tv_Project_List.Items[0];
      GetHiddenAndChkOutByMeModules;
      TotalDiff := 0;
      while Assigned(Node) do
      begin
        if tv_Project_List.Checked[Node] then
        begin
          ProjectID := TProject_Desc(Node.Data).Project_ID;
          case Mode of
          0: begin
               TProject_Desc(Node.Data).LatestRes.Diff := 0;
               VerifyProject(ProjectID, Mess, TProject_Desc(Node.Data).LatestRes);
               AfterVerify(Node, TProject_Desc(Node.Data).LatestRes);
             end;
          1: begin
               TProject_Desc(Node.Data).VersionRes.Diff := 0;
               VerifyProject(ProjectID, Mess, TProject_Desc(Node.Data).VersionRes);
               AfterVerify(Node, TProject_Desc(Node.Data).VersionRes);
             end;
          2: begin
               TProject_Desc(Node.Data).LabeledRes.Diff := 0;
               VerifyProject(ProjectID, Mess, TProject_Desc(Node.Data).LabeledRes);
               AfterVerify(Node, TProject_Desc(Node.Data).LabeledRes);
             end;
          3: begin
               TProject_Desc(Node.Data).RollbackRes.Diff := 0;
               VerifyProject(ProjectID, Mess, TProject_Desc(Node.Data).RollbackRes);
               AfterVerify(Node, TProject_Desc(Node.Data).RollbackRes);
             end;
          end; // Case
          StatusBar.Panels[sbStatusText].Text := Format(JVCSRES_37d_files_assigned_to_project_6037s62,
            [GetCurrLV.Items.Count, TProject_Desc(Node.Data).Project_Name]);
          Mess := Mess + #13;
        end;
        Node := Node.GetNext;
      end;

      if mmiHideUncheckedModules.Enabled and mmiHideUncheckedModules.Checked then
        HideUncheckedModules;
      StatusBar.Panels[sbStatusText].Text := Format(JVCSRES_37d_files_assigned_to_selected_projects,
        [GetCurrLV.Items.Count]);
      StatusBar.Panels[sbStatus].Text := JVCSRES_Ready;
      Screen.Cursor := crDefault;
      if TotalDiff > 0 then SetTransState(tsStop)
      else SetTransState(tsGo);
      UseRegistry := True;
      DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
      DSAIdentsMessageDlg(Mess
        , mtInformation
        , [mbOK]
        , 0
        , sBaseRegistryKey + crbMRU + 'Dlgs'
        , 'VerifyRes'
        , idOk
        );
      btnSync.Enabled := True;
      btnVerify.Enabled := False;
      if AutoClose and (TotalDiff = 0) then
      begin
        {$IFDEF DEBUG}
        JclDebug.TraceMsg('Sync: -> Close');
        {$ENDIF DEBUG}
        Caption := JVCSRES_VCS_Synchronize_45_All_files_up_to_date;
        TimerCloseForm.Enabled := True;
        Exit;
      end
      else
        AutoClose := False;
    except
      on E: Exception do
      begin
        if E.ClassType = EAbort then
          Exit
        else
        begin
          AutoClose := False;
          raise;
        end;
      end;
    end;
  finally
    Screen.Cursor := crDefault;
    btnVerify.Caption:= JVCSRES_38Verify;
  end;
end;

procedure TVCSSync.btnVerifyClick(Sender: TObject);
begin
  VerifyProject_List(PageControl1.ActivePageIndex);
end;

//------------------------------------------------------------------------------

procedure TVCSSync.CheckMembers(CurrLV: TdfsEnhListView;
  SearchIndex, NewState: Integer; RevisionID: string; NewDiffType: string);
var
  CurrentIndex: Integer;
begin
  if not (TDiff_Types(StrToInt(NewDiffType)) in [dtReadOnly, dtReadWrite]) then
  begin
    {$IFDEF DEBUG}
    JclDebug.TraceFmt('Sync: CheckMembers new Diff Type %s', [NewDiffType]);
    {$ENDIF DEBUG}
    with CurrLV do
    begin
      // Up
      CurrentIndex := SearchIndex;
      while (CurrentIndex >= 0) do
      begin
        if (Items[CurrentIndex].SubItems[lvItem_Revision_ID] = RevisionID) then
        begin
          Items[CurrentIndex].StateIndex := NewState;
          Items[CurrentIndex].SubItems[lvItem_Diff_Type]:= NewDiffType;
          {$IFDEF DEBUG}
          JclDebug.TraceFmt('Sync: CheckMembers Diff set to %s', [Items[CurrentIndex].Caption]);
          {$ENDIF DEBUG}
        end;
        Dec(CurrentIndex);
      end;
      // Down
      CurrentIndex := SearchIndex;
      while (CurrentIndex <= Items.Count - 1) do
      begin
        if (Items[CurrentIndex].SubItems[lvItem_Revision_ID] = RevisionID) then
        begin
          Items[CurrentIndex].StateIndex := NewState;
          Items[CurrentIndex].SubItems[lvItem_Diff_Type]:= NewDiffType;
          {$IFDEF DEBUG}
          JclDebug.TraceFmt('Sync: CheckMembers Diff set to %s', [Items[CurrentIndex].Caption]);
          {$ENDIF DEBUG}
        end;
        Inc(CurrentIndex);
      end;
    end; // with lvDateItems do begin
  end;
end;

//------------------------------------------------------------------------------

function TVCSSync.IsSyncROFlagEnabled: Boolean;
begin
  Result:= cbROFlag.Checked;
end;

function TVCSSync.SelectModules(Project_ID: Integer; Target: string; var AIgnoredModules,
  AIgnoredFiles, ACheckedOutModules, ACheckedOutFiles: Integer): Integer;
var
  TargetFile, CRC1, CRC2, Mess: string;
  ArchiveModuleDate, TargetFDate: Double;
  I, SelModules: Integer;
  CurrLV: TdfsEnhListView;
  IgnoredModules, CheckedOutModules: TSortedIntegerList;
  ModuleID: Integer;
  NotReadOnlyFilter: string;
begin
  IgnoredModules := nil;
  CheckedOutModules := nil;
  NotReadOnlyFilter :=
    jvcsReadString(sBaseRegistryKey + crbFilters, 'Writeable files', dfNotReadOnly);
  try
    IgnoredModules := TSortedIntegerList.Create;
    CheckedOutModules := TSortedIntegerList.Create;
    FIsInVerify := True;
    Result := 0;
    SelModules := 0;
    AIgnoredModules := 0;
    AIgnoredFiles := 0;
    ACheckedOutModules := 0;
    ACheckedOutFiles := 0;

    if Target<>'' then
      Target := SetBackSlash(Target);

    CurrLV := GetCurrLV;
    with CurrLV do
      for I := 0 to Items.Count - 1 do
      begin
        if StrToIntDef(Items[I].SubItems[8], 0) = Project_ID then
          Items[I].StateIndex := 0;
      end;

    ShowStatusBarGauge(True, False);
    StatusBarGaugePos(0);

    with CurrLV do
    begin
      FPressedEsc := False;
      for I := 0 to Items.Count - 1 do
      begin
        Application.ProcessMessages;
        if FPressedEsc then
        begin
          FPressedEsc := False;
          if NoYesMessageBox(Format(JVCSRES_Do_you_want_to_abort_verifying_project_6037s62_63,
            [SelectedProjectName])) then
            Abort;
        end;

        if StrToIntDef(Items[I].SubItems[lvItem_Project_ID], 0) <> Project_ID then Continue;

        ArchiveModuleDate := _StrToFloat(Items[I].SubItems[lvItem_Date_Val]);
        if Target = '' then
          TargetFile := Items[I].SubItems[lvItem_Original_Path] +
            LowerCase(Items[I].Caption)
        else
          TargetFile := Target + LowerCase(Items[I].Caption);

        ModuleID := StrToIntDef(Items[I].SubItems[lvItem_Module_ID], 0);
        if (Target = '') and IsIgnoreModulesEnabled and
          IsIgnoredModule(ModuleID, StrToIntDef(Items[I].SubItems[lvItem_Revision_ID], 0),
            Items[I].SubItems[lvItem_Original_Path])
        then
        begin
          //only count the modules and files (don't check for synchronizing)
          IgnoredModules.Add(ModuleID);
          Inc(AIgnoredFiles);
        end
        else
        if IsDontSyncChkOutByMeEnabled and IsChkOutByMe(ModuleID) then
        begin
          //only count the modules and files (don't check for synchronizing)
          CheckedOutModules.Add(ModuleID);
          Inc(ACheckedOutFiles);
        end
        else
        if IsSyncROFlagEnabled and IsChkOutByMe(ModuleID) then
        begin
          if ((FileGetAttr(TargetFile) and faReadOnly) = faReadOnly) then
          begin
            {$IFDEF DEBUG}
            JclDebug.TraceFmt('Sync: SelectModules %s ReadWrite', [TargetFile]);
            {$ENDIF DEBUG}
            Items[I].StateIndex := 1;
            Items[I].SubItems[lvItem_Diff_Type]:= IntToStr(Ord(dtReadWrite));
            CheckMembers(CurrLV, Items[I].Index, 1, Items[I].SubItems[lvItem_Revision_ID], Items[I].SubItems[lvItem_Diff_Type]);
            Inc(SelModules);
          end;
        end
        else
        if IsRemoveHiddenEnabled and IsHiddenFile(ModuleID) then
        begin
          if FileExists(TargetFile) and (Items[I].StateIndex <> 1) then
          begin
            Items[I].StateIndex := 1;
            Items[I].SubItems[lvItem_Diff_Type]:= IntToStr(Ord(dtRemoveHidden));
            CheckMembers(CurrLV, Items[I].Index, 1, Items[I].SubItems[lvItem_Revision_ID], Items[I].SubItems[lvItem_Diff_Type]);
            Inc(SelModules);
          end;
        end
        else
        if FileExists(TargetFile) then
        begin
          if cbCRC32.Checked or (CurrLV = lvRollBack) then
          begin
            CRC1 := Items[I].SubItems[lvItem_CRC32];
            CRC2 := IntToHex(CRCInt(TargetFile, Mess), 8);
            if (CRC1 <> CRC2) and
              (Items[I].StateIndex <> 1) then
            begin
              Items[I].StateIndex := 1;
              Items[I].SubItems[lvItem_Diff_Type]:= IntToStr(Ord(dtCRC32));
              CheckMembers(CurrLV, Items[I].Index, 1, Items[I].SubItems[lvItem_Revision_ID], Items[I].SubItems[lvItem_Diff_Type]);
              Inc(SelModules);
            end;
          end // if cbCRC32.Checked then begin
          else
          begin
            TargetFDate := FileGetUTCDateTime(TargetFile) - cTimeConvErr;
            if rbselOld.Checked then
            begin
              if (ArchiveModuleDate > (TargetFDate + cTimeConvErr)) and
                (Items[I].StateIndex <> 1) then
              begin
                CRC1 := Items[I].SubItems[lvItem_CRC32];
                CRC2 := IntToHex(CRCInt(TargetFile, Mess), 8);
                if (CRC1 <> CRC2) then
                begin
                  Items[I].StateIndex := 1;
                  Items[I].SubItems[lvItem_Diff_Type]:= IntToStr(Ord(dtCRC32));
                  CheckMembers(CurrLV, Items[I].Index, 1, Items[I].SubItems[lvItem_Revision_ID], Items[I].SubItems[lvItem_Diff_Type]);
                  Inc(SelModules);
                end; // if (CRC1 <> CRC2) then begin
              end;
            end // if rbselOld.Checked then begin
            else
            begin
              if ((ArchiveModuleDate > (TargetFDate + cTimeConvErr)) or
                (ArchiveModuleDate < (TargetFDate - cTimeConvErr))) and
                (Items[I].StateIndex <> 1) then
              begin
                Items[I].StateIndex := 1;
                Items[I].SubItems[lvItem_Diff_Type]:= IntToStr(Ord(dtDateTime));
                CheckMembers(CurrLV, Items[I].Index, 1, Items[I].SubItems[lvItem_Revision_ID], Items[I].SubItems[lvItem_Diff_Type]);
                Inc(SelModules);
              end;
            end; // else if rbselOld.Checked then begin
          end; // else if cbCRC32.Checked then begin
          if (Items[I].StateIndex <> 1) and IsSyncROFlagEnabled
             and ((FileGetAttr(TargetFile) and faReadOnly) <> faReadOnly)
             and (not (MatchWithFilter(ExtractFileName(TargetFile), NotReadOnlyFilter))) then
          begin
            {$IFDEF DEBUG}
            JclDebug.TraceFmt('Sync: SelectModules %s ReadOnly', [TargetFile]);
            {$ENDIF DEBUG}
            Items[I].StateIndex := 1;
            Items[I].SubItems[lvItem_Diff_Type]:= IntToStr(Ord(dtReadOnly));
            CheckMembers(CurrLV, Items[I].Index, 1, Items[I].SubItems[lvItem_Revision_ID], Items[I].SubItems[lvItem_Diff_Type]);
            Inc(SelModules);
          end;
        end
        else
        begin
          if (Items[I].StateIndex <> 1) then
          begin
            Items[I].StateIndex := 1;
            Items[I].SubItems[lvItem_Diff_Type]:= IntToStr(Ord(dtNotFound));
            CheckMembers(CurrLV, Items[I].Index, 1, Items[I].SubItems[lvItem_Revision_ID], Items[I].SubItems[lvItem_Diff_Type]);
            Inc(SelModules);
          end;
        end;
        StatusBarGaugePos(Round((I / Items.Count) * 100));
      end; // for I := 0 to Items.Count - 1 do begin
    end; // with CurrLV do begin
    ShowStatusBarGauge(False, False);
    Result := SelModules;
    AIgnoredModules := IgnoredModules.Count;
    ACheckedOutModules := CheckedOutModules.Count;
  finally
    FIsInVerify := False;
    IgnoredModules.Free;
    CheckedOutModules.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSSync.rbChkInfldClick(Sender: TObject);
begin
  {$IFDEF IDEDLL}
  cbReload.Enabled := not rbNewfldr.Checked;
  {$ENDIF IDEDLL}
  rcbxNewFolder.Enabled := rbNewfldr.Checked;
  if rcbxNewFolder.Enabled then
    rcbxNewFolder.Color := clWindow
  else
    rcbxNewFolder.Color := clBtnFace;
  spBtnBrowse.Enabled := rbNewfldr.Checked;
  btnVerify.Enabled := True;
  CheckAllListViewItems(GetCurrLV, 0);
end;

//------------------------------------------------------------------------------

procedure TVCSSync.lvDateItemsClick(Sender: TObject);
var
  CurrLV: TdfsEnhListView;
begin
  CurrLV := GetCurrLV;
  if (CurrLV.Items.Count > 0) and (CurrLV.Selected <> nil) then
  begin
    btnCompare.Enabled := True;
    btnDiff.Enabled := True;
    btnHistory.Enabled := True;
  end
  else
  begin
    btnCompare.Enabled := False;
    btnDiff.Enabled := False;    
    btnHistory.Enabled := False;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSSync.btnCompareClick(Sender: TObject);
var
  RevisionKey, CompareFile, CompareFileMember, Target: string;
  CurrLV: TdfsEnhListView;
begin
  CurrLV := GetCurrLV;
  if (CurrLV.Items.Count > 0) and (CurrLV.Selected <> nil) then
  begin
    if rbNewfldr.Checked then
    begin
      if rcbxNewFolder.Text = '' then
      begin
        MessageBox(WindowHandle, PChar(JVCSRES_Target_folder_cannot_be_blank46_Define_a_target_folder_and_retry46), cMsgBoxCaption,
          MB_OK or MB_ICONEXCLAMATION);
        Exit;
      end // if rcbxNewFolder.Text = '' then begin
      else
      begin
        Target := SetBackSlash(rcbxNewFolder.Text);
        CompareFile := Target + LowerCase(CurrLV.Selected.Caption);
      end; // else if rcbxNewFolder.Text = '' then begin
    end // if rbNewfldr.Checked then begin
    else
      CompareFile := CurrLV.Selected.SubItems[lvItem_Original_Path] + LowerCase(CurrLV.Selected.Caption);
    CompareFileMember := CompareFile;
    ResolveFileFamilies(CompareFile);

    btnCompare.Enabled := True;
    RevisionKey := CurrLV.Selected.SubItems[lvItem_Revision_ID];

    if Sender = btnCompare then
      DoModuleCompare(StrToIntDef(CurrLV.Selected.SubItems[lvItem_Module_ID], 0),
        CompareFile, CompareFileMember, StrToIntDef(RevisionKey, 0))
    else
    if Sender = btnDiff then    
      ShowCompressDiffDialog(CompareFileMember, StrToIntDef(RevisionKey, 0), ExtractFileExt(CompareFileMember));
  end // if (clbModules.Items.Count > 0) and (clbModules.ItemIndex <> -1) then
  else
    MessageBox(WindowHandle, PChar(JVCSRES_Select_a_module_first46),
      cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
end;

//------------------------------------------------------------------------------

procedure TVCSSync.spBtnBrowseClick(Sender: TObject);
begin
  VCSSelectFolder := TVCSSelectFolder.Create(Application);
  try
    VCSSelectFolder.SetStatusText(JVCSRES_38Target_folder58);
    VCSSelectFolder.EnableRecursive(False);
    if bProjectOpen then
      VCSSelectFolder.HelpContextID := IDH_Synchronize
    else
      VCSSelectFolder.HelpContextID := IDH_Create_from_DB;
    if rcbxNewFolder.Text <> '' then
      VCSSelectFolder.SetInitialDir(rcbxNewFolder.Text);
    VCSSelectFolder.ShowModal;
    if VCSSelectFolder.Selection <> '' then
    begin
      rcbxNewFolder.Text := SetBackSlash(AnsiLowerCase(VCSSelectFolder.Selection));
      MruListNewFolder.AddString(rcbxNewFolder.Text);
      rcbxNewFolder.Items.Insert(0, rcbxNewFolder.Text);
    end; // if VCSSelectFolder.Selection <> '' then begin
  finally
    VCSSelectFolder.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSSync.Sync_Project(ProjectID: Integer; var Res: TProjectSearchRec; Target: string; var Mess: string);
var
  TargetFile, AffectedFiles, NotReadOnlyFilter, ErrMsg: string;
  I: Integer;
  FuncRes: Integer;
  CurrLV: TdfsEnhListView;
  CloseIDEView, SetROFlag: Boolean;
  Project_ID: string;
  FileAttrs: Integer;
  {$IFDEF IDEDLL}
  FileWasWriteable, FileWasOpen: Boolean;
  {$ENDIF IDEDLL}
begin
  {$IFDEF DEBUG}
  JclDebug.TraceFmt('Sync: Start Sync_Project %d', [ProjectID]);
  {$ENDIF DEBUG}
  NotReadOnlyFilter :=
    jvcsReadString(sBaseRegistryKey + crbFilters, 'Writeable files', dfNotReadOnly);
  NeedRefresh := True;
  ShowStatusBarGauge(True, False);
  StatusBarGaugePos(0);
  StatusBar.Panels[sbStatus].Text := JVCSRES_Working464646;
  Application.ProcessMessages;

  CurrLV := GetCurrLV;
  with CurrLV do
  begin
    for I := 0 to Items.Count - 1 do
    begin
      if StrToIntDef(Items[I].SubItems[lvItem_Project_ID], 0) <> ProjectID then Continue;

      {$IFDEF DEBUG}
      JclDebug.TraceFmt('Sync: Sync_Project %s is parent %s', [LowerCase(Items[I].Caption), Items[I].SubItems[lvItem_Parent]]);
      {$ENDIF DEBUG}
      if (Items[I].StateIndex = 1) and
        ((Items[I].SubItems[lvItem_Parent] = '1') or (TDiff_Types(StrToInt(Items[I].SubItems[lvItem_Diff_Type])) in [dtReadOnly, dtReadWrite]))then
      begin
        if rbNewfldr.Checked then
          TargetFile := Target + LowerCase(Items[I].Caption)
        else
          TargetFile := Items[I].SubItems[lvItem_Original_Path] + LowerCase(Items[I].Caption);

        SetROFlag := False;
        if not (TDiff_Types(StrToInt(Items[I].SubItems[lvItem_Diff_Type])) in [dtReadOnly, dtReadWrite]) then
        begin
          // Readonly ?
          if IsChkOutByMe(StrToIntDef(Items[I].SubItems[lvItem_Module_ID], 0)) then
          begin
            SetROFlag := False;
            BeepIfSet;
            if not NoYesWarnMessageBox(Format(JVCSRES_6037s62_is_checked_out_by_you46, [TargetFile])
              + #13#13 + JVCSRES_Do_you_still_want_to_synchronize_this_file_63) then
              Continue;
          end
          else
            SetROFlag := not (MatchWithFilter(ExtractFileName(TargetFile), NotReadOnlyFilter));
        end;

        case TDiff_Types(StrToInt(Items[I].SubItems[lvItem_Diff_Type])) of
        dtRemoveHidden:
        begin
          FuncRes := DeleteHiddenFiles(TargetFile, StrToIntDef(Items[I].SubItems[lvItem_Revision_ID],0),
            ErrMsg, AffectedFiles);
          if FuncRes = 0 then
          begin
            Inc(Res.InSync);
            Mess := Mess + ExtractFileName(TargetFile) + ';' + AffectedFiles
              + ' ' + JVCSRES_removed + ' ;|';
            {$IFDEF IDEDLL}
            //@@@ToDo fixed file extension!
            if ((ExtractFileExt(TargetFile) = ('.' + sIDEUnit)) or
              (ExtractFileExt(TargetFile) = '.inc'))
            then
              if IDEInterface.IsFileOpen(TargetFile) then
                IDEInterface.CloseFile(TargetFile);
            {$ENDIF IDEDLL}
          end
          else
          begin
            BeepIfSet;
            case FuncRes of
              1:
                Mess := JVCSRES_91AppSrvClient46Request93;
              2:
                Mess := JVCSRES_91Get_FileAttributes93;
              3:
                Mess := JVCSRES_91Set_FileAttributes93;
              4:
                Mess := JVCSRES_91Delete_File93;
              else
                Mess := JVCSRES_91Unknown93;
            end;
            ErrorMessageBox(Format(JVCSRES_Unable_to_delete_6037s62_in_target_folder46 + #13
              + JVCSRES_Exception_37s_in_37s, [TargetFile, ErrMsg, Mess]));
          end;

          Items[I].StateIndex := 0;
          StatusBarGaugePos(Round((I / Items.Count) * 100));

          Continue;
        end;
        dtReadOnly:
        begin
          {$IFDEF DEBUG}
          JclDebug.TraceFmt('Sync: Sync_Project %s read only', [TargetFile]);
          {$ENDIF DEBUG}
          FileAttrs:= FileGetAttr(TargetFile);
          if not ((FileAttrs and faReadOnly) = faReadOnly) then
            if FileSetAttr(TargetFile, FileAttrs or faReadOnly) = 0 then
            begin
              Inc(Res.InSync);
              Mess := Mess + ExtractFileName(TargetFile) + ';' + ExtractFileName(TargetFile)
                + ' ' + JVCSRES_read45only + ' ;|';
            end;
        end;
        dtReadWrite:
        begin
          {$IFDEF DEBUG}
          JclDebug.TraceFmt('Sync: Sync_Project %s read write', [TargetFile]);
          {$ENDIF DEBUG}
          FileAttrs:= FileGetAttr(TargetFile);
          if (FileAttrs and faReadOnly) = faReadOnly then
            if FileSetAttr(TargetFile, FileAttrs and not faReadOnly) = 0 then
            begin
              Inc(Res.InSync);
              Mess := Mess + ExtractFileName(TargetFile) + ';' + ExtractFileName(TargetFile)
                + ' ' + JVCSRES_writeable + ' ;|';
            end;
        end;
        //----------------------------------------------------------------------
        dtNoDiff, dtDateTime, dtCRC32, dtNotFound:
        begin
          if (not SkipROCheck) and SetROFlag and
            (not ((FileGetAttr(TargetFile) and faReadOnly) = faReadOnly)) then
          begin
            BeepIfSet;
            case MessageBox(WindowHandle, PChar(Format('%s <%s>.' + #13#10 +
                JVCSRES_JEDI_VCS_expects_the_local_file_to_be_37s44_but_the_file_is_37s46 + #13#10 +
                JVCSRES_Continue_anyway63, [JVCSRES_Synchronize,
              TargetFile, JVCSRES_read45only, JVCSRES_writeable])), cMsgBoxCaption,
              MB_YESNOCANCEL or MB_DEFBUTTON2 or MB_ICONWARNING) of
              idYes:;
              idNo:
                Continue;
              else
                Break;
            end; // case
          end;
          CloseIDEView := False;
          {$IFDEF IDEDLL}
          //--- Close file before getting new versions from Server -------------
          FileWasOpen := False;
          FileWasWriteable := False;
          // project file?
          if IsIDEProject(TargetFile, sProjectName) then
          begin
            WarnMessageBox(Format( JVCSRES_Projectfile_6037s62_synchronized46 + sLineBreak +
                              JVCSRES_You_have_to_close_and_reload_the_project_for_this_change_to_take_effect46
                            , [ExtractFileName(TargetFile)]));
          end;
          //@@@ToDo fixed file extension!
          if ((ExtractFileExt(TargetFile) = ('.' + sIDEUnit)) or
            (ExtractFileExt(TargetFile) = '.inc')) then
          begin
            FileWasOpen := IDEInterface.IsFileOpen(TargetFile);
            if FileWasOpen then
            begin
              FileWasWriteable := IDEInterface.IsFileOpenAndWriteable(TargetFile);
              if (cbReload.Enabled) and (cbReload.Checked) then
                CloseIDEView := True;
            end;
          end;
          //--------------------------------------------------------------------
          {$ENDIF IDEDLL}
          //--- Get Blobs --------------------------------------------------------
          Project_ID := Items[I].SubItems[lvItem_Project_ID];
          FuncRes := GetBlobs(DBModule.GetJvcsConnection, StrToInt(Project_ID),
            ServerUserID, StrToInt(Items[I].SubItems[lvItem_Module_ID]),
            StrToInt(Items[I].SubItems[lvItem_Revision_ID]),
            False{CheckOut}, Application, Self,
            SetROFlag{SetReadOnly}, CloseIDEView{CloseIDEView},
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
            //--- prepare result view --------------------------------------------
            Inc(Res.InSync);
            Mess := Mess + ExtractFileName(TargetFile) + ';' + AffectedFiles + ';|';
            {$IFDEF IDEDLL}
            //--- Reopen file if it was open in IDE ------------------------------
            if FileWasOpen then
            begin
              IDEInterface.OpenFile(GetOriginalFileName(TargetFile));
              if (not FileWasWriteable) and (not IDEInterface.IsFileOpenAndWriteable(TargetFile)) then
                WarnMessageBox(Format(JVCSRES_Module_6037s62_was_synchronized_but_is_still_cached_by_Delphi, [ExtractFileName(TargetFile)]));
            end;
            //--------------------------------------------------------------------
            {$ENDIF IDEDLL}
          end; // else if FuncRes <> 0 then begin
        end;
        end; // case TDiff_Types(StrToInt(Items[I].SubItems[lvItem_Diff_Type]))
      end; // if Items[I].StateIndex = 1 and...
      Items[I].StateIndex := 0;
      Items[I].SubItems[lvItem_Diff_Type]:= IntToStr(Ord(dtNoDiff));
      StatusBarGaugePos(Round((I / Items.Count) * 100));
    end; // for I := 0 to Items.Count - 1 do begin
  end; // with CurrLV do begin
  ShowStatusBarGauge(False, False);
  StatusBar.Panels[sbStatus].Text := JVCSRES_Ready;

  if not cbSummary.Checked then
  begin
    Caption := Format(JVCSRES_VCS_Synchronize47_Restore_45_37d_files_updated46, [Res.InSync]);
  end; // else if cbSummary.Checked then begin

  {$IFDEF IDEDLL}
  if bPJM_Created then
    bPJM_NeedRefresh := True;
  {$ELSE}
  bPJM_NeedRefresh := True;
  {$ENDIF IDEDLL}
  {$IFDEF DEBUG}
  JclDebug.TraceFmt('Sync: Stop Sync_Project %d', [ProjectID]);
  {$ENDIF DEBUG}
end;

procedure TVCSSync.Sync_Project_List(Mode: Integer);
var
  Node: TTreeNode;
  ProjectID: Integer;
  Prj_Count: Integer;
  Msg: string;
  Mess: string;
  UpdatedCnt: Integer;
  Target: string;

  // Exit in a procedure only exit the procedure..
  // So changed to a function returning the MessageBox value
  function Confirmation: Integer;
  var
    Mess: string;
    mbIcon: Integer;
  begin
    if bProjectOpen then
    begin
      case Mode of
      0: begin
           if Target = '' then
             Mess := JVCSRES_Are_you_sure_to_synchronize_the_working_directory_with_the_archive63 + #13#10 +
               JVCSRES_This_may_overwrite_changes_in_your_working_directory46
           else
             Mess := Format(JVCSRES_Are_you_sure_to_synchronize_6037s62_with_the_archive63 + #13#10 +
               JVCSRES_This_may_overwrite_files_on_your_local_disk46, [Target]);
         end;
      1: begin
           if Target = '' then
             Mess := Format(JVCSRES_Are_you_sure_you_want_to_restore_37s_of_this_project_in + #13#10 +
               '%s?' + #13#10 +
               JVCSRES_This_may_overwrite_files_in_the_target_folders46,
               [Format(JVCSRES_version_37d4637d, [speVer.AsInteger, speRev.AsInteger]),
                 JVCSRES_your_working_directory])
           else
             Mess := Format(JVCSRES_Are_you_sure_you_want_to_restore_37s_of_this_project_in + #13#10 +
               '%s?' + #13#10 +
               JVCSRES_This_may_overwrite_files_in_the_target_folders46,
               [Format(JVCSRES_version_37d4637d, [speVer.AsInteger, speRev.AsInteger]),
                Format(JVCSRES_folder_6037s62, [Target])]);
         end;
      2: begin
           if Target = '' then
             Mess := Format(JVCSRES_Are_you_sure_you_want_to_restore_37s_of_this_project_in + #13#10 +
               '%s?' + #13#10 +
               JVCSRES_This_may_overwrite_files_in_the_target_folders46,
                 [JVCSRES_the_labeled_version, JVCSRES_your_working_directory])
           else
             Mess := Format(JVCSRES_Are_you_sure_you_want_to_restore_37s_of_this_project_in + #13#10 +
               '%s?' + #13#10 +
               JVCSRES_This_may_overwrite_files_in_the_target_folders46,
                 [JVCSRES_the_labeled_version, Format(JVCSRES_folder_6037s62, [Target])]);
         end;
      3: begin
           if Target = '' then
             Mess := Format(JVCSRES_Are_you_sure_you_want_to_restore_37s_of_this_project_in + #13#10 +
               '%s?' + #13#10 +
               JVCSRES_This_may_overwrite_files_in_the_target_folders46,
                 [JVCSRES_this_development_state, JVCSRES_your_working_directory])
           else
             Mess := Format(JVCSRES_Are_you_sure_you_want_to_restore_37s_of_this_project_in + #13#10 +
               '%s?' + #13#10 +
               JVCSRES_This_may_overwrite_files_in_the_target_folders46,
                 [JVCSRES_this_development_state, Format(JVCSRES_folder_6037s62, [Target])]);
         end;
      end;
      if rbSelDiff.Checked or
        (PageControl1.ActivePage = SheetRollBack) then
      begin
        if cbCRC32.Checked or
          (PageControl1.ActivePage = SheetRollBack) then
          Mess := Mess + #13#10 + Format(JVCSRES_40All_files_with_a_different_37s_will_be_overwritten_with_the_version_stored_in_the_archive4641,
            [JVCSRES_checksum])
        else
          Mess := Mess + #13#10 + Format(JVCSRES_40All_files_with_a_different_37s_will_be_overwritten_with_the_version_stored_in_the_archive4641,
            [JVCSRES_date]);

        mbIcon := MB_ICONWARNING;
      end
      else
        mbIcon := MB_ICONQUESTION;
    end // if bProjectOpen then begin
    else
    begin
      Mess := JVCSRES_Are_you_sure_you_want_to_create_a_new_working_directory_with_the_selected_modules63;
      mbIcon := MB_ICONQUESTION;
    end;

    Result := MessageBox(WindowHandle, PChar(Mess), cMsgBoxCaption, MB_YESNOCANCEL or
      MB_DEFBUTTON2 or mbIcon);
  end;

begin
  Msg := '';
  Mess := '';
  if (GetCurrLV.Items.Count = 0) then Exit;
  if tv_Project_List.Items.Count = 0 then Exit;
  Node := tv_Project_List.Items[0];
  try
    btnSync.Caption := JVCSRES_Cancel;
    Application.ProcessMessages;
    Prj_Count := 0;
    UpdatedCnt := 0;
    FRemoveHiddenFilesYesToAll := False;

    if rbNewfldr.Checked then
    begin
      if not DirectoryExists(rcbxNewFolder.Text) then
      begin
        MessageBox(WindowHandle, PChar(JVCSRES_Target_folder_cannot_be_blank46_Define_a_target_folder_and_retry46), cMsgBoxCaption,
          MB_OK or MB_ICONEXCLAMATION);
        Abort;
      end;
      Target := SetBackSlash(rcbxNewFolder.Text);
    end
    else
    begin
      Target := '';
    end;

    if Confirmation <> IDYES then
      Exit;
//  Victorious: Superfluous call
//    GetHiddenAndChkOutByMeModules;

    while Assigned(Node) and (not FPressedEsc) do
    begin
      if tv_Project_List.Checked[Node] then
      begin
        ProjectID := TProject_Desc(Node.Data).Project_ID;
        Inc(Prj_Count);
        case Mode of
        0: begin
             TProject_Desc(Node.Data).LatestRes.InSync := 0;
             Sync_Project(ProjectID, TProject_Desc(Node.Data).LatestRes, Target, Mess);
             Inc(UpdatedCnt,TProject_Desc(Node.Data).LatestRes.InSync);
             if Msg = '' then Msg := Format(JVCSRES_Synchronize_complete46_37d_files_updated46,
                                            [TProject_Desc(Node.Data).LatestRes.InSync])
             else Msg := Msg + #13 + Format(JVCSRES_Synchronize_complete46_37d_files_updated46,
                                            [TProject_Desc(Node.Data).LatestRes.InSync]);
           end;
        1: begin
             TProject_Desc(Node.Data).VersionRes.InSync := 0;
             Sync_Project(ProjectID, TProject_Desc(Node.Data).VersionRes, Target, Mess);
             Inc(UpdatedCnt,TProject_Desc(Node.Data).VersionRes.InSync);
             if Msg = '' then Msg := Format(JVCSRES_Synchronize_complete46_37d_files_updated46,
                                            [TProject_Desc(Node.Data).VersionRes.InSync])
             else Msg := Msg + #13 + Format(JVCSRES_Synchronize_complete46_37d_files_updated46,
                                            [TProject_Desc(Node.Data).VersionRes.InSync]);
           end;
        2: begin
             TProject_Desc(Node.Data).LabeledRes.InSync := 0;
             Sync_Project(ProjectID, TProject_Desc(Node.Data).LabeledRes, Target, Mess);
             Inc(UpdatedCnt,TProject_Desc(Node.Data).LabeledRes.InSync);
             if Msg = '' then Msg := Format(JVCSRES_Synchronize_complete46_37d_files_updated46,
                                            [TProject_Desc(Node.Data).LabeledRes.InSync])
             else Msg := Msg + #13 + Format(JVCSRES_Synchronize_complete46_37d_files_updated46,
                                            [TProject_Desc(Node.Data).LabeledRes.InSync]);
           end;
        3: begin
             TProject_Desc(Node.Data).RollbackRes.InSync := 0;
             Sync_Project(ProjectID, TProject_Desc(Node.Data).RollbackRes, Target, Mess);
             Inc(UpdatedCnt,TProject_Desc(Node.Data).RollbackRes.InSync);
             if Msg = '' then Msg:= Format(JVCSRES_Synchronize_complete46_37d_files_updated46,
                                           [TProject_Desc(Node.Data).RollbackRes.InSync])
             else Msg := Msg+#13+Format(JVCSRES_Synchronize_complete46_37d_files_updated46,
                                        [TProject_Desc(Node.Data).RollbackRes.InSync]);
           end;
        end; // Case
      end; // if tv_Project_List.Checked[Node]
      Node := Node.GetNext;
    end; // while Assigned(Node)
    if not cbSummary.Checked then
    begin
      UseRegistry := True;
      DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
      DSAIdentsMessageDlg(Format(JVCSRES_Synchronize_complete46_37d_files_updated46, [UpdatedCnt])
        , mtInformation
        , [mbOK]
        , 0
        , sBaseRegistryKey + crbMRU + 'Dlgs'
        , 'SyncRes'
        , idOk
        );
    end
    else
    begin
      VCSStdListView := TVCSStdListView.Create(Application);
      try
        VCSStdListView.LVRepID := 21;
        VCSStdListView.Caption := JVCSRES_Synchronize_results;
        VCSStdListView.Left := Left + 40;
        VCSStdListView.Top := Top + 40;
        VCSStdListView.LVType := 0;
        if bProjectOpen then
          VCSStdListView.HelpContextID := IDH_Synchronize
        else
          VCSStdListView.HelpContextID := IDH_Create_from_DB;
        VCSStdListView.AddListColumn(JVCSRES_Base_module, False);
        VCSStdListView.AddListColumn(JVCSRES_Affected_files, False);
        VCSStdListView.SetUpItems(Mess);
        VCSStdListView.ShowModal;
      finally
        VCSStdListView.Free;
      end;
    end; // if not  cbSummary.Checked then begin
    if (Mode = 0) and (Prj_Count < 2) then
      TimerCloseForm.Enabled := True;
  finally
    SetSyncCaption;
  end;
end;

procedure TVCSSync.btnSyncClick(Sender: TObject);
begin
  Sync_Project_List(PageControl1.ActivePageIndex);
end;

//------------------------------------------------------------------------------

procedure TVCSSync.SelectAll1Click(Sender: TObject);
begin
  if Sender = UnselectAll1 then
    CheckAllListViewItems(GetCurrLV, 0)
  else
  if Sender = SelectAll1 then
    CheckAllListViewItems(GetCurrLV, 1);
end;

//------------------------------------------------------------------------------

procedure TVCSSync.btnCloseClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSSync.HelpTopicF11Click(Sender: TObject);
begin
  if bProjectOpen then
    PerformHelpCommand(Application, IDH_Synchronize)
  else
    PerformHelpCommand(Application, IDH_Create_from_DB);
end;

//------------------------------------------------------------------------------

procedure TVCSSync.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
  begin
    if bProjectOpen then
      PerformHelpCommand(Application, IDH_Synchronize)
    else
      PerformHelpCommand(Application, IDH_Create_from_DB);
  end;
  if Key = VK_ESCAPE then
  begin
    if FIsInVerify then
      FPressedEsc := True
    else
      btnCloseClick(Self);
    Key := 0;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSSync.FormClose(Sender: TObject; var Action: TCloseAction);
var
  CurrLV: TdfsEnhListView;
begin
  if ProjectIDChanged then
  begin
    with DataModule1 do
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_PROJECT_ID';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [OriginalProjectName]);
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
        TransactionNr := _StrToInt(AppSrvClient1.Answer.Fields[2])
      else
        TransactionNr := -1;
    end; // with DataModule1 do begin
  end; // if ProjectIDChanged then begin

  jvcsWriteWindowPosAndSize(sBaseRegistryKey + crbWindows, 'Sync',
    Top, Left, Width, Height);

  CurrLV := GetCurrLV;
  with CurrLV do
  begin
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'Sync_Col1.0',
      Columns[0].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'Sync_Col1.1',
      Columns[1].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'Sync_Col1.2',
      Columns[2].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'Sync_Col1.3',
      Columns[3].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'Sync_Col1.4',
      Columns[4].Width);
  end;

  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'Sync_IncludeHidden',
    cbInclHidden.Checked);
  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'Sync_ShowSummary',
    cbSummary.Checked);

  if bProjectOpen then
  begin
    jvcsWriteBool(sBaseRegistryKey + crbWindows, 'Sync_VerifyCRC32',
      cbCRC32.Checked);
    jvcsWriteBool(sBaseRegistryKey + crbWindows, 'Sync_RemoveHidden',
      cbRemoveHidden.Checked);
    jvcsWriteBool(sBaseRegistryKey + crbWindows, 'Sync_IncludeChkOutByMe',
      cbInclChkOutByMe.Checked);
    jvcsWriteBool(sBaseRegistryKey + crbWindows, 'Sync_RO_Flag',
      cbROFlag.Checked);
    jvcsWriteBool(sBaseRegistryKey + crbWindows, 'Sync_Load_Project_Tree',
      cbLoadProjectTree.Checked);
  end;
  jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'tv_Project_List_Width',
    pan_Project_List.Width);

  {$IFDEF IDEDLL}
  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'Sync_AutoReload',
    cbReload.Checked);
  {$ENDIF IDEDLL}

  ChDir(ActDir);
end;

//------------------------------------------------------------------------------

procedure TVCSSync.SetSyncCaption;
begin
  case PageControl1.ActivePage.PageIndex of
  0: btnSync.Caption := JVCSRES_38Sync;
  1,2: btnSync.Caption := JVCSRES_Re38store;
  3: btnSync.Caption := JVCSRES_Rollb38ack;
  end; //Case
end;

procedure TVCSSync.PageControl1Change(Sender: TObject);
begin
  GroupBox3.Visible := (PageControl1.ActivePage <> SheetRollBack);
  if (not KWSet) and (PageControl1.ActivePage = SheetKey) then
  begin
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

      LabelIDs.Clear;
      AppSrvClient1.Answer.First;
      // Labels
      while (not AppSrvClient1.Answer.Eof) do
      begin
        LabelIDs.Add(AppSrvClient1.Answer.Fields[1] + '=' +
          AppSrvClient1.Answer.Fields[0]);
        ecbxKeyword.Items.Add(AppSrvClient1.Answer.Fields[1]);
        AppSrvClient1.Answer.Next;
      end; // while (not AppSrvClient1.Answer.EoF)
    end; // with DataModule1 do begin
    KWSet := True;
  end; // if not KWSet then begin

  SetSyncCaption;

  btnVerify.Enabled := True;
end;

//------------------------------------------------------------------------------

procedure TVCSSync.Reload_Wait4Server;
begin
  with DataModule1 do
  begin
    while WaitForAppSrvClient do
      Application.ProcessMessages;
    if (AppSrvClientErr = -99) then
    begin
      ShowServerTimeOut(WindowHandle);
      SetTransState(tsWait);
      StatusBar.Panels[sbStatus].Text := JVCSRES_Error;
      ShowStatusBarGauge(False, False);
      Abort;
    end;
    if (AppSrvClientErr <> 0) or
      (AppSrvClient1.AnswerStatus <> '200') then
    begin
      ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
        AppSrvClient1.AnswerStatus);
      SetTransState(tsWait);
      StatusBar.Panels[sbStatus].Text := JVCSRES_Error;
      ShowStatusBarGauge(False, False);
      Abort;
    end;
  end;
end;

procedure TVCSSync.Reload_ProcessAnswer(Project_ID: Integer; var Res: TProjectSearchRec; Lv_Target: TdfsEnhListView);
var
  ModuleID: Integer;
  CurrentPath, CurrentFileBase, CurrentFile: string;
  FExists: Boolean;
  LVItem: TListItem;
  sfi: TSHFileInfo;
begin
  with DataModule1 do
  begin
    Screen.Cursor := crHourGlass;
    AppSrvClient1.Answer.First;
    while not AppSrvClient1.Answer.Eof do
    begin
      if FPressedEsc then
      begin
        {$IFDEF DEBUG}
        JclDebug.TraceMsg('Break Signaled');
        {$ENDIF DEBUG}
        Break;
      end;
      Inc(Res.All);
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
          ChangeFileExt(CurrentFileBase,
            TrimRight(AppSrvClient1.Answer.Fields[7]));
        FExists := FileExists(CurrentPath + CurrentFile);
        // NewItem
        LVItem := Lv_Target.Items.Add;
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
        begin
          LVItem.ImageIndex := -1;
          Inc(Res.NotFound);
        end;
        // Version
        LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[4] + '.' +
          AppSrvClient1.Answer.Fields[5]);
        // Date
        LVItem.SubItems.Add(DateTimeToStr(GMTStr2LocalDateTime(AppSrvClient1.Answer.Fields[6])));
        // CRC32
        LVItem.SubItems.Add(IntToHex(_StrToInt(AppSrvClient1.Answer.Fields[8]), 8));
        // Path
        LVItem.SubItems.Add(CurrentPath);
        // Module ID
        LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[0]);
        // Revision ID
        LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[3]);
        // Parent?
        if CurrentFile = CurrentFileBase then
          LVItem.SubItems.Add('1')
        else
          LVItem.SubItems.Add('0');
        // Date Value
        LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[6]);
        // Project_ID
        LVItem.SubItems.Add(IntToStr(Project_ID));
        // Diff Type
        LVItem.SubItems.Add(IntToStr(Ord(dtNoDiff)));

        AppSrvClient1.Answer.Next;
      end; // while (not Answer.EoF) and....
    end; // while not AppSrvClient1.Answer.EoF do begin
  end;
end;

procedure TVCSSync.Reload_Project(ProjectID: Integer; var Res: TProjectSearchRec);
begin
  {$IFDEF DEBUG}
  JclDebug.TraceFmt('Sync: Start Reload_Project %d', [ProjectID]);
  {$ENDIF DEBUG}
  with DataModule1 do
  begin
    //--- get revisions --------------------------------------------------------
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_LATEST_REVISIONS';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [ProjectID]);
    AppSrvClient1.Request.WriteFields(False, [not cbInclHidden.Checked]);
    AppSrvClient1.Request.WriteFields(False, [0]); // LabelID = 0
    SetupTimeoutCounter;
    AppSrvClient1.Send;
  end; // with DataModule1 do begin
  Reload_Wait4Server;
  Reload_ProcessAnswer(ProjectID, Res, lvDateItems);
  {$IFDEF DEBUG}
  JclDebug.TraceFmt('Sync: Stop Reload_Project %d', [ProjectID]);
  {$ENDIF DEBUG}
end;

procedure TVCSSync.Reload_Version(ProjectID: Integer; var Res: TProjectSearchRec);
begin
  if (speVer.AsInteger < 0) or (speRev.AsInteger < 0) then
  begin
    MessageBox(Handle,
      PChar(JVCSRES_You_cannot_search_for_negative_version47revision_numbers46),
      cMsgBoxCaption, MB_OK or MB_ICONWARNING);
    Abort;
  end;
  with DataModule1 do
  begin
    //--- get revisions --------------------------------------------------------
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_VERSION_REVISION';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [ProjectID]);
    AppSrvClient1.Request.WriteFields(False, [not cbInclHidden.Checked]);
    AppSrvClient1.Request.WriteFields(False, [speVer.AsInteger]);
    AppSrvClient1.Request.WriteFields(False, [speRev.AsInteger]);
    SetupTimeoutCounter;
    AppSrvClient1.Send;
  end; // with DataModule1 do begin
  Reload_Wait4Server;
  Reload_ProcessAnswer(ProjectID, Res, lvVersion);
end;

procedure TVCSSync.Reload_Labeled(ProjectID: Integer; LabelID: string; var Res: TProjectSearchRec);
begin
  with DataModule1 do
  begin
    //--- get revisions --------------------------------------------------------
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_LATEST_REVISIONS';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [ProjectID]);
    AppSrvClient1.Request.WriteFields(False, [not cbInclHidden.Checked]);
    AppSrvClient1.Request.WriteFields(False, [LabelID]);
    SetupTimeoutCounter;
    AppSrvClient1.Send;
  end; // with DataModule1 do begin
  Reload_Wait4Server;
  Reload_ProcessAnswer(ProjectID, Res, lvKWItems);
end;

procedure TVCSSync.Reload_Rollback(ProjectID: Integer; var Res:
    TProjectSearchRec);
var
  NewDate: Double;
begin
  NewDate := LocalDT2GMTDT(Int(dtpRollbackDate.Date) + Frac(dtpRollbackTime.Time));
  with DataModule1 do
  begin
    //--- get revisions --------------------------------------------------------
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_ROLLBACK_REVISIONS';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [ProjectID]);
    AppSrvClient1.Request.WriteFields(False, [not cbInclHidden.Checked]);
    AppSrvClient1.Request.WriteFields(False, [NewDate]);
    SetupTimeoutCounter;
    AppSrvClient1.Send;
  end; // with DataModule1 do begin
  Reload_Wait4Server;
  Reload_ProcessAnswer(ProjectID, Res, lvRollBack);
end;

procedure TVCSSync.Reload_Project_Contents(Mode: Integer);
var
  Node: TTreeNode;
  ProjectID: Integer;
  LabelID: string;
  CurrLV: TdfsEnhListView;
  TotalCnt: Integer;
begin
  if btnSearchFiles.Caption = JVCSRES_Cancel then
  begin
    FPressedEsc := True;
    Exit;
  end;
  try
    FIsInVerify := True;
    TotalCnt := 0;
    FPressedEsc := False;
    SetTransState(tsWait);
    if bProjectOpen then
      Caption := Format(JVCSRES_VCS_Synchronize_Query_45_37s,
        [AnsiLowerCase(ExtractFileName(sProjectName))])
    else
      Caption := JVCSRES_VCS_Create_from_DB;

    {$IFDEF CUSTOMDRIVE}
    sDriveSubst := RegReadString(HKCU, sBaseRegistryKey + crbProjects +
      ExtractFileName(SelectedProjectName), 'LocalDrive', '');
    if (sDriveSubst = '') then
      sDriveSubst := RegReadString(HKCU, sBaseRegistryKey + crbOptions,
        'LocalDrive', '');
    {$ENDIF CUSTOMDRIVE}

    if tv_Project_List.Items.Count = 0 then Exit;
    Node := tv_Project_List.Items[0];
    CurrLV := GetCurrLV;
    try
      CurrLV.AutoResort := False;
      CurrLV.BeginUpdate;
      CurrLV.Items.Clear;
      btnSearchFiles.Caption := JVCSRES_Cancel;
      StatusBar.Panels[sbStatus].Text := JVCSRES_Scanning464646;
      ShowStatusBarGauge(True, True);
      Application.ProcessMessages;
      while Assigned(Node) and (not FPressedEsc) do
      begin
        if tv_Project_List.Checked[Node] then
        begin
          ProjectID := TProject_Desc(Node.Data).Project_ID;
          case Mode of
          0: begin
               TProject_Desc(Node.Data).LatestRes.All := 0;
               TProject_Desc(Node.Data).LatestRes.NotFound := 0;
               Reload_Project(ProjectID, TProject_Desc(Node.Data).LatestRes);
               Inc(TotalCnt, TProject_Desc(Node.Data).LatestRes.All);
             end;
          1: begin
               TProject_Desc(Node.Data).VersionRes.All := 0;
               TProject_Desc(Node.Data).VersionRes.NotFound := 0;
               Reload_Version(ProjectID, TProject_Desc(Node.Data).VersionRes);
               Inc(TotalCnt, TProject_Desc(Node.Data).VersionRes.All);
             end;
          2: begin
               if ecbxKeyword.ItemIndex < 0 then Exit;
               LabelID := LabelIDs.Values[ecbxKeyword.Text];
               TProject_Desc(Node.Data).LabeledRes.All := 0;
               TProject_Desc(Node.Data).LabeledRes.NotFound := 0;
               Reload_Labeled(ProjectID, LabelID, TProject_Desc(Node.Data).LabeledRes);
               Inc(TotalCnt, TProject_Desc(Node.Data).LabeledRes.All);
             end;
          3: begin
               TProject_Desc(Node.Data).RollbackRes.All:= 0;
               TProject_Desc(Node.Data).RollbackRes.NotFound:= 0;
               Reload_Rollback(ProjectID, TProject_Desc(Node.Data).RollbackRes);
               Inc(TotalCnt, TProject_Desc(Node.Data).RollbackRes.All);
             end;
          end; // Case
        end; // if tv_Project_List.Checked[Node]
        Node:= Node.GetNext;
      end; // while Assigned(Node)
      StatusBar.Panels[sbStatus].Text := JVCSRES_Ready;
      ShowStatusBarGauge(False, False);
      case Mode of
      0: begin
           StatusBar.Panels[sbStatusText].Text := Format(JVCSRES_Server_reports_37d_revision_members,
                                               [TotalCnt]);
           if bProjectOpen then
             Caption := JVCSRES_VCS_Synchronize47_Restore_
           else
             Caption := JVCSRES_VCS_Create_from_DB;
           if not bProjectOpen then rbselOld.Checked := True;
         end;
      1: begin
           StatusBar.Panels[sbStatusText].Text := Format(JVCSRES_37d_files_assigned_to_label_6037s62,
                                               [TotalCnt, ecbxKeyword.Text]);
         end;
      2: begin
           StatusBar.Panels[sbStatusText].Text := Format(JVCSRES_37d_files_available_for_Rollback,
                                               [TotalCnt]);
         end;
      3: begin
           StatusBar.Panels[sbStatusText].Text := Format(JVCSRES_37d_modules_assigned_to_V_37d4637d,
             [TotalCnt, speVer.AsInteger, speRev.AsInteger]);
         end;
      end;
    finally
      CurrLV.AutoResort := True;
      CurrLV.EndUpdate;
      CurrLV.Resort;
      btnSearchFiles.Caption:= JVCSRES_Search_38Files;
    end;

    if not bProjectOpen then
      rbselOld.Checked := True;
    VerifyProject_List(Mode);
    tv_Project_List.Repaint;
    Screen.Cursor := crDefault;
  finally
    FIsInVerify := False;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSSync.ecbxKeywordChange(Sender: TObject);
begin
  lvKWItems.Items.Clear;
  StatusBar.Panels[sbStatusText].Text := '';
end;

//------------------------------------------------------------------------------

procedure TVCSSync.dtpRollbackDateChange(Sender: TObject);
begin
  lvRollBack.Items.Clear;
  StatusBar.Panels[sbStatusText].Text := '';
end;

//------------------------------------------------------------------------------

procedure TVCSSync.rbselOldClick(Sender: TObject);
begin
  btnVerify.Enabled := True;
  CheckAllListViewItems(GetCurrLV, 0);
end;

//------------------------------------------------------------------------------

procedure TVCSSync.lvDateItemsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  HitTest: THitTests;
  HitItem: TListItem;
  NewState: Integer;
  CurrLV: TdfsEnhListView;
begin
  CurrLV := Sender as TdfsEnhListView;

  HitTest := CurrLV.GetHitTestInfoAt(X, Y);
  if (Button = mbLeft) and (htOnStateIcon in HitTest) then
  begin
    HitItem := CurrLV.GetItemAt(X, Y);
    if HitItem.StateIndex = 0 then
      NewState := 1
    else
      NewState := 0;
    HitItem.StateIndex := NewState;
    CheckMembers(CurrLV, HitItem.Index, NewState, HitItem.SubItems[lvItem_Revision_ID], HitItem.SubItems[lvItem_Diff_Type]);
  end; // if (Button = mbLeft) and (htOnStateIcon in HitTest) then begin
end;

//------------------------------------------------------------------------------

procedure TVCSSync.TimerCloseFormTimer(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

procedure TVCSSync.lvDateItemsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  NewState: Integer;
  CurrLV: TdfsEnhListView;
begin
  CurrLV := Sender as TdfsEnhListView;
  if (CurrLV.Selected <> nil) and (Key = VK_SPACE) then
  begin
    if CurrLV.Selected.StateIndex = 0 then
      NewState := 1
    else
      NewState := 0;
    CurrLV.Selected.StateIndex := NewState;
    CheckMembers(CurrLV, CurrLV.Selected.Index, NewState, CurrLV.Selected.SubItems[lvItem_Revision_ID], CurrLV.Selected.SubItems[lvItem_Diff_Type]);
  end; // if (CurrLV.Selected <> nil) and (Key = VK_SPACE) then begin
end;

//------------------------------------------------------------------------------

procedure TVCSSync.HelpClick(Sender: TObject);
var
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSSync.FormDestroy(Sender: TObject);
begin
  LabelIDs.Free;
  MruListNewFolder.Free;
  FHiddenModuleList.Free;
  FChkOutByMeModuleList.Free;
  FIgnoredModuleList.SaveToStorage(sBaseRegistryKey + '\IgnoredModules');
  FIgnoredModuleList.Free;
  Clear_ProjectTree;
end;

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

procedure TVCSSync.speVerChange(Sender: TObject);
begin
  if (Sender as TJvSpinEdit).AsInteger < 0 then
    (Sender as TJvSpinEdit).AsInteger := 0;
end;

//------------------------------------------------------------------------------

procedure TVCSSync.btnHistoryClick(Sender: TObject);
var
  CurrLV: TdfsEnhListView;
  LModuleName: string;
  LFound: Boolean;
  I, LRevisionID: Integer;
  LItem: TListItem;
begin
  CurrLV := GetCurrLV;
  if Assigned(CurrLV) and Assigned(CurrLV.Selected) then
  begin
    LItem := CurrLV.Selected;
    LModuleName := LItem.SubItems[lvItem_Original_Path] + LowerCase(LItem.Caption);
    //if the selected file is not the main file search the listview up and down
    if LItem.SubItems[lvItem_Parent] <> '1' then
    begin
      LRevisionID := StrToIntDef(LItem.SubItems[lvItem_Revision_ID], 0);
      if LRevisionID > 0 then
      begin
        LFound := False;
        I := LItem.Index - 1;
        while I >= 0 do
        begin
          if (StrToIntDef(CurrLV.Items[I].SubItems[lvItem_Revision_ID], 0) = LRevisionID) and
            (CurrLV.Items[I].SubItems[lvItem_Parent] = '1') then
          begin
            LFound := True;
            LModuleName := CurrLV.Items[I].SubItems[lvItem_Original_Path] +
              LowerCase(CurrLV.Items[I].Caption);
            Break;
          end;
          Dec(I);
        end; // while I >= 0 do
        if not LFound then
        begin
          I := LItem.Index + 1;
          while I < CurrLV.Items.Count do
          begin
            if (StrToIntDef(CurrLV.Items[I].SubItems[lvItem_Revision_ID], 0) = LRevisionID) and
              (CurrLV.Items[I].SubItems[lvItem_Parent] = '1') then
            begin
              LModuleName := CurrLV.Items[I].SubItems[lvItem_Original_Path] +
                LowerCase(CurrLV.Items[I].Caption);
              Break;
            end;
            Inc(I);
          end; // while I < CurrLV.Items.Count do
        end; // if not LFound then
      end; // if LRevisionID > 0 then
    end; // if LItem.SubItems[lvItem_Parent] <> '1' then
    VCSHistory := TVCSHistory.Create(Application);
    try
      VCSHistory.ModuleName := LModuleName;
      VCSHistory.ShowModal;
    finally
      VCSHistory.Free;
    end;
  end; // if Assigned(CurrLV) and Assigned(CurrLV.Selected) then
end;

//------------------------------------------------------------------------------

procedure TVCSSync.mmiHideUncheckedModulesClick(Sender: TObject);
begin
  mmiHideUncheckedModules.Checked := not mmiHideUncheckedModules.Checked;
  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'Sync_HideValid',
    mmiHideUncheckedModules.Checked);
  if not mmiHideUncheckedModules.Checked then
    MessageBox(Handle, PChar(Format(JVCSRES_This_change_will_not_take_effect_until_you_reopen_the_37s46,
      [JVCSRES_dialog])), cMsgBoxCaption,
      MB_OK or MB_ICONINFORMATION)
  else
    HideUncheckedModules;
end;

//------------------------------------------------------------------------------

procedure TVCSSync.HideUncheckedModules;
var
  I: Integer;
  CurrLV: TdfsEnhListView;
begin
  CurrLV := GetCurrLV;

  UseRegistry := True;
  DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
  if DSAIdentsMessageDlg(JVCSRES_All_unchecked_items_will_be_invisible_until_you_hit_the_34Refresh34_button46 + #13#10 +
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
  CurrLV.AutoResort := False;
  CurrLV.BeginUpdate;
  try
    while I < CurrLV.Items.Count do
    begin
      if CurrLV.Items[I].StateIndex <> 1 then
        CurrLV.Items[I].Delete
      else
        Inc(I);
    end;
  finally
    CurrLV.EndUpdate;
    CurrLV.AutoResort := True;
    CurrLV.Resort;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSSync.cbCRC32Click(Sender: TObject);
begin
  btnVerify.Enabled := True;
  rbselOld.Enabled:= not cbCRC32.Checked;
  rbselOld.Checked:= not cbCRC32.Checked;
  rbSelDiff.Checked:= cbCRC32.Checked;
end;

//------------------------------------------------------------------------------

function TVCSSync.GetListViewString(LV: TdfsEnhListView): string;
var
  CurrentText: string;
  I, J: Integer;
  oaColumnsWidth: array of Integer;
const
  cr = Chr(13) + Chr(10);

  function SizeString(const Column: Integer; const CellString: string;
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
    while Length(Result) < oaColumnsWidth[Column] do
      Result := Result + Fillchr;
  end;

  function ProjectList: string;
  var
    Node: TTreeNode;
  begin
    if tv_Project_List.Items.Count = 0 then Exit;
    Node := tv_Project_List.Items[0];
    Result := '';
    while Assigned(Node) and (not FPressedEsc) do
    begin
      if tv_Project_List.Checked[Node] then
      begin
        Result := Result + TProject_Desc(Node.Data).Project_Name + ', ';
      end;
      Node := Node.GetNext;
    end;
    Result := Copy(Result, 1, Length(Result) - 2);
  end;

begin
  Result := '';
  Screen.Cursor := crHourGlass;
  try
    with LV do
    begin
      if Items.Count = 0 then
      begin
        MessageBox(WindowHandle, PChar(JVCSRES_Requested_result_set_is_blank46_Nothing_to_do46),
          cMsgBoxCaption, MB_OK);
        Exit;
      end;
      // Textlänge in der Spalte?
      SetLength(oaColumnsWidth, Columns.Count);
      for I := 0 to Columns.Count - 1 do
      begin
        oaColumnsWidth[I] := Length(Columns[I].Caption);
        for J := 0 to Items.Count - 1 do
        begin
          if I = 0 then
            CurrentText := Items[J].Caption
          else
            CurrentText := Items[J].SubItems[I - 1];
          if Length(CurrentText) > oaColumnsWidth[I] then
            oaColumnsWidth[I] := Length(CurrentText);
        end; // for J := 0 to Items.Count - 1 do begin
      end; // for J := 0 to Columns.Count - 1 do begin
      oaColumnsWidth[0] := oaColumnsWidth[0] + 5;

      Result := Caption + cr;
      CurrentText := '';
      while Length(CurrentText) < Length(Caption) do
        CurrentText := CurrentText + '=';
      Result := Result + CurrentText + cr + cr;

      if tv_Project_List.Items.Count > 0 then
      begin
        if LV = lvDateItems then
          Result := Result + Format(JVCSRES_Synchronize_to_latest_4037s41,
            [ProjectList]);
        if LV = lvVersion then
          Result := Result + Format(JVCSRES_Restore_version_number_40V37d4637d41,
            [speVer.AsInteger, speRev.AsInteger]);
        if LV = lvKWItems then
          Result := Result + Format(JVCSRES_Restore_labeled_version_4037s41,
            [ecbxKeyword.Items[ecbxKeyword.ItemIndex]]);
        if LV = lvRollBack then
          Result := Result + Format(JVCSRES_Rollback_4037s41,
            [DateTimeToStr(Int(dtpRollbackDate.Date) + Frac(dtpRollbackTime.Time))]);
      end;

      Result := Result + cr + cr;
      Result := Result + Format(JVCSRES_37d_entries46, [Items.Count]) + cr + cr;

      for J := 0 to Columns.Count - 3 do
      begin
        Result := Result + SizeString(J, Columns[J].Caption, ' ');
        if J < (Columns.Count - 3) then
          Result := Result + ' | ';
      end;
      Result := Result + cr;
      for J := 0 to Columns.Count - 3 do
      begin
        Result := Result + SizeString(J, '-', '-');
        if J < (Columns.Count - 3) then
          Result := Result + ' | ';
      end;
      Result := Result + cr;

      for I := 0 to Items.Count - 1 do
      begin
        for J := 0 to Columns.Count - 3 do
        begin
          if J = 0 then
          begin
            if Items[I].StateIndex = 1 then
              CurrentText := 'x '
            else
              CurrentText := 'o ';
            CurrentText := CurrentText + Items[I].Caption;
          end
          else
            CurrentText := Items[I].SubItems[J - 1];
          Result := Result + SizeString(J, CurrentText, ' ');
          if J < (Columns.Count - 3) then
            Result := Result + ' | ';
        end; // for J := 0 to Columns.Count - 1 do begin
        Result := Result + cr;
      end; // for I := 0 to Items.Count - 1 do begin
    end; // with elv do begin

    Result := Result + cr + JVCSRES_Source58_ + sArchiveSource + cr +
      JVCSRES_JEDI_VCS_ + sProductVer + cProductInf + DateTimeToStr(Now) + cr;
  finally
    Screen.Cursor := crDefault;
    SetLength(oaColumnsWidth, 0);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSSync.btnReportClick(Sender: TObject);
var
  ResultString: string;
  CurrLV: TdfsEnhListView;
begin
  CurrLV := GetCurrLV;
  ResultString := GetListViewString(CurrLV);
  if ResultString = '' then
    Exit;

  VCSSimpleReport := TVCSSimpleReport.Create(Application);
  try
    VCSSimpleReport.RepID := 15;
    VCSSimpleReport.Left := Left + 60;
    VCSSimpleReport.Top := Top + 60;
    VCSSimpleReport.FullReportString := ResultString;
    VCSSimpleReport.SavePath := ExtractFileDir(sProjectName);
    VCSSimpleReport.SaveFileName := 'SyncList.txt';
    VCSSimpleReport.LineCount := CurrLV.Items.Count + 8;
    VCSSimpleReport.ShowModal;
  finally
    VCSSimpleReport.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSSync.ShowStatusBarGauge(const ShowGauge,
  Indeterminate: Boolean);
begin
  with StatusBar.Panels[sbStatusText] do
  begin
    if ShowGauge then
    begin
      SBTextBuffer := Text;
      Text := '';
      Alignment := taCenter;
      Paneltype := sptGauge;
      if Indeterminate then
      begin
        GaugeAttrs.Position := 0;
        GaugeAttrs.Speed := 5;
        GaugeAttrs.Style := gsIndeterminate2;
      end
      else
        GaugeAttrs.Style := gsPercent;
      GaugeAttrs.Position := 0;
    end
    else
    begin
      GaugeAttrs.Position := 0;
      GaugeAttrs.Style := gsPercent;
      Paneltype := sptNormal;
      Alignment := taLeftJustify;
      Text := SBTextBuffer;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSSync.StatusBarGaugePos(Value: Word);
begin
  if Value > 100 then
    Value := 100;
  with StatusBar.Panels[sbStatusText] do
    if (Paneltype = sptGauge) and
      (GaugeAttrs.Position <> Value) then
      GaugeAttrs.Position := Value;
end;

//------------------------------------------------------------------------------

procedure TVCSSync.cbInclHiddenClick(Sender: TObject);
begin
  if bProjectOpen then
  begin
    cbRemoveHidden.Enabled := cbInclHidden.Checked;
    if not cbRemoveHidden.Enabled then
      cbRemoveHidden.Checked := False;
  end;
end;

function TVCSSync.IsChkOutByMe(AModuleID: Integer): Boolean;
begin
  Result := False;
  if AModuleID > 0 then
    Result := FChkOutByMeModuleList.IndexOf(AModuleID) <> -1;
end;

function TVCSSync.IsDontSyncChkOutByMeEnabled: Boolean;
begin
  Result := not cbInclChkOutByMe.Checked;
end;

function TVCSSync.IsHiddenFile(AModuleID: Integer): Boolean;
begin
  Result := False;
  if AModuleID > 0 then
    Result := FHiddenModuleList.IndexOf(AModuleID) <> -1;
end;

function TVCSSync.IsRemoveHiddenEnabled: Boolean;
begin
  Result := cbInclHidden.Checked and cbRemoveHidden.Checked;
end;

procedure TVCSSync.GetHiddenAndChkOutByMeModules_ByProject(Project_ID: Integer);
var
  ModuleID: Integer;
  CheckedOut, Hidden: Boolean;
  MOwner: string;
  {$IFDEF DEBUG}
  RowsProcessed: Integer;
  {$ENDIF DEBUG}
begin
  {$IFDEF DEBUG}
  RowsProcessed:= 0;
  {$ENDIF DEBUG}
  if bProjectOpen then
    with DataModule1 do
    begin
      if cbInclHidden.Checked then
      begin
        AppSrvClient1.Request.Rewrite;
        AppSrvClient1.FunctionCode := 'GET_VERSION_LIST';
        AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
        AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
        AppSrvClient1.Request.WriteFields(True, [Project_ID]);
        AppSrvClient1.Request.WriteFields(False, [False]);

        SetupTimeoutCounter;
        AppSrvClient1.Send;

        while WaitForAppSrvClient do
          Application.ProcessMessages;
        if (AppSrvClientErr = -99) then
        begin
          ShowServerTimeOut(WindowHandle);
          SetTransState(tsWait);
          StatusBar.Panels[sbStatus].Text := JVCSRES_Error;
          ShowStatusBarGauge(False, False);
          Exit;
        end;
        if (AppSrvClientErr <> 0) or
          (AppSrvClient1.AnswerStatus <> '200') then
        begin
          ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
            AppSrvClient1.AnswerStatus);
          SetTransState(tsWait);
          StatusBar.Panels[sbStatus].Text := JVCSRES_Error;
          ShowStatusBarGauge(False, False);
          Exit;
        end;

        while not AppSrvClient1.Answer.Eof do
        begin
          ModuleID   := _StrToInt(AppSrvClient1.Answer.Fields[0]);
          CheckedOut := DecodeBoolStr(AppSrvClient1.Answer.Fields[3]);
          MOwner     := AppSrvClient1.Answer.Fields[10];
          Hidden     := AppSrvClient1.Answer.Fields[9] = '1';

          {$IFDEF DEBUG}
          Inc(RowsProcessed);
          {$ENDIF DEBUG}
         if Hidden then
            FHiddenModuleList.Add(ModuleID);

          if CheckedOut and (MOwner = sCurrentUser) then
            FChkOutByMeModuleList.Add(ModuleID);

          AppSrvClient1.Answer.Next;
        end;
      {$IFDEF DEBUG}
      JclDebug.TraceFmt('Sync: GET_VERSION_LIST Processed rows %d Hidden %d CheckedOutByMe %d',
        [RowsProcessed, FHiddenModuleList.Count, FChkOutByMeModuleList.Count]);
      {$ENDIF DEBUG}
      end
      else
      begin
        with DataModule1 do
        begin
          AppSrvClient1.Request.Rewrite;
          AppSrvClient1.FunctionCode := 'GET_LOCKED_MODULES';
          AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
          AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
          AppSrvClient1.Request.WriteFields(True, [Project_ID]);
          AppSrvClient1.Request.WriteFields(False, [ServerUserID]);

          SetupTimeoutCounter;
          AppSrvClient1.Send;

          while WaitForAppSrvClient do
            Application.ProcessMessages;
          if (AppSrvClientErr = -99) then
          begin
            ShowServerTimeOut(WindowHandle);
            SetTransState(tsWait);
            StatusBar.Panels[sbStatus].Text := JVCSRES_Error;
            ShowStatusBarGauge(False, False);
            Exit;
          end;
          if (AppSrvClientErr <> 0) or
            (AppSrvClient1.AnswerStatus <> '200') then
          begin
            ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
              AppSrvClient1.AnswerStatus);
            SetTransState(tsWait);
            StatusBar.Panels[sbStatus].Text := JVCSRES_Error;
            ShowStatusBarGauge(False, False);
            Exit;
          end;

          while not AppSrvClient1.Answer.Eof do
          begin
            {$IFDEF DEBUG}
            Inc(RowsProcessed);
            {$ENDIF DEBUG}
            ModuleID   := _StrToInt(AppSrvClient1.Answer.Fields[0]);
            FChkOutByMeModuleList.Add(ModuleID);
            AppSrvClient1.Answer.Next;
          end;
        end;
      {$IFDEF DEBUG}
      JclDebug.TraceFmt('Sync: GET_LOCKED_MODULES Processed rows %d Hidden %d CheckedOutByMe %d',
        [RowsProcessed, FHiddenModuleList.Count, FChkOutByMeModuleList.Count]);
      {$ENDIF DEBUG}
      end;
    end;
end;

procedure TVCSSync.GetHiddenAndChkOutByMeModules;
var
  Node: TTreeNode;
  ProjectID: Integer;
begin
  {$IFDEF DEBUG}
  JclDebug.TraceMsg('Sync: Start GetHiddenAndChkOutByMeModules');
  {$ENDIF DEBUG}
  FHiddenModuleList.Clear;
  FChkOutByMeModuleList.Clear;
  if tv_Project_List.Items.Count = 0 then Exit;
  Node := tv_Project_List.Items[0];
  while Assigned(Node) do
  begin
    if tv_Project_List.Checked[Node] then
    begin
      ProjectID := TProject_Desc(Node.Data).Project_ID;
      GetHiddenAndChkOutByMeModules_ByProject(ProjectID);
    end;
    Node := Node.GetNext;
  end;
  {$IFDEF DEBUG}
  JclDebug.TraceMsg('Sync: Stop GetHiddenAndChkOutByMeModules');
  {$ENDIF DEBUG}
end;

function TVCSSync.DeleteHiddenFiles(AModuleName: string; ARevisionID: Integer;
  var ErrMsg, AffectedFiles: string): Integer;
var
  CurrentModuleName, FileExtension: string;
  FAttr: Integer;
  Res: Integer;
  ModuleFiles: TStringList;
  I, DlgRes: Integer;
  CanDeleteFiles: Boolean;
begin
  Result := 0;
  ErrMsg := '';
  AffectedFiles := '';
  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_REVISION_STATUS';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [ARevisionID]);

    SetupTimeoutCounter;
    AppSrvClient1.Send;

    while WaitForAppSrvClient do
      Application.ProcessMessages;
    if (AppSrvClientErr = -99) then
    begin
      ErrMsg := JVCSRES_AppSrvClient46Request_timed_Out_91GET95REVISION95STATUS93;
      Result := 1;
      Exit;
    end;
    if (AppSrvClientErr <> 0) or
      (AppSrvClient1.AnswerStatus <> '200') then
    begin
      ErrMsg := JVCSRES_AppSrvClient46Request_Error_91GET95REVISION95STATUS93;
      Result := 1;
      Exit;
    end;

    ModuleFiles := TStringList.Create;
    try
      while not AppSrvClient1.Answer.Eof do
      begin
        FileExtension := TrimRight(AppSrvClient1.Answer.Fields[10]);
        CurrentModuleName := ChangeFileExt(AModuleName, FileExtension);
        AffectedFiles :=
            AffectedFiles + ExtractFileName(CurrentModuleName) + '/';
        if FileExists(CurrentModuleName) then
          ModuleFiles.Add(CurrentModuleName);
        AppSrvClient1.Answer.Next;
      end;

      if ModuleFiles.Count > 0 then
      begin
        CanDeleteFiles := FRemoveHiddenFilesYesToAll;
        if not CanDeleteFiles then
        begin
          BeepIfSet;
          DlgRes := MessageDlg(Format(JVCSRES_6037s62_is_marked_as_hidden_and_exists_in_target_folder46,
            [AModuleName]) + #13#13 + JVCSRES_Should_it_be_removed_in_target_folder_63, mtConfirmation,
            [mbYes, mbYesToAll, mbNo], 0);
          case DlgRes of
            mrYes: CanDeleteFiles := True;
            mrYesToAll: begin
                         CanDeleteFiles := True;
                         FRemoveHiddenFilesYesToAll := True;
                        end;
          end;
        end;

        if CanDeleteFiles then
          for I := 0 to Pred(ModuleFiles.Count) do
          begin
            CurrentModuleName := ModuleFiles[I];
            FAttr := FileGetAttr(CurrentModuleName);
            if FAttr <> -1 then
            begin
              if FAttr and faReadOnly = faReadOnly then
              begin
                FAttr := FAttr - faReadOnly;
                Res := FileSetAttr(CurrentModuleName, FAttr);
                if Res <> 0 then
                begin
                  ErrMsg := Format(JVCSRES_Could_not_set_attributes_of58_6037s62_Windowserrorcode58_37d_4037s41,
                    [CurrentModuleName, Res, SysErrorMessage(Res)]);
                  Result := 3;
                  Exit;
                end;
              end;
            end
            else
            begin
              ErrMsg := Format(JVCSRES_Could_not_get_attributes_of_6037s62_4037s41,
                [CurrentModuleName, SysErrorMessage(GetLastError)]);
              Result := 2;
              Exit;
            end;

            if not DeleteFile(CurrentModuleName) then
            begin
              ErrMsg := Format(JVCSRES_Could_not_delete_6037s62_4037s41,
                [CurrentModuleName, SysErrorMessage(GetLastError)]);
              Result := 4;
              Exit;
            end;
          end;
      end;
    finally
      ModuleFiles.Free;
    end;
  end;
end;

function TVCSSync.IsIgnoredModule(AModuleID, ARevisionID: Integer;
  APath: string): Boolean;
var
  IgnoreIndex: Integer;
  IgnoredModuleRec: TIgnoredModuleRec;
begin
  Result := False;
  IgnoreIndex := FIgnoredModuleList.IndexOf(sArchiveSource, AModuleID);
  if IgnoreIndex <> -1 then
  begin
    IgnoredModuleRec := FIgnoredModuleList[IgnoreIndex];
    Result := (IgnoredModuleRec.RevisionID = ARevisionID) and
      (IgnoredModuleRec.Hidden = IsHiddenFile(AModuleID)) and
      (SameText(IgnoredModuleRec.Path, APath));
    //remove the module from the ignore list if something changed on the module
    if not Result then
      FIgnoredModuleList.Delete(IgnoreIndex);
  end;
end;

function TVCSSync.IsIgnoreModulesEnabled: Boolean;
begin
  //reserved for later use
  Result := True;
end;

procedure TVCSSync.mmiIgnoreModuleRevisionClick(Sender: TObject);
var
  LV: TdfsEnhListView;
  LVItem: TListItem;
  ListItems: TList;
  ModuleID, RevisionID: Integer;
  ModuleFileNames: string;
  I: Integer;
begin
  LV := GetCurrLV;
  LVItem := LV.Selected;
  if Assigned(LVItem) then
  begin
    ModuleID := StrToIntDef(LVItem.SubItems[lvItem_Module_ID], 0);
    RevisionID := StrToIntDef(LVItem.SubItems[lvItem_Revision_ID], 0);
    if (ModuleID <> 0) and (RevisionID <> 0) then
    begin
      ModuleFileNames := '';
      ListItems := nil;
      try
        ListItems := TList.Create;
        for I := 0 to Pred(LV.Items.Count) do
          if StrToIntDef(LV.Items[I].SubItems[lvItem_Module_ID], 0) = ModuleID then
          begin
            ListItems.Add(LV.Items[I]);
            if ModuleFileNames <> '' then
              ModuleFileNames := ModuleFileNames + '/';
            ModuleFileNames := ModuleFileNames + LV.Items[I].Caption;
          end;

        if NoYesMessageBox(Format(JVCSRES_Would_you_like_to_ignore_6037s62_in_this_revision_63, [ModuleFileNames])
          + #13#13 + JVCSRES_This_module_will_be_ignored_in_the_syncronice_process_until_the_RevisionID44_the_hidden_state_or_the_path_changes_33) then
        begin
          FIgnoredModuleList.Add(sArchiveSource, ModuleID, RevisionID,
            IsHiddenFile(ModuleID), LVItem.SubItems[lvItem_Original_Path], ModuleFileNames);
          for I := 0 to Pred(ListItems.Count) do
            TListItem(ListItems[I]).Delete;
        end;
      finally
        ListItems.Free;
      end;
    end;
  end;
end;

procedure TVCSSync.lvSortItems(Sender: TObject; Item1,
  Item2: TListItem; SortColumn: Integer; var SortAs: TSortAs;
  var CompResult: Integer);

  function GetParentItem(AListItem: TListItem; AListView: TdfsEnhListView): TListItem;
  var
    I: Integer;
    ModuleIDstr: string;
  begin
    Result := AListItem;
    if (AListItem.SubItems.Count >= 6) and (AListItem.SubItems[lvItem_Parent] <> '1') then
    begin
      if Assigned(AListItem.Data) and (TObject(AListItem.Data) is TListItem) then
        Result := AListItem.Data
      else
      begin
        ModuleIDstr := AListItem.SubItems[lvItem_Module_ID];
        for I := 0 to Pred(AListView.Items.Count) do
          with AListView.Items[I] do
            if (SubItems.Count >= 6) and (SubItems[lvItem_Module_ID] = ModuleIDstr) and
              (SubItems[lvItem_Parent] = '1')
            then
            begin
              Result := AListView.Items[I];
              AListItem.Data := Result;
              Break;
            end;
      end;
    end;
  end;

  procedure GetVersionAndRevision(AVersionStr: string; var AVersion, ARevision: Integer);
  var
    p1: Integer;
  begin
    p1 := Pos('.', AVersionStr);
    if p1 > 0 then
    begin
      AVersion := StrToIntDef(Copy(AVersionStr, 1, p1 -1), 0);
      Delete(AVersionStr, 1, p1);
    end
    else
      AVersion := 0;
    ARevision := StrToIntDef(AVersionStr, 0);
  end;

  function VersionCompare(AVersionStr1, AVersionStr2: string): Integer;
  var
    Version1, Version2,
    Revision1, Revision2: Integer;
  begin
    GetVersionAndRevision(AVersionStr1, Version1, Revision1);
    GetVersionAndRevision(AVersionStr2, Version2, Revision2);
    Result := Version1 - Version2;
    if Result = 0 then
      Result := Revision1 - Revision2;
  end;

var
  ListItem1, ListItem2: TListItem;
  s1, s2: string;
  KeepModuleTogether: Boolean;
begin
  //USc 21.10.2003
  //  keeps the files of module together
  //
  //  it seams not to be necessary that the files of a module are together
  //  and keeping the files together maybe confuses the user because the child
  //  values have nothing to do with the choosen sort
  KeepModuleTogether := False;

  if KeepModuleTogether then
  begin
    ListItem1 := GetParentItem(Item1, TdfsEnhListView(Sender));
    ListItem2 := GetParentItem(Item2, TdfsEnhListView(Sender));
  end
  else
  begin
    ListItem1 := Item1;
    ListItem2 := Item2;
  end;

  if SortColumn = -1 then
  begin
    s1 := ListItem1.Caption;
    s2 := ListItem2.Caption;
  end
  else
  if SortColumn >= 0 then
  begin
    if SortColumn < ListItem1.SubItems.Count then
      s1 := ListItem1.SubItems[SortColumn];
    if SortColumn < ListItem2.SubItems.Count then
      s2 := ListItem2.SubItems[SortColumn];
  end;
  if (SortColumn = -1) or (SortColumn = 3) then
    CompResult := AnsiCompareStr(s1, s2)
  else
  if SortColumn = 0 then
    CompResult := VersionCompare(s1, s2)
  else
  if SortColumn = 1 then
    CompResult := CompareDateTimeStrs(s1, s2)
  else
  if SortColumn = 2 then
  begin
    CompResult := StrToIntDef('$' + Copy(s1, 1, 1), 0) - StrToIntDef('$' + Copy(s2, 1, 1), 0);
    if CompResult = 0 then
      CompResult := StrToIntDef('$' + Copy(s1, 2, 7), 0) - StrToIntDef('$' + Copy(s2, 2, 7), 0);
  end;
  if (CompResult = 0) and (KeepModuleTogether or (SortColumn <> -1)) then
    CompResult := AnsiCompareStr(Item1.Caption, Item2.Caption);
end;

procedure TVCSSync.CheckAllListViewItems(AListView: TdfsEnhListView; ANewState: Integer);
var
  I: Integer;
begin
  if Assigned(AListView) then
    with AListView do
      for I := 0 to (Items.Count - 1) do
        Items[I].StateIndex := ANewState;
end;

procedure TVCSSync.tv_Project_List_CheckAll(Value: Boolean);
var
  I: Integer;
begin
  for I := 0 to tv_Project_List.Items.Count - 1 do
  begin
    tv_Project_List.Checked[tv_Project_List.Items[I]] := Value;
  end;
  if (not Value) and (tv_Project_List.Items.Count > 0) then
    tv_Project_List.Checked[tv_Project_List.Items[0]] := True;
end;

procedure TVCSSync.CheckAll1Click(Sender: TObject);
begin
  tv_Project_List_CheckAll(True);
end;

procedure TVCSSync.UncheckAll1Click(Sender: TObject);
begin
  tv_Project_List_CheckAll(False);
end;

procedure TVCSSync.FullExpand1Click(Sender: TObject);
begin
  tv_Project_List.FullExpand;
end;

procedure TVCSSync.FullCollapce1Click(Sender: TObject);
begin
  tv_Project_List.FullCollapse;
  if tv_Project_List.Items.Count > 0 then
  begin
    tv_Project_List.Items[0].Expand(False);
    tv_Project_List.Items[0].Selected:= True;
    tv_Project_List.Items[0].MakeVisible;
  end;
end;

procedure TVCSSync.tv_Project_List_CheckBranch(Node: TTreeNode; Value: Boolean);
var
  I: Integer;
begin
  tv_Project_List.Checked[Node] := Value;
  for I:= 0 to Node.Count - 1 do
    tv_Project_List_CheckBranch(Node.Item[I], Value);
end;

procedure TVCSSync.CheckBranch1Click(Sender: TObject);
begin
  if Assigned(tv_Project_List.Selected) then
    tv_Project_List_CheckBranch(tv_Project_List.Selected, True);
end;

procedure TVCSSync.UncheckBranch1Click(Sender: TObject);
begin
  if Assigned(tv_Project_List.Selected) then
    tv_Project_List_CheckBranch(tv_Project_List.Selected, False);
end;

procedure TVCSSync.btnSearchFilesClick(Sender: TObject);
begin
  Reload_Project_Contents(PageControl1.ActivePageIndex);
end;

procedure TVCSSync.SetTransState(Status: TTransState);
begin
  case Status of
    tsDisabled: TransLED1.ColorOn := clGray;
    tsGo: TransLED1.ColorOn := clLime;
    tsWait: TransLED1.ColorOn := clYellow;
    tsStop: TransLED1.ColorOn := clRed;
  end;
end;

procedure TVCSSync.StatusBarPanels1DrawPanel(StatusBar: TdfsStatusBar;
  Panel: TdfsStatusPanel; const Rect: TRect);
begin
  TransLED1.Top := 1;
  TransLED1.Left := Rect.Left;
end;

procedure TVCSSync.Clear_ProjectTree;
var
  I: Integer;
begin
  for I := 0 to tv_Project_List.Items.Count - 1 do
  begin
    if Assigned(tv_Project_List.Items[I].Data) then
      TProject_Desc(tv_Project_List.Items[I].Data).Free;
    tv_Project_List.Items[I].Data := nil;
  end;
end;

procedure TVCSSync.SetProject_Tree_Loaded(const Value: Boolean);
begin
  FProject_Tree_Loaded:= Value;
  if Value then
    sbLoadProjectTree.Enabled:= False;
end;

procedure TVCSSync.sbLoadProjectTreeClick(Sender: TObject);
begin
  Clear_ProjectTree;
  Fill_ProjectTree(RootProjectID, True);
end;

procedure TVCSSync.cbROFlagClick(Sender: TObject);
begin
  btnVerify.Enabled := True;
end;

end.
