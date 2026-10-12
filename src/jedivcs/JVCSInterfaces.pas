(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSInterfaces.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
Apr/04
-USc: move TRefreshDispatcher + instance to new unit (JVCSRefreshDispatcher.pas)
     to have only interfaces here ?
-----------------------------------------------------------------------------

Unit history:

2003/09/15  USchuster - new unit
2003/11/23  USchuster - changes for cleanup in BugWindow.pas and ModuleHistoryWindow.pas
2003/12/31  USchuster - new RefreshType rtProjectClosing
                      - made client handling in TRefreshDispatcher a bit safer
2004/04/10  USchuster - added RefreshDispatcher as TRefreshDispatcher instance
                        (removed from ProjAdmin.pas to have access from everywhere)
2005/04/10  CSchuette - changed .Free to FreeAndNil() in unit finalization
2005/12/11  USchuster - added IJVCSProjectManager.RefreshSingleModule (mantis #3349)
2008/03/15  USchuster - added IJVCSProjectManager.ShowLineHistory

-----------------------------------------------------------------------------*)

unit JVCSInterfaces;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Classes, Windows, SysUtils;

const
  IID_IJVCSRefresh: TGUID = '{06E01BC8-9022-482F-A466-323D606F7B61}';
  IID_IJVCSProjectManager: TGUID = '{745805C2-7138-40B5-9A60-644A2BA9F262}';

type
  TJVCSRefreshType = (rtConnected, rtDisconnected, rtRefresh,
    rtSelectedProjectChanged, rtSelectedModuleChanged, rtProjectClosing);

  IJVCSRefresh = interface
  ['{06E01BC8-9022-482F-A466-323D606F7B61}']
    procedure SimpleRefresh(ARefreshType: TJVCSRefreshType);
  end;

  TRefreshDispatcher = class(TObject)
  private
    FClientList: TThreadList;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddClient(AClient: TObject);
    procedure RemoveClient(AClient: TObject);

    procedure DispatchSimpleRefresh(ARefreshType: TJVCSRefreshType);
  end;

  IJVCSProjectManager = interface
  ['{745805C2-7138-40B5-9A60-644A2BA9F262}']
    procedure OpenProject(SelectedProjectID: Integer; SelectedProjectName: string);
    function GetSelectedModuleID: Integer;
    function GetSelectedModuleName: string;
    procedure ExecuteBugManager;
    procedure ExecuteProjectBugManager;
    procedure ExecuteModuleBugManager;
    procedure RefreshSingleModule(AModuleID: Integer);
    procedure ShowLineHistory(const AModuleName: string; const AModuleMember: string = '');
  end;

var
  RefreshDispatcher: TRefreshDispatcher;

implementation

constructor TRefreshDispatcher.Create;
begin
  inherited;
  FClientList := TThreadList.Create;
end;

destructor TRefreshDispatcher.Destroy;
begin
  FClientList.Free;
  inherited;
end;

procedure TRefreshDispatcher.AddClient(AClient: TObject);
var
  Unknown: IUnknown;
  LList: TList;
begin
  if AClient.GetInterface(IID_IJVCSRefresh, Unknown) then
  begin
    LList := FClientList.LockList;
    try
      if LList.IndexOf(AClient) = -1 then
        LList.Add(AClient);
    finally
      FClientList.UnlockList;
    end;
  end;
end;

procedure TRefreshDispatcher.RemoveClient(AClient: TObject);
var
  Index: Integer;
  LList: TList;
begin
  LList := FClientList.LockList;
  try
    Index := LList.IndexOf(AClient);
    if Index <> -1 then
      LList.Delete(Index);
  finally
    FClientList.UnlockList;
  end;
end;

procedure TRefreshDispatcher.DispatchSimpleRefresh(ARefreshType: TJVCSRefreshType);
var
  I: Integer;
  JVCSRefresh: IJVCSRefresh;
  RefreshList, LList: TList;
  ClientToRefresh: TObject;
  ObjectIsStillInList: Boolean;
begin
  RefreshList := TList.Create;
  try
    LList := FClientList.LockList;
    try
      for I := 0 to Pred(LList.Count) do
        RefreshList.Add(LList[I]);
    finally
      FClientList.UnlockList;
    end;

    for I := 0 to Pred(RefreshList.Count) do
    begin
      ClientToRefresh := TObject(RefreshList[I]);
      LList := FClientList.LockList;
      try
        ObjectIsStillInList := LList.IndexOf(ClientToRefresh) <> -1;
      finally
        FClientList.UnlockList;
      end;
      if ObjectIsStillInList and
        (ClientToRefresh.GetInterface(IID_IJVCSRefresh, JVCSRefresh)) then
        JVCSRefresh.SimpleRefresh(ARefreshType);
    end;
  finally
    RefreshList.Free;
  end;
end;

initialization
  RefreshDispatcher := TRefreshDispatcher.Create;
  
finalization
  FreeAndNil(RefreshDispatcher);

end.
