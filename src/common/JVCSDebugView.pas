(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSClientDebugView.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2003/12/27  USchuster - new unit
2003/12/29  USchuster - renamed to JVCSDebugView.pas
2004/02/24  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2005/06/04  USchuster - set memo charset to DEFAULT_CHARSET(necessary for LANGUAGE version)

-----------------------------------------------------------------------------*)

unit JVCSDebugView;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, JvComponent, JvLED, JvExControls;

type
  TfmClientDebugView = class(TForm)
    memRunList: TMemo;
    Panel1: TPanel;
    btnShowRunning: TButton;
    btnShowStatistics: TButton;
    cboxStatisticSort: TComboBox;
    JvTransLED1: TJvLED;
    Timer1: TTimer;
    lbRunCount: TLabel;
    Label1: TLabel;
    procedure btnShowRunningClick(Sender: TObject);
    procedure btnShowStatisticsClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmClientDebugView: TfmClientDebugView;

procedure CreateClientDebugView;

implementation

{$R *.dfm}

uses
  JVCSDebug;

const
  ClientObjectBoolStrs: array [0..1] of string = ('               ', ' [ClientObject]');

procedure CreateClientDebugView;
begin
  if not Assigned(fmClientDebugView) then
    fmClientDebugView := TfmClientDebugView.Create(Application);
  fmClientDebugView.Show;
end;

procedure TfmClientDebugView.btnShowRunningClick(Sender: TObject);
var
  I: Integer;
begin
  memRunList.Lines.Clear;
  for I := 0 to Pred(FunctionDebugList.RunningCount) do
    with FunctionDebugList.RunningItems[I] do
      memRunList.Lines.Add(Format('%s%s runs since %.3f s', [FunctionCode,
        ClientObjectBoolStrs[Integer(ClientObject)], (Now - Start) * 86400]));
end;

procedure TfmClientDebugView.btnShowStatisticsClick(Sender: TObject);
var
  I: Integer;
begin
  memRunList.Lines.Clear;
  FunctionDebugList.StatisticSort := TStatisticSort(cboxStatisticSort.ItemIndex);
  for I := 0 to Pred(FunctionDebugList.StatisticCount) do
    with FunctionDebugList.StatisticItems[I] do
      memRunList.Lines.Add(Format('%-40s%s Runs: %4d Min/Avg./Max Runtime: %5.3f/%5.3f/%5.3f s',
        [FunctionCode, ClientObjectBoolStrs[Integer(ClientObject)], Runs,
          MinRunTime * 86400, (RunTime / Runs) * 86400, MaxRunTime * 86400]));
end;

procedure TfmClientDebugView.Timer1Timer(Sender: TObject);
begin
  if FunctionDebugList.RunningCount > 0 then
    JvTransLED1.ColorOn := clRed
  else
    JvTransLED1.ColorOn := clLime;
  lbRunCount.Caption := IntToStr(FunctionDebugList.RunningCount);
end;

end.
