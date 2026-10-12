(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: VCSBase.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS: Thomas Huber (Thomas_D_Huber@t-online.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
- more clean up necessary
- Load FVCSCrypt only once jvcsconnect
- add migration function for config folder from program files to appfolder
  in initialization  
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FreeVCS code to JEDI VCS
2003/03/04  THensle   - change to use only one RegKey ('Software\JEDI\JEDIVCS')
                        for all installations from now on. After all, it isn't a
                        good practice to use Delphis own Reg tree...
                        (you can still change this in Options)
                      - changed some subkeys
2003/04/08  USchuster - changes for IDEInterface
2003/10/05  THuber    - compiler hints & warnings
2003/10/17  USchuster - added constant for messagebox caption
2003/12/27  THuber    - verconst.inc removed and should not be used any more
                      - const for time conversion rounding issue now only in
                        JVCSClientConsts
                      - cVCSCryptName removed, see JVCSClientConsts
2004/03/14  USchuster - added constants for external files
                      - minor style cleaning (casing and comments)
2004/04/14  USchuster - changed extensions of external files from .fvc to .jvcs
                      - added .jvcs to different extension lists
2004/06/28  THuber    - for #1289: #1289 new var for server version
2005/01/06  THuber    #1704 - new var for handling of delted project

^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC1 was released ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

2005/02/27  THuber    - removed sAppDirectory for IDE detection
                      - year in copyright changed to 2005
^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC3 was released ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
2006/01/01  USchuster - changes for more flexible shortcuts (mantis #3397)
                      - year in copyright changed to 2006
2006/01/20  THuber    #3220, #3449 .bdsproj added to always writable extensions,
                      - minor changes in extensions (still unfinished)
                      - .bat,.cmd added to textfiles to avoid run through F2
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 final released ^^^^^^^^^^^^^^^^^^^^^^^^^^
2006/03/26  USchuster - fixed default value for Delphi Modules (mantis #3539)
2006/04/30  THuber    #3611 new var for config files (.snm,.tlg,.bkp,.pcf,.sdl) folder
                            and removed constant for part of this directory
2006/06/28  USchuster - first changes for branching
2007/04/27  USchuster - changes for D2007
                      - removed .bdsproj from keyword expansion list
2007/06/21  USchuster - changes for C++Builder 2007 (Mantis #4157)
2007/07/03  USchuster - year in copyright changed to 2007
2008/02/09  USchuster - year in copyright changed to 2008
2008/06/22  USchuster - changes for "Used Units" in Standalone client (Mantis #4380)
2008/07/01  USchuster - added crbIdentity from Create.pas
2009/01/01  USchuster - year in copyright changed to 2009
                      - changes for D2009
2009/01/18  THuber    #4618 - changed caption & application.title to have identity included
2009/12/22  USchuster - updated AnsiCrLf and added NativeLineBreak to make compilation with
                        checked in JCL version 1.102 and also JCL versions >= 1.104 possible
2009/12/28  THuber    - moved some consts to JVCSClientConsts
2010/01/09  USchuster - year in copyright changed to 2010
2010/01/24  THuber    -  directive H T M L H L P  removed
2011/01/15  USchuster - year in copyright changed to 2011
2012/07/08  AKroeber  - settings for external bugtracker
2012/09/02  AKroeber  - settings for SaveWIP

-----------------------------------------------------------------------------*)

unit VCSBase;

{$I jedi.inc}
{$I compopt.inc}

// we need this unit to share a couple of variables & functions during the project

interface

uses
  {$IFDEF IDEDLL}
  JVCSIDEInterface,
  {$ENDIF IDEDLL}
  Windows, Classes;

{$I jedivcs.inc}  // consts for onlinehelp

const
  {$IFDEF BETA}
  cBetaVer = 'x.x.x.x (c) JEDI VCS Development Team';
  cBetaDateTime = 0;  // TDateTime expected
  {$ENDIF BETA}
  cProductInf = ' © 2002-2011 JEDI VCS (http://jedivcs.sourceforge.net) - ';

  {$IFDEF IDEDLL}
  cPrgType = 'JVCSIE: ';
  cJVCSFileName = 'jedivcsdll.dll';
  {$ELSE}
  cPrgType = 'JVCSSA: ';
  cJVCSFileName = 'jedivcs.exe';
  {$ENDIF IDEDLL}

  cVCSDiffName    = 'jedivcsdiff.exe';
  cJVCSReportDll  = 'jedivcsreport.dll';
  cJVCSHelpFile   = 'jedivcs.chm';
  cMsgBoxCaption = 'JEDI VCS'; // Caption for MessageBox

  cBeepFreq = 500;              // Beepfrequence
  cBeepDur = 100;               // Beepduration

  cPopUpMCursor = 1;
  cSrvWaitCursor = 2;

  // const for time conversion rounding issue
//thu 27.12.2003 => see JVCSClientConst  cTimeConvErr = 0.000115741;

  //THe: change to use only one RegKey for all installations from now on.
  // after all, it isn't a good practice to use Delphis own Reg tree...
  // (you can still change this in Options if you like)
  // consts for regkeys
  // === JediVCS configuration storage root ===
  cRegSwJVCSBase = 'Software\JEDI\JEDIVCS';

  // === subkey's ===
  //THe: however, we will still allow different window layouts
  {$IFDEF IDEDLL}
  crbWindows = '\IDE_Windows';              //JediVCS.exe windows
  {$ELSE}
  crbWindows = '\App_Windows';              //JediVCS.dll windows
  {$ENDIF IDEDLL}

  crbOptions = '\Options';
  crbFilters = '\Mask';
  crbTimeLog = '\TimeLog';

  crbProjects = '\Projects\';
  crbMRU      = '\MRU\';
  crbPrinter  = '\Printer';

  crbIdentity = '\Identities';

  // consts for fontcolors Messagewindow projectmanager window
  msclNormal = 1;
  msclError = 2;
  msclNtfy = 3;

  // consts bit-coded field options (moduleoptions)
  moOrgFile = 1;
  moNotMember = 2;
  moAssocNotFnd = 4;
  moBatchIn = 8;
  moBatchOut = 16;
  moChanged = 32;
  moDelete = 64;
  moCopy = 128;
  moClosed = 256;
  moError = 512;
  moExcel = 1024;
  moMerge = 2048;
  moVer200 = 4096;
  // 8192 reserved by CmdLineApp

  // consts for Keyword expansion
  kwexAdd = 1;
  kwexCheckIn = 2;
  kwexCheckout = 3;


  // consts for Sheets Properties-Dialog
  cspInterface = 0;
  cspOptions = 1;
  cspComments = 2;
  cspFolders = 3;
  cspTimeStamp = 4;
  cspKWExp = 5;
  cspBackup = 6;
  cspEditors = 7;
  cspFilter = 8;
  cspExtCompare = 9;
  cspNotify = 10;
  cspShortcut = 11;
  cspDialogs = 12;
  cspIntPrinter = 13;
  cspMRU = 14;
  cspBlowfish = 15;
  cspDebug = 16;
  cspExtBugTrack = 17;
  cspSaveWIP = 18;


  // consts for Notify-Filter
  ntfyBeep = 1;
  ntfyOnlyCurrent = 2;
  ntfyChgIcon = 4;
  ntfyConctA = 8;
  ntfyConctExcl = 16;
  ntfyChckOut = 32;
  ntfyChckIn = 64;
  NtfyMsgStr = '%d|%d|%d|%s|%s|%s|%s';

  // invalid chars for Projekt/ Modulnames
  InvalidPMChars = ['"', '/', '\', '<', '>', '[', ']', ':', ';', '|', '{', '}', '*', '%', '?'];
  IPMCharsMsg = '", /, \, <, >, [, ], :, ;, |, {, }, *, %, ?';

  // const for external files
  cSelectionFileFamiliesFile = 'ffdef.jvcs';
  {$IFDEF IDEDLL}
  cIDEComponentListFile = 'CompList.jvcs';
  cVersionInfoLocalizationFile = 'verinf.jvcs';
  cDelphiVCLComponentListFile = 'vcllist.jvcs';
  cBCBVCLComponentListFile = 'vcllistbcb.jvcs';
  {$ENDIF IDEDLL}
  cParserUnitSkipListFile = 'ulist.jvcs';
  cHTMLReportTemplateFile = 'htm_rep.htm';

  // Shortcuts
  cDefaultSCProjAdmin = scCtrl + scShift + Ord('P');
  cDefaultSCChkIn = scCtrl + scShift + Ord('I');
  cDefaultSCChkOut = scCtrl + scShift + Ord('O');
  cDefaultSCSync = scCtrl + scShift + Ord('S');
  cDefaultSCBckUp = scCtrl + scShift + Ord('B');
  cDefaultSCGet = scCtrl + scShift + Ord('G');

var
  // Delphi or C++B?
  bIsCppBuilder: Boolean = False;
  sIDEName: string = 'Delphi';        // C++ Builder
  sIDEProject: string = 'dpr';        // bpr
  sIDEPackage: string = 'dpk';        // bpk
  sIDEUnit: string = 'pas';           // cpp
  // Midware
  AppSrvClientReady: Boolean = False; // Flag wait for AppSrv
  AppSrvClientErr: Integer = 0;       //
  SrvTimeOut: DWORD = 0;              //
  SrvTimeOutVal: DWORD = 120000;      //
  iServTraffic: Integer = 0;          //
  AppSrvClientConnected: Boolean = False; // Flag AppSrv connected
  AppSrvBanner: string = '';          // Server banner
  TransactionNr: Integer = -1;        // Transaction number
  EncryptServerData: Boolean = False; // Flag AppSrv connected
  LocalIPAddr: string = '';           // Local IP

  ServerProjectID: Integer = -1;      // Current Project ID
  {$IFDEF BRANCHING}
  ServerBranchID: Integer = 1;        // Current Branch ID
  {$ENDIF BRANCHING}
  ServerUserID: Integer = -1;         // Current User ID

  dServerLogin: Double = 0;           // Login Time
  iServerReqCount: Integer = 0;       // Request count

  bGlobalSettings: Boolean = False;   // Global user settings

  {$IFDEF IDEDLL}
  IDEInterface: TIDEInterface = nil;  // Interface to IDE
  bConnectRequired: Boolean = False;  // archive should be opened
  bArchiveEmpty: Boolean = True;      // is the archive empty ?
  bProjectDeleted: Boolean = False;   // is the Project deleted in the archive?
  //-> use better use IDEInterface... sAppDirectory: string = '';         // Base for Delphi installation = $(DELPHI)
  iDelphiVer: Integer = 4;            // Delphi IDE Version
  sIDERegistryKey: string = '';       // Base for (Delphi) IDE Registry entries
  {$ENDIF IDEDLL}
  sCurrentUser: string = '';          // the user
  sCurrentMachine: string = '';       // the computer
  sArchiveSource: string = '';        // the server
  bProjectOpen: Boolean = False;      // is a project open?
  bGoWithout: Boolean = False;        // User selected "Go Without"
  sProjectName: string = '';          // name of the project
  {$IFDEF BRANCHING}
  sBranchName: string = 'HEAD';       // name of the branch
  {$ENDIF BRANCHING}
  sCurrentProject: string = '';       // name of the current project
  sBaseRegistryKey: string = '';      // Base for App Registry entries
  sDLLDirectory: string = '';         // JEDI-VCS - Folder
  sProductVer: string = '';           // Product version
  bBackupEnable: Boolean = False;     // launch Backup form
  sBackupBuffer: string = '';         // Backup path buffer
  sFVCSMailslot: string = 'FVCSMail'; // Name of JEDI-VCS mailslot
  bACheck: Boolean = False;           // launch A.Admin form
  {$IFDEF IDEDLL}
  bPJM_Created: Boolean = False;      // Projectmanager form created
  bPJM_TopWindow: Boolean = False;    // Projectmanager form is Top Window
  bPJM_Valid: Boolean = False;        // Projectmanager form valid
  {$ENDIF IDEDLL}
  bPJM_NeedRefresh: Boolean = False;  // Projectmanager needs refresh

  bOpenformActive: Boolean = False;   // Open archive form active
  bVCSOptionsChanged: Boolean = False;// Options PM changed

  sDriveSubst: string = '';           // Drive Substitution
  ShowDebugMsg: Boolean = False;      // O u t p u t D e b u g S t r i n g

  iMenAccel: Integer = 5;             // Menu accelerator
  cSCProjAdmin: TShortCut = cDefaultSCProjAdmin;// Shortcuts
  cSCChkIn: TShortCut = cDefaultSCChkIn;
  cSCChkOut: TShortCut = cDefaultSCChkOut;
  cSCSync: TShortCut = cDefaultSCSync;
  cSCBckUp: TShortCut = cDefaultSCBckUp;
  cSCGet: TShortCut = cDefaultSCGet;
  bSCActive: Boolean = False;         // Shortcut in Progress

  trResDesktop: TRect;                // Working area (desktop - taskbar)

  bGlobalCancel: Boolean = False;

  nServerVersion : Integer = 100;     // Serverversion during connect

  sConfigFolder : String;             // folder for config files (.snm, .tlg, .bkp, .pcf, .sdl)

  sIdentityCaption : String;          // used for projectmanager caption

  sBugtrackerURL: string;
  sBugtrackerRegEx: string;

  sSaveWIPcommand: string;
  bSaveWIPauto: Boolean;

implementation
uses
    VCSProcBase
  , JVCSClientFunctions
  , JclSysInfo
  , JclFileUtils
  ;


initialization
  sConfigFolder := PathAddSeparator(GetAppdataFolder) + 'JEDI\JVCS\Config\';
  FileCopyFiles(PathAddSeparator(GetSelfFileLocation) + 'Config\', sConfigFolder, False);
end.
