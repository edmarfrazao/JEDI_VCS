(* -----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: Options.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS:
  Thomas Huber (Thomas_D_Huber@gmx.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
ToDo
- replace "Server name/address" in MRU Lists with "Identities"
  Identities can't be handled by TJVCSMruList -> different handling necessary
- use constant for standalone application server filename?
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FreeVCS code to JEDI VCS
2003/02/12  USchuster - changed DSAMsg with JVCSDialogs in uses clause to use JvDSADialogs
2003/02/18  MGosselink- Added "CheckModuleState" on menu pull-down
                        The "Check In/Put" and "Check Out" menu items will be
                        enabled/disabled according to the module checkout state.
                      - Changed the IDE menu accelerator from "FreeVCS" to "Jedi-VCS"
2003/03/02  THensle   - changes for "ConfigStorage" unit
2003/03/10  USchuster - exchanged THistoryList with TJVCSMruList (mantis #727)
                      - changed spEraseDays.ButtonKind = bkStandard
2003/03/11  THuber    - removed nonexisting testform, btnStrList, btnTestForm
                        which should now better implemented used in JediVCSTest project
2003/08/31  USchuster - changed JEDI-VCS to JEDI VCS in unit header,
                        message boxes and in form
                      - changed Keyword stuff
                      - changes on IDE menu accelerator
2004/02/24  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/04/14  USchuster - changed IDE component list filename (label caption) from
                        'components.fvc' to 'CompList.jvcs'
                      - use constant for messagebox caption
2004/06/13  USchuster - changed standalone application server filename from
                        'fvcsappsrv.exe' to 'jvcssrv.exe'
                      - minor style cleaning (casing and comments)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/26  USchuster - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
                      - bugfix for empty blowfish password edits
2004/11/02  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC1 was released ^^^^^^^^^^^^^^^^^^^^^^^^^^^ 
2005/01/06  THuber    #2481 IDE files filter were stored to wrong location
2005/01/09  THuber    - form now resizable
   to                 - removed IDE base path setting from registry; now
2005/02/27              dynamicaly loaded...
                      - Use JVCSDialogs in most cases instead of MessageBox
                      - #10#13/#13#10 now AnsiCrLf
2005/02/27  USchuster - enabled most parts of the shortcut selection for the
                        standalone version too (mantis #1956)
2005/03/01  Victorious- {$IFDEF DEBUG} 
2005/04/10  CSchuette - fixed ShowDebugMsg initialization error, not checkbox can be used. 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC2 was released ^^^^^^^^^^^^^^^^^^^^^^^^^^^
2005/05/22  USchuster - added comment history list to MRU lists (mantis #2713)
2005/06/04  USchuster - set label charset to DEFAULT_CHARSET(necessary for LANGUAGE version)
2005/06/30  CSchuette - added option "check in comment required"
                      - changed caption of options if empty Check In/Check Out comments must
                        confirmed to make clear what they mean
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC3 was released ^^^^^^^^^^^^^^^^^^^^^^^^^^^
2006/01/01  USchuster - changes for more flexible shortcuts (mantis #3397)
2007/06/25  USchuster - changes for large fonts (set AutoScroll to False)
2007/06/29  USchuster - changes for large fonts (contraints depend now on PixelsPerInch; Mantis #3710) 
2007/07/08  USchuster - fixed partly broken backup options "BackupProject" and "BackupActive" (Mantis #4075)
2007/09/12  USchuster - "Check In comment required" combobox depends now on "Confirm empty Check In comment" (Mantis #4227)
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2009/12/28  THuber    - added JVCSClientConsts to uses (as some consts were moved from VCSBase there)
2010/01/24  THuber    - Directive B L O W F I S H removed as we use Blowfish-encryption always
2011/01/15  USchuster - changed font to Tahoma
2012/07/08  AKroeber  - changed AnsiCrLf to sLineBreak (avoid using of JclAnsiString.pas - should work from Delphi 6 to XE2)
2012/07/08  AKroeber  - settings for external bugtracker
2012/09/02  AKroeber  - settings for SaveWIP

-----------------------------------------------------------------------------*)

unit Options;

{$I jedi.inc}
{$I compopt.inc}

{$IFDEF DELPHI6_UP}
  {$WARN UNIT_PLATFORM OFF}
  {$WARN SYMBOL_PLATFORM OFF}
{$ENDIF DELPHI6_UP}

interface

uses
  Windows, Messages, Forms, SysUtils, JvComponent, JvSearchFiles, Dialogs,
  ImgList, Controls, Menus, StdCtrls, ExtCtrls, JvExStdCtrls, JvEdit, Graphics,
  JvTextListBox, JvExControls, JvxSlider, JvCombobox, JvColorCombo, ComCtrls,
  JvToolEdit, Mask, JvExMask, JvSpin, Buttons, Classes, JvComponentBase, JVCSForms;

const
  WM_DLGSTARTUP = WM_APP + 100;   // startup message

type
  TVCSOptions = class(TJVCSForm)
    PopupMenu2: TPopupMenu;
    pmiFilterEdit: TMenuItem;
    StateImageList: TImageList;
    TypeImageList: TImageList;
    PanelOptions: TPanel;
    PanelFolders: TPanel;
    PanelDialogs: TPanel;
    PanelTimeStamp: TPanel;
    PanelBackup: TPanel;
    PanelEditors: TPanel;
    PanelFilter: TPanel;
    PanelNotify: TPanel;
    PanelShortcut: TPanel;
    lbSelectSheet: TListBox;
    Label14: TLabel;
    PanelInterface: TPanel;
    cbDoBeep: TCheckBox;
    cbShowToolTip: TCheckBox;
    PanelMRU: TPanel;
    cbAddDSK: TCheckBox;
    cbAddCFG: TCheckBox;
    cbAddCList: TCheckBox;
    cbAutoSync: TCheckBox;
    cbAutoRefresh: TCheckBox;
    cbShowLoad: TCheckBox;
    speAutoRefresh: TJvSpinEdit;
    min: TLabel;
    cbxPMDoubleClick: TComboBox;
    Label19: TLabel;
    edMailSlot: TEdit;
    cbMessChkIn: TCheckBox;
    cbMessChkOut: TCheckBox;
    cbMessDisConnect: TCheckBox;
    cbMessConnect: TCheckBox;
    cbNotifyActive: TCheckBox;
    btnEditFilter: TButton;
    btnRestFilt: TButton;
    lvFilters: TListView;
    lvDSADlg: TListView;
    btnHideDSA: TButton;
    btnShowDSA: TButton;
    cbDoBckUp: TCheckBox;
    cbBckupProj: TCheckBox;
    cbShProgr: TCheckBox;
    Label35: TLabel;
    edBckupPath: TEdit;
    spbtnBckUpPath: TSpeedButton;
    Label3: TLabel;
    rbBkupLevel9: TRadioButton;
    rbBkupLevel5: TRadioButton;
    rbBkupLevel2: TRadioButton;
    Label10: TLabel;
    edBMP: TJvFilenameEdit;
    edTxt: TJvFilenameEdit;
    edUserEdit: TJvFilenameEdit;
    Label13: TLabel;
    Label12: TLabel;
    Label11: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label20: TLabel;
    edLocalServer: TEdit;
    spBtnLocalServer: TSpeedButton;
    edBaseRegKey: TEdit;
    edTempDir: TEdit;
    spBtnTempDir: TSpeedButton;
    PanelExtCompare: TPanel;
    Label22: TLabel;
    Label15: TLabel;
    Label23: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    cbxChkInDate: TComboBox;
    cbxChkOutDate: TComboBox;
    Label33: TLabel;
    Label21: TLabel;
    lblAccel: TLabel;
    Label25: TLabel;
    edSCProjAdmin: THotKey;
    edSCGet: THotKey;
    Label7: TLabel;
    Label26: TLabel;
    edSCChkIn: THotKey;
    edSCChkOut: THotKey;
    Label27: TLabel;
    Label32: TLabel;
    edSCBckUp: THotKey;
    Label34: TLabel;
    speSearchTime: TJvSpinEdit;
    Label36: TLabel;
    Label37: TLabel;
    cbBeep: TCheckBox;
    Label38: TLabel;
    cbOnlyCurrent: TCheckBox;
    cbNtfyFOConnect: TCheckBox;
    cbNtfyFOCheckOut: TCheckBox;
    cbNtfyFOCheckIn: TCheckBox;
    cbDisableGraphDC: TCheckBox;
    Label9: TLabel;
    Label40: TLabel;
    PopupMenuServerInst: TPopupMenu;
    ServerInstBrowse: TMenuItem;
    ServerInstFind: TMenuItem;
    N2: TMenuItem;
    NtfyColorCombo: TJvColorComboBox;
    cbUseOnlyShellExt: TCheckBox;
    PanelIntPrinter: TPanel;
    cbPrintHeader: TCheckBox;
    Label41: TLabel;
    Label42: TLabel;
    spePrintTM: TJvSpinEdit;
    spePrintLM: TJvSpinEdit;
    paPrinterfont: TPanel;
    Label43: TLabel;
    spBtSelectPrnFont: TSpeedButton;
    Label44: TLabel;
    Label45: TLabel;
    Label46: TLabel;
    FontDialog1: TFontDialog;
    speFDlgMRUMax: TJvSpinEdit;
    Label51: TLabel;
    cbxMRUList: TComboBox;
    Label52: TLabel;
    btnClrMRUItem: TButton;
    btnClrMRUAll: TButton;
    Label47: TLabel;
    lbMRUList: TJvTextListBox;
    ccbxLVOut: TJvColorComboBox;
    ccbxLVNA: TJvColorComboBox;
    Label48: TLabel;
    Label49: TLabel;
    cbShowLVColor: TCheckBox;
    ccbxLVNew: TJvColorComboBox;
    Label1: TLabel;
    PanelKWExpansion: TPanel;
    cbKWExpCheckIn: TCheckBox;
    Label39: TLabel;
    cbKWExpCheckOut: TCheckBox;
    edKWExp: TEdit;
    Label53: TLabel;
    cbKWExpAdd: TCheckBox;
    cbKWCreateBackup: TCheckBox;
    spBtnInsCT: TSpeedButton;
    Label54: TLabel;
    cbKWExCheckBinary: TCheckBox;
    cbUnlockUnchanged: TCheckBox;
    spBtnEditKWExp: TSpeedButton;
    Label50: TLabel;
    rbPFSingle: TRadioButton;
    rbPFExplorer: TRadioButton;
    cbKWIgnorewoSKW: TCheckBox;
    Label56: TLabel;
    AddCustomFileFilter1: TMenuItem;
    RemoveCustomFileFilter1: TMenuItem;
    Restore1: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    btnAddCustFilter: TButton;
    Renamecustomfilefilter1: TMenuItem;
    IncPosition1: TMenuItem;
    DecrementPosition1: TMenuItem;
    N5: TMenuItem;
    lvCompareTools: TListView;
    btnCTEdit: TButton;
    btnCTAdd: TButton;
    btnCTRmv: TButton;
    spEraseDays: TJvSpinEdit;
    lOlderthan: TLabel;
    cbSeqBackup: TCheckBox;
    cbEraseSeq: TCheckBox;
    PanelEncryption: TPanel;
    cbEncryptData: TCheckBox;
    Label2: TLabel;
    Label6: TLabel;
    Label57: TLabel;
    Image1: TImage;
    Label58: TLabel;
    Label59: TLabel;
    Label60: TLabel;
    btnShowBackups: TButton;
    pwedBFKey: TJvEdit;
    pwedBFKeyConfirm: TJvEdit;
    Image2: TImage;
    Image4: TImage;
    PanelDebug: TPanel;
    cbOutPutDbgStr: TCheckBox;
    Bevel1: TBevel;
    speSrvTimeOut: TJvSpinEdit;
    Label62: TLabel;
    Label63: TLabel;
    edCleanUpVal: TEdit;
    Label64: TLabel;
    cbGEX: TCheckBox;
    CheckBox1: TCheckBox;
    Label65: TLabel;
    Edit1: TEdit;
    cbSMTP: TCheckBox;
    cbSend8and3: TCheckBox;
    cbLocalInfo: TCheckBox;
    cbTypeInfo: TCheckBox;
    Label24: TLabel;
    edSCSync: THotKey;
    cbNoROCheck: TCheckBox;
    PanelComments: TPanel;
    cbpromptfMemo: TCheckBox;
    cbMemoRequired: TCheckBox;
    cbpromptfMemoOut: TCheckBox;
    cbCommInOut: TCheckBox;
    cbIncludeIPComment: TCheckBox;
    cbMarkSource: TCheckBox;
    cbMSIn: TCheckBox;
    cbMSOut: TCheckBox;
    cbBreakCIITo80: TCheckBox;
    Label55: TLabel;
    Image3: TImage;
    cbIgnoreBinary_Text: TCheckBox;
    JvxAccel: TJvxSlider;
    JvSearchFiles: TJvSearchFiles;
    cbCheckModuleState: TCheckBox;
    cbUseFileStorage: TCheckBox;
    pnlBottom: TPanel;
    btnOK: TButton;
    btnApply: TButton;
    btnCancel: TButton;
    Help: TSpeedButton;
    edRWS: TJvFilenameEdit;
    PanelExtBugTrack: TPanel;
    edBugtrackerURL: TEdit;
    edBugtrackerRegEx: TEdit;
    Label16: TLabel;
    Label8: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    PanelSaveWIP: TPanel;
    Label31: TLabel;
    Label61: TLabel;
    edSaveWIPcommand: TEdit;
    Label30: TLabel;
    Label66: TLabel;
    cbSaveWIPauto: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure HelpTopic1Click(Sender: TObject);
    procedure spbtnBckUpPathClick(Sender: TObject);
    procedure btnResetDSAMClick(Sender: TObject);
    procedure cbShowLoadClick(Sender: TObject);
    procedure cbMarkSourceClick(Sender: TObject);
    procedure cbNotifyActiveClick(Sender: TObject);
    procedure pmiFilterEditClick(Sender: TObject);
    procedure lvFiltersDblClick(Sender: TObject);
    procedure edArchLimitChange(Sender: TObject);
    procedure cbDoBckUpClick(Sender: TObject);
    procedure btnSetAllDSAClick(Sender: TObject);
    procedure lvDSADlgMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnRestDefaultFiltClick(Sender: TObject);
    procedure cbAutoRefreshClick(Sender: TObject);
    procedure spBtnTempDirClick(Sender: TObject);
    procedure spBtnLocalServerClick(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure lvDSADlgKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lbSelectSheetClick(Sender: TObject);
    procedure ServerInstBrowseClick(Sender: TObject);
    procedure ServerInstFindClick(Sender: TObject);
    procedure cbUseOnlyShellExtClick(Sender: TObject);
    procedure spBtSelectPrnFontClick(Sender: TObject);
    procedure cbxMRUListChange(Sender: TObject);
    procedure btnClrMRUItemClick(Sender: TObject);
    procedure btnClrMRUAllClick(Sender: TObject);
    procedure lbMRUListClick(Sender: TObject);
    procedure cbShowLVColorClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure spBtnInsCTClick(Sender: TObject);
    procedure spBtnEditKWExpClick(Sender: TObject);
    procedure AddCustomFileFilter1Click(Sender: TObject);
    procedure RemoveCustomFileFilter1Click(Sender: TObject);
    procedure lvFiltersChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure lvFiltersEditing(Sender: TObject; Item: TListItem;
      var AllowEdit: Boolean);
    procedure Renamecustomfilefilter1Click(Sender: TObject);
    procedure IncPosition1Click(Sender: TObject);
    procedure DecrementPosition1Click(Sender: TObject);
    procedure btnCTEditClick(Sender: TObject);
    procedure btnCTAddClick(Sender: TObject);
    procedure btnCTRmvClick(Sender: TObject);
    procedure lvCompareToolsEditing(Sender: TObject; Item: TListItem;
      var AllowEdit: Boolean);
    procedure lvCompareToolsChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure cbSeqBackupClick(Sender: TObject);
    procedure btnShowBackupsClick(Sender: TObject);
    procedure cbSMTPClick(Sender: TObject);
    procedure cbxChkInDateChange(Sender: TObject);
    procedure cbKWExpAddClick(Sender: TObject);
    procedure cbKWExpCheckInClick(Sender: TObject);
    procedure cbKWExpCheckOutClick(Sender: TObject);
    procedure cbAutoSyncClick(Sender: TObject);
    procedure cbEncryptDataClick(Sender: TObject);
    procedure cbxChkOutDateChange(Sender: TObject);
    procedure cbUnlockUnchangedClick(Sender: TObject);
    procedure cbIncludeIPCommentClick(Sender: TObject);
    procedure cbNoROCheckClick(Sender: TObject);
    procedure JvxAccelChange(Sender: TObject);
    procedure JvSearchFilesFindFile(Sender: TObject; const AName: string);
    procedure cbCheckModuleStateClick(Sender: TObject);
    procedure cbUseFileStorageClick(Sender: TObject);
    procedure edRWSButtonClick(Sender: TObject);
    procedure edBMPButtonClick(Sender: TObject);
    procedure edTxtButtonClick(Sender: TObject);
    procedure edUserEditButtonClick(Sender: TObject);
    procedure cbpromptfMemoClick(Sender: TObject);
  private
    { Private-Deklarationen }
    FCreating: Boolean;
    NtfyFilterValue,
    iZipBkUpLevel: Integer;
    FindType: Byte;
    NtfyTCIdent,
    sftDelphi,
    sftAddin,
    sftCompare,
    {$IFDEF IDEDLL}
    sftIDE,
    {$ENDIF IDEDLL}
    sftImage,
    sftResource,
    sftText,
    sftWriteable,
    sftExclude,
    sftUser,
    sftNeverSync,
    ProjectRegistryKey: string;
    procedure WMDLGStartup(var msg: TMessage); message WM_DLGSTARTUP;
    function CheckValues: Boolean;
    procedure GetValues;
    procedure SetDSAMSettings;
    procedure DoContextHelp;
    function GetMRUListIndex: string;
    procedure CheckGlobalcbOption(cb: TCheckBox; Nr: Integer);
    procedure UpgradeRegistryKeys;
  public
    { Public-Deklarationen }
    DefaultSheet: Integer;
  end;

var
  VCSOptions: TVCSOptions;

implementation

uses
    VCSBase
  , BFCrypt
  {$IFDEF LANGUAGE}
  , JvGnugettext
  {$ENDIF LANGUAGE}
  , JVCSClientConsts
  , ShellAPI
  , FileCtrl
  , VCSProcBase
  , SelectFolder
  , SelectDrive
  , JVCSMruList
  , CommCtrl
  , ListEdit
  , FavOpenDialog
  , AddNewCompareTool
  , Std_ListView
  , ConfigStorage
  , Registry
  , JVCSGUIClientResources
  , JclStrings
  {$IFDEF DEBUG}
  , JVCSDebug
  {$ENDIF DEBUG}
  , JVCSDialogs
  ;

{$R *.dfm}

procedure TVCSOptions.UpgradeRegistryKeys;
begin
  //vvv 2.40 RC2
  //remove IDE installationpath, see jedivcsdll.dpr how it's handled now!
  jvcsDeleteValue(sBaseRegistryKey + crbOptions, 'InstBaseDir');
end;

procedure TVCSOptions.FormCreate(Sender: TObject);
var
  ToolTipHandle: HWND;
begin
  try
    Constraints.MinHeight := MulDiv(325, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(430, PixelsPerInch, 96);
    Screen.Cursor := crHourGlass;
    FCreating := True;
    // ListView Tooltips
    SendMessage(lvFilters.Handle, LVM_SETEXTENDEDLISTVIEWSTYLE, LVS_EX_INFOTIP,
      LVS_EX_INFOTIP);
    ToolTipHandle := SendMessage(lvFilters.Handle, LVM_GETTOOLTIPS, 0, 0);
    SendMessage(ToolTipHandle, TTM_SETDELAYTIME, TTDT_AUTOMATIC, 1);
    SendMessage(ToolTipHandle, TTM_SETDELAYTIME, TTDT_AUTOPOP, 3000);

    SendMessage(lvCompareTools.Handle, LVM_SETEXTENDEDLISTVIEWSTYLE, LVS_EX_INFOTIP,
      LVS_EX_INFOTIP);
    ToolTipHandle := SendMessage(lvCompareTools.Handle, LVM_GETTOOLTIPS, 0, 0);
    SendMessage(ToolTipHandle, TTM_SETDELAYTIME, TTDT_AUTOMATIC, 1);
    SendMessage(ToolTipHandle, TTM_SETDELAYTIME, TTDT_AUTOPOP, 3000);

    DefaultSheet := cspInterface;

    jvcsLoadFormPosSize(Self);

    // Basis = ccbxLVNew
    ccbxLVOut.Items.Assign(ccbxLVNew.Items);
    ccbxLVNA.Items.Assign(ccbxLVNew.Items);
    NtfyColorCombo.Items.Assign(ccbxLVNew.Items);

    Screen.Cursors[cPopUpMCursor] := LoadCursor(hInstance, PChar('CURSORRM'));
    lvFilters.Cursor := cPopUpMCursor;

    //Migrate Remove/Change Registrykey's
    UpgradeRegistryKeys;

  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.FormShow(Sender: TObject);
begin
  Update;
  if FCreating then
  begin
    lbSelectSheet.ItemIndex := DefaultSheet;
    lbSelectSheetClick(Self);
    lbSelectSheet.Update;

    PostMessage(Handle, WM_DLGSTARTUP, 0, 0);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.WMDLGStartup(var msg: TMessage);
var
  LVItem: TListItem;
  S,
  CurrentFilter,
  DSARootKey,
  TMPDirectory: string;
  I: Integer;
  NtfyColor: TColor;
begin
  Screen.Cursor := crHourGlass;
  try
    cbUseFileStorage.Checked := not UseRegistryStorage;

    ShowHint :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);
    speFDlgMRUMax.Value :=
      jvcsReadInteger(sBaseRegistryKey + crbMRU, 'FileDlgMRU', 10);

    cbShowLVColor.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbWindows, 'ProjMan_ShowListColors', True);
    ccbxLVOut.Enabled := cbShowLVColor.Checked;
    ccbxLVNA.Enabled := cbShowLVColor.Checked;
    ccbxLVNew.Enabled := cbShowLVColor.Checked;
    Label48.Enabled := cbShowLVColor.Checked;
    Label49.Enabled := cbShowLVColor.Checked;
    Label1.Enabled := cbShowLVColor.Checked;

    {$IFNDEF IDEDLL}
    cbShowLoad.Enabled := False;
    cbAddCList.Enabled := False;
    cbAddCFG.Enabled := False;
    cbAddDSK.Enabled := False;
    cbMarkSource.Enabled := False;
    JvxAccel.Enabled := False;
    lblAccel.Enabled := False;
    Label21.Enabled := False;
    Label25.Enabled := False;
    Label9.Enabled := False;
    Label55.Enabled := False;
    edSCProjAdmin.Enabled := False;
    spBtnInsCT.Enabled := False;
    Label54.Enabled := False;
    cbGEX.Enabled := False;
    cbCheckModuleState.Enabled := False;
    {$ELSE}
    //THe: for now, Baseregkey cannot be changed. Unsure if this is useful at all
    {edBaseRegKey.Enabled := False;
    edBaseRegKey.Text := sBaseRegistryKey;}
    {$ENDIF ~IDEDLL}
    edBaseRegKey.Enabled := False;
    edBaseRegKey.Text := sBaseRegistryKey;
     //--------------------------------------------------------------------
    cbOutPutDbgStr.Enabled := jvcsReadBool(sBaseRegistryKey,
      'DebugOptions', False);
    Label64.Enabled := cbOutPutDbgStr.Enabled;
    edCleanUpVal.Enabled := cbOutPutDbgStr.Enabled;
    //--------------------------------------------------------------------
    if cbOutPutDbgStr.Enabled then
      cbOutPutDbgStr.Checked := jvcsReadBool(sBaseRegistryKey + crbOptions,
        'OutputDebugStrActive', False)
    else
      cbOutPutDbgStr.Checked := False;
    ShowDebugMsg := cbOutPutDbgStr.Checked;

    edCleanUpVal.Text := IntToStr(jvcsReadInteger(sBaseRegistryKey +
      crbOptions, 'CleanUpDelayValue', 2000));
    //--------------------------------------------------------------------
    {$IFDEF IDEDLL}
    cbShowLoad.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowLoad', False);
    cbAddCList.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'AddComponentList', False);
    cbAddCFG.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'AddCFGFiles', False);
    cbAddDSK.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'AddDSKFiles', False);
    cbMarkSource.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'MarkSource', False);
    cbMSIn.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'MarkSource_I', False);
    cbMSOut.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'MarkSource_O', False);
    cbBreakCIITo80.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'MarkSource_Break', True);
    iMenAccel :=
      jvcsReadInteger(sBaseRegistryKey + crbOptions, 'FVCSAccel', 5);
    edSCProjAdmin.HotKey :=
      jvcsReadInteger(sBaseRegistryKey + crbOptions, 'ShortCutProjAdmin', cDefaultSCProjAdmin);
    cbCheckModuleState.Checked  :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'CheckModuleState', False);
    {$ENDIF IDEDLL}
    edSCGet.HotKey :=
      jvcsReadInteger(sBaseRegistryKey + crbOptions, 'ShortCutGet', cDefaultSCGet);
    edSCChkIn.HotKey :=
      jvcsReadInteger(sBaseRegistryKey + crbOptions, 'ShortCutChkIn', cDefaultSCChkIn);
    edSCChkOut.HotKey :=
      jvcsReadInteger(sBaseRegistryKey + crbOptions, 'ShortCutChkOut', cDefaultSCChkOut);
    edSCSync.HotKey :=
      jvcsReadInteger(sBaseRegistryKey + crbOptions, 'ShortCutSync', cDefaultSCSync);
    edSCBckUp.HotKey :=
      jvcsReadInteger(sBaseRegistryKey + crbOptions, 'ShortCutBckUp', cDefaultSCBckUp);
    cbIncludeIPComment.Checked  :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'IncludeIPComment', False);
    edLocalServer.Text :=
      jvcsReadString(sBaseRegistryKey + crbOptions, 'LocalServer', '');
    cbpromptfMemo.Checked  :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'PromptFMemo', True);
    cbMemoRequired.Checked  :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'MemoRequired', False);
    cbpromptfMemoOut.Checked  :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'PromptFMemo2', True);
    cbCommInOut.Checked  :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'LastOutDescr', False);
    cbDoBeep.Checked  :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'DoBeep', True);
    cbLocalInfo.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowLocalInfo', True);
    cbTypeInfo.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowTypeInfo', True);
    cbShowToolTip.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);
    iZipBkUpLevel :=
      jvcsReadInteger(sBaseRegistryKey + crbOptions, 'BackupZipLevel', 9);
    cbSeqBackup.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'BackupSequentiel', False);
    cbEraseSeq.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'BackupEraseSequentiel', False);
    spEraseDays.Value :=
      jvcsReadInteger(sBaseRegistryKey + crbOptions, 'BackupEraseAfterDays', 30);
    edRWS.Text :=
      jvcsReadString(sBaseRegistryKey + crbOptions, 'ResourceEditor', '');
    edBMP.Text :=
      jvcsReadString(sBaseRegistryKey + crbOptions, 'ImageEditor', '');
    edTxt.Text :=
      jvcsReadString(sBaseRegistryKey + crbOptions, 'TextEditor', '');
    edUserEdit.Text :=
      jvcsReadString(sBaseRegistryKey + crbOptions, 'UserDefinedEditor', '');
    cbBckupProj.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'BackupProject', True);
    cbDoBckUp.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'BackupActive', False);
    edBckupPath.Text :=
      jvcsReadString(sBaseRegistryKey + crbOptions, 'BackupPath', '');
    cbShProgr.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'BackupShowProgress', True);
    cbNotifyActive.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'NotifyActive', False);
    cbMessConnect.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'MessConnect', True);
    cbMessDisConnect.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'MessDisConnect', True);
    cbMessChkOut.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'MessChkOut', True);
    cbMessChkIn.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'MessChkIn', True);
    edTempDir.Text :=
      jvcsReadString(sBaseRegistryKey + crbOptions, 'TempDirectory', '');
    if edTempDir.Text = '' then
    begin
      I := 255;
      SetLength(TMPDirectory, I);
      I := GetTempPath(I, PChar(TMPDirectory));
      if I > 0 then
      begin
        SetLength(TMPDirectory, StrLen(PChar(TMPDirectory)));
        edTempDir.Text := TMPDirectory;
      end
      else
        edTempDir.Text := '';
    end;
    cbAutoSync.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'AutoSync', False);
    speAutoRefresh.Value :=
      (jvcsReadInteger(sBaseRegistryKey + crbOptions, 'RefreshTimer', 600000)) div 60000;
    cbAutoRefresh.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'RefreshTimerEnabled', False);
    speAutoRefresh.Enabled := cbAutoRefresh.Checked;
    cbxPMDoubleClick.ItemIndex :=
      jvcsReadInteger(sBaseRegistryKey + crbOptions, 'PMDoubleClick', 0);
    cbxChkInDate.ItemIndex :=
      jvcsReadInteger(sBaseRegistryKey + crbOptions, 'ChkInDate', 0);
    cbxChkOutDate.ItemIndex :=
      jvcsReadInteger(sBaseRegistryKey + crbOptions, 'ChkOutDate', 0);
    speSearchTime.Value :=
      jvcsReadInteger(sBaseRegistryKey + crbOptions, 'SearchTime', 750);
    cbDisableGraphDC.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'DisableCtrl', False);
    cbUseOnlyShellExt.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'UseOnlyShellExt', True);
    ccbxLVNew.ColorValue :=
      jvcsReadInteger(sBaseRegistryKey + crbOptions, 'ModuleListColor_New', clWindowText);
    ccbxLVOut.ColorValue :=
      jvcsReadInteger(sBaseRegistryKey + crbOptions, 'ModuleListColor_Owner', clMaroon);
    ccbxLVNA.ColorValue :=
      jvcsReadInteger(sBaseRegistryKey + crbOptions, 'ModuleListColor_Locked', clGray);
    cbKWExpAdd.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'KWExpAdd', False);
    cbKWCreateBackup.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'KWExpBackup', False);
    cbKWExCheckBinary.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'KWExpCheckBinary', True);
    cbKWExpCheckIn.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'KWExpCheckIn', False);
    cbKWExpCheckOut.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'KeywordExp_CheckOut', False);
    cbKWIgnorewoSKW.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'KWIgnorewoSKW', False);
    edKWExp.Text :=
      jvcsReadString(sBaseRegistryKey + crbOptions, 'KWExpFiles', dfKWExp);
    cbUnlockUnchanged.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'UnlockUnchangedFiles', True);
    rbPFExplorer.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'ParentAsExplorer', False);
    rbPFSingle.Checked := not rbPFExplorer.Checked;
    cbEncryptData.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'EncryptModuleData', False);
    S := jvcsReadString(sBaseRegistryKey + crbOptions, 'EncodeKey', '');
    if S <> '' then
    begin
      pwedBFKey.Text := Base64Decode(S);
      pwedBFKeyConfirm.Text := pwedBFKey.Text;
    end
    else
    begin
      pwedBFKey.Clear;
      pwedBFKeyConfirm.Clear;
    end;
    SrvTimeOutVal :=
      jvcsReadInteger(sBaseRegistryKey + crbOptions, 'SrvTimeOut', 120000);
    speSrvTimeOut.Value := SrvTimeOutVal div 1000;
    cbGEX.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'GEXPresent', True);
    cbNoROCheck.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'NoROCheck', False);
    cbSMTP.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'SMTPMessages', False);
    cbSend8and3.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'UseShortFilenames', True);
    cbIgnoreBinary_Text.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'IgnoreBinary_Text', False);
    edBugtrackerURL.Text :=
      jvcsReadString(sBaseRegistryKey + crbOptions, 'BugtrackerURL', '');
    edBugtrackerRegEx.Text :=
      jvcsReadString(sBaseRegistryKey + crbOptions, 'BugtrackerRegEx', '');
    edSaveWIPcommand.Text :=
      jvcsReadString(sBaseRegistryKey + crbOptions, 'SaveWIPcommand', '');
    cbSaveWIPauto.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'SaveWIPauto', False);
    {$IFNDEF IDEDLL}
    {edBaseRegKey.Text :=
      jvcsReadString(cRegSwJVCSBase, 'BaseRegistryKey', cRegSwJVCSBase);}
    {$ENDIF ~IDEDLL}
    edBaseRegKey.Text :=
      jvcsReadString(cRegSwJVCSBase, 'BaseRegistryKey', cRegSwJVCSBase);
          
    NtfyFilterValue :=
      jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_NotifyFilter', 1);
    NtfyTCIdent :=
      jvcsReadString(sBaseRegistryKey + crbWindows, 'ProjMan_NotifyColor', 'clNavy');

    cbPrintHeader.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbPrinter, 'PrintHeader', True);
    spePrintTM.Value :=
      jvcsReadInteger(sBaseRegistryKey + crbPrinter, 'PrintTM', 0);
    spePrintLM.Value :=
      jvcsReadInteger(sBaseRegistryKey + crbPrinter, 'PrintLM', 0);
    paPrinterfont.Font.Size :=
      jvcsReadInteger(sBaseRegistryKey + crbPrinter, 'FontSize', 8);
    paPrinterfont.Font.Name :=
      jvcsReadString(sBaseRegistryKey + crbPrinter, 'FontName', 'Courier New');
    paPrinterfont.Caption :=
      paPrinterfont.Font.Name + ', ' + IntToStr(paPrinterfont.Font.Size);
    sftDelphi :=
      jvcsReadString(sBaseRegistryKey + crbFilters, 'Delphi files', dfDelphiMod);
    sftAddin :=
      jvcsReadString(sBaseRegistryKey + crbFilters, 'AddProjectFiles', dfAddMod);
    sftCompare :=
      jvcsReadString(sBaseRegistryKey + crbFilters, 'Compare files', dfCompMod);
    sftUser :=
      jvcsReadString(sBaseRegistryKey + crbFilters, 'User files', '');
    {$IFDEF IDEDLL}
    sftIDE :=
      jvcsReadString(sBaseRegistryKey + crbFilters, 'IDE files', dfIDEEdit);
    {$ENDIF IDEDLL}
    sftImage :=
      jvcsReadString(sBaseRegistryKey + crbFilters, 'Image files', dfBMPEdit);
    sftResource :=
      jvcsReadString(sBaseRegistryKey + crbFilters, 'Resource files', dfRWSEdit);
    sftText :=
      jvcsReadString(sBaseRegistryKey + crbFilters, 'Text files', dfTXTEdit);
    sftNeverSync :=
      jvcsReadString(sBaseRegistryKey + crbFilters, 'Never Sync files', '');
    sftWriteable :=
      jvcsReadString(sBaseRegistryKey + crbFilters, 'Writeable files', dfNotReadOnly);
    sftExclude :=
      jvcsReadString(sBaseRegistryKey + crbFilters, 'Exclude files', dfFolderExclude);

    cbMSIn.Enabled := cbMarkSource.Checked;
    cbMSOut.Enabled := cbMarkSource.Checked;
    cbBreakCIITo80.Enabled := cbMarkSource.Checked;

    case iZipBkUpLevel of
      9:
        rbBkupLevel9.Checked := True;
      5:
        rbBkupLevel5.Checked := True;
      2:
        rbBkupLevel2.Checked := True;
      else
        rbBkupLevel9.Checked := True;
    end;

    cbBeep.Checked := ((NtfyFilterValue and ntfyBeep) = ntfyBeep);
    cbOnlyCurrent.Checked := ((NtfyFilterValue and ntfyOnlyCurrent) = ntfyOnlyCurrent);
    cbNtfyFOConnect.Checked := ((NtfyFilterValue and ntfyConctA) = ntfyConctA);
    cbNtfyFOCheckOut.Checked := ((NtfyFilterValue and ntfyChckOut) = ntfyChckOut);
    cbNtfyFOCheckIn.Checked := ((NtfyFilterValue and ntfyChckIn) = ntfyChckIn);
    if not IdentToColor(NtfyTCIdent, Longint(NtfyColor)) then
      NtfyColor := 0;
    NtfyColorCombo.ColorValue := NtfyColor;

    cbMessConnect.Enabled := cbNotifyActive.Checked;
    cbMessDisConnect.Enabled := cbNotifyActive.Checked;
    cbMessChkOut.Enabled := cbNotifyActive.Checked;
    cbMessChkIn.Enabled := cbNotifyActive.Checked;
    cbMemoRequired.Enabled := cbpromptfMemo.Checked;

    cbUseOnlyShellExtClick(Self);
    JvxAccel.Value := iMenAccel;
    //USc necessary because when JvxAccel.Value = iMenAccel then
    //    JvxAccelChange won't be executed and lblAccel.Caption = 'J e d i - V C S 1 . x'
    //    or whatever is currently in the dfm
    JvxAccelChange(nil);

    with lvFilters do
    begin
      LVItem := Items.Add;
      LVItem.ImageIndex := 3;
      LVItem.Caption := Format(JVCSRES_37s_Modules, [sIDEName]);
      LVItem.SubItems.Add(sftDelphi);
      LVItem.SubItems.Add('0');

      LVItem := Items.Add;
      LVItem.ImageIndex := 3;
      LVItem.Caption := JVCSRES_Add46_Modules;
      LVItem.SubItems.Add(sftAddin);
      LVItem.SubItems.Add('0');

      LVItem := Items.Add;
      LVItem.ImageIndex := 5;
      LVItem.Caption := JVCSRES_Compare_Modules;
      LVItem.SubItems.Add(sftCompare);
      LVItem.SubItems.Add('0');

      {$IFDEF IDEDLL}
      LVItem := Items.Add;
      LVItem.ImageIndex := 3;
      LVItem.Caption := JVCSRES_IDE_Modules;
      LVItem.SubItems.Add(sftIDE);
      LVItem.SubItems.Add('0');
      {$ENDIF IDEDLL}

      LVItem := Items.Add;
      LVItem.ImageIndex := 5;
      LVItem.Caption := JVCSRES_Image_Files;
      LVItem.SubItems.Add(sftImage);
      LVItem.SubItems.Add('0');

      LVItem := Items.Add;
      LVItem.ImageIndex := 5;
      LVItem.Caption := JVCSRES_Resource_Files;
      LVItem.SubItems.Add(sftResource);
      LVItem.SubItems.Add('0');

      LVItem := Items.Add;
      LVItem.ImageIndex := 5;
      LVItem.Caption := JVCSRES_Text_Files;
      LVItem.SubItems.Add(sftText);
      LVItem.SubItems.Add('0');

      LVItem := Items.Add;
      LVItem.ImageIndex := 5;
      LVItem.Caption := JVCSRES_User_Editor_Files;
      LVItem.SubItems.Add(sftUser);
      LVItem.SubItems.Add('0');

      LVItem := Items.Add;
      LVItem.ImageIndex := 5;
      LVItem.Caption := JVCSRES_Never_Sync;
      LVItem.SubItems.Add(sftNeverSync);
      LVItem.SubItems.Add('0');

      LVItem := Items.Add;
      LVItem.ImageIndex := 5;
      LVItem.Caption := JVCSRES_Always_Writeable;
      LVItem.SubItems.Add(sftWriteable);
      LVItem.SubItems.Add('0');

      LVItem := Items.Add;
      LVItem.ImageIndex := 5;
      LVItem.Caption := JVCSRES_Exclude_files;
      LVItem.SubItems.Add(sftExclude);
      LVItem.SubItems.Add('0');

      I := 0;
      repeat
        Inc(I);
        CurrentFilter := jvcsReadString(sBaseRegistryKey + crbFilters + '\Custom',
          'Custom' + IntToStr(I), '');
        if (CurrentFilter <> '') then
        begin
          LVItem := Items.Add;
          LVItem.ImageIndex := 4;
          LVItem.Caption := Copy(CurrentFilter, 1, Pos('|', CurrentFilter) - 1);
          System.Delete(CurrentFilter, 1, Pos('|', CurrentFilter));
          LVItem.SubItems.Add(CurrentFilter);
          LVItem.SubItems.Add('1');
        end;
      until CurrentFilter = '';
    end; // with lvFilters do begin


    with lvCompareTools do
    begin
      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_JEDI_VCS_Diff;
      LVItem.SubItems.Add(LowerCase(sDLLDirectory) + cVCSDiffName);
      LVItem.SubItems.Add('/s:%1 /t:%2 /sc:%3 /tc:%4 /autostart');
      LVItem.SubItems.Add('0');

      I := 0;
      repeat
        Inc(I);
        CurrentFilter := jvcsReadString(sBaseRegistryKey + '\CompareTools',
          'Custom' + IntToStr(I), '');
        if (CurrentFilter <> '') then
        begin
          LVItem := Items.Add;
          LVItem.Caption := Copy(CurrentFilter, 1, Pos('|', CurrentFilter) - 1);
          System.Delete(CurrentFilter, 1, Pos('|', CurrentFilter));
          LVItem.SubItems.Add(Copy(CurrentFilter, 1, Pos('|', CurrentFilter) - 1));
          System.Delete(CurrentFilter, 1, Pos('|', CurrentFilter));
          LVItem.SubItems.Add(CurrentFilter);
          LVItem.SubItems.Add('1');
        end;
      until CurrentFilter = '';
    end; // with lvFilters do begin

    ProjectRegistryKey :=
      sBaseRegistryKey + crbProjects +
      AnsiLowerCase(ExtractFileName(sProjectName));

    cbxMRUList.ItemIndex := 0;
    cbxMRUListChange(Self);

    Application.ProcessMessages;
    btnApply.Enabled := False;
    DSARootKey := sBaseRegistryKey + crbMRU + 'Dlgs';
    with lvDSADlg do
    begin
      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_Time_zone_difference_warning46;
      LVItem.SubItems.Add('TZWarning');
      if DSAIdentsGetState(DSARootKey, 'TZWarning') then
        LVItem.StateIndex := 1
      else
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 2;

      {$IFDEF IDEDLL}
      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_No_project_opened_in_the_IDE46;
      LVItem.SubItems.Add('NoProjOpen');
      if DSAIdentsGetState(DSARootKey, 'NoProjOpen') then
        LVItem.StateIndex := 1
      else
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 0;
      {$ENDIF IDEDLL}

      {$IFDEF IDEDLL}
      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_Project_names_cannot_be_blank46;
      LVItem.SubItems.Add('PJNameBlank');
      if DSAIdentsGetState(DSARootKey, 'PJNameBlank') then
        LVItem.StateIndex := 1
      else
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 0;
      {$ENDIF IDEDLL}

      {$IFNDEF IDEDLL}
      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_Check_OS_for_valid_project_name46;
      LVItem.SubItems.Add('ChkPName');
      if DSAIdentsGetState(DSARootKey, 'ChkPName') then
        LVItem.StateIndex := 1
      else
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 1;
      {$ENDIF ~IDEDLL}

      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_Assign_new_Project_to_Group46;
      LVItem.SubItems.Add('PJCreated');
      if DSAIdentsGetState(DSARootKey, 'PJCreatedEx') then
        LVItem.StateIndex := 1
      else
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 1;

      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_Prompt_for_project_description;
      LVItem.SubItems.Add('SkipProjectDescr');
      if jvcsReadBool(sBaseRegistryKey + crbOptions, 'SkipProjectDescr', False)
      then
        LVItem.StateIndex := 0
      else
        LVItem.StateIndex := 1;

      LVItem.ImageIndex := 1;
      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_Project_related_access_level46;
      LVItem.SubItems.Add('PJRight');
      if DSAIdentsGetState(DSARootKey, 'PJRight') then
        LVItem.StateIndex := 1
      else
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 0;

      {$IFDEF IDEDLL}
      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_File_not_member_of_current_project46;
      LVItem.SubItems.Add('FNMComp');
      if DSAIdentsGetState(DSARootKey, 'FNMComp') then
        LVItem.StateIndex := 1
      else
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 0;
      {$ENDIF IDEDLL}

      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_Prompt_for_module_description;
      LVItem.SubItems.Add('SkipModuleDescr');

      if jvcsReadBool(sBaseRegistryKey + crbOptions, 'SkipModuleDescr', False)
      then
        LVItem.StateIndex := 0
      else
        LVItem.StateIndex := 1;
      LVItem.ImageIndex := 1;

      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_Check_In_45_skip_unchanged_files46;
      LVItem.SubItems.Add('SkipUnchanged');
      if DSAIdentsGetState(DSARootKey, 'SkipUnchanged') then
        LVItem.StateIndex := 1
      else
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 0;

      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_Check_In_success46;
      LVItem.SubItems.Add('ChkInSuc');
      if DSAIdentsGetState(DSARootKey, 'ChkInSuc') then
        LVItem.StateIndex := 1
      else
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 0;

      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_Check_Out_success46;
      LVItem.SubItems.Add('ChkOutSuc');
      if DSAIdentsGetState(DSARootKey, 'ChkOutSuc') then
        LVItem.StateIndex := 1
      else
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 0;

      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_Undo_Check_Out_success46;
      LVItem.SubItems.Add('UndoChkOutSuc');
      if DSAIdentsGetState(DSARootKey, 'UndoChkOutSuc') then
        LVItem.StateIndex := 1
      else
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 0;

      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_Shared_module_removed;
      LVItem.SubItems.Add('SharedRemove');
      if DSAIdentsGetState(DSARootKey, 'SharedRemove') then
        LVItem.StateIndex := 1
      else
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 0;

      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_Confirm_refresh_PM_view;
      LVItem.SubItems.Add('RefreshView');
      if DSAIdentsGetState(DSARootKey, 'RefreshView') then
        LVItem.StateIndex := 1
      else
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 1;

      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_Confirm_auto_Synchronize46;
      LVItem.SubItems.Add('AutoSync');
      if DSAIdentsGetState(DSARootKey, 'AutoSync') then
        LVItem.StateIndex := 1
      else
        LVItem.StateIndex := 0;

      LVItem.ImageIndex := 1;
      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_Compare_binary_files46;
      LVItem.SubItems.Add('CompTxtFilt');
      if DSAIdentsGetState(DSARootKey, 'CompTxtFilt') then
        LVItem.StateIndex := 1
      else
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 0;

      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_Confirm_remove_revision_label46;
      LVItem.SubItems.Add('RmvRevLabel');
      if DSAIdentsGetState(DSARootKey, 'RmvRevLabel') then
        LVItem.StateIndex := 1
      else 
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 1;

      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_Confirm_delete_45_View_latest_version46;
      LVItem.SubItems.Add('DeleteViewLatest');
      if DSAIdentsGetState(DSARootKey, 'DeleteViewLatest') then
        LVItem.StateIndex := 1
      else 
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 1;

      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_Confirm_remove_temporary_QR_files46;
      LVItem.SubItems.Add('DelQRPD');
      if DSAIdentsGetState(DSARootKey, 'DelQRPD') then 
        LVItem.StateIndex := 1
      else
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 1;

      {$IFDEF IDEDLL}
      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_VERSIONINFO_hint46;
      LVItem.SubItems.Add('DelVerInfo');
      if DSAIdentsGetState(DSARootKey, 'DelVerInfo') then 
        LVItem.StateIndex := 1
      else 
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 0;
      {$ENDIF IDEDLL}

      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_Confirm_remove_from_custom_filter;
      LVItem.SubItems.Add('RmvCustFlt');
      if DSAIdentsGetState(DSARootKey, 'RmvCustFlt') then 
        LVItem.StateIndex := 1
      else 
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 1;

      {$IFNDEF IDEDLL}
      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_Confirm_terminate_program;
      LVItem.SubItems.Add('TerminateProg');
      if DSAIdentsGetState(DSARootKey, 'TerminateProg') then
        LVItem.StateIndex := 1
      else
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 1;
      {$ENDIF ~IDEDLL}

      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_Server_connection_closed46;
      LVItem.SubItems.Add('CloseA');
      if DSAIdentsGetState(DSARootKey, 'CloseA') then 
        LVItem.StateIndex := 1
      else 
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 0;

      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_Win2K_34Localhost34_warning46;
      LVItem.SubItems.Add('W2KWarning');
      if DSAIdentsGetState(DSARootKey, 'W2KWarning') then 
        LVItem.StateIndex := 1
      else
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 2;

      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_Confirm_hide_unselected_34Sync34_files46;
      LVItem.SubItems.Add('HideSyncFile');
      if DSAIdentsGetState(DSARootKey, 'HideSyncFile') then 
        LVItem.StateIndex := 1
      else 
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 1;

      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_Auto_start_local_servers46;
      LVItem.SubItems.Add('LocalReconnect');
      if DSAIdentsGetState(DSARootKey, 'LocalReconnect') then
        LVItem.StateIndex := 1
      else 
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 1;

      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_Direct_SQL_warning46;
      LVItem.SubItems.Add('DirectSQL');
      if DSAIdentsGetState(DSARootKey, 'DirectSQL') then 
        LVItem.StateIndex := 1
      else 
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 2;

      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_Ctrl43_shortcuts_disabled46;
      LVItem.SubItems.Add('CtrlSC');
      if DSAIdentsGetState(DSARootKey, 'CtrlSC') then 
        LVItem.StateIndex := 1
      else
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 0;

      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_SMTP_mail_not_send46;
      LVItem.SubItems.Add('SMTPRecords');
      if DSAIdentsGetState(DSARootKey, 'SMTPRecords') then 
        LVItem.StateIndex := 1
      else 
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 0;

      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_Request_check_in_for_locked_modules46;
      LVItem.SubItems.Add('NotifyLocked');
      if DSAIdentsGetState(DSARootKey, 'NotifyLocked') then 
        LVItem.StateIndex := 1
      else
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 1;

      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_Synchronize_45_Verify_result46;
      LVItem.SubItems.Add('VerifyRes');
      if DSAIdentsGetState(DSARootKey, 'VerifyRes') then 
        LVItem.StateIndex := 1
      else 
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 0;

      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_Synchronize_45_Synchronize_result46;
      LVItem.SubItems.Add('SyncRes');
      if DSAIdentsGetState(DSARootKey, 'SyncRes') then 
        LVItem.StateIndex := 1
      else
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 0;

      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_Adding_modules_45_skip_existing46;
      LVItem.SubItems.Add('SkipExisting');
      if DSAIdentsGetState(DSARootKey, 'SkipExisting') then
        LVItem.StateIndex := 1
      else
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 0;

      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_Check_In_45_skip_not_checked_out46;
      LVItem.SubItems.Add('SkipNotCheckedOut');
      if DSAIdentsGetState(DSARootKey, 'SkipNotCheckedOut') then 
        LVItem.StateIndex := 1
      else 
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 0;

      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_Get_writeable_warning46;
      LVItem.SubItems.Add('GetWriteable');
      if DSAIdentsGetState(DSARootKey, 'GetWriteable') then 
        LVItem.StateIndex := 1
      else 
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 2;

      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_Don39t_overwrite_local_warning46;
      LVItem.SubItems.Add('DontOverwrLocal');
      if DSAIdentsGetState(DSARootKey, 'DontOverwrLocal') then
        LVItem.StateIndex := 1
      else
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 2;

      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_34Global_settings34_forced_on_this_server46;
      LVItem.SubItems.Add('GlobalSetting');
      if DSAIdentsGetState(DSARootKey, 'GlobalSetting') then 
        LVItem.StateIndex := 1
      else
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 0;

      LVItem := Items.Add;
      LVItem.Caption := JVCSRES_Don39t_disable_locale_RO_checks_warning46;
      LVItem.SubItems.Add('DontCheckRO');
      if DSAIdentsGetState(DSARootKey, 'DontCheckRO') then
        LVItem.StateIndex := 1
      else
        LVItem.StateIndex := 0;
      LVItem.ImageIndex := 2;
    end; // with lvFilters do begin
    Update;
  finally
    Screen.Cursor := crDefault;
  end;
  FCreating := False;
end;

//------------------------------------------------------------------------------

function TVCSOptions.CheckValues: Boolean;
var
  CurrEntry: string;
  SCOK: Boolean;

  function CheckStrToInt(Value: string; Min, Max: Integer): Boolean;
  var
    TestInt, ValError: Integer;
  begin
    while Pos('.', Value) <> 0 do
      Delete(Value, Pos('.', Value), 1);
    while Pos(',', Value) <> 0 do
      Delete(Value, Pos(',', Value), 1);
    Val(Value, TestInt, ValError);
    Result := not ((ValError > 0) or (TestInt < Min) or (TestInt > Max));
  end;

  function CheckShortCuts(AShortCuts: array of TShortCut): Boolean;
  var
    I, J: Integer;
  begin
    Result := True;
    for I := Low(AShortCuts) to High(AShortCuts) do
      for J := I + 1 to High(AShortCuts) do
        if (AShortCuts[I] <> 0) and (AShortCuts[I] = AShortCuts[J]) then
        begin
          Result := False;
          Break;
        end;
  end;

begin
  Result := False;

  if (speSearchTime.Value < 500) or (speSearchTime.Value > 5000) then
  begin
    lbSelectSheet.ItemIndex := cspInterface;
    lbSelectSheetClick(Self);
    speSearchTime.SetFocus;
    speSearchTime.SelectAll;
    BeepIfSet;
    WarnMessageBox( Format( JVCSRES_Integer_between_6037d62_and_6037d62_expected46
                          , [500, 5000]
                          )
                  );
    Exit;
  end;

  {$IFNDEF IDEDLL}
  //THe: for now, Baseregkey cannot be changed. Unsure if this is useful at all
  {if (edBaseRegKey.Text <> sBaseRegistryKey) then
  begin
    lbSelectSheet.ItemIndex := cspFolders;
    lbSelectSheetClick(Self);
    edBaseRegKey.SetFocus;
    BeepIfSet;
    (* Are you sure to change the base registry key?\n\r
       Warning! All user settings and window positions will be lost! 42 *)
    if MessageBox(WindowHandle, PChar(LoadStr(42)),
      cMsgBoxCaption, MB_YESNOCANCEL or MB_DEFBUTTON2 or MB_ICONQUESTION) <> id_Yes then
    begin
      edBaseRegKey.Text := sBaseRegistryKey;
      Exit;
    end
    else
      sBaseRegistryKey := edBaseRegKey.Text;
    jvcsWriteString(cRegSwJVCSBase, 'BaseRegistryKey', sBaseRegistryKey);
  end;}
  {$ENDIF ~IDEDLL}

  if not DirectoryExists(edTempDir.Text) then
  begin
    lbSelectSheet.ItemIndex := cspFolders;
    lbSelectSheetClick(Self);
    edTempDir.SetFocus;
    edTempDir.SelectAll;
    BeepIfSet;
    WarnMessageBox( Format( JVCSRES_JEDI_VCS_cannot_find_the_directory58 + sLineBreak + '<%s>.'
                          , [edTempDir.Text]
                          )
                  );
    Exit;
  end;

  if edLocalServer.Text <> '' then
  begin
    if not FileExists(edLocalServer.Text) then
    begin
      lbSelectSheet.ItemIndex := cspFolders;
      lbSelectSheetClick(Self);
      edLocalServer.SetFocus;
      edLocalServer.SelectAll;
      BeepIfSet;
      WarnMessageBox( Format( JVCSRES_JEDI_VCS_cannot_find_the_file58 + sLineBreak + '<%s>.'
                            , [edLocalServer.Text]
                            )
                    );
      Exit;
    end;
  end; // if edLocalServer.Text <> '' then begin

  if edBckupPath.Text <> '' then
  begin
    if not DirectoryExists(edBckupPath.Text) then
    begin
      lbSelectSheet.ItemIndex := cspBackup;
      lbSelectSheetClick(Self);
      edBckupPath.SetFocus;
      edBckupPath.SelectAll;
      BeepIfSet;
      WarnMessageBox( Format( JVCSRES_JEDI_VCS_cannot_find_the_directory58 + sLineBreak + '<%s>.'
                            , [edBckupPath.Text]
                            )
                    );
      Exit;
    end;
    CurrEntry := ExtractFileDrive(edBckupPath.Text);
    case GetDriveType(PChar(CurrEntry)) of
      DRIVE_CDROM, DRIVE_RAMDISK:
        begin
          lbSelectSheet.ItemIndex := cspBackup;
          lbSelectSheetClick(Self);
          edBckupPath.SetFocus;
          edBckupPath.SelectAll;
          BeepIfSet;
          WarnMessageBox( Format( '<%s>' + sLineBreak +
                                  JVCSRES_The_directory_you_have_selected_is_located_on_a_RAM_disk_or_a_CDROM46 + sLineBreak +
                                  JVCSRES_You_cannot_use_temporary_or_read45only_drives_for_backup46
                                , [edBckupPath.Text]
                                )
                        );
          Exit;
        end;
    end; // case GetDriveType(CurrEntry) of
  end; // if edBckupPath.Text <> '' then begin

  if not cbUseOnlyShellExt.Checked then
  begin
    if edRWS.Text <> '' then
    begin
      if not FileExists(edRWS.Text) then 
      begin
        lbSelectSheet.ItemIndex := cspEditors;
        lbSelectSheetClick(Self);
        edRWS.SetFocus;
        edRWS.SelectAll;
        BeepIfSet;
        WarnMessageBox( Format( JVCSRES_JEDI_VCS_cannot_find_the_file58 + sLineBreak + '<%s>.'
                              , [edRWS.Text]
                              )
                      );
        Exit;
      end;
    end; // if edRWS.Text <> '' then begin

    if edBMP.Text <> '' then
    begin
      if not FileExists(edBMP.Text) then
      begin
        lbSelectSheet.ItemIndex := cspEditors;
        lbSelectSheetClick(Self);
        edBMP.SetFocus;
        edBMP.SelectAll;
        BeepIfSet;
        WarnMessageBox( Format( JVCSRES_JEDI_VCS_cannot_find_the_file58 + sLineBreak + '<%s>.'
                              , [edBMP.Text]
                              )
                      );
        Exit;
      end;
    end; // if edBMP.Text <> '' then begin

    if edTxt.Text <> '' then
    begin
      if not FileExists(edTxt.Text) then
      begin
        lbSelectSheet.ItemIndex := cspEditors;
        lbSelectSheetClick(Self);
        edTxt.SetFocus;
        edTxt.SelectAll;
        BeepIfSet;
        WarnMessageBox( Format( JVCSRES_JEDI_VCS_cannot_find_the_file58 + sLineBreak + '<%s>.'
                              , [edTxt.Text]
                              )
                      );
        Exit;
      end;
    end; // if edTxt.Text <> '' then begin

    if edUserEdit.Text <> '' then 
    begin
      if not FileExists(edUserEdit.Text) then 
      begin
        lbSelectSheet.ItemIndex := cspEditors;
        lbSelectSheetClick(Self);
        edUserEdit.SetFocus;
        edUserEdit.SelectAll;
        BeepIfSet;
        WarnMessageBox( Format( JVCSRES_JEDI_VCS_cannot_find_the_file58 + sLineBreak + '<%s>.'
                              , [edUserEdit.Text]
                              )
                      );
        Exit;
      end;
      {$IFDEF IDEDLL}
      CurrEntry := lvFilters.Items[7].SubItems[0];
      {$ELSE}
      CurrEntry := lvFilters.Items[6].SubItems[0];
      {$ENDIF IDEDLL}
      if CurrEntry = '' then 
      begin
        lbSelectSheet.ItemIndex := cspFilter;
        lbSelectSheetClick(Self);
        lvFilters.SetFocus;
        {$IFDEF IDEDLL}
        lvFilters.Items[7].Selected := True;
        {$ELSE}
        lvFilters.Items[6].Selected := True;
        {$ENDIF IDEDLL}
        BeepIfSet;
        WarnMessageBox( JVCSRES_You_have_a_user_editor_defined_but_no_corresponding_file_extensions46);
        Exit;
      end; // if CurrEntry = '' then begin
    end; // if edUserEdit.Text <> '' then begin
  end; // if not cbUseOnlyShellExt.Checked then begin

  SCOK := CheckShortCuts([edSCProjAdmin.HotKey, edSCGet.HotKey, edSCChkIn.HotKey,
    edSCChkOut.HotKey, edSCSync.HotKey, edSCBckUp.HotKey]);

  if not SCOK then 
  begin
    lbSelectSheet.ItemIndex := cspShortcut;
    lbSelectSheetClick(Self);
    BeepIfSet;
    WarnMessageBox(JVCSRES_Invalid_or_duplicate_shortcut46);
    Exit;
  end; // if not SCOK then begin

  if cbEncryptData.Checked then 
  begin
    if Length(pwedBFKey.Text) < 16 then
    begin
      lbSelectSheet.ItemIndex := cspBlowfish;
      lbSelectSheetClick(Self);
      pwedBFKey.SetFocus;
      pwedBFKey.SelectAll;
      BeepIfSet;
      WarnMessageBox( JVCSRES_Data_encryption_requires_a_key_length_of_128_bit_min46 + sLineBreak +
                      JVCSRES_Your_key_must_be_at_least_16_characters_and_can_be_up_to_56_characters46 + sLineBreak +
                      JVCSRES_Note_that_longer_keys_will_not_result_in_slower_encoding47decoding44_but_in_more_security46
                    );
      Exit;
    end;
    if pwedBFKeyConfirm.Text <> pwedBFKey.Text then 
    begin
      lbSelectSheet.ItemIndex := cspBlowfish;
      lbSelectSheetClick(Self);
      pwedBFKey.Clear;
      pwedBFKeyConfirm.Clear;
      pwedBFKey.SetFocus;
      BeepIfSet;
      WarnMessageBox( JVCSRES_Confirmation_does_not_match_key46 + sLineBreak +
                      JVCSRES_Please_re45enter_the_key46
                    );
      Exit;
    end;
  end; // if not SCOK then begin

  Result := True;
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.GetValues;
var
  CurrentStoreKey: string;
  I, J: Integer;
begin
  Screen.Cursor := crHourGlass;
  try
    if rbBkupLevel9.Checked then
      iZipBkUpLevel := 9;
    if rbBkupLevel5.Checked then
      iZipBkUpLevel := 5;
    if rbBkupLevel2.Checked then
      iZipBkUpLevel := 2;

    with lvFilters do
    begin
      sftDelphi := Items[0].SubItems[0];
      sftAddin := Items[1].SubItems[0];
      sftCompare := Items[2].SubItems[0];
      {$IFDEF IDEDLL}
      sftIDE := Items[3].SubItems[0];
      sftImage := Items[4].SubItems[0];
      sftResource := Items[5].SubItems[0];
      sftText := Items[6].SubItems[0];
      sftUser := Items[7].SubItems[0];
      sftNeverSync := Items[8].SubItems[0];
      sftWriteable := Items[9].SubItems[0];
      {$ELSE}
      sftImage := Items[3].SubItems[0];
      sftResource := Items[4].SubItems[0];
      sftText := Items[5].SubItems[0];
      sftUser := Items[6].SubItems[0];
      sftNeverSync := Items[7].SubItems[0];
      sftWriteable := Items[8].SubItems[0];
      sftExclude := Items[9].SubItems[0];
      {$ENDIF IDEDLL}
      jvcsDeleteKey(sBaseRegistryKey + crbFilters + '\Custom');
      J := 0;
      for I := 0 to Items.Count - 1 do
      begin
        if Items[I].SubItems[1] = '1' then
        begin
          Inc(J);
          jvcsWriteString(sBaseRegistryKey + crbFilters + '\Custom',
            'Custom' + IntToStr(J), Items[I].Caption + '|' + Items[I].SubItems[0]);
        end;
      end;
    end;
    with lvCompareTools do
    begin
      jvcsDeleteKey(sBaseRegistryKey + '\CompareTools');
      J := 0;
      for I := 0 to Items.Count - 1 do
      begin
        if (Items[I].SubItems[0] <> '') and
          (Items[I].SubItems[1] <> '') and
          (Items[I].SubItems[2] = '1') then
        begin
          Inc(J);
          jvcsWriteString(sBaseRegistryKey + '\CompareTools',
            'Custom' + IntToStr(J), Items[I].Caption + '|' + Items[I].SubItems[0] +
            '|' + Items[I].SubItems[1]);
        end;
      end;
    end;

    NtfyFilterValue := 0;
    if cbBeep.Checked then
      NtfyFilterValue := NtfyFilterValue or ntfyBeep;
    if cbOnlyCurrent.Checked then
      NtfyFilterValue := NtfyFilterValue or ntfyOnlyCurrent;
    if cbNtfyFOConnect.Checked then
      NtfyFilterValue := NtfyFilterValue or ntfyConctA;
    if cbNtfyFOCheckOut.Checked then
      NtfyFilterValue := NtfyFilterValue or ntfyChckOut;
    if cbNtfyFOCheckIn.Checked then
      NtfyFilterValue := NtfyFilterValue or ntfyChckIn;
    if not ColorToIdent(NtfyColorCombo.ColorValue, NtfyTCIdent) then
      NtfyTCIdent := 'clNavy';
    {$IFDEF IDEDLL}
    if (iMenAccel <> JvxAccel.Value) then
    begin
      WarnMessageBox( JVCSRES_IDE_Menu_accelerator_changed46 + sLineBreak +
                      JVCSRES_You_must_restart_the_IDE_for_this_change_to_take_effect46
                    );
    end;
    {$ENDIF IDEDLL}
    iMenAccel := JvxAccel.Value;
    {$IFDEF IDEDLL}
    cSCProjAdmin := edSCProjAdmin.HotKey;
    {$ENDIF IDEDLL}
    cSCGet := edSCGet.HotKey;
    cSCChkIn := edSCChkIn.HotKey;
    cSCChkOut := edSCChkOut.HotKey;
    cSCSync := edSCSync.HotKey;
    cSCBckUp := edSCBckUp.HotKey;

    CurrentStoreKey := sBaseRegistryKey + crbWindows;
    // ----------------------------------------------
    jvcsWriteInteger(CurrentStoreKey, 'ProjMan_NotifyFilter', NtfyFilterValue);
    jvcsWriteString(CurrentStoreKey, 'ProjMan_NotifyColor', NtfyTCIdent);
    jvcsWriteBool(CurrentStoreKey, 'ProjMan_ShowListColors', cbShowLVColor.Checked);

    CurrentStoreKey := sBaseRegistryKey + crbOptions;
    // ----------------------------------------------
    //-------------------------------------------------------------------------
    ShowDebugMsg := cbOutPutDbgStr.Checked;
    jvcsWriteBool(CurrentStoreKey, 'OutputDebugStrActive', cbOutPutDbgStr.Checked);
    jvcsWriteInteger(CurrentStoreKey, 'CleanUpDelayValue', _StrToInt(edCleanUpVal.Text));
    //-------------------------------------------------------------------------
    {$IFDEF IDEDLL}
    jvcsWriteBool(CurrentStoreKey, 'ShowLoad', cbShowLoad.Checked);
    jvcsWriteBool(CurrentStoreKey, 'MarkSource', cbMarkSource.Checked);
    jvcsWriteBool(CurrentStoreKey, 'MarkSource_I', cbMSIn.Checked);
    jvcsWriteBool(CurrentStoreKey, 'MarkSource_O', cbMSOut.Checked);
    jvcsWriteBool(CurrentStoreKey, 'MarkSource_Break', cbBreakCIITo80.Checked);
    jvcsWriteBool(CurrentStoreKey, 'AddComponentList', cbAddCList.Checked);
    jvcsWriteBool(CurrentStoreKey, 'AddCFGFiles', cbAddCFG.Checked);
    jvcsWriteBool(CurrentStoreKey, 'AddDSKFiles', cbAddDSK.Checked);
    jvcsWriteInteger(CurrentStoreKey, 'FVCSAccel', iMenAccel);
    jvcsWriteInteger(CurrentStoreKey, 'ShortCutProjAdmin', cSCProjAdmin);
    jvcsWriteBool(CurrentStoreKey,   'CheckModuleState', cbCheckModuleState.Checked);
    {$ENDIF IDEDLL}
    jvcsWriteInteger(CurrentStoreKey, 'ShortCutGet', cSCGet);
    jvcsWriteInteger(CurrentStoreKey, 'ShortCutChkIn', cSCChkIn);
    jvcsWriteInteger(CurrentStoreKey, 'ShortCutChkOut', cSCChkOut);
    jvcsWriteInteger(CurrentStoreKey, 'ShortCutSync', cSCSync);
    jvcsWriteInteger(CurrentStoreKey, 'ShortCutBckUp', cSCBckUp);
    jvcsWriteBool(CurrentStoreKey, 'IncludeIPComment', cbIncludeIPComment.Checked);
    jvcsWriteBool(CurrentStoreKey, 'PromptFMemo', cbpromptfMemo.Checked);
    jvcsWriteBool(CurrentStoreKey, 'MemoRequired', cbMemoRequired.Checked);
    jvcsWriteBool(CurrentStoreKey, 'PromptFMemo2', cbpromptfMemoOut.Checked);
    jvcsWriteBool(CurrentStoreKey, 'LastOutDescr', cbCommInOut.Checked);
    jvcsWriteBool(CurrentStoreKey, 'DoBeep', cbDoBeep.Checked);
    jvcsWriteBool(CurrentStoreKey, 'ShowLocalInfo', cbLocalInfo.Checked);
    jvcsWriteBool(CurrentStoreKey, 'ShowTypeInfo', cbTypeInfo.Checked);
    jvcsWriteBool(CurrentStoreKey, 'ShowToolTip', cbShowToolTip.Checked);
    jvcsWriteString(CurrentStoreKey, 'LocalServer', edLocalServer.Text + #0);
    jvcsWriteString(CurrentStoreKey, 'ResourceEditor', edRWS.Text + #0);
    jvcsWriteString(CurrentStoreKey, 'ImageEditor', edBMP.Text + #0);
    jvcsWriteString(CurrentStoreKey, 'TextEditor', edTxt.Text + #0);
    jvcsWriteString(CurrentStoreKey, 'UserDefinedEditor', edUserEdit.Text + #0);
    jvcsWriteInteger(CurrentStoreKey, 'BackupZipLevel', iZipBkUpLevel);
    jvcsWriteBool(CurrentStoreKey, 'BackupSequentiel', cbSeqBackup.Checked);
    jvcsWriteBool(CurrentStoreKey, 'BackupEraseSequentiel', cbEraseSeq.Checked);
    jvcsWriteInteger(CurrentStoreKey, 'BackupEraseAfterDays', spEraseDays.AsInteger);
    jvcsWriteBool(CurrentStoreKey, 'BackupActive', cbDoBckUp.Checked);
    jvcsWriteBool(CurrentStoreKey, 'BackupProject', cbBckupProj.Checked);
    jvcsWriteBool(CurrentStoreKey, 'BackupShowProgress', cbShProgr.Checked);
    jvcsWriteString(CurrentStoreKey, 'BackupPath', edBckupPath.Text);
    jvcsWriteBool(CurrentStoreKey, 'NotifyActive', cbNotifyActive.Checked);
    jvcsWriteBool(CurrentStoreKey, 'MessConnect', cbMessConnect.Checked);
    jvcsWriteBool(CurrentStoreKey, 'MessDisConnect', cbMessDisConnect.Checked);
    jvcsWriteBool(CurrentStoreKey, 'MessChkOut', cbMessChkOut.Checked);
    jvcsWriteBool(CurrentStoreKey, 'MessChkIn', cbMessChkIn.Checked);
    jvcsWriteString(CurrentStoreKey, 'TempDirectory', SetBackSlash(edTempDir.Text));
    jvcsWriteBool(CurrentStoreKey, 'AutoSync', cbAutoSync.Checked);
    jvcsWriteBool(CurrentStoreKey, 'RefreshTimerEnabled', cbAutoRefresh.Checked);
    jvcsWriteInteger(CurrentStoreKey, 'RefreshTimer', speAutoRefresh.AsInteger * 60000);
    jvcsWriteInteger(CurrentStoreKey, 'PMDoubleClick', cbxPMDoubleClick.ItemIndex);
    jvcsWriteInteger(CurrentStoreKey, 'ChkInDate', cbxChkInDate.ItemIndex);
    jvcsWriteInteger(CurrentStoreKey, 'ChkOutDate', cbxChkOutDate.ItemIndex);
    jvcsWriteInteger(CurrentStoreKey, 'SearchTime', speSearchTime.AsInteger);
    jvcsWriteBool(CurrentStoreKey, 'DisableCtrl', cbDisableGraphDC.Checked);
    jvcsWriteBool(CurrentStoreKey, 'UseOnlyShellExt', cbUseOnlyShellExt.Checked);
    jvcsWriteInteger(CurrentStoreKey, 'ModuleListColor_New', ccbxLVNew.ColorValue);
    jvcsWriteInteger(CurrentStoreKey, 'ModuleListColor_Owner', ccbxLVOut.ColorValue);
    jvcsWriteInteger(CurrentStoreKey, 'ModuleListColor_Locked', ccbxLVNA.ColorValue);
    jvcsWriteBool(CurrentStoreKey, 'KWExpAdd', cbKWExpAdd.Checked);
    jvcsWriteBool(CurrentStoreKey, 'KWExpCheckBinary', cbKWExCheckBinary.Checked);
    jvcsWriteBool(CurrentStoreKey, 'KWExpBackup', cbKWCreateBackup.Checked);
    jvcsWriteBool(CurrentStoreKey, 'KWExpCheckIn', cbKWExpCheckIn.Checked);
    jvcsWriteBool(CurrentStoreKey, 'KWIgnorewoSKW', cbKWIgnorewoSKW.Checked);
    jvcsWriteBool(CurrentStoreKey, 'KeywordExp_CheckOut', cbKWExpCheckOut.Checked);
    jvcsWriteString(CurrentStoreKey, 'KWExpFiles', edKWExp.Text + #0);
    jvcsWriteBool(CurrentStoreKey, 'UnlockUnchangedFiles', cbUnlockUnchanged.Checked);
    jvcsWriteBool(CurrentStoreKey, 'ParentAsExplorer', rbPFExplorer.Checked);
    jvcsWriteString(CurrentStoreKey, 'EncodeKey', Base64Encode(pwedBFKey.Text));
    jvcsWriteBool(CurrentStoreKey, 'EncryptModuleData', cbEncryptData.Checked);
    SrvTimeOutVal := speSrvTimeOut.AsInteger * 1000;
    jvcsWriteInteger(CurrentStoreKey, 'SrvTimeOut', SrvTimeOutVal);
    jvcsWriteBool(CurrentStoreKey, 'GEXPresent', cbGEX.Checked);
    jvcsWriteBool(CurrentStoreKey, 'NoROCheck', cbNoROCheck.Checked);
    jvcsWriteBool(CurrentStoreKey, 'SMTPMessages', cbSMTP.Checked);
    jvcsWriteBool(CurrentStoreKey, 'UseShortFilenames', cbSend8and3.Checked);
    jvcsWriteBool(CurrentStoreKey, 'IgnoreBinary_Text', cbIgnoreBinary_Text.Checked);
    jvcsWriteString(CurrentStoreKey, 'BugtrackerURL', edBugtrackerURL.Text);
    jvcsWriteString(CurrentStoreKey, 'BugtrackerRegEx', edBugtrackerRegEx.Text);
    jvcsWriteString(CurrentStoreKey, 'SaveWIPcommand', edSaveWIPcommand.Text);
    jvcsWriteBool(CurrentStoreKey, 'SaveWIPauto', cbSaveWIPauto.Checked);

    sBugtrackerURL   := edBugtrackerURL.Text;
    sBugtrackerRegEx := edBugtrackerRegEx.Text;
    sSaveWIPcommand  := edSaveWIPcommand.Text;
    bSaveWIPauto     := cbSaveWIPauto.Checked;

    CurrentStoreKey := sBaseRegistryKey + crbPrinter;
    // ----------------------------------------------
    jvcsWriteBool(CurrentStoreKey, 'PrintHeader', cbPrintHeader.Checked);
    jvcsWriteInteger(CurrentStoreKey, 'PrintTM', spePrintTM.AsInteger);
    jvcsWriteInteger(CurrentStoreKey, 'PrintLM', spePrintLM.AsInteger);
    jvcsWriteInteger(CurrentStoreKey, 'FontSize', paPrinterfont.Font.Size);
    jvcsWriteString(CurrentStoreKey, 'FontName', paPrinterfont.Font.Name + #0);

    CurrentStoreKey := sBaseRegistryKey + crbMRU;
    // ----------------------------------------------
    jvcsWriteInteger(CurrentStoreKey, 'FileDlgMRU', speFDlgMRUMax.AsInteger);

    CurrentStoreKey := sBaseRegistryKey + crbFilters;
    // ----------------------------------------------
    jvcsWriteString(CurrentStoreKey, 'Delphi files', sftDelphi + #0);
    jvcsWriteString(CurrentStoreKey, 'AddProjectFiles', sftAddin + #0);
    jvcsWriteString(CurrentStoreKey, 'Compare files', sftCompare + #0);
    jvcsWriteString(CurrentStoreKey, 'Image files', sftImage + #0);
    jvcsWriteString(CurrentStoreKey, 'Resource files', sftResource + #0);
    jvcsWriteString(CurrentStoreKey, 'Text files', sftText + #0);
    jvcsWriteString(CurrentStoreKey, 'User files', sftUser + #0);
    jvcsWriteString(CurrentStoreKey, 'Writeable files', sftWriteable + #0);
    jvcsWriteString(CurrentStoreKey, 'Never Sync files', sftNeverSync + #0);
    jvcsWriteString(CurrentStoreKey, 'Exclude files', sftExclude + #0);
    {$IFDEF IDEDLL}
    jvcsWriteString(CurrentStoreKey, 'IDE files', sftIDE + #0);
    {$ENDIF IDEDLL}

    SetDSAMSettings;
  finally
    Screen.Cursor := crDefault;
    if not jvcsUpdateStorageObject then
      WarnMessageBox(JVCSRES_Storage_Object_update_failed33);
  end;
  // last thing: store the storage methode...
  // this value is *always* stored in the registry!
  with TRegistry.Create do
  begin
    try
      OpenKey(cRegSwJVCSBase, True);
      WriteBool('UseRegistry', (not cbUseFileStorage.Checked));
    finally
      Free;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.btnOKClick(Sender: TObject);
begin
  if lvFilters.IsEditing then
  begin
    lvFilters.Selected.CancelEdit;
    Exit;
  end;
  if lvCompareTools.IsEditing then 
  begin
    lvCompareTools.Selected.CancelEdit;
    Exit;
  end;
  Screen.Cursor := crHourGlass;
  if not CheckValues then 
  begin
    Screen.Cursor := crDefault;
    Exit;
  end;
  GetValues;
  Screen.Cursor := crDefault;
  bVCSOptionsChanged := True;
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.btnApplyClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  if CheckValues then 
  begin
    GetValues;
    bVCSOptionsChanged := True;
    btnApply.Enabled := False;
  end;
  Screen.Cursor := crDefault;
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  jvcsSaveFormPosSize(Self);
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.spBtnLocalServerClick(Sender: TObject);
var 
  P: TPoint;
begin
  P.X := spBtnLocalServer.Left;
  P.Y := spBtnLocalServer.Top + spBtnLocalServer.Height;
  PopupMenuServerInst.Popup(PanelFolders.ClientToScreen(P).X,
    PanelFolders.ClientToScreen(P).Y);
end;


//------------------------------------------------------------------------------

procedure TVCSOptions.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then 
  begin
    btnCancel.Click;
    Key := 0;
  end;
  if Key = VK_F1 then 
    DoContextHelp;
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.HelpTopic1Click(Sender: TObject);
begin
  DoContextHelp;
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.DoContextHelp;
begin
  case lbSelectSheet.ItemIndex of
    cspOptions,
    cspComments:
      PerformHelpCommand(Application, IDH_Properties);
    cspInterface:
      PerformHelpCommand(Application, IDH_Properties_User_Interface);
    cspFolders:
      PerformHelpCommand(Application, IDH_Properties_Folders_2);
    cspDialogs:
      PerformHelpCommand(Application, IDH_Message_Dlgs);
    cspBackup:
      PerformHelpCommand(Application, IDH_Properties_Backup);
    cspEditors:
      PerformHelpCommand(Application, IDH_Properties_Editors);
    cspExtCompare:
      PerformHelpCommand(Application, IDH_External_compare);
    cspFilter:
      PerformHelpCommand(Application, IDH_Properties_OpenDialog);
    cspNotify:
      PerformHelpCommand(Application, IDH_Properties_Notify);
    cspShortcut:
      PerformHelpCommand(Application, IDH_Shortcuts);
    cspTimeStamp:
      PerformHelpCommand(Application, IDH_Properties_Timestamps);
    cspIntPrinter:
      PerformHelpCommand(Application, IDH_Properties_Internal_Printer);
    cspMRU:
      PerformHelpCommand(Application, IDH_Properties);
    cspKWExp:
      PerformHelpCommand(Application, IDH_Keyword_Expansion);
    cspBlowfish:
      PerformHelpCommand(Application, IDH_Data_encryption);
    cspDebug:
      PerformHelpCommand(Application, IDH_Properties_Debug);
    cspExtBugTrack:
      PerformHelpCommand(Application, IDH_Properties_ExtBugTrack);
    cspSaveWIP:
      PerformHelpCommand(Application, IDH_Properties_SaveWIP);
    else;
      PerformHelpCommand(Application, IDH_Properties);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.cbShowLoadClick(Sender: TObject);
begin
  if not FCreating then
    edArchLimitChange(Sender);
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.spbtnBckUpPathClick(Sender: TObject);
begin
  VCSSelectFolder := TVCSSelectFolder.Create(Application);
  try
    VCSSelectFolder.SetStatusText(JVCSRES_38Backup_root_folder58);
    VCSSelectFolder.EnableRecursive(False);
    VCSSelectFolder.HelpContextID := IDH_Backup;
    if edBckupPath.Text <> '' then 
      VCSSelectFolder.SetInitialDir(edBckupPath.Text);
    VCSSelectFolder.ShowModal;
    if VCSSelectFolder.Selection <> '' then
    begin
      edBckupPath.Text := SetBackSlash(AnsiLowerCase(VCSSelectFolder.Selection));
    end; // if VCSSelectFolder.Selection <> '' then begin
  finally
    VCSSelectFolder.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.SetDSAMSettings;
var
  DSARootKey: string;
  I: Integer;
begin
  DSARootKey := sBaseRegistryKey + crbMRU + 'Dlgs';
  with lvDSADlg do
  begin
    for I := 0 to Items.Count - 1 do
    begin
      if (Items[I].SubItems[0] = 'SkipProjectDescr') or
        (Items[I].SubItems[0] = 'SkipModuleDescr') then
        jvcsWriteBool(sBaseRegistryKey + crbOptions, Items[I].SubItems[0],
          (Items[I].StateIndex = 0))
      else
        DSAIdentsSetState(DSARootKey, Items[I].SubItems[0],
        (Items[I].StateIndex = 1));
    end; // for I := 0 to Items.Count - 1 do begin
  end; // with lvDSADlg do begin
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.btnResetDSAMClick(Sender: TObject);
var 
  I: Integer;
begin
  for I := 0 to lvDSADlg.Items.Count - 1 do 
    lvDSADlg.Items[I].StateIndex := 1;
  btnApply.Enabled := True;
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.btnSetAllDSAClick(Sender: TObject);
var 
  I: Integer;
begin
  for I := 0 to lvDSADlg.Items.Count - 1 do 
    lvDSADlg.Items[I].StateIndex := 0;
  btnApply.Enabled := True;
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.spBtnTempDirClick(Sender: TObject);
begin
  VCSSelectFolder := TVCSSelectFolder.Create(Application);
  try
    VCSSelectFolder.SetStatusText(JVCSRES_38JEDI_VCS_temporary_folder58);
    VCSSelectFolder.EnableRecursive(False);
    VCSSelectFolder.HelpContextID := IDH_Properties;
    VCSSelectFolder.EnableNewFolder(False);
    if edTempDir.Text <> '' then 
      VCSSelectFolder.SetInitialDir(edTempDir.Text);
    VCSSelectFolder.EnableNewFolder(True);
    VCSSelectFolder.ShowModal;
    if VCSSelectFolder.Selection <> '' then
    begin
      edTempDir.Text := SetBackSlash(AnsiLowerCase(VCSSelectFolder.Selection));
    end; // if VCSSelectFolder.Selection <> '' then begin
  finally
    VCSSelectFolder.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.cbMarkSourceClick(Sender: TObject);
begin
  if not FCreating then 
  begin
    if bIsCppBuilder and cbMarkSource.Checked then 
    begin
      WarnMessageBox(JVCSRES_This_feature_is_currently_not_supported_by_the_C4343_Builder_version46_Sorry46);
      cbMarkSource.Checked := False;
      Exit;
    end;
    edArchLimitChange(Sender);
    if SettingIsGlobal(1) then
      ShowGlobalSettingsWarning(WindowHandle, GlobalSettingValue(1));
  end;
  cbMSIn.Enabled := cbMarkSource.Checked;
  cbMSOut.Enabled := cbMarkSource.Checked;
  cbBreakCIITo80.Enabled := cbMarkSource.Checked;
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.cbAutoRefreshClick(Sender: TObject);
begin
  if not FCreating then 
    edArchLimitChange(Sender);
  speAutoRefresh.Enabled := cbAutoRefresh.Checked;
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.btnRestDefaultFiltClick(Sender: TObject);
begin
  if MessageBox(WindowHandle,
    PChar(JVCSRES_Restore_default_filter_values63 + sLineBreak +
    JVCSRES_This_will_clear_all_changes_to_internal_filter_values46 + sLineBreak +
    JVCSRES_Custom_file_filters_added_by_the_user_will_not_be_affected46), cMsgBoxCaption,
    MB_YESNOCANCEL or MB_DEFBUTTON2 or MB_ICONQUESTION) <> idYes then 
    Exit;

  if not FCreating then 
    edArchLimitChange(Sender);
  with lvFilters do 
  begin
    Items[0].SubItems[0] := dfDelphiMod;
    Items[1].SubItems[0] := dfAddMod;
    Items[2].SubItems[0] := dfCompMod;
    {$IFDEF IDEDLL}
    Items[3].SubItems[0] := dfIDEEdit;
    Items[4].SubItems[0] := dfBMPEdit;
    Items[5].SubItems[0] := dfRWSEdit;
    Items[6].SubItems[0] := dfTXTEdit;
    Items[7].SubItems[0] := '';
    Items[8].SubItems[0] := dfNotReadOnly;
    {$ELSE}
    Items[3].SubItems[0] := dfBMPEdit;
    Items[4].SubItems[0] := dfRWSEdit;
    Items[5].SubItems[0] := dfTXTEdit;
    Items[6].SubItems[0] := '';
    Items[7].SubItems[0] := dfNotReadOnly;
    {$ENDIF IDEDLL}
  end; // with lvFilters do begin
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.cbNotifyActiveClick(Sender: TObject);
begin
  cbMessConnect.Enabled := cbNotifyActive.Checked or cbSMTP.Checked;
  cbMessDisConnect.Enabled := cbMessConnect.Enabled;
  cbMessChkOut.Enabled := cbMessConnect.Enabled;
  cbMessChkIn.Enabled := cbMessConnect.Enabled;
  CheckGlobalcbOption(cbNotifyActive, 16);
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.lvFiltersDblClick(Sender: TObject);
begin
  pmiFilterEditClick(Self);
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.pmiFilterEditClick(Sender: TObject);
var 
  CurrFilter, CurrItem: string;
  I, SelectedItem, DlgResult: Integer;
begin
  with lvFilters do
  begin
    if Selected = nil then 
    begin
      BeepIfSet;
      Exit;
    end;
    if not FCreating then 
      edArchLimitChange(Sender);
    CurrFilter := Selected.SubItems[0];
    SelectedItem := -1;
    for I := 0 to Items.Count - 1 do
      if Items[I].Selected then 
        SelectedItem := I;
    case SelectedItem of
      0:
        CurrItem := Selected.Caption + ' ' + Format(JVCSRES_40OpenDialog_45_37s_modules41, [sIDEName]);
      1:
        CurrItem := Selected.Caption + ' ' + JVCSRES_40OpenDialog_45_Additional_modules41;
      2:
        CurrItem := Selected.Caption + ' ' + JVCSRES_40do_not_add_binary_file_types3341;
      {$IFDEF IDEDLL}
      3:
        CurrItem := Selected.Caption + ' ' + Format(JVCSRES_40loadable_by_37s_IDE41, [sIDEName]);
      4:
        CurrItem := Selected.Caption + ' ' + JVCSRES_40loadable_by_Image_editor41;
      5:
        CurrItem := Selected.Caption + ' ' + JVCSRES_40loadable_by_Resource_editor41;
      6:
        CurrItem := Selected.Caption + ' ' + JVCSRES_40loadable_by_Text_editor41;
      7:
        CurrItem := Selected.Caption + ' ' + JVCSRES_40loadable_by_User_editor41;
      8:
        CurrItem := Selected.Caption + ' ' + JVCSRES_40do_not_set_read45only_flag41;
      {$ELSE}
      3:
        CurrItem := Selected.Caption + ' ' + JVCSRES_40loadable_by_Image_editor41;
      4:
        CurrItem := Selected.Caption + ' ' + JVCSRES_40loadable_by_Resource_editor41;
      5:
        CurrItem := Selected.Caption + ' ' + JVCSRES_40loadable_by_Text_editor41;
      6:
        CurrItem := Selected.Caption + ' ' + JVCSRES_40loadable_by_User_editor41;
      7:
        CurrItem := Selected.Caption + ' ' + JVCSRES_40do_not_set_read45only_flag41;
      {$ENDIF IDEDLL}
      else
        CurrItem := Format(JVCSRES_File_filter58_37s, [Selected.Caption]);
    end;
  end; // with lvFilters do begin

  VCSListEdit := TVCSListEdit.Create(Application);
  try
    VCSListEdit.Left := Left + 40;
    VCSListEdit.Top := Top + 40;
    VCSListEdit.SetHint(CurrItem);
    VCSListEdit.EnablePathButton(False);
    VCSListEdit.EnableCheckBinaryButton(SelectedItem = 2);
    VCSListEdit.ListString := CurrFilter;
    DlgResult := VCSListEdit.ShowModal;
    CurrFilter := VCSListEdit.ListString;
  finally
    VCSListEdit.Free;
  end;
  if DlgResult = mrOk then
    lvFilters.Selected.SubItems[0] := CurrFilter;
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.edArchLimitChange(Sender: TObject);
begin
  if not FCreating then 
  begin
    btnApply.Enabled := True;
    {$IFDEF DEBUG}
    if Sender is TEdit then  
      TraceAlways('Apply: ' + (Sender as TEdit).Name);
    if Sender is TCheckBox then
      TraceAlways('Apply: ' + (Sender as TCheckBox).Name);
    {$ENDIF DEBUG}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.lvDSADlgMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var 
  HitTest: THitTests;
  HitItem: TListItem;
begin
  HitTest := lvDSADlg.GetHitTestInfoAt(X, Y);
  if (Button = mbLeft) and (htOnStateIcon in HitTest) then 
  begin
    btnApply.Enabled := True;
    HitItem := lvDSADlg.GetItemAt(X, Y);
    if HitItem.StateIndex = 0 then 
      HitItem.StateIndex := 1 
    else 
      HitItem.StateIndex := 0;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.HelpClick(Sender: TObject);
var
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.lvDSADlgKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (lvDSADlg.Selected <> nil) and (Key = VK_SPACE) then 
  begin
    if lvDSADlg.Selected.StateIndex > 1 then 
      Exit;
    btnApply.Enabled := True;    
    if lvDSADlg.Selected.StateIndex = 0 then 
      lvDSADlg.Selected.StateIndex := 1
    else
      lvDSADlg.Selected.StateIndex := 0;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.lbSelectSheetClick(Sender: TObject);
begin
  if lbSelectSheet.ItemIndex < 0 then
    Exit;
  PanelComments.Visible := (lbSelectSheet.ItemIndex = cspComments);
  PanelShortcut.Visible := (lbSelectSheet.ItemIndex = cspShortcut);
  PanelOptions.Visible := (lbSelectSheet.ItemIndex = cspOptions);
  PanelInterface.Visible := (lbSelectSheet.ItemIndex = cspInterface);
  PanelFolders.Visible := (lbSelectSheet.ItemIndex = cspFolders);
  PanelTimeStamp.Visible := (lbSelectSheet.ItemIndex = cspTimeStamp);
  PanelBackup.Visible := (lbSelectSheet.ItemIndex = cspBackup);
  PanelEditors.Visible := (lbSelectSheet.ItemIndex = cspEditors);
  PanelExtCompare.Visible := (lbSelectSheet.ItemIndex = cspExtCompare);
  PanelFilter.Visible := (lbSelectSheet.ItemIndex = cspFilter);
  PanelNotify.Visible := (lbSelectSheet.ItemIndex = cspNotify);
  PanelDialogs.Visible := (lbSelectSheet.ItemIndex = cspDialogs);
  PanelIntPrinter.Visible := (lbSelectSheet.ItemIndex = cspIntPrinter);
  PanelMRU.Visible := (lbSelectSheet.ItemIndex = cspMRU);
  PanelKWExpansion.Visible := (lbSelectSheet.ItemIndex = cspKWExp);
  PanelEncryption.Visible := (lbSelectSheet.ItemIndex = cspBlowfish);
  PanelDebug.Visible := (lbSelectSheet.ItemIndex = cspDebug);
  PanelExtBugTrack.Visible := (lbSelectSheet.ItemIndex = cspExtBugTrack);
  PanelSaveWIP.Visible := (lbSelectSheet.ItemIndex = cspSaveWIP);
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.ServerInstBrowseClick(Sender: TObject);
var
  DlgResult: Boolean;
  FavOpenDialog: TFavOpenDialog;
begin
  FavOpenDialog := TFavOpenDialog.Create(Application);
  try
    with FavOpenDialog do
    begin
      Title := JVCSRES_Application_server_40local41;
      Options := [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing];
      InitialDir := ExtractFileDir(edLocalServer.Text);
      FileName := edLocalServer.Text;
      Filter := Format(JVCSRES_Application_Server_4037s4112437s, ['jvcssrv.exe', 'jvcssrv.exe']);

      DlgResult := ExecuteFavOpenDialogWithMru(FavOpenDialog,
        sBaseRegistryKey + crbMRU + '18');
    end; // with FavOpenDialog1 do begin
    if DlgResult then 
      edLocalServer.Text := AnsiLowerCase(FavOpenDialog.FileName);
  finally
    FavOpenDialog.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.ServerInstFindClick(Sender: TObject);
var 
  SearchDrive: Char;
begin
  VCSSelectDrive := TVCSSelectDrive.Create(Application);
  try
    VCSSelectDrive.SetLabelCaption(JVCSRES_local_application_server46);
    VCSSelectDrive.ShowModal;
    SearchDrive := VCSSelectDrive.SelectedDrive;
  finally
    VCSSelectDrive.Free;
  end;
  if SearchDrive = '#' then
    Exit;
  edLocalServer.Text := '';
  Screen.Cursor := crHourGlass;
  Update;
  FindType := 2;
  with JvSearchFiles do
  begin
    RootDirectory := SearchDrive + ':\';
    DirOption := doIncludeSubDirs;
    FileParams.FileMasks.Clear;
    FileParams.FileMasks.Add('jvcssrv.exe');
    Search;
    Screen.Cursor := crDefault;
    if edLocalServer.Text = '' then
    begin
      WarnMessageBox( Format( JVCSRES_JEDI_VCS_cannot_find_the_37s_in_drive_6037s6246
                            , [JVCSRES_file, SearchDrive + ':']
                            )
                    );
    end;
  end;

  { 
  Screen.Cursor := crDefault;
  if edLocalServer.Text = '' then
   begin
    // JEDI VCS cannot find the %s in drive %s. 196
    MessageBox(WindowHandle, PChar(FmtLoadStr(196, ['file', SearchDrive + ':'])),
      cMsgBoxCaption, MB_OK or MB_ICONWARNING);
   end;
   }
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.cbUseOnlyShellExtClick(Sender: TObject);
begin
  Label10.Enabled := not cbUseOnlyShellExt.Checked;
  edRWS.Enabled := not cbUseOnlyShellExt.Checked;
  Label11.Enabled := not cbUseOnlyShellExt.Checked;
  edBMP.Enabled := not cbUseOnlyShellExt.Checked;
  Label12.Enabled := not cbUseOnlyShellExt.Checked;
  edTxt.Enabled := not cbUseOnlyShellExt.Checked;
  Label13.Enabled := not cbUseOnlyShellExt.Checked;
  edUserEdit.Enabled := not cbUseOnlyShellExt.Checked;
  Label40.Enabled := not cbUseOnlyShellExt.Checked;
  if not FCreating then 
    btnApply.Enabled := True;
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.spBtSelectPrnFontClick(Sender: TObject);
begin
  FontDialog1.Font.Name := paPrinterfont.Font.Name;
  FontDialog1.Font.Size := paPrinterfont.Font.Size;
  if FontDialog1.Execute then 
  begin
    paPrinterfont.Font.Name := FontDialog1.Font.Name;
    paPrinterfont.Font.Size := FontDialog1.Font.Size;
    paPrinterfont.Font.Style := [];
    paPrinterfont.Caption := paPrinterfont.Font.Name + ', ' +
      IntToStr(paPrinterfont.Font.Size);
    btnApply.Enabled := True;
  end;
end;

//------------------------------------------------------------------------------

function TVCSOptions.GetMRUListIndex: string;
begin
  case cbxMRUList.ItemIndex of
    -1:
      Result := '';
    0:
      Result := '17'; // Save file dialogs
    1:
      Result := '18'; // Open file dialogs
    2:
      Result := '8';  // Check Out target folders
    3:
      Result := '9';  // Project folders
    4:
      Result := '16'; // Host names
    5:
      Result := '5';  // Restore target path
    6:
      Result := '15'; // Module search mask
    7:
      Result := '6';  // New synchronize folder
    8:
      Result := '14'; // To Do categories
    9:
      Result := '12'; // Wildcard view filter
    10:
      Result := '20'; // Compare date module list
    11:
      Result := '22'; // Open project
    12:
      Result := '23'; // Select folder
    13:
      Result := '24'; // Compare Folder (Base)
    14:
      Result := '25'; // Compare Folder (Target)
    15:
      Result := '26'; // Touch Folder
    16:
      Result := '27'; // Source Distribution
    17:
      Result := 'SQL'; // Direct SQL
    18:
      Result := '28'; // Label filter mask
    19:
      Result := 'ChkIn'; // Check In comments
    20:
      Result := 'ChkOut'; // Check Out comments
    else
      Result := '';
  end; // case cbxMRUList.ItemIndex of
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.lbMRUListClick(Sender: TObject);
begin
  btnClrMRUItem.Enabled := (lbMRUList.ItemIndex <> -1);
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.cbxMRUListChange(Sender: TObject);
var
  MRUIndex: string;
  MRUStrings: TJVCSMruList;
  I: Integer;

  procedure EnableMaxCount(Enable: Boolean; const MCount: Word);
  begin
    speFDlgMRUMax.Visible := Enable;
    if Enable then
      Label47.Caption := JVCSRES_Ma38x_count
    else
      Label47.Caption := Format(JVCSRES_Max_count58_37d, [MCount]);
  end;
begin
  MRUIndex := GetMRUListIndex;
  if MRUIndex = '' then 
    Exit;
  case cbxMRUList.ItemIndex of
    0, 1:
      EnableMaxCount(True, 0);
    3:
      EnableMaxCount(False, 5);
    5, 7, 17:
      EnableMaxCount(False, 20);
    8:
      EnableMaxCount(False, 50);
    else 
      EnableMaxCount(False, 10);
  end; // case cbxMRUList.ItemIndex of
  MRUStrings := TJVCSMruList.Create;
  try
    MRUStrings.MaxSize := 100;
    MRUStrings.CaseSensitive := True;
    MRUStrings.LoadFromStorage(sBaseRegistryKey + crbMRU + MRUIndex);
    lbMRUList.Items.Clear;
    for I := 0 to MRUStrings.Count - 1 do
      lbMRUList.Items.Add(MRUStrings.Strings[I]);
  finally
    MRUStrings.Free;
  end;
  lbMRUListClick(Self);
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.btnClrMRUItemClick(Sender: TObject);
var 
  MRUIndex: string;
  MRUStrings: TJVCSMruList;
begin
  if lbMRUList.ItemIndex = -1 then 
    Exit;
  MRUIndex := GetMRUListIndex;
  if MRUIndex = '' then 
    Exit;
  MRUStrings := TJVCSMruList.Create;
  try
    MRUStrings.MaxSize := 100;
    MRUStrings.CaseSensitive := True;
    MRUStrings.LoadFromStorage(sBaseRegistryKey + crbMRU + MRUIndex);
    MRUStrings.RemoveString(lbMRUList.Items[lbMRUList.ItemIndex]);
    lbMRUList.Items.Delete(lbMRUList.ItemIndex);
    MRUStrings.SaveToStorage(sBaseRegistryKey + crbMRU + MRUIndex);
  finally
    MRUStrings.Free;
  end;
  lbMRUListClick(Self);
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.btnClrMRUAllClick(Sender: TObject);
var 
  MRUIndex: string;
  MRUStrings: TJVCSMruList;
  I: Integer;
begin
  MRUIndex := GetMRUListIndex;
  if MRUIndex = '' then 
    Exit;
  if MessageBox(WindowHandle, PChar(JVCSRES_Are_you_sure_you_want_to_clear_the_selected_MRU_list63),
    cMsgBoxCaption, MB_YESNOCANCEL or
    MB_DEFBUTTON2 or MB_ICONQUESTION) <> id_Yes then 
    Exit;
  MRUStrings := TJVCSMruList.Create;
  try
    MRUStrings.MaxSize := 100;
    MRUStrings.CaseSensitive := True;
    MRUStrings.LoadFromStorage(sBaseRegistryKey + crbMRU + MRUIndex);
    for I := 0 to lbMRUList.Items.Count - 1 do
      MRUStrings.RemoveString(lbMRUList.Items[I]);
    lbMRUList.Items.Clear;
    MRUStrings.SaveToStorage(sBaseRegistryKey + crbMRU + MRUIndex);
  finally
    MRUStrings.Free;
  end;
  lbMRUListClick(Self);
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.cbShowLVColorClick(Sender: TObject);
begin
  if not FCreating then 
    edArchLimitChange(Sender);
  ccbxLVOut.Enabled := cbShowLVColor.Checked;
  ccbxLVNA.Enabled := cbShowLVColor.Checked;
  ccbxLVNew.Enabled := cbShowLVColor.Checked;
  Label48.Enabled := cbShowLVColor.Checked;
  Label49.Enabled := cbShowLVColor.Checked;
  Label1.Enabled := cbShowLVColor.Checked;
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.spBtnInsCTClick(Sender: TObject);
  {$IFDEF IDEDLL}
var 
  CTFileName: string;
  CTContent: TStringList;
  I: Integer;
  Success, AlreadyAss: Boolean;
  {$ENDIF IDEDLL}
begin
  {$IFDEF IDEDLL}
  if bIsCppBuilder then 
  begin
    InfoMessageBox(JVCSRES_This_feature_is_currently_not_supported_by_the_C4343_Builder_version46_Sorry46);
    Exit;
  end;  
  Success := True;
  CTContent := TStringList.Create;
  try
    if DirectoryExists(IDEInterface.JVCSIDESettings.IDEAppFileDir) then
    begin
      CTFileName := IDEInterface.JVCSIDESettings.IDEAppFileDir + 'delphi32.dci';
      //---> CTFileName := s A p p D i r e c t o r y  + 'bin\delphi32.dci';
      if FileExists(CTFileName) then
      begin
        try
          CTContent.LoadFromFile(CTFileName);
        except
          on E:
          Exception do
          begin
            CTContent.Clear;
            BeepIfSet;
            ErrorMessageBox ( Format( JVCSRES_Reading_file_6037s62 + sLineBreak +
                                      JVCSRES_raised_exception58 + sLineBreak + '%s.'
                                    , [CTFileName, E.Message]
                                    )
                            );
            Success := False;
            Exit;
          end;
        end; // try except

        AlreadyAss := False;
        for I := 0 to CTContent.Count - 1 do
          if Pos('[jvcskeywords | JEDI VCS Keyword Expansion]',
            CTContent.Strings[I]) <> 0 then
            AlreadyAss := True;

        if not AlreadyAss then 
        begin
          CTContent.Add('');
          CTContent.Add('[jvcskeywords | JEDI VCS Keyword Expansion]');
          CTContent.Add('(********************************************************');
          CTContent.Add(' * $Keywords               (Important! Starts processing)');
          CTContent.Add(' * File maintained by JEDI Version Control System');
          CTContent.Add(' * http://jedivcs.sourceforge.net/');
          CTContent.Add(' ****************************************************');
          CTContent.Add(' *');
          CTContent.Add(' * $OriginalPath: $');
          CTContent.Add(' * $AddDate: $');
          CTContent.Add(' * $AddUser: $');
          CTContent.Add(' * $AddProject: $');
          CTContent.Add(' * $AddComment: $');
          CTContent.Add(' *');
          CTContent.Add(' * $ModuleID: $');
          CTContent.Add(' * $RevisionID: $');
          CTContent.Add(' *');
          CTContent.Add(' * $CheckInDate: $');
          CTContent.Add(' * $CheckInUser: $');
          CTContent.Add(' * $CheckInProject: $');
          CTContent.Add(' * $Version: $');
          CTContent.Add(' * $Revision: $');
          CTContent.Add(' * $Label: $');
          CTContent.Add(' * $CheckInComment: $');
          CTContent.Add(' *');
          CTContent.Add(' * $CheckOutDate: $');
          CTContent.Add(' * $CheckOutUser: $');
          CTContent.Add(' * $CheckOutProject: $');
          CTContent.Add(' * $CheckOutComment: $');
          CTContent.Add(' *');
          CTContent.Add(' * $NoKeywords   (Important! Stops further processing)');
          CTContent.Add(' ****************************************************)');
          try
            CTContent.SaveToFile(CTFileName);
          except
            BeepIfSet;
            ErrorMessageBox ( Format( JVCSRES_JEDI_VCS_cannot_save_the_file + sLineBreak + '<%s>.' + sLineBreak +
                                      JVCSRES_Be_sure_that_the_file_is_not_opened_by_another_application44 + sLineBreak +
                                      JVCSRES_that_there_is_enough_free_space_on_the_disk + sLineBreak +
                                      JVCSRES_and_that_you_have_the_required_access_rights46
                                    , [CTFileName]
                                    )
                            );
            Success := False;
          end;
        end; // if not AlreadyAss then begin
      end // if FileExists(PRLFileName) then begin
      else
      begin
        BeepIfSet;
        WarnMessageBox( Format( JVCSRES_JEDI_VCS_cannot_open_the_file46_40Invalid_path_or_access_denied4158 + sLineBreak + '<%s>.' + sLineBreak +
                                JVCSRES_Make_sure_that_the_file_exists44_that_it_is_not_opened_by_another_application + sLineBreak +
                                JVCSRES_and_that_you_have_the_required_access_rights46
                              , [CTFileName]
                              )
                      );
        Success := False;
      end;
    end // if DirectoryExists(sAppDirectory) then begin
    else
    begin
      BeepIfSet;
      WarnMessageBox( JVCSRES_JEDI_VCS_cannot_detect_the_name_of_Delphi39s_base_installation_folder46 + sLineBreak +
                      JVCSRES_This_function_is_only_supported_for_known_IDE_products46
                    );
      Success := False;
    end;
  finally
    CTContent.Free;
  end;
  if Success then
    InfoMessageBox( JVCSRES_Source_code_template_34jvcskeywords_124_JEDI_VCS_Keyword_Expansion34_successfully_added46 + sLineBreak +
                    JVCSRES_Hit_60Ctrl43J62_to_insert_the_template_into_your_source_files46
                  );
  {$ENDIF IDEDLL}
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.spBtnEditKWExpClick(Sender: TObject);
var 
  DlgResult: Integer;
  EditString: string;
begin
  EditString := edKWExp.Text;
  VCSListEdit := TVCSListEdit.Create(Application);
  try
    VCSListEdit.Left := Left + 40;
    VCSListEdit.Top := Top + 40;
    VCSListEdit.SetHint(JVCSRES_Search_files_for_keywords);
    VCSListEdit.EnablePathButton(False);
    VCSListEdit.ListString := EditString;
    DlgResult := VCSListEdit.ShowModal;
    EditString := VCSListEdit.ListString;
  finally
    VCSListEdit.Free;
  end;
  if DlgResult = mrOk then
    edKWExp.Text := EditString;
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.AddCustomFileFilter1Click(Sender: TObject);
var 
  LVItem: TListItem;
begin
  with lvFilters do 
  begin
    LVItem := Items.Add;
    LVItem.ImageIndex := 4;
    LVItem.Caption := JVCSRES_New_Filter;
    LVItem.SubItems.Add('');
    LVItem.SubItems.Add('1');
    Selected := LVItem;
    Selected.EditCaption;
  end;
  if not FCreating then
    btnApply.Enabled := True;
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.Renamecustomfilefilter1Click(Sender: TObject);
begin
  if (lvFilters.Selected <> nil) then 
    lvFilters.Selected.EditCaption;
  if not FCreating then 
    btnApply.Enabled := True;
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.RemoveCustomFileFilter1Click(Sender: TObject);
begin
  if (lvFilters.Selected = nil) then 
    Exit;
  if MessageBox(WindowHandle,
    PChar(Format(JVCSRES_Are_you_sure_you_want_to_remove_3437s3463, [lvFilters.Selected.Caption])),
    cMsgBoxCaption, MB_YESNOCANCEL or MB_DEFBUTTON2 or MB_ICONQUESTION) <> id_Yes then 
    Exit;
  lvFilters.Selected.Delete;
  if not FCreating then 
    btnApply.Enabled := True;
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.lvFiltersChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
var 
  SelIndex: Integer;
begin
  if FCreating then 
    Exit;

  RemoveCustomFileFilter1.Enabled := (lvFilters.Selected <> nil) and
    (lvFilters.Selected.SubItems[1] = '1');
  btnRestFilt.Enabled := RemoveCustomFileFilter1.Enabled;
  Renamecustomfilefilter1.Enabled := RemoveCustomFileFilter1.Enabled;

  if lvFilters.Selected <> nil then 
  begin
    SelIndex := lvFilters.Selected.Index;
    IncPosition1.Enabled := Renamecustomfilefilter1.Enabled and
      (SelIndex > 0) and
      (lvFilters.Items[SelIndex - 1].SubItems[1] = '1');
    DecrementPosition1.Enabled := Renamecustomfilefilter1.Enabled and
      (SelIndex < lvFilters.Items.Count - 1);
  end 
  else 
  begin
    IncPosition1.Enabled := False;
    DecrementPosition1.Enabled := False;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.lvFiltersEditing(Sender: TObject; Item: TListItem;
  var AllowEdit: Boolean);
begin
  AllowEdit := (lvFilters.Selected <> nil) and
    (lvFilters.Selected.SubItems[1] = '1');
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.IncPosition1Click(Sender: TObject);
var 
  Capt, SI0: string;
  SelIndex: Integer;
begin
  with lvFilters do 
  begin
    Capt := Selected.Caption;
    SI0 := Selected.SubItems[0];
    SelIndex := Selected.Index;
    Selected.Caption := Items[SelIndex - 1].Caption;
    Selected.SubItems[0] := Items[SelIndex - 1].SubItems[0];
    Items[SelIndex - 1].Caption := Capt;
    Items[SelIndex - 1].SubItems[0] := SI0;
    Selected := Items[SelIndex - 1];
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.DecrementPosition1Click(Sender: TObject);
var 
  Capt, SI0: string;
  SelIndex: Integer;
begin
  with lvFilters do 
  begin
    Capt := Selected.Caption;
    SI0 := Selected.SubItems[0];
    SelIndex := Selected.Index;
    Selected.Caption := Items[SelIndex + 1].Caption;
    Selected.SubItems[0] := Items[SelIndex + 1].SubItems[0];
    Items[SelIndex + 1].Caption := Capt;
    Items[SelIndex + 1].SubItems[0] := SI0;
    Selected := Items[SelIndex + 1];
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.btnCTEditClick(Sender: TObject);
begin
  if (lvCompareTools.Selected = nil) then 
    Exit;
  VCSAddCompareTool := TVCSAddCompareTool.Create(Application);
  try
    VCSAddCompareTool.Left := Left + 40;
    VCSAddCompareTool.Top := Top + 40;
    VCSAddCompareTool.ToolName := lvCompareTools.Selected.Caption;
    VCSAddCompareTool.ToolPath := lvCompareTools.Selected.SubItems[0];
    VCSAddCompareTool.ToolParam := lvCompareTools.Selected.SubItems[1];
    VCSAddCompareTool.ShowModal;
    if VCSAddCompareTool.ToolName <> '' then 
    begin
      lvCompareTools.Selected.Caption := VCSAddCompareTool.ToolName;
      lvCompareTools.Selected.SubItems[0] := VCSAddCompareTool.ToolPath;
      lvCompareTools.Selected.SubItems[1] := VCSAddCompareTool.ToolParam;
    end;
  finally
    VCSAddCompareTool.Free;
  end;
  if not FCreating then 
    btnApply.Enabled := True;
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.btnCTAddClick(Sender: TObject);
var 
  LVItem: TListItem;
begin
  with lvCompareTools do
  begin
    LVItem := Items.Add;
    LVItem.Caption := JVCSRES_New_Diff_Tool;
    LVItem.SubItems.Add('');
    LVItem.SubItems.Add('');
    LVItem.SubItems.Add('1');
    Selected := LVItem;
    Selected.EditCaption;
  end;
  if not FCreating then 
    btnApply.Enabled := True;
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.btnCTRmvClick(Sender: TObject);
begin
  if (lvCompareTools.Selected = nil) then 
    Exit;
  if MessageBox(WindowHandle,
    PChar(Format(JVCSRES_Are_you_sure_you_want_to_remove_3437s3463, [lvCompareTools.Selected.Caption])),
    cMsgBoxCaption, MB_YESNOCANCEL or MB_DEFBUTTON2 or MB_ICONQUESTION) <> id_Yes then 
    Exit;
  lvCompareTools.Selected.Delete;
  if not FCreating then 
    btnApply.Enabled := True;
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.lvCompareToolsEditing(Sender: TObject;
  Item: TListItem; var AllowEdit: Boolean);
begin
  AllowEdit := (lvCompareTools.Selected <> nil) and
    (lvCompareTools.Selected.SubItems[2] = '1');
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.lvCompareToolsChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
begin
  if FCreating then 
    Exit;
  btnCTRmv.Enabled := (lvCompareTools.Selected <> nil) and
    (lvCompareTools.Selected.SubItems[2] = '1');
  btnCTEdit.Enabled := btnCTRmv.Enabled;
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.cbSeqBackupClick(Sender: TObject);
begin
  cbEraseSeq.Enabled := cbSeqBackup.Checked;
  spEraseDays.Enabled := cbSeqBackup.Checked;
  lOlderthan.Enabled := cbSeqBackup.Checked;
  CheckGlobalcbOption(cbSeqBackup, 15);
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.btnShowBackupsClick(Sender: TObject);
var
  SRec: TSearchrec;
  ResultString, SearchMask: string;
  OldBackups, OldBSize, i1: Integer;
begin
  ResultString := '';
  SearchMask := edBckupPath.Text + '*_???.zip';
  OldBackups := 0;
  OldBSize := 0;

  {start filecheck}
  i1 := FindFirst(SearchMask, faAnyFile and (not faDirectory), SRec);
  try
    while i1 = 0 do 
    begin
      if (SRec.Name <> '.') and (SRec.Name <> '..') then 
      begin
        ResultString := ResultString + SRec.Name + ';';
        ResultString := ResultString +
          DateTimeToStr(FileDateToDateTime(SRec.Time)) + ';';
        ResultString := ResultString + FormatFloat('#,', SRec.Size) + ';|';
        Inc(OldBackups);
        OldBSize := OldBSize + SRec.Size;
      end;{if srecname}
      i1 := FindNext(SRec);
    end;{while}
  finally
    FindClose(SRec);
  end;{try ffirst}

  Screen.Cursor := crDefault;
  if OldBackups = 0 then 
  begin
    InfoMessageBox( Format( JVCSRES_There_were_no_37s_located_that_match_the_search_criteria46
                          , [JVCSRES_files]
                          )
                  );
    Exit;
  end;

  VCSStdListView := TVCSStdListView.Create(Application);
  try
    VCSStdListView.LVRepID := 9;
    VCSStdListView.Caption := JVCSRES_Sequentiel_backup_archives;
    VCSStdListView.Left := Left + 60;
    VCSStdListView.Top := Top + 60;
    VCSStdListView.LVType := 6;
    VCSStdListView.HelpContextID := IDH_Properties_Backup;
    VCSStdListView.AddListColumn(JVCSRES_Name, False);
    VCSStdListView.AddListColumn(JVCSRES_C_Date, False);
    VCSStdListView.AddListColumn(JVCSRES_Size, True);
    VCSStdListView.SetUpItems(ResultString);
    VCSStdListView.SetUpHint(Format(JVCSRES_37s_474037n_KB_in_37d_files4641,
      [edBckupPath.Text, OldBSize / 1024, OldBackups]));
    VCSStdListView.ShowModal;
  finally
    VCSStdListView.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.cbSMTPClick(Sender: TObject);
begin
  cbMessConnect.Enabled := cbNotifyActive.Checked or cbSMTP.Checked;
  cbMessDisConnect.Enabled := cbMessConnect.Enabled;
  cbMessChkOut.Enabled := cbMessConnect.Enabled;
  cbMessChkIn.Enabled := cbMessConnect.Enabled;
  CheckGlobalcbOption(cbSMTP, 17);

  if (not cbSMTP.Checked) or (not PanelNotify.Visible) then 
    Exit;
  if CreateTargetDir(sDLLDirectory + 'SMTP\') <> 0 then 
  begin
    WarnMessageBox( Format( JVCSRES_JEDI_VCS_cannot_create_the_directory + sLineBreak + '<%s>.' + sLineBreak +
                            JVCSRES_Perhaps_there_is_already_a_folder_with_this_name_or_you + sLineBreak +
                            JVCSRES_do_not_have_the_requested_rights_for_this46
                          , [sDLLDirectory + 'SMTP\']
                          )
                  );
    cbSMTP.Checked := False;
    Exit;
  end;
  InfoMessageBox( JVCSRES_Remember_that_you_need_to_install_the_JEDI_VCS_forwarder + sLineBreak +
                  JVCSRES_34FVCSSMTP46exe34_in_order_to_send_SMTP_mail46
                );
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.cbxChkInDateChange(Sender: TObject);
begin
  if not FCreating then 
  begin
    btnApply.Enabled := True;
    if SettingIsGlobal(3) and ((cbxChkInDate.ItemIndex = 1) <> GlobalSettingValue(3)) then
      ShowGlobalSettingsWarning(WindowHandle, GlobalSettingValue(3));
  end;
end;

procedure TVCSOptions.cbxChkOutDateChange(Sender: TObject);
begin
  if not FCreating then 
  begin
    btnApply.Enabled := True;
    if SettingIsGlobal(3) and ((cbxChkOutDate.ItemIndex = 1) <> GlobalSettingValue(3)) then
      ShowGlobalSettingsWarning(WindowHandle, GlobalSettingValue(3));
  end;
end;

procedure TVCSOptions.CheckGlobalcbOption(cb: TCheckBox; Nr: Integer);
begin
  if not FCreating then 
  begin
    btnApply.Enabled := True;
    if SettingIsGlobal(Nr) and (cb.Checked <> GlobalSettingValue(Nr)) then
      ShowGlobalSettingsWarning(WindowHandle, GlobalSettingValue(Nr));
  end;
end;

procedure TVCSOptions.cbKWExpAddClick(Sender: TObject);
begin
  CheckGlobalcbOption(cbKWExpAdd, 6);
end;

procedure TVCSOptions.cbKWExpCheckInClick(Sender: TObject);
begin
  CheckGlobalcbOption(cbKWExpCheckIn, 4);
end;

procedure TVCSOptions.cbKWExpCheckOutClick(Sender: TObject);
begin
  CheckGlobalcbOption(cbKWExpCheckOut, 5);
end;

procedure TVCSOptions.cbAutoSyncClick(Sender: TObject);
begin
  CheckGlobalcbOption(cbAutoSync, 12);
end;

procedure TVCSOptions.cbEncryptDataClick(Sender: TObject);
begin
  CheckGlobalcbOption(cbEncryptData, 7);
end;

procedure TVCSOptions.cbDoBckUpClick(Sender: TObject);
begin
  CheckGlobalcbOption(cbDoBckUp, 8);
end;

procedure TVCSOptions.cbUnlockUnchangedClick(Sender: TObject);
begin
  CheckGlobalcbOption(cbUnlockUnchanged, 13);
end;

procedure TVCSOptions.cbIncludeIPCommentClick(Sender: TObject);
begin
  CheckGlobalcbOption(cbIncludeIPComment, 14);
end;

procedure TVCSOptions.cbNoROCheckClick(Sender: TObject);
begin
  CheckGlobalcbOption(cbNoROCheck, 17);
  if SettingIsGlobal(17) then 
    Exit;
  if (not FCreating) and cbNoROCheck.Checked then 
  begin
    UseRegistry := True;
    DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
    if DSAIdentsMessageDlg(Format(JVCSRES_This_is_a_potentially_dangerous_option_and_only_recommended_for + sLineBreak +
      JVCSRES_experienced_users46_Inproper_use_may_cause_data_loss33 + sLineBreak +
      JVCSRES_Please_read_the_related_help_topic_before_enabling_this_option46 + sLineBreak +
      JVCSRES_Enable_3437s34_anyway63_, [JVCSRES_Don39t_perform_RO_flag_checks])
      , mtWarning
      , [mbYes, mbNo, mbCancel]
      , 0
      , sBaseRegistryKey + crbMRU + 'Dlgs'
      , 'DontCheckRO'
      , idYes
      ) <> idYes then
      cbNoROCheck.Checked := False;
  end; // if cbDontOverwriteLocal.Checked
end;

procedure TVCSOptions.JvxAccelChange(Sender: TObject);
begin
  if not FCreating then
    edArchLimitChange(Sender);
  lblAccel.Caption := GetAcceleratedMenuName(JvxAccel.Value, True);
end;

procedure TVCSOptions.JvSearchFilesFindFile(Sender: TObject;
  const AName: string);
begin
  case FindType of
    2:
      begin // local server
        edLocalServer.Text := AName;
        JvSearchFiles.Abort;
      end;
  end; // case FindType of
end;

procedure TVCSOptions.cbCheckModuleStateClick(Sender: TObject);
begin
  if not FCreating then
    edArchLimitChange(Sender);
  speAutoRefresh.Enabled := cbAutoRefresh.Checked;
end;

procedure TVCSOptions.cbUseFileStorageClick(Sender: TObject);
begin
  if not FCreating then
  begin
    BeepIfSet;
    if MessageBox(WindowHandle,
      PChar(JVCSRES_Are_you_really_sure_to_change_the_configuration_storage_method63 + sLineBreak + sLineBreak +
      JVCSRES_You_will_loose_all_settings44_MRU_lists_and_stored_window_positions47sizes33 + sLineBreak +
      JVCSRES_This_change_will_not_take_effect_until_you_restart_the_application46),
      cMsgBoxCaption, MB_YESNOCANCEL or MB_DEFBUTTON2 or MB_ICONWARNING) <> id_Yes then
    begin
      cbUseFileStorage.OnClick := nil;
      cbUseFileStorage.Checked := not cbUseFileStorage.Checked;
      cbUseFileStorage.OnClick := cbUseFileStorageClick;
      Exit;
    end;
    edArchLimitChange(Sender);
  end;
end;

procedure TVCSOptions.edRWSButtonClick(Sender: TObject);
begin
  with edRWS do
  begin
    DialogTitle := Format(JVCSRES_Select_editor_for_37s_files, [JVCSRES_resource]);
    DialogOptions := [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing];
    Filter := JVCSRES_Programs_404246exe594246com594246bat411244246exe594246com594246bat124All_files_4042464241124424642;
  end;
end;

procedure TVCSOptions.edBMPButtonClick(Sender: TObject);
begin
  with edRWS do
  begin
    DialogTitle := Format(JVCSRES_Select_editor_for_37s_files, [JVCSRES_bitmap]);
    DialogOptions := [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing];
    Filter := JVCSRES_Programs_404246exe594246com594246bat411244246exe594246com594246bat124All_files_4042464241124424642;
  end;
end;

procedure TVCSOptions.edTxtButtonClick(Sender: TObject);
begin
  with edTxt do
  begin
    DialogTitle := Format(JVCSRES_Select_editor_for_37s_files, [JVCSRES_text]);
    DialogOptions := [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing];
    Filter := JVCSRES_Programs_404246exe594246com594246bat411244246exe594246com594246bat124All_files_4042464241124424642;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSOptions.edUserEditButtonClick(Sender: TObject);
begin
  with edUserEdit do
  begin
      DialogTitle := Format(JVCSRES_Select_editor_for_37s_files, [JVCSRES_user_defined]);
      DialogOptions := [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing];
      Filter := JVCSRES_Programs_404246exe594246com594246bat411244246exe594246com594246bat124All_files_4042464241124424642;
  end;
end;

procedure TVCSOptions.cbpromptfMemoClick(Sender: TObject);
begin
  if not FCreating then 
  begin
    btnApply.Enabled := True;
    cbMemoRequired.Enabled := cbpromptfMemo.Checked;
    if not cbMemoRequired.Enabled then
      cbMemoRequired.Checked := False;
  end;
end;

end.
