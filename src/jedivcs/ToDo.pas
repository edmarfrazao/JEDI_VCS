(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: Todo.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS: Thomas Huber (Thomas_D_Huber@gmx.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
Jun/04
- USc: GetFilterStorageKey is equal to ProjectHist.pas GetFilterStorageKey
       -> should be moved to a common unit
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FreeVCS code to JEDI VCS
2003/02/12  USchuster - the use of IDEReader depends on IDEDLL now
2003/03/06  THensle   - changes for "ConfigStorage" unit
2003/03/08  USchuster - exchanged THistoryList with TJVCSMruList (mantis #727)
2003/03/15  THuber    - DoneCheckbox-Filter was not working
2003/04/08  USchuster - changes for IDEInterface
2003/12/28  USchuster - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use constant)
2004/01/30  USchuster - changed ToDo template name and content from "fvcs..." to
                        "jvcs..." and changed it's comment type
                      - it still parses the old "fvcs" templates
                      - minor style cleaning
2004/06/12  USchuster - changed to store filter per server
                      - minor style cleaning
2004/09/17  FHasovic  - Added dxGetText support for localization                      
2004/10/09  USchuster - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/10/31  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC1 was released ^^^^^^^^^^^^^^^^^^^^^^^^^^^
2005/02/26  THuber    - use replace s A p pDirectory with ..JVCSIDESettings.IDEAppFileDir
                      - partly changed M e ssageBoxes from JVCSDialogs
                      - TDODEBUG directive removed use DEBUG instead 
2007/06/17  USchuster - fixed self handled shortcuts
2007/06/29  USchuster - changes for large fonts (contraints and default size depend now on PixelsPerInch; Mantis #3710)
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma
2012/07/08  AKroeber  - changed AnsiCrLf to sLineBreak (avoid using of JclAnsiString.pas - should work from Delphi 6 to XE2)

-----------------------------------------------------------------------------*)

unit ToDo;

{$I jedi.inc}
{$I compopt.inc}

{$IFDEF DELPHI6_UP}
  {$WARN UNIT_PLATFORM OFF}
{$ENDIF DELPHI6_UP}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Menus, ImgList, ComCtrls, ExtCtrls, Buttons, RFormat, JVCSMruList,
  EnhListView, JVCSForms;

type
  TLVData = record
    ID,
    State: Integer;
    Changed: Boolean;
    Target,
    Done: Double;
  end;

  TFilterDefinition = record
    FilterValue: ShortString;
    FilterProject,
    FilterUser,
    FilterPriority: Integer;
    FilterDoneItems: Boolean;
    FilterDate: Double;
  end;

type
  TVCSToDo = class(TJVCSForm)
    Panel1: TPanel;
    btnDone: TButton;
    ImageList: TImageList;
    PopupMenu1: TPopupMenu;
    Edit1: TMenuItem;
    Clear1: TMenuItem;
    Add1: TMenuItem;
    StateImageList: TImageList;
    Clearalldoneitems1: TMenuItem;
    N2: TMenuItem;
    spBtnAdd: TSpeedButton;
    spBtnEdit: TSpeedButton;
    SpeedButton5: TSpeedButton;
    spBtnClear: TSpeedButton;
    N3: TMenuItem;
    Done1: TMenuItem;
    pmiScanproject: TMenuItem;
    N1: TMenuItem;
    SpeedButton1: TSpeedButton;
    spBtnInsCT: TSpeedButton;
    UserBuffer: TMWBuffer;
    ProjectBuffer: TMWBuffer;
    btnCancel: TButton;
    spBtnPLow: TSpeedButton;
    btnFilter: TButton;
    spBtnPHigh: TSpeedButton;
    cbSaveFilter: TCheckBox;
    Lowerpriority1: TMenuItem;
    Higherpriority1: TMenuItem;
    N4: TMenuItem;
    MarkasnotDone1: TMenuItem;
    Refresh1: TMenuItem;
    Help: TSpeedButton;
    CopytoClipboard1: TMenuItem;
    elvToDo: TdfsEnhListView;
    spBtnImportD5: TSpeedButton;
    OpenDialog1: TOpenDialog;
    procedure btnDoneClick(Sender: TObject);
    procedure Edit1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Add1Click(Sender: TObject);
    procedure Clear1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Clearalldoneitems1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure HelpTopic1Click(Sender: TObject);
    procedure Done1Click(Sender: TObject);
    procedure pmiScanprojectClick(Sender: TObject);
    procedure spBtnInsCTClick(Sender: TObject);
    procedure spBtnPLowClick(Sender: TObject);
    procedure spBtnPHighClick(Sender: TObject);
    procedure elvToDoDrawHeader(Control: TWinControl; var ACanvas: TCanvas;
      Index: Integer; var ARect: TRect; Selected: Boolean;
      var DefaultDrawing: Boolean);
    procedure elvToDoDrawItem(Control: TWinControl; var ACanvas: TCanvas;
      Index: Integer; ARect: TRect; State: TOwnerDrawState;
      var DefaultDrawing, FullRowSelect: Boolean);
    procedure elvToDoDrawSubItem(Control: TWinControl;
      var ACanvas: TCanvas; Index, SubItem: Integer; ARect: TRect;
      State: TOwnerDrawState; var DefaultDrawing: Boolean);
    procedure btnCancelClick(Sender: TObject);
    procedure elvToDoClick(Sender: TObject);
    procedure elvToDoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure MarkasnotDone1Click(Sender: TObject);
    procedure btnFilterClick(Sender: TObject);
    procedure Refresh1Click(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure CopytoClipboard1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure spBtnImportD5Click(Sender: TObject);
  private
    { Private declarations }
    FCreating: Boolean;
    SourceTDItems: TStringList;
    ProjectUnits: TStringList;
    CategoryList: TJVCSMruList;
    procedure SetCaption;
    procedure FillListView(const GetFilter: Boolean);
    procedure AddLVItem(const LVItem: TListItem; Priority, Date, Project,
      Responsible, Category, Description: string;
      Target, Done: Double;
      const ID: Integer; const Changed: Boolean);
    procedure RefreshLVItem(LVItem: TListItem);
    procedure ShowSelectedLVItem;
    {$IFDEF IDEDLL}
    procedure GetProjectUnits;
    procedure ParseUnit(FileName: string);
    {$ENDIF IDEDLL}
    function CheckforChanges: Boolean;
    function SaveChanges: Boolean;
    procedure FreeLVData;
  public
    { Public declarations }
    FilterBuffer: TStringList;
    FilterDefinition: TFilterDefinition;
    procedure RestrictSize(var Msg: TMessage); message WM_GETMINMAXINFO;
  end;

var
  VCSToDo: TVCSToDo;

implementation

uses
    VCSBase
  {$IFDEF IDEDLL}
  , JVCSIDEInterface
  , mwPasLex
  , mwPasLexTypes
  {$ENDIF IDEDLL}
  {$IFDEF LANGUAGE}
  , JvGnugettext
  {$ENDIF LANGUAGE}
  , ToDoEdit
  , VCSProcBase
  , FileCtrl
  , Progress
  , HandleBlob
  , DBModule
  , JclStrings
  , ToDoFilter
  , TZHandling
  , SimpleReport
  , SelectList
  , ConfigStorage
  , JVCSGUIClientResources
  , JVCSDialogs
  {$IFDEF DEBUG}
  , JVCSDebug
  {$ENDIF DEBUG}
  ;

var
  PLVData: ^TLVData;

{$R *.dfm}

//------------------------------------------------------------------------------

procedure TVCSToDo.SetCaption;
begin
  Caption := Format(JVCSRES_VCS_ToDo_45_37d_items, [elvToDo.Items.Count]);
end;

//------------------------------------------------------------------------------

function GetFilterStorageKey: string;
begin
  Result := sBaseRegistryKey + '\Filter' + '\' + sArchiveSource;
end;

procedure TVCSToDo.FormCreate(Sender: TObject);
var
  DlgTop, DlgLeft, DlgWidth, DlgHeight: Integer;
begin
  try
    VCSProgress := nil;
    FCreating := True;
    {$IFNDEF IDEDLL}
    SpeedButton1.Enabled := False;
    spBtnInsCT.Enabled := False;
    pmiScanproject.Enabled := False;
    pmiScanproject.Visible := False;
    N1.Visible := False;
    {$ENDIF ~IDEDLL}

    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    if not jvcsReadWindowPosAndSize(sBaseRegistryKey + crbWindows, 'ToDo',
      DlgTop, DlgLeft, DlgWidth, DlgHeight) then
    begin
      DlgTop := (Screen.Height - Height) div 2;
      DlgLeft := (Screen.Width - Width) div 2;
      DlgWidth := MulDiv(630, PixelsPerInch, 96);
      DlgHeight := MulDiv(300, PixelsPerInch, 96);
    end;
    Top := DlgTop;
    Left := DlgLeft;
    Width := DlgWidth;
    Height := DlgHeight;

    with elvToDo do
    begin
      Columns[0].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ToDo_Col1.0', 50);
      Columns[1].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ToDo_Col1.1', 75);
      Columns[2].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ToDo_Col1.2', 70);
      Columns[3].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ToDo_Col1.3', 70);
      Columns[4].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ToDo_Col1.4', 70);
      Columns[5].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ToDo_Col1.5', 300);
      Columns[6].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ToDo_Col1.6', 75);
      Columns[7].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ToDo_Col1.7', 75);
    end;


    cbSaveFilter.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbWindows, 'ToDo_SaveFilter', False);
    with FilterDefinition do
    begin
      if cbSaveFilter.Checked then
      begin
        FilterValue :=
          jvcsReadString(GetFilterStorageKey, 'ToDo_Value', '');
        FilterProject :=
          jvcsReadInteger(GetFilterStorageKey, 'ToDo_Project', 0);
        FilterUser :=
          jvcsReadInteger(GetFilterStorageKey, 'ToDo_User', 0);
        FilterDate :=
          jvcsReadFloat(GetFilterStorageKey, 'ToDo_Date', 0);
        FilterPriority :=
          jvcsReadInteger(GetFilterStorageKey, 'ToDo_Priority', 0);
        FilterDoneItems :=
          jvcsReadBool(GetFilterStorageKey, 'ToDo_Done', False);
      end else
      begin
        FilterValue := '';
        FilterProject := 0;
        FilterUser := 0;
        FilterDate := 0;
        FilterPriority := 0;
        FilterDoneItems := False;
      end;
    end;

    {$IFDEF CUSTOMDRIVE}
    sDriveSubst := RegReadString(HKCU, sBaseRegistryKey + crbProjects +
      ExtractFileName(sProjectName), 'LocalDrive', '');
    if (sDriveSubst = '') then
      sDriveSubst := RegReadString(HKCU, sBaseRegistryKey + crbOptions,
        'LocalDrive', '');
    {$ENDIF CUSTOMDRIVE}

    ProjectUnits := TStringList.Create;
    ProjectUnits.Sorted := True;
    ProjectUnits.Duplicates := dupIgnore;
    SourceTDItems := TStringList.Create;
    SourceTDItems.Sorted := True;
    SourceTDItems.Duplicates := dupIgnore;
    FilterBuffer := TStringList.Create;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSToDo.AddLVItem(const LVItem: TListItem; Priority, Date, Project,
  Responsible, Category, Description: string;
  Target, Done: Double;
  const ID: Integer; const Changed: Boolean);
var 
  NewLVItem: TListItem;
  NewItem: Boolean;
  I: Integer;
begin
  if Assigned(CategoryList) and (Category <> '') then
    CategoryList.AddString(Category);
  if Done < 1 then 
    Done := 0;
  if Target < 1 then 
    Target := 0;
  NewItem := (LVItem = nil);
  if NewItem then
    NewLVItem := elvToDo.Items.Add
  else
    NewLVItem := LVItem;
  if Priority = '1' then 
    NewLVItem.ImageIndex := 0;
  if Priority = '2' then 
    NewLVItem.ImageIndex := 1;
  if Priority = '3' then 
    NewLVItem.ImageIndex := 2;
  if _StrToInt(Priority) > 3 then 
    NewLVItem.ImageIndex := 3;
  if (Done > 0) and (Done <= Now) then 
  begin
    Priority := Priority + ' ';
    NewLVItem.StateIndex := 1;
  end 
  else
  begin
    if (Target > 0) and (Target <= Now) then 
      NewLVItem.StateIndex := 2
    else 
      NewLVItem.StateIndex := 0;
  end;
  NewLVItem.Caption := Priority;
  if NewItem then 
  begin
    NewLVItem.SubItems.Add(Date);
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

    New(PLVData);
    PLVData^.ID := ID;
    PLVData^.State := 0;
    PLVData^.Changed := Changed;
    PLVData^.Target := Int(Target);
    PLVData^.Done := Int(Done);
    NewLVItem.Data := PLVData;

    for I := 0 to elvToDo.Items.Count - 1 do
      elvToDo.Items[I].Selected := False;
    NewLVItem.Selected := True;
  end // if NewItem then begin
  else 
  begin
    NewLVItem.SubItems[0] := Date;
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

    TLVData(NewLVItem.Data^).ID := ID;
    TLVData(NewLVItem.Data^).State := 0;
    TLVData(NewLVItem.Data^).Changed := Changed;
    TLVData(NewLVItem.Data^).Target := Int(Target);
    TLVData(NewLVItem.Data^).Done := Int(Done);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSToDo.RefreshLVItem(LVItem: TListItem);
var 
  Priority: string;
  Target, Done: Double;
begin
  if LVItem = nil then 
    Exit;
  Priority := LVItem.Caption[1];
  if Priority = '1' then 
    LVItem.ImageIndex := 0;
  if Priority = '2' then 
    LVItem.ImageIndex := 1;
  if Priority = '3' then 
    LVItem.ImageIndex := 2;
  if _StrToInt(Priority) > 3 then 
    LVItem.ImageIndex := 3;
  Done := TLVData(LVItem.Data^).Done;
  Target := TLVData(LVItem.Data^).Target;
  if (Done > 0) and (Done <= Now) then 
  begin
    Priority := Priority + ' ';
    LVItem.Caption := Priority;
    LVItem.StateIndex := 1;
  end 
  else 
  begin
    if (Target > 0) and (Target <= Now) then
      LVItem.StateIndex := 2
    else 
    begin
      LVItem.Caption := Priority;
      LVItem.StateIndex := 0;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSToDo.FormActivate(Sender: TObject);
begin
  if Assigned(VCSProgress) then
    SetForeGroundWindow(VCSProgress.Handle);
  Application.ProcessMessages;
  if not FCreating then 
    Exit;
  FCreating := False;

  Caption := JVCSRES_VCS_ToDo_45_request_server_for_filter_items464646;
  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_TODO_FILTER';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
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
    end; // while not AppSrvClient1.Answer.EoF do begin
  end; // with DataModule1 do begin

  UserBuffer.Rewrite;
  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_USERS';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
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
    while not AppSrvClient1.Answer.Eof do
    begin
      UserBuffer.WriteFields(True, [AppSrvClient1.Answer.Fields[0]]);
      UserBuffer.WriteFields(False, [AppSrvClient1.Answer.Fields[1]]);
      UserBuffer.WriteFields(False, [AppSrvClient1.Answer.Fields[2]]);
      UserBuffer.WriteFields(False, [AppSrvClient1.Answer.Fields[3]]);
      AppSrvClient1.Answer.Next;
    end;
  end; // with DataModule1 do begin
  ProjectBuffer.Rewrite;
  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_PROJECT_LIST';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(False, ['']);
    AppSrvClient1.Request.WriteFields(True, [False]); // incl. details
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
    while not AppSrvClient1.Answer.Eof do 
    begin
      if AppSrvClient1.Answer.Fields[2] <> '1' then 
      begin
        ProjectBuffer.WriteFields(True, [AppSrvClient1.Answer.Fields[0]]);
        ProjectBuffer.WriteFields(False, [AppSrvClient1.Answer.Fields[1]]);
      end; // if AppSrvClient1.Answer.Fields[2] <> '1' then begin
      AppSrvClient1.Answer.Next;
    end;
  end; // with DataModule1 do begin

  Caption := JVCSRES_VCS_ToDo;

  FillListView(True);

  if (elvToDo.Items.Count = 0) then 
  begin
    InfoMessageBox( JVCSRES_There_were_no_records_located_that_match_your_search_criteria46 + sLineBreak +
                    JVCSRES_Re45check_your_criterias_and_retry46
                  );
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSToDo.FillListView(const GetFilter: Boolean);
var
  NeedRefresh: Boolean;
begin
  if GetFilter then 
  begin
    NeedRefresh := False;
    VCSToDoFilter := TVCSToDoFilter.Create(Application);
    try
      VCSToDoFilter.Top := Top + 60;
      VCSToDoFilter.Left := Left + 60;
      if VCSToDoFilter.ShowModal = mrOk then 
        NeedRefresh := True;
    finally
      VCSToDoFilter.Free;
    end;
  end // if GetFilter then begin
  else 
    NeedRefresh := True;
  if NeedRefresh then 
  begin
    elvToDo.BeginUpdate;
    try
      FreeLVData;
      elvToDo.Items.Clear;
      with DataModule1 do 
      begin
        AppSrvClient1.Request.Rewrite;
        AppSrvClient1.FunctionCode := 'GET_TODO_ENTRIES';
        AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
        AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
        AppSrvClient1.Request.WriteFields(True, [FilterDefinition.FilterUser]);
        AppSrvClient1.Request.WriteFields(False, [FilterDefinition.FilterProject]);
        AppSrvClient1.Request.WriteFields(False, [FilterDefinition.FilterValue]);
        AppSrvClient1.Request.WriteFields(False, [FilterDefinition.FilterPriority]);
        AppSrvClient1.Request.WriteFields(False, [FilterDefinition.FilterDoneItems]);
        AppSrvClient1.Request.WriteFields(False, [FilterDefinition.FilterDate]);
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

        CategoryList := TJVCSMruList.Create;
        CategoryList.MaxSize := 50;
        CategoryList.LoadFromStorage(sBaseRegistryKey + crbMRU + '14');
        AppSrvClient1.Answer.First;
        while not AppSrvClient1.Answer.Eof do 
        begin
          AddLVItem(nil,
            AppSrvClient1.Answer.Fields[4],
            DateToStr(GMTStr2LocalDateTime(AppSrvClient1.Answer.Fields[1])),
            AppSrvClient1.Answer.Fields[3],
            AppSrvClient1.Answer.Fields[2],
            AppSrvClient1.Answer.Fields[6],
            AppSrvClient1.Answer.Fields[9],
            GMTStr2LocalDateTime(AppSrvClient1.Answer.Fields[7]),
            GMTStr2LocalDateTime(AppSrvClient1.Answer.Fields[8]),
            _StrToInt(AppSrvClient1.Answer.Fields[0]),
            False);
          AppSrvClient1.Answer.Next;
        end;
        CategoryList.SaveToStorage(sBaseRegistryKey + crbMRU + '14');
        FreeAndNil(CategoryList);
      end; // with DataModule1 do begin
    finally
      elvToDo.EndUpdate;
    end;
    if elvToDo.Items.Count > 0 then 
    begin
      elvToDo.Resort;
      elvToDo.Selected := elvToDo.Items[0];
      elvToDoClick(Self);
    end; // if elvToDo.Items.Count > 0 then begin
    SetCaption;
  end; // if NeedRefresh then begin
end;

//------------------------------------------------------------------------------

procedure TVCSToDo.Add1Click(Sender: TObject);
begin
  VCSToDoEdit := TVCSToDoEdit.Create(Application);
  try
    VCSToDoEdit.New := True;
    UserBuffer.First;
    while (not UserBuffer.Eof) do 
    begin
      if (UserBuffer.Fields[3] = '0') then
        VCSToDoEdit.UserList.Add(UserBuffer.Fields[1]);
      UserBuffer.Next;
    end;
    ProjectBuffer.First;
    while not ProjectBuffer.Eof do 
    begin
      VCSToDoEdit.ProjectList.Add(ProjectBuffer.Fields[1]);
      ProjectBuffer.Next;
    end;
    VCSToDoEdit.ShowModal;
    if VCSToDoEdit.Priority <> 0 then 
    begin
      AddLVItem(nil,
        IntToStr(VCSToDoEdit.Priority),
        DateToStr(Now),
        VCSToDoEdit.Project,
        VCSToDoEdit.Responsible,
        VCSToDoEdit.Category,
        VCSToDoEdit.Description,
        VCSToDoEdit.Target,
        VCSToDoEdit.Done,
        0,
        True);
      elvToDo.Resort;
      ShowSelectedLVItem;
      elvToDoClick(Self);
    end; // if VCSToDoEdit.Priority <> 0 then begin
  finally
    VCSToDoEdit.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSToDo.Edit1Click(Sender: TObject);
var 
  ToDoID: Integer;
begin
  if elvToDo.Selected = nil then
    Exit;
  ToDoID := TLVData(elvToDo.Selected.Data^).ID;
  VCSToDoEdit := TVCSToDoEdit.Create(Application);
  try
    VCSToDoEdit.New := False;
    UserBuffer.First;
    while not UserBuffer.Eof do 
    begin
      if (UserBuffer.Fields[3] = '0') then
        VCSToDoEdit.UserList.Add(UserBuffer.Fields[1]);
      UserBuffer.Next;
    end;
    ProjectBuffer.First;
    while not ProjectBuffer.Eof do 
    begin
      VCSToDoEdit.ProjectList.Add(ProjectBuffer.Fields[1]);
      ProjectBuffer.Next;
    end;
    VCSToDoEdit.Priority := StrToInt(elvToDo.Selected.Caption[1]);
    VCSToDoEdit.Responsible := elvToDo.Selected.SubItems[2];
    VCSToDoEdit.Project := elvToDo.Selected.SubItems[1];
    VCSToDoEdit.Created := elvToDo.Selected.SubItems[0];
    VCSToDoEdit.Target := TLVData(elvToDo.Selected.Data^).Target;
    VCSToDoEdit.Done := TLVData(elvToDo.Selected.Data^).Done;
    VCSToDoEdit.Category := elvToDo.Selected.SubItems[3];
    VCSToDoEdit.Description := elvToDo.Selected.SubItems[4];
    VCSToDoEdit.ShowModal;
    if VCSToDoEdit.Priority <> 0 then
    begin
      AddLVItem(elvToDo.Selected,
        IntToStr(VCSToDoEdit.Priority),
        DateToStr(Now),
        VCSToDoEdit.Project,
        VCSToDoEdit.Responsible,
        VCSToDoEdit.Category,
        VCSToDoEdit.Description,
        VCSToDoEdit.Target,
        VCSToDoEdit.Done,
        ToDoID,
        True);
      TLVData(elvToDo.Selected.Data^).ID := ToDoID;
      elvToDo.Resort;
      ShowSelectedLVItem;
      elvToDoClick(Self);
    end; // if VCSToDoEdit.Priority <> 0 then begin
  finally
    VCSToDoEdit.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSToDo.Clear1Click(Sender: TObject);
var 
  I: Integer;
begin
  if elvToDo.Selected = nil then 
    Exit;
  if MessageBox(WindowHandle, PChar(JVCSRES_Are_you_sure_you_want_to_delete_the_selected_items63 + sLineBreak +
    JVCSRES_Warning33_This_process_is_not_reversible46),
    cMsgBoxCaption, MB_YESNOCANCEL or MB_ICONWARNING) <> idYes then 
    Exit;
  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'REMOVE_TODO_ENTRIES';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    for I := 0 to elvToDo.Items.Count - 1 do
      if elvToDo.Items[I].Selected and
        (TLVData(elvToDo.Items[I].Data^).ID <> 0) then
        AppSrvClient1.Request.WriteFields(True,
          [TLVData(elvToDo.Items[I].Data^).ID]);
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
  end; // with DataModule1 do begin

  I := 0;
  with elvToDo do 
  begin
    while I <= Items.Count - 1 do 
    begin
      if Items[I].Selected then 
      begin
        Dispose(Items[I].Data);
        Items[I].Delete;
      end
      else 
        Inc(I);
    end; // while I <= lvToDo.Items.Count - 1 do begin
  end; // with lvToDo do begin
  elvToDo.Resort;
  SetCaption;
end;

//------------------------------------------------------------------------------

procedure TVCSToDo.Clearalldoneitems1Click(Sender: TObject);
var 
  I: Integer;
begin
  if MessageBox(WindowHandle, PChar(JVCSRES_Are_you_sure_you_want_to_delete_all_done_items63 + sLineBreak +
    JVCSRES_Warning33_This_process_is_not_reversible46),
    cMsgBoxCaption, MB_YESNOCANCEL or MB_ICONWARNING) <> idYes then 
    Exit;
  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'REMOVE_TODO_ENTRIES';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    for I := 0 to elvToDo.Items.Count - 1 do
      if (elvToDo.Items[I].StateIndex = 1) and
        (TLVData(elvToDo.Items[I].Data^).ID <> 0) then
        AppSrvClient1.Request.WriteFields(True,
          [TLVData(elvToDo.Items[I].Data^).ID]);
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
  end; // with DataModule1 do begin

  I := 0;
  with elvToDo do 
  begin
    while I <= Items.Count - 1 do 
    begin
      if Items[I].StateIndex = 1 then
      begin
        Dispose(Items[I].Data);
        Items[I].Delete;
      end 
      else 
        Inc(I);
    end; // while I <= lvToDo.Items.Count - 1 do begin
  end; // with lvToDo do begin
  elvToDo.Resort;
  SetCaption;
end;

//------------------------------------------------------------------------------

function TVCSToDo.SaveChanges: Boolean;
var 
  I: Integer;
  DT: Double;

  function GetUserID(User: string): string;
  begin
    Result := '0';
    UserBuffer.First;
    while not UserBuffer.Eof do 
    begin
      if User = UserBuffer.Fields[1] then 
      begin
        Result := UserBuffer.Fields[0];
        Break;
      end;
      UserBuffer.Next;
    end;
  end;

  function GetProjectID(Project: string): string;
  begin
    Result := '0';
    ProjectBuffer.First;
    while not ProjectBuffer.Eof do 
    begin
      if Project = ProjectBuffer.Fields[1] then 
      begin
        Result := ProjectBuffer.Fields[0];
        Break;
      end;
      ProjectBuffer.Next;
    end;
  end;
begin
  Result := False;
  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'ADD_UPDATE_TODO_ENTRIES';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    for I := 0 to elvToDo.Items.Count - 1 do 
    begin
      if TLVData(elvToDo.Items[I].Data^).Changed then 
      begin
        AppSrvClient1.Request.WriteFields(True, [TLVData(elvToDo.Items[I].Data^).ID]);

        AppSrvClient1.Request.WriteFields(False,
          [GetUserID(elvToDo.Items[I].SubItems[2])]);
        AppSrvClient1.Request.WriteFields(False,
          [GetProjectID(elvToDo.Items[I].SubItems[1])]);
        AppSrvClient1.Request.WriteFields(False,
          [GetUserID(elvToDo.Items[I].SubItems[2])]);
        AppSrvClient1.Request.WriteFields(False, [elvToDo.Items[I].Caption[1]]);
        AppSrvClient1.Request.WriteFields(False, [TLVData(elvToDo.Items[I].Data^).State]);
        AppSrvClient1.Request.WriteFields(False, [elvToDo.Items[I].SubItems[3]]);
        AppSrvClient1.Request.WriteFields(False, [elvToDo.Items[I].SubItems[4]]);
        DT := TLVData(elvToDo.Items[I].Data^).Target;
        if DT > 0 then
          DT := LocalDT2GMTDT(DT);
        AppSrvClient1.Request.WriteFields(False, [DT]);
        DT := TLVData(elvToDo.Items[I].Data^).Done;
        if DT > 0 then
          DT := LocalDT2GMTDT(DT);
        AppSrvClient1.Request.WriteFields(False, [DT]);
      end; // if elvToDo.Items[I].SubItems[9] = '1' then begin
    end; // for I := 0 to elvToDo.Items.Count - 1 do begin
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
  end; // with DataModule1 do begin

  for I := 0 to elvToDo.Items.Count - 1 do
    TLVData(elvToDo.Items[I].Data^).Changed := False;

  Result := True;
end;

//------------------------------------------------------------------------------

procedure TVCSToDo.btnDoneClick(Sender: TObject);
var 
  Changed: Boolean;
  I: Integer;
begin
  Changed := False;
  for I := 0 to elvToDo.Items.Count - 1 do 
  begin
    if TLVData(elvToDo.Items[I].Data^).Changed then
    begin
      Changed := True;
      Break;
    end; // if elvToDo.Items[I].SubItems[9] = '1' then begin
  end; // for I := 0 to elvToDo.Items.Count - 1 do begin
  if Changed then 
    SaveChanges;
  Close;
end;

//------------------------------------------------------------------------------

function TVCSToDo.CheckforChanges: Boolean;
var
  Changed: Boolean;
  I, DlgResult: Integer;
begin
  Result := False;
  Changed := False;
  for I := 0 to elvToDo.Items.Count - 1 do 
  begin
    if TLVData(elvToDo.Items[I].Data^).Changed then 
    begin
      Changed := True;
      Break;
    end; // if elvToDo.Items[I].SubItems[9] = '1' then begin
  end; // for I := 0 to elvToDo.Items.Count - 1 do begin
  if Changed then 
  begin
    DlgResult := MessageBox(WindowHandle, PChar(JVCSRES_You_have_made_changes_that_have_not_been_applied46 + sLineBreak +
      JVCSRES_Do_you_want_to_apply_these_now63), cMsgBoxCaption,
      MB_YESNOCANCEL or MB_ICONQUESTION);
    case DlgResult of
      id_Yes:
        SaveChanges;
      id_Cancel: 
        Exit;
    end;
  end; // if Changed then begin
  Result := True;
end;

//------------------------------------------------------------------------------

procedure TVCSToDo.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if not CheckforChanges then 
    CanClose := False
  else 
    CanClose := True;
end;

//------------------------------------------------------------------------------

procedure TVCSToDo.btnCancelClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSToDo.RestrictSize(var Msg: TMessage);
var
  P: PMinMaxInfo;
begin
  // The lParam contains a pointer on a structure of type TMinMaxInfo
  P := PMinMaxInfo(Msg.lParam);
  // This represents the size of the Window when Maximized
  P.ptMaxSize.x := trResDesktop.Right;
  P.ptMaxSize.y := trResDesktop.Bottom;
  // This represents the position of the Window when Maximized
  P.ptMaxPosition.x := 0;
  P.ptMaxPosition.y := 0;
  // This represents the minimum size of the Window
  P.ptMinTrackSize.x := MulDiv(605, PixelsPerInch, 96);
  P.ptMinTrackSize.y := MulDiv(190, PixelsPerInch, 96);
end;

//------------------------------------------------------------------------------

procedure TVCSToDo.FormDestroy(Sender: TObject);
begin
  SourceTDItems.Free;
  ProjectUnits.Free;
  FilterBuffer.Free;
end;

//------------------------------------------------------------------------------

procedure TVCSToDo.FreeLVData;
var
  I: Integer;
begin
  // Speicher freigeben
  for I := elvToDo.Items.Count - 1 downto 0 do
    Dispose(elvToDo.Items[I].Data);
end;

//------------------------------------------------------------------------------

procedure TVCSToDo.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FreeLVData;

  jvcsWriteWindowPosAndSize(sBaseRegistryKey + crbWindows, 'ToDo',
    Top, Left, Width, Height);

  with elvToDo do
  begin
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ToDo_Col1.0',
      Columns[0].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ToDo_Col1.1',
      Columns[1].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ToDo_Col1.2',
      Columns[2].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ToDo_Col1.3',
      Columns[3].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ToDo_Col1.4',
      Columns[4].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ToDo_Col1.5',
      Columns[5].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ToDo_Col1.6',
      Columns[6].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ToDo_Col1.7',
      Columns[7].Width);
  end;

  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'ToDo_SaveFilter',
    cbSaveFilter.Checked);

  if cbSaveFilter.Checked then
    with FilterDefinition do
    begin
      jvcsWriteString(GetFilterStorageKey, 'ToDo_Value', FilterValue);
      jvcsWriteInteger(GetFilterStorageKey, 'ToDo_Project', FilterProject);
      jvcsWriteInteger(GetFilterStorageKey, 'ToDo_User', FilterUser);
      jvcsWriteFloat(GetFilterStorageKey, 'ToDo_Date', FilterDate);
      jvcsWriteInteger(GetFilterStorageKey, 'ToDo_Priority', FilterPriority);
      jvcsWriteBool(GetFilterStorageKey, 'ToDo_Done', FilterDoneItems);
    end;
end;

//------------------------------------------------------------------------------

procedure TVCSToDo.elvToDoClick(Sender: TObject);
begin
  Edit1.Enabled := elvToDo.SelCount = 1;
  spBtnEdit.Enabled := Edit1.Enabled;
  spBtnPLow.Enabled := Edit1.Enabled;
  spBtnPHigh.Enabled := Edit1.Enabled;

  Clear1.Enabled := (elvToDo.Selected <> nil);
  spBtnClear.Enabled := Clear1.Enabled;
  Done1.Enabled := Clear1.Enabled;

  if (elvToDo.Selected <> nil) then
    Higherpriority1.Enabled := elvToDo.Selected.StateIndex <> 1
  else 
    Higherpriority1.Enabled := False;
  Lowerpriority1.Enabled := Higherpriority1.Enabled;
  Done1.Enabled := Higherpriority1.Enabled;
  MarkasnotDone1.Enabled := not Done1.Enabled;
end;

//------------------------------------------------------------------------------

procedure TVCSToDo.elvToDoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  elvToDoClick(Self);
end;

//------------------------------------------------------------------------------

procedure TVCSToDo.spBtnPLowClick(Sender: TObject);
var 
  CurrentPriority: Integer;
begin
  if elvToDo.SelCount <> 1 then 
    Exit;
  if Length(elvToDo.Selected.Caption) > 1 then 
    Exit;
  CurrentPriority := _StrToInt(elvToDo.Selected.Caption);
  if CurrentPriority < 9 then 
  begin
    Inc(CurrentPriority);
    elvToDo.Selected.Caption := IntToStr(CurrentPriority);
    TLVData(elvToDo.Selected.Data^).Changed := True;
    RefreshLVItem(elvToDo.Selected);
    elvToDo.Resort;
    ShowSelectedLVItem;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSToDo.spBtnPHighClick(Sender: TObject);
var 
  CurrentPriority: Integer;
begin
  if elvToDo.SelCount <> 1 then 
    Exit;
  if Length(elvToDo.Selected.Caption) > 1 then 
    Exit;
  CurrentPriority := _StrToInt(elvToDo.Selected.Caption);
  if CurrentPriority > 1 then 
  begin
    Dec(CurrentPriority);
    TLVData(elvToDo.Selected.Data^).Changed := True;
    elvToDo.Selected.Caption := IntToStr(CurrentPriority);
    RefreshLVItem(elvToDo.Selected);
    elvToDo.Resort;
    ShowSelectedLVItem;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSToDo.HelpTopic1Click(Sender: TObject);
begin
  PerformHelpCommand(Application, IDH_ToDo_list);
end;

//------------------------------------------------------------------------------

procedure TVCSToDo.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    btnDone.Click;
    Key := 0;
  end;
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_ToDo_list);
  if Key = VK_F2 then
    Edit1Click(Self);
  if Key = VK_F3 then
    Done1Click(Self);
  if Key = VK_INSERT then 
    Add1Click(Self);
  if spBtnAdd.Enabled and (Shift * [ssShift, ssAlt, ssCtrl] = [ssCtrl]) and (Chr(Key) in ['A', 'a']) then
    if (not CtrlSCDisabled(WindowHandle)) then
      Add1Click(Self);
  if spBtnClear.Enabled and (Shift * [ssShift, ssAlt, ssCtrl] = [ssCtrl]) and (Chr(Key) in ['R', 'r']) then
    if (not CtrlSCDisabled(WindowHandle)) then 
      Clear1Click(Self);
end;

//------------------------------------------------------------------------------

procedure TVCSToDo.MarkasnotDone1Click(Sender: TObject);
var 
  I: Integer;
begin
  if elvToDo.Selected = nil then 
    Exit;
  with elvToDo do 
  begin
    for I := 0 to Items.Count - 1 do 
    begin
      if Items[I].Selected then 
      begin
        Items[I].SubItems[6] := '-';
        TLVData(Items[I].Data^).Changed := True;
        TLVData(Items[I].Data^).Done := 0;
        RefreshLVItem(Items[I]);
      end; // if Items[I].Selected then begin
    end; // for I := 0 to Items.Count - 1 do begin
  end; // with lvToDo do begin
  elvToDo.Resort;
end;

//------------------------------------------------------------------------------

procedure TVCSToDo.Done1Click(Sender: TObject);
var 
  I: Integer;
begin
  if elvToDo.Selected = nil then 
    Exit;
  with elvToDo do 
  begin
    for I := 0 to Items.Count - 1 do
    begin
      if Items[I].Selected then 
      begin
        Items[I].SubItems[6] := DateToStr(Now);
        TLVData(Items[I].Data^).Changed := True;
        TLVData(Items[I].Data^).Done := Int(Now);
        RefreshLVItem(Items[I]);
      end; // if Items[I].Selected then begin
    end; // for I := 0 to Items.Count - 1 do begin
  end; // with lvToDo do begin
  elvToDo.Resort;
end;

//------------------------------------------------------------------------------

procedure TVCSToDo.pmiScanprojectClick(Sender: TObject);
{$IFDEF IDEDLL}
var
  I, J, Index, IndLen: Integer;
  CurrItem, CurrLine, CurrFile, CurrPriority, CurrResp, CurrTDText: string;
  ItemIsNew: Boolean;
{$ENDIF IDEDLL}

  function CutBlanks(S: string): string;
  begin
    while (S <> '') and (S[1] = ' ') do 
      Delete(S, 1, 1);
    while (S <> '') and (S[Length(S)] = ' ') do 
      Delete(S, Length(S), 1);
    Result := S;
  end;

  function RemoveCRLF(S: string): string;
  var 
    I: Integer;
  begin
    for I := 1 to Length(S) do 
    begin
      if (S[I] = Chr(13)) or (S[I] = Chr(10)) then 
      begin
        Delete(S, I, 1);
        System.Insert(' ', S, I);
      end;
    end; // for J := 1 to Length(CurrPriority) do begin
    Result := S;
  end;
  
begin
  {$IFDEF IDEDLL}
  if bIsCppBuilder then 
  begin
    InfoMessageBox( JVCSRES_This_feature_is_currently_not_supported_by_the_C4343_Builder_version46_Sorry46 );
    Exit;
  end;  
  SourceTDItems.Clear;
  Screen.Cursor := crHourGlass;
  VCSProgress := TVCSProgress.Create(Self);
  try
    VCSProgress.SetText(JVCSRES_Parsing_the_source_files464646);
    VCSProgress.SetPBMax(IDEInterface.GetUnitCount + ProjectUnits.Count);
    VCSProgress.SetPBPos(0);
    VCSProgress.Left := Left + 40;
    VCSProgress.Top := Top + 60;
    VCSProgress.Show;
    Application.ProcessMessages;

    GetProjectUnits;

    for I := 0 to ProjectUnits.Count - 1 do
    begin
      if FileExists(ProjectUnits.Strings[I]) then 
      begin
        {$IFDEF DEBUG}
        TraceAlways('TODO Parse Unit: ' + ProjectUnits.Strings[I]);
        {$ENDIF DEBUG}
        if IsIDEUnit(ProjectUnits.Strings[I]) or
          IsIDEProject(ProjectUnits.Strings[I], sProjectName) or
          (ExtractFileExt(AnsiLowerCase(ProjectUnits.Strings[I])) = '.inc') then
          ParseUnit(ProjectUnits.Strings[I]);
      end;
      VCSProgress.SetPBPos(I);
    end;
    for I := 0 to IDEInterface.GetUnitCount - 1 do
    begin
      if FileExists(IDEInterface.GetUnitName(I)) then 
      begin
        {$IFDEF DEBUG}
        TraceAlways('TODO Parse Unit: ' + IDEInterface.GetUnitName(I));
        {$ENDIF DEBUG}
        if IsIDEUnit(IDEInterface.GetUnitName(I)) or
          IsIDEProject(IDEInterface.GetUnitName(I), sProjectName) then
          ParseUnit(IDEInterface.GetUnitName(I));
      end;
      VCSProgress.SetPBPos(ProjectUnits.Count + I - 1);
    end;
    VCSProgress.SetPBPos(0);
    VCSProgress.SetText(JVCSRES_Building_Listview464646);
    VCSProgress.SetPBMax(SourceTDItems.Count);
    Application.ProcessMessages;

    for I := 0 to SourceTDItems.Count - 1 do 
    begin
      CurrItem := SourceTDItems.Strings[I];
      try
        if (((Pos('(* #fvcstodostart', AnsiLowerCase(CurrItem)) <> 0) and
          (Pos('#fvcstodoend *)', AnsiLowerCase(CurrItem)) <> 0)) or
          ((Pos('{ #jvcstodostart', AnsiLowerCase(CurrItem)) <> 0) and
          (Pos('#jvcstodoend }', AnsiLowerCase(CurrItem)) <> 0))) and
          (Pos('$priority =', AnsiLowerCase(CurrItem)) <> 0) and
          (Pos('$responsible =', AnsiLowerCase(CurrItem)) <> 0) and
          (Pos('$item =', AnsiLowerCase(CurrItem)) <> 0) then
        begin
          CurrFile := Copy(CurrItem, 1, Pos('|', CurrItem) - 1);
          CurrFile := CutBlanks(CurrFile);
          {$IFDEF DEBUG}
          TraceAlways('########## TODO Parse Result Start ########## ');
          TraceAlways('SourceTDItems.Strings[I]: ' + SourceTDItems.Strings[I]);
          TraceAlways('CurrFile: ' + CurrFile);
          {$ENDIF DEBUG}
          Delete(CurrItem, 1, Pos('|', CurrItem));
          CurrLine := Copy(CurrItem, 1, Pos('|', CurrItem) - 1);
          CurrLine := CutBlanks(CurrLine);
          {$IFDEF DEBUG}
          TraceAlways('CurrLine: ' + CurrLine);
          {$ENDIF DEBUG}
          Delete(CurrItem, 1, Pos('|', CurrItem));
          Index := Pos('$priority =', CurrItem);
          IndLen := Pos('$responsible =', CurrItem);
          IndLen := IndLen - Index -11;
          if Index <> 0 then 
            CurrPriority := Copy(CurrItem, Index + 11, IndLen)
          else 
            CurrPriority := '3';
          CurrPriority := RemoveCRLF(CurrPriority);
          CurrPriority := CutBlanks(CurrPriority);
          if (CurrPriority <> '1') and (CurrPriority <> '2') and
            (CurrPriority <> '3') then 
            CurrPriority := '3';
          {$IFDEF DEBUG}
          TraceAlways('CurrPriority: ' + CurrPriority);
          {$ENDIF DEBUG}
          Index := Pos('$responsible =', CurrItem);
          IndLen := Pos('$item =', CurrItem);
          IndLen := IndLen - Index -14;
          if Index <> 0 then
            CurrResp := Copy(CurrItem, Index + 14, IndLen)
          else 
            CurrResp := '';
          CurrResp := RemoveCRLF(CurrResp);
          CurrResp := CutBlanks(CurrResp);
          {$IFDEF DEBUG}
          TraceAlways('CurrResp: ' + CurrResp);
          {$ENDIF DEBUG}
          Index := Pos('$item =', CurrItem);
          IndLen := Pos('#jvcstodoend }', CurrItem);        
          if IndLen = 0 then
            IndLen := Pos('#fvcstodoend *)', CurrItem);
          IndLen := IndLen - Index -7;
          if Index <> 0 then 
            CurrTDText := Copy(CurrItem, Index + 7, IndLen)
          else 
            CurrTDText := '';
          CurrTDText := CutBlanks(CurrTDText);
          CurrTDText := RemoveCRLF(CurrTDText);
          while Pos('  ', CurrTDText) > 0 do
            Delete(CurrTDText, Pos('  ', CurrTDText), 1);
          {$IFDEF DEBUG}
          TraceAlways('CurrTDText: ' + CurrTDText);
          {$ENDIF DEBUG}
          ItemIsNew := True;
          for J := 0 to elvToDo.Items.Count - 1 do
            if Pos(CurrTDText, elvToDo.Items[J].SubItems[4]) <> 0 then 
              ItemIsNew := False;
          if ItemIsNew then 
          begin
            CurrTDText := '(' + ExtractFileName(CurrFile) + ' - ' + CurrLine +
              ') ' + CurrTDText;
            CurrItem := CurrPriority[1] + '|' + DateTimeToStr(Now) + '|' +
              CurrTDText + '|0|1|' + CurrResp;
            CurrItem := RemoveCRLF(CurrItem);
            while Pos('  ', CurrItem) > 0 do
              Delete(CurrItem, Pos('  ', CurrItem), 1);
            {$IFDEF DEBUG}
            TraceAlways('ToDoItem: ' + CurrItem);
            {$ENDIF DEBUG}
            AddLVItem(nil, CurrPriority[1], DateToStr(Now),
              AnsiLowerCase(ExtractFileName(sProjectName)),
              sCurrentUser,
              JVCSRES_Source_scan, CurrTDText, 0, 0, 0, True);
          end; // if ItemIsNew then begin
          {$IFDEF DEBUG}
          TraceAlways('########## TODO Parse Result End ########## ');
          {$ENDIF DEBUG}
        end; // if (Pos('(* #fvcstodostart', AnsiLowerCase(CurrType)) <> 0) and...
      except
      end;
      VCSProgress.SetPBPos(I);
    end; // for I := 0 to SourceTDItems.Count - 1 do begin
  finally
    FreeAndNil(VCSProgress);
    SetCaption;
    Screen.Cursor := crDefault;
  end;
  {$ENDIF IDEDLL}
end;

//------------------------------------------------------------------------------

{$IFDEF IDEDLL}
procedure TVCSToDo.ParseUnit(FileName: string);
var
  MS: TMemoryStream;
  PasParser: TmwPasLex;
  CurrToken: string;
  CurrLine: Integer;
begin
  {$IFDEF DEBUG}
  if AnsiLowerCase(ExtractFileName(FileName)) = 'todo.pas' then
    Exit;
  {$ENDIF DEBUG}
  MS := TMemoryStream.Create;
  try
    IDESource2Stream(FileName, MS);
    PasParser := TmwPasLex.Create;
    try
      PasParser.Origin := MS.Memory;
      //hu01.12.2002       while PasParser.TokenID <> tkNull do
      while PasParser.TokenID <> ptNull do
      begin
        if Pos('(* #fvcstodostart', PasParser.Token) <> 0 then
        begin
          CurrToken := PasParser.Token;
          CurrLine := PasParser.LineNumber + 1;
          while (Pos('#fvcstodoend *)', PasParser.Token) = 0) and
            (Length(CurrToken) < 1000) do
          begin
            PasParser.Next;
            CurrToken := CurrToken + ' ' + PasParser.Token;
          end; // while Pos('#fvcstodoend *)', PasParser.Token) = 0 do
          SourceTDItems.Add(FileName + '|' + IntToStr(CurrLine) + '|' + CurrToken);
          {$IFDEF DEBUG}
          TraceAlways('TODO Parse Line Number: ' + IntToStr(CurrLine));
          TraceAlways('TODO Parse: ' + CurrToken);
          {$ENDIF DEBUG}
        end // if Pos('#fvcstodo', PasParser.Token) <> 0 then
        else
        if Pos('{ #jvcstodostart', PasParser.Token) <> 0 then
        begin
          CurrToken := PasParser.Token;
          CurrLine := PasParser.LineNumber + 1;
          while (Pos('#jvcstodoend }', PasParser.Token) = 0) and
            (Length(CurrToken) < 1000) do
          begin
            PasParser.Next;
            CurrToken := CurrToken + ' ' + PasParser.Token;
          end; // while Pos('#jvcstodoend }', PasParser.Token) = 0 do
          SourceTDItems.Add(FileName + '|' + IntToStr(CurrLine) + '|' + CurrToken);
          {$IFDEF DEBUG}
          TraceAlways('TODO Parse Line Number: ' + IntToStr(CurrLine));
          TraceAlways('TODO Parse: ' + CurrToken);
          {$ENDIF DEBUG}
        end; // if Pos('#jvcstodo', PasParser.Token) <> 0 then
        PasParser.Next;
      end; // while PasParser.TokenID <> tkNull do
    finally
      PasParser.Free;
    end;
  finally
    MS.Free;
  end;
end;
{$ENDIF IDEDLL}

//------------------------------------------------------------------------------

{$IFDEF IDEDLL}
procedure TVCSToDo.GetProjectUnits;
var
  I: Integer;
  CurrentFile: string;
  UserModules: TStringList;
begin
  UserModules := TStringList.Create;
  ProjectUnits.Clear;

  for I := 0 to IDEInterface.GetUnitCount - 1 do
  begin
    CurrentFile := IDEInterface.GetUnitName(I);
    if (CurrentFile <> '') and
      (AnsiLowerCase(ExtractFileExt(CurrentFile)) = ('.' + sIDEUnit)) then
      ProjectUnits.Add(AnsiLowerCase(CurrentFile));
  end; // for I := 0 to IDEInterface.GetUnitCount - 1 do begin

  //--User module list--
  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_PROJECT_MODULE_LIST';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [ServerProjectID]);
    SetupTimeoutCounter;
    AppSrvClient1.Send;

    while WaitForAppSrvClient do 
      Application.ProcessMessages;
    if (AppSrvClientErr = -99) then 
    begin
      ShowServerTimeOut(WindowHandle);
      Exit;
    end;    
    if (AppSrvClientErr <> 0) or (AppSrvClient1.AnswerStatus <> '200') then 
    begin
      ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
        AppSrvClient1.AnswerStatus);
      Exit;
    end;

    AppSrvClient1.Answer.First;
    while not AppSrvClient1.Answer.Eof do 
    begin
      {$IFDEF CUSTOMDRIVE}
      UserModules.Add(ChangeDriveName(AppSrvClient1.Answer.Fields[2], sDriveSubst) +
        AppSrvClient1.Answer.Fields[1]);
      {$ELSE}
      UserModules.Add(AppSrvClient1.Answer.Fields[2] +
        AppSrvClient1.Answer.Fields[1]);
      {$ENDIF CUSTOMDRIVE}


      AppSrvClient1.Answer.Next;
    end; // while not AppSrvClient1.Answer.Eof do begin
  end; // with DataModule1 do begin

  for I := 0 to UserModules.Count - 1 do
    if AnsiLowerCase(ExtractFileExt(UserModules.Strings[I])) = ('.' + sIDEUnit) then
      ProjectUnits.Add(AnsiLowerCase(UserModules.Strings[I]));

  UserModules.Free;
end;
{$ENDIF IDEDLL}

//------------------------------------------------------------------------------

procedure TVCSToDo.spBtnInsCTClick(Sender: TObject);
{$IFDEF IDEDLL}
var
  CTFileName: string;
  CTContent: TStringList;
  I: Integer;
  Success, AlreadyAss: Boolean;
{$ENDIF IDEDLL}
begin
  {$IFDEF IDEDLL}
  if bIsCppBuilder then 
  begin
    InfoMessageBox( JVCSRES_This_feature_is_currently_not_supported_by_the_C4343_Builder_version46_Sorry46 );
    Exit;
  end;  
  Success := True;
  CTContent := TStringList.Create;
  try
    if DirectoryExists(IDEInterface.JVCSIDESettings.IDEAppFileDir) then
    begin
      CTFileName := IDEInterface.JVCSIDESettings.IDEAppFileDir + 'delphi32.dci';
      if FileExists(CTFileName) then
      begin
        try
          CTContent.LoadFromFile(CTFileName);
        except
          on E: Exception do 
          begin
            CTContent.Clear;
            BeepIfSet;
            ErrorMessageBox ( Format( JVCSRES_Reading_file_6037s62 + sLineBreak +
                                      JVCSRES_raised_exception58 + sLineBreak + '%s.'
                                    , [CTFileName, E.Message]
                                    )
                            );
            Success := False;
            Exit;
          end;
        end; // try except

        AlreadyAss := False;
        for I := 0 to CTContent.Count - 1 do
          if Pos('[jvcstodo | JEDI VCS Todo Code Comment]',
            CTContent.Strings[I]) <> 0 then
            AlreadyAss := True;

        if not AlreadyAss then
        begin
          CTContent.Add('');
          CTContent.Add('[jvcstodo | JEDI VCS Todo Code Comment]');
          CTContent.Add('{ #jvcstodostart');
          CTContent.Add('  $priority = |');
          CTContent.Add('  $responsible =');
          CTContent.Add('  $item =');
          CTContent.Add('  #jvcstodoend }');
          try
            CTContent.SaveToFile(CTFileName);
          except
            BeepIfSet;
            ErrorMessageBox ( Format( JVCSRES_JEDI_VCS_cannot_save_the_file + sLineBreak + '<%s>.' + sLineBreak +
                                      JVCSRES_Be_sure_that_the_file_is_not_opened_by_another_application44 + sLineBreak +
                                      JVCSRES_that_there_is_enough_free_space_on_the_disk + sLineBreak +
                                      JVCSRES_and_that_you_have_the_required_access_rights46
                                    , [CTFileName]
                                    )
                            );
            Success := False;
          end;
        end; // if not AlreadyAss then begin
      end // if FileExists(PRLFileName) then begin
      else
      begin
        BeepIfSet;
        WarnMessageBox( Format( JVCSRES_JEDI_VCS_cannot_open_the_file46_40Invalid_path_or_access_denied4158 + sLineBreak + '<%s>.' + sLineBreak +
                                JVCSRES_Make_sure_that_the_file_exists44_that_it_is_not_opened_by_another_application + sLineBreak +
                                JVCSRES_and_that_you_have_the_required_access_rights46
                              , [CTFileName]
                              )
                      );
        Success := False;
      end;
    end // if DirectoryExists(sAppDirectory) then begin
    else 
    begin
      BeepIfSet;
      WarnMessageBox( JVCSRES_JEDI_VCS_cannot_detect_the_name_of_Delphi39s_base_installation_folder46 + sLineBreak +
                      JVCSRES_This_function_is_only_supported_for_known_IDE_products46
                    );
      Success := False;
    end;
  finally
    CTContent.Free;
  end;
  if Success then
    InfoMessageBox( JVCSRES_Source_code_template_34jvcstodo_124_JEDI_VCS_Todo_Code_Comment34_successfully_added46 + sLineBreak +
                    JVCSRES_Hit_60Ctrl43J62_to_insert_the_template_into_your_source_files46
                  );
  {$ENDIF IDEDLL}
end;

//------------------------------------------------------------------------------

procedure TVCSToDo.elvToDoDrawHeader(Control: TWinControl;
  var ACanvas: TCanvas; Index: Integer; var ARect: TRect;
  Selected: Boolean; var DefaultDrawing: Boolean);
begin
  DefaultDrawing := True;
end;

//------------------------------------------------------------------------------

procedure TVCSToDo.elvToDoDrawItem(Control: TWinControl;
  var ACanvas: TCanvas; Index: Integer; ARect: TRect;
  State: TOwnerDrawState; var DefaultDrawing, FullRowSelect: Boolean);
begin
  DefaultDrawing := True;
  FullRowSelect := True;
end;

//------------------------------------------------------------------------------

procedure TVCSToDo.elvToDoDrawSubItem(Control: TWinControl;
  var ACanvas: TCanvas; Index, SubItem: Integer; ARect: TRect;
  State: TOwnerDrawState; var DefaultDrawing: Boolean);
begin
  DefaultDrawing := True;
end;

//------------------------------------------------------------------------------

procedure TVCSToDo.ShowSelectedLVItem;
var
  I: Integer;
begin
  if (elvToDo.Items.Count = 0) then 
    Exit;
  with elvToDo do 
  begin
    // Selected = nil ?
    if Selected = nil then 
      Exit;
    // Selected = TopItem ?
    if Selected = TopItem then 
      Exit;
    // zurück auf Position 0
    BeginUpdate;
    try
      I := Items.Count;
      while (TopItem <> Items[0]) and (I > 0) do 
      begin
        Scroll(0, - 10); // Texthöhe = 8
        Dec(I);
      end;
      EndUpdate;
      BeginUpdate;
      I := Items.Count;
      while (TopItem <> Selected) and (I > 0) do
      begin
        Scroll(0, 10);
        Dec(I);
      end;
    finally
      EndUpdate;
    end;
  end; // with elvModules do begin
end;

//------------------------------------------------------------------------------

procedure TVCSToDo.btnFilterClick(Sender: TObject);
begin
  if not CheckforChanges then 
    Exit;
  FillListView(True);
end;

//------------------------------------------------------------------------------

procedure TVCSToDo.Refresh1Click(Sender: TObject);
begin
  if not CheckforChanges then 
    Exit;
  FillListView(False);
end;

//------------------------------------------------------------------------------

procedure TVCSToDo.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSToDo.CopytoClipboard1Click(Sender: TObject);
var 
  ResultString, CurrentText: string;
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
  Screen.Cursor := crHourGlass;
  try
    with elvToDo do 
    begin
      if Items.Count = 0 then 
      begin
        InfoMessageBox( JVCSRES_Requested_result_set_is_blank46_Nothing_to_do46 );
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
      end; // for J := 0 to Columns.Count - 1 do begin

      ResultString := Caption + cr;
      CurrentText := '';
      while Length(CurrentText) < Length(Caption) do
        CurrentText := CurrentText + '=';
      ResultString := ResultString + CurrentText + cr + cr;
      ResultString := ResultString + Format(JVCSRES_37d_entries46, [Items.Count]) + cr + cr;

      for J := 0 to Columns.Count - 1 do 
      begin
        ResultString := ResultString + SizeString(J, Columns[J].Caption, ' ');
        if J < (Columns.Count - 1) then 
          ResultString := ResultString + ' | ';
      end;
      ResultString := ResultString + cr;
      for J := 0 to Columns.Count - 1 do 
      begin
        ResultString := ResultString + SizeString(J, '-', '-');
        if J < (Columns.Count - 1) then 
          ResultString := ResultString + ' | ';
      end;
      ResultString := ResultString + cr;

      for I := 0 to Items.Count - 1 do 
      begin
        for J := 0 to Columns.Count - 1 do 
        begin
          if J = 0 then 
            CurrentText := Items[I].Caption
          else 
            CurrentText := Items[I].SubItems[J - 1];
          ResultString := ResultString + SizeString(J, CurrentText, ' ');
          if J < (Columns.Count - 1) then 
            ResultString := ResultString + ' | ';
        end; // for J := 0 to Columns.Count - 1 do begin
        ResultString := ResultString + cr;
      end; // for I := 0 to Items.Count - 1 do begin
    end; // with elv do begin

    ResultString := ResultString + cr + JVCSRES_Source58_ + sArchiveSource + cr +
      JVCSRES_JEDI_VCS_ + sProductVer + cProductInf + DateTimeToStr(Now) + cr;

    VCSSimpleReport := TVCSSimpleReport.Create(Application);
    try
      VCSSimpleReport.RepID := 16;    
      VCSSimpleReport.Left := Left + 60;
      VCSSimpleReport.Top := Top + 60;
      VCSSimpleReport.FullReportString := ResultString;
      VCSSimpleReport.SavePath := ExtractFileDir(sProjectName);
      VCSSimpleReport.SaveFileName := 'ToDo.txt';
      VCSSimpleReport.LineCount := elvToDo.Items.Count + 8;
      VCSSimpleReport.ShowModal;
    finally
      VCSSimpleReport.Free;
    end;

  finally
    Screen.Cursor := crDefault;
    SetLength(oaColumnsWidth, 0);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSToDo.spBtnImportD5Click(Sender: TObject);
var 
  D5ToDoFileName, D5ToDoFileContent, RelatedProject, CurrentToDo, CurrentPriority, CurrentOwner,
  CurrentCategory, CurrentText: string;
  NewPos: Integer;
  D5ToDoFile: TextFile;
begin
  with OpenDialog1 do 
  begin
    Title := JVCSRES_Select_D5_ToDo_file;
    Options := [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing];
    InitialDir := ExtractFileDir(sProjectName);
    FileName := '';
    Filter := JVCSRES_D5_ToDo_files_404246todo411244246todo124All_files_4042464241124424642;
    if Execute then
      D5ToDoFileName := FileName
    else
      Exit;
  end; // with OpenDialog1 do begin

{  UserBuffer.First;
  while (not UserBuffer.EoF) do begin
    if (UserBuffer.Fields[3] = '0') then
      VCSToDoEdit.UserList.Add(UserBuffer.Fields[1]);
    UserBuffer.Next;
  end;}

  VCSSelectList := TVCSSelectList.Create(Application);
  try
    VCSSelectList.Left := Left + 40;
    VCSSelectList.Top := Top + 40;
    VCSSelectList.MultiSelect := True;
    VCSSelectList.SetCaption(JVCSRES_Select_the_related_project);
    ProjectBuffer.First;
    while not ProjectBuffer.Eof do 
    begin
      VCSSelectList.AddListItem(ProjectBuffer.Fields[1]);
      ProjectBuffer.Next;
    end;
    VCSSelectList.DefaultString := D5ToDoFileName;
    VCSSelectList.ShowModal;
    RelatedProject := VCSSelectList.ResultString;
  finally
    VCSSelectList.Free;
  end;


  AssignFile(D5ToDoFile, D5ToDoFileName);
  Reset(D5ToDoFile);
  try
    ReadLn(D5ToDoFile, D5ToDoFileContent);
  finally
    CloseFile(D5ToDoFile);
  end;

  ShowMessage(D5ToDoFileContent);
  {TODO 3 -oadmin1 -ccategory2 : test fasdfasdfsaf}
  {TODO 5 -oadmin -ccategory1 : test fasdfasdfsaf}
  while Pos('{TODO', D5ToDoFileContent) > 0 do 
  begin
    CurrentToDo := Copy(D5ToDoFileContent, 1, Pos('}', D5ToDoFileContent));
    Delete(D5ToDoFileContent, 1, Pos('}', D5ToDoFileContent));
    ShowMessage(CurrentToDo);
    // "{TODO 5 -oadmin -ccategory1 : test fasdfasdfsaf}"
    CurrentPriority := Copy(CurrentToDo, 7, 1);
    Delete(CurrentToDo, 1, 8);
    ShowMessage(CurrentPriority);
    // "-oadmin -ccategory1 : test fasdfasdfsaf}"
    CurrentOwner := '';
    NewPos := Pos('-o', CurrentToDo) + 2;
    repeat
      CurrentOwner := CurrentOwner + CurrentToDo[NewPos];
      Inc(NewPos);
    until (NewPos >= Length(CurrentToDo)) or (CurrentToDo[NewPos] = ' ');
    ShowMessage(CurrentOwner);
    CurrentCategory := '';
    NewPos := Pos('-c', CurrentToDo) + 2;
    repeat
      CurrentCategory := CurrentCategory + CurrentToDo[NewPos];
      Inc(NewPos);
    until (NewPos >= Length(CurrentToDo)) or (CurrentToDo[NewPos] = ' ');
    ShowMessage(CurrentCategory);
    CurrentText := '';
    NewPos := Pos(' : ', CurrentToDo) + 3;
    repeat
      CurrentText := CurrentText + CurrentToDo[NewPos];
      Inc(NewPos);
    until (NewPos >= Length(CurrentToDo)) or (CurrentToDo[NewPos] = '}');
    if (Length(CurrentText) > 0) and (CurrentText[Length(CurrentText)] = '}') then
      Delete(CurrentText, Length(CurrentText), 1);
    ShowMessage(CurrentText);
  end; // while Pos('{TODO', D5ToDoFileContent) > 0 do begin

  {  if VCSToDoEdit.Priority <> 0 then begin
      AddLVItem(nil,
                IntToStr(VCSToDoEdit.Priority),
                DateToStr(Now),
                VCSToDoEdit.Project,
                VCSToDoEdit.Responsible,
                VCSToDoEdit.Category,
                VCSToDoEdit.Description,
                VCSToDoEdit.Target,
                VCSToDoEdit.Done,
                0,
                True);
      elvToDo.Resort;
      ShowSelectedLVItem;
      elvToDoClick(Self);}
end;

end.
