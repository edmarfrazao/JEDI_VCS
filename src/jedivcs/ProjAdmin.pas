(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: ProjAdmin.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS: Thomas Huber (Thomas_D_Huber@gmx.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
Feb/04
- Usc: Should there be a ESC hint while FillListView in Caption?
Nov/04:
- USc: possible translation bugs:
   - see VCSYes2AllDlg.SetCheckBoxCaption in TVCSProjAdmin.FillListView
   - Pos('AppSrvClient', in TVCSProjAdmin.AddMessage
- THu: #2031 still leaves tweak that double click is possible though project
             has already changed
ToDo
- make "VCL Library overview" strings resourcestrings? (how are the other files handled?)
- use ToolImageList from JVCSGUIClientImages.pas
- improve GlobalOption handling (see connect/disconnect)

-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FreeVCS code to JEDI VCS
2003/02/09  THuber    - changed name of fvcspluginmsgconst.inc => jedivcs...
2003/02/12  USchuster - changed DSAMsg with JVCSDialogs in uses clause to use JvDSADialogs
2003/02/14  USchuster - Bugfix: the user of last write access should now be shown correct
2003/02/21  FBouwmans - Added ProjectTree for explorer like browsing
2003/02/26  USchuster - fixed mantis bug #746
                        reason: - in maximized state Left and Top of the form are < 0
                                  TFormSize contains only Word(s) and copying a value < 0
                                  to this causes an Range Check Error
                        solution: - changed the Word(s) into Integer
                      - moved the creation of VcsVSSImport from dpr to projadmin
2003/03/03  THensle   - changes for "ConfigStorage" unit
                      - removed references to the obsolete form "CreateDBIArchive"
                      - fixed broken (by me?) storing of ProjectTree width
                      - changed some storage value names
                      - change to use only one RegKey ('Software\JEDI\JEDIVCS')
                        for all installations from now on. After all, it isn't a
                        good practice to use Delphis own Reg tree...
                        (you can still change this in Options)
                      - removed some outcommented (obsolete) stuff
2003/03/08  USchuster - exchanged THistoryList with TJVCSMruList (mantis #727)
2003/03/10  USchuster - fixed mantis issues #773 and #774
2003/03/30  USchuster - reenabled projectinformation message
2003/04/08  USchuster - changes for IDEInterface
2003/04/15  THuber    - Statusarea now TabSheets with additional own ToDo-List
                      - changed JEDI-VCS to JEDI VCS
2003/04/17  MGosselink- Disabled the projecttree in IDE mode
2003/05/02  THuber    - fixed wrong popup in ToDo
                      - added memo for better view on todo text with splitter
2003/05/02  THuber    - fixed bug with load/save todolist columns/splitter
                        from/to registry.
                      - Message/ToDo page now gets active if switched to visible
2003/05/21  MGosselink- Added the BugList window, docked the ProjAdmin
2003/05/22  USchuster - reenabled actions
                      - changed/disabled "manual" docking in the pagecontrol
                      - bugwindow now gets active if switched to visible
                      - Caption is now set in SetCaption
                      - changed JEDI-VCS to JEDI VCS in unit header and
                        menuentrys
2003/06/18  USchuster - added recent projects to project menu (mantis #978)
2003/06/19  MGosselink- added Module History List Window (mantis #908)
2003/06/20  MGosselink- added an IFDEF in RefreshProjectFolder to avoid errors in the IDEDLL version
2003/07/23  FBouwmans - Fixed splitter for treeview (minimum size is 1)
2003/07/28  THuber    - fixed mantis #0001058
2003/08/08  THuber    - last changes made D5 compatible over JclStrings
2003/09/06  THuber    - mantis #1095:
                        IDE not using projecttree (added some ifdef's,
                        added action for projecttree menu/toolbutton use now this action
                        (error doesn't happen now though value is 1)
2003/09/15  USchuster - moved projecttree and todo list to new units
                        (Roadmap 2.40 #6[sf #78449], #22[sf #79979])
                      - acRefreshForm is now disabled when not connected
2003/10/14  THuber    - mantis 0001176 according to Petr Jurik's suggestion
2003/11/09  USchuster - exchanged TextComp call with new procedure DoModuleCompare (mantis #1204)
2003/11/23  USchuster - changes for cleanup in BugWindow.pas and ModuleHistoryWindow.pas
2003/11/30  USchuster - changes because TProject.ID is now Integer
2003/12/27  THuber    - Versionno. in caption read from Fileversion
                      - TimeConst now from JVCSClientConsts
                      - CryptDLL loaded over JVCSCrypt now
2004/01/11  USchuster - improved recent projects (doesn't block the menu while loading)
                      - rtProjectClosing will now be send before closing a project
                      - version info handling is now also available for packages
                        (suggestion by Rainer Krug)
                      - minor style cleaning
2004/01/24  USchuster - the internet link menu items will now be created at runtime
                      - fixed GetSelectedModuleID/Name -> delivers now the moduleID/Name
                        also when the module don't exists on the local disk
                      - now with constant for message box caption
2004/02/19  USchuster - now it's possible to abort the open project process (mantis #1214)
                        (of course only in the Standalone version) 
2004/02/24  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/03/14  USchuster - 'CompList.fvc' -> cIDEComponentListFile
                        'ffdef.fvc' -> cSelectionFileFamiliesFile
                      - minor style cleaning (casing and comments)
2004/04/03  USchuster - changed to use internal images instead of .ico files in application path
                      - fixed GetFileType call in ADD_Refresh_Module
2004/04/10  USchuster - fixed sorting the module listview by date (mantis #1557)
                      - moved RefreshDispatcher to JVCSInterfaces.pas to have
                        access from everywhere
2004/05/14  USchuster - replaced TMenuBar with TJvToolBar
2004/07/12  THuber    #1960 - disable Autoresort on elvModules to prevent sorting
                              during long term operation
                      - fixed sorting for files with more than 999999 Bytes (mantis #1968)
2004/07/18  THuber    #1965 - refresh after get archive call to refresh tree
2004/07/28  USchuster - fixed sorting for files with no local size (mantis #1968)
2004/08/24  USchuster - changed archive space functions to add typeinformation to
                        the listview columns (mantis #2032)
                      - fixed integer overflow in archive space functions (mantis #2033)
2004/09/17  FHasovic  - Added dxGetText support for localization                      
2004/09/28  USchuster - added question before adding new modules to a project over
                        drag&drop (mantis #2150)
                      - moved some strings to JVCSGUIClientResources.pas
2004/10/01  THuber    #2189 - no accept of dropped directories in standalone gui client
2004/10/07  THuber    #2185 - same change as #2189 for modules with revisions
                      - jedistyle cleaning
2004/11/07  USchuster - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/11/14  USchuster - changed to use TLanguageMenuItem from JVCSLanguage.pas and
                        set the default textdomain to "jedivcs"
2004/12/28  USchuster - selecting a module by keys does now dispatch
                        rtSelectedModuleChanged as well (mantis #2359)
                      - fixed restoring of maximized window state (mantis #2408)
2005/01/03  USchuster - attempt to fix error 403 while refreshing project (mantis #2287)
                      - implemented another solution (use OnSelectItem event instead
                        of OnChange because OnChange slows down FillListView)
                        for mantis #2359
2005/01/06  THuber    #1704 - Prevent working on deleted projects
2005/01/10  USchuster - now we do lowercase the new module name in rename module
                        again (mantis #2454)
2005/01/16  USchuster - changes to avoid automatically adding of .dcp files (required
                        packages) to a package project in the IDE version (mantis #1936)
                      - removed opening of config storage (this is done since quite a
                        while in jedivcs.dpr [VCSProcBase.InitAndOpenConfigStorage])
                      - standalone version does now support user definable shortcuts
                        as the IDE version (mantis #1956)
                      - prevent calling rtSelectedModuleChanged twice in OnSelectItem
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC1 was released ^^^^^^^^^^^^^^^^^^^^^
2005/02/27  USchuster - IJVCSProjectManager.GetSelectedModuleID and GetSelectedModuleName
                        are now threadsafe (mantis #2470)
                      - attempt to fix mantis #2609
2005/02/28  THuber    #2031 - better message handling on project change to avoid
                              unwanted double click behaviour (still tweaks)
2005/03/01  Victorious- {$IFDEF DEBUG}
2005/03/18  USchuster - added refresh after autosync for standalone client (mantis #1966/b)
2005/04/10  CSchuette - fixed ShowDebugMsg initialization
2005/04/11  CSchuette - mantis #2815
2005/04/17  CSchuette - mantis #2884 - added .dll to be excluded from module list if
                        modules are added from currently active delphi project
                      - fixed some unneccessary sorting of module list during refresh
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC2 was released ^^^^^^^^^^^^^^^^^^^^^                      
2005/04/25  CSchuette - added calls to "ResolveFileFamilies" to fix mantis #1205
2005/05/12  CSchuette - fixed bug that it was no longer possible to add files to projects
2005/05/16  USchuster - fixed registry entry for auto open project dialog to get it
                        working again (mantis #2954)
2005/06/04  USchuster - changes to store the selected language and prevent the
                        exception while switching the language(ignore TListColumn for now)
2005/06/27  USchuster - label order in label column is now LabelID desc(mantis #2569)
2005/06/30  CSchuette - fixed bug where ModuleID was not correctly loaded into lists when
                        the module has no revisions on the server
                      - fixed refresh problem in DLL client after adding new modules (mantis #3062)
2005/07/10  CSchuette - fixed annoying problem with sDLLDirectory in "debug"-version
                      - fixed problem that project file was reloaded on "undo checkout" (mantis #3081)
2005/07/24  USchuster - user interaction while remove module is now prevented (mantis #3108)
                      - changed setting of sDLLDirectory back to Standalone version only
2005/09/17  USchuster - changes to support "Open Project" from the "Search Modules"
                        and "Locked Modules" window (mantis #3048)
2005/11/20  KFitzner  - changes to fix the project manager always asking to add to add .dfm
                        and .h files to project in C++ Builder (mantis #3318)
2005/11/22  KFitzner  - Fix minor formatting issue from previous change, and move "Modules->File Familes"
                        to "Tools->File Familes Manager..." (mantis #3319)
2005/11/28  USchuster - changes for mantis #3291
2005/12/11  USchuster - added IJVCSProjectManager.RefreshSingleModule implementation (mantis #3349)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC3 was released ^^^^^^^^^^^^^^^^^^^^^
2006/01/01  USchuster - changes for more flexible shortcuts (mantis #3397)
2006/01/02  THuber    #3404 tweaks in handling docked windows fixed
2006/01/04  THuber    #3404 docked area height was not stored - resize handler removed from dfm
2006/01/09  THuber    #3431 Print/Reports menu only visible if jedivcsreport.dll exists
2006/01/18  USchuster - archive space fix for item values greater than 2^31 (mantis #3450)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 final released ^^^^^^^^^^^^^^^^^^^^^^^^^^
2006/03/26  USchuster - speed up for project closing(suggestion by Valdir Stiebe Junior; mantis #3609) 
2006/04/01  USchuster - added line history feature (mantis #3613)
2006/04/24  USchuster - line history tab closing fix
                      - the main tab has now a name -> "Project View" 
2006/04/30  THuber    #3611 config folder now windows user dependend (appdata shell folder)
2006/06/28  USchuster - first changes for branching
2006/11/26  USchuster - some minor changes for the line history feature
2006/11/29  USchuster - added icon and tool button for the line history feature
2006/12/03  USchuster - changes for loading and saving of the line history settings
2006/12/10  USchuster - changes for menu bitmaps
2007/03/07  USchuster - replaced "Open Parent Folder" code by function ShellOpenParentFolder (mantis #4079)
                      - SetCaption does now use GetJVCSAppFileVersion
2007/08/13  USchuster - Trace -> TraceMsg
2007/11/22  USchuster - changes for new line history settings
2008/02/16  USchuster - added branch creation wizard
2008/02/17  USchuster - Trace -> TraceMsg and hint (IDEDLL)
2008/03/15  USchuster - line history can now be called from several forms
2008/06/22  USchuster - changes for "Used Units" and "Imports/ Exports" in Standalone client (Mantis #4380)
2008/07/06  USchuster - added favorites menu (submission by AK)
2008/07/08  USchuster - minor favorites fixes
2008/07/09  USchuster - favorite items are now updated after opening/closing a project
2008/07/23  USchuster - added label history form
2008/10/27  USchuster - renamed label history menu to "Project Label History"
2008/12/15  THuber    - introduced Support for Themes under XP/VISTA
2008/12/22  THuber    - added VISTA-Taskbar compatibility
2009/01/03  THuber    #4641 - cancel in login triggerd error message
2009/01/04  THuber    #4644 - performance improvement on multiple select actions
                      (removed unnecessary mmiAllusermodulesClick).
                      Also slight improvement in FillListView achieved.
2009/01/05  THuber    VISTA Taskbar fix needs to commented out for >= Delphi2007
2009/01/18  THuber    #4618 - changed caption & application.title to have identity included
                      - ProjectLabelHistory en-/disabled depending on connection state
2009/01/24  THuber    #4670 keep viewer application in front for view module
2009/03/21  USchuster - changes for new Line History settings
2009/12/06  THuber    #4209 Include Openrecentproject again to Project MRU 
2010/01/23  USchuster - added Server\VCS Browser (Mantis #5103)
2010/01/24  USchuster - added Branch\Remove (Mantis #5102)
2010/01/24  THuber    #4201 selected module name(s) can be copied to clipboard
2010/01/24  USchuster - added "Diff" menu items to module list (Mantis #5101)
2010/01/28  USchuster - images for "Diff" menu items (Mantis #5101)
2010/10/31  USchuster - implemented OnRevisionClick event of the Line History
2011/01/15  USchuster - changed font to Tahoma
2012/07/08  AKroeber  - changed AnsiCrLf to sLineBreak (avoid using of JclAnsiString.pas - should work from Delphi 6 to XE2)
2012/09/02  AKroeber  - SaveWIP
2015/04/04  USchuster - added "Diff All Local vs. Archive" menu item to module list

-----------------------------------------------------------------------------*)

unit ProjAdmin;

{$I jedi.inc}
{$I compopt.inc}

{$IFDEF DELPHI6_UP}
  {$WARN UNIT_PLATFORM OFF}
  {$WARN SYMBOL_PLATFORM OFF}
{$ENDIF DELPHI6_UP}

{$IFNDEF DEBUG}
  {$UNDEF SHCHANGENTFY}
{$ENDIF ~DEBUG}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Menus, ExtCtrls, ImgList, ComCtrls, Buttons, EnhListView, ActnList,
  ToolWin, JVCSMruList, JvToolBar, mdMailSlot, ApsCli, RFormat, dfsStatusBar,
  FavOpenDialog, JvComponent, JvPluginManager, JvComCtrls, JvSplitter,
  JVCSDataClasses, JVCSInterfaces, JvExExtCtrls, JvExComCtrls, JVCSClasses,
  JvComponentBase, JVCSLineHistoryDefaultProvider, JVCSLineHistoryFrame,
  JVCSLineHistoryUnit, JVCSLabelHistory, JVCSBrowserFrame, SaveWIP
  {$IFNDEF  DELPHI7_UP}
    , ThemeMgr
  {$ENDIF}
  ;

type
  // Listview columns width
  TColWidth = record
    Col: array [0..12] of Word;
  end;

  // Formsize
  TFormSize = record
    Top, Left, Width, Height: Integer;
  end;

  // Toolbar Positions
  TTBPos = record
    MBTop, MBLeft,
    TBToolTop, TBToolLeft,
    TBWindowTop, TBWindowLeft,
    TBModuleTop, TBModuleLeft: Word;
    TBToolVis, TBWindowVis, TBModuleVis: Boolean;
  end;

  // for action on module list
  TSelectAction = ( selAcSelectAll
                  , selAcUnselectAll
                  , selAcRevertSelection
                  , selAcAllCheckedIn
                  , selAcAllCheckedOut
                  , selAcAllCheckedOutByCurrentUser
                  , selAcAllNotYetAppliedChanges
                  , selAcAllNeverArchieved
                  );

const
  WM_APPSTARTUP = WM_APP + 100;   // startup message
  WM_ICONCALLBACK = WM_APP + 101; // taskbar icon (double-click) callback
  {$IFDEF IDEDLL}
  WM_IDEACTIVATION = WM_APP + 102; // for activation of projectadmin from IDE
  {$ENDIF IDEDLL}

  {$I ..\stdplugin\jedivcspluginmsgconst.inc}

  SrvTimeCnt = '  /%0.2f s';

  // constants for easy identification of columns/ list items
  // Listview columns
  colName = 0;
  colType = 1;
  colPath = 2;
  colVer = 3;
  colState = 4;
  colOwner = 5;
  colCount = 6;
  colKeyWord = 7;
  colShare = 8;
  colSize = 9;
  colDate = 10;
  colAttr = 11;
  colMID = 12;
  colRID = 13;
  // Listview subitems
  sitType = 0;
  sitPath = 1;
  sitVer = 2;
  sitState = 3;
  sitOwner = 4;
  sitCount = 5;
  sitKeyWord = 6;
  sitShare = 7;
  sitSize = 8;
  sitDate = 9;
  sitAttr = 10;
  sitMID = 11;
  sitRID = 12;

type
  TVCSProjAdmin = class(TForm, IJVCSProjectManager)
    PopupMenu1: TPopupMenu;
    miOpenFile: TMenuItem;
    StateImageList: TImageList;
    SysImageList: TImageList;
    miRemove: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    miCompare: TMenuItem;
    miHistory: TMenuItem;
    miCheckIn: TMenuItem;
    miCheckOut: TMenuItem;
    N7: TMenuItem;
    MainMenu1: TMainMenu;
    Module1: TMenuItem;
    mmiAdd: TMenuItem;
    mmiRemove: TMenuItem;
    N8: TMenuItem;
    mmiCheckIn: TMenuItem;
    mmiCheckOut: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    mmiView: TMenuItem;
    Help1: TMenuItem;
    Project1: TMenuItem;
    mmiUsedUnits: TMenuItem;
    mmiUsedComponents: TMenuItem;
    mmiLoad: TMenuItem;
    mmiCompare: TMenuItem;
    mmiHistory: TMenuItem;
    miClose: TMenuItem;
    ActionList1: TActionList;
    Select1: TMenuItem;
    mmiSelectAll: TMenuItem;
    mmiUnselectAll: TMenuItem;
    N13: TMenuItem;
    mmiAllcheckedout: TMenuItem;
    mmiAllCheckedin: TMenuItem;
    Tools1: TMenuItem;
    mmiBackupRestore: TMenuItem;
    mmiTouch: TMenuItem;
    mmiToDolist: TMenuItem;
    mmiInfo: TMenuItem;
    miInfo: TMenuItem;
    PrintReports1: TMenuItem;
    acLoadModules: TAction;
    acAddModules: TAction;
    acRemvModules: TAction;
    acCheckIn: TAction;
    acCheckOut: TAction;
    acGetRevision: TAction;
    acCompare: TAction;
    acHistory: TAction;
    acCtxHelp: TAction;
    acModInfo: TAction;
    acFormClose: TAction;
    ControlBar1: TControlBar;
    ToolImageList: TImageList;
    TBModule: TToolBar;
    edSearch: TEdit;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton14: TToolButton;
    popmAddModules: TPopupMenu;
    Projectfolder1: TMenuItem;
    acKeyAdmin: TAction;
    Keywords1: TMenuItem;
    Keywords2: TMenuItem;
    acRefreshForm: TAction;
    Refresh1: TMenuItem;
    N4: TMenuItem;
    acAddShared: TAction;
    ToolButton9: TToolButton;
    miLH1: TMenuItem;
    miLH2: TMenuItem;
    miLH3: TMenuItem;
    miLH4: TMenuItem;
    miLH5: TMenuItem;
    miLHSep: TMenuItem;
    Keywords3: TMenuItem;
    LoadallIDEmodules1: TMenuItem;
    UnloadallIDEmodules1: TMenuItem;
    Shared2: TMenuItem;
    Searchshared1: TMenuItem;
    Setsharedflag1: TMenuItem;
    N3: TMenuItem;
    mmiShowMenuBitmaps: TMenuItem;
    Timelog1: TMenuItem;
    mmiActive: TMenuItem;
    mmiShowtimelog: TMenuItem;
    acUndoChkOut: TAction;
    UndoCheckOut1: TMenuItem;
    UndoCheckOut2: TMenuItem;
    ToolButton24: TToolButton;
    MenuBar1: TJvToolBar;
    TBTool: TToolBar;
    ToolButton25: TToolButton;
    ToolButton26: TToolButton;
    TBWindow: TToolBar;
    ToolButton28: TToolButton;
    ToolButton29: TToolButton;
    ToolButton30: TToolButton;
    Toolbars1: TMenuItem;
    mmiTBModule: TMenuItem;
    mmiTBTools: TMenuItem;
    mmiTBWindow: TMenuItem;
    mmiChckoutbycurruser: TMenuItem;
    Custom1: TMenuItem;
    N18: TMenuItem;
    mmiDefine: TMenuItem;
    N19: TMenuItem;
    mmiCustSel0: TMenuItem;
    mmiCustSel1: TMenuItem;
    mmiCustSel2: TMenuItem;
    mmiCustSel3: TMenuItem;
    mmiCustSel4: TMenuItem;
    mmiCustSel5: TMenuItem;
    mmiCustSel6: TMenuItem;
    mmiCustSel7: TMenuItem;
    mmiCustSel8: TMenuItem;
    mmiCustSel9: TMenuItem;
    mmiProjectdependencies: TMenuItem;
    mmiSettings: TMenuItem;
    acAddtoCustFilt: TAction;
    Addtocustomfilter1: TMenuItem;
    N24: TMenuItem;
    Custom2: TMenuItem;
    N25: TMenuItem;
    Addtocustomfilter2: TMenuItem;
    mmiShowcustofilter: TMenuItem;
    mmiApplycustomfilter: TMenuItem;
    ToolButton8: TToolButton;
    N26: TMenuItem;
    N27: TMenuItem;
    History1: TMenuItem;
    N28: TMenuItem;
    mmiDefineWCView: TMenuItem;
    Splitter1: TSplitter;
    Messagewindow1: TMenuItem;
    mmiShowMsgWin: TMenuItem;
    N30: TMenuItem;
    Clearmessagewindow1: TMenuItem;
    N31: TMenuItem;
    popupmMsg: TPopupMenu;
    Clear1: TMenuItem;
    Save1: TMenuItem;
    Copy1: TMenuItem;
    N17: TMenuItem;
    acShowMsgWin: TAction;
    tbShowNsgWin: TToolButton;
    mdSecureMail1: TmdSecureMail;
    Sendmessage1: TMenuItem;
    N29: TMenuItem;
    Notify1: TMenuItem;
    mmiInternalNotifyactive: TMenuItem;
    N32: TMenuItem;
    Sendmessage2: TMenuItem;
    SearchTimer: TTimer;
    Projectmanager1: TMenuItem;
    CheckforBuildOK1: TMenuItem;
    mmiCrossRefList: TMenuItem;
    N33: TMenuItem;
    UpdateTimer: TTimer;
    Archive1: TMenuItem;
    CountSpace1: TMenuItem;
    Allprojects1: TMenuItem;
    Currentproject1: TMenuItem;
    RenameProject1: TMenuItem;
    MoveModules1: TMenuItem;
    RemoveProjects1: TMenuItem;
    PurgeProjects1: TMenuItem;
    Showprojecttree1: TMenuItem;
    N36: TMenuItem;
    RefreshTimer: TTimer;
    mmiAutorefresh: TMenuItem;
    acShowSharedBy: TAction;
    Sharedby2: TMenuItem;
    N15: TMenuItem;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton15: TToolButton;
    ToolButton16: TToolButton;
    acFileFamilies: TAction;
    Filefamilies1: TMenuItem;
    N11: TMenuItem;
    acHideModule: TAction;
    ToolButton17: TToolButton;
    ToolButton18: TToolButton;
    popupmView: TPopupMenu;
    Localversion1: TMenuItem;
    Latestarchiveversion1: TMenuItem;
    N1: TMenuItem;
    N37: TMenuItem;
    Showdesertedmodules1: TMenuItem;
    mmiShowhiddenmodules: TMenuItem;
    mmiProjectDescription: TMenuItem;
    N34: TMenuItem;
    acLabelManager: TAction;
    ToolButton19: TToolButton;
    acDescription: TAction;
    Description1: TMenuItem;
    Description2: TMenuItem;
    Administration1: TMenuItem;
    mmiUserlist: TMenuItem;
    mmiServeroptions: TMenuItem;
    N20: TMenuItem;
    HideShowmodule1: TMenuItem;
    N35: TMenuItem;
    HideShowmodule2: TMenuItem;
    N38: TMenuItem;
    mmiWhoami: TMenuItem;
    N39: TMenuItem;
    acWhoami: TAction;
    ToolButton20: TToolButton;
    ToolButton21: TToolButton;
    mmiSearchmodules: TMenuItem;
    Projectbasedrights1: TMenuItem;
    N40: TMenuItem;
    Changeserverpassword1: TMenuItem;
    N41: TMenuItem;
    Definemilestones1: TMenuItem;
    Deletedprojects1: TMenuItem;
    mmiNewProject: TMenuItem;
    mmiOpenProject: TMenuItem;
    N12: TMenuItem;
    mmiConnectserver: TMenuItem;
    mmiDisconnectserver: TMenuItem;
    N16: TMenuItem;
    N2: TMenuItem;
    mmiSynchronize: TMenuItem;
    mmiMerge: TMenuItem;
    mmiVCSproperties: TMenuItem;
    AboutFreeVCS1: TMenuItem;
    N43: TMenuItem;
    mmiCloseProject: TMenuItem;
    mmiBranch: TMenuItem;
    HelpTopics1: TMenuItem;
    Options1: TMenuItem;
    N22: TMenuItem;
    N23: TMenuItem;
    N42: TMenuItem;
    acCopy2Clip: TAction;
    ToolButton22: TToolButton;
    ToolButton23: TToolButton;
    ToolButton27: TToolButton;
    CopyListviewtoClipboard1: TMenuItem;
    N44: TMenuItem;
    acAddFolders: TAction;
    AddFolders2: TMenuItem;
    AddFolders3: TMenuItem;
    N45: TMenuItem;
    mmiShowColors: TMenuItem;
    N46: TMenuItem;
    mmiMSManager: TMenuItem;
    acSendMessage: TAction;
    ToolButton31: TToolButton;
    ToolButton32: TToolButton;
    acSepIDEVCS: TAction;
    HideApplication1: TMenuItem;
    N48: TMenuItem;
    N49: TMenuItem;
    acBugManager: TAction;
    BugManager1: TMenuItem;
    ToolButton33: TToolButton;
    ToolButton34: TToolButton;
    mmiProjectBugTracking: TMenuItem;
    mmiModuleBugTracking: TMenuItem;
    acModuleBugs: TAction;
    BugTracking1: TMenuItem;
    N50: TMenuItem;
    N51: TMenuItem;
    N52: TMenuItem;
    CompareFolders1: TMenuItem;
    N14: TMenuItem;
    ProjectHierarchy1: TMenuItem;
    LockedModules1: TMenuItem;
    acOpenParentFolder: TAction;
    OpenParentFolder1: TMenuItem;
    N53: TMenuItem;
    N54: TMenuItem;
    OpenParentFolder2: TMenuItem;
    Label2: TLabel;
    acViewArchiveVersion: TAction;
    ViewArchiveVersion1: TMenuItem;
    View1: TMenuItem;
    N55: TMenuItem;
    Panel1: TPanel;
    dfsStatusBar: TdfsStatusBar;
    acSynchronize: TAction;
    ToolButton37: TToolButton;
    ToolButton38: TToolButton;
    ReverseSelection1: TMenuItem;
    acHideApp: TAction;
    DirectSQL1: TMenuItem;
    DistributionArchive1: TMenuItem;
    N57: TMenuItem;
    N58: TMenuItem;
    JediVcsLinkPlaceholder: TMenuItem;
    N59: TMenuItem;
    LocalProjectFolder1: TMenuItem;
    N60: TMenuItem;
    NotArchieved1: TMenuItem;
    N61: TMenuItem;
    N62: TMenuItem;
    SMTPStatus1: TMenuItem;
    acRenameModule: TAction;
    Rename1: TMenuItem;
    Rename2: TMenuItem;
    mmiShowLocalInfo: TMenuItem;
    uilPluginManager1: TJvPluginManager;
    Plugins1: TMenuItem;
    AboutPlugins1: TMenuItem;
    N63: TMenuItem;
    Configure1: TMenuItem;
    ExpertMenu1: TMenuItem;
    N47: TMenuItem;
    mmiChangedDifferent: TMenuItem;
    mmiModuleListReportSel: TMenuItem;
    pmiLogtoFile: TMenuItem;
    UserCurrentProject1: TMenuItem;
    UserAllprojects1: TMenuItem;
    AllUsersAllProjects1: TMenuItem;
    N64: TMenuItem;
    AllUsersCurrentProject1: TMenuItem;
    pmiIncludeTimestamp: TMenuItem;
    tbShowProjectFolder: TToolButton;
    ProjectFolder2: TMenuItem;
    pgStatus: TPageControl;
    tsMessages: TTabSheet;
    reMessage: TRichEdit;
    acShowToDoWin: TAction;
    tbShowMyToDoList: TToolButton;
    mmiShowTodoWin: TMenuItem;
    acProjectBug: TAction;
    mmiShowBugWin: TMenuItem;
    acShowBugWin: TAction;
    tbShowBugList: TToolButton;
    mmiOpenRecentProject: TMenuItem;
    acShowModuleHistoryWin: TAction;
    ModuleHistoryList: TMenuItem;
    tbShowModHistList: TToolButton;
    acProjectTree: TAction;
    ModuleImageList: TImageList;
    acBackupRestore: TAction;
    acLockedModuleWin: TAction;
    ShowLockedModulesList1: TMenuItem;
    tbShowLockedModulesList: TToolButton;
    acPrintReports: TAction;
    pgMain: TPageControl;
    tsDefault: TTabSheet;
    JvSplitter1: TJvSplitter;
    elvModules: TdfsEnhListView;
    tvHierachyPlaceholder: TPanel;
    miLineHistory: TMenuItem;
    pmnPageControlMain: TPopupMenu;
    mnpgMainClose: TMenuItem;
    Branch1: TMenuItem;
    mmiOpenBranch: TMenuItem;
    mmiNewBranch: TMenuItem;
    acLineHistory: TAction;
    mmiLineHistory: TMenuItem;
    ToolButton35: TToolButton;
    mmiFavorites: TMenuItem;
    mmiManageFavorites: TMenuItem;
    mmiFavoritesSeparator: TMenuItem;
    mmiFavAddCurrentProject: TMenuItem;
    mmiLabelHistory: TMenuItem;
    acSelectAll: TAction;
    mmiVCSBrowser: TMenuItem;
    N21: TMenuItem;
    mmiRemoveBranch: TMenuItem;
    Copymodulenametoclipboard1: TMenuItem;
    acCopyModulenameClipboard: TAction;
    mnDiff3To5: TMenuItem;
    mnDiff3: TMenuItem;
    mnDiff4: TMenuItem;
    mnDiff5: TMenuItem;
    mnDiff2: TMenuItem;
    mnDiff1: TMenuItem;
    acDiff1: TAction;
    acDiff2: TAction;
    acDiff3: TAction;
    acDiff4: TAction;
    acDiff5: TAction;
    acCompareAllLocalArchive: TAction;
    miCompareAllLocalArchive: TMenuItem;

    {$IFDEF IDEDLL}
    procedure WndProc(var Message: TMessage); override;
    {$ENDIF IDEDLL}
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SetMenuMode;
    procedure LoadAll1Click(Sender: TObject);
    procedure UnloadAll1Click(Sender: TObject);
    procedure edSearchClick(Sender: TObject);
    procedure edSearchKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure elvModulesDrawItem(Control: TWinControl;
      var ACanvas: TCanvas; Index: Integer; ARect: TRect;
      State: TOwnerDrawState; var DefaultDrawing, FullRowSelect: Boolean);
    procedure mmiUsedUnitsClick(Sender: TObject);
    procedure mmiUsedComponentsClick(Sender: TObject);
    procedure elvModulesChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure acSelectAllClick(Sender: TObject);
    procedure mmiUnselectAllClick(Sender: TObject);
    procedure mmiAllcheckedoutClick(Sender: TObject);
    procedure mmiAllCheckedinClick(Sender: TObject);
    procedure mmiToDolistClick(Sender: TObject);
    procedure mmiTouchClick(Sender: TObject);
    procedure mmiBackupRestoreClick(Sender: TObject);
    procedure acPrintReportsExecute(Sender: TObject);
    procedure acLoadModulesExecute(Sender: TObject);
    procedure acAddModulesExecute(Sender: TObject);
    procedure acRemvModulesExecute(Sender: TObject);
    procedure acCheckInExecute(Sender: TObject);
    procedure acCheckOutExecute(Sender: TObject);
    procedure acCompareExecute(Sender: TObject);
    procedure acHistoryExecute(Sender: TObject);
    procedure acCtxHelpExecute(Sender: TObject);
    procedure acModInfoExecute(Sender: TObject);
    procedure acFormCloseExecute(Sender: TObject);
    procedure elvModulesClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure popmAddModulesPopup(Sender: TObject);
    procedure Projectfolder1Click(Sender: TObject);
    procedure acRefreshFormExecute(Sender: TObject);
    procedure acRefreshModuleList(Sender: TObject);
    procedure acKeyAdminExecute(Sender: TObject);
    procedure miLH1Click(Sender: TObject);
    procedure miLH2Click(Sender: TObject);
    procedure miLH3Click(Sender: TObject);
    procedure miLH4Click(Sender: TObject);
    procedure miLH5Click(Sender: TObject);
    procedure mmiShowColorsClick(Sender: TObject);
    procedure elvModulesDrawHeader(Control: TWinControl;
      var ACanvas: TCanvas; Index: Integer; var ARect: TRect;
      Selected: Boolean; var DefaultDrawing: Boolean);
    procedure mmiShowMenuBitmapsClick(Sender: TObject);
    procedure mmiActiveClick(Sender: TObject);
    procedure mmiShowtimelogClick(Sender: TObject);
    procedure acUndoChkOutExecute(Sender: TObject);
    procedure mmiTBModuleClick(Sender: TObject);
    procedure mmiTBToolsClick(Sender: TObject);
    procedure mmiTBWindowClick(Sender: TObject);
    procedure mmiChckoutbycurruserClick(Sender: TObject);
    procedure mmiDefineClick(Sender: TObject);
    procedure mmiProjectdependenciesClick(Sender: TObject);
    procedure mmiSettingsClick(Sender: TObject);
    procedure acAddtoCustFiltExecute(Sender: TObject);
    procedure mmiShowcustofilterClick(Sender: TObject);
    procedure mmiApplycustomfilterClick(Sender: TObject);
    procedure History1Click(Sender: TObject);
    procedure mmiDefineWCViewClick(Sender: TObject);
    procedure mmiShowMsgWinClick(Sender: TObject);
    procedure Clearmessagewindow1Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure mdSecureMail1MessageAvail(Sender: TObject; Msg: string);
    procedure mmiInternalNotifyactiveClick(Sender: TObject);
    procedure SearchTimerTimer(Sender: TObject);
    procedure mmiCrossRefListClick(Sender: TObject);
    procedure CheckforBuildOK1Click(Sender: TObject);
    procedure UpdateTimerTimer(Sender: TObject);
    procedure Allprojects1Click(Sender: TObject);
    procedure Currentproject1Click(Sender: TObject);
    procedure MoveModules1Click(Sender: TObject);
    procedure Showprojecttree1Click(Sender: TObject);
    procedure RenameProject1Click(Sender: TObject);
    procedure PurgeProjects1Click(Sender: TObject);
    procedure RemoveProjects1Click(Sender: TObject);
    procedure RefreshTimerTimer(Sender: TObject);
    procedure mmiAutorefreshClick(Sender: TObject);
    procedure acShowSharedByExecute(Sender: TObject);
    procedure acAddSharedExecute(Sender: TObject);
    procedure acFileFamiliesExecute(Sender: TObject);
    procedure acHideModuleExecute(Sender: TObject);
    procedure Showdesertedmodules1Click(Sender: TObject);
    procedure mmiProjectDescriptionClick(Sender: TObject);
    procedure mmiShowhiddenmodulesClick(Sender: TObject);
    procedure acLabelManagerExecute(Sender: TObject);
    procedure acDescriptionExecute(Sender: TObject);
    procedure mmiUserlistClick(Sender: TObject);
    procedure mmiServeroptionsClick(Sender: TObject);
    procedure acWhoamiExecute(Sender: TObject);
    procedure elvModulesDblClick(Sender: TObject);
    procedure mmiSearchmodulesClick(Sender: TObject);
    procedure Projectbasedrights1Click(Sender: TObject);
    procedure Changeserverpassword1Click(Sender: TObject);
    procedure Definemilestones1Click(Sender: TObject);
    procedure Deletedprojects1Click(Sender: TObject);
    procedure mmiNewProjectClick(Sender: TObject);
    procedure mmiOpenProjectClick(Sender: TObject);
    procedure mmiConnectserverClick(Sender: TObject);
    procedure mmiDisconnectserverClick(Sender: TObject);
    procedure mmiMergeClick(Sender: TObject);
    procedure mmiVCSpropertiesClick(Sender: TObject);
    procedure AboutFreeVCS1Click(Sender: TObject);
    procedure mmiCloseProjectClick(Sender: TObject);
    procedure mmiBranchClick(Sender: TObject);
    procedure HelpTopics1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure acCopy2ClipExecute(Sender: TObject);
    procedure acAddFoldersExecute(Sender: TObject);
    procedure mmiMSManagerClick(Sender: TObject);
    procedure acSendMessageExecute(Sender: TObject);
    procedure elvModulesKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure acBugManagerExecute(Sender: TObject);
    procedure mmiProjectBugTrackingClick(Sender: TObject);
    procedure acModuleBugsExecute(Sender: TObject);
    procedure CompareFolders1Click(Sender: TObject);
    procedure ProjectHierarchy1Click(Sender: TObject);
    procedure acOpenParentFolderExecute(Sender: TObject);
    procedure dfsStatusBarPanels5Click(Sender: TObject);
    procedure elvModulesSortItems(Sender: TObject; Item1, Item2: TListItem;
      SortColumn: Integer; var SortAs: TSortAs; var CompResult: Integer);
    procedure acViewArchiveVersionExecute(Sender: TObject);
    procedure acSynchronizeExecute(Sender: TObject);
    procedure ReverseSelection1Click(Sender: TObject);
    procedure acHideAppExecute(Sender: TObject);
    procedure DirectSQL1Click(Sender: TObject);
    procedure DistributionArchive1Click(Sender: TObject);
    procedure JediVcsLinkPlaceholderClick(Sender: TObject);
    procedure LocalProjectFolder1Click(Sender: TObject);
    procedure NotArchieved1Click(Sender: TObject);
    procedure SMTPStatus1Click(Sender: TObject);
    procedure acRenameModuleExecute(Sender: TObject);
    procedure mmiShowLocalInfoClick(Sender: TObject);
    procedure uilPluginManager1BeforeLoad(Sender: TObject;
      FileName: string; var AllowLoad: Boolean);
    procedure Configure1Click(Sender: TObject);
    procedure AboutPlugins1Click(Sender: TObject);
    procedure ExpertMenu1Click(Sender: TObject);
    procedure mmiChangedDifferentClick(Sender: TObject);
    procedure mmiModuleListReportSelClick(Sender: TObject);
    procedure pmiLogtoFileClick(Sender: TObject);
    procedure UserCurrentProject1Click(Sender: TObject);
    procedure UserAllprojects1Click(Sender: TObject);
    procedure AllUsersAllProjects1Click(Sender: TObject);
    procedure AllUsersCurrentProject1Click(Sender: TObject);
    procedure pmiIncludeTimestampClick(Sender: TObject);
    procedure acProjectTreeExecute(Sender: TObject);
    procedure acShowToDoWinExecute(Sender: TObject);
    procedure acProjectBugExecute(Sender: TObject);
    procedure acShowBugWinExecute(Sender: TObject);
    procedure acShowModuleHistoryWinExecute(Sender: TObject);
    procedure Project1Click(Sender: TObject);
    procedure uilPluginManager1NewCommand(Sender: TObject; ACaption, AHint, AData: string;
    AShortCut: TShortCut; ABitmap: TBitmap;
    AEvent: TNotifyEvent);
    procedure uilPluginManager1AfterLoad(Sender: TObject; FileName: string;
      const ALibHandle: Cardinal; var AllowLoad: Boolean);
    procedure FormActivate(Sender: TObject);
    procedure elvModulesSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure acLockedModuleWinExecute(Sender: TObject);
    procedure Panel1Resize(Sender: TObject);
    procedure acLineHistoryExecute(Sender: TObject);
    procedure mnpgMainCloseClick(Sender: TObject);
    procedure pmnPageControlMainPopup(Sender: TObject);
    procedure mmiOpenBranchClick(Sender: TObject);
    procedure mmiNewBranchClick(Sender: TObject);
    procedure mmiManageFavoritesClick(Sender: TObject);
    procedure mmiFavAddCurrentProjectClick(Sender: TObject);
    procedure mmiLabelHistoryClick(Sender: TObject);
    procedure mmiVCSBrowserClick(Sender: TObject);
    procedure mmiRemoveBranchClick(Sender: TObject);
    procedure acCopyModulenameClipboardExecute(Sender: TObject);
    procedure acDiff1Execute(Sender: TObject);
    procedure acCompareAllLocalArchiveExecute(Sender: TObject);
  private
    { Private-Deklarationen }
    FInitialized,
    bStopRefresh,
    bLVReady,
    ArchiveAdmin: Boolean;
    DelphiModules,
    SharedModuleIDs,
    ProjectFolders,
    ModuleBugs: TStringList;
    OpenHistory: TJVCSMruList;
    LibPath,
    NtfyMsgTextColor,
    WildCardFilter: string;
    MsgWinHeight,
    ProjectFolderWidth,
    FilteredModules,
    NtfyMsgCount,
    NtfyFilter,
    LVColorNew,
    LVColorOut,
    LVColorNA,
    BugStateFilter,
    ProjectModuleSize,
    NoFoundIcon: Integer;
    ColWidth: TColWidth;
    FormSize: TFormSize;
    TBPos: TTBPos;
    TickCount: DWORD;
    CustFF: array [0..9] of string;
    CustSelMI: array [0..9] of TMenuItem;
    ArchTStamp: Double;
    FReadedDockForms: Boolean;
    FSystemImagesOffset: Integer;
    FMustSetMaximized: Boolean;
    FIsInFillListView: Boolean;
    FIsInacRefreshModuleList: Boolean;
    FSelectedModuleID: Integer;
    FSelectedModuleName: string;
    FSelectedModuleLock: TRTLCriticalSection;
    FLabelList: TIDToNameList;
    FProjectLabelList: TModuleRevisionLabelList;
    FLineHistoryProvider: TJVCSConnectionLineHistoryProvider;
    FLineHistorySettings: TJVCSLineHistorySettings;
    FCurrentModuleFileNames: TStringList;
    {$IFNDEF IDEDLL}
    FRefreshProjects: TRefreshProjects;
    {$ENDIF ~IDEDLL}
    {$IFDEF REPORTDLL}
    ReportDLLHandle: THandle;
    {$ENDIF REPORTDLL}
    {$IFNDEF  DELPHI7_UP}
      FThemeManager : TThemeManager;
    {$ENDIF}
    {$IFNDEF IDEDLL}
    FPressedESC: Boolean;
    OpenProjectBusy: Boolean;
    FIcon: TIcon;
    // Taskbar icon
    procedure ShowIcon(const Hint: string);
    procedure HideIcon;
    procedure WMIconCallback(var Msg: TMessage); Message WM_ICONCALLBACK;
    procedure WMDROPFILES(var Message: TWMDROPFILES); Message WM_DROPFILES;
    {$ENDIF ~IDEDLL}
    {$IFDEF IDEDLL}
    procedure GetAllFileFamilyExtensions(var slAllFamilies, slExtensions: TStringList);
    procedure WMIDEActivation(var Msg: TMessage); Message WM_IDEACTIVATION;
    {$ENDIF IDEDLL}
    procedure ReadAndShowDockedWindows;
    procedure WMAppStartup(var Msg: TMessage); Message WM_APPSTARTUP;
    procedure GetVCSOptions;
    procedure GetArchiveTimeStamp(var TStamp: Double);
    procedure SetServerStatus;
    procedure SetStatusBar;
    procedure ShowStatusBarGauge(const ShowGauge, Indeterminate: Boolean);
    procedure StatusBarGaugePos(Value: Word);
    procedure SetStatusWinState;
    procedure AddMessage(MsgStr: string; const MsgCol: Word);
    procedure SetMenuState;
    procedure SetMenuStateEx;
    procedure SetCaption;
    function ArchivedModuleSelected: Boolean;
    procedure SaveFormSize;
    function GetArchiveCRC(ModuleID: string): string;
    function GetArchiveProject(const DlgCaption: string;
      var SelectedProjectID: Integer;
      var SelectedProjectName: string): Boolean;
    function Check_Create_Project(const ProjectName: string;
      const ShowMsg: Boolean; var ProjectID: Integer): Boolean;
    procedure GetModuleBugs(const ShowMsg: Boolean);
    function GetBugStateIndex(const ModuleID: Integer): Integer;
    function GetFakeImageIndex(const AFakeFilename: string;
      IsADirectory: Boolean): Integer;
    function GetFileImageIndex(const AFileName: string; const AShowLocalInfo, AExists: Boolean): Integer;
    procedure GetSharedModules(const ShowMsg: Boolean);
    procedure GetLabels;
    procedure GetLabelAssignement(const ShowMsg: Boolean);
    function GetLabelName(const LabelID: Integer): string;
    function GetModuleRevisionLabels(AModuleID, ARevisionID: Integer): string;
    procedure HandleDescription(const DescType, ID: Integer;
      const DescCaption: string);
    procedure AddNewModule(const ModuleName: string; const ModuleID: Integer);
    procedure ADD_Refresh_Module(const Add: Boolean;
      const LVItemIndex: Integer; ModuleID: Integer;
      const Module_Name_Path: string);
    procedure RefreshModules;
    procedure ShowSelectedLVItem;
    procedure FillListView;
    procedure AddModules(const DlgInitialDir: string);
    function AddModule(const CurrentModule: string): Integer;
    procedure LoadAllModules;
    procedure UnLoadAllModules;
    procedure CustSelClick(Sender: TObject);
    procedure ReadFF;
    procedure GetLockedModules(QueryTyp: Integer);
    function GetListViewString(Sel: Boolean): string;
    procedure OpenProject(SelectedProjectID: Integer; SelectedProjectName: string); //IJVCSProjectManager
    function GetIJVCSProjectManager: IJVCSProjectManager;
    {$IFNDEF IDEDLL}
    procedure OpenRecentProjectClick(Sender: TObject);
    procedure OpenFavoriteProjectClick(Sender: TObject);
    procedure ShowProjectTree(AVisible: Boolean);
    {$ENDIF ~IDEDLL}
    procedure ShowToDoWin(AVisible: Boolean);
    procedure ShowBugWin(AVisible: Boolean);
    procedure ShowModuleHistoryWin(AVisible: Boolean);
    procedure ShowLockedModulesWin(AVisible: Boolean);    
    procedure CreateInternetLinkMenuItems;
    procedure RemoveModules(Sender: TObject);
    {$IFDEF LANGUAGE}
    procedure HandleAfterChangedLanguage(const ALanguageCode: string);
    {$ENDIF LANGUAGE}
    procedure ShowLineHistory(const AModuleName: string; const AModuleMember: string = '');
    {$IFNDEF IDEDLL}
    procedure ReadFavorites;
    procedure RemoveLineHistoryPages;
    {$ENDIF ~IDEDLL}
    procedure LineHistoryRevisionClick(Sender: TObject; ARevisionIDStr: string);
    procedure LineHistorySettingsChanged(Sender: TObject);
    procedure LoadLineHistorySettings;
    procedure SaveLineHistorySettings;
    {$IFDEF BRANCHING}
    procedure OpenBranch(ANewBranchID: Integer);
    {$ENDIF BRANCHING}
    procedure SelectionOfModules(const aSelectAction : TSelectAction);
    procedure UpdateDiffActions;
  protected
    {$IFDEF BRANCHING}
    procedure Loaded; override;
    {$ENDIF BRANCHING}
    {$IFNDEF IDEDLL}
      {$IFNDEF DELPHI2007_UP}   //VISTA support integrated ok since DELPHI2007
      procedure CreateParams(var Params: TCreateParams); override;
      procedure WMSyscommand(var Message: TWmSysCommand); message WM_SYSCOMMAND;
      procedure WMActivate(var Message: TWMActivate);
      {$ENDIF ~DELPHI2007_UP}
    {$ENDIF ~IDEDLL}
  public
    { Public-Deklarationen }
    function GetSelectedModuleID: Integer; //IJVCSProjectManager
    function GetSelectedModuleName: string; //IJVCSProjectManager
    procedure ExecuteBugManager; //IJVCSProjectManager
    procedure ExecuteProjectBugManager; //IJVCSProjectManager
    procedure ExecuteModuleBugManager; //IJVCSProjectManager
    procedure RefreshSingleModule(AModuleID: Integer); //IJVCSProjectManager
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

var
  VCSProjAdmin: TVCSProjAdmin;
  {$IFDEF REPORTDLL}
  fvcsReportDLLInitProc: TfvcsReportDLLInitProc;
  fvcsSelectReport: TfvcsSelectReport;
  {$ENDIF REPORTDLL}

implementation

uses
  {$IFDEF IDEDLL}
  UsedComponents, UsedUnits, ProjDependencies, VerSet,
  {$ELSE}
  Create, OpenProject, UsedUnits, ProjDependencies,
  {$ENDIF IDEDLL}
  {$IFDEF DEBUG}
  JclDebug,
  {$ENDIF DEBUG}
  {$IFDEF LANGUAGE}
  JvGnugettext, JVCSLanguage,
  {$ENDIF LANGUAGE}
  {$IFDEF BRANCHING}
  JVCSSelectBranchDialog, JVCSBranchClientObj, JVCSCreateBranchDialog, WaitforServer,
  {$ENDIF BRANCHING}
  VCSBase, ShellAPI, VCSProcBase, Yes2AllDlg, ModuleInfo, FileCtrl, JVCSDialogs,
  TextComp, CustViewFilter, HandleBlob, History, ChkInSingle, ChkOutSingle, ToDo,
  Touch, Checksum, Backup, Printers, ShowTimeLog, FileFamilies, IniFiles,
  ProjectHist, WCViewFilter, NtfySend, CrossRefList, CheckfBuild, MoveModules,
  RenameProj, RemoveProj, Purge, ProjectTree, DBModule, MaintainLabels, ClipBrd,
  AssignLabels, AddShareModule, MaintainFFamilies, Description, SelectProjectID,
  MaintainUsers, ServerOptions,
  {$IFNDEF REPORTDLL}
  Report,
  {$ENDIF ~REPORTDLL}
  Std_ListView, SearchModules, ProjectRights, ChangeUserPW, Whoami,
  AssignMilestones, Syncronice, MergeVersion, Options, About, Branch,
  SelectFolder, MaintainMilestones, SimpleReport, KWExpansion, MaintainBugs,
  AssignBugs, CompareFolders, LoadModule, DirectSQL, Distribution, {ProjectRoot,}
  SMTPSend, TZHandling, Plugins, GetGlobalSettings, JclStrings, JclSecurity, JclWin32,
  ConfigStorage, Registry, BugWindow, ModuleHistoryWindow, JclFileUtils,
  JVCSClientFunctions, JVCSClientConsts, JVCSCrypt, VCSCommon,
  {$IFNDEF IDEDLL}
  ProjectTreeDockWnd, JVCSManageFavorites, JvMRUManager,
  {$ENDIF ~IDEDLL}
    ToDoDockWnd
  {$IFDEF DEBUG}
  , JVCSDebug
  {$ENDIF DEBUG}
  , JVCSGUIClientResources, Progress, JVCSFunctions, JVCSLockedModulesDockWnd,
  JVCSCompressedDiffDialog;

{$R *.dfm}

//------------------------------------------------------------------------------

//thu 28.07.2003
// Returns all defined child file extensions
{$IFDEF IDEDLL}
procedure TVCSProjAdmin.GetAllFileFamilyExtensions(var slAllFamilies, slExtensions: TStringList);
var
  slTmp: TStringList;
  sTmpParent, sTmpChildren: string;
  ii: Integer;
begin
  {$IFDEF DEBUG}
  JclDebug.TraceMsg('>PM: GetAllFileFamilyExtensions');
  {$ENDIF DEBUG}
  if Assigned(slExtensions) then
  begin
    with DataModule1 do
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_FILE_FAMILIES';
      AppSrvClient1.Request.WriteFields(True,  [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True,  [False]);
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
        ShowServerError ( WindowHandle
                        , AppSrvClient1.Answer.Fields[0]
                        , AppSrvClient1.AnswerStatus
                        );
        Exit;
      end;

      {$IFDEF DEBUG}
      JclDebug.TraceMsg('PM: GetAllFileFamilyExtensions: Found: '+
                        AnsiLowerCase(IntToStr(AppSrvClient1.Answer.RecordCount))
                      );
      {$ENDIF DEBUG}
      slTmp := TStringList.Create;
      try
        slExtensions.Clear;
        slExtensions.Duplicates := dupIgnore;
        slExtensions.Sorted := True;
        AppSrvClient1.Answer.First;
        while (not AppSrvClient1.Answer.Eof) do
        begin
          sTmpParent   := AnsiLowerCase(AppSrvClient1.Answer.Fields[2]);
          sTmpChildren := AnsiLowerCase(AppSrvClient1.Answer.Fields[3]);
          // Add complete file family to slAllFamilies stringlist in the form of '.parent=.child1;.child2;...'
          slAllFamilies.Add(sTmpParent + '=' + sTmpChildren);
          // Add each child extension to slExtensions stringlist, one extension per line
          StrTokenToStrings(sTmpChildren, ';', slTmp);
          for ii := 0 to slTmp.Count-1 do
          begin
            if Trim(slTmp[ii])<>'' then
            begin
              slExtensions.Add(slTmp[ii]);
            end;
          end;
          AppSrvClient1.Answer.Next;
        end; // while (not AppSrvClient1.Answer.EoF)
      finally
        slTmp.Free;
      end;
      {$IFDEF DEBUG}
      JclDebug.TraceMsg('PM: GetAllFileFamilyExtensions: All extensions: '+
                        StringsToStr(slExtensions, ';', True)
                      );
      {$ENDIF DEBUG}
    end; // with DataModule1 do begin
  end;
  {$IFDEF DEBUG}
  JclDebug.TraceMsg('<PM: GetAllFileFamilyExtensions');
  {$ENDIF DEBUG}
end;
{$ENDIF IDEDLL}

procedure TVCSProjAdmin.FormCreate(Sender: TObject);
var
  sfi: TSHFileInfo;
  DlgTop,
  DlgLeft,
  DlgWidth,
  DlgHeight: Integer;
  {$IFDEF IDEDLL}
  I, J,
  CompCount: Integer;
  CompModules: TStringList;
  {$ENDIF IDEDLL}
  wsMax: Boolean;
  {ToolTipHandle: HWND;}
begin
  FSelectedModuleID := -1;
  FSelectedModuleName := '';
  InitializeCriticalSection(FSelectedModuleLock);

  {$IFDEF DEBUG}
  JclDebug.TraceMsg('PM: FormCreate');
  {$ENDIF DEBUG}
  try
    {$IFNDEF  DELPHI7_UP}
      FThemeManager := TThemeManager.Create(self);
    {$ENDIF ~DELPHI7_UP}
    {$IFNDEF IDEDLL}
    sDLLDirectory := GetSelfFileLocation;
      {$IFNDEF DELPHI2007_UP}   //VISTA support integrated ok since DELPHI2007
      // fixes VISTA Taskbarsupport
      ShowWindow(Application.Handle, SW_HIDE);
      SetWindowLong ( Application.Handle, GWL_EXSTYLE
                    , GetWindowLong(Application.Handle, GWL_EXSTYLE) and not WS_EX_APPWINDOW or WS_EX_TOOLWINDOW);
      ShowWindow(Application.Handle, SW_SHOW);
      {$ENDIF ~DELPHI2007_UP}
    {$ENDIF ~IDEDLL}
    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);
    Screen.Cursor := crHourGlass;

    {$IFDEF REPORTDLL}
    ReportDLLHandle := 0;
    acPrintReports.Visible := (FileExists(ExtractFilePath(Application.ExeName) + cJVCSReportDll));
    {$ENDIF REPORTDLL}
    {$IFNDEF IDEDLL}
    FIcon := TIcon.Create;
    FIcon.Handle := LoadIcon(hInstance, 'TB_ICON');
    jvcsWriteString(cRegSwJVCSBase, 'BaseRegistryKey', sBaseRegistryKey);
    {sBaseRegistryKey := jvcsReadString(cRegSwJVCSBase, 'BaseRegistryKey', '');
    if sBaseRegistryKey = '' then
    begin
      sBaseRegistryKey := cRegSwJVCSBase;
      jvcsWriteString(cRegSwJVCSBase, 'BaseRegistryKey', sBaseRegistryKey);
    end;}
    //Debug
    ShowDebugMsg := jvcsReadBool(sBaseRegistryKey + crbOptions,
      'OutputDebugStrActive', False);
    if ShowDebugMsg then
    begin
      // NT ?
      if Win32Platform = VER_PLATFORM_WIN32_NT then
      begin
        //hu25.11.2002       if S e t P rivilege(SE_DEBUG) then
        if not EnableProcessPrivilege(True, SE_DEBUG_NAME) then
        begin
          //???
          {$IFDEF DEBUG}
          JclDebug.TraceMsg(PChar(cPrgType + 'JclDebug .TraceMsg enabled.' + #0));
          {$ENDIF DEBUG}
          Windows.Beep(1000, 100);
        end;
      end
      else
      begin
        {$IFDEF DEBUG}
        JclDebug.TraceMsg(PChar(cPrgType + 'JclDebug .TraceMsg enabled.' + #0));
        {$ENDIF DEBUG}
        Windows.Beep(1000, 100);
      end;
    end;

    ReadShortcutsFromStorage;

    OpenProjectBusy := False;
    FIsInFillListView := False;
    FIsInacRefreshModuleList := False;
    SetUpUserInfo;
    SystemParametersInfo(SPI_GETWORKAREA, 0, @trResDesktop, 0);
    // disable Menu items
    mmiSettings.Enabled := False;
    mmiUsedComponents.Enabled := False;
    LoadallIDEmodules1.Enabled := False;
    UnloadallIDEmodules1.Enabled := False;
    mmiSettings.Visible := False;
    mmiUsedComponents.Visible := False;
    LoadallIDEmodules1.Visible := False;
    UnloadallIDEmodules1.Visible := False;
    N37.Visible := False;
    N1.Visible := False;
    miClose.Caption := JVCSRES_E38xit;
    miClose.ShortCut := TextToShortCut('Alt+X');
    dfsStatusBar.Panels[2].Text := '';
    dfsStatusBar.Panels[3].Text := '';
    {$ELSE}
    BorderIcons := [biSystemMenu, biMinimize, biMaximize];
    mmiNewProject.Enabled := False;
    mmiOpenProject.Enabled := False;
    mmiOpenRecentProject.Enabled := False;
    mmiFavorites.Enabled := False;
    mmiCloseProject.Enabled := False;
    mmiConnectserver.Enabled := False;
    mmiDisconnectserver.Enabled := False;
    mmiNewProject.Visible := False;
    mmiOpenProject.Visible := False;
    mmiOpenRecentProject.Visible := False;
    mmiFavorites.Visible := False;
    mmiCloseProject.Visible := False;
    mmiConnectserver.Visible := False;
    mmiDisconnectserver.Visible := False;
    //  N47.Visible := False;
    N12.Visible := False;
    N40.Visible := False;
    HideApplication1.Visible := False;
    N48.Visible := False;
    {$ENDIF ~IDEDLL}
    {$IFNDEF CUSTOMDRIVE}
    LocalProjectFolder1.Visible := False;
    N60.Visible := False;
    {$ENDIF ~CUSTOMDRIVE}
    bLVReady := False;
    CustSelMI[0] := mmiCustSel0;
    CustSelMI[1] := mmiCustSel1;
    CustSelMI[2] := mmiCustSel2;
    CustSelMI[3] := mmiCustSel3;
    CustSelMI[4] := mmiCustSel4;
    CustSelMI[5] := mmiCustSel5;
    CustSelMI[6] := mmiCustSel6;
    CustSelMI[7] := mmiCustSel7;
    CustSelMI[8] := mmiCustSel8;
    CustSelMI[9] := mmiCustSel9;

    if (ExtractFileName(sProjectName) <> '') then
      mmiApplycustomfilter.Checked := jvcsReadBool(sBaseRegistryKey + crbProjects +
        ExtractFileName(sProjectName), 'ApplyCustFilter', False)
    else
      mmiApplycustomfilter.Checked := False;

    mmiInternalNotifyactive.Checked := jvcsReadBool(sBaseRegistryKey + crbWindows,
      'ProjMan_NotifyActive', False);

    //THe: need to change this to something like ReadBinData...
    with ColWidth do
    begin
      Col[colName] :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Col1.0', 130);
      Col[colType] :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Col1.1', 50);
      Col[colPath] :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Col1.2', 150);
      Col[colVer] :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Col1.3', 40);
      Col[colState] :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Col1.4', 38);
      Col[colOwner] :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Col1.5', 50);
      Col[colCount] :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Col1.6', 41);
      Col[colKeyWord] :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Col1.7', 70);
      Col[colShare] :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Col1.8', 36);
      Col[colSize] :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Col1.9', 50);
      Col[colDate] :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Col1.10', 75);
      Col[colAttr] :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Col1.11', 50);
      Col[colMID] :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Col1.12', 40);
    end;

    MsgWinHeight :=
      jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_MsgWinHeight', 85);
    mmiShowhiddenmodules.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbWindows, 'ProjMan_ShowHiddenModules', True);
    pmiLogtoFile.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbWindows, 'ProjMan_LogMsg2File', False);
    pmiIncludeTimestamp.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbWindows, 'ProjMan_IncludeTimeStamp', False);

    with TBPos do
    begin
      MBTop :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Tb1.0', 2);
      MBLeft :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Tb1.1', 11);
      TBToolTop :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Tb1.2', 28);
      TBToolLeft :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Tb1.3', 496);
      TBModuleTop :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Tb1.4', 28);
      TBModuleLeft :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Tb1.5', 11);
      TBWindowTop :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Tb1.6', 2);
      TBWindowLeft :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Tb1.7', 473);
      TBModuleVis :=
        jvcsReadBool(sBaseRegistryKey + crbWindows, 'ProjMan_Tb1.8', True);
      TBWindowVis :=
        jvcsReadBool(sBaseRegistryKey + crbWindows, 'ProjMan_Tb1.9', True);
      TBToolVis :=
        jvcsReadBool(sBaseRegistryKey + crbWindows, 'ProjMan_Tb1.10', True);
    end;

    wsMax := jvcsReadBool(sBaseRegistryKey + crbWindows, 'ProjMan_Maximized', False);
    FMustSetMaximized := wsMax;
    if wsMax then
    begin
      WindowState := wsMaximized;
      Top := 0;
      Left := 0;
      Width := trResDesktop.Right;
      Height := trResDesktop.Bottom;
    end
    else
    begin
      if not jvcsReadWindowPosAndSize(sBaseRegistryKey + crbWindows, 'ProjMan',
        DlgTop, DlgLeft, DlgWidth, DlgHeight) then
      begin
        DlgWidth := 710;
        DlgHeight := 460;
        if DlgWidth > Screen.Width then
          DlgWidth := Screen.Width - 40;
        if DlgHeight > Screen.Height then
          DlgHeight := Screen.Height - 40;
        DlgTop := (Screen.Height - DlgHeight) div 2;
        DlgLeft := (Screen.Width - DlgWidth) div 2;
      end;
      Top := DlgTop;
      Left := DlgLeft;
      Width := DlgWidth;
      Height := DlgHeight;
    end;

    ProjectFolderWidth :=
      jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_TreeWidth', 150);
    tvHierachyPlaceholder.Width := ProjectFolderWidth;

    LibPath :=
      jvcsReadString(sBaseRegistryKey + '\Library', 'ComponentLibrary', '');

    FormSize.Top := Top;
    FormSize.Left := Left;
    FormSize.Width := Width;
    FormSize.Height := Height;

    //@#Q
    tsMessages.TabVisible := jvcsReadBool(sBaseRegistryKey + crbWindows, 'ProjMan_MsgWinState', True);
    SetStatusWinState;
    //THu SetMsgWinState(jvcsReadBool(sBaseRegistryKey + crbWindows, 'ProjMan_MsgWinState', True));
    {$IFDEF IDEDLL}
    acProjectTree.Checked := False;
    acProjectTree.Visible := False;
    {$ENDIF IDEDLL}
    tvHierachyPlaceholder.Visible := False;
    JvSplitter1.Visible := False;
    FReadedDockForms := False;

    ExpertMenu1.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'ExpertMenu', False);
    SetMenuMode;

    DelphiModules := TStringList.Create;
    DelphiModules.Sorted := True;
    DelphiModules.Duplicates := dupIgnore;
    ProjectFolders := TStringList.Create;
    SharedModuleIDs := TStringList.Create;
    ModuleBugs := TStringList.Create;
    OpenHistory := TJVCSMruList.Create;
    OpenHistory.MaxSize := 5;
    OpenHistory.LoadFromStorage(sBaseRegistryKey + crbMRU + '9');

    mmiDefineWCView.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'WildCardFilterActive', False);
    WildCardFilter :=
      jvcsReadString(sBaseRegistryKey + crbOptions, 'WildCardFilter', '');
    BugStateFilter := -1;

    //Systemsymbole in eine TImageList-Komponente einlesen
    SysImageList.Handle := SHGetFileInfo('', 0, sfi, SizeOf(TSHFileInfo),
      SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
    SysImageList.ShareImages := True;
    FSystemImagesOffset := 1;

    // Set width of ListView.Columns
    with elvModules do
    begin
      Columns[colName].Width := ColWidth.Col[colName];
      Columns[colType].Width := ColWidth.Col[colType];
      Columns[colPath].Width := ColWidth.Col[colPath];
      Columns[colVer].Width := ColWidth.Col[colVer];
      Columns[colState].Width := ColWidth.Col[colState];
      Columns[colOwner].Width := ColWidth.Col[colOwner];
      Columns[colCount].Width := ColWidth.Col[colCount];
      Columns[colKeyWord].Width := ColWidth.Col[colKeyWord];
      Columns[colShare].Width := ColWidth.Col[colShare];
      Columns[colSize].Width := ColWidth.Col[colSize];
      Columns[colDate].Width := ColWidth.Col[colDate];
      Columns[colAttr].Width := ColWidth.Col[colAttr];
      Columns[colMID].Width := ColWidth.Col[colMID];
      {$IFNDEF SHOWIDS}
      Columns[colRID].Width := 0;
      Columns[colMID].Width := 0;
      {$ENDIF ~SHOWIDS}
    end;

    with TBPos do
    begin
      if (MBTop > ControlBar1.Height) or (MBLeft > ControlBar1.Width) then
      begin
        MenuBar1.Top := 2;
        MenuBar1.Left := 11;
      end
      else
      begin
        MenuBar1.Top := MBTop;
        MenuBar1.Left := MBLeft;
      end;
      mmiTBTools.Checked := TBPos.TBToolVis;
      TBTool.Visible := mmiTBTools.Checked;
      mmiTBModule.Checked := TBPos.TBModuleVis;
      TBModule.Visible := mmiTBModule.Checked;
      mmiTBWindow.Checked := TBPos.TBWindowVis;
      TBWindow.Visible := mmiTBWindow.Checked;
      TBWindow.Top := TBWindowTop;
      TBWindow.Left := TBWindowLeft;
      TBModule.Top := TBModuleTop;
      TBModule.Left := TBModuleLeft;
      TBTool.Top := TBToolTop;
      TBTool.Left := TBToolLeft;
    end;

    GetVCSOptions;
    {$IFNDEF IDEDLL}
    FRefreshProjects := TRefreshProjects.Create(Self);
    RefreshDispatcher.AddClient(FRefreshProjects);
    FPressedESC := False;
    {$ENDIF ~IDEDLL}

    Screen.Cursors[cSrvWaitCursor] := LoadCursor(hInstance, PChar('SRVWAIT'));

    {$IFNDEF IDEDLL}
    // Let Windows know we accept dropped files
    DragAcceptFiles(VCSProjAdmin.Handle, True);
    {$ENDIF ~IDEDLL}


    {$IFDEF IDEDLL}
    // Komponenetenliste einlesen
    if jvcsReadBool(sBaseRegistryKey + crbOptions, 'AddComponentList', False) then
    begin
      CompModules := TStringList.Create;
      try
        CompModules.Add(' VCL Library overview');
        CompModules.Add(' This file is maintained by JEDI VCS');
        CompModules.Add(' State: ' + LocalDT2GMTStr(Now));
        CompModules.Add(' ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
        CompCount := 0;
        with IDEInterface do
        begin
          for I := 0 to GetModuleCount - 1 do
          begin
            CompModules.Add(' > ' + GetModuleName(I));
            for J := 0 to GetComponentCount(I) - 1 do
            begin
              CompModules.Add(' - ' + GetComponentName(I, J));
              Inc(CompCount);
            end;
          end;
          CompModules.Insert(3, ' Packages (>): ' + IntToStr(GetModuleCount));
          CompModules.Insert(4, ' Components (-): ' + IntToStr(CompCount));
        end; // with IDEInterface do begin
        FileSetAttr(sDLLDirectory + cIDEComponentListFile,
          FileGetAttr(sDLLDirectory + cIDEComponentListFile) and not $00000001);
        try
          CompModules.SaveToFile(sDLLDirectory + cIDEComponentListFile);
        except
          MessageBox(WindowHandle, PChar(Format(JVCSRES_JEDI_VCS_cannot_save_the_file + #13#10 +
            '<%s>.' + JVCSRES_Be_sure_that_the_file_is_not_opened_by_another_application44 +
            JVCSRES_that_there_is_enough_free_space_on_the_disk + #13#10 +
            JVCSRES_and_that_you_have_the_required_access_rights46,
            [sDLLDirectory + cIDEComponentListFile])),
            cMsgBoxCaption, MB_OK or MB_ICONSTOP);
        end;
      finally
        CompModules.Free;
      end;
    end; // if if RegReadBool(... then begin
    {$ENDIF IDEDLL}

    NoFoundIcon := 0;

    NtfyMsgCount := 0;
    reMessage.SelAttributes.Color := clWindowText;
    if mmiInternalNotifyactive.Checked then
    begin
      try
        mdSecureMail1.Server := '.';
        mdSecureMail1.Slot := 'FVCSMail';
        mdSecureMail1.Open;
        if mdSecureMail1.Active then
        begin
          AddMessage(Format(JVCSRES_Internal_Notify58_Server58_914693_47_Mailslot58_91FVCSMail93_45_Init58_37s,
            [JVCSRES_Success]), msclNormal);
        end
        else
        begin
          AddMessage(Format(JVCSRES_Internal_Notify58_Server58_914693_47_Mailslot58_91FVCSMail93_45_Init58_37s,
            [JVCSRES_Error]), msclError);
          AddMessage(JVCSRES_Warning33_Notify_services_may_not_be_available, msclError);
        end;
      except
        on E :
        Exception do
        begin
          AddMessage(Format(JVCSRES_Internal_Notify_Init_raised_exception58_37s, [E.Message]), msclError);
          AddMessage(JVCSRES_Warning33_Notify_services_may_not_be_available, msclError);
        end;
      end;
    end //   if mmiInternalNotifyactive.Checked then begin
    else
    begin
      AddMessage(Format(JVCSRES_Internal_Notify58_Server58_914693_47_Mailslot58_91FVCSMail93_45_Init58_37s,
        [JVCSRES_not_active]), msclNormal);
      Sendmessage1.Enabled := False;
      acSendMessage.Enabled := False;
    end;

    CreateInternetLinkMenuItems;
    FLabelList := TIDToNameList.Create;
    FProjectLabelList := TModuleRevisionLabelList.Create;
    FLineHistoryProvider := nil;
    FLineHistorySettings := nil;
    FCurrentModuleFileNames := TStringList.Create;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    AddLanguageMenuItem(Options1, 'jedivcs', HandleAfterChangedLanguage);
    {$ENDIF LANGUAGE}
  end;
  {$IFDEF DEBUG}
  JclDebug.TraceMsg('PM: FormCreate Exit');
  {$ENDIF DEBUG}
  Screen.Cursor := crDefault;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.GetVCSOptions;
begin
  {$IFDEF DEBUG}
  JclDebug.TraceMsg('PM: GetVCSOptions');
  {$ENDIF DEBUG}

  if sProjectName <> '' then
    mmiActive.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbTimeLog, ExtractFileName(sProjectName), False);

  RefreshTimer.Interval :=
    jvcsReadInteger(sBaseRegistryKey + crbOptions, 'RefreshTimer', 600000); // 10min
  RefreshTimer.Enabled :=
    jvcsReadBool(sBaseRegistryKey + crbOptions, 'RefreshTimerEnabled', False);
  mmiAutorefresh.Checked := RefreshTimer.Enabled;
  mmiAutorefresh.Caption := Format(JVCSRES_A38uto_Refresh_4037dmin41,
    [RefreshTimer.Interval div 60000]);

  SearchTimer.Interval :=
    jvcsReadInteger(sBaseRegistryKey + crbOptions, 'SearchTime', 750);

  LVColorNew :=
    jvcsReadInteger(sBaseRegistryKey + crbOptions, 'ModuleListColor_New', clWindowText);
  LVColorOut :=
    jvcsReadInteger(sBaseRegistryKey + crbOptions, 'ModuleListColor_Owner', clMaroon);
  LVColorNA :=
    jvcsReadInteger(sBaseRegistryKey + crbOptions, 'ModuleListColor_Locked', clGray);

  mmiShowLocalInfo.Checked :=
    jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowLocalInfo', True);

  mmiShowMenuBitmaps.Checked :=
    jvcsReadBool(sBaseRegistryKey + crbWindows, 'ProjMan_ShowMenuBitmaps', True);
  mmiShowColors.Checked :=
    jvcsReadBool(sBaseRegistryKey + crbWindows, 'ProjMan_ShowListColors', True);

  NtfyFilter :=
    jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_NotifyFilter', 1);
  NtfyMsgTextColor :=
    jvcsReadString(sBaseRegistryKey + crbWindows, 'ProjMan_NotifyColor', 'clNavy');

  // Assing Shortcuts
  acCheckIn.ShortCut := cSCChkIn;
  acCheckOut.ShortCut := cSCChkOut;
  acModInfo.ShortCut := cSCGet;
  acSynchronize.ShortCut := cSCSync;
  acBackupRestore.ShortCut := cSCBckUp;
  {$IFNDEF IDEDLL}
  acHideApp.ShortCut := TextToShortCut('Shift+Ctrl+H');
  {$ENDIF ~IDEDLL}

  // Menu Bitmaps?
  if mmiShowMenuBitmaps.Checked then
  begin
    MainMenu1.Images := ToolImageList;
    PopupMenu1.Images := ToolImageList;
    popmAddModules.Images := ToolImageList;
    popupmView.Images := ToolImageList;
  end
  else
  begin
    MainMenu1.Images := nil;
    PopupMenu1.Images := nil;
    popmAddModules.Images := nil;
    popupmView.Images := nil;
  end;
  bVCSOptionsChanged := False;
  {$IFDEF DEBUG}
  JclDebug.TraceMsg('PM: GetVCSOptions Exit');
  {$ENDIF DEBUG}
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.FormShow(Sender: TObject);
begin
  UserCurrentProject1.Caption := Format(JVCSRES_37s47_Current_Project, [sCurrentUser]);
  UserAllprojects1.Caption := Format(JVCSRES_37s47_All_Projects, [sCurrentUser]);
  {$IFDEF DEBUG}
  JclDebug.TraceMsg('PM: FormShow');
  {$ENDIF DEBUG}
  if not FInitialized then
  begin
    {$IFDEF DEBUG}
    JclDebug.TraceMsg('PM: FormShow Initialiasing');
    {$ENDIF DEBUG}
    FInitialized := True;
    PostMessage(Handle, WM_APPSTARTUP, 0, 0);
  end; // if FInitialized then begin
  {$IFDEF DEBUG}
  JclDebug.TraceMsg('PM: FormShow Exit');
  {$ENDIF DEBUG}
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.ReadAndShowDockedWindows;

  function IsFormLastActivePage(S: string; AForm: TForm): Boolean;
  begin
    Result := Assigned(AForm) and (S = AForm.Name) and
      (AForm.Visible) and (AForm.HostDockSite = pgStatus);
  end;
  
var
  S: string;
begin
  if not FReadedDockForms then
  begin
    FReadedDockForms := True;
    {$IFNDEF IDEDLL}
    ShowProjectTree(jvcsReadBool(sBaseRegistryKey + crbWindows, 'ProjMan_ShowProjectTree', True));
    {$ENDIF ~IDEDLL}

    //MyToDoList visible?
    ShowToDoWin(jvcsReadBool(sBaseRegistryKey + crbWindows, 'ProjMan_ToDoWinState', False));

    //BugList visible?
    ShowBugWin(jvcsReadBool(sBaseRegistryKey + crbWindows, 'ProjMan_BugWinState', False));

    //ModuleHistoryWin-List visible?
    ShowModuleHistoryWin(jvcsReadBool(sBaseRegistryKey + crbWindows, 'ProjMan_ModHistoryWinState', False));

    //LockedModulesWin-List visible?
    ShowLockedModulesWin(jvcsReadBool(sBaseRegistryKey + crbWindows, 'ProjMan_LockedModulesWinState', False));

    S := jvcsReadString(sBaseRegistryKey + crbWindows, 'ProjMan_MsgWinActivePage', '');
    if S <> '' then
    begin
      if (S = tsMessages.Name) and (tsMessages.TabVisible) then
        pgStatus.ActivePage := tsMessages
      else
      if IsFormLastActivePage(S, JVCSDockToDoWindow) then
        SetDockClientToActivePage(pgStatus, JVCSDockToDoWindow)
      else
      if IsFormLastActivePage(S, VCSBugWindow) then
        SetDockClientToActivePage(pgStatus, VCSBugWindow)
      else
      if IsFormLastActivePage(S, VCSModuleHistoryWindow) then
        SetDockClientToActivePage(pgStatus, VCSModuleHistoryWindow)
      else
      if IsFormLastActivePage(S, JVCSDockLockedModulesWindow) then
        SetDockClientToActivePage(pgStatus, JVCSDockLockedModulesWindow);
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.WMAppStartup(var Msg: TMessage);
var
  CurrentFile: string;
  MenuBarWidth, I, SMTPRecordSize, SMTPRecordCount: Integer;
  {$IFNDEF IDEDLL}
  DisclAccepted: Boolean;
  {$ENDIF ~IDEDLL}
begin
  {$IFDEF DEBUG}
  JclDebug.TraceMsg('PM: WMAppStartup');
  {$ENDIF DEBUG}

  // "Large fonts"?
  MenuBarWidth := 0;
  for I := 0 to MenuBar1.ButtonCount - 1 do
    MenuBarWidth := MenuBarWidth + MenuBar1.Buttons[I].Width;
  MenuBar1.Width := MenuBarWidth;

  SetMenuStateEx;
  ShowStatusBarGauge(True, True);
  Screen.Cursor := crHourGlass;
  ShowStatusBarGauge(False, True);
  Update;
  try
    // Custom select
    ReadFF;
    SetCaption;
    {$IFNDEF IDEDLL}
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
    end;

    // Check for IDE Registry Keys
    //??? THe there is a logical bug anywhere in this sBaseRegistryKey stuff...
    //??? use only cRegSwJVCSBase for now
    {sBaseRegistryKey := jvcsReadString(cRegSwJVCSBase, 'BaseRegistryKey', '');
    if sBaseRegistryKey = '' then
    begin
      Reg := TRegistry.Create;
      with Reg do
      begin
        try
          RootKey := HKEY_CURRENT_USER;
          //??? THE why not in reverse order?
          if KeyExists('Software\Borland\Delphi\7.0') then
            sBaseRegistryKey := 'Software\Borland\Delphi\7.0';
          if KeyExists('Software\Borland\Delphi\6.0') then
            sBaseRegistryKey := 'Software\Borland\Delphi\6.0';
          if KeyExists('Software\Borland\Delphi\5.0') then
            sBaseRegistryKey := 'Software\Borland\Delphi\5.0';
          if (sBaseRegistryKey = '') and
            KeyExists('Software\Borland\Delphi\4.0') then
            sBaseRegistryKey := 'Software\Borland\Delphi\4.0';
          if (sBaseRegistryKey = '') and
            KeyExists('Software\Borland\C++Builder\4.0') then
            sBaseRegistryKey := 'Software\Borland\C++Builder\4.0';
          if (sBaseRegistryKey = '') and
            KeyExists('Software\Borland\C++Builder\5.0') then
            sBaseRegistryKey := 'Software\Borland\C++Builder\5.0';

          if sBaseRegistryKey <> '' then
          begin
            (* Existing registry entry of the IDE version found in\n\r%s.\n\r
               Should this entry be used for both JEDI VCS versions? 34 *)
            if MessageBox(WindowHandle, PChar(FmtLoadStr(34, ['HKCU\' + sBaseRegistryKey])),
              cMsgBoxCaption, MB_YESNOCANCEL or MB_ICONQUESTION) <> idYes then
              sBaseRegistryKey := cRegSwJVCSBase;
          end // if sBaseRegistryKey <> '' then begin
          else
            sBaseRegistryKey := cRegSwJVCSBase;
          try
            OpenKey(cRegSwJVCSBase, True);
            WriteString('BaseRegistryKey', sBaseRegistryKey);
            CloseKey;
          except
          end;
        finally
          Reg.Free;
        end; //
      end; // with Reg do begin
    end; // if sBaseRegistryKey = '' then begin}
    {$ENDIF ~IDEDLL}

    // IF with ExpertMenu
    if not jvcsReadBool(sBaseRegistryKey + crbOptions, 'ExpertMenu', False) then
    begin
      UseRegistry := True;
      DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
      DSAIdentsMessageDlg(JVCSRES_JEDI_VCS_runs_currently_in_34Beginners34_mode46 + #13#10 +
        JVCSRES_To_access_all_functionality_go_to_menu_34Options34_and + #13#10 +
        JVCSRES_check_the_menu_item_34Enable_Expert_Menu3446
        , mtInformation
        , [mbOK]
        , 0
        , sBaseRegistryKey + crbMRU + 'Dlgs'
        , 'BeginnersMenu'
        , idOk
        );
    end;

    // IF with SMTPMessages
    if jvcsReadBool(sBaseRegistryKey + crbOptions, 'SMTPMessages', False) then
    begin
      SMTPStatus1.Enabled := True;
      SMTPRecordCount := CountSMTPRecords(SMTPRecordSize);
      if SMTPRecordCount > 900 then
      begin
        BeepIfSet;
        MessageBox(Application.Handle, PChar(Format(JVCSRES_You_have_37s_SMTP_mail_records_4037n_k41_in_your_SMTP_out_folder46, 
          [Format(JVCSRES_more_than_37d, [SMTPRecordCount]), (SMTPRecordSize / 1024)]) + #13#10 +
          JVCSRES_Make_sure_that_the_JEDI_VCS_forwarder_34FVCSSMTP46exe34_is_up_and_running46),
          cMsgBoxCaption, MB_OK or MB_ICONEXCLAMATION);
      end
      else
      begin
        if SMTPRecordCount > 0 then
        begin
          UseRegistry := True;
          DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
          DSAIdentsMessageDlg(Format(JVCSRES_You_have_37s_SMTP_mail_records_4037n_k41_in_your_SMTP_out_folder46,
            [IntToStr(SMTPRecordCount), (SMTPRecordSize / 1024)]) + #13#10 +
            JVCSRES_Make_sure_that_the_JEDI_VCS_forwarder_34FVCSSMTP46exe34_is_up_and_running46
            , mtInformation
            , [mbOK]
            , 0
            , sBaseRegistryKey + crbMRU + 'Dlgs'
            , 'SMTPRecords'
            , idOk
            );
        end;
      end;
    end // if RegReadBool(HKCU, sBaseRegistryKey + crbOptions, 'SMTPMessages'
    else
      SMTPStatus1.Enabled := False;

    //???
    with uilPluginManager1 do
    begin
      {$IFDEF IDEDLL}
      PluginFolder := sDLLDirectory + 'Plugin\IDE';
      PluginKind := plgPackage;
      {$ELSE}
      PluginFolder := sDLLDirectory + 'Plugin\Standalone';
      PluginKind := plgDLL;
      {$ENDIF IDEDLL}
      uilPluginManager1.LoadPlugins;
    end;

    {$IFDEF IDEDLL}
    if bGlobalSettings then
      AddMessage(Format(JVCSRES_Server58_34Global_settings34_flag_is_set_by_Admin_on_37s, [sArchiveSource]),
        msclNormal);
    // fill listbox with module names of the project
    FillListView;
    // Aktuelle Editordatei markieren
    CurrentFile := AnsiLowerCase(IDEInterface.GetCurrentFile);
    if CurrentFile <> '' then
    begin
      ResolveFileFamilies(CurrentFile);
      // Message Window
      AddMessage(Format(JVCSRES_IDE_Topmost_view58_37s, [CurrentFile]), msclNormal);
      CurrentFile := ExtractFileName(CurrentFile);
      for I := 0 to elvModules.Items.Count - 1 do
      begin
        if Pos(CurrentFile, LowerCase(elvModules.Items[I].Caption)) <> 0 then
        begin
          elvModules.Items[I].Selected := True;
          Break;
        end;
      end; // for I := 0 to elvModules.Items.Count - 1 do begin
    end; // if CurrentFile <> '' then begin
    {$ELSE}
    mmiConnectserverClick(Self);
    if bGlobalSettings then
      AddMessage(Format(JVCSRES_Server58_34Global_settings34_flag_is_set_by_Admin_on_37s, [sArchiveSource]),
        msclNormal);
    // Autoopen Projects
    if (ServerUserID > 0) and
      jvcsReadBool(sBaseRegistryKey + crbWindows, 'SelectProjectID_AutoOpen', False) then
      mmiOpenProjectClick(Self);
    {$ENDIF IDEDLL}

    if (elvModules.Items.Count > 0) then
    begin
      if (elvModules.SelCount = 0) then
        elvModules.Items[0].Selected := True;
      ShowSelectedLVItem;
    end;
    elvModules.SetFocus;
    edSearch.Text := CurrentFile;
    bLVReady := True;
    dfsStatusBar.Panels[0].Text := Format(JVCSRES_Selected58_37d, [elvModules.SelCount]);
    SetMenuState;
    SetMenuStateEx;
    {$IFDEF IDEDLL}
    bPJM_Valid := True;
    {$ENDIF IDEDLL}

    {$IFDEF IDEDLL}
    ReadAndShowDockedWindows;
    {$ENDIF IDEDLL}
  finally
    Screen.Cursor := crDefault;
  end;
  {$IFDEF DEBUG}
  JclDebug.TraceMsg('PM: WMAppStartup Exit');
  {$ENDIF DEBUG}
end;

//------------------------------------------------------------------------------

{$IFDEF IDEDLL}
// -----------------------------------------------------------------------------
// following message handler will be called from WndProc by PostMessage to
// prevent wrong double click behaviour
procedure TVCSProjAdmin.WMIDEActivation(var Msg: TMessage);
var
  ActiveProject: string;
  SendMessages: Boolean;
begin
  {$IFDEF DEBUG}
  TraceBeginProcFmt('TVCSProjAdmin.WMIDEActivation','WParam=%d', [Msg.WParam]);
  {$ENDIF DEBUG}
  if Msg.WParam = 1 then  //Activate
  begin
    bPJM_TopWindow := True;
    ActiveProject := IDEInterface.GetProjectName;
    acRefreshForm.Enabled := (ServerUserID > 0);
    {$IFDEF DEBUG}
    TraceAlways(ActiveProject);
    {$ENDIF DEBUG}
    if not (ActiveProject = sCurrentProject) then
    begin
      sProjectName := ActiveProject;
      SetMenuStateEx;
      // Send Notify messages
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
      // Message Window
      AddMessage(Format(JVCSRES_Project_name_is_invalid58_37s,
        [ExtractFileName(sCurrentProject)]), msclNormal);
      // Time log
      if jvcsReadBool(sBaseRegistryKey + crbTimeLog,
        ExtractFileName(sCurrentProject), False) then
        WriteTimeLog( sConfigFolder + ChangeFileExt(ExtractFileName(sCurrentProject), '.tlg')
                    , 'close;' + sCurrentUser + ';' + FloatToStr(Now)
                    );
      sCurrentProject := ActiveProject;
      // Time log
      {$IFDEF DEBUG}
      TraceAlwaysFmt('Check Timelog active. Filename: %s', [ExtractFileName(sCurrentProject)]);
      {$ENDIF DEBUG}
      mmiActive.Checked :=
        jvcsReadBool(sBaseRegistryKey + crbTimeLog, ExtractFileName(sCurrentProject), False);
      // Send Notify messages
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
      // Message Window
      AddMessage(Format(JVCSRES_New_project58_37s,
        [ExtractFileName(sCurrentProject)]), msclNormal);
      // Time log
      if jvcsReadBool(sBaseRegistryKey + crbTimeLog,
        ExtractFileName(sCurrentProject), False) then
        WriteTimeLog( sConfigFolder + ChangeFileExt(ExtractFileName(sCurrentProject), '.tlg')
                    , 'open;' + sCurrentUser + ';' + FloatToStr(Now)
                    );
      // ProjectManager needs refresh
      if bPJM_Created then
        bPJM_NeedRefresh := True;
    end; // if not (ActiveProject = sCurrentProject) then begin
    if bVCSOptionsChanged then
      GetVCSOptions;
    if bPJM_NeedRefresh then
    begin
      {$IFDEF DEBUG}
      TraceAlways('Refresh in WMIDEActivation');
      {$ENDIF DEBUG}
      if FInitialized then
        acRefreshFormExecute(Self);
      SetMenuStateEx;
      SetStatusBar;
    end; // if (bPJM_NeedRefresh or....
  end
  else
  begin
    bPJM_TopWindow := False;
  end;
  {$IFDEF DEBUG}
  TraceEndProc('TVCSProjAdmin.WMIDEActivation');
  {$ENDIF DEBUG}
end;

procedure TVCSProjAdmin.WndProc(var Message: TMessage);
begin
  if (Message.Msg = WM_NCACTIVATE) or (Message.Msg = WM_ACTIVATE) then
  begin
    {  #2031 if activating is handled inside WndProc and activation was due to a
       click on the ListView it leads to a double click, so we post the
       event again in order to let handle the select click in the ListView first
    }
    PostMessage(Self.Handle, WM_IDEACTIVATION, Message.WParam, 0);
  end;
  inherited WndProc(Message);
end;
{$ENDIF IDEDLL}

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.FormPaint(Sender: TObject);
begin
  {$IFDEF DEBUG}
  JclDebug.TraceMsg('PM: Form Paint');
  {$ENDIF DEBUG}
  {$IFDEF IDEDLL}
  SaveFormSize;
  {$ENDIF IDEDLL}
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.acRefreshFormExecute(Sender: TObject);
begin
  {$IFDEF DEBUG}
  JclDebug.TraceMsg('PM: acRefreshFormExecute(Sender: TObject)');
  {$ENDIF DEBUG}
  acRefreshModuleList(Sender);
  RefreshDispatcher.DispatchSimpleRefresh(rtRefresh);
  RefreshDispatcher.DispatchSimpleRefresh(rtSelectedProjectChanged);
end;

procedure TVCSProjAdmin.acRefreshModuleList(Sender: TObject);
var
  LastItem: string;
  I: Integer;
begin
  if not FIsInacRefreshModuleList then
  begin
    if pgMain.ActivePage <> tsDefault then
      pgMain.ActivePage := tsDefault;
    FIsInacRefreshModuleList := True;
    try
      {$IFDEF IDEDLL}
      if (not bPJM_TopWindow) or bStopRefresh then
        Exit;
      {$ELSE}
      if bStopRefresh or (not bProjectOpen) then
        Exit;
      {$ENDIF IDEDLL}
      bPJM_NeedRefresh := False;

      LastItem := '';
      if elvModules.SelCount = 1 then
        LastItem := elvModules.Selected.Caption;

      FillListView;

      // Time log
      {$IFDEF DEBUG}
      JclDebug.TraceMsg('PM: Check Timelog active: ' + ExtractFileName(sProjectName));
      {$ENDIF DEBUG}
      if sProjectName <> '' then
        mmiActive.Checked :=
          jvcsReadBool(sBaseRegistryKey + crbTimeLog, ExtractFileName(sProjectName), False);
      if LastItem <> '' then
      begin
        for I := 0 to elvModules.Items.Count - 1 do
        begin
          if LastItem = elvModules.Items[I].Caption then
          begin
            elvModules.Items[I].Selected := True;
            Break;
          end;
        end; // for I := 0 to elvModules.Items.Count - 1 do begin
      end; // if LastItem <> '' then begin
      if (elvModules.Items.Count > 0) then
      begin
        if elvModules.SelCount = 0 then
          elvModules.Items[0].Selected := True;
        ShowSelectedLVItem;
      end;
      {$IFDEF IDEDLL}
      if bPJM_TopWindow then
        {$ENDIF IDEDLL}
        elvModules.SetFocus;
      edSearch.Text := LastItem;
    finally
      FIsInacRefreshModuleList := False;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.UpdateDiffActions;
var
  I: Integer;
  AdditionalFiles: TStringList;
  ModuleName: string;
  DiffActionItems: TList;
begin
  acDiff1.Enabled := acCompare.Enabled;
  ModuleName := GetSelectedModuleName;
  if acDiff1.Enabled and (ModuleName <> '') then
  begin
    FCurrentModuleFileNames.Clear;
    FCurrentModuleFileNames.AddObject(ModuleName, acDiff1);
    acDiff1.Caption := Format('Diff (%s)', [ExtractFileExt(ModuleName)]);
    DiffActionItems := TList.Create;
    AdditionalFiles := TStringList.Create;
    try
      DiffActionItems.Add(acDiff1);
      DiffActionItems.Add(acDiff2);
      DiffActionItems.Add(acDiff3);
      DiffActionItems.Add(acDiff4);
      DiffActionItems.Add(acDiff5);
      GetAdditionalFilesFromFileFamily(ModuleName, AdditionalFiles);
      for I := 0 to Pred(AdditionalFiles.Count) do
        FCurrentModuleFileNames.Add(AdditionalFiles[I]);
      for I := 1 to Pred(DiffActionItems.Count) do
      begin
        TAction(DiffActionItems[I]).Visible := FCurrentModuleFileNames.Count > I;
        if FCurrentModuleFileNames.Count > I then
        begin
          FCurrentModuleFileNames.Objects[I] := DiffActionItems[I];
          if I < 2 then
            TAction(DiffActionItems[I]).Caption := Format('Diff (%s)', [ExtractFileExt(FCurrentModuleFileNames[I])])
          else
            TAction(DiffActionItems[I]).Caption := ExtractFileExt(FCurrentModuleFileNames[I]);
        end;
      end;
      mnDiff3To5.Visible := AdditionalFiles.Count > 1;
    finally
      AdditionalFiles.Free;
      DiffActionItems.Free;
    end;
  end
  else
  begin
    acDiff1.Caption := 'Diff';
    acDiff2.Visible := False;
    mnDiff3To5.Visible := False;
    FCurrentModuleFileNames.Clear;
  end;
end;

procedure TVCSProjAdmin.UpdateTimerTimer(Sender: TObject);
begin
  SetServerStatus;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.SetServerStatus;
begin
  if AppSrvClientConnected then 
    dfsStatusBar.Panels[4].Text :=
      DataModule1.AppSrvClient1.Server
  else
    dfsStatusBar.Panels[4].Text := JVCSRES_Not_connected;
  dfsStatusBar.Panels[5].Text := Format(JVCSRES_Transfer58_37sk,
    [FormatFloat('#,', iServTraffic div 1024)]);
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.ShowStatusBarGauge(const ShowGauge,
  Indeterminate: Boolean);
begin
  with dfsStatusBar.Panels[7] do
  begin
    if ShowGauge then 
    begin
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
      SetStatusBar;
    end;
  end; // with dfsStatusBar.Panels[7] do begin
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.StatusBarGaugePos(Value: Word);
begin
  if Value > 100 then 
    Value := 100;
  if dfsStatusBar.Panels[7].Paneltype = sptGauge then
    dfsStatusBar.Panels[7].GaugeAttrs.Position := Value;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.SetStatusBar;
begin
  {$IFDEF DEBUG}
  JclDebug.TraceMsg('PM: SetLabels');
  {$ENDIF DEBUG}
  if mmiDefineWCView.Checked then 
    dfsStatusBar.Panels[1].Text := WildCardFilter
  else
    dfsStatusBar.Panels[1].Text := '*.*';
  {$IFDEF IDEDLL}
  dfsStatusBar.Panels[2].Text := Format(JVCSRES_Core58_37d, [IDEInterface.GetUnitCount]);
  dfsStatusBar.Panels[3].Text := Format(JVCSRES_Forms58_37d, [IDEInterface.GetFormCount]);
  {$ELSE}
  dfsStatusBar.Panels[2].Text := '';
  dfsStatusBar.Panels[3].Text := '';
  {$ENDIF IDEDLL}
  dfsStatusBar.Panels[4].Hint := sArchiveSource;
  SetCaption;
  if sProjectName <> '' then
  begin
    if mmiApplycustomfilter.Checked and (FilteredModules > 0) then
      dfsStatusBar.Panels[7].Text :=
        Format(JVCSRES_37d_404337d41_modules_45_37s_k,
          [elvModules.Items.Count, FilteredModules, FormatFloat('#,', ProjectModuleSize div 1024)])
    else
      dfsStatusBar.Panels[7].Text :=
        Format(JVCSRES_37d_modules_45_37s_k,
          [elvModules.Items.Count, FormatFloat('#,', ProjectModuleSize div 1024)]);
  end // if sProjectName <> '' then begin
  else
    dfsStatusBar.Panels[7].Text := JVCSRES_No_project;
end;

//------------------------------------------------------------------------------

function TVCSProjAdmin.GetArchiveCRC(ModuleID: string): string;
begin
  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_REVISION_STATUS';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [ModuleID]);
    SetupTimeoutCounter;
    AppSrvClient1.Send;

    while WaitForAppSrvClient do
      Application.ProcessMessages;
    if (AppSrvClientErr = -99) then 
    begin
      ShowServerTimeOut(WindowHandle);
      bStopRefresh := False;
      Exit;
    end;
    if (AppSrvClientErr <> 0) or
      (AppSrvClient1.AnswerStatus <> '200') then 
    begin
      ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
        AppSrvClient1.AnswerStatus);
      bStopRefresh := False;
      Exit;
    end;
    AppSrvClient1.Answer.First;
    try
      Result := IntToHex(StrToInt(AppSrvClient1.Answer.Fields[8]), 8);
    except
      Result := '00000000';
    end;
  end; // with DataModule1 do begin
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.ShowSelectedLVItem;
var 
  I: Integer;
begin
  if (elvModules.Items.Count = 0) then 
    Exit;
  with elvModules do 
  begin
    // Selected = nil ?
    if Selected = nil then 
      Exit;
    // Selected = TopItem ?
    if Selected = TopItem then 
      Exit;
    // zurück auf Position 0
    BeginUpdate;
    try
      I := Items.Count;
      while (TopItem <> Items[0]) and (I > 0) do 
      begin
        Scroll(0, - 10); // Texthöhe = 8
        Dec(I);
      end;
      EndUpdate;
      BeginUpdate;
      I := Items.Count;
      while (TopItem <> Selected) and (I > 0) do
      begin
        Scroll(0, 10);
        Dec(I);
      end;
    finally
      EndUpdate;
    end;
  end; // with elvModules do begin
end;

//------------------------------------------------------------------------------

function TVCSProjAdmin.Check_Create_Project(const ProjectName: string;
  const ShowMsg: Boolean;
  var ProjectID: Integer): Boolean;
var
  Msg, ProjectDescr: string;
  CurrentProjectID, GrantedRights: Integer;
begin
  bStopRefresh := True;
  try
    ProjectID := -1;
    Result := False;
    // new project has a valid project name?
    if (not IsValidProjectName(ProjectName, Msg)) then
    begin
      {$IFDEF IDEDLL}
      if sProjectName = '' then
      begin
        UseRegistry := True;
        DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
        DSAIdentsMessageDlg(Msg + #13#10 +
          JVCSRES_Remember_that_you_must_open_a_project_to_work_with_JEDI_VCS46,
          mtInformation, [mbOK],
          0, sBaseRegistryKey + crbMRU + 'Dlgs', 'PJNameBlank', idOk);
      end
      else
      begin
        BeepIfSet;
        MessageBox(Application.Handle, PChar(Format('<%s>' + #13#10 + '%s' + #13#10 +
          JVCSRES_See_help_topic_34Naming_conventions34_for_more_information46, [ProjectName, Msg])),
          cMsgBoxCaption, MB_OK or MB_ICONEXCLAMATION);
      end;
      {$ELSE}
      BeepIfSet;
      MessageBox(Application.Handle, PChar(Format('<%s>' + #13#10 + '%s' + #13#10 +
        JVCSRES_See_help_topic_34Naming_conventions34_for_more_information46, [ProjectName, Msg])),
        cMsgBoxCaption, MB_OK or MB_ICONEXCLAMATION);
      {$ENDIF IDEDLL}
      sProjectName := '';
      bProjectOpen := False;
      bStopRefresh := False;
      Exit;
    end; // if (not IsValidProjectName(ProjectName)) then begin
    CurrentProjectID := ProjectID;
    RefreshDispatcher.DispatchSimpleRefresh(rtProjectClosing);
    {$IFDEF DEBUG} // MG
    JclDebug.TraceMsg('PM: Check_Create_Project - GET_PROJECT_ID');
    {$ENDIF DEBUG}
    with DataModule1 do
    begin
      //--- get project ID -------------------------------------------------------
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.Answer.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_PROJECT_ID';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [ExtractFileName(ProjectName)]);
      SetupTimeoutCounter;
      AppSrvClient1.Send;
      // Message Window
      if ShowMsg then
        AddMessage(Format(JVCSRES_Server_request58_40Project_ID_for58_37s41,
          [ExtractFileName(sProjectName)]) + Format(SrvTimeCnt,
          [(GetTickCount - TickCount) / 1000]), msclNormal);

      while WaitForAppSrvClient do
        Application.ProcessMessages;
      if (AppSrvClientErr = -99) then
      begin
        ShowServerTimeOut(WindowHandle);
        bStopRefresh := False;
        Exit;
      end;
      if (AppSrvClientErr <> 0) or
        (AppSrvClient1.AnswerStatus <> '200') then
      begin
        ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
          AppSrvClient1.AnswerStatus);
        bStopRefresh := False;
        Exit;
      end;

      {$IFDEF DEBUG} // MG
      JclDebug.TraceMsg('PM: Check_Create_Project - after GET_PROJECT_ID');
      {$ENDIF DEBUG}
      AppSrvClient1.Answer.First;
      if AppSrvClient1.Answer.Fields[0] <> '0' then
      begin
        // known project
        TransactionNr := _StrToInt(AppSrvClient1.Answer.Fields[2]);
        ProjectID := _StrToInt(AppSrvClient1.Answer.Fields[0]);
        GrantedRights := _StrToInt(AppSrvClient1.Answer.Fields[3]);
        ArchiveAdmin := (GrantedRights = 4);
        case GrantedRights of
          0:
            dfsStatusBar.Panels[6].Text := JVCSRES_Guest;
          1:
            dfsStatusBar.Panels[6].Text := JVCSRES_read45only;
          2:
            dfsStatusBar.Panels[6].Text := JVCSRES_read45write;
          3:
            dfsStatusBar.Panels[6].Text := JVCSRES_Project_Admin;
          4:
            dfsStatusBar.Panels[6].Text := JVCSRES_Archive_Admin;
        end; // case GrantedRights of
        //#1704 - Project is deleted - should only occur in IDE client!
        if AppSrvClient1.Answer.Fields[1] <> '0' then
        begin
          MessageBox( Application.Handle
                    , PChar(Format(JVCSRES_Project_37s_is_deleted_in_VCS33,[ExtractFileName(ProjectName)]) +sLineBreak +
                      JVCSRES_Selected_action_is_not_permitted_for_deleted_projects46)
                    , cMsgBoxCaption
                    , MB_OK + MB_ICONERROR
                    );
          ProjectID := -1;
          Exit;
        end;
        if ShowMsg then
        begin
          if CurrentProjectID <> ProjectID then
          begin
            UseRegistry := True;
            DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
            Msg := Format(JVCSRES_Server_reports_a_known_project44_ID_37s + #10#13 +
              JVCSRES_Access_level_granted_to_37s58_37s,
              [AppSrvClient1.Answer.Fields[0], sCurrentUser, AppSrvClient1.Answer.Fields[3]]);
            case GrantedRights of
              0:
                Msg := Msg + ' [' + JVCSRES_Guest + ']';
              1:
                Msg := Msg + ' [' + JVCSRES_read45only + ']';
              2:
                Msg := Msg + ' [' + JVCSRES_read45write + ']';
              3:
                Msg := Msg + ' [' + JVCSRES_Project_administrator + ']';
              4:
                Msg := Msg + ' [' + JVCSRES_Archive_administrator + ']';
            end; // case GrantedRights of
            DSAIdentsMessageDlg(Msg
              , mtInformation
              , [mbOK]
              , 0
              , sBaseRegistryKey + crbMRU + 'Dlgs'
              , 'PJRight'
              , idOk
              );
          end; // if CurrentProjectID <> ProjectID then begin
        end; // if ShowMsg then begin
      end
      else
      begin
        // unknown project
        dfsStatusBar.Panels[6].Text := '';
        TransactionNr := _StrToInt(AppSrvClient1.Answer.Fields[2]);
        if MessageBox(WindowHandle, PChar(Format(JVCSRES_Server_reports_an_unknown_project_name_6037s6246 + #13#10 +
          JVCSRES_Create_a_new_project_with_this_name63, [ExtractFileName(sProjectName)])),
          cMsgBoxCaption, MB_YESNOCANCEL or MB_ICONQUESTION) <> idYes then
        begin
          bStopRefresh := False;
          ProjectID := -1;
          FilteredModules := 0;
          ProjectModuleSize := 0;
          Exit;
        end;

        ProjectDescr := '';
        if not jvcsReadBool(sBaseRegistryKey + crbOptions, 'SkipProjectDescr', False) then
        begin
          VCSDescription := TVCSDescription.Create(Application);
          try
            VCSDescription.Top := Top + 60;
            VCSDescription.Left := Left + 60;
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
        end;

        AppSrvClient1.Request.Rewrite;
        AppSrvClient1.FunctionCode := 'ADD_NEW_PROJECT';
        AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
        AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
        AppSrvClient1.Request.WriteFields(True, [ServerUserID]);
        AppSrvClient1.Request.WriteFields(False, [ExtractFileName(sProjectName)]);
        AppSrvClient1.Request.WriteFields(False, [ProjectDescr]);
        SetupTimeoutCounter;
        AppSrvClient1.Send;

        while WaitForAppSrvClient do
          Application.ProcessMessages;
        if (AppSrvClientErr = -99) then
        begin
          ShowServerTimeOut(WindowHandle);
          bStopRefresh := False;
          Exit;
        end;
        if (AppSrvClientErr <> 0) or
          (AppSrvClient1.AnswerStatus <> '200') then
        begin
          ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
            AppSrvClient1.AnswerStatus);
          bStopRefresh := False;
          Exit;
        end;

        AppSrvClient1.Answer.First;
        if DecodeBoolStr(AppSrvClient1.Answer.Fields[0]) then
        begin
          dfsStatusBar.Panels[6].Text := JVCSRES_default_rights;
          ProjectID := _StrToInt(AppSrvClient1.Answer.Fields[1]);
          UseRegistry := True;
          DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
          if DSAIdentsMessageDlg(Format(JVCSRES_Project_6037s62_successfully_created46_Project_ID58_37s,
            [ExtractFileName(sProjectName),
            AppSrvClient1.Answer.Fields[1]]) + #13#10 +
            JVCSRES_Would_you_like_to_assign_the_project_to_a_group63
            , mtConfirmation
            , [mbYes, mbNo]
            , 0
            , sBaseRegistryKey + crbMRU + 'Dlgs'
            , 'PJCreatedEx'
            , idNo
            ) = idYes then
            ProjectHierarchy1Click(Self);
          AddMessage(Format(JVCSRES_Project_6037s62_successfully_created46_Project_ID58_37s,
            [ExtractFileName(sProjectName),
            AppSrvClient1.Answer.Fields[1]]), msclNormal);
        end; // if not DecodeBoolStr(....
      end; // else if AppSrvClient1.Answer.Fields[0] <> '0' then

      if ShowMsg then
      begin
        //--- get project info ---------------------------------------------------
        AppSrvClient1.Request.Rewrite;
        AppSrvClient1.FunctionCode := 'GET_PROJECT_INFORMATION';
        AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
        AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
        AppSrvClient1.Request.WriteFields(True, [ProjectID]);
        SetupTimeoutCounter;
        AppSrvClient1.Send;
        // Message Window

        while WaitForAppSrvClient do
          Application.ProcessMessages;
        if (AppSrvClientErr = -99) then
        begin
          ShowServerTimeOut(WindowHandle);
          bStopRefresh := False;
          Exit;
        end;
        if (AppSrvClientErr <> 0) or
          (AppSrvClient1.AnswerStatus <> '200') then
        begin
          ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
            AppSrvClient1.AnswerStatus);
          bStopRefresh := False;
          Exit;
        end;

        AppSrvClient1.Answer.First;

        {$IFDEF DEBUG} // MG
        JclDebug.TraceMsg('PM: Check_Create_Project - Answer: ' + AppSrvClient1.Answer.Fields[2] + ':' +
                                                               AppSrvClient1.Answer.Fields[4]);
        {$ENDIF DEBUG}

        try
        Msg := Format(JVCSRES_Server_reports_a_known_project46_Created58_37s_by_37s_ID58_37d_45_Last_write_access58_37s_by_37s,
          [DateTimeToStr(GMTStr2LocalDateTime(AppSrvClient1.Answer.Fields[2])),
           AppSrvClient1.Answer.Fields[3], ProjectID,
           DateTimeToStr(GMTStr2LocalDateTime(AppSrvClient1.Answer.Fields[4])),
           AppSrvClient1.Answer.Fields[5]]);
        AddMessage(Msg + Format(SrvTimeCnt, [(GetTickCount - TickCount) / 1000]), msclNormal);
        except
        end;
      end; // if ShowMsg then begin
    end; // with DataModule1 do begin
    Result := True;
  finally
    bStopRefresh := False;
    {$IFDEF DEBUG} // MG
    JclDebug.TraceMsg('PM: Check_Create_Project - Exit');
    {$ENDIF DEBUG}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.GetSharedModules(const ShowMsg: Boolean);
begin
  bStopRefresh := True;
  try
    with DataModule1 do
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_SHARED_MODULES';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      SetupTimeoutCounter;
      AppSrvClient1.Send;
      // Message Window
      if ShowMsg then
        AddMessage(Format(JVCSRES_Server_request58_40Shared_modules_assigned_to58_37s41,
          [ExtractFileName(sProjectName)]) +
          Format(SrvTimeCnt, [(GetTickCount - TickCount) / 1000]), msclNormal)
      else
        AddMessage(Format(JVCSRES_Server_request58_40Shared_modules_assigned_to58_37s41,
          [ExtractFileName(sProjectName)]), msclNormal);

      while WaitForAppSrvClient do 
        Application.ProcessMessages;
      if (AppSrvClientErr = -99) then
      begin
        ShowServerTimeOut(WindowHandle);
        bStopRefresh := False;
        Exit;
      end;
      if (AppSrvClientErr <> 0) or
        (AppSrvClient1.AnswerStatus <> '200') then 
      begin
        ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
          AppSrvClient1.AnswerStatus);
        bStopRefresh := False;
        Exit;
      end;

      AppSrvClient1.Answer.First;
      SharedModuleIDs.Clear;
      while not AppSrvClient1.Answer.Eof do 
      begin
        SharedModuleIDs.Add(AppSrvClient1.Answer.Fields[0]);
        AppSrvClient1.Answer.Next;
      end;
    end; // with DataModule1 do begin
  finally
    bStopRefresh := False;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.GetModuleBugs;
begin
  bStopRefresh := True;
  try
    ModuleBugs.Clear;
    with DataModule1 do
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_MOST_SEVERE_BUGS';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [True]); // Module based?
      SetupTimeoutCounter;
      AppSrvClient1.Send;
      // Message Window
      if ShowMsg then
        AddMessage(JVCSRES_Server_request58_40Module_bug_list41 +
          Format(SrvTimeCnt, [(GetTickCount - TickCount) / 1000]), msclNormal)
      else
        AddMessage(JVCSRES_Server_request58_40Module_bug_list41, msclNormal);

      while WaitForAppSrvClient do 
        Application.ProcessMessages;
      if (AppSrvClientErr = -99) then
      begin
        ShowServerTimeOut(WindowHandle);
        bStopRefresh := False;
        Exit;
      end;
      if (AppSrvClientErr <> 0) or
        (AppSrvClient1.AnswerStatus <> '200') then
      begin
        ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
          AppSrvClient1.AnswerStatus);
        bStopRefresh := False;
        Exit;
      end;

      AppSrvClient1.Answer.First;
      while not AppSrvClient1.Answer.Eof do 
      begin
        ModuleBugs.Add(AppSrvClient1.Answer.Fields[0] + '=' +
          AppSrvClient1.Answer.Fields[2]);
        AppSrvClient1.Answer.Next;
      end;
    end; // with DataModule1 do begin
  finally
    bStopRefresh := False;
  end;
end;

//------------------------------------------------------------------------------

function TVCSProjAdmin.GetBugStateIndex(const ModuleID: Integer): Integer;
var 
  BugIndex: string;
begin
  Result := -1;
  if ModuleID < 1 then 
    Exit;
  BugIndex := ModuleBugs.Values[IntToStr(ModuleID)];
  if BugIndex <> '' then
    Result := _StrToInt(BugIndex);
  if Result > -1 then
    Result := Result + 4;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.GetLabels;
begin
  bStopRefresh := True;
  try
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
        bStopRefresh := False;
        Exit;
      end;
      if (AppSrvClientErr <> 0) or
        (AppSrvClient1.AnswerStatus <> '200') then
      begin
        ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
          AppSrvClient1.AnswerStatus);
        bStopRefresh := False;
        Exit;
      end;

      AppSrvClient1.Answer.First;
      // Labels
      FLabelList.Clear;
      while (not AppSrvClient1.Answer.Eof) do
      begin
        FLabelList.AddOrReplace(StrToIntDef(AppSrvClient1.Answer.Fields[0], 0),
           AppSrvClient1.Answer.Fields[1]);
        AppSrvClient1.Answer.Next;
      end; // while (not AppSrvClient1.Answer.EoF)
    end; // with DataModule1 do begin
  finally
    bStopRefresh := False;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.GetLabelAssignement(const ShowMsg: Boolean);
begin
  bStopRefresh := True;
  try
    with DataModule1 do
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_LABELS_BY_PROJECT';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [ServerProjectID]);
      SetupTimeoutCounter;
      AppSrvClient1.Send;
      // Message Window
      if ShowMsg then
        AddMessage(Format(JVCSRES_Server_request58_40Labels_assigned_to58_37s41,
          [ExtractFileName(sProjectName)]) +
          Format(SrvTimeCnt, [(GetTickCount - TickCount) / 1000]), msclNormal)
      else
        AddMessage(Format(JVCSRES_Server_request58_40Labels_assigned_to58_37s41,
          [ExtractFileName(sProjectName)]), msclNormal);
    

      while WaitForAppSrvClient do
        Application.ProcessMessages;
      if (AppSrvClientErr = -99) then 
      begin
        ShowServerTimeOut(WindowHandle);
        bStopRefresh := False;
        Exit;
      end;
      if (AppSrvClientErr <> 0) or
        (AppSrvClient1.AnswerStatus <> '200') then 
      begin
        ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
          AppSrvClient1.AnswerStatus);
        bStopRefresh := False;
        Exit;
      end;

      AppSrvClient1.Answer.First;
      // label assignement
      FProjectLabelList.Clear;
      while (not AppSrvClient1.Answer.Eof) do
      begin
        FProjectLabelList.Add(StrToIntDef(AppSrvClient1.Answer.Fields[0], 0),
          StrToIntDef(AppSrvClient1.Answer.Fields[1], 0), StrToIntDef(AppSrvClient1.Answer.Fields[2], 0));
        AppSrvClient1.Answer.Next;
      end; // while (not AppSrvClient1.Answer.EoF) and...
    end; // with DataModule1 do begin
  finally
    bStopRefresh := False;
  end;
end;

//------------------------------------------------------------------------------

function TVCSProjAdmin.GetLabelName(const LabelID: Integer): string;
var
  Idx: Integer;
begin
  Result := '';
  Idx := FLabelList.IndexOf(LabelID);
  if Idx <> -1 then
    Result := FLabelList[Idx].Name;
end;

function TVCSProjAdmin.GetModuleRevisionLabels(AModuleID, ARevisionID: Integer): string;
var
  LabelCount, I, Idx1, Idx2: Integer;
begin
  Result := '';
  LabelCount := 0;
  if FProjectLabelList.GetModuleRevisionLabelRange(AModuleID, ARevisionID, Idx1, Idx2) then
  begin
    for I := Idx2 downto Idx1 do
    begin
      Inc(LabelCount);
      if Result = '' then
        Result := GetLabelName(FProjectLabelList[I].LabelID)
      else
        Result := Result + '/' + GetLabelName(FProjectLabelList[I].LabelID);
    end;
  end; // while not ProjectLabelBuffer.EoF do begin
  if LabelCount > 1 then
    Result := '(' + IntToStr(LabelCount) + ') ' + Result;
end;

//------------------------------------------------------------------------------

function TVCSProjAdmin.GetFakeImageIndex(const AFakeFilename: string;
  IsADirectory: Boolean): Integer;
var
  Attrs: DWORD;
  sfi: TSHFileInfo;
begin
  // AFakeFilename does not exist, we must supply the attributes.
  if IsADirectory then
    Attrs := FILE_ATTRIBUTE_DIRECTORY // tell it we want the folder image index.
  else
    Attrs := FILE_ATTRIBUTE_NORMAL; // figure it out based on file extension.
  SHGetFileInfo(PChar(AFakeFilename), Attrs, sfi, SizeOf(TSHFileInfo),
    SHGFI_SYSICONINDEX or SHGFI_USEFILEATTRIBUTES);
  Result := sfi.iIcon;
end;

//------------------------------------------------------------------------------

function TVCSProjAdmin.GetFileImageIndex(const AFileName: string; const AShowLocalInfo, AExists: Boolean): Integer;

  function GetCorrectedImageIndex(const AIndex: Integer): Integer;
  var
    I: Integer;
    Icon: TIcon;
  begin
    Result := AIndex + FSystemImagesOffset;
    if Pred(ModuleImageList.Count - FSystemImagesOffset) < AIndex then
      for I := ModuleImageList.Count - FSystemImagesOffset to AIndex do
      begin
        Icon := TIcon.Create;
        try
          SysImageList.GetIcon(I, Icon);
          ModuleImageList.AddIcon(Icon);
        finally
          Icon.Free;
        end;
      end;
  end;

var
  sfi: TSHFileInfo;
begin
  if AShowLocalInfo then
  begin
    if AExists then
    begin
      SHGetFileInfo(PChar(AFileName), 0, sfi,
        SizeOf(sfi), SHGFI_SYSICONINDEX or
        SHGFI_SMALLICON or SHGFI_DISPLAYNAME);
      Result := GetCorrectedImageIndex(sfi.iIcon);
    end
    else
      Result := NoFoundIcon;
  end
  else
    Result := GetCorrectedImageIndex(GetFakeImageIndex(ExtractFileName(AFileName), False));
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.AddNewModule(const ModuleName: string;
  const ModuleID: Integer);
var
  NewItem: TListItem;
  ShowLocalInfo, ShowTypeInfo, FExists: Boolean;
  BugStateIndex, FOrigSize: Integer;
  OrigName: string;
begin
  ShowLocalInfo := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowLocalInfo', True);
  ShowTypeInfo := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowTypeInfo', True);
  if ShowLocalInfo then
    FExists := FileExists(ModuleName)
  else
    FExists := True;
  elvModules.AutoResort := False;
  try
    elvModules.BeginUpdate;
    try
      //--- Module -------------------------------------------------------
      NewItem := elvModules.Items.Add;
      uilPluginManager1.SendMessage(pimsgFVCSProjectModulesAdd, ModuleName);
      //--- Caption ------------------------------------------------------
      NewItem.Caption := ExtractFileName(ModuleName);
      //--- File Icon ----------------------------------------------------
      NewItem.ImageIndex := GetFileImageIndex(ModuleName, ShowLocalInfo, FExists);
      //--- StateIcons ---------------------------------------------------
      BugStateIndex := GetBugStateIndex(ModuleID);
      if BugStateIndex > 0 then
        NewItem.StateIndex := BugStateIndex
      else
        NewItem.StateIndex := 0;
      //--- Type ---------------------------------------------------------
      if ShowTypeInfo then
      begin
        NewItem.SubItems.Add(GetFileType(ModuleName));
      end
      else
        NewItem.SubItems.Add(ExtractFileExt(ModuleName));
      //--- Path ---------------------------------------------------------
      NewItem.SubItems.Add(ExtractFilePath(ModuleName));
      //--- Version ------------------------------------------------------
      NewItem.SubItems.Add(JVCSRES_N47A);
      //--- State --------------------------------------------------------
      NewItem.SubItems.Add(JVCSRES_N47A);
      //--- Owner --------------------------------------------------------
      NewItem.SubItems.Add(JVCSRES_N47A);
      //--- Count --------------------------------------------------------
      NewItem.SubItems.Add('0');
      //--- Keyword ------------------------------------------------------
      NewItem.SubItems.Add(JVCSRES_N47A);
      //--- Shared -------------------------------------------------------
      NewItem.SubItems.Add(JVCSRES_N47A);
      //--- Size ---------------------------------------------------------
      if ShowLocalInfo then
      begin
        if FExists then
        begin
          FOrigSize := _GetFileSizeEx(ModuleName, OrigName);
          NewItem.SubItems.Add(FormatFloat('#,', FOrigSize));
          ProjectModuleSize := ProjectModuleSize + FOrigSize;
          NewItem.Caption := OrigName;
        end
        else
          NewItem.SubItems.Add('-');
      end
      else
        NewItem.SubItems.Add('-');
      //--- Date ---------------------------------------------------------
      if ShowLocalInfo then
      begin
        if FExists then
          NewItem.SubItems.Add(DateTimeToStr(FileDateToDateTime(FileAge(ModuleName))))
        else
          NewItem.SubItems.Add('-');
      end
      else
        NewItem.SubItems.Add('-');
      //--- Attr ---------------------------------------------------------
      if ShowLocalInfo then
      begin
        if FExists then
          NewItem.SubItems.Add(GetAttrStrEx(ModuleName))
        else
          NewItem.SubItems.Add('-');
      end
      else
        NewItem.SubItems.Add('-');
      //--- Module ID ----------------------------------------------------
      NewItem.SubItems.Add(IntToStr(ModuleID));
      //--- Revision ID --------------------------------------------------
      NewItem.SubItems.Add(JVCSRES_N47A);
    finally
      elvModules.EndUpdate;
    end;
  finally
    elvModules.AutoResort := True;
    elvModules.Resort;
    elvModules.SetFocus;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.RefreshModules;
var
  I: Integer;
begin
  with elvModules do
  begin
    AutoResort := False;
    try
      BeginUpdate;
      try
        for I := 0 to Items.Count - 1 do
        begin
          if Items[I].Selected then
            ADD_Refresh_Module(False, I, _StrToInt(Items[I].SubItems[sitMID]),
              Items[I].SubItems[sitPath] + LowerCase(Items[I].Caption));
        end; // for I := 0 to Items.Count - 1 do begin
      finally
        EndUpdate;
      end;
    finally
      AutoResort := True;
      Resort;
    end;
  end; // with elvModules do begin

  RefreshDispatcher.DispatchSimpleRefresh(rtSelectedModuleChanged);
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.ADD_Refresh_Module(const Add: Boolean;
  const LVItemIndex: Integer; ModuleID: Integer;
  const Module_Name_Path: string);
var
  ModuleName, ModulePath, OrigName, ModuleTimeStamp, ModuleOwner, LabelString: string;
  OldAutoResort, FExists, ShowLocalInfo, ShowTypeInfo, ModuleHidden, CheckedOut: Boolean;
  RevisionID, RevisionCount, Version, Revision, BugStateIndex, FOrigSize: Integer;
  NewItem: TListItem;

  procedure SubitemValue(LVItem: TListItem; AddNewItem: Boolean; Col: Integer;
    Value: string);
  begin
    if AddNewItem then 
      LVItem.SubItems.Add(Value)
    else 
      LVItem.SubItems[Col] := Value;
  end;
begin
  if ModuleID = 0 then
    Exit;
  ShowLocalInfo := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowLocalInfo', True);
  ShowTypeInfo := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowTypeInfo', True);
  bStopRefresh := True;
  CheckedOut := False;
  RevisionID := 0;
  Version := 0;
  Revision := 0;
  ModuleHidden := False;
  with DataModule1 do
  begin
    //--- get revisions ------------------------------------------------------
    AppSrvClient1.FunctionCode := 'GET_REVISION_LIST_BY_ID';
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [ModuleID]);
    AppSrvClient1.Request.WriteFields(False, [ServerProjectID]);
    SetupTimeoutCounter;
    AppSrvClient1.Send;

    while WaitForAppSrvClient do 
      Application.ProcessMessages;
    if (AppSrvClientErr = -99) then 
    begin
      ShowServerTimeOut(WindowHandle);
      bStopRefresh := False;
      Exit;
    end;
    if (AppSrvClientErr <> 0) or
      (AppSrvClient1.AnswerStatus <> '200') then 
    begin
      ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
        AppSrvClient1.AnswerStatus);
      bStopRefresh := False;
      Exit;
    end;

    AppSrvClient1.Answer.First;
    if (not AppSrvClient1.Answer.Eof) and
      (AppSrvClient1.Answer.Fields[0] <> '0') then
    begin
      RevisionCount := 0;
      ModuleID := _StrToInt(AppSrvClient1.Answer.Fields[0]);
      ModuleName := AppSrvClient1.Answer.Fields[1];
      {$IFDEF CUSTOMDRIVE}
      ModulePath := ChangeDriveName(AppSrvClient1.Answer.Fields[2], sDriveSubst);
      {$ELSE}
      ModulePath := AppSrvClient1.Answer.Fields[2];
      {$ENDIF CUSTOMDRIVE}
      ModuleTimeStamp := DateTimeToStr(GMTStr2LocalDateTime(AppSrvClient1.Answer.Fields[4]));
      ModuleHidden := DecodeBoolStr(AppSrvClient1.Answer.Fields[11]);
      while not AppSrvClient1.Answer.Eof do
      begin
        Inc(RevisionCount);
        CheckedOut := DecodeBoolStr(AppSrvClient1.Answer.Fields[3]);
        if CheckedOut then 
          ModuleOwner := AppSrvClient1.Answer.Fields[9]
        else 
          ModuleOwner := '';
        RevisionID := _StrToInt(AppSrvClient1.Answer.Fields[6]);
        Version := _StrToInt(AppSrvClient1.Answer.Fields[7]);
        Revision := _StrToInt(AppSrvClient1.Answer.Fields[8]);
        AppSrvClient1.Answer.Next;
      end; // while (not AppSrvClient1.Answer.EoF) and....
    end // if not AppSrvClient1.Answer.EoF then begin
    else 
    begin
      RevisionCount := 0;
      ModuleID := 0;
      ModuleName := ExtractFileName(Module_Name_Path);
      ModulePath := ExtractFilePath(Module_Name_Path);
      ModuleTimeStamp := JVCSRES_UC_unknown;
      CheckedOut := False;
      ModuleOwner := '';
      RevisionID := 0;
      Version := 0;
      Revision := 0;
    end; // if not AppSrvClient1.Answer.EoF then begin
  end; // with DataModule1 do begin

  OldAutoResort := elvModules.AutoResort;
  elvModules.AutoResort := False;
  try
    elvModules.BeginUpdate;
    try
      if ShowLocalInfo then
        FExists := FileExists(ModulePath + ModuleName)
      else
        FExists := True;
      //--- Module -------------------------------------------------------
      if Add then
      begin
        NewItem := elvModules.Items.Add;
        uilPluginManager1.SendMessage(pimsgFVCSProjectModulesAdd, ModulePath + ModuleName);
      end
      else
        NewItem := elvModules.Items[LVItemIndex];
      if NewItem = nil then
        Exit;
      //--- Caption ------------------------------------------------------
      NewItem.Caption := ModuleName;
      //--- File Icon ----------------------------------------------------
      NewItem.ImageIndex := GetFileImageIndex(ModulePath + ModuleName, ShowLocalInfo, FExists);
      //--- StateIcons ---------------------------------------------------
      BugStateIndex := GetBugStateIndex(ModuleID);
      if BugStateIndex > 0 then
        NewItem.StateIndex := BugStateIndex
      else
      begin
        if not ModuleHidden then 
        begin
          NewItem.StateIndex := 0;
        end
        else 
          NewItem.StateIndex := 3;
      end;
      //--- Type ---------------------------------------------------------
      if ShowTypeInfo then
      begin
        SubitemValue(NewItem, Add, sitType, GetFileType(ModulePath + ModuleName));
      end
      else
        SubitemValue(NewItem, Add, sitType, ExtractFileExt(ModuleName));
      //--- Path ---------------------------------------------------------
      SubitemValue(NewItem, Add, sitPath, ModulePath);
      //--- Version ------------------------------------------------------
      if RevisionCount <> 0 then
        SubitemValue(NewItem, Add, sitVer, IntToStr(Version) + '.' + IntToStr(Revision))
      else 
        SubitemValue(NewItem, Add, sitVer, JVCSRES_N47A);
      //--- State --------------------------------------------------------
      if RevisionCount <> 0 then
      begin
        if CheckedOut then
          SubitemValue(NewItem, Add, sitState, JVCSRES_Out)
        else
          SubitemValue(NewItem, Add, sitState, JVCSRES_In);
      end
      else
        SubitemValue(NewItem, Add, sitState, JVCSRES_N47A);
      //--- Owner --------------------------------------------------------
      if RevisionCount <> 0 then
      begin
        if CheckedOut then 
          SubitemValue(NewItem, Add, sitOwner, ModuleOwner)
        else 
          SubitemValue(NewItem, Add, sitOwner, '');
      end 
      else 
        SubitemValue(NewItem, Add, sitOwner, JVCSRES_N47A);
      //--- Count --------------------------------------------------------
      SubitemValue(NewItem, Add, sitCount, IntToStr(RevisionCount));
      //--- Keyword ------------------------------------------------------
      if RevisionCount <> 0 then
      begin
        LabelString := GetModuleRevisionLabels(ModuleID, RevisionID);
        if LabelString = '' then 
          SubitemValue(NewItem, Add, sitKeyWord, '-')
        else 
          SubitemValue(NewItem, Add, sitKeyWord, LabelString);
      end 
      else
        SubitemValue(NewItem, Add, sitKeyWord, JVCSRES_N47A);
      //--- Shared -------------------------------------------------------
      if RevisionCount <> 0 then 
      begin
        if SharedModuleIDs.IndexOf(IntToStr(ModuleID)) <> -1 then
          SubitemValue(NewItem, Add, sitShare, JVCSRES_Yes)
        else
          SubitemValue(NewItem, Add, sitShare, JVCSRES_No);
      end 
      else 
        SubitemValue(NewItem, Add, sitShare, JVCSRES_N47A);
      //--- Size ---------------------------------------------------------
      if ShowLocalInfo then 
      begin
        if FExists then 
        begin
          FOrigSize := _GetFileSizeEx(ModulePath + ModuleName, OrigName);
          SubitemValue(NewItem, Add, sitSize, FormatFloat('#,', FOrigSize));
          ProjectModuleSize := ProjectModuleSize + FOrigSize;
          NewItem.Caption := OrigName;
        end 
        else 
          SubitemValue(NewItem, Add, sitSize, '-');
      end 
      else
        SubitemValue(NewItem, Add, sitSize, '-');
      //--- Date ---------------------------------------------------------
      if ShowLocalInfo then
      begin
        if FExists then
          SubitemValue(NewItem, Add, sitDate,
            DateTimeToStr(FileDateToDateTime(FileAge(ModulePath + ModuleName))))
        else
          SubitemValue(NewItem, Add, sitDate, '-');
      end
      else
        SubitemValue(NewItem, Add, sitDate, '-');
      //--- Attr ---------------------------------------------------------
      if ShowLocalInfo then
      begin
        if FExists then
          SubitemValue(NewItem, Add, sitAttr, GetAttrStrEx(ModulePath + ModuleName))
        else
          SubitemValue(NewItem, Add, sitAttr, '-');
      end
      else
        SubitemValue(NewItem, Add, sitAttr, '-');
      //--- Module ID ----------------------------------------------------
      SubitemValue(NewItem, Add, sitMID, IntToStr(ModuleID));
      //--- Revision ID --------------------------------------------------
      if RevisionCount <> 0 then
        SubitemValue(NewItem, Add, sitRID, IntToStr(RevisionID))
      else
        SubitemValue(NewItem, Add, sitRID, JVCSRES_N47A);
    finally
      elvModules.EndUpdate;
    end;
  finally
    elvModules.AutoResort := OldAutoResort;
    if OldAutoResort then
      elvModules.Resort;
    elvModules.SetFocus;
    bStopRefresh := False;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.FillListView;
var
  I, J: Integer;
  Msg, ModuleOwner, CurrentPath, CurrentFile, Associate, OrigName, LabelString, PCFFileName: string;
  {$IFDEF IDEDLL}
  SkipAlways, Skip, Yes2all: Boolean;
  AddResult, Yes2allRes: Integer;
  SkipNewModulesFile, sFileFamily, sTmp: string;
  NewModules, SkipNewModules: TStringList;
  slChildExtensions, slFileFamilies: TStringList;  //thu 27.07.2003, sun 20.11.2005
  bHasCPPFamilyWithH, bHasCPPFamilyWithDFM: Boolean;  // mantis #3318
  {$ENDIF IDEDLL}
  AllModules, AllRevisions, ModuleID, RevisionID, FSize, BugStateIndex,
  StatusBarGaugeMax: Integer;
  FExists, ShowLocalInfo, ShowTypeInfo, CheckedOut, FilterOut, Hidden,
  NeedRefresh, OldTimerState: Boolean;
  NewItem: TListItem;
  CustFiltItems: TStringList;
  aDateTime: TDateTime;
  {$IFNDEF IDEDLL}
  FillListViewAborted: Boolean;
  {$ENDIF ~IDEDLL}
label
  NextModule1, NextModule2;

  function CanRunFutherFillListView: Boolean;
  begin
    {$IFDEF IDEDLL}
    Result := True;
    {$ELSE}
    if not FillListViewAborted then
    begin
      Application.ProcessMessages;
      if FPressedESC then
      begin
        FPressedESC := False;
        FillListViewAborted :=
          NoYesMessageBox(Format(JVCSRES_Do_you_want_to_abort_opening_project_6037s62_63, [sProjectName]));
      end;
    end;
    Result := not FillListViewAborted;
    {$ENDIF IDEDLL}
  end;

begin
  if not FIsInFillListView then
  begin
    FIsInFillListView := True;
    try
      {$IFNDEF IDEDLL}
      FPressedESC := False;
      FillListViewAborted := False;
      {$ENDIF ~IDEDLL}
      ShowLocalInfo := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowLocalInfo', True);
      ShowTypeInfo := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowTypeInfo', True);
      {$IFDEF DEBUG}
      JclDebug.TraceMsg('PM: FillListView - IsValidProjectName(sProjectName)');
      {$ENDIF DEBUG}
      // new project has a valid project name?
      if (not IsValidProjectName(sProjectName, Msg)) then
      begin
        {$IFDEF IDEDLL}
        if sProjectName = '' then
        begin
          UseRegistry := True;
          DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
          DSAIdentsMessageDlg(Msg + #13#10 +
              JVCSRES_Remember_that_you_must_open_a_project_to_work_with_JEDI_VCS46
            , mtInformation
            , [mbOK]
            , 0
            , sBaseRegistryKey + crbMRU + 'Dlgs'
            , 'PJNameBlank'
            , idOk
            );
        end
        else
        begin
          BeepIfSet;
          MessageBox(Application.Handle, PChar(Format('<%s>' + #13#10 + '%s' + #13#10 +
            JVCSRES_See_help_topic_34Naming_conventions34_for_more_information46, [sProjectName, Msg])),
            cMsgBoxCaption, MB_OK or MB_ICONEXCLAMATION);
        end;
        {$ELSE}
        BeepIfSet;
        MessageBox(Application.Handle, PChar(Format('<%s>' + #13#10 + '%s' + #13#10 +
          JVCSRES_See_help_topic_34Naming_conventions34_for_more_information46, [sProjectName, Msg])),
          cMsgBoxCaption, MB_OK or MB_ICONEXCLAMATION);
        {$ENDIF IDEDLL}
        sProjectName := '';
        bProjectOpen := False;
        bStopRefresh := False;
        Exit;
      end; // if (not IsValidProjectName(ProjectName)) then begin
      Screen.Cursor := crHourGlass;
      //  Update;
      OldTimerState := RefreshTimer.Enabled;
      RefreshTimer.Enabled := False;
      CustFiltItems := nil;
      bPJM_NeedRefresh := False;
      NeedRefresh := False;
      {$IFDEF DEBUG}
      JclDebug.TraceMsg('PM: FillListView - ShowStatusBarGauge(True)');
      {$ENDIF DEBUG}
      ShowStatusBarGauge(True, False);
      StatusBarGaugePos(0);
      //--- Message Window ---------------------------------------------------------
      TickCount := GetTickCount;
      Msg := Format(JVCSRES_User58_37s, [sCurrentUser]);
      if sCurrentMachine <> '' then
        Msg := Format(JVCSRES_37s_on_37s, [Msg, sCurrentMachine]);
      AddMessage(Format(JVCSRES_37s_910s93, [Msg]), msclNormal);
      //--- Global settings? -------------------------------------------------------
      if bGlobalSettings then
      begin
        GetGlobalUserSettings(Application, WindowHandle);
        AddMessage(JVCSRES_Server_request58_40Reload_latest_global_settings41 +
          Format(SrvTimeCnt, [(GetTickCount - TickCount) / 1000]), msclNormal);
      end;
      {$IFDEF IDEDLL}
      if (sProjectName <> '') then
      begin
        {$IFDEF DEBUG}
        JclDebug.TraceMsg('PM: FillListView - Core modules');
        {$ENDIF DEBUG}
        //--- Core modules ---------------------------------------------------------
        AddMessage(Format(JVCSRES_IDE_request58_40Core_modules_assigned_to58_37s41,
          [ExtractFileName(sProjectName)]) +
          Format(SrvTimeCnt, [(GetTickCount - TickCount) / 1000]), msclNormal);
        DelphiModules.Clear;
        //thu 28.07.2003 - Get all child extensions (and now also all file families as per mantis #3318)
        slFileFamilies    := TStringList.Create;
        slChildExtensions := TStringList.Create;
        GetAllFileFamilyExtensions(slFileFamilies, slChildExtensions);
        // Determine if there is a file family with .cpp as the parent and .h/.dfm as children
        if bIsCppBuilder then
        begin
          bHasCPPFamilyWithH   := False;
          bHasCPPFamilyWithDFM := False;
          sFileFamily := slFileFamilies.Values['.cpp'];
          while Length(sFileFamily) <> 0 do
          begin
            sTmp := StrToken(sFileFamily, ';');
            if (sTmp = '.h') then
              bHasCPPFamilyWithH := True
            else
            if (sTmp = '.dfm') then
              bHasCPPFamilyWithDFM := True;
          end;
        end; // if bIsCPPBuilder then
        try
          for I := 0 to IDEInterface.GetUnitCount - 1 do
          begin
            CurrentFile := IDEInterface.GetUnitName(I);
            //thu 28.07.2003 - sort
            {$IFDEF DEBUG}
            JclDebug.TraceMsg('PM: IDEInterfaceFile - ' + CurrentFile);
            {$ENDIF DEBUG}
            {
              USc 16.01.2004
              I don't use dfNotAdd2Proj to avoid adding .dcp to a project because
              this would prevent manually adding of .dcp to a project
              (this could be the case if you would add a component "installation"
               as project)
              later (> V 2.4) we should delegate the check to IDEInterface
              CSc 18.04.2005
              Also exclude .dll files (for .net projects). Changed long IF statement into
              three single checks to make more clear what's going on.
            }
            if (CurrentFile = '') or (slChildExtensions.IndexOf(LowerCase(ExtractFileExt(CurrentFile)))<>-1) then
              Continue;
            if IsIDEPackage(sProjectName) and ((LowerCase(ExtractFileExt(CurrentFile)) = '.dcp') or (LowerCase(ExtractFileExt(CurrentFile)) = '.dll')) then
              Continue;
            if IsIDEProject(sProjectName, sProjectName) and (LowerCase(ExtractFileExt(CurrentFile)) = '.dll') then
              Continue;
            // ---
            
            DelphiModules.Add(AnsiLowerCase(CurrentFile));

            // The following is a workaround for people who don't have a correct file family configuration
            // for use with C++ Builder.  The user should have a file family with .cpp as the parent
            // and .dfm and .h files as children (and possibly .ddp, but that isn't checked for here).
            // If that file family isn't present, then the project manager will ask if any .h and .dfm
            // files with the same base name as any unit should be added to the VCS project.
            // See mantis #1176 and #3318
            if bIsCppBuilder then
            begin
              if FileExists(ChangeFileExt(CurrentFile, '.h')) and not bHasCPPFamilyWithH then
              begin
                DelphiModules.Add(AnsiLowerCase(ChangeFileExt(CurrentFile, '.h')));
              end;
              // BCP dfm fix provided by Petr 
              if FileExists(ChangeFileExt(CurrentFile, '.dfm')) and not bHasCPPFamilyWithDFM then
              begin
                DelphiModules.Add(AnsiLowerCase(ChangeFileExt(CurrentFile,'.dfm')));
              end;
            end; // if bIsCppBuilder then
          end; // for I := 0 to IDEInterface.GetUnitCount - 1 do begin
        finally
          slChildExtensions.Free;
          slFileFamilies.Free;
        end;
        AddMessage(Format(JVCSRES_IDE_reports_37d_core_modules, [DelphiModules.Count]) +
          Format(SrvTimeCnt, [(GetTickCount - TickCount) / 1000]),
          msclNormal);
        {$IFDEF DEBUG}
        JclDebug.TraceMsg('PM: FillListView - .cfg');
        {$ENDIF DEBUG}
        //--- .cfg datei -----------------------------------------------------------
        if jvcsReadBool(sBaseRegistryKey + crbOptions, 'AddCFGFiles', False) then
        begin
          AddMessage(JVCSRES_Adding_configuration_4046cfg41_file_to_core_modules +
            Format(SrvTimeCnt, [(GetTickCount - TickCount) / 1000]), msclNormal);
          if FileExists(ChangeFileExt(sProjectName, '.cfg')) then
            DelphiModules.Add(AnsiLowerCase(ChangeFileExt(sProjectName, '.cfg')));
        end;
        {$IFDEF DEBUG}
        JclDebug.TraceMsg('PM: FillListView - .dsk');
        {$ENDIF DEBUG}
        //--- .dsk datei -----------------------------------------------------------
        if jvcsReadBool(sBaseRegistryKey + crbOptions, 'AddDSKFiles', False) then
        begin
          AddMessage(JVCSRES_Adding_desktop_4046dsk41_file_to_core_modules +
            Format(SrvTimeCnt, [(GetTickCount - TickCount) / 1000]), msclNormal);
          if FileExists(ChangeFileExt(sProjectName, '.dsk')) then
            DelphiModules.Add(AnsiLowerCase(ChangeFileExt(sProjectName, '.dsk')));
        end;
      end; // if (sProjectName <> '') then begin
      {$ENDIF IDEDLL}
      {$IFDEF DEBUG}
      JclDebug.TraceMsg('PM: FillListView - StartUpdate');
      {$ENDIF DEBUG}
      StatusBarGaugePos(5);
      //--- Start update -----------------------------------------------------------
      elvModules.AutoResort := False;
      try
        elvModules.BeginUpdate;
        elvModules.OnChange := Nil;
        try
          elvModules.Items.Clear;
          uilPluginManager1.SendMessage(pimsgFVCSProjectModulesClear, '');
          ProjectFolders.Clear;
          //--- Load Custom filter ---------------------------------------------------
          {$IFDEF DEBUG} // MG
          JclDebug.TraceMsg('PM: FillListView - Load Custom filter');
          {$ENDIF DEBUG}
          CustFiltItems := TStringList.Create;
          try
            PCFFileName := sConfigFolder + ChangeFileExt(ExtractFileName(sProjectName), '.pcf');
            if FileExists(PCFFileName) then
            begin
              AddMessage(Format(JVCSRES_Local58_40Custom_view_filter_file58_37s41,
                [AnsiLowerCase(PCFFileName)]) +
                Format(SrvTimeCnt, [(GetTickCount - TickCount) / 1000]), msclNormal);
              try
                CustFiltItems.LoadFromFile(PCFFileName);
              except
                on E :
                Exception do
                begin
                  CustFiltItems.Clear;
                  BeepIfSet;
                  MessageBox(Handle, PChar(Format(JVCSRES_Reading_file_6037s62 + #13#10 +
                    JVCSRES_raised_exception58 + #13#10 + '%s.', [PCFFileName, E.Message])),
                    cMsgBoxCaption, MB_OK or MB_ICONSTOP);
                end;
              end;
              // Message Window
              AddMessage(Format(JVCSRES_Custom_view_filter_contains58_37d_modules,
                [CustFiltItems.Count]) +
                Format(SrvTimeCnt, [(GetTickCount - TickCount) / 1000]), msclNormal);
            end // if FileExists(PCFFileName) then begin
            else
              // Message Window
              AddMessage(JVCSRES_Custom_view_filter58_Not_defined, msclNormal);

            {$IFDEF DEBUG} // MG
            JclDebug.TraceMsg('PM: FillListView - Check_Create_Project');
            {$ENDIF DEBUG}

            StatusBarGaugePos(10);

            if CanRunFutherFillListView then
            begin
              //--- get project ID -----------------------------------------------------
              if not Check_Create_Project(ExtractFileName(sProjectName), True, ServerProjectID) then
              begin
                ServerProjectID := -1;
                SetMenuStateEx;
                {$IFNDEF IDEDLL}
                sProjectName := '';
                bProjectOpen := False;
                {$ENDIF ~IDEDLL}
                ShowStatusBarGauge(False, False);
                SetStatusBar;
                RefreshTimer.Enabled := OldTimerState;
                Screen.Cursor := crDefault;
                bStopRefresh := False;
                Exit;
              end;
            end;

            //thu 08.08.2003 here would be the correct point for removing child family
            //               extension files
            {$IFDEF IDEDLL}

            {$ENDIF IDEDLL}

            if CanRunFutherFillListView then
            begin
              //--- get project right --------------------------------------------------
              {$IFDEF DEBUG} // MG
              JclDebug.TraceMsg('PM: FillListView - get project right: ' + IntToStr(ServerUserID));
              {$ENDIF DEBUG}
              with DataModule1 do
              begin
                AppSrvClient1.Request.Rewrite;
                AppSrvClient1.FunctionCode := 'GET_PROJECT_RIGHT';
                AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
                AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
                AppSrvClient1.Request.WriteFields(True, [ServerProjectID]);
                SetupTimeoutCounter;
                AppSrvClient1.Send;

                while WaitForAppSrvClient do
                  Application.ProcessMessages;
                if (AppSrvClientErr = -99) then
                begin
                  BeepIfSet;
                  ShowServerTimeOut(WindowHandle);
                  SetStatusBar;
                  RefreshTimer.Enabled := OldTimerState;
                  Screen.Cursor := crDefault;
                  bStopRefresh := False;
                  Exit;
                end;
                if (AppSrvClientErr <> 0) or
                  (AppSrvClient1.AnswerStatus <> '200') then
                begin
                  {$IFDEF DEBUG} // MG
                  JclDebug.TraceMsg('PM: FillListView - get project right :' + AppSrvClient1.Answer.Fields[0]);
                  {$ENDIF DEBUG}
                  BeepIfSet;
                  MessageBox(Handle, PChar(AppSrvClient1.Answer.Fields[0]), cMsgBoxCaption,
                    MB_OK or MB_ICONSTOP);
                  SetStatusBar;
                  RefreshTimer.Enabled := OldTimerState;
                  Screen.Cursor := crDefault;
                  bStopRefresh := False;
                  Exit;
                end;

                AppSrvClient1.Answer.First;
                if not AppSrvClient1.Answer.Eof then
                begin
                  if _StrToInt(AppSrvClient1.Answer.Fields[0]) < 1 then
                  begin
                    BeepIfSet;
                    MessageBox(Handle, PChar(Format(JVCSRES_Access_denied46_4037s41 + #13#10 +
                      JVCSRES_Project_6037s62_is_not_enabled_for_your_account46 + #13#10 +
                      JVCSRES_Please_contact_the_archive_administrator_for_more_information46, ['403',
                      ExtractFileName(sProjectName)])), PChar(JVCSRES_JEDI_VCS_Application_Server),
                      MB_OK or MB_ICONWARNING);
                    ServerProjectID := -1;
                    SetMenuStateEx;
                    {$IFNDEF IDEDLL}
                    sProjectName := '';
                    bProjectOpen := False;
                    {$ENDIF ~IDEDLL}
                    ShowStatusBarGauge(False, False);
                    SetStatusBar;
                    RefreshTimer.Enabled := OldTimerState;
                    Screen.Cursor := crDefault;
                    Exit;
                  end; // if _StrToInt(AppSrvClient1.Answer.Fields[0]) < 1 then begin
                end; // if not AppSrvClient1.Answer.EoF then begin
              end; // with DataModule1 do begin
              StatusBarGaugePos(20);
              Screen.Cursor := crHourGlass;
            end;
            if CanRunFutherFillListView then
            begin
              //--- get shared modules -------------------------------------------------
              GetSharedModules(True);
              StatusBarGaugePos(30);
              Screen.Cursor := crHourGlass;
            end;
            if CanRunFutherFillListView then
            begin
              //--- get all labels -----------------------------------------------------
              GetLabels;
              StatusBarGaugePos(40);
              Screen.Cursor := crHourGlass;
            end;
            if CanRunFutherFillListView then
            begin
              //--- get label assignement ----------------------------------------------
              GetLabelAssignement(True);
              StatusBarGaugePos(45);
              Screen.Cursor := crHourGlass;
            end;
            if CanRunFutherFillListView then
            begin
              //--- get bugs -----------------------------------------------------------
              GetModuleBugs(True);
              StatusBarGaugePos(50);
              Screen.Cursor := crHourGlass;
            end;
            if CanRunFutherFillListView then
            begin
              //--- get revisions ------------------------------------------------------
              {$IFDEF DEBUG} // MG
              JclDebug.TraceMsg('PM: FillListView - get revisions');
              {$ENDIF DEBUG}
              with DataModule1 do
              begin
                AppSrvClient1.Request.Rewrite;
                AppSrvClient1.FunctionCode := 'GET_VERSION_LIST';
                AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
                AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
                AppSrvClient1.Request.WriteFields(True, [ServerProjectID]);
                AppSrvClient1.Request.WriteFields(False,
                  [not mmiShowhiddenmodules.Checked]);
                SetupTimeoutCounter;
                AppSrvClient1.Send;
                // Message Window
                AddMessage(Format(JVCSRES_Server_request58_40Modules_38_revisions_assigned_to58_37s41,
                  [ExtractFileName(sProjectName)]) +
                  Format(SrvTimeCnt, [(GetTickCount - TickCount) / 1000]), msclNormal);

                while WaitForAppSrvClient do
                  Application.ProcessMessages;
                if (AppSrvClientErr = -99) then
                begin
                  ShowServerTimeOut(WindowHandle);
                  RefreshTimer.Enabled := OldTimerState;
                  Exit;
                end;
                if (AppSrvClientErr <> 0) or
                  (AppSrvClient1.AnswerStatus <> '200') then
                begin
                  ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
                    AppSrvClient1.AnswerStatus);
                  RefreshTimer.Enabled := OldTimerState;
                  Exit;
                end;
                StatusBarGaugePos(60);
                Screen.Cursor := crHourGlass;
                //--- ListView start ---------------------------------------------------
                StatusBarGaugeMax := AppSrvClient1.Answer.RecordCount;
                if StatusBarGaugeMax = 0 then
                  StatusBarGaugeMax := 1;
                // Message Window
                AddMessage(JVCSRES_Local58_40File_size_38_attributes41 +
                  Format(SrvTimeCnt, [(GetTickCount - TickCount) / 1000]), msclNormal);

                I := 0;
                AllModules := 0;
                FilteredModules := 0;
                AllRevisions := 0;
                ProjectModuleSize := 0;

                AppSrvClient1.Answer.First;

                {$IFDEF CUSTOMDRIVE}
                sDriveSubst := RegReadString(HKCU, sBaseRegistryKey + crbProjects +
                  ExtractFileName(sProjectName), 'LocalDrive', '');
                if (sDriveSubst = '') then
                  sDriveSubst := RegReadString(HKCU, sBaseRegistryKey + crbOptions,
                    'LocalDrive', '');
                {$ENDIF CUSTOMDRIVE}

                while (not AppSrvClient1.Answer.Eof) and CanRunFutherFillListView do
                begin
                  CurrentFile := AppSrvClient1.Answer.Fields[1];
                  {$IFDEF CUSTOMDRIVE}
                  CurrentPath := ChangeDriveName(AppSrvClient1.Answer.Fields[2], sDriveSubst);
                  {$ELSE}
                  CurrentPath := AppSrvClient1.Answer.Fields[2];
                  {$ENDIF CUSTOMDRIVE}

                  Inc(AllModules);
                  AllRevisions := AllRevisions +
                    _StrToInt(AppSrvClient1.Answer.Fields[11]);
                  Inc(I);
                  ProjectFolders.Add(CurrentPath);

                  // Custom view Filter
                  FilterOut := False;
                  if mmiApplycustomfilter.Checked then
                    FilterOut := (CustFiltItems.IndexOf(CurrentPath + CurrentFile) <> -1);

                  if (not FilterOut) and mmiDefineWCView.Checked then
                  begin
                    if not MatchWithFilter(CurrentFile, WildCardFilter) then
                      FilterOut := True;
                  end; // if not FilterOut and mmiDefineWCView.Checked then begin
                  //--------------------------------------------------------------------
                  if not FilterOut then
                  begin
                    if not HasAssociateFile(CurrentPath + CurrentFile, Associate) then
                      Associate := '';
                    ModuleID := _StrToInt(AppSrvClient1.Answer.Fields[0]);
                    //--- get bug state / filter bugs ----------------------------------
                    BugStateIndex := GetBugStateIndex(ModuleID);
                    if (BugStateFilter > -1) and ((BugStateIndex - 4) < BugStateFilter) then
                      goto NextModule1;

                    if ShowLocalInfo then
                      FExists := FileExists(CurrentPath + CurrentFile)
                    else
                      FExists := True;
                    {TimeStamp := DateTimeToStr(_StrToFloat(AppSrvClient1.Answer.Fields[4]));}
                    CheckedOut := DecodeBoolStr(AppSrvClient1.Answer.Fields[3]);
                    if CheckedOut then
                      ModuleOwner := AppSrvClient1.Answer.Fields[10]
                    else
                      ModuleOwner := '';
                    RevisionID := _StrToInt(AppSrvClient1.Answer.Fields[6]);
                    Hidden := (AppSrvClient1.Answer.Fields[9] = '1');
                    //--- Module -------------------------------------------------------
                    NewItem := elvModules.Items.Add;
                    uilPluginManager1.SendMessage(pimsgFVCSProjectModulesAdd,
                      CurrentPath + CurrentFile);
                    //--- Caption ------------------------------------------------------
                    NewItem.Caption := CurrentFile;
                    //--- File Icon ----------------------------------------------------
                    NewItem.ImageIndex := GetFileImageIndex(CurrentPath + CurrentFile, ShowLocalInfo, FExists);
                    //--- StateIcons ---------------------------------------------------
                    if BugStateIndex > 0 then
                      NewItem.StateIndex := BugStateIndex
                    else
                    begin
                      if not Hidden then
                        NewItem.StateIndex := 0
                      else
                        NewItem.StateIndex := 3;
                    end;
                    //--- Type ---------------------------------------------------------
                    if ShowTypeInfo then
                    begin
                      NewItem.SubItems.Add(GetFileType(CurrentPath + CurrentFile));
                    end
                    else
                      NewItem.SubItems.Add(ExtractFileExt(CurrentFile));
                    //--- Path ---------------------------------------------------------
                    NewItem.SubItems.Add(CurrentPath);
                    //--- Version ------------------------------------------------------
                    NewItem.SubItems.Add(AppSrvClient1.Answer.Fields[7] + '.' +
                      AppSrvClient1.Answer.Fields[8]);
                    //--- State --------------------------------------------------------
                    if CheckedOut then
                      NewItem.SubItems.Add(JVCSRES_Out)
                    else
                      NewItem.SubItems.Add(JVCSRES_In);
                    //--- Owner --------------------------------------------------------
                    if CheckedOut then
                      NewItem.SubItems.Add(ModuleOwner)
                    else
                      NewItem.SubItems.Add('');
                    //--- Count --------------------------------------------------------
                    NewItem.SubItems.Add(AppSrvClient1.Answer.Fields[11]);
                    //--- Keyword ------------------------------------------------------
                    LabelString := GetModuleRevisionLabels(ModuleID, RevisionID);
                    if LabelString = '' then
                      NewItem.SubItems.Add('-')
                    else
                      NewItem.SubItems.Add(LabelString);
                    //--- Shared -------------------------------------------------------
                    if SharedModuleIDs.IndexOf(IntToStr(ModuleID)) <> -1 then
                      NewItem.SubItems.Add(JVCSRES_Yes)
                    else
                      NewItem.SubItems.Add(JVCSRES_No);
                    //--- Size ---------------------------------------------------------
                    if ShowLocalInfo then
                    begin
                      if FExists then
                      begin
                        FSize := _GetFileSizeEx(CurrentPath + CurrentFile, OrigName);
                        if Associate <> '' then
                          FSize := FSize + _GetFileSize(Associate);
                        NewItem.SubItems.Add(FormatFloat('#,', FSize));
                        ProjectModuleSize := ProjectModuleSize + FSize;
                        NewItem.Caption := OrigName;
                      end
                      else
                        NewItem.SubItems.Add('-');
                    end
                    else
                      NewItem.SubItems.Add('-');
                    {$IFDEF DEBUG} // MG
                    JclDebug.TraceMsg('PM: FillListView - Date');
                    {$ENDIF DEBUG}
                    //--- Date ---------------------------------------------------------
                    if ShowLocalInfo then
                    begin
                      if FExists then
                      begin
                        if IsDirectory(CurrentPath + CurrentFile) then
                        begin
                          if GetFileCreation(CurrentPath + CurrentFile, aDateTime) then
                          begin
                            NewItem.SubItems.Add(DateTimeToStr(aDateTime));
                          end;
                        end
                        else
                        begin
                          NewItem.SubItems.Add(DateTimeToStr(FileDateToDateTime(FileAge(CurrentPath +
                            CurrentFile))));
                        end;
                      end
                      else
                      begin
                        NewItem.SubItems.Add('-');
                      end;
                    end
                    else
                    begin
                      NewItem.SubItems.Add('-');
                    end;
                    //--- Attr ---------------------------------------------------------
                    if ShowLocalInfo then
                    begin
                      if FExists then
                        NewItem.SubItems.Add(GetAttrStrEx(CurrentPath + CurrentFile))
                      else
                        NewItem.SubItems.Add('-');
                    end
                    else
                      NewItem.SubItems.Add('-');
                    //--- Module ID ----------------------------------------------------
                    NewItem.SubItems.Add(IntToStr(ModuleID));
                    //--- Revision ID --------------------------------------------------
                    NewItem.SubItems.Add(IntToStr(RevisionID));
                    //--- Version Info Resource ----------------------------------------
                    {$IFDEF IDEDLL}
                    if IsIDEProject(CurrentFile, sProjectName) then
                      SaveProjectFileInfo(sProjectName,
                        _StrToInt(AppSrvClient1.Answer.Fields[7]),
                        _StrToInt(AppSrvClient1.Answer.Fields[8]), - 1, - 1, - 1);
                    {$ENDIF IDEDLL}
                    //--- ready --------------------------------------------------------
                    NextModule1:
                    AppSrvClient1.Answer.Next;
                  end // if not FilterOut then begin
                  else
                  begin
                    Inc(FilteredModules);
                    AppSrvClient1.Answer.Next;
                  end;
                  //--------------------------------------------------------------------
                  //--- remove the current file from 'DelphiModules' -------------------
                  J := DelphiModules.IndexOf(CurrentPath + CurrentFile);
                  if J <> -1 then
                    DelphiModules.Delete(J);
                  // Progress calcalution
                  StatusBarGaugePos(Round((I / StatusBarGaugeMax) * 30) + 60);
                end; // while not AppSrvClient1.Answer.EoF do begin
              end; // with DataModule1 do begin
            end // if CanRunFutherFillListView then \n begin
            else
            begin
              //avoid compiler warning
              AllModules := 0;
              AllRevisions := 0;
            end;
            if CanRunFutherFillListView then
            begin
              //--- Add modules without revision ---------------------------------------
              // Message Window
              AddMessage(Format(JVCSRES_Server_request58_40Modules_without_revision_assigned_to58_37s41,
                [ExtractFileName(sProjectName)]) +
                Format(SrvTimeCnt, [(GetTickCount - TickCount) / 1000]), msclNormal);
              with DataModule1 do
              begin
                AppSrvClient1.Request.Rewrite;
                AppSrvClient1.FunctionCode := 'GET_BLANK_MODULE_LIST';
                AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
                AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
                AppSrvClient1.Request.WriteFields(True, [ServerProjectID]);
                AppSrvClient1.Request.WriteFields(False,
                  [not mmiShowhiddenmodules.Checked]);
                SetupTimeoutCounter;
                AppSrvClient1.Send;

                while WaitForAppSrvClient do
                  Application.ProcessMessages;
                if (AppSrvClientErr = -99) then
                begin
                  ShowServerTimeOut(WindowHandle);
                  RefreshTimer.Enabled := OldTimerState;
                  Exit;
                end;
                if (AppSrvClientErr <> 0) or
                  (AppSrvClient1.AnswerStatus <> '200') then
                begin
                  ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
                    AppSrvClient1.AnswerStatus);
                  RefreshTimer.Enabled := OldTimerState;
                  Exit;
                end;

                StatusBarGaugeMax := AppSrvClient1.Answer.RecordCount;
                Screen.Cursor := crHourGlass;

                if StatusBarGaugeMax = 0 then
                  StatusBarGaugeMax := 1;
                I := 0;

                AppSrvClient1.Answer.First;
                while (not AppSrvClient1.Answer.Eof) and CanRunFutherFillListView do
                begin
                  ModuleID := _StrToInt(AppSrvClient1.Answer.Fields[0]);
                  CurrentFile := AppSrvClient1.Answer.Fields[1];
                  {$IFDEF CUSTOMDRIVE}
                  CurrentPath := ChangeDriveName(AppSrvClient1.Answer.Fields[2], sDriveSubst);
                  {$ELSE}
                  CurrentPath := AppSrvClient1.Answer.Fields[2];
                  {$ENDIF CUSTOMDRIVE}
                  Hidden := (AppSrvClient1.Answer.Fields[3] = '1');
                  Inc(AllModules);
                  Inc(I);

                  // Custom view Filter
                  FilterOut := False;
                  if mmiApplycustomfilter.Checked then
                    FilterOut := (CustFiltItems.IndexOf(CurrentPath + CurrentFile) <> -1);

                  if (not FilterOut) and mmiDefineWCView.Checked then
                  begin
                    if not MatchWithFilter(CurrentFile, WildCardFilter) then
                      FilterOut := True;
                  end; // if not FilterOut and mmiDefineWCView.Checked then begin
                  //--------------------------------------------------------------------
                  if not FilterOut then
                  begin
                    //--- get bug state / filter bugs ----------------------------------
                    BugStateIndex := GetBugStateIndex(ModuleID);
                    if (BugStateFilter > -1) and ((BugStateIndex - 4) < BugStateFilter) then
                      goto NextModule2;
                    //--- Module available ---------------------------------------------
                    if ShowLocalInfo then
                      FExists := FileExists(CurrentPath + CurrentFile)
                    else
                      FExists := True;
                    if not HasAssociateFile(CurrentPath + CurrentFile, Associate) then
                      Associate := '';
                    //--- Module -------------------------------------------------------
                    NewItem := elvModules.Items.Add;
                    uilPluginManager1.SendMessage(pimsgFVCSProjectModulesAdd,
                      CurrentPath + CurrentFile);
                    //--- Caption ------------------------------------------------------
                    NewItem.Caption := CurrentFile;
                    //--- File Icon ----------------------------------------------------
                    NewItem.ImageIndex := GetFileImageIndex(CurrentPath + CurrentFile, ShowLocalInfo, FExists);
                    //--- StateIcons ---------------------------------------------------
                    if BugStateIndex > 0 then
                      NewItem.StateIndex := BugStateIndex
                    else
                    begin
                      if not Hidden then
                      begin
                        NewItem.StateIndex := 0;
                      end
                      else
                        NewItem.StateIndex := 3;
                    end;
                    //--- Type ---------------------------------------------------------
                    if ShowTypeInfo then
                    begin
                      NewItem.SubItems.Add(GetFileType(CurrentPath + CurrentFile));
                    end
                    else
                      NewItem.SubItems.Add(ExtractFileExt(CurrentFile));
                    //--- Path ---------------------------------------------------------
                    NewItem.SubItems.Add(CurrentPath);
                    //--- Version ------------------------------------------------------
                    NewItem.SubItems.Add(JVCSRES_N47A);
                    //--- State --------------------------------------------------------
                    NewItem.SubItems.Add(JVCSRES_N47A);
                    //--- Owner --------------------------------------------------------
                    NewItem.SubItems.Add(JVCSRES_N47A);
                    //--- Count --------------------------------------------------------
                    NewItem.SubItems.Add('0');
                    //--- Keyword ------------------------------------------------------
                    NewItem.SubItems.Add(JVCSRES_N47A);
                    //--- Shared -------------------------------------------------------
                    if SharedModuleIDs.IndexOf(IntToStr(ModuleID)) <> -1 then
                      NewItem.SubItems.Add(JVCSRES_Yes)
                    else
                      NewItem.SubItems.Add(JVCSRES_No);
                    //--- Size ---------------------------------------------------------
                    if ShowLocalInfo then
                    begin
                      if FExists then
                      begin
                        FSize := _GetFileSizeEx(CurrentPath + CurrentFile, OrigName);
                        if Associate <> '' then
                          FSize := FSize + _GetFileSize(Associate);
                        NewItem.SubItems.Add(FormatFloat('#,', FSize));
                        ProjectModuleSize := ProjectModuleSize + FSize;
                        NewItem.Caption := OrigName;
                      end
                      else
                        NewItem.SubItems.Add('-');
                    end
                    else
                      NewItem.SubItems.Add('-');
                    //--- Date ---------------------------------------------------------
                    if ShowLocalInfo then
                    begin
                      if FExists then
                      begin
                        if IsDirectory(CurrentPath + CurrentFile) then
                        begin
                          if GetFileCreation(CurrentPath + CurrentFile, aDateTime) then
                          begin
                            NewItem.SubItems.Add(DateTimeToStr(aDateTime));
                          end;
                        end
                        else
                        begin
                          NewItem.SubItems.Add(DateTimeToStr(FileDateToDateTime(FileAge(CurrentPath +
                            CurrentFile))));
                        end;
                      end
                      else
                      begin
                        NewItem.SubItems.Add('-');
                      end;
                    end
                    else
                    begin
                      NewItem.SubItems.Add('-');
                    end;
                    //--- Attr ---------------------------------------------------------
                    if ShowLocalInfo then
                    begin
                      if FExists then
                        NewItem.SubItems.Add(GetAttrStrEx(CurrentPath + CurrentFile))
                      else
                        NewItem.SubItems.Add('-');
                    end
                    else
                      NewItem.SubItems.Add('-');
                    //--- Module ID ----------------------------------------------------
                    NewItem.SubItems.Add(IntToStr(ModuleID));
                    //--- Revision ID --------------------------------------------------
                    NewItem.SubItems.Add(JVCSRES_N47A);
                  end // if not FilterOut then begin
                  else
                    Inc(FilteredModules);
                  NextModule2 :
                  //--- remove the current file from 'DelphiModules' -------------------
                  J := DelphiModules.IndexOf(CurrentPath + CurrentFile);
                  if J <> -1 then
                    DelphiModules.Delete(J);
                  StatusBarGaugePos(Round((I / StatusBarGaugeMax) * 10) + 90);
                  AppSrvClient1.Answer.Next;
                end; // while not AppSrvClient1.Answer.EoF do begin
              end; // with DataModule1 do begin
            end; // if CanRunFutherFillListView then \n begin
            //--- ListView ready -----------------------------------------------------
            StatusBarGaugePos(100);
          finally
            elvModules.EndUpdate;
            elvModules.OnChange := elvModulesChange;
            elvModulesChange(nil, nil, ctState);
          end;
        finally
          elvModules.AutoResort := True;
          elvModules.Resort;
          Screen.Cursor := crDefault;
        end;
        Msg := Format(JVCSRES_Server_reports_37d_modules_38_37d_revisions,
          [AllModules, AllRevisions]);
        if not mmiShowhiddenmodules.Checked then
          Msg := Format(JVCSRES_37s_40w47o_hidden_modules41, [Msg]);
        AddMessage(Msg + Format(SrvTimeCnt, [(GetTickCount - TickCount) / 1000]), msclNormal);
        //--- Add core modules not member of the archive ---------------------------
        {$IFDEF IDEDLL}
        StatusBarGaugeMax := DelphiModules.Count;
        Screen.Cursor := crHourGlass;
        if StatusBarGaugeMax = 0 then
          StatusBarGaugeMax := 1;
        StatusBarGaugePos(0);
        Yes2all := False;
        NewModules := TStringList.Create;
        try
          SkipNewModulesFile := sConfigFolder + ChangeFileExt(ExtractFileName(sProjectName), '.snm');
          SkipNewModules := TStringList.Create;
          try
            if FileExists(SkipNewModulesFile) then
            begin
              try
                SkipNewModules.LoadFromFile(SkipNewModulesFile);
              except
                on E :
                Exception do
                begin
                  SkipNewModules.Clear;
                  BeepIfSet;
                  MessageBox(Handle, PChar(Format(JVCSRES_Reading_file_6037s62 + #13#10 +
                    JVCSRES_raised_exception58 + #13#10 + '%s.',
                    [SkipNewModulesFile, E.Message])), cMsgBoxCaption, MB_OK or MB_ICONSTOP);
                end;
              end;
            end; // if FileExits(SkipNewModulesFile) then begin

            elvModules.BeginUpdate;
            try
              for I := 0 to DelphiModules.Count - 1 do
              begin
                if SkipNewModules.IndexOf(AnsiLowerCase(DelphiModules.Strings[I])) > -1 then
                  Continue;
                Skip := False;
                if not Yes2all then
                begin
                  VCSYes2AllDlg := TVCSYes2AllDlg.Create(Application);
                  try
                    if (DelphiModules.Count > 1) then
                      VCSYes2AllDlg.EnableYes2All(True)
                    else
                      VCSYes2AllDlg.EnableYes2All(False);
                    VCSYes2AllDlg.SetMessageText(Format(JVCSRES_6037s62_4037d4737d41,
                      [ExtractFileName(DelphiModules.Strings[I]), I + 1, DelphiModules.Count]) + #10#13 +
                      JVCSRES_is_not_a_member_of_the_version_archive46 + #10#13 +
                      JVCSRES_Do_you_wish_to_add_it_now63);
                    VCSYes2AllDlg.ShowCheckBox(True);
                    VCSYes2AllDlg.SetCheckBoxCaption(JVCSRES_38Don39t_ask_me_further_about_this_file46);
                    {  Achtung! Wenn dieser Text geändert wird, muß die Routine im
                       Yes2All Dialog angepasst werden!  }
                    { english: if you use an other string with VCSYes2AllDlg.SetCheckBoxCaption
                        than TVCSYes2AllDlg.CheckBox1Click has to be adjusted }
                    Yes2allRes := VCSYes2AllDlg.ShowModal;
                    SkipAlways := VCSYes2AllDlg.CheckBoxChecked;
                  finally
                    VCSYes2AllDlg.Free;
                  end;
                  case Yes2allRes of
                    mrYes :;
                    mrAll :
                      Yes2all := True;
                    mrNo :
                      begin
                        Skip := True;
                        if SkipAlways then
                          SkipNewModules.Add(AnsiLowerCase(DelphiModules.Strings[I]));
                      end;
                    mrCancel :
                      Break;
                  end; // case Yes2allRes of
                end; // if not Yes2all then begin
                if not Skip then
                begin
                  AddResult := AddModule(DelphiModules.Strings[I]);
                  if AddResult <> 0 then
                    NewModules.Add(IntToStr(AddResult));
                end;
                StatusBarGaugePos(Round((I / StatusBarGaugeMax) * 100));
              end; // for I := 0 to DelphiModules.Count - 1 do begin
              BringWindowToTop(WindowHandle);
            finally
              elvModules.EndUpdate;
            end;
            try
              SkipNewModules.SaveToFile(SkipNewModulesFile);
            except
              MessageBox(WindowHandle, PChar(Format(JVCSRES_JEDI_VCS_cannot_save_the_file + #13#10 +
                '<%s>.' + JVCSRES_Be_sure_that_the_file_is_not_opened_by_another_application44 +
                JVCSRES_that_there_is_enough_free_space_on_the_disk + #13#10 +
                JVCSRES_and_that_you_have_the_required_access_rights46,
                [SkipNewModulesFile])), cMsgBoxCaption, MB_OK or MB_ICONSTOP);
            end;
          finally
            SkipNewModules.Free;
          end;
          DSAIdentsSetState(sBaseRegistryKey + crbMRU + 'Dlgs', 'IsSharedMod', True);
          // checkin the new modules
          if NewModules.Count > 0 then
          begin
            VCSChkInSingle := TVCSChkInSingle.Create(Application);
            try
              for I := 0 to NewModules.Count - 1 do
                VCSChkInSingle.SelectModuleList.AddObject('>' + NewModules.Strings[I], TObject(ServerProjectID));
              VCSChkInSingle.AsChild := True;
              VCSChkInSingle.ShowModal;
              NeedRefresh := VCSChkInSingle.ArchiveChanged;
            finally
              VCSChkInSingle.Free;
            end;
            if NeedRefresh then
            begin
              with elvModules do
              begin
                elvModules.AutoResort := False;
                try
                  elvModules.BeginUpdate;
                  try
                    for I := 0 to Items.Count - 1 do
                    begin
                      if NewModules.IndexOf(Items[I].SubItems[sitMID]) <> -1 then
                        ADD_Refresh_Module(False, I, _StrToInt(Items[I].SubItems[sitMID]),
                          Items[I].SubItems[sitPath] + LowerCase(Items[I].Caption));
                    end; // for I := 0 to Items.Count - 1 do begin
                  finally
                    elvModules.EndUpdate;
                  end;
                finally
                  elvModules.AutoResort := True;
                  elvModules.Resort;
                end;
              end; // with elvModules do begin
            end;
          end; // if NewModules.Count > 0 then begin
        finally
          NewModules.Free;
        end;
        {$ENDIF IDEDLL}
      finally
        if Assigned(CustFiltItems) then
          CustFiltItems.Free;
      end;
      ShowStatusBarGauge(False, False);
      Screen.Cursor := crDefault;
      SetStatusBar;
      if mmiDefineWCView.Checked then
        Msg := Format(JVCSRES__match_4037s41, [WildCardFilter])
      else
        Msg := '';
      case BugStateFilter of -1:;
        0:
          Msg := Format(JVCSRES_37s_45_Bug_filter_406261_37s41, [Msg, JVCSRES_Minor]);
        1:
          Msg := Format(JVCSRES_37s_45_Bug_filter_406261_37s41, [Msg, JVCSRES_Awkward]);
        2:
          Msg := Format(JVCSRES_37s_45_Bug_filter_406261_37s41, [Msg, JVCSRES_Significant]);
        3:
          Msg := Format(JVCSRES_37s_45_Bug_filter_406261_37s41, [Msg, JVCSRES_Serious]);
        4:
          Msg := Format(JVCSRES_37s_45_Bug_filter_406261_37s41, [Msg, JVCSRES_Fatal]);
      end;
      AddMessage(Format(JVCSRES_Currently_visible58_37d_modules, [elvModules.Items.Count])
        + Msg + Format(SrvTimeCnt, [(GetTickCount - TickCount) / 1000]), msclNormal);
      elvModules.Resort;
      {$IFDEF IDEDLL}
      if bPJM_TopWindow then
        {$ENDIF IDEDLL}
        elvModules.SetFocus;
      GetArchiveTimeStamp(ArchTStamp);
      RefreshTimer.Enabled := OldTimerState;
      if NeedRefresh then
      begin
        acRefreshFormExecute(Self);
        SetMenuStateEx;
        SetStatusBar;
      end;
      uilPluginManager1.SendMessage(pimsgFVCSProject, sProjectName);
      {$IFNDEF IDEDLL}
      if FillListViewAborted and bProjectOpen then
        mmiCloseProjectClick(Self);
      {$ENDIF ~IDEDLL}
    finally
      FIsInFillListView := False;
    end;
  end;
end;

//------------------------------------------------------------------------------

function TVCSProjAdmin.ArchivedModuleSelected: Boolean;
begin
  Result := False;
  if (elvModules.Selected <> nil) and
    (elvModules.Selected.SubItems[sitRID] = JVCSRES_N47A) then
  begin
    MessageBox(WindowHandle, PChar(Format(JVCSRES_No_revisions_of_6037s62_in_the_archive46 + #13#10 +
      JVCSRES_This_command_is_only_available_for_archived_files46, [elvModules.Selected.Caption])),
      cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
    Exit;
  end;
  Result := True;
end;

//------------------------------------------------------------------------------

function TVCSProjAdmin.AddModule(const CurrentModule: string): Integer;
var 
  FileName, Mess, ModuleDescr: string;
  I, ModuleID: Integer;
  NewModule, ExpandKeywords, FileIsAssoc: Boolean;
  {$IFDEF IDEDLL}
  FileWasOpen: Boolean;
  {$ENDIF IDEDLL}
begin
  Result := 0;
  bStopRefresh := True;

  //--- keine .dfm Dateien -----------------------------------------------------
  FileName := CurrentModule;
  FileIsAssoc := ResolveFileFamilies(FileName);
  
  //--- path information available? --------------------------------------------
  if (ExtractFilePath(FileName) = '') then
  begin
    MessageBox(WindowHandle, PChar(Format('<%s>' + #13#10 + JVCSRES_No_path_information_available46 + #13#10 +
      JVCSRES_JEDI_VCS_cannot_add_or_checkin_the_module_without_path_information46,
      [FileName])), cMsgBoxCaption, MB_OK or MB_ICONWARNING);
    elvModules.SetFocus;
    bStopRefresh := False;
    Exit;
  end; // if not FileExists(ModuleName) then begin

  //--- Ungültige Zeichen ------------------------------------------------------
  if not IsValidModuleName(ExtractFileName(FileName), Mess) then 
  begin
    MessageBox(WindowHandle, PChar(Format('<%s>' + #13#10 + '%s' + #13#10 +
      JVCSRES_See_help_topic_34Naming_conventions34_for_more_information46,
      [ExtractFileName(FileName), Mess])), cMsgBoxCaption, MB_OK or
      MB_ICONEXCLAMATION);
    elvModules.SetFocus;
    bStopRefresh := False;
    Exit;
  end;

  //--- keine Datenbanken, keine Projektdatei ! --------------------------------
  if not MatchWithFilter(ExtractFileName(FileName), dfNotAdd2Proj) then
  begin
    with DataModule1 do
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'IS_MEMBER_OF_PROJECT';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [ServerProjectID]);
      AppSrvClient1.Request.WriteFields(False, [FileName]);
      SetupTimeoutCounter;
      AppSrvClient1.Send;

      while WaitForAppSrvClient do 
        Application.ProcessMessages;
      if (AppSrvClientErr = -99) then 
      begin
        ShowServerTimeOut(WindowHandle);
        bStopRefresh := False;
        Exit;
      end;
      if (AppSrvClientErr <> 0) or
        (AppSrvClient1.AnswerStatus <> '200') then
      begin
        ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
          AppSrvClient1.AnswerStatus);
        bStopRefresh := False;
        Exit;
      end;

      AppSrvClient1.Answer.First;
      if DecodeBoolStr(AppSrvClient1.Answer.Fields[0]) then
      begin
        Mess := Format('<%s>' + #13#10 +
          JVCSRES_This_module_is_already_a_member_of_the_current_project46,
          [ExtractFileName(FileName)]);
        if FileIsAssoc then
          Mess := Mess + #13#10 + JVCSRES_Probably_you39ve_tried_to_add_one_of_his_file_family_members46;
        UseRegistry := True;
        DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46 + JVCSRES__40Skip_such_files41;
        if not DSAIdentsGetState(sBaseRegistryKey + crbMRU + 'Dlgs', 'SkipExisting') then
          AddMessage(Format(JVCSRES_Already_a_member44_skipped58_37s, [FileName]), msclNormal);
        DSAIdentsMessageDlg(Mess
          , mtInformation
          , [mbOK]
          , 0
          , sBaseRegistryKey + crbMRU + 'Dlgs'
          , 'SkipExisting'
          , idOk
          );
        elvModules.SetFocus;
        bStopRefresh := False;
        Exit;
      end;
      //--- Description --------------------------------------------------------
      ModuleDescr := '';
      if not jvcsReadBool(sBaseRegistryKey + crbOptions, 'SkipModuleDescr', False) then
      begin
        VCSDescription := TVCSDescription.Create(Application);
        try
          VCSDescription.Top := Top + 60;
          VCSDescription.Left := Left + 60;
          VCSDescription.DescType := 2;
          VCSDescription.SetDescripCaption(Format(JVCSRES_38Module58_37s,
            [ExtractFileName(FileName)]));
          VCSDescription.ShowModal;
          ModuleDescr := VCSDescription.Description;
          jvcsWriteBool(sBaseRegistryKey + crbOptions, 'SkipModuleDescr',
            VCSDescription.cbState);
        finally
          VCSDescription.Free;
        end;
      end; // if not RegReadBool(....
      Application.ProcessMessages;
      elvModules.Repaint;
      //--- Execute ------------------------------------------------------------
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'ADD_NEW_MODULE';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [ServerProjectID]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(False, [FileName]);
      AppSrvClient1.Request.WriteFields(False, [moVer200]); // flags
      AppSrvClient1.Request.WriteFields(False, [ModuleDescr]);
      SetupTimeoutCounter;
      AppSrvClient1.Send;

      while WaitForAppSrvClient do 
        Application.ProcessMessages;
      if (AppSrvClientErr = -99) then 
      begin
        ShowServerTimeOut(WindowHandle);
        bStopRefresh := False;
        Exit;
      end;      
      if (AppSrvClientErr <> 0) or
        (AppSrvClient1.AnswerStatus <> '200') then 
      begin
        ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
          AppSrvClient1.AnswerStatus);
        bStopRefresh := False;
        Exit;
      end;

      AppSrvClient1.Answer.First;
      NewModule := DecodeBoolStr(AppSrvClient1.Answer.Fields[0]);
      ModuleID := _StrToInt(AppSrvClient1.Answer.Fields[1]);
      //--- New? ---------------------------------------------------------------
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
        if I > 0 then
        begin
          UseRegistry := True;
          DontShowMsgText := JVCSRES_38Don39t_show_this_message_again_in_the_current_queue46;
          DSAIdentsMessageDlg(Format('<%s>' + #13#10 +
            JVCSRES_This_module_is_already_used_by_37d_other_projects58 + #13#10 + '%s',
            [ExtractFileName(FileName), I, Mess])
            , mtInformation
            , [mbOK]
            , 0
            , sBaseRegistryKey + crbMRU + 'Dlgs'
            , 'IsSharedMod'
            , idOk
            );
          GetSharedModules(False);
        end; // if I > 0 then begin
        ADD_Refresh_Module(True, 0, ModuleID, FileName);
      end // if not NewModule then begin
      else 
      begin
        //--- Keyword Expansion ------------------------------------------------
        //??? GlobalSettings
        if not SettingIsGlobal(6) then
          ExpandKeywords :=
            jvcsReadBool(sBaseRegistryKey + crbOptions, 'KWExpAdd', False)
        else
          ExpandKeywords := GlobalSettingValue(6);

        if ExpandKeywords then
        begin
          Screen.Cursor := crHourGlass;
          if MatchWithFilter(ExtractFileName(FileName),
            jvcsReadString(sBaseRegistryKey + crbOptions, 'KWExpFiles', dfKWExp)) then
          begin
            {$IFDEF IDEDLL}
            FileWasOpen := IDEInterface.IsFileOpen(FileName);
            if not ((FileGetAttr(FileName) and faReadOnly) = faReadOnly) then
              IDEInterface.SaveFile(FileName);
            if (not IsIDEProject(FileName, sProjectName)) and
              (not IsIDEPackage(FileName)) then
              IDEInterface.CloseFile(FileName);
            {$ENDIF IDEDLL}
            ExpanseKeywords(Application, WindowHandle, kwexAdd, FileName,
              sCurrentUser, ModuleDescr, '', 0, 0, ModuleID, 0);
            {$IFDEF IDEDLL}
            // reload
            if FileWasOpen and
              (not IsIDEProject(FileName, sProjectName)) and
              (not IsIDEPackage(FileName)) then
              IDEInterface.OpenFile(FileName);
            {$ENDIF IDEDLL}
          end; // if MatchWithFilter(ExtractFileExt(FileName),...
          Screen.Cursor := crDefault;
        end; // if ExpandKeywords then begin
        AddNewModule(FileName, ModuleID);
        Result := ModuleID;
      end;
    end; // with DataModule1 do begin
    // Message Window
    AddMessage(Format(JVCSRES_Added_to_project58_37s_45_Success, [FileName]), msclNormal);
    GetArchiveTimeStamp(ArchTStamp);
  end
  else
  begin
    Mess := Format(JVCSRES_You_cannot_add_this_type_of_file58 + #13#10 + '<%s>', [dfNotAdd2Proj]);
    MessageBox(WindowHandle, PChar(Mess), cMsgBoxCaption, MB_OK or MB_ICONWARNING);
  end;
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.acAddSharedExecute(Sender: TObject);
var 
  SelectedModuleNames: TStringList;
  I: Integer;
begin
  bStopRefresh := True;
  SelectedModuleNames := TStringList.Create;
  try
    VCSAddSharedModule := TVCSAddSharedModule.Create(Application);
    try
      VCSAddSharedModule.Top := Top + 60;
      VCSAddSharedModule.Left := Left + 60;
      VCSAddSharedModule.DefaultID := ServerProjectID;
      VCSAddSharedModule.ShowModal;
      for I := 0 to VCSAddSharedModule.SelectedModules.Count - 1 do
        SelectedModuleNames.Add(VCSAddSharedModule.SelectedModules.Strings[I]);
    finally
      VCSAddSharedModule.Free;
    end;
    for I := 0 to SelectedModuleNames.Count - 1 do
      AddModule(SelectedModuleNames.Strings[I]);
    DSAIdentsSetState(sBaseRegistryKey + crbMRU + 'Dlgs', 'IsSharedMod', True);
  finally
    SelectedModuleNames.Free;
  end;
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.popmAddModulesPopup(Sender: TObject);
var 
  I: Integer;
begin
  if OpenHistory.Count > 0 then 
  begin
    miLHSep.Visible := True;
    for I := 0 to 4 do 
    begin
      if OpenHistory.Count > I then 
      begin
        if I = 0 then 
        begin
          miLH1.Caption := CutPathStr(OpenHistory.Strings[0], 25);
          miLH1.Visible := True;
          miLH1.Enabled := True;
        end;
        if I = 1 then 
        begin
          miLH2.Caption := CutPathStr(OpenHistory.Strings[1], 25);
          miLH2.Visible := True;
          miLH2.Enabled := True;
        end;
        if I = 2 then 
        begin
          miLH3.Caption := CutPathStr(OpenHistory.Strings[2], 25);
          miLH3.Visible := True;
          miLH3.Enabled := True;
        end;
        if I = 3 then 
        begin
          miLH4.Caption := CutPathStr(OpenHistory.Strings[3], 25);
          miLH4.Visible := True;
          miLH4.Enabled := True;
        end;
        if I = 4 then
        begin
          miLH5.Caption := CutPathStr(OpenHistory.Strings[4], 25);
          miLH5.Visible := True;
          miLH5.Enabled := True;
        end;
      end; // if OpenHistory.Count >= I then begin
    end; // for I := 0 to 4 do begin
  end; // if OpenHistory.Count > 0 then begin
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.acAddModulesExecute(Sender: TObject);
begin
  AddModules(ExtractFilePath(sProjectName));
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.Projectfolder1Click(Sender: TObject);
begin
  AddModules(ExtractFilePath(sProjectName));
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.miLH1Click(Sender: TObject);
begin
  AddModules(OpenHistory.Strings[0]);
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.miLH2Click(Sender: TObject);
begin
  AddModules(OpenHistory.Strings[1]);
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.miLH3Click(Sender: TObject);
begin
  AddModules(OpenHistory.Strings[2]);
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.miLH4Click(Sender: TObject);
begin
  AddModules(OpenHistory.Strings[3]);
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.miLH5Click(Sender: TObject);
begin
  AddModules(OpenHistory.Strings[4]);
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.AddModules(const DlgInitialDir: string);
var
  CurrFile, CustomFilter, Filter1, Filter2: string;
  I: Integer;
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
      Title := JVCSRES_Add_new_modules;
      Options := [ofHideReadOnly, ofAllowMultiSelect, ofPathMustExist,
        ofFileMustExist, ofEnableSizing];
      if DirectoryExists(DlgInitialDir) then 
        InitialDir := DlgInitialDir
      else 
        InitialDir := ExtractFilePath(sProjectName);
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
        if FavOpenDialog.Files.Count > 0 then 
        begin
          if AnsiLowerCase(ExtractFilePath(sProjectName)) <>
            AnsiLowerCase(ExtractFilePath(FavOpenDialog.Files[0])) then 
          begin
            OpenHistory.AddString(ExtractFilePath(FavOpenDialog.Files[0]));
            OpenHistory.SaveToStorage(sBaseRegistryKey + crbMRU + '9');
          end; // if AnsiLowerCase(....
        end; // if OpenDialog1.Files.Count > 0 then begin
        // Add the files
        elvModules.Repaint;
        elvModules.AutoResort := False;
        try
          elvModules.BeginUpdate;
          try
            ShowStatusBarGauge(True, False);
            StatusBarGaugePos(0);
            for I := 0 to FavOpenDialog.Files.Count - 1 do
            begin
              AddModule(FavOpenDialog.Files[I]);
              StatusBarGaugePos(Round((I / FavOpenDialog.Files.Count) * 100));
            end;
            DSAIdentsSetState(sBaseRegistryKey + crbMRU + 'Dlgs', 'IsSharedMod', True);
          finally
            elvModules.EndUpdate;
          end;
        finally
          elvModules.AutoResort := True;
          // sorted later if necessary
        end;
        BringWindowToTop(WindowHandle);
        // -> LowerCase
        for I := 0 to FavOpenDialog.Files.Count - 1 do
          FavOpenDialog.Files[I] := AnsiLowerCase(FavOpenDialog.Files[I]);
        // select the files
        for I := 0 to elvModules.Items.Count - 1 do 
        begin
          CurrFile := elvModules.Items[I].SubItems[sitPath] +
            LowerCase(elvModules.Items[I].Caption);
          if (FavOpenDialog.Files.IndexOf(CurrFile) <> -1) and
            (elvModules.Items[I].SubItems[sitCount] = '0') then
            elvModules.Items[I].Selected := True
          else 
            elvModules.Items[I].Selected := False;
        end; // for I := 0 to elvModules.Items.Count - 1 do begin

        if (elvModules.SelCount > 0) then 
          acCheckInExecute(Self);
        if (elvModules.Items.Count > 0) then 
          elvModules.Resort;
        ShowStatusBarGauge(False, False);
        SetStatusBar;
      finally
        Screen.Cursor := crDefault;
      end;
    end; // if DlgResult then begin
  finally
    FavOpenDialog.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.acAddFoldersExecute(Sender: TObject);
var 
  DlgResult: Boolean;
  NewModules: TStringList;
  I: Integer;
  CurrFile: string;
begin
  NewModules := TStringList.Create;
  try
    VCSSelectFolder := TVCSSelectFolder.Create(Application);
    try
      VCSSelectFolder.SetDlgCaption(JVCSRES_Add_new_modules);
      VCSSelectFolder.SetStatusText(JVCSRES_38Add_new_modules_by_folder58);
      VCSSelectFolder.EnableRecursive(True);
      VCSSelectFolder.HelpContextID := IDH_Add_PM;
      VCSSelectFolder.EnableNewFolder(False);
      if ExtractFilePath(sProjectName) <> '' then
        VCSSelectFolder.SetInitialDir(ExtractFilePath(sProjectName));
      elvModules.BeginUpdate;
      try
        for I := 0 to elvModules.Items.Count - 1 do
          VCSSelectFolder.PJFiles.Add(elvModules.Items[I].SubItems[sitPath] +
            elvModules.Items[I].Caption);
      finally
        elvModules.EndUpdate;
      end;
      VCSSelectFolder.ShowModal;
      if VCSSelectFolder.Selection <> '' then
      begin
        DlgResult := True;
        for I := 0 to VCSSelectFolder.RecursiveList.Count - 1 do
          NewModules.Add(VCSSelectFolder.RecursiveList.Strings[I]);
      end // if VCSSelectFolder.Selection <> '' then begin
      else 
        DlgResult := False;
    finally
      VCSSelectFolder.Free;
    end;

    if DlgResult then 
    begin
      try
        Screen.Cursor := crHourGlass;
        elvModules.AutoResort := False;
        try
          // Add the files
          elvModules.Repaint;
          elvModules.BeginUpdate;
          try
            ShowStatusBarGauge(True, False);
            StatusBarGaugePos(0);
            for I := 0 to NewModules.Count - 1 do
            begin
              AddModule(NewModules.Strings[I]);
              StatusBarGaugePos(Round((I / NewModules.Count) * 100));
            end;
            DSAIdentsSetState(sBaseRegistryKey + crbMRU + 'Dlgs', 'IsSharedMod', True);
          finally
            elvModules.EndUpdate;
          end;
          // select the files
          for I := 0 to elvModules.Items.Count - 1 do
          begin
            CurrFile := elvModules.Items[I].SubItems[sitPath] +
              LowerCase(elvModules.Items[I].Caption);
            if (NewModules.IndexOf(CurrFile) <> -1) and
              (elvModules.Items[I].SubItems[sitCount] = '0') then
              elvModules.Items[I].Selected := True
            else
              elvModules.Items[I].Selected := False;
          end; // for I := 0 to elvModules.Items.Count - 1 do begin
        finally
          elvModules.AutoResort := True;
        end;

        if (elvModules.SelCount > 0) then 
          acCheckInExecute(Self);
        if (elvModules.Items.Count > 0) then 
          elvModules.Resort;
        ShowStatusBarGauge(False, False);
        SetStatusBar;
      finally
        Screen.Cursor := crDefault;
      end;
    end; // if DlgResult then begin
  finally
    NewModules.Free;
  end;
end;

//------------------------------------------------------------------------------

{$IFNDEF IDEDLL}
procedure TVCSProjAdmin.WMDROPFILES(var Message: TWMDROPFILES);
var
  NumFiles: Integer;
  I: Integer;
  Buffer: array [0..255] of Char;
  CurrFile: string;
  DroppedFiles: TStringList;
begin
  if (not bProjectOpen) or bStopRefresh then 
    Exit;
  // Accept the dropped files
  DroppedFiles := TStringList.Create;
  try
    NumFiles := DragQueryFile(Message.Drop, $FFFFFFFF, nil, 0);
    for I := 0 to (NumFiles - 1) do
    begin
      DragQueryFile(Message.Drop, I, @Buffer, SizeOf(Buffer));
      // only check files, no directories
      if not IsDirectory(Buffer) then
      begin
        DroppedFiles.Add(Buffer);
      end;
    end;
    // still any files to add?
    if DroppedFiles.Count>0 then
    begin
      if YesNoMessageBox(Format(JVCSRES_You_dropped_37d_files_onto_the_project_manager46, [DroppedFiles.Count])
        + #13#13 + JVCSRES_Would_you_like_to_add_them_to_the_current_project63) then
      begin
        Screen.Cursor := crHourGlass;
        try
          // Add the files
          elvModules.Repaint;
          elvModules.AutoResort := False;
          try
            elvModules.BeginUpdate;
            try
              ShowStatusBarGauge(True, False);
              StatusBarGaugePos(0);
              for I := 0 to DroppedFiles.Count - 1 do
              begin
                //thu - directories must not be accepted (for now...)
                if not (IsDirectory(DroppedFiles.Strings[I])) then
                begin
                  AddModule(DroppedFiles.Strings[I]);
                end;
                StatusBarGaugePos(Round((I / DroppedFiles.Count) * 100));
              end;
              DSAIdentsSetState(sBaseRegistryKey + crbMRU + 'Dlgs', 'IsSharedMod', True);
            finally
              elvModules.EndUpdate;
            end;
          finally
            elvModules.AutoResort := True;
            // sorted later if necessary
          end;
          // select the files
          for I := 0 to elvModules.Items.Count - 1 do
          begin
            CurrFile := elvModules.Items[I].SubItems[sitPath] +
              LowerCase(elvModules.Items[I].Caption);
            if (DroppedFiles.IndexOf(CurrFile) <> -1) and
              (elvModules.Items[I].SubItems[sitCount] = '0') then
              elvModules.Items[I].Selected := True
            else
              elvModules.Items[I].Selected := False;
          end; // for I := 0 to elvModules.Items.Count - 1 do begin

          if (elvModules.SelCount > 0) then
          begin
            acCheckInExecute(Self);
            BringWindowToTop(VCSProjAdmin.Handle);
          end;
          if (elvModules.Items.Count > 0) then
            elvModules.Resort;
          ShowStatusBarGauge(False, False);
          SetStatusBar;
        finally
          Screen.Cursor := crDefault;
        end;
      end;
    end;
  finally
    DroppedFiles.Free;
  end;
end;
{$ENDIF ~IDEDLL}

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.acRemvModulesExecute(Sender: TObject);
begin
  bStopRefresh := True;
  if elvModules.SelCount > 0 then
  begin
    VCSProgress := TVCSProgress.Create(Self);
    try
      VCSProgress.SetText('');
      VCSProgress.SetPBMax(elvModules.SelCount);
      VCSProgress.SetPBPos(0);
      VCSProgress.Left := Left + 20;
      VCSProgress.Top := Top + 20;
      VCSProgress.ShowAndRunAction(RemoveModules);
    finally
      VCSProgress.Free;
    end;
  end; // if ListBox1.SelCount > 0 then begin
  bStopRefresh := False;
end;

procedure TVCSProjAdmin.RemoveModules(Sender: TObject);
var
  ModuleToDelete, Mess: string;
  I, Yes2allRes, SelCount, ProcessedCount: Integer;
  RemoveRevision, Yes2all: Boolean;
  WasSelectedRow: Boolean;
label
  NextEntry;
begin
  Yes2all := False;
  RemoveRevision := False;

  I := 0;
  ProcessedCount := 0;
  SelCount := elvModules.SelCount;
  elvModules.AutoResort := False;
  try
    elvModules.BeginUpdate;
    try
      repeat // until I >= elvModules.Items.Count;
      {  keine for - to Schleife, sonst wird nach
         löschen über die Liste hinausgelesen  }
        Inc(I); // Start mit 1, da bei gelöschtem Eintrag
        // in der gl. Zeile weitergesucht wird
        WasSelectedRow := elvModules.Items[I - 1].Selected;
        if elvModules.Items[I - 1].Selected then
        begin
          ModuleToDelete := LowerCase(elvModules.Items[I - 1].Caption);
          if Sender is TVCSProgress then
          begin
            Inc(ProcessedCount);
            TVCSProgress(Sender).SetText(Format(JVCSRES_Remove_Module_37d4737d_45_37s,
              [ProcessedCount, SelCount, ModuleToDelete]));
            TVCSProgress(Sender).BringToFront;
          end;
          Mess := ModuleToDelete;
          ModuleToDelete := elvModules.Items[I - 1].SubItems[sitPath] +
            ModuleToDelete;

          if not Yes2all then
          begin
            // Yes 2 All dialog
            VCSYes2AllDlg := TVCSYes2AllDlg.Create(Application);
            try
              if (elvModules.SelCount > 1) then
                VCSYes2AllDlg.EnableYes2All(True)
              else
                VCSYes2AllDlg.EnableYes2All(False);
              VCSYes2AllDlg.ShowCheckBox(True);
              VCSYes2AllDlg.SetCheckBoxCaption(JVCSRES_38Remove_all_revisions_from_the_archive46);
              VCSYes2AllDlg.SetMessageText(Format(JVCSRES_37d_modules_selected46,
                [elvModules.SelCount]) + #13#10 +
                Format(JVCSRES_Are_you_sure_you_want_to_remove_6037s62_37s_from_ +
                #13#10 + '<%s>?', [Mess, '', 
                Format(JVCSRES_VC_project58_37s, [ExtractFileName(sProjectName)])]));
              Yes2allRes := VCSYes2AllDlg.ShowModal;
              RemoveRevision := VCSYes2AllDlg.CheckBoxChecked;
            finally
              VCSYes2AllDlg.Free;
            end;
            case Yes2allRes of
              mrYes :;
              mrAll:
                Yes2all := True;
              mrNo:
                goto NextEntry;
              mrCancel: 
                begin
                  bStopRefresh := False;
                  Exit;
                end;
            end; // case Yes2allRes of
            if RemoveRevision then 
            begin
              if MessageBox(WindowHandle, PChar(JVCSRES_Are_you_sure_you_want_to_remove_all_revisions_from_the_archive63
                + #13#10 + JVCSRES_Warning33_This_process_is_not_reversible46),
                cMsgBoxCaption, MB_YESNOCANCEL or MB_DEFBUTTON2 or MB_ICONWARNING) <> id_Yes then
              begin
                bStopRefresh := False;
                Exit;
              end;
            end; // if RemoveRevision then begin
          end; // if not Yes2all then begin

          with DataModule1 do
          begin
            AppSrvClient1.Request.Rewrite;
            AppSrvClient1.FunctionCode := 'REMOVE_MODULE';
            AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
            AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
            AppSrvClient1.Request.WriteFields(True, [ServerProjectID]);
            AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
            AppSrvClient1.Request.WriteFields(False,
              [elvModules.Items[I - 1].SubItems[sitMID]]);
            AppSrvClient1.Request.WriteFields(False, [RemoveRevision]);
            AppSrvClient1.Request.WriteFields(False, [ModuleToDelete]);
            SetupTimeoutCounter;
            AppSrvClient1.Send;

            while WaitForAppSrvClient do 
              Application.ProcessMessages;
            if (AppSrvClientErr = -99) then 
            begin
              ShowServerTimeOut(WindowHandle);
              bStopRefresh := False;
              Exit;
            end;
            if (AppSrvClientErr <> 0) or
              (AppSrvClient1.AnswerStatus <> '200') then 
            begin
              ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
                AppSrvClient1.AnswerStatus);
              bStopRefresh := False;
              Exit;
            end;

            AppSrvClient1.Answer.First;
            if RemoveRevision and
              (not DecodeBoolStr(AppSrvClient1.Answer.Fields[0])) then 
            begin
              UseRegistry := True;
              DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
              DSAIdentsMessageDlg(JVCSRES_This_module_is_already_used_by_other_projects_in_the_archive46 + #13#10 +
                JVCSRES_Shared_link_removed46
                , mtInformation
                , [mbOK]
                , 0
                , sBaseRegistryKey + crbMRU + 'Dlgs'
                , 'SharedRemove'
                , idOk
                );
            end;
          end; // with DataModule1 do begin

          uilPluginManager1.SendMessage(pimsgFVCSProjectModulesRemove,
            LowerCase(ModuleToDelete));
          elvModules.Items.Delete(I - 1);
          // Message Window
          AddMessage(Format(JVCSRES_Removed_from_project58_37s_45_Success, [ModuleToDelete]),
            msclNormal);
          Dec(I); // gelöscht => eine Zeile zurück
        end; // if ListBox1.Selected[I] then begin
        NextEntry :
        if (Sender is TVCSProgress) and (WasSelectedRow) then
        begin
          TVCSProgress(Sender).SetPBPos(ProcessedCount);
          TVCSProgress(Sender).BringToFront;
        end;
      until I >= elvModules.Items.Count;
    finally
      elvModules.EndUpdate;
    end;
  finally
    elvModules.AutoResort := True;
    elvModules.Resort;
  end;
  SetStatusBar;
  GetArchiveTimeStamp(ArchTStamp);
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.LoadAll1Click(Sender: TObject);
begin
  if MessageBox(WindowHandle, PChar(JVCSRES_Are_you_sure_you_want_to_load_all_source_files_into_the_IDE63 + #13#10 +
    JVCSRES_This_may_consume_a_lot_of_system_resources_on_big_projects46),
    cMsgBoxCaption, MB_YESNOCANCEL or MB_ICONQUESTION) <> idYes then 
    Exit;
  LoadAllModules;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.LoadAllModules;
{$IFDEF IDEDLL}
var
  I: Integer;
  Ext, CurrentModule: string;
{$ENDIF IDEDLL}
begin
  {$IFDEF IDEDLL}
  with elvModules do
  begin
    for I := 0 to Items.Count - 1 do 
    begin
      Ext := AnsiLowerCase(ExtractFileExt(Items[I].Caption));
      if FileExists(Items[I].SubItems[sitPath] + Items[I].Caption) and
        (MatchWithFilter(Ext,
        jvcsReadString(sBaseRegistryKey + crbFilters, 'IDE files', dfIDEEdit))) then
      begin
        CurrentModule := Items[I].SubItems[sitPath] + Items[I].Caption;
        if IDEInterface.OpenFile(GetOriginalFileName(CurrentModule)) then
          // Message Window
          AddMessage(Format(JVCSRES_Load_module58_37s_45_Success, [CurrentModule]), msclNormal)
        else
          // Message Window
          AddMessage(Format(JVCSRES_Load_module58_37s_45_Failed, [CurrentModule]), msclError);
      end; // if FileExists(Items[I].SubItems[sitPath] + Items[I].Caption) and...
    end; // for I := 0 to elvModules.Items.Count - 1 do begin
  end; // with elvModules do begin
  {$ENDIF IDEDLL}
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.acLoadModulesExecute(Sender: TObject);
var 
  I: Integer;
  Mess, CurrentFile: string;
begin
  if elvModules.SelCount > 0 then 
  begin
    // Multiselect, alle Dateinamen lesen
    for I := 0 to elvModules.Items.Count - 1 do
      if elvModules.Items[I].Selected then
      begin
        CurrentFile := elvModules.Items[I].Caption;
        if ViewTheModule(WindowHandle,
          elvModules.Items[I].SubItems[sitPath] + CurrentFile, Mess) then
          AddMessage(Mess, msclNormal);
      end;
  end; // if elvModules.SelCount > 0 then begin
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.UnloadAll1Click(Sender: TObject);
begin
  if MessageBox(WindowHandle,
    PChar(JVCSRES_Are_you_sure_you_want_to_unload_all_source_files_40except_of_the_project41_from_the_IDE63),
    cMsgBoxCaption, MB_YESNOCANCEL or MB_ICONQUESTION) <> idYes then 
    Exit;
  UnLoadAllModules;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.UnLoadAllModules;
{$IFDEF IDEDLL}
var
  I: Integer;
  Ext, CurrentModule: string;
{$ENDIF IDEDLL}
begin
  {$IFDEF IDEDLL}
  with elvModules do 
  begin
    for I := 0 to Items.Count - 1 do 
    begin
      Ext := AnsiLowerCase(ExtractFileExt(Items[I].Caption));
      if FileExists(Items[I].SubItems[sitPath] + Items[I].Caption) and
        (MatchWithFilter(Ext,
        jvcsReadString(sBaseRegistryKey + crbFilters, 'IDE files', dfIDEEdit))) then
      begin
        CurrentModule := Items[I].SubItems[sitPath] + Items[I].Caption;
        if IDEInterface.IsFileOpen(CurrentModule) then
          IDEInterface.CloseFile(CurrentModule);
      end; // if FileExists(Items[I].SubItems[sitPath] + Items[I].Caption) and...
    end; // for I := 0 to elvModules.Items.Count - 1 do begin
  end; // with elvModules do begin
  {$ENDIF IDEDLL}
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiUsedComponentsClick(Sender: TObject);
begin
  {$IFDEF IDEDLL}
  bStopRefresh := True;
  VCSUsedComponents := TVCSUsedComponents.Create(Application);
  try
    VCSUsedComponents.ShowModal;
  finally
    VCSUsedComponents.Free;
  end;
  bStopRefresh := False;
  {$ENDIF IDEDLL}
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  {$IFDEF IDEDLL}
  if Key = VK_ESCAPE then
  begin
    acFormCloseExecute(Self);
    Key := 0;
  end;
  {$ELSE}
  if Key = VK_ESCAPE then
    FPressedESC := True;
  {$ENDIF IDEDLL}
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.HelpTopics1Click(Sender: TObject);
var
  HelpFileName: string;
begin
  HelpFileName := sDLLDirectory + cJVCSHelpFile;
  ShellExecute(Application.Handle, 'open', PChar(HelpFileName),
    '', PChar(sDLLDirectory), sw_ShowNormal);
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.acCtxHelpExecute(Sender: TObject);
begin
  PerformHelpCommand(Application, IDH_Project_Administration);
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.acFormCloseExecute(Sender: TObject);
begin
  {$IFNDEF IDEDLL}
  UseRegistry := True;
  DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
  if DSAIdentsMessageDlg(Format(JVCSRES_Log_out_user_6037s62_and_terminate_program63,
    [sCurrentUser])
    , mtConfirmation
    , [mbYes, mbNo, mbCancel]
    , 0
    , sBaseRegistryKey + crbMRU + 'Dlgs'
    , 'TerminateProg'
    , idYes
    ) <> idYes then 
    Exit;
  {$ENDIF ~IDEDLL}
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  {$IFDEF DEBUG}
  JclDebug.TraceMsg('PM: FormClose');
  {$ENDIF DEBUG}
  SaveFormSize;
  {$IFDEF IDEDLL}
  VCSProjAdmin.Hide;
  {$ELSE}
  if mmiDisconnectserver.Enabled then
  begin
    DoSaveWIPonclose;
    mmiDisconnectserverClick(Self);
  end;
  if bProjectOpen then
    mmiCloseProjectClick(Self);
  {$ENDIF IDEDLL}
  {$IFDEF REPORTDLL}
{  try
    if ReportDLLHandle > 0 then
      FreeLibrary(ReportDLLHandle);
  except
  end;}
  {$ENDIF REPORTDLL}
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiTBModuleClick(Sender: TObject);
begin
  mmiTBModule.Checked := not mmiTBModule.Checked;
  if mmiTBModule.Checked then
    TBModule.Visible := True
  else 
    TBModule.Visible := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiTBToolsClick(Sender: TObject);
begin
  mmiTBTools.Checked := not mmiTBTools.Checked;
  if mmiTBTools.Checked then
    TBTool.Visible := True
  else 
    TBTool.Visible := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiTBWindowClick(Sender: TObject);
begin
  mmiTBWindow.Checked := not mmiTBWindow.Checked;
  if mmiTBWindow.Checked then
    TBWindow.Visible := True
  else
    TBWindow.Visible := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.SaveFormSize;
var
  ColChanged, TBChanged, SizeChanged: Boolean;
  I: Integer;
  S: string;
begin
  {$IFDEF DEBUG}
  JclDebug.TraceMsg('PM: Check - Save Window changes');
  {$ENDIF DEBUG}
  jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjMan_MsgWinHeight',
    Panel1.Height);

  //USc 15.09.2003 - check if the dockable forms are created before writing the
  //last active tabsheet because the IDE Version calls SaveFormSize in the OnPaint
  //event and thatswhy it overrides the last active page before the last active
  //page is set
  if FReadedDockForms then
  begin
    if Assigned(pgStatus.ActivePage) then
    begin
      if not pgStatus.ActivePage.TabVisible then
        S := ''
      else
      if pgStatus.ActivePage = tsMessages then
        S := tsMessages.Name
      else
      if IsDockClientActivePage(pgStatus, JVCSDockToDoWindow) then
        S := JVCSDockToDoWindow.Name
      else
      if IsDockClientActivePage(pgStatus, VCSBugWindow) then
        S := VCSBugWindow.Name
      else
      if IsDockClientActivePage(pgStatus, VCSModuleHistoryWindow) then
        S := VCSModuleHistoryWindow.Name
      else
      if IsDockClientActivePage(pgStatus, JVCSDockLockedModulesWindow) then
        S := JVCSDockLockedModulesWindow.Name;
    end
    else
      S := '';
    jvcsWriteString(sBaseRegistryKey + crbWindows, 'ProjMan_MsgWinActivePage', S);
  end;

  ColChanged := False;
  with elvModules do
  begin
    for I := 0 to 12 do
    begin
      if ColWidth.Col[I] <> Columns[I].Width then
      begin
        ColChanged := True;
        Break;
      end;
    end;
    if ColChanged then
    begin
      ColWidth.Col[colName] := Columns[colName].Width;
      ColWidth.Col[colType] := Columns[colType].Width;
      ColWidth.Col[colPath] := Columns[colPath].Width;
      ColWidth.Col[colVer] := Columns[colVer].Width;
      ColWidth.Col[colState] := Columns[colState].Width;
      ColWidth.Col[colOwner] := Columns[colOwner].Width;
      ColWidth.Col[colCount] := Columns[colCount].Width;
      ColWidth.Col[colKeyWord] := Columns[colKeyWord].Width;
      ColWidth.Col[colShare] := Columns[colShare].Width;
      ColWidth.Col[colSize] := Columns[colSize].Width;
      ColWidth.Col[colDate] := Columns[colDate].Width;
      ColWidth.Col[colAttr] := Columns[colAttr].Width;
      ColWidth.Col[colMID] := Columns[colMID].Width;
    end; // if ColChanged then begin
  end; // with elvModules do begin

  // Position
  SizeChanged := False;
  if (FormSize.Top <> Top) or (FormSize.Left <> Left) or
    (FormSize.Width <> Width) or (FormSize.Height <> Height) then
  begin
    SizeChanged := True;
    FormSize.Top := Top;
    FormSize.Left := Left;
    FormSize.Width := Width;
    FormSize.Height := Height;
  end; // if (FormSize.Top <> Top)

  TBChanged := False;
  with TBPos do
  begin
    if (MenuBar1.Top <> MBTop) or (MenuBar1.Left <> MBLeft) or
      (TBWindow.Top <> TBWindowTop) or (TBWindow.Left <> TBWindowLeft) or
      (TBModule.Top <> TBModuleTop) or (TBModule.Left <> TBModuleLeft) or
      (TBTool.Top <> TBToolTop) or (TBTool.Left <> TBToolLeft) or
      (TBModule.Visible <> TBModuleVis) or (TBWindow.Visible <> TBWindowVis) or
      (TBTool.Visible <> TBToolVis) then
    begin
      TBChanged := True;
      MBTop := MenuBar1.Top;
      MBLeft := MenuBar1.Left;
      TBModuleVis := TBModule.Visible;
      TBWindowVis := TBWindow.Visible;
      TBToolVis := TBTool.Visible;
      TBToolTop := TBTool.Top;
      TBToolLeft := TBTool.Left;
      TBWindowTop := TBWindow.Top;
      TBWindowLeft := TBWindow.Left;
      TBModuleTop := TBModule.Top;
      TBModuleLeft := TBModule.Left;
    end; // if (MenuBar1.Top <> MBTop)...
  end;

  if not (tvHierachyPlaceholder.Width = ProjectFolderWidth) then
  begin
    {$IFDEF DEBUG}
    JclDebug.TraceMsg('PM: Save tvHierachy.Width');
    {$ENDIF DEBUG}
    ProjectFolderWidth := tvHierachyPlaceholder.Width;
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjMan_TreeWidth',
      ProjectFolderWidth);
  end;

  if SizeChanged or ColChanged or TBChanged then
  begin
    if ColChanged then
    begin
      {$IFDEF DEBUG}
      JclDebug.TraceMsg('PM: Save Columns.Width');
      {$ENDIF DEBUG}
      with ColWidth do
      begin
        jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Col1.0',
          Col[colName]);
        jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Col1.1',
          Col[colType]);
        jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Col1.2',
          Col[colPath]);
        jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Col1.3',
          Col[colVer]);
        jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Col1.4',
          Col[colState]);
        jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Col1.5',
          Col[colOwner]);
        jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Col1.6',
          Col[colCount]);
        jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Col1.7',
          Col[colKeyWord]);
        jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Col1.8',
          Col[colShare]);
        jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Col1.9',
          Col[colSize]);
        jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Col1.10',
          Col[colDate]);
        jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Col1.11',
          Col[colAttr]);
        jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Col1.12',
          Col[colMID]);
      end;
    end; // if ColChanged then begin
    if TBChanged then
    begin
      {$IFDEF DEBUG}
      JclDebug.TraceMsg('PM: Save Toolbar positions');
      {$ENDIF DEBUG}
      with TBPos do
      begin
        jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Tb1.0',
          MBTop);
        jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Tb1.1',
          MBLeft);
        jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Tb1.2',
          TBToolTop);
        jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Tb1.3',
          TBToolLeft);
        jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Tb1.4',
          TBModuleTop);
        jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Tb1.5',
          TBModuleLeft);
        jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Tb1.6',
          TBWindowTop);
        jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjMan_Tb1.7',
          TBWindowLeft);
        jvcsWriteBool(sBaseRegistryKey + crbWindows, 'ProjMan_Tb1.8',
          TBModuleVis);
        jvcsWriteBool(sBaseRegistryKey + crbWindows, 'ProjMan_Tb1.9',
          TBWindowVis);
        jvcsWriteBool(sBaseRegistryKey + crbWindows, 'ProjMan_Tb1.10',
          TBToolVis);
      end;
    end; // if TBChanged then begin
    if SizeChanged then
    begin
      {$IFDEF DEBUG}
      JclDebug.TraceMsg('PM: Save Form size');
      {$ENDIF DEBUG}
      jvcsWriteBool(sBaseRegistryKey + crbWindows, 'ProjMan_Maximized',
        (WindowState = wsMaximized));
      jvcsWriteWindowPosAndSize(sBaseRegistryKey + crbWindows, 'ProjMan',
        FormSize.Top, FormSize.Left, FormSize.Width, FormSize.Height);
    end; // if SizeChanged then begin
  end;
  if SizeChanged or ColChanged or TBChanged then
    if not jvcsUpdateStorageObject then
      WarnMessageBox(JVCSRES_Storage_Object_update_failed33);
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.FormDestroy(Sender: TObject);
begin
  {$IFDEF DEBUG}
  JclDebug.TraceMsg('PM: FormDestroy');
  {$ENDIF DEBUG}
  FreeAndNil(FCurrentModuleFileNames);
  FreeAndNil(FLineHistoryProvider);
  FreeAndNil(FLineHistorySettings);
  FreeAndNil(FLabelList);
  FreeAndNil(FProjectLabelList);
  //USc 15.09.2003 destroying of the dockable forms should be done before closing
  //the storage object because the forms write there settings in formdestroy
  {$IFNDEF IDEDLL}
  RefreshDispatcher.RemoveClient(JVCSDockProjectTree);
  FreeAndNil(JVCSDockProjectTree);
  {$ENDIF ~IDEDLL}
  RefreshDispatcher.RemoveClient(JVCSDockToDoWindow);
  FreeAndNil(JVCSDockToDoWindow);
  RefreshDispatcher.RemoveClient(VCSBugWindow);
  FreeAndNil(VCSBugWindow);
  RefreshDispatcher.RemoveClient(VCSModuleHistoryWindow);
  FreeAndNil(VCSModuleHistoryWindow);
  RefreshDispatcher.RemoveClient(JVCSDockLockedModulesWindow);
  FreeAndNil(JVCSDockLockedModulesWindow);
  {$IFNDEF  DELPHI7_UP}
  FreeAndNil(FThemeManager);
  {$ENDIF ~DELPHI7_UP}

  {$IFNDEF IDEDLL}
  if Assigned(FIcon) then
    FIcon.Free;
  jvcsCloseStorageObject;
  {$ENDIF ~IDEDLL}
  mdSecureMail1.Close;
  DelphiModules.Free;
  ProjectFolders.Free;
  SharedModuleIDs.Free;
  ModuleBugs.Free;
  OpenHistory.Free;

  {$IFNDEF IDEDLL}
  RefreshDispatcher.RemoveClient(FRefreshProjects);
  FreeAndNil(FRefreshProjects);
  {$ENDIF ~IDEDLL}

  DeleteCriticalSection(FSelectedModuleLock);
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.acLabelManagerExecute(Sender: TObject);
var
  Changed: Boolean;
begin
  bStopRefresh := True;
  VCSMaintainLabels := TVCSMaintainLabels.Create(Application);
  try
    VCSMaintainLabels.Left := Left + 60;
    VCSMaintainLabels.Top := Top + 60;
    VCSMaintainLabels.ShowModal;
    Changed := VCSMaintainLabels.LabelsChanged;
  finally
    VCSMaintainLabels.Free;
  end;
  if Changed then 
    GetLabels;
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.SetMenuMode;
var 
  I, J: Integer;
  C: TObject;
const
  {$IFDEF IDEDLL}
  ExpMin = 10000;
  ExpMax = 10999;
  {$ELSE}
  ExpMin = 11000;
  ExpMax = 11999;
  {$ENDIF IDEDLL}
begin
  {  Normal = 9000 - 9999
     IDE Exp = 10000 - 10999
     Std Exp = 11000 - 11999
     Beide Exp = 12000 - 12999  }
  Screen.Cursor := crHourGlass;
  with Application do
    for I := 0 to ComponentCount - 1 do 
    begin
      for J := 0 to Components[I].ComponentCount - 1 do 
      begin
        C := Components[I].Components[J];
        if (C is TMenuItem) and
          (((C as TMenuItem).Tag >= 12000) and ((C as TMenuItem).Tag < 12999) or
          ((C as TMenuItem).Tag >= ExpMin) and ((C as TMenuItem).Tag < ExpMax)) then
          (C as TMenuItem).Visible := ExpertMenu1.Checked;
        if (C is TToolButton) and
          (((C as TToolButton).Tag >= 12000) and ((C as TToolButton).Tag < 12999) or
          ((C as TToolButton).Tag >= ExpMin) and ((C as TToolButton).Tag < ExpMax)) then
          (C as TToolButton).Visible := ExpertMenu1.Checked;
      end; // for J := 0 to Components[I].ComponentCount-1 do begin
    end; // for I := 0 to ComponentCount-1 do begin
  Screen.Cursor := crDefault;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.elvModulesClick(Sender: TObject);
begin
  edSearch.Text := '';
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.elvModulesChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
begin
  if bLVReady then
  begin
    SetMenuState;
    dfsStatusBar.Panels[0].Text := Format(JVCSRES_Selected58_37d, [elvModules.SelCount]);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.SetMenuState;
begin
  {$IFDEF DEBUG}
  JclDebug.TraceMsg('PM: SetMenuState');
  {$ENDIF DEBUG}
  // > 1 selected
  acLoadModules.Enabled := (elvModules.SelCount > 0);
  acRemvModules.Enabled := acLoadModules.Enabled;
  acCheckIn.Enabled := acLoadModules.Enabled;
  acCheckOut.Enabled := acLoadModules.Enabled;
  acUndoChkOut.Enabled := acLoadModules.Enabled;
  acAddtoCustFilt.Enabled := acLoadModules.Enabled;
  // 1 selected
  if (elvModules.SelCount = 1) then
    uilPluginManager1.SendMessage(pimsgFVCSProjectSelectedModule,
      elvModules.Selected.SubItems[sitPath] + elvModules.Selected.Caption)
  else
    uilPluginManager1.SendMessage(pimsgFVCSProjectSelectedModule, '');
  acModInfo.Enabled := (elvModules.SelCount = 1);
  acViewArchiveVersion.Enabled := acModInfo.Enabled;
  acGetRevision.Enabled := acModInfo.Enabled;
  acCompare.Enabled := acModInfo.Enabled;
  acCompareAllLocalArchive.Enabled := elvModules.SelCount > 0;
  acHistory.Enabled := acModInfo.Enabled;
  acLineHistory.Enabled := acModInfo.Enabled;
  acShowSharedBy.Enabled := acModInfo.Enabled;
  acHideModule.Enabled := acModInfo.Enabled;
  acKeyAdmin.Enabled := acModInfo.Enabled;
  acRenameModule.Enabled := acModInfo.Enabled;
  acModuleBugs.Enabled := acModInfo.Enabled;
  acDescription.Enabled := acModInfo.Enabled;
  acHideModule.Enabled := acModInfo.Enabled;
  Latestarchiveversion1.Enabled := acModInfo.Enabled;
  acOpenParentFolder.Enabled := acModInfo.Enabled;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.SetMenuStateEx;
var
  ServerConnected, ProjectOpened: Boolean;
begin
  {$IFDEF DEBUG}
  JclDebug.TraceMsg('PM: SetMenuStateEx');
  {$ENDIF DEBUG}
  ServerConnected := (ServerUserID > 0);
  ProjectOpened := ServerConnected and bProjectOpen and (ServerProjectID > 0);

  Project1.Enabled := ServerConnected;
  Showprojecttree1.Enabled := ServerConnected;
  History1.Enabled := ServerConnected;
  ProjectHierarchy1.Enabled := ServerConnected;
  mmiLabelHistory.Enabled := ServerConnected;
  RenameProject1.Enabled := ServerConnected;
  RemoveProjects1.Enabled := ServerConnected;
  PurgeProjects1.Enabled := ServerConnected;
  acFileFamilies.Enabled := ServerConnected;
  MoveModules1.Enabled := ServerConnected;
  acLabelManager.Enabled := ServerConnected;
  PrintReports1.Enabled := ServerConnected;
  mmiToDolist.Enabled := ServerConnected;
  Administration1.Enabled := ServerConnected;
  CountSpace1.Enabled := ServerConnected;
  mmiSearchmodules.Enabled := ServerConnected;
  Showdesertedmodules1.Enabled := ServerConnected;
  Deletedprojects1.Enabled := ServerConnected;
  acSynchronize.Enabled := ServerConnected;
  mmiMSManager.Enabled := ServerConnected;
  acWhoami.Enabled := ServerConnected;
  mmiBranch.Enabled := ServerConnected;
  Changeserverpassword1.Enabled := ServerConnected;
  LockedModules1.Enabled := ServerConnected;
  acBugManager.Enabled := ServerConnected;
  DirectSQL1.Enabled := ServerConnected;
  acShowToDoWin.Enabled := ServerConnected;
  acShowBugWin.Enabled := ServerConnected;
  acShowModuleHistoryWin.Enabled := ServerConnected;
  acLockedModuleWin.Enabled := ServerConnected;
  acRefreshForm.Enabled := ServerConnected;

  if bProjectOpen then
  begin
    acSynchronize.Caption := JVCSRES_38Synchronize47_Restore464646;
    acSynchronize.Hint := JVCSRES_Synchronize47_Restore;
  end
  else
  begin
    acSynchronize.Caption := JVCSRES_38Create_from_DB464646;
    acSynchronize.Hint := JVCSRES_Create_from_DB;
  end;

  mmiMerge.Enabled := ProjectOpened;
  acBackupRestore.Enabled := ProjectOpened;
  CheckforBuildOK1.Enabled := ProjectOpened;
  Definemilestones1.Enabled := ProjectOpened;
  mmiProjectDescription.Enabled := ProjectOpened;
  acAddModules.Enabled := ProjectOpened;
  acAddFolders.Enabled := ProjectOpened;
  acAddShared.Enabled := ProjectOpened;
  mmiCrossRefList.Enabled := ProjectOpened;
  mmiBranch.Enabled := ProjectOpened;
  Custom2.Enabled := ProjectOpened;
  Timelog1.Enabled := ProjectOpened;
//  mmiProjectBugTracking.Enabled := ProjectOpened;
  acProjectBug.Enabled := ProjectOpened;
  DistributionArchive1.Enabled := ProjectOpened;
  mmiChangedDifferent.Enabled := ProjectOpened;
  mmiModuleListReportSel.Enabled := ProjectOpened;
  UserCurrentProject1.Enabled := ProjectOpened;
  AllUsersCurrentProject1.Enabled := ProjectOpened;
  mmiUsedUnits.Enabled := ProjectOpened;
  mmiProjectdependencies.Enabled := ProjectOpened;
  {$IFDEF IDEDLL}
  mmiSettings.Enabled := ProjectOpened;
  mmiUsedComponents.Enabled := ProjectOpened;
  LoadallIDEmodules1.Enabled := ProjectOpened;
  UnloadallIDEmodules1.Enabled := ProjectOpened;
  acProjectTree.Enabled := False;
  {$ELSE}
  mmiDisconnectserver.Enabled := ServerConnected;
  mmiConnectserver.Enabled := not mmiDisconnectserver.Enabled;
  mmiNewProject.Enabled := ServerConnected;
  mmiOpenProject.Enabled := ServerConnected;
  mmiOpenRecentProject.Enabled := ServerConnected;
  mmiFavorites.Enabled := ServerConnected;
  mmiCloseProject.Enabled := ProjectOpened;
  acProjectTree.Enabled := ServerConnected;
  {$ENDIF IDEDLL}
  {$IFDEF BRANCHING}
  mmiNewBranch.Enabled := nServerVersion >= 250;
  mmiOpenBranch.Enabled := nServerVersion >= 250;
  mmiRemoveBranch.Enabled := nServerVersion >= 250;
  {$ENDIF BRANCHING}
  mmiVCSBrowser.Enabled := nServerVersion >= 250;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.SetCaption;
var
  CaptionStr: string;
begin
  // 1. Application
  CaptionStr := JVCSRES_JEDI_VCS_ + '('+GetJVCSAppFileVersion + ')';
  if sIdentityCaption <> '' then
    CaptionStr := CaptionStr + ' >> ' + sIdentityCaption;
  // 2. Branch
  {$IFDEF BRANCHING}
  if (nServerVersion >= 250) and (sBranchName <> '') then
    CaptionStr := CaptionStr + Format(' >> [Branch: %s]', [sBranchName]);
  {$ENDIF BRANCHING}
  // 3. Project
  if sProjectName <> '' then
    CaptionStr := CaptionStr + ' >> ' + ExtractFileName(sProjectName);
  Caption := CaptionStr;

  {$IFNDEF IDEDLL}
  Application.Title := Caption;
  {$ENDIF ~IDEDLL}
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.edSearchClick(Sender: TObject);
begin
  edSearch.SelStart := 0;
  edSearch.SelLength := Length(edSearch.Text);
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.edSearchKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (ssAlt in Shift) or (ssCtrl in Shift) then 
    Exit;
  if (Key = VK_DOWN) then
    elvModules.SetFocus;
  if not ((Key = VK_BACK) or
    (Key = VK_DELETE) or
    (Chr(Key) in ['a'..'z', 'A'..'Z', '.', '-', '_'])) then 
    Exit;
  SearchTimer.Enabled := True;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.SearchTimerTimer(Sender: TObject);
var 
  SearchLVItem: TListItem;
  I: Integer;
begin
  SearchTimer.Enabled := False;

  if (elvModules.Items.Count = 0) then 
    Exit;
  with elvModules do 
  begin
    elvModules.Selected := nil;
    for I := 0 to Items.Count - 1 do
      Items[I].Focused := False;
    if edSearch.Text = '' then 
    begin
      Selected := Items[0];
      Items[0].Focused := True;
      ShowSelectedLVItem;
      Exit;
    end;
    SearchLVItem :=
      FindCaption(0, AnsiLowerCase(edSearch.Text), True, True, False);
    if SearchLVItem <> nil then
    begin
      // Message Window
      AddMessage(Format(JVCSRES_Search_for_3437s34_45_Success, [edSearch.Text]), msclNormal);
      Selected := SearchLVItem;
      SearchLVItem.Focused := True;
      ShowSelectedLVItem;
    end
    else
    begin
      // Message Window
      AddMessage(Format(JVCSRES_Search_for_3437s34_45_not_found, [edSearch.Text]), msclNormal);
    end;
  end; // with elvModules do begin
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.acShowSharedByExecute(Sender: TObject);
var 
  ResultString: string;
begin
  if not ArchivedModuleSelected then 
    Exit;
  bStopRefresh := True;
  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_SHARED_BY';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True,
      [elvModules.Selected.SubItems[sitMID]]);
    SetupTimeoutCounter;
    AppSrvClient1.Send;

    while WaitForAppSrvClient do
      Application.ProcessMessages;
    if (AppSrvClientErr = -99) then 
    begin
      ShowServerTimeOut(WindowHandle);
      bStopRefresh := False;
      Exit;
    end;
    if (AppSrvClientErr <> 0) or
      (AppSrvClient1.AnswerStatus <> '200') then 
    begin
      ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
        AppSrvClient1.AnswerStatus);
      bStopRefresh := False;
      Exit;
    end;

    AppSrvClient1.Answer.First;
    ResultString := '';
    while not AppSrvClient1.Answer.Eof do 
    begin
      ResultString := ResultString + AppSrvClient1.Answer.Fields[1] + ';' +
        AppSrvClient1.Answer.Fields[0] + ';|';
      AppSrvClient1.Answer.Next;
    end;
  end; // with DataModule1 do begin
  VCSStdListView := TVCSStdListView.Create(Application);
  try
    VCSStdListView.LVRepID := 10;
    VCSStdListView.Caption := elvModules.Selected.Caption;
    VCSStdListView.Left := Left + 60;
    VCSStdListView.Top := Top + 60;
    VCSStdListView.LVType := 0;
    VCSStdListView.HelpContextID :=
      IDH_Sharing_modules_between_different_projects;
    VCSStdListView.AddListColumn(JVCSRES_Shared_by_project__, False);
    VCSStdListView.AddListColumn(JVCSRES_Project_ID, True);
    VCSStdListView.SetUpItems(ResultString);
    VCSStdListView.ShowModal;
  finally
    VCSStdListView.Free;
  end;
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.acHideModuleExecute(Sender: TObject);
var 
  Hide: Boolean;
begin
  if not ArchivedModuleSelected then 
    Exit;
  bStopRefresh := True;
  if elvModules.Selected.StateIndex = 3 then
    Hide := False
  else
    Hide := True;
  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'HIDE_UNHIDE_MODULE';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [ServerProjectID]);
    AppSrvClient1.Request.WriteFields(False,
      [elvModules.Selected.SubItems[sitMID]]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(False, [Hide]); // hide
    SetupTimeoutCounter;
    AppSrvClient1.Send;

    while WaitForAppSrvClient do 
      Application.ProcessMessages;
    if (AppSrvClientErr = -99) then 
    begin
      ShowServerTimeOut(WindowHandle);
      bStopRefresh := False;
      Exit;
    end;
    if (AppSrvClientErr <> 0) or
      (AppSrvClient1.AnswerStatus <> '200') then 
    begin
      ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
        AppSrvClient1.AnswerStatus);
      bStopRefresh := False;
      Exit;
    end;

    AppSrvClient1.Answer.First;
    if not DecodeBoolStr(AppSrvClient1.Answer.Fields[0]) then 
    begin
      MessageBox(WindowHandle, PChar(JVCSRES_The_module_is_checked_out46 + #13#10 +
        JVCSRES_You_cannot_hide_modules_while_they_are_checked_out46), cMsgBoxCaption, MB_OK or
        MB_ICONWARNING);
      bStopRefresh := False;
      Exit;
    end;
  end; // with DataModule1 do begin
  RefreshModules;
  GetArchiveTimeStamp(ArchTStamp);
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiShowMenuBitmapsClick(Sender: TObject);
begin
  mmiShowMenuBitmaps.Checked := not mmiShowMenuBitmaps.Checked;
  if mmiShowMenuBitmaps.Checked then 
  begin
    MainMenu1.Images := ToolImageList;
    PopupMenu1.Images := ToolImageList;
    if Assigned(JVCSDockLockedModulesWindow) then
      JVCSDockLockedModulesWindow.popmSharedby.Images := ToolImageList;
    if Assigned(VCSModuleHistoryWindow) then
      VCSModuleHistoryWindow.PopupMenu1.Images := ToolImageList;
  end
  else
  begin
    MainMenu1.Images := nil;
    PopupMenu1.Images := nil;
    if Assigned(JVCSDockLockedModulesWindow) then
      JVCSDockLockedModulesWindow.popmSharedby.Images := nil;
    if Assigned(VCSModuleHistoryWindow) then
      VCSModuleHistoryWindow.PopupMenu1.Images := nil;
  end;
  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'ProjMan_ShowMenuBitmaps',
    mmiShowMenuBitmaps.Checked);
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiShowColorsClick(Sender: TObject);
begin
  mmiShowColors.Checked := not mmiShowColors.Checked;
  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'ProjMan_ShowListColors',
    mmiShowColors.Checked);
  elvModules.Repaint;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.elvModulesDrawHeader(Control: TWinControl;
  var ACanvas: TCanvas; Index: Integer; var ARect: TRect;
  Selected: Boolean; var DefaultDrawing: Boolean);
begin
  DefaultDrawing := True;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.elvModulesDrawItem(Control: TWinControl;
  var ACanvas: TCanvas; Index: Integer; ARect: TRect;
  State: TOwnerDrawState; var DefaultDrawing, FullRowSelect: Boolean);
begin
  DefaultDrawing := True;
  FullRowSelect := True;
  if (not mmiShowColors.Checked) then 
    Exit;

  if (elvModules.Items[Index].SubItems[sitState] = JVCSRES_N47A) then 
  begin
    ACanvas.Font.Color := LVColorNew;
    Exit;
  end;

  if (elvModules.Items[Index].SubItems[sitState] = JVCSRES_Out) then 
  begin
    if elvModules.Items[Index].SubItems[sitOwner] = sCurrentUser then 
    begin
      if elvModules.Items[Index].Selected then
        ACanvas.Font.Style := ACanvas.Font.Style + [fsBold]
      else
        ACanvas.Font.Color := LVColorOut;
    end 
    else 
    begin
      if elvModules.Items[Index].Selected then
        ACanvas.Font.Style := ACanvas.Font.Style + [fsItalic]
      else
        ACanvas.Font.Color := LVColorNA;
    end;
  end; // if elvModules.Items[Index].SubItems[sitState] = 'Out' then begin
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiUsedUnitsClick(Sender: TObject);
var
  I: Integer;
  NeedRefresh: Boolean;
  NewFiles: TStringList;
  CurrFile: string;
begin
  if bIsCppBuilder then
  begin
    MessageBox(WindowHandle, PChar(JVCSRES_This_feature_is_currently_not_supported_by_the_C4343_Builder_version46_Sorry46),
      cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
    Exit;
  end;

  bStopRefresh := True;
  NewFiles := TStringList.Create;
  try
    VCSUsedUnits := TVCSUsedUnits.Create(Application);
    try
      VCSUsedUnits.ShowModal;
      NeedRefresh := (VCSUsedUnits.SelectedUnits.Count > 0);
      for I := 0 to VCSUsedUnits.SelectedUnits.Count - 1 do
        NewFiles.Add(VCSUsedUnits.SelectedUnits[I]);
    finally
      VCSUsedUnits.Free;
    end;
    if NeedRefresh then 
    begin
      for I := 0 to NewFiles.Count - 1 do 
        AddModule(NewFiles.Strings[I]);
      DSAIdentsSetState(sBaseRegistryKey + crbMRU + 'Dlgs', 'IsSharedMod', True);
      if (elvModules.Items.Count > 0) then 
        elvModules.Resort;
      // select the files
      for I := 0 to elvModules.Items.Count - 1 do 
      begin
        CurrFile := elvModules.Items[I].SubItems[sitPath] +
          LowerCase(elvModules.Items[I].Caption);
        if (NewFiles.IndexOf(CurrFile) <> -1) and
          (elvModules.Items[I].SubItems[sitCount] = '0') then
          elvModules.Items[I].Selected := True
        else 
          elvModules.Items[I].Selected := False;
      end; // for I := 0 to elvModules.Items.Count - 1 do begin
      if (elvModules.SelCount > 0) then 
        acCheckInExecute(Self);
      SetStatusBar;
    end; // if NeedRefresh then begin
  finally
    NewFiles.Free;
  end;
  BringWindowToTop(WindowHandle);
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

{procedure TVCSProjAdmin.mmiUsedProjectsClick(Sender: TObject);
var NeedRefresh: Boolean;
    I: Integer;
begin
  bStopRefresh := True;
  VCSUsedProjects := TVCSUsedProjects.Create(Application);
  try
    VCSUsedProjects.ShowModal;
    NeedRefresh := (VCSUsedUnits.SelectedUnits.Count > 0);
    for I := 0 to VCSUsedUnits.SelectedUnits.Count - 1
      do AddModule(VCSUsedUnits.SelectedUnits[I]);
    DSAIdentsSetState(sBaseRegistryKey + crbMRU + 'Dlgs', 'IsSharedMod', True);
  finally
    VCSUsedProjects.Free;
  end;
  if NeedRefresh then begin
    if (elvModules.Items.Count > 0) then elvModules.Resort;
    SetStatusBar;
  end; // if NeedRefresh then begin
  bStopRefresh := False;
end;}

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiProjectdependenciesClick(Sender: TObject);
begin
  if bIsCppBuilder then
  begin
    MessageBox(WindowHandle, PChar(JVCSRES_This_feature_is_currently_not_supported_by_the_C4343_Builder_version46_Sorry46),
      cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
    Exit;
  end;
  bStopRefresh := True;
  VCSProjectDependencies := TVCSProjectDependencies.Create(Application);
  try
    VCSProjectDependencies.ShowModal;
  finally
    VCSProjectDependencies.Free;
  end;
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.acCompareExecute(Sender: TObject);
var
  CompareFile: string;
begin
  if not ArchivedModuleSelected then
    Exit;
  bStopRefresh := True;
  try
    if elvModules.SelCount = 1 then
    begin
      CompareFile := elvModules.Selected.SubItems[sitPath] + elvModules.Selected.Caption;
      {if Pos('/.dfm', CompareFile) <> 0
        then CompareFile := Copy(CompareFile, 1, Pos('/.dfm', CompareFile) - 1);}
    end // if elvModules.SelCount = 1 then begin
    else
      CompareFile := '';

    DoModuleCompare(CompareFile, CompareFile,
      StrToIntDef(elvModules.Selected.SubItems[sitRID], 0), AddMessage);
  finally
    bStopRefresh := False;
  end;
end;

procedure TVCSProjAdmin.acCompareAllLocalArchiveExecute(Sender: TObject);
var
  I: Integer;
  CompareModules: TCompareModuleList;
  CompareModule: TCompareModule;
begin
  if not ArchivedModuleSelected then
    Exit;
  bStopRefresh := True;
  try
    if elvModules.SelCount >= 1 then
    begin
      CompareModules := TCompareModuleList.Create;
      try
        for I := 0 to elvModules.Items.Count - 1 do
          if elvModules.Items[I].Selected then
          begin
            CompareModule := CompareModules.Add(StrToIntDef(elvModules.Items[I].SubItems[sitMID], 0),
              elvModules.Items[I].SubItems[sitPath] + elvModules.Items[I].Caption);
            CompareModule.Revision1.Kind := cmrkLocal;
            CompareModule.Revision2.Kind := cmrkLatest;
          end;
        CompareModules.Compare;
      finally
        CompareModules.Free;
      end;
    end;
  finally
    bStopRefresh := False;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.acHistoryExecute(Sender: TObject);
var 
  HistoryFile: string;
begin
  if not ArchivedModuleSelected then 
    Exit;
  bStopRefresh := True;
  HistoryFile := elvModules.Selected.SubItems[sitPath] +
    LowerCase(elvModules.Selected.Caption);

  VCSHistory := TVCSHistory.Create(Application);
  try
    VCSHistory.ModuleName := HistoryFile;
    VCSHistory.ShowModal;
  finally
    VCSHistory.Free;
  end;
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.acCheckInExecute(Sender: TObject);
var
  CheckInModule: string;
  CheckInList: TStringList;
  I: Integer;
  HasErrors, NeedRefresh: Boolean;
begin
  // Table callback -> off
  bStopRefresh := True;
  CheckInList := TStringList.Create;
  try
    with elvModules do
    begin
      for I := 0 to Items.Count - 1 do
      begin
        if Items[I].Selected and
          FileExists(Items[I].SubItems[sitPath] + Items[I].Caption) then
        begin
          // add a record number if one is available, otherwise a path
          if Items[I].SubItems[sitMID] <> JVCSRES_N47A then
            CheckInModule := '>' + Items[I].SubItems[sitMID]
          else
          begin
            CheckInModule := Items[I].SubItems[sitPath] + LowerCase(Items[I].Caption);
          end; // else if Items[I].SubItems[sitRec] <> 'N/A'
          CheckInList.Add(CheckInModule);
        end; // if Items[I].Selected and...
      end; //for I := 0 to elvModules.Items.Count - 1 do begin
    end; // with elvModules do begin

    if CheckInList.Count = 0 then 
    begin
      bStopRefresh := False;
      // Message Window
      BeepIfSet;
      AddMessage(JVCSRES_Check_In58_module91s93_not_available_for_check_in, msclNormal);
      Exit;
    end; // if CheckInList.Count = 0 then begin

    // Message Window
    AddMessage(Format(JVCSRES_Check_In58_37d_module91s93_selected_45_Working464646,
      [CheckInList.Count]), msclNormal);

    VCSChkInSingle := TVCSChkInSingle.Create(Application); // unit CheckIn
    try
      for I := 0 to CheckInList.Count - 1 do 
      begin
        VCSChkInSingle.SelectModuleList.AddObject(CheckInList.Strings[I], TObject(ServerProjectID));
      end;
      VCSChkInSingle.AsChild := True;
      VCSChkInSingle.ShowModal;
      NeedRefresh := VCSChkInSingle.ArchiveChanged;
      HasErrors := VCSChkInSingle.HasErrors;
    finally
      VCSChkInSingle.Free;
    end;
  finally
    CheckInList.Free;
    bSCActive := False;
  end;
  if NeedRefresh then 
  begin
    GetLabels;
    // Message Window
    if mmiShowMsgWin.Checked then 
    begin
      if HasErrors then
        AddMessage(JVCSRES_Check_In58_Not_all_modules_could_be_checked_in464646, msclError)
      else 
      begin
        with elvModules do 
        begin
          for I := 0 to Items.Count - 1 do 
          begin
            if Items[I].Selected {and (Items[I].SubItems[sitState] = 'In')} then
            begin
              CheckInModule := Items[I].SubItems[sitPath] + LowerCase(Items[I].Caption);
              AddMessage(Format(JVCSRES_Check_In58_37s_45_Success, [CheckInModule]), msclNormal);
            end;
          end; // for I := 0 to Items.Count - 1 do begin
        end; // with elvModules do begin
      end;
    end; // if mmiShowMsgWin.Checked then begin
    // if we have more than 10 modules to refresh it is faster to rebuild
    if elvModules.SelCount > 10 then 
      FillListView
    else 
      RefreshModules;
    SetStatusBar;
    GetArchiveTimeStamp(ArchTStamp);
    bPJM_NeedRefresh := False;
  end // if NeedRefresh then begin
  else 
  begin
    // Message Window
    AddMessage(JVCSRES_Check_In58_Operation_canceled, msclNormal);
  end;
  bStopRefresh := False;
  RefreshDispatcher.DispatchSimpleRefresh(rtRefresh);  
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.acCheckOutExecute(Sender: TObject);
var 
  CheckOutModule: string;
  CheckOutList: TStringList;
  I: Integer;
  HasErrors, NeedRefresh: Boolean;
begin
  bStopRefresh := True;
  CheckOutList := TStringList.Create;
  try
    with elvModules do 
    begin
      for I := 0 to Items.Count - 1 do 
      begin
        if Items[I].Selected then 
        begin
          // add a record number if one is available, otherwise a path
          if Items[I].SubItems[sitMID] <> JVCSRES_N47A then
            CheckOutModule := '>' + Items[I].SubItems[sitMID]
          else 
          begin
            CheckOutModule := Items[I].SubItems[sitPath] + LowerCase(Items[I].Caption);
            if Pos('/.dfm', CheckOutModule) <> 0 then
              CheckOutModule := Copy(CheckOutModule, 1,
                Pos('/.dfm', CheckOutModule) - 1);
          end; // else if Items[I].SubItems[sitRec] <> 'N/A'
          CheckOutList.Add(CheckOutModule);
        end; // if Items[I].Selected then begin
      end; //for I := 0 to elvModules.Items.Count - 1 do begin
    end; // with elvModules do begin

    // Message Window
    AddMessage(Format(JVCSRES_Check_Out58_37d_module91s93_selected_45_Working464646,
      [CheckOutList.Count]), msclNormal);

    VCSChkOutSingle := TVCSChkOutSingle.Create(Application);
    try
      for I := 0 to CheckOutList.Count - 1 do 
      begin
        VCSChkOutSingle.SelectModuleList.AddObject(CheckOutList.Strings[I], TObject(ServerProjectID));
      end;
      VCSChkOutSingle.AsChild := True;
      VCSChkOutSingle.ShowModal;
      NeedRefresh := VCSChkOutSingle.ArchiveChanged;
      HasErrors := VCSChkOutSingle.HasErrors;
    finally
      VCSChkOutSingle.Free;
    end;
  finally
    CheckOutList.Free;
    bSCActive := False;
  end;
  if NeedRefresh then 
  begin
    // Message Window
    if mmiShowMsgWin.Checked then 
    begin
      if HasErrors then
        AddMessage(JVCSRES_Check_Out58_Not_all_modules_could_be_checked_out464646, msclError)
      else 
      begin
        with elvModules do
        begin
          for I := 0 to Items.Count - 1 do
          begin
            if Items[I].Selected {and (Items[I].SubItems[sitState] = 'Out')} then 
            begin
              CheckOutModule := Items[I].SubItems[sitPath] + LowerCase(Items[I].Caption);
              AddMessage(Format(JVCSRES_Check_Out58_37s_45_Success, [CheckOutModule]), msclNormal);
            end;
          end; // for I := 0 to Items.Count - 1 do begin
        end; // with elvModules do begin
      end;
    end; // if mmiShowMsgWin.Checked then begin
    // if we have more than 10 modules to refresh it is faster to rebuild
    if elvModules.SelCount > 10 then 
      FillListView
    else
      RefreshModules;
    SetStatusBar;
    GetArchiveTimeStamp(ArchTStamp);
    bPJM_NeedRefresh := False;
  end // if NeedRefresh then begin
  else 
  begin
    // Message Window
    AddMessage(JVCSRES_Check_Out58_Operation_canceled, msclNormal);
  end;
  bStopRefresh := False;
  RefreshDispatcher.DispatchSimpleRefresh(rtRefresh);  
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.acKeyAdminExecute(Sender: TObject);
var
  Changed: Boolean;
begin
  if elvModules.Selected = nil then
    Exit;
  if not ArchivedModuleSelected then
    Exit;
  if (elvModules.Selected.SubItems[sitState] = JVCSRES_Out) and
    (elvModules.Selected.SubItems[sitOwner] <> sCurrentUser) then
  begin
    BeepIfSet;
    MessageBox(WindowHandle, PChar(Format('<%s>' + #13#10 +
      JVCSRES_You_are_currently_not_the_owner_of_this_module46 + #13#10 +
      JVCSRES_Module_cannot_be_changed46,
      [elvModules.Selected.Caption])), cMsgBoxCaption, MB_OK or MB_ICONWARNING);
    Exit;
  end;
  bStopRefresh := True;
  VCSAssignLabels := TVCSAssignLabels.Create(Application);
  try
    VCSAssignLabels.Left := Left + 60;
    VCSAssignLabels.Top := Top + 60;
    VCSAssignLabels.RevisionID := elvModules.Selected.SubItems[sitRID];
    VCSAssignLabels.ModuleID := elvModules.Selected.SubItems[sitMID];
    VCSAssignLabels.ModuleName := elvModules.Selected.Caption + ' V' +
      elvModules.Selected.SubItems[sitVer];
    VCSAssignLabels.ShowModal;
    Changed := VCSAssignLabels.LabelsChanged;
  finally
    VCSAssignLabels.Free;
  end;
  if Changed then 
  begin
    GetLabels;
    GetLabelAssignement(False);
    RefreshModules;
    GetArchiveTimeStamp(ArchTStamp);
  end;

  AddMessage(Format(JVCSRES_Change_labels58_37s_45_Success, [elvModules.Selected.Caption]),
    msclNormal);

  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.SelectionOfModules(const aSelectAction : TSelectAction);
var
  I: Integer;
  CRC1, CRC2, Mess: string;
begin
  elvModules.Items.BeginUpdate;
  try
    // Dispatching a selected module in elvModulesSelectItem for every selected
    // item makes selection very slow. As dispatching in elvModulesSelectItem is
    // intended only for one item, updating seems not very usefull at this time.
    // Thus we drop dispatching during this selection cycle.
    // Also OnChange Event is not necessary and reduces performance unnecessarily.
    // We'll call it one time when selecting is finished.
    elvModules.OnSelectItem := Nil;
    elvModules.OnChange := Nil;
    try
      for I := 0 to elvModules.Items.Count - 1 do
      begin
        case aSelectAction of
          selAcSelectAll    :
            elvModules.Items[I].Selected := True;
          selAcUnselectAll  :
            elvModules.Items[I].Selected := False;
          selAcRevertSelection:
            begin
              if elvModules.Items[I].Selected then
                elvModules.Items[I].Selected := False
              else
                elvModules.Items[I].Selected := True;
            end;
          selAcAllCheckedIn:
            begin
              if elvModules.Items[I].SubItems[sitState] = JVCSRES_In then
                elvModules.Items[I].Selected := True
              else
                elvModules.Items[I].Selected := False;
            end;
          selAcAllCheckedOut:
            begin
              if elvModules.Items[I].SubItems[sitState] = JVCSRES_Out then
                elvModules.Items[I].Selected := True
              else
                elvModules.Items[I].Selected := False;
            end;
          selAcAllCheckedOutByCurrentUser:
            begin
              if (elvModules.Items[I].SubItems[sitOwner] = sCurrentUser) and
                (elvModules.Items[I].SubItems[sitState] = JVCSRES_Out) then
                elvModules.Items[I].Selected := True
              else
                elvModules.Items[I].Selected := False;
            end;
          selAcAllNotYetAppliedChanges:
            begin
              if (elvModules.Items[I].SubItems[sitOwner] = sCurrentUser) and
                  (elvModules.Items[I].SubItems[sitState] = JVCSRES_Out) and
                    (FileExists(elvModules.Items[I].SubItems[sitPath] +
                      elvModules.Items[I].Caption)) then
              begin
                CRC1 := GetArchiveCRC(elvModules.Items[I].SubItems[sitRID]);
                CRC2 := IntToHex( CRCInt( elvModules.Items[I].SubItems[sitPath] +
                                            elvModules.Items[I].Caption
                                        , Mess
                                        )
                                , 8
                                );
                elvModules.Items[I].Selected := (CRC1 <> CRC2);
              end // if (elvModules.Items[I].SubItems[sitOwner] = sCurrentUser) and...
              else
                elvModules.Items[I].Selected := False;
            end;
          selAcAllNeverArchieved:
            begin
              if (elvModules.Items[I].SubItems[sitState] = JVCSRES_N47A) and
                FileExists(elvModules.Items[I].SubItems[sitPath] + elvModules.Items[I].Caption) then
                elvModules.Items[I].Selected := True
              else
                elvModules.Items[I].Selected := False;
            end;
        end;
      end;
    finally
      elvModules.Items.EndUpdate;
    end;
  finally
    elvModules.OnSelectItem := elvModulesSelectItem;
    elvModules.OnChange := elvModulesChange;
    elvModulesChange(nil, nil, ctState);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.acSelectAllClick(Sender: TObject);
begin
  SelectionOfModules(selAcSelectAll);
  // Message Window
  AddMessage( Format( JVCSRES_Selection58_All_modules_45_37d_hits
                    , [elvModules.SelCount]
                    )
            , msclNormal
            );
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiUnselectAllClick(Sender: TObject);
begin
  SelectionOfModules(selAcUnselectAll);
  // Message Window
  AddMessage(JVCSRES_Selection58_None, msclNormal);
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.ReverseSelection1Click(Sender: TObject);
begin
  SelectionOfModules(selAcRevertSelection);
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiAllcheckedoutClick(Sender: TObject);
begin
  SelectionOfModules(selAcAllCheckedOut);
  // Message Window
  AddMessage( Format( JVCSRES_Selection58_All_checked_out_modules_45_37d_hits
                    , [elvModules.SelCount]
                    )

            , msclNormal
            );
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiAllCheckedinClick(Sender: TObject);
begin
  SelectionOfModules(selAcAllCheckedIn);
  // Message Window
  AddMessage( Format( JVCSRES_Selection58_All_checked_in_modules_45_37d_hits
                    , [elvModules.SelCount])
            , msclNormal
            );
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiChckoutbycurruserClick(Sender: TObject);
begin
  SelectionOfModules(selAcAllCheckedOutByCurrentUser);
  // Message Window
  AddMessage( Format( JVCSRES_Selection58_All_checked_out_by_37s_45_37d_hits
                    , [sCurrentUser, elvModules.SelCount]
                    )
            , msclNormal
            );
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.NotArchieved1Click(Sender: TObject);
begin
  SelectionOfModules(selAcAllNeverArchieved);
  // Message Window
  AddMessage( Format( JVCSRES_Selection58_All_unregistered_modules_45_37d_hits
                    , [elvModules.SelCount]
                    )
            , msclNormal
            );
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.acModInfoExecute(Sender: TObject);
var 
  Key: Integer;
begin
  if not ArchivedModuleSelected then 
    Exit;

  try
    Key := StrToInt(elvModules.Selected.SubItems[sitMID]);
  except
    {$IFDEF DEBUG}
    JclDebug.TraceMsg('PM: ConvertError Selected.SubItems[sitRec]');
    {$ENDIF DEBUG}
    Exit;
  end;
  bStopRefresh := True;
  VCSInfo := TVCSInfo.Create(Application);
  try
    VCSInfo.ModuleID := Key;
    VCSInfo.GetEnabled := True;
    VCSInfo.ShowModal;
  finally
    VCSInfo.Free;
  end;
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiToDolistClick(Sender: TObject);
begin
  bStopRefresh := True;
  VCSToDo := TVCSToDo.Create(Application);
  try
    VCSToDo.ShowModal;
  finally
    VCSToDo.Free;
  end;
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiTouchClick(Sender: TObject);
begin
  VCSTouch := TVCSTouch.Create(Application);
  try
    VCSTouch.ShowModal;
  finally
    VCSTouch.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiBackupRestoreClick(Sender: TObject);
begin
  bStopRefresh := True;
  VCSBackup := TVCSBackup.Create(Application);
  try
    VCSBackup.BackupProjectName := sProjectName;
    VCSBackup.AutoBackup := False;
    VCSBackup.ShowModal;
  finally
    VCSBackup.Free;
  end;
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.acPrintReportsExecute(Sender: TObject);
var 
  Mess, TMPDirectory: string;
  TempFiles: TStringList;
  SearchRec: TSearchRec;
  SearchBytes: Int64;
  I: Integer;
  Device: string;
  DefaultPrinter: Boolean;
  {$IFDEF REPORTDLL}
  FuncPtr: TFarProc;
  DLLServer, DLLPort, VerInfo: string;
  {$ENDIF REPORTDLL}
begin
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
      cMsgBoxCaption, MB_OK or MB_ICONWARNING);
    Exit;
  end;

  {$IFDEF REPORTDLL}
  bStopRefresh := True;
  if ReportDLLHandle = 0 then 
  begin
    ReportDLLHandle := LoadLibrary(PChar(sDLLDirectory + cJVCSReportDll));
    if ReportDLLHandle = 0 then 
    begin
      SysUtils.Beep;
      MessageBox(Application.Handle, PChar(Format(JVCSRES_JEDI_VCS_cannot_load_the_library58
        + #13#10 + '<%s>.' + #13#10 +
        JVCSRES_The_function_you_have_requested_requires_an_additional + #13#10 +
        JVCSRES_DLL_which_is_not_part_of_the_JEDI_VCS_standard_package46 + #13#10 +
        JVCSRES_You_can_download_this_DLL_for_free_from_JEDI_VCS_home46,
        [sDLLDirectory + cJVCSReportDll])), cMsgBoxCaption, MB_OK or MB_ICONWARNING);
      bStopRefresh := False;
      Exit;
    end;
    FuncPtr := GetProcAddress(ReportDLLHandle, 'fvcs_DLLInitProc');
    if FuncPtr <> nil then 
    begin @fvcsReportDLLInitProc := FuncPtr;
      fvcsReportDLLInitProc(Application, Screen);
    end // if FuncPtr <> nil then begin
    else 
    begin
      SysUtils.Beep;
      MessageBox(Application.Handle, PChar(Format(JVCSRES_Fatal_Error58_JEDI_VCS_cannot_find_the_external_library_procedure58 + #13#10 +
        '<%s>.' + #13#10 + JVCSRES_The_reason_for_this_is_usually_an_invalid_DLL_version + #13#10 +
        JVCSRES_or_the_library_could_not_be_loaded46, ['fvcs_DLLInitProc'])),
        cJVCSReportDll, MB_OK or MB_ICONSTOP);
      bStopRefresh := False;
      Exit;
    end; // else if FuncPtr <> nil then begin
  end; // if ReportDLLHandle = 0 then begin

  FuncPtr := GetProcAddress(ReportDLLHandle, 'fvcs_SelectReport');
  if FuncPtr <> nil then 
  begin
    VerInfo := 'JEDI VCS ' + sProductVer + cProductInf + DateTimeToStr(Now);
    DLLServer := DataModule1.AppSrvClient1.Server;
    DLLPort := DataModule1.AppSrvClient1.Port; @fvcsSelectReport := FuncPtr;
    fvcsSelectReport(Left + 60, Top + 60, IDH_Reports_Printing,
      ServerProjectID, TransactionNr, ServerUserID,
      PChar(DLLServer), PChar(DLLPort),
      PChar(sDLLDirectory), PChar(sBaseRegistryKey),
      PChar(VerInfo), PChar(sCurrentUser));
  end // if FuncPtr <> nil then begin
  else 
  begin
    SysUtils.Beep;
    MessageBox(Application.Handle, PChar(Format(JVCSRES_Fatal_Error58_JEDI_VCS_cannot_find_the_external_library_procedure58 + #13#10 +
      '<%s>.' + #13#10 + JVCSRES_The_reason_for_this_is_usually_an_invalid_DLL_version + #13#10 +
      JVCSRES_or_the_library_could_not_be_loaded46, ['fvcs_SelectReport'])),
      cJVCSReportDll, MB_OK or MB_ICONSTOP);
    bStopRefresh := False;
    Exit;
  end; // else if FuncPtr <> nil then begin
  bStopRefresh := False;
  {$ELSE}
  bStopRefresh := True;
  VCSReport := TVCSReport.Create(Application);
  try
    VCSReport.ShowModal;
  finally
    VCSReport.Free;
  end;
  bStopRefresh := False;
  {$ENDIF REPORTDLL}

  // Temporäre Files von QRPreview
  // TMP - Verzeichnis ?
  I := 255;
  SetLength(TMPDirectory, I);
  I := GetTempPath(I, PChar(TMPDirectory));
  if I = 0 then 
    Exit; // Error
  SetLength(TMPDirectory, StrLen(PChar(TMPDirectory)));
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

      // Message Window
      AddMessage(Format(JVCSRES_37d_KBytes_in_37d_temporary_file91s93_40QRPxx46tmp41_left_by_QRPreview,
        [SearchBytes, TempFiles.Count]), msclNormal);

      UseRegistry := True;
      DontShowMsgText := JVCSRES_38Delete_without_prompting_from_now_on46;
      Mess := Format(JVCSRES_37d_KBytes_in_37d_temporary_files_40QRPxx46tmp41_left_in_6037s6246 + #13#10 +
        JVCSRES_Delete63, [SearchBytes, TempFiles.Count, TMPDirectory]);
      if DSAIdentsMessageDlg(Mess
        , mtConfirmation
        , [mbYes, mbNo]
        , 0
        , sBaseRegistryKey + crbMRU + 'Dlgs'
        , 'DelQRPD'
        , idYes
        ) = idYes then
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
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiActiveClick(Sender: TObject);
begin
  mmiActive.Checked := not mmiActive.Checked;
  jvcsWriteBool(sBaseRegistryKey + crbTimeLog, ExtractFileName(sProjectName),
    mmiActive.Checked);
  if mmiActive.Checked then
    WriteTimeLog( sConfigFolder + ChangeFileExt(ExtractFileName(sProjectName), '.tlg')
                , 'open;' + sCurrentUser + ';' + FloatToStr(Now)
                );
  if (not mmiActive.Checked) and
    FileExists(sConfigFolder + ChangeFileExt(ExtractFileName(sProjectName), '.tlg')) then
      WriteTimeLog( sConfigFolder + ChangeFileExt(ExtractFileName(sProjectName), '.tlg')
                  , 'close;' + sCurrentUser + ';' + FloatToStr(Now)
                  );
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiShowtimelogClick(Sender: TObject);
begin
  bStopRefresh := True;
  VCSShowTimeLog := TVCSShowTimeLog.Create(Application);
  try
    VCSShowTimeLog.ShowModal;
  finally
    VCSShowTimeLog.Free;
  end;
  if (ExtractFileName(sCurrentProject) <> '') then
    mmiActive.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbTimeLog, ExtractFileName(sCurrentProject), False);
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.acUndoChkOutExecute(Sender: TObject);
var 
  Msg: string;
  Module, ModuleID, TargetFile, OldFile, OriginalPath, AffectedFiles, NotReadOnlyFilter, Mess, ErrMsg: string;
  TargetFDate: TDateTime;
  I, mbIcon, FuncRes, Yes2allRes: Integer;
  CloseIDEView, SetROFlag, SkipROCheck, Yes2AllUndo, Yes2AllRestore: Boolean;
label
  NextModule;
begin
  Yes2AllUndo := False;
  Yes2AllRestore := False;
  for I := 0 to elvModules.Items.Count - 1 do 
  begin
    if elvModules.Items[I].Selected then 
    begin
      if elvModules.Items[I].SubItems[sitRID] = JVCSRES_N47A then
        Continue;
      if not Yes2AllUndo then 
      begin
        VCSYes2AllDlg := TVCSYes2AllDlg.Create(Application);
        try
          VCSYes2AllDlg.SetMessageText(Format(JVCSRES_Are_you_sure_you_want_to_cancel_your_work_on
            + #13#10 + JVCSRES_6037s62_and_unlock_the_module63,
            [elvModules.Items[I].Caption]));
          VCSYes2AllDlg.EnableYes2All(True);
          VCSYes2AllDlg.ShowCheckBox(False);
          VCSYes2AllDlg.SetCheckBoxCaption('');
          Yes2allRes := VCSYes2AllDlg.ShowModal;
        finally
          VCSYes2AllDlg.Free;
        end;
        case Yes2allRes of
          mrYes :;
          mrAll: 
            Yes2AllUndo := True;
          mrNo:
            Continue;
          mrCancel: 
            Break;
        end; // case Yes2allRes of
      end; // if not Yes2all then begin

      if ArchiveAdmin and
        (elvModules.Items[I].SubItems[sitState] = JVCSRES_Out) and
        (elvModules.Items[I].SubItems[sitOwner] <> sCurrentUser) then 
      begin
        BeepIfSet;
        if MessageBox(WindowHandle, PChar(Format('<%s>' + #13#10 +
          JVCSRES_This_module_is_locked_by_another_user46 + #13#10 +
          JVCSRES_Use_your_administrator_right_to_unlock_anyway63 + #13#10 +
          JVCSRES_Warning33_All_changes_to_this_file_will_be_lost46,
          [elvModules.Items[I].Caption])), cMsgBoxCaption,
          MB_YESNOCANCEL or MB_DEFBUTTON2 or MB_ICONWARNING) <> idYes then 
          Exit;
      end; // if ArchiveAdmin and...
      NotReadOnlyFilter :=
        jvcsReadString(sBaseRegistryKey + crbFilters, 'Writeable files', dfNotReadOnly);
    // readonly ?
      //??? GlobalSettings
      if not SettingIsGlobal(17) then
        SkipROCheck := jvcsReadBool(sBaseRegistryKey + crbOptions, 'NoROCheck', False)
      else
        SkipROCheck := GlobalSettingValue(17);

      if (not SkipROCheck) and
        ((FileGetAttr(elvModules.Items[I].SubItems[sitPath] +
        elvModules.Items[I].Caption) and faReadOnly) = faReadOnly) then 
      begin
        BeepIfSet;
        case MessageBox(WindowHandle, PChar(Format('%s <%s>.' + #13#10 +
          JVCSRES_JEDI_VCS_expects_the_local_file_to_be_37s44_but_the_file_is_37s46 + #13#10 +
          JVCSRES_Continue_anyway63, [JVCSRES_Undo_Check_Out,
          elvModules.Items[I].SubItems[sitPath] + elvModules.Items[I].Caption,
          JVCSRES_writeable, JVCSRES_read45only])), cMsgBoxCaption,
          MB_YESNOCANCEL or MB_DEFBUTTON2 or MB_ICONWARNING) of
          idYes :;
          idNo: 
            Continue;
          else 
            Break;
        end; // case
      end; // if (not SkipROCheck) and

      bStopRefresh := True;
      with DataModule1 do 
      begin
        AppSrvClient1.Request.Rewrite;
        AppSrvClient1.FunctionCode := 'UNDO_CHECKOUT_MODULE';
        AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
        AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
        AppSrvClient1.Request.WriteFields(True, [ServerProjectID]);
        AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
        AppSrvClient1.Request.WriteFields(False,
          [elvModules.Items[I].SubItems[sitMID]]);
        AppSrvClient1.Request.WriteFields(False, [LowerCase(elvModules.Items[I].Caption)]);
        SetupTimeoutCounter;
        AppSrvClient1.Send;

        while WaitForAppSrvClient do 
          Application.ProcessMessages;
        if (AppSrvClientErr = -99) then 
        begin
          ShowServerTimeOut(WindowHandle);
          bStopRefresh := False;
          Exit;
        end;
        if (AppSrvClientErr <> 0) or
          (AppSrvClient1.AnswerStatus <> '200') then 
        begin
          ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
            AppSrvClient1.AnswerStatus);
          bStopRefresh := False;
          Exit;
        end;

        AppSrvClient1.Answer.First;
        if not AppSrvClient1.Answer.Eof then 
        begin
          if not DecodeBoolStr(AppSrvClient1.Answer.Fields[0]) then 
          begin
            Msg := '<' + elvModules.Items[I].Caption + '>' + #10#13;
            if AppSrvClient1.Answer.Fields[1] <> '' then
            begin
              Msg := Msg + Format(JVCSRES_Module_is_checked_out_by_37s, [AppSrvClient1.Answer.Fields[1]]);
              mbIcon := MB_ICONWARNING;
              BeepIfSet;
            end 
            else 
            begin
              Msg := Msg + JVCSRES_Nothing_to_do46;
              mbIcon := MB_ICONINFORMATION;
            end;
            Msg := Msg + #10#13 + AppSrvClient1.Answer.Fields[2];
            MessageBox(WindowHandle, PChar(Msg), cMsgBoxCaption, MB_OK or mbIcon);
            Continue;
          end; // if not DecodeBollStr(AppSrvClient1.Answer.Fields[0]) then begin
        end; // if not AppSrvClient1.Answer.EoF do begin

        if not Yes2AllRestore then 
        begin
          VCSYes2AllDlg := TVCSYes2AllDlg.Create(Application);
          try
            VCSYes2AllDlg.SetMessageText(Format('<%s>' + #13#10 +
              JVCSRES_Undo_Checkout_success46_Module_unlocked46 + #13#10 +
              JVCSRES_Restore_original_file_state_on_local_disk63,
              [elvModules.Items[I].Caption]));
            VCSYes2AllDlg.EnableYes2All(True);
            VCSYes2AllDlg.ShowCheckBox(False);
            VCSYes2AllDlg.SetCheckBoxCaption('');
            Yes2allRes := VCSYes2AllDlg.ShowModal;
          finally
            VCSYes2AllDlg.Free;
          end;
          case Yes2allRes of
            mrYes :;
            mrAll: 
              Yes2AllRestore := True;
            mrNo: 
              Continue;
            mrCancel :
              Break;
          end; // case Yes2allRes of
        end; // if not Yes2AllRestore then begin

        // Restore (Get)
        AppSrvClient1.Request.Rewrite;
        AppSrvClient1.FunctionCode := 'GET_REVISION_STATUS';
        AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
        AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
        AppSrvClient1.Request.WriteFields(True,
          [elvModules.Items[I].SubItems[sitRID]]);
        SetupTimeoutCounter;
        AppSrvClient1.Send;

        while WaitForAppSrvClient do 
          Application.ProcessMessages;
        if (AppSrvClientErr = -99) then 
        begin
          ShowServerTimeOut(WindowHandle);
          bStopRefresh := False;
          Exit;
        end;
        if (AppSrvClientErr <> 0) or
          (AppSrvClient1.AnswerStatus <> '200') then
        begin
          ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
            AppSrvClient1.AnswerStatus);
          bStopRefresh := False;
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
        end;

        while not AppSrvClient1.Answer.Eof do 
        begin
          OldFile := OriginalPath + AppSrvClient1.Answer.Fields[1];
          OldFile := ChangeFileExt(OldFile, TrimRight(AppSrvClient1.Answer.Fields[10]));
          if FileExists(OldFile) then 
          begin
            TargetFDate := FileGetUTCDateTime(OldFile) - cTimeConvErr;
            {$IFDEF DEBUGMSG}
            ShowMessage('File: ' + ExtractFileName(OldFile) +
              ' - TargetFDate: ' + DateTimeToStrGMT(TargetFDate) +
              ' - ArchiveFDate: ' +
              DateTimeToStrGMT(_StrToFloat(AppSrvClient1.Answer.Fields[6])));
            {$ENDIF DEBUGMSG}
            if _StrToFloat(AppSrvClient1.Answer.Fields[6]) < TargetFDate then 
            begin
              if _StrToInt(AppSrvClient1.Answer.Fields[8]) <> CRCInt(OldFile, Mess) then 
              begin
                BeepIfSet;
                if MessageBox(WindowHandle, PChar(Format(JVCSRES_Module_6037s62_on_disk_has_a_newer_date_than_the_module_in_the_archive33
                  + #13#10 + JVCSRES_Are_you_sure_you_want_to_overwrite_all_changes_of_the_existing_file63,
                  [ExtractFileName(OldFile)])), cMsgBoxCaption, MB_YESNOCANCEL or
                  MB_DEFBUTTON2 or MB_ICONQUESTION) <> idYes then
                  goto NextModule;
              end;
              // if _StrToInt(AppSrvClient1.Answer.Fields[8]) <> CRCInt(OldFile, Mess) then begin
            end; // if FieldByName('FTIME').AsDateTime...
          end; // if FileExists(OldFile) then begin
          AppSrvClient1.Answer.Next;
        end; // while not AppSrvClient1.Answer.EoF do begin
      end; // with DataModule1 do begin
      TargetFile := OriginalPath + Module;

      // readonly ?
      SetROFlag := not (MatchWithFilter(ExtractFileName(TargetFile), NotReadOnlyFilter));
      CloseIDEView := not (IsIDEProject(TargetFile, sProjectName));
      
      FuncRes := GetBlobs(DBModule.GetJvcsConnection, ServerProjectID, ServerUserID,
        StrToInt(ModuleID), StrToInt(elvModules.Items[I].SubItems[sitRID]),
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
          PChar(Format('<%s>' + #13#10 + JVCSRES_JEDI_VCS_is_unable_to_create_a_local_copy_of_this_file46 + #13#10 +
            JVCSRES_Exception58_37s_in_37s46_, [TargetFile, ErrMsg, Mess])),
          cMsgBoxCaption, MB_OK or MB_ICONSTOP);
        bStopRefresh := False;
        Exit;
      end // if FuncRes <> 0 then begin
      else 
      begin
        if Length(AffectedFiles) > 1 then
          Delete(AffectedFiles, Length(AffectedFiles), 1);
        UseRegistry := True;
        DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
        DSAIdentsMessageDlg(JVCSRES_Undo_Checkout_complete46 + #10#13 +
          Format('<%s>' + #13#10 + JVCSRES_successfully_created46, [TargetFile]) + #10#13 +
          Format(JVCSRES_40Affected_files58_37s41, [AffectedFiles])
          , mtInformation
          , [mbOK]
          , 0
          , sBaseRegistryKey + crbMRU + 'Dlgs'
          , 'UndoChkOutSuc'
          , idOk
          );
      end;
    end; // if elvModules.Items[I].Selected then begin
    NextModule :
  end; //   for I := 0 to elvModules.Items.Count - 1 do begin

  RefreshModules;
  SetStatusBar;
  bStopRefresh := False;
  GetArchiveTimeStamp(ArchTStamp);
  RefreshDispatcher.DispatchSimpleRefresh(rtRefresh);  
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiDefineClick(Sender: TObject);
begin
  bStopRefresh := True;
  VCSFileFamilies := TVCSFileFamilies.Create(Application);
  try
    VCSFileFamilies.Top := Top + 60;
    VCSFileFamilies.Left := Left + 60;
    VCSFileFamilies.ShowModal;
  finally
    VCSFileFamilies.Free;
  end;
  ReadFF;
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.CustSelClick(Sender: TObject);
var 
  I, CustSel: Integer;
  CurrentEntry: string;
begin
  try
    CustSel := StrToInt((Sender as TMenuItem).Caption[2]);
  except
    CustSel := -1;
  end;
  if CustSel = -1 then 
    Exit;
  for I := 0 to elvModules.Items.Count - 1 do 
  begin
    CurrentEntry := LowerCase(elvModules.Items[I].Caption);
    {if Pos('/.dfm', CurrentEntry) <> 0
      then CurrentEntry := Copy(CurrentEntry, 1, Pos('/.dfm', CurrentEntry) - 1);}
    if MatchWithFilter(CurrentEntry, CustFF[CustSel]) then
      elvModules.Items[I].Selected := True
    else
      elvModules.Items[I].Selected := False;
  end; // for I := 0 to elvModules.Items.Count - 1 do begin
  // Message Window
  if mmiShowMsgWin.Checked then 
  begin
    CurrentEntry := (Sender as TMenuItem).Caption;
    Delete(CurrentEntry, 1, 4);
    AddMessage(Format(JVCSRES_Selection58_Custom_45_37s_4037s41_45_37d_hits,
      [CurrentEntry, CustFF[CustSel], elvModules.SelCount]), msclNormal);
  end; // if mmiShowMsgWin.Checked then begin
end;

//------------------------------------------------------------------------------

{$IFNDEF IDEDLL}
procedure TVCSProjAdmin.ReadFavorites;
var
  I, J, K, LProjectID: Integer;
  S: string;
  LMItem: TMenuItem;
  LAItem: TAction;
  FavoriteProjectList: TJVCSMruList;
begin
  for I := Pred(mmiFavorites.Count) downto 0 do
    if (mmiFavorites.Items[I] <> mmiFavAddCurrentProject) and
       (mmiFavorites.Items[I] <> mmiFavoritesSeparator) and
       (mmiFavorites.Items[I] <> mmiManageFavorites) then
    begin
      if Assigned(mmiFavorites.Items[I].Action) then
        mmiFavorites.Items[I].Action.Free;
      mmiFavorites.Items[I].Free;
    end;
  S := CurrentIdentity;
  if (S <> '') and Assigned(FRefreshProjects) then
  begin
    FRefreshProjects.Lock;
    try
      FavoriteProjectList := TJVCSMruList.CreateEx(sBaseRegistryKey + crbMRU + 'Favorites\' + S);
      try
        K := 0;
        for I := 0 to Pred(FavoriteProjectList.Count) do
        begin
          LProjectID := -1;
          for J := 0 to Pred(FRefreshProjects.Count) do
            if (FRefreshProjects[J].Name = FavoriteProjectList.Strings[I]) and (FRefreshProjects[J].ID > 0) then
            begin
              LProjectID := FRefreshProjects[J].ID;
              Break;
            end;
          if LProjectID <> -1 then
          begin
            Inc(K);
            LAItem := TAction.Create(Self);
            with LAItem do
            begin
              ActionList := ActionList1;
              Caption := FavoriteProjectList.Strings[I];
              OnExecute := OpenFavoriteProjectClick;
              Tag := LProjectID;
              if K < 10 then ShortCut := scCtrl or (Ord('0') + K);
              Enabled := True;
              if ServerProjectID = LProjectID then
              begin
                Enabled := False;
                Caption := Format(JVCSRES_37s_60open62, [Caption]);
              end;
            end;
            LMItem := TMenuItem.Create(mmiFavorites);
            with LMItem do
            begin
              Action := LAItem;
              AutoHotKeys := maManual;
              mmiFavorites.Add(LMItem);
            end;
          end;
        end;
        mmiFavAddCurrentProject.Enabled := (sProjectName <> '') and (FavoriteProjectList.IndexOf(sProjectName) < 0);
      finally
        FavoriteProjectList.Free;
      end;
    finally
      FRefreshProjects.Unlock;
    end;
  end;
end;
{$ENDIF ~IDEDLL}

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.ReadFF;
var
  I: Integer;
  FF_F: TIniFile;
  CurrEntry: string;
begin
  {$IFDEF DEBUG}
  JclDebug.TraceMsg('PM: ReadFF');
  {$ENDIF DEBUG}
  for I := 0 to 9 do 
    CustSelMI[I].Visible := False;
  {$IFDEF DEBUG}
  JclDebug.TraceMsg('PM: CustSelMI[I].Visible := False - OK');
  {$ENDIF DEBUG}
  try
    FF_F := TIniFile.Create(sDLLDirectory + cSelectionFileFamiliesFile);
  except
    BeepIfSet;
    MessageBox(WindowHandle, PChar(Format(JVCSRES_JEDI_VCS_cannot_open_the_file46_40Invalid_path_or_access_denied4158 + #13#10 +
      '<%s>.' + #13#10 +  JVCSRES_Make_sure_that_the_file_exists44_that_it_is_not_opened_by_another_application + #13#10 +
      JVCSRES_and_that_you_have_the_required_access_rights46, [sDLLDirectory + cSelectionFileFamiliesFile])),
      cMsgBoxCaption, MB_OK or MB_ICONSTOP);
    Exit;
  end;
  {$IFDEF DEBUG}
  JclDebug.TraceMsg('PM: TIniFile.Create - OK');
  {$ENDIF DEBUG}
  for I := 0 to 9 do 
  begin
    CurrEntry := FF_F.ReadString('File Families', IntToStr(I), 'Not set'); 
    if CurrEntry <> 'Not set' then 
    begin
      CustSelMI[I].Caption := '&' + IntToStr(I) + ': ' +
        Copy(CurrEntry, 1, Pos('|', CurrEntry) - 1);
      CustSelMI[I].OnClick := CustSelClick;
      CustSelMI[I].Visible := True;
      Delete(CurrEntry, 1, Pos('|', CurrEntry));
      CustFF[I] := CurrEntry;
    end // if CurrEntry <> 'Not set' then begin
    else 
      CustSelMI[I].Visible := False;
  end; // for I := 0 to 9 do begin
  FF_F.Free;
  {$IFDEF DEBUG}
  JclDebug.TraceMsg('PM: ReadFF - OK');
  {$ENDIF DEBUG}
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiSettingsClick(Sender: TObject);
begin
  {$IFDEF IDEDLL}
  if bIsCppBuilder then 
  begin
    MessageBox(WindowHandle, PChar(JVCSRES_This_feature_is_currently_not_supported_by_the_C4343_Builder_version46_Sorry46),
      cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
    Exit;
  end;
  if (AnsiLowerCase(ExtractFileExt(sProjectName)) <> '.dpr') and
    (AnsiLowerCase(ExtractFileExt(sProjectName)) <> '.dpk') then
  begin
    MessageBox(WindowHandle, PChar(JVCSRES_This_function_is_only_available_for_libraries_or_applications46),
      cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
    Exit;
  end;
  bStopRefresh := True;
  VCSVerSet := TVCSVerSet.Create(Application);
  try
    VCSVerSet.Left := Left + 60;
    VCSVerSet.Top := Top + 60;
    VCSVerSet.ShowModal;
  finally
    VCSVerSet.Free;
  end;
  bStopRefresh := False;
  {$ENDIF IDEDLL}
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.acAddtoCustFiltExecute(Sender: TObject);
var
  I: Integer;
  CustFiltItems: TStringList;
  CustFiltFile, CurrModule: string;
begin
  CustFiltItems := TStringList.Create;
  try
    CustFiltItems.Sorted := True;
    CustFiltItems.Duplicates := dupIgnore;
    CustFiltFile := sConfigFolder + ChangeFileExt(ExtractFileName(sProjectName), '.pcf');
    if FileExists(CustFiltFile) then 
    begin
      try
        CustFiltItems.LoadFromFile(CustFiltFile);
      except
        on E: Exception do 
        begin
          CustFiltItems.Clear;
          BeepIfSet;
          MessageBox(Handle, PChar(Format(JVCSRES_Reading_file_6037s62 + #13#10 +
            JVCSRES_raised_exception58 + #13#10 + '%s.', [CustFiltFile, E.Message])),
            cMsgBoxCaption, MB_OK or MB_ICONSTOP);
        end;
      end;
    end; // if FileExists(CustFiltFile) then begin

    if elvModules.SelCount > 0 then 
    begin
      I := 0;
      repeat // until I >= elvModules.Items.Count;
      {  keine for - to Schleife, sonst wird nach
         löschen über die Liste hinausgelesen  }
        Inc(I); // Start mit 1, da bei gelöschtem Eintrag
        // in der gl. Zeile weitergesucht wird
        if elvModules.Items[I - 1].Selected then 
        begin
          CurrModule := elvModules.Items[I - 1].Caption;
          if (elvModules.Items[I - 1].SubItems[sitState] = JVCSRES_Out) and
            (elvModules.Items[I - 1].SubItems[sitOwner] = sCurrentUser) then
          begin
            MessageBox(WindowHandle, PChar(Format('<%s>' + #13#10 +
              JVCSRES_Module_is_checked_out_by_you_and_cannot_be_added_at_this_time46, [CurrModule])),
              cMsgBoxCaption, MB_OK or MB_ICONWARNING);
          end 
          else 
          begin
            CurrModule := elvModules.Items[I - 1].SubItems[sitPath] + LowerCase(CurrModule);
            CustFiltItems.Add(CurrModule);
            elvModules.Items.Delete(I - 1);
            Dec(I); // gelöscht => eine Zeile zurück
            // Message Window
            AddMessage(Format(JVCSRES_Module_added_to_custom_view_filter58_37s, [CurrModule]), msclNormal);
          end; // else if (elvModules.Items[I].SubItems[sitState] := 'Out') and...
        end; // if elvModules.Selected[I] then begin
      until I >= elvModules.Items.Count;
      SetStatusBar;
    end; // if elvModules.SelCount > 0 then begin

    try
      CustFiltItems.SaveToFile(CustFiltFile);
    except
      BeepIfSet;
      MessageBox(WindowHandle, PChar(Format(JVCSRES_JEDI_VCS_cannot_save_the_file + #13#10 +
        '<%s>.' + JVCSRES_Be_sure_that_the_file_is_not_opened_by_another_application44 +
        JVCSRES_that_there_is_enough_free_space_on_the_disk + #13#10 +
        JVCSRES_and_that_you_have_the_required_access_rights46, [CustFiltFile])),
        cMsgBoxCaption, MB_OK or MB_ICONSTOP);
    end;
  finally
    CustFiltItems.Free;
  end;
  if not mmiApplycustomfilter.Checked then 
  begin
    if MessageBox(WindowHandle,
      PChar(JVCSRES_Custom_view_filter_is_inactiv33_Activate_now63),
      cMsgBoxCaption, MB_YESNOCANCEL or MB_ICONQUESTION) <> idYes then
      Exit;
    mmiApplycustomfilterClick(Self);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiShowcustofilterClick(Sender: TObject);
var
  NeedRefresh: Boolean;
begin
  bStopRefresh := True;
  VCSCustomViewFilter := TVCSCustomViewFilter.Create(Application);
  try
    VCSCustomViewFilter.Left := Left + 60;
    VCSCustomViewFilter.Top := Top + 60;
    VCSCustomViewFilter.ShowModal;
    NeedRefresh := VCSCustomViewFilter.FilterChanged;
  finally
    VCSCustomViewFilter.Free;
  end;
  bStopRefresh := False;
  if NeedRefresh and mmiApplycustomfilter.Checked then
  begin
    UseRegistry := True;
    DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
    if DSAIdentsMessageDlg(JVCSRES_Parameters_changed46_Refresh_View63
      , mtConfirmation
      , [mbYes, mbNo, mbCancel]
      , 0
      , sBaseRegistryKey + crbMRU + 'Dlgs'
      , 'RefreshView'
      , idYes
      ) <> idYes then
      Exit;
    acRefreshModuleList(Self);
    SetMenuStateEx;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiApplycustomfilterClick(Sender: TObject);
begin
  mmiApplycustomfilter.Checked := not mmiApplycustomfilter.Checked;
  jvcsWriteBool(sBaseRegistryKey + crbProjects + ExtractFileName(sProjectName),
    'ApplyCustFilter', mmiApplycustomfilter.Checked);
  UseRegistry := True;
  DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
  if DSAIdentsMessageDlg(JVCSRES_Parameters_changed46_Refresh_View63
    , mtConfirmation
    , [mbYes, mbNo, mbCancel]
    , 0
    , sBaseRegistryKey + crbMRU + 'Dlgs'
    , 'RefreshView'
    , idYes
    ) <> idYes then 
    Exit;
  acRefreshModuleList(Self);
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.History1Click(Sender: TObject);
begin
  bStopRefresh := True;
  VCSProjectHistory := TVCSProjectHistory.Create(Application);
  try
    VCSProjectHistory.ShowModal;
  finally
    VCSProjectHistory.Free;
  end;
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiDefineWCViewClick(Sender: TObject);
var 
  DlgResult: Integer;
begin
  bStopRefresh := True;
  VCSWCViewFilter := TVCSWCViewFilter.Create(Application);
  try
    VCSWCViewFilter.Top := Top + 60;
    VCSWCViewFilter.Left := Left + 60;
    VCSWCViewFilter.WildCards := WildCardFilter;
    VCSWCViewFilter.BugSeverity := BugStateFilter;
    DlgResult := VCSWCViewFilter.ShowModal;
    WildCardFilter := VCSWCViewFilter.WildCards;
    BugStateFilter := VCSWCViewFilter.BugSeverity;
  finally
    VCSWCViewFilter.Free;
  end;
  if DlgResult = mrCancel then 
  begin
    bStopRefresh := False;
    Exit;
  end;
  bStopRefresh := False;
  jvcsWriteBool(sBaseRegistryKey + crbOptions, 'WildCardFilterActive',
    (WildCardFilter <> ''));

  if WildCardFilter <> '' then
  begin
    mmiDefineWCView.Checked := True;
    jvcsWriteString(sBaseRegistryKey + crbOptions, 'WildCardFilter', WildCardFilter);
    acRefreshModuleList(Self);
  end // if WildCardFilter <> '' then begin
  else 
  begin
    mmiDefineWCView.Checked := False;
    acRefreshModuleList(Self);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.SetStatusWinState;
var
  bOneTsVis: Boolean;
  ii: Integer;
begin
  bOneTsVis := False;
  // #3404 ensure no resize happens during calculation of visible tabs. If all
  // tabs are invisble no resize should happen so window height will stay until
  // making it again visible.  
  Panel1.OnResize := nil;
  try
    for ii := 0 to pgStatus.PageCount -1 do
    begin
      if pgStatus.Pages[ii].TabVisible then
      begin
        bOneTsVis := True;
      end;
    end;
    // IF NO TabSheet.Visible?
    if not bOneTsVis then
    begin
      Splitter1.Visible := False;
      Panel1.Constraints.MinHeight := 19;
      Panel1.Height := 19;
      // MessageWindow TabSheet
      tbShowNsgWin.Down := False;
      tbShowNsgWin.Hint := JVCSRES_Show_message_window;
      // MyToDoList window
      tbShowMyToDoList.Down := False;
      tbShowMyToDoList.Hint := JVCSRES_Show_own_ToDo45List;
      // BugList window
      tbShowBugList.Down := False;
      tbShowBugList.Hint := JVCSRES_Show_Bug45List;
      // ModuleHistoryWin-List window
      tbShowModHistList.Down := False;
      tbShowModHistList.Hint := JVCSRES_Show_Module_History45List;
      // MyLockedModules List window
      tbShowLockedModulesList.Down := False;
      tbShowLockedModulesList.Hint := JVCSRES_Show_own_Locked_Modules45List;
    end
    else
    begin
      Panel1.Constraints.MinHeight := 75;
      if Panel1.Height < MsgWinHeight then
      begin
        Panel1.Height := MsgWinHeight;
      end;
      if tsMessages.TabVisible then
      begin
        tbShowNsgWin.Down := True;
        tbShowNsgWin.Hint := JVCSRES_Hide_message_window;
      end
      else
      begin
        tbShowNsgWin.Down := False;
        tbShowNsgWin.Hint := JVCSRES_Show_message_window;
      end;
      if Assigned(JVCSDockToDoWindow) and (JVCSDockToDoWindow.Visible) then
      begin
        tbShowMyToDoList.Down := True;
        tbShowMyToDoList.Hint := JVCSRES_Hide_own_ToDo45List;
      end
      else
      begin
        tbShowMyToDoList.Down := False;
        tbShowMyToDoList.Hint := JVCSRES_Show_own_ToDo45List;
      end;
      if Assigned(VCSBugWindow) and VCSBugWindow.Visible then
      begin
        tbShowBugList.Down := True;
        tbShowBugList.Hint := JVCSRES_Hide_Bug45List;
      end
      else
      begin
        tbShowBugList.Down := False;
        tbShowBugList.Hint := JVCSRES_Show_Bug45List;
      end;
      if Assigned(VCSModuleHistoryWindow) and VCSModuleHistoryWindow.Visible then
      begin
        tbShowModHistList.Down := True;
        tbShowModHistList.Hint := JVCSRES_Hide_Module_History45List;
      end
      else
      begin
        tbShowModHistList.Down := False;
        tbShowModHistList.Hint := JVCSRES_Show_Module_History45List;
      end;
      if Assigned(JVCSDockLockedModulesWindow) and JVCSDockLockedModulesWindow.Visible then
      begin
        tbShowLockedModulesList.Down := True;
        tbShowLockedModulesList.Hint := JVCSRES_Hide_own_Locked_Modules45List;
      end
      else
      begin
        tbShowLockedModulesList.Down := False;
        tbShowLockedModulesList.Hint := JVCSRES_Show_own_Locked_Modules45List;
      end;
      Splitter1.Visible := True;
    end;
    acShowMsgWin.Checked := tbShowNsgWin.Down;
    acShowToDoWin.Checked := tbShowMyToDoList.Down;
    acShowBugWin.Checked := tbShowBugList.Down;
    acShowModuleHistoryWin.Checked := tbShowModHistList.Down;
    acLockedModuleWin.Checked := tbShowLockedModulesList.Down;
  finally
    if bOneTsVis then
      Panel1.OnResize := Panel1Resize;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiShowMsgWinClick(Sender: TObject);
begin
  mmiShowMsgWin.Checked := not mmiShowMsgWin.Checked;
  jvcsWriteBool ( sBaseRegistryKey + crbWindows
                , 'ProjMan_MsgWinState'
                , mmiShowMsgWin.Checked
                );
  //@#Q
  tsMessages.TabVisible := mmiShowMsgWin.Checked;
  SetStatusWinState;
  if tsMessages.TabVisible then
    pgStatus.ActivePage := tsMessages;
  //Thu SetMsgWinState(mmiShowMsgWin.Checked);
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.Clearmessagewindow1Click(Sender: TObject);
begin
  reMessage.Lines.Clear;
  NtfyMsgCount := 0;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.Save1Click(Sender: TObject);
var 
  DlgResult: Boolean;
  FavSaveDialog: TFavSaveDialog;
  TargetFileName: string;
begin
  FavSaveDialog := TFavSaveDialog.Create(Application);
  try
    with FavSaveDialog do 
    begin
      Title := JVCSRES_Save_message_log;
      Options := [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing];
      Filter := JVCSRES_Text_files_404246txt411244246txt124All_files_4042464241124424642;
      InitialDir := ExtractFilePath(sProjectName);
      FileName := 'PM_Msg.txt';
      DefaultExt := 'txt';

      //FavSaveDialog is inherited from FavOpenDialog and thatswhy
      //ExecuteFavOpenDialogWithMru also works here
      DlgResult := ExecuteFavOpenDialogWithMru(FavSaveDialog,
        sBaseRegistryKey + crbMRU + '17');

      TargetFileName := FileName;
    end; // with SaveDialog1 do begin
  finally
    FavSaveDialog.Free;
  end;
  if not DlgResult then 
    Exit;

  try
    reMessage.Lines.SaveToFile(TargetFileName);
  except
    MessageBox(WindowHandle, PChar(Format(JVCSRES_JEDI_VCS_cannot_save_the_file + #13#10 +
      '<%s>.' + JVCSRES_Be_sure_that_the_file_is_not_opened_by_another_application44 +
      JVCSRES_that_there_is_enough_free_space_on_the_disk + #13#10 +
      JVCSRES_and_that_you_have_the_required_access_rights46, [TargetFileName])),
      cMsgBoxCaption, MB_OK or MB_ICONSTOP);
  end;

  {with SaveDialog1 do begin
    Title := 'Save message log';
    Options := [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing];
    Filter := 'Text files (*.txt)|*.txt|All files (*.*)|*.*';
    InitialDir := ExtractFilePath(sProjectName);
    FileName := 'PM_Msg.txt';
    DefaultExt := 'txt';
    if Execute then begin
      try
        reMessage.Lines.SaveToFile(FileName);
      except
        (* Error while trying to save the file <%s>! *)
        MessageBox(WindowHandle, PChar(FmtLoadStr(161, [FileName])), 
                                       cMsgBoxCaption, MB_OK or MB_ICONSTOP);
      end;
    end; // if Execute then begin
  end; // with SaveDialog1 do begin}
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.Copy1Click(Sender: TObject);
begin
  reMessage.SelStart := 0;
  reMessage.SelLength := Length(reMessage.Text);
  reMessage.CopyToClipBoard;
  reMessage.SelLength := 0;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mdSecureMail1MessageAvail(Sender: TObject;
  Msg: string);
var
  FilterOut: Boolean;
  MsgType, MsgProjectID, MsgUserID: Integer;
  MsgUser, MsgTime, MsgIPAddr: string;
begin
  if not mmiInternalNotifyactive.Checked then
    Exit;
  {  %d|%d|%d|%s|%s|%s|%s 162
     Nr|PjID|UsrID|UsrName|Time|Res|Msg  }
  //  AddMessage('Original: ' + Msg, msclNtfy);

  if Pos('|', Msg) = 0 then
    Exit;
  MsgType := _StrToInt(Copy(Msg, 1, Pos('|', Msg) - 1));
  Delete(Msg, 1, Pos('|', Msg));
  if Pos('|', Msg) = 0 then
    Exit;
  MsgProjectID := _StrToInt(Copy(Msg, 1, Pos('|', Msg) - 1));
  Delete(Msg, 1, Pos('|', Msg));
  if Pos('|', Msg) = 0 then
    Exit;
  MsgUserID := _StrToInt(Copy(Msg, 1, Pos('|', Msg) - 1));
  if MsgUserID = 0 then;  //only due to compiler hint 
  Delete(Msg, 1, Pos('|', Msg));
  if Pos('|', Msg) = 0 then
    Exit;
  MsgUser := Copy(Msg, 1, Pos('|', Msg) - 1);
  Delete(Msg, 1, Pos('|', Msg));
  if Pos('|', Msg) = 0 then
    Exit;
  MsgTime := Copy(Msg, 1, Pos('|', Msg) - 1);
  Delete(Msg, 1, Pos('|', Msg));
  if Pos('|', Msg) = 0 then
    Exit;
  MsgIPAddr := Copy(Msg, 1, Pos('|', Msg) - 1);
  Delete(Msg, 1, Pos('|', Msg));

  // local filter
  if MsgUser = sCurrentUser then
    Exit;

  FilterOut := False;
  // Project filter
  if ((NtfyFilter and ntfyOnlyCurrent) = ntfyOnlyCurrent) and
    (MsgProjectID <> ServerProjectID) then
    FilterOut := True;
  // Message filter
  // Connect
  if (not FilterOut) and ((NtfyFilter and ntfyConctA) = ntfyConctA) and
    (MsgType = 1) then
    FilterOut := True;
  // Check In
  if (not FilterOut) and ((NtfyFilter and ntfyChckIn) = ntfyChckIn) and
    (MsgType = 2) then 
    FilterOut := True;
  // Check Out
  if (not FilterOut) and ((NtfyFilter and ntfyChckOut) = ntfyChckOut) and
    (MsgType = 3) then 
    FilterOut := True;
  if FilterOut then 
    Exit;

  if (NtfyFilter and ntfyBeep) = ntfyBeep then 
    Windows.Beep(500, 75);

  case MsgType of
    1, 2, 3 :
      if MsgProjectID > 0 then
        Msg := Msg + ' [' + IntToStr(MsgProjectID) + ']';
  end;
  AddMessage(MsgTime + ' > (' + MsgUser + ' - ' + MsgIPAddr + ') ' + Msg, msclNtfy);
  Inc(NtfyMsgCount);
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.acSendMessageExecute(Sender: TObject);
var 
  ModResult: Integer;
  SendResult: string;
begin
  NtfySendForm := TNtfySendForm.Create(Application);
  try
    ModResult := NtfySendForm.ShowModal;
    SendResult := NtfySendForm.ResultStr;
  finally
    NtfySendForm.Free;
  end;
  if ModResult = mrOk then 
    AddMessage(SendResult, msclNtfy);
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiInternalNotifyactiveClick(Sender: TObject);
begin
  mmiInternalNotifyactive.Checked := not mmiInternalNotifyactive.Checked;
  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'ProjMan_NotifyActive',
    mmiInternalNotifyactive.Checked);
  MessageBox(WindowHandle, PChar(JVCSRES_You_must_restart_the_IDE47_the_program_for_this_change_to_take_effect46 + #13#10 +
    JVCSRES_Sorry46), cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.AddMessage(MsgStr: string; const MsgCol: Word);
var
  MsgTextColor: TColor;
  LogFile: TextFile;
begin
  if Pos('AppSrvClient', MsgStr) <> 0 then
    IdentToColor(NtfyMsgTextColor, Longint(MsgTextColor))
  else
  begin
    if pmiIncludeTimestamp.Checked then
      MsgStr := '(' + DateTimeToStr(Now) + ') ' + MsgStr;
    case MsgCol of
      msclNormal :
        MsgTextColor := clWindowText;
      msclError:
        MsgTextColor := clRed;
      msclNtfy:
        IdentToColor(NtfyMsgTextColor, Longint(MsgTextColor));
      else
        MsgTextColor := clWindowText;
    end;
  end;
  with reMessage do
  begin
    SelAttributes.Color := MsgTextColor;
    Lines.Add(MsgStr);
    reMessage.Perform(EM_LINESCROLL, 0, 1);
  end; // with reMessage do begin
  if pmiLogtoFile.Checked then
  begin
    AssignFile(LogFile, sDLLDirectory + 'Client.log');
    try
      if FileExists(sDLLDirectory + 'Client.log') then
        Append(LogFile)
      else
        Rewrite(LogFile);
      WriteLn(LogFile, MsgStr);
      CloseFile(LogFile);
    except
      on E: Exception do
        reMessage.Lines.Add(JVCSRES_Log_file_access_error58_ +
          sDLLDirectory + 'Client.log' + E.Message);
    end;
  end; // if pmiLogtoFile.Checked then begin
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiCrossRefListClick(Sender: TObject);
begin
  bStopRefresh := True;
  VCSSelCrossRef := TVCSSelCrossRef.Create(Application);
  try
    VCSSelCrossRef.Top := Top + 60;
    VCSSelCrossRef.Left := Left + 60;
    VCSSelCrossRef.ShowModal;
  finally
    VCSSelCrossRef.Free;
  end;
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.CheckforBuildOK1Click(Sender: TObject);
begin
  bStopRefresh := True;
  VCSCheckfBuild := TVCSCheckfBuild.Create(Application);
  try
    VCSCheckfBuild.Top := Top + 60;
    VCSCheckfBuild.Left := Left + 60;
    VCSCheckfBuild.ShowModal;
  finally
    VCSCheckfBuild.Free;
  end;
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.Allprojects1Click(Sender: TObject);
var 
  ResultString: string;
  SumModules, SumBytes, SumCompBytes: Int64;
  Ratio: Integer;
begin
  bStopRefresh := True;
  ShowStatusBarGauge(True, True);
  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_SPACE_BY_PROJECTS';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    SetupTimeoutCounter;
    AppSrvClient1.Send;

    while WaitForAppSrvClient do 
      Application.ProcessMessages;
    if (AppSrvClientErr = -99) then 
    begin
      ShowStatusBarGauge(False, True);
      ShowServerTimeOut(WindowHandle);
      bStopRefresh := False;
      Exit;
    end;
    if (AppSrvClientErr <> 0) or
      (AppSrvClient1.AnswerStatus <> '200') then 
    begin
      ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
        AppSrvClient1.AnswerStatus);
      bStopRefresh := False;
      ShowStatusBarGauge(False, True);
      Exit;
    end;

    AppSrvClient1.Answer.First;
    SumModules := 0;
    SumBytes := 0;
    SumCompBytes := 0;
    ResultString := '';
    if AppSrvClient1.Answer.Eof then 
    begin
      ShowStatusBarGauge(False, True);
      MessageBox(Handle, PChar(Format(JVCSRES_There_were_no_37s_located_that_match_the_search_criteria46,
        [JVCSRES_records])), cMsgBoxCaption, MB_OK or
        MB_ICONINFORMATION);
      bStopRefresh := False;
      Exit;
    end; // if AppSrvClient1.Answer.EoF then begin
    while not AppSrvClient1.Answer.Eof do 
    begin
      SumModules := SumModules + StrToInt64Def(AppSrvClient1.Answer.Fields[1], 0);
      SumBytes := SumBytes + StrToInt64Def(AppSrvClient1.Answer.Fields[2], 0);
      SumCompBytes := SumCompBytes + StrToInt64Def(AppSrvClient1.Answer.Fields[3], 0);
      ResultString := ResultString + AppSrvClient1.Answer.Fields[0] + ';' +
        FormatFloat('#,', StrToInt64Def(AppSrvClient1.Answer.Fields[1], 0)) + ';' +
        FormatFloat('#,', StrToInt64Def(AppSrvClient1.Answer.Fields[2], 0)) + ';' +
        FormatFloat('#,', StrToInt64Def(AppSrvClient1.Answer.Fields[3], 0)) + ';' +
        DateTimeToStr(GMTStr2LocalDateTime(AppSrvClient1.Answer.Fields[4])) + ';|';
      AppSrvClient1.Answer.Next;
    end;
  end; // with DataModule1 do begin

  Ratio := Round((1 - (SumCompBytes / SumBytes)) * 100);

  ShowStatusBarGauge(False, True);

  VCSStdListView := TVCSStdListView.Create(Application);
  try
    VCSStdListView.LVRepID := 11;
    VCSStdListView.Caption := JVCSRES_Archive_space_45_all_projects;
    VCSStdListView.Left := Left + 60;
    VCSStdListView.Top := Top + 60;
    VCSStdListView.LVType := 0;
    VCSStdListView.HelpContextID := IDH_Count_space;
    VCSStdListView.AddTypedListColumn(JVCSRES_Project, vaString);
    VCSStdListView.AddTypedListColumn(JVCSRES_Revisions, vaInt64);
    VCSStdListView.AddTypedListColumn(JVCSRES_Modules_91Bytes93, vaInt64);
    VCSStdListView.AddTypedListColumn(JVCSRES_Zip_91Bytes93, vaInt64);
    VCSStdListView.AddTypedListColumn(JVCSRES_Last_write_access, vaDate);
    VCSStdListView.SetUpHint(Format(JVCSRES_SUM58_37s_Revisions44_37s_4037s41_Bytes44_37d_3737,
      [FormatFloat('#,', SumModules), FormatFloat('#,', SumBytes),
       FormatFloat('#,', SumCompBytes), Ratio]));
    VCSStdListView.SetUpItems(ResultString);
    VCSStdListView.ShowModal;
  finally
    VCSStdListView.Free;
  end;
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.Currentproject1Click(Sender: TObject);
var 
  SelectedProjectName, ResultString: string;
  SelectedProjectID, Ratio: Integer;
  SumModules, SumBytes, SumCompBytes: Int64;
begin
  if not GetArchiveProject(JVCSRES_count_space, SelectedProjectID, SelectedProjectName) then
    Exit;
  bStopRefresh := True;
  ShowStatusBarGauge(True, True);
  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_SPACE_BY_MODULES';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [SelectedProjectID]);
    SetupTimeoutCounter;
    AppSrvClient1.Send;

    while WaitForAppSrvClient do 
      Application.ProcessMessages;
    if (AppSrvClientErr = -99) then 
    begin
      ShowStatusBarGauge(False, True);    
      ShowServerTimeOut(WindowHandle);
      bStopRefresh := False;
      Exit;
    end;
    if (AppSrvClientErr <> 0) or
      (AppSrvClient1.AnswerStatus <> '200') then 
    begin
      ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
        AppSrvClient1.AnswerStatus);
      bStopRefresh := False;
      ShowStatusBarGauge(False, True);
      Exit;
    end;

    AppSrvClient1.Answer.First;
    SumModules := 0;
    SumBytes := 0;
    SumCompBytes := 0;
    ResultString := '';
    if AppSrvClient1.Answer.Eof then 
    begin
      ShowStatusBarGauge(False, True);
      MessageBox(Handle, PChar(Format(JVCSRES_There_were_no_37s_located_that_match_the_search_criteria46,
        [JVCSRES_records])), cMsgBoxCaption, MB_OK or
        MB_ICONINFORMATION);
      bStopRefresh := False;
      Exit;
    end; // if AppSrvClient1.Answer.EoF then begin
    while not AppSrvClient1.Answer.Eof do 
    begin
      SumModules := SumModules + StrToInt64Def(AppSrvClient1.Answer.Fields[1], 0);
      SumBytes := SumBytes + StrToInt64Def(AppSrvClient1.Answer.Fields[2], 0);
      SumCompBytes := SumCompBytes + StrToInt64Def(AppSrvClient1.Answer.Fields[3], 0);
      ResultString := ResultString + AppSrvClient1.Answer.Fields[0] + ';' +
        FormatFloat('#,', StrToInt64Def(AppSrvClient1.Answer.Fields[1], 0)) + ';' +
        FormatFloat('#,', StrToInt64Def(AppSrvClient1.Answer.Fields[2], 0)) + ';' +
        FormatFloat('#,', StrToInt64Def(AppSrvClient1.Answer.Fields[3], 0)) + ';' +
        DateTimeToStr(GMTStr2LocalDateTime(AppSrvClient1.Answer.Fields[4])) + ';|';
      AppSrvClient1.Answer.Next;
    end;
  end; // with DataModule1 do begin

  Ratio := Round((1 - (SumCompBytes / SumBytes)) * 100);
  ShowStatusBarGauge(False, True);

  VCSStdListView := TVCSStdListView.Create(Application);
  try
    VCSStdListView.LVRepID := 12;
    VCSStdListView.Caption := Format(JVCSRES_Archive_space_45_37s, [SelectedProjectName]);
    VCSStdListView.Left := Left + 60;
    VCSStdListView.Top := Top + 60;
    VCSStdListView.LVType := 0;
    VCSStdListView.HelpContextID := IDH_Count_space;
    VCSStdListView.AddTypedListColumn(JVCSRES_Module, vaString);
    VCSStdListView.AddTypedListColumn(JVCSRES_C_Files, vaInt64);
    VCSStdListView.AddTypedListColumn(JVCSRES_Files_91Bytes93, vaInt64);
    VCSStdListView.AddTypedListColumn(JVCSRES_Zip_91Bytes93, vaInt64);
    VCSStdListView.AddTypedListColumn(JVCSRES_Last_write_access, vaDate);
    VCSStdListView.SetUpHint(Format(JVCSRES_SUM58_37s_Files44_37s_4037s41_Bytes44_37d_3737,
      [FormatFloat('#,', SumModules), FormatFloat('#,', SumBytes),
       FormatFloat('#,', SumCompBytes), Ratio]));
    VCSStdListView.SetUpItems(ResultString);
    VCSStdListView.ShowModal;
  finally
    VCSStdListView.Free;
  end;
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

function TVCSProjAdmin.GetArchiveProject(const DlgCaption: string;
  var SelectedProjectID: Integer; var SelectedProjectName: string): Boolean;
var 
  DummyID: Integer;
begin
  bStopRefresh := True;
  Result := False;
  // Select a project
  VCSSelectProject := TVCSSelectProject.Create(Application);
  try
    VCSSelectProject.Top := Top + 60;
    VCSSelectProject.Left := Left + 60;
    VCSSelectProject.SetDlgCaption(DlgCaption);
    VCSSelectProject.DefaultID := ServerProjectID;
    VCSSelectProject.ShowModal;
    SelectedProjectID := VCSSelectProject.SelectedID;
    SelectedProjectName := VCSSelectProject.SelectedName;
  finally
    VCSSelectProject.Free;
  end;
  if SelectedProjectID <> 0 then 
  begin
    Check_Create_Project(SelectedProjectName, False, DummyID);
    Result := True;
  end;
  bStopRefresh := False;
  
  RefreshDispatcher.DispatchSimpleRefresh(rtRefresh);

end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.MoveModules1Click(Sender: TObject);
var
  SelectedProjectName: string;
  SelectedProjectID: Integer;
  Moved: Boolean;
begin
  if not GetArchiveProject(JVCSRES_Move_modules, SelectedProjectID,
    SelectedProjectName) then 
    Exit;
  bStopRefresh := True;
  VCSModMove := TVCSModMove.Create(Application);
  try
    VCSModMove.Top := Top + 60;
    VCSModMove.Left := Left + 60;
    VCSModMove.SelectedProjectID := SelectedProjectID;
    VCSModMove.ShowModal;
    Moved := VCSModMove.ModulesMoved;
  finally
    VCSModMove.Free;
  end;
  if sProjectName <> '' then
    Check_Create_Project(ExtractFileName(sProjectName), False, ServerProjectID);
  bStopRefresh := False;
  if Moved and (SelectedProjectID = ServerProjectID) then
    acRefreshModuleList(Self);
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.Showprojecttree1Click(Sender: TObject);
var
  SelectedProjectName: string;
  SelectedProjectID: Integer;
begin
  if not GetArchiveProject(JVCSRES_Project_tree, SelectedProjectID,
    SelectedProjectName) then 
    Exit;
  bStopRefresh := True;
  VCSProjectTree := TVCSProjectTree.Create(Application);
  try
    VCSProjectTree.SelectedProjectID := SelectedProjectID;
    VCSProjectTree.ShowModal;
  finally
    VCSProjectTree.Free;
  end;
  if sProjectName <> '' then
    Check_Create_Project(ExtractFileName(sProjectName), False, ServerProjectID);
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.ProjectHierarchy1Click(Sender: TObject);
begin
  bStopRefresh := True;
  VCSSelectProject := TVCSSelectProject.Create(Application);
  try
    VCSSelectProject.Top := Top + 60;
    VCSSelectProject.Left := Left + 60;
    VCSSelectProject.HierarchyOnly := True;
    VCSSelectProject.SetDlgCaption(JVCSRES_Project_Hierarchy);
    VCSSelectProject.DefaultID := ServerProjectID;
    VCSSelectProject.ShowModal;
  finally
    VCSSelectProject.Free;
  end;
  bStopRefresh := False;
  RefreshDispatcher.DispatchSimpleRefresh(rtRefresh);
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.RenameProject1Click(Sender: TObject);
var
  SelectedProjectName: string;
  SelectedProjectID: Integer;
begin
  try
    if GetArchiveProject(JVCSRES_Rename_project, SelectedProjectID,
      SelectedProjectName) then
    begin
      bStopRefresh := True;
      try
        // if have renamed actually opened project, close before rename
        if bProjectOpen and (SelectedProjectID = ServerProjectID) then
        begin
          mmiCloseProjectClick(Self);
        end;

        VCSRenameProj := TVCSRenameProj.Create(Application);
        try
          VCSRenameProj.Top := Top + 60;
          VCSRenameProj.Left := Left + 60;
          VCSRenameProj.SelectedProjectID := SelectedProjectID;
          VCSRenameProj.SelectedProjectName := SelectedProjectName;
          VCSRenameProj.ShowModal;
        finally
          VCSRenameProj.Free;
        end;
        if sProjectName <> '' then
          Check_Create_Project(ExtractFileName(sProjectName), False, ServerProjectID);
      finally
        bStopRefresh := False;
      end;
    end;
  finally
    acRefreshFormExecute(Self);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.PurgeProjects1Click(Sender: TObject);
var
  SelectedProjectName: string;
  SelectedProjectID: Integer;
begin
  try
    if GetArchiveProject(JVCSRES_Purge_project, SelectedProjectID,
      SelectedProjectName) then
    begin
      bStopRefresh := True;
      try
        VCSPurge := TVCSPurge.Create(Application);
        try
          VCSPurge.Top := Top + 60;
          VCSPurge.Left := Left + 60;
          VCSPurge.SelectedProj := SelectedProjectName;
          VCSPurge.SelectedProjID := SelectedProjectID;
          VCSPurge.ShowModal;
        finally
          VCSPurge.Free;
        end;
      finally
        bStopRefresh := False;
      end;
    end;
  finally
    acRefreshFormExecute(Self);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.RemoveProjects1Click(Sender: TObject);
var 
  SelectedProjectName: string;
  SelectedProjectID: Integer;
begin
  try
    if GetArchiveProject(JVCSRES_Remove_project, SelectedProjectID,
      SelectedProjectName) then
    begin
      bStopRefresh := True;
      try
        VCSRemoveProj := TVCSRemoveProj.Create(Application);
        try
          VCSRemoveProj.SelectedProject := SelectedProjectName;
          VCSRemoveProj.SelectedProjectID := SelectedProjectID;
          VCSRemoveProj.ShowModal;
        finally
          VCSRemoveProj.Free;
        end;
        if sProjectName <> '' then
          Check_Create_Project(ExtractFileName(sProjectName), False, ServerProjectID);
      finally
        bStopRefresh := False;
      end;
    end;
  finally
    acRefreshFormExecute(Self);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiAutorefreshClick(Sender: TObject);
begin
  mmiAutorefresh.Checked := not mmiAutorefresh.Checked;
  RefreshTimer.Enabled := mmiAutorefresh.Checked;
  jvcsWriteBool(sBaseRegistryKey + crbOptions, 'RefreshTimerEnabled',
    mmiAutorefresh.Checked);
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.GetArchiveTimeStamp(var TStamp: Double);
begin
  TStamp := 0;
  with DataModule1 do
  begin
    try
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_ARCHIVE_TSTAMP';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      SetupTimeoutCounter;
      AppSrvClient1.Send;

      while WaitForAppSrvClient do 
        Application.ProcessMessages;
      if (AppSrvClientErr = -99) then 
      begin
        BeepIfSet;
        AddMessage(JVCSRES_Server_request_timed_out46, msclError);
        Exit;
      end;
      if (AppSrvClientErr <> 0) or
        (AppSrvClient1.AnswerStatus <> '200') then 
      begin
        BeepIfSet;
        AddMessage(Format(JVCSRES_Auto_refresh_timer_45_Server_reports_error58_37s,
          [AppSrvClient1.AnswerStatus]), msclError);
        Exit;
      end;
    except
      on E: Exception do 
      begin
        BeepIfSet;
        AddMessage(Format(JVCSRES_Auto_refresh_timer_45_Server_exception58_37s,
          [E.Message]), msclError);
        Exit;
      end;
    end;
    AppSrvClient1.Answer.First;
    TStamp := GMTStr2LocalDateTime(AppSrvClient1.Answer.Fields[0]);
  end; // with DataModule1 do begin
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.RefreshTimerTimer(Sender: TObject);
var 
  ArchTS: Double;
begin
  if (not Visible) or bStopRefresh then 
    Exit;
  {$IFNDEF IDEDLL}
  if (not bProjectOpen) then 
    Exit;
  {$ELSE}
  if (not bProjectOpen) or (not Assigned(DataModule1)) then 
    Exit;
  {$ENDIF ~IDEDLL}
  GetArchiveTimeStamp(ArchTS);
  Screen.Cursor := crDefault;
  if ArchTStamp < ArchTS then 
    ArchTStamp := ArchTS 
  else 
    Exit;
  bPJM_NeedRefresh := True;
  acRefreshFormExecute(Self);
  SetMenuStateEx;
  SetStatusBar;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.acFileFamiliesExecute(Sender: TObject);
begin
  bStopRefresh := True;
  VCSMaintainFFamilies := TVCSMaintainFFamilies.Create(Application);
  try
    VCSMaintainFFamilies.Top := Top + 60;
    VCSMaintainFFamilies.Left := Left + 60;
    VCSMaintainFFamilies.ShowModal;
  finally
    VCSMaintainFFamilies.Free;
  end;
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.Showdesertedmodules1Click(Sender: TObject);
var 
  ResultString: string;
  ContainsRecords: Boolean;
begin
  bStopRefresh := True;
  ShowStatusBarGauge(True, True);
  ContainsRecords := False;
  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_DESERTED_MODULES';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    SetupTimeoutCounter;
    AppSrvClient1.Send;

    while WaitForAppSrvClient do 
      Application.ProcessMessages;
    if (AppSrvClientErr = -99) then 
    begin
      ShowStatusBarGauge(False, True);
      ShowServerTimeOut(WindowHandle);
      bStopRefresh := False;
      Exit;
    end;    
    if (AppSrvClientErr <> 0) or
      (AppSrvClient1.AnswerStatus <> '200') then 
    begin
      ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
        AppSrvClient1.AnswerStatus);
      bStopRefresh := False;
      ShowStatusBarGauge(False, True);
      Exit;
    end;

    AppSrvClient1.Answer.First;
    ResultString := '';
    while not AppSrvClient1.Answer.Eof do 
    begin
      ContainsRecords := True;
      ResultString := ResultString + AppSrvClient1.Answer.Fields[0] + ';' +
        AppSrvClient1.Answer.Fields[1] + ';' +
        AppSrvClient1.Answer.Fields[2] + ';|';
      AppSrvClient1.Answer.Next;
    end;
  end; // with DataModule1 do begin

  if not ContainsRecords then
  begin
    ShowStatusBarGauge(False, True);
    MessageBox(Handle, PChar(Format(JVCSRES_There_were_no_37s_located_that_match_the_search_criteria46,
      [JVCSRES_records])), cMsgBoxCaption, MB_OK or
      MB_ICONINFORMATION);
    bStopRefresh := False;
    Exit;
  end;

  ShowStatusBarGauge(False, True);

  VCSStdListView := TVCSStdListView.Create(Application);
  try
    VCSStdListView.LVRepID := 13;
    VCSStdListView.Caption := JVCSRES_Deserted_Modules;
    VCSStdListView.Left := Left + 60;
    VCSStdListView.Top := Top + 60;
    VCSStdListView.LVType := 1;
    VCSStdListView.HelpContextID := IDH_Deserted_modules;
    VCSStdListView.AddListColumn(JVCSRES_Modul_ID, True);
    VCSStdListView.AddListColumn(JVCSRES_Module, False);
    VCSStdListView.AddListColumn(JVCSRES_Path, False);
    VCSStdListView.SetUpItems(ResultString);
    VCSStdListView.ShowModal;
  finally
    VCSStdListView.Free;
  end;
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.acDescriptionExecute(Sender: TObject);
begin
  HandleDescription(2, _StrToInt(elvModules.Selected.SubItems[sitMID]),
    Format(JVCSRES_38Module58_37s, [elvModules.Selected.Caption]));
end;

procedure TVCSProjAdmin.acDiff1Execute(Sender: TObject);
var
  I, SelectedModuleID: Integer;
  SelectedModuleFileName, Extension: string;
begin
  SelectedModuleID := GetSelectedModuleID;
  SelectedModuleFileName := GetSelectedModuleName;
  if (SelectedModuleID > 0) and (SelectedModuleFileName <> '') and
    (FCurrentModuleFileNames.Count > 0) and (FCurrentModuleFileNames[0] = SelectedModuleFileName) then
  begin
    Extension := '';
    for I := 0 to Pred(FCurrentModuleFileNames.Count) do
      if Sender = FCurrentModuleFileNames.Objects[I] then
      begin
        Extension := ExtractFileExt(FCurrentModuleFileNames[I]);
        Break;
      end;
    if Extension <> '' then
      ShowCompressDiffDialogLocalToLatest(ChangeFileExt(SelectedModuleFileName, Extension), Extension, SelectedModuleID);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiProjectDescriptionClick(Sender: TObject);
begin
  HandleDescription(1, ServerProjectID, Format(JVCSRES_38Project58_37s,
    [ExtractFileName(sProjectName)]));
end;

procedure TVCSProjAdmin.mmiRemoveBranchClick(Sender: TObject);
{$IFDEF BRANCHING}
var
  BranchID: Integer;
  RemoveBranch: TJVCSRemoveBranch;
  BranchName: string;
{$ENDIF BRANCHING}
begin
  {$IFDEF BRANCHING}
  BranchID := SelectBranch(bsmRemove, BranchName);
  if (BranchID <> -1) and NoYesWarnMessageBox(Format(JVCSRES_Remove_branch_6037s6263, [BranchName]) + #13 +
    JVCSRES_Removing_the_branch_from_the_version_archive_will_remove_all_revisions_checked_in_in_this_branch46 + #13 +
    JVCSRES_Warning33_This_process_is_not_reversible46 + #13 +
    JVCSRES_Are_you_sure_you_want_to_do_this63) then
  begin
    RemoveBranch := TJVCSRemoveBranch.Create(nil);
    try
      RemoveBranch.BranchID := BranchID;
      //TODO: Better progress
      VCSWaitforServer := TVCSWaitforServer.Create(Application);
      try
        VCSWaitforServer.Show;
        DataModule1.ClientObjectSendRequest(RemoveBranch);
      finally
        VCSWaitforServer.Free;
      end;
      if RemoveBranch.Removed then
        InfoMessageBox(Format(JVCSRES_Branch_6037s62_successfully_removed46, [BranchName]))
      else
        ErrorMessageBox(Format(JVCSRES_Branch_6037s62_removal_failed46, [BranchName]) + #13 + RemoveBranch.ErrorMessage);
    finally
      RemoveBranch.Free;
    end;
  end;
  {$ENDIF BRANCHING}
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.HandleDescription(const DescType, ID: Integer;
  const DescCaption: string);
var 
  Description: string;
  ModRes: Integer;
begin
  bStopRefresh := True;
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
      bStopRefresh := False;
      Exit;
    end;
    if (AppSrvClientErr <> 0) or
      (AppSrvClient1.AnswerStatus <> '200') then 
    begin
      ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
        AppSrvClient1.AnswerStatus);
      bStopRefresh := False;
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
      ModRes := VCSDescription.ModRes;
      Description := VCSDescription.Description;
    finally
      VCSDescription.Free;
    end;
    if ModRes <> mrOk then 
    begin
      bStopRefresh := False;
      Exit;
    end;

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
  end; // with DataModule1 do begin
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiShowLocalInfoClick(Sender: TObject);
begin
  mmiShowLocalInfo.Checked := not mmiShowLocalInfo.Checked;
  jvcsWriteBool(sBaseRegistryKey + crbOptions, 'ShowLocalInfo',
    mmiShowLocalInfo.Checked);
  UseRegistry := True;
  DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
  if DSAIdentsMessageDlg(JVCSRES_Parameters_changed46_Refresh_View63
    , mtConfirmation
    , [mbYes, mbNo, mbCancel]
    , 0
    , sBaseRegistryKey + crbMRU + 'Dlgs'
    , 'RefreshView'
    , idYes
    ) <> idYes then 
    Exit;
  acRefreshModuleList(Self);
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiShowhiddenmodulesClick(Sender: TObject);
begin
  mmiShowhiddenmodules.Checked := not mmiShowhiddenmodules.Checked;
  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'ProjMan_ShowHiddenModules',
    mmiShowhiddenmodules.Checked);
  UseRegistry := True;
  DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
  if DSAIdentsMessageDlg(JVCSRES_Parameters_changed46_Refresh_View63
    , mtConfirmation
    , [mbYes, mbNo, mbCancel]
    , 0
    , sBaseRegistryKey + crbMRU + 'Dlgs'
    , 'RefreshView'
    , idYes
    ) <> idYes then 
    Exit;
  acRefreshModuleList(Self);
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.pmiLogtoFileClick(Sender: TObject);
begin
  pmiLogtoFile.Checked := not pmiLogtoFile.Checked;
  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'ProjMan_LogMsg2File',
    pmiLogtoFile.Checked);
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.pmiIncludeTimestampClick(Sender: TObject);
begin
  pmiIncludeTimestamp.Checked := not pmiIncludeTimestamp.Checked;
  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'ProjMan_IncludeTimeStamp',
    pmiIncludeTimestamp.Checked);
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiUserlistClick(Sender: TObject);
begin
  bStopRefresh := True;
  VCSMaintainUsers := TVCSMaintainUsers.Create(Application);
  try
    VCSMaintainUsers.Left := Left + 60;
    VCSMaintainUsers.Top := Top + 60;
    VCSMaintainUsers.ShowModal;
  finally
    VCSMaintainUsers.Free;
  end;
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiServeroptionsClick(Sender: TObject);
begin
  bStopRefresh := True;
  VCSServerOptions := TVCSServerOptions.Create(Application);
  try
    VCSServerOptions.Left := Left + 60;
    VCSServerOptions.Top := Top + 60;
    VCSServerOptions.ShowModal;
  finally
    VCSServerOptions.Free;
  end;
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.acWhoamiExecute(Sender: TObject);
begin
  if ServerUserID < 1 then 
    Exit;
  bStopRefresh := True;
  VCSWhoami := TVCSWhoami.Create(Application);
  try
    VCSWhoami.ShowModal;
  finally
    VCSWhoami.Free;
  end;
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.elvModulesDblClick(Sender: TObject);
var 
  DblClickAction: Integer;
begin
  if bStopRefresh or (elvModules.Selected = nil) then
    Exit;
  DblClickAction :=
    jvcsReadInteger(sBaseRegistryKey + crbOptions, 'PMDoubleClick', 0);
  if (DblClickAction < 1) then
  begin
    case MessageBox(WindowHandle, PChar(JVCSRES_You_do_not_have_a_double_click_action_defined46 + #13#10 +
      JVCSRES_Would_you_like_to_do_this_now63), cMsgBoxCaption,
      MB_YESNOCANCEL or MB_ICONQUESTION) of
      id_Yes :
        begin
          bStopRefresh := True;
          VCSOptions := TVCSOptions.Create(Application);
          try
            VCSOptions.DefaultSheet := cspInterface;
            VCSOptions.ShowModal;
          finally
            VCSOptions.Free;
          end;
          GetVCSOptions;
          bStopRefresh := False;
        end;
      else
        Exit;
    end;
  end;
  DblClickAction :=
    jvcsReadInteger(sBaseRegistryKey + crbOptions, 'PMDoubleClick', 0);
  case DblClickAction of
    1:
      acLoadModulesExecute(Self);
    2:
      acCheckInExecute(Self);
    3:
      acCheckOutExecute(Self);
    4:
      acModInfoExecute(Self);
    5:
      acCompareExecute(Self);
    6:
      acHistoryExecute(Self);
    7:
      acKeyAdminExecute(Self);
    8:
      acOpenParentFolderExecute(Self);
    else
      Exit;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiSearchmodulesClick(Sender: TObject);
begin
  bStopRefresh := True;
  VCSSearchModules := TVCSSearchModules.Create(Application);
  try
    VCSSearchModules.Left := Left + 60;
    VCSSearchModules.Top := Top + 60;
    VCSSearchModules.ShowModal;
    {$IFNDEF IDEDLL}
    if VCSSearchModules.OpenProjectSelected then
      OpenProject(VCSSearchModules.SelectedProjectID, VCSSearchModules.SelectedProjectName)
    else
    {$ENDIF ~IDEDLL}
    if VCSSearchModules.ShowLineHistorySelected then
      ShowLineHistory(VCSSearchModules.SelectedModuleName);
  finally
    VCSSearchModules.Free;
  end;
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.acViewArchiveVersionExecute(Sender: TObject);
var 
  I, FuncRes: Integer;
  TargetFile, Module, AffectedFiles, TMPDirectory, ErrMsg, Mess: string;
begin
  if not ArchivedModuleSelected then 
    Exit;
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

  Module := elvModules.Selected.Caption;
  TargetFile := TMPDirectory + Module;

  if FileExists(TargetFile) then 
  begin
    UseRegistry := True;
    DontShowMsgText := JVCSRES_38Delete_without_prompting_from_now_on46;
    if DSAIdentsMessageDlg(Format(JVCSRES_There_is_already_a_file_6037s62_in
      + #13#10 + '<%s>.' + #13#10 +
      JVCSRES_Delete_the_file_to_show_the_latest_archive_version_of_6037s6263,
      [Module, TMPDirectory, Module])
      , mtConfirmation
      , [mbYes, mbNo, mbCancel]
      , 0
      , sBaseRegistryKey + crbMRU + 'Dlgs'
      , 'DeleteViewLatest'
      , idYes
      ) <> idYes then 
      Exit 
    else 
    begin
      FileSetAttr(TargetFile, FileGetAttr(TargetFile) and not $00000001);
      SysUtils.DeleteFile(TargetFile);
    end;
  end; // if FileExists(TargetFile) then begin

  bStopRefresh := True;
  FuncRes := GetBlobs(DBModule.GetJvcsConnection, ServerProjectID, ServerUserID,
    StrToInt(elvModules.Selected.SubItems[sitMID]),
    StrToInt(elvModules.Selected.SubItems[sitRID]),
    False{CheckOut}, Application, Self,
    True{SetReadOnly}, False{CloseIDEView},
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
      PChar(Format('<%s>' + #13#10 + JVCSRES_JEDI_VCS_is_unable_to_create_a_local_copy_of_this_file46 + #13#10 +
        JVCSRES_Exception58_37s_in_37s46_, [TargetFile, ErrMsg, Mess])),
      cMsgBoxCaption, MB_OK or MB_ICONSTOP);
    bStopRefresh := False;
    Exit;
  end // if FuncRes <> 0 then begin
  else //    LoadTheModule(TargetFile);
  if ViewTheModule(WindowHandle, TargetFile, Mess) then
    AddMessage(Mess, msclNormal);
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.Projectbasedrights1Click(Sender: TObject);
begin
  bStopRefresh := True;
  VCSProjectRights := TVCSProjectRights.Create(Application);
  try
    VCSProjectRights.Left := Left + 60;
    VCSProjectRights.Top := Top + 60;
    VCSProjectRights.ShowModal;
  finally
    VCSProjectRights.Free;
  end;
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.Changeserverpassword1Click(Sender: TObject);
var
  OldPassword, NewPassword: string;
  ServerTime: Double;
begin
  bStopRefresh := True;
  VCSChangeUserPW := TVCSChangeUserPW.Create(Application);
  try
    VCSChangeUserPW.Left := Left + 60;
    VCSChangeUserPW.Top := Top + 60;
    VCSChangeUserPW.User := sCurrentUser;
    VCSChangeUserPW.ShowModal;
    OldPassword := VCSChangeUserPW.OldPassword;
    NewPassword := VCSChangeUserPW.NewPassword;
  finally
    VCSChangeUserPW.Free;
  end;
  if OldPassword <> '' then 
  begin
    with DataModule1 do 
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_SERVER_TIME';
      AppSrvClient1.Request.WriteFields(True, [-1]);
      AppSrvClient1.Request.WriteFields(False, [-1]);
      SetupTimeoutCounter;
      AppSrvClient1.Send;

      while WaitForAppSrvClient do 
        Application.ProcessMessages;
      if (AppSrvClientErr = -99) then 
      begin
        ShowServerTimeOut(WindowHandle);
        bStopRefresh := False;
        Exit;
      end;
      if (AppSrvClientErr <> 0) or (AppSrvClient1.AnswerStatus <> '200') then 
      begin
        ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
          AppSrvClient1.AnswerStatus);
        bStopRefresh := False;
        Exit;
      end;

      AppSrvClient1.Answer.First;
      ServerTime := 0;
      if not AppSrvClient1.Answer.Eof then
        ServerTime := _StrToFloat(AppSrvClient1.Answer.Fields[0]);

      if LoadFVCSCrypt(sDLLDirectory + cCryptDLLName) then
      begin
        OldPassword := fvcsCliEncrypt2(OldPassword, ServerTime);
        NewPassword := fvcsCliEncrypt1(NewPassword);
      end
      else
      begin
        MessageBox(Application.Handle, PChar(Format(JVCSRES_Fatal_Error58_JEDI_VCS_cannot_load_the_library58
          + #13#10 + '<%s>.' + #13#10 + JVCSRES_Terminate_the_program44_make_sure_that_this_file_exists_in_the
          + #13#10 + JVCSRES_application_folder_and_retry46, [sDLLDirectory + cCryptDLLName])),
          cMsgBoxCaption, MB_OK or MB_ICONSTOP);
        bStopRefresh := False;
        Exit;
      end;
      { 
      DLLHandle := LoadLibrary(PChar(sDLLDirectory + 'FVCSCrypt.dll'));
      if DLLHandle = 0 then
      begin
        SysUtils.Beep;
        // Fatal Error: Unable to load library <%s>.
        MessageBox(Application.Handle, PChar(FmtLoadStr(36, 
          [sDLLDirectory + 'FVCSCrypt.dll'])), cMsgBoxCaption, MB_OK or MB_ICONSTOP);
        bStopRefresh := False;
        Exit;
      end;
      FuncPtr := GetProcAddress(DLLHandle, 'fvcs_Encrypt2');
      if FuncPtr <> nil then
      begin @fvcsEncrypt2 := FuncPtr;
        OldPassword := fvcsEncrypt2(OldPassword, ServerTime);
      end // if FuncPtr <> nil then begin
      else
      begin
        SysUtils.Beep;
        // Fatal Error: Unable to map the external procedure <%s>.
        MessageBox(Application.Handle, PChar(FmtLoadStr(37, ['fvcs_Encrypt2'])),
          'FVCSCrypt.dll', MB_OK or MB_ICONSTOP);
        FreeLibrary(DLLHandle);
        bStopRefresh := False;
        Exit;
      end; // else if FuncPtr <> nil then begin
      FuncPtr := GetProcAddress(DLLHandle, 'fvcs_Encrypt1');
      if FuncPtr <> nil then
      begin @fvcsEncrypt1 := FuncPtr;
        NewPassword := fvcsEncrypt1(NewPassword);
      end // if FuncPtr <> nil then begin
      else
      begin
        SysUtils.Beep;
        // Fatal Error: Unable to map the external procedure <%s>.
        MessageBox(Application.Handle, PChar(FmtLoadStr(37, ['fvcs_Encrypt1'])),
          'FVCSCrypt.dll', MB_OK or MB_ICONSTOP);
        FreeLibrary(DLLHandle);
        bStopRefresh := False;
        Exit;
      end; // else if FuncPtr <> nil then begin
      FreeLibrary(DLLHandle);
       }

      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'CHANGE_PASSWORD';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(False, [OldPassword]);
      AppSrvClient1.Request.WriteFields(False, [NewPassword]);
      SetupTimeoutCounter;
      AppSrvClient1.Send;

      while WaitForAppSrvClient do 
        Application.ProcessMessages;
      if (AppSrvClientErr = -99) then 
      begin
        ShowServerTimeOut(WindowHandle);
        bStopRefresh := False;
        Exit;
      end;
      if (AppSrvClientErr <> 0) or
        (AppSrvClient1.AnswerStatus <> '200') then 
      begin
        ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
          AppSrvClient1.AnswerStatus);
        bStopRefresh := False;
        Exit;
      end;

      if DecodeBoolStr(AppSrvClient1.Answer.Fields[0]) then 
      begin
        MessageBox(Handle, PChar(JVCSRES_Password_successfully_changed46), cMsgBoxCaption,
          MB_OK or MB_ICONINFORMATION);
      end 
      else 
      begin
        BeepIfSet;
        MessageBox(Handle, PChar(AppSrvClient1.Answer.Fields[1]), cMsgBoxCaption,
          MB_OK or MB_ICONSTOP);
      end;
    end; // with DataModule1 do begin
  end; // if OldPassword <> '' then begin
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.Definemilestones1Click(Sender: TObject);
begin
  bStopRefresh := True;
  VCSAssignMilestones := TVCSAssignMilestones.Create(Application);
  try
    VCSAssignMilestones.Left := Left + 60;
    VCSAssignMilestones.Top := Top + 60;
    VCSAssignMilestones.ShowModal;
  finally
    VCSAssignMilestones.Free;
  end;
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.Deletedprojects1Click(Sender: TObject);
var 
  ResultString: string;
  ContainsRecords: Boolean;
begin
  bStopRefresh := True;
  ShowStatusBarGauge(True, True);
  ContainsRecords := False;
  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_PROJECT_LIST';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(False, ['']);
    AppSrvClient1.Request.WriteFields(True, [True]); // incl. details
    SetupTimeoutCounter;
    AppSrvClient1.Send;

    while WaitForAppSrvClient do 
      Application.ProcessMessages;
    if (AppSrvClientErr = -99) then 
    begin
      ShowStatusBarGauge(False, True);
      ShowServerTimeOut(WindowHandle);
      bStopRefresh := False;
      Exit;
    end;    
    if (AppSrvClientErr <> 0) or
      (AppSrvClient1.AnswerStatus <> '200') then 
    begin
      ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
        AppSrvClient1.AnswerStatus);
      bStopRefresh := False;
      ShowStatusBarGauge(False, True);
      Exit;
    end;

    ResultString := '';
    AppSrvClient1.Answer.First;
    while not AppSrvClient1.Answer.Eof do
    begin
      if AppSrvClient1.Answer.Fields[2] = '1' then 
      begin
        ContainsRecords := True;
        ResultString := ResultString + AppSrvClient1.Answer.Fields[0] + ';' +
          AppSrvClient1.Answer.Fields[1] + ';' +
          AppSrvClient1.Answer.Fields[3] + ';|';
      end; // if AppSrvClient1.Answer.Fields[2] <> '1' then begin
      AppSrvClient1.Answer.Next;
    end;
  end; // with DataModule1 do begin

  if not ContainsRecords then 
  begin
    ShowStatusBarGauge(False, True);
    MessageBox(Handle, PChar(Format(JVCSRES_There_were_no_37s_located_that_match_the_search_criteria46,
      [JVCSRES_records])), cMsgBoxCaption, MB_OK or
      MB_ICONINFORMATION);
    bStopRefresh := False;
    Exit;
  end;

  ShowStatusBarGauge(False, True);

  VCSStdListView := TVCSStdListView.Create(Application);
  try
    VCSStdListView.LVRepID := 14;
    VCSStdListView.Caption := JVCSRES_Deleted_Projects;
    VCSStdListView.Left := Left + 60;
    VCSStdListView.Top := Top + 60;
    VCSStdListView.MaxWidth := Width - 60;
    VCSStdListView.LVType := 2;
    VCSStdListView.HelpContextID := IDH_Restore_deleted_projects;
    VCSStdListView.AddListColumn(JVCSRES_Project_ID, True);
    VCSStdListView.AddListColumn(JVCSRES_Project, False);
    VCSStdListView.AddListColumn(JVCSRES_History, False);
    VCSStdListView.SetUpItems(ResultString);
    VCSStdListView.ShowModal;
  finally
    VCSStdListView.Free;
  end;
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiNewProjectClick(Sender: TObject);
{$IFNDEF IDEDLL}
var
  NewProject: string;
{$ENDIF ~IDEDLL}
begin
  {$IFNDEF IDEDLL}
  bStopRefresh := True;
  VCSOpenProject := TVCSOpenProject.Create(Application);
  try
    VCSOpenProject.Left := Left + 60;
    VCSOpenProject.Top := Top + 60;
    VCSOpenProject.ShowModal;
    NewProject := VCSOpenProject.NewProjectName;
  finally
    VCSOpenProject.Free;
  end;
  if NewProject <> '' then
  begin
    bStopRefresh := False;
    if bProjectOpen then
      mmiCloseProjectClick(Self);

    with DataModule1 do
    begin
      //--- get project ID -----------------------------------------------------
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_PROJECT_ID';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [ExtractFileName(NewProject)]);
      SetupTimeoutCounter;
      AppSrvClient1.Send;

      while WaitForAppSrvClient do
        Application.ProcessMessages;
      if (AppSrvClientErr = -99) then
      begin
        ShowServerTimeOut(WindowHandle);
        bStopRefresh := False;
        Exit;
      end;
      if (AppSrvClientErr <> 0) or
        (AppSrvClient1.AnswerStatus <> '200') then
      begin
        ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
          AppSrvClient1.AnswerStatus);
        bStopRefresh := False;
        Exit;
      end;

      AppSrvClient1.Answer.First;
      if AppSrvClient1.Answer.Fields[0] <> '0' then
      begin
        // known project
        TransactionNr := _StrToInt(AppSrvClient1.Answer.Fields[2]);
        MessageBox(WindowHandle,
          PChar(Format(JVCSRES_Server_reports_an_already_known_project_name_6037s6246 + #13#10 +
            JVCSRES_Probably_there_is_a__formerly_deleted_project_with_the_same_name_in_the_version_archive46 + #13#10 +
            JVCSRES_Check_34Server124Deleted_Projects34_and_restore_the_project_or_select_a_different_name46,
            [ExtractFileName(NewProject)])),
          cMsgBoxCaption, MB_OK or MB_ICONWARNING);
        bStopRefresh := False;
        Exit;
      end 
      else 
      begin
        // unknown project
        TransactionNr := _StrToInt(AppSrvClient1.Answer.Fields[2]);
      end; // else if AppSrvClient1.Answer.Fields[0] <> '0' then
    end; // with DataModule1 do begin

    sProjectName := NewProject;
    bProjectOpen := True;
    ServerProjectID := -1;
    acRefreshFormExecute(Self);
    SetMenuStateEx;
    SetStatusBar;
  end 
  else
    bStopRefresh := False;
  {$ENDIF ~IDEDLL}
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiOpenProjectClick(Sender: TObject);
{$IFNDEF IDEDLL}
var
  SelectedProjectName: string;
  SelectedProjectID: Integer;
{$ENDIF ~IDEDLL}
begin
  {$IFNDEF IDEDLL}
  if not GetArchiveProject('Open', SelectedProjectID, SelectedProjectName) then
    Exit;
  OpenProject(SelectedProjectID, SelectedProjectName);
  {$ENDIF ~IDEDLL}
end;

{$IFNDEF IDEDLL}
procedure TVCSProjAdmin.OpenFavoriteProjectClick(Sender: TObject);
begin
  if Sender is TAction then
    with TAction(Sender) do
      if (Tag > 0) then
        OpenProject(Tag, Caption);
end;
{$ENDIF ~IDEDLL}

procedure TVCSProjAdmin.OpenProject(SelectedProjectID: Integer; SelectedProjectName: string);
{$IFNDEF IDEDLL}
var
  SendMessages, AutoSync: Boolean;
  NeedRefresh: Boolean;
{$ENDIF ~IDEDLL}
begin
  {$IFNDEF IDEDLL}
  if not OpenProjectBusy then
    try
      OpenProjectBusy := True;
      mmiOpenProject.Enabled := False;
      mmiOpenRecentProject.Enabled := False;
      mmiFavorites.Enabled := False;
      if bProjectOpen then
        mmiCloseProjectClick(Self);
      bStopRefresh := True;
      sProjectName := SelectedProjectName;
      ServerProjectID := SelectedProjectID;
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
          '(to: All) ' + 'connected to: ' + ExtractFileName(sProjectName)]));
      end;
      // -- SMTP --
      if jvcsReadBool(sBaseRegistryKey + crbOptions, 'SMTPMessages', False) and
        jvcsReadBool(sBaseRegistryKey + crbOptions, 'MessConnect', False) then
        PrepareSMTP(sCurrentUser, LocalIPAddr, '*All*', 'FVCS Notify',
          ExtractFileName(sProjectName), 'connected to: ' +
          ExtractFileName(sProjectName), 1);
      // -- SMTP --
      // Time log

      if jvcsReadBool(sBaseRegistryKey + crbTimeLog,
        ExtractFileName(sProjectName), False) then
      begin
        mmiActive.Checked := True;
        WriteTimeLog( sConfigFolder + ChangeFileExt(ExtractFileName(sProjectName), '.tlg')
                    , 'open;' + sCurrentUser + ';' + FloatToStr(Now)
                    );
      end
      else
        mmiActive.Checked := False;
      bProjectOpen := True;
      bStopRefresh := False;
      acRefreshModuleList(Self);
      SetMenuStateEx;
      mmiOpenProject.Enabled := False;
      mmiOpenRecentProject.Enabled := False;
      mmiFavorites.Enabled := False;
      SetStatusBar;
      bStopRefresh := True;

      if not SettingIsGlobal(12) then
        AutoSync :=
          jvcsReadBool(sBaseRegistryKey + crbOptions, 'AutoSync', False)
      else
        AutoSync := GlobalSettingValue(12);
      if AutoSync then
      begin
        UseRegistry := True;
        DontShowMsgText := JVCSRES_38Synchronize_without_prompting_from_now_on46;
        if DSAIdentsMessageDlg(Format(JVCSRES_Synchronize_6037s62_with_the_latest_version_archive_state63,
          [ExtractFileName(sProjectName)])
          , mtConfirmation
          , [mbOK, mbCancel]
          , 0
          , sBaseRegistryKey + crbMRU + 'Dlgs'
          , 'AutoSync'
          , idOk
          ) = idOk then
        begin
          VCSSync := TVCSSync.Create(Application);
          try
            VCSSync.AutoClose := True;
            VCSSync.ShowModal;
            NeedRefresh := VCSSync.NeedRefresh;
          finally
            VCSSync.Free;
          end;
          bStopRefresh := False;
          if NeedRefresh then
          begin
            acRefreshModuleList(Self);
            SetMenuStateEx;
          end;
        end;
      end; // if AutoSync then
    finally
      bStopRefresh := False;
      mmiOpenProject.Enabled := True;
      mmiOpenRecentProject.Enabled := True;
      mmiFavorites.Enabled := True;
      ReadFavorites;

      RefreshDispatcher.DispatchSimpleRefresh(rtSelectedProjectChanged);
      RefreshDispatcher.DispatchSimpleRefresh(rtSelectedModuleChanged);

      OpenProjectBusy := False;
    end;
  {$ENDIF ~IDEDLL}
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiCloseProjectClick(Sender: TObject);
{$IFNDEF IDEDLL}
var
  BackUpFlag, SendMessages: Boolean;
{$ENDIF ~IDEDLL}
begin
  {$IFNDEF IDEDLL}
  RefreshDispatcher.DispatchSimpleRefresh(rtProjectClosing);
  if (ServerUserID > 0) then
  begin
    //??? GlobalSettings
    if not SettingIsGlobal(8) then
      BackUpFlag :=
        jvcsReadBool(sBaseRegistryKey + crbOptions, 'BackupActive', False)
    else
      BackUpFlag := GlobalSettingValue(8);

    if BackUpFlag then
    begin
      bStopRefresh := True;
      VCSBackup := TVCSBackup.Create(Application);
      VCSBackup.BackupProjectName := sProjectName;
      VCSBackup.AutoBackup := True;
      try
        VCSBackup.ShowModal;
      finally
        VCSBackup.Free;
      end;
      bStopRefresh := False;
    end; // if BackUpFlag then begin
  end; // if if (ServerUserID > 0) then begin
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
      '(to: All) ' + 'disconnect from: ' + ExtractFileName(sProjectName)]));
  end;
  // -- SMTP --
  if jvcsReadBool(sBaseRegistryKey + crbOptions, 'SMTPMessages', False) and
    jvcsReadBool(sBaseRegistryKey + crbOptions, 'MessDisConnect', False) then
    PrepareSMTP(sCurrentUser, LocalIPAddr, '*All*', 'FVCS Notify',
      ExtractFileName(sProjectName), 'disconnect from: ' +
      ExtractFileName(sProjectName), 2);
  // -- SMTP --
  // Time log
  if jvcsReadBool(sBaseRegistryKey + crbTimeLog, ExtractFileName(sProjectName),
    False) then
  begin
    mmiActive.Checked := True;
    WriteTimeLog( sConfigFolder + ChangeFileExt(ExtractFileName(sProjectName), '.tlg')
                , 'close;' + sCurrentUser + ';' + FloatToStr(Now)
                );
  end
  else
    mmiActive.Checked := False;
  // Message Window
  AddMessage(Format(JVCSRES_Project_closed58_37s, [ExtractFileName(sProjectName)]), msclNormal);
  sProjectName := '';
  uilPluginManager1.SendMessage(pimsgFVCSProject, '');
  ServerProjectID := -1;
  bProjectOpen := False;
  elvModules.BeginUpdate;
  try
    elvModules.Items.Clear;
  finally
    elvModules.EndUpdate;
  end;
  SetMenuStateEx;
  SetStatusBar;
  ReadFavorites;
  {$ENDIF ~IDEDLL}
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiConnectserverClick(Sender: TObject);
{$IFNDEF IDEDLL}
var
  ServerLoc: string;
  SendMessages: Boolean;
{$ENDIF ~IDEDLL}
begin
  {$IFNDEF IDEDLL}
  bStopRefresh := True;
  try
    VCSLoad := TVCSLoad.Create(Application);
    try
      VCSLoad.ShowModal;
    finally
      VCSLoad.Free;
    end;
    // is connection established?
    if ServerUserID > 0 then
    begin
      mmiConnectserver.Enabled := False;
      mmiDisconnectserver.Enabled := True;
      uilPluginManager1.SendMessage(pimsgServerInfo, sArchiveSource);
      uilPluginManager1.SendMessage(pimsgClientInfo, sProductVer + cProductInf);
      // Access Level
      with DataModule1 do
      begin
        AppSrvClient1.Request.Rewrite;
        AppSrvClient1.FunctionCode := 'WHOAMI';
        AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
        AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
        SetupTimeoutCounter;
        AppSrvClient1.Send;

        while WaitForAppSrvClient do
          Application.ProcessMessages;
        if (AppSrvClientErr = -99) then
        begin
          ShowServerTimeOut(WindowHandle);
          bStopRefresh := False;
          Exit;
        end;
        if (AppSrvClientErr <> 0) or
          (AppSrvClient1.AnswerStatus <> '200') then
        begin
          ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
            AppSrvClient1.AnswerStatus);
          bStopRefresh := False;
          Exit;
        end;

        AppSrvClient1.Answer.First;
        if not AppSrvClient1.Answer.Eof then
        begin
          case _StrToInt(AppSrvClient1.Answer.Fields[2]) of
            0:
              dfsStatusBar.Panels[6].Text := JVCSRES_Guest;
            1:
              dfsStatusBar.Panels[6].Text := JVCSRES_read45only;
            2:
              dfsStatusBar.Panels[6].Text := JVCSRES_read45write;
            3:
              dfsStatusBar.Panels[6].Text := JVCSRES_Project_Admin;
            4:
              dfsStatusBar.Panels[6].Text := JVCSRES_Archive_Admin;
          end; // case GrantedRights of
        end;
      end; // with DataModule1 do begin
      UserCurrentProject1.Caption := Format(JVCSRES_37s47_Current_Project, [sCurrentUser]);
      UserAllprojects1.Caption := Format(JVCSRES_37s47_All_Projects, [sCurrentUser]);
      SetCaption;

      SetMenuStateEx;
      SetStatusBar;
      bStopRefresh := False;  //do not remove

      //The: need change due to 'Identies'
      ServerLoc := 'unknown...';  //TODO resource
      //Is there a GlobalSetting for all users regarding Sending Message about connect
      //TODO common function for connect/disconnect
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
          '(to: All) ' + 'connected to application server [' + ServerLoc + ']']));  //TODO resourcestring
      end;
      // -- SMTP --
      if jvcsReadBool(sBaseRegistryKey + crbOptions, 'SMTPMessages', False) and
        jvcsReadBool(sBaseRegistryKey + crbOptions, 'MessConnect', False) then
        PrepareSMTP(sCurrentUser, LocalIPAddr, '*All*', 'FVCS Notify', '*None*',
          'connected to application server [' + ServerLoc + ']', 1);                //TODO resourcestring
      // -- SMTP --

      FRefreshProjects.LoadSynchron;
      ReadFavorites;
      RefreshDispatcher.DispatchSimpleRefresh(rtConnected);
      ReadAndShowDockedWindows;
    end;  //if ServerUserID > 0
  finally
    bStopRefresh := False;
  end;
  {$ENDIF ~IDEDLL}
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiDisconnectserverClick(Sender: TObject);
{$IFNDEF IDEDLL}
var
  ServerLoc: string;
  SendMessages: Boolean;
{$ENDIF ~IDEDLL}
begin
  {$IFNDEF IDEDLL}
  RemoveLineHistoryPages;
  if bProjectOpen then
    mmiCloseProjectClick(Self);

  RefreshDispatcher.DispatchSimpleRefresh(rtDisconnected);

  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'LOGOUT';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [ServerUserID]);
    SetupTimeoutCounter;
    AppSrvClient1.Send;
    while WaitForAppSrvClient do
      Application.ProcessMessages;

    {if (AppSrvClientErr <> 0) or
       (AppSrvClient1.AnswerStatus <> '200') then begin
      ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
                                                    AppSrvClient1.AnswerStatus);
    end;}
  end; // with DataModule1 do begin
  ServerUserID := -1;
  {$IFDEF BRANCHING}
  ServerBranchID := 1;
  sBranchName := 'HEAD';
  nServerVersion := 100;
  {$ENDIF BRANCHING}
  SetMenuStateEx;
  SetStatusBar;
  edSearch.Text := '';
  sIdentityCaption := '';
  SetCaption;

  //The: need change due to 'Identies'
  ServerLoc := 'unknown...';    //TODO resourcestring
  //Is there a GlobalSetting for all users regarding Sending Message about disconnect?
  //TODO common function for connect/disconnect
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
      '(to: All) ' + 'disconnect from application server [' + ServerLoc + ']'])); //TODO resourcestring
  end;
  // -- SMTP --
  if jvcsReadBool(sBaseRegistryKey + crbOptions, 'SMTPMessages', False) and
    jvcsReadBool(sBaseRegistryKey + crbOptions, 'MessDisConnect', False) then
    PrepareSMTP(sCurrentUser, LocalIPAddr, '*All*', 'FVCS Notify', '*None*',
      'disconnect from application server [' + ServerLoc + ']', 2); //TODO resourcestring
  // -- SMTP --
  {$ENDIF ~IDEDLL}
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiFavAddCurrentProjectClick(Sender: TObject);
{$IFNDEF IDEDLL}
var
  FavoriteProjectList: TJVCSMruList;
  S: string;
{$ENDIF ~IDEDLL}
begin
  {$IFNDEF IDEDLL}
  S := CurrentIdentity;
  if (S <> '') and (sProjectName <> '') and Assigned(FRefreshProjects) then
  begin
    FavoriteProjectList := TJVCSMruList.CreateEx(sBaseRegistryKey + crbMRU + 'Favorites\' + S);
    try
      if FavoriteProjectList.IndexOf(sProjectName) < 0 then
      begin
        FavoriteProjectList.Mode := rmAppend;
        FavoriteProjectList.AddString(sProjectName);
        FavoriteProjectList.SaveToStorage(sBaseRegistryKey + crbMRU + 'Favorites\' + S);
        ReadFavorites;
      end;
    finally
      FavoriteProjectList.Free;
    end;
  end;
  {$ENDIF ~IDEDLL}
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.acSynchronizeExecute(Sender: TObject);
var
  NeedRefresh: Boolean;
begin
  if (ServerProjectID < 1) and
    (acSynchronize.Caption = JVCSRES_38Synchronize47_Restore464646) then
  begin
    acRefreshModuleList(Self);
    Exit;
  end;

  bStopRefresh := True;
  NeedRefresh := False;
  if NeedRefresh then ; //compilerhint
  VCSSync := TVCSSync.Create(Application);
  try
    VCSSync.AutoClose := False;
    VCSSync.ShowModal;
    NeedRefresh := VCSSync.NeedRefresh;
  finally
    VCSSync.Free;
  end;
  bStopRefresh := False;
  if NeedRefresh then
  begin
    acRefreshModuleList(Self);
    SetMenuStateEx;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiManageFavoritesClick(Sender: TObject);
begin
  {$IFNDEF IDEDLL}
  DoManageFavorites; // JVCSManageFavorites.pas
  {$ENDIF ~IDEDLL}
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiMergeClick(Sender: TObject);
begin
  bStopRefresh := True;
  VCSMerge := TVCSMerge.Create(Application);
  try
    VCSMerge.ShowModal;
  finally
    VCSMerge.Free;
  end;
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiVCSBrowserClick(Sender: TObject);
var
  I, Idx: Integer;
  tabSheet: TTabSheet;
  BrowserFrame: TJVCSBrowserFrm;
begin
  Idx := -1;
  for I := 1 to Pred(pgMain.PageCount) do
    if (pgMain.Pages[I].ControlCount > 0) and (pgMain.Pages[I].Controls[0] is TJVCSBrowserFrm) then
    begin
      Idx := I;
      Break;
    end;
  if Idx <> -1 then
    pgMain.ActivePageIndex := Idx
  else
  begin
    tabSheet := TTabSheet.Create(pgMain);
    tabSheet.PageControl := pgMain;
    tabSheet.Caption := JVCSRES_VCS_Browser;
    if pgMain.PageCount > 1 then
      tsDefault.TabVisible := True;
    BrowserFrame := TJVCSBrowserFrm.Create(tabSheet);
    BrowserFrame.Parent := tabSheet;
    BrowserFrame.Align := alClient;
    BrowserFrame.Connection := GetJvcsConnection;
    BrowserFrame.ProjectManager := GetIJVCSProjectManager;
    pgMain.ActivePage := tabSheet;
  end;
end;

procedure TVCSProjAdmin.mmiVCSpropertiesClick(Sender: TObject);
begin
  bStopRefresh := True;
  VCSOptions := TVCSOptions.Create(Application); // unit Options
  try
    VCSOptions.DefaultSheet := cspInterface;
    VCSOptions.ShowModal;
  finally
    VCSOptions.Free;
  end;
  GetVCSOptions;
  elvModules.Repaint;
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.AboutFreeVCS1Click(Sender: TObject);
begin
  VCSAbout := TVCSAbout.Create(Application); // unit About
  try
    VCSAbout.ShowModal;
  finally
    VCSAbout.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiBranchClick(Sender: TObject);
begin
  bStopRefresh := True;
  VCSBranch := TVCSBranch.Create(Application);
  try
    VCSBranch.ShowModal;
  finally
    VCSBranch.Free;
  end;
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.acCopy2ClipExecute(Sender: TObject);
var 
  ResultString: string;
begin
  ResultString := GetListViewString(False);
  if ResultString = '' then 
    Exit;

  VCSSimpleReport := TVCSSimpleReport.Create(Application);
  try
    VCSSimpleReport.RepID := 7;
    VCSSimpleReport.Left := Left + 60;
    VCSSimpleReport.Top := Top + 60;
    VCSSimpleReport.FullReportString := ResultString;
    VCSSimpleReport.SavePath := ExtractFileDir(sProjectName);
    VCSSimpleReport.SaveFileName := 'ModuleList.txt';
    VCSSimpleReport.LineCount := elvModules.Items.Count + 8;
    VCSSimpleReport.ShowModal;
  finally
    VCSSimpleReport.Free;
  end;
end;

procedure TVCSProjAdmin.mmiModuleListReportSelClick(Sender: TObject);
var
  ResultString: string;
begin
  ResultString := GetListViewString(True);
  if ResultString = '' then 
    Exit;

  VCSSimpleReport := TVCSSimpleReport.Create(Application);
  try
    VCSSimpleReport.RepID := 8;  
    VCSSimpleReport.Left := Left + 60;
    VCSSimpleReport.Top := Top + 60;
    VCSSimpleReport.FullReportString := ResultString;
    VCSSimpleReport.SavePath := ExtractFileDir(sProjectName);
    VCSSimpleReport.SaveFileName := 'ModuleList.txt';
    VCSSimpleReport.LineCount := elvModules.Items.Count + 8;
    VCSSimpleReport.ShowModal;
  finally
    VCSSimpleReport.Free;
  end;
end;

//------------------------------------------------------------------------------

function TVCSProjAdmin.GetListViewString(Sel: Boolean): string;
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
begin
  Result := '';
  Screen.Cursor := crHourGlass;
  try
    with elvModules do
    begin
      if (Items.Count = 0) or (Sel and (SelCount = 0)) then 
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

      Result := Caption + cr;
      CurrentText := '';
      while Length(CurrentText) < Length(Caption) do
        CurrentText := CurrentText + '=';
      Result := Result + CurrentText + cr + cr;
      if Sel then
        Result := Result + Format(JVCSRES_37d_selected_entries46, [SelCount]) + cr + cr
      else
        Result := Result + Format(JVCSRES_37d_entries46, [Items.Count]) + cr + cr;

      for J := 0 to Columns.Count - 1 do 
      begin
        Result := Result + SizeString(J, Columns[J].Caption, ' ');
        if J < (Columns.Count - 1) then 
          Result := Result + ' | ';
      end;
      Result := Result + cr;
      for J := 0 to Columns.Count - 1 do 
      begin
        Result := Result + SizeString(J, '-', '-');
        if J < (Columns.Count - 1) then 
          Result := Result + ' | ';
      end;
      Result := Result + cr;

      for I := 0 to Items.Count - 1 do 
      begin
        if Sel and (not Items[I].Selected) then
          Continue;

        for J := 0 to Columns.Count - 1 do 
        begin
          if J = 0 then 
            CurrentText := Items[I].Caption
          else 
            CurrentText := Items[I].SubItems[J - 1];
          Result := Result + SizeString(J, CurrentText, ' ');
          if J < (Columns.Count - 1) then 
            Result := Result + ' | ';
        end; // for J := 0 to Columns.Count - 1 do begin
        Result := Result + cr;
      end; // for I := 0 to Items.Count - 1 do begin
    end; // with elv do begin

    if not Sel then
      Result := Result + cr + dfsStatusBar.Panels[7].Text + cr;
    Result := Result + cr + JVCSRES_Source58_ + sArchiveSource + cr +
      JVCSRES_JEDI_VCS_ + sProductVer + cProductInf + DateTimeToStr(Now) + cr;
  finally
    Screen.Cursor := crDefault;
    SetLength(oaColumnsWidth, 0);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiMSManagerClick(Sender: TObject);
begin
  VCSMaintainMilestones := TVCSMaintainMilestones.Create(Application);
  try
    VCSMaintainMilestones.Left := Left + 60;
    VCSMaintainMilestones.Top := Top + 60;
    VCSMaintainMilestones.ShowModal;
  finally
    VCSMaintainMilestones.Free;
  end;
end;

//==============================================================================
// Taskbar icon - show the icon
// Maximum hint length = 63 characters!

{$IFNDEF IDEDLL}
procedure TVCSProjAdmin.ShowIcon(const Hint: string);
var 
  NIData: TNotifyIconData;
begin
  NIData.cbSize := SizeOf(NIData);
  NIData.Wnd := Handle;
  NIData.uID := 0;
  NIData.uCallbackMessage := WM_ICONCALLBACK;
  NIData.hIcon := FIcon.Handle;
  StrCopy(NIData.szTip, PChar(Hint));
  NIData.uFlags := NIF_MESSAGE or NIF_ICON or NIF_TIP;
  Shell_NotifyIcon(NIM_ADD, @NIData);
end;

//=== Taskbar icon - hide the icon =============================================

procedure TVCSProjAdmin.HideIcon;
var
  NIData: TNotifyIconData;
begin
  NIData.cbSize := SizeOf(NIData);
  NIData.Wnd := Handle;
  NIData.uID := 0;
  Shell_NotifyIcon(NIM_DELETE, @NIData);
end;

//=== Taskbar icon - icon (double click) callback procedure ====================

procedure TVCSProjAdmin.WMIconCallback(var Msg: TMessage);
begin
  if Msg.lParam = WM_LBUTTONDBLCLK then
  begin
    VCSProjAdmin.Show;
    VCSProjAdmin.BringToFront;
    HideIcon;
  end;
end;
{$ENDIF ~IDEDLL}

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.acHideAppExecute(Sender: TObject);
begin
  {$IFNDEF IDEDLL}
  ShowIcon(Caption);
  VCSProjAdmin.Hide;
  {$ENDIF ~IDEDLL}
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.elvModulesKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if shift = [] then
  begin
    if Key = VK_RETURN then
      elvModulesDblClick(Self);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.acBugManagerExecute(Sender: TObject);
begin
  bStopRefresh := True;
  VCSMaintainBugs := TVCSMaintainBugs.Create(Application);
  try
    VCSMaintainBugs.Left := Left + 60;
    VCSMaintainBugs.Top := Top + 60;
    VCSMaintainBugs.ShowModal;
  finally
    VCSMaintainBugs.Free;
  end;
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiProjectBugTrackingClick(Sender: TObject);
begin
  bStopRefresh := True;
  VCSAssignBugs := TVCSAssignBugs.Create(Application);
  try
    VCSAssignBugs.Left := Left + 60;
    VCSAssignBugs.Top := Top + 60;
    VCSAssignBugs.ModuleBased := False;
    VCSAssignBugs.ItemID := IntToStr(ServerProjectID);
    VCSAssignBugs.ItemName := ExtractFileName(sProjectName);
    VCSAssignBugs.ShowModal;
  finally
    VCSAssignBugs.Free;
  end;
  GetModuleBugs(False);
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.acModuleBugsExecute(Sender: TObject);
begin
  if not ArchivedModuleSelected then 
    Exit;
  bStopRefresh := True;
  VCSAssignBugs := TVCSAssignBugs.Create(Application);
  try
    VCSAssignBugs.Left := Left + 60;
    VCSAssignBugs.Top := Top + 60;
    VCSAssignBugs.ItemID := elvModules.Selected.SubItems[sitMID];
    VCSAssignBugs.ItemName := elvModules.Selected.Caption;
    VCSAssignBugs.ModuleBased := True;
    VCSAssignBugs.ShowModal;
  finally
    VCSAssignBugs.Free;
  end;
  GetModuleBugs(False);
  RefreshModules;
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.CompareFolders1Click(Sender: TObject);
begin
  bStopRefresh := True;
  VCSCompareFolders := TVCSCompareFolders.Create(Application);
  try
    VCSCompareFolders.ShowModal;
  finally
    VCSCompareFolders.Free;
  end;
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.UserCurrentProject1Click(Sender: TObject);
begin
  GetLockedModules(0);
end;

procedure TVCSProjAdmin.UserAllprojects1Click(Sender: TObject);
begin
  GetLockedModules(1);
end;

procedure TVCSProjAdmin.AllUsersCurrentProject1Click(Sender: TObject);
begin
  GetLockedModules(2);
end;

procedure TVCSProjAdmin.AllUsersAllProjects1Click(Sender: TObject);
begin
  GetLockedModules(3);
end;

procedure TVCSProjAdmin.GetLockedModules(QueryTyp: Integer);
var 
  ResultString: string;
  ContainsRecords: Boolean;
  LockedModules: Integer;
begin
  bStopRefresh := True;
  ShowStatusBarGauge(True, True);
  ContainsRecords := False;


  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_LOCKED_MODULES';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    case QueryTyp of
      0: 
        begin
          AppSrvClient1.Request.WriteFields(True, [ServerProjectID]);
          AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
        end;
      1: 
        begin
          AppSrvClient1.Request.WriteFields(True, [0]);
          AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
        end;
      2: 
        begin
          AppSrvClient1.Request.WriteFields(True, [ServerProjectID]);
          AppSrvClient1.Request.WriteFields(False, [0]);
        end;
      3: 
        begin
          AppSrvClient1.Request.WriteFields(True, [0]);
          AppSrvClient1.Request.WriteFields(False, [0]);
        end;
    end; // case

    SetupTimeoutCounter;
    AppSrvClient1.Send;

    while WaitForAppSrvClient do 
      Application.ProcessMessages;
    if (AppSrvClientErr = -99) then 
    begin
      ShowStatusBarGauge(False, True);
      ShowServerTimeOut(WindowHandle);
      bStopRefresh := False;
      Exit;
    end;
    if (AppSrvClientErr <> 0) or
      (AppSrvClient1.AnswerStatus <> '200') then 
    begin
      ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
        AppSrvClient1.AnswerStatus);
      bStopRefresh := False;
      ShowStatusBarGauge(False, True);
      Exit;
    end;
    AppSrvClient1.Answer.First;
    ResultString := '';
    LockedModules := 0;
    while not AppSrvClient1.Answer.Eof do 
    begin
      ContainsRecords := True;
      Inc(LockedModules);
      ResultString := ResultString + AppSrvClient1.Answer.Fields[1] + ';' +
        AppSrvClient1.Answer.Fields[0] + ';' +
        AppSrvClient1.Answer.Fields[3] + ';' +
        AppSrvClient1.Answer.Fields[4] + ';';
      case QueryTyp of
        2, 3: 
          begin
            ResultString := ResultString +
              DateTimeToStr(GMTStr2LocalDateTime(AppSrvClient1.Answer.Fields[5])) +
              ';' +
              AppSrvClient1.Answer.Fields[6] + ';|';
          end;
        else
          ResultString := ResultString +
            DateTimeToStr(GMTStr2LocalDateTime(AppSrvClient1.Answer.Fields[5])) + ';|';
      end; // case
      AppSrvClient1.Answer.Next;
    end;
  end; // with DataModule1 do begin

  if not ContainsRecords then 
  begin
    ShowStatusBarGauge(False, True);
    MessageBox(Handle, PChar(Format(JVCSRES_There_were_no_37s_located_that_match_the_search_criteria46,
      [JVCSRES_records])), cMsgBoxCaption, MB_OK or
      MB_ICONINFORMATION);
    bStopRefresh := False;
    Exit;
  end;

  ShowStatusBarGauge(False, True);

  VCSStdListView := TVCSStdListView.Create(Application);
  try
    VCSStdListView.LVRepID := 2000 + QueryTyp;
    case QueryTyp of
      0: 
        begin
          VCSStdListView.Caption := sCurrentUser + '/ ' + sProjectName;
          VCSStdListView.SetUpHint(Format(JVCSRES_37d_modules_locked_by_37s,
            [LockedModules, sCurrentUser]));
        end;
      1:
        begin
          VCSStdListView.Caption := Format(JVCSRES_37s47_All_Projects, [sCurrentUser]);
          VCSStdListView.SetUpHint(Format(JVCSRES_37d_modules_locked_by_37s,
            [LockedModules, sCurrentUser]));
        end;
      2: 
        begin
          VCSStdListView.Caption := Format(JVCSRES_All_Users47_37s, [sProjectName]);
          VCSStdListView.SetUpHint(Format(JVCSRES_37d_modules_locked_by_All_Users,
            [LockedModules]));
        end;
      3: 
        begin
          VCSStdListView.Caption := JVCSRES_All_Users47_All_projects;
          VCSStdListView.SetUpHint(Format(JVCSRES_37d_modules_locked_by_All_Users,
            [LockedModules]));
        end;
    end; // case
    VCSStdListView.Left := Left + 60;
    VCSStdListView.Top := Top + 60;
    VCSStdListView.LVType := 8;
    VCSStdListView.HelpContextID := 0;
    VCSStdListView.AddListColumn(JVCSRES_Modules_locked_by464646, False);
    VCSStdListView.AddListColumn(JVCSRES_ID, True);
    VCSStdListView.AddListColumn(JVCSRES_Version, True);
    VCSStdListView.AddListColumn(JVCSRES_Revision, True);
    VCSStdListView.AddListColumn(JVCSRES_Locked, False);
    case QueryTyp of
      2, 3:
        VCSStdListView.AddListColumn(JVCSRES_Owner, False);
    end; // case
    VCSStdListView.SetUpItems(ResultString);
    VCSStdListView.ShowModal;
    {$IFNDEF IDEDLL}
    if VCSStdListView.OpenProjectSelected then
      OpenProject(VCSStdListView.SelectedProjectID, VCSStdListView.SelectedProjectName)
    else
    {$ENDIF ~IDEDLL}
    if VCSStdListView.ShowLineHistorySelected then
      ShowLineHistory(VCSStdListView.SelectedModuleName);
  finally
    VCSStdListView.Free;
  end;
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.acOpenParentFolderExecute(Sender: TObject);
begin
  ShellOpenParentFolder(elvModules.Selected.SubItems[sitPath] + elvModules.Selected.Caption);
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.dfsStatusBarPanels5Click(Sender: TObject);
begin
  MessageBox(WindowHandle, PChar(Format(JVCSRES_37d_requests_transfered_37s_bytes_of_data_between_server_and_client46
    + #13#10 + JVCSRES_Log_in_time58_37s + #13#10 + JVCSRES_Log_started_at_37s46,
    [iServerReqCount, FormatFloat('#,', iServTraffic),
    GetUpTimeStr,
    DateTimeToStr(dServerLogin)])),
    PChar(JVCSRES_JEDI_VCS_Application_Server), MB_OK or MB_ICONINFORMATION);
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.elvModulesSortItems(Sender: TObject; Item1,
  Item2: TListItem; SortColumn: Integer; var SortAs: TSortAs;
  var CompResult: Integer);
var
  Str1, Str2, Str1Hi, Str2Hi: string;
begin
  case SortColumn of
    sitPath: // Path
      begin
        Str1 := Item1.SubItems[SortColumn];
        Str2 := Item2.SubItems[SortColumn];
        CompResult := AnsiCompareStr(Str1, Str2);
        if CompResult = 0 then
        begin
          //-- second criteria: use filename!
          Str1 := Item1.Caption;
          Str2 := Item2.Caption;
          CompResult := AnsiCompareStr(Str1, Str2);
        end;
      end;
    sitVer: // Ver
      begin
        Str1 := Item1.SubItems[SortColumn];
        Str2 := Item2.SubItems[SortColumn];
        if (Pos('.', Str1) > 0) and (Pos('.', Str2) > 0) then
        begin
          Str1Hi := Copy(Str1, 1, Pos('.', Str1) - 1);
          System.Delete(Str1, 1, Length(Str1Hi) + 1);
          Str2Hi := Copy(Str2, 1, Pos('.', Str2) - 1);
          System.Delete(Str2, 1, Length(Str2Hi) + 1);
          CompResult := AnsiCompareStr(Str1Hi, Str2Hi);
          if CompResult = 0 then
          begin
            while Length(Str1) < 5 do
              Str1 := '0' + Str1;
            while Length(Str2) < 5 do
              Str2 := '0' + Str2;
            CompResult := AnsiCompareStr(Str1, Str2);
          end;
        end
        else
          SortAs := saString;
      end;
    sitSize: // Size
      begin
        Str1 := Item1.SubItems[SortColumn];
        Str2 := Item2.SubItems[SortColumn];
        if (Str1 = Str2) then
        begin
          CompResult := 0;
          Exit;
        end;
        // remove all thousand separators
        Str1 := JclStrings.StrRemoveChars(Str1, [ThousandSeparator]);
        Str2 := JclStrings.StrRemoveChars(Str2, [ThousandSeparator]);
        if StrToInt64Def(Str1, 0) > StrToInt64Def(Str2, 0) then
          CompResult := 1
        else
          CompResult := -1;
      end;
    sitCount, sitMID, sitRID: // Count, MID, RID
      SortAs := saNumeric;
    sitDate: // Date
{ //USc 10.04.2004 using TdfsEnhListView's internal TDateTime sort is buggy - see mantis #1557
      SortAs := saDateTime;
}
      CompResult := CompareDateTimeStrs(Item1.SubItems[SortColumn], Item2.SubItems[SortColumn]);
    else // Name, State, Owner, Keyword, Share, Attr
      SortAs := saString;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.DirectSQL1Click(Sender: TObject);
begin
  UseRegistry := True;
  DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
  if DSAIdentsMessageDlg(JVCSRES_WARNING33_This_is_a_high45risk_function_and_not_recommended_for_beginners33 + #13#10 +
    JVCSRES_Inproper_use_of_direct_SQL_commands_may_cause_corrupted_archive_tables + #13#10 +
    JVCSRES_and47or_unreversible_loss_of_data33 + #13#10 +
    JVCSRES_Do_NOT_use_this_function_until_you_are_really_sure_what_you_are_doing33 + #13#10 +
    JVCSRES_You_have_been_warned33_Continue_anyway63
    , mtWarning
    , [mbYes, mbNo, mbCancel]
    , 0
    , sBaseRegistryKey + crbMRU + 'Dlgs'
    , 'DirectSQL'
    , idYes
    ) <> idYes then 
    Exit;

  bStopRefresh := True;
  VCSDirectSQL := TVCSDirectSQL.Create(Application);
  try
    VCSDirectSQL.ShowModal;
  finally
    VCSDirectSQL.Free;
  end;
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.DistributionArchive1Click(Sender: TObject);
begin
  bStopRefresh := True;
  VCSDistribution := TVCSDistribution.Create(Application);
  try
    VCSDistribution.ShowModal;
  finally
    VCSDistribution.Free;
  end;
  bStopRefresh := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.CreateInternetLinkMenuItems;
var
  ILKind: TJVCSInternetLinkKind;
  CurrentLinkDescription: string;
  CurrentInsertIndex: Integer;
  LMItem: TMenuItem;
begin
  JediVcsLinkPlaceholder.Visible := False;
  CurrentInsertIndex := Help1.IndexOf(JediVcsLinkPlaceholder);
  for ILKind := Low(TJVCSInternetLinkKind) to High(TJVCSInternetLinkKind) do
  begin
    CurrentLinkDescription := GetJVCSInternetLinkDescription(ILKind);
    if CurrentLinkDescription <> '' then
    begin
      LMItem := TMenuItem.Create(Self);
      with LMItem do
      begin
        Caption := CurrentLinkDescription;
        OnClick := JediVcsLinkPlaceholderClick;
        ImageIndex := JediVcsLinkPlaceholder.ImageIndex;
        Tag := Ord(ILKind);
      end;
      Help1.Insert(CurrentInsertIndex, LMItem);
      Inc(CurrentInsertIndex);
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.JediVcsLinkPlaceholderClick(Sender: TObject);
var
  WebTarget: string;
  ExecResult: Integer;
begin
  if (Sender is TMenuItem) and (TMenuItem(Sender).Tag >= Ord(Low(TJVCSInternetLinkKind))) and
    (TMenuItem(Sender).Tag <= Ord(High(TJVCSInternetLinkKind))) then
  begin
    WebTarget := GetJVCSInternetLink(TJVCSInternetLinkKind(TMenuItem(Sender).Tag));
    if WebTarget <> '' then
    begin
      ExecResult := ShellExecute(Handle, 'Open', PChar(WebTarget), nil, nil, SW_SHOW);
      if ExecResult < 32 then
      begin
        BeepIfSet;
        MessageBox(Handle, PChar(Format(JVCSRES_ShellExecute_Error_6037s62, [WebTarget]) +
          #10#13 + DecodeShellErr(ExecResult)),
          cMsgBoxCaption, MB_OK or MB_ICONWARNING);
      end; // if ExecResult < 32 then begin
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.LocalProjectFolder1Click(Sender: TObject);
{$IFDEF CUSTOMDRIVE}
var
  NeedRefresh: Boolean;
{$ENDIF CUSTOMDRIVE}
begin
  {$IFNDEF CUSTOMDRIVE}
(* #fvcstodostart
   $priority = 1
   $responsible = Administrator
   $item = This feature has not been finished yet
   #fvcstodoend *)
  MessageBox(WindowHandle, PChar(JVCSRES_This_feature_has_not_been_finished_yet_and_has_been_disabled + #13#10 +
    JVCSRES_until_it_has_been_fixed46_Sorry46), cMsgBoxCaption, MB_OK);
  Exit;
  {$ELSE}
  bStopRefresh := True;
  VCSProjectRoot := TVCSProjectRoot.Create(Application);
  try
    VCSProjectRoot.Left := Left + 60;
    VCSProjectRoot.Top := Top + 60;
    NeedRefresh := (VCSProjectRoot.ShowModal = mrOk) and
      (VCSProjectRoot.IsChanged);
  finally
    VCSProjectRoot.Free;
  end;
  bStopRefresh := False;
  if NeedRefresh and (sProjectName <> '') then
  begin
    UseRegistry := True;
    DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
    if DSAIdentsMessageDlg(JVCSRES_Parameters_changed46_Refresh_View63
      , mtConfirmation
      , [mbYes, mbNo, mbCancel]
      , 0
      , sBaseRegistryKey + crbMRU + 'Dlgs'
      , 'RefreshView'
      , idYes
      ) <> idYes then
      Exit;
    acRefreshModuleList(Self);
  end;
  {$ENDIF ~CUSTOMDRIVE}
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.SMTPStatus1Click(Sender: TObject);
var
  SMTPRecordCount, SMTPRecordSize: Integer;
begin
  SMTPRecordCount := CountSMTPRecords(SMTPRecordSize);
  MessageBox(Application.Handle, PChar(Format(JVCSRES_You_have_37s_SMTP_mail_records_4037n_k41_in_your_SMTP_out_folder46,
    [IntToStr(SMTPRecordCount), (SMTPRecordSize / 1024)])),
    cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.acRenameModuleExecute(Sender: TObject);
var
  NewName: string;
begin
  if elvModules.Selected = nil then
    Exit;
  if not ArchivedModuleSelected then 
    Exit;
  if (elvModules.Selected.SubItems[sitState] = JVCSRES_Out) and
    (elvModules.Selected.SubItems[sitOwner] <> sCurrentUser) then 
  begin
    BeepIfSet;
    MessageBox(WindowHandle, PChar(Format('<%s>' + #13#10 +
      JVCSRES_You_are_currently_not_the_owner_of_this_module46 + #13#10 +
      JVCSRES_Module_cannot_be_changed46,
      [elvModules.Selected.Caption])), cMsgBoxCaption, MB_OK or MB_ICONWARNING);
    Exit;
  end;
  NewName := elvModules.Selected.Caption;
  if not InputQuery(JVCSRES_Rename_module, JVCSRES_Enter_a_new_module_name58_40same_extension3341,
    NewName) then
    Exit;
  if (LowerCase(ExtractFileExt(NewName)) <>
    LowerCase(ExtractFileExt(elvModules.Selected.Caption))) then
  begin
    BeepIfSet;
    MessageBox(WindowHandle, PChar('<' +
      ExtractFileExt(elvModules.Selected.Caption) + ' / ' +
      LowerCase(ExtractFileExt(NewName)) + '>' + #10#13 +
      JVCSRES_You_cannot_change_the_module_extension46),
      cMsgBoxCaption, MB_OK or MB_ICONWARNING);
    Exit;
  end;

  bStopRefresh := True;
  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'RENAME_MODULE';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [elvModules.Selected.SubItems[sitMID]]);
    AppSrvClient1.Request.WriteFields(False, [AnsiLowerCase(NewName)]);
    AppSrvClient1.Request.WriteFields(False, [ServerProjectID]);
    SetupTimeoutCounter;
    AppSrvClient1.Send;

    while WaitForAppSrvClient do 
      Application.ProcessMessages;
    if (AppSrvClientErr = -99) then 
    begin
      ShowServerTimeOut(WindowHandle);
      bStopRefresh := False;
      Exit;
    end;
    if (AppSrvClientErr <> 0) or
      (AppSrvClient1.AnswerStatus <> '200') then 
    begin
      ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
        AppSrvClient1.AnswerStatus);
      bStopRefresh := False;
      Exit;
    end;

    AppSrvClient1.Answer.First;
    if not DecodeBoolStr(AppSrvClient1.Answer.Fields[0]) then 
    begin
      BeepIfSet;
      MessageBox(WindowHandle, PChar(Format(JVCSRES_6037s62_Access_denied46,
        [elvModules.Selected.Caption]) + #10#13 +
        JVCSRES_You_cannot_change_the_name_of_a_locked_module46),
        cMsgBoxCaption, MB_OK or MB_ICONWARNING);
    end 
    else 
    begin
      RefreshModules;
      GetArchiveTimeStamp(ArchTStamp);
      AddMessage(Format(JVCSRES_Renamed58_37s_45_Success, [elvModules.Selected.Caption]),
        msclNormal);
    end;
  end; // with DataModule1 do begin
  bStopRefresh := False;
end;

//=== ??? ======================================================================

procedure TVCSProjAdmin.uilPluginManager1BeforeLoad(Sender: TObject;
  FileName: string; var AllowLoad: Boolean);
begin
  AddMessage(Format(JVCSRES_Loading_Plug45in58_37s, [FileName]), msclNormal);
  // in uilPluginManager was addition event BeforeLoading => moved here
  AddMessage(Format(JVCSRES_Plug45in_folder58_37s, [uilPluginManager1.PluginFolder]), msclNormal);
  AddMessage(JVCSRES_Searching_for_available_Plug45ins464646, msclNormal);
end;

procedure TVCSProjAdmin.Configure1Click(Sender: TObject);
begin
  bStopRefresh := True;
  VCSPlugin := TVCSPlugin.Create(Application);
  try
    uilPluginManager1.GetLoadedPlugins(VCSPlugin.lbPlugins.Items);
    VCSPlugin.Top := Top + 60;
    VCSPlugin.Left := Left + 60;
    VCSPlugin.ShowModal;
  finally
    VCSPlugin.Free;
  end;
  bStopRefresh := False;
end;

procedure TVCSProjAdmin.AboutPlugins1Click(Sender: TObject);
begin
  PerformHelpCommand(Application, IDH_Plug_In_s);
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.ExpertMenu1Click(Sender: TObject);
begin
  ExpertMenu1.Checked := not ExpertMenu1.Checked;
  jvcsWriteBool(sBaseRegistryKey + crbOptions, 'ExpertMenu', ExpertMenu1.Checked);
  SetMenuMode;
end;

//------------------------------------------------------------------------------

procedure TVCSProjAdmin.mmiChangedDifferentClick(Sender: TObject);
begin
  SelectionOfModules(selAcAllNotYetAppliedChanges);
  // Message Window
  AddMessage( Format( JVCSRES_Selection58_All_module_changes_not_yet_applied_to_the_archive_45_37d_hits
                    , [elvModules.SelCount])
            , msclNormal
            );
  if elvModules.SelCount = 0 then
    // \n\rRemember that the filter is related only to files checked out by you. 378
    MessageBox( Handle
              , PChar(Format( JVCSRES_There_were_no_37s_located_that_match_the_search_criteria46
                            , [JVCSRES_files]) + #13#10 + JVCSRES_Remember_that_the_filter_is_related_only_to_files_checked_out_by_you46)
              , cMsgBoxCaption
              , MB_OK or MB_ICONINFORMATION
              );
end;

function TVCSProjAdmin.GetIJVCSProjectManager: IJVCSProjectManager;
begin
  //USc 15.09.2003 - Self as IJVCSProjectManager does work in D6 but not in D5
  //thatswhy we must use TObject.GetInterface
  Self.GetInterface(IID_IJVCSProjectManager, Result);
end;

procedure TVCSProjAdmin.acProjectTreeExecute(Sender: TObject);
begin
  {$IFNDEF IDEDLL}
  acProjectTree.Checked := not acProjectTree.Checked;
  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'ProjMan_ShowProjectTree',
    acProjectTree.Checked);

  ShowProjectTree(acProjectTree.Checked);
  {$ENDIF ~IDEDLL}
end;

{$IFNDEF IDEDLL}
procedure TVCSProjAdmin.ShowProjectTree(AVisible: Boolean);
begin
  if AVisible then
  begin
    if not Assigned(JVCSDockProjectTree) then
      JVCSDockProjectTree := TJVCSDockProjectTree.Create(Self);
    JVCSDockProjectTree.ProjectManager := GetIJVCSProjectManager;
    JVCSDockProjectTree.Align := alClient;
    JVCSDockProjectTree.ShowAndDockToControl(tvHierachyPlaceholder);
    RefreshDispatcher.AddClient(JVCSDockProjectTree);
    tvHierachyPlaceholder.Constraints.MinWidth := 50;
    tvHierachyPlaceholder.Width := ProjectFolderWidth;
    tvHierachyPlaceholder.Visible := True;
    JvSplitter1.Visible := True;
    JvSplitter1.Left := tvHierachyPlaceholder.Left + 1;
    acProjectTree.Checked := True;
    acProjectTree.Hint := JVCSRES_Hide_project_tree;
  end
  else
  begin
    if tvHierachyPlaceholder.Width > 1 then
      ProjectFolderWidth :=  tvHierachyPlaceholder.Width; // remember previous setting
    if Assigned(JVCSDockProjectTree) then
    begin
      RefreshDispatcher.RemoveClient(JVCSDockProjectTree);
      JVCSDockProjectTree.Close;
    end;
    JvSplitter1.Visible := False;
    tvHierachyPlaceholder.Visible := False;
    acProjectTree.Checked := False;
    acProjectTree.Hint := JVCSRES_Show_project_tree;
  end;
end;
{$ENDIF ~IDEDLL}

procedure TVCSProjAdmin.acShowToDoWinExecute(Sender: TObject);
begin
  // Show/Hide ToDo status window
  acShowToDoWin.Checked := not acShowToDoWin.Checked;
  jvcsWriteBool ( sBaseRegistryKey + crbWindows
                , 'ProjMan_ToDoWinState'
                , acShowToDoWin.Checked
                );
  ShowToDoWin(acShowToDoWin.Checked);
end;

procedure TVCSProjAdmin.ShowToDoWin(AVisible: Boolean);
begin
  if AVisible then
  begin
    if not Assigned(JVCSDockToDoWindow) then
      JVCSDockToDoWindow := TJVCSDockToDoWindow.Create(Self);
    JVCSDockToDoWindow.ShowAndDockToControl(pgStatus);
    SetDockClientToActivePage(pgStatus, JVCSDockToDoWindow);
    RefreshDispatcher.AddClient(JVCSDockToDoWindow);
  end
  else
  if Assigned(JVCSDockToDoWindow) then
  begin
    RefreshDispatcher.RemoveClient(JVCSDockToDoWindow);
    JVCSDockToDoWindow.Close;
  end;
  SetStatusWinState;
end;

procedure TVCSProjAdmin.acProjectBugExecute(Sender: TObject);
begin
  bStopRefresh := True;
  VCSAssignBugs := TVCSAssignBugs.Create(Application);
  try
    VCSAssignBugs.Left := Left + 60;
    VCSAssignBugs.Top := Top + 60;
    VCSAssignBugs.ModuleBased := False;
    VCSAssignBugs.ItemID := IntToStr(ServerProjectID);
    VCSAssignBugs.ItemName := ExtractFileName(sProjectName);
    VCSAssignBugs.ShowModal;
  finally
    VCSAssignBugs.Free;
  end;
  GetModuleBugs(False);

  RefreshDispatcher.DispatchSimpleRefresh(rtSelectedProjectChanged);

  bStopRefresh := False;
end;

procedure TVCSProjAdmin.acShowBugWinExecute(Sender: TObject);
begin
  // Show/Hide Bugs window
  acShowBugWin.Checked := not acShowBugWin.Checked;
  jvcsWriteBool ( sBaseRegistryKey + crbWindows
                , 'ProjMan_BugWinState'
                , acShowBugWin.Checked
                );
  ShowBugWin(acShowBugWin.Checked);
end;

procedure TVCSProjAdmin.ShowBugWin(AVisible: Boolean);
begin
  if AVisible then
  begin
    if not Assigned(VCSBugWindow) then
      VCSBugWindow := TVCSBugWindow.Create(Self);
    VCSBugWindow.ShowAndDockToControl(pgStatus);
    SetDockClientToActivePage(pgStatus, VCSBugWindow);
    VCSBugWindow.ProjectManager := GetIJVCSProjectManager;
    RefreshDispatcher.AddClient(VCSBugWindow);
    RefreshDispatcher.DispatchSimpleRefresh(rtRefresh);
  end
  else
  if Assigned(VCSBugWindow) then
  begin
    RefreshDispatcher.RemoveClient(VCSBugWindow);  
    VCSBugWindow.Close;
  end;
  SetStatusWinState;
end;

procedure TVCSProjAdmin.Project1Click(Sender: TObject);
{$IFNDEF IDEDLL}
var
  I, J, cnt, LProjectID: Integer;
  C: Char;
  LHotKeys: array [0..9] of Char;
  LMItem: TMenuItem;
  RecentProjectList: TJVCSMruList;
{$ENDIF ~IDEDLL}
begin
  {$IFNDEF IDEDLL}
  while mmiOpenRecentProject.Count > 0 do
    mmiOpenRecentProject.Items[0].Free;

  if (ServerUserID > 0) and Assigned(FRefreshProjects) then
  begin
    FRefreshProjects.Lock;
    try
      RecentProjectList := nil;
      try
        RecentProjectList := TJVCSMruList.CreateEx(sBaseRegistryKey + crbMRU + '22');
        cnt := 0;
        for C := '1' to '9' do
        begin
          LHotKeys[cnt] := C;
          Inc(cnt);
        end;
        LHotKeys[cnt] := '0';

        cnt := 0;
        for I := 0 to Pred(RecentProjectList.Count) do
          if cnt < 10 then
          begin
            LProjectID := -1;
            for J := 0 to Pred(FRefreshProjects.Count) do
              if (FRefreshProjects[J].Name = RecentProjectList.Strings[I]) and
                (FRefreshProjects[J].ID > 0)
              then
              begin
                LProjectID := FRefreshProjects[J].ID;
                Break;
              end;
            if LProjectID <> -1 then
            begin
              LMItem := TMenuItem.Create(mmiOpenRecentProject);
              with LMItem do
              begin
                Caption := Format('&%s %s', [LHotKeys[cnt], RecentProjectList.Strings[I]]);
                OnClick := OpenRecentProjectClick;
                Tag := LProjectID;
                if ServerProjectID = LProjectID then
                begin
                  Enabled := False;
                  Caption := Format(JVCSRES_37s_60open62, [Caption]);
                end;
              end;
              mmiOpenRecentProject.Add(LMItem);
              Inc(cnt);
            end;
          end;
      finally
        RecentProjectList.Free;
      end;
    finally
      FRefreshProjects.Unlock;
    end;
    ReadFavorites;
  end;
  mmiOpenRecentProject.Visible := mmiOpenRecentProject.Count > 0;
  {$ENDIF ~IDEDLL}
end;

{$IFNDEF IDEDLL}
procedure TVCSProjAdmin.OpenRecentProjectClick(Sender: TObject);
var
  S: string;
  LMItem: TMenuItem;
  RecentProjectList: TJVCSMruList;
begin
  LMItem := TMenuItem(Sender);
  if Assigned(LMItem) and (LMItem is TMenuItem) and
    (LMItem.Parent = mmiOpenRecentProject) and (LMItem.Tag > 0)
  then
  begin
    S := LMItem.Caption;
    Delete(S, 1, 3);
    RecentProjectList := TJVCSMruList.CreateEx(sBaseRegistryKey + crbMRU + '22');
    try
      RecentProjectList.AddString(S);
      RecentProjectList.SaveToStorage(sBaseRegistryKey + crbMRU + '22');
    finally
      RecentProjectList.free;
    end;
    OpenProject(LMItem.Tag, S);
  end;
end;
{$ENDIF ~IDEDLL}

procedure TVCSProjAdmin.acShowModuleHistoryWinExecute(Sender: TObject);
begin
  // Show/Hide Module History window
  acShowModuleHistoryWin.Checked := not acShowModuleHistoryWin.Checked;
  jvcsWriteBool ( sBaseRegistryKey + crbWindows
                , 'ProjMan_ModHistoryWinState'
                , acShowModuleHistoryWin.Checked
                );
  ShowModuleHistoryWin(acShowModuleHistoryWin.Checked);
end;

procedure TVCSProjAdmin.ShowModuleHistoryWin(AVisible: Boolean);
begin
  if AVisible then
  begin
    if not Assigned(VCSModuleHistoryWindow) then
      VCSModuleHistoryWindow := TVCSModuleHistoryWindow.Create(Self);
    VCSModuleHistoryWindow.ShowAndDockToControl(pgStatus);
    SetDockClientToActivePage(pgStatus, VCSModuleHistoryWindow);
    VCSModuleHistoryWindow.ProjectManager := GetIJVCSProjectManager;
    RefreshDispatcher.AddClient(VCSModuleHistoryWindow);
    RefreshDispatcher.DispatchSimpleRefresh(rtRefresh);
  end
  else
  if Assigned(VCSModuleHistoryWindow) then
  begin
    RefreshDispatcher.RemoveClient(VCSModuleHistoryWindow);
    VCSModuleHistoryWindow.Close;
  end;
  SetStatusWinState;
end;

function TVCSProjAdmin.GetSelectedModuleID: Integer;
begin
  EnterCriticalSection(FSelectedModuleLock);
  try
    Result := FSelectedModuleID;
  finally
    LeaveCriticalSection(FSelectedModuleLock);
  end;
end;

function TVCSProjAdmin.GetSelectedModuleName: string;
begin
  EnterCriticalSection(FSelectedModuleLock);
  try
    Result := FSelectedModuleName;
  finally
    LeaveCriticalSection(FSelectedModuleLock);
  end;
end;

procedure TVCSProjAdmin.ExecuteBugManager;
begin
  acBugManager.Execute;
end;

procedure TVCSProjAdmin.ExecuteProjectBugManager;
begin
  acProjectBug.Execute;
end;

procedure TVCSProjAdmin.ExecuteModuleBugManager;
begin
  acModuleBugs.Execute;
end;

procedure TVCSProjAdmin.uilPluginManager1NewCommand(Sender: TObject; ACaption, AHint, AData: string;
    AShortCut: TShortCut; ABitmap: TBitmap;
    AEvent: TNotifyEvent);
var
  Item: TMenuItem;
begin
  AddMessage(Format(JVCSRES_Adding_command58_37s, [ACaption]), msclNormal);
  Item := NewItem(ACaption, scNone, False, True, AEvent, 0, '');
  MainMenu1.Items[8].Add(Item);
end;

procedure TVCSProjAdmin.uilPluginManager1AfterLoad(Sender: TObject;
  FileName: string; const ALibHandle: Cardinal; var AllowLoad: Boolean);
begin
  AddMessage(Format(JVCSRES_Finished_loading_Plug45in58_37s, [FileName]), msclNormal);
  // in uilPluginManager was addition event AfterLoading => moved here
  AddMessage(Format(JVCSRES_Finished_loading_Plug45ins_40loaded58_37d41,
    [uilPluginManager1.PluginCount]), msclNormal);
  Configure1.Enabled := (uilPluginManager1.PluginCount > 0);
  AllowLoad := True;
end;

procedure TVCSProjAdmin.FormActivate(Sender: TObject);
begin
  //USc 28.12.2004 obviously setting WindowState to wsMaximized in FormCreate doesn't
  //  work thatswhy I found this solution for mantis #2408
  if FMustSetMaximized then
  begin
    FMustSetMaximized := False;
    WindowState := wsMaximized;
  end;
end;

procedure TVCSProjAdmin.elvModulesSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  if not (csDestroying in ComponentState) then
  begin
    EnterCriticalSection(FSelectedModuleLock);
    try
      FSelectedModuleID := -1;
      FSelectedModuleName := '';
      with elvModules do
        if Assigned(Selected) and (Selected.SubItems[sitMID] <> JVCSRES_N47A) then
        begin
          FSelectedModuleID := _StrToInt(Selected.SubItems[sitMID]);
          FSelectedModuleName := Selected.SubItems[sitPath] + Selected.Caption;
        end;
    finally
      LeaveCriticalSection(FSelectedModuleLock);
    end;
    UpdateDiffActions;
    if Selected then
      RefreshDispatcher.DispatchSimpleRefresh(rtSelectedModuleChanged);
  end;
end;

{$IFDEF LANGUAGE}
procedure TVCSProjAdmin.HandleAfterChangedLanguage(const ALanguageCode: string);
begin
  jvcsWriteString(sBaseRegistryKey + crbOptions, 'Language', ALanguageCode);
end;
{$ENDIF LANGUAGE}

procedure TVCSProjAdmin.acLockedModuleWinExecute(Sender: TObject);
begin
  // Show/Hide Locked Modules window
  acLockedModuleWin.Checked := not acLockedModuleWin.Checked;
  jvcsWriteBool ( sBaseRegistryKey + crbWindows
                , 'ProjMan_LockedModulesWinState'
                , acLockedModuleWin.Checked
                );
  ShowLockedModulesWin(acLockedModuleWin.Checked);
end;

procedure TVCSProjAdmin.ShowLockedModulesWin(AVisible: Boolean);
begin
  if AVisible then
  begin
    if not Assigned(JVCSDockLockedModulesWindow) then
      JVCSDockLockedModulesWindow := TJVCSDockLockedModulesWindow.Create(Self);
    JVCSDockLockedModulesWindow.ShowAndDockToControl(pgStatus);
    SetDockClientToActivePage(pgStatus, JVCSDockLockedModulesWindow);
    JVCSDockLockedModulesWindow.ProjectManager := GetIJVCSProjectManager;
    RefreshDispatcher.AddClient(JVCSDockLockedModulesWindow);
    RefreshDispatcher.DispatchSimpleRefresh(rtRefresh);
  end
  else
  if Assigned(JVCSDockLockedModulesWindow) then
  begin
    RefreshDispatcher.RemoveClient(JVCSDockLockedModulesWindow);
    JVCSDockLockedModulesWindow.Close;
  end;
  SetStatusWinState;
end;

procedure TVCSProjAdmin.RefreshSingleModule(AModuleID: Integer);
var
  I, Idx: Integer;
begin
  with elvModules do
  begin
    Idx := -1;
    for I := 0 to Pred(Items.Count) do
      if StrToIntDef(Items[I].SubItems[sitMID], -1) = AModuleID then
      begin
        Idx := I;
        Break;
      end;
    if Idx <> -1 then
      ADD_Refresh_Module(False, Idx, _StrToInt(Items[Idx].SubItems[sitMID]),
        Items[Idx].SubItems[sitPath] + LowerCase(Items[Idx].Caption));
  end;
end;

procedure TVCSProjAdmin.Panel1Resize(Sender: TObject);
begin
  //assign new messagewindow height for SetStatusWinState
  MsgWinHeight := Panel1.Height;
end;

procedure TVCSProjAdmin.acLineHistoryExecute(Sender: TObject);
var
  CompareFile: string;
begin
  if not ArchivedModuleSelected then
    Exit;
  bStopRefresh := True;
  try
    if elvModules.SelCount = 1 then
    begin
      CompareFile := elvModules.Selected.SubItems[sitPath] + elvModules.Selected.Caption;
      ShowLineHistory(CompareFile);
    end;
  finally
    bStopRefresh := False;
  end;
end;

procedure TVCSProjAdmin.ShowLineHistory(const AModuleName: string; const AModuleMember: string = '');
var
  I, Idx: Integer;
  tabSheet: TTabSheet;
  LineHistoryFrame: TJVCSLineHistoryFrm;
  ModuleExtension: string;
begin
  Idx := -1;
  if AModuleMember <> '' then
    ModuleExtension := AModuleMember
  else
    ModuleExtension := ExtractFileExt(AModuleName);
  for I := 1 to Pred(pgMain.PageCount) do
    if (pgMain.Pages[I].ControlCount > 0) and (pgMain.Pages[I].Controls[0] is TJVCSLineHistoryFrm) and
      (TJVCSLineHistoryFrm(pgMain.Pages[I].Controls[0]).ModuleName = AModuleName)
    then
    begin
      Idx := I;
      Break;
    end;
  if Idx <> -1 then
  begin
    TJVCSLineHistoryFrm(pgMain.Pages[Idx].Controls[0]).SelectedExtension := ModuleExtension;
    pgMain.ActivePageIndex := Idx;
  end
  else
  begin
    if not Assigned(FLineHistoryProvider) then
      FLineHistoryProvider := TJVCSConnectionLineHistoryProvider.Create(GetJvcsConnection);
    if not Assigned(FLineHistorySettings) then
    begin
      FLineHistorySettings := TJVCSLineHistorySettings.Create;
      LoadLineHistorySettings;
    end;
    tabSheet := TTabSheet.Create(pgMain);
    tabSheet.PageControl := pgMain;
    tabSheet.Caption := Format(JVCSRES_Line_History_37s, [ExtractFileName(AModuleName)]);
    if pgMain.PageCount > 1 then
      tsDefault.TabVisible := True;
    LineHistoryFrame := TJVCSLineHistoryFrm.Create(tabSheet);
    LineHistoryFrame.Provider := FLineHistoryProvider;
    LineHistoryFrame.Enable;
    LineHistoryFrame.Parent := tabSheet;
    LineHistoryFrame.Align := alClient;
    LineHistoryFrame.ModuleName := AModuleName;
    LineHistoryFrame.SelectedExtension := ModuleExtension;
    LineHistoryFrame.OnRevisionClick := LineHistoryRevisionClick;
    LineHistoryFrame.OnSettingsChanged := LineHistorySettingsChanged;
    LineHistoryFrame.Settings := FLineHistorySettings;
    pgMain.ActivePage := tabSheet;
  end;
end;

{$IFNDEF IDEDLL}
procedure TVCSProjAdmin.RemoveLineHistoryPages;
var
  I: Integer;
begin
  if pgMain.PageCount > 0 then
    for I := Pred(pgMain.PageCount) downto 0 do
      if pgMain.Pages[I] <> tsDefault then
        pgMain.Pages[I].Free;
  if pgMain.PageCount = 1 then
  begin
    tsDefault.TabVisible := False;
    pgMain.ActivePage := tsDefault;
  end;
end;
{$ENDIF ~IDEDLL}

procedure TVCSProjAdmin.LineHistoryRevisionClick(Sender: TObject; ARevisionIDStr: string);
var
  RevisionID: Integer;
  CompareMode: TTextCompareMode;
begin
  if Sender is TJVCSLineHistoryFrm then
  begin
    RevisionID := StrToIntDef(ARevisionIDStr, 0);
    if RevisionID = 0 then
      CompareMode := tcmDefault
    else
      CompareMode := tcmArchiveToArchive;
    DoModuleCompare(TJVCSLineHistoryFrm(Sender).ModuleName, TJVCSLineHistoryFrm(Sender).SelectedExtension,
      RevisionID, CompareMode);
  end;
end;

procedure TVCSProjAdmin.LineHistorySettingsChanged(Sender: TObject);
var
  I: Integer;
begin
  FLineHistorySettings.Assign(TJVCSLineHistoryFrm(Sender).Settings);
  SaveLineHistorySettings;
  for I := 1 to Pred(pgMain.PageCount) do
    if (pgMain.Pages[I].ControlCount > 0) and (pgMain.Pages[I].Controls[0] is TJVCSLineHistoryFrm) then
      if pgMain.Pages[I].Controls[0] <> Sender then
        TJVCSLineHistoryFrm(pgMain.Pages[I].Controls[0]).Settings := FLineHistorySettings;
end;

const
  crbLineHistory = '\LineHistory';

procedure TVCSProjAdmin.LoadLineHistorySettings;
var
  I, Cnt, Int: Integer;
  S, S2: string;
  UserSettingsItem: TJVCSLineHistoryUserSettingsItem;
begin
  Cnt := jvcsReadInteger(sBaseRegistryKey + crbLineHistory, 'ColorBarOrderListCount', -1);
  if Cnt >= 0 then
  begin
    FLineHistorySettings.ColorBarOrderList.Clear;
    for I := 0 to Pred(Cnt) do
    begin
      Int := jvcsReadInteger(sBaseRegistryKey + crbLineHistory, Format('ColorBarOrderList%d', [I]), -1);
      if (Int >= 1) and (Int <= {$IFDEF LINEINFOEX} 5 {$ELSE} 3 {$ENDIF}) and (FLineHistorySettings.ColorBarOrderList.IndexOf(Pointer(Int)) = -1) then
        FLineHistorySettings.ColorBarOrderList.Add(Pointer(Int));
    end;
  end;
  FLineHistorySettings.DateEndColor := jvcsReadInteger(sBaseRegistryKey + crbLineHistory, 'DateEndColor', FLineHistorySettings.DateEndColor);
  FLineHistorySettings.DateFormat := jvcsReadString(sBaseRegistryKey + crbLineHistory, 'DateFormat', FLineHistorySettings.DateFormat);
  FLineHistorySettings.DateStartColor := jvcsReadInteger(sBaseRegistryKey + crbLineHistory, 'DateStartColor', FLineHistorySettings.DateStartColor);
  FLineHistorySettings.LineColorMode := jvcsReadInteger(sBaseRegistryKey + crbLineHistory, 'LineColorMode', FLineHistorySettings.LineColorMode);
  FLineHistorySettings.PaintMethod := jvcsReadInteger(sBaseRegistryKey + crbLineHistory, 'PaintMethod', FLineHistorySettings.PaintMethod);
  FLineHistorySettings.RevisionEndColor := jvcsReadInteger(sBaseRegistryKey + crbLineHistory, 'RevisionEndColor', FLineHistorySettings.RevisionEndColor);
  FLineHistorySettings.RevisionStartColor := jvcsReadInteger(sBaseRegistryKey + crbLineHistory, 'RevisionStartColor', FLineHistorySettings.RevisionStartColor);
  FLineHistorySettings.ShowLineNumbers := jvcsReadBool(sBaseRegistryKey + crbLineHistory, 'ShowLineNumbers', FLineHistorySettings.ShowLineNumbers);
  FLineHistorySettings.ShowRevisionInfoColor := jvcsReadBool(sBaseRegistryKey + crbLineHistory, 'ShowRevisionInfoColor', FLineHistorySettings.ShowRevisionInfoColor);
  FLineHistorySettings.ShowRevisionInfoText := jvcsReadBool(sBaseRegistryKey + crbLineHistory, 'ShowRevisionInfoText', FLineHistorySettings.ShowRevisionInfoText);
  FLineHistorySettings.ShowDateInfoColor := jvcsReadBool(sBaseRegistryKey + crbLineHistory, 'ShowDateInfoColor', FLineHistorySettings.ShowDateInfoColor);
  FLineHistorySettings.ShowDateInfoText := jvcsReadBool(sBaseRegistryKey + crbLineHistory, 'ShowDateInfoText', FLineHistorySettings.ShowDateInfoText);
  FLineHistorySettings.ShowUserInfoColor := jvcsReadBool(sBaseRegistryKey + crbLineHistory, 'ShowUserInfoColor', FLineHistorySettings.ShowUserInfoColor);
  FLineHistorySettings.ShowUserInfoText := jvcsReadBool(sBaseRegistryKey + crbLineHistory, 'ShowUserInfoText', FLineHistorySettings.ShowUserInfoText);
  {$IFDEF LINEINFOEX}
  FLineHistorySettings.ShowRevisionCountInfoColor := jvcsReadBool(sBaseRegistryKey + crbLineHistory, 'ShowRevisionCountInfoColor', FLineHistorySettings.ShowRevisionCountInfoColor);
  FLineHistorySettings.ShowRevisionCountInfoText := jvcsReadBool(sBaseRegistryKey + crbLineHistory, 'ShowRevisionCountInfoText', FLineHistorySettings.ShowRevisionCountInfoText);
  FLineHistorySettings.ShowFirstRevisionInfoColor := jvcsReadBool(sBaseRegistryKey + crbLineHistory, 'ShowFirstRevisionInfoColor', FLineHistorySettings.ShowFirstRevisionInfoColor);
  FLineHistorySettings.ShowFirstRevisionInfoText := jvcsReadBool(sBaseRegistryKey + crbLineHistory, 'ShowFirstRevisionInfoText', FLineHistorySettings.ShowFirstRevisionInfoText);
  {$ENDIF LINEINFOEX}
  Cnt := jvcsReadInteger(sBaseRegistryKey + crbLineHistory, 'ShowOrderListCount', -1);
  if Cnt >= 0 then
  begin
    FLineHistorySettings.ShowOrderList.Clear;
    for I := 0 to Pred(Cnt) do
    begin
      Int := jvcsReadInteger(sBaseRegistryKey + crbLineHistory, Format('ShowOrderList%d', [I]), -1);
      if (Int >= 1) and (Int <= {$IFDEF LINEINFOEX} 6 {$ELSE} 4 {$ENDIF}) and (FLineHistorySettings.ShowOrderList.IndexOf(Pointer(Int)) = -1) then
        FLineHistorySettings.ShowOrderList.Add(Pointer(Int));
    end;
  end;
  Cnt := jvcsReadInteger(sBaseRegistryKey + crbLineHistory, 'StaticUserColorListCount', -1);
  if Cnt >= 0 then
  begin
    FLineHistorySettings.StaticUserColorList.Clear;
    for I := 0 to Pred(Cnt) do
    begin
      S := jvcsReadString(sBaseRegistryKey + crbLineHistory, Format('StaticUserColorListUserName%d', [I]), '');
      Int := jvcsReadInteger(sBaseRegistryKey + crbLineHistory, Format('StaticUserColorListColor%d', [I]), -1);
      if (S <> '') and (FLineHistorySettings.StaticUserColorList.IndexOf(S) = -1) and (Int <> -1) then
        FLineHistorySettings.StaticUserColorList.AddObject(S, TObject(Int));
    end;
  end;
  FLineHistorySettings.SuppressRevisionTextZeroDot := jvcsReadBool(sBaseRegistryKey + crbLineHistory, 'SuppressRevisionTextZeroDot', FLineHistorySettings.SuppressRevisionTextZeroDot);
  Cnt := jvcsReadInteger(sBaseRegistryKey + crbLineHistory, 'UserSettingsListCount', -1);
  if Cnt >= 0 then
  begin
    FLineHistorySettings.UserSettingsList.Clear;
    for I := 0 to Pred(Cnt) do
    begin
      Int := jvcsReadInteger(sBaseRegistryKey + crbLineHistory, Format('UserSettingsListColor%d', [I]), -1);
      S := jvcsReadString(sBaseRegistryKey + crbLineHistory, Format('UserSettingsListUserName%d', [I]), '');
      S2 := jvcsReadString(sBaseRegistryKey + crbLineHistory, Format('UserSettingsListVisibleName%d', [I]), '');
      if (S <> '') and (FLineHistorySettings.UserSettingsList.IndexOfUser(S) = -1) and ((S2 <> '') or (Int <> -1)) then
      begin
        UserSettingsItem := FLineHistorySettings.UserSettingsList.Add;
        UserSettingsItem.UserName := S;
        UserSettingsItem.Color := TColor(Int);
        UserSettingsItem.VisibleName := S2;
      end;
    end;
  end;
  if (FLineHistorySettings.UserSettingsList.Count = 0) and (FLineHistorySettings.StaticUserColorList.Count > 0) then
  begin
    for I := 0 to Pred(FLineHistorySettings.StaticUserColorList.Count) do
    begin
      UserSettingsItem := FLineHistorySettings.UserSettingsList.Add;
      UserSettingsItem.UserName := FLineHistorySettings.StaticUserColorList[I];
      UserSettingsItem.Color := TColor(FLineHistorySettings.StaticUserColorList.Objects[I]);
    end;
  end;
end;

procedure TVCSProjAdmin.SaveLineHistorySettings;
var
  I: Integer;
  UserSettingsItem: TJVCSLineHistoryUserSettingsItem;
begin
  jvcsWriteInteger(sBaseRegistryKey + crbLineHistory, 'ColorBarOrderListCount', FLineHistorySettings.ColorBarOrderList.Count);
  for I := 0 to Pred(FLineHistorySettings.ColorBarOrderList.Count) do
    jvcsWriteInteger(sBaseRegistryKey + crbLineHistory, Format('ColorBarOrderList%d', [I]), Integer(FLineHistorySettings.ColorBarOrderList[I]));
  jvcsWriteInteger(sBaseRegistryKey + crbLineHistory, 'DateEndColor', FLineHistorySettings.DateEndColor);
  jvcsWriteString(sBaseRegistryKey + crbLineHistory, 'DateFormat', FLineHistorySettings.DateFormat);
  jvcsWriteInteger(sBaseRegistryKey + crbLineHistory, 'DateStartColor', FLineHistorySettings.DateStartColor);
  jvcsWriteInteger(sBaseRegistryKey + crbLineHistory, 'LineColorMode', FLineHistorySettings.LineColorMode);
  jvcsWriteInteger(sBaseRegistryKey + crbLineHistory, 'PaintMethod', FLineHistorySettings.PaintMethod);  
  jvcsWriteInteger(sBaseRegistryKey + crbLineHistory, 'RevisionEndColor', FLineHistorySettings.RevisionEndColor);
  jvcsWriteInteger(sBaseRegistryKey + crbLineHistory, 'RevisionStartColor', FLineHistorySettings.RevisionStartColor);
  jvcsWriteBool(sBaseRegistryKey + crbLineHistory, 'ShowLineNumbers', FLineHistorySettings.ShowLineNumbers);
  jvcsWriteBool(sBaseRegistryKey + crbLineHistory, 'ShowRevisionInfoColor', FLineHistorySettings.ShowRevisionInfoColor);
  jvcsWriteBool(sBaseRegistryKey + crbLineHistory, 'ShowRevisionInfoText', FLineHistorySettings.ShowRevisionInfoText);
  jvcsWriteBool(sBaseRegistryKey + crbLineHistory, 'ShowDateInfoColor', FLineHistorySettings.ShowDateInfoColor);
  jvcsWriteBool(sBaseRegistryKey + crbLineHistory, 'ShowDateInfoText', FLineHistorySettings.ShowDateInfoText);
  jvcsWriteBool(sBaseRegistryKey + crbLineHistory, 'ShowUserInfoColor', FLineHistorySettings.ShowUserInfoColor);
  jvcsWriteBool(sBaseRegistryKey + crbLineHistory, 'ShowUserInfoText', FLineHistorySettings.ShowUserInfoText);
  {$IFDEF LINEINFOEX}
  jvcsWriteBool(sBaseRegistryKey + crbLineHistory, 'ShowRevisionCountInfoColor', FLineHistorySettings.ShowRevisionCountInfoColor);
  jvcsWriteBool(sBaseRegistryKey + crbLineHistory, 'ShowRevisionCountInfoText', FLineHistorySettings.ShowRevisionCountInfoText);
  jvcsWriteBool(sBaseRegistryKey + crbLineHistory, 'ShowFirstRevisionInfoColor', FLineHistorySettings.ShowFirstRevisionInfoColor);
  jvcsWriteBool(sBaseRegistryKey + crbLineHistory, 'ShowFirstRevisionInfoText', FLineHistorySettings.ShowFirstRevisionInfoText);
  {$ENDIF LINEINFOEX}
  jvcsWriteInteger(sBaseRegistryKey + crbLineHistory, 'ShowOrderListCount', FLineHistorySettings.ShowOrderList.Count);
  for I := 0 to Pred(FLineHistorySettings.ShowOrderList.Count) do
    jvcsWriteInteger(sBaseRegistryKey + crbLineHistory, Format('ShowOrderList%d', [I]), Integer(FLineHistorySettings.ShowOrderList[I]));
  jvcsWriteInteger(sBaseRegistryKey + crbLineHistory, 'StaticUserColorListCount', FLineHistorySettings.StaticUserColorList.Count);
  for I := 0 to Pred(FLineHistorySettings.StaticUserColorList.Count) do
  begin
    jvcsWriteString(sBaseRegistryKey + crbLineHistory, Format('StaticUserColorListUserName%d', [I]), FLineHistorySettings.StaticUserColorList[I]);
    jvcsWriteInteger(sBaseRegistryKey + crbLineHistory, Format('StaticUserColorListColor%d', [I]), Integer(FLineHistorySettings.StaticUserColorList.Objects[I]));
  end;
  jvcsWriteBool(sBaseRegistryKey + crbLineHistory, 'SuppressRevisionTextZeroDot', FLineHistorySettings.SuppressRevisionTextZeroDot);
  jvcsWriteInteger(sBaseRegistryKey + crbLineHistory, 'UserSettingsListCount', FLineHistorySettings.UserSettingsList.Count);
  for I := 0 to Pred(FLineHistorySettings.UserSettingsList.Count) do
  begin
    UserSettingsItem := FLineHistorySettings.UserSettingsList[I];
    jvcsWriteInteger(sBaseRegistryKey + crbLineHistory, Format('UserSettingsListColor%d', [I]), Integer(UserSettingsItem.Color));
    jvcsWriteString(sBaseRegistryKey + crbLineHistory, Format('UserSettingsListUserName%d', [I]), UserSettingsItem.UserName);
    jvcsWriteString(sBaseRegistryKey + crbLineHistory, Format('UserSettingsListVisibleName%d', [I]), UserSettingsItem.VisibleName);
  end;
end;

procedure TVCSProjAdmin.mnpgMainCloseClick(Sender: TObject);
var
  CurrentPage: TTabSheet;
begin
  if pgMain.ActivePage <> tsDefault then
  begin
    CurrentPage := pgMain.ActivePage;
    //even if the tabsheet is the owner of the frame it is neccessary to destroy it - otherwise
    // an AV will occur at least if you press the Page Up/Down keys(at least with D5 Upd 1, D6 Per Upd 2)
    if (CurrentPage.ControlCount > 0) and (CurrentPage.Controls[0] is TJVCSLineHistoryFrm) then
      CurrentPage.Controls[0].Free;
    CurrentPage.Free;
  end;
  if pgMain.PageCount = 1 then
  begin
    tsDefault.TabVisible := False;
    pgMain.ActivePage := tsDefault;
  end;  
end;

procedure TVCSProjAdmin.pmnPageControlMainPopup(Sender: TObject);
begin
  mnpgMainClose.Enabled := pgMain.ActivePage <> tsDefault;
end;

procedure TVCSProjAdmin.mmiOpenBranchClick(Sender: TObject);
{$IFDEF BRANCHING}
var
  NewBranchID: Integer;
  Dummy: string;
{$ENDIF BRANCHING}
begin
  {$IFDEF BRANCHING}
  NewBranchID := SelectBranch(bsmOpen, Dummy);
  if NewBranchID > 0 then
    OpenBranch(NewBranchID);
  {$ENDIF BRANCHING}
end;

procedure TVCSProjAdmin.mmiNewBranchClick(Sender: TObject);
{$IFDEF BRANCHING}
var
  NewBranchID: Integer;
{$ENDIF BRANCHING}
begin
  {$IFDEF BRANCHING}
  JVCSCreateBranchForm := TJVCSCreateBranchForm.Create(Application); // unit JVCSCreateBranchDialog
  try
    JVCSCreateBranchForm.ShowModal;
    NewBranchID := JVCSCreateBranchForm.NewBranchID;
  finally
    JVCSCreateBranchForm.Free;
  end;
  if NewBranchID > -1 then
    OpenBranch(NewBranchID);
  {$ENDIF BRANCHING}
end;

{$IFDEF BRANCHING}
procedure TVCSProjAdmin.OpenBranch(ANewBranchID: Integer);
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
      acRefreshFormExecute(Self);
      SetMenuStateEx;
      SetStatusBar;
      SetCaption;
    end;
  end;
end;

procedure TVCSProjAdmin.Loaded;
begin
  inherited Loaded;
  Branch1.Visible := True;
  //workaround to make the branch menu item visible
  MenuBar1.Menu := nil;
  MenuBar1.Menu := MainMenu1;  
end;
{$ENDIF BRANCHING}

procedure TVCSProjAdmin.mmiLabelHistoryClick(Sender: TObject);
begin
  bStopRefresh := True;
  VCSLabelHistory := TVCSLabelHistory.Create(Application);
  try
    VCSLabelHistory.ShowModal;
  finally
    VCSLabelHistory.Free;
  end;
  bStopRefresh := False;
end;

{$IFNDEF IDEDLL}
  {$IFNDEF DELPHI2007_UP}   //VISTA support integrated ok since DELPHI2007
  procedure TVCSProjAdmin.CreateParams(var Params: TCreateParams);
  begin
    // fixes VISTA Taskbarsupport
    inherited CreateParams(Params);
    Params.ExStyle := Params.ExStyle and not WS_EX_TOOLWINDOW or WS_EX_APPWINDOW;
  end;

  procedure TVCSProjAdmin.WMSyscommand(var Message: TWmSysCommand);
  begin
    // fixes VISTA Taskbarsupport
    case (Message.CmdType and $FFF0) of
      SC_MINIMIZE:
      begin
        ShowWindow(Handle, SW_MINIMIZE);
        Message.Result := 0;
      end;
      SC_RESTORE:
      begin
        ShowWindow(Handle, SW_RESTORE);
        Message.Result := 0;
      end;
    else
      inherited;
    end;
  end;

  procedure TVCSProjAdmin.WMActivate(var Message: TWMActivate);
  begin
    // fixes VISTA Taskbarsupport
    if (Message.Active = WA_ACTIVE) and not IsWindowEnabled(Handle) then
    begin
      SetActiveWindow(Application.Handle);
      Message.Result := 0;
    end else
      inherited;
  end;
  {$ENDIF ~DELPHI2007_UP}
{$ENDIF ~IDEDLL}

procedure TVCSProjAdmin.acCopyModulenameClipboardExecute(Sender: TObject);
Var
  ii : integer;
  sModuleNames : String;
begin
  if elvModules.SelCount > 0 then
  begin
    sModuleNames := '';
    for ii := 0 to elvModules.Items.Count - 1 do
      if elvModules.Items[ii].Selected then
      begin
        sModuleNames := sModuleNames + elvModules.Items[ii].Caption + ' ';
      end;

    ClipBoard.AsText := sModuleNames;
  end;
end;

end.

