(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: HandleBlob.pas

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
2003/03/26  USchuster - new function GetBlobsEx
2003/04/08  USchuster - changes for IDEInterface
2004/10/30  USchuster - style cleaning
                      - res strings and displayed strings changed to resourcestrings
2004/11/03  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
2005/01/25  USchuster - replaced ZipMaster with Abbrevia (mantis #1048)
2005/04/11  CSchuette - mantis #2815
2005/12/02  THuber    #3336: additional check and removal of readonly flag on
                             extractblob for file included in blob
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 final released ^^^^^^^^^^^^^^^^^^^^^^^^^^
2006/03/15  THuber    #3555 ExtractZip2Source extracts to recent module name without
                            renaming extracted file
2006/03/27  USchuster - another change for mantis #3555 
2010/01/24  THuber - Directive B L O W F I S H removed as we use Blowfish-encryption always
-----------------------------------------------------------------------------*)

unit HandleBlob;

{$I jedi.inc}
{$I compopt.inc}

{$IFDEF DELPHI6_UP}
  {$WARN UNIT_PLATFORM OFF}
  {$WARN SYMBOL_PLATFORM OFF}
{$ENDIF DELPHI6_UP}

interface

uses
  JVCSConnect,
  {$IFDEF DEBUG}
  JclDebug,
  {$ENDIF DEBUG}
  Windows, Classes, Forms;

function ExtractZip2Source(ZipOwner: TComponent; const SourceFile: string;
  ZipFile: string; var ErrMsg: string; ModuleOrigTime: TDateTime = 0): Integer;

function GetBlobs(JVCSConnection: TJVCSConnection;
  const ProjectID, UserID, ModuleID, RevisionID: Integer;
  const CheckOut: Boolean; Application: TApplication;
  FuncOwner: TComponent;
  const SetReadOnly, CloseIDEView, SetCurrentDate: Boolean;
  var ModuleName: string; var ErrMsg: string;
  var AffectedFiles: string): Integer;

function GetBlobsEx(JVCSConnection: TJVCSConnection;
  const ProjectID, UserID, ModuleID, RevisionID: Integer;
  const CheckOut: Boolean; Application: TApplication;
  FuncOwner: TComponent;
  const SetReadOnly, CloseIDEView, SetCurrentDate: Boolean;
  var ModuleName: string; var ErrMsg: string;
  AffectedFiles: TStringList; AFmtModuleName: string = ''): Integer;

function CheckOut_Only(JVCSConnection: TJVCSConnection;
  const ProjectID, UserID, ModuleID, RevisionID: Integer;
  const CloseIDEView: Boolean;
  var ModuleName: string; var ErrMsg: string;
  var AffectedFiles: string): Integer;

implementation

uses
  SysUtils, TZHandling, VCSProcBase, VCSBase, ApsCli, RFormat, DBModule,
  BFCrypt, ConfigStorage, JVCSGUIClientResources, 
  AbArcTyp, AbZipTyp, AbUtils, AbUnzPrc, JVCSClientFunctions;

//==============================================================================
// function ExtractZip2Source(ZipOwner: TComponent; SourceFile, ZipFile: String;
//                            var OriginalFileName, ErrMsg: String;
//                            ModuleOrigTime: TDateTime = 0): Integer;
// Result 0 = OK
//        1 = Delete SourceFile error
//        2 = Assign Zipfile error
//        3 = Extract Error
//        4 = Successcount = 0
//        5 = Blowfish
//        6 = Blowfish
//==============================================================================
function ExtractZip2Source(ZipOwner: TComponent; const SourceFile: string;
  ZipFile: string; var ErrMsg: string; ModuleOrigTime: TDateTime = 0): Integer;
var
  FS, FSOut: TFileStream;
  Encrypted: Boolean;
  EncodeKey: string;
  AbZipArchive: TAbZipArchive;
  AbZipItem: TAbZipItem;
  sFile: string;
begin
  ErrMsg := '';
  if FileExists(SourceFile) then
  begin
    try
      FileSetReadOnlyAttribute(SourceFile, False);
      SysUtils.DeleteFile(SourceFile);
    except
      on E: Exception do
      begin
        ErrMsg := E.Message;
        Result := 1;
        Exit;
      end;
    end; // try except
  end;
  //--- Cipher -------------------------------------------------------------
  FS := TFileStream.Create(ZipFile, fmOpenRead or fmShareDenyWrite);
  try
    Encrypted := VerifyZip(FS) <> atZip;
  finally
    FS.Free;
  end;
  if Encrypted then
  begin
    EncodeKey :=
      jvcsReadString(sBaseRegistryKey + crbOptions, 'EncodeKey', '');
    if EncodeKey <> '' then
      EncodeKey := Base64Decode(EncodeKey)
    else
    begin
      ErrMsg := JVCSRES_EncodeKey_blank;
      Result := 5;
      Exit;
    end;
    if (not BlowFishDecode(ZipOwner, EncodeKey, ZipFile,
      ChangeFileExt(ZipFile, '.ulock'))) then
    begin
      ErrMsg := JVCSRES_BlowFishDecode_failed;
      Result := 6;
      Exit;
    end;
    SysUtils.DeleteFile(ZipFile);
    ZipFile := ChangeFileExt(ZipFile, '.ulock');
  end;
  //------------------------------------------------------------------------
  FS := TFileStream.Create(ZipFile, fmOpenRead or fmShareDenyWrite);
  try
    AbZipArchive := TAbZipArchive.CreateFromStream(FS, 'AbArchive');
    try
      try
        AbZipArchive.Load;
      except
        on E: Exception do
        begin
          ErrMsg := E.Message;
          Result := 2;
          Exit;
        end;
      end;
      if AbZipArchive.ItemList.Count > 0 then
      begin
        AbZipArchive.ExtractOptions :=  [eoCreateDirs, eoRestorePath];
        AbZipItem := AbZipArchive.Items[0];
        if SameText(AbZipItem.FileName, ExtractFileName(SourceFile)) then
          sFile := ExtractFilePath(SourceFile) + AbZipItem.FileName
        else
          sFile := SourceFile;
        try
          // !if a newly renamed module has already a file with same name in directory, this one will be overwritten!
          if FileExists(sFile) then
            FileSetReadOnlyAttribute(sFile, False);
          FSOut := TFileStream.Create(sFile, fmCreate);
          try
            AbUnzipToStream(AbZipArchive, AbZipItem, FSOut);
          finally
            FSOut.Free;
          end;

          // Set file time in UTC, CS 11.04.2005
          if ModuleOrigTime<>0 then
            FileSetUTCDateTime(sFile, ModuleOrigTime);

        except
          on E: Exception do
          begin
            ErrMsg := E.Message;
            Result := 3;
            Exit;
          end;
        end;
      end
      else
      begin
        ErrMsg := JVCSRES_Zipmaster46SuccessCnt_61_0; //change msg
        Result := 4;
        Exit;
      end;
    finally
      AbZipArchive.Free;
    end;
  finally
    FS.Free;
  end;
  if FileExists(ZipFile) then
    SysUtils.DeleteFile(ZipFile);

  Result := 0;
end;

//==============================================================================
// function GetBlobs(ProjectID, UserID, ModuleID, RevisionID: String;
//                   CheckOut: Boolean; Application: TApplication;
//                   FuncOwner: TComponent;
//                   SetReadOnly, CloseIDEView, SetCurrentDate: Boolean;
//                   var ModuleName: String; var ErrMsg: String;
//                   var AffectedFiles: String): Integer;
//
//  Result 0 = OK
//         1 = CreateTargetDir error
//         2 = AppSrvClient.Request Error
//         3 = File is checked out
//         4 = Not compressed
//         5 = TFileStream Error
//         6 = Error exctract zip file
//         7 = FileSetDate Error
//         8 = general error extract zip file
//        99 = unknown
//==============================================================================

function GetBlobs(JVCSConnection: TJVCSConnection;
  const ProjectID, UserID, ModuleID, RevisionID: Integer;
  const CheckOut: Boolean; Application: TApplication;
  FuncOwner: TComponent;
  const SetReadOnly, CloseIDEView, SetCurrentDate: Boolean;
  var ModuleName: string; var ErrMsg: string;
  var AffectedFiles: string): Integer;
var
  CurrentModuleName, ZipFile, FileExtension: string;
  FS: TFileStream;
  Compressed: Boolean;
  FldType: TMWFieldType;
  ModuleOrigTime: TDateTime;
begin
  Result := 99;
  ErrMsg := '';
  AffectedFiles := '';
  try
    //--- Close the view? ------------------------------------------------------
    {$IFDEF IDEDLL}
    if CloseIDEView then
      IDEInterface.CloseFile(ModuleName);
    {$ENDIF IDEDLL}
    //--- TargetDir? -----------------------------------------------------------
    if CreateTargetDir(ExtractFilePath(ModuleName)) <> 0 then
    begin
      ErrMsg := Format(JVCSRES_Unable_to_create_target_directory58_37s,
        [ExtractFilePath(ModuleName)]);
      Result := 1;
      Exit;
    end;
    with DataModule1 do
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_CHECKOUT_MODULE';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [ProjectID]);
      AppSrvClient1.Request.WriteFields(False, [UserID]);
      AppSrvClient1.Request.WriteFields(False, [ModuleID]);
      AppSrvClient1.Request.WriteFields(False, [RevisionID]);
      AppSrvClient1.Request.WriteFields(False, [CheckOut]);
      AppSrvClient1.Request.WriteFields(False, [ModuleName]);
      SetupTimeoutCounter;
      AppSrvClient1.Send;

      while WaitForAppSrvClient do
        Application.ProcessMessages;
      if (AppSrvClientErr <> 0) or (AppSrvClient1.AnswerStatus <> '200') then
      begin
        if AppSrvClient1.AnswerStatus = '403' then
          ErrMsg := JVCSRES_91Write_access_denied93
        else
          ErrMsg := JVCSRES_AppSrvClient46Request_Error_91GET95CHECKOUT95MODULE93;
        Result := 2;
        Exit;
      end;

      AppSrvClient1.Answer.First;
      // Locked?
      if not AppSrvClient1.Answer.Eof then
      begin
        if CheckOut and
          (not DecodeBoolStr(AppSrvClient1.Answer.Fields[0])) then
        begin
          ErrMsg := Format(JVCSRES_File_is_locked_by_6037s6246, [AppSrvClient1.Answer.Fields[1]])
            + #10#13 + JVCSRES_Access_denied;
          Result := 3;
          Exit;
        end;
      end; // if not AppSrvClient1.Answer.EoF then begin
      if not AppSrvClient1.Answer.Eof then
        AppSrvClient1.Answer.Next;

      while not AppSrvClient1.Answer.Eof do
      begin
        ModuleOrigTime := _StrToFloat(AppSrvClient1.Answer.Fields[0]);
        Compressed := (_StrToInt(AppSrvClient1.Answer.Fields[3]) > 0);
        FileExtension := TrimRight(AppSrvClient1.Answer.Fields[4]);
        CurrentModuleName := ChangeFileExt(ModuleName, FileExtension);
        AffectedFiles :=
          AffectedFiles + ExtractFileName(CurrentModuleName) + '/';

        if not Compressed then
        begin
          ErrMsg := JVCSRES_Current_version_does_not_support_uncompressed_modules33;
          Result := 4;
          Exit;
        end // if not Compressed then begin
        else
        begin
          // prepare Zipfile
          ZipFile := ExtractFilePath(CurrentModuleName) + '_vcsblob.zip';
          if FileExists(ZipFile) then
          begin
            FileSetAttr(ZipFile, FileGetAttr(ZipFile) and not $00000001);
            SysUtils.DeleteFile(ZipFile);
          end;
          // get blob
          try
            FS := TFileStream.Create(ZipFile, fmCreate or fmShareExclusive);
            try
              FS.Seek(0, 0);
              AppSrvClient1.Answer.GetStreamField(5, FS, FldType);
            finally
              FS.Free;
            end;
          except
            on E :
            Exception do
            begin
              ErrMsg := Format(JVCSRES_TFileStream_Error58_37s, [E.Message]);
              Result := 5;
              Exit;
            end;
          end; // try except
          // Extract Zip file
          try
            if ExtractZip2Source(FuncOwner, CurrentModuleName, ZipFile,
              ErrMsg, ModuleOrigTime) <> 0 then
            begin
              ErrMsg := Format(JVCSRES_Error_extract_zip_file58_37s, [ErrMsg]);
              Result := 6;
              Exit;
            end; // if ExtractZip2Source(self, Module, ZipFile,...
          except
            ErrMsg := JVCSRES_General_error_extract_zip_file;
            Result := 8;
            Exit;
          end; // try except

          if FileExists(ZipFile) then
            SysUtils.DeleteFile(ZipFile);

          // ReadOnly
          if SetReadOnly then
            FileSetAttr(CurrentModuleName,
              FileGetAttr(CurrentModuleName) or $00000001);
        end; // else if not Compressed then begin
        AppSrvClient1.Answer.Next;
      end;
    end; // with DataModule1 do begin
  except
    on E :
    Exception do
    begin
      ErrMsg := E.Message;
      Exit;
    end;
  end;
  Result := 0;
end;

//==============================================================================
// this is an extended version of GetBlobs
// - AffectedFiles is TStringList instead of string and the full filename will be
//   added to AffectedFiles
// - AFmtModuleName can be used to use another filename for the outputfile than
//   ModuleName, because Modulename will be written into the Logfile
// - AFmtModuleName can contain the placeholder %REVEXT% and this will be exchanged
//   with the revision extension
//
// function GetBlobsEx(const ProjectID, UserID, ModuleID, RevisionID: string;
//   const CheckOut: Boolean; Application: TApplication;
//   FuncOwner: TComponent;
//   const SetReadOnly, CloseIDEView, SetCurrentDate: Boolean;
//   var ModuleName: string; var ErrMsg: string;
//   AffectedFiles: TStringList; AFmtModuleName: string = ''): Integer;
//
//  Result 0 = OK
//         1 = CreateTargetDir error
//         2 = AppSrvClient.Request Error
//         3 = File is checked out
//         4 = Not compressed
//         5 = TFileStream Error
//         6 = Error exctract zip file
//         7 = FileSetDate Error
//         8 = general error extract zip file
//        99 = unknown
//==============================================================================

function GetBlobsEx(JVCSConnection: TJVCSConnection;
  const ProjectID, UserID, ModuleID, RevisionID: Integer;
  const CheckOut: Boolean; Application: TApplication;
  FuncOwner: TComponent;
  const SetReadOnly, CloseIDEView, SetCurrentDate: Boolean;
  var ModuleName: string; var ErrMsg: string;
  AffectedFiles: TStringList; AFmtModuleName: string = ''): Integer;
var
  CurrentModuleName, ZipFile, FileExtension: string;
  FS: TFileStream;
  Compressed: Boolean;
  FldType: TMWFieldType;
  ModuleOrigTime: TDateTime;
begin
  Result := 99;
  ErrMsg := '';
  if Assigned(AffectedFiles) then
    AffectedFiles.Clear;
  try
    //--- Close the view? ------------------------------------------------------
    {$IFDEF IDEDLL}
    if CloseIDEView then
      IDEInterface.CloseFile(ModuleName);
    {$ENDIF IDEDLL}
    //--- TargetDir? -----------------------------------------------------------
    if CreateTargetDir(ExtractFilePath(ModuleName)) <> 0 then
    begin
      ErrMsg := Format(JVCSRES_Unable_to_create_target_directory58_37s,
        [ExtractFilePath(ModuleName)]);
      Result := 1;
      Exit;
    end;
    with DataModule1 do
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'GET_CHECKOUT_MODULE';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [ProjectID]);
      AppSrvClient1.Request.WriteFields(False, [UserID]);
      AppSrvClient1.Request.WriteFields(False, [ModuleID]);
      AppSrvClient1.Request.WriteFields(False, [RevisionID]);
      AppSrvClient1.Request.WriteFields(False, [CheckOut]);
      AppSrvClient1.Request.WriteFields(False, [ModuleName]);
      SetupTimeoutCounter;
      AppSrvClient1.Send;

      while WaitForAppSrvClient do
        Application.ProcessMessages;
      if (AppSrvClientErr <> 0) or (AppSrvClient1.AnswerStatus <> '200') then
      begin
        if AppSrvClient1.AnswerStatus = '403' then
          ErrMsg := JVCSRES_91Write_access_denied93
        else
          ErrMsg := JVCSRES_AppSrvClient46Request_Error_91GET95CHECKOUT95MODULE93;
        Result := 2;
        Exit;
      end;

      AppSrvClient1.Answer.First;
      // Locked?
      if not AppSrvClient1.Answer.Eof then
      begin
        if CheckOut and
          (not DecodeBoolStr(AppSrvClient1.Answer.Fields[0])) then
        begin
          ErrMsg := Format(JVCSRES_File_is_locked_by_6037s6246, [AppSrvClient1.Answer.Fields[1]]) +
            #10#13 + JVCSRES_Access_denied;
          Result := 3;
          Exit;
        end;
      end; // if not AppSrvClient1.Answer.EoF then begin
      if not AppSrvClient1.Answer.Eof then
        AppSrvClient1.Answer.Next;

      while not AppSrvClient1.Answer.Eof do
      begin
        ModuleOrigTime := _StrToFloat(AppSrvClient1.Answer.Fields[0]);
        Compressed := (_StrToInt(AppSrvClient1.Answer.Fields[3]) > 0);
        FileExtension := TrimRight(AppSrvClient1.Answer.Fields[4]);

        if AFmtModuleName = '' then
          CurrentModuleName := ChangeFileExt(ModuleName, FileExtension)
        else
        if Pos('%REVEXT%', AFmtModuleName) = 0 then
          CurrentModuleName := ChangeFileExt(AFmtModuleName, FileExtension)
        else
          CurrentModuleName := StringReplace(AFmtModuleName, '%REVEXT%',
            ExtractFileExtWithoutDot(FileExtension), [rfReplaceAll]);

        if Assigned(AffectedFiles) then
          AffectedFiles.Add(CurrentModuleName);

        if not Compressed then
        begin
          ErrMsg := JVCSRES_Current_version_does_not_support_uncompressed_modules33;
          Result := 4;
          Exit;
        end // if not Compressed then begin
        else
        begin
          // prepare Zipfile
          ZipFile := ExtractFilePath(CurrentModuleName) + '_vcsblob.zip'; 
          if FileExists(ZipFile) then
          begin
            FileSetAttr(ZipFile, FileGetAttr(ZipFile) and not $00000001);
            SysUtils.DeleteFile(ZipFile);
          end;
          // get blob
          try
            FS := TFileStream.Create(ZipFile, fmCreate or fmShareExclusive);
            try
              FS.Seek(0, 0);
              AppSrvClient1.Answer.GetStreamField(5, FS, FldType);
            finally
              FS.Free;
            end;
          except
            on E :
            Exception do
            begin
              ErrMsg := Format(JVCSRES_TFileStream_Error58_37s, [E.Message]);
              Result := 5;
              Exit;
            end;
          end; // try except
          // Extract Zip file
          try
            if ExtractZip2Source(FuncOwner, CurrentModuleName, ZipFile,
              ErrMsg, ModuleOrigTime) <> 0 then
            begin
              ErrMsg := Format(JVCSRES_Error_extract_zip_file58_37s, [ErrMsg]);
              Result := 6;
              Exit;
            end; // if ExtractZip2Source(self, Module, ZipFile,...
          except
            ErrMsg := JVCSRES_General_error_extract_zip_file;
            Result := 8;
            Exit;
          end; // try except

          if FileExists(ZipFile) then
            SysUtils.DeleteFile(ZipFile);

          // ReadOnly
          if SetReadOnly then
            FileSetAttr(CurrentModuleName,
              FileGetAttr(CurrentModuleName) or $00000001);
        end; // else if not Compressed then begin
        AppSrvClient1.Answer.Next;
      end;
    end; // with DataModule1 do begin
  except
    on E :
    Exception do
    begin
      ErrMsg := E.Message;
      Exit;
    end;
  end;
  Result := 0;
end;

//==============================================================================
// function CheckOut_Only(ProjectID, UserID, ModuleID, RevisionID: String;
//                        CloseIDEView: Boolean;
//                        var ModuleName: String; var ErrMsg: String;
//                        var AffectedFiles: String): Integer;
//
//  Result 0 = OK
//         1 = CreateTargetDir error
//         2 = AppSrvClient.Request Error
//         3 = File is checked out
//         4 = Not compressed
//         5 = TFileStream Error
//         6 = Error exctract zip file
//         7 = FileSetDate Error
//        99 = unknown
//==============================================================================

function CheckOut_Only(JVCSConnection: TJVCSConnection;
  const ProjectID, UserID, ModuleID, RevisionID: Integer;
  const CloseIDEView: Boolean;
  var ModuleName: string; var ErrMsg: string;
  var AffectedFiles: string): Integer;
var
  CurrentModuleName, FileExtension: string;
begin
  Result := 99;
  ErrMsg := '';
  AffectedFiles := '';
  try
    //--- Close the view? ------------------------------------------------------
    {$IFDEF IDEDLL}
    if CloseIDEView then
      IDEInterface.CloseFile(ModuleName);
    {$ENDIF IDEDLL}
    with DataModule1 do
    begin
      AppSrvClient1.Request.Rewrite;
      AppSrvClient1.FunctionCode := 'CHECKOUT_ONLY_MODULE';
      AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
      AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
      AppSrvClient1.Request.WriteFields(True, [ProjectID]);
      AppSrvClient1.Request.WriteFields(False, [UserID]);
      AppSrvClient1.Request.WriteFields(False, [ModuleID]);
      AppSrvClient1.Request.WriteFields(False, [RevisionID]);
      AppSrvClient1.Request.WriteFields(False, [ModuleName]);
      SetupTimeoutCounter;
      AppSrvClient1.Send;

      while WaitForAppSrvClient do
        Application.ProcessMessages;
      if (AppSrvClientErr <> 0) or (AppSrvClient1.AnswerStatus <> '200') then
      begin
        if AppSrvClient1.AnswerStatus = '403' then
          ErrMsg := JVCSRES_91Write_access_denied93
        else
          ErrMsg := JVCSRES_AppSrvClient46Request_Error_91CHECKOUT95ONLY95MODULE93;
        Result := 2;
        Exit;
      end;

      AppSrvClient1.Answer.First;
      // Locked?
      if not AppSrvClient1.Answer.Eof then
      begin
        if not DecodeBoolStr(AppSrvClient1.Answer.Fields[0]) then
        begin
          ErrMsg := Format(JVCSRES_File_is_locked_by_6037s6246_Access_denied,
            [AppSrvClient1.Answer.Fields[1]]);
          Result := 3;
          Exit;
        end;
      end; // if not AppSrvClient1.Answer.EoF then begin
      if not AppSrvClient1.Answer.Eof then
        AppSrvClient1.Answer.Next;

      while not AppSrvClient1.Answer.Eof do
      begin
        FileExtension := TrimRight(AppSrvClient1.Answer.Fields[0]);
        CurrentModuleName := ChangeFileExt(ModuleName, FileExtension);
        AffectedFiles :=
          AffectedFiles + ExtractFileName(CurrentModuleName) + '/';
        // ReadOnly
        FileSetAttr(CurrentModuleName,
          FileGetAttr(CurrentModuleName) and not $00000001);
        AppSrvClient1.Answer.Next;
      end;
    end; // with DataModule1 do begin
  except
    on E :
    Exception do
    begin
      ErrMsg := E.Message;
      Exit;
    end;
  end;
  Result := 0;
end;

end.
