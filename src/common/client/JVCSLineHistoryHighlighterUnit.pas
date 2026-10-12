(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSLineHistoryHighlighterUnit.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2006/05/28  USchuster - new unit
2006/11/05  USchuster - changes for SynEdit 2.0.3
2009/01/01  USchuster - changes for D2009/UniSynEdit

-----------------------------------------------------------------------------*)

unit JVCSLineHistoryHighlighterUnit;

{$I jedi.inc}

interface

uses
  SysUtils, Classes, Graphics, Contnrs, SynEditHighlighter;

type
  TJVCSLineHistoryHighlighter = class(TObject)
  private
    FSynHighlighter: TSynCustomHighlighter;
    FColor: TColor;
    FFontColor: TColor;
  public
    constructor Create(AHighlighterClass: TSynCustomHighlighterClass);
    destructor Destroy; override;
    property SynHighlighter: TSynCustomHighlighter read FSynHighlighter;
    property Color: TColor read FColor write FColor;
    property FontColor: TColor read FFontColor write FFontColor;
  end;

  TJVCSLineHistoryHighlighters = class(TObject)
  private
    FItems: TObjectList;
    procedure CreateHighlighters;
    function GetCount: Integer;
    function GetDefaultHighlighter: TJVCSLineHistoryHighlighter;
    function GetItems(AIndex: Integer): TJVCSLineHistoryHighlighter;
  public
    constructor Create;
    destructor Destroy; override;
    function GetHighlighterByExtension(const AExt: string): TJVCSLineHistoryHighlighter;
    property DefaultHighligther: TJVCSLineHistoryHighlighter read GetDefaultHighlighter;
    property Count: Integer read GetCount;
    property Items[AIndex: Integer]: TJVCSLineHistoryHighlighter read GetItems; default;
  end;

implementation

uses
  SynHighlighterADSP21xx, SynHighlighterAsm, SynHighlighterAWK, SynHighlighterBaan,
  SynHighlighterBat, SynHighlighterCAC, SynHighlighterCache, SynHighlighterCobol,
  SynHighlighterCPM, SynHighlighterCpp, SynHighlighterCS, SynHighlighterCss,
  SynHighlighterDfm, SynHighlighterDml, SynHighlighterFortran, SynHighlighterFoxpro,
  SynHighlighterGalaxy, SynHighlighterGeneral, SynHighlighterGWS, SynHighlighterHaskell,
  SynHighlighterHC11, SynHighlighterHP48, SynHighlighterHtml, SynHighlighterIDL,
  SynHighlighterIni, SynHighlighterInno, SynHighlighterJava, SynHighlighterJScript,
  SynHighlighterKix, SynHighlighterLDraw, SynHighlighterM3, SynHighlighterModelica,
  {$IFNDEF UNISYNEDIT}SynHighlighterMPerl, {$ENDIF} SynHighlighterMsg, SynHighlighterMulti, SynHighlighterPas,
  SynHighlighterPerl, SynHighlighterPHP, SynHighlighterProgress, SynHighlighterPython,
  SynHighlighterRuby, SynHighlighterSDD, SynHighlighterSml, SynHighlighterSQL,
  SynHighlighterST, SynHighlighterTclTk, SynHighlighterTeX, SynHighlighterUNIXShellScript,
  SynHighlighterUnreal, SynHighlighterVB, SynHighlighterVBScript, SynHighlighterXML,
  SynHighlighterDOT, SynHighlighterEiffel, SynHighlighterRC, SynHighlighterURI,
  SynHighlighterVrml97;

constructor TJVCSLineHistoryHighlighter.Create(AHighlighterClass: TSynCustomHighlighterClass);
begin
  inherited Create;
  FSynHighlighter := AHighlighterClass.Create(nil);
  FColor := clBtnFace;
  FFontColor := clWindowText;
end;

destructor TJVCSLineHistoryHighlighter.Destroy;
begin
  FSynHighlighter.Free;
  inherited Destroy;
end;

constructor TJVCSLineHistoryHighlighters.Create;
begin
  inherited Create;
  FItems := TObjectList.Create;
  CreateHighlighters;
end;

destructor TJVCSLineHistoryHighlighters.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TJVCSLineHistoryHighlighters.CreateHighlighters;
var
  JVCSSynPas: TJVCSLineHistoryHighlighter;
  SynPas: TSynPasSyn;
begin
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynPasSyn));
  JVCSSynPas := TJVCSLineHistoryHighlighter(FItems.Last);
  SynPas := TSynPasSyn(JVCSSynPas.SynHighlighter);

  //D2005 color sheme
  {
  JVCSSynPas.Color := $F4F4F4;
  JVCSSynPas.FontColor := $CC9999;

  SynPas.DirectiveAttri.Foreground := clTeal;
  SynPas.DirectiveAttri.Style := [];
  SynPas.KeyAttri.Foreground := clNavy;
  SynPas.CommentAttri.Foreground := clGreen;
  SynPas.StringAttri.Foreground := clBlue;
  SynPas.NumberAttri.Foreground := clBlue;
  SynPas.FloatAttri.Foreground := clBlue;
  SynPas.HexAttri.Foreground := clBlue;
  }
  //D7 color sheme
  JVCSSynPas.Color := clBtnFace;
  JVCSSynPas.FontColor := clBlack;

  SynPas.DirectiveAttri.Foreground := clGreen;
  SynPas.DirectiveAttri.Style := [];
  SynPas.KeyAttri.Foreground := clBlack;
  SynPas.CommentAttri.Foreground := clNavy;
  SynPas.StringAttri.Foreground := clNavy;
  SynPas.NumberAttri.Foreground := clNavy;
  SynPas.FloatAttri.Foreground := clNavy;
  SynPas.HexAttri.Foreground := clNavy;

  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynADSP21xxSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynAsmSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynAWKSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynBaanSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynBatSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynCACSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynCacheSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynCobolSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynCPMSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynCppSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynCSSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynCssSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynDfmSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynDmlSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynFortranSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynFoxproSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynGalaxySyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynGeneralSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynGWScriptSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynHaskellSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynHC11Syn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynHP48Syn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynHTMLSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynIdlSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynIniSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynInnoSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynJavaSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynJScriptSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynKixSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynLDRSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynM3Syn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynModelicaSyn));
  {$IFNDEF UNISYNEDIT}
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynMPerlSyn));
  {$ENDIF ~UNISYNEDIT}
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynMsgSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynMultiSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynPasSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynPerlSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynPHPSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynProgressSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynPythonSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynRubySyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynSDDSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynSMLSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynSQLSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynSTSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynTclTkSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynTeXSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynUNIXShellScriptSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynUnrealSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynVBSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynVBScriptSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynXMLSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynDOTSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynEiffelSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynRCSyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynURISyn));
  FItems.Add(TJVCSLineHistoryHighlighter.Create(TSynVrml97Syn));
end;

function TJVCSLineHistoryHighlighters.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TJVCSLineHistoryHighlighters.GetDefaultHighlighter: TJVCSLineHistoryHighlighter;
begin
  Result := GetHighlighterByExtension('.pas');
end;

function TJVCSLineHistoryHighlighters.GetHighlighterByExtension(const AExt: string): TJVCSLineHistoryHighlighter;
var
  I, P, ExtLen: Integer;
  Extension, S: string;
begin
  Result := nil;
  Extension := LowerCase(AExt);
  ExtLen := Length(Extension);
  for I := 0 to Pred(Count) do
  begin
    S := Items[I].SynHighlighter.DefaultFilter;
    P := Pos('|', S);
    if P > 0 then
    begin
      Delete(S, 1, P);
      P := Pos(Extension, S);
      if (P > 0) and ((P + ExtLen > Length(S)) or (S[P + ExtLen] = ';')) then
      begin
        Result := Items[I];
        Break;
      end;
    end;
  end;
end;

function TJVCSLineHistoryHighlighters.GetItems(AIndex: Integer): TJVCSLineHistoryHighlighter;
begin
  Result := TJVCSLineHistoryHighlighter(FItems[AIndex]);
end;

end.