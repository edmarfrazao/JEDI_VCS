(*-----------------------------------------------------------------------------
JEDI VCS 2.5 Beta 2026 (port Delphi 13) - JVCSSynEditUtils.pas
Ajudas para o SynEdit pyscripter (src\comp\synedit). Licenca: MPL 1.1.
-----------------------------------------------------------------------------*)

unit JVCSSynEditUtils;

interface

uses
  SynEdit;

// No SynEdit pyscripter a largura do gutter e a soma das bandas (Gutter.Width
// nao existe mais). Os frames de Line History e Compressed Diff desenham o
// gutter num plugin (AfterPaint): aqui as bandas padrao ficam ocultas e uma
// banda gbkCustom recebe a largura pedida.
procedure SetCustomGutterBandWidth(AEdit: TCustomSynEdit; AWidth: Integer);

implementation

uses
  SynEditMiscClasses;

procedure SetCustomGutterBandWidth(AEdit: TCustomSynEdit; AWidth: Integer);
var
  I: Integer;
  Band: TSynGutterBand;
begin
  Band := nil;
  for I := 0 to AEdit.Gutter.Bands.Count - 1 do
    if AEdit.Gutter.Bands[I].Kind = gbkCustom then
      Band := AEdit.Gutter.Bands[I]
    else
      AEdit.Gutter.Bands[I].Visible := False;
  if Band = nil then
  begin
    Band := TSynGutterBand(AEdit.Gutter.Bands.Add);
    Band.Kind := gbkCustom;
  end;
  Band.Width := AWidth;
  Band.Visible := True;
end;

end.
