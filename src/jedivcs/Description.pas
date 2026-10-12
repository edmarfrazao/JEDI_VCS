(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: Description.pas

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
2003/08/03  THuber    - mantis #861: replaced TMemo with TJvMemo
                      - FormStorage changed in configStorage
2003/12/28  USchuster - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use constant)
2004/02/24  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/31  USchuster - style cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/11/05  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
2007/06/17  USchuster - fixed self handled shortcuts
2007/07/01  USchuster - changes for large fonts (contraints size depend now on PixelsPerInch; analog to Mantis #3710)
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit Description;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, JvMemo, JvExStdCtrls, JVCSForms;

type
  TVCSDescription = class(TJVCSForm)
    meDescription: TJvMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    lblDescript: TLabel;
    cbSkip: TCheckBox;
    Label1: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    Help: TSpeedButton;
    spBtnGetLDescr: TSpeedButton;
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure HelpClick(Sender: TObject);
    procedure spBtnGetLDescrClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Description: string;
    DescType: Byte;
    cbState: Boolean;
    ModRes: Integer;
    procedure SetDescripCaption(const Value: string);
    procedure SetDescription(const Value: string);
    procedure EnableCheckBox(const Value: Boolean);
  end;

var
  VCSDescription: TVCSDescription;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSBase, VCSProcBase, ConfigStorage, JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSDescription.FormCreate(Sender: TObject);
//thu 03.08.2003
{
var
  DlgWidth, DlgHeight: integer;
 }
begin
  try
    Constraints.MinHeight := MulDiv(190, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(350, PixelsPerInch, 96);
    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    //thu 03.08.2003
    { 
    if not jvcsReadWindowSize(sBaseRegistryKey + crbWindows, 'Description',
      DlgWidth, DlgHeight) then
    begin
      DlgWidth := 350;
      DlgHeight := 190;
    end;
    Width := DlgWidth;
    Height := DlgHeight;
     }

    Description := '';
    cbState := False;
    ModRes := mrCancel;
    DescType := 0;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSDescription.FormActivate(Sender: TObject);
begin
  case DescType of
    1: 
      Caption := JVCSRES_Project_Description;
    2: 
      Caption := JVCSRES_Module_Description;
    3:
      Caption := JVCSRES_Milestone_40reached41_Description;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSDescription.SetDescripCaption(const Value: string);
begin
  lblDescript.Caption := Value;
end;

//------------------------------------------------------------------------------

procedure TVCSDescription.SetDescription(const Value: string);
begin
  meDescription.Text := Value;
  meDescription.Modified := False;
end;

//------------------------------------------------------------------------------

procedure TVCSDescription.EnableCheckBox(const Value: Boolean);
begin
  cbSkip.Visible := Value;
  Label1.Visible := Value;
end;

//------------------------------------------------------------------------------

procedure TVCSDescription.btnOKClick(Sender: TObject);
begin
  Description := meDescription.Text;
  if Description <> '' then
    jvcsWriteString(sBaseRegistryKey + crbMRU, 'Description' + IntToStr(DescType),
      Description);
  cbState := cbSkip.Checked;
  ModRes := mrOk;
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSDescription.btnCancelClick(Sender: TObject);
var
  DlgResult: Integer;
begin
  if meDescription.Modified then
  begin
    DlgResult := MessageBox(WindowHandle, PChar(JVCSRES_You_have_made_changes_that_have_not_been_applied46 + #13#10 +
      JVCSRES_Do_you_want_to_apply_these_now63), cMsgBoxCaption,
      MB_YESNOCANCEL or MB_ICONQUESTION);
    case DlgResult of
      id_Yes:
        Description := meDescription.Text;
      id_No:
        Description := '';
      id_Cancel:
        Exit;
    end;
  end;
  cbState := cbSkip.Checked;
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSDescription.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Module_project_description);
  if Key = VK_ESCAPE then
  begin
    btnCancel.Click;
    Key := 0;
  end;
  if (Shift * [ssShift, ssAlt, ssCtrl] = [ssCtrl]) and (Chr(Key) in ['L', 'l']) then
    if (not CtrlSCDisabled(WindowHandle)) then
      spBtnGetLDescrClick(Self);
end;

//------------------------------------------------------------------------------

procedure TVCSDescription.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  //thu 03.08.2003
  { 
  jvcsWriteWindowSize(sBaseRegistryKey + crbWindows, 'Description',
    Width, Height);
   }
  jvcsSaveFormPosSize(Self);
end;

//------------------------------------------------------------------------------

procedure TVCSDescription.HelpClick(Sender: TObject);
var
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSDescription.spBtnGetLDescrClick(Sender: TObject);
var
  LastDescription: string;
begin
  LastDescription :=
    jvcsReadString(sBaseRegistryKey + crbMRU, 'Description' + IntToStr(DescType), '');
  if LastDescription <> '' then
    meDescription.Text := LastDescription
  else
    MessageBox(WindowHandle, PChar(Format(JVCSRES_MRU_item_6037s62_is_blank46,
      [JVCSRES_Last_Description])), cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
end;

procedure TVCSDescription.FormShow(Sender: TObject);
begin
  jvcsLoadFormPosSize(Self);
end;

end.
