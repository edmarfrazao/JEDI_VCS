(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: UsedUnits.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS: Thomas Huber (Thomas_D_Huber@t-online.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
May/05:
- USc: doesn't care about ifdef's and thatswhy it parses include and resource tokens
  which are IFDEFed for Linux/Unix
  example: resource files in JVCL which look like this example from JvSpin.pas

  {$IFDEF MSWINDOWS}
  {$R ..\Resources\JvSpin.Res}
  {$ENDIF MSWINDOWS}
  {$IFDEF UNIX}
  {$R ../Resources/JvSpin.Res}
  {$ENDIF UNIX}
  and that looks like this in the module list
  icon: add icon module: ../resources/jvspin.res Path: JVCLDir\
- USc: resources with path will look like this in the list if the not exist
  icon: not found icon module: JVCLDir\Resource\JvSpin Path: not found
  should it better look like this?
  icon: not found icon module: JvSpin.Res Path: JVCLDir\Resource\
- USc: .dpr uses parsing is not correct (wrong in handling - I will explain this later)
ToDo
- the Standalone version still needs some work (mainly search paths)
- move IDEPlaceholder, SearchPath and .cfg parsing to JVCSIDE...?
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FreeVCS code to JEDI VCS
2003/03/09  THensle   - changes for "ConfigStorage" unit
2003/04/08  USchuster - changes for IDEInterface
2003/08/22  USchuster - mantis #1061
2003/10/17  USchuster - fixed include/resource parsing bug which was caused by
                        the migration to a new mwpaslex version
                      - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes
                      - compiler hints & warnings
2004/03/14  USchuster - 'ulist.fvc' -> cParserUnitSkipListFile
                      - minor style cleaning (casing and comments)
2004/09/17  FHasovic  - Added dxGetText support for localization                      
2004/10/08  USchuster - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/10/30  USchuster - moved JvGnugettext to uses in implementation section
2004/11/02  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC1 was released ^^^^^^^^^^^^^^^^^^^^^^^^^^^
2005/02/26  THuber    - use replace s A p pDirectory with ..JVCSIDESettings.IDEAppFileDir
                      - partly use of JVCSDebug Tracefunctions
                      - now M e ssageBoxes from JVCSDialogs
                      - UUDEBUG directive removed, use DEBUG instead
2005/03/01  Victorious- {$IFDEF DEBUG}                      
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC2 was released ^^^^^^^^^^^^^^^^^^^^^^^^^^^
2005/05/21  USchuster - fixed search path creation(double separators at the end and
                        broken IDE placeholder replacement) (mantis #2927)
                      - ParseUnit does now add include and resource files with path
                      - fixed adding of new search path to search path edit
                        (path was always added also if it was still in the edits "list")
2005/10/16  USchuster - it is now possible to sort the listview by state (mantis #3269)
2007/07/01  USchuster - changes for large fonts (contraints and default size depend now on PixelsPerInch; analog to Mantis #3710)
2008/06/22  USchuster - first changes for usage in Standalone client (Mantis #4380)
2011/01/15  USchuster - changed font to Tahoma                        
2012/07/08  AKroeber  - changed AnsiCrLf to sLineBreak (avoid using of JclAnsiString.pas - should work from Delphi 6 to XE2)
                        
-----------------------------------------------------------------------------*)

unit UsedUnits;

{$I jedi.inc}
{$I compopt.inc}
{$IFDEF DELPHI6_UP}
  {$WARN UNIT_PLATFORM OFF}
  {$WARN SYMBOL_PLATFORM OFF}
{$ENDIF DELPHI6_UP}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ImgList, ComCtrls, EnhListView, Buttons, StdCtrls, ExtCtrls, Menus;

type
  TVCSUsedUnits = class(TForm)
    SysImageList: TImageList;
    StateImageList: TImageList;
    Panel1: TPanel;
    btnClose: TButton;
    btnParse: TButton;
    btnDefFilter: TButton;
    cbFilter: TCheckBox;
    lvUnits: TdfsEnhListView;
    edSearchPath: TEdit;
    Label1: TLabel;
    btnAdd: TButton;
    cbRecursive: TCheckBox;
    Help: TSpeedButton;
    btnReport: TButton;
    btnEdit: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnParseClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure lvUnitsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnDefFilterClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure HelpTopics1Click(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure btnReportClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure lvUnitsSortItems(Sender: TObject; Item1, Item2: TListItem;
      SortColumn: Integer; var SortAs: TSortAs; var CompResult: Integer);
  private
    { Private declarations }
    FCreating: Boolean;
    UsedUnits,
    CoreProjectUnits,
    ProjectUnits,
    SearchPaths: TStringList;
    procedure GetCoreProjectUnits;
    procedure GetSearchPaths;
    procedure ExecuteParse(const Step: string);
    procedure ParseUnit(const FileName: string);
    function GetListViewString: string;
  public
    { Public declarations }
    SelectedUnits: TStringList;
    procedure RestrictSize(var Msg: TMessage); message WM_GETMINMAXINFO;
  end;

var
  VCSUsedUnits: TVCSUsedUnits;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  {$IFDEF DEBUG}
  JVCSDebug,
  {$ENDIF DEBUG}
  VCSBase, ShellAPI, mwPasLex, mwPasLexTypes,
  {$IFDEF IDEDLL}
  JVCSIDEInterface,
  {$ENDIF IDEDLL}
  Progress, UnitFilter, FileCtrl,
  VCSProcBase, SelectFolder, HandleBlob, DBModule, SimpleReport, ListEdit, Registry, ConfigStorage,
  JclFileUtils, JclStrings, JVCSDialogs, JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSUsedUnits.FormCreate(Sender: TObject);
var
  sfi: TSHFileInfo;
  DlgTop, DlgLeft, DlgWidth, DlgHeight: Integer;
begin
  VCSProgress := nil;
  try
    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    cbFilter.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbWindows, 'UsedUnits_Filter', True);
    cbRecursive.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbWindows, 'UsedUnits_Recursive', False);

    if not jvcsReadWindowPosAndSize(sBaseRegistryKey + crbWindows, 'UsedUnits',
      DlgTop, DlgLeft, DlgWidth, DlgHeight) then
    begin
      DlgTop := (Screen.Height - Height) div 2;
      DlgLeft := (Screen.Width - Width) div 2;
      DlgWidth := MulDiv(540, PixelsPerInch, 96);
      DlgHeight := MulDiv(260, PixelsPerInch, 96);
    end;
    Top := DlgTop;
    Left := DlgLeft;
    Width := DlgWidth;
    Height := DlgHeight;

    with lvUnits do
    begin
      Columns[0].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'UsedUnits_Col1.0', 40);
      Columns[1].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'UsedUnits_Col1.1', 150);
      Columns[2].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'UsedUnits_Col1.2', 300);
    end;

    {$IFDEF CUSTOMDRIVE}
    sDriveSubst := RegReadString(HKCU, sBaseRegistryKey + crbProjects +
      ExtractFileName(sProjectName), 'LocalDrive', '');
    if (sDriveSubst = '') then
      sDriveSubst := RegReadString(HKCU, sBaseRegistryKey + crbOptions,
        'LocalDrive', '');
    {$ENDIF CUSTOMDRIVE}

    SelectedUnits := TStringList.Create;
    CoreProjectUnits := TStringList.Create;
    CoreProjectUnits.Sorted := True;
    CoreProjectUnits.Duplicates := dupIgnore;
    ProjectUnits := TStringList.Create;
    ProjectUnits.Sorted := True;
    ProjectUnits.Duplicates := dupIgnore;
    UsedUnits := TStringList.Create;
    UsedUnits.Sorted := True;
    UsedUnits.Duplicates := dupIgnore;
    SearchPaths := TStringList.Create;
    SearchPaths.Sorted := True;
    SearchPaths.Duplicates := dupIgnore;
    FCreating := True;
    //Systemsymbole in eine TImageList-Komponente einlesen
    SysImageList.Handle := SHGetFileInfo('', 0,sfi, SizeOf(TSHFileInfo),
      SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
    SysImageList.ShareImages := True;

    Caption := Format(JVCSRES_Used_modules_45_37s, [AnsiLowerCase(ExtractFileName(sProjectName))]);
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSUsedUnits.FormActivate(Sender: TObject);
begin
  if Assigned(VCSProgress) then
    SetForeGroundWindow(VCSProgress.Handle);
  Application.ProcessMessages;
  if FCreating then 
  begin
    Screen.Cursor := crHourGlass;
    FCreating := False;
    btnAdd.Enabled := False;
    GetSearchPaths;
    Screen.Cursor := crDefault;
  end; // if FCreating then begin
end;

//------------------------------------------------------------------------------

procedure TVCSUsedUnits.GetCoreProjectUnits;
var
  I: Integer;
  {$IFDEF IDEDLL}
  CurrentFile: string;
  {$ENDIF IDEDLL}
  UserModules: TStringList;
begin
  UserModules := TStringList.Create;
  CoreProjectUnits.Clear;

  {$IFDEF IDEDLL}
  for I := 0 to IDEInterface.GetUnitCount - 1 do
  begin
    CurrentFile := IDEInterface.GetUnitName(I);
    if (CurrentFile <> '') and
      (IsIDEUnit(CurrentFile) or
      IsIDEProject(CurrentFile, sProjectName)) then
      CoreProjectUnits.Add(AnsiLowerCase(CurrentFile));
  end; // for I := 0 to IDEInterface.GetUnitCount - 1 do begin
  {$ENDIF IDEDLL}

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
    if (AnsiLowerCase(ExtractFileExt(UserModules.Strings[I])) = ('.' + sIDEUnit)) or
      (AnsiLowerCase(ExtractFileExt(UserModules.Strings[I])) = '.inc') or
      (AnsiLowerCase(ExtractFileExt(UserModules.Strings[I])) = '.res') then
      CoreProjectUnits.Add(AnsiLowerCase(UserModules.Strings[I]));

  UserModules.Free;
end;

//------------------------------------------------------------------------------

procedure TVCSUsedUnits.GetSearchPaths;
{$IFDEF IDEDLL}
var
  CFGFile, CurrLine, CurrPath, IDEPlaceHld: string;
  Reg: TRegistry;
  RegPaths: TStringList;
  CFGF: TextFile;
  I: Integer;
begin
  SearchPaths.Clear;
  if not DirectoryExists(IDEInterface.JVCSIDESettings.IDEAppFileDir) then
  begin
    WarnMessageBox( JVCSRES_JEDI_VCS_cannot_detect_the_name_of_Delphi39s_base_installation_folder46 + sLineBreak +
                    JVCSRES_This_function_is_only_supported_for_known_IDE_products46
                  );
  end;

  if IDEInterface.JVCSIDESettings.IsIDEBCB then
  begin
    IDEPlaceHld := '$(BCB)'
  end
  else
  if IDEInterface.JVCSIDESettings.IsIDEDelphi then
  begin
    IDEPlaceHld := '$(delphi)';
  end;

  // Project's path
  SearchPaths.Add(AnsiLowerCase(ExtractFilePath(IDEInterface.GetProjectName)));
  // Search path from Reg
  if sIDERegistryKey <> '' then
  begin
    Reg := TRegistry.Create;
    with Reg do
    begin
      try
        RootKey := HKEY_CURRENT_USER;
        OpenKeyReadOnly(sIDERegistryKey + '\Library');
        try
          if ValueExists('Search Path') then
            CurrLine := ReadString('Search Path')
          else
            CurrLine := '';
        except;
        end;
        CloseKey;
      finally
        Free;
      end; // try finally
    end; // with Reg do begin
  end; // if BaseRegistryKey <> '' then begin
  if CurrLine <> '' then
  begin
    RegPaths := TStringList.Create;
    RegPaths.Sorted := True;
    RegPaths.Duplicates := dupIgnore;
    repeat // until Pos(';', CurrLine) = 0;
      CurrPath := Copy(CurrLine, 1, Pos(';', CurrLine) - 1);
      Delete(CurrLine, 1, Pos(';', CurrLine));
      RegPaths.Add(AnsiLowerCase(PathAddSeparator(CurrPath)));
    until Pos(';', CurrLine) = 0;
    RegPaths.Add(AnsiLowerCase(PathAddSeparator(CurrLine)));

    for I := 0 to RegPaths.Count - 1 do
    begin
      CurrLine := RegPaths.Strings[I];
      if Pos(IDEPlaceHld, CurrLine) <> 0 then
      begin
        Delete(CurrLine, 1, Pos(IDEPlaceHld, CurrLine) + Length(IDEPlaceHld));
        CurrPath := PathAddSeparator(IDEInterface.JVCSIDESettings.IDERootDir) + CurrLine;
        if DirectoryExists(CurrPath) then
          SearchPaths.Add(AnsiLowerCase(PathAddSeparator(CurrPath)));
      end; // if Pos(IDEPlaceHld, CurrLine) <> 0 then begin
      if DirectoryExists(CurrLine) then
        SearchPaths.Add(AnsiLowerCase(PathAddSeparator(CurrLine)));
    end; // for I := 0 to RegPaths.Count - 1 do begin
    RegPaths.Free;
  end; // if CurrLine <> '' then begin

  // Browse path from Reg
  if sIDERegistryKey <> '' then
  begin
    Reg := TRegistry.Create;
    with Reg do
    begin
      try
        RootKey := HKEY_CURRENT_USER;
        OpenKeyReadOnly(sIDERegistryKey + '\Library');
        try
          if ValueExists('Browsing Path') then
            CurrLine := ReadString('Browsing Path')
          else
            CurrLine := '';
        except;
        end;
        CloseKey;
      finally
        Free;
      end; // try finally
    end; // with Reg do begin
  end; // if sIDERegistryKey <> '' then begin
  if CurrLine <> '' then
  begin
    RegPaths := TStringList.Create;
    RegPaths.Sorted := True;
    RegPaths.Duplicates := dupIgnore;
    repeat // until Pos(';', CurrLine) = 0;
      CurrPath := Copy(CurrLine, 1, Pos(';', CurrLine) - 1);
      Delete(CurrLine, 1, Pos(';', CurrLine));
      RegPaths.Add(AnsiLowerCase(PathAddSeparator(CurrPath)));
    until Pos(';', CurrLine) = 0;
    RegPaths.Add(AnsiLowerCase(PathAddSeparator(CurrLine)));

    for I := 0 to RegPaths.Count - 1 do
    begin
      CurrLine := RegPaths.Strings[I];
      if Pos(IDEPlaceHld, CurrLine) <> 0 then
      begin
        Delete(CurrLine, 1, Pos(IDEPlaceHld, CurrLine) + Length(IDEPlaceHld));
        CurrPath := PathAddSeparator(IDEInterface.JVCSIDESettings.IDERootDir) + CurrLine;
        if DirectoryExists(CurrPath) then
          SearchPaths.Add(AnsiLowerCase(PathAddSeparator(CurrPath)));
      end; // if Pos(IDEPlaceHld, CurrLine) <> 0 then begin
      if DirectoryExists(CurrLine) then
        SearchPaths.Add(AnsiLowerCase(PathAddSeparator(CurrLine)));
    end; // for I := 0 to RegPaths.Count - 1 do begin
    RegPaths.Free;
  end; // if CurrLine <> '' then begin

  // Search path from cfg file
  CFGFile := ChangeFileExt(IDEInterface.GetProjectName, '.cfg');
  if FileExists(CFGFile) then
  begin
    AssignFile(CFGF, CFGFile);
    Reset(CFGF);
    while not Eof(CFGF) do
    begin
      ReadLn(CFGF, CurrLine);
      if (Copy(CurrLine, 1, 2) = '-U') or (Copy(CurrLine, 1, 2) = '-O') or
        (Copy(CurrLine, 1, 2) = '-I') or (Copy(CurrLine, 1, 2) = '-R') then
      begin
        Delete(CurrLine, 1, Pos('"', CurrLine));
        CurrLine := Copy(CurrLine, 1, Pos('"', CurrLine) - 1);
        repeat // until Pos(';', CurrLine) = 0;
          CurrPath := Copy(CurrLine, 1, Pos(';', CurrLine) - 1);
          Delete(CurrLine, 1, Pos(';', CurrLine));
          if DirectoryExists(CurrPath) then
            SearchPaths.Add(AnsiLowerCase(PathAddSeparator(CurrPath)));
        until Pos(';', CurrLine) = 0;
        if DirectoryExists(CurrLine) then
          SearchPaths.Add(AnsiLowerCase(PathAddSeparator(CurrLine)));
      end; // if (Copy(CurrLine, 1, 2) = '-U')....
    end; // while not EoF(CFGF) do begin
    CloseFile(CFGF);
  end; // if FileExists(CFGFile) then begin
  for I := 0 to SearchPaths.Count - 1 do
    edSearchPath.Text := edSearchPath.Text + SearchPaths.Strings[I] + ';';
{$ELSE}
begin
  SearchPaths.Clear;
{$ENDIF IDEDLL}
end;

//------------------------------------------------------------------------------

procedure TVCSUsedUnits.btnParseClick(Sender: TObject);
var 
  I, Step, ParsedUnits: Integer;
label
  RecScanStart;
begin
  btnClose.Enabled := False;
  GetCoreProjectUnits;
  ProjectUnits.Clear;
  for I := 0 to CoreProjectUnits.Count - 1 do
    ProjectUnits.Add(CoreProjectUnits.Strings[I]);

  UsedUnits.Clear;
  Step := 0;
  lvUnits.Items.BeginUpdate;
  try
    if cbRecursive.Checked then 
    begin
      RecScanStart :
      Inc(Step);
      ExecuteParse('#' + IntToStr(Step));
      ParsedUnits := ProjectUnits.Count;
      with lvUnits do 
      begin
        for I := 0 to Items.Count - 1 do 
        begin
          if (Items[I].StateIndex <> 2) and
            ((ExtractFileExt(Items[I].SubItems[0]) = ('.' + sIDEUnit)) or
            (ExtractFileExt(Items[I].SubItems[0]) = '.inc')) then
            ProjectUnits.Add(Items[I].SubItems[1] + Items[I].SubItems[0]);
        end; // for I := 0 to lvUnits.Items.Count - 1 do begin
      end; // with lvUnits do begin
      if ProjectUnits.Count > ParsedUnits then 
        goto RecScanStart;
    end // if cbRecursive.Checked then begin
    else 
      ExecuteParse('');
  finally
    lvUnits.Items.EndUpdate;
  end;
  btnClose.Enabled := True;
end;

//------------------------------------------------------------------------------

procedure TVCSUsedUnits.ExecuteParse(const Step: string);
var
  I, J, K: Integer;
  CurrItem, CurrPath: string;
  UCFilters, Filters: TStringList;
  NewItem: TListItem;
  sfi: TSHFileInfo;
  FilterOut: Boolean;
begin
  lvUnits.Items.Clear;

  Filters := TStringList.Create;
  try
    Filters.Sorted := True;
    Filters.Duplicates := dupIgnore;

    // Filter einlesen
    UCFilters := TStringList.Create;
    try
      if FileExists(sDLLDirectory + cParserUnitSkipListFile) then
      begin
        try
          UCFilters.LoadFromFile(sDLLDirectory + cParserUnitSkipListFile);
        except
          on E:
          Exception do
          begin
            UCFilters.Clear;
            BeepIfSet;
            ErrorMessageBox ( Format( JVCSRES_Reading_file_6037s62 + sLineBreak +
                                      JVCSRES_raised_exception58 + sLineBreak + '%s.'
                                    , [sDLLDirectory + cParserUnitSkipListFile, E.Message]
                                    )
                            );
          end;
        end;
      end; // if FileExists(sDLLDirectory + cParserUnitSkipListFile) then begin

      for I := 0 to UCFilters.Count - 1 do
        Filters.Add(AnsiLowerCase(UCFilters.Strings[I]));
    finally
      UCFilters.Free;
    end;

    VCSProgress := TVCSProgress.Create(Self);
    try
      VCSProgress.SetText(JVCSRES_Parsing_the_source_files464646 + Step);
      VCSProgress.SetPBMax(ProjectUnits.Count);
      VCSProgress.SetPBPos(0);
      VCSProgress.Left := Left + 40;
      VCSProgress.Top := Top + 60;
      VCSProgress.Show;
      Application.ProcessMessages;

      for I := 0 to ProjectUnits.Count - 1 do
      begin
        if FileExists(ProjectUnits.Strings[I]) then 
        begin
          {$IFDEF DEBUG}
          TraceAlwaysFmt('UU Parse Unit: %s', [ProjectUnits.Strings[I]]);
          {$ENDIF DEBUG}
          if IsIDEUnit(ProjectUnits.Strings[I]) or
            IsIDEProject(ProjectUnits.Strings[I], sProjectName) or
            (ExtractFileExt(AnsiLowerCase(ProjectUnits.Strings[I])) = '.inc') then
            ParseUnit(ProjectUnits.Strings[I]);
        end;
        VCSProgress.SetPBPos(I);
      end;

      VCSProgress.SetPBPos(0);
      VCSProgress.SetText(JVCSRES_Building_Listview464646 + Step);
      Application.ProcessMessages;
      for I := 0 to UsedUnits.Count - 1 do 
      begin
        CurrItem := UsedUnits.Strings[I];
        // Projekt (.dpr/ .dpk) File überspringen
        {$IFDEF IDEDLL}
        if AnsiLowerCase(ChangeFileExt(CurrItem, '')) <>
          AnsiLowerCase(ChangeFileExt(ExtractFileName(IDEInterface.GetProjectName), '')) then
        {$ENDIF IDEDLL}
        begin
          // Filter
          if cbFilter.Checked then 
          begin
            FilterOut := False;
            for K := 0 to Filters.Count - 1 do 
            begin
              if AnsiLowerCase(Filters.Strings[K]) =
                AnsiLowerCase(ChangeFileExt(CurrItem, '')) then
              begin
                FilterOut := True;
                Break;
              end;
            end;
          end 
          else 
            FilterOut := False;
          // Wenn alles OK, neuer Eintrag in Listview
          if not FilterOut then 
          begin
            NewItem := lvUnits.Items.Add;
            CurrPath := '';
            if (ExtractFilePath(CurrItem) <> '') and FileExists(CurrItem) then
            begin
              CurrPath := ExtractFilePath(CurrItem);
              CurrItem := ExtractFileName(CurrItem);
            end
            else
            if ExtractFileExt(CurrItem) = '' then 
            begin
              for J := 0 to SearchPaths.Count - 1 do 
              begin
                if FileExists(SearchPaths.Strings[J] + CurrItem + '.' + sIDEUnit) then 
                begin
                  CurrItem := CurrItem + '.' + sIDEUnit;
                  CurrPath := SearchPaths.Strings[J];
                  Break;
                end; // if FileExists(SearchPaths.Strings[J] + CurrItem) then begin
              end; // for J := 0 to SearchPaths.Count - 1 do begin
              if CurrPath = '' then 
              begin
                for J := 0 to SearchPaths.Count - 1 do 
                begin
                  if FileExists(SearchPaths.Strings[J] + CurrItem + '.dcu') then
                  begin
                    CurrItem := CurrItem + '.dcu';
                    CurrPath := SearchPaths.Strings[J];
                    Break;
                  end; // if FileExists(SearchPaths.Strings[J] + CurrItem) then begin
                end; // for J := 0 to SearchPaths.Count - 1 do begin
              end; // if CurrPath = '' then begin
            end // if ExtractFileExt(CurrItem) = '' then begin
            else 
            begin
              for J := 0 to SearchPaths.Count - 1 do
              begin
                if FileExists(SearchPaths.Strings[J] + CurrItem) then 
                begin
                  CurrPath := SearchPaths.Strings[J];
                  Break;
                end; // if FileExists(SearchPaths.Strings[J] + CurrItem) then begin
              end; // for J := 0 to SearchPaths.Count - 1 do begin
            end; // else if ExtractFileExt(CurrItem) = '' then begin
            // Datei gefunden ?
            if CurrPath <> '' then 
            begin
              NewItem.SubItems.Add(CurrItem);
              NewItem.SubItems.Add(CurrPath);
              SHGetFileInfo(PChar(CurrPath + CurrItem), 0, sfi, SizeOf(sfi),
                SHGFI_SYSICONINDEX or SHGFI_SMALLICON or SHGFI_DISPLAYNAME);
              NewItem.ImageIndex := sfi.IIcon;
              // Datei bereits im Projekt ?
              if ExtractFileExt(CurrItem) <> '.dcu' then 
              begin
                if CoreProjectUnits.IndexOf(AnsiLowerCase(CurrPath + CurrItem)) <> -1 then
                begin
                  NewItem.Caption := JVCSRES_Project_member;
                  NewItem.StateIndex := 3;
                end
                else
                begin
                  NewItem.Caption := JVCSRES_No_project_member;
                  NewItem.StateIndex := 0;
                end;
              end 
              else 
                NewItem.StateIndex := 2;
            end // if CurrPath <> '' then begin
            // Datei nicht gefunden
            else 
            begin
              NewItem.Caption := JVCSRES_Not_found;
              NewItem.SubItems.Add(ChangeFileExt(CurrItem, ''));
              NewItem.SubItems.Add(JVCSRES_Not_found);
              NewItem.StateIndex := 2;
              NewItem.ImageIndex := -1;
            end; // else if CurrPath <> '' then begin
          end; // if not FilterOut then begin
        end; // if AnsiLowerCase(ChangeFileExt(CurrItem, '')) <>....
        VCSProgress.SetPBPos(I);
      end;
    finally
      FreeAndNil(VCSProgress);
    end;
  finally
    Filters.Free;
  end;
  if cbFilter.Checked then
    Caption := Format(JVCSRES_Used_modules_45_37s_45_37d_modules_40filtered41,
      [AnsiLowerCase(ExtractFileName(sProjectName)), lvUnits.Items.Count])
  else
    Caption := Format(JVCSRES_Used_modules_45_37s_45_37d_modules,
      [AnsiLowerCase(ExtractFileName(sProjectName)), lvUnits.Items.Count]);
end;

//------------------------------------------------------------------------------

procedure TVCSUsedUnits.ParseUnit(const FileName: string);
var
  MS: TMemoryStream;
  {$IFNDEF IDEDLL}
  FS: TFileStream;
  {$ENDIF ~IDEDLL}
  PasParser: TmwPasLex;
  UnitName, CurrToken, ParseToken, RelativePath, NewSearchPath: string;

  procedure AddToUsedUnits(const AToken: string);
  var
    S, S2: string;
  begin
    S2 := ExtractFilePath(AToken);
    if S2 <> '' then
    begin
      S := PathAddSeparator(ExtractFilePath(FileName));
      S := PathCanonicalize(S + PathAddSeparator(S2));
      S := PathAddSeparator(S) + ExtractFileName(AToken);
      UsedUnits.Add(AnsiLowerCase(S));
    end
    else
      UsedUnits.Add(AnsiLowerCase(AToken));
  end;

begin
  UnitName := ExtractFileName(FileName);
  UnitName := ChangeFileExt(UnitName, '');
  MS := TMemoryStream.Create;
  try
    {$IFDEF IDEDLL}
    IDESource2Stream(FileName, MS);
    {$ELSE}
    FS := TFileStream.Create(FileName, fmOpenRead);
    try
      MS.CopyFrom(FS, 0);
      MS.Position := 0;
    finally
      FS.Free;
    end;
    {$ENDIF IDEDLL}
    PasParser := TmwPasLex.Create;
    try
      PasParser.Origin := MS.Memory;
      //--- C++ Builder --------------------------------------------------------
      if bIsCppBuilder then
      begin
        //hu01.12.2002         while PasParser.TokenID <> tkNull do
        while PasParser.TokenID <> ptNull do
        begin
          PasParser.NextNoJunk;
        end; // while PasParser.TokenID <> tkNull do
      end // if bIsCppBuilder then begin
      else 
      begin
        //--- Delphi -----------------------------------------------------------
        //hu01.12.2002         while not (PasParser.TokenID in [tkUnit, tkNull, tkLibrary, tkProgram]) do
        while not (PasParser.TokenID in [ptUnit, ptNull, ptLibrary, ptProgram]) do
        begin
          PasParser.NextNoJunk;
        end;
        //hu01.12.2002         if PasParser.TokenID in [tkUnit, tkLibrary, tkProgram] then
        if PasParser.TokenID in [ptUnit, ptLibrary, ptProgram] then
        begin
          PasParser.NextNoJunk;
          //hu01.12.2002           if PasParser.TokenID = tkIdentifier then
          if PasParser.TokenID = ptIdentifier then 
          begin // Unitname
            {$IFDEF DEBUG}
            TraceAlwaysFmt('UU Parse 1: %s',[PasParser.Token]);
            {$ENDIF DEBUG}
            UsedUnits.Add(AnsiLowerCase(PasParser.Token));
          end;
        end;
        //hu01.12.2002         while PasParser.TokenID <> tkNull do
        while PasParser.TokenID <> ptNull do
        begin
          //hu01.12.2002           if PasParser.TokenID = tkCompDirect then
          if PasParser.TokenID in [ptIncludeDirect, ptResourceDirect] then
          begin
            if UpperCase(Copy(PasParser.Token, 1, 4)) = '{$I ' then // Include files
            begin
              CurrToken := PasParser.Token;
              Delete(CurrToken, 1, 4);
              //Test für *.xx files
              if (Length(CurrToken) > 0) and (CurrToken[1] = '*') then
              begin
                System.Delete(CurrToken, 1, 1);
                CurrToken := UnitName + CurrToken;
              end;

              ParseToken := Copy(CurrToken, 1, Pos('}', CurrToken) - 1);
              {$IFDEF DEBUG}
              TraceAlwaysFmt('UU Parse 3: %s', [ParseToken]);
              {$ENDIF DEBUG}
              AddToUsedUnits(ParseToken);
            end; // if Copy(PasParser.Token, 1, 4) = '{$I ' then
            if UpperCase(Copy(PasParser.Token, 1, 10)) = '{$INCLUDE ' then
            // Include files
            begin
              CurrToken := PasParser.Token;
              Delete(CurrToken, 1, 10);
              //Test für *.xx files
              if (Length(CurrToken) > 0) and (CurrToken[1] = '*') then
              begin
                System.Delete(CurrToken, 1, 1);
                CurrToken := UnitName + CurrToken;
              end;

              ParseToken := Copy(CurrToken, 1, Pos('}', CurrToken) - 1);
              {$IFDEF DEBUG}
              TraceAlwaysFmt('UU Parse 3a: %s',[ParseToken]);
              {$ENDIF DEBUG}
              AddToUsedUnits(ParseToken);
            end; // if Copy(PasParser.Token, 1, 10) = '{$INCLUDE ' then
            if UpperCase(Copy(PasParser.Token, 1, 4)) = '{$R ' then // Resource files
            begin
              CurrToken := PasParser.Token;
              Delete(CurrToken, 1, 4);
              ParseToken := Copy(CurrToken, 1, Pos('}', CurrToken) - 1);
              if ParseToken[1] <> '*' then
              begin
                {$IFDEF DEBUG}
                TraceAlwaysFmt('UU Parse 4: %s',[ParseToken]);
                {$ENDIF DEBUG}
                AddToUsedUnits(ParseToken);
              end;
            end; // if Copy(PasParser.Token, 1, 4) = '{$R ' then
            if UpperCase(Copy(PasParser.Token, 1, 11)) = '{$RESOURCE ' then
            // Resource files
            begin
              CurrToken := PasParser.Token;
              Delete(CurrToken, 1, 11);
              ParseToken := Copy(CurrToken, 1, Pos('}', CurrToken) - 1);
              if ParseToken[1] <> '*' then
              begin
                {$IFDEF DEBUG}
                TraceAlwaysFmt('UU Parse 4a: %s',[ParseToken]);
                {$ENDIF DEBUG}
                AddToUsedUnits(ParseToken);
              end;
            end; // if Copy(PasParser.Token, 1, 11) = '{$RESOURCE ' then
          end;
          //hu01.12.2002           if PasParser.TokenID = tkUses then
          if PasParser.TokenID = ptUses then
          begin
            PasParser.NextNoJunk;
            //hu01.12.2002             while (PasParser.TokenID <> tkSemiColon) and (PasParser.TokenID <> tkNull) do
            while (PasParser.TokenID <> ptSemiColon) and (PasParser.TokenID <> ptNull) do
            begin
              //hu01.12.2002               if PasParser.TokenID = tkIdentifier then
              if PasParser.TokenID = ptIdentifier then 
              begin // Used Units
                {$IFDEF DEBUG}
                TraceAlwaysFmt('UU Parse 2: %s',[PasParser.Token]);
                {$ENDIF DEBUG}
                UsedUnits.Add(AnsiLowerCase(PasParser.Token));
              end;
              PasParser.NextNoJunk;
              //hu01.12.2002               if PasParser.TokenID = tkIn then
              if PasParser.TokenID = ptIn then
                //hu01.12.2002                 while not (PasParser.TokenID in [tkSemiColon, tkComma, tkNull]) do
                while not (PasParser.TokenID in [ptSemiColon, ptComma, ptNull]) do
                begin
                  // relative Path?
                  if (Length(PasParser.Token) > 1) and (PasParser.Token[2] = '.')
                    and (Pos('\', PasParser.Token) > 0)
                  then
                  begin
                    RelativePath := AnsiLowerCase(ExtractFilePath(sProjectName));
                    NewSearchPath := PasParser.Token;
                    Delete(NewSearchPath, 1, 1);
                    Delete(NewSearchPath, Length(NewSearchPath), 1);
                    try
                      while Pos('..\', NewSearchPath) > 0 do 
                      begin
                        Delete(NewSearchPath, 1, 3);
                        {$IFDEF DEBUG}
                        TraceAlwaysFmt('UU Parse New SPath1: %s',[NewSearchPath]);
                        {$ENDIF DEBUG}
                        repeat
                          Delete(RelativePath, Length(RelativePath), 1);
                        until (RelativePath[Length(RelativePath)] = '\') or
                          (Length(RelativePath) <= 3);
                        {$IFDEF DEBUG}
                        TraceAlwaysFmt('UU Parse New RelPath: %s',[RelativePath]);
                        {$ENDIF DEBUG}
                      end; // while Pos('..\', NewSearchPath) > 0 do begin
                      NewSearchPath := ExtractFilePath(RelativePath + NewSearchPath);
                      {$IFDEF DEBUG}
                      TraceAlwaysFmt('UU Parse New SPath: %s',[NewSearchPath]);
                      {$ENDIF DEBUG}
                      if DirectoryExists(NewSearchPath) then
                      begin
                        SearchPaths.Add(AnsiLowerCase(NewSearchPath));
                        if Pos(AnsiLowerCase(NewSearchPath), AnsiLowerCase(edSearchPath.Text)) = 0 then
                          edSearchPath.Text := edSearchPath.Text +
                            AnsiLowerCase(NewSearchPath) + ';';
                      end;
                    except
                      {$IFDEF DEBUG}
                      TraceAlwaysFmt('Error Parse New SPath: %s',[PasParser.Token]);
                      {$ENDIF DEBUG}
                    end;
                  end;
                  // if (PasParser.Token[2]  = '.') and (Pos('\', PasParser.Token) > 0) then begin
                  PasParser.NextNoJunk;
                end;
              // while not (PasParser.TokenID in [tkSemiColon, tkComma, tkNull]) do begin
            end; // while (PasParser.TokenID <> tkSemiColon)
          end; // if PasParser.TokenID = tkUses then
          PasParser.NextNoJunk;
        end; // while PasParser.TokenID <> tkNull do
      end; // else if bIsCppBuilder then begin
    finally
      PasParser.Free;
    end;
  finally
    MS.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSUsedUnits.btnAddClick(Sender: TObject);
var 
  I: Integer;
begin
  SelectedUnits.Clear;
  with lvUnits do
  begin
    for I := 0 to Items.Count - 1 do
    begin
      if Items[I].StateIndex = 1 then
        SelectedUnits.Add(Items[I].SubItems[1] + Items[I].SubItems[0]);
    end; // for I := 0 to Items.Count - 1 do begin
  end; // with lvUnits do begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSUsedUnits.btnCloseClick(Sender: TObject);
begin
  SelectedUnits.Clear;
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSUsedUnits.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'UsedUnits_Filter',
    cbFilter.Checked);
  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'UsedUnits_Recursive',
    cbRecursive.Checked);

  jvcsWriteWindowPosAndSize(sBaseRegistryKey + crbWindows, 'UsedUnits',
    Top, Left, Width, Height);

  with lvUnits do
  begin
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'UsedUnits_Col1.0',
      Columns[0].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'UsedUnits_Col1.1',
      Columns[1].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'UsedUnits_Col1.2',
      Columns[2].Width);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSUsedUnits.FormDestroy(Sender: TObject);
begin
  SelectedUnits.Free;
  UsedUnits.Free;
  SearchPaths.Free;
  ProjectUnits.Free;
  CoreProjectUnits.Free;
end;

//------------------------------------------------------------------------------

procedure TVCSUsedUnits.lvUnitsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  HitTest: THitTests;
  HitItem: TListItem;
  ItemsSelected: Boolean;
  I: Integer;
begin
  HitTest := lvUnits.GetHitTestInfoAt(X, Y);
  if (Button = mbLeft) and (htOnStateIcon in HitTest) then 
  begin
    HitItem := lvUnits.GetItemAt(X, Y);
    if (HitItem.StateIndex = 0) or (HitItem.StateIndex = 1) then 
    begin
      if HitItem.StateIndex = 0 then 
        HitItem.StateIndex := 1 
      else 
        HitItem.StateIndex := 0;
      ItemsSelected := False;
      for I := 0 to lvUnits.Items.Count - 1 do 
      begin
        if lvUnits.Items[I].StateIndex = 1 then 
        begin
          ItemsSelected := True;
          Break;
        end; // if lvUnits.Items[I].StateIndex = 1 then begin
      end; // for I := 0 to lvUnits.Items.Count - 1 do begin
      btnAdd.Enabled := ItemsSelected;
    end; // if (HitItem.StateIndex = 0) or (HitItem.StateIndex = 1) then begin
  end; // if (Button = mbLeft) and (htOnStateIcon in HitTest) then begin
end;

//------------------------------------------------------------------------------

procedure TVCSUsedUnits.btnDefFilterClick(Sender: TObject);
begin
  VCSUnitFilter := TVCSUnitFilter.Create(Application);
  try
    VCSUnitFilter.Top := Top + 20;
    VCSUnitFilter.Left := Left + 20;
    VCSUnitFilter.SetFilterType(1); // Unitfilter
    VCSUnitFilter.ShowModal;
  finally
    VCSUnitFilter.Free;
  end;
end;

//------------------------------------------------------------------------------

function TVCSUsedUnits.GetListViewString: string;
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
    with lvUnits do 
    begin
      if Items.Count = 0 then 
      begin
        // Nothing to do.
        InfoMessageBox(JVCSRES_Requested_result_set_is_blank46_Nothing_to_do46);
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

procedure TVCSUsedUnits.btnReportClick(Sender: TObject);
var 
  ResultString: string;
begin
  ResultString := GetListViewString;
  if ResultString = '' then 
    Exit;

  VCSSimpleReport := TVCSSimpleReport.Create(Application);
  try
    VCSSimpleReport.RepID := 18;  
    VCSSimpleReport.Left := Left + 60;
    VCSSimpleReport.Top := Top + 60;
    VCSSimpleReport.FullReportString := ResultString;
    VCSSimpleReport.SavePath := ExtractFileDir(sProjectName);
    VCSSimpleReport.SaveFileName := 'UsedModules.txt';
    VCSSimpleReport.LineCount := lvUnits.Items.Count + 8;
    VCSSimpleReport.ShowModal;
  finally
    VCSSimpleReport.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSUsedUnits.RestrictSize(var Msg: TMessage);
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
  P.ptMinTrackSize.x := MulDiv(540, PixelsPerInch, 96);
  P.ptMinTrackSize.y := MulDiv(260, PixelsPerInch, 96);
end;

//------------------------------------------------------------------------------

procedure TVCSUsedUnits.FormKeyDown(Sender: TObject; var Key: Word;
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
  if Key = VK_F2 then 
    btnParse.Click;
end;

//------------------------------------------------------------------------------

procedure TVCSUsedUnits.HelpTopics1Click(Sender: TObject);
begin
  PerformHelpCommand(Application, IDH_Used_Units);
end;

//------------------------------------------------------------------------------

procedure TVCSUsedUnits.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSUsedUnits.btnEditClick(Sender: TObject);
var 
  DlgResult, Marker: Integer;
  EditString: string;
begin
  EditString := edSearchPath.Text;
  VCSListEdit := TVCSListEdit.Create(Application);
  try
    VCSListEdit.Left := Left + 40;
    VCSListEdit.Top := Top + 40;
    VCSListEdit.SetHint(JVCSRES_Search_Paths);
    VCSListEdit.EnablePathButton(True);
    VCSListEdit.ListString := EditString;
    DlgResult := VCSListEdit.ShowModal;
    EditString := VCSListEdit.ListString;
  finally
    VCSListEdit.Free;
  end;
  if DlgResult <> mrOk then 
    Exit;
  edSearchPath.Text := EditString;
  SearchPaths.Clear;
  while Pos(';', EditString) <> 0 do 
  begin
    Marker := Pos(';', EditString);
    SearchPaths.Add(Copy(EditString, 1, Marker - 1));
    Delete(EditString, 1, Marker);
  end; // while Pos(';', EditString) <> 0 do begin
end;


procedure TVCSUsedUnits.lvUnitsSortItems(Sender: TObject; Item1,
  Item2: TListItem; SortColumn: Integer; var SortAs: TSortAs;
  var CompResult: Integer);
begin
  if SortColumn = -1 then
    CompResult := Item1.StateIndex - Item2.StateIndex
  else
  if (SortColumn >= 0) and (SortColumn <= 1) then
    CompResult := AnsiCompareStr(Item1.SubItems[SortColumn], Item2.SubItems[SortColumn]);
  if (CompResult = 0) and (SortColumn <> 0) then
    CompResult := AnsiCompareStr(Item1.SubItems[0], Item2.SubItems[0]);
end;

end.
