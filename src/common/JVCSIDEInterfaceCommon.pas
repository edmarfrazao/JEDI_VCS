(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSIDEInterfaceCommon.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2003/05/31  USchuster - new unit
2003/09/29  USchuster - new function prototypes for external IDE Interface
2005/06/14  USchuster - changes for D2005 History tab support
2005/06/22  CSchuette - introduced TIDEInterface.IsFileOpenAndWriteable
2005/06/27  USchuster - changes for D2005 project manager menu support
2005/09/04  USchuster - more changes for D2005 project manager menu support
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC3 was released ^^^^^^^^^^^^^^^^^^^^^^^^^^
2006/01/07  USchuster - new finalize procedure for external IDE Interface (mantis #3422)
2008/02/17  USchuster - added member to TOperationCompareModule (Mantis #4262)
2008/09/16  USchuster - changes for D2009 (Mantis #4456)
2010/01/24  USchuster - added DiffModule to TExternalVCSOperationFunctionRec (Mantis #5101)

-----------------------------------------------------------------------------*)

unit JVCSIDEInterfaceCommon;

{$I jedi.inc}
{$I compopt.inc}

{$IFDEF IDEDLL}
  {$IFDEF EXT_IDE_INTF}
     {$DEFINE FUNCTIONRECS}
  {$ELSE}
     {$DEFINE OLDOTA}
  {$ENDIF EXT_IDE_INTF}
{$ELSE}
  {$DEFINE FUNCTIONRECS}
{$ENDIF IDEDLL}

interface

uses
  Classes, Windows
  {$IFDEF OLDOTA}
  , ToolIntf, VCSIntf
  {$ENDIF OLDOTA}
  ;

type
  TIDEFileNotification = (ifnFileOpening, ifnFileOpened, ifnFileClosing,
    ifnProjectOpening, ifnProjectOpened, ifnProjectClosing, ifnAddedToProject,
    ifnRemovedFromProject, ifnDefaultDesktopLoad, ifnDefaultDesktopSave,
    ifnProjectDesktopLoad, ifnprojectDesktopSave, ifnPackageInstalled,
    ifnPackageUninstalled);

  TIDEEventNotification = (ienBeforeCompile, ienAfterCompile);

  TIDEInterfaceOption = (ioSupportsShortCuts);
  TIDEInterfaceOptions = set of TIDEInterfaceOption;

  TGetVerbImagesResult = (gvirOkay, gvirUnknown, gvirImageSizeNotSupported,
    gvirBufferToSmall, gvirContainsNoImages);

const
  ivsEnabled = 1;
  ivsChecked = 2;

{$IFDEF FUNCTIONRECS}
const
  cJediVCSDLLInitFuncName = 'JEDIVCSDLLINIT';
  cJediVCSDLLFinalizeFuncName = 'JEDIVCSDLLFINALIZE';
  cJediVCSDLLInitHistoryFuncName = 'JEDIVCSDLLHISTORYINIT';
  cJediVCSDLLInitOperationFuncName = 'JEDIVCSDLLOPERATIONINIT';

type
  TIDECloseProject = function: Boolean; stdcall;

  TIDECloseFile = function(const AFileName: PAnsiChar): Boolean; stdcall;
  TIDESaveFile  = function(const AFileName: PAnsiChar): Boolean; stdcall;
  TIDEOpenFile  = function(const AFileName: PAnsiChar): Boolean; stdcall;

  TIDEGetParentHandle = function: HWND; stdcall;

  TIDEGetProjectName = procedure(AProjectName: PAnsiChar); stdcall;
  TIDEGetUnitCount = function: Integer; stdcall;
  TIDEGetUnitName = procedure(const AIndex: Integer; AUnitName: PAnsiChar); stdcall;

  TIDEGetFormCount = function: Integer; stdcall;
  TIDEGetFormName = procedure(const AIndex: Integer; AFormName: PAnsiChar); stdcall;

  TIDEGetCurrentFile = procedure(ACurrentFile: PAnsiChar); stdcall;

  TIDEIsFileOpen = function(const AFileName: PAnsiChar): Boolean; stdcall;

  TIDEGetModuleCount = function: Integer; stdcall;
  TIDEGetModuleName = procedure(const AIndex: Integer; AModuleName: PAnsiChar); stdcall;
  TIDEGetComponentCount = function(const AModIndex: Integer): Integer; stdcall;
  TIDEGetComponentName = procedure(const AModIndex, ACompIndex: Integer;
    AComponentName: PAnsiChar); stdcall;

  TIDERaiseException = procedure(const AMessage: PAnsiChar); stdcall;

  TIDEGetBaseRegistryKey = procedure(ABaseRegistryKey: PAnsiChar); stdcall;

  TIDEGetModuleComponentCount = function(const AModuleName: PAnsiChar): Integer;
      stdcall;
  TIDEGetModuleComponent = function(const AModuleName: PAnsiChar; const AIndex: Integer;
    ACompName, ACompType: PAnsiChar): Boolean; stdcall;
  TIDESourceWriteString = function(const AModuleName: PAnsiChar; const APos: Integer;
    const AContent: PAnsiChar): Boolean; stdcall;
  TIDESourceReadString = function(const AModuleName: PAnsiChar; const APos: Integer;
    AContent: PAnsiChar; const AReadSize: Integer): Integer; stdcall;

  TIDEGetOptions = function: TIDEInterfaceOptions; stdcall;

  TIDEIsFileOpenAndWriteable = function(const AFileName: PAnsiChar): Boolean; stdcall;
  
  TExternalIDEFunctionRec = record
    CloseProject: TIDECloseProject;

    CloseFile: TIDECloseFile;
    SaveFile : TIDESaveFile;
    OpenFile : TIDEOpenFile;

    GetParentHandle : TIDEGetParentHandle;

    GetProjectName: TIDEGetProjectName;
    GetUnitCount  : TIDEGetUnitCount;
    GetUnitName   : TIDEGetUnitName;

    GetFormCount: TIDEGetFormCount;
    GetFormName : TIDEGetFormName;

    GetCurrentFile: TIDEGetCurrentFile;

    IsFileOpen: TIDEIsFileOpen;

    GetModuleCount   : TIDEGetModuleCount;
    GetModuleName    : TIDEGetModuleName;
    GetComponentCount: TIDEGetComponentCount;
    GetComponentName : TIDEGetComponentName;

    RaiseException: TIDERaiseException;

    GetBaseRegistryKey: TIDEGetBaseRegistryKey;

    GetModuleComponentCount: TIDEGetModuleComponentCount;
    GetModuleComponent     : TIDEGetModuleComponent;
    SourceWriteString      : TIDESourceWriteString;
    SourceReadString       : TIDESourceReadString;

    GetOptions: TIDEGetOptions;
    
    IsFileOpenAndWriteable: TIDEIsFileOpenAndWriteable;
    
  end;
  PExternalIDEFunctionRec = ^TExternalIDEFunctionRec;

  TGetIDString       = procedure(AIDString: PAnsiChar); stdcall;
  TExecuteVerb       = procedure(const AIndex: Integer); stdcall;
  TGetMenuName       = procedure(AMenuName: PAnsiChar); stdcall;
  TGetVerb           = procedure(const AIndex: Integer; AVerb: PAnsiChar); stdcall;
  TGetVerbCount      = function: Integer; stdcall;
  TGetVerbState      = function(const AIndex: Integer): Word; stdcall;
  TProjectChange     = procedure; stdcall;
  TGetVerbImages     = function(ABMPContent: Pointer; const AMaxBMPContentSize,
    AImageWidth, AImageHeight: Integer; var ABMPContentSize: Integer): TGetVerbImagesResult; stdcall;
  TGetVerbImageIndex = function(const AIndex: Integer): Integer; stdcall;
  TGetVerbShortCut   = function(const AIndex: Integer): Word; stdcall;

  TExternalVCSFunctionRec = record
    GetIDString      : TGetIDString;
    ExecuteVerb      : TExecuteVerb;
    GetMenuName      : TGetMenuName;
    GetVerb          : TGetVerb;
    GetVerbCount     : TGetVerbCount;
    GetVerbState     : TGetVerbState;
    ProjectChange    : TProjectChange;
    GetVerbImages    : TGetVerbImages;
    GetVerbImageIndex: TGetVerbImageIndex;
    GetVerbShortCut  : TGetVerbShortCut;
  end;
  PExternalVCSFunctionRec = ^TExternalVCSFunctionRec;

  TIDEFileNotificationFunc = procedure(const ANotifyCode: TIDEFileNotification;
    const AFileName: PAnsiChar; var ACancel: Boolean); stdcall;
  TIDEEventNotificationFunc = procedure(const ANotifyCode: TIDEEventNotification;
    var ACancel: Boolean); stdcall;

  TExternalNotifierFunctionRec = record
    FileNotification : TIDEFileNotificationFunc;
    EventNotification: TIDEEventNotificationFunc;
  end;
  PExternalNotifierFunctionRec = ^TExternalNotifierFunctionRec;

  TJediVCSDLLInit = function(AExternalIDEFunctionRec: PExternalIDEFunctionRec;
    AExternalVCSFunctionRec: PExternalVCSFunctionRec;
    AExternalNotifierFunctionRec: PExternalNotifierFunctionRec): Boolean; stdcall;
  TJediVCSDLLFinalize = procedure; stdcall; 

  TGetModuleHistoryCount = function(AModuleName: PAnsiChar): Integer; stdcall;
  TGetModuleHistoryAuthor = function(AModuleName: PAnsiChar; AIndex: Integer; AnAuthor: PAnsiChar): Boolean; stdcall;
  TGetModuleHistoryVersionRevisionStr = function(AModuleName: PAnsiChar; AIndex: Integer; AVersionStr: PAnsiChar): Boolean; stdcall;
  TGetModuleHistoryLabelCount = function(AModuleName: PAnsiChar; AIndex: Integer): Integer; stdcall;
  TGetModuleHistoryLabel = function(AModuleName: PAnsiChar; AIndex: Integer; ALabelIndex: Integer; ALabelStr: PAnsiChar): Boolean; stdcall;
  TGetModuleHistoryDate = function(AModuleName: PAnsiChar; AIndex: Integer; var ADate: TDateTime): Boolean; stdcall;
  TGetModuleHistoryComment = function(AModuleName: PAnsiChar; AIndex: Integer; AComment: PAnsiChar; AMaxCommentSize: Integer): Boolean; stdcall;
  TGetModuleHistoryContentSize = function(AModuleName: PAnsiChar; AIndex: Integer): Integer; stdcall;
  TGetModuleHistoryContent = function(AModuleName: PAnsiChar; AIndex: Integer; AContentPtr: Pointer): Boolean; stdcall;

  PExternalVCSModuleHistoryFunctionRec = ^TExternalVCSModuleHistoryFunctionRec;
  TExternalVCSModuleHistoryFunctionRec = record
    GetModuleHistoryCount             : TGetModuleHistoryCount;
    GetModuleHistoryAuthor            : TGetModuleHistoryAuthor;
    GetModuleHistoryVersionRevisionStr: TGetModuleHistoryVersionRevisionStr;
    GetModuleHistoryLabelCount        : TGetModuleHistoryLabelCount;
    GetModuleHistoryLabel             : TGetModuleHistoryLabel;
    GetModuleHistoryDate              : TGetModuleHistoryDate;
    GetModuleHistoryComment           : TGetModuleHistoryComment;
    GetModuleHistoryContentSize       : TGetModuleHistoryContentSize;
    GetModuleHistoryContent           : TGetModuleHistoryContent;
  end;

  TJediVCSDLLHistoryInit = function(AExternalVCSModuleHistoryFunctionRec: PExternalVCSModuleHistoryFunctionRec): Boolean; stdcall;

  TOperationGetProjectID = function(AProjectName: PAnsiChar): Integer; stdcall;
  TOperationCheckInModule = function(AProjectID: Integer; AModuleName: PAnsiChar): Boolean; stdcall;
  TOperationCheckOutModule = function(AProjectID: Integer; AModuleName: PAnsiChar): Boolean; stdcall;
  TOperationGetModule = function(AProjectID: Integer; AModuleName: PAnsiChar): Boolean; stdcall;
  TOperationCompareModule = function(AProjectID: Integer; AModuleName, AModuleMember: PAnsiChar): Boolean; stdcall;
  TOperationShowModuleHistory = function(AProjectID: Integer; AModuleName: PAnsiChar): Boolean; stdcall;
  TOperationShowProjectManager = function(AProjectID: Integer): Boolean; stdcall;  
  TOperationShowProjectHistory = function(AProjectID: Integer): Boolean; stdcall;
  TOperationSyncProject = function(AProjectID: Integer): Boolean; stdcall;
  TOperationDiffModule = TOperationCompareModule;

  PExternalVCSOperationFunctionRec = ^TExternalVCSOperationFunctionRec;
  TExternalVCSOperationFunctionRec = record
    GetProjectID      : TOperationGetProjectID;
    CheckInModule     : TOperationCheckInModule;
    CheckOutModule    : TOperationCheckOutModule;
    GetModule         : TOperationGetModule;
    CompareModule     : TOperationCompareModule;
    ShowModuleHistory : TOperationShowModuleHistory;
    ShowProjectManager: TOperationShowProjectManager;    
    ShowProjectHistory: TOperationShowProjectHistory;
    SyncProject       : TOperationSyncProject;
    DiffModule        : TOperationDiffModule;
  end;

  TJediVCSDLLOperationInit = function(AExternalVCSOperationFunctionRec: PExternalVCSOperationFunctionRec): Boolean; stdcall;
{$ENDIF FUNCTIONRECS}

{$IFDEF OLDOTA}
function TFN2TIDEFN(ANotifyCode: TFileNotification): TIDEFileNotification;
  {$IFDEF DELPHI3_UP}
function TEvN2TIDEEvN(ANotifyCode: TEventNotification): TIDEEventNotification;
  {$ENDIF DELPHI3_UP}
{$ENDIF OLDOTA}

implementation

{$IFDEF OLDOTA}
function TFN2TIDEFN(ANotifyCode: TFileNotification): TIDEFileNotification;
begin
  case ANotifyCode of
    fnFileOpening        : Result := ifnFileOpening;
    fnFileOpened         : Result := ifnFileOpened;
    fnFileClosing        : Result := ifnFileClosing;
    fnProjectOpening     : Result := ifnProjectOpening;
    fnProjectOpened      : Result := ifnProjectOpened;
    fnProjectClosing     : Result := ifnProjectClosing;
    fnAddedToProject     : Result := ifnAddedToProject;
    fnRemovedFromProject : Result := ifnRemovedFromProject;
    fnDefaultDesktopLoad : Result := ifnDefaultDesktopLoad;
    fnDefaultDesktopSave : Result := ifnDefaultDesktopSave;
    fnProjectDesktopLoad : Result := ifnProjectDesktopLoad;
    fnprojectDesktopSave : Result := ifnprojectDesktopSave;
    {$IFDEF DELPHI3_UP}
    fnPackageInstalled   : Result := ifnPackageInstalled;
    fnPackageUninstalled : Result := ifnPackageUninstalled;
    {$ENDIF DELPHI3_UP}
  end;
end;

{$IFDEF DELPHI3_UP}
function TEvN2TIDEEvN(ANotifyCode: TEventNotification): TIDEEventNotification;
begin
  case ANotifyCode of
    enBeforeCompile : Result := ienBeforeCompile;
    enAfterCompile  : Result := ienAfterCompile;
  end;
end;
{$ENDIF DELPHI3_UP}
{$ENDIF OLDOTA}

end.
