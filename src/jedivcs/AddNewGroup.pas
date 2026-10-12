(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: AddNewGroup.pas

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
2003/08/02  THuber    - mantis #861: replaced TMemo with TJvMemo
                      - better layout (form now sizable)
                      - help button
                      ... taborder, formstorage
2004/02/23  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/03  THuber    - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
2004/10/13  USchuster - mantis #2205
2007/06/25  USchuster - changes for large fonts (set AutoScroll to False)
2007/07/01  USchuster - changes for large fonts (added contraints)
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit AddNewGroup;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Forms, StdCtrls, Controls,
  JvMemo, Buttons, ExtCtrls, JvExStdCtrls, JVCSForms;

type
  TVCSAddNewGroup = class(TJVCSForm)
    pnlButton: TPanel;
    Help: TSpeedButton;
    btnOK: TButton;
    btnCancel: TButton;
    gbDEscription: TGroupBox;
    meDescription: TJvMemo;
    pnlHead: TPanel;
    lblParent: TLabel;
    edParent: TEdit;
    Label1: TLabel;
    edName: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure edNameChange(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    NewName,
    NewDescription: string;
    procedure SetupInfo(const DlgCaption, DlgLabel, DlgEdit: string);
    procedure SetupValues(const CurrentName, CurrentDescription: string);
  end;

var
  VCSAddNewGroup: TVCSAddNewGroup;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSProcBase, VCSBase, ConfigStorage;

{$R *.dfm}

procedure TVCSAddNewGroup.FormCreate(Sender: TObject);
begin
  try
    Constraints.MinHeight := MulDiv(227, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(264, PixelsPerInch, 96);
    NewName := '';
    NewDescription := '';
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

procedure TVCSAddNewGroup.SetupInfo(const DlgCaption, DlgLabel, DlgEdit: string);
begin
  Caption := DlgCaption;
  lblParent.Caption := DlgLabel;
  edParent.Text := DlgEdit;
end;

procedure TVCSAddNewGroup.SetupValues(const CurrentName,
  CurrentDescription: string);
begin
  edName.Text := CurrentName;
  meDescription.Text := CurrentDescription;
  edName.SelectAll;
end;

procedure TVCSAddNewGroup.btnOKClick(Sender: TObject);
begin
  NewName := edName.Text;
  NewDescription := meDescription.Text;
  Close;
end;

procedure TVCSAddNewGroup.btnCancelClick(Sender: TObject);
begin
  NewName := '';
  NewDescription := '';
  Close;
end;

procedure TVCSAddNewGroup.edNameChange(Sender: TObject);
begin
  btnOK.Enabled := (edName.Text <> '');
end;

procedure TVCSAddNewGroup.HelpClick(Sender: TObject);
var
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

procedure TVCSAddNewGroup.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Project_Administration);
  if Key = VK_ESCAPE then
  begin
    btnCancelClick(Self);
    Key := 0;
  end;
end;

procedure TVCSAddNewGroup.FormShow(Sender: TObject);
begin
  jvcsLoadFormPosSize(Self);
end;

procedure TVCSAddNewGroup.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  jvcsSaveFormPosSize(Self);
end;

end.
