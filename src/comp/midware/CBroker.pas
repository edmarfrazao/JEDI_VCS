Unit CBroker;

{$ifdef FPC}
  {$MODE DELPHI}
{$endif}

Interface

uses
  SysUtils, Classes,
  {$IFNDEF NOFORMS}
  StdCtrls,
  {$ENDIF}
  {$IFDEF OVERBYTEV6_UP}
  OverbyteIcsWsocket,
  {$ELSE}
  WSocket,
  {$ENDIF}
  RFormat, ApsCli;

const
  CBrokerVersion      = 107;
  CopyRight : String  = ' TResponseBroker (c) 1998, 1999 F. Piette V1.07a ';
  ClientObjectVersion = CBrokerVersion;


Type
  TResponseBroker = class;
  EResponseBrokerException = class( Exception );

  TClientObject = class;
  TClientObjectClass = class of TClientObject;
  TCliDisplayEvent = procedure ( Sender: TObject; Msg: String ) of object;
  //
  // I strongly recommend you never used to WaitForAnswer,
  // instead try to find another solution !!!
  // PL 12/07/2003  Correction for bug in WaitForAnswer
  //  ClientObjectRequestDone is use in process for queue message, you can not destroy the component clientObject
  TClientObject = class( TComponent )
  protected
    FClientObjectClass: TClientObjectClass;

    FFunctionCode: String;
    FAppSrvClient: TAppSrvClient;
    FResponseBuffer: TMWBuffer;
    FOnSocksError: TSocksErrorEvent;
    FResultStatus: Integer;
    FErrorMsg: String;

    FAnswerArrived: Boolean;
    FResponseBroker: TResponseBroker;
    FOnDisplay: TCliDisplayEvent;
    FOnRequestDone: TRequestDone;
    FFuncRequestDone: TRequestDone;

    FUserData: LongInt;
    FIniFileName: String;

    // PL 12/07/2003 destruction of FAppSrvClient, this is to have notification for the destruction
    Procedure Notification(AComponent: TComponent; Operation: TOperation);Override;
    procedure SocksError(Sender : TObject; Error : Integer; Msg : String); virtual;
    procedure RequestDone( Sender: TObject; Error: integer ); virtual;
    procedure CopyFromReference( Reference: TClientObject ); virtual;
  public
    constructor Create( AOwner: TComponent ); override;
    destructor Destroy; override;
    procedure Execute; virtual;
    procedure Initialize; virtual;
    procedure BuildFunctionCode; virtual;
    procedure ProcessRequest( Sender: TObject; Error: integer ); virtual;
    procedure SetResponseFields( ResponseBuffer: TMWBuffer ); virtual;
    procedure Loaded; override;
    function  WaitForAnswer( TimeOut: integer ): boolean; virtual;

    Property AppSrvClient: TAppSrvClient
      read FAppSrvClient;
    Property OnSocksError: TSocksErrorEvent
      read  FOnSocksError write FOnSocksError;
    Property ResultStatus: integer
      read FResultStatus write FResultStatus default 400;
    Property ErrorMsg: String
      read FErrorMsg write FErrorMsg;
    Property OnRequestDone: TRequestDone
      read FOnRequestDone write FOnRequestDone;
  End;

  TClientObjectUNKNOWN = class( TClientObject )
  public
    procedure Execute; override;
  end;

  { The ResponseBroker maintains a TList with TDispatchObject }
  TDispatchObject = record
    FunctionCode : String;
    Initialized  : Boolean;
    ClientObject : TClientObjectClass;
    Reference    : TClientObject;
  end;
  PDispatchObject = ^TDispatchObject;

  TResponseBrokerOption = ( rboDisplayObjectCount );
  TResponseBrokerOptions = set of TResponseBrokerOption;
  TCliInstanciationEvent = procedure ( Sender: TObject; ClientObject: TClientObject ) of object;
  TEnumClientFunctions = function ( Sender: TObject; FunctionCode: String ): Boolean of object;

  TResponseBroker = class( TComponent )
  protected
    FOptions: TResponseBrokerOptions;
  {$IFNDEF NOFORMS}
    FDisplayMemo: TCustomMemo;
    FObjectCountLabel: TLabel;
  {$ENDIF}
    FObjectList: TList;
    FRunningList: TList;
    FObjectCount: Integer;

    FAppSrvClient: TAppSrvClient;
    FUserData: LongInt;
    FIniFileName: String;

    FOnDisplay: TCliDisplayEvent;
    FOnObjCreate: TCliInstanciationEvent;
    FOnObjDestroy: TCliInstanciationEvent;

    procedure Notification( AComponent: TComponent; operation: TOperation ); override;
    function  FindClientObject( FunctionCode: String ) : Integer;
    function  RemoveClientObject( FunctionCode: String ) : Integer;
    procedure ClientObjectRequestDone( Sender: TObject; Error: Integer );
    procedure TriggerObjCreate( ClientObject: TClientObject ); virtual;
    procedure TriggerObjDestroy( ClientObject: TClientObject ); virtual;
    procedure InternalDisplay( Sender: TObject; Msg : String );
    procedure Loaded; override;
    function  RemoveRunningObject( ClientObject: TClientObject ) : Boolean;
  public
    constructor Create( AOwner: TComponent ); override;
    destructor  Destroy; override;
    procedure   AddClientObject( ClientObjectClass: TClientObjectClass );
    procedure   AddClientObjectWithReference(
      ClientObjectClass: TClientObjectClass; ClientObjectInstance: TClientObject 
    );
    procedure   EnumClientFunctions( CallBack: TEnumClientFunctions );
    procedure   SendRequest( FunctionCode: String; FuncRequestDone: TRequestDone; WaitForAnswer: Boolean );

    Property    ObjectCount: Integer           
      read FObjectCount;
  published
    Property UserData: LongInt              
      read  FUserData
      write FUserData;
    Property IniFileName: String                  
      read FIniFileName write FIniFileName;
  {$IFNDEF NOFORMS}
    Property ObjectCountLabel: TLabel
      read FObjectCountLabel write FObjectCountLabel;
  {$ENDIF}
    Property Options: TResponseBrokerOptions
      read FOptions write FOptions;
  {$IFNDEF NOFORMS}
    Property DisplayMemo: TCustomMemo
      read FDisplayMemo write FDisplayMemo;
  {$ENDIF}
    Property OnDisplay: TCliDisplayEvent        
      read FOnDisplay write FOnDisplay;
    Property OnObjCreate: TCliInstanciationEvent 
      read FOnObjCreate write FOnObjCreate;
    Property OnObjDestroy: TCliInstanciationEvent 
      read FOnObjDestroy write FOnObjDestroy;
    Property AppSrvClient: TAppSrvClient       
      read FAppSrvClient write FAppSrvClient;
  end;

procedure Register;

Implementation

Uses
  Windows;

procedure Register;
begin
  RegisterComponents('FPiette', [TResponseBroker, TClientObject]);
end;

constructor TClientObject.Create( AOwner: TComponent );
begin
  inherited;

  FClientObjectClass:= TClientObjectClass( ClassType );
  FResponseBroker:= NIL;
  FOnDisplay:= NIL;

  FFuncRequestDone:= NIL;
  FOnRequestDone:= NIL;
  FUserData:= 0;
  FIniFileName:= '';

  BuildFunctionCode;

  FResponseBuffer:= TMWBuffer.Create( Self );
  FAppSrvClient:= TAppSrvClient.Create( Self );
  FAppSrvClient.FunctionCode:= FFunctionCode;
  FAppSrvClient.Answer:= FResponseBuffer;
  FAppSrvClient.OnRequestDone:= RequestDone;
  FAppSrvClient.OnSocksError:= SocksError;
end;

destructor TClientObject.Destroy;
begin
  If Assigned(FAppSrvClient) Then Begin
    FAppSrvClient.Answer:= NIL;
    FAppSrvClient.Free;
  End;
  If Assigned(FResponseBuffer) Then
    FResponseBuffer.Free;
  inherited;
end;

Procedure TClientObject.CopyFromReference( Reference: TClientObject );
Begin
  // just nothing to do in the basic object
End;

Procedure TClientObject.Initialize;
Begin
  // just nothing to do in the basic object
End;

Procedure TClientObject.Loaded;
Begin
  inherited Loaded;
  If csDesigning in ComponentState then
    Exit;
  If Assigned(FResponseBroker) and Assigned(FClientObjectClass) then
    FResponseBroker.AddClientObjectWithReference(FClientObjectClass, Self);
End;

procedure TClientObject.BuildFunctionCode;
begin
  FFunctionCode:= UpperCase(ClassName);
  if Copy(FFunctionCode, 1, 13) = 'TCLIENTOBJECT' then
    FFunctionCode:= Copy(FFunctionCode, 14, Length(FFunctionCode))
  else 
    if Copy(FFunctionCode, 1, 5) = 'TCOBJ' then
      FFunctionCode:= Copy(FFunctionCode, 6, Length(FFunctionCode))
    else 
      if FFunctionCode[1] = 'T' then
        FFunctionCode:= Copy(FFunctionCode, 2, Length(FFunctionCode));
end;

Procedure TClientObject.Execute;
Begin
  Initialize;
  FAnswerArrived:= FALSE;
  If Assigned( FAppSrvClient ) Then Begin
    FAppSrvClient.Request.Rewrite;
  End;
End;

procedure TClientObject.SocksError(Sender : TObject; Error : Integer; Msg : String);
begin
  If Assigned( FOnSocksError ) Then
    FOnSocksError( Self, Error, Msg );
end;

procedure TClientObject.RequestDone( Sender: TObject; Error: Integer );
begin
  If Assigned( FOnRequestDone ) Then
    FOnRequestDone( Self, Error );
end;

procedure TClientObject.SetResponseFields( ResponseBuffer: TMWBuffer );
Begin
  // just nothing to do in the basic object
End;

procedure TClientObject.ProcessRequest( Sender: TObject; Error: Integer );
begin
  FAnswerArrived:= TRUE;
  FResultStatus:= 400;
  If Assigned( FAppSrvClient ) Then Begin
    FAppSrvClient.Answer.First;
    { Check if any error where detected, such as server not responding }
    If Error = 0 then begin
      { Check the answer sent back by the server. The status is '200' if ok }
      { Any other value is an error, the result set contains the errror msg }
      FResultStatus:= StrToInt( FAppSrvClient.AnswerStatus );
      if FResultStatus = 200 then begin
        FErrorMsg:= '';
        SetResponseFields( FAppSrvClient.Answer );
      end else begin
        FErrorMsg:= FAppSrvClient.Answer.Fields[0];
      end;
    End Else Begin
      FErrorMsg:= 'Server not responding !';
    End;
  End Else Begin
    If Assigned( Sender ) Then
      FErrorMsg:= 'Bug in TClinetObject'+FFunctionCode+' !'
    Else
      FErrorMsg:= FAppSrvClient.Answer.Fields[0];
  End;
  If Assigned( FFuncRequestDone ) Then
    FFuncRequestDone( Self, Error );
end;

function TClientObject.WaitForAnswer( TimeOut: integer ): boolean;
var
  DummyHandle: THandle;
begin
  Result:= TRUE;
  While NOT FAnswerArrived Do Begin
    DummyHandle := INVALID_HANDLE_VALUE;
    MsgWaitForMultipleObjects(0, DummyHandle, FALSE, 10,
                              QS_ALLINPUT + QS_ALLEVENTS +
                              QS_KEY + QS_MOUSE);
    If Assigned( FAppSrvClient ) Then Begin
      FAppSrvClient.ClientSocket.ProcessMessages;
    End;
    Sleep( 0 );
  End;
end;

procedure TClientObjectUNKNOWN.Execute;
begin
  If Assigned( FAppSrvClient ) Then Begin
    FAppSrvClient.Answer.Rewrite;
    FAppSrvClient.Answer.AppendFields( [FFunctionCode + ' unknown function !'] );
  End;
  If Assigned( FOnRequestDone ) Then
    FOnRequestDone( NIL, 0 )
  Else
    RequestDone( NIL, 0 );
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
constructor TResponseBroker.Create( AOwner: TComponent );
begin
  inherited Create( AOwner );
  FOptions:= [ rboDisplayObjectCount ];
  FObjectList:= TList.Create;
  FRunningList:= TList.Create;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
destructor TResponseBroker.Destroy;
var
  Dispatch: PDispatchObject;
begin
  if Assigned( FObjectList ) then begin
    { Free every item in the list }
    While FObjectList.Count > 0 do begin
      Dispatch:= FObjectList.Items[ 0 ];
      if Dispatch <> nil then
        Dispose( Dispatch );
      FObjectList.Delete( 0 );
      //If Assigned( Dispatch.Reference ) then 
      //  !!! FREE IT !!! OR NOT !!!
    end;

    { Free the list object }
    FObjectList.Destroy;
    FObjectList:= nil;
  end;

  if Assigned( FRunningList ) then begin
    { Should we destroy the object still in the list here ? }
    FRunningList.Destroy;
    FRunningList:= nil;
  end;

  inherited Destroy;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TResponseBroker.RemoveRunningObject( ClientObject: TClientObject ): Boolean;
var
  I: Integer;
begin
  Result:= FALSE;
  if Assigned( FRunningList ) then begin
    for I:= 0 to FRunningList.Count - 1 do begin
      if ClientObject = FRunningList.Items[ I ] then begin
        FRunningList.Delete( I );
        Result:= TRUE;
        BREAK;
      end;
    end;
  end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TResponseBroker.Notification( AComponent: TComponent; operation: TOperation );
begin
  inherited Notification( AComponent, operation );
  if operation = opRemove then begin
  {$IFNDEF NOFORMS}
    if AComponent = FObjectCountLabel then
      FObjectCountLabel:= nil
    else
      if AComponent = FDisplayMemo then
        FDisplayMemo:= nil
      else
  {$ENDIF} 
        if AComponent is TClientObject then
          RemoveRunningObject( TClientObject( AComponent ) );
  end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TResponseBroker.Loaded;
begin
  inherited Loaded;
  if csDesigning in ComponentState then
    Exit;
{$IFNDEF NOFORMS}
  if ( rboDisplayObjectCount in FOptions ) and Assigned( FObjectCountLabel ) then
    FObjectCountLabel.Caption:= '0';
{$ENDIF}    
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TResponseBroker.InternalDisplay( Sender: TObject; Msg: String );
begin
{$IFNDEF NOFORMS}
  try
    if Assigned( FDisplayMemo ) then
      FDisplayMemo.Lines.Add( Msg );
  except
  end;
{$ENDIF}  
  try
    if Assigned( FOnDisplay ) then
      FOnDisplay( Sender, Msg );
  except
  end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Find a FunctionCode in the FObjectList and return the item index or -1    }
{ if function code not found.                                               }
function TResponseBroker.FindClientObject( FunctionCode: String ): Integer;
var
  Dispatch: PDispatchObject;
begin
  { The list should be sorted to find faster... }
  FunctionCode:= UpperCase( Trim( FunctionCode ) );
  for Result:= 0 to FObjectList.Count - 1 do begin
    Dispatch:= FObjectList.Items[Result];
    if Dispatch.FunctionCode = FunctionCode then
      Exit;
  end;
  Result := -1;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Remove a FunctionCode from FObjectList. Return 0 if Ok, -1 if not found   }
function TResponseBroker.RemoveClientObject( FunctionCode: String): Integer;
var
  Dispatch: PDispatchObject;
begin
  //FunctionCode:= UpperCase( Trim( FunctionCode ) );
  Result:= FindClientObject( FunctionCode );
  if Result < 0 then
    Exit;

  Dispatch:= FObjectList.Items[ Result ];  
  if Dispatch <> nil then
    Dispose( Dispatch );


  FObjectList.Delete( Result );
  Result := 0;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TResponseBroker.AddClientObject( ClientObjectClass: TClientObjectClass );
begin
  AddClientObjectWithReference( ClientObjectClass, NIL );
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TResponseBroker.AddClientObjectWithReference(
  ClientObjectClass: TClientObjectClass; ClientObjectInstance: TClientObject
);
var
  Item: Integer;
  Dispatch: PDispatchObject;
  FunctionCode: String;
  ClientObject: TClientObject;
begin
  ClientObject:= ClientObjectClass.Create( Self );
  FunctionCode:= ClientObject.FFunctionCode;
  ClientObject.Destroy;

  Item:= FindClientObject( FunctionCode );
  if Item >= 0 then
    { FunctionCode already exist, replace existing }
    Dispatch:= FObjectList.Items[Item]
  else begin
    { FunctionCode does'nt exist, create an new item }
    New(Dispatch);
    FObjectList.Add( Dispatch );
    Dispatch.FunctionCode:= FunctionCode;
    { I should sort the list to be able to find faster }
  end;

  Dispatch.Initialized := FALSE;
  Dispatch.ClientObject:= ClientObjectClass;
  Dispatch.Reference:= ClientObjectInstance;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TResponseBroker.EnumClientFunctions( CallBack: TEnumClientFunctions );
var
 Item: Integer;
 Dispatch: PDispatchObject;
begin
  if not Assigned( CallBack ) then
    Exit;

  Item:= 0;
  while Item < FObjectList.Count do begin
    Dispatch:= FObjectList.Items[Item];
    if not CallBack( Self, Dispatch.FunctionCode ) then
      break;
    Inc(Item);
  end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TResponseBroker.TriggerObjCreate( ClientObject: TClientObject );
begin
{$IFNDEF NOFORMS}
  if ( rboDisplayObjectCount in FOptions ) and Assigned( FObjectCountLabel ) then
    FObjectCountLabel.Caption := IntToStr( ObjectCount );
{$ENDIF}    
  if Assigned( FOnObjCreate ) then
    FOnObjCreate( Self, ClientObject );
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TResponseBroker.TriggerObjDestroy( ClientObject: TClientObject );
begin
{$IFNDEF NOFORMS}
  if ( rboDisplayObjectCount in FOptions ) and Assigned( FObjectCountLabel ) then
    FObjectCountLabel.Caption := IntToStr( ObjectCount - 1 );
{$ENDIF}    
  if Assigned( FOnObjDestroy ) then
    FOnObjDestroy( Self, ClientObject );
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TResponseBroker.ClientObjectRequestDone( Sender: TObject; Error: Integer );
var
  ClientObject: TClientObject;
begin
  ClientObject:= Sender as TClientObject;
  ClientObject.FAnswerArrived:= TRUE;
  ClientObject.ProcessRequest( Sender, Error );
  TriggerObjDestroy( ClientObject );
  Dec( FObjectCount );
// PL 12/07/2003  ClientObjectRequestDone is use in process for queue message, you can not destroy the component
//  ClientObject.Destroy;
  ClientObject.AppSrvClient.Free;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TResponseBroker.SendRequest( FunctionCode: String; FuncRequestDone: TRequestDone; WaitForAnswer: Boolean );
var
  Item: Integer;
  Dispatch: PDispatchObject;
  ClientObject: TClientObject;
begin

  Item:= FindClientObject( FunctionCode );
  if Item < 0 then begin
    ClientObject:= TClientObjectUNKNOWN.Create( Self );
    ClientObject.FFunctionCode:= UpperCase( FunctionCode );
    FRunningList.Add( ClientObject );
    Dispatch:= nil;
  end else begin
    Dispatch:= FObjectList.Items[ Item ];
    ClientObject:= Dispatch.ClientObject.Create( Self );
    FRunningList.Add( ClientObject );
    if Assigned( Dispatch.Reference ) then
      ClientObject.CopyFromReference( Dispatch.Reference );
  end;

  Inc( FObjectCount );
  TriggerObjCreate( ClientObject );

  try
    ClientObject.FOnDisplay:= InternalDisplay;
    ClientObject.FFuncRequestDone:= FuncRequestDone;
    ClientObject.FOnRequestDone:= ClientObjectRequestDone;
    ClientObject.FResponseBroker:= Self;
    ClientObject.FUserData:= FUserData;
    ClientObject.FIniFileName:= FIniFileName;
    If Assigned( ClientObject.FAppSrvClient ) Then Begin
      ClientObject.FAppSrvClient.Port:= FAppSrvClient.Port;
      ClientObject.FAppSrvClient.Server:= FAppSrvClient.Server;
      ClientObject.FAppSrvClient.SocksServer:= FAppSrvClient.SocksServer;
      ClientObject.FAppSrvClient.SocksPort:= FAppSrvClient.SocksPort;
      ClientObject.FAppSrvClient.SocksUsercode:= FAppSrvClient.SocksUsercode;
      ClientObject.FAppSrvClient.SocksPassword:= FAppSrvClient.SocksPassword;
      ClientObject.FAppSrvClient.SocksAuthentication:= FAppSrvClient.SocksAuthentication;
    End;
    { Call the Initialize procedure if it is the first instanciation }
    if ( Dispatch <> nil ) and ( not Dispatch.Initialized ) then begin
      ClientObject.Initialize;
      Dispatch.Initialized := TRUE;
    end;

    ClientObject.FAnswerArrived:= FALSE;
    ClientObject.Execute;
    If WaitForAnswer Then
      If NOT ClientObject.WaitForAnswer( 0 ) Then;
      
  except
    { In case of error, delete the ClientObject instance }
    TriggerObjDestroy( ClientObject );
    ClientObject.Destroy;
    Dec( FObjectCount );
    raise;
  end;
end;
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

// PL 12/07/2003 destruction of FAppSrvClient, this is to have notification for the destruction
procedure TClientObject.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (operation=opremove) and (AComponent=FAppSrvClient) then
   FAppSrvClient:=Nil;
end;

end.
