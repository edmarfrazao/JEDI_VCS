(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSIDEInterface.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2003/04/07  USchuster - new unit
2003/05/31  USchuster - changes for external IDE interface
2003/08/22  USchuster - added ZeroByte to the end of the stream in
                        IDESource2Stream (this caused mantis #1061)
2003/09/29  USchuster - introduced property TIDEInterface.Options
2005/01/30  THuber    - introduced property TIDEInterface.JVCSIDESettings
                        for detection and settings of IDE which loads JVCS IDE DLL
2005/06/22  CSchuette - introduced TIDEInterface.IsFileOpenAndWriteable
^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC3 released ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
2005/06/22  THuber    - hints removed
2008/02/17  USchuster - Trace -> TraceMsg

-----------------------------------------------------------------------------*)

unit JVCSIDEInterface;

{$I jedi.inc}
{$I compopt.inc}

{$IFDEF DELPHI6_UP}
  {$WARN SYMBOL_PLATFORM OFF}
{$ENDIF DELPHI6_UP}

{
  !!! Don't change the switches !!!
}
{$IFDEF EXT_IDE_INTF}
  {$DEFINE EXTERNAL_INTERFACE}
{$ELSE}
  {$DEFINE INTERNAL_OLDOTA}
{$ENDIF}

interface

uses
    Windows
  , Classes
  , JVCSIDEInterfaceCommon
  , JVCSIDESettings
{$IFDEF INTERNAL_OLDOTA}
  ,ToolIntf, EditIntf, VCSIntf
{$ENDIF}
  ;

type
  TComponentListEntry = record
    CompType, CompName: string;
  end;
  PComponentListEntry = ^TComponentListEntry;

  TIDEAddInNotifier = class;

  TIDEInterface = class(TObject)
  private
    FJVCSIDESettings: TJVCSIDESettings;
  protected
    FIDEInterfaceOptions: TIDEInterfaceOptions;
  public
    constructor Create;
    destructor Destroy; override;

    function CloseProject: Boolean; virtual; abstract;

    function CloseFile(const AFileName: string): Boolean; virtual; abstract;
    function SaveFile(const AFileName: string): Boolean; virtual; abstract;
    function OpenFile(const AFileName: string): Boolean; virtual; abstract;

    function GetParentHandle: HWND; virtual; abstract;

    function GetProjectName: string; virtual; abstract;
    function GetUnitCount: Integer; virtual; abstract;
    function GetUnitName(const AIndex: Integer): string; virtual; abstract;

    function GetFormCount: Integer; virtual; abstract;
    function GetFormName(const AIndex: Integer): string; virtual; abstract;

    function GetCurrentFile: string; virtual; abstract;

    function IsFileOpen(const AFileName: string): Boolean; virtual; abstract;
    function IsFileOpenAndWriteable(const AFileName: string): Boolean; virtual; abstract;

    function GetModuleCount: Integer; virtual; abstract;
    function GetModuleName(const AIndex: Integer): string; virtual; abstract;
    function GetComponentCount(const AModIndex: Integer): Integer; virtual;
      abstract;
    function GetComponentName(const AModIndex, ACompIndex: Integer): string;
      virtual; abstract;

    function AddNotifierEx(AddInNotifier: TIDEAddInNotifier): Boolean;
      virtual; abstract;
    function RemoveNotifier(AddInNotifier: TIDEAddInNotifier): Boolean;
      virtual; abstract;

    procedure RaiseException(const AMessage: string); virtual; abstract;

    function GetBaseRegistryKey: string; virtual; abstract;

    function GetModuleComponents(const AModuleName: string;
      AModuleList: TList): Boolean; virtual; abstract;
    function SourceWriteString(const AModuleName: string; const APos: Integer;
      const AContent: string): Boolean; virtual; abstract;
    function SourceReadString(const AModuleName: string; const APos: Integer;
      var AContent: string; const AReadSize: Integer): Integer; virtual; abstract;

    property Options: TIDEInterfaceOptions read FIDEInterfaceOptions;

    property JVCSIDESettings: TJVCSIDESettings read FJVCSIDESettings;

  end;

{$IFDEF INTERNAL_OLDOTA}
  TOldOTAIDEInterface = class(TIDEInterface)
  private
    FToolInterface: TIToolServices;
    {$IFDEF DEBUG}
    procedure CheckToolInterface;
    {$ENDIF}
  public
    constructor Create(AToolInterface: TIToolServices);

    function CloseProject: Boolean; override;

    function CloseFile(const AFileName: string): Boolean; override;
    function SaveFile(const AFileName: string): Boolean; override;
    function OpenFile(const AFileName: string): Boolean; override;

    function GetParentHandle: HWND; override;

    function GetProjectName: string; override;
    function GetUnitCount: Integer; override;
    function GetUnitName(const AIndex: Integer): string; override;

    function GetFormCount: Integer; override;
    function GetFormName(const AIndex: Integer): string; override;

    function GetCurrentFile: string; override;

    function IsFileOpen(const AFileName: string): Boolean; override;
    function IsFileOpenAndWriteable(const AFileName: string): Boolean; override;

    function GetModuleCount: Integer; override;
    function GetModuleName(const AIndex: Integer): string; override;
    function GetComponentCount(const AModIndex: Integer): Integer; override;
    function GetComponentName(const AModIndex, ACompIndex: Integer): string; override;

    function AddNotifierEx(AddInNotifier: TIDEAddInNotifier): Boolean; override;
    function RemoveNotifier(AddInNotifier: TIDEAddInNotifier): Boolean; override;

    procedure RaiseException(const AMessage: string); override;

    function GetBaseRegistryKey: string; override;

    function GetModuleComponents(const AModuleName: string;
      AModuleList: TList): Boolean; override;
    function SourceWriteString(const AModuleName: string; const APos: Integer;
      const AContent: string): Boolean; override;
    function SourceReadString(const AModuleName: string; const APos: Integer;
      var AContent: string; const AReadSize: Integer): Integer; override;

    property ToolInterface: TIToolServices read FToolInterface write FToolInterface;
  end;
{$ENDIF}

{$IFDEF EXTERNAL_INTERFACE}
  TIToolServices = PExternalIDEFunctionRec;

  TExternalIDEInterface = class(TIDEInterface)
  private
    FFuncRecPtr: PExternalIDEFunctionRec;
    {$IFDEF DEBUG}
    procedure CheckFuncRecPtr(AFunction: string);
    procedure CheckFuncRecPtrFkt(APtrValid: Boolean; AFunction: string);
    {$ENDIF}
  public
    constructor Create(AFuncRecPtr: PExternalIDEFunctionRec);

    function CloseProject: Boolean; override;

    function CloseFile(const AFileName: string): Boolean; override;
    function SaveFile(const AFileName: string): Boolean; override;
    function OpenFile(const AFileName: string): Boolean; override;

    function GetParentHandle: HWND; override;

    function GetProjectName: string; override;
    function GetUnitCount: Integer; override;
    function GetUnitName(const AIndex: Integer): string; override;

    function GetFormCount: Integer; override;
    function GetFormName(const AIndex: Integer): string; override;

    function GetCurrentFile: string; override;

    function IsFileOpen(const AFileName: string): Boolean; override;
    function IsFileOpenAndWriteable(const AFileName: string): Boolean; override;

    function GetModuleCount: Integer; override;
    function GetModuleName(const AIndex: Integer): string; override;
    function GetComponentCount(const AModIndex: Integer): Integer; override;
    function GetComponentName(const AModIndex, ACompIndex: Integer): string; override;

    function AddNotifierEx(AddInNotifier: TIDEAddInNotifier): Boolean; override;
    function RemoveNotifier(AddInNotifier: TIDEAddInNotifier): Boolean; override;

    procedure RaiseException(const AMessage: string); override;

    function GetBaseRegistryKey: string; override;

    function GetModuleComponents(const AModuleName: string;
      AModuleList: TList): Boolean; override;
    function SourceWriteString(const AModuleName: string; const APos: Integer;
      const AContent: string): Boolean; override;
    function SourceReadString(const AModuleName: string; const APos: Integer;
      var AContent: string; const AReadSize: Integer): Integer; override;

    property FunctionRecPtr: PExternalIDEFunctionRec read FFuncRecPtr write FFuncRecPtr;
  end;
{$ENDIF}

{$IFNDEF EXTERNAL_INTERFACE}
  TIDEVCSClient = class(TIVCSClient);
{$ELSE}
  TIDEVCSClient = class
  public
    function GetIDString: string; virtual; abstract;
    procedure ExecuteVerb(Index: Integer); virtual; abstract;
    function GetMenuName: string; virtual; abstract;
    function GetVerb(Index: Integer): string; virtual; abstract;
    function GetVerbCount: Integer; virtual; abstract;
    function GetVerbState(Index: Integer): Word; virtual; abstract;
    procedure ProjectChange; virtual; abstract;
  end;
{$ENDIF}

{$IFNDEF EXTERNAL_INTERFACE}
  TIDEAddInNotifier = class(TIAddInNotifier)
  public
    procedure FileNotification(NotifyCode: TFileNotification;
      const FileName: string; var Cancel: Boolean); override;
    procedure EventNotification(NotifyCode: TEventNotification;
      var Cancel: Boolean); override;
{$ELSE}
  TIDEAddInNotifier = class
  public
{$ENDIF}
    procedure IDEFileNotification(NotifyCode: TIDEFileNotification;
      const FileName: string; var Cancel: Boolean); virtual; abstract;
    procedure IDEEventNotification(NotifyCode: TIDEEventNotification;
      var Cancel: Boolean); virtual; abstract;
  end;

function IDESourceWriteString(const AModuleName: string; AContent: string): Boolean;
function IDEModuleComponentsToStringList(const AFormName, AModuleName: string;
  AComponentStringList: TStrings): Boolean;
function IDESource2Stream(const AModuleName: string; AModuleStream: TStream): Boolean;

function ReleaseException: string;

function CreateIDEInterface(VCSInterface: TIToolServices): TIDEInterface;

implementation

uses
  {$IFDEF DEBUG}
  JclDebug,
  {$ENDIF}
  VCSBase,
  SysUtils,
  ConfigStorage;

function CreateIDEInterface(VCSInterface: TIToolServices): TIDEInterface;
begin
  Result :=
  {$IFNDEF EXTERNAL_INTERFACE}
    TOldOTAIDEInterface.Create(VCSInterface);
  {$ELSE}
    TExternalIDEInterface.Create(VCSInterface);
  {$ENDIF}
end;

function ReleaseException: string;
begin
  Result := Exception(ExceptObject).Message;
end;

function IDESourceWriteString(const AModuleName: string; AContent: string): Boolean;
var
  _Pos: Integer;
const
  cr = Chr(13) + Chr(10);
begin
  Result := False;
  // prüfen, ob Datei read-only
  if (FileGetAttr(AModuleName) and $00000001) = $00000001 then 
    Exit;
  // String auf Länge 80 Z

  if not jvcsReadBool(sBaseRegistryKey + crbOptions, 'MarkSource_Break', True) then
  begin
    if Length(AContent) > 80 then
    begin
      _Pos := 70;
      while _Pos < Length(AContent) do 
      begin
        if AContent[_Pos] = ' ' then
        begin
          Insert(cr + '  ', AContent, _Pos);
          Break;
        end;
        Inc(_Pos);
      end;
    end; // if Length(Value) > 80 then begin
    // String auf Länge 160 Z
    if Length(AContent) > 160 then
    begin
      _Pos := 150;
      while _Pos < Length(AContent) do
      begin
        if AContent[_Pos] = ' ' then
        begin
          Insert(cr + '  ', AContent, _Pos);
          Break;
        end;
        Inc(_Pos);
      end;
    end; // if Length(Value) > 160 then begin
  end
  else 
  begin
    _Pos := 1;
    while _Pos < Length(AContent) do
    begin
      if (AContent[_Pos] = #10) or (AContent[_Pos] = #13) then
      begin
        System.Delete(AContent, _Pos, 1);
        System.Insert('\', AContent, _Pos);
      end;
      Inc(_Pos);
    end;
  end; 
  AContent := AContent + cr;
  if Assigned(IDEInterface) then
    Result := IDEInterface.SourceWriteString(AModuleName, 0, AContent);
end;

function IDEModuleComponentsToStringList(const AFormName, AModuleName: string;
  AComponentStringList: TStrings): Boolean;
var
  ComponentList: TList;
  I: Integer;
begin
  Result := False;
  if Assigned(AComponentStringList) then
  begin
    ComponentList := nil;
    try
      ComponentList := TList.Create;
      Result := IDEInterface.GetModuleComponents(AModuleName, ComponentList);
      if Result then
      begin
        for I := 0 to Pred(ComponentList.Count) do
          with PComponentListEntry(ComponentList[I])^ do
            AComponentStringList.Add(AFormName + '|' + CompType + '|' + CompName);
      end;
      for I := 0 to Pred(ComponentList.Count) do
        Dispose(ComponentList[I]);
    finally
      ComponentList.Free;
    end;
  end;
end;

function IDESource2Stream(const AModuleName: string; AModuleStream: TStream): Boolean;
const
  BufferSize = 2048;
var
  FS: TFileStream;
  SPos: Integer;
  Content: string;
  ReadCount: Integer;
  ZeroByte: Byte;
begin
  Result := False;
  if Assigned(AModuleStream) then
  begin
    if IDEInterface.IsFileOpen(AModuleName) then
    begin
      SPos := 0;
      ReadCount := BufferSize;
      while ReadCount = BufferSize do
      begin
        ReadCount := IDEInterface.SourceReadString(AModuleName, SPos, Content,
          BufferSize);
        Inc(SPos, ReadCount);
        if ReadCount > 0 then
          AModuleStream.Write(Content[1], ReadCount);
      end;
      Result := True;
    end
    else if FileExists(AModuleName) then
    begin
      FS := nil;
      try
        FS := TFileStream.Create(AModuleName, fmOpenRead);
        AModuleStream.CopyFrom(FS, 0);
        Result := True;
      finally
        FS.Free;
      end;
    end;
    //USc - add zero to the end of stream to avoid parsing over the end of the
    //      stream (mantis #1061)
    ZeroByte := 0;
    AModuleStream.Write(ZeroByte, 1);
  end;
end;

constructor TIDEInterface.Create;
begin
{$IFDEF DEBUG} TraceMsg('> TIDEInterface.Create'); {$ENDIF DEBUG}

  inherited Create;

  FIDEInterfaceOptions := [];
  // detect used IDE over IDE filename
  FJVCSIDESettings := TJVCSIDESettings.Create(ParamStr(0));

{$IFDEF DEBUG} TraceFmt('  TIDEInterface.Create IDE=%d, Version=%s <', [Ord(FJVCSIDESettings.Product), FJVCSIDESettings.Version]); {$ENDIF DEBUG}
end;

destructor TIDEInterface.Destroy;
begin
{$IFDEF DEBUG} TraceMsg('> TIDEInterface.Destroy'); {$ENDIF DEBUG}

  FJVCSIDESettings.Free;

  inherited Destroy;

{$IFDEF DEBUG} TraceMsg('  TIDEInterface.Destroy <'); {$ENDIF DEBUG}
end;

{$IFDEF INTERNAL_OLDOTA}
{$IFDEF DEBUG}
procedure TOldOTAIDEInterface.CheckToolInterface;
begin
  Assert(Assigned(FToolInterface),
    '"TOldOTAIDEInterface.FToolInterface" is not Assigned');
end;
{$ENDIF}

constructor TOldOTAIDEInterface.Create(AToolInterface: TIToolServices);
begin
  inherited Create;

  FToolInterface := AToolInterface;
end;

function TOldOTAIDEInterface.CloseProject: Boolean;
begin
  {$IFDEF DEBUG}CheckToolInterface;{$ENDIF}
  Result := FToolInterface.CloseProject;
end;

function TOldOTAIDEInterface.CloseFile(const AFileName: string): Boolean;
begin
  {$IFDEF DEBUG}CheckToolInterface;{$ENDIF}
  Result := FToolInterface.CloseFile(AFileName);
end;

function TOldOTAIDEInterface.SaveFile(const AFileName: string): Boolean;
begin
  {$IFDEF DEBUG}CheckToolInterface;{$ENDIF}
  Result := FToolInterface.SaveFile(AFileName);
end;

function TOldOTAIDEInterface.OpenFile(const AFileName: string): Boolean;
begin
  {$IFDEF DEBUG}CheckToolInterface;{$ENDIF}
  Result := FToolInterface.OpenFile(AFileName);
end;

function TOldOTAIDEInterface.GetParentHandle: HWND;
begin
  {$IFDEF DEBUG}CheckToolInterface;{$ENDIF}
  Result := FToolInterface.GetParentHandle;
end;

function TOldOTAIDEInterface.GetProjectName: string;
begin
  {$IFDEF DEBUG}CheckToolInterface;{$ENDIF}
  Result := FToolInterface.GetProjectName;
end;

function TOldOTAIDEInterface.GetUnitCount: Integer;
begin
  {$IFDEF DEBUG}CheckToolInterface;{$ENDIF}
  Result := FToolInterface.GetUnitCount;
end;

function TOldOTAIDEInterface.GetUnitName(const AIndex: Integer): string;
begin
  {$IFDEF DEBUG}CheckToolInterface;{$ENDIF}
  Result := FToolInterface.GetUnitName(AIndex);
end;

function TOldOTAIDEInterface.GetFormCount: Integer;
begin
  {$IFDEF DEBUG}CheckToolInterface;{$ENDIF}
  Result := FToolInterface.GetFormCount;
end;

function TOldOTAIDEInterface.GetFormName(const AIndex: Integer): string;
begin
  {$IFDEF DEBUG}CheckToolInterface;{$ENDIF}
  Result := FToolInterface.GetFormName(AIndex);
end;

function TOldOTAIDEInterface.GetCurrentFile: string;
begin
  {$IFDEF DEBUG}CheckToolInterface;{$ENDIF}
  Result := FToolInterface.GetCurrentFile;
end;

function TOldOTAIDEInterface.IsFileOpen(const AFileName: string): Boolean;
begin
  {$IFDEF DEBUG}CheckToolInterface;{$ENDIF}
  Result := FToolInterface.IsFileOpen(AFileName);
end;

function TOldOTAIDEInterface.IsFileOpenAndWriteable(const AFileName: string): Boolean;
begin
  {$IFDEF DEBUG}CheckToolInterface;{$ENDIF}
  
  // This is not supported in old interface, so return TRUE if the file is open
  Result := FToolInterface.IsFileOpen(AFileName);
end;

function TOldOTAIDEInterface.GetModuleCount: Integer;
begin
  {$IFDEF DEBUG}CheckToolInterface;{$ENDIF}
  Result := FToolInterface.GetModuleCount;
end;

function TOldOTAIDEInterface.GetModuleName(const AIndex: Integer): string;
begin
  {$IFDEF DEBUG}CheckToolInterface;{$ENDIF}
  Result := FToolInterface.GetModuleName(AIndex);
end;

function TOldOTAIDEInterface.GetComponentCount(const AModIndex: Integer): Integer;
begin
  {$IFDEF DEBUG}CheckToolInterface;{$ENDIF}
  Result := FToolInterface.GetComponentCount(AModIndex);
end;

function TOldOTAIDEInterface.GetComponentName(const AModIndex,
  ACompIndex: Integer): string;
begin
  {$IFDEF DEBUG}CheckToolInterface;{$ENDIF}
  Result := FToolInterface.GetComponentName(AModIndex, ACompIndex);
end;

function TOldOTAIDEInterface.AddNotifierEx(AddInNotifier: TIDEAddInNotifier): Boolean;
begin
  {$IFDEF DEBUG}CheckToolInterface;{$ENDIF}
  Result := FToolInterface.AddNotifierEx(AddInNotifier);
end;

function TOldOTAIDEInterface.RemoveNotifier(AddInNotifier: TIDEAddInNotifier): Boolean;
begin
  {$IFDEF DEBUG}CheckToolInterface;{$ENDIF}
  Result := FToolInterface.RemoveNotifier(AddInNotifier);
end;

procedure TOldOTAIDEInterface.RaiseException(const AMessage: string);
begin
  {$IFDEF DEBUG}CheckToolInterface;{$ENDIF}
  FToolInterface.RaiseException(AMessage);
end;

function TOldOTAIDEInterface.GetBaseRegistryKey: string;
begin
  {$IFDEF DEBUG}CheckToolInterface;{$ENDIF}
  Result := FToolInterface.GetBaseRegistryKey;
end;

function TOldOTAIDEInterface.GetModuleComponents(const AModuleName: string;
  AModuleList: TList): Boolean;
var
  ModuleInterface: TIModuleInterface;
  FormInterface: TIFormInterface;
  ComponentInterface, ChildComponent: TIComponentInterface;

  CPtr: PComponentListEntry;
  I: Integer;
  CurrCompType, CurrCompName: string;
begin
  {$IFDEF DEBUG}CheckToolInterface;{$ENDIF}
  Result := False;
  if Assigned(AModuleList) then
  begin
    ModuleInterface := ToolInterface.GetModuleInterface(AModuleName);
    if ModuleInterface <> nil then
    begin
      try
        FormInterface := ModuleInterface.GetFormInterface;
        if FormInterface <> nil then
        begin
          try
            ComponentInterface := FormInterface.GetFormComponent;
            if ComponentInterface <> nil then
            begin
              try
                for I := 0 to ComponentInterface.GetComponentCount - 1 do
                begin
                  ChildComponent := ComponentInterface.GetComponent(I);
                  if ChildComponent <> nil then
                  begin
                    try
                      CurrCompType := ChildComponent.GetComponentType;
                      if CurrCompType <> '' then
                      begin
                        ChildComponent.GetPropValueByName('Name', CurrCompName);
                        New(CPtr);
                        with CPtr^ do
                        begin
                          CompType := CurrCompType;
                          CompName := CurrCompName;
                        end;
                        AModuleList.Add(CPtr);
                      end;
                    finally
                      ChildComponent.Release;
                    end;
                  end; // if ChildComponent <> nil then begin
                end;
                // for j := 0 to ComponentInterface.GetComponentCount - 1 do begin
                Result := True;
              finally
                ComponentInterface.Release;
              end;
            end; // if ComponentInterface <> nil then begin
          finally
            FormInterface.Release;
          end;
        end; // if FormInterface <> nil then begin
      finally
        ModuleInterface.Release;
      end;
    end;
  end;
end;

function TOldOTAIDEInterface.SourceWriteString(const AModuleName: string;
  const APos: Integer; const AContent: string): Boolean;
var
  ModuleInterface: TIModuleInterface;
  EditorInterface: TIEditorInterface;
  EditWriter: TIEditWriter;
begin
  {$IFDEF DEBUG}CheckToolInterface;{$ENDIF}
  Result := False;

  ModuleInterface := nil;
  EditorInterface := nil;
  EditWriter := nil;
  try
    try
      ModuleInterface := ToolInterface.GetModuleInterface(AModuleName);
      if Assigned(ModuleInterface) then
        ModuleInterface.ShowSource;
      if Assigned(ModuleInterface) then
        EditorInterface := ModuleInterface.GetEditorInterface;
      if Assigned(EditorInterface) then
        EditWriter := EditorInterface.CreateWriter;
      //
      if Assigned(EditWriter) then
      begin
        EditWriter.CopyTo(APos);
        EditWriter.Insert(PChar(AContent));
        Result := True;
      end;
      //
    finally
      if Assigned(EditWriter) then
        EditWriter.Release;
      if Assigned(EditorInterface) then
        EditorInterface.Release;
      if Assigned(ModuleInterface) then
        ModuleInterface.Save(True);
      if Assigned(ModuleInterface) then
        ModuleInterface.Release;
    end;
  except
    {$IFDEF DEBUG}
    JclDebug.Trace('IDEWriter Error Insert: ' + AModuleName);
    {$ENDIF}
    Exit;
  end;
end;

function TOldOTAIDEInterface.SourceReadString(const AModuleName: string;
  const APos: Integer; var AContent: string; const AReadSize: Integer): Integer;
var
  ModuleInterface: TIModuleInterface;
  EditorInterface: TIEditorInterface;
  EditReader: TIEditReader;

  Buffer: PChar;
begin
  {$IFDEF DEBUG}CheckToolInterface;{$ENDIF}
  Result := 0;
  ModuleInterface := nil;
  EditorInterface := nil;
  EditReader      := nil;
  try
    ModuleInterface := ToolInterface.GetModuleInterface(AModuleName);
    if Assigned(ModuleInterface) then
    begin
      ModuleInterface.ShowSource;
      EditorInterface := ModuleInterface.GetEditorInterface;
      if Assigned(EditorInterface) then
        EditReader := EditorInterface.CreateReader;
      if Assigned(EditReader) then
      begin
        Buffer := nil;
        try
          GetMem(Buffer, AReadSize + 1);
          Result := EditReader.GetText(APos, Buffer, AReadSize);
          PByteArray(Buffer)^[Result] := 0;
          AContent := StrPas(Buffer);
        finally
          if Assigned(Buffer) then
            FreeMem(Buffer);
        end;
      end;
    end;
  finally
    if Assigned(EditReader) then
      EditReader.Release;
    if Assigned(EditorInterface) then
      EditorInterface.Release;
    if Assigned(ModuleInterface) then
      ModuleInterface.Release;
  end;
end;
{$ENDIF}

{$IFDEF EXTERNAL_INTERFACE}
{$IFDEF DEBUG}
procedure TExternalIDEInterface.CheckFuncRecPtr(AFunction: string);
begin
  if ShowDebugMsg then
    JclDebug.TraceMsg('TExternalIDEInterface.CheckFuncRecPtr: ' + AFunction);
  Assert(Assigned(FFuncRecPtr),
    '"TExternalIDEInterface.FFuncRecPtr" is not Assigned' + #13
    + 'used in function ' + AFunction);
  if (not Assigned(FFuncRecPtr)) and ShowDebugMsg then
    JclDebug.TraceMsg('"TExternalIDEInterface.FFuncRecPtr" is not Assigned' + #13
    + 'used in function ' + AFunction);
end;

procedure TExternalIDEInterface.CheckFuncRecPtrFkt(APtrValid: Boolean;
  AFunction: string);
begin
  if ShowDebugMsg then
    JclDebug.TraceMsg('TExternalIDEInterface.CheckFuncRecPtrFkt: ' + AFunction);
  Assert(APtrValid,
    '"TExternalIDEInterface.FFuncRecPtr.' + AFunction + '" is not Assigned' + #13
    + 'used in function ' + AFunction);
  if (not APtrValid) and ShowDebugMsg then
    JclDebug.TraceMsg('"TExternalIDEInterface.FFuncRecPtr.' + AFunction + '" is not Assigned'+#13
    + 'used in function ' + AFunction);
end;
{$ENDIF}

constructor TExternalIDEInterface.Create(AFuncRecPtr: PExternalIDEFunctionRec);
begin
  inherited Create;

  FFuncRecPtr := AFuncRecPtr;

  if Assigned(FFuncRecPtr) and Assigned(FFuncRecPtr^.GetOptions) then
    FIDEInterfaceOptions := FFuncRecPtr^.GetOptions;
end;

function TExternalIDEInterface.CloseProject: Boolean;
begin
  {$IFDEF DEBUG}
    CheckFuncRecPtr('CloseProject');
    CheckFuncRecPtrFkt(Assigned(FFuncRecPtr.CloseProject),'CloseProject');
  {$ENDIF}
  Result := FFuncRecPtr.CloseProject;
end;

function TExternalIDEInterface.CloseFile(const AFileName: string): Boolean;
begin
  {$IFDEF DEBUG}
    CheckFuncRecPtr('CloseFile');
    CheckFuncRecPtrFkt(Assigned(FFuncRecPtr.CloseFile),'CloseFile');
  {$ENDIF}
  Result := FFuncRecPtr.CloseFile(PChar(AFileName));
end;

function TExternalIDEInterface.SaveFile(const AFileName: string): Boolean;
begin
  {$IFDEF DEBUG}
    CheckFuncRecPtr('SaveFile');
    CheckFuncRecPtrFkt(Assigned(FFuncRecPtr.SaveFile),'SaveFile');
  {$ENDIF}
  Result := FFuncRecPtr.SaveFile(PChar(AFileName));
end;

function TExternalIDEInterface.OpenFile(const AFileName: string): Boolean;
begin
  {$IFDEF DEBUG}
    CheckFuncRecPtr('OpenFile');
    CheckFuncRecPtrFkt(Assigned(FFuncRecPtr.OpenFile),'OpenFile');
  {$ENDIF}
  Result := FFuncRecPtr.OpenFile(PChar(AFileName));
end;

function TExternalIDEInterface.GetParentHandle: HWND;
begin
  {$IFDEF DEBUG}
    CheckFuncRecPtr('GetParentHandle');
    CheckFuncRecPtrFkt(Assigned(FFuncRecPtr.GetParentHandle),'GetParentHandle');
  {$ENDIF}
  Result := FFuncRecPtr.GetParentHandle;
end;

function TExternalIDEInterface.GetProjectName: string;
var
  LProjectName: array [0..255] of Char;
begin
  {$IFDEF DEBUG}
    CheckFuncRecPtr('GetProjectName');
    CheckFuncRecPtrFkt(Assigned(FFuncRecPtr.GetProjectName),'GetProjectName');
  {$ENDIF}
  FFuncRecPtr.GetProjectName(@LProjectName);
  Result := StrPas(@LProjectName);
end;

function TExternalIDEInterface.GetUnitCount: Integer;
begin
  {$IFDEF DEBUG}
    CheckFuncRecPtr('GetUnitCount');
    CheckFuncRecPtrFkt(Assigned(FFuncRecPtr.GetUnitCount),'GetUnitCount');
  {$ENDIF}
  Result := FFuncRecPtr.GetUnitCount;
end;

function TExternalIDEInterface.GetUnitName(const AIndex: Integer): string;
var
  LUnitName: array [0..255] of Char;
begin
  {$IFDEF DEBUG}
    CheckFuncRecPtr('GetUnitName');
    CheckFuncRecPtrFkt(Assigned(FFuncRecPtr.GetUnitName),'GetUnitName');
  {$ENDIF}
  FFuncRecPtr.GetUnitName(AIndex, @LUnitName);
  Result := StrPas(@LUnitName);
end;

function TExternalIDEInterface.GetFormCount: Integer;
begin
  {$IFDEF DEBUG}
    CheckFuncRecPtr('GetFormCount');
    CheckFuncRecPtrFkt(Assigned(FFuncRecPtr.GetFormCount),'GetFormCount');
  {$ENDIF}
  Result := FFuncRecPtr.GetFormCount;
end;

function TExternalIDEInterface.GetFormName(const AIndex: Integer): string;
var
  LFormName: array [0..255] of Char;
begin
  {$IFDEF DEBUG}
    CheckFuncRecPtr('GetFormName');
    CheckFuncRecPtrFkt(Assigned(FFuncRecPtr.GetFormName),'GetFormName');
  {$ENDIF}
  FFuncRecPtr.GetFormName(AIndex, @LFormName);
  Result := StrPas(@LFormName);
end;

function TExternalIDEInterface.GetCurrentFile: string;
var
  LCurrentFile: array [0..255] of Char;
begin
  {$IFDEF DEBUG}
    CheckFuncRecPtr('GetCurrentFile');
    CheckFuncRecPtrFkt(Assigned(FFuncRecPtr.GetCurrentFile),'GetCurrentFile');
  {$ENDIF}
  FFuncRecPtr.GetCurrentFile(@LCurrentFile);
  Result := StrPas(@LCurrentFile);
end;

function TExternalIDEInterface.IsFileOpen(const AFileName: string): Boolean;
begin
  {$IFDEF DEBUG}
    CheckFuncRecPtr('IsFileOpen');
    CheckFuncRecPtrFkt(Assigned(FFuncRecPtr.IsFileOpen),'IsFileOpen');
  {$ENDIF}
  Result := FFuncRecPtr.IsFileOpen(PChar(AFileName));
end;

function TExternalIDEInterface.IsFileOpenAndWriteable(const AFileName: string): Boolean;
begin
  {$IFDEF DEBUG}
    CheckFuncRecPtr('IsFileOpenAndWriteable');
    CheckFuncRecPtrFkt(Assigned(FFuncRecPtr.IsFileOpenAndWriteable),'IsFileOpenAndWriteable');
  {$ENDIF}
  Result := FFuncRecPtr.IsFileOpenAndWriteable(PChar(AFileName));
end;

function TExternalIDEInterface.GetModuleCount: Integer;
begin
  {$IFDEF DEBUG}
    CheckFuncRecPtr('GetModuleCount');
    CheckFuncRecPtrFkt(Assigned(FFuncRecPtr.GetModuleCount),'GetModuleCount');
  {$ENDIF}
  Result := FFuncRecPtr.GetModuleCount;
end;

function TExternalIDEInterface.GetModuleName(const AIndex: Integer): string;
var
  LModuleName: array [0..255] of Char;
begin
  {$IFDEF DEBUG}
    CheckFuncRecPtr('GetModuleName');
    CheckFuncRecPtrFkt(Assigned(FFuncRecPtr.GetModuleName),'GetModuleName');
  {$ENDIF}
  FFuncRecPtr.GetModuleName(AIndex, @LModuleName);
  Result := StrPas(@LModuleName);
end;

function TExternalIDEInterface.GetComponentCount(const AModIndex: Integer): Integer;
begin
  {$IFDEF DEBUG}
    CheckFuncRecPtr('GetComponentCount');
    CheckFuncRecPtrFkt(Assigned(FFuncRecPtr.GetComponentCount),'GetComponentCount');
  {$ENDIF}
  Result := FFuncRecPtr.GetComponentCount(AModIndex);
end;

function TExternalIDEInterface.GetComponentName(const AModIndex,
  ACompIndex: Integer): string;
var
  LComponentName: array [0..255] of Char;
begin
  {$IFDEF DEBUG}
    CheckFuncRecPtr('GetComponentName');
    CheckFuncRecPtrFkt(Assigned(FFuncRecPtr.GetComponentName),'GetComponentName');
  {$ENDIF}
  FFuncRecPtr.GetComponentName(AModIndex, ACompIndex, @LComponentName);
  Result := StrPas(@LComponentName);
end;

function TExternalIDEInterface.AddNotifierEx(AddInNotifier: TIDEAddInNotifier): Boolean;
begin
//do nothing
  result := true;
end;

function TExternalIDEInterface.RemoveNotifier(AddInNotifier: TIDEAddInNotifier): Boolean;
begin
  result := true;
  if Assigned(AddInNotifier) then
    AddInNotifier.Free;
end;

procedure TExternalIDEInterface.RaiseException(const AMessage: string);
begin
  {$IFDEF DEBUG}
    CheckFuncRecPtr('RaiseException');
    CheckFuncRecPtrFkt(Assigned(FFuncRecPtr.RaiseException),'RaiseException');
  {$ENDIF}
  FFuncRecPtr.RaiseException(PChar(AMessage));
end;

function TExternalIDEInterface.GetBaseRegistryKey: string;
var
  LBaseRegistryKey: array [0..255] of Char;
begin
  {$IFDEF DEBUG}
    CheckFuncRecPtr('GetBaseRegistryKey');
    CheckFuncRecPtrFkt(Assigned(FFuncRecPtr.GetBaseRegistryKey),'GetBaseRegistryKey');
  {$ENDIF}
  FFuncRecPtr.GetBaseRegistryKey(@LBaseRegistryKey);
  Result := StrPas(@LBaseRegistryKey);
end;

function TExternalIDEInterface.GetModuleComponents(const AModuleName: string;
  AModuleList: TList): Boolean;
var
  Cnt: Integer;
  I: Integer;
  LName, LType: array [0..255] of Char;
  CPtr: PComponentListEntry;
begin
  Result := False;
  if Assigned(AModuleList) then
  begin
    {$IFDEF DEBUG}
      CheckFuncRecPtr('GetModuleComponentCount');
      CheckFuncRecPtrFkt(Assigned(FFuncRecPtr.GetModuleComponentCount),'GetModuleComponentCount');
    {$ENDIF}
    Cnt := FFuncRecPtr.GetModuleComponentCount(PChar(AModuleName));
    {$IFDEF DEBUG}
      CheckFuncRecPtr('GetModuleComponent');
      CheckFuncRecPtrFkt(Assigned(FFuncRecPtr.GetModuleComponent),'GetModuleComponent');
    {$ENDIF}
    for I := 0 to Pred(Cnt) do
      if FFuncRecPtr.GetModuleComponent(PChar(AModuleName), I, @LName, @LType) then
      begin
        New(CPtr);
        CPtr^.CompType := StrPas(LType);
        CPtr^.CompName := StrPas(LName);
        AModuleList.Add(CPtr);
        if not Result then
          Result := True;
      end;
  end;
end;

function TExternalIDEInterface.SourceWriteString(const AModuleName: string;
  const APos: Integer; const AContent: string): Boolean;
begin
  {$IFDEF DEBUG}
    CheckFuncRecPtr('SourceWriteString');
    CheckFuncRecPtrFkt(Assigned(FFuncRecPtr.SourceWriteString),'SourceWriteString');
  {$ENDIF}
  Result := FFuncRecPtr.SourceWriteString(PChar(AModuleName), APos, PChar(AContent));
end;

function TExternalIDEInterface.SourceReadString(const AModuleName: string;
  const APos: Integer; var AContent: string; const AReadSize: Integer): Integer;
var
  Buffer: PChar;
begin
  {$IFDEF DEBUG}
    CheckFuncRecPtr('SourceReadString');
    CheckFuncRecPtrFkt(Assigned(FFuncRecPtr.SourceReadString),'SourceReadString');
  {$ENDIF}
  Buffer := nil;
  try
    GetMem(Buffer, AReadSize + 1);
    Result := FFuncRecPtr.SourceReadString(PChar(AModuleName), APos, Buffer,
      AReadSize);
    PByteArray(Buffer)^[Result] := 0;
    AContent := StrPas(Buffer);
  finally
    if Assigned(Buffer) then
      FreeMem(Buffer);
  end;
end;
{$ENDIF}

{$IFNDEF EXTERNAL_INTERFACE}
procedure TIDEAddInNotifier.FileNotification(NotifyCode: TFileNotification;
  const FileName: string; var Cancel: Boolean);
begin
  IDEFileNotification(TFN2TIDEFN(NotifyCode), FileName, Cancel);
end;

procedure TIDEAddInNotifier.EventNotification(NotifyCode: TEventNotification;
  var Cancel: Boolean);
begin
  IDEEventNotification(TEvN2TIDEEvN(NotifyCode), Cancel);
end;
{$ENDIF}

end.
