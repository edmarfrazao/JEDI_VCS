(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: ChangeUserPW.pas

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
2003/03/03  THensle   - changes for "ConfigStorage" unit
2003/12/27  USchuster - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use constant)
2004/02/24  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/09  THuber    - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
                      - use jvcl msgBoxes
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit ChangeUserPW;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, JvEdit, JvExStdCtrls, JVCSForms;

type
  TVCSChangeUserPW = class(TJVCSForm)
    Label1 : TLabel;
    btnOK : TButton;
    btnCancel : TButton;
    Label3 : TLabel;
    Label5 : TLabel;
    lblUser : TLabel;
    Help : TSpeedButton;
    pwedOldPW : TJvEdit;
    pwedPW : TJvEdit;
    pwedPW2 : TJvEdit;
    procedure btnOKClick(Sender : TObject);
    procedure FormCreate(Sender : TObject);
    procedure btnCancelClick(Sender : TObject);
    procedure FormShow(Sender : TObject);
    procedure edOldPWChange(Sender : TObject);
    procedure HelpClick(Sender : TObject);
    procedure FormKeyDown(Sender : TObject; var Key : word;
      Shift : TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
    OldPassword,
    NewPassword,
    User : string;
  end;

var
  VCSChangeUserPW : TVCSChangeUserPW;

implementation

uses
    VCSProcBase
  , VCSBase
  , ConfigStorage
  , JvJVCLUtils
  , JVCSGUIClientResources
{$IFDEF LANGUAGE}
  , JvGnugettext
{$ENDIF LANGUAGE}
  ;

{$R *.DFM}


procedure TVCSChangeUserPW.FormCreate(Sender : TObject);
begin
  try
    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', true);
    OldPassword := '';
    NewPassword := '';
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(self);
    {$ENDIF LANGUAGE}
  end;
end;
(******************************************************************************

 ******************************************************************************)

procedure TVCSChangeUserPW.FormShow(Sender : TObject);
begin
  lblUser.Caption := Format(JVCSRES_User58_37s, [User]);
end;
(******************************************************************************

 ******************************************************************************)

procedure TVCSChangeUserPW.btnOKClick(Sender : TObject);
begin
  if Length(pwedPW.Text) < 5 then
  begin
    MsgWarn ( WindowHandle
            , JVCSRES_Passwords_must_be_at_least_5_characters46 +#13+#10+
              JVCSRES_Please_re45enter_the_password46
            , cMsgBoxCaption
            );
    pwedPW.Text := '';
    pwedPW2.Text := '';
    pwedPW.SetFocus;
    Exit;
  end;
  if pwedPW.Text <> pwedPW2.Text then
  begin
    MsgWarn ( WindowHandle
            , JVCSRES_Password_does_not_match_confirmation46
            , cMsgBoxCaption
            );
    pwedPW.Text := '';
    pwedPW2.Text := '';
    pwedPW.SetFocus;
    Exit;
  end;
  OldPassword := pwedOldPW.Text;
  NewPassword := pwedPW.Text;
  Close;
end;
(******************************************************************************

 ******************************************************************************)

procedure TVCSChangeUserPW.btnCancelClick(Sender : TObject);
begin
  OldPassword := '';
  NewPassword := '';
  Close;
end;
(******************************************************************************

 ******************************************************************************)

procedure TVCSChangeUserPW.edOldPWChange(Sender : TObject);
begin
  btnOK.Enabled := (pwedOldPW.Text <> '') and
    (pwedPW.Text <> '') and (pwedPW2.Text <> '');
end;
(******************************************************************************

 ******************************************************************************)

procedure TVCSChangeUserPW.HelpClick(Sender : TObject);
var 
  HelpKey : word;
begin
  HelpKey := vk_F1;
  FormKeyDown(self, HelpKey, []);
end;
(******************************************************************************

 ******************************************************************************)

procedure TVCSChangeUserPW.FormKeyDown(Sender : TObject; var Key : word;
  Shift : TShiftState);
begin
  if Key = vk_F1 then
    PerformHelpCommand(Application, IDH_VC_Administrator);
end;

end.
