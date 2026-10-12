(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: SelectDrive.pas

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
2003/07/28  THuber    - Cosmetic text changes
2004/02/24  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/17  USchuster - style cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit SelectDrive;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, JvCombobox, JvDriveCtrls, JvExStdCtrls,
  JVCSForms;

type
  TVCSSelectDrive = class(TJVCSForm)
    Label1: TLabel;
    lblSearchFor: TLabel;
    Label3: TLabel;
    btnCancel: TButton;
    JvDriveCombo: TJvDriveCombo;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    SelectedDrive: Char;
    procedure SetLabelCaption(const Value: string);
  end;

var
  VCSSelectDrive: TVCSSelectDrive;

implementation

{$IFDEF LANGUAGE}
uses
  JvGnugettext;
{$ENDIF LANGUAGE}

{$R *.dfm}

procedure TVCSSelectDrive.FormCreate(Sender: TObject);
begin
  try
    lblSearchFor.Caption := '';
    SelectedDrive := '#';
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectDrive.SetLabelCaption(const Value: string);
begin
  lblSearchFor.Caption := Value;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectDrive.Button1Click(Sender: TObject);
begin
  SelectedDrive := JvDriveCombo.Drive;
  ModalResult := mrOk;
end;

end.
