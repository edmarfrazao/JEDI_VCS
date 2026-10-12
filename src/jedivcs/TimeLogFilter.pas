(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: TimeLogFilter.pas

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
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/09  USchuster - style cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit TimeLogFilter;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, JVCSForms;

type
  TVCSTLFilter = class(TJVCSForm)
    Label1: TLabel;
    cbxUser: TComboBox;
    Label3: TLabel;
    Label4: TLabel;
    dtpStart: TDateTimePicker;
    dtpStop: TDateTimePicker;
    btnOK: TButton;
    btnCancel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    StartFilterValue,
    EndFilterValue: Double;
    UserFilterValue: string;
    procedure AddUser(const Value: string);
  end;

var
  VCSTLFilter: TVCSTLFilter;

implementation

{$IFDEF LANGUAGE}
uses
  JvGnugettext;
{$ENDIF LANGUAGE}

{$R *.dfm}

procedure TVCSTLFilter.FormCreate(Sender: TObject);
begin
  try
    StartFilterValue := 0;
    EndFilterValue := 0;
    UserFilterValue := '';
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

procedure TVCSTLFilter.FormShow(Sender: TObject);
begin
  if UserFilterValue <> '' then
    cbxUser.ItemIndex := cbxUser.Items.IndexOf(UserFilterValue)
  else
    cbxUser.ItemIndex := 0;
  dtpStart.Date := StartFilterValue;
  dtpStop.Date := EndFilterValue;
end;

procedure TVCSTLFilter.AddUser(const Value: string);
begin
  cbxUser.Items.Add(Value);
end;

procedure TVCSTLFilter.btnOKClick(Sender: TObject);
begin
  if cbxUser.ItemIndex > 0 then
    UserFilterValue := cbxUser.Items[cbxUser.ItemIndex]
  else
    UserFilterValue := '';
  StartFilterValue := dtpStart.Date;
  EndFilterValue := dtpStop.Date;
  ModalResult := mrOk;
end;

procedure TVCSTLFilter.btnCancelClick(Sender: TObject);
begin
  UserFilterValue := '';
  StartFilterValue := 0;
  EndFilterValue := 66000;
  ModalResult := mrCancel;
end;

end.
