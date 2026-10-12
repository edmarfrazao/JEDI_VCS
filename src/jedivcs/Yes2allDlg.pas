(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: Yes2allDlg.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS: Thomas Huber (Thomas_D_Huber@gmx.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FreeVCS code to JEDI-VCS
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/05  USchuster - style cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/10/31  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
2007/06/05  USchuster - as of now the icon will be replaced with the OS icon                      
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit Yes2allDlg;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, JVCSForms;

type
  TVCSYes2AllDlg = class(TJVCSForm)
    Label1: TLabel;
    btnYes: TButton;
    btnYesAll: TButton;
    btnNo: TButton;
    btnCancel: TButton;
    Image1: TImage;
    CheckBox1: TCheckBox;
    procedure btnYesClick(Sender: TObject);
    procedure btnYesAllClick(Sender: TObject);
    procedure btnNoClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
  private
    { Private declarations }
    YesAllState: Boolean;
  public
    { Public declarations }
    CheckBoxChecked: Boolean;
    procedure SetMessageText(const Value: string);
    procedure EnableYes2All(const Value: Boolean);
    procedure ShowCheckBox(const Value: Boolean);
    procedure SetCheckBoxCaption(const Value: string);
  end;

var
  VCSYes2AllDlg: TVCSYes2AllDlg;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSYes2AllDlg.SetMessageText(const Value: string);
begin
  Label1.Caption := Value;
end;

procedure TVCSYes2AllDlg.EnableYes2All(const Value: Boolean);
begin
  btnYesAll.Enabled := Value;
  YesAllState := Value;
end;

procedure TVCSYes2AllDlg.ShowCheckBox(const Value: Boolean);
begin
  CheckBox1.Enabled := Value;
end;

procedure TVCSYes2AllDlg.SetCheckBoxCaption(const Value: string);
begin
  CheckBox1.Caption := Value;
end;

procedure TVCSYes2AllDlg.btnYesClick(Sender: TObject);
begin
  CheckBoxChecked := CheckBox1.Checked;
  ModalResult := mrYes;
end;

procedure TVCSYes2AllDlg.btnYesAllClick(Sender: TObject);
begin
  CheckBoxChecked := CheckBox1.Checked;
  ModalResult := mrAll;
end;

procedure TVCSYes2AllDlg.btnNoClick(Sender: TObject);
begin
  CheckBoxChecked := CheckBox1.Checked;
  ModalResult := mrNo;
end;

procedure TVCSYes2AllDlg.btnCancelClick(Sender: TObject);
begin
  CheckBoxChecked := CheckBox1.Checked;
  ModalResult := mrCancel;
end;

procedure TVCSYes2AllDlg.FormCreate(Sender: TObject);
begin
  try
    Image1.Picture.Icon.Handle := LoadIcon(0, IDI_QUESTION);
    CheckBoxChecked := False;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

procedure TVCSYes2AllDlg.CheckBox1Click(Sender: TObject);
begin
  if CheckBox1.Caption = JVCSRES_38Don39t_ask_me_further_about_this_file46 then 
  begin
    btnYes.Enabled := not CheckBox1.Checked;
    btnYesAll.Enabled := (not CheckBox1.Checked) and YesAllState;
  end;
end;

end.
