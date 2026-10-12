(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: Std_ListView.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS: Thomas Huber (Thomas_D_Huber@gmx.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
Aug/04:
- USc: OwnSortItems doesn't support all TValueType's(but all so far used)
ToDo
- make Addtocurrentproject1Click, Removefromarchive1Click and RemoveBug1Click
  save against sorting
- refresh project manager if a module was checked in from here?  
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FreeVCS code to JEDI VCS
2003/03/05  THensle   - changes for "ConfigStorage" unit
2003/03/15  THuber    - compilerwarnings
2003/10/05  THuber    - form storage added
2003/12/28  USchuster - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use constant)
2004/08/04  USchuster - added possibility to close form while retrieving the projects
                        for locked modules (mantis #1989) and made retrieving of the
                        projects for locked modules save against sorting (mantis #2027)
                      - minor style cleaning (casing and comments)
2004/08/24  USchuster - added support for typed columns to ensure correct sorting (mantis #2032)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/10  USchuster - style cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/10/31  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
2005/06/28  USchuster - added compare and checkin function for own locked modules (mantis #3033)
2005/09/17  USchuster - added several functions to the locked modules popup menu (mantis #3048)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC3 was released ^^^^^^^^^^^^^^^^^^^^^^^^^^^
2005/12/30  USchuster - added "Undo Check Out" menu item to the locked modules popup menu (mantis #3381)
2006/12/10  USchuster - changes for menu bitmaps and added "View" function for the locked modules popup menu
2007/03/07  USchuster - replaced "Open Parent Folder" code by function ShellOpenParentFolder (mantis #4079)
2007/07/01  USchuster - changes for large fonts (contraints size depend now on PixelsPerInch; analog to Mantis #3710)
2008/03/15  USchuster - added "Line History" menu item to the locked modules popup menu
                      - "Open First Available Project" is now disabled when LVType = 5 (=called from MaintainUsers.pas)
2011/01/15  USchuster - changed font to Tahoma                      

-----------------------------------------------------------------------------*)

unit Std_ListView;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Menus, Buttons, Grids, ComCtrls,
  EnhListView, JVCSForms;

type
  TVCSStdListView = class(TJVCSForm)
    Panel1: TPanel;
    btnClose: TButton;
    popmDeserted: TPopupMenu;
    Addtocurrentproject1: TMenuItem;
    Removefromarchive1: TMenuItem;
    lblHint: TLabel;
    popmDeletedP: TPopupMenu;
    Restoreproject1: TMenuItem;
    N1: TMenuItem;
    Help: TSpeedButton;
    elv: TdfsEnhListView;
    popmCompDate: TPopupMenu;
    CopyModulesto1: TMenuItem;
    SelectAll1: TMenuItem;
    N2: TMenuItem;
    btnReport: TButton;
    popmUsedBugs: TPopupMenu;
    RemoveBug1: TMenuItem;
    ModuleHistory1: TMenuItem;
    N3: TMenuItem;
    popmSharedby: TPopupMenu;
    ShowsharedBy1: TMenuItem;
    popMCleanSeq: TPopupMenu;
    Movetorecyclebin1: TMenuItem;
    Delete1: TMenuItem;
    N4: TMenuItem;
    popmLabelUsedby: TPopupMenu;
    ShowTimer: TTimer;
    mnCompare: TMenuItem;
    mnCheckIn: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    mnOpenParentFolder: TMenuItem;
    mnOpenProject: TMenuItem;
    mnHistory: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    mnUndoCheckOut: TMenuItem;
    N10: TMenuItem;
    mnOpenFile: TMenuItem;
    mnLineHistory: TMenuItem;
    procedure btnCloseClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure elvDrawHeader(Control: TWinControl; var ACanvas: TCanvas;
      Index: Integer; var ARect: TRect; Selected: Boolean;
      var DefaultDrawing: Boolean);
    procedure elvDrawItem(Control: TWinControl; var ACanvas: TCanvas;
      Index: Integer; ARect: TRect; State: TOwnerDrawState;
      var DefaultDrawing, FullRowSelect: Boolean);
    procedure elvDrawSubItem(Control: TWinControl; var ACanvas: TCanvas;
      Index, SubItem: Integer; ARect: TRect; State: TOwnerDrawState;
      var DefaultDrawing: Boolean);
    procedure FormShow(Sender: TObject);
    procedure Addtocurrentproject1Click(Sender: TObject);
    procedure Removefromarchive1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Restoreproject1Click(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure CopyModulesto1Click(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);
    procedure btnReportClick(Sender: TObject);
    procedure RemoveBug1Click(Sender: TObject);
    procedure ModuleHistory1Click(Sender: TObject);
    procedure elvChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure ShowsharedBy1Click(Sender: TObject);
    procedure Movetorecyclebin1Click(Sender: TObject);
    procedure ShowTimerTimer(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure mnCompareClick(Sender: TObject);
    procedure mnCheckInClick(Sender: TObject);
    procedure popmSharedbyPopup(Sender: TObject);
    procedure mnOpenParentFolderClick(Sender: TObject);
    procedure mnOpenProjectClick(Sender: TObject);
    procedure mnHistoryClick(Sender: TObject);
    procedure mnUndoCheckOutClick(Sender: TObject);
    procedure mnOpenFileClick(Sender: TObject);
    procedure mnLineHistoryClick(Sender: TObject);
  private
    { Private declarations }
    FFormClosed: Boolean;
    FColumnTypeList: TList;
    FSelectedModuleID: Integer;
    FSelectedModuleName: string;
    FSelectedProjectID: Integer;
    FSelectedProjectName: string;
    FShowLineHistorySelected: Boolean;
    FOpenProjectSelected: Boolean;
    procedure AddModules(ModuleName: string);
    procedure RemoveModules(ModuleName: string);
    function GetListViewString: string;
    procedure ShowProjectforLockedModules;
    procedure OwnSortItems(Sender: TObject; Item1,
     Item2: TListItem; SortColumn: Integer; var SortAs: TSortAs;
     var CompResult: Integer);
    function GetSelectedModule(var AModuleID: Integer): Boolean;
    function GetSelectedModuleState(var AModuleID: Integer; var AMyModule: Boolean): Boolean;
  protected
    procedure WndProc(var Message: TMessage); override;
  public
    { Public declarations }
    MaxWidth,
    LVType,
    LVRepID,
    ItemID,
    HelpContextID: Integer;
    procedure AddListColumn(const NewCaption: string; const Number: Boolean);
    procedure AddTypedListColumn(const NewCaption: string; const AValueType: TValueType);
    procedure SetUpItems(Entrys: string);
    procedure SetUpHint(const Value: string);
    property SelectedModuleID: Integer read FSelectedModuleID;
    property SelectedModuleName: string read FSelectedModuleName;
    property SelectedProjectID: Integer read FSelectedProjectID;
    property SelectedProjectName: string read FSelectedProjectName;
    property ShowLineHistorySelected: Boolean read FShowLineHistorySelected;
    property OpenProjectSelected: Boolean read FOpenProjectSelected;
  end;

var
  VCSStdListView: TVCSStdListView;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  DBModule, VCSBase, VCSProcBase, Yes2allDlg, SelectFolder, CommCtrl,
  SimpleReport, History, ConfigStorage, JclStrings, JVCSGUIClientResources,
  TextComp, ChkInSingle, JVCSClientObj, ShellAPI, JVCSChkInOutCommon, JVCSDialogs,
  LoadModule, JVCSGUIClientImages;

{$R *.dfm}

procedure TVCSStdListView.FormCreate(Sender: TObject);
var
  ToolTipHandle: HWND;
begin
  try
    Constraints.MinHeight := MulDiv(210, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(240, PixelsPerInch, 96);
    // ListView Tooltips
    SendMessage(elv.Handle, LVM_SETEXTENDEDLISTVIEWSTYLE, LVS_EX_INFOTIP,
      LVS_EX_INFOTIP);
    ToolTipHandle := SendMessage(elv.Handle, LVM_GETTOOLTIPS, 0, 0);
    SendMessage(ToolTipHandle, TTM_SETDELAYTIME, TTDT_AUTOMATIC, 1);
    SendMessage(ToolTipHandle, TTM_SETDELAYTIME, TTDT_AUTOPOP, 3000);

    HelpContextID := 0;
    Addtocurrentproject1.Enabled := bProjectOpen;
    MaxWidth := Screen.Width - Left - 30;

    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    Screen.Cursors[cPopUpMCursor] := LoadCursor(hInstance, PChar('CURSORRM'));

    FFormClosed := False;
    FColumnTypeList := TList.Create;
    FSelectedModuleID := -1;
    FSelectedModuleName := '';
    FSelectedProjectID := -1;
    FSelectedProjectName := '';
    FShowLineHistorySelected := False;
    FOpenProjectSelected := False;
    {$IFDEF IDEDLL}
    N8.Visible := False;
    mnOpenProject.Visible := False;
    {$ENDIF IDEDLL}
    if ShowMenuBitmaps then
      popmSharedby.Images := GetToolImageList;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSStdListView.AddListColumn(const NewCaption: string;
  const Number: Boolean);
var
  NewColumn: TListColumn;
begin
  NewColumn := elv.Columns.Add;
  if Number then
    NewColumn.Alignment := taRightJustify
  else
    NewColumn.Alignment := taLeftJustify;
  NewColumn.AutoSize := False;
  NewColumn.Caption := NewCaption;
  NewColumn.ImageIndex := -1;
  NewColumn.MaxWidth := 0;
  NewColumn.MinWidth := 0;
  NewColumn.Width := 50;
end;

procedure TVCSStdListView.AddTypedListColumn(const NewCaption: string;
  const AValueType: TValueType);
begin
  AddListColumn(NewCaption, AValueType in [vaInt8, vaInt16, vaInt32, vaExtended,
    vaSingle, vaCurrency, vaInt64]);
  elv.OnSortItems := OwnSortItems;
  FColumnTypeList.Add(Pointer(AValueType));
end;

//------------------------------------------------------------------------------

procedure TVCSStdListView.SetUpHint(const Value: string);
begin
  lblHint.Caption := Value;
  lblHint.Hint := Value;
end;

//------------------------------------------------------------------------------

procedure TVCSStdListView.SetUpItems(Entrys: string);
var 
  I, J, LineMarker, Colmarker, ColumnsWidth, CurrTextWdt: Integer;
  CurrItemText, CurrLine: string;
  LVItem: TListItem;
begin
  elv.BeginUpdate;
  try
    while Pos('|', Entrys) <> 0 do 
    begin
      LineMarker := Pos('|', Entrys);
      CurrLine := Copy(Entrys, 1, LineMarker - 1);
      LVItem := elv.Items.Add;
      // caption
      Colmarker := Pos(';', CurrLine);
      CurrItemText := Copy(CurrLine, 1, Colmarker - 1);
      LVItem.Caption := CurrItemText;
      Delete(CurrLine, 1, Colmarker);
      // sub items
      while Pos(';', CurrLine) <> 0 do
      begin
        Colmarker := Pos(';', CurrLine);
        CurrItemText := Copy(CurrLine, 1, Colmarker - 1);
        LVItem.SubItems.Add(CurrItemText);
        Delete(CurrLine, 1, Colmarker);
      end; // while Pos(';', CurrLine) <> 0 do begin
      Delete(Entrys, 1, LineMarker);
    end; // while Pos('|', Entrys) <> 0 do begin
    // columns width
    with elv do
    begin
      for I := 0 to Columns.Count - 1 do 
      begin
        ColumnsWidth := Canvas.TextWidth(Columns[I].Caption) + 30;
        for J := 0 to Items.Count - 1 do
        begin
          if I = 0 then 
            CurrTextWdt := Canvas.TextWidth(Items[J].Caption)
          else 
            CurrTextWdt := Canvas.TextWidth(Items[J].SubItems[I - 1]);
          if (CurrTextWdt + 10) > ColumnsWidth then
            ColumnsWidth := CurrTextWdt + 10;
        end; // for J := 0 to Items.Count - 1 do begin
        Columns[I].Width := ColumnsWidth;
      end; // for I := 0 to Columns.Count - 1 do begin
    end; // with elv do begin
  finally
    elv.EndUpdate;
  end;

  // set up form width
  CurrTextWdt := 0;
  for I := 0 to elv.Columns.Count - 1 do
    CurrTextWdt := CurrTextWdt + elv.Columns[I].Width;
  CurrTextWdt := CurrTextWdt + 40;
  if CurrTextWdt > MaxWidth then
    CurrTextWdt := MaxWidth;
  Width := CurrTextWdt;
end;

//------------------------------------------------------------------------------

procedure TVCSStdListView.FormShow(Sender: TObject);
begin
  Help.Enabled := (HelpContextID <> 0);
  case LVType of
    1: 
      begin // deserted modules
        elv.PopUpMenu := popmDeserted;
        elv.Cursor := cPopUpMCursor;
        elv.MultiSelect := True;
      end;
    2: 
      begin // deleted projects
        elv.PopUpMenu := popmDeletedP;
        elv.Cursor := cPopUpMCursor;
        elv.MultiSelect := True;
      end;
    3:
      begin // compare date
        elv.PopUpMenu := popmCompDate;
        elv.Cursor := cPopUpMCursor;
        elv.MultiSelect := True;
      end;
    4:
      begin // bugs used by
        elv.PopUpMenu := popmUsedBugs;
        elv.Cursor := cPopUpMCursor;
        elv.MultiSelect := True;
      end;
    5:
      begin // module shared by
        elv.PopUpMenu := popmSharedby;
        elv.Cursor := cPopUpMCursor;
        elv.MultiSelect := False;
      end;
    6:
      begin // sequentiel backups
        elv.PopUpMenu := popMCleanSeq;
        elv.Cursor := cPopUpMCursor;
        elv.MultiSelect := True;
      end;
    7:
      begin // Label used by
          {elv.PopUpMenu := popmLabelUsedby;
          elv.Cursor := cPopUpMCursor;
          elv.MultiSelect := True;}
        elv.PopUpMenu := nil;
        //elv.Cursor := cPopUpMCursor;
        elv.MultiSelect := False;
      end;
    8:
      begin // module shared by (Multiple Projects)
        with elv.Columns.Add do
        begin
          Alignment := taLeftJustify;
          AutoSize := False;
          Caption := JVCSRES_Project;
          ImageIndex := -1;
          MaxWidth := 0;
          MinWidth := 0;
          Width := 150;
        end;
        elv.PopUpMenu := popmSharedby;
        elv.Cursor := cPopUpMCursor;
        elv.MultiSelect := False;
        ShowTimer.Enabled := True;
      end;
    else
      elv.PopUpMenu := nil;
  end; // case LVType of
end;

//------------------------------------------------------------------------------

procedure TVCSStdListView.ShowTimerTimer(Sender: TObject);
begin
  ShowTimer.Enabled := False;
  case LVType of
    //    1: // deserted modules
    //    2: // deleted projects
    //    3: // compare date
    //    4: // bugs used by
    //    5: // module shared by
    //    6: // sequentiel backups
    //    7: // Label used by
    8: 
      begin // module shared by (Multiple Projects)
        ShowProjectforLockedModules;
      end;
  end; // case LVType of
end;

//------------------------------------------------------------------------------

procedure TVCSStdListView.btnCloseClick(Sender: TObject);
begin
  FFormClosed := True;
  Close;
end;

//------------------------------------------------------------------------------

function TVCSStdListView.GetListViewString: string;
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
    with elv do 
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
      Result := Result + Format(JVCSRES_37d_entries46, [Items.Count]) + cr + cr;

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

    if lblHint.Caption <> '' then
      Result := Result + cr + lblHint.Caption + cr;

    Result := Result + cr + JVCSRES_Source58_ + sArchiveSource + cr +
      JVCSRES_JEDI_VCS_ + sProductVer + cProductInf + DateTimeToStr(Now) + cr;
  finally
    Screen.Cursor := crDefault;
    SetLength(oaColumnsWidth, 0);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSStdListView.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (HelpContextID <> 0) and (Key = VK_F1) then
  begin
    PerformHelpCommand(Application, HelpContextID);
  end;
  if Key = VK_ESCAPE then
  begin
    btnClose.Click;
    Key := 0;
  end;    
end;

//------------------------------------------------------------------------------

procedure TVCSStdListView.elvDrawHeader(Control: TWinControl;
  var ACanvas: TCanvas; Index: Integer; var ARect: TRect;
  Selected: Boolean; var DefaultDrawing: Boolean);
begin
  DefaultDrawing := True;
end;

//------------------------------------------------------------------------------

procedure TVCSStdListView.elvDrawItem(Control: TWinControl;
  var ACanvas: TCanvas; Index: Integer; ARect: TRect;
  State: TOwnerDrawState; var DefaultDrawing, FullRowSelect: Boolean);
begin
  DefaultDrawing := True;
  FullRowSelect := True;
end;

//------------------------------------------------------------------------------

procedure TVCSStdListView.elvDrawSubItem(Control: TWinControl;
  var ACanvas: TCanvas; Index, SubItem: Integer; ARect: TRect;
  State: TOwnerDrawState; var DefaultDrawing: Boolean);
begin
  DefaultDrawing := True;
end;

//------------------------------------------------------------------------------

procedure TVCSStdListView.Addtocurrentproject1Click(Sender: TObject);
var 
  I: Integer;
begin
  if elv.SelCount = 0 then 
    Exit;
  for I := 0 to elv.Items.Count - 1 do 
  begin
    if elv.Items[I].Selected then
      AddModules(elv.Items[I].SubItems[1] + elv.Items[I].SubItems[0]);
  end; // for I := 0 to elv.Items.Count - 1 do begin
  MessageBox(Handle, PChar(JVCSRES_You_must_refresh_40F541_the_project_manager_view_to_see_the_changes46),
    cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
end;

//------------------------------------------------------------------------------

procedure TVCSStdListView.AddModules(ModuleName: string);
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

procedure TVCSStdListView.Removefromarchive1Click(Sender: TObject);
var
  I, Yes2allRes: Integer;
  Yes2All, Skip: Boolean;
begin
  if elv.SelCount = 0 then 
    Exit;
  Yes2All := False;
  I := 0;
  repeat // until I >= elvModules.Items.Count;
  {  keine for - to Schleife, sonst wird nach
     löschen über die Liste hinausgelesen  }
    Inc(I); // Start mit 1, da bei gelöschtem Eintrag
    // in der gl. Zeile weitergesucht wird
    if elv.Items[I - 1].Selected then 
    begin
      Skip := False;
      if not Yes2All then
      begin
        VCSYes2AllDlg := TVCSYes2AllDlg.Create(Application);
        try
          if (elv.SelCount > 1) then 
            VCSYes2AllDlg.EnableYes2All(True)
          else 
            VCSYes2AllDlg.EnableYes2All(False);
          VCSYes2AllDlg.SetMessageText(Format(JVCSRES_Are_you_sure_you_want_to_remove_6037s62_4037s41_from_the_archive63,
            [elv.Items[I - 1].SubItems[0], JVCSRES_all_versions]) + #13#10 +
            JVCSRES_Warning33_This_process_is_not_reversible46);
          Yes2allRes := VCSYes2AllDlg.ShowModal;
        finally
          VCSYes2AllDlg.Free;
        end;
        case Yes2allRes of
          mrYes:;
          mrAll:
            Yes2All := True;
          mrNo:
            Skip := True;
          mrCancel: 
            Break;
        end; // case Yes2allRes of
      end; // if not Yes2All then begin
      if not Skip then 
      begin
        RemoveModules(elv.Items[I - 1].SubItems[1] + elv.Items[I - 1].SubItems[0]);
        elv.Items.Delete(I - 1);
        Dec(I); // gelöscht => eine Zeile zurück
      end;
    end; // if ListBox1.Selected[I] then begin
  until I >= elv.Items.Count;
end;

//------------------------------------------------------------------------------

procedure TVCSStdListView.RemoveModules(ModuleName: string);
begin
  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'REMOVE_MODULE';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [ServerProjectID]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(False, [elv.Selected.Caption]);
    AppSrvClient1.Request.WriteFields(False, [True]);
    AppSrvClient1.Request.WriteFields(False, [ModuleName]);
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
end;

//------------------------------------------------------------------------------

procedure TVCSStdListView.Restoreproject1Click(Sender: TObject);
begin
  if elv.Selected = nil then 
    Exit;
  if MessageBox(WindowHandle, PChar(Format(JVCSRES_Restore_project_6037s6263 + #13#10 +
    JVCSRES_Remember_that_JEDI_VCS_cannot_restore_the_links_between_this_project + #13#10 +
    JVCSRES_and_the_modules_recently_used_by_them46, [elv.Selected.SubItems[0]])),
    cMsgBoxCaption, MB_YESNOCANCEL or MB_ICONQUESTION) <> id_Yes then 
    Exit;

  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'RESTORE_PROJECT';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [elv.Selected.Caption]);
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
  elv.Selected.Delete;
end;

//------------------------------------------------------------------------------

procedure TVCSStdListView.btnReportClick(Sender: TObject);
var 
  ResultString, FileName: string;
  I: Integer;
begin
  ResultString := GetListViewString;
  if ResultString = '' then 
    Exit;

  VCSSimpleReport := TVCSSimpleReport.Create(Application);
  try
    VCSSimpleReport.RepID := 1000 + LVRepID;
    VCSSimpleReport.Left := Left + 60;
    VCSSimpleReport.Top := Top + 60;
    VCSSimpleReport.FullReportString := ResultString;
    case LVType of
      3: 
        begin // compare date
          VCSSimpleReport.SavePath := ExtractFileDir(sProjectName);
          FileName := 'CompareDate.txt';
        end;
      else
        begin
          VCSSimpleReport.SavePath := ExtractFileDir(sProjectName);
          FileName := Caption + '.txt';
        end;
    end; // case LVType of
    VCSSimpleReport.LineCount := elv.Items.Count + 8;
    for I := 1 to Length(FileName) do
      if FileName[I] in ['/', '\', '*', '?', '"', '<', '>', '|'] then
        FileName[I] := ' ';
    VCSSimpleReport.SaveFileName := FileName;
    VCSSimpleReport.ShowModal;
  finally
    VCSSimpleReport.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSStdListView.HelpClick(Sender: TObject);
var
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSStdListView.SelectAll1Click(Sender: TObject);
var 
  I: Integer;
begin
  for I := 0 to elv.Items.Count - 1 do
    elv.Items[I].Selected := True;
end;

//------------------------------------------------------------------------------

procedure TVCSStdListView.CopyModulesto1Click(Sender: TObject);
var 
  I: Integer;
  TargetPath: string;
begin
  if elv.SelCount = 0 then 
    Exit;

  VCSSelectFolder := TVCSSelectFolder.Create(Application);
  try
    VCSSelectFolder.SetStatusText(JVCSRES_38Copy_selected_modules_to);
    VCSSelectFolder.EnableRecursive(False);
    VCSSelectFolder.HelpContextID := 0;
    {VCSSelectFolder.SetInitialDir();}
    VCSSelectFolder.ShowModal;
    TargetPath := VCSSelectFolder.Selection;
  finally
    VCSSelectFolder.Free;
  end;

  if TargetPath = '' then
    Exit;
  TargetPath := SetBackSlash(AnsiLowerCase(TargetPath));

  for I := 0 to elv.Items.Count - 1 do 
  begin
    if elv.Items[I].Selected then 
    begin
      CopyFile(PChar(elv.Items[I].Caption),
        PChar(TargetPath + ExtractFileName(elv.Items[I].Caption)), False);
      elv.Items[I].Selected := False;
    end;
  end; // for I := 0 to elv.Items.Count - 1 do begin
end;

//------------------------------------------------------------------------------

procedure TVCSStdListView.RemoveBug1Click(Sender: TObject);
var
  I: Integer;
begin
  if elv.Selected = nil then
    Exit;
  if MessageBox(WindowHandle, PChar(Format(JVCSRES_Are_you_sure_you_want_to_remove_bug_6037s62 + #13#10 +
    JVCSRES_from_6037s6263,
    [Caption, Format(JVCSRES_37d_selected_projects47modules, [elv.SelCount])])), cMsgBoxCaption,
    MB_YESNOCANCEL or MB_ICONQUESTION) <> id_Yes then 
    Exit;

  I := 0;
  repeat // until I >= elvModules.Items.Count;
  {  keine for - to Schleife, sonst wird nach
     löschen über die Liste hinausgelesen  }
    Inc(I); // Start mit 1, da bei gelöschtem Eintrag
    // in der gl. Zeile weitergesucht wird
    if elv.Items[I - 1].Selected then
    begin
      with DataModule1 do 
      begin
        AppSrvClient1.Request.Rewrite;
        AppSrvClient1.FunctionCode := 'ASSIGN_REMOVE_BUG';
        AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
        AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
        AppSrvClient1.Request.WriteFields(True, [elv.Items[I - 1].SubItems[1]]);
        AppSrvClient1.Request.WriteFields(False, [ItemID]);
        AppSrvClient1.Request.WriteFields(False, [(elv.Items[I - 1].Caption = JVCSRES_Project)]);
        AppSrvClient1.Request.WriteFields(False, [False]); // add the bug?
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
      elv.Items.Delete(I - 1);
      Dec(I); // gelöscht => eine Zeile zurück
    end; // if ListBox1.Selected[I] then begin
  until I >= elv.Items.Count;
end;

//------------------------------------------------------------------------------

procedure TVCSStdListView.ModuleHistory1Click(Sender: TObject);
begin
  if elv.Selected = nil then 
    Exit;
  VCSHistory := TVCSHistory.Create(Application);
  try
    VCSHistory.ModuleName := elv.Selected.SubItems[1] + elv.Selected.SubItems[0];
    VCSHistory.ModuleID := _StrToInt(elv.Selected.Caption);
    VCSHistory.ShowModal;
  finally
    VCSHistory.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSStdListView.elvChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  ModuleHistory1.Enabled := (elv.SelCount = 1);
end;

//------------------------------------------------------------------------------

procedure TVCSStdListView.ShowsharedBy1Click(Sender: TObject);
var 
  ResultString: string;
  VCSStdListView2: TVCSStdListView;
begin
  if elv.Selected = nil then 
    Exit;
  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_SHARED_BY';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [elv.Selected.SubItems[0]]);
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
    VCSStdListView2.Caption := elv.Selected.Caption;
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

//------------------------------------------------------------------------------

procedure TVCSStdListView.Movetorecyclebin1Click(Sender: TObject);
var 
  Msg, DeletePath: string;
  I: Integer;
begin
  if elv.SelCount = 0 then 
    Exit;
  if Sender = Movetorecyclebin1 then
    Msg := JVCSRES_Are_you_sure_you_want_to_move_the_selected_backup_files + #13#10 +
      JVCSRES_to_the_recycle_bin63
  else
    Msg := JVCSRES_Are_you_sure_you_want_to_delete_the_selected_backup_files63;

  if MessageBox(WindowHandle, PChar(Msg),
    cMsgBoxCaption, MB_YESNOCANCEL or MB_DEFBUTTON2 or MB_ICONQUESTION) <> id_Yes then
    Exit;

  DeletePath := Copy(lblHint.Caption, 1, Pos(' /(', lblHint.Caption) - 1);

  I := 0;
  repeat // until I >= elvModules.Items.Count;
  {  keine for - to Schleife, sonst wird nach
     löschen über die Liste hinausgelesen  }
    Inc(I); // Start mit 1, da bei gelöschtem Eintrag
    // in der gl. Zeile weitergesucht wird
    if elv.Items[I - 1].Selected then 
    begin
      if Sender = Movetorecyclebin1 then
        DeleteToRecycleBin(WindowHandle, DeletePath + elv.Items[I - 1].Caption)
      else
        DeleteFile(DeletePath + elv.Items[I - 1].Caption);
      elv.Items.Delete(I - 1);
      Dec(I); // gelöscht => eine Zeile zurück
    end; // if elv.Items[I - 1].Selected then begin
  until I >= elv.Items.Count;
end;

//------------------------------------------------------------------------------

procedure TVCSStdListView.ShowProjectforLockedModules;
var 
  ResultString: string;
  I: Integer;
  ItemList: TList;
  CurrentItem: TListItem;
begin
  ItemList := TList.Create;
  try
    for I := 0 to elv.Items.Count - 1 do
      ItemList.Add(elv.Items[I]);
    I := 0;
    while (I < ItemList.Count) and (not FFormClosed) do
    begin
      CurrentItem := TListItem(ItemList[I]);
      with DataModule1 do
      begin
        AppSrvClient1.Request.Rewrite;
        AppSrvClient1.FunctionCode := 'GET_SHARED_BY';
        AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
        AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
        AppSrvClient1.Request.WriteFields(True, [CurrentItem.SubItems[0]]);
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
          ResultString := ResultString + AppSrvClient1.Answer.Fields[1] + ', ';
          AppSrvClient1.Answer.Next;
        end;
      end; // with DataModule1 do begin
      CurrentItem.SubItems.Add(ResultString);
      Inc(I);
    end; // while (I < ItemList.Count) and (not FFormClosed) do
  finally
    ItemList.Free;
  end;
end;

procedure TVCSStdListView.FormActivate(Sender: TObject);
begin
  jvcsLoadFormPosSize(Self);
end;

procedure TVCSStdListView.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  jvcsSaveFormPosSize(Self);
end;

procedure TVCSStdListView.WndProc(var Message: TMessage);
begin
  if Message.Msg = WM_CLOSE then
    FFormClosed := True;
  inherited WndProc(Message);
end;

procedure TVCSStdListView.OwnSortItems(Sender: TObject; Item1,
  Item2: TListItem; SortColumn: Integer; var SortAs: TSortAs;
  var CompResult: Integer);
var
  ColumnValueType: TValueType;
  Str1, Str2: string;
begin
  CompResult := 0;
  if (SortColumn >= -1) and ((SortColumn + 1) < FColumnTypeList.Count) then
  begin
    ColumnValueType := TValueType(FColumnTypeList[SortColumn + 1]);
    if SortColumn = -1 then
    begin
      Str1 := Item1.Caption;
      Str2 := Item2.Caption;
    end
    else
    begin
      Str1 := Item1.SubItems[SortColumn];
      Str2 := Item2.SubItems[SortColumn];
    end;
    case ColumnValueType of
      vaString:
        CompResult := AnsiCompareStr(Str1, Str2);
      vaInt64:
        begin
          if Str1 <> Str2 then
          begin
            // remove all thousand separators
            Str1 := JclStrings.StrRemoveChars(Str1, [ThousandSeparator]);
            Str2 := JclStrings.StrRemoveChars(Str2, [ThousandSeparator]);
            if StrToInt64Def(Str1, 0) > StrToInt64Def(Str2, 0) then
              CompResult := 1
            else
              CompResult := -1;
          end;
        end;
      vaDate:
        CompResult := CompareDateTimeStrs(Str1, Str2);
    end;
  end;
end;

procedure TVCSStdListView.FormDestroy(Sender: TObject);
begin
  FColumnTypeList.Free;
end;

function TVCSStdListView.GetSelectedModule(var AModuleID: Integer): Boolean;
begin
  AModuleID := -1;
  if Assigned(elv.Selected) then
    AModuleID := StrToIntDef(elv.Selected.SubItems[0], 0);
  Result := AModuleID > 0;
end;

function TVCSStdListView.GetSelectedModuleState(var AModuleID: Integer; var AMyModule: Boolean): Boolean;
var
  OwnerColumn: Integer;
begin
  AModuleID := -1;
  AMyModule := False;
  if Assigned(elv.Selected) then
  begin
    AModuleID := StrToIntDef(elv.Selected.SubItems[0], 0);
    OwnerColumn := -1;
    if (elv.Selected.SubItems.Count >= 2) and (elv.Columns.Count >= 3) and
      (elv.Columns[elv.Columns.Count - 2].Caption = JVCSRES_Owner) then
      OwnerColumn := elv.Columns.Count - 3;
    AMyModule := (LVType = 8) and ((OwnerColumn = -1) or (elv.Selected.SubItems[OwnerColumn] = sCurrentUser));
  end;
  Result := (AModuleID > 0) and AMyModule;
end;

procedure TVCSStdListView.mnCompareClick(Sender: TObject);
var
  SelectedModuleID: Integer;
  SelectedModuleFileName: string;
  CurrentProjectState: TGUIClientProjectState;
  GetModuleName: TJVCSGetModuleName;
begin
  if GetSelectedModule(SelectedModuleID) then
  begin
    CurrentProjectState := SaveProjectState;
    try
      if OpenFirstModuleProject(SelectedModuleID, 1) then
      begin
        GetModuleName := TJVCSGetModuleName.Create(nil);
        try
          GetModuleName.ModuleID := SelectedModuleID;
          DataModule1.ClientObjectSendRequest(GetModuleName);
          SelectedModuleFileName := GetModuleName.ModuleName;
        finally
          GetModuleName.Free;
        end;
        DoModuleCompare(SelectedModuleFileName);
      end;
    finally
      RestoreProjectState(CurrentProjectState);
    end;
  end;
end;

procedure TVCSStdListView.mnCheckInClick(Sender: TObject);
var
  SelectedModuleID: Integer;
  DummyBool: Boolean;
  CurrentProjectState: TGUIClientProjectState;
  GetRevisionListById: TJVCSGetRevisionListById;
  CheckedOut: Boolean;
begin
  if GetSelectedModuleState(SelectedModuleID, DummyBool) then
  begin
    CurrentProjectState := SaveProjectState;
    try
      if OpenFirstModuleProject(SelectedModuleID, 2) then
      begin
        VCSChkInSingle := TVCSChkInSingle.Create(Application);
        try
          VCSChkInSingle.SelectModuleList.Add('>' + IntToStr(SelectedModuleID));
          VCSChkInSingle.AsChild := True;
          VCSChkInSingle.ShowModal;
          if VCSChkInSingle.ArchiveChanged then
          begin
            //check module state and remove from listview if it is not longer locked
            GetRevisionListById := TJVCSGetRevisionListById.Create(nil);
            try
              GetRevisionListById.ProjectID := ServerProjectID;
              GetRevisionListById.ModuleID := SelectedModuleID;
              DataModule1.ClientObjectSendRequest(GetRevisionListById);
              CheckedOut := (GetRevisionListById.OutputItemCount > 0) and
                (GetRevisionListById.OutputItems[Pred(GetRevisionListById.OutputItemCount)].Owner <> '');
              if not CheckedOut then
                elv.Selected.Delete;
            finally
              GetRevisionListById.Free;
            end;
          end;
        finally
          VCSChkInSingle.Free;
        end;
      end;
    finally
      RestoreProjectState(CurrentProjectState);
    end;
  end;
end;

procedure TVCSStdListView.popmSharedbyPopup(Sender: TObject);
var
  DummyInt: Integer;
  DummyBool: Boolean;
begin
  mnCheckIn.Enabled := GetSelectedModuleState(DummyInt, DummyBool);
  mnUndoCheckOut.Enabled := mnCheckIn.Enabled;
  mnCompare.Enabled := GetSelectedModule(DummyInt);
  mnOpenParentFolder.Enabled := mnCompare.Enabled;
  mnOpenProject.Enabled := mnCompare.Enabled and (LVType = 8) and (not ((LVRepID = 2000) or (LVRepID = 2002)));
  mnHistory.Enabled := mnCompare.Enabled;
  mnLineHistory.Enabled := mnCompare.Enabled and (LVType = 8);
  ShowsharedBy1.Enabled := mnCompare.Enabled;
  mnOpenFile.Enabled := mnCompare.Enabled;
end;

procedure TVCSStdListView.mnOpenParentFolderClick(Sender: TObject);
var
  SelectedModuleID: Integer;
  CurrentProjectState: TGUIClientProjectState;
  GetModuleName: TJVCSGetModuleName;
  SelectedModuleFileName: string;
begin
  if GetSelectedModule(SelectedModuleID) then
  begin
    CurrentProjectState := SaveProjectState;
    try
      if OpenFirstModuleProject(SelectedModuleID, 1) then
      begin
        GetModuleName := TJVCSGetModuleName.Create(nil);
        try
          GetModuleName.ModuleID := SelectedModuleID;
          DataModule1.ClientObjectSendRequest(GetModuleName);
          SelectedModuleFileName := GetModuleName.ModuleName;
        finally
          GetModuleName.Free;
        end;
        ShellOpenParentFolder(SelectedModuleFileName);
      end;
    finally
      RestoreProjectState(CurrentProjectState);
    end;
  end;
end;

procedure TVCSStdListView.mnOpenProjectClick(Sender: TObject);
{$IFNDEF IDEDLL}
var
  SelectedModuleID: Integer;
  CurrentProjectState: TGUIClientProjectState;
{$ENDIF ~IDEDLL}
begin
  {$IFNDEF IDEDLL}
  if GetSelectedModule(SelectedModuleID) then
  begin
    CurrentProjectState := SaveProjectState;
    try
      if OpenFirstModuleProject(SelectedModuleID, 1) then
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

procedure TVCSStdListView.mnHistoryClick(Sender: TObject);
var
  SelectedModuleID: Integer;
  SelectedModuleFileName: string;
  CurrentProjectState: TGUIClientProjectState;
  GetModuleName: TJVCSGetModuleName;
begin
  if GetSelectedModule(SelectedModuleID) then
  begin
    CurrentProjectState := SaveProjectState;
    try
      if OpenFirstModuleProject(SelectedModuleID, 1) then
      begin
        GetModuleName := TJVCSGetModuleName.Create(nil);
        try
          GetModuleName.ModuleID := SelectedModuleID;
          DataModule1.ClientObjectSendRequest(GetModuleName);
          SelectedModuleFileName := GetModuleName.ModuleName;
        finally
          GetModuleName.Free;
        end;
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

procedure TVCSStdListView.mnUndoCheckOutClick(Sender: TObject);
var
  SelectedModuleID, CurrentRevisionID: Integer;
  DummyBool: Boolean;
  CurrentProjectState: TGUIClientProjectState;
  GetRevisionListById: TJVCSGetRevisionListById;
  CheckedOut: Boolean;
  UndoCheckOutModuleList: TUndoCheckOutModuleList;
  UndoCheckedOutModule: TUndoCheckOutModule;
  GetModuleName: TJVCSGetModuleName;
  SelectedModuleFileName: string;
begin
  if GetSelectedModuleState(SelectedModuleID, DummyBool) then
  begin
    CurrentProjectState := SaveProjectState;
    try
      if OpenFirstModuleProject(SelectedModuleID, 2) then
      begin
        GetModuleName := TJVCSGetModuleName.Create(nil);
        try
          GetModuleName.ModuleID := SelectedModuleID;
          DataModule1.ClientObjectSendRequest(GetModuleName);
          SelectedModuleFileName := GetModuleName.ModuleName;
        finally
          GetModuleName.Free;
        end;
        UndoCheckOutModuleList := TUndoCheckOutModuleList.Create;
        try
          CurrentRevisionID := -1;
          GetRevisionListById := TJVCSGetRevisionListById.Create(nil);
          try
            GetRevisionListById.ProjectID := ServerProjectID;
            GetRevisionListById.ModuleID := SelectedModuleID;
            DataModule1.ClientObjectSendRequest(GetRevisionListById);
            if GetRevisionListById.OutputItemCount > 0 then
              CurrentRevisionID := GetRevisionListById.OutputItems[Pred(GetRevisionListById.OutputItemCount)].RevisionID;
          finally
            GetRevisionListById.Free;
          end;
          if CurrentRevisionID > 0 then
          begin
            UndoCheckedOutModule := UndoCheckOutModuleList.Add;
            UndoCheckedOutModule.Name := ExtractFileName(SelectedModuleFileName);
            UndoCheckedOutModule.Path := ExtractFilePath(SelectedModuleFileName);
            UndoCheckedOutModule.ProjectID := ServerProjectID;
            UndoCheckedOutModule.ModuleID := SelectedModuleID;
            UndoCheckedOutModule.RevisionID := CurrentRevisionID;
            UndoCheckedOutModule.OwnerName := sCurrentUser;
          end
          else
            WarnMessageBox(Format(JVCSRES_Undo_Check_Out_of_6037s62_failed33, [SelectedModuleFileName]));
          if UndoCheckOutModuleList.Count > 0 then
          begin
            UndoCheckout(UndoCheckOutModuleList, False, DummyBool, WindowHandle);
            //check module state and remove from listview if it is not longer locked
            GetRevisionListById := TJVCSGetRevisionListById.Create(nil);
            try
              GetRevisionListById.ProjectID := ServerProjectID;
              GetRevisionListById.ModuleID := SelectedModuleID;
              DataModule1.ClientObjectSendRequest(GetRevisionListById);
              CheckedOut := (GetRevisionListById.OutputItemCount > 0) and
                (GetRevisionListById.OutputItems[Pred(GetRevisionListById.OutputItemCount)].Owner <> '');
              if not CheckedOut then
                elv.Selected.Delete;
            finally
              GetRevisionListById.Free;
            end;
          end;
        finally
          UndoCheckOutModuleList.Free;
        end;
      end;
    finally
      RestoreProjectState(CurrentProjectState);
    end;
  end;
end;

procedure TVCSStdListView.mnOpenFileClick(Sender: TObject);
var
  SelectedModuleID: Integer;
  SelectedModuleFileName, Mess: string;
  CurrentProjectState: TGUIClientProjectState;
  GetModuleName: TJVCSGetModuleName;
begin
  if GetSelectedModule(SelectedModuleID) then
  begin
    CurrentProjectState := SaveProjectState;
    try
      if OpenFirstModuleProject(SelectedModuleID, 1) then
      begin
        GetModuleName := TJVCSGetModuleName.Create(nil);
        try
          GetModuleName.ModuleID := SelectedModuleID;
          DataModule1.ClientObjectSendRequest(GetModuleName);
          SelectedModuleFileName := GetModuleName.ModuleName;
        finally
          GetModuleName.Free;
        end;
        ViewTheModule(WindowHandle, SelectedModuleFileName, Mess);
        BringWindowToTop(WindowHandle);
        BringWindowToTop(Self.Handle);
      end;
    finally
      RestoreProjectState(CurrentProjectState);
    end;
  end;
end;

procedure TVCSStdListView.mnLineHistoryClick(Sender: TObject);
var
  LocalSelectedModuleID: Integer;
  SelectedModuleFileName: string;
  CurrentProjectState: TGUIClientProjectState;
  GetModuleName: TJVCSGetModuleName;
begin
  if GetSelectedModule(LocalSelectedModuleID) then
  begin
    CurrentProjectState := SaveProjectState;
    try
      if OpenFirstModuleProject(LocalSelectedModuleID, 1) then
      begin
        GetModuleName := TJVCSGetModuleName.Create(nil);
        try
          GetModuleName.ModuleID := LocalSelectedModuleID;
          DataModule1.ClientObjectSendRequest(GetModuleName);
          SelectedModuleFileName := GetModuleName.ModuleName;
        finally
          GetModuleName.Free;
        end;
        FSelectedModuleID := LocalSelectedModuleID;
        FSelectedModuleName := SelectedModuleFileName;
        FShowLineHistorySelected := True;
        Close;
      end;
    finally
      RestoreProjectState(CurrentProjectState);
    end;
  end;
end;

end.
