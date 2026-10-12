// ..................................................................
//
//                          mdMailSlot
//
//            Copyright © 1997-99 by Martin Djernæs
//
// ..................................................................
// $Id: mdMailSlot.pas 1.17 1999-04-21 22:19:56+02 md Exp md $
// ..................................................................
// Initial Date : 2th April 1997
// Version 1.0  : 3th April 1997
// 8th April 1997 :
// + SendBufToMailSlot added
// 13th April 1997 :
// + WaitThread added for signaling that a message is arrived
// - TmdAutoMailSlot (substituted by TmdMailSlot)
//   ...not installed by default, but just remove the (**) arund
//      the Class in the Register procedure in the buttom of the
//      unit
//   ...The class still exists, but with a new source.
// 17th April 1997 :
// + TmdCustomWinPopup class added
//   ...with a easy message event and a send function
// + TmdWinPopup class added
// Version 1.1 : 17th April 1997
// 19th Maj 1997
// + Sleep in MailSlotWaitThread (Thanks to Matt Behrens)
// Version 1.2 : 10th Juli 1997
// 28th July 1997
// % The paramerters in TwpMessage got new names - there were a naming
//   conflict (Thanks to Channing Corn for reminding me)
// Version 1.3 : 28th Juli 1997
// 23th September 1997
// - Two wait threads is one to many !
// 24th October 1997
// + Added success return value in SendBufToMailSlot (Alexander Orlov)
// + Added safe load of value at startup (AO + MD)
// Version 1.4 : 24th October 1997
// + TmdCustomSecureMail + TmdSecureMail added (prevent duplicates
//   and guarantee is integrity with a CRC16
// + SendSecureMail function added
// Version 1.5 : 15th November 1997
// % Changed the MOD 10000 to $10000, which gives 4 digits in hex!
// 3th January 1998
// - Set of FActive removed in SetActive. (David Novak)
// 3th January 1998
// % Changed the format of a secure mail to UNIQUE,CRC,DATA and
//   only the UNIQUE and CRC data is stored in last message.
// + Added ramdom to the GetTickCount in SendSecureMail(Buf)
//   else to mails (which are alike) send within 1 ms would
//   be counted as equal (Idea from Alexander Orlov - AO).
// + SetSlot and SetServer is now made incase sensitive
//   since mailslot names not is case sensiteive.
// + A SendToWinpopup is added, and the send function in
//   the TmdCustomWinpoup now uses that one.
// Version 1.6 : 3th February 1998
// 12th March 1998
// + Added FreeOnTerminate = True for
//   the TmdMailSlotWaitThread (Thanks to Marian Maier)
// + TmdCustomWinPopup now have implementet an "ignore dublicatet
//   messages" (should this be offered via a property ?)
//   So now no messages is received double.
//   (Thanks to David Adam Mathew for asking about the problem
//   so I startet thinking about it)
// Version 1.7 : 10th April 1998
// 21th April 1998
// + Added use of the local variable in
//   TmdCustomWinPopup.DoMessageAvail (Thanks to Alek Shamrai)
// Version 1.8 : 21th April 1998
// 24th April 1998
// % Added typecast to send secure mail (prefix got 8 bytes long
//   when the random value became $80000000 or bigger)
//   (Thanks to Raoul De Kezel for informing me about the problem)
// Version 1.9 : 24th April 1998
// 3th May 1998
// % Typecast in SendBufSecure is now correct (do nover use two
//   functions for the same work) - Thanks to Don Hass ;-)
// 7th May 1998
// % The wait thread do not poll on incomming messages any longer,
//   but uses the fact that ReadFile do only return after "timeout"
//   milliseconds. With "timeout" set to MAILSLOT_WAIT_FOREVER the
//   read function (dummy) do not return before there is data to
//   read.
// % Wait thread got priority lowest (one more than before), since
//   it now do not poll at incomming data anymore.
// Version 1.10 (1.a) : 9th May 1998
// 24th Juni 1998
// % Do not start the Wait Thread before all values which the thread
//   need is set in the Constructor.
// + Sleep is readded in the Wait Thread, since Windows 95 do not
//   handle a read with the length of zerro as a request of only
//   returning when the "file" is changed
// 18th August 1998
// % Changed values conflicting with the new D4 DWord type.
// Version 1.11 (1.b) : 18th August 1998
// 24th August 1998
// % Corrections in SendSecureBuf (and spelling) which Richard Kable
//   have informed me about.
// 13th december 1998
// - Removed outcommented prototypes and code (if you would like an
//   old version, then send me a mail - I have a copy of all prior
//   versions)
// % Changed the internal data handling, for bether handling of
//   binary data. The structures is totally compatible so far...
// + Added events for binary reception of data
// + Two new components are added. "NoErrMail" and "SafeMail".
//   NoErrMail is a base class for SafeMail, and is not exported
//   as a component. "SafeMail" do excactly the same as SecureMail,
//   but the header values is send as binary data instead of
//   hex-strings. I have keept SecureMail as is was for compatibility
//   reason.
// + Added another component! TmdLongMail.
//   LongMail offers the ability to send messages over the network,
//   with a maximum size of 65532 bytes.
// Version 1.12 (1.c) : 13th December 1998
// 2nd January 1999
// % Corrected an usage of StrCopy! (CopyMemory should be used)
//   Thanks to Rafe Aldridge for pointing me to the problem.
// Version 1.13 (1.d) : 2nd January 1999
// January 31st, 1999
// % TmdCustomWinPopup is now based on the OnBinMessageAvail event,
//   since the WinPopup message "format" contains #0 chars =>
//   binary data.
// Version 1.14 (1.e) : 2nd February 1999
// April 21st, 1999
// + Now memory in SendBufNoErr and SendBufSafe is also released!
//   (Thanks Don!)
// Version 1.15 (1.f) : 21st April 1999
// ..................................................................
{
NOTES:
------------------------------------------------------------------------------
Revised:  2006/01/22 BY: THu (JEDI-VCS) Reason: removed compiler warnings/hints
Revised:  0000/00/00 BY: ******* Reason: ******
------------------------------------------------------------------------------
}

unit mdMailSlot;

{$ifdef FPC}
  {$MODE DELPHI}
{$endif}

interface

uses
  Windows, SysUtils, Classes;

Const
// Missing constant!
{$IFDEF VER90}
  MAILSLOT_WAIT_FOREVER = -1; // exist as -1 in Delphi 3.0
{$ENDIF}

  // Error strings
  sCantOpen             = 'Cannot open mailslot';
  sNotActive            = 'Not active';
  sGetMailSlotInfoError = 'Error in GetMailSlotInfo';
  sNoMessages           = 'No messages waiting';
  sReadError            = 'Error reading message';
  sExists               = 'Mailslot already exists'; // ver 1.12 - Richard Kable
  sBadName              = 'Bad mailslot name';

  // Default values
  msDefActive = False;
  msDefServer  = '.';
  msDefSlot = 'mdMailSlot1';
  msDefMaxSize = 0;

  wpSlot = 'messngr';

type
// .........................................................
//              Forward declerations
// .........................................................
  TmdCustomMailSlot = Class;

// .........................................................
//               Wait for MessageAvail thread
// .........................................................
  TmdMailSlotWaitThread = class(TThread)
  private
    FMailSlot : TmdCustomMailSlot;
    FHandle : THandle;           // ver 1.10
  protected
    procedure Execute; override;
    Procedure SignalMsgReady;
    Procedure SignalError;
  Public
    Constructor Create(MailSlot : TmdCustomMailSlot);
  end;

// .........................................................
//                Component types
// .........................................................

  TmsMessageAvail = Procedure (Sender : TObject; Msg : String) of Object;
  TmsBinMessageAvail = Procedure (Sender : TObject; Data : PChar; Len : Integer) of Object;
  TwpMessage = Procedure (Sender : TObject; AReciever, ASender, AMsg : String) Of Object;

// .........................................................
//       EXCEPTION :     EmdMailSlot
// .........................................................

  EmdMailSlot = Class(Exception);

// .........................................................
//                       TmdCustomMailSlot
// .........................................................

  // This structure contans a pointer and a length of the
  // the alocated data area.
  TMsgInfo = Record
    Len : Longword;
    Data : Pointer;
  end;

  // This structure is used to pass data up and down through
  // the objects.
  // When Org.Len is 0 a new memory area can be allocated!
  TMsgPtr = Record
    Org : TMsgInfo;
    Cur : TMsgInfo;
  end;

  TmdCustomMailSlot = class(TComponent)
  private          { Private declarations }
    // Property storage variables
    FLoadedActiveValue : Boolean; // Ver 1.4
    FActive : Boolean;
    FHandle : THandle;
    FMaxSize : DWord;
    FServer : String;

    FWaiting : DWord;
    FNextSize : DWord;

    // Event storage variables
    FOpen : TNotifyEvent;
    FClose : TNotifyEvent;
    FMessageAvail : TmsMessageAvail;
    FBinMessageAvail : TmsBinMessageAvail;

    // Misc values
    FSlotChanged : Boolean;
    FWaitThread : TmdMailSlotWaitThread;

    // Property modification functions
    Procedure SetActive(Value : Boolean);
    Procedure SetSlot(Const Value : String);
    Procedure SetServer(Const Value : String);
    Procedure SetMaxSize(Value : DWord);

    Function GetWaiting : DWord;
    Function GetNextSize : DWord;
  protected        { Protected declarations }
    FSlot : String;

    // Event process functions
    Procedure DoOpen; Virtual;
    Procedure DoClose; Virtual;
    Procedure DoMessageAvail(Const Msg : String); Virtual;
    Procedure DoBinMessageAvail(Data : PChar; Len : Integer); Virtual;

    // Special functions
    Procedure PerformError(Const Err : String); Virtual;
    Procedure UpdateSlotInfo;

    // Read functions
    Function ReadNext(Var Msg : TMsgPtr) : Boolean; Virtual;        // ver 1.12
    Function AllocNext(Var Msg : TMsgPtr; Len : Integer) : Boolean; // Ver 1.12
    Procedure FreeNext(Msg : TMsgPtr); Virtual;                     // Ver 1.12
  public  { Public declarations }
    // Default functions
    Constructor Create(AOwner : TComponent); Override;
    Procedure SetName(const NewName: TComponentName); Override;
    Procedure Loaded; Override; // Ver 1.4

    // Special functions
    Procedure Open; Virtual;
    Procedure Close; Virtual;
    Procedure ReadMessage;

    // properties - Read Only
    Property Handle : THandle Read FHandle;
    Property Waiting : DWord Read GetWaiting;
    Property NextSize : DWord Read GetNextSize;
    // properties - Read/Write
    Property Active : Boolean Read FActive Write SetActive Default msDefActive;
    Property Server : String Read FServer Write SetServer;
    Property Slot : String Read FSlot Write SetSlot Stored FSlotChanged;
    Property MaxSize : DWord Read FMaxSize Write SetMaxSize Default msDefMaxSize;

    // Events
    Property OnOpen : TNotifyEvent Read FOpen Write FOpen;
    Property OnClose : TNotifyEvent Read FClose Write FClose;
    Property OnMessageAvail : TmsMessageAvail Read FMessageAvail Write FMessageAvail;
    Property OnBinMessageAvail : TmsBinMessageAvail Read FBinMessageAvail Write FBinMessageAvail;
  published        { Published declarations }
  end;

// .........................................................
//                       TmdMailSlot
// .........................................................

  TmdMailSlot = class(TmdCustomMailSlot)
  Published
    // Properties
    Property Active;              // TmdCustomMailSlot
    Property Server;              // TmdCustomMailSlot
    Property Slot;                // TmdCustomMailSlot
    Property MaxSize;             // TmdCustomMailSlot
    // Events
    Property OnOpen;              // TmdCustomMailSlot
    Property OnClose;             // TmdCustomMailSlot
    Property OnMessageAvail;      // TmdCustomMailSlot
    Property OnBinMessageAvail;   // TmdCustomMailSlot
  end;

// .........................................................
//                       TmdAutoMailSlot
// .........................................................

  TmdAutoMailSlot = Class(TmdMailSlot);  // For backward compatibility

// .........................................................
//                       TmdCustomWinPopup
// .........................................................
  TmdCustomWinPopup = Class(TmdCustomMailSlot)
  Private
    FMessage : TwpMessage;
    FMessageCRC : String[4];
    FMessageTicks : Integer;
  Protected
    Procedure DoBinMessageAvail(Data : PChar; Len : Integer); Override;
  Public
    Constructor Create(AOwner : TComponent); Override;
    Function Send(AServer, ASender, AReciever, AMsg : String) : Boolean;
    Property Slot : String Read FSlot; // Should be read only...
    Property OnMessage : TwpMessage Read FMessage Write FMessage;
  end;

// .........................................................
//                       TmdWinPopup
// .........................................................
  TmdWinPopup = Class(TmdCustomWinPopup)
  Published
    // Properties
    Property Active;     // TmdCustomMailSlot
    Property MaxSize;    // TmdCustomMailSlot
    // Events
    Property OnOpen;     // TmdCustomMailSlot
    Property OnClose;    // TmdCustomMailSlot
    Property OnMessage;  // TmdCustomWinPopup
  end;

// .........................................................
//                     TmdCustomSecureMail
// .........................................................
  TmdCustomSecureMail = Class(TmdCustomMailSlot)
  Private
    FError : TmsMessageAvail;
    FBinError : TmsBinMessageAvail; // ver 1.12
    FDuplicated : TNotifyEvent;
    FLastMessage : PChar;
  Protected
    Function ReadNext(Var Msg : TMsgPtr) : Boolean; Override; // ver 1.12
    Procedure DoError(Const Msg : String); Virtual;
    Procedure DoBinError(Data : PChar; Len : Integer); Virtual;
    Procedure DoDuplicated; Virtual;
  Public
    Destructor Destroy;  Override;   // New in version 1.6

    Property OnError : TmsMessageAvail Read FError Write FError;
    Property OnBinError : TmsBinMessageAvail Read FBinError Write FBinError; // ver 1.12
    Property OnDuplicated : TNotifyEvent Read FDuplicated Write FDuplicated;
  end;

// .........................................................
//                     TmdSecureMail
// .........................................................
  TmdSecureMail = Class(TmdCustomSecureMail)
  Published
    // Properties
    Property Active;            // TmdCustomMailSlot
    Property Server;            // TmdCustomMailSlot
    Property Slot;              // TmdCustomMailSlot
    Property MaxSize;           // TmdCustomMailSlot
    // Events
    Property OnOpen;            // TmdCustomMailSlot
    Property OnClose;           // TmdCustomMailSlot
    Property OnMessageAvail;    // TmdCustomMailSlot
    Property OnBinMessageAvail; // TmdCustomMailSlot
    Property OnError;           // TmdCustomSecureMail
    Property OnDuplicated;      // TmdCustomSecureMail
  end;

// .........................................................
//                     TmdCustomNoErrMail
// .........................................................
  TmdCustomNoErrMail = Class(TmdCustomMailSlot)
  Private
    FError : TmsMessageAvail;
    FBinError : TmsBinMessageAvail;
  Protected
    Procedure DoError(Const Msg : String); Virtual;
    Procedure DoBinError(Data : PChar; Len : Integer); Virtual;
    Function ReadNext(Var Msg : TMsgPtr) : Boolean; Override;
  Public
    Property OnError : TmsMessageAvail Read FError Write FError;
    Property OnBinError : TmsBinMessageAvail Read FBinError Write FBinError;
  end;

// .........................................................
//                     TmdNoErrMail
// .........................................................
  TmdNoErrMail = Class(TmdCustomNoErrMail)
  Published
    // Properties
    Property Active;            // TmdCustomMailSlot
    Property Server;            // TmdCustomMailSlot
    Property Slot;              // TmdCustomMailSlot
    Property MaxSize;           // TmdCustomMailSlot
    // Events
    Property OnOpen;            // TmdCustomMailSlot
    Property OnClose;           // TmdCustomMailSlot
    Property OnMessageAvail;    // TmdCustomMailSlot
    Property OnBinMessageAvail; // TmdCustomMailSlot
    Property OnError;           // TmdCustomSecureMail
  end;

// .........................................................
//                     TmdCustomSafeMail
// .........................................................
  TmdCustomSafeMail = Class(TmdCustomNoErrMail)
  Private
    FLastId : Word;
    FDuplicated : TNotifyEvent;
  Protected
    Function ReadNext(Var Msg : TMsgPtr) : Boolean; Override;
    Procedure DoDuplicated; Virtual;
  Public
    Property OnDuplicated : TNotifyEvent Read FDuplicated Write FDuplicated;
  end;

// .........................................................
//                     TmdSafeMail
// .........................................................
  TmdSafeMail = Class(TmdCustomSafeMail)
  Published
    // Properties
    Property Active;            // TmdCustomMailSlot
    Property Server;            // TmdCustomMailSlot
    Property Slot;              // TmdCustomMailSlot
    Property MaxSize;           // TmdCustomMailSlot
    // Events
    Property OnOpen;            // TmdCustomMailSlot
    Property OnClose;           // TmdCustomMailSlot
    Property OnMessageAvail;    // TmdCustomMailSlot
    Property OnBinMessageAvail; // TmdCustomMailSlot
    Property OnError;           // TmdCustomNoErrMail
    Property OnDuplicated;      // TmdCustomSafeMail
  end;

// .........................................................
//                     TmdCustomLongMail
// .........................................................

  // Informatiom about a long message beeing received...
  PmdLongMailInfo = ^TmdLongMailInfo;
  TmdLongMailInfo = Record
    Msg      : PChar;
    Len      : Integer;
    Expected : Integer;
    Id       : Integer;
    Tick     : Longword;
  end;

  // Class manageing the information about all the messages
  // currently being received.
  TmdLongMailInfoList = Class
  Private
    FList : TList;
  Protected
    Function IndexOf(Id : Integer) : Integer;

    Function GetMsg(Index : Integer) : PChar;
    Procedure SetExpected(Index : Integer; Value : Integer);
    Function GetExpected(Index : Integer) : Integer;
    Procedure SetLen(Index : Integer; Value : Integer);
    Function GetLen(Index : Integer) : Integer;
  Public
    Constructor Create; Virtual;
    Destructor Destroy; Override;

    Procedure NewMsg(Id : Integer; Msg : PChar; MsgLen, TotalLen : Integer);
    Procedure AppendMsg(Id : Integer; Msg : PChar; MsgLen : Integer);
    Procedure DeleteMsg(Index : Integer);
    Procedure FreeMsg(Id : Integer);
    Property Msg[Index : Integer] : PChar Read GetMsg;
    Property Expected[Index : Integer] : Integer Read GetExpected Write SetExpected;
    Property Len[Index : Integer] : Integer Read GetLen Write Setlen;
  end;

  TmdCustomLongMail = Class(TmdCustomNoErrMail)
  Private
    FInfoList : TmdLongMailInfoList;
  Protected
    Function ReadNext(Var Msg : TMsgPtr) : Boolean; Override;
  Public
    Constructor Create(AOwner : TComponent); Override;
    Destructor Destroy;  Override;
  end;

// .........................................................
//                     TmdLongMail
// .........................................................
  TmdLongMail = Class(TmdCustomLongMail)
  Published
    // Properties
    Property Active;            // TmdCustomMailSlot
    Property Server;            // TmdCustomMailSlot
    Property Slot;              // TmdCustomMailSlot
    Property MaxSize;           // TmdCustomMailSlot
    // Events
    Property OnOpen;            // TmdCustomMailSlot
    Property OnClose;           // TmdCustomMailSlot
    Property OnMessageAvail;    // TmdCustomMailSlot
    Property OnBinMessageAvail; // TmdCustomMailSlot
    Property OnError;           // TmdCustomNoErrMail
  end;


// .........................................................
//                       Functions
// .........................................................

// Send a single message to a mailslot
// If Server is "." then the current machine are used
// If Server is "*" then the current domain are used
Function SendToMailSlot(Const Server, Slot, Mail : String) : Boolean;
Function SendBufToMailSlot(Const Server, Slot : String; Data : PChar; Length : Longword) : Boolean;

// Sends a message to the messgr mailslot (winpopup)
// Hier must a sender and reciever name be given...
Function SendToWinpopup(Server, Reciever, Sender, Msg : String) : Boolean;

// Send with preample for preventing duplicate messages, and
// a CRC16 for preventing errors in the data.
Function SendSecureMail(Const Server, Slot : String; Mail : String) : Boolean;
Function SendBufSecure(Const Server, Slot : String; Data : PChar; Length : Integer) : Boolean;

// Functions to send a message with a CRC attached
Function SendBufNoErr(Const Server, Slot : String; Data : PChar; Length : Integer) : Boolean;
Function SendNoErrMail(Const Server, Slot : String; Mail : String) : Boolean;

// Functions to send "safe messages".
// Safe messages is the same as secure messages, but the header format
// is binary and not str-encoded hex values
Function SendBufSafe(Const Server, Slot : String; Data : PChar; Length : Integer) : Boolean;
Function SendSafeMail(Const Server, Slot : String; Mail : String) : Boolean;

// Functions to send long messages... max 30000 bytes
// Is based on NoErrMail, so errors is handles on segment level, and
// duplicated segments is not added (using an 16 bit ID)
Function SendBufLong(Const Server, Slot : String; Data : PChar; Length : Integer) : Boolean;
Function SendLongMail(Const Server, Slot : String; Mail : String) : Boolean;

procedure Register;

implementation

// .........................................................
// Constant used for sending and receivng long messages
// .........................................................
Const
  MaxSegment = 394; // We use 6 bytes for header information.

// .........................................................
//                        CRC16
// Actually this is a unit by me, but for only having to
// have one file I copied it in here.
// .........................................................

Const
  IntegerCRCTable     : Array[0..255] of Word =
    ($0000, $C0C1, $C181, $0140, $C301, $03C0, $0280, $C241,
     $C601, $06C0, $0780, $C741, $0500, $C5C1, $C481, $0440,
     $CC01, $0CC0, $0080, $CD41, $0F00, $CFC1, $CE81, $0E40,
     $0A00, $CAC1, $C881, $0B40, $C901, $09C0, $0880, $C841,
     $D801, $18C0, $1980, $D941, $1B00, $DBC1, $DA81, $1A40,
     $1E00, $DEC1, $DF81, $1F40, $DD01, $1DC0, $1C80, $DC41,
     $1400, $D4C1, $D581, $1540, $D701, $17C0, $1680, $0641,
     $D201, $12C0, $1380, $D341, $1100, $D1C1, $D081, $1040,
     $F001, $30C0, $3180, $F141, $3300, $F3C1, $F281, $3240,
     $3600, $F6C1, $F781, $3740, $F501, $35C0, $3480, $F441,
     $3C00, $FCC1, $FD81, $3D40, $FF01, $3FC0, $3E80, $FE41,
     $FA01, $3AC0, $3B80, $FB41, $3900, $F9C1, $F881, $3840,
     $2800, $E8C1, $E981, $2940, $EB01, $2BC0, $2A80, $EA41,
     $EE01, $2EC0, $2F80, $EF41, $2D00, $EDC1, $EC81, $2C40,
     $E401, $24C0, $2580, $E541, $2700, $E7C1, $E681, $2640,
     $2200, $E2C1, $E381, $2340, $E101, $21C0, $2080, $E041,
     $A001, $60C0, $6180, $A141, $6300, $A3C1, $A281, $6240,
     $6600, $A6C1, $A781, $6740, $A501, $65C0, $6480, $A441,
     $6C00, $ACC1, $AD81, $6D40, $AF01, $6FC0, $6E80, $AE41,
     $AA01, $6AC0, $6B80, $AB41, $6900, $A9C1, $A881, $6840,
     $7800, $B8C1, $B981, $7940, $BB01, $7BC0, $7A80, $BA41,
     $BE01, $7EC0, $7F80, $BF41, $7D00, $BDC1, $BC81, $7C40,
     $B401, $74C0, $7580, $B541, $7700, $B7C1, $B681, $7640,
     $7200, $B2C1, $B381, $7340, $B101, $71C0, $7080, $B041,
     $5000, $90C1, $9181, $5140, $9301, $53C0, $5280, $9241,
     $9601, $56C0, $5780, $9741, $5500, $95C1, $9481, $5440,
     $9C01, $5CC0, $5D80, $9041, $5F00, $9FC1, $9E81, $5E40,
     $5A00, $9AC1, $9B81, $5B40, $9901, $59C0, $5880, $9841,
     $8801, $48C0, $4980, $8941, $4B00, $8BC1, $8A81, $4A40,
     $4E00, $8EC1, $8F81, $4F40, $8D01, $4DC0, $4C80, $8C41,
     $4400, $84C1, $8581, $4540, $8701, $47C0, $4680, $8641,
     $8201, $42C0, $4380, $8341, $4100, $81C1, $8081, $4040);

     SECURITY_DESCRIPTOR_REVISION = 1; // 1.7
Type
  CRCRecord = Record
    Low         : Byte;
    High        : Byte;
  end;

Var
  CRCTable : Array[0..255] of CRCRecord absolute IntegerCRCTable;

Function CalcCRC16(Const S;Const L : Integer) : Word;
Var
  i, j  : Integer;
  CRC   : CRCRecord;
Begin
  Try
    CRC.High := 0;
    CRC.Low := 0;
    For i := 0 to L-1 do
    Begin
      j := Ord(PChar(S)[i]) XOR CRC.Low;
      CRC.Low := CRCTable[j].Low XOR CRC.High;
      CRC.High := CRCTable[j].High;
    end;
    CalcCRC16 := (CRC.High SHL 8) or CRC.Low;
  Except
    On Exception do   // This is added because use of
      CalcCRC16 := 0; // this function can easy result
  end;                // in a exception :-(
end;

// .........................................................
// Support functions
// .........................................................
Function Min(I1, I2 : Integer) : Integer;
Begin
  If I1 > I2 Then
    Result := I2
  else
    Result := I1;
end;

// .........................................................
//                      SendToMailSlot
// .........................................................

Function OpenMailSlot(Const Server, Slot : String): THandle;
Var
  FullSlot : String;
Begin
  FullSlot := '\\'+Server+'\mailslot\'+Slot;  // MailSlot string
  Result := CreateFile(
    PChar(FullSlot),
    GENERIC_WRITE,
    FILE_SHARE_READ,
    NIL,
    OPEN_EXISTING,
    FILE_ATTRIBUTE_NORMAL,
    0                    );  // Changed from -1 to 0 ver 1.11
                             // I cannot remember why it were -1
                             // in the first place, but Win32 SDK
                             // says NULL (in C), and that is normally
                             // the same as zero = 0
end;

Function SendBufToMailSlot(Const Server, Slot : String; Data : PChar; Length : Longword) : Boolean;
Var
  hToSlot : THandle;
  BytesWritten : Longword; // D4 Compatible - ver 1.11
Begin
  Result := False;
  hToSlot := OpenMailSlot(Server,Slot);
  If hToSlot = INVALID_HANDLE_VALUE Then
    Exit; // Error
  Try
    BytesWritten := 0;
    If (NOT WriteFile(hToSlot,
                      Pointer(Data)^,
                      Length,
                      BytesWritten,
                      NIL))         OR
        (BytesWritten <> Length) Then
      Exit; // Error
    Result := True; // Alexander Orlov - ver 1.4
  Finally
    CloseHandle(hToSlot);
  end;
end;

// Changed in ver 1.12
Function SendToMailSlot(Const Server, Slot, Mail : String) : Boolean;
Begin
  Result := SendBufToMailSlot(Server, Slot, PChar(Mail), Length(Mail));
end;


Function SendToWinpopup(Server, Reciever, Sender, Msg : String) : Boolean;
Begin
  {$IFDEF VER200}
  {$Message Warn 'Fix me'}
  {$ELSE}
  CharToOEM(PChar(Server),  PChar(Server));
  CharToOEM(PChar(Sender),  PChar(Sender));
  CharToOEM(PChar(Reciever),PChar(Reciever));
  CharToOEM(PChar(Msg),     PChar(Msg));
  {$ENDIF}
  Result := SendToMailSlot(Server, wpSlot, Sender+#0+Reciever+#0+Msg);
end;

// Format in version 1.5 :
// 4 byte TickCount as HEX
// Data
// 4 byte CRC16

// Format in version 1.6 :
// 4 byte TickCount as HEX   -| <- Now I only need to store and
// 4 byte CRC16              -|    compare these 8 bytes
// Data

Function SendBufSecure(Const Server, Slot : String; Data : PChar; Length : Integer) : Boolean;
Var
  TempData : PChar;
Begin
  TempData := StrAlloc(Length+9);
  Try
    // 1.10 Thanks Don Hass
    StrCopy(TempData,PChar(IntToHex(Cardinal(Random(GetTickCount)) MOD $10000,4)));
    // Format changed in version 1.6
    StrCat(TempData,PChar(IntToHex(CalcCRC16(Data,Length),4))); // Sascha Buchner
    CopyMemory(@TempData[8],Data,Length); // ver 1.13 - Richard Kable
    Result := SendBufToMailSlot(Server, Slot, TempData, Length+8);
  Finally
    StrDispose(TempData);
  end;
end;

// Changed in ver 1.12
Function SendSecureMail(Const Server, Slot : String; Mail : String) : Boolean;
Begin
  Result := SendBufSecure(Server, Slot, PChar(Mail), Length(Mail));
end;

Function SendBufNoErr(Const Server, Slot : String; Data : PChar; Length : Integer) : Boolean;
Var
  TempData : PChar;
  Crc : Word;
Begin
  Result := False;
  TempData := StrAlloc(Length+SizeOf(Word));
  If TempData <> NIL Then
  Begin
    Try
      Crc := CalcCRC16(Data,Length);;
      CopyMemory(TempData, @Crc, SizeOf(Word));
      CopyMemory(@TempData[2], Data, Length);
      Result := SendBufToMailSlot(Server, Slot, TempData, Length+2);
    Finally
      StrDispose(TempData);
    end;
  end;
end;

Function SendNoErrMail(Const Server, Slot : String; Mail : String) : Boolean;
Begin
  Result := SendBufNoErr(Server, Slot, PChar(Mail), Length(Mail));
end;


Function SendBufSafe(Const Server, Slot : String; Data : PChar; Length : Integer) : Boolean;
Var
  Id : Word;
  TempData : PChar;
Begin
  Result := False;
  TempData := StrAlloc(Length+SizeOf(Word));
  If TempData <> NIL Then
  Begin
    Try
      Id := Cardinal(Random(GetTickCount)) MOD $10000;
      CopyMemory(TempData, @Id, SizeOf(Word));
      CopyMemory(@TempData[2], Data, Length);
      Result := SendBufNoErr(Server, Slot, TempData, Length+2);
    Finally
      StrDispose(TempData);
    end;
  end;
end;

Function SendSafeMail(Const Server, Slot : String; Mail : String) : Boolean;
Begin
  Result := SendBufSafe(Server, Slot, PChar(Mail), Length(Mail));
end;

Function SendBufLong(Const Server, Slot : String; Data : PChar; Length : Integer) : Boolean;
Var
  SegmentCount : Integer;
  SegmentLength : Integer;
  Cnt : Integer;
  FirstId, Id : Word;
  P,
  TempData : PChar;
Begin
  Result := False;
  If Length > 65532 Then // Delphi need 2 bytes of manegsment, and I one
    Exit;                

  // Get a message ID
  Id := (Cardinal(Random(GetTickCount)) MOD $10000) AND $7FFF;
  FirstId := $8000 OR Id;

  // Calculate how many segments we have to send
  SegmentLength := MaxSegment;
  SegmentCount := Length DIV SegmentLength;
  If (Length MOD SegmentLength) > 0 Then
    Inc(SegmentCount);

  // Get mem for a segments
  GetMem(TempData, SegmentLength+2*SizeOf(Word));
  Try
    For Cnt := 0 to SegmentCount-1  do
    Begin
      // This is because i have noticed that sending a very long message
      // (more than 23 segments) we loose data. I have not found any
      // reason for this (max size of an incomming mailslot?), but
      // by releasing a bit of time once in a while when sending
      // we get rid of the problem!
      If ((Cnt+1) MOD 20) = 0 Then
        Sleep(20);
      If Cnt = 0 Then
        CopyMemory(@TempData[0], @FirstId, SizeOf(Word))
      else
        CopyMemory(@TempData[0], @Id, SizeOf(Word));

      CopyMemory(@TempData[2], @Length, SizeOf(Word));
      P := @Data[Cnt*SegmentLength];
      CopyMemory(@TempData[4], P, Min(SegmentLength,Length));

      If NOT SendBufNoErr(Server, Slot, TempData, Min(SegmentLength,Length)+2*SizeOf(Word)) Then
        Exit;
      Dec(Length,SegmentLength);
    end;
    Result := True;
  Finally
    FreeMem(TempData, SegmentLength+2*SizeOf(Word));
  end;
end;

Function SendLongMail(Const Server, Slot : String; Mail : String) : Boolean;
Begin
  Result := SendBufLong(Server, Slot, PChar(Mail), Length(Mail));
end;
// .........................................................
//               Wait for MessageAvail thread
// .........................................................

Constructor TmdMailSlotWaitThread.Create(MailSlot : TmdCustomMailSlot);
Begin
  Inherited Create(True);   // ver 1.11
  FreeOnTerminate := True;  // Marian Maier 1.7

  Priority := tpLowest;

  // I have tried Higher prio but somehow it does not work
  // the first GetMailSlotInfo returns invalid data
//  Priority := tpHigher;

  FMailSlot := MailSlot;
  FHandle := MailSlot.Handle;

  Resume; // ver 1.11 - We need the info from above!
end;

Procedure TmdMailSlotWaitThread.Execute;
Var
  Waiting,
  Size : DWord;
  DummyBuffer : Char;
Begin
  While Not Terminated do
  Begin
    // Check if there is messages in the mailslot
    GetMailSlotInfo(FHandle,NIL, Size, @Waiting, NIL);
    If Waiting > 0 Then
      Synchronize(SignalMsgReady) // signal to vcl if there is
    else
    Begin
      // Sleep reinserted so we continue to release resources under
      // Windows 95, since ReadFile for 0 bytes do return straight away
      // with true under Windows 95, but under Windows NT the function
      // blocks until the "file" is changed.
      // - Sleep(1) suggested by Matt Behrens. (5th Dec 1997 inc to 10)
      Sleep(10);  // ver 1.11

      // Wait in blocking mode... Dummy Read ...
      // ... do not read anything, but uses the fact that
      // ReadFile returns when it have got data...
      // (ups Windows 95 do not like this - at least not WinTop)
      // Problem is pointed out by Alek Shamrai.
      // Look up ver 1.11 "corrects" this
      ReadFile(FHandle, DummyBuffer, 0, Size, NIL); // ver 1.10
    end;
  end;
end;

Procedure TmdMailSlotWaitThread.SignalMsgReady;
Begin
  FMailSlot.ReadMessage;
end;

Procedure TmdMailSlotWaitThread.SignalError;
Begin
end;


// .........................................................
//                    TmdCustomMailSlot
// .........................................................

// Default functions

Constructor TmdCustomMailSlot.Create(AOwner : TComponent);
Begin
  Inherited Create(AOwner);
  FWaitThread := NIL;
  FSlotChanged := False;
  FHandle := INVALID_HANDLE_VALUE;
  FSlot := msDefSlot;
  FServer := msDefServer;
  FMaxSize := msDefMaxSize;

  If msDefActive Then
    Open
  else
    Close;
end;

Procedure TmdCustomMailSlot.SetName(const NewName: TComponentName);
Begin
  Inherited SetName(NewName);
  If NOT FSlotChanged Then
    FSlot := NewName;
end;

Procedure TmdCustomMailSlot.Loaded; // Ver 1.4
Begin
  Inherited Loaded;
  SetActive(FLoadedActiveValue);
end;

// Special functions

Procedure TmdCustomMailSlot.PerformError(Const Err : String);
Begin
  Raise EmdMailSlot.Create(Err);
end;

Procedure TmdCustomMailSlot.Open;
Var
  MailSlotName : String;
Begin
  If Active Then
    Close;
  MailSlotName := '\\'+FServer+'\mailslot\'+FSlot;
  If NOT (csDesigning IN ComponentState) Then
  Begin
    FHandle := CreateMailSlot(PChar(MailSlotName),
                            MaxSize,
                            MAILSLOT_WAIT_FOREVER,
                            NIL);
    FActive := Handle <> INVALID_HANDLE_VALUE;
    If NOT Active Then
    Begin
      Case GetLastError of
        ERROR_ALREADY_EXISTS : PerformError(sExists);
        ERROR_BAD_PATHNAME   : PerformError(sBadName);
      else
        PerformError(sCantOpen);
      end;
    end
    else
    Begin
      DoOpen;
      If FWaitThread = NIL Then
        FWaitThread := TmdMailSlotWaitThread.Create(Self);
    end;
  end
  else
    FActive := True;
end;

Procedure TmdCustomMailSlot.Close;
Begin
  If Active Then
  Begin
    If FWaitThread <> NIL Then
    Begin
      FWaitThread.Terminate;
      FWaitThread := NIL;
    end;

    CloseHandle(FHandle);
    FHandle := INVALID_HANDLE_VALUE;
    FActive := False;
    DoClose;
  end;
end;

Procedure TmdCustomMailSlot.UpdateSlotInfo;
Begin
  If NOT Active Then
    PerformError(sNotActive);

  If NOT GetMailSlotInfo(Handle,NIL, FNextSize, @FWaiting, NIL) Then
    PerformError(sGetMailSlotInfoError);
end;

// Changed in ver 1.12
Function TmdCustomMailSlot.ReadNext(Var Msg : TMsgPtr) : Boolean;
Var
  ReadSize : DWord;
Begin
  UpdateSlotInfo;
  If FWaiting = 0 Then
    PerformError(sNoMessages);
  FreeNext(Msg);
  AllocNext(Msg, FNextSize);
  ReadFile(Handle,Msg.Org.Data^,Msg.Org.Len,ReadSize,NIL);
  Result := Msg.Org.Len = ReadSize;
  If NOT Result Then
    PerformError(sReadError);
end;

// Added in ver 1.12
Function TmdCustomMailSlot.AllocNext(Var Msg : TMsgPtr; Len : Integer) : Boolean;
Begin
  Result := False;
  If Len > (65535 -3) Then
  Begin
    Msg.Org.Len := 0;
    Exit;
  end;
  Msg.Org.Len := Len;
  GetMem(Msg.Org.Data, Len+1); // Make sure that we _always_ have a NULL termination
  Result := Msg.Org.Data <> NIL;
  If Result Then
  Begin
    FillChar(Msg.Org.Data^,Len+1, #0);
    Msg.Cur := Msg.Org;
  end
  else
    Msg.Org.Len := 0;
end;

// Added in ver 1.12
Procedure TmdCustomMailSlot.FreeNext(Msg : TMsgPtr);
Begin
  Try
    If Msg.Org.Len > 0 Then
    Begin
      FreeMem(Msg.Org.Data, Msg.Org.Len+1);
      Msg.Org.Len := 0;
    end;
  Except
    On Exception do
      Raise;
  end;
end;

// Changed in ver 1.12
Procedure TmdCustomMailSlot.ReadMessage;
Var
  Msg : TMsgPtr;
Begin
  Try
    Try
      Msg.Org.Len := 0;
      If ReadNext(Msg) Then
      Begin
        DoMessageAvail(String(PChar(Msg.Cur.Data)));
        DoBinMessageAvail(Msg.Cur.Data, Msg.Cur.Len);
      end;
    Finally
      FreeNext(Msg);
    end;
  Except
    On Exception do
      ; // Ignore
  end;
end;

// Property modification functions

Procedure TmdCustomMailSlot.SetActive(Value : Boolean);
Begin
  If csReading IN ComponentState Then // Ver 1.4
  Begin
    FLoadedActiveValue := Value;
    Exit;
  end;

//  Not needed since open and close set FActive [DGN]
//  FActive := Value;	  // Ver 1.6
  If Value Then
    Open
  else
    Close;
end;

Procedure TmdCustomMailSlot.SetServer(Const Value : String);
Begin
  If StrIComp(PChar(Value), PChar(FServer)) = 0 Then // Ver 1.6
    Exit;
  FServer := Value;
  If Active Then
    Open;
end;

Procedure TmdCustomMailSlot.SetSlot(Const Value : String);
Begin
  If StrIComp(PChar(Value), PChar(FSlot)) = 0 Then // Ver 1.6
    Exit;
  FSlotChanged := True;
  FSlot := Value;
  If Active Then
    Open;
end;

Procedure TmdCustomMailSlot.SetMaxSize(Value : DWord);
Begin
  If Value = FMaxSize Then
    Exit;
  FMaxSize := Value;
  If Active  Then
    Open;
end;

Function TmdCustomMailSlot.GetWaiting : DWord;
Begin
  Result := 0;
  // I want that it is possible to check on
  // waiting without testing Active first
  If NOT Active Then
    Exit;
  UpdateSlotInfo;
  Result := FWaiting;
end;

Function TmdCustomMailSlot.GetNextSize : DWord;
Begin
  UpdateSlotInfo;
  Result := FNextSize;
end;

// Event process functions

Procedure TmdCustomMailSlot.DoOpen;
Begin
  If Assigned(FOpen) Then
    FOpen(Self);
end;

Procedure TmdCustomMailSlot.DoClose;
Begin
  If Assigned(FClose) Then
    FClose(Self);
end;

Procedure TmdCustomMailSlot.DoMessageAvail(Const Msg : String);
Begin
  If Assigned(FMessageAvail) Then
    FMessageAvail(Self, Msg);
end;

Procedure TmdCustomMailSlot.DoBinMessageAvail(Data : PChar; Len : Integer);
Begin
  If Assigned(FBinMessageAvail) Then
    FBinMessageAvail(Self, Data, Len);
end;

// .........................................................
//                        TmdCustomWinPopup
// .........................................................

// Overriden functions

Constructor TmdCustomWinPopup.Create(AOwner : TComponent);
Begin
  Inherited Create(AOwner);
  Inherited Slot := wpSlot;
end;

// 1.13 - mdCutsomWinPopup is now based on BinMessages (since it contains
// NULL chars).
Procedure TmdCustomWinPopup.DoBinMessageAvail(Data : PChar; Len : Integer);
var
  P : PChar;
  ASender, AReciever, AMessage : String;
  CRC : String[4];
  Ticks, Elapse : Integer;
  NewMsg : Boolean;
Begin
  If Assigned(FMessage) Then
  Begin
    // Check if any message a dublicate of the last message
    // - Happens when more than one protocal is avalible for
    //   the transport.
    // 1.7 - MD
    CRC := IntToHex(CalcCRC16(Data, Len),4);
    Ticks := GetTickCount;
    Elapse := ((Ticks - FMessageTicks) DIV 1000);

    // The message is more than 2 sec old or it is a new message
    NewMsg := ((Elapse >= 2) OR
              ((Elapse < 2) AND (CRC <> FMessageCRC)));
    // Store this before the event is called
    FMessageTicks := Ticks;
    FMessageCRC := CRC;


    // 1.13 - We do not need to find the strings if we ignore the msg.
    If NewMsg Then  // Ver 1.8 - Thanks to Alek Shamrai
    Begin
      P := PChar(Data);
      {$IFDEF VER200}
      {$Message Warn 'Fix me'}
      {$ELSE}
      OemToChar(P,P);
      {$ENDIF}
      ASender := StrPas(P);
      While NOT (P[0] = #0) do
        Inc(P);
      Inc(P);
      {$IFDEF VER200}
      {$Message Warn 'Fix me'}
      {$ELSE}
      OemToChar(P,P);
      {$ENDIF}
      AReciever := StrPas(P);
      While NOT (P[0] = #0) do
        Inc(P);
      Inc(P);
      {$IFDEF VER200}
      {$Message Warn 'Fix me'}
      {$ELSE}
      OemToChar(P,P);
      {$ENDIF}
      AMessage := StrPas(P);

      FMessage(Self, AReciever, ASender, AMessage);
    end;
  end;
end;

// New functions

Function TmdCustomWinPopup.Send(AServer, ASender, AReciever, AMsg : String):Boolean;
Begin
// Ver 1.6
// Functionallity moved to extern function
  Result := SendToWinpopup(AServer, AReciever, ASender, AMsg);
end;

// .........................................................
//                       TmdCustomSecureMail
// .........................................................

// New in version 1.6
Destructor TmdCustomSecureMail.Destroy;
Begin
  If FLastMessage <> NIL Then
    StrDispose(FLastMessage); // Make sure that we free our buffer
  Inherited Destroy;
end;

// For version 1.6...secure mail format
// The functionallity from DoMessageAvail is now inserted
// here - ver 1.12
Function TmdCustomSecureMail.ReadNext(Var Msg : TMsgPtr) : Boolean;
Var
  P : PChar;
Begin
  Result := Inherited ReadNext(Msg);
  If Result Then
  Begin
    Result := False; // Default is an non OK message
    // P is used because the compiler not will accept
    // PChar(@Msg[9]) as typecast in the call to CalcCRC16 !!!
    P := @PChar(Msg.Cur.Data)[8];
    If Copy(String(Msg.Cur.Data),5,4) <>
       IntTohex(CalcCRC16(P,Msg.Cur.Len-8),4) Then
    Begin
      DoError(String(Msg.Cur.Data));
      DoBinError(Msg.Cur.Data, Msg.Cur.Len);
    end
    else  // OK !
    Begin
      If (FLastMessage <> NIL) AND
          // Only check the first 8 chars...
          // then the CRC and the TickCount is equal
         (StrLComp(FLastMessage,Msg.Cur.Data,8) = 0) Then
      Begin
        // Inform about this mail is ignores since it is a duplicate
        DoDuplicated;
      end
      else
      Begin
        If FLastMessage = NIL Then
        Begin
          // Make sure that we have somewhere to store the data
          FLastMessage := StrAlloc(9);
          FLastMessage[8] := #0;
        end;
        // Remember the last message
        StrLCopy(FLastMessage,Msg.Cur.Data,8);
        // Remove the header from the "Current Message"
        Inc(PChar(Msg.Cur.Data),8);
        Dec(Msg.Cur.Len,8);
        // Signal OK message
        Result := True;
      end;
    end;
  end;
end;

Procedure TmdCustomSecureMail.DoError(Const Msg : String);
Begin
  If Assigned(FError) Then
    FError(Self,Msg);
end;

// new in ver 1.12
Procedure TmdCustomSecureMail.DoBinError(Data : PChar; Len : Integer);
Begin
  If Assigned(FBinError) Then
    FBinError(Self, Data, Len);
end;

Procedure TmdCustomSecureMail.DoDuplicated;
Begin
  If Assigned(FDuplicated) Then
    FDuplicated(Self);
end;

// .........................................................
//                        TmdCustomNoErrMail
// .........................................................

Function TmdCustomNoErrMail.ReadNext(Var Msg : TMsgPtr) : Boolean;
Var
  AttachedCrc : Word;
Begin
  Result := Inherited ReadNext(Msg);
  If Result Then
  Begin
    AttachedCrc := Word(Msg.Cur.Data^);
    Inc(PChar(Msg.Cur.Data),SizeOf(Word));
    Dec(Msg.Cur.Len,SizeOf(Word));
    Result := CalcCRC16(Msg.Cur.Data, Msg.Cur.Len) = AttachedCrc;
    If NOT Result Then
    Begin
      // We want to send the CRC value
      Dec(PChar(Msg.Cur.Data),SizeOf(Word));
      Inc(Msg.Cur.Len,SizeOf(Word));
      // Indicate an error
      DoError(String(Msg.Cur.Data));
      DoBinError(Msg.Cur.Data, Msg.Cur.Len);
    end;
  end;
end;

Procedure TmdCustomNoErrMail.DoError(Const Msg : String);
Begin
  If Assigned(FError) Then
    FError(Self,Msg);
end;

Procedure TmdCustomNoErrMail.DoBinError(Data : PChar; Len : Integer);
Begin
  If Assigned(FBinError) Then
    FBinError(Self, Data, Len);
end;

// .........................................................
//                     TmdCustomSafe
// .........................................................

Function TmdCustomSafeMail.ReadNext(Var Msg : TMsgPtr) : Boolean;
Begin
  Result := Inherited ReadNext(Msg);
  If Result Then
  Begin
    If FLastId <> Word(Msg.Cur.Data^) Then
    Begin
      FLastId := Word(Msg.Cur.Data^);
      Inc(PChar(Msg.Cur.Data),SizeOf(Word));
      Dec(Msg.Cur.Len,SizeOf(Word));
    end
    else
    Begin
      DoDuplicated;
      Result := False;
    end;
  end;
end;

Procedure TmdCustomSafeMail.DoDuplicated;
Begin
  If Assigned(FDuplicated) Then
    FDuplicated(Self);
end;


// .........................................................
//                       TmdLongMailInfoList
// .........................................................

Constructor TmdLongMailInfoList.Create;
Begin
  FList := TList.Create;
end;

Destructor TmdLongMailInfoList.Destroy;
Begin
  FList.Free;
end;

Procedure TmdLongMailInfoList.NewMsg(Id : Integer; Msg : PChar; MsgLen, TotalLen : Integer);
Var
  pMsg : PmdLongMailInfo;
Begin
  New(pMsg);
  If pMsg <> NIL Then
  Begin
    pMsg^.Id := Id;
    pMsg^.Tick := GetTickCount; // Milliseconds
    pMsg^.Len := TotalLen;
    GetMem(pMsg^.Msg, pMsg^.Len+1);
    pMsg^.Expected := TotalLen - MsgLen;
    If pMsg^.Msg = NIL Then
      Dispose(pMsg)
    else
    Begin
//      StrLCopy(pMsg^.Msg,Msg, MsgLen); - Err
      CopyMemory(pMsg^.Msg, Msg, MsgLen); // 1.13
      FList.Add(pMsg);
    end;
  end;
end;

Procedure TmdLongMailInfoList.AppendMsg(Id : Integer; Msg : PChar; MsgLen : Integer);
Var
  pMsg : PmdLongMailInfo;
  Index : Integer;
Begin
  Index := IndexOf(Id);
  If Index <> -1 Then
  Begin
    pMsg := PmdLongMailInfo(FList[Index]);
    If pMsg^.Msg <> NIL Then
    Begin
      CopyMemory(Pointer(@pMsg^.Msg[pMsg^.Len - pMsg^.Expected]), Msg, MsgLen);
      Dec(pMsg^.Expected, MsgLen);
      pMsg^.Msg[pMsg^.Len - pMsg^.Expected] := #0; // Terminate string..
    end;
  end;
end;

Procedure TmdLongMailInfoList.FreeMsg(Id : Integer);
Begin
  DeleteMsg(IndexOf(Id));
end;

Procedure TmdLongMailInfoList.DeleteMsg(Index : Integer);
Var
  pMsg : PmdLongMailInfo;
Begin
  If Index < 0 Then
    Exit;
  Try
    pMsg := PmdLongMailInfo(FList[Index]);
    If pMsg^.Msg <> NIL Then
      FreeMem(pMsg^.Msg, pMsg^.Len+1);
    Dispose(pMsg);
    FList[Index] := NIL;
    FList.Delete(Index);
  Except
    On Exception do
      ; // Ignore
  end;
end;

Function TmdLongMailInfoList.IndexOf(Id : Integer) : Integer;
Var
  IndexToDelete : Integer;
Begin
  IndexToDelete := -1; // None
  Try
    For Result := 0 To FList.Count - 1 do
    Begin
      If PmdLongMailInfo(FList[Result])^.Id = Id Then
      Begin
        PmdLongMailInfo(FList[Result])^.Tick := GetTickCount; // Update ticks
        Exit;
      end;
      If PmdLongMailInfo(FList[Result])^.Tick+2000 < GetTickCount Then
        IndexToDelete := Result;
    end;
    Result := -1;
  Finally
    If IndexToDelete <> -1 Then
    Begin
      DeleteMsg(IndexToDelete);
      Result := IndexOf(Id);
    end;
  end;
end;

Function TmdLongMailInfoList.GetMsg(Index : Integer) : PChar;
Begin
  Index := IndexOf(Index);
  If Index <> -1 Then
    Result := PmdLongMailInfo(FList[Index])^.Msg
  else
    Result := NIL;
end;

Procedure TmdLongMailInfoList.SetExpected(Index : Integer; Value : Integer);
Begin
  Index := IndexOf(Index);
  If Index <> -1 Then
    PmdLongMailInfo(FList[Index])^.Expected := Value;
end;

Function TmdLongMailInfoList.GetExpected(Index : Integer) : Integer;
Begin
  Index := IndexOf(Index);
  If Index <> -1 Then
    Result := PmdLongMailInfo(FList[Index])^.Expected
  else
    Result := 0;
end;

Procedure TmdLongMailInfoList.SetLen(Index : Integer; Value : Integer);
Begin
  Index := IndexOf(Index);
  If Index <> -1 Then
    PmdLongMailInfo(FList[Index])^.Len := Value;
end;

Function TmdLongMailInfoList.GetLen(Index : Integer) : Integer;
Begin
  Index := IndexOf(Index);
  If Index <> -1 Then
    Result := PmdLongMailInfo(FList[Index])^.Len
  else
    Result := 0;
end;

// .........................................................
//                    TmdCustomLongMail
// .........................................................

Constructor TmdCustomLongMail.Create(AOwner : TComponent);
Begin
  Inherited Create(AOwner);
  FInfoList := TmdLongMailInfoList.Create;
end;

Destructor TmdCustomLongMail.Destroy;
Begin
  FInfoList.Free;
  Inherited Destroy;
end;

Function TmdCustomLongMail.ReadNext(Var Msg : TMsgPtr) : Boolean;
Var
  FirstSeg : Boolean;
  MsgId    : Integer;
  MsgLenId : Integer;
Begin
  Result := Inherited ReadNext(Msg);
  If Result Then
  Try
    Result := False;
    If Msg.Cur.Len > 4 Then
    Begin
      MsgId := Word(Msg.Cur.Data^) AND $7FFF;  // Id
      FirstSeg := Word(Msg.Cur.Data^) > $7FFF;
      Inc(PChar(Msg.Cur.Data),SizeOf(Word));
      Dec(Msg.Cur.Len,SizeOf(Word));


      MsgLenId := Word(Msg.Cur.Data^);         // Len Id
      Inc(PChar(Msg.Cur.Data),SizeOf(Word));
      Dec(Msg.Cur.Len,SizeOf(Word));

      If (FirstSeg) AND (FInfoList.IndexOf(MsgId) = -1) Then      // New message
        FInfoList.NewMsg(MsgId, PChar(Msg.Cur.Data), Msg.Cur.Len, MsgLenId)
      else
      Begin
        // Appent to existing message
        If FInfoList.Expected[MsgId] = MsgLenId Then
          FInfoList.AppendMsg(MsgId, PChar(Msg.Cur.Data), Msg.Cur.Len)
        else
          Exit;
      end;

      // Whole message received ?
      If FInfoList.Expected[MsgId] = 0 Then
      Begin
        FreeNext(Msg);
        If AllocNext(Msg, FInfoList.Len[MsgId]) Then
        Begin
          Result := True;
          CopyMemory(Msg.Org.Data,FInfoList.Msg[MsgId],Msg.Org.Len);
        end;
        FInfoList.FreeMsg(MsgId);
      end;
    end;
  Except
    On Exception do
      ; // Ignore
  end;
end;

// .........................................................
//                        Register
// .........................................................

procedure Register;
begin
  RegisterComponents('mdVCL', [TmdMailSlot{,
                               TmdAutoMailSlot},
                               TmdWinPopup,
                               TmdSecureMail,
                               TmdSafeMail,  // Have the same functionallity as TmdSecureMail
                               TmdLongMail]);
end;

Initialization
  Randomize; // Ver 1.6
end.
