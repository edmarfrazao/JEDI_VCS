(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JEDIVCSDLL.DPR

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS: Thomas Huber (Thomas_D_Huber@t-online.de)

Components and code which are used in this sources are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
Feb/03:
- connect in IDE-expert actually not working
- some messages appear empty
ToDo
- unify handling to access registry (THe: Done)
- replace strings.res => resource strings
- replace dfs component package with JVCL
- replace zip14 with ?nanozip?
- test with different compiler defines
- test, test, test
ToDo
- validate if FastMM can be used inside IDE without using FastMMs borlndmm replacement dll
-----------------------------------------------------------------------------

Unit history:

2003/02/03  RMarquardt- created seperate dpr for IDE Expert
2003/02/08  THuber    - added credits.txt
2003/02/10  WKlein    - Bug fixed: sDLLDirectory was not initialized
2003/02/12  USchuster - changed DSAMsg with JVCSDialogs in uses clause to use JvDSADialogs
                      - D5 Fix
2003/02/18  MGosselink- Added "CheckModuleState" on menu pull-down
                        The "Check In/Put" and "Check Out" menu items will be
                        enabled/disabled according to the module checkout state.
2003/03/09  THensle   - changes for "ConfigStorage" unit
                      - removed some obsolete units in Uses clause
                        "CreateDBIArchive" (senseless, as DBISAM != standard DB)
                        "ProjectRoot" (not used for now)
                        "RegAcc" (replaced by "ConfigStorage")
                      - leave return state of TJVCSNotifier.EventNotification()
                        unchanged. Probably the cause for JvDebugExpert problems
2003/03/10  USchuster - exchanged THistoryList with TJVCSMruList (mantis #727)
2003/04/08  USchuster - changes for IDEInterface
2003/05/21  MGosselink- BugWindow added
2003/05/23  USchuster - added JVCSDockForm (necessary to open or create
                        forms inherited from TJVCSDockableForm)
                      - changed JediVCS to JEDI VCS except the accelerator
                        (has to be changed together with Options.pas)
2003/05/31  USchuster - changes for external IDE interface
2003/06/19  MGosselink- added Module History List Window (mantis #908)
2003/08/24  USchuster - added JCL Exceptionhandler
2003/08/31  USchuster - now TimeLog will only be written when sProjectName <> ''
                        (part of mantis #1095)
                      - joined TJVCSClient.CanCheckIn and CanCheckOut
                      - moved Accelerator stuff in GetMenuName to VCSProcBase.pas
                      - some fixes in JediVCSInternalInit
                      - added DllEntry because ExitProc won't be executed
                        (currently only for external IDE Interface)
2003/09/29  USchuster - fixed mantis #1131
                      - implemented new functions for external IDE Interface
                        including simplified ShortCut stuff in TJVCSClient.GetVerb
                        and Keyboard hook will now only installed when the
                        IDE Interface doesn't support ShortCut's
                      - VCSProjAdmin is now destroyed in LibExit
2003/10/16  PJurik    - Some bug corrections for C++ Builder
                        (I updated functions DoCheckInSingle and DoCheckOutSingle
                         where I make a operations for .dfm and .h too)
2003/10/22  THuber    - paths of JVCSIDE... units added
2003/10/27  USchuster - changed location of TZHandling.pas
                      - compiler hints & warnings
2003/11/11  FHasovic  - added new unit ..\common\D7ComboBoxStringsGetPatch.pas which
                        fixes Delphi 7 bug:
                        Problem: Selecting an empty string in TComboBox component will cause
        Access Violation on some systems. See details in Quality Central report
        #2246.
      Description: On some systems (Windows 2000 SP3) it will cause Access
                          Violation in ntdll.dll for an empty string item.
2003/11/30  USchuster - fixed checkin/out from FormEditor (mantis #1237)
                        (Petr compile with the additional define PJBCBFIX !)
2003/12/04  USchuster - added ClientObjects units                        
2003/12/27  THuber    - added JVCSClientFunctions to uses
                      - removed pchar casting in trace calls
2003/12/27  USchuster - added new units
                      - compare directories will now be cleaned on startup (mantis #1272)
                      - removed version from Aboutmenuitem
2003/12/30  USchuster - improved speed of module state check
                      - minor style cleaning (comments)
2004/01/08  USchuster - added new units
                      - minor style cleaning (comments) 
2004/05/31  FHasovic  - removed dependency on D7ComboBoxStringsGetPatch.pas
                        (see 2003/11/11). It's not needed anymore with Delphi 7 SP1.
2004/07/10  USchuster - fix for GPF in ntdll.dll on IDE shutdown (mantis #1938)
                        (ProjAdmin was destructed after the finalization of JVCSInterfaces.pas
                         and thatswhy the access to RefreshDispatcher raised the exception)
                      - minor style cleaning (casing and IFDEF'S)
2004/07/14  USchuster - added init/deinit of WakeMainThread handler (mantis #1964)
2004/10/30  USchuster - res strings and displayed strings changed to resourcestrings
2004/11/03  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC1 was released ^^^^^^^^^^^^^^^^^^^^^^^^^^
2005/01/06  THuber    #1704: prevent checkin/checkout from deleted projects
                             and disable projadmin
2005/02/27  THuber    detection of used IDE now over JVCSIDESettings
2005/02/27  USchuster - changed TDataModule1 creation and destruction
                        (mantis #2621; from now on it will be created on startup and
                         destroyed on unload similar as in the standalone version)
                      - changed to use InitAndOpenConfigStorage, BuildShortCut and
                        ReadShortcutsFromStorage from VCSProcBase instead of local
                        implementations
                      - fixed TJVCSClient.DoSync/"Create from DB"(was broken since
                        changes for #1704 on 2005/01/06)
                      - minor changes(IDE name and extensions) for C# Builder IDE
2005/02/27  THuber    - include credits.txt was from wrong location
2005/04/10  CSchuette - fixed ShowDebugMsg initialization
                      - some changes in finalization when compiles as external dll
                      - added Project Manager close when project is closed (only
                        way to fix mantis #2836)
2005/04/14  USchuster - minor changes(IDE name and extensions) for Delphi 8(guessed)
2005/04/18  CSchuette - added missing project manager refresh after DoOpen(True)
2005/04/24  CSchuette - added new code will will resolve the current file's extension
                        with defines files families (mantis #2891)
2005/06/12  USchuster - moved shortcut reading from TJVCSClient.ConnectArchive to
                        JediVCSInternalInit to load the shortcuts earlier (mantis #2926)
2005/06/14  USchuster - changes for D2005 History tab support
2005/07/03  CSchuette - modified initialization order in JediVCSInternalInit and added call of
                        DoOpen to fix mantis #3053 and #1932
2005/07/03  USchuster - enabled D2005 History View support function in external 
                        IDE Interface version(mantis #3071)
2005/07/11  USchuster - changes for D2005 project manager menu support
2005/12/15  USchuster - enabled functions for D2005/BDS2006 Project Manager Menu integration
                        in external IDE Interface version (mantis #3368)
2005/12/21  THuber    - FastMM now default memory manager
                      - added define for FastMM as IDE DLLs with exception of
                        JvcsExternalDll.Dll don't use FastMM due to necessary
                        use of FastMMs borlndmm.dll. As we couldn't validate this
                        for RC3 this is left open as Todo.
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC3 was released ^^^^^^^^^^^^^^^^^^^^^^^^^^
2005/12/22  THuber    - rollback to ShareMem version due to IDE crashes
2006/01/01  USchuster - changes for more flexible shortcuts (mantis #3397)
2006/01/07  USchuster - new finalization in external IDE Interface version (mantis #3422)
2006/01/08  USchuster - fixed module name preparation in TJVCSClient.GetVerb (mantis #3423)
                      - removed deprecated(still in D5) resident directive in
                        VCSManager version
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 final released ^^^^^^^^^^^^^^^^^^^^^^^^^^                        
2006/04/02  THuber    #3613 files for line history added to uses
2006/04/30  THuber    #3611 config folder now windows user dependend (appdata shell folder)
2006/04/30  USchuster - removed wrong textdiff units(library&component search paths belong into 
                        compsearch.mki, project search paths or library path of the IDE)
2006/06/05  CSchuette - added missing JVCSLineHistoryHighlighterUnit to uses
2006/12/04  USchuster - added JVCSLineHistorySettingsDialog to uses
2007/05/20  USchuster - added JVCSLanguage to uses
2007/10/26  USchuster - first changes for branching
2008/02/17  USchuster - Trace -> TraceMsg
2008/06/28  USchuster - changes for Line History frame in the IDE (RAD Studio 2007; not yet enabled)
2008/12/06  USchuster - added JVCSLabelHistory and JVCSNewClientObj to uses
2009/01/01  USchuster - added changes from jedivcs.dpr (added Winxp.res and JVCSForms)
2010/01/24  USchuster - added VCS browser unit (Mantis #5103)
                      - changes for new SelectBranch call
2014/02/26  USchuster - added compressed Diff SynEdit highlighter proxy unit

-----------------------------------------------------------------------------
 Compiler Directives:
 see also compopt.inc
 IDEDLL        : compiles to IDE expert (JEDIVCS.DLL)
 EXT_IDE_INTF  : create external IDE Interface
 DEBUG         : includes debug messages viewable in eventwindow
 JCL_DEBUG_DATA: use JCL Exceptionhandler
 REPORTDLL     : use reportdll
 BETA          : define this is a beta version
 CUSTOMDRIVE   : a first try to implement server <> client drive substituion
 DBGFILE       : write debugmessages to file DebugInfo.txt
 RELEASE       : explicitly stated as release version
 TDODEBUG      : extra Debug info in ToDo.pas
 GX_VER100_up  : use gexperts over v1.0
 PDDEBUG       : extra Debug info in Projectdependencies.pas
 UUDEBUG       : extra Debug info in usedunits.pas
 RTFREPORT     : use rtf-export in simple report

-----------------------------------------------------------------------------*)

// === THIS IS THE Delphi IDE VCS manager === //
// compile with IDEDLL in project settings    //

library JediVCSDLL;

{$I jedi.inc}
{$I compopt.inc}

{$IFDEF DELPHI6_UP}
  {$WARN UNIT_PLATFORM OFF}
  {$WARN SYMBOL_PLATFORM OFF}
{$ENDIF DELPHI6_UP}

{$IFDEF EXT_IDE_INTF}
  {$DEFINE HISTORYAPISUPPORT}
  {$DEFINE OPERATIONSSUPPORT}
{$ENDIF EXT_IDE_INTF}

{%File 'v:\projects\jedivcs\doc\common\credits.txt'}

uses
  ShareMem,
  Windows,
  Messages,
  Registry,
  Forms,
  SysUtils,
  FileCtrl,
  Classes,
  Dialogs,
  JVCSMruList,
  ShellAPI,
  Printers,
  Menus,
  {$IFNDEF EXT_IDE_INTF}
  ToolIntf,
  VCSIntf,
  {$ELSE}
  Graphics,
  {$IFDEF HISTORYAPISUPPORT}
  JVCSDLLFileHistoryImpl,
  {$ENDIF HISTORYAPISUPPORT}
  {$IFDEF OPERATIONSSUPPORT}
  JVCSDLLOperations,
  {$ENDIF OPERATIONSSUPPORT}
  {$IFDEF LINEHISTORYFRAMEEXPORT}
  JVCSDLLLineHistoryFrame,
  {$ENDIF LINEHISTORYFRAMEEXPORT}
  {$ENDIF ~EXT_IDE_INTF}
  JVCSDialogs,
  mdMailSlot,
  JclDebug,
  {$IFDEF JCL_DEBUG_DATA}
  ExceptDlg,
  {$ENDIF JCL_DEBUG_DATA}
  JclSecurity,
  JclWin32,
  JclStrings,
  ConfigStorage,
  JVCSIDEInterfaceCommon in '..\common\JVCSIDEInterfaceCommon.pas',
  JVCSIDEInterface in 'JVCSIDEInterface.pas',
  About in 'About.pas' {VCSAbout},
  Options in 'Options.pas' {VCSOptions},
  Create in 'Create.pas' {VCSLoad},
  Progress in 'Progress.pas' {VCSProgress},
  ProjAdmin in 'ProjAdmin.pas' {VCSProjAdmin},
  VCSBase in 'VCSBase.pas',
  Yes2allDlg in 'Yes2allDlg.pas' {VCSYes2AllDlg},
  UsedComponents in 'UsedComponents.pas' {VCSUsedComponents},
  UnitFilter in 'UnitFilter.pas' {VCSUnitFilter},
  MoveModules in 'MoveModules.pas' {VCSModMove},
  RemoveProj in 'RemoveProj.pas' {VCSRemoveProj},
  history in 'history.pas' {VCSHistory},
  MergeVersion in 'mergeversion.pas' {VCSMerge},
  Syncronice in 'Syncronice.pas' {VCSSync},
  todo in 'todo.pas' {VCSToDo},
  ToDoEdit in 'todoedit.pas' {VCSToDoEdit},
  touch in 'Touch.pas' {VCSTouch},
  Backup in 'Backup.pas' {VCSBackup},
  Textcomp in 'Textcomp.pas' {VCSTextCompare},
  Recent in 'Recent.pas' {VCSRecentProjects},
  Std_ListView in 'Std_ListView.pas' {VCSStdListView},
  AssignMilestones in 'AssignMilestones.pas' {VCSAssignMilestones},
  ChkInSingle in 'ChkInSingle.pas' {VCSChkInSingle},
  ChkOutSingle in 'ChkOutSingle.pas' {VCSChkOutSingle},
  ShowTimeLog in 'ShowTimeLog.pas' {VCSShowTimeLog},
  FileFamilies in 'FileFamilies.pas' {VCSFileFamilies},
  ProjDependencies in 'ProjDependencies.pas' {VCSProjectDependencies},
  VerSet in 'VerSet.pas' {VCSVerSet},
  UsedUnits in 'UsedUnits.pas' {VCSUsedUnits},
  RenameProj in 'RenameProj.pas' {VCSRenameProj},
  SelectFolder in 'SelectFolder.pas' {VCSSelectFolder},
  Branch in 'Branch.pas' {VCSBranch},
  ModuleInfo in 'moduleinfo.pas' {VCSInfo},
  CustViewFilter in 'CustViewFilter.pas' {VCSCustomViewFilter},
  HandleBlob in 'HandleBlob.pas',
  ProjectHist in 'ProjectHist.pas' {VCSProjectHistory},
  WCViewFilter in 'WCViewFilter.pas' {VCSWCViewFilter},
  DeletePH in 'DeletePH.pas' {VCSDeletePH},
  NtfySend in 'NtfySend.pas' {NtfySendForm},
  CrossRefList in 'CrossRefList.pas' {VCSSelCrossRef},
  CheckfBuild in 'CheckfBuild.pas' {VCSCheckfBuild},
  Purge in 'Purge.pas' {VCSPurge},
  ListView in 'ListView.pas' {VCSListView},
  ProjectTree in 'ProjectTree.pas' {VCSProjectTree},
  DBModule in 'DBModule.pas' {DataModule1: TDataModule},
  ChangeUserPW in 'ChangeUserPW.pas' {VCSChangeUserPW},
  MaintainUsers in 'MaintainUsers.pas' {VCSMaintainUsers},
  MaintainLabels in 'MaintainLabels.pas' {VCSMaintainLabels},
  AssignLabels in 'AssignLabels.pas' {VCSAssignLabels},
  Description in 'Description.pas' {VCSDescription},
  AddNewLabel in 'AddNewLabel.pas' {VCSAddLabel},
  SelectProjectID in 'SelectProjectID.pas' {VCSSelectProject},
  AddShareModule in 'AddShareModule.pas' {VCSAddSharedModule},
  ServerOptions in 'ServerOptions.pas' {VCSServerOptions},
  AddNewUser in 'AddNewUser.pas' {VCSAddUser},
  ToDoFilter in 'ToDoFilter.pas' {VCSToDoFilter},
  PHFilter in 'PHFilter.pas' {VCSPHistoryFilter},
  SearchModules in 'SearchModules.pas' {VCSSearchModules},
  WaitforServer in 'WaitforServer.pas' {VCSWaitforServer},
  ProjectRights in 'ProjectRights.pas' {VCSProjectRights},
  Whoami in 'Whoami.pas' {VCSWhoami},
  AddNewFamily in 'AddNewFamily.pas' {VCSAddFamily},
  MaintainFFamilies in 'MaintainFFamilies.pas' {VCSMaintainFFamilies},
  AddNewMilestone in 'AddNewMilestone.pas' {VCSAddMilestone},
  MaintainMilestones in 'MaintainMilestones.pas' {VCSMaintainMilestones},
  SelectList in 'SelectList.pas' {VCSSelectList},
  EditIP in 'EditIP.pas' {VCSEditIP},
  SelectDrive in 'SelectDrive.pas' {VCSSelectDrive},
  SimpleReport in 'SimpleReport.pas' {VCSSimpleReport},
  KWExpansion in 'KWExpansion.pas',
  MaintainBugs in 'MaintainBugs.pas' {VCSMaintainBugs},
  AddNewBug in 'AddNewBug.pas' {VCSAddBug},
  AssignBugs in 'AssignBugs.pas' {VCSAssignBugs},
  ListEdit in 'ListEdit.pas' {VCSListEdit},
  CompareFolders in 'CompareFolders.pas' {VCSCompareFolders},
  AddNewGroup in 'AddNewGroup.pas' {VCSAddNewGroup},
  TimeLogFilter in 'TimeLogFilter.pas' {VCSTLFilter},
  AddNewCompareTool in 'AddNewCompareTool.pas' {VCSAddCompareTool},
  DirectSQL in 'DirectSQL.pas' {VCSDirectSQL},
  SMTPSend in 'SMTPSend.pas',
  TZHandling in '..\common\client\TZHandling.pas',
  Plugins in 'Plugins.pas' {VCSPlugin},
  DirWatch in 'dirwatch.pas' {VCSDirWatch},
  GetGlobalSettings in 'GetGlobalSettings.pas',
  Distribution in 'Distribution.pas' {VCSDistribution},
  VCSCommon in '..\Common\vcscommon.pas',
  VCSProcBase in 'VCSProcBase.pas',
  BugWindow in 'BugWindow.pas' {VCSBugWindow},
  JVCSDockForm in 'JVCSDockForm.pas' {JVCSDockableForm},
  ModuleHistoryWindow in 'ModuleHistoryWindow.pas' {VCSModuleHistoryWindow},
  JVCSBaseAboutDialog in '..\common\JVCSBaseAboutDialog.pas' {JVCSBaseAboutDlg},
  {$IFDEF BRANCHING}
  JVCSBranchClientObj in '..\common\client\JVCSBranchClientObj.pas',
  {$ENDIF BRANCHING}
  JVCSBrowserFrame in 'JVCSBrowserFrame.pas' {JVCSBrowserFrm: TFrame},
  JVCSClasses in 'JVCSClasses.pas',
  JVCSClientConsts in '..\common\client\JVCSClientConsts.pas',
  {$IFDEF DEBUG}
  JVCSDebug in '..\common\JVCSDebug.pas',
  JVCSDebugView in '..\common\JVCSDebugView.pas',
  {$ENDIF DEBUG}
  JVCSClientDispatcher in '..\common\client\JVCSClientDispatcher.pas',
  JVCSClientFunctions in '..\common\client\JVCSClientFunctions.pas',
  JVCSClientObj in '..\common\client\JVCSClientObj.pas',
  JVCSClientObjBase in '..\common\client\JVCSClientObjBase.pas',
  JVCSConnect in '..\common\client\JVCSConnect.pas',
  JVCSCrypt in '..\common\client\JVCSCrypt.pas',
  JVCSDataClasses in 'JVCSDataClasses.pas',
  JVCSFunctions in '..\common\JVCSFunctions.pas',
  JVCSGUIClientResources in 'JVCSGUIClientResources.pas',
  JVCSLabelHistory in 'JVCSLabelHistory.pas' {VCSLabelHistory},
  {$IFDEF LANGUAGE}
  JVCSLanguage in '..\common\JVCSLanguage.pas',
  {$ENDIF LANGUAGE}
  {$IFDEF BRANCHING}
  JVCSSelectBranchDialog in 'JVCSSelectBranchDialog.pas' {JVCSSelectBranchForm},
  {$ENDIF BRANCHING}  
  JVCSThreads in '..\common\JVCSThreads.pas',
  JVCSTypes in '..\common\client\JVCSTypes.pas',
  jvcslinehistorypropertystorage in '..\common\client\jvcslinehistorypropertystorage.pas',
  JVCSLineHistoryDefaultProvider in '..\common\client\JVCSLineHistoryDefaultProvider.pas',
  JVCSCompressedDiffUnit in '..\common\client\JVCSCompressedDiffUnit.pas',
  JVCSCompressedDiffFrame in '..\common\client\JVCSCompressedDiffFrame.pas',
  JVCSCompressedDiffDialog in '..\common\client\JVCSCompressedDiffDialog.pas',
  JVCSCompressedDiffSynProxy in '..\common\client\JVCSCompressedDiffSynProxy.pas',
  JVCSLineHistoryFrame in '..\common\Client\JVCSLineHistoryFrame.pas' {JVCSLineHistoryFrm: TFrame},
  JVCSLineHistoryHighlighterUnit in '..\common\client\JVCSLineHistoryHighlighterUnit.pas',
  JVCSLineHistorySettingsDialog in '..\common\Client\JVCSLineHistorySettingsDialog.pas' {JVCSLineHistorySettingsDlg},
  JVCSLineHistoryUnit in '..\common\client\JVCSLineHistoryUnit.pas',
  JVCSNewClientObj in '..\common\client\JVCSNewClientObj.pas',
  JVCSIDESettings in '..\common\JVCSIDESettings.pas',
  JVCSForms in '..\common\JVCSForms.pas';

const
  cJediVCS = 'JEDI VCS';

type
  {  The VCS client object should be returned by the VCS Manager DLL as the
     result of the init call. Delphi is responsible for freeing the client
     object before unloading the VCS Manager DLL.                            }
  TJVCSClient = class(TIDEVCSClient)
  public
    constructor Create;
    destructor Destroy; override;

    function GetIDString: string; override;
    {  called at initialization. Client should return a unique identification
       string. The following string is reserved for Borland use:
       Borland.StdVcs                                                          }
    procedure ExecuteVerb(Index: Integer); override;
    // called when the user selects a verb from the menu
    function GetMenuName: string; override;
    {  called to retrieve the name of the main menu item to be added to the
       application's menu bar. Return a blank string to indicate no menu.      }
    function GetVerb(Index: Integer): string; override;
    {  called to retrieve the menu text for each verb. A verb may be returned
       as a blank string to create a seperator bar.                            }
    function GetVerbCount: Integer; override;
    {  called to determine the number of available verbs. This function will
       not be called of the GetMenuName function returns a blank string.       }
    function GetVerbState(Index: Integer): Word; override;
    {  called to determine the state of a particular verb. The return value
       is a bit field of various states.                                       }
    procedure ProjectChange; override;
    {  called when there is any state change of the current project, i.e.
       when a project is destroyed or created.                                 }
  private
    FModuleStateDataList: TModuleStateDataList;

    // Make the connection to the server
    procedure ConnectArchive;
    // Open the archive
    procedure DoOpen(Auto: Boolean);
    // Close an open archive
    procedure DoClose(Msg: Boolean);
    // Check out single module
    procedure DoCheckOutSingle;
    // Get single module
    procedure DoGetSingle;
    // Check in single module
    procedure DoCheckInSingle;
    // Reload an IDE file
    procedure DoReload;
    // Maintain project list
    procedure DoProjAdmin;
    // Compare source files
    procedure DoCompare;
    // Check In-Out History
    procedure DoHistory;
    // Project History
    procedure DoProjectHistory;
    // Merge & Stamp
    procedure DoMerge;
    // Synchronize
    procedure DoSync(Prompt: Boolean);
    // Branch
    procedure DoBranch;
    // ToDo List
    procedure DoToDoList;
    // Time Log
    procedure DoTimeLog;
    // Show properties
    procedure DoProperties;
    // launch online help window
    procedure DoHelp;
    // Show about form
    procedure DoShowAbout;
    // Printing & Preview
    procedure DoPrintReport;
    // Backup project files
    procedure DoBackup(Auto: Boolean);
    // Set date & time of executables
    procedure DoTouch;
    // MRU project list
    procedure DoRecentList;
    {$IFDEF BRANCHING}
    procedure OpenBranch(ANewBranchID: Integer);
    // Select Branch
    procedure DoSelectBranch;
    {$ENDIF BRANCHING}
    // Check if Module is member of cur. project
    function IsMemberOf(Module: string): Boolean;
    // Check if Module can be checked in or out
    function CanCheckInOut(AModuleName: string; ACheckIn: Boolean): Boolean;
    // Check if Module can be checked in
    function CanCheckIn(Module: string): Boolean;
    // Check if Module can be checked out
    function CanCheckOut(Module: string): Boolean;
    // Active project changed?
    procedure CheckCurrentProject;
    // Check server connection
    function CheckServerConnection: Boolean;
    // Get project ID
    function GetServerProjectID: Integer;
    // Add a new module to the current project
    function AddNewModule(ModuleName: string): Boolean;
    // Check if Verb can be executed for project relevant task.
    // set bCheckDeleted flag if execution of verb is prohibited for deleted project
    function CanExecuteVerbOnProject(const bCheckDeleted: Boolean): Boolean;
    procedure CreateDatamodule;
    procedure DestroyDatamodule;
  end;

  TJVCSNotifier = class(TIDEAddInNotifier)
  public
    procedure IDEFileNotification(NotifyCode: TIDEFileNotification;
      const FileName: string; var Cancel: Boolean); override;
    procedure IDEEventNotification(NotifyCode: TIDEEventNotification;
      var Cancel: Boolean); override;
  end;

  {$IFDEF REPORTDLL}
  TfvcsReportDLLInitProc = procedure(fApplication: TApplication;
    fScreen: TScreen);
  stdcall;
  TfvcsSelectReport = procedure(X, Y, HlpCtx, DLLProjectID, DLLTransactID,
    DLLUserID: Integer;
    DLLServer, DLLServerPort,
    DLLBaseDirectory, DLLBaseRegistryKey,
    DLLVerInfo, DLLUser: PChar);
  stdcall;
  {$ENDIF REPORTDLL}

  {$R *.res}
  {$R jvcsver.res} // DLL-Version information
  {$R strings.res} // String Resource
  {$R cursors.res} // Cursor Resource
  {$IFDEF EXT_IDE_INTF}
  {$R menuimages.res} // for external IDE Versions which supports menuimages
  {$ENDIF EXT_IDE_INTF}
  {$R \Projects\Jedivcs\src\comp\soft-gems\thememanager\Resources\winxp.res}   // Include Themingresource for WindowsXP

var
  JVCSClient: TJVCSClient = nil; // the client
  JVCSNotifier: TJVCSNotifier = nil; // the AddIn notifier
  SaveExit: Pointer = nil; // DLL exit procedure
  hKeyHook: THandle = 0; // Keyboard hook
  JVCSMutex: THandle = 0; // Mutex
  {$IFDEF EXT_IDE_INTF}
  NeedsFinalization: Boolean = False;
  {$ENDIF EXT_IDE_INTF}
  {$IFDEF REPORTDLL}
  fvcsReportDLLInitProc: TfvcsReportDLLInitProc;
  fvcsSelectReport: TfvcsSelectReport;
  {$ENDIF REPORTDLL}

//=== Exception handler (Pass the exception to Delphi) =========================

procedure HandleException(ExcType, InProc: string);
begin
  if ShowDebugMsg then
    JclDebug.TraceMsg(cPrgType + 'Core Exception: ' + ExcType + ' in ' + InProc);

  {$IFDEF JCL_DEBUG_DATA}
  ExceptDlg.TExceptionDialog.ExceptionHandler(nil, Exception(ExceptObject));
  {$ELSE}
  if Assigned(IDEInterface) then
    IDEInterface.RaiseException(ReleaseException);
  {$ENDIF JCL_DEBUG_DATA}
end;

//=== Keyboard hook procedure ==================================================

function KeyProc(nCode: Integer; wp: WParam; lp: LParam): Integer; stdcall;
var
  Handled: Boolean;
  TempShortCut: TShortCut;

  function IsShortCut(AShortCut: TShortCut; ShortCuts: array of TShortCut): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    for I := Low(ShortCuts) to High(ShortCuts) do
      if (ShortCuts[I] <> 0) and (ShortCuts[I] = AShortCut) then
      begin
        Result := True;
        Break;
      end;
  end;

begin
  if nCode >= HC_ACTION then
  begin
    Result := 0;
    TempShortCut := wp;
    if GetKeyState(VK_CONTROL) < 0 then
      Inc(TempShortCut, scCtrl);
    if GetKeyState(VK_SHIFT) < 0 then
      Inc(TempShortCut, scShift);
    if GetKeyState(VK_MENU) < 0 then
      Inc(TempShortCut, scAlt);
    if IsShortCut(TempShortCut, [cSCProjAdmin, cSCChkIn, cSCChkOut, cSCSync, cSCGet, cSCBckUp]) then
    begin // yes
      if not bSCActive then
      begin // Shortcuts already in process ?
        Handled := False;
        // Shortcut Projectmanager
        if (cSCProjAdmin <> 0) and (TempShortCut = cSCProjAdmin) then
        begin
          bSCActive := True;
          Result := 1;
          Handled := True;
          JVCSClient.DoProjAdmin;
          bSCActive := False;
        end;
        // Shortcut Check in
        if (cSCChkIn <> 0) and (TempShortCut = cSCChkIn) then
        begin
          bSCActive := True;
          // is ProjectManager the Topmost window?
          if bPJM_TopWindow then
          begin
            Result := CallNextHookEx(hKeyHook, nCode, wp, lp);
            Exit;
          end // if bPJM_TopWindow then begin
          else
          begin
            Result := 1;
            Handled := True;
            JVCSClient.DoCheckInSingle;
            bSCActive := False;
          end; // else if bPJM_TopWindow then begin
        end;
        // Shortcut Check out
        if (cSCChkOut <> 0) and (TempShortCut = cSCChkOut) then
        begin
          bSCActive := True;
          // is ProjectManager the Topmost window?
          if bPJM_TopWindow then
          begin
            Result := CallNextHookEx(hKeyHook, nCode, wp, lp);
            Exit;
          end // if bPJM_TopWindow then begin
          else
          begin
            Result := 1;
            Handled := True;
            JVCSClient.DoCheckOutSingle;
            bSCActive := False;
          end; // else if bPJM_TopWindow then begin
        end;
        // Shortcut Sync
        if (cSCSync <> 0) and (TempShortCut = cSCSync) then
        begin
          bSCActive := True;
          // is ProjectManager the Topmost window?
          if bPJM_TopWindow then
          begin
            Result := CallNextHookEx(hKeyHook, nCode, wp, lp);
            Exit;
          end // if bPJM_TopWindow then begin
          else
          begin
            Result := 1;
            Handled := True;
            JVCSClient.DoSync(False);
            bSCActive := False;
          end; // else if bPJM_TopWindow then begin
        end;
        // Shortcut Get
        if (cSCGet <> 0) and (TempShortCut = cSCGet) then
        begin
          bSCActive := True;
          // is ProjectManager the Topmost window?
          if bPJM_TopWindow then
          begin
            Result := CallNextHookEx(hKeyHook, nCode, wp, lp);
            Exit;
          end // if bPJM_TopWindow then begin
          else
          begin
            Result := 1;
            Handled := True;
            JVCSClient.DoGetSingle;
            bSCActive := False;
          end; // else if bPJM_TopWindow then begin
        end;
        // Shortcut Backup
        if (cSCBckUp <> 0) and (TempShortCut = cSCBckUp) then
        begin
          bSCActive := True;
          Result := 1;
          Handled := True;
          JVCSClient.DoBackup(False);
          bSCActive := False;
        end;
        if not Handled then
          Result := CallNextHookEx(hKeyHook, nCode, wp, lp);
      end // if not bSCActive then begin
      else
        Result := 1;
    end // if (GetKeyState(VK_CONTROL) and $8000) <> 0)...
    else
      Result := CallNextHookEx(hKeyHook, nCode, wp, lp);
  end // if nCode >= HC_ACTION then begin
  else
    Result := CallNextHookEx(hKeyHook, nCode, wp, lp);
end;

//=== Exit procedure ===========================================================

procedure LibExit;
begin
  if ShowDebugMsg then
    JclDebug.TraceMsg(cPrgType + 'LibExit');

  // Unhook Keyboard
  if hKeyHook <> 0 then
    UnhookWindowsHookEx(hKeyHook);

  // Remove Notifier
  if Assigned(IDEInterface) and Assigned(JVCSNotifier) then
    IDEInterface.RemoveNotifier(JVCSNotifier);

  //destroy projectmananager
  if Assigned(VCSProjAdmin) then
  begin
    FreeAndNil(VCSProjAdmin);
    bPJM_Created := False;
    bPJM_Valid := False;
    bPJM_NeedRefresh := False;
    bPJM_TopWindow := False;
  end;
  
  // close Storage Object
  jvcsCloseStorageObject;

  if Assigned(IDEInterface) then
    IDEInterface.Free;
  {$IFDEF EXT_IDE_INTF}
  {$IFDEF HISTORYAPISUPPORT}
  FinalizeHistory;
  {$ENDIF HISTORYAPISUPPORT}
  FreeAndNil(JVCSClient);
  {$ENDIF EXT_IDE_INTF}

  {$IFNDEF EXT_IDE_INTF}
  ExitProc := SaveExit;
  {$ENDIF ~EXT_IDE_INTF}
  if ShowDebugMsg then
    JclDebug.TraceMsg(cPrgType + 'LibExit finished');

  //???
  //Halt; // flush buffers
end;

//==============================================================================
// JVCSNotifier
//==============================================================================

procedure TJVCSNotifier.IDEFileNotification(NotifyCode: TIDEFileNotification;
  const FileName: string; var Cancel: Boolean);
var
  MRUItem, Mess: string;
  Modules: TStringList;
  OldProjects: TJVCSMruList;
  MaxCount, I: Integer;
  AutoSync, SendMessages: Boolean;
begin
  try
    try
      case NotifyCode of
        ifnProjectOpening:
          begin
            if ShowDebugMsg then
              JclDebug.TraceMsg(cPrgType + '> ifnProjectOpening ' + FileName);
            MRUItem := AnsiLowerCase(ExtractFileName(FileName));
            if (MRUItem <> ('project1.' + sIDEProject)) and
              (MRUItem <> 'projectgroup1.bpg') and
              (MRUItem <> ('package1.' + sIDEPackage)) then
            begin
              sProjectName := FileName;
              bProjectOpen := True;
              // Recent list
              MaxCount :=
                jvcsReadInteger(sBaseRegistryKey + crbOptions, 'RecentCount', 20);
              OldProjects := TJVCSMruList.Create;
              try
                OldProjects.MaxSize := MaxCount;
                OldProjects.LoadFromStorage(sBaseRegistryKey + crbMRU + '3');
                // any items to add?
                if IsIDEProject(FileName, '') or IsIDEPackage(FileName) then
                  OldProjects.AddString(AnsiLowerCase(FileName));
                if IsIDEProject(IDEInterface.GetProjectName, '') or
                  IsIDEPackage(IDEInterface.GetProjectName) then
                  OldProjects.AddString(AnsiLowerCase(IDEInterface.GetProjectName));
                if IsIDEProject(IDEInterface.GetCurrentFile, '') or
                  IsIDEPackage(IDEInterface.GetCurrentFile) then
                  OldProjects.AddString(AnsiLowerCase(IDEInterface.GetCurrentFile));
                // store recent list
                OldProjects.SaveToStorage(sBaseRegistryKey + crbMRU + '3');
              finally
                OldProjects.Free;
              end;
            end; // if AnsiLowerCase(
            if ShowDebugMsg then
              JclDebug.TraceMsg(cPrgType + '< ifnProjectOpening Ready');
          end; // ifnProjectOpening
        //----------------------------------------------------------------------
        ifnProjectOpened:
          begin
            if ShowDebugMsg then
              JclDebug.TraceMsg(cPrgType + '> ifnProjectOpened ' + FileName);
            if bPJM_Created then
              bPJM_NeedRefresh := True;
            if (not IsIDEProject(FileName, sProjectName)) and
              (not IsIDEPackage(FileName)) then
            begin
              // Backup-Modulliste in Datei ablegen
              Modules := TStringList.Create;
              try
                for I := 0 to IDEInterface.GetUnitCount - 1 do
                  Modules.Add(AnsiLowerCase(IDEInterface.GetUnitName(I)));
                for I := 0 to IDEInterface.GetFormCount - 1 do
                  Modules.Add(AnsiLowerCase(IDEInterface.GetFormName(I)));
                try
                  Modules.SaveToFile(sConfigFolder + ChangeFileExt(ExtractFileName(sProjectName), '.bkp'));
                except
                  BeepIfSet;
                  Mess := Format( JVCSRES_JEDI_VCS_cannot_save_the_file + #13#10 + '<%s>.' + #13#10 +
                                  JVCSRES_Be_sure_that_the_file_is_not_opened_by_another_application44 + #13#10 +
                                  JVCSRES_that_there_is_enough_free_space_on_the_disk + #13#10 +
                                  JVCSRES_and_that_you_have_the_required_access_rights46
                                , [sConfigFolder + ChangeFileExt(ExtractFileName(sProjectName), '.bkp')]
                                );
                  MessageBox(Application.Handle, PChar(Mess), cJediVCS,
                    MB_OK or MB_ICONSTOP);
                end;
              finally
                Modules.Free;
              end;
            end; // if AnsiLowerCase(
            if ShowDebugMsg then
              JclDebug.TraceMsg(cPrgType + '< ifnProjectOpened Ready');
          end; // ifnProjectOpened
        //----------------------------------------------------------------------
        ifnProjectClosing:
          begin
            if ShowDebugMsg then
              JclDebug.TraceMsg(cPrgType + '> ifnProjectClosing ' + FileName);
            if Assigned(VCSProjAdmin) then
            begin
              VCSProjAdmin.Hide;
              bPJM_TopWindow := False;
            end;
            if True {AnsiLowerCase(ExtractFileName(FileName)) <> 'projectgroup1.bpg'} then
            begin
              if bProjectOpen then
              begin
                bProjectOpen := False;
                ServerProjectID := -1;
                sProjectName := '';
                if bPJM_Created then
                  bPJM_NeedRefresh := True;
                bBackupEnable := True; // backup flag
                if ServerUserID > 0 then
                begin
                  if ShowDebugMsg then
                    JclDebug.TraceMsg(cPrgType + 'ifnProjectClosing - bArchiveOpen');
                  // Backup buffer
                  sBackupBuffer := IDEInterface.GetProjectName;
                end;
                // Notify
                //??? GlobalSettings
                if not SettingIsGlobal(16) then
                  SendMessages :=
                    jvcsReadBool(sBaseRegistryKey + crbOptions, 'NotifyActive', False) and
                    jvcsReadBool(sBaseRegistryKey + crbOptions, 'MessDisConnect', False)
                else
                  SendMessages := GlobalSettingValue(16);
                if SendMessages then
                begin
                  {  %d|%d|%d|%s|%s|%s|%s 162
                     Nr|PjID|UsrID|UsrName|Time|Res|Msg  }
                  SendSecureMail('*', sFVCSMailslot,
                    Format(NtfyMsgStr, [1, ServerProjectID, ServerUserID,
                    sCurrentUser, LocalDT2GMTStr(Now), LocalIPAddr,
                      '(to: All) ' + 'disconnect from: ' +
                      ExtractFileName(IDEInterface.GetProjectName)]));
                end;
                // -- SMTP --
                if jvcsReadBool(sBaseRegistryKey + crbOptions, 'SMTPMessages', False) and
                  jvcsReadBool(sBaseRegistryKey + crbOptions, 'MessDisConnect', False) then
                  PrepareSMTP(sCurrentUser, LocalIPAddr, '*All*', 'FVCS Notify',
                    ExtractFileName(IDEInterface.GetProjectName), 'disconnect from: ' +
                    ExtractFileName(IDEInterface.GetProjectName), 2);
                // -- SMTP --
                // Time log
                if jvcsReadBool(sBaseRegistryKey + crbTimeLog,
                  ExtractFileName(IDEInterface.GetProjectName), False) then
                  WriteTimeLog( sConfigFolder + ChangeFileExt(ExtractFileName(IDEInterface.GetProjectName), '.tlg')
                              , 'close;' + sCurrentUser + ';' + FloatToStr(Now)
                              );
              end; // if bProjectOpen then begin
            end; // if AnsiLowerCase(ExtractFileName(FileName)) <> ...
            if ShowDebugMsg then
              JclDebug.TraceMsg(cPrgType + '< ifnProjectClosing Ready');
          end; // ifnProjectClosing :
        //----------------------------------------------------------------------
        ifnAddedToProject:
          begin
            if ShowDebugMsg then
              JclDebug.TraceMsg(cPrgType + '> ifnAddedToProject ' + FileName);
            if bPJM_Created then
              bPJM_NeedRefresh := True;
          end; // ifnAddedToProject :
        //----------------------------------------------------------------------
        ifnRemovedFromProject:
          begin
            if ShowDebugMsg then
              JclDebug.TraceMsg(cPrgType + '> ifnRemovedFromProject ' + FileName);
            if bPJM_Created then
              bPJM_NeedRefresh := True;
          end;
        //----------------------------------------------------------------------
        ifnProjectDesktopLoad:
          begin
            if ShowDebugMsg then
              JclDebug.TraceMsg(cPrgType + '> ifnProjectDesktopLoad ' + FileName);
            if Assigned(VCSProjAdmin) then
            begin
              VCSProjAdmin.Hide;
              bPJM_TopWindow := False;
            end;
            //??? GlobalSettings
            if not SettingIsGlobal(16) then
              SendMessages :=
                jvcsReadBool(sBaseRegistryKey + crbOptions, 'NotifyActive', False) and
                jvcsReadBool(sBaseRegistryKey + crbOptions, 'MessConnect', False)
            else
              SendMessages := GlobalSettingValue(16);
            if SendMessages then
            begin
              {  %d|%d|%d|%s|%s|%s|%s 162
                 Nr|PjID|UsrID|UsrName|Time|Res|Msg  }
              SendSecureMail('*', sFVCSMailslot,
                Format(NtfyMsgStr, [1, ServerProjectID, ServerUserID,
                sCurrentUser, LocalDT2GMTStr(Now), LocalIPAddr,
                  '(to: All) ' + 'connected to: ' +
                  ExtractFileName(IDEInterface.GetProjectName)]));
            end;
            // -- SMTP --
            if jvcsReadBool(sBaseRegistryKey + crbOptions, 'SMTPMessages', False) and
              jvcsReadBool(sBaseRegistryKey + crbOptions, 'MessConnect', False) then
              PrepareSMTP(sCurrentUser, LocalIPAddr, '*All*', 'FVCS Notify',
                ExtractFileName(IDEInterface.GetProjectName), 'connected to: ' +
                ExtractFileName(IDEInterface.GetProjectName), 1);
            // -- SMTP --
            // Time log
            if jvcsReadBool(sBaseRegistryKey + crbTimeLog,
              ExtractFileName(IDEInterface.GetProjectName), False) then
              WriteTimeLog( sConfigFolder + ChangeFileExt(ExtractFileName(IDEInterface.GetProjectName), '.tlg')
                          , 'open;' + sCurrentUser + ';' + FloatToStr(Now)
                          );
            // Autosync
            if ShowDebugMsg then
            begin
              JclDebug.TraceMsg(cPrgType + 'Autosync/ServerUserID ' + IntToStr(ServerUserID));
              if bProjectOpen then
                JclDebug.TraceMsg(cPrgType + 'Autosync/bProjectOpen true')
              else
                JclDebug.TraceMsg(cPrgType + 'Autosync/bProjectOpen false');
            end;
            if (ServerUserID > 0) and bProjectOpen then
            begin
              if not SettingIsGlobal(12) then
                AutoSync :=
                  jvcsReadBool(sBaseRegistryKey + crbOptions, 'AutoSync', False)
              else
                AutoSync := GlobalSettingValue(12);
              if AutoSync then
              begin
                if ShowDebugMsg then
                  JclDebug.TraceMsg(cPrgType + '< ifnProjectDesktopLoad Autosync');
                // JEDI VCS Project?
                JVCSClient.DoSync(True);
              end; // if AutoSync then begin
            end; // if (ServerUserID > 0) and bProjectOpen then begin
            if ShowDebugMsg then
              JclDebug.TraceMsg(cPrgType + '< ifnProjectDesktopLoad Ready');
          end; // ifnProjectDesktopLoad
        //----------------------------------------------------------------------
        ifnProjectDesktopSave:
          begin
            if ShowDebugMsg then
            begin
              JclDebug.TraceMsg(cPrgType + '> ifnProjectDesktopSave ' + FileName);
              JclDebug.TraceMsg(cPrgType + 'IDEInterface.GetProjectName: ' + IDEInterface.GetProjectName);
            end;
            if Assigned(VCSProjAdmin) then
            begin
              VCSProjAdmin.Hide;
              bPJM_TopWindow := False;
            end;
          end; // ifnprojectDesktopSave
        //----------------------------------------------------------------------
        ifnDefaultDesktopLoad:
          begin
            {if ShowDebugMsg then
              JclDebug.TraceMsg(PChar(cPrgType  + '> ifnDefaultDesktopLoad ' +
                FileName + #0));}
          end; // ifnDefaultDesktopLoad
        //----------------------------------------------------------------------
        ifnDefaultDesktopSave:
          begin
            {if ShowDebugMsg then
              JclDebug.TraceMsg(PChar(cPrgType  + '> ifnDefaultDesktopSave ' +
                FileName + #0));}
          end; // ifnDefaultDesktopSave
        //----------------------------------------------------------------------
        ifnFileOpening:
          begin
            {if ShowDebugMsg then
              JclDebug.TraceMsg(PChar(cPrgType  + '> ifnFileOpening ' +
                FileName + #0));}
          end; // ifnFileOpening
        //----------------------------------------------------------------------
        ifnFileOpened:
          begin
            {if ShowDebugMsg then
              JclDebug.TraceMsg(PChar(cPrgType  + '> ifnFileOpened ' +
                FileName + #0));}
          end; // ifnFileOpened
        //----------------------------------------------------------------------
        ifnFileClosing:
          begin
            {if ShowDebugMsg then
              JclDebug.TraceMsg(PChar(cPrgType  + '> ifnFileClosing ' +
                FileName + #0));}
          end; // ifnFileClosing
      end; // case NotifyCode of
    finally
      Cancel := False; // Better not cancel such operations!
    end;
  except
    on E:
    Exception do
      HandleException(E.Message, 'FileNotification');
  end;
end;

//------------------------------------------------------------------------------

procedure TJVCSNotifier.IDEEventNotification(NotifyCode: TIDEEventNotification;
  var Cancel: Boolean);
begin
  try
    try
      case NotifyCode of
        //----------------------------------------------------------------------
        ienBeforeCompile:
          begin
            if bProjectOpen and
              jvcsReadBool(sBaseRegistryKey + crbProjects + ExtractFileName(sProjectName),
              'VerInfoHandle', False) then
              PrepareResFileInfo(sProjectName);
          end; // ienBeforeCompile
        //----------------------------------------------------------------------
        ienAfterCompile:
          begin
            if Cancel and bProjectOpen and
              jvcsReadBool(sBaseRegistryKey + crbProjects + ExtractFileName(sProjectName),
              'VerInfoHandle', False) then
              ResFileInfoIncBuild(sProjectName);
          end; // ienAfterCompile
      end; // case NotifyCode of
    finally
      // maybe this was the cause for JvDebugExpert problems?
      // try to leave Cancel unchanged...
      //Cancel := False;
    end;
  except
    on E:
    Exception do
      HandleException(E.Message, 'EventNotification');
  end;
end;

//==============================================================================
// JVCSClient
//==============================================================================

constructor TJVCSClient.Create;
begin
  inherited Create;
  FModuleStateDataList := TModuleStateDataList.Create;
  InitWakeMainThreadHandler;
end;

destructor TJVCSClient.Destroy;
begin
  //destroy projectmananager (fix for mantis #1938)
  if Assigned(VCSProjAdmin) then
  begin
    FreeAndNil(VCSProjAdmin);
    bPJM_Created := False;
    bPJM_Valid := False;
    bPJM_NeedRefresh := False;
    bPJM_TopWindow := False;
  end;
  DestroyDatamodule;
  DeInitWakeMainThreadHandler;
  FModuleStateDataList.Free;
  inherited Destroy;
end;

procedure TJVCSClient.CreateDatamodule;
begin
  // Create Datamodule
  if not Assigned(DataModule1) then
  begin
    if ShowDebugMsg then
      JclDebug.TraceMsg(cPrgType + 'Create Datamodule Start');
    DataModule1 := TDataModule1.Create(Application);

    {DataModule1.AppSrvClient1.Port := RegReadString(HKCU,
      sBaseRegistryKey + crbOptions, 'Port', '2106');
    DataModule1.AppSrvClient1.Server := RegReadString(HKCU,
      sBaseRegistryKey + crbOptions, 'Server', LocalIPAddr);}
    DataModule1.AppSrvClient1.Server :=
      jvcsReadString(sBaseRegistryKey, 'CurrentServer',  LocalIPAddr);
    DataModule1.AppSrvClient1.Port :=
      jvcsReadString(sBaseRegistryKey, 'CurrentPort', '2106');

    if ShowDebugMsg then
      JclDebug.TraceMsg(cPrgType + 'Create Datamodule Ready');
  end;
end;

procedure TJVCSClient.DestroyDatamodule;
begin
  // Free Datamodule
  if Assigned(DataModule1) then
  begin
    if ShowDebugMsg then
      JclDebug.TraceMsg(cPrgType + 'Free Datamodule Start');
    DataModule1.AppSrvClient1.Close;
    DataModule1.Free;
    DataModule1 := nil;
    if ShowDebugMsg then
      JclDebug.TraceMsg(cPrgType + 'Free Datamodule Ready');
  end;
end;

procedure TJVCSClient.ConnectArchive;
begin
  try
    // User & machine name
    if sCurrentUser = '' then
    begin
      if ShowDebugMsg then
        JclDebug.TraceMsg(cPrgType + 'ConnectArchive - SetUpUserInfo');
      SetUpUserInfo;
      // Working area
      SystemParametersInfo(SPI_GETWORKAREA, 0, @trResDesktop, 0);
    end; // if sCurrentUser = '' then begin
    // Archive connect
    if bProjectOpen and (ServerUserID < 1) and (not bGoWithout) and
      (not bOpenformActive) then
    begin
      if ShowDebugMsg then
        JclDebug.TraceMsg(cPrgType + 'ConnectArchive - CheckForDoOpen');
      if jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowLoad', False) then
      begin
        if ShowDebugMsg then
          JclDebug.TraceMsg(cPrgType + 'ConnectArchive - DoOpen(true)');
        DoOpen(True);
      end;
    end; // if not bArchiveOpen then begin
  except
    on E:
    Exception do
      HandleException(E.Message, 'ConnectArchive');
  end;
end;

// === Check if connection is established and project is open
function TJVCSClient.CanExecuteVerbOnProject(const bCheckDeleted: Boolean): Boolean;
begin
  JclDebug.TraceMsg('> CanExecuteVerbOnProject');
  Result := False;
  if not CheckServerConnection then
    Exit;
  CheckCurrentProject;
  if ServerProjectID < 1 then
  begin
    ServerProjectID := GetServerProjectID;
    if ServerProjectID < 1 then
      Exit;
  end;
  if bCheckDeleted and bProjectDeleted then
  begin
    MessageBox( Application.Handle
              , PChar(Format(JVCSRES_Project_37s_is_deleted_in_VCS33,[ExtractFileName(sProjectName)]) +AnsiCrLf +
                JVCSRES_Selected_action_is_not_permitted_for_deleted_projects46)
              , cJediVCS
              , MB_OK + MB_ICONERROR
              );
    Exit;
  end;
  Result := True;
  JclDebug.TraceMsg('CanExecuteVerbOnProject <');
end;

//=== Open a new archive =======================================================

procedure TJVCSClient.DoOpen(Auto: Boolean);
var
  DisclAccepted: Boolean;
begin
  try
    {$IFDEF BETA}
    if cBetaDateTime < Now then
    begin
      Windows.Beep(500, 250);
      Windows.MessageBox(0, PChar(JVCSRES_This_is_an_outdated_Beta_version33),
        PChar(Format(JVCSRES_37s_Beta_version, [cJediVCS])), MB_OK or MB_ICONSTOP);
      bGoWithout := True;
      Exit;
    end // if cBetaDateTime < Now then begin
    else
    begin
      UseRegistry := True;
      DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
      DSAIdentsMessageDlg(Format(JVCSRES_Beta_37s + #13#10 +
        JVCSRES_This_is_a_beta_version_for_test_and_debug_purposes33 + #13#10 +
        JVCSRES_Do_NOT_publish_or_distribute_this_version33 + #13#10 +
        JVCSRES_This_version_expires_after_37s33, [cBetaVer,
        DateTimeToStr(cBetaDateTime)]), mtWarning, [mbOK],
        0, sBaseRegistryKey + crbMRU + 'Dlgs', 'Beta', idOk);
    end; // if cBetaDateTime < Now then begin
    {$ELSE}
    DSAIdentsClear(sBaseRegistryKey + crbMRU + 'Dlgs', 'Beta');
    {$ENDIF BETA}

    // About dialog - one time

    if not jvcsReadBool(cRegSwJVCSBase, 'AcceptDisclaimer', False) then
    begin
      VCSAbout := TVCSAbout.Create(Application); // unit About
      try
        VCSAbout.AcceptDlg := True;
        VCSAbout.ShowModal;
        DisclAccepted := VCSAbout.Accepted;
      finally
        VCSAbout.Free;
      end;
      jvcsWriteBool(cRegSwJVCSBase, 'AcceptDisclaimer', DisclAccepted);
    end; // if not RegReadBool(

    bOpenformActive := True;
    bACheck := False; // check archive flag

    VCSLoad := TVCSLoad.Create(Application);
    try
      VCSLoad.ShowModal;
    finally
      VCSLoad.Free;
    end;
    bOpenformActive := False;
    
    if bPJM_Created then
      bPJM_NeedRefresh := True;
  except
    on E:
    Exception do
      HandleException(E.Message, 'DoOpen');
  end;
end;

//=== Close an open archive ====================================================

procedure TJVCSClient.DoClose(Msg: Boolean);
var
  ServerLoc: string;
  SendMessages: Boolean;
begin
  try
    // Close ProjectManager if open
    if Assigned(VCSProjAdmin) then
    begin
      VCSProjAdmin.Close;
      VCSProjAdmin.Free;
      VCSProjAdmin := nil;
      bPJM_Created := False;
      bPJM_Valid := False;
      bPJM_NeedRefresh := False;
      bPJM_TopWindow := False;
    end;

    // Backup after closing a project
    if bProjectOpen then
      DoBackup(True);
    bBackupEnable := False;
    //??? GlobalSettings
    if not SettingIsGlobal(16) then
      SendMessages :=
        jvcsReadBool(sBaseRegistryKey + crbOptions, 'NotifyActive', False) and
        jvcsReadBool(sBaseRegistryKey + crbOptions, 'MessDisConnect', False)
    else
      SendMessages := GlobalSettingValue(16);
    if SendMessages then
    begin
      ServerLoc :=
        jvcsReadString(sBaseRegistryKey, 'CurrentServer',  LocalIPAddr);
      {  %d|%d|%d|%s|%s|%s|%s 162
         Nr|PjID|UsrID|UsrName|Time|Res|Msg  }
      SendSecureMail('*', sFVCSMailslot,
        Format(NtfyMsgStr, [1, ServerProjectID, ServerUserID, sCurrentUser,
        LocalDT2GMTStr(Now), LocalIPAddr,
          '(to: All) ' + 'disconnect from application server [' + ServerLoc + ']']));
    end;
    // -- SMTP --
    if jvcsReadBool(sBaseRegistryKey + crbOptions, 'SMTPMessages', False) and
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'MessDisConnect', False) then
      PrepareSMTP(sCurrentUser, LocalIPAddr, '*All*', 'FVCS Notify', '*None*',
        'disconnect from application server [' + ServerLoc + ']', 2);
    // -- SMTP --
    // Time log
    if (sProjectName <> '') and jvcsReadBool(sBaseRegistryKey + crbTimeLog,
      ExtractFileName(sProjectName), False)
    then
      WriteTimeLog( sConfigFolder + ChangeFileExt(ExtractFileName(sProjectName), '.tlg')
                  , 'close;' + sCurrentUser + ';' + FloatToStr(Now)
                  );

    // Logout User
    try
      with DataModule1 do
      begin
        VCSWaitforServer := TVCSWaitforServer.Create(Application);
        try
          VCSWaitforServer.Show;
          AppSrvClient1.Request.Rewrite;
          AppSrvClient1.FunctionCode := 'LOGOUT';
          AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
          AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
          AppSrvClient1.Request.WriteFields(True, [ServerUserID]);
          SetupTimeoutCounter;
          AppSrvClient1.Send;
          while WaitForAppSrvClient do
            Application.ProcessMessages;
        finally
          VCSWaitforServer.Free;
        end;
      end; // with DataModule1 do begin

      DataModule1.AppSrvClient1.Close;
      FModuleStateDataList.Clear;
      JclDebug.TraceMsg('After FModuleStateDataList.Clear'); //todo - now
    finally
      TransactionNr := -1;
      ServerUserID := -1;
    end;

    if Msg then
    begin
      UseRegistry := True;
      DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
      DSAIdentsMessageDlg(JVCSRES_Connection_closed46 + #13#10 +
        JVCSRES_You_must_reopen_the_connection_to_make_JEDI_VCS39s_functions_available46,
        mtInformation, [mbOK],
        0, sBaseRegistryKey + crbMRU + 'Dlgs', 'CloseA', idOk);
    end;
  except
    on E:
    Exception do
      HandleException(E.Message, 'DoClose');
  end;
end;

//------------------------------------------------------------------------------

procedure TJVCSClient.DoProjAdmin;
begin
  try
    // Check server connection and project ID
    if not CheckServerConnection then
      Exit;
    CheckCurrentProject;
    //------------------------------------------

    if Assigned(VCSProjAdmin) then
      VCSProjAdmin.Show
    else
    begin
      Assert(VCSProjAdmin = nil, 'TJVCSClient.DoProjAdmin');
      VCSProjAdmin := TVCSProjAdmin.Create(Application); // unit ProjAdmin
      try
        bPJM_Created := True;
        bPJM_NeedRefresh := False;
        VCSProjAdmin.Show;
      except
        VCSProjAdmin.Free;
        VCSProjAdmin := nil;
        bPJM_Created := False;
        bPJM_Valid := False;
        bPJM_NeedRefresh := False;
        bPJM_TopWindow := False;
      end;
    end; // else if ProjManVisible then begin
  except
    on E:
    Exception do
      HandleException(E.Message, 'DoProjAdmin');
  end;
end;

//=== Show properties ==========================================================

procedure TJVCSClient.DoProperties;
begin
  try
    VCSOptions := TVCSOptions.Create(Application); // unit Options
    try
      VCSOptions.DefaultSheet := cspInterface;
      VCSOptions.ShowModal;
    finally
      VCSOptions.Free;
    end;
  except
    on E:
    Exception do
      HandleException(E.Message, 'DoProperties');
  end;
end;

//=== Check in single module ===================================================

procedure TJVCSClient.DoCheckInSingle;
var
  CurrentFile: string;
  SelectedFileList: TStringList;
  I: Integer;
begin
  try
    SelectedFileList := TStringList.Create;
    try
      // Check server connection and project ID
      if not CanExecuteVerbOnProject(True) then
        Exit;
      //------------------------------------------

      CurrentFile := AnsiLowerCase(IDEInterface.GetCurrentFile);
      ResolveFileFamilies(CurrentFile);

      if SelectedFileList.IndexOf(CurrentFile) = -1 then
        SelectedFileList.Add(AnsiLowerCase(CurrentFile));

      for I := 0 to SelectedFileList.Count - 1 do
      begin
        CurrentFile := SelectedFileList[I];
        // Testen, ob aktuelles Modul zu Projekt gehört
        if not IsMemberOf(CurrentFile) then
        begin
          if ServerUserID < 0 then
            Exit;
          BeepIfSet;
          if MessageBox(Application.Handle,
            PChar(Format(JVCSRES_6037s62_is_not_a_member_of_the_current_VC_project_6037s6246 + #13#10 +
              JVCSRES_You_cannot_access_the_module_from_here46, [ExtractFileName(CurrentFile),
            ExtractFileName(sProjectName)]) + #13#10 + JVCSRES_Add_the_module_to_the_current_VC_project63),
              PChar(Format(JVCSRES_37s_Check_In, [cJediVCS])), MB_YESNOCANCEL or MB_ICONQUESTION) <> idYes then
            Exit;
          // Yes -> try to add the file
          if not AddNewModule(CurrentFile) then
            Exit;
          // projectmanager needs refresh
          if bPJM_Created then
            bPJM_NeedRefresh := True;
        end; // if not IsMemberOf(
      end;

      VCSChkInSingle := TVCSChkInSingle.Create(Application);
      try
        VCSChkInSingle.SelectModuleList.Assign(SelectedFileList);
        VCSChkInSingle.ShowModal;
      finally
        VCSChkInSingle.Free;
      end;
    finally
      SelectedFileList.Free;
    end;
  except
    on E:
    Exception do
      HandleException(E.Message, 'DoCheckInSingle');
  end;
end;

//=== Check Out single module ==================================================

procedure TJVCSClient.DoCheckOutSingle;
var
  CurrentFile: string;
  SelectedFileList: TStringList;
  I: Integer;
begin
  try
    SelectedFileList := TStringList.Create;
    try
      // Check server connection and project ID
      if not CanExecuteVerbOnProject(True) then
        Exit;
      //------------------------------------------

      CurrentFile := AnsiLowerCase(IDEInterface.GetCurrentFile);
      ResolveFileFamilies(CurrentFile);

      if SelectedFileList.IndexOf(CurrentFile) = -1 then
        SelectedFileList.Add(AnsiLowerCase(CurrentFile));

      for I := 0 to SelectedFileList.Count - 1 do
      begin
        CurrentFile := SelectedFileList[I];
        // Testen, ob aktuelles Modul zu Projekt gehört
        if not IsMemberOf(CurrentFile) then
        begin
          if ServerUserID < 0 then
            Exit;
          BeepIfSet;
          if MessageBox(Application.Handle,
            PChar(Format(JVCSRES_6037s62_is_not_a_member_of_the_current_VC_project_6037s6246 + #13#10 +
            JVCSRES_You_cannot_access_the_module_from_here46, [ExtractFileName(CurrentFile),
            ExtractFileName(sProjectName)]) + #13#10 + JVCSRES_Add_the_module_to_the_current_VC_project63),
              PChar(Format(JVCSRES_37s_Check_Out, [cJediVCS])), MB_YESNOCANCEL or MB_ICONQUESTION) <> idYes then
            Exit;
          // Yes -> Add the file
          if not AddNewModule(CurrentFile) then
            Exit;
          // projectmanager needs refresh
          if bPJM_Created then
            bPJM_NeedRefresh := True;
        end; // if not IsMemberOf(
      end;

      VCSChkOutSingle := TVCSChkOutSingle.Create(Application);
      try
        VCSChkOutSingle.SelectModuleList.Assign(SelectedFileList);
        VCSChkOutSingle.ShowModal;
      finally
        VCSChkOutSingle.Free;
      end;

      {$IFDEF PJBCBFIX}
      if bIsCppBuilder then
      begin
        for I := 0 to SelectedFileList.Count - 1 do
        begin
          CurrentFile := SelectedFileList[I];
          if IDEInterface.IsFileOpen(CurrentFile) then
            IDEInterface.CloseFile(CurrentFile);
        end;

        for I := 0 to SelectedFileList.Count - 1 do
        begin
          CurrentFile := SelectedFileList[I];
          if ExtractFileExt(CurrentFile) <> '.dfm' then
            IDEInterface.OpenFile(CurrentFile);
        end;
      end;
      {$ENDIF PJBCBFIX}  
    finally
      SelectedFileList.Free;
    end;
  except
    on E:
    Exception do
      HandleException(E.Message, 'DoCheckOutSingle');
  end;
end;

//=== Get single module ========================================================

procedure TJVCSClient.DoGetSingle;
var
  CurrentFile: string;
begin
  try
    // Check server connection and project ID
    if not CanExecuteVerbOnProject(True) then
      Exit;
    //------------------------------------------

    CurrentFile := AnsiLowerCase(IDEInterface.GetCurrentFile);
    ResolveFileFamilies(CurrentFile);

    // Testen, ob aktuelles Modul zu Projekt gehört
    if not IsMemberOf(CurrentFile) then
    begin
      if ServerUserID < 0 then
        Exit;
      BeepIfSet;
      MessageBox(Application.Handle,
        PChar(Format(JVCSRES_6037s62_is_not_a_member_of_the_current_VC_project_6037s6246 + #13#10 +
          JVCSRES_You_cannot_access_the_module_from_here46, [ExtractFileName(CurrentFile),
        ExtractFileName(sProjectName)])),
          PChar(Format(JVCSRES_37s_Get, [cJediVCS])), MB_OK or MB_ICONWARNING);
      Exit;
    end; // if not IsMemberOf(

    VCSInfo := TVCSInfo.Create(Application);
    try
      VCSInfo.ModuleID := 0;
      VCSInfo.ModuleName := CurrentFile;
      VCSInfo.GetEnabled := True;
      VCSInfo.ShowModal;
    finally
      VCSInfo.Free;
    end;
  except
    on E:
    Exception do
      HandleException(E.Message, 'DoGetSingle');
  end;
end;

//------------------------------------------------------------------------------

procedure TJVCSClient.DoReload;
var
  CurrentFile: string;
begin
  try
    CurrentFile := IDEInterface.GetCurrentFile;
    IDEInterface.CloseFile(CurrentFile);
    Sleep(100);
    IDEInterface.OpenFile(CurrentFile);
  except
    on E:
    Exception do
      HandleException(E.Message, 'DoReload');
  end;
end;

//------------------------------------------------------------------------------

procedure TJVCSClient.DoCompare;
var
  Mess: string;
begin
  try
    // Check server connection and project ID
    if not CanExecuteVerbOnProject(True) then
      Exit;
    //------------------------------------------

    // Testen, ob aktuelles Modul zu Projekt gehört
    if not IsMemberOf(IDEInterface.GetCurrentFile) then
    begin
      if ServerUserID < 0 then
        Exit;
      Mess := Format(JVCSRES_6037s62_is_not_a_member_of_the_current_VC_project46 + #13#10 +
        JVCSRES_Continue_anyway63, [ExtractFileName(IDEInterface.GetCurrentFile)]);
      UseRegistry := True;
      DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
      if DSAIdentsMessageDlg(Mess
        , mtInformation
        , [mbOK, mbCancel]
        , 0
        , sBaseRegistryKey + crbMRU + 'Dlgs'
        , 'FNMComp'
        , idOk
        ) <> idOk then
        Exit;
    end; // if not IsMemberOf(
    // Read-Only?
    if not ((FileGetAttr(IDEInterface.GetCurrentFile) and $00000001) = $00000001) then
      IDEInterface.SaveFile(IDEInterface.GetCurrentFile);

    VCSTextCompare := TVCSTextCompare.Create(Application);
    try
      VCSTextCompare.ShowModal;
    finally
      VCSTextCompare.Free;
    end;
  except
    on E:
    Exception do
      HandleException(E.Message, 'DoCompare');
  end;
end;

//=== History ==================================================================

procedure TJVCSClient.DoHistory;
begin
  try
    // Check server connection and project ID
    if not CanExecuteVerbOnProject(True) then
      Exit;
    //------------------------------------------

    VCSHistory := TVCSHistory.Create(Application);
    try
      VCSHistory.ShowModal;
    finally
      VCSHistory.Free;
    end;
  except
    on E:
    Exception do
      HandleException(E.Message, 'DoHistory');
  end;
end;

//------------------------------------------------------------------------------

procedure TJVCSClient.DoProjectHistory;
begin
  try
    // Check server connection and project ID
    if not CanExecuteVerbOnProject(False) then
      Exit;
    //------------------------------------------

    VCSProjectHistory := TVCSProjectHistory.Create(Application);
    try
      VCSProjectHistory.ShowModal;
    finally
      VCSProjectHistory.Free;
    end;
  except
    on E:
    Exception do
      HandleException(E.Message, 'DoProjectHistory');
  end;
end;

//------------------------------------------------------------------------------

procedure TJVCSClient.DoMerge;
begin
  try
    // Check server connection and project ID
    if not CanExecuteVerbOnProject(True) then
      Exit;
    //------------------------------------------

    VCSMerge := TVCSMerge.Create(Application);
    try
      VCSMerge.ShowModal;
    finally
      VCSMerge.Free;
    end;
  except
    on E:
    Exception do
      HandleException(E.Message, 'DoMerge');
  end;
end;

//------------------------------------------------------------------------------

procedure TJVCSClient.DoSync(Prompt: Boolean);
begin
  try
    // Check server connection and project ID
    if (not bProjectOpen and not CheckServerConnection) or
      (bProjectOpen and not CanExecuteVerbOnProject(True)) then
      Exit;
    //------------------------------------------
    if Prompt then
    begin
      UseRegistry := True;
      DontShowMsgText := JVCSRES_38Synchronize_without_prompting_from_now_on46;
      if DSAIdentsMessageDlg(Format(JVCSRES_Synchronize_6037s62_with_the_latest_version_archive_state63,
        [ExtractFileName(sProjectName)]),
        mtConfirmation, [mbOK, mbCancel], 0, sBaseRegistryKey + crbMRU + 'Dlgs',
        'AutoSync', idOk) <> idOk then
        Exit;
    end;
    VCSSync := TVCSSync.Create(Application);
    try
      VCSSync.AutoClose := Prompt;
      VCSSync.ShowModal;
    finally
      VCSSync.Free;
    end;
  except
    on E:
    Exception do
      HandleException(E.Message, 'DoSync');
  end;
end;

//------------------------------------------------------------------------------

procedure TJVCSClient.DoBranch;
begin
  try
    // Check server connection and project ID
    if not CanExecuteVerbOnProject(True) then
      Exit;
    //------------------------------------------

    VCSBranch := TVCSBranch.Create(Application);
    try
      VCSBranch.ShowModal;
    finally
      VCSBranch.Free;
    end;
  except
    on E:
    Exception do
      HandleException(E.Message, 'DoBranch');
  end;
end;

//------------------------------------------------------------------------------

procedure TJVCSClient.DoTouch;
begin
  try
    VCSTouch := TVCSTouch.Create(Application);
    try
      VCSTouch.ShowModal;
    finally
      VCSTouch.Free;
    end;
  except
    on E:
    Exception do
      HandleException(E.Message, 'DoTouch');
  end;
end;

//------------------------------------------------------------------------------

procedure TJVCSClient.DoPrintReport;
var
  Mess, TMPDirectory: string;
  TempFiles: TStringList;
  SearchRec: TSearchRec;
  SearchBytes: int64;
  I: Integer;
  Device: string;
  DefaultPrinter: Boolean;
  {$IFDEF REPORTDLL}
  ReportDLLHandle: THandle;
  FuncPtr: TFarProc;
  VerInfo, DLLServer, DLLPort: string;
  {$ENDIF REPORTDLL}
begin
  try
    // Check server connection and project ID
    if not CanExecuteVerbOnProject(True) then
      Exit;
    //------------------------------------------

    // Default Printer vorhanden?
    DefaultPrinter := True;
    try
      with Printer do
        Device := Printers[PrinterIndex];
    except
      DefaultPrinter := False;
    end;
    if (not DefaultPrinter) or (Device = '') then
    begin
      MessageBox(Application.Handle, PChar(JVCSRES_JEDI_VCS_cannot_find_the_Windows_standard_printer46 + #13#10 +
        JVCSRES_Define_a_Windows_standard_printer_and_retry46),
        cJediVCS, MB_OK or MB_ICONWARNING);
      Exit;
    end;

    {$IFDEF REPORTDLL}
    ReportDLLHandle := 0;
    if ReportDLLHandle = 0 then
    begin
      ReportDLLHandle := LoadLibrary(PChar(sDLLDirectory + cJVCSReportDll));
      if ReportDLLHandle = 0 then
      begin
        SysUtils.Beep;
        MessageBox(Application.Handle, PChar(Format(JVCSRES_JEDI_VCS_cannot_load_the_library58 + #13#10 +
          '<%s>.' + #13#10 +
          JVCSRES_The_function_you_have_requested_requires_an_additional + #13#10 +
          JVCSRES_DLL_which_is_not_part_of_the_JEDI_VCS_standard_package46 + #13#10 +
          JVCSRES_You_can_download_this_DLL_for_free_from_JEDI_VCS_home46,
          [sDLLDirectory + cJVCSReportDll])), cJediVCS, MB_OK or MB_ICONWARNING);
        Exit;
      end;
      FuncPtr := GetProcAddress(ReportDLLHandle, 'fvcs_DLLInitProc');
      if FuncPtr <> nil then
      begin
        @fvcsReportDLLInitProc := FuncPtr;
        fvcsReportDLLInitProc(Application, Screen);
      end // if FuncPtr <> nil then begin
      else
      begin
        SysUtils.Beep;
        MessageBox(Application.Handle, PChar(Format(JVCSRES_Fatal_Error58_JEDI_VCS_cannot_find_the_external_library_procedure58 + #13#10 +
          '<%s>.' + #13#10 +
          JVCSRES_The_reason_for_this_is_usually_an_invalid_DLL_version + #13#10 +
          JVCSRES_or_the_library_could_not_be_loaded46, ['fvcs_DLLInitProc'])),
          cJVCSReportDll, MB_OK or MB_ICONSTOP);
        FreeLibrary(ReportDLLHandle);
        Exit;
      end; // else if FuncPtr <> nil then begin
    end; // if ReportDLLHandle = 0 then begin

    FuncPtr := GetProcAddress(ReportDLLHandle, 'fvcs_SelectReport');
    if FuncPtr <> nil then
    begin
      VerInfo := cJediVCS + ' ' + sProductVer + cProductInf + DateTimeToStr(Now);
      DLLServer :=
        jvcsReadString(sBaseRegistryKey, 'CurrentServer',  LocalIPAddr);
      DLLPort :=
        jvcsReadString(sBaseRegistryKey, 'CurrentPort', '2106');

      @fvcsSelectReport := FuncPtr;
      fvcsSelectReport(0, 0, IDH_Reports_Printing,
        ServerProjectID, TransactionNr, ServerUserID,
        PChar(DLLServer), PChar(DLLPort),
        PChar(sDLLDirectory), PChar(sBaseRegistryKey),
        PChar(VerInfo), PChar(sCurrentUser));
    end // if FuncPtr <> nil then begin
    else
    begin
      SysUtils.Beep;
      MessageBox(Application.Handle, PChar(Format(JVCSRES_Fatal_Error58_JEDI_VCS_cannot_find_the_external_library_procedure58 + #13#10 +
          '<%s>.' + #13#10 +
          JVCSRES_The_reason_for_this_is_usually_an_invalid_DLL_version + #13#10 +
          JVCSRES_or_the_library_could_not_be_loaded46, ['fvcs_SelectReport'])),
        cJVCSReportDll, MB_OK or MB_ICONSTOP);
      FreeLibrary(ReportDLLHandle);
      Exit;
    end; // else if FuncPtr <> nil then begin
    FreeLibrary(ReportDLLHandle);
    {$ELSE}
    VCSReport := TVCSReport.Create(Application);
    try
      VCSReport.ShowModal;
    finally
      VCSReport.Free;
    end;
    {$ENDIF REPORTDLL}

    // Temporäre Files von QRPreview
    // TMP - Verzeichnis ?
    I := 255;
    SetLength(TMPDirectory, I);
    I := GetTempPath(I, PChar(TMPDirectory));
    if I = 0 then
      Exit; // Error
    SetLength(TMPDirectory, StrLen(PChar(TMPDirectory)));
    if TMPDirectory[Length(TMPDirectory)] <> '\' then
      TMPDirectory := TMPDirectory + '\';

    TempFiles := TStringList.Create;
    try
      // Liste einlesen
      if FindFirst(TMPDirectory + 'qrp*.tmp', faAnyFile, SearchRec) = 0 then
      begin
        TempFiles.Add(TMPDirectory + SearchRec.Name);
        SearchBytes := SearchRec.Size;
        while FindNext(SearchRec) = 0 do
        begin
          TempFiles.Add(TMPDirectory + SearchRec.Name);
          SearchBytes := SearchBytes + SearchRec.Size;
        end;
        FindClose(SearchRec);
        SearchBytes := SearchBytes div 1024;

        if TempFiles.Count = 0 then
        begin
          TempFiles.Free;
          Exit;
        end;

        UseRegistry := True;
        DontShowMsgText := JVCSRES_38Delete_without_prompting_from_now_on46;
        Mess := Format(JVCSRES_37d_KBytes_in_37d_temporary_files_40QRPxx46tmp41_left_in_6037s6246 + #13#10 +
          JVCSRES_Delete63, [SearchBytes, TempFiles.Count, TMPDirectory]);
        if DSAIdentsMessageDlg(Mess, mtConfirmation, [mbYes, mbNo], 0,
          sBaseRegistryKey + crbMRU + 'Dlgs', 'DelQRPD', idYes) = idYes then
        begin
          for I := 0 to TempFiles.Count - 1 do
          begin
            SysUtils.DeleteFile(TempFiles.Strings[I]);
          end;
        end; // if DSAIdentsMessageDlg(...
      end; // if FindFirst(GetTempDirectory + 'QRPD*.tmp', faAnyfile, SearchRec) = 0
    finally
      TempFiles.Free;
    end;
  except
    on E:
    Exception do
      HandleException(E.Message, 'DoPrintReports');
  end;
end;

//------------------------------------------------------------------------------

procedure TJVCSClient.DoBackup(Auto: Boolean);
var
  BackUpFlag, GEXFlag: Boolean;
  BackUpList: string;
  DelayCounter: DWORD;
  DelayValue: DWORD;
begin
  try
    GEXFlag :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'GEXPresent', True);
    DelayValue :=
      jvcsReadInteger(sBaseRegistryKey + crbOptions, 'CleanUpDelayValue', 2000);

    if AnsiLowerCase(ExtractFileName(IDEInterface.GetProjectName)) = 'projectgroup1.bpg' then
    begin
      if ShowDebugMsg then
        JclDebug.TraceMsg(cPrgType + 'DoBackup - Exit');
      //???
      if GEXFlag then
      begin
        DelayCounter := GetTickCount;
        while GetTickCount < (DelayCounter + DelayValue) do
          Application.ProcessMessages;
      end;
      Exit;
    end;

    if ServerUserID < 1 then
    begin
      //???
      if GEXFlag then
      begin
        DelayCounter := GetTickCount;
        while GetTickCount < (DelayCounter + DelayValue) do
          Application.ProcessMessages;
      end;
      Exit;
    end;

    if not Auto then
      CheckCurrentProject;
    BackUpFlag := True;
    if Auto and (sBaseRegistryKey <> '') then
    begin
      //??? GlobalSettings
      if not SettingIsGlobal(8) then
        BackUpFlag :=
          jvcsReadBool(sBaseRegistryKey + crbOptions, 'BackupActive', False)
      else
        BackUpFlag := GlobalSettingValue(8);
    end; // if Auto and BaseRegistryKey <> '' then begin
    if not BackUpFlag then
    begin
      //???
      if GEXFlag then
      begin
        DelayCounter := GetTickCount;
        while GetTickCount < (DelayCounter + DelayValue) do
          Application.ProcessMessages;
      end;
      Exit;
    end;

    if ShowDebugMsg then
    begin
      JclDebug.TraceMsg(cPrgType + 'VCSBackup.sCurrentProject: ' + sCurrentProject);
      JclDebug.TraceMsg(cPrgType + 'VCSBackup.sProjectName: ' + sProjectName);
      JclDebug.TraceMsg(cPrgType + 'VCSBackup.IDEInterface.GetProjectName: ' + IDEInterface.GetProjectName);
      JclDebug.TraceMsg(cPrgType + 'VCSBackup.sBackupBuffer: ' + sBackupBuffer);
      if Auto then
        JclDebug.TraceMsg(cPrgType + 'VCSBackup.Auto: true')
      else
        JclDebug.TraceMsg(cPrgType + 'VCSBackup.Auto: false');
    end;

    if Auto then
    begin
      if (sProjectName <> '') or (sBackupBuffer = '') then
        BackUpList := sCurrentProject
      else
        BackUpList := sBackupBuffer;
    end
    else
      BackUpList := sProjectName;

    VCSBackup := TVCSBackup.Create(Application);
    try
      VCSBackup.BackupProjectName := BackUpList;
      if ShowDebugMsg then
        JclDebug.TraceMsg(cPrgType + 'VCSBackup.BackupProjectName: ' + VCSBackup.BackupProjectName);
      VCSBackup.AutoBackup := Auto;
      VCSBackup.ShowModal;
    finally
      VCSBackup.Free;
    end;

    //???
    if GEXFlag then
    begin
      DelayCounter := GetTickCount;
      while GetTickCount < (DelayCounter + DelayValue) do
        Application.ProcessMessages;
    end;
  except
    on E:
    Exception do
      HandleException(E.Message, 'DoBackup');
  end;
end;

//------------------------------------------------------------------------------

procedure TJVCSClient.DoRecentList;
var
  MRUSelection: string;
begin
  try
    MRUSelection := '';
    VCSRecentProjects := TVCSRecentProjects.Create(Application);
    try
      VCSRecentProjects.ShowModal;
      MRUSelection := VCSRecentProjects.SelectedItem;
    finally
      VCSRecentProjects.Free;
    end;
    if MRUSelection <> '' then
    begin
      if IsIDEProject(MRUSelection, '') or
        IsIDEPackage(MRUSelection) then
      begin
        if Assigned(VCSProjAdmin) then
        begin
          VCSProjAdmin.Hide;
          bPJM_TopWindow := False;
        end;
        IDEInterface.CloseProject;
      end; // if (ExtractFileExt(MRUSelection) = '.dpr') or...
      IDEInterface.OpenFile(GetOriginalFileName(MRUSelection));
    end; // if MRUSelection <> '' then begin
  except
    on E:
    Exception do
      HandleException(E.Message, 'DoRecentList');
  end;
end;

//------------------------------------------------------------------------------

{$IFDEF BRANCHING}
procedure TJVCSClient.OpenBranch(ANewBranchID: Integer);
var
  SelectBranch: TJVCSSelectBranch;
  GetBranchList: TJVCSGetBranchList;
  FoundNewBranch: Boolean;
  NewBranchName: string;
  I: Integer;
begin
  if ANewBranchID <> ServerBranchID then
  begin
    FoundNewBranch := False;
    GetBranchList := TJVCSGetBranchList.Create(nil);
    try
      DataModule1.ClientObjectSendRequest(GetBranchList);
      for I := 0 to Pred(GetBranchList.OutputItemCount) do
        if GetBranchList.OutputItems[I].BranchID = ANewBranchID then
        begin
          FoundNewBranch := True;
          NewBranchName := GetBranchList.OutputItems[I].Name;
          Break;
        end;
    finally
      GetBranchList.Free;
    end;
    if FoundNewBranch then
    begin
      ServerBranchID := ANewBranchID;
      sBranchName := NewBranchName;
      SelectBranch := TJVCSSelectBranch.Create(nil);
      try
        SelectBranch.BranchID := ServerBranchID;
        DataModule1.ClientObjectSendRequest(SelectBranch);
      finally
        SelectBranch.Free;
      end;
      // projectmanager needs refresh
      if bPJM_Created then
        bPJM_NeedRefresh := True;
    end;
  end;
end;

procedure TJVCSClient.DoSelectBranch;
var
  NewBranchID: Integer;
  Dummy: string;  
begin
  NewBranchID := SelectBranch(bsmOpen, Dummy);
  if NewBranchID > 0 then
    OpenBranch(NewBranchID);
end;
{$ENDIF BRANCHING}

//------------------------------------------------------------------------------

procedure TJVCSClient.DoToDoList;
begin
  try
    // Check server connection and project ID
    if not CanExecuteVerbOnProject(False) then
      Exit;
    //------------------------------------------

    VCSToDo := TVCSToDo.Create(Application);
    try
      VCSToDo.ShowModal;
    finally
      VCSToDo.Free;
    end;
  except
    on E:
    Exception do
      HandleException(E.Message, 'DoToDoList');
  end;
end;

//------------------------------------------------------------------------------

procedure TJVCSClient.DoTimeLog;
begin
  try
    CheckCurrentProject;
    VCSShowTimeLog := TVCSShowTimeLog.Create(Application);
    try
      VCSShowTimeLog.ShowModal;
    finally
      VCSShowTimeLog.Free;
    end;
  except
    on E:
    Exception do
      HandleException(E.Message, 'DoTimeLog');
  end;
end;

//------------------------------------------------------------------------------

procedure TJVCSClient.DoHelp;
var
  ExecResult: Integer;
  HelpFileName: string;
  Mess: string;
begin
  try
    HelpFileName := sDLLDirectory + cJVCSHelpFile;
    if FileExists(HelpFileName) then
    begin
      ExecResult :=
        ShellExecute(Application.Handle, 'open',
        PChar(HelpFileName),
        '',
        PChar(ExtractFileDir(HelpFileName)), sw_ShowNormal);
    end // if FileExists(HelpFileName) then begin
    else
    begin
      BeepIfSet;
      Mess := Format(JVCSRES_JEDI_VCS_cannot_find_the_file58 + #13#10 + '<%s>.', [HelpFileName]);
      MessageBox(Application.Handle, PChar(Mess), cJediVCS, MB_OK or
        MB_ICONWARNING);
      Exit;
    end; // else if FileExists(HelpFileName) then begin
    if ExecResult < 32 then
    begin
      BeepIfSet;
      Mess := Format(JVCSRES_JEDI_VCS_cannot_open_the_file46_40Invalid_path_or_access_denied4158 + #13#10 +
        '<%s>.' + #13#10 +
        JVCSRES_Make_sure_that_the_file_exists44_that_it_is_not_opened_by_another_application + #13#10 +
        JVCSRES_and_that_you_have_the_required_access_rights46, [HelpFileName]);
      MessageBox(Application.Handle,
        PChar(Mess + #10#13 + DecodeShellErr(ExecResult)),
        cJediVCS, MB_OK or MB_ICONWARNING);
    end; // if ExecResult < 32 then begin
  except
    on E:
    Exception do
      HandleException(E.Message, 'DoHelp');
  end;
end;

//------------------------------------------------------------------------------

procedure TJVCSClient.DoShowAbout; // Show about form
begin
  try
    VCSAbout := TVCSAbout.Create(Application); // unit About
    try
      VCSAbout.ShowModal;
    finally
      VCSAbout.Free;
    end;
  except
    on E:
    Exception do
      HandleException(E.Message, 'DoShowAbout');
  end;
end;

//=== check if 'Module' is a member of the current JEDI VCS Project ============

function TJVCSClient.IsMemberOf(Module: string): Boolean;
begin
  if ShowDebugMsg then
    JclDebug.TraceMsg(cPrgType + 'TJVCSClient.IsMemberOf');
  Result := False;
  try
    ResolveFileFamilies(Module);
    if Assigned(DataModule1) and (ServerUserID > 0) then
    begin
      try
        with DataModule1 do
        begin
          VCSWaitforServer := TVCSWaitforServer.Create(Application);
          try
            VCSWaitforServer.Show;
            AppSrvClient1.Request.Rewrite;
            AppSrvClient1.FunctionCode := 'IS_MEMBER_OF_PROJECT';
            AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
            AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
            AppSrvClient1.Request.WriteFields(True, [ServerProjectID]);
            AppSrvClient1.Request.WriteFields(False, [Module]);
            SetupTimeoutCounter;
            AppSrvClient1.Send;
            while WaitForAppSrvClient do
              Application.ProcessMessages;
          finally
            VCSWaitforServer.Free;
          end;

          if (AppSrvClientErr <> 0) or
            (AppSrvClient1.AnswerStatus <> '200') then
          begin
            ShowServerError(Application.Handle, AppSrvClient1.Answer.Fields[0],
              AppSrvClient1.AnswerStatus);
            Exit;
          end;

          AppSrvClient1.Answer.First;
          Result := DecodeBoolStr(AppSrvClient1.Answer.Fields[0]);
        end; // with DataModule1 do begin
      except
        // No Data available - connection invalid
        ServerUserID := -1;
      end;
    end; // if Assigned(DataModule1) and (ServerUserID > 0) then begin
  except
    on E:
    Exception do
      HandleException(E.Message, 'IsMemberOf');
  end;
end;

//=== check if 'Module' can be checked in or out ===============================

function TJVCSClient.CanCheckInOut(AModuleName: string; ACheckIn: Boolean): Boolean;
var
//ModuleID, UserID: Integer; //USc 30.12.2003 for old version
  ModuleState: TModuleStateRec;
begin
  JclDebug.TraceMsg('> TJVCSClient.CanCheckInOut');

  if ShowDebugMsg then
    JclDebug.TraceMsg(cPrgType + 'TJVCSClient.CanCheckInOut');
  Result := False;
  try
    ResolveFileFamilies(AModuleName);
    if Assigned(DataModule1) and (ServerUserID > 0) then
    begin
      try
        with DataModule1 do
        begin
          VCSWaitforServer := TVCSWaitforServer.Create(Application);
          try
            VCSWaitforServer.Show;
{ //USc 30.12.2003 old version (without caching)
            AppSrvClient1.Request.Rewrite;
            AppSrvClient1.FunctionCode := 'GET_MODULE_ID';
            AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
            AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
            AppSrvClient1.Request.WriteFields(True, [AModuleName]);
            SetupTimeoutCounter;
            AppSrvClient1.Send;
            while WaitForAppSrvClient do
              Application.ProcessMessages;
            if (AppSrvClientErr <> 0) or
              (AppSrvClient1.AnswerStatus <> '200') then
            begin
              ShowServerError(Application.Handle, AppSrvClient1.Answer.Fields[0],
                AppSrvClient1.AnswerStatus);
              Exit;
            end;
            AppSrvClient1.Answer.First;
            ModuleID := StrToIntDef(AppSrvClient1.Answer.Fields[0], 0);

            // Found module
            if ModuleID > 0 then
            begin
              AppSrvClient1.Request.Rewrite;
              AppSrvClient1.FunctionCode := 'GET_REVISION_LIST_BY_ID';
              AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
              AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
              AppSrvClient1.Request.WriteFields(True, [ModuleID]);
              AppSrvClient1.Request.WriteFields(False, [0]); // all projects !
              SetupTimeoutCounter;
              AppSrvClient1.Send;
              while WaitForAppSrvClient do
                Application.ProcessMessages;
              if (AppSrvClientErr <> 0) or
                (AppSrvClient1.AnswerStatus <> '200') then
              begin
                ShowServerError(Application.Handle, AppSrvClient1.Answer.Fields[0],
                  AppSrvClient1.AnswerStatus);
                Exit;
              end;

              AppSrvClient1.Answer.First;
              if ACheckIn then
              begin
                UserID := _StrToInt(AppSrvClient1.Answer.Fields[5]);
                Result := DecodeBoolStr(AppSrvClient1.Answer.Fields[3]) and (UserID = ServerUserID);
              end
              else
                Result := not DecodeBoolStr(AppSrvClient1.Answer.Fields[3]);
            end
            else if ACheckIn then
              Result := True;
}
            //USc 30.12.2003 new version (with caching)
            ModuleState := FModuleStateDataList.GetStateByName(AModuleName);
            if ModuleState.ModuleID <> 0 then
            begin
              if ACheckIn then
                Result := ModuleState.CheckedOut and (ModuleState.UserID = ServerUserID)
              else
                Result := not ModuleState.CheckedOut;
            end
            else
            if ACheckIn then
              Result := True;
          finally
            VCSWaitforServer.Free;
          end;
        end; // with DataModule1 do begin
      except
        // No Data available - connection invalid
        ServerUserID := -1;
      end;
    end; // if Assigned(DataModule1) and (ServerUserID > 0) then begin
  except
    on E :
    Exception do
      HandleException(E.Message, 'CanCheckInOut');
  end;
  JclDebug.TraceMsg('TJVCSClient.CanCheckInOut <');  
end;

//=== check if 'Module' can be checked in ======================================

function TJVCSClient.CanCheckIn(Module: string): Boolean;
begin
  Result := CanCheckInOut(Module, True);
end;

//=== check if 'Module' can be checked out =====================================

function TJVCSClient.CanCheckOut(Module: string): Boolean;
begin
  Result := CanCheckInOut(Module, False);
end;

//==============================================================================
// called when there is any state change of the current project, i.e.
// when a project is destroyed or created.

procedure TJVCSClient.ProjectChange;
var
  ExecResult: Integer;
begin
  if ShowDebugMsg then
    JclDebug.TraceMsg(cPrgType + 'TJVCSClient.ProjectChange');
  try
  
    {$IFDEF EXT_IDE_INTF}
    // Close Project Manager when project is closed, mantis #2836
    if sProjectName = '' then
      if Assigned(VCSProjAdmin) then
      begin
        FreeAndNil(VCSProjAdmin);
        bPJM_Created := False;
        bPJM_Valid := False;
        bPJM_NeedRefresh := False;
        bPJM_TopWindow := False;
      end;
    {$ENDIF EXT_IDE_INTF}
    
    // Verzeichnis für DLL's aus Registry holen.
    //USc 28.09.2003 - this should be moved into CheckAndPrepareDependencies
    // because I think this obsolete here and I don't think that this will
    // be executed because sDLLDirectory should always <> '' now
    // this seams to be obsolete since jedivcsdll.dpr V 0.3 (2003/02/10)
    // because WKlein introduced the initialization of sDLLDirectory in JediVCSInit
    if (sDLLDirectory = '') and (sBaseRegistryKey <> '') then
    begin
      if ShowDebugMsg then
        JclDebug.TraceMsg(cPrgType + 'TJVCSClient.ProjectChange: Verzeichnis für DLL');
      sDLLDirectory :=
        ExtractFilePath(
        jvcsReadString(sIDERegistryKey + '\Version Control', 'VCSManager', ''));

      if (sDLLDirectory = '') or
        (not FileExists(sDLLDirectory + cJVCSReportDll)) then
      begin
        BeepIfSet;
        MessageBox(Application.Handle, PChar(JVCSRES_Fatal_Error58_JEDI_VCS_is_unable_to_get_the_DLL_path46 + #13#10 +
          JVCSRES_Close_the_program44_execute_34reginst46exe34_and_retry46), cJediVCS,
          MB_OK or MB_ICONSTOP);
      end;
      if not DirectoryExists(sConfigFolder) then
      begin
        ExecResult := CreateTargetDir(sConfigFolder);
        if ExecResult <> 0 then
        begin
          BeepIfSet;
          MessageBox(Application.Handle, PChar(Format ( JVCSRES_Unable_to_create58_37s
                                                      , [sConfigFolder])),
            cJediVCS, MB_OK or MB_ICONSTOP);
        end; // if if CreateRes <> 0 then begin
      end; // if not DirectoryExists(TargetDir) then begin
      //Debug
      //???
      ShowDebugMsg := jvcsReadBool(sBaseRegistryKey + crbOptions,
        'OutputDebugStrActive', False);
      if ShowDebugMsg then
      begin
        // NT ?
        if Win32Platform = VER_PLATFORM_WIN32_NT then
        begin
          if EnableProcessPrivilege(True, SE_DEBUG_NAME) then
          begin
            //???
            JclDebug.TraceMsg(cPrgType + 'JclDebug.Trace enabled.');
            Windows.Beep(1000, 100);
          end
          else
            ShowMessage(Format(JVCSRES_37s58_Unable_to_get_privilege_SE95DEBUG46, [cJediVCS]));
        end
        else
        begin
          JclDebug.TraceMsg(cPrgType + 'JclDebug.Trace enabled.');
          Windows.Beep(1000, 100);
        end;
      end;
    end; // if sDLLDirectory = '' and BaseRegistryKey <> '' then begin

    if bBackupEnable then
    begin
      if ShowDebugMsg then
        JclDebug.TraceMsg(cPrgType + 'TJVCSClient.ProjectChange: DoBackup(true) - Start');
      DoBackup(True);
      if ShowDebugMsg then
        JclDebug.TraceMsg(cPrgType + 'TJVCSClient.ProjectChange: DoBackup(true) - Ready');
    end;
    bBackupEnable := False;
    if bConnectRequired then
    begin
      if ShowDebugMsg then
        JclDebug.TraceMsg(cPrgType + 'TJVCSClient.ProjectChange: ConnectArchive - Start');
      ConnectArchive;
      if ShowDebugMsg then
        JclDebug.TraceMsg(cPrgType + 'TJVCSClient.ProjectChange: ConnectArchive - Ready');
    end;
    bConnectRequired := False;
    sCurrentProject := sProjectName;

  except
    on E:
    Exception do
      HandleException(E.Message, 'ProjectChange');
  end;
end;

//=== called to check if there is a change in the active project ===============

procedure TJVCSClient.CheckCurrentProject;
var
  ActiveProject, Mess: string;
  SendMessages: Boolean;
begin
  if ShowDebugMsg then
    JclDebug.TraceMsg(cPrgType + 'TJVCSClient.CheckCurrentProject');
  try
    ActiveProject := IDEInterface.GetProjectName;
    // active project has changed?
    if not (ActiveProject = sCurrentProject) then
    begin
      // yes, Backup after closing a project
      if bProjectOpen then
        DoBackup(True);
      bBackupEnable := False;

      //--- Send Notify messages - disconnected --------------------------------
      //??? GlobalSettings
      if not SettingIsGlobal(16) then
        SendMessages :=
          jvcsReadBool(sBaseRegistryKey + crbOptions, 'NotifyActive', False) and
          jvcsReadBool(sBaseRegistryKey + crbOptions, 'MessDisConnect', False)
      else
        SendMessages := GlobalSettingValue(16);
      if SendMessages then
      begin
        {  %d|%d|%d|%s|%s|%s|%s 162
           Nr|PjID|UsrID|UsrName|Time|Res|Msg  }
        SendSecureMail('*', sFVCSMailslot,
          Format(NtfyMsgStr, [1, ServerProjectID, ServerUserID, sCurrentUser,
          LocalDT2GMTStr(Now), LocalIPAddr,
            '(to: All) ' + 'disconnect from: ' + ExtractFileName(sCurrentProject)]));
      end;
      // -- SMTP --
      if jvcsReadBool(sBaseRegistryKey + crbOptions, 'SMTPMessages', False) and
        jvcsReadBool(sBaseRegistryKey + crbOptions, 'MessDisConnect', False) then
        PrepareSMTP(sCurrentUser, LocalIPAddr, '*All*', 'FVCS Notify',
          ExtractFileName(sCurrentProject), 'disconnect from: ' +
          ExtractFileName(sCurrentProject), 2);
      // -- SMTP --
      // Close time log
      if jvcsReadBool(sBaseRegistryKey + crbTimeLog,
        ExtractFileName(sCurrentProject), False) then
        WriteTimeLog( sConfigFolder + ChangeFileExt(ExtractFileName(sCurrentProject), '.tlg')
                    , 'close;' + sCurrentUser + ';' + FloatToStr(Now)
                    );
      //------------------------------------------------------------------------

      // project ID is now unknown
      ServerProjectID := -1;
      // new project has a valid project name?
      if not IsValidProjectName(sProjectName, Mess) then
      begin
        if sProjectName = '' then
          MessageBox(Application.Handle, PChar(Mess + #13#10 +
            JVCSRES_Remember_that_you_must_open_a_project_to_work_with_JEDI_VCS46), 
            cJediVCS, MB_OK or MB_ICONINFORMATION)
        else
        begin
          BeepIfSet;
          MessageBox(Application.Handle, PChar(Format('<%s>' + #13#10 + '%s' + #13#10 +
            JVCSRES_See_help_topic_34Naming_conventions34_for_more_information46,
            [sProjectName, Mess])), cJediVCS, MB_OK or MB_ICONEXCLAMATION);
        end;
        sProjectName := '';
        bProjectOpen := False;
        Exit;
      end; // if not IsValidProjectName(sProjectName) then begin

      // store the new project name
      sProjectName := ActiveProject;
      sCurrentProject := ActiveProject;

      //--- Send Notify messages - connected -----------------------------------
      //??? GlobalSettings
      if not SettingIsGlobal(16) then
        SendMessages :=
          jvcsReadBool(sBaseRegistryKey + crbOptions, 'NotifyActive', False) and
          jvcsReadBool(sBaseRegistryKey + crbOptions, 'MessConnect', False)
      else
        SendMessages := GlobalSettingValue(16);
      if SendMessages then
      begin
        {  %d|%d|%d|%s|%s|%s|%s 162
           Nr|PjID|UsrID|UsrName|Time|Res|Msg  }
        SendSecureMail('*', sFVCSMailslot,
          Format(NtfyMsgStr, [1, ServerProjectID, ServerUserID, sCurrentUser,
          LocalDT2GMTStr(Now), LocalIPAddr,
            '(to: All) ' + 'connected to: ' + ExtractFileName(sCurrentProject)]));
      end;
      // -- SMTP --
      if jvcsReadBool(sBaseRegistryKey + crbOptions, 'SMTPMessages', False) and
        jvcsReadBool(sBaseRegistryKey + crbOptions, 'MessConnect', False) then
        PrepareSMTP(sCurrentUser, LocalIPAddr, '*All*', 'FVCS Notify',
          ExtractFileName(sCurrentProject), 'connected to: ' +
          ExtractFileName(sCurrentProject), 1);
      // -- SMTP --
      // Open time log
      if jvcsReadBool(sBaseRegistryKey + crbTimeLog,
        ExtractFileName(sCurrentProject), False) then
        WriteTimeLog( sConfigFolder + ChangeFileExt(ExtractFileName(sCurrentProject), '.tlg')
                    , 'open;' + sCurrentUser + ';' + FloatToStr(Now)
                    );
      //------------------------------------------------------------------------

      // ProjectManager needs refresh
      if bPJM_Created then
        bPJM_NeedRefresh := True;
    end; // if not (ActiveProject = sCurrentProject) then begin
  except
    on E:
    Exception do
      HandleException(E.Message, 'CheckCurrentProject');
  end;
end;

//=== called to see if the client is connected with the application server =====

function TJVCSClient.CheckServerConnection: Boolean;
begin
  if ShowDebugMsg then
    JclDebug.TraceMsg(cPrgType + 'TJVCSClient.CheckServerConnection');
  Result := False;
  try
    if ServerUserID < 1 then
    begin
      BeepIfSet;
      MessageBox(Application.Handle, PChar(JVCSRES_Application_server_not_connected46
        + #13#10 + JVCSRES_Connect_the_application_server_and_retry46),
        cJediVCS, MB_OK or MB_ICONWARNING);
    end
    else
      Result := True;
  except
    on E:
    Exception do
      HandleException(E.Message, 'CheckServerConnection');
  end;
end;

//=== called to retrieve the id of the current project =========================

function TJVCSClient.GetServerProjectID: Integer;
var
  ProjectDescr, Msg: string;
begin
  if ShowDebugMsg then
    JclDebug.TraceMsg(cPrgType + 'TJVCSClient.GetServerProjectID');
  Result := 0;
  try
    // reset status 
    bProjectDeleted := False;
    // new project has a valid project name?
    if not IsValidProjectName(sProjectName, Msg) then
    begin
      if sProjectName = '' then
        MessageBox(Application.Handle, PChar(Msg + #13#10 +
          JVCSRES_Remember_that_you_must_open_a_project_to_work_with_JEDI_VCS46),
          cJediVCS, MB_OK or MB_ICONINFORMATION)
      else
      begin
        BeepIfSet;
        MessageBox(Application.Handle, PChar(Format('<%s>' + #13#10 + '%s' + #13#10 +
          JVCSRES_See_help_topic_34Naming_conventions34_for_more_information46,
          [sProjectName, Msg])), cJediVCS, MB_OK or MB_ICONEXCLAMATION);
      end;
      sProjectName := '';
      bProjectOpen := False;
      ServerProjectID := -1;
      Exit;
    end; // if not IsValidProjectName(sProjectName) then begin
    if Assigned(DataModule1) and (ServerUserID > 0) then
    begin
      try
        with DataModule1 do
        begin
          VCSWaitforServer := TVCSWaitforServer.Create(Application);
          try
            VCSWaitforServer.Show;
            //--- get project ID -----------------------------------------------
            AppSrvClient1.Request.Rewrite;
            AppSrvClient1.FunctionCode := 'GET_PROJECT_ID';
            AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
            AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
            AppSrvClient1.Request.WriteFields(True,
              [ExtractFileName(sProjectName)]);
            SetupTimeoutCounter;
            AppSrvClient1.Send;
            while WaitForAppSrvClient do
              Application.ProcessMessages;
          finally
            VCSWaitforServer.Free;
          end;

          if (AppSrvClientErr <> 0) or
            (AppSrvClient1.AnswerStatus <> '200') then
          begin
            ShowServerError(Application.Handle, AppSrvClient1.Answer.Fields[0],
              AppSrvClient1.AnswerStatus);
            Exit;
          end;

          AppSrvClient1.Answer.First;
          if AppSrvClient1.Answer.Fields[0] <> '0' then
          begin
            // known project
            TransactionNr := _StrToInt(AppSrvClient1.Answer.Fields[2]);
            Result := _StrToInt(AppSrvClient1.Answer.Fields[0]);
            // check now if deleted to prevent checkin/checkout (#1704)
            bProjectDeleted := (AppSrvClient1.Answer.Fields[1] <> '0');
          end
          else
          begin
            TransactionNr := _StrToInt(AppSrvClient1.Answer.Fields[2]);
            if MessageBox(Application.Handle, PChar(Format(JVCSRES_Server_reports_an_unknown_project_name_6037s6246 + #13#10 +
              JVCSRES_Create_a_new_project_with_this_name63,
              [ExtractFileName(sProjectName)])), cJediVCS, MB_YESNOCANCEL or
              MB_ICONQUESTION) <> idYes then
              Exit;
            ProjectDescr := '';
            if not jvcsReadBool(sBaseRegistryKey + crbOptions, 'SkipProjectDescr', False) then
            begin
              VCSDescription := TVCSDescription.Create(Application);
              try
                VCSDescription.Top := (Screen.Height div 2) - 85;
                VCSDescription.Left := (Screen.Width div 2) - 142;
                VCSDescription.DescType := 1;
                VCSDescription.SetDescripCaption(Format(JVCSRES_38Project58_37s,
                  [ExtractFileName(sProjectName)]));
                VCSDescription.ShowModal;
                ProjectDescr := VCSDescription.Description;
                jvcsWriteBool(sBaseRegistryKey + crbOptions, 'SkipProjectDescr',
                  VCSDescription.cbState);
              finally
                VCSDescription.Free;
              end;
            end; // if not RegReadBool(....

            VCSWaitforServer := TVCSWaitforServer.Create(Application);
            try
              VCSWaitforServer.Show;
              AppSrvClient1.Request.Rewrite;
              AppSrvClient1.FunctionCode := 'ADD_NEW_PROJECT';
              AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
              AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
              AppSrvClient1.Request.WriteFields(True, [ServerUserID]);
              AppSrvClient1.Request.WriteFields(False,
                [ExtractFileName(sProjectName)]);
              AppSrvClient1.Request.WriteFields(False, [ProjectDescr]);
              SetupTimeoutCounter;
              AppSrvClient1.Send;
              while WaitForAppSrvClient do
                Application.ProcessMessages;
            finally
              VCSWaitforServer.Free;
            end;

            if (AppSrvClientErr <> 0) or
              (AppSrvClient1.AnswerStatus <> '200') then
            begin
              ShowServerError(Application.Handle, AppSrvClient1.Answer.Fields[0],
                AppSrvClient1.AnswerStatus);
              Exit;
            end;

            AppSrvClient1.Answer.First;
            if DecodeBoolStr(AppSrvClient1.Answer.Fields[0]) then
            begin
              Result := _StrToInt(AppSrvClient1.Answer.Fields[1]);
              UseRegistry := True;
              DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
              DSAIdentsMessageDlg(Format(JVCSRES_Project_6037s62_successfully_created46_Project_ID58_37s,
                [ExtractFileName(sProjectName),
                AppSrvClient1.Answer.Fields[1]]), mtInformation,
                  [mbOK], 0, sBaseRegistryKey + crbMRU + 'Dlgs', 'PJCreated', idOk);
            end; // if not DecodeBoolStr(....
          end; // else if AppSrvClient1.Answer.Fields[0] <> '0' then
        end; // with DataModule1 do begin
      except
        // No Data available - connection invalid
        ServerUserID := -1;
        BeepIfSet;
        MessageBox(Application.Handle, PChar(Format(JVCSRES_Connect_failed46_4037s4146 + #13#10 +
          JVCSRES_The_JEDI_VCS_server_on_host_6037s62_did_not_answer46 + #13#10 +
          JVCSRES_Perhaps_the_server_is_not_running44_you_have_entered_an_invalid_IP_or_port_number + #13#10 +
          JVCSRES_or_your_TCP47IP_network_is_not_properly_set46 + #13#10 +
          JVCSRES_Select_the_connect_dialog39s_help_button_for_more_information46, ['', ''])),
          cJediVCS, MB_OK or MB_ICONWARNING);
      end;
    end // if Assigned(DataModule1) and (ServerUserID > 0) then begin
    else
      Result := 0;
  except
    on E:
    Exception do
      HandleException(E.Message, 'GetServerProjectID');
  end;
end;

//=== Add a new module to the current project ==================================

function TJVCSClient.AddNewModule(ModuleName: string): Boolean;
var
  ModuleDescr, Mess, Ext: string;
  I: Integer;
  NewModule: Boolean;
begin
  if ShowDebugMsg then
    JclDebug.TraceMsg(cPrgType + 'TJVCSClient.bConnectRequired := true');
  Result := False;
  try
    //--- keine Datenbanken, keine Projektdatei ! ------------------------------
    Ext := AnsiLowerCase(ExtractFileExt(ModuleName));
    if not MatchWithFilter(Ext, dfNotAdd2Proj) then
    begin
      with DataModule1 do
      begin
        //--- Description ------------------------------------------------------
        ModuleDescr := '';
        if not jvcsReadBool(sBaseRegistryKey + crbOptions, 'SkipModuleDescr', False) then
        begin
          VCSDescription := TVCSDescription.Create(Application);
          try
            VCSDescription.Top := (Screen.Height div 2) - 85;
            VCSDescription.Left := (Screen.Width div 2) - 142;
            VCSDescription.DescType := 2;
            VCSDescription.SetDescripCaption(Format(JVCSRES_38Module58_37s, 
              [ExtractFileName(ModuleName)]));
            VCSDescription.ShowModal;
            ModuleDescr := VCSDescription.Description;
            jvcsWriteBool(sBaseRegistryKey + crbOptions, 'SkipModuleDescr',
              VCSDescription.cbState);
          finally
            VCSDescription.Free;
          end;
        end; // if not RegReadBool(....
        //--- Execute ----------------------------------------------------------
        VCSWaitforServer := TVCSWaitforServer.Create(Application);
        try
          VCSWaitforServer.Show;
          AppSrvClient1.Request.Rewrite;
          AppSrvClient1.FunctionCode := 'ADD_NEW_MODULE';
          AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
          AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
          AppSrvClient1.Request.WriteFields(True, [ServerProjectID]);
          AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
          AppSrvClient1.Request.WriteFields(False, [ModuleName]);
          AppSrvClient1.Request.WriteFields(False, [moVer200]); // flags
          SetupTimeoutCounter;
          AppSrvClient1.Send;
          while WaitForAppSrvClient do
            Application.ProcessMessages;
        finally
          VCSWaitforServer.Free;
        end;

        if (AppSrvClientErr <> 0) or
          (AppSrvClient1.AnswerStatus <> '200') then
        begin
          ShowServerError(Application.Handle, AppSrvClient1.Answer.Fields[0],
            AppSrvClient1.AnswerStatus);
          Exit;
        end;

        AppSrvClient1.Answer.First;
        NewModule := DecodeBoolStr(AppSrvClient1.Answer.Fields[0]);
//      ModuleID := _StrToInt(AppSrvClient1.Answer.Fields[1]);
        //--- New? -------------------------------------------------------------
        if not NewModule then
        begin
          if not AppSrvClient1.Answer.Eof then
            AppSrvClient1.Answer.Next;
          I := 0;
          Mess := '';
          while not AppSrvClient1.Answer.Eof do
          begin
            Inc(I);
            if I < 5 then
            begin
              if Mess = '' then
                Mess := AppSrvClient1.Answer.Fields[1]
              else
                Mess := Mess + '/' + AppSrvClient1.Answer.Fields[1];
            end;
            if I = 5 then
              Mess := Mess + '/...' + #10#13 +
                JVCSRES_40See_34Shared_by34_for_a_complete_list41;
            AppSrvClient1.Answer.Next;
          end; // while not AppSrvClient1.Answer.EoF do begin
          MessageBox(Application.Handle,
            PChar(Format('<%s>' + #13#10 +
              JVCSRES_This_module_is_already_used_by_37d_other_project91s9358
              + #13#10 + '%s' + #13#10 + JVCSRES_Module_added_as_shared_link46,
             [ExtractFileName(ModuleName), I, Mess])),
            cJediVCS, MB_OK or MB_ICONINFORMATION);
          Result := True;
        end // if not NewModule then begin
        else
        begin
          Result := True;
        end;
      end; // with DataModule1 do begin
    end //   if not MatchWithFilter(Ext, dfNotAdd2Proj) then begin
    else
    begin
      Mess := Format(JVCSRES_You_cannot_add_this_type_of_file58 + #13#10 + '<%s>',
        [dfNotAdd2Proj]);
      MessageBox(Application.Handle, PChar(Mess), cJediVCS, MB_OK or
        MB_ICONWARNING);
    end;
  except
    on E:
    Exception do
      HandleException(E.Message, 'AddNewModule');
  end;
end;

//==============================================================================
// called to retrieve the name of the main menu item to be added to the
// application's menu bar. Return a blank string to indicate no menu.

function TJVCSClient.GetMenuName: string;
begin
  if ShowDebugMsg then
    JclDebug.TraceMsg(cPrgType + 'TJVCSClient.bConnectRequired := true');
  bConnectRequired := True;
  try
    Result := GetAcceleratedMenuName(iMenAccel);
  except
    on E:
    Exception do
      HandleException(E.Message, 'GetMenuName');
  end;
end;

//==============================================================================
// called at initialization. Client should return a unique identification
// string. The following string is reserved for Borland use:
// Borland.StdVcs

function TJVCSClient.GetIDString: string;
begin
  try
    Result := cJediVCS;
  except
    on E:
    Exception do
      HandleException(E.Message, 'GetIDString');
  end;
end;

//=== called when the user selects a verb from the menu ========================

function MapVerbIndex(AIndex: Integer): Integer;
begin
  Result := AIndex;
  {$IFDEF BRANCHING}
  if Result in [1, 2] then
    Result := Result + 26
  else
  if (Result >= 3) and (Result <= 28) then
    Result := Result - 2;
  {$ENDIF BRANCHING}
end;


procedure TJVCSClient.ExecuteVerb(Index: Integer);
begin
  try
    Index := MapVerbIndex(Index);
    case Index of
      // Open / Close
      0:
        if ServerUserID > 0 then
        begin
          DoClose(True);
        end
        else
        begin
          bSCActive := True;
          bGoWithout := False;
          DoOpen(False);
          bSCActive := False;
        end;
        // 1 = Seperator
        // Project Admin
      2:
        begin
          bSCActive := True;
          DoProjAdmin;
          bSCActive := False;
        end;
      // 3 = Seperator
      // Check In Single
      4:
        begin
          bSCActive := True;
          DoCheckInSingle;
          bSCActive := False;
        end;
      // Check Out Single
      5:
        begin
          bSCActive := True;
          DoCheckOutSingle;
          bSCActive := False;
        end;
      // Get Single
      6:
        begin
          bSCActive := True;
          DoGetSingle;
          bSCActive := False;
        end;
      // 7 = Seperator
      // Reload
      8:
        begin
          bSCActive := True;
          DoReload;
          bSCActive := False;
        end;
      // 9 = Seperator
      // Compare
      10:
        begin
          bSCActive := True;
          DoCompare;
          bSCActive := False;
        end;
      // Module History
      11:
        begin
          bSCActive := True;
          DoHistory;
          bSCActive := False;
        end;
      // Project History
      12:
        begin
          bSCActive := True;
          DoProjectHistory;
          bSCActive := False;
        end;
      // Merge
      13:
        begin
          bSCActive := True;
          DoMerge;
          bSCActive := False;
        end;
      // Synchronize
      14:
        begin
          bSCActive := True;
          DoSync(False);
          bSCActive := False;
        end;
      // Branch
      15:
        begin
          bSCActive := True;
          DoBranch;
          bSCActive := False;
        end;
      // Reports & Printing
      16:
        begin
          bSCActive := True;
          DoPrintReport;
          bSCActive := False;
        end;
      // Properties
      17:
        begin
          bSCActive := True;
          DoProperties;
          bSCActive := False;
        end;
      // 18 = Seperator
      // Todo list
      19:
        begin
          bSCActive := True;
          DoToDoList;
          bSCActive := False;
        end;
      // Time log
      20:
        begin
          bSCActive := True;
          DoTimeLog;
          bSCActive := False;
        end;
      // Backup / Restore
      21:
        begin
          bSCActive := True;
          DoBackup(False); // Parameter Registry auswerten
          bSCActive := False;
        end;
      // Touch
      22:
        begin
          bSCActive := True;
          DoTouch;
          bSCActive := False;
        end;
      // Recent projects
      23:
        begin
          bSCActive := True;
          DoRecentList;
          bSCActive := False;
        end;
      // 24 = Seperator
      // Help Topics
      25:
        DoHelp;
      // About
      26:
        begin
          bSCActive := True;
          DoShowAbout;
          bSCActive := False;
        end;
      {$IFDEF BRANCHING}
      // 27 = Seperator
      // Select Branch
      28:
        begin
          bSCActive := True;
          DoSelectBranch;
          bSCActive := False;
        end;
      {$ENDIF BRANCHING}
    end;
  except
    on E:
    Exception do
      HandleException(E.Message, 'ExecuteVerb');
  end;
end;

//==============================================================================
// called to retrieve the menu text for each verb. A verb may be returned
// as a blank string to create a seperator bar.

function TJVCSClient.GetVerb(Index: Integer): string;

  function BuildShortCutStr(AShortCut: TShortCut): string;
  begin
    Result := '';
    if (not (ioSupportsShortCuts in IDEInterface.Options)) and (AShortCut <> 0) then
      Result := ' (' + ShortCutToText(AShortCut) + ')';
  end;

  function CurrModule: string;
  begin
    Result := IDEInterface.GetCurrentFile;
    ResolveFileFamilies(Result);
    Result := ExtractFileName(Result);
  end;

begin
  try
    Index := MapVerbIndex(Index);
    case Index of
      0:
        if ServerUserID > 0 then
          Result := JVCSRES_Disconnect47_38Close
        else
          Result := JVCSRES_C38onnect_Server464646;
      1:
        Result := '';
      2:
        Result := JVCSRES_38Project_Manager464646 + BuildShortCutStr(cSCProjAdmin);
      3:
        Result := '';
      4:
        Result := Format(JVCSRES_Check_38In47_Put_6037s62464646, [CurrModule]) + BuildShortCutStr(cSCChkIn);
      5:
        Result := Format(JVCSRES_Check_38Out_6037s62464646, [CurrModule]) + BuildShortCutStr(cSCChkOut);
      6:
        Result := Format(JVCSRES_38Get_6037s62464646, [CurrModule]) + BuildShortCutStr(cSCGet);
      7:
        Result := '';
      8:
        Result := Format(JVCSRES_Relo38ad_6037s62, [CurrModule]);
      9:
        Result := '';
      10:
        Result := JVCSRES_Co38mpare_Modules464646;
      11:
        Result := JVCSRES_Module_Histor38y464646;
      12:
        Result := JVCSRES_P38roject_History464646;
      13:
        Result := JVCSRES_Merge47_38Stamp_Projects464646;
      14:
        if bProjectOpen then
          Result := JVCSRES_Synchroni38ze47_Restore_Projects464646 + BuildShortCutStr(cSCSync)
        else
          Result := JVCSRES_Create_from_38DB464646;
      15:
        Result := JVCSRES_38Branch_Projects464646;
      16:
        Result := JVCSRES_Reports47_Pri38nting464646;
      17:
        Result := JVCSRES_38VCS_Properties464646;
      18:
        Result := '';
      19:
        Result := JVCSRES_ToDo_38List464646;
      20:
        Result := JVCSRES_Tim38e_Log464646;
      21:
        Result := JVCSRES_Back38up47_Restore464646 + BuildShortCutStr(cSCBckUp);
      22:
        Result := JVCSRES_38Touch464646;
      23:
        Result := JVCSRES_Recent_Pro38jects464646;
      24:
        Result := '';
      25:
        Result := JVCSRES_38Help_Topics;
      26:
        Result := JVCSRES_About_38JEDI_VCS;
      {$IFDEF BRANCHING}
      27:
        Result := '';
      28:
        Result := 'Select Branch';
      {$ENDIF BRANCHING}
    end;
  except
    on E:
    Exception do
      HandleException(E.Message, 'GetVerb');
  end;
end;

//==============================================================================
// called to determine the number of available verbs. This function will
// not be called of the GetMenuName function returns a blank string.

function TJVCSClient.GetVerbCount: Integer;
begin
  {$IFDEF BRANCHING}
  Result := 29;
  {$ELSE}
  Result := 27;
  {$ENDIF BRANCHING}
end;

//==============================================================================
// called to determine the state of a particular verb. The return value
// is a bit field of various states.

function TJVCSClient.GetVerbState(Index: Integer): Word;
var
  CurrentFile: string;
begin
  Result := 0;
  try
    Index := MapVerbIndex(Index);
    case Index of
      // Open / Close
      0:
        Result := ivsEnabled;
      // Seperator
      1:
        Result := ivsEnabled;
      // Project Admin
      2:
        if bProjectOpen and (ServerUserID > 0) then
        begin
          if bPJM_Created then
            Result := ivsEnabled or ivsChecked
          else
            Result := ivsEnabled;
        end;
        // Seperator
      3:
        Result := ivsEnabled;
      // Check In Single
      4:
        if (bProjectOpen and (ServerUserID > 0)) then
        begin
          CurrentFile := AnsiLowerCase(IDEInterface.GetCurrentFile);
          ResolveFileFamilies(CurrentFile);
          if not jvcsReadBool(sBaseRegistryKey + crbOptions, 'CheckModuleState', False) or
            CanCheckIn(CurrentFile) then
            Result := ivsEnabled;
        end;
        // Check Out Single
      5:
        if (bProjectOpen and (ServerUserID > 0)) then
        begin
          CurrentFile := AnsiLowerCase(IDEInterface.GetCurrentFile);
          ResolveFileFamilies(CurrentFile);
          if not jvcsReadBool(sBaseRegistryKey + crbOptions, 'CheckModuleState', False) or
            CanCheckOut(CurrentFile) then
            Result := ivsEnabled;
        end;
        // Get Single
      6:
        if (bProjectOpen and (ServerUserID > 0)) then
          Result := ivsEnabled;
        // Seperator
      7:
        Result := ivsEnabled;
      // Reload
      8:
        if bProjectOpen then
          Result := ivsEnabled;
        // Seperator
      9:
        Result := ivsEnabled;
      // Compare
      10:
        if (bProjectOpen and (ServerUserID > 0)) then
          Result := ivsEnabled;
        // Module History
      11:
        if (bProjectOpen and (ServerUserID > 0)) then
          Result := ivsEnabled;
        // Project History
      12:
        if (bProjectOpen and (ServerUserID > 0)) then
          Result := ivsEnabled;
        // Merge
      13:
        if (bProjectOpen and (ServerUserID > 0)) then
          Result := ivsEnabled;
        // Synchronize
      14:
        if (ServerUserID > 0) then
          Result := ivsEnabled;
        // Branch
      15:
        if (bProjectOpen and (ServerUserID > 0)) then
          Result := ivsEnabled;
        // Reports & Printing
      16:
        if (bProjectOpen and (ServerUserID > 0)) then
          Result := ivsEnabled;
        // Properties
      17:
        Result := ivsEnabled;
      // Seperator
      18:
        Result := ivsEnabled;
      // Todo list
      19:
        if (bProjectOpen and (ServerUserID > 0)) then
          Result := ivsEnabled;
        // Time Log
      20:
        if (bProjectOpen and (ServerUserID > 0)) then
          Result := ivsEnabled;
        // Backup / Restore
      21:
        if (bProjectOpen and (ServerUserID > 0)) then
          Result := ivsEnabled;
        // Touch
      22:
        Result := ivsEnabled;
      // Recent projects
      23:
        Result := ivsEnabled;
      // Seperator
      24:
        Result := ivsEnabled;
      // Help Topics
      25:
        Result := ivsEnabled;
      // About
      26:
        Result := ivsEnabled;
      {$IFDEF BRANCHING}
      // Select Branch
      28:
        if nServerVersion >= 250 then
          Result := ivsEnabled;
      {$ENDIF BRANCHING}
    end;
  except
    on E:
    Exception do
      HandleException(E.Message, 'GetVerbState');
  end;
end;

//------------------------------------------------------------------------------

{$IFDEF EXT_IDE_INTF}
procedure GetIDString(AIDString: PChar); stdcall;
var
  S: string;
begin
  if Assigned(JVCSClient) then
    S := JVCSClient.GetIDString
  else
    S := '';
  StrPCopy(AIDString, S);
end;

procedure ExecuteVerb(const AIndex: Integer); stdcall;
begin
  if Assigned(JVCSClient) then
    JVCSClient.ExecuteVerb(AIndex);
end;

procedure GetMenuName(AMenuName: PChar); stdcall;
var
  S: string;
begin
  if Assigned(JVCSClient) then
    S := JVCSClient.GetMenuName
  else
    S := '';
  StrPCopy(AMenuName, S);
end;

procedure GetVerb(const AIndex: Integer; AVerb: PChar); stdcall;
var
  S: string;
begin
  if Assigned(JVCSClient) then
    S := JVCSClient.GetVerb(AIndex)
  else
    S := '';
  StrPCopy(AVerb, S);
end;

function GetVerbCount: Integer; stdcall;
begin
  if Assigned(JVCSClient) then
    Result := JVCSClient.GetVerbCount
  else
    Result := 0;
end;

function GetVerbState(const AIndex: Integer): Word; stdcall;
begin
  if Assigned(JVCSClient) then
    Result := JVCSClient.GetVerbState(AIndex)
  else
    Result := 0;
end;

procedure ProjectChange; stdcall;
begin
  if Assigned(JVCSClient) then
    JVCSClient.ProjectChange;
end;

function GetVerbImages(ABMPContent: Pointer; const AMaxBMPContentSize,
    AImageWidth, AImageHeight: Integer; var ABMPContentSize: Integer): TGetVerbImagesResult; stdcall;
var
  Bitmap: Graphics.TBitmap;
  MemoryStream: TMemoryStream;
begin
  try
    ABMPContentSize := 0;
    if (AImageWidth = 16) and (AImageHeight = 16) then
    begin
      Bitmap := nil;
      MemoryStream := nil;
      try
        Bitmap := TBitmap.Create;
        Bitmap.LoadFromResourceName(HInstance, 'MENUIMAGES');
        MemoryStream := TMemoryStream.Create;
        Bitmap.SaveToStream(MemoryStream);
        if MemoryStream.Size > 0 then
        begin
          if MemoryStream.Size <= AMaxBMPContentSize then
          begin
            Move(MemoryStream.Memory^, ABMPContent^, MemoryStream.Size);
            ABMPContentSize := MemoryStream.Size;
            Result := gvirOkay;
          end
          else
            Result := gvirBufferToSmall;
        end
        else
          Result := gvirContainsNoImages;
      finally
        Bitmap.Free;
        MemoryStream.Free;
      end;
    end
    else
      Result := gvirImageSizeNotSupported;
  except
    Result := gvirUnknown;
  end;
end;

function GetVerbImageIndex(const AIndex: Integer): Integer; stdcall;
var
  MappedIndex: Integer;
begin
  MappedIndex := MapVerbIndex(AIndex);
  case MappedIndex of
    4: Result := 0;
    5: Result := 1;
    6: Result := 2;
    8: Result := 3;
   10: Result := 4;
   11: Result := 5;
   14: Result := 6;
   17: Result := 7;
   25: Result := 8;
   else
     Result := -1;
  end;
end;

function GetVerbShortCut(const AIndex: Integer): Word; stdcall;
var
  MappedIndex: Integer;
begin
  MappedIndex := MapVerbIndex(AIndex);
  case MappedIndex of
     2: Result := cSCProjAdmin;
     4: Result := cSCChkIn;
     5: Result := cSCChkOut;
     6: Result := cSCGet;
    14: if bProjectOpen then
          Result := cSCSync
        else
          Result := 0;
    21: Result := cSCBckUp;
    else
      Result := 0;
  end;
end;

procedure FileNotification(const ANotifyCode: TIDEFileNotification;
  const AFileName: PChar; var ACancel: Boolean); stdcall;
begin
  if Assigned(JVCSNotifier) then
    JVCSNotifier.IDEFileNotification(ANotifyCode, StrPas(AFileName), ACancel);
end;

procedure EventNotification(const ANotifyCode: TIDEEventNotification;
  var ACancel: Boolean); stdcall;
begin
  if Assigned(JVCSNotifier) then
    JVCSNotifier.IDEEventNotification(ANotifyCode, ACancel);
end;
{$ENDIF EXT_IDE_INTF}

//------------------------------------------------------------------------------

procedure CheckAndPrepareDependencies;

  procedure CheckAndCreateFolder(AFolder: string);
  begin
    if not DirectoryExists(AFolder) then
      if CreateTargetDir(AFolder) <> 0 then
      begin
        MessageBox(Application.Handle, PChar(Format(JVCSRES_JEDI_VCS_cannot_create_the_directory + #13#10 +
          '<%s>.' + #13#10 +
          JVCSRES_Perhaps_there_is_already_a_folder_with_this_name_or_you + #13#10 +
          JVCSRES_do_not_have_the_requested_rights_for_this46, [AFolder])),
          cJediVCS, MB_OK or MB_ICONWARNING);
      end;
  end;

begin
  JclDebug.TraceMsg('> CheckAndPrepareDependencies');
  //check and create cfgfolder to avoid mantis #1131
  //this makes the creation of that folder in .ProjectChange obsolete
  CheckAndCreateFolder(sConfigFolder);
  //check and create smtp folder - why ? - this folder will be created when
  //you enable the smtp-option but what happens when you moved the IDE-DLL to
  //another directory or migrated from an old install
  if jvcsReadBool(sBaseRegistryKey + crbOptions, 'SMTPMessages', False) then
    CheckAndCreateFolder(SetBackSlash(sDLLDirectory) + 'SMTP\');
  {
   there seams to be no need to create the following directories
   \Compare\1 and \Compare\2 (only necessary in textcomp and will be created there)
   \Plugin\IDE               (the pluginmanager doesn't cry when the directory not exists)
   \Plugin\Standalone        (only in Standalone - maybe we use this prog in both versions later)
  }
  JclDebug.TraceMsg('CheckAndPrepareDependencies <');
end;

function JediVCSInternalInit(VCSInterface: TIToolServices): TIDEVCSClient;
begin
  JclDebug.TraceMsg('> JediVCSInternalInit');
  // TIToolServices
  if Assigned(VCSInterface) then
  begin
    IDEInterface := CreateIDEInterface(VCSInterface);
    if IDEInterface <> nil then
    begin
      // Extract directory of JediVCSDLL.dll
      sDLLDirectory := GetDllLocation(HInstance);
      JclDebug.TraceFmt('sDLLDirectory= %s',[sDLLDirectory]);

      // Parent handle
      Application.Handle := IDEInterface.GetParentHandle;

      // App registry key
      sBaseRegistryKey := cRegSwJVCSBase;
      InitAndOpenConfigStorage;

      // (Delphi) IDE registry key
      sIDERegistryKey := IDEInterface.GetBaseRegistryKey;
      if (Length(sIDERegistryKey) > 0) and
        (sIDERegistryKey[1] = {$IFDEF DELPHI6_UP}PathDelim{$ELSE}'\'{$ENDIF})
      then
      begin
        // remove leading BS as some Win-OS raise error's if
        // access to subkey of registry is done with leading BS
        sIDERegistryKey := StrRestOf(sIDERegistryKey, 2);
      end;
      // Delphi or C++B?
      bIsCppBuilder := IDEInterface.JVCSIDESettings.IsIDEBCB;
      if bIsCppBuilder then
      begin
        sIDEName := 'C++ Builder';
        sIDEProject := 'bpr';
        sIDEPackage := 'bpk';
        sIDEUnit := 'cpp';
      end; // if bIsCppBuilder then begin
      if IDEInterface.JVCSIDESettings.Product = IDEDeveloperStudio1 then
      begin
        bIsCppBuilder := True;//in order to disable functions for Delphi(Win32) like used units
        sIDEName := 'C# Builder';
        sIDEProject := 'bdsproj';
        sIDEPackage := 'bdsproj';
        sIDEUnit := 'cs';
      end
      else
      if IDEInterface.JVCSIDESettings.Product = IDEDeveloperStudio2 then
      begin
        bIsCppBuilder := True;//in order to disable functions for Delphi(Win32) like used units
        sIDEName := 'Delphi.NET'; //or Delphi 8?
        sIDEProject := 'bdsproj';
        sIDEPackage := 'bdsproj';
        sIDEUnit := 'pas';
      end;

      // Debug???
      ShowDebugMsg := jvcsReadBool(sBaseRegistryKey + crbOptions,
        'OutputDebugStrActive', False);

      // Menu accelerator
      iMenAccel :=
        jvcsReadInteger(sBaseRegistryKey + crbOptions, 'FVCSAccel', 5);

      // TIAddInNotifier
      JVCSNotifier := TJVCSNotifier.Create;
      if Assigned(JVCSNotifier) then
        IDEInterface.AddNotifierEx(JVCSNotifier);

      // Shortcuts
      ReadShortcutsFromStorage;

      // Install key hook
      if (hKeyHook = 0) and (not (ioSupportsShortCuts in IDEInterface.Options)) then
      begin
        hKeyHook := SetWindowsHookEx(WH_KEYBOARD, KeyProc, 0,
          GetWindowThreadProcessID(Application.Handle, nil));
      end; // if hKeyHook = 0 then begin

      // check if all necessary directories exists or create them
      CheckAndPrepareDependencies;

      // clean compare directories (mantis #1272)
      CleanCompareDirectories;

      // Mutex
      JVCSMutex := Windows.CreateMutex(nil, False, 'FVCSIDEMutex');

      // VCS client
      JVCSClient := TJVCSClient.Create;

      // Datamodule
      JVCSClient.CreateDatamodule;

      // Auto Login?
      if jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowLoad', False) then
        JVCSClient.DoOpen(True);

      // OK - submit the client
      Result := JVCSClient;

    end // if IDEInterface <> nil then begin
    else
      Result := nil;
  end
  else // if Assigned(VCSInterface) then
    Result := nil;
  JclDebug.TraceMsg('JediVCSInternalInit <');
end;

{$IFNDEF EXT_IDE_INTF}
function JediVCSInit(VCSInterface: TIToolServices): TIVCSClient; stdcall export;
begin
  JclDebug.TraceMsg('> JediVCSInit');
  Result := JediVCSInternalInit(VCSInterface);
  JclDebug.TraceMsg('JediVCSInit <');
end;
{$ELSE}
function JediVCSDLLInit(AExternalIDEFunctionRec: PExternalIDEFunctionRec;
  AExternalVCSFunctionRec: PExternalVCSFunctionRec;
  AExternalNotifierFunctionRec: PExternalNotifierFunctionRec): Boolean; stdcall;
begin
  JclDebug.TraceMsg('> JediVCSInit Ext');
  NeedsFinalization := True;
  AExternalVCSFunctionRec^.GetIDString       := GetIDString;
  AExternalVCSFunctionRec^.ExecuteVerb       := ExecuteVerb;
  AExternalVCSFunctionRec^.GetMenuName       := GetMenuName;
  AExternalVCSFunctionRec^.GetVerb           := GetVerb;
  AExternalVCSFunctionRec^.GetVerbCount      := GetVerbCount;
  AExternalVCSFunctionRec^.GetVerbState      := GetVerbState;
  AExternalVCSFunctionRec^.ProjectChange     := ProjectChange;
  AExternalVCSFunctionRec^.GetVerbImages     := GetVerbImages;
  AExternalVCSFunctionRec^.GetVerbImageIndex := GetVerbImageIndex;
  AExternalVCSFunctionRec^.GetVerbShortCut   := GetVerbShortCut;

  AExternalNotifierFunctionRec^.FileNotification  := FileNotification;
  AExternalNotifierFunctionRec^.EventNotification := EventNotification;

  Result := Assigned(JediVCSInternalInit(AExternalIDEFunctionRec));
  JclDebug.TraceMsg('JediVCSInit  Ext <');
end;

procedure JediVCSDLLFinalize; stdcall;
begin
  {$IFDEF DEBUG}
  JclDebug.TraceMsg('> JediVCSDLLFinalize Ext');
  if NeedsFinalization then
    JclDebug.TraceMsg('  JediVCSDLLFinalize Ext NeedsFinalization=True')
  else
    JclDebug.TraceMsg('  JediVCSDLLFinalize Ext NeedsFinalization=False');
  {$ENDIF DEBUG}
  if NeedsFinalization then
  begin
    NeedsFinalization := False;
    LibExit;
  end;
  {$IFDEF DEBUG}
  JclDebug.TraceMsg('< JediVCSDLLFinalize Ext');
  {$ENDIF DEBUG}
end;
{$ENDIF ~EXT_IDE_INTF}

exports
  {$IFNDEF EXT_IDE_INTF}
  JediVCSInit name VCSManagerEntryPoint;
  {$ELSE}
  JediVCSDLLInit name cJediVCSDLLInitFuncName
  , JediVCSDLLFinalize name cJediVCSDLLFinalizeFuncName
  {$IFDEF HISTORYAPISUPPORT}
  , JediVCSDLLHistoryInit name cJediVCSDLLInitHistoryFuncName
  {$ENDIF HISTORYAPISUPPORT}
  {$IFDEF OPERATIONSSUPPORT}
  , JediVCSDLLOperationsInit name cJediVCSDLLInitOperationFuncName
  {$ENDIF OPERATIONSSUPPORT}
  {$IFDEF LINEHISTORYFRAMEEXPORT}
  , AddLineHistoryControl name 'AddLineHistoryControl'
  , SetLineHistoryControlParentHandle name 'SetLineHistoryControlParentHandle'
  , SetLineHistoryControlModuleAndExtension name 'SetLineHistoryControlModuleAndExtension'
  {$ENDIF LINEHISTORYFRAMEEXPORT}
  ;
  {$ENDIF ~EXT_IDE_INTF}

{$IFDEF EXT_IDE_INTF}
procedure DllEntry(Reason: Integer);
begin
  case Reason of
    DLL_PROCESS_ATTACH:
      JclDebug.TraceMsg('DllEntry Reason=DLL_PROCESS_ATTACH');
    DLL_PROCESS_DETACH:
      begin
        JclDebug.TraceMsg('DllEntry Reason=DLL_PROCESS_DETACH');
        JediVCSDLLFinalize;
      end;
    DLL_THREAD_ATTACH:  ;
    DLL_THREAD_DETACH:  ;
  end;
end;
{$ENDIF EXT_IDE_INTF}

begin
  {$IFDEF EXT_IDE_INTF}
  DllProc  := @DllEntry;
  DllEntry(DLL_PROCESS_ATTACH);
  {$ELSE}
  SaveExit := ExitProc; // Kette der Exit-Prozeduren speichern
  ExitProc := @LibExit; // Exit-Prozedur LibExit installieren
  {$ENDIF EXT_IDE_INTF}
end.

