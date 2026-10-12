(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSDLLFileHistoryImpl.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
- bProjectOpen //todo
-----------------------------------------------------------------------------

Unit history:

2005/06/14  USchuster - new unit
2005/06/27  USchuster - added label support
                      - made exported functions thread safe
                      - moved blob stream extraction to JVCSClientObjBase
2008/02/17  USchuster - Trace -> TraceMsg                      

-----------------------------------------------------------------------------*)

unit JVCSDLLFileHistoryImpl;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  {$IFDEF DEBUG}
  JclDebug,
  {$ENDIF DEBUG}
  Windows,
  SysUtils, Classes, VCSBase, DBModule, JVCSClientObj, JVCSClasses, JVCSDataClasses,
  JVCSTypes, Contnrs, VCSProcBase, JVCSIDEInterfaceCommon, JVCSClientObjBase;

function JediVCSDLLHistoryInit(AExternalVCSModuleHistoryFunctionRec: PExternalVCSModuleHistoryFunctionRec): Boolean; stdcall;
procedure FinalizeHistory;

implementation

type
  TModuleHistoryRevisionExt = class(TObject)
  private
    FExtension: JVCSString20;
    FTimeStamp: TDateTime;
  public
    constructor Create;
    property Extension: JVCSString20 read FExtension write FExtension;
    property TimeStamp: TDateTime read FTimeStamp write FTimeStamp;
  end;

  TModuleHistoryRevision = class(TObject)
  private
    FVersion: Integer;
    FRevision: Integer;
    FUserName: JVCSString50;
    FCheckinComment: string;
    FRevisionID: Integer;
    FItems: TObjectList;
    function GetCount: Integer;
    function GetItems(AIndex: Integer): TModuleHistoryRevisionExt;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddExt(AExtension: string; ATimeStamp: TDateTime);

    property Count: Integer read GetCount;
    property Items[AIndex: Integer]: TModuleHistoryRevisionExt read GetItems; default;

    property UserName: JVCSString50 read FUserName write FUserName;
    property Version: Integer read FVersion write FVersion;
    property Revision: Integer read FRevision write FRevision;
    property CheckinComment: string read FCheckinComment write FCheckinComment;
    property RevisionID: Integer read FRevisionID write FRevisionID;
  end;

  TModuleHistory = class(TObject)
  private
    FID: Integer;
    FItems: TObjectList;
    function GetCount: Integer;
    function GetItems(AIndex: Integer): TModuleHistoryRevision;
  public
    constructor Create(AID: Integer);
    destructor Destroy; override;

    procedure Assign(AObject: TObject);

    property Count: Integer read GetCount;
    property ID: Integer read FID;
    property Items[AIndex: Integer]: TModuleHistoryRevision read GetItems; default;
  end;

  TModuleHistoryList = class(TCustomFastSortedObjectList)
  private
    function GetItem(AIndex: Integer): TModuleHistory;
  protected
    function CompareItems(AItem1, AItem2: Pointer): Integer; override;
  public
    procedure AddOrReplace(AModuleID: Integer);
    function IndexOf(AModuleID: Integer): Integer;

    property Items[AIndex: Integer]: TModuleHistory read GetItem; default;
  end;

  TRevisionExtensionBlob = class(TObject)
  private
    FRevisionID: Integer;
    FExtension: JVCSString20;
    FBlob: TMemoryStream;
  public
    constructor Create(ARevisionID: Integer; AExtension: JVCSString20);
    destructor Destroy; override;

    property RevisionID: Integer read FRevisionID;
    property Extension: JVCSString20 read FExtension;
    property Blob: TMemoryStream read FBlob;
  end;

  TRevisionExtensionBlobList = class(TCustomFastSortedObjectList)
  private
    function GetItem(AIndex: Integer): TRevisionExtensionBlob;
  protected
    function CompareItems(AItem1, AItem2: Pointer): Integer; override;
  public
    procedure AddOrReplace(ARevisionID: Integer; AExtension: string);
    function IndexOf(ARevisionID: Integer; AExtension: string): Integer;

    property Items[AIndex: Integer]: TRevisionExtensionBlob read GetItem; default;
  end;

  TModuleRevisionLabels = class(TObject)
  private
    FModuleID: Integer;
    FRevisionID: Integer;
    FLabelList: TStringList;
  public
    constructor Create(AModuleID: Integer; ARevisionID: Integer; ALabels: TStrings = nil);
    destructor Destroy; override;

    property ModuleID: Integer read FModuleID;
    property RevisionID: Integer read FRevisionID;
    property LabelList: TStringList read FLabelList;
  end;

  TModuleRevisionLabelsList = class(TCustomFastSortedObjectList)
  private
    FInDoesModuleExists: Boolean;
    function GetItem(AIndex: Integer): TModuleRevisionLabels;
  protected
    function CompareItems(AItem1, AItem2: Pointer): Integer; override;
  public
    constructor Create;
    procedure AddOrReplace(AModuleID, ARevisionID: Integer; ALabels: TStrings = nil);
    function DoesModuleExists(AModuleID: Integer): Boolean;
    function IndexOf(AModuleID, ARevisionID: Integer): Integer;

    property Items[AIndex: Integer]: TModuleRevisionLabels read GetItem; default;
  end;

  TModuleHistoryDataList = class(TObject)
  private
    FModuleNameToID: TModuleNameToIDList;
    FModuleHistoryList: TModuleHistoryList;
    FRevisionExtensionBlobList: TRevisionExtensionBlobList;
    FModuleRevisionLabelsList: TModuleRevisionLabelsList;
    FAllLabelList: TIDToNameList;
    FLastCheckTime: TDateTime;
    FArchiveDateTime: TDateTime;
    FLastArchiveSource: string;
    FReadedLabels: Boolean;
    FLocked: Boolean;
    FLock: TRTLCriticalSection;
    procedure ClearAfterArchiveTimeStampChanged;
    procedure DoCheckClear;
    function GetItem(AIndex: Integer): TModuleHistory;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;

    function GetLabelStr(ALabelID: Integer): string;
    function IndexOf(AModuleName: string): Integer;
    function LoadBlob(ARevisionID: Integer; AExtension: string; ADestStream: TStream): Boolean;
    procedure Lock;
    procedure Unlock;

    property Items[AIndex: Integer]: TModuleHistory read GetItem; default;
    property ModuleRevisionLabelsList: TModuleRevisionLabelsList read FModuleRevisionLabelsList;
  end;

constructor TModuleHistoryRevisionExt.Create;
begin
  inherited Create;
  FExtension := '';
  FTimeStamp := 0;
end;

constructor TModuleHistoryRevision.Create;
begin
  inherited Create;
  FItems := TObjectList.Create;
  FVersion := 0;
  FRevision := 0;
  FUserName := '';
  FCheckinComment := '';
  FRevisionID := 0;
end;

destructor TModuleHistoryRevision.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TModuleHistoryRevision.AddExt(AExtension: string; ATimeStamp: TDateTime);
begin
  FItems.Add(TModuleHistoryRevisionExt.Create);
  TModuleHistoryRevisionExt(FItems.Last).Extension := AExtension;
  TModuleHistoryRevisionExt(FItems.Last).TimeStamp := ATimeStamp;
end;

function TModuleHistoryRevision.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TModuleHistoryRevision.GetItems(AIndex: Integer): TModuleHistoryRevisionExt;
begin
  Result := TModuleHistoryRevisionExt(FItems[AIndex]);
end;

constructor TModuleHistory.Create(AID: Integer);
begin
  inherited Create;
  FID := AID;
  FItems := TObjectList.Create;
end;

destructor TModuleHistory.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TModuleHistory.Assign(AObject: TObject);
var
  I: Integer;
  ModuleHistoryItem: TModuleHistoryRevision;
  GetModuleHistory: TJVCSGetModuleHistory;
begin
  if AObject is TJVCSGetModuleHistory then
  begin
    GetModuleHistory := TJVCSGetModuleHistory(AObject);
    ModuleHistoryItem := nil;
    for I := 0 to Pred(GetModuleHistory.OutputItemCount) do
    begin
      if (not Assigned(ModuleHistoryItem)) or (ModuleHistoryItem.RevisionID <> GetModuleHistory.OutputItems[I].RevisionID) then
      begin
        FItems.Add(TModuleHistoryRevision.Create);
        ModuleHistoryItem := TModuleHistoryRevision(FItems.Last);
        with GetModuleHistory.OutputItems[I] do
        begin
          ModuleHistoryItem.Version := Version;
          ModuleHistoryItem.Revision := Revision;
          ModuleHistoryItem.UserName := UserName;
          ModuleHistoryItem.CheckinComment := CheckinComment;
          ModuleHistoryItem.RevisionID := RevisionID;
        end;
      end;
      with GetModuleHistory.OutputItems[I] do
        ModuleHistoryItem.AddExt(Extension, TimeStamp);
    end;
  end;
end;

function TModuleHistory.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TModuleHistory.GetItems(AIndex: Integer): TModuleHistoryRevision;
begin
  Result := TModuleHistoryRevision(FItems[AIndex]);
end;

function TModuleHistoryList.GetItem(AIndex: Integer): TModuleHistory;
begin
  Result := TModuleHistory(FList[AIndex]);
end;

function TModuleHistoryList.CompareItems(AItem1, AItem2: Pointer): Integer;
var
  Ptr1, Ptr2: TModuleHistory;
begin
  Ptr1 := AItem1;
  Ptr2 := AItem2;
  Result := Ptr1.ID - Ptr2.ID;
end;

procedure TModuleHistoryList.AddOrReplace(AModuleID: Integer);
var
  Idx: Integer;
begin
  Idx := IndexOf(AModuleID);
  if Idx <> -1 then
    Delete(Idx);
  inherited Add(TModuleHistory.Create(AModuleID));
end;

function TModuleHistoryList.IndexOf(AModuleID: Integer): Integer;
var
  ModuleHistory: TModuleHistory;
begin
  ModuleHistory := TModuleHistory.Create(AModuleID);
  try
    Result := inherited IndexOf(ModuleHistory);
  finally
    ModuleHistory.Free;
  end;
end;

constructor TRevisionExtensionBlob.Create(ARevisionID: Integer; AExtension: JVCSString20);
begin
  inherited Create;
  FRevisionID := ARevisionID;
  FExtension := AExtension;
  FBlob := TMemoryStream.Create;
end;

destructor TRevisionExtensionBlob.Destroy;
begin
  FBlob.Free;
  inherited Destroy;
end;

function TRevisionExtensionBlobList.GetItem(AIndex: Integer): TRevisionExtensionBlob;
begin
  Result := TRevisionExtensionBlob(FList[AIndex]);
end;

function TRevisionExtensionBlobList.CompareItems(AItem1, AItem2: Pointer): Integer;
var
  Ptr1, Ptr2: TRevisionExtensionBlob;
begin
  Ptr1 := AItem1;
  Ptr2 := AItem2;
  Result := Ptr1.RevisionID - Ptr2.RevisionID;
  if Result = 0 then
    Result := CompareStr(Ptr1.Extension, Ptr2.Extension);
end;

procedure TRevisionExtensionBlobList.AddOrReplace(ARevisionID: Integer; AExtension: string);
var
  Idx: Integer;
begin
  Idx := IndexOf(ARevisionID, AExtension);
  if Idx <> -1 then
    Delete(Idx);
  inherited Add(TRevisionExtensionBlob.Create(ARevisionID, AExtension));
end;

function TRevisionExtensionBlobList.IndexOf(ARevisionID: Integer; AExtension: string): Integer;
var
  RevisionExtensionBlob: TRevisionExtensionBlob;
begin
  RevisionExtensionBlob := TRevisionExtensionBlob.Create(ARevisionID, AExtension);
  try
    Result := inherited IndexOf(RevisionExtensionBlob);
  finally
    RevisionExtensionBlob.Free;
  end;
end;

constructor TModuleRevisionLabels.Create(AModuleID: Integer; ARevisionID: Integer; ALabels: TStrings = nil);
begin
  inherited Create;
  FModuleID := AModuleID;
  FRevisionID := ARevisionID;
  FLabelList := TStringList.Create;
  if Assigned(ALabels) then
    FLabelList.Assign(ALabels);
end;

destructor TModuleRevisionLabels.Destroy;
begin
  FLabelList.Free;
  inherited Destroy;
end;

constructor TModuleRevisionLabelsList.Create;
begin
  inherited Create;
  FInDoesModuleExists := False;
end;

function TModuleRevisionLabelsList.DoesModuleExists(AModuleID: Integer): Boolean;
begin
  FInDoesModuleExists := True;
  try
    Result := IndexOf(AModuleID, 0) <> -1;
  finally
    FInDoesModuleExists := False;
  end;
end;

function TModuleRevisionLabelsList.GetItem(AIndex: Integer): TModuleRevisionLabels;
begin
  Result := TModuleRevisionLabels(FList[AIndex]);
end;

function TModuleRevisionLabelsList.CompareItems(AItem1, AItem2: Pointer): Integer;
var
  Ptr1, Ptr2: TModuleRevisionLabels;
begin
  Ptr1 := AItem1;
  Ptr2 := AItem2;
  Result := Ptr1.ModuleID - Ptr2.ModuleID;
  if (Result = 0) and (not FInDoesModuleExists) then
    Result := Ptr1.RevisionID - Ptr2.RevisionID;
end;

procedure TModuleRevisionLabelsList.AddOrReplace(AModuleID, ARevisionID: Integer; ALabels: TStrings = nil);
var
  Idx: Integer;
begin
  Idx := IndexOf(AModuleID, ARevisionID);
  if Idx <> -1 then
    Delete(Idx);
  inherited Add(TModuleRevisionLabels.Create(AModuleID, ARevisionID, ALabels));
end;

function TModuleRevisionLabelsList.IndexOf(AModuleID, ARevisionID: Integer): Integer;
var
  ModuleRevisionLabels: TModuleRevisionLabels;
begin
  ModuleRevisionLabels := TModuleRevisionLabels.Create(AModuleID, ARevisionID);
  try
    Result := inherited IndexOf(ModuleRevisionLabels);
  finally
    ModuleRevisionLabels.Free;
  end;
end;

constructor TModuleHistoryDataList.Create;
begin
  inherited Create;
  FModuleNameToID := TModuleNameToIDList.Create;
  FModuleHistoryList := TModuleHistoryList.Create;
  FRevisionExtensionBlobList := TRevisionExtensionBlobList.Create;
  FModuleRevisionLabelsList := TModuleRevisionLabelsList.Create;
  FAllLabelList := TIDToNameList.Create;
  FLastCheckTime := 0;
  FArchiveDateTime := 0;
  FLastArchiveSource := '';
  FReadedLabels := False;
  FLocked := False;
  InitializeCriticalSection(FLock);
end;

destructor TModuleHistoryDataList.Destroy;
begin
  DeleteCriticalSection(FLock);  
  FAllLabelList.Free;
  FModuleHistoryList.Free;
  FModuleNameToID.Free;
  FRevisionExtensionBlobList.Free;
  FModuleRevisionLabelsList.Free;
  inherited Destroy;
end;

procedure TModuleHistoryDataList.Clear;
begin
  FModuleNameToID.Clear;
  FRevisionExtensionBlobList.Clear;
  ClearAfterArchiveTimeStampChanged;
end;

procedure TModuleHistoryDataList.ClearAfterArchiveTimeStampChanged;
begin
  FModuleHistoryList.Clear;
  FModuleRevisionLabelsList.Clear;
  FAllLabelList.Clear;
  FReadedLabels := False;
end;

procedure TModuleHistoryDataList.DoCheckClear;
var
  GetArchiveTstamp: TJVCSGetArchiveTstamp;
begin
  if (FLastArchiveSource <> sArchiveSource) then
  begin
    {$IFDEF DEBUG}
    JclDebug.TraceMsg(' TModuleHistoryDataList.DoCheckClear FLastArchiveSource <> sArchiveSource -> Clear');
    {$ENDIF DEBUG}
    Clear;
  end
  else
  if (Now - FLastCheckTime > 5/86400) then
  begin
    {$IFDEF DEBUG}
    JclDebug.TraceMsg(' TModuleHistoryDataList.DoCheckClear Now - FLastCheckTime > 5/86400');
    {$ENDIF DEBUG}
    GetArchiveTstamp := TJVCSGetArchiveTstamp.Create(nil);
    try
      DataModule1.ClientObjectSendRequest(GetArchiveTstamp);
      if FArchiveDateTime <> GetArchiveTstamp.Timestamp then
      begin
        {$IFDEF DEBUG}
        JclDebug.TraceMsg(' TModuleHistoryDataList.DoCheckClear FArchiveDateTime <> GetArchiveTstamp.Timestamp -> ClearAfterArchiveTimeStampChanged');
        {$ENDIF DEBUG}
        ClearAfterArchiveTimeStampChanged;
      end;
      FArchiveDateTime := GetArchiveTstamp.Timestamp;
    finally
      GetArchiveTstamp.Free;
    end;
  end;
  FLastArchiveSource := sArchiveSource;
  FLastCheckTime := Now;
end;

function TModuleHistoryDataList.GetItem(AIndex: Integer): TModuleHistory;
begin
  Result := FModuleHistoryList[AIndex];
end;

function TModuleHistoryDataList.GetLabelStr(ALabelID: Integer): string;
var
  GetLabels: TJVCSGetLabels;
  I, Idx: Integer;
begin
  if not FReadedLabels then
  begin
    GetLabels := TJVCSGetLabels.Create(nil);
    try
      DataModule1.ClientObjectSendRequest(GetLabels);
      for I := 0 to Pred(GetLabels.OutputItemCount) do
        FAllLabelList.AddOrReplace(GetLabels.OutputItems[I].LabelID, GetLabels.OutputItems[I].LabelName);
    finally
      GetLabels.Free;
    end;
    FReadedLabels := True;
  end;
  Result := '';
  Idx := FAllLabelList.IndexOf(ALabelID);
  if Idx <> -1 then
    Result := FAllLabelList[Idx].Name;
end;

function TModuleHistoryDataList.IndexOf(AModuleName: string): Integer;
var
  I, J, Idx: Integer;
  GetModuleId: TJVCSGetModuleId;
  GetModuleHistory: TJVCSGetModuleHistory;
  GetSharedBy: TJVCSGetSharedBy;
  GetLabelsByProject: TJVCSGetLabelsByProject;
  ModuleID, FirstProjectID, RevisionID, TempModuleID: Integer;
  CurrentRevisionLabelIDs: TSortedIntegerList;
  CurrentRevisionLabelStrings: TStringList;
  LabelStr: string;
begin
  Result := -1;
  DoCheckClear;
  Idx := FModuleNameToID.IndexOf(AModuleName);
  if Idx = -1 then
  begin
    GetModuleId := TJVCSGetModuleId.Create(nil);
    try
      GetModuleId.ModuleName := AModuleName;
      DataModule1.ClientObjectSendRequest(GetModuleId);
      ModuleID := GetModuleId.ModuleID;
      FModuleNameToID.AddOrReplace(AModuleName, ModuleID);
      Idx := FModuleNameToID.IndexOf(AModuleName);
    finally
      GetModuleId.Free;
    end;
  end;
  if Idx <> -1 then
  begin
    ModuleID := FModuleNameToID[Idx].ModuleID;
    Result := FModuleHistoryList.IndexOf(ModuleID);
    if (Result = -1) and (ModuleID > 0) then
    begin
      GetModuleHistory := TJVCSGetModuleHistory.Create(nil);
      try
        GetModuleHistory.ModuleID := ModuleID;
        DataModule1.ClientObjectSendRequest(GetModuleHistory);
        FModuleHistoryList.AddOrReplace(ModuleID);
        Result := FModuleHistoryList.IndexOf(ModuleID);
        if Result <> -1 then
          FModuleHistoryList[Result].Assign(GetModuleHistory);
      finally
        GetModuleHistory.Free;
      end;
      if not FModuleRevisionLabelsList.DoesModuleExists(ModuleID) then
      begin
        {$IFDEF DEBUG}
        JclDebug.TraceMsg(' TModuleHistoryDataList.IndexOf not FModuleRevisionLabelsList.DoesModuleExists(ModuleID)');
        {$ENDIF DEBUG}
        GetSharedBy := TJVCSGetSharedBy.Create(nil);
        try
          GetSharedBy.ModuleID := ModuleID;
          DataModule1.ClientObjectSendRequest(GetSharedBy);
          FirstProjectID := -1;
          if GetSharedBy.OutputItemCount > 0 then
            FirstProjectID := GetSharedBy.OutputItems[0].ProjectID;
        finally
          GetSharedBy.Free;
        end;
        if FirstProjectID > 0 then
        begin
          GetLabelsByProject := TJVCSGetLabelsByProject.Create(nil);
          try
            GetLabelsByProject.ProjectID := FirstProjectID;
            DataModule1.ClientObjectSendRequest(GetLabelsByProject);
            for I := 0 to Pred(GetLabelsByProject.OutputItemCount) do
            begin
              TempModuleID := GetLabelsByProject.OutputItems[I].ModuleID;
              RevisionID := GetLabelsByProject.OutputItems[I].RevisionID;
              if FModuleRevisionLabelsList.IndexOf(TempModuleID, RevisionID) = -1 then
              begin
                CurrentRevisionLabelIDs := TSortedIntegerList.Create;
                try
                  for J := I to Pred(GetLabelsByProject.OutputItemCount) do
                    if (GetLabelsByProject.OutputItems[J].ModuleID = TempModuleID) and
                      (GetLabelsByProject.OutputItems[J].RevisionID = RevisionID) then
                      CurrentRevisionLabelIDs.Add(GetLabelsByProject.OutputItems[J].LabelID);

                  CurrentRevisionLabelStrings := TStringList.Create;
                  try
                    for J := Pred(CurrentRevisionLabelIDs.Count) downto 0 do
                    begin
                      LabelStr := GetLabelStr(CurrentRevisionLabelIDs[J]);
                      if LabelStr <> '' then
                        CurrentRevisionLabelStrings.Add(LabelStr);
                    end;
                    FModuleRevisionLabelsList.AddOrReplace(TempModuleID, RevisionID, CurrentRevisionLabelStrings);
                  finally
                    CurrentRevisionLabelStrings.Free;
                  end;
                finally
                  CurrentRevisionLabelIDs.Free;
                end;
              end;
            end;
          finally
            GetLabelsByProject.Free;
          end;
        end;
      end;
    end;
  end;
end;

function TModuleHistoryDataList.LoadBlob(ARevisionID: Integer; AExtension: string; ADestStream: TStream): Boolean;
var
  JVCSGetSingleBlob: TJVCSGetSingleBlob;
  Idx: Integer;
begin
  Result := False;
  if ARevisionID > 0 then
  begin
    Idx := FRevisionExtensionBlobList.IndexOf(ARevisionID, AExtension);
    if Idx = -1 then
    begin
      FRevisionExtensionBlobList.AddOrReplace(ARevisionID, AExtension);
      Idx := FRevisionExtensionBlobList.IndexOf(ARevisionID, AExtension);
      if Idx <> -1 then
      begin
        JVCSGetSingleBlob := TJVCSGetSingleBlob.Create(nil);
        try
          JVCSGetSingleBlob.RevisionID := ARevisionID;
          JVCSGetSingleBlob.Extension := AExtension;
          DataModule1.ClientObjectSendRequest(JVCSGetSingleBlob);
          if not JVCSGetSingleBlob.ExtractBlobToStream(JVCSGetSingleBlob.ModuleBinary, FRevisionExtensionBlobList[Idx].Blob) then
            FRevisionExtensionBlobList[Idx].Blob.CopyFrom(JVCSGetSingleBlob.ModuleBinary, 0);
        finally
          JVCSGetSingleBlob.Free;
        end;
      end;
    end;
    if Idx <> -1 then
      ADestStream.CopyFrom(FRevisionExtensionBlobList[Idx].Blob, 0);
  end;
end;

procedure TModuleHistoryDataList.Lock;
begin
  {$IFDEF DEBUG}
  if FLocked then
    JclDebug.TraceMsg('ModuleHistoryDataList is still locked!');
  {$ENDIF DEBUG}
  EnterCriticalSection(FLock);
  FLocked := True;
end;

procedure TModuleHistoryDataList.Unlock;
begin
  LeaveCriticalSection(FLock);
  FLocked := False;
end;

var
  ModuleHistoryDataList: TModuleHistoryDataList = nil;

procedure CreateModuleHistoryDataList;
begin
  if not Assigned(ModuleHistoryDataList) then
    ModuleHistoryDataList := TModuleHistoryDataList.Create;
end;

function GetModuleHistoryIndex(AModuleName: PChar; var AIndex: Integer): Boolean;
var
  MN: string;
begin
  Result := False;
  if ServerUserID > 0 then
  begin
    CreateModuleHistoryDataList;
    AIndex := ModuleHistoryDataList.IndexOf(StrPas(AModuleName));
    if AIndex = -1 then
    begin
      bProjectOpen := True;//todo
      MN := StrPas(AModuleName);
      if ResolveFileFamilies(MN) then
        AIndex := ModuleHistoryDataList.IndexOf(MN);
    end;
    Result := AIndex <> -1;
  end;
end;

procedure LockModuleHistory;
begin
  CreateModuleHistoryDataList;
  ModuleHistoryDataList.Lock;
end;

procedure UnlockModuleHistory;
begin
  CreateModuleHistoryDataList;
  ModuleHistoryDataList.Unlock;
end;

function GetModuleHistoryCount(AModuleName: PChar): Integer; stdcall;
var
  Idx: Integer;
begin
  LockModuleHistory;
  try
    Result := 0;
    if GetModuleHistoryIndex(AModuleName, Idx) then
      Result := ModuleHistoryDataList[Idx].Count;
  finally
    UnlockModuleHistory;
  end;
end;

function GetModuleHistoryAuthor(AModuleName: PChar; AIndex: Integer; AnAuthor: PChar): Boolean; stdcall;
var
  Idx: Integer;
begin
  LockModuleHistory;
  try
    Result := False;
    if GetModuleHistoryIndex(AModuleName, Idx) then
    begin
      StrPCopy(AnAuthor, TModuleHistoryRevision(ModuleHistoryDataList[Idx].Items[AIndex]).UserName);
      Result := True;
    end;
  finally
    UnlockModuleHistory;
  end;
end;

function GetModuleHistoryVersionRevisionStr(AModuleName: PChar; AIndex: Integer; AVersionStr: PChar): Boolean; stdcall;
var
  Idx: Integer;
begin
  LockModuleHistory;
  try
    Result := False;
    if GetModuleHistoryIndex(AModuleName, Idx) then
    begin
      with TModuleHistoryRevision(ModuleHistoryDataList[Idx].Items[AIndex]) do
        StrPCopy(AVersionStr, Format('%d.%.3d', [Version, Revision]));
      Result := True;
    end;
  finally
    UnlockModuleHistory;
  end;
end;

function GetModuleHistoryLabelCount(AModuleName: PChar; AIndex: Integer): Integer; stdcall;
var
  Idx, IdxRevision: Integer;
begin
  LockModuleHistory;
  try
    Result := 0;
    if GetModuleHistoryIndex(AModuleName, Idx) then
    begin
      IdxRevision := ModuleHistoryDataList.ModuleRevisionLabelsList.IndexOf(ModuleHistoryDataList[Idx].ID, TModuleHistoryRevision(ModuleHistoryDataList[Idx].Items[AIndex]).RevisionID);
      if IdxRevision <> -1 then
        Result := ModuleHistoryDataList.ModuleRevisionLabelsList[IdxRevision].LabelList.Count;
    end;
  finally
    UnlockModuleHistory;
  end;
end;

function GetModuleHistoryLabel(AModuleName: PChar; AIndex: Integer; ALabelIndex: Integer; ALabelStr: PChar): Boolean; stdcall;
var
  Idx, IdxRevision: Integer;
begin
  LockModuleHistory;
  try
    Result := False;
    if GetModuleHistoryIndex(AModuleName, Idx) then
    begin
      IdxRevision := ModuleHistoryDataList.ModuleRevisionLabelsList.IndexOf(ModuleHistoryDataList[Idx].ID, TModuleHistoryRevision(ModuleHistoryDataList[Idx].Items[AIndex]).RevisionID);
      if IdxRevision <> -1 then
      begin
        Result := True;
        StrPCopy(ALabelStr, ModuleHistoryDataList.ModuleRevisionLabelsList[IdxRevision].LabelList[ALabelIndex]);
      end;
    end;
  finally
    UnlockModuleHistory;
  end;
end;

function GetModuleHistoryDate(AModuleName: PChar; AIndex: Integer; var ADate: TDateTime): Boolean; stdcall;
var
  I, Idx: Integer;
  S: string;
begin
  LockModuleHistory;
  try
    Result := False;
    if GetModuleHistoryIndex(AModuleName, Idx) then
    begin
      with TModuleHistoryRevision(ModuleHistoryDataList[Idx].Items[AIndex]) do
      begin
        S := ExtractFileExt(StrPas(AModuleName));
        for I := 0 to Pred(Count) do
          if SameText(Items[I].Extension, S) then
          begin
            ADate := Items[I].TimeStamp;
            Result := True;
            Break;
          end;
      end;
    end;
  finally
    UnlockModuleHistory;
  end;
end;

function GetModuleHistoryComment(AModuleName: PChar; AIndex: Integer; AComment: PChar; AMaxCommentSize: Integer): Boolean; stdcall;
var
  Idx: Integer;
begin
  LockModuleHistory;
  try
    Result := False;
    if GetModuleHistoryIndex(AModuleName, Idx) then
    begin
      with TModuleHistoryRevision(ModuleHistoryDataList[Idx].Items[AIndex]) do
        StrPCopy(AComment, Copy(CheckinComment, 1, AMaxCommentSize));
      Result := True;
    end;
  finally
    UnlockModuleHistory;
  end;
end;

function GetModuleHistoryContentSize(AModuleName: PChar; AIndex: Integer): Integer; stdcall;
var
  I, Idx, ExtIdx: Integer;
  MS: TMemoryStream;
  S: string;
begin
  LockModuleHistory;
  try
    Result := 0;
    if GetModuleHistoryIndex(AModuleName, Idx) then
    begin
      MS := TMemoryStream.Create;
      try
        with TModuleHistoryRevision(ModuleHistoryDataList[Idx].Items[AIndex]) do
        begin
          S := ExtractFileExt(StrPas(AModuleName));
          ExtIdx := -1;
          for I := 0 to Pred(Count) do
            if SameText(Items[I].Extension, S) then
            begin
              ExtIdx := I;
              Break;
            end;
          if ExtIdx <> -1 then
            ModuleHistoryDataList.LoadBlob(RevisionID, S, MS);
        end;
        Result := MS.Size;
      finally
        MS.Free;
      end;
    end;
  finally
    UnlockModuleHistory;
  end;
end;

function GetModuleHistoryContent(AModuleName: PChar; AIndex: Integer; AContentPtr: Pointer): Boolean; stdcall;
var
  I, Idx, ExtIdx: Integer;
  MS: TMemoryStream;
  S: string;
begin
  LockModuleHistory;
  try
    Result := False;
    if GetModuleHistoryIndex(AModuleName, Idx) then
    begin
      MS := TMemoryStream.Create;
      try
        with TModuleHistoryRevision(ModuleHistoryDataList[Idx].Items[AIndex]) do
        begin
          S := ExtractFileExt(StrPas(AModuleName));
          ExtIdx := -1;
          for I := 0 to Pred(Count) do
            if SameText(Items[I].Extension, S) then
            begin
              ExtIdx := I;
              Break;
            end;
          if ExtIdx <> -1 then
            ModuleHistoryDataList.LoadBlob(RevisionID, S, MS);
        end;
        Move(MS.Memory^, AContentPtr^, MS.Size);
        Result := True;
      finally
        MS.Free;
      end;
    end;
  finally
    UnlockModuleHistory;
  end;
end;

function JediVCSDLLHistoryInit(AExternalVCSModuleHistoryFunctionRec: PExternalVCSModuleHistoryFunctionRec): Boolean; stdcall;
begin
  Result := False;
  if Assigned(AExternalVCSModuleHistoryFunctionRec) then
  begin
    AExternalVCSModuleHistoryFunctionRec^.GetModuleHistoryCount := GetModuleHistoryCount;
    AExternalVCSModuleHistoryFunctionRec^.GetModuleHistoryAuthor := GetModuleHistoryAuthor;
    AExternalVCSModuleHistoryFunctionRec^.GetModuleHistoryVersionRevisionStr := GetModuleHistoryVersionRevisionStr;
    AExternalVCSModuleHistoryFunctionRec^.GetModuleHistoryLabelCount := GetModuleHistoryLabelCount;
    AExternalVCSModuleHistoryFunctionRec^.GetModuleHistoryLabel := GetModuleHistoryLabel;
    AExternalVCSModuleHistoryFunctionRec^.GetModuleHistoryDate := GetModuleHistoryDate;
    AExternalVCSModuleHistoryFunctionRec^.GetModuleHistoryComment := GetModuleHistoryComment;
    AExternalVCSModuleHistoryFunctionRec^.GetModuleHistoryContentSize := GetModuleHistoryContentSize;
    AExternalVCSModuleHistoryFunctionRec^.GetModuleHistoryContent := GetModuleHistoryContent;
    Result := True;    
  end;
end;

procedure FinalizeHistory;
begin
  FreeAndNil(ModuleHistoryDataList);
end;

initialization

finalization
  FinalizeHistory;
  
end.