(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: Password.pas

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
2003/11/19  USchuster - changed 'FreeVCS' in messageboxes to 'JEDI VCS'
                        with constant cMsgBoxCaption from VCSBase.pas
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/24  USchuster - style cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/11/02  USchuster - moved resourcestrings to JVCSGUIClientResources.pas                      
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit Password;

// Added by F. Libaud
{$ifdef FPC}
  {$MODE DELPHI}
{$endif}

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, JVCSForms;

type
  TVCSPassword = class(TJVCSForm)
    btnOK: TButton;
    btnCancel: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    edPW: TEdit;
    Label2: TLabel;
    edVerify: TEdit;
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
    GetPassword: Boolean;
    DlgCaption,
    Password: string;
  end;

var
  VCSPassword: TVCSPassword;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSBase, JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSPassword.FormCreate(Sender: TObject);
begin
  try
    Password := '';
    GetPassword := False;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

procedure TVCSPassword.FormActivate(Sender: TObject);
begin
  Caption := DlgCaption;
  if GetPassword then 
  begin
    Label2.Enabled := False;
    edVerify.Enabled := False;
    edVerify.Color := clBtnFace;
  end;
end;

procedure TVCSPassword.btnOKClick(Sender: TObject);
begin
  if GetPassword then
  begin
    Password := edPW.Text;
    ModalResult := mrOk;
  end
  else
  begin
    if edPW.Text <> edVerify.Text then
    begin
      MessageBeep(0);
      MessageBox(WindowHandle, PChar(JVCSRES_Password_does_not_match_confirmation46 + #13#10 +
        JVCSRES_Please_re45enter_the_password46), cMsgBoxCaption,
        MB_OK or MB_ICONWARNING);
      edPW.Text := '';
      edVerify.Text := '';
      edPW.SetFocus;
    end
    else
    begin
      Password := edPW.Text;
      ModalResult := mrOk;
    end;
  end; // else if GetPassword then begin
end;

end.
