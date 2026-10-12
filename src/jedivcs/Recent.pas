(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: Recent.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS: Thomas Huber (Thomas_D_Huber@t-online.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FreeVCS code to JEDI VCS
2003/03/09  THensle   - changes for "ConfigStorage" unit
2003/03/09  USchuster - exchanged THistoryList with TJVCSMruList (mantis #727)
2003/12/28  USchuster - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use constant)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/17  USchuster - style cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/11/02  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
2007/07/01  USchuster - changes for large fonts (contraints and default size depend now on PixelsPerInch; analog to Mantis #3710)
2010/01/24  USchuster - added JVCSClientConsts to uses (as some consts were moved from VCSBase there)
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit Recent;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  {$IFDEF DEBUG}
  JclDebug,
  {$ENDIF DEBUG}
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, Buttons, Menus, ImgList, FavOpenDialog;

type
  TVCSRecentProjects = class(TForm)
    PageControl1: TPageControl;
    Panel1: TPanel;
    Label2: TLabel;
    edMaxCount: TEdit;
    UpDown1: TUpDown;
    btnLoad: TButton;
    btnCancel: TButton;
    SheetMRU: TTabSheet;
    SheetUser: TTabSheet;
    Panel2: TPanel;
    spBtnAddUser: TSpeedButton;
    spBtnDelUser: TSpeedButton;
    spBtnClrUser: TSpeedButton;
    Panel3: TPanel;
    spBtnClrHist: TSpeedButton;
    PopupMenu1: TPopupMenu;
    RemoveItem1: TMenuItem;
    OpenProject1: TMenuItem;
    N2: TMenuItem;
    ImportDelphisMRU1: TMenuItem;
    N1: TMenuItem;
    HelpTopic1: TMenuItem;
    spBtnDelMRU: TSpeedButton;
    Add1: TMenuItem;
    SpeedButton1: TSpeedButton;
    lvMRU: TListView;
    StateImageList: TImageList;
    SysImageList: TImageList;
    lvUser: TListView;
    Help: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure spBtnClrHistClick(Sender: TObject);
    procedure RemoveItem1Click(Sender: TObject);
    procedure HelpTopic1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ImportDelphisMRU1Click(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure spBtnAddUserClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure lvMRUResize(Sender: TObject);
    procedure lvUserChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure lvUserClick(Sender: TObject);
    procedure HelpClick(Sender: TObject);
  private
    { Private-Deklarationen }
    MaxCount: Integer;
    procedure AddLVItem(const LV: TListView; const FileName: string);
    procedure SetupMenu;
  public
    { Public-Deklarationen }
    SelectedItem: string;
    procedure RestrictSize(var Msg: TMessage); message WM_GETMINMAXINFO;
  end;

var
  VCSRecentProjects: TVCSRecentProjects;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  ShellAPI, JVCSMruList, VCSBase, VCSProcBase, ConfigStorage, JVCSGUIClientResources,
  JVCSClientConsts;

{$R *.dfm}

procedure TVCSRecentProjects.FormCreate(Sender: TObject);
var
  OldProjects: TJVCSMruList;
  DlgTop, DlgLeft, DlgWidth, DlgHeight, I: Integer;
  sfi: TSHFileInfo;
  Msg: string;
begin
  try
    //Systemsymbole in eine TImageList-Komponente einlesen
    SysImageList.Handle := SHGetFileInfo('', 0, sfi, SizeOf(TSHFileInfo),
      SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
    SysImageList.ShareImages := True;

    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);
    MaxCount := jvcsReadInteger(sBaseRegistryKey + crbOptions, 'RecentCount', 20);

    if not jvcsReadWindowPosAndSize(sBaseRegistryKey + crbWindows, 'RecentIDEFiles',
      DlgTop, DlgLeft, DlgWidth, DlgHeight) then
    begin
      DlgTop := (Screen.Height - Height) div 2;
      DlgLeft := (Screen.Width - Width) div 2;
      DlgWidth := MulDiv(380, PixelsPerInch, 96);
      DlgHeight := MulDiv(260, PixelsPerInch, 96);
    end;
    Top := DlgTop;
    Left := DlgLeft;
    Width := DlgWidth;
    Height := DlgHeight;

    PageControl1.ActivePage := SheetMRU;
    edMaxCount.Text := IntToStr(MaxCount);
    UpDown1.Position := MaxCount;
    btnLoad.Enabled := False;

    // RecentListe für projekte
    OldProjects := TJVCSMruList.Create;
    OldProjects.MaxSize := MaxCount;
    OldProjects.LoadFromStorage(sBaseRegistryKey + crbMRU + '3');
    for I := 0 to OldProjects.Count - 1 do
      if IsValidProjectName(OldProjects.Strings[I], Msg) then
        AddLVItem(lvMRU, OldProjects.Strings[I]);
    Caption := Format(JVCSRES_Recent_Projects47Files_45_37d_items, [lvMRU.Items.Count]);
    OldProjects.Free;
    // RecentListe für files
    OldProjects := TJVCSMruList.Create;
    OldProjects.MaxSize := MaxCount;
    OldProjects.LoadFromStorage(sBaseRegistryKey + crbMRU + '7');
    for I := 0 to OldProjects.Count - 1 do
      AddLVItem(lvUser, OldProjects.Strings[I]);
    OldProjects.Free;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSRecentProjects.AddLVItem(const LV: TListView;
  const FileName: string);
var
  sfi: TSHFileInfo;
  NewItem: TListItem;
begin
  NewItem := LV.Items.Add;
  NewItem.Caption := FileName;
  if FileExists(FileName) then
  begin
    SHGetFileInfo(PChar(FileName), 0, sfi, SizeOf(sfi),
      SHGFI_SYSICONINDEX or SHGFI_SMALLICON or SHGFI_DISPLAYNAME);
    NewItem.ImageIndex := sfi.IIcon;
    if AnsiLowerCase(ExtractFileExt(FileName)) = '.bpg' then 
      NewItem.StateIndex := 1
    else 
      NewItem.StateIndex := -1;
  end 
  else 
  begin
    NewItem.ImageIndex := -1;
    NewItem.StateIndex := 0;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSRecentProjects.btnLoadClick(Sender: TObject);
var 
  CurrLV: TListView;
begin
  if PageControl1.ActivePage = SheetMRU then 
    CurrLV := lvMRU 
  else 
    CurrLV := lvUser;
  if CurrLV.Selected <> nil then 
  begin
    if CurrLV.Selected.StateIndex = 0 then 
      Exit;
    SelectedItem := CurrLV.Selected.Caption;
    Close;
  end 
  else
    BeepIfSet;
end;

//------------------------------------------------------------------------------

procedure TVCSRecentProjects.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  jvcsWriteWindowPosAndSize(sBaseRegistryKey + crbWindows, 'RecentIDEFiles',
    Top, Left, Width, Height);

  jvcsWriteInteger(sBaseRegistryKey + crbOptions, 'RecentCount', MaxCount);
end;

//------------------------------------------------------------------------------

procedure TVCSRecentProjects.spBtnClrHistClick(Sender: TObject);
var 
  OldProjects: TJVCSMruList;
  CurrLV: TListView;
begin
  if PageControl1.ActivePage = SheetMRU then 
    CurrLV := lvMRU 
  else 
    CurrLV := lvUser;
  if MessageBox(WindowHandle, PChar(Format(JVCSRES_Are_you_sure_you_want_to_clear_37d_entries63,
    [CurrLV.Items.Count])),
    cMsgBoxCaption, MB_YESNOCANCEL or MB_ICONQUESTION or MB_DEFBUTTON2) <> idYes then 
    Exit;
  OldProjects := TJVCSMruList.Create;
  OldProjects.MaxSize := 0;
  if PageControl1.ActivePage = SheetMRU then
    OldProjects.SaveToStorage(sBaseRegistryKey + crbMRU + '3')
  else
    OldProjects.SaveToStorage(sBaseRegistryKey + crbMRU + '7');
  OldProjects.Free;
  CurrLV.Items.Clear;
  Caption := Format(JVCSRES_Recent_Projects47Files_45_37d_items, [0]);
  btnLoad.Enabled := False;
end;

//------------------------------------------------------------------------------

procedure TVCSRecentProjects.RemoveItem1Click(Sender: TObject);
var 
  I, Selected: Integer;
  OldProjects: TJVCSMruList;
  CurrLV: TListView;
begin
  if PageControl1.ActivePage = SheetMRU then 
    CurrLV := lvMRU 
  else 
    CurrLV := lvUser;
  if CurrLV.Selected <> nil then 
  begin
    OldProjects := TJVCSMruList.Create;
    OldProjects.MaxSize := UpDown1.Position;
    if PageControl1.ActivePage = SheetMRU then
      OldProjects.LoadFromStorage(sBaseRegistryKey + crbMRU + '3')
    else
      OldProjects.LoadFromStorage(sBaseRegistryKey + crbMRU + '7');
    Selected := OldProjects.IndexOf(CurrLV.Selected.Caption);
    if Selected <> -1 then 
    begin
      OldProjects.Delete(Selected);
      CurrLV.Items.Clear;
      for I := 0 to OldProjects.Count - 1 do 
        AddLVItem(CurrLV, OldProjects.Strings[I]);
      Caption := Format(JVCSRES_Recent_Projects47Files_45_37d_items, [CurrLV.Items.Count]);
      if PageControl1.ActivePage = SheetMRU then
        OldProjects.SaveToStorage(sBaseRegistryKey + crbMRU + '3')
      else 
        OldProjects.SaveToStorage(sBaseRegistryKey + crbMRU + '7');
    end; // if Selected <> -1 then begin
    OldProjects.Free;
  end // if CurrHLB.ItemIndex <> -1 then begin
  else 
    BeepIfSet;
end;

//------------------------------------------------------------------------------

procedure TVCSRecentProjects.HelpTopic1Click(Sender: TObject);
begin
  PerformHelpCommand(Application, IDH_Recent_project_list);
end;

//------------------------------------------------------------------------------

procedure TVCSRecentProjects.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    btnLoad.Click;
  if Key = VK_ESCAPE then
  begin
    btnCancel.Click;
    Key := 0;
  end;
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Recent_project_list);
end;

//------------------------------------------------------------------------------

procedure TVCSRecentProjects.ImportDelphisMRU1Click(Sender: TObject);
var
  DMRU: TStringList;
  OldProjects: TJVCSMruList;
  Marker, I: Integer;
  CurrEntry: string;
begin
  if bIsCppBuilder then
  begin
    MessageBox(WindowHandle, PChar(JVCSRES_This_feature_is_currently_not_supported_by_the_C4343_Builder_version46_Sorry46),
      cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
    Exit;
  end;
  // Closed projects
  DMRU := TStringList.Create;
  try
    DMRU.Sorted := True;
    DMRU.Duplicates := dupIgnore;
    for I := 0 to 10 do
    begin
      CurrEntry :=
        jvcsReadString(sIDERegistryKey + '\Closed Projects', 'File_' + IntToStr(I), '');
      if CurrEntry <> '' then
        DMRU.Add(CurrEntry);
    end;

    OldProjects := TJVCSMruList.Create;
    try
      OldProjects.MaxSize := MaxCount;
      OldProjects.LoadFromStorage(sBaseRegistryKey + crbMRU + '3');
      for I := 0 to DMRU.Count - 1 do
      begin
        CurrEntry := DMRU.Strings[I];
        Marker := Pos(',', CurrEntry);
        Delete(CurrEntry, 1, Marker + 1);
        Marker := Pos(',', CurrEntry);
        CurrEntry := Copy(CurrEntry, 1, Marker - 2);
        if FileExists(CurrEntry) then
          OldProjects.AddString(CurrEntry);
      end; // for I := 0 to DMRU.Count - 1 do begin
      OldProjects.SaveToStorage(sBaseRegistryKey + crbMRU + '3');
      lvMRU.Items.Clear;
      for I := 0 to OldProjects.Count - 1 do
        AddLVItem(lvMRU, OldProjects.Strings[I]);
    finally
      OldProjects.Free;
    end;
    // Closed files
    DMRU.Clear;
    for I := 0 to 10 do
    begin
      CurrEntry :=
        jvcsReadString(sIDERegistryKey + '\Closed Files', 'File_' + IntToStr(I), '');
      if CurrEntry <> '' then
        DMRU.Add(CurrEntry);
    end;
    OldProjects := TJVCSMruList.Create;
    try
      OldProjects.MaxSize := MaxCount;
      OldProjects.LoadFromStorage(sBaseRegistryKey + crbMRU + '7');
      for I := 0 to DMRU.Count - 1 do
      begin
        CurrEntry := DMRU.Strings[I];
        Marker := Pos(',', CurrEntry);
        Delete(CurrEntry, 1, Marker + 1);
        Marker := Pos(',', CurrEntry);
        CurrEntry := Copy(CurrEntry, 1, Marker - 2);
        if FileExists(CurrEntry) then
          OldProjects.AddString(CurrEntry);
      end; // for I := 0 to DMRU.Count - 1 do begin
      OldProjects.SaveToStorage(sBaseRegistryKey + crbMRU + '7');
      lvUser.Items.Clear;
      for I := 0 to OldProjects.Count - 1 do
        AddLVItem(lvUser, OldProjects.Strings[I]);
    finally
      OldProjects.Free;
    end;
  finally
    DMRU.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSRecentProjects.RestrictSize(var Msg: TMessage);
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
  P.ptMinTrackSize.x := MulDiv(380, PixelsPerInch, 96);
  P.ptMinTrackSize.y := MulDiv(260, PixelsPerInch, 96);
end;

//------------------------------------------------------------------------------

procedure TVCSRecentProjects.PageControl1Change(Sender: TObject);
begin
  if PageControl1.ActivePage = SheetMRU then
    Caption := Format(JVCSRES_Recent_Projects47Files_45_37d_items, [lvMRU.Items.Count])
  else
    Caption := Format(JVCSRES_Recent_Projects47Files_45_37d_items, [lvUser.Items.Count]);

  lvMRU.Selected := nil;
  lvUser.Selected := nil;
  btnLoad.Enabled := False;
end;

//------------------------------------------------------------------------------

procedure TVCSRecentProjects.SetupMenu;
begin
  Add1.Enabled := (PageControl1.ActivePage = SheetUser);
  RemoveItem1.Enabled := ((PageControl1.ActivePage = SheetUser) and
    (lvUser.Selected <> nil)) or
    ((PageControl1.ActivePage = SheetMRU) and
    (lvMRU.Selected <> nil));
  btnLoad.Enabled := RemoveItem1.Enabled;
  OpenProject1.Enabled := btnLoad.Enabled;
end;

//------------------------------------------------------------------------------

procedure TVCSRecentProjects.lvUserClick(Sender: TObject);
begin
  SetupMenu;
end;

//------------------------------------------------------------------------------

procedure TVCSRecentProjects.lvUserChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  SetupMenu;
end;

//------------------------------------------------------------------------------

procedure TVCSRecentProjects.spBtnAddUserClick(Sender: TObject);
var
  OldProjects: TJVCSMruList;
  Filter1: string;
  I: Integer;
  DlgResult: Boolean;
  FavOpenDialog: TFavOpenDialog;
begin
  Filter1 :=
    jvcsReadString(sBaseRegistryKey + crbFilters, 'Delphi files', dfDelphiMod);
  FavOpenDialog := TFavOpenDialog.Create(Application);
  try
    with FavOpenDialog do
    begin
      Title := JVCSRES_Add_module91s93_to_MRU_list;
      Options := [ofHideReadOnly, ofAllowMultiSelect, ofPathMustExist,
        ofFileMustExist, ofEnableSizing];
      InitialDir := ExtractFilePath(sProjectName);
      FileName := '';
      Filter := Format(JVCSRES_37s_source_files_4037s4112437s124All_files_4042464241124424642,
        [sIDEName, Filter1, Filter1]);

      DlgResult := ExecuteFavOpenDialogWithMru(FavOpenDialog,
        sBaseRegistryKey + crbMRU + '18');
    end; // with FavOpenDialog1 do begin
    if not DlgResult then
      Exit;

    if FavOpenDialog.Files.Count > 0 then
    begin
      OldProjects := TJVCSMruList.Create;
      OldProjects.MaxSize := MaxCount;
      OldProjects.LoadFromStorage(sBaseRegistryKey + crbMRU + '7');
      for I := 0 to FavOpenDialog.Files.Count - 1 do
        OldProjects.AddString(FavOpenDialog.Files[I]);
      OldProjects.SaveToStorage(sBaseRegistryKey + crbMRU + '7');
      lvUser.Items.Clear;
      for I := 0 to OldProjects.Count - 1 do
        AddLVItem(lvUser, OldProjects.Strings[I]);
      OldProjects.Free;
    end; // if OpenDialog1.Files.Count > 0 then begin
  finally
    FavOpenDialog.Free;
  end;
  Caption := Format(JVCSRES_Recent_Projects47Files_45_37d_items, [lvUser.Items.Count]);
end;

//------------------------------------------------------------------------------

procedure TVCSRecentProjects.btnCancelClick(Sender: TObject);
begin
  SelectedItem := '';
end;

//------------------------------------------------------------------------------

procedure TVCSRecentProjects.lvMRUResize(Sender: TObject);
begin
  lvMRU.Columns[0].Width := lvMRU.Width - 25;
  lvUser.Columns[0].Width := lvMRU.Columns[0].Width;
end;

//------------------------------------------------------------------------------

procedure TVCSRecentProjects.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

end.
