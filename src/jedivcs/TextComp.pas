(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: Textcomp.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS: Thomas Huber (Thomas_D_Huber@gmx.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
ToDo
- move GetArchiveCRC and GetLatestModuleRevisionID to another unit
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FreeVCS code to JEDI VCS
2003/02/18  MGosselink- emptied some .text props
2003/02/18  THuber    - changed JvHTComboBox => JvComboBox
2003/03/03  THensle   - changes for "ConfigStorage" unit
2003/03/10  USchuster - changes in connection with mantis #772
                        - set the anchors of the archive comboboxes
                        - set all comboboxes.style to csDropDownList
                          (editing caused a servererror and the ModuleIDs are
                           taken from the combobox.Items.Values and when you enter
                           a string which doesn't exist in combobox.Items then
                           the ModuleID is empty and thatswhy the servererror)
                        - simplified the btnCompare.enabled stuff and disabled
                          btnCompare in the beginning of FindVersions and set
                          the state again at the end
                        - the DFM will only be converted when it's a binary DFM
                          (fixed error in Archive vs. Archive Mode when TextDFM
                           where stored in the archive)
                        - in Local vs. Archive was the filename in IsBinaryFile
                          allways empty the first time -> thatswhy the DFM was
                          converted although it was a TextDFM and this caused
                          an error with the old DFM conversion method
                          (w/o IsBinaryDFMStream)
2003/03/15  THuber    - compilerwarnings removed
2003/04/08  USchuster - changes for IDEInterface
2003/04/11  FBouwmans - direct member choice (for local project admin)
2003/05/01  USchuster - fixed direct member choice (mantis #880/3.)
2003/05/11  USchuster - bugfix: a binary dfm from the archive wasn't converted
                                to text in local vs. archive mode if the local
                                file was a text dfm
                        (solved this mainly by simplifying the preparation
                         of the two files)
2003/11/08  USchuster - added unified procedure DoCompareModule for TextComp
                        (base work for mantis #1204)
                      - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use new constant)
2003/11/09  USchuster - fixed GetArchiveCRC (revision extension was not found
                        when the case was different) and GetLatestModuleRevisionID
                        (delivered always the first and not the latest revision)
                      - disabled the binaryfile check before retrieving the ModuleID
                        (ModuleID will now be always retrieved because they is necessary)
2003/11/28  USchuster - included *.dfm in Compare files (fixed bug: calling DoModuleCompare
                        with a binary .dfm as ModuleMember executed a binary compare only)
2004/02/24  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/04/12  USchuster - AutoComplete in ComboBox now False
                      - minor style cleaning (casing and comments)
                      - typo
2004/09/17  FHasovic  - Added dxGetText support for localization                      
2004/10/09  USchuster - style cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/10/31  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
2004/11/21  USchuster - changed to keep selected revision while switching between
                        "Local vs. Archive" and "Archive vs. Archive" mode (mantis #2186)
                      - added option to include version and revision in filename (mantis #2186)
                      - added buttons for fast synced increase or decrease of the version.revision
                        of both comboboxes in "Archive vs. Archive" mode (mantis #2186)
                      - changed RevisionIDs to TObjectList and use objects instead of
                        TStrings.Names and .Values
2005/01/07  USchuster - some more changes for mantis #2186
                        (storage of difftool per extension, save state of
                         checkbox "incl. Ver&&Rev in file names" and changed
                         keeping of selected revision to use upper "Archive" combobox)
2005/03/17  USchuster - changes to open the "Get Module" dialog with the selected
                        revision (mantis #2769)
2005/04/02  USchuster - added SelectedModuleID property to TVCSTextCompare and
                        ModuleID parameter to several DoCompareModule methods
                        to be able compare a module which is in another path (mantis #2820)
2005/04/25  CSchuette - added calls to "ResolveFileFamilies" to fix mantis #1205
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 final released ^^^^^^^^^^^^^^^^^^^^^^^^^^
2006/03/15  THuber    #3555 changed function call params for HandleBlob.ExtractZip2Source
2006/04/29  THuber    #3668 shell folder local appdata now used for compared files
2006/12/10  USchuster - added JVCSClientFunctions to uses (as of now it is required for MatchWithFilter)
2007/06/07  USchuster - form size changes for large fonts and large title bars
2007/08/13  USchuster - Trace -> TraceMsg
2007/11/23  USchuster - added member count as label
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2009/12/28  THuber    - added JVCSClientConsts to uses (as some consts were moved from VCSBase there)
2010/10/31  USchuster - added CompareMode to open the dialog in "Archive vs. Archive" mode
                        (required for revision hyperlink feature in Line History)
2011/01/15  USchuster - changed font to Tahoma
2015/04/04  USchuster - added TCompareModule* for "Diff All Local vs. Archive"
2015/04/11  USchuster - added ProjectID to TCompareModule to support modules of different projects

-----------------------------------------------------------------------------*)

unit TextComp;

{$I jedi.inc}
{$I compopt.inc}

{$IFDEF DELPHI6_UP}
  {$WARN UNIT_PLATFORM OFF}
  {$WARN SYMBOL_PLATFORM OFF}
{$ENDIF DELPHI6_UP}

interface

uses
  SysUtils, Windows, Messages, Classes, Controls, Forms, StdCtrls,
  Buttons, ExtCtrls, JvCombobox, JvExStdCtrls, Contnrs, JVCSForms;

type
  TCompareTool = class(TObject)
  private
    FName: string;
    FExeName: string;
    FParams: string;
    procedure FillFromValues(AValues: string);
  public
    constructor Create(AValues: string = '');
    property Name: string read FName write FName;
    property ExeName: string read FExeName write FExeName;
    property Params: string read FParams write FParams;
  end;

  TCompareTools = class(TObject)
  private
    FItems: TObjectList;
    FExtensionCompareToolMappings: TObjectList;
    function GetCount: Integer;
    function GetItems(AIndex: Integer): TCompareTool;
    procedure LoadExtensionCompareToolMapping(const AKey: string);
    procedure SaveExtensionCompareToolMapping(const AKey: string);
  public
    constructor Create;
    destructor Destroy; override;

    function GetExtensionIndex(AExtension: string): Integer;
    procedure SetExtensionIndex(AExtension: string; AIndex: Integer);
    procedure ReadCompareTools;

    property Count: Integer read GetCount;
    property Items[AIndex: Integer]: TCompareTool read GetItems; default;
  end;

  TTextCompareMode = (tcmDefault, tcmArchiveToArchive);

  TCompareModuleFile = class(TObject)
  private
    FCompareFileName1: string;
    FCompareFileName2: string;
    FCompareTool: TCompareTool;
    FExtension: string;
  public
    property CompareFileName1: string read FCompareFileName1 write FCompareFileName1;
    property CompareFileName2: string read FCompareFileName2 write FCompareFileName2;
    property CompareTool: TCompareTool read FCompareTool write FCompareTool;
    property Extension: string read FExtension write FExtension;
  end;

  TCompareModuleFlag = (cmfFilesLoaded, cmfRevisionsLoaded, cmfCompareFilesPrepared);
  TCompareModuleFlags = set of TCompareModuleFlag;
  TCompareModuleRevisionKind = (cmrkLatest, cmrkLocal);

  TCompareModuleRevisionInfo = class(TObject)
    Kind: TCompareModuleRevisionKind;
    RevisionID: Integer;
    Version: Integer;
    Revision: Integer;
  end;

  TCompareModule = class(TObject)
  private
    FAutoLoadChilds: Boolean;
    FFlags: TCompareModuleFlags;
    FItems: TObjectList;
    FModuleID: Integer;
    FModuleName: string;
    FProjectID: Integer;
    FRevision1: TCompareModuleRevisionInfo;
    FRevision2: TCompareModuleRevisionInfo;
    function GetCount: Integer;
    function GetItems(AIndex: Integer): TCompareModuleFile;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(AExtension: string): TCompareModuleFile;
    procedure Clear;
    property AutoLoadChilds: Boolean read FAutoLoadChilds write FAutoLoadChilds;
    property Count: Integer read GetCount;
    property Flags: TCompareModuleFlags read FFlags write FFlags;
    property Items[AIndex: Integer]: TCompareModuleFile read GetItems; default;
    property ModuleID: Integer read FModuleID write FModuleID;
    property ModuleName: string read FModuleName write FModuleName;
    property ProjectID: Integer read FProjectID write FProjectID;
    property Revision1: TCompareModuleRevisionInfo read FRevision1;
    property Revision2: TCompareModuleRevisionInfo read FRevision2;
  end;

  TCompareModuleList = class(TObject)
  private
    FCompareTools: TCompareTools;
    FDefaultCompareIndex: Integer;
    FIncludeVerRevInFilenames: Boolean;
    FItems: TObjectList;
    FTargetDir1: string;
    FTargetDir2: string;    
    procedure FillModuleCompareFiles(AModule: TCompareModule; ARevisionIndex: Integer);
    procedure FillModuleFiles(AModule: TCompareModule);
    procedure FillModuleRevisionInfo(AModule: TCompareModule; AModuleRevisionInfo: TCompareModuleRevisionInfo);
    function GetArchiveFile(AModule: TCompareModule; AModuleRevisionInfo: TCompareModuleRevisionInfo; AFileIndex: Integer; ATargetDir: string): string;
    function GetDFMTextFile(const ASourceFile, ATargetDir: string): string;
    function GetCount: Integer;
    function GetItems(AIndex: Integer): TCompareModule;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(AModuleID: Integer; const AModuleName: string): TCompareModule;
    procedure Compare;
    procedure PrepareModules;
    property CompareTools: TCompareTools read FCompareTools;
    property Count: Integer read GetCount;
    property Items[AIndex: Integer]: TCompareModule read GetItems; default;
  end;

  TVCSTextCompare = class(TJVCSForm)
    btnClose: TButton;
    btnCompare: TButton;
    cbxTool: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    cbArch2: TComboBox;
    spBtnInfo: TSpeedButton;
    Help: TSpeedButton;
    cbArchVers: TComboBox;
    cbArch1: TComboBox;
    Label3: TLabel;
    cbMembers: TComboBox;
    Label4: TLabel;
    Panel1: TPanel;
    lblVersions: TLabel;
    Label5: TLabel;
    spbtnTools: TSpeedButton;
    rbSource_Archive: TRadioButton;
    rbArchive_Archive: TRadioButton;
    cbShortNames: TCheckBox;
    ecbxSource: TJvComboBox;
    spBtnNextRev: TSpeedButton;
    spBtnPrevRev: TSpeedButton;
    cbIncludeVRFileName: TCheckBox;
    Panel2: TPanel;
    lblMemberCount: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCloseClick(Sender: TObject);
    procedure btnCompareClick(Sender: TObject);
    procedure cbArchVersChange(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure HelpTopic1Click(Sender: TObject);
    procedure spBtnInfoClick(Sender: TObject);
    procedure cbMembersChange(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ecbxSourceChange(Sender: TObject);
    procedure spbtnToolsClick(Sender: TObject);
    procedure rbSource_ArchiveClick(Sender: TObject);
    procedure spBtnNextRevClick(Sender: TObject);
  private
    ActDir,
    CompareFile1,
    CompareFile2,
    Filter1: string;
    RevisionIDs: TObjectList;
    SourceIDs: TStringList;
    FCompareTools: TCompareTools;

    function CreateTempFile(var CompFile: string; SourceFile,
      TargetDir: string): Boolean;
    function CreateArchTempFile(var CompFile: string;
      const RevisionID: string;
      TargetDir: string;
      const DFM: Boolean): Boolean;
    procedure GetProjectModules;
    procedure FindVersions;
    procedure FindRevisionMembers(RevisionID: string);
    procedure GetCompareTools;
    procedure SetCompareButtonState;
  public
    CompareMode: TTextCompareMode;
    SelectedModuleID: Integer;
    SelectedModule: string;
    SelectedMember: string;
    SelectedRevisionID: Integer;
  end;

var
  VCSTextCompare: TVCSTextCompare;

type
  TAddMessageProc = procedure(MsgStr: string; const MsgCol: Word) of object;

procedure DoModuleCompare(AModuleName: string); overload;
procedure DoModuleCompare(AWindowHandle: HWND; AModuleName: string); overload;
procedure DoModuleCompare(AModuleName, AModuleMember: string;
  ARevisionID: Integer; ACompareMode: TTextCompareMode = tcmDefault); overload;
procedure DoModuleCompare(AModuleID: Integer; const AModuleName, AModuleMember: string;
  ARevisionID: Integer); overload;
procedure DoModuleCompare(AModuleName, AModuleMember: string;
  ARevisionID: Integer; AMessageProc: TAddMessageProc); overload;
procedure DoModuleCompare(AWindowHandle: HWND;
  AModuleID: Integer; AModuleName, AModuleMember: string; ARevisionID: Integer;
  AMessageProc: TAddMessageProc; ACompareMode: TTextCompareMode = tcmDefault); overload;

implementation

uses
  {$IFDEF DEBUG}
  JclDebug,
  {$ENDIF DEBUG}
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  ShellAPI, FileCtrl, ModuleInfo, JVCSClientConsts, VCSProcBase, VCSBase, CheckSum, HandleBlob,
  ApsCli, RFormat, DBModule, Options, TZHandling, ConfigStorage, Dialogs,
  JVCSDialogs, JVCSGUIClientResources, JclStrings, JclSysInfo, JVCSClientFunctions,
  JVCSClientObj;

{$R *.dfm}
{$DEFINE DFM} //USc 30.10.2003 - can't find any usage

type
  TTextCompRevisionItem = class(TObject)
  private
    FRevision: Integer;
    FRevisionID: Integer;
    FVersion: Integer;
  public
    constructor Create;
    property Revision: Integer read FRevision write FRevision;
    property RevisionID: Integer read FRevisionID write FRevisionID;
    property Version: Integer read FVersion write FVersion;
  end;

constructor TTextCompRevisionItem.Create;
begin
  inherited Create;
  FRevision := 0;
  FRevisionID := 0;
  FVersion := 0;
end;

type
  TExtensionCompareTool = class(TObject)
  private
    FCompareTool: string;
    FExtension: string;
  public
    constructor Create;
    property CompareTool: string read FCompareTool write FCompareTool;
    property Extension: string read FExtension write FExtension;
  end;

constructor TExtensionCompareTool.Create;
begin
  inherited Create;
  FCompareTool := '';
  FExtension := '';
end;

constructor TCompareTool.Create(AValues: string = '');
begin
  inherited Create;
  FillFromValues(AValues);
end;

procedure TCompareTool.FillFromValues(AValues: string);
begin
  FName := '';
  FExeName := '';
  FParams := '';
  if AValues <> '' then
  begin
    FName := Copy(AValues, 1, Pos('|', AValues) - 1);
    System.Delete(AValues, 1, Pos('|', AValues));
    FExeName := Copy(AValues, 1, Pos('|', AValues) - 1);
    System.Delete(AValues, 1, Pos('|', AValues));
    FParams := AValues;
  end;
end;

constructor TCompareTools.Create;
begin
  inherited Create;
  FItems := TObjectList.Create;
  FExtensionCompareToolMappings := TObjectList.Create;
  ReadCompareTools;
  LoadExtensionCompareToolMapping(sBaseRegistryKey + '\CompareToolMapping');
end;

destructor TCompareTools.Destroy;
begin
  SaveExtensionCompareToolMapping(sBaseRegistryKey + '\CompareToolMapping');
  FItems.Free;
  FExtensionCompareToolMappings.Free;
  inherited Destroy;
end;

procedure TCompareTools.ReadCompareTools;
var
  CompareTool: TCompareTool;
  I: Integer;
  CurrentTool: string;
begin
  FItems.Clear;
  CompareTool := TCompareTool.Create;
  with CompareTool do
  begin
    Name := JVCSRES_JEDI_VCS_Diff;
    ExeName := LowerCase(sDLLDirectory) + cVCSDiffName;
    Params := '/s:%1 /t:%2 /sc:%3 /tc:%4 /autostart';
  end;
  FItems.Add(CompareTool);
  I := 0;
  repeat
    Inc(I);
    CurrentTool :=
      jvcsReadString(sBaseRegistryKey + '\CompareTools', 'Custom' + IntToStr(I), '');
    if (CurrentTool <> '') then
    begin
      CompareTool := TCompareTool.Create(CurrentTool);
      if (CompareTool.ExeName <> '') and (CompareTool.Params <> '') then
        FItems.Add(CompareTool)
      else
        FItems.Free;
    end;
  until CurrentTool = '';
end;

procedure TCompareTools.LoadExtensionCompareToolMapping(const AKey: string);
var
  I, J, Idx: Integer;
  S, Extension, CompareTool: string;
begin
  FExtensionCompareToolMappings.Clear;
  I := 0;
  while jvcsValueExists(AKey, Format('Mapping%d', [I])) do
  begin
    S := jvcsReadString(AKey, Format('Mapping%d', [I]), '');
    Extension := StrToken(S, ';');
    CompareTool := S;
    if Extension <> '' then
    begin
      Idx := -1;
      for J := 0 to Pred(FItems.Count) do
        if SameText(TCompareTool(FItems[J]).Name, CompareTool) then
        begin
          Idx := J;
          Break;
        end;
      if Idx <> -1 then
        SetExtensionIndex(Extension, Idx);
    end;
    Inc(I);
  end;
end;

procedure TCompareTools.SaveExtensionCompareToolMapping(const AKey: string);
var
  I: Integer;
  S: string;
begin
  jvcsDeleteKey(AKey);
  for I := 0 to Pred(FExtensionCompareToolMappings.Count) do
  begin
    with TExtensionCompareTool(FExtensionCompareToolMappings[I]) do
      S := Format('%s;%s', [Extension, CompareTool]);
    jvcsWriteString(AKey, Format('Mapping%d', [I]), S);
  end;
end;

function TCompareTools.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TCompareTools.GetItems(AIndex: Integer): TCompareTool;
begin
  Result := TCompareTool(FItems[AIndex]);
end;

function TCompareTools.GetExtensionIndex(AExtension: string): Integer;
var
  I: Integer;
  CompareToolName: string;
begin
  Result := -1;
  CompareToolName := '';
  for I := 0 to Pred(FExtensionCompareToolMappings.Count) do
    if SameText(TExtensionCompareTool(FExtensionCompareToolMappings[I]).Extension, AExtension) then
    begin
      CompareToolName := TExtensionCompareTool(FExtensionCompareToolMappings[I]).CompareTool;
      Break;
    end;
  if CompareToolName <> '' then
    for I := 0 to Pred(Count) do
      if SameText(CompareToolName, Items[I].Name) then
      begin
        Result := I;
        Break;
      end;
end;

procedure TCompareTools.SetExtensionIndex(AExtension: string; AIndex: Integer);
var
  I, Idx: Integer;
  ExtensionCompareTool: TExtensionCompareTool;
begin
  Idx := -1;
  for I := 0 to Pred(FExtensionCompareToolMappings.Count) do
    if SameText(TExtensionCompareTool(FExtensionCompareToolMappings[I]).Extension, AExtension) then
    begin
      Idx := I;
      Break;
    end;
  if Idx = -1 then
  begin
    ExtensionCompareTool := TExtensionCompareTool.Create;
    ExtensionCompareTool.Extension := AExtension;
    ExtensionCompareTool.CompareTool := Items[AIndex].Name;
    FExtensionCompareToolMappings.Add(ExtensionCompareTool);
  end
  else
  begin
    ExtensionCompareTool := TExtensionCompareTool(FExtensionCompareToolMappings[Idx]);
    if Items[AIndex].Name <> ExtensionCompareTool.CompareTool then
      ExtensionCompareTool.CompareTool := Items[AIndex].Name;
  end;
end;

{ TCompareModule }

constructor TCompareModule.Create;
begin
  inherited Create;
  FItems := TObjectList.Create;
  FAutoLoadChilds := True;
  FRevision1 := TCompareModuleRevisionInfo.Create;
  FRevision2 := TCompareModuleRevisionInfo.Create;
end;

destructor TCompareModule.Destroy;
begin
  FRevision2.Free;
  FRevision1.Free;
  FItems.Free;
  inherited Destroy;
end;

function TCompareModule.Add(AExtension: string): TCompareModuleFile;
begin
  FItems.Add(TCompareModuleFile.Create);
  Result := TCompareModuleFile(FItems.Last);
  Result.Extension := AExtension;
end;

procedure TCompareModule.Clear;
begin
  FItems.Clear;
end;

function TCompareModule.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TCompareModule.GetItems(AIndex: Integer): TCompareModuleFile;
begin
  Result := TCompareModuleFile(FItems[AIndex]);
end;

{ TCompareModuleList }

constructor TCompareModuleList.Create;
begin
  inherited Create;
  FItems := TObjectList.Create;
  FCompareTools := TCompareTools.Create;
  FDefaultCompareIndex := jvcsReadInteger(sBaseRegistryKey + crbOptions, 'DefaultCompare', 0);
  FTargetDir1 := GetAppdataFolder + '\JEDI\JVCS\COMPARE\1\';
  FTargetDir2 := GetAppdataFolder + '\JEDI\JVCS\COMPARE\2\';
  FIncludeVerRevInFilenames := jvcsReadBool(sBaseRegistryKey + crbOptions, 'CompareIncludeVRFileName', False); 
end;

destructor TCompareModuleList.Destroy;
begin
  FCompareTools.Free;
  FItems.Free;
  inherited Destroy;
end;

function TCompareModuleList.Add(AModuleID: Integer; const AModuleName: string): TCompareModule;
begin
  FItems.Add(TCompareModule.Create);
  Result := TCompareModule(FItems.Last);
  Result.ModuleID := AModuleID;
  Result.ModuleName := AModuleName;
end;

procedure TCompareModuleList.Compare;
var
  I, J: Integer;
  ParameterStr, CompareToolPath, CompareToolParam: string;
  ExecResult: Integer;
begin
  PrepareModules;
  for I := 0 to Count - 1 do
    for J := 0 to Items[I].Count - 1 do
    if Assigned(Items[I][J].CompareTool) then
    begin
      CompareToolPath := Items[I][J].CompareTool.ExeName;
      CompareToolParam := Items[I][J].CompareTool.Params;

      ParameterStr := SearchAndChange(CompareToolParam, '%1', '"' + Items[I][J].CompareFileName1 + '"');
      ParameterStr := SearchAndChange(ParameterStr, '%2', '"' + Items[I][J].CompareFileName2 + '"');
      {
      ParameterStr := SearchAndChange(ParameterStr, '%3', '"' + CommentStr1 + '"');
      ParameterStr := SearchAndChange(ParameterStr, '%4', '"' + CommentStr2 + '"');
      }

      ExecResult := ShellExecute(Application.Handle, 'open',
        PChar(CompareToolPath),
        PChar(ParameterStr),
        PChar(ExtractFileDir(CompareToolPath)),
        sw_ShowNormal);
    end;
end;

procedure TCompareModuleList.FillModuleCompareFiles(AModule: TCompareModule; ARevisionIndex: Integer);
var
  I: Integer;
  Info: TCompareModuleRevisionInfo;
  CompareFileName, LocalFileName, TargetDir: string;
begin
  if ARevisionIndex = 1 then
  begin
    Info := AModule.Revision1;
    TargetDir := FTargetDir1;
  end
  else
  begin
    Info := AModule.Revision2;
    TargetDir := FTargetDir2;
  end;

  for I := 0 to AModule.Count - 1 do
  begin
    CompareFileName := '';
    if Info.Kind = cmrkLocal then
    begin
      LocalFileName := ChangeFileExt(AModule.ModuleName, AModule[I].Extension);
      if SameText(AModule[I].Extension, '.dfm') and IsBinaryFile(LocalFileName) then
        CompareFileName := GetDFMTextFile(LocalFileName, TargetDir)
      else
        CompareFileName := LocalFileName;
    end
    else
      CompareFileName := GetArchiveFile(AModule, Info, I, TargetDir);
    if ARevisionIndex = 1 then
      AModule[I].CompareFileName1 := CompareFileName
    else
      AModule[I].CompareFileName2 := CompareFileName;
  end;
end;

procedure TCompareModuleList.FillModuleFiles(AModule: TCompareModule);
var
  I, RevisionID, CompareIdx: Integer;
  GetRevisionStatus: TJVCSGetRevisionStatus;
  FixedExtension: string;
  CompareModuleFile: TCompareModuleFile;
begin
  RevisionID := 0;
  AModule.Clear;
  if AModule.Revision1.Kind = cmrkLatest then
    RevisionID := AModule.Revision1.RevisionID
  else
  if AModule.Revision2.Kind = cmrkLatest then
    RevisionID := AModule.Revision2.RevisionID;
  GetRevisionStatus := TJVCSGetRevisionStatus.Create(nil);
  try
    GetRevisionStatus.RevisionID := RevisionID;
    DataModule1.ClientObjectSendRequest(GetRevisionStatus);
    for I := 0 to Pred(GetRevisionStatus.OutputItemCount) do
    begin
      FixedExtension := TrimRight(GetRevisionStatus.OutputItems[I].RevisionExtension);
      CompareModuleFile := AModule.Add(FixedExtension);
      CompareIdx := FCompareTools.GetExtensionIndex(FixedExtension);
      if CompareIdx <> -1 then
        CompareModuleFile.CompareTool := FCompareTools[CompareIdx]
      else
      if (FDefaultCompareIndex >= 0) and (FDefaultCompareIndex < FCompareTools.Count) then
        CompareModuleFile.CompareTool := FCompareTools[FDefaultCompareIndex]
      else
        CompareModuleFile.CompareTool := nil;
    end;
  finally
    GetRevisionStatus.Free;
  end;
end;

procedure TCompareModuleList.FillModuleRevisionInfo(AModule: TCompareModule; AModuleRevisionInfo: TCompareModuleRevisionInfo);
var
  I: Integer;
  GetRevisionListById: TJVCSGetRevisionListById;
begin
  GetRevisionListById := TJVCSGetRevisionListById.Create(nil);
  try
    GetRevisionListById.ModuleID := AModule.ModuleID;
    if AModule.ProjectID > 0 then
      GetRevisionListById.ProjectID := AModule.ProjectID
    else
      GetRevisionListById.ProjectID := ServerProjectID;
    DataModule1.ClientObjectSendRequest(GetRevisionListById);
    AModuleRevisionInfo.RevisionID := -1;
    AModuleRevisionInfo.Version := -1;
    AModuleRevisionInfo.Revision := -1;
    for I := 0 to Pred(GetRevisionListById.OutputItemCount) do
    begin
      AModuleRevisionInfo.RevisionID := GetRevisionListById.OutputItems[I].RevisionID;
      AModuleRevisionInfo.Version := GetRevisionListById.OutputItems[I].Version;
      AModuleRevisionInfo.Revision := GetRevisionListById.OutputItems[I].Revision;
    end;
  finally
    GetRevisionListById.Free;
  end;
end;

function TCompareModuleList.GetArchiveFile(AModule: TCompareModule; AModuleRevisionInfo: TCompareModuleRevisionInfo; AFileIndex: Integer; ATargetDir: string): string;
var
  TempFile: string;
  GetSingleBlob: TJVCSGetSingleBlob;
begin
  TempFile := ATargetDir + ChangeFileExt(ExtractFileName(AModule.ModuleName), AModule[AFileIndex].Extension);
  if FIncludeVerRevInFilenames then
    TempFile := ChangeFileExt(TempFile, Format('_%d_%d', [AModuleRevisionInfo.Version, AModuleRevisionInfo.Revision])
      + AModule[AFileIndex].Extension);
  GetSingleBlob := TJVCSGetSingleBlob.Create(nil);
  try
    GetSingleBlob.RevisionID := AModuleRevisionInfo.RevisionID;
    GetSingleBlob.Extension := AModule[AFileIndex].Extension;
    GetJvcsConnection.SendRequest(GetSingleBlob);
    GetSingleBlob.ExtractBlobToFile(TempFile, GetSingleBlob.ModuleBinary);
  finally
    GetSingleBlob.Free;
  end;
  FileSetReadOnlyAttribute(TempFile, False);
  if SameText(AModule[AFileIndex].Extension, '.dfm') and IsBinaryFile(TempFile) then
    Result := GetDFMTextFile(TempFile, ATargetDir)
  else
    Result := TempFile;  
end;

function TCompareModuleList.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TCompareModuleList.GetDFMTextFile(const ASourceFile, ATargetDir: string): string;
var
  FStream: TFileStream;
  OutStream: TMemoryStream;
begin
  Result := ATargetDir + ChangeFileExt(ExtractFileName(ASourceFile), '.txt');
  FStream := TFileStream.Create(ASourceFile, fmOpenRead or fmShareDenyNone);
  OutStream := TMemoryStream.Create;
  try
    if IsBinaryDFMStream(FStream) then
      ObjectResourceToText(FStream, OutStream)
    else
      OutStream.CopyFrom(FStream, 0);
    OutStream.Position := 0;
    OutStream.SaveToFile(Result);
  finally
    OutStream.Free;
    FStream.Free;
  end;
end;

function TCompareModuleList.GetItems(AIndex: Integer): TCompareModule;
begin
  Result := TCompareModule(FItems[AIndex]);
end;

procedure TCompareModuleList.PrepareModules;
var
  I: Integer;
begin
  ForceDirectories(FTargetDir1);
  ForceDirectories(FTargetDir2);  
  for I := 0 to Count - 1 do
  begin
    if not (cmfRevisionsLoaded in Items[I].Flags) then
    begin
      if Items[I].Revision1.Kind = cmrkLatest then
        FillModuleRevisionInfo(Items[I], Items[I].Revision1);
      if Items[I].Revision2.Kind = cmrkLatest then
        FillModuleRevisionInfo(Items[I], Items[I].Revision2);
      Items[I].Flags := Items[I].Flags + [cmfRevisionsLoaded];
    end;
    if Items[I].AutoLoadChilds and not (cmfFilesLoaded in Items[I].Flags) then
    begin
      FillModuleFiles(Items[I]);
      Items[I].Flags := Items[I].Flags + [cmfFilesLoaded];
    end;
    if not (cmfCompareFilesPrepared in Items[I].Flags) then
    begin
      FillModuleCompareFiles(Items[I], 1);
      FillModuleCompareFiles(Items[I], 2);
    end;
  end;
end;

function GetArchiveCRC(AWindowHandle: HWND; ARevisionID: Integer;
  ARevisionExtension: string): string;
begin
  Result := '00000000';
  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_REVISION_STATUS';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [ARevisionID]);
    SetupTimeoutCounter;
    AppSrvClient1.Send;

    while WaitForAppSrvClient do
      Application.ProcessMessages;
    if (AppSrvClientErr = -99) then 
    begin
      ShowServerTimeOut(AWindowHandle);
      Exit;
    end;
    if (AppSrvClientErr <> 0) or
      (AppSrvClient1.AnswerStatus <> '200') then
    begin
      ShowServerError(AWindowHandle, AppSrvClient1.Answer.Fields[0],
        AppSrvClient1.AnswerStatus);
      Exit;
    end;
    AppSrvClient1.Answer.First;
    Result := '00000000';
    while not AppSrvClient1.Answer.Eof do
    begin
      //USc 09.11.2003 use SameText instead of equal because ProjAdmin uses the
      // filename from the disk and that extension might have another case than
      // the lowercase version stored in the db
      if SameText(ARevisionExtension, TrimRight(AppSrvClient1.Answer.Fields[10])) then
        Result := IntToHex(StrToIntDef(AppSrvClient1.Answer.Fields[8], 0), 8);
      AppSrvClient1.Answer.Next;
    end; // while not AppSrvClient1.Answer.EoF do begin
  end; // with DataModule1 do begin
end;

function GetLatestModuleRevisionID(AWindowHandle: HWND;
  AModuleName: string): Integer;
var
  ModuleID: Integer;
begin
  Result := 0;
  // Get Module ID
  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_MODULE_ID';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [AModuleName]);
    SetupTimeoutCounter;
    AppSrvClient1.Send;

    while WaitForAppSrvClient do
      Application.ProcessMessages;
    if (AppSrvClientErr = -99) then
    begin
      ShowServerTimeOut(AWindowHandle);
      Exit;
    end;
    if (AppSrvClientErr <> 0) or
      (AppSrvClient1.AnswerStatus <> '200') then
    begin
      ShowServerError(AWindowHandle, AppSrvClient1.Answer.Fields[0],
        AppSrvClient1.AnswerStatus);
      Exit;
    end;
    ModuleID := StrToIntDef(AppSrvClient1.Answer.Fields[0], 0);
  end; // with DataModule1 do begin

  if ModuleID > 0 then
    with DataModule1 do
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_REVISION_LIST_BY_ID';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [ModuleID]);
      AppSrvClient1.Request.WriteFields(False, [0]); // all projects !
      SetupTimeoutCounter;
      AppSrvClient1.Send;

      while WaitForAppSrvClient do
        Application.ProcessMessages;
      if (AppSrvClientErr = -99) then
      begin
        ShowServerTimeOut(AWindowHandle);
        Exit;
      end;
      if (AppSrvClientErr <> 0) or
        (AppSrvClient1.AnswerStatus <> '200') then
      begin
        ShowServerError(AWindowHandle, AppSrvClient1.Answer.Fields[0],
          AppSrvClient1.AnswerStatus);
        Exit;
      end;

      AppSrvClient1.Answer.First;
      while not AppSrvClient1.Answer.Eof do
      begin
        if StrToIntDef(AppSrvClient1.Answer.Fields[0], 0) = ModuleID then
          Result := StrToIntDef(AppSrvClient1.Answer.Fields[6], 0);
        AppSrvClient1.Answer.Next;
      end; // if not AppSrvClient1.Answer.EoF then begin
    end;
end;

function GetCompareFiles: string;
begin
  Result := jvcsReadString(sBaseRegistryKey + crbFilters, 'Compare files', dfCompMod);
  if Pos('*.dfm', LowerCase(Result)) = 0 then
  begin
    if (Length(Result) > 0) and (Result[Length(Result)] <> ';') then
      Result := Result + ';';
    Result := Result + '*.dfm';
  end;
end;

procedure DoModuleCompare(AModuleName: string);
begin
  DoModuleCompare(Application.Handle, AModuleName);
end;

procedure DoModuleCompare(AWindowHandle: HWND; AModuleName: string);
var
  DummyProc: TAddMessageProc;
begin
  DummyProc := nil;
  DoModuleCompare(AWindowHandle, 0, AModuleName, AModuleName, 0, DummyProc);
end;

procedure DoModuleCompare(AModuleName, AModuleMember: string;
  ARevisionID: Integer; ACompareMode: TTextCompareMode = tcmDefault);
var
  DummyProc: TAddMessageProc;
begin
  DummyProc := nil;
  DoModuleCompare(Application.Handle, 0, AModuleName, AModuleMember, ARevisionID,
    DummyProc, ACompareMode);
end;

procedure DoModuleCompare(AModuleID: Integer; const AModuleName, AModuleMember: string;
  ARevisionID: Integer); overload;
var
  DummyProc: TAddMessageProc;
begin
  DummyProc := nil;
  DoModuleCompare(Application.Handle, AModuleID, AModuleName, AModuleMember, ARevisionID,
    DummyProc);
end;

procedure DoModuleCompare(AModuleName, AModuleMember: string;
  ARevisionID: Integer; AMessageProc: TAddMessageProc);
begin
  DoModuleCompare(Application.Handle, 0, AModuleName, AModuleMember, ARevisionID,
    AMessageProc);
end;

procedure DoModuleCompare(AWindowHandle: HWND;
  AModuleID: Integer; AModuleName, AModuleMember: string; ARevisionID: Integer;
  AMessageProc: TAddMessageProc; ACompareMode: TTextCompareMode = tcmDefault);
var
  CompareFile, Filter1, CRC1, CRC2, Mess: string;
  DlgIcon: Integer;
begin
  if AModuleMember = '' then
    AModuleMember := AModuleName;
  CompareFile := ChangeFileExt(AModuleName, ExtractFileExt(AModuleMember));
{//USc 08.11.2003 - disabled -> mantis #1204
  if not FileExists(CompareFile) then
  begin
    (* Source file <%s> not found. Nothing to compare. *)
    MessageBox(AWindowHandle, PChar(FmtLoadStr(275, [CompareFile])),
      cMsgBoxCaption, MB_OK or MB_ICONWARNING);
    Exit;
  end;
}
  Filter1 := GetCompareFiles;
  if (CompareFile <> '') and
    (not MatchWithFilter(ExtractFileName(CompareFile), Filter1)) and
    (
      (not FileExists(CompareFile))
      or
      (
       IsBinaryFile(CompareFile) and
       (not jvcsReadBool(sBaseRegistryKey + crbOptions, 'IgnoreBinary_Text', False))
      )
    )
  then
  begin
    UseRegistry := True;
    DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
    DSAIdentsMessageDlg(Format(JVCSRES_Visual_compare_is_only_available_for_text_files46 + #13#10 +
      JVCSRES_Known_text_files58_4037s41, [Filter1])
      , mtInformation
      , [mbOK]
      , 0
      , sBaseRegistryKey + crbMRU + 'Dlgs'
      , 'CompTxtFilt'
      , idOk
      );
    if FileExists(CompareFile) then
    begin
      if ARevisionID = 0 then
        ARevisionID := GetLatestModuleRevisionID(AWindowHandle, AModuleName);
      CRC1 := GetArchiveCRC(AWindowHandle, ARevisionID, ExtractFileExt(AModuleMember));
      CRC2 := IntToHex(CRCInt(CompareFile, Mess), 8);
      if CRC1 = '00000000' then
      begin
        Mess := JVCSRES_No_CRC32_checksum_stored_for_this_module46 + #13#10 +
          JVCSRES_Probably_the_module_was_checked_in_with_a_version_60_1462460;
        DlgIcon := MB_ICONWARNING;
      end
      else
      begin
        if CRC1 = CRC2 then
        begin
          Mess := Format(JVCSRES_Binary_compare58_6037s6246 + #13#10 +
            JVCSRES_Archive58_3637s + #13#10 +
            JVCSRES_File58________3637s + #13#10 +
            JVCSRES_The_modules_are_37s46, [CompareFile, CRC1, CRC2, JVCSRES_equal]);
          DlgIcon := MB_ICONINFORMATION;
          // Message Window
          if Assigned(AMessageProc) then
            AMessageProc(Format(JVCSRES_Binary_compare58_37s_45_equal, [CompareFile]), msclNormal);
        end
        else
        begin
          Mess := Format(JVCSRES_Binary_compare58_6037s6246 + #13#10 +
            JVCSRES_Archive58_3637s + #13#10 +
            JVCSRES_File58________3637s + #13#10 +
            JVCSRES_The_modules_are_37s46, [CompareFile, CRC1, CRC2, JVCSRES_not_equal]);
          DlgIcon := MB_ICONWARNING;
          // Message Window
          if Assigned(AMessageProc) then
            AMessageProc(Format(JVCSRES_Binary_compare58_37s_45_not_equal, [CompareFile]),
              msclNormal);
        end;
      end; // else if CRC1 = '00000000' then begin
    end
    else
    begin
      Mess := Format(JVCSRES_JEDI_VCS_cannot_find_the_source_file58 + #13#10
               + '<%s>.' + #13#10
               + JVCSRES_Unable_to_Binary_compare46, [CompareFile]);
      DlgIcon := MB_ICONWARNING;
    end;
    MessageBox(AWindowHandle, PChar(Mess), cMsgBoxCaption, MB_OK or DlgIcon);
  end // if not MatchWithFilter(
  else
  begin
    VCSTextCompare := TVCSTextCompare.Create(Application);
    try
      VCSTextCompare.CompareMode := ACompareMode;
      VCSTextCompare.SelectedModuleID := AModuleID;    
      VCSTextCompare.SelectedModule := AModuleName;
      VCSTextCompare.SelectedMember := AModuleMember;
      VCSTextCompare.SelectedRevisionID := ARevisionID;
      VCSTextCompare.ShowModal;
    finally
      VCSTextCompare.Free;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSTextCompare.FormCreate(Sender: TObject);
var
  DlgTop,
  DlgLeft,
  DlgWidth,
  DlgHeight: Integer;
begin
  try
    Constraints.MinHeight := Height;
    Constraints.MaxHeight := Height;
    Constraints.MinWidth := Width;
    SelectedRevisionID := 0;
    GetDir(0, ActDir);

    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);
    Filter1 := GetCompareFiles;

    if not jvcsReadWindowPosAndSize(sBaseRegistryKey + crbWindows, 'Compare',
      DlgTop, DlgLeft, DlgWidth, DlgHeight) then
    begin
      DlgTop := (Screen.Height - Height) div 2;
      DlgLeft := (Screen.Width - Width) div 2;
      DlgWidth := 420;
      DlgHeight := 250;
    end;
    Top := DlgTop;
    Left := DlgLeft;
    Width := DlgWidth;
    Height := DlgHeight;

    {$IFDEF CUSTOMDRIVE}
    sDriveSubst := RegReadString(HKCU, sBaseRegistryKey + crbProjects +
      ExtractFileName(sProjectName), 'LocalDrive', '');
    if (sDriveSubst = '') then
      sDriveSubst := RegReadString(HKCU, sBaseRegistryKey + crbOptions,
        'LocalDrive', '');
    {$ENDIF CUSTOMDRIVE}

    SourceIDs := TStringList.Create;
    RevisionIDs := TObjectList.Create;

    rbSource_ArchiveClick(Self);

    Screen.Cursor := crHourGlass;

    FCompareTools := TCompareTools.Create;
    GetCompareTools;

    cbxTool.ItemIndex :=
      jvcsReadInteger(sBaseRegistryKey + crbOptions, 'DefaultCompare', 0);
    cbShortNames.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'CompareShortNames', False);
    cbIncludeVRFileName.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'CompareIncludeVRFileName', False);

    SelectedModuleID := 0;
    SelectedModule := '';
    SelectedMember := '';
    CompareMode := tcmDefault;
    Screen.Cursor := crDefault;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSTextCompare.GetProjectModules;
begin
  SourceIDs.Clear;
  ecbxSource.Items.Clear;
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
      if MatchWithFilter(ExtractFileName(AppSrvClient1.Answer.Fields[1]), Filter1) then
      begin
        {$IFDEF CUSTOMDRIVE}
        SourceIDs.Add(ChangeDriveName(AppSrvClient1.Answer.Fields[2], sDriveSubst) +
          AppSrvClient1.Answer.Fields[1] + '=' +
          AppSrvClient1.Answer.Fields[0]);
        ecbxSource.Items.Add(ChangeDriveName(AppSrvClient1.Answer.Fields[2],
          sDriveSubst) +
          AppSrvClient1.Answer.Fields[1]);
        {$ELSE}
        SourceIDs.Add(AppSrvClient1.Answer.Fields[2] +
          AppSrvClient1.Answer.Fields[1] + '=' +
          AppSrvClient1.Answer.Fields[0]);
        ecbxSource.Items.Add(AppSrvClient1.Answer.Fields[2] +
          AppSrvClient1.Answer.Fields[1]);
        {$ENDIF CUSTOMDRIVE}
      end;
      AppSrvClient1.Answer.Next;
    end; // while not AppSrvClient1.Answer.Eof do begin
  end; // with DataModule1 do begin
end;

//------------------------------------------------------------------------------

procedure TVCSTextCompare.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then 
  begin
    btnCloseClick(Self);
    Key := 0;
  end;    
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Compare_Modules);
end;

//------------------------------------------------------------------------------

procedure TVCSTextCompare.btnCompareClick(Sender: TObject);
var
  SMSize, ExecResult: Integer;
  IsDFMFile, IsLocalArchive, CreateRes: Boolean;
  ParameterStr, CommentStr1, CommentStr2, RevisionID, Filter1,
  ShortModulName, TestFile, CommentFileName: string;
  cbVer2: TComboBox;
  CompareToolPath, CompareToolParam: string;

  function GetRevisionID(AssComboBox: TComboBox): string;
  begin
    Result := IntToStr(TTextCompRevisionItem(RevisionIDs[AssComboBox.ItemIndex]).RevisionID);
  end; // function GetRecNr(AssComboBox: TComboBox): Integer;

  function GetVerStr(AssComboBox: TComboBox): string;
  var
    RevisionItem: TTextCompRevisionItem;
  begin
    RevisionItem := TTextCompRevisionItem(RevisionIDs[AssComboBox.ItemIndex]);
    Result := Format('V%d.%d', [RevisionItem.Version, RevisionItem.Revision]);
  end; // function GetVerStr(AssComboBox: TComboBox): String;

  function GetCRCChkSum(FileName: string): string;
  var
    CRCStr: string;
  begin
    try
      CRCStr := CRCString(FileName);
      if Pos('$', CRCStr) = 0 then
        CRCStr := '';
    except
      CRCStr := '';
    end;
    Result := CRCStr;
  end; // function GetCRCChkSum(FileName: String): String;
begin
  CompareToolPath := '';
  CompareToolParam := '';
  if (cbxTool.ItemIndex >= 0) and (cbxTool.ItemIndex < FCompareTools.Count) then
  begin
    FCompareTools.SetExtensionIndex(cbMembers.Text, cbxTool.ItemIndex);
    CompareToolPath := FCompareTools[cbxTool.ItemIndex].ExeName;
    CompareToolParam := FCompareTools[cbxTool.ItemIndex].Params;
  end;
  if rbSource_Archive.Checked then
  begin
    // Compare Source-Archive
    TestFile := ecbxSource.Text;
    TestFile := ChangeFileExt(TestFile, cbMembers.Text);
    if not FileExists(TestFile) then
    begin
      MessageBox(WindowHandle,
        PChar(Format('<%s>' + #13#10 +
          JVCSRES_JEDI_VCS_cannot_find_this_file_on_the_local_disk46_, [TestFile]) +
          JVCSRES_JEDI_VCS_cannot_compare_the_selected_versions46),
        cMsgBoxCaption, MB_OK or MB_ICONWARNING);
      Exit;
    end; // if not FileExists(TestFile) then begin
  end; // if rbSource_Archive.Checked then begin

  Filter1 := GetCompareFiles;
  if (not MatchWithFilter(ExtractFileName(cbMembers.Text), Filter1)) and
    IsBinaryFile(TestFile) and
    (not jvcsReadBool(sBaseRegistryKey + crbOptions, 'IgnoreBinary_Text', False)) then
  begin
    MessageBox(WindowHandle, PChar(Format(JVCSRES_Visual_compare_is_only_available_for_text_files46 + #13#10 +
      JVCSRES_Known_text_files58_4037s41, [Filter1])),
      cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
    Exit;
  end; // if not MatchWithFilter(

  //---------------------------------------
  CreateRes := True;
  IsDFMFile := cbMembers.Text = '.dfm';
  IsLocalArchive := rbSource_Archive.Checked;
  //---------------------------------------
  // 1. Datei
  if IsLocalArchive then
  begin
    CompareFile1 := ChangeFileExt(ecbxSource.Text, cbMembers.Text);
    if IsDFMFile and IsBinaryFile(CompareFile1) then
    begin
      CreateRes := CreateTempFile ( CompareFile1
                                  , CompareFile1
                                  , GetAppdataFolder + '\JEDI\JVCS\COMPARE\1'
                                  );
    end;
    cbVer2 := cbArchVers;
  end
  else
  begin
    RevisionID := GetRevisionID(cbArch1);
    if CreateRes then
    begin
      CreateRes := CreateArchTempFile ( CompareFile1
                                      , RevisionID
                                      , GetAppdataFolder + '\JEDI\JVCS\COMPARE\1'
                                      , IsDFMFile
                                      );
    end;
    cbVer2 := cbArch2;
  end;
  // 2. Datei
  if CreateRes then
    RevisionID := GetRevisionID(cbVer2);
  if CreateRes then
  begin
    CreateRes := CreateArchTempFile ( CompareFile2
                                    , RevisionID
                                    , GetAppdataFolder + '\JEDI\JVCS\COMPARE\2'
                                    , IsDFMFile
                                    );
  end;
  // Header
  if CreateRes then
  begin
    CommentFileName := AnsiLowerCase(ExtractFileName(ChangeFileExt(CompareFile1,
                         cbMembers.Text)));
    if IsLocalArchive then
      CommentStr1 := 'File: ' + CommentFileName +
        ' (' + GetCRCChkSum(CompareFile1) + ')'
    else
      CommentStr1 := CommentFileName +
        ' ' + GetVerStr(cbArch1) + ' (' + GetCRCChkSum(CompareFile1) + ')';
    CommentStr2 := CommentFileName +
      ' ' + GetVerStr(cbVer2) + ' (' + GetCRCChkSum(CompareFile2) + ')';
  end; // if CreateRes then begin

  if CreateRes then
  begin
    if (CompareToolParam <> '') and
      (Pos('%1', CompareToolParam) > 0) and
      (Pos('%2', CompareToolParam) > 0) then
    begin
      // keine langen Dateinamen als Parameter?
      if cbShortNames.Checked then
      begin
        SetLength(ShortModulName, MAX_PATH);
        SMSize := GetShortPathName(PChar(CompareFile1), PChar(ShortModulName),
          MAX_PATH);
        SetLength(ShortModulName, SMSize);
        CompareFile1 := ShortModulName;
        SetLength(ShortModulName, MAX_PATH);
        SMSize := GetShortPathName(PChar(CompareFile2), PChar(ShortModulName),
          MAX_PATH);
        SetLength(ShortModulName, SMSize);
        CompareFile2 := ShortModulName;
      end; // if cbShortNames.Checked then begin

      ParameterStr := SearchAndChange(CompareToolParam, '%1', '"' + CompareFile1 + '"');
      ParameterStr := SearchAndChange(ParameterStr, '%2', '"' + CompareFile2 + '"');
      ParameterStr := SearchAndChange(ParameterStr, '%3', '"' + CommentStr1 + '"');
      ParameterStr := SearchAndChange(ParameterStr, '%4', '"' + CommentStr2 + '"');


      ExecResult := ShellExecute(Application.Handle, 'open',
        PChar(CompareToolPath),
        PChar(ParameterStr),
        PChar(ExtractFileDir(CompareToolPath)),
        sw_ShowNormal);
      if ExecResult < 32 then
      begin
        BeepIfSet;
        MessageBox(WindowHandle, PChar(Format(JVCSRES_ShellExecute_Error_6037s62,
          [ExtractFileName(CompareToolPath)]) + #10#13 +
          DecodeShellErr(ExecResult)),
          cMsgBoxCaption, MB_OK or MB_ICONWARNING);
      end; // if ExecResult < 32 then begin
    end // if (ExtParam <> '') and...
    else 
    begin
      BeepIfSet;
      MessageBox(WindowHandle,
        PChar(JVCSRES_Invalid_parameter_string_for_external_compare_utility33),
        cMsgBoxCaption, MB_OK or MB_ICONWARNING);
    end;
  end 
  else
  begin
    MessageBox(WindowHandle, PChar(JVCSRES_JEDI_VCS_cannot_compare_the_selected_versions46),
      cMsgBoxCaption, MB_OK or MB_ICONSTOP);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSTextCompare.FormActivate(Sender: TObject);
var
  I: Integer;
  IDEFile: string;
begin
  Application.ProcessMessages;
  Screen.Cursor := crHourGlass;

  if SelectedRevisionID = 0 then
    GetProjectModules;

  Screen.Cursor := crHourGlass;

  {$IFDEF IDEDLL}
  IDEFile := IDEInterface.GetCurrentFile;
  ResolveFileFamilies(IDEFile);
  {$ENDIF IDEDLL}

  btnCompare.Enabled := False;
  btnClose.Enabled := False;

  if SelectedModule = '' then
    SelectedModule := IDEFile;
  SelectedModule := AnsiLowerCase(SelectedModule);

{//USc 09.11.2003 disabled (-> mantis #1204) because this let's any further stuff
 // fail when the localfile don't exist or is a binary file because without the
 // moduleid it's not possible to get the revisionlist... which is even necessary
 // for the archive to archive compare
 // (the compareprocedure will check that the localfile exists and that file isn't
 //  a binary file)
  if (not IsBinaryFile(SelectedModule)) or
    (jvcsReadBool(sBaseRegistryKey + crbOptions, 'IgnoreBinary_Text', False)) then
}
  begin
    if SelectedModuleID <= 0 then
      with DataModule1 do
      begin
        AppSrvClient1.Request.Rewrite;
        AppSrvClient1.FunctionCode := 'GET_MODULE_ID';
        AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
        AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
        AppSrvClient1.Request.WriteFields(True, [SelectedModule]);
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
          SelectedModuleID := -1;
        end;
        if not (AppSrvClient1.Answer.Fields[0] = '0') then
          SelectedModuleID := _StrToInt(AppSrvClient1.Answer.Fields[0])
      end; // with DataModule1 do begin
    if SelectedModuleID > 0 then
    begin
      if ecbxSource.Items.IndexOf(SelectedModule) = -1 then
      begin
        SourceIDs.Add(SelectedModule + '=' +
          IntToStr(SelectedModuleID));
        ecbxSource.Items.Add(SelectedModule);
      end;
    end;
  end; // if not IsBinaryFile(SelectedModule) then begin

  Screen.Cursor := crHourGlass;
  if ecbxSource.Items.Count > 0 then
  begin
    for I := 0 to ecbxSource.Items.Count - 1 do
    begin
      if Pos(SelectedModule, ecbxSource.Items[I]) > 0 then
      begin
        ecbxSource.ItemIndex := I;
      end;
    end;
    if ecbxSource.ItemIndex = -1 then
      ecbxSource.ItemIndex := 0;
  end; // if ecbxSource.Items.Count > 0 then begin

  FindVersions;
  if CompareMode = tcmArchiveToArchive then
    rbArchive_Archive.Checked := True;  
end;

//------------------------------------------------------------------------------

procedure TVCSTextCompare.FindVersions;
var
  RevisionString, RevisionID, CurrentRevisionID, ModuleID, ParentModule: string;
  I: Integer;
  RevisionItem: TTextCompRevisionItem;
begin
  try
    btnCompare.Enabled := False;
    cbArchVers.Items.Clear;
    cbArch1.Items.Clear;
    cbArch2.Items.Clear;
    RevisionIDs.Clear;

    ParentModule := ecbxSource.Text;
    ModuleID := SourceIDs.Values[ecbxSource.Text];

    with DataModule1 do
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_BLOB_STATUS';
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

      Screen.Cursor := crHourGlass;
      ParentModule := ExtractFileExt(ParentModule);
      AppSrvClient1.Answer.First;
      while not AppSrvClient1.Answer.Eof do
      begin
        RevisionItem := TTextCompRevisionItem.Create;      
        CurrentRevisionID := AppSrvClient1.Answer.Fields[0];
        while (not AppSrvClient1.Answer.Eof) and
          (CurrentRevisionID = AppSrvClient1.Answer.Fields[0]) do
        begin
          if ParentModule = TrimRight(AppSrvClient1.Answer.Fields[7]) then
          begin
            RevisionString := 'Ver: ' + AppSrvClient1.Answer.Fields[1] +
              '.' + AppSrvClient1.Answer.Fields[2] +
              ' - ' + DateTimeToStr(GMTStr2LocalDateTime(AppSrvClient1.Answer.Fields[3]));
            RevisionItem.Version := StrToIntDef(AppSrvClient1.Answer.Fields[1], -1);
            RevisionItem.Revision := StrToIntDef(AppSrvClient1.Answer.Fields[2], -1);
            RevisionItem.RevisionID := StrToIntDef(AppSrvClient1.Answer.Fields[0], -1);
          end;
          AppSrvClient1.Answer.Next;
        end;
        RevisionIDs.Add(RevisionItem);
        cbArchVers.Items.Add(RevisionString);
        cbArch1.Items.Add(RevisionString);
        cbArch2.Items.Add(RevisionString);
      end; // while not AppSrvClient1.Answer.EoF do begin
    end; // with DataModule1 do begin}

    if SelectedRevisionID > 0 then
    begin
      for I := 0 to cbArchVers.Items.Count - 1 do
      begin
        if SelectedRevisionID =
          TTextCompRevisionItem(RevisionIDs[I]).RevisionID then
        begin
          cbArchVers.ItemIndex := I;
          Break;
        end;
      end; // for I := 0 to cbArchVers.Items.Count - 1 do begin
    end;

    Caption := Format(JVCSRES_Visual_Compare_45_37s, [ExtractFileName(ecbxSource.Text)]);    
    lblVersions.Caption := IntToStr(cbArchVers.Items.Count);

    if cbArchVers.Items.Count > 0 then
    begin
      if cbArchVers.ItemIndex = -1 then
        cbArchVers.ItemIndex := cbArchVers.Items.Count - 1;
      cbArch1.ItemIndex := cbArch1.Items.Count - 1;
      if cbArch2.Items.Count > 0 then
        cbArch2.ItemIndex := 0;
      if cbArch2.Items.Count > 1 then
        cbArch2.ItemIndex := cbArch2.Items.Count - 2;
      RevisionID := IntToStr(TTextCompRevisionItem(RevisionIDs[cbArchVers.ItemIndex]).RevisionID);
      FindRevisionMembers(RevisionID);
    end;
  finally
    Screen.Cursor := crDefault;
    btnClose.Enabled := True;
    SetCompareButtonState;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSTextCompare.FindRevisionMembers(RevisionID: string);
var
  I: Integer;
  tmpModuleFileName: string;
begin
  cbMembers.Items.Clear;

  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_REVISION_STATUS';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [RevisionID]);
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
      cbMembers.Items.Add(TrimRight(AppSrvClient1.Answer.Fields[10]));
      AppSrvClient1.Answer.Next;
    end;
  end; // with DataModule1 do begin}
  lblMemberCount.Caption := IntToStr(cbMembers.Items.Count);

  Screen.Cursor := crHourGlass;
  cbMembers.ItemIndex := -1;
  if cbMembers.Items.Count > 1 then
  begin
    if (SelectedMember = '') or (not SameText(ecbxSource.Text, SelectedModule)) then
      tmpModuleFileName := ecbxSource.Text
    else
      tmpModuleFileName := SelectedMember;

    for I := 0 to cbMembers.Items.Count - 1 do
    begin
      if Pos(cbMembers.Items[I], tmpModuleFileName) > 0 then
      begin
        cbMembers.ItemIndex := I;
        Break;
      end;
    end;
    if cbMembers.ItemIndex = -1 then
      cbMembers.ItemIndex := 0;
  end // if cbMembers.Items.Count > 1 then begin
  else
  if cbMembers.Items.Count > 0 then 
    cbMembers.ItemIndex := 0;
  cbMembersChange(nil);
  Screen.Cursor := crDefault;
end;

//------------------------------------------------------------------------------

procedure TVCSTextCompare.spBtnInfoClick(Sender: TObject);
var 
  ModuleID, ModuleName: string;
  RevisionID: Integer;
  Idx: Integer;
begin
  ModuleName := '';
  ModuleID := SourceIDs.Values[ecbxSource.Text];
  if rbSource_Archive.Checked then
    Idx := cbArchVers.ItemIndex
  else
    Idx := cbArch2.ItemIndex;
  RevisionID := 0;
  if Idx <> -1 then
    RevisionID := TTextCompRevisionItem(RevisionIDs[Idx]).RevisionID;

  VCSInfo := TVCSInfo.Create(Application);
  try
    if ModuleName <> '' then 
    begin
      VCSInfo.ModuleName := ModuleName;
      VCSInfo.ModuleID := 0;
    end 
    else 
    begin
      VCSInfo.ModuleName := '';
      VCSInfo.ModuleID := StrToInt(ModuleID);
    end;
    VCSInfo.SelectedRevisionID := RevisionID;
    VCSInfo.ShowModal;
  finally
    VCSInfo.Free;
  end;
end;

//------------------------------------------------------------------------------

function TVCSTextCompare.CreateArchTempFile(var CompFile: string;
  const RevisionID: string;
  TargetDir: string;
  const DFM: Boolean): Boolean;
var 
  DFMFile, PasFile, ZipFile, ErrMsg: string;
  CreateRes: Integer;
  FS, FStream: TFileStream;
  OutStream: TMemoryStream;
  FldType: TMWFieldType;
  hFHandle: Integer;

  function AddVersionRevisionToFile(AFileName: string): string;
  var
    I: Integer;
    RevisionItem: TTextCompRevisionItem;
  begin
    Result := AFileName;
    for I := 0 to Pred(RevisionIDs.Count) do
    begin
      RevisionItem := TTextCompRevisionItem(RevisionIDs[I]);
      if RevisionItem.RevisionID = StrToIntDef(RevisionID, 0) then
      begin
        Result := ChangeFileExt(Result, Format('_%d_%d', [RevisionItem.Version,
          RevisionItem.Revision]) + ExtractFileExt(Result));
        Break;
      end;
    end;
  end;

begin
  {$IFDEF DEBUG}
  if DFM then
    JclDebug.TraceMsg('Compare: CreateArchTempFile DFM: true')
  else
    JclDebug.TraceMsg('Compare: CreateArchTempFile DFM: false');
  {$ENDIF DEBUG}
  Result := False;
  CompFile := '';
  TargetDir := SetBackSlash(TargetDir);
  if not DirectoryExists(TargetDir) then
  begin
    CreateRes := CreateTargetDir(TargetDir);
    if CreateRes <> 0 then 
    begin
      Exit;
    end; // if if CreateRes <> 0 then begin
  end; // if not DirectoryExists(TargetDir) then begin

  with DataModule1 do 
  begin
    if DFM then 
    begin
      // .dfm file compare
      // Temporäre Dateien
      DFMFile := ecbxSource.Text;
      DFMFile := ExtractFileName(ChangeFileExt(DFMFile, '.dfm'));
      DFMFile := TargetDir + DFMFile;
      if cbIncludeVRFileName.Checked then
        DFMFile := AddVersionRevisionToFile(DFMFile);
      ZipFile := ChangeFileExt(DFMFile, '.zip');
      if FileExists(DFMFile) then 
      begin
        if not DeleteFile(PChar(DFMFile)) then 
        begin
          BeepIfSet;
          MessageBox(WindowHandle, PChar(Format(JVCSRES_JEDI_VCS_cannot_delete_the_file + #13#10 +
            '<%s>.' + #13#10 +
            JVCSRES_Be_sure_that_the_file_is_not_opened_by_another_application + #13#10 +
            JVCSRES_and_that_you_have_the_required_access_rights46, [DFMFile])),
            cMsgBoxCaption, MB_OK or MB_ICONWARNING);
          Screen.Cursor := crDefault;
          Exit;
        end;
      end;
      if FileExists(ZipFile) then 
      begin
        if not DeleteFile(PChar(ZipFile)) then
        begin
          BeepIfSet;
          MessageBox(WindowHandle, PChar(Format(JVCSRES_JEDI_VCS_cannot_delete_the_file + #13#10 +
            '<%s>.' + #13#10 +
            JVCSRES_Be_sure_that_the_file_is_not_opened_by_another_application + #13#10 +
            JVCSRES_and_that_you_have_the_required_access_rights46, [ZipFile])),
            cMsgBoxCaption, MB_OK or MB_ICONWARNING);
          Screen.Cursor := crDefault;
          Exit;
        end;
      end;
      //--- Get BLOB (form) ----------------------------------------------------
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_SINGLE_BLOB';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [RevisionID]);
      AppSrvClient1.Request.WriteFields(False, ['.dfm']);
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
      //--- Save BLOB (form) to Zip file ---------------------------------------
      AppSrvClient1.Answer.First;
      if AppSrvClient1.Answer.Eof then 
      begin
        BeepIfSet;
        MessageBox(WindowHandle, PChar(JVCSRES_No_file_object_returned_by_server46),
          cMsgBoxCaption, MB_OK or MB_ICONSTOP);
        Exit;
      end;
      // prepare Zipfile
      if FileExists(ZipFile) then 
      begin
        FileSetAttr(ZipFile, FileGetAttr(ZipFile) and not $00000001);
        SysUtils.DeleteFile(ZipFile);
      end;
      // get blob
      try
        FS := TFileStream.Create(ZipFile, fmCreate or fmShareExclusive);
        try
          FS.Seek(0, 0);
          AppSrvClient1.Answer.GetStreamField(5, FS, FldType);
        finally
          FS.Free;
        end;
      except
        on E: 
        Exception do 
        begin
          BeepIfSet;
          MessageBox(WindowHandle,
            PChar(Format(JVCSRES_TFileStream_Error40form4158_37s, [E.Message])),
            cMsgBoxCaption, MB_OK or MB_ICONSTOP);
          Exit;
        end;
      end;
      //--- Extract Zip file ---------------------------------------------------
      if ExtractZip2Source(Self, DFMFile, ZipFile,
        ErrMsg) <> 0 then
      begin
        BeepIfSet;
        MessageBox(WindowHandle,
          PChar(Format(JVCSRES_Error_extract40form4158_37s, [ErrMsg])),
          cMsgBoxCaption, MB_OK or MB_ICONSTOP);
        Exit;
      end; // if ExtractZip2Source(Self, Module, ZipFile,...
      if FileExists(ZipFile) then
        SysUtils.DeleteFile(ZipFile);
      //--- Originaldatum setzen -----------------------------------------------
      try
        hFHandle := FileOpen(DFMFile, fmOpenWrite or fmShareDenyNone);
        if hFHandle <> -1 then 
        begin
          FileSetDate(hFHandle,
            DateTimeToFileDate(GMTStr2LocalDateTime(AppSrvClient1.Answer.Fields[0])));
          FileClose(hFHandle);
        end;
      except
        on E:
        Exception do 
        begin
          BeepIfSet;
          MessageBox(WindowHandle,
            PChar(Format(JVCSRES_FileSetDate_Error40form4158_37s, [E.Message])),
            cMsgBoxCaption, MB_OK or MB_ICONSTOP);
          Exit;
        end;
      end; // try except
      // .dfm datei aus archive in text umwandelen
      try
        FStream := TFileStream.Create(DFMFile, fmOpenRead or fmShareDenyNone);
        OutStream := TMemoryStream.Create;
        try
          if IsBinaryDFMStream(FStream) then
            ObjectResourceToText(FStream, OutStream)
          else
            OutStream.CopyFrom(FStream, 0);
          OutStream.Position := 0;
          OutStream.SaveToFile(ChangeFileExt(DFMFile, '.txt'));
        finally
          OutStream.Free;
          FStream.Free;
        end;
      except
        BeepIfSet;
        MessageBox(WindowHandle, PChar(Format(JVCSRES_JEDI_VCS_cannot_convert_the_form_4046dfm41_file58 + #13#10 +
          '<%s>.', [DFMFile])),
          cMsgBoxCaption, MB_OK or MB_ICONSTOP);
        Screen.Cursor := crDefault;
        Exit;
      end;
      CompFile := ChangeFileExt(DFMFile, '.txt');
    end // if DFM then begin
    else
    begin
      // .pas/.txt... file compare
      // Temporäre Dateien
      PasFile := ecbxSource.Text;
      PasFile := ExtractFileName(ChangeFileExt(PasFile, cbMembers.Text));
      PasFile := TargetDir + PasFile;
      if cbIncludeVRFileName.Checked then
        PasFile := AddVersionRevisionToFile(PasFile);
      ZipFile := ChangeFileExt(PasFile, '.zip');
      if FileExists(PasFile) then 
      begin
        if not DeleteFile(PChar(PasFile)) then 
        begin
          BeepIfSet;
          MessageBox(WindowHandle, PChar(Format(JVCSRES_JEDI_VCS_cannot_delete_the_file + #13#10 +
            '<%s>.' + #13#10 +
            JVCSRES_Be_sure_that_the_file_is_not_opened_by_another_application + #13#10 +
            JVCSRES_and_that_you_have_the_required_access_rights46, [PasFile])),
            cMsgBoxCaption, MB_OK or MB_ICONWARNING);
          Screen.Cursor := crDefault;
          Exit;
        end;
      end;
      if FileExists(ZipFile) then
      begin
        if not DeleteFile(PChar(ZipFile)) then 
        begin
          BeepIfSet;
          MessageBox(WindowHandle, PChar(Format(JVCSRES_JEDI_VCS_cannot_delete_the_file + #13#10 +
            '<%s>.' + #13#10 +
            JVCSRES_Be_sure_that_the_file_is_not_opened_by_another_application + #13#10 +
            JVCSRES_and_that_you_have_the_required_access_rights46, [ZipFile])),
            cMsgBoxCaption, MB_OK or MB_ICONWARNING);
          Screen.Cursor := crDefault;
          Exit;
        end;
      end;
      //--- Get BLOB (module) --------------------------------------------------
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_SINGLE_BLOB';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [RevisionID]);
      AppSrvClient1.Request.WriteFields(False, [ExtractFileExt(PasFile)]);
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
      //--- Save BLOB (module) to Zip file -------------------------------------
      AppSrvClient1.Answer.First;
      if AppSrvClient1.Answer.Eof then
      begin
        BeepIfSet;
        MessageBox(WindowHandle, PChar(JVCSRES_No_Blob_returned_by_server46),
          cMsgBoxCaption, MB_OK or MB_ICONSTOP);
        Exit;
      end;
      // prepare Zipfile
      if FileExists(ZipFile) then 
      begin
        FileSetAttr(ZipFile, FileGetAttr(ZipFile) and not $00000001);
        SysUtils.DeleteFile(ZipFile);
      end;
      // get blob
      try
        FS := TFileStream.Create(ZipFile, fmCreate or fmShareExclusive);
        try
          FS.Seek(0, 0);
          AppSrvClient1.Answer.GetStreamField(5, FS, FldType);
        finally
          FS.Free;
        end;
      except
        on E: 
        Exception do 
        begin
          BeepIfSet;
          MessageBox(WindowHandle,
            PChar(Format(JVCSRES_TFileStream_Error40module4158_37s, [E.Message])),
            cMsgBoxCaption, MB_OK or MB_ICONSTOP);
          Exit;
        end;
      end;
      //--- Extract Zip file ---------------------------------------------------
      if ExtractZip2Source(Self, PasFile, ZipFile,
        ErrMsg) <> 0 then
      begin
        BeepIfSet;
        MessageBox(WindowHandle,
          PChar(Format(JVCSRES_Error_extract40module4158_37s, [ErrMsg])),
          cMsgBoxCaption, MB_OK or MB_ICONSTOP);
        Exit;
      end; // if ExtractZip2Source(Self, Module, ZipFile,...
      if FileExists(ZipFile) then 
        SysUtils.DeleteFile(ZipFile);
      //--- Originaldatum setzen -----------------------------------------------
      try
        hFHandle := FileOpen(PasFile, fmOpenWrite or fmShareDenyNone);
        if hFHandle <> -1 then 
        begin
          FileSetDate(hFHandle,
            DateTimeToFileDate(GMTStr2LocalDateTime(AppSrvClient1.Answer.Fields[0])));
          FileClose(hFHandle);
        end;
      except
        on E:
        Exception do
        begin
          BeepIfSet;
          MessageBox(WindowHandle,
            PChar(Format(JVCSRES_FileSetDate_Error40module4158_37s, [E.Message])),
            cMsgBoxCaption, MB_OK or MB_ICONSTOP);
          Exit;
        end;
      end; // try except
      CompFile := PasFile;
    end; // else if DFM then begin
  end; // with DataModule1 do begin}
  Result := True;
end;

//------------------------------------------------------------------------------

function TVCSTextCompare.CreateTempFile(var CompFile: string; SourceFile,
  TargetDir: string): Boolean;
var
  CreateRes: Integer;
  FStream: TFileStream;
  OutStream: TMemoryStream;
begin
  Result := False;
  CompFile := '';
  TargetDir := SetBackSlash(TargetDir);
  if not DirectoryExists(TargetDir) then
  begin
    CreateRes := CreateTargetDir(TargetDir);
    if CreateRes <> 0 then 
    begin
      Exit;
    end; // if if CreateRes <> 0 then begin
  end; // if not DirectoryExists(TargetDir) then begin

  CompFile := TargetDir + ChangeFileExt(ExtractFileName(SourceFile), '.txt');
  // .dfm datei in text umwandelen
  try
    FStream := TFileStream.Create(SourceFile, fmOpenRead or fmShareDenyNone);
    OutStream := TMemoryStream.Create;
    try
      if IsBinaryDFMStream(FStream) then
        ObjectResourceToText(FStream, OutStream)
      else
        OutStream.CopyFrom(FStream, 0);
      OutStream.Position := 0;
      OutStream.SaveToFile(CompFile);
    finally
      OutStream.Free;
      FStream.Free;
    end;
  except
    BeepIfSet;
    MessageBox(WindowHandle, PChar(Format(JVCSRES_JEDI_VCS_cannot_convert_the_form_4046dfm41_file58 + #13#10 +
      '<%s>.', [SourceFile])),
      cMsgBoxCaption, MB_OK or MB_ICONSTOP);
    Screen.Cursor := crDefault;
    Exit;
  end;
  Result := True;
end;

//------------------------------------------------------------------------------

procedure TVCSTextCompare.ecbxSourceChange(Sender: TObject);
begin
  FindVersions;
  SetCompareButtonState;
end;

//------------------------------------------------------------------------------

procedure TVCSTextCompare.cbArchVersChange(Sender: TObject);
begin
  SetCompareButtonState;
end;

//------------------------------------------------------------------------------

procedure TVCSTextCompare.btnCloseClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSTextCompare.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  jvcsWriteInteger(sBaseRegistryKey + crbOptions, 'DefaultCompare',
    cbxTool.ItemIndex);
  jvcsWriteBool(sBaseRegistryKey + crbOptions, 'CompareShortNames',
    cbShortNames.Checked);
  jvcsWriteBool(sBaseRegistryKey + crbOptions, 'CompareIncludeVRFileName',
    cbIncludeVRFileName.Checked);

  jvcsWriteWindowPosAndSize(sBaseRegistryKey + crbWindows, 'Compare',
    Top, Left, Width, Height);

  // Aktuelles Verzeichnis wiederherstellen
  ChDir(ActDir);
end;

//------------------------------------------------------------------------------

procedure TVCSTextCompare.HelpTopic1Click(Sender: TObject);
begin
  PerformHelpCommand(Application, IDH_Compare_Modules);
end;

//------------------------------------------------------------------------------

procedure TVCSTextCompare.rbSource_ArchiveClick(Sender: TObject);
begin
  SetCompareButtonState;

  ecbxSource.Visible := rbSource_Archive.Checked;
  cbArchVers.Visible := rbSource_Archive.Checked;

  cbArch1.Visible := not rbSource_Archive.Checked;
  cbArch2.Visible := not rbSource_Archive.Checked;

  if rbSource_Archive.Checked then
  begin
    Label2.Caption := JVCSRES_38Local;
    Label2.FocusControl := ecbxSource;
    Label1.Caption := JVCSRES_38Archive;
    Label1.FocusControl := cbArchVers;
    cbArchVers.ItemIndex := cbArch1.ItemIndex;
  end // if rbSource_Archive.Checked then begin
  else
  begin
    Label2.Caption := JVCSRES_Archive_381;
    Label2.FocusControl := cbArch1;
    Label1.Caption := JVCSRES_Archive_382;
    Label1.FocusControl := cbArch2;
    cbArch1.ItemIndex := cbArchVers.ItemIndex;
    if cbArch1.ItemIndex - 1 >= 0 then
      cbArch2.ItemIndex := cbArch1.ItemIndex - 1
    else
      cbArch2.ItemIndex := cbArch1.ItemIndex;
  end;
  spBtnPrevRev.Visible := rbArchive_Archive.Checked;
  spBtnPrevRev.Enabled := cbArch1.Items.Count > 2;
  spBtnNextRev.Visible := spBtnPrevRev.Visible;
  spBtnNextRev.Enabled := spBtnPrevRev.Enabled;
end;

//------------------------------------------------------------------------------

procedure TVCSTextCompare.cbMembersChange(Sender: TObject);
var
  Idx: Integer;
begin
  SetCompareButtonState;
  if cbMembers.Text <> '' then
  begin
    Idx := FCompareTools.GetExtensionIndex(cbMembers.Text);
    if (Idx >= 0) and (Idx < FCompareTools.Count) then
      cbxTool.ItemIndex := Idx;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSTextCompare.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSTextCompare.FormDestroy(Sender: TObject);
begin
  FCompareTools.Free;
  SourceIDs.Free;
  RevisionIDs.Free;
end;

//------------------------------------------------------------------------------

procedure TVCSTextCompare.GetCompareTools;
var
  I, ToolIndex: Integer;
begin
  with cbxTool do
  begin
    Items.Clear;
    for I := 0 to Pred(FCompareTools.Count) do
      Items.Add(FCompareTools[I].Name)
  end;
  ToolIndex :=
    jvcsReadInteger(sBaseRegistryKey + crbOptions, 'DefaultCompare', 0);
  if ToolIndex > cbxTool.Items.Count - 1 then
    cbxTool.ItemIndex := 0
  else
    cbxTool.ItemIndex := ToolIndex;
end;

//------------------------------------------------------------------------------

procedure TVCSTextCompare.spbtnToolsClick(Sender: TObject);
begin
  jvcsWriteInteger(sBaseRegistryKey + crbOptions, 'DefaultCompare',
    cbxTool.ItemIndex);
  VCSOptions := TVCSOptions.Create(Application);
  try
    VCSOptions.DefaultSheet := cspExtCompare;
    VCSOptions.ShowModal;
  finally
    VCSOptions.Free;
  end;
  FCompareTools.ReadCompareTools;
  GetCompareTools;
  cbMembersChange(nil);
end;

//------------------------------------------------------------------------------

procedure TVCSTextCompare.SetCompareButtonState;
begin
  btnCompare.Enabled := cbArchVers.Items.Count > 0;
end;

procedure TVCSTextCompare.spBtnNextRevClick(Sender: TObject);
var
  AddValue, NewIdx1, NewIdx2: Integer;
begin
  if cbArch1.Items.Count > 2 then
  begin
    if Sender = spBtnNextRev then
      AddValue := 1
    else
      AddValue := -1;
    NewIdx1 := cbArch1.ItemIndex + AddValue;
    if NewIdx1 >= cbArch1.Items.Count then
      NewIdx1 := Pred(cbArch1.Items.Count)
    else
    if NewIdx1 < 1 then
      NewIdx1 := 1;
    NewIdx2 := NewIdx1 - 1;
    cbArch1.ItemIndex := NewIdx1;
    cbArch2.ItemIndex := NewIdx2;
  end;
end;

end.
