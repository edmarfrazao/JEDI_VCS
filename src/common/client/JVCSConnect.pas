(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: FVCSConnect.pas

The Initial Developer of the original Code (JEDI FreeVCS) is:
  Ondrej Kelle (tondrej@t-online.de)
Code move to JEDI VCS: Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Purpose:
  This unit contains TJVCSConnection class which encapsulates the connection to
  the JEDI VCS MidWare appserver.

Last Modified: see History

Known Issues:
ToDo
- remove IFDEF's and not longer used code parts if there are no problems with
  Clientdispatcher and internal clientobject execution
- use constant for ClientVersion instead of the hardcoded value 239 in
  TJVCSConnection.InternalClientObjCreate
-----------------------------------------------------------------------------

Unit history(JEDI FreeVCS):

2002/05/11  TOndrej    - Initial implementation and commenting
2002/05/17  TOndrej    - Login will raise an exception if not accepted (invalid
                         user name or password)
                       - Added connection statistics: number of requests processed,
                         bytes sent, bytes received
2002/06/09  TOndrej    - Fixed bug in SendRequest: client object instance's
                         FUserData was not updated
2002/07/19  TOndrej    - Added ServerTimeZone property
2002/07/18  TOndrej    - Added UserID, TransactionID properties

Unit history(JEDI VCS):

2003/02/23  THuber     changed in FVCSConnect.pas !
                       - IsFileDirty now uses TZhandling functions to be GMT aware (bug fix)
                       - bugfix: Login failed if user was same as password
2003/10/23  USchuster  - 1st Migrationstep from JEDI FreeVCS code to JEDI VCS
                       - renamed to JVCSConnect.pas
                       - changed ...FVCS... into ...JVCS... except the
                         encryption stuff
                       - changed ClientVersion from 220 to 239
2003/11/30  USchuster  - changes for usage in GUI client
2003/12/22  USchuster  - improved performance with an optional dispatcher
                         (use define USECLIENTDISPATCHER for now to enable it)
2003/12/27  THuber     - fixed problem loading FVCSCrypt from IDE
                       - CryptDLLName now in JVCSClientConsts
2003/12/27  USchuster  - fixed minor problems with clientdispatcher
2004/01/09  USchuster  - clientobjects will now be internally executed (by default)
                         which should be threadsafe and not long over TResponseBroker
                       - fixed bug when crypt-DLL wasn't found
2008/11/15  USchuster  - changes for TJVCSConnection.SupportsFunction
                       - minor style cleaning
2009/01/01  USchuster  - changes for D2009
2010/01/23  USchuster  - added TJVCSConnection.SupportsFunctionCode 

-----------------------------------------------------------------------------*)

unit JVCSConnect;

{$I jedi.inc}
{$I compopt.inc}

{$DEFINE USECLIENTDISPATCHER}
{$DEFINE INTERNALOBJECTEXECUTION}

interface

uses
  Classes, SysUtils, ApsCli, CBroker, JVCSTypes, JVCSClientObjBase
  {$IFDEF USECLIENTDISPATCHER}
  , JVCSClientDispatcher
  {$ENDIF USECLIENTDISPATCHER}
  ;

type
  TJVCSConnection = class(TComponent)
  private
    FAppSrvClient: TAppSrvClient;
    FBytesReceived: Int64;
    FBytesSent: Int64;
    {$IFNDEF INTERNALOBJECTEXECUTION}
    FInstance: TJVCSClientObject;
    {$ENDIF ~INTERNALOBJECTEXECUTION}
    FLoginMessage: string;
    FLoginTime: TDateTime;
    {$IFNDEF INTERNALOBJECTEXECUTION}
    FResponseBroker: TResponseBroker;
    {$ENDIF ~INTERNALOBJECTEXECUTION}
    {$IFDEF USECLIENTDISPATCHER}
    FClientDispatcher: TJVCSClientDispatcher;
    {$ENDIF USECLIENTDISPATCHER}
    FRequestCount: Int64;
//THu    FServerTimeZone: TDateTime;
    FServerType: string;
    FStreamedActive: Boolean;
    FUserData: TUserData;
    FUserName: string;
    FUserPassword: string;

    FOnRequestStart: TNotifyEvent;
    FOnRequestEnd: TNotifyEvent;

    FSupportedFunctions: TStringList;
    FSupportedFunctionsReaded: Boolean;

    function GetServer: string;
    function GetStatistics(Index: Integer): Int64;
    function GetPort: string;
    function GetUserData(Index: Integer): Integer;
    procedure InternalClientObjCreate(Sender: TObject; ClientObject: TClientObject);
    {$IFDEF USECLIENTDISPATCHER}
    procedure InternalClientObjDestroy(Sender: TObject; ClientObject: TClientObject);
    {$ENDIF USECLIENTDISPATCHER}
    {$IFDEF INTERNALOBJECTEXECUTION}
    procedure InternalExecuteObject(ClientObject: TClientObject);
    {$ENDIF INTERNALOBJECTEXECUTION}
    procedure InternalRequestDone(Sender: TObject; Error: Integer);
    procedure InternalSendRequest(const FunctionCode: string);
    procedure ReadSupportedFunctions;
    procedure SetServer(const Value: string);
    procedure SetPort(const Value: string);
    procedure SetUserName(const Value: string);
    procedure SetUserPassword(const Value: string);
  protected
    FServerVersion: Integer;
    procedure ClearLoginInfo; virtual;
    function GetActive: Boolean;
    procedure SetActive(Value: Boolean); virtual;
    procedure SetTransactionID(const Value: Integer);
    procedure SetUserID(const Value: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Loaded; override;
    procedure SendRequest(AnInstance: TJVCSClientObject);
    function SupportsFunction(const AClass: TClientObjectClass): Boolean;
    function SupportsFunctionCode(const AFunctionCode: string): Boolean;

    property TransactionID: Integer index 1 read GetUserData;
    property UserID: Integer index 0 read GetUserData;
  published
    property Active: Boolean read GetActive write SetActive;
    property BytesSent: Int64 index 0 read GetStatistics;
    property BytesReceived: Int64 index 1 read GetStatistics;
    property LoginMessage: string read FLoginMessage;
    property LoginTime: TDateTime read FLoginTime;
    property Server: string read GetServer write SetServer;
//THu    property ServerTimeZone: TDateTime read FServerTimeZone;
    property ServerType: string read FServerType;
    property ServerVersion: Integer read FServerVersion;
    property Port: string read GetPort write SetPort;
    property RequestCount: Int64 index 2 read GetStatistics;
    property UserName: string read FUserName write SetUserName;
    property UserPassword: string read FUserPassword write SetUserPassword;

    property OnRequestEnd: TNotifyEvent read FOnRequestEnd write FOnRequestEnd;
    property OnRequestStart: TNotifyEvent read FOnRequestStart write FOnRequestStart;
  end;

implementation

uses
  Windows,
  {$IFDEF OVERBYTEV6_UP}
  OverbyteIcsWSocket,
  {$ELSE}
  WSocket,
  {$ENDIF OVERBYTEV6_UP}
  TZHandling,
  JVCSClientConsts,
  JVCSCrypt,
  JVCSClientFunctions,
  JVCSClientObj,
  JVCSNewClientObj;

type
  THackClientObject = class(TClientObject);

{ TJVCSConnection private }

procedure TJVCSConnection.ClearLoginInfo;
begin
  FUserData.UserID := -1;
  FUserData.TransactionID := -1;
  FLoginTime := 0;
  FLoginMessage := '';
//THu  FServerTimeZone := 0;
  FServerType := '';
  FServerVersion := -1;

  FBytesReceived := 0;
  FBytesSent := 0;
  FRequestCount := 0;
  FSupportedFunctionsReaded := False;
  {$IFDEF USECLIENTDISPATCHER}
  FClientDispatcher.KillUnusedClients;
  {$ENDIF USECLIENTDISPATCHER}
end;

function TJVCSConnection.GetActive: Boolean;
begin
  with FUserData do
    Result := (UserID <> -1) and (TransactionID <> -1);
end;

function TJVCSConnection.GetServer: string;
begin
  Result := FAppSrvClient.Server;
end;

function TJVCSConnection.GetStatistics(Index: Integer): Int64;
begin
  case Index of
    0:
      Result := FBytesSent;
    1:
      Result := FBytesReceived;
    2:
      Result := FRequestCount;
    else
      Result := 0;
  end;
end;

function TJVCSConnection.GetPort: string;
begin
  Result := FAppSrvClient.Port;
end;

function TJVCSConnection.GetUserData(Index: Integer): Integer;
begin
  case Index of
    0:
      Result := FUserData.UserID;
    1:
      Result := FUserData.TransactionID;
    else
      Result := -1;
  end;
end;

procedure TJVCSConnection.InternalClientObjCreate(Sender: TObject; ClientObject: TClientObject);
{$IFDEF USECLIENTDISPATCHER}
var
  NewAppSrvClient: TJVCSAppSrvClient;
  HackedClientObject: THackClientObject;
{$ENDIF USECLIENTDISPATCHER}  
begin
  if ClientObject is TJVCSLogin then
    with TJVCSLogin(ClientObject) do
    begin
      UserName := FUserName;
      UserPassword := FUserPassword;
      ClientVersion := 239;
      //THu ClientTimestamp := FLoginTime;
      (*
         Use (local) servertime from GET_SERVER_TIME for Login.
      *)
      ServerTimestamp := FLoginTime;
    end
  else
  if ClientObject is TJVCSLogout then
    with TJVCSLogout(ClientObject) do
      UserID := FUserData.UserID;
  {$IFDEF USECLIENTDISPATCHER}
  if Assigned(ClientObject) then
  begin
    HackedClientObject := THackClientObject(ClientObject);
    NewAppSrvClient := FClientDispatcher.GetJVCSAppSrvClient;
    NewAppSrvClient.FunctionCode:= HackedClientObject.FFunctionCode;
    NewAppSrvClient.Answer:= HackedClientObject.FResponseBuffer;
    NewAppSrvClient.OnRequestDone:= HackedClientObject.RequestDone;
    NewAppSrvClient.OnSocksError:= HackedClientObject.SocksError;
    HackedClientObject.FAppSrvClient.Free;
    HackedClientObject.FAppSrvClient := NewAppSrvClient;
  end;
  if ClientObject is TJVCSLogin then
    Sleep(1);
  {$ENDIF USECLIENTDISPATCHER}
end;

{$IFDEF USECLIENTDISPATCHER}
procedure TJVCSConnection.InternalClientObjDestroy(Sender: TObject; ClientObject: TClientObject);
begin
  if Assigned(ClientObject) and Assigned(ClientObject.AppSrvClient) and
    (ClientObject.AppSrvClient is TJVCSAppSrvClient) then
  begin
    TJVCSAppSrvClient(ClientObject.AppSrvClient).Busy := False;
    THackClientObject(ClientObject).FAppSrvClient := nil;
  end;
end;
{$ENDIF USECLIENTDISPATCHER}

procedure TJVCSConnection.InternalRequestDone(Sender: TObject; Error: Integer);
{$IFDEF INTERNALOBJECTEXECUTION}
var
  ClientObject: TClientObject;
{$ENDIF INTERNALOBJECTEXECUTION}
begin
  Inc(FRequestCount);
  with (Sender as TClientObject), AppSrvClient do
  begin
    Inc(FBytesSent, RequestHeaderLen + RequestBodyLen);
    if Assigned(Answer) then
      Inc(FBytesReceived, Answer.HeaderSize + Answer.DataBufferSize);
  end;

  {$IFNDEF INTERNALOBJECTEXECUTION}
  if Assigned(FInstance) then
    FInstance.CopyFromReference(TClientObject(Sender));
  {$ELSE}
  ClientObject := Sender as TClientObject;
  THackClientObject(ClientObject).FAnswerArrived := True;
  ClientObject.ProcessRequest(Sender, Error);
  {$ENDIF ~INTERNALOBJECTEXECUTION}

  if Sender is TJVCSGetServerTime then
    with TJVCSGetServerTime(Sender) do
    begin
      // used for password encryption in login !
      FLoginTime := ServerTime;
//THu      FServerTimeZone := LocalGMTDiff;
    end
  else
  if Sender is TJVCSLogin then
    with TJVCSLogin(Sender) do
    begin
      if Accepted then
      begin
        FUserData.UserID := UserID;
        FUserData.TransactionID := TransactionID;
        FServerType := ServerType;
        FServerVersion := ServerVersion;
        FLoginMessage := LoginMessage;
      end
      else
      begin
        ClearLoginInfo;
        raise EJVCSClient.Create(LoginMessage);
      end;
    end
  else
  if Sender is TJVCSLogout then
    ClearLoginInfo
  else
  if Sender is TJVCSGetProjectId then
    with TJVCSGetProjectId(Sender) do
      FUserData.TransactionID := TransactionID;
  if Assigned(FOnRequestEnd) then
    FOnRequestEnd(Self);
end;

procedure TJVCSConnection.InternalSendRequest(const FunctionCode: string);
{$IFDEF INTERNALOBJECTEXECUTION}
var
  GetServerTime: TJVCSGetServerTime;
  Login: TJVCSLogin;
  Logout: TJVCSLogout;
{$ENDIF INTERNALOBJECTEXECUTION}
begin
  {$IFNDEF INTERNALOBJECTEXECUTION}
  if Assigned(FOnRequestStart) then
    FOnRequestStart(Self);
  FResponseBroker.SendRequest(FunctionCode, InternalRequestDone, False);
  {$ELSE}
  if FunctionCode = 'GET_SERVER_TIME' then
  begin
    GetServerTime := TJVCSGetServerTime.Create(nil);
    try
      InternalExecuteObject(GetServerTime);
    finally
      GetServerTime.Free;
    end;
  end
  else
  if FunctionCode = 'LOGIN' then
  begin
    Login := TJVCSLogin.Create(nil);
    try
      InternalExecuteObject(Login);
    finally
      Login.Free;
    end;
  end
  else
  if FunctionCode = 'LOGOUT' then
  begin
    Logout := TJVCSLogout.Create(nil);
    try
      InternalExecuteObject(Logout);
    finally
      Logout.Free;
    end;
  end;
  {$ENDIF ~INTERNALOBJECTEXECUTION}
end;

procedure TJVCSConnection.ReadSupportedFunctions;
var
  GetSupportedFunctions: TJVCSGetSupportedFunctions;
  I: Integer;
begin
  if not FSupportedFunctionsReaded then
  begin
    FSupportedFunctions.Clear;
    FSupportedFunctionsReaded := True;
    if ServerVersion >= 250 then
    begin
      GetSupportedFunctions := TJVCSGetSupportedFunctions.Create(nil);
      try
        try
          SendRequest(GetSupportedFunctions);
          for I := 0 to Pred(GetSupportedFunctions.OutputItemCount) do
            FSupportedFunctions.Add(GetSupportedFunctions.OutputItems[I].FunctionName);
        except
        //todo check exception
        end;
      finally
        GetSupportedFunctions.Free;
      end;
    end;
  end;
end;

procedure TJVCSConnection.SetActive(Value: Boolean);
begin
  if Value <> GetActive then
  begin
    if Value then
    begin
      if csLoading in ComponentState then
        FStreamedActive := True
      else
      begin
        ClearLoginInfo;
        InternalSendRequest('GET_SERVER_TIME');
        InternalSendRequest('LOGIN');
      end;
    end
    else
      InternalSendRequest('LOGOUT');
  end;
end;

procedure TJVCSConnection.SetServer(const Value: string);
begin
  if AnsiCompareText(Value, GetServer) <> 0 then
  begin
    SetActive(False);
    FAppSrvClient.Server := Value;
  end;
end;

procedure TJVCSConnection.SetPort(const Value: string);
begin
  if AnsiCompareText(Value, GetPort) <> 0 then
  begin
    SetActive(False);
    FAppSrvClient.Port := Value;
  end;
end;

procedure TJVCSConnection.SetUserName(const Value: string);
begin
  if Value <> FUserName then
  begin
    SetActive(False);
    FUserName := Value;
  end;
end;

procedure TJVCSConnection.SetUserPassword(const Value: string);
begin
  if Value <> FUserPassword then
  begin
    SetActive(False);
    FUserPassword := Value;
  end;
end;

{ TJVCSConnection protected }

procedure TJVCSConnection.SetTransactionID(const Value: Integer);
begin
  FUserData.TransactionID := Value;
end;

procedure TJVCSConnection.SetUserID(const Value: Integer);
begin
  FUserData.UserID := Value;
end;

{ TJVCSConnection public }

constructor TJVCSConnection.Create(AOwner: TComponent);
var
  sCryptDLLFileName: string;
begin
  inherited Create(AOwner);
  FStreamedActive := False;
  {$IFDEF USECLIENTDISPATCHER}
  //USc 09.01.2004 should be created before ClearLoginInfo is called because it's used there
  FClientDispatcher := TJVCSClientDispatcher.Create;
  {$ENDIF USECLIENTDISPATCHER}
  //USc 09.01.2004 should be done before raising the dll-exception otherwise an exception
  //  will be raised in .Destroy/SetActive and the user won't get the dll-exception
  ClearLoginInfo;
  //try to load the crypt-DLL
  sCryptDLLFileName := GetSelfFileLocation + cCryptDLLName;
  if not LoadFVCSCrypt(sCryptDLLFileName) then
    raise EJVCSClient.CreateFmt(SDLLError, [sCryptDLLFileName]);
  {$IFNDEF INTERNALOBJECTEXECUTION}
  FInstance := nil;
  {$ENDIF ~INTERNALOBJECTEXECUTION}
  FAppSrvClient := TAppSrvClient.Create(nil);
  FAppSrvClient.SocksAuthentication := socksNoAuthentication;
  {$IFNDEF INTERNALOBJECTEXECUTION}
  FResponseBroker := TResponseBroker.Create(nil);
  FResponseBroker.UserData := Integer(@FUserData);
  FResponseBroker.Options := [];
  FResponseBroker.AppSrvClient := FAppSrvClient;
  FResponseBroker.OnObjCreate := InternalClientObjCreate;
  {$IFDEF USECLIENTDISPATCHER}
  FResponseBroker.OnObjDestroy := InternalClientObjDestroy;
  {$ENDIF USECLIENTDISPATCHER}
  FResponseBroker.AddClientObject(TJVCSLogin);
  FResponseBroker.AddClientObject(TJVCSLogout);

  FResponseBroker.AddClientObject(TJVCSWhoami);
  FResponseBroker.AddClientObject(TJVCSGetServerOptions);
  FResponseBroker.AddClientObject(TJVCSSetServerOptions);
  FResponseBroker.AddClientObject(TJVCSGetProjectRights);
  FResponseBroker.AddClientObject(TJVCSSetProjectRights);
  FResponseBroker.AddClientObject(TJVCSGetUserList);
  FResponseBroker.AddClientObject(TJVCSGetUsers);
  FResponseBroker.AddClientObject(TJVCSAddUpdateUser);
  FResponseBroker.AddClientObject(TJVCSChangePassword);
  FResponseBroker.AddClientObject(TJVCSRemoveUser);
  FResponseBroker.AddClientObject(TJVCSGetServerTime);
  FResponseBroker.AddClientObject(TJVCSGetServerLog);
  FResponseBroker.AddClientObject(TJVCSClearServerLog);
  FResponseBroker.AddClientObject(TJVCSGetArchiveTstamp);
  FResponseBroker.AddClientObject(TJVCSGetProjectId);
  FResponseBroker.AddClientObject(TJVCSGetProjectRight);
  FResponseBroker.AddClientObject(TJVCSSearchModules);
  FResponseBroker.AddClientObject(TJVCSGetDesertedModules);
  FResponseBroker.AddClientObject(TJVCSGetSpaceByProjects);
  FResponseBroker.AddClientObject(TJVCSGetSpaceByModules);
  FResponseBroker.AddClientObject(TJVCSLiveBackup);
  FResponseBroker.AddClientObject(TJVCSPurgeProject);
  //FResponseBroker.AddClientObject(TJVCSExecuteSql);
  FResponseBroker.AddClientObject(TJVCSReadConfigData);
  FResponseBroker.AddClientObject(TJVCSWriteConfigData);
  FResponseBroker.AddClientObject(TJVCSGetProjectModuleList);
  FResponseBroker.AddClientObject(TJVCSGetBlankModuleList);
  FResponseBroker.AddClientObject(TJVCSGetSharedBy);
  FResponseBroker.AddClientObject(TJVCSAddNewProject);
  FResponseBroker.AddClientObject(TJVCSRemoveProject);
  FResponseBroker.AddClientObject(TJVCSRestoreProject);
  FResponseBroker.AddClientObject(TJVCSGetProjectReferences);
  FResponseBroker.AddClientObject(TJVCSAddUpdateProjectReferences);
  FResponseBroker.AddClientObject(TJVCSRemoveProjectReferences);
  FResponseBroker.AddClientObject(TJVCSGetProjectInformation);
  FResponseBroker.AddClientObject(TJVCSGetProjectList);
  FResponseBroker.AddClientObject(TJVCSGetVersionList);
  FResponseBroker.AddClientObject(TJVCSGetRevisionList);
  FResponseBroker.AddClientObject(TJVCSGetLatestRevisions);
  FResponseBroker.AddClientObject(TJVCSGetVersionRevision);
  FResponseBroker.AddClientObject(TJVCSGetRollbackRevisions);
  FResponseBroker.AddClientObject(TJVCSGetLockedModules);
  FResponseBroker.AddClientObject(TJVCSRenameProject);
  FResponseBroker.AddClientObject(TJVCSAddUpdateProjectGroup);
  FResponseBroker.AddClientObject(TJVCSRemoveProjectGroup);
  FResponseBroker.AddClientObject(TJVCSGetProjectGroupInformation);
  FResponseBroker.AddClientObject(TJVCSAddRemoveProjectToGroup);
  FResponseBroker.AddClientObject(TJVCSGetModuleId);
  FResponseBroker.AddClientObject(TJVCSGetModuleName);
  FResponseBroker.AddClientObject(TJVCSRenameModule);
  FResponseBroker.AddClientObject(TJVCSGetModulesLike);
  FResponseBroker.AddClientObject(TJVCSGetRevisionListByName);
  FResponseBroker.AddClientObject(TJVCSGetRevisionListById);
  FResponseBroker.AddClientObject(TJVCSGetRevisionListByVersion);
  FResponseBroker.AddClientObject(TJVCSGetRevisionStatus);
  FResponseBroker.AddClientObject(TJVCSGetRevisionComment);
  FResponseBroker.AddClientObject(TJVCSChangeRevisionComment);
  FResponseBroker.AddClientObject(TJVCSGetBlobStatus);
  FResponseBroker.AddClientObject(TJVCSGetModuleHistory);
  FResponseBroker.AddClientObject(TJVCSIsMemberOfProject);
  FResponseBroker.AddClientObject(TJVCSGetSingleBlob);
  FResponseBroker.AddClientObject(TJVCSGetSharedModules);
  FResponseBroker.AddClientObject(TJVCSAddNewModule);
  FResponseBroker.AddClientObject(TJVCSRemoveModule);
  FResponseBroker.AddClientObject(TJVCSRemoveRevision);
  FResponseBroker.AddClientObject(TJVCSRemoveVersion);
  FResponseBroker.AddClientObject(TJVCSMoveModule);
  FResponseBroker.AddClientObject(TJVCSGetCheckoutModule);
  FResponseBroker.AddClientObject(TJVCSCheckoutOnlyModule);
  FResponseBroker.AddClientObject(TJVCSUndoCheckoutModule);
  FResponseBroker.AddClientObject(TJVCSCheckinModule);
  FResponseBroker.AddClientObject(TJVCSHideUnhideModule);
  FResponseBroker.AddClientObject(TJVCSCopyRevision);
  FResponseBroker.AddClientObject(TJVCSMergeVerRevNr);
  FResponseBroker.AddClientObject(TJVCSReportProjectState);
  FResponseBroker.AddClientObject(TJVCSReportAllProjects);
  FResponseBroker.AddClientObject(TJVCSReportProjectBugs);
  FResponseBroker.AddClientObject(TJVCSReportMilestones);
  FResponseBroker.AddClientObject(TJVCSGetBugs);
  FResponseBroker.AddClientObject(TJVCSGetBugsByProject);
  FResponseBroker.AddClientObject(TJVCSGetBugsByModule);
  FResponseBroker.AddClientObject(TJVCSGetMostSevereBugs);
  FResponseBroker.AddClientObject(TJVCSAddUpdateBug);
  FResponseBroker.AddClientObject(TJVCSRemoveBug);
  FResponseBroker.AddClientObject(TJVCSAssignRemoveBug);
  FResponseBroker.AddClientObject(TJVCSEnableModuleProjectBug);
  FResponseBroker.AddClientObject(TJVCSBugsUsedBy);
  FResponseBroker.AddClientObject(TJVCSGetLabels);
  FResponseBroker.AddClientObject(TJVCSGetLabelsByProject);
  FResponseBroker.AddClientObject(TJVCSGetLabelsByRevision);
  FResponseBroker.AddClientObject(TJVCSGetFileFamilies);
  FResponseBroker.AddClientObject(TJVCSGetFamilyExtensions);
  FResponseBroker.AddClientObject(TJVCSGetMilestones);
  FResponseBroker.AddClientObject(TJVCSAddUpdateMilestones);
  FResponseBroker.AddClientObject(TJVCSRemoveMilestone);
  FResponseBroker.AddClientObject(TJVCSGetProjectMilestones);
  FResponseBroker.AddClientObject(TJVCSAssignProjectMilestone);
  FResponseBroker.AddClientObject(TJVCSRemoveProjectMilestone);
  FResponseBroker.AddClientObject(TJVCSFamilyUsedBy);
  FResponseBroker.AddClientObject(TJVCSAddUpdateLabel);
  FResponseBroker.AddClientObject(TJVCSAddUpdateFileFamilies);
  FResponseBroker.AddClientObject(TJVCSRemoveFileFamilies);
  FResponseBroker.AddClientObject(TJVCSRemoveLabel);
  FResponseBroker.AddClientObject(TJVCSAddRemoveRevisionLabel);
  FResponseBroker.AddClientObject(TJVCSLabelUsedBy);
  FResponseBroker.AddClientObject(TJVCSGetUpdateDescription);
  FResponseBroker.AddClientObject(TJVCSGetTodoFilter);
  FResponseBroker.AddClientObject(TJVCSAddUpdateTodoEntries);
  FResponseBroker.AddClientObject(TJVCSRemoveTodoEntries);
  FResponseBroker.AddClientObject(TJVCSGetTodoEntries);
  FResponseBroker.AddClientObject(TJVCSGetLogFilter);
  FResponseBroker.AddClientObject(TJVCSGetLogEntries);
  FResponseBroker.AddClientObject(TJVCSGetLogComment);
  FResponseBroker.AddClientObject(TJVCSRemoveLogEntries);
  FResponseBroker.AddClientObject(TJVCSAddLogEntries);
  {$ENDIF ~INTERNALOBJECTEXECUTION}
  FSupportedFunctions := TStringList.Create;
  FSupportedFunctions.Sorted := True;
  FSupportedFunctionsReaded := False;
end;

destructor TJVCSConnection.Destroy;
begin
  FSupportedFunctions.Free;
  SetActive(False);
  {$IFNDEF INTERNALOBJECTEXECUTION}
  FResponseBroker.Free;
  {$ENDIF ~INTERNALOBJECTEXECUTION}
  {$IFDEF USECLIENTDISPATCHER}
  FClientDispatcher.Free;
  {$ENDIF USECLIENTDISPATCHER}
  FAppSrvClient.Free;
  inherited Destroy;
end;

procedure TJVCSConnection.Loaded;
begin
  inherited Loaded;
  SetActive(FStreamedActive);
end;

{$IFDEF INTERNALOBJECTEXECUTION}
procedure TJVCSConnection.InternalExecuteObject(ClientObject: TClientObject);
var
  HackClientObject: THackClientObject;
begin
  HackClientObject := THackClientObject(ClientObject);
  HackClientObject.FUserData := Integer(@FUserData);
  if Assigned(FOnRequestStart) then
    FOnRequestStart(Self);
  InternalClientObjCreate(Self, HackClientObject);
  try
    HackClientObject.FOnDisplay := nil; //InternalDisplay;
    HackClientObject.FFuncRequestDone:= nil; //FuncRequestDone;
    HackClientObject.FOnRequestDone:= InternalRequestDone; //ClientObjectRequestDone;
    HackClientObject.FResponseBroker:= nil;
    HackClientObject.FUserData := Integer(@FUserData);
    HackClientObject.FIniFileName:= ''; //FIniFileName;
    if Assigned(HackClientObject.FAppSrvClient) then
    begin
      HackClientObject.FAppSrvClient.Port:= FAppSrvClient.Port;
      HackClientObject.FAppSrvClient.Server:= FAppSrvClient.Server;
      HackClientObject.FAppSrvClient.SocksServer:= FAppSrvClient.SocksServer;
      HackClientObject.FAppSrvClient.SocksPort:= FAppSrvClient.SocksPort;
      HackClientObject.FAppSrvClient.SocksUsercode:= FAppSrvClient.SocksUsercode;
      HackClientObject.FAppSrvClient.SocksPassword:= FAppSrvClient.SocksPassword;
      HackClientObject.FAppSrvClient.SocksAuthentication:= FAppSrvClient.SocksAuthentication;
    end;
    HackClientObject.Initialize;

    HackClientObject.FAnswerArrived:= False;
    HackClientObject.Execute;
  finally
    {$IFDEF USECLIENTDISPATCHER}
    InternalClientObjDestroy(Self, HackClientObject);
    {$ENDIF USECLIENTDISPATCHER}
  end;
end;
{$ENDIF INTERNALOBJECTEXECUTION}

procedure TJVCSConnection.SendRequest(AnInstance: TJVCSClientObject);
begin
  {$IFDEF INTERNALOBJECTEXECUTION}
  SetActive(True);
  InternalExecuteObject(AnInstance);
  {$ELSE}
  FInstance := AnInstance;
  try
    SetActive(True);
    THackClientObject(AnInstance).FUserData := Integer(@FUserData);
    FResponseBroker.AddClientObjectWithReference(TClientObjectClass(AnInstance.ClassType), FInstance);
    try
      InternalSendRequest(FInstance.FunctionCode);
    finally
      FResponseBroker.AddClientObject(TClientObjectClass(AnInstance.ClassType));
    end;
  finally
    FInstance := nil;
  end;
  {$ENDIF INTERNALOBJECTEXECUTION}
end;

function TJVCSConnection.SupportsFunction(const AClass: TClientObjectClass): Boolean;
var
  S: string;
begin
  ReadSupportedFunctions;
  if Assigned(AClass) and (FSupportedFunctions.Count > 0) then
  begin
    S := GetFunctionCode(AClass);
    Result := FSupportedFunctions.IndexOf(S) <> -1;
  end
  else
    Result := False;
end;

function TJVCSConnection.SupportsFunctionCode(const AFunctionCode: string): Boolean;
begin
  Result := FSupportedFunctions.IndexOf(AFunctionCode) <> -1;
end;

end.
