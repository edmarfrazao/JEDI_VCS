(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: SearchModules.pas

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
2003/02/18  MGosselink- emptied some .text props
2003/03/05  THensle   - changes for "ConfigStorage" unit
2003/03/09  USchuster - exchanged TjvMruList with TJVCSMruList (mantis #727)
                      - disabled the AutoSave property in rcbxMask
                        and removed the regkeys (they where wrong and
                        loading and saving is no done with MruListMask)
                      - removed rcbxMask.AutoSave.SaveValue
                      - the selected search mask will also be inserted into the
                        combobox now
2003/08/03  THuber    - set autocomplete to false on JvComboBox
                      - FormStorage changed in configStorage
2003/12/28  USchuster - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use constant)
2004/02/24  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/09/17  THuber    #2148 - get module shows no revisions
2004/10/03  THuber    #2148 - bugfix: restore project rights
                      - jedistyle cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/11/02  USchuster - minor style cleaning
                      - moved resourcestrings to JVCSGUIClientResources.pas
2005/09/17  USchuster - added several functions to the popup menu (mantis #3048)
2006/12/10  USchuster - changes for menu bitmaps and added "View" function
2007/03/07  USchuster - replaced "Open Parent Folder" code by function ShellOpenParentFolder (mantis #4079)
2007/06/30  USchuster - changes for large fonts (contraints size depend now on PixelsPerInch; analog to Mantis #3710)
2008/03/15  USchuster - added "Line History" menu item to popup menu
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit SearchModules;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  {$IFDEF DEBUG}
  JclDebug,
  {$ENDIF DEBUG}
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, Buttons, ExtCtrls, Menus, EnhListView, JvCombobox,
  JVCSMruList, JvExStdCtrls, ImgList, JVCSForms;

type
  TVCSSearchModules = class(TJVCSForm)
    Panel1: TPanel;
    btnCancel: TButton;
    btnSearch: TButton;
    Label1: TLabel;
    PopupMenu1: TPopupMenu;
    Addtocurrentproject1: TMenuItem;
    Help: TSpeedButton;
    btnReport: TButton;
    elvResult: TdfsEnhListView;
    ModuleHistory1: TMenuItem;
    N1: TMenuItem;
    rcbxMask: TJvComboBox;
    N2: TMenuItem;
    mnCheckIn: TMenuItem;
    mnCompare: TMenuItem;
    mnCheckOut: TMenuItem;
    mnOpenParentFolder: TMenuItem;
    mnOpenProject: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    mnOpenFile: TMenuItem;
    mnLineHistory: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCancelClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure Addtocurrentproject1Click(Sender: TObject);
    procedure rcbxMaskChange(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure EnableControls(Enable: Boolean);
    procedure btnReportClick(Sender: TObject);
    procedure elvResultDrawItem(Control: TWinControl; var ACanvas: TCanvas;
      Index: Integer; ARect: TRect; State: TOwnerDrawState;
      var DefaultDrawing, FullRowSelect: Boolean);
    procedure elvResultDrawHeader(Control: TWinControl;
      var ACanvas: TCanvas; Index: Integer; var ARect: TRect;
      Selected: Boolean; var DefaultDrawing: Boolean);
    procedure elvResultDrawSubItem(Control: TWinControl;
      var ACanvas: TCanvas; Index, SubItem: Integer; ARect: TRect;
      State: TOwnerDrawState; var DefaultDrawing: Boolean);
    procedure ModuleHistory1Click(Sender: TObject);
    procedure mnCheckInClick(Sender: TObject);
    procedure mnCompareClick(Sender: TObject);
    procedure mnCheckOutClick(Sender: TObject);
    procedure mnOpenParentFolderClick(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure mnOpenProjectClick(Sender: TObject);
    procedure mnOpenFileClick(Sender: TObject);
    procedure mnLineHistoryClick(Sender: TObject);
  private
    { Private declarations }
    FCreating: Boolean;
    ActDir: string;
    MruListMask: TJVCSMruList;
    FSelectedModuleID: Integer;
    FSelectedModuleName: string;
    FSelectedProjectID: Integer;
    FSelectedProjectName: string;
    FShowLineHistorySelected: Boolean;    
    FOpenProjectSelected: Boolean;
    procedure AddModules(ModuleName: string);
    function GetListViewString: string;
    function GetSelectedModule(var AModuleID: Integer): Boolean;
    function GetSelectedModuleFileName(var AModuleFileName: string): Boolean;
    function GetSelectedProject(var AProjectName: string): Boolean;
  public
    { Public declarations }
    property SelectedModuleID: Integer read FSelectedModuleID;
    property SelectedModuleName: string read FSelectedModuleName;
    property SelectedProjectID: Integer read FSelectedProjectID;
    property SelectedProjectName: string read FSelectedProjectName;
    property ShowLineHistorySelected: Boolean read FShowLineHistorySelected;    
    property OpenProjectSelected: Boolean read FOpenProjectSelected;
  end;

var
  VCSSearchModules: TVCSSearchModules;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSBase, VCSProcBase, DBModule, SimpleReport, History, ConfigStorage, JVCSClientObj,
  JVCSGUIClientResources, TextComp, ChkInSingle, ChkOutSingle, ShellAPI, LoadModule,
  JVCSGUIClientImages;

{$R *.dfm}

procedure TVCSSearchModules.FormCreate(Sender: TObject);
begin
  try
    Constraints.MinHeight := MulDiv(190, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(450, PixelsPerInch, 96);
    FCreating := True;
    // save actual folder
    GetDir(0, ActDir);
    Screen.Cursor := crHourGlass;

    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);
    jvcsLoadFormPosSize(Self);

    with elvResult do
    begin
      Columns[0].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'SearchModules_Col1.0', 50);
      Columns[1].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'SearchModules_Col1.1', 80);
      Columns[2].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'SearchModules_Col1.2', 140);
      Columns[3].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'SearchModules_Col1.3', 80);
    end;

    MruListMask := TJVCSMruList.CreateEx(sBaseRegistryKey + crbMRU + '15');
    rcbxMask.Items.Assign(MruListMask);

    FSelectedModuleID := -1;
    FSelectedModuleName := '';
    FSelectedProjectID := -1;
    FSelectedProjectName := '';
    FShowLineHistorySelected := False;
    FOpenProjectSelected := False;
    {$IFDEF IDEDLL}
    N4.Visible := False;
    mnOpenProject.Visible := False;
    {$ENDIF IDEDLL}
    if ShowMenuBitmaps then
      PopupMenu1.Images := GetToolImageList;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
    Screen.Cursor := crDefault;
    Screen.Cursors[cPopUpMCursor] := LoadCursor(hInstance, PChar('CURSORRM'));
    elvResult.Cursor := cPopUpMCursor;
    Addtocurrentproject1.Enabled := bProjectOpen;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSSearchModules.FormActivate(Sender: TObject);
begin
  Application.ProcessMessages;
  if not FCreating then
    Exit;
  FCreating := False;
  rcbxMask.SetFocus;
end;

//------------------------------------------------------------------------------

procedure TVCSSearchModules.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  jvcsSaveFormPosSize(Self);

  with elvResult do
  begin
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'SearchModules_Col1.0',
      Columns[0].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'SearchModules_Col1.1',
      Columns[1].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'SearchModules_Col1.2',
      Columns[2].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'SearchModules_Col1.3',
      Columns[3].Width);
  end;

  ChDir(ActDir);
end;

//------------------------------------------------------------------------------

procedure TVCSSearchModules.FormDestroy(Sender: TObject);
begin
  //  Log.Free;
  MruListMask.Free;
end;

//------------------------------------------------------------------------------

procedure TVCSSearchModules.btnCancelClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSSearchModules.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Search_modules);
  if Key = VK_ESCAPE then
  begin
    btnCancel.Click;
    Key := 0;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSSearchModules.EnableControls(Enable: Boolean);
begin
  rcbxMask.Enabled := Enable;
  btnSearch.Enabled := Enable;
  btnCancel.Enabled := Enable;
  btnReport.Enabled := Enable;
end;

//------------------------------------------------------------------------------

procedure TVCSSearchModules.btnSearchClick(Sender: TObject);
var
  LVItem: TListItem;
begin
  if rcbxMask.Text = '' then
  begin
    MessageBox( WindowHandle
              , PChar(Format(JVCSRES_6037s6246_This_value_cannot_be_blank46, [JVCSRES_Mask_string]))
              , cMsgBoxCaption
              , MB_OK or MB_ICONWARNING
              );
    rcbxMask.SetFocus;
    Exit;
  end;
  MruListMask.AddString(rcbxMask.Text);
  rcbxMask.Items.Insert(0, rcbxMask.Text);
  EnableControls(False);
  try
    Caption := JVCSRES_Search_Modules_45_searching464646;
    with DataModule1 do
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'SEARCH_MODULES';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [rcbxMask.Text]);
      SetupTimeoutCounter;
      AppSrvClient1.Send;

      while WaitForAppSrvClient do
        Application.ProcessMessages;
      if (AppSrvClientErr = -99) then
      begin
        ShowServerTimeOut(WindowHandle);
        EnableControls(True);
        Exit;
      end;
      if (AppSrvClientErr <> 0) or
        (AppSrvClient1.AnswerStatus <> '200') then
      begin
        ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
          AppSrvClient1.AnswerStatus);
        EnableControls(True);
        Exit;
      end;

      AppSrvClient1.Answer.First;
      elvResult.BeginUpdate;
      try
        elvResult.Items.Clear;
        while not AppSrvClient1.Answer.Eof do
        begin
          LVItem := elvResult.Items.Add;
          LVItem.Caption := AppSrvClient1.Answer.Fields[0];
          LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[1]);
          LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[2]);
          LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[3]);
          AppSrvClient1.Answer.Next;
        end;
      finally
        elvResult.EndUpdate;
      end;
    end; // with DataModule1 do begin

    Caption := Format(JVCSRES_Search_Modules_45_37d_hits, [elvResult.Items.Count]);
  finally
    EnableControls(True);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSSearchModules.Addtocurrentproject1Click(Sender: TObject);
var 
  I: Integer;
begin
  if elvResult.SelCount = 0 then 
    Exit;
  for I := 0 to elvResult.Items.Count - 1 do 
  begin
    if elvResult.Items[I].Selected then
      AddModules(elvResult.Items[I].SubItems[1] + elvResult.Items[I].SubItems[0]);
  end; // for i := 0 to elv.Items.Count - 1 do begin
  MessageBox( Handle
            , PChar(JVCSRES_You_must_refresh_40F541_the_project_manager_view_to_see_the_changes46)
            , cMsgBoxCaption
            , MB_OK or MB_ICONINFORMATION
            );
end;

//------------------------------------------------------------------------------

procedure TVCSSearchModules.AddModules(ModuleName: string);
begin
  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'ADD_NEW_MODULE';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [ServerProjectID]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(False, [ModuleName]);
    AppSrvClient1.Request.WriteFields(False, [moVer200]); // flags
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
  end; //   with DataModule1 do begin
end;

//------------------------------------------------------------------------------

procedure TVCSSearchModules.rcbxMaskChange(Sender: TObject);
begin
  btnSearch.Enabled := rcbxMask.Text <> '';
end;

//------------------------------------------------------------------------------

procedure TVCSSearchModules.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSSearchModules.btnReportClick(Sender: TObject);
var 
  ResultString: string;
begin
  ResultString := GetListViewString;
  if ResultString = '' then
    Exit;

  VCSSimpleReport := TVCSSimpleReport.Create(Application);
  try
    VCSSimpleReport.RepID := 12;
    VCSSimpleReport.Left := Left + 60;
    VCSSimpleReport.Top := Top + 60;
    VCSSimpleReport.FullReportString := ResultString;
    VCSSimpleReport.SavePath := ExtractFileDir(sProjectName);
    VCSSimpleReport.LineCount := elvResult.Items.Count + 8;
    VCSSimpleReport.SaveFileName := 'SearchResult.txt';
    VCSSimpleReport.ShowModal;
  finally
    VCSSimpleReport.Free;
  end;
end;

//------------------------------------------------------------------------------

function TVCSSearchModules.GetListViewString: string;
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
    with elvResult do 
    begin
      if Items.Count = 0 then
      begin
        MessageBox( WindowHandle
                  , PChar(JVCSRES_Requested_result_set_is_blank46_Nothing_to_do46)
                  , cMsgBoxCaption
                  , MB_OK
                  );
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
        end; // for j := 0 to Items.Count - 1 do begin
      end; // for j := 0 to Columns.Count - 1 do begin

      Result := Caption + cr;
      CurrentText := '';
      while Length(CurrentText) < Length(Caption) do
        CurrentText := CurrentText + '=';
      Result := Result + CurrentText + cr + cr;
      Result := Result + Format(JVCSRES_37d_modules_matches_3437s34, [Items.Count, rcbxMask.Text]);
      Result := Result + cr + cr;

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
        end; // for j := 0 to Columns.Count - 1 do begin
        Result := Result + cr;
      end; // for i := 0 to Items.Count - 1 do begin
    end; // with elv do begin

    Result := Result + cr + JVCSRES_Source58_ + sArchiveSource + cr +
      JVCSRES_JEDI_VCS_ + sProductVer + cProductInf + DateTimeToStr(Now) + cr;
  finally
    Screen.Cursor := crDefault;
    SetLength(oaColumnsWidth, 0);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSSearchModules.elvResultDrawItem(Control: TWinControl;
  var ACanvas: TCanvas; Index: Integer; ARect: TRect;
  State: TOwnerDrawState; var DefaultDrawing, FullRowSelect: Boolean);
begin
  DefaultDrawing := True;
  FullRowSelect := True;
end;

//------------------------------------------------------------------------------

procedure TVCSSearchModules.elvResultDrawHeader(Control: TWinControl;
  var ACanvas: TCanvas; Index: Integer; var ARect: TRect;
  Selected: Boolean; var DefaultDrawing: Boolean);
begin
  DefaultDrawing := True;
end;

//------------------------------------------------------------------------------

procedure TVCSSearchModules.elvResultDrawSubItem(Control: TWinControl;
  var ACanvas: TCanvas; Index, SubItem: Integer; ARect: TRect;
  State: TOwnerDrawState; var DefaultDrawing: Boolean);
begin
  DefaultDrawing := True;
end;

//------------------------------------------------------------------------------

procedure TVCSSearchModules.ModuleHistory1Click(Sender: TObject);
var
  SelectedModuleID: Integer;
  SelectedModuleFileName: string;
  SelectedModuleProject: string;  
  CurrentProjectState: TGUIClientProjectState;
begin
  if GetSelectedModule(SelectedModuleID) and GetSelectedModuleFileName(SelectedModuleFileName) and
    GetSelectedProject(SelectedModuleProject) then
  begin
    CurrentProjectState := SaveProjectState;
    try
      if OpenProjectByName(SelectedModuleProject) >= 1 then
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

function TVCSSearchModules.GetSelectedModule(var AModuleID: Integer): Boolean;
begin
  AModuleID := -1;
  if Assigned(elvResult.Selected) then
    AModuleID := StrToIntDef(elvResult.Selected.Caption, 0);
  Result := AModuleID > 0;
end;

function TVCSSearchModules.GetSelectedModuleFileName(var AModuleFileName: string): Boolean;
begin
  AModuleFileName := '';
  if Assigned(elvResult.Selected) and (elvResult.Selected.SubItems.Count > 1) then
    AModuleFileName := elvResult.Selected.SubItems[1] + elvResult.Selected.SubItems[0];
  Result := AModuleFileName <> '';
end;

function TVCSSearchModules.GetSelectedProject(var AProjectName: string): Boolean;
begin
  AProjectName := '';
  if Assigned(elvResult.Selected) and (elvResult.Selected.SubItems.Count > 2) then
    AProjectName := elvResult.Selected.SubItems[2];
  Result := AProjectName <> '';
end;

procedure TVCSSearchModules.mnCheckInClick(Sender: TObject);
var
  SelectedModuleID: Integer;
  SelectedModuleProject: string;
  CurrentProjectState: TGUIClientProjectState;
begin
  if GetSelectedModule(SelectedModuleID) and GetSelectedProject(SelectedModuleProject) then
  begin
    CurrentProjectState := SaveProjectState;
    try
      if OpenProjectByName(SelectedModuleProject) >= 2 then
      begin
        VCSChkInSingle := TVCSChkInSingle.Create(Application);
        try
          VCSChkInSingle.SelectModuleList.Add('>' + IntToStr(SelectedModuleID));
          VCSChkInSingle.AsChild := True;
          VCSChkInSingle.ShowModal;
        finally
          VCSChkInSingle.Free;
        end;
      end;
    finally
      RestoreProjectState(CurrentProjectState);
    end;
  end;
end;

procedure TVCSSearchModules.mnCompareClick(Sender: TObject);
var
  SelectedModuleFileName: string;
  SelectedModuleProject: string;
  CurrentProjectState: TGUIClientProjectState;
begin
  if GetSelectedModuleFileName(SelectedModuleFileName) and GetSelectedProject(SelectedModuleProject) then
  begin
    CurrentProjectState := SaveProjectState;
    try
      if OpenProjectByName(SelectedModuleProject) >= 1 then
        DoModuleCompare(SelectedModuleFileName);
    finally
      RestoreProjectState(CurrentProjectState);
    end;
  end;
end;

procedure TVCSSearchModules.mnCheckOutClick(Sender: TObject);
var
  SelectedModuleID: Integer;
  SelectedModuleProject: string;
  CurrentProjectState: TGUIClientProjectState;
begin
  if GetSelectedModule(SelectedModuleID) and GetSelectedProject(SelectedModuleProject) then
  begin
    CurrentProjectState := SaveProjectState;
    try
      if OpenProjectByName(SelectedModuleProject) >= 2 then
      begin
        VCSChkOutSingle := TVCSChkOutSingle.Create(Application);
        try
          VCSChkOutSingle.SelectModuleList.Add('>' + IntToStr(SelectedModuleID));
          VCSChkOutSingle.AsChild := True;
          VCSChkOutSingle.ShowModal;
        finally
          VCSChkOutSingle.Free;
        end;
      end;
    finally
      RestoreProjectState(CurrentProjectState);
    end;
  end;
end;

procedure TVCSSearchModules.mnOpenParentFolderClick(Sender: TObject);
var
  SelectedModuleFileName: string;
begin
  if GetSelectedModuleFileName(SelectedModuleFileName) then
    ShellOpenParentFolder(SelectedModuleFileName);
end;

procedure TVCSSearchModules.PopupMenu1Popup(Sender: TObject);
var
  DummyInt: Integer;
  SelectedModuleProject: string;
begin
  mnCheckIn.Enabled := GetSelectedModule(DummyInt);
  mnCheckOut.Enabled := mnCheckIn.Enabled;
  mnCompare.Enabled := mnCheckIn.Enabled;
  ModuleHistory1.Enabled := mnCheckIn.Enabled;
  mnLineHistory.Enabled := mnCheckIn.Enabled;
  mnOpenParentFolder.Enabled := mnCheckIn.Enabled;
  mnOpenProject.Enabled := GetSelectedProject(SelectedModuleProject) and
    ((not bProjectOpen) or (sProjectName <> SelectedModuleProject));
  Addtocurrentproject1.Enabled := mnCheckIn.Enabled and bProjectOpen;
  mnOpenFile.Enabled := mnCheckIn.Enabled;
end;

procedure TVCSSearchModules.mnOpenProjectClick(Sender: TObject);
{$IFNDEF IDEDLL}
var
  SelectedModuleProject: string;
  CurrentProjectState: TGUIClientProjectState;
{$ENDIF ~IDEDLL}
begin
  {$IFNDEF IDEDLL}
  if GetSelectedProject(SelectedModuleProject) then
  begin
    CurrentProjectState := SaveProjectState;
    try
      if OpenProjectByName(SelectedModuleProject) >= 1 then
      begin
        FSelectedProjectID := ServerProjectID;
        FSelectedProjectName := sProjectName;
        FOpenProjectSelected := True;
        Close;
      end;
    finally
      RestoreProjectState(CurrentProjectState);
    end;
  end;
  {$ENDIF ~IDEDLL}
end;

procedure TVCSSearchModules.mnOpenFileClick(Sender: TObject);
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

procedure TVCSSearchModules.mnLineHistoryClick(Sender: TObject);
var
  SelectedModuleProject: string;
  CurrentProjectState: TGUIClientProjectState;
begin
  if GetSelectedProject(SelectedModuleProject) then
  begin
    CurrentProjectState := SaveProjectState;
    try
      if OpenProjectByName(SelectedModuleProject) >= 1 then
      begin
        if GetSelectedModule(FSelectedModuleID) and GetSelectedModuleFileName(FSelectedModuleName) then
        begin
          FShowLineHistorySelected := True;
          Close;
        end;
      end;
    finally
      RestoreProjectState(CurrentProjectState);
    end;
  end;
end;

end.
