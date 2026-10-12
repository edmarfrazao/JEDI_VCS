(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: ToDoDockWnd.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2003/09/15  USchuster - new unit (code moved from ProjAdmin.pas)
2003/11/30  USchuster - replaced server function calls with ClientObjects
2004/01/11  USchuster - refresh is now done in a separate thread
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/09  USchuster - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - removed THREADREFRESH directive and matching code
2005/03/05  USchuster - use TJVCSDockableForm.HandleThreadException to ignore
                        appserver result 403 in the thread (mantis #2714)                      

-----------------------------------------------------------------------------*)

unit ToDoDockWnd;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  JVCSDockForm, ComCtrls, ActnList, ImgList, Menus, StdCtrls, ToolWin,
  EnhListView, ExtCtrls, JVCSInterfaces, JVCSThreads;

type //USc - should be moved into JVCSTypes because it's also defined in ProjAdmin.pas
  // Listview columns width
  TColWidth = record
    Col: array [0..12] of Word;
  end;

const
  //MyToDo-Listview columns
  colTdPrio = 0;
  colTdDate = 1;
  colTdProject = 2;
  colTdResp = 3;
  colTdCategory = 4;
  colTdToDo = 5;
  colTdTarget = 6;
  colTdDone = 7;

type
  TJVCSDockToDoWindow = class(TJVCSDockableForm, IJVCSRefresh)
    ToolImageList: TImageList;
    StateToDoImageImageList: TImageList;
    ActionListMsgWin: TActionList;
    acRefreshMyToDoLv: TAction;
    ImageList: TImageList;
    popupMyToDoLv: TPopupMenu;
    RefreshToDoList1: TMenuItem;
    spltMyToDo: TSplitter;
    elvToDo: TdfsEnhListView;
    ToolBar1: TToolBar;
    ToolButton36: TToolButton;
    mmoToDo: TMemo;
    procedure acRefreshMyToDoLvExecute(Sender: TObject);
    procedure elvToDoDrawItem(Control: TWinControl; var ACanvas: TCanvas;
      Index: Integer; ARect: TRect; State: TOwnerDrawState;
      var DefaultDrawing, FullRowSelect: Boolean);
    procedure elvToDoDrawSubItem(Control: TWinControl;
      var ACanvas: TCanvas; Index, SubItem: Integer; ARect: TRect;
      State: TOwnerDrawState; var DefaultDrawing: Boolean);
    procedure elvToDoDrawHeader(Control: TWinControl; var ACanvas: TCanvas;
      Index: Integer; var ARect: TRect; Selected: Boolean;
      var DefaultDrawing: Boolean);
    procedure elvToDoSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    ColWidthMyToDo: TColWidth;
    FInternalThread: TJVCSJobThread;
    FVCLSyncAction: Integer;
    FIsFilling: Boolean;
    FTodoItems: TList;
    procedure FreeLVToDoData;
    procedure AddLVItem(const LVItem: TListItem; APriority: Integer; ADateStr,
      Project, Responsible, Category, Description: string; Target, Done: Double;
      const ID: Integer; const Changed: Boolean);
    procedure SaveFormSize;
    procedure ThreadFillListView(AThreadJob: TJVCSThreadJob);
    procedure ThreadSetControlState(AThreadJob: TJVCSThreadJob);
    procedure VCLThreadSyncProc;
    procedure ClearTodoItems;
  public
    { Public declarations }
    procedure SimpleRefresh(ARefreshType: TJVCSRefreshType);
  end;

var
  JVCSDockToDoWindow: TJVCSDockToDoWindow;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  DBModule, VCSBase, TZHandling, ConfigStorage, JVCSClientObj;

{$R *.dfm}

const
  cSyncActionClearListView = 1;
  cSyncActionFillListView = 2;
  cSyncActionSetControlStateFalse = 3;
  cSyncActionSetControlStateOnDepend = 4;

procedure TJVCSDockToDoWindow.ThreadFillListView(AThreadJob: TJVCSThreadJob);
var
  TodoEntries: TJVCSGetTodoEntries;
  TodoEntryPtr: PGetTodoEntriesOutputItem;
  I: Integer;
begin
  if not FIsFilling then
  begin
    FIsFilling := True;
    try
      FVCLSyncAction := cSyncActionClearListView;
      AThreadJob.Sync(VCLThreadSyncProc);
      if (Integer(AThreadJob.Parameter) = cSyncActionFillListView) and
        (ServerUserID > 0) then
      begin
        ClearTodoItems;
        TodoEntries := TJVCSGetTodoEntries.Create(nil);
        try
          TodoEntries.UserID := ServerUserID;
          TodoEntries.ProjectID := 0;
          TodoEntries.Category := '';
          TodoEntries.Priority := 0;
          TodoEntries.NotDoneOnly := True;
          TodoEntries.TargetDate := 0;

          DataModule1.ClientObjectSendRequest(TodoEntries);

          with TodoEntries do
            for I := 0 to OutputItemCount - 1 do
            begin
              New(TodoEntryPtr);
              TodoEntryPtr^ := OutputItems[I];
              FTodoItems.Add(TodoEntryPtr);
            end;
        finally
          TodoEntries.Free;
        end;
        if not AThreadJob.Aborted then
        begin
          FVCLSyncAction := cSyncActionFillListView;
          AThreadJob.Sync(VCLThreadSyncProc);
        end;
        ClearTodoItems;
      end;
    finally
      FIsFilling := False;
    end;
  end;
end;

procedure TJVCSDockToDoWindow.ThreadSetControlState(AThreadJob: TJVCSThreadJob);
var
  ParameterInteger: Integer;
begin
  ParameterInteger := Integer(AThreadJob.Parameter);
  if (ParameterInteger = cSyncActionSetControlStateFalse) or
    (ParameterInteger = cSyncActionSetControlStateOnDepend) then
  begin
    FVCLSyncAction := ParameterInteger;
    AThreadJob.Sync(VCLThreadSyncProc);
  end;
end;

procedure TJVCSDockToDoWindow.VCLThreadSyncProc;
var
  I: Integer;
begin
  if FVCLSyncAction = cSyncActionClearListView then
  begin
    FreeLVToDoData;
    elvToDo.Items.Clear;
  end
  else
  if FVCLSyncAction = cSyncActionFillListView then
  begin
    elvToDo.BeginUpdate;
    try
      for I := 0 to Pred(FTodoItems.Count) do
        with PGetTodoEntriesOutputItem(FTodoItems[I])^ do
          AddLVItem(nil,
            Priority,
            DateToStr(GMTDT2LocalDT(Timestamp)),
            ProjectName,
            UserName,
            Category,
            Description,
            GMTDT2LocalDT(TargetDate),
            GMTDT2LocalDT(DoneDate),
            TodoID,
            False);
    finally
      elvToDo.EndUpdate;
    end;
    if elvToDo.Items.Count > 0 then
    begin
      elvToDo.Resort;
      elvToDo.Selected := nil;
      elvToDo.Invalidate;
    end; // if elvToDo.Items.Count > 0 then begin
  end
  else
  if FVCLSyncAction = cSyncActionSetControlStateFalse then
    acRefreshMyToDoLv.Enabled := False
  else
  if FVCLSyncAction = cSyncActionSetControlStateOnDepend then
    acRefreshMyToDoLv.Enabled := ServerUserID > 0;
end;

procedure TJVCSDockToDoWindow.ClearTodoItems;
var
  I: Integer;
begin
  for I := 0 to Pred(FTodoItems.Count) do
    Dispose(FTodoItems[I]);
  FTodoItems.Clear;
end;

type
  TLVToDoData = record
    ID,
    State: Integer;
    Changed: Boolean;
    Target,
    Done: Double;
  end;

procedure TJVCSDockToDoWindow.acRefreshMyToDoLvExecute(Sender: TObject);
begin
  FInternalThread.DisqueueAndAbortAllJobsAndWait;
  FInternalThread.AddJob(ThreadFillListView,
    Pointer(cSyncActionFillListView));
end;

procedure TJVCSDockToDoWindow.elvToDoDrawItem(Control: TWinControl;
  var ACanvas: TCanvas; Index: Integer; ARect: TRect;
  State: TOwnerDrawState; var DefaultDrawing, FullRowSelect: Boolean);
begin
  DefaultDrawing := True;
  FullRowSelect := True;
end;

procedure TJVCSDockToDoWindow.elvToDoDrawSubItem(Control: TWinControl;
  var ACanvas: TCanvas; Index, SubItem: Integer; ARect: TRect;
  State: TOwnerDrawState; var DefaultDrawing: Boolean);
begin
  DefaultDrawing := True;
end;

procedure TJVCSDockToDoWindow.elvToDoDrawHeader(Control: TWinControl;
  var ACanvas: TCanvas; Index: Integer; var ARect: TRect;
  Selected: Boolean; var DefaultDrawing: Boolean);
begin
  DefaultDrawing := True;
end;

procedure TJVCSDockToDoWindow.elvToDoSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if Selected and Assigned(Item) then
    mmoToDo.Text := Item.SubItems[colTdToDo-1]
  else
    mmoToDo.Text := '';
end;

procedure TJVCSDockToDoWindow.FormCreate(Sender: TObject);
begin
  try
    inherited;
    // same for ColWidthMyToDo
    with ColWidthMyToDo do
    begin
      Col[colTdPrio] :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_ToDoCol1.0', 60);
      Col[colTdPrio] :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_ToDoCol1.1', 70);
      Col[colTdDate] :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_ToDoCol1.2', 80);
      Col[colTdProject] :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_ToDoCol1.3', 70);
      Col[colTdResp] :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_ToDoCol1.4', 70);
      Col[colTdCategory] :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_ToDoCol1.5', 70);
      Col[colTdToDo] :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_ToDoCol1.6', 200);
      Col[colTdTarget] :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_ToDoCol1.7', 70);
      Col[colTdDone] :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjMan_ToDoCol1.8', 70);
    end;
    // Set width of ToDoListView.columns
    with elvToDo do
    begin
      Columns[colTdPrio].Width := ColWidthMyToDo.Col[colTdPrio];
      Columns[colTdDate].Width := ColWidthMyToDo.Col[colTdDate];
      Columns[colTdProject].Width := ColWidthMyToDo.Col[colTdProject];
      Columns[colTdResp].Width := ColWidthMyToDo.Col[colTdResp];
      Columns[colTdCategory].Width := ColWidthMyToDo.Col[colTdCategory];
      Columns[colTdToDo].Width := ColWidthMyToDo.Col[colTdToDo];
      Columns[colTdTarget].Width := ColWidthMyToDo.Col[colTdTarget];
      Columns[colTdDone].Width := ColWidthMyToDo.Col[colTdDone];
    end;
    elvToDo.Width := jvcsReadInteger(sBaseRegistryKey + crbWindows, 'splMyToDoLeft', 500);
    FInternalThread := TJVCSJobThread.Create(False);
    FInternalThread.OnJobException := HandleThreadException;    
    FIsFilling := False;
    FTodoItems := TList.Create;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

procedure TJVCSDockToDoWindow.FormShow(Sender: TObject);
begin
  inherited;
  SimpleRefresh(rtRefresh);
end;

procedure TJVCSDockToDoWindow.FormDestroy(Sender: TObject);
begin
  SaveFormSize;
  ClearTodoItems;
  FTodoItems.Free;
  FInternalThread.Free;
  inherited;
end;

procedure TJVCSDockToDoWindow.FreeLVToDoData;
var
  I: Integer;
begin
  // Free Memory
  for I := elvToDo.Items.Count - 1 downto 0 do
    if Assigned(elvToDo.Items[I].Data) then
      Dispose(elvToDo.Items[I].Data);
end;

procedure TJVCSDockToDoWindow.AddLVItem(const LVItem: TListItem;
  APriority: Integer; ADateStr, Project, Responsible, Category, Description: string;
  Target, Done: Double; const ID: Integer; const Changed: Boolean);
var
  NewLVItem: TListItem;
  NewItem: Boolean;
  I: Integer;
  PLVToDoData: ^TLVToDoData;
begin
  if Done < 1 then
    Done := 0;
  if Target < 1 then
    Target := 0;
  NewItem := (LVItem = nil);
  if NewItem then
    NewLVItem := elvToDo.Items.Add
  else
    NewLVItem := LVItem;
  if APriority = 1 then
    NewLVItem.ImageIndex := 0;
  if APriority = 2 then
    NewLVItem.ImageIndex := 1;
  if APriority = 3 then
    NewLVItem.ImageIndex := 2;
  if APriority > 3 then
    NewLVItem.ImageIndex := 3;
  if (Done > 0) and (Done <= Now) then
    NewLVItem.StateIndex := 1
  else
  begin
    if (Target > 0) and (Target <= Now) then
      NewLVItem.StateIndex := 2
    else
      NewLVItem.StateIndex := 0;
  end;
  NewLVItem.Caption := IntToStr(APriority);
  if NewItem then
  begin
    NewLVItem.SubItems.Add(ADateStr);
    NewLVItem.SubItems.Add(Project);
    NewLVItem.SubItems.Add(Responsible);
    NewLVItem.SubItems.Add(Category);
    NewLVItem.SubItems.Add(Description);
    if (Int(Target) = 0) then
      NewLVItem.SubItems.Add('-')
    else
      NewLVItem.SubItems.Add(DateToStr(Target));
    if (Int(Done) = 0) then
      NewLVItem.SubItems.Add('-')
    else
      NewLVItem.SubItems.Add(DateToStr(Done));

    New(PLVToDoData);
    PLVToDoData^.ID := ID;
    PLVToDoData^.State := 0;
    PLVToDoData^.Changed := Changed;
    PLVToDoData^.Target := Int(Target);
    PLVToDoData^.Done := Int(Done);
    NewLVItem.Data := PLVToDoData;

    for I := 0 to elvToDo.Items.Count - 1 do
      elvToDo.Items[I].Selected := False;
    NewLVItem.Selected := True;
  end // if NewItem then begin
  else
  begin
    NewLVItem.SubItems[0] := ADateStr;
    NewLVItem.SubItems[1] := Project;
    NewLVItem.SubItems[2] := Responsible;
    NewLVItem.SubItems[3] := Category;
    NewLVItem.SubItems[4] := Description;
    if (Int(Target) = 0) then
      NewLVItem.SubItems[5] := '-'
    else
      NewLVItem.SubItems[5] := DateToStr(Target);
    if (Int(Done) = 0) then
      NewLVItem.SubItems[6] := '-'
    else
      NewLVItem.SubItems[6] := DateToStr(Done);

    TLVToDoData(NewLVItem.Data^).ID := ID;
    TLVToDoData(NewLVItem.Data^).State := 0;
    TLVToDoData(NewLVItem.Data^).Changed := Changed;
    TLVToDoData(NewLVItem.Data^).Target := Int(Target);
    TLVToDoData(NewLVItem.Data^).Done := Int(Done);
  end;
end;


procedure TJVCSDockToDoWindow.SaveFormSize;
var
  ColToDoChanged: Boolean;
  I: Integer;
begin
  jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'splMyToDoLeft', elvToDo.Width);

  ColToDoChanged := False;
  with elvToDo do
  begin
    for I := 0 to 7 do
    begin
      if ColWidthMyToDo.Col[I] <> Columns[I].Width then
      begin
        ColToDoChanged := True;
        Break;
      end;
    end;
    if ColToDoChanged then
    begin
      ColWidthMyToDo.Col[colTdPrio] := Columns[colTdPrio].Width;
      ColWidthMyToDo.Col[colTdDate] := Columns[colTdDate].Width;
      ColWidthMyToDo.Col[colTdProject] := Columns[colTdProject].Width;
      ColWidthMyToDo.Col[colTdResp] := Columns[colTdResp].Width;
      ColWidthMyToDo.Col[colTdCategory] := Columns[colTdCategory].Width;
      ColWidthMyToDo.Col[colTdToDo] := Columns[colTdToDo].Width;
      ColWidthMyToDo.Col[colTdTarget] := Columns[colTdTarget].Width;
      ColWidthMyToDo.Col[colTdDone] := Columns[colTdDone].Width;
    end; // if ColToDoChanged then begin
  end; // with elvTodo do begin
  if ColToDoChanged then
  begin
    with ColWidthMyToDo do
    begin
      jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjMan_ToDoCol1.0', Col[colTdPrio]);
      jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjMan_ToDoCol1.1', Col[colTdPrio]);
      jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjMan_ToDoCol1.2', Col[colTdDate]);
      jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjMan_ToDoCol1.3', Col[colTdProject]);
      jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjMan_ToDoCol1.4', Col[colTdResp]);
      jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjMan_ToDoCol1.5', Col[colTdCategory]);
      jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjMan_ToDoCol1.6', Col[colTdToDo]);
      jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjMan_ToDoCol1.7', Col[colTdTarget]);
      jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjMan_ToDoCol1.8', Col[colTdDone]);
    end;
  end;
end;

procedure TJVCSDockToDoWindow.SimpleRefresh(ARefreshType: TJVCSRefreshType);
begin
  case ARefreshType of
    rtConnected, rtRefresh:
    begin
      FInternalThread.DisqueueAndAbortAllJobsAndWait;
      FInternalThread.AddJob(ThreadSetControlState,
        Pointer(cSyncActionSetControlStateOnDepend));
      FInternalThread.AddJob(ThreadFillListView,
        Pointer(cSyncActionFillListView));
    end;
    rtDisconnected:
    begin
      FInternalThread.DisqueueAndAbortAllJobsAndWait;
      FInternalThread.AddJob(ThreadSetControlState,
        Pointer(cSyncActionSetControlStateFalse));
      FInternalThread.AddJob(ThreadFillListView,
        Pointer(cSyncActionClearListView));
    end;
  end;
end;

end.
