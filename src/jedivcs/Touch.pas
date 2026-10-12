(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: Touch.pas

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
2003/03/06  THensle   - changes for "ConfigStorage" unit
2003/03/09  USchuster - exchanged TjvMruList with TJVCSMruList (mantis #727)
                      - disabled the AutoSave property in rcbxTouchFolder
                        and removed the regkeys (they where wrong and
                        loading and saving is no done with MruListTouchFolder)
                      - removed rcbxTouchFolder.AutoSave.SaveValue
                      - the selected folder will also be inserted into the
                        combobox now
2003/12/28  USchuster - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use constant)
                      - AutoComplete in ComboBox now False
2004/02/24  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/09/17  FHasovic  - Added dxGetText support for localization                      
2004/10/08  USchuster - style cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/10/31  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
2007/06/30  USchuster - changes for large fonts (contraints and default size depend now on PixelsPerInch; analog to Mantis #3710)                      
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit Touch;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, CheckLst, ExtCtrls, Menus, Buttons, ImgList, JvCombobox,
  JVCSMruList, JvExStdCtrls, JVCSForms;

type
  TVCSTouch = class(TJVCSForm)
    Panel1: TPanel;
    Panel2: TPanel;
    dtpNewTime: TDateTimePicker;
    dtpNewDate: TDateTimePicker;
    btnTouch: TButton;
    Button1: TButton;
    GroupBox1: TGroupBox;
    rbExecutables: TRadioButton;
    rbAll: TRadioButton;
    PopupMenu1: TPopupMenu;
    HelpTopicF11: TMenuItem;
    spBtnSelect: TSpeedButton;
    spBtnBrowse: TSpeedButton;
    lvFiles: TListView;
    SysImageList: TImageList;
    StateImageList: TImageList;
    Panel3: TPanel;
    Label1: TLabel;
    Help: TSpeedButton;
    btnRead: TButton;
    Label2: TLabel;
    Image2: TImage;
    rcbxTouchFolder: TJvComboBox;
    procedure btnTouchClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure rbExecutablesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure HelpTopicF11Click(Sender: TObject);
    procedure spBtnSelectClick(Sender: TObject);
    procedure spBtnBrowseClick(Sender: TObject);
    procedure lvFilesMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lvFilesKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure HelpClick(Sender: TObject);
    procedure btnReadClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private-Deklarationen}
    AllChecked: Boolean;
    MruListTouchFolder: TJVCSMruList;
    procedure ReadDirectory(Dir: string);
    function SetNewDate(const FileName: string;
      const NewDate: TDateTime): Boolean;
  public
    { Public-Deklarationen}
    procedure RestrictSize(var Msg: TMessage); message WM_GETMINMAXINFO;
  end;

var
  VCSTouch: TVCSTouch;

implementation

{$R *.dfm}

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  ShellAPI, VCSBase, SelectFolder, VCSProcBase, CommCtrl, ConfigStorage,
  JVCSGUIClientResources;

//------------------------------------------------------------------------------
procedure TVCSTouch.FormCreate(Sender: TObject);
var
  sfi: TSHFileInfo;
  ToolTipHandle: HWND;
  DlgTop, DlgLeft, DlgWidth, DlgHeight: Integer;
begin
  try
    // ListView Tooltips
    SendMessage(lvFiles.Handle, LVM_SETEXTENDEDLISTVIEWSTYLE, LVS_EX_INFOTIP,
      LVS_EX_INFOTIP);
    ToolTipHandle := SendMessage(lvFiles.Handle, LVM_GETTOOLTIPS, 0, 0);
    SendMessage(ToolTipHandle, TTM_SETDELAYTIME, TTDT_AUTOMATIC, 1);
    SendMessage(ToolTipHandle, TTM_SETDELAYTIME, TTDT_AUTOPOP, 3000);

    if not jvcsReadWindowPosAndSize(sBaseRegistryKey + crbWindows, 'Touch',
      DlgTop, DlgLeft, DlgWidth, DlgHeight) then
    begin
      DlgTop := (Screen.Height - Height) div 2;
      DlgLeft := (Screen.Width - Width) div 2;
      DlgWidth := MulDiv(415, PixelsPerInch, 96);
      DlgHeight := MulDiv(300, PixelsPerInch, 96);
    end;
    Top := DlgTop;
    Left := DlgLeft;
    Width := DlgWidth;
    Height := DlgHeight;

    with lvFiles do
    begin
      Columns[0].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'Touch_Col1.0', 300);
      Columns[1].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'Touch_Col1.1', 100);
    end;

    MruListTouchFolder := TJVCSMruList.CreateEx(sBaseRegistryKey + crbMRU + '26');
    rcbxTouchFolder.Items.Assign(MruListTouchFolder);

    AllChecked := False;
    //Systemsymbole in eine TImageList-Komponente einlesen
    SysImageList.Handle := SHGetFileInfo('', 0, sfi, SizeOf(TSHFileInfo),
      SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
    SysImageList.ShareImages := True;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSTouch.ReadDirectory(Dir: string);
var
  SearchRec: TSearchRec;
  Path, Ext: string;
  NewLVItem: TListItem;
  sfi: TSHFileInfo;
begin
  if Dir = '' then 
    Exit;
  if Dir[Length(Dir)] <> '\' then 
    Dir := Dir + '\';
  Path := Dir;
  Dir := Dir + '*.*';
  with lvFiles do 
  begin
    Items.BeginUpdate;
    try
      Items.Clear;
      FindFirst(Dir, faAnyFile, SearchRec);
      if (SearchRec.Attr and faDirectory) = 0 then
      begin
        if rbExecutables.Checked then 
        begin
          Ext := AnsiLowerCase(ExtractFileExt(SearchRec.Name));
          if (Ext = '.exe') or (Ext = '.dll') or (Ext = '.bpl') then 
          begin
            NewLVItem := Items.Add;
            NewLVItem.StateIndex := 0;
            SHGetFileInfo(PChar(Path + SearchRec.Name), 0, sfi, SizeOf(sfi),
              SHGFI_SYSICONINDEX or SHGFI_SMALLICON or SHGFI_DISPLAYNAME);
            NewLVItem.ImageIndex := sfi.IIcon;
            NewLVItem.Caption := Path + SearchRec.Name;
            NewLVItem.SubItems.Add(DateTimeToStr(FileDateToDateTime(SearchRec.Time)));
          end; // if (Ext = '.exe') or (Ext = '.dll') or (Ext = '.bpl') then begin
        end
        else 
        begin
          NewLVItem := Items.Add;
          NewLVItem.StateIndex := 0;
          SHGetFileInfo(PChar(Path + SearchRec.Name), 0, sfi, SizeOf(sfi),
            SHGFI_SYSICONINDEX or SHGFI_SMALLICON or SHGFI_DISPLAYNAME);
          NewLVItem.ImageIndex := sfi.IIcon;
          NewLVItem.Caption := Path + SearchRec.Name;
          NewLVItem.SubItems.Add(DateTimeToStr(FileDateToDateTime(SearchRec.Time)));
        end;
      end; // if (SearchRec.Attr and faDirectory) = 0 then
      while (FindNext(SearchRec) = 0) do 
      begin
        if (SearchRec.Attr and faDirectory) = 0 then
        begin
          if rbExecutables.Checked then 
          begin
            Ext := AnsiLowerCase(ExtractFileExt(SearchRec.Name));
            if (Ext = '.exe') or (Ext = '.dll') or (Ext = '.bpl') then 
            begin
              NewLVItem := Items.Add;
              NewLVItem.StateIndex := 0;
              SHGetFileInfo(PChar(Path + SearchRec.Name), 0, sfi, SizeOf(sfi),
                SHGFI_SYSICONINDEX or SHGFI_SMALLICON or SHGFI_DISPLAYNAME);
              NewLVItem.ImageIndex := sfi.IIcon;
              NewLVItem.Caption := Path + SearchRec.Name;
              NewLVItem.SubItems.Add(DateTimeToStr(FileDateToDateTime(SearchRec.Time)));
            end;
          end
          else 
          begin
            NewLVItem := Items.Add;
            NewLVItem.StateIndex := 0;
            SHGetFileInfo(PChar(Path + SearchRec.Name), 0, sfi, SizeOf(sfi),
              SHGFI_SYSICONINDEX or SHGFI_SMALLICON or SHGFI_DISPLAYNAME);
            NewLVItem.ImageIndex := sfi.IIcon;
            NewLVItem.Caption := Path + SearchRec.Name;
            NewLVItem.SubItems.Add(DateTimeToStr(FileDateToDateTime(SearchRec.Time)));
          end;
        end; // if (SearchRec.Attr and faDirectory) = 0 then
      end; // while (FindNext(SearchRec) = 0) do begin
      FindClose(SearchRec);
    finally
      Items.EndUpdate;
    end;
  end; // with lvFiles do begin
end;

//------------------------------------------------------------------------------

function TVCSTouch.SetNewDate(const FileName: string;
  const NewDate: TDateTime): Boolean;
var 
  hFHandle: Integer;
begin
  Result := False;
  try
    hFHandle := FileOpen(FileName, fmOpenWrite or fmShareDenyNone);
    if hFHandle <> -1 then 
    begin
      FileSetDate(hFHandle, DateTimeToFileDate(NewDate + 0.000005));
      FileClose(hFHandle);
    end 
    else 
      Exit; // Result := false;
  except
    Exit; // Result := false;
  end;
  Result := True;
end;

//------------------------------------------------------------------------------

procedure TVCSTouch.btnTouchClick(Sender: TObject);
var
  NewDate: TDateTime;
  Buffer: string;
  Changed, Error, I, mbIcon: Integer;
begin
  {  --hu
  rcbxTouchFolder.AddMRUString(rcbxTouchFolder.Text);
  rcbxTouchFolder.MRUSaveToReg;
   }

  mbIcon := MB_ICONINFORMATION;
  NewDate := Int(dtpNewDate.Date) + Frac(dtpNewTime.Time);
  Changed := 0;
  Error := 0;
  with lvFiles do 
  begin
    for I := 0 to (Items.Count - 1) do 
    begin
      if Items[I].StateIndex = 1 then 
      begin
        if SetNewDate(Items[I].Caption, NewDate) then 
          Inc(Changed)
        else 
          Inc(Error);
      end; // if Items[I].StateIndex = 1 then begin
    end; // for I := 0 to (Items.Count - 1) do begin
  end; // with lvFiles do begin
  Buffer := Format(JVCSRES_37d_files_changed_to_37s46, [Changed, DateTimeToStr(NewDate)]);
  if Error <> 0 then
  begin
    Buffer := Buffer + #10#13 +
      Format(JVCSRES_37d_files_not_changed58_Access_denied46, [Error]);
    mbIcon := MB_ICONWARNING;
  end;
  MessageBox(WindowHandle, PChar(Buffer), cMsgBoxCaption, MB_OK or mbIcon);
  ReadDirectory(SetBackSlash(rcbxTouchFolder.Text));

  AllChecked := False;
  spBtnSelect.Hint := JVCSRES_Select_All;
end;

//------------------------------------------------------------------------------

procedure TVCSTouch.FormActivate(Sender: TObject);
begin
  dtpNewDate.Date := Now;
  rbExecutables.Checked := True;
end;

//------------------------------------------------------------------------------

procedure TVCSTouch.rbExecutablesClick(Sender: TObject);
begin
  ReadDirectory(SetBackSlash(rcbxTouchFolder.Text));
  AllChecked := False;
  spBtnSelect.Hint := JVCSRES_Select_All;
end;

//------------------------------------------------------------------------------

procedure TVCSTouch.RestrictSize(var Msg: TMessage);
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
  P.ptMinTrackSize.x := MulDiv(408, PixelsPerInch, 96);
  P.ptMinTrackSize.y := MulDiv(266, PixelsPerInch, 96);
end;

//------------------------------------------------------------------------------

procedure TVCSTouch.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  jvcsWriteWindowPosAndSize(sBaseRegistryKey + crbWindows, 'Touch',
    Top, Left, Width, Height);

  with lvFiles do
  begin
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'Touch_Col1.0',
      Columns[0].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'Touch_Col1.1',
      Columns[1].Width);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSTouch.Button1Click(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSTouch.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then 
  begin
    Close;
    Key := 0;
  end;    
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Touch);
end;

//------------------------------------------------------------------------------

procedure TVCSTouch.HelpTopicF11Click(Sender: TObject);
begin
  PerformHelpCommand(Application, IDH_Touch);
end;

//------------------------------------------------------------------------------

procedure TVCSTouch.spBtnSelectClick(Sender: TObject);
var 
  I: Integer;
begin
  if AllChecked then 
  begin
    with lvFiles do
      for I := 0 to (Items.Count - 1) do 
        Items[I].StateIndex := 0;
    AllChecked := False;
    spBtnSelect.Hint := JVCSRES_Select_All;
  end 
  else 
  begin
    with lvFiles do
      for I := 0 to (Items.Count - 1) do 
        Items[I].StateIndex := 1;
    AllChecked := True;
    spBtnSelect.Hint := JVCSRES_Unselect_All;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSTouch.spBtnBrowseClick(Sender: TObject);
begin
  VCSSelectFolder := TVCSSelectFolder.Create(Application);
  try
    VCSSelectFolder.SetStatusText(JVCSRES_38Target_folder58);
    VCSSelectFolder.EnableRecursive(False);
    VCSSelectFolder.HelpContextID := IDH_Touch;
    VCSSelectFolder.EnableNewFolder(False);
    if rcbxTouchFolder.Text <> '' then 
      VCSSelectFolder.SetInitialDir(rcbxTouchFolder.Text)
    else 
      VCSSelectFolder.SetInitialDir(GetCurrentDir);
    VCSSelectFolder.ShowModal;
    if VCSSelectFolder.Selection <> '' then
    begin
      rcbxTouchFolder.Text :=
        SetBackSlash(AnsiLowerCase(VCSSelectFolder.Selection));
      AllChecked := False;
      spBtnSelect.Hint := JVCSRES_Select_All;
      MruListTouchFolder.AddString(rcbxTouchFolder.Text);
      rcbxTouchFolder.Items.Insert(0, rcbxTouchFolder.Text);
    end; // if VCSSelectFolder.Selection <> '' then begin
  finally
    VCSSelectFolder.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSTouch.btnReadClick(Sender: TObject);
begin
  ReadDirectory(SetBackSlash(rcbxTouchFolder.Text));
end;

//------------------------------------------------------------------------------

procedure TVCSTouch.lvFilesMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var 
  HitTest: THitTests;
  HitItem: TListItem;
begin
  HitTest := lvFiles.GetHitTestInfoAt(X, Y);
  if (Button = mbLeft) and (htOnStateIcon in HitTest) then 
  begin
    HitItem := lvFiles.GetItemAt(X, Y);
    if HitItem.StateIndex = 0 then 
      HitItem.StateIndex := 1 
    else 
      HitItem.StateIndex := 0;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSTouch.lvFilesKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (lvFiles.Selected <> nil) and (Key = VK_SPACE) then 
  begin
    if lvFiles.Selected.StateIndex > 1 then 
      Exit;
    if lvFiles.Selected.StateIndex = 0 then 
      lvFiles.Selected.StateIndex := 1
    else 
      lvFiles.Selected.StateIndex := 0;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSTouch.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

procedure TVCSTouch.FormDestroy(Sender: TObject);
begin
  MruListTouchFolder.Free;
end;

end.
