(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSCompressedDiffUnit.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2009/11/27  USchuster - new unit
2014/02/26  USchuster - changes for inline diffs

-----------------------------------------------------------------------------*)

unit JVCSCompressedDiffUnit;

{$I jedi.inc}

interface

uses
  Classes, Contnrs;

type
  TJVCSCompressedDiffKind = (cdtNone, cdtBlockDivider, cdtAdd, cdtDelete, cdtModifyAdd, cdtModifyDelete);
  TJVCSCompressedDiffBlockKind = (cdtbNone, cdtbAdd, cdtbDelete, cdtbModify);

  TJVCSCompressedDiffInlineDiffHighlight = record
    CharIndex: Integer;
    Length: Integer;
  end;

  TJVCSCompressedDiffInlineDiffHighlightArray = array of TJVCSCompressedDiffInlineDiffHighlight;

  TJVCSCompressedDiffItem = class(TObject)
  private
    FInlineDiffHighlight: TJVCSCompressedDiffInlineDiffHighlightArray;
    FKind: TJVCSCompressedDiffKind;
    FLineNumber1: Integer;
    FLineNumber2: Integer;
    FText: string;
  public
    constructor Create(AKind: TJVCSCompressedDiffKind; ALineNumber1, ALineNumber2: Integer; const AText: string);
    property InlineDiffHighlight: TJVCSCompressedDiffInlineDiffHighlightArray read FInlineDiffHighlight write FInlineDiffHighlight;
    property Kind: TJVCSCompressedDiffKind read FKind;
    property LineNumber1: Integer read FLineNumber1;
    property LineNumber2: Integer read FLineNumber2;
    property Text: string read FText;
  end;

  TJVCSCompressedDiffBlockItem = class(TObject)
  private
    FKind: TJVCSCompressedDiffBlockKind;
    FLine: Integer;
    FItems: TObjectList;
    function GetCount: Integer;
    function GetItems(AIndex: Integer): TJVCSCompressedDiffItem;
    function GetZeroLineAfter: Integer;
    function GetZeroLineBefore: Integer;
  public
    constructor Create(AKind: TJVCSCompressedDiffBlockKind; ALine: Integer);
    destructor Destroy; override;
    function Add(AKind: TJVCSCompressedDiffKind; ALineNumber1, ALineNumber2: Integer; AText: string): TJVCSCompressedDiffItem;
    property Count: Integer read GetCount;
    property Items[AIndex: Integer]: TJVCSCompressedDiffItem read GetItems; default;
    property Kind: TJVCSCompressedDiffBlockKind read FKind write FKind;
    property Line: Integer read FLine write FLine;
    property ZeroLineAfter: Integer read GetZeroLineAfter;
    property ZeroLineBefore: Integer read GetZeroLineBefore;
  end;

  TJVCSCompressedDiff = class(TObject)
  private
    FBlockItems: TObjectList;
    FInlineDiffHighlight: Boolean;
    FItems: TObjectList;
    FSurroundLinesCount: Integer;
    FText: TStringList;
    function Add(AKind: TJVCSCompressedDiffKind; ALineNumber1, ALineNumber2: Integer; AText: string): TJVCSCompressedDiffItem;
    function GetCount: Integer;
    function GetItems(AIndex: Integer): TJVCSCompressedDiffItem;
    function GetBlockCount: Integer;
    function GetBlockItems(AIndex: Integer): TJVCSCompressedDiffBlockItem;
    procedure InlineDiff(ALines1, ALines2: TStrings);
    procedure InlineDiffStrings(const AStr1, AStr2: string; AMod: TList);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Diff(ALines1, ALines2: TStrings);
    property BlockCount: Integer read GetBlockCount;
    property BlockItems[AIndex: Integer]: TJVCSCompressedDiffBlockItem read GetBlockItems;
    property Count: Integer read GetCount;
    property InlineDiffHighlight: Boolean read FInlineDiffHighlight write FInlineDiffHighlight;
    property Items[AIndex: Integer]: TJVCSCompressedDiffItem read GetItems; default;
    property SurroundLinesCount: Integer read FSurroundLinesCount write FSurroundLinesCount;
    property Text: TStringList read FText;
  end;

implementation

uses
  DiffUnit, HashUnit;

{ TJVCSCompressedDiffItem }

constructor TJVCSCompressedDiffItem.Create(AKind: TJVCSCompressedDiffKind; ALineNumber1, ALineNumber2: Integer; const AText: string);
begin
  inherited Create;
  FKind := AKind;
  FLineNumber1 := ALineNumber1;
  FLineNumber2 := ALineNumber2;
  FText := AText;
end;

{ TJVCSCompressedDiffBlockItem }

constructor TJVCSCompressedDiffBlockItem.Create(AKind: TJVCSCompressedDiffBlockKind; ALine: Integer);
begin
  inherited Create;
  FItems := TObjectList.Create;
  FKind := AKind;
  FLine := ALine;
end;

destructor TJVCSCompressedDiffBlockItem.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

function TJVCSCompressedDiffBlockItem.Add(AKind: TJVCSCompressedDiffKind; ALineNumber1,
  ALineNumber2: Integer; AText: string): TJVCSCompressedDiffItem;
begin
  FItems.Add(TJVCSCompressedDiffItem.Create(AKind, ALineNumber1, ALineNumber2, AText));
  Result := TJVCSCompressedDiffItem(FItems.Last);
end;

function TJVCSCompressedDiffBlockItem.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TJVCSCompressedDiffBlockItem.GetItems(AIndex: Integer): TJVCSCompressedDiffItem;
begin
  Result := TJVCSCompressedDiffItem(FItems[AIndex]);
end;

function TJVCSCompressedDiffBlockItem.GetZeroLineAfter: Integer;
var
  I: Integer;
begin
  Result := Line - 1;
  for I := 0 to Pred(Count) do
    if Items[I].Kind in [cdtAdd, cdtModifyAdd] then
      Inc(Result);
end;

function TJVCSCompressedDiffBlockItem.GetZeroLineBefore: Integer;
begin
  Result := Line - 2;
end;

{ TJVCSCompressedDiff }

function TJVCSCompressedDiff.Add(AKind: TJVCSCompressedDiffKind; ALineNumber1, ALineNumber2: Integer;
  AText: string): TJVCSCompressedDiffItem;
begin
  FItems.Add(TJVCSCompressedDiffItem.Create(AKind, ALineNumber1, ALineNumber2, AText));
  Result := TJVCSCompressedDiffItem(FItems.Last);
  FText.Add(AText);
end;

constructor TJVCSCompressedDiff.Create;
begin
  inherited Create;
  FBlockItems := TObjectList.Create;
  FInlineDiffHighlight := False;
  FItems := TObjectList.Create;
  FSurroundLinesCount := 3;//TODO
  FText := TStringList.Create;
end;

destructor TJVCSCompressedDiff.Destroy;
begin
  FText.Free;
  FItems.Free;
  FBlockItems.Free;
  inherited Destroy;
end;

procedure TJVCSCompressedDiff.Diff(ALines1, ALines2: TStrings);
var
  HashList1, HashList2: TList;
  I, J, K, L, NextK, FillK: Integer;
  LDiff: TDiff;
  Block: TJVCSCompressedDiffBlockItem;
begin
  FItems.Clear;
  FBlockItems.Clear;
  FText.Clear;
  HashList1 := TList.Create;
  HashList2 := TList.Create;
  LDiff := TDiff.Create(nil);
  try
    for I := 0 to ALines1.Count - 1 do
      HashList1.Add(HashLine(ALines1[I], True, True));
    for I := 0 to ALines2.Count - 1 do
      HashList2.Add(HashLine(ALines2[I], True, True));
    LDiff.Execute(PIntArray(HashList1.List), PIntArray(HashList2.List),
      HashList1.Count, HashList2.Count);
    J := 0;
    K := 0;
    with LDiff do
      for I := 0 to ChangeCount-1 do
        with Changes[I] do
        begin
          while J < x do
          begin
            Inc(J);
            Inc(K);
          end;
          if Kind = ckAdd then
          begin
            FBlockItems.Add(TJVCSCompressedDiffBlockItem.Create(cdtbAdd, K + 1));
            Block := TJVCSCompressedDiffBlockItem(FBlockItems.Last);
            for J := K to K + Range - 1 do
            begin
              //Add(cdtAdd, -1, J + 1, ALines2[J]);
              Block.Add(cdtAdd, -1, J + 1, ALines2[J]);
            end;
            J := x;
            K := y + Range;
          end
          else
          if Kind = ckModify then
          begin
            FBlockItems.Add(TJVCSCompressedDiffBlockItem.Create(cdtbModify, y + 1));
            Block := TJVCSCompressedDiffBlockItem(FBlockItems.Last);
            for J := x to x + Range - 1 do
            begin
              //Add(cdtModifyDelete, -1, 0, ALines1[J]);
              Block.Add(cdtModifyDelete, J + 1 -X + Y{-1}, 0, ALines1[J]);
            end;
            for K := y to y + Range - 1 do
            begin
              //Add(cdtModifyAdd, -1, K + 1, ALines2[K]);
              Block.Add(cdtModifyAdd, K + 1 - Y + X{-1}, K + 1, ALines2[K]);
            end;
            J := x + Range;
            K := y + Range;
          end
          else //Kind = ckDelete
          begin
            FBlockItems.Add(TJVCSCompressedDiffBlockItem.Create(cdtbDelete, K + 1));
            Block := TJVCSCompressedDiffBlockItem(FBlockItems.Last);
            for J := x to x + Range - 1 do
            begin
              //Add(cdtDelete, -1, 0, ALines1[J]);
              Block.Add(cdtDelete, -1, 0, ALines1[J]);
            end;
            J := x + Range;
          end;
        end;
  finally
    LDiff.Free;
    HashList2.Free;
    HashList1.Free;
  end;

  FItems.Clear;
  FText.Clear;
  K := -1;
  for I := 0 to BlockCount - 1 do
  begin
    Block := BlockItems[I];
    J := Block.ZeroLineBefore - FSurroundLinesCount + 1;
    if J < 0 then
      J := 0;
    if J < K then
      J := K;
    for L := J to Block.ZeroLineBefore do
      Add(cdtNone, -1, L + 1, ALines2[L]);

    for J := 0 to BlockItems[I].Count - 1 do
      Add(BlockItems[I][J].Kind, BlockItems[I][J].LineNumber1, BlockItems[I][J].LineNumber2,
        BlockItems[I][J].Text);

    K := Block.ZeroLineAfter;
    NextK := - FSurroundLinesCount;
    if I < BlockCount - 1 then
      NextK := BlockItems[I + 1].ZeroLineBefore - FSurroundLinesCount + 1;
    FillK := K + FSurroundLinesCount - 1;
    if FillK >= ALines2.Count then
      FillK := ALines2.Count - 1;
    if (NextK <> - FSurroundLinesCount) and (NextK <= FillK) then
      FillK := NextK - 1;
    for L := K to FillK do
      Add(cdtNone, -1, L + 1, ALines2[L]);
    if (NextK <> - FSurroundLinesCount) and (FillK < NextK - 1) then
      Add(cdtBlockDivider, -1, -1, '---');
  end;

  if FInlineDiffHighlight then
    InlineDiff(ALines1, ALines2);
end;

function TJVCSCompressedDiff.GetBlockCount: Integer;
begin
  Result := FBlockItems.Count;
end;

function TJVCSCompressedDiff.GetBlockItems(AIndex: Integer): TJVCSCompressedDiffBlockItem;
begin
  Result := TJVCSCompressedDiffBlockItem(FBlockItems[AIndex]);
end;

function TJVCSCompressedDiff.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TJVCSCompressedDiff.GetItems(AIndex: Integer): TJVCSCompressedDiffItem;
begin
  Result := TJVCSCompressedDiffItem(FItems[AIndex]);
end;

procedure TJVCSCompressedDiff.InlineDiff(ALines1, ALines2: TStrings);
var
  I, J, LastStart, LastIndex, Index, ArrayIndex: Integer;
  Text2: string;
  ModList: TList;
  CharArray: TJVCSCompressedDiffInlineDiffHighlightArray;
begin
  for I := 0 to Count - 1 do
    if Items[I].LineNumber1 > 0 then
    begin
      ModList := TList.Create;
      try
        if Items[I].Kind = cdtModifyDelete then
          Text2 := ALines2[Items[I].LineNumber1 - 1]
        else
          Text2 := ALines1[Items[I].LineNumber1 - 1];
        InlineDiffStrings(Items[I].Text, Text2, ModList);
        LastStart := -1;
        LastIndex := -1;
        ArrayIndex := 0;
        SetLength(CharArray, 0);
        for J := 0 to ModList.Count - 1 do
        begin
          Index := Integer(ModList[J]);
          if LastStart = -1 then
          begin
            LastStart := Index;
            LastIndex := Index;
          end
          else
          if LastIndex + 1 = Index then
            LastIndex := Index
          else
          begin
            SetLength(CharArray, ArrayIndex + 1);
            CharArray[ArrayIndex].CharIndex := LastStart;
            CharArray[ArrayIndex].Length := LastIndex - LastStart + 1;
            Inc(ArrayIndex);
            LastStart := Index;
            LastIndex := Index;
          end;
        end;
        if LastStart <> -1 then
        begin
          SetLength(CharArray, ArrayIndex + 1);
          CharArray[ArrayIndex].CharIndex := LastStart;
          CharArray[ArrayIndex].Length := LastIndex - LastStart + 1;
        end;
        Items[I].InlineDiffHighlight := CharArray;
      finally
        ModList.Free;
      end;
    end;
end;

procedure TJVCSCompressedDiff.InlineDiffStrings(const AStr1, AStr2: string; AMod: TList);
var
  I, J: Integer;
  L1, L2: TList;
  Diff: TDiff;
begin
  AMod.Clear;

  Diff := TDiff.Create(nil);
  L1 := TList.Create;
  L2 := TList.Create;
  try
    for I := 1 to Length(AStr1) do
      L1.Add(Pointer(Ord(AStr1[I])));
    for I := 1 to Length(AStr2) do
      L2.Add(Pointer(Ord(AStr2[I])));
    Diff.Execute(PIntArray(L1.List), PIntArray(L2.List), L1.Count, L2.Count);

    with Diff do
      for I := 0 to ChangeCount-1 do
        with Changes[I] do
        begin
          if Kind = ckModify then
          begin
            for J := x to x + Range - 1 do
              AMod.Add(Pointer(J));
          end
          else
          if Kind = ckDelete then
            for J := x to x + Range - 1 do
              AMod.Add(Pointer(J));
        end;
  finally
    L1.Free;
    L2.Free;
    Diff.Free;
  end;
end;

end.
