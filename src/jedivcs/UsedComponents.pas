(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: UsedComponents.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS: Thomas Huber (Thomas_D_Huber@t-online.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FreeVCS code to JEDI VCS
2003/02/12  USchuster - changed DSAMsg with JVCSDialogs in uses clause to use JvDSADialogs
2003/03/09  THensle   - changes for "ConfigStorage" unit
2003/04/08  USchuster - changes for IDEInterface
2003/12/28  USchuster - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use constant)
2004/03/14  USchuster - 'vcllist.fvc' -> cDelphiVCLComponentListFile
                        'vcllistbcb.fvc' -> cBCBVCLComponentListFile
                      - minor style cleaning (casing and comments)
2004/09/17  FHasovic  - Added dxGetText support for localization                      
2004/10/08  USchuster - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/11/02  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
2005/04/09  USchuster - improved speed with some Begin/EndUpdate (mantis #2852)                      
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC3 released ^^^^^^^^^^^^^^^^^^^^^^^^^^^
2006/01/21  THuber    - hints removed
2007/07/01  USchuster - changes for large fonts (contraints and default size depend now on PixelsPerInch; analog to Mantis #3710)
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit UsedComponents;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Buttons, Menus, EnhListView;

type
  TVCSUsedComponents = class(TForm)
    Panel2: TPanel;
    btnParse: TButton;
    btnClose: TButton;
    Splitter1: TSplitter;
    cbFilter: TCheckBox;
    btnFilter: TButton;
    Help: TSpeedButton;
    btnReport: TButton;
    elvperForm: TdfsEnhListView;
    elvperProject: TdfsEnhListView;
    procedure btnParseClick(Sender: TObject);
    procedure btnFilterClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure HelpTopics1Click(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure btnReportClick(Sender: TObject);
    procedure elvperFormDrawItem(Control: TWinControl;
      var ACanvas: TCanvas; Index: Integer; ARect: TRect;
      State: TOwnerDrawState; var DefaultDrawing, FullRowSelect: Boolean);
    procedure elvperProjectDrawItem(Control: TWinControl;
      var ACanvas: TCanvas; Index: Integer; ARect: TRect;
      State: TOwnerDrawState; var DefaultDrawing, FullRowSelect: Boolean);
  private
    { Private declarations }
    function GetListViewString: string;
  public
    { Public declarations }
    procedure RestrictSize(var Msg: TMessage); message WM_GETMINMAXINFO;
  end;

var
  VCSUsedComponents: TVCSUsedComponents;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  JVCSIDEInterface, JVCSDialogs, VCSBase, VCSProcBase, UnitFilter,
  SimpleReport, ConfigStorage, JVCSGUIClientResources;

{$R *.dfm}

//------------------------------------------------------------------------------

procedure TVCSUsedComponents.FormCreate(Sender: TObject);
var
  DlgTop, DlgLeft, DlgWidth, DlgHeight: Integer;
begin
  try
    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    cbFilter.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbWindows, 'UsedComponents_Filter', True);

    if not jvcsReadWindowPosAndSize(sBaseRegistryKey + crbWindows, 'UsedComponents',
      DlgTop, DlgLeft, DlgWidth, DlgHeight) then
    begin
      DlgTop := (Screen.Height - Height) div 2;
      DlgLeft := (Screen.Width - Width) div 2;
      DlgWidth := MulDiv(500, PixelsPerInch, 96);
      DlgHeight := MulDiv(300, PixelsPerInch, 96);
    end;
    Top := DlgTop;
    Left := DlgLeft;
    Width := DlgWidth;
    Height := DlgHeight;

    with elvperForm do
    begin
      Columns[0].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'UsedComponents_Col1.0', 90);
      Columns[1].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'UsedComponents_Col1.1', 95);
      Columns[2].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'UsedComponents_Col1.2', 80);
      Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'UsedComponents_Pn1', 249);
    end;
    with elvperProject do
    begin
      Columns[0].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'UsedComponents_Col2.0', 100);
      Columns[1].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'UsedComponents_Col2.1', 100);
    end;

    Caption := Caption + ' - ' + AnsiLowerCase(ExtractFileName(sProjectName));

    Application.ProcessMessages;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSUsedComponents.btnParseClick(Sender: TObject);
var
  I, J, K: Integer;
  CurrModule, CurrForm, CurrEntry, CurrCompType, CurrCompName, VCLListFilter: string;
  FormWasOpen, FilterOut, PackageFound: Boolean;
  UCFilters, Filters, CompList, CompList_Proj: TStringList;
  NewLVItem: TListItem;
begin
  Caption := Format(JVCSRES_Used_Components_45_37s_45_parsing_project_modules,
    [AnsiLowerCase(ExtractFileName(sProjectName))]);

  if bIsCppBuilder then
    VCLListFilter := sDLLDirectory + cBCBVCLComponentListFile
  else
    VCLListFilter := sDLLDirectory + cDelphiVCLComponentListFile;
  UCFilters := TStringList.Create;
  try
    if FileExists(VCLListFilter) then 
    begin
      try
        UCFilters.LoadFromFile(VCLListFilter);
      except
        on E :
        Exception do 
        begin
          UCFilters.Clear;
          BeepIfSet;
          MessageBox(Handle, PChar(Format(JVCSRES_Reading_file_6037s62 + #13#10 +
            JVCSRES_raised_exception58 + #13#10 + '%s.', [VCLListFilter, E.Message])),
            cMsgBoxCaption, MB_OK or MB_ICONSTOP);
        end;
      end;
    end; // if FileExists(VCLListFilter) then begin

    Screen.Cursor := crHourGlass;
    Filters := TStringList.Create;
    Filters.Sorted := True;
    Filters.Duplicates := dupIgnore;

    for I := 0 to UCFilters.Count - 1 do
      Filters.Add(AnsiLowerCase(UCFilters.Strings[I]));
  finally
    UCFilters.Free;
  end;

  elvperProject.Items.Clear;
  elvperForm.Items.Clear;

  CompList := TStringList.Create;
  CompList.Sorted := True;
  CompList.Duplicates := dupIgnore;
  for I := 0 to IDEInterface.GetUnitCount - 1 do
  begin
    CurrModule := IDEInterface.GetUnitName(I);
    CurrForm := AnsiLowerCase(ExtractFileName(ChangeFileExt(CurrModule, '.dfm')));
    if (CurrModule <> '') and
      (AnsiLowerCase(ExtractFileExt(CurrModule)) = ('.' + sIDEUnit)) then
    begin
      FormWasOpen := IDEInterface.IsFileOpen(CurrModule);
      if (FormWasOpen) or (IDEInterface.OpenFile(GetOriginalFileName(CurrModule))) then
      begin
        IDEModuleComponentsToStringList(CurrForm, CurrModule, CompList);

        if not FormWasOpen then
          IDEInterface.CloseFile(CurrModule);
        Application.ProcessMessages;
      end; // if IDEInterface.OpenFile(CurrForm) then begin
    end; // if CurrForm <> '' then begin
  end; // for I := 0 to IDEInterface.GetFormCount - 1

  CompList_Proj := TStringList.Create;
  CompList_Proj.Sorted := True;
  CompList_Proj.Duplicates := dupIgnore;

  elvperForm.BeginUpdate;
  try
    for I := 0 to CompList.Count - 1 do
    begin
      CurrEntry := CompList.Strings[I];
      CurrForm := Copy(CurrEntry, 1, Pos('|', CurrEntry) - 1);
      Delete(CurrEntry, 1, Pos('|', CurrEntry));
      CurrCompType := Copy(CurrEntry, 1, Pos('|', CurrEntry) - 1);
      Delete(CurrEntry, 1, Pos('|', CurrEntry));
      CurrCompName := CurrEntry;
      // Filter
      if cbFilter.Checked then 
      begin
        FilterOut := False;
        for J := 0 to Filters.Count - 1 do
        begin
          if Filters.Strings[J] = AnsiLowerCase(CurrCompType) then 
          begin
            FilterOut := True;
            Break;
          end;
        end;
      end 
      else 
        FilterOut := False;
      if not FilterOut then 
      begin
        NewLVItem := elvperForm.Items.Add;
        NewLVItem.Caption := CurrForm;
        NewLVItem.SubItems.Add(CurrCompType);
        NewLVItem.SubItems.Add(CurrCompName);
        CompList_Proj.Add(CurrCompType);
      end; // if not FilterOut then begin
    end; // for I := 0 to CompList.Count - 1 do begin
  finally
    elvperForm.EndUpdate;
  end;
  elvperProject.BeginUpdate;
  try
    for I := 0 to CompList_Proj.Count - 1 do
    begin
      NewLVItem := elvperProject.Items.Add;
      NewLVItem.Caption := CompList_Proj.Strings[I];
      // find package
      PackageFound := False;
      with IDEInterface do 
      begin
        for J := 0 to GetModuleCount - 1 do 
        begin
          for K := 0 to GetComponentCount(J) - 1 do 
          begin
            if LowerCase(GetComponentName(J, K)) = LowerCase(NewLVItem.Caption) then
            begin
              NewLVItem.SubItems.Add(GetModuleName(J));
              PackageFound := True;
              Break;
            end;
          end; // for K := 0 to GetComponentCount(J) - 1 do begin
          if PackageFound then 
            Break;
        end; // for J := 0 to GetModuleCount - 1 do begin
      end; // with IDEInterface do begin
      if not PackageFound then
        NewLVItem.SubItems.Add('?');
    end; // for I := 0 to CompList_Proj.Count - 1 do begin
  finally
    elvperProject.EndUpdate;
  end;

  CompList_Proj.Free;
  CompList.Free;
  Filters.Free;
  if cbFilter.Checked then
    Caption := Format(JVCSRES_Used_Components_45_37s_45_37d_comps_40filtered41,
      [AnsiLowerCase(ExtractFileName(sProjectName)), elvperProject.Items.Count])
  else
    Caption := Format(JVCSRES_Used_Components_45_37s_45_37d_comps,
      [AnsiLowerCase(ExtractFileName(sProjectName)), elvperProject.Items.Count]);
  SetForeGroundWindow(Handle);
  Screen.Cursor := crDefault;
end;

//------------------------------------------------------------------------------

procedure TVCSUsedComponents.btnFilterClick(Sender: TObject);
begin
  VCSUnitFilter := TVCSUnitFilter.Create(Application);
  try
    VCSUnitFilter.Top := Top + 20;
    VCSUnitFilter.Left := Left + 20;
    VCSUnitFilter.SetFilterType(0); // Componentfilter
    VCSUnitFilter.ShowModal;
  finally
    VCSUnitFilter.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSUsedComponents.btnCloseClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSUsedComponents.RestrictSize(var Msg: TMessage);
var
  P: PMinMaxInfo;
begin
  // The lParam contains a pointer on a structure of type TMinMaxInfo
  P := PMinMaxInfo(Msg.lParam);
  // This represents the size of the Window when Maximized
  P.ptMaxSize.x := trResDesktop.Right;
  P.ptMaxSize.y := trResDesktop.Bottom;
  // This represents the position of the Window when Maximized
  P.ptMaxPosition.x := 0;
  P.ptMaxPosition.y := 0;
  // This represents the minimum size of the Window
  P.ptMinTrackSize.x := MulDiv(480, PixelsPerInch, 96);
  P.ptMinTrackSize.y := MulDiv(290, PixelsPerInch, 96);
end;

//------------------------------------------------------------------------------

procedure TVCSUsedComponents.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  cbFilter.Checked :=
    jvcsWriteBool(sBaseRegistryKey + crbWindows, 'UsedComponents_Filter', True);

  jvcsWriteWindowPosAndSize(sBaseRegistryKey + crbWindows, 'UsedComponents',
    Top, Left, Width, Height);

  with elvperForm do
  begin
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'UsedComponents_Col1.0',
      Columns[0].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'UsedComponents_Col1.1',
      Columns[1].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'UsedComponents_Col1.2',
      Columns[2].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'UsedComponents_Pn1',
      Width);
  end;
  with elvperProject do
  begin
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'UsedComponents_Col2.0',
      Columns[0].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'UsedComponents_Col2.1',
      Columns[1].Width);
  end;
end;

//------------------------------------------------------------------------------

function TVCSUsedComponents.GetListViewString: string;
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
    with elvperForm do 
    begin
      if Items.Count = 0 then 
      begin
        // Nothing to do.
        MessageBox(WindowHandle, PChar(JVCSRES_Requested_result_set_is_blank46_Nothing_to_do46), cMsgBoxCaption, MB_OK);
        Exit;
      end;
      Result := Caption + cr;
      CurrentText := '';
      while Length(CurrentText) < Length(Caption) do
        CurrentText := CurrentText + '=';
      Result := Result + CurrentText + cr + cr;
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
      end; // for J := 0 to Columns.Count - 1 do begin

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

    Result := Result + cr;
    SetLength(oaColumnsWidth, 0);

    with elvperProject do 
    begin
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
      end; // for J := 0 to Columns.Count - 1 do begin

      Result := Result + cr;      

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

//------------------------------------------------------------------------------

procedure TVCSUsedComponents.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    btnClose.Click;
    Key := 0;
  end;
  if Key = VK_F1 then 
  begin
    PerformHelpCommand(Application, IDH_Used_Components);
  end;
  if Key = VK_F2 then 
    btnParse.Click;
end;

//------------------------------------------------------------------------------

procedure TVCSUsedComponents.btnReportClick(Sender: TObject);
var 
  ResultString: string;
begin
  ResultString := GetListViewString;
  if ResultString = '' then 
    Exit;

  VCSSimpleReport := TVCSSimpleReport.Create(Application);
  try
    VCSSimpleReport.RepID := 17;  
    VCSSimpleReport.Left := Left + 60;
    VCSSimpleReport.Top := Top + 60;
    VCSSimpleReport.FullReportString := ResultString;
    VCSSimpleReport.SavePath := ExtractFileDir(sProjectName);
    VCSSimpleReport.SaveFileName := 'UsedComponents.txt';
    VCSSimpleReport.LineCount := elvperForm.Items.Count +
      elvperProject.Items.Count + 8;
    VCSSimpleReport.ShowModal;
  finally
    VCSSimpleReport.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSUsedComponents.HelpTopics1Click(Sender: TObject);
begin
  PerformHelpCommand(Application, IDH_Used_Components);
end;

//------------------------------------------------------------------------------

procedure TVCSUsedComponents.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSUsedComponents.elvperFormDrawItem(Control: TWinControl;
  var ACanvas: TCanvas; Index: Integer; ARect: TRect;
  State: TOwnerDrawState; var DefaultDrawing, FullRowSelect: Boolean);
begin
  DefaultDrawing := True;
  FullRowSelect := True;
end;

//------------------------------------------------------------------------------

procedure TVCSUsedComponents.elvperProjectDrawItem(Control: TWinControl;
  var ACanvas: TCanvas; Index: Integer; ARect: TRect;
  State: TOwnerDrawState; var DefaultDrawing, FullRowSelect: Boolean);
begin
  DefaultDrawing := True;
  FullRowSelect := True;
end;

end.
