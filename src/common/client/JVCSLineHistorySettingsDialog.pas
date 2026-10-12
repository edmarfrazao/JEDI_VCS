(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSLineHistorySettingsDialog.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2006/12/03  USchuster - new unit
2007/06/27  USchuster - changes for large fonts (set AutoScroll to False and changed contraints; Mantis #1034)
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2009/03/21  USchuster - changes for defining alternative visible user names
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit JVCSLineHistorySettingsDialog;

{$I jedi.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, JVCSLineHistoryUnit, JvExExtCtrls,
  JvOfficeColorButton, JvExControls, JvColorBox, JvColorButton,
  JvGradient, VirtualTrees, Buttons, JvDialogs, JVCSForms, JvExtComponent;

type
  TJVCSLineHistorySettingsDlg = class(TJVCSForm)
    pnlBottom: TPanel;
    btnOK: TButton;
    btnApply: TButton;
    btnCancel: TButton;
    VSTUserColors: TVirtualStringTree;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    JvGradient1: TJvGradient;
    JvGradient2: TJvGradient;
    spBtnClear: TSpeedButton;
    spBtnAdd: TSpeedButton;
    cbtnDateTo: TJvOfficeColorButton;
    cbtnRevisionFrom: TJvOfficeColorButton;
    cbtnRevisionTo: TJvOfficeColorButton;
    cbtnDateFrom: TJvOfficeColorButton;
    cbtnUserColor: TJvOfficeColorButton;
    JvColorDialog1: TJvColorDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cbtnDateFromColorChange(Sender: TObject);
    procedure cbtnRevisionFromColorChange(Sender: TObject);
    procedure VSTUserColorsGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure spBtnClearClick(Sender: TObject);
    procedure VSTUserColorsAfterCellPaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      CellRect: TRect);
    procedure VSTUserColorsDblClick(Sender: TObject);
    procedure spBtnAddClick(Sender: TObject);
    procedure VSTUserColorsFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure cbtnUserColorColorChange(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
  private
    { Private declarations }
    FSettings: TJVCSLineHistorySettings;
    FOnApply: TNotifyEvent;
    function GetSettings: TJVCSLineHistorySettings;
    procedure GetSettingsFromControls;
    procedure SetSettings(AValue: TJVCSLineHistorySettings);
    procedure SetSettingsToControls;
  public
    { Public declarations }
    property Settings: TJVCSLineHistorySettings read GetSettings write SetSettings;
    property OnApply: TNotifyEvent read FOnApply write FOnApply;
  end;

var
  JVCSLineHistorySettingsDlg: TJVCSLineHistorySettingsDlg;

implementation

{$R *.dfm}

procedure TJVCSLineHistorySettingsDlg.FormCreate(Sender: TObject);
begin
  Constraints.MinHeight := Height;
  Constraints.MinWidth := Width;
  FSettings := TJVCSLineHistorySettings.Create;
  FOnApply := nil;
  VSTUserColorsFocusChanged(nil, nil, -1);
end;

procedure TJVCSLineHistorySettingsDlg.FormDestroy(Sender: TObject);
begin
  FSettings.Free;
end;

function TJVCSLineHistorySettingsDlg.GetSettings: TJVCSLineHistorySettings;
begin
  GetSettingsFromControls;
  Result := FSettings;
end;

procedure TJVCSLineHistorySettingsDlg.GetSettingsFromControls;
begin
  FSettings.DateStartColor := cbtnDateFrom.SelectedColor;
  FSettings.DateEndColor := cbtnDateTo.SelectedColor;
  FSettings.RevisionStartColor := cbtnRevisionFrom.SelectedColor;
  FSettings.RevisionEndColor := cbtnRevisionTo.SelectedColor;
end;

procedure TJVCSLineHistorySettingsDlg.SetSettings(AValue: TJVCSLineHistorySettings);
begin
  VSTUserColors.BeginUpdate;
  try
    FSettings.Assign(AValue);
    SetSettingsToControls;
  finally
    VSTUserColors.EndUpdate;
  end;
end;

procedure TJVCSLineHistorySettingsDlg.SetSettingsToControls;
begin
  cbtnDateFrom.SelectedColor := FSettings.DateStartColor;
  cbtnDateTo.SelectedColor := FSettings.DateEndColor;
  cbtnRevisionFrom.SelectedColor := FSettings.RevisionStartColor;
  cbtnRevisionTo.SelectedColor := FSettings.RevisionEndColor;
  VSTUserColors.RootNodeCount := FSettings.UserSettingsList.Count;
end;

procedure TJVCSLineHistorySettingsDlg.cbtnDateFromColorChange(
  Sender: TObject);
begin
  JvGradient1.StartColor := cbtnDateFrom.SelectedColor;
  JvGradient1.EndColor := cbtnDateTo.SelectedColor;
end;

procedure TJVCSLineHistorySettingsDlg.cbtnRevisionFromColorChange(
  Sender: TObject);
begin
  JvGradient2.StartColor := cbtnRevisionFrom.SelectedColor;
  JvGradient2.EndColor := cbtnRevisionTo.SelectedColor;
end;

procedure TJVCSLineHistorySettingsDlg.VSTUserColorsGetText(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType; var CellText: WideString);
begin
  CellText := '';
  if Column = 0 then
    CellText := FSettings.UserSettingsList[Node^.Index].UserName
  else
  if Column = 2 then
    CellText := FSettings.UserSettingsList[Node^.Index].VisibleName;
end;

procedure TJVCSLineHistorySettingsDlg.spBtnClearClick(Sender: TObject);
begin
  if Assigned(VSTUserColors.FocusedNode) then
  begin
    VSTUserColors.BeginUpdate;
    try
      FSettings.UserSettingsList.Delete(VSTUserColors.FocusedNode^.Index);
      VSTUserColors.RootNodeCount := FSettings.UserSettingsList.Count;
    finally
      VSTUserColors.EndUpdate;
    end;
  end;
end;

procedure TJVCSLineHistorySettingsDlg.VSTUserColorsAfterCellPaint(
  Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
  Column: TColumnIndex; CellRect: TRect);
begin
  if Column = 1 then
    with TargetCanvas do
    begin
      InflateRect(CellRect, -2, -2);
      Brush.Color := FSettings.UserSettingsList[Node^.Index].Color;
      FillRect(CellRect);
    end;
end;

procedure TJVCSLineHistorySettingsDlg.VSTUserColorsDblClick(
  Sender: TObject);
var
  Node: PVirtualNode;
  VisibleName: string;
begin
  Node := VSTUserColors.FocusedNode;
  if Assigned(Node) then
  begin
    JvColorDialog1.Color := FSettings.UserSettingsList[Node^.Index].Color;
    if JvColorDialog1.Execute then
    begin
      VisibleName := FSettings.UserSettingsList[Node^.Index].VisibleName;
      if InputQuery('Modify User', 'User visible name', VisibleName) then
        FSettings.UserSettingsList[Node^.Index].VisibleName := VisibleName;
      FSettings.UserSettingsList[Node^.Index].Color := JvColorDialog1.Color;
      VSTUserColors.Invalidate;
      VSTUserColorsFocusChanged(nil, Node, -1);
    end;
  end;
end;

procedure TJVCSLineHistorySettingsDlg.spBtnAddClick(Sender: TObject);
var
  UserName, VisibleName: string;
  UserSettingsItem: TJVCSLineHistoryUserSettingsItem;
begin
  if InputQuery('Add User', 'User name', UserName) then
  begin
    if FSettings.UserSettingsList.IndexOfUser(UserName) <> -1 then
    begin

    end
    else
    begin
      JvColorDialog1.Color := clNone;
      if JvColorDialog1.Execute then
      begin
        VisibleName := '';
        InputQuery('Add User', 'User visible name', VisibleName);
        VSTUserColors.BeginUpdate;
        try
          UserSettingsItem := FSettings.UserSettingsList.Add;
          UserSettingsItem.UserName := UserName;
          UserSettingsItem.Color := JvColorDialog1.Color;
          UserSettingsItem.VisibleName := VisibleName;
          VSTUserColors.RootNodeCount := FSettings.UserSettingsList.Count;
        finally
          VSTUserColors.EndUpdate;
        end;
      end;
    end;
  end;
end;

procedure TJVCSLineHistorySettingsDlg.VSTUserColorsFocusChanged(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
begin
  spBtnClear.Enabled := Assigned(Node);
  cbtnUserColor.Enabled := Assigned(Node);
  if not Assigned(Node) then
    cbtnUserColor.SelectedColor := clNone
  else
    cbtnUserColor.SelectedColor := FSettings.UserSettingsList[Node^.Index].Color;
end;

procedure TJVCSLineHistorySettingsDlg.cbtnUserColorColorChange(
  Sender: TObject);
begin
  if Assigned(VSTUserColors.FocusedNode) then
  begin
    FSettings.UserSettingsList[VSTUserColors.FocusedNode^.Index].Color := cbtnUserColor.SelectedColor;
    VSTUserColors.Invalidate;
  end;
end;

procedure TJVCSLineHistorySettingsDlg.btnApplyClick(Sender: TObject);
begin
  if Assigned(FOnApply) then
    FOnApply(Settings);
end;

end.
