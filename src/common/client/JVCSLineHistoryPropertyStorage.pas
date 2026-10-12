(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSLineHistoryPropertyStorage.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
ToDo
- better FLast... solution
- changes for users with access level < 2 (complex task)
-----------------------------------------------------------------------------

Unit history:

2008/11/07  USchuster - new unit
2009/01/12  USchuster - added LINEINFOEX support
2009/01/17  USchuster - added THybridStoragePreparedRevisionInfoProvider to use either local
                        storage or server storage depending on the server version and user level
2009/04/11  USchuster - fixed bug in TPropertyStoragePreparedRevisionInfoProvider.InfoExists
                        (cached information were not found if the latest revision was not equal
                         to the revision where the cached information belongs to)

-----------------------------------------------------------------------------*)

unit JVCSLineHistoryPropertyStorage;

{$I jedi.inc}

interface

uses
  SysUtils, Classes, Contnrs, JVCSLineHistoryUnit, JVCSConnect, JVCSNewClientObj, DBModule,
  JVCSClientObj;

type
  TPropertyStoragePreparedRevisionInfoProvider = class(TCustomPreparedRevisionInfoProvider)
  private
    FLineHistoryPropertyID: Integer;
    FLastRevisionExtension: string;
    FLastRevisionID: Integer;
    FLastTablePropertyID: Integer;
    procedure Init;
  public
    constructor Create;
    function ApplyInfo(ALineHistory: TJVCSLineHistory; AModuleRevisionList: TJVCSLineHistoryModuleRevisionList; AIndex: Integer; ALines: TStrings): TJVCSLineHistoryRevision; override;
    function InfoExists(AModuleRevisionList: TJVCSLineHistoryModuleRevisionList; AFirstIndex, ALastIndex: Integer): Integer; override;
    procedure StoreInfo(ALineHistory: TJVCSLineHistory; AModuleRevisionList: TJVCSLineHistoryModuleRevisionList; ALastRevisionID: Integer); override;
  end;

  THybridStoragePreparedRevisionInfoProvider = class(TCustomPreparedRevisionInfoProvider)
  private
    FLastServerInfo: string;
    FProvider: TCustomPreparedRevisionInfoProvider;
    FPrepareRevisionInfoPath: string;
    function GetProvider: TCustomPreparedRevisionInfoProvider;
  public
    constructor Create;
    destructor Destroy; override;
    function ApplyInfo(ALineHistory: TJVCSLineHistory; AModuleRevisionList: TJVCSLineHistoryModuleRevisionList; AIndex: Integer; ALines: TStrings): TJVCSLineHistoryRevision; override;
    function InfoExists(AModuleRevisionList: TJVCSLineHistoryModuleRevisionList; AFirstIndex, ALastIndex: Integer): Integer; override;
    procedure StoreInfo(ALineHistory: TJVCSLineHistory; AModuleRevisionList: TJVCSLineHistoryModuleRevisionList; ALastRevisionID: Integer); override;
    property PrepareRevisionInfoPath: string read FPrepareRevisionInfoPath write FPrepareRevisionInfoPath;
  end;

implementation

uses
  JclSimpleXml, JVCSClasses;

type
  TPropertyStoragePreparedRevisionHeader = class(TObject)
  private
    FExtension: string;
    FFirstRevisionID: Integer;
    FLastRevisionID: Integer;
    FRevisionCount: Integer;
    procedure Clear;
    function GetAsString: string;
    procedure SetAsString(const AValue: string);
  public
    constructor Create(const AHeader: string = '');
    property Extension: string read FExtension write FExtension;
    property FirstRevisionID: Integer read FFirstRevisionID write FFirstRevisionID;
    property LastRevisionID: Integer read FLastRevisionID write FLastRevisionID;
    property RevisionCount: Integer read FRevisionCount write FRevisionCount;
    property AsString: string read GetAsString write SetAsString;
  end;

constructor TPropertyStoragePreparedRevisionHeader.Create(const AHeader: string = '');
begin
  inherited Create;
  if AHeader = '' then
    Clear
  else
    AsString := AHeader;
end;

procedure TPropertyStoragePreparedRevisionHeader.Clear;
begin
  FExtension := '';
  FFirstRevisionID := -1;
  FLastRevisionID := -1;
  FRevisionCount := -1;
end;

function TPropertyStoragePreparedRevisionHeader.GetAsString: string;
var
  XML: TJclSimpleXML;
begin
  XML := TJclSimpleXML.Create;
  try
    XML.Root.Name := 'Header';
    XML.Root.Items.Add('Extension', FExtension);
    XML.Root.Items.Add('FirstRevisionID', FFirstRevisionID);
    XML.Root.Items.Add('LastRevisionID', FLastRevisionID);
    XML.Root.Items.Add('RevisionCount', FRevisionCount);
    Result := XML.SaveToString;
  finally
    XML.Free;
  end;
end;

procedure TPropertyStoragePreparedRevisionHeader.SetAsString(const AValue: string);
var
  XML: TJclSimpleXML;
  Item: TJclSimpleXMLElem;
begin
  Clear;
  if (Length(AValue) > 0) and (AValue[1] = '<') then
  begin
    XML := TJclSimpleXML.Create;
    try
      try
        XML.LoadFromString(AValue);
        Item := XML.Root.Items.ItemNamed['Extension'];
        if Assigned(Item) then
          FExtension := Item.Value;
        Item := XML.Root.Items.ItemNamed['FirstRevisionID'];
        if Assigned(Item) then
          FFirstRevisionID := Item.IntValue;
        Item := XML.Root.Items.ItemNamed['LastRevisionID'];
        if Assigned(Item) then
          FLastRevisionID := Item.IntValue;
        Item := XML.Root.Items.ItemNamed['RevisionCount'];
        if Assigned(Item) then
          FRevisionCount := Item.IntValue;
      except
      end;
    finally
      XML.Free;
    end;
  end;
end;

constructor TPropertyStoragePreparedRevisionInfoProvider.Create;
begin
  inherited Create;
  Init;
end;

function TPropertyStoragePreparedRevisionInfoProvider.ApplyInfo(ALineHistory: TJVCSLineHistory; AModuleRevisionList: TJVCSLineHistoryModuleRevisionList; AIndex: Integer; ALines: TStrings): TJVCSLineHistoryRevision;
var
  I: Integer;
  GetProperties: TJVCSGetProperties;
  {$IFDEF LINEINFOEX}
  J: Integer;
  LineInfo: TObjectList;
  LineInfoItem: TJVCSLineHistoryLineInfo;
  {$ENDIF LINEINFOEX}
begin
  Result := nil;
  if FLineHistoryPropertyID > 0 then
  begin
    GetProperties := TJVCSGetProperties.Create(nil);
    try
      GetProperties.Table := 3;
      GetProperties.TableID := AModuleRevisionList[AIndex].RevisionID;
      GetProperties.PropertyID := FLineHistoryPropertyID;
      if (FLastRevisionID = AModuleRevisionList[AIndex].RevisionID) and (FLastRevisionExtension = AModuleRevisionList.Extension) then
        GetProperties.TablePropertyID := FLastTablePropertyID;
      GetProperties.IncludeContent := True;
      DataModule1.ClientObjectSendRequest(GetProperties);
      if GetProperties.OutputItemCount > 0 then
        for I := 0 to Pred(GetProperties.OutputItemCount) do
          if Assigned(GetProperties.OutputItems[I].Content) then
          begin
            {$IFDEF LINEINFOEX}
            LineInfo := TObjectList.Create;
            try
              RevisionInfoExLoadFromZXMLStream(LineInfo, GetProperties.OutputItems[I].Content);
              for J := 0 to Pred(LineInfo.Count) do
              begin
                LineInfoItem := TJVCSLineHistoryLineInfo(LineInfo[J]);
                if (LineInfoItem.Count > 0) and (ALines.Count > J) then
                  ALines.Objects[J] := LineInfoItem.Revision[Pred(LineInfoItem.Count)];
              end;
            {$ELSE}
            RevisionInfoLoadFromStream(ALines, GetProperties.OutputItems[I].Content);
            {$ENDIF LINEINFOEX}
            Result := ALineHistory.AddPreparedRevision(AModuleRevisionList[AIndex].RevisionID, ALines {$IFDEF LINEINFOEX} , LineInfo {$ENDIF});
            {$IFDEF LINEINFOEX}
            finally
              LineInfo.Free;
            end;
            {$ENDIF LINEINFOEX}
            Break;
          end;
    finally
      GetProperties.Free;
    end;
  end;
end;

function TPropertyStoragePreparedRevisionInfoProvider.InfoExists(AModuleRevisionList: TJVCSLineHistoryModuleRevisionList; AFirstIndex, ALastIndex: Integer): Integer;
var
  I, J, RevisionID: Integer;
  GetModuleRevisionProperties: TJVCSGetModuleRevisionProperties;
  PropertyStoragePreparedRevisionHeader: TPropertyStoragePreparedRevisionHeader;
  OutputRevisionIDList: TSortedIntegerList;
begin
  Result := -1;
  if (FLineHistoryPropertyID > 0) and (AFirstIndex = 0) and (ALastIndex > AFirstIndex) and (ALastIndex < AModuleRevisionList.Count) then
  begin
    GetModuleRevisionProperties := TJVCSGetModuleRevisionProperties.Create(nil);
    try
      GetModuleRevisionProperties.ModuleID := AModuleRevisionList.ModuleID;
      GetModuleRevisionProperties.PropertyID := FLineHistoryPropertyID;
      GetModuleRevisionProperties.IncludeContent := False;
      DataModule1.ClientObjectSendRequest(GetModuleRevisionProperties);
      if GetModuleRevisionProperties.OutputItemCount > 0 then
      begin
        OutputRevisionIDList := TSortedIntegerList.Create;
        try
          for I := 0 to Pred(GetModuleRevisionProperties.OutputItemCount) do
            OutputRevisionIDList.Add(GetModuleRevisionProperties.OutputItems[I].RevisionID);
          for I := AFirstIndex to ALastIndex do
          begin
            RevisionID := AModuleRevisionList[I].RevisionID;
            if OutputRevisionIDList.IndexOf(RevisionID) <> -1 then
            begin
              for J := 0 to Pred(GetModuleRevisionProperties.OutputItemCount) do
                if GetModuleRevisionProperties.OutputItems[J].RevisionID = RevisionID then
                begin
                  PropertyStoragePreparedRevisionHeader := TPropertyStoragePreparedRevisionHeader.Create(GetModuleRevisionProperties.OutputItems[J].Header);
                  try
                    if (PropertyStoragePreparedRevisionHeader.Extension = AModuleRevisionList.Extension) and
                      (PropertyStoragePreparedRevisionHeader.FirstRevisionID = AModuleRevisionList[AFirstIndex].RevisionID) and
                      (PropertyStoragePreparedRevisionHeader.LastRevisionID = RevisionID) and
                      (PropertyStoragePreparedRevisionHeader.RevisionCount = I - AFirstIndex + 1) then
                    begin
                      FLastRevisionExtension := AModuleRevisionList.Extension;
                      FLastRevisionID := RevisionID;
                      FLastTablePropertyID := GetModuleRevisionProperties.OutputItems[J].TablePropertyID;
                      Result := I;
                      Break;
                    end;
                  finally
                    PropertyStoragePreparedRevisionHeader.Free;
                  end;
                end;
            end;
          end;
        finally
          OutputRevisionIDList.Free;
        end;
      end;
    finally
      GetModuleRevisionProperties.Free;
    end;
  end;
end;

procedure TPropertyStoragePreparedRevisionInfoProvider.Init;
var
  GetPropertyList: TJVCSGetPropertyList;
  I: Integer;
begin
  FLineHistoryPropertyID := -1;
  GetPropertyList := TJVCSGetPropertyList.Create(nil);
  try
    DataModule1.ClientObjectSendRequest(GetPropertyList);
    for I := 0 to Pred(GetPropertyList.OutputItemCount) do
      if SameText(GetPropertyList.OutputItems[I].PropertyName, 'Line History') then
      begin
        FLineHistoryPropertyID := GetPropertyList.OutputItems[I].PropertyID;
        Break;
      end;
  finally
    GetPropertyList.Free;
  end;
end;

procedure TPropertyStoragePreparedRevisionInfoProvider.StoreInfo(ALineHistory: TJVCSLineHistory; AModuleRevisionList: TJVCSLineHistoryModuleRevisionList; ALastRevisionID: Integer);
var
  AddUpdateProperties: TJVCSAddUpdateProperties;
  PropertyStoragePreparedRevisionHeader: TPropertyStoragePreparedRevisionHeader;
  Header: string;
  I, Idx, RevisionCount: Integer;
begin
  if FLineHistoryPropertyID > 0 then
  begin
    Idx := -1;
    RevisionCount := 0;
    for I := 0 to Pred(AModuleRevisionList.Count) do
    begin
      Inc(RevisionCount);
      if AModuleRevisionList[I].RevisionID = ALastRevisionID then
      begin
        Idx := I;
        Break;
      end;
    end;
    if Idx <> -1 then
    begin
      PropertyStoragePreparedRevisionHeader := TPropertyStoragePreparedRevisionHeader.Create;
      try
        PropertyStoragePreparedRevisionHeader.Extension := AModuleRevisionList.Extension;
        PropertyStoragePreparedRevisionHeader.FirstRevisionID := AModuleRevisionList[0].RevisionID;
        PropertyStoragePreparedRevisionHeader.LastRevisionID := ALastRevisionID;
        PropertyStoragePreparedRevisionHeader.RevisionCount := RevisionCount;
        Header := PropertyStoragePreparedRevisionHeader.AsString; 
      finally
        PropertyStoragePreparedRevisionHeader.Free;
      end;
      AddUpdateProperties := TJVCSAddUpdateProperties.Create(nil);
      try
        AddUpdateProperties.Table := 3;
        AddUpdateProperties.TableID := ALastRevisionID;
        AddUpdateProperties.TablePropertyID := 0;
        AddUpdateProperties.PropertyID := FLineHistoryPropertyID;
        AddUpdateProperties.Header := Header;
        {$IFDEF LINEINFOEX}
        RevisionInfoExSaveToZXMLStream(ALineHistory.LineInfos, AddUpdateProperties.Content);
        {$ELSE}
        RevisionInfoSaveToStream(ALineHistory.Lines, AddUpdateProperties.Content);
        {$ENDIF LINEINFOEX}
        DataModule1.ClientObjectSendRequest(AddUpdateProperties);
      finally
        AddUpdateProperties.Free;
      end;
    end;
  end;
end;

constructor THybridStoragePreparedRevisionInfoProvider.Create;
begin
  inherited Create;
  FProvider := nil;
  FPrepareRevisionInfoPath := '';
  FLastServerInfo := '';
end;

destructor THybridStoragePreparedRevisionInfoProvider.Destroy;
begin
  FProvider.Free;
  inherited Destroy;
end;

function THybridStoragePreparedRevisionInfoProvider.ApplyInfo(ALineHistory: TJVCSLineHistory; AModuleRevisionList: TJVCSLineHistoryModuleRevisionList; AIndex: Integer; ALines: TStrings): TJVCSLineHistoryRevision;
begin
  GetProvider;
  Result := FProvider.ApplyInfo(ALineHistory, AModuleRevisionList, AIndex, ALines);
end;

function THybridStoragePreparedRevisionInfoProvider.GetProvider: TCustomPreparedRevisionInfoProvider;

  function GetServerInfo: string;
  var
    Connection: TJVCSConnection;
  begin
    Result := '';
    Connection := DBModule.GetJvcsConnection;
    if Assigned(Connection) then
    begin
      Result := DBModule.GetJvcsConnection.Server + DBModule.GetJvcsConnection.Port +
        IntToStr(DBModule.GetJvcsConnection.UserID) + DBModule.GetJvcsConnection.ServerType;
    end;
  end;

  function CanUsePropertyStorage: Boolean;
  var
    Connection: TJVCSConnection;
    Whoami: TJVCSWhoami;
  begin
    Result := False;
    Connection := DBModule.GetJvcsConnection;
    if Assigned(Connection) then
    begin
      if (Connection.ServerVersion >= 250) and (Connection.SupportsFunction(TJVCSGetPropertyList)) then
      begin
        Whoami := TJVCSWhoami.Create(nil);
        try
          Connection.SendRequest(Whoami);
          Result := Whoami.AccessLevel >= 2;
        finally
          Whoami.Free;
        end;
      end;
    end;
  end;

var
  CurrentServerInfo: string;
begin
  CurrentServerInfo := GetServerInfo;
  if not Assigned(FProvider) or (CurrentServerInfo <> FLastServerInfo) then
  begin
    FreeAndNil(FProvider);
    if CanUsePropertyStorage then
      FProvider := TPropertyStoragePreparedRevisionInfoProvider.Create
    else
    begin
      FProvider := TLocalPreparedRevisionInfoProvider.Create;
      TLocalPreparedRevisionInfoProvider(FProvider).PrepareRevisionInfoPath := FPrepareRevisionInfoPath;
    end;
    FLastServerInfo := CurrentServerInfo;
    Result := FProvider;
  end
  else
    Result := FProvider;
end;

function THybridStoragePreparedRevisionInfoProvider.InfoExists(AModuleRevisionList: TJVCSLineHistoryModuleRevisionList; AFirstIndex, ALastIndex: Integer): Integer;
begin
  GetProvider;
  Result := FProvider.InfoExists(AModuleRevisionList, AFirstIndex, ALastIndex);
end;

procedure THybridStoragePreparedRevisionInfoProvider.StoreInfo(ALineHistory: TJVCSLineHistory; AModuleRevisionList: TJVCSLineHistoryModuleRevisionList; ALastRevisionID: Integer);
begin
  GetProvider;
  FProvider.StoreInfo(ALineHistory, AModuleRevisionList, ALastRevisionID);
end;

end.
