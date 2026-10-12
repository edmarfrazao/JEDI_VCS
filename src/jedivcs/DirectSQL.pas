(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: DirectSQL.pas

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
2003/03/08  USchuster - exchanged THistoryList with TJVCSMruList (mantis #727)
2003/03/15  THuber    - compilerhints removed
2003/08/02  THuber    - mantis #861: replaced TMemo with TJvMemo
                      - FormStorage changed in configStorage
2003/12/28  USchuster - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use constant)
2004/02/24  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/31  USchuster - style cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/11/05  USchuster - moved resourcestrings to JVCSGUIClientResources.pas                      
2005/06/04  USchuster - set memo charset to DEFAULT_CHARSET(necessary for LANGUAGE version)
2007/06/17  USchuster - fixed self handled shortcuts
2007/06/30  USchuster - changes for large fonts (contraints size depend now on PixelsPerInch; analog to Mantis #3710)
2011/01/15  USchuster - changed font to Tahoma                       

-----------------------------------------------------------------------------*)

unit DirectSQL;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  JvSpin, StdCtrls, ExtCtrls, JVCSMruList, Buttons, Mask, JvMaskEdit,
  JvEdit, JvMemo, JvExStdCtrls, JvExMask;

type
  TVCSDirectSQL = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    SQLMemo: TJvMemo;
    btnClose: TButton;
    btnExecSQL: TButton;
    btnOpenSQL: TButton;
    Label1: TLabel;
    Label2: TLabel;
    speMaxRows: TJvSpinEdit;
    Label3: TLabel;
    Image2: TImage;
    spBtnPrevSQL: TSpeedButton;
    spBtnNextSQL: TSpeedButton;
    spBtnSaveSQL: TSpeedButton;
    spBtnLoadSQL: TSpeedButton;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnOpenSQLClick(Sender: TObject);
    procedure btnExecSQLClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure SQLMemoChange(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure spBtnPrevSQLClick(Sender: TObject);
    procedure spBtnNextSQLClick(Sender: TObject);
    procedure spBtnSaveSQLClick(Sender: TObject);
    procedure spBtnLoadSQLClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    SQLHistory: TJVCSMruList;
    SQLHistoryIndex: Integer;
    procedure DoSQL(const Exec: Boolean);
    procedure SetupMRUButtons;
  public
    { Public declarations }
  end;

var
  VCSDirectSQL: TVCSDirectSQL;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  DBModule, Std_ListView, VCSBase, VCSProcBase, ConfigStorage, JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSDirectSQL.FormCreate(Sender: TObject);
//thu 03.08.2003
{ 
var
  DlgTop,
  DlgLeft,
  DlgWidth,
  DlgHeight: Integer;
 }
begin
  try
    Constraints.MinHeight := MulDiv(240, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(500, PixelsPerInch, 96);
    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    //thu 03.08.2003
    { 
    if not jvcsReadWindowPosAndSize(sBaseRegistryKey + crbWindows, 'DirectSQL',
      DlgTop, DlgLeft, DlgWidth, DlgHeight) then
    begin
      DlgTop := (Screen.Height - Height) div 2;
      DlgLeft := (Screen.Width - Width) div 2;
      DlgWidth := 500;
      DlgHeight := 240;
    end;
    Top := DlgTop;
    Left := DlgLeft;
    Width := DlgWidth;
    Height := DlgHeight;
     }

    SQLHistory := TJVCSMruList.Create;
    SQLHistory.MaxSize := 20;
    SQLHistory.CaseSensitive := False;
    SQLHistory.LoadFromStorage(sBaseRegistryKey + crbMRU + 'SQL');
    SQLHistoryIndex := -1;
    SetupMRUButtons;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSDirectSQL.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  //thu 03.08.2003
  { 
  jvcsWriteWindowPosAndSize(sBaseRegistryKey + crbWindows, 'DirectSQL',
    Top, Left, Width, Height);
   }
  jvcsSaveFormPosSize(Self);

  SQLHistory.SaveToStorage(sBaseRegistryKey + crbMRU + 'SQL');
end;

//------------------------------------------------------------------------------

procedure TVCSDirectSQL.DoSQL(const Exec: Boolean);
var 
  I, J: Integer;
  SQLString, CurrentField, FldBuffer, ResultString: string;
  ResultFieldNames: TStringList;
begin
  SQLHistoryIndex := -1;
  SQLString := '';
  for I := 0 to SQLMemo.Lines.Count - 1 do 
  begin
    SQLString := SQLString + SQLMemo.Lines[I] + #10;
  end;

  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'EXECUTE_SQL';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [SQLString]);
    AppSrvClient1.Request.WriteFields(False, [Exec]);
    AppSrvClient1.Request.WriteFields(False, [speMaxRows.Value - 1]);
    SetupTimeoutCounter;
    AppSrvClient1.Send;

    while WaitForAppSrvClient do 
      Application.ProcessMessages;
    if (AppSrvClientErr = -99) then 
    begin
      ShowServerTimeOut(WindowHandle);
      Exit;
    end;    
    if (AppSrvClientErr <> 0) or
      (AppSrvClient1.AnswerStatus <> '200') then 
    begin
      ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
        AppSrvClient1.AnswerStatus);
      Exit;
    end;

    SQLHistory.AddString(SQLString);
    SQLHistoryIndex := -1;
    SetupMRUButtons;

    AppSrvClient1.Answer.First;
    ResultString := '';
    if AppSrvClient1.Answer.Eof then
    begin
      MessageBox(Handle, PChar(JVCSRES_Result_set_is_blank46), cMsgBoxCaption,
        MB_OK or MB_ICONINFORMATION);
      Exit;
    end; // if AppSrvClient1.Answer.EoF then begin

    //THu no use: ColumnCount := AppSrvClient1.Answer.FieldCount;
    ResultFieldNames := TStringList.Create;
    try
      Screen.Cursor := crHourGlass;
      for I := 0 to AppSrvClient1.Answer.FieldCount - 1 do
        ResultFieldNames.Add(AppSrvClient1.Answer.Fields[I]);

      if not AppSrvClient1.Answer.Eof then
        AppSrvClient1.Answer.Next;
      while not AppSrvClient1.Answer.Eof do 
      begin
        for I := 0 to AppSrvClient1.Answer.FieldCount - 1 do 
        begin
          CurrentField := AppSrvClient1.Answer.Fields[I];
          J := Pos(';', CurrentField);
          if J > 0 then 
          begin
            FldBuffer := Copy(CurrentField, 1, J - 1);
            System.Delete(CurrentField, 1, J);
            CurrentField := CurrentField + '.' + FldBuffer;
          end;
          ResultString := ResultString + CurrentField + ';';
        end;
        ResultString := ResultString + '|';
        AppSrvClient1.Answer.Next;
      end;
      Screen.Cursor := crDefault;
      VCSStdListView := TVCSStdListView.Create(Application);
      try
        VCSStdListView.LVRepID := 2;
        VCSStdListView.Caption := JVCSRES_SQL_result;
        VCSStdListView.Left := Left + 60;
        VCSStdListView.Top := Top + 60;
        VCSStdListView.LVType := 0;
        VCSStdListView.HelpContextID := 0;
        for I := 0 to ResultFieldNames.Count - 1 do
          VCSStdListView.AddListColumn(ResultFieldNames.Strings[I], False);
        VCSStdListView.SetUpItems(ResultString);
        VCSStdListView.ShowModal;
      finally
        VCSStdListView.Free;
      end;
    finally
      ResultFieldNames.Free;
    end;
  end; // with DataModule1 do begin
end;

//------------------------------------------------------------------------------

procedure TVCSDirectSQL.btnOpenSQLClick(Sender: TObject);
begin
  DoSQL(False);
end;

//------------------------------------------------------------------------------

procedure TVCSDirectSQL.btnExecSQLClick(Sender: TObject);
begin
  DoSQL(True);
end;

//------------------------------------------------------------------------------

procedure TVCSDirectSQL.btnCloseClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSDirectSQL.SQLMemoChange(Sender: TObject);
begin
  btnOpenSQL.Enabled := (SQLMemo.Lines.Count > 0);
  btnExecSQL.Enabled := btnOpenSQL.Enabled;
  spBtnSaveSQL.Enabled := btnOpenSQL.Enabled;
end;

//------------------------------------------------------------------------------

procedure TVCSDirectSQL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Close;
    Key := 0;
  end;
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Direct_SQL);
  if spBtnNextSQL.Enabled and (Shift * [ssShift, ssAlt, ssCtrl] = [ssCtrl]) and (Chr(Key) in ['N', 'n']) then
    if (not CtrlSCDisabled(WindowHandle)) then
      spBtnNextSQLClick(Self);
  if spBtnPrevSQL.Enabled and (Shift * [ssShift, ssAlt, ssCtrl] = [ssCtrl]) and (Chr(Key) in ['P', 'p']) then
    if (not CtrlSCDisabled(WindowHandle)) then
      spBtnPrevSQLClick(Self);
  if spBtnSaveSQL.Enabled and (Shift * [ssShift, ssAlt, ssCtrl] = [ssCtrl]) and (Chr(Key) in ['S', 's']) then
    if (not CtrlSCDisabled(WindowHandle)) then 
      spBtnSaveSQLClick(Self);
end;

//------------------------------------------------------------------------------

procedure TVCSDirectSQL.FormDestroy(Sender: TObject);
begin
  SQLHistory.Free;
end;

//------------------------------------------------------------------------------

procedure TVCSDirectSQL.SetupMRUButtons;
begin
  spBtnNextSQL.Enabled := (SQLHistoryIndex > 0);
  spBtnPrevSQL.Enabled := (SQLHistoryIndex < (SQLHistory.Count - 1));
end;

procedure TVCSDirectSQL.spBtnNextSQLClick(Sender: TObject);
begin
  if SQLHistoryIndex > 0 then 
  begin
    Dec(SQLHistoryIndex);
    SQLMemo.Lines.Clear;
    SQLMemo.Lines.SetText(PChar(SQLHistory.Strings[SQLHistoryIndex]));
  end;
  SetupMRUButtons;
end;

procedure TVCSDirectSQL.spBtnPrevSQLClick(Sender: TObject);
begin
  if (SQLHistoryIndex < (SQLHistory.Count - 1)) then 
  begin
    Inc(SQLHistoryIndex);
    SQLMemo.Lines.Clear;
    SQLMemo.Lines.SetText(PChar(SQLHistory.Strings[SQLHistoryIndex]));
  end;
  SetupMRUButtons;
end;

//------------------------------------------------------------------------------

procedure TVCSDirectSQL.spBtnLoadSQLClick(Sender: TObject);
begin
  with OpenDialog1 do 
  begin
    Title := JVCSRES_Open_SQL_query;
    Filter := JVCSRES_SQL_files_404246sql594246txt411244246sql594246txt124All_files_4042464241124424642;
    InitialDir := GetCurrentDir;
    if not Execute then 
      Exit;
    SQLMemo.Lines.Clear;
    SQLMemo.Lines.LoadFromFile(FileName);
  end;
end;

procedure TVCSDirectSQL.spBtnSaveSQLClick(Sender: TObject);
begin
  with SaveDialog1 do 
  begin
    Title := JVCSRES_Save_SQL_query;  
    Filter := JVCSRES_SQL_files_404246sql594246txt411244246sql594246txt124All_files_4042464241124424642;
    DefaultExt := 'sql';
    InitialDir := GetCurrentDir;
    if not Execute then 
      Exit;
    SQLMemo.Lines.Clear;
    SQLMemo.Lines.SaveToFile(FileName);
  end;
end;

procedure TVCSDirectSQL.FormShow(Sender: TObject);
begin
  jvcsLoadFormPosSize(Self);
end;

end.
