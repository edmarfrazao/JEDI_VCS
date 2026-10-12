(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: SimpleReport.pas

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
2003/03/04  THensle   - changes for "ConfigStorage" unit
2003/03/08  USchuster - exchanged THistoryList with TJVCSMruList (mantis #727)
2003/11/19  USchuster - changed 'FreeVCS' and 'JEDI-VCS' in messageboxes to
                        'JEDI VCS' with constant cMsgBoxCaption from VCSBase.pas
2004/02/24  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/03/14  USchuster - 'htm_rep.htm' -> cHTMLReportTemplateFile
                      - minor style cleaning (casing and comments)
2004/09/17  FHasovic  - Added dxGetText support for localization                      
2004/10/10  USchuster - style cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/10/31  USchuster - moved resourcestrings to JVCSGUIClientResources.pas                      
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit SimpleReport;

{$I jedi.inc}
{$I compopt.inc}
{$DEFINE RTFREPORT}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, Menus, JvExControls, JvComponent, JVCSForms,
  JvxCheckListBox;

type
  TVCSSimpleReport = class(TJVCSForm)
    PrintDialog1: TPrintDialog;
    Panel1: TPanel;
    imgClipBrd: TImage;
    rbClipBoard: TRadioButton;
    rbSave: TRadioButton;
    rbCSVReport: TRadioButton;
    rbHTML: TRadioButton;
    rbRTF: TRadioButton;
    rbPrint: TRadioButton;
    cbShowResult: TCheckBox;
    btnReport: TButton;
    btnPreview: TButton;
    btnClose: TButton;
    clbInclude: TJvxCheckListBox;
    Label1: TLabel;
    PopupMenu1: TPopupMenu;
    SelectAllColumns1: TMenuItem;
    UnselectAllColumns1: TMenuItem;
    SaveasDefault1: TMenuItem;
    N1: TMenuItem;
    imgSaved: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCloseClick(Sender: TObject);
    procedure btnPreviewClick(Sender: TObject);
    procedure btnReportClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure rbClipBoardClick(Sender: TObject);
    procedure clbIncludeClick(Sender: TObject);
    procedure SelectAllColumns1Click(Sender: TObject);
    procedure UnselectAllColumns1Click(Sender: TObject);
    procedure clbIncludeKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SaveasDefault1Click(Sender: TObject);
  private
    ColumnsSetup: Boolean;
    { Private declarations }
    procedure EnableShowResult;
    procedure SetUpColumnsLB;
    procedure CheckColumnsToShow;
    function ParsedReportString: string;
    procedure CopyToClipBoard;
    procedure SaveToFile;
    procedure Print;
    procedure HTMLReport;
    {$IFDEF RTFREPORT}
    procedure RTFReport;
    {$ENDIF RTFREPORT}
    procedure CSVReport;
  public
    { Public declarations }
    FullReportString,
    SaveFileName,
    SavePath: string;
    RepID, // letzter 25 oder 1000 + 21 oder 2000 + 3;
    LineCount: Integer;
  end;

var
  VCSSimpleReport: TVCSSimpleReport;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  ShellAPI, Printers, ClipBrd, FavOpenDialog, VCSBase, VCSProcBase,
  ListView, Math, ConfigStorage, JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSSimpleReport.FormCreate(Sender: TObject);
begin
  try
    ColumnsSetup := False;
    case jvcsReadInteger(sBaseRegistryKey + crbOptions, 'SReportTarget', 0) of
      0:
        rbClipBoard.Checked := True;
      1:
        rbSave.Checked := True;
      2:
        rbPrint.Checked := True;
      3:
        rbHTML.Checked := True;
      4:
        rbRTF.Checked := True;
      5:
        rbCSVReport.Checked := True;
    end;
    cbShowResult.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbOptions, 'SReportShow', False);
    EnableShowResult;
    Screen.Cursors[cPopUpMCursor] := LoadCursor(hInstance, PChar('CURSORRM'));
    clbInclude.Cursor := cPopUpMCursor;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSSimpleReport.FormShow(Sender: TObject);
begin
  rbPrint.Caption := Format(JVCSRES_Pr38int_report_4012637d_lines41, [LineCount]);
  SetUpColumnsLB;
end;

//------------------------------------------------------------------------------

procedure TVCSSimpleReport.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  LastTarget: Integer;
begin
  LastTarget := 0;
  if rbClipBoard.Checked then
    LastTarget := 0;
  if rbSave.Checked then
    LastTarget := 1;
  if rbPrint.Checked then
    LastTarget := 2;
  if rbHTML.Checked then
    LastTarget := 3;
  if rbRTF.Checked then
    LastTarget := 4;
  if rbCSVReport.Checked then
    LastTarget := 5;

  jvcsWriteInteger(sBaseRegistryKey + crbOptions, 'SReportTarget', LastTarget);
  jvcsWriteBool(sBaseRegistryKey + crbOptions, 'SReportShow', cbShowResult.Checked);
end;

//------------------------------------------------------------------------------

procedure TVCSSimpleReport.rbClipBoardClick(Sender: TObject);
begin
  EnableShowResult;
end;

//------------------------------------------------------------------------------

procedure TVCSSimpleReport.EnableShowResult;
begin
  cbShowResult.Enabled := rbSave.Checked or rbHTML.Checked or rbRTF.Checked or
    rbCSVReport.Checked;
end;

//------------------------------------------------------------------------------

procedure TVCSSimpleReport.btnCloseClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSSimpleReport.btnPreviewClick(Sender: TObject);
begin
  VCSListView := TVCSListView.Create(Application);
  try
    VCSListView.Caption := JVCSRES_Preview;
    VCSListView.Left := Left + 40;
    VCSListView.Top := Top + 40;
    VCSListView.Width := Screen.Width - (Left + 40) - 150;
    VCSListView.Height := Screen.Height - (Top + 40) - 100;
    VCSListView.SetFontName('Courier New');
    VCSListView.EnableWordWrap(False);
    VCSListView.SetUpText(ParsedReportString);

    VCSListView.ShowModal;
  finally
    VCSListView.Free;
    VCSListView := nil;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSSimpleReport.btnReportClick(Sender: TObject);
begin
  if rbClipBoard.Checked then
    CopyToClipBoard;
  if rbSave.Checked then
    SaveToFile;
  if rbPrint.Checked then
    Print;
  if rbHTML.Checked then
    HTMLReport;
  if rbRTF.Checked then
    RTFReport;
  if rbCSVReport.Checked then
    CSVReport;
end;

//------------------------------------------------------------------------------

procedure TVCSSimpleReport.SetUpColumnsLB;
var
  I, CurrentSetting: Integer;
  ReportList: TStringList;
  CurrentLine, CurrColumnText: string;
begin
  if ColumnsSetup then
    Exit;
  if RepID in [1, 11] then
  begin
    clbInclude.Enabled := False;
    clbInclude.Color := clBtnFace;
    ColumnsSetup := True;
    Exit;
  end;
  if RepID = 1002 then
  begin
    clbInclude.Cursor := crDefault;
    clbInclude.PopUpMenu := nil;
  end;

  clbInclude.Items.Clear;
  ReportList := TStringList.Create;
  try
    ReportList.Text := FullReportString;
    for I := 0 to ReportList.Count - 1 do
    begin
      if Pos(' | ', ReportList[I]) > 0 then
      begin
        CurrentLine := ReportList[I];
        repeat // until Length(CurrentLine) >= 1;
          if Pos(' | ', CurrentLine) > 0 then
            CurrColumnText := Copy(CurrentLine, 1, Pos(' | ', CurrentLine) + 2)
          else
            CurrColumnText := CurrentLine;
          Delete(CurrentLine, 1, Length(CurrColumnText));
          if Pos('|', CurrColumnText) > 0 then
            Delete(CurrColumnText, Pos('|', CurrColumnText), 1);
          clbInclude.Items.Add(CurrColumnText);
        until Length(CurrentLine) <= 1;
        Break;
      end; // if Pos(' | ', ReportList[I]) > 0 then begin
    end; // for I := 0 to ReportList.Count - 1 do begin
  finally
    ReportList.Free;
  end;

  CurrentSetting :=
    jvcsReadInteger(sBaseRegistryKey + crbPrinter + '\SimpleReportColumns',
    IntToHex(RepID, 8), 0);
  if CurrentSetting = 0 then
  begin
    for I := 0 to clbInclude.Items.Count - 1 do
      clbInclude.Checked[I] := True;
  end
  else
  begin
    imgSaved.Visible := True;
    for I := 0 to clbInclude.Items.Count - 1 do
      if (CurrentSetting and (Round(Power(2, I)))) = (Round(Power(2, I))) then
        clbInclude.Checked[I] := True;
  end;
  ColumnsSetup := True;
end;

//------------------------------------------------------------------------------

function TVCSSimpleReport.ParsedReportString: string;
var
  I, CurrColumn: Integer;
  ReportList: TStringList;
  CurrentLine, CurrColumnText: string;
  FilterColumns: Boolean;
begin
  FilterColumns := False;
  for I := 0 to clbInclude.Items.Count - 1 do
    if not clbInclude.Checked[I] then
      FilterColumns := True;

  if not FilterColumns then
  begin
    Result := FullReportString;
    Exit;
  end
  else
  begin
    Result := '';
    ReportList := TStringList.Create;
    try
      ReportList.Text := FullReportString;
      for I := 0 to ReportList.Count - 1 do
      begin
        if Pos(' | ', ReportList[I]) > 0 then
        begin
          CurrentLine := ReportList[I];
          CurrColumn := 0;
          repeat // until Length(CurrentLine) >= 1;
            if clbInclude.Checked[CurrColumn] then
            begin
              if Pos(' | ', CurrentLine) > 0 then
                CurrColumnText := Copy(CurrentLine, 1, Pos(' | ', CurrentLine) + 2)
              else
                CurrColumnText := CurrentLine;
              Delete(CurrentLine, 1, Length(CurrColumnText));
              Result := Result + CurrColumnText;
            end // if clbInclude.Checked[CurrColumn] then begin
            else
            begin
              if Pos(' | ', CurrentLine) > 0 then
                CurrColumnText := Copy(CurrentLine, 1, Pos(' | ', CurrentLine) + 2)
              else
                CurrColumnText := CurrentLine;
              Delete(CurrentLine, 1, Length(CurrColumnText));
            end; // else if clbInclude.Checked[CurrColumn] then begin
            Inc(CurrColumn);
          until (Length(CurrentLine) <= 1) or (CurrColumn > clbInclude.Items.Count - 1);

          while (Length(Result) > 0) and
            ((Result[Length(Result)] = ' ') or
            (Result[Length(Result)] = '|')) do
            Delete(Result, Length(Result), 1);

          Result := Result + #13#10;
        end // if Pos(' | ', ReportList[I]) > 0 then begin
        else
          Result := Result + ReportList[I] + #13#10;
      end; // for I := 0 to ReportList.Count - 1 do begin
    finally
      ReportList.Free;
    end;
  end; // else if not FilterColumns then begin
end;

//------------------------------------------------------------------------------

procedure TVCSSimpleReport.CopyToClipBoard;
var
  ReportString: string;
begin
  ReportString := ParsedReportString;
  try
    ClipBoard.SetTextBuf(PChar(ReportString));
  except
    MessageBox(WindowHandle, PChar(JVCSRES_Cannot_access_clipboard46), cMsgBoxCaption,
      MB_OK or MB_ICONEXCLAMATION);
    Exit;
  end;
  imgClipBrd.Visible := True;
end;

//------------------------------------------------------------------------------

procedure TVCSSimpleReport.SaveToFile;
var
  TargetFileName, OutPutString, CurrentString, ShortModulName: string;
  ResultStringList: TStringList;
  DlgResult: Boolean;
  FavSaveDialog: TFavSaveDialog;
  SMSize, ExecResult: Integer;
begin
  OutPutString := ParsedReportString;
  FavSaveDialog := TFavSaveDialog.Create(Application);
  try
    with FavSaveDialog do
    begin
      Title := JVCSRES_Save_report_to_file;
      Options := [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing];
      Filter := JVCSRES_Text_files_404246txt411244246txt124All_files_4042464241124424642;
      FileName := SaveFileName;
      InitialDir := SavePath;
      DefaultExt := 'txt';

      //FavSaveDialog is inherited from FavOpenDialog and thatswhy
      //ExecuteFavOpenDialogWithMru also works here
      DlgResult := ExecuteFavOpenDialogWithMru(FavSaveDialog,
        sBaseRegistryKey + crbMRU + '17');

      TargetFileName := FileName;
    end; // with SaveDialog1 do begin
  finally
    FavSaveDialog.Free;
  end;

  if not DlgResult then
    Exit;

  ResultStringList := TStringList.Create;
  try
    try
      while Pos(Chr(10), OutPutString) > 0 do
      begin
        CurrentString := Copy(OutPutString, 1, Pos(Chr(10), OutPutString) - 2);
        System.Delete(OutPutString, 1, Pos(Chr(10), OutPutString));
        ResultStringList.Add(CurrentString);
      end; // while Pos(Chr(10),  OutPutString) > 0 do begin
    except
      on E :
      Exception do
      begin
        BeepIfSet;
        MessageBox(WindowHandle, PChar(Format(JVCSRES_Parsing_the_ListView_content_raised_exception58 + #13#10 +
          '%s', [E.Message])), cMsgBoxCaption,
          MB_OK or MB_ICONSTOP);
        Exit;
      end;
    end;
    try
      ResultStringList.SaveToFile(TargetFileName);
    except
      BeepIfSet;
      MessageBox(WindowHandle, PChar(Format(JVCSRES_JEDI_VCS_cannot_save_the_file + #13#10 + '<%s>.' + #13#10 +
        JVCSRES_Be_sure_that_the_file_is_not_opened_by_another_application44 + #13#10 +
        JVCSRES_that_there_is_enough_free_space_on_the_disk + #13#10 +
        JVCSRES_and_that_you_have_the_required_access_rights46, [TargetFileName])),
        cMsgBoxCaption, MB_OK or MB_ICONSTOP);
      Exit;
    end;
  finally
    ResultStringList.Free;
  end;

  if cbShowResult.Checked then
  begin
    // keine langen Dateinamen als Parameter
    SetLength(ShortModulName, MAX_PATH);
    SMSize := GetShortPathName(PChar(TargetFileName), PChar(ShortModulName), MAX_PATH);
    SetLength(ShortModulName, SMSize);
    ExecResult := ShellExecute(Application.Handle, 'open',
      PChar(ShortModulName),
      PChar(''),
      PChar(ExtractFileDir(ShortModulName)),
      sw_ShowNormal);
    if ExecResult < 32 then
    begin
      MessageBox(WindowHandle, PChar(Format(JVCSRES_ShellExecute_Error_6037s62,
        [ExtractFileName(TargetFileName)]) + #10#13 +
        DecodeShellErr(ExecResult)),
        cMsgBoxCaption, MB_OK or MB_ICONWARNING);
    end; // if ExecResult < 32 then begin
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSSimpleReport.CSVReport;
var
  TargetFileName, OutPutString, CurrentString, CSVDelim, ShortModulName: string;
  ResultStringList: TStringList;
  DlgResult: Boolean;
  FavSaveDialog: TFavSaveDialog;
  I, SMSize, ExecResult: Integer;
begin
  CSVDelim := jvcsReadString(sBaseRegistryKey, 'CSVDelimiter', ',');
  OutPutString := ParsedReportString;
  FavSaveDialog := TFavSaveDialog.Create(Application);
  try
    with FavSaveDialog do
    begin
      Title := JVCSRES_Save_report_to_CSV_file;
      Options := [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing];
      Filter :=
        JVCSRES_Comma_sep_values_404246csv411244246csv124Text_files_404246txt411244246txt124All_files_4042464241124424642;
      FileName := ChangeFileExt(SaveFileName, '.csv');
      InitialDir := SavePath;
      DefaultExt := 'csv';

      //FavSaveDialog is inherited from FavOpenDialog and thatswhy
      //ExecuteFavOpenDialogWithMru also works here
      DlgResult := ExecuteFavOpenDialogWithMru(FavSaveDialog,
        sBaseRegistryKey + crbMRU + '17');

      TargetFileName := FileName;
    end; // with SaveDialog1 do begin
  finally
    FavSaveDialog.Free;
  end;

  if not DlgResult then 
    Exit;

  ResultStringList := TStringList.Create;
  try
    try
      while Pos(Chr(10), OutPutString) > 0 do 
      begin
        CurrentString := Copy(OutPutString, 1, Pos(Chr(10), OutPutString) - 2);
        System.Delete(OutPutString, 1, Pos(Chr(10), OutPutString));
        {while Pos(';', CurrentString) > 0 do begin
          I := Pos(';', CurrentString);
          System.Delete(CurrentString, I, 1);
          System.Insert('/', CurrentString, I);
        end;}
        while Pos('|', CurrentString) > 0 do 
        begin
          I := Pos('|', CurrentString);
          System.Delete(CurrentString, I, 1);
          System.Insert(CSVDelim, CurrentString, I);
        end;
        ResultStringList.Add(CurrentString);
      end; // while Pos(Chr(10),  OutPutString) > 0 do begin
    except
      on E: 
      Exception do 
      begin
        BeepIfSet;
        MessageBox(WindowHandle, PChar(Format(JVCSRES_Parsing_the_ListView_content_raised_exception58 + #13#10 +
          '%s', [E.Message])), cMsgBoxCaption,
          MB_OK or MB_ICONSTOP);
        Exit;
      end;
    end;
    try
      ResultStringList.SaveToFile(TargetFileName);
    except
      BeepIfSet;
      MessageBox(WindowHandle, PChar(Format(JVCSRES_JEDI_VCS_cannot_save_the_file + #13#10 + '<%s>.' + #13#10 +
        JVCSRES_Be_sure_that_the_file_is_not_opened_by_another_application44 + #13#10 +
        JVCSRES_that_there_is_enough_free_space_on_the_disk + #13#10 +
        JVCSRES_and_that_you_have_the_required_access_rights46, [TargetFileName])),
        cMsgBoxCaption, MB_OK or MB_ICONSTOP);
      Exit;
    end;
  finally
    ResultStringList.Free;
  end;

  if cbShowResult.Checked then 
  begin
    // keine langen Dateinamen als Parameter
    SetLength(ShortModulName, MAX_PATH);
    SMSize := GetShortPathName(PChar(TargetFileName), PChar(ShortModulName), MAX_PATH);
    SetLength(ShortModulName, SMSize);
    ExecResult := ShellExecute(Application.Handle, 'open',
      PChar(ShortModulName),
      PChar(''),
      PChar(ExtractFileDir(ShortModulName)),
      sw_ShowNormal);
    if ExecResult < 32 then 
    begin
      MessageBox(WindowHandle, PChar(Format(JVCSRES_ShellExecute_Error_6037s62,
        [ExtractFileName(TargetFileName)]) + #10#13 +
        DecodeShellErr(ExecResult)),
        cMsgBoxCaption, MB_OK or MB_ICONWARNING);
    end; // if ExecResult < 32 then begin
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSSimpleReport.Print;
var 
  wTextHeight: Word;
  I, TopMarg, LeftMarg, iLinePos, iLines, iLPS: Integer;
  iSides: Single;
  OutPutString, CurrentString, Device: string;
  DefaultPrinter: Boolean;
begin
  OutPutString := ParsedReportString;
  DefaultPrinter := True;
  try
    with Printer do 
      Device := Printers[PrinterIndex];
  except
    DefaultPrinter := False;
  end;
  if (not DefaultPrinter) or (Device = '') then
  begin
    MessageBox(Handle, PChar(JVCSRES_JEDI_VCS_cannot_find_the_Windows_standard_printer46 + #13#10 +
      JVCSRES_Define_a_Windows_standard_printer_and_retry46), cMsgBoxCaption, MB_OK or MB_ICONWARNING);
    Exit;
  end;
  with Printer do
  begin
    Canvas.Font.Size :=
      jvcsReadInteger(sBaseRegistryKey + crbPrinter, 'FontSize', 8);
    Canvas.Font.Name :=
      jvcsReadString(sBaseRegistryKey + crbPrinter, 'FontName', 'Courier New');
    Canvas.Font.Style := [];
    wTextHeight := Canvas.TextHeight('XX');
    iLPS := Round(PageHeight / wTextHeight) - 6;
  end;

  iLines := LineCount;
  iSides := iLines / iLPS;
  with PrintDialog1 do
  begin
    Options := [poWarning];
    MinPage := 1;
    FromPage := 1;
    if Round(iSides) = 0 then
      MaxPage := 1
    else
      MaxPage := Round(iSides);
    if not Execute then
      Exit;
    ToPage := MaxPage;
  end; // with PrintDialog1 do begin
  with Printer do
  begin
    Device := Printers[PrinterIndex];
    Canvas.Font.Size :=
      jvcsReadInteger(sBaseRegistryKey + crbPrinter, 'FontSize', 8);
    Canvas.Font.Name :=
      jvcsReadString(sBaseRegistryKey + crbPrinter, 'FontName', 'Courier New');
    Canvas.Font.Style := [];
    wTextHeight := Canvas.TextHeight('XX');
  end; // with Printer do begin

  LeftMarg := jvcsReadInteger(sBaseRegistryKey + crbPrinter, 'PrintLM', 0);
  TopMarg := jvcsReadInteger(sBaseRegistryKey + crbPrinter, 'PrintTM', 0);

  Screen.Cursor := crHourGlass;
  Printer.Title := JVCSRES_JEDI_VCS_Report;

  // Start Druckanweisungen
  Printer.BeginDoc;
  Printer.Canvas.Font.Style := [];
  iLinePos := 2 * wTextHeight;
  for I := 0 to TopMarg do
  begin
    Printer.Canvas.TextOut(10, iLinePos, '');
    Inc(iLinePos, wTextHeight);
  end;

  try
    while Pos(Chr(10), OutPutString) > 0 do
    begin
      CurrentString := Copy(OutPutString, 1, Pos(Chr(10), OutPutString) - 2);
      System.Delete(OutPutString, 1, Pos(Chr(10), OutPutString));
      for I := 0 to LeftMarg do
        CurrentString := ' ' + CurrentString;
      Printer.Canvas.TextOut(10, iLinePos, CurrentString);
      Inc(iLinePos, wTextHeight);
      if iLinePos >= Printer.PageHeight - (wTextHeight * 2) then
      begin
        Printer.NewPage;
        iLinePos := 2 * wTextHeight;
        for I := 0 to TopMarg do
        begin
          Printer.Canvas.TextOut(10, iLinePos, '');
          Inc(iLinePos, wTextHeight);
        end;
      end; // if iLinePos >=...
    end; // while Pos(Chr(10),  OutPutString) > 0 do begin
  except
    on E :
    Exception do
    begin
      BeepIfSet;
      MessageBox(WindowHandle, PChar(Format(JVCSRES_Parsing_the_ListView_content_raised_exception58 + #13#10 +
        '%s', [E.Message])), cMsgBoxCaption,
        MB_OK or MB_ICONSTOP);
      Printer.EndDoc;
      Exit;
    end;
  end;

  // Ende Druckanweisungen
  Printer.Canvas.Font.Style := [];
  Printer.EndDoc;
  Screen.Cursor := crDefault;
end;

//------------------------------------------------------------------------------

procedure TVCSSimpleReport.HTMLReport;
var
  HTMLTemplate, CurrentLine, CurrentCell: string;
  HTMLLines: TStringList;
  I, K, ExecResult: Integer;
  ShortModulName: string;
  SMSize: Integer;
  TargetFileName, OutPutString, CurrentString: string;
  DlgResult: Boolean;
  FavSaveDialog: TFavSaveDialog;

  function RemoveWhiteSpace(SourceString: string): string;
  begin
    while (Length(SourceString) > 0) and
      (SourceString[1] = ' ') do
      System.Delete(SourceString, 1, 1);
    while (Length(SourceString) > 0) and
      (SourceString[Length(SourceString)] = ' ') do
      System.Delete(SourceString, Length(SourceString), 1);
    Result := SourceString;
  end;
begin
  OutPutString := ParsedReportString;
  FavSaveDialog := TFavSaveDialog.Create(Application);
  try
    with FavSaveDialog do 
    begin
      Title := JVCSRES_Save_report_to_HTML_file;
      Options := [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing];
      Filter := JVCSRES_HTML_files_404246htm594246html411244246htm594246html124All_files_4042464241124424642;
      FileName := ChangeFileExt(SaveFileName, '.htm');
      InitialDir := SavePath;
      DefaultExt := 'htm';

      //FavSaveDialog is inherited from FavOpenDialog and thatswhy
      //ExecuteFavOpenDialogWithMru also works here
      DlgResult := ExecuteFavOpenDialogWithMru(FavSaveDialog,
        sBaseRegistryKey + crbMRU + '17');

      TargetFileName := FileName;
    end; // with SaveDialog1 do begin
  finally
    FavSaveDialog.Free;
  end;

  if not DlgResult then 
    Exit;

  HTMLTemplate := sDLLDirectory + cHTMLReportTemplateFile;

  HTMLLines := TStringList.Create;
  try
    try
      HTMLLines.LoadFromFile(HTMLTemplate);
    except
      on E: 
      Exception do 
      begin
        MessageBox(Handle, PChar(Format(JVCSRES_Reading_file_6037s62 + #13#10 +
          JVCSRES_raised_exception58 + #13#10 + '%s.', [HTMLTemplate, E.Message])),
          cMsgBoxCaption, MB_OK or MB_ICONSTOP);
        Exit;
      end;
    end;
    // default values
    Screen.Cursor := crHourGlass;
    for I := 0 to HTMLLines.Count - 1 do 
    begin
      { $author$, $generator$, $title$ }
      CurrentLine := HTMLLines.Strings[I];
      CurrentLine := SearchAndChange(CurrentLine, '$author$', sCurrentUser);
      if (CurrentLine <> HTMLLines.Strings[I]) then
        HTMLLines.Strings[I] := CurrentLine;
      CurrentLine := HTMLLines.Strings[I];
      CurrentLine := SearchAndChange(CurrentLine, '$generator$', JVCSRES_JEDI_VCS);
      if (CurrentLine <> HTMLLines.Strings[I]) then
        HTMLLines.Strings[I] := CurrentLine;
      CurrentLine := HTMLLines.Strings[I];
      CurrentLine := SearchAndChange(CurrentLine, '$title$', JVCSRES_JEDI_VCS_HTML_Report);
      if (CurrentLine <> HTMLLines.Strings[I]) then
        HTMLLines.Strings[I] := CurrentLine;
    end; // for I := 0 to HTMLLines.Count - 1 do begin
    // HTML report
    for I := 0 to HTMLLines.Count - 1 do 
    begin
      if Pos('$start$', HTMLLines.Strings[I]) > 0 then 
      begin
        if Pos(Chr(10), OutPutString) > 0 then 
        begin
          CurrentString := Copy(OutPutString, 1, Pos(Chr(10), OutPutString) - 2);
          System.Delete(OutPutString, 1, Pos(Chr(10), OutPutString));
          HTMLLines.Strings[I] := '<p><b>' + CurrentString + '</b></p>';
        end;
        K := I;
        try
          while Pos(Chr(10), OutPutString) > 0 do 
          begin
            CurrentString := Copy(OutPutString, 1, Pos(Chr(10), OutPutString) - 2);
            System.Delete(OutPutString, 1, Pos(Chr(10), OutPutString));
            if (Pos('==', CurrentString) = 0) then
            begin
              if Pos('|', CurrentString) > 0 then
              begin
                CurrentString := CurrentString + '|';
                Inc(K);
                HTMLLines.Insert(K, '<table border="1" width="100%">');
                Inc(K);
                HTMLLines.Insert(K, '  <tr>');
                while Pos('|', CurrentString) > 0 do 
                begin
                  CurrentCell := Copy(CurrentString, 1, Pos('|', CurrentString) - 1);
                  System.Delete(CurrentString, 1, Pos('|', CurrentString));
                  CurrentCell := RemoveWhiteSpace(CurrentCell);
                  if CurrentCell = '' then 
                    CurrentCell := '&nbsp;';
                  Inc(K);
                  HTMLLines.Insert(K, '    <td valign="top"><b>' +
                    CurrentCell + '</b></td>');
                end;
                Inc(K);
                HTMLLines.Insert(K, '  </tr>');

                while (Pos(Chr(10), OutPutString) > 0) and
                  (Pos('|', Copy(OutPutString, 1, Pos(Chr(10),
                  OutPutString) - 2)) > 0) do
                begin
                  CurrentString := Copy(OutPutString, 1, Pos(Chr(10),
                    OutPutString) - 2);
                  System.Delete(OutPutString, 1, Pos(Chr(10), OutPutString));
                  if (Pos('----', CurrentString) = 0) then
                  begin
                    CurrentString := CurrentString + '|';
                    Inc(K);
                    HTMLLines.Insert(K, '  <tr>');
                    while Pos('|', CurrentString) > 0 do 
                    begin
                      CurrentCell := Copy(CurrentString, 1, Pos('|',
                        CurrentString) - 1);
                      System.Delete(CurrentString, 1, Pos('|', CurrentString));
                      CurrentCell := RemoveWhiteSpace(CurrentCell);
                      if CurrentCell = '' then
                        CurrentCell := '&nbsp;';
                      Inc(K);
                      HTMLLines.Insert(K, '    <td valign="top">' +
                        CurrentCell + '</td>');
                    end;
                    Inc(K);
                    HTMLLines.Insert(K, '  </tr>');
                  end; // if (Pos('----', CurrentString) = 0) then
                end; // while (Pos(Chr(10), OutPutString) > 0) and...
                Inc(K);
                HTMLLines.Insert(K, '</table>');
              end // if Pos('|', CurrentString) > 0 then begin
              else 
              begin
                Inc(K);
                HTMLLines.Insert(K, '<p>' + CurrentString + '</p>');
              end; // else if Pos('|', CurrentString) > 0 then begin
            end; // if Pos('==', CurrentString) = 0 then begin
          end; // while Pos(Chr(10),  OutPutString) > 0 do begin
        except
          on E: 
          Exception do 
          begin
            BeepIfSet;
            MessageBox(WindowHandle, PChar(Format(JVCSRES_Parsing_the_ListView_content_raised_exception58 + #13#10 +
             '%s', [E.Message])), cMsgBoxCaption,
              MB_OK or MB_ICONSTOP);
            Printer.EndDoc;
            Exit;
          end;
        end;
        Break;
      end; // if Pos('$start$', HTMLLines.Strings[I]) > 0 then begin
    end; // for I := 0 to HTMLLines.Count - 1 do begin
    for I := 0 to HTMLLines.Count - 1 do
      if Pos('$start$', HTMLLines.Strings[I]) > 0 then
        HTMLLines.Strings[I] := '<p></p>';
    for I := 0 to HTMLLines.Count - 1 do
      if Pos('$stop$', HTMLLines.Strings[I]) > 0 then
        HTMLLines.Strings[I] := '<p></p>';
    try
      HTMLLines.SaveToFile(TargetFileName);
    except
      BeepIfSet;
      MessageBox(WindowHandle, PChar(Format(JVCSRES_JEDI_VCS_cannot_save_the_file + #13#10 + '<%s>.' + #13#10 +
        JVCSRES_Be_sure_that_the_file_is_not_opened_by_another_application44 + #13#10 +
        JVCSRES_that_there_is_enough_free_space_on_the_disk + #13#10 +
        JVCSRES_and_that_you_have_the_required_access_rights46, [TargetFileName])),
        cMsgBoxCaption, MB_OK or MB_ICONSTOP);
      Exit;
    end;
    Screen.Cursor := crDefault;
  finally
    HTMLLines.Free;
  end;
  if cbShowResult.Checked then 
  begin
    // keine langen Dateinamen als Parameter
    SetLength(ShortModulName, MAX_PATH);
    SMSize := GetShortPathName(PChar(TargetFileName), PChar(ShortModulName), MAX_PATH);
    SetLength(ShortModulName, SMSize);
    ExecResult := ShellExecute(Application.Handle, 'open',
      PChar(ShortModulName),
      PChar(''),
      PChar(ExtractFileDir(ShortModulName)),
      sw_ShowNormal);
    if ExecResult < 32 then 
    begin
      MessageBox(WindowHandle, PChar(Format(JVCSRES_ShellExecute_Error_6037s62,
        [ExtractFileName(TargetFileName)]) + #10#13 +
        DecodeShellErr(ExecResult)),
        cMsgBoxCaption, MB_OK or MB_ICONWARNING);
    end; // if ExecResult < 32 then begin
  end;
end;

//------------------------------------------------------------------------------

{$IFDEF RTFREPORT}
procedure TVCSSimpleReport.RTFReport;
var 
  I: Integer;
  Align, FontColor, FontAttrib, FontSize, FontName: string;
  RTF: TMemoryStream;
  ExecResult: Integer;
  ShortModulName: string;
  SMSize: Integer;
  TargetFileName, OutPutString, CurrentString, CurrentRTFString: string;
  DlgResult: Boolean;
  FavSaveDialog: TFavSaveDialog;
  RTFFont: TFont;

  function GetFontTableName(Font: TFont): string;
  var  
    DC: HDC;
    SaveFont: HFont;
    Metrics: TTextMetric;
    Temp: Byte;
    charset, family: string;
  begin
    DC := GetDC(0);
    SaveFont := SelectObject(DC, Font.Handle);
    GetTextMetrics(DC, Metrics);
    SelectObject(DC, SaveFont);
    ReleaseDC(0, DC);
    case Metrics.tmCharSet of
      ANSI_CHARSET: 
        charset := 'fcharset0';
      DEFAULT_CHARSET: 
        charset := 'fcharset1';
      SYMBOL_CHARSET: 
        charset := 'fcharset2';
      SHIFTJIS_CHARSET: 
        charset := 'fcharset128';
      OEM_CHARSET: 
        charset := 'fcharset255';
      else 
        charset := '';
    end;
    Temp := Metrics.tmPitchAndFamily;
    Temp := (Temp shr 4) shl 4;
    case Temp of
      FF_DECORATIVE: 
        family := 'fdecorative';
      FF_DONTCARE: 
        family := 'fdontcare';
      FF_MODERN: 
        family := 'fmodern';
      FF_ROMAN: 
        family := 'froman';
      FF_SCRIPT: 
        family := 'fscript';
      FF_SWISS: 
        family := 'fswiss';
      else 
        family := 'froman';
    end;
    Result := '{\f' + '0' + '\' + family + '\' + charset + ' ' +
      Font.Name + ';}';
  end;

  procedure StreamWriteStr(var MS: TMemoryStream; S: string);
  begin
    MS.Write(S[1], Length(S));
  end;
begin
  OutPutString := ParsedReportString;
  FavSaveDialog := TFavSaveDialog.Create(Application);
  try
    with FavSaveDialog do 
    begin
      Title := JVCSRES_Save_report_to_RTF_file;
      Options := [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing];
      Filter := JVCSRES_RTF_files_404246rtf411244246rtf124All_files_4042464241124424642;
      FileName := ChangeFileExt(SaveFileName, '.rtf');
      InitialDir := SavePath;
      DefaultExt := 'rtf';

      //FavSaveDialog is inherited from FavOpenDialog and thatswhy
      //ExecuteFavOpenDialogWithMru also works here
      DlgResult := ExecuteFavOpenDialogWithMru(FavSaveDialog,
        sBaseRegistryKey + crbMRU + '17');

      TargetFileName := FileName;
    end; // with SaveDialog1 do begin
  finally
    FavSaveDialog.Free;
  end;

  if not DlgResult then
    Exit;

  RTF := TMemoryStream.Create;
  RTFFont := TFont.Create;
  RTFFont.Name := 'Courier New';
  RTFFont.Size := 8;
  try
    // create header
    StreamWriteStr(RTF, '{\rtf1\ansi\ansicpg1252\deff0\deftab720');
    StreamWriteStr(RTF, '{\fonttbl');
    StreamWriteStr(RTF, GetFontTableName(RTFFont));
    StreamWriteStr(RTF, '}');
    StreamWriteStr(RTF, '{\colortbl');
    StreamWriteStr(RTF, '\red0\green0\blue0;');     {Black}
{    StreamWriteStr(RTF,'\red128\green0\blue0;');
    StreamWriteStr(RTF,'\red0\green128\blue0;');
    StreamWriteStr(RTF,'\red128\green128\blue0;');
    StreamWriteStr(RTF,'\red0\green0\blue128;');
    StreamWriteStr(RTF,'\red128\green0\blue128;');
    StreamWriteStr(RTF,'\red0\green128\blue128;');
    StreamWriteStr(RTF,'\red128\green128\blue128;');
    StreamWriteStr(RTF,'\red192\green192\blue192;');
    StreamWriteStr(RTF,'\red255\green0\blue0;');
    StreamWriteStr(RTF,'\red0\green255\blue0;');
    StreamWriteStr(RTF,'\red255\green255\blue0;');
    StreamWriteStr(RTF,'\red0\green0\blue255;');
    StreamWriteStr(RTF,'\red255\green0\blue255;');
    StreamWriteStr(RTF,'\red0\green255\blue255;');
    StreamWriteStr(RTF,'\red255\green255\blue255;');}
    StreamWriteStr(RTF, '}');

    Align := '';
    FontColor := '\cf0';
    FontSize := '\fs' + IntToStr(8 * 2);
    FontAttrib := '';
    FontName := '\f0';
    StreamWriteStr(RTF, '\par \pard' + Align + '\plain' + FontName +
      FontSize + FontAttrib + FontColor);
    try
      while Pos(Chr(10), OutPutString) > 0 do 
      begin
        CurrentString := Copy(OutPutString, 1, Pos(Chr(10), OutPutString) - 2);
        System.Delete(OutPutString, 1, Pos(Chr(10), OutPutString));
        if Length(CurrentString) > 0 then 
        begin
          CurrentRTFString := '';
          for I := 1 to Length(CurrentString) do 
          begin
            if CurrentString[I] = '\' then
              CurrentRTFString := CurrentRTFString + '\\'
            else
              CurrentRTFString := CurrentRTFString + CurrentString[I];
          end; // for I := 1 to Length(CurrentString) do begin
        end // if Length(CurrentString) > 0 then begin
        else 
          CurrentRTFString := CurrentString;
        StreamWriteStr(RTF, ' \par ' + CurrentRTFString);
      end; // while Pos(Chr(10),  OutPutString) > 0 do begin
    except
      on E: 
      Exception do 
      begin
        BeepIfSet;
        MessageBox(WindowHandle, PChar(Format(JVCSRES_Parsing_the_ListView_content_raised_exception58 + #13#10 +
          '%s', [E.Message])), cMsgBoxCaption,
          MB_OK or MB_ICONSTOP);
        Printer.EndDoc;
        Exit;
      end;
    end;
    StreamWriteStr(RTF, #13#10 + '}}');
    RTF.SaveToFile(TargetFileName);
  finally
    RTFFont.Free;
    RTF.Free;
  end;
  if cbShowResult.Checked then 
  begin
    // keine langen Dateinamen als Parameter
    SetLength(ShortModulName, MAX_PATH);
    SMSize := GetShortPathName(PChar(TargetFileName), PChar(ShortModulName), MAX_PATH);
    SetLength(ShortModulName, SMSize);
    ExecResult := ShellExecute(Application.Handle, 'open',
      PChar(ShortModulName),
      PChar(''),
      PChar(ExtractFileDir(ShortModulName)),
      sw_ShowNormal);
    if ExecResult < 32 then 
    begin
      MessageBox(WindowHandle, PChar(Format(JVCSRES_ShellExecute_Error_6037s62, 
        [ExtractFileName(TargetFileName)]) + #10#13 +
        DecodeShellErr(ExecResult)),
        cMsgBoxCaption, MB_OK or MB_ICONWARNING);
    end; // if ExecResult < 32 then begin
  end;
end;
{$ENDIF RTFREPORT}

//------------------------------------------------------------------------------

procedure TVCSSimpleReport.CheckColumnsToShow;
var
  ColumnsToShow: Boolean;
  I: Integer;
begin
  if clbInclude.Items.Count = 0 then 
    Exit;
  ColumnsToShow := False;
  for I := 0 to clbInclude.Items.Count - 1 do
    if clbInclude.Checked[I] then
      ColumnsToShow := True;
  btnPreview.Enabled := ColumnsToShow;
  btnReport.Enabled := ColumnsToShow;
  if ColumnsSetup then
    imgSaved.Visible := False;
end;

procedure TVCSSimpleReport.clbIncludeClick(Sender: TObject);
begin
  CheckColumnsToShow;
end;

procedure TVCSSimpleReport.clbIncludeKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  CheckColumnsToShow;
end;

procedure TVCSSimpleReport.SelectAllColumns1Click(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to clbInclude.Items.Count - 1 do
    clbInclude.Checked[I] := True;
  CheckColumnsToShow;
end;

procedure TVCSSimpleReport.UnselectAllColumns1Click(Sender: TObject);
var 
  I: Integer;
begin
  for I := 0 to clbInclude.Items.Count - 1 do
    clbInclude.Checked[I] := False;
  CheckColumnsToShow;
end;

procedure TVCSSimpleReport.SaveasDefault1Click(Sender: TObject);
var 
  I, CurrentSetting: Integer;
begin
  CurrentSetting := 0;
  for I := 0 to clbInclude.Items.Count - 1 do
    if clbInclude.Checked[I] then
      CurrentSetting := CurrentSetting or (Round(Power(2, I)));

  jvcsWriteInteger(sBaseRegistryKey + crbPrinter + '\SimpleReportColumns',
    IntToHex(RepID, 8), CurrentSetting);

  imgSaved.Visible := True;
end;

end.
