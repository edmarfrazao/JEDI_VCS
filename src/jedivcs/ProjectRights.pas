(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: ProjectRights.pas

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
2004/02/24  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/02/26  USchuster - reassigned dropped imagelist to TJvImageComboBox
                      - minor style cleaning (casing and comments)
2004/09/17  FHasovic  - Added dxGetText support for localization                      
2004/10/20  USchuster - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/11/02  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
2007/06/30  USchuster - changes for large fonts (contraints and default size depend now on PixelsPerInch; analog to Mantis #3710)                      
2008/11/01  USchuster - improved performance (Mantis #4561)
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit ProjectRights;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  {$IFDEF DEBUG}
  JclDebug,
  {$ENDIF DEBUG}
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, Buttons, ExtCtrls, RFormat, ImgList, Menus, JvListComb,
  JvExStdCtrls, JvCombobox, JVCSClasses, JVCSForms;

type
  TVCSProjectRights = class(TJVCSForm)
    Panel1: TPanel;
    btnCancel: TButton;
    Panel2: TPanel;
    Splitter1: TSplitter;
    ImageList1: TImageList;
    Help: TSpeedButton;
    lvUsers: TListView;
    lvProjects: TListView;
    Panel3: TPanel;
    Label4: TLabel;
    PopupMenu2: TPopupMenu;
    SelectAll1: TMenuItem;
    ApplyReadOnly1: TMenuItem;
    ApplyReadWrite1: TMenuItem;
    ApplyProjectAdmin1: TMenuItem;
    ClearAll1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    ApplyDefault1: TMenuItem;
    GroupBox1: TGroupBox;
    lblCurrentRight: TLabel;
    btnApply: TButton;
    Button1: TButton;
    btnReport: TButton;
    icbRight: TJvImageComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCancelClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnApplyClick(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure lvUsersChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure lvProjectsChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure ClearAllProjectbasedrights1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);
    procedure ApplyReadOnly1Click(Sender: TObject);
    procedure ApplyReadWrite1Click(Sender: TObject);
    procedure ApplyProjectAdmin1Click(Sender: TObject);
    procedure ApplyDefault1Click(Sender: TObject);
    procedure btnReportClick(Sender: TObject);
    procedure icbRightChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FCreating: Boolean;
    ActDir: string;
    CurrentRight: Integer;
    FProjectUserRightsList: TProjectUserRightsList;
    procedure GetProjectRights;
    procedure ShowCurrentRight;
    procedure UpdateRights;
    function ApplyRights(const ProjectID, UserID: string;
      const Right: Integer): Boolean;
    function CreateClipBoardStr: string;
  public
    { Public declarations }
  end;

var
  VCSProjectRights: TVCSProjectRights;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSBase, VCSProcBase, DBModule, SimpleReport, ConfigStorage, JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSProjectRights.FormCreate(Sender: TObject);
var
  I, DlgWidth, DlgHeight: Integer;
begin
  try
    Constraints.MinHeight := MulDiv(300, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(380, PixelsPerInch, 96);
    FCreating := True;
    CurrentRight := -1;
    btnApply.Enabled := False;
    // Aktuelles Verzeichnis speichern
    GetDir(0, ActDir);
    Screen.Cursor := crHourGlass;

    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    if not jvcsReadWindowSize(sBaseRegistryKey + crbWindows, 'ProjectRights',
      DlgWidth, DlgHeight) then
    begin
      DlgWidth := MulDiv(380, PixelsPerInch, 96);
      DlgHeight := MulDiv(310, PixelsPerInch, 96);
    end;
    Width := DlgWidth;
    Height := DlgHeight;

    {$IFNDEF SHOWIDS}
    lvUsers.Columns[1].Width := 0;
    lvProjects.Columns[1].Width := 0;
    {$ENDIF ~SHOWIDS}

    for I := 0 to icbRight.Items.Count - 1 do
    begin
      icbRight.Items[I].ImageIndex := I;
      // --hu icbRight.SelectedIndex[I] := I;
    end;

    Screen.Cursor := crDefault;
    Screen.Cursors[cPopUpMCursor] := LoadCursor(hInstance, PChar('CURSORRM'));
    lvUsers.Cursor := cPopUpMCursor;
    lvProjects.Cursor := cPopUpMCursor;
    lblCurrentRight.Caption := '';
    FProjectUserRightsList := TProjectUserRightsList.Create;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectRights.FormActivate(Sender: TObject);
var 
  LVItem: TListItem;
  UserLevel: Integer;
begin
  Application.ProcessMessages;
  if not FCreating then 
    Exit;
  FCreating := False;
  Screen.Cursor := crHourGlass;
  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_USERS';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
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
    lvUsers.Items.BeginUpdate;
    try
      while not AppSrvClient1.Answer.Eof do
      begin
        if (not DecodeBoolStr(AppSrvClient1.Answer.Fields[3])) and
          (_StrToInt(AppSrvClient1.Answer.Fields[2]) < 4) then
        begin
          LVItem := lvUsers.Items.Add;
          LVItem.Caption := AppSrvClient1.Answer.Fields[1];
          LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[0]);
          LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[2]);
          UserLevel := _StrToInt(AppSrvClient1.Answer.Fields[2]);
          if UserLevel = 0 then
            LVItem.ImageIndex := 5
          else
            LVItem.ImageIndex := UserLevel;
        end;
        AppSrvClient1.Answer.Next;
      end;
      if lvUsers.Items.Count > 0 then
        lvUsers.Items[0].Selected := True;
    finally
      lvUsers.Items.EndUpdate;
    end;

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

    lvProjects.Items.BeginUpdate;
    try
      AppSrvClient1.Answer.First;
      while not AppSrvClient1.Answer.Eof do
      begin
        if AppSrvClient1.Answer.Fields[2] <> '1' then
        begin
          LVItem := lvProjects.Items.Add;
          LVItem.Caption := AppSrvClient1.Answer.Fields[1];
          LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[0]);
          LVItem.ImageIndex := 0;
        end; // if AppSrvClient1.Answer.Fields[2] <> '1' then begin
        AppSrvClient1.Answer.Next;
      end;
    finally
      lvProjects.Items.EndUpdate;
    end;
    if lvProjects.Items.Count > 0 then
      lvProjects.Items[0].Selected := True;
  end; // with DataModule1 do begin
  GetProjectRights;
  FCreating := False;
  UpdateRights;
  Screen.Cursor := crDefault;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectRights.GetProjectRights;
var
  LAnswer: TMWBuffer;
begin
  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_PROJECT_RIGHTS';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
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
    FProjectUserRightsList.Clear;
    LAnswer := AppSrvClient1.Answer;
    while not LAnswer.Eof do
    begin
      FProjectUserRightsList.Add(StrToIntDef(LAnswer.Fields[0], 0),
        StrToIntDef(LAnswer.Fields[1], 0), StrToIntDef(LAnswer.Fields[2], 0));
      LAnswer.Next;
    end;
  end; // with DataModule1 do begin
end;

//------------------------------------------------------------------------------

procedure TVCSProjectRights.lvUsersChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  UpdateRights;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectRights.UpdateRights;
var
  UserID, ProjectID: Integer;
  I, Idx: Integer;
begin
  if (lvUsers.Items.Count = 0) or (lvProjects.Items.Count = 0) or
    (lvUsers.Selected = nil) then
    Exit;

  UserID := StrToIntDef(lvUsers.Selected.SubItems[0], 0);
  //Project Rights
  for I := 0 to lvProjects.Items.Count - 1 do
  begin
    ProjectID := StrToIntDef(lvProjects.Items[I].SubItems[0], 0);
    CurrentRight := 0;
    Idx := FProjectUserRightsList.IndexOf(UserID, ProjectID);
    if Idx <> -1 then
      CurrentRight := FProjectUserRightsList[Idx].AccessLevel;
    lvProjects.Items[I].ImageIndex := CurrentRight;
  end; // for I := 0 to lvProjects.Items.Count - 1 do begin
  ShowCurrentRight;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectRights.lvProjectsChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
begin
  ShowCurrentRight;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectRights.ShowCurrentRight;
begin
  if (lvProjects.Selected <> nil) and (lvUsers.Selected <> nil) then
  begin
    if lvProjects.SelCount = 1 then
    begin
      icbRight.ItemIndex := lvProjects.Selected.ImageIndex;
      lblCurrentRight.Caption := Format(JVCSRES_User_6037s62_in_project_6037s62,
        [lvUsers.Selected.Caption, lvProjects.Selected.Caption]);
    end
    else
    begin
      icbRight.ItemIndex := -1;
      lblCurrentRight.Caption := Format(JVCSRES_User_6037s62_in_60Selected_projects_4037d41_62,
        [lvUsers.Selected.Caption, lvProjects.SelCount]);
    end;
  end
  else
    lblCurrentRight.Caption := '?';
end;

//------------------------------------------------------------------------------

procedure TVCSProjectRights.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  jvcsWriteWindowSize(sBaseRegistryKey + crbWindows, 'ProjectRights',
    Width, Height);

  ChDir(ActDir);
end;

//------------------------------------------------------------------------------

procedure TVCSProjectRights.btnCancelClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectRights.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Project_based_rights);
  if Key = VK_ESCAPE then 
  begin
    btnCancel.Click;
    Key := 0;
  end;    
end;

//------------------------------------------------------------------------------

procedure TVCSProjectRights.icbRightChange(Sender: TObject);
begin
  if FCreating then 
    Exit;
  btnApply.Enabled := True;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectRights.btnApplyClick(Sender: TObject);
var 
  I: Integer;
begin
  if (lvUsers.Selected = nil) or (lvProjects.Selected = nil) or
    (icbRight.ItemIndex = -1) then 
    Exit;
  for I := 0 to lvProjects.Items.Count - 1 do 
  begin
    if (lvProjects.Items[I].Selected) and
      (lvProjects.Items[I].ImageIndex <> icbRight.ItemIndex) then
      if not ApplyRights(lvProjects.Items[I].SubItems[0],
        lvUsers.Selected.SubItems[0], icbRight.ItemIndex) then 
        Break;
  end;
  btnApply.Enabled := False;
  GetProjectRights;
  UpdateRights;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectRights.ClearAllProjectbasedrights1Click(Sender: TObject);
var 
  UserID: string;
  I: Integer;
begin
  if (lvUsers.Selected = nil) then 
    Exit;
  if MessageBox(WindowHandle, PChar(Format(JVCSRES_Are_you_sure_you_want_to_clear_all_project_based_rights + #13#10 +
    JVCSRES_assigned_to_user_6037s6263, [lvUsers.Selected.Caption])),
    cMsgBoxCaption, MB_YESNOCANCEL or MB_ICONQUESTION) <> idYes then 
    Exit;
  UserID := lvUsers.Selected.SubItems[0];
  for I := 0 to lvProjects.Items.Count - 1 do 
  begin
    if (lvProjects.Items[I].ImageIndex > 0) then
      if not ApplyRights(lvProjects.Items[I].SubItems[0], UserID, 0) then 
        Break;
  end;
  GetProjectRights;
  UpdateRights;
end;

//------------------------------------------------------------------------------

function TVCSProjectRights.ApplyRights(const ProjectID, UserID: string;
  const Right: Integer): Boolean;
begin
  Result := True;
  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'SET_PROJECT_RIGHTS';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [UserID]);
    AppSrvClient1.Request.WriteFields(False, [ProjectID]);
    AppSrvClient1.Request.WriteFields(False, [Right]);
    SetupTimeoutCounter;
    AppSrvClient1.Send;

    while WaitForAppSrvClient do
      Application.ProcessMessages;
    if (AppSrvClientErr = -99) then 
    begin
      ShowServerTimeOut(WindowHandle);
      Result := False;
      Exit;
    end;
    if (AppSrvClientErr <> 0) or
      (AppSrvClient1.AnswerStatus <> '200') then 
    begin
      ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
        AppSrvClient1.AnswerStatus);
      Result := False;
      Exit;
    end;
  end; // with DataModule1 do begin
end;

//------------------------------------------------------------------------------

procedure TVCSProjectRights.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSProjectRights.FormResize(Sender: TObject);
begin
  {$IFNDEF SHOWIDS}
  lvUsers.Columns[0].Width := lvUsers.Width - 25;
  lvProjects.Columns[0].Width := lvProjects.Width - 25;
  {$ENDIF ~SHOWIDS}
end;

//------------------------------------------------------------------------------

procedure TVCSProjectRights.SelectAll1Click(Sender: TObject);
var 
  I: Integer;
begin
  for I := 0 to lvProjects.Items.Count - 1 do
    lvProjects.Items[I].Selected := True;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectRights.ApplyDefault1Click(Sender: TObject);
begin
  icbRight.ItemIndex := 0;
  btnApplyClick(Self);
end;

//------------------------------------------------------------------------------

procedure TVCSProjectRights.ApplyReadOnly1Click(Sender: TObject);
begin
  icbRight.ItemIndex := 1;
  btnApplyClick(Self);
end;

//------------------------------------------------------------------------------

procedure TVCSProjectRights.ApplyReadWrite1Click(Sender: TObject);
begin
  icbRight.ItemIndex := 2;
  btnApplyClick(Self);
end;

//------------------------------------------------------------------------------

procedure TVCSProjectRights.ApplyProjectAdmin1Click(Sender: TObject);
begin
  icbRight.ItemIndex := 3;
  btnApplyClick(Self);
end;

//------------------------------------------------------------------------------

function TVCSProjectRights.CreateClipBoardStr: string;
var 
  I, J, CurrentRight, DefaultRight: Integer;
  CurrentText, CurrentUserID, CurrentProjectID: string;
  oaColumnsWidth: array of Integer;
const 
  cr = Chr(13) + Chr(10);

  function GetSpecificRight(const ProjectID, UserID: string): Integer;
  var
    Idx: Integer;
  begin
    Result := -1;
    Idx := FProjectUserRightsList.IndexOf(StrToIntDef(UserID, 0), StrToIntDef(ProjectID, 0));
    if Idx <> -1 then
      Result := FProjectUserRightsList[Idx].AccessLevel;
  end;

  function SizeString(const Column: Integer; const CellString: string;
    const Fillchr: Char): string;
  begin
    Result := CellString;
    while Length(Result) < oaColumnsWidth[Column] do
      Result := Result + Fillchr;
  end;
begin
  Result := '';
  if (lvUsers.Items.Count = 0) or
    (lvProjects.Items.Count = 0) then 
  begin
    MessageBox(WindowHandle, PChar(JVCSRES_Requested_result_set_is_blank46_Nothing_to_do46),
      cMsgBoxCaption, MB_OK);
    Exit;
  end;

  Screen.Cursor := crHourGlass;
  try
    // Textlänge in der Spalte?
    SetLength(oaColumnsWidth, lvUsers.Items.Count + 1);
    // Project = 0
    oaColumnsWidth[0] := 0;

    for I := 0 to lvProjects.Items.Count - 1 do 
    begin
      if Length(lvProjects.Items[I].Caption) > oaColumnsWidth[0] then
        oaColumnsWidth[0] := Length(lvProjects.Items[I].Caption);
    end;
    // Users = 1 - x
    for J := 0 to lvUsers.Items.Count - 1 do 
    begin
      oaColumnsWidth[J + 1] := Length(lvUsers.Items[J].Caption);
      if (oaColumnsWidth[J + 1] < 13) then
        oaColumnsWidth[J + 1] := 13;
    end;

    Result := Caption + cr;
    CurrentText := '';
    while Length(CurrentText) < Length(Caption) do
      CurrentText := CurrentText + '=';
    Result := Result + CurrentText + cr + cr;

    Result := Result + SizeString(0, ' ', ' ') + ' | ';
    for J := 0 to lvUsers.Items.Count - 1 do 
    begin
      Result := Result + SizeString(J + 1, lvUsers.Items[J].Caption, ' ');
      if J < (lvUsers.Items.Count - 1) then 
        Result := Result + ' | ';
    end;
    Result := Result + cr;

    Result := Result + SizeString(0, '-', '-') + ' | ';
    for J := 0 to lvUsers.Items.Count - 1 do 
    begin
      Result := Result + SizeString(J + 1, '-', '-');
      if J < (lvUsers.Items.Count - 1) then 
        Result := Result + ' | ';
    end;
    Result := Result + cr;

    for I := 0 to lvProjects.Items.Count - 1 do 
    begin
      Result := Result + SizeString(0, lvProjects.Items[I].Caption, ' ') + ' | ';
      CurrentProjectID := lvProjects.Items[I].SubItems[0];
      for J := 0 to lvUsers.Items.Count - 1 do 
      begin
        CurrentUserID := lvUsers.Items[J].SubItems[0];
        case lvUsers.Items[J].ImageIndex of
          0: 
            DefaultRight := -1;
          5: 
            DefaultRight := 0;
          1: 
            DefaultRight := 1;
          2:
            DefaultRight := 2;
          3:
            DefaultRight := 3;
          else
            DefaultRight := -1;
        end;
        CurrentRight := GetSpecificRight(CurrentProjectID, CurrentUserID);
        if CurrentRight = -1 then
          CurrentRight := DefaultRight;
        case CurrentRight of
          0:
            Result := Result + SizeString(J + 1, JVCSRES_None, ' ');
          1:
            Result := Result + SizeString(J + 1, JVCSRES_read45only, ' ');
          2:
            Result := Result + SizeString(J + 1, JVCSRES_read45write, ' ');
          3:
            Result := Result + SizeString(J + 1, JVCSRES_Project_Admin, ' ');
        end;
        if J < (lvUsers.Items.Count - 1) then 
          Result := Result + ' | ';
      end; // for J := 0 to lvUsers.Items.Count - 1 do begin
      Result := Result + cr;
    end; // for I := 0 to lvProjects.Items.Count - 1 do begin

    Result := Result + cr + JVCSRES_Source58_ + sArchiveSource + cr +
      JVCSRES_JEDI_VCS_ + sProductVer + cProductInf + DateTimeToStr(Now) + cr;
  finally
    Screen.Cursor := crDefault;
    SetLength(oaColumnsWidth, 0);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProjectRights.btnReportClick(Sender: TObject);
var 
  ResultString: string;
begin
  ResultString := CreateClipBoardStr;
  if ResultString = '' then 
    Exit;

  VCSSimpleReport := TVCSSimpleReport.Create(Application);
  try
    VCSSimpleReport.RepID := 11;
    VCSSimpleReport.Left := Left + 60;
    VCSSimpleReport.Top := Top + 60;
    VCSSimpleReport.FullReportString := ResultString;
    VCSSimpleReport.SavePath := ExtractFileDir(sProjectName);
    VCSSimpleReport.SaveFileName := 'ProjectRights.txt';
    VCSSimpleReport.LineCount := lvUsers.Items.Count +
      lvProjects.Items.Count + 8;
    VCSSimpleReport.ShowModal;
  finally
    VCSSimpleReport.Free;
  end;
end;

procedure TVCSProjectRights.FormDestroy(Sender: TObject);
begin
  FProjectUserRightsList.Free;
end;

end.
