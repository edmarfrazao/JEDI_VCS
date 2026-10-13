(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSListView.pas

JEDI VCS 2.5 Beta 2026 (port Delphi 13): TJVCSListView, substituto nativo da
TdfsEnhListView 3.72 (DFS), escrito do zero sobre o TListView da VCL. Nao contem
codigo da DFS. Reproduz so a parte da API usada pelo cliente:
  - propriedades de DFM: AutoColumnSort, AutoSortAscending, ShowSortArrows,
    NoColumnResize, Style (lvOwnerDrawFixed), ReadOnly;
  - eventos com a assinatura da DFS: OnSortItems (TSortAs), OnDrawItem,
    OnDrawSubItem, OnDrawHeader (os handlers dos forms nao mudam);
  - metodos: BeginUpdate/EndUpdate, Resort, AutoResort, CurrentSortAscending,
    LastColumnClicked.
O desenho usa o custom draw da VCL: os handlers mudam a fonte/cor do Canvas e
deixam DefaultDrawing = True (nenhum handler do cliente desenha sozinho).
-----------------------------------------------------------------------------*)

unit JVCSListView;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.CommCtrl, System.SysUtils,
  System.Classes, Vcl.Controls, Vcl.Graphics, Vcl.ComCtrls;

type
  TSortAs = (saNone, saString, saNumeric, saDateTime);
  TAutoColumnSort = (acsNoSort, acsSort, acsSortToggle);
  TJVCSLVStyle = (lvStandard, lvOwnerDrawFixed);

  TJVCSLVSortItemsEvent = procedure(Sender: TObject; Item1, Item2: TListItem;
    SortColumn: Integer; var SortAs: TSortAs; var CompResult: Integer) of object;
  TJVCSLVDrawItemEvent = procedure(Control: TWinControl; var ACanvas: TCanvas;
    Index: Integer; ARect: TRect; State: TOwnerDrawState;
    var DefaultDrawing, FullRowSelect: Boolean) of object;
  TJVCSLVDrawSubItemEvent = procedure(Control: TWinControl; var ACanvas: TCanvas;
    Index, SubItem: Integer; ARect: TRect; State: TOwnerDrawState;
    var DefaultDrawing: Boolean) of object;
  TJVCSLVDrawHeaderEvent = procedure(Control: TWinControl; var ACanvas: TCanvas;
    Index: Integer; var ARect: TRect; Selected: Boolean;
    var DefaultDrawing: Boolean) of object;

  TJVCSListView = class(TListView)
  private
    FAutoColumnSort: TAutoColumnSort;
    FAutoSortAscending: Boolean;
    FAutoResort: Boolean;
    FShowSortArrows: Boolean;
    FNoColumnResize: Boolean;
    FStyle: TJVCSLVStyle;
    FLastColumnClicked: Integer;
    FCurrentSortAscending: Boolean;
    FOnSortItems: TJVCSLVSortItemsEvent;
    FOnDrawItem: TJVCSLVDrawItemEvent;
    FOnDrawSubItem: TJVCSLVDrawSubItemEvent;
    FOnDrawHeader: TJVCSLVDrawHeaderEvent;
    procedure SetShowSortArrows(const Value: Boolean);
    function OwnerDrawActive: Boolean;
    procedure CallDrawItem(Item: TListItem; State: TCustomDrawState);
    procedure WMNotify(var Message: TWMNotify); message WM_NOTIFY;
  protected
    procedure ColClick(Column: TListColumn); override;
    procedure CreateWnd; override;
    function IsCustomDrawn(Target: TCustomDrawTarget; Stage: TCustomDrawStage): Boolean; override;
    function CustomDrawItem(Item: TListItem; State: TCustomDrawState;
      Stage: TCustomDrawStage): Boolean; override;
    function CustomDrawSubItem(Item: TListItem; SubItem: Integer;
      State: TCustomDrawState; Stage: TCustomDrawStage): Boolean; override;
    function DoCompare(Item1, Item2: TListItem): Integer; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure Resort;
    procedure UpdateSortArrows;
    property AutoResort: Boolean read FAutoResort write FAutoResort;
    property CurrentSortAscending: Boolean read FCurrentSortAscending write FCurrentSortAscending;
    property LastColumnClicked: Integer read FLastColumnClicked write FLastColumnClicked;
  published
    property AutoColumnSort: TAutoColumnSort read FAutoColumnSort write FAutoColumnSort default acsNoSort;
    property AutoSortAscending: Boolean read FAutoSortAscending write FAutoSortAscending default True;
    property ShowSortArrows: Boolean read FShowSortArrows write SetShowSortArrows default False;
    property NoColumnResize: Boolean read FNoColumnResize write FNoColumnResize default False;
    property Style: TJVCSLVStyle read FStyle write FStyle default lvStandard;
    property ReadOnly;
    // Eventos com a assinatura da TJVCSListView (escondem os do TListView)
    property OnSortItems: TJVCSLVSortItemsEvent read FOnSortItems write FOnSortItems;
    property OnDrawItem: TJVCSLVDrawItemEvent read FOnDrawItem write FOnDrawItem;
    property OnDrawSubItem: TJVCSLVDrawSubItemEvent read FOnDrawSubItem write FOnDrawSubItem;
    property OnDrawHeader: TJVCSLVDrawHeaderEvent read FOnDrawHeader write FOnDrawHeader;
  end;

implementation

function JVCSLVCompare(lParam1, lParam2, lParamSort: LPARAM): Integer; stdcall;
begin
  Result := TJVCSListView(lParamSort).DoCompare(TListItem(lParam1), TListItem(lParam2));
end;

{ TJVCSListView }

constructor TJVCSListView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAutoColumnSort := acsNoSort;
  FAutoSortAscending := True;
  FCurrentSortAscending := True;
  FAutoResort := True;
  FLastColumnClicked := -1;
  FStyle := lvStandard;
end;

procedure TJVCSListView.BeginUpdate;
begin
  Items.BeginUpdate;
end;

procedure TJVCSListView.EndUpdate;
begin
  Items.EndUpdate;
end;

procedure TJVCSListView.ColClick(Column: TListColumn);
begin
  if FAutoColumnSort <> acsNoSort then
  begin
    if (Column.Index = FLastColumnClicked) and (FAutoColumnSort = acsSortToggle) then
      FCurrentSortAscending := not FCurrentSortAscending
    else
    begin
      FLastColumnClicked := Column.Index;
      FCurrentSortAscending := FAutoSortAscending;
    end;
    Resort;
  end;
  inherited ColClick(Column);
end;

procedure TJVCSListView.CreateWnd;
begin
  inherited CreateWnd;
  UpdateSortArrows;
end;

function TJVCSListView.DoCompare(Item1, Item2: TListItem): Integer;
var
  SortAs: TSortAs;
  SortColumn: Integer;
  S1, S2: string;
  F1, F2: Double;
  D1, D2: TDateTime;
begin
  Result := 0;
  SortColumn := FLastColumnClicked - 1; // -1 = Caption, 0.. = SubItems
  SortAs := saNone;
  if Assigned(FOnSortItems) then
    FOnSortItems(Self, Item1, Item2, SortColumn, SortAs, Result)
  else
    SortAs := saString;
  if SortAs <> saNone then
  begin
    if SortColumn < 0 then
    begin
      S1 := Item1.Caption;
      S2 := Item2.Caption;
    end
    else
    begin
      if SortColumn < Item1.SubItems.Count then
        S1 := Item1.SubItems[SortColumn]
      else
        S1 := '';
      if SortColumn < Item2.SubItems.Count then
        S2 := Item2.SubItems[SortColumn]
      else
        S2 := '';
    end;
    case SortAs of
      saNumeric:
        begin
          F1 := StrToFloatDef(S1, 0);
          F2 := StrToFloatDef(S2, 0);
          if F1 < F2 then
            Result := -1
          else
          if F1 > F2 then
            Result := 1
          else
            Result := 0;
        end;
      saDateTime:
        begin
          D1 := StrToDateTimeDef(S1, 0);
          D2 := StrToDateTimeDef(S2, 0);
          if D1 < D2 then
            Result := -1
          else
          if D1 > D2 then
            Result := 1
          else
            Result := 0;
        end;
      else
        Result := AnsiCompareText(S1, S2);
    end;
  end;
  if not FCurrentSortAscending then
    Result := -Result;
end;

procedure TJVCSListView.Resort;
begin
  if FLastColumnClicked >= 0 then
  begin
    if HandleAllocated then
      CustomSort(@JVCSLVCompare, LPARAM(Self));
    UpdateSortArrows;
  end;
end;

procedure TJVCSListView.SetShowSortArrows(const Value: Boolean);
begin
  if FShowSortArrows <> Value then
  begin
    FShowSortArrows := Value;
    UpdateSortArrows;
  end;
end;

procedure TJVCSListView.UpdateSortArrows;
var
  HeaderHandle: HWND;
  I: Integer;
  HDItem: THDItem;
begin
  if not HandleAllocated or (ViewStyle <> vsReport) then
    Exit;
  HeaderHandle := ListView_GetHeader(Handle);
  if HeaderHandle = 0 then
    Exit;
  for I := 0 to Columns.Count - 1 do
  begin
    FillChar(HDItem, SizeOf(HDItem), 0);
    HDItem.Mask := HDI_FORMAT;
    if Header_GetItem(HeaderHandle, I, HDItem) then
    begin
      HDItem.fmt := HDItem.fmt and not (HDF_SORTUP or HDF_SORTDOWN);
      if FShowSortArrows and (I = FLastColumnClicked) then
      begin
        if FCurrentSortAscending then
          HDItem.fmt := HDItem.fmt or HDF_SORTUP
        else
          HDItem.fmt := HDItem.fmt or HDF_SORTDOWN;
      end;
      Header_SetItem(HeaderHandle, I, HDItem);
    end;
  end;
end;

procedure TJVCSListView.WMNotify(var Message: TWMNotify);
begin
  // NoColumnResize: impede arrastar a divisoria das colunas
  if FNoColumnResize and ((Message.NMHdr^.code = HDN_BEGINTRACKW) or
    (Message.NMHdr^.code = HDN_BEGINTRACKA) or
    (Message.NMHdr^.code = HDN_DIVIDERDBLCLICKW) or
    (Message.NMHdr^.code = HDN_DIVIDERDBLCLICKA)) then
  begin
    Message.Result := 1;
    Exit;
  end;
  inherited;
end;

function TJVCSListView.OwnerDrawActive: Boolean;
begin
  Result := (FStyle = lvOwnerDrawFixed) and
    (Assigned(FOnDrawItem) or Assigned(FOnDrawSubItem));
end;

function TJVCSListView.IsCustomDrawn(Target: TCustomDrawTarget;
  Stage: TCustomDrawStage): Boolean;
begin
  Result := inherited IsCustomDrawn(Target, Stage);
  if not Result and OwnerDrawActive and (Stage = cdPrePaint) and
    (Target in [dtItem, dtSubItem]) then
    Result := True;
end;

procedure TJVCSListView.CallDrawItem(Item: TListItem; State: TCustomDrawState);
var
  ACanvas: TCanvas;
  DefaultDrawing, FullRowSelect: Boolean;
  OwnerState: TOwnerDrawState;
begin
  if not Assigned(FOnDrawItem) then
    Exit;
  OwnerState := [];
  if cdsSelected in State then
    Include(OwnerState, odSelected);
  if cdsFocused in State then
    Include(OwnerState, odFocused);
  ACanvas := Canvas;
  DefaultDrawing := True;
  FullRowSelect := True;
  FOnDrawItem(Self, ACanvas, Item.Index, Item.DisplayRect(drBounds), OwnerState,
    DefaultDrawing, FullRowSelect);
end;

function TJVCSListView.CustomDrawItem(Item: TListItem; State: TCustomDrawState;
  Stage: TCustomDrawStage): Boolean;
begin
  Result := inherited CustomDrawItem(Item, State, Stage);
  if Result and OwnerDrawActive and (Stage = cdPrePaint) and Assigned(Item) then
  begin
    Canvas.Font.Assign(Font);
    CallDrawItem(Item, State);
  end;
end;

function TJVCSListView.CustomDrawSubItem(Item: TListItem; SubItem: Integer;
  State: TCustomDrawState; Stage: TCustomDrawStage): Boolean;
var
  ACanvas: TCanvas;
  DefaultDrawing: Boolean;
  OwnerState: TOwnerDrawState;
begin
  Result := inherited CustomDrawSubItem(Item, SubItem, State, Stage);
  if Result and OwnerDrawActive and (Stage = cdPrePaint) and Assigned(Item) then
  begin
    // a cor/fonte da linha vem do OnDrawItem; depois o da subcoluna
    Canvas.Font.Assign(Font);
    CallDrawItem(Item, State);
    if Assigned(FOnDrawSubItem) then
    begin
      OwnerState := [];
      if cdsSelected in State then
        Include(OwnerState, odSelected);
      ACanvas := Canvas;
      DefaultDrawing := True;
      FOnDrawSubItem(Self, ACanvas, Item.Index, SubItem, Item.DisplayRect(drBounds),
        OwnerState, DefaultDrawing);
    end;
  end;
end;

end.
