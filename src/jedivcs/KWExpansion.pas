{ $NoKeywords }
(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: KWExpansion.pas

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
2003/03/15  THuber    - compilerhints/warnings removed
2003/12/28  USchuster - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use constant)
2004/10/30  USchuster - style cleaning
                      - res strings and displayed strings changed to resourcestrings
2004/11/03  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
2005/03/17  USchuster - fixed $Keyword check in the first two lines (mantis #2768)
2006/12/10  USchuster - added JVCSClientFunctions to uses (as of now it is required for MatchWithFilter)

-----------------------------------------------------------------------------*)

unit KWExpansion;

{$I jedi.inc}
{$I compopt.inc}

{$IFDEF DELPHI6_UP}
  {$WARN UNIT_PLATFORM OFF}
  {$WARN SYMBOL_PLATFORM OFF}
{$ENDIF DELPHI6_UP}

interface

uses
  Forms, Windows;

function ExpanseKeywords(const ParentApp: TApplication; const ParentWnd: HWND;
  const ActionType: Integer; const FileName, User: string; Comment: string;
  const LabelName: string; const Version, Revision, ModuleID,
  RevisionID: Integer): Boolean;

implementation

uses
  SysUtils, Classes, VCSProcBase, VCSBase, DBModule, TZHandling, ConfigStorage,
  JVCSGUIClientResources, JVCSClientFunctions;

var
  FileIsChanged: Boolean;

//------------------------------------------------------------------------------
function SearchAndChangeKW(const TextString, SearchString,
  ChangeString: string): string;
var
  SrcPos, SrchLen, TextLen: Integer;
begin
  Result := '';
  SrcPos := 0;
  SrchLen := Length(SearchString);
  TextLen := Length(TextString);
  FileIsChanged := True;
  repeat
    Inc(SrcPos);
    if Copy(TextString, SrcPos, SrchLen) = SearchString then
    begin
      Result := Result + ChangeString + ' $';
      SrcPos := SrcPos + SrchLen - 1;
      repeat
        Inc(SrcPos);
      until (SrcPos >= TextLen) or (TextString[SrcPos] = '$');
    end
    else
      Result := Result + Copy(TextString, SrcPos, 1);
  until SrcPos >= TextLen;
end;

//------------------------------------------------------------------------------

function ParseCommentString(CommentString: string): string;
var
  CurrPos: Integer;
begin
  Result := '';
  if CommentString <> '' then 
  begin
    for CurrPos := 1 to Length(CommentString) do
    begin
      if (CommentString[CurrPos] = #10) or (CommentString[CurrPos] = #13) then
      begin
        CommentString[CurrPos] := ' ';
      end;
    end;
    while Length(CommentString) > 70 do
    begin
      CurrPos := 50;
      while CurrPos < Length(CommentString) do
      begin
        if CommentString[CurrPos] = ' ' then
        begin
          Result := Result + Copy(CommentString, 1, CurrPos) + '|';
          System.Delete(CommentString, 1, CurrPos);
          Break;
        end;
        Inc(CurrPos);
      end; // while CurrPos < Length(Comment) do begin
      //THu no use: Inc(CurrPos);
    end; // while Length(Comment) > 70 do begin
    Result := Result + CommentString + '|';
  end; // if Comment <> '' then begin}
end;

//------------------------------------------------------------------------------

function GetModuleHistory(const ParentApp: TApplication; ModuleName: string;
  ModuleID: Integer; var History: string): Boolean;
var
  CurrentVersion, CurrentRevision, Comment: string;
begin
  Result := False;
  History := '';
  try
    //Thu no use: VersionsCount := 0;
    with DataModule1 do 
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_MODULE_HISTORY';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [ModuleID]);
      SetupTimeoutCounter;
      AppSrvClient1.Send;

      while WaitForAppSrvClient do 
        Application.ProcessMessages;
      if (AppSrvClientErr = -99) then 
      begin
        History := '';
        Exit;
      end;
      if (AppSrvClientErr <> 0) or
        (AppSrvClient1.AnswerStatus <> '200') then 
      begin
        History := AppSrvClient1.Answer.Fields[0];
        Exit;
      end;

      AppSrvClient1.Answer.First;
      //THu No use: CheckedOut := False;
      if not AppSrvClient1.Answer.Eof then 
      begin
        {if AppSrvClient1.Answer.Fields[0] <> '' then
          edDescr.Text := AppSrvClient1.Answer.Fields[0]
            else edDescr.Text := 'blank';}
      end; // if not AppSrvClient1.Answer.EoF then begin
      if not AppSrvClient1.Answer.Eof then 
        AppSrvClient1.Answer.Next;
      while not AppSrvClient1.Answer.Eof do 
      begin
        //THu was not used: Inc(VersionsCount);
        //Thu was not used: CheckedOut := DecodeBoolStr(AppSrvClient1.Answer.Fields[0]);
        CurrentVersion := AppSrvClient1.Answer.Fields[1];
        CurrentRevision := AppSrvClient1.Answer.Fields[2];
        Comment := AppSrvClient1.Answer.Fields[7];
        // Ver/Rev
        History := History + '**** V ' + CurrentVersion + '.' +
          CurrentRevision + ' by ';
        // by User
        History := History + AppSrvClient1.Answer.Fields[3] + ' ****|';
        // Member
        History := History + '* ' +
          ChangeFileExt(ModuleName, TrimRight(AppSrvClient1.Answer.Fields[6])) + ' - ';
        // Time
        History := History +
          DateTimeToStr(GMTStr2LocalDateTime(AppSrvClient1.Answer.Fields[4])) + ' - ';
        // Size
        History := History + AppSrvClient1.Answer.Fields[5] + ' Bytes|';
        if not AppSrvClient1.Answer.Eof then 
          AppSrvClient1.Answer.Next;
        while (not AppSrvClient1.Answer.Eof) and
          (CurrentVersion = AppSrvClient1.Answer.Fields[1]) and
          (CurrentRevision = AppSrvClient1.Answer.Fields[2]) do 
        begin
          // Member
          History := History + '* ' +
            ChangeFileExt(ModuleName, TrimRight(AppSrvClient1.Answer.Fields[6])) + ' - ';
          // Time
          History := History +
            DateTimeToStr(GMTStr2LocalDateTime(AppSrvClient1.Answer.Fields[4])) + ' - ';
          // Size
          History := History + AppSrvClient1.Answer.Fields[5] + ' Bytes|';
          AppSrvClient1.Answer.Next;
        end; // while (not AppSrvClient1.Answer.EoF) and
        // Comment
        Comment := ParseCommentString(Comment);
        if Comment <> '' then 
        begin
          // parse & show the result
          while (Length(Comment) > 1) and (Pos('|', Comment) > 0) do
          begin
            History :=
              History + '* ' + Copy(Comment, 1, Pos('|', Comment) - 1) + '|';
            Delete(Comment, 1, Pos('|', Comment));
          end; // while (Length(History) > 1)...
        end; // if Comment <> '' then begin}
      end; // while not AppSrvClient1.Answer.EoF do begin
    end; // with DataModule1 do begin

    Result := True;
  except
    on E: 
    Exception do 
    begin
      History := E.Message;
      Result := False;
    end;
  end;
end;

//------------------------------------------------------------------------------

function ExpanseKeywords(const ParentApp: TApplication; const ParentWnd: HWND;
  const ActionType: Integer; const FileName, User: string; Comment: string;
  const LabelName: string; const Version, Revision, ModuleID,
  RevisionID: Integer): Boolean;
var 
  FileLines: TStringList;
  I, J, K, OldFAttr: Integer;
  OriginalStr, OriginalName, History, HistoryItem, Comments: string;
  LookForSKW, SkiptheFile, HistoryChanged: Boolean;
begin
  Result := False;
  HistoryChanged := False;
  FileIsChanged := False;
  if not FileExists(FileName) then 
    Exit;
  OriginalName := GetOriginalFileName(FileName);
  if jvcsReadBool(sBaseRegistryKey + crbOptions, 'KWExpCheckBinary', False) then
  begin
    if IsBinaryFile(OriginalName) then 
    begin
      BeepIfSet;
      MessageBox(ParentWnd, PChar(Format(JVCSRES_JEDI_VCS_cannot_expand_keywords_in_file + #13#10 +
        '<%s>' + #13#10 + JVCSRES_The_file_is_a_binary_file_type46, [FileName])),
        cMsgBoxCaption, MB_OK or MB_ICONWARNING);
      Exit;
    end;
  end;
  OldFAttr := FileGetAttr(OriginalName);
  FileSetAttr(OriginalName, OldFAttr and not $00000001);
  LookForSKW :=
    jvcsReadBool(sBaseRegistryKey + crbOptions, 'KWIgnorewoSKW', False);
  if jvcsReadBool(sBaseRegistryKey + crbOptions, 'KWExpBackup', False) then
    _CopyFile(OriginalName, ChangeFileExt(OriginalName, '.~kw'));
  try
    FileLines := TStringList.Create;
    try
      FileLines.LoadFromFile(OriginalName);
      SkiptheFile := False;
      if LookForSKW then 
      begin
        SkiptheFile := True;
        I := 0;
        while (I < 2) and (I < FileLines.Count) do
        begin
          if SkiptheFile then
            SkiptheFile := (Pos('$Keywords', FileLines.Strings[I]) = 0);
          Inc(I);
        end;
      end; // if LookForSKW then begin

      if not SkiptheFile then 
      begin
        for I := 0 to FileLines.Count - 1 do 
        begin
          OriginalStr := FileLines.Strings[I];
          if (OriginalStr <> '') and (Pos('$', OriginalStr) > 0) then
          begin
            if Pos('$NoKeywords', OriginalStr) > 0 then 
              Break;
            case ActionType of
              kwexAdd :
                begin
                  if (Pos('$AddDate:', OriginalStr) > 0) then
                    OriginalStr := SearchAndChangeKW(OriginalStr,
                      '$AddDate:', '$AddDate: ' + DateTimeToStr(Now));
                  if (Pos('$AddUser:', OriginalStr) > 0) then
                    OriginalStr := SearchAndChangeKW(OriginalStr,
                      '$AddUser:', '$AddUser: ' + User);
                  if (Pos('$AddComment:', OriginalStr) > 0) then
                    OriginalStr := SearchAndChangeKW(OriginalStr,
                      '$AddComment:', '$AddComment: ' + Comment);
                  if (Pos('$AddProject:', OriginalStr) > 0) then
                    OriginalStr := SearchAndChangeKW(OriginalStr,
                      '$AddProject:', '$AddProject: ' + ExtractFileName(sProjectName));
                  if (Pos('$ModuleID:', OriginalStr) > 0) then
                    OriginalStr := SearchAndChangeKW(OriginalStr,
                      '$ModuleID:', '$ModuleID: ' + IntToStr(ModuleID));
                  if (Pos('$OriginalPath:', OriginalStr) > 0) then
                    OriginalStr := SearchAndChangeKW(OriginalStr,
                      '$OriginalPath:', '$OriginalPath: ' + ExtractFilePath(FileName));
                  if (Pos('$AddComment:', OriginalStr) > 0) then
                  begin
                    Comments := Comment;
                    for K := 1 to Length(Comments) do
                      if (Comments[K] = #10) or (Comments[K] = #13) then
                        Comments[K] := ' ';
                    OriginalStr := SearchAndChangeKW(OriginalStr,
                      '$AddComment:', '$AddComment: ' + Comments);
                  end;
                end; // kwexAdd :
              kwexCheckIn :
                begin
                  if (Pos('$CheckInDate:', OriginalStr) > 0) then
                    OriginalStr := SearchAndChangeKW(OriginalStr,
                      '$CheckInDate:', '$CheckInDate: ' + DateTimeToStr(Now));
                  if (Pos('$CheckInUser:', OriginalStr) > 0) then
                    OriginalStr := SearchAndChangeKW(OriginalStr,
                      '$CheckInUser:', '$CheckInUser: ' + User);
                  if (Pos('$Version:', OriginalStr) > 0) then
                    OriginalStr := SearchAndChangeKW(OriginalStr,
                      '$Version:', '$Version: ' + IntToStr(Version));
                  if (Pos('$Revision:', OriginalStr) > 0) then
                    OriginalStr := SearchAndChangeKW(OriginalStr,
                      '$Revision:', '$Revision: ' + IntToStr(Revision));
                  if (Pos('$CheckInProject:', OriginalStr) > 0) then
                    OriginalStr := SearchAndChangeKW(OriginalStr,
                      '$CheckInProject:', '$CheckInProject: ' +
                      ExtractFileName(sProjectName));
                  if (Pos('$ModuleID:', OriginalStr) > 0) then
                    OriginalStr := SearchAndChangeKW(OriginalStr,
                      '$ModuleID:', '$ModuleID: ' + IntToStr(ModuleID));
                  if (Pos('$Label:', OriginalStr) > 0) then
                    OriginalStr := SearchAndChangeKW(OriginalStr,
                      '$Label:', '$Label: ' + LabelName);
                  if (Pos('$OriginalPath:', OriginalStr) > 0) then
                    OriginalStr := SearchAndChangeKW(OriginalStr,
                      '$OriginalPath:', '$OriginalPath: ' + ExtractFilePath(FileName));
                  if (Pos('$CheckInComment:', OriginalStr) > 0) then
                  begin
                    Comments := Comment;
                    for K := 1 to Length(Comments) do
                      if (Comments[K] = #10) or (Comments[K] = #13) then
                        Comments[K] := ' ';
                    OriginalStr := SearchAndChangeKW(OriginalStr,
                      '$CheckInComment:', '$CheckInComment: ' + Comments);
                  end;
                end; // kwexCheckIn :
              kwexCheckout :
                begin
                  if (Pos('$CheckOutDate:', OriginalStr) > 0) then
                    OriginalStr := SearchAndChangeKW(OriginalStr,
                      '$CheckOutDate:', '$CheckOutDate: ' + DateTimeToStr(Now));
                  if (Pos('$CheckOutUser:', OriginalStr) > 0) then
                    OriginalStr := SearchAndChangeKW(OriginalStr,
                      '$CheckOutUser:', '$CheckOutUser: ' + User);
                  if (Pos('$CheckOutProject:', OriginalStr) > 0) then
                    OriginalStr := SearchAndChangeKW(OriginalStr,
                      '$CheckOutProject:', '$CheckOutProject: ' +
                      ExtractFileName(sProjectName));
                  if (Pos('$ModuleID:', OriginalStr) > 0) then
                    OriginalStr := SearchAndChangeKW(OriginalStr,
                      '$ModuleID:', '$ModuleID: ' + IntToStr(ModuleID));
                  if (Pos('$RevisionID:', OriginalStr) > 0) then
                    OriginalStr := SearchAndChangeKW(OriginalStr,
                      '$RevisionID:', '$RevisionID: ' + IntToStr(RevisionID));
                  if (Pos('$OriginalPath:', OriginalStr) > 0) then
                    OriginalStr := SearchAndChangeKW(OriginalStr,
                      '$OriginalPath:', '$OriginalPath: ' + ExtractFilePath(FileName));
                  if (Pos('$CheckOutComment:', OriginalStr) > 0) then
                  begin
                    Comments := Comment;
                    for K := 1 to Length(Comments) do
                      if (Comments[K] = #10) or (Comments[K] = #13) then
                        Comments[K] := ' ';
                    OriginalStr := SearchAndChangeKW(OriginalStr,
                      '$CheckOutComment:', '$CheckOutComment: ' + Comments);
                  end;
                end; // kwexCheckout :
            end; // case ActionType of
            FileLines.Strings[I] := OriginalStr;
          end; // if (OriginalStr <> '') and (Pos('$', OriginalStr) > 0) then
        end; // for I := 0 to FileLines.Count - 1 do begin
        if FileIsChanged then
          FileLines.SaveToFile(OriginalName);
        // insert history
        if ActionType = kwexCheckIn then 
        begin
          FileLines.LoadFromFile(OriginalName);
          for I := 0 to FileLines.Count - 1 do 
          begin
            if Pos('$NoKeywords', FileLines.Strings[I]) > 0 then 
              Break;
            if Pos('$History', FileLines.Strings[I]) > 0 then
            begin
              J := I;
              if not GetModuleHistory(ParentApp, ExtractFileName(FileName),
                ModuleID, History) then
              begin
                BeepIfSet;
                MessageBox(ParentWnd, PChar(Format(JVCSRES_JEDI_VCS_cannot_expand_the_keywords_in_file + #13#10 +
                  '<%s>' + #13#10 + JVCSRES_Exception58_37s, [FileName, History])),
                  cMsgBoxCaption, MB_OK or MB_ICONSTOP);
                Exit;
              end
              else
              begin
                HistoryChanged := True;
                // remove old history
                while (Pos('$History', FileLines.Strings[J]) > 0) and
                  (J < FileLines.Count) do 
                  FileLines.Delete(J);
                // parse & show the result
                while (Length(History) > 1) and (Pos('|', History) > 0) do
                begin
                  HistoryItem := '$History: ' + Copy(History, 1, Pos('|', History) - 1);
                  Delete(History, 1, Pos('|', History));
                  FileLines.Insert(J, HistoryItem);
                  Inc(J);
                end; // while (Length(History) > 1)...
              end;
              // latest revision
              FileLines.Insert(J, '$History: **** Latest ** V ' +
                IntToStr(Version) + '.' + IntToStr(Revision) + ' by ' + User +
                ' ** ' + DateTimeToStr(Now) + ' ****');
              Inc(J);
              // Comment
              Comments := ParseCommentString(Comment);
              if Comments <> '' then
              begin
                // parse & show the result
                while (Length(Comments) > 1) and (Pos('|', Comments) > 0) do
                begin
                  FileLines.Insert(J, '$History: * ' +
                    Copy(Comments, 1, Pos('|', Comments) - 1));
                  Delete(Comments, 1, Pos('|', Comments));
                  Inc(J);
                end; // while (Length(Comments) > 1) and...
              end; // if Comment <> '' then begin}
              Break; // for I := 0 to FileLines.Count - 1 do begin
            end; // if Pos('$History', FileLines.Strings[I]) > 0 then
          end; // for I := 0 to FileLines.Count - 1 do begin
          if HistoryChanged then
            FileLines.SaveToFile(OriginalName);
        end; // if ActionType = kwexCheckIn then begin
      end; // if not SkiptheFile then
    finally
      FileLines.Free;
    end;
  except
    on E: 
    Exception do 
    begin
      BeepIfSet;
      MessageBox(ParentWnd, PChar(Format(JVCSRES_JEDI_VCS_cannot_expand_the_keywords_in_file + #13#10 +
        '<%s>' + #13#10 + JVCSRES_Exception58_37s, [FileName, E.Message])),
        cMsgBoxCaption, MB_OK or MB_ICONSTOP);
      Exit;
    end;
  end;
  FileSetAttr(OriginalName, OldFAttr or faArchive);
  Result := True;
end;

end.
