(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSCompressedDiffFrame.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2009/11/27  USchuster - new unit
2009/12/19  THuber    - D5 compatibility
2010/10/02  USchuster - fixed AV when no highlighter exists for the file (Mantis #5347)
2014/02/26  USchuster - changes for inline diffs
2014/03/01  USchuster - changes for D2009+/UniSynEdit

-----------------------------------------------------------------------------*)

unit JVCSCompressedDiffFrame;

{$I jedi.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  {$IFDEF HAS_UNIT_VARIANTS}
  Variants,
  {$ENDIF HAS_UNIT_VARIANTS}
  Dialogs, SynEdit, JVCSCompressedDiffUnit, SynHighlighterPas, JVCSLineHistoryHighlighterUnit,
  JVCSCompressedDiffSynProxy;

type
  TJVCSCompressedDiffFrm = class(TFrame)
  private
    { Private declarations }
    FExtension: string;
    FHighlighterProxy: TJVCSCompressedDiffSynProxyHighlighter;
    FHighlighters: TJVCSLineHistoryHighlighters;
    FInlineDiff: Boolean;
    FLines1: TStrings;
    FLines2: TStrings;
    FSynEdit: TSynEdit;
    FSynEditPlugin: TSynEditPlugin;
    FCompressedDiff: TJVCSCompressedDiff;
    procedure SynEditSpecialLineColors(Sender: TObject; Line: Integer;
      var Special: Boolean; var FG, BG: TColor);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Diff;
    property Extension: string read FExtension write FExtension;
    property Lines1: TStrings read FLines1 write FLines1;
    property Lines2: TStrings read FLines2 write FLines2;
  end;

implementation

{$R *.dfm}

type
  TGutterInfoPlugin = class(TSynEditPlugin)
  protected
    FCompressedDiff: TJVCSCompressedDiff;
    FFontColor: TColor;
    FRightLineNumberX: Integer;
    FSynEdit: TCustomSynEdit;
    procedure AfterPaint(ACanvas: TCanvas; const AClip: TRect;
      FirstLine, LastLine: Integer); override;
    procedure LinesInserted(FirstLine, Count: Integer); override;
    procedure LinesDeleted(FirstLine, Count: Integer); override;
  public
    constructor Create(ASynEdit: TCustomSynEdit);
    destructor Destroy; override;
    procedure UpdateGutterWidth;
    property CompressedDiff: TJVCSCompressedDiff read FCompressedDiff write FCompressedDiff;
    property FontColor: TColor read FFontColor write FFontColor;
  end;

{ TGutterInfoPlugin }

constructor TGutterInfoPlugin.Create(ASynEdit: TCustomSynEdit);
begin
  inherited Create(ASynEdit);
  FSynEdit := ASynEdit;
  FCompressedDiff := nil;
  FFontColor := clBlack;
end;

destructor TGutterInfoPlugin.Destroy;
begin
  inherited Destroy;
end;

procedure TGutterInfoPlugin.AfterPaint(ACanvas: TCanvas; const AClip: TRect;
  FirstLine, LastLine: Integer);
var
  LH, Y, W: Integer;
  S: string;
begin
  LH := FSynEdit.LineHeight;
  Y := LH * (FirstLine - FSynEdit.TopLine);
  while FirstLine <= LastLine do
  begin
    ACanvas.Brush.Style := bsClear;
    ACanvas.Font.Assign(FSynEdit.Font);
    ACanvas.Font.Color := FFontColor;
    if Assigned(FCompressedDiff) and (FCompressedDiff.Count > FirstLine - 1) then
    begin
      if FCompressedDiff[FirstLine - 1].Kind = cdtBlockDivider then
      begin
        ACanvas.Pen.Color := ACanvas.Font.Color;
        ACanvas.MoveTo(2, Y + LH div 2);
        {$IFDEF UNISYNEDIT}
        ACanvas.LineTo(FSynEdit.Gutter.Width - 2, Y + LH div 2);
        {$ELSE}
        ACanvas.LineTo(FSynEdit.GutterWidth - 2, Y + LH div 2);
        {$ENDIF}
      end
      else
      if FCompressedDiff[FirstLine - 1].Kind in [cdtNone, cdtAdd, cdtModifyAdd] then
      begin
        S := IntToStr(FCompressedDiff[FirstLine - 1].LineNumber2);
        W := ACanvas.TextWidth(S);
        ACanvas.TextOut(FRightLineNumberX - W, Y, S);
      end;
      if FCompressedDiff[FirstLine - 1].Kind in [cdtAdd, cdtModifyAdd] then
        ACanvas.TextOut(FRightLineNumberX, Y, '+')
      else
      if FCompressedDiff[FirstLine - 1].Kind in [cdtDelete, cdtModifyDelete] then
        ACanvas.TextOut(FRightLineNumberX, Y, '-');
    end;
    Inc(FirstLine);
    Inc(Y, LH);
  end;
end;

procedure TGutterInfoPlugin.LinesDeleted(FirstLine, Count: Integer);
begin
end;

procedure TGutterInfoPlugin.LinesInserted(FirstLine, Count: Integer);
begin
end;

procedure TGutterInfoPlugin.UpdateGutterWidth;
var
  FontBitmap: TBitmap;
  S: string;
  I, GutterWidth, CurrentWidth, MaxLineNumberWidth, MaxKindWidth: Integer;
begin
  FontBitmap := TBitmap.Create;
  try
    FontBitmap.Canvas.Font.Assign(FSynEdit.Font);
    GutterWidth := 0;
    MaxLineNumberWidth := 0;
    if Assigned(FCompressedDiff) then
    begin
      for I := 0 to Pred(FCompressedDiff.Count) do
        if FCompressedDiff[I].LineNumber2 >= 0 then
        begin
          S := IntToStr(FCompressedDiff[I].LineNumber2);
          CurrentWidth := FontBitmap.Canvas.TextWidth(S);
          if CurrentWidth > MaxLineNumberWidth then
            MaxLineNumberWidth := CurrentWidth;
        end;
      CurrentWidth := FontBitmap.Canvas.TextWidth('+');
      MaxKindWidth := CurrentWidth;
      CurrentWidth := FontBitmap.Canvas.TextWidth('-');
      if CurrentWidth > MaxKindWidth then
        MaxKindWidth := CurrentWidth;
      GutterWidth := MaxLineNumberWidth + 2 + MaxKindWidth + 2;
      FRightLineNumberX := MaxLineNumberWidth;
    end;
  finally
    FontBitmap.Free;
  end;
  FSynEdit.Gutter.Width := GutterWidth;
end;

{ TJVCSCompressedDiffFrm }

constructor TJVCSCompressedDiffFrm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FLines1 := nil;
  FLines2 := nil;
  FSynEdit := TSynEdit.Create(Self);
  FSynEdit.Parent := Self;
  FSynEdit.Align := alClient;
  FSynEdit.ReadOnly := True;
  FSynEdit.DoubleBuffered := True;
  FSynEdit.ActiveLineColor := $E6FFFA;
  FSynEditPlugin := TGutterInfoPlugin.Create(FSynEdit);
  FCompressedDiff := TJVCSCompressedDiff.Create;
  TGutterInfoPlugin(FSynEditPlugin).CompressedDiff := FCompressedDiff;
  FHighlighters := TJVCSLineHistoryHighlighters.Create;
  FSynEdit.OnSpecialLineColors := SynEditSpecialLineColors;
  FHighlighterProxy := TJVCSCompressedDiffSynProxyHighlighter.Create(Self);
  FInlineDiff := True;
end;

destructor TJVCSCompressedDiffFrm.Destroy;
begin
  FHighlighters.Free;
  TGutterInfoPlugin(FSynEditPlugin).CompressedDiff := nil;
  FCompressedDiff.Free;
  inherited Destroy;
end;

procedure TJVCSCompressedDiffFrm.Diff;
var
  CurrentHighlighter: TJVCSLineHistoryHighlighter;
begin
  FCompressedDiff.InlineDiffHighlight := FInlineDiff;
  FCompressedDiff.Diff(FLines1, FLines2);
  FSynEdit.Lines.BeginUpdate;
  try
    FSynEdit.Lines.Assign(FCompressedDiff.Text);

    CurrentHighlighter := FHighlighters.GetHighlighterByExtension(FExtension);
    if Assigned(CurrentHighlighter) then
    begin
      FSynEdit.Gutter.Color := CurrentHighlighter.Color;
      TGutterInfoPlugin(FSynEditPlugin).FontColor := CurrentHighlighter.FontColor;
      FSynEdit.Highlighter := CurrentHighlighter.SynHighlighter;
    end
    else
    begin
      FSynEdit.Gutter.Color := clBtnFace;
      TGutterInfoPlugin(FSynEditPlugin).FontColor := clWindowText;
      FSynEdit.Highlighter := nil;
    end;

    if FInlineDiff and Assigned(FSynEdit.Highlighter) then
    begin
      FHighlighterProxy.InternalHighlighter := FSynEdit.Highlighter;
      FSynEdit.Highlighter := FHighlighterProxy;
      FHighlighterProxy.UpdateHighlight(FCompressedDiff);
    end;

    TGutterInfoPlugin(FSynEditPlugin).UpdateGutterWidth;
  finally
    FSynEdit.Lines.EndUpdate;
  end;
end;

procedure TJVCSCompressedDiffFrm.SynEditSpecialLineColors(Sender: TObject; Line: Integer;
  var Special: Boolean; var FG, BG: TColor);
var
  Kind: TJVCSCompressedDiffKind;
begin
  if (FCompressedDiff.Count > Line - 1) and (FCompressedDiff[Line - 1].Kind <> cdtNone) then
  begin
    Kind := TJVCSCompressedDiff(FCompressedDiff)[Line - 1].Kind;
    case Kind of
      cdtAdd:          BG := RGB($80, $FF, $80);
      cdtDelete:       BG := RGB($FF, $80, $80);
      cdtModifyAdd:    BG := RGB($80, $FF, $80);//RGB($80, $FF, $FF);
      cdtModifyDelete: BG := RGB($FF, $80, $80);//RGB($FF, $80, $FF);
    end;
    Special := not FInlineDiff or (Kind in [cdtAdd, cdtDelete]);
  end;
end;

end.
