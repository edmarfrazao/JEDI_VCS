(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSLabelHistory.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2008/07/23  USchuster - new unit
2008/07/27  USchuster - changes for large fonts (set AutoScroll to False)
                      - changes for modules without "From" label
2008/12/21  USchuster - changes for new mode "Label to latest"
2008/12/23  USchuster - changes for new mode "Branchpoint to latest"
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit JVCSLabelHistory;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, EnhListView, ExtCtrls, JVCSClientObj, JVCSGUIClientResources,
  VCSBase, JVCSBranchClientObj;

type
  TProjectDiffMode = (pdmLabelToLabel, pdmLabelToLatest, pdmBranchpointToLatest);

  TVCSLabelHistory = class(TForm)
    Panel1: TPanel;
    elvHistory: TdfsEnhListView;
    lbFromLabel: TLabel;
    cbFromLabel: TComboBox;
    cbToLabel: TComboBox;
    lbToLabel: TLabel;
    cbProjects: TComboBox;
    Label3: TLabel;
    btnGenerate: TButton;
    btnReport: TButton;
    btnClose: TButton;
    cbMode: TComboBox;
    Label4: TLabel;
    procedure btnCloseClick(Sender: TObject);
    procedure btnReportClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnGenerateClick(Sender: TObject);
    procedure cbFromLabelChange(Sender: TObject);
  private
    { Private declarations }
    function GetListViewString: string;
    procedure LabelDiff(AMode: TProjectDiffMode; ALabelID1, ALabelID2, AProjectID: Integer; AIncludeModulesWithoutFirstRevision: Boolean);
  public
    { Public declarations }
  end;

var
  VCSLabelHistory: TVCSLabelHistory;

implementation

uses
  ListView, SimpleReport, DBModule, Progress;

{$R *.dfm}

procedure TVCSLabelHistory.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TVCSLabelHistory.btnReportClick(Sender: TObject);
var
  ResultString: string;
begin
  if VCSListView <> nil then
  begin
    VCSListView.Free;
    VCSListView := nil;
  end;
  ResultString := GetListViewString;
  if ResultString = '' then 
    Exit;

  VCSSimpleReport := TVCSSimpleReport.Create(Application);
  try
    VCSSimpleReport.RepID := 10;  
    VCSSimpleReport.Left := Left + 60;
    VCSSimpleReport.Top := Top + 60;
    VCSSimpleReport.FullReportString := ResultString;
    VCSSimpleReport.SavePath := '';
    VCSSimpleReport.SaveFileName := 'LabelHistory.txt';
    VCSSimpleReport.LineCount := elvHistory.Items.Count + 8;
    VCSSimpleReport.ShowModal;
  finally
    VCSSimpleReport.Free;
  end;
end;

function TVCSLabelHistory.GetListViewString: string;
var 
  CurrentText: string;
  I, J: Integer;
  oaColumnsWidth: array of Integer;
const 
  cr = Chr(13) + Chr(10);

  function SizeString(const Column: Integer; const CellString: string;
    const Fillchr: Char): string;
  var 
    K: Integer;
  begin
    Result := CellString;
    if Length(Result) > 0 then
      for K := 1 to Length(Result) do 
      begin
        if (Result[K] = Chr(10)) or (Result[K] = Chr(13)) then 
        begin
          System.Delete(Result, K, 1);
          System.Insert('\', Result, K);
        end;
      end;
    while Length(Result) < oaColumnsWidth[Column] do
      Result := Result + Fillchr;
  end;
begin
  Result := '';
  Screen.Cursor := crHourGlass;
  try
    with elvHistory do 
    begin
      if Items.Count = 0 then 
      begin
        MessageBox(WindowHandle, PChar(JVCSRES_Requested_result_set_is_blank46_Nothing_to_do46),
          cMsgBoxCaption, MB_OK);
        Exit;
      end;
      // Textlänge in der Spalte?
      SetLength(oaColumnsWidth, Columns.Count);
      for I := 0 to Columns.Count - 1 do 
      begin
        oaColumnsWidth[I] := Length(Columns[I].Caption);
        for J := 0 to Items.Count - 1 do 
        begin
          if I = 0 then 
            CurrentText := Items[J].Caption
          else 
            CurrentText := Items[J].SubItems[I - 1];
          if Length(CurrentText) > oaColumnsWidth[I] then
            oaColumnsWidth[I] := Length(CurrentText);
        end; // for J := 0 to Items.Count - 1 do begin
      end; // for I := 0 to Columns.Count - 1 do begin

      Result := Caption + cr;
      CurrentText := '';
      while Length(CurrentText) < Length(Caption) do
        CurrentText := CurrentText + '=';
      Result := Result + CurrentText + cr + cr;

      for J := 0 to Columns.Count - 1 do 
      begin
        Result := Result + SizeString(J, Columns[J].Caption, ' ');
        if J < (Columns.Count - 1) then 
          Result := Result + ' | ';
      end;
      Result := Result + cr;
      for J := 0 to Columns.Count - 1 do 
      begin
        Result := Result + SizeString(J, '-', '-');
        if J < (Columns.Count - 1) then 
          Result := Result + ' | ';
      end;
      Result := Result + cr;

      for I := 0 to Items.Count - 1 do 
      begin
        for J := 0 to Columns.Count - 1 do
        begin
          if J = 0 then
            CurrentText := Items[I].Caption
          else
            CurrentText := Items[I].SubItems[J - 1];
          Result := Result + SizeString(J, CurrentText, ' ');
          if J < (Columns.Count - 1) then 
            Result := Result + ' | ';
        end; // for J := 0 to Columns.Count - 1 do begin
        Result := Result + cr;
      end; // for I := 0 to Items.Count - 1 do begin
    end; // with elv do begin

    Result := Result + cr + JVCSRES_Source58_ + sArchiveSource + cr +
      JVCSRES_JEDI_VCS_ + sProductVer + cProductInf + DateTimeToStr(Now) + cr;
  finally
    Screen.Cursor := crDefault;
    SetLength(oaColumnsWidth, 0);
  end;
end;

procedure TVCSLabelHistory.FormCreate(Sender: TObject);
var
  GetLabels: TJVCSGetLabels;
  GetProjectList: TJVCSGetProjectList;
  I: Integer;
begin
  GetLabels := TJVCSGetLabels.Create(nil);
  try
    DataModule1.ClientObjectSendRequest(GetLabels);
    cbFromLabel.Items.Clear;
    cbToLabel.Items.Clear;
    for I := 0 to Pred(GetLabels.OutputItemCount) do
      with GetLabels.OutputItems[I] do
      begin
        cbFromLabel.Items.AddObject(LabelName, TObject(LabelID));
        cbToLabel.Items.AddObject(LabelName, TObject(LabelID));
      end;
  finally
    GetLabels.Free;
  end;
  GetProjectList := TJVCSGetProjectList.Create(nil);
  try
    DataModule1.ClientObjectSendRequest(GetProjectList);
    cbProjects.Items.Clear;
    for I := 0 to Pred(GetProjectList.OutputItemCount) do
      with GetProjectList.OutputItems[I] do
        cbProjects.Items.AddObject(ProjectName, TObject(ProjectID));
  finally
    GetProjectList.Free;
  end;
  if nServerVersion < 250 then
    cbMode.Items.Delete(2);
  cbMode.ItemIndex := 0;
end;

procedure TVCSLabelHistory.LabelDiff(AMode: TProjectDiffMode; ALabelID1, ALabelID2, AProjectID: Integer; AIncludeModulesWithoutFirstRevision: Boolean);
var
  GetLatestRevisionsL1: TJVCSGetLatestRevisions;
  GetBranchpointRevisions: TJVCSGetBranchpointRevisions;
  GetLatestRevisionsL2: TJVCSGetLatestRevisions;
  GetModuleHistory: TJVCSGetModuleHistory;
  I, J, ModuleID, LastModuleID, ModuleIdx: Integer;
  FirstVersion, FirstRevision, SecondVersion, SecondRevision,
  CurrentVersion, CurrentRevision, LastRevisionID: Integer;
  ListItem: TListItem;
begin
  VCSProgress := TVCSProgress.Create(Self);
  try
    VCSProgress.SetText('Generate Diff');
    VCSProgress.SetPBMax(10);
    VCSProgress.SetPBPos(0);
    VCSProgress.Left := Left + 40;
    VCSProgress.Top := Top + 60;
    VCSProgress.Show;
    Application.ProcessMessages;
    elvHistory.Items.BeginUpdate;
    try
      elvHistory.Items.Clear;
      GetLatestRevisionsL1 := TJVCSGetLatestRevisions.Create(nil);
      GetBranchpointRevisions := TJVCSGetBranchpointRevisions.Create(nil);
      GetLatestRevisionsL2 := TJVCSGetLatestRevisions.Create(nil);
      try
        if AMode = pdmBranchpointToLatest then
        begin
          GetBranchpointRevisions.ProjectID := AProjectID;
          DataModule1.ClientObjectSendRequest(GetBranchpointRevisions);
        end
        else
        begin
          GetLatestRevisionsL1.ProjectID := AProjectID;
          GetLatestRevisionsL1.LabelID := ALabelID1;
          DataModule1.ClientObjectSendRequest(GetLatestRevisionsL1);
        end;
        VCSProgress.SetPBPos(1);
        Application.ProcessMessages;
        GetLatestRevisionsL2.ProjectID := AProjectID;
        if AMode = pdmLabelToLabel then
          GetLatestRevisionsL2.LabelID := ALabelID2
        else
          GetLatestRevisionsL2.LabelID := 0;
        DataModule1.ClientObjectSendRequest(GetLatestRevisionsL2);
        VCSProgress.SetPBPos(2);
        Application.ProcessMessages;
        LastModuleID := -1;
        VCSProgress.SetPBPos(0);
        VCSProgress.SetPBMax(GetLatestRevisionsL2.OutputItemCount + GetLatestRevisionsL2.OutputItemCount div 4);
        VCSProgress.SetPBPos(GetLatestRevisionsL2.OutputItemCount div 4);
        Application.ProcessMessages;
        for I := 0 to Pred(GetLatestRevisionsL2.OutputItemCount) do
        begin
          ModuleID := GetLatestRevisionsL2.OutputItems[I].ModuleID;
          if ModuleID <> LastModuleID then
          begin
            LastModuleID := ModuleID;
            SecondVersion := GetLatestRevisionsL2.OutputItems[I].Version;
            SecondRevision := GetLatestRevisionsL2.OutputItems[I].Revision;
            ModuleIdx := -1;
            FirstVersion := 0;
            FirstRevision := 0;
            if AMode = pdmBranchpointToLatest then
            begin
              for J := 0 to Pred(GetBranchpointRevisions.OutputItemCount) do
                if GetBranchpointRevisions.OutputItems[J].ModuleID = ModuleID then
                begin
                  ModuleIdx := J;
                  FirstVersion := GetBranchpointRevisions.OutputItems[J].Version;
                  FirstRevision := GetBranchpointRevisions.OutputItems[J].Revision;
                  Break;
                end;
            end
            else
            begin
              for J := 0 to Pred(GetLatestRevisionsL1.OutputItemCount) do
                if GetLatestRevisionsL1.OutputItems[J].ModuleID = ModuleID then
                begin
                  ModuleIdx := J;
                  FirstVersion := GetLatestRevisionsL1.OutputItems[J].Version;
                  FirstRevision := GetLatestRevisionsL1.OutputItems[J].Revision;
                  Break;
                end;
            end;
            if ((ModuleIdx <> -1) or AIncludeModulesWithoutFirstRevision) and
              (not ((FirstVersion = SecondVersion) and (FirstRevision = SecondRevision))) then
            begin
              GetModuleHistory := TJVCSGetModuleHistory.Create(nil);
              try
                GetModuleHistory.ModuleID := ModuleID;
                DataModule1.ClientObjectSendRequest(GetModuleHistory);
                LastRevisionID := -1;
                for J := 0 to Pred(GetModuleHistory.OutputItemCount) do
                begin
                  CurrentVersion := GetModuleHistory.OutputItems[J].Version;
                  CurrentRevision := GetModuleHistory.OutputItems[J].Revision;
                  if (LastRevisionID <> GetModuleHistory.OutputItems[J].RevisionID) and
                    (((ModuleIdx <> -1) and ((CurrentVersion > FirstVersion) or ((CurrentVersion = FirstVersion) and (CurrentRevision > FirstRevision)))) or
                      ((ModuleIdx = -1) and (AIncludeModulesWithoutFirstRevision))) and
                    ((CurrentVersion < SecondVersion) or ((CurrentVersion = SecondVersion) and (CurrentRevision <= SecondRevision))) then
                  begin
                    ListItem := elvHistory.Items.Add;
                    ListItem.Caption := GetLatestRevisionsL2.OutputItems[I].ModulePath;
                    ListItem.SubItems.Add(GetLatestRevisionsL2.OutputItems[I].ModuleName);
                    ListItem.SubItems.Add(Format('%d.%d', [CurrentVersion, CurrentRevision]));
                    ListItem.SubItems.Add(GetModuleHistory.OutputItems[J].CheckinComment);
                  end;
                  LastRevisionID := GetModuleHistory.OutputItems[J].RevisionID;
                end;
              finally
                GetModuleHistory.Free;
              end;
            end;
          end;
          VCSProgress.SetPBPos(GetLatestRevisionsL2.OutputItemCount div 4 + I + 1);
          Application.ProcessMessages;
        end;
      finally
        GetLatestRevisionsL1.Free;
        GetBranchpointRevisions.Free;
        GetLatestRevisionsL2.Free;
      end;
    finally
      elvHistory.Items.EndUpdate;
    end;
  finally
    FreeAndNil(VCSProgress);
  end;
end;

procedure TVCSLabelHistory.btnGenerateClick(Sender: TObject);
var
  LabelID1, LabelID2, ProjectID: Integer;
  DiffMode: TProjectDiffMode;
begin
  LabelID1 := -1;
  LabelID2 := -1;
  ProjectID := -1;
  if cbFromLabel.ItemIndex <> -1 then
    LabelID1 := Integer(cbFromLabel.Items.Objects[cbFromLabel.ItemIndex]);
  if cbToLabel.ItemIndex <> -1 then
    LabelID2 := Integer(cbToLabel.Items.Objects[cbToLabel.ItemIndex]);
  if cbProjects.ItemIndex <> -1 then
    ProjectID := Integer(cbProjects.Items.Objects[cbProjects.ItemIndex]);

  case cbMode.ItemIndex of
    0: DiffMode := pdmLabelToLabel;
    1: DiffMode := pdmLabelToLatest;
    2: DiffMode := pdmBranchpointToLatest;
    else
      DiffMode := pdmLabelToLabel;
  end;

  LabelDiff(DiffMode, LabelID1, LabelID2, ProjectID, True);
end;

procedure TVCSLabelHistory.cbFromLabelChange(Sender: TObject);
var
  LabelID1, LabelID2, ProjectID: Integer;
  DiffMode: TProjectDiffMode;
begin
  LabelID1 := -1;
  LabelID2 := -1;
  ProjectID := -1;
  if cbFromLabel.ItemIndex <> -1 then
    LabelID1 := Integer(cbFromLabel.Items.Objects[cbFromLabel.ItemIndex]);
  if cbToLabel.ItemIndex <> -1 then
    LabelID2 := Integer(cbToLabel.Items.Objects[cbToLabel.ItemIndex]);
  if cbProjects.ItemIndex <> -1 then
    ProjectID := Integer(cbProjects.Items.Objects[cbProjects.ItemIndex]);

  case cbMode.ItemIndex of
    0: DiffMode := pdmLabelToLabel;
    1: DiffMode := pdmLabelToLatest;
    2: DiffMode := pdmBranchpointToLatest;
    else
      DiffMode := pdmLabelToLabel;
  end;

  lbFromLabel.Enabled := DiffMode in [pdmLabelToLabel, pdmLabelToLatest];
  cbFromLabel.Enabled := DiffMode in [pdmLabelToLabel, pdmLabelToLatest];
  cbToLabel.Enabled := DiffMode = pdmLabelToLabel;
  lbToLabel.Enabled := DiffMode = pdmLabelToLabel;

  btnGenerate.Enabled := ((DiffMode = pdmBranchpointToLatest) or (LabelID1 <> -1)) and
   ((DiffMode in [pdmLabelToLatest, pdmBranchpointToLatest]) or ((LabelID2 <> -1) and
   (LabelID1 <> LabelID2))) and (ProjectID <> -1);
end;

end.
