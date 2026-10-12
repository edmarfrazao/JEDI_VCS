(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSHistoryCommon.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2006/01/09  USchuster - new unit for mantis #3416 to avoid double code
2008/06/08  USchuster - fixed memory leak (Mantis #3082)
2008/11/15  USchuster - added TRevisionLabelStrs to encapsulate retrieving of the module revision labels
                        (it does use GET_LABELS_BY_MODULE if available otherwise GET_LABELS_BY_REVISION)

-----------------------------------------------------------------------------*)

unit JVCSHistoryCommon;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  SysUtils, Classes, ComCtrls, JVCSClasses;

type
  TRevisionIDLabelStr = class(TObject)
  private
    FRevisionID: Integer;
    FLabelStr: string;
  public
    constructor Create(ARevisionID: Integer);
    property RevisionID: Integer read FRevisionID;
    property LabelStr: string read FLabelStr write FLabelStr;
  end;

  TRevisionIDLabelStrList = class(TCustomFastSortedObjectList)
  private
    function GetItem(AIndex: Integer): TRevisionIDLabelStr;
  protected
    function CompareItems(AItem1, AItem2: Pointer): Integer; override;
  public
    function Add(ARevisionID: Integer): TRevisionIDLabelStr;
    property Items[AIndex: Integer]: TRevisionIDLabelStr read GetItem; default;
  end;

  TRevisionLabelStrs = class(TObject)
  private
    FModuleID: Integer;
    FItems: TRevisionIDLabelStrList;
    FUseGetLabelsByRevision: Boolean;
    procedure Init;
  public
    constructor Create(AModuleID: Integer);
    destructor Destroy; override;
    function GetRevisionLabelsStr(ARevisionID: Integer): string;
    property ModuleID: Integer read FModuleID;
    property UseGetLabelsByRevision: Boolean read FUseGetLabelsByRevision;
  end;

function GetRevisionLabelsStr(ARevisionID: Integer): string;
function GetFirstRevisionItemFromHistoryListView(AListView: TListView; ARevisionMemberItem: TListItem): TListItem;

implementation

uses
  JVCSClientObj, DBModule, JVCSNewClientObj;

constructor TRevisionIDLabelStr.Create(ARevisionID: Integer);
begin
  inherited Create;
  FRevisionID := ARevisionID;
  FLabelStr := '';
end;

function TRevisionIDLabelStrList.Add(ARevisionID: Integer): TRevisionIDLabelStr;
var
  Idx: Integer;
  Item: TRevisionIDLabelStr;
begin
  Idx := 0;
  Item := TRevisionIDLabelStr.Create(ARevisionID);
  try
    Idx := IndexOf(Item);
    if Idx = -1 then
    begin
      inherited Add(Item);
      Result := Item;
    end
    else
      Result := FList[Idx];
  finally
    if Idx <> -1 then
      Item.Free;
  end;
end;

function TRevisionIDLabelStrList.CompareItems(AItem1, AItem2: Pointer): Integer;
begin
  Result := TRevisionIDLabelStr(AItem1).RevisionID - TRevisionIDLabelStr(AItem2).RevisionID;
end;

function TRevisionIDLabelStrList.GetItem(AIndex: Integer): TRevisionIDLabelStr;
begin
  Result := FList[AIndex];
end;

constructor TRevisionLabelStrs.Create(AModuleID: Integer);
begin
  inherited Create;
  FModuleID := AModuleID;
  FItems := TRevisionIDLabelStrList.Create;
  FUseGetLabelsByRevision := False;
  Init;
end;

destructor TRevisionLabelStrs.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

function TRevisionLabelStrs.GetRevisionLabelsStr(ARevisionID: Integer): string;
var
  Idx: Integer;
  Item: TRevisionIDLabelStr;
begin
  if FUseGetLabelsByRevision then
    Result := JVCSHistoryCommon.GetRevisionLabelsStr(ARevisionID)
  else
  begin
    Item := TRevisionIDLabelStr.Create(ARevisionID);
    try
      Idx := FItems.IndexOf(Item);
      if Idx <> -1 then
        Result := TRevisionIDLabelStr(FItems[Idx]).LabelStr
      else
        Result := '';
    finally
      Item.Free;
    end;
  end;
end;

function SortRevisionLabelsByIDDesc(Item1, Item2: Pointer): Integer;
begin
  Result := PGetLabelsByModuleOutputItem(Item1)^.RevisionID - PGetLabelsByModuleOutputItem(Item2)^.RevisionID;
  if Result = 0 then
    Result := PGetLabelsByModuleOutputItem(Item2)^.LabelID - PGetLabelsByModuleOutputItem(Item1)^.LabelID;
end;

procedure TRevisionLabelStrs.Init;
var
  GetLabelsByModule: TJVCSGetLabelsByModule;
  Item: TRevisionIDLabelStr;
  I: Integer;
  List: TList;
  Ptr: PGetLabelsByModuleOutputItem;
begin
  if GetJvcsConnection.SupportsFunction(TJVCSGetLabelsByModule) then
  begin
    GetLabelsByModule := TJVCSGetLabelsByModule.Create(nil);
    try
      GetLabelsByModule.ModuleID := FModuleID;
      DataModule1.ClientObjectSendRequest(GetLabelsByModule);
      List := TList.Create;
      try
        for I := 0 to Pred(GetLabelsByModule.OutputItemCount) do
        begin
          New(Ptr);
          List.Add(Ptr);
          Ptr^ := GetLabelsByModule.OutputItems[I];
        end;
        List.Sort(SortRevisionLabelsByIDDesc);
        for I := 0 to Pred(List.Count) do
        begin
          Ptr := List[I];
          Item := FItems.Add(Ptr^.RevisionID);
          if Item.LabelStr = '' then
            Item.LabelStr := Ptr^.LabelName
          else
            Item.LabelStr := Item.LabelStr + '/' + Ptr^.LabelName;
        end;
      finally
        for I := 0 to Pred(List.Count) do
          Dispose(PGetLabelsByModuleOutputItem(List[I]));
        List.Free;
      end;
    finally
      GetLabelsByModule.Free;
    end;
  end
  else
    FUseGetLabelsByRevision := True;
end;

function SortLabelsByIDDesc(Item1, Item2: Pointer): Integer;
begin
  Result := PGetLabelsByRevisionOutputItem(Item2)^.LabelID - PGetLabelsByRevisionOutputItem(Item1)^.LabelID;
end;

function GetRevisionLabelsStr(ARevisionID: Integer): string;
var
  LabelCount: Integer;
  LabelsByRevision: TJVCSGetLabelsByRevision;
  LabelItemPtr: PGetLabelsByRevisionOutputItem;
  LabelList: TList;
  I: Integer;
begin
  Result := '';

  LabelList := TList.Create;
  try
    LabelsByRevision := TJVCSGetLabelsByRevision.Create(nil);
    try
      LabelsByRevision.RevisionID := ARevisionID;
      DataModule1.ClientObjectSendRequest(LabelsByRevision);

      with LabelsByRevision do
      begin
        for I := 0 to OutputItemCount - 1 do
        begin
          New(LabelItemPtr);
          LabelList.Add(LabelItemPtr);
          LabelItemPtr^ := OutputItems[I];
        end;
      end;
    finally
      LabelsByRevision.Free;
    end;
    LabelList.Sort(SortLabelsByIDDesc);
    LabelCount := LabelList.Count;
    for I := 0 to Pred(LabelList.Count) do
    begin
      LabelItemPtr := LabelList[I];
      if Result <> '' then Result := Result + '/';
      Result := Result + LabelItemPtr^.LabelName;
    end;
  finally
    for I := 0 to Pred(LabelList.Count) do
      Dispose(PGetLabelsByRevisionOutputItem(LabelList[I]));
    LabelList.Free;
  end;

  if LabelCount > 1 then
    Result := Format('(%d) %s', [LabelCount, Result]);
end;

function GetFirstRevisionItemFromHistoryListView(AListView: TListView; ARevisionMemberItem: TListItem): TListItem;
var
  I: Integer;
begin
  Result := nil;
  if Assigned(ARevisionMemberItem) and (ARevisionMemberItem.SubItems.Count >= 7) then
  begin
    I := ARevisionMemberItem.Index;
    if (I >= 0) and (AListView.Items.Count > I) and
      (AListView.Items[I] = ARevisionMemberItem) then
    begin
      while (not Assigned(Result)) and (I >= 0) and
        (AListView.Items[I].SubItems.Count >= 7) and
        (AListView.Items[I].SubItems[6] = ARevisionMemberItem.SubItems[6]) do
      begin
        if AListView.Items[I].Caption <> '' then
          Result := AListView.Items[I]
        else
          Dec(I);
      end;
    end;
  end;
  if not Assigned(Result) then
    Result := ARevisionMemberItem;
end;

end.