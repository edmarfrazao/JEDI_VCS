(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: DiffEditorProp.pas

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
2004/01/18  USchuster - replaced TSpinEdit with TJvSpinEdit -> now personal edition compatible
                      - fixed alignment in form
2004/02/24  USchuster - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
                        -> TJvColorComboBox.AutoSave was removed in JVCL 3 and
                           thatswhy a small fix was necessary
                           -> this removed some outdated registry stuff as well
                              (Software\JEDI\Version Control\JediFVCSDiff)
2004/04/12  THuber    - use chm help instead of hlp help
2004/07/12  USchuster - TabWidth is now configurable (mantis #1945)
2004/11/12  USchuster - added dxGetText support for localization with over IFDEF LANGUAGE
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit DiffEditorProp;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, ExtCtrls, StdCtrls, JvCombobox, JvColorCombo, Mask, JvMaskEdit,
  JvSpin, JvExStdCtrls, JvExMask, JVCSForms;

type
  Tfm_EditorProp = class(TJVCSForm)
    Label1: TLabel;
    speMaxUndo: TJvSpinEdit;
    Label4: TLabel;
    speLineSpacing: TJvSpinEdit;
    Label3: TLabel;
    speRightEdge: TJvSpinEdit;
    Label2: TLabel;
    pnEditorFont: TPanel;
    speFont: TSpeedButton;
    FontDialog1: TFontDialog;
    btnOK: TButton;
    btnCancel: TButton;
    cbEnableLeftEditor: TCheckBox;
    cbEnableRightEditor: TCheckBox;
    cocbxWinBack: TJvColorComboBox;
    cocbxSelFore: TJvColorComboBox;
    cocbxSelBack: TJvColorComboBox;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    cocbxText: TJvColorComboBox;
    Label8: TLabel;
    Label9: TLabel;
    speTabWidth: TJvSpinEdit;
    Label10: TLabel;
    procedure speFontClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure cocbxWinBackChange(Sender: TObject);
    procedure cocbxSelForeChange(Sender: TObject);
    procedure cocbxSelBackChange(Sender: TObject);
    procedure cocbxTextChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    FShowShowCalled: Boolean;
    cWinBack: TColor;
    cSelFore: TColor;
    cSelBack: TColor;
    cText: TColor;
  public
    { Public declarations }
  end;

var
  fm_EditorProp: Tfm_EditorProp;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  DiffMain, DiffHelp;

{$R *.dfm}

procedure Tfm_EditorProp.FormShow(Sender: TObject);
begin
  if not FShowShowCalled then
  begin
    FShowShowCalled := True;
    pnEditorFont.Font.Color := fm_Main.mwceSource.Font.Color;
    pnEditorFont.Color := fm_Main.mwceSource.Color;
    cWinBack := fm_Main.mwceSource.Color;
    cText := fm_Main.mwceSource.Font.Color;
    cSelFore := fm_Main.mwceSource.SelectedColor.Foreground;
    cSelBack := fm_Main.mwceSource.SelectedColor.Background;
    cocbxWinBack.ColorValue := cWinBack;
    cocbxText.ColorValue := cText;
    cocbxSelFore.ColorValue := cSelFore;
    cocbxSelBack.ColorValue := cSelBack;
  end;
end;

procedure Tfm_EditorProp.cocbxWinBackChange(Sender: TObject);
begin
  if FShowShowCalled then
  begin
    fm_Main.mwceSource.Color := cocbxWinBack.ColorValue;
    fm_Main.mwceTarget.Color := fm_Main.mwceSource.Color;
    pnEditorFont.Color := fm_Main.mwceSource.Color;
  end;
end;

procedure Tfm_EditorProp.cocbxTextChange(Sender: TObject);
begin
  if FShowShowCalled then
  begin
    fm_Main.mwceSource.Font.Color := cocbxText.ColorValue;
    fm_Main.mwceTarget.Font.Color := fm_Main.mwceSource.Font.Color;
    pnEditorFont.Font.Color := cocbxText.ColorValue;
  end;
end;

procedure Tfm_EditorProp.cocbxSelForeChange(Sender: TObject);
begin
  if FShowShowCalled then
  begin
    fm_Main.mwceSource.SelectedColor.Foreground := cocbxSelFore.ColorValue;
    fm_Main.mwceTarget.SelectedColor.Foreground :=
      fm_Main.mwceSource.SelectedColor.Foreground;
  end;
end;

procedure Tfm_EditorProp.cocbxSelBackChange(Sender: TObject);
begin
  if FShowShowCalled then
  begin
    fm_Main.mwceSource.SelectedColor.Background := cocbxSelBack.ColorValue;
    fm_Main.mwceTarget.SelectedColor.Background :=
      fm_Main.mwceSource.SelectedColor.Background;
  end;
end;

procedure Tfm_EditorProp.speFontClick(Sender: TObject);
begin
  FontDialog1.Font.Assign(pnEditorFont.Font);
  if FontDialog1.Execute then
  begin
    pnEditorFont.Font.Assign(FontDialog1.Font);
    pnEditorFont.Caption := pnEditorFont.Font.Name + ', ' +
      IntToStr(pnEditorFont.Font.Size) + ' pt';
  end;
end;

procedure Tfm_EditorProp.btnCancelClick(Sender: TObject);
begin
  fm_Main.mwceSource.Color := cWinBack;
  fm_Main.mwceTarget.Color := fm_Main.mwceSource.Color;
  fm_Main.mwceSource.Font.Color := cText;
  fm_Main.mwceTarget.Font.Color := fm_Main.mwceSource.Font.Color;
  fm_Main.mwceSource.SelectedColor.Foreground := cSelFore;
  fm_Main.mwceTarget.SelectedColor.Foreground :=
    fm_Main.mwceSource.SelectedColor.Foreground;
  fm_Main.mwceSource.SelectedColor.Background := cSelBack;
  fm_Main.mwceTarget.SelectedColor.Background :=
    fm_Main.mwceSource.SelectedColor.Background;
  ModalResult := mrCancel;
end;

procedure Tfm_EditorProp.FormCreate(Sender: TObject);
begin
  try
    FShowShowCalled := False;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

procedure Tfm_EditorProp.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // set TForm.KeyPreview := true !
  if Key = VK_F1 then
    ShowHelpContext(Application, IDH_jvcsdiff_editor_properties);
end;

end.
