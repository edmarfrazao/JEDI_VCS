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
    FastMM4 in '..\comp\fastmm\FastMM4.pas'
  , SysUtils
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
  , VCSCommon in '..\common\VCSCommon.pas';

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
procedure CheckOpenProject; forward;
procedure CheckRequiredLibs; forward;
function CheckGetLabelID(const ALabel: string): Integer; forward;

function CmdProcOpenProject(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcCheckinModule(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcCheckoutModule(const Line: string; var ExtExitCode: Integer): Boolean; forward;
function CmdProcExit(const Line: string; var ExtExitCode: Integer): Boolean; forward;
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

  Commands: array [0.. {$IFDEF BRANCHING} 15 {$ELSE} 14 {$ENDIF}] of TCommand = (

    (
      Name: 'openproject';
      Syntax: 'openproject <project_name> | <project_id>';
      HelpText: 'Opens a project for further processing, usefull if working with input files.';
      Proc: @CmdProcOpenProject),
    (
      Name: 'checkin';
      Syntax: 'checkin <module_name> | <module_id> [<comment>]';
      HelpText: 'Check in the specified module. A project containing the module is assumed to be already open.';
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
      Name: 'labelproject';
      Syntax: 'labelproject <project_name> | <project_id> <"label"> [crossref]';
      HelpText: 'Stamp project with given label.' + sLineBreak +
        'Label will be created, if not existing, if label contains spaces, enclose with double quotes.';
      Proc: @CmdProcLabelProject),

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
begin
  Result := False;
  ModuleID := -1;
  ModuleName := '';
  Count := LineParamCount(Line);
  if (Count in [2, 3]) then
  begin
    S := LineParamStr(Line, 2);
    ModuleID := StrToIntDef(S, -1);
    if ModuleID = -1 then
      ModuleName := S;
    try
      CheckOpenProject;
      CheckModule;
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
      {  //thu 30.10.2003 #1159
      // make sure the module is locked by the current user
      if not LatestRevision.CheckedOut then
        raise Exception.CreateFmt(SModuleNotCheckedOut, [ModuleID, ModuleName]);
      if (LatestRevision.UserID <> Connection.UserID) or (LatestRevision.Owner <> Connection.UserName) then
        raise Exception.CreateFmt(SModuleLocked, [ModuleID, ModuleName, LatestRevision.Owner]);
       }
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
            CheckinModule.PutOnly := False;
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
                ModuleOriginalCRC  := StrToInt(CRCString(ModuleFileName));
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
            if CheckinModule.ErrorMessage = '' then
            begin
              // now set file readonly
              SetVCSReadOnlyFile(ModuleName, FamilyExtensions);
            end;

            ShowLog(CheckinModule);
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
  // change max if params are added!
  if (Count in [2..4]) then
  begin
    S := LineParamStr(Line, 2);
    ModuleID := StrToIntDef(S, -1);
    if ModuleID = -1 then
      ModuleName := S;
    try
      CheckOpenProject;
      CheckModule;

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
              S := ChangeFileExt(PathAddSeparator(sDestPath) + WantedRevision.ModuleName, ModuleExtension)
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
      CheckModule;
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
              Write(StrAlign('Rev.CRC',       10));
              Writeln;
              Write(StringOfChar('=', 8), ' ');
              Write(StringOfChar('=', 30), ' ');
              Write(StringOfChar('=', 30), ' ');
              Write(StringOfChar('=', 10), ' ');
              Write(StringOfChar('=', 20), ' ');
              Write(StringOfChar('=', 10));
              Writeln;
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
      CheckModule;
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
      Writeln(FileDescription, ' ', FileVersion, ' (', CompanyName, ')');
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
