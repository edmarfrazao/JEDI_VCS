(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSCompressedDiffSynProxy.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2014/02/26  USchuster - new unit
2014/03/01  USchuster - changes for D2009+/UniSynEdit
2014/03/07  USchuster - changes to make it actually work with UniSynEdit

-----------------------------------------------------------------------------*)

unit JVCSCompressedDiffSynProxy;

{$I jedi.inc}

interface

uses
  Windows, SysUtils, Classes, SynEditHighlighter, Contnrs, Graphics,
  JVCSCompressedDiffUnit;

type
  TLineToken = class(TPersistent)
  private
    FText: string;
    FKind: Integer;
    FAttribute: TSynHighlighterAttributes;
    FPos: Integer;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    property Attribute: TSynHighlighterAttributes read FAttribute write FAttribute;
    property Kind: Integer read FKind write FKind;
    property Text: string read FText write FText;
    property Pos: Integer read FPos write FPos;
  end;

  TLineTokens = class(TObject)
  private
    FItems: TObjectList;
    function GetCount: Integer;
    function GetItems(AIndex: Integer): TLineToken;
  public
    constructor Create;
    destructor Destroy; override;
    function Add: TLineToken;
    procedure Clear;
    procedure Combine;
    procedure HighlightChars(APos, ALength: Integer; AAttribute: TSynHighlighterAttributes);
    procedure SplitByChar;
    property Count: Integer read GetCount;
    property Items[AIndex: Integer]: TLineToken read GetItems; default;
  end;

  THighlightKind = (hkDeleteLine, hkDeleteChar, hkInsertLine, hkInsertChar);

  THighlightChar = class(TObject)
  private
    FCharIndex: Integer;
    FKind: THighlightKind;
  public
    property CharIndex: Integer read FCharIndex write FCharIndex;
    property Kind: THighlightKind read FKind write FKind;
  end;

  THighlightLine = class(TObject)
  private
    FItems: TObjectList;
    FLine: Integer;
    function GetCount: Integer;
    function GetItems(AIndex: Integer): THighlightChar;
  public
    constructor Create(ALine: Integer);
    destructor Destroy; override;
    function Add: THighlightChar;
    property Count: Integer read GetCount;
    property Items[AIndex: Integer]: THighlightChar read GetItems; default;
    property Line: Integer read FLine;
  end;

  THighlightLines = class(TObject)
  private
    FItems: TObjectList;
    function GetCount: Integer;
    function GetItems(AIndex: Integer): THighlightLine;
  public
    constructor Create;
    destructor Destroy; override;
    function Find(ALine: Integer): THighlightLine;
    function Get(ALine: Integer): THighlightLine;
    property Count: Integer read GetCount;
    property Items[AIndex: Integer]: THighlightLine read GetItems; default;
  end;

  TJVCSCompressedDiffSynProxyHighlighter = class(TSynCustomHighlighter)
  private
    FAttrDeleteLine: TSynHighlighterAttributes;
    FAttrDeleteChar: TSynHighlighterAttributes;
    FAttrInsertLine: TSynHighlighterAttributes;
    FAttrInsertChar: TSynHighlighterAttributes;
    FHighlightLines: THighlightLines;
    FIdx: Integer;
    FInternalHighlighter: TSynCustomHighlighter;
    FLineNumber: Integer;
    FLineStr: string;
    FTokens: TLineTokens;
    procedure AddHighlightChar(ALine, ACharIndex: Integer; AKind: THighlightKind);
    procedure SetInternalHighlighter(const Value: TSynCustomHighlighter);
  protected
    function GetDefaultAttribute(Index: Integer): TSynHighlighterAttributes; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetEol: Boolean; override;
    {$IFDEF UNISYNEDIT}
    function GetExpandedToken: UnicodeString; override;
    function GetExpandedTokenPos: Integer; override;
    {$ENDIF UNISYNEDIT}
    function GetToken: string; override;
    function GetTokenAttribute: TSynHighlighterAttributes; override;
    function GetTokenKind: Integer; override;
    function GetTokenPos: Integer; override;
    property InternalHighlighter: TSynCustomHighlighter read FInternalHighlighter write SetInternalHighlighter;
    {$IFDEF UNISYNEDIT}
    procedure DoSetLine(const NewValue: string; LineNumber:Integer); override;
    {$ELSE}
    procedure SetLine(NewValue: string; LineNumber:Integer); override;
    {$ENDIF}
    procedure ResetRange; override;
    procedure Next; override;
    procedure UpdateHighlight(ACompressedDiff: TJVCSCompressedDiff);
  end;

implementation

type
  TSynCustomHighlighterAccess = class(TSynCustomHighlighter);

{ TLineTokens }

constructor TLineTokens.Create;
begin
  inherited Create;
  FItems := TObjectList.Create;
end;

destructor TLineTokens.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

function TLineTokens.Add: TLineToken;
begin
  FItems.Add(TLineToken.Create);
  Result := TLineToken(FItems.Last);
end;

procedure TLineTokens.Clear;
begin
  FItems.Clear;
end;

procedure TLineTokens.Combine;
var
  I: Integer;
begin
  for I := Count - 1 downto 1 do
    if (Items[I].Kind = Items[I - 1].Kind) and (Items[I].Attribute = Items[I - 1].Attribute) and
      (Items[I].Pos = Items[I - 1].Pos + Length(Items[I - 1].Text)) then
    begin
      Items[I - 1].Text := Items[I - 1].Text + Items[I].Text;
      FItems.Delete(I);  
    end;     
end;

function TLineTokens.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TLineTokens.GetItems(AIndex: Integer): TLineToken;
begin
  Result := TLineToken(FItems[AIndex]);
end;

procedure TLineTokens.HighlightChars(APos, ALength: Integer; AAttribute: TSynHighlighterAttributes);
var
  I, P2: Integer;
begin
  P2 := APos + ALength - 1;
  for I := 0 to Count - 1 do
    if (Items[I].Pos >= APos) and (Items[I].Pos <= P2) then
    begin
      Items[I].Attribute := AAttribute;
      Items[I].Kind := Items[I].Kind + 100; 
    end;
end;

procedure TLineTokens.SplitByChar;
var
  I, J, L: Integer;
  TempTokens: TLineTokens;
  LineToken: TLineToken;
begin
  TempTokens := TLineTokens.Create;
  try
    for I := 0 to Pred(Count) do
    begin
      LineToken := TempTokens.Add;
      LineToken.Assign(Items[I]);
    end;
    Clear;
    for I := 0 to Pred(TempTokens.Count) do
    begin
      L := Length(TempTokens[I].Text);
      for J := 0 to L - 1 do
      begin
        LineToken := Add;
        LineToken.Assign(TempTokens[I]);
        LineToken.Pos := TempTokens[I].Pos + J;
        LineToken.Text := Copy(TempTokens[I].Text, J + 1, 1);
      end;
    end;
  finally
    TempTokens.Free;
  end;
end;

{ TLineToken }

procedure TLineToken.AssignTo(Dest: TPersistent);
begin
  if Dest is TLineToken then
  begin
    TLineToken(Dest).FText := FText;
    TLineToken(Dest).FKind := FKind;
    TLineToken(Dest).FAttribute := FAttribute;
    TLineToken(Dest).FPos := FPos;
  end
  else
    inherited AssignTo(Dest);
end;

{ THighlightLine }

constructor THighlightLine.Create(ALine: Integer);
begin
  inherited Create;
  FItems := TObjectList.Create;
  FLine := ALine;
end;

destructor THighlightLine.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

function THighlightLine.Add: THighlightChar;
begin
  FItems.Add(THighlightChar.Create);
  Result := THighlightChar(FItems.Last);
end;

function THighlightLine.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function THighlightLine.GetItems(AIndex: Integer): THighlightChar;
begin
  Result := THighlightChar(FItems[AIndex]);
end;

{ THighlightLines }

constructor THighlightLines.Create;
begin
  inherited Create;
  FItems := TObjectList.Create;
end;

destructor THighlightLines.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

function THighlightLines.Find(ALine: Integer): THighlightLine;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Pred(Count) do
    if Items[I].Line = ALine then
    begin
      Result := Items[I];
      Break;
    end;
end;

function THighlightLines.Get(ALine: Integer): THighlightLine;
begin
  Result := Find(ALine);
  if not Assigned(Result) then
  begin
    FItems.Add(THighlightLine.Create(ALine));
    Result := THighlightLine(FItems.Last);
  end;    
end;

function THighlightLines.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function THighlightLines.GetItems(AIndex: Integer): THighlightLine;
begin
  Result := THighlightLine(FItems[AIndex]);
end;

{ TJVCSCompressedDiffSynProxyHighlighter }

constructor TJVCSCompressedDiffSynProxyHighlighter.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FInternalHighlighter := nil;
  FAttrDeleteLine := TSynHighlighterAttributes.Create('Delete Line'{$IFDEF UNISYNEDIT}, 'Delete Line'{$ENDIF});
  FAttrDeleteLine.Background := RGB($FF, $E0, $E0);
  FAttrDeleteChar := TSynHighlighterAttributes.Create('Delete Char'{$IFDEF UNISYNEDIT}, 'Delete Char'{$ENDIF});
  FAttrDeleteChar.Background := RGB($FF, $80, $80);
  FAttrInsertLine := TSynHighlighterAttributes.Create('Insert Line'{$IFDEF UNISYNEDIT}, 'Insert Line'{$ENDIF});
  FAttrInsertLine.Background := RGB($E0, $FF, $E0);
  FAttrInsertChar := TSynHighlighterAttributes.Create('Insert Char'{$IFDEF UNISYNEDIT}, 'Insert Char'{$ENDIF});
  FAttrInsertChar.Background := RGB($80, $FF, $80);
  FTokens := TLineTokens.Create;
  FHighlightLines := THighlightLines.Create;
end;

destructor TJVCSCompressedDiffSynProxyHighlighter.Destroy;
begin
  FAttrDeleteLine.Free;
  FHighlightLines.Free;
  FTokens.Free;
  inherited Destroy;
end;

procedure TJVCSCompressedDiffSynProxyHighlighter.AddHighlightChar(ALine, ACharIndex: Integer; AKind: THighlightKind);
var
  L: THighlightLine;
  H: THighlightChar;
begin
  L := FHighlightLines.Get(ALine);
  H := L.Add;
  H.CharIndex := ACharIndex;
  H.Kind := AKind;
end;

function TJVCSCompressedDiffSynProxyHighlighter.GetDefaultAttribute(Index: Integer): TSynHighlighterAttributes;
begin
  if Assigned(FInternalHighlighter) then
    Result := TSynCustomHighlighterAccess(FInternalHighlighter).GetDefaultAttribute(Index)
  else
    Result := nil;
end;

function TJVCSCompressedDiffSynProxyHighlighter.GetEol: Boolean;
begin
  Result := FIdx >= FTokens.Count;
end;

{$IFDEF UNISYNEDIT}
function TJVCSCompressedDiffSynProxyHighlighter.GetExpandedToken: UnicodeString;
begin
  Result := GetToken;
end;

function TJVCSCompressedDiffSynProxyHighlighter.GetExpandedTokenPos: Integer;
begin
  Result := GetTokenPos;
end;
{$ENDIF UNISYNEDIT}

function TJVCSCompressedDiffSynProxyHighlighter.GetToken: string;
begin
  Result := FTokens[FIdx].Text;
end;

function TJVCSCompressedDiffSynProxyHighlighter.GetTokenAttribute: TSynHighlighterAttributes;
begin
  Result := FTokens[FIdx].Attribute;
end;

function TJVCSCompressedDiffSynProxyHighlighter.GetTokenKind: Integer;
begin
  Result := FTokens[FIdx].Kind;
end;

function TJVCSCompressedDiffSynProxyHighlighter.GetTokenPos: Integer;
begin
  Result := FTokens[FIdx].Pos;
end;

procedure TJVCSCompressedDiffSynProxyHighlighter.Next;
begin
  Inc(FIdx);
end;

procedure TJVCSCompressedDiffSynProxyHighlighter.ResetRange;
begin
  if Assigned(FInternalHighlighter) then
    FInternalHighlighter.ResetRange;
end;

procedure TJVCSCompressedDiffSynProxyHighlighter.SetInternalHighlighter(const Value: TSynCustomHighlighter);
begin
  FInternalHighlighter := Value;
  FTokens.Clear;
  FIdx := 0;
end;

{$IFDEF UNISYNEDIT}
procedure TJVCSCompressedDiffSynProxyHighlighter.DoSetLine(const NewValue: string; LineNumber: Integer);
{$ELSE}
procedure TJVCSCompressedDiffSynProxyHighlighter.SetLine(NewValue: string; LineNumber: Integer);
{$ENDIF}
var
  I, P: Integer;
  Token: TLineToken;
  Line: THighlightLine;
  Attr: TSynHighlighterAttributes;
  IsDel: Boolean;
begin
  FTokens.Clear;
  {$IFDEF UNISYNEDIT}
  FIdx := -1;
  {$ELSE}
  FIdx := 0;
  {$ENDIF}
  if Assigned(FInternalHighlighter) then
  begin
    {$IFDEF UNISYNEDIT}
    TSynCustomHighlighterAccess(FInternalHighlighter).DoSetLine(NewValue, LineNumber);
    {$ELSE}
    FInternalHighlighter.SetLine(NewValue, LineNumber);
    {$ENDIF}
    while not FInternalHighlighter.GetEol do
    begin
      Token := FTokens.Add;
      Token.Attribute := FInternalHighlighter.GetTokenAttribute;
      Token.Text := FInternalHighlighter.GetToken;
      Token.Pos := FInternalHighlighter.GetTokenPos;
      Token.Kind := FInternalHighlighter.GetTokenKind;
      FInternalHighlighter.Next;
    end;
  end;
  FLineStr := NewValue;
  FLineNumber := LineNumber;

  Line := FHighlightLines.Find(LineNumber);
  if Assigned(Line) then
  begin
    FTokens.SplitByChar;
    IsDel := False;
    for I := 0 to Line.Count - 1 do
    begin
      case Line[I].Kind of
        hkDeleteLine: Attr := FAttrDeleteLine;
        hkDeleteChar: Attr := FAttrDeleteChar;
        hkInsertLine: Attr := FAttrInsertLine;
        hkInsertChar: Attr := FAttrInsertChar;
        else
          Attr := FAttrDeleteLine;
      end;
      if Line[I].Kind in [hkDeleteLine, hkDeleteChar] then
        IsDel := True;
      FTokens.HighlightChars(Line[I].CharIndex, 1, Attr);
    end;
    if FTokens.Count > 0 then
    begin
      Token := FTokens[Pred(FTokens.Count)];
      P := Token.Pos + Length(Token.Text) - 1;
      if P < 80 then
      begin
        Token := FTokens.Add;
        if IsDel then
          Token.Attribute := FAttrDeleteLine
        else
          Token.Attribute := FAttrInsertLine;
        Token.Text := StringOfChar(' ', 80 - P);
        Token.Pos := P + 1;
        Token.Kind := 100;
      end;
    end;
    FTokens.Combine;
  end;
end;

procedure TJVCSCompressedDiffSynProxyHighlighter.UpdateHighlight(ACompressedDiff: TJVCSCompressedDiff);
var
  I, J, K: Integer;
  Kind: THighlightKind;
begin
  for I := 0 to ACompressedDiff.Count - 1 do
    if ACompressedDiff[I].Kind in [cdtModifyAdd, cdtModifyDelete] then
    begin
      for J := 0 to Length(ACompressedDiff[I].Text) - 1 do
      begin
        if ACompressedDiff[I].Kind = cdtModifyDelete then
          Kind := hkDeleteLine
        else
          Kind := hkInsertLine;
        AddHighlightChar(I, J, Kind);
      end;
      for J := Low(ACompressedDiff[I].InlineDiffHighlight) to High(ACompressedDiff[I].InlineDiffHighlight) do
        for K := ACompressedDiff[I].InlineDiffHighlight[J].CharIndex to ACompressedDiff[I].InlineDiffHighlight[J].CharIndex + ACompressedDiff[I].InlineDiffHighlight[J].Length - 1 do
        begin
          if ACompressedDiff[I].Kind = cdtModifyDelete then
            Kind := hkDeleteChar
          else
            Kind := hkInsertChar;
          AddHighlightChar(I, K, Kind);
        end;
    end;
end;

end.
