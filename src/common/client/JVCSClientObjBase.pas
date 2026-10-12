(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: FVCSBase.pas

The Initial Developer of the original Code (JEDI FreeVCS) is:
  Ondrej Kelle (tondrej@t-online.de)
Code move to JEDI VCS: Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Purpose:
  This unit contains the base class TJVCSClientObject for all JEDI VCS client classes.

Last Modified: see History

Known Issues:
ToDo:
- move SafeStrToFloat to JVCSClientFunctions ?
-----------------------------------------------------------------------------

Unit history(JEDI FreeVCS):

2002/05/08  TOndrej    - Initial implementation and commenting
2002/07/17  TOndrej    - Added ExtractBlobToDir method
2002/07/19  TOndrej    - Changed LogResults, BlobAsText methods of TFVCSClientObject 
                         to allow conditional displaying of blobs in logs
2002/10/04  THuber     - Bugfix on ExtractBlobToDir (file was not overwritten)
2002/11/16  THuber     - Replaced ZipMastr with NanoZip

Unit history(JEDI VCS):

2003/10/23  USchuster  - 1st Migrationstep from JEDI FreeVCS code to JEDI VCS
                       - renamed to JVCSClientObjectBase.pas
                       - changed ...FVCS... into ...JVCS...
                       - new define NOFORMS to exclude forms in console application
                       - included g_DefReqTimeout and JVCSClassPrefix from FVCSDef.pas
2003/10/27  USchuster  - D5 Fix
2003/12/13  USchuster  - moved FileSetReadOnlyAttribute to JVCSClientFunctions
2004/01/31  USchuster  - prepared for next MidWare beta (use TAppSrvClient.ClientSocket 
                         instead of TAppSrvClient.WSocket)
2004/10/12  THuber     - #2157 replaced nanozip with abbrevia
2004/10/17  USchuster  - D5 fix
2004/10/18  THuber     - added JVCSCompressFile from jvcs.dpr for common use 
2004/11/24  CSchuette  - #2297 do not change extension to .zip in JVCSCompressFile
2005/01/25  USchuster  - changed to use another Abbrevia method for zip extraction
                         in TJVCSClientObject.BlobAsText and .ExtractBlobToDir
                       - fixed broken .BlobAsText (before you got an empty result
                         for a valid zip; this was broken since ZipMaster was
                         replaced by Nanozip in FVCSBase.pas[V 0.8/16.11.2002])
2005/02/01  USchuster  - changed to use another Abbrevia method in JVCSCompressFile
                         for adding a file to avoid problems(empty zip file) with
                         "special" characters in the filename(mantis #2571)
2005/02/02  USchuster  - fix for last change to store correct filename case and
                         timestamp in the zip file
2005/03/05  USchuster  - now EJVCSClientRequestError is used in TJVCSClientObject.RequestDone
                         for bad appserver results (mantis #2714)
2005/03/26  USchuster  - new function JVCSCompressFileList for mantis #2782
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC2 was released ^^^^^^^^^^^^^^^^^^^^^^^^^^^
2005/05/21  USchuster  - fixed some filename issues in TJVCSAbZipper (mantis #2969)
2005/06/27  USchuster  - added TJVCSClientObject.ExtractBlobToStream
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 final released ^^^^^^^^^^^^^^^^^^^^^^^^^^
2006/06/05  USchuster  - added TJVCSClientObject.ExtractBlobToFile (mantis #3744)
2014/02/27  USchuster  - Unicode fix in JVCSCompressFile

-----------------------------------------------------------------------------*)

unit JVCSClientObjBase;

{$I jedi.inc}
{$I compopt.inc}

{$IFDEF DELPHI6_UP}
  {$WARN SYMBOL_PLATFORM OFF}
{$ENDIF DELPHI6_UP}

interface

{ TODO -oTOndrej -cBase : split FVCSClient package in two; make a separate package requiring VCL }
{ TODO -oTOndrej -cBase : re-generate FVCSClientObj without logging and input forms }
{ TODO -oTOndrej -cBase : AVs sometimes raised in WaitForAnswer; difficult to reproduce }

uses
  Classes, SysUtils, Windows
  {$IFNDEF NOFORMS}
    , Controls
    {$IFNDEF DELPHI6_UP}
    , Forms
    {$ENDIF ~DELPHI6_UP}
  {$ENDIF ~NOFORMS}
  , ApsCli, CBroker, RFormat, JVCSTypes, VCSCommon, JclFileUtils;

var
  g_DefReqTimeout: Integer = 12000;

const
  JVCSClassPrefix = 'TJVCS';

type
  // override Initialize to clear any previously received response
  // override SetResponseFields to store received response

  TJVCSClientObjectClass = class of TJVCSClientObject;
  TJVCSClientObject = class(TClientObject)
  private
    FRequestTimeout: Cardinal;

    function GetUserData(Index: Integer): Integer;
  protected
    FHandleResultSibling: Boolean;  // RequestDone will always be called
    procedure DoExecute; virtual; // override to prepare input parameters
    procedure RequestDone(Sender: TObject; Error: Integer); override;
  public
    procedure CopyFromReference(Reference: TClientObject); override; // copy from a reference instance
    constructor Create(AOwner: TComponent); override;

    function BlobAsText(Stream: TStream; ShowBlob: Boolean = True): string;
    procedure BuildFunctionCode; override;
    procedure Execute; override;
    procedure ExtractBlobToDir(const TargetDir: string; Stream: TStream);
    procedure ExtractBlobToFile(const AFileName: string; Stream: TStream);
    function ExtractBlobToStream(ASourceStream, ADestStream: TStream): Boolean;
    procedure LogResults(Strings: TStrings; ShowBlobs: Boolean = False); virtual;
    {$IFNDEF NOFORMS}
    function ShowInputForm: TModalResult; virtual;
    {$ENDIF ~NOFORMS}
    function  WaitForAnswer(Timeout: Integer): Boolean; override;

    property FunctionCode: string read FFunctionCode;
    property RequestTimeout: Cardinal read FRequestTimeout write FRequestTimeout;
    property TransactionID: Integer index 1 read GetUserData;
    property UserID: Integer index 0 read GetUserData;
  end;

function GetFunctionCode(ClientObject: TClientObjectClass): string;
function SafeStrToFloat(const S: string): Extended;
function JVCSCompressFile(const sSourceFile: string; var sCompressedFile: string; CompressedType: TJVCSCompressionType = jvcsZip): Boolean;
function JVCSCompressFileList(AFileList: TStrings; const ARootDir, AZipFileName: string;
  const AStripPath: Boolean; var ASuccessCount: Integer; AOnSimpleProgress: TNotifyEvent;
  CompressedType: TJVCSCompressionType = jvcsZip): Boolean;

resourcestring
  SBadRequest = 'Request ''%s'' rejected by server: status %d (bad request)'; // result 400
  SInvalidClassName = 'Invalid client request object class name: %s'; // invalid class name
  SRequestForbidden = 'Request ''%s'' rejected by server: status %d (forbidden)'; // result 403
  SRequestRejected = 'Request ''%s'' rejected by server: status %d'; // other results
  SRequestFailed = 'Request ''%s'' failed: error %d %s'; // non-zero error code
  SRequestTimedOut = 'Request ''%s'' timed out';
  SDLLError = 'Cannot load library %s';

implementation

uses
    JVCSClientFunctions
  , AbBase
  , AbArcTyp
  , AbZipTyp
  , AbZipper
  , AbUtils
  , AbUnzPrc
  ;

function GetFunctionCode(ClientObject: TClientObjectClass): string;
var
  S: string;
  P: PChar;
begin
  Result := '';
  S := ClientObject.ClassName;
  if StrLComp(PChar(S), JVCSClassPrefix, Length(JVCSClassPrefix)) <> 0 then
    raise EJVCSClient.CreateFmt(SInvalidClassName, [S]);
    
  P := PChar(S) + Length(JVCSClassPrefix);
  repeat
    Result := Result + UpperCase(P^);

    Inc(P);
    case P^ of
      'A'..'Z':
        Result := Result + '_';
    end;
  until P^ = #0;
end;

// appserver may be running under different locale
function SafeStrToFloat(const S: string): Extended;
var
  I: Integer;
  Test: string;
begin
  Test := S;
  if Pos(DecimalSeparator, Test) = 0 then
  begin
    for I := 1 To Length(Test) do
    begin
      if not (Test[I] in [' ','0'..'9','e','E','+','-']) then
      begin
        Test[I] := DecimalSeparator;
        Break;
      end;
    end;
  end;
  Result := StrToFloat(Test);
end;

type
  TJVCSAbZipper = class(TAbZipper)
  private
    FRootPath: string;
    FOnSimpleProgress: TNotifyEvent;
    procedure SetRootPath(const AValue: string);
  protected
    procedure DoConfirmProcessItem(Sender: TObject; Item: TAbArchiveItem;
      ProcessType: TAbProcessType; var Confirm: Boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
    property RootPath: string read FRootPath write SetRootPath;
    property OnSimpleProgress: TNotifyEvent read FOnSimpleProgress write FOnSimpleProgress;
  end;

constructor TJVCSAbZipper.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRootPath := '';
  FOnSimpleProgress := nil;
end;

procedure TJVCSAbZipper.DoConfirmProcessItem(Sender: TObject; Item: TAbArchiveItem;
  ProcessType: TAbProcessType; var Confirm: Boolean);
var
  SearchRec: TSearchRec;
  S: string;
begin
  inherited DoConfirmProcessItem(Sender, Item, ProcessType, Confirm);
  if ProcessType = ptAdd then
  begin
    if FindFirst(Item.DiskFileName, faAnyFile, SearchRec) = 0 then
    begin
      Item.LastModTimeAsDateTime := FileDateToDateTime(SearchRec.Time);
      S := '';
      if (not (soStripPath in StoreOptions)) and (FRootPath <> '') then
      begin
        S := ExtractFilePath(Item.DiskFileName);
        Delete(S, 1, Length(FRootPath));
      end;
      S := S + SearchRec.Name;
      AbFixName(S); //filename must contain / and not \
      Item.FileName := S;
      SysUtils.FindClose(SearchRec);
    end;
    if Assigned(FOnSimpleProgress) then
      FOnSimpleProgress(Self);
  end;
end;

procedure TJVCSAbZipper.SetRootPath(const AValue: string);
begin
  FRootPath := PathAddSeparator(AValue);
end;

{ JVCSCompressFile
  compresses a given source file into the temp directory and returns the file
  name of the temporary file in sCompressedFile
  if result is True, zip was succesfully created,
  CompressionType gives the to use compression type, until 2.40 only zip is
  supported
  calling function has to delete the temp file after use
  readonly files are included, dir's are stripped of from compressed file
}
function JVCSCompressFile(const sSourceFile: string; var sCompressedFile: string; CompressedType: TJVCSCompressionType = jvcsZip): Boolean;
var
  TmpPath, TmpFileName: array [0..MAX_PATH] of Char;
  // Abbrevia
  AbZipper: TJVCSAbZipper;
  FS: TFileStream;
  FSize: Integer;
begin
  GetTempPath(Length(TmpPath) - 1, TmpPath);
  GetTempFileName(TmpPath, 'JVCS', 0, TmpFileName);
  try
    // CSchuette, Mantis #2297: Do not change extension to .zip.
    // sCompressedFile := ChangeFileExt(TmpFileName, '.zip');
    sCompressedFile := TmpFileName;
    // Tweak: GetTempFileName has tmp extension, but we like zip
    //        so its better to try to delete .zip before
    //        and as we don't need .tmp, delete this immediatly
    //        (rem: if check for uniqueness is done in GetTempFileName
    //              file is created with length of zero)
    DeleteFile(PChar(sCompressedFile));
    // Create zip archive
    // @@@ToDo after 2.40 allow other compression types
    // ig
    AbZipper := TJVCSAbZipper.Create(nil);
    try
      // The following two lines are need to handle .tmp file as ZIP
      AbZipper.ArchiveType := atZip;
      AbZipper.ForceType := True;
      // ---
      AbZipper.FileName := sCompressedFile;
      AbZipper.StoreOptions := [soStripPath];
      FS := TFileStream.Create(sSourceFile, fmOpenRead or fmShareDenyWrite);
      try
        FSize := FS.Size;
        AbZipper.AddFromStream(sSourceFile, FS);
      finally
        FS.Free;
      end;
      AbZipper.Save;
      Result := (AbZipper.Count = 1) and (AbZipper.Items[0].UncompressedSize = FSize);
    finally
      AbZipper.Free;
    end;
  finally
    // DeleteFile(TmpFileName);
  end;
end;

function JVCSCompressFileList(AFileList: TStrings; const ARootDir, AZipFileName: string;
  const AStripPath: Boolean; var ASuccessCount: Integer; AOnSimpleProgress: TNotifyEvent;
  CompressedType: TJVCSCompressionType = jvcsZip): Boolean;
var
  AbZipper: TJVCSAbZipper;
  FS: TFileStream;
  FileSizes: TList;
  I: Integer;
begin
  if FileExists(AZipFileName) then
    SysUtils.DeleteFile(AZipFileName);
  ASuccessCount := 0;
  AbZipper := TJVCSAbZipper.Create(nil);
  try
    // The following two lines are need to handle .tmp file as ZIP
    AbZipper.ArchiveType := atZip;
    AbZipper.ForceType := True;
    // ---
    AbZipper.FileName := AZipFileName;
    if AStripPath then
      AbZipper.StoreOptions := [soStripPath]
    else
      AbZipper.StoreOptions := [];
    AbZipper.CompressionMethodToUse := smDeflated;
    AbZipper.DeflationOption := doMaximum;
    AbZipper.RootPath := ARootDir;
    AbZipper.OnSimpleProgress := AOnSimpleProgress;
    FileSizes := TList.Create;
    try
      for I := 0 to Pred(AFileList.Count) do
      begin
        FS := TFileStream.Create(AFileList[I], fmOpenRead or fmShareDenyWrite);
        try
          AbZipper.AddFromStream(AFileList[I], FS);
          FileSizes.Add(Pointer(FS.Size));
        finally
          FS.Free;
        end;
      end;
      AbZipper.Save;
      Result := AbZipper.Count = FileSizes.Count;
      if Result then
        for I := 0 to Pred(FileSizes.Count) do
          if AbZipper.Items[I].UncompressedSize = Integer(FileSizes[I]) then
            Inc(ASuccessCount)
          else
          begin
            Result := False;
            Break;
          end;
    finally
      FileSizes.Free;
    end;
  finally
    AbZipper.Free;
  end;
end;

{ TJVCSClientObject private }

function TJVCSClientObject.GetUserData(Index: Integer): Integer;
begin
  case Index of
    0:
      Result := PUserData(FUserData)^.UserID;
    1:
      Result := PUserData(FUserData)^.TransactionID;
    else
      Result := -1;
  end;
end;

{ TJVCSClientObject protected }

procedure TJVCSClientObject.DoExecute;
begin
  if (FUserData <> 0) and Assigned(FAppSrvClient) then
    with FAppSrvClient do
    begin
      Request.AppendFields([TransactionID]);
      Request.AppendFields([UserID]);
    end;
end;

procedure TJVCSClientObject.RequestDone(Sender: TObject; Error: Integer);
var
  AppSrvResultStatus: Integer;
begin
  if Error = 0 then
  begin
    if Assigned(Sender) and (Sender is TAppSrvClient) then
    begin
      with TAppSrvClient(Sender) do
        AppSrvResultStatus := StrToInt(AnswerStatus);

      if FHandleResultSibling then
      begin
        inherited RequestDone(Sender, Error);
      end
      else
      begin
        case AppSrvResultStatus of
          200:
            inherited RequestDone(Sender, Error);
          400:
            raise EJVCSClientRequestError.CreateFmt(SBadRequest, [FFunctionCode, AppSrvResultStatus], AppSrvResultStatus);
          403:
            raise EJVCSClientRequestError.CreateFmt(SRequestForbidden, [FFunctionCode, AppSrvResultStatus], AppSrvResultStatus);
          else
            raise EJVCSClientRequestError.CreateFmt(SRequestRejected, [FFunctionCode, AppSrvResultStatus], AppSrvResultStatus);
        end;
      end;
    end;
  end
  else
    raise EJVCSClient.CreateFmt(SRequestFailed, [FFunctionCode, Error, string(ErrorMsg)]);
end;

{ TJVCSClientObject public }

procedure TJVCSClientObject.CopyFromReference(Reference: TClientObject);
begin
  inherited CopyFromReference(Reference);
  if Assigned(Reference) and (Reference is TJVCSClientObject) then
    FRequestTimeout := TJVCSClientObject(Reference).FRequestTimeout;
end;

constructor TJVCSClientObject.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRequestTimeout := g_DefReqTimeout;
  FHandleResultSibling := False;
end;

function TJVCSClientObject.BlobAsText(Stream: TStream; ShowBlob: Boolean = True): string;
var
  AbZipArchive: TAbZipArchive;
  AbZipItem: TAbZipItem;
  SS: TStringStream;
begin
  // No extract of Blob
  if not ShowBlob then
  begin
    Result := '*BLOB*';
    Exit;
  end;

  // IF is a ZipFile
  if VerifyZip(Stream) = atZip then
  begin
    AbZipArchive := TAbZipArchive.CreateFromStream(Stream, 'AbArchive');
    try
      AbZipArchive.Load;
      if AbZipArchive.ItemList.Count > 0 then
      begin
        AbZipArchive.ExtractOptions :=  [eoCreateDirs, eoRestorePath];
        AbZipItem := AbZipArchive.Items[0];
        SS := TStringStream.Create('');
        try
          AbUnzipToStream(AbZipArchive, AbZipItem, SS);
          Result := SS.DataString;
        finally
          SS.Free;
        end;
      end;
    finally
      AbZipArchive.Free;
    end;
  end
  else
  begin
    Stream.Seek(0, soFromBeginning);
    SetLength(Result, Stream.Size);
    Stream.Read(Result[1], Stream.Size);
  end;
end;

procedure TJVCSClientObject.BuildFunctionCode;
begin
  FFunctionCode := GetFunctionCode(TClientObjectClass(ClassType));
end;

procedure TJVCSClientObject.Execute;
begin
  inherited Execute;
  DoExecute;
  if Assigned(FAppSrvClient) then
  begin
    FAppSrvClient.Send;

    if not WaitForAnswer(FRequestTimeout) then
      raise EJVCSClient.CreateFmt(SRequestTimedOut, [FFunctionCode]);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TJVCSClientObject.ExtractBlobToDir(const TargetDir: string; Stream: TStream);
var
  sFile: string;
  AbZipArchive: TAbZipArchive;
  AbZipItem: TAbZipItem;
begin
  // IF is a ZipFile
  if VerifyZip(Stream) = atZip then
  begin
    AbZipArchive := TAbZipArchive.CreateFromStream(Stream, 'AbArchive');
    try
      AbZipArchive.Load;
      if AbZipArchive.ItemList.Count > 0 then
      begin
        AbZipArchive.ExtractOptions :=  [eoCreateDirs, eoRestorePath];
        AbZipItem := AbZipArchive.Items[0];
        sFile := PathAddSeparator(TargetDir) + AbZipItem.FileName;
        ExtractBlobToFile(sFile, Stream);
      end;
    finally
      AbZipArchive.Free;
    end;
  end;
end;

procedure TJVCSClientObject.ExtractBlobToFile(const AFileName: string; Stream: TStream);
const
  PKZipHeader = $04034B50;
var
  sFile: string;
  AbZipArchive: TAbZipArchive;
  AbZipItem: TAbZipItem;
  FSOut: TFileStream;
begin
  // IF is a ZipFile
  if VerifyZip(Stream) = atZip then
  begin
    AbZipArchive := TAbZipArchive.CreateFromStream(Stream, 'AbArchive');
    try
      AbZipArchive.Load;
      if AbZipArchive.ItemList.Count > 0 then
      begin
        AbZipArchive.ExtractOptions :=  [eoCreateDirs, eoRestorePath];
        AbZipItem := AbZipArchive.Items[0];
        if SameText(AbZipItem.FileName, ExtractFileName(AFileName)) then
          sFile := ExtractFilePath(AFileName) + AbZipItem.FileName
        else
          sFile := AFileName;
        try
          // set readwrite!
          FileSetReadOnlyAttribute(sFile, False);
        except
        end;
        FSOut := TFileStream.Create(sFile, fmCreate);
        try
          AbUnzipToStream(AbZipArchive, AbZipItem, FSOut);
          FileSetDate(FSOut.Handle, DateTimeToFileDate(AbZipItem.LastModTimeAsDateTime));
        finally
          FSOut.Free;
        end;
        // set to read-only here, as here we do not know if we make a
        // sync (get ro), checkout (get rw), be aware in client to remove
        // ro-flag later
        try
          FileSetReadOnlyAttribute(sFile, True);
        except
        end;
      end;
    finally
      AbZipArchive.Free;
    end;
  end;
end;

function TJVCSClientObject.ExtractBlobToStream(ASourceStream, ADestStream: TStream): Boolean;
var
  AbZipArchive: TAbZipArchive;
  AbZipItem: TAbZipItem;
begin
  Result := False;
  // IF is a ZipFile
  if VerifyZip(ASourceStream) = atZip then
  begin
    AbZipArchive := TAbZipArchive.CreateFromStream(ASourceStream, 'AbArchive');
    try
      AbZipArchive.Load;
      if AbZipArchive.ItemList.Count > 0 then
      begin
        AbZipItem := AbZipArchive.Items[0];
        AbUnzipToStream(AbZipArchive, AbZipItem, ADestStream);
        Result := True;
      end;
    finally
      AbZipArchive.Free;
    end;
  end;
end;

procedure TJVCSClientObject.LogResults(Strings: TStrings; ShowBlobs: Boolean = False);
begin
  // do nothing
end;

{$IFNDEF NOFORMS}
function TJVCSClientObject.ShowInputForm: TModalResult;
begin
  Result := mrOK;
end;
{$ENDIF ~NOFORMS}

function TJVCSClientObject.WaitForAnswer(Timeout: Integer): Boolean;
var
  TimeoutTick: Cardinal;
begin
  // testing
  Result := inherited WaitForAnswer(Timeout);
  Exit;

  if Timeout < 0 then
    Timeout := 0;
  TimeoutTick := GetTickCount + Cardinal(Timeout);
  while TimeoutTick > GetTickCount do
  begin
    if FAnswerArrived then
      Break;
    if Assigned(FAppSrvClient) and Assigned(FAppSrvClient.ClientSocket) then
    begin
      FAppSrvClient.ClientSocket.ProcessMessages;
      if FAppSrvClient.State = cstReady then
        Break;
    end;
    Sleep(0);
  end;
  Result := FAnswerArrived;
  if not Result then
    if Assigned(FAppSrvClient) then
      FAppSrvClient.Close;
end;

end.
