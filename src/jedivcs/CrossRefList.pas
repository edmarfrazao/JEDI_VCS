(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: CrossRefList.pas

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
2003/03/04  THensle   - changes for "ConfigStorage" unit
2003/03/08  USchuster - exchanged THistoryList with TJVCSMruList (mantis #727)
2003/09/13  THuber    - form now sizable
2003/12/28  USchuster - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use constant)
2004/04/17  USchuster - restricted minimum size in form
                      - minor style cleaning (casing and comments)
                      - moved some strings to JVCSGUIClientResources.pas
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/31  USchuster - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/11/05  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
2007/06/17  USchuster - fixed self handled shortcuts
2007/06/29  USchuster - changes for large fonts (set AutoScroll to False and changed contraints; Mantis #1034)
2008/12/22  THuber    - Baseclass changed to TJVCSForm

-----------------------------------------------------------------------------*)

unit CrossRefList;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, Dialogs, ExtCtrls, JVCSForms;

type
  TVCSSelCrossRef = class(TJVCSForm)
    Panel1: TPanel;
    Help: TSpeedButton;
    btnPGroup: TButton;
    OKBtn: TButton;
    CancelBtn: TButton;
    gbAvailableProjects: TGroupBox;
    SrcList: TListBox;
    gbRefProjects: TGroupBox;
    DstList: TListBox;
    pnlLeftRight: TPanel;
    IncludeBtn: TSpeedButton;
    IncAllBtn: TSpeedButton;
    ExcludeBtn: TSpeedButton;
    ExAllBtn: TSpeedButton;
    procedure IncludeBtnClick(Sender: TObject);
    procedure ExcludeBtnClick(Sender: TObject);
    procedure IncAllBtnClick(Sender: TObject);
    procedure ExcAllBtnClick(Sender: TObject);
    procedure MoveSelected(List: TCustomListBox; Items: TStrings);
    procedure SetItem(List: TListBox; Index: Integer);
    function GetFirstSelection(List: TCustomListBox): Integer;
    procedure SetButtons;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure SrcListClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnPGroupClick(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FCreating: Boolean;
    ProjectIDs: TStringList;
  public
    { Public declarations }
  end;

var
  VCSSelCrossRef: TVCSSelCrossRef;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSBase, VCSProcBase, FavOpenDialog, DBModule, ParsePG, ConfigStorage,
  JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSSelCrossRef.FormCreate(Sender: TObject);
begin
  try
    Constraints.MinHeight := MulDiv(210, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(370, PixelsPerInch, 96);
    FCreating := True;
    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);
    Caption := Caption + ' - ' + AnsiLowerCase(ExtractFileName(sProjectName));
    ProjectIDs := TStringList.Create;
    ProjectIDs.Sorted := True;
    ProjectIDs.Duplicates := dupIgnore;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSSelCrossRef.FormActivate(Sender: TObject);
var
  CurrentProject: string;
begin
  Application.ProcessMessages;
  if not FCreating then
    Exit;
  FCreating := False;

  // bereits verbundene Projekte
  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_PROJECT_REFERENCES';
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

    ProjectIDs.Clear;
    AppSrvClient1.Answer.First;
    while not AppSrvClient1.Answer.Eof do 
    begin
      ProjectIDs.Add(AppSrvClient1.Answer.Fields[1] + '=' +
        AppSrvClient1.Answer.Fields[0]);
      DstList.Items.Add(AppSrvClient1.Answer.Fields[1]);
      AppSrvClient1.Answer.Next;
    end;
  end; // with DataModule1 do begin}

  // vorhandene Projekte
  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_PROJECT_LIST';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(False, ['']);
    AppSrvClient1.Request.WriteFields(True, [False]); // incl. details
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
      if AppSrvClient1.Answer.Fields[2] <> '1' then
      begin
        ProjectIDs.Add(AppSrvClient1.Answer.Fields[1] + '=' +
          AppSrvClient1.Answer.Fields[0]);
        CurrentProject := AppSrvClient1.Answer.Fields[1];
        if (DstList.Items.IndexOf(CurrentProject) = -1) and
          (AppSrvClient1.Answer.Fields[0] <> IntToStr(ServerProjectID)) then
          SrcList.Items.Add(CurrentProject);
      end; // if AppSrvClient1.Answer.Fields[2] <> '1' then begin
      AppSrvClient1.Answer.Next;
    end;
  end; // with DataModule1 do begin}

  SetButtons;
end;

//------------------------------------------------------------------------------

procedure TVCSSelCrossRef.IncludeBtnClick(Sender: TObject);
var
  Index: Integer;
begin
  Index := GetFirstSelection(SrcList);
  MoveSelected(SrcList, DstList.Items);
  SetItem(SrcList, Index);
end;

//------------------------------------------------------------------------------

procedure TVCSSelCrossRef.ExcludeBtnClick(Sender: TObject);
var
  Index: Integer;
begin
  Index := GetFirstSelection(DstList);
  MoveSelected(DstList, SrcList.Items);
  SetItem(DstList, Index);
end;

//------------------------------------------------------------------------------

procedure TVCSSelCrossRef.IncAllBtnClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to SrcList.Items.Count - 1 do
    DstList.Items.AddObject(SrcList.Items[I],
      SrcList.Items.Objects[I]);
  SrcList.Items.Clear;
  SetItem(SrcList, 0);
end;

//------------------------------------------------------------------------------

procedure TVCSSelCrossRef.ExcAllBtnClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to DstList.Items.Count - 1 do
    SrcList.Items.AddObject(DstList.Items[I], DstList.Items.Objects[I]);
  DstList.Items.Clear;
  SetItem(DstList, 0);
end;

//------------------------------------------------------------------------------

procedure TVCSSelCrossRef.MoveSelected(List: TCustomListBox; Items: TStrings);
var
  I: Integer;
begin
  for I := List.Items.Count - 1 downto 0 do
    if List.Selected[I] then
    begin
      Items.AddObject(List.Items[I], List.Items.Objects[I]);
      List.Items.Delete(I);
    end;
end;

//------------------------------------------------------------------------------

procedure TVCSSelCrossRef.SetButtons;
var
  SrcEmpty, DstEmpty: Boolean;
begin
  SrcEmpty := SrcList.Items.Count = 0;
  DstEmpty := DstList.Items.Count = 0;
  IncludeBtn.Enabled := not SrcEmpty;
  IncAllBtn.Enabled := not SrcEmpty;
  ExcludeBtn.Enabled := not DstEmpty;
  ExAllBtn.Enabled := not DstEmpty;
end;

//------------------------------------------------------------------------------

function TVCSSelCrossRef.GetFirstSelection(List: TCustomListBox): Integer;
begin
  for Result := 0 to List.Items.Count - 1 do
    if List.Selected[Result] then 
      Exit;
  Result := LB_ERR;
end;

//------------------------------------------------------------------------------

procedure TVCSSelCrossRef.SetItem(List: TListBox; Index: Integer);
var
  MaxIndex: Integer;
begin
  with List do
  begin
    SetFocus;
    MaxIndex := List.Items.Count - 1;
    if Index = LB_ERR then 
      Index := 0
    else
    if Index > MaxIndex then 
      Index := MaxIndex;
    Selected[Index] := True;
  end;
  SetButtons;
end;

//------------------------------------------------------------------------------

procedure TVCSSelCrossRef.OKBtnClick(Sender: TObject);
var 
  I: Integer;
  CurrentProjectID: string;
begin
  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'ADD_UPDATE_PROJECT_REFERENCES';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [ServerProjectID]);
    AppSrvClient1.Request.WriteFields(False, [True]); // Update

    for I := 0 to DstList.Items.Count - 1 do 
    begin
      CurrentProjectID := ProjectIDs.Values[DstList.Items[I]];
      if CurrentProjectID <> '' then
        AppSrvClient1.Request.WriteFields(True, [CurrentProjectID])
    end;
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
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSSelCrossRef.CancelBtnClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSSelCrossRef.SrcListClick(Sender: TObject);
begin
  SetButtons;
end;

//------------------------------------------------------------------------------

procedure TVCSSelCrossRef.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Project_cross_references);
  if Key = VK_ESCAPE then 
  begin
    CancelBtn.Click;
    Key := 0;
  end;    
  if IncludeBtn.Enabled and (Shift * [ssShift, ssAlt, ssCtrl] = [ssCtrl]) and (Chr(Key) in ['A', 'a']) then
    if (not CtrlSCDisabled(WindowHandle)) then
      IncludeBtnClick(Self);
  if ExcludeBtn.Enabled and (Shift * [ssShift, ssAlt, ssCtrl] = [ssCtrl]) and (Chr(Key) in ['R', 'r']) then
    if (not CtrlSCDisabled(WindowHandle)) then
      ExcludeBtnClick(Self);
end;

//------------------------------------------------------------------------------

procedure TVCSSelCrossRef.btnPGroupClick(Sender: TObject);
var 
  I, J: Integer;
  ParseStr, GroupName: string;
  ProjectList: TStringList;
  DlgResult: Boolean;
  FavOpenDialog: TFavOpenDialog;
begin
  if bIsCppBuilder then 
  begin
    MessageBox(WindowHandle, PChar(JVCSRES_This_feature_is_currently_not_supported_by_the_C4343_Builder_version46_Sorry46),
      cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
    Exit;
  end;
  if (SrcList.Items.Count = 0) then 
  begin
    MessageBox(Handle, PChar(JVCSRES_List_34Available_projects34_contains_no_entries_to_add46_),
      cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
    Exit;
  end;
  FavOpenDialog := TFavOpenDialog.Create(Application);
  try
    with FavOpenDialog do
    begin
      Title := JVCSRES_Select_project_group;
      Options := [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing];
      InitialDir := ExtractFileDir(sProjectName);
      FileName := '';
      Filter := JVCSRES_Project_groups_404246bpg411244246bpg + '|' +
        JVCSRES_All_files_4042464241124424642;

      DlgResult := ExecuteFavOpenDialogWithMru(FavOpenDialog,
        sBaseRegistryKey + crbMRU + '18');
      if DlgResult then
        GroupName := FileName;
    end; // with FavOpenDialog1 do begin
  finally
    FavOpenDialog.Free;
  end;
  if not DlgResult then
    Exit;

  ParseStr := ParseProjectGroup(GroupName, WindowHandle);
  ProjectList := TStringList.Create;
  try
    while (Length(ParseStr) > 1) and (Pos('|', ParseStr) > 0) do
    begin
      ProjectList.Add(Copy(ParseStr, 1, Pos('|', ParseStr) - 1));
      Delete(ParseStr, 1, Pos('|', ParseStr));
    end; // while Pos('|', ParseStr) > 1 do begin

    if SrcList.Items.Count > 0 then 
    begin
      for J := 0 to SrcList.Items.Count - 1 do
        SrcList.Selected[J] := False;
      for I := 0 to ProjectList.Count - 1 do 
      begin
        if (ExtractFileExt(ProjectList.Strings[I]) = '.exe') or
          (ExtractFileExt(ProjectList.Strings[I]) = '.dll') then
          ProjectList.Strings[I] := ChangeFileExt(ProjectList.Strings[I],
            ('.' + sIDEProject));

        for J := 0 to SrcList.Items.Count - 1 do
          if Pos(ProjectList.Strings[I], SrcList.Items[J]) > 0 then
            SrcList.Selected[J] := True;
      end; // for I := 0 to ProjectList.Items.Count - 1 do begin
    end; // if SrcList.Items.Count > 0 then begin
    IncludeBtnClick(Self);
  finally
    ProjectList.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSSelCrossRef.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSSelCrossRef.FormDestroy(Sender: TObject);
begin
  ProjectIDs.Free;
end;

procedure TVCSSelCrossRef.FormResize(Sender: TObject);
begin
  // same width for both groupboxes;
  gbAvailableProjects.width := Trunc((width - pnlLeftRight.width) / 2);
end;

procedure TVCSSelCrossRef.FormShow(Sender: TObject);
begin
  jvcsLoadFormPosSize(Self);
end;

procedure TVCSSelCrossRef.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  jvcsSaveFormPosSize(Self);
end;

end.
