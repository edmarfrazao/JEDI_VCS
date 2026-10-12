{*_* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Author:       François PIETTE
Description:  Object Request Broker (ORB).
              The ORB is one of the two major components for the application
              server (an application server is composed of the application
              server component, the request broker component and several server
              components). The ORB is responsible for dispatching client request
              to server object which knows how to execute the request.
Creation:     February 26, 1998
Version:      1.24
EMail:        francois.piette@overbyte.be  http://www.overbyte.be
Support:      Use the mailing list midware@elists.org
              Follow "support" link at http://www.overbyte.be for subscription.
Legal issues: Copyright (C) 1998-2007 by François PIETTE
              Rue de Grady 24, 4053 Embourg, Belgium. Fax: +32-4-365.74.56
              <francois.piette@overbyte.be>

              This software is provided 'as-is', without any express or
              implied warranty.  In no event will the author be held liable
              for any  damages arising from the use of this software.

              Permission is granted to anyone to use this software and or any
              derived or altered versions for any purpose, excluding commercial
              applications. You can use this software for personal use only.
              You may distribute it freely untouched.
              The following restrictions applies:

              1. The origin of this software must not be misrepresented, you
                 must not claim that you wrote the original software.

              2. If you use this software in a product, an acknowledgment in
                 the product documentation and displayed on screen is required.
                 The text must be: "This product is based on MidWare. Freeware
                 source code is available at http://www.overbyte.be."

              3. Altered source versions must be plainly marked as such, and
                 must not be misrepresented as being the original software.

              4. This notice may not be removed or altered from any source
                 distribution and must be added to the product documentation.

Updates:
Mar 05, 1998  V1.01 TServerObjectUNKNOWN called inherited Execute. Corrected
              call Finish method.
              Created RBrokerVersion constant.
May 23, 1998  V1.02 Renamed procedure Display to TriggerDisplay to be consistent
              with convention used with events management.
              Added comments for methods, properties and events documentation.
Jun 01, 1998  V1.03 Removed beta status. Changed "legal stuff" to prohibe
              commercial applications whithout an agreement.
Jun 21, 1998  V1.04 Adapted for C++Builder V3 (do not support multiple
              constructors).
Jul 08, 1998  V1.05 Adapted for Delphi 4 (added a dummy argument to second
              constructor to remove warning).
Jul 15, 1998  V1.06 Added Tag argument in CrackHeader to help descending
              classes.
Sep 10, 1998  V1.07 Added AppServer to TOrbData
              Added Sender to BrokeRequest function
Jun 06, 1999  V1.08 Set AutoExpand equal to 0 in GiveRequest.
Oct 29, 2001  V1.09 Exposed TServerObject.UserData and ResultStatus as public
              properties
Nov 07, 2001  V1.10 Exposed TServerObject.ORBDataPtr as public property.
Mar 30, 2002  V1.11 Add Datagram handling
Apr 09, 2002  V1.12 Implemented Datagram types
Apr 24, 2002  V1.13 Francesco D'Inzeo <f.dinzeo@wintech.it> found a bug in
              BrokeRequest when TServerObject was not found.
Apr 30, 2002  V1.14 Exposed RequestBuffer, ResponseBuffer, OnRequestDone in
              TServerObject.
              Check for Assigned(FRequestBroker) in TServerObject.Finish and
              TServerObject.SendDatagram before using FRequestBroker.
Jul 18, 2002  V1.15 Made FunctionCode a read-only property.
              Exposed FRunningList as read-only property ObjectList.
              Added read-only property TServerObject.CreateTime
Jul 19, 2000  V1.16 Better exception handling in ServerObjectRequestDone
May 06, 2003  V1.17 Exposed TServerObject.OnDisplay and IniFilename as public.
Jun 28, 2003  V1.18 Added ServerObjectUNKNOWNClass property (code by "Uwe Schuster"
              <jedivcs@bitcommander.de>) so that you can override the behaviour
              in case the AppServer receive an unknown request. The default
              action can be whatever you like now. This is very useful in the
              case you are writing an proxy or load balancing system.
Aug 28, 2004  V1.19 Use MWDefs.inc.
Apr 22, 2004  V1.20 Added TRequestBroker.DispatchList property
Apr 25, 2005  V1.21 Added TServerObject.EnumPropertyItems
Jul 16, 2005  V1.22 Added simple session handling
Oct 23, 2005  V1.23 Updated for Delphi 2006 and BCB 2006
Apr 13, 2006  V1.24 Made TDisplayEvent argument a const argument.


 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit RBroker;

{$ifdef FPC}
  {$MODE DELPHI}
{$endif}

interface

{$I MWDEFS.INC}

uses
    Windows, SysUtils, StdCtrls, Classes, RFormat, WebSession
    // To be able to use DebugOutput
    //, ThreadPool
    ;

const
    RBrokerVersion      = 124;
    CopyRight : String  = ' TRequestBroker (c) 1998-2006 F. Piette V1.24 ';
    ServerObjectVersion = RBrokerVersion;

type
    ERequestBrokerException = class(Exception);
    TRequestBroker          = class;
    TServerObject           = class;
    TServerObjectClass      = class of TServerObject;

    TRequestBrokerOption     = (rboDisplayObjectCount);
    TRequestBrokerOptions    = set of TRequestBrokerOption;

    TDisplayEvent = procedure (Sender : TObject; const Msg : String) of object;
    TSendResponseToClient = procedure (Dest     : TObject;
                                       ORB      : TRequestBroker;
                                       Status   : Integer;
                                       Response : PChar;
                                       Len      : Integer) of object;

    TORBData = record
        SendResp  : TSendResponseToClient;
        Tag       : TObject;                     { CliWSocket    }
        Item      : Integer;
        ORB       : TRequestBroker;              { RequestBroker }
        AppServer : TObject;                     { AppServer     }
    end;
    PORBData = ^TORBData;

    TPropertyItemDataType =
        (vdtNone,         // No edit possible
         vdtString,       // Edit as a single string (TEdit)
         vdtPickString,   // Edit as a drop down list of strings
         vdtMaskString);  // Edit as a formatted string (TMaskEdit)

    TPropertyReadStringEvent = procedure (Sender : TObject;
                                          const Section, Key, Default : String;
                                          out   Value : String) of object;
    TPropertyWriteStringEvent = procedure (Sender : TObject;
                                           const Section, Key : String;
                                           const Value : String) of object;
    TORBPropertyReadStringEvent = procedure (Sender : TObject; Obj : TObject;
                                          const Section, Key, Default : String;
                                          out   Value : String) of object;
    TORBPropertyWriteStringEvent = procedure (Sender : TObject; Obj : TObject;
                                           const Section, Key : String;
                                           const Value : String) of object;

    {:TServerObject is the ancestor (abstract class) for all object responsible
      for doing the application server work. The ORB create instances of server
      object, pass client request to them and call their Execute method. When
      the server object work is done, it must call the Finish method to send
      the response back to the client. This can be done either from the execute
      method or form any other point later in time. }
    TServerObject = class(TComponent)
    protected
        {:The FunctionCode is used by the ORB to know how to dispatch client
          requests to the various server objects he has in his table. By default
          the FunctionCode is derived from the server object class name and is
          the class name without the leading TServerObject. You can override
          the BuildFunctionCode method to change that behaviour. The function
          code is case insensitive. }
        FFunctionCode   : String;
        {:Where the request comes in. }
        FRequestBuffer  : TMWBuffer;
        {:Where the result goes to. }
        FResponseBuffer : TMWBuffer;
        {:The default response size. }
        FResponseSize   : Integer;
        {:ResultStatus returned to client. Based on the model used by the HTTP
          protocol: 200 means OK, 400 means error. See HTTP protocol reference.
          The server does'nt really use this ResultStatus. It's used by the
          client. The ResultStatus value is returned in the client's
          TAppSrvClient AnswerStatus property as a string. }
        FResultStatus   : Integer;
        {:Reserved for the TServerObject descendent writer. It is generally used
          to pass global data from the application server to the various server
          object. For example TTable or any other global data. Using FUserData
          is far better way of programming than using global variables. }
        FUserData          : LongInt;
        {:To be used for persistent data. }
        FIniFileName       : String;
        {:Data received from the ORB. }
        FORBDataPtr        : PORBData;
        FRequestBroker     : TRequestBroker;
        FServerObjectClass : TServerObjectClass;
        {:Updated when constructor is called}
        FCreateTime        : TDateTime;
        {:Value extracted from request buffer. Client send SessionID into
          metadata type 'I' in the first field of the request. Value SessionID
          are normally created by a TServerObjectLogon which populate the
          session list hosted by the global variable GWebSessions.}
        FSessionID         : String;
        {:Current session information. Nil if no SessionID received from
          client.}
        FSession           : TWebSession;
        FOnRequestDone     : TNotifyEvent;
        FOnDisplay         : TDisplayEvent;
        {:Used by the request broker which has transfer functions to expose
          the event to the application }
        FOnPropertyReadString  : TPropertyReadStringEvent;
        {:Used by the request broker which has transfer functions to expose
          the event to the application }
        FOnPropertyWriteString : TPropertyWriteStringEvent;
        {:Triggers the OnDisplay event, if assigned. }
        procedure TriggerDisplay(Msg : String); virtual;
        {:BuildFunctionCode will initialize FFunctionCode with the function
          code handled by the ServerObject. Default to the class name
          without TServerObject. }
        procedure BuildFunctionCode; virtual;
        procedure Loaded; override;
        procedure Notification(AComponent: TComponent; operation: TOperation); override;
        procedure CopyFromReference(Reference : TServerObject); virtual;
{$IFNDEF VER110} { C++Builder do not support multiple constructors }
        {:This constructor is used by the ORB just to get the function code.
          Normally not used outside of the ORB code. }
        constructor CreateForFunctionCode(AOwner : TComponent; Dummy : Integer); virtual;
{$ENDIF}
    public
        constructor Create(AOwner : TComponent); override;
        destructor  Destroy; override; 
        {:The ORB (Object Request Broker, TRequestBroker component) call this
          method to pass a request from the client to the server object. }
        procedure GiveRequest(RqBuffer : PChar; RqLength : Integer); virtual;
        {:The ORB (Object Request Broker, TRequestBroker component) call this
          method when the server object must be initialized. This is done only
          ONCE per server run. This procedure can be overriden to place any
          code needed to initialize global data for the server object. }
        procedure Initialize; virtual;
        {:The ORB (Object Request Broker, TRequestBroker component) call this
          method to make the server object do his work: execute the request
          and produce a response. You MUST override this method and place the
          effective code for the server object work. }
        procedure Execute; virtual;
        {:The server object MUST call this method to signal the ORB (Object
          Request Broker, TRequestBroker component) that the server's object
          work is done and the response is ready to be sent to the client.
          You can call Finish just before returning from the Execute method, or
          at some later moment if the server object continue processing in the
          background after the Execute method has returned control back to the
          ORB (this means you have written an event driven server object or a
          multi-threaded server object). While Execute method code runs, no
          other client is serviced. If the processing is long, you probably
          wants to start a thread to do the processing in the background and
          call Finish method at a later time, or wants to write a fully
          event-driven server object which works by sending messages. }
        procedure Finish; virtual;
        {:The ORB will call this procedure when a datagram has been received
          from client. You must override DatagramAvailable in your own
          TServerObject to handle those incomming datagrams. }
        procedure DatagramAvailable(Sender          : TObject;
                                    const DGramType : String;
                                    Data            : PChar;
                                    DataLen         : Integer); virtual;
        {:Call SendDatagram to send a datagram back to the client. }
        procedure SendDatagram(const DGramType : String;
                               Data            : PChar;
                               Size            : Integer);
        {:Call SendDatagramString to send a single string as a single
          datagram to the client. }
        procedure SendDatagramString(const DGramType : String;
                                     const S         : String);
        procedure DataSent(Sender : TObject; Error : Word); virtual;
        {:Enumerator for persitant properties. Used for building a config
          windows in the server application. }
        procedure EnumPropertyItems(
                        // More properties ?
                        var   More       : Boolean;
                        // Property global index
                        const Index      : Integer;
                        // Need a new section ?
                        var   NewSection : Boolean;
                        // Section where the property belongs to
                        var   Section    : String;
                        // Property key within the section
                        var   ItemKey    : String;
                        // Hint for property
                        var   ItemHint   : String;
                        // Initial value, returned value
                        var   ItemVDflt  : String;
                        // Value list when required
                        var   ItemVList  : String;
                        // Value type
                        var   ItemVType  : TPropertyItemDataType); virtual;
        {:Read a property value of type string. Same idea as INI file.
          This correspond to the request broker OnPropertyReadString event. }
        function PropertyReadString(const Section, Key,
                                    Default : String) : String; virtual;
        {:Write a property value of type string. Same idea as INI file.
          This correspond to the request broker OnPropertyWriteString event. }
        procedure PropertyWriteString(const Section, Key,
                                      Value : String); virtual;
        {:Check if a the client has a valid SessionID, that is is
          authenticated.
          Refresh argument tell the system if timemark has to be refreshed with
          current time, that is signal some activity on the session to avoid
          session expiration. }
        function IsLoggedOn(Refresh : Boolean) : Boolean;
        {:UserData is initialized by the ORB with his own UseData. This is
          a way to pass global data to all TServerObject. }
        property UserData          : LongInt       read  FUserData
                                                   write FUserData;
        property ResultStatus      : Integer       read  FResultStatus
                                                   write FResultStatus;
        property ORBDataPtr        : PORBData      read  FORBDataPtr
                                                   write FORBDataPtr;
        property RequestBuffer     : TMWBuffer     read  FRequestBuffer;
        property ResponseBuffer    : TMWBuffer     read  FResponseBuffer;
        property FunctionCode      : String        read  FFunctionCode;
        property CreateTime        : TDateTime     read  FCreateTime;
        property IniFileName       : String        read  FIniFileName
                                                   write FIniFileName;
        property OnRequestDone     : TNotifyEvent  read  FOnRequestDone
                                                   write FOnRequestDone;
        property OnDisplay         : TDisplayEvent read  FOnDisplay
                                                   write FOnDisplay;
        property OnPropertyReadString  : TPropertyReadStringEvent
                                                   read  FOnPropertyReadString
                                                   write FOnPropertyReadString;
        property OnPropertyWriteString : TPropertyWriteStringEvent
                                                   read  FOnPropertyWriteString
                                                   write FOnPropertyWriteString;
    published
        property RequestBroker : TRequestBroker    read  FRequestBroker
                                                   write FRequestBroker;
    end;

    { This ServerObject is used when the ORB is asked to execute an unknown   }
    { function code.                                                         }
    TServerObjectUNKNOWN = class(TServerObject)
    private
        FFunctionCode : String;
    public
        constructor CreateParam(AOwner : TComponent; FunctionCode : String); virtual;
        procedure   Execute; override;
    end;

    TServerObjectUNKNOWNClass = class of TServerObjectUNKNOWN;

    TAnonimousLink = procedure (ServerObject   : TServerObject;
                                CliWSocket     : TObject) of object;
    TAnonimousSendDatagram = procedure (CliWSocket      : TObject;
                                        const DGramType : String;
                                        Data            : PChar;
                                        DataLen         : Integer) of object;

    { The RequestBroker maintains a TList with TDispatchObject }
    TDispatchObject = record
        FunctionCode : String;
        Initialized  : Boolean;
        ServerObject : TServerObjectClass;
        Reference    : TServerObject;
    end;
    PDispatchObject = ^TDispatchObject;

    TInstanciationEvent = procedure (Sender : TObject; ServerObject : TServerObject) of object;
    TEnumServerFunctions = function (Sender : TObject; FunctionCode : String) : Boolean of object;

    {:The RequestBroker (ORB) main job is to instanciate objects to satisfy
      client requests, passing to the object the parameters from the request
      and giving the result back to the client when the object has finished.
      A request is made of a function code, a space and some parameters in a
      special format (TMWBuffer).
      The RequestBroker object is linked to the application server object and
      receive client requests from him, brokening those requests and
      dispatching them to server objects for execution. }
    TRequestBroker = class(TComponent)
    protected
        FOptions          : TRequestBrokerOptions;
        FDisplayMemo      : TCustomMemo;
        FObjectCountLabel : TLabel;
        {:List of all TDispatchObject. }
        FObjectList    : TList;
        {:List of all running TServerObject }
        FRunningList   : TList;
        {:Number of instanciated objects. }
        FObjectCount   : Integer;
        {:Just passed to ServerObject instances. }
        FUserData      : LongInt;
        {:Just passed to ServerObject instances. }
        FIniFileName   : String;
        FOnDisplay     : TDisplayEvent;
        FOnPropertyReadString  : TORBPropertyReadStringEvent;
        FOnPropertyWriteString : TORBPropertyWriteStringEvent;
        {:Triggered when an object has been instanciated. }
        FOnObjCreate   : TInstanciationEvent;
        {:Triggered when an object has been destroyed. }
        FOnObjDestroy  : TInstanciationEvent;
        FOnLinkClientWSocketAndServerObject : TAnonimousLink;
        FOnAskClientWSocketToSendDatagram   : TAnonimousSendDatagram;
        FServerObjectUNKNOWNClass           : TServerObjectUNKNOWNClass;
        {:Find a server object by using function code as a key.
          Returns the server object index in the table of object. }
        procedure Notification(AComponent: TComponent; operation: TOperation); override;
        function  FindServerObject(FunctionCode : String) : Integer;
        {:Remove an object from the obejct list. }
        function  RemoveServerObject(FunctionCode : String) : Integer;
        procedure ServerObjectRequestDone(Sender   : TObject);
        {:A client request is constitued of two parts: a function code and
          some parameters. The CrackHeader method is responsible to split both
          parts. By default, it consider the function code to be the first word
          in the data received from the client and the parameter being the
          remaining data after this function code and any trailing spaces.
          You can overrie this method if you like to have a more complex headder
          for example to pass more info from the client to the server. }
        procedure CrackHeader(
            RqBuffer         : PChar;       { Given request buffer       }
            RqLength         : Integer;     { Given request length       }
            Tag              : TObject;     { CliWSocket                 }
            var FunctionCode : String;      { Returned function code     }
            var ParamPtr     : PChar;       { Returned parameters start  }
            var ParamLen     : LongInt      { Returned parameters length }
            ); virtual;
        procedure   TriggerObjCreate(ServerObject : TServerObject); virtual;
        procedure   TriggerObjDestroy(ServerObject : TServerObject); virtual;
        procedure   InternalDisplay(Sender : TObject; const Msg : String);
        procedure   Loaded; override;
        function    RemoveRunningObject(ServerObject : TServerObject) : Boolean;
    public
        constructor Create(AOwner : TComponent); override;
        destructor  Destroy; override;
        {:AddServerObject is called from the main application server code, at
          startup to build the request broker object table. This table
          associates objects and request. Each server object has a functions
          code (which default to the server object name without the leading
          TServerObject). Note hat the argument for AddServerObject is an
          object class, not an object instance. }
        procedure   AddServerObject(ServerObjectClass : TServerObjectClass);
        procedure   AddServerObjectWithReference(
                          ServerObjectClass    : TServerObjectClass;
                          ServerObjectInstance : TServerObject);
        {:This method is used to enumerate all server functions. The mains
          purpose is to built some way to display all the server
          functionnalities such as function code list. }
        procedure   EnumServerFunctions(CallBack : TEnumServerFunctions);
        {:BrokeRequest is the ORB main method. This is the method which does
          all the work: creack header, find and instanciate server object,
          execute server object code and send result back to the client. }
        procedure   BrokeRequest(Sender   : TObject;
                                 RqBuffer : PChar;
                                 RqLength : Integer;
                                 Tag      : TObject;
                                 SendResp : TSendResponseToClient);
        procedure   TransferReadString(Sender : TObject;
                                       const Section, Key, Default : String;
                                       out   Value : String); virtual;
        procedure   TransferWriteString(Sender : TObject;
                                        const Section, Key, Value: String); virtual;
        {:Number of currently instanciated server objects. }
        property    ObjectCount  : Integer          read  FObjectCount;
        property    ObjectList   : TList            read  FRunningList;
        property    DispatchList : TList            read  FObjectList;
        property    OnLinkClientWSocketAndServerObject : TAnonimousLink
                                    read  FOnLinkClientWSocketAndServerObject
                                    write FOnLinkClientWSocketAndServerObject;
        property    OnAskClientWSocketToSendDatagram   : TAnonimousSendDatagram
                                    read  FOnAskClientWSocketToSendDatagram
                                    write FOnAskClientWSocketToSendDatagram;
        property    ServerObjectUNKNOWNClass           : TServerObjectUNKNOWNClass
                                    read  FServerObjectUNKNOWNClass
                                    write FServerObjectUNKNOWNClass;
    published
        {:UserData is not used by the request broker nor the application
          server component. It is there for the application server's writer to
          pass global data between the main application server code and each
          server object, such as TTable of any other data. }
        property UserData    : LongInt              read  FUserData
                                                    write FUserData;
        {:Used to store permanent data. }
        property IniFileName : String               read  FIniFileName
                                                    write FIniFileName;
        property ObjectCountLabel : TLabel          read  FObjectCountLabel
                                                    write FObjectCountLabel;
        property Options : TRequestBrokerOptions    read  FOptions
                                                    write FOptions;
        property DisplayMemo : TCustomMemo          read  FDisplayMemo
                                                    write FDisplayMemo;
        {:Triggered when the component need to display something on the user
          interface such as error or informatinal messages. }
        property OnDisplay   : TDisplayEvent        read  FOnDisplay
                                                    write FOnDisplay;
        {:Triggered when an object has been instanciated. }
        property OnObjCreate  : TInstanciationEvent read  FOnObjCreate
                                                    write FOnObjCreate;
        {:Triggered when an object has been destroyed. }
        property OnObjDestroy : TInstanciationEvent read  FOnObjDestroy
                                                    write FOnObjDestroy;
        property OnPropertyReadString  : TORBPropertyReadStringEvent
                                                    read  FOnPropertyReadString
                                                    write FOnPropertyReadString;
        property OnPropertyWriteString : TORBPropertyWriteStringEvent
                                                    read  FOnPropertyWriteString
                                                    write FOnPropertyWriteString;
    end;

function GetTickDiff(const InitialTime: LongWord): LongWord;

procedure Register;

implementation

var
    GServerObjectID : Integer;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure Register;
begin
    RegisterComponents('FPiette', [TRequestBroker, TServerObject]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
constructor TServerObject.Create(AOwner : TComponent);
begin
    inherited Create(AOwner);
    FResponseSize              := 1024;
    FRequestBuffer             := TMWBuffer.Create(nil);
    FResponseBuffer            := TMWBuffer.Create(nil);
    FResponseBuffer.AutoExpand := 1024;
    FServerObjectClass         := TServerObjectClass(ClassType);
    FCreateTime                := Now;
    BuildFunctionCode;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ This is just a partial object creation, just enough to get the function   }
{ code created.                                                             }
{ The function code is build from the class name, removing the base class   }
{ name. This behaviour can be overriden in the descendent classes.          }
{$IFNDEF VER110}
constructor TServerObject.CreateForFunctionCode(
    AOwner : TComponent; Dummy : Integer);
begin
    inherited Create(AOwner);
    BuildFunctionCode;
end;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
destructor TServerObject.Destroy;
begin
    if Assigned(FRequestBuffer) then begin
        FRequestBuffer.Destroy;
        FRequestBuffer := nil;
    end;
    if Assigned(FResponseBuffer) then begin
        FResponseBuffer.Destroy;
        FResponseBuffer := nil;
    end;
    inherited Destroy;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TServerObject.Notification(AComponent: TComponent; operation: TOperation);
begin
    inherited Notification(AComponent, operation);
    if operation = opRemove then begin
        if AComponent = FRequestBroker then
            FRequestBroker := nil;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TServerObject.Loaded;
begin
    inherited Loaded;
    if csDesigning in ComponentState then
        Exit;
    if Assigned(FRequestBroker) and Assigned(FServerObjectClass) then
        FRequestBroker.AddServerObjectWithReference(FServerObjectClass, Self);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TServerObject.CopyFromReference(Reference : TServerObject);
begin
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Build the function code. The code is based on the classname. For example  }
{ TServerObjectTest will have function code equal to 'TEST'                 }
{ If the classname do not begin by TServerObject, the function code will be }
{ the class name without any leading 'T': TMyObject will gives 'MYOBJECT'.  }
{ This behaviour can be overriden in descendent objects to fit particular   }
{ needs.                                                                    }
procedure TServerObject.BuildFunctionCode;
begin
    FFunctionCode := UpperCase(ClassName);
    if Copy(FFunctionCode, 1, 13) = 'TSERVEROBJECT' then
        FFunctionCode := Copy(FFunctionCode, 14, Length(FFunctionCode))
    else if Copy(FFunctionCode, 1, 5) = 'TSOBJ' then
        FFunctionCode := Copy(FFunctionCode, 6, Length(FFunctionCode))
    else if FFunctionCode[1] = 'T' then
        FFunctionCode := Copy(FFunctionCode, 2, Length(FFunctionCode));
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TServerObject.GiveRequest(RqBuffer : PChar; RqLength : Integer);
begin
    FRequestBuffer.DataBuffer      := RqBuffer;
    FRequestBuffer.DataBufferSize  := RqLength;
    FRequestBuffer.DataBufferCount := RqLength;
    FRequestBuffer.HasData         := TRUE;
    FRequestBuffer.AutoExpand      := 0;          // 06/06/99
    FRequestBuffer.First;
    FResponseBuffer.DataBufferSize := FResponseSize;
    FResponseBuffer.Rewrite;
    FSessionID := FRequestBuffer.MetaData[0, 'I'];
    if FSessionID <> '' then
        FSession := GWebSessions.FindSession(FSessionID)
    else
        FSession := nil;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TServerObject.Initialize;
begin
    { Just nothing to do in the basic object }
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TServerObject.Execute;
begin
    FResponseBuffer.WriteFields(TRUE, ['Base TServerObject called']);
    FResultStatus := 404;
    Finish;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TServerObject.Finish;
begin
    if Assigned(RequestBroker) and
       Assigned(RequestBroker.FOnLinkClientWSocketAndServerObject) then
        RequestBroker.FOnLinkClientWSocketAndServerObject
                           (nil, TObject(FOrbDataPtr.Tag));

     if Assigned(FOnRequestDone) then
         FOnRequestDone(Self)
     else begin
         if Assigned(FORBDataPtr) then
             Dispose(FORBDataPtr);
         Destroy;
     end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Called by the ORB when a datagram comes in. Overide this method in your   }
{ own TServerObject to handle incomming datagrams from client.              }
procedure TServerObject.DatagramAvailable(
    Sender          : TObject;
    const DGramType : String;
    Data            : PChar;
    DataLen         : Integer);
begin
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Call this procedure to send a datagram to the client.                     }
procedure TServerObject.SendDatagram(
    const DGramType : String;
    Data            : PChar;
    Size            : Integer);
begin
    if Assigned(RequestBroker) and
       Assigned(RequestBroker.OnAskClientWSocketToSendDatagram) then
        RequestBroker.OnAskClientWSocketToSendDatagram(
            TObject(FOrbDataPtr.Tag), DGramType, Data, Size);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TServerObject.SendDatagramString(
    const DGramType : String;
    const S         : String);
begin
    SendDatagram(DGramType, PChar(S), Length(S));
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TServerObject.DataSent(Sender: TObject; Error: Word);
begin

end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TServerObject.TriggerDisplay(Msg : String);
begin
    try
        if Assigned(FOndisplay) then
            FOnDisplay(Self, Msg);
    except
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
constructor TServerObjectUNKNOWN.CreateParam(AOwner : TComponent; FunctionCode : String);
begin
    inherited Create(AOwner);
    { We need just a small buffer for this demo }
    FResponseSize := 200;
    FFunctionCode := FunctionCode;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TServerObjectUNKNOWN.Execute;
begin
    FResponseBuffer.WriteFields(TRUE, [FFunctionCode, 'Unknown request']);
    FResultStatus := 401;
    Finish;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
constructor TRequestBroker.Create(AOwner : TComponent);
begin
    inherited Create(AOwner);
    FOptions     := [rboDisplayObjectCount];
    FObjectList  := TList.Create;
    FRunningList := TList.Create;
    FServerObjectUNKNOWNClass := TServerObjectUNKNOWN;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
destructor TRequestBroker.Destroy;
var
    Dispatch : PDispatchObject;
begin
    if Assigned(FObjectList) then begin
        { Free every item in the list }
        while FObjectList.Count > 0 do begin
            Dispatch := FObjectList.Items[0];
            if Dispatch <> nil then
                Dispose(Dispatch);
            FObjectList.Delete(0);
        end;

        { Free the list object }
        FObjectList.Destroy;
        FObjectList := nil;
    end;

    if Assigned(FRunningList) then begin
        { Should we destroy the object still in the list here ? }
        FRunningList.Destroy;
        FRunningList := nil;
    end;

    inherited Destroy;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TRequestBroker.RemoveRunningObject(
    ServerObject : TServerObject) : Boolean;
var
    I : Integer;
begin
    if Assigned(FRunningList) then begin
        for I := 0 to FRunningList.Count - 1 do begin
            if ServerObject = FRunningList.Items[I] then begin
                FRunningList.Delete(I);
                Result := TRUE;
                exit;
            end;
        end;
    end;
    Result := FALSE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestBroker.Notification(AComponent: TComponent; operation: TOperation);
begin
    inherited Notification(AComponent, operation);
    if operation = opRemove then begin
        if AComponent = FObjectCountLabel then
            FObjectCountLabel := nil
        else if AComponent = FDisplayMemo then
            FDisplayMemo := nil
        else if AComponent is TServerObject then
            RemoveRunningObject(TServerObject(AComponent));
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestBroker.Loaded;
begin
    inherited Loaded;
    if csDesigning in ComponentState then
        Exit;
    if (rboDisplayObjectCount in FOptions) and Assigned(FObjectCountLabel) then
        FObjectCountLabel.Caption := '0';
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestBroker.InternalDisplay(Sender : TObject; const Msg : String);
begin
    try
        if Assigned(FDisplayMemo) then
            FDisplayMemo.Lines.Add(Msg);
    except
    end;
    try
        if Assigned(FOnDisplay) then
            FOnDisplay(Sender, Msg);
    except
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Find a FunctionCode in the FObjectList and return the item index or -1    }
{ if function code not found.                                               }
function TRequestBroker.FindServerObject(FunctionCode : String) : Integer;
var
    Dispatch : PDispatchObject;
begin
    { The list should be sorted to find faster... }
    FunctionCode := UpperCase(Trim(FunctionCode));
    for Result := 0 to FObjectList.Count - 1 do begin
        Dispatch := FObjectList.Items[Result];
        if Dispatch.FunctionCode = FunctionCode then
            Exit;
    end;
    Result := -1;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Remove a FunctionCode from FObjectList. Return 0 if Ok, -1 if not found   }
function TRequestBroker.RemoveServerObject(FunctionCode : String) : Integer;
var
    Dispatch : PDispatchObject;
begin
    FunctionCode := UpperCase(Trim(FunctionCode));
    Result := FindServerObject(FunctionCode);
    if Result < 0 then
        Exit;

    Dispatch := FObjectList.Items[Result];
    if Dispatch <> nil then
        Dispose(Dispatch);


    FObjectList.Delete(Result);
    Result := 0;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestBroker.AddServerObject(
    ServerObjectClass : TServerObjectClass);
begin
    AddServerObjectWithReference(ServerObjectClass, nil);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestBroker.AddServerObjectWithReference(
    ServerObjectClass    : TServerObjectClass;
    ServerObjectInstance : TServerObject);
var
    Dispatch     : PDispatchObject;
    Item         : Integer;
    FunctionCode : String;
    ServerObject : TServerObject;
begin
    { Create an object instance, just to get the object FunctionCode }
{$IFNDEF VER110}
    { We use another constructor which is faster because it does'nt create }
    { TMWBuffers.                                                          }
    ServerObject := ServerObjectClass.CreateForFunctionCode(Self, 0);
{$ELSE}
    { But C++Builder do not support multiple constructors, so we use the   }
    { normal constructor.                                                  }
    ServerObject := ServerObjectClass.Create(Self);
{$ENDIF}
    ServerObject.FOnDisplay := InternalDisplay;
    FunctionCode := ServerObject.FFunctionCode;
    ServerObject.Destroy;

    Item := FindServerObject(FunctionCode);
    if Item >= 0 then
        { FunctionCode already exist, replace existing }
        Dispatch := FObjectList.Items[Item]
    else begin
        { FunctionCode does'nt exist, create an new item }
        New(Dispatch);
        FObjectList.Add(Dispatch);
        Dispatch.FunctionCode := FunctionCode;
        { I should sort the list to be able to find faster }
    end;

    Dispatch.Initialized  := FALSE;
    Dispatch.ServerObject := ServerObjectClass;
    Dispatch.Reference    := ServerObjectInstance;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestBroker.EnumServerFunctions(CallBack : TEnumServerFunctions);
var
    Item     : Integer;
    Dispatch : PDispatchObject;
begin
    if not Assigned(CallBack) then
        Exit;
    Item := 0;
    while Item < FObjectList.Count do begin
        Dispatch := FObjectList.Items[Item];
        if not CallBack(Self, Dispatch.FunctionCode) then
            break;
        Inc(Item);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestBroker.TriggerObjCreate(ServerObject : TServerObject);
begin
    if (rboDisplayObjectCount in FOptions) and Assigned(FObjectCountLabel) then
        FObjectCountLabel.Caption := IntToStr(ObjectCount);
    if Assigned(FOnObjCreate) then
        FOnObjCreate(Self, ServerObject);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestBroker.TriggerObjDestroy(ServerObject : TServerObject);
begin
    if (rboDisplayObjectCount in FOptions) and Assigned(FObjectCountLabel) then
        FObjectCountLabel.Caption := IntToStr(ObjectCount - 1);
    if Assigned(FOnObjDestroy) then
         FOnObjDestroy(Self, ServerObject);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestBroker.ServerObjectRequestDone(Sender : TObject);
var
    ServerObject : TServerObject;
    ORBDataPtr   : PORBData;
begin
    ServerObject := Sender as TServerObject;
    try
        TriggerObjDestroy(ServerObject);
        ORBDataPtr := ServerObject.FORBDataPtr;
        if Assigned(ORBDataPtr) then begin { 19/07/02 }
            if Assigned(ORBDataPtr.SendResp) then begin
                ORBDataPtr.SendResp(ORBDataPtr.Tag,
                                    ORBDataPtr.ORB,
                                    ServerObject.FResultStatus,
                                    ServerObject.FResponseBuffer.DataBuffer,
                                    ServerObject.FResponseBuffer.DataBufferCount);
            end;
            Dispose(ORBDataPtr);
        end;
    finally  { 19/07/02 }
        Dec(FObjectCount);
        ServerObject.Free;
        // DebugOutput('ServerObjectRequestDone');
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Extract the function code and separate parameters from header             }
procedure TRequestBroker.CrackHeader(
    RqBuffer         : PChar;       { Given request buffer       }
    RqLength         : Integer;     { Given request length       }
    Tag              : TObject;     { CliWSocket                 }
    var FunctionCode : String;      { Returned function code     }
    var ParamPtr     : PChar;       { Returned parameters start  }
    var ParamLen     : LongInt);    { Returned parameters length }
var
    I : LongInt;
begin
    { The first word is the object name }
    I := 0;
    while (I < RqLength) and (RqBuffer[I] <> ' ') do
        Inc(I);
    SetLength(FunctionCode, I);
    Move(RqBuffer^, FunctionCode[1], I);

    { Skip spaces }
    while (I < RqLength) and (RqBuffer[I] = ' ') do
        Inc(I);

    { Parameters follows }
    ParamPtr := RqBuffer + I;
    ParamLen := RqLength - I;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestBroker.BrokeRequest(
    Sender   : TObject;                 { TAppServer }
    RqBuffer : PChar;
    RqLength : Integer;
    Tag      : TObject;                 { CliWSocket }
    SendResp : TSendResponseToClient);
var
    Item         : Integer;
    FunctionCode : String;
    ParamPtr     : PChar;
    ParamLen     : LongInt;
    Dispatch     : PDispatchObject;
    ServerObject : TServerObject;
    ORBDataPtr   : PORBData;
begin
    { Extract the function code and separate parameters from header }
    CrackHeader(RqBuffer, RqLength, Tag,            { Inputs  }
                FunctionCode, ParamPtr, ParamLen);  { Outputs }

    Item := FindServerObject(FunctionCode);
    if Item < 0 then begin
        ServerObject := FServerObjectUNKNOWNClass.CreateParam(Self, FunctionCode);
        Item         := FRunningList.Add(ServerObject);
        Dispatch     := nil;
    end
    else begin
        Dispatch          := FObjectList.Items[Item];
        ServerObject      := Dispatch.ServerObject.Create(Self);
        FRunningList.Add(ServerObject);
        if Assigned(Dispatch.Reference) then
            ServerObject.CopyFromReference(Dispatch.Reference);
        { The request broker doesn't know anything about communication   }
        { layer (CliWSocket), so it can't link it to the server object.  }
        { But the AppServer knows about it, so it can do the link !      }
        if Assigned(FOnLinkClientWSocketAndServerObject) then
            FOnLinkClientWSocketAndServerObject(ServerObject, Tag);
    end;

    { Give a unique name to the object }
    Inc(GServerObjectID); { Next object ID }
    if Dispatch = nil then { 20020424 }
        ServerObject.Name := 'ServerObjectUNKNOWN_' + Self.Name + '_' +
                             IntToStr(GServerObjectID)
    else
        ServerObject.Name := Copy(Dispatch.ServerObject.ClassName, 2, 64) +
                             '_' + Self.Name + '_' +
                             IntToStr(GServerObjectID);

    Inc(FObjectCount);
    TriggerObjCreate(ServerObject);

    try
        New(ORBDataPtr);
        try
            ORBDataPtr.SendResp         := SendResp;
            ORBDataPtr.Tag              := Tag;        { CliWSocket }
            ORBDataPtr.Item             := Item;
            ORBDataPtr.ORB              := Self;
            ORBDataPtr.AppServer        := Sender;

            ServerObject.FOnDisplay     := InternalDisplay;
            ServerObject.FOnRequestDone := ServerObjectRequestDone;
            ServerObject.FOnPropertyReadString  := TransferReadString;
            ServerObject.FOnPropertyWriteString := TransferWriteString;
            ServerObject.FORBDataPtr    := ORBDataPtr;
            ServerObject.FRequestBroker := Self;
            ServerObject.FResultStatus  := 400;
            ServerObject.FUserData      := FUserData;
            ServerObject.FIniFileName   := FIniFileName;
            ServerObject.GiveRequest(ParamPtr, ParamLen);
            { Call the Initialize procedure if it is the first instanciation }
            if (Dispatch <> nil) and (not Dispatch.Initialized) then begin
                ServerObject.Initialize;
                Dispatch.Initialized := TRUE;
            end;
            ServerObject.Execute;
        except
            Dispose(ORBDataPtr);
            raise;
        end;
    except
        { In case of error, delete the ServerObject instance }
        TriggerObjDestroy(ServerObject);
        ServerObject.Destroy;
        Dec(FObjectCount);
        raise;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
// This should be overriden in derived classes
procedure TServerObject.EnumPropertyItems(var More: Boolean;
  const Index: Integer; var NewSection: Boolean; var Section, ItemKey,
  ItemHint, ItemVDflt, ItemVList: String;
  var ItemVType: TPropertyItemDataType);
begin
    More := FALSE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TServerObject.PropertyReadString(
    const Section, Key, Default: String): String;
begin
    Result := Default;
    if Assigned(FOnPropertyReadString) then
        FOnPropertyReadString(Self, Section, Key, Default, Result);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TServerObject.PropertyWriteString(
    const Section, Key, Value: String);
begin
    if Assigned(FOnPropertyWriteString) then
        FOnPropertyWriteString(Self, Section, Key, Value);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
// Check if a the client has a valid SessionID, that is is authenticated.
// Refresh argument tell the system if timemark has to be refreshed with
// current time, that is signal some activity on the session to avoid
// session expiration
function TServerObject.IsLoggedOn(Refresh : Boolean) : Boolean;
begin
    Result := (FSession <> nil);
    if Refresh and (FSession <> nil) then
        FSession.Refresh;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestBroker.TransferReadString(Sender: TObject; const Section,
  Key, Default: String; out Value: String);
begin
    Value := Default;
    if Assigned(FOnPropertyReadString) then
        FOnPropertyReadString(Self, Sender, Section, Key, Default, Value);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestBroker.TransferWriteString(Sender: TObject;
  const Section, Key, Value: String);
begin
    if Assigned(FOnPropertyWriteString) then
        FOnPropertyWriteString(Self, Sender, Section, Key, Value);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
// Returns the difference between an initial GetTickCount and the current
// value returned by GetTickCount. It takes into account the fact that
// GetTickCount restart to 0 after around 49 days.
// It also take into account the phenomena which happends when the real time
// clock is adjusted with a value before the actual value. In that case, the
// difference returned will be 0 instead of a negative value (Not possible
// anyway with a LongWord return type). This makes the routine not handling
// intervals greater than 24 days or so.
function GetTickDiff(const InitialTime: LongWord): LongWord;
var
    CurrentTime : LongWord;
begin
    CurrentTime := GetTickCount;
    // Check for wrap arround: GetTickCount restart to 0 after 49 days
    if CurrentTime >= InitialTime then
        Result := CurrentTime - InitialTime
    else
        Result := High(LongWord) - InitialTime + CurrentTime;

    // We can also have strange results when the PC time is changed between
    // InitialTime and CurrentTime, specially if  CurrentTime is less than
    // InitialTime ! We got this when an AtomicClock is used on a PC which
    // real time clock is too fast
    // If this happend, we symply return 0 as TickDiff.
    // The code below is then not valid for an interval longer than 24 days.
    if Result > (High(LongWord) div 2) then
        Result := 0;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

end.

