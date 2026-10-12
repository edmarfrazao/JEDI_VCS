(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: DirWatch.pas

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
2003/03/05  THensle   - changes for "ConfigStorage" unit
2003/12/28  USchuster - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use constant)
2004/07/12  THuber    - #1960 faster loading of huge selections, automatic sort
                              was called on every item added
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/31  USchuster - style cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/11/05  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
2005/10/16  USchuster - it is now possible to sort the listview by state (mantis #3268)
                      - minor speed improvement(OldFiles are now sorted)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 final released ^^^^^^^^^^^^^^^^^^^^^^^^^^
2006/03/26  USchuster - as of now the buttons got a ModalResult to avoid mantis #3596
2007/07/01  USchuster - changes for large fonts (contraints and default size depend now on PixelsPerInch; analog to Mantis #3710)
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit DirWatch;

{$I jedi.inc}
{$I compopt.inc}

{$IFDEF DEBUG}
  {.$DEFINE UUDEBUG}
{$ENDIF DEBUG}

interface

uses
  {$IFDEF DEBUG}
  JclDebug,
  {$ENDIF DEBUG}
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ImgList, ComCtrls, EnhListView, Buttons, StdCtrls, ExtCtrls, Menus, JVCSForms;

type
  TVCSDirWatch = class(TJVCSForm)
    SysImageList: TImageList;
    StateImageList: TImageList;
    Panel1: TPanel;
    btnClose: TButton;
    btnAdd: TButton;
    Help: TSpeedButton;
    btnReport: TButton;
    elvFiles: TdfsEnhListView;
    PopupMenu1: TPopupMenu;
    SelectAll1: TMenuItem;
    UnselectAll1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure lvFilesMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure HelpTopics1Click(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure btnReportClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);
    procedure UnselectAll1Click(Sender: TObject);
    procedure elvFilesKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure elvFilesSortItems(Sender: TObject; Item1, Item2: TListItem;
      SortColumn: Integer; var SortAs: TSortAs; var CompResult: Integer);
  private
    { Private declarations }
    procedure GetSelectCount;
    function GetListViewString: string;
  public
    { Public declarations }
    OldFiles,
    NewFiles: TStringList;
  end;

var
  VCSDirWatch: TVCSDirWatch;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  ShellAPI, VCSBase, VCSProcBase, SimpleReport, ConfigStorage, JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSDirWatch.FormCreate(Sender: TObject);
var
  sfi: TSHFileInfo;
  DlgTop,
  DlgLeft,
  DlgWidth,
  DlgHeight: Integer;
begin
  try
    Constraints.MinHeight := MulDiv(250, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(350, PixelsPerInch, 96);
    if not jvcsReadWindowPosAndSize(sBaseRegistryKey + crbWindows, 'DirWatch',
      DlgTop, DlgLeft, DlgWidth, DlgHeight) then
    begin
      DlgTop := (Screen.Height - Height) div 2;
      DlgLeft := (Screen.Width - Width) div 2;
      DlgWidth := MulDiv(350, PixelsPerInch, 96);
      DlgHeight := MulDiv(250, PixelsPerInch, 96);
    end;
    Top := DlgTop;
    Left := DlgLeft;
    Width := DlgWidth;
    Height := DlgHeight;

    with elvFiles do
    begin
      Columns[0].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'DirWatch_Col1.0', 40);
      Columns[1].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'DirWatch_Col1.1', 150);
      Columns[2].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'DirWatch_Col1.2', 70);
      Columns[3].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'DirWatch_Col1.3', 250);
    end;

    {$IFDEF CUSTOMDRIVE}
    sDriveSubst := RegReadString(HKCU, sBaseRegistryKey + crbProjects +
      ExtractFileName(sProjectName), 'LocalDrive', '');
    if (sDriveSubst = '') then
      sDriveSubst := RegReadString(HKCU, sBaseRegistryKey + crbOptions,
        'LocalDrive', '');
    {$ENDIF CUSTOMDRIVE}

    OldFiles := TStringList.Create;
    OldFiles.Sorted := True;
    NewFiles := TStringList.Create;
    //Systemsymbole in eine TImageList-Komponente einlesen
    SysImageList.Handle := SHGetFileInfo('', 0, sfi, SizeOf(TSHFileInfo),
      SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
    SysImageList.ShareImages := True;

    Screen.Cursors[cPopUpMCursor] := LoadCursor(hInstance, PChar('CURSORRM'));
    elvFiles.Cursor := cPopUpMCursor;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSDirWatch.FormShow(Sender: TObject);
var
  I: Integer;
  NewItem: TListItem;
  sfi: TSHFileInfo;
begin
  Screen.Cursor := crHourGlass;
  // prevent calling sorting during fill
  elvFiles.AutoResort := False;
  try
    elvFiles.BeginUpdate;
    try
      // additional tuning for huge selection possible,
      // -> cache filetype/icon handling
      for I := 0 to NewFiles.Count - 1 do
      begin
        NewItem := elvFiles.Items.Add;
        NewItem.SubItems.Add(ExtractFileName(NewFiles[I]));
        SHGetFileInfo(PChar(NewFiles[I]), 0, sfi,
          SizeOf(sfi), SHGFI_SYSICONINDEX or SHGFI_SMALLICON or SHGFI_DISPLAYNAME);
        NewItem.ImageIndex := sfi.IIcon;
        if OldFiles.IndexOf(NewFiles[I]) > -1 then
        begin
          NewItem.StateIndex := 3;
          NewItem.Caption := JVCSRES_Project_member;
        end
        else
        begin
          NewItem.StateIndex := 0;
          NewItem.Caption := JVCSRES_No_project_member;
        end;
        NewItem.SubItems.Add(GetFileType(NewFiles[I]));
        NewItem.SubItems.Add(ExtractFilePath(NewFiles[I]));
      end;
    finally
      elvFiles.EndUpdate;
    end;
  finally
    elvFiles.AutoResort := True;
    elvFiles.Resort;
    GetSelectCount;
    Screen.Cursor := crDefault;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSDirWatch.btnAddClick(Sender: TObject);
var
  I: Integer;
begin
  NewFiles.Clear;
  // form is closing, there is no need for a final resort!
  elvFiles.AutoResort := False;
  with elvFiles do
  begin
    for I := 0 to Items.Count - 1 do
    begin
      if Items[I].StateIndex = 1 then
        NewFiles.Add(Items[I].SubItems[2] + Items[I].SubItems[0]);
    end; // for I := 0 to Items.Count - 1 do begin
  end; // with elvFiles do begin
end;

//------------------------------------------------------------------------------

procedure TVCSDirWatch.btnCloseClick(Sender: TObject);
begin
  NewFiles.Clear;
end;

//------------------------------------------------------------------------------

procedure TVCSDirWatch.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  jvcsWriteWindowPosAndSize(sBaseRegistryKey + crbWindows, 'DirWatch',
    Top, Left, Width, Height);

  with elvFiles do
  begin
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'DirWatch_Col1.0',
      Columns[0].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'DirWatch_Col1.1',
      Columns[1].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'DirWatch_Col1.2',
      Columns[2].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'DirWatch_Col1.3',
      Columns[3].Width);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSDirWatch.FormDestroy(Sender: TObject);
begin
  OldFiles.Free;
  NewFiles.Free;
end;

//------------------------------------------------------------------------------

procedure TVCSDirWatch.lvFilesMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var 
  HitTest: THitTests;
  HitItem: TListItem;
begin
  HitTest := elvFiles.GetHitTestInfoAt(X, Y);
  if (Button = mbLeft) and (htOnStateIcon in HitTest) then 
  begin
    HitItem := elvFiles.GetItemAt(X, Y);
    if (HitItem.StateIndex = 0) or (HitItem.StateIndex = 1) then 
    begin
      if HitItem.StateIndex = 0 then 
        HitItem.StateIndex := 1 
      else
        HitItem.StateIndex := 0;
      GetSelectCount;
    end; // if (HitItem.StateIndex = 0) or (HitItem.StateIndex = 1) then begin
  end; // if (Button = mbLeft) and (htOnStateIcon in HitTest) then begin
end;

//------------------------------------------------------------------------------

procedure TVCSDirWatch.GetSelectCount;
var 
  I, NewFiles, SelFiles: Integer;
  ItemsSelected: Boolean;
begin
  NewFiles := 0;
  SelFiles := 0;
  ItemsSelected := False;
  for I := 0 to elvFiles.Items.Count - 1 do 
  begin
    if elvFiles.Items[I].StateIndex = 1 then 
    begin
      ItemsSelected := True;
      Inc(SelFiles);
    end; // if lvUnits.Items[I].StateIndex = 1 then begin
    if elvFiles.Items[I].StateIndex <> 3 then
      Inc(NewFiles);
  end; // for I := 0 to lvUnits.Items.Count - 1 do begin
  btnAdd.Enabled := ItemsSelected;
  Caption := Format(JVCSRES_Scan_Result_45_37d_files_45_37d_new_files_45_37d_selected,
    [elvFiles.Items.Count, NewFiles, SelFiles]);
end;

//------------------------------------------------------------------------------

function TVCSDirWatch.GetListViewString: string;
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
    with elvFiles do 
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

procedure TVCSDirWatch.btnReportClick(Sender: TObject);
var 
  ResultString: string;
begin
  ResultString := GetListViewString;
  if ResultString = '' then
    Exit;

  VCSSimpleReport := TVCSSimpleReport.Create(Application);
  try
    VCSSimpleReport.RepID := 3;  
    VCSSimpleReport.Left := Left + 60;
    VCSSimpleReport.Top := Top + 60;
    VCSSimpleReport.FullReportString := ResultString;
    VCSSimpleReport.SavePath := ExtractFileDir(sProjectName);
    VCSSimpleReport.SaveFileName := 'DirScan.txt';
    VCSSimpleReport.LineCount := elvFiles.Items.Count + 8;
    VCSSimpleReport.ShowModal;
  finally
    VCSSimpleReport.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSDirWatch.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    btnClose.Click;
    Key := 0;
  end;
  if Key = VK_F1 then 
  begin
    PerformHelpCommand(Application, IDH_Used_Units);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSDirWatch.HelpTopics1Click(Sender: TObject);
begin
  PerformHelpCommand(Application, IDH_Add_PM);
end;

//------------------------------------------------------------------------------

procedure TVCSDirWatch.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSDirWatch.SelectAll1Click(Sender: TObject);
var 
  I: Integer;
begin
  for I := 0 to elvFiles.Items.Count - 1 do
    if elvFiles.Items[I].StateIndex <> 3 then
      elvFiles.Items[I].StateIndex := 1;
  GetSelectCount;
end;

//------------------------------------------------------------------------------

procedure TVCSDirWatch.UnselectAll1Click(Sender: TObject);
var 
  I: Integer;
begin
  for I := 0 to elvFiles.Items.Count - 1 do
    if elvFiles.Items[I].StateIndex <> 3 then
      elvFiles.Items[I].StateIndex := 0;
  GetSelectCount;
end;

//------------------------------------------------------------------------------

procedure TVCSDirWatch.elvFilesKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (elvFiles.Selected <> nil) and (Key = VK_SPACE) then 
  begin
    if elvFiles.Selected.StateIndex > 1 then 
      Exit;
    if elvFiles.Selected.StateIndex = 0 then 
      elvFiles.Selected.StateIndex := 1
    else 
      elvFiles.Selected.StateIndex := 0;
    GetSelectCount;
  end;
end;

procedure TVCSDirWatch.elvFilesSortItems(Sender: TObject; Item1,
  Item2: TListItem; SortColumn: Integer; var SortAs: TSortAs;
  var CompResult: Integer);
begin
  if SortColumn = -1 then
    CompResult := Item1.StateIndex - Item2.StateIndex
  else
  if (SortColumn >= 0) and (SortColumn <= 2) then
    CompResult := AnsiCompareStr(Item1.SubItems[SortColumn], Item2.SubItems[SortColumn]);
  if (CompResult = 0) and (SortColumn <> 0) then
    CompResult := AnsiCompareStr(Item1.SubItems[0], Item2.SubItems[0]);
end;

end.
