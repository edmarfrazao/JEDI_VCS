(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: Listview.pas

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
2003/08/03  THuber    - mantis #861: replaced TMemo with TJvMemo
                      - FormStorage changed in configStorage
2004/02/24  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/30  USchuster - style cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/11/03  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
2005/06/04  USchuster - set memo charset to DEFAULT_CHARSET(necessary for LANGUAGE version)
2007/07/01  USchuster - changes for large fonts (added contraints)                      
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit ListView;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Menus, Buttons, JvMemo, JvExStdCtrls, JVCSForms;

type
  TVCSListView = class(TJVCSForm)
    Panel1: TPanel;
    btnClose: TButton;
    PopupMenu1: TPopupMenu;
    CopytoClipboard1: TMenuItem;
    Memo1: TJvMemo;
    spBtnCopyClipbrd: TSpeedButton;
    Help: TSpeedButton;
    procedure btnCloseClick(Sender: TObject);
    procedure CopytoClipboard1Click(Sender: TObject);
    procedure spBtnCopyClipbrdClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure HelpClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    HelpContextID: Integer;
    procedure EnableWordWrap(Value: Boolean);
    procedure SetUpText(TextString: string);
    procedure SetUpListView(Entrys: string);
    procedure SetFontName(Value: string);
  end;

var
  VCSListView: TVCSListView;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSBase, ConfigStorage, JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSListView.FormCreate(Sender: TObject);
begin
  try
    Constraints.MinHeight := MulDiv(176, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(250, PixelsPerInch, 96);
    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);
    HelpContextID := 0;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSListView.FormShow(Sender: TObject);
begin
  jvcsLoadFormPosSize(Self);
  Help.Enabled := (HelpContextID <> 0);
  Help.Visible := Help.Enabled;
  spBtnCopyClipbrd.Enabled := (Caption <> JVCSRES_Preview);
  spBtnCopyClipbrd.Visible := spBtnCopyClipbrd.Enabled;
end;

//------------------------------------------------------------------------------

procedure TVCSListView.SetFontName(Value: string);
begin
  Memo1.Font.Name := Value;
end;

//------------------------------------------------------------------------------

procedure TVCSListView.SetUpText(TextString: string);
begin
  Memo1.Clear;
  Memo1.Text := TextString;
end;

//------------------------------------------------------------------------------

procedure TVCSListView.SetUpListView(Entrys: string);
var 
  Marker: Integer;
begin
  Memo1.Clear;
  while Pos(';', Entrys) <> 0 do 
  begin
    Marker := Pos(';', Entrys);
    Memo1.Lines.Add(Copy(Entrys, 1, Marker - 1));
    Delete(Entrys, 1, Marker);
  end; // while Pos(';', Entrys) <> 0 do begin
end;

//------------------------------------------------------------------------------

procedure TVCSListView.EnableWordWrap(Value: Boolean);
begin
  Memo1.WordWrap := Value;
  if Value then
    Memo1.ScrollBars := ssVertical
  else
    Memo1.ScrollBars := ssBoth;
end;

//------------------------------------------------------------------------------

procedure TVCSListView.btnCloseClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSListView.CopytoClipboard1Click(Sender: TObject);
begin
  Memo1.CopyToClipBoard;
end;

//------------------------------------------------------------------------------

procedure TVCSListView.spBtnCopyClipbrdClick(Sender: TObject);
begin
  Memo1.SelStart := 0;
  Memo1.SelLength := Length(Memo1.Text);
  Memo1.CopyToClipBoard;
  Memo1.SelLength := 0;
end;

//------------------------------------------------------------------------------

procedure TVCSListView.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then 
  begin
    btnClose.Click;
    Key := 0;
  end;    
end;

//------------------------------------------------------------------------------

procedure TVCSListView.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

procedure TVCSListView.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  jvcsSaveFormPosSize(Self);
end;

end.
