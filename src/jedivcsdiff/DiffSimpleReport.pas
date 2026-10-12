(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: DiffSimpleReport.pas

The Initial Developer of the original Code (FVCSDiff) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDIVCSDiff: Thomas Huber (Thomas_D_Huber@gmx.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FVCSDiff code to JEDIVCSDiff
2003/05/26  THuber    - changed registry key according to main
2004/01/18  USchuster - now with constant for message box caption
2004/04/12  THuber    - use chm help instead of hlp help
2004/11/12  USchuster - style cleaning
                      - added dxGetText support for localization with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit DiffSimpleReport;

{$I jedi.inc}
{$I compopt.inc}

{$DEFINE RTFREPORT}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, JVCSForms;

type
  TVCSSimpleReport = class(TJVCSForm)
    rbClipBoard: TRadioButton;
    rbSave: TRadioButton;
    rbPrint: TRadioButton;
    btnPreview: TButton;
    btnReport: TButton;
    btnClose: TButton;
    PrintDialog1: TPrintDialog;
    rbHTML: TRadioButton;
    cbShowResult: TCheckBox;
    rbRTF: TRadioButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCloseClick(Sender: TObject);
    procedure btnPreviewClick(Sender: TObject);
    procedure btnReportClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure rbClipBoardClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    function SearchAndChange(const TextString, SearchString,
      ChangeString: string): string;
    procedure EnableShowResult;
    procedure CopyToClipBoard;
    procedure SaveToFile;
    procedure Print;
    procedure HTMLReport;
    {$IFDEF RTFREPORT}
    procedure RTFReport;
    {$ENDIF RTFREPORT}
  public
    { Public declarations }
    ReportString,
    SaveFileName,
    SavePath: string;
    LineCount: Integer;
  end;

var
  VCSSimpleReport: TVCSSimpleReport;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  ShellAPI, Printers, ClipBrd, Historylist, FavOpenDialog, RegAcc, DiffMain,
  ListView, DiffHelp, JVCSDiffResources;

{$R *.dfm}

function TVCSSimpleReport.SearchAndChange(const TextString, SearchString, ChangeString: string): string;
var
  Q: Integer;
  D: string;
begin
  D := '';
  Q := 0;
  repeat
    Inc(Q);
    if UpperCase(Copy(TextString,Q,Length(SearchString))) = UpperCase(SearchString) then
    begin
      D := D + ChangeString;
      Q := Q + Length(SearchString)-1;
    end
    else
      D := D + Copy(TextString,Q,1);
  until Q >= Length(TextString);
  Result := D;
end;

//------------------------------------------------------------------------------

procedure TVCSSimpleReport.FormCreate(Sender: TObject);
begin
  try
    case RegReadInteger(HKCU, RegDiffBase, 'SReportTarget', 0) of
      0: rbClipBoard.Checked := True;
      1: rbSave.Checked := True;
      2: rbPrint.Checked := True;
      3: rbHTML.Checked := True;
      4: rbRTF.Checked := True;
    end;
    cbShowResult.Checked := RegReadBool(HKCU, RegDiffBase,
      'SReportShow', False);
    EnableShowResult;
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
end;

//------------------------------------------------------------------------------

procedure TVCSSimpleReport.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  LastTarget: Integer;
begin
  LastTarget := 0;
  if rbClipBoard.Checked then LastTarget := 0;
  if rbSave.Checked then LastTarget := 1;
  if rbPrint.Checked then LastTarget := 2;
  if rbHTML.Checked then LastTarget := 3;
  if rbRTF.Checked then LastTarget := 4;
  RegWriteInteger(HKCU, RegDiffBase, 'SReportTarget',
    LastTarget);
  RegWriteBool(HKCU, RegDiffBase, 'SReportShow',
    cbShowResult.Checked);
end;

//------------------------------------------------------------------------------

procedure TVCSSimpleReport.rbClipBoardClick(Sender: TObject);
begin
  EnableShowResult;
end;

//------------------------------------------------------------------------------

procedure TVCSSimpleReport.EnableShowResult;
begin
  cbShowResult.Enabled := rbSave.Checked or rbHTML.Checked or rbRTF.Checked;
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
    VCSListView.SetUpText(ReportString);
    VCSListView.ShowModal;
  finally
    VCSListView.Free;
    VCSListView := nil;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSSimpleReport.btnReportClick(Sender: TObject);
begin
  if rbClipBoard.Checked then CopyToClipBoard;
  if rbSave.Checked then SaveToFile;
  if rbPrint.Checked then Print;
  if rbHTML.Checked then HTMLReport;
  if rbRTF.Checked then RTFReport;
end;

//------------------------------------------------------------------------------

procedure TVCSSimpleReport.CopyToClipBoard;
begin
  try
    ClipBoard.SetTextBuf(PChar(ReportString));
  except
    MessageBox(WindowHandle, PChar(JVCSRES_Cannot_access_clipboard46), cMessageBoxCaption,
               MB_OK or MB_ICONEXCLAMATION);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSSimpleReport.SaveToFile;
var
  TargetFileName,
  OutPutString,
  CurrentString,
  ShortModulName: string;
  ResultStringList: TStringList;
  FAVDirectories: THistoryList;
  DlgResult: Boolean;
  FavSaveDialog: TFavSaveDialog;
  SMSize,
  ExecResult: Integer;
begin
  OutPutString := ReportString;
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
      MaxCount := RegReadInteger(HKCU, RegDiffBase,
          'FileDlgMRU', 10);
      // Favorites
      FAVDirectories := THistoryList.Create;
      try
        FAVDirectories.MaxLen := MaxCount;
        FAVDirectories.LoadFromReg(RegDiffMRU);
        Favorites.Assign(FAVDirectories);
        DlgResult := FavSaveDialog.Execute;
        FAVDirectories.Clear;
        FAVDirectories.Assign(Favorites);
        // store recent list
        FAVDirectories.SaveToReg(RegDiffMRU);
        TargetFileName := FileName;
      finally
        FAVDirectories.Free;
      end;
    end; // with SaveDialog1 do begin
  finally
    FavSaveDialog.Free;
  end;

  if not DlgResult then Exit;

  ResultStringList := TStringList.Create;
  try
    try
      while Pos(Chr(10),  OutPutString) > 0 do
      begin
        CurrentString := Copy(OutPutString, 1, Pos(Chr(10),  OutPutString) - 2);
        System.Delete(OutPutString, 1, Pos(Chr(10),  OutPutString));
        ResultStringList.Add(CurrentString);
      end; // while Pos(Chr(10),  OutPutString) > 0 do begin
    except
      on E: Exception do
      begin
        Windows.Beep(500, 100);
        MessageBox(WindowHandle,
          PChar(JVCSRES_Parsing_the_ListView_content_raised_exception58_ + #10#13 +
          E.Message), cMessageBoxCaption, MB_OK or MB_ICONSTOP);
        Exit;
      end;
    end;
    try
      ResultStringList.SaveToFile(TargetFileName);
    except
      Windows.Beep(500, 100);
      MessageBox(WindowHandle, PChar(Format(JVCSRES_Error_while_trying_to_save_the_file_37s,
        [TargetFileName])), cMessageBoxCaption, MB_OK or MB_ICONSTOP);
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
       [ExtractFileName(TargetFileName)])), cMessageBoxCaption, MB_OK or MB_ICONWARNING);
    end; // if ExecResult < 32 then begin
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSSimpleReport.Print;
var
  wTextHeight: Word;
  I,
  TopMarg,
  LeftMarg,
  iLinePos,
  iLines,
  iLPS: Integer;
  iSides: Single;
  OutPutString,
  CurrentString,
  Device: string;
  DefaultPrinter: Boolean;
begin
  OutPutString := ReportString;
  DefaultPrinter := True;
  try
    with Printer do Device := Printers[PrinterIndex];
  except
    DefaultPrinter := False;
  end;
  if (not DefaultPrinter) or (Device = '') then
  begin
    MessageBox(Handle, PChar(JVCSRES_You_do_not_have_a_default_printer_defined33),
      cMessageBoxCaption, MB_OK or MB_ICONWARNING);
    Exit;
  end;
  with Printer do
  begin
    Canvas.Font.Size := 8;
    Canvas.Font.Name := 'Courier New';
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
    if Round(iSides) = 0 then MaxPage := 1
    else MaxPage := Round(iSides);
    if not Execute then Exit;
    ToPage := MaxPage;
  end; // with PrintDialog1 do begin
  with Printer do
  begin
    Device := Printers[PrinterIndex];
    Canvas.Font.Size := 8;
    Canvas.Font.Name := 'Courier New';
    Canvas.Font.Style := [];
    wTextHeight := Canvas.TextHeight('XX');
  end; // with Printer do begin

  LeftMarg := 0;
  TopMarg := 0;

  Screen.Cursor := crHourGlass;
  Printer.Title := JVCSRES_JVCS_Diff_Report;

  // Start Druckanweisungen
  Printer.BeginDoc;
  Printer.Canvas.Font.Style := [];
  iLinePos := 2 * wTextHeight;
  for I := 0 to TopMarg do
  begin
    Printer.Canvas.TextOut(10, iLinePos, '');
    Inc(iLinePos, wTextHeight);
  end;
//  if RegReadBool(HKCU, sBaseRegistryKey + crbPrinter, 'PrintHeader', False) then begin
//  end;

  try
    while Pos(Chr(10),  OutPutString) > 0 do
    begin
      CurrentString := Copy(OutPutString, 1, Pos(Chr(10),  OutPutString) - 2);
      System.Delete(OutPutString, 1, Pos(Chr(10),  OutPutString));
      for I := 0 to LeftMarg do CurrentString := ' ' + CurrentString;
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
    on E: Exception do
    begin
      Windows.Beep(500, 100);
        MessageBox(WindowHandle,
          PChar(JVCSRES_Parsing_the_ListView_content_raised_exception58_ + #10#13 +
          E.Message), cMessageBoxCaption, MB_OK or MB_ICONSTOP);
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
  HTMLTemplate,
  CurrentLine,
  CurrentCell: string;
  HTMLLines: TStringList;
  I, K,
  ExecResult: Integer;
  ShortModulName:  string;
  SMSize: Integer;
  TargetFileName,
  OutPutString,
  CurrentString: string;
  FAVDirectories: THistoryList;
  DlgResult: Boolean;
  FavSaveDialog: TFavSaveDialog;

  function RemoveWhiteSpace(SourceString: string): string;
  begin
    while (Length(SourceString) > 0) and
          (SourceString[1] = ' ') do System.Delete(SourceString, 1, 1);
    while (Length(SourceString) > 0) and
          (SourceString[Length(SourceString)] = ' ') do
      System.Delete(SourceString, Length(SourceString), 1);
    Result := SourceString;
  end;

begin
  OutPutString := ReportString;
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
      MaxCount := RegReadInteger(HKCU, RegDiffBase,
          'FileDlgMRU', 10);
      // Favorites
      FAVDirectories := THistoryList.Create;
      try
        FAVDirectories.MaxLen := MaxCount;
        FAVDirectories.LoadFromReg(RegDiffMRU);
        Favorites.Assign(FAVDirectories);
        DlgResult := FavSaveDialog.Execute;
        FAVDirectories.Clear;
        FAVDirectories.Assign(Favorites);
        // store recent list
        FAVDirectories.SaveToReg(RegDiffMRU);
        TargetFileName := FileName;
      finally
        FAVDirectories.Free;
      end;
    end; // with SaveDialog1 do begin
  finally
    FavSaveDialog.Free;
  end;

  if not DlgResult then Exit;

  HTMLTemplate := ExtractFilePath(Application.ExeName) + 'htm_rep.htm';

  HTMLLines := TStringList.Create;
  try
    try
      HTMLLines.LoadFromFile(HTMLTemplate);
    except
      on E: Exception do
      begin
        MessageBox(Handle, PChar(Format(JVCSRES_Reading_file_6037s62 + #10#13 +
          JVCSRES_raised_exception58 + #10#13 + '%s.', [HTMLTemplate, E.Message])),
          cMessageBoxCaption, MB_OK or MB_ICONSTOP);
        Exit;
      end;
    end;
    // default values
    Screen.Cursor := crHourGlass;
    for I := 0 to HTMLLines.Count - 1 do
    begin
      { $author$, $generator$, $title$ }
      CurrentLine := HTMLLines.Strings[I];
      CurrentLine := SearchAndChange(CurrentLine, '$author$', cMessageBoxCaption);
      if (CurrentLine <> HTMLLines.Strings[I]) then
        HTMLLines.Strings[I] := CurrentLine;
      CurrentLine := HTMLLines.Strings[I];
      CurrentLine := SearchAndChange(CurrentLine, '$generator$', cMessageBoxCaption);
      if (CurrentLine <> HTMLLines.Strings[I]) then
        HTMLLines.Strings[I] := CurrentLine;
      CurrentLine := HTMLLines.Strings[I];
      CurrentLine := SearchAndChange(CurrentLine, '$title$', JVCSRES_JVCS_Diff_HTML_Report);
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
          CurrentString := Copy(OutPutString, 1, Pos(Chr(10),  OutPutString) - 2);
          System.Delete(OutPutString, 1, Pos(Chr(10),  OutPutString));
          HTMLLines.Strings[I] := '<p><b>' + CurrentString + '</b></p>';
        end;
        K := I;
        try
          while Pos(Chr(10),  OutPutString) > 0 do
          begin
            CurrentString := Copy(OutPutString, 1, Pos(Chr(10),  OutPutString) - 2);
            System.Delete(OutPutString, 1, Pos(Chr(10),  OutPutString));
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
                  if CurrentCell = '' then CurrentCell := '&nbsp;';
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
                  System.Delete(OutPutString, 1, Pos(Chr(10),  OutPutString));
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
                      if CurrentCell = '' then CurrentCell := '&nbsp;';
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
          on E: Exception do
          begin
            Windows.Beep(500, 100);
            MessageBox(WindowHandle,
              PChar(JVCSRES_Parsing_the_ListView_content_raised_exception58_ + #10#13 +
              E.Message), cMessageBoxCaption, MB_OK or MB_ICONSTOP);
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
      Windows.Beep(500, 100);
      MessageBox(WindowHandle, PChar(Format(JVCSRES_Error_while_trying_to_save_the_file_37s,
        [TargetFileName])), cMessageBoxCaption, MB_OK or MB_ICONSTOP);
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
        [ExtractFileName(TargetFileName)])), cMessageBoxCaption, MB_OK or MB_ICONWARNING);
    end; // if ExecResult < 32 then begin
  end;
end;

//------------------------------------------------------------------------------

{$IFDEF RTFREPORT}
procedure TVCSSimpleReport.RTFReport;
var
  I: Integer;
  Align,
  FontColor,
  FontAttrib,
  FontSize,
  FontName: string;
  RTF: TMemoryStream;
  ExecResult: Integer;
  ShortModulName:  string;
  SMSize: Integer;
  TargetFileName,
  OutPutString,
  CurrentString,
  CurrentRTFString: string;
  FAVDirectories: THistoryList;
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
      ANSI_CHARSET: charset := 'fcharset0';
      DEFAULT_CHARSET: charset := 'fcharset1';
      SYMBOL_CHARSET: charset := 'fcharset2';
      SHIFTJIS_CHARSET: charset := 'fcharset128';
      OEM_CHARSET: charset := 'fcharset255';
      else charset := '';
    end;
    Temp := Metrics.tmPitchAndFamily;
    Temp := (Temp shr 4) shl 4;
    case Temp of
      FF_DECORATIVE:	family := 'fdecorative';
      FF_DONTCARE:	family := 'fdontcare';
      FF_MODERN:	family := 'fmodern';
      FF_ROMAN:	family := 'froman';
      FF_SCRIPT:	family := 'fscript';
      FF_SWISS:	family := 'fswiss';
      else family := 'froman';
    end;
    Result := '{\f' + '0' + '\' + family + '\' + charset + ' ' +
      Font.Name+ ';}';
  end;

  procedure StreamWriteStr(var MS: TMemoryStream; S: string);
  begin
    MS.Write(S[1], Length(S));
  end;

begin
  OutPutString := ReportString;
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
      MaxCount := RegReadInteger(HKCU, RegDiffBase,
          'FileDlgMRU', 10);
      // Favorites
      FAVDirectories := THistoryList.Create;
      try
        FAVDirectories.MaxLen := MaxCount;
        FAVDirectories.LoadFromReg(RegDiffMRU);
        Favorites.Assign(FAVDirectories);
        DlgResult := FavSaveDialog.Execute;
        FAVDirectories.Clear;
        FAVDirectories.Assign(Favorites);
        // store recent list
        FAVDirectories.SaveToReg(RegDiffMRU);
        TargetFileName := FileName;
      finally
        FAVDirectories.Free;
      end;
    end; // with SaveDialog1 do begin
  finally
    FavSaveDialog.Free;
  end;

  if not DlgResult then Exit;

  RTF := TMemoryStream.Create;
  RTFFont := TFont.Create;
  RTFFont.Name := 'Courier New';
  RTFFont.Size := 8;
  try
    // create header
    StreamWriteStr(RTF,'{\rtf1\ansi\ansicpg1252\deff0\deftab720');
    StreamWriteStr(RTF,'{\fonttbl');
    StreamWriteStr(RTF, GetFontTableName(RTFFont));
    StreamWriteStr(RTF,'}');
    StreamWriteStr(RTF,'{\colortbl');
    StreamWriteStr(RTF,'\red0\green0\blue0;');     {Black}
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
    StreamWriteStr(RTF,'}');

    Align := '';
    FontColor := '\cf0';
    FontSize := '\fs' + IntToStr(8 * 2);
    FontAttrib := '';
    FontName := '\f0';
    StreamWriteStr(RTF, '\par \pard' + Align + '\plain' + FontName +
      FontSize + FontAttrib + FontColor);
    try
      while Pos(Chr(10),  OutPutString) > 0 do
      begin
        CurrentString := Copy(OutPutString, 1, Pos(Chr(10),  OutPutString) - 2);
        System.Delete(OutPutString, 1, Pos(Chr(10),  OutPutString));
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
        else CurrentRTFString := CurrentString;
        StreamWriteStr(RTF,' \par ' + CurrentRTFString);
      end; // while Pos(Chr(10),  OutPutString) > 0 do begin
    except
      on E: Exception do
      begin
        Windows.Beep(500, 100);
        MessageBox(WindowHandle,
          PChar(JVCSRES_Parsing_the_ListView_content_raised_exception58_ + #10#13 +
          E.Message), cMessageBoxCaption, MB_OK or MB_ICONSTOP);
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
        [ExtractFileName(TargetFileName)])), cMessageBoxCaption, MB_OK or MB_ICONWARNING);
    end; // if ExecResult < 32 then begin
  end;
end;
{$ENDIF RTFREPORT}

procedure TVCSSimpleReport.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // set TForm.KeyPreview := true !
  if Key = VK_F1 then
    ShowHelpContext(Application, IDH_jvcsdiff_report_differences);
end;

end.
