(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSForms.pas

The Initial Developer of the original code (JEDI VCS) is:
  Thomas Huber (thomas_d_huber@gmx.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:
2008/12/22  THuber    introduced unit for various fixes:
                      - fixing z-order problem together with VISTA Taskbar code for Delphi<2007
2009/01/05  THuber    VISTA Taskbar fix needs to commented out for >= Delphi2007
2026/10/13  v2026     aparencia (F4/F5): fonte/escala (JVCSUIScale), fonte dos
                      menus e dos editores SynEdit e tema (JVCSUITheme) em todos
                      os forms quando JVCSFormsApplyAppearance = True (EXE e DLL;
                      o Diff continua aplicando por conta propria)

-----------------------------------------------------------------------------*)

unit JVCSForms;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, Classes, Forms, Controls, Menus;

type
  TJVCSForm = class(TForm)
  private
    { Private declarations }
    FScaledMinW, FScaledMinH: Integer;
    procedure EnsureScaledMinSize;
  protected
    { Protected declarations }
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DoCreate; override;
    procedure DoShow; override;
    procedure Activate; override;
    procedure WndProc(var Message: TMessage); override;
  public
    { Public declarations }
  end;

var
  { liga a aplicacao automatica da aparencia (fonte/escala, menus, editores e
    tema) em TJVCSForm.DoCreate e, com JVCSInstallAppearanceHook, nos forms que
    nao herdam de TJVCSForm (mensagens, dialogos da JVCL). Ligado pelo EXE e
    pela DLL (JVCSClientAppearance); o Diff aplica sozinho. }
  JVCSFormsApplyAppearance: Boolean = False;

{ aplica a aparencia em uso a um form. AForce = reaplica mesmo com a fonte
  padrao (depois de o usuario mudar as opcoes). }
procedure JVCSApplyAppearanceToForm(AForm: TCustomForm; AForce: Boolean = False);
{ reaplica em todos os forms abertos (depois de gravar as opcoes) }
procedure JVCSApplyAppearanceToAllForms;
{ instala/remove o tratamento dos forms que nao herdam de TJVCSForm
  (Screen.OnActiveFormChange, encadeado com o handler anterior) }
procedure JVCSInstallAppearanceHook;
procedure JVCSRemoveAppearanceHook;

{ DLL dentro da IDE: os menus da IDE (VCL Style com SystemHooks/shMenus) tem um
  hook de thread (WH_CBT) que pinta TODA janela de menu #32768 do thread,
  inclusive os submenus e popups dos forms da DLL. Como a VCL da DLL e outra
  (estatica), o hook da IDE nao acha o TMenuItem e le o texto do item com
  GetMenuItemInfo(MIIM_STRING); item owner-draw (menu com Images) nao tem texto
  e sai em branco. A correcao grava o Caption (+ atalho) como texto do item
  (MIIM_STRING; continua owner-draw) a cada WM_INITMENUPOPUP: o hook da IDE
  passa a desenhar o texto com as cores do tema da IDE (claro ou escuro). }
procedure JVCSInstallHostMenuFix;

var
  { DLL na IDE: classe da janela principal do host ('TAppBuilder' no Delphi);
    '' = nao muda o dono dos forms (EXE) }
  JVCSFormsOwnerClass: string = '';

{ janela principal visivel do host (classe JVCSFormsOwnerClass, no thread
  atual); 0 = nao achou }
function JVCSHostMainWindow: HWND;
{ grava o texto dos itens owner-draw de AMenu achando o TMenuItem em AMenus }
procedure JVCSFixOwnerDrawMenuText(AMenu: HMENU; const AMenus: array of TMenu);

implementation

uses
  SysUtils, Types, Math, JVCSUIScale, JVCSUITheme;

type
  TControlAccess = class(TControl);

  TJVCSAppearanceHook = class
  private
    FOldHandler: TNotifyEvent;
  public
    procedure ActiveFormChange(Sender: TObject);
  end;

var
  GHook: TJVCSAppearanceHook = nil;

function InheritsFromClassName(AObj: TObject; const AClassName: string): Boolean;
var
  C: TClass;
begin
  Result := False;
  C := AObj.ClassType;
  while C <> nil do
  begin
    if SameText(C.ClassName, AClassName) then
      Exit(True);
    C := C.ClassParent;
  end;
end;

function EditorFontCustomized: Boolean;
var
  S: TJVCSUIFontSettings;
begin
  S := JVCSUIFontSettings;
  Result := (S.EditorFontName <> '') or (S.EditorFontSize > 0);
end;

{ popup menus e editores SynEdit (inclusive dentro de frames); o SynEdit e
  reconhecido pelo nome da classe para esta unit nao depender do SynEdit }
procedure ApplyToComponents(AOwner: TComponent; AMenus, AEditors: Boolean);
var
  I: Integer;
  C: TComponent;
begin
  for I := 0 to AOwner.ComponentCount - 1 do
  begin
    C := AOwner.Components[I];
    if AMenus and (C is TPopupMenu) then
      JVCSUIApplyToMenu(TPopupMenu(C))
    else
    if AEditors and (C is TControl) and InheritsFromClassName(C, 'TCustomSynEdit') then
      JVCSUIAssignEditorFont(TControlAccess(C).Font);
    if C.ComponentCount > 0 then
      ApplyToComponents(C, AMenus, AEditors);
  end;
end;

procedure JVCSApplyAppearanceToForm(AForm: TCustomForm; AForce: Boolean);
var
  S: TJVCSUIFontSettings;
  KeepSize: Boolean;
begin
  if not Assigned(AForm) then
    Exit;
  S := JVCSUIFontSettings;
  // com a fonte padrao o form fica como no DFM (layout original)
  if AForce or not S.IsDefaultUI then
  begin
    // a janela principal mantem o tamanho (so o conteudo acompanha); no EXE
    // a primeira janela criada (antes de Application.MainForm) e a principal
    KeepSize := (AForm = Application.MainForm) or
      ((Application.MainForm = nil) and not IsLibrary and (Screen.FormCount <= 1));
    JVCSUIApplyToForm(AForm, KeepSize);
  end;
  ApplyToComponents(AForm, AForce or not S.IsDefaultMenu, AForce or EditorFontCustomized);
  JVCSUIApplyThemeToForm(AForm);
end;

procedure JVCSApplyAppearanceToAllForms;
var
  I: Integer;
begin
  for I := 0 to Screen.FormCount - 1 do
    JVCSApplyAppearanceToForm(Screen.Forms[I], True);
end;

{ TJVCSAppearanceHook }

procedure TJVCSAppearanceHook.ActiveFormChange(Sender: TObject);
var
  F: TCustomForm;
begin
  try
    F := Screen.ActiveCustomForm;
    // TJVCSForm ja foi tratado no DoCreate; aqui so os outros. A aplicacao e
    // idempotente (fonte e altura iguais = nada muda).
    if JVCSFormsApplyAppearance and Assigned(F) and not (F is TJVCSForm) then
      JVCSApplyAppearanceToForm(F);
  except
    // a aparencia nunca derruba a janela
  end;
  if Assigned(FOldHandler) then
    FOldHandler(Sender);
end;

procedure JVCSInstallAppearanceHook;
begin
  if Assigned(GHook) then
    Exit;
  GHook := TJVCSAppearanceHook.Create;
  GHook.FOldHandler := Screen.OnActiveFormChange;
  Screen.OnActiveFormChange := GHook.ActiveFormChange;
end;

procedure JVCSRemoveAppearanceHook;
begin
  if not Assigned(GHook) then
    Exit;
  if Assigned(Screen) and
     (TMethod(Screen.OnActiveFormChange).Data = Pointer(GHook)) then
    Screen.OnActiveFormChange := GHook.FOldHandler;
  FreeAndNil(GHook);
end;

//=== texto dos menus owner-draw (DLL na IDE) ===================================

type
  TJVCSPopupList = class(TPopupList)
  protected
    procedure WndProc(var Message: TMessage); override;
  end;

var
  GFixMenuText: Boolean = False;

procedure JVCSFixOwnerDrawMenuText(AMenu: HMENU; const AMenus: array of TMenu);
var
  I, J, N: Integer;
  Info: TMenuItemInfo;
  MI: TMenuItem;
  S: string;
begin
  if AMenu = 0 then
    Exit;
  N := GetMenuItemCount(AMenu);
  for I := 0 to N - 1 do
  begin
    FillChar(Info, SizeOf(Info), 0);
    Info.cbSize := SizeOf(Info);
    Info.fMask := MIIM_FTYPE or MIIM_ID or MIIM_STRING;
    Info.dwTypeData := nil;
    if not GetMenuItemInfo(AMenu, I, True, Info) then
      Continue;
    if (Info.fType and MFT_OWNERDRAW = 0) or (Info.fType and MFT_SEPARATOR <> 0) then
      Continue;
    MI := nil;
    for J := Low(AMenus) to High(AMenus) do
      if Assigned(AMenus[J]) then
      begin
        MI := AMenus[J].FindItem(Info.wID, fkCommand);
        if Assigned(MI) then
          Break;
      end;
    if not Assigned(MI) or MI.IsLine then
      Continue;
    // mesmo texto que a VCL usaria sem owner-draw (TMenuItem.AppendTo)
    S := MI.Caption;
    if (MI.ShortCut <> scNone) and (MI.Count = 0) then
      S := S + #9 + ShortCutToText(MI.ShortCut);
    if Info.cch = UINT(Length(S)) then
      Continue; // ja tem o texto
    FillChar(Info, SizeOf(Info), 0);
    Info.cbSize := SizeOf(Info);
    Info.fMask := MIIM_STRING;
    Info.dwTypeData := PChar(S);
    Info.cch := Length(S);
    SetMenuItemInfo(AMenu, I, True, Info);
  end;
end;

procedure TJVCSPopupList.WndProc(var Message: TMessage);
var
  Menus: array of TMenu;
  I: Integer;
begin
  inherited WndProc(Message);
  if GFixMenuText and (Message.Msg = WM_INITMENUPOPUP) then
  try
    SetLength(Menus, Count);
    for I := 0 to Count - 1 do
      Menus[I] := TMenu(Items[I]);
    JVCSFixOwnerDrawMenuText(HMENU(Message.WParam), Menus);
  except
  end;
end;

procedure JVCSInstallHostMenuFix;
var
  Old: TPopupList;
  P: TPopupMenu;
begin
  GFixMenuText := True;
  if PopupList is TJVCSPopupList then
    Exit;
  // troca a PopupList da VCL (da DLL) por uma que tambem corrige o texto;
  // Remove/Add (e nao Delete) para a janela da lista velha ser liberada
  Old := PopupList;
  PopupList := TJVCSPopupList.Create;
  if Assigned(Old) then
  begin
    while Old.Count > 0 do
    begin
      P := TPopupMenu(Old[0]);
      Old.Remove(P);
      PopupList.Add(P);
    end;
    Old.Free;
  end;
end;

type
  PHostFind = ^THostFind;
  THostFind = record
    Wnd: HWND;
  end;

function EnumHostProc(W: HWND; L: LPARAM): BOOL; stdcall;
var
  Buf: array [0..63] of Char;
begin
  Result := True;
  if IsWindowVisible(W) and (GetClassName(W, Buf, Length(Buf)) > 0) and
     SameText(string(Buf), JVCSFormsOwnerClass) then
  begin
    PHostFind(L)^.Wnd := W;
    Result := False;
  end;
end;

function JVCSHostMainWindow: HWND;
var
  F: THostFind;
begin
  Result := 0;
  if JVCSFormsOwnerClass = '' then
    Exit;
  F.Wnd := 0;
  EnumThreadWindows(GetCurrentThreadId, @EnumHostProc, LPARAM(@F));
  Result := F.Wnd;
end;

{ TJVCSForm }

procedure TJVCSForm.WndProc(var Message: TMessage);
begin
  inherited WndProc(Message);
  // menu principal do form: WM_INITMENUPOPUP vem para o form
  if GFixMenuText and (Message.Msg = WM_INITMENUPOPUP) then
  try
    JVCSFixOwnerDrawMenuText(HMENU(Message.WParam), [Menu]);
  except
  end;
end;

procedure TJVCSForm.CreateParams(var Params: TCreateParams);
var
  Host: HWND;
begin
  inherited CreateParams(Params);
  // DLL na IDE: a janela dona passa a ser a janela principal da IDE (e nao a
  // janela oculta do Application da IDE), para o form ficar na frente da IDE
  // e minimizar/restaurar junto (Alt+Tab)
  if (JVCSFormsOwnerClass <> '') and (Params.WndParent = Application.Handle) then
  begin
    Host := JVCSHostMainWindow;
    if Host <> 0 then
      Params.WndParent := Host;
  end;
  {$IFNDEF IDEDLL}
  {$IFNDEF DELPHI2007_UP}
  if Owner is TWinControl then
  begin
    Params.WndParent := TWinControl(Owner).Handle;
  end else if Owner is TApplication then
  begin
    Params.WndParent := Application.Mainform.Handle;
  end;
  {$ENDIF ~DELPHI2007_UP}
  {$ENDIF ~IDEDLL}
end;

procedure TJVCSForm.DoCreate;
var
  DesignW, DesignH: Integer;
begin
  DesignW := 0;
  DesignH := 0;
  // antes do OnCreate (que restaura posicao/tamanho salvos)
  if JVCSFormsApplyAppearance then
  try
    JVCSUIRefreshHostTheme;
    JVCSApplyAppearanceToForm(Self);
    // v2026: tambem a 100% (o tamanho salvo por versoes antigas pode ser menor
    // que o DFM e cortar rotulos, ex.: Synchronize com 400x520)
    DesignW := Width;
    DesignH := Height;
  except
    // a aparencia nunca impede a criacao do form
  end;
  inherited DoCreate;
  // v2026: o OnCreate de muitos forms restaura o tamanho salvo, gravado em
  // pixels numa sessao com outra escala/fonte (ou ate menor que o DFM): com
  // 125-200% o conteudo escalado ficava cortado (ex.: VCS Properties). Forms
  // redimensionaveis (menos a janela principal) ficam no minimo com o tamanho
  // do DFM ja escalado, limitado a area de trabalho do monitor.
  // O mesmo vale para os que restauram no OnShow (jvcsLoadFormPosSize): ver
  // DoShow.
  FScaledMinW := DesignW;
  FScaledMinH := DesignH;
  EnsureScaledMinSize;
end;

procedure TJVCSForm.EnsureScaledMinSize;
var
  W, H: Integer;
  WA: TRect;
begin
  if (FScaledMinW > 0) and (BorderStyle in [bsSizeable, bsSizeToolWin]) and
     (Self <> Application.MainForm) and (WindowState = wsNormal) and
     (Parent = nil) and (HostDockSite = nil) then // acoplados (dock) ficam como estao
  try
    WA := Screen.MonitorFromRect(BoundsRect).WorkareaRect;
    // menor que o DFM escalado: cresce; maior que a area de trabalho (200% numa
    // tela pequena): encolhe para caber
    if (Width >= FScaledMinW) and (Height >= FScaledMinH) and
       (Width <= WA.Width) and (Height <= WA.Height) then
      Exit;
    W := Min(Max(Width, FScaledMinW), WA.Width);
    H := Min(Max(Height, FScaledMinH), WA.Height);
    SetBounds(Max(WA.Left, Min(Left, WA.Right - W)),
      Max(WA.Top, Min(Top, WA.Bottom - H)), W, H);
  except
    // a aparencia nunca impede a janela
  end;
end;

procedure TJVCSForm.Activate;
begin
  inherited Activate;
  // v2026: alguns forms restauram o tamanho salvo no OnActivate
  EnsureScaledMinSize;
end;

procedure TJVCSForm.DoShow;
begin
  if JVCSFormsApplyAppearance then
  try
    // DLL: acompanha a troca de tema da IDE feita desde o ultimo form
    JVCSUIRefreshHostTheme;
    JVCSUIApplyThemeToForm(Self);
  except
    // idem
  end;
  inherited DoShow;
  // v2026: muitos forms restauram o tamanho salvo no OnShow
  // (jvcsLoadFormPosSize), em pixels de outra escala: mesmo minimo do DoCreate
  EnsureScaledMinSize;
end;

initialization

finalization
  JVCSRemoveAppearanceHook;

end.
