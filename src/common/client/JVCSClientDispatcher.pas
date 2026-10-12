(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSClientDispatcher.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
ToDo
- remove define MULTITHREADSUPPORT if there are no problems
-----------------------------------------------------------------------------

Unit history:

2003/12/22  USchuster - new unit
2003/12/27  USchuster - added new function to kill all unused clients
2003/12/31  USchuster - bugfix - new clients get now busy flag too
2004/01/09  USchuster - TJVCSAppSrvClient should now be threadsafe
2004/03/13  USchuster - bugfix - avoid destroying of clients in TJVCSClientDispatcher
                        which were created in other threads
2009/01/01  USchuster - changes for D2009

-----------------------------------------------------------------------------*)

unit JVCSClientDispatcher;

{$I jedi.inc}
{$I compopt.inc}

{$DEFINE MULTITHREADSUPPORT}

interface

uses
  Windows, Messages, SysUtils, Classes, ApsCli, RFormat
  {$IFDEF OVERBYTEV6_UP}
  , OverbyteIcsWSocket
  {$ELSE}
  , WSocket
  {$ENDIF OVERBYTEV6_UP}
  ;

type
  {$IFDEF MULTITHREADSUPPORT}
  TWSocketThread = class(TThread)
  private
    FWSocketAttached: Boolean;
    FWSocket: TWSocket;
    procedure AttachWSocket;
    procedure DetachWSocket;
  public
    constructor Create(ASuspended: Boolean);
    destructor Destroy; override;
    procedure Execute; override;

    property WSocket: TWSocket read FWSocket write FWSocket;
    property WSocketAttached: Boolean read FWSocketAttached;
  end;
  {$ENDIF MULTITHREADSUPPORT}  

  TJVCSAppSrvClient = class(TAppSrvClient)
  private
    FBusy: Boolean;
    {$IFDEF MULTITHREADSUPPORT}
    FThreadID: THandle;
    FInternalThread: TWSocketThread;
    {$ENDIF MULTITHREADSUPPORT}
  public
    constructor Create(AOwner: TComponent); override;
    {$IFDEF MULTITHREADSUPPORT}
    destructor Destroy; override;
    {$ENDIF MULTITHREADSUPPORT}
    property Busy: Boolean read FBusy write FBusy;
    {$IFDEF MULTITHREADSUPPORT}
    property ThreadID: THandle read FThreadID;
    {$ENDIF MULTITHREADSUPPORT}
  end;

  TJVCSClientDispatcher = class(TObject)
  private
    FClientList: TThreadList;
    FUnusedClientTimeOut: DWord;
  protected
    procedure KillAllClients;
    procedure KillOldClients(AList: TList);
  public
    constructor Create;
    destructor Destroy; override;

    function GetJVCSAppSrvClient: TJVCSAppSrvClient;
    procedure KillUnusedClients;

    property UnusedClientTimeOut: DWord read FUnusedClientTimeOut
      write FUnusedClientTimeOut;
  end;

implementation

{$IFDEF MULTITHREADSUPPORT}
constructor TWSocketThread.Create(ASuspended: Boolean);
begin
  inherited Create(ASuspended);

  FWSocketAttached := False;
  FWSocket := nil;
end;

destructor TWSocketThread.Destroy;
begin
  Terminate;
  PostThreadMessage(ThreadID, WM_QUIT, 0, 0);
  WaitForSingleObject(Handle, 10000);

  DetachWSocket;
  inherited Destroy;
end;

procedure TWSocketThread.AttachWSocket;
begin
  if (not FWSocketAttached) and Assigned(FWSocket) then
  begin
    FWSocket.ThreadAttach;
    FWSocketAttached := True;
  end;
end;

procedure TWSocketThread.DetachWSocket;
begin
  if FWSocketAttached and Assigned(FWSocket) then
  begin
    FWSocketAttached := False;
    FWSocket.ThreadDetach;
  end;
end;

procedure TWSocketThread.Execute;
begin
  while not Terminated do
  begin
    if Assigned(FWSocket) then
    begin
      AttachWSocket;
      Sleep(0);
      FWSocket.MessageLoop;
      Sleep(0);
      DetachWSocket;
    end
    else
      Sleep(10);
  end;
end;
{$ENDIF MULTITHREADSUPPORT}

constructor TJVCSAppSrvClient.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBusy := False;
  {$IFDEF MULTITHREADSUPPORT}
  FThreadID := GetCurrentThreadID;
  FWSocket.ThreadDetach;
  FWSocket.MultiThreaded := True;

  FInternalThread := TWSocketThread.Create(True);
  FInternalThread.WSocket := FWSocket;
  FInternalThread.Suspended := False;
  while not FInternalThread.WSocketAttached do
    Sleep(0);
  {$ENDIF MULTITHREADSUPPORT}
end;

{$IFDEF MULTITHREADSUPPORT}
destructor TJVCSAppSrvClient.Destroy;
begin
  FInternalThread.Free;
  inherited Destroy;
end;
{$ENDIF MULTITHREADSUPPORT}

type
  PDispatcherClientRec = ^TDispatcherClientRec;
  TDispatcherClientRec = record
    JVCSAppSrvClient: TJVCSAppSrvClient;
    LastAccess: TDateTime;
  end;

procedure TJVCSClientDispatcher.KillAllClients;
var
  I: Integer;
  LList: TList;
begin
  LList := FClientList.LockList;
  try
    if LList.Count > 0 then
    begin
      for I := 0 to Pred(LList.Count) do
      begin
        PDispatcherClientRec(LList[I])^.JVCSAppSrvClient.Free;
        Dispose(LList[I]);
      end;
      LList.Clear;
    end;
  finally
    FClientList.UnlockList;
  end;
end;

function TJVCSClientDispatcher.GetJVCSAppSrvClient: TJVCSAppSrvClient;
var
  I: Integer;
  LList: TList;
  PPtr: PDispatcherClientRec;
begin
  Result := nil;
  LList := FClientList.LockList;
  try
    if LList.Count > 0 then
      for I := 0 to Pred(LList.Count) do
        with PDispatcherClientRec(LList[I])^ do
          {$IFDEF MULTITHREADSUPPORT}
          if (not JVCSAppSrvClient.Busy) and (JVCSAppSrvClient.ThreadID = GetCurrentThreadID) then
          {$ELSE}
          if not JVCSAppSrvClient.Busy then
          {$ENDIF MULTITHREADSUPPORT}
          begin
            JVCSAppSrvClient.Busy := True;
            Result := JVCSAppSrvClient;
            LastAccess := Now;
            Break;
          end;
    if not Assigned(Result) then
    begin
      Result := TJVCSAppSrvClient.Create(nil);
      Result.Busy := True;
      New(PPtr);
      PPtr^.JVCSAppSrvClient := Result;
      PPtr^.LastAccess := Now;
      LList.Add(PPtr);
    end;
    KillOldClients(LList);
  finally
    FClientList.UnLockList;
  end;
end;

procedure TJVCSClientDispatcher.KillOldClients(AList: TList);
var
  I: Integer;
  MinTimeStamp: TDateTime;
  dtUnusedClientTimeOut: TDateTime;
begin
  if Assigned(AList) and (AList.Count > 0) then
  begin
    dtUnusedClientTimeOut := FUnusedClientTimeOut;
    dtUnusedClientTimeOut := dtUnusedClientTimeOut / 86400000;
    MinTimeStamp := Now - dtUnusedClientTimeOut;
    for I := Pred(AList.Count) downto 0 do
      with PDispatcherClientRec(AList[I])^ do
        if (not JVCSAppSrvClient.Busy) and
          {$IFDEF MULTITHREADSUPPORT}
          (JVCSAppSrvClient.ThreadID = GetCurrentThreadID) and
          {$ENDIF MULTITHREADSUPPORT}
          (LastAccess < MinTimeStamp) then
        begin
          JVCSAppSrvClient.Free;
          Dispose(AList[I]);
          AList.Delete(I);
        end;
  end;
end;

constructor TJVCSClientDispatcher.Create;
begin
  inherited Create;

  FClientList := TThreadList.Create;
  FUnusedClientTimeOut := 60 * 60 * 1000; // 1 hour
end;

destructor TJVCSClientDispatcher.Destroy;
begin
  KillAllClients;
  FClientList.Free;
  inherited Destroy;
end;

procedure TJVCSClientDispatcher.KillUnusedClients;
var
  I: Integer;
  LList: TList;
begin
  LList := FClientList.LockList;
  try
    for I := Pred(LList.Count) downto 0 do
      with PDispatcherClientRec(LList[I])^ do
        if not JVCSAppSrvClient.Busy then
        begin
{
//USc 13.03.2004 it is not possible to destroy the AppSrvClients which were created
// in other threads because they contain a window and it is not possible to destroy
// a window which was created in other thread (see remark WinAPI DestroyWindow)
// destroying these windows will cause strange errors -> these wrongly destroyed windows
// still receive messages but message handling is broken and thatswhy message handling
// for that windows will end up in Access Violations
}
          {$IFDEF MULTITHREADSUPPORT}
          if JVCSAppSrvClient.ThreadID = GetCurrentThreadID then
          begin
          {$ENDIF MULTITHREADSUPPORT}
            JVCSAppSrvClient.Free;
            Dispose(LList[I]);
            LList.Delete(I);
          {$IFDEF MULTITHREADSUPPORT}
          end
          else
            JVCSAppSrvClient.Close;
          {$ENDIF MULTITHREADSUPPORT}
        end;
  finally
    FClientList.UnlockList;
  end;
end;

end.
