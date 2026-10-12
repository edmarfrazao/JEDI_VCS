{*_* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Author:       François PIETTE
Description:  ClientWSocket component. It handle the client connection for
              the application server.
              Do not confuse TClientWSocket with TAppSrvClient which is the
              client application side. TClientWSocket is used on the server
              side to handle client connections, TAppSrvClient is used on the
              client side to connect to the application server. Both components
              are talking to each other.
Creation:     February 17, 1998
Version:      1.19
EMail:        francois.piette@overbyte.be   http://www.overbyte.be
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
Mar 27, 1998  V1.01 Added a ConnectedSince and LastCommand properties
              Added a Banner property, must be a single line
Apr 10, 1998  V1.01 Removed aSocket from StartConnection.
May 18, 1998  V1.03 Implemented command timeout to disconnect an inactive
              user after a period of inactivity (30 minutes by default).
              The CheckCommandTimeOut has to be called to make this feature
              work. It's the server component who do it. Using a TTimer here
              would consume too much resources.
Jun 01, 1998  V1.04 Removed beta status. Changed "legal stuff" to prohibe
              commercial applications whithout an agreement.
Jun 07, 1998  V1.05 Added ReplyHeader, ReplyHeaderLen, ReplyBody, ReplyBodyLen,
              and SendReply to allow easy encryption and compression
              implementation.
Jul 08, 1998  V1.06 Adapted for Delphi 4
Jul 13, 1998  V1.07 Corrected properties declaration order which prevented
              BCB to compile this unit, terminating on an internal error !
              Functions and procedure must be declared before any property.
              Added a register procedure to register the component.
Aug 17, 1998  V1.08 Added dynamic RcvBuf allocation, OnOverflow event and
              RcvBuf, RcvSizeInc and RcvSizeMax properties.
Dec 12, 1998  V1.09 Added background exception handling
Mar 24, 2002  V1.10 Reset RcvBuf to default size when command is executed and
              receive buffer emptyed.
Apr 09, 2002  V1.11 Implemented Datagram types and datagrams from server to
              client.
Aug 13, 2002  V1.12 added ServerObject property.
Oct 02, 2002  V1.13 In TClientWSocket.TriggerDataAvailable, checked if FRcvBuf
              is nul. This occurs when async TServerObject is used and client
              disconnect prematurely.
Aug 28, 2004  V1.14 Use MWDefs.inc
Jun 18, 2005  V1.15 TAppServer now use TWSocketServer. That's why TClientWSocket
              now derive from TWSocketClient instead of TCustomWSocket.
Sep 24, 2005  V1.16 Optimized DataAvailable handler to search for EOL only
              from the point where data has been received.
              Thanks to Bjørnar Nielsen <bjornar@sentinel.no>
Oct 08, 2005  V1.17 Uwe Schuster <jedivcs@bitcommander.de> implemented dynamic
              buffer allocation. If you set RcvSizeInc property to 0, then
              the component will increase the buffer by 25% instead of a 
              fixed value.
Oct 23, 2005 V1.18 Updated for Delphi 2006 and BCB 2006
Nov 05, 2005 V1.19 Uwe Schuster <jedivcs@bitcommander.de> updated the timeout
                   detection mechanism to avoid timeout while still transmitting



 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit ApSrvCli;

{$ifdef FPC}
  {$MODE DELPHI}
{$endif}

{$I MWDefs.inc}

interface

uses
    Windows, Messages, Classes, SysUtils, Winsock, WSocket, WSocketS;

const
    ApSrvCliVersion      = 119;
    CopyRight : String   = ' TClientWSocket (c) 1998-2006 F. Piette V1.19 ';
    DefaultRcvSize       = 65536;
    // USc 08/10/2005 zero means dynamic buffer increase(+ 1/4) -> see TriggerDataAvailable
    DefaultRcvSizeInc    = 0;
    DefaultRcvSizeMinInc = 65536; 
    DefaultRcvSizeMax    = 0;             { Unlimited size }
    WM_ABORT_REQUEST     = WM_USER + 10;

type
    ClientWSocketException = class(Exception);
    TDisplayEvent  = procedure (Sender : TObject; const Msg : String) of object;
    TCommandEvent  = procedure (Sender : TObject; CmdBuf : PChar; CmdLen : Integer) of object;
    TTimeoutEvent  = procedure (Sender : TObject; var CanClose : Boolean) of object;
    TOverflowEvent = procedure (Sender : TObject; var CanAbort : Boolean) of object;
    TDatagramAvailableEvent = procedure (Sender : TObject; const DGramType : String; Data : PChar; DataLen : Integer) of object;

    {:TClientWSocket is a specialized TWSocket which handle a single client
      connected to the application server. TAppServer component instanciate a
      new TClientWSocket for each new client connecting to the server. }
    TClientWSocket = class(TWSocketClient)
    protected
        FRcvBuf                : PChar;
        FRcvCnt                : Integer;
        FRcvSize               : Integer;
        FRcvSizeInc            : Integer;
        FRcvSizeMax            : Integer;
        FBusy                  : Boolean;
        FConnectedSince        : TDateTime;
        FLastCommandRXTime     : TDateTime;        
        FLastCommandTime       : TDateTime;
        FLastCommandTXTime     : TDateTime;
        FCommandCount          : LongInt;
        FCommandTimeOut        : TDateTime;
        FBanner                : String;
        FPeerAddr              : String;
        FReplyHeader           : PChar;
        FReplyHeaderLen        : Integer;
        FReplyBody             : PChar;
        FReplyBodyLen          : Integer;
        FUserData              : LongInt;
        FAbortRequest          : Boolean;
        FDatagramInBuffer      : PChar;
        FDatagramInBufferSize  : Integer;
        FDatagramOutBuffer     : PChar;
        FDatagramOutBufferSize : Integer;
        FServerObject          : TObject;
        FOnDisplay             : TDisplayEvent;
        FOnCommand             : TCommandEvent;
        FOnTimeout             : TTimeoutEvent;
        FOnOverflow            : TOverflowEvent;
        FOnDatagramAvailable   : TDatagramAvailableEvent;
        procedure TriggerSessionConnected(Error : Word); override;
        function  TriggerDataAvailable(Error : Word) : boolean; override;
        procedure TriggerCommand(CmdBuf : PChar; CmdLen : Integer); virtual;
        procedure TriggerTimeout(var CanClose : Boolean); virtual;
        procedure TriggerOverflow(var CanAbort : Boolean); virtual;
        procedure TriggerDatagramAvailable(const DGramType : String;
                                           Data            : PChar;
                                           DataLen         : Integer); virtual;
        function  RealSend(Data : Pointer; Len : Integer) : Integer; override;
        procedure SetRcvSize(newValue : Integer);
        procedure WndProc(var MsgRec: TMessage); override;
        procedure WMAbortRequest(var msg: TMessage); message WM_ABORT_REQUEST;
    public
        constructor Create(AOwner: TComponent); override;
        destructor  Destroy; override;
        {:First method to be invoked on client connection. It initializes
          internal working and send the banner to the client. }
        procedure   StartConnection; override;
        {:Procedure used by TAppServer to check for inactivity timeout. }
        procedure   CheckCommandTimeout; virtual;
        procedure   SendReply; virtual;
        procedure   Dup(newHSocket : TSocket); override;
        function    GetPeerAddr: string; override;
        procedure   DatagramIn(const DGramType : String;
                               Data            : PChar;
                               DataLen         : Integer;
                               EscChar         : Char); virtual;

        {:Store the client's IP address. The value is cached. }
        property    PeerAddr        : String    read  GetPeerAddr;
        {:Gives the time when the client connected. }
        property    ConnectedSince  : TDateTime read  FConnectedSince;
        {:Gives the time of the last command request data received. Use for timeout. }
        property    LastCommandRXTime : TDateTime read  FLastCommandRXTime;
        {:Gives the time of the last command received. Use for timeout. }
        property    LastCommandTime : TDateTime read  FLastCommandTime;
        {:Gives the time of the last command response data transmission. Use for timeout. }
        property    LastCommandTXTime : TDateTime read  FLastCommandTXTime;
        {:Number of commands issued by the client. }
        property    CommandCount    : LongInt   read  FCommandCount;
        {:Timeout value. If the client stay inactive for this period of
          time, the server will disconnect it. }
        property    CommandTimeOut  : TDateTime read  FCommandTimeOut
                                                write FCommandTimeout;
        {:The actual buffer used to store incomming data }
        property    RcvBuf : PChar              read  FRcvBuf;
        {:Inherited property giving the number of bytes received. }
        property    RcvdCount;
        {:ReplyHeader point to the header built by the AppServer based
          on reply status. }
        property    ReplyHeader : PChar         read  FReplyHeader
                                                write FReplyHeader;
        {:ReplyHeaderLen is the length in byte for the header. }
        property    ReplyHeaderLen : Integer    read  FReplyHeaderLen
                                                write FReplyHeaderLen;
        {:ReplyBody point to the answer to be sent to the client. }
        property    ReplyBody : PChar           read  FReplyBody
                                                write FReplyBody;
        {:ReplyBodyLen is the length in bytes for the answer. }
        property    ReplyBodyLen : Integer      read  FReplyBodyLen
                                                write FReplyBodyLen;
        property    LocalPort;
        property    OnDatagramAvailable : TDatagramAvailableEvent
                                                read  FOnDatagramAvailable
                                                write FOnDatagramAvailable;
        property    DatagramInBuffer      : PChar
                                                read  FDatagramInBuffer
                                                write FDatagramInBuffer;
        property    DatagramInBufferSize  : Integer
                                                read  FDatagramInBufferSize
                                                write FDatagramInBufferSize;
        property    DatagramOutBuffer     : PChar
                                                read  FDatagramOutBuffer
                                                write FDatagramOutBuffer;
        property    DatagramOutBufferSize : Integer
                                                read  FDatagramOutBufferSize
                                                write FDatagramOutBufferSize;
        property    ServerObject          : TObject
                                                read  FServerObject
                                                write FServerObject;
    published
        {:The banner to be sent to the client upon connection. }
        property Banner : String           read  FBanner
                                           write FBanner;
        {:Size of buffer used to receive commands (requests). }
        property RcvSize : integer         read  FRcvSize
                                           write SetRcvSize;
        {:When RcvSize is too small, the buffer will be enlarged by RcvSizeInc
          bytes automatically until RcvSizeMax is reached }
        property RcvSizeInc : Integer      read  FRcvSizeInc
                                           write FRcvSizeInc;
        {:Maximum size allowed for the RcvBuf }
        property RcvSizeMax : Integer      read  FRcvSizeMax
                                           write FRcvSizeMax;
        {:Tells if the previous request is still executing. }
        property Busy : Boolean            read  FBusy
                                           write FBusy;
        {:UserData is not user by middleware, it is left for the application
          programmer use. }
        property UserData : LongInt        read  FUserData
                                           write FUserData;
        {:Triggered when the component wants to display something on the user
          interface. }
        property OnDisplay : TDisplayEvent read  FOnDisplay
                                           write FOnDisplay;
        {:Triggered when a client request (command) is received. }
        property OnCommand : TCommandEvent read  FOnCommand
                                           write FOnCommand;
        {:Triggered when the client timedout as is about to be disconnected
          by TAppServer. }
        property OnTimeout : TTimeoutEvent read  FOnTimeout
                                           write FOnTimeout;
        {:Triggered when the input buffer is overflowed and can't be enlarged }
        property OnOverflow : TOverflowEvent
                                           read  FOnOverflow
                                           write FOnOverflow;
        {:Inherited event triggered when the client disconnect. }
        property OnSessionClosed;
        {:Inherited event triggered when an exception occurs in the background }
        property OnBgException;
        property OnDataSent;
        {:Inherited property giving the winsock handle. }
        property HSocket;
    end;

procedure Register;

implementation

const
    DefaultBanner = 'Hello from middleware Server';


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure Register;
begin
    RegisterComponents('FPiette', [TClientWSocket]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
constructor TClientWSocket.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    FBanner         := DefaultBanner;
    FCommandTimeOut := EncodeTime(0, 30, 0, 0);  { 30 minutes }
    FRcvSizeMax     := DefaultRcvSizeMax;
    FRcvSizeInc     := DefaultRcvSizeInc;
    if (DefaultRcvSizeMax <> 0) and (FRcvSizeMax < DefaultRcvSize) then
        SetRcvSize(DefaultRcvSizeMax)
    else
        SetRcvSize(DefaultRcvSize);
    FDatagramInBufferSize  := 2048;
    FDatagramInBuffer      := nil;
    FDatagramOutBufferSize := 2048;
    FDatagramOutBuffer     := nil;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
destructor TClientWSocket.Destroy;
begin
    FRcvCnt := 0;      { Cancel received data }
    SetRcvSize(0);     { Free the buffer      }
    if Assigned(FDatagramInBuffer) then begin
        FreeMem(FDatagramInBuffer, FDatagramInBufferSize);
        FDatagramInBuffer := nil;
    end;
    if Assigned(FDatagramOutBuffer) then begin
        FreeMem(FDatagramOutBuffer, FDatagramOutBufferSize);
        FDatagramOutBuffer := nil;
    end;
    inherited Destroy;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TClientWSocket.WndProc(var MsgRec: TMessage);
begin
    with MsgRec do begin
        if Msg = WM_ABORT_REQUEST then begin
            try
                WMAbortRequest(MsgRec)
            except
                on E:Exception do
                    HandleBackGroundException(E);
            end;
        end
        else
            inherited WndProc(MsgRec);
   end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TClientWSocket.WMAbortRequest(var msg: TMessage);
begin
    { Verify that the socket handle is ours handle }
    if msg.wParam <> HSocket then
        Exit;
    FAbortRequest := FALSE;
    Abort;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TClientWSocket.RealSend(Data : Pointer; Len : Integer) : Integer;
begin
    Result             := inherited RealSend(Data, Len);
    FLastCommandTXTime := Now;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TClientWSocket.SetRcvSize(newValue : Integer);
begin
    if FRcvSize < 0 then
        FRcvSize := 0;

    if FRcvSize = newValue then
        Exit; { No change, nothing to do }

    if (FRcvSizeMax > 0) and (newValue > FRcvSizeMax) then
        raise ClientWSocketException.Create(
            'Can''t expand receive buffer, max size (' + IntToStr(FRcvSizeMax) +
            ' bytes) has been reached');

    if newValue < FRcvCnt then
        raise ClientWSocketException.Create(
           'Can''t reduce buffer size now because data ' +
           'will not fit in new size');

    FRcvSize := newValue;
    ReallocMem(FRcvBuf, newValue);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TClientWSocket.StartConnection;
begin
    FConnectedSince    := Now;
    FLastCommandRXTime := 0;
    FLastCommandTime   := Now;
    FLastCommandTXTime := 0;
    FCommandCount      := 0;
    inherited StartConnection;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TClientWSocket.GetPeerAddr: String; // 20060729 Not needed: already done in the base class ?
begin
    Result := FPeerAddr;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TClientWSocket.Dup(newHSocket : TSocket);
begin
    inherited Dup(newHSocket);
    FPeerAddr := inherited GetPeerAddr;  // 20060729 Not needed: already done in the base class ?
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TClientWSocket.TriggerSessionConnected(Error : Word);
begin
    FAbortRequest := FALSE;
    FPeerAddr     := inherited GetPeerAddr;
    inherited TriggerSessionConnected(Error);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TClientWSocket.CheckCommandTimeout;
var
    CanClose : Boolean;
    MostRecentLastCommandTimeStamp: TDateTime;
begin
    if (State <> wsConnected) or (FCommandTimeOut <= 0) then
        Exit;
    MostRecentLastCommandTimeStamp := FLastCommandTXTime;
    if FLastCommandTime > MostRecentLastCommandTimeStamp then
      MostRecentLastCommandTimeStamp := FLastCommandTime;
    if FLastCommandRXTime > MostRecentLastCommandTimeStamp then
      MostRecentLastCommandTimeStamp := FLastCommandRXTime;
    if Now > (MostRecentLastCommandTimeStamp + FCommandTimeOut) then begin
        CanClose := TRUE;
        TriggerTimeout(CanClose);
        if CanClose then
            Close;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TClientWSocket.TriggerCommand(CmdBuf : PChar; CmdLen : Integer);
begin
    if Assigned(FOnCommand) then
        FOnCommand(Self, CmdBuf, CmdLen);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TClientWSocket.DatagramIn(
    const DGramType : String;
    Data            : PChar;
    DataLen         : Integer;
    EscChar         : Char);
var
    I, J : Integer;
begin
    // Allocate memory for the buffer if not already done
    if not Assigned(FDatagramInBuffer) then begin
        if DataLen >= FDatagramInBufferSize then
            FDatagramInBufferSize := DataLen + 2048;
        GetMem(FDatagramInBuffer, FDatagramInBufferSize);
    end
    else if FDatagramInBufferSize < DataLen then begin
        // Need to enlarge buffer (2KB increment)
        FDatagramInBufferSize := DataLen + 2048;
        ReallocMem(FDatagramInBuffer, FDatagramInBufferSize);
    end;

    I := 0;
    J := 0;
    while I < DataLen do begin
        if Data[I] <> EscChar then
            FDatagramInBuffer[J] := Data[I]
        else begin
            Inc(I);
            case Data[I] of
            'C': FDatagramInBuffer[J] := #13;
            'L': FDatagramInBuffer[J] := #10;
            'N': FDatagramInBuffer[J] := #0;
            else
                if Data[I] = EscChar then
                    FDatagramInBuffer[J] := EscChar
                else
                    FDatagramInBuffer[J] := Data[I];
            end;
        end;
        Inc(I);
        Inc(J);
    end;
    FDatagramInBuffer[J] := #0;  // Just easier to debug when nul termintated

    TriggerDatagramAvailable(DGramType, FDatagramInBuffer, J);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TClientWSocket.TriggerDatagramAvailable(
    const DGramType : String;
    Data            : PChar;
    DataLen         : Integer);
begin
    if Assigned(FOnDatagramAvailable) then
        FOnDatagramAvailable(Self, DGramType, Data, DataLen);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TClientWSocket.TriggerTimeout(var CanClose : Boolean);
begin
    if Assigned(FOnTimeout) then
        FOnTimeout(Self, CanClose);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TClientWSocket.TriggerOverflow(var CanAbort : Boolean);
begin
    if Assigned(FOnOverflow) then
        FOnOverflow(Self, CanAbort);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TClientWSocket.TriggerDataAvailable(Error : Word) : Boolean;
var
    Len               : Integer;
    I                 : Integer;
    CanAbort          : Boolean;
    AllowedInc        : Integer;
    CurrentRcvSizeInc : Integer;
begin
    if FAbortRequest then begin
        Result := FALSE;
        Exit;
    end;

    Result := TRUE;                                { We read data }
    { check space in buffer }
    if (FRcvSize - FRcvCnt - 1) <= 0 then begin
        { No space left, enlarge the buffer }
        try
            CurrentRcvSizeInc := FRcvSizeInc;
            if CurrentRcvSizeInc = 0 then begin // USc 08/10/2005 dynamic buffer increase
                CurrentRcvSizeInc := FRcvSize div 4;
                if CurrentRcvSizeInc < DefaultRcvSizeMinInc then
                    CurrentRcvSizeInc := DefaultRcvSizeMinInc;
            end;
            if FRcvSizeMax > 0 then begin
                AllowedInc := FRcvSizeMax - FRcvSize;
                if AllowedInc <= 0 then
                    raise ClientWSocketException.Create('');
                if AllowedInc > CurrentRcvSizeInc then
                    SetRcvSize(FRcvSize + CurrentRcvSizeInc)
                else
                    SetRcvSize(FRcvSize + AllowedInc);
            end
            else
                SetRcvSize(FRcvSize + CurrentRcvSizeInc);
        except
            CanAbort := TRUE;
            TriggerOverflow(CanAbort);
            if CanAbort then begin
                FAbortRequest := TRUE;
                PostMessage(Handle, WM_ABORT_REQUEST, HSocket, 0);
            end;
            { Buffer cannot be enlarged, cancel actual content }
            FRcvCnt := 0;
            Result  := FALSE;
            Exit;
        end;
    end;

    Len := Receive(@FRcvBuf[FRcvCnt], FRcvSize - FRcvCnt - 1);
    FLastCommandRXTime := Now;
    if Len <= 0 then
        Exit;

    FRcvCnt := FRcvCnt + Len;
    FRcvBuf[FRcvCnt] := #0;

    I := FRcvCnt - Len;  // 24/09/2005 Optimize eol search
    while TRUE do begin
        // I := 0;       // 24/09/2005 Optimize eol search
        while (I < FRcvCnt) and (FRcvBuf[I] <> #10) do
            Inc(I);
        if I >= FRcvCnt then
            Exit;
        FRcvBuf[I] := #0;
        FLastCommandTime := Now;
        Inc(FCommandCount);
        if (I > 1) and (FRcvBuf[I - 1] = #13) then begin
            FRcvBuf[I - 1] := #0;
            TriggerCommand(FRcvBuf, I - 1);
            if FRcvBuf = nil then         // Disconnected !
                break;
            FRcvBuf[I - 1] := #13;
        end
        else begin
            FRcvBuf[0] := #0;             // May 19, 2003. Clear #13
            TriggerCommand(FRcvBuf, I);
        end;

        FRcvBuf[I] := #10;
        if I >= (FRcvCnt - 1) then begin
            FRcvCnt    := 0;
            FRcvBuf[0] := #0;
            SetRcvSize(DefaultRcvSize);   // Reset rcv buffer to default size
            break;
        end;
        Move(FRcvBuf[I + 1], FRcvBuf^, FRcvCnt - I);
        FRcvCnt := FRcvCnt - I - 1;
        I       := 0;
    end;                                 // 24/09/2005 Optimize eol search
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TClientWSocket.SendReply;
begin
    PutDataInSendBuffer(ReplyHeader, ReplyHeaderLen);
    PutDataInSendBuffer(ReplyBody,   ReplyBodyLen);
    PutStringInSendBuffer(#13+#10);
    Send(nil, 0);
    FBusy := FALSE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

end.
