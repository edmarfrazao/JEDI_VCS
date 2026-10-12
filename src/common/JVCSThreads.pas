(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSThreads.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
ToDo
- Exception event for TJVCSJobThread.Execute?
-----------------------------------------------------------------------------

Unit history:

2004/01/02  USchuster - new unit
2004/01/05  USchuster - small fixes
2004/01/11  USchuster - ready for production -> moved to ..\common\
2004/01/15  USchuster - tried to guess a D7 fix
2004/01/19  USchuster - added exception handling
2004/02/08  USchuster - made JCL exception handling possible
                      - reduced FEmptyQueueWaitTime
2004/04/23  USchuster - changes in TJVCSJobThread.Create/Destroy to avoid access
                        to member variables (mainly FJobQueue) before they are
                        created or after they are destroyed
                      - added message processing to TJVCSJobThread.Execute
                        (the GUI clients should not longer freeze on switching
                         the keyboard shema or double clicking a module with
                         "View module" as action [ShellExecute])
                        thanks to morgon mo for the pointing out the bug and providing
                        the fix
2004/07/14  USchuster - added WakeMainThread handler for D6/D7 (mantis #1964)
2004/11/29  CSchuette - added try, except, end to JVCSJobThread.Execute to hide
                        these strange exceptions in Delphi 7 DLL client (mantis #2023)
2005/01/04  USchuster - added critical section for TJVCSJobThread queue manipulation
2005/01/11  CSchuette - again #2023
2005/01/16  USchuster - D5 fix
^^^^^^^^^^^^^^^^^ 2.40 RC1(Client)&RC3(Server) was released ^^^^^^^^^^^^^^^^^^
2005/02/27  THuber    - use De/AllocateHWndEx from JvJVCLUtils (compiler warning)
2005/03/05  USchuster - added exception event TJVCSJobThread.OnJobException for external
                        handling of exceptions in TJVCSJobThread.DoRunJobs (mantis #2714)

-----------------------------------------------------------------------------*)

unit JVCSThreads;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, SysUtils, Classes, Contnrs {$IFNDEF NOFORMS}, Forms {$ENDIF}
  {$IFDEF JCL_DEBUG_DATA}, JclDebug {$ENDIF};

type
  TJVCSThreadJob = class;

  TJVCSThreadJobProc = procedure(AThreadJob: TJVCSThreadJob) of object;
  TJVCSThreadSync = procedure(Method: TThreadMethod) of object;
  TJVCSThreadException = procedure(Sender: TObject; E: Exception; var AHandled: Boolean) of object;

  TJVCSThreadJob = class(TObject)
  private
    FAborted: Boolean;
    FParameter: Pointer;
    FProc: TJVCSThreadJobProc;
    FRunning: Boolean;
    FSync: TJVCSThreadSync;
  public
    constructor Create;

    procedure Abort;
    procedure Run;

    property Aborted: Boolean read FAborted;
    property Parameter: Pointer read FParameter write FParameter;
    property Proc: TJVCSThreadJobProc read FProc write FProc;
    property Running: Boolean read FRunning;
    property Sync: TJVCSThreadSync read FSync write FSync;
  end;

  {$IFDEF JCL_DEBUG_DATA}
  TJVCSJobThread = class(TJclDebugThread)
  {$ELSE}
  TJVCSJobThread = class(TThread)
  {$ENDIF JCL_DEBUG_DATA}
  private
    FEmptyQueueWaitTime: Integer;
    FException: Exception;
    FExceptionAddr: Pointer;
    FJobQueue: TObjectList;
    FRunningJob: TJVCSThreadJob;
    FChangeLock: TRTLCriticalSection;
    FOnJobException: TJVCSThreadException;
    {$IFNDEF JCL_DEBUG_DATA}
    procedure DefaultExceptionHandler;
    procedure DoHandleExecuteException;
    procedure DoHandleJobException;
    {$ENDIF ~JCL_DEBUG_DATA}
    procedure DoRunJobs;
    function GetQueuedJobCount: Integer;
    procedure JobSynchronize(Method: TThreadMethod);
  protected
    procedure Execute; override;
  public
    constructor Create(ASuspended: Boolean; const AThreadName: string = '');
    destructor Destroy; override;

    procedure AddJob(AProc: TJVCSThreadJobProc; AParameter: Pointer);
    procedure DisqueueAllJobs;
    procedure DisqueueAllJobsAndWait;
    procedure DisqueueAndAbortAllJobsAndWait;
    function IsQueueEmpty: Boolean;

    property QueuedJobCount: Integer read GetQueuedJobCount;
    property OnJobException: TJVCSThreadException read FOnJobException write FOnJobException;
  end;

procedure InitWakeMainThreadHandler;
procedure DeInitWakeMainThreadHandler;

implementation

uses
    Messages
  , JvJVCLUtils
  ;
const
  JVCS_HWND_NAME = 'JVCS_HWND';

{$IFDEF DELPHI6_UP}
const
  WM_WAKEUP = WM_USER + 100; 

type
  TWakeMainThreadHandler = class(TObject)
  private
    FHandle: HWND;
    FOldWakeMainThread: TNotifyEvent;
    procedure DoWakeMainThread(Sender: TObject);  
    procedure WndProc(var MsgRec: TMessage);
  public
    constructor Create;
    destructor Destroy; override;
  end;

constructor TWakeMainThreadHandler.Create;
begin
  inherited Create;
  FHandle := JvJVCLUtils .AllocateHWndEx(WndProc, JVCS_HWND_NAME);
  FOldWakeMainThread := WakeMainThread;
  WakeMainThread := DoWakeMainThread;
end;

destructor TWakeMainThreadHandler.Destroy;
begin
  WakeMainThread := FOldWakeMainThread;
  JvJVCLUtils .DeallocateHWndEx(FHandle);
  inherited Destroy;
end;

procedure TWakeMainThreadHandler.DoWakeMainThread(Sender: TObject);
begin
  PostMessage(FHandle, WM_WAKEUP, 0, 0);
  if Assigned(FOldWakeMainThread) then
    FOldWakeMainThread(Sender);
end;

procedure TWakeMainThreadHandler.WndProc(var MsgRec: TMessage);
begin
  with MsgRec do 
  begin
    if Msg = WM_WAKEUP then 
      CheckSynchronize
    else
      Result := DefWindowProc(FHandle, Msg, wParam, lParam);
  end;
end;

var
  WakeMainThreadHandler: TWakeMainThreadHandler = nil;
{$ENDIF DELPHI6_UP}

procedure InitWakeMainThreadHandler;
begin
  {$IFDEF DELPHI6_UP}
  if (not Assigned(WakeMainThreadHandler)) and (GetCurrentThreadID = MainThreadID) then
    WakeMainThreadHandler := TWakeMainThreadHandler.Create;
  {$ENDIF DELPHI6_UP}
end;

procedure DeInitWakeMainThreadHandler;
begin
  {$IFDEF DELPHI6_UP}
  FreeAndNil(WakeMainThreadHandler);
  {$ENDIF DELPHI6_UP}
end;

constructor TJVCSThreadJob.Create;
begin
  inherited Create;
  FAborted := False;
  FProc := nil;
  FParameter := nil;
  FRunning := False;
  FSync := nil;
end;

procedure TJVCSThreadJob.Abort;
begin
  FAborted := True;
end;

procedure TJVCSThreadJob.Run;
begin
  if Assigned(FProc) and (not FRunning) then
  begin
    FRunning := True;
    try
      FAborted := False;
      FProc(Self);
    finally
      FRunning := False;
    end;
  end;
end;

constructor TJVCSJobThread.Create(ASuspended: Boolean; const AThreadName: string = '');
begin
  FEmptyQueueWaitTime := 5;
  FException := nil;
  FExceptionAddr := nil;
//USc 23.04.2004 FJobQueue must be created before inherited Create to avoid AV in
// IsQueueEmpty because FJobQueue is not yet created
  FJobQueue := TObjectList.Create;
  FJobQueue.OwnsObjects := False;
  FRunningJob := nil;
  FOnJobException := nil;
  InitializeCriticalSection(FChangeLock);
  inherited Create(ASuspended {$IFDEF JCL_DEBUG_DATA}, AThreadName {$ENDIF});
end;

destructor TJVCSJobThread.Destroy;
begin
  DisqueueAndAbortAllJobsAndWait;
  inherited Destroy;
  FJobQueue.Free;
  DeleteCriticalSection(FChangeLock);
end;

procedure TJVCSJobThread.AddJob(AProc: TJVCSThreadJobProc; AParameter: Pointer);
var
  NewJob: TJVCSThreadJob;
begin
  NewJob := TJVCSThreadJob.Create;
  NewJob.Proc := AProc;
  NewJob.Parameter := AParameter;
{//USc 15.01.2004 doesn't work with D7 - according to the compiler error message
 // "This form of method call only allowed for class methods" Synchronize could
 // be a class method in D7
  NewJob.Sync := Synchronize;
}
  NewJob.Sync := JobSynchronize;
  EnterCriticalSection(FChangeLock);
  try
    FJobQueue.Add(NewJob);
  finally
    LeaveCriticalSection(FChangeLock);
  end;
end;

procedure TJVCSJobThread.DisqueueAllJobs;
var
  I: Integer;
begin
  EnterCriticalSection(FChangeLock);
  try
    for I := 0 to Pred(FJobQueue.Count) do
      FJobQueue[I].Free;
    FJobQueue.Clear;
  finally
    LeaveCriticalSection(FChangeLock);
  end;
end;

procedure TJVCSJobThread.DisqueueAllJobsAndWait;
begin
  DisqueueAllJobs;
  while not IsQueueEmpty do
    Sleep(FEmptyQueueWaitTime);
end;

procedure TJVCSJobThread.DisqueueAndAbortAllJobsAndWait;
begin
  if Assigned(FRunningJob) then
    FRunningJob.Abort;
  DisqueueAllJobsAndWait;
end;

{$IFNDEF JCL_DEBUG_DATA}
procedure TJVCSJobThread.DefaultExceptionHandler;
begin
  if Assigned(FException) and (not (FException is EAbort)) then
  begin
    {$IFDEF NOFORMS}
    SysUtils.ShowException(FException, FExceptionAddr);
    {$ELSE}
    if Assigned(Application.OnException) then
      Application.OnException(Self, FException)
    else
      Application.ShowException(FException);
    {$ENDIF NOFORMS}
  end;
end;

procedure TJVCSJobThread.DoHandleExecuteException;
begin
  if FException is Exception then
    Exception(FException).Message := Exception(FException).Message + #13 + '(in thread excution)';
  DefaultExceptionHandler;
end;

procedure TJVCSJobThread.DoHandleJobException;
begin
  if FException is Exception then
    Exception(FException).Message := Exception(FException).Message + #13 + '(in thread job)';
  DefaultExceptionHandler;
end;
{$ENDIF ~JCL_DEBUG_DATA}

procedure TJVCSJobThread.DoRunJobs;
var
  HandledException: Boolean;
begin
  while (not Terminated) and (not IsQueueEmpty) do
  begin
    FRunningJob := nil;
    try
      EnterCriticalSection(FChangeLock);
      try
        if not IsQueueEmpty then
        begin
          FRunningJob := TJVCSThreadJob(FJobQueue[0]);
          FJobQueue.Delete(0);
        end;
      finally
        LeaveCriticalSection(FChangeLock);
      end;
      if Assigned(FRunningJob) then
      begin
        try
          FRunningJob.Run;
        except
          on E: Exception do
          begin
            HandledException := False;
            if Assigned(FOnJobException) then
              FOnJobException(Self, E, HandledException);
            if not HandledException then
            begin
              {$IFDEF JCL_DEBUG_DATA}
              HandleException;
              {$ELSE}
              FException := E;
              FExceptionAddr := ExceptAddr;
              Synchronize(DoHandleJobException);
              {$ENDIF JCL_DEBUG_DATA}
            end;
          end;
        end;
      end;
    finally
      FreeAndNil(FRunningJob);
    end;
  end;
end;

procedure TJVCSJobThread.Execute;
var
  Msg: TMsg;
begin
  try
    while not Terminated do
    begin
      if not IsQueueEmpty then
        DoRunJobs
      else
      begin

// USc 23.04.2004 it seams to be necessary to process messages in a thread if you
// create windows in a thread and their parent isn't HWND_MESSAGE
// (MidWare creates internal messaging windows and HWND_MESSAGE is only available in
// Windows 2000/XP)

// CSchuette, #2023, 11.01.2005: Take a look in Win32 SDK help file, topic "PeekMessage".
// Here it is only neccessary to handle messages which are sent to Midware. Midware's
// messaging windows are created without a parent handle, so PeekMessage will receive
// it's messages when the 2nd parameter is HWnd(-1). Also Midware messages are WM_USER-
// messages, so the message id range can also be passed to PeekMessage.

        while PeekMessage(Msg, HWND(-1), WM_USER ,WM_USER+31, PM_REMOVE) do
        begin
          TranslateMessage(Msg);
          DispatchMessage(Msg);
        end;
        Sleep(FEmptyQueueWaitTime);

// End of changes made for mantis #2023.

      end;
    end;
  except
    {$IFDEF JCL_DEBUG_DATA}
    HandleException;
    {$ELSE}
    on E: Exception do
    begin
      FException := E;
      FExceptionAddr := ExceptAddr;
      Synchronize(DoHandleExecuteException);
    end;
    {$ENDIF JCL_DEBUG_DATA}
  end;
end;

function TJVCSJobThread.GetQueuedJobCount: Integer;
begin
  Result := FJobQueue.Count;
end;

function TJVCSJobThread.IsQueueEmpty: Boolean;
begin
  Result := FJobQueue.Count = 0;
end;

procedure TJVCSJobThread.JobSynchronize(Method: TThreadMethod);
begin
  Synchronize(Method);
end;

initialization

finalization
  DeInitWakeMainThreadHandler;

end.