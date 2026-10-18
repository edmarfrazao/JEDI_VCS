(*------------------------------------------------------------------------------

 Project JEDI Version Control System

 The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License"); 
 you may not use this file except in compliance with the License. You may obtain a copy of the    
 License at http://www.mozilla.org/MPL/                                                           

 Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF
 ANY KIND, either express or implied. See the License for the specific language governing rights  
 and limitations under the License.

 The Original Code is jfvcs.dpr.

 The Initial Developer of the Original Code is TOndrej (tondrej@t-online.de).                     
 Portions created by TOndrej are Copyright (C) of TOndrej.                                        
 Portions created by THu are Copyright (C) of Thomas Huber.

 Credits:                                                                                         
 Portions of this code are based on/derived from:
                                                                                                  

********************************************************************************

 This unit contains the JEDI VCS command line client.

 Unit owner: TOndrej (tondrej@t-online.de)
 Last modified: July 26, 2002

--------------------------------------------------------------------------------

Unit history(JEDI FreeVCS):
2002/05/23  TOndrej - Initial implementation and commenting.
2002/06/09  TOndrej - Added interactive session, commands etc.
2002/07/17  TOndrej - Added/modified commands: listprojects, syncproject
2002/07/19  TOndrej - Added commands: checkout, undocheckout.
                    - Modified listprojects to use GET_PROJECT_INFORMATION
                      (rather than GET_PROJECT_LIST which never returns project descriptions).
2002/07/26  TOndrej - Added input command. Added noprompt option to syncproject command.
2002/10/02  THuber  - Added syncprojectcrc: same as syncproject but compare is
                      done with crc-check
2002/10/11  TOndrej - Added column aligned output.
                    - Added backspace handling in ReadPassword.
                    - Centralized handling of commands.
2002/10/13  TOndrej - Improved prompts, crc now as parameter to syncproject command.
2002/10/23  TOndrej - Added commands: checkin, listlocks. Minor improvements.
                      Command syncprojectgroup in progress.
2002/11/02  TOndrej - Added pre-check of required libraries; workaround to prevent
                      access violations later.
2002/11/03  THuber  - New command labelproject in progress (for assigning label to
                      modules of a project)
2002/11/16  THuber  - Replaced ZipMaster by NanoZip to get rid of Zip/Unzip DLL
                      Attention: Get also FVCSClient60 as this also was changed there

Unit history(JEDI VCS):                      

2003/02/23  THuber    - IsFileDirty now uses TZhandling functions to be GMT aware (bug fix)
                      - bugfix: Login failed if user was same as password
                      - more info about web, newsgroup, bugtracker
                      - introduced #define BETA which shows a warning
2003/03/29  THuber    - first implementation of labelproject
                      - changed webadress of jvcs homepage
2003/04/03  THuber    - replaced crc32.pas with checksum.pas (same as in Gui-part)
2003/04/06  THuber    - crossref parameter added to syncproject
                      - crossref parameter added to labelproject
                      - new internSyncProject function for sync exactly one project
                      - new internLabelProject function for label exactly one project
                      - new link to SF.project shown
                      - syncproject now shows header with syncoptions as there
                        could now synced more than one project over crossref
                      - !! renamed to jvcs.dpr !!
2003/09/06  PLauret   - mantis #0001116
                        don't erase checkedout file by current user
2003/10/27  USchuster - finished migration from JEDI FreeVCS -> from now on the
                        migrated units are used and changed ...FVCS... into ...JVCS...
                      - now with COMPOPT.INC and moved BETA define to COMPOPT.INC
2003/10/27  USchuster - D5 Fix
2003/10/30  THuber    - #1159: introduced new parameter includehidden to commands
                               syncproject & listproject
                      - #1153: allow 'unsafe' checkin if allowed by global parameter
2003/12/13  USchuster - moved some functions to JVCSClientFunctions.pas and some
                        constants to JVCSClientConsts.pas
                      - minor cleanup (changed to standard casing)
2004/01/09  USchuster - added new unit
2004/01/24  USchuster - the internet links will now be taken from VCSCommon.pas
2004/02/29  ESasse    - #1346: extexitcode added to syncproject
                      - Remove some code inadvertently inserted
2004/03/04  ESasse    - Minors adjustments
2004/04/03  THuber    - same version 2.40.650 as other clients over jvcsver.rc/res
2004/06/01  USchuster - fixed check out if module must be synced (mantis #1737)
                      - minor style cleaning (casing and comments)
2004/10/12  THuber    #2157 - replaced nanozip with abbrevia, build now 2.40.655
2004/10/16  THuber    #2157 - again abbrevia, checkin was still done over nanozip
2004/10/17  THuber    #2235 - JVCS*.tmp file now deleted on checkin
2004/10/17  USchuster - D5 fix
2004/10/19  THuber    - abbrevia checkin part moved to JVCSClientObjBase for
                        common use
2005/03/18  USchuster - added the possibility to restore a labeled version (mantis #1556)
2005/03/29  CSchuette - mantis #2815
2005/04/12  USchuster - does now use MatchWithFilter from JVCSClientFunctions (mantis #2857)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RC2 was released ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
2005/07/05  THuber    #3045 - added getmodule command
2005/08/09  CSchuette - added FastMM4
                        added option "noprompt" to undocheckout command
2005/08/27  MBurbach  - added code library units & comp\midware units
                        to project to get it to compile
2005/11/12  USchuster - back to revision 0.25
                        (- librarys which are not hosted by us should not be referenced
                         - library search path belong into compsearch.mki,
                           project search paths or library path of the IDE)
2005/12/03  THuber    #3337 possibility to delete hidden files on syncproject
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RC3 was released ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
2005/12/29  USchuster - finished command syncprojectgroup (mantis #3356)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 final released ^^^^^^^^^^^^^^^^^^^^^^^^^^
2006/06/05  USchuster - fixed sync/get of renamed modules (mantis #3744)
2007/10/20  USchuster - first changes for branching
2007/12/22  USchuster - added parameter branch in ShowUsage
2008/12/06  USchuster - added JVCSNewClientObj to uses
---- 2.50 Beta2 was released
2009/12/26  THuber    #2284 added option to set RO Flag in syncProject(group) according
                      to expected checkout state like in GUI client. 
------------------------------------------------------------------------------*)

{  TODO:
   - sync should be aware if file is checked out/writeable when filedatetime
     is newer than in archive!

 }

program jvcs;

{$I jedi.inc}
{$I compopt.inc}

{$IFDEF DELPHI6_UP}
  {$WARN SYMBOL_PLATFORM OFF}
{$ENDIF DELPHI6_UP}

uses
    SysUtils
  , Classes
  , Windows
  , TZHandling in '..\common\client\TZHandling.pas'
  , JclFileUtils
  , Registry
  , Checksum
  , JVCSClasses in '..\Jedivcs\JVCSClasses.pas'
  {$IFDEF BRANCHING}
  , JVCSBranchClientObj in '..\common\client\JVCSBranchClientObj.pas'
  {$ENDIF BRANCHING}
  , JVCSConnect in '..\common\client\JVCSConnect.pas'
  , JVCSClientObjBase in '..\common\client\JVCSClientObjBase.pas'
  , JVCSClientObj in '..\common\client\JVCSClientObj.pas'
  , JVCSCrypt in '..\common\client\JVCSCrypt.pas'
  , JVCSTypes in '..\common\client\JVCSTypes.pas'
  , JVCSClientDispatcher in '..\common\Client\JVCSClientDispatcher.pas'
  , JVCSClientFunctions in '..\common\Client\JVCSClientFunctions.pas'
  , JVCSClientConsts in '..\common\Client\JVCSClientConsts.pas'
  , JVCSNewClientObj in '..\common\client\JVCSNewClientObj.pas'
  , JclStrings
  , VCSCommon in '..\common\VCSCommon.pas'
  , JVCSAppVersion in '..\common\JVCSAppVersion.pas'
  , RFormat;

const
  JVCSPrompt = 'jvcs> ';
  SwitchChars: TSysCharSet = ['-', '/'];
  ExitCodeUnspecified = 1;
  ExitCodeInvalidParams = 2;
  ExitCodeAllUpToDate = 3;

resourcestring
  SBetaVersion = 'Warning: *Beta* version - for reporting problems please visit our issuetracker';
{//USc 24.01.2004 now the values from VCSCommon will be used
  SInfoLinkWeb = 'JEDI VCS on the web  : http://jedivcs.sourceforge.net/';
  SInfoLinkSF  = 'JEDI VCS @SourceForge: http://sourceforge.net/projects/jedivcs/';
  SInfoLinkNews = 'JEDI VCS newsgroup   : news://forums.talkto.net/jedi.vcs';
  SInfoLinkMantis = 'JEDI VCS issuetracker: http://projectjedi.sourceforge.net/issuetracker/';
}
  SCheckedOutFalse = 'In';
  SCheckedOutTrue = 'Out';
  SCreateDir = 'Create directory ''%s''?';
  SDeletedFalse = '';
  SDeletedTrue = 'Deleted';
  SHiddenFalse = '';
  SHiddenTrue = 'Hidden';
  SInputFileNotFound = 'Input file ''%s'' not found';
  SModuleCheckoutNotAllowed = 'Checkout of module %d ''%s'' not allowed';
  SModuleCheckoutNotAllowed2 = 'Checkout of module %d ''%s'' not allowed: module is locked by user ''%s''';
  SModuleIDNotFound = 'Module %d not found';
  SModuleLocked = 'Module %d ''%s'' is locked by ''%s''';
  SModuleLockedPrompt = 'Module %d ''%s'' is locked by ''%s''. Continue anyway?';
  SModuleNoRevisions = 'No revisions found for module %d ''%s''';
  SModuleNotChanged = 'Module %d ''%s'' not changed';
  SModuleNotCheckedOut = 'Module %d ''%s'' is not checked out';
  SModuleNotFound = 'Module ''%s'' not found';
  SModuleUndoCheckoutError = 'Undo checkout of module %d ''%s''';
  SOverwriteFile = 'Overwrite file ''%s''?';
  SProjectDeleted = 'Project %d ''%s'' deleted';
  SProjectIDNotFound = 'Project %d not found';
  SProjectNotFound = 'Project ''%s'' not found';
  SProjectGroupIDNotFound = 'Project group %d not found';
  SProjectGroupNotFound = 'Project group ''%s'' not found';
  SRequiredLibNotFound = 'Required library ''%s'' not found';
  SUnknownCommand = 'Unknown command ''%s''. Use ''help'' to display available commands.';
  SUserNotFound = 'User ''%s'' not found';
  SCheckedOut = ' (Checkout)';
  SLabelNotFound = 'Label ''%s'' not found';
  SRevisionNotFound = 'Required revision %d.%d does not exist for ''%s''';

const
  CheckedOutStrings: array [Boolean] of string = (SCheckedOutFalse, SCheckedOutTrue);
  DeletedStrings: array [Boolean] of string = (SDeletedFalse, SDeletedTrue);
  HiddenStrings: array [Boolean] of string = (SHiddenFalse, SHiddenTrue);
  IndicatorStrings: array [Boolean] of string = ('', '*');
  IndicatorFileStrings: array [1..3] of string = ('', 'N', 'O');
  LinesPerPage = 20;

var
  StdInRedirected: Boolean = False;
  ExitSession: Boolean = False;
  ConsoleMode: Cardinal = 0;
  ExCode: Integer = ExitCodeUnspecified;
  Server: string = '';
  Port: string = '';
  UserName: string = '';
  Password: string = '';
  CommandLine: string = '';
  InputFileName: string = '';
  ProjectName: string = '';
  ProjectID: Integer = 0;
  SyncNoPrompt: Boolean = False;
  ModuleName: string = '';
  ModuleID: Integer = 0;
  LabelParamName: string = '';
  Connection: TJVCSConnection = nil;
  {$IFDEF BRANCHING}
  BranchName: string = '';
  {$ENDIF BRANCHING}

type
  TPromptOption = record
    AccelChar: Char;
    Text: array [0..35] of Char;
  end;

type
  THandleHiddenModules = (hmodIgnore, hmodInclude, hmodDelete);

const
  OptionsYesNo: array [0..1] of TPromptOption = (
    (AccelChar: 'Y'; Text: 'Yes'),
    (AccelChar: 'N'; Text: 'No'));
  OptionsYesNoAllBreak: array [0..3] of TPromptOption = (
    (AccelChar: 'Y'; Text: 'Yes'),
    (AccelChar: 'N'; Text: 'No'),
    (AccelChar: 'A'; Text: 'All'),
    (AccelChar: 'B'; Text: 'Break'));

function CheckCommandLine: Boolean; forward;
procedure CheckModule; forward;
procedure CheckModuleOrLocalFile; forward;
procedure CheckOpenProject; forward;
procedure CheckRequiredLibs; forward;
function CheckGetLabelID(const ALabel: string): Integer; forward;

function CmdProcOpenProject(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcCheckinModule(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcCheckoutModule(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcExit(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcAddProject(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcAddModule(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcSetModulePath(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcHistory(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcListLabels(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcLabelRevs(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcProjectRevs(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcModuleLabels(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcSharedBy(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcSharedModules(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcProjectLog(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcSearchModules(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcSearchComments(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcListTodo(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcAddTodo(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcDoneTodo(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcListMilestones(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcListBugs(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcBugSummary(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcAddBug(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcUpdateBug(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcAssignBug(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcListModules(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcListDeserted(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcRemoveModule(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcRenameModule(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcHideModule(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcGetComment(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcSetComment(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcHelp(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcInput(const Line: string; var ExtExitCode: Integer): Boolean; forward;
{$IFDEF BRANCHING}
function CmdProcListBranches(const Line: string; var ExtExitCode: Integer): Boolean; forward;
{$ENDIF BRANCHING}
function CmdProcListLocks(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcListProject(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcListProjects(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcSyncProject(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcSyncProjectGroup(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcUndoCheckout(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcLabelProject(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcGetModule(const Line: string; var ExtExitCode: Integer): Boolean; forward; //thu05.07.05
function CmdProcProjectInfo(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcRemoveProject(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcRestoreProject(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcRenameProject(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcLinkModule(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcProjectGroups(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcSetProjectGroup(const Line: string; var ExtExitCode: Integer): Boolean; forward;

function FmtStamp(DateTime: TDateTime): string; forward;
function GetParamStr(P: PChar; var Param: string): PChar; forward;
function HowIsFileDirty(const FileName: string; RefStamp: TDateTime): string; forward;
//--- replaced with function in JVCSClientFunctions function IsFileTypeAlwaysWritable(const FileExt: string): Boolean; forward;
function LineParamCount(const Line: string): Integer; forward;
function LineParamStr(const Line: string; Index: Integer): string; forward;
procedure ListModule(ProjectID, ModuleID: Integer); forward;
function PadR(const S: string; Length: Integer; Ch: Char = ' '): string; forward;
procedure ProcessLine(const Line: string); forward;
function Prompt(const Text: string; const Options: array of TPromptOption): Integer; forward;
function ReadPassword: string; forward;
procedure RunInteractiveSession; forward;
{$IFDEF BRANCHING}
procedure SelectBranchByName(const ABranchName: string); forward;
{$ENDIF BRANCHING}
procedure ShowBanner; forward;
procedure ShowCommand(Index: Integer); forward;
procedure ShowCommands; forward;
procedure ShowLog(JVCSClientObject: TJVCSClientObject); forward;
procedure ShowUsage; forward;
function StrAlign(const S: string; Width: Integer; PadChar: Char = ' '): string; forward;
function TrimLines(const Text: string; Chars: Integer): string; forward;
function internProjectHasModule(AProjectID, AModuleID: Integer): Boolean; forward;

type
  TCommandProc = function (const Line: string; var ExtExitCode: Integer): Boolean;
  TExecProc = procedure;
  TCommand = record
    Name: PChar;
    Syntax: PChar;
    HelpText: PChar;
    Proc: Pointer; // TCommandProc
  end;
  TSyncResult = (srSynced, srUpToDate);
  { ESasse 29.02.2004

    srSynced - The project was synchronized successfully, all modules were updated
    srUpToDate - The project is up-to-date, no modules must be synced
  }

const
  {$IFNDEF DELPHI6_UP}
  sLineBreak = #13#10;
  {$ENDIF ~DELPHI6_UP}

  Commands: array [0.. {$IFDEF BRANCHING} 51 {$ELSE} 50 {$ENDIF}] of TCommand = (

    (
      Name: 'openproject';
      Syntax: 'openproject <project_name> | <project_id>';
      HelpText: 'Opens a project for further processing, usefull if working with input files.';
      Proc: @CmdProcOpenProject),
    (
      Name: 'checkin';
      Syntax: 'checkin <module_name> | <module_id> [<comment>] [keep]';
      HelpText: 'Check in the specified module. A project containing the module is assumed to be already open.' + sLineBreak +
        'With keep as the last parameter the module stays checked out (Put, CHECKIN_MODULE with PutOnly, as the standalone Put):' + sLineBreak +
        'new revision on the server, lock and writable files kept; only for a module checked out by the current user.' + sLineBreak +
        'A check-in refused by the server raises an error with its reason (locked by, not checked out, revision already checked in).';
      Proc: @CmdProcCheckinModule),

    (
      Name: 'checkout';
      Syntax: 'checkout <module_name> | <module_id>';
      HelpText: 'Check out the specified module. A project containing the module is assumed to be already open.';
      Proc: @CmdProcCheckoutModule),

    (
      Name: 'exit';
      Syntax: 'exit';
      HelpText: 'Exit the interactive session.';
      Proc: @CmdProcExit),

    (
      Name: 'quit';
      Syntax: 'quit';
      HelpText: 'Exit the interactive session.';
      Proc: @CmdProcExit),

    (
      Name: 'help';
      Syntax: 'help [<command>]';
      HelpText: 'Display help for given <command>, or list of available commands.';
      Proc: @CmdProcHelp),

    (
      Name: 'input';
      Syntax: 'input <file_name>';
      HelpText: 'Execute commands from the specified external file.';
      Proc: @CmdProcInput),

    {$IFDEF BRANCHING}
    (
      Name: 'listbranches';
      Syntax: 'listbranches';
      HelpText: 'List all branches in the archive.';
      Proc: @CmdProcListBranches),
    {$ENDIF BRANCHING}

    (
      Name: 'listlocks';
      Syntax: 'listlocks [<user_name> | all_users ]';
      HelpText: 'List modules locked by <user_name> or all users. Default is current user.';
      Proc: @CmdProcListLocks),

    (
      Name: 'listproject';
      Syntax: 'listproject <project_name> | <project_id> [diffonly, newonly, oldonly] [includehidden]'; //thu 30.10.2003
      HelpText: 'List modules of the specified project. The second optional parameter will list different files only (diffonly)' + sLineBreak +
         'or NewerOnly (newonly) or OlderOnly (oldonly). Default is list all files'+ sLineBreak +  //thu 30.10.2003
        'If includehidden is given as parameter, also hidden modules are synchronized, '+ sLineBreak +  //thu 30.10.2003
        'default is no synchronizing hidden modules.' //thu 30.10.2003
      ;
      Proc: @CmdProcListProject),

    (
      Name: 'listprojects';
      Syntax: 'listprojects';
      HelpText: 'List all projects in the archive.';
      Proc: @CmdProcListProjects),

    (
      Name: 'syncproject';
      Syntax: 'syncproject <project_name> | <project_id> [noprompt] [stamp | crc | RO] [crossref] [includehidden|deletehidden] [extexitcode] [label="labelname"]';
      HelpText: 'Synchronize the specified project.' + sLineBreak +
        'Optional parameter noprompt will create directories and overwrite files without questions.' + sLineBreak +
        'The second optional parameter (crc) specifies whether files are to be checked by their timestamp (stamp) ' +
        'or CRC value (crc). Default is stamp.' + sLineBreak +
        'The third optional parameter (RO) specifies if a files RO/RW attribute should be checked against the expected value.' + sLineBreak +
        'Eg. a module which is not checked out should be read-only. Connected user and always writeable files are checked here.' + sLineBreak +
        'Changes which are only on file attributes are not written out.' + sLineBreak +
        'If crossref is given as parameter, also modules of all crossreferenced projects are synchronized, '+ sLineBreak +
        'default is synchronizing without crossreferences.'+ sLineBreak +
        'Hidden modules can be included to be synchronized with includehidden parameter or can be deleted in target folder '+ sLineBreak +
        'with deletehidden parameter. Deletehidden parameter has no effect on checked out modules.' + sLineBreak +
        'By default nothing is done for hidden modules. If extexitcode is given, a special exit code (3) will be returned ' + sLineBreak +
        'by the application when no modules were synchronized. If label is given as parameter, ' + sLineBreak +
        'the project will be restored to the labeled state. If label contains spaces, enclose with double quotes.'
        ;
      Proc: @CmdProcSyncProject),

    (
      Name: 'syncprojectgroup';
      Syntax: 'syncprojectgroup <prj_group_name> | <prj_group_id> [noprompt] [stamp | crc | RO] [crossref] [includehidden|deletehidden] [extexitcode] [label="labelname"]';
      HelpText: 'Synchronize all projects (and project groups, recursively) under the specified project group.' + sLineBreak +
        'If the group name contains spaces, enclose with double quotes.' + sLineBreak +
        'Note that group names are not unique and the first group with the given name will be synchronized.' + sLineBreak +
        'Optional parameter noprompt will create directories and overwrite files without questions.' + sLineBreak +
        'The second optional parameter specifies whether files are to be checked by their timestamp (stamp) ' +
        'or CRC value (crc). Default is stamp.' + sLineBreak +
        'The third optional parameter (RO) specifies if a files RO/RW attribute should be checked against the expected value.' + sLineBreak +
        'Eg. a module which is not checked out should be read-only. Connected user and always writeable files are checked here.' + sLineBreak +
        'Changes which are only on file attributes are not written out.' + sLineBreak +
        'If crossref is given as parameter, also modules of all crossreferenced projects are synchronized, '+ sLineBreak +
        'default is synchronizing without crossreferences.'+ sLineBreak +
        'Hidden modules can be included to be synchronized with includehidden parameter or can be deleted in target folder '+ sLineBreak +
        'with deletehidden parameter. Deletehidden parameter has no effect on checked out modules.' + sLineBreak +
        'By default nothing is done for hidden modules. If extexitcode is given, a special exit code (3) will be returned ' + sLineBreak +
        'by the application when no modules were synchronized. If label is given as parameter, ' + sLineBreak +
        'the project will be restored to the labeled state. If label contains spaces, enclose with double quotes.';
      Proc: @CmdProcSyncProjectGroup),

    (
      Name: 'addproject';
      Syntax: 'addproject <project_name> [<description>]';
      HelpText: 'Creates a new project on the server (same as the standalone Project Admin, New project). Does not open it.';
      Proc: @CmdProcAddProject),

    (
      Name: 'addmodule';
      Syntax: 'addmodule <file_name> [<description>]';
      HelpText: 'Adds a file to the open project on the server (same as the standalone Add module). Open the project first.';
      Proc: @CmdProcAddModule),

    (
      Name: 'setmodulepath';
      Syntax: 'setmodulepath <module_name> | <module_id> <folder>';
      HelpText: 'Sets the local folder of a module on the server (MOVE_MODULE, same request as the standalone Move module). Needed for modules created without the IDE.';
      Proc: @CmdProcSetModulePath),

    (
      Name: 'history';
      Syntax: 'history <module_name> | <module_id>';
      HelpText: 'Lists the revisions of a module (GET_MODULE_HISTORY, same data as the standalone History): ' + sLineBreak +
        'version, check-in time (local), user, size, family extensions and check-in comment.' + sLineBreak +
        'The comment is printed on one line: backslash as \\, line breaks as \n.';
      Proc: @CmdProcHistory),

    // Project administration. The wrapper (tools\ai\jvcs-ai.ps1, Assert-Console2026) looks for these
    // phrases in the executable: keep each one inside a single literal of the help texts below:
    // 'projectinfo <project_name>', 'REMOVE_PROJECT, same as', 'RESTORE_PROJECT, same as',
    // 'RENAME_PROJECT, same as' and 'ADD_NEW_MODULE with the stored path'.
    (
      Name: 'projectinfo';
      Syntax: 'projectinfo <project_name> | <project_id>';
      HelpText: 'Prints a project and its links, one value per line (also for deleted projects): Project, ProjectID, Deleted (0/1),' + sLineBreak +
        'Module: id|hidden(0/1)|other_project_ids|path|name, Locked: id|owner|version|path_and_name,' + sLineBreak +
        'Reference: id|name, ReferencedBy: id|name, Group: id|name, Right: user_id|level, Bug: id|name and Summary.' + sLineBreak +
        'Read only (rebinds the session rights to that project: use openproject again before other commands);' + sLineBreak +
        'used as preview and record before removeproject/renameproject.';
      Proc: @CmdProcProjectInfo),

    (
      Name: 'removeproject';
      Syntax: 'removeproject <project_name> | <project_id> confirm';
      HelpText: 'Removes a project (REMOVE_PROJECT, same as the standalone Remove project; needs the Archive Admin level' + sLineBreak +
        'for that project: its project right, else the global level).' + sLineBreak +
        'Only the project is flagged as deleted, but the server also deletes its module links, project rights,' + sLineBreak +
        'references (also the references from other projects), group links and bug links;' + sLineBreak +
        'modules and revisions stay in the archive.' + sLineBreak +
        'Refused while any module of the project is checked out (by any user). The literal confirm is required.';
      Proc: @CmdProcRemoveProject),

    (
      Name: 'restoreproject';
      Syntax: 'restoreproject <project_name> | <project_id> confirm';
      HelpText: 'Restores a deleted project (RESTORE_PROJECT, same as the standalone Restore project; needs Archive Admin).' + sLineBreak +
        'Only clears the deleted flag: module links, rights, references and groups removed by removeproject' + sLineBreak +
        'are not restored (use linkmodule and setprojectgroup). The literal confirm is required.';
      Proc: @CmdProcRestoreProject),

    (
      Name: 'renameproject';
      Syntax: 'renameproject <project_name> | <project_id> <new_name> [renamefiles] confirm';
      HelpText: 'Renames a project (RENAME_PROJECT, same as the standalone Rename project; needs read-write).' + sLineBreak +
        'The new name must be unused (also by deleted projects) and keep the file extension.' + sLineBreak +
        'With renamefiles the project modules (.dpr .dpk .dproj .res .dof .cfg .dsk with the old name) are renamed' + sLineBreak +
        'on the server too (RENAME_MODULE), except modules shared with other projects; every module is read back' + sLineBreak +
        '(Module renamed: / Module not renamed: id|old|new[|reason]). Local files are never renamed.' + sLineBreak +
        'Refused while any module of the project is checked out. The literal confirm is required.';
      Proc: @CmdProcRenameProject),

    (
      Name: 'linkmodule';
      Syntax: 'linkmodule <module_id> <module_path_and_name> [hidden]';
      HelpText: 'Links an existing module to the open project again (ADD_NEW_MODULE with the stored path and name),' + sLineBreak +
        'e.g. after restoreproject. Refused when path and name do not resolve to <module_id> (the server would' + sLineBreak +
        'create a new, empty module). hidden hides the link afterwards (HIDE_UNHIDE_MODULE). Open the project first.';
      Proc: @CmdProcLinkModule),

    (
      Name: 'projectgroups';
      Syntax: 'projectgroups';
      HelpText: 'Lists project groups (Group: id|parent_id|level|name) and their members (Member: group_id|project_id).';
      Proc: @CmdProcProjectGroups),

    (
      Name: 'setprojectgroup';
      Syntax: 'setprojectgroup <project_name> | <project_id> <group_id> add | remove';
      HelpText: 'Adds the project to an existing project group or removes it from the group (ADD_REMOVE_PROJECT_TO_GROUP).';
      Proc: @CmdProcSetProjectGroup),

    (
      Name: 'projectlog';
      Syntax: 'projectlog <project_name> | <project_id> [since=yyyy-mm-dd[Thh:nn[:ss]]] [user=<user_name>] [max=<n>] [norev]';
      HelpText: 'Lists the check-ins of the modules of a project (GET_LOG_ENTRIES, check-ins of the server log; ' + sLineBreak +
        'shared modules included even when checked in from another project), oldest first.' + sLineBreak +
        'since is local time; max=n keeps the n most recent (0 = all); norev skips the version lookup.' + sLineBreak +
        'Without since/max it reads the whole server log (slow on big archives).' + sLineBreak +
        'Columns: log ID, check-in time (local), user, version, revision ID, module ID, op (ci or put), then' + sLineBreak +
        'module | via project | comment, escaped as in history (backslash as \\, line breaks as \n).' + sLineBreak +
        'Header line "Server log: on|off|unknown" tells whether the server writes this log (WriteVCSLog).';
      Proc: @CmdProcProjectLog),

    (
      Name: 'searchmodules';
      Syntax: 'searchmodules <mask>';
      HelpText: 'Finds modules by name or mask in all projects of the archive (SEARCH_MODULES, all projects, same request as the standalone Search modules).' + sLineBreak +
        'Wildcards * and ? (case-insensitive). A mask with a folder (c:\src\*.pas) also filters the module path.' + sLineBreak +
        'One row per module and project: module ID, project name and path|name on the rest of the line.';
      Proc: @CmdProcSearchModules),

    (
      Name: 'searchcomments';
      Syntax: 'searchcomments <text> <project_name> | <project_id> [maxmodules=<n>]';
      HelpText: 'Searches <text> (case-insensitive) in the check-in and check-out comments of a project:' + sLineBreak +
        'scans GET_MODULE_HISTORY of each module (one request per module, at most maxmodules, default 300).' + sLineBreak +
        'Hit: I = check-in comment, O = check-out comment (IO prints the check-in comment). Time as in history (local).' + sLineBreak +
        'The comment is printed on one line: backslash as \\, line breaks as \n.';
      Proc: @CmdProcSearchComments),

    (
      Name: 'listlabels';
      Syntax: 'listlabels [<project_name> | <project_id>]';
      HelpText: 'Lists the labels of the archive (GET_LABELS), or only the labels used in a project' + sLineBreak +
        'with the number of its modules carrying each one, hidden modules included (GET_LABELS_BY_PROJECT).' + sLineBreak +
        'Columns: label ID, label, [modules,] description. Label and description escaped on one line (backslash as \\, line breaks as \n).';
      Proc: @CmdProcListLabels),

    (
      Name: 'labelrevs';
      Syntax: 'labelrevs <project_name> | <project_id> <label_name> | #<label_id>';
      HelpText: 'Lists the revision of each module of the project that carries the label' + sLineBreak +
        '(GET_LATEST_REVISIONS filtered by label, hidden modules excluded): module ID, version, revision ID,' + sLineBreak +
        'family extensions and module name. If the label contains spaces, enclose with double quotes.';
      Proc: @CmdProcLabelRevs),

    (
      Name: 'projectrevs';
      Syntax: 'projectrevs <project_name> | <project_id> latest | label=<label_name>|#<label_id> | version=<n>[.<m>] | date=yyyy-mm-dd[Thh:nn[:ss]] [includehidden]';
      HelpText: 'Lists the revision of each module of the project in one state, as the standalone Synchronize/Restore tabs:' + sLineBreak +
        'latest (GET_LATEST_REVISIONS); label= (the labeled revision); version=n (newest revision of version n of each' + sLineBreak +
        'module) or version=n.m (exactly n.m, GET_VERSION_REVISION, tab Restore version number); date= in local time' + sLineBreak +
        '(GET_ROLLBACK_REVISIONS, same as the standalone Rollback: per module the newest revision whose files all have' + sLineBreak +
        'a file date not after that time; the file date is the one history shows, not the check-in time).' + sLineBreak +
        'Hidden modules are excluded unless includehidden is given; modules without a revision in that state are not listed.' + sLineBreak +
        'Columns: module ID, version, revision ID, file date (local, newest member), family extensions, then path|name' + sLineBreak +
        '(escaped as in history: backslash as \\). Read only: nothing is written to disk.';
      Proc: @CmdProcProjectRevs),

    (
      Name: 'modulelabels';
      Syntax: 'modulelabels <module_name> | <module_id>';
      HelpText: 'Lists the labels of each revision of a module (GET_LABELS_BY_MODULE, or GET_LABELS_BY_REVISION' + sLineBreak +
        'on older servers): version, revision ID, label ID, label and description (escaped on one line, as in history).';
      Proc: @CmdProcModuleLabels),

    (
      Name: 'sharedby';
      Syntax: 'sharedby <module_name> | <module_id>';
      HelpText: 'Lists the projects that share a module (GET_SHARED_BY), the current one included.' + sLineBreak +
        'One project: the module is not shared.';
      Proc: @CmdProcSharedBy),

    (
      Name: 'sharedmodules';
      Syntax: 'sharedmodules <project_name> | <project_id>';
      HelpText: 'Lists the modules of a project that are shared with other projects, one line per module and project' + sLineBreak +
        '(GET_SHARED_MODULES + GET_SHARED_BY): module ID, project ID, project, module name.';
      Proc: @CmdProcSharedModules),

    (
      Name: 'listmodules';
      Syntax: 'listmodules [<project_name> | <project_id>]';
      HelpText: 'Lists every module linked to the project (GET_PROJECT_MODULE_LIST), also modules without revisions or ' +
        'without folder that listproject does not show.' + sLineBreak +
        'One row per module: ID, flags and path|name. Flags: H hidden, B no revisions (GET_BLANK_MODULE_LIST), ' +
        'N no folder, P name contains a path.';
      Proc: @CmdProcListModules),

    (
      Name: 'listdeserted';
      Syntax: 'listdeserted';
      HelpText: 'Lists modules not linked to any project (GET_DESERTED_MODULES, same as the standalone Show deserted modules): ID, flags (D) and path|name.';
      Proc: @CmdProcListDeserted),

    (
      Name: 'removemodule';
      Syntax: 'removemodule <module_name> | <module_id> [archive confirm]';
      HelpText: 'Removes the module from the open project (REMOVE_MODULE, same request as the standalone Remove module).' + sLineBreak +
        'Without archive only the project link is removed: module and revisions stay in the archive (listdeserted).' + sLineBreak +
        'With archive confirm the module and ALL its revisions are deleted from the archive (not reversible); refused for shared modules.' + sLineBreak +
        'A deserted module (listdeserted) can be given with archive confirm. A 2.5 server with branches refuses archive for a' + sLineBreak +
        'module with revisions (status 400, nothing changed): there only modules without revisions are deleted.' + sLineBreak +
        'Refused while the module is checked out by anybody. No prompt: archive needs the word confirm.';
      Proc: @CmdProcRemoveModule),

    (
      Name: 'renamemodule';
      Syntax: 'renamemodule <module_name> | <module_id> <new_name>';
      HelpText: 'Renames the module in the archive (RENAME_MODULE): file name only, same extension, lower case.' + sLineBreak +
        'Affects every project sharing the module; local files are not renamed. Refused while checked out.';
      Proc: @CmdProcRenameModule),

    (
      Name: 'hidemodule';
      Syntax: 'hidemodule <module_name> | <module_id> [unhide]';
      HelpText: 'Hides (or with unhide shows again) the module in the open project (HIDE_UNHIDE_MODULE). Refused while checked out.';
      Proc: @CmdProcHideModule),

    (
      Name: 'getcomment';
      Syntax: 'getcomment <revision_id>';
      HelpText: 'Shows the check-in and check-out comments of a revision (GET_REVISION_COMMENT), on one line each (\\ and \n escaped).';
      Proc: @CmdProcGetComment),

    (
      Name: 'setcomment';
      Syntax: 'setcomment <module_name> | <module_id> <revision_id> in|out <"comment">';
      HelpText: 'Changes the check-in (in) or check-out (out) comment of a revision of the module (CHANGE_REVISION_COMMENT).' + sLineBreak +
        'The module must belong to the open project and the revision to the module. In the text \n is a line break and \\ a backslash.' + sLineBreak +
        'The old comment is printed first. The server keeps no log of this change.';
      Proc: @CmdProcSetComment),

    (
      Name: 'labelproject';
      Syntax: 'labelproject <project_name> | <project_id> <"label"> [crossref]';
      HelpText: 'Stamp project with given label.' + sLineBreak +
        'Label will be created, if not existing, if label contains spaces, enclose with double quotes.' + sLineBreak +
        'Last column: added, or kept x.y when the label already was on revision x.y of the module (the server does not move labels).';
      Proc: @CmdProcLabelProject),

    (
      Name: 'listtodo';
      Syntax: 'listtodo [project=<project_name>|<project_id>|all] [user=<login>|me|all] [category=<text>] [priority=<1-9>] [due=<yyyy-mm-dd>] [includedone]';
      HelpText: 'Lists ToDo items (GET_TODO_ENTRIES, same data as the standalone ToDo list): id, priority, status, ' + sLineBreak +
        'last change, target and done dates (local), responsible, project, category and description.' + sLineBreak +
        'Default: the open project (or all), all users, open items only. user= filters the responsible (me = current user);' + sLineBreak +
        'due= lists items with a target date up to that day.' + sLineBreak +
        'The description is printed on one line: backslash as \\, line breaks as \n.';
      Proc: @CmdProcListTodo),

    (
      Name: 'addtodo';
      Syntax: 'addtodo <project_name> | <project_id> <"description"> [priority=<1-9>] [category=<text>] [user=<login>|me] [due=<yyyy-mm-dd>]';
      HelpText: 'Creates a ToDo item in the project (ADD_UPDATE_TODO_ENTRIES, new item, same as the standalone ToDo list).' + sLineBreak +
        'Defaults: priority=3 (1 = highest), user=me (responsible), no category, no target date (due is a local date).';
      Proc: @CmdProcAddTodo),

    (
      Name: 'donetodo';
      Syntax: 'donetodo <todo_id> [reopen]';
      HelpText: 'Marks a ToDo item as done now, or open again with reopen (ADD_UPDATE_TODO_ENTRIES, rewrites the item' + sLineBreak +
        'with the values read from the server, as the standalone does; the server also resets its timestamp).';
      Proc: @CmdProcDoneTodo),

    (
      Name: 'listmilestones';
      Syntax: 'listmilestones [<project_name> | <project_id> | all]';
      HelpText: 'Lists the milestones (GET_MILESTONES and GET_PROJECT_MILESTONES): the defined milestones and those' + sLineBreak +
        'reached by the project (default: the open project, or all), with reach time (local), confirmed by and description.';
      Proc: @CmdProcListMilestones),

    (
      Name: 'listbugs';
      Syntax: 'listbugs [module <module_name> | <module_id>] | [project <project_name> | <project_id>] | [bug <bug_id>]';
      HelpText: 'Lists bugs (GET_BUGS, GET_BUGS_BY_MODULE/GET_BUGS_BY_PROJECT, same data as the standalone Bugs windows): ' + sLineBreak +
        'all bugs of the archive, the bugs assigned to a module or project (Done = yes/no for that assignment), ' + sLineBreak +
        'or one bug with the modules and projects it is assigned to (BUGS_USED_BY, lines "  link: m|p <id> <name>").' + sLineBreak +
        'Columns: BugID, severity (0 Minor, 1 Awkward, 2 Significant, 3 Serious, 4 Fatal), status (0 Unknown, 1 Open, ' + sLineBreak +
        '2 Scheduled, 3 Fixed, 4 Ignored), Done, creation time (local), creator, flags and the bug name; then the lines ' + sLineBreak +
        '"  keywords:", "  reportedby:", "  description:" and "  workaround:". Texts on one line: backslash as \\, line breaks as \n.';
      Proc: @CmdProcListBugs),

    (
      Name: 'bugsummary';
      Syntax: 'bugsummary <modules | projects>';
      HelpText: 'For each module (or project) with open bug assignments (Done = no), the bug with the highest severity ' + sLineBreak +
        '(GET_MOST_SEVERE_BUGS, as the bug icons of the standalone). Columns: ItemID, BugID, severity.';
      Proc: @CmdProcBugSummary),

    (
      Name: 'addbug';
      Syntax: 'addbug <bug_name> [severity=<0-4>] [status=<0-4>] [keywords="<text>"] [reportedby="<text>"] [description="<text>" | descriptionfile="<file>"] [workaround="<text>" | workaroundfile="<file>"]';
      HelpText: 'Creates a bug in the archive (ADD_UPDATE_BUG, same request as the standalone Maintain bugs, Add). ' + sLineBreak +
        'Defaults: severity 0 (Minor), status 1 (Open). The bug name must be unique (compared without case). ' + sLineBreak +
        'descriptionfile and workaroundfile read a text file in code page 1252 (line breaks kept), for texts with quotes ' + sLineBreak +
        'or several lines. Limits: name and keywords 250 characters, the other texts 2000.';
      Proc: @CmdProcAddBug),

    (
      Name: 'updatebug';
      Syntax: 'updatebug <bug_id> [name="<bug_name>"] [severity=<0-4>] [status=<0-4>] [keywords="<text>"] [reportedby="<text>"] [description="<text>" | descriptionfile="<file>"] [workaround="<text>" | workaroundfile="<file>"]';
      HelpText: 'Changes the given fields of a bug (ADD_UPDATE_BUG). The server overwrites every field, so the bug is read ' + sLineBreak +
        'first (GET_BUGS) and the fields not given are sent unchanged; flags are kept; key= with no value clears a text. ' + sLineBreak +
        'The bug is read again to confirm the change. Example: updatebug 12 status=3 (Fixed).';
      Proc: @CmdProcUpdateBug),

    (
      Name: 'assignbug';
      Syntax: 'assignbug <bug_id> module <module_name> | <module_id> | project <project_name> | <project_id> [add | remove | done | open]';
      HelpText: 'Assigns a bug to a module or project, removes the assignment, or marks the assignment done/open ' + sLineBreak +
        '(ASSIGN_REMOVE_BUG and ENABLE_MODULE_PROJECT_BUG, same requests as the standalone Assign bugs). Default: add. ' + sLineBreak +
        'Prints "Bug <result>: bug <bug_id> module|project <id> <name>".';
      Proc: @CmdProcAssignBug),

    (
      Name: 'undocheckout';
      Syntax: 'undocheckout <module_name> | <module_id> [noprompt]';
      HelpText: 'Undo checkout of the specified module. A project containing the module is assumed to be already open.';
      Proc: @CmdProcUndoCheckout),


    (
      Name: 'getmodule';
      Syntax: 'getmodule <module_name> | <module_id> [rev=ver.rev] [dest="destinationpath"] [noprompt]';
      HelpText: 'Get the revision of the specified module. A project containing the module is assumed to be already open.' + sLineBreak +
        'Parameter rev="rev" allows to get exactly this revision of the moduel, if not given getmodule gets the most recent revision.' + sLineBreak +
        'dest parameter allows to get the revision to a different folder as stored in the VCS. If this parameter is omitted,' + sLineBreak +
        'getmodule saves the revision of the module to the folder stored in the VCS.' + sLineBreak +
        'Optional parameter noprompt will create directories and overwrite file without questions.';
      Proc: @CmdProcGetModule)

);


//Todo Change from registry to server based property values (>=2.50)
procedure SetVCSReadOnlyFile(const sFile, sFamilyExtensions: string);
const
  cDefWritableFiles = '*.prl;*.pcr;*.dof;*.dpr;*.res;*.fvc;*.dpk;*.dsk;*.cfg;*.todo';
var
  ii: Integer;
  sNotReadOnlyFilter: string;
  sBaseRegistryKey: string;
  slFamilyExtensions: TStringList;
  sProcessFile: string;
  sExt: string;
  bReadOnlyFlag: Boolean;
begin
  // Defaults
  sBaseRegistryKey := '';
  sNotReadOnlyFilter := cDefWritableFiles;
  // get JEDIVCS base key
  with TRegistry.Create do
  begin
    rootKey := HKEY_CURRENT_USER;
    try
      if OpenKeyReadOnly('Software\JEDI\JEDIVCS') then
      begin
        if ValueExists('BaseRegistryKey') then
        begin
          sBaseRegistryKey := ReadString('BaseRegistryKey');
        end;
        CloseKey;
      end;
    finally
      Free;
    end; // try finally
  end;

  if sBaseRegistryKey <> '' then
  begin
    // Get fileextensions for always writeable files
    with TRegistry.Create do
    begin
      rootKey := HKEY_CURRENT_USER;
      try
        if OpenKeyReadOnly(sBaseRegistryKey + '\Version Control\JEDIVCS\Options\AddFilters') then
        begin
          if ValueExists('Writeable Files') then
          begin
            sNotReadOnlyFilter := ReadString('Writeable Files');
          end;
          CloseKey;
        end;
      finally
        Free;
      end; // try finally
    end; // with Reg do begin

    // prepare action
    sProcessFile := sFile;
    slFamilyExtensions := TStringList.Create;
    try
      slFamilyExtensions.Duplicates := dupIgnore;
      StrTokenToStrings(AnsiLowerCase(sFamilyExtensions), ';', slFamilyExtensions);

      // Set file readonly if extension not matching always writable files
      bReadOnlyFlag := not MatchWithFilter(ExtractFileName(sFile), sNotReadOnlyFilter);
      // set parent ro-attrib
      FileSetReadOnlyAttribute(sProcessFile, bReadOnlyFlag);
      // process 'childs'
      for ii := 0 to slFamilyExtensions.Count-1 do
      begin
        sExt := ExtractFileExt(slFamilyExtensions[ii]);
        FileSetReadOnlyAttribute(ChangeFileExt(sProcessFile,sExt), bReadOnlyFlag);
      end;

      // now set always writeable files to RW
      StrTokenToStrings(AnsiLowerCase(sNotReadOnlyFilter), ';', slFamilyExtensions);
      for ii := 0 to slFamilyExtensions.Count-1 do
      begin
        sExt := ExtractFileExt(slFamilyExtensions[ii]);
        FileSetReadOnlyAttribute(ChangeFileExt(sProcessFile,sExt), bReadOnlyFlag);
      end;

    finally
      slFamilyExtensions.Free;
    end;
  end;
end;

function CheckCommandLine: Boolean;
var
  I, J, Index: Integer;
  S: string;
begin
  Result := False;
  I := 1;
  // check server/port
  if ParamCount >= 1 then
  begin
    S := ParamStr(1);
    if not (S[1] in SwitchChars) then
    begin
      Server := S;
      J := Pos(':', S);
      if J <> 0 then
      begin
        Port := Copy(S, J + 1, Length(S));
        Delete(Server, J, Length(S));
      end;
      I := 2;
    end;
  end;

  while I <= ParamCount do
  begin
    S := ParamStr(I);
    if not (S[1] in SwitchChars) then
      Exit;
    Delete(S, 1, 1);

    if AnsiCompareText(S, 'user') = 0 then
    begin
      Inc(I);
      if I > ParamCount then
        Exit;
      UserName := ParamStr(I);
    end
    else
    if AnsiCompareText(S, 'password') = 0 then
    begin
      Inc(I);
      if I > ParamCount then
        Exit;
      Password := ParamStr(I);
    end
    {$IFDEF BRANCHING}
    else
    if AnsiCompareText(S, 'branch') = 0 then
    begin
      Inc(I);
      if I > ParamCount then
        Exit;
      BranchName := ParamStr(I);
    end
    {$ENDIF BRANCHING}
    else
    begin
      Index := -1;
      for J := Low(Commands) to High(Commands) do
        if AnsiCompareText(S, Commands[J].Name) = 0 then
        begin
          Index := J;
          Break;
        end;
      if Index = -1 then
        Exit
      else
      begin
        CommandLine := StrPos(CmdLine, Commands[Index].Name);
        Break;
      end;
    end;

    Inc(I);
  end;

  Result := True;
end;

procedure CheckModule;
var
  GetModuleId: TJVCSGetModuleId;
  GetModuleName: TJVCSGetModuleName;
begin
  if ModuleName = '' then
  begin
    GetModuleName := TJVCSGetModuleName.Create(nil);
    try
      GetModuleName.ModuleID := ModuleID;
      Connection.SendRequest(GetModuleName);
      ShowLog(GetModuleName);
      ModuleName := GetModuleName.ModuleName;
      if ModuleName = '' then
      begin
        if GetModuleName.ErrorMessage = '' then
          raise Exception.CreateFmt(SModuleIDNotFound, [ModuleID])
        else
          raise Exception.Create(GetModuleName.ErrorMessage);
      end;
    finally
      GetModuleName.Free;
    end;
  end
  else
  begin
    GetModuleId := TJVCSGetModuleId.Create(nil);
    try
      GetModuleId.ModuleName := ModuleName;
      Connection.SendRequest(GetModuleId);
      ShowLog(GetModuleId);
      ModuleID := GetModuleId.ModuleID;
      if ModuleID = 0 then
      begin
        if GetModuleId.ErrorMessage = '' then
          raise Exception.CreateFmt(SModuleNotFound, [ModuleName])
        else
          raise Exception.Create(GetModuleId.ErrorMessage);
      end;
    finally
      GetModuleId.Free;
    end;
  end;
end;

// Modules with a stored folder are found by the full name. When only the short
// name was given and that file exists in the current directory, retry with it.
procedure CheckModuleOrLocalFile;
begin
  try
    CheckModule;
  except
    if (ModuleName <> '') and (ExtractFilePath(ModuleName) = '') and
      FileExists(ExpandFileName(ModuleName)) then
    begin
      ModuleName := ExpandFileName(ModuleName);
      CheckModule;
    end
    else
      raise;
  end;
end;

procedure CheckOpenProject;
var
  GetProjectInformation: TJVCSGetProjectInformation;
  GetProjectId: TJVCSGetProjectId;
begin
  if (ProjectName = '') and (ProjectID <> 0) then
  begin
    GetProjectInformation := TJVCSGetProjectInformation.Create(nil);
    try
      GetProjectInformation.ProjectID := ProjectID;
      Connection.SendRequest(GetProjectInformation);
      ShowLog(GetProjectInformation);
      if (GetProjectInformation.OutputItemCount = 0) or (GetProjectInformation.OutputItems[0].ProjectID = 0) then
        raise Exception.CreateFmt(SProjectIDNotFound, [ProjectID]);
      ProjectName := GetProjectInformation.OutputItems[0].ProjectName;
    finally
      GetProjectInformation.Free;
    end;
  end;

  GetProjectId := TJVCSGetProjectId.Create(nil);
  try
    GetProjectId.ProjectName := ProjectName;
    Connection.SendRequest(GetProjectId);
    ShowLog(GetProjectId);
    if GetProjectId.ProjectID = 0 then
      raise Exception.CreateFmt(SProjectNotFound, [ProjectName]);
    ProjectID := GetProjectId.ProjectID;
  finally
    GetProjectId.Free;
  end;

  if GetProjectId.ProjectDeleted then
    raise Exception.CreateFmt(SProjectDeleted, [ProjectID, ProjectName]);
end;

procedure CheckRequiredLibs;
  procedure CheckLib(const LibName: string);
  var
    Lib: HMODULE;
  begin
    Lib := LoadLibrary(PChar(LibName));
    if Lib = 0 then
      raise Exception.CreateFmt(SRequiredLibNotFound, [LibName]);
    FreeLibrary(Lib);
  end;
begin
  CheckLib('FVCSCrypt.dll');
end;

function CheckGetLabelID(const ALabel: string): Integer;
var
  GetLabels: TJVCSGetLabels;
  I: Integer;
begin
  Result := 0;
  GetLabels := TJVCSGetLabels.Create(nil);
  try
    GetLabels.IncludeDescription := False;
    Connection.SendRequest(GetLabels);
    for I := 0 to Pred(GetLabels.OutputItemCount) do
      if SameText(GetLabels.OutputItems[I].LabelName, ALabel) then
      begin
        Result := GetLabels.OutputItems[I].LabelID;
        Break;
      end;
  finally
    GetLabels.Free;
  end;
  if Result = 0 then
    raise Exception.CreateFmt(SLabelNotFound, [ALabel]);
end;

// just open a project for further use => sets globals ProjectName, ProjectID
function CmdProcOpenProject(const Line: string; var ExtExitCode: Integer): Boolean;
var
  Count: Integer;
  S: string;
  nTemp: Integer;
begin
  Result := False;
  ProjectID := 0;
  ProjectName := '';
  Count := LineParamCount(Line);
  if (Count in [2]) then
  begin
    S := LineParamStr(Line, 2);
    nTemp := StrToIntDef(S,-1);
    if nTemp <> -1 then
    begin
      ProjectID := nTemp;
      ProjectName := '';
    end
    else
    begin
      ProjectID := 0;
      ProjectName := S;
    end;
    CheckOpenProject;
    Result := True;
  end;
end;

// First check-in of a module that has no revisions yet (version 0.1), the same
// request the standalone sends after Add module. The local file is taken from
// the current directory (ExpandFileName), so run the command from the project folder.
function internCheckinFirstRevision(const CheckinComment: string): Boolean;
var
  GetFamilyExtensions: TJVCSGetFamilyExtensions;
  FamilyID: Integer;
  FamilyExtensions: string;
  ZipFileName: string;
  ModuleFileName: string;
  CheckinModule: TJVCSCheckinModule;
  ModuleOriginalTime: TDateTime;
  ModuleOriginalSize, ModuleOriginalCRC, ModuleCompressedSize: Integer;
  ModuleFileStream: TFileStream;
  CrcErr: string;
  MemberFiles, FamilyList, ZipFiles: TStringList;
  MemberFile: string;
  I: Integer;
  RefuseReason: string;
begin
  Result := False;
  ModuleFileName := ExpandFileName(ModuleName);
  if not FileExists(ModuleFileName) then
    raise Exception.CreateFmt('Local file not found: %s (run the command from the folder that holds the file)',
      [ModuleFileName]);

  GetFamilyExtensions := TJVCSGetFamilyExtensions.Create(nil);
  try
    GetFamilyExtensions.ParentExtension := ExtractFileExt(ModuleName);
    Connection.SendRequest(GetFamilyExtensions);
    ShowLog(GetFamilyExtensions);
    FamilyID := GetFamilyExtensions.FamilyID;
    FamilyExtensions := GetFamilyExtensions.FamilyExtensions;
  finally
    GetFamilyExtensions.Free;
  end;

  // the module file plus the family members that exist beside it (e.g. the .dfm
  // of a unit), as the standalone sends them
  MemberFiles := TStringList.Create;
  FamilyList := TStringList.Create;
  ZipFiles := TStringList.Create;
  try
    MemberFiles.Add(ModuleFileName);
    StrTokenToStrings(AnsiLowerCase(FamilyExtensions), ';', FamilyList);
    for I := 0 to FamilyList.Count - 1 do
    begin
      MemberFile := ChangeFileExt(ModuleFileName, ExtractFileExt(Trim(FamilyList[I])));
      if (ExtractFileExt(MemberFile) <> '') and FileExists(MemberFile) and
        (MemberFiles.IndexOf(MemberFile) < 0) then
        MemberFiles.Add(MemberFile);
    end;

    CheckinModule := TJVCSCheckinModule.Create(nil);
    try
      CheckinModule.PutOnly := False;
      for I := 0 to MemberFiles.Count - 1 do
      begin
        MemberFile := MemberFiles[I];
        if not JVCSCompressFile(MemberFile, ZipFileName) then
          raise Exception.CreateFmt('Could not compress %s', [MemberFile]);
        ZipFiles.Add(ZipFileName);
        ModuleOriginalTime := FileGetUTCDateTime(MemberFile);
        ModuleOriginalSize := GetSizeOfFile(MemberFile);
        ModuleOriginalCRC := CRCInt(MemberFile, CrcErr);
        ModuleCompressedSize := GetSizeOfFile(ZipFileName);
        ModuleFileStream := TFileStream.Create(ZipFileName, fmOpenRead);
        try
          CheckinModule.AddInputItem(ProjectID, Connection.UserID, ModuleID, 0
                                    , 0, 0, 1
                                    , ModuleOriginalTime, ModuleOriginalSize, ModuleOriginalCRC
                                    , ModuleCompressedSize, ExtractFileExt(MemberFile)
                                    , ModuleFileStream, CheckinComment, 0
                                    , MemberFile, FamilyID);
        finally
          ModuleFileStream.Free;
        end;
      end;
      Connection.SendRequest(CheckinModule);
      ShowLog(CheckinModule);
      // JVCS 2026: a refused first check-in is an error with the reason, as in the normal
      // check-in (before: 'First check-in failed', the syntax help and exit code 0)
      if (not CheckinModule.CheckinAllowed) or (CheckinModule.ErrorMessage <> '') then
      begin
        RefuseReason := Trim(string(CheckinModule.ErrorMessage));
        if RefuseReason = '' then
          RefuseReason := 'no reason given by the server';
        raise Exception.CreateFmt('First check-in of module %d ''%s'' refused by server: %s',
          [ModuleID, ModuleFileName, RefuseReason]);
      end;
      Result := True;
      Writeln('First check-in: ', ModuleFileName, ' (version 0.1, ', MemberFiles.Count, ' file(s))');
      SetVCSReadOnlyFile(ModuleFileName, FamilyExtensions);
    finally
      CheckinModule.Free;
    end;
  finally
    for I := 0 to ZipFiles.Count - 1 do
      DeleteFile(PChar(ZipFiles[I]));
    ZipFiles.Free;
    FamilyList.Free;
    MemberFiles.Free;
  end;
end;

function CmdProcCheckinModule(const Line: string; var ExtExitCode: Integer): Boolean;
var
  Count, I: Integer;
  S: string;
  CheckinComment: string;
  GetRevisionListById: TJVCSGetRevisionListById;
  LatestRevision: TGetRevisionListByIdOutputItem;
  GetRevisionStatus: TJVCSGetRevisionStatus;
  ModuleFileName: string;
  ModuleFilesDirty: Boolean;
  ZipFileName: string;
  GetFamilyExtensions: TJVCSGetFamilyExtensions;
  FamilyID: Integer;
  FamilyExtensions: string;
  CheckinModule: TJVCSCheckinModule;
  ZipFiles: TStringList;
  ModuleOriginalTime: TDateTime;
  ModuleOriginalSize, ModuleOriginalCRC, ModuleCompressedSize: Integer;
  ModuleFileStream: TFileStream;
  CrcErr: string;
  KeepCheckout: Boolean;
  RefuseReason: string;
begin
  Result := False;
  ModuleID := -1;
  ModuleName := '';
  Count := LineParamCount(Line);
  // JVCS 2026: "keep" as the last parameter = Put (check in and keep the checkout)
  KeepCheckout := (Count >= 3) and (AnsiCompareText(LineParamStr(Line, Count), 'keep') = 0);
  if KeepCheckout then
    Dec(Count); // the comment, when given, is still parameter 3
  if (Count in [2, 3]) then
  begin
    S := LineParamStr(Line, 2);
    ModuleID := StrToIntDef(S, -1);
    if ModuleID = -1 then
      ModuleName := S;
    try
      CheckOpenProject;
      CheckModuleOrLocalFile;
      if Count = 3 then
        CheckinComment := LineParamStr(Line, 3)
      else
        CheckinComment := '';
      // get information about latest revision of the specified module
      FillChar(LatestRevision, SizeOf(TGetRevisionListByIdOutputItem), 0);
      GetRevisionListById := TJVCSGetRevisionListById.Create(nil);
      try
        GetRevisionListById.ProjectID := 0; // has to be zero, not projectId
        GetRevisionListById.ModuleID := ModuleID;
        Connection.SendRequest(GetRevisionListById);
        ShowLog(GetRevisionListById);
        // a module just added (addmodule) has no revisions yet. Note: a module added
        // with an empty description gets a placeholder revision 0.1 from the server,
        // which refuses the first check-in ("Revision already checked in"); addmodule
        // therefore always sends a description.
        if GetRevisionListById.OutputItemCount = 0 then
        begin
          if KeepCheckout then
            raise Exception.CreateFmt('Module %d ''%s'' has no revisions yet: keep is not possible on the first check-in',
              [ModuleID, ModuleName]);
          // module without revisions (just added): first check-in, version 0.1
          Result := internCheckinFirstRevision(CheckinComment);
          Exit;
        end;
        for I := 0 to GetRevisionListById.OutputItemCount - 1 do
          with GetRevisionListById.OutputItems[I] do
          begin
            LatestRevision.ModuleID := ModuleID;
            if (ModuleName <> '') then
              LatestRevision.ModuleName := ModuleName;
            if (ModulePath <> '') then
              LatestRevision.ModulePath := ModulePath;
            LatestRevision.CheckedOut := CheckedOut;
            LatestRevision.Timestamp := Timestamp;
            LatestRevision.UserID := UserID;
            if (Version > LatestRevision.Version) or ((Version = LatestRevision.Version) and
              (Revision >= LatestRevision.Revision)) then
            begin
              LatestRevision.RevisionID := RevisionID;
              LatestRevision.Version := Version;
              LatestRevision.Revision := Revision;
            end;
            LatestRevision.Owner := Owner;
            LatestRevision.ProjectID := ProjectID;
            LatestRevision.Hidden := Hidden;
          end;
      finally
        GetRevisionListById.Free;
      end;
      {  //thu 30.10.2003 #1159
      // make sure the module is locked by the current user
      if not LatestRevision.CheckedOut then
        raise Exception.CreateFmt(SModuleNotCheckedOut, [ModuleID, ModuleName]);
      if (LatestRevision.UserID <> Connection.UserID) or (LatestRevision.Owner <> Connection.UserName) then
        raise Exception.CreateFmt(SModuleLocked, [ModuleID, ModuleName, LatestRevision.Owner]);
       }
      // JVCS 2026: Put only on a module checked out by the current user. With CasuallyCheckin the
      // server accepts a Put on a free module and locks it for this user (CHECKIN_MODULE, readonly = '1')
      if KeepCheckout then
      begin
        if not LatestRevision.CheckedOut then
          raise Exception.CreateFmt(SModuleNotCheckedOut, [ModuleID, ModuleName]);
        if LatestRevision.UserID <> Connection.UserID then
          raise Exception.CreateFmt(SModuleLocked, [ModuleID, ModuleName, string(LatestRevision.Owner)]);
      end;
      // check if any of the module files has been modified; nothing to do otherwise
      ModuleFilesDirty := False;
      GetRevisionStatus := TJVCSGetRevisionStatus.Create(nil);
      try
        GetRevisionStatus.RevisionID := LatestRevision.RevisionID;
        Connection.SendRequest(GetRevisionStatus);
        ShowLog(GetRevisionStatus);
        for I := 0 to GetRevisionStatus.OutputItemCount - 1 do
          with GetRevisionStatus.OutputItems[I] do
          begin
            ModuleFileName := ChangeFileExt(PathAddSeparator(ModulePath) + ModuleName, RevisionExtension);
            if IsFileDirty(ModuleFileName, RevisionOriginalTime) or
              IsFileDirtyCRC(ModuleFileName, RevisionOriginalCRC) then
            begin
              ModuleFilesDirty := True;
              Break;
            end;
          end;

        // actual implementation:
        // if file was not changed, it still keeps being locked
        // @@@ToDo: new parameter for checkin
        if not ModuleFilesDirty then
        begin
          raise Exception.CreateFmt(SModuleNotChanged, [ModuleID, ModuleName]);
        end;

        // get family ID
        GetFamilyExtensions := TJVCSGetFamilyExtensions.Create(nil);
        try
          GetFamilyExtensions.ParentExtension := ExtractFileExt(ModuleName);
          Connection.SendRequest(GetFamilyExtensions);
          ShowLog(GetFamilyExtensions);
          FamilyID := GetFamilyExtensions.FamilyID;
          FamilyExtensions := GetFamilyExtensions.FamilyExtensions;
        finally
          GetFamilyExtensions.Free;
        end;

        ZipFiles := TStringList.Create;
        try
          for I := 0 to GetRevisionStatus.OutputItemCount - 1 do
            with GetRevisionStatus.OutputItems[I] do
            begin
              ModuleFileName := ChangeFileExt ( PathAddSeparator(ModulePath) + ModuleName
                                              , RevisionExtension
                                              );
              if JVCSCompressFile(ModuleFileName, ZipFileName) then
              begin
                ZipFiles.Add(ZipFileName);
              end;
            end;
          CheckinModule := TJVCSCheckinModule.Create(nil);
          try
            CheckinModule.PutOnly := KeepCheckout;
            for I := 0 to GetRevisionStatus.OutputItemCount - 1 do
              with GetRevisionStatus.OutputItems[I] do
              begin
                ModuleFileName := ChangeFileExt ( PathAddSeparator(ModulePath) + ModuleName
                                                , RevisionExtension
                                                );
                //THu Save to VCS with GMT timestamp
                //CSchuette, 29.03.2005: fix problem with UTC timestamps
                ModuleOriginalTime := FileGetUTCDateTime(ModuleFileName);
                ModuleOriginalSize := GetSizeOfFile(ModuleFileName);
//THu                ModuleOriginalCRC  := GetFileCrc32(ModuleFileName);
                // no exception handling!
                // JVCS 2026: CRCInt direto (CRCString devolve 'OK' para arquivo
                // vazio e o StrToInt quebrava); mesmo valor Integer com sinal
                ModuleOriginalCRC  := CRCInt(ModuleFileName, CrcErr);
                ModuleCompressedSize := GetSizeOfFile(ZipFiles[I]);
                ModuleFileStream := TFileStream.Create(ZipFiles[I], fmOpenRead);
                try
                  CheckinModule.AddInputItem( ProjectID
                                            , Connection.UserID
                                            , ModuleID
                                            , 0
                                            , LatestRevision.RevisionID
                                            , LatestRevision.Version
                                            , LatestRevision.Revision + 1
                                            , ModuleOriginalTime
                                            , ModuleOriginalSize
                                            , ModuleOriginalCRC
                                            , ModuleCompressedSize
                                            , RevisionExtension
                                            , ModuleFileStream
                                            , CheckinComment
                                            , 0
                                            , ModuleFileName
                                            , FamilyID
                                            );
                finally
                  ModuleFileStream.Free;
                end;
              end;
            Connection.SendRequest(CheckinModule);
            ShowLog(CheckinModule);
            // JVCS 2026: the server answers CheckinAllowed = False with the reason; before, the
            // console only skipped the read-only flag and printed nothing
            if not CheckinModule.CheckinAllowed then
            begin
              RefuseReason := Trim(string(CheckinModule.ErrorMessage));
              if RefuseReason = '' then
                RefuseReason := 'no reason given by the server';
              raise Exception.CreateFmt('Check-in of module %d ''%s'' refused by server: %s',
                [ModuleID, ModuleName, RefuseReason]);
            end;
            if KeepCheckout then
              // Put keeps the lock and the files writable (standalone: no read-only flag with cbPut)
              Writeln(Format('Put: module %d ''%s'' checked in as %d.%d and still checked out',
                [ModuleID, ModuleName, LatestRevision.Version, LatestRevision.Revision + 1]))
            else
              // now set file readonly
              SetVCSReadOnlyFile(ModuleName, FamilyExtensions);
          finally
            CheckinModule.Free;
          end;
        finally
          for I := 0 to ZipFiles.Count - 1 do
            DeleteFile(PChar(ZipFiles[I]));
          ZipFiles.Free;
        end;
      finally
        GetRevisionStatus.Free;
      end;

      ListModule(ProjectID, ModuleID);

      Writeln;
      Result := True;
    finally
      ModuleID := -1;
      ModuleName := '';
    end;
  end;
end;


// Syntax: 'getmodule <module_name> | <module_id> [rev="ver.rev"] [dest="destinationpath"] [noprompt] [extexitcode]';
// Prereq: open project
// Check : exist module_name or module_id in project
// Params: max. 4 params
function CmdProcGetModule(const Line: string; var ExtExitCode: Integer): Boolean; //thu05.07.05
var
  bParamOk, bByRev, bDestPath, bCheckedOutByMe, bCreateDirOK, bDirNoPrompt,
  bFileNoPrompt, bOverwriteFileOK: Boolean;
  I, ii, Count, nWantVer, nWantRev: Integer;
  S, sDestPath, sTmp: string;
  GetRevisionListById: TJVCSGetRevisionListById;
  WantedRevision: TGetRevisionListByIdOutputItem;
  GetRevisionStatus: TJVCSGetRevisionStatus;
  GetCheckoutModule: TJVCSGetCheckoutModule;
begin
  Result := False;
  ModuleID := -1;
  ModuleName := '';
  // init
  bByRev := False;
  bDestPath := False;
  bDirNoPrompt := False;
  bFileNoPrompt := False;
  nWantVer := 0;
  nWantRev := 0;
  Count := LineParamCount(Line);
  // change max if params are added! (2026: 5 = module + rev= + dest= + noprompt,
  // as documented; it was 4 and refused the three options together)
  if (Count in [2..5]) then
  begin
    S := LineParamStr(Line, 2);
    ModuleID := StrToIntDef(S, -1);
    if ModuleID = -1 then
      ModuleName := S;
    try
      CheckOpenProject;
      CheckModuleOrLocalFile;

      bParamOk := True;
      for ii := 3 to Count do
      begin
        bParamOk := True;
        S := LineParamStr(Line, ii);
        // add new cases in this block for new params
        if AnsiCompareText(S, 'noprompt') = 0 then
          SyncNoPrompt := True
        else
        if Pos('rev=', S)>0 then
        begin
          bByRev := True;
          sTmp := strAfter('=',S);
          nWantVer := StrToInt(strBefore('.',sTmp));
          nWantRev := StrToInt(strAfter('.', sTmp));
        end
        else
        if Pos('dest=', S)>0 then
        begin
          bDestPath := True;
          sDestPath := strAfter('=',S);
        end
        else
          bParamOk := False;
        if not bParamOk then
          Break;
      end;

      if not bParamOk then
        Exit;

      // Get Revisionlist for Module
      // get information about wanted revision of the specified module
      FillChar(WantedRevision, SizeOf(TGetRevisionListByIdOutputItem), 0);
      GetRevisionListById := TJVCSGetRevisionListById.Create(nil);
      try
        GetRevisionListById.ProjectID := 0; // has to be zero, not projectId
        GetRevisionListById.ModuleID := ModuleID;
        Connection.SendRequest(GetRevisionListById);
        ShowLog(GetRevisionListById);
        if GetRevisionListById.OutputItemCount = 0 then
          raise Exception.CreateFmt(SModuleNoRevisions, [ModuleID, ModuleName]);
        for I := 0 to GetRevisionListById.OutputItemCount - 1 do
          with GetRevisionListById.OutputItems[I] do
          begin
            WantedRevision.ModuleID := ModuleID;
            if (ModuleName <> '') then
              WantedRevision.ModuleName := ModuleName;
            if (ModulePath <> '') then
              WantedRevision.ModulePath := ModulePath;
            WantedRevision.CheckedOut := CheckedOut;
            WantedRevision.Timestamp := Timestamp;
            WantedRevision.UserID := UserID;
            WantedRevision.Owner := Owner;
            WantedRevision.ProjectID := ProjectID;
            WantedRevision.Hidden := Hidden;
            // as next condition may break loop don't assign anything beneath!
            // Distinct between latest revision and wanted revision
            if bByRev then
            begin
              if (Version = nWantVer) and (Revision = nWantRev) then
              begin
                WantedRevision.RevisionID := RevisionID;
                WantedRevision.Version := Version;
                WantedRevision.Revision := Revision;
                // ATT: go out
                Break;
              end;
            end
            else
            if (Version > WantedRevision.Version) or ((Version = WantedRevision.Version) and
              (Revision >= WantedRevision.Revision)) then
            begin
              WantedRevision.RevisionID := RevisionID;
              WantedRevision.Version := Version;
              WantedRevision.Revision := Revision;
            end;
          end;
          if WantedRevision.RevisionID = 0 then
            raise Exception.CreateFmt(SRevisionNotFound, [nWantVer, nWantRev, ModuleName]);
      finally
        GetRevisionListById.Free;
      end;

      // Check if revision is checked out by logged on user
      // not used at the moment as existing file is overwritten only if not exist
      // but might be necessary for more restrictive get (same issue as for sync) 
      bCheckedOutByMe := False;
      GetRevisionStatus := TJVCSGetRevisionStatus.Create(nil);
      try
        GetRevisionStatus.RevisionID := WantedRevision.RevisionID;
        Connection.SendRequest(GetRevisionStatus);
        ShowLog(GetRevisionStatus);
        for I := 0 to GetRevisionStatus.OutputItemCount - 1 do
          with GetRevisionStatus.OutputItems[I] do
          begin
            bCheckedOutByMe := CheckedOut and (WantedRevision.Owner = Connection.UserName);
            if bCheckedOutByMe then
              Break;
          end;
          if bCheckedOutByMe then;
      finally
        GetRevisionStatus.Free;
      end;

      // If found we have WantedRevision filled, get revision blob
      GetCheckoutModule := TJVCSGetCheckoutModule.Create(nil);
      try
        GetCheckoutModule.ProjectID := ProjectID;
        GetCheckoutModule.UserID := Connection.UserID;
        GetCheckoutModule.ModuleID := WantedRevision.ModuleID;
        GetCheckoutModule.RevisionID := WantedRevision.RevisionID;
        GetCheckoutModule.CheckOut := False;  // Only get revision

        Connection.SendRequest(GetCheckoutModule);
        ShowLog(GetCheckoutModule);

        for I := 0 to GetCheckoutModule.OutputItemCount - 1 do
          with GetCheckoutModule.OutputItems[I] do
          begin
            // Get to different path?
            if bDestPath then
            begin
              // 2026: dest= must keep the file inside the destination folder; a module
              // name from the server with a drive, a leading backslash or a '..' segment is refused
              // (a name such as a..b.pas is valid)
              if (ExtractFileDrive(WantedRevision.ModuleName) <> '') or
                (Copy(WantedRevision.ModuleName, 1, 1) = '\') or
                (Pos('\..\', '\' + StringReplace(string(WantedRevision.ModuleName), '/', '\', [rfReplaceAll]) + '\') > 0) then
                raise Exception.CreateFmt('Module name ''%s'' leaves the dest folder: nothing written',
                  [WantedRevision.ModuleName]);
              S := ChangeFileExt(PathAddSeparator(sDestPath) + WantedRevision.ModuleName, ModuleExtension);
            end
            else
              S := ChangeFileExt(PathAddSeparator(WantedRevision.ModulePath) + WantedRevision.ModuleName, ModuleExtension);
              
            Trim(S);
            
            if not DirectoryExists(ExtractFilePath(S)) then
            begin
              if SyncNoPrompt or bDirNoPrompt then
                bCreateDirOK := True
              else
              begin
                bCreateDirOK := False;
                case Prompt(Format(SCreateDir, [PathRemoveSeparator(ExtractFilePath(S))]),
                  OptionsYesNoAllBreak) of
                  0:
                    bCreateDirOK := True;
                  2:
                    begin
                      bCreateDirOK := True;
                      bDirNoPrompt := True;
                    end;
                  3:
                    Break;
                end;
              end;
              if bCreateDirOK then
                ForceDirectories(ExtractFilePath(S));
            end;

            if FileExists(S) then
            begin
              if SyncNoPrompt or bFileNoPrompt then
                bOverwriteFileOK := True
              else
              begin
                bOverwriteFileOK := False;
                case Prompt(Format(SOverwriteFile, [S]), OptionsYesNoAllBreak) of
                  0:
                    bOverwriteFileOK := True;
                  2:
                    begin
                      bOverwriteFileOK := True;
                      bFileNoPrompt := True;
                    end;
                  3:
                    Break;
                end;
              end
            end
            else
              bOverwriteFileOK := True;

            if bOverwriteFileOK then
            begin
              GetCheckoutModule.ExtractBlobToFile(S, ModuleBinary);
              FileSetReadOnlyAttribute(S, False);
              FileSetUTCDateTime(S, ModuleOriginalTime);
            end;
          end;
      finally
        GetCheckoutModule.Free;
      end;

      Result := True;
    finally
      ModuleID := -1;
      ModuleName := '';
    end;
  end;
end;


function CmdProcCheckoutModule(const Line: string; var ExtExitCode: Integer): Boolean;
var
  Count, I, J: Integer;
  S: string;
  GetLatestRevisions: TJVCSGetLatestRevisions;
  LatestRevision: TGetLatestRevisionsOutputItem;
  ModuleFilesAreDirty: Boolean;
  GetCheckoutModule: TJVCSGetCheckoutModule;
  DirNoPrompt, CreateDirOK, FileNoPrompt, OverwriteFileOK: Boolean;
  CheckoutOnlyModule: TJVCSCheckoutOnlyModule;
begin
  Result := False;
  ModuleID := -1;
  ModuleName := '';
  DirNoPrompt := False;
  FileNoPrompt := False;

  Count := LineParamCount(Line);
  if Count = 2 then
  begin
    S := LineParamStr(Line, 2);
    ModuleID := StrToIntDef(S, -1);
    if ModuleID = -1 then
      ModuleName := S;
    try
      CheckOpenProject;
      CheckModuleOrLocalFile;
      GetLatestRevisions := TJVCSGetLatestRevisions.Create(nil);
      try
        GetLatestRevisions.ProjectID := ProjectID;
        GetLatestRevisions.ExcludeHiddenModules := False;
        GetLatestRevisions.LabelID := 0;
        Connection.SendRequest(GetLatestRevisions);
        ShowLog(GetLatestRevisions);

        I := 0;
        while I < GetLatestRevisions.OutputItemCount do
        begin
          ModuleFilesAreDirty := False;
          if (GetLatestRevisions.OutputItems[I].ModuleID = ModuleID) and
            (GetLatestRevisions.OutputItems[I].ModulePath <> '') and
            (GetLatestRevisions.OutputItems[I].ModuleName <> '') then
          begin
            LatestRevision := GetLatestRevisions.OutputItems[I];
            // check if one or more module files are dirty
            for J := 0 to GetLatestRevisions.OutputItemCount - 1 do
              with GetLatestRevisions.OutputItems[J] do
                if (ModuleID = LatestRevision.ModuleID) then
                begin
                  if (ModulePath = '') and (ModuleName = '') then
                    S := ChangeFileExt(PathAddSeparator(LatestRevision.ModulePath) + LatestRevision.ModuleName,
                      RevisionExtension)
                  else
                    S := ChangeFileExt(PathAddSeparator(ModulePath) + ModuleName, RevisionExtension);

                  S := Trim(S);
                  if FileExists(S) then
                    ModuleFilesAreDirty := IsFileDirty(S, RevisionTimestamp) or IsFileDirtyCRC(S, RevisionCRC32)
                  else
                    ModuleFilesAreDirty := True;

                  if ModuleFilesAreDirty then
                    Break;
                end;
            if ModuleFilesAreDirty then // module files dirty: GET_CHECKOUT_MODULE
            begin
              GetCheckoutModule := TJVCSGetCheckoutModule.Create(nil);
              try
                GetCheckoutModule.ProjectID := ProjectID;
                GetCheckoutModule.UserID := Connection.UserID;
                GetCheckoutModule.ModuleID := LatestRevision.ModuleID;
                GetCheckoutModule.RevisionID := LatestRevision.RevisionID;
                GetCheckoutModule.CheckOut := True;
                with LatestRevision do
                  S := ChangeFileExt(PathAddSeparator(ModulePath) + ModuleName, RevisionExtension);
                GetCheckoutModule.ModuleName := S;
                Connection.SendRequest(GetCheckoutModule);
                ShowLog(GetCheckoutModule);
                if not GetCheckoutModule.CheckoutAllowed then
                  if GetCheckoutModule.Owner = '' then
                    raise Exception.CreateFmt(SModuleCheckoutNotAllowed, [ModuleID, ModuleName])
                  else
                    raise Exception.CreateFmt(SModuleCheckoutNotAllowed2, [ModuleID, ModuleName, GetCheckoutModule.Owner]);

                for J := 0 to GetCheckoutModule.OutputItemCount - 1 do
                  with GetCheckoutModule.OutputItems[J] do
                  begin
                    with LatestRevision do
                      S := Trim(ChangeFileExt(PathAddSeparator(ModulePath) + ModuleName, ModuleExtension));

                    if not DirectoryExists(ExtractFilePath(S)) then
                    begin
                      if SyncNoPrompt or DirNoPrompt then
                        CreateDirOK := True
                      else
                      begin
                        CreateDirOK := False;
                        case Prompt(Format(SCreateDir, [PathRemoveSeparator(ExtractFilePath(S))]),
                          OptionsYesNoAllBreak) of
                          0:
                            CreateDirOK := True;
                          2:
                            begin
                              CreateDirOK := True;
                              DirNoPrompt := True;
                            end;
                          3:
                            Break;
                        end;
                      end;
                      if CreateDirOK then
                        ForceDirectories(ExtractFilePath(S));
                    end;

                    if FileExists(S) then
                    begin
                      if IsFileDirty(S, ModuleOriginalTime) or IsFileDirtyCRC(S, ModuleOriginalCRC) then
                      begin
                        if SyncNoPrompt or FileNoPrompt then
                          OverwriteFileOK := True
                        else
                        begin
                          OverwriteFileOK := False;
                          case Prompt(Format(SOverwriteFile, [S]), OptionsYesNoAllBreak) of
                            0:
                              OverwriteFileOK := True;
                            2:
                              begin
                                OverwriteFileOK := True;
                                FileNoPrompt := True;
                              end;
                            3:
                              Break;
                          end;
                        end;
                      end
                      else
                        OverwriteFileOK := False;
                    end
                    else
                      OverwriteFileOK := True;

                    if OverwriteFileOK then
                    begin
                      GetCheckoutModule.ExtractBlobToFile(S, ModuleBinary);
                      FileSetReadOnlyAttribute(S, False);
                      //THu be aware if server/client live in different timezones !
                      //CSchuette, 29.03.2005: fix problem with UTC timestamps
                      FileSetUTCDateTime(S, ModuleOriginalTime);
                    end;
                  end;
              finally
                GetCheckoutModule.Free;
              end;
              Break;
            end
            else // module files not dirty: CHECKOUT_ONLY_MODULE
            begin
              CheckoutOnlyModule := TJVCSCheckoutOnlyModule.Create(nil);
              try
                CheckoutOnlyModule.ProjectID := ProjectID;
                CheckoutOnlyModule.UserID := Connection.UserID;
                CheckoutOnlyModule.ModuleID := ModuleID;
                CheckoutOnlyModule.RevisionID := LatestRevision.RevisionID;
                with LatestRevision do
                  S := ChangeFileExt(PathAddSeparator(ModulePath) + ModuleName, RevisionExtension);
                CheckoutOnlyModule.ModuleName := S;
                Connection.SendRequest(CheckoutOnlyModule);
                ShowLog(CheckoutOnlyModule);
                if not CheckoutOnlyModule.CheckoutAllowed then
                  if CheckoutOnlyModule.Owner = '' then
                    raise Exception.CreateFmt(SModuleCheckoutNotAllowed, [ModuleID, ModuleName])
                  else
                    raise Exception.CreateFmt(SModuleCheckoutNotAllowed2, [ModuleID, ModuleName,
                      CheckoutOnlyModule.Owner]);

                // files should be writable after checkout
                for J := 0 to CheckoutOnlyModule.OutputItemCount - 1 do
                  with CheckoutOnlyModule.OutputItems[J] do
                  begin
                    S := Trim(ChangeFileExt(CheckoutOnlyModule.ModuleName, ModuleExtension));
                    FileSetReadOnlyAttribute(S, False);
                  end;
              finally
                CheckoutOnlyModule.Free;
              end;
            end;
          end;
          Inc(I);
        end;

        ListModule(ProjectID, ModuleID);

        Writeln;
        Result := True;
      finally
        GetLatestRevisions.Free;
      end;
    finally
      ModuleID := -1;
      ModuleName := '';
    end;
  end;
end;

function CmdProcAddProject(const Line: string; var ExtExitCode: Integer): Boolean;
var
  Count: Integer;
  AddNewProject: TJVCSAddNewProject;
  ProjName, Descr: string;
begin
  Result := False;
  Count := LineParamCount(Line);
  if not (Count in [2, 3]) then
    Exit;
  ProjName := LineParamStr(Line, 2);
  Descr := '';
  if Count = 3 then
    Descr := LineParamStr(Line, 3);

  AddNewProject := TJVCSAddNewProject.Create(nil);
  try
    AddNewProject.UserID := Connection.UserID;
    AddNewProject.ProjectName := ProjName;
    AddNewProject.Description := Descr;
    Connection.SendRequest(AddNewProject);
    ShowLog(AddNewProject);
    ProjectID := AddNewProject.ProjectID;
    ProjectName := ProjName;
    if AddNewProject.IsNewProject then
    begin
      Writeln('Project created: ', ProjName, ' (ID ', ProjectID, ')');
      Result := True;
    end
    else
    begin
      // JVCS 2026: not a syntax error (before: the syntax help followed this line)
      Writeln('Project already exists: ', ProjName, ' (ID ', ProjectID, ')');
      Result := True;
    end;
  finally
    AddNewProject.Free;
  end;
end;

// Stores the local folder of a module on the server (MOVE_MODULE). Without it the
// module has no path and listproject/checkout do not see it.
function internSetModulePath(AModuleID: Integer; const AModuleName, APath: string): Boolean;
var
  MoveModule: TJVCSMoveModule;
begin
  MoveModule := TJVCSMoveModule.Create(nil);
  try
    MoveModule.ProjectID := ProjectID;
    MoveModule.UserID := Connection.UserID;
    MoveModule.ModuleID := AModuleID;
    MoveModule.NewModulePath := ExcludeTrailingPathDelimiter(APath);
    MoveModule.ModuleName := AModuleName;
    Connection.SendRequest(MoveModule);
    ShowLog(MoveModule);
    Result := MoveModule.ModuleMoved;
  finally
    MoveModule.Free;
  end;
end;

// Long form of an existing path (8.3 components expanded); the path itself if that fails.
function internLongPath(const APath: string): string;
var
  Buf: array[0..MAX_PATH] of Char;
  L: DWORD;
begin
  Result := APath;
  L := GetLongPathName(PChar(APath), Buf, Length(Buf));
  if (L > 0) and (L < DWORD(Length(Buf))) then
    SetString(Result, Buf, L);
end;

// JVCS 2026: the module of a local file. A module stores its folder as it was given, and the
// same folder can be written in its long form, in its 8.3 short form or mixed (only
// C:\Users\EDMARF~1 short, as in %TEMP%). First GET_MODULE_ID as given and in the long form;
// then SEARCH_MODULES by the file name, comparing the long forms of the folders that exist.
// AFoundName = the stored full name (lower case), to be sent when the module is linked.
function internFindModuleID(const AFullName: string; var AFoundName: string): Integer;
var
  Names: TStringList;
  S, Wanted: string;
  I: Integer;
  GetModuleId: TJVCSGetModuleId;
  SearchModules: TJVCSSearchModules;
  Item: TSearchModulesOutputItem;
begin
  Result := 0;
  AFoundName := '';
  Wanted := AnsiLowerCase(internLongPath(AFullName));
  Names := TStringList.Create;
  try
    Names.Add(AnsiLowerCase(AFullName));
    if Names.IndexOf(Wanted) < 0 then
      Names.Add(Wanted);
    for I := 0 to Names.Count - 1 do
    begin
      GetModuleId := TJVCSGetModuleId.Create(nil);
      try
        GetModuleId.ModuleName := Names[I];
        Connection.SendRequest(GetModuleId);
        ShowLog(GetModuleId);
        Result := GetModuleId.ModuleID;
      finally
        GetModuleId.Free;
      end;
      if Result > 0 then
      begin
        AFoundName := Names[I];
        Exit;
      end;
    end;
  finally
    Names.Free;
  end;

  SearchModules := TJVCSSearchModules.Create(nil);
  try
    SearchModules.MaskString := JVCSString255(AnsiString(ExtractFileName(AFullName)));
    Connection.SendRequest(SearchModules);
    ShowLog(SearchModules);
    for I := 0 to SearchModules.OutputItemCount - 1 do
    begin
      Item := SearchModules.OutputItems[I];
      if (string(Item.Path) = '') or not SameText(string(Item.ModuleName), ExtractFileName(AFullName)) then
        Continue;
      S := IncludeTrailingPathDelimiter(string(Item.Path)) + string(Item.ModuleName);
      if AnsiLowerCase(internLongPath(S)) = Wanted then
      begin
        Result := Item.ModuleID;
        AFoundName := AnsiLowerCase(S);
        Exit;
      end;
    end;
  finally
    SearchModules.Free;
  end;
end;

// addmodule sends only the file name (a full path would become the module name on
// the server), always with a description (an empty one leaves a placeholder revision
// that later refuses the first check-in) and then stores the local folder.
// The file is looked up relative to the current directory.
function CmdProcAddModule(const Line: string; var ExtExitCode: Integer): Boolean;
var
  Count: Integer;
  AddNewModule: TJVCSAddNewModule;
  ExistingID: Integer;
  FullName, ShortName, Descr, FoundName: string;
begin
  Result := False;
  Count := LineParamCount(Line);
  if not (Count in [2, 3]) then
    Exit;
  FullName := ExpandFileName(LineParamStr(Line, 2));
  ShortName := ExtractFileName(FullName);
  if not FileExists(FullName) then
    raise Exception.CreateFmt('Local file not found: %s', [FullName]);
  Descr := '';
  if Count = 3 then
    Descr := Trim(LineParamStr(Line, 3));
  if Descr = '' then
    Descr := ShortName;

  CheckOpenProject;
  // JVCS 2026: a file that already is a module (same folder and name) is not added again.
  // ADD_NEW_MODULE gets only the short name (empty path), which never matches the stored
  // name + path: the server would create a second, empty module. Already in the open
  // project: nothing to do; in another project: linked (as linkmodule), with its revisions.
  ExistingID := internFindModuleID(FullName, FoundName);
  if ExistingID > 0 then
  begin
    if internProjectHasModule(ProjectID, ExistingID) then
      Writeln('Module already in project: ', FullName, ' (ID ', ExistingID, ')')
    else
    begin
      AddNewModule := TJVCSAddNewModule.Create(nil);
      try
        AddNewModule.ProjectID := ProjectID;
        AddNewModule.UserID := Connection.UserID;
        AddNewModule.ModuleFullName := FoundName; // the stored form, or the server creates a new module
        AddNewModule.Flags := 4096; // ignored for an existing module
        AddNewModule.Description := Descr;
        Connection.SendRequest(AddNewModule);
        ShowLog(AddNewModule);
        if AddNewModule.IsNewModule or (AddNewModule.ModuleID <> ExistingID) then
          raise Exception.CreateFmt('ADD_NEW_MODULE returned module %d (new: %s) instead of linking %d; ' +
            'that module may now be linked to the project: check with listmodules',
            [AddNewModule.ModuleID, BoolToStr(AddNewModule.IsNewModule, True), ExistingID]);
      finally
        AddNewModule.Free;
      end;
      Writeln('Module linked: ', FullName, ' (ID ', ExistingID, ')');
    end;
    Result := True;
    Exit;
  end;

  AddNewModule := TJVCSAddNewModule.Create(nil);
  try
    AddNewModule.ProjectID := ProjectID;
    AddNewModule.UserID := Connection.UserID;
    AddNewModule.ModuleFullName := ShortName;
    AddNewModule.Flags := 4096; // moVer200, as the standalone sends for new modules
    AddNewModule.Description := Descr;
    Connection.SendRequest(AddNewModule);
    ShowLog(AddNewModule);
    ModuleID := AddNewModule.ModuleID;
    if AddNewModule.IsNewModule then
      Writeln('Module added: ', ShortName, ' (ID ', ModuleID, ')')
    else
      Writeln('Module already exists: ', ShortName, ' (ID ', ModuleID, ')');
    if ModuleID <= 0 then
      raise Exception.CreateFmt('Module %s not added (the server answered module ID %d)', [ShortName, ModuleID]);
    // JVCS 2026: a path the server did not store is an error (before: syntax help, exit code 0)
    if not internSetModulePath(ModuleID, ShortName, ExtractFileDir(FullName)) then
      raise Exception.CreateFmt('Module %s (ID %d) added, but its path was not set: run setmodulepath %d "%s"',
        [ShortName, ModuleID, ModuleID, ExtractFileDir(FullName)]);
    Writeln('Module path: ', ExtractFileDir(FullName));
    Result := True;
  finally
    AddNewModule.Free;
    ModuleID := -1;
    ModuleName := '';
  end;
end;

function CmdProcSetModulePath(const Line: string; var ExtExitCode: Integer): Boolean;
var
  Count: Integer;
  S, NewPath: string;
begin
  Result := False;
  Count := LineParamCount(Line);
  if Count <> 3 then
    Exit;
  ModuleID := -1;
  ModuleName := '';
  S := LineParamStr(Line, 2);
  ModuleID := StrToIntDef(S, -1);
  if ModuleID = -1 then
    ModuleName := S;
  NewPath := ExcludeTrailingPathDelimiter(LineParamStr(Line, 3));

  try
    CheckOpenProject;
    CheckModuleOrLocalFile;
    // JVCS 2026: a path the server did not store is an error (before: syntax help, exit code 0)
    if not internSetModulePath(ModuleID, ModuleName, NewPath) then
      raise Exception.CreateFmt('Module path not set: %s (ID %d) -> %s', [ModuleName, ModuleID, NewPath]);
    Writeln('Module path set: ', ModuleName, ' -> ', NewPath);
    Result := True;
  finally
    ModuleID := -1;
    ModuleName := '';
  end;
end;

// Comment on one line for parsers: '\' -> '\\', CR/LF -> '\n', TAB -> ' '.
function EscapeHistoryComment(const S: string): string;
var
  I: Integer;
begin
  Result := '';
  I := 1;
  while I <= Length(S) do
  begin
    case S[I] of
      '\': Result := Result + '\\';
      #13:
        begin
          Result := Result + '\n';
          if (I < Length(S)) and (S[I + 1] = #10) then
            Inc(I);
        end;
      #10: Result := Result + '\n';
      #9: Result := Result + ' ';
    else
      if S[I] >= ' ' then
        Result := Result + S[I];
    end;
    Inc(I);
  end;
end;

function CmdProcHistory(const Line: string; var ExtExitCode: Integer): Boolean;
var
  Count, I: Integer;
  S, Exts: string;
  TotalSize: Int64;
  GetModuleHistory: TJVCSGetModuleHistory;
  Item: TGetModuleHistoryOutputItem;
  procedure FlushRow(const Row: TGetModuleHistoryOutputItem);
  var
    sOut: string;
  begin
    sOut := '';
    if Row.CheckedOut then
      sOut := '*';
    Write(StrAlign(Format('%d.%d', [Row.Version, Row.Revision]), 7), ' ');
    Write(StrAlign(IntToStr(Row.RevisionID), 8), ' ');
    Write(StrAlign(FormatDateTime('yyyy-mm-dd hh:nn:ss', GMTDT2LocalDT(Row.Timestamp)), 19), ' ');
    Write(StrAlign(Row.UserName, 20), ' ');
    Write(StrAlign(IntToStr(TotalSize), 10), ' ');
    Write(StrAlign(sOut, 3), ' ');
    Write(StrAlign(Exts, 30), ' ');
    Writeln(EscapeHistoryComment(Row.CheckinComment));
  end;
begin
  Result := False;
  Count := LineParamCount(Line);
  if Count <> 2 then
    Exit;
  ModuleID := -1;
  ModuleName := '';
  S := LineParamStr(Line, 2);
  ModuleID := StrToIntDef(S, -1);
  if ModuleID = -1 then
    ModuleName := S;
  try
    CheckModuleOrLocalFile;
    GetModuleHistory := TJVCSGetModuleHistory.Create(nil);
    try
      GetModuleHistory.ModuleID := ModuleID;
      Connection.SendRequest(GetModuleHistory);
      ShowLog(GetModuleHistory);
      Writeln('Module: ', ModuleName, ' (ID ', ModuleID, ')');
      Writeln;
      Write(StrAlign('Version', 7), ' ');
      Write(StrAlign('RevID', 8), ' ');
      Write(StrAlign('Checked in', 19), ' ');
      Write(StrAlign('User', 20), ' ');
      Write(StrAlign('Size', 10), ' ');
      Write(StrAlign('Out', 3), ' ');
      Write(StrAlign('Files', 30), ' ');
      Writeln('Comment');
      Write(StringOfChar('=', 7), ' ');
      Write(StringOfChar('=', 8), ' ');
      Write(StringOfChar('=', 19), ' ');
      Write(StringOfChar('=', 20), ' ');
      Write(StringOfChar('=', 10), ' ');
      Write(StringOfChar('=', 3), ' ');
      Write(StringOfChar('=', 30), ' ');
      Writeln(StringOfChar('=', 7));
      // one output item per family member: one row per revision. The server sends
      // user and comments only on the first member of each revision (as History.pas reads).
      Exts := '';
      TotalSize := 0;
      for I := 0 to GetModuleHistory.OutputItemCount - 1 do
      begin
        if (I = 0) or (GetModuleHistory.OutputItems[I].RevisionID <> Item.RevisionID) then
        begin
          if I > 0 then
            FlushRow(Item);
          Item := GetModuleHistory.OutputItems[I];
          Exts := '';
          TotalSize := 0;
        end;
        if Exts <> '' then
          Exts := Exts + ',';
        Exts := Exts + GetModuleHistory.OutputItems[I].Extension;
        Inc(TotalSize, GetModuleHistory.OutputItems[I].Size);
        if GetModuleHistory.OutputItems[I].CheckedOut then
          Item.CheckedOut := True;
      end;
      if GetModuleHistory.OutputItemCount > 0 then
        FlushRow(Item);
      Writeln;
      Writeln(GetModuleHistory.OutputItemCount, ' item(s)');
      Result := True;
    finally
      GetModuleHistory.Free;
    end;
  finally
    ModuleID := -1;
    ModuleName := '';
  end;
end;

// ---------------------------------------------------------------- module administration
// listmodules, listdeserted, sharedby, removemodule, renamemodule, hidemodule, getcomment,
// setcomment. No Prompt here (Prompt fails with redirected stdin): callers confirm before.

// Inverse of EscapeHistoryComment: '\n' -> CRLF, '\\' -> '\'.
function UnescapeHistoryComment(const S: string): string;
var
  I: Integer;
begin
  Result := '';
  I := 1;
  while I <= Length(S) do
  begin
    if (S[I] = '\') and (I < Length(S)) then
      case S[I + 1] of
        'n':
          begin
            Result := Result + #13#10;
            Inc(I, 2);
            Continue;
          end;
        '\':
          begin
            Result := Result + '\';
            Inc(I, 2);
            Continue;
          end;
      end;
    Result := Result + S[I];
    Inc(I);
  end;
end;

function ModuleFlags(const APath, AName: string; AHidden, ABlank: Boolean): string;
begin
  Result := '';
  if AHidden then
    Result := Result + 'H';
  if ABlank then
    Result := Result + 'B';
  if Trim(APath) = '' then
    Result := Result + 'N';
  if (Pos('\', AName) > 0) or (Pos('/', AName) > 0) or (Pos(':', AName) > 0) then
    Result := Result + 'P';
end;

// One row: ID(8) Flags(6) path|name - path and name complete (parsers split at the first '|').
procedure WriteModuleRow(AID: Integer; const AFlags, APath, AName: string);
begin
  Write(StrAlign(IntToStr(AID), 8), ' ');
  Write(StrAlign(AFlags, 6), ' ');
  Writeln(APath, '|', AName);
end;

procedure WriteModuleHeader;
begin
  Write(StrAlign('ID', 8), ' ');
  Write(StrAlign('Flags', 6), ' ');
  Writeln('Path|Name');
  Write(StringOfChar('=', 8), ' ');
  Write(StringOfChar('=', 6), ' ');
  Writeln(StringOfChar('=', 20));
end;

function internProjectHasModule(AProjectID, AModuleID: Integer): Boolean;
var
  GetProjectModuleList: TJVCSGetProjectModuleList;
  I: Integer;
begin
  Result := False;
  GetProjectModuleList := TJVCSGetProjectModuleList.Create(nil);
  try
    GetProjectModuleList.ProjectID := AProjectID;
    GetProjectModuleList.ExcludeHiddenModules := False;
    Connection.SendRequest(GetProjectModuleList);
    ShowLog(GetProjectModuleList);
    for I := 0 to GetProjectModuleList.OutputItemCount - 1 do
      if GetProjectModuleList.OutputItems[I].ModuleID = AModuleID then
      begin
        Result := True;
        Break;
      end;
  finally
    GetProjectModuleList.Free;
  end;
end;

function internIsDesertedModule(AModuleID: Integer): Boolean;
var
  GetDesertedModules: TJVCSGetDesertedModules;
  I: Integer;
begin
  Result := False;
  GetDesertedModules := TJVCSGetDesertedModules.Create(nil);
  try
    Connection.SendRequest(GetDesertedModules);
    ShowLog(GetDesertedModules);
    for I := 0 to GetDesertedModules.OutputItemCount - 1 do
      if GetDesertedModules.OutputItems[I].ModuleID = AModuleID then
      begin
        Result := True;
        Break;
      end;
  finally
    GetDesertedModules.Free;
  end;
end;

// Owner of the lock, '' if not checked out.
// GET_LOCKED_MODULES joins pjmodule and revision (SrvOBJProjects.pas:853-866): a deserted
// module that is checked out is not listed there. GET_MODULE_HISTORY returns modules.readonly
// in every row (CheckedOut) without pjmodule, so it is checked as well ('?' = owner unknown).
function internModuleLockOwner(AModuleID: Integer): string;
var
  GetLockedModules: TJVCSGetLockedModules;
  GetModuleHistory: TJVCSGetModuleHistory;
  I: Integer;
begin
  Result := '';
  GetLockedModules := TJVCSGetLockedModules.Create(nil);
  try
    GetLockedModules.ProjectID := 0;
    GetLockedModules.UserID := 0;
    Connection.SendRequest(GetLockedModules);
    ShowLog(GetLockedModules);
    for I := 0 to GetLockedModules.OutputItemCount - 1 do
      if GetLockedModules.OutputItems[I].ModuleID = AModuleID then
      begin
        Result := string(GetLockedModules.OutputItems[I].Owner);
        if Result = '' then
          Result := '?';
        Break;
      end;
  finally
    GetLockedModules.Free;
  end;
  if Result <> '' then
    Exit;
  GetModuleHistory := TJVCSGetModuleHistory.Create(nil);
  try
    GetModuleHistory.ModuleID := AModuleID;
    Connection.SendRequest(GetModuleHistory);
    ShowLog(GetModuleHistory);
    for I := 0 to GetModuleHistory.OutputItemCount - 1 do
      if GetModuleHistory.OutputItems[I].CheckedOut then
      begin
        Result := '?';
        Break;
      end;
  finally
    GetModuleHistory.Free;
  end;
end;

// Other (not deleted) projects containing the module, as 'id name, id name'.
function internSharedBy(AModuleID, AExceptProjectID: Integer): string;
var
  GetSharedBy: TJVCSGetSharedBy;
  I: Integer;
begin
  Result := '';
  GetSharedBy := TJVCSGetSharedBy.Create(nil);
  try
    GetSharedBy.ModuleID := AModuleID;
    Connection.SendRequest(GetSharedBy);
    ShowLog(GetSharedBy);
    for I := 0 to GetSharedBy.OutputItemCount - 1 do
      if GetSharedBy.OutputItems[I].ProjectID <> AExceptProjectID then
      begin
        if Result <> '' then
          Result := Result + ', ';
        Result := Result + IntToStr(GetSharedBy.OutputItems[I].ProjectID) + ' ' +
          string(GetSharedBy.OutputItems[I].ProjectName);
      end;
  finally
    GetSharedBy.Free;
  end;
end;

// Number of revisions with files (GET_MODULE_HISTORY has one item per family member and
// joins blobs: revisions without files are not listed).
function internRevisionCount(AModuleID: Integer): Integer;
var
  GetModuleHistory: TJVCSGetModuleHistory;
  I, LastID: Integer;
begin
  Result := 0;
  LastID := -1;
  GetModuleHistory := TJVCSGetModuleHistory.Create(nil);
  try
    GetModuleHistory.ModuleID := AModuleID;
    Connection.SendRequest(GetModuleHistory);
    ShowLog(GetModuleHistory);
    for I := 0 to GetModuleHistory.OutputItemCount - 1 do
      if GetModuleHistory.OutputItems[I].RevisionID <> LastID then
      begin
        LastID := GetModuleHistory.OutputItems[I].RevisionID;
        Inc(Result);
      end;
  finally
    GetModuleHistory.Free;
  end;
end;

function internModuleHasRevision(AModuleID, ARevisionID: Integer): Boolean;
var
  GetModuleHistory: TJVCSGetModuleHistory;
  I: Integer;
begin
  Result := False;
  GetModuleHistory := TJVCSGetModuleHistory.Create(nil);
  try
    GetModuleHistory.ModuleID := AModuleID;
    Connection.SendRequest(GetModuleHistory);
    ShowLog(GetModuleHistory);
    for I := 0 to GetModuleHistory.OutputItemCount - 1 do
      if GetModuleHistory.OutputItems[I].RevisionID = ARevisionID then
      begin
        Result := True;
        Break;
      end;
  finally
    GetModuleHistory.Free;
  end;
end;

function CmdProcListModules(const Line: string; var ExtExitCode: Integer): Boolean;
var
  Count, I, J: Integer;
  S, sPath, sName: string;
  bHidden, bBlank: Boolean;
  AllModules, VisibleModules: TJVCSGetProjectModuleList;
  BlankModules: TJVCSGetBlankModuleList;
begin
  Result := False;
  Count := LineParamCount(Line);
  if not (Count in [1, 2]) then
    Exit;
  if Count = 2 then
  begin
    S := LineParamStr(Line, 2);
    ProjectName := '';
    ProjectID := StrToIntDef(S, -1);
    if ProjectID = -1 then
      ProjectName := S;
  end;
  CheckOpenProject;
  AllModules := TJVCSGetProjectModuleList.Create(nil);
  VisibleModules := TJVCSGetProjectModuleList.Create(nil);
  BlankModules := TJVCSGetBlankModuleList.Create(nil);
  try
    AllModules.ProjectID := ProjectID;
    AllModules.ExcludeHiddenModules := False;
    Connection.SendRequest(AllModules);
    ShowLog(AllModules);
    VisibleModules.ProjectID := ProjectID;
    VisibleModules.ExcludeHiddenModules := True;
    Connection.SendRequest(VisibleModules);
    ShowLog(VisibleModules);
    BlankModules.ProjectID := ProjectID;
    BlankModules.ExcludeHiddenModules := False;
    Connection.SendRequest(BlankModules);
    ShowLog(BlankModules);
    Writeln('Project: ', ProjectName, ' (ID ', ProjectID, ')');
    Writeln;
    WriteModuleHeader;
    for I := 0 to AllModules.OutputItemCount - 1 do
    begin
      bHidden := True;
      for J := 0 to VisibleModules.OutputItemCount - 1 do
        if VisibleModules.OutputItems[J].ModuleID = AllModules.OutputItems[I].ModuleID then
        begin
          bHidden := False;
          Break;
        end;
      bBlank := False;
      for J := 0 to BlankModules.OutputItemCount - 1 do
        if BlankModules.OutputItems[J].ModuleID = AllModules.OutputItems[I].ModuleID then
        begin
          bBlank := True;
          Break;
        end;
      sPath := string(AllModules.OutputItems[I].ModulePath);
      sName := string(AllModules.OutputItems[I].ModuleName);
      WriteModuleRow(AllModules.OutputItems[I].ModuleID, ModuleFlags(sPath, sName, bHidden, bBlank), sPath, sName);
    end;
    Writeln;
    Writeln(AllModules.OutputItemCount, ' module(s)');
    Result := True;
  finally
    BlankModules.Free;
    VisibleModules.Free;
    AllModules.Free;
  end;
end;

function CmdProcListDeserted(const Line: string; var ExtExitCode: Integer): Boolean;
var
  I: Integer;
  sPath, sName: string;
  GetDesertedModules: TJVCSGetDesertedModules;
begin
  Result := False;
  if LineParamCount(Line) <> 1 then
    Exit;
  GetDesertedModules := TJVCSGetDesertedModules.Create(nil);
  try
    Connection.SendRequest(GetDesertedModules);
    ShowLog(GetDesertedModules);
    Writeln;
    WriteModuleHeader;
    for I := 0 to GetDesertedModules.OutputItemCount - 1 do
    begin
      sPath := string(GetDesertedModules.OutputItems[I].ModulePath);
      sName := string(GetDesertedModules.OutputItems[I].ModuleName);
      WriteModuleRow(GetDesertedModules.OutputItems[I].ModuleID, 'D' + ModuleFlags(sPath, sName, False, False), sPath, sName);
    end;
    Writeln;
    Writeln(GetDesertedModules.OutputItemCount, ' module(s)');
    Result := True;
  finally
    GetDesertedModules.Free;
  end;
end;

// sharedby: the labels/shared command (CmdProcSharedBy, further below) also serves the module
// administration (same request and columns; names escaped on one line).

// REMOVE_MODULE does not check locks and, for a shared module, removes the link of this
// project and answers False (SrvOBJModules.pas:659-806): the checks are done here first.
function CmdProcRemoveModule(const Line: string; var ExtExitCode: Integer): Boolean;
var
  Count, I, RevCount: Integer;
  S, Owner, Shared: string;
  bArchive: Boolean;
  RemoveModule: TJVCSRemoveModule;
begin
  Result := False;
  Count := LineParamCount(Line);
  if not (Count in [2, 4]) then
    Exit;
  bArchive := False;
  // JVCS 2026: archive deletes the module and all its revisions (not reversible): it needs
  // the word confirm after it, as removeproject/renameproject
  if Count = 4 then
  begin
    if (AnsiCompareText(LineParamStr(Line, 3), 'archive') <> 0) or
      (AnsiCompareText(LineParamStr(Line, 4), 'confirm') <> 0) then
      Exit;
    bArchive := True;
  end;
  ModuleID := -1;
  ModuleName := '';
  S := LineParamStr(Line, 2);
  ModuleID := StrToIntDef(S, -1);
  if ModuleID = -1 then
    ModuleName := S;
  try
    CheckOpenProject;
    CheckModuleOrLocalFile;
    if not internProjectHasModule(ProjectID, ModuleID) then
      if not (bArchive and internIsDesertedModule(ModuleID)) then
        raise Exception.CreateFmt('Module %d ''%s'' is not a member of project %d ''%s''',
          [ModuleID, ModuleName, ProjectID, ProjectName]);
    Owner := internModuleLockOwner(ModuleID);
    if Owner <> '' then
      raise Exception.CreateFmt(SModuleLocked, [ModuleID, ModuleName, Owner]);
    Shared := internSharedBy(ModuleID, ProjectID);
    if bArchive and (Shared <> '') then
      raise Exception.CreateFmt('Module %d ''%s'' is shared by project(s) %s: not removed (archive deletes only unshared modules)',
        [ModuleID, ModuleName, Shared]);
    RevCount := internRevisionCount(ModuleID);
    Writeln('Module: ', ModuleName, ' (ID ', ModuleID, ')');
    Writeln('Revisions: ', RevCount, ' (with files; revisions without files are not counted)');
    if Shared <> '' then
      Writeln('Shared by: ', Shared)
    else
      Writeln('Shared by: -');
    RemoveModule := TJVCSRemoveModule.Create(nil);
    try
      RemoveModule.ProjectID := ProjectID;
      RemoveModule.UserID := Connection.UserID;
      RemoveModule.ModuleID := ModuleID;
      RemoveModule.RemoveFromArchive := bArchive;
      RemoveModule.ModuleName := ShortString(ModuleName); // only for the server log, as the standalone sends path+name
      // 2.5 server with branches (Firebird): with archive, a module WITH revisions is refused with
      // status 400 and the transaction is rolled back (nothing changes): BRANCH_REMOVE_MODULE does
      // not delete revision/rvbranch (//todo) and LATESTREVISION references revision and modules.
      // REMOVE_REVISION fails the same way (LATESTREVISION). Only modules without revisions go.
      Connection.SendRequest(RemoveModule);
      ShowLog(RemoveModule);
      if RemoveModule.ModuleRemoved then
      begin
        if bArchive then
        begin
          // the server answers the deleted revision rows in the 2nd record (read as ProjectID);
          // the branch server answers nothing there (RevCount stays the history count)
          if RemoveModule.OutputItemCount > 0 then
            RevCount := RemoveModule.OutputItems[0].ProjectID;
          Writeln('Module removed from archive: ', ModuleName, ' (ID ', ModuleID, '), ', RevCount, ' revision(s) deleted');
        end
        else
          Writeln('Module removed from project: ', ModuleName, ' (ID ', ModuleID, ')');
      end
      else
      begin
        // False is the answer for a shared module (link removed, project list in the answer);
        // without the list nothing is known to have changed
        if RemoveModule.OutputItemCount = 0 then
          raise Exception.CreateFmt('Module %d ''%s'' not removed: the server answered False without the project list',
            [ModuleID, ModuleName]);
        S := '';
        for I := 0 to RemoveModule.OutputItemCount - 1 do
        begin
          if S <> '' then
            S := S + ',';
          S := S + IntToStr(RemoveModule.OutputItems[I].ProjectID);
        end;
        Writeln('Shared module: project link removed, module kept for project(s) ', S, ' (ID ', ModuleID, ')');
      end;
      Result := True;
    finally
      RemoveModule.Free;
    end;
  finally
    ModuleID := -1;
    ModuleName := '';
  end;
end;

function CmdProcRenameModule(const Line: string; var ExtExitCode: Integer): Boolean;
var
  S, NewName, Owner, Shared: string;
  RenameModule: TJVCSRenameModule;
begin
  Result := False;
  if LineParamCount(Line) <> 3 then
    Exit;
  ModuleID := -1;
  ModuleName := '';
  S := LineParamStr(Line, 2);
  ModuleID := StrToIntDef(S, -1);
  if ModuleID = -1 then
    ModuleName := S;
  NewName := Trim(LineParamStr(Line, 3));
  try
    if (NewName = '') or (ExtractFileName(NewName) <> NewName) or (Pos(':', NewName) > 0) or (Pos('/', NewName) > 0) then
      raise Exception.CreateFmt('Invalid new module name ''%s'': file name only, without folder', [NewName]);
    CheckOpenProject;
    CheckModuleOrLocalFile;
    if not internProjectHasModule(ProjectID, ModuleID) then
      raise Exception.CreateFmt('Module %d ''%s'' is not a member of project %d ''%s''',
        [ModuleID, ModuleName, ProjectID, ProjectName]);
    if AnsiCompareText(ExtractFileExt(NewName), ExtractFileExt(ModuleName)) <> 0 then
      raise Exception.CreateFmt('Module %d ''%s'': the extension cannot be changed (%s)', [ModuleID, ModuleName, NewName]);
    Owner := internModuleLockOwner(ModuleID);
    if Owner <> '' then
      raise Exception.CreateFmt(SModuleLocked, [ModuleID, ModuleName, Owner]);
    Shared := internSharedBy(ModuleID, ProjectID);
    if Shared <> '' then
      Writeln('Shared by: ', Shared, ' (renamed there too)');
    RenameModule := TJVCSRenameModule.Create(nil);
    try
      RenameModule.ModuleID := ModuleID;
      RenameModule.NewModuleName := AnsiLowerCase(NewName);
      RenameModule.ProjectID := ProjectID;
      Connection.SendRequest(RenameModule);
      ShowLog(RenameModule);
      if not RenameModule.Success then
        raise Exception.CreateFmt('Module %d ''%s'' not renamed: %s', [ModuleID, ModuleName, RenameModule.ErrorMessage]);
      Writeln('Module renamed: ', ModuleName, ' -> ', AnsiLowerCase(NewName), ' (ID ', ModuleID, ')');
      Result := True;
    finally
      RenameModule.Free;
    end;
  finally
    ModuleID := -1;
    ModuleName := '';
  end;
end;

function CmdProcHideModule(const Line: string; var ExtExitCode: Integer): Boolean;
var
  Count: Integer;
  S: string;
  bHide: Boolean;
  HideUnhideModule: TJVCSHideUnhideModule;
begin
  Result := False;
  Count := LineParamCount(Line);
  if not (Count in [2, 3]) then
    Exit;
  bHide := True;
  if Count = 3 then
  begin
    if AnsiCompareText(LineParamStr(Line, 3), 'unhide') <> 0 then
      Exit;
    bHide := False;
  end;
  ModuleID := -1;
  ModuleName := '';
  S := LineParamStr(Line, 2);
  ModuleID := StrToIntDef(S, -1);
  if ModuleID = -1 then
    ModuleName := S;
  try
    CheckOpenProject; // ProjectID > 0: ProjectID 0 would hide the module in ALL projects
    CheckModuleOrLocalFile;
    if not internProjectHasModule(ProjectID, ModuleID) then
      raise Exception.CreateFmt('Module %d ''%s'' is not a member of project %d ''%s''',
        [ModuleID, ModuleName, ProjectID, ProjectName]);
    HideUnhideModule := TJVCSHideUnhideModule.Create(nil);
    try
      HideUnhideModule.ProjectID := ProjectID;
      HideUnhideModule.ModuleID := ModuleID;
      HideUnhideModule.UserID := Connection.UserID;
      HideUnhideModule.Hide := bHide;
      Connection.SendRequest(HideUnhideModule);
      ShowLog(HideUnhideModule);
      if not HideUnhideModule.Success then
        raise Exception.CreateFmt('Module %d ''%s'' is checked out: hidden state not changed', [ModuleID, ModuleName]);
      if bHide then
        Writeln('Module hidden: ', ModuleName, ' (ID ', ModuleID, ')')
      else
        Writeln('Module unhidden: ', ModuleName, ' (ID ', ModuleID, ')');
      Result := True;
    finally
      HideUnhideModule.Free;
    end;
  finally
    ModuleID := -1;
    ModuleName := '';
  end;
end;

function CmdProcGetComment(const Line: string; var ExtExitCode: Integer): Boolean;
var
  RevisionID: Integer;
  GetRevisionComment: TJVCSGetRevisionComment;
begin
  Result := False;
  if LineParamCount(Line) <> 2 then
    Exit;
  RevisionID := StrToIntDef(LineParamStr(Line, 2), -1);
  if RevisionID <= 0 then
    Exit;
  GetRevisionComment := TJVCSGetRevisionComment.Create(nil);
  try
    GetRevisionComment.RevisionID := RevisionID;
    Connection.SendRequest(GetRevisionComment);
    ShowLog(GetRevisionComment);
    Writeln('Revision: ', RevisionID);
    Writeln('Checkin comment: ', EscapeHistoryComment(GetRevisionComment.CheckinComment));
    Writeln('Checkout comment: ', EscapeHistoryComment(GetRevisionComment.CheckoutComment));
    Writeln('Version state: ', GetRevisionComment.VersionState);
    Result := True;
  finally
    GetRevisionComment.Free;
  end;
end;

function CmdProcSetComment(const Line: string; var ExtExitCode: Integer): Boolean;
var
  RevisionID: Integer;
  S, Kind, NewText, OldText: string;
  GetRevisionComment: TJVCSGetRevisionComment;
  ChangeRevisionComment: TJVCSChangeRevisionComment;
begin
  Result := False;
  if LineParamCount(Line) <> 5 then
    Exit;
  RevisionID := StrToIntDef(LineParamStr(Line, 3), -1);
  Kind := LowerCase(LineParamStr(Line, 4));
  if (RevisionID <= 0) or ((Kind <> 'in') and (Kind <> 'out')) then
    Exit;
  NewText := UnescapeHistoryComment(LineParamStr(Line, 5));
  ModuleID := -1;
  ModuleName := '';
  S := LineParamStr(Line, 2);
  ModuleID := StrToIntDef(S, -1);
  if ModuleID = -1 then
    ModuleName := S;
  try
    CheckOpenProject;
    CheckModuleOrLocalFile;
    if not internProjectHasModule(ProjectID, ModuleID) then
      raise Exception.CreateFmt('Module %d ''%s'' is not a member of project %d ''%s''',
        [ModuleID, ModuleName, ProjectID, ProjectName]);
    if not internModuleHasRevision(ModuleID, RevisionID) then
      raise Exception.CreateFmt('Revision %d is not a revision of module %d ''%s''', [RevisionID, ModuleID, ModuleName]);
    GetRevisionComment := TJVCSGetRevisionComment.Create(nil);
    try
      GetRevisionComment.RevisionID := RevisionID;
      Connection.SendRequest(GetRevisionComment);
      ShowLog(GetRevisionComment);
      if Kind = 'in' then
        OldText := GetRevisionComment.CheckinComment
      else
        OldText := GetRevisionComment.CheckoutComment;
    finally
      GetRevisionComment.Free;
    end;
    Writeln('Module: ', ModuleName, ' (ID ', ModuleID, ')');
    Writeln('Old comment: ', EscapeHistoryComment(OldText));
    ChangeRevisionComment := TJVCSChangeRevisionComment.Create(nil);
    try
      ChangeRevisionComment.RevisionID := RevisionID;
      if Kind = 'in' then
        ChangeRevisionComment.CommentType := 'i'
      else
        ChangeRevisionComment.CommentType := 'o';
      ChangeRevisionComment.CommentValue := NewText;
      Connection.SendRequest(ChangeRevisionComment);
      ShowLog(ChangeRevisionComment);
    finally
      ChangeRevisionComment.Free;
    end;
    // read back: CHANGE_REVISION_COMMENT answers nothing
    GetRevisionComment := TJVCSGetRevisionComment.Create(nil);
    try
      GetRevisionComment.RevisionID := RevisionID;
      Connection.SendRequest(GetRevisionComment);
      ShowLog(GetRevisionComment);
      if Kind = 'in' then
        S := GetRevisionComment.CheckinComment
      else
        S := GetRevisionComment.CheckoutComment;
    finally
      GetRevisionComment.Free;
    end;
    if AdjustLineBreaks(TrimRight(S)) <> AdjustLineBreaks(TrimRight(NewText)) then
      raise Exception.CreateFmt('Revision %d: comment not changed on the server', [RevisionID]);
    Writeln('Comment changed: revision ', RevisionID, ' (', Kind, ')');
    Result := True;
  finally
    ModuleID := -1;
    ModuleName := '';
  end;
end;

//=== project administration (projectinfo, removeproject, restoreproject, renameproject,
//    linkmodule, projectgroups, setprojectgroup) ==========================================

// Resolves <project_name> | <project_id> also for deleted projects (CheckOpenProject refuses them).
// Always ends with GET_PROJECT_ID by name: the server rebinds this session's rights (transact.rights)
// to the project related level of THIS project (its project right, else the global level), like
// openproject does. Without it REMOVE/RESTORE/RENAME would run with the rights of the last opened project.
procedure internResolveProject(const S: string; out AID: Integer; out AName: string; out ADeleted: Boolean);
var
  GetProjectInformation: TJVCSGetProjectInformation;
  GetProjectId: TJVCSGetProjectId;
  N: Integer;
begin
  AID := 0;
  AName := '';
  ADeleted := False;
  N := StrToIntDef(S, -1);
  if N > 0 then
  begin
    GetProjectInformation := TJVCSGetProjectInformation.Create(nil);
    try
      GetProjectInformation.ProjectID := N;
      Connection.SendRequest(GetProjectInformation);
      ShowLog(GetProjectInformation);
      if (GetProjectInformation.OutputItemCount = 0) or (GetProjectInformation.OutputItems[0].ProjectID = 0) then
        raise Exception.CreateFmt(SProjectIDNotFound, [N]);
      AName := string(GetProjectInformation.OutputItems[0].ProjectName);
    finally
      GetProjectInformation.Free;
    end;
  end
  else
    AName := AnsiLowerCase(S);

  GetProjectId := TJVCSGetProjectId.Create(nil);
  try
    GetProjectId.ProjectName := AName;
    Connection.SendRequest(GetProjectId);
    ShowLog(GetProjectId);
    if GetProjectId.ProjectID = 0 then
      raise Exception.CreateFmt(SProjectNotFound, [AName]);
    if (N > 0) and (GetProjectId.ProjectID <> N) then
      raise Exception.CreateFmt('Project %d ''%s'': the name resolves to ID %d', [N, AName, GetProjectId.ProjectID]);
    AID := GetProjectId.ProjectID;
    ADeleted := GetProjectId.ProjectDeleted;
  finally
    GetProjectId.Free;
  end;
end;

// Prints 'Locked: id|owner|version|path_and_name' for every checked out module of the project
// (all users, GET_LOCKED_MODULES) and returns how many there are. The server query joins revisions
// and users, so a lock without revision or user is not listed here; REMOVE/RENAME check again.
function internListProjectLocks(AProjectID: Integer): Integer;
var
  GetLockedModules: TJVCSGetLockedModules;
  I: Integer;
begin
  GetLockedModules := TJVCSGetLockedModules.Create(nil);
  try
    GetLockedModules.ProjectID := AProjectID;
    GetLockedModules.UserID := 0; // all users
    Connection.SendRequest(GetLockedModules);
    ShowLog(GetLockedModules);
    Result := GetLockedModules.OutputItemCount;
    for I := 0 to GetLockedModules.OutputItemCount - 1 do
      Writeln('Locked: ', GetLockedModules.OutputItems[I].ModuleID, '|', GetLockedModules.OutputItems[I].Owner, '|',
        GetLockedModules.OutputItems[I].Version, '.', GetLockedModules.OutputItems[I].Revision, '|',
        GetLockedModules.OutputItems[I].ModulePath, GetLockedModules.OutputItems[I].ModuleName);
  finally
    GetLockedModules.Free;
  end;
end;

// Same rules as the standalone IsValidProjectName (VCSProcBase.pas:590) plus the 50 char limit.
procedure internCheckProjectName(const AName: string);
const
  Reserved: array [0..7] of string = ('project1.dpr', 'project1.bdsproj', 'project1.cbproj', 'project1.dproj',
    'package1.dpk', 'projectgroup1.bpg', 'unit1.pas', 'unit1.dfm');
  InvalidChars: TSysCharSet = ['"', '/', '\', '<', '>', '[', ']', ':', ';', '|', '{', '}', '*', '%', '?', #9];
var
  I: Integer;
begin
  if AName = '' then
    raise Exception.Create('Project names cannot be blank');
  if Length(AName) > 50 then
    raise Exception.Create('Project names are limited to 50 characters');
  for I := Low(Reserved) to High(Reserved) do
    if AnsiLowerCase(AName) = Reserved[I] then
      raise Exception.CreateFmt('''%s'' is a reserved project name', [AName]);
  for I := 1 to Length(AName) do
    if CharInSet(AName[I], InvalidChars) then
      raise Exception.CreateFmt('Project names cannot contain the character ''%s''', [AName[I]]);
end;

function CmdProcProjectInfo(const Line: string; var ExtExitCode: Integer): Boolean;
var
  PrjID, I, J, HiddenCount, SharedCount, LockCount, RefCount, RefByCount, GroupCount, RightCount, BugCount: Integer;
  PrjName, Shared, GroupName: string;
  PrjDeleted, IsHidden: Boolean;
  AllModules, VisibleModules: TJVCSGetProjectModuleList;
  VisibleIDs: TStringList;
  GetSharedBy: TJVCSGetSharedBy;
  GetProjectReferences, GetOtherRefs: TJVCSGetProjectReferences;
  GetAllProjects: TJVCSGetProjectInformation;
  GetGroupInfo: TJVCSGetProjectGroupInformation;
  GetProjectRights: TJVCSGetProjectRights;
  GetBugs: TJVCSGetBugsByProject;
begin
  Result := False;
  if LineParamCount(Line) <> 2 then
    Exit;
  Result := True;
  internResolveProject(LineParamStr(Line, 2), PrjID, PrjName, PrjDeleted);
  Writeln('Project: ', PrjName);
  Writeln('ProjectID: ', PrjID);
  Writeln('Deleted: ', Ord(PrjDeleted));
  HiddenCount := 0;
  SharedCount := 0;
  RefCount := 0;
  RefByCount := 0;
  GroupCount := 0;
  RightCount := 0;
  BugCount := 0;
  AllModules := nil;
  VisibleModules := nil;
  VisibleIDs := nil;
  GetProjectReferences := nil;
  GetAllProjects := nil;
  GetGroupInfo := nil;
  GetProjectRights := nil;
  GetBugs := nil;
  try
    AllModules := TJVCSGetProjectModuleList.Create(nil);
    AllModules.ProjectID := PrjID;
    AllModules.ExcludeHiddenModules := False;
    Connection.SendRequest(AllModules);
    ShowLog(AllModules);
    VisibleModules := TJVCSGetProjectModuleList.Create(nil);
    VisibleModules.ProjectID := PrjID;
    VisibleModules.ExcludeHiddenModules := True;
    Connection.SendRequest(VisibleModules);
    ShowLog(VisibleModules);
    VisibleIDs := TStringList.Create;
    for I := 0 to VisibleModules.OutputItemCount - 1 do
      VisibleIDs.Add(IntToStr(VisibleModules.OutputItems[I].ModuleID));

    for I := 0 to AllModules.OutputItemCount - 1 do
    begin
      Shared := '';
      GetSharedBy := TJVCSGetSharedBy.Create(nil);
      try
        GetSharedBy.ModuleID := AllModules.OutputItems[I].ModuleID;
        Connection.SendRequest(GetSharedBy);
        ShowLog(GetSharedBy);
        for J := 0 to GetSharedBy.OutputItemCount - 1 do
          if GetSharedBy.OutputItems[J].ProjectID <> PrjID then
          begin
            if Shared <> '' then
              Shared := Shared + ',';
            Shared := Shared + IntToStr(GetSharedBy.OutputItems[J].ProjectID);
          end;
      finally
        GetSharedBy.Free;
      end;
      IsHidden := VisibleIDs.IndexOf(IntToStr(AllModules.OutputItems[I].ModuleID)) < 0;
      if IsHidden then
        Inc(HiddenCount);
      if Shared <> '' then
        Inc(SharedCount);
      Writeln('Module: ', AllModules.OutputItems[I].ModuleID, '|', Ord(IsHidden), '|', Shared, '|',
        AllModules.OutputItems[I].ModulePath, '|', AllModules.OutputItems[I].ModuleName);
    end;

    LockCount := internListProjectLocks(PrjID);

    GetProjectReferences := TJVCSGetProjectReferences.Create(nil);
    GetProjectReferences.ProjectID := PrjID;
    Connection.SendRequest(GetProjectReferences);
    ShowLog(GetProjectReferences);
    for I := 0 to GetProjectReferences.OutputItemCount - 1 do
    begin
      Writeln('Reference: ', GetProjectReferences.OutputItems[I].ProjectID, '|', GetProjectReferences.OutputItems[I].ProjectName);
      Inc(RefCount);
    end;

    // REMOVE_PROJECT also deletes the references OTHER projects have to this one (pjref.reference)
    GetAllProjects := TJVCSGetProjectInformation.Create(nil);
    GetAllProjects.ProjectID := 0;
    Connection.SendRequest(GetAllProjects);
    ShowLog(GetAllProjects);
    for I := 0 to GetAllProjects.OutputItemCount - 1 do
      if (GetAllProjects.OutputItems[I].ProjectID <> PrjID) and not GetAllProjects.OutputItems[I].Deleted then
      begin
        GetOtherRefs := TJVCSGetProjectReferences.Create(nil);
        try
          GetOtherRefs.ProjectID := GetAllProjects.OutputItems[I].ProjectID;
          Connection.SendRequest(GetOtherRefs);
          ShowLog(GetOtherRefs);
          for J := 0 to GetOtherRefs.OutputItemCount - 1 do
            if GetOtherRefs.OutputItems[J].ProjectID = PrjID then
            begin
              Writeln('ReferencedBy: ', GetAllProjects.OutputItems[I].ProjectID, '|', GetAllProjects.OutputItems[I].ProjectName);
              Inc(RefByCount);
              Break;
            end;
        finally
          GetOtherRefs.Free;
        end;
      end;

    GetGroupInfo := TJVCSGetProjectGroupInformation.Create(nil);
    Connection.SendRequest(GetGroupInfo);
    ShowLog(GetGroupInfo);
    for I := 0 to GetGroupInfo.OutputItemCount - 1 do
      if (GetGroupInfo.OutputItems[I].RecordType = 'p') and (GetGroupInfo.OutputItems[I].ParentID = PrjID) then
      begin
        GroupName := '';
        for J := 0 to GetGroupInfo.OutputItemCount - 1 do
          if (GetGroupInfo.OutputItems[J].RecordType = 'g') and
            (GetGroupInfo.OutputItems[J].GroupID = GetGroupInfo.OutputItems[I].GroupID) then
          begin
            GroupName := string(GetGroupInfo.OutputItems[J].GroupName);
            Break;
          end;
        Writeln('Group: ', GetGroupInfo.OutputItems[I].GroupID, '|', GroupName);
        Inc(GroupCount);
      end;

    GetProjectRights := TJVCSGetProjectRights.Create(nil);
    Connection.SendRequest(GetProjectRights);
    ShowLog(GetProjectRights);
    for I := 0 to GetProjectRights.OutputItemCount - 1 do
      if GetProjectRights.OutputItems[I].ProjectID = PrjID then
      begin
        Writeln('Right: ', GetProjectRights.OutputItems[I].UserID, '|', GetProjectRights.OutputItems[I].AccessLevel);
        Inc(RightCount);
      end;

    // REMOVE_PROJECT deletes pjbugs too
    GetBugs := TJVCSGetBugsByProject.Create(nil);
    GetBugs.ProjectID := PrjID;
    Connection.SendRequest(GetBugs);
    ShowLog(GetBugs);
    for I := 0 to GetBugs.OutputItemCount - 1 do
    begin
      Writeln('Bug: ', GetBugs.OutputItems[I].BugID, '|', GetBugs.OutputItems[I].BugName);
      Inc(BugCount);
    end;

    Writeln(Format('Summary: modules=%d;hidden=%d;shared=%d;locked=%d;references=%d;referencedby=%d;groups=%d;rights=%d;bugs=%d',
      [AllModules.OutputItemCount, HiddenCount, SharedCount, LockCount, RefCount, RefByCount, GroupCount, RightCount, BugCount]));
  finally
    GetBugs.Free;
    GetProjectRights.Free;
    GetGroupInfo.Free;
    GetAllProjects.Free;
    GetProjectReferences.Free;
    VisibleIDs.Free;
    VisibleModules.Free;
    AllModules.Free;
  end;
end;

function CmdProcRemoveProject(const Line: string; var ExtExitCode: Integer): Boolean;
var
  PrjID, I: Integer;
  PrjName: string;
  PrjDeleted: Boolean;
  RemoveProject: TJVCSRemoveProject;
begin
  Result := False;
  if (LineParamCount(Line) <> 3) or (AnsiCompareText(LineParamStr(Line, 3), 'confirm') <> 0) then
    Exit;
  Result := True;
  internResolveProject(LineParamStr(Line, 2), PrjID, PrjName, PrjDeleted); // binds the rights to this project
  if PrjDeleted then
    raise Exception.CreateFmt('Project %d ''%s'' is already deleted', [PrjID, PrjName]);
  if internListProjectLocks(PrjID) > 0 then
    raise Exception.CreateFmt('Project %d ''%s'' not removed: it contains checked out modules (Locked: lines above). ' +
      'Check them in or undo the checkouts first.', [PrjID, PrjName]);

  RemoveProject := TJVCSRemoveProject.Create(nil);
  try
    RemoveProject.ProjectID := PrjID;
    Connection.SendRequest(RemoveProject);
    ShowLog(RemoveProject);
    if not RemoveProject.Removed then
    begin
      // the server checks again (a checkout may have happened after our check)
      for I := 0 to RemoveProject.OutputItemCount - 1 do
        Writeln('Locked: ', RemoveProject.OutputItems[I].ModuleID, '|||', RemoveProject.OutputItems[I].ModuleName);
      raise Exception.CreateFmt('Project %d ''%s'' not removed: %s', [PrjID, PrjName, RemoveProject.ErrorMessage]);
    end;
    Writeln('Project removed: ', PrjName, ' (ID ', PrjID, ')');
    if ProjectID = PrjID then
    begin
      ProjectID := 0;
      ProjectName := '';
    end;
  finally
    RemoveProject.Free;
  end;
end;

function CmdProcRestoreProject(const Line: string; var ExtExitCode: Integer): Boolean;
var
  PrjID, CheckID: Integer;
  PrjName, CheckName: string;
  PrjDeleted, CheckDeleted: Boolean;
  RestoreProject: TJVCSRestoreProject;
begin
  Result := False;
  if (LineParamCount(Line) <> 3) or (AnsiCompareText(LineParamStr(Line, 3), 'confirm') <> 0) then
    Exit;
  Result := True;
  internResolveProject(LineParamStr(Line, 2), PrjID, PrjName, PrjDeleted); // binds the rights to this project
  if not PrjDeleted then
    raise Exception.CreateFmt('Project %d ''%s'' is not deleted', [PrjID, PrjName]);
  RestoreProject := TJVCSRestoreProject.Create(nil);
  try
    RestoreProject.ProjectID := PrjID;
    Connection.SendRequest(RestoreProject);
    ShowLog(RestoreProject);
  finally
    RestoreProject.Free;
  end;
  // RESTORE_PROJECT has no answer and does not check the ID: read the flag again
  internResolveProject(IntToStr(PrjID), CheckID, CheckName, CheckDeleted);
  if CheckDeleted then
    raise Exception.CreateFmt('Project %d ''%s'' is still deleted after RESTORE_PROJECT', [PrjID, PrjName]);
  Writeln('Project restored: ', PrjName, ' (ID ', PrjID, ') - module links, rights, references and groups ' +
    'removed by removeproject are not restored');
end;

// RENAME_PROJECT only renames the project. The module names it gets are written to the old column
// modules.name, which the 2.5 server (branches: name, path and lock live in brmodule) no longer reads:
// the server answers "renamed", but nothing changes. So the project modules are renamed with
// RENAME_MODULE (the branch aware request of the standalone Rename module), one by one, and the
// result is read back with GET_PROJECT_MODULE_LIST.
function CmdProcRenameProject(const Line: string; var ExtExitCode: Integer): Boolean;
const
  ProjectFileExts: array [0..6] of string = ('.dpr', '.dpk', '.dproj', '.res', '.dof', '.cfg', '.dsk');
var
  Count, PrjID, I, J, K, ClashID, PlanCount: Integer;
  PrjName, NewName, S, ModName, NewModName, ErrText: string;
  PrjDeleted, RenameFiles, Confirmed, ClashDeleted, IsShared, Found: Boolean;
  PlanIDs: array of Integer;
  PlanOld, PlanNew: array of string;
  PlanOk: array of Boolean;
  PlanErr: array of string;
  GetProjectId: TJVCSGetProjectId;
  GetModuleId: TJVCSGetModuleId;
  GetSharedBy: TJVCSGetSharedBy;
  ModuleList: TJVCSGetProjectModuleList;
  RenameProject: TJVCSRenameProject;
  RenameModule: TJVCSRenameModule;
begin
  Result := False;
  Count := LineParamCount(Line);
  if not (Count in [4, 5]) then
    Exit;
  RenameFiles := False;
  Confirmed := False;
  for I := 4 to Count do
  begin
    S := LineParamStr(Line, I);
    if AnsiCompareText(S, 'renamefiles') = 0 then
      RenameFiles := True
    else
    if AnsiCompareText(S, 'confirm') = 0 then
      Confirmed := True
    else
      Exit;
  end;
  if not Confirmed then
    Exit;
  Result := True;

  NewName := AnsiLowerCase(Trim(LineParamStr(Line, 3)));
  internCheckProjectName(NewName);
  internResolveProject(LineParamStr(Line, 2), PrjID, PrjName, PrjDeleted); // binds the rights to this project
  if PrjDeleted then
    raise Exception.CreateFmt(SProjectDeleted, [PrjID, PrjName]);
  if SameText(PrjName, NewName) then
    raise Exception.Create('The new project name is the current one');
  if not SameText(ExtractFileExt(PrjName), ExtractFileExt(NewName)) then
    raise Exception.CreateFmt('The new project name must have the same file extension as the old one (%s)',
      [ExtractFileExt(PrjName)]);

  // the server does not check it; names stay reserved by deleted projects too.
  // An unknown name (ID 0) does not change the session rights.
  GetProjectId := TJVCSGetProjectId.Create(nil);
  try
    GetProjectId.ProjectName := NewName;
    Connection.SendRequest(GetProjectId);
    ShowLog(GetProjectId);
    ClashID := GetProjectId.ProjectID;
    ClashDeleted := GetProjectId.ProjectDeleted;
  finally
    GetProjectId.Free;
  end;
  if ClashID <> 0 then
  begin
    if ClashDeleted then
      raise Exception.CreateFmt('Project name ''%s'' is already in use (ID %d, deleted)', [NewName, ClashID])
    else
      raise Exception.CreateFmt('Project name ''%s'' is already in use (ID %d)', [NewName, ClashID]);
  end;

  if internListProjectLocks(PrjID) > 0 then
    raise Exception.CreateFmt('Project %d ''%s'' not renamed: it contains checked out modules (Locked: lines above)',
      [PrjID, PrjName]);

  // plan (and every check) before anything changes: ONLY modules of this project, from its own module
  // list (RENAME_MODULE renames any module ID it gets), never shared ones, never onto an existing module
  PlanCount := 0;
  if RenameFiles then
  begin
    ModuleList := TJVCSGetProjectModuleList.Create(nil);
    try
      ModuleList.ProjectID := PrjID;
      ModuleList.ExcludeHiddenModules := False;
      Connection.SendRequest(ModuleList);
      ShowLog(ModuleList);
      for I := 0 to ModuleList.OutputItemCount - 1 do
      begin
        ModName := string(ModuleList.OutputItems[I].ModuleName);
        for J := Low(ProjectFileExts) to High(ProjectFileExts) do
          if SameText(ModName, ChangeFileExt(ExtractFileName(PrjName), ProjectFileExts[J])) then
          begin
            // a shared module keeps its name (it is also a module of the other projects)
            IsShared := False;
            GetSharedBy := TJVCSGetSharedBy.Create(nil);
            try
              GetSharedBy.ModuleID := ModuleList.OutputItems[I].ModuleID;
              Connection.SendRequest(GetSharedBy);
              ShowLog(GetSharedBy);
              for K := 0 to GetSharedBy.OutputItemCount - 1 do
                if GetSharedBy.OutputItems[K].ProjectID <> PrjID then
                  IsShared := True;
            finally
              GetSharedBy.Free;
            end;
            if IsShared then
            begin
              Writeln('Module kept (shared): ', ModuleList.OutputItems[I].ModuleID, '|', ModName);
              Break;
            end;
            NewModName := AnsiLowerCase(ChangeFileExt(ExtractFileName(NewName), ExtractFileExt(ModName)));
            GetModuleId := TJVCSGetModuleId.Create(nil);
            try
              GetModuleId.ModuleName := string(ModuleList.OutputItems[I].ModulePath) + NewModName;
              Connection.SendRequest(GetModuleId);
              ShowLog(GetModuleId);
              if GetModuleId.ModuleID <> 0 then
                raise Exception.CreateFmt('Module ''%s%s'' already exists (ID %d): nothing renamed',
                  [string(ModuleList.OutputItems[I].ModulePath), NewModName, GetModuleId.ModuleID]);
            finally
              GetModuleId.Free;
            end;
            Inc(PlanCount);
            SetLength(PlanIDs, PlanCount);
            SetLength(PlanOld, PlanCount);
            SetLength(PlanNew, PlanCount);
            SetLength(PlanOk, PlanCount);
            SetLength(PlanErr, PlanCount);
            PlanIDs[PlanCount - 1] := ModuleList.OutputItems[I].ModuleID;
            PlanOld[PlanCount - 1] := ModName;
            PlanNew[PlanCount - 1] := NewModName;
            PlanOk[PlanCount - 1] := False;
            PlanErr[PlanCount - 1] := '';
            Writeln('Module to rename: ', ModuleList.OutputItems[I].ModuleID, '|', ModName);
            Break;
          end;
      end;
    finally
      ModuleList.Free;
    end;
  end;

  RenameProject := TJVCSRenameProject.Create(nil);
  try
    RenameProject.UserID := Connection.UserID;
    RenameProject.ProjectID := PrjID;
    RenameProject.NewProjectName := JVCSString50(NewName); // internCheckProjectName: at most 50 characters
    Connection.SendRequest(RenameProject);
    ShowLog(RenameProject);
    if not RenameProject.Renamed then
    begin
      // not renamed: the server sends [module id, name]; the client object keeps field 0 (the ID) in ModuleName
      for I := 0 to RenameProject.OutputItemCount - 1 do
        Writeln('Locked: ', RenameProject.OutputItems[I].ModuleName, '|||');
      raise Exception.CreateFmt('Project %d ''%s'' not renamed: it contains checked out modules', [PrjID, PrjName]);
    end;
  finally
    RenameProject.Free;
  end;
  Writeln('Project renamed: ', PrjName, ' -> ', NewName, ' (ID ', PrjID, ')');
  if ProjectID = PrjID then
    ProjectName := NewName;

  for I := 0 to PlanCount - 1 do
  begin
    ErrText := '';
    RenameModule := TJVCSRenameModule.Create(nil);
    try
      RenameModule.ModuleID := PlanIDs[I];
      RenameModule.NewModuleName := PlanNew[I];
      RenameModule.ProjectID := PrjID;
      try
        Connection.SendRequest(RenameModule);
        ShowLog(RenameModule);
        if not RenameModule.Success then
          ErrText := RenameModule.ErrorMessage;
      except
        on E: Exception do
          ErrText := E.Message;
      end;
    finally
      RenameModule.Free;
    end;
    PlanErr[I] := StringReplace(StringReplace(ErrText, #13, ' ', [rfReplaceAll]), #10, ' ', [rfReplaceAll]);
  end;

  // read the names back: only a module whose name really changed counts as renamed
  if PlanCount > 0 then
  begin
    ModuleList := TJVCSGetProjectModuleList.Create(nil);
    try
      ModuleList.ProjectID := PrjID;
      ModuleList.ExcludeHiddenModules := False;
      Connection.SendRequest(ModuleList);
      ShowLog(ModuleList);
      for I := 0 to PlanCount - 1 do
      begin
        Found := False;
        for J := 0 to ModuleList.OutputItemCount - 1 do
          if ModuleList.OutputItems[J].ModuleID = PlanIDs[I] then
          begin
            Found := True;
            PlanOk[I] := SameText(string(ModuleList.OutputItems[J].ModuleName), PlanNew[I]);
            Break;
          end;
        if PlanOk[I] then
          Writeln('Module renamed: ', PlanIDs[I], '|', PlanOld[I], '|', PlanNew[I])
        else
        begin
          ErrText := PlanErr[I];
          if ErrText = '' then
            if Found then
              ErrText := 'name unchanged on the server'
            else
              ErrText := 'no longer in the project';
          Writeln('Module not renamed: ', PlanIDs[I], '|', PlanOld[I], '|', PlanNew[I], '|', ErrText);
        end;
      end;
    finally
      ModuleList.Free;
    end;
  end;
end;

function CmdProcLinkModule(const Line: string; var ExtExitCode: Integer): Boolean;
var
  Count, WantedID: Integer;
  FullName: string;
  MakeHidden: Boolean;
  GetModuleId: TJVCSGetModuleId;
  AddNewModule: TJVCSAddNewModule;
  HideUnhideModule: TJVCSHideUnhideModule;
begin
  Result := False;
  Count := LineParamCount(Line);
  if not (Count in [3, 4]) then
    Exit;
  WantedID := StrToIntDef(LineParamStr(Line, 2), -1);
  if WantedID <= 0 then
    Exit;
  FullName := AnsiLowerCase(LineParamStr(Line, 3));
  MakeHidden := False;
  if Count = 4 then
  begin
    if AnsiCompareText(LineParamStr(Line, 4), 'hidden') <> 0 then
      Exit;
    MakeHidden := True;
  end;
  if (FullName = '') or (ExtractFilePath(FullName) = '') then
    Exit;
  Result := True;
  CheckOpenProject;

  // same lookup as ADD_NEW_MODULE (name + path, lower case): if it does not give this ID,
  // the server would create a new, empty module instead of linking the old one
  GetModuleId := TJVCSGetModuleId.Create(nil);
  try
    GetModuleId.ModuleName := FullName;
    Connection.SendRequest(GetModuleId);
    ShowLog(GetModuleId);
    if GetModuleId.ModuleID <> WantedID then
      raise Exception.CreateFmt('Module ''%s'' resolves to ID %d, not %d: nothing linked',
        [FullName, GetModuleId.ModuleID, WantedID]);
  finally
    GetModuleId.Free;
  end;

  AddNewModule := TJVCSAddNewModule.Create(nil);
  try
    AddNewModule.ProjectID := ProjectID;
    AddNewModule.UserID := Connection.UserID;
    AddNewModule.ModuleFullName := FullName;
    AddNewModule.Flags := 4096; // ignored for an existing module
    AddNewModule.Description := ExtractFileName(FullName);
    Connection.SendRequest(AddNewModule);
    ShowLog(AddNewModule);
    if AddNewModule.IsNewModule or (AddNewModule.ModuleID <> WantedID) then
      raise Exception.CreateFmt('ADD_NEW_MODULE returned module %d (new: %s) instead of linking %d; ' +
        'that module may now be linked to the project: check with projectinfo',
        [AddNewModule.ModuleID, BoolToStr(AddNewModule.IsNewModule, True), WantedID]);
  finally
    AddNewModule.Free;
  end;
  Writeln('Module linked: ', FullName, ' (ID ', WantedID, ')');

  if MakeHidden then
  begin
    HideUnhideModule := TJVCSHideUnhideModule.Create(nil);
    try
      HideUnhideModule.ProjectID := ProjectID;
      HideUnhideModule.ModuleID := WantedID;
      HideUnhideModule.UserID := Connection.UserID;
      HideUnhideModule.Hide := True;
      Connection.SendRequest(HideUnhideModule);
      ShowLog(HideUnhideModule);
      if not HideUnhideModule.Success then
        raise Exception.CreateFmt('Module %d linked, but not hidden', [WantedID]);
      Writeln('Module hidden: ', FullName, ' (ID ', WantedID, ')');
    finally
      HideUnhideModule.Free;
    end;
  end;
end;

function CmdProcProjectGroups(const Line: string; var ExtExitCode: Integer): Boolean;
var
  GetGroupInfo: TJVCSGetProjectGroupInformation;
  I: Integer;
begin
  Result := False;
  if LineParamCount(Line) <> 1 then
    Exit;
  GetGroupInfo := TJVCSGetProjectGroupInformation.Create(nil);
  try
    Connection.SendRequest(GetGroupInfo);
    ShowLog(GetGroupInfo);
    for I := 0 to GetGroupInfo.OutputItemCount - 1 do
      if GetGroupInfo.OutputItems[I].RecordType = 'g' then
        Writeln('Group: ', GetGroupInfo.OutputItems[I].GroupID, '|', GetGroupInfo.OutputItems[I].ParentID, '|',
          GetGroupInfo.OutputItems[I].GroupLevel, '|', GetGroupInfo.OutputItems[I].GroupName)
      else
      if GetGroupInfo.OutputItems[I].RecordType = 'p' then
        Writeln('Member: ', GetGroupInfo.OutputItems[I].GroupID, '|', GetGroupInfo.OutputItems[I].ParentID);
    Result := True;
  finally
    GetGroupInfo.Free;
  end;
end;

function CmdProcSetProjectGroup(const Line: string; var ExtExitCode: Integer): Boolean;
var
  PrjID, GroupID, I: Integer;
  PrjName, Mode: string;
  PrjDeleted, GroupFound: Boolean;
  GetGroupInfo: TJVCSGetProjectGroupInformation;
  AddRemove: TJVCSAddRemoveProjectToGroup;
begin
  Result := False;
  if LineParamCount(Line) <> 4 then
    Exit;
  GroupID := StrToIntDef(LineParamStr(Line, 3), 0);
  Mode := LowerCase(LineParamStr(Line, 4));
  if (GroupID <= 0) or ((Mode <> 'add') and (Mode <> 'remove')) then
    Exit;
  Result := True;
  internResolveProject(LineParamStr(Line, 2), PrjID, PrjName, PrjDeleted); // binds the rights to this project
  if PrjDeleted then
    raise Exception.CreateFmt(SProjectDeleted, [PrjID, PrjName]);

  GroupFound := False;
  GetGroupInfo := TJVCSGetProjectGroupInformation.Create(nil);
  try
    Connection.SendRequest(GetGroupInfo);
    ShowLog(GetGroupInfo);
    for I := 0 to GetGroupInfo.OutputItemCount - 1 do
      if (GetGroupInfo.OutputItems[I].RecordType = 'g') and (GetGroupInfo.OutputItems[I].GroupID = GroupID) then
      begin
        GroupFound := True;
        Break;
      end;
  finally
    GetGroupInfo.Free;
  end;
  if not GroupFound then
    raise Exception.CreateFmt(SProjectGroupIDNotFound, [GroupID]);

  AddRemove := TJVCSAddRemoveProjectToGroup.Create(nil);
  try
    AddRemove.ProjectID := PrjID;
    AddRemove.GroupID := GroupID;
    AddRemove.Add := Mode = 'add';
    Connection.SendRequest(AddRemove);
    ShowLog(AddRemove);
    if Mode = 'remove' then
      Writeln('Project group removed: ', PrjName, ' (ID ', PrjID, ') from group ', GroupID)
    else
    if AddRemove.Added then
      Writeln('Project group added: ', PrjName, ' (ID ', PrjID, ') to group ', GroupID)
    else
      Writeln('Project group already set: ', PrjName, ' (ID ', PrjID, ') in group ', GroupID);
  finally
    AddRemove.Free;
  end;
end;

// Label given as '#<label_id>' or by name (case-insensitive with the locale, like labelproject's
// AnsiCompareText, so both resolve the same label). Returns the ID and the name stored on the server.
function ResolveLabel(const S: string; out ALabelName: string): Integer;
var
  GetLabels: TJVCSGetLabels;
  I, WantID: Integer;
begin
  Result := 0;
  ALabelName := '';
  WantID := 0;
  if (Length(S) > 1) and (S[1] = '#') then
    WantID := StrToIntDef(Copy(S, 2, MaxInt), 0);
  GetLabels := TJVCSGetLabels.Create(nil);
  try
    GetLabels.IncludeDescription := False;
    Connection.SendRequest(GetLabels);
    ShowLog(GetLabels);
    for I := 0 to GetLabels.OutputItemCount - 1 do
      if ((WantID > 0) and (GetLabels.OutputItems[I].LabelID = WantID)) or
        ((WantID = 0) and AnsiSameText(string(GetLabels.OutputItems[I].LabelName), S)) then
      begin
        Result := GetLabels.OutputItems[I].LabelID;
        ALabelName := string(GetLabels.OutputItems[I].LabelName);
        Break;
      end;
  finally
    GetLabels.Free;
  end;
  if Result = 0 then
    raise Exception.CreateFmt(SLabelNotFound, [S]);
end;

function CmdProcListLabels(const Line: string; var ExtExitCode: Integer): Boolean;
var
  Count, I, J, N, Shown: Integer;
  S: string;
  GetLabels: TJVCSGetLabels;
  GetLabelsByProject: TJVCSGetLabelsByProject;
  Item: TGetLabelsOutputItem;
begin
  Result := False;
  Count := LineParamCount(Line);
  if not (Count in [1, 2]) then
    Exit;
  GetLabelsByProject := nil;
  GetLabels := TJVCSGetLabels.Create(nil);
  try
    if Count = 2 then
    begin
      S := LineParamStr(Line, 2);
      ProjectID := StrToIntDef(S, -1);
      if ProjectID = -1 then
        ProjectName := S
      else
        ProjectName := '';
      CheckOpenProject;
      GetLabelsByProject := TJVCSGetLabelsByProject.Create(nil);
      GetLabelsByProject.ProjectID := ProjectID;
      Connection.SendRequest(GetLabelsByProject);
      ShowLog(GetLabelsByProject);
      Writeln('Project: ', EscapeHistoryComment(ProjectName), ' (ID ', ProjectID, ')');
      Writeln;
    end;
    GetLabels.IncludeDescription := True;
    Connection.SendRequest(GetLabels);
    ShowLog(GetLabels);
    Write(StrAlign('ID', 8), ' ');
    Write(StrAlign('Label', 50), ' ');
    if Assigned(GetLabelsByProject) then
      Write(StrAlign('Modules', 7), ' ');
    Writeln('Description');
    Write(StringOfChar('=', 8), ' ');
    Write(StringOfChar('=', 50), ' ');
    if Assigned(GetLabelsByProject) then
      Write(StringOfChar('=', 7), ' ');
    Writeln(StringOfChar('=', 11));
    Shown := 0;
    for I := 0 to GetLabels.OutputItemCount - 1 do
    begin
      Item := GetLabels.OutputItems[I];
      N := 0;
      if Assigned(GetLabelsByProject) then
      begin
        // one row per (module, revision, label), hidden modules included; the server keeps a
        // label on one revision per module (ADD_REMOVE_REVISION_LABEL)
        for J := 0 to GetLabelsByProject.OutputItemCount - 1 do
          if GetLabelsByProject.OutputItems[J].LabelID = Item.LabelID then
            Inc(N);
        if N = 0 then
          Continue;
      end;
      Write(StrAlign(IntToStr(Item.LabelID), 8), ' ');
      // server text: escaped so that it never breaks the fixed columns
      Write(StrAlign(EscapeHistoryComment(string(Item.LabelName)), 50), ' ');
      if Assigned(GetLabelsByProject) then
        Write(StrAlign(IntToStr(N), 7), ' ');
      Writeln(EscapeHistoryComment(Item.Description));
      Inc(Shown);
    end;
    Writeln;
    Writeln(Shown, ' label(s)');
    Result := True;
  finally
    GetLabelsByProject.Free;
    GetLabels.Free;
  end;
end;

function CmdProcLabelRevs(const Line: string; var ExtExitCode: Integer): Boolean;
var
  I, J, LabelID, Modules: Integer;
  S, LabelName, Exts: string;
  GetLatestRevisions: TJVCSGetLatestRevisions;
  Item: TGetLatestRevisionsOutputItem;
begin
  Result := False;
  if LineParamCount(Line) <> 3 then
    Exit;
  if Trim(LineParamStr(Line, 3)) = '' then
    Exit;
  S := LineParamStr(Line, 2);
  ProjectID := StrToIntDef(S, -1);
  if ProjectID = -1 then
    ProjectName := S
  else
    ProjectName := '';
  CheckOpenProject;
  LabelID := ResolveLabel(LineParamStr(Line, 3), LabelName);
  GetLatestRevisions := TJVCSGetLatestRevisions.Create(nil);
  try
    GetLatestRevisions.ProjectID := ProjectID;
    GetLatestRevisions.ExcludeHiddenModules := True; // same set as labelproject
    GetLatestRevisions.LabelID := LabelID;
    Connection.SendRequest(GetLatestRevisions);
    ShowLog(GetLatestRevisions);
    Writeln('Project: ', EscapeHistoryComment(ProjectName), ' (ID ', ProjectID, ')');
    Writeln('Label: ', EscapeHistoryComment(LabelName), ' (ID ', LabelID, ')');
    Writeln;
    Write(StrAlign('ID', 8), ' ');
    Write(StrAlign('Version', 7), ' ');
    Write(StrAlign('RevID', 8), ' ');
    Write(StrAlign('Files', 30), ' ');
    Writeln('Module');
    Write(StringOfChar('=', 8), ' ');
    Write(StringOfChar('=', 7), ' ');
    Write(StringOfChar('=', 8), ' ');
    Write(StringOfChar('=', 30), ' ');
    Writeln(StringOfChar('=', 6));
    // one output item per family member; only the first member of a revision carries
    // the module name and path (server GET_LATEST_REVISIONS)
    Modules := 0;
    I := 0;
    while I < GetLatestRevisions.OutputItemCount do
    begin
      Item := GetLatestRevisions.OutputItems[I];
      Exts := string(Item.RevisionExtension);
      J := I + 1;
      while (J < GetLatestRevisions.OutputItemCount) and
        (GetLatestRevisions.OutputItems[J].ModuleID = Item.ModuleID) and
        (GetLatestRevisions.OutputItems[J].RevisionID = Item.RevisionID) do
      begin
        Exts := Exts + ',' + string(GetLatestRevisions.OutputItems[J].RevisionExtension);
        Inc(J);
      end;
      Write(StrAlign(IntToStr(Item.ModuleID), 8), ' ');
      Write(StrAlign(Format('%d.%d', [Item.Version, Item.Revision]), 7), ' ');
      Write(StrAlign(IntToStr(Item.RevisionID), 8), ' ');
      Write(StrAlign(Exts, 30), ' ');
      Writeln(EscapeHistoryComment(string(Item.ModuleName)));
      Inc(Modules);
      I := J;
    end;
    Writeln;
    Writeln(Modules, ' module(s)');
    Result := True;
  finally
    GetLatestRevisions.Free;
  end;
end;

function CmdProcModuleLabels(const Line: string; var ExtExitCode: Integer): Boolean;
var
  I, J, Rows, RevID: Integer;
  S: string;
  Versions: TStringList; // 'RevisionID=version.revision', history order
  GetModuleHistory: TJVCSGetModuleHistory;
  GetLabelsByModule: TJVCSGetLabelsByModule;
  GetLabelsByRevision: TJVCSGetLabelsByRevision;
  H: TGetModuleHistoryOutputItem;

  procedure WriteRow(ARevisionID, ALabelID: Integer; const ALabelName, ADescription: string);
  var
    V: string;
  begin
    V := Versions.Values[IntToStr(ARevisionID)];
    if V = '' then
      V := '?';
    Write(StrAlign(V, 7), ' ');
    Write(StrAlign(IntToStr(ARevisionID), 8), ' ');
    Write(StrAlign(IntToStr(ALabelID), 8), ' ');
    // server text: escaped so that it never breaks the fixed columns
    Write(StrAlign(EscapeHistoryComment(ALabelName), 50), ' ');
    Writeln(EscapeHistoryComment(ADescription));
    Inc(Rows);
  end;

begin
  Result := False;
  if LineParamCount(Line) <> 2 then
    Exit;
  ModuleID := -1;
  ModuleName := '';
  S := LineParamStr(Line, 2);
  ModuleID := StrToIntDef(S, -1);
  if ModuleID = -1 then
    ModuleName := S;
  Rows := 0;
  Versions := TStringList.Create;
  try
    CheckModuleOrLocalFile;
    GetModuleHistory := TJVCSGetModuleHistory.Create(nil);
    try
      GetModuleHistory.ModuleID := ModuleID;
      Connection.SendRequest(GetModuleHistory);
      ShowLog(GetModuleHistory);
      // one item per family member: keep one entry per revision
      for I := 0 to GetModuleHistory.OutputItemCount - 1 do
      begin
        H := GetModuleHistory.OutputItems[I];
        if Versions.IndexOfName(IntToStr(H.RevisionID)) < 0 then
          Versions.Add(Format('%d=%d.%d', [H.RevisionID, H.Version, H.Revision]));
      end;
    finally
      GetModuleHistory.Free;
    end;
    Writeln('Module: ', EscapeHistoryComment(ModuleName), ' (ID ', ModuleID, ')');
    Writeln;
    Write(StrAlign('Version', 7), ' ');
    Write(StrAlign('RevID', 8), ' ');
    Write(StrAlign('LabelID', 8), ' ');
    Write(StrAlign('Label', 50), ' ');
    Writeln('Description');
    Write(StringOfChar('=', 7), ' ');
    Write(StringOfChar('=', 8), ' ');
    Write(StringOfChar('=', 8), ' ');
    Write(StringOfChar('=', 50), ' ');
    Writeln(StringOfChar('=', 11));
    if Connection.SupportsFunction(TJVCSGetLabelsByModule) then
    begin
      GetLabelsByModule := TJVCSGetLabelsByModule.Create(nil);
      try
        GetLabelsByModule.ModuleID := ModuleID;
        Connection.SendRequest(GetLabelsByModule);
        ShowLog(GetLabelsByModule);
        for I := 0 to GetLabelsByModule.OutputItemCount - 1 do
          WriteRow(GetLabelsByModule.OutputItems[I].RevisionID, GetLabelsByModule.OutputItems[I].LabelID,
            string(GetLabelsByModule.OutputItems[I].LabelName), GetLabelsByModule.OutputItems[I].Description);
      finally
        GetLabelsByModule.Free;
      end;
    end
    else
      // older servers: one GET_LABELS_BY_REVISION per revision (as History.pas)
      for I := 0 to Versions.Count - 1 do
      begin
        RevID := StrToInt(Versions.Names[I]);
        GetLabelsByRevision := TJVCSGetLabelsByRevision.Create(nil);
        try
          GetLabelsByRevision.RevisionID := RevID;
          Connection.SendRequest(GetLabelsByRevision);
          ShowLog(GetLabelsByRevision);
          for J := 0 to GetLabelsByRevision.OutputItemCount - 1 do
            WriteRow(RevID, GetLabelsByRevision.OutputItems[J].LabelID,
              string(GetLabelsByRevision.OutputItems[J].LabelName), GetLabelsByRevision.OutputItems[J].Description);
        finally
          GetLabelsByRevision.Free;
        end;
      end;
    Writeln;
    Writeln(Rows, ' label(s)');
    Result := True;
  finally
    Versions.Free;
    ModuleID := -1;
    ModuleName := '';
  end;
end;

function CmdProcSharedBy(const Line: string; var ExtExitCode: Integer): Boolean;
var
  I: Integer;
  S: string;
  GetSharedBy: TJVCSGetSharedBy;
  Prj: TGetSharedByOutputItem;
begin
  Result := False;
  if LineParamCount(Line) <> 2 then
    Exit;
  ModuleID := -1;
  ModuleName := '';
  S := LineParamStr(Line, 2);
  ModuleID := StrToIntDef(S, -1);
  if ModuleID = -1 then
    ModuleName := S;
  try
    CheckModuleOrLocalFile;
    GetSharedBy := TJVCSGetSharedBy.Create(nil);
    try
      GetSharedBy.ModuleID := ModuleID;
      Connection.SendRequest(GetSharedBy);
      ShowLog(GetSharedBy);
      Writeln('Module: ', EscapeHistoryComment(ModuleName), ' (ID ', ModuleID, ')');
      Writeln;
      Write(StrAlign('PrjID', 8), ' ');
      Writeln('Project');
      Write(StringOfChar('=', 8), ' ');
      Writeln(StringOfChar('=', 7));
      for I := 0 to GetSharedBy.OutputItemCount - 1 do
      begin
        Prj := GetSharedBy.OutputItems[I];
        Write(StrAlign(IntToStr(Prj.ProjectID), 8), ' ');
        Writeln(EscapeHistoryComment(string(Prj.ProjectName)));
      end;
      Writeln;
      Writeln(GetSharedBy.OutputItemCount, ' project(s)');
      Result := True;
    finally
      GetSharedBy.Free;
    end;
  finally
    ModuleID := -1;
    ModuleName := '';
  end;
end;

function CmdProcSharedModules(const Line: string; var ExtExitCode: Integer): Boolean;
var
  I, J, Rows, Modules: Integer;
  S: string;
  SharedIDs, Done: TStringList;
  GetSharedModules: TJVCSGetSharedModules;
  GetLatestRevisions: TJVCSGetLatestRevisions;
  GetSharedBy: TJVCSGetSharedBy;
  Rev: TGetLatestRevisionsOutputItem;
  Prj: TGetSharedByOutputItem;
begin
  Result := False;
  if LineParamCount(Line) <> 2 then
    Exit;
  S := LineParamStr(Line, 2);
  ProjectID := StrToIntDef(S, -1);
  if ProjectID = -1 then
    ProjectName := S
  else
    ProjectName := '';
  CheckOpenProject;
  SharedIDs := TStringList.Create;
  Done := TStringList.Create;
  GetSharedModules := nil;
  GetLatestRevisions := nil;
  try
    SharedIDs.Sorted := True;
    SharedIDs.Duplicates := dupIgnore;
    Done.Sorted := True;
    Done.Duplicates := dupIgnore;
    // GET_SHARED_MODULES has no input: every module of the archive that is in more than one project
    GetSharedModules := TJVCSGetSharedModules.Create(nil);
    Connection.SendRequest(GetSharedModules);
    ShowLog(GetSharedModules);
    for I := 0 to GetSharedModules.OutputItemCount - 1 do
      SharedIDs.Add(IntToStr(GetSharedModules.OutputItems[I].ModuleID));
    // module names of the project (hidden ones too: sharing does not depend on it)
    GetLatestRevisions := TJVCSGetLatestRevisions.Create(nil);
    GetLatestRevisions.ProjectID := ProjectID;
    GetLatestRevisions.ExcludeHiddenModules := False;
    GetLatestRevisions.LabelID := 0;
    Connection.SendRequest(GetLatestRevisions);
    ShowLog(GetLatestRevisions);
    Writeln('Project: ', EscapeHistoryComment(ProjectName), ' (ID ', ProjectID, ')');
    Writeln;
    Write(StrAlign('ID', 8), ' ');
    Write(StrAlign('PrjID', 8), ' ');
    Write(StrAlign('Project', 50), ' ');
    Writeln('Module');
    Write(StringOfChar('=', 8), ' ');
    Write(StringOfChar('=', 8), ' ');
    Write(StringOfChar('=', 50), ' ');
    Writeln(StringOfChar('=', 6));
    Rows := 0;
    Modules := 0;
    for I := 0 to GetLatestRevisions.OutputItemCount - 1 do
    begin
      Rev := GetLatestRevisions.OutputItems[I];
      // only the first member of a revision carries the module name (server GET_LATEST_REVISIONS)
      if (Rev.ModuleName = '') or (SharedIDs.IndexOf(IntToStr(Rev.ModuleID)) < 0) or
        (Done.IndexOf(IntToStr(Rev.ModuleID)) >= 0) then
        Continue;
      Done.Add(IntToStr(Rev.ModuleID));
      Inc(Modules);
      GetSharedBy := TJVCSGetSharedBy.Create(nil);
      try
        GetSharedBy.ModuleID := Rev.ModuleID;
        Connection.SendRequest(GetSharedBy);
        ShowLog(GetSharedBy);
        for J := 0 to GetSharedBy.OutputItemCount - 1 do
        begin
          Prj := GetSharedBy.OutputItems[J];
          Write(StrAlign(IntToStr(Rev.ModuleID), 8), ' ');
          Write(StrAlign(IntToStr(Prj.ProjectID), 8), ' ');
          // server text: escaped so that it never breaks the fixed columns
          Write(StrAlign(EscapeHistoryComment(string(Prj.ProjectName)), 50), ' ');
          Writeln(EscapeHistoryComment(string(Rev.ModuleName)));
          Inc(Rows);
        end;
      finally
        GetSharedBy.Free;
      end;
    end;
    Writeln;
    Writeln(Modules, ' shared module(s), ', Rows, ' row(s)');
    Result := True;
  finally
    GetLatestRevisions.Free;
    GetSharedModules.Free;
    Done.Free;
    SharedIDs.Free;
  end;
end;

// since=yyyy-mm-dd[Thh:nn[:ss]] in local time (a space instead of the T is accepted, within quotes).
function ParseProjectLogSince(const S: string; out DT: TDateTime): Boolean;
var
  Y, Mo, D, H, Mi, Se: Integer;
  T: TDateTime;
begin
  Result := False;
  DT := 0;
  if not ((Length(S) = 10) or (Length(S) = 16) or (Length(S) = 19)) then
    Exit;
  if (S[5] <> '-') or (S[8] <> '-') then
    Exit;
  Y := StrToIntDef(Copy(S, 1, 4), -1);
  Mo := StrToIntDef(Copy(S, 6, 2), -1);
  D := StrToIntDef(Copy(S, 9, 2), -1);
  H := 0;
  Mi := 0;
  Se := 0;
  if Length(S) > 10 then
  begin
    if not CharInSet(S[11], ['T', 't', ' ']) or (S[14] <> ':') then
      Exit;
    H := StrToIntDef(Copy(S, 12, 2), -1);
    Mi := StrToIntDef(Copy(S, 15, 2), -1);
    if Length(S) = 19 then
    begin
      if S[17] <> ':' then
        Exit;
      Se := StrToIntDef(Copy(S, 18, 2), -1);
    end;
  end;
  if (Y < 1990) or (Mo < 1) or (D < 1) or (H < 0) or (Mi < 0) or (Se < 0) then
    Exit;
  if not TryEncodeDate(Y, Mo, D, DT) then
    Exit;
  if not TryEncodeTime(H, Mi, Se, 0, T) then
    Exit;
  DT := DT + T;
  Result := True;
end;

// Check-ins (vcslog type 'i') of the modules of a project. The log is the only source of the real
// check-in time (table revision has no date; the Timestamp of GET_MODULE_HISTORY is the file date).
// Reads all projects (ProjectID = 0) and filters by the modules of the project: shared modules
// get check-ins from other projects. The version comes from GET_MODULE_HISTORY, matching user and
// exact comment (GET_LOG_COMMENT reads the comment of the revision linked to the log entry).
function CmdProcProjectLog(const Line: string; var ExtExitCode: Integer): Boolean;
type
  TPLogRow = record
    LogID, ModuleID, ModIdx, RevisionID, Version, Revision: Integer;
    Stamp: TDateTime;
    UserName, ViaProject, Kind, Comment: string;
    Linked: Boolean;
  end;
  TPLogRev = record
    RevisionID, Version, Revision: Integer;
    UserName, Comment: string;
  end;
var
  Count, I, J, K, N, RevPtr, MaxCount, FilterUserID, First, OldProjectID: Integer;
  S, UserText, LogState, OldProjectName, NoRevMark: string;
  HasSince, NoRev: Boolean;
  SinceLocal: TDateTime;
  ModIDs: array of Integer;
  ModNames: array of string;
  ModDone: array of Boolean;
  Rows: array of TPLogRow;
  Revs: array of TPLogRev;
  Tmp: TPLogRev;
  GetServerOptions: TJVCSGetServerOptions;
  GetUsers: TJVCSGetUsers;
  GetModuleList: TJVCSGetProjectModuleList;
  GetLogEntries: TJVCSGetLogEntries;
  GetLogComment: TJVCSGetLogComment;
  GetModuleHistory: TJVCSGetModuleHistory;
  MItem: TGetProjectModuleListOutputItem;
  LItem: TGetLogEntriesOutputItem;
  HItem: TGetModuleHistoryOutputItem;

  function ModuleIndex(AModuleID: Integer): Integer;
  var
    X: Integer;
  begin
    Result := -1;
    for X := 0 to High(ModIDs) do
      if ModIDs[X] = AModuleID then
      begin
        Result := X;
        Break;
      end;
  end;

begin
  Result := False;
  Count := LineParamCount(Line);
  if Count < 2 then
    Exit;
  HasSince := False;
  SinceLocal := 0;
  UserText := '';
  MaxCount := 0;
  NoRev := False;
  for I := 3 to Count do
  begin
    S := LineParamStr(Line, I);
    if Pos('since=', AnsiLowerCase(S)) = 1 then
    begin
      if not ParseProjectLogSince(Copy(S, 7, MaxInt), SinceLocal) then
        raise Exception.CreateFmt('Invalid date in ''%s'' (use since=yyyy-mm-dd or since=yyyy-mm-ddThh:nn[:ss], local time)', [S]);
      HasSince := True;
    end
    else
    if Pos('user=', AnsiLowerCase(S)) = 1 then
    begin
      UserText := Trim(Copy(S, 6, MaxInt));
      if UserText = '' then
        Exit;
    end
    else
    if Pos('max=', AnsiLowerCase(S)) = 1 then
    begin
      MaxCount := StrToIntDef(Copy(S, 5, MaxInt), -1);
      if MaxCount < 0 then
        Exit;
    end
    else
    if AnsiCompareText(S, 'norev') = 0 then
      NoRev := True
    else
      Exit;
  end;
  if NoRev then
    NoRevMark := '-'
  else
    NoRevMark := '?';

  // the project of this command must not stay "open" for the next lines of /input
  OldProjectID := ProjectID;
  OldProjectName := ProjectName;
  try
    S := LineParamStr(Line, 2);
    ProjectID := StrToIntDef(S, -1);
    if ProjectID = -1 then
    begin
      ProjectID := 0;
      ProjectName := S;
    end
    else
      ProjectName := '';
    CheckOpenProject;

    // the log exists only if the server writes it (WriteVCSLog); no right to read the options (403): unknown
    LogState := 'unknown';
    GetServerOptions := TJVCSGetServerOptions.Create(nil);
    try
      try
        Connection.SendRequest(GetServerOptions);
        ShowLog(GetServerOptions);
        if GetServerOptions.WriteVCSLog then
          LogState := 'on'
        else
          LogState := 'off';
      except
        on E: EJVCSClientRequestError do
          if E.StatusCode = 403 then
            LogState := 'unknown'
          else
            raise;
      end;
    finally
      GetServerOptions.Free;
    end;

    FilterUserID := 0;
    if UserText <> '' then
    begin
      FilterUserID := -1;
      GetUsers := TJVCSGetUsers.Create(nil);
      try
        Connection.SendRequest(GetUsers);
        ShowLog(GetUsers);
        for I := 0 to GetUsers.OutputItemCount - 1 do
          if AnsiCompareText(UserText, string(GetUsers.OutputItems[I].UserName)) = 0 then
          begin
            FilterUserID := GetUsers.OutputItems[I].UserID;
            Break;
          end;
      finally
        GetUsers.Free;
      end;
      if FilterUserID = -1 then
        raise Exception.CreateFmt(SUserNotFound, [UserText]);
    end;

    // modules of the project (hidden ones too): log filter and full name to show
    GetModuleList := TJVCSGetProjectModuleList.Create(nil);
    try
      GetModuleList.ProjectID := ProjectID;
      GetModuleList.ExcludeHiddenModules := False;
      Connection.SendRequest(GetModuleList);
      ShowLog(GetModuleList);
      SetLength(ModIDs, GetModuleList.OutputItemCount);
      SetLength(ModNames, GetModuleList.OutputItemCount);
      for I := 0 to GetModuleList.OutputItemCount - 1 do
      begin
        MItem := GetModuleList.OutputItems[I];
        ModIDs[I] := MItem.ModuleID;
        S := string(MItem.ModuleName);
        if (Pos('\', S) = 0) and (string(MItem.ModulePath) <> '') then
          S := IncludeTrailingPathDelimiter(string(MItem.ModulePath)) + S;
        ModNames[I] := S;
      end;
    finally
      GetModuleList.Free;
    end;

    GetLogEntries := TJVCSGetLogEntries.Create(nil);
    try
      GetLogEntries.ProjectID := 0; // all: a shared module may get check-ins from another project
      GetLogEntries.ModuleID := 0;
      GetLogEntries.UserID := FilterUserID;
      if HasSince then
        GetLogEntries.StartDate := LocalDT2GMTDT(SinceLocal)
      else
        GetLogEntries.StartDate := 0;
      GetLogEntries.EndDate := 0;
      GetLogEntries.EntryType := 'i;'; // server format: one char and ';' per type
      Connection.SendRequest(GetLogEntries);
      ShowLog(GetLogEntries);
      SetLength(Rows, GetLogEntries.OutputItemCount);
      N := 0;
      for I := 0 to GetLogEntries.OutputItemCount - 1 do
      begin
        LItem := GetLogEntries.OutputItems[I];
        K := ModuleIndex(LItem.ModuleID);
        if K < 0 then
          Continue;
        Rows[N].LogID := LItem.LogID;
        Rows[N].ModuleID := LItem.ModuleID;
        Rows[N].ModIdx := K;
        Rows[N].RevisionID := 0;
        Rows[N].Version := -1;
        Rows[N].Revision := -1;
        Rows[N].Stamp := LItem.Timestamp; // GMT
        Rows[N].UserName := string(LItem.UserName);
        Rows[N].ViaProject := string(LItem.ProjectName);
        if Pos('Update (Put)', LItem.Description) = 1 then
          Rows[N].Kind := 'put'
        else
          Rows[N].Kind := 'ci';
        Rows[N].Comment := '';
        Rows[N].Linked := False;
        Inc(N);
      end;
      SetLength(Rows, N);
    finally
      GetLogEntries.Free;
    end;

    // the server sorts by date: max=n keeps the n most recent (the end of the list)
    First := 0;
    if (MaxCount > 0) and (Length(Rows) > MaxCount) then
      First := Length(Rows) - MaxCount;

    for I := First to High(Rows) do
    begin
      GetLogComment := TJVCSGetLogComment.Create(nil);
      try
        GetLogComment.LogID := Rows[I].LogID;
        Connection.SendRequest(GetLogComment);
        ShowLog(GetLogComment);
        // without a linked revision (logcomm) the server answers the literal word 'blank'
        Rows[I].Linked := GetLogComment.CheckinComment <> 'blank';
        if Rows[I].Linked then
          Rows[I].Comment := GetLogComment.CheckinComment;
      finally
        GetLogComment.Free;
      end;
    end;

    if not NoRev then
    begin
      SetLength(ModDone, Length(ModIDs));
      for I := 0 to High(ModDone) do
        ModDone[I] := False;
      for I := High(Rows) downto First do
      begin
        if ModDone[Rows[I].ModIdx] then
          Continue;
        ModDone[Rows[I].ModIdx] := True;
        // one entry per revision: user and comment come only with the first member of the family
        SetLength(Revs, 0);
        GetModuleHistory := TJVCSGetModuleHistory.Create(nil);
        try
          GetModuleHistory.ModuleID := Rows[I].ModuleID;
          Connection.SendRequest(GetModuleHistory);
          ShowLog(GetModuleHistory);
          for J := 0 to GetModuleHistory.OutputItemCount - 1 do
          begin
            HItem := GetModuleHistory.OutputItems[J];
            K := Length(Revs);
            if (K > 0) and (Revs[K - 1].RevisionID = HItem.RevisionID) then
              Continue;
            SetLength(Revs, K + 1);
            Revs[K].RevisionID := HItem.RevisionID;
            Revs[K].Version := HItem.Version;
            Revs[K].Revision := HItem.Revision;
            Revs[K].UserName := string(HItem.UserName);
            Revs[K].Comment := HItem.CheckinComment;
          end;
        finally
          GetModuleHistory.Free;
        end;
        // newest first (RevisionID comes from a generator, it grows with each check-in)
        for J := 1 to High(Revs) do
        begin
          Tmp := Revs[J];
          K := J - 1;
          while (K >= 0) and (Revs[K].RevisionID < Tmp.RevisionID) do
          begin
            Revs[K + 1] := Revs[K];
            Dec(K);
          end;
          Revs[K + 1] := Tmp;
        end;
        // from the newest check-in to the oldest: each one takes the next older revision of the
        // same user with the same comment (revisions without a log entry are skipped)
        RevPtr := 0;
        for J := High(Rows) downto First do
        begin
          if (Rows[J].ModIdx <> Rows[I].ModIdx) or not Rows[J].Linked then
            Continue;
          for K := RevPtr to High(Revs) do
            if (AnsiCompareText(Revs[K].UserName, Rows[J].UserName) = 0) and
              (Revs[K].Comment = Rows[J].Comment) then
            begin
              Rows[J].RevisionID := Revs[K].RevisionID;
              Rows[J].Version := Revs[K].Version;
              Rows[J].Revision := Revs[K].Revision;
              RevPtr := K + 1;
              Break;
            end;
        end;
      end;
    end;

    Writeln('Project: ', EscapeHistoryComment(ProjectName), ' (ID ', ProjectID, ')');
    if HasSince then
      Writeln('Since: ', FormatDateTime('yyyy-mm-dd hh:nn:ss', SinceLocal))
    else
      Writeln('Since: all');
    if UserText <> '' then
      Writeln('User: ', EscapeHistoryComment(UserText))
    else
      Writeln('User: all');
    Writeln('Server log: ', LogState);
    Writeln;
    Write(StrAlign('LogID', 8), ' ');
    Write(StrAlign('Checked in', 19), ' ');
    Write(StrAlign('User', 20), ' ');
    Write(StrAlign('Version', 7), ' ');
    Write(StrAlign('RevID', 8), ' ');
    Write(StrAlign('ModID', 8), ' ');
    Write(StrAlign('Op', 3), ' ');
    Writeln('Module | Via project | Comment');
    Write(StringOfChar('=', 8), ' ');
    Write(StringOfChar('=', 19), ' ');
    Write(StringOfChar('=', 20), ' ');
    Write(StringOfChar('=', 7), ' ');
    Write(StringOfChar('=', 8), ' ');
    Write(StringOfChar('=', 8), ' ');
    Write(StringOfChar('=', 3), ' ');
    Writeln(StringOfChar('=', 31));
    for I := First to High(Rows) do
    begin
      Write(StrAlign(IntToStr(Rows[I].LogID), 8), ' ');
      Write(StrAlign(FormatDateTime('yyyy-mm-dd hh:nn:ss', GMTDT2LocalDT(Rows[I].Stamp)), 19), ' ');
      Write(StrAlign(Rows[I].UserName, 20), ' ');
      if Rows[I].RevisionID > 0 then
      begin
        Write(StrAlign(Format('%d.%d', [Rows[I].Version, Rows[I].Revision]), 7), ' ');
        Write(StrAlign(IntToStr(Rows[I].RevisionID), 8), ' ');
      end
      else
      begin
        Write(StrAlign(NoRevMark, 7), ' ');
        Write(StrAlign(NoRevMark, 8), ' ');
      end;
      Write(StrAlign(IntToStr(Rows[I].ModuleID), 8), ' ');
      Write(StrAlign(Rows[I].Kind, 3), ' ');
      Writeln(EscapeHistoryComment(ModNames[Rows[I].ModIdx]), ' | ',
        EscapeHistoryComment(Rows[I].ViaProject), ' | ',
        EscapeHistoryComment(Rows[I].Comment));
    end;
    Writeln;
    Writeln(Length(Rows) - First, ' check-in(s) shown of ', Length(Rows));
    Result := True;
  finally
    ProjectID := OldProjectID;
    ProjectName := OldProjectName;
  end;
end;

// projectrevs: revision of each module of a project in one state, as the tabs of the standalone
// Synchronize/Restore (Syncronice.pas Reload_Project, Reload_Labeled, Reload_Version, Reload_Rollback):
//   latest   GET_LATEST_REVISIONS, label 0
//   label=   GET_LATEST_REVISIONS filtered by the label
//   version= GET_VERSION_REVISION: n -> revision -1 (newest revision of version n of each module);
//            n.m -> exactly n.m (the standalone tab always sends both)
//   date=    GET_ROLLBACK_REVISIONS, local time -> GMT (as Reload_Rollback). Per module the server returns
//            the newest revision (by revision ID) whose members ALL have blobs.origtime <= date: the file
//            date sent at check-in, not the check-in time (table revision has no date).
// One answer item per family member; name and path only with the first member. GET_VERSION_REVISION
// sorts by module NAME, not ID: modules with the same name in different folders can interleave and come
// twice. Rows are grouped by module ID over the whole answer, keeping the first revision seen of each
// module (the newest) and only its members. Project membership and hidden flag are the current ones.
function CmdProcProjectRevs(const Line: string; var ExtExitCode: Integer): Boolean;
type
  TPRevKind = (prkLatest, prkLabel, prkVersion, prkDate);
  TPRevRow = record
    ModuleID, RevisionID, Version, Revision: Integer;
    Stamp: TDateTime;
    Exts, Name, Path: string;
  end;
var
  Count, I, P, LabelID, WantVer, WantRev, Ignored: Integer;
  S, Sel, LabelName, StateText: string;
  Kind: TPRevKind;
  InclHidden: Boolean;
  RollbackLocal: TDateTime;
  Rows: array of TPRevRow;
  GetLatestRevisions: TJVCSGetLatestRevisions;
  GetVersionRevision: TJVCSGetVersionRevision;
  GetRollbackRevisions: TJVCSGetRollbackRevisions;
  LItem: TGetLatestRevisionsOutputItem;
  VItem: TGetVersionRevisionOutputItem;
  RItem: TGetRollbackRevisionsOutputItem;

  procedure AddMember(AModuleID, ARevisionID, AVersion, ARevision: Integer; AStamp: TDateTime;
    const AExt, AName, APath: string);
  var
    X, K: Integer;
  begin
    K := -1;
    for X := 0 to High(Rows) do
      if Rows[X].ModuleID = AModuleID then
      begin
        K := X;
        Break;
      end;
    if K < 0 then
    begin
      K := Length(Rows);
      SetLength(Rows, K + 1);
      Rows[K].ModuleID := AModuleID;
      Rows[K].RevisionID := ARevisionID;
      Rows[K].Version := AVersion;
      Rows[K].Revision := ARevision;
      Rows[K].Stamp := AStamp;
      Rows[K].Exts := AExt;
      Rows[K].Name := AName;
      Rows[K].Path := APath;
    end
    else
    if Rows[K].RevisionID <> ARevisionID then
      Inc(Ignored) // older revision of a module interleaved with another one of the same name
    else
    begin
      if Pos(',' + AnsiLowerCase(AExt) + ',', ',' + AnsiLowerCase(Rows[K].Exts) + ',') = 0 then
        Rows[K].Exts := Rows[K].Exts + ',' + AExt;
      if AStamp > Rows[K].Stamp then
        Rows[K].Stamp := AStamp;
      if (Rows[K].Name = '') and (AName <> '') then
      begin
        Rows[K].Name := AName;
        Rows[K].Path := APath;
      end;
    end;
  end;

begin
  Result := False;
  Count := LineParamCount(Line);
  if not (Count in [3, 4]) then
    Exit;
  InclHidden := False;
  if Count = 4 then
  begin
    if AnsiCompareText(LineParamStr(Line, 4), 'includehidden') <> 0 then
      Exit;
    InclHidden := True;
  end;
  Sel := LineParamStr(Line, 3);
  LabelID := 0;
  LabelName := '';
  WantVer := -1;
  WantRev := -1;
  RollbackLocal := 0;
  if AnsiCompareText(Sel, 'latest') = 0 then
    Kind := prkLatest
  else
  if Pos('label=', AnsiLowerCase(Sel)) = 1 then
  begin
    if Trim(Copy(Sel, 7, MaxInt)) = '' then
      Exit;
    Kind := prkLabel;
  end
  else
  if Pos('version=', AnsiLowerCase(Sel)) = 1 then
  begin
    Kind := prkVersion;
    S := Copy(Sel, 9, MaxInt);
    P := Pos('.', S);
    if P = 0 then
      WantVer := StrToIntDef(S, -1)
    else
    begin
      WantVer := StrToIntDef(Copy(S, 1, P - 1), -1);
      WantRev := StrToIntDef(Copy(S, P + 1, MaxInt), -1);
      if WantRev < 0 then
        WantVer := -1;
    end;
    if WantVer < 0 then
      raise Exception.CreateFmt('Invalid version in ''%s'' (use version=n or version=n.m)', [Sel]);
  end
  else
  if Pos('date=', AnsiLowerCase(Sel)) = 1 then
  begin
    Kind := prkDate;
    if not ParseProjectLogSince(Copy(Sel, 6, MaxInt), RollbackLocal) then
      raise Exception.CreateFmt('Invalid date in ''%s'' (use date=yyyy-mm-dd or date=yyyy-mm-ddThh:nn[:ss], local time)', [Sel]);
  end
  else
    Exit;

  S := LineParamStr(Line, 2);
  ProjectID := StrToIntDef(S, -1);
  if ProjectID = -1 then
    ProjectName := S
  else
    ProjectName := '';
  CheckOpenProject;
  if Kind = prkLabel then
    LabelID := ResolveLabel(Copy(Sel, 7, MaxInt), LabelName);

  SetLength(Rows, 0);
  Ignored := 0;
  case Kind of
    prkLatest, prkLabel:
      begin
        GetLatestRevisions := TJVCSGetLatestRevisions.Create(nil);
        try
          GetLatestRevisions.ProjectID := ProjectID;
          GetLatestRevisions.ExcludeHiddenModules := not InclHidden;
          GetLatestRevisions.LabelID := LabelID;
          Connection.SendRequest(GetLatestRevisions);
          ShowLog(GetLatestRevisions);
          for I := 0 to GetLatestRevisions.OutputItemCount - 1 do
          begin
            LItem := GetLatestRevisions.OutputItems[I];
            AddMember(LItem.ModuleID, LItem.RevisionID, LItem.Version, LItem.Revision, LItem.RevisionTimestamp,
              string(LItem.RevisionExtension), string(LItem.ModuleName), string(LItem.ModulePath));
          end;
        finally
          GetLatestRevisions.Free;
        end;
      end;
    prkVersion:
      begin
        GetVersionRevision := TJVCSGetVersionRevision.Create(nil);
        try
          GetVersionRevision.ProjectID := ProjectID;
          GetVersionRevision.ExcludeHiddenModules := not InclHidden;
          GetVersionRevision.Version := WantVer;
          GetVersionRevision.Revision := WantRev; // -1: newest revision of the version
          Connection.SendRequest(GetVersionRevision);
          ShowLog(GetVersionRevision);
          for I := 0 to GetVersionRevision.OutputItemCount - 1 do
          begin
            VItem := GetVersionRevision.OutputItems[I];
            AddMember(VItem.ModuleID, VItem.RevisionID, VItem.Version, VItem.Revision, VItem.RevisionTimestamp,
              string(VItem.RevisionExtension), string(VItem.ModuleName), string(VItem.ModulePath));
          end;
        finally
          GetVersionRevision.Free;
        end;
      end;
    prkDate:
      begin
        GetRollbackRevisions := TJVCSGetRollbackRevisions.Create(nil);
        try
          GetRollbackRevisions.ProjectID := ProjectID;
          GetRollbackRevisions.ExcludeHiddenModules := not InclHidden;
          GetRollbackRevisions.RollbackDate := LocalDT2GMTDT(RollbackLocal);
          Connection.SendRequest(GetRollbackRevisions);
          ShowLog(GetRollbackRevisions);
          for I := 0 to GetRollbackRevisions.OutputItemCount - 1 do
          begin
            RItem := GetRollbackRevisions.OutputItems[I];
            AddMember(RItem.ModuleID, RItem.RevisionID, RItem.Version, RItem.Revision, RItem.RevisionTimestamp,
              string(RItem.RevisionExtension), string(RItem.ModuleName), string(RItem.ModulePath));
          end;
        finally
          GetRollbackRevisions.Free;
        end;
      end;
  end;

  case Kind of
    prkLatest:
      StateText := 'latest';
    prkLabel:
      StateText := Format('label %s (ID %d)', [EscapeHistoryComment(LabelName), LabelID]);
    prkVersion:
      begin
        if WantRev < 0 then
          StateText := Format('version %d', [WantVer])
        else
          StateText := Format('version %d.%d', [WantVer, WantRev]);
      end;
  else
    StateText := 'date ' + FormatDateTime('yyyy-mm-dd hh:nn:ss', RollbackLocal);
  end;
  Writeln('Project: ', EscapeHistoryComment(ProjectName), ' (ID ', ProjectID, ')');
  Writeln('State: ', StateText);
  if InclHidden then
    Writeln('Hidden modules: included')
  else
    Writeln('Hidden modules: excluded');
  Writeln;
  Write(StrAlign('ID', 8), ' ');
  Write(StrAlign('Version', 7), ' ');
  Write(StrAlign('RevID', 8), ' ');
  Write(StrAlign('File date', 19), ' ');
  Write(StrAlign('Files', 30), ' ');
  Writeln('Path|Name');
  Write(StringOfChar('=', 8), ' ');
  Write(StringOfChar('=', 7), ' ');
  Write(StringOfChar('=', 8), ' ');
  Write(StringOfChar('=', 19), ' ');
  Write(StringOfChar('=', 30), ' ');
  Writeln(StringOfChar('=', 9));
  for I := 0 to High(Rows) do
  begin
    Write(StrAlign(IntToStr(Rows[I].ModuleID), 8), ' ');
    Write(StrAlign(Format('%d.%d', [Rows[I].Version, Rows[I].Revision]), 7), ' ');
    Write(StrAlign(IntToStr(Rows[I].RevisionID), 8), ' ');
    if Rows[I].Stamp > 0 then
      Write(StrAlign(FormatDateTime('yyyy-mm-dd hh:nn:ss', GMTDT2LocalDT(Rows[I].Stamp)), 19), ' ')
    else
      Write(StrAlign('', 19), ' ');
    Write(StrAlign(Rows[I].Exts, 30), ' ');
    // server text: escaped so that it never breaks the line (backslash as \\, line breaks as \n)
    Writeln(EscapeHistoryComment(Trim(Rows[I].Path) + '|' + Trim(Rows[I].Name)));
  end;
  Writeln;
  if Ignored > 0 then
    Writeln('Ignored: ', Ignored, ' answer row(s) of older revisions (modules with the same name)');
  Writeln(Length(Rows), ' module(s)');
  Result := True;
end;

// SEARCH_MODULES: one row per module x project. The server returns the name in
// lower case and only modules assigned to some project (join with pjmodule).
function CmdProcSearchModules(const Line: string; var ExtExitCode: Integer): Boolean;
var
  I: Integer;
  Mask: string;
  SearchModules: TJVCSSearchModules;
  Item: TSearchModulesOutputItem;
begin
  Result := False;
  if LineParamCount(Line) <> 2 then
    Exit;
  Mask := Trim(LineParamStr(Line, 2));
  if Mask = '' then
    Exit;
  if Length(Mask) > 255 then
    raise Exception.Create('Mask longer than 255 characters');
  SearchModules := TJVCSSearchModules.Create(nil);
  try
    SearchModules.MaskString := JVCSString255(AnsiString(Mask));
    Connection.SendRequest(SearchModules);
    ShowLog(SearchModules);
    Writeln('Mask: ', Mask);
    Writeln;
    Write(StrAlign('ID', 8), ' ');
    Write(StrAlign('Project', 50), ' ');
    Writeln('Path|Name');
    Write(StringOfChar('=', 8), ' ');
    Write(StringOfChar('=', 50), ' ');
    Writeln(StringOfChar('=', 9));
    for I := 0 to SearchModules.OutputItemCount - 1 do
    begin
      Item := SearchModules.OutputItems[I];
      Write(StrAlign(IntToStr(Item.ModuleID), 8), ' ');
      Write(StrAlign(string(Item.AssignedToProject), 50), ' ');
      // file names cannot contain '|' or control chars: printed as is
      Writeln(string(Item.Path), '|', string(Item.ModuleName));
    end;
    Writeln;
    Writeln(SearchModules.OutputItemCount, ' item(s)');
    Result := True;
  finally
    SearchModules.Free;
  end;
end;

// Comment search over GET_MODULE_HISTORY of each module of a project (the 2.5
// server has no project-scoped comment search; SEARCH_REVISIONS_BY_COMMENT is
// optional (NEWOBJECTS), case-sensitive and returns no date/user).
// The project of this command does not stay "open" for the next lines of /input
// (as projectlog). Hidden modules included. The time is the one history shows.
function CmdProcSearchComments(const Line: string; var ExtExitCode: Integer): Boolean;
const
  DefaultMaxModules = 300;
var
  Count, I, J, MaxModules, Scanned, Hits, ModuleHits, LastRevID, OldProjectID: Integer;
  S, SearchText, Needle, OldProjectName: string;
  GetProjectModuleList: TJVCSGetProjectModuleList;
  GetModuleHistory: TJVCSGetModuleHistory;
  Item: TGetModuleHistoryOutputItem;
  ModItem: TGetProjectModuleListOutputItem;

  procedure CheckRevision(const Row: TGetModuleHistoryOutputItem);
  var
    Hit, Shown: string;
  begin
    Hit := '';
    if (Row.CheckinComment <> '') and (AnsiPos(Needle, AnsiUpperCase(Row.CheckinComment)) > 0) then
      Hit := 'I';
    if (Row.CheckoutComment <> '') and (AnsiPos(Needle, AnsiUpperCase(Row.CheckoutComment)) > 0) then
      Hit := Hit + 'O';
    if Hit = '' then
      Exit;
    if ModuleHits = 0 then
      Writeln('Module: ', ModItem.ModuleID, ' ', string(ModItem.ModulePath), string(ModItem.ModuleName));
    Inc(ModuleHits);
    Inc(Hits);
    if Hit[1] = 'I' then
      Shown := Row.CheckinComment
    else
      Shown := Row.CheckoutComment;
    Write(StrAlign(IntToStr(ModItem.ModuleID), 8), ' ');
    Write(StrAlign(Format('%d.%d', [Row.Version, Row.Revision]), 7), ' ');
    Write(StrAlign(IntToStr(Row.RevisionID), 8), ' ');
    Write(StrAlign(FormatDateTime('yyyy-mm-dd hh:nn:ss', GMTDT2LocalDT(Row.Timestamp)), 19), ' ');
    Write(StrAlign(string(Row.UserName), 20), ' ');
    Write(StrAlign(Hit, 3), ' ');
    Writeln(EscapeHistoryComment(Shown));
  end;

begin
  Result := False;
  Count := LineParamCount(Line);
  if not (Count in [3, 4]) then
    Exit;
  SearchText := Trim(LineParamStr(Line, 2));
  if Length(SearchText) < 2 then
    Exit;
  MaxModules := DefaultMaxModules;
  if Count = 4 then
  begin
    S := LineParamStr(Line, 4);
    if AnsiCompareText(Copy(S, 1, 11), 'maxmodules=') <> 0 then
      Exit;
    MaxModules := StrToIntDef(Copy(S, 12, MaxInt), -1);
    if MaxModules < 1 then
      Exit;
  end;
  OldProjectID := ProjectID;
  OldProjectName := ProjectName;
  try
    // an ID clears a stale name (as listproject/openproject)
    S := LineParamStr(Line, 3);
    ProjectID := StrToIntDef(S, -1);
    if ProjectID = -1 then
    begin
      ProjectID := 0;
      ProjectName := S;
    end
    else
      ProjectName := '';
    CheckOpenProject;
    Needle := AnsiUpperCase(SearchText);
    GetProjectModuleList := TJVCSGetProjectModuleList.Create(nil);
    try
      GetProjectModuleList.ProjectID := ProjectID;
      GetProjectModuleList.ExcludeHiddenModules := False;
      Connection.SendRequest(GetProjectModuleList);
      ShowLog(GetProjectModuleList);
      Writeln('Project: ', ProjectName, ' (ID ', ProjectID, ')');
      Writeln('Text: ', EscapeHistoryComment(SearchText));
      Writeln;
      Write(StrAlign('ModID', 8), ' ');
      Write(StrAlign('Version', 7), ' ');
      Write(StrAlign('RevID', 8), ' ');
      Write(StrAlign('Checked in', 19), ' ');
      Write(StrAlign('User', 20), ' ');
      Write(StrAlign('Hit', 3), ' ');
      Writeln('Comment');
      Write(StringOfChar('=', 8), ' ');
      Write(StringOfChar('=', 7), ' ');
      Write(StringOfChar('=', 8), ' ');
      Write(StringOfChar('=', 19), ' ');
      Write(StringOfChar('=', 20), ' ');
      Write(StringOfChar('=', 3), ' ');
      Writeln(StringOfChar('=', 7));
      Hits := 0;
      Scanned := 0;
      for I := 0 to GetProjectModuleList.OutputItemCount - 1 do
      begin
        if Scanned >= MaxModules then
          Break;
        ModItem := GetProjectModuleList.OutputItems[I];
        Inc(Scanned);
        ModuleHits := 0;
        GetModuleHistory := TJVCSGetModuleHistory.Create(nil);
        try
          GetModuleHistory.ModuleID := ModItem.ModuleID;
          Connection.SendRequest(GetModuleHistory);
          ShowLog(GetModuleHistory);
          // one item per family member; user and comments only on the first
          // member of each revision (as History.pas / CmdProcHistory read)
          LastRevID := -1;
          for J := 0 to GetModuleHistory.OutputItemCount - 1 do
          begin
            Item := GetModuleHistory.OutputItems[J];
            if Item.RevisionID <> LastRevID then
            begin
              LastRevID := Item.RevisionID;
              CheckRevision(Item);
            end;
          end;
        finally
          GetModuleHistory.Free;
        end;
      end;
      Writeln;
      Writeln(Format('Scanned %d of %d module(s), %d revision(s) found',
        [Scanned, GetProjectModuleList.OutputItemCount, Hits]));
      Result := True;
    finally
      GetProjectModuleList.Free;
    end;
  finally
    ProjectID := OldProjectID;
    ProjectName := OldProjectName;
  end;
end;

// ----- ToDo and milestones (listtodo, addtodo, donetodo, listmilestones) -----

// Server text printed in a fixed column: control characters -> space (one line per row,
// so no value can start a fake 'jvcs> ' or '[Exception]' line).
function internOneLine(const S: string): string;
var
  I: Integer;
begin
  Result := S;
  for I := 1 to Length(Result) do
    if (Result[I] < ' ') or (Result[I] = #127) then
      Result[I] := ' ';
end;

// 'key=value' (key case-insensitive). True and Value when S starts with Key + '='.
function internKeyValue(const S, Key: string; var Value: string): Boolean;
begin
  Result := SameText(Copy(S, 1, Length(Key) + 1), Key + '=');
  if Result then
    Value := Copy(S, Length(Key) + 2, MaxInt);
end;

// yyyy-mm-dd (local date, 00:00) -> TDateTime. False if invalid.
function internParseDate(const S: string; var ADate: TDateTime): Boolean;
var
  Y, M, D: Integer;
begin
  Result := (Length(S) = 10) and (S[5] = '-') and (S[8] = '-') and
    TryStrToInt(Copy(S, 1, 4), Y) and TryStrToInt(Copy(S, 6, 2), M) and
    TryStrToInt(Copy(S, 9, 2), D) and (Y >= 1900) and (Y <= 9999) and
    (M >= 1) and (M <= 12) and (D >= 1) and (D <= 31) and
    TryEncodeDate(Y, M, D, ADate);
end;

// GMT TDateTime from the server -> 'yyyy-mm-dd hh:nn:ss' local; '' when not set (0).
function internFmtGMTDate(DT: TDateTime): string;
begin
  if DT > 1 then
    Result := FormatDateTime('yyyy-mm-dd hh:nn:ss', GMTDT2LocalDT(DT))
  else
    Result := '';
end;

// Login -> user ID ('me' = connected user). Exact match first; a case-insensitive
// match only when it is unique. Raises SUserNotFound / ambiguous.
function internFindUserID(const AName: string; AllowDeleted: Boolean): Integer;
var
  GetUsers: TJVCSGetUsers;
  I, CIMatches, CIID: Integer;
begin
  if SameText(AName, 'me') then
  begin
    Result := Connection.UserID;
    Exit;
  end;
  Result := -1;
  CIMatches := 0;
  CIID := -1;
  GetUsers := TJVCSGetUsers.Create(nil);
  try
    Connection.SendRequest(GetUsers);
    ShowLog(GetUsers);
    for I := 0 to GetUsers.OutputItemCount - 1 do
      if AllowDeleted or not GetUsers.OutputItems[I].UserDeleted then
      begin
        if AnsiCompareStr(AName, string(GetUsers.OutputItems[I].UserName)) = 0 then
        begin
          Result := GetUsers.OutputItems[I].UserID;
          Break;
        end;
        if AnsiCompareText(AName, string(GetUsers.OutputItems[I].UserName)) = 0 then
        begin
          Inc(CIMatches);
          CIID := GetUsers.OutputItems[I].UserID;
        end;
      end;
  finally
    GetUsers.Free;
  end;
  if Result = -1 then
  begin
    if CIMatches > 1 then
      raise Exception.CreateFmt('User ''%s'' is ambiguous (differs only in case); use the exact login', [AName]);
    if CIMatches = 1 then
      Result := CIID;
  end;
  if Result = -1 then
    raise Exception.CreateFmt(SUserNotFound, [AName]);
end;

// <project_name> | <project_id>: opens it like openproject (globals ProjectID/ProjectName).
procedure internOpenProjectArg(const S: string);
var
  N: Integer;
begin
  N := StrToIntDef(S, -1);
  if N > 0 then
  begin
    ProjectID := N;
    ProjectName := '';
  end
  else
  begin
    ProjectID := 0;
    ProjectName := S;
  end;
  CheckOpenProject;
end;

procedure internWriteTodoHeader;
begin
  Write(StrAlign('ID', 8), ' ');
  Write(StrAlign('Pri', 3), ' ');
  Write(StrAlign('Stat', 4), ' ');
  Write(StrAlign('Changed', 19), ' ');
  Write(StrAlign('Target', 19), ' ');
  Write(StrAlign('Done', 19), ' ');
  Write(StrAlign('Responsible', 20), ' ');
  Write(StrAlign('Project', 50), ' ');
  Write(StrAlign('Category', 50), ' ');
  Writeln('Description');
  Write(StringOfChar('=', 8), ' ');
  Write(StringOfChar('=', 3), ' ');
  Write(StringOfChar('=', 4), ' ');
  Write(StringOfChar('=', 19), ' ');
  Write(StringOfChar('=', 19), ' ');
  Write(StringOfChar('=', 19), ' ');
  Write(StringOfChar('=', 20), ' ');
  Write(StringOfChar('=', 50), ' ');
  Write(StringOfChar('=', 50), ' ');
  Writeln(StringOfChar('=', 11));
end;

// ID(8)@0 Pri(3)@9 Stat(4)@13 Changed(19)@18 Target(19)@38 Done(19)@58 Responsible(20)@78
// Project(50)@99 Category(50)@150 Description@201
procedure internWriteTodoRow(const Row: TGetTodoEntriesOutputItem);
const
  StatText: array [Boolean] of string = ('open', 'done');
begin
  Write(StrAlign(IntToStr(Row.TodoID), 8), ' ');
  Write(StrAlign(IntToStr(Row.Priority), 3), ' ');
  Write(StrAlign(StatText[Row.DoneDate > 1], 4), ' ');
  Write(StrAlign(internFmtGMTDate(Row.Timestamp), 19), ' ');
  Write(StrAlign(internFmtGMTDate(Row.TargetDate), 19), ' ');
  Write(StrAlign(internFmtGMTDate(Row.DoneDate), 19), ' ');
  Write(StrAlign(internOneLine(string(Row.UserName)), 20), ' ');
  Write(StrAlign(internOneLine(string(Row.ProjectName)), 50), ' ');
  Write(StrAlign(internOneLine(string(Row.Category)), 50), ' ');
  Writeln(EscapeHistoryComment(Row.Description));
end;

// One ToDo item (all users, all projects, done or not). False if not found
// (items of deleted projects never come: the server joins projects.deleted = '0').
function internFindTodo(ATodoID: Integer; var ARow: TGetTodoEntriesOutputItem): Boolean;
var
  GetTodoEntries: TJVCSGetTodoEntries;
  I: Integer;
begin
  Result := False;
  GetTodoEntries := TJVCSGetTodoEntries.Create(nil);
  try
    GetTodoEntries.UserID := 0;
    GetTodoEntries.ProjectID := 0;
    GetTodoEntries.Category := '';
    GetTodoEntries.Priority := 0;
    GetTodoEntries.NotDoneOnly := False;
    GetTodoEntries.TargetDate := 0;
    Connection.SendRequest(GetTodoEntries);
    ShowLog(GetTodoEntries);
    for I := 0 to GetTodoEntries.OutputItemCount - 1 do
      if GetTodoEntries.OutputItems[I].TodoID = ATodoID then
      begin
        ARow := GetTodoEntries.OutputItems[I];
        Result := True;
        Break;
      end;
  finally
    GetTodoEntries.Free;
  end;
end;

function CmdProcListTodo(const Line: string; var ExtExitCode: Integer): Boolean;
var
  Count, I, FilterProjectID, FilterUserID, FilterPriority: Integer;
  S, V, FilterCategory: string;
  IncludeDone: Boolean;
  DueDate: TDateTime;
  GetTodoEntries: TJVCSGetTodoEntries;
begin
  Result := False;
  Count := LineParamCount(Line);
  FilterProjectID := -1; // not given
  FilterUserID := 0;
  FilterPriority := 0;
  FilterCategory := '';
  IncludeDone := False;
  DueDate := 0;
  for I := 2 to Count do
  begin
    S := LineParamStr(Line, I);
    if SameText(S, 'includedone') then
      IncludeDone := True
    else
    if internKeyValue(S, 'project', V) then
    begin
      if SameText(V, 'all') then
        FilterProjectID := 0
      else
      begin
        internOpenProjectArg(V);
        FilterProjectID := ProjectID;
      end;
    end
    else
    if internKeyValue(S, 'user', V) then
    begin
      if SameText(V, 'all') then
        FilterUserID := 0
      else
        FilterUserID := internFindUserID(V, True);
    end
    else
    if internKeyValue(S, 'category', V) then
      FilterCategory := V
    else
    if internKeyValue(S, 'priority', V) then
    begin
      FilterPriority := StrToIntDef(V, -1);
      if (FilterPriority < 1) or (FilterPriority > 9) then
        Exit;
    end
    else
    if internKeyValue(S, 'due', V) then
    begin
      if not internParseDate(V, DueDate) then
        Exit;
    end
    else
      Exit;
  end;
  if Length(FilterCategory) > 50 then
    raise Exception.Create('Category too long (max. 50 characters)');
  if FilterProjectID = -1 then
  begin
    if (ProjectID <> 0) or (ProjectName <> '') then
    begin
      CheckOpenProject;
      FilterProjectID := ProjectID;
    end
    else
      FilterProjectID := 0;
  end;
  GetTodoEntries := TJVCSGetTodoEntries.Create(nil);
  try
    GetTodoEntries.UserID := FilterUserID;
    GetTodoEntries.ProjectID := FilterProjectID;
    GetTodoEntries.Category := JVCSString50(AnsiString(FilterCategory));
    GetTodoEntries.Priority := FilterPriority;
    GetTodoEntries.NotDoneOnly := not IncludeDone;
    // server: targetdate > 0 and targetdate < TargetDate (GMT) -> up to the end of that local day
    if DueDate > 0 then
      GetTodoEntries.TargetDate := LocalDT2GMTDT(DueDate + 1)
    else
      GetTodoEntries.TargetDate := 0;
    Connection.SendRequest(GetTodoEntries);
    ShowLog(GetTodoEntries);
    if FilterProjectID > 0 then
      Writeln('Project: ', internOneLine(ProjectName), ' (ID ', ProjectID, ')')
    else
      Writeln('Project: all');
    Writeln;
    internWriteTodoHeader;
    for I := 0 to GetTodoEntries.OutputItemCount - 1 do
      internWriteTodoRow(GetTodoEntries.OutputItems[I]);
    Writeln;
    Writeln(GetTodoEntries.OutputItemCount, ' item(s)');
    Result := True;
  finally
    GetTodoEntries.Free;
  end;
end;

function CmdProcAddTodo(const Line: string; var ExtExitCode: Integer): Boolean;
var
  Count, I, RespID, Priority, NewID: Integer;
  S, V, Desc, Category: string;
  DueDate: TDateTime;
  NewRow: TGetTodoEntriesOutputItem;
  AddUpdateTodo: TJVCSAddUpdateTodoEntries;
  GetTodoEntries: TJVCSGetTodoEntries;
begin
  Result := False;
  Count := LineParamCount(Line);
  if Count < 3 then
    Exit;
  Desc := Trim(LineParamStr(Line, 3));
  RespID := -1;
  Priority := 3;
  Category := '';
  DueDate := 0;
  for I := 4 to Count do
  begin
    S := LineParamStr(Line, I);
    if internKeyValue(S, 'priority', V) then
    begin
      Priority := StrToIntDef(V, -1);
      if (Priority < 1) or (Priority > 9) then
        Exit;
    end
    else
    if internKeyValue(S, 'category', V) then
      Category := Trim(V)
    else
    if internKeyValue(S, 'user', V) then
      RespID := internFindUserID(V, False)
    else
    if internKeyValue(S, 'due', V) then
    begin
      if not internParseDate(V, DueDate) then
        Exit;
    end
    else
      Exit;
  end;
  if Desc = '' then
    Exit;
  if Length(Desc) > 2000 then
    raise Exception.Create('Description too long (max. 2000 characters)');
  if Length(Category) > 50 then
    raise Exception.Create('Category too long (max. 50 characters)');
  if RespID = -1 then
    RespID := Connection.UserID;
  internOpenProjectArg(LineParamStr(Line, 2));
  if DueDate > 0 then
    DueDate := LocalDT2GMTDT(DueDate); // stored in GMT, like the standalone (ToDo.pas SaveChanges)
  AddUpdateTodo := TJVCSAddUpdateTodoEntries.Create(nil);
  try
    AddUpdateTodo.AddInputItem(0, Connection.UserID, ProjectID, RespID, Priority, '',
      Category, Desc, DueDate, 0);
    Connection.SendRequest(AddUpdateTodo);
    ShowLog(AddUpdateTodo);
  finally
    AddUpdateTodo.Free;
  end;
  // the server does not return the new ID: read it back (highest ID with this text)
  NewID := 0;
  GetTodoEntries := TJVCSGetTodoEntries.Create(nil);
  try
    GetTodoEntries.UserID := RespID;
    GetTodoEntries.ProjectID := ProjectID;
    GetTodoEntries.Category := JVCSString50(AnsiString(Category));
    GetTodoEntries.Priority := Priority;
    GetTodoEntries.NotDoneOnly := True;
    GetTodoEntries.TargetDate := 0;
    Connection.SendRequest(GetTodoEntries);
    ShowLog(GetTodoEntries);
    for I := 0 to GetTodoEntries.OutputItemCount - 1 do
      if (Trim(GetTodoEntries.OutputItems[I].Description) = Desc) and
        (GetTodoEntries.OutputItems[I].TodoID > NewID) then
      begin
        NewID := GetTodoEntries.OutputItems[I].TodoID;
        NewRow := GetTodoEntries.OutputItems[I];
      end;
  finally
    GetTodoEntries.Free;
  end;
  if NewID > 0 then
  begin
    Writeln('ToDo created: ', NewID, ' in project ', internOneLine(ProjectName), ' (ID ', ProjectID, ')');
    Writeln;
    internWriteTodoHeader;
    internWriteTodoRow(NewRow);
  end
  else
    Writeln('ToDo created, ID not confirmed (project ', internOneLine(ProjectName), ', ID ', ProjectID, ')');
  Writeln;
  Result := True;
end;

function CmdProcDoneTodo(const Line: string; var ExtExitCode: Integer): Boolean;
var
  Count, TodoID, RespID: Integer;
  Reopen: Boolean;
  DoneDT: TDateTime;
  Item: TGetTodoEntriesOutputItem;
  AddUpdateTodo: TJVCSAddUpdateTodoEntries;
begin
  Result := False;
  Count := LineParamCount(Line);
  if not (Count in [2, 3]) then
    Exit;
  TodoID := StrToIntDef(LineParamStr(Line, 2), 0);
  if TodoID <= 0 then
    Exit;
  Reopen := False;
  if Count = 3 then
  begin
    if not SameText(LineParamStr(Line, 3), 'reopen') then
      Exit;
    Reopen := True;
  end;
  if not internFindTodo(TodoID, Item) then
    raise Exception.CreateFmt('ToDo %d not found', [TodoID]);
  if (Item.DoneDate > 1) <> Reopen then
  begin
    if Reopen then
      Writeln('ToDo already open: ', TodoID)
    else
      Writeln('ToDo already done: ', TodoID);
    Writeln;
    internWriteTodoHeader;
    internWriteTodoRow(Item);
    Writeln;
    Result := True;
    Exit;
  end;
  // the update rewrites every field: never write back an invalid priority
  // (NULL comes as -1; the standalone would then fail saving this item)
  if (Item.Priority < 1) or (Item.Priority > 9) then
    raise Exception.CreateFmt('ToDo %d has an invalid priority (%d); fix it in the standalone ToDo list', [TodoID, Item.Priority]);
  // send back what was read (IDs from the names); opening the project also
  // selects the transaction whose rights the server checks
  ProjectID := 0;
  ProjectName := string(Item.ProjectName);
  CheckOpenProject;
  RespID := internFindUserID(string(Item.UserName), True);
  if Reopen then
    DoneDT := 0
  else
    DoneDT := LocalDT2GMTDT(Now);
  AddUpdateTodo := TJVCSAddUpdateTodoEntries.Create(nil);
  try
    // UserID = responsible, as the standalone sends (ToDo.pas SaveChanges)
    AddUpdateTodo.AddInputItem(TodoID, RespID, ProjectID, RespID, Item.Priority, '',
      string(Item.Category), Item.Description, Item.TargetDate, DoneDT);
    Connection.SendRequest(AddUpdateTodo);
    ShowLog(AddUpdateTodo);
  finally
    AddUpdateTodo.Free;
  end;
  // an UPDATE of a vanished ID still answers 200: always confirm by reading again
  if not internFindTodo(TodoID, Item) then
    raise Exception.CreateFmt('ToDo %d not found after update', [TodoID]);
  if (Item.DoneDate > 1) = Reopen then
    raise Exception.CreateFmt('ToDo %d was not updated by the server', [TodoID]);
  if Reopen then
    Writeln('ToDo reopened: ', TodoID)
  else
    Writeln('ToDo done: ', TodoID);
  Writeln;
  internWriteTodoHeader;
  internWriteTodoRow(Item);
  Writeln;
  Result := True;
end;

function CmdProcListMilestones(const Line: string; var ExtExitCode: Integer): Boolean;
var
  Count, I, FilterProjectID: Integer;
  S: string;
  GetMilestones: TJVCSGetMilestones;
  GetProjectMilestones: TJVCSGetProjectMilestones;
begin
  Result := False;
  Count := LineParamCount(Line);
  if not (Count in [1, 2]) then
    Exit;
  FilterProjectID := 0;
  if Count = 2 then
  begin
    S := LineParamStr(Line, 2);
    if not SameText(S, 'all') then
    begin
      internOpenProjectArg(S);
      FilterProjectID := ProjectID;
    end;
  end
  else
  if (ProjectID <> 0) or (ProjectName <> '') then
  begin
    CheckOpenProject;
    FilterProjectID := ProjectID;
  end;
  GetMilestones := TJVCSGetMilestones.Create(nil);
  GetProjectMilestones := TJVCSGetProjectMilestones.Create(nil);
  try
    Connection.SendRequest(GetMilestones);
    ShowLog(GetMilestones);
    GetProjectMilestones.ProjectID := FilterProjectID;
    Connection.SendRequest(GetProjectMilestones);
    ShowLog(GetProjectMilestones);
    if FilterProjectID > 0 then
      Writeln('Project: ', internOneLine(ProjectName), ' (ID ', ProjectID, ')')
    else
      Writeln('Project: all');
    Writeln;
    // ID(8)@0 Order(5)@9 Name(50)@15 Description@66
    Writeln('Defined milestones:');
    Write(StrAlign('ID', 8), ' ');
    Write(StrAlign('Order', 5), ' ');
    Write(StrAlign('Name', 50), ' ');
    Writeln('Description');
    Write(StringOfChar('=', 8), ' ');
    Write(StringOfChar('=', 5), ' ');
    Write(StringOfChar('=', 50), ' ');
    Writeln(StringOfChar('=', 11));
    for I := 0 to GetMilestones.OutputItemCount - 1 do
      with GetMilestones.OutputItems[I] do
      begin
        Write(StrAlign(IntToStr(MilestoneID), 8), ' ');
        Write(StrAlign(IntToStr(Milestone), 5), ' ');
        Write(StrAlign(internOneLine(string(MilestoneName)), 50), ' ');
        Writeln(EscapeHistoryComment(Description));
      end;
    Writeln;
    // Project(8)@0 MstoneID(8)@9 Order(5)@18 Reached(19)@24 Confirmed by(20)@44 Name(50)@65 Description@116
    Writeln('Reached milestones:');
    Write(StrAlign('Project', 8), ' ');
    Write(StrAlign('MstoneID', 8), ' ');
    Write(StrAlign('Order', 5), ' ');
    Write(StrAlign('Reached', 19), ' ');
    Write(StrAlign('Confirmed by', 20), ' ');
    Write(StrAlign('Name', 50), ' ');
    Writeln('Description');
    Write(StringOfChar('=', 8), ' ');
    Write(StringOfChar('=', 8), ' ');
    Write(StringOfChar('=', 5), ' ');
    Write(StringOfChar('=', 19), ' ');
    Write(StringOfChar('=', 20), ' ');
    Write(StringOfChar('=', 50), ' ');
    Writeln(StringOfChar('=', 11));
    // inside the 'with', ProjectID is the record field (it wins over the global), as intended
    for I := 0 to GetProjectMilestones.OutputItemCount - 1 do
      with GetProjectMilestones.OutputItems[I] do
      begin
        Write(StrAlign(IntToStr(ProjectID), 8), ' ');
        Write(StrAlign(IntToStr(MilestoneID), 8), ' ');
        Write(StrAlign(IntToStr(Milestone), 5), ' ');
        Write(StrAlign(internFmtGMTDate(ReachedTime), 19), ' ');
        Write(StrAlign(internOneLine(string(ConfirmedBy)), 20), ' ');
        Write(StrAlign(internOneLine(string(MilestoneName)), 50), ' ');
        Writeln(EscapeHistoryComment(Description));
      end;
    Writeln;
    Writeln(GetMilestones.OutputItemCount, ' milestone(s), ', GetProjectMilestones.OutputItemCount, ' reached');
    Result := True;
  finally
    GetProjectMilestones.Free;
    GetMilestones.Free;
  end;
end;

//=== Bugs (console 2026) =====================================================

type
  TBugEdit = record
    HasName, HasSeverity, HasStatus, HasKeywords, HasReportedBy,
    HasDescription, HasWorkaround: Boolean;
    Name, Keywords, ReportedBy, Description, Workaround: string;
    Severity, Status: Integer;
  end;

const
  BugNameMax = 250;
  BugKeywordsMax = 250;
  BugTextMax = 2000;
  BugTextFileMaxBytes = 16384;
  BugOptionKeys: array [0..8] of string = ('name', 'severity', 'status', 'keywords', 'reportedby',
    'description', 'descriptionfile', 'workaround', 'workaroundfile');

function internIsBugOptionKey(const S: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := Low(BugOptionKeys) to High(BugOptionKeys) do
    if SameText(S, BugOptionKeys[I]) then
    begin
      Result := True;
      Break;
    end;
end;

function internBugCode(const Value, What: string): Integer;
begin
  Result := StrToIntDef(Trim(Value), -1);
  if (Result < 0) or (Result > 4) then
    raise Exception.CreateFmt('Invalid %s ''%s'' (use 0..4)', [What, Value]);
end;

// Texts compared after a round trip through the server (line breaks and trailing blanks ignored).
function internSameBugText(const A, B: string): Boolean;
begin
  Result := TrimRight(AdjustLineBreaks(A, tlbsCRLF)) = TrimRight(AdjustLineBreaks(B, tlbsCRLF));
end;

// Text for description/workaround from a file in code page 1252 (texts with quotes or line
// breaks cannot go on a command line). No BOM, no control characters except TAB/CR/LF.
function internReadBugTextFile(const FileName: string): string;
var
  FullName: string;
  FS: TFileStream;
  Bytes: TBytes;
  Enc: TEncoding;
  I: Integer;
begin
  FullName := ExpandFileName(FileName);
  if not FileExists(FullName) then
    raise Exception.CreateFmt('Text file not found: %s', [FullName]);
  FS := TFileStream.Create(FullName, fmOpenRead or fmShareDenyWrite);
  try
    if FS.Size > BugTextFileMaxBytes then
      raise Exception.CreateFmt('Text file too big (max. %d bytes): %s', [BugTextFileMaxBytes, FullName]);
    SetLength(Bytes, FS.Size);
    if FS.Size > 0 then
      FS.ReadBuffer(Bytes[0], FS.Size);
  finally
    FS.Free;
  end;
  if (Length(Bytes) >= 3) and (Bytes[0] = $EF) and (Bytes[1] = $BB) and (Bytes[2] = $BF) then
    raise Exception.CreateFmt('Text file must be code page 1252, not UTF-8: %s', [FullName]);
  Enc := TEncoding.GetEncoding(1252);
  try
    Result := Enc.GetString(Bytes);
  finally
    Enc.Free;
  end;
  // C0 controls (except TAB/CR/LF), DEL and C1 (bytes undefined in code page 1252 decode to U+0081..U+009D).
  // Compared by Ord: with HIGHCHARUNICODE off, the literal #$9F would be the ANSI char (U+0178).
  for I := 1 to Length(Result) do
    if ((Result[I] < ' ') and not CharInSet(Result[I], [#9, #10, #13])) or
      ((Ord(Result[I]) >= $7F) and (Ord(Result[I]) <= $9F)) then
      raise Exception.CreateFmt('Text file with control character #%d: %s', [Ord(Result[I]), FullName]);
  Result := AdjustLineBreaks(Result, tlbsCRLF);
  while (Result <> '') and CharInSet(Result[Length(Result)], [#10, #13]) do
    SetLength(Result, Length(Result) - 1);
end;

procedure internParseBugOptions(const Line: string; FirstIndex: Integer; var E: TBugEdit);
var
  I, P: Integer;
  S, Key, Value: string;
  procedure CheckTwice(AlreadySet: Boolean);
  begin
    if AlreadySet then
      raise Exception.CreateFmt('Option ''%s'' given twice', [Key]);
  end;
begin
  for I := FirstIndex to LineParamCount(Line) do
  begin
    S := LineParamStr(Line, I);
    P := Pos('=', S);
    if P < 2 then
      raise Exception.CreateFmt('Invalid option ''%s'' (use key=value)', [S]);
    Key := LowerCase(Copy(S, 1, P - 1));
    Value := Copy(S, P + 1, MaxInt);
    if Key = 'name' then
    begin
      CheckTwice(E.HasName);
      E.HasName := True;
      E.Name := Trim(Value);
    end
    else
    if Key = 'severity' then
    begin
      CheckTwice(E.HasSeverity);
      E.HasSeverity := True;
      E.Severity := internBugCode(Value, 'severity');
    end
    else
    if Key = 'status' then
    begin
      CheckTwice(E.HasStatus);
      E.HasStatus := True;
      E.Status := internBugCode(Value, 'status');
    end
    else
    if Key = 'keywords' then
    begin
      CheckTwice(E.HasKeywords);
      E.HasKeywords := True;
      E.Keywords := Trim(Value);
    end
    else
    if Key = 'reportedby' then
    begin
      CheckTwice(E.HasReportedBy);
      E.HasReportedBy := True;
      E.ReportedBy := Trim(Value);
    end
    else
    if (Key = 'description') or (Key = 'descriptionfile') then
    begin
      CheckTwice(E.HasDescription);
      E.HasDescription := True;
      if Key = 'description' then
        E.Description := Value
      else
        E.Description := internReadBugTextFile(Value);
    end
    else
    if (Key = 'workaround') or (Key = 'workaroundfile') then
    begin
      CheckTwice(E.HasWorkaround);
      E.HasWorkaround := True;
      if Key = 'workaround' then
        E.Workaround := Value
      else
        E.Workaround := internReadBugTextFile(Value);
    end
    else
      raise Exception.CreateFmt('Unknown option ''%s''', [Key]);
  end;
end;

// Limits of the server columns (SrvOBJBugTrack.pas: bug 250, keywords 250, texts 2000).
// BugName/Keywords are string[250] in JVCSClientObj and would be cut silently.
procedure internCheckBugTexts(const AName, AKeywords, AReportedBy, ADescription, AWorkaround: string);
begin
  if AName = '' then
    raise Exception.Create('Bug name is empty');
  if Length(AName) > BugNameMax then
    raise Exception.CreateFmt('Bug name too long (max. %d characters)', [BugNameMax]);
  if Length(AKeywords) > BugKeywordsMax then
    raise Exception.CreateFmt('Keywords too long (max. %d characters)', [BugKeywordsMax]);
  if Length(AReportedBy) > BugTextMax then
    raise Exception.CreateFmt('Reported by too long (max. %d characters)', [BugTextMax]);
  if Length(ADescription) > BugTextMax then
    raise Exception.CreateFmt('Description too long (max. %d characters)', [BugTextMax]);
  if Length(AWorkaround) > BugTextMax then
    raise Exception.CreateFmt('Workaround too long (max. %d characters)', [BugTextMax]);
end;

// Module by name or ID without leaving the globals set (as CmdProcHistory).
function internResolveBugModule(const S: string; out AName: string): Integer;
begin
  ModuleID := StrToIntDef(S, -1);
  ModuleName := '';
  if ModuleID = -1 then
    ModuleName := S;
  try
    CheckModuleOrLocalFile;
    Result := ModuleID;
    AName := ModuleName;
  finally
    ModuleID := -1;
    ModuleName := '';
  end;
end;

// Project by name or ID; the open project (globals) is kept.
function internResolveBugProject(const S: string; out AName: string): Integer;
var
  SaveID: Integer;
  SaveName: string;
begin
  SaveID := ProjectID;
  SaveName := ProjectName;
  try
    ProjectID := StrToIntDef(S, 0);
    ProjectName := '';
    if ProjectID = 0 then
      ProjectName := S;
    CheckOpenProject;
    Result := ProjectID;
    AName := ProjectName;
  finally
    ProjectID := SaveID;
    ProjectName := SaveName;
  end;
end;

function internGetAllBugs: TJVCSGetBugs;
begin
  Result := TJVCSGetBugs.Create(nil);
  try
    Result.IncludeDescription := True;
    Connection.SendRequest(Result);
    ShowLog(Result);
  except
    Result.Free;
    raise;
  end;
end;

function internFindBug(GetBugs: TJVCSGetBugs; ABugID: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to GetBugs.OutputItemCount - 1 do
    if GetBugs.OutputItems[I].BugID = ABugID then
    begin
      Result := I;
      Break;
    end;
end;

// The server compares names with '=' (case sensitive in Firebird); the standalone treats
// BUG1 and bug1 as equal, so the console refuses both (also for accented letters).
function internFindBugByName(GetBugs: TJVCSGetBugs; const AName: string; AExceptID: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to GetBugs.OutputItemCount - 1 do
    if (GetBugs.OutputItems[I].BugID <> AExceptID) and
      AnsiSameText(Trim(string(GetBugs.OutputItems[I].BugName)), AName) then
    begin
      Result := I;
      Break;
    end;
end;

// User list only to show names; without it the creator is shown as #<user_id>.
function internGetUsersSafe: TJVCSGetUsers;
begin
  Result := TJVCSGetUsers.Create(nil);
  try
    Connection.SendRequest(Result);
    ShowLog(Result);
  except
    FreeAndNil(Result);
  end;
end;

// GET_BUGS returns in CreatedBy the user ID (the server stores createdby = AccessID).
function internBugCreator(GetUsers: TJVCSGetUsers; const CreatedBy: string): string;
var
  I, UID: Integer;
begin
  Result := Trim(CreatedBy);
  UID := StrToIntDef(Result, -1);
  if UID < 0 then
    Exit;
  Result := '#' + IntToStr(UID);
  if Assigned(GetUsers) then
    for I := 0 to GetUsers.OutputItemCount - 1 do
      if GetUsers.OutputItems[I].UserID = UID then
      begin
        Result := string(GetUsers.OutputItems[I].UserName);
        Break;
      end;
end;

procedure internWriteBugHeader;
begin
  Write(StrAlign('BugID', 8), ' ');
  Write(StrAlign('Sev', 3), ' ');
  Write(StrAlign('Sta', 3), ' ');
  Write(StrAlign('Done', 4), ' ');
  Write(StrAlign('Created', 19), ' ');
  Write(StrAlign('Created by', 20), ' ');
  Write(StrAlign('Flags', 10), ' ');
  Writeln('Bug');
  Write(StringOfChar('=', 8), ' ');
  Write(StringOfChar('=', 3), ' ');
  Write(StringOfChar('=', 3), ' ');
  Write(StringOfChar('=', 4), ' ');
  Write(StringOfChar('=', 19), ' ');
  Write(StringOfChar('=', 20), ' ');
  Write(StringOfChar('=', 10), ' ');
  Writeln(StringOfChar('=', 7));
end;

// One bug: fixed columns + name (from column 74), then the four text lines, always in this order.
procedure internWriteBug(const B: TGetBugsOutputItem; const DoneText, Creator: string);
var
  Created: string;
begin
  Created := '';
  if B.CreatedTime > 1 then
    Created := FormatDateTime('yyyy-mm-dd hh:nn:ss', GMTDT2LocalDT(B.CreatedTime));
  Write(StrAlign(IntToStr(B.BugID), 8), ' ');
  Write(StrAlign(IntToStr(B.Severity), 3), ' ');
  Write(StrAlign(IntToStr(B.Status), 3), ' ');
  Write(StrAlign(DoneText, 4), ' ');
  Write(StrAlign(Created, 19), ' ');
  Write(StrAlign(Creator, 20), ' ');
  Write(StrAlign(IntToStr(B.Flags), 10), ' ');
  Writeln(EscapeHistoryComment(string(B.BugName)));
  Writeln('  keywords: ', EscapeHistoryComment(string(B.Keywords)));
  Writeln('  reportedby: ', EscapeHistoryComment(B.ReportedBy));
  Writeln('  description: ', EscapeHistoryComment(B.Description));
  Writeln('  workaround: ', EscapeHistoryComment(B.Workaround));
end;

// Assignment of a bug to a module/project: Result = assigned, ADone = done flag of it.
function internBugLinkState(IsProject: Boolean; AItemID, ABugID: Integer; out ADone: Boolean): Boolean;
var
  ByProject: TJVCSGetBugsByProject;
  ByModule: TJVCSGetBugsByModule;
  I: Integer;
begin
  Result := False;
  ADone := False;
  if IsProject then
  begin
    ByProject := TJVCSGetBugsByProject.Create(nil);
    try
      ByProject.ProjectID := AItemID;
      Connection.SendRequest(ByProject);
      ShowLog(ByProject);
      for I := 0 to ByProject.OutputItemCount - 1 do
        if ByProject.OutputItems[I].BugID = ABugID then
        begin
          Result := True;
          ADone := ByProject.OutputItems[I].Done;
          Break;
        end;
    finally
      ByProject.Free;
    end;
  end
  else
  begin
    ByModule := TJVCSGetBugsByModule.Create(nil);
    try
      ByModule.ModuleID := AItemID;
      Connection.SendRequest(ByModule);
      ShowLog(ByModule);
      for I := 0 to ByModule.OutputItemCount - 1 do
        if ByModule.OutputItems[I].BugID = ABugID then
        begin
          Result := True;
          ADone := ByModule.OutputItems[I].Done;
          Break;
        end;
    finally
      ByModule.Free;
    end;
  end;
end;

function CmdProcListBugs(const Line: string; var ExtExitCode: Integer): Boolean;
var
  Count, I, Idx, ItemID, Shown: Integer;
  Mode, S, ItemName, DoneText: string;
  GetBugs: TJVCSGetBugs;
  GetUsers: TJVCSGetUsers;
  ByModule: TJVCSGetBugsByModule;
  ByProject: TJVCSGetBugsByProject;
  UsedBy: TJVCSBugsUsedBy;
  B: TGetBugsOutputItem;
  BM: TGetBugsByModuleOutputItem;
  BP: TGetBugsByProjectOutputItem;
  procedure WriteAssigned(ABugID: Integer; const AName, ADescription: string; ASeverity: Integer; ADone: Boolean);
  var
    Row: TGetBugsOutputItem;
    K: Integer;
  begin
    K := internFindBug(GetBugs, ABugID);
    if K >= 0 then
      Row := GetBugs.OutputItems[K]
    else
    begin
      // assignment to a bug missing from GET_BUGS: only the data of the assignment
      Row := Default(TGetBugsOutputItem);
      Row.BugID := ABugID;
      Row.BugName := JVCSString250(AnsiString(AName));
      Row.Description := ADescription;
      Row.Severity := ASeverity;
      Row.Status := -1;
    end;
    if ADone then
      DoneText := 'yes'
    else
      DoneText := 'no';
    internWriteBug(Row, DoneText, internBugCreator(GetUsers, string(Row.CreatedBy)));
    Inc(Shown);
  end;
begin
  Result := False;
  Count := LineParamCount(Line);
  if not (Count in [1, 3]) then
    Exit;
  Mode := 'all';
  S := '';
  if Count = 3 then
  begin
    Mode := LowerCase(LineParamStr(Line, 2));
    S := LineParamStr(Line, 3);
    if (Mode <> 'module') and (Mode <> 'project') and (Mode <> 'bug') then
      Exit;
  end;
  ItemID := 0;
  ItemName := '';
  Shown := 0;
  GetBugs := nil;
  GetUsers := nil;
  ByModule := nil;
  ByProject := nil;
  UsedBy := nil;
  try
    if Mode = 'module' then
      ItemID := internResolveBugModule(S, ItemName)
    else
    if Mode = 'project' then
      ItemID := internResolveBugProject(S, ItemName)
    else
    if Mode = 'bug' then
    begin
      ItemID := StrToIntDef(S, 0);
      if ItemID <= 0 then
        Exit;
    end;
    GetBugs := internGetAllBugs;
    GetUsers := internGetUsersSafe;
    if Mode = 'module' then
      Writeln('Module: ', ItemName, ' (ID ', ItemID, ')')
    else
    if Mode = 'project' then
      Writeln('Project: ', ItemName, ' (ID ', ItemID, ')')
    else
    if Mode = 'bug' then
      Writeln('Bug: ', ItemID)
    else
      Writeln('Bugs: all');
    Writeln;
    internWriteBugHeader;
    if Mode = 'all' then
    begin
      for I := 0 to GetBugs.OutputItemCount - 1 do
      begin
        B := GetBugs.OutputItems[I];
        internWriteBug(B, '', internBugCreator(GetUsers, string(B.CreatedBy)));
        Inc(Shown);
      end;
    end
    else
    if Mode = 'bug' then
    begin
      Idx := internFindBug(GetBugs, ItemID);
      if Idx < 0 then
        raise Exception.CreateFmt('Bug %d not found', [ItemID]);
      B := GetBugs.OutputItems[Idx];
      internWriteBug(B, '', internBugCreator(GetUsers, string(B.CreatedBy)));
      Inc(Shown);
      UsedBy := TJVCSBugsUsedBy.Create(nil);
      UsedBy.BugID := ItemID;
      Connection.SendRequest(UsedBy);
      ShowLog(UsedBy);
      for I := 0 to UsedBy.OutputItemCount - 1 do
        Writeln('  link: ', string(UsedBy.OutputItems[I].ItemType), ' ', UsedBy.OutputItems[I].ItemID, ' ',
          EscapeHistoryComment(string(UsedBy.OutputItems[I].ItemName)));
    end
    else
    if Mode = 'module' then
    begin
      ByModule := TJVCSGetBugsByModule.Create(nil);
      ByModule.ModuleID := ItemID;
      Connection.SendRequest(ByModule);
      ShowLog(ByModule);
      for I := 0 to ByModule.OutputItemCount - 1 do
      begin
        BM := ByModule.OutputItems[I];
        WriteAssigned(BM.BugID, string(BM.BugName), BM.Description, BM.Severity, BM.Done);
      end;
    end
    else
    begin
      ByProject := TJVCSGetBugsByProject.Create(nil);
      ByProject.ProjectID := ItemID;
      Connection.SendRequest(ByProject);
      ShowLog(ByProject);
      for I := 0 to ByProject.OutputItemCount - 1 do
      begin
        BP := ByProject.OutputItems[I];
        WriteAssigned(BP.BugID, string(BP.BugName), BP.Description, BP.Severity, BP.Done);
      end;
    end;
    Writeln;
    Writeln(Shown, ' bug(s)');
    Result := True;
  finally
    UsedBy.Free;
    ByProject.Free;
    ByModule.Free;
    GetUsers.Free;
    GetBugs.Free;
  end;
end;

function CmdProcBugSummary(const Line: string; var ExtExitCode: Integer): Boolean;
var
  Mode: string;
  I: Integer;
  GetMostSevere: TJVCSGetMostSevereBugs;
  Row: TGetMostSevereBugsOutputItem;
begin
  Result := False;
  if LineParamCount(Line) <> 2 then
    Exit;
  Mode := LowerCase(LineParamStr(Line, 2));
  if (Mode <> 'modules') and (Mode <> 'projects') then
    Exit;
  GetMostSevere := TJVCSGetMostSevereBugs.Create(nil);
  try
    GetMostSevere.ModuleBased := Mode = 'modules';
    Connection.SendRequest(GetMostSevere);
    ShowLog(GetMostSevere);
    Writeln('Most severe open bug per ', Copy(Mode, 1, Length(Mode) - 1));
    Writeln;
    Write(StrAlign('ItemID', 8), ' ');
    Write(StrAlign('BugID', 8), ' ');
    Writeln('Sev');
    Write(StringOfChar('=', 8), ' ');
    Write(StringOfChar('=', 8), ' ');
    Writeln(StringOfChar('=', 3));
    for I := 0 to GetMostSevere.OutputItemCount - 1 do
    begin
      Row := GetMostSevere.OutputItems[I];
      Write(StrAlign(IntToStr(Row.ItemID), 8), ' ');
      Write(StrAlign(IntToStr(Row.BugID), 8), ' ');
      Writeln(IntToStr(Row.Severity));
    end;
    Writeln;
    Writeln(GetMostSevere.OutputItemCount, ' item(s)');
    Result := True;
  finally
    GetMostSevere.Free;
  end;
end;

function CmdProcAddBug(const Line: string; var ExtExitCode: Integer): Boolean;
var
  Count, P, Idx: Integer;
  E: TBugEdit;
  GetBugs: TJVCSGetBugs;
  AddUpdateBug: TJVCSAddUpdateBug;
begin
  Result := False;
  Count := LineParamCount(Line);
  if Count < 2 then
    Exit;
  E := Default(TBugEdit);
  E.Name := Trim(LineParamStr(Line, 2));
  P := Pos('=', E.Name);
  if (P > 1) and internIsBugOptionKey(Copy(E.Name, 1, P - 1)) then
    Exit; // the positional <bug_name> is missing
  internParseBugOptions(Line, 3, E);
  if E.HasName then
    raise Exception.Create('addbug takes the bug name as the first parameter, not name=');
  if not E.HasSeverity then
    E.Severity := 0;
  if not E.HasStatus then
    E.Status := 1;
  internCheckBugTexts(E.Name, E.Keywords, E.ReportedBy, E.Description, E.Workaround);

  GetBugs := internGetAllBugs;
  try
    Idx := internFindBugByName(GetBugs, E.Name, 0);
    if Idx >= 0 then
    begin
      Writeln('Bug already exists: ', EscapeHistoryComment(string(GetBugs.OutputItems[Idx].BugName)),
        ' (ID ', GetBugs.OutputItems[Idx].BugID, ')');
      Result := True;
      Exit;
    end;
  finally
    GetBugs.Free;
  end;

  AddUpdateBug := TJVCSAddUpdateBug.Create(nil);
  try
    AddUpdateBug.BugID := 0;
    AddUpdateBug.BugName := JVCSString250(AnsiString(E.Name));
    AddUpdateBug.Severity := E.Severity;
    AddUpdateBug.Flags := 0; // as the standalone (MaintainBugs.pas:526)
    AddUpdateBug.Description := E.Description;
    AddUpdateBug.Keywords := JVCSString250(AnsiString(E.Keywords));
    AddUpdateBug.ReportedBy := E.ReportedBy;
    AddUpdateBug.Workaround := E.Workaround;
    AddUpdateBug.Status := E.Status;
    Connection.SendRequest(AddUpdateBug);
    ShowLog(AddUpdateBug);
    if AddUpdateBug.NewBug then
    begin
      // the server reads the new ID back by name; without it the caller cannot use the bug
      if AddUpdateBug.NewBugID <= 0 then
        raise Exception.CreateFmt('Bug created but the server returned no ID; check with listbugs: %s', [E.Name]);
      Writeln('Bug created: ', E.Name, ' (ID ', AddUpdateBug.NewBugID, ')');
    end
    else
    begin
      if AddUpdateBug.NewBugID <= 0 then
        raise Exception.Create('Bug not created: ' + AddUpdateBug.ErrorMessage);
      if AddUpdateBug.ErrorMessage <> '' then
        Writeln(AddUpdateBug.ErrorMessage);
      Writeln('Bug already exists: ', E.Name, ' (ID ', AddUpdateBug.NewBugID, ')');
    end;
    Result := True;
  finally
    AddUpdateBug.Free;
  end;
end;

function CmdProcUpdateBug(const Line: string; var ExtExitCode: Integer): Boolean;
var
  Count, BugID, Idx, Flags, NewSeverity, NewStatus: Integer;
  E: TBugEdit;
  Cur: TGetBugsOutputItem;
  NewName, NewKeywords, NewReportedBy, NewDescription, NewWorkaround, Changed: string;
  GetBugs: TJVCSGetBugs;
  AddUpdateBug: TJVCSAddUpdateBug;
  procedure AddChanged(const AField: string);
  begin
    if Changed <> '' then
      Changed := Changed + ', ';
    Changed := Changed + AField;
  end;
begin
  Result := False;
  Count := LineParamCount(Line);
  if Count < 3 then
    Exit;
  BugID := StrToIntDef(LineParamStr(Line, 2), 0);
  if BugID <= 0 then
    Exit;
  E := Default(TBugEdit);
  internParseBugOptions(Line, 3, E);

  Changed := '';
  GetBugs := internGetAllBugs;
  try
    Idx := internFindBug(GetBugs, BugID);
    if Idx < 0 then
      raise Exception.CreateFmt('Bug %d not found', [BugID]);
    Cur := GetBugs.OutputItems[Idx];
    NewName := string(Cur.BugName);
    NewSeverity := Cur.Severity;
    NewStatus := Cur.Status;
    NewKeywords := string(Cur.Keywords);
    NewReportedBy := Cur.ReportedBy;
    NewDescription := Cur.Description;
    NewWorkaround := Cur.Workaround;
    if E.HasName and (E.Name <> NewName) then
    begin
      Idx := internFindBugByName(GetBugs, E.Name, BugID);
      if Idx >= 0 then
        raise Exception.CreateFmt('Another bug already uses the name ''%s'' (ID %d)',
          [E.Name, GetBugs.OutputItems[Idx].BugID]);
      NewName := E.Name;
      AddChanged('name');
    end;
    if E.HasSeverity and (E.Severity <> NewSeverity) then
    begin
      NewSeverity := E.Severity;
      AddChanged('severity');
    end;
    if E.HasStatus and (E.Status <> NewStatus) then
    begin
      NewStatus := E.Status;
      AddChanged('status');
    end;
    if E.HasKeywords and (E.Keywords <> NewKeywords) then
    begin
      NewKeywords := E.Keywords;
      AddChanged('keywords');
    end;
    if E.HasReportedBy and (E.ReportedBy <> NewReportedBy) then
    begin
      NewReportedBy := E.ReportedBy;
      AddChanged('reportedby');
    end;
    if E.HasDescription and (E.Description <> NewDescription) then
    begin
      NewDescription := E.Description;
      AddChanged('description');
    end;
    if E.HasWorkaround and (E.Workaround <> NewWorkaround) then
    begin
      NewWorkaround := E.Workaround;
      AddChanged('workaround');
    end;
  finally
    GetBugs.Free;
  end;
  if (NewSeverity < 0) or (NewSeverity > 4) or (NewStatus < 0) or (NewStatus > 4) then
    raise Exception.CreateFmt('Bug %d has invalid severity/status on the server; give severity= and status=', [BugID]);
  internCheckBugTexts(NewName, NewKeywords, NewReportedBy, NewDescription, NewWorkaround);
  if Changed = '' then
  begin
    Writeln('Bug not changed: ', EscapeHistoryComment(NewName), ' (ID ', BugID, ')');
    Result := True;
    Exit;
  end;

  Flags := Cur.Flags;
  if Flags < 0 then
    Flags := 0;
  AddUpdateBug := TJVCSAddUpdateBug.Create(nil);
  try
    // ADD_UPDATE_BUG with BugID <> 0 overwrites every column: send all of them
    AddUpdateBug.BugID := BugID;
    AddUpdateBug.BugName := JVCSString250(AnsiString(NewName));
    AddUpdateBug.Severity := NewSeverity;
    AddUpdateBug.Flags := Flags;
    AddUpdateBug.Description := NewDescription;
    AddUpdateBug.Keywords := JVCSString250(AnsiString(NewKeywords));
    AddUpdateBug.ReportedBy := NewReportedBy;
    AddUpdateBug.Workaround := NewWorkaround;
    AddUpdateBug.Status := NewStatus;
    Connection.SendRequest(AddUpdateBug);
    ShowLog(AddUpdateBug);
  finally
    AddUpdateBug.Free;
  end;

  // the server confirms nothing for an update: read the bug again and compare EVERY field
  GetBugs := internGetAllBugs;
  try
    Idx := internFindBug(GetBugs, BugID);
    if Idx < 0 then
      raise Exception.CreateFmt('Update of bug %d not confirmed by the server', [BugID]);
    Cur := GetBugs.OutputItems[Idx];
    if (Trim(string(Cur.BugName)) <> Trim(NewName)) or (Cur.Severity <> NewSeverity) or
      (Cur.Status <> NewStatus) or (Trim(string(Cur.Keywords)) <> Trim(NewKeywords)) or
      not internSameBugText(Cur.ReportedBy, NewReportedBy) or
      not internSameBugText(Cur.Description, NewDescription) or
      not internSameBugText(Cur.Workaround, NewWorkaround) then
      raise Exception.CreateFmt('Update of bug %d not confirmed by the server', [BugID]);
  finally
    GetBugs.Free;
  end;
  Writeln('Bug updated: ', EscapeHistoryComment(NewName), ' (ID ', BugID, ')');
  Writeln('Changed: ', Changed);
  Result := True;
end;

function CmdProcAssignBug(const Line: string; var ExtExitCode: Integer): Boolean;
var
  Count, BugID, ItemID: Integer;
  Kind, Action, ItemName, Msg: string;
  IsProject, Linked, LinkDone, DoneNow: Boolean;
  GetBugs: TJVCSGetBugs;
  AssignRemoveBug: TJVCSAssignRemoveBug;
  EnableBug: TJVCSEnableModuleProjectBug;
begin
  Result := False;
  Count := LineParamCount(Line);
  if not (Count in [4, 5]) then
    Exit;
  BugID := StrToIntDef(LineParamStr(Line, 2), 0);
  Kind := LowerCase(LineParamStr(Line, 3));
  Action := 'add';
  if Count = 5 then
    Action := LowerCase(LineParamStr(Line, 5));
  if (BugID <= 0) or ((Kind <> 'module') and (Kind <> 'project')) or
    ((Action <> 'add') and (Action <> 'remove') and (Action <> 'done') and (Action <> 'open')) then
    Exit;
  IsProject := Kind = 'project';
  if IsProject then
    ItemID := internResolveBugProject(LineParamStr(Line, 4), ItemName)
  else
    ItemID := internResolveBugModule(LineParamStr(Line, 4), ItemName);

  // the server does not check the bug ID (ASSIGN_REMOVE_BUG inserts any number)
  GetBugs := internGetAllBugs;
  try
    if internFindBug(GetBugs, BugID) < 0 then
      raise Exception.CreateFmt('Bug %d not found', [BugID]);
  finally
    GetBugs.Free;
  end;

  Linked := internBugLinkState(IsProject, ItemID, BugID, LinkDone);
  if Action = 'add' then
  begin
    if Linked then
      Msg := 'Bug already assigned'
    else
    begin
      AssignRemoveBug := TJVCSAssignRemoveBug.Create(nil);
      try
        AssignRemoveBug.ItemID := ItemID;
        AssignRemoveBug.BugID := BugID;
        AssignRemoveBug.ProjectRelated := IsProject;
        AssignRemoveBug.AddBug := True;
        Connection.SendRequest(AssignRemoveBug);
        ShowLog(AssignRemoveBug);
      finally
        AssignRemoveBug.Free;
      end;
      if not internBugLinkState(IsProject, ItemID, BugID, DoneNow) then
        raise Exception.CreateFmt('Assignment of bug %d not confirmed by the server', [BugID]);
      Msg := 'Bug assigned';
    end;
  end
  else
  if Action = 'remove' then
  begin
    if not Linked then
      Msg := 'Bug not assigned'
    else
    begin
      AssignRemoveBug := TJVCSAssignRemoveBug.Create(nil);
      try
        AssignRemoveBug.ItemID := ItemID;
        AssignRemoveBug.BugID := BugID;
        AssignRemoveBug.ProjectRelated := IsProject;
        AssignRemoveBug.AddBug := False;
        Connection.SendRequest(AssignRemoveBug);
        ShowLog(AssignRemoveBug);
      finally
        AssignRemoveBug.Free;
      end;
      if internBugLinkState(IsProject, ItemID, BugID, DoneNow) then
        raise Exception.CreateFmt('Removal of bug %d not confirmed by the server', [BugID]);
      Msg := 'Bug removed';
    end;
  end
  else
  begin
    // done/open: ENABLE_MODULE_PROJECT_BUG updates nothing (and says nothing) without the assignment
    if not Linked then
      raise Exception.CreateFmt('Bug %d is not assigned to %s %d ''%s''', [BugID, Kind, ItemID, ItemName]);
    if LinkDone = (Action = 'done') then
      Msg := 'Bug already ' + Action
    else
    begin
      EnableBug := TJVCSEnableModuleProjectBug.Create(nil);
      try
        EnableBug.ItemID := ItemID;
        EnableBug.BugID := BugID;
        EnableBug.ProjectRelated := IsProject;
        EnableBug.Done := Action = 'done';
        Connection.SendRequest(EnableBug);
        ShowLog(EnableBug);
      finally
        EnableBug.Free;
      end;
      if (not internBugLinkState(IsProject, ItemID, BugID, DoneNow)) or (DoneNow <> (Action = 'done')) then
        raise Exception.CreateFmt('State change of bug %d not confirmed by the server', [BugID]);
      Msg := 'Bug marked ' + Action;
    end;
  end;
  Writeln(Format('%s: bug %d %s %d %s', [Msg, BugID, Kind, ItemID, EscapeHistoryComment(ItemName)]));
  Result := True;
end;

function CmdProcExit(const Line: string; var ExtExitCode: Integer): Boolean;
begin
  Result := False;
  if LineParamCount(Line) = 1 then
  begin
    ExitSession := True;
    Result := True;
  end;
end;

function CmdProcHelp(const Line: string; var ExtExitCode: Integer): Boolean;
var
  Count, I, CmdIndex: Integer;
  S: string;
begin
  Result := False;
  Count := LineParamCount(Line);
  if Count = 1 then
  begin
    ShowCommands;
    Result := True;
  end
  else
  if Count = 2 then
  begin
    S := LineParamStr(Line, 2);
    CmdIndex := -1;
    for I := Low(Commands) to High(Commands) do
      if AnsiCompareText(S, Commands[I].Name) = 0 then
      begin
        CmdIndex := I;
        Break;
      end;
    if CmdIndex = -1 then
      ShowCommands
    else
      ShowCommand(CmdIndex);
    Result := True;
  end;
end;

function CmdProcInput(const Line: string; var ExtExitCode: Integer): Boolean;
var
  Count, I: Integer;
  Lines: TStringList;
  InputEncoding: TEncoding;
begin
  Result := False;
  Count := LineParamCount(Line);
  if Count = 2 then
  begin
    InputFileName := LineParamStr(Line, 2);
    if not FileExists(InputFileName) then
      raise Exception.CreateFmt(SInputFileNotFound, [InputFileName]);
    Lines := TStringList.Create;
    try
      // JVCS 2026: without a BOM the file is read in the wire code page (cp1252), whatever the
      // ANSI code page of Windows is: the 2.5.0.1030 console passed the bytes as they were, and
      // with ACP 65001 the default would decode a cp1252 file as UTF-8. A BOM still wins.
      InputEncoding := TEncoding.GetEncoding(MWCodePage);
      try
        Lines.DefaultEncoding := InputEncoding; // TStrings keeps a clone
      finally
        InputEncoding.Free;
      end;
      Lines.LoadFromFile(InputFileName);
      for I := 0 to Lines.Count - 1 do
        try
          if AnsiCompareText(LineParamStr(Lines[I], 1), 'exit') = 0 then
            Break;
          Write(JVCSPrompt);
          Writeln(Lines[I]);
          ProcessLine(Lines[I]);
        except
          on E: Exception do
            if not (E is EAbort) then
              Writeln('[', E.ClassName, '] ', E.Message);
        end;
        Result := True;
    finally
      Lines.Free;
    end;
  end;
end;

{$IFDEF BRANCHING}
function CmdProcListBranches(const Line: string; var ExtExitCode: Integer): Boolean;
var
  Count: Integer;
  GetBranchList: TJVCSGetBranchList;
  GetUsers: TJVCSGetUsers;
  I, J: Integer;
  S: string;
begin
  Result := False;
  Count := LineParamCount(Line);
  if Count = 1 then
  begin
    GetBranchList := TJVCSGetBranchList.Create(nil);
    GetUsers := TJVCSGetUsers.Create(nil);
    try
      GetBranchList.IncludeDetails := True;
      Connection.SendRequest(GetBranchList);
      ShowLog(GetBranchList);
      Connection.SendRequest(GetUsers);
      ShowLog(GetUsers);
      for I := 0 to GetBranchList.OutputItemCount - 1 do
        with GetBranchList.OutputItems[I] do
        begin
          if I mod LinesPerPage = 0 then
          begin
            Writeln;
            Write(StrAlign('ID', 8), ' ');
            Write(StrAlign('ParentID', 8), ' ');
            Write(StrAlign('Branch Name', 30), ' ');
            Write(StrAlign('Created', 25), ' ');
            Write(StrAlign('Creator', 20), ' ');
            Write(StrAlign('Description', 50), ' ');
            Writeln;
            Write(StringOfChar('=', 8), ' ');
            Write(StringOfChar('=', 8), ' ');
            Write(StringOfChar('=', 30), ' ');
            Write(StringOfChar('=', 25), ' ');
            Write(StringOfChar('=', 20), ' ');
            Write(StringOfChar('=', 50), ' ');
            Writeln;
          end;
          Write(StrAlign(IntToStr(BranchID), 8), ' ');
          Write(StrAlign(IntToStr(ParentBranchID), 8), ' ');
          Write(StrAlign(Name, 30), ' ');
          Write(StrAlign(FmtStamp(Created_In), 25), ' ');
          S := '';
          if Created_By > 0 then
            for J := 0 to Pred(GetUsers.OutputItemCount) do
              if GetUsers.OutputItems[J].UserID = Created_By then
              begin
                S := GetUsers.OutputItems[J].UserName;
                Break;
              end;
          Write(StrAlign(S, 20), ' ');
          Write(StrAlign(TrimLines(Description, 50), 50), ' ');
          Writeln;
        end;
      Writeln;
    finally
      GetBranchList.Free;
      GetUsers.Free;
    end;
    Result := True;
  end;
end;
{$ENDIF BRANCHING}

function CmdProcListLocks(const Line: string; var ExtExitCode: Integer): Boolean;
var
  Count: Integer;
  UserName: string;
  UserID: Integer;
  GetUsers: TJVCSGetUsers;
  I: Integer;
  GetLockedModules: TJVCSGetLockedModules;
begin
  Result := False;
  Count := LineParamCount(Line);
  if not (Count in [1, 2]) then
    Exit;
  if Count = 2 then
  begin
    UserName := LineParamStr(Line, 2);
    if AnsiCompareText(UserName, 'all_users') = 0 then
      UserID := 0
    else
    begin
      UserID := -1;
      GetUsers := TJVCSGetUsers.Create(nil);
      try
        Connection.SendRequest(GetUsers);
        ShowLog(GetUsers);
        for I := 0 to GetUsers.OutputItemCount - 1 do
          if AnsiCompareStr(UserName, GetUsers.OutputItems[I].UserName) = 0 then
          begin
            UserID := GetUsers.OutputItems[I].UserID;
            Break;
          end;
      finally
        GetUsers.Free;
      end;
      if UserID = -1 then
        raise Exception.CreateFmt(SUserNotFound, [UserName]);
    end;
  end
  else
    UserID := Connection.UserID;
  GetLockedModules := TJVCSGetLockedModules.Create(nil);
  try
    GetLockedModules.ProjectID := 0;
    GetLockedModules.UserID := UserID;
    Connection.SendRequest(GetLockedModules);
    ShowLog(GetLockedModules);
    for I := 0 to GetLockedModules.OutputItemCount - 1 do
      with GetLockedModules.OutputItems[I] do
      begin
        if I mod LinesPerPage = 0 then
        begin
          Writeln;
          Write(StrAlign('ID', 8), ' ');
          Write(StrAlign('Module Path', 50), ' ');
          Write(StrAlign('Module Name', 30), ' ');
          Write(StrAlign('Version', 7), ' ');
          Write(StrAlign('Owner', 20), ' ');
          Write(StrAlign('Locked', 25), ' ');
          Writeln;
          Write(StringOfChar('=', 8), ' ');
          Write(StringOfChar('=', 50), ' ');
          Write(StringOfChar('=', 30), ' ');
          Write(StringOfChar('=', 7), ' ');
          Write(StringOfChar('=', 20), ' ');
          Write(StringOfChar('=', 25), ' ');
          Writeln;
        end;
        Write(StrAlign(IntToStr(ModuleID), 8), ' ');
        Write(StrAlign(ModulePath, 50), ' ');
        Write(StrAlign(ModuleName, 30), ' ');
        Write(StrAlign(Format('%d.%d', [Version, Revision]), 7), ' ');
        Write(StrAlign(Owner, 20), ' ');
        Write(StrAlign(FmtStamp(LockedTimestamp), 25), ' ');
        Writeln;
      end;

    Writeln;
    Result := True;
  finally
    GetLockedModules.Free;
  end;
end;

function CmdProcListProject(const Line: string; var ExtExitCode: Integer): Boolean;
var
  Count, I, J, K: Integer;
//thu 30.10.2003   S, T: string;
  S: string;
  GetVersionList: TJVCSGetVersionList;
  GetLatestRevisions: TJVCSGetLatestRevisions;
  LatestRevision: TGetLatestRevisionsOutputItem;
  ModuleFileName: string;
  VersionListIndex: Integer;
  bDiffOnly, bNewOnly, bOldOnly: Boolean;
  bIncludeHidden: Boolean; //thu 30.10.2003
  bParamOk: Boolean; //thu 30.10.2003
  ii: Integer; //thu 30.10.2003
begin
  Result := False;
  bDiffOnly := False;
  bNewOnly := False;
  bOldOnly := False;
  bIncludeHidden := False;

  Count := LineParamCount(Line);
  //thu 30.10.2003
  if not (Count in [2..4]) then
    Exit; //!!!

  S := LineParamStr(Line, 2);
  ProjectID := StrToIntDef(S, -1);
  if ProjectID = -1 then
    ProjectName := S;

  bParamOk := True;
  for ii := 3 to Count do
  begin
    bParamOk := True;
    S := LineParamStr(Line, ii);
    if AnsiCompareText(S, 'diffonly') = 0 then
    begin
      bDiffOnly := True;
      bNewOnly := False;
      bOldOnly := False;
    end
    else
    if AnsiCompareText(S, 'newonly') = 0 then
    begin
      bNewOnly := True;
      bDiffOnly := False;
      bOldOnly := False;
    end
    else
    if AnsiCompareText(S, 'oldonly') = 0 then
    begin
      bOldOnly := True;
      bNewOnly := False;
      bDiffOnly := False;
    end
    else
    if AnsiCompareText(S, 'includehidden') = 0 then
      bIncludeHidden := True
    else
       bParamOk := False;
    if not bParamOk then
      Break;
  end;  //for

  if bParamOk then
  begin
    try
      CheckOpenProject;
      GetVersionList := TJVCSGetVersionList.Create(nil);
      try
        GetVersionList.ProjectID := ProjectID;
//thu 30.10.2003         GetVersionList.ExcludeHiddenModules := False;
        GetVersionList.ExcludeHiddenModules := not bIncludeHidden;
        Connection.SendRequest(GetVersionList);
        ShowLog(GetVersionList);

        GetLatestRevisions := TJVCSGetLatestRevisions.Create(nil);
        try
          GetLatestRevisions.ProjectID := ProjectID;
//thu 30.10.2003           GetLatestRevisions.ExcludeHiddenModules := False;
          GetLatestRevisions.ExcludeHiddenModules := not bIncludeHidden;
          GetLatestRevisions.LabelID := 0;
          Connection.SendRequest(GetLatestRevisions);
          ShowLog(GetLatestRevisions);

          for I := 0 to GetLatestRevisions.OutputItemCount - 1 do
          begin
            if (GetLatestRevisions.OutputItems[I].ModulePath <> '') and
              (GetLatestRevisions.OutputItems[I].ModuleName <> '') then
            begin
              LatestRevision := GetLatestRevisions.OutputItems[I];
              for J := 0 to GetLatestRevisions.OutputItemCount - 1 do
              begin
                with GetLatestRevisions.OutputItems[J] do
                begin

                  if ModuleID = LatestRevision.ModuleID then
                  begin
                    if (ModulePath = '') and (ModuleName = '') then
                      ModuleFileName := ChangeFileExt(PathAddSeparator(LatestRevision.ModulePath) +
                        LatestRevision.ModuleName, RevisionExtension)
                    else
                      ModuleFileName := ChangeFileExt(PathAddSeparator(ModulePath) + ModuleName,
                        RevisionExtension);
                      if ((bDiffOnly) or (bNewOnly) or (bOldOnly)) then
                      begin
                        if (bDiffOnly) then
                        begin
                          if ((FileExists(ModuleFileName)) and (not IsFileDirty(ModuleFileName, RevisionTimestamp))) then Break
                        end
                        else
                        if (bNewOnly) then
                        begin
                          if ((FileExists(ModuleFileName)) and (not (HowIsFileDirty(ModuleFileName, RevisionTimestamp) = 'N'))) then Break
                        end
                        else
                        if (bOldOnly) then
                        begin
                          if ((FileExists(ModuleFileName)) and (not (HowIsFileDirty(ModuleFileName, RevisionTimestamp) = 'O'))) then Break
                        end;
                      end;
                    if J mod LinesPerPage = 0 then
                    begin
                      Writeln;
                      Write(StrAlign('ID', 8), ' ');
                      Write(StrAlign('File Path', 50), ' ');
                      Write(StrAlign('File Name', 30), ' ');
                      Write(StrAlign('Version', 7), ' ');
                      Write(StrAlign('Out', 3), ' ');
                      Write(StrAlign('Owner', 20), ' ');
                      Write(StrAlign('Hid', 3), ' ');
                      Write(StrAlign('Stamp', 5), ' ');
                      Write(StrAlign('CRC', 5), ' ');
                      Writeln;
                      Write(StringOfChar('=', 8), ' ');
                      Write(StringOfChar('=', 50), ' ');
                      Write(StringOfChar('=', 30), ' ');
                      Write(StringOfChar('=', 7), ' ');
                      Write(StringOfChar('=', 3), ' ');
                      Write(StringOfChar('=', 20), ' ');
                      Write(StringOfChar('=', 3), ' ');
                      Write(StringOfChar('=', 5), ' ');
                      Write(StringOfChar('=', 5), ' ');
                      Writeln;
                    end;
                    VersionListIndex := -1;
                    for K := 0 to GetVersionList.OutputItemCount - 1 do
                      if GetVersionList.OutputItems[K].ModuleID = ModuleID then
                      begin
                        VersionListIndex := K;
                        Break;
                      end;
                    Write(StrAlign(IntToStr(ModuleID), 8), ' ');
                    Write(StrAlign(ExtractFilePath(ModuleFileName), 50), ' ');
                    Write(StrAlign(ExtractFileName(ModuleFileName), 30), ' ');
                    Write(StrAlign(Format('%d.%d', [Version, Revision]), 7), ' ');
                    with GetVersionList.OutputItems[VersionListIndex] do
                    begin
                      Write(StrAlign(IndicatorStrings[CheckedOut], 3), ' ');
                      Write(StrAlign(Owner, 20), ' ');
                      Write(StrAlign(IndicatorStrings[Hidden], 3), ' ');
                    end;
                    if FileExists(ModuleFileName) then
                    begin
                      Write(StrAlign(HowIsFileDirty(ModuleFileName, RevisionTimestamp), 5), ' ');
                      Write(StrAlign(IndicatorStrings[IsFileDirtyCRC(ModuleFileName, RevisionCRC32)], 5), ' ');
                    end
                    else
                    begin
                      Write(StrAlign('N/A', 5), ' ');
                      Write(StrAlign('N/A', 5), ' ');
                    end;
                    Writeln;
                  end;
                end;
              end;
            end;
          end;

          Writeln;
          Result := True;
        finally
          GetLatestRevisions.Free;
        end;
      finally
        GetVersionList.Free;
      end;
    finally
      ProjectID := -1;
      ProjectName := '';
    end;
  end;
end;

function CmdProcListProjects(const Line: string; var ExtExitCode: Integer): Boolean;
var
  Count: Integer;
  GetProjectInformation: TJVCSGetProjectInformation;
  I: Integer;
begin
  Result := False;
  Count := LineParamCount(Line);
  if Count = 1 then
  begin
    GetProjectInformation := TJVCSGetProjectInformation.Create(nil);
    try
      GetProjectInformation.ProjectID := 0; // retrieve information about all projects
      Connection.SendRequest(GetProjectInformation);
      ShowLog(GetProjectInformation);
      for I := 0 to GetProjectInformation.OutputItemCount - 1 do
        with GetProjectInformation.OutputItems[I] do
        begin
          if I mod LinesPerPage = 0 then
          begin
            Writeln;
            Write(StrAlign('ID', 8), ' ');
            Write(StrAlign('Project Name', 30), ' ');
            Write(StrAlign('Created', 25), ' ');
            Write(StrAlign('Creator', 20), ' ');
            Write(StrAlign('Del', 3), ' ');
            Write(StrAlign('Description', 50), ' ');
            Writeln;
            Write(StringOfChar('=', 8), ' ');
            Write(StringOfChar('=', 30), ' ');
            Write(StringOfChar('=', 25), ' ');
            Write(StringOfChar('=', 20), ' ');
            Write(StringOfChar('=', 3), ' ');
            Write(StringOfChar('=', 50), ' ');
            Writeln;
          end;
          Write(StrAlign(IntToStr(ProjectID), 8), ' ');
          Write(StrAlign(ProjectName, 30), ' ');
          Write(StrAlign(FmtStamp(Created), 25), ' ');
          Write(StrAlign(CreatedBy, 20), ' ');
          Write(StrAlign(IndicatorStrings[Deleted], 3), ' ');
          Write(StrAlign(TrimLines(Description, 50), 50), ' ');
          Writeln;
        end;
      Writeln;
    finally
      GetProjectInformation.Free;
    end;
    Result := True;
  end;
end;

// -----------------------------------------------------------------------------
// bCRC
// bChangeROAttrib (introduced in 2.45)
// bPrompt
// bLabel
// sLabel => if bLabel True, this is the label to sync
// handleHiddenModules => include hidden, delete hidden modules, ignore
//
function internSyncOneProject (nProjectId: Integer
                              ; bCRC, bChangeROAttrib, bNoPrompt, bLabel: Boolean
                              ; sLabel: string
                              ; handleHiddenModules: THandleHiddenModules
                              ): TSyncResult; //ESasse 29.02.2004
var
  I, J, K, M, VersionListIndex: Integer;
  sFile,
  sTmp: string;
  GetVersionList: TJVCSGetVersionList;
  GetLatestRevisions: TJVCSGetLatestRevisions;
  LatestRevision: TGetLatestRevisionsOutputItem;
  ModuleFilesAreDirty: Boolean;
  GetCheckoutModule: TJVCSGetCheckoutModule;
  CheckedOutByMeModuleList: TSortedIntegerList;
  DirNoPrompt, FileNoPrompt, CreateDirOK, OverwriteFileOK, BreakLoop, AllowWrite: Boolean;
  LinesWritten, ModulesSynced: Integer;
  LabelID: Integer;
  bFileDeleted, bHiddenModule, bHiddenCheckedOut: Boolean;
begin
  LinesWritten := 0;
  ModulesSynced := 0;

  DirNoPrompt := False;
  FileNoPrompt := False;

  // re-/set global project vars!
  ProjectID := nProjectId;
  ProjectName := '';

  sTmp:= '';
  if bNoPrompt then
    sTmp := sTmp + 'noprompt ';
  if bCRC then
    sTmp := sTmp + 'crc '
  else
    sTmp := sTmp + 'stamp ';
  if (handleHiddenModules = hmodInclude) then
    sTmp := sTmp + 'include hidden modules '
  else
  if handleHiddenModules = hmodDelete then
    sTmp := sTmp + 'delete hidden modules ';
  if bLabel then
    sTmp := sTmp + 'labeled with ' + sLabel;
  sTmp := Trim(sTmp);

  CheckedOutByMeModuleList := TSortedIntegerList.Create;
  try
    CheckOpenProject;

    LabelID := 0;
    if bLabel then
      LabelID := CheckGetLabelID(sLabel);

    Write(StrAlign(Format('syncproject %d, %s',[ProjectID, ProjectName]), 15+8+30));
    Writeln(Format('(%s)',[sTmp]));

    GetVersionList := TJVCSGetVersionList.Create(nil);
    try
      GetVersionList.ProjectID := ProjectID;
      GetVersionList.ExcludeHiddenModules := (hmodIgnore = handleHiddenModules);  //#3337
      Connection.SendRequest(GetVersionList);
      ShowLog(GetVersionList);

      GetLatestRevisions := TJVCSGetLatestRevisions.Create(nil);
      try
        GetCheckoutModule := nil;
        try
          GetLatestRevisions.ProjectID := ProjectID;
          GetLatestRevisions.ExcludeHiddenModules := (hmodIgnore = handleHiddenModules);  //#3337
          GetLatestRevisions.LabelID := LabelID;
          Connection.SendRequest(GetLatestRevisions);
          ShowLog(GetLatestRevisions);

          // Build List of modules "I" have checked out
          for m := 0 to GetVersionList.OutputItemCount-1 do
            if GetVersionList.OutputItems[m].CheckedOut then
              if GetVersionList.OutputItems[m].Owner = Connection.UserName then
                CheckedOutByMeModuleList.Add(GetVersionList.OutputItems[m].ModuleID);

          I := 0;
          BreakLoop := False;
          // Loop through project and get for each module its latest revision
          while I < GetLatestRevisions.OutputItemCount do
          begin
            if BreakLoop then
              Break;
            //#3337 detect if module is hidden and delete
            bFileDeleted := False;
            bHiddenModule := False;
            bHiddenCheckedOut := False;

            if (handleHiddenModules = hmodDelete) then
            begin
              //find module and check if hidden
              for K := 0 to GetVersionList.OutputItemCount - 1 do
                if GetVersionList.OutputItems[K].ModuleID = GetLatestRevisions.OutputItems[I].ModuleID then
                begin
                  bHiddenModule := GetVersionList.OutputItems[K].Hidden;
                  bHiddenCheckedOut := GetVersionList.OutputItems[K].CheckedOut;  //no delete if checked out!
                  Break;
                end;
            end;

            ModuleFilesAreDirty := False;
            if (GetLatestRevisions.OutputItems[I].ModulePath <> '') and
              (GetLatestRevisions.OutputItems[I].ModuleName <> '') then
            begin
              LatestRevision := GetLatestRevisions.OutputItems[I];
              // check if one or more module files are dirty (REM: if eg. latest revision is .pas, there are .pas, .dfm as two records)
              for J := 0 to GetLatestRevisions.OutputItemCount - 1 do
              begin
                with GetLatestRevisions.OutputItems[J] do
                begin
                  if (ModuleID = LatestRevision.ModuleID) then
                  begin
                    // IF is it the module or a family member
                    if (ModulePath = '') and (ModuleName = '') then
                      sFile := ChangeFileExt(PathAddSeparator(LatestRevision.ModulePath) + LatestRevision.ModuleName,
                        RevisionExtension)
                    else
                      sFile := ChangeFileExt(PathAddSeparator(ModulePath) + ModuleName, RevisionExtension);

                    sFile := Trim(sFile); //fix wrong spacing (eg. some modules in repository on vcs.delphi-jedi.org)

                    // HandleDeleted files directly here!
                    if (handleHiddenModules = hmodDelete) and bHiddenModule then
                    begin
                      // want to delete hidden and is hidden module but keep if checked out (see find module and check if hidden!)
                      ModuleFilesAreDirty := False;
                      if FileExists(sFile) then
                      begin
                        if not bHiddenCheckedOut then
                        begin
                          // file exist, set readwrite and delete
                          FileSetReadOnlyAttribute(sFile, False);
                          bFileDeleted := DeleteFile(PChar(sFile)) or bFileDeleted; // keep order, first DeleteFile!
                          if LinesWritten mod LinesPerPage = 0 then
                          begin
                            Writeln;
                            Write(StrAlign('ID', 8), ' ');
                            Write(StrAlign('File Path', 50), ' ');
                            Write(StrAlign('File Name', 30), ' ');
                            Write(StrAlign('Timestamp', 20), ' ');
                            Write(StrAlign('CRC', 9));
                            Writeln;
                            Write(StringOfChar('=', 8), ' ');
                            Write(StringOfChar('=', 50), ' ');
                            Write(StringOfChar('=', 30), ' ');
                            Write(StringOfChar('=', 20), ' ');
                            Write(StringOfChar('=', 9));
                            Writeln;
                          end;

                          Write(StrAlign(IntToStr(ModuleID), 8), ' ');
                          Write(StrAlign(ExtractFilePath(sFile), 50), ' ');
                          Write(StrAlign(ExtractFileName(sFile), 30), ' ');
                          // 20 + 9 = 29
                          Write(StringOfChar('x', 3), ' ');
                          Write(StrAlign('!module deleted!', 16), ' ');
                          Write(StringOfChar('x', 10), ' ');
                          Writeln;
                          Inc(LinesWritten);
                          Inc(ModulesSynced);
                        end;
                      end;
                    end
                    else
                    begin
                      // should not delete, check for synch.
                      // (a) based on CRC
                      // (b) based on Timestamp
                      // (c) of if file does not exist
                      if FileExists(sFile) then
                        if bCRC then
                          ModuleFilesAreDirty := IsFileDirtyCRC(sFile, RevisionCRC32)
                        else
                          ModuleFilesAreDirty := IsFileDirty(sFile, RevisionTimestamp)
                      else
                        ModuleFilesAreDirty := True;
                    end;

                    if ModuleFilesAreDirty then
                      Break
                    else
                    begin
                      // for files which need no synch we check FileAttributes if RO parameter was givven
                      // 1. set readonly if file is not checked out by me and is not in the list of always writable files
                      // 2. set readwrite if file is checked out by me or is in the list of always writable files
                      // Changing only file attributes is not handled as a synchronization, so if no file was synched but file attributes were changed we still return "no change"
                      if (bChangeROAttrib and FileExists(sFile)) then
                      begin
                        AllowWrite := (CheckedOutByMeModuleList.IndexOf(LatestRevision.ModuleID) <> -1);
                        AllowWrite := AllowWrite or (MatchWithFilter(ExtractFileName(sFile), GetAlwaysWritableFileTypes));
                        FileSetReadOnlyAttribute(sFile, (not AllowWrite));
                      end;
                    end;
                  end;
                end;  //endwith GetLatestRevisions
              end;  //endfor J

              if ModuleFilesAreDirty then
              begin
                // TODO refactor sync. and drop checkout function. Members are readed over LatestRevision so we could buffer it and make this call obsolete!
                if not Assigned(GetCheckoutModule) then
                  GetCheckoutModule := TJVCSGetCheckoutModule.Create(nil);
                GetCheckoutModule.ProjectID := ProjectID;
                GetCheckoutModule.UserID := Connection.UserID;
                GetCheckoutModule.ModuleID := LatestRevision.ModuleID;
                GetCheckoutModule.RevisionID := LatestRevision.RevisionID;
                GetCheckoutModule.CheckOut := False;
                with LatestRevision do
                  sTmp := ChangeFileExt(PathAddSeparator(ModulePath) + ModuleName, RevisionExtension);  //don't trim here!
                GetCheckoutModule.ModuleName := sTmp;
                Connection.SendRequest(GetCheckoutModule);
                ShowLog(GetCheckoutModule);

                // Here starts the big loop over checked out modules
                // TODO keep filemembers always together, at the moment it is possible over prompt option to sync. eg. .pas member but not .dfm! with option noprompt this is not a problem
                for J := 0 to GetCheckoutModule.OutputItemCount - 1 do
                  with GetCheckoutModule.OutputItems[J] do
                  begin
                    with LatestRevision do
                      sFile := Trim(ChangeFileExt(PathAddSeparator(ModulePath) + ModuleName, ModuleExtension));

                    if not DirectoryExists(ExtractFilePath(sFile)) then
                    begin
                      if bNoPrompt or DirNoPrompt then
                        CreateDirOK := True
                      else
                      begin
                        CreateDirOK := False;
                        case Prompt(Format(SCreateDir, [PathRemoveSeparator(ExtractFilePath(sFile))]),
                          OptionsYesNoAllBreak) of
                          0:
                            CreateDirOK := True;
                          2:
                            begin
                              CreateDirOK := True;
                              DirNoPrompt := True;
                            end;
                          3:
                            begin
                              BreakLoop := True;
                              Break;
                            end;
                        end;
                      end;
                      if CreateDirOK then
                        ForceDirectories(ExtractFilePath(sFile));
                    end; //IF not DirectoryExists(...)

                    if FileExists(sFile) then
                    begin
                      // Check if this Module is checked out by me
                      AllowWrite := (CheckedOutByMeModuleList.IndexOf(LatestRevision.ModuleID) <> -1);

                      if SyncNoPrompt or FileNoPrompt then
// 2003/09/06 PLa  no overwrite if file is checkout by current user
                        OverwriteFileOK := not AllowWrite
                      else
                      begin
                        OverwriteFileOK := False;
                        if AllowWrite then
                         sTmp := sFile + SCheckedOut ;
                        case Prompt(Format(SOverwriteFile, [sTmp]), OptionsYesNoAllBreak) of
                          0:
                            OverwriteFileOK := True;
                          2:
                            begin
                              OverwriteFileOK := True;
                              FileNoPrompt := True;
                            end;
                          3:
                            begin
                              BreakLoop := True;
                              Break;
                            end;
                        end;
                      end;
                    end
                    else
                      OverwriteFileOK := True;

                    if OverwriteFileOK then
                    begin
                      GetCheckoutModule.ExtractBlobToFile(sFile, ModuleBinary);
                      FileSetReadOnlyAttribute(sFile, False);
                      //THu be aware if server/client live in different timezones !
                      //CSchuette, 29.03.2005: fix problem with UTC timestamps
                      FileSetUTCDateTime(sFile, ModuleOriginalTime);

                      // some files are always writable, based on extensions
                      AllowWrite := IsFileTypeAlwaysWritable(ModuleExtension);

                      // file should be writable if it's checked out by current user
                      AllowWrite := (AllowWrite or (CheckedOutByMeModuleList.IndexOf(LatestRevision.ModuleID) <> -1));

                      // consequently AllowWrite should set the file RO/RW attrib
                      FileSetReadOnlyAttribute(sFile, (not AllowWrite));

                      if LinesWritten mod LinesPerPage = 0 then
                      begin
                        Writeln;
                        Write(StrAlign('ID', 8), ' ');
                        Write(StrAlign('File Path', 50), ' ');
                        Write(StrAlign('File Name', 30), ' ');
                        Write(StrAlign('Timestamp', 20), ' ');
                        Write(StrAlign('CRC', 9));
                        Writeln;
                        Write(StringOfChar('=', 8), ' ');
                        Write(StringOfChar('=', 50), ' ');
                        Write(StringOfChar('=', 30), ' ');
                        Write(StringOfChar('=', 20), ' ');
                        Write(StringOfChar('=', 9));
                        Writeln;
                      end;

                      Write(StrAlign(IntToStr(GetCheckoutModule.ModuleID), 8), ' ');
                      Write(StrAlign(ExtractFilePath(sFile), 50), ' ');
                      Write(StrAlign(ExtractFileName(sFile), 30), ' ');
                      Write(StrAlign(FmtStamp(ModuleOriginalTime), 20), ' ');
                      Write(StrAlign(Format('$%.8x', [ModuleOriginalCRC]), 9), ' ');
                      Writeln;
                      Inc(LinesWritten);
                      Inc(ModulesSynced);
                    end;
                  end;
              end; // If ModuleFilesAreDirty
            end; // if GetLatestRevisions.OutputItems[I].ModulePath <> '' ...
            Inc(I);
          end;  //endwhile

          Writeln;

          if ModulesSynced > 0 then
            Result := srSynced
          else
            Result := srUpToDate;
        finally
          GetCheckoutModule.Free;
        end;
      finally
        GetLatestRevisions.Free;
      end;
    finally
      GetVersionList.Free;
    end;
  finally
    ProjectID := -1;
    ProjectName := '';
    CheckedOutByMeModuleList.Free;
  end;
end;

// -----------------------------------------------------------------------------
// Get Projectidlist add's all crossreferenced project-id's; rootid will NOT
// been added to the list.
function internGetProjectCrossRef(const nProjectId: Integer; var slProjectId: TStringList): Boolean;
var
  ii: Integer;
  GetProjectReferences: TJVCSGetProjectReferences;
begin
  Result := False;
  if Assigned(slProjectId) then
  begin
    GetProjectReferences := TJVCSGetProjectReferences.Create(nil);
    try
      GetProjectReferences.ProjectID := nProjectId;
      Connection.SendRequest(GetProjectReferences);
      ShowLog(GetProjectReferences);
      for ii := 0 to GetProjectReferences.OutputItemCount-1 do
      begin
        slProjectId.Add(IntToStr(GetProjectReferences.OutputItems[ii].ProjectID))
      end;
      Result := True;
    finally
      GetProjectReferences.Free;
    end;
  end;
end;

function CmdProcSyncProject(const Line: string; var ExtExitCode: Integer): Boolean;
var
  Count, ii: Integer;
  S: string;
  bParamOk: Boolean;
  slProjectIdList: TStringList;
  bUseCRC: Boolean;
  bChangeROAttrib : Boolean;
  bWithCross: Boolean;
  bByLabel: Boolean;
  handleHiddenModules: THandleHiddenModules;
  sLabel: string;
  bExtExitCode, bAllUpToDate: Boolean;
  SyncResult: TSyncResult;
begin
  Result := False;

  bUseCRC := False;
  bWithCross := False;
  bChangeROAttrib := False;
  bByLabel := False;
  bExtExitCode := False;
  bAllUpToDate := True;
  handleHiddenModules := hmodIgnore;

  Count := LineParamCount(Line);
  if not (Count in [2..8]) then  //thu 30.10.2003
    Exit;
  S := LineParamStr(Line, 2);
  ProjectID := StrToIntDef(S, -1);
  if ProjectID = -1 then
    ProjectName := S;

  bParamOk := True;
  for ii := 3 to Count do
  begin
    bParamOk := True;
    S := LineParamStr(Line, ii);
    if AnsiCompareText(S, 'noprompt') = 0 then
      SyncNoPrompt := True
    else
    if AnsiCompareText(S, 'stamp') = 0 then
      bUseCRC := False
    else
    if AnsiCompareText(S, 'crc') = 0 then
      bUseCRC := True
    else
    if AnsiCompareText(S, 'RO') = 0 then
      bChangeROAttrib := True
    else
    if AnsiCompareText(S, 'crossref') = 0 then
      bWithCross := True
    else
    if AnsiCompareText(S, 'includehidden') = 0 then
      handleHiddenModules := hmodInclude
    else
    if AnsiCompareText(S, 'deletehidden') = 0 then
      handleHiddenModules := hmodDelete
    else
    if AnsiCompareText(S, 'extexitcode') = 0 then
      bExtExitCode := True
    else
    if Pos('label=', AnsiLowerCase(S)) = 1 then
    begin
      bByLabel := True;
      sLabel := Copy(S, 7, Length(S) - 6);
    end
    else
      bParamOk := False;
    if not bParamOk then
      Break;
  end;

  if not bParamOk then
    Exit;

  Result := True;
  try
    slProjectIdList := TStringList.Create;
    try
      CheckOpenProject;
      // add root projectid
      slProjectIdList.Add(IntToStr(ProjectID));
      if bWithCross then
      begin
        if not internGetProjectCrossRef(ProjectID, slProjectIdList) then
        begin
          Exit; //!!
        end;
      end;

      // now we have the list of all projectid's to syncronize
      for ii := 0 to slProjectIdList.Count-1 do
      begin
        ProjectID := StrToInt(slProjectIdList[ii]);

        SyncResult := internSyncOneProject( ProjectID
                                          , bUseCRC
                                          , bChangeROAttrib
                                          , SyncNoPrompt
                                          , bByLabel
                                          , sLabel
                                          , handleHiddenModules
                                          );

        if (SyncResult = srSynced) and bAllUpToDate then
          bAllUpToDate := False;
      end;

      if bExtExitCode and bAllUpToDate then
        ExtExitCode := ExitCodeAllUpToDate;
    finally
      slProjectIdList.Free;
    end;
  finally
    ProjectID := -1;
    ProjectName := '';
    SyncNoPrompt := False;
  end;
end;

function CmdProcSyncProjectGroup(const Line: string; var ExtExitCode: Integer): Boolean;
var
  Count: Integer;
  S: string;
  ProjectGroupID: Integer;
  ProjectGroupParentID: Integer;  
  ProjectGroupName: string;
  bUseCRC: Boolean;
  bChangeROAttrib : Boolean;
  GetProjectGroupInformation: TJVCSGetProjectGroupInformation;
  Projects: TList;
  I: Integer;
  bParamOk: Boolean;  
  slProjectIdList: TStringList;
  bWithCross: Boolean;
  bByLabel: Boolean;
  handleHiddenModules: THandleHiddenModules;
  sLabel: string;
  bExtExitCode, bAllUpToDate: Boolean;
  SyncResult: TSyncResult;

  procedure GetProjectGroupParent;
  var
    I: Integer;
  begin
    ProjectGroupParentID := -1;
    for I := 0 to GetProjectGroupInformation.OutputItemCount - 1 do
      with GetProjectGroupInformation.OutputItems[I] do
        if RecordType = 'g' then
        begin
          if (ProjectGroupID = -1) and (AnsiCompareStr(GroupName, ProjectGroupName) = 0) then
          begin
            ProjectGroupID := GroupID;
            ProjectGroupParentID := ParentID;
            ProjectGroupName := GroupName;
            Break;
          end
          else
          if GroupID = ProjectGroupID then
          begin
            ProjectGroupParentID := ParentID;
            ProjectGroupName := GroupName;
            Break;
          end;
        end;
  end;

  procedure WalkGroups(AParentID: Integer; AddMode: Boolean = False);
  var
    I, J, Index: Integer;
    Match: Boolean;
  begin
    for I := 0 to GetProjectGroupInformation.OutputItemCount - 1 do
      with GetProjectGroupInformation.OutputItems[I] do
      begin
        if (RecordType = 'g') and (ParentID = AParentID) then
        begin
          Match := GroupID = ProjectGroupID;
          if Match or AddMode then
            WalkGroups(GroupID, True);
        end
        else
        if (RecordType = 'p') and (GroupID = AParentID) and AddMode then
        begin
          Index := -1;
          for J := 0 to Projects.Count - 1 do
            if Integer(Projects[J]) = ParentID then
            begin
              Index := J;
              Break;
            end;
          if Index = -1 then
          begin
            Projects.Add(Pointer(ParentID));
            //Writeln(ParentID);
          end;
        end;
      end;
  end;

begin
  Result := False;

  bUseCRC := False;
  bChangeROAttrib := False;
  bWithCross := False;
  bByLabel := False;
  bExtExitCode := False;
  bAllUpToDate := True;
  handleHiddenModules := hmodIgnore;

  Count := LineParamCount(Line);
  if not (Count in [2..8]) then
    Exit;
  S := LineParamStr(Line, 2);
  ProjectGroupID := StrToIntDef(S, -1);
  if ProjectGroupID = -1 then
    ProjectGroupName := S;

  bParamOk := True;
  for I := 3 to Count do
  begin
    bParamOk := True;
    S := LineParamStr(Line, I);
    if AnsiCompareText(S, 'noprompt') = 0 then
      SyncNoPrompt := True
    else
    if AnsiCompareText(S, 'stamp') = 0 then
      bUseCRC := False
    else
    if AnsiCompareText(S, 'crc') = 0 then
      bUseCRC := True
    else
    if AnsiCompareText(S, 'readonly') = 0 then
      bChangeROAttrib := True
    else
    if AnsiCompareText(S, 'crossref') = 0 then
      bWithCross := True
    else
    if AnsiCompareText(S, 'includehidden') = 0 then
      handleHiddenModules := hmodInclude
    else
    if AnsiCompareText(S, 'deletehidden') = 0 then
      handleHiddenModules := hmodDelete
    else
    if AnsiCompareText(S, 'extexitcode') = 0 then
      bExtExitCode := True
    else
    if Pos('label=', AnsiLowerCase(S)) = 1 then
    begin
      bByLabel := True;
      sLabel := Copy(S, 7, Length(S) - 6);
    end
    else
      bParamOk := False;
    if not bParamOk then
      Break;
  end;

  if not bParamOk then
    Exit;

  try
    GetProjectGroupInformation := TJVCSGetProjectGroupInformation.Create(nil);
    try
      Connection.SendRequest(GetProjectGroupInformation);
      ShowLog(GetProjectGroupInformation);
      Projects := TList.Create;
      try
        GetProjectGroupParent;
        //0 is valid here!
        if ProjectGroupParentID < 0 then
        begin
          if ProjectGroupName <> '' then
            raise Exception.CreateFmt(SProjectGroupNotFound, [ProjectGroupName])
          else
            raise Exception.CreateFmt(SProjectGroupIDNotFound, [ProjectGroupID]);
        end
        else
        begin
          Writeln(Format('syncprojectgroup %d, %s', [ProjectGroupID, ProjectGroupName]));
          WalkGroups(ProjectGroupParentID);

          if bWithCross then
          begin
            slProjectIdList := TStringList.Create;
            try
              for I := 0 to Pred(Projects.Count) do
                if not internGetProjectCrossRef(Integer(Projects[I]), slProjectIdList) then
                begin
                  Exit; //!!
                end;
              for I := 0 to Pred(slProjectIdList.Count) do
                if Projects.IndexOf(Pointer(StrToInt(slProjectIdList[I]))) = -1 then
                  Projects.Add(Pointer(StrToInt(slProjectIdList[I])));
            finally
              slProjectIdList.Free;
            end;
          end;

          for I := 0 to Pred(Projects.Count) do
          begin
            SyncResult := internSyncOneProject( Integer(Projects[I])
                                              , bUseCRC
                                              , bChangeROAttrib
                                              , SyncNoPrompt
                                              , bByLabel
                                              , sLabel
                                              , handleHiddenModules
                                              );
              
            if (SyncResult = srSynced) and bAllUpToDate then
              bAllUpToDate := False;
          end;

          if bExtExitCode and bAllUpToDate then
            ExtExitCode := ExitCodeAllUpToDate;
        end;
      finally
        Projects.Free;
      end;

      Writeln;
      Result := True;
    finally
      GetProjectGroupInformation.Free;
    end;
  finally
    SyncNoPrompt := False;
  end;
end;

function internLabelProject(nProjectId: Integer; nLabelId: Integer): Boolean;
var
  I, Count: Integer;
  AddRemoveRevisionLabel: TJVCSAddRemoveRevisionLabel;
  GetLatestRevisions: TJVCSGetLatestRevisions;
begin
  ProjectID := nProjectId;
  ProjectName := '';

  CheckOpenProject;
  Writeln;
  Writeln(StrAlign(Format('labelproject %d, %s',[ProjectID, ProjectName]), 15+8+30));

  Count := 0;

  AddRemoveRevisionLabel := TJVCSAddRemoveRevisionLabel.Create(nil);
  try
    GetLatestRevisions := TJVCSGetLatestRevisions.Create(nil);
    try
      GetLatestRevisions.ProjectID := nProjectId;
      GetLatestRevisions.ExcludeHiddenModules := True;  //no hidden modules!
      GetLatestRevisions.LabelID := 0;
      Connection.SendRequest(GetLatestRevisions);
      for I := 0 to GetLatestRevisions.OutputItemCount - 1 do
      begin
        if (GetLatestRevisions.OutputItems[I].ModulePath <> '') and
          (GetLatestRevisions.OutputItems[I].ModuleName <> '') then
        begin
          with AddRemoveRevisionLabel do
          begin
            // Assign params for this module/revision
            AddLabel := True;
            ModuleID := GetLatestRevisions.OutputItems[I].ModuleID;
            RevisionID := GetLatestRevisions.OutputItems[I].RevisionID;
            LabelID := nLabelId;
            CheckOnly := False;
            Connection.SendRequest(AddRemoveRevisionLabel);

            if Count mod LinesPerPage = 0 then
            begin
              Writeln;
              Write(StrAlign('ModuleID',      8), ' ');
              Write(StrAlign('Module Name',   30), ' ');
              Write(StrAlign('Label',         30), ' ');
              Write(StrAlign('Vers./Rev.',    10), ' ');
              Write(StrAlign('Rev.Timestamp', 20), ' ');
              Write(StrAlign('Rev.CRC',       10), ' ');
              Writeln('Result');
              Write(StringOfChar('=', 8), ' ');
              Write(StringOfChar('=', 30), ' ');
              Write(StringOfChar('=', 30), ' ');
              Write(StringOfChar('=', 10), ' ');
              Write(StringOfChar('=', 20), ' ');
              Write(StringOfChar('=', 10), ' ');
              Writeln(StringOfChar('=', 6));
            end;

            with GetLatestRevisions.OutputItems[I] do
            begin
              Write(StrAlign(IntToStr(ModuleID),  8), ' ');
              Write(StrAlign(ModuleName,         30), ' ');
              Write(StrAlign(LabelParamName,      30), ' ');
              Write(StrAlign(IntToStr(Version)+'.'+IntToStr(Revision), 10), ' ');
              Write(StrAlign(FmtStamp(RevisionTimestamp), 20), ' ');
              Write(StrAlign(Format('$%.8x', [RevisionCRC32]), 10), ' ');
            end;
            // ADD_REMOVE_REVISION_LABEL never moves a label: when it already is on another revision
            // of the module the server answers LabelAdded = False with that revision (SrvOBJFeatures).
            if AddRemoveRevisionLabel.LabelAdded then
              Write('added')
            else
              Write(Format('kept %d.%d', [AddRemoveRevisionLabel.Version, AddRemoveRevisionLabel.Revision]));
            Writeln;
            Inc(Count);
          end;
        end;
      end;
      Result := True;
    finally
      GetLatestRevisions.Free;
    end;
  finally
    AddRemoveRevisionLabel.Free;
  end;
end;

function CmdProcLabelProject(const Line: string; var ExtExitCode: Integer): Boolean;
var
  I, ii, Count: Integer;
  S: string;
  bWithCross: Boolean;
  nLabelId: Integer;
  GetLabels: TJVCSGetLabels;
  AddUpdateLabel: TJVCSAddUpdateLabel;
  slProjectIdList: TStringList;
begin
  Result := False;
  nLabelId := -1;
  bWithCross := False;

  // resolve params
  Count := LineParamCount(Line);
  if not (Count in [3,4]) then
    Exit;
  S := LineParamStr(Line, 2);
  ProjectID := StrToIntDef(S, -1);
  if ProjectID = -1 then
    ProjectName := S;
  CheckOpenProject;

  if Count > 2 then //for further enhancement
  begin
    S := LineParamStr(Line, 3);
    if Trim(S) =  '' then
      Exit;
    LabelParamName := S;
  end;

  if Count = 4 then // crossref?
  begin
    S := LineParamStr(Line, 4);
    if AnsiCompareText(S, 'crossref') = 0 then
      bWithCross := True
    else
      Exit; //wrong param
  end;

  // Don't try-expect inside without changing repeat-until
  // otherwise endless loop possible
  repeat
    // now we should have (projectId | projectName) and LabelName, so lets start
    GetLabels := TJVCSGetLabels.Create(nil);
    try
      Connection.SendRequest(GetLabels);
      ShowLog(GetLabels);
      for I := 0 to GetLabels.OutputItemCount-1 do
      begin
        with GetLabels.OutputItems[I] do
        begin
          if AnsiCompareText(LabelName, LabelParamName) = 0 then
          begin
            nLabelId := GetLabels.OutputItems[I].LabelID;
            Break;
          end;
        end;
      end;
    finally
      GetLabels.Free;
    end;

    // IF label not exists => have to add label first
    if (nLabelId = -1) then
    begin
      AddUpdateLabel := TJVCSAddUpdateLabel.Create(nil);
      try
        AddUpdateLabel.LabelName := LabelParamName;
        AddUpdateLabel.Description := FormatDateTime('yyyy/mm/dd" - autocreated by jvcs-commandlineclient"', Date);
        Connection.SendRequest(AddUpdateLabel);
        Writeln;
        Write(StrAlign('New Label added:',         30), ' ');
        Write(StrAlign(LabelParamName,         30), ' ');
        Write(StrAlign(AddUpdateLabel.Description,         80), ' ');
      finally
        AddUpdateLabel.Free;
      end;
    end;
  until nLabelId <> -1;

  // IF valid label?
  if nLabelId <> -1 then
  begin
    slProjectIdList := TStringList.Create;
    try
      CheckOpenProject;
      // add root projectid
      slProjectIdList.Add(IntToStr(ProjectID));
      // IF label also crossref'd projects
      if bWithCross then
      begin
        // IF NOT get crossreferences
        if not internGetProjectCrossRef(ProjectID, slProjectIdList) then
        begin
          Exit; //!!!
        end;
      end;

      // now we have the list of all projectid's to label
      for ii := 0 to slProjectIdList.Count-1 do
      begin
        ProjectID := StrToInt(slProjectIdList[ii]);
        if not internLabelProject(ProjectID, nLabelId) then
        begin
          Exit; //!!!
        end;
      end;
      Result := True;
    finally
      slProjectIdList.Free;
    end;
  end;
end;

function CmdProcUndoCheckout(const Line: string; var ExtExitCode: Integer): Boolean;
var
  Count, I, J: Integer;
  S: string;
  UndoCheckoutModule: TJVCSUndoCheckoutModule;
  GetLatestRevisions: TJVCSGetLatestRevisions;
  LatestRevision: TGetLatestRevisionsOutputItem;
  GetCheckoutModule: TJVCSGetCheckoutModule;
  ModuleFilesAreDirty: Boolean;
  FileNoPrompt, OverwriteFileOK: Boolean;
begin
  Result := False;
  ModuleID := -1;
  ModuleName := '';
  FileNoPrompt := False;

  Count := LineParamCount(Line);
  if Count in [2,3] then
  begin
    S := LineParamStr(Line, 2);
    if Count = 3 then
      if SameText(LineParamStr(Line, 3), 'noprompt') then
        SyncNoPrompt := True;
    ModuleID := StrToIntDef(S, -1);
    if ModuleID = -1 then
      ModuleName := S;
    try
      CheckOpenProject;
      CheckModuleOrLocalFile;
      // undo checkout
      UndoCheckoutModule := TJVCSUndoCheckoutModule.Create(nil);
      try
        UndoCheckoutModule.ProjectID := ProjectID;
        UndoCheckoutModule.UserID := Connection.UserID;
        UndoCheckoutModule.ModuleID := ModuleID;
        UndoCheckoutModule.ModuleName := ModuleName;
        Connection.SendRequest(UndoCheckoutModule);
        ShowLog(UndoCheckoutModule);
      finally
        UndoCheckoutModule.Free;
      end;

      GetLatestRevisions := TJVCSGetLatestRevisions.Create(nil);
      try
        GetLatestRevisions.ProjectID := ProjectID;
        GetLatestRevisions.ExcludeHiddenModules := False;
        GetLatestRevisions.LabelID := 0;
        Connection.SendRequest(GetLatestRevisions);
        ShowLog(GetLatestRevisions);

        I := 0;
        while I < GetLatestRevisions.OutputItemCount do
        begin
          ModuleFilesAreDirty := False;
          if (GetLatestRevisions.OutputItems[I].ModuleID = ModuleID) and
            (GetLatestRevisions.OutputItems[I].ModulePath <> '') and
            (GetLatestRevisions.OutputItems[I].ModuleName <> '') then
          begin
            LatestRevision := GetLatestRevisions.OutputItems[I];
            // check if one or more module files are dirty
            for J := 0 to GetLatestRevisions.OutputItemCount - 1 do
              with GetLatestRevisions.OutputItems[J] do
                if (ModuleID = LatestRevision.ModuleID) then
                begin
                  if (ModulePath = '') and (ModuleName = '') then
                    S := ChangeFileExt(PathAddSeparator(LatestRevision.ModulePath) +
                      LatestRevision.ModuleName, RevisionExtension)
                  else
                    S := ChangeFileExt(PathAddSeparator(ModulePath) + ModuleName, RevisionExtension);

                  if FileExists(S) then
                    ModuleFilesAreDirty := IsFileDirty(S, RevisionTimestamp) or IsFileDirtyCRC(S, RevisionCRC32)
                  else
                    ModuleFilesAreDirty := True;

                  if ModuleFilesAreDirty then
                    Break;
                end;
            if ModuleFilesAreDirty then // module files dirty: GET_CHECKOUT_MODULE
            begin
              GetCheckoutModule := TJVCSGetCheckoutModule.Create(nil);
              try
                GetCheckoutModule.ProjectID := ProjectID;
                GetCheckoutModule.UserID := Connection.UserID;
                GetCheckoutModule.ModuleID := LatestRevision.ModuleID;
                GetCheckoutModule.RevisionID := LatestRevision.RevisionID;
                GetCheckoutModule.CheckOut := False;
                with LatestRevision do
                  S := ChangeFileExt(PathAddSeparator(ModulePath) + ModuleName, RevisionExtension);
                GetCheckoutModule.ModuleName := S;
                Connection.SendRequest(GetCheckoutModule);
                ShowLog(GetCheckoutModule);
                for J := 0 to GetCheckoutModule.OutputItemCount - 1 do
                  with GetCheckoutModule.OutputItems[J] do
                  begin
                    with LatestRevision do
                      S := Trim(ChangeFileExt(PathAddSeparator(ModulePath) + ModuleName, ModuleExtension));

                    if FileExists(S) then
                    begin
                      if IsFileDirty(S, ModuleOriginalTime) or IsFileDirtyCRC(S, ModuleOriginalCRC) then
                      begin
                        if SyncNoPrompt or FileNoPrompt then
                          OverwriteFileOK := True
                        else
                        begin
                          OverwriteFileOK := False;
                          case Prompt(Format(SOverwriteFile, [S]), OptionsYesNoAllBreak) of
                            0:
                              OverwriteFileOK := True;
                            2:
                              begin
                                OverwriteFileOK := True;
                                FileNoPrompt := True;
                              end;
                            3:
                              Break;
                          end;
                        end;
                      end
                      else
                        OverwriteFileOK := False;
                    end
                    else
                      OverwriteFileOK := True;

                    if OverwriteFileOK then
                    begin
                      GetCheckoutModule.ExtractBlobToFile(S, ModuleBinary);
                      FileSetReadOnlyAttribute(S, False);
                      //THu be aware if server/client live in different timezones !
                      //CSchuette, 29.03.2005: fix problem with UTC timestamps
                      FileSetUTCDateTime(S, ModuleOriginalTime);
                    end;
                  end;
              finally
                GetCheckoutModule.Free;
              end;
              Break;
            end;

            // set all files read-only after undo checkout
            for J := 0 to GetLatestRevisions.OutputItemCount - 1 do
              with GetLatestRevisions.OutputItems[J] do
                if (ModuleID = LatestRevision.ModuleID) then
                begin
                  if (ModulePath = '') and (ModuleName = '') then
                    S := ChangeFileExt(PathAddSeparator(LatestRevision.ModulePath) +
                      LatestRevision.ModuleName, RevisionExtension)
                  else
                    S := ChangeFileExt(PathAddSeparator(ModulePath) + ModuleName, RevisionExtension);

                  if not IsFileTypeAlwaysWritable(RevisionExtension) then
                    FileSetReadOnlyAttribute(S, True);
                end;
          end;
          Inc(I);
        end;

        ListModule(ProjectID, ModuleID);

        Writeln;
        Result := True;
      finally
        GetLatestRevisions.Free;
      end;
    finally
      ModuleID := -1;
      ModuleName := '';
      SyncNoPrompt := False;
    end;
  end;
end;


//@@@ thu put above new cmd's

function FmtStamp(DateTime: TDateTime): string;
begin
  Result := FormatDateTime('dd.mm.yyyy hh:nn:ss', DateTime);
end;

// GetParamStr copied from System (not exposed in interface section)
function GetParamStr(P: PChar; var Param: string): PChar;
var
  I, Len: Integer;
  Start, S, Q: PChar;
begin
  while True do
  begin
    while (P[0] <> #0) and (P[0] <= ' ') do
      P := CharNext(P);
    if (P[0] = '"') and (P[1] = '"') then Inc(P, 2) else Break;
  end;
  Len := 0;
  Start := P;
  while P[0] > ' ' do
  begin
    if P[0] = '"' then
    begin
      P := CharNext(P);
      while (P[0] <> #0) and (P[0] <> '"') do
      begin
        Q := CharNext(P);
        Inc(Len, Q - P);
        P := Q;
      end;
      if P[0] <> #0 then
        P := CharNext(P);
    end
    else
    begin
      Q := CharNext(P);
      Inc(Len, Q - P);
      P := Q;
    end;
  end;

  SetLength(Param, Len);

  P := Start;
  S := Pointer(Param);
  I := 0;
  while P[0] > ' ' do
  begin
    if P[0] = '"' then
    begin
      P := CharNext(P);
      while (P[0] <> #0) and (P[0] <> '"') do
      begin
        Q := CharNext(P);
        while P < Q do
        begin
          S[I] := P^;
          Inc(P);
          Inc(I);
        end;
      end;
      if P[0] <> #0 then P := CharNext(P);
    end
    else
    begin
      Q := CharNext(P);
      while P < Q do
      begin
        S[I] := P^;
        Inc(P);
        Inc(I);
      end;
    end;
  end;

  Result := P;
end;

function HowIsFileDirty(const FileName: string; RefStamp: TDateTime): string;
begin
{//USc 13.12.2003 old version
  Result := IndicatorFileStrings[1];
  if FileExists(FileName) then
  begin
    //THu be aware if server/client live in different timezones !
		if Abs(LocalDT2GMTDT(FileDateToDateTime(FileAge(FileName))) - RefStamp) > cTimeConvErr
    then begin
			if LocalDT2GMTDT(FileDateToDateTime(FileAge(FileName))) > RefStamp then
        Result := IndicatorFileStrings[2]
      else Result := IndicatorFileStrings[3];
    end;
  end;
}
  case CompareFileTimeStamp(FileName, RefStamp) of
    cmptsresNewer: Result := IndicatorFileStrings[2];
    cmptsresOlder: Result := IndicatorFileStrings[3];
    else
      Result := IndicatorFileStrings[1];
  end;
end;

(* there is a better function in JVCSClientFunctions
function IsFileTypeAlwaysWritable(const FileExt: string): Boolean;
const
  WritableExts: array [0..4] of string = ('.dpr', '.dpk', '.dof', '.cfg', '.res');
var
  I: Integer;
begin
  Result := False;
  for I := Low(WritableExts) to High(WritableExts) do
    if StrLIComp(PChar(FileExt), PChar(WritableExts[I]), Length(WritableExts[I])) = 0 then
    begin
      Result := True;
      Break;
    end;
end;
*)

// similar to System.ParamCount except it takes Line parameter instead of command line
// there is no parameter with index 0
function LineParamCount(const Line: string): Integer;
var
  P: PChar;
  S: string;
begin
  Result := 0;
  P := PChar(Line);
  while True do
  begin
    P := GetParamStr(P, S);
    if S = '' then
      Break;
    Inc(Result);
  end;
end;

// similar to System.ParamStr except it takes Line parameter instead of command line
function LineParamStr(const Line: string; Index: Integer): string;
var
  P: PChar;
begin
  Result := '';
  if Index > 0 then // LineParamStr(0) doesn't make sense
  begin
    P := PChar(Line);
    while True do
    begin
      P := GetParamStr(P, Result);
      Dec(Index);
      if (Index = 0) or (Result = '') then
        Break;
    end;
  end;
end;

procedure ListModule(ProjectID, ModuleID: Integer);
var
  LatestRevision: TGetRevisionListByIdOutputItem;
  GetRevisionListById: TJVCSGetRevisionListById;
  GetRevisionStatus: TJVCSGetRevisionStatus;
  I: Integer;
  ModuleFileName: string;
begin
  FillChar(LatestRevision, SizeOf(TGetRevisionListByIdOutputItem), 0);
  GetRevisionListById := TJVCSGetRevisionListById.Create(nil);
  try
    GetRevisionListById.ProjectID := 0; // ProjectID has to be 0!
    GetRevisionListById.ModuleID := ModuleID;
    Connection.SendRequest(GetRevisionListById);
    ShowLog(GetRevisionListById);
    if GetRevisionListById.OutputItemCount = 0 then
      raise Exception.CreateFmt(SModuleNoRevisions, [ModuleID, ModuleName]);
    for I := 0 to GetRevisionListById.OutputItemCount - 1 do
      with GetRevisionListById.OutputItems[I] do
      begin
        LatestRevision.ModuleID := ModuleID;
        if (ModuleName <> '') then
          LatestRevision.ModuleName := ModuleName;
        if (ModulePath <> '') then
          LatestRevision.ModulePath := ModulePath;
        LatestRevision.CheckedOut := CheckedOut;
        LatestRevision.Timestamp := Timestamp;
        LatestRevision.UserID := UserID;
        if (Version > LatestRevision.Version) or ((Version = LatestRevision.Version) and
          (Revision >= LatestRevision.Revision)) then
        begin
          LatestRevision.RevisionID := RevisionID;
          LatestRevision.Version := Version;
          LatestRevision.Revision := Revision;
        end;
        LatestRevision.Owner := Owner;
        LatestRevision.ProjectID := ProjectID;
        LatestRevision.Hidden := Hidden;
      end;
  finally
    GetRevisionListById.Free;
  end;
  GetRevisionStatus := TJVCSGetRevisionStatus.Create(nil);
  try
    GetRevisionStatus.RevisionID := LatestRevision.RevisionID;
    Connection.SendRequest(GetRevisionStatus);
    ShowLog(GetRevisionStatus);
    for I := 0 to GetRevisionStatus.OutputItemCount - 1 do
      with GetRevisionStatus.OutputItems[I] do
      begin
        ModuleFileName := ChangeFileExt(PathAddSeparator(ModulePath) + ModuleName, RevisionExtension);

        if I mod LinesPerPage = 0 then
        begin
          Writeln;
          Write(StrAlign('ID', 8), ' ');
          Write(StrAlign('File Path', 50), ' ');
          Write(StrAlign('File Name', 30), ' ');
          Write(StrAlign('Version', 7), ' ');
          Write(StrAlign('Out', 3), ' ');
          Write(StrAlign('Owner', 20), ' ');
          Write(StrAlign('Hid', 3), ' ');
          Write(StrAlign('Stamp', 5), ' ');
          Write(StrAlign('CRC', 5), ' ');
          Writeln;
          Write(StringOfChar('=', 8), ' ');
          Write(StringOfChar('=', 50), ' ');
          Write(StringOfChar('=', 30), ' ');
          Write(StringOfChar('=', 7), ' ');
          Write(StringOfChar('=', 3), ' ');
          Write(StringOfChar('=', 20), ' ');
          Write(StringOfChar('=', 3), ' ');
          Write(StringOfChar('=', 5), ' ');
          Write(StringOfChar('=', 5), ' ');
          Writeln;
        end;
        Write(StrAlign(IntToStr(ModuleID), 8), ' ');
        Write(StrAlign(ExtractFilePath(ModuleFileName), 50), ' ');
        Write(StrAlign(ExtractFileName(ModuleFileName), 30), ' ');
        with LatestRevision do
        begin
          Write(StrAlign(Format('%d.%d', [Version, Revision]), 7), ' ');
          Write(StrAlign(IndicatorStrings[CheckedOut], 3), ' ');
          Write(StrAlign(Owner, 20), ' ');
          Write(StrAlign(IndicatorStrings[Hidden], 3), ' ');

          if FileExists(ModuleFileName) then
          begin
            Write(StrAlign(IndicatorStrings[IsFileDirty(ModuleFileName, RevisionOriginalTime)], 5), ' ');
            Write(StrAlign(IndicatorStrings[IsFileDirtyCRC(ModuleFileName, RevisionOriginalCRC)], 5), ' ');
          end
          else
          begin
            Write(StrAlign('N/A', 5), ' ');
            Write(StrAlign('N/A', 5), ' ');
          end;
        end;
        Writeln;
      end;
  finally
    GetRevisionStatus.Free;
  end;
end;

function PadR(const S: string; Length: Integer; Ch: Char = ' '): string;
begin
  Result := StringOfChar(Ch, Length);
  StrLCopy(PChar(Result), PChar(S), Length);
end;

procedure ProcessLine(const Line: string);
var
  Count, I, CmdIndex: Integer;
  S: string;
begin
  Count := LineParamCount(Line);
  if Count > 0 then
  begin
    S := LineParamStr(Line, 1);
    CmdIndex := -1;
    for I := Low(Commands) to High(Commands) do
      with Commands[I] do
        if AnsiCompareText(S, Name) = 0 then
        begin
          CmdIndex := I;
          Break;
        end;
    if CmdIndex = -1 then
      raise Exception.CreateFmt(SUnknownCommand, [S]);

    with Commands[CmdIndex] do
      if Assigned(Proc) and not TCommandProc(Proc)(Line, ExCode) then
      begin
        Writeln;
        Writeln(Syntax);
        Writeln;
        Writeln(HelpText);
        Writeln;
      end;
  end;
end;

function Prompt(const Text: string; const Options: array of TPromptOption): Integer;
var
  StdIn, StdOut: THandle;
  ConsoleMode: Cardinal;
  C: Char;
  CharsRead, CharsWritten: Cardinal;
  ScreenBufferInfo: TConsoleScreenBufferInfo;
  CursorPos: TCoord;
  I, Index, SelectedIndex: Integer;
  S: string;
begin
  Result := -1;
  if Length(Options) = 0 then
    Exit;

  StdIn := GetStdHandle(STD_INPUT_HANDLE);
  StdOut := GetStdHandle(STD_OUTPUT_HANDLE);
  Win32Check(GetConsoleMode(StdIn, ConsoleMode));
  Win32Check(SetConsoleMode(StdIn, ConsoleMode and not ENABLE_ECHO_INPUT and not ENABLE_LINE_INPUT));
  try
    Write(Text, ' ', '[');
    S := '';
    for I := Low(Options) to High(Options) do
    begin
      if S <> '' then
        S := S + '/';
      S := S + Options[I].Text;
    end;
    Write(S, '] ');
    Win32Check(GetConsoleScreenBufferInfo(StdOut, ScreenBufferInfo));
    CursorPos := ScreenBufferInfo.dwCursorPosition;
    C := Options[0].AccelChar;
    SelectedIndex := 0;
    Write(C);
    SetConsoleCursorPosition(StdOut, CursorPos);

    while ReadConsole(StdIn, @C, 1, CharsRead, nil) and (CharsRead = 1) do
    begin
      case C of
        #10, #13:
          begin
            // clear the prompt line
            S := StringOfChar(' ', CursorPos.X + 1);
            CursorPos.X := 0;
            WriteConsoleOutputCharacter(StdOut, @S[1], Length(S), CursorPos, CharsWritten);
            SetConsoleCursorPosition(StdOut, CursorPos);
            Break;
          end;
        else
        begin
          Index := -1;
          for I := Low(Options) to High(Options) do
            if UpCase(Options[I].AccelChar) = UpCase(C) then
            begin
              Index := I;
              Break;
            end;
          if Index <> -1 then
          begin
            SelectedIndex := Index;
            if SetConsoleCursorPosition(StdOut, CursorPos) then
            begin
              C := UpCase(C);
              WriteConsoleOutputCharacter(StdOut, @C, 1, CursorPos, CharsWritten);
            end;
            SetConsoleCursorPosition(StdOut, CursorPos);
          end;
        end;
      end;
    end;
    Result := SelectedIndex;
  finally
    SetConsoleMode(StdIn, ConsoleMode);
  end;
end;

// ReadPassword will only work if stdin is not redirected
function ReadPassword: string;
var
  StdIn, StdOut: THandle;
  ConsoleMode: Cardinal;
  C: Char;
  CharsRead, CharsWritten: Cardinal;
  ScreenBufferInfo: TConsoleScreenBufferInfo;
begin
  Result := '';

  StdIn := GetStdHandle(STD_INPUT_HANDLE);
  StdOut := GetStdHandle(STD_OUTPUT_HANDLE);
  Win32Check(GetConsoleMode(StdIn, ConsoleMode));
  Win32Check(SetConsoleMode(StdIn, ConsoleMode and not ENABLE_ECHO_INPUT and not ENABLE_LINE_INPUT));
  try
    while ReadConsole(StdIn, @C, 1, CharsRead, nil) and (CharsRead = 1) do
    begin
      case C of
        #8:
          if Length(Result) > 0 then
          begin
            Delete(Result, Length(Result), 1);
            // erase last character from screen
            if GetConsoleScreenBufferInfo(StdOut, ScreenBufferInfo) then
            begin
              Dec(ScreenBufferInfo.dwCursorPosition.X);
              if SetConsoleCursorPosition(StdOut, ScreenBufferInfo.dwCursorPosition) then
                WriteConsoleOutputCharacter(StdOut, ' ', 1, ScreenBufferInfo.dwCursorPosition, CharsWritten);
              SetConsoleCursorPosition(StdIn, ScreenBufferInfo.dwCursorPosition);
            end;
          end;
        #10, #13:
          begin
            Writeln;
            Break;
          end;
        else
          begin
            Result := Result + C;
            C := '*';
            WriteConsole(StdOut, @C, 1, CharsWritten, nil);
          end;
      end;
    end;
  finally
    SetConsoleMode(StdIn, ConsoleMode);
  end;
end;

procedure RunInteractiveSession;
var
  Line: string;
  S: string;
begin
  ExitSession := False;
  while not ExitSession do
  begin
    try
      Write(JVCSPrompt);
      Readln(Line);
      S := LineParamStr(Line, 1);
      if AnsiCompareText(S, 'exit') = 0 then
        Break;
      ProcessLine(Line);
    except
      on E: Exception do
        if not (E is EAbort) then
        begin
          Writeln('[', E.ClassName, '] ', E.Message);
          Writeln;
        end;
    end;
  end;
end;

{$IFDEF BRANCHING}
procedure SelectBranchByName(const ABranchName: string);
var
  GetBranchList: TJVCSGetBranchList;
  SelectBranch: TJVCSSelectBranch;
  I, BranchID: Integer;
begin
  if Assigned(Connection) then
  begin
    BranchID := 0;
    GetBranchList := TJVCSGetBranchList.Create(nil);
    try
      GetBranchList.IncludeDetails := False;
      Connection.SendRequest(GetBranchList);
      for I := 0 to Pred(GetBranchList.OutputItemCount) do
        if GetBranchList.OutputItems[I].Name = ABranchName then
        begin
          BranchID := GetBranchList.OutputItems[I].BranchID;
          Break;
        end;
    finally
      GetBranchList.Free;
    end;
    if BranchID = 0 then
      raise Exception.CreateFmt('Branch ''%s'' not found', [ABranchName])
    else
    begin
      SelectBranch := TJVCSSelectBranch.Create(nil);
      try
        SelectBranch.BranchID := BranchID;
        Connection.SendRequest(SelectBranch);
        if not SelectBranch.BranchFound then
          raise Exception.CreateFmt('Branch ''%s'' not found', [ABranchName])
      finally
        SelectBranch.Free;
      end;
    end;
  end;
end;
{$ENDIF BRANCHING}

procedure ShowBanner;
var
  VersionInfo: TJclFileVersionInfo;
  ILKind: TJVCSInternetLinkKind;
  MaxLinkDescriptionLength: Integer;
  CurrentLinkDescription, CurrentLink: string;
begin
  VersionInfo := TJclFileVersionInfo.Create(ParamStr(0));
  try
    with VersionInfo do
      // v2026: "JEDI VCS console client 2.5.0 Beta 5 - build 2050 (...)" (InternalVersion
      // + build do FILEVERSION; ASCII: a console nao tem o travessao)
      Writeln(FileDescription, ' ', JVCSVersionLabel(ParamStr(0)), ' (', CompanyName, ')');
      // JVCS 2026: exigido pela licenca do MidWare (clausula 2)
      Writeln('This product is based on MidWare. Freeware source code is available at http://www.overbyte.be.');
      Writeln;
{     //USc 24.01.2004 now the values from VCSCommon will be used
      Writeln(#9+SInfoLinkSF);
      Writeln(#9+SInfoLinkWeb);
      Writeln(#9+SInfoLinkNews);
      Writeln(#9+SInfoLinkMantis);
}
      MaxLinkDescriptionLength := 0;
      for ILKind := Low(TJVCSInternetLinkKind) to High(TJVCSInternetLinkKind) do
      begin
        CurrentLinkDescription := GetJVCSInternetLinkDescription(ILKind);
        if Length(CurrentLinkDescription) > MaxLinkDescriptionLength then
          MaxLinkDescriptionLength := Length(CurrentLinkDescription);
      end;
      for ILKind := Low(TJVCSInternetLinkKind) to High(TJVCSInternetLinkKind) do
      begin
        CurrentLinkDescription := GetJVCSInternetLinkDescription(ILKind);
        CurrentLink := Format('%s%s: %s', [CurrentLinkDescription,
          StringOfChar(' ', MaxLinkDescriptionLength - Length(CurrentLinkDescription)),
          GetJVCSInternetLink(ILKind)]);
        Writeln(#9 + CurrentLink);
      end;
      {$IFDEF BETA}
      Writeln;
      Writeln(SBetaVersion);
      {$ENDIF BETA}
  finally
    VersionInfo.Free;
  end;
end;

procedure ShowCommand(Index: Integer);
begin
  if (Index < Low(Commands)) or (Index > High(Commands)) then
    Exit;
  with Commands[Index] do
  begin
    Writeln;
    Writeln(Syntax);
    Writeln;
    Writeln(HelpText);
    Writeln;
  end;
end;

procedure ShowCommands;
var
  I: Integer;
  SortedCommands: TStringList;
begin
  Writeln;
  Writeln('Available commands:');
  Writeln;
  SortedCommands := TStringList.Create;
  try
    SortedCommands.Sorted := True;
    for I := Low(Commands) to High(Commands) do
      SortedCommands.AddObject(Commands[I].Name, TObject(I));
    for I := 0 to SortedCommands.Count - 1 do
      with Commands[Integer(SortedCommands.Objects[I])] do
        Writeln(Syntax);
    Writeln;
  finally
    SortedCommands.Free;
  end;
end;

procedure ShowLog(JVCSClientObject: TJVCSClientObject);
{$IFDEF DEBUG}
var
  Strings: TStringList;
{$ENDIF DEBUG}
begin
{$IFDEF DEBUG}
  Strings := TStringList.Create;
  try
    //Writeln;
    OutputDebugString(#13#10);
    //Writeln(JVCSClientObject.FunctionCode);
    OutputDebugString(PChar(JVCSClientObject.FunctionCode + #13#10));
    JVCSClientObject.LogResults(Strings);
    //Write(Strings.Text);
    OutputDebugString(PChar(Strings.Text));
  finally
    Strings.Free;
  end;
{$ENDIF DEBUG}
end;

procedure ShowUsage;
var
  I: Integer;
  SortedCommands: TStringList;
begin
  Writeln;
  Writeln('Usage:');
  Writeln('jvcs [<server>[:<port>]] [<login_params>] [<action> [<action_params>]] [<options>]');
  Writeln('<login_params>:');
  Writeln('  -user <user_name>');
  Writeln('  -password <password>');
  {$IFDEF BRANCHING}
  Writeln('  -branch <branch_name>');
  {$ENDIF BRANCHING}
  Writeln('<action>:');
  SortedCommands := TStringList.Create;
  try
    SortedCommands.Sorted := True;
    for I := Low(Commands) to High(Commands) do
      SortedCommands.AddObject(Commands[I].Name, TObject(I));
    for I := 0 to SortedCommands.Count - 1 do
      with Commands[Integer(SortedCommands.Objects[I])] do
        Writeln('  -', Syntax);
  finally
    SortedCommands.Free;
  end;
  Writeln;
end;

function StrAlign(const S: string; Width: Integer; PadChar: Char = ' '): string;
begin
  Result := StringOfChar(PadChar, Width);
  StrLCopy(PChar(Result), PChar(S), Width);
  if Length(S) > Width then
    StrCopy(@Result[Width - 2], '...');
end;

function TrimLines(const Text: string; Chars: Integer): string;
var
  TrimPos: Integer;
begin
  Result := '';
  if Text = '' then
    Exit;

  TrimPos := Pos(sLineBreak, Text);
  if (TrimPos = 0) or (TrimPos > Chars) then
    TrimPos := Chars;
  Result := Copy(Text, 1, TrimPos);
  if TrimPos < Length(Text) then
    StrCopy(@Result[Length(Result) - 2], '...');
end;


{.$R *.RES}
{$R jvcsver.res}

begin
  try
    // JVCS 2026: os textos trafegam em bytes da code page do protocolo (1252,
    // como o cliente Delphi 2007). Os registros do nucleo usam ShortString, cuja
    // conversao implicita segue DefaultSystemCodePage: alinhar as duas.
    DefaultSystemCodePage := MWCodePage;
    SetConsoleTitle('JEDI VCS console client');
    ShowBanner;
    CheckRequiredLibs;
    // GetConsoleMode will fail if stdin redirected
    StdInRedirected := not GetConsoleMode(GetStdHandle(STD_INPUT_HANDLE), ConsoleMode);
    if not CheckCommandLine then
    begin
      ExCode := ExitCodeInvalidParams;
      ShowUsage;
      Abort;
    end;
    if Server = '' then
    begin
      if not StdInRedirected then
        Write('Server: ');
      Readln(Server);
      if Pos(':', Server) <> 0 then
      begin
        Port := Copy(Server, Pos(':', Server) + 1, Length(Server));
        Delete(Server, Pos(':', Server), Length(Server));
      end;
      if Server = '' then
        Server := 'localhost';
    end;
    if Port = '' then
      Port := '2106';
    if UserName = '' then
    begin
      if not StdInRedirected then
        Write('User name: ');
      Readln(UserName);
    end;
    if Password = '' then
    begin
      if StdInRedirected then
        Readln(Password)
      else
      begin
        Write('Password: ');
        Password := ReadPassword;
      end;
    end;

    Connection := TJVCSConnection.Create(nil);
    try
      Connection.Server := Server;
      Connection.Port := Port;
      Connection.UserName := UserName;
      Connection.UserPassword := Password;
      Connection.Active := True;

      with Connection do
      begin
        if (ServerType <> '') then
        begin
          Writeln;
          Write('JEDI VCS Server: ', ServerType, ' v.', ServerVersion);
        end;
        if LoginMessage <> '' then
        begin
          Writeln;
          Writeln(LoginMessage);
        end;
        {$IFDEF BRANCHING}
        if BranchName <> '' then
        begin
          SelectBranchByName(BranchName);
          Writeln('Branch: ', BranchName);
        end
        else
          Writeln('Branch: HEAD');        
        {$ENDIF BRANCHING}
        Writeln;
      end;

      if CommandLine = '' then
        RunInteractiveSession
      else
        ProcessLine(CommandLine);
    finally
      Connection.Active := False;
      Connection.Free;
    end;

    { ESasse
      * By default ExCode is ExitCodeUnspecified when no error happened, so if
        it is different, the ExCode must be returned }

    if ExCode <> ExitCodeUnspecified then
      Halt(ExCode);
  except
    on E: Exception do
    begin
      if not (E is EAbort) then
        Writeln('[', E.ClassName, '] ', E.Message);
      Halt(ExCode);
    end;
  end;
end.
