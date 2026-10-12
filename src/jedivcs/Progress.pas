(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: Progress

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
2004/09/17  FHasovic  - Added dxGetText support for localization                      
2004/10/24  USchuster - style cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
2005/07/24  USchuster - added new procedure ShowAndRunAction(for mantis #3108)
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit Progress;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Buttons, ExtCtrls, JVCSForms;

type
  TVCSProgress = class(TJVCSForm)
    Panel1: TPanel;
    ProgressBar1: TProgressBar;
    Label1: TLabel;
    procedure spBtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private-Deklarationen }
    FAction: TNotifyEvent;
    FExecutedAction: Boolean;
  public
    { Public-Deklarationen }
    ProgrCancel: Boolean;
    procedure SetText(Value: string);
    procedure SetPBMax(Value: Integer);
    procedure SetPBStepIt;
    procedure SetPBPos(Value: Integer);
    procedure EnableCancel(Value: Boolean);
    procedure ShowAndRunAction(Value: TNotifyEvent);
  end;

var
  VCSProgress: TVCSProgress;

implementation

{$IFDEF LANGUAGE}
uses
  JvGnugettext;
{$ENDIF LANGUAGE}

{$R *.dfm}

procedure TVCSProgress.FormCreate(Sender: TObject);
begin
  try
    //  spBtnCancel.Enabled := false;
    ProgrCancel := False;
    FAction := nil;
    FExecutedAction := False;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSProgress.SetText(Value: string);
begin
  Label1.Caption := Value;
end;

//------------------------------------------------------------------------------

procedure TVCSProgress.SetPBMax(Value: Integer);
begin
  ProgressBar1.Max := Value;
end;

//------------------------------------------------------------------------------

procedure TVCSProgress.SetPBStepIt;
begin
  ProgressBar1.StepIt;
end;

//------------------------------------------------------------------------------

procedure TVCSProgress.SetPBPos(Value: Integer);
begin
  ProgressBar1.Position := Value;
end;

//------------------------------------------------------------------------------

procedure TVCSProgress.EnableCancel(Value: Boolean);
begin
  //  spBtnCancel.Enabled := Value;
end;

//------------------------------------------------------------------------------

procedure TVCSProgress.spBtnCancelClick(Sender: TObject);
begin
  ProgrCancel := True;
end;

procedure TVCSProgress.ShowAndRunAction(Value: TNotifyEvent);
begin
  FAction := Value;
  FExecutedAction := False;
  ShowModal;
end;

procedure TVCSProgress.FormActivate(Sender: TObject);
begin
  if Assigned(FAction) and (not FExecutedAction) then
  begin
    FExecutedAction := True;
    try
      FAction(Self);
    finally
      PostMessage(Handle, WM_CLOSE, 0, 0);
    end;
  end;
end;

end.
