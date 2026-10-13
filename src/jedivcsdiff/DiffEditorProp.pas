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
2026/10/12  v2026     - port Delphi 13: TSpinEdit/TColorBox nativos; grupo
                        "User interface" (escala/fonte da interface e tema,
                        JVCSUIScale/JVCSUITheme); a fonte do editor tambem vai
                        para EditorFontName/EditorFontSize (preferencia comum)

-----------------------------------------------------------------------------*)

unit DiffEditorProp;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, ExtCtrls, StdCtrls, Spin, JVCSForms, JVCSUIScale, JVCSUITheme;

type
  Tfm_EditorProp = class(TJVCSForm)
    Label1: TLabel;
    speMaxUndo: TSpinEdit;
    Label4: TLabel;
    speLineSpacing: TSpinEdit;
    Label3: TLabel;
    speRightEdge: TSpinEdit;
    Label2: TLabel;
    pnEditorFont: TPanel;
    speFont: TSpeedButton;
    FontDialog1: TFontDialog;
    btnOK: TButton;
    btnCancel: TButton;
    cbEnableLeftEditor: TCheckBox;
    cbEnableRightEditor: TCheckBox;
    cocbxWinBack: TColorBox;
    cocbxSelFore: TColorBox;
    cocbxSelBack: TColorBox;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    cocbxText: TColorBox;
    Label8: TLabel;
    Label9: TLabel;
    speTabWidth: TSpinEdit;
    Label10: TLabel;
    grbUI: TGroupBox;
    lblUIScale: TLabel;
    lblUIFont: TLabel;
    lblTheme: TLabel;
    cbUIScale: TComboBox;
    pnUIFont: TPanel;
    btnUIFont: TButton;
    btnUIFontDefault: TButton;
    cbTheme: TComboBox;
    FontDialog2: TFontDialog;
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
    procedure btnUIFontClick(Sender: TObject);
    procedure btnUIFontDefaultClick(Sender: TObject);
  private
    { Private declarations }
    FShowShowCalled: Boolean;
    cWinBack: TColor;
    cSelFore: TColor;
    cSelBack: TColor;
    cText: TColor;
    FUIFontName: string;
    FUIFontSize: Integer;
    procedure UpdateUIFontPanel;
  public
    { Public declarations }
    { aparencia escolhida (lida por Tfm_Main.EditorProperties1Click) }
    function GetUISettings(const ACurrent: TJVCSUIFontSettings): TJVCSUIFontSettings;
    function GetThemeMode: TJVCSUIThemeMode;
  end;

var
  fm_EditorProp: Tfm_EditorProp;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  DiffMain, DiffHelp, JVCSDiffResources;

{$R *.dfm}

procedure Tfm_EditorProp.FormShow(Sender: TObject);
var
  S: TJVCSUIFontSettings;
begin
  if not FShowShowCalled then
  begin
    FShowShowCalled := True;
    // cores "logicas" (podem ser cores de sistema; o tema as traduz)
    cWinBack := fm_Main.EditorColor;
    cText := fm_Main.EditorTextColor;
    cSelFore := fm_Main.EditorSelForeground;
    cSelBack := fm_Main.EditorSelBackground;
    pnEditorFont.Font.Color := fm_Main.mwceSource.Font.Color;
    pnEditorFont.Color := fm_Main.mwceSource.Color;
    cocbxWinBack.Selected := cWinBack;
    cocbxText.Selected := cText;
    cocbxSelFore.Selected := cSelFore;
    cocbxSelBack.Selected := cSelBack;

    // interface (JVCSUIScale / JVCSUITheme)
    S := JVCSUIFontSettings;
    cbUIScale.Text := JVCSUIScaleToText(S.Scale);
    FUIFontName := S.UIFontName;
    FUIFontSize := S.UIFontSize;
    UpdateUIFontPanel;
    cbTheme.ItemIndex := Ord(JVCSUIThemeMode);
  end;
end;

procedure Tfm_EditorProp.UpdateUIFontPanel;
begin
  if (FUIFontName = '') and (FUIFontSize = 0) then
    pnUIFont.Caption := JVCSRES_System_default
  else
    pnUIFont.Caption := Format('%s, %d pt', [FUIFontName, FUIFontSize]);
end;

procedure Tfm_EditorProp.btnUIFontClick(Sender: TObject);
var
  S: TJVCSUIFontSettings;
begin
  S := JVCSUIFontSettings;
  if FUIFontName <> '' then
    FontDialog2.Font.Name := FUIFontName
  else
    FontDialog2.Font.Name := S.EffectiveUIFontName;
  if FUIFontSize > 0 then
    FontDialog2.Font.Size := FUIFontSize
  else
    FontDialog2.Font.Size := S.EffectiveUIFontSize;
  if FontDialog2.Execute then
  begin
    FUIFontName := FontDialog2.Font.Name;
    FUIFontSize := FontDialog2.Font.Size;
    UpdateUIFontPanel;
  end;
end;

procedure Tfm_EditorProp.btnUIFontDefaultClick(Sender: TObject);
begin
  FUIFontName := '';
  FUIFontSize := 0;
  cbUIScale.Text := JVCSUIScaleToText(cJVCSUIScaleDefault);
  UpdateUIFontPanel;
end;

function Tfm_EditorProp.GetUISettings(const ACurrent: TJVCSUIFontSettings): TJVCSUIFontSettings;
begin
  Result := ACurrent;
  Result.Scale := JVCSUITextToScale(cbUIScale.Text, ACurrent.Scale);
  Result.UIFontName := FUIFontName;
  Result.UIFontSize := FUIFontSize;
  Result.EditorFontName := pnEditorFont.Font.Name;
  Result.EditorFontSize := pnEditorFont.Font.Size;
end;

function Tfm_EditorProp.GetThemeMode: TJVCSUIThemeMode;
begin
  if (cbTheme.ItemIndex >= Ord(Low(TJVCSUIThemeMode))) and
     (cbTheme.ItemIndex <= Ord(High(TJVCSUIThemeMode))) then
    Result := TJVCSUIThemeMode(cbTheme.ItemIndex)
  else
    Result := tmFollowHost;
end;

procedure Tfm_EditorProp.cocbxWinBackChange(Sender: TObject);
begin
  if FShowShowCalled then
  begin
    fm_Main.EditorColor := cocbxWinBack.Selected;
    fm_Main.ApplyAppearance;
    pnEditorFont.Color := fm_Main.mwceSource.Color;
  end;
end;

procedure Tfm_EditorProp.cocbxTextChange(Sender: TObject);
begin
  if FShowShowCalled then
  begin
    fm_Main.EditorTextColor := cocbxText.Selected;
    fm_Main.ApplyAppearance;
    pnEditorFont.Font.Color := fm_Main.mwceSource.Font.Color;
  end;
end;

procedure Tfm_EditorProp.cocbxSelForeChange(Sender: TObject);
begin
  if FShowShowCalled then
  begin
    fm_Main.EditorSelForeground := cocbxSelFore.Selected;
    fm_Main.ApplyAppearance;
  end;
end;

procedure Tfm_EditorProp.cocbxSelBackChange(Sender: TObject);
begin
  if FShowShowCalled then
  begin
    fm_Main.EditorSelBackground := cocbxSelBack.Selected;
    fm_Main.ApplyAppearance;
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
  fm_Main.EditorColor := cWinBack;
  fm_Main.EditorTextColor := cText;
  fm_Main.EditorSelForeground := cSelFore;
  fm_Main.EditorSelBackground := cSelBack;
  fm_Main.ApplyAppearance;
  ModalResult := mrCancel;
end;

procedure Tfm_EditorProp.FormCreate(Sender: TObject);
begin
  try
    FShowShowCalled := False;
    JVCSUIApplyToForm(Self);
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
