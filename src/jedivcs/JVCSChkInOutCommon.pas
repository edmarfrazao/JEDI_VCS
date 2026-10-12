(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSChkInOutCommon.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2005/05/22  USchuster - new unit for mantis #2713 to avoid double code
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC3 was released ^^^^^^^^^^^^^^^^^^^^^^^^^^^
2005/12/30  USchuster - added function UndoCheckout for mantis #3381
                        (a generic version of TVCSProjAdmin.acUndoChkOutExecute)  

-----------------------------------------------------------------------------*)

unit JVCSChkInOutCommon;

{$I jedi.inc}
{$I compopt.inc}

{$IFDEF DELPHI6_UP}
  {$WARN UNIT_PLATFORM OFF}
  {$WARN SYMBOL_PLATFORM OFF}
{$ENDIF DELPHI6_UP}

interface

uses
  Windows, SysUtils, Classes, StdCtrls, JVCSMruList, Menus, Forms, Controls,
  Dialogs, Contnrs;

type
  TLastCommentHandler = class(TComponent)
  private
    FMemo: TCustomMemo;
    FMruList: TJVCSMruList;
    FPopupMenu: TPopupMenu;
    procedure DoSetText(const AValue: string);
    procedure HandlePopupMenuOnClick(Sender: TObject);
    procedure HandlePopupMenuOnPopup(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    constructor CreateEx(AOwner: TComponent; const ASubKey: string; AMemo: TCustomMemo);
    destructor Destroy; override;
    procedure AddString(const AValue: string);
    property Memo: TCustomMemo read FMemo write FMemo;
    property PopupMenu: TPopupMenu read FPopupMenu;
  end;

  TUndoCheckOutModule = class(TObject)
  private
    FName: string;
    FPath: string;
    FProjectID: Integer;
    FModuleID: Integer;
    FRevisionID: Integer;
    FOwnerName: string;
  public
    constructor Create;
    property Name: string read FName write FName;
    property Path: string read FPath write FPath;
    property ProjectID: Integer read FProjectID write FProjectID;
    property ModuleID: Integer read FModuleID write FModuleID;
    property RevisionID: Integer read FRevisionID write FRevisionID;
    property OwnerName: string read FOwnerName write FOwnerName;
  end;

  TUndoCheckOutModuleList = class(TObject)
  private
    FItems: TObjectList;
    function GetCount: Integer;
    function GetItems(AIndex: Integer): TUndoCheckOutModule;
  public
    constructor Create;
    destructor Destroy; override;

    function Add: TUndoCheckOutModule;

    property Count: Integer read GetCount;
    property Items[AIndex: Integer]: TUndoCheckOutModule read GetItems; default;
  end;

procedure UndoCheckout(AModuleList: TUndoCheckOutModuleList; AUserIsArchiveAdmin: Boolean;
  var AStopRefresh: Boolean; AWindowHandle: HWND = 0);

implementation

uses
  VCSBase, JclStrings, JVCSGUIClientResources, Yes2allDlg, VCSProcBase,
  ConfigStorage, DBModule, JVCSClientFunctions, JVCSClientConsts, Checksum,
  HandleBlob, JVCSDialogs;

constructor TLastCommentHandler.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPopupMenu := TPopupMenu.Create(Self);
  FPopupMenu.OnPopup := HandlePopupMenuOnPopup;
  FMruList := nil;
end;

constructor TLastCommentHandler.CreateEx(AOwner: TComponent; const ASubKey: string; AMemo: TCustomMemo);
begin
  Create(AOwner);
  FMruList := TJVCSMruList.CreateEx(sBaseRegistryKey + crbMRU + ASubKey, True, True, True, 10);
  FMemo := AMemo;
end;

destructor TLastCommentHandler.Destroy;
begin
  FMruList.Free;
  inherited Destroy;
end;

procedure TLastCommentHandler.AddString(const AValue: string);
begin
  if Assigned(FMruList) then
    FMruList.AddString(AValue);
end;

procedure TLastCommentHandler.DoSetText(const AValue: string);
begin
  if Assigned(FMemo) then
  begin
    FMemo.Text := AValue;
    FMemo.SetFocus;
    FMemo.SelStart := Length(FMemo.Text);
  end;
end;

procedure TLastCommentHandler.HandlePopupMenuOnClick(Sender: TObject);
var
  Idx: Integer;
begin
  if Sender is TComponent then
  begin
    Idx := TComponent(Sender).Tag;
    if (FMruList.Count > Idx) then
      DoSetText(FMruList[Idx]);
  end;
end;

procedure TLastCommentHandler.HandlePopupMenuOnPopup(Sender: TObject);
var
  I: Integer;
  MItem: TMenuItem;
  S: string;
begin
  while FPopupMenu.Items.Count > 0 do
    FPopupMenu.Items[0].Free;
  if (not Assigned(FMruList)) or (FMruList.Count = 0) then
  begin
    MItem := TMenuItem.Create(Self);
    MItem.Caption := JVCSRES_60empty62;
    MItem.OnClick := nil;
    MItem.Tag := -1;
    FPopupMenu.Items.Add(MItem);
  end
  else
  begin
    for I := 0 to Pred(FMruList.Count) do
    begin
      MItem := TMenuItem.Create(Self);
      S := FMruList[I];
      if Length(S) > 30 then
        S := Copy(S, 1, 20) + Format(JVCSRES_464646404337d_chars41, [Length(S) - 20]);
      if Pos(#13#10, S) > 0 then
        StrReplace(S, #13#10, ' \n ');// or <br> ?
      MItem.Caption := S;
      MItem.OnClick := HandlePopupMenuOnClick;
      MItem.Tag := I;
      FPopupMenu.Items.Add(MItem);
    end;
  end;
end;

constructor TUndoCheckOutModule.Create;
begin
  inherited Create;
  FName := '';
  FPath := '';
  FProjectID := -1;
  FModuleID := -1;
  FRevisionID := -1;
  FOwnerName := '';
end;

constructor TUndoCheckOutModuleList.Create;
begin
  inherited Create;
  FItems := TObjectList.Create;
end;

destructor TUndoCheckOutModuleList.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

function TUndoCheckOutModuleList.Add: TUndoCheckOutModule;
begin
  FItems.Add(TUndoCheckOutModule.Create);
  Result := TUndoCheckOutModule(FItems.Last);
end;

function TUndoCheckOutModuleList.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TUndoCheckOutModuleList.GetItems(AIndex: Integer): TUndoCheckOutModule;
begin
  Result := TUndoCheckOutModule(FItems[AIndex]);
end;

procedure UndoCheckout(AModuleList: TUndoCheckOutModuleList; AUserIsArchiveAdmin: Boolean;
  var AStopRefresh: Boolean; AWindowHandle: HWND = 0);
var
  Msg: string;
  Module, ModuleID, TargetFile, OldFile, OriginalPath, AffectedFiles, NotReadOnlyFilter, Mess, ErrMsg: string;
  TargetFDate: TDateTime;
  I, mbIcon, FuncRes, Yes2allRes: Integer;
  CloseIDEView, SetROFlag, SkipROCheck, Yes2AllUndo, Yes2AllRestore: Boolean;
label
  NextModule;
begin
  Yes2AllUndo := False;
  Yes2AllRestore := False;
  for I := 0 to AModuleList.Count - 1 do
  begin
    if not Yes2AllUndo then
    begin
      VCSYes2AllDlg := TVCSYes2AllDlg.Create(Application);
      try
        VCSYes2AllDlg.SetMessageText(Format(JVCSRES_Are_you_sure_you_want_to_cancel_your_work_on
          + #13#10 + JVCSRES_6037s62_and_unlock_the_module63,
          [AModuleList[I].Name]));
        VCSYes2AllDlg.EnableYes2All(True);
        VCSYes2AllDlg.ShowCheckBox(False);
        VCSYes2AllDlg.SetCheckBoxCaption('');
        Yes2allRes := VCSYes2AllDlg.ShowModal;
      finally
        VCSYes2AllDlg.Free;
      end;
      case Yes2allRes of
        mrYes :;
        mrAll:
          Yes2AllUndo := True;
        mrNo: 
          Continue;
        mrCancel: 
          Break;
      end; // case Yes2allRes of
    end; // if not Yes2all then begin

    if AUserIsArchiveAdmin and (AModuleList[I].OwnerName <> sCurrentUser) then
    begin
      BeepIfSet;
      if MessageBox(AWindowHandle, PChar(Format('<%s>' + #13#10 +
        JVCSRES_This_module_is_locked_by_another_user46 + #13#10 +
        JVCSRES_Use_your_administrator_right_to_unlock_anyway63 + #13#10 +
        JVCSRES_Warning33_All_changes_to_this_file_will_be_lost46,
        [AModuleList[I].Name])), cMsgBoxCaption,
        MB_YESNOCANCEL or MB_DEFBUTTON2 or MB_ICONWARNING) <> idYes then 
        Exit;
    end; // if ArchiveAdmin and...
    NotReadOnlyFilter :=
      jvcsReadString(sBaseRegistryKey + crbFilters, 'Writeable files', dfNotReadOnly);
  // readonly ?
    //??? GlobalSettings
    if not SettingIsGlobal(17) then
      SkipROCheck := jvcsReadBool(sBaseRegistryKey + crbOptions, 'NoROCheck', False)
    else
      SkipROCheck := GlobalSettingValue(17);

    if (not SkipROCheck) and
      ((FileGetAttr(AModuleList[I].Path + AModuleList[I].Name) and faReadOnly) = faReadOnly) then
    begin
      BeepIfSet;
      case MessageBox(AWindowHandle, PChar(Format('%s <%s>.' + #13#10 +
        JVCSRES_JEDI_VCS_expects_the_local_file_to_be_37s44_but_the_file_is_37s46 + #13#10 +
        JVCSRES_Continue_anyway63, [JVCSRES_Undo_Check_Out,
        AModuleList[I].Path + AModuleList[I].Name,
        JVCSRES_writeable, JVCSRES_read45only])), cMsgBoxCaption,
        MB_YESNOCANCEL or MB_DEFBUTTON2 or MB_ICONWARNING) of
        idYes :;
        idNo: 
          Continue;
        else 
          Break;
      end; // case
    end; // if (not SkipROCheck) and

    AStopRefresh := True;
    with DataModule1 do 
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'UNDO_CHECKOUT_MODULE';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [AModuleList[I].ProjectID]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(False,
        [AModuleList[I].ModuleID]);
      AppSrvClient1.Request.WriteFields(False, [LowerCase(AModuleList[I].Name)]);
      SetupTimeoutCounter;
      AppSrvClient1.Send;

      while WaitForAppSrvClient do 
        Application.ProcessMessages;
      if (AppSrvClientErr = -99) then 
      begin
        ShowServerTimeOut(AWindowHandle);
        AStopRefresh := False;
        Exit;
      end;
      if (AppSrvClientErr <> 0) or
        (AppSrvClient1.AnswerStatus <> '200') then 
      begin
        ShowServerError(AWindowHandle, AppSrvClient1.Answer.Fields[0],
          AppSrvClient1.AnswerStatus);
        AStopRefresh := False;
        Exit;
      end;

      AppSrvClient1.Answer.First;
      if not AppSrvClient1.Answer.Eof then 
      begin
        if not DecodeBoolStr(AppSrvClient1.Answer.Fields[0]) then 
        begin
          Msg := '<' + AModuleList[I].Name + '>' + #10#13;
          if AppSrvClient1.Answer.Fields[1] <> '' then
          begin
            Msg := Msg + Format(JVCSRES_Module_is_checked_out_by_37s, [AppSrvClient1.Answer.Fields[1]]);
            mbIcon := MB_ICONWARNING;
            BeepIfSet;
          end 
          else 
          begin
            Msg := Msg + JVCSRES_Nothing_to_do46;
            mbIcon := MB_ICONINFORMATION;
          end;
          Msg := Msg + #10#13 + AppSrvClient1.Answer.Fields[2];
          MessageBox(AWindowHandle, PChar(Msg), cMsgBoxCaption, MB_OK or mbIcon);
          Continue;
        end; // if not DecodeBollStr(AppSrvClient1.Answer.Fields[0]) then begin
      end; // if not AppSrvClient1.Answer.EoF do begin

      if not Yes2AllRestore then 
      begin
        VCSYes2AllDlg := TVCSYes2AllDlg.Create(Application);
        try
          VCSYes2AllDlg.SetMessageText(Format('<%s>' + #13#10 +
            JVCSRES_Undo_Checkout_success46_Module_unlocked46 + #13#10 +
            JVCSRES_Restore_original_file_state_on_local_disk63,
            [AModuleList[I].Name]));
          VCSYes2AllDlg.EnableYes2All(True);
          VCSYes2AllDlg.ShowCheckBox(False);
          VCSYes2AllDlg.SetCheckBoxCaption('');
          Yes2allRes := VCSYes2AllDlg.ShowModal;
        finally
          VCSYes2AllDlg.Free;
        end;
        case Yes2allRes of
          mrYes :;
          mrAll: 
            Yes2AllRestore := True;
          mrNo: 
            Continue;
          mrCancel :
            Break;
        end; // case Yes2allRes of
      end; // if not Yes2AllRestore then begin

      // Restore (Get)
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_REVISION_STATUS';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True,
        [AModuleList[I].RevisionID]);
      SetupTimeoutCounter;
      AppSrvClient1.Send;

      while WaitForAppSrvClient do 
        Application.ProcessMessages;
      if (AppSrvClientErr = -99) then
      begin
        ShowServerTimeOut(AWindowHandle);
        AStopRefresh := False;
        Exit;
      end;
      if (AppSrvClientErr <> 0) or
        (AppSrvClient1.AnswerStatus <> '200') then
      begin
        ShowServerError(AWindowHandle, AppSrvClient1.Answer.Fields[0],
          AppSrvClient1.AnswerStatus);
        AStopRefresh := False;
        Exit;
      end;

      AppSrvClient1.Answer.First;
      if not AppSrvClient1.Answer.Eof then 
      begin
        ModuleID := AppSrvClient1.Answer.Fields[0];
        Module := AppSrvClient1.Answer.Fields[1];
        {$IFDEF CUSTOMDRIVE}
        OriginalPath := ChangeDriveName(AppSrvClient1.Answer.Fields[2], sDriveSubst);
        {$ELSE}
        OriginalPath := AppSrvClient1.Answer.Fields[2];
        {$ENDIF CUSTOMDRIVE}
      end;

      while not AppSrvClient1.Answer.Eof do
      begin
        OldFile := OriginalPath + AppSrvClient1.Answer.Fields[1];
        OldFile := ChangeFileExt(OldFile, TrimRight(AppSrvClient1.Answer.Fields[10]));
        if FileExists(OldFile) then 
        begin
          TargetFDate := FileGetUTCDateTime(OldFile) - cTimeConvErr;
          {$IFDEF DEBUGMSG}
          ShowMessage('File: ' + ExtractFileName(OldFile) +
            ' - TargetFDate: ' + DateTimeToStrGMT(TargetFDate) +
            ' - ArchiveFDate: ' +
            DateTimeToStrGMT(_StrToFloat(AppSrvClient1.Answer.Fields[6])));
          {$ENDIF DEBUGMSG}
          if _StrToFloat(AppSrvClient1.Answer.Fields[6]) < TargetFDate then 
          begin
            if _StrToInt(AppSrvClient1.Answer.Fields[8]) <> CRCInt(OldFile, Mess) then 
            begin
              BeepIfSet;
              if MessageBox(AWindowHandle, PChar(Format(JVCSRES_Module_6037s62_on_disk_has_a_newer_date_than_the_module_in_the_archive33
                + #13#10 + JVCSRES_Are_you_sure_you_want_to_overwrite_all_changes_of_the_existing_file63,
                [ExtractFileName(OldFile)])), cMsgBoxCaption, MB_YESNOCANCEL or
                MB_DEFBUTTON2 or MB_ICONQUESTION) <> idYes then
                goto NextModule;
            end;
            // if _StrToInt(AppSrvClient1.Answer.Fields[8]) <> CRCInt(OldFile, Mess) then begin
          end; // if FieldByName('FTIME').AsDateTime...
        end; // if FileExists(OldFile) then begin
        AppSrvClient1.Answer.Next;
      end; // while not AppSrvClient1.Answer.EoF do begin
    end; // with DataModule1 do begin
    TargetFile := OriginalPath + Module;

    // readonly ?
    SetROFlag := not (MatchWithFilter(ExtractFileName(TargetFile), NotReadOnlyFilter));
    CloseIDEView := not (IsIDEProject(TargetFile, sProjectName));
      
    FuncRes := GetBlobs(DBModule.GetJvcsConnection, AModuleList[I].ProjectID, ServerUserID,
      StrToInt(ModuleID), AModuleList[I].RevisionID,
      False{CheckOut}, Application, nil,
      SetROFlag{SetReadOnly}, CloseIDEView{CloseIDEView},
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
      MessageBox(AWindowHandle,
        PChar(Format('<%s>' + #13#10 + JVCSRES_JEDI_VCS_is_unable_to_create_a_local_copy_of_this_file46 + #13#10 +
          JVCSRES_Exception58_37s_in_37s46_, [TargetFile, ErrMsg, Mess])),
        cMsgBoxCaption, MB_OK or MB_ICONSTOP);
      AStopRefresh := False;
      Exit;
    end // if FuncRes <> 0 then begin
    else 
    begin
      if Length(AffectedFiles) > 1 then
        Delete(AffectedFiles, Length(AffectedFiles), 1);
      UseRegistry := True;
      DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
      DSAIdentsMessageDlg(JVCSRES_Undo_Checkout_complete46 + #10#13 +
        Format('<%s>' + #13#10 + JVCSRES_successfully_created46, [TargetFile]) + #10#13 +
        Format(JVCSRES_40Affected_files58_37s41, [AffectedFiles])
        , mtInformation
        , [mbOK]
        , 0
        , sBaseRegistryKey + crbMRU + 'Dlgs'
        , 'UndoChkOutSuc'
        , idOk
        );
    end;
    NextModule :
  end; //   for I := 0 to AModuleList.Count - 1 do begin
end;

end.