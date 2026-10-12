(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: AddNewFamily.pas

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
                      ... taborder, formstorage
2003/12/27  USchuster - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use constant)
2004/04/17  USchuster - restricted minimum size in form
                      - minor style cleaning (casing and comments)
                      - moved string to JVCSGUIClientResources.pas
2004/06/28  THuber    #1289 ffamily.parentext enlarged to 20chars depending on
                        server version
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/08  THuber    - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
                      - jedistyle clean
                      - use jvcl msgBoxes
2007/06/25  USchuster - changes for large fonts (set AutoScroll to False)
2007/07/01  USchuster - changes for large fonts (contraints size depend now on PixelsPerInch; analog to Mantis #3710)
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma
                      
-----------------------------------------------------------------------------*)

unit AddNewFamily;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Forms, StdCtrls, Buttons, Controls,
  ExtCtrls, JVCSForms;

type
  TVCSAddFamily = class(TJVCSForm)
    pnlButton: TPanel;
    Help: TSpeedButton;
    btnOK: TButton;
    btnCancel: TButton;
    gbDescription: TGroupBox;
    meDescription: TMemo;
    pnlHead: TPanel;
    Label1: TLabel;
    edFamily: TEdit;
    edParent: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    edChild: TEdit;
    spBtnEditChild: TSpeedButton;
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edFamilyChange(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure spBtnEditChildClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    FamilyName,
    FamilyParent,
    FamilyChilds,
    FamilyDescr: string;
  end;

var
  VCSAddFamily: TVCSAddFamily;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSProcBase, VCSBase, ListEdit, ConfigStorage, JvJVCLUtils, JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSAddFamily.FormCreate(Sender: TObject);
begin
  try
    Constraints.MinHeight := MulDiv(210, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(360, PixelsPerInch, 96);
    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);
    FamilyName := '';
    FamilyParent := '';
    FamilyChilds := '';
    FamilyDescr := '';
    // since jvcs 240 (db version 241) parentext is now 20 char
    if nServerVersion < 240 then
      edParent.MaxLength := 10
    else
      edParent.MaxLength := 20;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

procedure TVCSAddFamily.btnOKClick(Sender: TObject);
var
  ParseStr, CurrentExt: string;

  procedure InvValue(EditField: TEdit);
  begin
    BeepIfSet;
    MsgOk ( Handle
          , JVCSRES_The_value_you_have_entered_is_invalid46 +#13+#10+
            JVCSRES_Required58_One_leading_dot44_different_child_extensions_seperated_with_semicolons46 +#13+#10+
            JVCSRES_Wildcards_not_allowed46 +#13+#10+
            JVCSRES_Select_the_dialog39s_help_button_for_more_information46
          , cMsgBoxCaption
          , MB_ICONWARNING
          );
    EditField.SetFocus;
    EditField.SelectAll;
  end;

  function CheckChars(Value: string): Boolean;
  var
    I: Integer;
  begin
    Result := True;
    for I := 1 to Length(Value) do
    begin
      if not (Value[I] in ['a'..'z', 'A'..'Z', '0'..'9', '-', '_']) then
      begin
        Result := False;
        Exit;
      end;
    end;
  end;
  
begin
  FamilyName := edFamily.Text;

  FamilyParent := edParent.Text;
  if (Length(FamilyParent) > 1) and
    (FamilyParent[Length(FamilyParent)] = ';') then
    Delete(FamilyParent, Length(FamilyParent), 1);
  edParent.Text := FamilyParent;

  FamilyChilds := edChild.Text;
  if (Length(FamilyChilds) > 1) and
    (FamilyChilds[Length(FamilyChilds)] = ';') then
    Delete(FamilyChilds, Length(FamilyChilds), 1);
  edChild.Text := FamilyChilds;

  // Name
  ParseStr := FamilyName;
  if ParseStr = '' then 
  begin
    InvValue(edFamily);
    Exit;
  end;
  // Parent
  ParseStr := FamilyParent;
  if ParseStr = '' then 
  begin
    InvValue(edParent);
    Exit;
  end;
  if ParseStr[1] <> '.' then 
  begin
    InvValue(edParent);
    Exit;
  end;
  Delete(ParseStr, 1, 1);
  if not CheckChars(ParseStr) then 
  begin
    InvValue(edParent);
    Exit;
  end;
  // Childs
  ParseStr := FamilyChilds;
  if ParseStr = '' then 
  begin
    InvValue(edChild);
    Exit;
  end;
  ParseStr := ParseStr + ';';
  while (Pos(';', ParseStr) > 0) and (Length(ParseStr) > 1) do 
  begin
    CurrentExt := Copy(ParseStr, 1, Pos(';', ParseStr) - 1);
    if CurrentExt[1] <> '.' then 
    begin
      InvValue(edChild);
      Exit;
    end;
    Delete(CurrentExt, 1, 1);
    if not CheckChars(CurrentExt) then 
    begin
      InvValue(edChild);
      Exit;
    end;
    Delete(ParseStr, 1, Pos(';', ParseStr));
  end; // while Pos(';', ParseStr) > 0 do begin


  FamilyDescr := meDescription.Text;
  Close;
end;


procedure TVCSAddFamily.btnCancelClick(Sender: TObject);
begin
  FamilyName := '';
  FamilyParent := '';
  FamilyChilds := '';
  FamilyDescr := '';
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSAddFamily.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then 
  begin
    btnCancel.Click;
    Key := 0;
  end;    
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_File_families);
end;

//------------------------------------------------------------------------------

procedure TVCSAddFamily.edFamilyChange(Sender: TObject);
begin
  btnOK.Enabled := (edFamily.Text <> '') and
    (edParent.Text <> '') and
    (edChild.Text <> '');
end;

//------------------------------------------------------------------------------

procedure TVCSAddFamily.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSAddFamily.spBtnEditChildClick(Sender: TObject);
var 
  DlgResult: Integer;
  EditString: string;
begin
  EditString := edChild.Text;
  VCSListEdit := TVCSListEdit.Create(Application);
  try
    VCSListEdit.Left := Left + 40;
    VCSListEdit.Top := Top + 40;
    VCSListEdit.SetHint(JVCSRES_Child_extensions);
    VCSListEdit.EnablePathButton(False);
    VCSListEdit.ListString := EditString;
    DlgResult := VCSListEdit.ShowModal;
    EditString := VCSListEdit.ListString;
  finally
    VCSListEdit.Free;
  end;
  if DlgResult = mrOk then
    edChild.Text := EditString;
end;

procedure TVCSAddFamily.FormShow(Sender: TObject);
begin
  jvcsLoadFormPosSize(Self);
end;

procedure TVCSAddFamily.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  jvcsSaveFormPosSize(Self);
end;

end.
