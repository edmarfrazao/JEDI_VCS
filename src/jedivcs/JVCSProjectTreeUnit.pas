(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSProjectTreeUnit.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2007/04/23  USchuster - new unit
2007/06/04  USchuster - changes for project treeview dialog
2007/06/17  USchuster - added AlwaysShowUnassignedProjects to TProjectTreeContainer
2008/06/08  USchuster - fixed memory leaks (Mantis #3082)
                      - simplified memory leak fix
2008/06/22  USchuster - implemented new group sorting without tree level to avoid
                        wrong order if tree level is wrong (Mantis #4379)
2008/12/19  USchuster - changes for new tree with filter

-----------------------------------------------------------------------------*)

unit JVCSProjectTreeUnit;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  SysUtils, Classes, Contnrs, ComCtrls, JVCSConnect, JVCSClasses, JVCSDataClasses,
  JclStrings, JclResources, VirtualTrees;

type
  TProjectTreeProjectData = class(TObject)
  private
    FBugIndex: Integer;
    FDeleted: Boolean;
    FProjectID: Integer;
    FProjectName: string;
  public
    constructor Create(AProjectID: Integer; AProjectName: string; ADeleted: Boolean);
    property BugIndex: Integer read FBugIndex write FBugIndex;
    property Deleted: Boolean read FDeleted;
    property ProjectID: Integer read FProjectID;
    property ProjectName: string read FProjectName;
  end;

  TCustomProjectTreeItem = class(TPersistent)
  protected
    FParent: TCustomProjectTreeItem;
  public
    constructor Create(AParent: TCustomProjectTreeItem);
    property Parent: TCustomProjectTreeItem read FParent;
  end;

  TProjectTreeProject = class(TCustomProjectTreeItem)
  private
    FProjectData: TProjectTreeProjectData;
    FUnassigned: Boolean;
    function GetProjectName: string;
  protected
    procedure AssignTo(Dest: TPersistent); override;
    procedure SetProjectData(AProjectData: TProjectTreeProjectData);
  public
    constructor Create(AParent: TCustomProjectTreeItem; AProjectData: TProjectTreeProjectData);
    property ProjectData: TProjectTreeProjectData read FProjectData;
    property ProjectName: string read GetProjectName;
    property Unassigned: Boolean read FUnassigned write FUnassigned;
  end;

  TProjectTreeGroup = class(TCustomProjectTreeItem)
  private
    FGroupDescription: string;
    FGroupID: Integer;
    FGroupIsUnassigned: Boolean;
    FGroupName: string;
    FItems: TObjectList;
    FProjects: TObjectList;
    function GetCount: Integer;
    function GetItems(AIndex: Integer): TProjectTreeGroup;
    function GetLevel: Integer;
    function GetProjectCount: Integer;
    function GetProjects(AIndex: Integer): TProjectTreeProject;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create(AParent: TCustomProjectTreeItem; AGroupID: Integer; const AGroupName, AGroupDescription: string);
    destructor Destroy; override;
    function AddGroup(AGroupID: Integer; const AGroupName, AGroupDescription: string): TProjectTreeGroup;
    function AddProject(AProjectData: TProjectTreeProjectData): TProjectTreeProject;
    procedure Clear;
    function RemoveGroup(AGroupID: Integer): Boolean;
    function RemoveProject(AProjectID: Integer): Boolean;
    procedure SortGroupsByName;
    procedure SortProjectsByName;
    property GroupDescription: string read FGroupDescription write FGroupDescription;
    property GroupID: Integer read FGroupID;
    property GroupName: string read FGroupName write FGroupName;
    property GroupCount: Integer read GetCount;
    property GroupIsUnassigned: Boolean read FGroupIsUnassigned write FGroupIsUnassigned;
    property GroupItems[AIndex: Integer]: TProjectTreeGroup read GetItems; default;
    property Level: Integer read GetLevel;
    property ProjectCount: Integer read GetProjectCount;
    property Projects[AIndex: Integer]: TProjectTreeProject read GetProjects;
  end;

  TVSTTreeItem = class(TObject)
  private
    FExpanded: Boolean;
    FItems: TObjectList;
    FLinkedItem: TCustomProjectTreeItem;
    FText: string;
    function GetCount: Integer;
    function GetItems(AIndex: Integer): TVSTTreeItem;
  public
    constructor Create;
    destructor Destroy; override;
    function Add: TVSTTreeItem;
    procedure Clear;
    property Count: Integer read GetCount;
    property Items[AIndex: Integer]: TVSTTreeItem read GetItems; default;
    property Expanded: Boolean read FExpanded write FExpanded;
    property LinkedItem: TCustomProjectTreeItem read FLinkedItem write FLinkedItem;
    property Text: string read FText write FText;
  end;

  TProjectTreeContainer = class;

  TVSTContainer = class(TObject)
  private
    FRootTreeItem: TVSTTreeItem;
    FProjectTreeContainer: TProjectTreeContainer;
    FOpenGroups: TSortedIntegerList;    
    FTopGroupID: Integer;
    FTopProjectID: Integer;
    FTopItemIsProject: Boolean;
    FSelectedGroupID: Integer;
    FSelectedProjectID: Integer;
    FSelectedItemIsProject: Boolean;
    procedure SetProjectTreeContainer(AValue: TProjectTreeContainer);
  public
    constructor Create;
    destructor Destroy; override;
    procedure RestoreStateInfo(AVirtualTree: TBaseVirtualTree);
    procedure SaveStateInfo(AVirtualTree: TBaseVirtualTree);
    procedure FilterItems(ACaseInSensitive: Boolean; const AGroupFilter: string = ''; AProjectFilter: string = ''; AOrFilter: Boolean = False);
    property RootTreeItem: TVSTTreeItem read FRootTreeItem;
    property ProjectTreeContainer: TProjectTreeContainer read FProjectTreeContainer write SetProjectTreeContainer;
  end;

  TFastProjectDataList = class(TCustomFastSortedObjectList)
  private
    function GetItem(AIndex: Integer): TProjectTreeProjectData;
  protected
    function CompareItems(AItem1, AItem2: Pointer): Integer; override;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(AList: TFastProjectDataList);
    procedure FillFromProjects(AProjects: TProjects);
    function Find(AProjectID: Integer): TProjectTreeProjectData;
    property Items[AIndex: Integer]: TProjectTreeProjectData read GetItem; default;
  end;

  TProjectTreeGroupData = class(TObject)
  private
    FGroupID: Integer;
    FData: Pointer;
  public
    constructor Create(AGroupID: Integer);
    property GroupID: Integer read FGroupID;
    property Data: Pointer read FData write FData;
  end;

  TFastGroupDataList = class(TCustomFastSortedObjectList)
  private
    function GetItem(AIndex: Integer): TProjectTreeGroupData;
  protected
    function CompareItems(AItem1, AItem2: Pointer): Integer; override;
  public
    constructor Create;
    destructor Destroy; override;
    function Find(AGroupID: Integer): TProjectTreeGroupData;
    property Items[AIndex: Integer]: TProjectTreeGroupData read GetItem; default;
  end;

  TProjectTreeContainer = class(TPersistent)
  private
    FAlwaysShowUnassignedProjects: Boolean;
    FBugIndexImageOffset: Integer;
    FProjectDataList: TFastProjectDataList;
    FRootTreeItem: TProjectTreeGroup;
    FOpenGroups: TList;
    FTopGroupID: Integer;
    FTopProjectID: Integer;
    FTopItemIsProject: Boolean;
    FSelectedGroupID: Integer;
    FSelectedProjectID: Integer;
    FSelectedItemIsProject: Boolean;
    function FindGroupItem(AProjectTreeGroup: TProjectTreeGroup; AGroupID: Integer): TProjectTreeGroup;
    procedure UpdateUnassignedProjects;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Apply(ATreeView: TTreeView);
    procedure ApplyWithState(ATreeView: TTreeView);
    procedure Clear;
    procedure IncrementalAddProject(AGroupID, AProjectID: Integer; ATreeView: TTreeView);
    procedure IncrementalInsertGroup(AGroupID, AParentGroupID: Integer; AGroupName, AGroupDescription: string; ATreeView: TTreeView);
    procedure IncrementalRenameGroup(AGroupID: Integer; AGroupName, AGroupDescription: string; ATreeView: TTreeView);
    procedure IncrementalRemoveGroup(AGroupID: Integer; ATreeView: TTreeView);
    procedure IncrementalRemoveProject(AGroupID, AProjectID: Integer; ATreeView: TTreeView);
    procedure IncrementalUpdateBugIndex(AProjectID, ABugIndex: Integer; ATreeView: TTreeView);
    procedure Read(AConnection: TJVCSConnection; AHideProjectsWithoutRights: Boolean);
    procedure RestoreTreeViewState(ATreeView: TTreeView);
    procedure SaveTreeViewState(ATreeView: TTreeView);
    property AlwaysShowUnassignedProjects: Boolean read FAlwaysShowUnassignedProjects write FAlwaysShowUnassignedProjects;
    property BugIndexImageOffset: Integer read FBugIndexImageOffset write FBugIndexImageOffset;
    property RootTreeItem: TProjectTreeGroup read FRootTreeItem;
  end;

implementation

uses
  JVCSClientObj, JVCSTypes, JVCSGUIClientResources;

constructor TProjectTreeProjectData.Create(AProjectID: Integer; AProjectName: string; ADeleted: Boolean);
begin
  inherited Create;
  FBugIndex := -1;
  FDeleted := ADeleted;
  FProjectID := AProjectID;
  FProjectName := AProjectName;
end;

constructor TCustomProjectTreeItem.Create(AParent: TCustomProjectTreeItem);
begin
  inherited Create;
  FParent := AParent;
end;

constructor TProjectTreeProject.Create(AParent: TCustomProjectTreeItem; AProjectData: TProjectTreeProjectData);
begin
  inherited Create(AParent);
  FProjectData := AProjectData;
  FUnassigned := False;
end;

procedure TProjectTreeProject.AssignTo(Dest: TPersistent);
begin
  if Dest is TProjectTreeProject then
  begin
    TProjectTreeProject(Dest).FProjectData := ProjectData;
    TProjectTreeProject(Dest).Unassigned := Unassigned;
  end
  else
    inherited AssignTo(Dest);
end;

function TProjectTreeProject.GetProjectName: string;
begin
  Result := '';
  if Assigned(FProjectData) then
    Result := FProjectData.ProjectName;
end;

procedure TProjectTreeProject.SetProjectData(AProjectData: TProjectTreeProjectData);
begin
  FProjectData := AProjectData;
end;

constructor TProjectTreeGroup.Create(AParent: TCustomProjectTreeItem; AGroupID: Integer; const AGroupName, AGroupDescription: string);
begin
  inherited Create(AParent);
  FGroupDescription := AGroupDescription;
  FGroupID := AGroupID;
  FGroupIsUnassigned := False;
  FGroupName := AGroupName;
  FItems := TObjectList.Create;
  FProjects := TObjectList.Create;
end;

destructor TProjectTreeGroup.Destroy;
begin
  FItems.Free;
  FProjects.Free;
  inherited Destroy;
end;

function TProjectTreeGroup.AddGroup(AGroupID: Integer; const AGroupName, AGroupDescription: string): TProjectTreeGroup;
begin
  FItems.Add(TProjectTreeGroup.Create(Self, AGroupID, AGroupName, AGroupDescription));
  Result := TProjectTreeGroup(FItems.Last);
end;

function TProjectTreeGroup.AddProject(AProjectData: TProjectTreeProjectData): TProjectTreeProject;
begin
  FProjects.Add(TProjectTreeProject.Create(Self, AProjectData));
  Result := TProjectTreeProject(FProjects.Last);
end;

procedure TProjectTreeGroup.AssignTo(Dest: TPersistent);
var
  I: Integer;
begin
  if Dest is TProjectTreeGroup then
  begin
    TProjectTreeGroup(Dest).Clear;
    TProjectTreeGroup(Dest).FGroupID := GroupID;
    TProjectTreeGroup(Dest).FGroupName := GroupName;
    TProjectTreeGroup(Dest).FGroupDescription := GroupDescription;
    TProjectTreeGroup(Dest).GroupIsUnassigned := GroupIsUnassigned;
    for I := 0 to Pred(GroupCount) do
      TProjectTreeGroup(Dest).AddGroup(0, '', '').Assign(GroupItems[I]);
    for I := 0 to Pred(ProjectCount) do
      TProjectTreeGroup(Dest).AddProject(Projects[I].ProjectData);
  end
  else
    inherited AssignTo(Dest);
end;

procedure TProjectTreeGroup.Clear;
begin
  FItems.Clear;
  FProjects.Clear;
end;

function TProjectTreeGroup.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TProjectTreeGroup.GetItems(AIndex: Integer): TProjectTreeGroup;
begin
  Result := TProjectTreeGroup(FItems[AIndex]);
end;

function TProjectTreeGroup.GetLevel: Integer;
var
  TempParent: TCustomProjectTreeItem;
begin
  Result := 0;
  TempParent := Parent;
  while Assigned(TempParent) do
  begin
    TempParent := TempParent.Parent;
    Inc(Result);
  end;
end;

function TProjectTreeGroup.GetProjectCount: Integer;
begin
  Result := FProjects.Count;
end;

function TProjectTreeGroup.GetProjects(AIndex: Integer): TProjectTreeProject;
begin
  Result := TProjectTreeProject(FProjects[AIndex]);
end;

function TProjectTreeGroup.RemoveGroup(AGroupID: Integer): Boolean;
var
  I, Idx: Integer;
begin
  Idx := -1;
  for I := 0 to Pred(GroupCount) do
    if GroupItems[I].GroupID = AGroupID then
    begin
      Idx := I;
      Break;
    end;
  Result := Idx <> -1;
  if Result then
    FItems.Delete(Idx);
end;

function TProjectTreeGroup.RemoveProject(AProjectID: Integer): Boolean;
var
  I, Idx: Integer;
begin
  Idx := -1;
  for I := 0 to Pred(ProjectCount) do
    if Assigned(Projects[I].ProjectData) and (Projects[I].ProjectData.ProjectID = AProjectID) then
    begin
      Idx := I;
      Break;
    end;
  Result := Idx <> -1;
  if Result then
    FProjects.Delete(Idx);
end;

function SortByProjectTreeGroupName(AItem1, AItem2: Pointer): Integer;
begin
  Result := CompareStr(TProjectTreeGroup(AItem1).GroupName, TProjectTreeGroup(AItem2).GroupName);
end;

procedure TProjectTreeGroup.SortGroupsByName;
begin
  FItems.Sort(SortByProjectTreeGroupName);
end;

function SortByProjectTreeProjectName(AItem1, AItem2: Pointer): Integer;
begin
  Result := CompareStr(TProjectTreeProject(AItem1).ProjectName, TProjectTreeProject(AItem2).ProjectName);
end;

procedure TProjectTreeGroup.SortProjectsByName;
begin
  FProjects.Sort(SortByProjectTreeProjectName);
end;

constructor TVSTTreeItem.Create;
begin
  inherited Create;
  FExpanded := False;
  FItems := TObjectList.Create;
  FLinkedItem := nil;
end;

destructor TVSTTreeItem.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

function TVSTTreeItem.Add: TVSTTreeItem;
begin
  FItems.Add(TVSTTreeItem.Create);
  Result := TVSTTreeItem(FItems.Last);
end;

procedure TVSTTreeItem.Clear;
begin
  FItems.Clear;
end;

function TVSTTreeItem.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TVSTTreeItem.GetItems(AIndex: Integer): TVSTTreeItem;
begin
  Result := TVSTTreeItem(FItems[AIndex]);
end;

constructor TVSTContainer.Create;
begin
  inherited Create;
  FRootTreeItem := TVSTTreeItem.Create;
  FProjectTreeContainer := TProjectTreeContainer.Create;
  FOpenGroups := TSortedIntegerList.Create;
  FTopGroupID := -1;
  FTopProjectID := -1;
  FTopItemIsProject := False;
  FSelectedGroupID := -1;
  FSelectedProjectID := -1;
  FSelectedItemIsProject := False;
end;

destructor TVSTContainer.Destroy;
begin
  FOpenGroups.Free;
  FProjectTreeContainer.Free;
  FRootTreeItem.Free;
  inherited Destroy;
end;

// Derived from "Like" by Michael Winter
function StrMatches(const Substr, S: string; const Index: Integer; var AOutputStr: string): Boolean;
{$IFDEF CLR}
begin
  Result := Substr = S;
  { TODO : StrMatches }
end;
{$ELSE}
var
  StringPtr: PChar;
  PatternPtr: PChar;
  StringRes: PChar;
  PatternRes: PChar;
  OutputStringPtr: PChar;
  OutputStringRes: PChar;
  OutputStringLastPtr: PChar;
begin
  if SubStr = '' then
    raise EJclStringError.CreateRes(@RsBlankSearchString);

  Result := SubStr = '*';
  if Result then
    AOutputStr := StringOfChar('F', Length(S))
  else
    AOutputStr := StringOfChar('N', Length(S));

  if Result or (S = '') then
    Exit;

  if (Index <= 0) or (Index > Length(S)) then
    raise EJclStringError.CreateRes(@RsArgumentOutOfRange);

  StringPtr := PChar(@S[Index]);
  PatternPtr := PChar(SubStr);
  StringRes := nil;
  PatternRes := nil;

  OutputStringPtr := PChar(@AOutputStr[Index]);
  OutputStringLastPtr := nil;
  OutputStringRes := nil;

  repeat
    repeat
      case PatternPtr^ of
        #0:
          begin
            Result := StringPtr^ = #0;
            if Result or (StringRes = nil) or (PatternRes = nil) then
              Exit;

            StringPtr := StringRes;
            OutputStringPtr := OutputStringRes;
            PatternPtr := PatternRes;
            Break;
          end;
        '*':
          begin
            Inc(PatternPtr);
            PatternRes := PatternPtr;
            OutputStringLastPtr := nil;
            Break;
          end;
        '?':
          begin
            if StringPtr^ = #0 then
              Exit;
            Inc(StringPtr);
            Inc(OutputStringPtr);
            Inc(PatternPtr);
          end;
        else
          begin
            if StringPtr^ = #0 then
              Exit;
            if StringPtr^ <> PatternPtr^ then
            begin
              if (StringRes = nil) or (PatternRes = nil) then
                Exit;
              if Assigned(OutputStringLastPtr) then
                while OutputStringLastPtr <> OutputStringPtr do
                begin
                  OutputStringLastPtr^ := 'N';
                  Inc(OutputStringLastPtr);
                end;
              StringPtr := StringRes;
              OutputStringPtr := OutputStringRes;
              PatternPtr := PatternRes;
              Break;
            end
            else
            begin
              Inc(StringPtr);
              if not Assigned(OutputStringLastPtr) then
                OutputStringLastPtr := OutputStringPtr;
              OutputStringPtr^ := 'F';
              Inc(OutputStringPtr);
              Inc(PatternPtr);
            end;
          end;
      end;
    until False;

    repeat
      case PatternPtr^ of
        #0:
          begin
            Result := True;
            Exit;
          end;
        '*':
          begin
            Inc(PatternPtr);
            PatternRes := PatternPtr;
            OutputStringLastPtr := nil;
          end;
        '?':
          begin
            if StringPtr^ = #0 then
              Exit;
            Inc(StringPtr);
            Inc(OutputStringPtr);
            Inc(PatternPtr);
          end;
        else
          begin
            repeat
              if StringPtr^ = #0 then
                Exit;
              if StringPtr^ = PatternPtr^ then
              begin
                if not Assigned(OutputStringLastPtr) then
                  OutputStringLastPtr := OutputStringPtr;
                OutputStringPtr^ := 'F';
                Break;
              end;
              Inc(StringPtr);
              Inc(OutputStringPtr);
            until False;
            Inc(StringPtr);
            Inc(OutputStringPtr);
            StringRes := StringPtr;
            OutputStringRes := OutputStringPtr;
            Inc(PatternPtr);
            Break;
          end;
      end;
    until False;
  until False;
end;
{$ENDIF CLR}

function HasMatchingSubgroup(AGroup: TProjectTreeGroup; var AOutputStr: string; ACaseInSensitive: Boolean; const AFilter: string = ''): Boolean;
var
  I: Integer;
  S: string;
begin
  if AFilter = '' then
    Result := True
  else
  begin
    if ACaseInSensitive then
      Result := StrMatches(UpperCase(AFilter), UpperCase(AGroup.GroupName), 1, AOutputStr)
    else
      Result := StrMatches(AFilter, AGroup.GroupName, 1, AOutputStr);
    if not Result then
      for I := 0 to Pred(AGroup.GetCount) do
      begin
        Result := HasMatchingSubgroup(AGroup.GroupItems[I], S, ACaseInSensitive, AFilter);
        if Result then
          Break;
      end;
  end;
end;

function HasMatchingProject(AGroup: TProjectTreeGroup; ACaseInSensitive: Boolean; const AFilter: string = ''): Boolean;
var
  I: Integer;
  S: string;
begin
  if AFilter = '' then
    Result := True
  else
  begin
    Result := False;
    for I := 0 to Pred(AGroup.GetCount) do
    begin
      Result := HasMatchingProject(AGroup.GroupItems[I], ACaseInSensitive, AFilter);
      if Result then
        Break;
    end;
    if not Result then
      for I := 0 to Pred(AGroup.ProjectCount) do
      begin
        if ACaseInSensitive then
          Result := StrMatches(UpperCase(AFilter), UpperCase(AGroup.Projects[I].ProjectName), 1, S)
        else
          Result := StrMatches(AFilter, AGroup.Projects[I].ProjectName, 1, S);
        if Result then
          Break;
      end;
  end;
end;

procedure TVSTContainer.FilterItems(ACaseInSensitive: Boolean; const AGroupFilter: string = ''; AProjectFilter: string = ''; AOrFilter: Boolean = False);

  function EncodeText(const ATextStr, AFoundStr: string): string;
  var
    I: Integer;
    LastState: Char;
  begin
    if Length(ATextStr) <> Length(AFoundStr) then
      Result := ATextStr
    else
    begin
      Result := '';
      LastState := 'N';
      for I := 1 to Length(AFoundStr) do
      begin
        if LastState <> AFoundStr[I] then
        begin
          if LastState = 'N' then
            Result := Result + '<b>'
          else
            Result := Result + '</b>';
          LastState := AFoundStr[I];
        end;
        Result := Result + ATextStr[I];
      end;
      if LastState <> 'N' then
        Result := Result + '</b>';
    end;
  end;

  procedure SaveExpandedGroups(ATreeItem: TVSTTreeItem);
  var
    I, Idx, GroupID: Integer;
  begin
    for I := 0 to Pred(ATreeItem.Count) do
      if ATreeItem[I].LinkedItem is TProjectTreeGroup then
      begin
        GroupID := TProjectTreeGroup(ATreeItem[I].LinkedItem).GroupID;
        if ATreeItem[I].Expanded then
          FOpenGroups.Add(GroupID)
        else
        begin
          Idx := FOpenGroups.IndexOf(GroupID);
          if Idx <> -1 then
            FOpenGroups.Delete(Idx);
        end;
        SaveExpandedGroups(ATreeItem[I]);
      end;
  end;

  procedure AddItems(ATreeItem: TVSTTreeItem; ATreeGroup: TProjectTreeGroup);
  var
    I: Integer;
    TempTreeItem: TVSTTreeItem;
    S: string;
    IsInGroupFilter, GroupFilterMatch, ProjectFilterMatch: Boolean;
  begin
    for I := 0 to Pred(ATreeGroup.GroupCount) do
    begin
      if AGroupFilter = '' then
        IsInGroupFilter := False
      else
        IsInGroupFilter := HasMatchingSubgroup(ATreeGroup.GroupItems[I], S, ACaseInSensitive, AGroupFilter);
      GroupFilterMatch := (AGroupFilter = '') or IsInGroupFilter;
      ProjectFilterMatch := (AProjectFilter = '') or HasMatchingProject(ATreeGroup.GroupItems[I], ACaseInSensitive, AProjectFilter);
      if (AOrFilter and (GroupFilterMatch or ProjectFilterMatch)) or (GroupFilterMatch and ProjectFilterMatch) then
      begin
        TempTreeItem := ATreeItem.Add;
        TempTreeItem.LinkedItem := ATreeGroup.GroupItems[I];
        if IsInGroupFilter then
          TempTreeItem.Text := EncodeText(ATreeGroup.GroupItems[I].GroupName, S)
        else
          TempTreeItem.Text := ATreeGroup.GroupItems[I].GroupName;
        TempTreeItem.Expanded := FOpenGroups.IndexOf(ATreeGroup.GroupItems[I].GroupID) <> -1;
        AddItems(TempTreeItem, ATreeGroup.GroupItems[I]);
      end;
    end;
    for I := 0 to Pred(ATreeGroup.ProjectCount) do
      if (AProjectFilter = '') or (StrMatches(AProjectFilter, ATreeGroup.Projects[I].ProjectName, 1, S)) then
      begin
        TempTreeItem := ATreeItem.Add;
        TempTreeItem.LinkedItem := ATreeGroup.Projects[I];
        if AProjectFilter <> '' then
          TempTreeItem.Text := EncodeText(ATreeGroup.Projects[I].ProjectName, S)
        else
          TempTreeItem.Text := ATreeGroup.Projects[I].ProjectName;
        if ATreeGroup.GroupIsUnassigned or ATreeGroup.Projects[I].Unassigned then
          TempTreeItem.Text := Format('<%s>', [TempTreeItem.Text]);
      end;
  end;

begin
  SaveExpandedGroups(FRootTreeItem);
  FRootTreeItem.Clear;
  AddItems(FRootTreeItem, FProjectTreeContainer.RootTreeItem);
end;

procedure TVSTContainer.RestoreStateInfo(AVirtualTree: TBaseVirtualTree);
var
  Node, TopGroupNode, TopProjectNode, SelectedGroupNode, SelectedProjectNode: PVirtualNode;
  Data, ParentData: ^TVSTTreeItem;
  obj: TObject;
begin
  AVirtualTree.BeginUpdate;
  try
    TopGroupNode := nil;
    TopProjectNode := nil;
    SelectedGroupNode := nil;
    SelectedProjectNode := nil;
    Node := AVirtualTree.RootNode^.FirstChild;
    while Assigned(Node) do
    begin
      Data := AVirtualTree.GetNodeData(Node);
      if Assigned(Data^) then
      begin
        obj := Data^.LinkedItem;
        if (FTopGroupID <> -1) and (obj is TProjectTreeGroup) and
          (TProjectTreeGroup(obj).GroupID = FTopGroupID) then
          TopGroupNode := Node;
        if (FTopGroupID <> -1) and (FTopProjectID <> -1) and (obj is TProjectTreeProject) and FTopItemIsProject and
          (TProjectTreeProject(obj).ProjectData.ProjectID = FTopProjectID) and
          Assigned(Node^.Parent) then
        begin
          ParentData := AVirtualTree.GetNodeData(Node^.Parent);
          if Assigned(ParentData^) and (ParentData^.LinkedItem is TProjectTreeGroup) and
            (TProjectTreeGroup(ParentData^.LinkedItem).GroupID = FTopGroupID) then
            TopProjectNode := Node;
        end;
        if (FSelectedGroupID <> -1) and (obj is TProjectTreeGroup) and
          (TProjectTreeGroup(obj).GroupID = FSelectedGroupID) then
          SelectedGroupNode := Node;
        if (FSelectedGroupID <> -1) and (FSelectedProjectID <> -1) and (obj is TProjectTreeProject) and FSelectedItemIsProject and
          (TProjectTreeProject(obj).ProjectData.ProjectID = FSelectedProjectID) and
          Assigned(Node^.Parent) then
        begin
          ParentData := AVirtualTree.GetNodeData(Node^.Parent);
          if Assigned(ParentData^) and (ParentData^.LinkedItem is TProjectTreeGroup) and
            (TProjectTreeGroup(ParentData^.LinkedItem).GroupID = FSelectedGroupID) then
            SelectedProjectNode := Node;
        end;
      end;
      Node := AVirtualTree.GetNext(Node);
    end;
    if Assigned(TopProjectNode) then
      AVirtualTree.TopNode := TopProjectNode
    else
    if Assigned(TopGroupNode) then
      AVirtualTree.TopNode := TopGroupNode;
    if Assigned(SelectedProjectNode) then
    begin
      AVirtualTree.FocusedNode := SelectedProjectNode;
      AVirtualTree.Selected[SelectedProjectNode] := True;
    end
    else
    if Assigned(SelectedGroupNode) then
    begin
      AVirtualTree.FocusedNode := SelectedGroupNode;
      AVirtualTree.Selected[SelectedGroupNode] := True;
    end;
  finally
    AVirtualTree.EndUpdate;
  end;
end;

procedure TVSTContainer.SaveStateInfo(AVirtualTree: TBaseVirtualTree);
var
  Data: ^TVSTTreeItem;
  obj: TObject;
begin
  inherited;
  FTopGroupID := -1;
  FTopProjectID := -1;
  FTopItemIsProject := False;
  if Assigned(AVirtualTree.TopNode) then
  begin
    Data := AVirtualTree.GetNodeData(AVirtualTree.TopNode);
    obj := Data^.LinkedItem;
    if obj is TProjectTreeGroup then
    begin
      FTopGroupID := TProjectTreeGroup(obj).GroupID;
      FTopItemIsProject := False;
    end
    else
    if obj is TProjectTreeProject then
    begin
      FTopProjectID := TProjectTreeProject(obj).ProjectData.ProjectID;
      if Assigned(TProjectTreeProject(obj).Parent) and (TProjectTreeProject(obj).Parent is TProjectTreeGroup) then
        FTopGroupID := TProjectTreeGroup(TProjectTreeProject(obj).Parent).GroupID;
      FTopItemIsProject := True;
    end;
  end;
  FSelectedGroupID := -1;
  FSelectedProjectID := -1;
  FSelectedItemIsProject := False;
  if Assigned(AVirtualTree.FocusedNode) then
  begin
    Data := AVirtualTree.GetNodeData(AVirtualTree.FocusedNode);
    obj := Data^.LinkedItem;
    if obj is TProjectTreeGroup then
    begin
      FSelectedGroupID := TProjectTreeGroup(obj).GroupID;
      FSelectedItemIsProject := False;
    end
    else
    if obj is TProjectTreeProject then
    begin
      FSelectedProjectID := TProjectTreeProject(obj).ProjectData.ProjectID;
      if Assigned(TProjectTreeProject(obj).Parent) and (TProjectTreeProject(obj).Parent is TProjectTreeGroup) then
        FSelectedGroupID := TProjectTreeGroup(TProjectTreeProject(obj).Parent).GroupID;
      FSelectedItemIsProject := True;
    end;
  end;
end;

procedure TVSTContainer.SetProjectTreeContainer(AValue: TProjectTreeContainer);

  procedure SaveExpandedGroups(ATreeItem: TVSTTreeItem);
  var
    I, Idx, GroupID: Integer;
  begin
    for I := 0 to Pred(ATreeItem.Count) do
      if ATreeItem[I].LinkedItem is TProjectTreeGroup then
      begin
        GroupID := TProjectTreeGroup(ATreeItem[I].LinkedItem).GroupID;
        if ATreeItem[I].Expanded then
          FOpenGroups.Add(GroupID)
        else
        begin
          Idx := FOpenGroups.IndexOf(GroupID);
          if Idx <> -1 then
            FOpenGroups.Delete(Idx);
        end;
        SaveExpandedGroups(ATreeItem[I]);
      end;
  end;

  procedure AddItems(ATreeItem: TVSTTreeItem; ATreeGroup: TProjectTreeGroup);
  var
    I: Integer;
    TempTreeItem: TVSTTreeItem;
  begin
    for I := 0 to Pred(ATreeGroup.GroupCount) do
    begin
      TempTreeItem := ATreeItem.Add;
      TempTreeItem.LinkedItem := ATreeGroup.GroupItems[I];
      TempTreeItem.Text := ATreeGroup.GroupItems[I].GroupName;
      TempTreeItem.Expanded := FOpenGroups.IndexOf(ATreeGroup.GroupItems[I].GroupID) <> -1;
      AddItems(TempTreeItem, ATreeGroup.GroupItems[I]);
    end;
    for I := 0 to Pred(ATreeGroup.ProjectCount) do
    begin
      TempTreeItem := ATreeItem.Add;
      TempTreeItem.LinkedItem := ATreeGroup.Projects[I];
      TempTreeItem.Text := ATreeGroup.Projects[I].ProjectName;
    end;
  end;

begin
  SaveExpandedGroups(FRootTreeItem);
  FRootTreeItem.Clear;
  FProjectTreeContainer.Assign(AValue);
  AddItems(FRootTreeItem, FProjectTreeContainer.RootTreeItem);
end;

constructor TFastProjectDataList.Create;
begin
  inherited Create;
end;

destructor TFastProjectDataList.Destroy;
begin
  inherited Destroy;
end;

procedure TFastProjectDataList.Assign(AList: TFastProjectDataList);
var
  I: Integer;
  ProjectData: TProjectTreeProjectData;
  Added: Boolean;
begin
  Clear;
  for I := 0 to Pred(AList.Count) do
  begin
    Added := False;
    ProjectData := TProjectTreeProjectData.Create(AList[I].ProjectID, AList[I].ProjectName, AList[I].Deleted);
    try
      Added := Add(ProjectData);
      if Added then
        ProjectData.BugIndex := AList[I].BugIndex;
    finally
      if not Added then
        ProjectData.Free;
    end;
  end;
end;

function TFastProjectDataList.CompareItems(AItem1, AItem2: Pointer): Integer;
begin
  Result := TProjectTreeProjectData(AItem1).ProjectID - TProjectTreeProjectData(AItem2).ProjectID;
end;

procedure TFastProjectDataList.FillFromProjects(AProjects: TProjects);
var
  I: Integer;
  ProjectData: TProjectTreeProjectData;
  Added: Boolean;
begin
  Clear;
  for I := 0 to Pred(AProjects.ItemCount) do
  begin
    Added := False;
    ProjectData := TProjectTreeProjectData.Create(AProjects[I].ID, AProjects[I].Name, AProjects[I].Deleted);
    try
      Added := Add(ProjectData);
    finally
      if not Added then
        ProjectData.Free;
    end;
  end;
end;

function TFastProjectDataList.Find(AProjectID: Integer): TProjectTreeProjectData;
var
  ProjectData: TProjectTreeProjectData;
  Idx: Integer;
begin
  ProjectData := TProjectTreeProjectData.Create(AProjectID, '', False);
  try
    Idx := IndexOf(ProjectData);
  finally
    ProjectData.Free;
  end;
  Result := nil;
  if Idx <> -1 then
    Result := Items[Idx];
end;

function TFastProjectDataList.GetItem(AIndex: Integer): TProjectTreeProjectData;
begin
  Result := FList[AIndex];
end;

constructor TProjectTreeGroupData.Create(AGroupID: Integer);
begin
  inherited Create;
  FGroupID := AGroupID;
  FData := nil;
end;

constructor TFastGroupDataList.Create;
begin
  inherited Create;
end;

destructor TFastGroupDataList.Destroy;
begin
  inherited Destroy;
end;

function TFastGroupDataList.CompareItems(AItem1, AItem2: Pointer): Integer;
begin
  Result := TProjectTreeGroupData(AItem1).GroupID - TProjectTreeGroupData(AItem2).GroupID;
end;

function TFastGroupDataList.Find(AGroupID: Integer): TProjectTreeGroupData;
var
  GroupData: TProjectTreeGroupData;
  Idx: Integer;
begin
  GroupData := TProjectTreeGroupData.Create(AGroupID);
  try
    Idx := IndexOf(GroupData);
  finally
    GroupData.Free;
  end;
  Result := nil;
  if Idx <> -1 then
    Result := Items[Idx];
end;

function TFastGroupDataList.GetItem(AIndex: Integer): TProjectTreeGroupData;
begin
  Result := FList[AIndex];
end;

function SortGroupList(AItem1, AItem2: Pointer): Integer;
begin
  Result := PGetProjectGroupInformationOutputItem(AItem1)^.GroupLevel - PGetProjectGroupInformationOutputItem(AItem2)^.GroupLevel;
  if Result = 0 then
    Result := CompareStr(PGetProjectGroupInformationOutputItem(AItem1)^.GroupName, PGetProjectGroupInformationOutputItem(AItem2)^.GroupName);
end;

function SortGroupListByNameDesc(AItem1, AItem2: Pointer): Integer;
begin
  Result := - CompareStr(PGetProjectGroupInformationOutputItem(AItem1)^.GroupName, PGetProjectGroupInformationOutputItem(AItem2)^.GroupName);
end;

procedure ProjectTreeViewItemsToTree(ATreeView: TTreeView; AParentNode: TTreeNode; AItem: TProjectTreeGroup; ABugIndexImageOffset: Integer);
var
  I, BugIndex: Integer;
  TreeNode: TTreeNode;
  S: string;
  ProjectProjectTreeItem: TProjectTreeProject;
  ProjectData: TProjectTreeProjectData;
begin
  for I := 0 to Pred(AItem.GroupCount) do
  begin
    TreeNode := ATreeView.Items.AddChild(AParentNode, AItem[I].GroupName);
    TreeNode.ImageIndex := 0;
    TreeNode.SelectedIndex := 1;
    TreeNode.Data := AItem[I];
    ProjectTreeViewItemsToTree(ATreeView, TreeNode, AItem[I], ABugIndexImageOffset);
  end;
  for I := 0 to Pred(AItem.ProjectCount) do
    if Assigned(AItem.Projects[I].ProjectData) then
    begin
      ProjectProjectTreeItem := AItem.Projects[I];
      ProjectData := ProjectProjectTreeItem.ProjectData;
      S := ProjectData.ProjectName;
      if AItem.GroupIsUnassigned or ProjectProjectTreeItem.Unassigned then
      //if AItem.GroupID = -99 then
        S := Format('<%s>', [S]);
      TreeNode := ATreeView.Items.AddChild(AParentNode, S);
      TreeNode.ImageIndex := 2;
      TreeNode.SelectedIndex := 2;
      TreeNode.Data := ProjectProjectTreeItem;
      BugIndex := ProjectData.BugIndex;
      if BugIndex >= 0 then
        TreeNode.StateIndex := BugIndex + ABugIndexImageOffset
      else
        TreeNode.StateIndex := -1;
    end;
end;

constructor TProjectTreeContainer.Create;
begin
  inherited Create;
  FAlwaysShowUnassignedProjects := True;
  FBugIndexImageOffset := 0;
  FProjectDataList := TFastProjectDataList.Create;
  FRootTreeItem := TProjectTreeGroup.Create(nil, -1, '', '');
  FOpenGroups := TList.Create;
  FTopGroupID := -1;
  FTopProjectID := -1;
  FTopItemIsProject := False;
  FSelectedGroupID := -1;
  FSelectedProjectID := -1;
  FSelectedItemIsProject := False;
end;

destructor TProjectTreeContainer.Destroy;
begin
  FOpenGroups.Free;
  FRootTreeItem.Free;
  FProjectDataList.Free;
  inherited Destroy;
end;

procedure TProjectTreeContainer.Apply(ATreeView: TTreeView);
begin
  ATreeView.Items.BeginUpdate;
  try
    ATreeView.Items.Clear;
    ProjectTreeViewItemsToTree(ATreeView, nil, FRootTreeItem, FBugIndexImageOffset);
  finally
    ATreeView.Items.EndUpdate;
  end;
end;

procedure TProjectTreeContainer.ApplyWithState(ATreeView: TTreeView);
begin
  ATreeView.Items.BeginUpdate;
  try
    Apply(ATreeView);
    RestoreTreeViewState(ATreeView);
  finally
    ATreeView.Items.EndUpdate;
  end;
end;

procedure TProjectTreeContainer.AssignTo(Dest: TPersistent);

  procedure ReplaceProjects(AGroupTreeItem: TProjectTreeGroup; AProjectDataList: TFastProjectDataList);
  var
    I: Integer;
    ProjectData: TProjectTreeProjectData;
  begin
    for I := 0 to Pred(AGroupTreeItem.GroupCount) do
      ReplaceProjects(AGroupTreeItem.GroupItems[I], AProjectDataList);
    for I := 0 to Pred(AGroupTreeItem.ProjectCount) do
    begin
      ProjectData := AProjectDataList.Find(AGroupTreeItem.Projects[I].ProjectData.ProjectID);
      AGroupTreeItem.Projects[I].SetProjectData(ProjectData);
    end;
  end;

begin
  if Dest is TProjectTreeContainer then
  begin
    TProjectTreeContainer(Dest).FProjectDataList.Assign(FProjectDataList);
    TProjectTreeContainer(Dest).RootTreeItem.Assign(RootTreeItem);
    ReplaceProjects(TProjectTreeContainer(Dest).RootTreeItem, TProjectTreeContainer(Dest).FProjectDataList);
  end
  else
    inherited AssignTo(Dest);
end;

procedure TProjectTreeContainer.Clear;
begin
  FRootTreeItem.Clear;
  FProjectDataList.Clear;
end;

function TProjectTreeContainer.FindGroupItem(AProjectTreeGroup: TProjectTreeGroup; AGroupID: Integer): TProjectTreeGroup;
var
  I: Integer;
begin
  Result := nil;
  if AProjectTreeGroup.GroupID = AGroupID then
    Result := AProjectTreeGroup
  else
    for I := 0 to Pred(AProjectTreeGroup.GroupCount) do
    begin
      Result := FindGroupItem(AProjectTreeGroup.GroupItems[I], AGroupID);
      if Assigned(Result) then
        Break;
    end;
end;

procedure TProjectTreeContainer.IncrementalAddProject(AGroupID, AProjectID: Integer; ATreeView: TTreeView);
var
  GroupTreeItem: TProjectTreeGroup;
  ProjectData: TProjectTreeProjectData;
begin
  GroupTreeItem := FindGroupItem(FRootTreeItem, AGroupID);
  ProjectData := FProjectDataList.Find(AProjectID);
  if Assigned(GroupTreeItem) and Assigned(ProjectData) then
  begin
    SaveTreeViewState(ATreeView);
    GroupTreeItem.AddProject(ProjectData);
    GroupTreeItem.SortProjectsByName;
    UpdateUnassignedProjects;
    Apply(ATreeView);
    RestoreTreeViewState(ATreeView);
  end;
end;

procedure TProjectTreeContainer.IncrementalInsertGroup(AGroupID, AParentGroupID: Integer; AGroupName, AGroupDescription: string; ATreeView: TTreeView);
var
  ParentTreeItem: TProjectTreeGroup;
begin
  if AParentGroupID = 0 then
    ParentTreeItem := FRootTreeItem
  else
    ParentTreeItem := FindGroupItem(FRootTreeItem, AParentGroupID);
  if Assigned(ParentTreeItem) then
  begin
    SaveTreeViewState(ATreeView);
    ParentTreeItem.AddGroup(AGroupID, AGroupName, AGroupDescription);
    ParentTreeItem.SortGroupsByName;
    Apply(ATreeView);
    RestoreTreeViewState(ATreeView);
  end;
end;

procedure TProjectTreeContainer.IncrementalRenameGroup(AGroupID: Integer; AGroupName, AGroupDescription: string; ATreeView: TTreeView);
var
  GroupTreeItem: TProjectTreeGroup;
begin
  GroupTreeItem := FindGroupItem(FRootTreeItem, AGroupID);
  if Assigned(GroupTreeItem) then
  begin
    SaveTreeViewState(ATreeView);
    GroupTreeItem.GroupName := AGroupName;
    GroupTreeItem.GroupDescription := AGroupDescription;
    if GroupTreeItem.Parent is TProjectTreeGroup then
      TProjectTreeGroup(GroupTreeItem.Parent).SortGroupsByName;
    Apply(ATreeView);
    RestoreTreeViewState(ATreeView);
  end;
end;

procedure TProjectTreeContainer.IncrementalRemoveGroup(AGroupID: Integer; ATreeView: TTreeView);
var
  GroupTreeItem: TProjectTreeGroup;
begin
  GroupTreeItem := FindGroupItem(FRootTreeItem, AGroupID);
  if Assigned(GroupTreeItem) and (GroupTreeItem.Parent is TProjectTreeGroup) then
  begin
    SaveTreeViewState(ATreeView);
    TProjectTreeGroup(GroupTreeItem.Parent).RemoveGroup(AGroupID);
    UpdateUnassignedProjects;
    Apply(ATreeView);
    RestoreTreeViewState(ATreeView);
  end;
end;

procedure TProjectTreeContainer.IncrementalRemoveProject(AGroupID, AProjectID: Integer; ATreeView: TTreeView);
var
  GroupTreeItem: TProjectTreeGroup;
begin
  GroupTreeItem := FindGroupItem(FRootTreeItem, AGroupID);
  if Assigned(GroupTreeItem) then
  begin
    SaveTreeViewState(ATreeView);
    GroupTreeItem.RemoveProject(AProjectID);
    UpdateUnassignedProjects;
    Apply(ATreeView);
    RestoreTreeViewState(ATreeView);
  end;
end;

procedure TProjectTreeContainer.IncrementalUpdateBugIndex(AProjectID, ABugIndex: Integer; ATreeView: TTreeView);
var
  ProjectData: TProjectTreeProjectData;
begin
  ProjectData := FProjectDataList.Find(AProjectID);
  if Assigned(ProjectData) then
  begin
    SaveTreeViewState(ATreeView);
    ProjectData.BugIndex := ABugIndex;
    Apply(ATreeView);
    RestoreTreeViewState(ATreeView);
  end;
end;

procedure TProjectTreeContainer.Read(AConnection: TJVCSConnection; AHideProjectsWithoutRights: Boolean);
var
  GetProjectGroupInformation: TJVCSGetProjectGroupInformation;
  Item: PGetProjectGroupInformationOutputItem;
  GroupList, ProjectList: TList;
  GroupDataList: TFastGroupDataList;
  GroupData, ParentGroupData: TProjectTreeGroupData;
  ProjectData: TProjectTreeProjectData;
  Added: Boolean;
  I, Idx: Integer;
  ParentTreeItem, GroupTreeItem: TProjectTreeGroup;
  ProjectTreeItem: TProjectTreeProject;
  UnassignedProjects: TSortedIntegerList;
  Whoami: TJVCSWhoami;
  Projects: TProjects;
  MostSevereProjectBugs: TMostSevereBugsDataList;
  DefaultAccessLevel: Integer;
  AddedItems: Boolean;
  NotFoundParentIDList: TSortedIntegerList;
begin
  Clear;
  GroupList := TList.Create;
  ProjectList := TList.Create;
  GroupDataList := TFastGroupDataList.Create;
  UnassignedProjects := TSortedIntegerList.Create;
  try
    GetProjectGroupInformation := TJVCSGetProjectGroupInformation.Create(nil);
    try
      try
        AConnection.SendRequest(GetProjectGroupInformation);
      except
        on E: Exception do
        begin
          if not ((E is EJVCSClientRequestError) and (EJVCSClientRequestError(E).StatusCode = 403)) then
            raise;
        end;
      end;
      for I := 0 to Pred(GetProjectGroupInformation.OutputItemCount) do
      begin
        New(Item);
        Item^ := GetProjectGroupInformation.OutputItems[I];
        if Item^.RecordType = 'g' then
          GroupList.Add(Item)
        else
        if Item^.RecordType = 'p' then
          ProjectList.Add(Item)
        else
          Dispose(Item);
      end;
    finally
      GetProjectGroupInformation.Free;
    end;
    Whoami := TJVCSWhoami.Create(nil);
    try
      AConnection.SendRequest(Whoami);
      DefaultAccessLevel := Whoami.AccessLevel;
    finally
      Whoami.Free;
    end;
    if (not AHideProjectsWithoutRights) and (DefaultAccessLevel = 0) then
      DefaultAccessLevel := 1;
    Projects := TProjects.Create;
    try
      Projects.Load(DefaultAccessLevel);
      FProjectDataList.FillFromProjects(Projects);
    finally
      Projects.Free;
    end;
    MostSevereProjectBugs := TMostSevereBugsDataList.Create;
    try
      MostSevereProjectBugs.LoadMostSevereProjectBugs;
      for I := 0 to Pred(FProjectDataList.Count) do
        FProjectDataList[I].BugIndex := MostSevereProjectBugs.GetItemSeverity(FProjectDataList[I].ProjectID);
    finally
      MostSevereProjectBugs.Free;
    end;
    GroupList.Sort(SortGroupListByNameDesc);
    AddedItems := True;
    NotFoundParentIDList := TSortedIntegerList.Create;
    try
      while AddedItems and (GroupList.Count > 0) do
      begin
        AddedItems := False;
        NotFoundParentIDList.Clear;
        for I := Pred(GroupList.Count) downto 0 do
        begin
          Item := GroupList[I];
          if NotFoundParentIDList.IndexOf(Item^.ParentID) = -1 then
          begin
            if Item^.ParentID = 0 then
              ParentTreeItem := FRootTreeItem
            else
            begin
              ParentTreeItem := nil;
              ParentGroupData := GroupDataList.Find(Item^.ParentID);
              if Assigned(ParentGroupData) and Assigned(ParentGroupData.Data) then
                ParentTreeItem := ParentGroupData.Data;
            end;
            if Assigned(ParentTreeItem) then
            begin
              AddedItems := True;
              Added := False;
              GroupData := TProjectTreeGroupData.Create(Item^.GroupID);
              try
                Added := GroupDataList.Add(GroupData);
              finally
                if not Added then
                  GroupData.Free;
              end;
              if Added then
              begin
                GroupTreeItem := ParentTreeItem.AddGroup(Item^.GroupID, Item^.GroupName, Item^.GroupDescription);
                GroupData.Data := GroupTreeItem;
                Dispose(PGetProjectGroupInformationOutputItem(GroupList[I]));
                GroupList.Delete(I);
              end;
            end
            else
              NotFoundParentIDList.Add(Item^.ParentID);
          end;
        end;
      end;
    finally
      NotFoundParentIDList.Free;
    end;
    for I := 0 to Pred(GroupList.Count) do
      Dispose(PGetProjectGroupInformationOutputItem(GroupList[I]));
    for I := 0 to Pred(FProjectDataList.Count) do
      if not FProjectDataList[I].Deleted then
        UnassignedProjects.Add(FProjectDataList[I].ProjectID);
    for I := 0 to Pred(ProjectList.Count) do
    begin
      Item := ProjectList[I];
      ParentGroupData := GroupDataList.Find(Item^.GroupID);
      if Assigned(ParentGroupData) and Assigned(ParentGroupData.Data) then
      begin
        ProjectData := FProjectDataList.Find(Item^.ParentID);
        if Assigned(ProjectData) and not ProjectData.Deleted then
        begin
          Idx := UnassignedProjects.IndexOf(ProjectData.ProjectID);
          if Idx <> -1 then
            UnassignedProjects.Delete(Idx);
          ParentTreeItem := ParentGroupData.Data;
          ParentTreeItem.AddProject(ProjectData);
        end;
      end;
    end;
    if FAlwaysShowUnassignedProjects or (UnassignedProjects.Count > 0) then
    begin
      ParentTreeItem := FRootTreeItem.AddGroup(-99, JVCSRES_60Unassigned_Projects62,
        JVCSRES_Auto_generated_group46_This_group_lists_all_projects_not_assigned_to_any_user_defined_group46_Not_editable33);
      ParentTreeItem.GroupIsUnassigned := True;
      for I := 0 to Pred(UnassignedProjects.Count) do
      begin
        ProjectData := FProjectDataList.Find(UnassignedProjects[I]);
        if Assigned(ProjectData) then
        begin
          ProjectTreeItem := ParentTreeItem.AddProject(ProjectData);
          ProjectTreeItem.Unassigned := True;
        end;
      end;
    end;
    for I := 0 to Pred(ProjectList.Count) do
      Dispose(PGetProjectGroupInformationOutputItem(ProjectList[I]));
  finally
    UnassignedProjects.Free;
    GroupDataList.Free;
    ProjectList.Free;
    GroupList.Free;
  end;
end;

procedure TProjectTreeContainer.RestoreTreeViewState(ATreeView: TTreeView);
var
  I, Idx: Integer;
  TopGroupNode, TopProjectNode, SelectedGroupNode, SelectedProjectNode: TTreeNode;
  obj: TObject;
begin
  ATreeView.Items.BeginUpdate;
  try
    TopGroupNode := nil;
    TopProjectNode := nil;
    SelectedGroupNode := nil;
    SelectedProjectNode := nil;
    for I := 0 to Pred(ATreeView.Items.Count) do
    begin
      if Assigned(ATreeView.Items[I].Data) then
      begin
        obj := TObject(ATreeView.Items[I].Data);
        if obj is TProjectTreeGroup then
        begin
          Idx := FOpenGroups.IndexOf(Pointer(TProjectTreeGroup(obj).GroupID));
          if Idx <> -1 then
          begin
            ATreeView.Items[I].Expanded := True;
            FOpenGroups.Delete(Idx);
          end;
        end;
        if (FTopGroupID <> -1) and (obj is TProjectTreeGroup) and
          (TProjectTreeGroup(obj).GroupID = FTopGroupID) then
          TopGroupNode := ATreeView.Items[I];
        if (FTopGroupID <> -1) and (FTopProjectID <> -1) and (obj is TProjectTreeProject) and FTopItemIsProject and
          (TProjectTreeProject(obj).ProjectData.ProjectID = FTopProjectID) and
          Assigned(ATreeView.Items[I].Parent) and Assigned(ATreeView.Items[I].Parent.Data) and
          (TObject(ATreeView.Items[I].Parent.Data) is TProjectTreeGroup) and
          (TProjectTreeGroup(ATreeView.Items[I].Parent.Data).GroupID = FTopGroupID) then
          TopProjectNode := ATreeView.Items[I];
        if (FSelectedGroupID <> -1) and (obj is TProjectTreeGroup) and
          (TProjectTreeGroup(obj).GroupID = FSelectedGroupID) then
          SelectedGroupNode := ATreeView.Items[I];
        if (FSelectedGroupID <> -1) and (FSelectedProjectID <> -1) and (obj is TProjectTreeProject) and FSelectedItemIsProject and
          (TProjectTreeProject(obj).ProjectData.ProjectID = FSelectedProjectID) and
          Assigned(ATreeView.Items[I].Parent) and Assigned(ATreeView.Items[I].Parent.Data) and
          (TObject(ATreeView.Items[I].Parent.Data) is TProjectTreeGroup) and
          (TProjectTreeGroup(ATreeView.Items[I].Parent.Data).GroupID = FSelectedGroupID) then
          SelectedProjectNode := ATreeView.Items[I];
      end;
    end;
    if Assigned(TopProjectNode) then
      ATreeView.TopItem := TopProjectNode
    else
    if Assigned(TopGroupNode) then
      ATreeView.TopItem := TopGroupNode;
    if Assigned(SelectedProjectNode) then
      ATreeView.Selected := SelectedProjectNode
    else
    if Assigned(SelectedGroupNode) then
      ATreeView.Selected := SelectedGroupNode;
    FOpenGroups.Clear;
    FTopGroupID := -1;
    FTopProjectID := -1;    
    FTopItemIsProject := False;
  finally
    ATreeView.Items.EndUpdate;
  end;
end;

procedure TProjectTreeContainer.SaveTreeViewState(ATreeView: TTreeView);
var
  I: Integer;
  obj: TObject;
begin
  for I := 0 to Pred(ATreeView.Items.Count) do
    if (ATreeView.Items[I].Expanded) and Assigned(ATreeView.Items[I].Data) and
      (TObject(ATreeView.Items[I].Data) is TProjectTreeGroup) then
      FOpenGroups.Add(Pointer(TProjectTreeGroup(ATreeView.Items[I].Data).GroupID));
  if ATreeView.Items.Count > 0 then
  begin
    FTopGroupID := -1;
    FTopProjectID := -1;
    FTopItemIsProject := False;
    if Assigned(ATreeView.TopItem) and Assigned(ATreeView.TopItem.Data) then
    begin
      obj := TObject(ATreeView.TopItem.Data);
      if obj is TProjectTreeGroup then
      begin
        FTopGroupID := TProjectTreeGroup(obj).GroupID;
        FTopItemIsProject := False;
      end
      else
      if obj is TProjectTreeProject then
      begin
        FTopProjectID := TProjectTreeProject(obj).ProjectData.ProjectID;
        if Assigned(TProjectTreeProject(obj).Parent) and (TProjectTreeProject(obj).Parent is TProjectTreeGroup) then
          FTopGroupID := TProjectTreeGroup(TProjectTreeProject(obj).Parent).GroupID;
        FTopItemIsProject := True;
      end;
    end;
    FSelectedGroupID := -1;
    FSelectedProjectID := -1;    
    FSelectedItemIsProject := False;
    if Assigned(ATreeView.Selected) and Assigned(ATreeView.Selected.Data) then
    begin
      obj := TObject(ATreeView.Selected.Data);
      if obj is TProjectTreeGroup then
      begin
        FSelectedGroupID := TProjectTreeGroup(obj).GroupID;
        FSelectedItemIsProject := False;
      end
      else
      if obj is TProjectTreeProject then
      begin
        FSelectedProjectID := TProjectTreeProject(obj).ProjectData.ProjectID;
        if Assigned(TProjectTreeProject(obj).Parent) and (TProjectTreeProject(obj).Parent is TProjectTreeGroup) then
          FSelectedGroupID := TProjectTreeGroup(TProjectTreeProject(obj).Parent).GroupID;
        FSelectedItemIsProject := True;
      end;
    end;
  end;
end;

procedure TProjectTreeContainer.UpdateUnassignedProjects;

  procedure EnumAssignedProjects(AProjectTreeGroup: TProjectTreeGroup; AProjectList: TSortedIntegerList);
  var
    I: Integer;
  begin
    if not AProjectTreeGroup.GroupIsUnassigned then
    begin
      for I := 0 to Pred(AProjectTreeGroup.ProjectCount) do
        if Assigned(AProjectTreeGroup.Projects[I].ProjectData) then
          AProjectList.Add(AProjectTreeGroup.Projects[I].ProjectData.ProjectID);
      for I := 0 to Pred(AProjectTreeGroup.GroupCount) do
        if not AProjectTreeGroup.GroupItems[I].GroupIsUnassigned then
          EnumAssignedProjects(AProjectTreeGroup.GroupItems[I], AProjectList);
    end;
  end;

var
  I: Integer;
  AssignedProjects, UnassignedProjects: TSortedIntegerList;
  ParentTreeItem: TProjectTreeGroup;
  ProjectData: TProjectTreeProjectData;
  ProjectTreeItem: TProjectTreeProject;
begin
  AssignedProjects := TSortedIntegerList.Create;
  UnassignedProjects := TSortedIntegerList.Create;
  try
    EnumAssignedProjects(FRootTreeItem, AssignedProjects);
    for I := 0 to Pred(FProjectDataList.Count) do
      if (not FProjectDataList[I].Deleted) and (AssignedProjects.IndexOf(FProjectDataList[I].ProjectID) = -1) then
        UnassignedProjects.Add(FProjectDataList[I].ProjectID);
    FRootTreeItem.RemoveGroup(-99);
    if FAlwaysShowUnassignedProjects or (UnassignedProjects.Count > 0) then
    begin
      ParentTreeItem := FRootTreeItem.AddGroup(-99, JVCSRES_60Unassigned_Projects62,
        JVCSRES_Auto_generated_group46_This_group_lists_all_projects_not_assigned_to_any_user_defined_group46_Not_editable33);
      ParentTreeItem.GroupIsUnassigned := True;
      for I := 0 to Pred(UnassignedProjects.Count) do
      begin
        ProjectData := FProjectDataList.Find(UnassignedProjects[I]);
        if Assigned(ProjectData) then
        begin
          ProjectTreeItem := ParentTreeItem.AddProject(ProjectData);
          ProjectTreeItem.Unassigned := True;
        end;
      end;
    end;
  finally
    AssignedProjects.Free;
    UnassignedProjects.Free;
  end;
end;

end.
