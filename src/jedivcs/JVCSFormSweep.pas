(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSFormSweep.pas

The Initial Developer of the Original Code is: JEDI VCS 2026 port.
-----------------------------------------------------------------------------

v2026 (F4, 3a etapa): modo de diagnostico do build Debug do Jedivcs.exe.

  Jedivcs.exe -formsweep=<pasta> [-sweepscale=<80..250>] [-sweepshots]
              [-sweepfilter=<parte do nome da classe>] [-sweepnoshow]

Cria, mostra, fecha e destroi CADA form/frame do executavel (encontrados por
RTTI, units do proprio JEDI VCS), sem login, e grava <pasta>\formsweep.log:
  - excecoes na criacao (EReadError, propriedade inexistente no DFM...), no
    OnShow, no fechamento e na destruicao (inclusive AV);
  - handlers ligados pelo DFM cuja assinatura difere do tipo do evento
    (compara parametros, var/out e tipos pela RTTI do evento e do metodo);
  - layout: controles fora da area do pai, textos cortados (rotulos sem
    AutoSize, botoes, check/radio), rotulos sobre campos e form maior que a
    area de trabalho, na escala pedida (-sweepscale, so na memoria);
  - componentes JVCL (classes TJv...) de cada form;
  - mensagens/dialogos que apareceram (fechados sozinhos com Cancelar/Nao).
Com -sweepshots grava um PNG de cada janela (PrintWindow).
O registro so recebe o que os proprios forms gravam ao fechar (posicoes).
-----------------------------------------------------------------------------*)

unit JVCSFormSweep;

{$I jedi.inc}
{$I compopt.inc}

interface

function JVCSFormSweepRequested: Boolean;
procedure JVCSRunFormSweep;

{ automacao de teste por arquivo (ver abaixo); nao faz nada sem
  JVCS_DEBUG_AUTOMATION=1 }
procedure JVCSDebugAutomationStart;

implementation

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.Types,
  System.Rtti, System.TypInfo, System.Math, System.Generics.Collections,
  System.Generics.Defaults, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Graphics, Vcl.Menus, Vcl.Buttons, Vcl.ToolWin,
  Vcl.Imaging.pngimage, Vcl.ActnList, System.StrUtils, JclDebug, JVCSStatusBar, JVCSUIScale;

function PrintWindow(hwnd: HWND; hdcBlt: HDC; nFlags: UINT): BOOL; stdcall;
  external user32 name 'PrintWindow';

type
  TControlAccess = class(TControl);
  TButtonControlAccess = class(TButtonControl);
  TComboBoxAccess = class(TCustomComboBox);
  TListViewAccess = class(TCustomListView);

  TSweepWatcher = class(TComponent)
  public
    FreedObj: TComponent;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  end;

  TSweep = class
  private
    FDir: string;
    FLog: TStreamWriter;
    FShots, FNoShow: Boolean;
    FFilter: string;
    FScale: Integer;
    FCurrent: TComponent;
    FCurrentName: string;
    FTimer: TTimer;
    FWatcher: TSweepWatcher;
    FMeasure: TBitmap;
    FCtx: TRttiContext;
    FErrors, FSigErrors, FSigWarnings, FLayout, FDialogs: Integer;
    FSeen: TDictionary<string, Boolean>;
    procedure Log(const S: string);
    procedure TimerTick(Sender: TObject);
    procedure AppException(Sender: TObject; E: Exception);
    procedure Pump(AMs: Integer);
    procedure CheckEvents(AObj: TObject; const APath: string; ADepth: Integer);
    procedure CheckComponentTree(AComp: TComponent; const APath: string);
    function CompareSignature(AEvent: TRttiMethodType; AMethod: TRttiMethod;
      out AWarn: string): string;
    procedure CheckLayout(AForm: TCustomForm);
    procedure CheckLayoutOf(AParent: TWinControl; const APath: string);
    procedure CheckPageControls(AParent: TWinControl);
    function TextWidthOf(AControl: TControl; const AText: string): Integer;
    procedure ListJvcl(AComp: TComponent);
    procedure SaveShot(AForm: TCustomForm; const AName: string);
    procedure SweepClass(AClass: TClass);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Run;
  end;

function ParamValue(const AName: string; out AValue: string): Boolean;
var
  I: Integer;
  S, N: string;
begin
  Result := False;
  AValue := '';
  for I := 1 to ParamCount do
  begin
    S := ParamStr(I);
    if (S <> '') and CharInSet(S[1], ['-', '/']) then
    begin
      Delete(S, 1, 1);
      N := S;
      if Pos('=', N) > 0 then
      begin
        AValue := Copy(N, Pos('=', N) + 1, MaxInt);
        N := Copy(N, 1, Pos('=', N) - 1);
      end;
      if SameText(N, AName) then
        Exit(True);
      AValue := '';
    end;
  end;
end;

function JVCSFormSweepRequested: Boolean;
var
  V: string;
begin
  Result := ParamValue('formsweep', V);
end;

{ TSweepWatcher }

procedure TSweepWatcher.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if Operation = opRemove then
    FreedObj := AComponent;
end;

{ TSweep }

constructor TSweep.Create;
var
  V: string;
begin
  inherited Create;
  ParamValue('formsweep', FDir);
  if FDir = '' then
    FDir := ExtractFilePath(ParamStr(0)) + 'formsweep';
  ForceDirectories(FDir);
  FShots := ParamValue('sweepshots', V);
  FNoShow := ParamValue('sweepnoshow', V);
  ParamValue('sweepfilter', FFilter);
  FScale := 0;
  if ParamValue('sweepscale', V) then
    FScale := StrToIntDef(V, 0);
  FLog := TStreamWriter.Create(IncludeTrailingPathDelimiter(FDir) + 'formsweep.log',
    False, TEncoding.UTF8);
  FTimer := TTimer.Create(nil);
  FTimer.Interval := 150;
  FTimer.OnTimer := TimerTick;
  FWatcher := TSweepWatcher.Create(nil);
  FMeasure := TBitmap.Create;
  FMeasure.SetSize(8, 8);
  FCtx := TRttiContext.Create;
  FSeen := TDictionary<string, Boolean>.Create;
end;

destructor TSweep.Destroy;
begin
  FSeen.Free;
  FCtx.Free;
  FMeasure.Free;
  FWatcher.Free;
  FTimer.Free;
  FLog.Free;
  inherited Destroy;
end;

procedure TSweep.Log(const S: string);
begin
  FLog.WriteLine(S);
  FLog.Flush;
end;

procedure TSweep.AppException(Sender: TObject; E: Exception);
begin
  Inc(FErrors);
  Log(Format('  ERRO (mensagens) %s: %s: %s em %s', [FCurrentName, E.ClassName, E.Message,
    GetLocationInfoStr(ExceptAddr)]));
end;

function WindowTexts(AWnd: HWND): string;
var
  Child: HWND;
  Buf: array[0..1023] of Char;
begin
  Result := '';
  Child := GetWindow(AWnd, GW_CHILD);
  while Child <> 0 do
  begin
    if GetWindowText(Child, Buf, Length(Buf)) > 0 then
      Result := Result + ' | ' + StringReplace(Buf, #13#10, ' ', [rfReplaceAll]);
    Child := GetWindow(Child, GW_HWNDNEXT);
  end;
end;

function FormTexts(AForm: TCustomForm): string;
var
  I: Integer;
  C: TComponent;
begin
  Result := '';
  for I := 0 to AForm.ComponentCount - 1 do
  begin
    C := AForm.Components[I];
    if C is TCustomLabel then
      Result := Result + ' | ' + StringReplace(TLabel(C).Caption, #13#10, ' ', [rfReplaceAll])
    else
    if (C is TCustomStaticText) or (C is TCustomMemo) then
      Result := Result + ' | ' + StringReplace(TControlAccess(C).Text, #13#10, ' ', [rfReplaceAll]);
  end;
  // dialogos JVCL/VCL criam os rotulos sem dono
  if Result = '' then
    for I := 0 to AForm.ControlCount - 1 do
      if AForm.Controls[I] is TCustomLabel then
        Result := Result + ' | ' + TLabel(AForm.Controls[I]).Caption;
end;

function EnumDlgProc(W: HWND; L: LPARAM): BOOL; stdcall;
var
  Cls: array[0..63] of Char;
begin
  Result := True;
  if IsWindowVisible(W) and (GetClassName(W, Cls, Length(Cls)) > 0) and
     (string(Cls) = '#32770') then
    TList<HWND>(Pointer(L)).Add(W);
end;

procedure TSweep.TimerTick(Sender: TObject);
var
  I: Integer;
  F: TCustomForm;
  L: TList<HWND>;
  W, B: HWND;
  Buf: array[0..255] of Char;
begin
  // dialogos modais que nao sao o form em teste: registra e fecha
  for I := Screen.CustomFormCount - 1 downto 0 do
  begin
    F := Screen.CustomForms[I];
    if (F <> FCurrent) and (fsModal in F.FormState) and F.Visible and
       (F.ModalResult = mrNone) then
    begin
      Inc(FDialogs);
      Log(Format('  DIALOGO %s "%s"%s', [F.ClassName, F.Caption, FormTexts(F)]));
      F.ModalResult := mrCancel;
    end;
  end;
  L := TList<HWND>.Create;
  try
    EnumThreadWindows(GetCurrentThreadId, @EnumDlgProc, LPARAM(L));
    for W in L do
    begin
      GetWindowText(W, Buf, Length(Buf));
      Inc(FDialogs);
      Log(Format('  DIALOGO #32770 "%s"%s', [string(Buf), WindowTexts(W)]));
      B := GetDlgItem(W, IDCANCEL);
      if B = 0 then
        B := GetDlgItem(W, IDNO);
      if B = 0 then
        B := GetDlgItem(W, IDOK);
      if B <> 0 then
        PostMessage(W, WM_COMMAND, MakeWParam(GetDlgCtrlID(B), BN_CLICKED), LPARAM(B))
      else
        PostMessage(W, WM_CLOSE, 0, 0);
    end;
  finally
    L.Free;
  end;
end;

procedure TSweep.Pump(AMs: Integer);
var
  T: Cardinal;
begin
  T := GetTickCount;
  repeat
    Application.ProcessMessages;
    Sleep(10);
  until GetTickCount - T >= Cardinal(AMs);
end;

function TypeText(T: TRttiType): string;
begin
  if T = nil then
    Result := '<sem tipo>'
  else
    Result := T.Name;
end;

function TSweep.CompareSignature(AEvent: TRttiMethodType; AMethod: TRttiMethod;
  out AWarn: string): string;
const
  StrictFlags = [pfVar, pfOut, pfArray, pfReference];
var
  PE, PM: TArray<TRttiParameter>;
  I: Integer;
  TE, TM: TRttiType;

  function SameKindAndSize(A, B: TRttiType): Boolean;
  begin
    Result := (A.TypeKind = B.TypeKind) and (A.TypeSize = B.TypeSize);
  end;

  function ClassCompatible(A, B: TRttiType): Boolean;
  begin
    Result := (A is TRttiInstanceType) and (B is TRttiInstanceType) and
      (TRttiInstanceType(A).MetaclassType.InheritsFrom(TRttiInstanceType(B).MetaclassType) or
       TRttiInstanceType(B).MetaclassType.InheritsFrom(TRttiInstanceType(A).MetaclassType));
  end;

  function CheckTypes(A, B: TRttiType; const What: string): string;
  begin
    Result := '';
    if (A = nil) and (B = nil) then
      Exit;
    if (A = nil) or (B = nil) then
      Exit(Format('%s: %s x %s', [What, TypeText(A), TypeText(B)]));
    if A.Handle = B.Handle then
      Exit;
    if ClassCompatible(A, B) then
    begin
      AWarn := AWarn + Format(' %s: %s x %s (classes compativeis);', [What, A.Name, B.Name]);
      Exit;
    end;
    if SameText(A.Name, B.Name) or SameKindAndSize(A, B) and
       not (A.TypeKind in [tkUString, tkWString, tkLString, tkString, tkRecord,
         tkMRecord, tkDynArray, tkInterface, tkVariant]) then
    begin
      AWarn := AWarn + Format(' %s: %s x %s (mesmo tamanho);', [What, A.Name, B.Name]);
      Exit;
    end;
    Result := Format('%s: evento %s x handler %s', [What, A.Name, B.Name]);
  end;

begin
  Result := '';
  AWarn := '';
  PE := AEvent.GetParameters;
  PM := AMethod.GetParameters;
  if Length(PE) <> Length(PM) then
    Exit(Format('%d parametros no evento x %d no handler', [Length(PE), Length(PM)]));
  for I := 0 to High(PE) do
  begin
    if (PE[I].Flags * StrictFlags) <> (PM[I].Flags * StrictFlags) then
      Exit(Format('parametro %d (%s): var/out/array diferente', [I + 1, PE[I].Name]));
    if (pfConst in PE[I].Flags) <> (pfConst in PM[I].Flags) then
      AWarn := AWarn + Format(' parametro %d (%s): const diferente;', [I + 1, PE[I].Name]);
    TE := PE[I].ParamType;
    TM := PM[I].ParamType;
    Result := CheckTypes(TE, TM, Format('parametro %d (%s)', [I + 1, PE[I].Name]));
    if Result <> '' then
      Exit;
  end;
  if (AEvent.ReturnType <> nil) or (AMethod.ReturnType <> nil) then
    Result := CheckTypes(AEvent.ReturnType, AMethod.ReturnType, 'retorno');
  if (Result = '') and (AEvent.CallingConvention <> AMethod.CallingConvention) then
    Result := 'convencao de chamada diferente';
end;

procedure TSweep.CheckEvents(AObj: TObject; const APath: string; ADepth: Integer);
var
  T: TRttiType;
  P: TRttiProperty;
  Names: TDictionary<string, Boolean>;
  M: TMethod;
  Target: TObject;
  MName, Err, Warn, Key: string;
  RM: TRttiMethod;
  V: TValue;
  Sub: TObject;
  I: Integer;
begin
  if (AObj = nil) or (ADepth > 3) then
    Exit;
  T := FCtx.GetType(AObj.ClassType);
  if T = nil then
    Exit;
  Names := TDictionary<string, Boolean>.Create;
  try
    for P in T.GetProperties do
    begin
      if Names.ContainsKey(LowerCase(P.Name)) then
        Continue; // propriedade escondida por uma redeclaracao mais nova
      Names.Add(LowerCase(P.Name), True);
      if (P.Visibility <> mvPublished) or not P.IsReadable then
        Continue;
      if P.PropertyType.TypeKind = tkMethod then
      begin
        M := GetMethodProp(AObj, P.Name);
        if M.Code = nil then
          Continue;
        Target := TObject(M.Data);
        if Target = nil then
          Continue;
        MName := Target.MethodName(M.Code);
        Key := Target.ClassName + '.' + MName + '@' + P.PropertyType.Name;
        if FSeen.ContainsKey(Key + APath + '.' + P.Name) then
          Continue;
        FSeen.Add(Key + APath + '.' + P.Name, True);
        RM := nil;
        if MName = '' then
          Continue; // handler atribuido em codigo (nao publicado): o DFM nao liga
        if MName <> '' then
          RM := FCtx.GetType(Target.ClassType).GetMethod(MName);
        if RM = nil then
        begin
          Inc(FSigWarnings);
          Log(Format('  AVISO assinatura %s.%s -> %s.%s: metodo sem RTTI',
            [APath, P.Name, Target.ClassName, MName]));
          Continue;
        end;
        if not (P.PropertyType is TRttiMethodType) then
          Continue;
        Err := CompareSignature(TRttiMethodType(P.PropertyType), RM, Warn);
        if Err <> '' then
        begin
          Inc(FSigErrors);
          Log(Format('  ERRO assinatura %s.%s (%s) -> %s.%s: %s',
            [APath, P.Name, P.PropertyType.Name, Target.ClassName, MName, Err]));
        end
        else
        if Warn <> '' then
        begin
          Inc(FSigWarnings);
          Log(Format('  AVISO assinatura %s.%s (%s) -> %s.%s:%s',
            [APath, P.Name, P.PropertyType.Name, Target.ClassName, MName, Warn]));
        end;
      end
      else
      if P.PropertyType.TypeKind = tkClass then
      begin
        try
          V := P.GetValue(AObj);
          Sub := V.AsObject;
        except
          Sub := nil;
        end;
        if (Sub = nil) or (Sub is TComponent) or (Sub is TFont) or (Sub is TStrings) or
           (Sub is TGraphic) or (Sub is TPicture) or (Sub is TBrush) or (Sub is TPen) then
          Continue;
        if Sub is TCollection then
        begin
          for I := 0 to TCollection(Sub).Count - 1 do
            CheckEvents(TCollection(Sub).Items[I],
              Format('%s.%s[%d]', [APath, P.Name, I]), ADepth + 1);
        end
        else
        if Sub is TPersistent then
          CheckEvents(Sub, APath + '.' + P.Name, ADepth + 1);
      end;
    end;
  finally
    Names.Free;
  end;
end;

procedure TSweep.CheckComponentTree(AComp: TComponent; const APath: string);
var
  I: Integer;
  C: TComponent;
  N: string;
begin
  CheckEvents(AComp, APath, 0);
  for I := 0 to AComp.ComponentCount - 1 do
  begin
    C := AComp.Components[I];
    N := C.Name;
    if N = '' then
      N := '<' + C.ClassName + '>';
    CheckComponentTree(C, APath + '.' + N);
  end;
end;

procedure TSweep.ListJvcl(AComp: TComponent);
var
  Counts: TDictionary<string, Integer>;
  Keys: TArray<string>;
  S, K: string;

  procedure Walk(C: TComponent);
  var
    I, N: Integer;
  begin
    for I := 0 to C.ComponentCount - 1 do
    begin
      if C.Components[I].ClassName.StartsWith('TJv') then
      begin
        if not Counts.TryGetValue(C.Components[I].ClassName, N) then
          N := 0;
        Counts.AddOrSetValue(C.Components[I].ClassName, N + 1);
      end;
      Walk(C.Components[I]);
    end;
  end;

begin
  Counts := TDictionary<string, Integer>.Create;
  try
    Walk(AComp);
    if Counts.Count = 0 then
      Exit;
    Keys := Counts.Keys.ToArray;
    TArray.Sort<string>(Keys);
    S := '';
    for K in Keys do
      S := S + Format(' %sx%d', [K, Counts[K]]);
    Log('  JVCL:' + S);
  finally
    Counts.Free;
  end;
end;

function StripHotKey(const S: string): string;
begin
  Result := StringReplace(S, '&&', #1, [rfReplaceAll]);
  Result := StringReplace(Result, '&', '', [rfReplaceAll]);
  Result := StringReplace(Result, #1, '&', [rfReplaceAll]);
end;

function TSweep.TextWidthOf(AControl: TControl; const AText: string): Integer;
begin
  FMeasure.Canvas.Font.Assign(TControlAccess(AControl).Font);
  Result := FMeasure.Canvas.TextWidth(StripHotKey(AText));
end;

function CtlName(C: TControl): string;
begin
  Result := C.Name;
  if Result = '' then
    Result := '<' + C.ClassName + '>';
end;

function IsInputControl(C: TControl): Boolean;
begin
  Result := (C is TCustomEdit) or (C is TCustomComboBox) or (C is TCustomListBox) or
    (C is TButtonControl) or (C is TCustomListView) or (C is TCustomTreeView) or
    (C is TCustomUpDown) or (C is TTrackBar) or (C is TDateTimePicker) or
    (C is TCustomHotKey);
end;

procedure TSweep.CheckLayoutOf(AParent: TWinControl; const APath: string);
var
  I, J, TW, Need, CW, CH: Integer;
  C, D: TControl;
  R, R2, X: TRect;
  Path, Cap: string;
  DT: TRect;

  procedure Report(const What: string);
  begin
    Inc(FLayout);
    Log(Format('  LAYOUT %s: %s', [Path, What]));
  end;

begin
  CW := AParent.ClientWidth;
  CH := AParent.ClientHeight;
  for I := 0 to AParent.ControlCount - 1 do
  begin
    C := AParent.Controls[I];
    if not C.Visible then
      Continue;
    Path := APath + '.' + CtlName(C);
    R := C.BoundsRect;
    // filhos de barras (botoes de toolbar, paineis de status) se reorganizam
    if not ((AParent is TToolBar) or (AParent is TStatusBar) or (AParent is TCoolBar) or
       (AParent is TScrollBox) or (AParent is TCustomForm) and TForm(AParent).AutoScroll and
       (TForm(AParent).HorzScrollBar.IsScrollBarVisible or
        TForm(AParent).VertScrollBar.IsScrollBarVisible)) then
    begin
      if (R.Right > CW + 2) and (C.Width > 0) then
        Report(Format('passa da largura do pai em %d px (dir %d > %d)', [R.Right - CW, R.Right, CW]));
      if (R.Bottom > CH + 2) and (C.Height > 0) then
        Report(Format('passa da altura do pai em %d px (base %d > %d)', [R.Bottom - CH, R.Bottom, CH]));
      if (R.Left < -2) or (R.Top < -2) then
        Report(Format('posicao negativa (%d,%d)', [R.Left, R.Top]));
    end;
    // textos
    if C is TCustomLabel then
    begin
      Cap := TLabel(C).Caption;
      if (Cap <> '') and not TLabel(C).AutoSize then
      begin
        if TLabel(C).WordWrap then
        begin
          FMeasure.Canvas.Font.Assign(TLabel(C).Font);
          DT := Rect(0, 0, C.Width, 0);
          DrawText(FMeasure.Canvas.Handle, PChar(StripHotKey(Cap)), -1, DT,
            DT_CALCRECT or DT_WORDBREAK);
          if DT.Height > C.Height + 1 then
            Report(Format('rotulo (quebra) cortado na altura: precisa %d, tem %d "%s"', [DT.Height, C.Height, Cap]));
        end
        else
        begin
          TW := TextWidthOf(C, Cap);
          if (TW > C.Width + 1) and not (TLabel(C).EllipsisPosition <> epNone) then
            Report(Format('rotulo cortado: texto %d px, largura %d "%s"', [TW, C.Width, Cap]));
          FMeasure.Canvas.Font.Assign(TLabel(C).Font);
          if FMeasure.Canvas.TextHeight('Ag') > C.Height + 1 then
            Report(Format('rotulo cortado na altura: texto %d px, altura %d "%s"',
              [FMeasure.Canvas.TextHeight('Ag'), C.Height, Cap]));
        end;
      end;
      // rotulo por cima de um campo vizinho
      for J := 0 to AParent.ControlCount - 1 do
      begin
        D := AParent.Controls[J];
        if (D = C) or not D.Visible or not IsInputControl(D) or (D.Align <> alNone) then
          Continue;
        R2 := D.BoundsRect;
        if IntersectRect(X, R, R2) and (X.Width > 2) and (X.Height > 2) then
        begin
          // so conta se o texto (nao so a caixa do rotulo) invade o campo
          TW := TextWidthOf(C, Cap);
          if (TLabel(C).Alignment = taLeftJustify) and (R.Left + TW <= R2.Left) then
            Continue;
          if (TLabel(C).Alignment = taRightJustify) and (R.Right - TW >= R2.Right) then
            Continue;
          Report(Format('rotulo "%s" sobre %s (%dx%d px)', [Cap, CtlName(D), X.Width, X.Height]));
        end;
      end;
    end
    else
    if (C is TButton) or (C is TCheckBox) or (C is TRadioButton) or (C is TBitBtn) then
    begin
      Cap := TControlAccess(C).Caption;
      if Cap <> '' then
      begin
        TW := TextWidthOf(C, Cap);
        if (C is TCheckBox) or (C is TRadioButton) then
        begin
          if ((C is TCheckBox) and TCheckBox(C).WordWrap) or
             ((C is TRadioButton) and TRadioButton(C).WordWrap) then
            Need := 0
          else
            Need := TW + GetSystemMetrics(SM_CXMENUCHECK) + 4;
        end
        else
        if C is TBitBtn then
        begin
          Need := TW + 8;
          if not TBitBtn(C).Glyph.Empty then
            Need := Need + TBitBtn(C).Glyph.Width div Max(1, TBitBtn(C).NumGlyphs) + TBitBtn(C).Spacing;
        end
        else
        if TButton(C).WordWrap then
          Need := 0
        else
          Need := TW + 6;
        if (Need > 0) and (Need > C.Width) then
          Report(Format('texto cortado: precisa %d px, largura %d "%s"', [Need, C.Width, StripHotKey(Cap)]));
        FMeasure.Canvas.Font.Assign(TControlAccess(C).Font);
        if FMeasure.Canvas.TextHeight('Ag') > C.Height then
          Report(Format('texto cortado na altura: %d px, altura %d "%s"',
            [FMeasure.Canvas.TextHeight('Ag'), C.Height, StripHotKey(Cap)]));
      end;
    end
    else
    if (C is TCustomEdit) and not (C is TCustomMemo) and not (C is TCustomRichEdit) then
    begin
      FMeasure.Canvas.Font.Assign(TControlAccess(C).Font);
      if FMeasure.Canvas.TextHeight('Ag') + 2 > C.ClientHeight then
        Report(Format('campo baixo para a fonte: texto %d px, area %d', [FMeasure.Canvas.TextHeight('Ag'), C.ClientHeight]));
    end;
    if (C is TWinControl) and not (C is TToolBar) and not (C is TCustomListView) and
       not (C is TCustomTreeView) and not (C is TCustomComboBox) then
      CheckLayoutOf(TWinControl(C), Path);
  end;
end;

procedure TSweep.CheckPageControls(AParent: TWinControl);
var
  I, J: Integer;
  PC: TPageControl;
  Old: TTabSheet;
begin
  for I := 0 to AParent.ControlCount - 1 do
    if AParent.Controls[I] is TWinControl then
    begin
      if (AParent.Controls[I] is TPageControl) and AParent.Controls[I].Visible then
      begin
        PC := TPageControl(AParent.Controls[I]);
        Old := PC.ActivePage;
        for J := 0 to PC.PageCount - 1 do
          if PC.Pages[J].TabVisible and (PC.Pages[J] <> Old) then
          begin
            try
              PC.ActivePage := PC.Pages[J];
              Application.ProcessMessages;
              CheckLayoutOf(PC.Pages[J], PC.Owner.Name + '.' + PC.Name + '[' + PC.Pages[J].Name + ']');
            except
              on E: Exception do
                Log(Format('  ERRO ao trocar de pagina %s.%s: %s: %s', [PC.Name, PC.Pages[J].Name, E.ClassName, E.Message]));
            end;
          end;
        try
          PC.ActivePage := Old;
        except
        end;
      end;
      CheckPageControls(TWinControl(AParent.Controls[I]));
    end;
end;

procedure TSweep.CheckLayout(AForm: TCustomForm);
var
  WA: TRect;
begin
  WA := Screen.MonitorFromWindow(AForm.Handle).WorkareaRect;
  if (AForm.Width > WA.Width) or (AForm.Height > WA.Height) then
  begin
    Inc(FLayout);
    Log(Format('  LAYOUT form %dx%d maior que a area de trabalho %dx%d',
      [AForm.Width, AForm.Height, WA.Width, WA.Height]));
  end;
  CheckLayoutOf(AForm, AForm.Name);
  CheckPageControls(AForm);
end;

{ captura de uma janela do proprio processo: PrintWindow sem flags (com
  PW_RENDERFULLCONTENT o resultado sai em branco no mesmo thread); se vier
  uniforme, copia da tela (a janela acabou de ser mostrada, esta na frente) }
procedure CaptureWindow(AWnd: HWND; ABmp: TBitmap);
var
  R: TRect;
  DC: HDC;
  Y, X: Integer;
  First: TColor;
  Uniform: Boolean;
begin
  GetWindowRect(AWnd, R);
  ABmp.PixelFormat := pf24bit;
  ABmp.SetSize(R.Width, R.Height);
  PrintWindow(AWnd, ABmp.Canvas.Handle, 0);
  Uniform := True;
  First := ABmp.Canvas.Pixels[R.Width div 2, R.Height div 2];
  Y := 0;
  while Uniform and (Y < R.Height) do
  begin
    X := 0;
    while X < R.Width do
    begin
      if ABmp.Canvas.Pixels[X, Y] <> First then
      begin
        Uniform := False;
        Break;
      end;
      Inc(X, 7);
    end;
    Inc(Y, 7);
  end;
  if Uniform then
  begin
    DC := GetDC(0);
    try
      BitBlt(ABmp.Canvas.Handle, 0, 0, R.Width, R.Height, DC, R.Left, R.Top, SRCCOPY);
    finally
      ReleaseDC(0, DC);
    end;
  end;
end;

procedure TSweep.SaveShot(AForm: TCustomForm; const AName: string);
var
  R: TRect;
  Bmp: TBitmap;
  Png: TPngImage;
begin
  if not FShots or not AForm.HandleAllocated then
    Exit;
  Bmp := TBitmap.Create;
  try
    CaptureWindow(AForm.Handle, Bmp);
    Png := TPngImage.Create;
    try
      Png.Assign(Bmp);
      Png.SaveToFile(IncludeTrailingPathDelimiter(FDir) + AName + '.png');
    finally
      Png.Free;
    end;
  finally
    Bmp.Free;
  end;
end;

procedure TSweep.SweepClass(AClass: TClass);
var
  F: TCustomForm;
  Host: TForm;
  Frame: TCustomFrame;
  Target: TComponent;
  Stage: string;
begin
  FCurrentName := AClass.ClassName;
  Log('');
  Log(Format('[%s] (%s)', [AClass.ClassName, AClass.UnitName]));
  Host := nil;
  F := nil;
  Target := nil;
  Stage := 'criacao';
  try
    if AClass.InheritsFrom(TCustomFrame) then
    begin
      Host := TForm.CreateNew(Application);
      Host.Caption := 'Host ' + AClass.ClassName;
      Host.SetBounds(40, 40, 900, 650);
      Frame := TCustomFrameClass(AClass).Create(Host);
      Frame.Parent := Host;
      Frame.Align := alClient;
      F := Host;
      Target := Frame;
    end
    else
    begin
      F := TCustomFormClass(AClass).Create(Application);
      Target := F;
    end;
    FCurrent := F;
    Log('  criacao OK');
    Stage := 'assinaturas';
    CheckComponentTree(Target, Target.Name);
    ListJvcl(Target);
    if not FNoShow then
    begin
      Stage := 'Show';
      F.Show;
      Pump(700);
      if (F <> nil) and (FWatcher.FreedObj <> F) and F.Visible then
      begin
        Stage := 'layout';
        Log(Format('  janela %dx%d (cliente %dx%d), fonte %s %d', [F.Width, F.Height,
          F.ClientWidth, F.ClientHeight, F.Font.Name, F.Font.Size]));
        CheckLayout(F);
        SaveShot(F, AClass.ClassName);
      end
      else
        Log('  (o form se fechou sozinho no Show)');
    end;
    Stage := 'Close';
    FWatcher.FreedObj := nil;
    F.FreeNotification(FWatcher);
    if F.Visible then
    begin
      F.Close;
      Pump(300);
    end;
    Stage := 'destruicao';
    if FWatcher.FreedObj <> F then
      F.Free
    else
      Log('  (liberado pelo proprio form: caFree)');
    F := nil;
    Log('  destruicao OK');
  except
    on E: Exception do
    begin
      Inc(FErrors);
      Log(Format('  ERRO na etapa %s: %s: %s em %s', [Stage, E.ClassName, E.Message,
        GetLocationInfoStr(ExceptAddr)]));
      if Assigned(F) and (FWatcher.FreedObj <> F) then
      try
        F.Free;
      except
        on E2: Exception do
          Log(Format('  ERRO ao destruir depois do erro: %s: %s', [E2.ClassName, E2.Message]));
      end;
    end;
  end;
  FCurrent := nil;
  Pump(50);
end;

function IsOwnUnit(const AUnit: string): Boolean;
const
  Foreign: array[0..12] of string = ('Jv', 'Jcl', 'Syn', 'VirtualTrees', 'Ab', 'Overbyte',
    'Vcl', 'System', 'Winapi', 'Data', 'Xml', 'Soap', 'Web');
var
  S: string;
begin
  Result := Pos('.', AUnit) = 0;
  // prefixo de biblioteca seguido de maiuscula (JvXxx, AbXxx, SynXxx), sem
  // pegar JVCS*, About, Syncronice
  if Result then
    for S in Foreign do
      if AUnit.StartsWith(S, False) and (Length(AUnit) > Length(S)) and
         CharInSet(AUnit[Length(S) + 1], ['A'..'Z', '0'..'9', '_']) then
        Exit(False);
end;

procedure TSweep.Run;
var
  T: TRttiType;
  Classes: TList<TClass>;
  C: TClass;
  OldExc: TExceptionEvent;
  FS: TJVCSUIFontSettings;
  I: Integer;
begin
  Log(Format('JEDI VCS formsweep %s  escala=%d  show=%s  shots=%s  filtro="%s"',
    [FormatDateTime('yyyy-mm-dd hh:nn:ss', Now), FScale, BoolToStr(not FNoShow, True),
     BoolToStr(FShots, True), FFilter]));
  Log(Format('Tela %dx%d, area de trabalho %dx%d, PixelsPerInch %d',
    [Screen.Width, Screen.Height, Screen.WorkAreaWidth, Screen.WorkAreaHeight, Screen.PixelsPerInch]));
  if FScale > 0 then
  begin
    FS := JVCSUIFontSettings;
    FS.Scale := FScale;
    JVCSUISetFontSettings(FS, False);
  end;
  OldExc := Application.OnException;
  Application.OnException := AppException;
  FTimer.Enabled := True;
  Classes := TList<TClass>.Create;
  try
    for T in FCtx.GetTypes do
      if (T is TRttiInstanceType) and IsOwnUnit(TRttiInstanceType(T).DeclaringUnitName) then
      begin
        C := TRttiInstanceType(T).MetaclassType;
        if not (C.InheritsFrom(TCustomForm) or C.InheritsFrom(TCustomFrame)) then
          Continue;
        if FindResource(FindClassHInstance(C), PChar(C.ClassName), RT_RCDATA) = 0 then
        begin
          Log(Format('(sem DFM, ignorado: %s em %s)', [C.ClassName, C.UnitName]));
          Continue;
        end;
        if (FFilter <> '') and (Pos(LowerCase(FFilter), LowerCase(C.ClassName)) = 0) then
          Continue;
        Classes.Add(C);
      end;
    Classes.Sort(TComparer<TClass>.Construct(
      function(const A, B: TClass): Integer
      begin
        Result := CompareText(A.ClassName, B.ClassName);
      end));
    Log(Format('%d classes', [Classes.Count]));
    // as instancias ja criadas pelo .dpr: so assinaturas (o Show do ProjAdmin
    // dispara o login)
    for I := 0 to Screen.DataModuleCount - 1 do
    begin
      Log('');
      Log(Format('[instancia %s] assinaturas', [Screen.DataModules[I].ClassName]));
      CheckComponentTree(Screen.DataModules[I], Screen.DataModules[I].Name);
    end;
    if Assigned(Application.MainForm) then
    begin
      Log('');
      Log(Format('[instancia %s] assinaturas', [Application.MainForm.ClassName]));
      CheckComponentTree(Application.MainForm, Application.MainForm.Name);
      ListJvcl(Application.MainForm);
    end;
    for C in Classes do
      if (Application.MainForm = nil) or (C <> Application.MainForm.ClassType) then
        SweepClass(C);
  finally
    Classes.Free;
    FTimer.Enabled := False;
    Application.OnException := OldExc;
  end;
  // forms que algum form da varredura deixou abertos (ex.: janelas de dock):
  // liberar agora, com as units ainda inicializadas
  for I := Screen.FormCount - 1 downto 0 do
    if (Screen.Forms[I] <> Application.MainForm) then
    try
      Log('(liberando form restante ' + Screen.Forms[I].ClassName + ')');
      Screen.Forms[I].Free;
    except
      on E: Exception do
        Log(Format('  ERRO ao liberar: %s: %s', [E.ClassName, E.Message]));
    end;
  Log('');
  Log(Format('RESUMO: erros=%d assinaturas_erradas=%d avisos_assinatura=%d layout=%d dialogos=%d',
    [FErrors, FSigErrors, FSigWarnings, FLayout, FDialogs]));
end;

procedure JVCSRunFormSweep;
var
  S: TSweep;
begin
  S := TSweep.Create;
  try
    S.Run;
  finally
    S.Free;
  end;
end;

{ ---------------------------------------------------------------------------
  Automacao de teste (so Debug, so com JVCS_DEBUG_AUTOMATION=1 no ambiente).
  Um TTimer le %TEMP%\jvcs-debug-cmd.txt (apaga ao ler) e executa cada linha:
    click <Classe do form> <componente>            TMenuItem/TAction/botoes
    set   <Classe do form> <componente> <texto>    Text de edit/memo/combo
    check <Classe do form> <componente> 0|1        TCheckBox/TRadioButton
    index <Classe do form> <componente> <n>        ItemIndex/selecao
    get   <Classe do form> <componente>            texto/estado
    dump  <Classe do form>                         nomes, classes e textos
    forms                                          forms abertos
    stack                                          pilha do thread principal
    shot  <Classe do form> <arquivo.png>           captura da janela
    colclick <Classe do form> <listview> <n>       clique no cabecalho da coluna n
    popup <Classe do form> <popupmenu>             executa o OnPopup
  O resultado vai para %TEMP%\jvcs-debug-out.txt. Funciona com dialogos
  modais abertos (o loop modal processa o timer).
  --------------------------------------------------------------------------- }

type
  TJVCSDebugAutomation = class
  private
    FTimer: TTimer;
    FBusy: Boolean;
    procedure Tick(Sender: TObject);
    procedure Exec(const ALine: string);
    procedure AppMinimize(Sender: TObject);
    procedure Out(const S: string);
  public
    constructor Create;
    destructor Destroy; override;
  end;

var
  GAutomation: TJVCSDebugAutomation = nil;

function AutoDir: string;
begin
  Result := IncludeTrailingPathDelimiter(GetEnvironmentVariable('TEMP'));
end;

constructor TJVCSDebugAutomation.Create;
begin
  inherited Create;
  FTimer := TTimer.Create(nil);
  FTimer.Interval := 250;
  FTimer.OnTimer := Tick;
end;

destructor TJVCSDebugAutomation.Destroy;
begin
  FTimer.Free;
  inherited Destroy;
end;

procedure TJVCSDebugAutomation.Out(const S: string);
var
  W: TStreamWriter;
begin
  W := TStreamWriter.Create(AutoDir + 'jvcs-debug-out.txt', True, TEncoding.UTF8);
  try
    W.WriteLine(FormatDateTime('hh:nn:ss.zzz ', Now) + S);
  finally
    W.Free;
  end;
end;

procedure TJVCSDebugAutomation.AppMinimize(Sender: TObject);
var
  SL: TStringList;
  I: Integer;
begin
  // investigacao (item 4 da F4): quem minimiza o app? pilha no momento
  Out('*** Application.OnMinimize');
  SL := TStringList.Create;
  try
    with JclCreateStackList(True, 0, nil) do
    try
      AddToStrings(SL, True, True, True, True);
    finally
      Free;
    end;
    for I := 0 to SL.Count - 1 do
      Out('  ' + SL[I]);
  finally
    SL.Free;
  end;
end;

procedure TJVCSDebugAutomation.Tick(Sender: TObject);
var
  F: string;
  L: TStringList;
  I: Integer;
begin
  if FBusy then
    Exit;
  F := AutoDir + 'jvcs-debug-cmd.txt';
  if not FileExists(F) then
    Exit;
  L := TStringList.Create;
  try
    FBusy := True;
    try
      try
        L.LoadFromFile(F, TEncoding.UTF8);
        DeleteFile(F);
      except
        Exit; // ainda sendo gravado
      end;
    finally
      FBusy := False;
    end;
    // executa fora do FBusy: um comando pode abrir um modal e o timer volta
    for I := 0 to L.Count - 1 do
      if Trim(L[I]) <> '' then
      try
        Exec(Trim(L[I]));
      except
        on E: Exception do
          Out(Format('ERRO "%s": %s: %s', [L[I], E.ClassName, E.Message]));
      end;
  finally
    L.Free;
  end;
end;

function FindFormByClass(const AClass: string): TCustomForm;
var
  I: Integer;
begin
  for I := 0 to Screen.CustomFormCount - 1 do
    if SameText(Screen.CustomForms[I].ClassName, AClass) then
      Exit(Screen.CustomForms[I]);
  Result := nil;
end;

function FindCompDeep(AOwner: TComponent; const AName: string): TComponent;
var
  I: Integer;
begin
  Result := AOwner.FindComponent(AName);
  if Result <> nil then
    Exit;
  for I := 0 to AOwner.ComponentCount - 1 do
    if AOwner.Components[I].ComponentCount > 0 then
    begin
      Result := FindCompDeep(AOwner.Components[I], AName);
      if Result <> nil then
        Exit;
    end;
end;

function CompText(C: TComponent): string;
var
  I: Integer;
begin
  Result := '';
  if C is TMenuItem then
    Result := TMenuItem(C).Caption + IfThen(TMenuItem(C).Enabled, '', ' [desab]') +
      IfThen(TMenuItem(C).Visible, '', ' [oculto]') + IfThen(TMenuItem(C).Checked, ' [x]', '')
  else
  if C is TCustomAction then
    Result := TCustomAction(C).Caption + IfThen(TCustomAction(C).Enabled, '', ' [desab]')
  else
  if C is TControl then
  begin
    Result := TControlAccess(C).Text;
    if Result = '' then
      Result := TControlAccess(C).Caption;
    if C is TCustomListBox then
      Result := Format('%d itens, sel=%d: %s', [TCustomListBox(C).Items.Count,
        TCustomListBox(C).ItemIndex, StringReplace(TCustomListBox(C).Items.Text, #13#10, ' | ', [rfReplaceAll])])
    else
    if C is TCustomListView then
    begin
      Result := Format('%d itens', [TCustomListView(C).Items.Count]);
      for I := 0 to Min(TCustomListView(C).Items.Count, 40) - 1 do
        Result := Result + ' | ' + TCustomListView(C).Items[I].Caption + ' ; ' +
          StringReplace(TCustomListView(C).Items[I].SubItems.Text, #13#10, ' ; ', [rfReplaceAll]) +
          IfThen(TCustomListView(C).Items[I].Selected, ' <sel>', '') +
          IfThen(TCustomListView(C).Items[I].Checked, ' <chk>', '');
    end
    else
    if C is TCheckBox then
      Result := Result + IfThen(TCheckBox(C).Checked, ' [x]', ' [ ]')
    else
    if C is TRadioButton then
      Result := Result + IfThen(TRadioButton(C).Checked, ' (o)', ' ( )');
    if not TControl(C).Enabled then
      Result := Result + ' [desab]';
    if not TControl(C).Visible then
      Result := Result + ' [oculto]';
  end;
  Result := StringReplace(Result, #13#10, ' | ', [rfReplaceAll]);
end;

procedure SaveFormShot(AForm: TCustomForm; const AFile: string);
var
  R: TRect;
  Bmp: TBitmap;
  Png: TPngImage;
begin
  Bmp := TBitmap.Create;
  try
    CaptureWindow(AForm.Handle, Bmp);
    Png := TPngImage.Create;
    try
      Png.Assign(Bmp);
      Png.SaveToFile(AFile);
    finally
      Png.Free;
    end;
  finally
    Bmp.Free;
  end;
end;

procedure TJVCSDebugAutomation.Exec(const ALine: string);
var
  P: TArray<string>;
  Cmd, Txt: string;
  F: TCustomForm;
  C: TComponent;
  I: Integer;
  SL: TStringList;
  SB: TJVCSStatusBar;
  J: Integer;

  procedure DumpTree(AOwner: TComponent; const APrefix: string);
  var
    J: Integer;
  begin
    for J := 0 to AOwner.ComponentCount - 1 do
    begin
      Out(Format('  %s%s: %s = %s', [APrefix, AOwner.Components[J].Name,
        AOwner.Components[J].ClassName, CompText(AOwner.Components[J])]));
      if AOwner.Components[J].ComponentCount > 0 then
        DumpTree(AOwner.Components[J], APrefix + AOwner.Components[J].Name + '.');
    end;
  end;

begin
  // ate 3 palavras + o resto da linha (texto com espacos) como 4o parametro
  P := ALine.Split([' '], 4);
  if Length(P) = 4 then
  begin
    I := Pos(' ', ALine);
    I := Pos(' ', ALine, I + 1);
    I := Pos(' ', ALine, I + 1);
    P[3] := Copy(ALine, I + 1, MaxInt);
  end;
  Cmd := LowerCase(P[0]);
  Out('> ' + ALine);
  if Cmd = 'stack' then
  begin
    // pilha do thread principal neste ponto (o timer roda dentro de qualquer
    // laco de mensagens: mostra quem esta esperando)
    SL := TStringList.Create;
    try
      with JclCreateStackList(True, 0, nil) do
      try
        AddToStrings(SL, True, True, True, True);
      finally
        Free;
      end;
      for I := 0 to SL.Count - 1 do
        Out('  ' + SL[I]);
    finally
      SL.Free;
    end;
    Exit;
  end;
  if Cmd = 'forms' then
  begin
    Out(Format('  Terminated=%s ModalLevel=%d MainForm=%s visivel=%s', [BoolToStr(Application.Terminated, True),
      Application.ModalLevel, IfThen(Assigned(Application.MainForm), Application.MainForm.ClassName, 'nil'),
      BoolToStr(Assigned(Application.MainForm) and Application.MainForm.Visible, True)]));
    for I := 0 to Screen.CustomFormCount - 1 do
      Out(Format('  %s "%s" visivel=%s modal=%s', [Screen.CustomForms[I].ClassName,
        Screen.CustomForms[I].Caption, BoolToStr(Screen.CustomForms[I].Visible, True),
        BoolToStr(fsModal in Screen.CustomForms[I].FormState, True)]));
    Exit;
  end;
  if Length(P) < 2 then
    raise Exception.Create('faltam parametros');
  F := FindFormByClass(P[1]);
  if F = nil then
    raise Exception.Create('form nao encontrado: ' + P[1]);
  if Cmd = 'dump' then
  begin
    Out(Format('  [%s "%s" %dx%d]', [F.ClassName, F.Caption, F.Width, F.Height]));
    DumpTree(F, '');
    Exit;
  end;
  if Length(P) < 3 then
    raise Exception.Create('falta o componente');
  if Cmd = 'shot' then
  begin
    SaveFormShot(F, P[2]);
    Out('  ok');
    Exit;
  end;
  C := FindCompDeep(F, P[2]);
  if C = nil then
    raise Exception.Create('componente nao encontrado: ' + P[2]);
  if Length(P) > 3 then
    Txt := P[3]
  else
    Txt := '';
  if Cmd = 'click' then
  begin
    Out('  executando ' + P[2]);
    if C is TMenuItem then
      TMenuItem(C).Click
    else
    if C is TBasicAction then
      TBasicAction(C).Execute
    else
    if C is TToolButton then
      TToolButton(C).Click
    else
    if C is TButtonControl then
      TButtonControlAccess(C).Click
    else
    if C is TSpeedButton then
      TSpeedButton(C).Click
    else
    if C is TControl then
      TControlAccess(C).Click;
    Out('  fim ' + P[2]);
  end
  else
  if Cmd = 'set' then
  begin
    if C is TCustomEdit then
      TControlAccess(C).Text := Txt
    else
    if C is TCustomComboBox then
    begin
      TComboBoxAccess(C).Text := Txt;
      TComboBoxAccess(C).Change;
    end
    else
      TControlAccess(C).Text := Txt;
    Out('  ok');
  end
  else
  if Cmd = 'check' then
  begin
    if C is TCheckBox then
      TCheckBox(C).Checked := Txt = '1'
    else
    if C is TRadioButton then
      TRadioButton(C).Checked := Txt = '1';
    Out('  ok');
  end
  else
  if Cmd = 'index' then
  begin
    if C is TCustomComboBox then
    begin
      TCustomComboBox(C).ItemIndex := StrToInt(Txt);
      TComboBoxAccess(C).Change;
      TComboBoxAccess(C).Select;
    end
    else
    if C is TCustomListBox then
    begin
      TCustomListBox(C).ItemIndex := StrToInt(Txt);
      TControlAccess(C).Click;
    end
    else
    if C is TPageControl then
    begin
      TPageControl(C).ActivePageIndex := StrToInt(Txt);
      if Assigned(TPageControl(C).OnChange) then
        TPageControl(C).OnChange(C);
    end
    else
    if C is TCustomRadioGroup then
      TRadioGroup(C).ItemIndex := StrToInt(Txt)
    else
    if C is TCustomListView then
    begin
      TCustomListView(C).ClearSelection;
      TCustomListView(C).Items[StrToInt(Txt)].Selected := True;
      TCustomListView(C).Items[StrToInt(Txt)].Focused := True;
    end;
    Out('  ok');
  end
  else
  if Cmd = 'stateidx' then
  begin
    // stateidx <form> <listview> <item|all>:<StateIndex> (marcacao por icone de estado)
    I := StrToInt(Copy(Txt, Pos(':', Txt) + 1, MaxInt));
    Txt := Copy(Txt, 1, Pos(':', Txt) - 1);
    if Txt = 'all' then
    begin
      for J := 0 to TCustomListView(C).Items.Count - 1 do
        TCustomListView(C).Items[J].StateIndex := I;
    end
    else
      TCustomListView(C).Items[StrToInt(Txt)].StateIndex := I;
    Out('  ok');
  end
  else
  if Cmd = 'check' + 'item' then
  begin
    // checkitem <form> <listview> <item|all>:<0|1> (Checked do item)
    I := StrToInt(Copy(Txt, Pos(':', Txt) + 1, MaxInt));
    Txt := Copy(Txt, 1, Pos(':', Txt) - 1);
    for J := 0 to TCustomListView(C).Items.Count - 1 do
      if (Txt = 'all') or (J = StrToInt(Txt)) then
        TCustomListView(C).Items[J].Checked := I = 1;
    Out('  ok');
  end
  else
  if Cmd = 'colclick' then
  begin
    // clique no cabecalho da coluna n (ordenacao)
    TListViewAccess(C).ColClick(TListView(C).Columns[StrToInt(Txt)]);
    Out('  ok');
  end
  else
  if Cmd = 'gauge' then
  begin
    // painel P da TJVCSStatusBar como gauge: gauge <form> <statusbar> <P>:<pos|ind|off>
    SB := C as TJVCSStatusBar;
    with SB.Panels[StrToInt(Copy(Txt, 1, Pos(':', Txt) - 1))] do
    begin
      Txt := Copy(Txt, Pos(':', Txt) + 1, MaxInt);
      if Txt = 'off' then
        PanelType := sptNormal
      else
      begin
        PanelType := sptGauge;
        if Txt = 'ind' then
          GaugeAttrs.Style := gsIndeterminate2
        else
        begin
          GaugeAttrs.Style := gsPercent;
          GaugeAttrs.Position := StrToInt(Txt);
        end;
      end;
    end;
    Out('  ok');
  end
  else
  if Cmd = 'popup' then
  begin
    // dispara o OnPopup de um TPopupMenu (estado dos itens)
    if Assigned(TPopupMenu(C).OnPopup) then
      TPopupMenu(C).OnPopup(C);
    Out('  ok');
  end
  else
  if Cmd = 'get' then
    Out('  = ' + CompText(C))
  else
    raise Exception.Create('comando desconhecido: ' + Cmd);
end;

procedure JVCSDebugAutomationStart;
begin
  if (GAutomation = nil) and (GetEnvironmentVariable('JVCS_DEBUG_AUTOMATION') = '1') then
  begin
    GAutomation := TJVCSDebugAutomation.Create;
    Application.OnMinimize := GAutomation.AppMinimize;
    GAutomation.Out('automacao ativa, pid ' + IntToStr(GetCurrentProcessId));
  end;
end;

initialization

finalization
  FreeAndNil(GAutomation);

end.
