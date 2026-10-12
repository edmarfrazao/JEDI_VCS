(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: DiffCustomKW.pas

The Initial Developer of the original Code (FVCSDiff) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDIVCSDiff: Thomas Huber (Thomas_D_Huber@gmx.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FVCSDiff code to JEDIVCSDiff
2004/04/12  THuber    - use chm help instead of hlp help
2004/11/12  USchuster - added dxGetText support for localization with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit DiffCustomKW;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, JVCSForms;

type
  TCustomKW = class(TJVCSForm)
    lbKeywords: TListBox;
    btnLoad: TButton;
    btnClose: TButton;
    OpenDialog1: TOpenDialog;
    btnAdd: TButton;
    btnEdit: TButton;
    btnDelete: TButton;
    procedure btnLoadClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CustomKW: TCustomKW;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  DiffHelp, JVCSDiffResources;

{$R *.dfm}

procedure TCustomKW.btnLoadClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
    lbKeywords.Items.LoadFromFile(OpenDialog1.FileName);
end;

procedure TCustomKW.btnDeleteClick(Sender: TObject);
begin
  if lbKeywords.ItemIndex <> -1 then
    lbKeywords.Items.Delete(lbKeywords.ItemIndex);
end;

procedure TCustomKW.btnAddClick(Sender: TObject);
var
  val: string;
begin
  val := Inputbox(JVCSRES_Add_Reserved_Word, JVCSRES_Reserved_Word58, '');
  if val <> '' then
    lbKeywords.Items.Add(val);
end;

procedure TCustomKW.btnEditClick(Sender: TObject);
var
  val: string;
begin
  if lbKeywords.ItemIndex <> -1 then
  begin
    val := Inputbox(JVCSRES_Edit_Reserved_Word, JVCSRES_Reserved_Word58, lbKeywords.Items[lbKeywords.ItemIndex]);
    if val <> lbKeywords.Items[lbKeywords.ItemIndex] then
      lbKeywords.Items.Add(val);
  end;
end;

procedure TCustomKW.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // set TForm.KeyPreview := true !
  if Key = VK_F1 then
    ShowHelpContext(Application, IDH_jvcsdiff_custom_keywords);
end;

procedure TCustomKW.FormCreate(Sender: TObject);
begin
  try
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

end.

