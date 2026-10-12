(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSBranchClientObj.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
- unit is handcrafted and not generated
-----------------------------------------------------------------------------

Unit history:

2006/02/17  USchuster - new unit
2006/06/28  USchuster - renamed AddNewBranch to AddBranch
                      - added RemoveBranch and UpdateBranch
2006/11/08  USchuster - removed TJVCSAddNewBranch
2008/12/23  USchuster - added TJVCSGetBranchpointRevisions
2009/04/04  USchuster - added TagOnly to TJVCSAddBranch
2009/09/06  USchuster - added path substitution options to TJVCSAddBranch

-----------------------------------------------------------------------------*)

unit JVCSBranchClientObj;

interface

uses
  SysUtils, Classes, CBroker, JVCSTypes, JVCSClientObjBase, RFormat;

type
  TJVCSAddBranch = class(TJVCSClientObject)
  private
    // input
    FUserID: Integer;
    FParentBranchID: Integer;
    FBranchName: string;
    FDescription: string;
    FTagOnly: Boolean;
    FSubstituteRootPath: Boolean;
    FOldRootPath: string;
    FNewRootPath: string;
    // output
    FIsNewBranch: Boolean;
    FBranchID: Integer;
  protected
    procedure DoExecute; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CopyFromReference(Reference: TClientObject); override;
    procedure Initialize; override;
    procedure SetResponseFields(ResponseBuffer: TMWBuffer); override;
    // input
    property UserID: Integer read FUserID write FUserID;
    property ParentBranchID: Integer read FParentBranchID write FParentBranchID;
    property BranchName: string read FBranchName write FBranchName;
    property Description: string read FDescription write FDescription;
    property TagOnly: Boolean read FTagOnly write FTagOnly;
    property SubstituteRootPath: Boolean read FSubstituteRootPath write FSubstituteRootPath;
    property OldRootPath: string read FOldRootPath write FOldRootPath;
    property NewRootPath: string read FNewRootPath write FNewRootPath;
    // output
    property IsNewBranch: Boolean read FIsNewBranch;
    property BranchID: Integer read FBranchID;
  end;

  TJVCSRemoveBranch = class(TJVCSClientObject)
  private
    // input
    FBranchID: Integer;
    // output
    FRemoved: Boolean;
    FErrorMessage: string;
  protected
    procedure DoExecute; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CopyFromReference(Reference: TClientObject); override;
    procedure Initialize; override;
    procedure SetResponseFields(ResponseBuffer: TMWBuffer); override;
    // input
    property BranchID: Integer read FBranchID write FBranchID;
    // output
    property Removed: Boolean read FRemoved;
    property ErrorMessage: string read FErrorMessage;
  end;

  TJVCSUpdateBranch = class(TJVCSClientObject)
  private
    // input
    FBranchID: Integer;
    FBranchName: JVCSString50;
    FBranchDescription: string;
    // output
    FBranchUpdated: Boolean;
    FErrorMessage: string;
  protected
    procedure DoExecute; override;
  public
    procedure CopyFromReference(Reference: TClientObject); override;
    procedure Initialize; override;
    procedure SetResponseFields(ResponseBuffer: TMWBuffer); override;
    // input
    property BranchID: Integer read FBranchID write FBranchID;
    property BranchName: JVCSString50 read FBranchName write FBranchName;
    property BranchDescription: string read FBranchDescription write FBranchDescription;
    // output
    property BranchUpdated: Boolean read FBranchUpdated;
    property ErrorMessage: string read FErrorMessage;
  end;

  TJVCSSelectBranch = class(TJVCSClientObject)
  private
    // input
    FBranchID: Integer;
    // output
    FBranchFound: Boolean;
  protected
    procedure DoExecute; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CopyFromReference(Reference: TClientObject); override;
    procedure Initialize; override;
    procedure SetResponseFields(ResponseBuffer: TMWBuffer); override;
    // input
    property BranchID: Integer read FBranchID write FBranchID;
    // output
    property BranchFound: Boolean read FBranchFound;
  end;

  // GET_BRANCH_LIST

  PGetBranchListOutputItem = ^TGetBranchListOutputItem;
  TGetBranchListOutputItem = record
    BranchID: Integer;
    ParentBranchID: Integer;
    Name: string;//todo string50?
    Description: string;
    Created_By: Integer;
    Created_In: TDateTime;
  end;

  TJVCSGetBranchList = class(TJVCSClientObject)
  private
    // input
    FIncludeDetails: Boolean;
    // output
    FOutputItems: TList;
    procedure ClearOutputItems;
    function GetOutputItemCount: Integer;
    function GetOutputItems(Index: Integer): TGetBranchListOutputItem;
  protected
    procedure DoExecute; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CopyFromReference(Reference: TClientObject); override;
    procedure Initialize; override;
    procedure SetResponseFields(ResponseBuffer: TMWBuffer); override;
    // input
    property IncludeDetails: Boolean read FIncludeDetails write FIncludeDetails;
    // output
    property OutputItemCount: Integer read GetOutputItemCount;
    property OutputItems[Index: Integer]: TGetBranchListOutputItem read GetOutputItems;
  end;

  // GET_MODULE_REVISIONS

  PBranchGetModuleRevisionsOutputItem = ^TBranchGetModuleRevisionsOutputItem;
  TBranchGetModuleRevisionsOutputItem = record
    BranchID: Integer;
    RevisionID: Integer;
  end;

  TJVCSBranchGetModuleRevisions = class(TJVCSClientObject)
  private
    // input
    FModuleID: Integer;
    // output
    FOutputItems: TList;
    procedure ClearOutputItems;
    function GetOutputItemCount: Integer;
    function GetOutputItems(Index: Integer): TBranchGetModuleRevisionsOutputItem;
  protected
    procedure DoExecute; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CopyFromReference(Reference: TClientObject); override;
    procedure Initialize; override;
    procedure SetResponseFields(ResponseBuffer: TMWBuffer); override;
    // input
    property ModuleID: Integer read FModuleID write FModuleID;
    // output
    property OutputItemCount: Integer read GetOutputItemCount;
    property OutputItems[Index: Integer]: TBranchGetModuleRevisionsOutputItem read GetOutputItems;
  end;

  // GET_BRANCHPOINT_REVISIONS

  PGetBranchpointRevisionsOutputItem = ^TGetBranchpointRevisionsOutputItem;
  TGetBranchpointRevisionsOutputItem = record
    ModuleID: Integer;
    ModuleName: JVCSString255;
    ModulePath: JVCSString255;
    RevisionID: Integer;
    Version: Integer;
    Revision: Integer;
    RevisionTimestamp: TDateTime;
    RevisionExtension: JVCSString20;
    RevisionCRC32: Integer;
  end;

  TJVCSGetBranchpointRevisions = class(TJVCSClientObject)
  private
    // input
    FProjectID: Integer;
    FExcludeHiddenModules: Boolean;
    // output
    FOutputItems: TList;
    procedure ClearOutputItems;
    function GetOutputItemCount: Integer;
    function GetOutputItems(Index: Integer): TGetBranchpointRevisionsOutputItem;
  protected
    procedure DoExecute; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CopyFromReference(Reference: TClientObject); override;
    procedure Initialize; override;
    procedure SetResponseFields(ResponseBuffer: TMWBuffer); override;
    // input
    property ProjectID: Integer read FProjectID write FProjectID;
    property ExcludeHiddenModules: Boolean read FExcludeHiddenModules write FExcludeHiddenModules;
    // output
    property OutputItemCount: Integer read GetOutputItemCount;
    property OutputItems[Index: Integer]: TGetBranchpointRevisionsOutputItem read GetOutputItems;
  end;

implementation

{ TJVCSAddBranch protected }

procedure TJVCSAddBranch.DoExecute;
begin
  inherited DoExecute;
  if Assigned(FAppSrvClient) and Assigned(FAppSrvClient.Request) then
    with FAppSrvClient.Request do
    begin
      WriteFields(True, [FUserID]);
      WriteFields(False, [FParentBranchID]);
      WriteFields(False, [FBranchName]);
      WriteFields(False, [FDescription]);
      WriteFields(False, [FTagOnly]);
      WriteFields(False, [FSubstituteRootPath]);
      WriteFields(False, [FOldRootPath]);
      WriteFields(False, [FNewRootPath]);
    end;
end;

{ TJVCSAddBranch public }

constructor TJVCSAddBranch.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TJVCSAddBranch.Destroy;
begin
  inherited Destroy;
end;

procedure TJVCSAddBranch.CopyFromReference(Reference: TClientObject);
begin
  inherited CopyFromReference(Reference);
  if Assigned(Reference) and (Reference is TJVCSAddBranch) then
    begin
      FUserID := TJVCSAddBranch(Reference).FUserID;
      FParentBranchID := TJVCSAddBranch(Reference).FParentBranchID;

      FBranchName := TJVCSAddBranch(Reference).FBranchName;
      FDescription := TJVCSAddBranch(Reference).FDescription;
      FTagOnly := TJVCSAddBranch(Reference).FTagOnly;
      FSubstituteRootPath := TJVCSAddBranch(Reference).FSubstituteRootPath;
      FOldRootPath := TJVCSAddBranch(Reference).FOldRootPath;
      FNewRootPath := TJVCSAddBranch(Reference).FNewRootPath;
      FIsNewBranch := TJVCSAddBranch(Reference).FIsNewBranch;
      FBranchID := TJVCSAddBranch(Reference).FBranchID;
    end;
end;

procedure TJVCSAddBranch.Initialize;
begin
  inherited Initialize;
  FIsNewBranch := False;
  FBranchID := -1;
end;

procedure TJVCSAddBranch.SetResponseFields(ResponseBuffer: TMWBuffer);
begin
  inherited SetResponseFields(ResponseBuffer);
  if Assigned(ResponseBuffer) then
  begin
    if not ResponseBuffer.Eof then
    begin
      if (ResponseBuffer.FieldCount > 0) and (ResponseBuffer.FieldType[0] = mwString) then
        FIsNewBranch := (StrToInt64Def(ResponseBuffer.Fields[0], 0) <> 0);
      if (ResponseBuffer.FieldCount > 1) and (ResponseBuffer.FieldType[1] = mwString) then
        FBranchID := StrToInt64Def(ResponseBuffer.Fields[1], -1);
    end;
  end;
end;

{ TJVCSRemoveBranch protected }

procedure TJVCSRemoveBranch.DoExecute;
begin
  inherited DoExecute;
  if Assigned(FAppSrvClient) and Assigned(FAppSrvClient.Request) then
    with FAppSrvClient.Request do
    begin
      WriteFields(True, [FBranchID]);
    end;
end;

{ TJVCSRemoveBranch public }

constructor TJVCSRemoveBranch.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TJVCSRemoveBranch.Destroy;
begin
  inherited Destroy;
end;

procedure TJVCSRemoveBranch.CopyFromReference(Reference: TClientObject);
begin
  inherited CopyFromReference(Reference);
  if Assigned(Reference) and (Reference is TJVCSRemoveBranch) then
    begin
      FBranchID := TJVCSRemoveBranch(Reference).FBranchID;
      FRemoved := TJVCSRemoveBranch(Reference).FRemoved;
      FErrorMessage := TJVCSRemoveBranch(Reference).FErrorMessage;
    end;
end;

procedure TJVCSRemoveBranch.Initialize; 
begin
  inherited Initialize;
  FRemoved := False;
  FErrorMessage := '';
end;

procedure TJVCSRemoveBranch.SetResponseFields(ResponseBuffer: TMWBuffer);
begin
  inherited SetResponseFields(ResponseBuffer);
  if Assigned(ResponseBuffer) then
  begin
    if not ResponseBuffer.Eof then
    begin
      if (ResponseBuffer.FieldCount > 0) and (ResponseBuffer.FieldType[0] = mwString) then
        FRemoved := (StrToInt64Def(ResponseBuffer.Fields[0], 0) <> 0);
      if (ResponseBuffer.FieldCount > 1) and (ResponseBuffer.FieldType[1] = mwString) then
        FErrorMessage := ResponseBuffer.Fields[1];
    end;
  end;
end;

{ TJVCSUpdateBranch protected }

procedure TJVCSUpdateBranch.DoExecute;
begin
  inherited DoExecute;
  if Assigned(FAppSrvClient) and Assigned(FAppSrvClient.Request) then
    with FAppSrvClient.Request do
    begin
      WriteFields(True, [FBranchID]);
      WriteFields(False, [FBranchName]);
      WriteFields(False, [FBranchDescription]);
    end;
end;

{ TJVCSUpdateBranch public }

procedure TJVCSUpdateBranch.CopyFromReference(Reference: TClientObject);
begin
  inherited CopyFromReference(Reference);
  if Assigned(Reference) and (Reference is TJVCSUpdateBranch) then
    begin
      FBranchID := TJVCSUpdateBranch(Reference).FBranchID;
      FBranchName := TJVCSUpdateBranch(Reference).FBranchName;
      FBranchDescription := TJVCSUpdateBranch(Reference).FBranchDescription;
      FBranchUpdated := TJVCSUpdateBranch(Reference).FBranchUpdated;
      FErrorMessage := TJVCSUpdateBranch(Reference).FErrorMessage;
    end;
end;

procedure TJVCSUpdateBranch.Initialize; 
begin
  inherited Initialize;
  FBranchUpdated := False;
  FErrorMessage := '';
end;

procedure TJVCSUpdateBranch.SetResponseFields(ResponseBuffer: TMWBuffer);
begin
  inherited SetResponseFields(ResponseBuffer);
  if Assigned(ResponseBuffer) then
  begin
    if not ResponseBuffer.Eof then
    begin
      if (ResponseBuffer.FieldCount > 0) and (ResponseBuffer.FieldType[0] = mwString) then
        FBranchUpdated := (StrToInt64Def(ResponseBuffer.Fields[0], 0) <> 0);
      if (ResponseBuffer.FieldCount > 1) and (ResponseBuffer.FieldType[1] = mwString) then
        FErrorMessage := ResponseBuffer.Fields[1];
    end;
  end;
end;

{ TJVCSSelectBranch protected }

procedure TJVCSSelectBranch.DoExecute;
begin
  inherited DoExecute;
  if Assigned(FAppSrvClient) and Assigned(FAppSrvClient.Request) then
    with FAppSrvClient.Request do
    begin
      WriteFields(True, [FBranchID]);
    end;
end;

{ TJVCSSelectBranch public }

constructor TJVCSSelectBranch.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TJVCSSelectBranch.Destroy;
begin
  inherited Destroy;
end;

procedure TJVCSSelectBranch.CopyFromReference(Reference: TClientObject);
begin
  inherited CopyFromReference(Reference);
  if Assigned(Reference) and (Reference is TJVCSSelectBranch) then
    begin
      FBranchID := TJVCSSelectBranch(Reference).FBranchID;
      FBranchFound := TJVCSSelectBranch(Reference).FBranchFound;
    end;
end;

procedure TJVCSSelectBranch.Initialize;
begin
  inherited Initialize;
  FBranchFound := False;
end;

procedure TJVCSSelectBranch.SetResponseFields(ResponseBuffer: TMWBuffer);
begin
  inherited SetResponseFields(ResponseBuffer);
  if Assigned(ResponseBuffer) then
  begin
    if not ResponseBuffer.Eof then
    begin
      if (ResponseBuffer.FieldCount > 0) and (ResponseBuffer.FieldType[0] = mwString) then
        FBranchFound := (StrToInt64Def(ResponseBuffer.Fields[0], 0) <> 0);
    end;
  end;
end;


{ TJVCSGetBranchList private }

procedure TJVCSGetBranchList.ClearOutputItems;
var
  I: Integer;
  Item: TGetBranchListOutputItem;
begin
  for I := 0 to FOutputItems.Count - 1 do
  begin
    Item := PGetBranchListOutputItem(FOutputItems[I])^;
    Finalize(Item);
    FreeMem(FOutputItems[I]);
  end;
  FOutputItems.Clear;
end;

function TJVCSGetBranchList.GetOutputItemCount: Integer;
begin
  Result := FOutputItems.Count;
end;

function TJVCSGetBranchList.GetOutputItems(Index: Integer): TGetBranchListOutputItem;
begin
  Result := PGetBranchListOutputItem(FOutputItems[Index])^;
end;

{ TJVCSGetBranchList protected }

procedure TJVCSGetBranchList.DoExecute;
begin
  inherited DoExecute;
  if Assigned(FAppSrvClient) and Assigned(FAppSrvClient.Request) then
    with FAppSrvClient.Request do
    begin
      WriteFields(True, [FIncludeDetails]);
    end;
end;

{ TJVCSGetBranchList public }

constructor TJVCSGetBranchList.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOutputItems := TList.Create;
end;

destructor TJVCSGetBranchList.Destroy;
begin
  ClearOutputItems;
  FOutputItems.Free;
  inherited Destroy;
end;

procedure TJVCSGetBranchList.CopyFromReference(Reference: TClientObject);
var
  I: Integer;
  P: Pointer;
begin
  inherited CopyFromReference(Reference);
  if Assigned(Reference) and (Reference is TJVCSGetBranchList) then
    begin
      FIncludeDetails := TJVCSGetBranchList(Reference).FIncludeDetails;
      ClearOutputItems;
      for I := 0 to TJVCSGetBranchList(Reference).OutputItemCount - 1 do
      begin
        P := AllocMem(SizeOf(TGetBranchListOutputItem));
        try
          with PGetBranchListOutputItem(P)^ do
          begin
            BranchID := TJVCSGetBranchList(Reference).OutputItems[I].BranchID;
            ParentBranchID := TJVCSGetBranchList(Reference).OutputItems[I].ParentBranchID;
            Name := TJVCSGetBranchList(Reference).OutputItems[I].Name;
            Description := TJVCSGetBranchList(Reference).OutputItems[I].Description;
            Created_By := TJVCSGetBranchList(Reference).OutputItems[I].Created_By;
            Created_In := TJVCSGetBranchList(Reference).OutputItems[I].Created_In;
          end;
          FOutputItems.Add(P);
        except
          FreeMem(P);
          raise;
        end;
      end;
    end;
end;

procedure TJVCSGetBranchList.Initialize;
begin
  inherited Initialize;
  ClearOutputItems;
end;

procedure TJVCSGetBranchList.SetResponseFields(ResponseBuffer: TMWBuffer);
var
  P: Pointer;
begin
  inherited SetResponseFields(ResponseBuffer);
  if Assigned(ResponseBuffer) then
  begin
    if not ResponseBuffer.Eof then
    begin
      while not ResponseBuffer.Eof do
      begin
        P := AllocMem(SizeOf(TGetBranchListOutputItem));
        try
          if (ResponseBuffer.FieldCount > 0) and (ResponseBuffer.FieldType[0] = mwString) then
            PGetBranchListOutputItem(P)^.BranchID := StrToInt64Def(ResponseBuffer.Fields[0], -1);
          if (ResponseBuffer.FieldCount > 1) and (ResponseBuffer.FieldType[1] = mwString) then
            PGetBranchListOutputItem(P)^.ParentBranchID := StrToInt64Def(ResponseBuffer.Fields[1], -1);
          if (ResponseBuffer.FieldCount > 2) and (ResponseBuffer.FieldType[2] = mwString) then
            PGetBranchListOutputItem(P)^.Name := ResponseBuffer.Fields[2];
          if (ResponseBuffer.FieldCount > 3) and (ResponseBuffer.FieldType[3] = mwString) then
            PGetBranchListOutputItem(P)^.Created_By := StrToInt64Def(ResponseBuffer.Fields[3], -1);
          if (ResponseBuffer.FieldCount > 4) and (ResponseBuffer.FieldType[4] = mwString) then
            PGetBranchListOutputItem(P)^.Created_In := SafeStrToFloat(ResponseBuffer.Fields[4]);
          if (ResponseBuffer.FieldCount > 5) and (ResponseBuffer.FieldType[5] = mwString) then
            PGetBranchListOutputItem(P)^.Description := ResponseBuffer.Fields[5];
          FOutputItems.Add(P);
          ResponseBuffer.Next;
        except
          FreeMem(P);
          raise;
        end;
      end;
    end;
  end;
end;

{ TJVCSBranchGetModuleRevisions private }

procedure TJVCSBranchGetModuleRevisions.ClearOutputItems;
var
  I: Integer;
  Item: TBranchGetModuleRevisionsOutputItem;
begin
  for I := 0 to FOutputItems.Count - 1 do
  begin
    Item := PBranchGetModuleRevisionsOutputItem(FOutputItems[I])^;
    FreeMem(FOutputItems[I]);
  end;
  FOutputItems.Clear;
end;

function TJVCSBranchGetModuleRevisions.GetOutputItemCount: Integer;
begin
  Result := FOutputItems.Count;
end;

function TJVCSBranchGetModuleRevisions.GetOutputItems(Index: Integer): TBranchGetModuleRevisionsOutputItem;
begin
  Result := PBranchGetModuleRevisionsOutputItem(FOutputItems[Index])^;
end;

{ TJVCSBranchGetModuleRevisions protected }

procedure TJVCSBranchGetModuleRevisions.DoExecute;
begin
  inherited DoExecute;
  if Assigned(FAppSrvClient) and Assigned(FAppSrvClient.Request) then
    with FAppSrvClient.Request do
    begin
      WriteFields(True, [FModuleID]);
    end;
end;

{ TJVCSBranchGetModuleRevisions public }

constructor TJVCSBranchGetModuleRevisions.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOutputItems := TList.Create;
end;

destructor TJVCSBranchGetModuleRevisions.Destroy;
begin
  ClearOutputItems;
  FOutputItems.Free;
  inherited Destroy;
end;

procedure TJVCSBranchGetModuleRevisions.CopyFromReference(Reference: TClientObject);
var
  I: Integer;
  P: Pointer;
begin
  inherited CopyFromReference(Reference);
  if Assigned(Reference) and (Reference is TJVCSBranchGetModuleRevisions) then
    begin
      FModuleID := TJVCSBranchGetModuleRevisions(Reference).FModuleID;
      ClearOutputItems;
      for I := 0 to TJVCSBranchGetModuleRevisions(Reference).OutputItemCount - 1 do
      begin
        P := AllocMem(SizeOf(TBranchGetModuleRevisionsOutputItem));
        try
          with PBranchGetModuleRevisionsOutputItem(P)^ do
          begin
            BranchID := TJVCSBranchGetModuleRevisions(Reference).OutputItems[I].BranchID;
            RevisionID := TJVCSBranchGetModuleRevisions(Reference).OutputItems[I].RevisionID;
          end;
          FOutputItems.Add(P);
        except
          FreeMem(P);
          raise;
        end;
      end;
    end;
end;

procedure TJVCSBranchGetModuleRevisions.Initialize;
begin
  inherited Initialize;
  ClearOutputItems;
end;

procedure TJVCSBranchGetModuleRevisions.SetResponseFields(ResponseBuffer: TMWBuffer);
var
  P: Pointer;
begin
  inherited SetResponseFields(ResponseBuffer);
  if Assigned(ResponseBuffer) then
  begin
    if not ResponseBuffer.Eof then
    begin
      while not ResponseBuffer.Eof do
      begin
        P := AllocMem(SizeOf(TBranchGetModuleRevisionsOutputItem));
        try
          if (ResponseBuffer.FieldCount > 0) and (ResponseBuffer.FieldType[0] = mwString) then
            PBranchGetModuleRevisionsOutputItem(P)^.BranchID := StrToInt64Def(ResponseBuffer.Fields[0], -1);
          if (ResponseBuffer.FieldCount > 1) and (ResponseBuffer.FieldType[1] = mwString) then
            PBranchGetModuleRevisionsOutputItem(P)^.RevisionID := StrToInt64Def(ResponseBuffer.Fields[1], -1);
          FOutputItems.Add(P);
          ResponseBuffer.Next;
        except
          FreeMem(P);
          raise;
        end;
      end;
    end;
  end;
end;

{ TJVCSGetBranchpointRevisions private }

procedure TJVCSGetBranchpointRevisions.ClearOutputItems;
var
  I: Integer;
begin
  for I := 0 to FOutputItems.Count - 1 do
    FreeMem(FOutputItems[I]);
  FOutputItems.Clear;
end;

function TJVCSGetBranchpointRevisions.GetOutputItemCount: Integer;
begin
  Result := FOutputItems.Count;
end;

function TJVCSGetBranchpointRevisions.GetOutputItems(Index: Integer): TGetBranchpointRevisionsOutputItem;
begin
  Result := PGetBranchpointRevisionsOutputItem(FOutputItems[Index])^;
end;

{ TJVCSGetBranchpointRevisions protected }

procedure TJVCSGetBranchpointRevisions.DoExecute;
begin
  inherited DoExecute;
  if Assigned(FAppSrvClient) and Assigned(FAppSrvClient.Request) then
    with FAppSrvClient.Request do
    begin
      WriteFields(True, [FProjectID]);
      WriteFields(False, [FExcludeHiddenModules]);
    end;
end;

{ TJVCSGetBranchpointRevisions public }

constructor TJVCSGetBranchpointRevisions.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOutputItems := TList.Create;
end;

destructor TJVCSGetBranchpointRevisions.Destroy;
begin
  ClearOutputItems;
  FOutputItems.Free;
  inherited Destroy;
end;

procedure TJVCSGetBranchpointRevisions.CopyFromReference(Reference: TClientObject);
var
  I: Integer;
  P: Pointer;
begin
  inherited CopyFromReference(Reference);
  if Assigned(Reference) and (Reference is TJVCSGetBranchpointRevisions) then
    begin
      FProjectID := TJVCSGetBranchpointRevisions(Reference).FProjectID;
      FExcludeHiddenModules := TJVCSGetBranchpointRevisions(Reference).FExcludeHiddenModules;
      ClearOutputItems;
      for I := 0 to TJVCSGetBranchpointRevisions(Reference).OutputItemCount - 1 do
      begin
        P := AllocMem(SizeOf(TGetBranchpointRevisionsOutputItem));
        try
          with PGetBranchpointRevisionsOutputItem(P)^ do
          begin
            ModuleID := TJVCSGetBranchpointRevisions(Reference).OutputItems[I].ModuleID;
            ModuleName := TJVCSGetBranchpointRevisions(Reference).OutputItems[I].ModuleName;
            ModulePath := TJVCSGetBranchpointRevisions(Reference).OutputItems[I].ModulePath;
            RevisionID := TJVCSGetBranchpointRevisions(Reference).OutputItems[I].RevisionID;
            Version := TJVCSGetBranchpointRevisions(Reference).OutputItems[I].Version;
            Revision := TJVCSGetBranchpointRevisions(Reference).OutputItems[I].Revision;
            RevisionTimestamp := TJVCSGetBranchpointRevisions(Reference).OutputItems[I].RevisionTimestamp;
            RevisionExtension := TJVCSGetBranchpointRevisions(Reference).OutputItems[I].RevisionExtension;
            RevisionCRC32 := TJVCSGetBranchpointRevisions(Reference).OutputItems[I].RevisionCRC32;
          end;
          FOutputItems.Add(P);
        except
          FreeMem(P);
          raise;
        end;
      end;
    end;
end;

procedure TJVCSGetBranchpointRevisions.Initialize; 
begin
  inherited Initialize;
  ClearOutputItems;
end;

procedure TJVCSGetBranchpointRevisions.SetResponseFields(ResponseBuffer: TMWBuffer);
var
  P: Pointer;
begin
  inherited SetResponseFields(ResponseBuffer);
  if Assigned(ResponseBuffer) then
  begin
    if not ResponseBuffer.Eof then
    begin
      while not ResponseBuffer.Eof do
      begin
        P := AllocMem(SizeOf(TGetBranchpointRevisionsOutputItem));
        try
          if (ResponseBuffer.FieldCount > 0) and (ResponseBuffer.FieldType[0] = mwString) then
            PGetBranchpointRevisionsOutputItem(P)^.ModuleID := StrToInt64Def(ResponseBuffer.Fields[0], -1);
          if (ResponseBuffer.FieldCount > 1) and (ResponseBuffer.FieldType[1] = mwString) then
            PGetBranchpointRevisionsOutputItem(P)^.ModuleName := ResponseBuffer.Fields[1];
          if (ResponseBuffer.FieldCount > 2) and (ResponseBuffer.FieldType[2] = mwString) then
            PGetBranchpointRevisionsOutputItem(P)^.ModulePath := ResponseBuffer.Fields[2];
          if (ResponseBuffer.FieldCount > 3) and (ResponseBuffer.FieldType[3] = mwString) then
            PGetBranchpointRevisionsOutputItem(P)^.RevisionID := StrToInt64Def(ResponseBuffer.Fields[3], -1);
          if (ResponseBuffer.FieldCount > 4) and (ResponseBuffer.FieldType[4] = mwString) then
            PGetBranchpointRevisionsOutputItem(P)^.Version := StrToInt64Def(ResponseBuffer.Fields[4], -1);
          if (ResponseBuffer.FieldCount > 5) and (ResponseBuffer.FieldType[5] = mwString) then
            PGetBranchpointRevisionsOutputItem(P)^.Revision := StrToInt64Def(ResponseBuffer.Fields[5], -1);
          if (ResponseBuffer.FieldCount > 6) and (ResponseBuffer.FieldType[6] = mwString) then
            PGetBranchpointRevisionsOutputItem(P)^.RevisionTimestamp := SafeStrToFloat(ResponseBuffer.Fields[6]);
          if (ResponseBuffer.FieldCount > 7) and (ResponseBuffer.FieldType[7] = mwString) then
            PGetBranchpointRevisionsOutputItem(P)^.RevisionExtension := ResponseBuffer.Fields[7];
          if (ResponseBuffer.FieldCount > 8) and (ResponseBuffer.FieldType[8] = mwString) then
            PGetBranchpointRevisionsOutputItem(P)^.RevisionCRC32 := StrToInt64Def(ResponseBuffer.Fields[8], -1);
          FOutputItems.Add(P);
          ResponseBuffer.Next;
        except
          FreeMem(P);
          raise;
        end;
      end;
    end;
  end;
end;

end.