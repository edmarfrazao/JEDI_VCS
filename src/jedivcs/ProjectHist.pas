(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: ProjectHist.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS: Thomas Huber (Thomas_D_Huber@gmx.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FreeVCS code to JEDI VCS
2003/02/25  USchuster - fixed mantis bug #743
                        reason: - History compares ModuleName with the Path+Modulenname
                                  from the modules in the project
                                  (that must done this way because if you have 2 or more
                                   files with the same name in different directorys in
                                   one project than History shows the correct history,
                                   because it compares the Path+Modulename)
                                - the result of GET_LOG_ENTRIES doesn't contain the
                                  modulepath and thatswhy History can't find the module
                                  and shows allways the first module from the project
                        solution: - now ModuleID will be used
                                    (this has only one disadvantage:
                                     History doesn't show all files of the project
                                     in the combobox - if this is necessary than
                                     History has to be changed, because it doesn't
                                     insert all modules from the project into the
                                     combobox when ModuleID <> 0)
2003/03/05  THensle   - changes for "ConfigStorage" unit
2003/05/18  USchuster - fixed mantis bug #903
2003/07/29  THuber    - Added possibility to synchronize project from selected
                        module (belonging to this project)
2003/09/06  THuber    - Filtervalues are retrieved now on 'need', which means
                        that only if searching for specific project/module/user
                        which speeds up handling project history for those who
                        normaly only filter over dates/action over all projects
                        modules/users. (see also PHFilter.pas)
2003/10/30  THuber    - due to last change, purge needs a LoadFilterBuffer
2004/06/05  USchuster - changed to store filter per server (mantis #1781)
                      - minor style cleaning (casing and comments)
                      - use constant for messagebox caption
2004/09/17  FHasovic  - Added dxGetText support for localization                      
2004/10/20  USchuster - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/11/02  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
2006/12/10  USchuster - changes for menu bitmaps
2007/06/27  USchuster - changes to store "Current project" and "Current user" explicitly (Mantis #4166)
2007/06/30  USchuster - changes for large fonts (contraints size depend now on PixelsPerInch; analog to Mantis #3710)
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit ProjectHist;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  {$IFDEF DEBUG}
  JclDebug,
  {$ENDIF DEBUG}
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, ExtCtrls, ComCtrls, ImgList, Menus, EnhListView, RFormat,
  JVCSForms;

type
  TLVData = record
    ProjectID,
    ModuleID,
    LogID: Integer;
  end;

  TFilterDefinition = record
    FilterValue: ShortString;
    FilterProject,
    FilterModule,
    FilterUser: Integer;
    FilterStartDate,
    FilterEndDate: Double;
  end;

type
  TVCSProjectHistory = class(TJVCSForm)
    StateImageList: TImageList;
    PopupMenu1: TPopupMenu;
    Comment1: TMenuItem;
    Panel1: TPanel;
    btnClose: TButton;
    btnFilter: TButton;
    cbSaveFilter: TCheckBox;
    Action1: TMenuItem;
    N1: TMenuItem;
    btnPurge: TButton;
    Help: TSpeedButton;
    spBtnInfo: TSpeedButton;
    ModuleHistory1: TMenuItem;
    spBtnMHistory: TSpeedButton;
    elvHistory: TdfsEnhListView;
    btnReport: TButton;
    CheckInComment1: TMenuItem;
    N2: TMenuItem;
    ProjectTree1: TMenuItem;
    N3: TMenuItem;
    AllCheckInComments1: TMenuItem;
    cbComments: TCheckBox;
    N4: TMenuItem;
    Synchronice1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCloseClick(Sender: TObject);
    procedure btnFilterClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Comment1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Action1Click(Sender: TObject);
    procedure btnPurgeClick(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure elvHistoryChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure elvHistoryDrawHeader(Control: TWinControl;
      var ACanvas: TCanvas; Index: Integer; var ARect: TRect;
      Selected: Boolean; var DefaultDrawing: Boolean);
    procedure elvHistoryDrawItem(Control: TWinControl;
      var ACanvas: TCanvas; Index: Integer; ARect: TRect;
      State: TOwnerDrawState; var DefaultDrawing, FullRowSelect: Boolean);
    procedure elvHistoryDrawSubItem(Control: TWinControl;
      var ACanvas: TCanvas; Index, SubItem: Integer; ARect: TRect;
      State: TOwnerDrawState; var DefaultDrawing: Boolean);
    procedure spBtnMHistoryClick(Sender: TObject);
    procedure btnReportClick(Sender: TObject);
    procedure CheckInComment1Click(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure ProjectTree1Click(Sender: TObject);
    procedure AllCheckInComments1Click(Sender: TObject);
    procedure cbCommentsClick(Sender: TObject);
    procedure Synchronice1Click(Sender: TObject);
  private
    { Private declarations }
    CreateDT: TDateTime;
    ProjectOwner: string;
    FCreating: Boolean;
    FbProjectOpenState: Boolean; //thu 29.07.2003
    FnSelectedProjectID: Integer;  //thu 29.07.2003
    FsProjectName: string; //thu 29.07.2003
    procedure ShowLogEntries;
    function GetListViewString: string;
    procedure FreeLVData;
  public
    FilterBuffer: TStringList;
    FilterDefinition: TFilterDefinition;
    procedure LoadFilterBuffer;
  end;

const
  sitPJName = 0;
  sitModName = 1;
  sitUserName = 2;
  sitAction = 3;
  sitComment = 4;
  ProjectHistoryCurrentSelection = -1;

var
  VCSProjectHistory: TVCSProjectHistory;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSBase, VCSProcBase, ListView, PHFilter, DBModule, DeletePH, ModuleInfo,
  History, SimpleReport, ProjectTree, TZHandling, ConfigStorage, Syncronice,
  JVCSGUIClientResources, JVCSGUIClientImages;

var
  PLVData: ^TLVData;

{$R *.dfm}

function GetFilterStorageKey: string;
begin
  Result := sBaseRegistryKey + '\Filter' + '\' + sArchiveSource;
end;

procedure TVCSProjectHistory.FormCreate(Sender: TObject);
begin
  try
    Constraints.MinHeight := MulDiv(270, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(560, PixelsPerInch, 96);
    FCreating := True;
    //thu 29.07.2003 - push actual project state
    FbProjectOpenState := bProjectOpen;
    FnSelectedProjectID := ServerProjectID;
    FsProjectName := sProjectName;
    //thu 29.07.2003 ^^^

    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    cbComments.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbWindows, 'ProjectHistory_ShowComment', False);
    cbSaveFilter.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbWindows, 'ProjectHistory_SaveFilter', False);

    with FilterDefinition do
    begin
      if cbSaveFilter.Checked then
      begin
        FilterValue :=
          jvcsReadString(GetFilterStorageKey, 'ProjectHistory_Value', 'a;r;i;o;c;s;m;b;t;p;u;g;v;x;n;');
        FilterProject :=
          jvcsReadInteger(GetFilterStorageKey, 'ProjectHistory_Project', ProjectHistoryCurrentSelection);
        FilterModule :=
          jvcsReadInteger(GetFilterStorageKey, 'ProjectHistory_Module', 0);
        FilterUser :=
          jvcsReadInteger(GetFilterStorageKey, 'ProjectHistory_User', ProjectHistoryCurrentSelection);
        FilterStartDate :=
          jvcsReadFloat(GetFilterStorageKey, 'ProjectHistory_StartDate', Now - 30);
        FilterEndDate :=
          jvcsReadFloat(GetFilterStorageKey, 'ProjectHistory_EndDate', Now);
      end else
      begin
        FilterValue := 'a;r;i;o;c;s;m;b;t;p;u;g;v;x;n;';
        FilterProject := ProjectHistoryCurrentSelection;
        FilterModule := 0;
        FilterUser := ProjectHistoryCurrentSelection;
        FilterStartDate := Now - 30;
        FilterEndDate := Now;
      end;
    end;

    with elvHistory do
    begin
      Columns[0].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjectHistory_Col1.0', 80);
      Columns[1].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjectHistory_Col1.1', 100);
      Columns[2].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjectHistory_Col1.2', 100);
      Columns[3].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjectHistory_Col1.3', 100);
      Columns[4].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjectHistory_Col1.4', 200);
      Columns[5].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjectHistory_Col1.5', 200);
    end;

    FilterBuffer := TStringList.Create;
    CreateDT := 0;
    ProjectOwner := '';

    Screen.Cursors[cPopUpMCursor] := LoadCursor(hInstance, PChar('CURSORRM'));
    elvHistory.Cursor := cPopUpMCursor;

    VCSListView := nil;
    if ShowMenuBitmaps then
      PopupMenu1.Images := GetToolImageList;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectHistory.FormActivate(Sender: TObject);
begin
  Application.ProcessMessages;
  if not FCreating then
    Exit;
  jvcsLoadFormPosSize(Self);

  //thu 06.09.2003
  // Improve performance if have no project/user/module filter condition
  // for large log-table (see also PHFilter)
  if (FilterDefinition.FilterProject = 2) or
     (FilterDefinition.FilterModule = 2) or
     (FilterDefinition.FilterUser = 2) then
  begin
    LoadFilterBuffer;
  end;
  ShowLogEntries;
  FCreating := False;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectHistory.btnFilterClick(Sender: TObject);
begin
  if VCSListView <> nil then 
    VCSListView.Hide;
  ShowLogEntries;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectHistory.ShowLogEntries;
var
  NeedRefresh: Boolean;
  LVItem: TListItem;
  LStartDate, LEndDate: TDateTime;
  RequestFilterProject, RequestFilterUser: Integer;
begin
  NeedRefresh := False;
  VCSPHistoryFilter := TVCSPHistoryFilter.Create(Application);
  try
    VCSPHistoryFilter.Top := Top + 60;
    VCSPHistoryFilter.Left := Left + 60;
    if VCSPHistoryFilter.ShowModal = mrOk then 
      NeedRefresh := True;
  finally
    VCSPHistoryFilter.Free;
  end;
  if NeedRefresh then 
  begin
    elvHistory.BeginUpdate;
    try
      FreeLVData;
      elvHistory.Items.Clear;
      LVItem := elvHistory.Items.Add;
      LVItem.Caption := '';
      LVItem.SubItems.Add('');
      LVItem.SubItems.Add('');
      LVItem.SubItems.Add('');
      LVItem.SubItems.Add(JVCSRES_Server_request58_Log_entries46_Please_wait464646);
      LVItem.ImageIndex := -1;
    finally
      elvHistory.EndUpdate;
    end;
    Application.ProcessMessages;

    LStartDate := Trunc(FilterDefinition.FilterStartDate);
    if LStartDate <> 0 then
      LStartDate := LocalDT2GMTDT(LStartDate);
    LEndDate   := Trunc(FilterDefinition.FilterEndDate);
    if LEndDate <> 0 then
      LEndDate := LocalDT2GMTDT(LEndDate + 1);

    RequestFilterProject := FilterDefinition.FilterProject;
    if RequestFilterProject = ProjectHistoryCurrentSelection then
      RequestFilterProject := ServerProjectID;
    RequestFilterUser := FilterDefinition.FilterUser;
    if RequestFilterUser = ProjectHistoryCurrentSelection then
      RequestFilterUser := ServerUserID;
    with DataModule1 do
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_LOG_ENTRIES';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [RequestFilterProject]);
      AppSrvClient1.Request.WriteFields(False, [FilterDefinition.FilterModule]);
      AppSrvClient1.Request.WriteFields(False, [RequestFilterUser]);
      AppSrvClient1.Request.WriteFields(False, [LStartDate]);
      AppSrvClient1.Request.WriteFields(False, [LEndDate]);
      AppSrvClient1.Request.WriteFields(False, [FilterDefinition.FilterValue]);
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

      Screen.Cursor := crHourGlass;
      elvHistory.BeginUpdate;
      try
        elvHistory.Items.Clear;
        AppSrvClient1.Answer.First;
        while not AppSrvClient1.Answer.Eof do 
        begin
          LVItem := elvHistory.Items.Add;
          try
            LVItem.Caption := DateTimeToStr(GMTStr2LocalDateTime(AppSrvClient1.Answer.Fields[3]));
          except
            LVItem.Caption := JVCSRES_UC_unknown;
          end;
          case AppSrvClient1.Answer.Fields[4][1] of
            'a': 
              LVItem.ImageIndex := 0;
            'r':
              LVItem.ImageIndex := 1;
            'o':
              LVItem.ImageIndex := 2;
            'i':
              LVItem.ImageIndex := 3;
            else 
              LVItem.ImageIndex := -1;
          end;
          LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[0]);
          LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[1]);
          LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[2]);
          LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[5]);
          // comment - blank for now
          LVItem.SubItems.Add('');
          // Data
          New(PLVData);
          PLVData^.ProjectID := _StrToInt(AppSrvClient1.Answer.Fields[6]);
          PLVData^.ModuleID := _StrToInt(AppSrvClient1.Answer.Fields[7]);
          PLVData^.LogID := _StrToInt(AppSrvClient1.Answer.Fields[8]);
          LVItem.Data := PLVData;

          AppSrvClient1.Answer.Next;
        end;  // while not AppSrvClient1.Answer.EoF do begin
      finally
        elvHistory.EndUpdate;
      end;
      elvHistory.Resort;
      Screen.Cursor := crDefault;
    end; // with DataModule1 do begin
    if (elvHistory.Items.Count > 0) and cbComments.Checked then
      AllCheckInComments1Click(Self);
  end; // if NeedRefresh then begin
  Caption := Format(JVCSRES_Project_History_45_37d_hits, [elvHistory.Items.Count]);
  if (elvHistory.Items.Count = 0) then 
  begin
    MessageBox(Handle, PChar(JVCSRES_There_were_no_records_located_that_match_your_search_criteria46 + #13#10 +
      JVCSRES_Re45check_your_criterias_and_retry46), cMsgBoxCaption, MB_OK or
      MB_ICONINFORMATION);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectHistory.btnPurgeClick(Sender: TObject);
begin
  if VCSListView <> nil then
    VCSListView.Hide;
  LoadFilterBuffer; //thu 30.10.2003 
  VCSDeletePH := TVCSDeletePH.Create(Application);
  try
    VCSDeletePH.Top := Top + 60;
    VCSDeletePH.Left := Left + 60;
    VCSDeletePH.ShowModal;
  finally
    VCSDeletePH.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectHistory.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  FreeLVData;

  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'ProjectHistory_ShowComment',
    cbComments.Checked);
  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'ProjectHistory_SaveFilter',
    cbSaveFilter.Checked);

  if cbSaveFilter.Checked then
    with FilterDefinition do
    begin
      jvcsWriteString(GetFilterStorageKey, 'ProjectHistory_Value',
        FilterValue);
      jvcsWriteInteger(GetFilterStorageKey, 'ProjectHistory_Project',
        FilterProject);
      jvcsWriteInteger(GetFilterStorageKey, 'ProjectHistory_Module',
        FilterModule);
      jvcsWriteInteger(GetFilterStorageKey, 'ProjectHistory_User',
        FilterUser);
      jvcsWriteFloat(GetFilterStorageKey, 'ProjectHistory_StartDate',
        FilterStartDate);
      jvcsWriteFloat(GetFilterStorageKey, 'ProjectHistory_EndDate',
        FilterEndDate);
    end;

  with elvHistory do
  begin
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjectHistory_Col1.0',
      Columns[0].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjectHistory_Col1.1',
      Columns[1].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjectHistory_Col1.2',
      Columns[2].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjectHistory_Col1.3',
      Columns[3].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjectHistory_Col1.4',
      Columns[4].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjectHistory_Col1.5',
      Columns[5].Width);
  end;

  jvcsSaveFormPosSize(Self);

  //thu 29.07.2003 - pop last project state
  bProjectOpen := FbProjectOpenState;
  ServerProjectID := FnSelectedProjectID;
  sProjectName := FsProjectName;
  //thu 29.07.2003 ^^^
end;

//------------------------------------------------------------------------------

procedure TVCSProjectHistory.btnCloseClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------

function TVCSProjectHistory.GetListViewString: string;
var 
  CurrentText: string;
  I, J: Integer;
  oaColumnsWidth: array of Integer;
const 
  cr = Chr(13) + Chr(10);

  function SizeString(const Column: Integer; const CellString: string;
    const Fillchr: Char): string;
  var 
    K: Integer;
  begin
    Result := CellString;
    if Length(Result) > 0 then
      for K := 1 to Length(Result) do 
      begin
        if (Result[K] = Chr(10)) or (Result[K] = Chr(13)) then 
        begin
          System.Delete(Result, K, 1);
          System.Insert('\', Result, K);
        end;
      end;
    while Length(Result) < oaColumnsWidth[Column] do
      Result := Result + Fillchr;
  end;
begin
  Result := '';
  Screen.Cursor := crHourGlass;
  try
    with elvHistory do 
    begin
      if Items.Count = 0 then 
      begin
        MessageBox(WindowHandle, PChar(JVCSRES_Requested_result_set_is_blank46_Nothing_to_do46),
          cMsgBoxCaption, MB_OK);
        Exit;
      end;
      // Textlänge in der Spalte?
      SetLength(oaColumnsWidth, Columns.Count);
      for I := 0 to Columns.Count - 1 do 
      begin
        oaColumnsWidth[I] := Length(Columns[I].Caption);
        for J := 0 to Items.Count - 1 do 
        begin
          if I = 0 then 
            CurrentText := Items[J].Caption
          else 
            CurrentText := Items[J].SubItems[I - 1];
          if Length(CurrentText) > oaColumnsWidth[I] then
            oaColumnsWidth[I] := Length(CurrentText);
        end; // for J := 0 to Items.Count - 1 do begin
      end; // for I := 0 to Columns.Count - 1 do begin

      Result := Caption + cr;
      CurrentText := '';
      while Length(CurrentText) < Length(Caption) do
        CurrentText := CurrentText + '=';
      Result := Result + CurrentText + cr + cr;

      for J := 0 to Columns.Count - 1 do 
      begin
        Result := Result + SizeString(J, Columns[J].Caption, ' ');
        if J < (Columns.Count - 1) then 
          Result := Result + ' | ';
      end;
      Result := Result + cr;
      for J := 0 to Columns.Count - 1 do 
      begin
        Result := Result + SizeString(J, '-', '-');
        if J < (Columns.Count - 1) then 
          Result := Result + ' | ';
      end;
      Result := Result + cr;

      for I := 0 to Items.Count - 1 do 
      begin
        for J := 0 to Columns.Count - 1 do
        begin
          if J = 0 then
            CurrentText := Items[I].Caption
          else
            CurrentText := Items[I].SubItems[J - 1];
          Result := Result + SizeString(J, CurrentText, ' ');
          if J < (Columns.Count - 1) then 
            Result := Result + ' | ';
        end; // for J := 0 to Columns.Count - 1 do begin
        Result := Result + cr;
      end; // for I := 0 to Items.Count - 1 do begin
    end; // with elv do begin

    Result := Result + cr + JVCSRES_Source58_ + sArchiveSource + cr +
      JVCSRES_JEDI_VCS_ + sProductVer + cProductInf + DateTimeToStr(Now) + cr;
  finally
    Screen.Cursor := crDefault;
    SetLength(oaColumnsWidth, 0);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectHistory.btnReportClick(Sender: TObject);
var
  ResultString: string;
begin
  if VCSListView <> nil then
  begin
    VCSListView.Free;
    VCSListView := nil;
  end;
  ResultString := GetListViewString;
  if ResultString = '' then 
    Exit;

  VCSSimpleReport := TVCSSimpleReport.Create(Application);
  try
    VCSSimpleReport.RepID := 10;  
    VCSSimpleReport.Left := Left + 60;
    VCSSimpleReport.Top := Top + 60;
    VCSSimpleReport.FullReportString := ResultString;
    VCSSimpleReport.SavePath := ExtractFileDir(sProjectName);
    VCSSimpleReport.SaveFileName := 'ProjectHistory.txt';
    VCSSimpleReport.LineCount := elvHistory.Items.Count + 8;
    VCSSimpleReport.ShowModal;
  finally
    VCSSimpleReport.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectHistory.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Project_history);
  if Key = VK_ESCAPE then
  begin
    btnClose.Click;
    Key := 0;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectHistory.Comment1Click(Sender: TObject);
var 
  OldServerProjectID: Integer;
begin
  if elvHistory.Selected = nil then
    Exit;
  Application.ProcessMessages;
  if VCSListView <> nil then 
    VCSListView.Hide;
  OldServerProjectID := ServerProjectID;
  try
    ServerProjectID := TLVData(elvHistory.Selected.Data^).ProjectID;
    VCSInfo := TVCSInfo.Create(Application);
    try
      VCSInfo.ModuleName := '';
      VCSInfo.ModuleID := TLVData(elvHistory.Selected.Data^).ModuleID;
      VCSInfo.ShowModal;
    finally
      VCSInfo.Free;
    end;
  finally
    ServerProjectID := OldServerProjectID;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectHistory.spBtnMHistoryClick(Sender: TObject);
var
  OldServerProjectID: Integer;
begin
  if elvHistory.Selected = nil then
    Exit;
  Application.ProcessMessages;
  if VCSListView <> nil then
    VCSListView.Hide;
  OldServerProjectID := ServerProjectID;
  try
    ServerProjectID := TLVData(elvHistory.Selected.Data^).ProjectID;
    VCSHistory := TVCSHistory.Create(Application);
    try
      VCSHistory.ModuleName := elvHistory.Selected.SubItems[sitModName];
      VCSHistory.ModuleID   := TLVData(elvHistory.Selected.Data^).ModuleID;
      VCSHistory.ShowModal;
    finally
      VCSHistory.Free;
    end;
  finally
    ServerProjectID := OldServerProjectID;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectHistory.FormDestroy(Sender: TObject);
begin
  FilterBuffer.Free;
  if VCSListView <> nil then 
    VCSListView.Free;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectHistory.Action1Click(Sender: TObject);
var 
  ResultStr: string;
begin
  if elvHistory.Selected = nil then 
    Exit;
  Application.ProcessMessages;  
  ResultStr := elvHistory.Selected.SubItems[sitAction] + ';';
  if VCSListView = nil then 
  begin
    VCSListView := TVCSListView.Create(Application);
    VCSListView.Caption := JVCSRES_Action;
    VCSListView.Left := (Left + Width) - (VCSListView.Width + 40);
    VCSListView.Top := Top + 60;
    VCSListView.EnableWordWrap(True);
    VCSListView.SetUpListView(ResultStr);
    VCSListView.FormStyle := fsStayOnTop;
    VCSListView.Show;
    {VCSListView.Visible := FALSE;
    ShowWindow(VCSListView.Handle, SW_SHOWNA);}
  end // if VCSListView = nil then begin
  else 
  begin
    VCSListView.Caption := JVCSRES_Action;
    VCSListView.SetUpListView(ResultStr);
    VCSListView.Show;
    {VCSListView.Visible := FALSE;
    ShowWindow(VCSListView.Handle, SW_SHOWNA);}
  end;
  Windows.SetFocus(WindowHandle);
end;

//------------------------------------------------------------------------------

procedure TVCSProjectHistory.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSProjectHistory.elvHistoryChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
begin
  spBtnInfo.Enabled := (elvHistory.Selected <> nil);
  Comment1.Enabled := (elvHistory.Selected <> nil);
  ModuleHistory1.Enabled := (elvHistory.Selected <> nil);
  spBtnMHistory.Enabled := (elvHistory.Selected <> nil);
end;

//------------------------------------------------------------------------------

procedure TVCSProjectHistory.elvHistoryDrawHeader(Control: TWinControl;
  var ACanvas: TCanvas; Index: Integer; var ARect: TRect;
  Selected: Boolean; var DefaultDrawing: Boolean);
begin
  DefaultDrawing := True;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectHistory.elvHistoryDrawItem(Control: TWinControl;
  var ACanvas: TCanvas; Index: Integer; ARect: TRect;
  State: TOwnerDrawState; var DefaultDrawing, FullRowSelect: Boolean);
begin
  DefaultDrawing := True;
  FullRowSelect := True;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectHistory.elvHistoryDrawSubItem(Control: TWinControl;
  var ACanvas: TCanvas; Index, SubItem: Integer; ARect: TRect;
  State: TOwnerDrawState; var DefaultDrawing: Boolean);
begin
  DefaultDrawing := True;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectHistory.PopupMenu1Popup(Sender: TObject);
begin
  CheckInComment1.Enabled := (elvHistory.Selected <> nil) and
    (elvHistory.Selected.ImageIndex = 3);
end;

//------------------------------------------------------------------------------

procedure TVCSProjectHistory.CheckInComment1Click(Sender: TObject);
var 
  ResultStr: string;
begin
  if elvHistory.Selected = nil then 
    Exit;
  Application.ProcessMessages;
  ResultStr := '';
  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_LOG_COMMENT';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [TLVData(elvHistory.Selected.Data^).LogID]);

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
    if not AppSrvClient1.Answer.Eof then
      ResultStr := AppSrvClient1.Answer.Fields[0];
  end; // with DataModule1 do begin

  if (ResultStr = '') or (ResultStr = 'blank') then //resstr -????
  begin
    MessageBox(Handle, PChar(JVCSRES_There_were_no_records_located_that_match_your_search_criteria46 + #13#10 +
      JVCSRES_Re45check_your_criterias_and_retry46), cMsgBoxCaption, MB_OK or
      MB_ICONINFORMATION);
    Exit;
  end;

  ResultStr := ResultStr + ';';
  if VCSListView = nil then 
  begin
    VCSListView := TVCSListView.Create(Application);
    VCSListView.Caption := Format(JVCSRES_Check_In_Comment_45_37s,
      [elvHistory.Selected.SubItems[sitModName]]);
    VCSListView.Left := (Left + Width) - (VCSListView.Width + 40);
    VCSListView.Top := Top + 60;
    VCSListView.EnableWordWrap(True);
    VCSListView.SetUpListView(ResultStr);
    VCSListView.FormStyle := fsStayOnTop;
    VCSListView.Show;
    {VCSListView.Visible := FALSE;
    ShowWindow(VCSListView.Handle, SW_SHOWNA);}
  end // if VCSListView = nil then begin
  else 
  begin
    VCSListView.Caption := Format(JVCSRES_Check_In_Comment_45_37s,
      [elvHistory.Selected.SubItems[sitModName]]);
    VCSListView.SetUpListView(ResultStr);
    VCSListView.Show;
    {VCSListView.Visible := FALSE;
    ShowWindow(VCSListView.Handle, SW_SHOWNA);}
  end;
  Windows.SetFocus(WindowHandle);
end;

//------------------------------------------------------------------------------

procedure TVCSProjectHistory.ProjectTree1Click(Sender: TObject);
begin
  if elvHistory.Selected = nil then 
    Exit;
  if VCSListView <> nil then 
    VCSListView.Hide;
  Application.ProcessMessages;
  VCSProjectTree := TVCSProjectTree.Create(Application);
  try
    VCSProjectTree.SelectedProjectID := TLVData(elvHistory.Selected.Data^).ProjectID;
    VCSProjectTree.SelectedModuleID := TLVData(elvHistory.Selected.Data^).ModuleID;
    VCSProjectTree.ShowModal;
  finally
    VCSProjectTree.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectHistory.AllCheckInComments1Click(Sender: TObject);
var 
  I: Integer;
  ResultStr: string;
begin
  if (elvHistory.Items.Count > 100) then 
  begin
    if MessageBox(WindowHandle, PChar(Format(JVCSRES_You_have_37d_items_in_the_history_list46 + #13#10 +
      JVCSRES_Loading_all_Check_In_comments_may_take_several_time46 + #13#10 +
      JVCSRES_Continue_anyway63, [elvHistory.Items.Count])),
      cMsgBoxCaption, MB_YESNOCANCEL or MB_ICONQUESTION) <> idYes then 
    begin
      cbComments.Checked := False;
      Exit;
    end;
  end;
  cbComments.Checked := True;
  for I := 0 to elvHistory.Items.Count - 1 do
  begin
    if (elvHistory.Items[I].ImageIndex = 3) then 
    begin
      ResultStr := '';
      with DataModule1 do 
      begin
        AppSrvClient1.Request.Rewrite;
        AppSrvClient1.FunctionCode := 'GET_LOG_COMMENT';
        AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
        AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
        AppSrvClient1.Request.WriteFields(True, [TLVData(elvHistory.Items[I].Data^).LogID]);

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
        if not AppSrvClient1.Answer.Eof then
          ResultStr := AppSrvClient1.Answer.Fields[0];
      end; // with DataModule1 do begin
      if (ResultStr <> '') then
        elvHistory.Items[I].SubItems[sitComment] := ResultStr;
    end; // if (elvHistory.Items[I].ImageIndex = 3) then begin
  end; // for I := 0 to elvHistory.Items.Count - 1 do begin
end;

//------------------------------------------------------------------------------

procedure TVCSProjectHistory.FreeLVData;
var 
  I: Integer;
begin
  // Speicher freigeben
  for I := elvHistory.Items.Count - 1 downto 0 do
    Dispose(elvHistory.Items[I].Data);
end;

//------------------------------------------------------------------------------

procedure TVCSProjectHistory.cbCommentsClick(Sender: TObject);
begin
  if cbComments.Checked then
    AllCheckInComments1Click(Self);
end;

//==============================================================================
//THu 29.07.2003

// Synchronize Project from selected item
procedure TVCSProjectHistory.Synchronice1Click(Sender: TObject);
begin
  if Assigned(elvHistory.Selected) and Assigned(elvHistory.Selected.Data) then
  begin
    // Prepare for VCSSync
    bProjectOpen := True;
    ServerProjectID := TLVData(elvHistory.Selected.Data^).ProjectID;
    sProjectName := elvHistory.Selected.SubItems[0];

    VCSSync := TVCSSync.Create(Application);
    try
      VCSSync.AutoClose := True;
      VCSSync.ShowModal;
    finally
      VCSSync.Free;
    end;
  end;
end;

//==============================================================================
//THu 06.09.2003

// Synchronize Project from selected item
procedure TVCSProjectHistory.LoadFilterBuffer;
begin
  Caption := JVCSRES_Project_History_45_request_server_for_filter_items464646;
  try
    with DataModule1 do
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_LOG_FILTER';
      AppSrvClient1.Request.WriteRecord([TransactionNr,ServerUserID]);

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

      FilterBuffer.Clear;
      AppSrvClient1.Answer.First;
      while not AppSrvClient1.Answer.Eof do
      begin
        FilterBuffer.Add(AppSrvClient1.Answer.Fields[0] + '|' +
          AppSrvClient1.Answer.Fields[1] + '|' +
          AppSrvClient1.Answer.Fields[2]);
        AppSrvClient1.Answer.Next;
      end; // while not AppSrvClient1.Answer.Eof do begin
    end; // with DataModule1 do begin
  finally
    Caption := JVCSRES_Project_History;
  end;
end;

end.
