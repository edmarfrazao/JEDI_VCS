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

-----------------------------------------------------------------------------*)
{$I jedi.inc}

unit DiffAbout;

{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  JVCSBaseAboutDialog, StdCtrls, ExtCtrls, ComCtrls;

type
  TJVCSDiffAbout = class(TJVCSBaseAboutDlg)
    procedure FormCreate(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
  private
    { Private declarations }
    FCreatedCredits: Boolean;
  protected
    function GetCredits: string;
    function GetVersionInformation(AwithFileDate: Boolean): string; override;
  public
    { Public declarations }
  end;

var
  JVCSDiffAbout: TJVCSDiffAbout;

procedure ShowDiffAboutForm;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  JVCSDiffResources;

{$R *.dfm}

procedure ShowDiffAboutForm;
begin
  JVCSDiffAbout := TJVCSDiffAbout.Create(Application);
  try
    JVCSDiffAbout.ShowModal;
  finally
    JVCSDiffAbout.Free;
  end;
end;

procedure TJVCSDiffAbout.FormCreate(Sender: TObject);
begin
  try
    inherited;
    {$IFDEF BETAVER}
    pnWarning.Visible := True;
    pnWarning.Caption := JVCSRES_Beta_Version;
    {$ENDIF BETAVER}
    FCreatedCredits := False;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

function TJVCSDiffAbout.GetCredits: string;
begin
  Result :=
    JVCSRES_Based_on_FreeVCS_Diff47Merge_Utility_source_by_Thomas_Hensle + #13 +
    '(freevcs@thensle.de) - http://www.freevcs.de' + #13 +
    #13 +
    JVCSRES_Compare_engine_based_on_code_by_Armin_L46_Biernaczyk46 + #13 +
    JVCSRES_Edit_controls47_Syntax_Highlighter58_Opensource_TSynEdit_146146;
end;

function TJVCSDiffAbout.GetVersionInformation(AwithFileDate: Boolean): string;
var
  Msg: string;

  LFileName: string;
begin
  Msg := JVCSRES_JEDI_VCS_Diff47Merge_Utility_ {$IFDEF BETAVER} + JVCSRES_Beta {$ENDIF};

  Msg := Msg + lblProductVersion.Caption + #13;

  if AwithFileDate then
  begin
    LFileName := Application.ExeName;
    Msg := Msg + Format(JVCSRES_Filedate58_37s, [DateTimeToStr(FileDateToDateTime(FileAge(LFileName)))])
           + #13;
  end;

  Msg := Msg + #13 + 
    'call: JEDIVCSDiff.exe /s: /t: /autostart'  + #13 +
    '  /s: = source file'  + #13 +
    '  /t: = target file'  + #13 +
    '  /autostart = start compare immediately';

  Result := Msg;
end;

procedure TJVCSDiffAbout.PageControl1Change(Sender: TObject);
begin
  inherited;
  if (PageControl1.ActivePage = tsCredits) and (not FCreatedCredits) then
  begin
    Memo3.Lines.Text := GetCredits;
    FCreatedCredits := True;
  end;
end;

end.
