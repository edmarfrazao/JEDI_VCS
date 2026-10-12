(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: ModuleInfo.pas

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
2003/02/12  USchuster - changed DSAMsg with JVCSDialogs in uses clause to use JvDSADialogs
2003/03/05  THensle   - changes for "ConfigStorage" unit
2003/03/15  THuber    - platformwarnings removed
2003/09/12  USchuster - fixed mantis #1124
                      - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes
2003/12/08  USchuster - modules checked out by you won't get the RO Flag (mantis #1220)
                      - line breaks are now kept on comment saving
                      - now with constant as messagebox caption
2003/12/27  THuber    - TimeConst now from JVCSClientConsts
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/26  USchuster - style cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/11/02  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
2005/03/17  USchuster - added "property" SelectedRevisionID -> now it's possible
                        to open the dialog with a desired revision (mantis #2769)
2005/03/28  USchuster - made it compatible with latest HandleBlob.pas
2005/04/11  CSchuette - mantis #2815
2007/06/17  USchuster - fixed self handled shortcuts
2007/06/30  USchuster - changes for large fonts (contraints and default size depend now on PixelsPerInch; analog to Mantis #3710)
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit ModuleInfo;

{$I jedi.inc}
{$I compopt.inc}

{$IFDEF DELPHI6_UP}
  {$WARN UNIT_PLATFORM OFF}
  {$WARN SYMBOL_PLATFORM OFF}
{$ENDIF DELPHI6_UP}

interface

uses
  {$IFDEF DEBUG}
  JclDebug,
  {$ENDIF DEBUG}
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, ImgList, Buttons, JVCSForms;

type
  TVCSInfo = class(TJVCSForm)
    lvRevValues: TListView;
    Splitter1: TSplitter;
    StateImageList: TImageList;
    Panel2: TPanel;
    rbChkInMemo: TRadioButton;
    rbChkOutMemo: TRadioButton;
    spBtnSave: TSpeedButton;
    spBtnChgKW: TSpeedButton;
    spBtnUndo: TSpeedButton;
    SysImageList: TImageList;
    Label1: TLabel;
    Panel3: TPanel;
    Panel1: TPanel;
    spBtnNextRev: TSpeedButton;
    spBtnPrevRev: TSpeedButton;
    Help: TSpeedButton;
    btnClose: TButton;
    btnGet: TButton;
    cbSelTargetFold: TCheckBox;
    Memo: TMemo;
    btnView: TButton;
    cbGetWriteable: TCheckBox;
    procedure rbChkInMemoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure MemoChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure spBtnPrevRevClick(Sender: TObject);
    procedure spBtnNextRevClick(Sender: TObject);
    procedure spBtnSaveClick(Sender: TObject);
    procedure spBtnChgKWClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnGetClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure spBtnUndoClick(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure btnViewClick(Sender: TObject);
    procedure cbGetWriteableClick(Sender: TObject);
  private
    { Private-Deklarationen }
    Comment_I,
    Comment_O,
    IntModuleName: string;
    RevisionID: Integer;
    RevisionKeysSet,
    FCreating: Boolean;
    RevisionKeys: TStringList;
    FIsCheckedOutByMe: Boolean;
    procedure ReadRevisionInfo;
    procedure EnableBrowse(Enable: Boolean);
    //    procedure LoadTheModule(const CurrentModule: String);
  public
    { Public-Deklarationen }
    ModuleID: Integer;
    ModuleName: string;
    GetEnabled: Boolean;
    SelectedRevisionID: Integer;
    procedure RestrictSize(var Msg: TMessage); message WM_GETMINMAXINFO;
  end;

var
  VCSInfo: TVCSInfo;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  ShellAPI, VCSProcBase, VCSBase, Checksum, JVCSDialogs, SelectFolder,
  HandleBlob, ApsCli, RFormat, DBModule, CommCtrl, AssignLabels, LoadModule,
  JVCSClientConsts, TZHandling, ConfigStorage, JVCSGUIClientResources,
  JVCSClientFunctions;

{$R *.dfm}

procedure TVCSInfo.FormCreate(Sender: TObject);
var
  sfi: TSHFileInfo;
  ToolTipHandle: HWND;
  DlgTop,
  DlgLeft,
  DlgWidth,
  DlgHeight: Integer;
begin
  try
    // ListView Tooltips
    SendMessage(lvRevValues.Handle, LVM_SETEXTENDEDLISTVIEWSTYLE, LVS_EX_INFOTIP,
      LVS_EX_INFOTIP);
    ToolTipHandle := SendMessage(lvRevValues.Handle, LVM_GETTOOLTIPS, 0, 0);
    SendMessage(ToolTipHandle, TTM_SETDELAYTIME, TTDT_AUTOMATIC, 1);
    SendMessage(ToolTipHandle, TTM_SETDELAYTIME, TTDT_AUTOPOP, 3000);

    FCreating := True;
    RevisionKeysSet := False;
    GetEnabled := False;
    RevisionKeys := TStringList.Create;

    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    if not jvcsReadWindowPosAndSize(sBaseRegistryKey + crbWindows, 'ModuleInfo',
      DlgTop, DlgLeft, DlgWidth, DlgHeight) then
    begin
      DlgTop := (Screen.Height - Height) div 2;
      DlgLeft := (Screen.Width - Width) div 2;
      DlgWidth := MulDiv(460, PixelsPerInch, 96);
      DlgHeight := MulDiv(240, PixelsPerInch, 96);
    end;
    Top := DlgTop;
    Left := DlgLeft;
    Width := DlgWidth;
    Height := DlgHeight;

    with lvRevValues do
    begin
      Columns[0].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ModuleInfo_Col1.0', 90);
      Columns[1].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ModuleInfo_Col1.1', 90);
      Columns[2].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ModuleInfo_Col1.2', 110);
      Columns[3].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ModuleInfo_Col1.3', 70);
      Columns[4].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ModuleInfo_Col1.4', 70);
      Columns[5].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ModuleInfo_Col1.5', 70);
      Height :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ModuleInfo_Pn1', 75);
    end;

    Panel3.Height :=
      jvcsReadInteger(sBaseRegistryKey + crbWindows, 'ModuleInfo_Pn2', 95);

    if not SettingIsGlobal(11) then
      cbGetWriteable.Checked :=
        jvcsReadBool(sBaseRegistryKey + crbWindows, 'ModuleInfo_GetWriteable', False)
    else
      cbGetWriteable.Checked := GlobalSettingValue(11);

    {$IFDEF CUSTOMDRIVE}
    sDriveSubst := RegReadString(HKCU, sBaseRegistryKey + crbProjects +
      ExtractFileName(sProjectName), 'LocalDrive', '');
    if (sDriveSubst = '') then
      sDriveSubst := RegReadString(HKCU, sBaseRegistryKey + crbOptions,
        'LocalDrive', '');
    {$ENDIF CUSTOMDRIVE}

    rbChkInMemo.Checked := True;
    ModuleID := 0;
    ModuleName := '';
    FIsCheckedOutByMe := False;
    SelectedRevisionID := 0;

    //Systemsymbole in eine TImageList-Komponente einlesen
    SysImageList.Handle := SHGetFileInfo('', 0, sfi, SizeOf(TSHFileInfo),
      SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
    SysImageList.ShareImages := True;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSInfo.FormActivate(Sender: TObject);
  //var Msg: String;
begin
  Application.ProcessMessages;
  if FCreating then 
  begin
    EnableBrowse(False);
    FCreating := False;
    spBtnSave.Visible := GetEnabled;
    spBtnUndo.Visible := GetEnabled;
    spBtnChgKW.Visible := GetEnabled;
    cbSelTargetFold.Visible := GetEnabled;
    btnGet.Visible := GetEnabled;
    if (ModuleID = 0) and (ModuleName = '') then 
      Exit;
    ReadRevisionInfo;
    EnableBrowse(True);
  end; // if FCreating then begin
end;

//------------------------------------------------------------------------------

procedure TVCSInfo.ReadRevisionInfo;
var 
  Size, CSize, RevisionIndex, Ratio: Integer;
  IsNewModule, FExists: Boolean;
  sfi: TSHFileInfo;
  LVItem: TListItem;
  CSizeStr: string;
begin
  // Module ID
  if ModuleID = 0 then
  begin
    ModuleName := AnsiLowerCase(ModuleName);
    with DataModule1 do
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_MODULE_ID';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [ModuleName]);
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
      IsNewModule := (AppSrvClient1.Answer.Fields[0] = '0');
      if not IsNewModule then
        ModuleID := _StrToInt(AppSrvClient1.Answer.Fields[0])
      else 
      begin
        // New module
        ShowMessage(Format(JVCSRES_Unknown_module58_37s, [ModuleName]));
        spBtnPrevRev.Enabled := False;
        spBtnNextRev.Enabled := False;
        btnGet.Enabled := False;
        Exit;
      end;
    end; // with DataModule1 do begin
  end; // if ModuleID = 0 then begin
  if ModuleID = 0 then
    Exit;
  // Revision list
  if not RevisionKeysSet then
  begin
    FIsCheckedOutByMe := False;
    RevisionKeys.Clear;
    with DataModule1 do
    begin
      //--- User modules -------------------------------------------------------
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_REVISION_LIST_BY_ID';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [ModuleID]);
      AppSrvClient1.Request.WriteFields(False, [ServerProjectID]);
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

      AppSrvClient1.Answer.First;
      if not AppSrvClient1.Answer.Eof then 
      begin
        IntModuleName := AppSrvClient1.Answer.Fields[2] +
          AppSrvClient1.Answer.Fields[1];
        {$IFDEF CUSTOMDRIVE}
        IntModuleName := ChangeDriveName(IntModuleName, sDriveSubst);
        {$ENDIF CUSTOMDRIVE}
      end; // if not AppSrvClient1.Answer.Eof then begin
      while not AppSrvClient1.Answer.Eof do
      begin
        RevisionKeys.Add(AppSrvClient1.Answer.Fields[6]);
        RevisionID := _StrToInt(AppSrvClient1.Answer.Fields[6]);
        FIsCheckedOutByMe := DecodeBoolStr(AppSrvClient1.Answer.Fields[3]) and
          (StrToIntDef(AppSrvClient1.Answer.Fields[5], 0) = ServerUserID);
        AppSrvClient1.Answer.Next;
      end; // while not AppSrvClient1.Answer.Eof do begin
    end; // with DataModule1 do begin}
    if SelectedRevisionID > 0 then
      RevisionID := SelectedRevisionID;
    RevisionKeysSet := True;
  end; // if not RevisionKeysSet then begin

  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_REVISION_STATUS';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [RevisionID]);
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

    lvRevValues.Items.BeginUpdate;
    try
      lvRevValues.Items.Clear;
      AppSrvClient1.Answer.First;
      Caption := Format(JVCSRES_Revisions_45_37s_40V_37s4637s41_, [ExtractFileName(IntModuleName),
        AppSrvClient1.Answer.Fields[4], AppSrvClient1.Answer.Fields[5]]);
      while not AppSrvClient1.Answer.Eof do 
      begin
        FExists := FileExists(ChangeFileExt(IntModuleName,
          TrimRight(AppSrvClient1.Answer.Fields[10])));
        LVItem := lvRevValues.Items.Add;
        // File
        if FExists then
          LVItem.Caption := ExtractFileName(GetOriginalFileName(ChangeFileExt(IntModuleName,
            TrimRight(AppSrvClient1.Answer.Fields[10]))))
        else
          LVItem.Caption := ChangeFileExt(ExtractFileName(IntModuleName),
            TrimRight(AppSrvClient1.Answer.Fields[10]));
        // FileIcon
        if FExists then 
        begin
          SHGetFileInfo(PChar(ChangeFileExt(IntModuleName,
            TrimRight(AppSrvClient1.Answer.Fields[10]))), 0, sfi, SizeOf(sfi),
            SHGFI_SYSICONINDEX or SHGFI_SMALLICON or SHGFI_DISPLAYNAME);
          LVItem.ImageIndex := sfi.IIcon;
        end 
        else 
          LVItem.ImageIndex := -1;
        // StateIcon
        if ExtractFileExt(IntModuleName) = TrimRight(AppSrvClient1.Answer.Fields[10]) then
          LVItem.StateIndex := 0 
        else 
          LVItem.StateIndex := -1;
        // Type
        if FExists then
        begin
          LVItem.SubItems.Add(GetFileType(ChangeFileExt(IntModuleName,
            TrimRight(AppSrvClient1.Answer.Fields[10]))));
        end 
        else 
          LVItem.SubItems.Add('NA');
        // TimeStamp
        LVItem.SubItems.Add(DateTimeToStr(GMTStr2LocalDateTime(AppSrvClient1.Answer.Fields[6])));
        // Size
        Size := _StrToInt(AppSrvClient1.Answer.Fields[7]);
        LVItem.SubItems.Add(FormatFloat('#,0', Size));
        // compr. size
        CSize := _StrToInt(AppSrvClient1.Answer.Fields[9]);
        CSizeStr := FormatFloat('#,0', CSize);
        if Size > 0 then
        begin
          Ratio := Round((1 - (CSize / Size)) * 100);
          CSizeStr := Format('%s (%s%%)', [CSizeStr, FormatFloat('#,0', Ratio)]);
        end;
        LVItem.SubItems.Add(CSizeStr);
        // CRC
        LVItem.SubItems.Add('$' +
          IntToHex(_StrToInt(AppSrvClient1.Answer.Fields[8]), 8));
        AppSrvClient1.Answer.Next;
      end; // while not AppSrvClient1.Answer.EoF do begin
    finally
      lvRevValues.Items.EndUpdate;
    end;

    //--- Comments -------------------------------------------------------------
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_REVISION_COMMENT';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [RevisionID]);
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

    AppSrvClient1.Answer.First;
    Comment_I := AppSrvClient1.Answer.Fields[0];
    if Comment_I = '' then
    begin
      rbChkInMemo.Font.Color := clWindowText;
      Comment_I := JVCSRES_45_blank_45;
    end
    else 
      rbChkInMemo.Font.Color := clNavy;
    Comment_O := AppSrvClient1.Answer.Fields[1];
    if Comment_O = '' then 
    begin
      rbChkOutMemo.Font.Color := clWindowText;
      Comment_O := JVCSRES_45_blank_45;
    end 
    else 
      rbChkOutMemo.Font.Color := clNavy;
    rbChkInMemoClick(Self);
  end; // with DataModule1 do begin

  RevisionIndex := RevisionKeys.IndexOf(IntToStr(RevisionID));
  {spBtnPrevRev.Enabled := RevisionIndex > 0;
  spBtnNextRev.Enabled := RevisionIndex < RevisionKeys.Count - 1; }
  if Pos('[', Caption) <> 0 then 
    Caption := Copy(Caption, 1, Pos('[', Caption) - 1);
  Caption := Caption + ' [' + IntToStr(RevisionIndex + 1) + '/' +
    IntToStr(RevisionKeys.Count) + ']';
  cbGetWriteable.Enabled := not FIsCheckedOutByMe;
end;

//------------------------------------------------------------------------------

procedure TVCSInfo.EnableBrowse(Enable: Boolean);
var
  RevisionIndex: Integer;
begin
  if Enable then
  begin
    RevisionIndex := RevisionKeys.IndexOf(IntToStr(RevisionID));
    spBtnPrevRev.Enabled := RevisionIndex > 0;
    spBtnNextRev.Enabled := RevisionIndex < RevisionKeys.Count - 1;
  end 
  else 
  begin
    spBtnPrevRev.Enabled := False;
    spBtnNextRev.Enabled := False;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSInfo.rbChkInMemoClick(Sender: TObject);
begin
  Memo.Lines.Clear;
  if rbChkInMemo.Checked then
    Memo.Lines.Add(Comment_I)
  else
    Memo.Lines.Add(Comment_O);
  spBtnSave.Enabled := False;
  spBtnUndo.Enabled := False;
end;

//------------------------------------------------------------------------------

procedure TVCSInfo.spBtnSaveClick(Sender: TObject);
var 
  NewMemo, CommentType: string;
//i: Integer;
begin
  if rbChkInMemo.Checked then
  begin
    CommentType := 'i';
{//USc 08.12.2003 we should keep the line breaks -> they are also kept in ChkIn/Out
    Comment_I := '';
    for i := 0 to Memo.Lines.Count - 1 do
      Comment_I := Comment_I + Memo.Lines[i];
}
    Comment_I := Memo.Lines.Text;
    NewMemo := Comment_I;
  end // if rbChkInMemo.Checked then begin
  else
  begin
    CommentType := 'o';
{//USc 08.12.2003 we should keep the line breaks -> they are also kept in ChkIn/Out
    Comment_O := '';
    for i := 0 to Memo.Lines.Count - 1 do
      Comment_O := Comment_O + Memo.Lines[i];
}      
    Comment_O := Memo.Lines.Text;
    NewMemo := Comment_O;
  end; // else if rbChkInMemo.Checked then begin
  with DataModule1 do 
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'CHANGE_REVISION_COMMENT';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [RevisionID]);
    AppSrvClient1.Request.WriteFields(False, [CommentType]);
    AppSrvClient1.Request.WriteFields(False, [NewMemo]);
    SetupTimeoutCounter;
    AppSrvClient1.Send;

    while WaitForAppSrvClient do 
      Application.ProcessMessages;
    if (AppSrvClientErr = -99) then 
    begin
      ShowServerTimeOut(WindowHandle);
    end;
    if (AppSrvClientErr <> 0) or
      (AppSrvClient1.AnswerStatus <> '200') then 
    begin
      ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
        AppSrvClient1.AnswerStatus);
    end;
  end; // with DataModule1 do begin}
  spBtnSave.Enabled := False;
  spBtnUndo.Enabled := False;
end;

//------------------------------------------------------------------------------

procedure TVCSInfo.MemoChange(Sender: TObject);
begin
  if GetEnabled then 
  begin
    spBtnSave.Enabled := True;
    spBtnUndo.Enabled := True;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSInfo.FormDestroy(Sender: TObject);
begin
  RevisionKeys.Free;
end;

//------------------------------------------------------------------------------

procedure TVCSInfo.spBtnPrevRevClick(Sender: TObject);
var 
  RevisionIndex: Integer;
begin
  EnableBrowse(False);
  RevisionIndex := RevisionKeys.IndexOf(IntToStr(RevisionID));
  if RevisionIndex > 0 then 
    Dec(RevisionIndex);
  RevisionID := StrToInt(RevisionKeys.Strings[RevisionIndex]);
  ReadRevisionInfo;
  EnableBrowse(True);  
end;

//------------------------------------------------------------------------------

procedure TVCSInfo.spBtnNextRevClick(Sender: TObject);
var
  RevisionIndex: Integer;
begin
  EnableBrowse(False);
  RevisionIndex := RevisionKeys.IndexOf(IntToStr(RevisionID));
  if RevisionIndex < RevisionKeys.Count - 1 then 
    Inc(RevisionIndex);
  RevisionID := StrToInt(RevisionKeys.Strings[RevisionIndex]);
  ReadRevisionInfo;
  EnableBrowse(True);  
end;

//------------------------------------------------------------------------------

procedure TVCSInfo.spBtnChgKWClick(Sender: TObject);
var 
  ModuleInfo: string;
begin
  ModuleInfo := Caption;
  while (ModuleInfo <> '') and (ModuleInfo[1] <> '(') do 
    Delete(ModuleInfo, 1, 1);
  ModuleInfo := Copy(ModuleInfo, 1, Pos(')', ModuleInfo));

  VCSAssignLabels := TVCSAssignLabels.Create(Application);
  try
    VCSAssignLabels.Left := Left + 40;
    VCSAssignLabels.Top := Top + 40;
    VCSAssignLabels.RevisionID := IntToStr(RevisionID);
    VCSAssignLabels.ModuleID := IntToStr(ModuleID);
    VCSAssignLabels.ModuleName := ExtractFileName(IntModuleName) + ModuleInfo;
    VCSAssignLabels.ShowModal;
  finally
    VCSAssignLabels.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSInfo.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  jvcsWriteWindowPosAndSize(sBaseRegistryKey + crbWindows, 'ModuleInfo',
    Top, Left, Width, Height);

  with lvRevValues do
  begin
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ModuleInfo_Col1.0',
      Columns[0].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ModuleInfo_Col1.1',
      Columns[1].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ModuleInfo_Col1.2',
      Columns[2].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ModuleInfo_Col1.3',
      Columns[3].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ModuleInfo_Col1.4',
      Columns[4].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ModuleInfo_Col1.5',
      Columns[5].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ModuleInfo_Pn1',
      Height);
  end;

  jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'ModuleInfo_Pn2',
    Panel3.Height);

  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'ModuleInfo_GetWriteable',
    cbGetWriteable.Checked);
end;

//------------------------------------------------------------------------------

procedure TVCSInfo.RestrictSize(var Msg: TMessage);
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
  P.ptMinTrackSize.x := MulDiv(464, PixelsPerInch, 96);
  P.ptMinTrackSize.y := MulDiv(240, PixelsPerInch, 96);
end;

//------------------------------------------------------------------------------

procedure TVCSInfo.btnGetClick(Sender: TObject);
var
  TargetDir, TargetFile, OldFile, OriginalPath, AffectedFiles, NotReadOnlyFilter, Mess, ErrMsg: string;
  TargetFDate: TDateTime;
  FuncRes: Integer;
  SetROFlag, SkipROCheck: Boolean;
begin
  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'GET_REVISION_STATUS';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    AppSrvClient1.Request.WriteFields(True, [RevisionID]);
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

    AppSrvClient1.Answer.First;
    if not AppSrvClient1.Answer.Eof then
    begin
      OriginalPath := AppSrvClient1.Answer.Fields[2];
    end;

    if cbSelTargetFold.Checked then
    begin
      VCSSelectFolder := TVCSSelectFolder.Create(Application);
      try
        VCSSelectFolder.SetStatusText(JVCSRES_38Target_folder58);
        VCSSelectFolder.EnableRecursive(False);
        VCSSelectFolder.HelpContextID := IDH_Get_version_history;
        VCSSelectFolder.SetInitialDir(OriginalPath);
        VCSSelectFolder.ShowModal;
        if VCSSelectFolder.Selection <> '' then
        begin
          TargetDir := AnsiLowerCase(VCSSelectFolder.Selection);
        end // if VCSSelectFolder.Selection <> '' then begin
        else 
          TargetDir := '';
      finally
        VCSSelectFolder.Free;
      end;
    end // if cbSelTargetFold.Checked then begin
    else 
      TargetDir := OriginalPath;
    if TargetDir = '' then 
      Exit;
    TargetDir := SetBackSlash(TargetDir);

    AppSrvClient1.Answer.First;
    while not AppSrvClient1.Answer.Eof do 
    begin
      OldFile := TargetDir + AppSrvClient1.Answer.Fields[1];
      OldFile := ChangeFileExt(OldFile, TrimRight(AppSrvClient1.Answer.Fields[10]));
      if FileExists(OldFile) then 
      begin
        TargetFDate := FileGetUTCDateTime(OldFile) - cTimeConvErr;
        {$IFDEF DEBUGMSG}
        ShowMessage('File: ' + ExtractFileName(OldFile) +
          ' - TargetFDate: ' + DateTimeToStr(TargetFDate) +
          ' - ArchiveFDate: ' +
          DateTimeToStr(_StrToFloat(AppSrvClient1.Answer.Fields[6])));
        {$ENDIF DEBUGMSG}
        if _StrToFloat(AppSrvClient1.Answer.Fields[6]) < TargetFDate then 
        begin
          if _StrToInt(AppSrvClient1.Answer.Fields[8]) <> CRCInt(OldFile, Mess) then 
          begin
            BeepIfSet;
            if MessageBox(WindowHandle, PChar(Format(JVCSRES_Module_6037s62_on_disk_has_a_newer_date_than_the_module_in_the_archive33 + #13#10 +
              JVCSRES_Are_you_sure_you_want_to_overwrite_all_changes_of_the_existing_file63,
              [ExtractFileName(OldFile)])), cMsgBoxCaption, MB_YESNOCANCEL or
              MB_DEFBUTTON2 or MB_ICONWARNING) <> idYes then 
              Exit;
          end;
          // if _StrToInt(AppSrvClient1.Answer.Fields[8]) <> CRCInt(OldFile, Mess) then begin
        end; // if FieldByName('FTIME').AsDateTime...
      end; // if FileExists(OldFile) then begin
      AppSrvClient1.Answer.Next;
    end; // while not AppSrvClient1.Answer.EoF do begin
  end; // with DataModule1 do begin

  TargetFile := TargetDir + ExtractFileName(IntModuleName);
  NotReadOnlyFilter :=
    jvcsReadString(sBaseRegistryKey + crbFilters, 'Writeable files', dfNotReadOnly);
  // readonly ?
  if cbGetWriteable.Checked or FIsCheckedOutByMe then
    SetROFlag := False
  else
    SetROFlag := not (MatchWithFilter(ExtractFileName(TargetFile), NotReadOnlyFilter));

  if FIsCheckedOutByMe then
    SkipROCheck := True
  else
  //??? GlobalSettings
  if not SettingIsGlobal(17) then
    SkipROCheck := jvcsReadBool(sBaseRegistryKey + crbOptions, 'NoROCheck', False)
  else
    SkipROCheck := GlobalSettingValue(17);
  //----------------------------------------------------------------------
  if (not SkipROCheck) and
    (not (MatchWithFilter(ExtractFileName(TargetFile), NotReadOnlyFilter))) and
    (not ((FileGetAttr(TargetFile) and faReadOnly) = faReadOnly)) then
  begin
    BeepIfSet;
    if MessageBox(WindowHandle, PChar(Format('%s <%s>.' + #13#10 +
      JVCSRES_JEDI_VCS_expects_the_local_file_to_be_37s44_but_the_file_is_37s46 + #13#10 +
      JVCSRES_Continue_anyway63, [JVCSRES_Get, TargetFile,
      JVCSRES_read45only, JVCSRES_writeable])), cMsgBoxCaption, MB_YESNOCANCEL or MB_DEFBUTTON2 or
      MB_ICONWARNING) <> idYes then
      Exit;
  end;
  //----------------------------------------------------------------------

  FuncRes := GetBlobs(DBModule.GetJvcsConnection, ServerProjectID, ServerUserID,
    ModuleID, RevisionID,
    False{CheckOut}, Application, Self,
    SetROFlag{SetReadOnly}, False{CloseIDEView},
    False{SetCurrentDate},
    TargetFile, ErrMsg, AffectedFiles);
  if FuncRes <> 0 then
  begin
    case FuncRes of
      1:
        Mess := JVCSRES_91CreateTargetDir93;
      2:
        Mess := JVCSRES_91AppSrvClient46Request93;
      3:
        Mess := JVCSRES_91GET95CHECKOUT95MODULE93;
      4:
        Mess := JVCSRES_91Get_compressed_size93;
      5:
        Mess := JVCSRES_91TFileStream_access93;
      6:
        Mess := JVCSRES_91Extract_zip_file93;
      7:
        Mess := JVCSRES_91Set_original_timestamp93;
      8:
        Mess := JVCSRES_91Replace_local_copy93;
      else
        Mess := JVCSRES_91Unknown93;
    end; // case FuncRes of
    BeepIfSet;
    MessageBox(WindowHandle,
      PChar(Format('<%s>' + #13#10 +
        JVCSRES_JEDI_VCS_is_unable_to_create_a_local_copy_of_this_file46 + #13#10 +
        JVCSRES_Exception58_37s_in_37s46_, [TargetFile, ErrMsg, Mess])),
      cMsgBoxCaption, MB_OK or MB_ICONSTOP);
    Exit;
  end // if FuncRes <> 0 then begin
  else
  begin
    if Length(AffectedFiles) > 1 then
      Delete(AffectedFiles, Length(AffectedFiles), 1);
    Mess := Format('<%s>' + #13#10 +
      JVCSRES_successfully_created46, [TargetFile]) + #10#13 +
      Format(JVCSRES_40Affected_files58_37s41, [AffectedFiles]);
    MessageBox(WindowHandle, PChar(Mess),
      cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSInfo.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if spBtnPrevRev.Enabled and (Shift * [ssShift, ssAlt, ssCtrl] = [ssCtrl]) and (Chr(Key) in ['P', 'p']) then
    if (not CtrlSCDisabled(WindowHandle)) then
      spBtnPrevRevClick(Self);
  if spBtnNextRev.Enabled and (Shift * [ssShift, ssAlt, ssCtrl] = [ssCtrl]) and (Chr(Key) in ['N', 'n']) then
    if (not CtrlSCDisabled(WindowHandle)) then
      spBtnNextRevClick(Self);
  if Key = VK_ESCAPE then
  begin
    btnClose.Click;
    Key := 0;
  end;
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Get_version_history);
end;

//------------------------------------------------------------------------------

procedure TVCSInfo.spBtnUndoClick(Sender: TObject);
begin
  Memo.Perform(EM_UNDO, 0, 0);
end;

//------------------------------------------------------------------------------

procedure TVCSInfo.HelpClick(Sender: TObject);
var
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSInfo.btnViewClick(Sender: TObject);
var
  I, FuncRes: Integer;
  TargetFile, AffectedFiles, TMPDirectory, ErrMsg, Mess: string;
begin
  // TMP - Verzeichnis ?
  TMPDirectory :=
    jvcsReadString(sBaseRegistryKey + crbOptions, 'TempDirectory', '');
  if TMPDirectory = '' then
  begin
    I := 255;
    SetLength(TMPDirectory, I);
    I := GetTempPath(I, PChar(TMPDirectory));
    if I = 0 then
    begin
      BeepIfSet;
      MessageBox(WindowHandle, PChar(JVCSRES_JEDI_VCS_cannot_detect_the_name_of_the_local_temporary_directory46 + #13#10 +
        JVCSRES_Try_to_define_a_temporary_directory_in_34Properties124Folders34_and_retry46), cMsgBoxCaption,
        MB_OK or MB_ICONWARNING);
      Exit;
    end;
    SetLength(TMPDirectory, StrLen(PChar(TMPDirectory)));
  end; // if TMPDirectory = '' then begin

  TargetFile := TMPDirectory + ExtractFileName(IntModuleName);

  if FileExists(TargetFile) then
  begin
    UseRegistry := True;
    DontShowMsgText := JVCSRES_38Delete_without_prompting_from_now_on46;

    if DSAIdentsMessageDlg(Format(JVCSRES_There_is_already_a_file_6037s62_in + #13#10 +
      '<%s>.' + #13#10 +
      JVCSRES_Delete_the_file_to_show_the_latest_archive_version_of_6037s6263
      , [ExtractFileName(TargetFile)
      , TMPDirectory
      , ExtractFileName(TargetFile)]
      )
      , mtConfirmation
      , [mbYes, mbNo, mbCancel]
      , 0
      , sBaseRegistryKey + crbMRU + 'Dlgs'
      , 'DeleteViewLatest'
      , idYes) <> idYes then 
      Exit 
    else 
    begin
      FileSetAttr(TargetFile, FileGetAttr(TargetFile) and not $00000001);
      SysUtils.DeleteFile(TargetFile);
    end;
  end; // if FileExists(TargetFile) then begin

  FuncRes := GetBlobs(DBModule.GetJvcsConnection, ServerProjectID, ServerUserID,
    ModuleID, RevisionID,
    False{CheckOut}, Application, Self,
    True{SetReadOnly},
    False{CloseIDEView},
    False{SetCurrentDate},
    TargetFile, ErrMsg, AffectedFiles);
  if FuncRes <> 0 then 
  begin
    case FuncRes of
      1:
        Mess := JVCSRES_91CreateTargetDir93;
      2: 
        Mess := JVCSRES_91AppSrvClient46Request93;
      3: 
        Mess := JVCSRES_91GET95CHECKOUT95MODULE93;
      4: 
        Mess := JVCSRES_91Get_compressed_size93;
      5: 
        Mess := JVCSRES_91TFileStream_access93;
      6: 
        Mess := JVCSRES_91Extract_zip_file93;
      7: 
        Mess := JVCSRES_91Set_original_timestamp93;
      8: 
        Mess := JVCSRES_91Replace_local_copy93;
      else 
        Mess := JVCSRES_91Unknown93;
    end; // case FuncRes of
    BeepIfSet;
    MessageBox(WindowHandle,
      PChar(Format('<%s>' + #13#10 +
      JVCSRES_JEDI_VCS_is_unable_to_create_a_local_copy_of_this_file46 + #13#10 +
      JVCSRES_Exception58_37s_in_37s46_, [TargetFile, ErrMsg, Mess])),
      cMsgBoxCaption, MB_OK or MB_ICONSTOP);
    Exit;
  end // if FuncRes <> 0 then begin
  else {LoadTheModule(TMPDirectory + ExtractFileName(IntModuleName));}
    ViewTheModule(WindowHandle, TMPDirectory + ExtractFileName(IntModuleName),
      Mess);
end;

//------------------------------------------------------------------------------

procedure TVCSInfo.cbGetWriteableClick(Sender: TObject);
begin
  if SettingIsGlobal(11) and (cbGetWriteable.Checked <> GlobalSettingValue(11)) then 
  begin
    ShowGlobalSettingsWarning(WindowHandle, GlobalSettingValue(11));
    cbGetWriteable.Checked := GlobalSettingValue(11);
    Exit;
  end;
  if (not FCreating) and cbGetWriteable.Checked then
  begin
    UseRegistry := True;
    DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;

    if DSAIdentsMessageDlg(Format(JVCSRES_This_is_a_potentially_dangerous_option_and_only_recommended_for + #13#10 +
      JVCSRES_experienced_users46_Inproper_use_may_cause_data_loss33 + #13#10 +
      JVCSRES_Please_read_the_related_help_topic_before_enabling_this_option46 + #13#10 +
      JVCSRES_Enable_3437s34_anyway63_
      , [JVCSRES_Get_writeable]
      )
      , mtWarning
      , [mbYes, mbNo, mbCancel]
      , 0
      , sBaseRegistryKey + crbMRU + 'Dlgs'
      , 'GetWriteable'
      , idYes) <> idYes then
      cbGetWriteable.Checked := False;
  end; // if cbGetWriteable.Checked
end;

end.
