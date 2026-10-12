(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: AddNewCompareTool.pas

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
2003/03/08  USchuster - exchanged THistoryList with TJVCSMruList (mantis #727)
2004/02/23  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
                      - use TJvFilenameEdit now, removed favopendialog
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/08  THuber    - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
2004/10/13  USchuster - mantis #2205
2007/06/25  USchuster - changes for large fonts (set AutoScroll to False and changed contraints)                        
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit AddNewCompareTool;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Forms, Dialogs, Buttons, StdCtrls,
  Controls, Mask, JvExMask, JvToolEdit, JVCSForms;

type
  TVCSAddCompareTool = class(TJVCSForm)
    Label2: TLabel;
    Label6: TLabel;
    edPath: TJvFilenameEdit;
    Label1: TLabel;
    edName: TEdit;
    edParam: TEdit;
    btnCancel: TButton;
    btnOK: TButton;
    Help: TSpeedButton;
    procedure edNameChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    ToolName,
    ToolPath,
    ToolParam: string;
  end;

var
  VCSAddCompareTool: TVCSAddCompareTool;

implementation

{$R *.dfm}

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSBase, VCSProcBase, ConfigStorage, JvJVCLUtils, JVCSGUIClientResources;

procedure TVCSAddCompareTool.FormShow(Sender: TObject);
begin
  edName.Text := ToolName;
  edPath.Text := ToolPath;
  edParam.Text := ToolParam;
end;

procedure TVCSAddCompareTool.btnOKClick(Sender: TObject);
begin
  ToolName := edName.Text;
  ToolPath := edPath.Text;
  ToolParam := edParam.Text;
  Close;
end;

procedure TVCSAddCompareTool.btnCancelClick(Sender: TObject);
begin
  ToolName := '';
  ToolPath := '';
  ToolParam := '';
  Close;
end;

procedure TVCSAddCompareTool.edNameChange(Sender: TObject);
begin
  btnOK.Enabled := (edName.Text <> '') and
    (edPath.Text <> '') and
    (edParam.Text <> '');
end;

procedure TVCSAddCompareTool.HelpClick(Sender: TObject);
begin
  PerformHelpCommand(Application, IDH_External_compare);
end;

procedure TVCSAddCompareTool.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_External_compare);
end;

procedure TVCSAddCompareTool.FormCreate(Sender: TObject);
begin
  try
    Constraints.MinHeight := Height;
    Constraints.MaxHeight := Height;
    Constraints.MinWidth := Width;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

end.
