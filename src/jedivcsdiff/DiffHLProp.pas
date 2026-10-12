(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: DiffHLProp.pas

The Initial Developer of the original Code (FVCSDiff) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDIVCSDiff: Thomas Huber (Thomas_D_Huber@gmx.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
ToDo
- remove dependency from mainform
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FVCSDiff code to JEDIVCSDiff
2003/02/18  MGosselink- Bug in registry reference solved
2003/05/26  THuber    - Reg const name changed
2004/01/18  USchuster - removed Spin from uses -> now personal edition compatible
2004/02/24  USchuster - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
                        -> TJvColorComboBox.AutoSave was removed in JVCL 3 but
                           actually the use of this property seams not to be necessary
                           because the ColorCombo's will be set from the highlighters
                           -> this removed some outdated registry stuff as well
                              (Software\JEDI\Version Control\JediFVCSDiff) 
2004/04/12  THuber    - use chm help instead of hlp help
2004/11/12  USchuster - added dxGetText support for localization with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2006/11/05  USchuster - changes for SynEdit 2.0.3                      
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit DiffHLProp;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ComCtrls, JvCombobox, JvColorCombo,
  SynHighlighterGeneral, SynEditHighlighter, JvExStdCtrls, JVCSForms;

type
  Tfm_HighLightProp = class(TJVCSForm)
    Button1: TButton;
    Button2: TButton;
    lblStatus: TLabel;
    Label6: TLabel;
    cbxHighlighterSelect: TComboBox;
    Label22: TLabel;
    cbxAttrSelect: TComboBox;
    Label23: TLabel;
    cocbxAttrForeground: TJvColorComboBox;
    Label24: TLabel;
    cocbxAttrBackground: TJvColorComboBox;
    btnKeywords: TButton;
    Label5: TLabel;
    edDefaultFilter: TEdit;
    grbAttrComments: TGroupBox;
    cbCommentsBas: TCheckBox;
    cbCommentsAsm: TCheckBox;
    cbCommentsPas: TCheckBox;
    cbCommentsAnsi: TCheckBox;
    cbCommentsC: TCheckBox;
    grbAttrStyle: TGroupBox;
    cbStyleBold: TCheckBox;
    cbStyleStrikeOut: TCheckBox;
    cbStyleUnderline: TCheckBox;
    cbStyleItalic: TCheckBox;
    procedure btnKeywordsClick(Sender: TObject);
    procedure cbxAttrSelectChange(Sender: TObject);
    procedure cbCommentsAnsiClick(Sender: TObject);
    procedure edDefaultFilterChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure cbxHighlighterSelectChange(Sender: TObject);
    procedure cocbxAttrForegroundChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    CurrentHLName: string;
    procedure SaveHighLighterToReg;
    procedure ReloadAttributes;
  public
    { Public declarations }
  end;

var
  fm_HighLightProp: Tfm_HighLightProp;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  Registry, DiffMain, DiffCustomKW, DiffHelp, JVCSDiffResources;

{$R *.dfm}

procedure Tfm_HighLightProp.FormCreate(Sender: TObject);
begin
  try
    cocbxAttrBackground.Items.Assign(cocbxAttrForeground.Items);
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

procedure Tfm_HighLightProp.FormShow(Sender: TObject);
var
  I: Integer;
begin
  CurrentHLName := '';

  cbxHighlighterSelect.Items.Clear;
  cbxHighlighterSelect.Items.Add(JVCSRES_40none41);
  for I := 0 to fm_Main.ComponentCount - 1 do
    if fm_Main.Components[I] is TSynCustomHighlighter then
    begin
      cbxHighlighterSelect.Items.Add((fm_Main.Components[I] as
        TSynCustomHighlighter).LanguageName)
    end;

  if Assigned(fm_Main.mwceSource.Highlighter) then
    cbxHighlighterSelect.ItemIndex :=
      cbxHighlighterSelect.Items.IndexOf(
        fm_Main.mwceSource.Highlighter.LanguageName)
  else
    cbxHighlighterSelect.ItemIndex := 0;
  cbxHighlighterSelectChange(Self);

  cbxAttrSelect.Items.Clear;
  if Assigned(fm_Main.mwceSource.Highlighter) then
  begin
    for I := 0 to fm_Main.mwceSource.Highlighter.AttrCount - 1 do
      cbxAttrSelect.Items.Add(fm_Main.mwceSource.Highlighter.Attribute[I].Name);
    cbxAttrSelect.ItemIndex := 0;
  end;

  cbxAttrSelectChange(Self);
{  cbCommentsAnsi.Checked := (csAnsiStyle in VCSTextCompare.mwceSource.Highlighter.Comments);
  cbCommentsPas.Checked  := (csPasStyle in VCSTextCompare.mwceSource.Highlighter.Comments);
  cbCommentsC.Checked    := (csCStyle in VCSTextCompare.mwceSource.Highlighter.Comments);
  cbCommentsAsm.Checked  := (csAsmStyle in VCSTextCompare.mwceSource.Highlighter.Comments);
  cbCommentsBas.Checked  := (csBasStyle in VCSTextCompare.mwceSource.Highlighter.Comments);}

  edDefaultFilter.Text := fm_Main.mwGeneralSyn1.DefaultFilter;
end;

procedure Tfm_HighLightProp.ReloadAttributes;
var
  I: Integer;
begin
  if cbxHighlighterSelect.ItemIndex > 0 then
  begin
    cbxAttrSelect.Items.Clear;
    if Assigned(fm_Main.mwceSource.Highlighter) then
    begin
      for I := 0 to fm_Main.mwceSource.Highlighter.AttrCount - 1 do
        cbxAttrSelect.Items.Add(fm_Main.mwceSource.Highlighter.Attribute[I].Name);
      cbxAttrSelect.ItemIndex := 0;
    end;
  end;
  cbxAttrSelectChange(Self);
end;

procedure Tfm_HighLightProp.SaveHighLighterToReg;
var
  CmntSet: SynHighlighterGeneral.TCommentStyles;
begin
  if CurrentHLName = '' then Exit;
  if Assigned(fm_Main.mwceSource.Highlighter) then
  begin
    if fm_Main.mwceSource.Highlighter.SaveToRegistry(HKEY_CURRENT_USER,
        RegDiffOptions + '\Highlighters\' + CurrentHLName)
      then
        lblStatus.Caption := JVCSRES_Success
      else
        lblStatus.Caption := JVCSRES_Failure;
    if CurrentHLName = 'General' then
    begin
      with TRegistry.Create do
      begin
        try
          RootKey := HKEY_CURRENT_USER;
          OpenKey(RegDiffOptions + '\Highlighters\General', True);
          WriteString('DefaultFilter', edDefaultFilter.Text);
          CmntSet :=
            (fm_Main.mwceSource.Highlighter as TSynGeneralSyn).Comments;
          WriteBinaryData('CommentSet', CmntSet, SizeOf(CmntSet));
          CloseKey;
        finally
          Free;
        end;
      end;
    end;
  end;
end;

procedure Tfm_HighLightProp.btnKeywordsClick(Sender: TObject);
begin
  CustomKW := TCustomKW.Create(Application);
  try
    CustomKW.Top := Top + 100;
    CustomKW.Left := Left + 100;
    CustomKW.lbKeywords.Items.Assign((fm_Main.mwceSource.Highlighter as TSynGeneralSyn).Keywords);
    if CustomKW.ShowModal = mrOk then
      (fm_Main.mwceSource.Highlighter as TSynGeneralSyn).Keywords := CustomKW.lbKeywords.Items;
  finally
    CustomKW.Free;
  end;
end;

procedure Tfm_HighLightProp.cbxHighlighterSelectChange(Sender: TObject);
var
  I: Integer;
  CmntSet: SynHighlighterGeneral.TCommentStyles;
begin
  SaveHighLighterToReg;
  fm_Main.mwceSource.Highlighter := nil;
  for I := 0 to fm_Main.ComponentCount-1 do
    if (fm_Main.Components[I] is TSynCustomHighlighter) and
       ((fm_Main.Components[I] as TSynCustomHighlighter).LanguageName =
        cbxHighlighterSelect.Text) then
    begin
      fm_Main.mwceSource.Highlighter := (fm_Main.Components[I] as TSynCustomHighlighter);
      fm_Main.mwceSource.Highlighter.LoadFromRegistry(HKEY_CURRENT_USER,
        RegDiffOptions + '\Highlighters\' +
        fm_Main.mwceSource.Highlighter.LanguageName);

      Break;
    end;
//  StatusBar.SimpleText := '';
  fm_Main.mwceSource.Invalidate;

  edDefaultFilter.Text := '';
  cbxAttrSelect.Enabled := (cbxHighlighterSelect.ItemIndex > 0);
  cocbxAttrForeground.Enabled := (cbxHighlighterSelect.ItemIndex > 0);
  cocbxAttrBackground.Enabled := (cbxHighlighterSelect.ItemIndex > 0);
  grbAttrStyle.Enabled := (cbxHighlighterSelect.ItemIndex > 0);
  grbAttrComments.Enabled := fm_Main.mwceSource.Highlighter is TSynGeneralSyn;
  btnKeywords.Enabled := grbAttrComments.Enabled;
  edDefaultFilter.Enabled := grbAttrComments.Enabled;
  if grbAttrComments.Enabled then
  begin
    with TRegistry.Create do
    begin
      try
        RootKey := HKEY_CURRENT_USER;
        OpenKey(RegDiffOptions + '\Highlighters\General', True);
        if ValueExists('DefaultFilter') then
          edDefaultFilter.Text := ReadString('DefaultFilter')
        else
          edDefaultFilter.Text := '';

        if ValueExists('CommentSet') then
        begin
          ReadBinaryData('CommentSet', CmntSet, SizeOf(CmntSet));
          (fm_Main.mwceSource.Highlighter as TSynGeneralSyn).Comments :=
            CmntSet;
        end;
        CloseKey;
      finally
        Free;
      end;
    end;

    cbCommentsAnsi.Checked := (SynHighlighterGeneral.csAnsiStyle in (fm_Main.mwceSource.Highlighter as TSynGeneralSyn).Comments);
    cbCommentsPas.Checked  := (SynHighlighterGeneral.csPasStyle in (fm_Main.mwceSource.Highlighter as TSynGeneralSyn).Comments);
    cbCommentsC.Checked    := (SynHighlighterGeneral.csCStyle in (fm_Main.mwceSource.Highlighter as TSynGeneralSyn).Comments);
    cbCommentsAsm.Checked  := (SynHighlighterGeneral.csAsmStyle in (fm_Main.mwceSource.Highlighter as TSynGeneralSyn).Comments);
    cbCommentsBas.Checked  := (SynHighlighterGeneral.csBasStyle in (fm_Main.mwceSource.Highlighter as TSynGeneralSyn).Comments);
  end;
  ReloadAttributes;
  CurrentHLName := cbxHighlighterSelect.Text;
end;


procedure Tfm_HighLightProp.cbxAttrSelectChange(Sender: TObject);
var
//hu30.12.2002   Attr: TmwHighLightAttributes;
  Attr: TSynHighlighterAttributes;
begin
//hu30.12.2002   Attr := TmwHighLightAttributes.Create('');
  Attr := TSynHighlighterAttributes.Create('');
  if Assigned(fm_Main.mwceSource.Highlighter) then
    Attr.Assign(fm_Main.mwceSource.Highlighter.Attribute[cbxAttrSelect.ItemIndex]);
  cocbxAttrBackground.ColorValue := Attr.Background;
  cocbxAttrForeground.ColorValue := Attr.Foreground;
  cbStyleBold.Checked := (fsBold in Attr.Style);
  cbStyleItalic.Checked := (fsItalic in Attr.Style);
  cbStyleUnderline.Checked := (fsUnderline in Attr.Style);
  cbStyleStrikeOut.Checked := (fsStrikeOut in Attr.Style);
end;

procedure Tfm_HighLightProp.cocbxAttrForegroundChange(Sender: TObject);
var
//hu30.12.2002   Attr: TmwHighLightAttributes;
  Attr: TSynHighlighterAttributes;
  AttrStyle: TFontStyles;
begin
//hu30.12.2002   Attr := TmwHighLightAttributes.Create(cbxAttrSelect.Items[cbxAttrSelect.ItemIndex]);
  Attr := TSynHighlighterAttributes.Create(cbxAttrSelect.Items[cbxAttrSelect.ItemIndex]);
  AttrStyle := [];
  Attr.Foreground := cocbxAttrForeground.ColorValue;
  Attr.Background := cocbxAttrBackground.ColorValue;
  if cbStyleBold.Checked then
    Include(AttrStyle, fsBold);
  if cbStyleItalic.Checked then
    Include(AttrStyle, fsItalic);
  if cbStyleUnderline.Checked then
    Include(AttrStyle, fsUnderline);
  if cbStyleStrikeOut.Checked then
    Include(AttrStyle, fsStrikeOut);
  Attr.Style := AttrStyle;
  if cbxAttrSelect.ItemIndex>-1 then
  begin
    if Assigned(fm_Main.mwceSource.Highlighter) then
    begin
      fm_Main.mwceSource.Highlighter.Attribute[cbxAttrSelect.ItemIndex].Assign(Attr);
    end;
  end;
  fm_Main.mwceSource.Invalidate;
end;

procedure Tfm_HighLightProp.cbCommentsAnsiClick(Sender: TObject);
var
  CmntSet: SynHighlighterGeneral.TCommentStyles;
begin
  CmntSet := [];
  if cbCommentsAnsi.Checked then Include(CmntSet, SynHighlighterGeneral.csAnsiStyle);
  if cbCommentsPas.Checked  then Include(CmntSet, SynHighlighterGeneral.csPasStyle);
  if cbCommentsC.Checked    then Include(CmntSet, SynHighlighterGeneral.csCStyle);
  if cbCommentsAsm.Checked  then Include(CmntSet, SynHighlighterGeneral.csAsmStyle);
  if cbCommentsBas.Checked  then Include(CmntSet, SynHighlighterGeneral.csBasStyle);
  (fm_Main.mwceSource.Highlighter as TSynGeneralSyn).Comments := CmntSet;
  fm_Main.mwceSource.Invalidate;
end;

procedure Tfm_HighLightProp.edDefaultFilterChange(Sender: TObject);
begin
  if Assigned(fm_Main.mwGeneralSyn1) then
    fm_Main.mwGeneralSyn1.DefaultFilter := edDefaultFilter.Text;
end;

procedure Tfm_HighLightProp.Button1Click(Sender: TObject);
begin
  SaveHighLighterToReg;
  ModalResult := mrOk;
end;

procedure Tfm_HighLightProp.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // set TForm.KeyPreview := true !
  if Key = VK_F1 then
    ShowHelpContext(Application, IDH_jvcsdiff_syntax_highlighter);
end;

end.
