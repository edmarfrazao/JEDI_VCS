(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

The Original Code is: JVCSStatusBar.pas

JEDI VCS 2.5 Beta 2026 (port Delphi 13): TJVCSStatusBar, substituto nativo da
TdfsStatusBar 1.24 (DFS), escrito do zero sobre o TStatusBar da VCL (nao contem
codigo da DFS). Cobre o que o ProjAdmin e o Syncronice usam:
  - por painel: Enabled, AutoFit, Hint, OnClick, OnDrawPanel, PanelType
    (sptNormal, sptGauge, sptOwnerDraw) e GaugeAttrs (Style, Position, Speed,
    Color);
  - gauge = TProgressBar sobre o painel (pbstMarquee no modo indeterminado).
-----------------------------------------------------------------------------*)

unit JVCSStatusBar;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.CommCtrl, System.SysUtils,
  System.Classes, Vcl.Controls, Vcl.Graphics, Vcl.ComCtrls, Vcl.Forms;

type
  TJVCSStatusPanelType = (sptNormal, sptCapsLock, sptNumLock, sptScrollLock,
    sptDate, sptTime, sptDateTime, sptTimeDate, sptEllipsisText,
    sptEllipsisPath, sptGlyph, sptGauge, sptOwnerDraw);
  TJVCSGaugeStyle = (gsPercent, gsIndeterminate, gsIndeterminate2);

  TJVCSStatusBar = class;
  TJVCSStatusPanel = class;

  TJVCSDrawPanelEvent = procedure(StatusBar: TJVCSStatusBar;
    Panel: TJVCSStatusPanel; const Rect: TRect) of object;

  TJVCSGaugeAttrs = class(TPersistent)
  private
    FOwner: TJVCSStatusPanel;
    FStyle: TJVCSGaugeStyle;
    FPosition: Integer;
    FSpeed: Integer;
    FColor: TColor;
    procedure SetStyle(const Value: TJVCSGaugeStyle);
    procedure SetPosition(const Value: Integer);
  public
    constructor Create(AOwner: TJVCSStatusPanel);
    procedure Assign(Source: TPersistent); override;
  published
    property Style: TJVCSGaugeStyle read FStyle write SetStyle default gsPercent;
    property Position: Integer read FPosition write SetPosition default 0;
    property Speed: Integer read FSpeed write FSpeed default 4;
    property Color: TColor read FColor write FColor default clHighlight;
  end;

  TJVCSStatusPanel = class(TStatusPanel)
  private
    FEnabled: Boolean;
    FAutoFit: Boolean;
    FHint: string;
    FPanelType: TJVCSStatusPanelType;
    FGaugeAttrs: TJVCSGaugeAttrs;
    FOnClick: TNotifyEvent;
    FOnDrawPanel: TJVCSDrawPanelEvent;
    procedure SetPanelType(const Value: TJVCSStatusPanelType);
    procedure SetGaugeAttrs(const Value: TJVCSGaugeAttrs);
    procedure SetOnDrawPanel(const Value: TJVCSDrawPanelEvent);
    function StatusBarEx: TJVCSStatusBar;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property GaugeAttrs: TJVCSGaugeAttrs read FGaugeAttrs write SetGaugeAttrs;
    property PanelType: TJVCSStatusPanelType read FPanelType write SetPanelType default sptNormal;
    property Enabled: Boolean read FEnabled write FEnabled default True;
    property AutoFit: Boolean read FAutoFit write FAutoFit default False;
    property Hint: string read FHint write FHint;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnDrawPanel: TJVCSDrawPanelEvent read FOnDrawPanel write SetOnDrawPanel;
  end;

  TJVCSStatusPanels = class(TStatusPanels)
  private
    function GetItemEx(Index: Integer): TJVCSStatusPanel;
  public
    property Items[Index: Integer]: TJVCSStatusPanel read GetItemEx; default;
  end;

  TJVCSStatusBar = class(TStatusBar)
  private
    FGauge: TProgressBar;
    FGaugePanel: Integer;
    FDefaultHint: string;
    function GetPanel(Index: Integer): TJVCSStatusPanel;
    function PanelAt(X: Integer): Integer;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  protected
    function CreatePanels: TStatusPanels; override;
    function GetPanelsEx: TJVCSStatusPanels;
    procedure SetPanelsEx(const Value: TJVCSStatusPanels);
    function GetPanelClass: TStatusPanelClass; override;
    procedure DrawPanel(Panel: TStatusPanel; const Rect: TRect); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure Resize; override;
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure UpdateGauge;
    function PanelRect(Index: Integer): TRect;
    property PanelsEx[Index: Integer]: TJVCSStatusPanel read GetPanel;
  published
    property Panels: TJVCSStatusPanels read GetPanelsEx write SetPanelsEx;
  end;

implementation

{ TJVCSGaugeAttrs }

constructor TJVCSGaugeAttrs.Create(AOwner: TJVCSStatusPanel);
begin
  inherited Create;
  FOwner := AOwner;
  FStyle := gsPercent;
  FSpeed := 4;
  FColor := clHighlight;
end;

procedure TJVCSGaugeAttrs.Assign(Source: TPersistent);
begin
  if Source is TJVCSGaugeAttrs then
  begin
    FStyle := TJVCSGaugeAttrs(Source).Style;
    FPosition := TJVCSGaugeAttrs(Source).Position;
    FSpeed := TJVCSGaugeAttrs(Source).Speed;
    FColor := TJVCSGaugeAttrs(Source).Color;
  end
  else
    inherited Assign(Source);
end;

procedure TJVCSGaugeAttrs.SetPosition(const Value: Integer);
begin
  FPosition := Value;
  if Assigned(FOwner) and (FOwner.StatusBarEx <> nil) then
    FOwner.StatusBarEx.UpdateGauge;
end;

procedure TJVCSGaugeAttrs.SetStyle(const Value: TJVCSGaugeStyle);
begin
  FStyle := Value;
  if Assigned(FOwner) and (FOwner.StatusBarEx <> nil) then
    FOwner.StatusBarEx.UpdateGauge;
end;

{ TJVCSStatusPanel }

constructor TJVCSStatusPanel.Create(Collection: TCollection);
begin
  FGaugeAttrs := TJVCSGaugeAttrs.Create(Self);
  FEnabled := True;
  inherited Create(Collection);
end;

destructor TJVCSStatusPanel.Destroy;
begin
  FreeAndNil(FGaugeAttrs);
  inherited Destroy;
end;

procedure TJVCSStatusPanel.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
  if Source is TJVCSStatusPanel then
  begin
    FEnabled := TJVCSStatusPanel(Source).Enabled;
    FAutoFit := TJVCSStatusPanel(Source).AutoFit;
    FHint := TJVCSStatusPanel(Source).Hint;
    FPanelType := TJVCSStatusPanel(Source).PanelType;
    FGaugeAttrs.Assign(TJVCSStatusPanel(Source).GaugeAttrs);
    FOnClick := TJVCSStatusPanel(Source).OnClick;
    FOnDrawPanel := TJVCSStatusPanel(Source).OnDrawPanel;
  end;
end;

function TJVCSStatusPanel.StatusBarEx: TJVCSStatusBar;
begin
  if Assigned(Collection) and (Collection.Owner is TJVCSStatusBar) then
    Result := TJVCSStatusBar(Collection.Owner)
  else
    Result := nil;
end;

procedure TJVCSStatusPanel.SetGaugeAttrs(const Value: TJVCSGaugeAttrs);
begin
  FGaugeAttrs.Assign(Value);
end;

procedure TJVCSStatusPanel.SetOnDrawPanel(const Value: TJVCSDrawPanelEvent);
begin
  FOnDrawPanel := Value;
  if Assigned(FOnDrawPanel) or (FPanelType = sptOwnerDraw) then
    Style := psOwnerDraw;
end;

procedure TJVCSStatusPanel.SetPanelType(const Value: TJVCSStatusPanelType);
begin
  FPanelType := Value;
  if FPanelType = sptOwnerDraw then
    Style := psOwnerDraw
  else
  if not Assigned(FOnDrawPanel) then
    Style := psText;
  if StatusBarEx <> nil then
    StatusBarEx.UpdateGauge;
end;

{ TJVCSStatusPanels }

function TJVCSStatusPanels.GetItemEx(Index: Integer): TJVCSStatusPanel;
begin
  Result := inherited Items[Index] as TJVCSStatusPanel;
end;

{ TJVCSStatusBar }

function TJVCSStatusBar.CreatePanels: TStatusPanels;
begin
  Result := TJVCSStatusPanels.Create(Self);
end;

function TJVCSStatusBar.GetPanelsEx: TJVCSStatusPanels;
begin
  Result := TJVCSStatusPanels(inherited Panels);
end;

procedure TJVCSStatusBar.SetPanelsEx(const Value: TJVCSStatusPanels);
begin
  inherited Panels := Value;
end;

constructor TJVCSStatusBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FGaugePanel := -1;
  ShowHint := True;
end;

function TJVCSStatusBar.GetPanelClass: TStatusPanelClass;
begin
  Result := TJVCSStatusPanel;
end;

function TJVCSStatusBar.GetPanel(Index: Integer): TJVCSStatusPanel;
begin
  Result := Panels[Index] as TJVCSStatusPanel;
end;

procedure TJVCSStatusBar.Loaded;
begin
  inherited Loaded;
  FDefaultHint := Hint;
  UpdateGauge;
end;

function TJVCSStatusBar.PanelRect(Index: Integer): TRect;
var
  I, X: Integer;
begin
  X := 0;
  for I := 0 to Index - 1 do
    Inc(X, Panels[I].Width);
  Result := Rect(X, 2, X + Panels[Index].Width, ClientHeight);
  if (Index = Panels.Count - 1) or (Result.Right > ClientWidth) then
    Result.Right := ClientWidth;
  if HandleAllocated then
    SendMessage(Handle, SB_GETRECT, Index, LPARAM(@Result));
end;

function TJVCSStatusBar.PanelAt(X: Integer): Integer;
var
  I, Right: Integer;
begin
  Result := -1;
  if SimplePanel then
    Exit;
  Right := 0;
  for I := 0 to Panels.Count - 1 do
  begin
    Inc(Right, Panels[I].Width);
    if (X < Right) or (I = Panels.Count - 1) then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

procedure TJVCSStatusBar.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Idx: Integer;
begin
  inherited MouseUp(Button, Shift, X, Y);
  if Button = mbLeft then
  begin
    Idx := PanelAt(X);
    if (Idx >= 0) and PanelsEx[Idx].Enabled and Assigned(PanelsEx[Idx].OnClick) then
      PanelsEx[Idx].OnClick(PanelsEx[Idx]);
  end;
end;

procedure TJVCSStatusBar.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  Idx: Integer;
  NewHint: string;
begin
  inherited MouseMove(Shift, X, Y);
  Idx := PanelAt(X);
  if (Idx >= 0) and (PanelsEx[Idx].Hint <> '') then
    NewHint := PanelsEx[Idx].Hint
  else
    NewHint := FDefaultHint;
  if NewHint <> Hint then
  begin
    Hint := NewHint;
    Application.CancelHint;
  end;
end;

procedure TJVCSStatusBar.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  Hint := FDefaultHint;
end;

procedure TJVCSStatusBar.Resize;
begin
  inherited Resize;
  UpdateGauge;
end;

procedure TJVCSStatusBar.DrawPanel(Panel: TStatusPanel; const Rect: TRect);
begin
  if (Panel is TJVCSStatusPanel) and Assigned(TJVCSStatusPanel(Panel).OnDrawPanel) then
    TJVCSStatusPanel(Panel).OnDrawPanel(Self, TJVCSStatusPanel(Panel), Rect)
  else
    inherited DrawPanel(Panel, Rect);
end;

procedure TJVCSStatusBar.UpdateGauge;
var
  I, Idx: Integer;
  R: TRect;
  Attrs: TJVCSGaugeAttrs;
begin
  if csLoading in ComponentState then
    Exit;
  Idx := -1;
  for I := 0 to Panels.Count - 1 do
    if (Panels[I] is TJVCSStatusPanel) and (PanelsEx[I].PanelType = sptGauge) then
    begin
      Idx := I;
      Break;
    end;
  if Idx < 0 then
  begin
    if Assigned(FGauge) then
      FGauge.Visible := False;
    FGaugePanel := -1;
    Exit;
  end;
  if not Assigned(FGauge) then
  begin
    FGauge := TProgressBar.Create(Self);
    FGauge.Parent := Self;
    FGauge.Min := 0;
    FGauge.Max := 100;
  end;
  FGaugePanel := Idx;
  Attrs := PanelsEx[Idx].GaugeAttrs;
  R := PanelRect(Idx);
  InflateRect(R, -1, -1);
  FGauge.SetBounds(R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top);
  if Attrs.Style = gsPercent then
  begin
    FGauge.Style := pbstNormal;
    FGauge.Position := Attrs.Position;
  end
  else
  begin
    FGauge.Style := pbstMarquee;
    FGauge.MarqueeInterval := 30;
  end;
  FGauge.Visible := True;
  FGauge.Update;
end;

end.
