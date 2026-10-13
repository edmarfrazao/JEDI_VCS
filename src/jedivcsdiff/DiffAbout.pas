(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: DiffAbout.pas

The Initial Developer of the original code (JEDIVCSDiff) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2004/01/18  USchuster - new unit (replace old about message box with standard dialog)
2004/11/12  USchuster - added dxGetText support for localization with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2026/10/12  v2026     - port Delphi 13: dialogo proprio montado em codigo (sem DFM
                        e sem herdar de JVCSBaseAboutDialog, que usa TJvRichEdit e
                        as units do EXE); mostra versao, credito e parametros

-----------------------------------------------------------------------------*)
{$I jedi.inc}

unit DiffAbout;

{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, JVCSForms;

type
  TJVCSDiffAbout = class(TJVCSForm)
  private
    FPages: TPageControl;
    FBtnClose: TButton;
    function AddPage(const ACaption, AText: string): TMemo;
  protected
    function GetCredits: string;
    function GetVersionInformation(AwithFileDate: Boolean): string;
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  JVCSDiffAbout: TJVCSDiffAbout;

procedure ShowDiffAboutForm;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  DiffUtils, JVCSUIScale, JVCSDiffResources;

procedure ShowDiffAboutForm;
begin
  JVCSDiffAbout := TJVCSDiffAbout.Create(Application);
  try
    JVCSDiffAbout.ShowModal;
  finally
    FreeAndNil(JVCSDiffAbout);
  end;
end;

constructor TJVCSDiffAbout.Create(AOwner: TComponent);
var
  Bottom: TPanel;
begin
  CreateNew(AOwner);
  Caption := JVCSRES_About_JEDI_VCS_Diff;
  BorderStyle := bsDialog;
  Position := poMainFormCenter;
  ClientWidth := 520;
  ClientHeight := 360;
  Font.Name := 'Tahoma';
  Font.Height := -11;

  Bottom := TPanel.Create(Self);
  Bottom.Parent := Self;
  Bottom.Align := alBottom;
  Bottom.Height := 41;
  Bottom.BevelOuter := bvNone;

  FBtnClose := TButton.Create(Self);
  FBtnClose.Parent := Bottom;
  FBtnClose.Caption := 'OK';
  FBtnClose.Default := True;
  FBtnClose.Cancel := True;
  FBtnClose.ModalResult := mrOk;
  FBtnClose.SetBounds(Bottom.Width - 88, 8, 80, 25);
  FBtnClose.Anchors := [akTop, akRight];

  FPages := TPageControl.Create(Self);
  FPages.Parent := Self;
  FPages.Align := alClient;
  FPages.AlignWithMargins := True;

  AddPage('&About', GetVersionInformation(False) + #13#10 +
    'Web: http://jedivcs.sourceforge.net/' + #13#10 +
    'Source codes based on Thomas Hensle''s FreeVCS Diff/Merge.' + #13#10 +
    'Released under MPL 1.1.');
  AddPage('&' + JVCSRES_Version_information, GetVersionInformation(True));
  AddPage('&' + JVCSRES_Credits, GetCredits);

  JVCSUIApplyToForm(Self);
  {$IFDEF LANGUAGE}
  TranslateComponent(Self);
  {$ENDIF LANGUAGE}
end;

function TJVCSDiffAbout.AddPage(const ACaption, AText: string): TMemo;
var
  Sheet: TTabSheet;
begin
  Sheet := TTabSheet.Create(Self);
  Sheet.PageControl := FPages;
  Sheet.Caption := ACaption;
  Result := TMemo.Create(Self);
  Result.Parent := Sheet;
  Result.Align := alClient;
  Result.ReadOnly := True;
  Result.ScrollBars := ssVertical;
  Result.WordWrap := True;
  Result.Lines.Text := AText;
end;

function TJVCSDiffAbout.GetCredits: string;
begin
  Result :=
    JVCSRES_Based_on_FreeVCS_Diff47Merge_Utility_source_by_Thomas_Hensle + #13#10 +
    '(freevcs@thensle.de) - http://www.freevcs.de' + #13#10 +
    #13#10 +
    JVCSRES_Compare_engine_based_on_code_by_Armin_L46_Biernaczyk46 + #13#10 +
    JVCSRES_Edit_controls47_Syntax_Highlighter58_Opensource_TSynEdit_146146;
end;

function TJVCSDiffAbout.GetVersionInformation(AwithFileDate: Boolean): string;
var
  Msg, LFileName, Ver, Stamp: string;
  DT: TDateTime;
begin
  LFileName := Application.ExeName;
  Ver := DiffFileVersionValue(LFileName, 'ProductVersion');
  Stamp := DiffFileVersionValue(LFileName, 'BuildTimestamp');
  Msg := JVCSRES_JEDI_VCS_Diff47Merge_Utility_ {$IFDEF BETAVER} + JVCSRES_Beta {$ENDIF};
  Msg := Msg + 'V ' + Ver;
  if Stamp <> '' then
    Msg := Msg + ' - Buildtime ' + Stamp;
  Msg := Msg + #13#10 + 'File version ' + DiffFileVersionValue(LFileName, 'FileVersion') + #13#10;

  if AwithFileDate and FileAge(LFileName, DT) then
    Msg := Msg + Format(JVCSRES_Filedate58_37s, [DateTimeToStr(DT)]) + #13#10;

  Msg := Msg + #13#10 + JVCSRES_Command_line + ':' + #13#10 +
    'JEDIVCSDiff.exe /s:<file> /t:<file> [/sc:<text>] [/tc:<text>] [/autostart]' + #13#10 +
    '  /s: = source (base) file' + #13#10 +
    '  /t: = target (compare to) file' + #13#10 +
    '  /sc:, /tc: = header text for source/target' + #13#10 +
    '  /autostart = start compare immediately' + #13#10 +
    '  /log:<file> = append the result to <file> (no result dialog)' + #13#10 +
    '  /close = close after /autostart (exit code 0 equal, 1 different, 2 error)';

  Result := Msg;
end;

end.
