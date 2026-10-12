(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSSelectBranchDialog.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2006/06/28  USchuster - new unit
2007/07/01  USchuster - changes for large fonts (set AutoScroll to False and Contraints size
                        depend now on PixelsPerInch; analog to Mantis #3710)
2007/10/28  USchuster - added icon to form (necessary for IDE Version)
2010/01/24  USchuster - changes for the selection of a branch to remove (Mantis #5102)
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit JVCSSelectBranchDialog;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, JVCSBranchTreeViewFrame, JVCSGUIClientResources;

type
  TBranchSelectMode = (bsmOpen, bsmRemove);

  TJVCSSelectBranchForm = class(TForm)
    vtBranchFrame: TJVCSBranchTreeViewFrm;
    Panel1: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FMode: TBranchSelectMode;
    function GetSelectedBranchID: Integer;
    procedure HandleFocusChange(ASender: TObject);
    procedure SetMode(const Value: TBranchSelectMode);
    function GetSelectedBranchName: string;
  public
    { Public declarations }
    property Mode: TBranchSelectMode read FMode write SetMode;
    property SelectedBranchID: Integer read GetSelectedBranchID;
    property SelectedBranchName: string read GetSelectedBranchName;
  end;

var
  JVCSSelectBranchForm: TJVCSSelectBranchForm;

function SelectBranch(AMode: TBranchSelectMode; var ABranchName: string): Integer;

implementation

{$R *.dfm}

function SelectBranch(AMode: TBranchSelectMode; var ABranchName: string): Integer;
begin
  Result := -1;
  with TJVCSSelectBranchForm.Create(Application) do
  try
    Mode := AMode;
    if ShowModal = mrOk then
    begin
      Result := SelectedBranchID;
      ABranchName := SelectedBranchName;
    end;
  finally
    Free;
  end;
end;

function TJVCSSelectBranchForm.GetSelectedBranchID: Integer;
begin
  Result := vtBranchFrame.SelectedBranchID;
end;

function TJVCSSelectBranchForm.GetSelectedBranchName: string;
begin
  Result := vtBranchFrame.SelectedBranchName;
end;

procedure TJVCSSelectBranchForm.HandleFocusChange(ASender: TObject);
begin
  if FMode = bsmOpen then
    btnOK.Enabled := SelectedBranchID > 0
  else
  if FMode = bsmRemove then
    btnOK.Enabled := vtBranchFrame.SelectedBranchIsRemovable;
end;

procedure TJVCSSelectBranchForm.SetMode(const Value: TBranchSelectMode);
begin
  FMode := Value;
  if FMode = bsmOpen then
    Caption := JVCSRES_Select_a_Branch_40Open41
  else
  if FMode = bsmRemove then
    Caption := JVCSRES_Select_a_Branch_40Remove41;  
end;

procedure TJVCSSelectBranchForm.FormCreate(Sender: TObject);
begin
  Constraints.MinHeight := MulDiv(240, PixelsPerInch, 96);
  Constraints.MinWidth := MulDiv(330, PixelsPerInch, 96);
  FMode := bsmOpen;
  vtBranchFrame.Init;
  vtBranchFrame.OnSelection := HandleFocusChange;
end;

end.
