(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: AddShareModule.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDIVCS:
  Thomas Huber (Thomas_D_Huber@t-online.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FreeVCS code to JEDI-VCS
2003/03/02  THensle   - changes for "ConfigStorage" unit
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/03  THuber    - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/10/08  THuber    - resourcestring now in JVCSGuiClientResources
2007/07/01  USchuster - style cleaning
                      - changes for large fonts (contraints and default size depend now on PixelsPerInch; analog to Mantis #3710)
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit AddShareModule;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Forms, StdCtrls, ComCtrls, ExtCtrls, Buttons,
  Controls, JVCSForms;

type
  TVCSAddSharedModule = class(TJVCSForm)
    Panel1: TPanel;
    btnCancel: TButton;
    btnOK: TButton;
    ListView1: TListView;
    btnNext: TButton;
    Help: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnNextClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure HelpClick(Sender: TObject);
  private
    { Private declarations }
    FCreating: Boolean;
    IDBuffer: Integer;
    Side: Integer;
    SelectedProject: string;
    procedure SelectProject;
    procedure SelectModule;
  public
    { Public declarations }
    DefaultID: Integer;
    SelectedModules: TStringList;
  end;

var
  VCSAddSharedModule: TVCSAddSharedModule;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSBase, VCSProcBase, DBModule, ConfigStorage, JvJVCLUtils, JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSAddSharedModule.FormCreate(Sender: TObject);
var
  DlgWidth, DlgHeight: Integer;
begin
  try
    Constraints.MinHeight := MulDiv(190, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(295, PixelsPerInch, 96);
    FCreating := True;
    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    if not jvcsReadWindowSize(sBaseRegistryKey + crbWindows, 'AddSharedModule',
      DlgWidth, DlgHeight) then
    begin
      DlgWidth := MulDiv(300, PixelsPerInch, 96);
      DlgHeight := MulDiv(190, PixelsPerInch, 96);
    end;
    Width := DlgWidth;
    Height := DlgHeight;

    {$IFDEF CUSTOMDRIVE}
    sDriveSubst := RegReadString(HKCU, sBaseRegistryKey + crbProjects +
      ExtractFileName(sProjectName), 'LocalDrive', '');
    if (sDriveSubst = '') then
      sDriveSubst := RegReadString(HKCU, sBaseRegistryKey + crbOptions,
        'LocalDrive', '');
    {$ENDIF CUSTOMDRIVE}

    {$IFNDEF SHOWIDS}
    ListView1.Columns[1].Width := 0;
    {$ENDIF ~SHOWIDS}
    SelectedModules := TStringList.Create;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSAddSharedModule.FormActivate(Sender: TObject);
begin
  Application.ProcessMessages;
  if FCreating then
  begin
    FCreating := False;
    btnOK.Enabled := False;
    SelectProject;
  end; // if FCreating then begin
end;

//------------------------------------------------------------------------------

procedure TVCSAddSharedModule.btnNextClick(Sender: TObject);
begin
  if Side = 1 then
    if ListView1.Selected = nil then
      Exit;
  if Side = 1 then
  begin
    IDBuffer := _StrToInt(ListView1.Selected.SubItems[0]);
    SelectedProject := ListView1.Selected.Caption;
    btnNext.Caption := JVCSRES_38Back_60;
    SelectModule;
  end
  else
  begin
    btnNext.Caption := JVCSRES_38Next_62;
    SelectProject;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSAddSharedModule.btnOKClick(Sender: TObject);
var
  I: Integer;
begin
  if ListView1.Selected = nil then 
    Exit;
  SelectedModules.Clear;
  for I := 0 to ListView1.Items.Count - 1 do
    if ListView1.Items[I].Selected then
      SelectedModules.Add(ListView1.Items[I].SubItems[1] +
        LowerCase(ListView1.Items[I].Caption));
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSAddSharedModule.btnCancelClick(Sender: TObject);
begin
  SelectedModules.Clear;
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSAddSharedModule.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Sharing_modules_between_different_projects);
  if Key = VK_ESCAPE then 
  begin
    btnCancelClick(Self);
    Key := 0;
  end;    
end;

//------------------------------------------------------------------------------

procedure TVCSAddSharedModule.SelectProject;
var 
  LVItem: TListItem;
begin
  Caption := JVCSRES_Share_a_module_45_146_Select_project;
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
    ListView1.Items.BeginUpdate;
    try
      ListView1.Items.Clear;
      ListView1.MultiSelect := False;
      while not AppSrvClient1.Answer.Eof do
      begin
        if AppSrvClient1.Answer.Fields[2] <> '1' then
        begin
          if (DefaultID = 0) or
            (_StrToInt(AppSrvClient1.Answer.Fields[0]) <> DefaultID) then
          begin
            LVItem := ListView1.Items.Add;
            LVItem.Caption := AppSrvClient1.Answer.Fields[1];
            LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[0]);
          end; // if (DefaultID = 0) or
        end; // if AppSrvClient1.Answer.Fields[2] <> '1' then begin
        AppSrvClient1.Answer.Next;
      end;
      ListView1.Column[0].Caption := JVCSRES_Project;
    finally
      ListView1.Items.EndUpdate;
    end;
    if ListView1.Items.Count > 0 then
      ListView1.Items[0].Selected := True;
  end; // with DataModule1 do begin
  Side := 1;
  btnOK.Enabled := False;
end;

//------------------------------------------------------------------------------

procedure TVCSAddSharedModule.SelectModule;
var
  LVItem: TListItem;
begin
  Caption := JVCSRES_Share_a_module_45_246_Select_module;
  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_PROJECT_MODULE_LIST';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [IDBuffer]);
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
    ListView1.Items.BeginUpdate;
    try
      ListView1.Items.Clear;
      ListView1.MultiSelect := True;
      while not AppSrvClient1.Answer.Eof do 
      begin
        LVItem := ListView1.Items.Add;
        if FileExists(AppSrvClient1.Answer.Fields[2] + AppSrvClient1.Answer.Fields[1]) then
          LVItem.Caption := ExtractFileName(GetOriginalFileName(AppSrvClient1.Answer.Fields[2] +
            AppSrvClient1.Answer.Fields[1]))
        else
          LVItem.Caption := AppSrvClient1.Answer.Fields[1];
        LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[0]);
        {$IFDEF CUSTOMDRIVE}
        LVItem.SubItems.Add(ChangeDriveName(AppSrvClient1.Answer.Fields[2], sDriveSubst));
        {$ELSE}
        LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[2]);
        {$ENDIF CUSTOMDRIVE}
        AppSrvClient1.Answer.Next;
      end;
      ListView1.Column[0].Caption := Format(JVCSRES_Modules_in_37s, [SelectedProject]);
    finally
      ListView1.Items.EndUpdate;
    end;
    if ListView1.Items.Count > 0 then
      ListView1.Items[0].Selected := True;
  end; // with DataModule1 do begin}
  Side := 2;
  btnOK.Enabled := True;
end;

//------------------------------------------------------------------------------

procedure TVCSAddSharedModule.FormResize(Sender: TObject);
begin
  {$IFNDEF SHOWIDS}
  ListView1.Columns[0].Width := Width - 35;
  {$ENDIF ~SHOWIDS}
end;

//------------------------------------------------------------------------------

procedure TVCSAddSharedModule.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  jvcsWriteWindowSize(sBaseRegistryKey + crbWindows, 'AddSharedModule',
    Height, Width);
end;

//------------------------------------------------------------------------------

procedure TVCSAddSharedModule.FormDestroy(Sender: TObject);
begin
  SelectedModules.Free;
end;

//------------------------------------------------------------------------------

procedure TVCSAddSharedModule.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyUp(Self, HelpKey, []);
end;

end.
