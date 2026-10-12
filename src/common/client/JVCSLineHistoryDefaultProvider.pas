(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSLineHistoryDefaultProvider.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2006/04/01  USchuster - new unit
2006/04/16  USchuster - changes for revision comment
2009/04/10  USchuster - workaround for non varchar extension fields (extension = '.pas<a lot of spaces>')
2010/01/10  USchuster - implemented TJVCSCustomLineHistoryModuleProvider.GetModuleCheckoutState (for Mantis #5083)

-----------------------------------------------------------------------------*)

unit JVCSLineHistoryDefaultProvider;

{$I jedi.inc}

interface

uses
  {$IFDEF DELPHI9_UP}
  Windows, //for inline expansion
  {$ENDIF DELPHI9_UP}
  SysUtils, Classes, JVCSConnect, JVCSClientObj, JVCSLineHistoryUnit;

type
  TJVCSConnectionLineHistoryProvider = class(TJVCSCustomLineHistoryModuleProvider)
  private
    FConnection: TJVCSConnection;
    function IsConnectionOkay: Boolean;
  public
    constructor Create(AConnection: TJVCSConnection);
    procedure FillRevisionList(AModuleRevisionList: TJVCSLineHistoryModuleRevisionList); override;
    function GetModuleCheckoutState(const AModuleName: string; var ACheckedOut: Boolean; ACRCList: TStrings): Boolean; override;
    function GetModuleExtensions(const AModuleName: string; AExtensions: TStrings): Boolean; override;
    procedure GetRevisionContent(AModuleRevision: TJVCSLineHistoryModuleRevision; AStream: TStream); override;
    function GetServerInfo: string; override;
  end;

implementation

constructor TJVCSConnectionLineHistoryProvider.Create(AConnection: TJVCSConnection);
begin
  inherited Create;
  FConnection := AConnection;
end;

procedure TJVCSConnectionLineHistoryProvider.FillRevisionList(AModuleRevisionList: TJVCSLineHistoryModuleRevisionList);
var
  GetModuleId: TJVCSGetModuleId;
  GetModuleHistory: TJVCSGetModuleHistory;
  ModuleID, LastRevisionID: Integer;
  CurrentRevisionInfo: TGetModuleHistoryOutputItem;
  ModuleRevision: TJVCSLineHistoryModuleRevision;
  I: Integer;
  FixedExtension: string;
begin
  if IsConnectionOkay and Assigned(AModuleRevisionList) and (AModuleRevisionList.ModuleName <> '') then
  begin
    GetModuleId := TJVCSGetModuleId.Create(nil);
    try
      GetModuleId.ModuleName := AModuleRevisionList.ModuleName;
      FConnection.SendRequest(GetModuleId);
      ModuleID := GetModuleId.ModuleID;
    finally
      GetModuleId.Free;
    end;
    if ModuleID > 0 then
    begin
      AModuleRevisionList.ModuleID := ModuleID;
      GetModuleHistory := TJVCSGetModuleHistory.Create(nil);
      try
        GetModuleHistory.ModuleID := ModuleID;
        FConnection.SendRequest(GetModuleHistory);

        CurrentRevisionInfo.RevisionID := -1;
        LastRevisionID := -1;
        for I := 0 to Pred(GetModuleHistory.OutputItemCount) do
        begin
          if GetModuleHistory.OutputItems[I].RevisionID = CurrentRevisionInfo.RevisionID then
            CurrentRevisionInfo.Timestamp := GetModuleHistory.OutputItems[I].Timestamp
          else
            CurrentRevisionInfo := GetModuleHistory.OutputItems[I];
          FixedExtension := TrimRight(GetModuleHistory.OutputItems[I].Extension);
          if SameText(FixedExtension, AModuleRevisionList.Extension) and
            (LastRevisionID <> GetModuleHistory.OutputItems[I].RevisionID) then
          begin
            LastRevisionID := GetModuleHistory.OutputItems[I].RevisionID;
            ModuleRevision := AModuleRevisionList.AddRevision;
            ModuleRevision.RevisionID := CurrentRevisionInfo.RevisionID;
            ModuleRevision.RevisionStr := Format('%d.%d', [CurrentRevisionInfo.Version, CurrentRevisionInfo.Revision]);
            ModuleRevision.UserStr := CurrentRevisionInfo.UserName;
            ModuleRevision.TimeStamp := CurrentRevisionInfo.Timestamp;
            ModuleRevision.CheckInComment := CurrentRevisionInfo.CheckinComment;
          end;
        end;
      finally
        GetModuleHistory.Free;
      end;
    end;
  end;
end;

function TJVCSConnectionLineHistoryProvider.GetModuleExtensions(const AModuleName: string; AExtensions: TStrings): Boolean;
var
  GetModuleId: TJVCSGetModuleId;
  GetModuleHistory: TJVCSGetModuleHistory;
  ModuleID: Integer;
  I: Integer;
  FixedExtension: string;
begin
  Result := False;
  if IsConnectionOkay and (AModuleName <> '') then
  begin
    GetModuleId := TJVCSGetModuleId.Create(nil);
    try
      GetModuleId.ModuleName := AModuleName;
      FConnection.SendRequest(GetModuleId);
      ModuleID := GetModuleId.ModuleID;
    finally
      GetModuleId.Free;
    end;
    if ModuleID > 0 then
    begin
      AExtensions.Clear;
      GetModuleHistory := TJVCSGetModuleHistory.Create(nil);
      try
        GetModuleHistory.ModuleID := ModuleID;
        FConnection.SendRequest(GetModuleHistory);
        Result := True;
        for I := 0 to Pred(GetModuleHistory.OutputItemCount) do
        begin
          FixedExtension := TrimRight(GetModuleHistory.OutputItems[I].Extension);
          if AExtensions.IndexOf(FixedExtension) = -1 then
            AExtensions.Add(FixedExtension);
        end;
      finally
        GetModuleHistory.Free;
      end;
    end;
  end;
end;

procedure TJVCSConnectionLineHistoryProvider.GetRevisionContent(AModuleRevision: TJVCSLineHistoryModuleRevision; AStream: TStream);
var
  GetSingleBlob: TJVCSGetSingleBlob;
begin
  if IsConnectionOkay and Assigned(AModuleRevision) and Assigned(AStream) and
    Assigned(AModuleRevision.List) and (AModuleRevision.RevisionID > 0) then
  begin
    GetSingleBlob := TJVCSGetSingleBlob.Create(nil);
    try
      GetSingleBlob.RevisionID := AModuleRevision.RevisionID;
      GetSingleBlob.Extension := AModuleRevision.List.Extension;
      FConnection.SendRequest(GetSingleBlob);
      GetSingleBlob.ExtractBlobToStream(GetSingleBlob.ModuleBinary, AStream);
    finally
      GetSingleBlob.Free;
    end;
  end;
end;

function TJVCSConnectionLineHistoryProvider.GetServerInfo: string;
begin
  Result := '';
  if IsConnectionOkay then
    Result := Trim(FConnection.Server) + ':' + Trim(FConnection.Port);
end;

function TJVCSConnectionLineHistoryProvider.IsConnectionOkay: Boolean;
begin
  Result := Assigned(FConnection) and (FConnection.Server <> '') and (FConnection.Port <> '');
end;

function TJVCSConnectionLineHistoryProvider.GetModuleCheckoutState(const AModuleName: string;
  var ACheckedOut: Boolean; ACRCList: TStrings): Boolean;
var
  GetModuleId: TJVCSGetModuleId;
  GetRevisionListById: TJVCSGetRevisionListById;
  GetRevisionListByIdOutputItem: TGetRevisionListByIdOutputItem;
  I, ModuleID, MaxVersion, MaxRevision, MaxRevisionID: Integer;
  GetRevisionStatus: TJVCSGetRevisionStatus;
  FixedExtension: string;
  FoundCheckOutState, FoundCRC: Boolean;
begin
  Result := False;
  MaxVersion := -1;
  MaxRevision := -1;
  MaxRevisionID := -1;
  if IsConnectionOkay and (AModuleName <> '') then
  begin
    GetModuleId := TJVCSGetModuleId.Create(nil);
    try
      GetModuleId.ModuleName := AModuleName;
      FConnection.SendRequest(GetModuleId);
      ModuleID := GetModuleId.ModuleID;
    finally
      GetModuleId.Free;
    end;
    if ModuleID > 0 then
    begin
      FoundCheckOutState := False;
      GetRevisionListById := TJVCSGetRevisionListById.Create(nil);
      try
        GetRevisionListById.ModuleID := ModuleID;
        FConnection.SendRequest(GetRevisionListById);
        for I := 0 to Pred(GetRevisionListByID.OutputItemCount) do
        begin
          GetRevisionListByIdOutputItem := GetRevisionListByID.OutputItems[I];
          if (I = 0) or (GetRevisionListByIdOutputItem.Version > MaxVersion) or
            ((GetRevisionListByIdOutputItem.Version = MaxVersion) and
            (GetRevisionListByIdOutputItem.Revision >= MaxRevision)) then
          begin
            MaxVersion := GetRevisionListByIdOutputItem.Version;
            MaxRevision := GetRevisionListByIdOutputItem.Revision;
            MaxRevisionID := GetRevisionListByIdOutputItem.RevisionID;
            FoundCheckOutState := True;
            ACheckedOut := GetRevisionListByIdOutputItem.CheckedOut and
              SameText(GetRevisionListByIdOutputItem.Owner, FConnection.UserName);
          end;
        end;
      finally
        GetRevisionListById.Free;
      end;
      FoundCRC := False;
      if (MaxRevisionID <> -1) and Assigned(ACRCList) then
      begin
        GetRevisionStatus := TJVCSGetRevisionStatus.Create(nil);
        try
          GetRevisionStatus.RevisionID := MaxRevisionID;
          FConnection.SendRequest(GetRevisionStatus);
          if GetRevisionStatus.OutputItemCount > 0 then
          begin
            FoundCRC := True;
            for I := 0 to Pred(GetRevisionStatus.OutputItemCount) do
            begin
              FixedExtension := TrimRight(GetRevisionStatus.OutputItems[I].RevisionExtension);
              ACRCList.AddObject(FixedExtension, TObject(GetRevisionStatus.OutputItems[I].RevisionOriginalCRC));
            end;
          end;
        finally
          GetRevisionStatus.Free;
        end;
      end;
      Result := FoundCheckOutState and (not Assigned(ACRCList) or FoundCRC);
    end;
  end;
end;

end.
