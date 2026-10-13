(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSUIScale.pas

The Initial Developer of the original code (JEDI VCS v2026) is the JEDI VCS
port team (2026).

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Purpose:
  Fonte e tamanho da interface do cliente JEDI VCS (EXE, Diff e DLL da IDE):
  - fonte da interface (nome + tamanho em pt) ou escala em %;
  - fonte dos menus (owner-draw quando difere do padrao do Windows);
  - fonte dos editores (SynEdit: Diff, Line History, visualizadores).
  Ver doc\client\Requisito-Tamanho-Fonte.md e doc\client\Port-Diff.md.

Persistencia (padrao: registro, HKCU\Software\JEDI\JEDIVCS\Options):
  UIFontScale    Integer  escala em % (100 = sem escala; 80..250)
  UIFontName     String   fonte da interface ('' = Screen.MessageFont)
  UIFontSize     Integer  tamanho em pt (0 = usa UIFontScale); prevalece
  MenuFontName   String   fonte dos menus ('' = segue a interface)
  MenuFontSize   Integer  tamanho dos menus em pt (0 = segue a interface)
  EditorFontName String   fonte dos editores ('' = Consolas)
  EditorFontSize Integer  tamanho dos editores em pt (0 = 10)
  O EXE e a DLL podem redirecionar a leitura/gravacao para a ConfigStorage
  (jvcsReadInteger/jvcsWriteInteger/...) atribuindo JVCSUIReadInteger etc.,
  e o nome da chave em JVCSUIOptionsKey (sBaseRegistryKey + crbOptions).

Unit history:

2026/10/12  v2026      - nova unit (fase F3, piloto no JEDIVCSDiff)

-----------------------------------------------------------------------------*)

unit JVCSUIScale;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Menus,
  StdCtrls, ImgList, Math;

const
  cJVCSUIOptionsKey = 'Software\JEDI\JEDIVCS\Options';

  cJVCSUIFontScale    = 'UIFontScale';
  cJVCSUIFontName     = 'UIFontName';
  cJVCSUIFontSize     = 'UIFontSize';
  cJVCSMenuFontName   = 'MenuFontName';
  cJVCSMenuFontSize   = 'MenuFontSize';
  cJVCSEditorFontName = 'EditorFontName';
  cJVCSEditorFontSize = 'EditorFontSize';

  cJVCSUIScaleMin = 80;
  cJVCSUIScaleMax = 250;
  cJVCSUIScaleDefault = 100;
  cJVCSUIScaleSteps: array [0..4] of Integer = (100, 125, 150, 175, 200);

  cJVCSDefaultEditorFontName = 'Consolas';
  cJVCSDefaultEditorFontSize = 10;

type
  { assinaturas iguais as de ConfigStorage (jvcsReadInteger etc.) }
  TJVCSUIReadIntegerFunc = function(const Key, Name: string; Def: Integer): Integer;
  TJVCSUIWriteIntegerFunc = function(const Key, Name: string; Value: Integer): Boolean;
  TJVCSUIReadStringFunc = function(const Key, Name: string; Def: string): string;
  TJVCSUIWriteStringFunc = function(const Key, Name, Value: string): Boolean;

  TJVCSUIFontSettings = record
    Scale: Integer;           // %, 100 = padrao
    UIFontName: string;       // '' = fonte do sistema (Screen.MessageFont)
    UIFontSize: Integer;      // pt; 0 = tamanho do sistema * Scale
    MenuFontName: string;     // '' = segue a interface
    MenuFontSize: Integer;    // pt; 0 = segue a interface
    EditorFontName: string;   // '' = Consolas
    EditorFontSize: Integer;  // pt; 0 = 10
    procedure SetDefaults;
    function IsDefaultUI: Boolean;
    function IsDefaultMenu: Boolean;
    function EffectiveUIFontName: string;
    function EffectiveUIFontSize: Integer;
    function EffectiveMenuFontName: string;
    function EffectiveMenuFontSize: Integer;
    function EffectiveEditorFontName: string;
    function EffectiveEditorFontSize: Integer;
  end;

var
  { armazenamento: por padrao o registro (HKCU); o EXE/DLL podem trocar }
  JVCSUIOptionsKey: string = cJVCSUIOptionsKey;
  JVCSUIReadInteger: TJVCSUIReadIntegerFunc = nil;
  JVCSUIWriteInteger: TJVCSUIWriteIntegerFunc = nil;
  JVCSUIReadString: TJVCSUIReadStringFunc = nil;
  JVCSUIWriteString: TJVCSUIWriteStringFunc = nil;

{ leitura/gravacao das preferencias }
function JVCSUILoadFontSettings: TJVCSUIFontSettings;
procedure JVCSUISaveFontSettings(const ASettings: TJVCSUIFontSettings);

{ preferencias em uso (carregadas por JVCSUIInitialize ou definidas por JVCSUISetFontSettings) }
function JVCSUIFontSettings: TJVCSUIFontSettings;
{ define as preferencias em uso; ApplyNow reaplica em todos os forms abertos }
procedure JVCSUISetFontSettings(const ASettings: TJVCSUIFontSettings; ApplyNow: Boolean = True);
{ carrega as preferencias do armazenamento e ajusta Screen.MenuFont/HintFont }
procedure JVCSUIInitialize;

{ aplica a fonte da interface a um form (fonte, tamanho e escala dos controles).
  KeepFormSize = True para janelas principais redimensionaveis (so o conteudo
  acompanha). Pode ser chamada de novo (reaplica a partir do estado atual). }
procedure JVCSUIApplyToForm(AForm: TCustomForm; KeepFormSize: Boolean = False);
{ reaplica em todos os forms de Screen.Forms }
procedure JVCSUIApplyToAllForms;
{ menus: com fonte/tamanho padrao nao mexe em nada (desenho nativo); senao liga
  owner-draw com a fonte de menu efetiva }
procedure JVCSUIApplyToMenu(AMenu: TMenu);
{ fonte do editor (SynEdit.Font, TMemo.Font, ...) }
procedure JVCSUIAssignEditorFont(AFont: TFont);
{ fonte de menu efetiva (para quem desenha menus/listas) }
procedure JVCSUIAssignMenuFont(AFont: TFont);

{ escala em % -> texto ('125%') e o contrario }
function JVCSUIScaleToText(AScale: Integer): string;
function JVCSUITextToScale(const AText: string; ADefault: Integer): Integer;

implementation

uses
  Registry, Types, Themes;

var
  GSettings: TJVCSUIFontSettings;
  GSystemMenuFont: TFont = nil;

//=== armazenamento padrao (registro HKCU) ======================================

function RegReadInteger(const Key, Name: string; Def: Integer): Integer;
var
  Reg: TRegistry;
  S: string;
begin
  Result := Def;
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKeyReadOnly(Key) and Reg.ValueExists(Name) then
    try
      case Reg.GetDataType(Name) of
        rdInteger: Result := Reg.ReadInteger(Name);
        rdString, rdExpandString:
          begin
            S := Reg.ReadString(Name);
            Result := StrToIntDef(Trim(S), Def);
          end;
      end;
    except
      Result := Def;
    end;
  finally
    Reg.Free;
  end;
end;

function RegWriteInteger(const Key, Name: string; Value: Integer): Boolean;
var
  Reg: TRegistry;
begin
  Result := False;
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey(Key, True) then
    begin
      Reg.WriteInteger(Name, Value);
      Result := True;
    end;
  finally
    Reg.Free;
  end;
end;

function RegReadString(const Key, Name: string; Def: string): string;
var
  Reg: TRegistry;
begin
  Result := Def;
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKeyReadOnly(Key) and Reg.ValueExists(Name) then
    try
      case Reg.GetDataType(Name) of
        rdString, rdExpandString: Result := Reg.ReadString(Name);
        rdInteger: Result := IntToStr(Reg.ReadInteger(Name));
      end;
    except
      Result := Def;
    end;
  finally
    Reg.Free;
  end;
end;

function RegWriteString(const Key, Name, Value: string): Boolean;
var
  Reg: TRegistry;
begin
  Result := False;
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey(Key, True) then
    begin
      Reg.WriteString(Name, Value);
      Result := True;
    end;
  finally
    Reg.Free;
  end;
end;

//=== TJVCSUIFontSettings =======================================================

procedure TJVCSUIFontSettings.SetDefaults;
begin
  Scale := cJVCSUIScaleDefault;
  UIFontName := '';
  UIFontSize := 0;
  MenuFontName := '';
  MenuFontSize := 0;
  EditorFontName := '';
  EditorFontSize := 0;
end;

function TJVCSUIFontSettings.IsDefaultUI: Boolean;
begin
  Result := (UIFontName = '') and (UIFontSize = 0) and (Scale = cJVCSUIScaleDefault);
end;

function TJVCSUIFontSettings.IsDefaultMenu: Boolean;
begin
  Result := IsDefaultUI and (MenuFontName = '') and (MenuFontSize = 0);
end;

function TJVCSUIFontSettings.EffectiveUIFontName: string;
begin
  if UIFontName <> '' then
    Result := UIFontName
  else
    Result := Screen.MessageFont.Name;
end;

function TJVCSUIFontSettings.EffectiveUIFontSize: Integer;
begin
  if UIFontSize > 0 then
    Result := UIFontSize
  else
    Result := MulDiv(Abs(Screen.MessageFont.Size), Scale, 100);
  if Result < 6 then
    Result := 6;
end;

function TJVCSUIFontSettings.EffectiveMenuFontName: string;
begin
  if MenuFontName <> '' then
    Result := MenuFontName
  else
  if UIFontName <> '' then
    Result := UIFontName
  else
  if Assigned(GSystemMenuFont) then
    Result := GSystemMenuFont.Name
  else
    Result := Screen.MenuFont.Name;
end;

function TJVCSUIFontSettings.EffectiveMenuFontSize: Integer;
var
  SysSize: Integer;
begin
  if MenuFontSize > 0 then
    Result := MenuFontSize
  else
  if UIFontSize > 0 then
    Result := UIFontSize
  else
  begin
    if Assigned(GSystemMenuFont) then
      SysSize := Abs(GSystemMenuFont.Size)
    else
      SysSize := Abs(Screen.MenuFont.Size);
    Result := MulDiv(SysSize, Scale, 100);
  end;
  if Result < 6 then
    Result := 6;
end;

function TJVCSUIFontSettings.EffectiveEditorFontName: string;
begin
  if EditorFontName <> '' then
    Result := EditorFontName
  else
    Result := cJVCSDefaultEditorFontName;
end;

function TJVCSUIFontSettings.EffectiveEditorFontSize: Integer;
begin
  if EditorFontSize > 0 then
    Result := EditorFontSize
  else
    Result := cJVCSDefaultEditorFontSize;
end;

//=== leitura / gravacao ========================================================

function ClampScale(AScale: Integer): Integer;
begin
  Result := AScale;
  if Result < cJVCSUIScaleMin then
    Result := cJVCSUIScaleMin;
  if Result > cJVCSUIScaleMax then
    Result := cJVCSUIScaleMax;
end;

function JVCSUILoadFontSettings: TJVCSUIFontSettings;
var
  K: string;
begin
  Result.SetDefaults;
  K := JVCSUIOptionsKey;
  Result.Scale := ClampScale(JVCSUIReadInteger(K, cJVCSUIFontScale, cJVCSUIScaleDefault));
  Result.UIFontName := Trim(JVCSUIReadString(K, cJVCSUIFontName, ''));
  Result.UIFontSize := JVCSUIReadInteger(K, cJVCSUIFontSize, 0);
  Result.MenuFontName := Trim(JVCSUIReadString(K, cJVCSMenuFontName, ''));
  Result.MenuFontSize := JVCSUIReadInteger(K, cJVCSMenuFontSize, 0);
  Result.EditorFontName := Trim(JVCSUIReadString(K, cJVCSEditorFontName, ''));
  Result.EditorFontSize := JVCSUIReadInteger(K, cJVCSEditorFontSize, 0);
  if (Result.UIFontSize < 0) or (Result.UIFontSize > 72) then
    Result.UIFontSize := 0;
  if (Result.MenuFontSize < 0) or (Result.MenuFontSize > 72) then
    Result.MenuFontSize := 0;
  if (Result.EditorFontSize < 0) or (Result.EditorFontSize > 72) then
    Result.EditorFontSize := 0;
end;

procedure JVCSUISaveFontSettings(const ASettings: TJVCSUIFontSettings);
var
  K: string;
begin
  K := JVCSUIOptionsKey;
  JVCSUIWriteInteger(K, cJVCSUIFontScale, ClampScale(ASettings.Scale));
  JVCSUIWriteString(K, cJVCSUIFontName, ASettings.UIFontName);
  JVCSUIWriteInteger(K, cJVCSUIFontSize, ASettings.UIFontSize);
  JVCSUIWriteString(K, cJVCSMenuFontName, ASettings.MenuFontName);
  JVCSUIWriteInteger(K, cJVCSMenuFontSize, ASettings.MenuFontSize);
  JVCSUIWriteString(K, cJVCSEditorFontName, ASettings.EditorFontName);
  JVCSUIWriteInteger(K, cJVCSEditorFontSize, ASettings.EditorFontSize);
end;

function JVCSUIFontSettings: TJVCSUIFontSettings;
begin
  Result := GSettings;
end;

procedure UpdateScreenFonts;
begin
  if not Assigned(GSystemMenuFont) then
  begin
    GSystemMenuFont := TFont.Create;
    GSystemMenuFont.Assign(Screen.MenuFont);
  end;
  if GSettings.IsDefaultMenu then
    Screen.MenuFont.Assign(GSystemMenuFont)
  else
  begin
    Screen.MenuFont.Name := GSettings.EffectiveMenuFontName;
    Screen.MenuFont.Size := GSettings.EffectiveMenuFontSize;
  end;
end;

procedure JVCSUISetFontSettings(const ASettings: TJVCSUIFontSettings; ApplyNow: Boolean);
begin
  GSettings := ASettings;
  GSettings.Scale := ClampScale(GSettings.Scale);
  UpdateScreenFonts;
  if ApplyNow then
    JVCSUIApplyToAllForms;
end;

procedure JVCSUIInitialize;
begin
  JVCSUISetFontSettings(JVCSUILoadFontSettings, False);
end;

//=== forms =====================================================================

type
  TControlAccess = class(TControl);

{ troca o nome da fonte nos controles com fonte propria que usavam a fonte do form }
procedure RenameFonts(AControl: TWinControl; const OldName, NewName: string);
var
  I: Integer;
  C: TControl;
begin
  for I := 0 to AControl.ControlCount - 1 do
  begin
    C := AControl.Controls[I];
    if (not TControlAccess(C).ParentFont) and
       SameText(TControlAccess(C).Font.Name, OldName) then
      TControlAccess(C).Font.Name := NewName;
    if C is TWinControl then
      RenameFonts(TWinControl(C), OldName, NewName);
  end;
end;

procedure JVCSUIApplyToForm(AForm: TCustomForm; KeepFormSize: Boolean);
var
  OldName, NewName: string;
  OldHeight, NewHeight, W, H, PPI: Integer;
  F: TForm;
begin
  if not (AForm is TForm) then
    Exit;
  F := TForm(AForm);
  PPI := F.CurrentPPI;
  if PPI <= 0 then
    PPI := Screen.PixelsPerInch;
  OldName := F.Font.Name;
  NewName := GSettings.EffectiveUIFontName;
  OldHeight := Abs(F.Font.Height);
  NewHeight := MulDiv(GSettings.EffectiveUIFontSize, PPI, 72);
  if OldHeight <= 0 then
    OldHeight := NewHeight;

  F.DisableAlign;
  try
    if not SameText(OldName, NewName) then
    begin
      RenameFonts(F, OldName, NewName);
      F.Font.Name := NewName;
    end;
    if NewHeight <> OldHeight then
    begin
      W := F.Width;
      H := F.Height;
      F.ScaleBy(NewHeight, OldHeight);
      if KeepFormSize then
      begin
        F.Width := W;
        F.Height := H;
      end;
    end;
    F.Font.Height := -NewHeight;
  finally
    F.EnableAlign;
  end;
  if Assigned(F.Menu) then
    JVCSUIApplyToMenu(F.Menu);
end;

procedure JVCSUIApplyToAllForms;
var
  I: Integer;
begin
  UpdateScreenFonts;
  for I := 0 to Screen.FormCount - 1 do
    JVCSUIApplyToForm(Screen.Forms[I], Screen.Forms[I] = Application.MainForm);
end;

//=== menus (owner-draw) ========================================================

type
  TJVCSMenuPainter = class(TComponent)
  public
    procedure MeasureItem(Sender: TObject; ACanvas: TCanvas;
      var Width, Height: Integer);
    procedure AdvancedDrawItem(Sender: TObject; ACanvas: TCanvas;
      ARect: TRect; State: TOwnerDrawState);
  end;

var
  GMenuPainter: TJVCSMenuPainter = nil;
  GDummyImages: TImageList = nil;

function MenuImages(AItem: TMenuItem): TCustomImageList;
begin
  Result := AItem.GetImageList;
end;

function IsTopLevel(AItem: TMenuItem): Boolean;
begin
  Result := (AItem.Parent <> nil) and (AItem.Parent.Parent = nil) and
    (AItem.GetParentMenu is TMainMenu);
end;

procedure TJVCSMenuPainter.MeasureItem(Sender: TObject; ACanvas: TCanvas;
  var Width, Height: Integer);
var
  Item: TMenuItem;
  Images: TCustomImageList;
  S: string;
  ImgW, ImgH, TextH: Integer;
begin
  Item := Sender as TMenuItem;
  JVCSUIAssignMenuFont(ACanvas.Font);
  TextH := ACanvas.TextHeight('Wg');
  if Item.IsLine then
  begin
    Width := 10;
    Height := Max(5, TextH div 2);
    Exit;
  end;
  Images := MenuImages(Item);
  if Assigned(Images) then
  begin
    ImgW := Images.Width;
    ImgH := Images.Height;
  end
  else
  begin
    ImgW := TextH;
    ImgH := TextH;
  end;
  S := StripHotkey(Item.Caption);
  if IsTopLevel(Item) then
  begin
    Width := ACanvas.TextWidth(S) + TextH;
    Height := TextH + TextH div 2;
  end
  else
  begin
    Width := ImgW + 8 + ACanvas.TextWidth(S) + TextH * 2;
    if Item.ShortCut <> 0 then
      Inc(Width, ACanvas.TextWidth(ShortCutToText(Item.ShortCut)) + TextH);
    Height := Max(TextH + TextH div 2, ImgH + 4);
  end;
end;

procedure TJVCSMenuPainter.AdvancedDrawItem(Sender: TObject; ACanvas: TCanvas;
  ARect: TRect; State: TOwnerDrawState);
var
  Item: TMenuItem;
  Images: TCustomImageList;
  R, TR: TRect;
  S: string;
  Flags: Cardinal;
  ImgW, TextH, Y: Integer;
  Selected, Disabled, TopLevel: Boolean;
  BackColor, TextColor: TColor;
begin
  Item := Sender as TMenuItem;
  JVCSUIAssignMenuFont(ACanvas.Font);
  TextH := ACanvas.TextHeight('Wg');
  Selected := (odSelected in State) or (odHotLight in State);
  Disabled := (odDisabled in State) or (odGrayed in State) or not Item.Enabled;
  TopLevel := IsTopLevel(Item);

  if TStyleManager.IsCustomStyleActive then
  begin
    // VCL Style (ex.: tema escuro): cores do estilo
    BackColor := StyleServices.GetSystemColor(clBtnFace);
    if TopLevel then
      TextColor := StyleServices.GetStyleFontColor(sfMenuItemTextNormal)
    else
      TextColor := StyleServices.GetStyleFontColor(sfPopupMenuItemTextNormal);
    if Selected and not Item.IsLine then
    begin
      BackColor := StyleServices.GetSystemColor(clHighlight);
      TextColor := StyleServices.GetSystemColor(clHighlightText);
    end;
    if Disabled then
      TextColor := StyleServices.GetStyleFontColor(sfPopupMenuItemTextDisabled);
  end
  else
  begin
    if TopLevel then
      BackColor := clMenuBar
    else
      BackColor := clMenu;
    TextColor := clMenuText;
    if Selected and not Item.IsLine then
    begin
      BackColor := clHighlight;
      TextColor := clHighlightText;
    end;
    if Disabled then
      TextColor := clGrayText;
  end;

  ACanvas.Brush.Color := BackColor;
  ACanvas.FillRect(ARect);

  if Item.IsLine then
  begin
    Y := (ARect.Top + ARect.Bottom) div 2;
    ACanvas.Pen.Color := StyleServices.GetSystemColor(clBtnShadow);
    ACanvas.MoveTo(ARect.Left + 4, Y);
    ACanvas.LineTo(ARect.Right - 4, Y);
    Exit;
  end;

  ACanvas.Font.Color := TextColor;
  ACanvas.Brush.Style := bsClear;
  S := Item.Caption;
  Flags := DT_SINGLELINE or DT_VCENTER;
  if odNoAccel in State then
    Flags := Flags or DT_HIDEPREFIX;

  if TopLevel then
  begin
    R := ARect;
    DrawText(ACanvas.Handle, PChar(S), Length(S), R, Flags or DT_CENTER);
    ACanvas.Brush.Style := bsSolid;
    Exit;
  end;

  Images := MenuImages(Item);
  if Assigned(Images) then
    ImgW := Images.Width
  else
    ImgW := TextH;

  // imagem ou marca de selecao
  R := Rect(ARect.Left + 2, ARect.Top, ARect.Left + 2 + ImgW + 4, ARect.Bottom);
  if Assigned(Images) and (Item.ImageIndex >= 0) then
  begin
    if Item.Checked then
    begin
      ACanvas.Pen.Color := TextColor;
      ACanvas.Rectangle(R.Left, R.Top + 1, R.Right, R.Bottom - 1);
    end;
    Images.Draw(ACanvas, R.Left + 2, (R.Top + R.Bottom - Images.Height) div 2,
      Item.ImageIndex, not Disabled);
  end
  else
  if Item.Checked then
  begin
    if Item.RadioItem then
      S := #$25CF  // bolinha
    else
      S := #$2713; // visto
    TR := R;
    DrawText(ACanvas.Handle, PChar(S), Length(S), TR, DT_SINGLELINE or DT_VCENTER or DT_CENTER);
    S := Item.Caption;
  end;

  // texto
  TR := Rect(R.Right + 4, ARect.Top, ARect.Right - TextH, ARect.Bottom);
  DrawText(ACanvas.Handle, PChar(S), Length(S), TR, Flags or DT_LEFT);
  // atalho
  if Item.ShortCut <> 0 then
  begin
    S := ShortCutToText(Item.ShortCut);
    DrawText(ACanvas.Handle, PChar(S), Length(S), TR, DT_SINGLELINE or DT_VCENTER or DT_RIGHT);
  end;
  ACanvas.Brush.Style := bsSolid;
end;

procedure SetupMenuItems(AItem: TMenuItem; OwnerDraw: Boolean);
var
  I: Integer;
  Sub: TMenuItem;
begin
  for I := 0 to AItem.Count - 1 do
  begin
    Sub := AItem.Items[I];
    if OwnerDraw then
    begin
      if not Assigned(Sub.OnMeasureItem) then
        Sub.OnMeasureItem := GMenuPainter.MeasureItem;
      if not Assigned(Sub.OnAdvancedDrawItem) then
        Sub.OnAdvancedDrawItem := GMenuPainter.AdvancedDrawItem;
    end
    else
    begin
      if TMethod(Sub.OnMeasureItem).Data = GMenuPainter then
        Sub.OnMeasureItem := nil;
      if TMethod(Sub.OnAdvancedDrawItem).Data = GMenuPainter then
        Sub.OnAdvancedDrawItem := nil;
    end;
    SetupMenuItems(Sub, OwnerDraw);
  end;
end;

procedure JVCSUIApplyToMenu(AMenu: TMenu);
var
  UseOwnerDraw: Boolean;
begin
  if not Assigned(AMenu) then
    Exit;
  if not Assigned(GMenuPainter) then
    GMenuPainter := TJVCSMenuPainter.Create(nil);
  // com VCL Style ativo (tema escuro) os menus sao desenhados pelos style hooks,
  // que ja usam Screen.MenuFont (ver UpdateScreenFonts): sem owner-draw
  UseOwnerDraw := not GSettings.IsDefaultMenu and not TStyleManager.IsCustomStyleActive;
  SetupMenuItems(AMenu.Items, UseOwnerDraw);
  if AMenu is TMainMenu then
  begin
    // Barra do menu principal: a altura da barra e fixa (SM_CYMENU) e o VCL
    // nao entrega o owner-draw dos itens de nivel 1, entao eles ficam nativos.
    // Os submenus viram owner-draw por terem uma ImageList (regra do VCL
    // para Vista+: item de nivel 1 sem ImageIndex continua nativo).
    if UseOwnerDraw then
    begin
      if AMenu.Images = nil then
      begin
        if not Assigned(GDummyImages) then
          GDummyImages := TImageList.Create(nil);
        AMenu.Images := GDummyImages;
      end;
    end
    else
    if (AMenu.Images <> nil) and (AMenu.Images = GDummyImages) then
      AMenu.Images := nil;
    if AMenu.OwnerDraw then
      AMenu.OwnerDraw := False;
    if AMenu.WindowHandle <> 0 then
      DrawMenuBar(AMenu.WindowHandle);
  end
  else
  begin
    if UseOwnerDraw then
      AMenu.OwnerDraw := True
    else
    if AMenu.OwnerDraw then
      AMenu.OwnerDraw := False;
  end;
end;

procedure JVCSUIAssignMenuFont(AFont: TFont);
begin
  // pela altura em pixels do DPI da tela: o canvas dos menus nao tem
  // necessariamente o PixelsPerInch da tela
  AFont.Name := GSettings.EffectiveMenuFontName;
  AFont.Height := -MulDiv(GSettings.EffectiveMenuFontSize, Screen.PixelsPerInch, 72);
end;

procedure JVCSUIAssignEditorFont(AFont: TFont);
begin
  AFont.Name := GSettings.EffectiveEditorFontName;
  AFont.Size := GSettings.EffectiveEditorFontSize;
end;

//=== textos ====================================================================

function JVCSUIScaleToText(AScale: Integer): string;
begin
  Result := IntToStr(AScale) + '%';
end;

function JVCSUITextToScale(const AText: string; ADefault: Integer): Integer;
var
  S: string;
begin
  S := StringReplace(Trim(AText), '%', '', [rfReplaceAll]);
  Result := ClampScale(StrToIntDef(Trim(S), ADefault));
end;

initialization
  JVCSUIReadInteger := RegReadInteger;
  JVCSUIWriteInteger := RegWriteInteger;
  JVCSUIReadString := RegReadString;
  JVCSUIWriteString := RegWriteString;
  GSettings.SetDefaults;

finalization
  FreeAndNil(GMenuPainter);
  FreeAndNil(GDummyImages);
  FreeAndNil(GSystemMenuFont);

end.
