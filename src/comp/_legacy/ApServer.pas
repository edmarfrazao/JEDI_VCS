{*_* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Author:       François PIETTE
Description:  Application Server Component. This is the communication kernel
              for the application server.
              This component handle all the communication work for the
              application server, keeping track of user connections.
              A complete application server is made of this somponent, a
              request broker component and a set of server components.
              See project SrvTst for a sample application server program.
Creation:     March 02, 1998
Version:      2.04
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
                 source code is available at http://www.overbyte.be"

              3. Altered source versions must be plainly marked as such, and
                 must not be misrepresented as being the original software.

              4. This notice may not be removed or altered from any source
                 distribution and must be added to the product documentation.

Updates:
Mar 27, 1998  V1.01 Added ClientWSocket[] indexed property to retrive the
              client TWSocket reference (helpful for example to display all
              connected client IP addresses).
Apr 10, 1998  V1.02 Accepted the client connection before triggering the
              OnClientConnected event handler.
Apr 14, 1998  V1.03 Changed LongInt to Integer parameter ProcessClientCommand
              to match function description in TClientWSocket - ApSrvCli.PAS
              (from Bruce Christensen <brucec@compusmart.ab.ca>)
              Added a Banner property.
May 18, 1998  V1.04 Implemented client timeout functions.
May 23, 1998  V1.05 Added comments to describes properties, events and methods.
Jun 01, 1998  V1.06 Removed beta status. Changed "legal stuff" to prohibe
              commercial applications whithout an agreement.
Jun 07, 1998  V1.07 Added functionnalities to support encryption and compression
Jun 19, 1998  V1.08 DisconnectAll now trigger the OnSessionClosed event for
              each client.
Jul 08, 1998  V1.09 Adapted for Delphi 4
Jul 15, 1998  V1.10 Added TAppServer.FClientClass to allow descendent class
              to use a custom class for his clients sockets.
Aug 17, 1998  V1.11 Added handling for client buffer overflow
              Added SendStringResponseToClient to correctly format error
              responses to client (Timeout and overflow)
Sep 10, 1998  V1.12 Added RequestCount and ConnectCount property and support
Dec 12, 1998  V1.13 Added background exception handling
Feb 14, 1999  V1.14 Use runtime dynamic link with winsock, using wsocket
              functionswhich are linked at runtime instead of loadtime. This
              allows programs to run without winsock installed, provided program
              doesn't try to use TWSocket or winsock function without first
              checking for winsock installation.
              Added functions AppServerWindowProc, AppServerAllocateHWnd and
              AppServerDeallocateHWnd to handle private message handling
              without using the Forms unit (help for writing services or non
              GUI applications).
              Added OnBgexception event and related logic.
Dec 07, 2000  V1.15 Added 100mS sleep right after a client connect when we
              run on Windows 2000. Thanks to Thomas Hensle <freevcs@thensle.de>.
Mar 03, 2002  V1.16 Added Addr property
Mar 23, 2002  V1.17 In ProcessClientCommand, truncate at 1024 bytes for display
Mar 28, 2002  V1.18 Made ClientClass a public property
Apr 09, 2002  V1.19 Implemented datagram and datagram types feature.
              This allows a server to send datagram to connected clients.
Jul 19, 2002  V1.19 Ignore send exceptions in SendResponseToClient
Aug 13, 2002  V1.20 Use CliWsocket.ServerObject reference in
              LinkClientWSocketAndServerObject and CliSessionClosed.
Sep 02, 2002  V1.21 Added FOnServerSObjException event.
Sep 08, 2002  V1.22 Changed PChar to Pointer in TProcessRequestEvent and
              TClientCommandEvent.
Sep 26, 2002  V1.23 Added CmdBuf and CmdLen to OnServerSObjException event.
              Added FunctionCode to error message when a TServerObject crashed.
Nov 27, 2002  V1.24 Added ListenBacklog property, default to 5.
Sep 27, 2003  V1.25 Fixed ProcessClientCommand to correctly truncate data
              after Max_Display_len characters.Thanks to Marcel Isler
              <goodfun@goodfun.org> for finding this bug.
Aug 28, 2004  V1.26 Use MWDefs.inc
Jun 18, 2005  V2.00 Use TWSocketServer.
              That's the begining of the SSL enabled version.
Sep 13, 2005  V2.01 Propagated FSrvWSocket.OnBgExecption to
              TAppServer.OnServerBgException (See SrvWSocketBgException).
              Avoid closing server socket when exception occur during early
              client connection phase so that the server stay up and running.
Oct 03, 2005  V2.02 Added _OSVERSIONINFOA for Delphi 3.
              Thanks to Rocco Neri <rocco.neri@corael.it> for his help.
Oct 23, 2005  V2.03 Updated for Delphi 2006 and BCB 2006
Feb 18, 2007  V2.03 Added SetName and related.


 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit ApServer;

{$ifdef FPC}
  {$MODE DELPHI}
{$endif}

interface

{$I MWDEFS.INC}

uses
    Windows, Messages, SysUtils, Classes, StdCtrls, ExtCtrls,
{ You must define USE_SSL so that SSL code is included in the component.    }
{ To be able to compile the component, you must have the SSL related files  }
{ which are _NOT_ freeware. See http://www.overbyte.be for details.         }
{$IFDEF USE_SSL}
    IcsSSLEAY, IcsLIBEAY,
{$ENDIF}
    RBroker, RFormat, ApSrvCli, WSocket, WSocketS, WinSock;

const
    ApServerVersion    = 204;
    CopyRight : String = ' TAppServer (c) 1998-2007 F. Piette V2.07 ';
    WM_DESTROY_CLIENT_SOCKET = WM_USER + 1;

{$IFDEF DELPHI3}
type
    // Missing from Delphi 3 Windows unit
    _OSVERSIONINFOA = record
        dwOSVersionInfoSize: DWORD;
        dwMajorVersion: DWORD;
        dwMinorVersion: DWORD;
        dwBuildNumber: DWORD;
        dwPlatformId: DWORD;
        szCSDVersion: array[0..127] of AnsiChar;
    end;
    TOSVersionInfoA = _OSVERSIONINFOA;
    TOSVersionInfo  = TOSVersionInfoA;
    POSVersionInfoA = ^TOSVersionInfoA;
    POSVersionInfo  = POSVersionInfoA;
    OSVERSIONINFO   = _OSVERSIONINFOA;

function GetVersionEx(var lpVersionInformation: TOSVersionInfo): BOOL; stdcall;
{$ENDIF}

type
    EAppServerException  = class(Exception);
    TClientEvent         = procedure (Sender       : TObject;
                                      CliWSocket   : TClientWSocket) of object;
    TClientCommandEvent  = procedure (Sender       : TObject;
                                      CliWSocket   : TClientWSocket;
                                      CmdBuf       : Pointer;
                                      CmdLen       : Integer) of object;
    TClientTimeoutEvent  = procedure (Sender       : TObject;
                                      CliWSocket   : TClientWSocket;
                                      var CanClose : Boolean) of object;
    TClientBgException   = procedure (Sender       : TObject;
                                      CliWSocket   : TClientWSocket;
                                      E            : Exception) of object;
    TProcessRequestEvent = procedure (Sender       : TObject;
                                      CliWSocket   : TClientWSocket;
                                      var CmdBuf   : Pointer;
                                      var CmdLen   : Integer) of object;
    TAppServerBgExceptionEvent = procedure (Sender : TObject;
                                            E : Exception) of object;
    TAppServerSObjExceptionEvent = procedure (Sender : TObject;
                                              E      : Exception;
                                              CmdBuf : Pointer;
                                              CmdLen : Integer) of object;
    TAppServerOption     = (asoAutoStart,
                            asoDisplayCommands,
                            asoDisplayClientCount,
                            asoDisplayDatagrams);
    TAppServerOptions    = set of TAppServerOption;
    TClientWSocketClass  = class of TClientWSocket;

    {:TAppServer component is responsible for client connection, communication
      and management. It is constitued of a listening TWSocket receiving client
      connections. For each connection a new TClientWSocket is instanciated.
      TAppServer work with a linked TRequestBroker which manage to execute
      client request. }
    TAppServer = class(TComponent)
    protected
        FAddr                   : String;
        FBanner                 : String;
        FDisplayMemo            : TCustomMemo;
        FClientCountLabel       : TLabel;
        FRequestCount           : LongInt;
        FConnectCount           : LongInt;
        FRequestBroker          : TRequestBroker;
        FSrvWSocket             : TWSocketServer;
        FClientClass            : TClientWSocketClass;
        FPort                   : String;
        FHandle                 : HWND;
        FClientTimeout          : LongInt;          { in seconds }
        FTimeoutInterval        : LongInt;          { in seconds }
        FTimer                  : TTimer;
        FSysVersionInfo         : _OSVersionInfoA;
        FListenBacklog          : Integer;
        FOptions                : TAppServerOptions;
        FOnDisplay              : TDisplayEvent;
        FOnClientConnected      : TClientEvent;
        FOnClientClosed         : TClientEvent;
        FOnClientCommand        : TClientCommandEvent;
        FOnClientTimeout        : TClientTimeoutEvent;
        FOnClientBgException    : TClientBgException;
        FOnBeforeSendReply      : TClientEvent;
        FOnAfterSendReply       : TClientEvent;
        FOnBeforeProcessRequest : TProcessRequestEvent;
        FOnAfterProcessRequest  : TProcessRequestEvent;
        FOnServerBgException    : TAppServerBgExceptionEvent;
        FOnServerSObjException  : TAppServerSObjExceptionEvent;
        procedure   WndProc(var MsgRec: TMessage); virtual;
        procedure   CreateSocket; virtual;
        procedure   SetClientClass(const Value: TClientWSocketClass); virtual;
        procedure   Notification(AComponent: TComponent; operation: TOperation); override;
        procedure   SrvWSocketClientConnect(Sender  : TObject;
                                            Client  : TWSocketClient;
                                            ErrCode : Word); virtual;
        procedure   SrvWSocketClientDisconnect(Sender  : TObject;
                                               Client  : TWSocketClient;
                                               ErrCode : Word); virtual;
        procedure   SrvWSocketBgException(Sender       : TObject;
                                          E            : Exception;
                                          var CanClose : Boolean);
        procedure   SendResponseToClient(Dest     : TObject;
                                         ORB      : TRequestBroker;
                                         Status   : Integer;
                                         Response : PChar;
                                         Len      : Integer); virtual;
        procedure   SendStringResponseToClient(
                                         Dest     : TObject;
                                         ORB      : TRequestBroker;
                                         Status   : Integer;
                                         Response : String); virtual;
        procedure   ProcessClientCommand(Sender : TObject;
                                         CmdBuf : PChar;
                                         CmdLen : Integer); virtual;
        procedure   ProcessClientBgException(Sender : TObject;
                                             E      : Exception;
                                             var CanClose : Boolean); virtual;
        procedure   ProcessClientOverflow(Sender       : TObject;
                                          var CanAbort : Boolean); virtual;
        function    GetClientCount : Integer;
        function    GetClientWSocket(nIndex : Integer) : TClientWSocket;
        procedure   SetClientTimeout(newValue : LongInt);
        procedure   SetTimeoutInterval(newValue : LongInt);
        procedure   TimerTimer(Sender : TObject);
        procedure   CliTimeout(Sender : TObject; var CanClose : Boolean); virtual;
        procedure   Loaded; override;
        procedure   InternalDisplay(Sender : TObject; const Msg : String);
        procedure   TriggerBgException(E: Exception); virtual;
        procedure   TriggerServerSObjException(E: Exception;
                                               CmdBuf : Pointer;
                                               CmdLen : Integer); virtual;
        procedure   LinkClientWSocketAndServerObject(ServerObject : TServerObject; Cli : TObject);
        procedure   SetName(const NewName: TComponentName); override;
    public
        constructor Create(AOwner: TComponent); override;
        destructor  Destroy; override;
        {:The start procedure will start the server. The server will accept new
          client connections. }
        procedure   Start;
        {:The Stop procedure will stop the server which will no more accept
          new clients, but will not disconnect already connected clients. }
        procedure   Stop;
        {:DisconnectAll will disconnect every connected client. Do not confuse
          with the Stop procedure. }
        procedure   DisconnectAll;
        {:SendDatagramToClient will send a datagram to the specified client }
        procedure   SendDatagramToClient(ToClient        : TObject;
                                         const DGramType : String;
                                         Datagram        : PChar;
                                         DataLen         : Integer);
        {:SrvWSocket is the underlayng TWSocketServer component. }
        property SrvWSocket    : TWSocketServer    read  FSrvWSocket;
        {:ClientCount gives the actual numlber of connected clients. }
        property ClientCount   : Integer           read  GetClientCount;
        {:ConnectCount gives the total number of connection received since
          server startup}
        property ConnectCount  : LongInt           read  FConnectCount;
        {:RequestCount gives the total number of request received since
          server startup}
        property RequestCount  : LongInt           read  FRequestCount;
        {:ClientWSocket is an indexed property whose value is the reference to
          each connected client. }
        property ClientWSocket[nIndex : Integer] : TClientWSocket
                                                   read  GetClientWSocket;
        {:The Handle property is the windows handle for the hidden window
          the component uses for internal messages. }
        property Handle        : HWND              read  FHandle;
        {:The ClientClass property allows the programmer to change the class
          instanciated for each new client connection. This class is the right
          place to put data for client session. }
        property ClientClass   : TClientWSocketClass
                                                   read  FClientClass
                                                   write SetClientClass;
    published
        property DisplayMemo   : TCustomMemo       read  FDisplayMemo
                                                   write FDisplayMemo;
        property ClientCountLabel : TLabel         read  FClientCountLabel
                                                   write FClientCountLabel;
        property Options       : TAppServerOptions read  FOptions
                                                   write FOptions;
        {:The banner property is the text that is sent to the client when
          the connection has been established. This banner can be anything
          because the client ignore it. }
        property Banner        : String            read  FBanner
                                                   write FBanner;
        {:The Addr property allows to select the inteface which will be used
          to listen to client. The default value is '0.0.0.0' make the
          component listen on all available interfaces. }
        property Addr          : String            read  FAddr
                                                   write FAddr;
        {:The port property gives the port number used by the server to
          listen for client connection. It can be a numeric value or a
          string value which must be present in the 'services' file.
          You should not use any port number already used in your computer.
          This default value is 2106. }
        property Port          : String            read  FPort
                                                   write FPort;
        {:ClientTimeout gives the time in seconds before the server
          disconnect a client without activity. The default value is 300
          seconds. }
        property ClientTimeout : LongInt           read  FClientTimeout
                                                   write SetClientTimeout;
        {:The server periodically check for client timeout. It uses a single
          TTimer component for this check. The TimeoutInterval is this timer
          interval and default to 30 seconds. This means that every 30", the
          server will goes thru the client list and check for timeout. A
          smaller value gives better accuracy in timeout detection, but
          produce some overhead, specially if the number of client is large. }
        property TimeoutInterval : LongInt         read  FTimeoutInterval
                                                   write SetTimeoutInterval;
        {:The server component receive client request, data parameters and
          send replies to client. But it delegate the request dispatching to
          a dedicated component: the RequestBroker component. }
        property RequestBroker : TRequestBroker    read  FRequestBroker
                                                   write FRequestBroker;

        {:The socket component has a connection backlog queue. This gives the
          number of pending connection requests. Default to 5. }
        property ListenBacklog : Integer           read  FListenBacklog
                                                   write FListenBacklog;
        {:Sometimes, the server can display some infos about his internal
          working. Each time the server wants to display that info, it triggers
          the OnDisplay event. There is no need to have an event handler
          connected to this event. If you ad an event handler, it is probably
          to display the messages on the server's user interface, or just to
          log it into a file. Messages to be displayed can be generate by
          the TAppServer component or any TServerObject used in the server. }
        property OnDisplay     : TDisplayEvent     read  FOnDisplay
                                                   write FOnDisplay;
        {:This event is triggered when a client connect to the server.
          It could be used to disconnect unwanted client or any other
          processing that must be done when a new client connect, such as
          updating the server user interface to show how many clients are
          connected. }
        property OnClientConnected : TClientEvent  read  FOnClientConnected
                                                   write FOnClientConnected;
        {:When a client disconnect, the OnClientClosed event is triggered.
          The event handler could be used to update the server's user interface
          or to do any other post-processing or cleaning task. }
        property OnClientClosed    : TClientEvent  read  FOnClientClosed
                                                   write FOnClientClosed;
        {:Clients connects to the server to send commands (also called requests)
          and wait for server responses. The OnClientCommand is triggered when
          such a command arrives, before it gets executed. The event handler
          can use the command for any purpose, it can even change it. }
        property OnClientCommand   : TClientCommandEvent
                                                   read  FOnClientCommand
                                                   write FOnClientCommand;
        {:When a client had no more activity during some time specified by the
          ClientTimeout property, it is automatically disconnected. If this
          occurs, the OnClientTimeout event is triggred. }
        property OnClientTimeout   : TClientTimeoutEvent
                                                   read  FOnClientTimeout
                                                   write FOnClientTimeout;
        {:When an exception is triggered in the background. }
        property OnClientBgException : TClientBgException
                                                   read  FOnClientBgException
                                                   write FOnClientBgException;

        {:The OnBeforeSendReply event is called when a reply is ready to be
          transmitted to the client. A reply is made of a header and a body
          which are accessible thru the CliWSocket properties. The event
          has the possibility to process the header and answer to encrypt or
          compress them. It can even allocate some memory for holding the
          processed header and body. Use the OnAfterSendReply to free any
          allocated memory. The processed data must *not* contains CR/LF
          pair as it is used by the client to delimit the reply. If processed
          data has CR/LF, then it must be escaped in some way. }
        property OnBeforeSendReply : TClientEvent  read  FOnBeforeSendReply
                                                   write FOnBeforeSendReply;
        {:The OnAfterSendReply event is called once the reply header and body
          has ben written to the internal buffer for sending in the background.
          It's the right place to deallocate any resource allocated in the
          OnBeforeSendReply. }
        property OnAfterSendReply  : TClientEvent  read  FOnAfterSendReply
                                                   write FOnAfterSendReply;
        {:The OnBeforeProcessRequest event is triggered just before anything is
          done with a request received from the client. This is the right place
          to add code for decryption/decompression. If needed, the event
          handler can allocate memory or resources and change the values on
          the arguments (passed by var) to fit the requirement. Allocated
          resources must be freed from the OnAfterProcessCommand. }
        property OnBeforeProcessRequest : TProcessRequestEvent
                                                   read  FOnBeforeProcessRequest
                                                   write FOnBeforeProcessRequest;
        {:The OnAfterProcessRequest is called when a request has been
          transformed to a command for execution. It main purpose is to
          cleanup resources allocated in the OnBeforeProcessRequest event. }
        property OnAfterProcessRequest  : TProcessRequestEvent
                                                   read  FOnAfterProcessRequest
                                                   write FOnAfterProcessRequest;
        {:The OnBgException event is triggered when an exception occurs in the
          background (occuring in an event handler called from the message
          pump). If not handled, those exceptions are simply ignored. }
        property OnServerBgException    : TAppServerBgExceptionEvent
                                                    read  FOnServerBgException
                                                    write FOnServerBgException;
        {:The OnServerSObjException event is triggered when a TServerObject
          triggers an unhandled exception. }
        property OnServerSObjException  : TAppServerSObjExceptionEvent
                                                    read  FOnServerSObjException
                                                    write FOnServerSObjException;
    end;

{ You must define USE_SSL so that SSL code is included in the component.    }
{ To be able to compile the component, you must have the SSL related files  }
{ which are _NOT_ freeware. See http://www.overbyte.be for details.         }
{$IFDEF USE_SSL}
    {$I ApServerIntfSsl.inc}
{$ENDIF}

procedure Register;

implementation

var
    GClientWSocketID : Integer;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure Register;
begin
    RegisterComponents('FPiette', [TAppServer
{$IFDEF USE_SSL}
                                 , TSslAppServer
{$ENDIF}
                                  ]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFDEF DELPHI3}
// Missing from Delphi 3 Windows unit
function GetVersionEx; external kernel32 name 'GetVersionExA';
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ This function is a callback function. It means that it is called by       }
{ windows. This is the very low level message handler procedure setup to    }
{ handle the message sent by windows to handle messages.                    }
function AppServerWindowProc(
    ahWnd   : HWND;
    auMsg   : Integer;
    awParam : WPARAM;
    alParam : LPARAM): Integer; stdcall;
var
    Obj    : TObject;
    MsgRec : TMessage;
begin
    { At window creation asked windows to store a pointer to our object     }
    Obj := TObject(GetWindowLong(ahWnd, 0));

    { If the pointer doesn't represent a TAppServer, just call the default  }
    { procedure                                                             }
    if not (Obj is TAppServer) then
        Result := DefWindowProc(ahWnd, auMsg, awParam, alParam)
    else begin
        { Delphi use a TMessage type to pass parameter to his own kind of   }
        { windows procedure. So we are doing the same...                    }
        MsgRec.Msg    := auMsg;
        MsgRec.wParam := awParam;
        MsgRec.lParam := alParam;
        { May be a try/except around next line is needed. Not sure ! }
        TAppServer(Obj).WndProc(MsgRec);
        Result := MsgRec.Result;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ This global variable is used to store the windows class characteristic    }
{ and is needed to register the window class used by TWSocket               }
var
    AppServerWindowClass: TWndClass = (
        style         : 0;
        lpfnWndProc   : @AppServerWindowProc;
        cbClsExtra    : 0;
        cbWndExtra    : SizeOf(Pointer);
        hInstance     : 0;
        hIcon         : 0;
        hCursor       : 0;
        hbrBackground : 0;
        lpszMenuName  : nil;
        lpszClassName : 'AppServerWindowClass');


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Allocate a window handle. This means registering a window class the first }
{ time we are called, and creating a new window each time we are called.    }
function AppServerAllocateHWnd(Obj : TObject): HWND;
var
    TempClass       : TWndClass;
    ClassRegistered : Boolean;
begin
    { Check if the window class is already registered                       }
    AppServerWindowClass.hInstance := HInstance;
    ClassRegistered := GetClassInfo(HInstance,
                                    AppServerWindowClass.lpszClassName,
                                    TempClass);
    if not ClassRegistered then begin
       { Not yet registered, do it right now                                }
       Result := Windows.RegisterClass(AppServerWindowClass);
       if Result = 0 then
           Exit;
    end;

    { Now create a new window                                               }
    Result := CreateWindowEx(WS_EX_TOOLWINDOW,
                             AppServerWindowClass.lpszClassName,
                             '',        { Window name   }
                             WS_POPUP,  { Window Style  }
                             0, 0,      { X, Y          }
                             0, 0,      { Width, Height }
                             0,         { hWndParent    }
                             0,         { hMenu         }
                             HInstance, { hInstance     }
                             nil);      { CreateParam   }

    { if successfull, the ask windows to store the object reference         }
    { into the reserved byte (see RegisterClass)                            }
    if (Result <> 0) and Assigned(Obj) then
        SetWindowLong(Result, 0, Integer(Obj));
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Free the window handle                                                    }
procedure AppServerDeallocateHWnd(Wnd: HWND);
begin
    DestroyWindow(Wnd);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
constructor TAppServer.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    FBanner          := 'Welcome to MidWare server';
    FHandle          := AppServerAllocateHWnd(Self); // 14/02/99 AllocateHWnd(WndProc);
    CreateSocket;
//    FClientList      := TList.Create;
    FClientTimeout   := 300;           { 5 minutes timeout              }
    FTimeoutInterval := 30;            { Check timeout every 30 seconds }
    FTimer           := TTimer.Create(Self);
    FTimer.Name      := 'Timer_AppServer';
    FTimer.Enabled   := FALSE;
    FTimer.OnTimer   := TimerTimer;
    FTimer.Interval  := FTimeoutInterval * 1000;
    FOptions         := [asoDisplayCommands, asoDisplayClientCount];
    FListenBacklog   := 5;
    FSysVersionInfo.dwOSVersionInfoSize := SizeOf(OSVERSIONINFO);
    GetVersionEx(FSysVersionInfo);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
destructor TAppServer.Destroy;
begin
    try
//        if Assigned(FClientList) then begin
//            FClientList.Destroy;
//            FClientList := nil;
//        end;
        if Assigned(FSrvWSocket) then begin
            FSrvWSocket.Destroy;
            FSrvWSocket := nil;
        end;
        if Assigned(FTimer) then begin
            FTimer.Destroy;
            FTimer := nil;
        end;
    except
        { Ignore any exception, we cannot handle them }
    end;
    AppServerDeallocateHWnd(FHandle); // 14/02/99 DeallocateHWnd(FHandle);
    inherited Destroy;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TAppServer.CreateSocket;
begin
    FClientClass            := TClientWSocket;
    FSrvWSocket             := TWSocketServer.Create(Self);
    FSrvWSocket.Name        := 'AppServer_WSocket';
    FSrvWSocket.ClientClass := FClientClass;
    FAddr                   := '0.0.0.0';
    FPort                   := '2106';
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TAppServer.Loaded;
begin
    inherited Loaded;
    if csDesigning in ComponentState then
        Exit;
    if (asoDisplayClientCount in FOptions) and Assigned(FClientCountLabel) then
        FClientCountLabel.Caption := '0';
    if asoAutoStart in FOptions then
        Start;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ All exceptions *MUST* be handled. If an exception is not handled, the     }
{ application will be shut down !                                           }
procedure TAppServer.TriggerBgException(E: Exception);
begin
    { First call the error event handler, if any }
    if Assigned(FOnServerBgException) then begin
        try
            FOnServerBgException(Self, E);
        except
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ All exceptions *MUST* be handled. If an exception is not handled, the     }
{ application will be shut down !                                           }
procedure TAppServer.TriggerServerSObjException(
    E      : Exception;
    CmdBuf : Pointer;
    CmdLen : Integer);
begin
    if Assigned(FOnServerSObjException) then begin
        try
            FOnServerSObjException(Self, E, CmdBuf, CmdLen);
        except
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TAppServer.WndProc(var MsgRec: TMessage);
begin
    try  // 14/02/99
         with MsgRec do begin
//             if Msg = WM_DESTROY_CLIENT_SOCKET then
//                 TClientWSocket(lParam).Destroy
//             else
                 Result := DefWindowProc(Handle, Msg, wParam, lParam);
        end;
    except
        on E:Exception do
            TriggerBgException(E);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TAppServer.Notification(AComponent: TComponent; operation: TOperation);
begin
    inherited Notification(AComponent, operation);
    if operation = opRemove then begin
        if AComponent = FRequestBroker then
            FRequestBroker := nil
        else if AComponent = FSrvWSocket then
            FSrvWSocket := nil
        else if AComponent = FClientCountLabel then
            FClientCountLabel := nil
        else if AComponent = FDisplayMemo then
            FDisplayMemo := nil;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TAppServer.DisconnectAll;
var
    I : Integer;
begin
    for I := FSrvWSocket.ClientCount - 1 downto 0 do
        FSrvWSocket.Client[0].Close;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TAppServer.Start;
begin
    if not Assigned(FSrvWSocket) then
        Exit;
    FSrvWSocket.Close;
    FSrvWSocket.Proto              := 'tcp';
    FSrvWSocket.Port               := FPort;
    FSrvWSocket.Addr               := FAddr;
    FSrvWSocket.Banner             := FBanner;
    FSrvWSocket.OnClientConnect    := SrvWSocketClientConnect;
    FSrvWSocket.OnClientDisconnect := SrvWSocketClientDisconnect;
    FSrvWSocket.OnBgException      := SrvWSocketBgException;
    FSrvWSocket.ListenBacklog      := FListenBacklog;
    FSrvWSocket.Listen;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TAppServer.Stop;
begin
    if not Assigned(FSrvWSocket) then
        Exit;
    FSrvWSocket.Close;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TAppServer.InternalDisplay(Sender : TObject; const Msg : String);
begin
    try
        FDisplayMemo.Lines.BeginUpdate;
        try
            if FDisplayMemo.Lines.Count > 200 then begin
                while FDisplayMemo.Lines.Count > 200 do
                    FDisplayMemo.Lines.Delete(0);
            end;
            if Assigned(FDisplayMemo) then
                FDisplayMemo.Lines.Add(Msg);
        finally
            FDisplayMemo.Lines.EndUpdate;
            SendMessage(FDisplayMemo.Handle, EM_SCROLLCARET, 0, 0);
        end;
    except
    end;
    try
        if Assigned(FOnDisplay) then
            FOnDisplay(Sender, Msg);
    except
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TAppServer.SrvWSocketClientConnect(
    Sender  : TObject;
    Client  : TWSocketClient;
    ErrCode : Word);
var
    CliWSocket : TClientWSocket;
begin
    CliWSocket := Client as TClientWSocket;

    { Give a unique name to this client socket }
    Inc(GClientWSocketID);
    CliWSocket.Name            := Copy(CliWSocket.ClassName, 2, 64) + '_' +
                                  Self.Name + '_' + IntToStr(GClientWSocketID);

    CliWSocket.OnDisplay       := InternalDisplay;
    CliWSocket.OnOverflow      := ProcessClientOverflow;
    CliWSocket.OnCommand       := ProcessClientCommand;
    CliWSocket.OnBgException   := ProcessClientBgException;
    CliWSocket.OnTimeout       := CliTimeout;
    CliWSocket.Banner          := FBanner;
    CliWSocket.LineEnd         := #13#10;
    CliWSocket.CommandTimeOut  := FClientTimeout / (24 * 3600);
    if Assigned(FClientCountLabel) and (asoDisplayClientCount in FOptions) then
        FClientCountLabel.Caption := IntToStr(FSrvWSocket.ClientCount);
    if Assigned(FOnClientConnected) then begin
        // Should I move this Sleep outside of the above if ?
        if FSysVersionInfo.dwMajorVersion = 5 then
            Sleep(100);      // If OS is Windows 2000 then "sleep" for 100 ms
        FOnClientConnected(Self, CliWSocket);
    end;
    { We have a client, we need to check for timeout }
    if FTimeoutInterval > 0 then
        FTimer.Enabled  := TRUE;
    Inc(FConnectCount);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TAppServer.SrvWSocketClientDisconnect(
    Sender : TObject;
    Client : TWSocketClient;
    ErrCode: Word);
var
    CliWSocket : TClientWSocket;
begin
    CliWSocket := Client as TClientWSocket;

    if Assigned(FOnClientClosed) then
        FOnClientClosed(Self, CliWSocket);

    { Remove reference to this CliWSocket from TServerObject }
    if Assigned(CliWSocket.ServerObject) then begin
        if Assigned(TServerObject(CliWSocket.ServerObject).OrbDataPtr) then
            TServerObject(CliWSocket.ServerObject).OrbDataPtr.Tag := nil;
    end;

    if (asoDisplayClientCount in FOptions) and Assigned(FClientCountLabel) then
        FClientCountLabel.Caption := IntToStr(FSrvWSocket.ClientCount - 1);

    { Do we still need to check for timeout ? }
    if (FSrvWSocket.ClientCount <= 1) and Assigned(FTimer) then
        FTimer.Enabled  := FALSE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TAppServer.CliTimeout(Sender : TObject; var CanClose : Boolean);
var
    CliWSocket : TClientWSocket;
begin
    CliWSocket := Sender as TClientWSocket;

    if Assigned(FOnClientTimeout) then
        FOnClientTimeout(Self, CliWSocket, canClose);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TAppServer.SendResponseToClient(
    Dest     : TObject;
    ORB      : TRequestBroker;
    Status   : Integer;
    Response : PChar;
    Len      : Integer);
var
    CliWSocket : TClientWSocket;
    Header     : String;
begin
    { Verify that the Dest is still in our client list }
    { It is removed if the client disconnected         }
    if not FSrvWSocket.IsClient(Dest) then
        Exit;

    { The client is still there, send the result }
    CliWSocket := Dest as TClientWSocket;
    Header     := IntToStr(Status) + ' ';
    CliWSocket.ReplyHeader    := PChar(Header);
    CliWSocket.ReplyHeaderLen := Length(Header);
    CliWSocket.ReplyBody      := Response;
    CliWSocket.ReplyBodyLen   := Len;
    if Assigned(FOnBeforeSendReply) then
        FOnBeforeSendReply(Self, CliWSocket);
    try
        CliWSocket.SendReply;
    except
        // Ignore any exception while trying to send data
        // Client maybe dead !
    end;
    if Assigned(FOnAfterSendReply) then
        FOnAfterSendReply(Self, CliWSocket);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TAppServer.SendStringResponseToClient(
    Dest     : TObject;
    ORB      : TRequestBroker;
    Status   : Integer;
    Response : String);
var
    Buffer     : TMWBuffer;
begin
    Buffer := TMWBuffer.Create(nil);
    try
        Buffer.DataBufferSize := 256; { Remember, there is AutoExpand }
        Buffer.WriteFields(TRUE, [Response]);
        SendResponseToClient(Dest, ORB, Status,
                             Buffer.DataBuffer, Buffer.DataBufferCount);
    finally
        Buffer.Destroy;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TAppServer.ProcessClientOverflow(
    Sender : TObject;
    var CanAbort : Boolean);
var
    CliWSocket : TClientWSocket;
begin
    try
        CliWSocket := Sender as TClientWSocket;
        if Assigned(FDisplayMemo) then
            FDisplayMemo.Lines.Add(CliWSocket.PeerAddr + ' Input buffer overflow');

        SendStringResponseToClient(CliWSocket, FRequestBroker, 406,
                                   'Input buffer at server overflowed');
    except
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TAppServer.SrvWSocketBgException(
    Sender : TObject;
    E      : Exception;
    var CanClose : Boolean);
begin
    CanClose := FALSE;
    TriggerBgException(E);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TAppServer.ProcessClientBgException(
    Sender : TObject;
    E      : Exception;
    var CanClose : Boolean);
var
    CliWSocket : TClientWSocket;
begin
    CliWSocket := Sender as TClientWSocket;
    if Assigned(FOnClientBgException) then
        FOnClientBgException(Self, CliWSocket, E);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TAppServer.ProcessClientCommand(
    Sender : TObject;
    CmdBuf : PChar;
    CmdLen : Integer);
const
    Max_Display_len = 256;
var
    CliWSocket  : TClientWSocket;
    Buffer      : String;
    BufFct      : String;
    I           : Integer;
    Ch          : Char;
    HasDatagram : Boolean;
    DGramType   : String;
begin
    CliWSocket := Sender as TClientWSocket;

    if Assigned(FOnBeforeProcessRequest) then
        FOnBeforeProcessRequest(Self, CliWSocket, Pointer(CmdBuf), CmdLen);

    if CmdLen <= 0 then begin
        // OnBeforeProcessRequest handler has cleared command
        if Assigned(FOnAfterProcessRequest) then
            FOnAfterProcessRequest(Self, CliWSocket, Pointer(CmdBuf), CmdLen);
        Exit;
    end;

    try
        HasDatagram := ((CmdLen    >= 3) and
                        (CmdBuf[0]  = '^'));
        try
            if Assigned(FDisplayMemo) and
               (
                ((HasDatagram) and (asoDisplayDatagrams in FOptions)) or
                ((not HasDatagram) and (asoDisplayCommands in FOptions))
               ) then begin
                if CmdLen < Max_Display_len then
                    InternalDisplay(Self, CliWSocket.PeerAddr + ' ' + StrPas(CmdBuf))
                else begin
                    // Command is too long, truncate after Max_Display_len characters
                    Ch := CmdBuf[Max_Display_len];
                    CmdBuf[Max_Display_len] := #0;
                    InternalDisplay(Self, CliWSocket.PeerAddr + ' ' + StrPas(CmdBuf));
                    CmdBuf[Max_Display_len] := Ch;
                end;
            end;
        except
        end;
        if Assigned(FOnClientCommand) then
            FOnClientCommand(Self, CliWSocket, CmdBuf, CmdLen);

        if HasDatagram then begin
            { A datagram has been received }
            DGramType := '';
            I         := 1;
            while (CmdBuf[I] <> ' ') and (I < CmdLen) do
                Inc(I);
            DGramType := Copy(CmdBuf, 2, I - 1);
            CliWSocket.DatagramIn(DGramType, CmdBuf + I + 2, CmdLen - I - 2, CmdBuf[I + 1]);
            //CliWSocket.DatagramIn(CmdBuf + 3, CmdLen - 3, CmdBuf[2]);
        end
        else if CliWSocket.Busy then begin
            SendStringResponseToClient(CliWSocket, FRequestBroker, 405,
                                       'Server object is busy');
            CliWSocket.Busy := TRUE;   { We are still busy }
        end
        else begin
            CliWSocket.Busy := TRUE;
            try
                Inc(FRequestCount);
                if not Assigned(FRequestBroker) then begin
                    // This should never occurs in a correctly written AppServer
                    // Anyway, if RequestBroker is not assigned, send a valid
                    // answer to client.
                    SendStringResponseToClient(CliWSocket, FRequestBroker, 501,
                                               'No request broker available');
                end
                else begin
                    FRequestBroker.OnLinkClientWSocketAndServerObject :=
                        LinkClientWSocketAndServerObject;
                    FRequestBroker.OnAskClientWSocketToSendDatagram :=
                        SendDatagramToClient;
                    FRequestBroker.BrokeRequest(Self, CmdBuf, CmdLen, CliWSocket,
                                                SendResponseToClient);
                end;
            except
                on E:Exception do begin
                   TriggerServerSObjException(E, CmdBuf, CmdLen);
                   // Extract FunctionCode from CmdBuf, at most 64 characters
                   BufFct := '';
                   if CmdBuf <> nil then begin
                       I := 0;
                       while (I < CmdLen) and (I < 64) and (CmdBuf[I] <> ' ') do
                           Inc(I);
                       BufFct := Copy(CmdBuf, 1, I);
                   end;

                   Buffer := 'ServerObject crashed. Function "' +
                             BufFct + '". ' +
                             E.ClassName + ': ' + E.Message;
                   { Replace all CR or LF by spaces }
                   for I := 1 to Length(Buffer) do
                       if Buffer[I] in [#13, #10] then
                           Buffer[I] := ' ';
                   SendStringResponseToClient(CliWSocket, FRequestBroker, 404,
                                              Buffer);
                end;
            end;
        end;
    finally
        if Assigned(FOnAfterProcessRequest) then
            FOnAfterProcessRequest(Self, CliWSocket, Pointer(CmdBuf), CmdLen);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TAppServer.LinkClientWSocketAndServerObject(
    ServerObject : TServerObject;
    Cli          : TObject);
begin
    if Cli is TClientWSocket then begin
        if not Assigned(ServerObject) then begin
            TClientWSocket(Cli).OnDatagramAvailable := nil;
            TClientWSocket(Cli).OnDataSent          := nil;
            TClientWSocket(Cli).ServerObject        := nil;
        end
        else begin
            TClientWSocket(Cli).OnDatagramAvailable :=
                ServerObject.DatagramAvailable;
            TClientWSocket(Cli).OnDataSent          :=
                ServerObject.DataSent;
            TClientWSocket(Cli).ServerObject        := ServerObject;
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TAppServer.SendDatagramToClient(
    ToClient        : TObject;
    const DGramType : String;
    Datagram        : PChar;
    DataLen         : Integer);
var
    CliWSocket : TClientWSocket;
    Header     : String;
    EscChar    : Char;
    P          : PChar;
    I, J       : Integer;
begin
    if Length(DGramType) = 0 then
        raise EAppServerException.Create(
                  'SendDatagramToClient: DGramType is empty');

    for I := 1 to Length(DGramType) do begin
        if not (DGramType[I] in ['A'..'Z', 'a'..'z', '0'..'9', '_']) then
            raise EAppServerException.Create(
                      'SendDatagramToClient: ' +
                      'DGramType contains an invalid character');
    end;

    if (not Assigned(ToClient)) or (not (ToClient is TClientWSocket)) then
        raise EAppServerException.Create(
                  'SendDatagramToClient: Unsupported destination type');

    // Convert anonymous destination to easier type to handle
    CliWSocket := TClientWSocket(ToClient);

    // Hard coded delimiter. Could be a property...
    EscChar    := #127;

    // Allocate memory for the buffer
    if not Assigned(CliWSocket.DatagramOutBuffer) then begin
        if DataLen > (CliWSocket.DatagramOutBufferSize - 3) then
            CliWSocket.DatagramOutBufferSize := DataLen + 3;
        GetMem(P, CliWSocket.DatagramOutBufferSize);
        CliWSocket.DatagramOutBuffer := P;
    end;

    // Escape characters in datagram (same mechanism as implemented in TMWBuffer)
    I := 0;
    J := 0;
    while I < DataLen do begin
        // Check if we have enough place for an EscChar, a Char and a nul
        if (J + 3) > CliWSocket.DatagramOutBufferSize then begin
            // Need to enlarge buffer (2KB increment)
            CliWSocket.DatagramOutBufferSize := CliWSocket.DatagramOutBufferSize + 2048;
            P := CliWSocket.DatagramOutBuffer;
            ReallocMem(P, CliWSocket.DatagramOutBufferSize);
            CliWSocket.DatagramOutBuffer := P;
        end;
        if Datagram[I] = EscChar then begin
            CliWSocket.DatagramOutBuffer[J] := EscChar;
            Inc(J);
            CliWSocket.DatagramOutBuffer[J] := EscChar;
        end
        else if Datagram[I] = #13 then begin
            CliWSocket.DatagramOutBuffer[J] := EscChar;
            Inc(J);
            CliWSocket.DatagramOutBuffer[J] := 'C';
        end
        else if Datagram[I] = #10 then begin
            CliWSocket.DatagramOutBuffer[J] := EscChar;
            Inc(J);
            CliWSocket.DatagramOutBuffer[J] := 'L';
        end
        else if Datagram[I] = #0 then begin
            CliWSocket.DatagramOutBuffer[J] := EscChar;
            Inc(J);
            CliWSocket.DatagramOutBuffer[J] := 'N';
        end
        else
            CliWSocket.DatagramOutBuffer[J] := Datagram[I];
        Inc(I);
        Inc(J);
    end;
    CliWSocket.DatagramOutBuffer[J] := #0;

    Header                    := '^' + DGramType + ' ' + EscChar;
    CliWSocket.ReplyHeader    := PChar(Header);
    CliWSocket.ReplyHeaderLen := Length(Header);
    CliWSocket.ReplyBody      := CliWSocket.DatagramOutBuffer;
    CliWSocket.ReplyBodyLen   := J;
    if Assigned(FOnBeforeSendReply) then
        FOnBeforeSendReply(self, CliWSocket);
    CliWSocket.PutDataInSendBuffer(CliWSocket.ReplyHeader, CliWSocket.ReplyHeaderLen);
    CliWSocket.PutDataInSendBuffer(CliWSocket.ReplyBody,   CliWSocket.ReplyBodyLen);
    CliWSocket.PutStringInSendBuffer(#13+#10);
    CliWSocket.Send(nil, 0);
    if Assigned(FOnAfterSendReply) then
        FOnAfterSendReply(self, CliWSocket);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TAppServer.GetClientCount : Integer;
begin
     Result := FSrvWSocket.ClientCount
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TAppServer.GetClientWSocket(nIndex : Integer) : TClientWSocket;
begin
    if (nIndex >= 0) and
       (nIndex < FSrvWSocket.ClientCount) then
        Result := FSrvWSocket.Client[nIndex] as TClientWSocket
    else
        Result := nil;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TAppServer.SetTimeoutInterval(newValue : LongInt);
begin
    if newValue <= 0 then
        newValue := 0;
    if FTimeoutInterval = newValue then
        Exit;
    FTimeoutInterval := newValue;
    if FTimeoutInterval > 0 then
        FTimer.Interval := FTimeoutInterval * 1000
    else
        FTimer.Enabled  := FALSE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TAppServer.SetClientTimeout(newValue : LongInt);
var
    I : Integer;
begin
    if newValue < 0 then
        newValue := 0;
    if FClientTimeout = newValue then
        Exit;
    FClientTimeout := newValue;
    for I := FSrvWSocket.ClientCount - 1 downto 0 do begin
         TClientWSocket(FSrvWSocket.Client[I]).CommandTimeout :=
                 FClientTimeout / (24 * 3600);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TAppServer.TimerTimer(Sender : TObject);
var
    I : Integer;
begin
    if FTimeoutInterval > 0 then
        FTimer.Enabled := TRUE;
    for I := FSrvWSocket.ClientCount - 1 downto 0 do
         TClientWSocket(FSrvWSocket.Client[I]).CheckCommandTimeout;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TAppServer.SetClientClass(const Value: TClientWSocketClass);
begin
    FClientClass            := Value;
    FSrvWSocket.ClientClass := FClientClass;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TAppServer.SetName(const NewName: TComponentName);
begin
    inherited SetName(NewName);
    if Assigned(FSrvWSocket) then
        FSrvWSocket.Name := 'WSocketServer_' + NewName;
    if Assigned(FTimer) then
        FTimer.Name      := 'Timer_' + NewName;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ You must define USE_SSL so that SSL code is included in the component.    }
{ To be able to compile the component, you must have the SSL related files  }
{ which are _NOT_ freeware. See http://www.overbyte.be for details.         }
{$IFDEF USE_SSL}
    {$I ApServerImplSsl.inc}
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

end.

