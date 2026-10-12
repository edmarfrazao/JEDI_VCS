(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSDataClasses.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2003/09/15  USchuster - new unit (code moved from ProjAdmin.pas)
2003/11/30  USchuster - replaced server function calls with ClientObjects
                      - clean up
2003/12/30  USchuster - added class for module state check
2004/01/11  USchuster - added new class TRefreshProjects for recent projects in ProjAdmin
2004/01/16  USchuster - bugfix: now the projectlist will only be loaded in TRefreshProjects
                        when connected
2004/01/25  USchuster - added new class TMostSevereBugsDataList
2004/12/29  USchuster - TProjects does now suppress projects without at least
                        read only access (for mantis #2254)
2005/01/06  THuber    - Extended projectclass with info if project is deleted
2005/04/16  USchuster - added HandleThreadException to TRefreshProjects to ignore
                        appserver result 403 in the thread (mantis #2714)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC3 was released ^^^^^^^^^^^^^^^^^^^^^^^^^^^
2006/01/08  USchuster - added new class TFileFamilyList (for mantis #3423)
2006/01/14  USchuster - fixed sometimes wrong module state in TModuleStateDataList (mantis #3434)
2008/06/08  USchuster - fixed memory leak (Mantis #3082)
                      - simplified memory leak fix
2008/07/08  USchuster - added TRefreshProjects.LoadSynchron

-----------------------------------------------------------------------------*)

unit JVCSDataClasses;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, SysUtils, Classes, JVCSClasses, JVCSInterfaces, JVCSThreads, Contnrs,
  JVCSClientObj;

type
  TProject = class(TObject)
  public
    Name: string;
    ID: Integer;
    Assigned: Boolean;
    Deleted: Boolean;
    constructor Create;
  end;

  TProjects = class(TObject)
  private
    FItems: TList;
    FLoaded: Boolean;
  protected
    function GetProject(Index: Integer): TProject;
    function GetItemCount: Integer;
    procedure Add(AItem: TProject);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Load(ADefaultAccessLevel: Integer = -1);
    procedure Clear;
    property Project[Index: Integer]: TProject read GetProject; default;
    property ItemCount: Integer read GetItemCount;
    function GetProjectName(AID: Integer): string;
    function GetIsDeleted(AID: Integer): Boolean;
  end;

  TRefreshProjects = class(TComponent, IJVCSRefresh)
  private
    FInternalThread: TJVCSJobThread;
    FIsRefreshing: Boolean;
    FItems: TObjectList;
    FLock: TRTLCriticalSection;
    FLoaded: Boolean;
    FLocked: Boolean;
    function GetCount: Integer;
    function GetItems(AIndex: Integer): TProject;
    procedure HandleThreadException(Sender: TObject; E: Exception; var AHandled: Boolean);
    procedure ThreadRefresh(AThreadJob: TJVCSThreadJob);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure LoadSynchron;
    procedure Lock;
    procedure SimpleRefresh(ARefreshType: TJVCSRefreshType);
    procedure Unlock;

    property Count: Integer read GetCount;
    property Items[AIndex: Integer]: TProject read GetItems; default;
  end;

  TModuleStateDataList = class(TObject)
  private
    FArchiveTimeStamp: TDateTime;
    FModuleNameToIDList: TModuleNameToIDList;
    FModuleStateList: TModuleStateList;
    function GetArchiveTimeStamp: TDateTime;
    function GetModuleID(AModuleName: string): Integer;
    function GetModuleState(AModuleID: Integer; var ACheckedOut: Boolean;
      var AUserID: Integer): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;
    function GetStateByName(AModuleName: string): TModuleStateRec;
  end;

  TMostSevereBugsDataList = class(TObject)
  private
    FMostSevereBugsList: TMostSevereBugsList;
    procedure InternalLoad(AModuleBased: Boolean);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;
    function GetItemSeverity(AItemID: Integer): Integer;
    procedure LoadMostSevereModuleBugs;    
    procedure LoadMostSevereProjectBugs;
  end;

  TFileFamilyList = class(TObject)
  private
    FFileFamilies: TList;
    FLastLoadTimeStamp: TDateTime;
    function GetCount: Integer;
    function GetItems(AIndex: Integer): TGetFileFamiliesOutputItem;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Load;
    property Count: Integer read GetCount;
    property Items[AIndex: Integer]: TGetFileFamiliesOutputItem read GetItems; default;
  end;

implementation

uses
  DBModule, VCSBase, JVCSTypes;

constructor TProject.Create;
begin
  inherited Create;

  Assigned := False;
  Name := '';
  ID := -1;
end;

procedure TProjects.Add(AItem: TProject);
begin
  FItems.Add(AItem);
end;

constructor TProjects.Create;
begin
  inherited Create;
  FItems := TList.Create;
  FLoaded := False;
end;

destructor TProjects.Destroy;
begin
  Clear;
  FItems.Free;
  inherited Destroy;
end;

procedure TProjects.Clear;
var
  I: Integer;
begin
  for I := 0 to GetItemCount -1 do
    Project[I].Free;
  FItems.Clear;
  FLoaded := False;
end;

function TProjects.GetProject(Index: Integer): TProject;
begin
  Result := TProject(FItems[Index]);
end;

function TProjects.GetProjectName(AID: Integer): string;
var
  I: Integer;
begin
  Result := 'not found';
  for I := 0 to ItemCount -1 do
    if Project[I].ID = AID then
    begin
      Result := Project[I].Name;
      Break;
    end;
end;

function TProjects.GetIsDeleted(AID: Integer): Boolean;
var
  I: Integer;
begin
  //only call for existing projectId!!!
  Result := False;
  for I := 0 to ItemCount -1 do
    if Project[I].ID = AID then
    begin
      Result := Project[I].Deleted;
      Break;
    end;
end;


function TProjects.GetItemCount: Integer;
begin
  Result := FItems.Count;
end;

procedure TProjects.Load(ADefaultAccessLevel: Integer = -1);
var
  NewProject: TProject;
  ProjectList: TJVCSGetProjectList;
  I, Idx: Integer;
  CurrentUserProjectRights: TProjectRightsList;
  Whoami: TJVCSWhoami;
  GetProjectRights: TJVCSGetProjectRights;
  ProjectAccessLevel: Integer;
begin
  if not FLoaded then
  begin
    CurrentUserProjectRights := TProjectRightsList.Create;
    try
      if ADefaultAccessLevel = -1 then
      begin
        Whoami := TJVCSWhoami.Create(nil);
        try
          DataModule1.ClientObjectSendRequest(Whoami);
          ADefaultAccessLevel := Whoami.AccessLevel;
        finally
          Whoami.Free;
        end;
      end;
      if ADefaultAccessLevel < 1 then
      begin
        GetProjectRights := TJVCSGetProjectRights.Create(nil);
        try
          DataModule1.ClientObjectSendRequest(GetProjectRights);
          for I := 0 to Pred(GetProjectRights.OutputItemCount) do
            if (GetProjectRights.OutputItems[I].UserID = ServerUserID) then
              CurrentUserProjectRights.AddOrReplace(GetProjectRights.OutputItems[I].ProjectID,
                GetProjectRights.OutputItems[I].AccessLevel);
        finally
          GetProjectRights.Free;
        end;
      end;
      ProjectList := TJVCSGetProjectList.Create(nil);
      try
        ProjectList.Purpose := '';
        ProjectList.IncludeDetails := False;
        DataModule1.ClientObjectSendRequest(ProjectList);

        with ProjectList do
          for I := 0 to OutputItemCount - 1 do
            if (not OutputItems[I].ProjectDeleted) then
            begin
              ProjectAccessLevel := ADefaultAccessLevel;
              Idx := CurrentUserProjectRights.IndexOf(OutputItems[I].ProjectID);
              if Idx <> -1 then
                ProjectAccessLevel := CurrentUserProjectRights[Idx].AccessLevel;
              if ProjectAccessLevel > 0 then
              begin
                NewProject := TProject.Create;
                NewProject.Name := OutputItems[I].ProjectName;
                NewProject.ID   := OutputItems[I].ProjectID;
                NewProject.Deleted := OutputItems[I].ProjectDeleted;
                Add(NewProject);
              end;
            end; // if not OutputItems[I].ProjectDeleted then
      finally
        ProjectList.Free;
      end;
    finally
      CurrentUserProjectRights.Free;
    end;
    FLoaded := True;
  end;
end;

constructor TRefreshProjects.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FInternalThread := TJVCSJobThread.Create(False);
  FInternalThread.OnJobException := HandleThreadException;
  FItems := TObjectList.Create;
  InitializeCriticalSection(FLock);
  FIsRefreshing := False;
  FLoaded := False;
  FLocked := False;
end;

destructor TRefreshProjects.Destroy;
begin
  FInternalThread.Free;
  FItems.Free;
  DeleteCriticalSection(FLock);
  inherited Destroy;
end;

function TRefreshProjects.GetCount: Integer;
begin
  Result := 0;
  if FLocked then
    Result := FItems.Count;
end;

function TRefreshProjects.GetItems(AIndex: Integer): TProject;
begin
  Result := nil;
  if FLocked then
    Result := TProject(FItems[AIndex]);
end;

procedure TRefreshProjects.HandleThreadException(Sender: TObject; E: Exception; var AHandled: Boolean);
begin
  //keep in sync with TJVCSDockableForm.HandleThreadException in JVCSDockForm.pas
  if (E is EJVCSClientRequestError) and (EJVCSClientRequestError(E).StatusCode = 403) then
    AHandled := True;
end;

procedure TRefreshProjects.LoadSynchron;
var
  InternalProjects: TProjects;
  LProject: TProject;
  I: Integer;
begin
  InternalProjects := TProjects.Create;
  try
    InternalProjects.Load;
    Lock;
    try
      FItems.Clear;
      for I := 0 to Pred(InternalProjects.ItemCount) do
      begin
        LProject := TProject.Create;
        LProject.Name := InternalProjects[I].Name;
        LProject.ID := InternalProjects[I].ID;
        LProject.Assigned := InternalProjects[I].Assigned;
        FItems.Add(LProject);
      end;
    finally
      Unlock;
    end;
    FLoaded := True;
  finally
    InternalProjects.Free;
  end;
end;

procedure TRefreshProjects.Lock;
begin
  EnterCriticalSection(FLock);
  FLocked := True;
end;

const
  cThreadActionClearProjects = 1;
  cThreadActionLoadProjects = 2;

procedure TRefreshProjects.SimpleRefresh(ARefreshType: TJVCSRefreshType);
begin
  case ARefreshType of
    rtConnected, rtRefresh:
      begin
        FInternalThread.DisqueueAndAbortAllJobsAndWait;
        FInternalThread.AddJob(ThreadRefresh, Pointer(cThreadActionLoadProjects));
      end;
    rtDisconnected:
      begin
        FInternalThread.DisqueueAndAbortAllJobsAndWait;
        FInternalThread.AddJob(ThreadRefresh, Pointer(cThreadActionClearProjects));
      end;
  end;
end;

procedure TRefreshProjects.ThreadRefresh(AThreadJob: TJVCSThreadJob);
var
  InternalProjects: TProjects;
  LProject: TProject;
  I: Integer;
begin
  if not FIsRefreshing then
  begin
    FIsRefreshing := True;
    try
      if Integer(AThreadJob.Parameter) = cThreadActionClearProjects then
      begin
        if (not AThreadJob.Aborted) and FLocked then
          Sleep(1);
        if not AThreadJob.Aborted then
        begin
          Lock;
          try
            FItems.Clear;
            FLoaded := False;
          finally
            Unlock;
          end;
        end;
      end
      else
      if (ServerUserID > 0) and (Integer(AThreadJob.Parameter) = cThreadActionLoadProjects) then
      begin
        if not FLoaded then
        begin
          InternalProjects := TProjects.Create;
          try
            InternalProjects.Load;

            if (not AThreadJob.Aborted) and FLocked then
              Sleep(1);
            if not AThreadJob.Aborted then
            begin
              Lock;
              try
                FItems.Clear;
                for I := 0 to Pred(InternalProjects.ItemCount) do
                begin
                  LProject := TProject.Create;
                  LProject.Name := InternalProjects[I].Name;
                  LProject.ID := InternalProjects[I].ID;
                  LProject.Assigned := InternalProjects[I].Assigned;
                  FItems.Add(LProject);
                end;
              finally
                Unlock;
              end;
              FLoaded := True;
            end;
          finally
            InternalProjects.Free;
          end;
        end;
      end;
    finally
      FIsRefreshing := False;
    end;
  end;
end;

procedure TRefreshProjects.Unlock;
begin
  LeaveCriticalSection(FLock);
  FLocked := False;
end;

constructor TModuleStateDataList.Create;
begin
  inherited Create;
  FArchiveTimeStamp := 0;
  FModuleNameToIDList := TModuleNameToIDList.Create;
  FModuleStateList := TModuleStateList.Create;
end;

destructor TModuleStateDataList.Destroy;
begin
  FModuleNameToIDList.Free;
  FModuleStateList.Free;
  inherited Destroy;
end;

procedure TModuleStateDataList.Clear;
begin
  FModuleNameToIDList.Clear;
  FModuleStateList.Clear;
end;

function TModuleStateDataList.GetArchiveTimeStamp: TDateTime;
var
  GetArchiveTstamp: TJVCSGetArchiveTstamp;
begin
  GetArchiveTstamp := TJVCSGetArchiveTstamp.Create(nil);
  try
    DataModule1.ClientObjectSendRequest(GetArchiveTstamp);
    Result := GetArchiveTstamp.Timestamp;
  finally
    GetArchiveTstamp.Free;
  end;
end;

function TModuleStateDataList.GetModuleID(AModuleName: string): Integer;
var
  GetModuleIdObj: TJVCSGetModuleId;
begin
  GetModuleIdObj := TJVCSGetModuleId.Create(nil);
  try
    GetModuleIdObj.ModuleName := AModuleName;
    DataModule1.ClientObjectSendRequest(GetModuleIdObj);
    Result := GetModuleIdObj.ModuleID;
  finally
    GetModuleIdObj.Free;
  end;
end;

function TModuleStateDataList.GetModuleState(AModuleID: Integer; var ACheckedOut: Boolean;
  var AUserID: Integer): Boolean;
var
  GetRevisionListById: TJVCSGetRevisionListById;
  LastIdx: Integer;
begin
  GetRevisionListById := TJVCSGetRevisionListById.Create(nil);
  try
    GetRevisionListById.ModuleID := AModuleID;
    GetRevisionListById.ProjectID := 0;
    DataModule1.ClientObjectSendRequest(GetRevisionListById);
    Result := GetRevisionListById.OutputItemCount > 0;
    if Result then
    begin
      LastIdx := Pred(GetRevisionListById.OutputItemCount);
      ACheckedOut := GetRevisionListById.OutputItems[LastIdx].CheckedOut;
      AUserID := GetRevisionListById.OutputItems[LastIdx].UserID;
    end;
  finally
    GetRevisionListById.Free;
  end;
end;

function TModuleStateDataList.GetStateByName(AModuleName: string): TModuleStateRec;
var
  CurrentArchiveTimeStamp: TDateTime;
  ReadedArchiveTimeStamp: Boolean;

  function GetCurrentArchiveTimeStamp: TDateTime;
  begin
    if not ReadedArchiveTimeStamp then
    begin
      CurrentArchiveTimeStamp := GetArchiveTimeStamp;
      ReadedArchiveTimeStamp := True;
    end;
    Result := CurrentArchiveTimeStamp;
  end;

  function IsTimedOut(ATime: TDateTime): Boolean;
  begin
    Result := (Now - ATime) * 86400 < 0.1;
  end;

var
  Idx, ModuleID: Integer;
  ModuleCheckedOut: Boolean;
  ModuleUserID: Integer;
begin
  with Result do
  begin
    LastAccess := 0;
    ModuleID := 0;
    CheckedOut := False;
    UserID := 0;
  end;

  CurrentArchiveTimeStamp := 0;
  ReadedArchiveTimeStamp := False;

  Idx := FModuleNameToIDList.IndexOf(AModuleName);
  //there is no need to check the archive timestamp because the module ID won't change
  if (Idx <> -1){ and (IsTimedOut(FModuleNameToIDList[Idx].LastAccess) or
    (FArchiveTimeStamp = GetCurrentArchiveTimeStamp))} then
  begin
    ModuleID := FModuleNameToIDList[Idx].ModuleID;
    if ReadedArchiveTimeStamp then
      FModuleNameToIDList.UpdateLastAccessIdx(Idx);
  end
  else
  begin
    ModuleID := GetModuleID(AModuleName);
    FModuleNameToIDList.AddOrReplace(AModuleName, ModuleID);
  end;

  if ModuleID <> 0 then
  begin
    Idx := FModuleStateList.IndexOf(ModuleID);
    if (Idx <> -1) and (IsTimedOut(FModuleNameToIDList[Idx].LastAccess) or
      (FArchiveTimeStamp = GetCurrentArchiveTimeStamp)) then
    begin
      Result := FModuleStateList[Idx];
      if ReadedArchiveTimeStamp then
        FModuleStateList.UpdateLastAccessIdx(Idx);
    end
    else
    begin
      FModuleStateList.Clear;
      if GetModuleState(ModuleID, ModuleCheckedOut, ModuleUserID) then
      begin
        FModuleStateList.AddOrReplace(ModuleID, ModuleCheckedOut, ModuleUserID);
        Idx := FModuleStateList.IndexOf(ModuleID);
        Result := FModuleStateList[Idx];
      end;
    end;
  end;

  if ReadedArchiveTimeStamp then
    FArchiveTimeStamp := CurrentArchiveTimeStamp;
end;

constructor TMostSevereBugsDataList.Create;
begin
  inherited Create;
  FMostSevereBugsList := TMostSevereBugsList.Create;
end;

destructor TMostSevereBugsDataList.Destroy;
begin
  FMostSevereBugsList.Free;
  inherited Destroy;
end;

procedure TMostSevereBugsDataList.Clear;
begin
  FMostSevereBugsList.Clear;
end;

function TMostSevereBugsDataList.GetItemSeverity(AItemID: Integer): Integer;
var
  Idx: Integer;
begin
  Result := -1;
  Idx := FMostSevereBugsList.IndexOf(AItemID);
  if Idx <> -1 then
    Result := FMostSevereBugsList[Idx].Severity;
end;

procedure TMostSevereBugsDataList.InternalLoad(AModuleBased: Boolean);
var
  GetMostSevereBugs: TJVCSGetMostSevereBugs;
  I: Integer;
begin
  Clear;
  GetMostSevereBugs := TJVCSGetMostSevereBugs.Create(nil);
  try
    GetMostSevereBugs.ModuleBased := AModuleBased;
    DataModule1.ClientObjectSendRequest(GetMostSevereBugs);
    with GetMostSevereBugs do
      for I := 0 to Pred(OutputItemCount) do
        FMostSevereBugsList.AddOrReplace(OutputItems[I].ItemID, OutputItems[I].BugID,
          OutputItems[I].Severity);
  finally
    GetMostSevereBugs.Free;
  end;  
end;

procedure TMostSevereBugsDataList.LoadMostSevereModuleBugs;
begin
  InternalLoad(True);
end;

procedure TMostSevereBugsDataList.LoadMostSevereProjectBugs;
begin
  InternalLoad(False);
end;

constructor TFileFamilyList.Create;
begin
  inherited Create;
  FFileFamilies := TList.Create;
  FLastLoadTimeStamp := 0;
end;

destructor TFileFamilyList.Destroy;
begin
  Clear;
  FFileFamilies.Free;
  inherited Destroy;
end;

procedure TFileFamilyList.Clear;
var
  I: Integer;
begin
  FLastLoadTimeStamp := 0;
  for I := 0 to Pred(FFileFamilies.Count) do
    Dispose(PGetFileFamiliesOutputItem(FFileFamilies[I]));
  FFileFamilies.Clear;
end;

function TFileFamilyList.GetCount: Integer;
begin
  Result := FFileFamilies.Count;
end;

function TFileFamilyList.GetItems(AIndex: Integer): TGetFileFamiliesOutputItem;
begin
  Result := PGetFileFamiliesOutputItem(FFileFamilies[AIndex])^;
end;

procedure TFileFamilyList.Load;
var
  I: Integer;
  GetFileFamilies: TJVCSGetFileFamilies;
  FileFamilyPtr: PGetFileFamiliesOutputItem;
begin
  if (Now - FLastLoadTimeStamp) > 5/86400 then
  begin
    Clear;
    GetFileFamilies := TJVCSGetFileFamilies.Create(nil);
    try
      GetFileFamilies.IncludeDescription := False;
      DataModule1.ClientObjectSendRequest(GetFileFamilies);
      for I := 0 to Pred(GetFileFamilies.OutputItemCount) do
      begin
        New(FileFamilyPtr);
        FFileFamilies.Add(FileFamilyPtr);
        FileFamilyPtr^ := GetFileFamilies.OutputItems[I];
      end;
    finally
      GetFileFamilies.Free;
    end;
    FLastLoadTimeStamp := Now;
  end;
end;

end.
