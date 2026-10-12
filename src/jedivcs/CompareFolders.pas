(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: CompareFolders.pas

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
2003/03/03  THensle   - changes for "ConfigStorage" unit
2003/03/09  USchuster - exchanged TjvMruList with TJVCSMruList (mantis #727)
                      - disabled the AutoSave property in the folder comboboxes
                        and removed the regkeys (they where wrong and
                        loading and saving is no done with MruList...Folder)
                      - removed the comboboxes.AutoSave.SaveValue
                      - the TargetFolder will also be inserted into the
                        comboboxes now
2003/12/28  USchuster - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use constant)
                      - AutoComplete in ComboBox now False
2004/02/24  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/31  USchuster - style cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/11/05  USchuster - moved resourcestrings to JVCSGUIClientResources.pas                      
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC3 released ^^^^^^^^^^^^^^^^^^^^^^^^^^
2006/01/22  THuber    - replaced CheckSum unit
2007/03/07  USchuster - replaced "Open Parent Folder" code by function ShellOpenParentFolder (mantis #4079)
2007/06/29  USchuster - changes for large fonts (contraints and default size depend now on PixelsPerInch; Mantis #3710)
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit CompareFolders;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ComCtrls, EnhListView, ImgList,
  Menus, JvCombobox, JVCSMruList, JvExStdCtrls,JVCSForms;

type
  TVCSCompareFolders = class(TJVCSForm)
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    spBtnBrowseBase: TSpeedButton;
    spBtnBrowseTarget: TSpeedButton;
    spBtnHelp: TSpeedButton;
    cbRecurse: TCheckBox;
    btnCompare: TButton;
    btnReport: TButton;
    btnClose: TButton;
    elvCompareResult: TdfsEnhListView;
    StateImageList: TImageList;
    SysImageList: TImageList;
    lblResult: TLabel;
    SpeedButton1: TSpeedButton;
    rbCompTStamp: TRadioButton;
    rbCRC: TRadioButton;
    cbInclEqual: TCheckBox;
    PopupMenu1: TPopupMenu;
    CopyBaseTarget1: TMenuItem;
    CopyTargetBase1: TMenuItem;
    N1: TMenuItem;
    OpenBaseFolder1: TMenuItem;
    OpenTargetFolder1: TMenuItem;
    rcbxBaseFolder: TJvComboBox;
    rcbxTargetFolder: TJvComboBox;
    procedure FormCreate(Sender: TObject);
    procedure spBtnBrowseBaseClick(Sender: TObject);
    procedure spBtnBrowseTargetClick(Sender: TObject);
    procedure btnCompareClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SpeedButton1Click(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure elvCompareResultDrawItem(Control: TWinControl;
      var ACanvas: TCanvas; Index: Integer; ARect: TRect;
      State: TOwnerDrawState; var DefaultDrawing, FullRowSelect: Boolean);
    procedure btnReportClick(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure CopyBaseTarget1Click(Sender: TObject);
    procedure CopyTargetBase1Click(Sender: TObject);
    procedure spBtnHelpClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure rcbxBaseFolderChange(Sender: TObject);
    procedure OpenBaseFolder1Click(Sender: TObject);
    procedure OpenTargetFolder1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    BaseFolder,
    CompareFolder: TStringList;
    FindType,
    AllFiles: Integer;
    MruListBaseFolder,
    MruListTargetFolder: TJVCSMruList;
    function LogFiles(const Path: string; const SRec: TSearchRec): Boolean;
    function GetListViewString: string;
  public
    { Public declarations }
    procedure RestrictSize(var Msg: TMessage); message WM_GETMINMAXINFO;
  end;

var
  VCSCompareFolders: TVCSCompareFolders;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  ShellAPI, SelectFolder, VCSBase, VCSProcBase, RekScan,  SimpleReport, CheckSum,
  ConfigStorage, JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSCompareFolders.FormCreate(Sender: TObject);
var
  sfi: TSHFileInfo;
  DlgTop,
  DlgLeft,
  DlgWidth,
  DlgHeight: Integer;
begin
  try
    //Systemsymbole in eine TImageList-Komponente einlesen
    SysImageList.Handle := SHGetFileInfo('', 0,sfi, SizeOf(TSHFileInfo),
      SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
    SysImageList.ShareImages := True;

    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    cbRecurse.Checked := jvcsReadBool(sBaseRegistryKey + crbWindows,
      'CompareFolder_Recourse', False);
    cbInclEqual.Checked := jvcsReadBool(sBaseRegistryKey + crbWindows,
      'CompareFolder_IncludeEqual', False);
    rbCompTStamp.Checked := True;

    if not jvcsReadWindowPosAndSize(sBaseRegistryKey + crbWindows, 'CompareFolder',
      DlgTop, DlgLeft, DlgWidth, DlgHeight) then
    begin
      DlgTop := (Screen.Height - Height) div 2;
      DlgLeft := (Screen.Width - Width) div 2;
      DlgWidth := MulDiv(420, PixelsPerInch, 96);
      DlgHeight := MulDiv(250, PixelsPerInch, 96);
    end;
    Top := DlgTop;
    Left := DlgLeft;
    Width := DlgWidth;
    Height := DlgHeight;

    with elvCompareResult do
    begin
      Columns[0].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'CompareFolder_Col1.0', 70);
      Columns[1].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'CompareFolder_Col1.1', 200);
      Columns[2].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'CompareFolder_Col1.2', 50);
      Columns[3].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'CompareFolder_Col1.3', 200);
      Columns[4].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'CompareFolder_Col1.4', 50);
    end;

    MruListBaseFolder   := TJVCSMruList.CreateEx(sBaseRegistryKey + crbMRU + '24');
    rcbxBaseFolder.Items.Assign(MruListBaseFolder);
    MruListTargetFolder := TJVCSMruList.CreateEx(sBaseRegistryKey + crbMRU + '25');
    rcbxTargetFolder.Items.Assign(MruListTargetFolder);

    Screen.Cursors[cPopUpMCursor] := LoadCursor(hInstance, PChar('CURSORRM'));
    elvCompareResult.Cursor := cPopUpMCursor;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSCompareFolders.spBtnBrowseBaseClick(Sender: TObject);
begin
  VCSSelectFolder := TVCSSelectFolder.Create(Application);
  try
    VCSSelectFolder.SetStatusText(JVCSRES_38Base_folder58);
    VCSSelectFolder.EnableRecursive(False);
    VCSSelectFolder.EnableNewFolder(False);
    VCSSelectFolder.EnableRenameFolder(False);
    VCSSelectFolder.HelpContextID := IDH_Compare_folders;
    if rcbxBaseFolder.Text <> '' then
      VCSSelectFolder.SetInitialDir(rcbxBaseFolder.Text)
    else
      VCSSelectFolder.SetInitialDir(GetCurrentDir);
    VCSSelectFolder.ShowModal;
    if VCSSelectFolder.Selection <> '' then
    begin
      rcbxBaseFolder.Text := SetBackSlash(AnsiLowerCase(VCSSelectFolder.Selection));
      MruListBaseFolder.AddString(rcbxBaseFolder.Text);
      rcbxBaseFolder.Items.Insert(0, rcbxBaseFolder.Text);
    end; // if VCSSelectFolder.Selection <> '' then begin
  finally
    VCSSelectFolder.Free;
  end;
  rcbxBaseFolderChange(Self);
end;

//------------------------------------------------------------------------------

procedure TVCSCompareFolders.spBtnBrowseTargetClick(Sender: TObject);
begin
  VCSSelectFolder := TVCSSelectFolder.Create(Application);
  try
    VCSSelectFolder.SetStatusText(JVCSRES_38Target_folder58);
    VCSSelectFolder.EnableRecursive(False);
    VCSSelectFolder.EnableNewFolder(False);
    VCSSelectFolder.EnableRenameFolder(False);
    VCSSelectFolder.HelpContextID := IDH_Compare_folders;
    if rcbxTargetFolder.Text <> '' then
      VCSSelectFolder.SetInitialDir(rcbxTargetFolder.Text)
    else
      VCSSelectFolder.SetInitialDir(GetCurrentDir);
    VCSSelectFolder.ShowModal;
    if VCSSelectFolder.Selection <> '' then 
    begin
      rcbxTargetFolder.Text := SetBackSlash(AnsiLowerCase(VCSSelectFolder.Selection));
      MruListTargetFolder.AddString(rcbxTargetFolder.Text);
      rcbxTargetFolder.Items.Insert(0, rcbxTargetFolder.Text);
    end; // if VCSSelectFolder.Selection <> '' then begin
  finally
    VCSSelectFolder.Free;
  end;
  rcbxBaseFolderChange(Self);
end;

//------------------------------------------------------------------------------

procedure TVCSCompareFolders.SpeedButton1Click(Sender: TObject);
var 
  Buffer: string;
begin
  Buffer := rcbxBaseFolder.Text;
  rcbxBaseFolder.Text := rcbxTargetFolder.Text;
  rcbxTargetFolder.Text := Buffer;
  rcbxBaseFolderChange(Self);
end;

//------------------------------------------------------------------------------

procedure TVCSCompareFolders.rcbxBaseFolderChange(Sender: TObject);
begin
  btnCompare.Enabled := (rcbxBaseFolder.Text <> '') and
    (rcbxTargetFolder.Text <> '');
end;

//------------------------------------------------------------------------------

procedure TVCSCompareFolders.btnCompareClick(Sender: TObject);
var 
  I, OnlyBase, OnlyTarget, EqualFiles, DeltaFiles: Integer;
  CRC1, CRC2: string;
  LVItem: TListItem;
  sfi: TSHFileInfo;
  BaseFDate, TargetFDate: TDateTime;
  Delta: Boolean;
begin
  btnCompare.Enabled := False;
  btnReport.Enabled := False;
  btnClose.Enabled := False;
  Application.ProcessMessages;

  BaseFolder := TStringList.Create;
  CompareFolder := TStringList.Create;
  try
    Screen.Cursor := crHourGlass;
    elvCompareResult.BeginUpdate;
    try
      elvCompareResult.Items.Clear;
      elvCompareResult.Column[1].Caption := rcbxBaseFolder.Text;
      elvCompareResult.Column[3].Caption := rcbxTargetFolder.Text;
      AllFiles := 0;
      OnlyBase := 0;
      OnlyTarget := 0;
      DeltaFiles := 0;
      EqualFiles := 0;

      FindType := 1;
      FindRecursive(rcbxBaseFolder.Text, '*.*', LogFiles);
      FindType := 2;
      FindRecursive(rcbxTargetFolder.Text, '*.*', LogFiles);

      for I := 0 to BaseFolder.Count - 1 do 
      begin
        if CompareFolder.IndexOf(BaseFolder.Strings[I]) = -1 then 
        begin
          Inc(OnlyBase);
          LVItem := elvCompareResult.Items.Add;
          LVItem.Caption := JVCSRES_Base_only;


          LVItem.SubItems.Add(ExtractFileName(GetOriginalFileName(rcbxBaseFolder.Text +
            BaseFolder.Strings[I])));

          BaseFDate := FileDateToDateTime(FileAge(rcbxBaseFolder.Text +
            BaseFolder.Strings[I]));
          LVItem.SubItems.Add(DateTimeToStr(BaseFDate));
          LVItem.SubItems.Add(JVCSRES_no_such_file);
          LVItem.SubItems.Add('-');
          LVItem.StateIndex := 0;
          SHGetFileInfo(PChar(rcbxBaseFolder.Text + BaseFolder.Strings[I]), 0,
            sfi, SizeOf(sfi), SHGFI_SYSICONINDEX or SHGFI_SMALLICON or
            SHGFI_DISPLAYNAME);
          LVItem.ImageIndex := sfi.IIcon;
        end; // if CompareFolder.IndexOf(BaseFolder.Strings[I]) = -1 then begin
      end; // for I := 0 to BaseFolder.Count - 1 do begin

      for I := 0 to BaseFolder.Count - 1 do 
      begin
        if CompareFolder.IndexOf(BaseFolder.Strings[I]) <> -1 then 
        begin
          BaseFDate := 0;
          TargetFDate := 0;
          if rbCompTStamp.Checked then 
          begin
            BaseFDate := FileDateToDateTime(FileAge(rcbxBaseFolder.Text +
              BaseFolder.Strings[I]));
            TargetFDate := FileDateToDateTime(FileAge(rcbxTargetFolder.Text +
              BaseFolder.Strings[I]));
            Delta := (BaseFDate <> TargetFDate);
          end 
          else 
          begin
            CRC1 := CRCString(rcbxBaseFolder.Text + BaseFolder.Strings[I]);
            CRC2 := CRCString(rcbxTargetFolder.Text + BaseFolder.Strings[I]);
            Delta := (CRC1 <> CRC2);
          end;
          if Delta then 
          begin
            Inc(DeltaFiles);
            LVItem := elvCompareResult.Items.Add;
            LVItem.Caption := JVCSRES_Different;

            LVItem.SubItems.Add(ExtractFileName(GetOriginalFileName(rcbxBaseFolder.Text +
              BaseFolder.Strings[I])));

            if rbCompTStamp.Checked then
              LVItem.SubItems.Add(DateTimeToStr(BaseFDate))
            else
              LVItem.SubItems.Add('$' + CRC1);

            LVItem.SubItems.Add(ExtractFileName(GetOriginalFileName(rcbxTargetFolder.Text +
              BaseFolder.Strings[I])));

            if rbCompTStamp.Checked then
              LVItem.SubItems.Add(DateTimeToStr(TargetFDate))
            else
              LVItem.SubItems.Add('$' + CRC2);
            LVItem.StateIndex := 1;
            SHGetFileInfo(PChar(rcbxTargetFolder.Text + BaseFolder.Strings[I]), 0,
              sfi, SizeOf(sfi), SHGFI_SYSICONINDEX or SHGFI_SMALLICON or
              SHGFI_DISPLAYNAME);
            LVItem.ImageIndex := sfi.IIcon;
          end // if Delta then begin
          else 
          begin
            Inc(EqualFiles);
            if cbInclEqual.Checked then 
            begin
              LVItem := elvCompareResult.Items.Add;
              LVItem.Caption := JVCSRES_C_Equal;

              LVItem.SubItems.Add(ExtractFileName(GetOriginalFileName(rcbxBaseFolder.Text +
                BaseFolder.Strings[I])));

              if rbCompTStamp.Checked then
                LVItem.SubItems.Add(DateTimeToStr(BaseFDate))
              else
                LVItem.SubItems.Add('$' + CRC1);

              LVItem.SubItems.Add(ExtractFileName(GetOriginalFileName(rcbxTargetFolder.Text +
                BaseFolder.Strings[I])));

              if rbCompTStamp.Checked then
                LVItem.SubItems.Add(DateTimeToStr(TargetFDate))
              else
                LVItem.SubItems.Add('$' + CRC2);
              LVItem.StateIndex := 3;
              SHGetFileInfo(PChar(rcbxTargetFolder.Text + BaseFolder.Strings[I]), 0,
                sfi, SizeOf(sfi), SHGFI_SYSICONINDEX or SHGFI_SMALLICON or
                SHGFI_DISPLAYNAME);
              LVItem.ImageIndex := sfi.IIcon;
            end; // if cbInclEqual.Checked then begin
          end; // else if Delta then begin
        end; // if CompareFolder.IndexOf(BaseFolder.Strings[I]) <> -1 then begin
      end; // for I := 0 to BaseFolder.Count - 1 do begin

      for I := 0 to CompareFolder.Count - 1 do
      begin
        if BaseFolder.IndexOf(CompareFolder.Strings[I]) = -1 then 
        begin
          Inc(OnlyTarget);
          LVItem := elvCompareResult.Items.Add;
          LVItem.Caption := JVCSRES_Target_only;
          LVItem.SubItems.Add(JVCSRES_no_such_file);
          LVItem.SubItems.Add('-');

          LVItem.SubItems.Add(ExtractFileName(GetOriginalFileName(rcbxTargetFolder.Text +
            CompareFolder.Strings[I])));

          TargetFDate := FileDateToDateTime(FileAge(rcbxTargetFolder.Text +
            CompareFolder.Strings[I]));
          LVItem.SubItems.Add(DateTimeToStr(TargetFDate));
          LVItem.StateIndex := 2;
          SHGetFileInfo(PChar(rcbxTargetFolder.Text + CompareFolder.Strings[I]),
            0, sfi, SizeOf(sfi), SHGFI_SYSICONINDEX or SHGFI_SMALLICON or
            SHGFI_DISPLAYNAME);
          LVItem.ImageIndex := sfi.IIcon;
        end; // if BaseFolder.IndexOf(CompareFolder.Strings[I]) = -1 then begin
      end; // for I := 0 to CompareFolder.Count - 1 do begin

    finally
      elvCompareResult.EndUpdate;
    end;
    lblResult.Caption := Format(JVCSRES_Base58_37d_files47_Target58_37d_files + ' -  ' +
      JVCSRES_37d_equal_files47_37d_in_both_directories44_but_different47_37d_only_in_base47_37d_only_in_target46,
      [BaseFolder.Count, CompareFolder.Count, EqualFiles, DeltaFiles, OnlyBase, OnlyTarget]);
  finally
    BaseFolder.Free;
    CompareFolder.Free;
    Screen.Cursor := crDefault;
  end;
  btnCompare.Enabled := True;
  btnReport.Enabled := True;
  btnClose.Enabled := True;
end;

//------------------------------------------------------------------------------
// CallBack für FindRecursive

function TVCSCompareFolders.LogFiles(const Path: string;
  const SRec: TSearchRec): Boolean;
var 
  CurrentFile: string;
begin
  if not cbRecurse.Checked then 
  begin
    Result := True;
    case FindType of
      1:
        if AnsiLowerCase(rcbxBaseFolder.Text) <> AnsiLowerCase(Path) then
        begin
          Result := False;
          Exit;
        end;
      2: 
        if AnsiLowerCase(rcbxTargetFolder.Text) <> AnsiLowerCase(Path) then
        begin
          Result := False;
          Exit;
        end;
    end; // case FindType of
  end 
  else 
    Result := True;
  case FindType of
    1: 
      begin
        CurrentFile := AnsiLowerCase(Path + SRec.Name);
        System.Delete(CurrentFile, 1, Length(rcbxBaseFolder.Text));
        BaseFolder.Add(CurrentFile);
      end;
    2: 
      begin
        CurrentFile := AnsiLowerCase(Path + SRec.Name);
        System.Delete(CurrentFile, 1, Length(rcbxTargetFolder.Text));
        CompareFolder.Add(CurrentFile);
      end;
  end; // case FindType of
end;

//------------------------------------------------------------------------------

procedure TVCSCompareFolders.RestrictSize(var Msg: TMessage);
var
  P: PMinMaxInfo;
begin
  P := PMinMaxInfo(Msg.lParam);
  P.ptMaxSize.x := trResDesktop.Right;
  P.ptMaxSize.y := trResDesktop.Bottom;
  P.ptMaxPosition.x := 0;
  P.ptMaxPosition.y := 0;
  P.ptMinTrackSize.x := MulDiv(540, PixelsPerInch, 96);
  P.ptMinTrackSize.y := MulDiv(320, PixelsPerInch, 96);
end;

//------------------------------------------------------------------------------

procedure TVCSCompareFolders.btnReportClick(Sender: TObject);
var
  ResultString: string;
begin
  ResultString := GetListViewString;
  if ResultString = '' then 
    Exit;

  VCSSimpleReport := TVCSSimpleReport.Create(Application);
  try
    VCSSimpleReport.RepID := 2;  
    VCSSimpleReport.Left := Left + 60;
    VCSSimpleReport.Top := Top + 60;
    VCSSimpleReport.FullReportString := ResultString;
    VCSSimpleReport.SavePath := ExtractFileDir(sProjectName);
    VCSSimpleReport.LineCount := elvCompareResult.Items.Count + 8;
    VCSSimpleReport.SaveFileName := 'CompareFolders.txt';
    VCSSimpleReport.ShowModal;
  finally
    VCSSimpleReport.Free;
  end;
end;

//------------------------------------------------------------------------------

function TVCSCompareFolders.GetListViewString: string;
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
    with elvCompareResult do 
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
      Result := Result + CurrentText + cr;

      if rbCompTStamp.Checked then
        Result := Result + JVCSRES_File_compare58_Timestamp + cr + cr
      else
        Result := Result + JVCSRES_File_compare58_CRC32 + cr + cr;

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

    Result := Result + lblResult.Caption + cr;

    Result := Result + cr + JVCSRES_Source58_ + LocalIPAddr + JVCSRES__40local41 + cr +
      JVCSRES_JEDI_VCS_ + sProductVer + cProductInf + DateTimeToStr(Now) + cr;
  finally
    Screen.Cursor := crDefault;
    SetLength(oaColumnsWidth, 0);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSCompareFolders.btnCloseClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSCompareFolders.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  jvcsWriteWindowPosAndSize(sBaseRegistryKey + crbWindows, 'CompareFolder',
    Top, Left, Width, Height);

  with elvCompareResult do
  begin
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'CompareFolder_Col1.0',
      Columns[0].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'CompareFolder_Col1.1',
      Columns[1].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'CompareFolder_Col1.2',
      Columns[2].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'CompareFolder_Col1.3',
      Columns[3].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'CompareFolder_Col1.4',
      Columns[4].Width);
  end;

  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'CompareFolder_Recourse',
    cbRecurse.Checked);
  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'CompareFolder_IncludeEqual',
    cbInclEqual.Checked);
end;

//------------------------------------------------------------------------------

procedure TVCSCompareFolders.elvCompareResultDrawItem(Control: TWinControl;
  var ACanvas: TCanvas; Index: Integer; ARect: TRect;
  State: TOwnerDrawState; var DefaultDrawing, FullRowSelect: Boolean);
begin
  DefaultDrawing := True;
  FullRowSelect := True;
end;

//------------------------------------------------------------------------------

procedure TVCSCompareFolders.PopupMenu1Popup(Sender: TObject);
var 
  I: Integer;
  CopyBaseTarget, CopyTargetBase: Boolean;
begin
  if elvCompareResult.SelCount = 0 then 
  begin
    CopyBaseTarget1.Enabled := False;
    CopyTargetBase1.Enabled := False;
    Exit;
  end;
  CopyBaseTarget := True;
  CopyTargetBase := True;
  with elvCompareResult do
  begin
    for I := 0 to Items.Count - 1 do 
    begin
      if Items[I].Selected then 
      begin
        if (Items[I].StateIndex = 2) then
          CopyBaseTarget := False;
        if (Items[I].StateIndex = 0) then
          CopyTargetBase := False;
      end; // if Items[I].Selected then begin
    end; // for I := 0 to Items.Count - 1 do begin
  end; // with elvCompareResult do begin
  CopyBaseTarget1.Enabled := CopyBaseTarget;
  CopyTargetBase1.Enabled := CopyTargetBase;

  {CopyBaseTarget1.Enabled := (elvCompareResult.Selected <> nil) and
                             ((elvCompareResult.Selected.StateIndex = 0) or
                              (elvCompareResult.Selected.StateIndex = 1));
  CopyTargetBase1.Enabled := (elvCompareResult.Selected <> nil) and
                             ((elvCompareResult.Selected.StateIndex = 1) or
                              (elvCompareResult.Selected.StateIndex = 2));}
end;

//------------------------------------------------------------------------------

procedure TVCSCompareFolders.CopyBaseTarget1Click(Sender: TObject);
var 
  BaseFile, TargetFile: string;
  I: Integer;
begin
  Screen.Cursor := crHourGlass;
  try
    with elvCompareResult do 
    begin
      for I := 0 to Items.Count - 1 do 
      begin
        if Items[I].Selected then 
        begin
          BaseFile := elvCompareResult.Columns[1].Caption +
            elvCompareResult.Items[I].SubItems[0];
          TargetFile := elvCompareResult.Columns[3].Caption +
            elvCompareResult.Items[I].SubItems[0];
          if FileExists(TargetFile) then
            if MessageBox(WindowHandle, PChar(Format('<%s>' + #13#10 +
              JVCSRES_Are_you_sure_you_want_to_overwrite_this_file63, [TargetFile])),
              cMsgBoxCaption, MB_YESNOCANCEL or MB_DEFBUTTON2 or MB_ICONWARNING) <> idYes then
              Exit;

          if CopyFile(PChar(BaseFile), PChar(TargetFile), False) then
          begin
            elvCompareResult.Items[I].SubItems[2] :=
              elvCompareResult.Items[I].SubItems[0];
            elvCompareResult.Items[I].SubItems[3] :=
              elvCompareResult.Items[I].SubItems[1];
            elvCompareResult.Items[I].Caption := JVCSRES_C_Equal;
            elvCompareResult.Items[I].StateIndex := 3;
            lblResult.Caption := '';
          end 
          else 
            BeepIfSet;
        end; // if Items[I].Selected then begin
      end; // for I := 0 to Items.Count - 1 do begin
    end; // with elvCompareResult do begin
  finally
    Screen.Cursor := crDefault;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSCompareFolders.CopyTargetBase1Click(Sender: TObject);
var 
  BaseFile, TargetFile: string;
  I: Integer;
begin
  Screen.Cursor := crHourGlass;
  try
    with elvCompareResult do 
    begin
      for I := 0 to Items.Count - 1 do 
      begin
        if Items[I].Selected then 
        begin
          BaseFile := elvCompareResult.Columns[1].Caption +
            elvCompareResult.Items[I].SubItems[2];
          TargetFile := elvCompareResult.Columns[3].Caption +
            elvCompareResult.Items[I].SubItems[2];
          if FileExists(BaseFile) then
            if MessageBox(WindowHandle, PChar(Format('<%s>' + #13#10 +
              JVCSRES_Are_you_sure_you_want_to_overwrite_this_file63, [BaseFile])),
              cMsgBoxCaption, MB_YESNOCANCEL or MB_DEFBUTTON2 or MB_ICONWARNING) <> idYes then
              Exit;

          if CopyFile(PChar(TargetFile), PChar(BaseFile), False) then 
          begin
            elvCompareResult.Items[I].SubItems[0] :=
              elvCompareResult.Items[I].SubItems[2];
            elvCompareResult.Items[I].SubItems[1] :=
              elvCompareResult.Items[I].SubItems[3];
            elvCompareResult.Items[I].Caption := JVCSRES_C_Equal;
            elvCompareResult.Items[I].StateIndex := 3;
            lblResult.Caption := '';
          end 
          else 
            BeepIfSet;
        end; // if Items[I].Selected then begin
      end; // for I := 0 to Items.Count - 1 do begin
    end; // with elvCompareResult do begin
  finally
    Screen.Cursor := crDefault;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSCompareFolders.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Compare_folders);
end;

//------------------------------------------------------------------------------

procedure TVCSCompareFolders.spBtnHelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSCompareFolders.OpenBaseFolder1Click(Sender: TObject);
var
  FileName: string;
begin
  FileName := elvCompareResult.Selected.SubItems[0];
  if FileName = JVCSRES_no_such_file then
    FileName := '';
  ShellOpenParentFolder(elvCompareResult.Columns[1].Caption + FileName);
end;

//------------------------------------------------------------------------------

procedure TVCSCompareFolders.OpenTargetFolder1Click(Sender: TObject);
var
  FileName: string;
begin
  FileName := elvCompareResult.Selected.SubItems[2];
  if FileName = JVCSRES_no_such_file then
    FileName := '';
  ShellOpenParentFolder(elvCompareResult.Columns[3].Caption + FileName);
end;

procedure TVCSCompareFolders.FormDestroy(Sender: TObject);
begin
  MruListBaseFolder.Free;
  MruListTargetFolder.Free;
end;

end.
