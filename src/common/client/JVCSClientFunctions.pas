(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSClientFunctions.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
ToDo
- improve GetAgeStr(language support -> see http://dybdahl.dk/dxgettext/docs/online/pluralforms.html)
- test GetAge
- positive effect of the change in MatchWithFilter from 0.7 -> 0.8? (negative: it was not possible to compare binary .dfm's)
-----------------------------------------------------------------------------

Unit history:

2003/12/13  USchuster - new unit (new home for some common client functions)
2003/12/27  THuber    - moved two functions from VCSProcBase for use in
                        JVCSConnect.pas.
2005/04/11  CSchuette - added functions for UTC timestamps (mantis #2815)
2005/04/12  USchuster - moved MatchWithFilter from VCSProcBase (mantis #2857)
2005/04/14  USchuster/CSchuette - fixed error wirth UTC timestamps (mantis #2815
                        and #2872) and IsUTCVolume (on Win 9x)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 released ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
2006/04/30  THuber    #3611 new function to copy files from source to dest folder
2006/04/30  USchuster - D5 fix
            THuber    - D5 fix over jcl
2006/11/29  USchuster - added GetAgeStr(moved DateToDiffStr from ListFilesTest.pas)
2006/12/10  USchuster - moved IsBinaryFile and IsBinaryDFMStream from VCSProcBase.pas
                        and published IsTextStream (was an embedded function of IsBinaryFile)
                      - reverted the MatchWithFilter change from revision 0.8
2007/02/18  USchuster - improved GetAgeStr (now "1 year" and not "1 years")
2007/08/15  USchuster - added GetAge2Str
2008/09/28  USchuster - added overloaded version IsFileDirtyCRC which return the local CRC
2009/12/26  THuber    - improved functions to handle alwayswritable files.

-----------------------------------------------------------------------------*)

unit JVCSClientFunctions;

{$I jedi.inc}

interface

uses
  SysUtils, Classes, Windows, Math;

type
  TJVCSCompareFileTimeStampResult = (cmptsresFileNotFound, cmptsresEqual, cmptsresNewer, cmptsresOlder);

function CompareFileTimeStamp(const AFileName: string; ARefStamp: TDateTime): TJVCSCompareFileTimeStampResult;
function FileSetReadOnlyAttribute(const AFileName: string; ASetReadOnly: Boolean): Boolean;
function IsUTCVolume(const FileName: string): Boolean;
function FileSetUTCDateTime(const FileName: string; UTCDateTime: TDateTime): Boolean;
function FileGetUTCDateTime(const FileName: string): TDateTime;
function GetNowUTC: TDateTime;
function IsFileDirty(const FileName: string; RefStamp: TDateTime): Boolean;
function IsFileDirtyCRC(const FileName: string; RefCRC: Integer): Boolean; overload;
function IsFileDirtyCRC(const FileName: string; RefCRC: Integer; var LocalCRC: Integer): Boolean; overload;
function GetAgeStr(ADateTime: TDateTime): string;
function GetAge2Str(ADateTime: TDateTime): string;

// Moved from VCSProcBase
function GetSelfFileName: string;
function GetSelfFileLocation: string;
function IsBinaryDFMStream(AStream: TStream): Boolean;
function IsBinaryFile(const FileName: string): Boolean;
function IsTextStream(Stream: TStream): Boolean;
function MatchWithFilter(Name, Filter: string): Boolean;

function FileCopyFiles(const Source, Destination: string; const ReplaceExisting: Boolean = False): Boolean;

// Moved from jvcs.dpr
function GetAlwaysWritableFileTypes : String;
function IsFileTypeAlwaysWritable(const FileExt: string): Boolean;

implementation

uses
  Registry, JVCSClientConsts, Checksum, TZHandling, JclStrings, JclFileUtils;

// -----------------------------------------------------------------------------
function FileSetReadOnlyAttribute(const AFileName: string; ASetReadOnly: Boolean): Boolean;
{$IFNDEF DELPHI6_UP}
var
  FAttr, FNewAttr: Integer;
{$ENDIF ~DELPHI6_UP}
begin
  {$IFDEF DELPHI6_UP}
  Result := SysUtils.FileSetReadOnly(AFileName, ASetReadOnly);
  {$ELSE}
  FAttr := FileGetAttr(AFileName);
  if FAttr <> -1 then
  begin
    FNewAttr := FAttr;
    if ASetReadOnly then
      FNewAttr := FNewAttr or faReadOnly
    else
    if FAttr and faReadOnly = faReadOnly then
      FNewAttr := FNewAttr - faReadOnly;
    if FAttr <> FNewAttr then
      Result := FileSetAttr(AFileName, FNewAttr) = 0
    else
      Result := True;
  end
  else
    Result := False;
  {$ENDIF DELPHI6_UP}
end;

// -----------------------------------------------------------------------------
function IsUTCVolume(const FileName: string): Boolean;
var
  Buf, Drv: string;
  FileSystem: array [0..15] of Char;
  ErrorMode: Cardinal;
  MaximumComponentLength, FileSystemFlags: DWord;
begin
  Result := False;
  ErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    Drv := ExtractFileDrive(ExpandFileName(FileName));
    if Drv <> '' then
    begin
      if Drv[Length(Drv)] <> '\' then
        Drv := Drv + '\';
      if Windows.GetVolumeInformation(PChar(Drv), nil, 0, nil, MaximumComponentLength, FileSystemFlags, FileSystem, SizeOf(FileSystem)) then
      begin
        Buf := StrPas(FileSystem);
        if SameText(Buf, 'NTFS') or SameText(Buf, 'HPFS') or SameText(Buf, 'OWFS') then
          Result := True;
      end;
    end;
  finally
    SetErrorMode(ErrorMode);
  end;
end;

// -----------------------------------------------------------------------------
function FileSetUTCDateTime(const FileName: string; UTCDateTime: TDateTime): Boolean;
var
  Handle: THandle;
  SysTime: TSystemTime;
  FileTime: TFileTime;
  UTC: Boolean;
begin
  Result := False;

  Handle := FileOpen(FileName, fmOpenWrite);
  if Handle = THandle(-1) then
    Exit;
  try
    UTC := IsUTCVolume(FileName);
    if not UTC then
      UTCDateTime := GMTDT2LocalDT(UTCDateTime);
    SysUtils.DateTimeToSystemTime(UTCDateTime, SysTime);
    if Windows.SystemTimeToFileTime(SysTime, FileTime) then
    begin
      if not UTC then
        Windows.LocalFileTimeToFileTime(FileTime, FileTime);
      Result := SetFileTime(Handle, nil, nil, @FileTime);
    end;
  finally
    FileClose(Handle);
  end;
end;

// -----------------------------------------------------------------------------
function FileGetUTCDateTime(const FileName: string): TDateTime;
var
  Handle: THandle;
  SysTime: TSystemTime;
  FindData: TWin32FindData;
  UTC: Boolean;
begin
  Handle := FindFirstFile(PChar(FileName), FindData);
  if Handle <> INVALID_HANDLE_VALUE then
  begin
    Windows.FindClose(Handle);
    if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then
    begin
      UTC := IsUTCVolume(FileName);
      if not UTC then
        Windows.FileTimeToLocalFileTime(FindData.ftLastWriteTime, FindData.ftLastWriteTime);
      if Windows.FileTimeToSystemTime(FindData.ftLastWriteTime, SysTime) then
      begin
        Result := SysUtils.SystemTimeToDateTime(SysTime);
        if not UTC then
          Result := LocalDT2GMTDT(Result);
        Exit;
      end;
    end;
  end;
  Result := -1;
end;

// -----------------------------------------------------------------------------
function GetNowUTC: TDateTime;
var
  SystemTime: TSystemTime;
begin
  GetSystemTime(SystemTime);
  with SystemTime do
    Result := EncodeDate(wYear, wMonth, wDay) + EncodeTime(wHour, wMinute, wSecond, wMilliseconds);
end;

// -----------------------------------------------------------------------------
//modified (changed result to enumeration) version of HowIsFileDirty from jvcs.dpr
function CompareFileTimeStamp(const AFileName: string; ARefStamp: TDateTime): TJVCSCompareFileTimeStampResult;
var
  FileStamp: TDateTime;
begin
  FileStamp := FileGetUTCDateTime(AFileName);
  if Abs(FileStamp - ARefStamp) > cTimeConvErr then
  begin
    if FileStamp > ARefStamp then
      Result := cmptsresNewer
    else
      Result := cmptsresOlder;
  end
  else
    Result := cmptsresEqual;
end;

// -----------------------------------------------------------------------------
function IsFileDirty(const FileName: string; RefStamp: TDateTime): Boolean;
begin
{//USc 13.12.2003 old version from jvcs.dpr
  Result := True;
  if FileExists(FileName) then
  begin
    //THu be aware if server/client live in different timezones !
    Result := Abs(LocalDT2GMTDT(FileDateToDateTime(FileAge(FileName))) - RefStamp) > cTimeConvErr;
  end;
}
  Result := CompareFileTimeStamp(FileName, RefStamp) <> cmptsresEqual;
end;

// -----------------------------------------------------------------------------

function IsFileDirtyCRC(const FileName: string; RefCRC: Integer): Boolean;
var
  Dummy: Integer;
begin
  Result := IsFileDirtyCRC(FileName, RefCRC, Dummy);
end;

function IsFileDirtyCRC(const FileName: string; RefCRC: Integer; var LocalCRC: Integer): Boolean;
var
  sErr: string;
begin
//THu  Result := (FileCRC(FileName) <> RefCRC);
  LocalCRC := 0;
  Result := False;
  try
    LocalCRC := CRCInt(FileName, sErr);
    Result := LocalCRC <> RefCRC;
  except
  end;
end;

function GetAgeStr(ADateTime: TDateTime): string;
var
  DateDiff, LNow: TDateTime;
  y1, m1, y2, m2, dummy: Word;
  ym1, ym2: DWord;
  AgeAmount: Integer;
  SingularAgeStr, PluralAgeStr: string;
begin
  LNow := Now;
  DateDiff := LNow - ADateTime;
  if DateDiff < 0 then
  begin
    AgeAmount := -1;
    SingularAgeStr := 'future';
  end
  else
  if DateDiff < (1 / (24 * 60 * 60)) then
  begin
    AgeAmount := -1;
    SingularAgeStr := 'now';
  end
  else
  if DateDiff < (1 / (24 * 60)) then
  begin
    AgeAmount := Round(DateDiff * 24 * 60 * 60);
    SingularAgeStr := 'second';
    PluralAgeStr := 'seconds';
  end
  else
  if DateDiff < (1 / 24) then
  begin
    AgeAmount := Round(DateDiff * 24 * 60);
    SingularAgeStr := 'minute';
    PluralAgeStr := 'minutes';
  end
  else
  if DateDiff < 1 then
  begin
    AgeAmount := Round(DateDiff * 24);
    SingularAgeStr := 'hour';
    PluralAgeStr := 'hours';
  end
  else
  if DateDiff < 7 then
  begin
    AgeAmount := Round(DateDiff);
    SingularAgeStr := 'day';
    PluralAgeStr := 'days';
  end
  else
  if DateDiff < (7 * 8) then
  begin
    AgeAmount := Round(DateDiff / 7);
    SingularAgeStr := 'week';
    PluralAgeStr := 'weeks';
  end
  else
  begin
    DecodeDate(LNow, y1, m1, dummy);
    ym1 := y1 * 12 + m1;
    DecodeDate(ADateTime, y2, m2, dummy);
    ym2 := y2 * 12 + m2;
    if ym1 - ym2 < 12 then
    begin
      AgeAmount := ym1 - ym2;
      SingularAgeStr := 'month';
      PluralAgeStr := 'months';
    end
    else
    begin
      AgeAmount := (ym1 - ym2) div 12;
      SingularAgeStr := 'year';
      PluralAgeStr := 'years';
    end;
  end;
  if AgeAmount < 0 then
    Result := SingularAgeStr
  else
  if AgeAmount = 1 then
    Result := Format('%d %s', [AgeAmount, SingularAgeStr])
  else
    Result := Format('%d %s', [AgeAmount, PluralAgeStr]);
end;

type
  TGetAgeResultKind = (garkYear, garkMonth, garkWeek, garkDay, garkHour, garkMinute, garkSecond, garkNow, garkFuture);

function GetAge(ABase, ADate: TDateTime; var AResultKind: TGetAgeResultKind; var ARest: TDateTime): Integer;
var
  DateDiff: TDateTime;
  y1, m1, y2, m2, dummy: Word;
  ym1, ym2: DWord;
begin
  DateDiff := ABase - ADate;
  if DateDiff < 0 then
  begin
    Result := -1;
    ARest := 0;
    AResultKind := garkFuture;
  end
  else
  if DateDiff < (1 / (24 * 60 * 60)) then
  begin
    Result := -1;
    ARest := 0;
    AResultKind := garkNow;
  end
  else
  if DateDiff < (1 / (24 * 60)) then
  begin
    Result := Round(DateDiff * 24 * 60 * 60);
    ARest := DateDiff - Result / ( 24 * 60 * 60);
    AResultKind := garkSecond;
  end
  else
  if DateDiff < (1 / 24) then
  begin
    Result := Round(DateDiff * 24 * 60);
    ARest :=  DateDiff - Result / (24 * 60);
    AResultKind := garkMinute;
  end
  else
  if DateDiff < 1 then
  begin
    Result := Round(DateDiff * 24);
    ARest := DateDiff - Result / 24;
    AResultKind := garkHour;
  end
  else
  if DateDiff < 7 then
  begin
    Result := Round(DateDiff);
    ARest := DateDiff - Result;
    AResultKind := garkDay;
  end
  else
  if DateDiff < (7 * 8) then
  begin
    Result := Round(DateDiff / 7);
    ARest := DateDiff - Result * 7;
    AResultKind := garkWeek;
  end
  else
  begin
    DecodeDate(ABase, y1, m1, dummy);
    ym1 := y1 * 12 + m1;
    DecodeDate(ADate, y2, m2, dummy);
    ym2 := y2 * 12 + m2;
    if ym1 - ym2 < 12 then
    begin
      Result := ym1 - ym2;
      ARest := DateDiff - (30.4375 * Result);
      AResultKind := garkMonth;
    end
    else
    begin
      Result := (ym1 - ym2) div 12;
      ARest := DateDiff - (365.25 * Result);
      AResultKind := garkYear;
    end;
  end;
  if ARest < 0 then
    ARest := 0;
end;

function GetAgeResultToStr(AnAgeInt: Integer; AResultKind: TGetAgeResultKind; ALong: Boolean): string;
const
  ShortSingularNames: array[Low(TGetAgeResultKind)..High(TGetAgeResultKind)] of string =
    ('yr', 'mo', 'wk', 'dy', 'hr', 'mn', 'sc', 'now', 'future');
  ShortPluralNames: array[Low(TGetAgeResultKind)..High(TGetAgeResultKind)] of string =
    ('yrs', 'mos', 'wks', 'dys', 'hrs', 'min', 'sc', 'now', 'future');
  LongSingularNames: array[Low(TGetAgeResultKind)..High(TGetAgeResultKind)] of string =
    ('year', 'month', 'week', 'day', 'hour', 'minute', 'second', 'now', 'future');
  LongPluralNames: array[Low(TGetAgeResultKind)..High(TGetAgeResultKind)] of string =
    ('years', 'months', 'weeks', 'days', 'hours', 'minutes', 'seconds', 'now', 'future');
var
  S: string;
begin
  if (AnAgeInt < 2) and ALong then
    S := LongSingularNames[AResultKind]
  else
  if ALong then
    S := LongPluralNames[AResultKind]
  else
  if AnAgeInt < 2 then
    S := ShortSingularNames[AResultKind]
  else
    S := ShortPluralNames[AResultKind];
  Result := Format('%d %s', [AnAgeInt, S]);
end;

function GetAge2Str(ADateTime: TDateTime): string;
var
  LNow, DateDiffRest: TDateTime;
  ResultKind: TGetAgeResultKind;
  Age: Integer;
begin
  LNow := Now;
  Age := GetAge(LNow, ADateTime, ResultKind, DateDiffRest);
  Result := GetAgeResultToStr(Age, ResultKind, False);
  if DateDiffRest > 0 then
  begin
    Age := GetAge(LNow, LNow - DateDiffRest, ResultKind, DateDiffRest);
    Result := Result + ' ' + GetAgeResultToStr(Age, ResultKind, False);
  end;
end;

// -----------------------------------------------------------------------------
function GetSelfFileName: string;
var
  ModName: array [0..MAX_PATH] of Char;
begin
  SetString ( Result
            , ModName
            , Windows.GetModuleFileName(HInstance, ModName, SizeOf(ModName))
            );
end;

// -----------------------------------------------------------------------------
function GetSelfFileLocation: string;
begin
  Result := ExtractFilePath(GetSelfFileName);
end;

function IsBinaryDFMStream(AStream: TStream): Boolean;
const
  MaxLineLength = 255;
var
  Count: Integer;
  OldPos: Integer;
  LineBuffer: array [0..MaxLineLength] of Char;
  str: string;
begin
  Result := True;
  if Assigned(AStream) then
  begin
    OldPos := AStream.Position;
    FillChar(LineBuffer, SizeOf(LineBuffer), 0);
    Count := Min(MaxLineLength, AStream.Size - AStream.Position);
    if Count > 0 then
    begin
      AStream.Read(LineBuffer, Count);
      str := UpperCase(StrPas(LineBuffer));
      Result := not ((Pos('INHERITED', str) = 1) or (Pos('OBJECT', str) = 1));
//the other method to determine the type could be checking the first byte
//binary DFM's start with #FF
    end;
    AStream.Position := OldPos;
  end;
end;

function IsBinaryFile(const FileName: string): Boolean;
var
  S: TStream;
begin
  Result := True;
  if not FileExists(FileName) then
    Exit;

  S := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  try
    Result := not IsTextStream(S);
  finally
    S.Free;
  end;
end;

function IsTextStream(Stream: TStream): Boolean;
const
  MaxLineLength = 255;
var
  LineBuffer: array [0..MaxLineLength] of Char;
  CharFlags: array of Word;
  I, Count: Integer;
  P, S: PChar;
begin
  Result := False;
  FillChar(LineBuffer, SizeOf(LineBuffer), 0);
  Stream.Position := 0;
  if Stream.Size > MaxLineLength then
    Count := MaxLineLength
  else
    Count := Stream.Size;
  Stream.Read(LineBuffer, Count);
  // see if we can come up with an EOL (unless we read the whole file)
  if Count < Stream.Size then
  begin
    P := StrPos(LineBuffer, #13);
    if P = nil then
      Exit;
    // terminate the string here
    P^ := #0;
    // check if there are any terminators prior to where we expect the EOL
    S := @LineBuffer;
    while S < P do
    begin
      if S^ = #0 then
        Exit;
      Inc(S);
    end;
  end;
  Count := StrLen(LineBuffer);
  if Count > 0 then
  begin
    // some editors place a $1A (26) as an EOF marker
    if LineBuffer[Count - 1] = Char($1A) then
    begin
      LineBuffer[Count - 1] := #0;
      Dec(Count);
    end;
    // if first character is $FF, then it's likely not text
    if LineBuffer[0] = Char($FF) then
      Exit;
    // get the char flags
    SetLength(CharFlags, Count);
    GetStringTypeEx(LOCALE_USER_DEFAULT, CT_CTYPE1, LineBuffer, Count,
      CharFlags[0]);
    // check the CharFlags array to see if anything looks fishy
    for I := Low(CharFlags) to High(CharFlags) do
      if ((CharFlags[I] and C1_CNTRL) <> 0) and ((CharFlags[I] and $0F) = 0) then
        Exit;
  end;
  // best guess is that it looks reasonable
  Result := True;
end; // function IsTextStream(Stream: TStream): Boolean;

// Ext im Format .ext !
function MatchWithFilter(Name, Filter: string): Boolean;
var
  CurrPattern: string;
{//old implementation caused mantis #2825
 //keep here as reminder -> compare with jvcs.dpr and move to JVCSClientFunction.pas
  function Match(TestStr, MaskStr: string): Boolean;
  var
    I, J: Integer;
  begin
    Result := True;
    try
      TestStr := AnsiLowerCase(TestStr);
      MaskStr := AnsiLowerCase(MaskStr);
      I := 0;
      J := 0;
      if (Pos('*', MaskStr) = 0) and (Length(MaskStr) <> Length(TestStr)) then
        Result := False
      else
      begin
        repeat // until (not Result) or...
          Inc(I);
          Inc(J);
          if MaskStr[I] = '*' then
          begin
            // '*' = last position of MaskStr?
            if (I < Length(MaskStr)) then
            begin // no
              Inc(I);
              while (J < Length(TestStr)) and
                (MaskStr[I] <> TestStr[J]) do
                Inc(J);
              Result := (MaskStr[I] = TestStr[J]);
            end;
          end // if MaskStr[I] = '*' then begin
          else
          begin
            if (MaskStr[I] <> '?') then
              Result := (MaskStr[I] = TestStr[J]);
          end;
        until (not Result) or
          (J >= Length(TestStr)) or (I >= Length(MaskStr));
      end; // else if (Pos('*', MaskStr) = 0) and...
      if Result then
        if (MaskStr[I] <> '*') then
          Result := (J = Length(TestStr)) and (I = Length(MaskStr));
    except
      Result := False;
    end;
  end; // function Match(...
}
begin
  Result := False;
  if (Name = '') or (Filter = '') then
    Exit;
  if Filter[Length(Filter)] <> ';' then
    Filter := Filter + ';';
  while Pos(';', Filter) > 0 do
  begin
    CurrPattern := Copy(Filter, 1, Pos(';', Filter) - 1);
    Delete(Filter, 1, Pos(';', Filter));
//  if Match(Name, CurrPattern) then ////old implementation caused mantis #2825
    if StrMatches(AnsiLowerCase(CurrPattern), AnsiLowerCase(Name)) then
    begin
      Result := True;
      Exit;
    end; // if CurrExt = Ext then begin
  end; // while Pos(';', Filter) > 0 do begin
end;

// Copy files from source to destination directory
// If replace exsting files are overwritten
// used eg. to copy JVCS config files
function FileCopyFiles(const Source, Destination: string; const ReplaceExisting: Boolean = False): Boolean;
var
  SourceDir, DestinationDir: string;
  SourceFiles: TStringList;
  ii: Integer;
begin
  Result := False;
  if JclFileUtils .DirectoryExists(Source) and (Trim(Destination) <> '') then
  begin
    JclFileUtils.ForceDirectories(Destination);
    SourceDir := PathAddSeparator(Source);
    DestinationDir := PathAddSeparator(Destination);
    SourceFiles := TStringList.Create;
    try
      if JclFileUtils.BuildFileList(SourceDir + '*.*',faAnyFile, SourceFiles) then
      begin
        for ii := 0 to SourceFiles.Count - 1 do
        begin
          JclFileUtils.FileCopy(SourceDir + SourceFiles[ii], DestinationDir + SourceFiles[ii], ReplaceExisting);
        end;
        Result := True;
      end;
    finally
      SourceFiles.Free;
    end;
  end;
end;

// -----------------------------------------------------------------------------
//
// FileExt must be in the format '.extension', not '*.extension'!
//
function IsFileTypeAlwaysWritable(const FileExt: string): Boolean;
begin
  Result := MatchWithFilter('a'+Trim(FileExt), GetAlwaysWritableFileTypes);
end;

// -----------------------------------------------------------------------------
// TODO clean ConfigStorage for use in console client and use functions from there
//
function GetAlwaysWritableFileTypes : String;
var
  sBaseRegistryKey: string;
begin
  // Defaults
  result := dfNotReadOnly;
  sBaseRegistryKey := '';

  // get JEDIVCS base key
  with TRegistry.Create do
  begin
    rootKey := HKEY_CURRENT_USER;
    try
      if OpenKeyReadOnly('Software\JEDI\JEDIVCS') then
      begin
        if ValueExists('BaseRegistryKey') then
        begin
          sBaseRegistryKey := ReadString('BaseRegistryKey');
        end;
        CloseKey;
      end;
    finally
      Free;
    end; // try finally
  end;

  if sBaseRegistryKey <> '' then
  begin
    // Get fileextensions for always writeable files
    with TRegistry.Create do
    begin
      rootKey := HKEY_CURRENT_USER;
      try
        if OpenKeyReadOnly(sBaseRegistryKey + '\Mask') then
        begin
          if ValueExists('Writeable Files') then
          begin
            result := ReadString('Writeable Files');
          end;
          CloseKey;
        end;
      finally
        Free;
      end; // try finally
    end; // with Reg do begin
  end;
end;
end.
