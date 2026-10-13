(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSUITheme.pas

The Initial Developer of the original code (JEDI VCS v2026) is the JEDI VCS
port team (2026).

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Purpose:
  Tema claro/escuro do cliente JEDI VCS com VCL Styles nativos.
  - Modo (UITheme, Integer em HKCU\Software\JEDI\JEDIVCS\Options):
      0 = seguir o host (standalone: Windows; DLL na IDE: tema da IDE)
      1 = claro  (estilo nativo "Windows", sem VCL Style)
      2 = escuro ("Windows Modern Dark", embutido via JVCSUIStyles.res)
  - Standalone: le HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\
    Personalize\AppsUseLightTheme (0 = escuro) e acompanha WM_SETTINGCHANGE
    ("ImmersiveColorSet") quando JVCSUIStartFollowingSystem for chamada.
  - Dentro da IDE (fase F5): o expert informa o tema da IDE por
    JVCSUISetHostTheme(IsDark) (ou atribuindo JVCSUIHostIsDark); a DLL nao
    le o tema da IDE sozinha. Ver doc\client\Port-Diff.md.
  A leitura/gravacao usa as mesmas funcoes de armazenamento de JVCSUIScale
  (JVCSUIReadInteger/JVCSUIWriteInteger + JVCSUIOptionsKey).

Unit history:

2026/10/12  v2026      - nova unit (fase F3, piloto no JEDIVCSDiff)

-----------------------------------------------------------------------------*)

unit JVCSUITheme;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms;

const
  cJVCSUITheme = 'UITheme';
  cJVCSLightStyleName = 'Windows';              // estilo nativo do sistema
  cJVCSDarkStyleName = 'Windows Modern Dark';   // JVCSUIStyles.res

type
  TJVCSUIThemeMode = (tmFollowHost, tmLight, tmDark);

  { informa se o host (IDE) esta com tema escuro; nil = usa o Windows }
  TJVCSUIHostIsDarkFunc = function: Boolean;

var
  JVCSUIHostIsDark: TJVCSUIHostIsDarkFunc = nil;
  { evento disparado depois de cada troca efetiva de tema }
  JVCSUIOnThemeChanged: TNotifyEvent = nil;

function JVCSUIThemeModeToText(AMode: TJVCSUIThemeMode): string;

{ preferencia }
function JVCSUILoadThemeMode: TJVCSUIThemeMode;
procedure JVCSUISaveThemeMode(AMode: TJVCSUIThemeMode);

{ tema do Windows para apps (AppsUseLightTheme = 0) }
function JVCSUIWindowsUsesDarkTheme: Boolean;
{ resolve o modo (seguir host -> host/Windows) }
function JVCSUIIsDarkMode(AMode: TJVCSUIThemeMode): Boolean;

{ modo em uso e aplicacao }
function JVCSUIThemeMode: TJVCSUIThemeMode;
function JVCSUIIsDark: Boolean;
procedure JVCSUIApplyTheme(AMode: TJVCSUIThemeMode);
{ carrega a preferencia e aplica (chamar antes de criar os forms) }
procedure JVCSUIThemeInitialize;
{ IDE: o expert informa o tema da IDE; reaplica se o modo for "seguir host" }
procedure JVCSUISetHostTheme(IsDark: Boolean);
{ standalone: reaplica quando o usuario troca o tema do Windows }
procedure JVCSUIStartFollowingSystem;
procedure JVCSUIStopFollowingSystem;

{ cor de sistema traduzida pelo estilo ativo (clWindow, clWindowText, ...) }
function JVCSUIColor(AColor: TColor): TColor;
{ barra de titulo escura no Windows 10 1809+/11 para forms sem VCL Style de borda }
procedure JVCSUISetDarkTitleBar(AWnd: HWND; ADark: Boolean);

implementation

{$R JVCSUIStyles.res}

uses
  Registry, Themes, Styles, JVCSUIScale;

const
  cPersonalizeKey = 'Software\Microsoft\Windows\CurrentVersion\Themes\Personalize';
  DWMWA_USE_IMMERSIVE_DARK_MODE_OLD = 19;
  DWMWA_USE_IMMERSIVE_DARK_MODE = 20;

type
  TJVCSThemeWatcher = class
  private
    FWnd: HWND;
    procedure WndProc(var Msg: TMessage);
  public
    constructor Create;
    destructor Destroy; override;
  end;

var
  GMode: TJVCSUIThemeMode = tmFollowHost;
  GDark: Boolean = False;
  GHostKnown: Boolean = False;
  GHostDark: Boolean = False;
  GWatcher: TJVCSThemeWatcher = nil;

function JVCSUIThemeModeToText(AMode: TJVCSUIThemeMode): string;
begin
  case AMode of
    tmLight: Result := 'Light';
    tmDark: Result := 'Dark';
  else
    Result := 'Follow host';
  end;
end;

function JVCSUILoadThemeMode: TJVCSUIThemeMode;
var
  V: Integer;
begin
  V := JVCSUIReadInteger(JVCSUIOptionsKey, cJVCSUITheme, Ord(tmFollowHost));
  if (V < Ord(Low(TJVCSUIThemeMode))) or (V > Ord(High(TJVCSUIThemeMode))) then
    V := Ord(tmFollowHost);
  Result := TJVCSUIThemeMode(V);
end;

procedure JVCSUISaveThemeMode(AMode: TJVCSUIThemeMode);
begin
  JVCSUIWriteInteger(JVCSUIOptionsKey, cJVCSUITheme, Ord(AMode));
end;

function JVCSUIWindowsUsesDarkTheme: Boolean;
var
  Reg: TRegistry;
begin
  Result := False;
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKeyReadOnly(cPersonalizeKey) and
       Reg.ValueExists('AppsUseLightTheme') then
    try
      Result := Reg.ReadInteger('AppsUseLightTheme') = 0;
    except
      Result := False;
    end;
  finally
    Reg.Free;
  end;
end;

function JVCSUIIsDarkMode(AMode: TJVCSUIThemeMode): Boolean;
begin
  case AMode of
    tmLight: Result := False;
    tmDark: Result := True;
  else
    if Assigned(JVCSUIHostIsDark) then
      Result := JVCSUIHostIsDark()
    else
    if GHostKnown then
      Result := GHostDark
    else
      Result := JVCSUIWindowsUsesDarkTheme;
  end;
end;

function JVCSUIThemeMode: TJVCSUIThemeMode;
begin
  Result := GMode;
end;

function JVCSUIIsDark: Boolean;
begin
  Result := GDark;
end;

function JVCSUIColor(AColor: TColor): TColor;
begin
  Result := StyleServices.GetSystemColor(AColor);
end;

procedure JVCSUISetDarkTitleBar(AWnd: HWND; ADark: Boolean);
type
  TDwmSetWindowAttribute = function(hwnd: HWND; dwAttribute: DWORD;
    pvAttribute: Pointer; cbAttribute: DWORD): HRESULT; stdcall;
var
  Lib: HMODULE;
  Fn: TDwmSetWindowAttribute;
  Value: BOOL;
begin
  if AWnd = 0 then
    Exit;
  Lib := GetModuleHandle('dwmapi.dll');
  if Lib = 0 then
    Lib := LoadLibrary('dwmapi.dll');
  if Lib = 0 then
    Exit;
  @Fn := GetProcAddress(Lib, 'DwmSetWindowAttribute');
  if not Assigned(Fn) then
    Exit;
  Value := ADark;
  if Fn(AWnd, DWMWA_USE_IMMERSIVE_DARK_MODE, @Value, SizeOf(Value)) <> S_OK then
    Fn(AWnd, DWMWA_USE_IMMERSIVE_DARK_MODE_OLD, @Value, SizeOf(Value));
end;

procedure JVCSUIApplyTheme(AMode: TJVCSUIThemeMode);
var
  NewDark, Changed: Boolean;
  StyleName: string;
begin
  GMode := AMode;
  NewDark := JVCSUIIsDarkMode(AMode);
  if NewDark then
    StyleName := cJVCSDarkStyleName
  else
    StyleName := cJVCSLightStyleName;
  Changed := not SameText(TStyleManager.ActiveStyle.Name, StyleName);
  if Changed then
  begin
    if not TStyleManager.TrySetStyle(StyleName, False) then
    begin
      // estilo escuro ausente: fica no nativo
      TStyleManager.TrySetStyle(cJVCSLightStyleName, False);
      NewDark := False;
    end;
  end;
  GDark := NewDark;
  if Changed and Assigned(JVCSUIOnThemeChanged) then
    JVCSUIOnThemeChanged(nil);
end;

procedure JVCSUIThemeInitialize;
begin
  JVCSUIApplyTheme(JVCSUILoadThemeMode);
end;

procedure JVCSUISetHostTheme(IsDark: Boolean);
begin
  GHostKnown := True;
  GHostDark := IsDark;
  if GMode = tmFollowHost then
    JVCSUIApplyTheme(GMode);
end;

{ TJVCSThemeWatcher }

constructor TJVCSThemeWatcher.Create;
begin
  inherited Create;
  FWnd := AllocateHWnd(WndProc);
end;

destructor TJVCSThemeWatcher.Destroy;
begin
  if FWnd <> 0 then
    DeallocateHWnd(FWnd);
  inherited Destroy;
end;

procedure TJVCSThemeWatcher.WndProc(var Msg: TMessage);
begin
  if (Msg.Msg = WM_SETTINGCHANGE) and (Msg.LParam <> 0) and
     SameText(PChar(Msg.LParam), 'ImmersiveColorSet') then
  begin
    if (GMode = tmFollowHost) and not Assigned(JVCSUIHostIsDark) and not GHostKnown then
      JVCSUIApplyTheme(GMode);
  end;
  Msg.Result := DefWindowProc(FWnd, Msg.Msg, Msg.WParam, Msg.LParam);
end;

procedure JVCSUIStartFollowingSystem;
begin
  if not Assigned(GWatcher) then
    GWatcher := TJVCSThemeWatcher.Create;
end;

procedure JVCSUIStopFollowingSystem;
begin
  FreeAndNil(GWatcher);
end;

initialization

finalization
  FreeAndNil(GWatcher);

end.
