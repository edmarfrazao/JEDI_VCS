(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: AddNewBug.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS:
  Thomas Huber (Thomas_D_Huber@gmx.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FreeVCS code to JEDI VCS
2003/03/01  THensle   - changes for "ConfigStorage" unit
2003/08/02  THuber    - mantis #861: replaced TMemo with TJvMemo
                      - better layout (form now sizable)
                      ... Taborder, FormStorage changed
2004/02/23  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/04/17  USchuster - restricted minimum size in form
                      - minor style cleaning (casing and comments)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/03  THuber    - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
2004/10/13  USchuster - mantis #2205
2007/06/25  USchuster - changes for large fonts (set AutoScroll to False)
2007/07/01  USchuster - changes for large fonts (contraints size depend now on PixelsPerInch; analog to Mantis #3710)                         
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit AddNewBug;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Forms, StdCtrls, Buttons, Controls,
  JvMemo, ExtCtrls, JvExStdCtrls, JVCSForms;

type
  TVCSAddBug = class(TJVCSForm)
    gbWorkaround: TGroupBox;
    pnlButtons: TPanel;
    Help: TSpeedButton;
    btnOK: TButton;
    btnCancel: TButton;
    meWorkaround: TJvMemo;
    gbDesription: TGroupBox;
    meDescription: TJvMemo;
    pnlBugHead: TPanel;
    Label1: TLabel;
    edBug: TEdit;
    Label4: TLabel;
    cbLevel: TComboBox;
    cbxStatus: TComboBox;
    Label7: TLabel;
    edKeywords: TEdit;
    Label3: TLabel;
    Label5: TLabel;
    edReported: TEdit;
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edBugChange(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    BugName,
    BugKeywords,
    BugDescr,
    ReportedBy,
    Workaround: string;
    Severity,
    Status: Integer;
  end;

var
  VCSAddBug: TVCSAddBug;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSProcBase, VCSBase, ConfigStorage;

{$R *.dfm}

procedure TVCSAddBug.FormCreate(Sender: TObject);
begin
  try
    Constraints.MinHeight := MulDiv(380, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(290, PixelsPerInch, 96);
    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);
    BugName := '';
    BugKeywords := '';
    ReportedBy := '';
    Workaround := '';
    Status := 0;
    Severity := 0;
    cbLevel.ItemIndex := 0;
    cbxStatus.ItemIndex := 0;
    edReported.Text := sCurrentUser;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSAddBug.btnOKClick(Sender: TObject);
begin
  BugName := edBug.Text;
  BugKeywords := edKeywords.Text;
  BugDescr := meDescription.Text;
  Severity := cbLevel.ItemIndex;
  ReportedBy := edReported.Text;
  Workaround := meWorkaround.Text;
  Status := cbxStatus.ItemIndex;
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSAddBug.btnCancelClick(Sender: TObject);
begin
  BugName := '';
  BugKeywords := '';
  BugDescr := '';
  ReportedBy := '';
  Workaround := '';
  Status := 0;
  Severity := 0;
  cbLevel.ItemIndex := 0;
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSAddBug.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Bug_tracking);
  if Key = VK_ESCAPE then
  begin
    btnCancelClick(Self);
    Key := 0;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSAddBug.edBugChange(Sender: TObject);
begin
  btnOK.Enabled := (edBug.Text <> '');
end;

//------------------------------------------------------------------------------

procedure TVCSAddBug.HelpClick(Sender: TObject);
var
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

procedure TVCSAddBug.FormShow(Sender: TObject);
begin
  jvcsLoadFormPosSize(Self);
end;

procedure TVCSAddBug.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  jvcsSaveFormPosSize(Self);
end;

end.
