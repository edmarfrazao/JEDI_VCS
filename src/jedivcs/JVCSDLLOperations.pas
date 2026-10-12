(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSDLLOperations.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2005/07/11  USchuster - new unit
2005/09/04  USchuster - added some project operations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC3 released ^^^^^^^^^^^^^^^^^^^^^^^^^^^
2006/01/21  THuber    - warnings removed
2008/02/17  USchuster - added member to CompareModule (Mantis #4262)
2010/01/24  USchuster - added DiffModule (Mantis #5101)

-----------------------------------------------------------------------------*)

unit JVCSDLLOperations;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  {$IFDEF DEBUG}
  JclDebug,
  {$ENDIF DEBUG}
  SysUtils, VCSBase, DBModule, JVCSClientObj, JVCSIDEInterfaceCommon, ChkInSingle,
  ChkOutSingle, Forms, JVCSClasses, History, TextComp, VCSProcBase, ModuleInfo,
  ProjAdmin, ProjectHist, Syncronice, JVCSCompressedDiffDialog;

function JediVCSDLLOperationsInit(AExternalVCSOperationFunctionRec: PExternalVCSOperationFunctionRec): Boolean; stdcall;

implementation

var
  ProjectNameToIDList: TModuleNameToIDList = nil;

procedure CreateProjectNameToIDList;
begin
  if not Assigned(ProjectNameToIDList) then
    ProjectNameToIDList := TModuleNameToIDList.Create;
end;

function GetProjectID(AProjectName: PChar): Integer; stdcall;
var
  GetProjectId: TJVCSGetProjectId;
  Idx: Integer;
  CurrentProjectState: TGUIClientProjectState;
begin
  Result := -1;
  if ServerUserID > 0 then
  begin
    CurrentProjectState := SaveProjectState;
    try
      CreateProjectNameToIDList;
      Idx := ProjectNameToIDList.IndexOf(StrPas(AProjectName));
      if Idx = -1 then
      begin
        GetProjectId := TJVCSGetProjectId.Create(nil);
        try
          GetProjectId.ProjectName := ExtractFileName(StrPas(AProjectName));
          DataModule1.ClientObjectSendRequest(GetProjectId);
          TransactionNr := GetProjectId.TransactionID;
          ServerProjectID := GetProjectId.ProjectID;
          Result := GetProjectId.ProjectID;
          ProjectNameToIDList.AddOrReplace(StrPas(AProjectName), Result);
        finally
          GetProjectId.Free;
        end;
      end
      else
        Result := ProjectNameToIDList[Idx].ModuleID;
    finally
      RestoreProjectState(CurrentProjectState);
    end;
  end;
  {$IFDEF DEBUG}
  JclDebug.TraceFmt(' GetProjectID(%s)=%d', [StrPas(AProjectName), Result]);
  {$ENDIF DEBUG}
end;

function OpenProjectByID(AProjectID: Integer; AMinimumAccessLevel: Integer = 1): Boolean;
var
  GetProjectList: TJVCSGetProjectList;
  GetProjectId: TJVCSGetProjectId;
  I: Integer;
  ProjectName: string;
begin
  Result := False;
  if ServerUserID > 0 then
  begin
    GetProjectList := TJVCSGetProjectList.Create(nil);
    try
      GetProjectList.IncludeDetails := False;
      DataModule1.ClientObjectSendRequest(GetProjectList);
      ProjectName := '';
      for I := 0 to Pred(GetProjectList.OutputItemCount) do
        if GetProjectList.OutputItems[I].ProjectID = AProjectID then
        begin
          ProjectName := GetProjectList.OutputItems[I].ProjectName;
          Break;
        end;
    finally
      GetProjectList.Free;
    end;
    if ProjectName <> '' then
    begin
      GetProjectId := TJVCSGetProjectId.Create(nil);
      try
        GetProjectId.ProjectName := ProjectName;
        DataModule1.ClientObjectSendRequest(GetProjectId);
        TransactionNr := GetProjectId.TransactionID;
        ServerProjectID := GetProjectId.ProjectID;
        if (not GetProjectId.ProjectDeleted) and (GetProjectId.AccessLevel >= AMinimumAccessLevel) then
        begin
          bProjectOPen := True;
          sProjectName := ProjectName;
          Result := True;
        end;
      finally
        GetProjectId.Free;
      end;
    end;
  end;
end;

function CheckInModule(AProjectID: Integer; AModuleName: PChar): Boolean; stdcall;
var
  CurrentProjectState: TGUIClientProjectState;
begin
  Result := True;
  CurrentProjectState := SaveProjectState;
  try
    if OpenProjectByID(AProjectID, 2) then
    begin
      VCSChkInSingle := TVCSChkInSingle.Create(Application);
      try
        VCSChkInSingle.SelectModuleList.AddObject(StrPas(AModuleName), TObject(AProjectID));
        VCSChkInSingle.AsChild := True;
        VCSChkInSingle.ShowModal;
  //    NeedRefresh := VCSChkInSingle.ArchiveChanged;
      finally
        VCSChkInSingle.Free;
      end;
    end;
  finally
    RestoreProjectState(CurrentProjectState);
  end;
end;

function CheckOutModule(AProjectID: Integer; AModuleName: PChar): Boolean; stdcall;
var
  CurrentProjectState: TGUIClientProjectState;
begin
  Result := True;
  CurrentProjectState := SaveProjectState;
  try
    if OpenProjectByID(AProjectID, 2) then
    begin
      VCSChkOutSingle := TVCSChkOutSingle.Create(Application);
      try
        VCSChkOutSingle.SelectModuleList.AddObject(StrPas(AModuleName), TObject(AProjectID));
        VCSChkOutSingle.AsChild := True;
        VCSChkOutSingle.ShowModal;
  //    NeedRefresh := VCSChkOutSingle.ArchiveChanged;
  //    HasErrors := VCSChkOutSingle.HasErrors;
      finally
        VCSChkOutSingle.Free;
      end;
    end;
  finally
    RestoreProjectState(CurrentProjectState);
  end;
end;

function GetModule(AProjectID: Integer; AModuleName: PChar): Boolean; stdcall;
var
  CurrentProjectState: TGUIClientProjectState;
begin
  Result := True;
  CurrentProjectState := SaveProjectState;
  try
    if OpenProjectByID(AProjectID, 1) then
    begin
      VCSInfo := TVCSInfo.Create(Application);
      try
        VCSInfo.ModuleID := 0;
        VCSInfo.ModuleName := StrPas(AModuleName);
        VCSInfo.GetEnabled := True;
        VCSInfo.ShowModal;
      finally
        VCSInfo.Free;
      end;
    end;
  finally
    RestoreProjectState(CurrentProjectState);
  end;
end;

function CompareModule(AProjectID: Integer; AModuleName, AModuleMember: PChar): Boolean; stdcall;
var
  CurrentProjectState: TGUIClientProjectState;
begin
  Result := True;
  CurrentProjectState := SaveProjectState;
  try
    if OpenProjectByID(AProjectID, 1) then
      DoModuleCompare(StrPas(AModuleName), StrPas(AModuleMember), 0);
  finally
    RestoreProjectState(CurrentProjectState);
  end;
end;

function ShowModuleHistory(AProjectID: Integer; AModuleName: PChar): Boolean; stdcall;
var
  CurrentProjectState: TGUIClientProjectState;
begin
  Result := True;
  CurrentProjectState := SaveProjectState;
  try
    if OpenProjectByID(AProjectID, 1) then
    begin
      VCSHistory := TVCSHistory.Create(Application);
      try
        VCSHistory.ProjectID := AProjectID;
        VCSHistory.ModuleName := StrPas(AModuleName);
        VCSHistory.ShowModal;
      finally
        VCSHistory.Free;
      end;
    end;
  finally
    RestoreProjectState(CurrentProjectState);
  end;
end;

function ShowProjectManager(AProjectID: Integer): Boolean; stdcall;
var
  CurrentProjectState: TGUIClientProjectState;
begin
  Result := True;
  CurrentProjectState := SaveProjectState;
  try
    if OpenProjectByID(AProjectID, 1) then
    begin
      if Assigned(VCSProjAdmin) then
        VCSProjAdmin.Show
      else
      begin
        Assert(VCSProjAdmin = nil, 'TJVCSClient.DoProjAdmin');
        VCSProjAdmin := TVCSProjAdmin.Create(Application); // unit ProjAdmin
        try
          bPJM_Created := True;
          bPJM_NeedRefresh := False;
          VCSProjAdmin.Show;
        except
          VCSProjAdmin.Free;
          VCSProjAdmin := nil;
          bPJM_Created := False;
          bPJM_Valid := False;
          bPJM_NeedRefresh := False;
          bPJM_TopWindow := False;
        end;
      end; // else if ProjManVisible then begin
    end;
  finally
    RestoreProjectState(CurrentProjectState);
  end;
end;

function ShowProjectHistory(AProjectID: Integer): Boolean; stdcall;
var
  CurrentProjectState: TGUIClientProjectState;
begin
  Result := True;
  CurrentProjectState := SaveProjectState;
  try
    if OpenProjectByID(AProjectID, 1) then
    begin
      VCSProjectHistory := TVCSProjectHistory.Create(Application);
      try
        VCSProjectHistory.ShowModal;
      finally
        VCSProjectHistory.Free;
      end;
    end;
  finally
    RestoreProjectState(CurrentProjectState);
  end;
end;

function SyncProject(AProjectID: Integer): Boolean; stdcall;
var
  CurrentProjectState: TGUIClientProjectState;
begin
  Result := True;
  CurrentProjectState := SaveProjectState;
  try
    if OpenProjectByID(AProjectID, 1) then
    begin
      VCSSync := TVCSSync.Create(Application);
      try
        VCSSync.AutoClose := False;
        VCSSync.ShowModal;
      finally
        VCSSync.Free;
      end;
    end;
  finally
    RestoreProjectState(CurrentProjectState);
  end;
end;

function DiffModule(AProjectID: Integer; AModuleName, AModuleMember: PChar): Boolean; stdcall;
var
  CurrentProjectState: TGUIClientProjectState;
  GetModuleId: TJVCSGetModuleId;
  ModuleID: Integer;
begin
  Result := True;
  CurrentProjectState := SaveProjectState;
  try
    if OpenProjectByID(AProjectID, 1) then
    begin
      GetModuleId := TJVCSGetModuleId.Create(nil);
      try
        GetModuleId.ModuleName := StrPas(AModuleName);
        DataModule1.ClientObjectSendRequest(GetModuleId);
        ModuleID := GetModuleId.ModuleID;
      finally
        GetModuleId.Free;
      end;
      if ModuleID > 0 then
        ShowCompressDiffDialogLocalToLatest(ChangeFileExt(StrPas(AModuleName), StrPas(AModuleMember)), StrPas(AModuleMember), ModuleID);
    end;
  finally
    RestoreProjectState(CurrentProjectState);
  end;
end;

function JediVCSDLLOperationsInit(AExternalVCSOperationFunctionRec: PExternalVCSOperationFunctionRec): Boolean; stdcall;
begin
  Result := False;
  if Assigned(AExternalVCSOperationFunctionRec) then
  begin
    AExternalVCSOperationFunctionRec^.GetProjectID := GetProjectID;
    AExternalVCSOperationFunctionRec^.CheckInModule := CheckInModule;
    AExternalVCSOperationFunctionRec^.CheckOutModule := CheckOutModule;
    AExternalVCSOperationFunctionRec^.GetModule := GetModule;    
    AExternalVCSOperationFunctionRec^.CompareModule := CompareModule;
    AExternalVCSOperationFunctionRec^.ShowModuleHistory := ShowModuleHistory;
    AExternalVCSOperationFunctionRec^.ShowProjectManager := ShowProjectManager;    
    AExternalVCSOperationFunctionRec^.ShowProjectHistory := ShowProjectHistory;    
    AExternalVCSOperationFunctionRec^.SyncProject := SyncProject;
    AExternalVCSOperationFunctionRec^.DiffModule := DiffModule;
    Result := True;
  end;
end;

initialization

finalization
  ProjectNameToIDList.Free;

end.
