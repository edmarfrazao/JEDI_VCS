(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JEDIVCS.DPR

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
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber     - 1st Migration step from FreeVCS code to JEDI-VCS
2003/02/03  RMarquardt - seperate DPR for Standalone App.
2003/02/26  USchuster  - moved the creation of VcsVSSImport to projadmin
2003/03/02  THuber     - added new unit ..\common\vcscommon.pas which shares
                         const's/func's between server/client parts
2003/03/06  THensle    - changes for "ConfigStorage" unit
                       - removed some obsolete units in Uses clause
                         "CreateDBIArchive" (senseless, as DBISAM != standard DB)
                         "ProjectRoot" (not used for now)
                         "RegAcc" (replaced by "ConfigStorage")
                         "Recent" (only used by DLL version)
2003/03/09  THuber     - introduced memcheck use
2003/05/21  MGosselink - Added BugWindow unit
2003/05/23  USchuster  - added JVCSDockForm (necessary to open or create
                         forms inherited from TJVCSDockableForm)
                       - changed JediVCS to JEDI VCS in unit header,
                         application.title and messagebox
2003/06/19  MGosselink - added ModuleHistoryWindow (mantis #908)
2003/09/05  THuber     - configStorage.pas was not included in uses
2003/10/27  USchuster  - added TZHandling.pas
2003/11/05  USchuster  - added JCL Exceptionhandler
2003/11/11  FHasovic   - added new unit ..\common\D7ComboBoxStringsGetPatch.pas which
                         fixes Delphi 7 bug:
                         Problem: Selecting an empty string in TComboBox component will cause
    			   Access Violation on some systems. See details in Quality Central report
   			   #2246.
			 Description: On some systems (Windows 2000 SP3) it will cause Access
                           Violation in ntdll.dll for an empty string item.
2003/11/30  USchuster  - added ClientObjects units
2003/12/27  USchuster  - added new units
                       - compare directories will now be cleaned on startup (mantis #1272)
2003/12/29  USchuster  - changes because debug units were moved to ..\common\
2004/01/08  USchuster  - added new units
2004/05/31  FHasovic   - removed dependency on D7ComboBoxStringsGetPatch.pas
                         (see 2003/11/11). It's not needed anymore with Delphi 7 SP1.
2004/10/09  THuber     - added JVCSGUIClientResources
2004/10/30  USchuster  - res strings and displayed strings changed to resourcestrings
2004/10/31  USchuster  - changed Application.Title back to string (the IDE don't like
                         resourcestring as Application.Title)
                       - moved resourcestrings to JVCSGUIClientResources
2004/11/27  USchuster  - now we allow several clients to be started simultaneously (mantis #830)
2005/12/21  THuber     - FastMM now default memory manager
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 final released ^^^^^^^^^^^^^^^^^^^^^^^^^^
2006/04/02  THuber     #3613 files for line history added to uses
2006/04/30  USchuster  - removed wrong textdiff units(library&component search paths belong into 
                         compsearch.mki, project search paths or library path of the IDE)
2006/06/05  CSchuette  - added missing JVCSLineHistoryHighlighterUnit to uses
2006/08/06  USchuster  - added BRANCHING units to uses
2006/12/04  USchuster  - added JVCSLineHistorySettingsDialog to uses
2008/12/06  USchuster  - added JVCSLabelHistory and JVCSNewClientObj to uses
2008/12/15  THuber     - introduced Support for Themes under XP/VISTA - added Winxp.res file
2008/12/22  THuber     - introduced JVCSForms as Baseclass for modal dialogs to avoid
                         "shy" window problem of Delphi together with VISTA changes
2009/11/27  USchuster  - added compressed Diff units
2010/01/23  USchuster  - added VCS browser unit (Mantis #5103)
2014/02/26  USchuster  - added compressed Diff SynEdit highlighter proxy unit 

-----------------------------------------------------------------------------
 Compiler Directives:
 see also compopt.inc
 DEBUG         : includes debug messages viewable in eventwindow
 JCL_DEBUG_DATA: use JCL Exceptionhandler
 REPORTDLL     : use reportdll
 BETA          : define this is a beta version
 HTMLHLP       : use chm helpfile, otherwise uses hlp-file
 CUSTOMDRIVE   : a first try to implement server <> client drive substituion
 DBGFILE       : write debugmessages to file DebugInfo.txt
 BLOWFISH      : use blowfish cipher
 RELEASE       : explicitly stated as release version
 TDODEBUG      : extra Debug info in ToDo.pas
 GX_VER100_up  : use gexperts over v1.0
 PDDEBUG       : extra Debug info in Projectdependencies.pas
 UUDEBUG       : extra Debug info in usedunits.pas
 LZH           : use lzh compression if encryption on
 RTFREPORT     : use rtf-export in simple report

-----------------------------------------------------------------------------*)

{$I jedi.inc}

// === THIS IS THE Standalone Application ===   //
// compile *without* IDEDLL in project settings //


{$I compopt.inc}

program JediVCS;

{%File '..\StdPlugin\JEDIVCSPluginMsgConst.inc'}
{%File '..\credits.txt'}

uses
  FastMM4,
  Windows,
  Forms,
  Dialogs,
  JclDebug,
  {$IFDEF JCL_DEBUG_DATA}
  ExceptDlg,
  {$ENDIF JCL_DEBUG_DATA}
  JclStrings,
  ProjAdmin in 'ProjAdmin.pas' {VCSProjAdmin},
  Progress in 'Progress.pas' {VCSProgress},
  AddNewFamily in 'AddNewFamily.pas' {VCSAddFamily},
  AddNewLabel in 'AddNewLabel.pas' {VCSAddLabel},
  AddNewMilestone in 'AddNewMilestone.pas' {VCSAddMilestone},
  AddNewUser in 'AddNewUser.pas' {VCSAddUser},
  AddShareModule in 'AddShareModule.pas' {VCSAddSharedModule},
  AssignLabels in 'AssignLabels.pas' {VCSAssignLabels},
  AssignMilestones in 'AssignMilestones.pas' {VCSAssignMilestones},
  Backup in 'Backup.pas' {VCSBackup},
  Branch in 'Branch.pas' {VCSBranch},
  ChangeUserPW in 'ChangeUserPW.pas' {VCSChangeUserPW},
  CheckfBuild in 'CheckfBuild.pas' {VCSCheckfBuild},
  ChkInSingle in 'ChkInSingle.pas' {VCSChkInSingle},
  ChkOutSingle in 'ChkOutSingle.pas' {VCSChkOutSingle},
  Create in 'Create.pas' {VCSLoad},
  CrossRefList in 'CrossRefList.pas' {VCSSelCrossRef},
  CustViewFilter in 'CustViewFilter.pas' {VCSCustomViewFilter},
  DBModule in 'DBModule.pas' {DataModule1: TDataModule},
  DeletePH in 'DeletePH.pas' {VCSDeletePH},
  Description in 'Description.pas' {VCSDescription},
  FileFamilies in 'FileFamilies.pas' {VCSFileFamilies},
  HandleBlob in 'HandleBlob.pas',
  History in 'history.pas' {VCSHistory},
  ListView in 'ListView.pas' {VCSListView},
  MaintainFFamilies in 'MaintainFFamilies.pas' {VCSMaintainFFamilies},
  MaintainLabels in 'MaintainLabels.pas' {VCSMaintainLabels},
  MaintainMilestones in 'MaintainMilestones.pas' {VCSMaintainMilestones},
  MaintainUsers in 'MaintainUsers.pas' {VCSMaintainUsers},
  MergeVersion in 'mergeversion.pas' {VCSMerge},
  ModuleInfo in 'moduleinfo.pas' {VCSInfo},
  MoveModules in 'MoveModules.pas' {VCSModMove},
  NtfySend in 'NtfySend.pas' {NtfySendForm},
  Options in 'Options.pas' {VCSOptions},
  Password in 'Password.pas' {VCSPassword},
  PHFilter in 'PHFilter.pas' {VCSPHistoryFilter},
  About in 'About.pas' {VCSAbout},
  Yes2allDlg in 'Yes2allDlg.pas' {VCSYes2AllDlg},
  ProjectHist in 'ProjectHist.pas' {VCSProjectHistory},
  ProjectRights in 'ProjectRights.pas' {VCSProjectRights},
  ProjectTree in 'ProjectTree.pas' {VCSProjectTree},
  Purge in 'Purge.pas' {VCSPurge},
  RemoveProj in 'RemoveProj.pas' {VCSRemoveProj},
  RenameProj in 'RenameProj.pas' {VCSRenameProj},
  SearchModules in 'SearchModules.pas' {VCSSearchModules},
  SelectFolder in 'SelectFolder.pas' {VCSSelectFolder},
  SelectList in 'SelectList.pas' {VCSSelectList},
  SelectProjectID in 'SelectProjectID.pas' {VCSSelectProject},
  ServerOptions in 'ServerOptions.pas' {VCSServerOptions},
  Std_ListView in 'Std_ListView.pas' {VCSStdListView},
  Syncronice in 'Syncronice.pas' {VCSSync},
  TextComp in 'Textcomp.pas' {VCSTextCompare},
  ToDo in 'todo.pas' {VCSToDo},
  ToDoEdit in 'todoedit.pas' {VCSToDoEdit},
  ToDoFilter in 'ToDoFilter.pas' {VCSToDoFilter},
  Touch in 'Touch.pas' {VCSTouch},
  VCSBase in 'VCSBase.pas',
  VCSProcBase in 'VCSProcBase.pas',
  WaitforServer in 'WaitforServer.pas' {VCSWaitforServer},
  WCViewFilter in 'WCViewFilter.pas' {VCSWCViewFilter},
  Whoami in 'Whoami.pas' {VCSWhoami},
  OpenProject in 'OpenProject.pas' {VCSOpenProject},
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
  Distribution in 'Distribution.pas' {VCSDistribution},
  SMTPSend in 'SMTPSend.pas',
  TZHandling in '..\common\client\TZHandling.pas',
  Plugins in 'Plugins.pas' {VCSPlugin},
  DirWatch in 'DirWatch.pas' {VCSDirWatch},
  VCSCommon in '..\Common\vcscommon.pas',
  BugWindow in 'BugWindow.pas' {VCSBugWindow},
  JVCSDockForm in 'JVCSDockForm.pas' {JVCSDockableForm},
  ModuleHistoryWindow in 'ModuleHistoryWindow.pas' {VCSModuleHistoryWindow},
  ConfigStorage in 'ConfigStorage.pas',
  JVCSGUIClientResources in 'JVCSGUIClientResources.pas',
  JVCSBaseAboutDialog in '..\common\JVCSBaseAboutDialog.pas' {JVCSBaseAboutDlg},
  {$IFDEF BRANCHING}
  JVCSBranchClientObj in '..\common\client\JVCSBranchClientObj.pas',
  JVCSBranchTreeViewFrame in 'JVCSBranchTreeViewFrame.pas' {JVCSBranchTreeViewFrm: TFrame},
  JVCSSelectBranchDialog,
  {$ENDIF BRANCHING}
  JVCSBrowserFrame in 'JVCSBrowserFrame.pas' {JVCSBrowserFrm: TFrame},
  JVCSClientConsts in '..\common\client\JVCSClientConsts.pas',
  {$IFDEF DEBUG}
  JVCSDebug in '..\common\JVCSDebug.pas',
  JVCSDebugView in '..\common\JVCSDebugView.pas',
  {$ENDIF DEBUG}
  JVCSDialogs,
  JVCSThreads in '..\common\JVCSThreads.pas',
  JVCSClientDispatcher in '..\common\client\JVCSClientDispatcher.pas',
  JVCSClientFunctions in '..\common\client\JVCSClientFunctions.pas',
  JVCSClientObj in '..\common\client\JVCSClientObj.pas',
  JVCSClientObjBase in '..\common\client\JVCSClientObjBase.pas',
  JVCSCompressedDiffDialog in '..\common\client\JVCSCompressedDiffDialog.pas' {VCSCompressedDiff},
  JVCSCompressedDiffFrame in '..\common\client\JVCSCompressedDiffFrame.pas' {JVCSCompressedDiffFrm: TFrame},
  JVCSCompressedDiffSynProxy in '..\common\client\JVCSCompressedDiffSynProxy.pas',
  JVCSCompressedDiffUnit in '..\common\client\JVCSCompressedDiffUnit.pas',
  JVCSConnect in '..\common\client\JVCSConnect.pas',
  JVCSCrypt in '..\common\client\JVCSCrypt.pas',
  JVCSFunctions in '..\common\JVCSFunctions.pas',
  JVCSLabelHistory in 'JVCSLabelHistory.pas' {VCSLabelHistory},
  {$IFDEF LANGUAGE}
  JVCSLanguage in '..\common\JVCSLanguage.pas',
  {$ENDIF LANGUAGE}
  JVCSLineHistoryPropertyStorage in '..\common\client\JVCSLineHistoryPropertyStorage.pas',
  JVCSLineHistoryDefaultProvider in '..\common\client\JVCSLineHistoryDefaultProvider.pas',
  JVCSLineHistoryFrame in '..\common\Client\JVCSLineHistoryFrame.pas' {JVCSLineHistoryFrm: TFrame},
  JVCSLineHistoryHighlighterUnit in '..\common\client\JVCSLineHistoryHighlighterUnit.pas',
  JVCSLineHistorySettingsDialog in '..\common\Client\JVCSLineHistorySettingsDialog.pas' {JVCSLineHistorySettingsDlg},
  JVCSLineHistoryUnit in '..\common\client\JVCSLineHistoryUnit.pas',
  JVCSNewClientObj in '..\common\client\JVCSNewClientObj.pas',
  JVCSTypes in '..\common\client\JVCSTypes.pas',
  JVCSForms in '..\common\JVCSForms.pas';

{$R *.res}
{$R jvcsver.res} // DLL-Version information
{$R strings.res} // String Resource
{$R cursors.res} // Cursor Resource
{$R icon.res}    // Taskbar icon
{$R \Projects\Jedivcs\src\comp\soft-gems\thememanager\Resources\winxp.res}   // Include Themingresource for WindowsXP

var
  JVCSMutex: THandle;

begin
  // create a mutex to be able to detect running instances
  JVCSMutex := CreateMutex(nil, False, 'JediVCSAppMutex');
  InitAndOpenConfigStorage;
  if (GetLastError = ERROR_ALREADY_EXISTS) or ExistMutex('FVCSAppMutex') or
    ExistMutex('FVCSIDEMutex') then
  begin
    DSAIdentsMessageDlg(JVCSRES_There_are_still_running_instances_of_the_JEDI_VCS_or_FreeVCS_Client46 + #13#13 +
      JVCSRES_It_is_not_possible_to_login_on_a_server_more_than_once_with_the_same_login_at_the_same_time46
      , mtWarning
      , [mbOK]
      , 0
      , sBaseRegistryKey + crbMRU + 'Dlgs'
      , 'MultipleInstances'
      , idOk
      );
  end;
  Application.Initialize;
  Application.Title := 'JEDI VCS';
  Application.CreateForm(TVCSProjAdmin, VCSProjAdmin);
  Application.CreateForm(TDataModule1, DataModule1);
  CleanCompareDirectories;
  {$IFDEF DEBUG}
  //CreateClientDebugView;
  {$ENDIF DEBUG}
  Application.Run;
  ReleaseMutex(JVCSMutex);
end.

