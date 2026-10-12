(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSBranchTreeViewFrame.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2006/06/28  USchuster - new unit
2006/12/16  USchuster - added user and date column to treeview
2007/04/18  USchuster - fixed access rights problem (exchanged TJVCSGetUserlist with TJVCSGetUsers [requires much lesser access rights])
2008/06/08  USchuster - fixed usage of wrong pointer type
2010/01/24  USchuster - changes for the selection of a branch to remove (Mantis #5102)
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit JVCSBranchTreeViewFrame;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  VirtualTrees, DBModule, JVCSBranchClientObj, Contnrs, JVCSClientObj;

type
  TJVCSBranchTreeViewFrm = class(TFrame)
    vtBranch: TVirtualStringTree;
    procedure vtBranchInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure vtBranchInitChildren(Sender: TBaseVirtualTree;
      Node: PVirtualNode; var ChildCount: Cardinal);
    procedure vtBranchGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure vtBranchFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
  private
    { Private declarations }
    FBranchItemList: TObjectList;
    FOnSelection: TNotifyEvent;
    FRootItem: TObject;
    procedure DoHandleSelection;
    function GetSelectedBranchID: Integer;
    function GetSelectedBranchIsRemovable: Boolean;
    function GetSelectedBranchName: string;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Init;
    property SelectedBranchID: Integer read GetSelectedBranchID;
    property SelectedBranchIsRemovable: Boolean read GetSelectedBranchIsRemovable;
    property SelectedBranchName: string read GetSelectedBranchName;    
    property OnSelection: TNotifyEvent read FOnSelection write FOnSelection;
  end;

implementation

{$R *.dfm}

type
  TJVCSBranchItem = class(TObject)
  private
    FCreatedBy: Integer;
    FCreatedByUser: string;
    FCreatedIn: TDateTime;
    FID: Integer;
    FName: string;
    FParentID: Integer;
  public
    constructor Create(AID: Integer; AName: string; AParentID: Integer);
    property CreatedBy: Integer read FCreatedBy write FCreatedBy;
    property CreatedByUser: string read FCreatedByUser write FCreatedByUser;     
    property CreatedIn: TDateTime read FCreatedIn write FCreatedIn;
    property ID: Integer read FID;
    property Name: string read FName write FName;
    property ParentID: Integer read FParentID;
  end;

  TJVCSBranchTreeItem = class(TObject)
  private
    FItem: TJVCSBranchItem;
    FItems: TObjectList;
    function GetCount: Integer;
    function GetItems(AIndex: Integer): TJVCSBranchTreeItem;
  public
    constructor Create(AItem: TJVCSBranchItem);
    destructor Destroy; override;
    function Add(AItem: TJVCSBranchItem): TJVCSBranchTreeItem;
    procedure Clear;
    property Count: Integer read GetCount;
    property Item: TJVCSBranchItem read FItem;
    property Items[AIndex: Integer]: TJVCSBranchTreeItem read GetItems; default;
  end;

constructor TJVCSBranchItem.Create(AID: Integer; AName: string; AParentID: Integer);
begin
  inherited Create;
  FCreatedBy := 0;
  FCreatedByUser := '';
  FCreatedIn := 0;
  FID := AID;
  FName := AName;
  FParentID := AParentID;
end;

constructor TJVCSBranchTreeItem.Create(AItem: TJVCSBranchItem);
begin
  inherited Create;
  FItem := AItem;
  FItems := TObjectList.Create;
end;

destructor TJVCSBranchTreeItem.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

function TJVCSBranchTreeItem.Add(AItem: TJVCSBranchItem): TJVCSBranchTreeItem;
begin
  FItems.Add(TJVCSBranchTreeItem.Create(AItem));
  Result := TJVCSBranchTreeItem(FItems.Last);
end;

procedure TJVCSBranchTreeItem.Clear;
begin
  FItems.Clear;
end;

function TJVCSBranchTreeItem.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TJVCSBranchTreeItem.GetItems(AIndex: Integer): TJVCSBranchTreeItem;
begin
  Result := TJVCSBranchTreeItem(FItems[AIndex]);
end;

constructor TJVCSBranchTreeViewFrm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBranchItemList := TObjectList.Create;
  FRootItem := nil;
  FOnSelection := nil;
  vtBranch.NodeDataSize := SizeOf(TJVCSBranchTreeItem);
end;

destructor TJVCSBranchTreeViewFrm.Destroy;
begin
  FreeAndNil(FRootItem);
  FBranchItemList.Free;
  inherited Destroy;
end;

procedure TJVCSBranchTreeViewFrm.DoHandleSelection;
begin
  if Assigned(FOnSelection) then
    FOnSelection(Self);
end;

function TJVCSBranchTreeViewFrm.GetSelectedBranchID: Integer;
var
  Data: ^TJVCSBranchTreeItem;
begin
  Result := -1;
  if Assigned(vtBranch.FocusedNode) then
  begin
    Data := vtBranch.GetNodeData(vtBranch.FocusedNode);
    Result := Data^.Item.ID;
  end;
end;

function TJVCSBranchTreeViewFrm.GetSelectedBranchIsRemovable: Boolean;
var
  Data: ^TJVCSBranchTreeItem;
begin
  Result := False;
  if Assigned(vtBranch.FocusedNode) then
  begin
    Data := vtBranch.GetNodeData(vtBranch.FocusedNode);
    Result := (Data^.Item.ParentID > 0) and (Data^.Count = 0);
  end;
end;

function TJVCSBranchTreeViewFrm.GetSelectedBranchName: string;
var
  Data: ^TJVCSBranchTreeItem;
begin
  Result := '';
  if Assigned(vtBranch.FocusedNode) then
  begin
    Data := vtBranch.GetNodeData(vtBranch.FocusedNode);
    Result := Data^.Item.Name;
  end;
end;

function SortByParentID(AItem1, AItem2: Pointer): Integer;
begin
  Result := TJVCSBranchItem(AItem1).ParentID - TJVCSBranchItem(AItem2).ParentID;
  if Result = 0 then
    Result := TJVCSBranchItem(AItem1).ID - TJVCSBranchItem(AItem2).ID;
end;

function SortForSearchChilds(AItem1, AItem2: Pointer): Integer;
begin
  Result := TJVCSBranchItem(AItem1).ParentID - Integer(AItem2);
end;

function ListIndexOf(AList: TList; ASearchValue: Pointer; ACompareFunction: TListSortCompare): Integer;
var
  RangeStart, RangeEnd, MidItemIndex, CompareRes: Integer;
begin
  Result := -1;
  if (AList.Count > 0) and (ACompareFunction(AList[0], ASearchValue) <= 0) and
    (ACompareFunction(AList[Pred(AList.Count)], ASearchValue) >= 0)
  then
  begin
    RangeStart := 0;
    RangeEnd := AList.Count;
    while (RangeStart <= RangeEnd) and (Result = -1) do
    begin
      MidItemIndex := (RangeStart + RangeEnd) shr 1;
      CompareRes := ACompareFunction(AList[MidItemIndex], ASearchValue);
      if CompareRes = 0 then
        Result := MidItemIndex
      else
      if CompareRes > 0 then
        RangeEnd := MidItemIndex - 1
      else
        RangeStart := MidItemIndex + 1;
    end;
  end;
end;

function SortByUserID(AItem1, AItem2: Pointer): Integer;
begin
  Result := PGetUsersOutputItem(AItem1)^.UserID - PGetUsersOutputItem(AItem2)^.UserID;
end;

function ListRange(AList: TList; ASearchValue: Pointer; ACompareFunction: TListSortCompare; var AStart, AEnde: Integer): Boolean;
var
  Idx: Integer;
begin
  Idx := ListIndexOf(AList, ASearchValue, ACompareFunction);
  Result := Idx <> -1;
  if Result then
  begin
    AStart := Idx;
    AEnde := Idx;
    while (Idx >= 0) and (ACompareFunction(AList[Idx], ASearchValue) = 0) do
    begin
      AStart := Idx;
      Dec(Idx);
    end;
    Idx := AEnde;
    while (Idx < AList.Count) and (ACompareFunction(AList[Idx], ASearchValue) = 0) do
    begin
      AEnde := Idx;
      Inc(Idx);
    end;
  end;
end;

procedure TJVCSBranchTreeViewFrm.Init;

  procedure AddChilds(ACurrentItem: TJVCSBranchTreeItem);
  var
    I, Start, Ende: Integer;
  begin
    if Assigned(ACurrentItem) then
      if ListRange(FBranchItemList, Pointer(ACurrentItem.Item.ID), SortForSearchChilds, Start, Ende) then
      begin
        for I := Start to Ende do
          ACurrentItem.Add(TJVCSBranchItem(FBranchItemList[I]));
        for I := 0 to Pred(ACurrentItem.Count) do
          AddChilds(ACurrentItem[I]);
      end;
  end;

var
  GetBranchList: TJVCSGetBranchList;
  GetUsers: TJVCSGetUsers;
  BranchTreeItem: TJVCSBranchTreeItem;
  BranchItem: TJVCSBranchItem;
  I, Idx: Integer;
  S: string;
  TempUserPtrList: TList;
  UserPtr: PGetUsersOutputItem;
begin
  vtBranch.BeginUpdate;
  try
    vtBranch.RootNodeCount := 0;
    FreeAndNil(FRootItem);
    FBranchItemList.Clear;
    GetBranchList := TJVCSGetBranchList.Create(nil);
    try
      GetBranchList.IncludeDetails := False;
      DataModule1.ClientObjectSendRequest(GetBranchList);
      for I := 0 to Pred(GetBranchList.OutputItemCount) do
        with GetBranchList.OutputItems[I] do
        begin
          BranchItem := TJVCSBranchItem.Create(BranchID, Name, ParentBranchID);
          FBranchItemList.Add(BranchItem);
          BranchItem.CreatedBy := Created_By;
          BranchItem.CreatedIn := Created_In;
        end;
    finally
      GetBranchList.Free;
    end;
    if FBranchItemList.Count > 1 then
      FBranchItemList.Sort(SortByParentID);
    if FBranchItemList.Count > 0 then
    begin
      TempUserPtrList := TList.Create;
      try
        GetUsers := TJVCSGetUsers.Create(nil);
        try
          DataModule1.ClientObjectSendRequest(GetUsers);
          for I := 0 to Pred(GetUsers.OutputItemCount) do
          begin
            New(UserPtr);
            TempUserPtrList.Add(UserPtr);
            UserPtr^ := GetUsers.OutputItems[I];
          end;
        finally
          GetUsers.Free;
        end;
        TempUserPtrList.Sort(SortByUserID);
        for I := 0 to Pred(FBranchItemList.Count) do
        begin
          BranchItem := TJVCSBranchItem(FBranchItemList[I]);
          S := '';
          if BranchItem.CreatedBy > 0 then
          begin
            New(UserPtr);
            try
              UserPtr^.UserID := BranchItem.CreatedBy;
              Idx := ListIndexOf(TempUserPtrList, UserPtr, SortByUserID);
            finally
              Dispose(UserPtr);
            end;
            if Idx <> -1 then
              S := PGetUsersOutputItem(TempUserPtrList[Idx])^.UserName
            else
            if BranchItem.CreatedBy > 0 then
              S := IntToStr(BranchItem.CreatedBy);
          end;
          BranchItem.CreatedByUser := S;
        end;
        for I := 0 to Pred(TempUserPtrList.Count) do
          Dispose(TempUserPtrList[I]);
      finally
        TempUserPtrList.Free;
      end;
    end;
    if (FBranchItemList.Count > 0) and (TJVCSBranchItem(FBranchItemList[0]).ParentID < 1) then
    begin
      FRootItem := TJVCSBranchTreeItem.Create(TJVCSBranchItem(FBranchItemList[0]));
      BranchTreeItem := TJVCSBranchTreeItem(FRootItem);
      AddChilds(BranchTreeItem);
    end;
    if Assigned(FRootItem) then
      vtBranch.RootNodeCount := 1;
  finally
    vtBranch.EndUpdate;
  end;
end;

procedure TJVCSBranchTreeViewFrm.vtBranchInitNode(Sender: TBaseVirtualTree;
  ParentNode, Node: PVirtualNode;
  var InitialStates: TVirtualNodeInitStates);
var
  Data, ParentData: ^TJVCSBranchTreeItem;
begin
  Data := Sender.GetNodeData(Node);
  if ParentNode = nil then
    Data^ := TJVCSBranchTreeItem(FRootItem)
  else
  begin
    ParentData := Sender.GetNodeData(ParentNode);
    if Assigned(ParentData) and Assigned(ParentData^) then
      Data^ := ParentData^.Items[Node^.Index];
  end;
  if Assigned(Data^) and (Data^.Count > 0) then
  begin
    Include(InitialStates, ivsHasChildren);
    Include(InitialStates, ivsExpanded);
  end;
end;

procedure TJVCSBranchTreeViewFrm.vtBranchInitChildren(
  Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
var
  Data: ^TJVCSBranchTreeItem;
begin
  Data := Sender.GetNodeData(Node);
  ChildCount := Data^.Count;
end;

procedure TJVCSBranchTreeViewFrm.vtBranchGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
var
  Data: ^TJVCSBranchTreeItem;
begin
  CellText := '';
  if Column in [0..2] then
  begin
    Data := Sender.GetNodeData(Node);
    case Column of
      0: CellText := Data^.Item.Name;
      1: CellText := Data^.Item.CreatedByUser;
      2: if Data^.Item.CreatedIn > 1 then
           CellText := DateTimeToStr(Data^.Item.CreatedIn);
    end;
  end;
end;

procedure TJVCSBranchTreeViewFrm.vtBranchFocusChanged(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
begin
  DoHandleSelection;
end;

end.
