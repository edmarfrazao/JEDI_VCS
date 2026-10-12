(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: History.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS: Thomas Huber (Thomas_D_Huber@gmx.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
May/03:
- maybe it's necessary to call GET_PROJECT_ID if ProjectID <> ServerProjectID
  in order to get a new TransactionNr
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber     - 1st Migrationstep from FreeVCS code to JEDI VCS
2003/02/12  USchuster  - changed DSAMsg with JVCSDialogs in uses clause to use
                         JvDSADialogs
2003/02/18  MGosselink - changed the autosize prop of TJvHTComboBox
2003/02/18  THuber     - changed TJvHTComboBox => TJvComboBox
2003/03/05  THensle    - changes for "ConfigStorage" unit
2003/04/08  USchuster  - changes for IDEInterface
2003/04/11  FBouwmans  - Added multiple projectid for group display
                         (local project admin)
2003/05/02  USchuster  - selected revision member will be delivered to
                         TextComp (mantis #880/4.)
                       - added scrolling to the lastest revision
2003/11/09  USchuster  - exchanged TextComp call with new procedure DoModuleCompare (mantis #1204)
                       - changed JEDI-VCS to JEDI VCS in unit header and
                         message boxes (use new constant)
2004/02/24  THuber     - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/04/12  USchuster  - AutoComplete in ComboBox now False and Style is
                         csDropDownList again(lost in migration from FreeVCS to JEDI VCS)
                       - adjusted min width
                       - minor style cleaning (casing and comments)
2004/09/17  FHasovic   - Added dxGetText support for localization
2004/10/30  USchuster  - localization of Fikret Hasovic from newideas project
                         with over IFDEF LANGUAGE
                       - res strings and displayed strings changed to resourcestrings
2004/11/03  USchuster  - moved resourcestrings to JVCSGUIClientResources.pas
2005/03/17  USchuster  - changes to open the "Get Module" dialog with the selected
                         revision (mantis #2769)
2005/04/25  CSchuette  - added call to "ResolveFileFamilies" to fix mantis #1205
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC3 was released ^^^^^^^^^^^^^^^^^^^^^
2006/01/09  USchuster  - added label column and "Assign Labels" function (mantis #3416)
2006/12/10  USchuster  - changes for menu bitmaps
2007/06/17  USchuster  - fixed self handled shortcuts
2007/06/30  USchuster  - changes for large fonts (contraints and default size depend now on PixelsPerInch; analog to Mantis #3710)
2008/11/15  USchuster  - changes for TRevisionLabelStrs
2008/12/22  THuber     - Baseclass changed to TJVCSForm
2011/01/15  USchuster  - changed font to Tahoma
2012/07/08  AKroeber   - call external bugtracker (via regex from checkin comment)

-----------------------------------------------------------------------------*)

unit History;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, SortGrid, ExtCtrls, Menus, ComCtrls, ImgList, Buttons, JvCombobox,
  JvExStdCtrls, JVCSForms;

type
  TVCSHistory = class(TJVCSForm)
    Panel1: TPanel;
    Label1: TLabel;
    Button1: TButton;
    PopupMenu1: TPopupMenu;
    lvHistory: TListView;
    StateImageList: TImageList;
    Comments1: TMenuItem;
    edDescr: TEdit;
    Help: TSpeedButton;
    ChangeDescription2: TMenuItem;
    N1: TMenuItem;
    SpeedButton1: TSpeedButton;
    btnReport: TButton;
    GetModule1: TMenuItem;
    Compare1: TMenuItem;
    ecbModules: TJvComboBox;
    N2: TMenuItem;
    AssignLabels1: TMenuItem;
    LabelTimer: TTimer;
    BugtrackerSep: TMenuItem;
    BugtrackerItem: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure HelpTopic1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Comments1Click(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure ChangeDescription2Click(Sender: TObject);
    procedure btnReportClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure GetModule1Click(Sender: TObject);
    procedure Compare1Click(Sender: TObject);
    procedure ecbModulesChange(Sender: TObject);
    procedure AssignLabels1Click(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure LabelTimerTimer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure BugtrackerItemClick(Sender: TObject);
  private
    { Private-Deklarationen }
    bCreating: Boolean;
    CurrentIDEModule: string;
    ModuleIDs: TStringList;
    FFillListViewCount: Integer;
    FIsInTimer: Boolean;
    FFirstRevisionItemList: TThreadList;
    FFormClosed: Boolean;
    procedure FillListView;
    function GetListViewString: string;
    function GetModuleName(MID: string): string;
    procedure ClearFirstRevisionItems;
  protected
    procedure WndProc(var Message: TMessage); override;
  public
    { Public-Deklarationen }
    ModuleName: string;
    ModuleID: Integer;
    ProjectID: Integer;
    procedure RestrictSize(var Msg: TMessage); message WM_GETMINMAXINFO;
  end;

var
  VCSHistory: TVCSHistory;

implementation

{$R *.dfm}

uses
  {$IFDEF DEBUG}
  JclDebug,
  {$ENDIF DEBUG}
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSBase, VCSProcBase, JVCSDialogs, DBModule, ListView, Description, CommCtrl,
  SimpleReport, ModuleInfo, Textcomp, CheckSum, TZHandling, ConfigStorage, ExtBugtracker,
  JVCSGUIClientResources, AssignLabels, JVCSHistoryCommon, JVCSGUIClientImages;

type
  PFirstRevisionItemRecord = ^TFirstRevisionItemRecord;
  TFirstRevisionItemRecord = record
    RevisionID: Integer;
    ItemIndex: Integer;
    FillListViewCount: Integer;
  end;

procedure TVCSHistory.ClearFirstRevisionItems;
var
  I: Integer;
  List: TList;
begin
  List := FFirstRevisionItemList.LockList;
  try
    for I := 0 to Pred(List.Count) do
      Dispose(List[I]);
    List.Clear;
  finally
    FFirstRevisionItemList.UnlockList;
  end;
end;

//------------------------------------------------------------------------------
procedure TVCSHistory.FormCreate(Sender: TObject);
var
  ToolTipHandle: HWND;
  DlgTop,
  DlgLeft,
  DlgWidth,
  DlgHeight: Integer;
begin
  try
    ModuleName := '';
    ModuleID := 0;
    ProjectID := ServerProjectID;
    // ListView Tooltips
    SendMessage(lvHistory.Handle, LVM_SETEXTENDEDLISTVIEWSTYLE, LVS_EX_INFOTIP,
      LVS_EX_INFOTIP);
    ToolTipHandle := SendMessage(lvHistory.Handle, LVM_GETTOOLTIPS, 0, 0);
    SendMessage(ToolTipHandle, TTM_SETDELAYTIME, TTDT_AUTOMATIC, 1);
    SendMessage(ToolTipHandle, TTM_SETDELAYTIME, TTDT_AUTOPOP, 3000);

    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    if not jvcsReadWindowPosAndSize(sBaseRegistryKey + crbWindows, 'ModuleHistory',
      DlgTop, DlgLeft, DlgWidth, DlgHeight) then
    begin
      DlgTop := (Screen.Height - Height) div 2;
      DlgLeft := (Screen.Width - Width) div 2;
      DlgWidth := MulDiv(530, PixelsPerInch, 96);
      DlgHeight := MulDiv(280, PixelsPerInch, 96);
    end;
    Top := DlgTop;
    Left := DlgLeft;
    Width := DlgWidth;
    Height := DlgHeight;

    with lvHistory do
    begin
      Columns[0].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ModuleHistory_Col1.0', 60);
      Columns[1].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ModuleHistory_Col1.1', 60);
      Columns[2].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ModuleHistory_Col1.2', 50);
      Columns[3].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ModuleHistory_Col1.3', 75);
      Columns[4].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ModuleHistory_Col1.4', 70);
      Columns[5].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ModuleHistory_Col1.5', 150);
      Columns[6].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ModuleHistory_Col1.6', 150);
      Columns[7].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ModuleHistory_Col1.7', 0);
      Columns[8].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ModuleHistory_Col1.8', 150);
    end;

    {$IFDEF IDEDLL}
    CurrentIDEModule := IDEInterface.GetCurrentFile;
    ResolveFileFamilies(CurrentIDEModule);
    {$ENDIF IDEDLL}
    ModuleIDs := TStringList.Create;

    Screen.Cursors[cPopUpMCursor] := LoadCursor(hInstance, PChar('CURSORRM'));
    lvHistory.Cursor := cPopUpMCursor;

    FFillListViewCount := 0;
    FIsInTimer := False;
    FFirstRevisionItemList := TThreadList.Create;
    FFormClosed := False;

    if ShowMenuBitmaps then
      PopupMenu1.Images := GetToolImageList;

    bCreating := True;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSHistory.FormActivate(Sender: TObject);
var
  I, CurrentIndex: Integer;
  //    Msg,
  SelectedModule: string;
begin
  Application.ProcessMessages;
  if bCreating then
  begin
    Screen.Cursor := crHourGlass;
    {if ModuleName <> ''
      then SelectedModule := AnsiLowerCase(ExtractFileName(ModuleName))
        else SelectedModule := AnsiLowerCase(ExtractFileName(CurrentIDEModule));}
    if ModuleName <> '' then
      SelectedModule := AnsiLowerCase(ModuleName)
    else
      SelectedModule := AnsiLowerCase(CurrentIDEModule);

    if (ModuleID <> 0) then
    begin
      ModuleIDs.Add(SelectedModule + '=' + IntToStr(ModuleID));
      ecbModules.Items.Add(SelectedModule);
    end // if (ModuleID <> 0) then begin
    else
    begin
      // Modulnamen aus Archiv
      with DataModule1 do
      begin
        AppSrvClient1.Request.Rewrite;
        AppSrvClient1.FunctionCode := 'GET_PROJECT_MODULE_LIST';
        AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
        AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
        AppSrvClient1.Request.WriteFields(True, [ProjectID]);
        AppSrvClient1.Request.WriteFields(False, [False]);
        SetupTimeoutCounter;
        AppSrvClient1.Send;

        while DataModule1.WaitForAppSrvClient do
          Application.ProcessMessages;
        if (AppSrvClientErr <> 0) or
          (AppSrvClient1.AnswerStatus <> '200') then
        begin
          ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
            AppSrvClient1.AnswerStatus);
          Exit;
        end;


        DataModule1.AppSrvClient1.Answer.First;
        while not DataModule1.AppSrvClient1.Answer.Eof do
        begin
          ModuleIDs.Add(AppSrvClient1.Answer.Fields[2] +
            AppSrvClient1.Answer.Fields[1] + '=' +
            AppSrvClient1.Answer.Fields[0]);
          ecbModules.Items.Add(AppSrvClient1.Answer.Fields[2] +
            AppSrvClient1.Answer.Fields[1]);
          DataModule1.AppSrvClient1.Answer.Next;
        end; // while not AppSrvClient1.Answer.Eof do begin
      end; // with DataModule1 do begin}
    end; // else if (ModuleID <> 0) then begin

    // aktuelle Datei in Combobox selektieren
    CurrentIndex := -1;
    for I := 0 to ecbModules.Items.Count - 1 do
    begin
      if (SelectedModule = ecbModules.Items[I]) then
      begin
        CurrentIndex := I;
        Break;
      end; // if Pos(SelectedModule, cbModules.Items[I]) <> 0 then begin
    end; // for I := 0 to cbModules.Items.Count - 1 do begin
    if (CurrentIndex = -1) and (ecbModules.Items.Count > 0) then
      ecbModules.ItemIndex := 0
    else
      ecbModules.ItemIndex := CurrentIndex;

    FillListView;
    bCreating := False;
    Screen.Cursor := crDefault;
  end; // if bCreating then begin
end;

//------------------------------------------------------------------------------

procedure TVCSHistory.ecbModulesChange(Sender: TObject);
begin
  FillListView;
end;

//------------------------------------------------------------------------------

procedure TVCSHistory.FillListView;
var
  CurrentVersion, CurrentRevision, ModuleID: string;
  CheckedOut: Boolean;
  ModuleCount: Integer;
  LVItem: TListItem;
  FirstRevisionItem: PFirstRevisionItemRecord;
  List: TList;
  RevisionLabelStrs: TRevisionLabelStrs;
  S: string;
begin
  Inc(FFillListViewCount);
  ClearFirstRevisionItems;

  if ecbModules.Text = '' then
    Exit;
  ModuleID := ModuleIDs.Values[ecbModules.Text];

  RevisionLabelStrs := TRevisionLabelStrs.Create(StrToIntDef(ModuleID, 0));
  try
    lvHistory.Items.BeginUpDate;
    try
      lvHistory.Items.Clear;
      ModuleCount := 0;
      with DataModule1 do
      begin
        AppSrvClient1.Request.Rewrite;
        AppSrvClient1.FunctionCode := 'GET_MODULE_HISTORY';
        AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
        AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
        AppSrvClient1.Request.WriteFields(True, [ModuleID]);
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
        CheckedOut := False;
        if not AppSrvClient1.Answer.Eof then
        begin
          if AppSrvClient1.Answer.Fields[0] <> '' then
            edDescr.Text := AppSrvClient1.Answer.Fields[0]
          else
            edDescr.Text := JVCSRES_blank;
        end; // if not AppSrvClient1.Answer.EoF then begin
        if not AppSrvClient1.Answer.Eof then
          AppSrvClient1.Answer.Next;
        while not AppSrvClient1.Answer.Eof do
        begin
          Inc(ModuleCount);
          CheckedOut := DecodeBoolStr(AppSrvClient1.Answer.Fields[0]);
          LVItem := lvHistory.Items.Add;
          CurrentVersion := AppSrvClient1.Answer.Fields[1];
          CurrentRevision := AppSrvClient1.Answer.Fields[2];
          // Ver/Rev
          LVItem.Caption := CurrentVersion + '.' + CurrentRevision;
          // by User
          LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[3]);
          // Member
          LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[6]);
          // Time
          LVItem.SubItems.Add(DateTimeToStr(GMTStr2LocalDateTime(AppSrvClient1.Answer.Fields[4])));
          // Size
          LVItem.SubItems.Add(FormatFloat('#,', _StrToInt(AppSrvClient1.Answer.Fields[5])));
          // Comment I
          LVItem.SubItems.Add(RemoveCRLF(AppSrvClient1.Answer.Fields[7]));
          // Comment O
          LVItem.SubItems.Add(RemoveCRLF(AppSrvClient1.Answer.Fields[8]));
          // Rev. ID
          LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[9]);
          // labels
          if RevisionLabelStrs.UseGetLabelsByRevision then
            S := ''
          else
            S := RevisionLabelStrs.GetRevisionLabelsStr(StrToIntDef(AppSrvClient1.Answer.Fields[9], 0));
          LVItem.SubItems.Add(S);
          if RevisionLabelStrs.UseGetLabelsByRevision then
          begin
            List := FFirstRevisionItemList.LockList;
            try
              New(FirstRevisionItem);
              List.Add(FirstRevisionItem);
              FirstRevisionItem^.RevisionID := StrToIntDef(AppSrvClient1.Answer.Fields[9], 0);
              FirstRevisionItem^.ItemIndex := LVItem.Index;
              FirstRevisionItem^.FillListViewCount := FFillListViewCount;
            finally
              FFirstRevisionItemList.UnlockList;
            end;
          end;
          if not AppSrvClient1.Answer.Eof then
            AppSrvClient1.Answer.Next;
          while (not AppSrvClient1.Answer.Eof) and
            (CurrentVersion = AppSrvClient1.Answer.Fields[1]) and
            (CurrentRevision = AppSrvClient1.Answer.Fields[2]) do
          begin
            LVItem := lvHistory.Items.Add;
            // Ver/Rev
            LVItem.Caption := '';
            // by User
            LVItem.SubItems.Add('');
            // Member
            LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[6]);
            // Time
            LVItem.SubItems.Add(DateTimeToStr(GMTStr2LocalDateTime(AppSrvClient1.Answer.Fields[4])));
            // Size
            LVItem.SubItems.Add(FormatFloat('#,', _StrToInt(AppSrvClient1.Answer.Fields[5])));
            // Comment I
            LVItem.SubItems.Add('');
            // Comment O
            LVItem.SubItems.Add('');
            // Rev. ID
            LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[9]);
            // empty label
            LVItem.SubItems.Add('');
            AppSrvClient1.Answer.Next;
          end; // while (not AppSrvClient1.Answer.EoF) and
        end; // while not AppSrvClient1.Answer.EoF do begin
      end; // with DataModule1 do begin
      if CheckedOut then
        lvHistory.Items[lvHistory.Items.Count - 1].StateIndex := 1;
      {  scroll to the latest entry, because in most cases the user would like
         to see the lastest comments instead of the oldest  }
      if lvHistory.Items.Count > 0 then
        lvHistory.Items[lvHistory.Items.Count - 1].MakeVisible(False);

      Caption := Format(JVCSRES_Module_History_45_37s_45_37s_45_available_versions58_37d,
        [AnsiLowerCase(ExtractFileName(sProjectName)), CutPathStr(ecbModules.Text, 40), ModuleCount]);
    finally
      lvHistory.Items.EndUpDate;
    end;
    if RevisionLabelStrs.UseGetLabelsByRevision then
      LabelTimer.Enabled := True;
  finally
    RevisionLabelStrs.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSHistory.RestrictSize(var Msg: TMessage);
var
  P: PMinMaxInfo;
begin
  P := PMinMaxInfo(Msg.lParam);
  P.ptMaxSize.x := trResDesktop.Right;
  P.ptMaxSize.y := trResDesktop.Bottom;
  P.ptMaxPosition.x := 0;
  P.ptMaxPosition.y := 0;
  P.ptMinTrackSize.x := MulDiv(460, PixelsPerInch, 96);
  P.ptMinTrackSize.y := MulDiv(200, PixelsPerInch, 96);
end;

//------------------------------------------------------------------------------

procedure TVCSHistory.HelpTopic1Click(Sender: TObject);
begin
  PerformHelpCommand(Application, IDH_History);
end;

//------------------------------------------------------------------------------

procedure TVCSHistory.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_History);
  if (Shift * [ssShift, ssAlt, ssCtrl] = [ssCtrl]) and (Chr(Key) in ['D', 'd']) then
    if (not CtrlSCDisabled(WindowHandle)) then
      ChangeDescription2Click(Self);
end;

//------------------------------------------------------------------------------

procedure TVCSHistory.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FFormClosed := True;
  jvcsWriteWindowPosAndSize(sBaseRegistryKey + crbWindows, 'ModuleHistory',
    Top, Left, Width, Height);

  with lvHistory do
  begin
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ModuleHistory_Col1.0',
      Columns[0].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ModuleHistory_Col1.1',
      Columns[1].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ModuleHistory_Col1.2',
      Columns[2].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ModuleHistory_Col1.3',
      Columns[3].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ModuleHistory_Col1.4',
      Columns[4].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ModuleHistory_Col1.5',
      Columns[5].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ModuleHistory_Col1.6',
      Columns[6].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ModuleHistory_Col1.7',
      Columns[7].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ModuleHistory_Col1.8',
      Columns[8].Width);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSHistory.Comments1Click(Sender: TObject);
var
  ResultStr: string;
begin
  if lvHistory.Selected = nil then
    Exit;
  ResultStr := JVCSRES_Check_in_comment58 + ';' +
    lvHistory.Selected.SubItems[4] + ';;' +
    JVCSRES_Check_out_comment58 + ';' +
    lvHistory.Selected.SubItems[5] + ';';
  VCSListView := TVCSListView.Create(Application);
  try
    VCSListView.Caption := Format(JVCSRES_Comments_for_version_37s, [lvHistory.Selected.Caption]);
    VCSListView.Left := Left + 60;
    VCSListView.Top := Top + 60;
    VCSListView.EnableWordWrap(True);
    VCSListView.SetUpListView(ResultStr);
    VCSListView.ShowModal;
  finally
    VCSListView.Free;
    VCSListView := nil;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSHistory.HelpClick(Sender: TObject);
var
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSHistory.ChangeDescription2Click(Sender: TObject);
var
  ModuleID, ModuleCaption, Description: string;
begin
  if ecbModules.Text = '' then
    Exit;
  ModuleID := ModuleIDs.Values[ecbModules.Text];

  ModuleCaption := CutPathStr(ecbModules.Text, 40);

  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_UPDATE_DESCRIPTION';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [2]);
    AppSrvClient1.Request.WriteFields(False, [ModuleID]); // id
    AppSrvClient1.Request.WriteFields(False, [False]); // update
    AppSrvClient1.Request.WriteFields(False, ['']); // text
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
    Description := '';
    if not AppSrvClient1.Answer.Eof then
      Description := AppSrvClient1.Answer.Fields[0];

    VCSDescription := TVCSDescription.Create(Application);
    try
      VCSDescription.Top := Top + 60;
      VCSDescription.Left := Left + 60;
      VCSDescription.DescType := 2;
      VCSDescription.SetDescripCaption(Format(JVCSRES_38Module58_37s, [ModuleCaption]));
      VCSDescription.SetDescription(Description);
      VCSDescription.EnableCheckBox(False);
      VCSDescription.ShowModal;
      Description := VCSDescription.Description;
    finally
      VCSDescription.Free;
    end;
    if Description = '' then
    begin
      Exit;
    end;

    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_UPDATE_DESCRIPTION';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [2]);
    AppSrvClient1.Request.WriteFields(False, [ModuleID]); // id
    AppSrvClient1.Request.WriteFields(False, [True]); // update
    AppSrvClient1.Request.WriteFields(False, [Description]); // text
    SetupTimeoutCounter;
    AppSrvClient1.Send;

    while WaitForAppSrvClient do
      Application.ProcessMessages;
    if (AppSrvClientErr = -99) then
    begin
      ShowServerTimeOut(WindowHandle);
    end;
    if (AppSrvClientErr <> 0) or
      (AppSrvClient1.AnswerStatus <> '200') then
    begin
      ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
        AppSrvClient1.AnswerStatus);
    end;
  end; // with DataModule1 do begin
  edDescr.Text := Description;
end;

//------------------------------------------------------------------------------

function TVCSHistory.GetListViewString: string;
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
    with lvHistory do
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

procedure TVCSHistory.btnReportClick(Sender: TObject);
var
  ResultString: string;
begin
  ResultString := GetListViewString;
  if ResultString = '' then
    Exit;

  VCSSimpleReport := TVCSSimpleReport.Create(Application);
  try
    VCSSimpleReport.RepID := 4;
    VCSSimpleReport.Left := Left + 60;
    VCSSimpleReport.Top := Top + 60;
    VCSSimpleReport.FullReportString := ResultString;
    VCSSimpleReport.SavePath := ExtractFileDir(sProjectName);
    VCSSimpleReport.SaveFileName := 'ModuleHistory.txt';
    VCSSimpleReport.LineCount := lvHistory.Items.Count + 8;
    VCSSimpleReport.ShowModal;
  finally
    VCSSimpleReport.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSHistory.FormDestroy(Sender: TObject);
begin
  ModuleIDs.Free;
  ClearFirstRevisionItems;
  FFirstRevisionItemList.Free;
end;

//------------------------------------------------------------------------------

procedure TVCSHistory.GetModule1Click(Sender: TObject);
var
  ModuleID: string;
begin
  if ecbModules.Text = '' then
    Exit;

  ModuleID := ModuleIDs.Values[ecbModules.Text];
  VCSInfo := TVCSInfo.Create(Application);
  try
    VCSInfo.ModuleID := _StrToInt(ModuleID);
    VCSInfo.GetEnabled := True;
    if Assigned(lvHistory.Selected) then
      VCSInfo.SelectedRevisionID := StrToIntDef(lvHistory.Selected.SubItems[6], 0);
    VCSInfo.ShowModal;
  finally
    VCSInfo.Free;
  end;
end;

//------------------------------------------------------------------------------

function TVCSHistory.GetModuleName(MID: string): string;
begin
  Result := '';
  // Get Module name
  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_MODULE_NAME';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [MID]);
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

    Result := AppSrvClient1.Answer.Fields[0];
  end; // with DataModule1 do begin
end;

//------------------------------------------------------------------------------

procedure TVCSHistory.Compare1Click(Sender: TObject);
var
  RevisionKey, CompareFile: string;
begin
  if lvHistory.Selected = nil then
    Exit;
  CompareFile := GetModuleName(ModuleIDs.Values[ecbModules.Text]);
  if CompareFile = '' then
    Exit;
  ResolveFileFamilies(CompareFile);

  RevisionKey := lvHistory.Selected.SubItems[6];

  DoModuleCompare(CompareFile, lvHistory.Selected.SubItems[1],
    StrToIntDef(RevisionKey, 0));
end;

procedure TVCSHistory.AssignLabels1Click(Sender: TObject);
var
  ModuleName: string;
  ModuleID: string;
  Revision, RevisionID: string;
  FirstRevisionListItem: TListItem;
  FirstRevisionItem: PFirstRevisionItemRecord;
  List: TList;
begin
  inherited;

  if Assigned(lvHistory.Selected) and (lvHistory.Selected.SubItems.Count >= 7) then
  begin
    FirstRevisionListItem := GetFirstRevisionItemFromHistoryListView(lvHistory, lvHistory.Selected);

    ModuleName := ecbModules.Text;
    ModuleID := ModuleIDs.Values[ecbModules.Text];
    RevisionID := FirstRevisionListItem.SubItems[6];
    Revision := FirstRevisionListItem.Caption;

    if (ModuleID <> '') and (StrToIntDef(RevisionID, 0) > 0) then
    begin
      VCSAssignLabels := TVCSAssignLabels.Create(Application);
      try
        VCSAssignLabels.Left := Left + 40;
        VCSAssignLabels.Top := Top + 40;
        VCSAssignLabels.RevisionID := RevisionID;
        VCSAssignLabels.ModuleID := ModuleID;
        VCSAssignLabels.ModuleName := ExtractFileName(ModuleName) + ' V' + Revision;
        VCSAssignLabels.ShowModal;
      finally
        VCSAssignLabels.Free;
      end;
    end;
    List := FFirstRevisionItemList.LockList;
    try
      New(FirstRevisionItem);
      List.Add(FirstRevisionItem);
      FirstRevisionItem^.RevisionID := StrToIntDef(RevisionID, 0);
      FirstRevisionItem^.ItemIndex := FirstRevisionListItem.Index;
      FirstRevisionItem^.FillListViewCount := FFillListViewCount;
    finally
      FFirstRevisionItemList.UnlockList;
    end;
    LabelTimer.Enabled := True;
  end; //if Assigned(lvHistory.Selected) and ...
end;

procedure TVCSHistory.PopupMenu1Popup(Sender: TObject);
var
  HasItemsAndServerOkay, ItemSelected: Boolean;
begin
  inherited;
  HasItemsAndServerOkay := (lvHistory.Items.Count > 0) and (ServerUserID > 0);
  ItemSelected := Assigned(lvHistory.Selected);

  GetModule1.Enabled := HasItemsAndServerOkay;
  Compare1.Enabled := HasItemsAndServerOkay and ItemSelected;
  Comments1.Enabled := HasItemsAndServerOkay and ItemSelected;
  ChangeDescription2.Enabled := HasItemsAndServerOkay;
  AssignLabels1.Enabled := HasItemsAndServerOkay and ItemSelected;

  CheckCommentForExternalBugtrackerReference(lvHistory.Selected, BugtrackerItem, BugtrackerSep)
end;

procedure TVCSHistory.LabelTimerTimer(Sender: TObject);
var
  RevisionItem: PFirstRevisionItemRecord;
  SourceList: TList;
  CurrentRevisionLabels: string;
  CurrentItemNr: Integer;

  function IsListEmpty: Boolean;
  var
    List: TList;
  begin
    List := FFirstRevisionItemList.LockList;
    try
      Result := List.Count = 0;
    finally
      FFirstRevisionItemList.UnlockList;
    end;
  end;

begin
  if not FIsInTimer then
  begin
    FIsInTimer := True;
    try
      while not (IsListEmpty or FFormClosed) do
      begin
        SourceList := FFirstRevisionItemList.LockList;
        try
          if SourceList.Count > 0 then
          begin
            RevisionItem := SourceList[0];
            SourceList.Delete(0);
          end
          else
            RevisionItem := nil;
        finally
          FFirstRevisionItemList.UnlockList;
        end;
        if Assigned(RevisionItem) then
        begin
          if (RevisionItem^.FillListViewCount = FFillListViewCount) and (not FFormClosed) then
            CurrentRevisionLabels := GetRevisionLabelsStr(RevisionItem^.RevisionID);
          if (RevisionItem^.FillListViewCount = FFillListViewCount) and (not FFormClosed) then
          begin
            CurrentItemNr := RevisionItem^.ItemIndex;
            if lvHistory.Items[CurrentItemNr].SubItems.Count < 8 then
              lvHistory.Items[CurrentItemNr].SubItems.Add(CurrentRevisionLabels)
            else
              lvHistory.Items[CurrentItemNr].SubItems[7] := CurrentRevisionLabels;
          end;
          Dispose(RevisionItem);
        end;
      end;
      SourceList := FFirstRevisionItemList.LockList;
      try
        LabelTimer.Enabled := SourceList.Count > 0;
      finally
        FFirstRevisionItemList.UnlockList;
      end;
    finally
      FIsInTimer := False;
    end;
  end;
end;

procedure TVCSHistory.WndProc(var Message: TMessage);
begin
  if Message.Msg = WM_CLOSE then
    FFormClosed := True;
  inherited WndProc(Message);
end;

procedure TVCSHistory.BugtrackerItemClick(Sender: TObject);
begin
  OpenExternalBugtracker;
end;

procedure TVCSHistory.Button1Click(Sender: TObject);
begin
  FFormClosed := True;
  Close;
end;

end.
