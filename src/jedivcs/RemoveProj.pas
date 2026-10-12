(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: RemoveProj.pas

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
2007/06/05  USchuster - as of now the icon will be replaced with the OS icon
2011/01/15  USchuster - changed font to Tahoma                      

-----------------------------------------------------------------------------*)

unit RemoveProj;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons;

type
  TVCSRemoveProj = class(TForm)
    btnRemove: TButton;
    btnCancel: TButton;
    Image1: TImage;
    Label1: TLabel;
    Button1: TButton;
    Help: TSpeedButton;
    lblRemProj: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure HelpClick(Sender: TObject);
  private
    { Private declarations }
    FCreating: Boolean;
  public
    { Public declarations }
    SelectedProject: string;
    SelectedProjectID: Integer;
    Removed: Boolean;
  end;

var
  VCSRemoveProj: TVCSRemoveProj;

implementation

uses 
  {$IFDEF DEBUG}
  JclDebug,
  {$ENDIF DEBUG}
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSBase, VCSProcBase, DBModule, Std_ListView, ConfigStorage, JVCSGUIClientResources;

{$R *.dfm}

//------------------------------------------------------------------------------

procedure TVCSRemoveProj.FormCreate(Sender: TObject);
begin
  try
    Image1.Picture.Icon.Handle := LoadIcon(0, IDI_EXCLAMATION);
    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);
    FCreating := True;
    Removed := False;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSRemoveProj.FormActivate(Sender: TObject);
begin
  if FCreating then
  begin
    FCreating := False;
    lblRemProj.Caption := Format(JVCSRES_Remove_6037s6263, [SelectedProject]);
  end; // if FCreating then begin
end;

//------------------------------------------------------------------------------

procedure TVCSRemoveProj.btnRemoveClick(Sender: TObject);
var
  ResultString: string;
  ProjectRemoved: Boolean;
begin
  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'REMOVE_PROJECT';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [SelectedProjectID]);
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

    ResultString := '';
    AppSrvClient1.Answer.First;
    if not DecodeBoolStr(AppSrvClient1.Answer.Fields[0]) then
    begin
      ProjectRemoved := False;
      if not AppSrvClient1.Answer.Eof then
        AppSrvClient1.Answer.Next;
      while not AppSrvClient1.Answer.Eof do
      begin
        ResultString := ResultString + AppSrvClient1.Answer.Fields[0] + ';' +
          AppSrvClient1.Answer.Fields[1] + ';|';
        AppSrvClient1.Answer.Next;
      end;
    end // if not DecodeBoolStr(AppSrvClient1.Answer.Fields[0]) then begin
    else
      ProjectRemoved := True;
  end; // with DataModule1 do begin}

  if ProjectRemoved then
  begin
    if MessageBox(WindowHandle, PChar(Format(JVCSRES_Project_6037s62_successfully_removed46,
      [SelectedProject]) + #10#13 + Format('<%s>' + #13#10 +
      JVCSRES_Remove_all_registry_values_associated_with_this_project63, ['HKCU\' + sBaseRegistryKey +
      crbProjects + SelectedProject])), cMsgBoxCaption,
      MB_YESNO or MB_DEFBUTTON2 or MB_ICONQUESTION) = id_Yes then
    begin
      if jvcsKeyExists(sBaseRegistryKey + crbProjects + SelectedProject) then
        jvcsDeleteKey(sBaseRegistryKey + crbProjects + SelectedProject);
    end; // if MessageBox(...then begin
  end // if ProjectRemoved then begin
  else
  begin
    MessageBox(WindowHandle, PChar(Format(JVCSRES_Access_denied_4037s4146 + #13#10 +
      JVCSRES_The_project_still_contains_checked_out_modules46 + #13#10+
      JVCSRES_Check_In_all_related_modules_and_retry46, [JVCSRES_Remove_project])),
      cMsgBoxCaption, MB_OK or MB_ICONWARNING);

    VCSStdListView := TVCSStdListView.Create(Application);
    try
      VCSStdListView.LVRepID := 17;
      VCSStdListView.Caption := JVCSRES_Checked_Out;
      VCSStdListView.Left := Left + 40;
      VCSStdListView.Top := Top + 40;
      VCSStdListView.LVType := 1;
      VCSStdListView.HelpContextID := IDH_Remove_project;
      VCSStdListView.AddListColumn(JVCSRES_Module_ID, False);
      VCSStdListView.AddListColumn(JVCSRES_Checked_out_modules, False);
      VCSStdListView.SetUpItems(ResultString);
      VCSStdListView.ShowModal;
    finally
      VCSStdListView.Free;
    end;
  end;
  Removed := True;
  btnRemove.Enabled := False;
  btnCancel.Caption := JVCSRES_38Close;
  btnCancel.SetFocus;
end;

//------------------------------------------------------------------------------

procedure TVCSRemoveProj.btnCancelClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSRemoveProj.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    btnCancel.Click;
    Key := 0;
  end;
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Remove_project);
end;

//------------------------------------------------------------------------------

procedure TVCSRemoveProj.HelpClick(Sender: TObject);
var
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

end.
