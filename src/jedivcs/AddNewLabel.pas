(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: AddNewLabel.pas

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

2003/01/31  THuber    - 1st Migrationstep from FreeVCS code to JEDI-VCS
2003/03/02  THensle   - changes for "ConfigStorage" unit
2003/08/02  THuber    - mantis #861: replaced TMemo with TJvMemo
                      - better layout (form now sizable)
                      - FormStorage changed in configStorage
2004/04/17  USchuster - restricted minimum size in form
                      - minor style cleaning (casing and comments)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/03  THuber    - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
2007/06/25  USchuster - changes for large fonts (set AutoScroll to False)
2007/07/01  USchuster - changes for large fonts (contraints size depend now on PixelsPerInch; analog to Mantis #3710)                        
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit AddNewLabel;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Forms, StdCtrls, Buttons, Controls,
  ExtCtrls, JVCSForms;

type
  TVCSAddLabel = class(TJVCSForm)
    pnlButton: TPanel;
    Help: TSpeedButton;
    btnOK: TButton;
    btnCancel: TButton;
    gbDescription: TGroupBox;
    meDescription: TMemo;
    pnlHead: TPanel;
    Label1: TLabel;
    edLabel: TEdit;
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edLabelChange(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    LabelName,
    LabelDescr: string;
  end;

var
  VCSAddLabel: TVCSAddLabel;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSBase, VCSProcBase, ConfigStorage;

{$R *.dfm}

procedure TVCSAddLabel.FormCreate(Sender: TObject);
begin
  try
    Constraints.MinHeight := MulDiv(220, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(270, PixelsPerInch, 96);
    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);
    LabelName := '';
    LabelDescr := '';
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

procedure TVCSAddLabel.btnOKClick(Sender: TObject);
begin
  LabelName := edLabel.Text;
  LabelDescr := meDescription.Text;
  Close;
end;

procedure TVCSAddLabel.btnCancelClick(Sender: TObject);
begin
  LabelName := '';
  LabelDescr := '';
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSAddLabel.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Keywords);
  if Key = VK_ESCAPE then
  begin
    btnCancelClick(Self);
    Key := 0;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSAddLabel.edLabelChange(Sender: TObject);
begin
  btnOK.Enabled := edLabel.Text <> '';
end;

//------------------------------------------------------------------------------

procedure TVCSAddLabel.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

procedure TVCSAddLabel.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  jvcsSaveFormPosSize(Self);
end;

procedure TVCSAddLabel.FormShow(Sender: TObject);
begin
  //thu 03.08.2003
  jvcsLoadFormPosSize(Self);
end;

end.
