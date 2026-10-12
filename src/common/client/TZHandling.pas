(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: TZHandling.pas

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
2003/02/09  WKlein    - Removed unnecessary exception within IDE
                        (introduced SystemTimeToDateTimeNew)
2003/02/13  USchuster - D5 Fix
2003/10/05  THuber    - compiler hints & warnings
                        (fixed SystemTimeToDateTimeNew)
2003/10/27  USchuster - changes for use in CONSOLE Client to avoid
                        different versions
2007/08/13  USchuster - Trace -> TraceMsg
                      - minor stylecleaning
2012/11/23  USchuster - Fixed Unicode and FormatSettings warnings

-----------------------------------------------------------------------------*)

unit TZHandling;

{$I jedi.inc}
{$I compopt.inc}

interface

function LocalDT2GMTDT(const LocalDT: TDateTime): TDateTime;
function GMTDT2LocalDT(const GMTDT: TDateTime): TDateTime;
function GMTStr2LocalDateTime(GMTStr: string): TDateTime;
function LocalDT2GMTStr(const LocalDT: TDateTime): string;
function GetClientGMTDiff: Single;

implementation

uses
  Windows, SysUtils
  {$IFDEF DEBUG}
  , JclDebug
  {$ENDIF DEBUG}
  {$IFNDEF JVCSCONSOLECLIENT}
  , VCSBase
  {$ENDIF ~JVCSCONSOLECLIENT}
  ;

{$IFDEF JVCSCONSOLECLIENT}
const
  ShowDebugMsg = True;
  cPrgType = 'JVCSConsole: ';
{$ENDIF JVCSCONSOLECLIENT}

var
  TimeZoneInfo: TTimeZoneInformation;
  StdTime, DayTime: TDateTime;

{$IFNDEF DELPHI6_UP}
function TryEncodeDate(Year, Month, Day: Word; out ADate: TDateTime): Boolean;
begin
  Result := False;
  try
    ADate := EncodeDate(Year, Month, Day);
    Result := True;
  except
  end;
end;

function TryEncodeTime(Hour, Min, Sec, MSec: Word; out ATime: TDateTime): Boolean;
begin
  Result := False;
  try
    ATime := EncodeTime(Hour, Min, Sec, MSec);
    Result := True;
  except
  end;
end;
{$ENDIF ~DELPHI6_UP}  

function SystemTimeToDateTimeNew(const SystemTime: TSystemTime): TDateTime;
var
  D, T: TDateTime;
begin
  with SystemTime do
    if TryEncodeDate(wYear, wMonth, wDay, D) and
      TryEncodeTime(wHour, wMinute, wSecond, wMilliseconds, T) then
    //thu 05.10.2003 ??? unclear about next commented lines but result is undefined!!!
    (*
      if Result>=0 then
        Result := d+t
      else
        Result := d-t
    *)
      Result := D + T
    else
      Result := -1;
end;

  (******************************************************************************)
(* calculate the range of daylight (DayTime -> StdTime) related to the year
   given by DT - code by Gary Brightwell gary.brightwell@realtime.co.nz *)
procedure CalculateDayLightRange(DT: TDateTime);
var
  CalcSysTime: SYSTEMTIME;
  iDayofWeek: Integer;
begin
  DateTimeToSystemTime(DT, CalcSysTime);
  if TimeZoneInfo.StandardDate.wYear = 0 then
  begin
    // structure stores DST etc using no year
    // but dayofweek and which occurance in month

    // check if the wMonth member in standard date is defined
    // to be sure that there *is* a transition date defined
    // (in W95, GetTimeZoneInformation may return TIME_ZONE_ID_STANDARD,
    // although there is no standard date...)
    if (TimeZoneInfo.StandardDate.wMonth = 0) then 
    begin
      // not defined -> use standart bias
      StdTime := 0;
      DayTime := 0;
      Exit;
    end;

    // wMonth is nonzero, go right ahead with the calculation
    CalcSysTime.wMonth := TimeZoneInfo.StandardDate.wMonth;
    CalcSysTime.wDay := 1;
    StdTime := SystemTimeToDateTime(CalcSysTime);
    iDayofWeek := DayofWeek(StdTime);
    Dec(iDayofWeek);  // same format as systime dayofweek structure
    if iDayofWeek > TimeZoneInfo.StandardDate.wDayOfWeek then
      CalcSysTime.wDay := TimeZoneInfo.StandardDate.wDayOfWeek - iDayofWeek + +1 + (TimeZoneInfo.StandardDate.wDay) * 7
    else
      CalcSysTime.wDay := TimeZoneInfo.StandardDate.wDayOfWeek - iDayofWeek + +1 +
        (TimeZoneInfo.StandardDate.wDay - 1) * 7;
    CalcSysTime.wHour := TimeZoneInfo.StandardDate.wHour;
    CalcSysTime.wMinute := TimeZoneInfo.StandardDate.wMinute;
    CalcSysTime.wSecond := TimeZoneInfo.StandardDate.wSecond;
    CalcSysTime.wMilliseconds := TimeZoneInfo.StandardDate.wMilliseconds;
    try
      StdTime := SystemTimeToDateTimeNew(CalcSysTime);
      if StdTime = -1 then
      begin
        // wDay must have = 5 which means last week of the month so subtract 7
        CalcSysTime.wDay := CalcSysTime.wDay - 7;
        StdTime := SystemTimeToDateTime(CalcSysTime);
      end;
    except
      {$IFDEF DEBUG}
      if ShowDebugMsg then
        JclDebug.TraceMsg(PChar(cPrgType +
          'Unable to calculate Daylight -> Standard date transition' + #0));
      {$ENDIF DEBUG}
    end;
    StdTime := SystemTimeToDateTime(CalcSysTime);

    CalcSysTime.wMonth := TimeZoneInfo.DaylightDate.wMonth;
    CalcSysTime.wDay := 1;
    DayTime := SystemTimeToDateTime(CalcSysTime);
    iDayofWeek := DayofWeek(DayTime);
    Dec(iDayofWeek);
    // same range as systemtime.dayofweek variable
    if iDayofWeek > TimeZoneInfo.DaylightDate.wDayOfWeek then
      CalcSysTime.wDay := 1 + TimeZoneInfo.DaylightDate.wDayOfWeek - iDayofWeek +
        (TimeZoneInfo.DaylightDate.wDay) * 7
    else
      CalcSysTime.wDay := 1 + TimeZoneInfo.DaylightDate.wDayOfWeek - iDayofWeek +
        (TimeZoneInfo.DaylightDate.wDay - 1) * 7;
    CalcSysTime.wHour := TimeZoneInfo.DaylightDate.wHour;
    CalcSysTime.wMinute := TimeZoneInfo.DaylightDate.wMinute;
    CalcSysTime.wSecond := TimeZoneInfo.DaylightDate.wSecond;
    CalcSysTime.wMilliseconds := TimeZoneInfo.DaylightDate.wMilliseconds;
    try
      DayTime := SystemTimeToDateTimeNew(CalcSysTime);
      if DayTime = -1 then
      begin
        // wDay must have = 5 which means last week of the month so subtract 7
        CalcSysTime.wDay := CalcSysTime.wDay - 7;
        DayTime := SystemTimeToDateTime(CalcSysTime);
      end;
    except
      {$IFDEF DEBUG}
      if ShowDebugMsg then
        JclDebug.TraceMsg(PChar(cPrgType +
          'Unable to calculate Standard -> Daylight date transition' + #0));
      {$ENDIF DEBUG}
    end;
  end
  else
  begin
    // structure stores DST etc using year
    StdTime := SystemTimeToDateTime(TimeZoneInfo.StandardDate);
    DayTime := SystemTimeToDateTime(TimeZoneInfo.DaylightDate);
  end;
end;
(******************************************************************************)
(* calculate the local time zone bias related to the year given by DT
   (in minutes) *)

function CalculateTimeZoneBias(DT: TDateTime): Integer;
begin
  case GetTimeZoneInformation(TimeZoneInfo) of
    TIME_ZONE_ID_UNKNOWN:
      Result := TimeZoneInfo.Bias;
    TIME_ZONE_ID_STANDARD, TIME_ZONE_ID_DAYLIGHT:
      begin
        CalculateDayLightRange(DT);
        if (DT >= DayTime) and (DT < StdTime) then
          Result := TimeZoneInfo.Bias + TimeZoneInfo.DaylightBias
        else
          Result := TimeZoneInfo.Bias + TimeZoneInfo.StandardBias;
      end;
    else
      Result := 0;
  end;
end;
(******************************************************************************)
(* retrieve the current GMT difference (in hours) *)

function GetClientGMTDiff: Single;
begin
  Result := -1 * (CalculateTimeZoneBias(Now) / 60);
end;
(******************************************************************************)
(* convert local dates to GMT related to Daylight/Standard settings *)

function LocalDT2GMTDT(const LocalDT: TDateTime): TDateTime;
begin
  Result := LocalDT + CalculateTimeZoneBias(LocalDT) / (24 * 60);
end;
(******************************************************************************)
(* convert GMT dates to local related to Daylight/Standard settings *)

function GMTDT2LocalDT(const GMTDT: TDateTime): TDateTime;
begin
  Result := GMTDT - CalculateTimeZoneBias(GMTDT) / (24 * 60);
end;
(******************************************************************************)

function GMTStr2LocalDateTime(GMTStr: string): TDateTime;
var
  GMTDT: Double;
  I: Integer;
begin
  Result := 0;
  if GMTStr = '' then
    Exit;
  (* Step 1 : translate the separator to local settings *)
  for I := 1 to Length(GMTStr) do
    {$IFDEF UNICODE}
    if not CharInSet(GMTStr[I], ['0'..'9', '+', '-', 'E']) then
    {$ELSE ~UNICODE}
    if not (GMTStr[I] in ['0'..'9', '+', '-', 'E']) then
    {$ENDIF ~UNICODE}
    begin
      System.Delete(GMTStr, I, 1);
      System.Insert({$IFDEF RTL220_UP}FormatSettings.{$ENDIF}DecimalSeparator, GMTStr, I);
      Break;
    end;
  (* Step 2 : translate to GMT based DateTime value *)
  GMTDT := StrToFloat(GMTStr);

  Result := GMTDT - CalculateTimeZoneBias(GMTDT) / (24 * 60);
end;
(******************************************************************************)
(* convert local dates to a GMT time string related to Daylight/Standard
   settings *)

function LocalDT2GMTStr(const LocalDT: TDateTime): string;
var 
  TZBias, Hr2GMT, Min2GMT: Single;
  Min2GMTStr: string;
begin
  TZBias := -1 * (CalculateTimeZoneBias(LocalDT) / 60);
  Hr2GMT := Int(TZBias);
  Min2GMT := (TZBias - Hr2GMT) * 60;
  if Min2GMT < 0 then
    Min2GMT := -1 * Min2GMT;
  Min2GMTStr := FloatToStr(Min2GMT);
  if Min2GMTStr = '0' then
    Min2GMTStr := '0' + Min2GMTStr;
  if TZBias >= 0 then
    Result := Format('%s (GMT+%.0f:%s)', [DateTimeToStr(LocalDT), Hr2GMT,
      Min2GMTStr])
  else
    Result := Format('%s (GMT%.0f:%s)', [DateTimeToStr(LocalDT), Hr2GMT,
      Min2GMTStr]);
end;

end.
