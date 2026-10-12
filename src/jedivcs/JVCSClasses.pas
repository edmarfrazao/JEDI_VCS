(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSClasses.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
ToDo
- find out until which amount of items it does make sense to add the items sorted
  instead of performing a full quick sort after all items are added
  (of course this does only make sense for Add and not for AddOrReplace)
-----------------------------------------------------------------------------

Unit history:

2003/09/08  USchuster - new unit
2003/12/30  USchuster - added classes for module state check
2004/01/25  USchuster - added new class TMostSevereBugsList
2004/12/29  USchuster - added new class TProjectRightsList (for mantis #2254)
2005/06/12  USchuster - added TCustomFastSortedObjectList
2005/06/27  USchuster - added TIDToNameList
                      - made some changes in TFastSortedList to support GetRange functions
                      - added TModuleRevisionLabelList
2008/06/08  USchuster - fixed memory leaks (Mantis #3082)
                      - simplified memory leak fix
2008/11/01  USchuster - added TProjectUserRightsList for Mantis #4561

2009/12/28  THuber    - IFNDEF JVCSCONSOLECLIENT added for use of this unit in
                        jvcs.dpr (SortedIntegerList)
-----------------------------------------------------------------------------*)


unit JVCSClasses;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
    SysUtils
  , Classes
  {$IFNDEF JVCSCONSOLECLIENT}
  , ConfigStorage
  {$ENDIF ~JVCSCONSOLECLIENT}
  , JclStrings;

type
  TFastSortedListCompare = function(AItem1, AItem2: Pointer): Integer of object;

  TFastSortedList = class(TObject)
  private
    function GetCount: Integer;
    function GetInsertPos(ASearchValue: Pointer): Integer;
  protected
    FList: TList;
    function CompareItems(AItem1, AItem2: Pointer): Integer; virtual;
    procedure DisposeItem(AItem: Pointer); virtual;
    function InternalGetRange(ASearchValue: Pointer; ACompareFunction: TFastSortedListCompare;
      var ARangeStart, ARangeEnd: Integer): Boolean;
    function InternalIndexOf(ASearchValue: Pointer; ACompareFunction: TFastSortedListCompare): Integer;
  public
    constructor Create;
    destructor Destroy; override;

    function Add(AItem: Pointer): Boolean;
    procedure Clear;
    procedure Delete(AIndex: Integer);
    function IndexOf(ASearchValue: Pointer): Integer;

    property Count: Integer read GetCount;
  end;

  TCustomFastSortedObjectList = class(TFastSortedList)
  protected
    procedure DisposeItem(AItem: Pointer); override;
  end;

{$IFNDEF JVCSCONSOLECLIENT}
  PIgnoredModuleRec = ^TIgnoredModuleRec;
  TIgnoredModuleRec = record
    Server: string;
    ModuleID,
    RevisionID: Integer;
    Hidden: Boolean;
    Path,
    ModuleName: string;
  end;

  TIgnoredModuleList = class(TFastSortedList)
  private
    function GetItem(AIndex: Integer): TIgnoredModuleRec;
  protected
    function CompareItems(AItem1, AItem2: Pointer): Integer; override;
    procedure DisposeItem(AItem: Pointer); override;
  public
    procedure Add(AServer: string; AModuleID, ARevisionID: Integer;
      AHidden: Boolean; APath, AModuleName: string);
    function IndexOf(AServer: string; AModuleID: Integer): Integer;

    procedure LoadFromStorage(const AKey: string);
    procedure SaveToStorage(const AKey: string);

    property Items[AIndex: Integer]: TIgnoredModuleRec read GetItem; default;
  end;
{$ENDIF ~JVCSCONSOLECLIENT}

  TSortedIntegerList = class(TFastSortedList)
  private
    function GetItem(AIndex: Integer): Integer;
  protected
    function CompareItems(AItem1, AItem2: Pointer): Integer; override;
  public
    procedure Add(AInteger: Integer);
    function IndexOf(AInteger: Integer): Integer;

    property Items[AIndex: Integer]: Integer read GetItem; default;
  end;

  PModuleStateRec = ^TModuleStateRec;
  TModuleStateRec = record
    LastAccess: TDateTime;
    ModuleID: Integer;
    CheckedOut: Boolean;
    UserID: Integer;
  end;

  TModuleStateList = class(TFastSortedList)
  private
    function GetItem(AIndex: Integer): TModuleStateRec;
  protected
    function CompareItems(AItem1, AItem2: Pointer): Integer; override;
    procedure DisposeItem(AItem: Pointer); override;
  public
    procedure AddOrReplace(AModuleID: Integer; ACheckedOut: Boolean; AUserID: Integer);
    function IndexOf(AModuleID: Integer): Integer;
    procedure UpdateLastAccessIdx(AIndex: Integer);

    property Items[AIndex: Integer]: TModuleStateRec read GetItem; default;
  end;

  PModuleNameToIDRec = ^TModuleNameToIDRec;
  TModuleNameToIDRec = record
    LastAccess: TDateTime;
    ModuleName: string;
    ModuleID: Integer;
  end;

  TModuleNameToIDList = class(TFastSortedList)
  private
    function GetItem(AIndex: Integer): TModuleNameToIDRec;
  protected
    function CompareItems(AItem1, AItem2: Pointer): Integer; override;
    procedure DisposeItem(AItem: Pointer); override;
  public
    procedure AddOrReplace(AModuleName: string; AModuleID: Integer);
    function IndexOf(AModuleName: string): Integer;
    procedure UpdateLastAccessIdx(AIndex: Integer);

    property Items[AIndex: Integer]: TModuleNameToIDRec read GetItem; default;
  end;

  PMostServereBugRec = ^TMostServereBugRec;
  TMostServereBugRec = record
    ItemID: Integer;
    BugID: Integer;
    Severity: Integer;
  end;

  TMostSevereBugsList = class(TFastSortedList)
  private
    function GetItem(AIndex: Integer): TMostServereBugRec;
  protected
    function CompareItems(AItem1, AItem2: Pointer): Integer; override;
    procedure DisposeItem(AItem: Pointer); override;
  public
    procedure AddOrReplace(AItemID, ABugID, ASeverity: Integer);
    function IndexOf(AItemID: Integer): Integer;

    property Items[AIndex: Integer]: TMostServereBugRec read GetItem; default;
  end;

  PProjectRightsRec = ^TProjectRightsRec;
  TProjectRightsRec = record
    ProjectID: Integer;
    AccessLevel: Integer;
  end;

  TProjectRightsList = class(TFastSortedList)
  private
    function GetItem(AIndex: Integer): TProjectRightsRec;
  protected
    function CompareItems(AItem1, AItem2: Pointer): Integer; override;
    procedure DisposeItem(AItem: Pointer); override;
  public
    procedure AddOrReplace(AProjectID, AAccessLevel: Integer);
    function IndexOf(AProjectID: Integer): Integer;

    property Items[AIndex: Integer]: TProjectRightsRec read GetItem; default;
  end;

  PProjectUserRightsRec = ^TProjectUserRightsRec;
  TProjectUserRightsRec = record
    UserID: Integer;
    ProjectID: Integer;
    AccessLevel: Integer;
  end;

  TProjectUserRightsList = class(TFastSortedList)
  private
    FSortRequired: Boolean;
    procedure DoSort;
    function GetItem(AIndex: Integer): TProjectUserRightsRec;
  protected
    function CompareItems(AItem1, AItem2: Pointer): Integer; override;
    procedure DisposeItem(AItem: Pointer); override;
  public
    constructor Create;
    procedure Add(AUserID, AProjectID, AAccessLevel: Integer);
    function IndexOf(AUserID, AProjectID: Integer): Integer;

    property Items[AIndex: Integer]: TProjectUserRightsRec read GetItem; default;
  end;  

  PIDToNameRec = ^TIDToNameRec;
  TIDToNameRec = record
    ID: Integer;
    Name: string;
  end;

  TIDToNameList = class(TFastSortedList)
  private
    function GetItem(AIndex: Integer): TIDToNameRec;
  protected
    function CompareItems(AItem1, AItem2: Pointer): Integer; override;
    procedure DisposeItem(AItem: Pointer); override;
  public
    procedure AddOrReplace(AID: Integer; AName: string);
    function IndexOf(AID: Integer): Integer;

    property Items[AIndex: Integer]: TIDToNameRec read GetItem; default;
  end;

  PModuleRevisionLabelRec = ^TModuleRevisionLabelRec;
  TModuleRevisionLabelRec = record
    ModuleID: Integer;
    RevisionID: Integer;
    LabelID: Integer;
  end;

  TModuleRevisionLabelList = class(TFastSortedList)
  private
    function GetItem(AIndex: Integer): TModuleRevisionLabelRec;
  protected
    function CompareItems(AItem1, AItem2: Pointer): Integer; override;
    function CompareModuleRevision(AItem1, AItem2: Pointer): Integer;
    procedure DisposeItem(AItem: Pointer); override;
  public
    procedure Add(AModuleID, ARevisionID, ALabelID: Integer);
    function GetModuleRevisionLabelRange(AModuleID, ARevisionID: Integer; var ARangeStart, ARangeEnd: Integer): Boolean;
    function IndexOf(AModuleID, ARevisionID, ALabelID: Integer): Integer;

    property Items[AIndex: Integer]: TModuleRevisionLabelRec read GetItem; default;
  end;

implementation

function TFastSortedList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TFastSortedList.GetInsertPos(ASearchValue: Pointer): Integer;
var
  RangeStart, RangeEnd, MidItemIndex, CompareRes: Integer;
  found: Boolean;
begin
  Result := 0;
  if FList.Count > 0 then
  begin
    RangeStart := 0;
    RangeEnd := Pred(FList.Count);
    found := False;
    while (RangeStart <= RangeEnd) and (not found) do
    begin
      if CompareItems(FList[RangeStart], ASearchValue) > 0 then
      begin
        Result := RangeStart;
        found  := True;
      end
      else
      if (CompareItems(FList[RangeEnd], ASearchValue) < 0) then
      begin
        Result := RangeEnd + 1;
        found  := True;
      end
      else
      begin
        MidItemIndex := (RangeStart + RangeEnd) shr 1;
        CompareRes := CompareItems(FList[MidItemIndex], ASearchValue);
        if CompareRes = 0 then
        begin
          Result := -1;
          found  := True;
        end
        else
        if CompareRes > 0 then
          RangeEnd := MidItemIndex - 1
        else
          RangeStart := MidItemIndex + 1;
      end;
    end;
  end;
end;

function TFastSortedList.CompareItems(AItem1, AItem2: Pointer): Integer;
begin
  Result := 0;
end;

procedure TFastSortedList.DisposeItem(AItem: Pointer);
begin
//do nothing
end;

constructor TFastSortedList.Create;
begin
  inherited;
  FList := TList.Create;
end;

destructor TFastSortedList.Destroy;
begin
  Clear;
  FList.Free;
  inherited;
end;

function TFastSortedList.Add(AItem: Pointer): Boolean;
var
  InsertIndex: Integer;
begin
  InsertIndex := GetInsertPos(AItem);
  Result := InsertIndex <> -1;
  if Result then
    FList.Insert(InsertIndex, AItem);
end;

procedure TFastSortedList.Clear;
var
  I: Integer;
begin
  if FList.Count > 0 then
  begin
    for I := 0 to Pred(FList.Count) do
      DisposeItem(FList[I]);
    FList.Clear;
  end;
end;

procedure TFastSortedList.Delete(AIndex: Integer);
begin
  DisposeItem(FList[AIndex]);
  FList.Delete(AIndex);
end;

function TFastSortedList.IndexOf(ASearchValue: Pointer): Integer;
begin
  Result := InternalIndexOf(ASearchValue, CompareItems);
end;

function TFastSortedList.InternalGetRange(ASearchValue: Pointer; ACompareFunction: TFastSortedListCompare;
  var ARangeStart, ARangeEnd: Integer): Boolean;
var
  I, MidIdx: Integer;
begin
  Result := False;
  MidIdx := InternalIndexOf(ASearchValue, ACompareFunction);
  if MidIdx <> -1 then
  begin
    Result := True;
    I := MidIdx;
    ARangeStart := MidIdx;
    while I >= 0 do
    begin
      if ACompareFunction(FList[I], ASearchValue) = 0 then
        ARangeStart := I
      else
        Break;
      Dec(I);
    end;
    I := MidIdx;
    ARangeEnd := MidIdx;
    while I < Count do
    begin
      if ACompareFunction(FList[I], ASearchValue) = 0 then
        ARangeEnd := I
      else
        Break;
      Inc(I);
    end;
  end;
end;

function TFastSortedList.InternalIndexOf(ASearchValue: Pointer; ACompareFunction: TFastSortedListCompare): Integer;
var
  RangeStart, RangeEnd, MidItemIndex, CompareRes: Integer;
begin
  Result := -1;
  if (FList.Count > 0) and (ACompareFunction(FList[0], ASearchValue) <= 0) and
    (ACompareFunction(FList[Pred(FList.Count)], ASearchValue) >= 0)
  then
  begin
    RangeStart := 0;
    RangeEnd := FList.Count;
    while (RangeStart <= RangeEnd) and (Result = -1) do
    begin
      MidItemIndex := (RangeStart + RangeEnd) shr 1;
      CompareRes := ACompareFunction(FList[MidItemIndex], ASearchValue);
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

procedure TCustomFastSortedObjectList.DisposeItem(AItem: Pointer);
begin
  TObject(AItem).Free;
end;

{$IFNDEF JVCSCONSOLECLIENT}
function TIgnoredModuleList.GetItem(AIndex: Integer): TIgnoredModuleRec;
begin
  Result := PIgnoredModuleRec(FList[AIndex])^;
end;

function TIgnoredModuleList.CompareItems(AItem1, AItem2: Pointer): Integer;
var
  Ptr1, Ptr2: PIgnoredModuleRec;
begin
  Ptr1 := AItem1;
  Ptr2 := AItem2;
  Result := CompareStr(LowerCase(Ptr1^.Server), LowerCase(Ptr2^.Server));
  if Result = 0 then
    Result := Ptr1^.ModuleID - Ptr2^.ModuleID;
end;

procedure TIgnoredModuleList.DisposeItem(AItem: Pointer);
begin
  Dispose(PIgnoredModuleRec(AItem));
end;

procedure TIgnoredModuleList.Add(AServer: string; AModuleID, ARevisionID: Integer;
  AHidden: Boolean; APath, AModuleName: string);
var
  PPtr: PIgnoredModuleRec;
begin
  if IndexOf(AServer, AModuleID) = -1 then
  begin
    New(PPtr);
    with PPtr^ do
    begin
      Server     := AServer;
      ModuleID   := AModuleID;
      RevisionID := ARevisionID;
      Hidden     := AHidden;
      Path       := APath;
      ModuleName := AModuleName;
    end;
    inherited Add(PPtr);
  end;
end;

function TIgnoredModuleList.IndexOf(AServer: string; AModuleID: Integer): Integer;
var
  IgnoredModuleRec: TIgnoredModuleRec;
begin
  IgnoredModuleRec.ModuleID   := AModuleID;
  IgnoredModuleRec.RevisionID := 0;
  IgnoredModuleRec.Hidden     := False;
  IgnoredModuleRec.Server     := AServer;
  IgnoredModuleRec.Path       := '';
  IgnoredModuleRec.ModuleName := '';
  Result := inherited IndexOf(@IgnoredModuleRec);
end;

procedure TIgnoredModuleList.LoadFromStorage(const AKey: string);
var
  I: Integer;
  ModuleID,
  RevisionID: Integer;
  Hidden: Boolean;
  Server, Path, ModuleName: string;
  S, HiddenStr: string;
begin
  Clear;
  {$IFDEF DEBUG}
  Assert(AKey <> '', 'Parameter Key is blank');
  {$ENDIF DEBUG}
  if AKey <> '' then
  begin
    if jvcsKeyExists(AKey) then
    begin
      I := 0;
      while jvcsValueExists(AKey, Format('Module%d', [I])) do
      begin
        S := jvcsReadString(AKey, Format('Module%d', [I]), '');
        Server := StrToken(S, ';');
        ModuleID := StrToIntDef(StrToken(S, ';'), 0);
        RevisionID := StrToIntDef(StrToken(S, ';'), 0);
        HiddenStr := StrToken(S, ';');
        Hidden := (HiddenStr <> '') and (HiddenStr <> '0');
        Path := StrToken(S, ';');
        ModuleName := StrToken(S, ';');
        if (ModuleID <> 0) and (RevisionID <> 0) then
          Add(Server, ModuleID, RevisionID, Hidden, Path, ModuleName);
        Inc(I);
      end;
    end;
  end;
end;

procedure TIgnoredModuleList.SaveToStorage(const AKey: string);
var
  I: Integer;
begin
  {$IFDEF DEBUG}
  Assert(AKey <> '', 'Parameter Key is blank');
  {$ENDIF DEBUG}
  if AKey <> '' then
  begin
    jvcsDeleteKey(AKey);
    if Count > 0 then
      for I := 0 to Pred(Count) do
        with Items[I] do
          jvcsWriteString(AKey, Format('Module%d', [I]),
            Format('%s;%d;%d;%d;%s;%s', [Server, ModuleID, RevisionID,
              Integer(Hidden), Path, ModuleName]));
  end;
end;
{$ENDIF ~JVCSCONSOLECLIENT}

function TSortedIntegerList.GetItem(AIndex: Integer): Integer;
begin
  Result := Integer(FList[AIndex]);
end;

function TSortedIntegerList.CompareItems(AItem1, AItem2: Pointer): Integer;
begin
  Result := Integer(AItem1) - Integer(AItem2);
end;

procedure TSortedIntegerList.Add(AInteger: Integer);
begin
  if IndexOf(AInteger) = -1 then
    inherited Add(Pointer(AInteger));
end;

function TSortedIntegerList.IndexOf(AInteger: Integer): Integer;
begin
  Result := inherited IndexOf(Pointer(AInteger));
end;

function TModuleStateList.GetItem(AIndex: Integer): TModuleStateRec;
begin
  Result := PModuleStateRec(FList[AIndex])^;
end;

function TModuleStateList.CompareItems(AItem1, AItem2: Pointer): Integer;
var
  Ptr1, Ptr2: PModuleStateRec;
begin
  Ptr1 := AItem1;
  Ptr2 := AItem2;
  Result := Ptr1^.ModuleID - Ptr2^.ModuleID;
end;

procedure TModuleStateList.DisposeItem(AItem: Pointer);
begin
  Dispose(AItem);
end;

procedure TModuleStateList.AddOrReplace(AModuleID: Integer; ACheckedOut: Boolean;
  AUserID: Integer);
var
  PPtr: PModuleStateRec;
  idx: Integer;
begin
  idx := IndexOf(AModuleID);
  if idx <> -1 then
    Delete(idx);
  New(PPtr);
  with PPtr^ do
  begin
    LastAccess := Now;
    ModuleID := AModuleID;
    CheckedOut := ACheckedOut;
    UserID := AUserID;
  end;
  inherited Add(PPtr);
end;

function TModuleStateList.IndexOf(AModuleID: Integer): Integer;
var
  ModuleStateRec: TModuleStateRec;
begin
  ModuleStateRec.LastAccess := 0;
  ModuleStateRec.ModuleID := AModuleID;
  ModuleStateRec.CheckedOut := False;
  ModuleStateRec.UserID := 0;
  Result := inherited IndexOf(@ModuleStateRec);
end;

procedure TModuleStateList.UpdateLastAccessIdx(AIndex: Integer);
begin
  PModuleStateRec(FList[AIndex])^.LastAccess := Now;
end;

function TModuleNameToIDList.GetItem(AIndex: Integer): TModuleNameToIDRec;
begin
  Result := PModuleNameToIDRec(FList[AIndex])^;
end;

function TModuleNameToIDList.CompareItems(AItem1, AItem2: Pointer): Integer;
var
  Ptr1, Ptr2: PModuleNameToIDRec;
begin
  Ptr1 := AItem1;
  Ptr2 := AItem2;
  Result := CompareStr(Ptr1^.ModuleName, Ptr2^.ModuleName);
end;

procedure TModuleNameToIDList.DisposeItem(AItem: Pointer);
begin
  Dispose(PModuleNameToIDRec(AItem));
end;

procedure TModuleNameToIDList.AddOrReplace(AModuleName: string; AModuleID: Integer);
var
  PPtr: PModuleNameToIDRec;
  idx: Integer;
begin
  idx := IndexOf(AModuleName);
  if idx <> -1 then
    Delete(idx);
  New(PPtr);
  with PPtr^ do
  begin
    LastAccess := Now;
    ModuleName := AModuleName;
    ModuleID := AModuleID;
  end;
  inherited Add(PPtr);
end;

function TModuleNameToIDList.IndexOf(AModuleName: string): Integer;
var
  ModuleNameToIDRec: TModuleNameToIDRec;
begin
  ModuleNameToIDRec.LastAccess := 0;
  ModuleNameToIDRec.ModuleName := AModuleName;
  ModuleNameToIDRec.ModuleID := 0;
  Result := inherited IndexOf(@ModuleNameToIDRec);
end;

procedure TModuleNameToIDList.UpdateLastAccessIdx(AIndex: Integer);
begin
  PModuleNameToIDRec(FList[AIndex])^.LastAccess := Now;
end;

function TMostSevereBugsList.GetItem(AIndex: Integer): TMostServereBugRec;
begin
  Result := PMostServereBugRec(FList[AIndex])^;
end;

function TMostSevereBugsList.CompareItems(AItem1, AItem2: Pointer): Integer;
var
  Ptr1, Ptr2: PMostServereBugRec;
begin
  Ptr1 := AItem1;
  Ptr2 := AItem2;
  Result := Ptr1^.ItemID - Ptr2^.ItemID;
end;

procedure TMostSevereBugsList.DisposeItem(AItem: Pointer);
begin
  Dispose(AItem);
end;

procedure TMostSevereBugsList.AddOrReplace(AItemID, ABugID, ASeverity: Integer);
var
  PPtr: PMostServereBugRec;
  idx: Integer;
begin
  idx := IndexOf(AItemID);
  if idx <> -1 then
    Delete(idx);
  New(PPtr);
  with PPtr^ do
  begin
    ItemID := AItemID;
    BugID := ABugID;
    Severity := ASeverity;
  end;
  inherited Add(PPtr);
end;

function TMostSevereBugsList.IndexOf(AItemID: Integer): Integer;
var
  MostServereBugRec: TMostServereBugRec;
begin
  MostServereBugRec.ItemID := AItemID;
  MostServereBugRec.BugID := 0;
  MostServereBugRec.Severity := 0;
  Result := inherited IndexOf(@MostServereBugRec);
end;

function TProjectRightsList.GetItem(AIndex: Integer): TProjectRightsRec;
begin
  Result := PProjectRightsRec(FList[AIndex])^;
end;

function TProjectRightsList.CompareItems(AItem1, AItem2: Pointer): Integer;
var
  Ptr1, Ptr2: PProjectRightsRec;
begin
  Ptr1 := AItem1;
  Ptr2 := AItem2;
  Result := Ptr1^.ProjectID - Ptr2^.ProjectID;
end;

procedure TProjectRightsList.DisposeItem(AItem: Pointer);
begin
  Dispose(AItem);
end;

procedure TProjectRightsList.AddOrReplace(AProjectID, AAccessLevel: Integer);
var
  PPtr: PProjectRightsRec;
  idx: Integer;
begin
  idx := IndexOf(AProjectID);
  if idx <> -1 then
    Delete(idx);
  New(PPtr);
  with PPtr^ do
  begin
    ProjectID := AProjectID;
    AccessLevel := AAccessLevel;
  end;
  inherited Add(PPtr);
end;

function TProjectRightsList.IndexOf(AProjectID: Integer): Integer;
var
  ProjectRightsRec: TProjectRightsRec;
begin
  ProjectRightsRec.ProjectID := AProjectID;
  ProjectRightsRec.AccessLevel := 0;
  Result := inherited IndexOf(@ProjectRightsRec);
end;

constructor TProjectUserRightsList.Create;
begin
  inherited Create;
  FSortRequired := False;
end;

function TProjectUserRightsList.GetItem(AIndex: Integer): TProjectUserRightsRec;
begin
  Result := PProjectUserRightsRec(FList[AIndex])^;
end;

function TProjectUserRightsList.CompareItems(AItem1, AItem2: Pointer): Integer;
var
  Ptr1, Ptr2: PProjectUserRightsRec;
begin
  Ptr1 := AItem1;
  Ptr2 := AItem2;
  Result := Ptr1^.UserID - Ptr2^.UserID;
  if Result = 0 then
    Result := Ptr1^.ProjectID - Ptr2^.ProjectID;
end;

procedure TProjectUserRightsList.DisposeItem(AItem: Pointer);
begin
  Dispose(AItem);
end;

function CompareProjectUserRightsItems(AItem1, AItem2: Pointer): Integer;
var
  Ptr1, Ptr2: PProjectUserRightsRec;
begin
  Ptr1 := AItem1;
  Ptr2 := AItem2;
  Result := Ptr1^.UserID - Ptr2^.UserID;
  if Result = 0 then
    Result := Ptr1^.ProjectID - Ptr2^.ProjectID;
end;

procedure TProjectUserRightsList.DoSort;
begin
  if FSortRequired then
  begin
    FList.Sort(CompareProjectUserRightsItems);
    FSortRequired := False;
  end;
end;

procedure TProjectUserRightsList.Add(AUserID, AProjectID, AAccessLevel: Integer);
var
  PPtr: PProjectUserRightsRec;
begin
  New(PPtr);
  with PPtr^ do
  begin
    UserID := AUserID;
    ProjectID := AProjectID;
    AccessLevel := AAccessLevel;
  end;
  FList.Add(PPtr);
  FSortRequired := True;
end;

function TProjectUserRightsList.IndexOf(AUserID, AProjectID: Integer): Integer;
var
  ProjectUserRightsRec: TProjectUserRightsRec;
begin
  DoSort;
  ProjectUserRightsRec.UserID := AUserID;
  ProjectUserRightsRec.ProjectID := AProjectID;
  ProjectUserRightsRec.AccessLevel := 0;
  Result := inherited IndexOf(@ProjectUserRightsRec);
end;

function TIDToNameList.GetItem(AIndex: Integer): TIDToNameRec;
begin
  Result := PIDToNameRec(FList[AIndex])^;
end;

function TIDToNameList.CompareItems(AItem1, AItem2: Pointer): Integer;
var
  Ptr1, Ptr2: PIDToNameRec;
begin
  Ptr1 := AItem1;
  Ptr2 := AItem2;
  Result := Ptr1^.ID - Ptr2^.ID;
end;

procedure TIDToNameList.DisposeItem(AItem: Pointer);
begin
  Dispose(PIDToNameRec(AItem));
end;

procedure TIDToNameList.AddOrReplace(AID: Integer; AName: string);
var
  PPtr: PIDToNameRec;
  Idx: Integer;
begin
  Idx := IndexOf(AID);
  if Idx <> -1 then
    Delete(Idx);
  New(PPtr);
  with PPtr^ do
  begin
    ID := AID;
    Name := AName;
  end;
  inherited Add(PPtr);
end;

function TIDToNameList.IndexOf(AID: Integer): Integer;
var
  IDToNameRec: TIDToNameRec;
begin
  IDToNameRec.ID := AID;
  IDToNameRec.Name := '';
  Result := inherited IndexOf(@IDToNameRec);
end;

function TModuleRevisionLabelList.GetItem(AIndex: Integer): TModuleRevisionLabelRec;
begin
  Result := PModuleRevisionLabelRec(FList[AIndex])^;
end;

function TModuleRevisionLabelList.CompareItems(AItem1, AItem2: Pointer): Integer;
var
  Ptr1, Ptr2: PModuleRevisionLabelRec;
begin
  Result := CompareModuleRevision(AItem1, AItem2);
  if Result = 0 then
  begin
    Ptr1 := AItem1;
    Ptr2 := AItem2;
    Result := Ptr1^.LabelID - Ptr2^.LabelID;
  end;
end;

function TModuleRevisionLabelList.CompareModuleRevision(AItem1, AItem2: Pointer): Integer;
var
  Ptr1, Ptr2: PModuleRevisionLabelRec;
begin
  Ptr1 := AItem1;
  Ptr2 := AItem2;
  Result := Ptr1^.ModuleID - Ptr2^.ModuleID;
  if Result = 0 then
    Result := Ptr1^.RevisionID - Ptr2^.RevisionID;
end;

procedure TModuleRevisionLabelList.DisposeItem(AItem: Pointer);
begin
  Dispose(AItem);
end;

procedure TModuleRevisionLabelList.Add(AModuleID, ARevisionID, ALabelID: Integer);
var
  PPtr: PModuleRevisionLabelRec;
begin
  New(PPtr);
  with PPtr^ do
  begin
    ModuleID := AModuleID;
    RevisionID := ARevisionID;
    LabelID := ALabelID;
  end;
  inherited Add(PPtr);
end;

function TModuleRevisionLabelList.GetModuleRevisionLabelRange(AModuleID, ARevisionID: Integer; var ARangeStart, ARangeEnd: Integer): Boolean;
var
  ModuleRevisionLabel: TModuleRevisionLabelRec;
begin
  ModuleRevisionLabel.ModuleID := AModuleID;
  ModuleRevisionLabel.RevisionID := ARevisionID;
  ModuleRevisionLabel.LabelID := 0;
  Result := InternalGetRange(@ModuleRevisionLabel, CompareModuleRevision, ARangeStart, ARangeEnd);
end;

function TModuleRevisionLabelList.IndexOf(AModuleID, ARevisionID, ALabelID: Integer): Integer;
var
  ModuleRevisionLabel: TModuleRevisionLabelRec;
begin
  ModuleRevisionLabel.ModuleID := AModuleID;
  ModuleRevisionLabel.RevisionID := ARevisionID;
  ModuleRevisionLabel.LabelID := ALabelID;
  Result := inherited IndexOf(@ModuleRevisionLabel);
end;

end.
