(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: VerSet.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS: Thomas Huber (Thomas_D_Huber@t-online.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
   - add JVCSDebug Trace.. calls

-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FreeVCS code to JEDI VCS
2003/02/12  USchuster - changed DSAMsg with JVCSDialogs in uses clause to use JvDSADialogs
2003/03/09  THensle   - changes for "ConfigStorage" unit
2003/03/09  USchuster - exchanged THistoryList with TJVCSMruList (mantis #727)
2003/07/28  THuber    - cosmetic text changes
2004/02/04  USchuster - changed version info resource name from FVCSVer.res to JVCSVer.res
                      - included a warning message if FVCSVer.res is found in the project
                      - now with constant for message box caption
2004/02/24  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/03/14  USchuster - 'verinf.fvc' -> cVersionInfoLocalizationFile
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
2005/02/27  USchuster - D5 fix
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC2 was released ^^^^^^^^^^^^^^^^^^^^^^^^^^^
2005/05/11  USchuster - fixed mantis #2480 with suggestion from Alexander Genedl
2008/02/17  USchuster - BooleanToStr -> BoolToStr
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit VerSet;

{$I jedi.inc}
{$I compopt.inc}

{$IFDEF DELPHI6_UP}
  {$WARN UNIT_PLATFORM OFF}
  {$WARN SYMBOL_PLATFORM OFF}
{$ENDIF DELPHI6_UP}

{$IFNDEF IDEDLL}
  !!! DO NOT INCLUDE IN JVCS STANDALONE APPLICATIONS => ONLY IDEDLL
{$ENDIF ~IDEDLL}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, JvSpin, ComCtrls, Buttons, ExtCtrls, IniFiles, FavOpenDialog,
  Mask, JvExMask, JvMaskEdit;

type
  TResFileRec = record
    MajFVer, MinFVer, FRelease, FBuild,
    MajPVer, MinPVer, PRelease, PBuild: Word;
    CompanyName, FileDescription, FileOS, FileType,
    InternalName, OriginalFilename, LegalCopyright,
    ProductName, LegalTradeMarks, Comments, Author,
    FileFlags, FVCSVer: string;
    DebugBuild, SpecialBuild, InternalBuild,
    IncludeDateStamp, IncStringVerInfo: Boolean;
    Language, CharSet: string;
  end;

type
  TVCSVerSet = class(TForm)
    tabVersionInfo: TPageControl;
    TabSheet1: TTabSheet;
    lblFileVersion: TLabel;
    lblProductVersion: TLabel;
    spiFBuild: TJvSpinEdit;
    spiFRelease: TJvSpinEdit;
    spiPBuild: TJvSpinEdit;
    spiPRelease: TJvSpinEdit;
    TabSheet2: TTabSheet;
    lblCompanyName: TLabel;
    lblCopyright: TLabel;
    lblTradeMark: TLabel;
    lblAuthor: TLabel;
    txtCompanyName: TEdit;
    txtCopyright: TEdit;
    txtTradeMark: TEdit;
    txtAuthor: TEdit;
    TabSheet3: TTabSheet;
    lblComments: TLabel;
    radDebugBuild: TRadioButton;
    radReleaseBuild: TRadioButton;
    chkSpecialBuild: TCheckBox;
    chkInternalBuild: TCheckBox;
    txtComments: TEdit;
    rbHandlebyD: TRadioButton;
    rbHandlebyFVCS: TRadioButton;
    btnOK: TButton;
    btnCancel: TButton;
    btnCreate: TButton;
    cmbOSType: TComboBox;
    cmbLanguage: TComboBox;
    cmbCharSet: TComboBox;
    lblOS: TLabel;
    lblLanguage: TLabel;
    lblCharSet: TLabel;
    cbAssFVersion: TCheckBox;
    cbAssPVersion: TCheckBox;
    spiMinPVer: TJvSpinEdit;
    spiMajPVer: TJvSpinEdit;
    spiMinFVer: TJvSpinEdit;
    spiMajFVer: TJvSpinEdit;
    lblFileType: TLabel;
    cmbFileType: TComboBox;
    lblFileFlags: TLabel;
    txtFileFlags: TEdit;
    txtOriginalName: TEdit;
    lblOriginalName: TLabel;
    lblInternalName: TLabel;
    txtInternalName: TEdit;
    txtDescription: TEdit;
    lblDescription: TLabel;
    lblProductName: TLabel;
    txtProductName: TEdit;
    chkIncludeDateStamp: TCheckBox;
    cbIncBuildNr: TCheckBox;
    cbIncPBuildNr: TCheckBox;
    Label1: TLabel;
    edRCComp: TEdit;
    spBtnBrowse: TSpeedButton;
    cbIncStringVerInfo: TCheckBox;
    Help: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure rbHandlebyDClick(Sender: TObject);
    procedure btnCreateClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure cbAssFVersionClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure spBtnBrowseClick(Sender: TObject);
    procedure HelpClick(Sender: TObject);
  private
    { Private-Deklarationen}
    procedure EnableControls(const Enable: Boolean);
    procedure SaveSettings;
  public
    { Public-Deklarationen}
  end;

function PrepareResFileInfo(const FileName: string): Boolean;

function ResFileInfoIncBuild(const FileName: string): Boolean;

function BuildResFile(const FileName, RCCompiler: string;
  const ResFileRec: TResFileRec): Boolean;

function SaveProjectFileInfo(const ProjectName: string;
  const MajorVer, MinorVer, Release, Build,
  FileFlag: Integer): Boolean;

procedure ShowVersionInfoHint(const ACheckProjectFile: Boolean;
  const AProjectFileName: string);

var
  VCSVerSet: TVCSVerSet;

implementation

uses
    VCSBase
  {$IFDEF LANGUAGE}
  , JvGnugettext
  {$ENDIF LANGUAGE}
  , JVCSDialogs
  , Registry
  , FileCtrl
  , VCSProcBase
  , ConfigStorage
  , mwPasLex
  , mwPasLexTypes
  , JVCSIDEInterface
  , JVCSGUIClientResources
  {$IFDEF DEBUG}
  , JVCSDebug
  {$ENDIF DEBUG}
  , JclStrings
  ;

{$R *.dfm}

function PrepareResFileInfo(const FileName: string): Boolean;
var
  ResFileRec: TResFileRec;
  CurrentRegBaseKey, RCCompiler: string;
  AssFVersion, AssPVersion: Boolean;
begin
  {$IFDEF DEBUG}
  TraceBeginProcFmt('PrepareResFileInfo', 'Filename: %s', [FileName]);
  {$ENDIF DEBUG}
  Result := True;

  RCCompiler :=
    jvcsReadString(sBaseRegistryKey + crbOptions, 'RCCompiler', 'bin\brcc32.exe');

  CurrentRegBaseKey :=
    sBaseRegistryKey + crbProjects + ExtractFileName(FileName);

  with ResFileRec do
  begin
    AssFVersion := jvcsReadBool(CurrentRegBaseKey, 'AssignFVer', False);
    AssPVersion := jvcsReadBool(CurrentRegBaseKey, 'AssignPVer', False);
    if not AssFVersion then
    begin
      MajFVer := jvcsReadInteger(CurrentRegBaseKey, 'FMajorVer', 1);
      MinFVer := jvcsReadInteger(CurrentRegBaseKey, 'FMinorVer', 0);
    end // if AssFVersion then begin
    else
    begin
      MajFVer := jvcsReadInteger(CurrentRegBaseKey, 'MajorVer', 1);
      MinFVer := jvcsReadInteger(CurrentRegBaseKey, 'MinorVer', 0);
    end;

    if not AssPVersion then
    begin
      MajPVer := jvcsReadInteger(CurrentRegBaseKey, 'PMajorVer', 1);
      MinPVer := jvcsReadInteger(CurrentRegBaseKey, 'PMinorVer', 0);
    end // if AssPVersion then begin
    else
    begin
      MajPVer := jvcsReadInteger(CurrentRegBaseKey, 'MajorVer', 1);
      MinPVer := jvcsReadInteger(CurrentRegBaseKey, 'MinorVer', 0);
    end;

    FRelease := StrToInt(jvcsReadString(CurrentRegBaseKey, 'FRelease', '0'));
    FBuild := StrToInt(jvcsReadString(CurrentRegBaseKey, 'FBuild', '0'));
    PRelease := StrToInt(jvcsReadString(CurrentRegBaseKey, 'PRelease', '0'));
    PBuild := StrToInt(jvcsReadString(CurrentRegBaseKey, 'PBuild', '0'));
    CompanyName := jvcsReadString(CurrentRegBaseKey, 'CompanyName', '');
    FileDescription := jvcsReadString(CurrentRegBaseKey, 'FileDescription', '');
    InternalName := jvcsReadString(CurrentRegBaseKey, 'InternalName', '');
    OriginalFilename := jvcsReadString(CurrentRegBaseKey, 'OriginalFilename', '');
    LegalCopyright := jvcsReadString(CurrentRegBaseKey, 'LegalCopyright', '');
    ProductName := jvcsReadString(CurrentRegBaseKey, 'ProductName', '');
    LegalTradeMarks := jvcsReadString(CurrentRegBaseKey, 'LegalTradeMarks', '');
    Comments := jvcsReadString(CurrentRegBaseKey, 'Comments', '');
    Author := jvcsReadString(CurrentRegBaseKey, 'Author', '');
    FileFlags := jvcsReadString(CurrentRegBaseKey, 'FileFlags', '');
    DebugBuild := jvcsReadBool(CurrentRegBaseKey, 'DebugBuild', False);
    SpecialBuild := jvcsReadBool(CurrentRegBaseKey, 'SpecialBuild', False);
    InternalBuild := jvcsReadBool(CurrentRegBaseKey, 'InternalBuild', False);
    IncludeDateStamp := jvcsReadBool(CurrentRegBaseKey, 'IncludeDateStamp', True);
    IncStringVerInfo := jvcsReadBool(CurrentRegBaseKey, 'IncStringVerInfo', True);
    FVCSVer :=
      IntToStr(jvcsReadInteger(CurrentRegBaseKey, 'MajorVer', 1)) + '.' +
      IntToStr(jvcsReadInteger(CurrentRegBaseKey, 'MinorVer', 1));
    FileOS := jvcsReadString(CurrentRegBaseKey, 'FileOS', 'VOS__WINDOWS32');
    FileType := jvcsReadString(CurrentRegBaseKey, 'FileType', 'VFT_APP');
    Language := jvcsReadString(CurrentRegBaseKey, 'Language', '0409: U.S. English');
    CharSet := jvcsReadString(CurrentRegBaseKey, 'CharSet', '1252: Windows, Multilangual');
  end; //   with ResFRec do begin


  if Result then
    Result := BuildResFile(FileName, RCCompiler, ResFileRec);
  {$IFDEF DEBUG}
  TraceEndProcFmt('PrepareResFileInfo', 'Result: %s', [BoolToStr(Result)]);
  {$ENDIF DEBUG}
end;

//------------------------------------------------------------------------------

function ResFileInfoIncBuild(const FileName: string): Boolean;
var
  CurrentRegBaseKey: string;
  IncBuild: Boolean;
  FBuild, PBuild: Integer;
begin
  {$IFDEF DEBUG}
  TraceBeginProcFmt('ResFileInfoIncBuild', 'Filename: %s', [FileName]);
  {$ENDIF DEBUG}
  Result := True;
  IncBuild := False;

  CurrentRegBaseKey :=
    sBaseRegistryKey + crbProjects + ExtractFileName(FileName);

  FBuild := StrToInt(jvcsReadString(CurrentRegBaseKey, 'FBuild', '0'));
  PBuild := StrToInt(jvcsReadString(CurrentRegBaseKey, 'PBuild', '0'));

  if jvcsReadBool(CurrentRegBaseKey, 'IncBuildNr', False) then
  begin
    IncBuild := True;
    Inc(FBuild);
  end;
  if jvcsReadBool(CurrentRegBaseKey, 'IncPBuildNr', False) then
  begin
    IncBuild := True;
    Inc(PBuild);
  end;

  if IncBuild then
  begin
    jvcsWriteString(CurrentRegBaseKey, 'FBuild', IntToStr(FBuild));
    jvcsWriteString(CurrentRegBaseKey, 'PBuild', IntToStr(PBuild));
  end;
  {$IFDEF DEBUG}
  TraceEndProcFmt('ResFileInfoIncBuild', 'Result: %s', [BoolToStr(Result)]);
  {$ENDIF DEBUG}
end;

//------------------------------------------------------------------------------

function BuildResFile(const FileName, RCCompiler: string;
  const ResFileRec: TResFileRec): Boolean;
var
  RCF: TextFile;
  RCFile, RESFile, ShortName, CommandLine, LangID: string;
  IntFile: TIniFile;
  Size, CharSetID: Integer;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;

  function ProperText(S: string): string;  // simply replace \ to /
  begin
    while Pos('\', S) > 0 do
      S[Pos('\', S)] := '/';
    Result := S;
  end;
  
begin
  {$IFDEF DEBUG}
  TraceBeginProcFmt('BuildResFile', 'Filename, RCCompiler: %s', [FileName,RCCompiler]);
  {$ENDIF DEBUG}
  Result := True;
  RCFile := ExtractFileDir(FileName) + '\JVCSVer.rc';
  AssignFile(RCF, RCFile);
  try
    try
      Rewrite(RCF);
    except
      Result := False;
      BeepIfSet;
      Exit;
    end;

    IntFile := TIniFile.Create(sDllDirectory + cVersionInfoLocalizationFile);
    try
      LangID := Copy(ResFileRec.Language, 1, Pred(Pos(':', ResFileRec.Language)));
      if LangID = '' then
        LangID := '0000';
      CharSetID := _StrToInt(Copy(ResFileRec.CharSet, 1, Pred(Pos(':', ResFileRec.CharSet))));

      Writeln(RCF, '1 VERSIONINFO LOADONCALL MOVEABLE DISCARDABLE IMPURE');
      Writeln(RCF, 'FILEVERSION ', IntToStr(ResFileRec.MajFVer), ',',
        IntToStr(ResFileRec.MinFVer), ',',
        IntToStr(ResFileRec.FRelease), ',',
        IntToStr(ResFileRec.FBuild));
      Writeln(RCF, 'PRODUCTVERSION ', IntToStr(ResFileRec.MajPVer), ',',
        IntToStr(ResFileRec.MinPVer), ',',
        IntToStr(ResFileRec.PRelease), ',',
        IntToStr(ResFileRec.PBuild));
      Writeln(RCF, 'FILEOS ', ResFileRec.FileOS);
      Writeln(RCF, 'FILETYPE ', ResFileRec.FileType);
      Writeln(RCF, '{');
      Writeln(RCF, ' BLOCK "StringFileInfo"');
      Writeln(RCF, ' {');
      Writeln(RCF, '  BLOCK "' + LangID + IntToHex(CharSetID, 4) + '"');
      Writeln(RCF, '  {');
      Writeln(RCF, '   VALUE "CompanyName", "', ProperText(ResFileRec.CompanyName), '\000"');
      Writeln(RCF, '   VALUE "FileDescription", "', ProperText(ResFileRec.FileDescription),
        '\000"');
      Writeln(RCF, '   VALUE "FileVersion", "', IntToStr(ResFileRec.MajFVer), '.',
        IntToStr(ResFileRec.MinFVer), '.',
        IntToStr(ResFileRec.FRelease), '.',
        IntToStr(ResFileRec.FBuild), '\000"');
      Writeln(RCF, '   VALUE "ProductVersion", "', IntToStr(ResFileRec.MajPVer), '.',
        IntToStr(ResFileRec.MinPVer), '.',
        IntToStr(ResFileRec.PRelease), '.',
        IntToStr(ResFileRec.PBuild), '\000"');
      if ProperText(ResFileRec.InternalName) <> '' then
        Writeln(RCF, '   VALUE "InternalName", "', ProperText(ResFileRec.InternalName),
          '\000"');
      if ProperText(ResFileRec.OriginalFilename) <> '' then
        Writeln(RCF, '   VALUE "OriginalFilename", "', ProperText(ResFileRec.OriginalFilename),
          '\000"');
      if ProperText(ResFileRec.LegalCopyright) <> '' then
        Writeln(RCF, '   VALUE "LegalCopyright", "Copyright © ',
          ProperText(ResFileRec.LegalCopyright), '\000"');
      if ProperText(ResFileRec.ProductName) <> '' then
        Writeln(RCF, '   VALUE "ProductName", "', ProperText(ResFileRec.ProductName), '\000"');
      if ProperText(ResFileRec.LegalTradeMarks) <> '' then
        Writeln(RCF, '   VALUE "' + IntFile.ReadString(LangID, 'LegalTradeMarks',
          'LegalTradeMarks') + '", "',
          ProperText(ResFileRec.LegalTradeMarks), '\000"');
      if ProperText(ResFileRec.Comments) <> '' then
        Writeln(RCF, '   VALUE "Comments", "', ProperText(ResFileRec.Comments), '\000"');
      if ProperText(ResFileRec.FileFlags) <> '' then
        Writeln(RCF, '   VALUE "FileFlags", "', ProperText(ResFileRec.FileFlags), '\000"');
      if ProperText(ResFileRec.Author) <> '' then
        Writeln(RCF, '   VALUE "' + IntFile.ReadString(LangID, 'Author', 'Author') + '", "',
          ProperText(ResFileRec.Author), '\000"');
      Write(RCF, '   VALUE "' + IntFile.ReadString(LangID, 'BuildType', 'BuildType') + '", "');
      if ResFileRec.DebugBuild then
        Write(RCF, IntFile.ReadString(LangID, 'DebugBuild', 'DebugBuild'))
      else
        Write(RCF, IntFile.ReadString(LangID, 'ReleaseBuild', 'ReleaseBuild'));
      if ResFileRec.SpecialBuild then
        Write(RCF, ', ' + IntFile.ReadString(LangID, 'SpecialBuild', 'SpecialBuild'));
      if ResFileRec.InternalBuild then
        Writeln(RCF, ', ' + IntFile.ReadString(LangID, 'InternalBuild (NOT FOR RELEASE!)',
          'InternalBuild (NOT FOR RELEASE!)') + '\000"')
      else
        Writeln(RCF, '\000"');
      if ResFileRec.IncludeDateStamp then
        Writeln(RCF, '   VALUE "' + IntFile.ReadString(LangID, 'BuildTimestamp',
          'BuildTimestamp') +
          '", "', DateTimeToStr(Now), '\000"');
      if ResFileRec.IncStringVerInfo then
        Writeln(RCF, '   VALUE "' + IntFile.ReadString(LangID, 'InternalVersion',
          'InternalVersion') +
          '", "', ResFileRec.FVCSVer, '\000"');

      Writeln(RCF, '   VALUE "VCS", "JEDI VCS ', sProductVer, ' http://sourceforge.net/projects/jedivcs\000"');
      Writeln(RCF, '  }');
      Writeln(RCF, ' }');
      Writeln(RCF, ' BLOCK "VarFileInfo"');
      Writeln(RCF, ' {');
      Writeln(RCF, '  VALUE "Translation", 0x', Copy(ResFileRec.Language, 1,
        Pred(Pos(':', ResFileRec.Language))), ',',
        Copy(ResFileRec.CharSet, 1, Pred(Pos(':', ResFileRec.CharSet))));
      Writeln(RCF, ' }');
      Writeln(RCF, '}');
    finally
      IntFile.Free;
    end;

    // keine langen Dateinamen als Parameter
    SetLength(ShortName, MAX_PATH);
    Size := GetShortPathName(PChar(RCFile), PChar(ShortName), MAX_PATH);
    SetLength(ShortName, Size);
    CommandLine := '-fo ' + ShortName;
    RESFile := ChangeFileExt(RCFile, '.res');
    SetLength(ShortName, MAX_PATH);
    Size := GetShortPathName(PChar(RESFile), PChar(ShortName), MAX_PATH);
    SetLength(ShortName, Size);
    CommandLine := CommandLine + ' -w32 ' + ShortName;
    {$IFDEF DEBUG}
    TraceAlwaysFmt('BRCC32 path: %s, BRCC32 Command: %s', [RCCompiler,CommandLine]);
    {$ENDIF DEBUG}
    Flush(RCF);
  finally
    CloseFile(RCF);
  end;
  FillChar(StartupInfo, SizeOf(TStartupInfo), 0);
  StartupInfo.cb := SizeOf(TStartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := SW_HIDE;
  if not CreateProcess(PChar(RCCompiler), PChar(CommandLine), nil, nil, False,
    CREATE_DEFAULT_ERROR_MODE, nil,
    PChar(ExtractFileDir(FileName)), StartupInfo,
    ProcessInfo) then
  begin
    Result := False;
    {$IFDEF DEBUG}
    TraceAlwaysFmt('CreateProcess: BRCC32 failed: %s', [CommandLine]);
    {$ENDIF DEBUG}
  end;
  {$IFDEF DEBUG}
  TraceEndProcFmt('ResFileInfoIncBuild', 'Result: %s', [BoolToStr(Result)]);
  {$ENDIF DEBUG}
end;

//------------------------------------------------------------------------------

function SaveProjectFileInfo(const ProjectName: string;
  const MajorVer, MinorVer, Release, Build,
  FileFlag: Integer): Boolean;
var
  CurrentRegBaseKey: string;
begin
  Result := True;

  CurrentRegBaseKey :=
    sBaseRegistryKey + crbProjects + ExtractFileName(ProjectName);

  if MajorVer <> -1 then
    jvcsWriteInteger(CurrentRegBaseKey, 'MajorVer', MajorVer);
  if MinorVer <> -1 then
    jvcsWriteInteger(CurrentRegBaseKey, 'MinorVer', MinorVer);
  if Release <> -1 then
    jvcsWriteInteger(CurrentRegBaseKey, 'FRelease', Release);
  if Build <> -1 then
    jvcsWriteInteger(CurrentRegBaseKey, 'FBuild', Build);
  if FileFlag <> -1 then
    jvcsWriteInteger(CurrentRegBaseKey, 'FileFlag', FileFlag);
end;

//------------------------------------------------------------------------------

procedure TVCSVerSet.FormCreate(Sender: TObject);
var
  Reg: TRegistry;
  RegOrganisation, RegOwner, CurrValue, CurrentRegBaseKey: string;
begin
  try
    tabVersionInfo.ActivePage := TabSheet1;
    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    if sBaseRegistryKey <> '' then
    begin
      Reg := TRegistry.Create;
      with Reg do
      begin
        try
          RootKey := HKEY_LOCAL_MACHINE;
          OpenKeyReadOnly('\Software\Microsoft\Windows\CurrentVersion');
          try
            RegOrganisation := ReadString('RegisteredOrganization');
            RegOwner := ReadString('RegisteredOwner');
          except
            {$IFDEF DEBUG}
            TraceAlways('RegError: VerSet RegOwner');
            {$ENDIF DEBUG}
          end;
          CloseKey;
          {$IFDEF DEBUG}
          TraceAlwaysFmt('RegOrganisation: %s, RegOwner: %s', [RegOrganisation, RegOwner]);
          {$ENDIF DEBUG}
          CloseKey;
        finally
          Free;
        end; // try finally
      end; // with Reg do begin
    end; // if BaseRegistryKey <> '' then begin

    edRCComp.Text :=
      jvcsReadString(sBaseRegistryKey + crbOptions, 'RCCompiler', 'bin\brcc32.exe');

    CurrentRegBaseKey :=
      sBaseRegistryKey + crbProjects + ExtractFileName(sProjectName);

    cbAssFVersion.Checked :=
      jvcsReadBool(CurrentRegBaseKey, 'AssignFVer', False);
    cbAssPVersion.Checked :=
    jvcsReadBool(CurrentRegBaseKey, 'AssignPVer', False);

    if not cbAssFVersion.Checked then
    begin
      spiMajFVer.Text :=
        IntToStr(jvcsReadInteger(CurrentRegBaseKey, 'FMajorVer', 1));

      spiMinFVer.Text :=
        IntToStr(jvcsReadInteger(CurrentRegBaseKey, 'FMinorVer', 0));
    end // if cbAssFVersion.Checked then begin
    else
    begin
      spiMajFVer.Text :=
        IntToStr(jvcsReadInteger(CurrentRegBaseKey, 'MajorVer', 1));
      spiMinFVer.Text :=
        IntToStr(jvcsReadInteger(CurrentRegBaseKey, 'MinorVer', 0));
    end;

    if not cbAssPVersion.Checked then
    begin
      spiMajPVer.Text :=
        IntToStr(jvcsReadInteger(CurrentRegBaseKey, 'PMajorVer', 1));
      spiMinPVer.Text :=
        IntToStr(jvcsReadInteger(CurrentRegBaseKey, 'PMinorVer', 0));
    end // if cbAssPVersion.Checked then begin
    else
    begin
      spiMajPVer.Text :=
        IntToStr(jvcsReadInteger(CurrentRegBaseKey, 'MajorVer', 1));
      spiMinPVer.Text :=
        IntToStr(jvcsReadInteger(CurrentRegBaseKey, 'MinorVer', 0));
    end;

    spiFRelease.Text := jvcsReadString(CurrentRegBaseKey, 'FRelease', '0');
    spiFBuild.Text := jvcsReadString(CurrentRegBaseKey, 'FBuild', '0');
    spiPRelease.Text := jvcsReadString(CurrentRegBaseKey, 'PRelease', '0');
    spiPBuild.Text := jvcsReadString(CurrentRegBaseKey, 'PBuild', '0');
    txtCompanyName.Text := jvcsReadString(CurrentRegBaseKey, 'CompanyName', RegOrganisation);
    txtDescription.Text := jvcsReadString(CurrentRegBaseKey, 'FileDescription', '');
    txtInternalName.Text := jvcsReadString(CurrentRegBaseKey, 'InternalName', '');
    txtOriginalName.Text := jvcsReadString(CurrentRegBaseKey, 'OriginalFilename', ExtractFileName(ChangeFileExt(sProjectName, '')));
    txtCopyright.Text := jvcsReadString(CurrentRegBaseKey, 'LegalCopyright', RegOwner);
    txtProductName.Text := jvcsReadString(CurrentRegBaseKey, 'ProductName', '');
    txtTradeMark.Text := jvcsReadString(CurrentRegBaseKey, 'All rights reserved', '');
    txtComments.Text := jvcsReadString(CurrentRegBaseKey, 'Comments', '');
    txtAuthor.Text := jvcsReadString(CurrentRegBaseKey, 'Author', '');
    txtFileFlags.Text := jvcsReadString(CurrentRegBaseKey, 'FileFlags', '');
    radDebugBuild.Checked := jvcsReadBool(CurrentRegBaseKey, 'DebugBuild', False);
    radReleaseBuild.Checked := not radDebugBuild.Checked;
    chkSpecialBuild.Checked := jvcsReadBool(CurrentRegBaseKey, 'SpecialBuild', False);
    chkInternalBuild.Checked := jvcsReadBool(CurrentRegBaseKey, 'InternalBuild', False);
    chkIncludeDateStamp.Checked := jvcsReadBool(CurrentRegBaseKey, 'IncludeDateStamp', True);
    cbIncStringVerInfo.Checked := jvcsReadBool(CurrentRegBaseKey, 'IncStringVerInfo', True);

    CurrValue := jvcsReadString(CurrentRegBaseKey, 'FileOS', 'VOS__WINDOWS32');
    cmbOSType.ItemIndex := cmbOSType.Items.IndexOf(CurrValue);

    CurrValue := jvcsReadString(CurrentRegBaseKey, 'FileType', 'VFT_APP');
    cmbFileType.ItemIndex := cmbFileType.Items.IndexOf(CurrValue);

    CurrValue := jvcsReadString(CurrentRegBaseKey, 'Language', '0409: U.S. English');
    cmbLanguage.ItemIndex := cmbLanguage.Items.IndexOf(CurrValue);

    CurrValue := jvcsReadString(CurrentRegBaseKey, 'CharSet', '1252: Windows, Multilangual');
    cmbCharSet.ItemIndex := cmbCharSet.Items.IndexOf(CurrValue);

    cbIncBuildNr.Checked := jvcsReadBool(CurrentRegBaseKey, 'IncBuildNr', False);
    cbIncPBuildNr.Checked := jvcsReadBool(CurrentRegBaseKey, 'IncPBuildNr', False);

    rbHandlebyFVCS.Checked := jvcsReadBool(CurrentRegBaseKey, 'VerInfoHandle', False);
    rbHandlebyD.Checked := not rbHandlebyFVCS.Checked;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSVerSet.FormActivate(Sender: TObject);
begin
  //////////////////////
end;

//------------------------------------------------------------------------------

procedure TVCSVerSet.EnableControls(const Enable: Boolean);
var
  I: Integer;
begin
  for I := 0 to ComponentCount - 1 do 
  begin
    if (Components[I] is TEdit) and
      ((Components[I] as TEdit).Name <> 'edRCComp') then 
    begin
      (Components[I] as TEdit).Enabled := Enable;
      if Enable then
        (Components[I] as TEdit).Color := clWindow
      else 
        (Components[I] as TEdit).Color := clBtnFace;
    end;
    if (Components[I] is TJvSpinEdit) and
      ((Components[I] as TJvSpinEdit).Name <> 'spiMajFVer') and
      ((Components[I] as TJvSpinEdit).Name <> 'spiMinFVer') and
      ((Components[I] as TJvSpinEdit).Name <> 'spiMajPVer') and
      ((Components[I] as TJvSpinEdit).Name <> 'spiMinPVer') then 
    begin
      (Components[I] as TJvSpinEdit).Enabled := Enable;
      if Enable then 
        (Components[I] as TJvSpinEdit).Color := clWindow
      else
        (Components[I] as TJvSpinEdit).Color := clBtnFace;
    end;
    if Components[I] is TComboBox then 
    begin
      (Components[I] as TComboBox).Enabled := Enable;
      if Enable then
        (Components[I] as TComboBox).Color := clWindow
      else
        (Components[I] as TComboBox).Color := clBtnFace;
    end;
    if (Components[I] is TRadioButton) and
      ((Components[I] as TRadioButton).Name <> 'rbHandlebyD') and
      ((Components[I] as TRadioButton).Name <> 'rbHandlebyFVCS') then
      (Components[I] as TRadioButton).Enabled := Enable;
    if (Components[I] is TCheckBox) then
      (Components[I] as TCheckBox).Enabled := Enable;
    if not Enable then
    begin
      spiMajFVer.Enabled := False;
      spiMinFVer.Enabled := False;
      spiMajPVer.Enabled := False;
      spiMinPVer.Enabled := False;
    end 
    else
    begin
      spiMajFVer.Enabled := not cbAssFVersion.Checked;
      spiMinFVer.Enabled := not cbAssFVersion.Checked;
      spiMajPVer.Enabled := not cbAssPVersion.Checked;
      spiMinPVer.Enabled := not cbAssPVersion.Checked;
    end;
    if spiMajFVer.Enabled then
      spiMajFVer.Color := clWindow
    else 
      spiMajFVer.Color := clBtnFace;
    if spiMinFVer.Enabled then
      spiMinFVer.Color := clWindow
    else 
      spiMinFVer.Color := clBtnFace;
    if spiMajPVer.Enabled then
      spiMajPVer.Color := clWindow
    else
      spiMajPVer.Color := clBtnFace;
    if spiMinPVer.Enabled then 
      spiMinPVer.Color := clWindow
    else 
      spiMinPVer.Color := clBtnFace;
    btnCreate.Enabled := Enable;
  end; // for I := 0 to ComponentCount - 1 do begin
end;

//------------------------------------------------------------------------------

procedure TVCSVerSet.SaveSettings;
var
  CurrentRegBaseKey: string;
begin
  jvcsWriteString(sBaseRegistryKey + crbOptions, 'RCCompiler', edRCComp.Text);

  CurrentRegBaseKey :=
    sBaseRegistryKey + crbProjects + ExtractFileName(sProjectName);

  jvcsWriteBool(CurrentRegBaseKey, 'VerInfoHandle', rbHandlebyFVCS.Checked);
  jvcsWriteBool(CurrentRegBaseKey, 'IncBuildNr', cbIncBuildNr.Checked);
  jvcsWriteBool(CurrentRegBaseKey, 'IncPBuildNr', cbIncPBuildNr.Checked);
  jvcsWriteBool(CurrentRegBaseKey, 'AssignFVer', cbAssFVersion.Checked);
  jvcsWriteBool(CurrentRegBaseKey, 'AssignPVer', cbAssPVersion.Checked);

  jvcsWriteInteger(CurrentRegBaseKey, 'FMajorVer', StrToInt(spiMajFVer.Text));
  jvcsWriteInteger(CurrentRegBaseKey, 'FMinorVer', StrToInt(spiMinFVer.Text));
  jvcsWriteInteger(CurrentRegBaseKey, 'PMajorVer', StrToInt(spiMajPVer.Text));
  jvcsWriteInteger(CurrentRegBaseKey, 'PMinorVer', StrToInt(spiMinPVer.Text));

  jvcsWriteString(CurrentRegBaseKey, 'FRelease', spiFRelease.Text);
  jvcsWriteString(CurrentRegBaseKey, 'FBuild', spiFBuild.Text);
  jvcsWriteString(CurrentRegBaseKey, 'PRelease', spiPRelease.Text);
  jvcsWriteString(CurrentRegBaseKey, 'PBuild', spiPBuild.Text);
  jvcsWriteString(CurrentRegBaseKey, 'CompanyName', txtCompanyName.Text);
  jvcsWriteString(CurrentRegBaseKey, 'FileDescription', txtDescription.Text);
  jvcsWriteString(CurrentRegBaseKey, 'InternalName', txtInternalName.Text);
  jvcsWriteString(CurrentRegBaseKey, 'OriginalFilename', txtOriginalName.Text);
  jvcsWriteString(CurrentRegBaseKey, 'LegalCopyright', txtCopyright.Text);
  jvcsWriteString(CurrentRegBaseKey, 'ProductName', txtProductName.Text);
  jvcsWriteString(CurrentRegBaseKey, 'LegalTradeMarks', txtTradeMark.Text);
  jvcsWriteString(CurrentRegBaseKey, 'Comments', txtComments.Text);
  jvcsWriteString(CurrentRegBaseKey, 'Author', txtAuthor.Text);
  jvcsWriteString(CurrentRegBaseKey, 'FileFlags', txtFileFlags.Text);
  jvcsWriteBool(CurrentRegBaseKey, 'DebugBuild', radDebugBuild.Checked);
  jvcsWriteBool(CurrentRegBaseKey, 'SpecialBuild', chkSpecialBuild.Checked);
  jvcsWriteBool(CurrentRegBaseKey, 'InternalBuild', chkInternalBuild.Checked);
  jvcsWriteBool(CurrentRegBaseKey, 'IncludeDateStamp', chkIncludeDateStamp.Checked);
  jvcsWriteBool(CurrentRegBaseKey, 'IncStringVerInfo', cbIncStringVerInfo.Checked);
  jvcsWriteString(CurrentRegBaseKey, 'FileOS', cmbOSType.Text);
  jvcsWriteString(CurrentRegBaseKey, 'FileType', cmbFileType.Text);
  jvcsWriteString(CurrentRegBaseKey, 'Language', cmbLanguage.Text);
  jvcsWriteString(CurrentRegBaseKey, 'CharSet', cmbCharSet.Text);
end;

//------------------------------------------------------------------------------

procedure TVCSVerSet.FormClose(Sender: TObject; var Action: TCloseAction);
begin

end;

//------------------------------------------------------------------------------

procedure TVCSVerSet.rbHandlebyDClick(Sender: TObject);
begin
  EnableControls(not rbHandlebyD.Checked);
  if rbHandlebyFVCS.Checked then
    ShowVersionInfoHint(True, sProjectName);
end;

//------------------------------------------------------------------------------

procedure TVCSVerSet.btnCreateClick(Sender: TObject);
var
  ResFRec: TResFileRec;
begin
  with ResFRec do
  begin
    MajFVer := StrToInt(spiMajFVer.Text);
    MinFVer := StrToInt(spiMinFVer.Text);
    FRelease := StrToInt(spiFRelease.Text);
    FBuild := StrToInt(spiFBuild.Text);
    MajPVer := StrToInt(spiMajPVer.Text);
    MinPVer := StrToInt(spiMinPVer.Text);
    PRelease := StrToInt(spiPRelease.Text);
    PBuild := StrToInt(spiPBuild.Text);
    CompanyName := txtCompanyName.Text;
    FileDescription := txtDescription.Text;
    InternalName := txtInternalName.Text;
    OriginalFilename := txtOriginalName.Text;
    LegalCopyright := txtCopyright.Text;
    ProductName := txtProductName.Text;
    LegalTradeMarks := txtTradeMark.Text;
    Comments := txtComments.Text;
    Author := txtAuthor.Text;
    FileFlags := txtFileFlags.Text;
    DebugBuild := radDebugBuild.Checked;
    SpecialBuild := chkSpecialBuild.Checked;
    InternalBuild := chkInternalBuild.Checked;
    IncludeDateStamp := chkIncludeDateStamp.Checked;
    Language := cmbLanguage.Items[cmbLanguage.ItemIndex];
    CharSet := cmbCharSet.Items[cmbCharSet.ItemIndex];
    FileType := cmbOSType.Items[cmbOSType.ItemIndex];
    FileOS := cmbFileType.Items[cmbFileType.ItemIndex];
  end; // with ResFRec do begin
  BuildResFile(sProjectName, edRCComp.Text, ResFRec);
end;

//------------------------------------------------------------------------------

procedure TVCSVerSet.btnOKClick(Sender: TObject);
begin
  if rbHandlebyFVCS.Checked then
  begin
    if not DirectoryExists(IDEInterface.JVCSIDESettings.IDEAppFileDir) then
    begin
      WarnMessageBox( JVCSRES_JEDI_VCS_cannot_detect_the_name_of_Delphi39s_base_installation_folder46 + AnsiCrLf +
                      JVCSRES_This_function_is_only_supported_for_known_IDE_products46
                    );
    end;
    if not FileExists(edRCComp.Text) then
    begin
      tabVersionInfo.ActivePage := TabSheet3;
      edRCComp.SetFocus;
      edRCComp.SelectAll;
      BeepIfSet;
      WarnMessageBox( Format(JVCSRES_JEDI_VCS_cannot_find_the_file58 + AnsiCrLf + '<%s>.', [edRCComp.Text]));
      Exit;
    end;
  end; // if rbHandlebyFVCS.Checked then begin
  SaveSettings;
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSVerSet.btnCancelClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSVerSet.cbAssFVersionClick(Sender: TObject);
var
  CurrentRegBaseKey: string;
begin
  spiMajFVer.Enabled := not cbAssFVersion.Checked;
  spiMinFVer.Enabled := not cbAssFVersion.Checked;
  spiMajPVer.Enabled := not cbAssPVersion.Checked;
  spiMinPVer.Enabled := not cbAssPVersion.Checked;
  if spiMajFVer.Enabled then
    spiMajFVer.Color := clWindow
  else
    spiMajFVer.Color := clBtnFace;
  if spiMinFVer.Enabled then
    spiMinFVer.Color := clWindow
  else
    spiMinFVer.Color := clBtnFace;
  if spiMajPVer.Enabled then
    spiMajPVer.Color := clWindow
  else
    spiMajPVer.Color := clBtnFace;
  if spiMinPVer.Enabled then
    spiMinPVer.Color := clWindow
  else
    spiMinPVer.Color := clBtnFace;

  CurrentRegBaseKey :=
    sBaseRegistryKey + crbProjects + ExtractFileName(sProjectName);

  if not cbAssFVersion.Checked then
  begin
    spiMajFVer.Text :=
      IntToStr(jvcsReadInteger(CurrentRegBaseKey, 'FMajorVer', 1));
    spiMinFVer.Text :=
      IntToStr(jvcsReadInteger(CurrentRegBaseKey, 'FMinorVer', 0));
  end // if cbAssFVersion.Checked then begin
  else
  begin
    spiMajFVer.Text :=
      IntToStr(jvcsReadInteger(CurrentRegBaseKey, 'MajorVer', 1));
    spiMinFVer.Text :=
      IntToStr(jvcsReadInteger(CurrentRegBaseKey, 'MinorVer', 0));
  end;

  if not cbAssPVersion.Checked then
  begin
    spiMajPVer.Text :=
      IntToStr(jvcsReadInteger(CurrentRegBaseKey, 'PMajorVer', 1));
    spiMinPVer.Text :=
      IntToStr(jvcsReadInteger(CurrentRegBaseKey, 'PMinorVer', 0));
  end // if cbAssPVersion.Checked then begin
  else
  begin
    spiMajPVer.Text :=
      IntToStr(jvcsReadInteger(CurrentRegBaseKey, 'MajorVer', 1));
    spiMinPVer.Text :=
      IntToStr(jvcsReadInteger(CurrentRegBaseKey, 'MinorVer', 0));
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSVerSet.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    btnCancel.Click;
    Key := 0;
  end;
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Version_resource);
end;

//------------------------------------------------------------------------------

procedure TVCSVerSet.spBtnBrowseClick(Sender: TObject);
var
  DlgResult: Boolean;
  FavOpenDialog: TFavOpenDialog;
begin
  FavOpenDialog := TFavOpenDialog.Create(Application);
  try
    with FavOpenDialog do
    begin
      Title := Format(JVCSRES_37s_resource_compiler, [sIDEName]);
      Options := [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing];
      InitialDir := ExtractFileDir(edRCComp.Text);
      FileName := edRCComp.Text;
      Filter := JVCSRES_Programs_404246exe594246com594246bat411244246exe594246com594246bat124All_files_4042464241124424642;

      DlgResult := ExecuteFavOpenDialogWithMru(FavOpenDialog,
        sBaseRegistryKey + crbMRU + '18');
    end; // with FavOpenDialog1 do begin
    if DlgResult then
      edRCComp.Text := AnsiLowerCase(FavOpenDialog.FileName);
  finally
    FavOpenDialog.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSVerSet.HelpClick(Sender: TObject);
var
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

function CheckForVersionResourceInProject(const AProjectFileName: string;
  var AfoundFreeVCSVersionResource: Boolean): Boolean;
var
  MS: TMemoryStream;
  PasParser: TmwPasLex;
  CurrToken, ParseToken: string;
  ProjectResourceFiles: TStringList;
begin
  ProjectResourceFiles := TStringList.Create;
  try
    MS := TMemoryStream.Create;
    try
      IDESource2Stream(AProjectFileName, MS);
      PasParser := TmwPasLex.Create;
      try
        PasParser.Origin := MS.Memory;
        while PasParser.TokenID <> ptNull do
        begin
          if PasParser.TokenID = ptResourceDirect then
          begin
            if (UpperCase(Copy(PasParser.Token, 1, 4)) = '{$R ') then
            begin
              CurrToken := PasParser.Token;
              Delete(CurrToken, 1, 4);
              ParseToken := Copy(CurrToken, 1, Pos('}', CurrToken) - 1);
              if (ParseToken <> '') and (ParseToken[1] <> '*') then
                ProjectResourceFiles.Add(ParseToken);
            end; // if Copy(PasParser.Token, 1, 4) = '{$R ' then
            if UpperCase(Copy(PasParser.Token, 1, 11)) = '{$RESOURCE ' then
            // Resource files
            begin
              CurrToken := PasParser.Token;
              Delete(CurrToken, 1, 11);
              ParseToken := Copy(CurrToken, 1, Pos('}', CurrToken) - 1);
              if (ParseToken <> '') and (ParseToken[1] <> '*') then
                ProjectResourceFiles.Add(ParseToken);
            end; // if Copy(PasParser.Token, 1, 11) = '{$RESOURCE ' then
          end;
          PasParser.NextNoJunk;
        end; // while PasParser.TokenID <> ptNull do
      finally
        PasParser.Free;
      end;
    finally
      MS.Free;
    end;
    AfoundFreeVCSVersionResource := ProjectResourceFiles.IndexOf('FVCSVer.res') <> -1;
    Result := ProjectResourceFiles.IndexOf('JVCSVer.res') <> -1;
  finally
    ProjectResourceFiles.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure ShowVersionInfoHint(const ACheckProjectFile: Boolean;
  const AProjectFileName: string);
var
  FoundFreeVCSVersionInfoResourceInProject: Boolean;
  Mess: string;
begin
  FoundFreeVCSVersionInfoResourceInProject := False;
  if (not ACheckProjectFile) or (not CheckForVersionResourceInProject(AProjectFileName,
    FoundFreeVCSVersionInfoResourceInProject)) then
  begin
    if not FoundFreeVCSVersionInfoResourceInProject then
    begin
      UseRegistry := True;
      DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
      DSAIdentsMessageDlg(Format(JVCSRES_146_Disable_39Include_version_information46464639_in_Project124Options46 + #13#10
        + JVCSRES_246_Delete_all_version_informations_in_37s_to_prevent_39Duplicate_Resource39_errors46 + #13#10
        + JVCSRES_346_Include_12336R_JVCSVER46RES125_in_37s46,
        [ExtractFileName(ChangeFileExt(AProjectFileName, '.res')),
        ExtractFileName(AProjectFileName)]),
        mtInformation, [mbOK], 0,
        sBaseRegistryKey + crbMRU + 'Dlgs',
        'DelVerInfo', idOk);
    end
    else
    begin
      Mess := Format(JVCSRES_The_version_info_resource_JVCSVer46res_was_not_found_in_the_current_project_37s46,
        [ExtractFileName(AProjectFileName)]) + #13
        + JVCSRES_An_old_version_40FVCSVer46res41_of_the_version_info_resource_was_found_in_the_current_project46 + #13
        + Format(JVCSRES_Remove_FVCSVer46res_from_37s_and_follow_this_steps58,
        [ExtractFileName(AProjectFileName)]) + #13#13;
      Mess := Mess + Format(JVCSRES_146_Disable_39Include_version_information46464639_in_Project124Options46 + #13#10
        + JVCSRES_246_Delete_all_version_informations_in_37s_to_prevent_39Duplicate_Resource39_errors46 + #13#10
        + JVCSRES_346_Include_12336R_JVCSVER46RES125_in_37s46, [ExtractFileName(ChangeFileExt(AProjectFileName, '.res')),
        ExtractFileName(sProjectName)]);
      WarnMessageBox(Mess);
    end;
  end;
end;

end.
