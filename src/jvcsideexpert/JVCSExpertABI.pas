(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSIDEInterfaceCommon.pas (src\common)

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

-----------------------------------------------------------------------------

Unit JVCSExpertABI - ABI expert <-> JvcsExternalDll.dll

  Copia FIEL das declaracoes da parte FUNCTIONRECS de
  src\common\JVCSIDEInterfaceCommon.pas (JEDI VCS 2.5, Mantis #5101).

  Por que uma copia: a unit original inclui jedi.inc e compopt.inc, e o
  compopt.inc forca $IMAGEBASE $00400000, $APPTYPE GUI, $MINSTACKSIZE, $T- e
  DEBUG/MEMCHECK - diretivas que nao podem vazar para o expert. Os layouts,
  a ordem dos campos, a convencao (stdcall) e os tipos (PAnsiChar, Boolean de
  1 byte, enums/sets de 1 byte, Word) sao os mesmos; as verificacoes de tamanho
  no fim da interface quebram a compilacao se algo divergir.

  Se mudar algo aqui, mude tambem em src\common\JVCSIDEInterfaceCommon.pas
  (e vice-versa): a JvcsExternalDll.dll 2.5.0.1030 (Delphi 2007, ANSI) usa
  exatamente estes layouts.

  Historico:
  2026/10/12  v2026 - criada a partir de JVCSIDEInterfaceCommon.pas
-----------------------------------------------------------------------------*)

unit JVCSExpertABI;

{$Z1}  // enums de 1 byte, como no Delphi 2007 (compopt.inc: Z1)
{$A8}

interface

uses
  Winapi.Windows;

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

  cJediVCSDLLInitFuncName = 'JEDIVCSDLLINIT';
  cJediVCSDLLFinalizeFuncName = 'JEDIVCSDLLFINALIZE';
  cJediVCSDLLInitHistoryFuncName = 'JEDIVCSDLLHISTORYINIT';
  cJediVCSDLLInitOperationFuncName = 'JEDIVCSDLLOPERATIONINIT';

  // Tamanho dos buffers "array[0..255] of Char" que a DLL entrega ao expert
  // (GetProjectName, GetUnitName, GetFormName, GetCurrentFile, GetModuleName,
  // GetComponentName, GetBaseRegistryKey, GetModuleComponent). O expert copia
  // no maximo cDllNameBufferMaxLen caracteres + #0.
  cDllNameBufferSize = 256;
  cDllNameBufferMaxLen = cDllNameBufferSize - 1;

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

  // 24 ponteiros - preenchido pelo EXPERT; a DLL guarda o ponteiro do record
  // ate o JEDIVCSDLLFINALIZE (por isso ele vive dentro de um objeto estavel).
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

  // 10 ponteiros - preenchido pela DLL em JEDIVCSDLLINIT
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

  // 2 ponteiros - preenchido pela DLL em JEDIVCSDLLINIT
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

  // 9 ponteiros - preenchido pela DLL em JEDIVCSDLLHISTORYINIT
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

  // 10 ponteiros - preenchido pela DLL em JEDIVCSDLLOPERATIONINIT
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

// Verificacoes de layout (ver doc\pt\client\Expert-IDE-Analise.md, 3.2/6.3):
// 24 / 10 / 2 / 9 / 10 ponteiros e tipos escalares de 1 byte.
{$IF SizeOf(TExternalIDEFunctionRec) <> 24 * SizeOf(Pointer)}
  {$MESSAGE FATAL 'JVCSExpertABI: TExternalIDEFunctionRec deve ter 24 ponteiros'}
{$ENDIF}
{$IF SizeOf(TExternalVCSFunctionRec) <> 10 * SizeOf(Pointer)}
  {$MESSAGE FATAL 'JVCSExpertABI: TExternalVCSFunctionRec deve ter 10 ponteiros'}
{$ENDIF}
{$IF SizeOf(TExternalNotifierFunctionRec) <> 2 * SizeOf(Pointer)}
  {$MESSAGE FATAL 'JVCSExpertABI: TExternalNotifierFunctionRec deve ter 2 ponteiros'}
{$ENDIF}
{$IF SizeOf(TExternalVCSModuleHistoryFunctionRec) <> 9 * SizeOf(Pointer)}
  {$MESSAGE FATAL 'JVCSExpertABI: TExternalVCSModuleHistoryFunctionRec deve ter 9 ponteiros'}
{$ENDIF}
{$IF SizeOf(TExternalVCSOperationFunctionRec) <> 10 * SizeOf(Pointer)}
  {$MESSAGE FATAL 'JVCSExpertABI: TExternalVCSOperationFunctionRec deve ter 10 ponteiros'}
{$ENDIF}
{$IF (SizeOf(TIDEFileNotification) <> 1) or (SizeOf(TIDEEventNotification) <> 1) or
     (SizeOf(TIDEInterfaceOptions) <> 1) or (SizeOf(TGetVerbImagesResult) <> 1) or
     (SizeOf(Boolean) <> 1)}
  {$MESSAGE FATAL 'JVCSExpertABI: enums/sets/Boolean da ABI devem ter 1 byte'}
{$ENDIF}

implementation

end.
