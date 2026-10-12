(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: ProjectDependencies.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS: Thomas Huber (Thomas_D_Huber@t-online.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
ToDo
- the Standalone version still needs some work (mainly search paths)
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FreeVCS code to JEDI VCS
2003/03/09  THensle   - changes for "ConfigStorage" unit
2003/04/08  USchuster - changes for IDEInterface
2003/12/28  USchuster - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use constant)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/31  USchuster - style cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/11/03  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
2007/07/01  USchuster - changes for large fonts (contraints and default size depend now on PixelsPerInch; analog to Mantis #3710)
2008/06/22  USchuster - first changes for usage in Standalone client (Mantis #4380)
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit ProjDependencies;

{$I jedi.inc}
{$I compopt.inc}

{$IFDEF DEBUG}
  {.$DEFINE PDDEBUG}
{$ENDIF DEBUG}

interface

uses
  {$IFDEF DEBUG}
  JclDebug,
  {$ENDIF DEBUG}
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ImgList, ComCtrls, EnhListView, Buttons, StdCtrls, ExtCtrls, Menus;

type
  TVCSProjectDependencies = class(TForm)
    StateImageList: TImageList;
    Panel1: TPanel;
    btnClose: TButton;
    btnParse: TButton;
    Help: TSpeedButton;
    elvExternals: TdfsEnhListView;
    btnReport: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnParseClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure HelpTopics1Click(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure btnReportClick(Sender: TObject);
  private
    { Private declarations }
    FCreating: Boolean;
    UsedModules,
    ProjectUnits: TStringList;
    procedure GetProjectUnits;
    procedure ParseUnit(const FileName: string);
    function GetListViewString: string;
  public
    { Public declarations }
    procedure RestrictSize(var Msg: TMessage); message WM_GETMINMAXINFO;
  end;

var
  VCSProjectDependencies: TVCSProjectDependencies;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  mwPasLex, mwPasLexTypes,
  {$IFDEF IDEDLL}
  JVCSIDEInterface,
  {$ENDIF IDEDLL}  
  VCSBase, Progress, VCSProcBase,
  HandleBlob, DBModule, SimpleReport, ConfigStorage, JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSProjectDependencies.FormCreate(Sender: TObject);
var
  DlgTop, DlgLeft, DlgWidth, DlgHeight: Integer;
begin
  try
    VCSProgress := nil;

    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    if jvcsReadWindowPosAndSize(sBaseRegistryKey + crbWindows, 'ProjectDependencies',
      DlgTop, DlgLeft, DlgHeight, DlgWidth) then
    begin
      Top := DlgTop;
      Left := DlgLeft;
      Height := DlgHeight;
      Width := DlgWidth;
    end else
    begin
      Top := (Screen.Height - Height) div 2;
      Left := (Screen.Width - Width) div 2;
      Height := MulDiv(260, PixelsPerInch, 96);
      Width := MulDiv(505, PixelsPerInch, 96);
    end;

    with elvExternals do
    begin
      Columns[0].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjectDependencies_Col1.0', 250);
      Columns[1].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ProjectDependencies_Col1.1', 250);
    end;

    {$IFDEF CUSTOMDRIVE}
    sDriveSubst := RegReadString(HKCU, sBaseRegistryKey + crbProjects +
      ExtractFileName(sProjectName), 'LocalDrive', '');
    if (sDriveSubst = '') then
      sDriveSubst := RegReadString(HKCU, sBaseRegistryKey + crbOptions,
        'LocalDrive', '');
    {$ENDIF CUSTOMDRIVE}

    ProjectUnits := TStringList.Create;
    ProjectUnits.Sorted := True;
    ProjectUnits.Duplicates := dupIgnore;
    UsedModules := TStringList.Create;
    UsedModules.Sorted := True;
    UsedModules.Duplicates := dupIgnore;
    FCreating := True;

    Caption := Format(JVCSRES_External_modules_45_37s, [AnsiLowerCase(ExtractFileName(sProjectName))]);
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectDependencies.FormActivate(Sender: TObject);
begin
  if Assigned(VCSProgress) then
    SetForeGroundWindow(VCSProgress.Handle);
  Application.ProcessMessages;
  if FCreating then 
  begin
    Screen.Cursor := crHourGlass;
    FCreating := False;
    GetProjectUnits;
    Screen.Cursor := crDefault;
  end; // if FCreating then begin
end;

//------------------------------------------------------------------------------

procedure TVCSProjectDependencies.GetProjectUnits;
var 
  I: Integer;
  {$IFDEF IDEDLL}
  CurrentFile: string;
  {$ENDIF IDEDLL}  
  UserModules: TStringList;
begin
  UserModules := TStringList.Create;
  try
    ProjectUnits.Clear;

    {$IFDEF IDEDLL}
    for I := 0 to IDEInterface.GetUnitCount - 1 do
    begin
      CurrentFile := IDEInterface.GetUnitName(I);
      if (CurrentFile <> '') and
        (AnsiLowerCase(ExtractFileExt(CurrentFile)) = ('.' + sIDEUnit)) then
        ProjectUnits.Add(AnsiLowerCase(CurrentFile));
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
      if AnsiLowerCase(ExtractFileExt(UserModules.Strings[I])) = ('.' + sIDEUnit) then
        ProjectUnits.Add(AnsiLowerCase(UserModules.Strings[I]));
  finally
    UserModules.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectDependencies.btnParseClick(Sender: TObject);
var 
  I: Integer;
  CurrItem, CurrType: string;
  NewItem: TListItem;
begin
  elvExternals.Items.Clear;
  UsedModules.Clear;
  VCSProgress := TVCSProgress.Create(Self);
  VCSProgress.SetText(JVCSRES_Parsing_the_source_files464646);
  VCSProgress.SetPBMax( {$IFDEF IDEDLL}IDEInterface.GetUnitCount + {$ENDIF}ProjectUnits.Count);
  VCSProgress.SetPBPos(0);
  VCSProgress.Left := Left + 40;
  VCSProgress.Top := Top + 60;
  VCSProgress.Show;
  Application.ProcessMessages;

  for I := 0 to ProjectUnits.Count - 1 do 
  begin
    if FileExists(ProjectUnits.Strings[I]) then 
    begin
      {$IFDEF PDDEBUG}
      DebugString('UU Parse Unit: ' + ProjectUnits.Strings[I]);
      {$ENDIF PDDEBUG}
      if IsIDEUnit(ProjectUnits.Strings[I]) or
        IsIDEProject(ProjectUnits.Strings[I], sProjectName) or
        (ExtractFileExt(AnsiLowerCase(ProjectUnits.Strings[I])) = '.inc') then
        ParseUnit(ProjectUnits.Strings[I]);
    end;
    VCSProgress.SetPBPos(I);
  end;
  {$IFDEF IDEDLL}
  for I := 0 to IDEInterface.GetUnitCount - 1 do
  begin
    if FileExists(IDEInterface.GetUnitName(I)) then
    begin
      {$IFDEF PDDEBUG}
      DebugString('UU Parse Unit: ' + IDEInterface.GetUnitName(I));
      {$ENDIF PDDEBUG}
      if IsIDEUnit(IDEInterface.GetUnitName(I)) or
        IsIDEProject(IDEInterface.GetUnitName(I), sProjectName) then
        ParseUnit(IDEInterface.GetUnitName(I));
    end;
    VCSProgress.SetPBPos(ProjectUnits.Count + I - 1);
  end;
  {$ENDIF IDEDLL}
  VCSProgress.SetPBPos(0);
  VCSProgress.SetText(JVCSRES_Building_Listview464646);
  Application.ProcessMessages;
  for I := 0 to UsedModules.Count - 1 do 
  begin
    CurrItem := UsedModules.Strings[I];
    CurrType := Copy(CurrItem, 1, Pos('|', CurrItem) - 1);
    Delete(CurrItem, 1, Pos('|', CurrItem));

    NewItem := elvExternals.Items.Add;
    NewItem.Caption := CurrType;
    NewItem.SubItems.Add(CurrItem);
    NewItem.StateIndex := -1;
    if Pos('loadlibrary', AnsiLowerCase(CurrType)) <> 0 then //do not localize
      NewItem.StateIndex := 0;
    if Pos('getprocaddress', AnsiLowerCase(CurrType)) <> 0 then //do not localize
      NewItem.StateIndex := 1;
    if Pos('exports ', AnsiLowerCase(CurrType)) <> 0 then //do not localize
      NewItem.StateIndex := 2;
    if Pos('external ', AnsiLowerCase(CurrType)) <> 0 then //do not localize
      NewItem.StateIndex := 3;
    if Pos('createoleobject', AnsiLowerCase(CurrType)) <> 0 then //do not localize 
      NewItem.StateIndex := 4;

    VCSProgress.SetPBPos(I);
  end; // for I := 0 to UsedModules.Count - 1 do begin
  elvExternals.Resort;
  VCSProgress.Free;
  VCSProgress := nil;  
  Caption := Format(JVCSRES_External_modules_45_37s_45_37d_items,
    [AnsiLowerCase(ExtractFileName(sProjectName)), elvExternals.Items.Count]);
end;

//------------------------------------------------------------------------------

procedure TVCSProjectDependencies.ParseUnit(const FileName: string);
var 
  MS: TMemoryStream;
  {$IFNDEF IDEDLL}
  FS: TFileStream;
  {$ENDIF ~IDEDLL}  
  PasParser: TmwPasLex;
  CurrToken: string;
begin
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
      //hu01.12.2002       while PasParser.TokenID <> tkNull do
      while PasParser.TokenID <> ptNull do
      begin
        //hu01.12.2002         if PasParser.TokenID = tkIdentifier then
        if PasParser.TokenID = ptIdentifier then
        begin
          CurrToken := AnsiLowerCase(PasParser.Token);
          if Pos('loadlibrary', CurrToken) <> 0 then //do not localize
          begin
            CurrToken := '';
            //hu01.12.2002             while PasParser.TokenID <> tkSemicolon do
            while PasParser.TokenID <> ptSemicolon do
            begin
              CurrToken := CurrToken + PasParser.Token;
              PasParser.NextNoJunk;
            end;
            {$IFDEF PDDEBUG}
            DebugString('DP Parse 2: ' + CurrToken);
            {$ENDIF PDDEBUG}
            UsedModules.Add(CurrToken + '|' + AnsiLowerCase(FileName));
          end; // if Pos('loadlibrary', CurrToken) <> 0 then
          if Pos('getprocaddress', CurrToken) <> 0 then //do not localize
          begin
            CurrToken := '';
            //hu01.12.2002             while PasParser.TokenID <> tkSemicolon do
            while PasParser.TokenID <> ptSemicolon do
            begin
              CurrToken := CurrToken + PasParser.Token;
              PasParser.NextNoJunk;
            end;
            {$IFDEF PDDEBUG}
            DebugString('DP Parse 21: ' + CurrToken);
            {$ENDIF PDDEBUG}
            UsedModules.Add(CurrToken + '|' + AnsiLowerCase(FileName));
          end; // if Pos('loadlibrary', CurrToken) <> 0 then
          if Pos('createoleobject', CurrToken) <> 0 then //do not localize
          begin
            CurrToken := '';
            //hu01.12.2002             while PasParser.TokenID <> tkSemicolon do
            while PasParser.TokenID <> ptSemicolon do
            begin
              CurrToken := CurrToken + PasParser.Token;
              PasParser.NextNoJunk;
            end;
            {$IFDEF PDDEBUG}
            DebugString('DP Parse 22: ' + CurrToken);
            {$ENDIF PDDEBUG}
            UsedModules.Add(CurrToken + '|' + AnsiLowerCase(FileName));
          end; // if Pos('createoleobject', CurrToken) <> 0 then
        end; // if PasParser.TokenID = tkIdentifier
        //hu01.12.2002         if PasParser.TokenID = tkExport then
        if PasParser.TokenID = ptExport then 
        begin
          {$IFDEF PDDEBUG}
          DebugString('DP Parse 2: ' + PasParser.Token);
          {$ENDIF PDDEBUG}
          //            UsedModules.Add(AnsiLowerCase(ParseToken));
        end;
        //hu01.12.2002         if PasParser.TokenID = tkExports then
        if PasParser.TokenID = ptExports then 
        begin
          CurrToken := '';
          //hu01.12.2002           while PasParser.TokenID <> tkSemicolon do
          while PasParser.TokenID <> ptSemicolon do
          begin
            CurrToken := CurrToken + PasParser.Token + ' ';
            PasParser.NextNoJunk;
          end;
          {$IFDEF PDDEBUG}
          DebugString('DP Parse 3: ' + CurrToken);
          {$ENDIF PDDEBUG}
          UsedModules.Add(CurrToken + '|' + AnsiLowerCase(FileName));
        end; // if PasParser.TokenID = tkExports
        //hu01.12.2002         if PasParser.TokenID = tkExternal then
        if PasParser.TokenID = ptExternal then 
        begin
          CurrToken := '';
          //hu01.12.2002           while PasParser.TokenID <> tkSemicolon do
          while PasParser.TokenID <> ptSemicolon do
          begin
            CurrToken := CurrToken + PasParser.Token + ' ';
            PasParser.NextNoJunk;
          end;
          {$IFDEF PDDEBUG}
          DebugString('DP Parse 4: ' + CurrToken);
          {$ENDIF PDDEBUG}
          UsedModules.Add(CurrToken + '|' + AnsiLowerCase(FileName));
        end; // if PasParser.TokenID = tkExternal
        PasParser.NextNoJunk;
      end; // while PasParser.TokenID <> tkNull do
    finally
      PasParser.Free;
    end;
  finally
    MS.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectDependencies.btnCloseClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectDependencies.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  jvcsWriteWindowPosAndSize(sBaseRegistryKey + crbWindows, 'ProjectDependencies',
    Top, Left, Height, Width);

  with elvExternals do
  begin
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjectDependencies_Col1.0',
      Columns[0].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ProjectDependencies_Col1.1',
      Columns[1].Width);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectDependencies.FormDestroy(Sender: TObject);
begin
  UsedModules.Free;
  ProjectUnits.Free;
end;

//------------------------------------------------------------------------------

function TVCSProjectDependencies.GetListViewString: string;
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
    with elvExternals do
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

procedure TVCSProjectDependencies.btnReportClick(Sender: TObject);
var 
  ResultString: string;
begin
  ResultString := GetListViewString;
  if ResultString = '' then
    Exit;

  VCSSimpleReport := TVCSSimpleReport.Create(Application);
  try
    VCSSimpleReport.RepID := 9;  
    VCSSimpleReport.Left := Left + 60;
    VCSSimpleReport.Top := Top + 60;
    VCSSimpleReport.FullReportString := ResultString;
    VCSSimpleReport.SavePath := ExtractFileDir(sProjectName);
    VCSSimpleReport.SaveFileName := 'Externals.txt';
    VCSSimpleReport.LineCount := elvExternals.Items.Count + 8;
    VCSSimpleReport.ShowModal;
  finally
    VCSSimpleReport.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectDependencies.RestrictSize(var Msg: TMessage);
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
  P.ptMinTrackSize.x := MulDiv(505, PixelsPerInch, 96);
  P.ptMinTrackSize.y := MulDiv(260, PixelsPerInch, 96);
end;

//------------------------------------------------------------------------------

procedure TVCSProjectDependencies.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    btnClose.Click;
    Key := 0;
  end;
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Externals_Librarys);
  if Key = VK_F2 then 
    btnParse.Click;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectDependencies.HelpTopics1Click(Sender: TObject);
begin
  PerformHelpCommand(Application, IDH_Externals_Librarys);
end;

//------------------------------------------------------------------------------

procedure TVCSProjectDependencies.HelpClick(Sender: TObject);
var
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

end.
