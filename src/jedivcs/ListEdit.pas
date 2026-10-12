(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: ListEdit.pas

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
2004/02/24  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/30  USchuster - style cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/11/03  USchuster - moved resourcestrings to JVCSGUIClientResources.pas                      
2005/01/06  THuber    - replaced JvHtListBox with JvListBox
2006/12/10  USchuster - added JVCSClientFunctions to uses (as of now it is required for MatchWithFilter)
2007/06/30  USchuster - changes for large fonts (contraints size depend now on PixelsPerInch; analog to Mantis #3710)
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit ListEdit;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, JvExStdCtrls, JvListBox, JVCSForms;

type
  TVCSListEdit = class(TJVCSForm)
    lbStrings: TJvListBox;
    Panel1: TPanel;
    edStrings: TEdit;
    btnReplace: TButton;
    btnAdd: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    btnDelete: TButton;
    spBtnAddPath: TSpeedButton;
    Panel2: TPanel;
    spBtnUp: TSpeedButton;
    spBtnDown: TSpeedButton;
    spBtnCheckBinary: TSpeedButton;
    OpenDialog1: TOpenDialog;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lbStringsClick(Sender: TObject);
    procedure edStringsChange(Sender: TObject);
    procedure btnReplaceClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure spBtnAddPathClick(Sender: TObject);
    procedure spBtnUpClick(Sender: TObject);
    procedure spBtnDownClick(Sender: TObject);
    procedure spBtnCheckBinaryClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    ListString: string;
    procedure SetHint(Value: string);
    procedure EnablePathButton(Value: Boolean);
    procedure EnableCheckBinaryButton(Value: Boolean);
  end;

var
  VCSListEdit: TVCSListEdit;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  SelectFolder, VCSBase, VCSProcBase, ConfigStorage, JVCSGUIClientResources, JVCSClientFunctions;

{$R *.dfm}

procedure TVCSListEdit.FormCreate(Sender: TObject);
begin
  try
    Constraints.MinHeight := MulDiv(240, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(305, PixelsPerInch, 96);
    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);
    ListString := '';
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSListEdit.SetHint(Value: string);
begin
  Caption := Value;
end;

//------------------------------------------------------------------------------

procedure TVCSListEdit.EnablePathButton(Value: Boolean);
begin
  spBtnAddPath.Enabled := Value;
  spBtnAddPath.Visible := spBtnAddPath.Enabled;
end;

//------------------------------------------------------------------------------

procedure TVCSListEdit.EnableCheckBinaryButton(Value: Boolean);
begin
  spBtnCheckBinary.Enabled := Value;
  spBtnCheckBinary.Visible := spBtnCheckBinary.Enabled;
end;

//------------------------------------------------------------------------------

procedure TVCSListEdit.FormShow(Sender: TObject);
var 
  Marker: Integer;
begin
  if (Length(ListString) > 0) and
    (ListString[Length(ListString)] <> ';') then
    ListString := ListString + ';';
  while Pos(';', ListString) <> 0 do
  begin
    Marker := Pos(';', ListString);
    lbStrings.Items.Add(Copy(ListString, 1, Marker - 1));
    Delete(ListString, 1, Marker);
  end; // while Pos(';', Entrys) <> 0 do begin
  if lbStrings.Items.Count > 0 then
    lbStrings.ItemIndex := 0;
  lbStringsClick(Self);
end;

//------------------------------------------------------------------------------

procedure TVCSListEdit.lbStringsClick(Sender: TObject);
begin
  if lbStrings.ItemIndex <> -1 then
    edStrings.Text := lbStrings.Items[lbStrings.ItemIndex];
end;

//------------------------------------------------------------------------------

procedure TVCSListEdit.edStringsChange(Sender: TObject);
begin
  btnReplace.Enabled := edStrings.Text <> '';
  btnAdd.Enabled := btnReplace.Enabled;
end;

//------------------------------------------------------------------------------

procedure TVCSListEdit.btnReplaceClick(Sender: TObject);
begin
  if lbStrings.ItemIndex = -1 then 
    Exit;
  if spBtnAddPath.Enabled then
    lbStrings.Items[lbStrings.ItemIndex] := SetBackSlash(edStrings.Text)
  else
    lbStrings.Items[lbStrings.ItemIndex] := edStrings.Text;
end;

//------------------------------------------------------------------------------

procedure TVCSListEdit.btnAddClick(Sender: TObject);
begin
  if spBtnAddPath.Enabled then
  begin
    if lbStrings.Items.IndexOf(SetBackSlash(edStrings.Text)) > -1 then
      Exit;
    lbStrings.Items.Add(SetBackSlash(edStrings.Text))
  end 
  else 
  begin
    if lbStrings.Items.IndexOf(edStrings.Text) > -1 then
      Exit;
    lbStrings.Items.Add(edStrings.Text);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSListEdit.btnDeleteClick(Sender: TObject);
begin
  lbStrings.Items.Delete(lbStrings.ItemIndex);
end;

//------------------------------------------------------------------------------

procedure TVCSListEdit.btnOKClick(Sender: TObject);
var 
  I: Integer;
begin
  ListString := '';
  for I := 0 to lbStrings.Items.Count - 1 do
    ListString := ListString + lbStrings.Items[I] + ';';
  ModalResult := mrOk;
  //  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSListEdit.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
  //  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSListEdit.spBtnAddPathClick(Sender: TObject);
var
  NewDir: string;
begin
  VCSSelectFolder := TVCSSelectFolder.Create(Application);
  try
    VCSSelectFolder.SetStatusText(JVCSRES_38Add_as_new_search_path58);
    VCSSelectFolder.EnableRecursive(False);
    VCSSelectFolder.HelpContextID := IDH_Used_Units;
    VCSSelectFolder.EnableNewFolder(False);
    VCSSelectFolder.SetInitialDir(GetCurrentDir);
    VCSSelectFolder.ShowModal;
    if VCSSelectFolder.Selection <> '' then 
    begin
      NewDir := SetBackSlash(AnsiLowerCase(VCSSelectFolder.Selection));
      edStrings.Text := NewDir;
    end; // if VCSSelectFolder.Selection <> '' then begin
  finally
    VCSSelectFolder.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSListEdit.spBtnUpClick(Sender: TObject);
var 
  CurrentItem: string;
  CurrentIndex: Integer;
begin
  if lbStrings.ItemIndex < 1 then 
    Exit;
  CurrentIndex := lbStrings.ItemIndex;
  CurrentItem := lbStrings.Items[CurrentIndex];
  lbStrings.Items.Delete(CurrentIndex);
  lbStrings.Items.Insert(CurrentIndex - 1, CurrentItem);
  lbStrings.ItemIndex := CurrentIndex - 1;
end;

//------------------------------------------------------------------------------

procedure TVCSListEdit.spBtnDownClick(Sender: TObject);
var 
  CurrentItem: string;
  CurrentIndex: Integer;
begin
  if (lbStrings.ItemIndex = -1) or
    (lbStrings.ItemIndex >= (lbStrings.Items.Count - 1)) then 
    Exit;
  CurrentIndex := lbStrings.ItemIndex;
  CurrentItem := lbStrings.Items[CurrentIndex];
  lbStrings.Items.Delete(CurrentIndex);
  lbStrings.Items.Insert(CurrentIndex + 1, CurrentItem);
  lbStrings.ItemIndex := CurrentIndex + 1;
end;

//------------------------------------------------------------------------------

procedure TVCSListEdit.spBtnCheckBinaryClick(Sender: TObject);
var 
  CurrExt: string;
begin
  CurrExt := ExtractFileExt(edStrings.Text);
  if CurrExt <> '' then
    OpenDialog1.Filter := Format(JVCSRES_37s45files_404237s411244237s124All_files_4042464241124424642,
      [CurrExt, CurrExt, CurrExt])
  else
    OpenDialog1.Filter := JVCSRES_All_files_4042464241124424642;
  if OpenDialog1.Execute then
  begin
    if IsBinaryFile(OpenDialog1.FileName) then
      MessageBox(WindowHandle, PChar(Format('<%s>' + #13#10 +
        JVCSRES_37s_a_binary_file_type46_You_37s_use_files_of_this_type_with_JEDIVCSDiff46exe46,
       [OpenDialog1.FileName, JVCSRES_is, JVCSRES_cannot])), cMsgBoxCaption, MB_OK or MB_ICONWARNING)
    else
      MessageBox(WindowHandle, PChar(Format('<%s>' + #13#10 +
        JVCSRES_37s_a_binary_file_type46_You_37s_use_files_of_this_type_with_JEDIVCSDiff46exe46,
        [OpenDialog1.FileName, JVCSRES_is_not, JVCSRES_can])), cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
  end;
end;

end.
