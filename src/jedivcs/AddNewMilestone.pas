(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: AddNewMilestone.pas

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
2003/03/02  THensle   - changes for "ConfigStorage" unit
2003/08/02  THuber    - mantis #861: replaced TMemo with TJvMemo
                      - better layout (form now sizable)
                      - FormStorage changed in configStorage
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

unit AddNewMilestone;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Forms, StdCtrls, Buttons,
  Controls, ExtCtrls, JvMemo, JvExStdCtrls, JVCSForms;

type
  TVCSAddMilestone = class(TJVCSForm)
    pnlButton: TPanel;
    Help: TSpeedButton;
    btnOK: TButton;
    btnCancel: TButton;
    gbDescription: TGroupBox;
    pnlHead: TPanel;
    meDescription: TJvMemo;
    Label1: TLabel;
    edMilestone: TEdit;
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edMilestoneChange(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    MilestoneName,
    MilestoneDescr: string;
  end;

var
  VCSAddMilestone: TVCSAddMilestone;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSProcBase, VCSBase, ConfigStorage, JvJVCLUtils, JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSAddMilestone.FormCreate(Sender: TObject);
begin
  try
    Constraints.MinHeight := MulDiv(220, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(270, PixelsPerInch, 96);
    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);
    MilestoneName := '';
    MilestoneDescr := '';
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSAddMilestone.btnOKClick(Sender: TObject);
begin
  MilestoneName := edMilestone.Text;
  MilestoneDescr := meDescription.Text;
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSAddMilestone.btnCancelClick(Sender: TObject);
begin
  MilestoneName := '';
  MilestoneDescr := '';
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSAddMilestone.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    btnCancel.Click;
    Key := 0;
  end;
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Milestones);
end;

//------------------------------------------------------------------------------

procedure TVCSAddMilestone.edMilestoneChange(Sender: TObject);
begin
  btnOK.Enabled := edMilestone.Text <> '';
end;

//------------------------------------------------------------------------------

procedure TVCSAddMilestone.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

procedure TVCSAddMilestone.FormShow(Sender: TObject);
begin
  jvcsLoadFormPosSize(Self);
end;

procedure TVCSAddMilestone.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  jvcsSaveFormPosSize(Self);
end;

end.
