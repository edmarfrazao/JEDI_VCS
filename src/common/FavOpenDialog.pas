(*-----------------------------------------------------------------------------
JEDI VCS 2.5 Beta 2026 (port Delphi 13) - FavOpenDialog.pas

Reimplementacao nativa (codigo novo, sem o fonte original de Markus Stephany)
da API de TFavOpenDialog/TFavSaveDialog usada pelo cliente. O dialogo e o
TOpenDialog/TSaveDialog da VCL (dialogo moderno do Windows); a lista de pastas
"favoritas" (MRU, gravada pelo chamador via TJVCSMruList) e usada so para a
pasta inicial: a 1a entrada vira o InitialDir quando o chamador nao define um, e
a pasta escolhida volta para o topo da lista.

Licenca: MPL 1.1 (como o restante do JEDI VCS).
-----------------------------------------------------------------------------*)

unit FavOpenDialog;

interface

uses
  System.SysUtils, System.Classes, Vcl.Dialogs;

type
  TFavOpenDialog = class(TOpenDialog)
  private
    FMaxCount: Integer;
    FFavorites: TStrings;
    FShowFullPath: Boolean;
    FSetInitDirFrom1st: Boolean;
    procedure SetFavorites(const Value: TStrings);
  protected
    procedure BeforeExecute;
    procedure AfterExecute;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Execute: Boolean; overload; override;
  published
    property MaxCount: Integer read FMaxCount write FMaxCount default 10;
    property ShowFullPath: Boolean read FShowFullPath write FShowFullPath default True;
    property Favorites: TStrings read FFavorites write SetFavorites;
    property SetInitDirFrom1st: Boolean read FSetInitDirFrom1st write FSetInitDirFrom1st default True;
  end;

  TFavSaveDialog = class(TFavOpenDialog)
  public
    function Execute: Boolean; overload; override;
  end;

implementation

{ TFavOpenDialog }

constructor TFavOpenDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FFavorites := TStringList.Create;
  FMaxCount := 10;
  FShowFullPath := True;
  FSetInitDirFrom1st := True;
end;

destructor TFavOpenDialog.Destroy;
begin
  FFavorites.Free;
  inherited Destroy;
end;

procedure TFavOpenDialog.SetFavorites(const Value: TStrings);
begin
  FFavorites.Assign(Value);
end;

procedure TFavOpenDialog.BeforeExecute;
begin
  if FSetInitDirFrom1st and ((InitialDir = '') or not DirectoryExists(InitialDir)) and
    (FFavorites.Count > 0) and DirectoryExists(FFavorites[0]) then
    InitialDir := FFavorites[0];
end;

procedure TFavOpenDialog.AfterExecute;
var
  Dir: string;
  Idx: Integer;
begin
  if FileName = '' then
    Exit;
  Dir := ExtractFilePath(FileName);
  if Dir = '' then
    Exit;
  Idx := FFavorites.IndexOf(Dir);
  if Idx >= 0 then
    FFavorites.Delete(Idx);
  FFavorites.Insert(0, Dir);
  if FMaxCount > 0 then
    while FFavorites.Count > FMaxCount do
      FFavorites.Delete(FFavorites.Count - 1);
end;

function TFavOpenDialog.Execute: Boolean;
begin
  BeforeExecute;
  Result := inherited Execute;
  if Result then
    AfterExecute;
end;

{ TFavSaveDialog }

function TFavSaveDialog.Execute: Boolean;
var
  Dlg: TSaveDialog;
begin
  BeforeExecute;
  Dlg := TSaveDialog.Create(nil);
  try
    Dlg.Title := Title;
    Dlg.Filter := Filter;
    Dlg.FilterIndex := FilterIndex;
    Dlg.InitialDir := InitialDir;
    Dlg.FileName := FileName;
    Dlg.DefaultExt := DefaultExt;
    Dlg.Options := Options;
    Dlg.OptionsEx := OptionsEx;
    Result := Dlg.Execute;
    if Result then
    begin
      FileName := Dlg.FileName;
      FilterIndex := Dlg.FilterIndex;
      Files.Assign(Dlg.Files);
      AfterExecute;
    end;
  finally
    Dlg.Free;
  end;
end;

end.
