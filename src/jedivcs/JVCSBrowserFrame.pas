(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSBrowserFrame.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2010/01/23  USchuster - new frame (Mantis #5103)
2010/01/29  USchuster - added an indication that a request is running (Mantis #5103)
2010/02/06  USchuster - D5 fix (removed Variants)
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit JVCSBrowserFrame;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, VirtualTrees, StdCtrls, ExtCtrls, JVCSConnect, Contnrs,
  JVCSNewClientObj, TZHandling, ShellAPI, JVCSInterfaces, Menus;

type
  TJVCSBrowserFrm = class(TFrame)
    Panel1: TPanel;
    btnRefresh: TButton;
    edDirectory: TEdit;
    VST: TVirtualStringTree;
    ImageList: TImageList;
    popmSharedby: TPopupMenu;
    mnOpenFile: TMenuItem;
    N2: TMenuItem;
    ShowsharedBy1: TMenuItem;
    N6: TMenuItem;
    mnCompare: TMenuItem;
    mnHistory: TMenuItem;
    mnLineHistory: TMenuItem;
    N7: TMenuItem;
    mnOpenParentFolder: TMenuItem;
    N8: TMenuItem;
    mnOpenProject: TMenuItem;
    lbRefreshWait: TLabel;
    RefreshWaitTimer: TTimer;
    procedure btnRefreshClick(Sender: TObject);
    procedure VSTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure VSTGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean;
      var ImageIndex: Integer);
    procedure VSTDblClick(Sender: TObject);
    procedure edDirectoryKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure mnOpenFileClick(Sender: TObject);
    procedure popmSharedbyPopup(Sender: TObject);
    procedure ShowsharedBy1Click(Sender: TObject);
    procedure mnCompareClick(Sender: TObject);
    procedure mnHistoryClick(Sender: TObject);
    procedure mnLineHistoryClick(Sender: TObject);
    procedure mnOpenParentFolderClick(Sender: TObject);
    procedure mnOpenProjectClick(Sender: TObject);
    procedure RefreshWaitTimerTimer(Sender: TObject);
  private
    { Private-Deklarationen }
    FViewItems: TObjectList;
    FListBaseDir: string;
    FConnection: TJVCSConnection;
    FFolderIndex: Integer;
    FOpenProjectBusy: Boolean;
    FProjectManager: IJVCSProjectManager;
    function GetSelectedModule(var AModuleID: Integer): Boolean;    
    function GetSelectedModuleFileName(var AModuleFileName: string): Boolean;
    function GetSelectedModuleName(var AModuleName: string): Boolean;    
    procedure RefreshList;
  public
    { Public-Deklarationen }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Connection: TJVCSConnection read FConnection write FConnection;
    property ProjectManager: IJVCSProjectManager read FProjectManager write FProjectManager;
  end;

implementation

uses
  VCSBase, DBModule, VCSProcBase, Std_ListView, History, JVCSGuiClientResources, TextComp,
  ConfigStorage, LoadModule, JVCSGUIClientImages;

{$R *.dfm}

type
  TListFileItem = class(TObject)
  private
    FKind: Integer;
    FModuleID: Integer;
    FName: string;
    FLatestRevisionUser: string;
    FLatestRevisionVersion: Integer;
    FLatestRevisionRevision: Integer;
    FLatestRevisionDate: TDateTime;
    FLatestRevisionComment: string;
    FLatestRevisionSize: Integer;
  public
    constructor Create;

    property Kind: Integer read FKind write FKind;
    property ModuleID: Integer read FModuleID write FModuleID;
    property Name: string read FName write FName;
    property LatestRevisionVersion: Integer read FLatestRevisionVersion write FLatestRevisionVersion;
    property LatestRevisionRevision: Integer read FLatestRevisionRevision write FLatestRevisionRevision;
    property LatestRevisionDate: TDateTime read FLatestRevisionDate write FLatestRevisionDate;
    property LatestRevisionComment: string read FLatestRevisionComment write FLatestRevisionComment;
    property LatestRevisionUser: string read FLatestRevisionUser write FLatestRevisionUser;
    property LatestRevisionSize: Integer read FLatestRevisionSize write FLatestRevisionSize;
  end;

{ TListFileItem }

constructor TListFileItem.Create;
begin
  inherited Create;
  FKind := 0;
  FModuleID := 0;
  FName := '';
  FLatestRevisionVersion := 0;
  FLatestRevisionRevision := 0;
  FLatestRevisionDate := 0;
  FLatestRevisionComment := '';
  FLatestRevisionUser := '';
  FLatestRevisionSize := -1;
end;

function GetSortKind(AKind: Integer): Integer;
begin
  if AKind = 3 then
    Result := 0
  else
  if AKind > 0 then
    Result := 1
  else
    Result := 2;
end;

function SortItemsByKind(AItem1, AItem2: Pointer): Integer;
var
  Item1, Item2: TListFileItem;
begin
  Item1 := TListFileItem(AItem1);
  Item2 := TListFileItem(AItem2);  
  Result := GetSortKind(Item1.Kind) - GetSortKind(Item2.Kind);
  if Result = 0 then
    Result := CompareStr(Item1.Name, Item2.Name);
end;

procedure TJVCSBrowserFrm.btnRefreshClick(Sender: TObject);
begin
  RefreshList;
end;

function GetWindowsDir: string;
var
  Buffer: array [0..MAX_PATH] of Char;
begin
  SetString(Result, Buffer, GetWindowsDirectory(Buffer, SizeOf(Buffer)));
end;

function GetImageIndexByExt(const AExtension: string): Integer;
var
  FileInfo: SHFILEINFO;
begin
  SHGetFileInfo(PChar(AExtension), FILE_ATTRIBUTE_NORMAL, FileInfo, SizeOf(FileInfo), SHGFI_SYSICONINDEX or SHGFI_USEFILEATTRIBUTES or SHGFI_SMALLICON);
  Result := FileInfo.iIcon;
end;

constructor TJVCSBrowserFrm.Create(AOwner: TComponent);
const
  ColumnWidthArray: array [0..5] of Integer = (144, 56, 56, 112, 96, 368);
var
  I: Integer;
  FileInfo: SHFILEINFO;
begin
  inherited Create(AOwner);
  FListBaseDir := '';
  FViewItems := TObjectList.Create;

  ImageList.Handle := SHGetFileInfo('', 0, FileInfo, SizeOf(TSHFileInfo),
    SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
  SHGetFileInfo(PChar(GetWindowsDir), 0, FileInfo, SizeOf(FileInfo), SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
  FFolderIndex := FileInfo.iIcon;
  FOpenProjectBusy := False;
  FProjectManager := nil;
  {$IFDEF IDEDLL}
  N8.Visible := False;
  mnOpenProject.Visible := False;
  {$ENDIF IDEDLL}
  if ShowMenuBitmaps then
    popmSharedby.Images := GetToolImageList;
  with VST.Header do
    for I := 0 to Columns.Count -1 do
      if I <= High(ColumnWidthArray) then
        Columns[I].Width :=
          jvcsReadInteger(sBaseRegistryKey + crbWindows, 'VCSBrowser_Col1.' + IntToStr(I), ColumnWidthArray[I]);
end;

destructor TJVCSBrowserFrm.Destroy;
var
  I: Integer;
begin
  with VST.Header do
    for I := 0 to Columns.Count -1 do
      jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'VCSBrowser_Col1.' + IntToStr(I), Columns[I].Width);
  VST.RootNodeCount := 0;
  FViewItems.Free;
  inherited Destroy;
end;

procedure TJVCSBrowserFrm.edDirectoryKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    RefreshList;
end;

function TJVCSBrowserFrm.GetSelectedModule(var AModuleID: Integer): Boolean;
var
  ListItem: TListFileItem;
begin
  Result := False;
  if Assigned(VST.FocusedNode) then
  begin
    ListItem := TListFileItem(FViewItems[VST.FocusedNode^.Index]);
    if ListItem.Kind = 0 then
    begin
      AModuleID := ListItem.ModuleID;
      Result := True;
    end;
  end;
end;

function TJVCSBrowserFrm.GetSelectedModuleFileName(var AModuleFileName: string): Boolean;
var
  ListItem: TListFileItem;
begin
  Result := False;
  if Assigned(VST.FocusedNode) then
  begin
    ListItem := TListFileItem(FViewItems[VST.FocusedNode^.Index]);
    if ListItem.Kind = 0 then
    begin
      AModuleFileName := FListBaseDir + ListItem.Name;
      Result := True;
    end;
  end;
end;

function TJVCSBrowserFrm.GetSelectedModuleName(var AModuleName: string): Boolean;
var
  ListItem: TListFileItem;
begin
  Result := False;
  if Assigned(VST.FocusedNode) then
  begin
    ListItem := TListFileItem(FViewItems[VST.FocusedNode^.Index]);
    if ListItem.Kind = 0 then
    begin
      AModuleName := ListItem.Name;
      Result := True;
    end;
  end;
end;

procedure TJVCSBrowserFrm.mnCompareClick(Sender: TObject);
var
  SelectedModuleID: Integer;
  SelectedModuleFileName: string;
  CurrentProjectState: TGUIClientProjectState;
begin
  if GetSelectedModule(SelectedModuleID) and GetSelectedModuleFileName(SelectedModuleFileName) then
  begin
    CurrentProjectState := SaveProjectState;
    try
      if OpenFirstModuleProject(SelectedModuleID, 1) then
        DoModuleCompare(SelectedModuleFileName);
    finally
      RestoreProjectState(CurrentProjectState);
    end;
  end;
end;

procedure TJVCSBrowserFrm.mnHistoryClick(Sender: TObject);
var
  SelectedModuleID: Integer;
  SelectedModuleFileName: string;
  CurrentProjectState: TGUIClientProjectState;
begin
  if GetSelectedModule(SelectedModuleID) and GetSelectedModuleFileName(SelectedModuleFileName) then
  begin
    CurrentProjectState := SaveProjectState;
    try
      if OpenFirstModuleProject(SelectedModuleID, 1) then
      begin
        VCSHistory := TVCSHistory.Create(Application);
        try
          VCSHistory.ModuleName := SelectedModuleFileName;
          VCSHistory.ModuleID := SelectedModuleID;
          VCSHistory.ShowModal;
        finally
          VCSHistory.Free;
        end;
      end;
    finally
      RestoreProjectState(CurrentProjectState);
    end;
  end;
end;

procedure TJVCSBrowserFrm.mnLineHistoryClick(Sender: TObject);
var
  SelectedModuleID: Integer;
  SelectedModuleFileName: string;
  CurrentProjectState: TGUIClientProjectState;
begin
  if Assigned(FProjectManager) and GetSelectedModule(SelectedModuleID) and
    GetSelectedModuleFileName(SelectedModuleFileName) then
  begin
    CurrentProjectState := SaveProjectState;
    try
      if OpenFirstModuleProject(SelectedModuleID, 1) then
        FProjectManager.ShowLineHistory(SelectedModuleFileName);
    finally
      RestoreProjectState(CurrentProjectState);
    end;
  end;
end;

procedure TJVCSBrowserFrm.mnOpenFileClick(Sender: TObject);
var
  SelectedModuleFileName, Mess: string;
begin
  if GetSelectedModuleFileName(SelectedModuleFileName) then
  begin
    ViewTheModule(WindowHandle, SelectedModuleFileName, Mess);
    BringWindowToTop(WindowHandle);
    BringWindowToTop(Self.Handle);
  end;
end;

procedure TJVCSBrowserFrm.mnOpenParentFolderClick(Sender: TObject);
var
  SelectedModuleFileName: string;
begin
  if GetSelectedModuleFileName(SelectedModuleFileName) then
    ShellOpenParentFolder(SelectedModuleFileName);
end;

procedure TJVCSBrowserFrm.mnOpenProjectClick(Sender: TObject);
{$IFNDEF IDEDLL}
var
  SelectedModuleID: Integer;
  CurrentProjectState: TGUIClientProjectState;
  FSelectedProjectID: Integer;
  FSelectedProjectName: string;
  FOpenProjectSelected: Boolean;
{$ENDIF ~IDEDLL}
begin
  {$IFNDEF IDEDLL}
  if GetSelectedModule(SelectedModuleID) then
  begin
    FOpenProjectSelected := False;
    FSelectedProjectID := -1;
    CurrentProjectState := SaveProjectState;
    try
      if OpenFirstModuleProject(SelectedModuleID, 1) then
      begin
        FSelectedProjectID := ServerProjectID;
        FSelectedProjectName := sProjectName;
        FOpenProjectSelected := True;
      end;
    finally
      RestoreProjectState(CurrentProjectState);
    end;
    if Assigned(FProjectManager) and FOpenProjectSelected then
    begin
      if not FOpenProjectBusy then
      begin
        FOpenProjectBusy := True;
        try
          FProjectManager.OpenProject(FSelectedProjectID, FSelectedProjectName);
        finally
          FOpenProjectBusy := False;
        end;
      end;
    end;
  end;
  {$ENDIF ~IDEDLL}
end;

procedure TJVCSBrowserFrm.popmSharedbyPopup(Sender: TObject);
var
  DummyStr: string;
begin
  mnCompare.Enabled := GetSelectedModuleFileName(DummyStr);
  mnOpenParentFolder.Enabled := mnCompare.Enabled;
  mnOpenProject.Enabled := mnCompare.Enabled;
  mnHistory.Enabled := mnCompare.Enabled;
  mnLineHistory.Enabled := mnCompare.Enabled and Assigned(FProjectManager);
  ShowsharedBy1.Enabled := mnCompare.Enabled;
  mnOpenFile.Enabled := mnCompare.Enabled;
end;

procedure TJVCSBrowserFrm.RefreshList;
var
  I: Integer;
  NewItem: TListFileItem;
  ListFiles: TJVCSListFiles;
  ListFilesOutputItem: TListFilesOutputItem;
begin
  lbRefreshWait.Caption := 'Server request: File list. Please wait';
  lbRefreshWait.Visible := True;
  RefreshWaitTimer.Enabled := True;
  VST.BeginUpdate;
  try
    VST.RootNodeCount := 0;
    FListBaseDir := edDirectory.Text;
    FViewItems.Clear;

    ListFiles := TJVCSListFiles.Create(nil);
    try
      ListFiles.Dir := FListBaseDir;
      FConnection.SendRequest(ListFiles);
      if FListBaseDir <> '' then
      begin
        NewItem := TListFileItem.Create;
        FViewItems.Add(NewItem);
        NewItem.Kind := 3;
        NewItem.Name := '..';
      end;
      for I := 0 to Pred(ListFiles.OutputItemCount) do
      begin
        ListFilesOutputItem := ListFiles.OutputItems[I];
        NewItem := TListFileItem.Create;
        NewItem.Kind := ListFilesOutputItem.Kind;
        NewItem.ModuleID := ListFilesOutputItem.ModuleID;
        //LatestRevisionID [3]
        NewItem.Name := ChangeFileExt(ListFilesOutputItem.Name, TrimRight(ListFilesOutputItem.LatestRevisionExtension));
        NewItem.LatestRevisionVersion := ListFilesOutputItem.LatestRevisionVersion;
        NewItem.LatestRevisionRevision := ListFilesOutputItem.LatestRevisionRevision;
        NewItem.LatestRevisionComment := ListFilesOutputItem.LatestRevisionComment_I;
        NewItem.LatestRevisionUser := ListFilesOutputItem.LatestRevisionUser;
        NewItem.LatestRevisionDate := GMTDT2LocalDT(ListFilesOutputItem.LatestRevisionTS);
        NewItem.LatestRevisionSize := ListFilesOutputItem.LatestRevisionOrigSize;
        FViewItems.Add(NewItem);
      end;
    finally
      ListFiles.Free;
    end;
    FViewItems.Sort(SortItemsByKind);
    VST.RootNodeCount := FViewItems.Count;
  finally
    VST.EndUpdate;
    lbRefreshWait.Visible := False;
    RefreshWaitTimer.Enabled := False;
  end;
end;

procedure TJVCSBrowserFrm.RefreshWaitTimerTimer(Sender: TObject);
begin
  lbRefreshWait.Caption := lbRefreshWait.Caption + '.';
end;

procedure TJVCSBrowserFrm.ShowsharedBy1Click(Sender: TObject);
var
  ResultString: string;
  VCSStdListView2: TVCSStdListView;
  SelectedModuleID: Integer;
  SelectedModuleName: string;
begin
  if GetSelectedModule(SelectedModuleID) then
  begin
    with DataModule1 do
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_SHARED_BY';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [SelectedModuleID]);
      SetupTimeoutCounter;
      AppSrvClient1.Send;

      while WaitForAppSrvClient do
        Application.ProcessMessages;
      if (AppSrvClientErr = -99) then
      begin
        ShowServerTimeOut(WindowHandle);
        Exit;
      end;
      if (AppSrvClientErr <> 0) or
        (AppSrvClient1.AnswerStatus <> '200') then
      begin
        ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
          AppSrvClient1.AnswerStatus);
        Exit;
      end;

      AppSrvClient1.Answer.First;
      ResultString := '';
      while not AppSrvClient1.Answer.Eof do
      begin
        ResultString := ResultString + AppSrvClient1.Answer.Fields[1] + ';' +
          AppSrvClient1.Answer.Fields[0] + ';|';
        AppSrvClient1.Answer.Next;
      end;
    end; // with DataModule1 do begin
    Application.CreateForm(TVCSStdListView, VCSStdListView2);
    try
      GetSelectedModuleName(SelectedModuleName);
      VCSStdListView2.Caption := SelectedModuleName;
      VCSStdListView2.Left := Left + 60;
      VCSStdListView2.Top := Top + 60;
      VCSStdListView2.LVType := 0;
      VCSStdListView2.HelpContextID :=
        IDH_Sharing_modules_between_different_projects;
      VCSStdListView2.AddListColumn(JVCSRES_Shared_by_project__, False);
      VCSStdListView2.AddListColumn(JVCSRES_Project_ID, True);
      VCSStdListView2.SetUpItems(ResultString);
      VCSStdListView2.ShowModal;
    finally
      VCSStdListView2.Free;
    end;
  end;
end;

procedure TJVCSBrowserFrm.VSTDblClick(Sender: TObject);
var
  ListItem: TListFileItem;
  S: string;
  I, PCnt: Integer;
begin
  if Assigned(VST.FocusedNode) then
  begin
    ListItem := TListFileItem(FViewItems[VST.FocusedNode^.Index]);
    if (ListItem.Kind = 1) or (ListItem.Kind = 2) then
    begin
      edDirectory.Text := FListBaseDir + ListItem.Name;
      RefreshList;
    end
    else
    if ListItem.Kind = 3 then
    begin
      S := FListBaseDir;
      PCnt := 0;
      for I := Length(S) downto 1 do
      begin
        if S[I] = '\' then
        begin
          if PCnt = 1 then
            Break;
          Inc(PCnt);
        end;
        Delete(S, Length(S), 1);
      end;
      edDirectory.Text := S;
      RefreshList;
    end;
  end;
end;

procedure TJVCSBrowserFrm.VSTGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
begin
  if (Column = 0) and (Kind in [ikNormal, ikSelected]) then
  begin
    case TListFileItem(FViewItems[Node^.Index]).Kind of
      0: ImageIndex := GetImageIndexByExt(ExtractFileExt(TListFileItem(FViewItems[Node^.Index]).Name));
      1, 2: ImageIndex := FFolderIndex;
    end;
  end;
end;

procedure TJVCSBrowserFrm.VSTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
var
  ListItem: TListFileItem;
  S: string;
  L: Integer;
begin
  ListItem := TListFileItem(FViewItems[Node^.Index]);
  CellText := '';
  if (Column = 0) or (ListItem.LatestRevisionVersion <> 0) or (ListItem.LatestRevisionRevision <> 0) then
    case Column of
      0:
         begin
           S := ListItem.Name;
           L := Length(S);
           if (L > 0) and (S[L] = '\') then
             Delete(S, L, 1);
           CellText := S;
         end;
      1: CellText := Format('%d.%d', [ListItem.LatestRevisionVersion, ListItem.LatestRevisionRevision]);
      2: if (ListItem.LatestRevisionSize <> -1) and (ListItem.Kind = 0) then
           CellText := IntToStr(ListItem.LatestRevisionSize);
      3: CellText := DateTimeToStr(ListItem.LatestRevisionDate);
      4: CellText := ListItem.LatestRevisionUser;
      5: CellText := ListItem.LatestRevisionComment;
    end;
end;

end.
