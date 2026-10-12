(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: SelectList.pas

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
2003/11/10  THuber    - FormStorage 
2004/02/24  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/17  USchuster - style cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
2007/04/14  USchuster - removed fixed background color of the list box (mantis #4102)
2007/07/01  USchuster - changes for large fonts (added contraints)                        
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit SelectList;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, Menus, JvExStdCtrls, JvTextListBox, JVCSForms;

type
  TVCSSelectList = class(TJVCSForm)
    Panel1: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    Help: TSpeedButton;
    Panel2: TPanel;
    Label1: TLabel;
    edFind: TEdit;
    exlbItems: TJvTextListBox;
    PopupMenu1: TPopupMenu;
    ColouredRows1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edFindChange(Sender: TObject);
    procedure exlbItemsClick(Sender: TObject);
    procedure ColouredRows1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure exlbItemsDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    DefaultString,
    ResultString: string;
    HelpContextID: Integer;
    MultiSelect: Boolean;
    procedure SetCaption(Value: string);
    procedure AddListItem(Value: string);
  end;

var
  VCSSelectList: TVCSSelectList;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSBase, VCSProcBase, ConfigStorage;

{$R *.dfm}

procedure TVCSSelectList.FormCreate(Sender: TObject);
begin
  try
    Constraints.MinHeight := MulDiv(200, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(300, PixelsPerInch, 96);
    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    ColouredRows1.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbWindows, 'SelectList_ColouredRows', True);

    Screen.Cursors[cPopUpMCursor] := LoadCursor(hInstance, PChar('CURSORRM'));
    exlbItems.Cursor := cPopUpMCursor;
    MultiSelect := False;
    ResultString := '';
    DefaultString := '';
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectList.FormShow(Sender: TObject);
var 
  I: Integer;
begin
  exlbItems.MultiSelect := MultiSelect;
  if DefaultString <> '' then 
  begin
    for I := 0 to exlbItems.Items.Count - 1 do 
    begin
      if Pos(LowerCase(DefaultString), exlbItems.Items[I]) > 0 then
      begin
        exlbItems.Selected[I] := True;
        Break;
      end;
    end; // for I := 0 to exlbItems.Items.Count - 1 do begin
  end; // if DefaultString <> '' then begin
end;

//------------------------------------------------------------------------------

procedure TVCSSelectList.SetCaption(Value: string);
begin
  Caption := Value;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectList.AddListItem(Value: string);
begin
  exlbItems.Items.Add(Value);
end;

//------------------------------------------------------------------------------

procedure TVCSSelectList.btnOKClick(Sender: TObject);
var 
  I: Integer;
begin
  if MultiSelect then 
  begin
    ResultString := '';
    for I := 0 to exlbItems.Items.Count - 1 do
      if exlbItems.Selected[I] then
        ResultString := ResultString + exlbItems.Items[I] + ';';
  end 
  else 
  begin
    if exlbItems.ItemIndex <> -1 then
      ResultString := exlbItems.Items[exlbItems.ItemIndex];
  end;
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectList.btnCancelClick(Sender: TObject);
begin
  ResultString := '';
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSSelectList.HelpClick(Sender: TObject);
var
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSSelectList.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, HelpContextID);
end;

//------------------------------------------------------------------------------

procedure TVCSSelectList.edFindChange(Sender: TObject);
var 
  I: Integer;
begin
  with exlbItems do 
  begin
    for I := 0 to Items.Count - 1 do 
    begin
      if AnsiLowerCase(edFind.Text) =
        AnsiLowerCase(Copy(Items[I], 1, Length(edFind.Text))) then 
      begin
        TopIndex := I;
        Break;
      end;
    end; // for I := 0 to Items.Count - 1 do begin
  end; // with exlbItems do begin
end;

//------------------------------------------------------------------------------

procedure TVCSSelectList.exlbItemsClick(Sender: TObject);
begin
  btnOK.Enabled := (exlbItems.ItemIndex <> -1);
end;

//------------------------------------------------------------------------------

procedure TVCSSelectList.ColouredRows1Click(Sender: TObject);
begin
  ColouredRows1.Checked := not ColouredRows1.Checked;
  jvcsReadBool(sBaseRegistryKey + crbWindows, 'SelectList_ColouredRows',
    ColouredRows1.Checked);
  exlbItems.Repaint;
end;


procedure TVCSSelectList.FormActivate(Sender: TObject);
begin
  jvcsLoadFormPosSize(Self);
end;

procedure TVCSSelectList.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  jvcsSaveFormPosSize(Self);
end;

procedure TVCSSelectList.exlbItemsDblClick(Sender: TObject);
begin
  btnOK.Click;
end;

end.
