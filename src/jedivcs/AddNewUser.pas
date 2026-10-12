(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: AddNewUser.pas

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
2003/12/27  USchuster - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use constant)
2004/02/23  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/03  THuber    - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/10/08  THuber    - use jvcl msgBoxes
                      - resourcestring now in JVCSGUIClientResources
2007/06/25  USchuster - changes for large fonts (set AutoScroll to False)
2007/06/30  USchuster - changes for large fonts (added contraints)
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit AddNewUser;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Forms, StdCtrls, Buttons, Controls,
  ExtCtrls, JVCSForms;

type
  TVCSAddUser = class(TJVCSForm)
    pnlButton: TPanel;
    gbDescription: TGroupBox;
    pnlHead: TPanel;
    Help: TSpeedButton;
    btnOK: TButton;
    btnCancel: TButton;
    meDescription: TMemo;
    Label1: TLabel;
    edUser: TEdit;
    cbLevel: TComboBox;
    Label4: TLabel;
    edPW: TEdit;
    Label3: TLabel;
    Label5: TLabel;
    edPW2: TEdit;
    Label6: TLabel;
    edIP: TEdit;
    spBtnEditIP: TSpeedButton;
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edUserChange(Sender: TObject);
    procedure spBtnEditIPClick(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UserName,
    UserPW,
    UserIP, 
    UserDescr: string;
    UserLevel: Integer;
  end;

var
  VCSAddUser: TVCSAddUser;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSProcBase, VCSBase, EditIP, ConfigStorage, JvJVCLUtils, JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSAddUser.FormCreate(Sender: TObject);
begin
  try
    Constraints.MinHeight := MulDiv(261, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(274, PixelsPerInch, 96);
    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);
    UserName := '';
    UserPW := '';
    UserIP := '';
    UserDescr := '';
    UserLevel := 1;
    edIP.Text := '0';
    cbLevel.ItemIndex := 0;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSAddUser.btnOKClick(Sender: TObject);
begin
  if Length(edUser.Text) < 2 then
  begin
    MsgWarn ( WindowHandle
            , JVCSRES_User_names_must_be_at_least_2_characters46 + #13+#10 +
              JVCSRES_Please_enter_a_valid_user_name46
            , cMsgBoxCaption
            );
    edUser.SetFocus;
    edUser.SelectAll;
    Exit;
  end;
  if Length(edPW.Text) < 5 then
  begin
    MsgWarn ( WindowHandle
            , JVCSRES_Passwords_must_be_at_least_5_characters46 + #13+#10+
              JVCSRES_Please_re45enter_the_password46
            , cMsgBoxCaption
            );
    edPW.Text := '';
    edPW2.Text := '';
    edPW.SetFocus;
    Exit;
  end;
  if edPW.Text <> edPW2.Text then
  begin
    MsgWarn ( WindowHandle
            , JVCSRES_Password_does_not_match_confirmation46 +#13+#10+
              JVCSRES_Please_re45enter_the_password46
            , cMsgBoxCaption
            );
    edPW.Text := '';
    edPW2.Text := '';
    edPW.SetFocus;
    Exit;
  end;
  UserName := edUser.Text;
  UserPW := edPW.Text;
  UserIP := edIP.Text;
  UserDescr := meDescription.Text;
  UserLevel := cbLevel.ItemIndex;
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSAddUser.btnCancelClick(Sender: TObject);
begin
  UserName := '';
  UserPW := '';
  UserIP := '';
  UserDescr := '';
  UserLevel := 1;
  cbLevel.ItemIndex := 0;
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSAddUser.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_VC_Administrator);
  if Key = VK_ESCAPE then 
  begin
    btnCancelClick(Self);
    Key := 0;
  end;    
end;

procedure TVCSAddUser.edUserChange(Sender: TObject);
begin
  btnOK.Enabled := (edUser.Text <> '') and
    (edPW.Text <> '') and
    (edPW2.Text <> '');
end;

//------------------------------------------------------------------------------

procedure TVCSAddUser.spBtnEditIPClick(Sender: TObject);
begin
  VCSEditIP := TVCSEditIP.Create(Application);
  try
    VCSEditIP.Left := Left + 40;
    VCSEditIP.Top := Top + 40;
    VCSEditIP.IPAddress := edIP.Text;
    if VCSEditIP.ShowModal = mrOk then
      edIP.Text := VCSEditIP.IPAddress;
  finally
    VCSEditIP.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSAddUser.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

procedure TVCSAddUser.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  jvcsSaveFormPosSize(Self);
end;

procedure TVCSAddUser.FormShow(Sender: TObject);
begin
  jvcsLoadFormPosSize(Self);
end;

end.
