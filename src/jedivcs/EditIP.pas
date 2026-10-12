(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: EditIP.pas

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
2003/03/05  THensle   - changes for "ConfigStorage" unit
2003/12/28  USchuster - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use constant)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/30  USchuster - style cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/11/05  USchuster - moved resourcestrings to JVCSGUIClientResources.pas                      
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit EditIP;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, JVCSForms;

type
  TVCSEditIP = class(TJVCSForm)
    rbFree: TRadioButton;
    rbRestricted: TRadioButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    Label4: TLabel;
    Help: TSpeedButton;
    procedure rbFreeClick(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure Edit2Change(Sender: TObject);
    procedure Edit3Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    FCreating: Boolean;
  public
    { Public declarations }
    IPAddress: string;
  end;

var
  VCSEditIP: TVCSEditIP;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSProcBase, VCSBase, ConfigStorage, JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSEditIP.FormCreate(Sender: TObject);
begin
  try
    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);
    IPAddress := '0';
    FCreating := True;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

procedure TVCSEditIP.FormActivate(Sender: TObject);
var
  IP: string;
begin
  if FCreating then 
  begin
    rbFree.Checked := (IPAddress = '0');
    rbRestricted.Checked := not rbFree.Checked;
    if rbFree.Checked then 
      rbFreeClick(Self);
    if IPAddress <> '0' then 
    begin
      IP := IPAddress;
      Edit1.Text := Copy(IP, 1, Pos('.', IP) - 1);
      Delete(IP, 1, Pos('.', IP));
      Edit2.Text := Copy(IP, 1, Pos('.', IP) - 1);
      Delete(IP, 1, Pos('.', IP));
      Edit3.Text := Copy(IP, 1, Pos('.', IP) - 1);
      Delete(IP, 1, Pos('.', IP));
      Edit4.Text := IP;
    end;
    FCreating := False;
  end; // if FCreating then begin
end;

procedure TVCSEditIP.rbFreeClick(Sender: TObject);
begin
  Edit1.Enabled := not rbFree.Checked;
  Edit2.Enabled := not rbFree.Checked;
  Edit3.Enabled := not rbFree.Checked;
  Edit4.Enabled := not rbFree.Checked;
  if rbFree.Checked then 
  begin
    Edit1.Color := clBtnFace;
    Edit2.Color := clBtnFace;
    Edit3.Color := clBtnFace;
    Edit4.Color := clBtnFace;
  end 
  else 
  begin
    Edit1.Color := clWindow;
    Edit2.Color := clWindow;
    Edit3.Color := clWindow;
    Edit4.Color := clWindow;
  end;
  Label4.Enabled := not rbFree.Checked;
end;

procedure TVCSEditIP.Edit1Change(Sender: TObject);
begin
  if FCreating then 
    Exit;
  if Length(Edit1.Text) = 3 then 
    Edit2.SetFocus;
end;

procedure TVCSEditIP.Edit2Change(Sender: TObject);
begin
  if FCreating then
    Exit;
  if Length(Edit2.Text) = 3 then 
    Edit3.SetFocus;
end;

procedure TVCSEditIP.Edit3Change(Sender: TObject);
begin
  if FCreating then 
    Exit;
  if Length(Edit3.Text) = 3 then 
    Edit4.SetFocus;
end;


procedure TVCSEditIP.btnOKClick(Sender: TObject);
var 
  IPPart: Integer;

  function CheckNumber(const ED: TEdit; var Value: Integer): Boolean;
  var
    ValErr: Integer;
  begin
    Value := 0;
    Result := False;
    Val(ED.Text, Value, ValErr);
    if (ValErr <> 0) or (Value > 255) then 
    begin
      BeepIfSet;
      MessageBox(WindowHandle, PChar(Format(JVCSRES_Integer_between_6037d62_and_6037d62_or_wildcard_expected46,
        [0, 255]) + #13#10 + JVCSRES_Select_the_dialog39s_help_button_for_more_information46),
        cMsgBoxCaption, MB_OK or MB_ICONWARNING);
      ED.SetFocus;
      ED.SelectAll;
      Exit;
    end;
    Result := True;
  end;
begin
  if rbRestricted.Checked then 
  begin
    if (Pos('*', Edit1.Text) > 0) or (Pos('?', Edit1.Text) > 0) then
      IPAddress := Edit1.Text
    else
    begin
      if not CheckNumber(Edit1, IPPart) then 
        Exit;
      IPAddress := IntToStr(IPPart);
    end;
    if (Pos('*', Edit2.Text) > 0) or (Pos('?', Edit2.Text) > 0) then
      IPAddress := IPAddress + '.' + Edit2.Text
    else 
    begin
      if not CheckNumber(Edit2, IPPart) then 
        Exit;
      IPAddress := IPAddress + '.' + IntToStr(IPPart);
    end;
    if (Pos('*', Edit3.Text) > 0) or (Pos('?', Edit3.Text) > 0) then
      IPAddress := IPAddress + '.' + Edit3.Text
    else 
    begin
      if not CheckNumber(Edit3, IPPart) then
        Exit;
      IPAddress := IPAddress + '.' + IntToStr(IPPart);
    end;
    if (Pos('*', Edit4.Text) > 0) or (Pos('?', Edit4.Text) > 0) then
      IPAddress := IPAddress + '.' + Edit4.Text
    else 
    begin
      if not CheckNumber(Edit4, IPPart) then 
        Exit;
      IPAddress := IPAddress + '.' + IntToStr(IPPart);
    end;
  end 
  else 
    IPAddress := '0';
  ModalResult := mrOk;
end;

//------------------------------------------------------------------------------

procedure TVCSEditIP.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSEditIP.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_VC_Administrator);
end;

end.
