(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSClientDebug.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2003/12/27  USchuster - new unit
2003/12/29  USchuster - renamed to JVCSDebug.pas
2003/12/31  USchuster - new trace functions
2007/08/13  USchuster - Trace -> TraceMsg
2008/06/08  USchuster - fixed memory leaks (Mantis #3082)
                      - simplified memory leak fix

-----------------------------------------------------------------------------*)

unit JVCSDebug;

{$I jedi.inc}

interface

uses
  SysUtils, Classes;

type
  PRunningFunction = ^TRunningFunction;
  TRunningFunction = record
    ObjectPtr: Pointer;
    FunctionCode: string;
    ClientObject: Boolean;
    Start: TDateTime;
  end;

  PStatisticFunction = ^TStatisticFunction;
  TStatisticFunction = record
    FunctionCode: string;
    ClientObject: Boolean;
    MinRunTime: TDateTime;
    MaxRunTime: TDateTime;
    Runs: Integer;
    RunTime: TDateTime;
  end;

  TStatisticSort = (stsFunctionCode, stsMinAvgRunTime, stsMaxAvgRunTime, stsMaxRuns);

  TFunctionDebugList = class(TObject)
  private
    FMustSortStatistics: Boolean;
    FRunningFunctionList: TThreadList;
    FStatisticList: TList;
    FStatisticSort: TStatisticSort;
    procedure AddToStatistic(ARunPtr: PRunningFunction);
    procedure DoSortStatistics;
    function GetRunningCount: Integer;
    function GetRunningItem(AIndex: Integer): TRunningFunction;
    function GetStatisticCount: Integer;
    function GetStatisticItem(AIndex: Integer): TStatisticFunction;
    procedure SetStatisticSort(AStatisticSort: TStatisticSort);
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddRunningFunction(AFunctionCode: string);
    procedure AddRunningObject(AObject: TObject);
    procedure Clear;
    procedure RemoveRunningFunction(AFunctionCode: string);
    procedure RemoveRunningObject(AObject: TObject);

    property RunningCount: Integer read GetRunningCount;
    property RunningItems[AIndex: Integer]: TRunningFunction read GetRunningItem;
    property StatisticCount: Integer read GetStatisticCount;
    property StatisticItems[AIndex: Integer]: TStatisticFunction read GetStatisticItem;
    property StatisticSort: TStatisticSort read FStatisticSort write SetStatisticSort;
  end;

function FunctionDebugList: TFunctionDebugList;

//------------------------------------------------------------------------------
// trace functions
//------------------------------------------------------------------------------

var
  gTraceLevel: Byte = 2;
  gTracePrefix: ShortString = '';

procedure TraceStandard(const ATraceLevel: Integer; const AMessage: string);
procedure TraceStandardFmt(const ATraceLevel: Integer; const AFormat: string;
  const Arguments: array of const);
procedure TraceAlways(const AMessage: string);
procedure TraceAlwaysFmt(const AFormat: string; const Arguments: array of const);
procedure TraceException(AException: Exception; const AMessage: string);
procedure TraceExceptionFmt(AException: Exception; const AFormat: string;
  const Arguments: array of const);
procedure TraceBeginProc(const AProcedureName: string);
procedure TraceBeginProcFmt(const AProcedureName: string; const AFormat: string;
  const Arguments: array of const);
procedure TraceEndProc(const AProcedureName: string);
procedure TraceEndProcFmt(const AProcedureName: string; const AFormat: string;
  const Arguments: array of const);

implementation

uses
  CBroker, JVCSClientObjBase, JclDebug;

var
  LocalFunctionDebugList: TFunctionDebugList;

const
  cTraceLevelMinimum = 1;
  cTraceLevelException = 1;
  cTraceLevelProc = 2;

function FunctionDebugList: TFunctionDebugList;
begin
  Result := LocalFunctionDebugList;
end;

constructor TFunctionDebugList.Create;
begin
  inherited Create;

  FMustSortStatistics := False;
  FRunningFunctionList := TThreadList.Create;
  FStatisticList := TList.Create;
  FStatisticSort := stsFunctionCode;
end;

destructor TFunctionDebugList.Destroy;
begin
  Clear;
  FRunningFunctionList.Free;
  FStatisticList.Free;

  inherited Destroy;
end;

procedure TFunctionDebugList.AddRunningFunction(AFunctionCode: string);
var
  LList: TList;
  RunPtr: PRunningFunction;
begin
  LList := FRunningFunctionList.LockList;
  try
    New(RunPtr);
    RunPtr^.ObjectPtr := nil;
    RunPtr^.FunctionCode := AFunctionCode;
    RunPtr^.ClientObject := False;
    RunPtr^.Start := Now;
    LList.Add(RunPtr);
  finally
    FRunningFunctionList.UnlockList;
  end;
end;

procedure TFunctionDebugList.AddRunningObject(AObject: TObject);
var
  LList: TList;
  RunPtr: PRunningFunction;
begin
  LList := FRunningFunctionList.LockList;
  try
    New(RunPtr);
    RunPtr^.ObjectPtr := AObject;
    RunPtr^.FunctionCode := GetFunctionCode(TClientObjectClass(AObject.ClassType));
    RunPtr^.ClientObject := True;
    RunPtr^.Start := Now;
    LList.Add(RunPtr);
  finally
    FRunningFunctionList.UnlockList;
  end;
end;

procedure TFunctionDebugList.AddToStatistic(ARunPtr: PRunningFunction);
var
  I: Integer;
  StatisticPtr: PStatisticFunction;
  CurrentRunTime: TDateTime;
begin
  FMustSortStatistics := True;
  StatisticPtr := nil;
  for I := 0 to Pred(FStatisticList.Count) do
    with PStatisticFunction(FStatisticList[I])^ do
    if (FunctionCode = ARunPtr^.FunctionCode) and (ClientObject = ARunPtr^.ClientObject) then
    begin
      StatisticPtr := FStatisticList[I];
      Break;
    end;
  if not Assigned(StatisticPtr) then
  begin
    New(StatisticPtr);
    StatisticPtr^.FunctionCode := ARunPtr^.FunctionCode;
    StatisticPtr^.ClientObject := ARunPtr^.ClientObject;
    StatisticPtr^.Runs := 0;
    StatisticPtr^.MinRunTime := 0;
    StatisticPtr^.MaxRunTime := 0;        
    StatisticPtr^.RunTime := 0;
    FStatisticList.Add(StatisticPtr);
  end;
  Inc(StatisticPtr^.Runs);
  CurrentRunTime := Now - ARunPtr^.Start;
  if (StatisticPtr^.Runs = 1) or (StatisticPtr^.MinRunTime > CurrentRunTime) then
    StatisticPtr^.MinRunTime := CurrentRunTime;
  if (StatisticPtr^.Runs = 1) or (StatisticPtr^.MaxRunTime < CurrentRunTime) then
    StatisticPtr^.MaxRunTime := CurrentRunTime;
  StatisticPtr^.RunTime := StatisticPtr^.RunTime + CurrentRunTime;
end;

function SortByFunctionCode(Item1, Item2: Pointer): Integer;
begin
  Result := CompareStr(PStatisticFunction(Item1)^.FunctionCode,
    PStatisticFunction(Item2)^.FunctionCode);
end;

function SortByMinAvgRunTime(Item1, Item2: Pointer): Integer;
var
  AvgTime1, AvgTime2: TDateTime;
begin
  AvgTime1 := PStatisticFunction(Item1)^.RunTime / PStatisticFunction(Item1)^.Runs;
  AvgTime2 := PStatisticFunction(Item2)^.RunTime / PStatisticFunction(Item2)^.Runs;
  if AvgTime1 < AvgTime2 then
    Result := -1
  else
  if AvgTime1 > AvgTime2 then
    Result := 1
  else
    Result := 0;
end;

function SortByMaxAvgRunTime(Item1, Item2: Pointer): Integer;
begin
  Result := -1 * SortByMinAvgRunTime(Item1, Item2);
end;

function SortByMaxRuns(Item1, Item2: Pointer): Integer;
begin
  Result := PStatisticFunction(Item2)^.Runs -
    PStatisticFunction(Item1)^.Runs;
  if Result = 0 then
    Result := SortByFunctionCode(Item1, Item2);
end;

procedure TFunctionDebugList.DoSortStatistics;
var
  CompareFunc: TListSortCompare;
begin
  if FMustSortStatistics then
  begin
    FMustSortStatistics := False;
    case FStatisticSort of
      stsFunctionCode: CompareFunc := SortByFunctionCode;
      stsMinAvgRunTime: CompareFunc := SortByMinAvgRunTime;
      stsMaxAvgRunTime: CompareFunc := SortByMaxAvgRunTime;
      stsMaxRuns: CompareFunc := SortByMaxRuns;
      else
        CompareFunc := SortByFunctionCode;
    end;
    FStatisticList.Sort(CompareFunc);
  end;
end;

procedure TFunctionDebugList.Clear;
var
  LList: TList;
  I: Integer;
begin
  LList := FRunningFunctionList.LockList;
  try
    for I := 0 to Pred(LList.Count) do
      Dispose(PRunningFunction(LList[I]));
    LList.Clear;
  finally
    FRunningFunctionList.UnlockList;
  end;
  for I := 0 to Pred(FStatisticList.Count) do
    Dispose(PStatisticFunction(FStatisticList[I]));
  FStatisticList.Clear;
end;

function TFunctionDebugList.GetRunningCount: Integer;
var
  LList: TList;
begin
  LList := FRunningFunctionList.LockList;
  try
    Result := LList.Count;
  finally
    FRunningFunctionList.UnlockList;
  end;
end;

function TFunctionDebugList.GetRunningItem(AIndex: Integer): TRunningFunction;
var
  LList: TList;
begin
  LList := FRunningFunctionList.LockList;
  try
    Result := PRunningFunction(LList[AIndex])^;
  finally
    FRunningFunctionList.UnlockList;
  end;
end;

function TFunctionDebugList.GetStatisticCount: Integer;
begin
  Result := FStatisticList.Count;
end;

function TFunctionDebugList.GetStatisticItem(AIndex: Integer): TStatisticFunction;
begin
  DoSortStatistics;
  Result := PStatisticFunction(FStatisticList[AIndex])^;
end;

procedure TFunctionDebugList.RemoveRunningFunction(AFunctionCode: string);
var
  LList: TList;
  I, idx: Integer;
begin
  LList := FRunningFunctionList.LockList;
  try
    idx := -1;
    for I := 0 to Pred(LList.Count) do
      with PRunningFunction(LList[I])^ do
        if (ObjectPtr = nil) and (FunctionCode = AFunctionCode) then
        begin
          idx := I;
          Break;
        end;
    if idx <> -1 then
    begin
      AddToStatistic(LList[idx]);
      Dispose(PRunningFunction(LList[idx]));
      LList.Delete(idx);
    end;
  finally
    FRunningFunctionList.UnlockList;
  end;
end;

procedure TFunctionDebugList.RemoveRunningObject(AObject: TObject);
var
  LList: TList;
  I, idx: Integer;
begin
  LList := FRunningFunctionList.LockList;
  try
    idx := -1;
    for I := 0 to Pred(LList.Count) do
      if PRunningFunction(LList[I])^.ObjectPtr = AObject then
      begin
        idx := I;
        Break;
      end;
    if idx <> -1 then
    begin
      AddToStatistic(LList[idx]);
      Dispose(PRunningFunction(LList[idx]));
      LList.Delete(idx);
    end;
  finally
    FRunningFunctionList.UnlockList;
  end;
end;

procedure TFunctionDebugList.SetStatisticSort(AStatisticSort: TStatisticSort);
begin
  if FStatisticSort <> AStatisticSort then
  begin
    FStatisticSort := AStatisticSort;
    FMustSortStatistics := True;
  end;
end;

//==============================================================================
// trace functions
//==============================================================================

procedure TraceStandard(const ATraceLevel: Integer; const AMessage: string);
begin
  if gTraceLevel >= ATraceLevel then
    JclDebug.TraceMsg(gTracePrefix + AMessage);
end;

procedure TraceStandardFmt(const ATraceLevel: Integer; const AFormat: string;
  const Arguments: array of const);
begin
  TraceStandard(ATraceLevel, Format(AFormat, Arguments));
end;

procedure TraceAlways(const AMessage: string);
begin
  TraceStandard(cTraceLevelMinimum, AMessage);
end;

procedure TraceAlwaysFmt(const AFormat: string; const Arguments: array of const);
begin
  TraceStandardFmt(cTraceLevelMinimum, AFormat, Arguments);
end;

procedure TraceException(AException: Exception; const AMessage: string);
begin
  TraceStandardFmt(cTraceLevelException, 'Exception %s/%s in %s',
    [AException.ClassName, AException.Message, AMessage]);
end;

procedure TraceExceptionFmt(AException: Exception; const AFormat: string;
  const Arguments: array of const);
begin
  TraceStandardFmt(cTraceLevelException, 'Exception %s/%s in %s',
    [AException.ClassName, AException.Message, Format(AFormat, Arguments)]);
end;

procedure TraceBeginProc(const AProcedureName: string);
begin
  TraceStandardFmt(cTraceLevelProc, '> %s', [AProcedureName]);
end;

procedure TraceBeginProcFmt(const AProcedureName: string; const AFormat: string;
  const Arguments: array of const);
begin
  TraceStandardFmt(cTraceLevelProc, '> %s (%s)', [AProcedureName,
    Format(AFormat, Arguments)]);
end;

procedure TraceEndProc(const AProcedureName: string);
begin
  TraceStandardFmt(cTraceLevelProc, '%s <', [AProcedureName]);
end;

procedure TraceEndProcFmt(const AProcedureName: string; const AFormat: string;
  const Arguments: array of const);
begin
  TraceStandardFmt(cTraceLevelProc, '%s (%s) <', [AProcedureName,
    Format(AFormat, Arguments)]);
end;

initialization
  LocalFunctionDebugList := TFunctionDebugList.Create;
finalization
  LocalFunctionDebugList.Free;
  
end.
