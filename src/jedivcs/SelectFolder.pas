(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: SelectFolder.pas

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
2003/02/12  USchuster - changed DSAMsg with JVCSDialogs in uses clause to use JvDSADialogs
2003/02/18  MGosselink- emptied some .text props
2003/03/05  THensle   - changes for "ConfigStorage" unit
                      - added window pos/size storage
2003/03/09  USchuster - exchanged TjvMruList with TJVCSMruList (mantis #727)
                      - disabled the AutoSave property in rcbxRecent
                        and removed the regkeys (they where wrong and
                        loading and saving is no done with MruListRecent)
                      - removed rcbxRecent.AutoSave.SaveValue
                      - the selected folder will also be inserted into the
                        combobox now
2003/03/15  THuber    - removed filectrl from uses
2003/03/16  USchuster - FileCtrl now for < D6 only
2003/12/28  USchuster - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use constant)
                      - AutoComplete in ComboBox now False
2004/02/24  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/09/17  FHasovic  - Added dxGetText support for localization                      
2004/10/17  USchuster - style cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/10/31  USchuster - moved resourcestrings to JVCSGUIClientResources.pas                      
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 final released ^^^^^^^^^^^^^^^^^^^^^^^^^^
2006/03/26  USchuster - as of now the ModalResult of the "Scan Result" dialog
                        will be evaluated to avoid mantis #3596
2006/12/10  USchuster - added JVCSClientFunctions to uses (as of now it is required for MatchWithFilter)
2007/07/01  USchuster - changes for large fonts (contraints and default size depend now on PixelsPerInch; analog to Mantis #3710)
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2009/12/28  THuber    - added JVCSClientConsts to uses (as some consts were moved from VCSBase there)
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit SelectFolder;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, SystemTreeView, SystemControlPack, ExtCtrls, Menus, Buttons,
  JvCombobox, JvSearchFiles, JVCSMruList, JvExStdCtrls, JVCSForms;

type
  TVCSSelectFolder = class(TJVCSForm)
    Panel1: TPanel;
    Panel2: TPanel;
    lblStatus: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    btnNew: TButton;
    PopupMenu1: TPopupMenu;
    Newfolder1: TMenuItem;
    Rename1: TMenuItem;
    N1: TMenuItem;
    Mapnetworkdir1: TMenuItem;
    Help: TSpeedButton;
    DisconnectNetworkDrive1: TMenuItem;
    Panel3: TPanel;
    SystemTree: TdfsSystemTreeView;
    PanelRecursive: TPanel;
    cbRecursive: TCheckBox;
    cbExclude: TCheckBox;
    edExclude: TEdit;
    cbxFilters: TComboBox;
    spBtnSetFilter: TSpeedButton;
    spBtnExclude: TSpeedButton;
    cbProjectFolders: TCheckBox;
    Label1: TLabel;
    rcbxRecent: TJvComboBox;
    procedure FormCreate(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Rename1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SystemTreeChange(Sender: TObject; Node: TTreeNode);
    procedure Mapnetworkdir1Click(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure DisconnectNetworkDrive1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure rcbxRecentChange(Sender: TObject);
    procedure spBtnSetFilterClick(Sender: TObject);
    procedure cbxFiltersChange(Sender: TObject);
    procedure spBtnExcludeClick(Sender: TObject);
    procedure cbExcludeClick(Sender: TObject);
    procedure cbProjectFoldersClick(Sender: TObject);
  private
    { Private declarations }
    Asked,
    RecursiveSelect: Boolean;
    RecursiveSize: Integer;
    Filters: TStringList;
    CurrentFilter: string;
    MruListRecent: TJVCSMruList;
    { this is the notification function for the directory scan }
    function LogFiles(const Path: string; const SRec: TSearchRec): Boolean;
    procedure GetFileFilters;
  public
    { Public declarations }
    Selection: string;
    HelpContextID: Integer;
    RecursiveList,
    PJFiles: TStringList;
    procedure SetDlgCaption(Value: string);
    procedure SetInitialDir(Value: string);
    procedure SetStatusText(Value: string);
    procedure EnableNewFolder(Value: Boolean);
    procedure EnableRenameFolder(Value: Boolean);
    procedure EnableRecursive(Value: Boolean);
  end;

var
  VCSSelectFolder: TVCSSelectFolder;

implementation

uses
  {$IFNDEF DELPHI6_UP}
  FileCtrl,
  {$ENDIF ~DELPHI6_UP}
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSProcBase, VCSBase, JVCSClientConsts, Options, ListEdit, DirWatch, RekScan,
  JVCSDialogs, ConfigStorage, JVCSGUIClientResources, JVCSClientFunctions;

{$R *.dfm}

procedure TVCSSelectFolder.FormCreate(Sender: TObject);
var
  DlgWidth,
  DlgHeight: Integer;
begin
  try
    Constraints.MinHeight := MulDiv(300, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(300, PixelsPerInch, 96);
    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    if not jvcsReadWindowSize(sBaseRegistryKey + crbWindows, 'SelectFolder',
      DlgWidth, DlgHeight) then
    begin
      DlgWidth := MulDiv(300, PixelsPerInch, 96);
      DlgHeight := MulDiv(300, PixelsPerInch, 96);
    end;
    Width := DlgWidth;
    Height := DlgHeight;

    cbExclude.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbWindows, 'SelectFolder_Exclude', False);
    edExclude.Enabled := cbExclude.Checked;
    spBtnExclude.Enabled := cbExclude.Checked;

    edExclude.Text :=
      jvcsReadString(sBaseRegistryKey + crbFilters, 'Exclude files', dfFolderExclude);

    Selection := '';
    lblStatus.Caption := '';
    btnNew.Visible := True;
    Newfolder1.Enabled := True;
    Screen.Cursor := crHourGlass;
    RecursiveList := TStringList.Create;
    PJFiles := TStringList.Create;
    Filters := TStringList.Create;
    GetFileFilters;

    MruListRecent := TJVCSMruList.CreateEx(sBaseRegistryKey + crbMRU + '23');
    rcbxRecent.Items.Assign(MruListRecent);
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectFolder.FormShow(Sender: TObject);
begin
  Screen.Cursor := crDefault;
  if RecursiveSelect then
    SystemTree.RootFolder := rfFileSystem;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectFolder.SetDlgCaption(Value: string);
begin
  Caption := Value;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectFolder.SetInitialDir(Value: string);
var
  ActDir: string;
begin
  if not DirectoryExists(Value) then
  begin
    GetDir(0, ActDir);
    SystemTree.Selection := ActDir;
  end
  else
    SystemTree.Selection := Value;
  rcbxRecent.Text := AnsiLowerCase(SystemTree.Selection);
  btnOK.Enabled := (rcbxRecent.Text <> '');
end;

//------------------------------------------------------------------------------

procedure TVCSSelectFolder.SetStatusText(Value: string);
begin
  lblStatus.Caption := Value;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectFolder.EnableNewFolder(Value: Boolean);
begin
  btnNew.Visible := Value;
  Newfolder1.Enabled := Value;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectFolder.EnableRenameFolder(Value: Boolean);
begin
  if not Value then
    EnableNewFolder(False);
  SystemTree.ReadOnly := not Value;
  Rename1.Enabled := Value;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectFolder.btnNewClick(Sender: TObject);
var
  NewFolder: string;
begin
  if (SystemTree.Selection = '') then 
    Exit;
  NewFolder := JVCSRES_New_Folder;
  if not InputQuery(JVCSRES_Create_new_folder, Format(JVCSRES_Root58_37s, [
    AnsiLowerCase(CutPathStr(SystemTree.Selection, 35))]), NewFolder) then
    Exit;
  SystemTree.SetFocus;
  if not SystemTree.AddNewNode(SystemTree.Selected, NewFolder, True) then 
  begin
    BeepIfSet;
    MessageBox(WindowHandle, PChar(Format(JVCSRES_JEDI_VCS_cannot_create_the_directory + #13#10 +
      '<%s>.' + #13#10 +
      JVCSRES_Perhaps_there_is_already_a_folder_with_this_name_or_you + #13#10 +
      JVCSRES_do_not_have_the_requested_rights_for_this46, [NewFolder])),
      cMsgBoxCaption, MB_OK or MB_ICONWARNING);
  end; // if not SystemTree.AddNewNode(....
end;

//------------------------------------------------------------------------------

procedure TVCSSelectFolder.btnCancelClick(Sender: TObject);
begin
  Selection := '';
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectFolder.btnOKClick(Sender: TObject);
var 
  DlgMsg, RecSearch: string;
  I, SRes: Integer;
  SRec: TSearchRec;
  SearchPaths: TStringList;

  procedure ShowSearchResult;
  var
    K: Integer;
    ShowResult: Integer;
  begin
    if RecursiveList.Count > 0 then 
    begin
      VCSDirWatch := TVCSDirWatch.Create(Application);
      try
        for K := 0 to PJFiles.Count - 1 do
          VCSDirWatch.OldFiles.Add(PJFiles[K]);
        for K := 0 to RecursiveList.Count - 1 do
          VCSDirWatch.NewFiles.Add(RecursiveList[K]);
        ShowResult := VCSDirWatch.ShowModal;
        RecursiveList.Clear;
        if ShowResult = mrOk then
          for K := 0 to VCSDirWatch.NewFiles.Count - 1 do
            RecursiveList.Add(VCSDirWatch.NewFiles[K]);
      finally
        VCSDirWatch.Free;
      end;

      if RecursiveList.Count > 0 then 
      begin
        if cbRecursive.Checked then 
          RecSearch := JVCSRES_91recursive93 
        else 
          RecSearch := '';
        if cbProjectFolders.Checked then
          DlgMsg := Format(JVCSRES_Searching_in_6037s62_37s, [JVCSRES_Project_folders, ''])
        else
          DlgMsg := Format(JVCSRES_Searching_in_6037s62_37s, [AnsiLowerCase(rcbxRecent.Text), RecSearch]);
        DlgMsg := DlgMsg + #13#10 + Format(JVCSRES_Your_search_criteria_6037s62_will_include_37d_files46 + #13#10 +
          JVCSRES_Are_you_sure_you_want_to_add_all_files_at_once63, [CurrentFilter, RecursiveList.Count]);

        if RecursiveList.Count > 50 then 
        begin
          DlgMsg := DlgMsg + #10#13 +
            JVCSRES_Remember_that_this_may_take_some_time_and_cannot_be_canceld33;
        end;
        UseRegistry := True;
        DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
        case DSAIdentsMessageDlg(DlgMsg
          , mtConfirmation
          , [mbYes, mbNo, mbCancel]
          , 0
          , sBaseRegistryKey + crbMRU + 'Dlgs'
          , 'AddByFolder'
          , idYes
          ) of
          id_Yes:
            begin
              Selection := 'OK';
              Close;
            end;
          id_No:
            Exit;
          id_Cancel:
            begin
              Selection := '';
              Close;
            end;
        end; // case MessageBox....
      end; // if RecursiveList.Count > 0 then begin
    end // if RecursiveList.Count > 0 then begin
    else
    begin
      if cbProjectFolders.Checked then
        DlgMsg := Format(JVCSRES_Searching_in_6037s62_37s, [JVCSRES_Project_folders, ''])
      else
        DlgMsg := Format(JVCSRES_Searching_in_6037s62_37s, [AnsiLowerCase(rcbxRecent.Text), RecSearch]);
      DlgMsg := DlgMsg + #13#10 + Format(JVCSRES_There_were_no_37s_located_that_match_the_search_criteria46,
        [JVCSRES_files]);
      MessageBox(Handle, PChar(DlgMsg), cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
      Exit;
    end;
  end;
begin
  if cbProjectFolders.Checked then 
  begin
    RecursiveList.Clear;
    RecursiveSize := 0;
    Screen.Cursor := crHourGlass;
    SearchPaths := TStringList.Create;
    try
      SearchPaths.Sorted := True;
      SearchPaths.Duplicates := dupIgnore;
      for I := 0 to PJFiles.Count - 1 do
        SearchPaths.Add(ExtractFilePath(PJFiles[I]));
      CurrentFilter := Filters.Values[cbxFilters.Text];

      for I := 0 to SearchPaths.Count - 1 do 
      begin
        SRes := FindFirst(SearchPaths.Strings[I] + '*.*',
          faAnyFile and (not faDirectory), SRec);
        try
          while SRes = 0 do 
          begin
            if (SRec.Name <> '.') and (SRec.Name <> '..') then 
            begin
              if MatchWithFilter(SRec.Name, CurrentFilter) then
              begin
                if (not cbExclude.Checked) or (not MatchWithFilter(SRec.Name,
                  edExclude.Text)) then
                begin
                  RecursiveList.Add(SearchPaths.Strings[I] + SRec.Name);
                  RecursiveSize := RecursiveSize + SRec.Size;
                end;
                // if (not cbExclude.Checked) or (not MatchWithFilter(SRec.Name, edExclude.Text)) then begin
              end; // if MatchWithFilter(SRec.Name, edMask: String) then begin
            end; // if (SRec.Name <> '.') and (SRec.Name <> '..') then begin
            SRes := FindNext(SRec);
          end; // while SRes = 0 do begin
        finally
          FindClose(SRec);
        end;
      end; // for I := 0 to SearchPaths.Count - 1 do begin
    finally
      SearchPaths.Free;
    end;
    Screen.Cursor := crDefault;
    ShowSearchResult;
  end // if cbProjectFolders.Checked then begin
  else 
  begin
    SetBackSlash(rcbxRecent.Text);
    {  --hu
    rcbxRecent.AddMRUString(rcbxRecent.Text);
     }
    if RecursiveSelect then 
    begin
      CurrentFilter := Filters.Values[cbxFilters.Text];
      RecursiveList.Clear;
      RecursiveSize := 0;
      Screen.Cursor := crHourGlass;
      Asked := False;
      FindRecursive(rcbxRecent.Text, '*.*'{rcbxMaskStr.Text}, LogFiles);
      Screen.Cursor := crDefault;
      ShowSearchResult;
    end 
    else 
    begin
      Selection := rcbxRecent.Text;
      Close;
    end;
  end; // else if cbProjectFolders.Checked then begin
  MruListRecent.AddString(rcbxRecent.Text);
  rcbxRecent.Items.Insert(0, rcbxRecent.Text);
end;

//------------------------------------------------------------------------------
// CallBack für FindRecursive

function TVCSSelectFolder.LogFiles(const Path: string; const SRec: TSearchRec): Boolean;
begin
  if not cbRecursive.Checked then 
  begin
    if AnsiLowerCase(SetBackSlash(rcbxRecent.Text)) <>
      AnsiLowerCase(Path) then
    begin
      Result := False;   // proceeded with recursion
      Exit;
    end;
  end;

  if cbExclude.Checked and MatchWithFilter(SRec.Name, edExclude.Text) then 
  begin
    Result := True;
    Exit;
  end;

  if MatchWithFilter(SRec.Name, CurrentFilter) then 
  begin
    RecursiveList.Add(AnsiLowerCase(Path + SRec.Name));
    RecursiveSize := RecursiveSize + SRec.Size;
  end;
  if (not Asked) and (RecursiveList.Count > 500) then 
  begin
    if MessageBox(Handle, PChar(JVCSRES_Your_search_matches_more_than_500_files46 +
      #10#13 + JVCSRES_Continue_anyway63), cMsgBoxCaption, MB_YESNOCANCEL or
      MB_DEFBUTTON2 or MB_ICONWARNING) <> id_Yes then
      Result := False
    else 
    begin
      Asked := True;
      Result := True;
    end;
  end // if RecursiveList.Count > 500 then begin
  else
    Result := True;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectFolder.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then 
  begin
    btnCancel.Click;
    Key := 0;
  end;
  if Key = VK_F1 then
    PerformHelpCommand(Application, HelpContextID);
end;

//------------------------------------------------------------------------------

procedure TVCSSelectFolder.Rename1Click(Sender: TObject);
begin
  SystemTree.Selected.EditText;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectFolder.SystemTreeChange(Sender: TObject;
  Node: TTreeNode);
begin
  rcbxRecent.Text := AnsiLowerCase(SystemTree.Selection);
  btnOK.Enabled := (rcbxRecent.Text <> '');
end;

//------------------------------------------------------------------------------

procedure TVCSSelectFolder.Mapnetworkdir1Click(Sender: TObject);
var 
  ProcResult: Integer;
  ErrMess: string;
begin
  ProcResult := WNetConnectionDialog(WindowHandle, RESOURCETYPE_DISK);
  if ProcResult = NO_ERROR then 
  begin
    SystemTree.Reset;
  end // if ProcResult = NO_ERROR then begin
  else 
  begin
    ErrMess := '';
    case GetLastError of
      ERROR_NO_NETWORK :
        ErrMess := JVCSRES_No_network_is_present46;
      ERROR_EXTENDED_ERROR :
        ErrMess := JVCSRES_A_network45specific_error_occurred46;
      ERROR_INVALID_PASSWORD :
        ErrMess := JVCSRES_The_specified_password_is_invalid46;
      ERROR_NOT_ENOUGH_MEMORY :
        ErrMess := JVCSRES_There_is_insufficient_memory_to_start_the_dialog_box46;
    end; // case GetLastError of
    if ErrMess <> '' then 
    begin
      BeepIfSet;
      MessageBox(WindowHandle, PChar(ErrMess), cMsgBoxCaption, MB_OK or MB_ICONWARNING);
    end; // if ErrMess = '' then begin
  end; // else if ProcResult = NO_ERROR then begin
end;

//------------------------------------------------------------------------------

procedure TVCSSelectFolder.DisconnectNetworkDrive1Click(Sender: TObject);
begin
  if WNetDisconnectDialog(WindowHandle, RESOURCETYPE_DISK) = NO_ERROR then
    SystemTree.Reset;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectFolder.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSSelectFolder.EnableRecursive(Value: Boolean);
begin
  PanelRecursive.Visible := Value;
  RecursiveSelect := Value;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectFolder.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  jvcsWriteWindowSize(sBaseRegistryKey + crbWindows, 'SelectFolder',
    Width, Height);

  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'SelectFolder_Exclude',
    cbExclude.Checked);
  jvcsWriteString(sBaseRegistryKey + crbFilters, 'Exclude files',
    edExclude.Text);
end;

//------------------------------------------------------------------------------

procedure TVCSSelectFolder.FormDestroy(Sender: TObject);
begin
  RecursiveList.Free;
  PJFiles.Free;
  Filters.Free;
  MruListRecent.Free;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectFolder.rcbxRecentChange(Sender: TObject);
begin
  SystemTree.Selection := rcbxRecent.Text;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectFolder.GetFileFilters;
var 
  Filter1, Filter2, CustomFilter, CurrentFilterName: string;
  I: Integer;
begin
  Filters.Clear;
  cbxFilters.Items.Clear;

  Filter1 :=
    jvcsReadString(sBaseRegistryKey + crbFilters, 'Delphi files', dfDelphiMod);
  Filter2 :=
    jvcsReadString(sBaseRegistryKey + crbFilters, 'AddProjectFiles', dfAddMod);

  CurrentFilterName := JVCSRES_All_files_4042464241;
  cbxFilters.Items.Add(CurrentFilterName);
  Filters.Add(CurrentFilterName + '=*.*');
  CurrentFilterName := Format(JVCSRES_37s_source_files_4037s41, [sIDEName, Filter1]);
  cbxFilters.Items.Add(CurrentFilterName);
  Filters.Add(CurrentFilterName + '=' + Filter1);
  CurrentFilterName := Format(JVCSRES_Other_source_files_4037s41, [Filter2]);
  cbxFilters.Items.Add(CurrentFilterName);
  Filters.Add(CurrentFilterName + '=' + Filter2);
  I := 0;
  repeat
    Inc(I);
    CustomFilter :=
      jvcsReadString(sBaseRegistryKey + crbFilters + '\Custom', 'Custom' + IntToStr(I), '');
    if (CustomFilter <> '') then
    begin
      CurrentFilterName := Copy(CustomFilter, 1, Pos('|', CustomFilter) - 1);
      System.Delete(CustomFilter, 1, Pos('|', CustomFilter));
      cbxFilters.Items.Add(CurrentFilterName + ' (' + CustomFilter + ')');
      Filters.Add(CurrentFilterName + ' (' + CustomFilter + ')=' + CustomFilter);
    end;
  until (CustomFilter = '');
  cbxFilters.ItemIndex := 0;
  cbxFilters.Hint := cbxFilters.Text;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectFolder.spBtnSetFilterClick(Sender: TObject);
begin
  VCSOptions := TVCSOptions.Create(Application);
  try
    VCSOptions.DefaultSheet := cspFilter;
    VCSOptions.ShowModal;
  finally
    VCSOptions.Free;
  end;
  GetFileFilters;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectFolder.cbxFiltersChange(Sender: TObject);
begin
  cbxFilters.Hint := cbxFilters.Text;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectFolder.spBtnExcludeClick(Sender: TObject);
var 
  DlgResult: Integer;
  EditString: string;
begin
  EditString := edExclude.Text;
  VCSListEdit := TVCSListEdit.Create(Application);
  try
    VCSListEdit.Left := Left + 40;
    VCSListEdit.Top := Top + 40;
    VCSListEdit.SetHint(JVCSRES_Add_by_folder_45_exclude_files);
    VCSListEdit.EnablePathButton(False);
    VCSListEdit.ListString := EditString;
    DlgResult := VCSListEdit.ShowModal;
    EditString := VCSListEdit.ListString;
  finally
    VCSListEdit.Free;
  end;
  if DlgResult = mrOk then
    edExclude.Text := EditString;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectFolder.cbExcludeClick(Sender: TObject);
begin
  edExclude.Enabled := cbExclude.Checked;
  spBtnExclude.Enabled := cbExclude.Checked;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectFolder.cbProjectFoldersClick(Sender: TObject);
begin
  if cbProjectFolders.Checked and (PJFiles.Count = 0) then 
  begin
    MessageBox(WindowHandle, PChar(Format(JVCSRES_There_are_currently_no_known_project_folders_for_6037s6246 + #13#10 +
      JVCSRES_Probably_the_project_is_still_empty46, [sProjectName])),
      cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
    cbProjectFolders.Checked := False;
  end;
  rcbxRecent.Enabled := not cbProjectFolders.Checked;
  if rcbxRecent.Enabled then 
    rcbxRecent.Color := clWindow
  else 
    rcbxRecent.Color := clBtnFace;
  cbRecursive.Enabled := not cbProjectFolders.Checked;
  SystemTree.Enabled := not cbProjectFolders.Checked;
  if SystemTree.Enabled then 
    SystemTree.Color := clWindow
  else 
    SystemTree.Color := clBtnFace;
  btnOK.Enabled := cbProjectFolders.Checked;
end;

end.
