(*-----------------------------------------------------------------------------
JEDI VCS 2.5 Beta 2026 (port Delphi 13) - mwPasLex.pas

TmwPasLex minimo (codigo novo, ver mwPasLexTypes.pas). API usada pelo cliente:
Origin (ponteiro para o texto ANSI terminado em #0), Next, NextNoJunk,
TokenID, Token (texto do token, inclusive comentarios e diretivas inteiros) e
LineNumber (base 0). O texto e lido como bytes (code page ANSI do sistema).
Licenca: MPL 1.1.
-----------------------------------------------------------------------------*)

unit mwPasLex;

interface

uses
  System.SysUtils, mwPasLexTypes;

type
  TmwPasLex = class(TObject)
  private
    FOrigin: PAnsiChar;
    FRun: Integer;
    FTokenPos: Integer;
    FTokenID: TptTokenKind;
    FLineNumber: Integer;
    FTokenLine: Integer;
    procedure SetOrigin(const Value: PAnsiChar);
    function GetToken: string;
    function Ch(AOffset: Integer = 0): AnsiChar; inline;
    procedure ScanIdentifier;
    procedure ScanBorComment;
    procedure ScanAnsiComment;
    procedure ScanDirective(const AText: string);
  public
    procedure Next;
    procedure NextNoJunk;
    function IsJunk: Boolean;
    property Origin: PAnsiChar read FOrigin write SetOrigin;
    property TokenID: TptTokenKind read FTokenID;
    property Token: string read GetToken;
    property LineNumber: Integer read FTokenLine;
    property RunPos: Integer read FRun;
    property TokenPos: Integer read FTokenPos;
  end;

implementation

type
  TKeywordMap = record
    Name: string;
    Kind: TptTokenKind;
  end;

const
  SpecialKeywords: array[0..7] of TKeywordMap = (
    (Name: 'unit'; Kind: ptUnit), (Name: 'uses'; Kind: ptUses),
    (Name: 'program'; Kind: ptProgram), (Name: 'library'; Kind: ptLibrary),
    (Name: 'in'; Kind: ptIn), (Name: 'export'; Kind: ptExport),
    (Name: 'exports'; Kind: ptExports), (Name: 'external'; Kind: ptExternal));

  // palavras reservadas do Delphi (as que nao tem token proprio viram ptKeyword)
  ReservedWords: array[0..58] of string = (
    'and', 'array', 'as', 'asm', 'begin', 'case', 'class', 'const',
    'constructor', 'destructor', 'dispinterface', 'div', 'do', 'downto',
    'else', 'end', 'except', 'file', 'finalization', 'finally', 'for',
    'function', 'goto', 'if', 'implementation', 'inherited', 'initialization',
    'inline', 'interface', 'is', 'label', 'mod', 'nil', 'not', 'object', 'of',
    'or', 'packed', 'procedure', 'property', 'raise', 'record', 'repeat',
    'resourcestring', 'set', 'shl', 'shr', 'string', 'then', 'threadvar', 'to',
    'try', 'type', 'until', 'var', 'while', 'with', 'xor', 'operator');

{ TmwPasLex }

function TmwPasLex.Ch(AOffset: Integer): AnsiChar;
begin
  Result := FOrigin[FRun + AOffset];
end;

procedure TmwPasLex.SetOrigin(const Value: PAnsiChar);
begin
  FOrigin := Value;
  FRun := 0;
  FLineNumber := 0;
  FTokenLine := 0;
  if FOrigin = nil then
    FTokenID := ptNull
  else
    Next;
end;

function TmwPasLex.GetToken: string;
var
  S: AnsiString;
begin
  if (FOrigin = nil) or (FRun <= FTokenPos) then
    Exit('');
  SetString(S, PAnsiChar(@FOrigin[FTokenPos]), FRun - FTokenPos);
  Result := string(S);
end;

function TmwPasLex.IsJunk: Boolean;
begin
  Result := FTokenID in JunkTokens;
end;

procedure TmwPasLex.NextNoJunk;
begin
  repeat
    Next;
  until not IsJunk;
end;

procedure TmwPasLex.ScanIdentifier;
var
  S: string;
  I: Integer;
begin
  while Ch in ['A'..'Z', 'a'..'z', '0'..'9', '_'] do
    Inc(FRun);
  S := LowerCase(GetToken);
  FTokenID := ptIdentifier;
  for I := Low(SpecialKeywords) to High(SpecialKeywords) do
    if SpecialKeywords[I].Name = S then
    begin
      FTokenID := SpecialKeywords[I].Kind;
      Exit;
    end;
  for I := Low(ReservedWords) to High(ReservedWords) do
    if ReservedWords[I] = S then
    begin
      FTokenID := ptKeyword;
      Exit;
    end;
end;

procedure TmwPasLex.ScanBorComment;
begin
  // FRun aponta para '{'
  while (Ch <> #0) and (Ch <> '}') do
  begin
    if Ch = #10 then
      Inc(FLineNumber);
    Inc(FRun);
  end;
  if Ch = '}' then
    Inc(FRun);
end;

procedure TmwPasLex.ScanAnsiComment;
begin
  // FRun aponta para '(*'
  Inc(FRun, 2);
  while (Ch <> #0) and not ((Ch = '*') and (Ch(1) = ')')) do
  begin
    if Ch = #10 then
      Inc(FLineNumber);
    Inc(FRun);
  end;
  if Ch <> #0 then
    Inc(FRun, 2);
end;

procedure TmwPasLex.ScanDirective(const AText: string);
var
  U: string;
begin
  U := UpperCase(AText);
  if (Pos('{$I ', U) = 1) or (Pos('{$INCLUDE ', U) = 1) or
    (Pos('(*$I ', U) = 1) or (Pos('(*$INCLUDE ', U) = 1) then
    FTokenID := ptIncludeDirect
  else
  if (Pos('{$R ', U) = 1) or (Pos('{$RESOURCE ', U) = 1) or
    (Pos('(*$R ', U) = 1) or (Pos('(*$RESOURCE ', U) = 1) then
    FTokenID := ptResourceDirect
  else
    FTokenID := ptCompDirect;
end;

procedure TmwPasLex.Next;
begin
  if FOrigin = nil then
  begin
    FTokenID := ptNull;
    Exit;
  end;
  FTokenPos := FRun;
  FTokenLine := FLineNumber;
  case Ch of
    #0:
      FTokenID := ptNull;
    #10:
      begin
        Inc(FRun);
        Inc(FLineNumber);
        FTokenID := ptCRLF;
      end;
    #13:
      begin
        Inc(FRun);
        if Ch = #10 then
          Inc(FRun);
        Inc(FLineNumber);
        FTokenID := ptCRLF;
      end;
    #1..#9, #11, #12, #14..#32:
      begin
        while Ch in [#1..#9, #11, #12, #14..#32] do
          Inc(FRun);
        FTokenID := ptSpace;
      end;
    'A'..'Z', 'a'..'z', '_', '&':
      begin
        if Ch = '&' then
          Inc(FRun);
        ScanIdentifier;
      end;
    '0'..'9':
      begin
        while Ch in ['0'..'9'] do
          Inc(FRun);
        FTokenID := ptNumber;
        if (Ch = '.') and (Ch(1) in ['0'..'9']) then
        begin
          Inc(FRun);
          while Ch in ['0'..'9', 'e', 'E', '+', '-'] do
            Inc(FRun);
          FTokenID := ptFloat;
        end;
      end;
    '$':
      begin
        Inc(FRun);
        while Ch in ['0'..'9', 'A'..'F', 'a'..'f'] do
          Inc(FRun);
        FTokenID := ptIntegerConst;
      end;
    '#':
      begin
        Inc(FRun);
        if Ch = '$' then
          Inc(FRun);
        while Ch in ['0'..'9', 'A'..'F', 'a'..'f'] do
          Inc(FRun);
        FTokenID := ptAsciiChar;
      end;
    '''':
      begin
        Inc(FRun);
        repeat
          while (Ch <> #0) and (Ch <> '''') and (Ch <> #13) and (Ch <> #10) do
            Inc(FRun);
          if Ch = '''' then
            Inc(FRun);
        until Ch <> '''';
        FTokenID := ptString;
      end;
    '{':
      begin
        ScanBorComment;
        if FOrigin[FTokenPos + 1] = '$' then
          ScanDirective(GetToken)
        else
          FTokenID := ptBorComment;
      end;
    '(':
      if Ch(1) = '*' then
      begin
        ScanAnsiComment;
        if FOrigin[FTokenPos + 2] = '$' then
          ScanDirective(GetToken)
        else
          FTokenID := ptAnsiComment;
      end
      else
      begin
        Inc(FRun);
        FTokenID := ptRoundOpen;
      end;
    '/':
      if Ch(1) = '/' then
      begin
        while not (Ch in [#0, #10, #13]) do
          Inc(FRun);
        FTokenID := ptSlashesComment;
      end
      else
      begin
        Inc(FRun);
        FTokenID := ptSymbol;
      end;
    ';':
      begin
        Inc(FRun);
        FTokenID := ptSemiColon;
      end;
    ',':
      begin
        Inc(FRun);
        FTokenID := ptComma;
      end;
    '.':
      begin
        Inc(FRun);
        FTokenID := ptPoint;
      end;
    ':':
      begin
        Inc(FRun);
        FTokenID := ptColon;
      end;
    ')':
      begin
        Inc(FRun);
        FTokenID := ptRoundClose;
      end;
    '[':
      begin
        Inc(FRun);
        FTokenID := ptSquareOpen;
      end;
    ']':
      begin
        Inc(FRun);
        FTokenID := ptSquareClose;
      end;
    '=':
      begin
        Inc(FRun);
        FTokenID := ptEqual;
      end;
  else
    begin
      Inc(FRun);
      FTokenID := ptSymbol;
    end;
  end;
end;

end.
