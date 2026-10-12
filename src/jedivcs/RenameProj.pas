(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: RenameProj.pas

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
2003/03/05  THensle   - changes for "ConfigStorage" unit
2003/12/28  USchuster - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use constant)
2004/09/17  FHasovic  - Added dxGetText support for localization                      
2004/10/17  USchuster - style cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/11/02  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
2007/07/01  USchuster - changes for large fonts (contraints and default size depend now on PixelsPerInch; analog to Mantis #3710)
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit RenameProj;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ImgList, ComCtrls, Buttons;

type
  TVCSRenameProj = class(TForm)
    SaveDialog1: TSaveDialog;
    Panel1: TPanel;
    btnRemove: TButton;
    btnCancel: TButton;
    edRename: TEdit;
    Label3: TLabel;
    Panel2: TPanel;
    lblRemProj: TLabel;
    LVModules: TListView;
    SysImageList: TImageList;
    StateImageList: TImageList;
    Help: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure edRenameChange(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cbInclHiddenClick(Sender: TObject);
    procedure LVModulesKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure LVModulesMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure HelpClick(Sender: TObject);
  private
    { Private declarations }
    FCreating: Boolean;
    procedure FillListView;
  public
    { Public declarations }
    SelectedProjectID: Integer;
    SelectedProjectName: string;
    Renamed: Boolean;
  end;

var
  VCSRenameProj: TVCSRenameProj;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSBase, VCSProcBase, DBModule, ShellAPI, Std_ListView, ConfigStorage,
  JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSRenameProj.FormCreate(Sender: TObject);
var
  sfi: TSHFileInfo;
  DlgWidth, DlgHeight: Integer;
begin
  try
    Constraints.MinHeight := MulDiv(220, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(311, PixelsPerInch, 96);
    FCreating := True;
    Renamed := False;

    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    if not jvcsReadWindowSize(sBaseRegistryKey + crbWindows, 'RenameProject',
      DlgWidth, DlgHeight) then
    begin
      DlgWidth := MulDiv(320, PixelsPerInch, 96);
      DlgHeight := MulDiv(220, PixelsPerInch, 96);
    end;
    Width := DlgWidth;
    Height := DlgHeight;

    with LVModules do
    begin
      Columns[0].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'RenameProject_Col1.0', 120);
      Columns[1].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'RenameProject_Col1.1', 100);
    end;

    {$IFDEF CUSTOMDRIVE}
    sDriveSubst := RegReadString(HKCU, sBaseRegistryKey + crbProjects +
      ExtractFileName(sProjectName), 'LocalDrive', '');
    if (sDriveSubst = '') then
      sDriveSubst := RegReadString(HKCU, sBaseRegistryKey + crbOptions,
        'LocalDrive', '');
    {$ENDIF CUSTOMDRIVE}

    //Systemsymbole in eine TImageList-Komponente einlesen
    SysImageList.Handle := SHGetFileInfo('', 0, sfi, SizeOf(TSHFileInfo),
      SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
    SysImageList.ShareImages := True;
    {$IFNDEF SHOWIDS}
    LVModules.Columns[2].Width := 0;
    {$ENDIF ~SHOWIDS}
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSRenameProj.FormActivate(Sender: TObject);
begin
  if FCreating then 
  begin
    FCreating := False;
    btnRemove.Enabled := False;
    lblRemProj.Caption := Format(JVCSRES_Rename_project_6037s62, [SelectedProjectName]);
    FillListView;
  end; // if FCreating then begin
end;

//------------------------------------------------------------------------------

procedure TVCSRenameProj.FillListView;
var 
  sfi: TSHFileInfo;
  LVItem: TListItem;
  CurrentPath: string;
begin
  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_PROJECT_MODULE_LIST';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [SelectedProjectID]);
    AppSrvClient1.Request.WriteFields(False, [False]);
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
    LVModules.Items.BeginUpdate;
    try
      LVModules.Items.Clear;
      while not AppSrvClient1.Answer.Eof do 
      begin
        if (AppSrvClient1.Answer.Fields[1] =
          ChangeFileExt(SelectedProjectName, ('.' + sIDEProject))) or
          (AppSrvClient1.Answer.Fields[1] =
          ChangeFileExt(SelectedProjectName, ('.' + sIDEPackage))) or
          (AppSrvClient1.Answer.Fields[1] =
          ChangeFileExt(SelectedProjectName, '.dof')) or
          (AppSrvClient1.Answer.Fields[1] =
          ChangeFileExt(SelectedProjectName, '.res')) or
          (AppSrvClient1.Answer.Fields[1] =
          ChangeFileExt(SelectedProjectName, '.cfg')) or
          (AppSrvClient1.Answer.Fields[1] =
          ChangeFileExt(SelectedProjectName, '.dsk')) then
        begin
          LVItem := LVModules.Items.Add;
          LVItem.Caption := AppSrvClient1.Answer.Fields[1];
          {$IFDEF CUSTOMDRIVE}
          CurrentPath := ChangeDriveName(AppSrvClient1.Answer.Fields[2], sDriveSubst);
          {$ELSE}
          CurrentPath := AppSrvClient1.Answer.Fields[2];
          {$ENDIF CUSTOMDRIVE}
          // FileIcon
          if FileExists(CurrentPath +
            AppSrvClient1.Answer.Fields[1]) then 
          begin
            SHGetFileInfo(PChar(CurrentPath +
              AppSrvClient1.Answer.Fields[1]), 0, sfi, SizeOf(sfi),
              SHGFI_SYSICONINDEX or SHGFI_SMALLICON or SHGFI_DISPLAYNAME);
            LVItem.ImageIndex := sfi.IIcon;
          end 
          else 
            LVItem.ImageIndex := -1;
          LVItem.StateIndex := 1;
          LVItem.SubItems.Add(CurrentPath);
          LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[0]);
        end; // if (AppSrvClient1.Answer.Fields[1] =...
        AppSrvClient1.Answer.Next;
      end;
    finally
      LVModules.Items.EndUpdate;
    end;
  end; // with DataModule1 do begin}
end;

//------------------------------------------------------------------------------

procedure TVCSRenameProj.edRenameChange(Sender: TObject);
begin
  btnRemove.Enabled := edRename.Text <> '';
end;

//------------------------------------------------------------------------------

procedure TVCSRenameProj.btnRemoveClick(Sender: TObject);
var 
  I: Integer;
  Msg, ResultString, NewModuleName: string;
  ProjectRenamed: Boolean;
begin
  if not IsValidProjectName(edRename.Text, Msg) then 
  begin
    MessageBox(Application.Handle, PChar(Format('<%s>' + #13#10 + '%s' + #13#10 +
      JVCSRES_See_help_topic_34Naming_conventions34_for_more_information46, [edRename.Text, Msg])),
      cMsgBoxCaption, MB_OK or MB_ICONEXCLAMATION);
    edRename.SetFocus;
    edRename.SelectAll;
    Exit;
  end;

  {$IFDEF IDEDLL}
  if (ExtractFileExt(SelectedProjectName) <>
    AnsiLowerCase(ExtractFileExt(edRename.Text))) then 
  begin
    MessageBox(WindowHandle, PChar(JVCSRES_The_new_project_name_must_have_the_same_file_extension_as_the_old_one46),
      cMsgBoxCaption, MB_OK or MB_ICONWARNING);
    edRename.SetFocus;
    edRename.SelectAll;
    Exit;
  end;
  {$ENDIF IDEDLL}

  if MessageBox(WindowHandle, PChar(Format(JVCSRES_37s_and_all_selected_modules63,
    [lblRemProj.Caption])), cMsgBoxCaption,
    MB_YESNOCANCEL or MB_ICONQUESTION) <> id_Yes then 
    Exit;

  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_PROJECT_ID';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [edRename.Text]);
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
    if AppSrvClient1.Answer.Fields[0] <> '0' then 
    begin
      // known project
      TransactionNr := _StrToInt(AppSrvClient1.Answer.Fields[2]);
      BeepIfSet;
      MessageBox(WindowHandle, PChar(JVCSRES_Projectname_is_already_in_use46 + #10#13 +
        JVCSRES_Access_denied46), cMsgBoxCaption, MB_OK or MB_ICONWARNING);
      Exit;
    end 
    else 
      TransactionNr := _StrToInt(AppSrvClient1.Answer.Fields[2]);

    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'RENAME_PROJECT';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(False, [SelectedProjectID]);
    AppSrvClient1.Request.WriteFields(False, [edRename.Text]);
    for I := 0 to LVModules.Items.Count - 1 do 
    begin
      if LVModules.Items[I].StateIndex = 1 then 
      begin
        AppSrvClient1.Request.WriteFields(True,
          [LVModules.Items[I].SubItems[1]]);
        NewModuleName := ChangeFileExt(ExtractFileName(edRename.Text),
          ExtractFileExt(LVModules.Items[I].Caption));
        AppSrvClient1.Request.WriteFields(False, [AnsiLowerCase(NewModuleName)]);
      end; // if LVModules.Items[I].StateIndex := 1 then begin
    end; // for I := 0 to LVModules.Items.Count - 1 do begin
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
    ProjectRenamed := DecodeBoolStr(AppSrvClient1.Answer.Fields[0]);
    if ProjectRenamed then
      MessageBox(WindowHandle, PChar(JVCSRES_Project_successfully_renamed46), cMsgBoxCaption,
        MB_OK or MB_ICONINFORMATION)
    else 
    begin
      MessageBox(WindowHandle, PChar(Format(JVCSRES_Access_denied_4037s4146 + #13#10 +
        JVCSRES_The_project_still_contains_checked_out_modules46 + #13#10 +
        JVCSRES_Check_In_all_related_modules_and_retry46, [JVCSRES_Rename_project])),
        cMsgBoxCaption, MB_OK or MB_ICONWARNING);
      if not AppSrvClient1.Answer.Eof then 
        AppSrvClient1.Answer.Next;
      ResultString := '';
      while not AppSrvClient1.Answer.Eof do 
      begin
        ResultString := ResultString + AppSrvClient1.Answer.Fields[1] + ';|';
        AppSrvClient1.Answer.Next;
      end;
      VCSStdListView := TVCSStdListView.Create(Application);
      try
        VCSStdListView.LVRepID := 18;
        VCSStdListView.Caption := JVCSRES_Checked_out;
        VCSStdListView.Left := Left + 60;
        VCSStdListView.Top := Top + 60;
        VCSStdListView.LVType := 0;
        VCSStdListView.HelpContextID := IDH_Rename_project;
        VCSStdListView.AddListColumn(JVCSRES_Module, False);
        VCSStdListView.SetUpItems(ResultString);
        VCSStdListView.ShowModal;
      finally
        VCSStdListView.Free;
      end;
      Exit;
    end; // else if ProjectRenamed then
  end; // with DataModule1 do begin

  if MessageBox(WindowHandle, PChar(Format('<%s>' + #13#10 +
    JVCSRES_Remove_all_registry_values_associated_with_this_project63,
    ['HKCU\' + sBaseRegistryKey +
    crbProjects + SelectedProjectName])), cMsgBoxCaption,
    MB_YESNO or MB_DEFBUTTON2 or MB_ICONQUESTION) = id_Yes then
  begin
    if jvcsKeyExists(sBaseRegistryKey + crbProjects + SelectedProjectName) then
      jvcsDeleteKey(sBaseRegistryKey + crbProjects + SelectedProjectName);
  end; // if MessageBox(...then begin

  Renamed := True;
  btnRemove.Enabled := False;
  btnCancel.Caption := JVCSRES_38Close;
  btnCancel.SetFocus;
end;

//------------------------------------------------------------------------------

procedure TVCSRenameProj.btnCancelClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSRenameProj.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    btnCancel.Click;
    Key := 0;
  end;
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Rename_project);
end;

//------------------------------------------------------------------------------

procedure TVCSRenameProj.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  jvcsWriteWindowSize(sBaseRegistryKey + crbWindows, 'RenameProject',
    Width, Height);

  with LVModules do
  begin
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'RenameProject_Col1.0',
      Columns[0].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'RenameProject_Col1.1',
      Columns[1].Width);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSRenameProj.cbInclHiddenClick(Sender: TObject);
begin
  if not FCreating then 
    FillListView;
end;

//------------------------------------------------------------------------------

procedure TVCSRenameProj.LVModulesKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (LVModules.Selected <> nil) and (Key = VK_SPACE) then 
  begin
    if LVModules.Selected.StateIndex > 1 then 
      Exit;
    if LVModules.Selected.StateIndex = 0 then 
      LVModules.Selected.StateIndex := 1
    else 
      LVModules.Selected.StateIndex := 0;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSRenameProj.LVModulesMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var 
  HitTest: THitTests;
  HitItem: TListItem;
begin
  HitTest := LVModules.GetHitTestInfoAt(X, Y);
  if (Button = mbLeft) and (htOnStateIcon in HitTest) then 
  begin
    HitItem := LVModules.GetItemAt(X, Y);
    if HitItem.StateIndex > 1 then 
      Exit;
    if HitItem.StateIndex = 0 then 
      HitItem.StateIndex := 1 
    else 
      HitItem.StateIndex := 0;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSRenameProj.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

end.
