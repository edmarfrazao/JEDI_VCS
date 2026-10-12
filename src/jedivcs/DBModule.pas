(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: DBModule.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS: Thomas Huber (Thomas_D_Huber@t-online.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FreeVCS code to JEDI VCS
2003/02/09  WKlein    - Added support for Delphi 7
2003/02/16  USchuster - Bugfix: wasn't compilable without DEBUG
2003/11/30  USchuster - included new connection for ClientObjects which can be
                        executed with ClientObjectSendRequest
2003/12/27  USchuster - fixed minor problems with clientdispatcher
                      - added new debug stuff
2003/12/29  USchuster - changes because debug unit was renamed
2004/01/09  USchuster - Bugfix for negative "Transfer" value after reconnect
                      - minor style cleaning
2004/05/07  USchuster - added Sleep(0) to WaitForAppSrvClient
                        (MidWare demos and CBroker.pas use Sleep(0) while waiting for answer)
2004/10/31  USchuster - res strings and displayed strings changed to resourcestrings
2004/11/05  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
2005/01/21  USchuster - use MsgWaitForMultipleObjects to reduce the CPU load
                        while requests (mantis #2529)
2005/11/05  USchuster - implemented better timeout handling (mantis #3221)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC3 was released ^^^^^^^^^^^^^^^^^^^^^^^^^^^
2006/01/08  USchuster - added property FileFamilyList (for mantis #3423)
2006/01/18  USchuster - the timeout does now start after the data was sent (mantis #3453) 
2006/05/05  THuber    - removed z i pmaster from uses
2007/08/13  USchuster - Trace -> TraceMsg
2008/11/15  USchuster - set ServerVersion in TJVCSMigrationConnection.DoOnRequestStart (required for TJVCSConnection.SupportsFunction)
2009/01/01  USchuster - changes for D2009
2010/01/10  USchuster - added missing username to TJVCSMigrationConnection instance (for Mantis #5083)

-----------------------------------------------------------------------------*)

unit DBModule;

{$I jedi.inc}
{$I compopt.inc}

{$DEFINE LZH}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ApsCli, RFormat, JVCSConnect, JVCSClientObjBase, JVCSDataClasses,
  {$IFDEF DEBUG}
  JclDebug,
  {$ENDIF DEBUG}
  {$IFDEF LZH}
  CipherLz;
  {$ELSE}
  Cipher;
  {$ENDIF LZH}

type
  TDataModule1 = class(TDataModule)
    AppSrvClient1: TAppSrvClient;
    MWBuffer1: TMWBuffer;
    procedure AppSrvClient1RequestDone(Sender: TObject; Error: Integer);
    procedure AppSrvClient1BeforeSendRequest(Sender: TObject);
    procedure AppSrvClient1SessionConnected(Sender: TObject; Error: Word);
    procedure AppSrvClient1SessionClosed(Sender: TObject; Error: Word);
    procedure AppSrvClient1AfterSendRequest(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
    FEncryptFlag: Boolean;
    FLastReplyRXTimeStamp: TDateTime;
    FRestartTimeout: Boolean;
    FFileFamilyList: TFileFamilyList;
    procedure AppSrvClient1BeforeProcessReply(Sender: TObject;
      var CmdBuf: PAnsiChar; var CmdLen: Integer);
    procedure AppSrvClient1AfterProcessReply(Sender: TObject;
      var CmdBuf: PAnsiChar; var CmdLen: Integer);
    procedure AppSrvClient1BannerRcvd(Sender: TObject; CmdBuf: PAnsiChar;
      CmdLen: Integer; var BannerOk: Boolean);
  protected
    FClientObjectConnection: TJVCSConnection;
    procedure Loaded; override;
  public
    { Public declarations }
    procedure SetupTimeoutCounter;
    function WaitForAppSrvClient: Boolean;
    function DecodeBoolStr(const Value: string): Boolean;

    procedure ClientObjectSendRequest(AnInstance: TJVCSClientObject);
    property FileFamilyList: TFileFamilyList read FFileFamilyList;
  end;

  function GetJvcsConnection: TJVCSConnection;

var
  DataModule1: TDataModule1;

implementation

uses
  {$IFDEF DEBUG}
  JVCSDebug,
  {$ENDIF DEBUG}
  VCSBase, JVCSGUIClientResources;

{$R *.dfm}

function GetJvcsConnection: TJVCSConnection;
begin
  Result := DataModule1.FClientObjectConnection;
end;

type
  TJVCSMigrationConnection = class(TJVCSConnection)
  private
    FLastBytesReceived: Int64;
    FLastBytesSent: Int64;
  protected
    procedure ClearLoginInfo; override;
    procedure SetActive(Value: Boolean); override;
    procedure DoOnRequestEnd(Sender: TObject);
    procedure DoOnRequestStart(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  end;

procedure TJVCSMigrationConnection.ClearLoginInfo;
begin
  inherited ClearLoginInfo;
  FLastBytesReceived := 0;
  FLastBytesSent := 0;
end;

procedure TJVCSMigrationConnection.SetActive(Value: Boolean);
begin
  if Value <> GetActive then
    ClearLoginInfo;
end;

procedure TJVCSMigrationConnection.DoOnRequestEnd(Sender: TObject);
begin
  if Sender = Self then
  begin
    iServTraffic := iServTraffic + BytesSent - FLastBytesSent;
    iServTraffic := iServTraffic + BytesReceived - FLastBytesReceived;
    FLastBytesSent := BytesSent;
    FLastBytesReceived := BytesReceived;
    Inc(iServerReqCount);
  end;
end;

procedure TJVCSMigrationConnection.DoOnRequestStart(Sender: TObject);
begin
  if Sender = Self then
  begin
    FServerVersion := nServerVersion;
    SetTransactionID(TransactionNr);
    SetUserID(ServerUserID);
  end;
end;

constructor TJVCSMigrationConnection.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FLastBytesReceived := 0;
  FLastBytesSent := 0;
  OnRequestEnd := DoOnRequestEnd;
  OnRequestStart := DoOnRequestStart;
end;

//------------------------------------------------------------------------------

procedure TDataModule1.Loaded;
begin
  inherited;
  AppSrvClient1.OnBeforeProcessReply := AppSrvClient1BeforeProcessReply;
  AppSrvClient1.OnAfterProcessReply := AppSrvClient1AfterProcessReply;
  AppSrvClient1.OnBannerRcvd := AppSrvClient1BannerRcvd;
end;

//------------------------------------------------------------------------------

procedure TDataModule1.SetupTimeoutCounter;
begin
  AppSrvClientReady := False;
  AppSrvClientErr := 0;
  SrvTimeOut := GetTickCount;
  FLastReplyRXTimeStamp := AppSrvClient1.LastReplyRXTime;
  FRestartTimeout := True;
  {$IFDEF DEBUG}
  if ShowDebugMsg then
    JclDebug.TraceMsg(PChar(cPrgType + '(' + AppSrvClient1.FunctionCode +
      ') Server request start time: ' + IntToStr(SrvTimeOut) + #0));
  {$ENDIF DEBUG}
end;

//------------------------------------------------------------------------------

function TDataModule1.WaitForAppSrvClient: Boolean;
var
  DummyHandle: THandle;
begin
  Result := True;
  Screen.Cursor := cSrvWaitCursor;
  // Timeout?
  if FRestartTimeout or (FLastReplyRXTimeStamp <> AppSrvClient1.LastReplyRXTime) then
  begin
    FLastReplyRXTimeStamp := AppSrvClient1.LastReplyRXTime;
    FRestartTimeout := False;
    SrvTimeOut := GetTickCount;
    {$IFDEF DEBUG}
    if ShowDebugMsg then
      JclDebug.TraceMsg(PChar(cPrgType + '(' + AppSrvClient1.FunctionCode +
        ') Server request timeout "counter" restarted: ' + IntToStr(SrvTimeOut) + #0));
    {$ENDIF DEBUG}
  end
  else
  if (GetTickCount > (SrvTimeOut + SrvTimeOutVal)) then
  begin
    AppSrvClientReady := True;
    AppSrvClientErr := -99;
    {$IFDEF DEBUG}
    if ShowDebugMsg then
      JclDebug.TraceMsg(PChar(cPrgType + '(' + AppSrvClient1.FunctionCode +
        ') Server request timed out: ' + IntToStr(GetTickCount) + #0));
    {$ENDIF DEBUG}
  end;
  if AppSrvClientReady then
  begin
    Result := False;
    Screen.Cursor := crDefault;
    Application.ProcessMessages;
  end
  else
  begin
    DummyHandle := INVALID_HANDLE_VALUE;
    MsgWaitForMultipleObjects(0, DummyHandle, False, 10,
      QS_ALLINPUT + QS_ALLEVENTS + QS_KEY + QS_MOUSE);
  end;
  Sleep(0);
end;

//------------------------------------------------------------------------------

function TDataModule1.DecodeBoolStr(const Value: string): Boolean;
begin
  if (Value = '1') or (LowerCase(Value) = 'true') then
    Result := True
  else
    Result := False;
end;

//------------------------------------------------------------------------------

procedure TDataModule1.AppSrvClient1RequestDone(Sender: TObject;
  Error: Integer);
begin
  {$IFDEF DEBUG}
  FunctionDebugList.RemoveRunningFunction(AppSrvClient1.FunctionCode);
  {$ENDIF DEBUG}
  AppSrvClientReady := True;
  AppSrvClientErr := Error;
  iServTraffic := iServTraffic + AppSrvClient1.Answer.DataBufferCount;
  Inc(iServerReqCount);
end;

//------------------------------------------------------------------------------

{$IFDEF LZH}
procedure TDataModule1.AppSrvClient1BeforeSendRequest(Sender: TObject);
var
  Dst: PAnsiChar;
  DstLen: Longint;
begin
  if not EncryptServerData then
    Exit;
  Encrypt(AppSrvClient1.RequestHeader, AppSrvClient1.RequestHeaderLen,
    AppSrvClient1.RequestBody, AppSrvClient1.RequestBodyLen,
    Dst, DstLen, 1);
  Dst[0] := #$FF;
  AppSrvClient1.RequestHeader := Dst;
  AppSrvClient1.RequestHeaderLen := DstLen;
  AppSrvClient1.RequestBody := nil;
  AppSrvClient1.RequestBodyLen := 0;
  iServTraffic := iServTraffic + AppSrvClient1.Request.DataBufferCount;
end;
{$ELSE}
procedure TDataModule1.AppSrvClient1BeforeSendRequest(Sender: TObject);
var
  Dst: PAnsiChar;
  DstLen: Integer;
  Key: Integer;
begin
  if not EncryptServerData then
    Exit;
  Key := Ord('0');
  { Encrypt will allocate new memory for encrypted data which takes a
    little bit more space than original data.
    Memory will be freed in the OnAfterSendRequest event handler.     }
  Encrypt(AppSrvClient1.RequestHeader, AppSrvClient1.RequestHeaderLen,
    Dst, DstLen, Key, 2);
  AppSrvClient1.RequestHeader := Dst;
  AppSrvClient1.RequestHeaderLen := DstLen;
  Dst[0] := #3;     // This will let the server know we use encrypted data
  Dst[1] := Chr(Key);
  Encrypt(AppSrvClient1.RequestBody, AppSrvClient1.RequestBodyLen,
    Dst, DstLen, Key, 0);
  AppSrvClient1.RequestBody := Dst;
  AppSrvClient1.RequestBodyLen := DstLen;
  iServTraffic := iServTraffic + AppSrvClient1.Request.DataBufferCount;
end;
{$ENDIF LZH}

//------------------------------------------------------------------------------

procedure TDataModule1.AppSrvClient1SessionConnected(Sender: TObject;
  Error: Word);
begin
  AppSrvClientConnected := True;
end;

//------------------------------------------------------------------------------

procedure TDataModule1.AppSrvClient1SessionClosed(Sender: TObject;
  Error: Word);
begin
  AppSrvClientConnected := False;
  FClientObjectConnection.Active := False;
  FFileFamilyList.Clear;
end;

//------------------------------------------------------------------------------

procedure TDataModule1.AppSrvClient1BannerRcvd(Sender: TObject;
  CmdBuf: PAnsiChar; CmdLen: Integer; var BannerOk: Boolean);
begin
  if CmdLen < 10 then
    AppSrvBanner := JVCSRES_Server_banner58_45blank45
  else
    AppSrvBanner := Format(JVCSRES_Server_banner58_3937s39, [CmdBuf]);
end;

//------------------------------------------------------------------------------

{$IFDEF LZH}
procedure TDataModule1.AppSrvClient1BeforeProcessReply(Sender: TObject;
  var CmdBuf: PAnsiChar; var CmdLen: Integer);
var
  Dst: PAnsiChar;
  DstLen: Longint;
begin
  // Check if we have some encrypted data
  FEncryptFlag := not ((CmdLen < 3) or (CmdBuf[0] <> #$FF));
  if not FEncryptFlag then
    Exit;

  // We've got encrypted data. Decrypt. First byte is a flag, ignore.
  Decrypt(CmdBuf + 1, CmdLen - 1, Dst, DstLen);
  CmdBuf := Dst;
  CmdLen := DstLen;
end;
{$ELSE}
procedure TDataModule1.AppSrvClient1BeforeProcessReply(Sender: TObject;
  var CmdBuf: PAnsiChar; var CmdLen: Integer);
var
  Cnt: Integer;
begin
  // Check if we have some encrypted data
  if (CmdLen < 3) or (CmdBuf[0] <> #3) then
    Exit;

  // We've got encrypted data. Decrypt on same place.
  Decrypt(CmdBuf, CmdLen, CmdBuf, Cnt);

  CmdLen := Cnt;
end;
{$ENDIF LZH}

//------------------------------------------------------------------------------

{$IFDEF LZH}
procedure TDataModule1.AppSrvClient1AfterProcessReply(Sender: TObject;
  var CmdBuf: PAnsiChar; var CmdLen: Integer);
begin
  if FEncryptFlag then
    FreeMem(CmdBuf, CmdLen);
end;
{$ELSE}
procedure TDataModule1.AppSrvClient1AfterProcessReply(Sender: TObject;
  var CmdBuf: PAnsiChar; var CmdLen: Integer);
begin
  // Nothing to do
end;
{$ENDIF LZH}

//------------------------------------------------------------------------------

procedure TDataModule1.AppSrvClient1AfterSendRequest(Sender: TObject);
begin
  {$IFDEF DEBUG}
  FunctionDebugList.AddRunningFunction(AppSrvClient1.FunctionCode);
  {$ENDIF DEBUG}
  if not EncryptServerData then
    Exit;

  { Memory was allocated in the OnBeforeSendRequest event handler. We have
    to free it to avoid memory leaks.                                      }
  if AppSrvClient1.RequestHeaderLen > 0 then
    FreeMem(AppSrvClient1.RequestHeader, AppSrvClient1.RequestHeaderLen);
  if AppSrvClient1.RequestBodyLen > 0 then
    FreeMem(AppSrvClient1.RequestBody, AppSrvClient1.RequestBodyLen);
end;

procedure TDataModule1.DataModuleCreate(Sender: TObject);
begin
  FClientObjectConnection := TJVCSMigrationConnection.Create(Self);
  FFileFamilyList := TFileFamilyList.Create;
  FRestartTimeout := True;
end;

procedure TDataModule1.ClientObjectSendRequest(AnInstance: TJVCSClientObject);
begin
  {$IFDEF DEBUG}
  FunctionDebugList.AddRunningObject(AnInstance);
  try
  {$ENDIF DEBUG}
    FClientObjectConnection.Port:= AppSrvClient1.Port;
    FClientObjectConnection.Server:= AppSrvClient1.Server;
    FClientObjectConnection.UserName := sCurrentUser;
    FClientObjectConnection.SendRequest(AnInstance);
  {$IFDEF DEBUG}
  finally
    FunctionDebugList.RemoveRunningObject(AnInstance);
  end;
  {$ENDIF DEBUG}
end;

procedure TDataModule1.DataModuleDestroy(Sender: TObject);
begin
  FFileFamilyList.Free;
end;

end.
