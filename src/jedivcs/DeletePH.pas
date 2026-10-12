(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: DeletePH.pas

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
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/31  USchuster - style cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/11/05  USchuster - moved resourcestrings to JVCSGUIClientResources.pas                      
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit DeletePH;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Buttons, JVCSForms;

type
  TFilterDefinition = record
    FilterValue: string;
    FilterProject,
    FilterModule,
    FilterUser: Integer;
    FilterStartDate,
    FilterEndDate: Double;
  end;

type
  TVCSDeletePH = class(TJVCSForm)
    btnOk: TButton;
    btnCancel: TButton;
    cbProjects: TComboBox;
    cbModule: TComboBox;
    cbUser: TComboBox;
    dtpStartDate: TDateTimePicker;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label1: TLabel;
    Help: TSpeedButton;
    procedure btnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FCreating: Boolean;
  public
    { Public declarations }
  end;

var
  VCSDeletePH: TVCSDeletePH;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  DBModule, VCSBase, VCSProcBase, ProjectHist, ConfigStorage, JVCSGUIClientResources;

{$R *.dfm}

//------------------------------------------------------------------------------
{- New class of items to insert in a list }
type
  TIDItem = class
    I: Integer;
    constructor Create(I1: Integer);
  end;

  {- Create a new instance of TIDItem }
constructor TIDItem.Create(I1: Integer);
begin
  I := I1;                { Save integer parameter }
  inherited Create;       { Call inherited Create }
end;

//------------------------------------------------------------------------------

procedure TVCSDeletePH.FormCreate(Sender: TObject);
begin
  try
    FCreating := True;
    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);
    dtpStartDate.Date := Now - 30;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSDeletePH.FormActivate(Sender: TObject);
var 
  I: Integer;
  CurrentEnty, CurrentType, CurrentID: string;
  IDItem: TIDItem;
begin
  Application.ProcessMessages;
  if not FCreating then 
    Exit;
  FCreating := False;

  cbProjects.Items.Add(JVCSRES_Ignore_project_name);
  cbModule.Items.Add(JVCSRES_Ignore_module_name);
  cbUser.Items.Add(JVCSRES_Ignore_user_name);
  cbProjects.ItemIndex := 0;
  cbModule.ItemIndex := 0;
  cbUser.ItemIndex := 0;

  for I := 0 to VCSProjectHistory.FilterBuffer.Count - 1 do 
  begin
    CurrentEnty := VCSProjectHistory.FilterBuffer.Strings[I];
    CurrentType := Copy(CurrentEnty, 1, Pos('|', CurrentEnty) - 1);
    Delete(CurrentEnty, 1, Pos('|', CurrentEnty));
    CurrentID := Copy(CurrentEnty, 1, Pos('|', CurrentEnty) - 1);
    Delete(CurrentEnty, 1, Pos('|', CurrentEnty));

    if CurrentType = 'p' then 
    begin
      IDItem := TIDItem.Create(_StrToInt(CurrentID));
      cbProjects.Items.AddObject(CurrentEnty, IDItem);
    end;
    if CurrentType = 'm' then 
    begin
      IDItem := TIDItem.Create(_StrToInt(CurrentID));
      cbModule.Items.AddObject(CurrentEnty, IDItem);
    end;
    if CurrentType = 'u' then 
    begin
      IDItem := TIDItem.Create(_StrToInt(CurrentID));
      cbUser.Items.AddObject(CurrentEnty, IDItem);
    end;
  end; // for I := 0 to VCSProjectHistory.FilterBuffer.Count - 1 do begin
end;

//------------------------------------------------------------------------------

procedure TVCSDeletePH.btnOkClick(Sender: TObject);
var 
  ProjectID, ModuleID, UserID: Integer;
  ExpDate: Double;
begin
  if MessageBox(WindowHandle, PChar(JVCSRES_Are_you_sure_you_want_to_delete_the_selected_items63
    + #13#10 + JVCSRES_Warning33_This_process_is_not_reversible46), cMsgBoxCaption,
    MB_YESNOCANCEL or MB_DEFBUTTON2 or MB_ICONWARNING) <> id_Yes then 
    Exit;

  if (cbProjects.ItemIndex > 0) then
    ProjectID := TIDItem(cbProjects.Items.Objects[cbProjects.ItemIndex]).I
  else
    ProjectID := 0;

  if (cbModule.ItemIndex > 0) then
    ModuleID := TIDItem(cbModule.Items.Objects[cbModule.ItemIndex]).I
  else
    ModuleID := 0;

  if (cbUser.ItemIndex > 0) then
    UserID := TIDItem(cbUser.Items.Objects[cbUser.ItemIndex]).I
  else
    UserID := 0;

  ExpDate := dtpStartDate.Date;

  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'REMOVE_LOG_ENTRIES';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [ProjectID]);
    AppSrvClient1.Request.WriteFields(False, [ModuleID]);
    AppSrvClient1.Request.WriteFields(False, [UserID]);
    AppSrvClient1.Request.WriteFields(False, [ExpDate]);
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
    if not AppSrvClient1.Answer.Eof then
    begin
      MessageBox(WindowHandle, PChar(Format(JVCSRES_37s_items_removed46,
        [AppSrvClient1.Answer.Fields[0]])), cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
    end;
  end; // with DataModule1 do begin
  ModalResult := mrOk;
end;

//------------------------------------------------------------------------------

procedure TVCSDeletePH.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSDeletePH.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Project_history);
end;

//------------------------------------------------------------------------------

procedure TVCSDeletePH.FormDestroy(Sender: TObject);
var 
  I: Integer;
begin
  for I := 0 to cbProjects.Items.Count - 1 do
    cbProjects.Items.Objects[I].Free;
  for I := 0 to cbModule.Items.Count - 1 do
    cbModule.Items.Objects[I].Free;
  for I := 0 to cbUser.Items.Count - 1 do
    cbUser.Items.Objects[I].Free;
end;

end.
