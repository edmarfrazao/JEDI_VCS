(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSCreateBranchDialog.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
ToDo:
- check if branch name still exists
- move strings in CreateBranchWizardActivePageChanging to JVCSGUIClientResources
-----------------------------------------------------------------------------

Unit history:

2008/02/16  USchuster - new unit
2008/06/08  USchuster - fixed memory leak (Mantis #3082)
2009/07/12  USchuster - add option Tag Only (does add only the latest revision to the branch)
2009/09/06  USchuster - added path substitution options
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit JVCSCreateBranchDialog;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  JvWizard, JvWizardRouteMapSteps, JvExControls, JvComponent, StdCtrls,
  JvExStdCtrls, JvMemo, VCSBase, JVCSBranchClientObj, JVCSGUIClientResources,
  JVCSBranchTreeViewFrame, Buttons;

type
  TJVCSCreateBranchForm = class(TForm)
    CreateBranchWizard: TJvWizard;
    CreateBranchWizardSteps: TJvWizardRouteMapSteps;
    wipParentBranch: TJvWizardInteriorPage;
    rbCurrentBranch: TRadioButton;
    rbSelectBranch: TRadioButton;
    wipParentBranchSelection: TJvWizardInteriorPage;
    wipNameAndDescription: TJvWizardInteriorPage;
    gbDescription: TGroupBox;
    memDescription: TJvMemo;
    edBranchName: TEdit;
    Label1: TLabel;
    wipSummary: TJvWizardInteriorPage;
    wipBranchCreation: TJvWizardInteriorPage;
    lbCreateBranch: TLabel;
    memSummary: TMemo;
    wipOptions: TJvWizardInteriorPage;
    cbTagOnly: TCheckBox;
    cbSubstituteRootPath: TCheckBox;
    edOldRootPath: TEdit;
    edNewRootPath: TEdit;
    lbOldRootPath: TLabel;
    lbNewRootPath: TLabel;
    spBtnBrowseOld: TSpeedButton;
    spBtnBrowseNew: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure CreateBranchWizardActivePageChanging(Sender: TObject;
      var ToPage: TJvWizardCustomPage);
    procedure rbSelectBranchClick(Sender: TObject);
    procedure edBranchNameChange(Sender: TObject);
    procedure CreateBranchWizardActivePageChanged(Sender: TObject);
    procedure wipBranchCreationFinishButtonClick(Sender: TObject;
      var Stop: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure spBtnBrowseOldClick(Sender: TObject);
    procedure cbSubstituteRootPathClick(Sender: TObject);
    procedure edOldRootPathChange(Sender: TObject);
  private
    { Private declarations }
    FGetBranchList: TJVCSGetBranchList;
    FInCreateBranch: Boolean;
    FNewBranchID: Integer;
    FParentBranchID: Integer;
    FJVCSBranchTreeViewFrm: TJVCSBranchTreeViewFrm;
    procedure HandleSelectedBranch(Sender: TObject);
    procedure NeedGetBranchList;
    function IsPathSubstitutionValid: Boolean;
  public
    { Public declarations }
    property NewBranchID: Integer read FNewBranchID write FNewBranchID;
  end;

var
  JVCSCreateBranchForm: TJVCSCreateBranchForm;

implementation

uses
  DBModule, SelectFolder, VCSProcBase;

{$R *.dfm}

procedure TJVCSCreateBranchForm.FormCreate(Sender: TObject);
begin
  FInCreateBranch := False;
  FNewBranchID := -1;
  FParentBranchID := -1;
  FJVCSBranchTreeViewFrm := nil;
  rbCurrentBranch.Caption := Format(JVCSRES_Current_Branch_6037s62, [sBranchName]);
  rbCurrentBranch.Checked := True;
  rbSelectBranchClick(nil);
  FGetBranchList := nil;
end;

procedure TJVCSCreateBranchForm.CreateBranchWizardActivePageChanging(Sender: TObject;
  var ToPage: TJvWizardCustomPage);
var
  ParentBranchName, BranchDescription: string;
  I: Integer;
begin
  if ToPage = wipParentBranchSelection then
  begin
    if not Assigned(FJVCSBranchTreeViewFrm) then
    begin
      FJVCSBranchTreeViewFrm := TJVCSBranchTreeViewFrm.Create(Self);
      FJVCSBranchTreeViewFrm.Parent := wipParentBranchSelection;
      FJVCSBranchTreeViewFrm.Align := alClient;
      FJVCSBranchTreeViewFrm.OnSelection := HandleSelectedBranch;
      FJVCSBranchTreeViewFrm.Init;
    end;
    wipParentBranchSelection.EnableButton(bkNext, FJVCSBranchTreeViewFrm.SelectedBranchID > 0);
  end
  else
  if ToPage = wipNameAndDescription then
    wipNameAndDescription.EnableButton(bkNext, edBranchName.Text <> '')
  else
  if ToPage = wipOptions then
    cbSubstituteRootPathClick(nil)
  else
  if ToPage = wipSummary then
  begin
    ParentBranchName := '';
    NeedGetBranchList;
    for I := 0 to Pred(FGetBranchList.OutputItemCount) do
      if FGetBranchList.OutputItems[I].BranchID = FParentBranchID then
      begin
        ParentBranchName := FGetBranchList.OutputItems[I].Name;
        Break;
      end;
    memSummary.Lines.Clear;
    memSummary.Lines.Add(JVCSRES_Parent_Branch58);
    memSummary.Lines.Add(ParentBranchName);
    memSummary.Lines.Add('');
    memSummary.Lines.Add(JVCSRES_Branch_Name58);
    memSummary.Lines.Add(edBranchName.Text);
    memSummary.Lines.Add('');
    memSummary.Lines.Add(JVCSRES_Branch_Description58);
    BranchDescription := memDescription.Text;
    if BranchDescription = '' then
      BranchDescription := JVCSRES_60empty62;
    memSummary.Lines.Add(BranchDescription);
    memSummary.Lines.Add('');
    memSummary.Lines.Add('Branch Options:');
    if cbTagOnly.Checked then
      memSummary.Lines.Add('Tag Only (add only the latest revision to the branch)');
    if cbSubstituteRootPath.Checked then
      memSummary.Lines.Add(Format('Substitute Root Path %s with %s', [edOldRootPath.Text, edNewRootPath.Text]));
    wipNameAndDescription.EnableButton(bkNext, FParentBranchID > 0)
  end;
end;

procedure TJVCSCreateBranchForm.rbSelectBranchClick(Sender: TObject);
begin
  wipParentBranchSelection.Enabled := rbSelectBranch.Checked;
  if rbSelectBranch.Checked then
    FParentBranchID := -1
  else
    FParentBranchID := ServerBranchID;
end;

procedure TJVCSCreateBranchForm.spBtnBrowseOldClick(Sender: TObject);
var
  PathEdit: TEdit;
begin
  if Sender = spBtnBrowseOld then
    PathEdit := edOldRootPath
  else
    PathEdit := edNewRootPath;
  VCSSelectFolder := TVCSSelectFolder.Create(Application);
  try
    VCSSelectFolder.SetStatusText('');
    VCSSelectFolder.EnableRecursive(False);
    VCSSelectFolder.HelpContextID := -1;    
    if PathEdit.Text <> '' then
      VCSSelectFolder.SetInitialDir(ExtractFilePath(PathEdit.Text));
    VCSSelectFolder.EnableNewFolder(False);
    VCSSelectFolder.ShowModal;
    if VCSSelectFolder.Selection <> '' then
      PathEdit.Text := SetBackSlash(AnsiLowerCase(VCSSelectFolder.Selection));
  finally
    VCSSelectFolder.Free;
  end;
end;

procedure TJVCSCreateBranchForm.HandleSelectedBranch(Sender: TObject);
begin
  wipParentBranchSelection.EnableButton(bkNext, FJVCSBranchTreeViewFrm.SelectedBranchID > 0);
  FParentBranchID := FJVCSBranchTreeViewFrm.SelectedBranchID;
  CreateBranchWizardSteps.Invalidate;
end;

function TJVCSCreateBranchForm.IsPathSubstitutionValid: Boolean;
var
  OldRootPath, NewRootPath: string;
begin
  if cbSubstituteRootPath.Checked then
  begin
    OldRootPath := AnsiLowerCase(ExtractFilePath(edOldRootPath.Text));
    NewRootPath := AnsiLowerCase(ExtractFilePath(edNewRootPath.Text));
    Result := (OldRootPath <> '') and (NewRootPath <> '') and (OldRootPath <> NewRootPath);
  end
  else
    Result := True;
end;

procedure TJVCSCreateBranchForm.NeedGetBranchList;
begin
  if not Assigned(FGetBranchList) then
  begin
    FGetBranchList := TJVCSGetBranchList.Create(nil);
    FGetBranchList.IncludeDetails := False;
    DataModule1.ClientObjectSendRequest(FGetBranchList);
  end;
end;

procedure TJVCSCreateBranchForm.edBranchNameChange(Sender: TObject);
begin
  wipNameAndDescription.EnableButton(bkNext, edBranchName.Text <> '');
  CreateBranchWizardSteps.Invalidate;
end;

procedure TJVCSCreateBranchForm.edOldRootPathChange(Sender: TObject);
begin
  wipOptions.EnableButton(bkNext, IsPathSubstitutionValid);
end;

procedure TJVCSCreateBranchForm.cbSubstituteRootPathClick(Sender: TObject);
var
  ControlsEnabled: Boolean;
begin
  ControlsEnabled := cbSubstituteRootPath.Checked;
  edOldRootPath.Enabled := ControlsEnabled;
  edNewRootPath.Enabled := ControlsEnabled;
  spBtnBrowseOld.Enabled := ControlsEnabled;
  spBtnBrowseNew.Enabled := ControlsEnabled;
  lbOldRootPath.Enabled := ControlsEnabled;  
  lbNewRootPath.Enabled := ControlsEnabled;
  wipOptions.EnableButton(bkNext, IsPathSubstitutionValid);
end;

procedure TJVCSCreateBranchForm.CreateBranchWizardActivePageChanged(Sender: TObject);
var
  AddBranch: TJVCSAddBranch;
begin
  if (CreateBranchWizard.ActivePage = wipBranchCreation) and (not FInCreateBranch) then
  begin
    FInCreateBranch := True;
    try
      Application.ProcessMessages;
      AddBranch := TJVCSAddBranch.Create(nil);
      try
        AddBranch.ParentBranchID := FParentBranchID;
        AddBranch.UserID := ServerUserID;
        AddBranch.BranchName := edBranchName.Text;
        AddBranch.Description := memDescription.Text;
        AddBranch.TagOnly := cbTagOnly.Checked;
        AddBranch.SubstituteRootPath := cbSubstituteRootPath.Checked;
        if AddBranch.SubstituteRootPath then
        begin
          AddBranch.OldRootPath := AnsiLowerCase(edOldRootPath.Text);
          AddBranch.NewRootPath := AnsiLowerCase(edNewRootPath.Text);
        end;
        DataModule1.ClientObjectSendRequest(AddBranch);
        FNewBranchID := AddBranch.BranchID;
        if AddBranch.IsNewBranch and (FNewBranchID > 0) then
          lbCreateBranch.Caption := JVCSRES_Branch_creation_was_successful46
        else
        begin
          lbCreateBranch.Font.Color := clRed;
          lbCreateBranch.Caption := JVCSRES_Branch_creation_failed33;
        end;
      finally
        AddBranch.Free;
      end;
    finally
      FInCreateBranch := False;
    end;
    wipBranchCreation.EnableButton(bkFinish, True);
  end;
end;

procedure TJVCSCreateBranchForm.wipBranchCreationFinishButtonClick(Sender: TObject;
  var Stop: Boolean);
begin
  Stop := True;
  Close;
end;

procedure TJVCSCreateBranchForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := not FInCreateBranch;
end;

procedure TJVCSCreateBranchForm.FormDestroy(Sender: TObject);
begin
  FGetBranchList.Free;
end;

end.
