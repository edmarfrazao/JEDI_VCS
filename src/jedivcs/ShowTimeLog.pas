(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: ShowTimeLog.pas

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
2003/03/05  THensle   - changes for "ConfigStorage" unit
2003/12/28  USchuster - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use constant)
2004/09/17  FHasovic  - Added dxGetText support for localization                      
2004/10/10  USchuster - style cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
                      - fixed memory leak
                      - fixed ERangeError in GetListViewString
2004/10/31  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 final released ^^^^^^^^^^^^^^^^^^^^^^^^^^
2006/04/30  THuber    #3611 config folder now windows user dependend (appdata shell folder)
2007/06/30  USchuster - changes for large fonts (contraints and default size depend now on PixelsPerInch; analog to Mantis #3710)
2007/08/13  USchuster - Trace -> TraceMsg
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit ShowTimeLog;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  {$IFDEF DEBUG}
  JclDebug,
  {$ENDIF DEBUG}
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, Buttons, StdCtrls, ExtCtrls, Menus;

const
  dfcMon = 1;
  dfcTue = 2;
  dfcWed = 4;
  dfcThu = 8;
  dfcFri = 16;
  dfcSat = 32;
  dfcSun = 64;

type
  TLVData = record
    Duration: Double;
  end;

type
  TVCSShowTimeLog = class(TForm)
    Panel1: TPanel;
    btnClose: TButton;
    lvTimeLog: TListView;
    cbTimeLog: TCheckBox;
    Help: TSpeedButton;
    btnClear: TButton;
    pnResult: TPanel;
    Label1: TLabel;
    lblTime: TLabel;
    Label2: TLabel;
    lblTime2: TLabel;
    lblSum: TLabel;
    Label3: TLabel;
    btnReport: TButton;
    Label4: TLabel;
    pnFilter: TPanel;
    btnFilter: TButton;
    PopupMenu1: TPopupMenu;
    MoreDetails1: TMenuItem;
    btnCalc: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCloseClick(Sender: TObject);
    procedure spBtnClearClick(Sender: TObject);
    procedure cbTimeLogClick(Sender: TObject);
    procedure HelpTopics1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure HelpClick(Sender: TObject);
    procedure btnReportClick(Sender: TObject);
    procedure btnFilterClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MoreDetails1Click(Sender: TObject);
    procedure btnCalcClick(Sender: TObject);
    procedure lvTimeLogDeletion(Sender: TObject; Item: TListItem);
  private
    { Private declarations }
    FCreating: Boolean;
    StartTime,
    EndTime,
    FirstTime,
    LastTime,
    Duration,
    Summary,
    DateStartFilter,
    DateEndFilter: Double;
    UserFilter: string;
    UserList: TStringList;
    procedure ReadTimeLog;
    function CalcDuration(Value: Double): string;
    function GetListViewString: string;
    function GetSummaryDetails: string;
  public
    { Public declarations }
    procedure RestrictSize(var Msg: TMessage); message WM_GETMINMAXINFO;
  end;

var
  VCSShowTimeLog: TVCSShowTimeLog;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSBase, VCSProcBase, CommCtrl, SimpleReport, TimeLogFilter, ConfigStorage,
  JVCSGUIClientResources;

var
  PLVData: ^TLVData;

{$R *.dfm}

  { open;Administrator;36281,548822037 }

procedure TVCSShowTimeLog.FormCreate(Sender: TObject);
var
  ToolTipHandle: HWND;
  DlgTop,
  DlgLeft,
  DlgWidth,
  DlgHeight: Integer;
begin
  try
    FCreating := True;
    // ListView Tooltips
    SendMessage(lvTimeLog.Handle, LVM_SETEXTENDEDLISTVIEWSTYLE, LVS_EX_INFOTIP,
      LVS_EX_INFOTIP);
    ToolTipHandle := SendMessage(lvTimeLog.Handle, LVM_GETTOOLTIPS, 0, 0);
    SendMessage(ToolTipHandle, TTM_SETDELAYTIME, TTDT_AUTOMATIC, 1);
    SendMessage(ToolTipHandle, TTM_SETDELAYTIME, TTDT_AUTOPOP, 3000);

    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    if not jvcsReadWindowPosAndSize(sBaseRegistryKey + crbWindows, 'ShowTimeLog',
      DlgTop, DlgLeft, DlgWidth, DlgHeight) then
    begin
      DlgTop := (Screen.Height - Height) div 2;
      DlgLeft := (Screen.Width - Width) div 2;
      DlgWidth := MulDiv(400, PixelsPerInch, 96);
      DlgHeight := MulDiv(285, PixelsPerInch, 96);
    end;
    Top := DlgTop;
    Left := DlgLeft;
    Width := DlgWidth;
    Height := DlgHeight;

    with lvTimeLog do
    begin
      Columns[0].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ShowTimeLog_Col1.0', 75);
      Columns[1].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ShowTimeLog_Col1.1', 100);
      Columns[2].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ShowTimeLog_Col1.2', 100);
      Columns[3].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ShowTimeLog_Col1.3', 75);
    end;

    // Time log
    {$IFDEF DEBUG}
    JclDebug.TraceMsg('PM: Check Timelog active: ' + ExtractFileName(sProjectName));
    {$ENDIF DEBUG}
    cbTimeLog.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbTimeLog, ExtractFileName(sProjectName), False);

    UserFilter := '';
    DateStartFilter := 0;
    DateEndFilter := 66000;
    UserList := TStringList.Create;
    UserList.Sorted := True;
    UserList.Duplicates := dupIgnore;

    Screen.Cursors[cPopUpMCursor] := LoadCursor(hInstance, PChar('CURSORRM'));
    pnResult.Cursor := cPopUpMCursor;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSShowTimeLog.FormActivate(Sender: TObject);
var
  I: Integer;
begin
  Application.ProcessMessages;
  if FCreating then
  begin
    FCreating := False;
    Caption := Format(JVCSRES_VCS_Time_Log_45_37s, [AnsiLowerCase(ExtractFileName(sProjectName))]);
    ReadTimeLog;
    DateStartFilter := FirstTime;
    DateEndFilter := LastTime;
    for I := 0 to lvTimeLog.Items.Count - 1 do
      UserList.Add(lvTimeLog.Items[I].Caption);
  end; // if FCreating then begin
end;

//------------------------------------------------------------------------------

function TVCSShowTimeLog.CalcDuration(Value: Double): string;
var 
  Hours, Mins: Integer;
  MinStr: string;
begin
  if Value <= 0 then 
  begin
    Result := JVCSRES_Convert_Error;
    Exit;
  end;
  Hours := Round(Int(Value * 24));
  Value := Value - (Hours * (1 / 24));
  if Value > 0 then 
  begin
    Mins := Round(Value * 1440);
    MinStr := IntToStr(Mins);
  end 
  else
    MinStr := '00';
  if Length(MinStr) < 2 then 
    MinStr := '0' + MinStr;
  Result := Format(JVCSRES_37d_h_37s_min, [Hours, MinStr]);
end;

//------------------------------------------------------------------------------

procedure TVCSShowTimeLog.ReadTimeLog;
var 
  LogFileStrings: TStringList;
  CurrEntry, TLGFileName, User: string;
  I: Integer;
  NewItem: TListItem;
  IncludeRecord: Boolean;
begin
  StartTime := 0;
  EndTime := 0;
  TLGFileName := sConfigFolder + ChangeFileExt(ExtractFileName(sProjectName), '.tlg');
  if FileExists(TLGFileName) then
  begin
    Screen.Cursor := crHourGlass;
    lvTimeLog.Items.Clear;
    try
      lvTimeLog.Items.BeginUpdate;
      LogFileStrings := TStringList.Create;
      try
        try
          LogFileStrings.LoadFromFile(TLGFileName);
        except
          on E: Exception do 
          begin
            LogFileStrings.Clear;
            BeepIfSet;
            MessageBox(Handle, PChar(Format(JVCSRES_Reading_file_6037s62 + #13#10 +
              JVCSRES_raised_exception58 + #13#10 + '%s.', [TLGFileName, E.Message])),
              cMsgBoxCaption, MB_OK or MB_ICONSTOP);
          end;
        end;
        I := 0;
        FirstTime := 9999999;
        LastTime := 0;
        Summary := 0;
        while I < LogFileStrings.Count - 1 do
        begin
          if (Copy(LogFileStrings.Strings[I], 1, 4) = 'open') and
            (Copy(LogFileStrings.Strings[I + 1], 1, 5) = 'close') then 
          begin
            CurrEntry := LogFileStrings.Strings[I];
            while CurrEntry[1] <> ';' do
              Delete(CurrEntry, 1, 1);
            Delete(CurrEntry, 1, 1);
            User := Copy(CurrEntry, 1, Pos(';', CurrEntry) - 1);
            while CurrEntry[1] <> ';' do 
              Delete(CurrEntry, 1, 1);
            Delete(CurrEntry, 1, 1);
            StartTime := _StrToFloat(CurrEntry);
            CurrEntry := LogFileStrings.Strings[I + 1];
            while CurrEntry[1] <> ';' do 
              Delete(CurrEntry, 1, 1);
            Delete(CurrEntry, 1, 1);
            while CurrEntry[1] <> ';' do 
              Delete(CurrEntry, 1, 1);
            Delete(CurrEntry, 1, 1);
            EndTime := _StrToFloat(CurrEntry);

            IncludeRecord := True;
            // user
            if UserFilter <> '' then
              IncludeRecord := (User = UserFilter);
            // date filter
            if IncludeRecord then
              IncludeRecord := (StartTime >= DateStartFilter) and
                (EndTime <= DateEndFilter);

            if IncludeRecord then 
            begin
              if StartTime < FirstTime then 
                FirstTime := StartTime;
              if EndTime > LastTime then
                LastTime := EndTime;
              Duration := EndTime - StartTime;
              Summary := Summary + Duration;

              NewItem := lvTimeLog.Items.Add;
              NewItem.Caption := User;
              NewItem.SubItems.Add(DateTimeToStr(StartTime));
              NewItem.SubItems.Add(DateTimeToStr(EndTime));
              NewItem.SubItems.Add(CalcDuration(Duration));
              NewItem.SubItems.Add('-');

              New(PLVData);
              PLVData^.Duration := Duration;
              NewItem.Data := PLVData;
            end; // if IncludeRecord then begin
          end; // if (Copy(LogFileStrings.Strings[I], 1, 4) = 'open') and...
          Inc(I);
        end; // while I <= LogFileStrings.Count - 1 do begin
        if (I = LogFileStrings.Count - 1) and
          (Copy(LogFileStrings.Strings[I], 1, 4) = 'open') then 
        begin
          CurrEntry := LogFileStrings.Strings[I];
          while CurrEntry[1] <> ';' do 
            Delete(CurrEntry, 1, 1);
          Delete(CurrEntry, 1, 1);
          User := Copy(CurrEntry, 1, Pos(';', CurrEntry) - 1);
          while CurrEntry[1] <> ';' do 
            Delete(CurrEntry, 1, 1);
          Delete(CurrEntry, 1, 1);
          StartTime := _StrToFloat(CurrEntry);
          EndTime := Now;

          IncludeRecord := True;
          // user
          if UserFilter <> '' then
            IncludeRecord := (User = UserFilter);
          // date filter
          if IncludeRecord then
            IncludeRecord := (StartTime >= DateStartFilter) and
              (EndTime <= DateEndFilter);

          if IncludeRecord then 
          begin
            if StartTime < FirstTime then 
              FirstTime := StartTime;
            if EndTime > LastTime then 
              LastTime := EndTime;
            Duration := EndTime - StartTime;
            Summary := Summary + Duration;


            NewItem := lvTimeLog.Items.Add;
            NewItem.Caption := User;
            NewItem.SubItems.Add(DateTimeToStr(StartTime));
            NewItem.SubItems.Add(DateTimeToStr(EndTime));
            NewItem.SubItems.Add(CalcDuration(Duration));
            NewItem.SubItems.Add('-');

            New(PLVData);
            PLVData^.Duration := Duration;
            NewItem.Data := PLVData;
          end; // if IncludeRecord then begin
        end; // if (I = LogFileStrings.Count - 1) and
      finally
        LogFileStrings.Free;
      end;
      lblTime.Caption := DateTimeToStr(FirstTime);
      lblTime2.Caption := DateTimeToStr(LastTime);
      lblSum.Caption := CalcDuration(Summary);

      Caption := Format(JVCSRES_VCS_Time_Log_45_37s_45_37d_entries,
        [AnsiLowerCase(ExtractFileName(sProjectName)), lvTimeLog.Items.Count]);

      pnFilter.Caption := ' ';
      if UserFilter <> '' then
        pnFilter.Caption := pnFilter.Caption + UserFilter + ', '
      else
        pnFilter.Caption := pnFilter.Caption + JVCSRES_All_users + ', ';
      pnFilter.Caption := pnFilter.Caption + DateTimeToStr(Int(FirstTime)) +
        ' - ' + DateTimeToStr(Int(LastTime));
    finally
      lvTimeLog.Items.EndUpdate;
      Screen.Cursor := crDefault;
    end;
  end // if FileExists(TLGFileName) then begin
  else 
  begin
    if cbTimeLog.Checked then 
    begin
      MessageBox(WindowHandle, PChar(Format(JVCSRES_File_6037s62_not_found46 + #13#10 +
        JVCSRES_40This_is_normal_behavior_if_you_open_this_window_for_the_first_time4146, [TLGFileName])),
        cMsgBoxCaption, MB_OK or MB_ICONWARNING);
    end; // if cbTimeLog.Checked then begin
  end; // else if FileExists(TLGFileName) then begin
  btnCalc.Enabled := (lvTimeLog.Items.Count > 0);
end;

//------------------------------------------------------------------------------

procedure TVCSShowTimeLog.cbTimeLogClick(Sender: TObject);
begin
  if FCreating then 
    Exit;

  jvcsWriteBool(sBaseRegistryKey + crbTimeLog, ExtractFileName(sProjectName),
    cbTimeLog.Checked);

  if cbTimeLog.Checked then 
    WriteTimeLog( sConfigFolder + ChangeFileExt(ExtractFileName(sProjectName), '.tlg')
                , 'open;' + sCurrentUser + ';' + FloatToStr(Now)
                );
  if (not cbTimeLog.Checked) and
    FileExists( sConfigFolder + ChangeFileExt(ExtractFileName(sProjectName), '.tlg')) then
      WriteTimeLog( sConfigFolder + ChangeFileExt(ExtractFileName(sProjectName), '.tlg')
                  , 'close;' + sCurrentUser + ';' + FloatToStr(Now)
                  );
end;

//------------------------------------------------------------------------------

procedure TVCSShowTimeLog.btnCloseClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSShowTimeLog.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  jvcsWriteWindowPosAndSize(sBaseRegistryKey + crbWindows, 'ShowTimeLog',
    Top, Left, Width, Height);

  with lvTimeLog do
  begin
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ShowTimeLog_Col1.0',
      Columns[0].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ShowTimeLog_Col1.1',
      Columns[1].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ShowTimeLog_Col1.2',
      Columns[2].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ShowTimeLog_Col1.3',
      Columns[3].Width);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSShowTimeLog.spBtnClearClick(Sender: TObject);
begin
  if MessageBox(WindowHandle, PChar(JVCSRES_Are_you_sure_you_want_to_clear_the_time_log63 + #13#10 +
    JVCSRES_Warning33_This_process_is_not_reversible46), cMsgBoxCaption,
    MB_YESNOCANCEL or MB_DEFBUTTON2 or MB_ICONWARNING) <> idYes then 
    Exit;
  SysUtils.DeleteFile ( sConfigFolder + ChangeFileExt(ExtractFileName(sProjectName), '.tlg'));
  WriteTimeLog( sConfigFolder + ChangeFileExt(ExtractFileName(sProjectName), '.tlg')
              , 'open;' + sCurrentUser + ';' + FloatToStr(Now)
              );
end;

//------------------------------------------------------------------------------

function TVCSShowTimeLog.GetListViewString: string;
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
    with lvTimeLog do 
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

      Result := Result + Format(JVCSRES_Filter58_37s, [pnFilter.Caption]) + cr;

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

    CurrentText := GetSummaryDetails;
    for I := Length(CurrentText) downto 1 do
      if CurrentText[I] = #10 then
        System.Delete(CurrentText, I, 1);

    for I := Length(CurrentText) downto 1 do
      if CurrentText[I] = #13 then
      begin
        System.Delete(CurrentText, I, 1);
        System.Insert(cr, CurrentText, I);
      end;
    Result := Result + cr + CurrentText;

    Result := Result + cr + JVCSRES_Source58_ + sConfigFolder +
              ChangeFileExt(ExtractFileName(sProjectName), '.tlg') + cr;

    Result := Result + JVCSRES_JEDI_VCS_Report + ' ' + sProductVer + cProductInf + 
      DateTimeToStr(Now) + cr;
  finally
    Screen.Cursor := crDefault;
    SetLength(oaColumnsWidth, 0);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSShowTimeLog.RestrictSize(var Msg: TMessage);
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
  P.ptMinTrackSize.x := MulDiv(375, PixelsPerInch, 96);
  P.ptMinTrackSize.y := MulDiv(210, PixelsPerInch, 96);
end;

//------------------------------------------------------------------------------

procedure TVCSShowTimeLog.HelpTopics1Click(Sender: TObject);
begin
  PerformHelpCommand(Application, IDH_Time_Log);
end;

//------------------------------------------------------------------------------

procedure TVCSShowTimeLog.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    btnClose.Click;
    Key := 0;
  end;
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Time_Log);
end;

//------------------------------------------------------------------------------

procedure TVCSShowTimeLog.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSShowTimeLog.btnReportClick(Sender: TObject);
var 
  ResultString: string;
begin
  ResultString := GetListViewString;
  if ResultString = '' then 
    Exit;

  VCSSimpleReport := TVCSSimpleReport.Create(Application);
  try
    VCSSimpleReport.RepID := 13;  
    VCSSimpleReport.Left := Left + 60;
    VCSSimpleReport.Top := Top + 60;
    VCSSimpleReport.FullReportString := ResultString;
    VCSSimpleReport.SavePath := ExtractFileDir(sProjectName);
    VCSSimpleReport.SaveFileName := 'TimeLog.txt';
    VCSSimpleReport.LineCount := lvTimeLog.Items.Count + 8;
    VCSSimpleReport.ShowModal;
  finally
    VCSSimpleReport.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSShowTimeLog.btnFilterClick(Sender: TObject);
var 
  DlgResult: Boolean;
  I: Integer;
begin
  DlgResult := False;
  VCSTLFilter := TVCSTLFilter.Create(Application);
  try
    VCSTLFilter.Left := Left + 60;
    VCSTLFilter.Top := Top + 60;
    VCSTLFilter.StartFilterValue := DateStartFilter;
    VCSTLFilter.EndFilterValue := DateEndFilter;
    VCSTLFilter.UserFilterValue := UserFilter;
    for I := 0 to UserList.Count - 1 do
      VCSTLFilter.AddUser(UserList.Strings[I]);
    if VCSTLFilter.ShowModal = mrOk then 
    begin
      DlgResult := True;
      DateStartFilter := VCSTLFilter.StartFilterValue;
      DateEndFilter := VCSTLFilter.EndFilterValue;
      UserFilter := VCSTLFilter.UserFilterValue;
    end;
  finally
    VCSTLFilter.Free;
  end;
  if DlgResult then
    ReadTimeLog;
end;

//------------------------------------------------------------------------------

procedure TVCSShowTimeLog.FormDestroy(Sender: TObject);
begin
  UserList.Free;
end;

//------------------------------------------------------------------------------

function TVCSShowTimeLog.GetSummaryDetails: string;
var 
  Days, Hours: Integer;
begin
  // Summary = Tage
  Days := Round(Int(Summary));
  Hours := Round(Int(Summary * 24));

  if LocalIPAddr <> '' then
    Result := Format(JVCSRES_Project_6037s62_on_9137s9346,
      [AnsiLowerCase(ExtractFileName(sProjectName)), LocalIPAddr]) + #10#13
  else
    Result := Format(JVCSRES_Project_6037s62_on_9137s9346,
      [AnsiLowerCase(ExtractFileName(sProjectName)), sCurrentMachine]) + #10#13;
  Result := Result + Format(JVCSRES_Period_of_time58_37s_45_37s_4037d_days4146,
    [lblTime.Caption, lblTime2.Caption, Round(LastTime - FirstTime)])+ #10#13;

  if UserFilter <> '' then
    Result := Result + Format(JVCSRES_User58_37s46, [UserFilter]) + #10#13
  else
    Result := Result + Format(JVCSRES_Users58_37d46, [UserList.Count]) + #10#13;

  Result := Result + Format(JVCSRES_Project_time58_37d_d44_37s46, [Days,
    CalcDuration(Summary - Days)]) + #10#13;
  Result := Result + Format(JVCSRES_Average58_37s_h47d46,
    [FormatFloat('#.#', Hours / (LastTime - FirstTime))]) + #10#13;
  Result := Result + Format(JVCSRES_Working_days_408h47d4158_37s_d46_4037s_weeks4737s_years4146,
    [FormatFloat('#.#', Hours / 8), FormatFloat('#.#', Hours / 40),
    FormatFloat('#.#', Hours / 2080)]) + #10#13;
  //  Result := Result +
end;

//------------------------------------------------------------------------------

procedure TVCSShowTimeLog.MoreDetails1Click(Sender: TObject);
begin
  if lvTimeLog.Items.Count = 0 then 
    Exit;
  MessageBox(WindowHandle, PChar(GetSummaryDetails), cMsgBoxCaption, MB_OK or
    MB_ICONINFORMATION);
end;

//------------------------------------------------------------------------------

procedure TVCSShowTimeLog.btnCalcClick(Sender: TObject);
var 
  I: Integer;
  CurrDuration, Duration, Value: Double;
  InputStr: string;
  NewItem: TListItem;
begin
  InputStr :=
    jvcsReadString(sBaseRegistryKey + crbMRU, 'TimeLog_CostpHour', '');

  if InputQuery(JVCSRES_Calculate, JVCSRES_Enter_cost47hour58, InputStr) then
  begin
    Value := _StrToFloat(InputStr);
    if Value = 0 then 
    begin
      BeepIfSet;
      MessageBox(WindowHandle, PChar(JVCSRES_Float_62_0_expected46),
        cMsgBoxCaption, MB_OK or MB_ICONWARNING);
      Exit;
    end 
    else 
    begin
      jvcsReadString(sBaseRegistryKey + crbMRU, 'TimeLog_CostpHour', InputStr);

      Duration := 0;
      with lvTimeLog do
      begin
        I := 0;
        while I < Items.Count do
        begin
          if Items[I].Caption = '' then
            Items[I].Delete
          else
            Inc(I);
        end;

        for I := 0 to Items.Count - 1 do
        begin
          if Items[I].Caption <> '' then
          begin
            CurrDuration := TLVData(Items[I].Data^).Duration;
            Duration := Duration + CurrDuration;
            Items[I].SubItems[3] := Format('%f', [((CurrDuration * 24) * Value)]);
          end; // if Items[I].Caption <> '' then begin
        end; // for I := to Items.Count - 1 do begin
        NewItem := Items.Add;
        NewItem.Caption := '';
        NewItem.SubItems.Add('');
        NewItem.SubItems.Add('');
        NewItem.SubItems.Add('');
        NewItem.SubItems.Add('========');

        NewItem := Items.Add;
        NewItem.Caption := '';
        NewItem.SubItems.Add('');
        NewItem.SubItems.Add('');
        NewItem.SubItems.Add(Format(JVCSRES_Base_37f47h, [Value]));
        NewItem.SubItems.Add(Format('%f', [((Duration * 24) * Value)]));
      end; // with lvTimeLog do begin
    end;
  end; // if InputQuery('Calculate', 'Enter costs/hour:', InputStr) then begin
end;

procedure TVCSShowTimeLog.lvTimeLogDeletion(Sender: TObject;
  Item: TListItem);
begin
  if Assigned(Item.Data) then
    Dispose(Item.Data);
end;

end.
