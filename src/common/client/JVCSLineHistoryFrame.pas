(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSLineHistoryFrame.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
ToDo
- extended search function (search for revision, date, user)
- since 2009/03/21 the revision summary does now show the short revision and user text
  Should it show the long revision and user text or both?
- VirtualTree for the comments?
- strings
-----------------------------------------------------------------------------

Unit history:

2006/04/01  USchuster - new unit
2006/04/14  USchuster - fixed color bars for short files
                      - the date format is now selectable
                      - added a search function
2006/04/16  USchuster - changes for revision comment
2006/05/01  USchuster - as of now the shell folder common appdata is used for revisioninfo files
2006/05/13  USchuster - fixed extremely slow color bar painting(was "broken" since 2006/04/14)
2006/05/28  USchuster - added highlighting support
2006/08/06  USchuster - added revision/user statistic treeview
2006/11/05  USchuster - changes for SynEdit 2.0.3
2006/11/06  USchuster - more changes for SynEdit 2.0.3(added missing search engine)
2006/11/29  USchuster - added date format "Age" and set SynEdit.ActiveLineColor
2006/12/03  USchuster - added color settings dialog and changed settings handling
2006/12/10  USchuster - added binary check and binary .dfm conversion
                      - added info label for statistic navigation buttons
                      - added percent column to statistic treeview
                      - made color bar clickable (changes the topline of the SynEdit)
                      - added icons for speedbuttons
2006/12/14  USchuster - fixed sorting of percent column
2007/08/15  USchuster - added new date format "Age2"
2007/10/28  USchuster - first changes for extented line information visualization
2007/11/14  USchuster - first changes for painting of successive lines with same revision, date or user
2007/11/21  USchuster - extented line information visualization is now almost finished
                      - the gutter paint method is now selectable
2007/11/22  USchuster - added some missing things in TJVCSLineHistoryFrm.SetSettings
                      - fix for BlockType bteCount in TGutterInfoPlugin.AfterPaintDefault
2007/11/25  USchuster - added member count as label
2007/12/11  USchuster - the first and the last revision is now selectable and also
                        the local file can be used
2008/03/31  USchuster - suppressed exception of FileGetOwnerName
2008/10/29  USchuster - moved TJVCSLineHistoryRevisionKind, TJVCSLineHistoryRevisionLink,
                        BuildLineHistoryInfo and EncodeFileName to JVCSLineHistoryUnit.pas
2008/11/02  USchuster - changes for TJVCSLineHistoryBuilder (was BuildLineHistoryInfo)
2008/11/06  USchuster - changes for modularized cached history information handling
2008/11/07  USchuster - changes for properties as cached history information storage
2009/01/01  USchuster - changes for D2009/UniSynEdit
2009/01/17  USchuster - changes for THybridStoragePreparedRevisionInfoProvider
2009/02/07  USchuster - removed horizontal scrollbar in comment memo to force word wrap
                      - extented line information: the comment memo shows now all revision
                        comments for the current line (newest first)
2009/03/21  USchuster - changes for alternative visible user names and option to suppress "0." in the revision str
2009/09/07  USchuster - changes for VisibleUserName in summary treeview
                      - minor fixes to update the view directly after changing the settings
2010/01/09  USchuster - minimized space for the top panel by moving the first and last revision combobox
2010/01/10  USchuster - added a warning when the local file is not up-to-date and preselection of the last
                        revision depending on the checkout state (Mantis #5083)
2010/01/24  THuber - directive P R O P E R T Y S T O R A G E  removed
2010/03/04  USchuster - minor tweak: refresh button is now disabled when filling comboboxes to avoid AV
                        when pressing it while filling the comboboxes
2010/10/31  USchuster - added hyperlinks for the revision text that can call a comparision with the
                        prior revision with the OnRevisionClick implementation
2011/01/15  USchuster - fixed several exceptions in successive paint mode, when
                        "From" revision was not the first revision
                      - changed font to Tahoma                        

-----------------------------------------------------------------------------*)

unit JVCSLineHistoryFrame;

{$I jedi.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  JVCSLineHistoryUnit, SynEdit, JVCSLineHistoryHighlighterUnit, Contnrs, StdCtrls, ExtCtrls,
  ComCtrls, Menus, Buttons, ImgList, ActnList, JclFileUtils, JclSysInfo,
  VirtualTrees, SynEditTypes, SynEditSearch, JVCSLineHistorySettingsDialog, JVCSClientFunctions,
  JVCSDialogs;

type
  TRevisionColor = class(TObject)
  private
    FDateColor: TColor;
    FRevisionColor: TColor;
    FLineHistoryRevision: TJVCSLineHistoryRevision;
    FUserColor: TColor;
  public
    constructor Create(ALineHistoryRevision: TJVCSLineHistoryRevision);
    property DateColor: TColor read FDateColor write FDateColor;
    property RevisionColor: TColor read FRevisionColor write FRevisionColor;
    property LineHistoryRevision: TJVCSLineHistoryRevision read FLineHistoryRevision;
    property UserColor: TColor read FUserColor write FUserColor;
  end;

  TGetRevisionColorEvent = function(ALineHistoryRevision: TJVCSLineHistoryRevision): TRevisionColor of object;
  TOnGetLineColorEvent = function(ALine: Integer; AColorIndex: Integer): TColor of object;
  TRevisionClickEvent = procedure(ASender: TObject; ARevisionIDStr: string) of object;

  TJVCSLineHistoryFrm = class(TFrame)
    Panel1: TPanel;
    PaintBox1: TPaintBox;
    PB1: TProgressBar;
    btnCancel: TButton;
    cbMember: TComboBox;
    Label2: TLabel;
    Panel2: TPanel;
    Label1: TLabel;
    cbShowUserText: TCheckBox;
    cbShowUserColor: TCheckBox;
    cbLineNumbers: TCheckBox;
    cbLineColorMode: TComboBox;
    cbShowRevisionColor: TCheckBox;
    cbShowDateColor: TCheckBox;
    cbShowRevisionColorBar: TCheckBox;
    cbShowDateColorBar: TCheckBox;
    cbShowRevisionText: TCheckBox;
    cbShowDateText: TCheckBox;
    cbShowUserColorBar: TCheckBox;
    SpeedButton1: TSpeedButton;
    cbDateFormat: TComboBox;
    Label3: TLabel;
    actlMain: TActionList;
    actSearch: TAction;
    actSearchNext: TAction;
    actSearchPrev: TAction;
    imglMain: TImageList;
    FindDialog1: TFindDialog;
    PopupMenu1: TPopupMenu;
    Find1: TMenuItem;
    Findnext1: TMenuItem;
    Findprevious1: TMenuItem;
    memComment: TMemo;
    SpeedButton2: TSpeedButton;
    splComment: TSplitter;
    cbxHighlighter: TComboBox;
    Label4: TLabel;
    pnlRight: TPanel;
    vstSummary: TVirtualStringTree;
    splCommentVst: TSplitter;
    SpeedButton3: TSpeedButton;
    Panel3: TPanel;
    spBtnPrevLine: TSpeedButton;
    spBtnNextLine: TSpeedButton;
    pnlSummary: TPanel;
    SpeedButton4: TSpeedButton;
    lbJumpLineInfo: TLabel;
    cbShowRevisionCountText: TCheckBox;
    cbShowRevisionCountColor: TCheckBox;
    cbShowRevisionCountColorBar: TCheckBox;
    cbShowFirstRevisionText: TCheckBox;
    cbShowFirstRevisionColor: TCheckBox;
    cbShowFirstRevisionColorBar: TCheckBox;
    cbPaintMethod: TComboBox;
    Label5: TLabel;
    Panel4: TPanel;
    lblMemberCount: TLabel;
    cbFirstRevision: TComboBox;
    cbLastRevision: TComboBox;
    cbSuppressRevisionTextZeroDot: TCheckBox;
    Label6: TLabel;
    Label7: TLabel;
    procedure cbLineColorModeChange(Sender: TObject);
    procedure cbLineNumbersClick(Sender: TObject);
    procedure cbShowRevisionColorBarClick(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure FrameResize(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure cbMemberChange(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure cbDateFormatChange(Sender: TObject);
    procedure actSearchExecute(Sender: TObject);
    procedure actSearchNextExecute(Sender: TObject);
    procedure actSearchPrevExecute(Sender: TObject);
    procedure FindDialog1Find(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure cbxHighlighterChange(Sender: TObject);
    procedure vstSummaryInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure vstSummaryInitChildren(Sender: TBaseVirtualTree;
      Node: PVirtualNode; var ChildCount: Cardinal);
    procedure vstSummaryGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure vstSummaryBeforeItemErase(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; ItemRect: TRect;
      var ItemColor: TColor; var EraseAction: TItemEraseAction);
    procedure vstSummaryCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure vstSummaryHeaderClick(Sender: TVTHeader;
      Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer);
    procedure vstSummaryFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure spBtnPrevLineClick(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure cbPaintMethodChange(Sender: TObject);
  private
    { Private declarations }
    FAbort: Boolean;
    FSynEdit: TSynEdit;
    FSynEditPlugin: TSynEditPlugin;
    FSynEditSearch: TSynEditSearch;
    FLineHistory: TJVCSLineHistory;
    FLineHistorySummary: TJVCSLineHistorySummary;
    FColorList: TStringList;
    FRevisionColorList: TObjectList;
    FCachedColorBar: TBitmap;
    FIsInBuildInfo: Boolean;
    FIsNewModule: Boolean;
    FModuleName: string;
    FSelectedExtension: string;
    FProvider: TJVCSCustomLineHistoryModuleProvider;
    FDateFormatList: TStringList;
    FSearchText: string;
    FPrepareRevisionInfoPath: string;
    FHighlighters: TJVCSLineHistoryHighlighters;
    FLastCommentHeight: Integer;
    FSettings: TJVCSLineHistorySettings;
    FOnSettingsChanged: TNotifyEvent;
    FInSetSettings: Boolean;
    FLastTopLine: Integer;
    FRevisionLinks: TObjectList;
    {$IFDEF LINEINFOEX}
    FMaxLineRevisionCount: Integer;
    FRevisionCountColorList: TList;
    {$ENDIF LINEINFOEX}
    FFirstRevisionIDStr: string;
    FLastHighlightedRevisionIDStr: string;
    FOnRevisionClick: TRevisionClickEvent;
    procedure DoSettingsChanged;
    function GetNextColor: TColor;
    function GetRevisionColor(ALineHistoryRevision: TJVCSLineHistoryRevision): TRevisionColor;
    function GetLineColor(ALine: Integer; AColorIndex: Integer): TColor;
    procedure HandleApplySettings(Sender: TObject);
    procedure HandleLineHistoryBuilderProgress(ASender: TObject; APosition, AMax: Integer; var AAbort: Boolean);
    procedure SynEditChange(Sender: TObject);
    procedure SynEditMouseLeave(Sender: TObject);
    procedure SynEditMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure SynEditOnClick(Sender: TObject);
    procedure SynEditStatusChange(Sender: TObject;
      Changes: TSynStatusChanges);
    procedure SynEditSpecialLineColors(Sender: TObject; Line: Integer;
      var Special: Boolean; var FG, BG: TColor);
    procedure PaintColorBar(ACanvas: TCanvas; ARect: TRect; ALinesCount,
      APenColor, ABackGroundColor: TColor; AOnGetLineColor: TOnGetLineColorEvent; AColorIndex: Integer);
    procedure UpdateColorBars;
    procedure UpdateRevisionInfo;
    function GetModuleName(AIndex: Integer): string;
    procedure SetModuleName(AIndex: Integer; AValue: string);
    procedure SetButtonCaption;
    procedure SetExtensionControls;
    procedure FillDateFormatComboBox;
    procedure FillExtensionsList(ASelectedExtension: string);
    procedure FillHighlighterList;
    procedure FillRevisionLists(const AModulename, ASelectedExtension: string);
    procedure Search(ABackwards: Boolean);
    procedure SetSettings(AValue: TJVCSLineHistorySettings);
    procedure SetSummaryNextLineButtonState;
    procedure UpdateAll;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ShowLineHistory;
    procedure Enable;
    property Provider: TJVCSCustomLineHistoryModuleProvider read FProvider write FProvider;
    property PrepareRevisionInfoPath: string read FPrepareRevisionInfoPath write FPrepareRevisionInfoPath;
    property ModuleName: string index 1 read FModuleName write SetModuleName;
    property SelectedExtension: string index 2 read FSelectedExtension write SetModuleName;
    property Settings: TJVCSLineHistorySettings read FSettings write SetSettings;
    property OnRevisionClick: TRevisionClickEvent read FOnRevisionClick write FOnRevisionClick;
    property OnSettingsChanged: TNotifyEvent read FOnSettingsChanged write FOnSettingsChanged;
  end;

implementation

uses
  JVCSLineHistoryPropertyStorage;

{$R *.dfm}

constructor TRevisionColor.Create(ALineHistoryRevision: TJVCSLineHistoryRevision);
begin
  inherited Create;
  FDateColor := clNone;
  FRevisionColor := clNone;
  FLineHistoryRevision := ALineHistoryRevision;
  FUserColor := clNone;
end;

type
  TRevisionRectangle = class(TObject)
  private
    FRect: TRect;
    FRevisionIDStr: string;
  public
    constructor Create(ARect: TRect; ARevisionIDStr: string);
    property Rect: TRect read FRect;
    property RevisionIDStr: string read FRevisionIDStr;
  end;

  TRevisionRectangleList = class(TObject)
  private
    FItems: TObjectList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(ARect: TRect; ARevisionIDStr: string);
    procedure Clear(AY: Integer = -1);
    function Find(AX, AY: Integer; var ATopY: Integer; var ARevisionIDStr: string): Boolean;
  end;

  TGutterInfoPlugin = class(TSynEditPlugin)
  protected
    FSynEdit: TCustomSynEdit;
    FLineInformationList: TStrings;
    {$IFDEF LINEINFOEX}
    FLineInformationListEx: TList;
    {$ENDIF LINEINFOEX}
    FLineX: Integer;
    FRevisionX: Integer;
    FRevisionRectX1: Integer;
    FRevisionRectX2: Integer;
    {$IFDEF LINEINFOEX}
    FRevisionCountX: Integer;
    FRevisionCountRectX1: Integer;
    FRevisionCountRectX2: Integer;
    FFirstRevisionX: Integer;
    FFirstRevisionRectX1: Integer;
    FFirstRevisionRectX2: Integer;
    {$ENDIF LINEINFOEX}
    FDateX: Integer;
    FDateRectX1: Integer;
    FDateRectX2: Integer;
    FUserX: Integer;
    FUserRectX1: Integer;
    FUserRectX2: Integer;
    FFontColor: TColor;
    FLineHistory: TJVCSLineHistory;
    FSettings: TJVCSLineHistorySettings;
    {$IFDEF LINEINFOEX}
    FOnGetLineColor: TOnGetLineColorEvent;
    {$ENDIF LINEINFOEX}    
    FOnGetRevisionColor: TGetRevisionColorEvent;
    FBitmap: TBitmap;
    FLastBitmapTopLine, FLastBitmapLineCount: Integer;
    FRevisionRectangles: TRevisionRectangleList;
    FHighlightY: Integer;
    FLastHighlightY: Integer;
    procedure AfterPaintDefault(ACanvas: TCanvas; const AClip: TRect;
      FirstLine, LastLine: Integer);
    procedure AfterPaintSuccessive(ACanvas: TCanvas; const AClip: TRect;
      FirstLine, LastLine: Integer);
    procedure AfterPaint(ACanvas: TCanvas; const AClip: TRect;
      FirstLine, LastLine: Integer); override;
    {$IFDEF LINEINFOEX}
    function DoGetLineColor(ALine: Integer; AColorIndex: Integer): TColor;
    {$ENDIF LINEINFOEX}
    function DoGetRevisionColor(ALineHistoryRevision: TJVCSLineHistoryRevision): TRevisionColor;
    procedure LinesInserted(FirstLine, Count: Integer); override;
    procedure LinesDeleted(FirstLine, Count: Integer); override;
    procedure SetLineInformationList(AValue: TStrings);
    {$IFDEF LINEINFOEX}
    procedure SetLineInformationListEx(AValue: TList);
    {$ENDIF LINEINFOEX}
    procedure SetSettings(AValue: TJVCSLineHistorySettings);
  public
    constructor Create(ASynEdit: TCustomSynEdit);
    destructor Destroy; override;
    function FindRevisionRectangle(AX, AY: Integer; var ATopY: Integer; var ARevisionIDStr: string): Boolean;
    procedure UpdateGutterWidth;
    property LineInformationList: TStrings read FLineInformationList write SetLineInformationList;
    {$IFDEF LINEINFOEX}
    property LineInformationListEx: TList read FLineInformationListEx write SetLineInformationListEx;
    {$ENDIF LINEINFOEX}
    property FontColor: TColor read FFontColor write FFontColor;
    property LineHistory: TJVCSLineHistory read FLineHistory write FLineHistory;
    property Settings: TJVCSLineHistorySettings read FSettings write SetSettings;
    {$IFDEF LINEINFOEX}
    property OnGetLineColor: TOnGetLineColorEvent read FOnGetLineColor write FOnGetLineColor;
    {$ENDIF LINEINFOEX}
    property OnGetRevisionColor: TGetRevisionColorEvent read FOnGetRevisionColor write FOnGetRevisionColor;
  end;

{ TRevisionRectangle }

constructor TRevisionRectangle.Create(ARect: TRect; ARevisionIDStr: string);
begin
  FRect := ARect;
  FRevisionIDStr := ARevisionIDStr;
end;

{ TRevisionRectangleList }

constructor TRevisionRectangleList.Create;
begin
  inherited Create;
  FItems := TObjectList.Create;
end;

destructor TRevisionRectangleList.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TRevisionRectangleList.Add(ARect: TRect; ARevisionIDStr: string);
begin
  FItems.Add(TRevisionRectangle.Create(ARect, ARevisionIDStr));
end;

procedure TRevisionRectangleList.Clear(AY: Integer = -1);
var
  I: Integer;
begin
  if AY = -1 then
    FItems.Clear
  else
  for I := FItems.Count - 1 downto 0 do
    if TRevisionRectangle(FItems[I]).Rect.Top <= AY then
      FItems.Delete(I);
end;

function TRevisionRectangleList.Find(AX, AY: Integer; var ATopY: Integer; var ARevisionIDStr: string): Boolean;
var
  I: Integer;
  Rect: TRect;
begin
  Result := False;
  ATopY := -1;
  ARevisionIDStr := '';
  for I := 0 to FItems.Count - 1 do
  begin
    Rect := TRevisionRectangle(FItems[I]).Rect;
    if (Rect.Left <= AX) and (Rect.Right >= AX) and (Rect.Top <= AY) and (Rect.Bottom >= AY) then
    begin
      ATopY := Rect.Top;
      ARevisionIDStr := TRevisionRectangle(FItems[I]).RevisionIDStr;
      Result := True;
      Break;
    end;
  end;
end;

constructor TGutterInfoPlugin.Create(ASynEdit: TCustomSynEdit);
begin
  inherited Create(ASynEdit);
  FSynEdit := ASynEdit;
  FLineInformationList := nil;
  {$IFDEF LINEINFOEX}
  FLineInformationListEx := nil;
  {$ENDIF LINEINFOEX}
  FLineX := -1;
  FRevisionX := -1;
  FRevisionRectX1 := -1;
  FRevisionRectX2 := -1;
  {$IFDEF LINEINFOEX}
  FRevisionCountX := -1;
  FRevisionCountRectX1 := -1;
  FRevisionCountRectX2 := -1;
  FFirstRevisionX := -1;
  FFirstRevisionRectX1 := -1;
  FFirstRevisionRectX2 := -1;
  {$ENDIF LINEINFOEX}
  FDateX := -1;
  FDateRectX1 := -1;
  FDateRectX2 := -1;
  FUserX := -1;
  FUserRectX1 := -1;
  FUserRectX2 := -1;
  FFontColor := clBlack;
  FLineHistory := nil;
  FSettings := TJVCSLineHistorySettings.Create;
  {$IFDEF LINEINFOEX}
  FOnGetLineColor := nil;
  {$ENDIF LINEINFOEX}
  FOnGetRevisionColor := nil;
  FBitmap := TBitmap.Create;
  FLastBitmapTopLine := -1;
  FLastBitmapLineCount := -1;
  FRevisionRectangles := TRevisionRectangleList.Create;
  FHighlightY := -1;
  FLastHighlightY := -1;
end;

destructor TGutterInfoPlugin.Destroy;
begin
  FRevisionRectangles.Free;
  FBitmap.Free;
  FSettings.Free;
  inherited Destroy;
end;

procedure TGutterInfoPlugin.AfterPaintDefault(ACanvas: TCanvas; const AClip: TRect;
  FirstLine, LastLine: Integer);
var
  LH, Y: Integer;
  LineInformation: TJVCSLineHistoryRevision;
  {$IFDEF LINEINFOEX}
  LineInformationEx: TJVCSLineHistoryLineInfo;
  RevisionColor2: TRevisionColor;
  {$ENDIF LINEINFOEX}
  RealLine: Integer;
  RevisionColor: TRevisionColor;
  RevisionRect: TRect;
  RevisionTextExtent: TSize;
  OldFontColor: TColor;
  OldFontStyle: TFontStyles;
  RevisionIDStr: string;
begin
  if Assigned(FLineInformationList) then
  begin
    LH := FSynEdit.LineHeight;
    Y := LH * (FirstLine - FSynEdit.TopLine);
    FRevisionRectangles.Clear(LH * (LastLine - FSynEdit.TopLine));
    while FirstLine <= LastLine do
    begin
      RealLine := FirstLine - 1;

      if (FLineInformationList.Count > RealLine) and Assigned(FLineInformationList.Objects[RealLine]) then
        RevisionColor := DoGetRevisionColor(TJVCSLineHistoryRevision(FLineInformationList.Objects[RealLine]))
      else
        RevisionColor := DoGetRevisionColor(nil);

      if Assigned(RevisionColor) then
      begin
        ACanvas.Pen.Style := psClear;
        if FRevisionRectX1 <> -1 then
        begin
          ACanvas.Brush.Color := RevisionColor.RevisionColor;
          ACanvas.Rectangle(FRevisionRectX1, Y, FRevisionRectX2, Y + LH + 1);
        end;
        {$IFDEF LINEINFOEX}
        if FRevisionCountRectX1 <> -1 then
        begin
          ACanvas.Brush.Color := DoGetLineColor(RealLine, 4);
          ACanvas.Rectangle(FRevisionCountRectX1, Y, FRevisionCountRectX2, Y + LH + 1);
        end;
        if FFirstRevisionRectX1 <> -1 then
        begin
          if (FLineInformationListEx.Count > RealLine) and Assigned(FLineInformationListEx[RealLine]) and
            (TJVCSLineHistoryLineInfo(FLineInformationListEx[RealLine]).Count > 0) then
            RevisionColor2 := DoGetRevisionColor(TJVCSLineHistoryLineInfo(FLineInformationListEx[RealLine]).Revision[0])
          else
            RevisionColor2 := DoGetRevisionColor(nil);
          if Assigned(RevisionColor2) then
          begin
            ACanvas.Brush.Color := RevisionColor2.RevisionColor;
            ACanvas.Rectangle(FFirstRevisionRectX1, Y, FFirstRevisionRectX2, Y + LH + 1);
          end;
        end;
        {$ENDIF LINEINFOEX}
        if FDateRectX1 <> -1 then
        begin
          ACanvas.Brush.Color := RevisionColor.DateColor;
          ACanvas.Rectangle(FDateRectX1, Y, FDateRectX2, Y + LH + 1);
        end;
        if FUserRectX1 <> -1 then
        begin
          ACanvas.Brush.Color := RevisionColor.UserColor;
          ACanvas.Rectangle(FUserRectX1, Y, FUserRectX2, Y + LH + 1);
        end;
      end;

      ACanvas.Brush.Style := bsClear;
      ACanvas.Font.Assign(FSynEdit.Font);
      ACanvas.Font.Color := FFontColor;
      if (FLineInformationList.Count > RealLine) and Assigned(FLineInformationList.Objects[RealLine]) then
      begin
        LineInformation := TJVCSLineHistoryRevision(FLineInformationList.Objects[RealLine]);
        {$IFDEF LINEINFOEX}
        LineInformationEx := nil;
        if (FLineInformationListEx.Count > RealLine) and Assigned(FLineInformationListEx[RealLine]) then
          LineInformationEx := TJVCSLineHistoryLineInfo(FLineInformationListEx[RealLine]);
        {$ENDIF LINEINFOEX}
        if FLineX <> -1 then
        begin
          if {(FirstLine = FSynEdit.TopLine) or }(FirstLine mod 10 = 0) then
            ACanvas.TextOut(FLineX, Y, IntToStr(FirstLine));
        end;
        if FRevisionX <> -1 then
        begin
          OldFontColor := ACanvas.Font.Color;
          OldFontStyle := ACanvas.Font.Style;
          try
            if Y = FHighlightY then
            begin
              ACanvas.Font.Color := clHighlight;
              ACanvas.Font.Style := [fsUnderline];
            end;
            ACanvas.TextOut(FRevisionX, Y, LineInformation.RevisionStr);
            RevisionTextExtent := ACanvas.TextExtent(LineInformation.RevisionStr);
            RevisionRect.Left := FRevisionX;
            RevisionRect.Right := RevisionRect.Left + RevisionTextExtent.cx;
            RevisionRect.Top := Y;
            RevisionRect.Bottom := RevisionRect.Top + RevisionTextExtent.cy;
            if LineInformation.RevisionID > 0 then
              RevisionIDStr := IntToStr(LineInformation.RevisionID)
            else
              RevisionIDStr := LineInformation.OrgRevisionStr;
            FRevisionRectangles.Add(RevisionRect, RevisionIDStr);
          finally
            ACanvas.Font.Color := OldFontColor;
            ACanvas.Font.Style := OldFontStyle;
          end;
        end;
        {$IFDEF LINEINFOEX}
        if (FRevisionCountX <> -1) and Assigned(LineInformationEx) then
          ACanvas.TextOut(FRevisionCountX, Y, IntToStr(LineInformationEx.Count));
        if (FFirstRevisionX <> -1) and Assigned(LineInformationEx) and (LineInformationEx.Count > 0) and
          Assigned(LineInformationEx.Revision[0]) then
          ACanvas.TextOut(FFirstRevisionX, Y, LineInformationEx.Revision[0].RevisionStr);
        {$ENDIF LINEINFOEX}
        if FUserX <> -1 then
          ACanvas.TextOut(FUserX, Y, LineInformation.UserStr);
        if FDateX <> -1 then
          ACanvas.TextOut(FDateX, Y, LineInformation.DateStr);
      end;
      Inc(FirstLine);
      Inc(Y, LH);
    end;
  end;
end;

procedure TGutterInfoPlugin.AfterPaintSuccessive(ACanvas: TCanvas; const AClip: TRect;
  FirstLine, LastLine: Integer);

  function IsDifferent(ALine: Integer): Boolean;
  var
    LHR1, LHR2: TJVCSLineHistoryRevision;
    {$IFDEF LINEINFOEX}
    LHI1, LHI2: TJVCSLineHistoryLineInfo;
    {$ENDIF LINEINFOEX}
    RealLine: Integer;
  begin
    if FSettings.PaintMethod = 2 then
    begin
      Result := False;
      if ALine = FSynEdit.TopLine then
        Result := True
      else
      begin
        RealLine := ALine - 2;
        if RealLine < FLineInformationList.Count then
          LHR1 := TJVCSLineHistoryRevision(FLineInformationList.Objects[RealLine])
        else
          LHR1 := nil;
        RealLine := ALine - 1;
        if RealLine < FLineInformationList.Count then
          LHR2 := TJVCSLineHistoryRevision(FLineInformationList.Objects[RealLine])
        else
          LHR2 := nil;
        if (Assigned(LHR1) and not Assigned(LHR2)) or (not Assigned(LHR1) and Assigned(LHR2)) then
          Result := True
        else
        if (not Assigned(LHR1)) and (not Assigned(LHR2)) then
          Result := False
        else
        if FSettings.ShowRevisionInfoText and (LHR1.RevisionID <> LHR2.RevisionID) then
          Result := True
        else
        if FSettings.ShowDateInfoText and (LHR1.DateStr <> LHR2.DateStr) then
          Result := True
        else
        if FSettings.ShowUserInfoText and (LHR1.UserStr <> LHR2.UserStr) then
          Result := True;
        {$IFDEF LINEINFOEX}
        RealLine := ALine - 2;
        if RealLine < FLineInformationListEx.Count then
          LHI1 := TJVCSLineHistoryLineInfo(FLineInformationListEx[RealLine])
        else
          LHI1 := nil;
        RealLine := ALine - 1;
        if RealLine < FLineInformationListEx.Count then
          LHI2 := TJVCSLineHistoryLineInfo(FLineInformationListEx[RealLine])
        else
          LHI2 := nil;
        if (Assigned(LHI1) and not Assigned(LHI2)) or (not Assigned(LHI1) and Assigned(LHI2)) then
          Result := True
        else
        if (not Assigned(LHI1)) and (not Assigned(LHI2)) then
          Result := False
        else        
        if FSettings.ShowRevisionCountInfoText and (LHI1.Count <> LHI2.Count) then
          Result := True
        else
        if FSettings.ShowFirstRevisionInfoText and (LHI1.Count > 0) and (LHI2.Count > 0) and (LHI1.Revision[0] <> LHI2.Revision[0]) then
          Result := True;
        {$ENDIF LINEINFOEX}
      end;
    end
    else
      Result := False;
  end;

type
  TBlockType = (btRevision, btDate, btUser);

  procedure PaintBlocks(ADestCanvas: TCanvas; ABlockType: TBlockType; ARectX1, ARectX2, ATextX: Integer);

    function IsSameInfo(AInfo1, AInfo2: TJVCSLineHistoryRevision): Boolean;
    begin
      Result := AInfo1 = AInfo2;
      if ABlockType <> btRevision then
      begin
        if Assigned(AInfo1) and Assigned(AInfo2) then
        begin
          case ABlockType of
            btDate: Result := AInfo1.DateStr = AInfo2.DateStr;
            btUser: Result := AInfo1.UserStr = AInfo2.UserStr;
            else
              Result := False;
          end;
        end
        else
          Result := False;
      end;
    end;

    function GetColor(AInfo: TJVCSLineHistoryRevision): TColor;
    var
      RevisionColor: TRevisionColor;
    begin
      RevisionColor := DoGetRevisionColor(AInfo);
      case ABlockType of
        btRevision: Result := RevisionColor.RevisionColor;
        btDate: Result := RevisionColor.DateColor;
        btUser: Result := RevisionColor.UserColor;
        else
          Result := clBtnFace;
      end;
    end;

  var
    LastBlockRevision: TJVCSLineHistoryRevision;
    LastBlockStartY, LastBlockEndY, LH: Integer;

    procedure PaintLastBlock;
    var
      S, RevisionIDStr: string;
      RevisionRect: TRect;
      RevisionTextExtent: TSize;
      OldFontColor: TColor;
      OldFontStyle: TFontStyles;
    begin
      if (LastBlockEndY > -1) and Assigned(LastBlockRevision) then
      begin
        FBitmap.Canvas.Brush.Style := bsSolid;
        FBitmap.Canvas.Brush.Color := GetColor(LastBlockRevision);
        FBitmap.Canvas.Rectangle(ARectX1, LastBlockStartY, ARectX2, LastBlockEndY);
        if ATextX <> -1 then
        begin
          FBitmap.Canvas.Brush.Style := bsClear;
          case ABlockType of
            btRevision: S := LastBlockRevision.RevisionStr;
            btDate: S := LastBlockRevision.DateStr;
            btUser: S := LastBlockRevision.UserStr;
            else
              S := '';
          end;
          if ABlockType = btRevision then
          begin
            OldFontColor := FBitmap.Canvas.Font.Color;
            OldFontStyle := FBitmap.Canvas.Font.Style;
            try
              if (LastBlockStartY + LastBlockEndY - LH) shr 1 = FHighlightY then
              begin
                FBitmap.Canvas.Font.Color := clHighlight;
                FBitmap.Canvas.Font.Style := [fsUnderline];
              end;
              FBitmap.Canvas.TextOut(ATextX, (LastBlockStartY + LastBlockEndY - LH) shr 1, S);
              RevisionTextExtent := FBitmap.Canvas.TextExtent(S);
              RevisionRect.Left := ATextX;
              RevisionRect.Right := RevisionRect.Left + RevisionTextExtent.cx;
              RevisionRect.Top := (LastBlockStartY + LastBlockEndY - LH) shr 1;
              RevisionRect.Bottom := RevisionRect.Top + RevisionTextExtent.cy;
              if LastBlockRevision.RevisionID > 0 then
                RevisionIDStr := IntToStr(LastBlockRevision.RevisionID)
              else
                RevisionIDStr := LastBlockRevision.OrgRevisionStr;
              FRevisionRectangles.Add(RevisionRect, RevisionIDStr);
            finally
              FBitmap.Canvas.Font.Color := OldFontColor;
              FBitmap.Canvas.Font.Style := OldFontStyle;
            end;
          end
          else
            FBitmap.Canvas.TextOut(ATextX, (LastBlockStartY + LastBlockEndY - LH) shr 1, S);
        end;
      end;
    end;

  var
    Revision: TJVCSLineHistoryRevision;
    PaintLine, RealLine, Y: Integer;
  begin
    if (ARectX1 <> -1) or (ATextX <> -1) then
    begin
      LH := FSynEdit.LineHeight;
      LastBlockStartY := -1;
      LastBlockEndY := -1;
      LastBlockRevision := nil;
      for PaintLine := FSynEdit.TopLine to (FSynEdit.TopLine + FSynEdit.LinesInWindow - 1) do
      begin
        RealLine := PaintLine - 1;
        Y := LH * (PaintLine - FSynEdit.TopLine);
        if RealLine < FLineInformationList.Count then
        begin
          Revision := TJVCSLineHistoryRevision(FLineInformationList.Objects[RealLine]);
          if not (IsSameInfo(LastBlockRevision, Revision) and not IsDifferent(PaintLine)) then
          begin
            PaintLastBlock;
            LastBlockStartY := Y;
            LastBlockRevision := Revision;
          end;
          LastBlockEndY := Y + LH + 1;
        end;
      end;
      PaintLastBlock;
    end;
  end;

{$IFDEF LINEINFOEX}  
type
  TBlockTypeEx = (bteCount, bteFirstRevision);

  procedure PaintBlocksEx(ADestCanvas: TCanvas; ABlockType: TBlockTypeEx; ARectX1, ARectX2, ATextX: Integer);

    function IsSameInfo(AInfo1, AInfo2: TJVCSLineHistoryLineInfo): Boolean;
    begin
      if Assigned(AInfo1) and Assigned(AInfo2) then
      begin
        case ABlockType of
          bteCount: Result := AInfo1.Count = AInfo2.Count;
          bteFirstRevision: Result := AInfo1.Revision[0] = AInfo2.Revision[0];
          else
            Result := False;
        end;
      end
      else
        Result := False;
    end;

    function GetColor(AStartLine: Integer; AInfo: TJVCSLineHistoryLineInfo): TColor;
    var
      RevisionColor: TRevisionColor;
    begin
      case ABlockType of
        bteCount: Result := DoGetLineColor(AStartLine, 4);
        bteFirstRevision:
          begin
            RevisionColor := DoGetRevisionColor(AInfo.Revision[0]);
            Result := RevisionColor.RevisionColor;
          end;
        else
          Result := clBtnFace;
      end;
    end;

  var
    LastBlockInfo: TJVCSLineHistoryLineInfo;
    LastBlockStartRealLine: Integer;
    LastBlockStartY, LastBlockEndY, LH: Integer;

    procedure PaintLastBlock;
    var
      S: string;
    begin
      if (LastBlockEndY > -1) and Assigned(LastBlockInfo) then
      begin
        FBitmap.Canvas.Brush.Style := bsSolid;
        FBitmap.Canvas.Brush.Color := GetColor(LastBlockStartRealLine, LastBlockInfo);
        FBitmap.Canvas.Rectangle(ARectX1, LastBlockStartY, ARectX2, LastBlockEndY);
        if ATextX <> -1 then
        begin
          FBitmap.Canvas.Brush.Style := bsClear;
          case ABlockType of
            bteCount: S := IntToStr(LastBlockInfo.Count);
            bteFirstRevision: if Assigned(LastBlockInfo.Revision[0]) then
                                S := LastBlockInfo.Revision[0].RevisionStr
                              else
                                S := '';
            else
              S := '';
          end;
          if S <> '' then
            FBitmap.Canvas.TextOut(ATextX, (LastBlockStartY + LastBlockEndY - LH) shr 1, S);
        end;
      end;
    end;

  var
    LineInfo: TJVCSLineHistoryLineInfo;
    PaintLine, RealLine, Y: Integer;
  begin
    if (ARectX1 <> -1) or (ATextX <> -1) then
    begin
      LH := FSynEdit.LineHeight;
      LastBlockStartRealLine := -1;
      LastBlockStartY := -1;
      LastBlockEndY := -1;
      LastBlockInfo := nil;
      for PaintLine := FSynEdit.TopLine to (FSynEdit.TopLine + FSynEdit.LinesInWindow - 1) do
      begin
        RealLine := PaintLine - 1;
        Y := LH * (PaintLine - FSynEdit.TopLine);
        if RealLine < FLineInformationListEx.Count then
        begin
          LineInfo := TJVCSLineHistoryLineInfo(FLineInformationListEx[RealLine]);
          if not (IsSameInfo(LastBlockInfo, LineInfo) and not IsDifferent(PaintLine)) then
          begin
            PaintLastBlock;
            LastBlockStartY := Y;
            LastBlockStartRealLine := RealLine;
            LastBlockInfo := LineInfo;
          end;
          LastBlockEndY := Y + LH + 1;
        end;
      end;
      PaintLastBlock;
    end;
  end;
{$ENDIF LINEINFOEX}

var
  LH, Y: Integer;
  PaintLine: Integer;
  SourceRect: TRect;
  CurrentGutterWidth: Integer;
begin
  LH := FSynEdit.LineHeight;
  {$IFDEF UNISYNEDIT}
  CurrentGutterWidth := FSynEdit.Gutter.Width;
  {$ELSE}
  CurrentGutterWidth := FSynEdit.GutterWidth;
  {$ENDIF UNISYNEDIT}
  if (FLastBitmapTopLine <> FSynEdit.TopLine) or (FLastBitmapLineCount <> FSynEdit.LinesInWindow) or
    (FBitmap.Width <> CurrentGutterWidth) or (FHighlightY <> FLastHighlightY) then
  begin
    FBitmap.Height := FSynEdit.LinesInWindow * LH;
    FBitmap.Width := CurrentGutterWidth;
    FBitmap.Canvas.Brush.Color := clBtnFace;
    FBitmap.Canvas.Brush.Style := bsSolid;
    FBitmap.Canvas.FillRect(Rect(0, 0, FBitmap.Width, FBitmap.Height));
    FRevisionRectangles.Clear(FBitmap.Height);

    FBitmap.Canvas.Brush.Style := bsClear;
    FBitmap.Canvas.Font.Assign(FSynEdit.Font);
    FBitmap.Canvas.Font.Color := FFontColor;
    for PaintLine := FSynEdit.TopLine to (FSynEdit.TopLine + FSynEdit.LinesInWindow - 1) do
    begin
      Y := LH * (PaintLine - FSynEdit.TopLine);
      if FLineX <> -1 then
      begin
        if {(FirstLine = FSynEdit.TopLine) or }(PaintLine mod 10 = 0) then
          FBitmap.Canvas.TextOut(FLineX, Y, IntToStr(PaintLine));
      end;
    end;
    if ((FSynEdit.TopLine - 1) >= 0) and Assigned(FLineInformationList) and (FSynEdit.TopLine - 1 < FLineInformationList.Count) then
    begin
      FBitmap.Canvas.Pen.Color := clSilver;
      FBitmap.Canvas.Pen.Style := psSolid;
      PaintBlocks(FBitmap.Canvas, btRevision, FRevisionRectX1, FRevisionRectX2, FRevisionX);
      PaintBlocks(FBitmap.Canvas, btDate, FDateRectX1, FDateRectX2, FDateX);
      PaintBlocks(FBitmap.Canvas, btUser, FUserRectX1, FUserRectX2, FUserX);
    end;
    {$IFDEF LINEINFOEX}
    if ((FSynEdit.TopLine - 1) >= 0) and Assigned(FLineInformationListEx) and (FSynEdit.TopLine - 1 < FLineInformationListEx.Count) then
    begin
      FBitmap.Canvas.Pen.Color := clSilver;
      FBitmap.Canvas.Pen.Style := psSolid;
      PaintBlocksEx(FBitmap.Canvas, bteCount, FRevisionCountRectX1, FRevisionCountRectX2, FRevisionCountX);
      PaintBlocksEx(FBitmap.Canvas, bteFirstRevision, FFirstRevisionRectX1, FFirstRevisionRectX2, FFirstRevisionX);
    end;
    {$ENDIF LINEINFOEX}
    FLastBitmapTopLine := FSynEdit.TopLine;
    FLastBitmapLineCount := FSynEdit.LinesInWindow;
    FLastHighlightY := FHighlightY;
  end;
  SourceRect := Rect(0, LH * (FirstLine - FSynEdit.TopLine), CurrentGutterWidth, LH * (LastLine - FSynEdit.TopLine) + LH);
  ACanvas.CopyRect(SourceRect, FBitmap.Canvas, SourceRect);
end;

procedure TGutterInfoPlugin.AfterPaint(ACanvas: TCanvas; const AClip: TRect;
  FirstLine, LastLine: Integer);
begin
  if FSettings.PaintMethod = 0 then
    AfterPaintDefault(ACanvas, AClip, FirstLine, LastLine)
  else
    AfterPaintSuccessive(ACanvas, AClip, FirstLine, LastLine);
end;

{$IFDEF LINEINFOEX}
function TGutterInfoPlugin.DoGetLineColor(ALine: Integer; AColorIndex: Integer): TColor;
begin
  Result := clNone;
  if Assigned(FOnGetLineColor) then
    Result := FOnGetLineColor(ALine, AColorIndex);
end;
{$ENDIF LINEINFOEX}

function TGutterInfoPlugin.DoGetRevisionColor(ALineHistoryRevision: TJVCSLineHistoryRevision): TRevisionColor;
begin
  Result := nil;
  if Assigned(FOnGetRevisionColor) then
    Result := FOnGetRevisionColor(ALineHistoryRevision);
end;

function TGutterInfoPlugin.FindRevisionRectangle(AX, AY: Integer; var ATopY: Integer; var ARevisionIDStr: string): Boolean;
begin
  Result := FRevisionRectangles.Find(AX, AY, ATopY, ARevisionIDStr);
end;

procedure TGutterInfoPlugin.LinesInserted(FirstLine, Count: Integer);
begin
end;

procedure TGutterInfoPlugin.LinesDeleted(FirstLine, Count: Integer);
begin
end;

procedure TGutterInfoPlugin.SetLineInformationList(AValue: TStrings);
begin
  if FLineInformationList <> AValue then
  begin
    FLineInformationList := AValue;
    UpdateGutterWidth;
  end;
end;

{$IFDEF LINEINFOEX}
procedure TGutterInfoPlugin.SetLineInformationListEx(AValue: TList);
begin
  if FLineInformationListEx <> AValue then
  begin
    FLineInformationListEx := AValue;
    UpdateGutterWidth;
  end;
end;
{$ENDIF LINEINFOEX}

procedure TGutterInfoPlugin.SetSettings(AValue: TJVCSLineHistorySettings);
begin
  if Assigned(AValue) then
  begin
    FSettings.Assign(AValue);
    FLastBitmapTopLine := -1;
    UpdateGutterWidth;
  end;
end;

procedure TGutterInfoPlugin.UpdateGutterWidth;
var
  MaxWidthRevision, MaxLineWidth, MaxWidthUser, MaxWidthDate, CurrentWidth: Integer;
  I, NextX: Integer;
  LineInformation: TJVCSLineHistoryRevision;
  FontBitmap: TBitmap;
  OrderList: TList;
  {$IFDEF LINEINFOEX}
  MaxWidthRevisionCount, MaxWidthFirstRevision: Integer;
  LineInformationEx: TJVCSLineHistoryLineInfo;
  {$ENDIF LINEINFOEX}

  procedure CalcTextPosAndColorRect(AShowText, AShowColor: Boolean;
    AMaxTextWidth: Integer; var ACurrentX, ATextX, AColorRectX1, AColorRectX2: Integer);
  begin
    if AShowText then
    begin
      ATextX := ACurrentX + 5;
    end
    else
    begin
      AMaxTextWidth := 0;
      ATextX := -1;
    end;
    if AShowColor then
    begin
      AColorRectX1 := ACurrentX;
      AColorRectX2 := ACurrentX + AMaxTextWidth + 11;
    end
    else
    begin
      AColorRectX1 := -1;
      AColorRectX2 := -1;
    end;
    if AShowText or AShowColor then
      Inc(ACurrentX, AMaxTextWidth + 10);
  end;

begin
  MaxWidthRevision := 0;
  {$IFDEF LINEINFOEX}
  MaxWidthRevisionCount := 0;
  MaxWidthFirstRevision := 0;
  {$ENDIF LINEINFOEX}
  MaxWidthUser := 0;
  MaxWidthDate := 0;
  MaxLineWidth := 0;
  FontBitmap := TBitmap.Create;
  try
    FontBitmap.Canvas.Font.Assign(FSynEdit.Font);
    if Assigned(LineInformationList) then
      for I := 0 to Pred(LineInformationList.Count) do
      begin
        LineInformation := TJVCSLineHistoryRevision(LineInformationList.Objects[I]);
        if Assigned(LineInformation) then
        begin
          CurrentWidth := FontBitmap.Canvas.TextWidth(LineInformation.RevisionStr);
          if CurrentWidth > MaxWidthRevision then
            MaxWidthRevision := CurrentWidth;
          CurrentWidth := FontBitmap.Canvas.TextWidth(LineInformation.UserStr);
          if CurrentWidth > MaxWidthUser then
            MaxWidthUser := CurrentWidth;
          CurrentWidth := FontBitmap.Canvas.TextWidth(LineInformation.DateStr);
          if CurrentWidth > MaxWidthDate then
            MaxWidthDate := CurrentWidth;
          CurrentWidth := FontBitmap.Canvas.TextWidth(IntToStr(I + 1));
          if CurrentWidth > MaxLineWidth then
            MaxLineWidth := CurrentWidth;
        end;
      end;
    {$IFDEF LINEINFOEX}
    if Assigned(LineInformationListEx) then
      for I := 0 to Pred(LineInformationListEx.Count) do
        begin
          LineInformationEx := LineInformationListEx[I];
          if Assigned(LineInformationEx) then
          begin
            CurrentWidth := FontBitmap.Canvas.TextWidth(IntToStr(LineInformationEx.Count));
            if CurrentWidth > MaxWidthRevisionCount then
              MaxWidthRevisionCount := CurrentWidth;
            if (LineInformationEx.Count > 0) and Assigned(LineInformationEx.Revision[0]) then
            begin
              CurrentWidth := FontBitmap.Canvas.TextWidth(LineInformationEx.Revision[0].RevisionStr);
              if CurrentWidth > MaxWidthFirstRevision then
                MaxWidthFirstRevision := CurrentWidth;
            end;
          end;
        end;
    {$ENDIF LINEINFOEX}
    NextX := 0;
    OrderList := TList.Create;
    try
      for I := 0 to Pred(FSettings.ShowOrderList.Count) do
        OrderList.Add(FSettings.ShowOrderList[I]);
      for I := 1 to {$IFDEF LINEINFOEX} 6 {$ELSE} 4 {$ENDIF} do
        if OrderList.IndexOf(Pointer(I)) = -1 then
          OrderList.Add(Pointer(I));
      for I := 0 to Pred(OrderList.Count) do
      begin
        if OrderList[I] = Pointer(1) then
        begin
          if FSettings.ShowLineNumbers then
          begin
            FLineX := NextX + 5;
            Inc(NextX, MaxLineWidth + 10);
          end
          else
            FLineX := -1;
        end
        else
        if OrderList[I] = Pointer(2) then
          CalcTextPosAndColorRect(FSettings.ShowRevisionInfoText, FSettings.ShowRevisionInfoColor,
            MaxWidthRevision, NextX, FRevisionX, FRevisionRectX1, FRevisionRectX2)
        else
        if OrderList[I] = Pointer(3) then
          CalcTextPosAndColorRect(FSettings.ShowDateInfoText, FSettings.ShowDateInfoColor,
            MaxWidthDate, NextX, FDateX, FDateRectX1, FDateRectX2)
        else
        {$IFDEF LINEINFOEX}
        if OrderList[I] = Pointer(5) then
          CalcTextPosAndColorRect(FSettings.ShowRevisionCountInfoText, FSettings.ShowRevisionCountInfoColor,
            MaxWidthRevisionCount, NextX, FRevisionCountX, FRevisionCountRectX1, FRevisionCountRectX2)
        else
        if OrderList[I] = Pointer(6) then
          CalcTextPosAndColorRect(FSettings.ShowFirstRevisionInfoText, FSettings.ShowFirstRevisionInfoColor,
            MaxWidthFirstRevision, NextX, FFirstRevisionX, FFirstRevisionRectX1, FFirstRevisionRectX2)
        else
        {$ENDIF LINEINFOEX}
        if OrderList[I] = Pointer(4) then
          CalcTextPosAndColorRect(FSettings.ShowUserInfoText, FSettings.ShowUserInfoColor,
            MaxWidthUser, NextX, FUserX, FUserRectX1, FUserRectX2);
      end;
    finally
      OrderList.Free;
    end;
    FSynEdit.Gutter.Width := NextX;
  finally
    FontBitmap.Free;
  end;
end;

type
  TControlCracker = class(TControl);

constructor TJVCSLineHistoryFrm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  {$IFNDEF LINEINFOEX}
  cbShowRevisionCountText.Visible := False;
  cbShowRevisionCountColor.Visible := False;
  cbShowFirstRevisionText.Visible := False;
  cbShowFirstRevisionColor.Visible := False;
  cbShowRevisionCountColorBar.Visible := False;
  cbShowFirstRevisionColorBar.Visible := False;
  cbLineColorMode.Items.Delete(5);
  cbLineColorMode.Items.Delete(4);
  {$ENDIF ~LINEINFOEX}
  FSettings := TJVCSLineHistorySettings.Create;
  FLastCommentHeight := memComment.Height;
  FIsInBuildInfo := False;
  FIsNewModule := False;
  FModuleName := '';
  FSelectedExtension := '';
  FProvider := nil;
  FPrepareRevisionInfoPath := PathAddSeparator(GetCommonAppdataFolder) + 'JEDI\JVCS\';
  cbLineColorMode.ItemIndex := 0;
  cbPaintMethod.ItemIndex := 0;

  FColorList := TStringList.Create;
  FColorList.AddObject('', TObject(GetNextColor));
  FRevisionColorList := TObjectList.Create;
  FRevisionLinks := TObjectList.Create;
  {$IFDEF LINEINFOEX}
  FMaxLineRevisionCount := -1;
  FRevisionCountColorList := TList.Create;
  {$ENDIF LINEINFOEX}

  FSynEdit := TSynEdit.Create(Self);
  FSynEdit.Parent := Self;
  FSynEdit.Align := alClient;
  FSynEdit.ReadOnly := True;
  FSynEdit.DoubleBuffered := True;
  FSynEdit.ActiveLineColor := $E6FFFA;

  FHighlighters := TJVCSLineHistoryHighlighters.Create;
  FSynEditPlugin := TGutterInfoPlugin.Create(FSynEdit);
  FSynEditSearch := TSynEditSearch.Create(FSynEdit);
  FSynEdit.SearchEngine := FSynEditSearch;
  FillHighlighterList;

  FDateFormatList := TStringList.Create;
  FillDateFormatComboBox;

  FLineHistory := TJVCSLineHistory.Create;
  FLineHistorySummary := TJVCSLineHistorySummary.Create;

  TGutterInfoPlugin(FSynEditPlugin).LineHistory := FLineHistory;
  TGutterInfoPlugin(FSynEditPlugin).OnGetRevisionColor := GetRevisionColor;
  {$IFDEF LINEINFOEX}
  TGutterInfoPlugin(FSynEditPlugin).OnGetLineColor := GetLineColor;
  {$ENDIF LINEINFOEX}
  FCachedColorBar := TBitmap.Create;
  FLastTopLine := -1;
  FSynEdit.OnChange := SynEditChange;
  FSynEdit.OnClick := SynEditOnClick;
  TControlCracker(FSynEdit).OnMouseLeave := SynEditMouseLeave;
  FSynEdit.OnMouseMove := SynEditMouseMove;
  FSynEdit.OnStatusChange := SynEditStatusChange;
  FSynEdit.OnSpecialLineColors := SynEditSpecialLineColors;
  FInSetSettings := False;
  vstSummary.NodeDataSize := SizeOf(TObject);
  FOnSettingsChanged := nil;
  cbLineNumbersClick(nil);
  cbShowRevisionColorBarClick(nil);
  SetSummaryNextLineButtonState;
end;

destructor TJVCSLineHistoryFrm.Destroy;
begin
  FSynEdit.Highlighter := nil;
  FHighlighters.Free;
  FreeAndNil(FCachedColorBar);
  FRevisionLinks.Free;
  FColorList.Free;
  FRevisionColorList.Free;
  {$IFDEF LINEINFOEX}
  FRevisionCountColorList.Free;
  {$ENDIF LINEINFOEX}
  FLineHistorySummary.Free;
  FLineHistory.Free;
  FDateFormatList.Free;
  FSettings.Free;
  inherited Destroy;
end;

procedure TJVCSLineHistoryFrm.DoSettingsChanged;
begin
  if not FInSetSettings and Assigned(FOnSettingsChanged) then
    FOnSettingsChanged(Self);
end;

function TJVCSLineHistoryFrm.GetNextColor: TColor;
begin
  case (14 - FColorList.Count mod 15) of
    0: Result := RGB(128, 128, 128);
    1: Result := RGB(255, 128, 128);
    2: Result := RGB(128, 255, 128);
    3: Result := RGB(128, 128, 255);
    4: Result := RGB(255, 255, 128);
    5: Result := RGB(128, 255, 255);
    6: Result := RGB(255, 128, 255);
    7: Result := RGB(192, 192, 192);
    8: Result := RGB(255, 192, 192);
    9: Result := RGB(192, 255, 192);
   10: Result := RGB(192, 192, 255);
   11: Result := RGB(255, 255, 192);
   12: Result := RGB(192, 255, 255);
   13: Result := RGB(255, 192, 255);
   14: Result := RGB(255, 255, 255);
   else
     Result := RGB(255, 255, 255);
  end;
end;

function CalcColor(AStartColor, AEndColor: TColor; AFactor: Double): TColor;
var
  StartRGB: array [0..2] of Byte;
begin
  AStartColor := ColorToRGB(AStartColor);
  AEndColor := ColorToRGB(AEndColor);
  StartRGB[0] := GetRValue(AStartColor);
  StartRGB[1] := GetGValue(AStartColor);
  StartRGB[2] := GetBValue(AStartColor);
  Result := RGB(StartRGB[0] + Trunc((GetRValue(AEndColor) - StartRGB[0]) * AFactor),
    StartRGB[1] + Trunc((GetGValue(AEndColor) - StartRGB[1]) * AFactor),
    StartRGB[2] + Trunc((GetBValue(AEndColor) - StartRGB[2]) * AFactor));
end;

function TJVCSLineHistoryFrm.GetRevisionColor(ALineHistoryRevision: TJVCSLineHistoryRevision): TRevisionColor;
var
  DC, DL: Double;
  I, Idx, IdxS: Integer;
  MinDate, MaxDate: TDateTime;
begin
  Result := nil;
  for I := 0 to Pred(FRevisionColorList.Count) do
    if TRevisionColor(FRevisionColorList[I]).LineHistoryRevision = ALineHistoryRevision then
    begin
      Result := TRevisionColor(FRevisionColorList[I]);
      Break;
    end;
  if not Assigned(Result) then
  begin
    FRevisionColorList.Add(TRevisionColor.Create(ALineHistoryRevision));
    Result := TRevisionColor(FRevisionColorList.Last);

    if Assigned(FLineHistory) then
      DL := FLineHistory.RevisionCount
    else
      DL := 0;
    if DL > 0 then
    begin
      DC := 0;
      if Assigned(ALineHistoryRevision) then
        for I := 0 to Pred(FLineHistory.RevisionCount) do
          if FLineHistory[I] = ALineHistoryRevision then
          begin
            DC := I + 1;
            Break;
          end;
    end
    else
      DC := 0;
    if DL = 0 then
      DC := 0
    else
      DC := DC / DL;
    Result.RevisionColor := CalcColor(FSettings.RevisionStartColor, FSettings.RevisionEndColor, DC);

    MinDate := MaxInt;
    MaxDate := 0;
    if Assigned(FLineHistory) then
      for I := 0 to Pred(FLineHistory.RevisionCount) do
      begin
        if FLineHistory[I].Date < MinDate then
          MinDate := FLineHistory[I].Date;
        if FLineHistory[I].Date > MaxDate then
          MaxDate := FLineHistory[I].Date;
      end;
    DC := 0;
    DL := 0;
    if (MinDate < MaxInt) and (MaxDate > 0) then
    begin
      if Assigned(ALineHistoryRevision) then
      begin
        DC := ALineHistoryRevision.Date - MinDate;
        DL := MaxDate - MinDate;
      end;
    end;
    if DL = 0 then
      DC := 0
    else
      DC := DC / DL;
    Result.DateColor := CalcColor(FSettings.DateStartColor, FSettings.DateEndColor, DC);

    Idx := 0;
    if Assigned(ALineHistoryRevision) then
    begin
      IdxS := FSettings.UserSettingsList.IndexOfUser(ALineHistoryRevision.OrgUserStr);
      if (IdxS <> -1) and (FSettings.UserSettingsList[IdxS].Color <> clNone) and
        (FSettings.UserSettingsList[IdxS].Color <> clDefault) then
      begin
        Idx := FColorList.IndexOf(ALineHistoryRevision.OrgUserStr);
        if Idx = -1 then
        begin
          FColorList.AddObject(ALineHistoryRevision.OrgUserStr, TObject(FSettings.UserSettingsList[IdxS].Color));
          Idx := Pred(FColorList.Count);
        end;
      end
      else
      begin
        Idx := FColorList.IndexOf(ALineHistoryRevision.OrgUserStr);
        if Idx = -1 then
        begin
          FColorList.AddObject(ALineHistoryRevision.OrgUserStr, TObject(GetNextColor));
          Idx := Pred(FColorList.Count);
        end;
      end;
    end;
    if Idx < FColorList.Count then
      Result.UserColor := Integer(FColorList.Objects[Idx])
    else
      Result.UserColor := clNone;
  end;
end;

function TJVCSLineHistoryFrm.GetLineColor(ALine: Integer; AColorIndex: Integer): TColor;
var
  RevisionColor: TRevisionColor;
  {$IFDEF LINEINFOEX}
  I: Integer;
  DC, DL: Double;
  {$ENDIF LINEINFOEX}  
begin
  Result := clNone;
  if AColorIndex in [1, 2, 3] then
  begin
    if (FLineHistory.Lines.Count > ALine) then
      RevisionColor := GetRevisionColor(TJVCSLineHistoryRevision(FLineHistory.Lines.Objects[ALine]))
    else
      RevisionColor := GetRevisionColor(nil);
    if Assigned(RevisionColor) then
    begin
      case AColorIndex of
        1: Result := RevisionColor.RevisionColor;
        2: Result := RevisionColor.DateColor;
        3: Result := RevisionColor.UserColor;
      end;
    end;
  {$IFDEF LINEINFOEX}
  end
  else
  if AColorIndex = 4 then
  begin
    if FMaxLineRevisionCount = -1 then
    begin
      for I := 0 to Pred(FLineHistory.LineInfos.Count) do
        if TJVCSLineHistoryLineInfo(FLineHistory.LineInfos[I]).Count > FMaxLineRevisionCount then
          FMaxLineRevisionCount := TJVCSLineHistoryLineInfo(FLineHistory.LineInfos[I]).Count;
      FRevisionCountColorList.Clear;
      for I := 0 to FMaxLineRevisionCount do
      begin
        DL := FMaxLineRevisionCount;
        DC := I;
        if DL = 0 then
          DC := 0
        else
          DC := DC / DL;
        FRevisionCountColorList.Add(Pointer(CalcColor(clWhite, clAqua, DC)));
      end;
    end;
    if (FLineHistory.LineInfos.Count > ALine) and (TJVCSLineHistoryLineInfo(FLineHistory.LineInfos[ALine]).Count < FRevisionCountColorList.Count) then
      Result := TColor(FRevisionCountColorList[TJVCSLineHistoryLineInfo(FLineHistory.LineInfos[ALine]).Count])
    else
      Result := clAqua;
  end
  else
  if AColorIndex = 5 then
  begin
    if (FLineHistory.LineInfos.Count > ALine) and (TJVCSLineHistoryLineInfo(FLineHistory.LineInfos[ALine]).Count > 0) then
      RevisionColor := GetRevisionColor(TJVCSLineHistoryLineInfo(FLineHistory.LineInfos[ALine]).Revision[0])
    else
      RevisionColor := GetRevisionColor(nil);
    if Assigned(RevisionColor) then
      Result := RevisionColor.RevisionColor;
  {$ENDIF LINEINFOEX}
  end;
end;

procedure TJVCSLineHistoryFrm.HandleApplySettings(Sender: TObject);
begin
  FSettings.Assign(TJVCSLineHistorySettings(Sender));
  UpdateAll;
end;

procedure TJVCSLineHistoryFrm.HandleLineHistoryBuilderProgress(ASender: TObject; APosition, AMax: Integer; var AAbort: Boolean);
begin
  PB1.Position := APosition;
  PB1.Max := AMax;
  if FAbort then
    AAbort := True;
end;

procedure TJVCSLineHistoryFrm.SynEditChange(Sender: TObject);
begin
  FCachedColorBar.Width := 0;
  UpdateColorBars;
  UpdateRevisionInfo;
end;

procedure TJVCSLineHistoryFrm.SynEditMouseLeave(Sender: TObject);
begin
  FSynEdit.Gutter.Cursor := crDefault;
  TGutterInfoPlugin(FSynEditPlugin).FHighlightY := -1;
  FSynEdit.InvalidateGutter;
end;

procedure TJVCSLineHistoryFrm.SynEditMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  NewCursor: TCursor;
  TopY: Integer;
begin
  if Assigned(FOnRevisionClick) then
  begin
    if TGutterInfoPlugin(FSynEditPlugin).FindRevisionRectangle(X, Y, TopY, FLastHighlightedRevisionIDStr) and
      (FFirstRevisionIDStr <> FLastHighlightedRevisionIDStr) then
      NewCursor := crHandPoint
    else
    begin
      NewCursor := crDefault;
      TopY := -1;
    end;
    if (NewCursor <> FSynEdit.Gutter.Cursor) or (TGutterInfoPlugin(FSynEditPlugin).FHighlightY <> TopY) then
    begin
      FSynEdit.Gutter.Cursor := NewCursor;
      TGutterInfoPlugin(FSynEditPlugin).FHighlightY := TopY;
      FSynEdit.InvalidateGutter;
    end;
  end;
end;

procedure TJVCSLineHistoryFrm.SynEditOnClick(Sender: TObject);
begin
  if (FSynEdit.Gutter.Cursor = crHandPoint) and Assigned(FOnRevisionClick) then
    FOnRevisionClick(Self, FLastHighlightedRevisionIDStr);
end;

procedure TJVCSLineHistoryFrm.SynEditStatusChange(Sender: TObject;
  Changes: TSynStatusChanges);
begin
  if (FSettings.PaintMethod <> 0) and (FLastTopLine <> FSynEdit.TopLine) then
  begin
    FLastTopLine := FSynEdit.TopLine;
    FSynEdit.InvalidateGutter;
  end;
  UpdateColorBars;
  UpdateRevisionInfo;
end;

procedure TJVCSLineHistoryFrm.SynEditSpecialLineColors(Sender: TObject; Line: Integer;
  var Special: Boolean; var FG, BG: TColor);
begin
  if Assigned(FSynEditPlugin) and (FSettings.LineColorMode > 0) then
  begin
    Special := True;
    FG := clNone;
    BG := GetLineColor(Line - 1, FSettings.LineColorMode);
  end;
end;

procedure TJVCSLineHistoryFrm.PaintColorBar(ACanvas: TCanvas; ARect: TRect; ALinesCount,
  APenColor, ABackGroundColor: TColor; AOnGetLineColor: TOnGetLineColorEvent; AColorIndex: Integer);
var
  HeightRatio: Single;
  TruncedHeightRatio: Integer;
  I, Y, Y1, Y2, StartY, X1, X2: Integer;
begin
  if ALinesCount = 0 then
  begin
    ACanvas.Brush.Color := ABackGroundColor;
    ACanvas.Pen.Style := psClear;
    ACanvas.Rectangle(ARect);
  end
  else
  begin
    if APenColor = clNone then
    begin
      HeightRatio := (ARect.Bottom - ARect.Top) / ALinesCount;
      StartY := ARect.Top;
      X1 := ARect.Left;
      X2 := ARect.Right;
      ACanvas.Pen.Style := psClear;
    end
    else
    begin
      HeightRatio := (ARect.Bottom - ARect.Top - 2) / ALinesCount;
      StartY := ARect.Top + 1;
      X1 := ARect.Left + 1;
      X2 := ARect.Right - 1;
      ACanvas.Pen.Width := 1;
      ACanvas.Pen.Color := APenColor;
    end;
    TruncedHeightRatio := Trunc(HeightRatio);
    ACanvas.Brush.Color := ABackGroundColor;
    ACanvas.Rectangle(ARect);
    ACanvas.Pen.Style := psSolid;
    if Assigned(AOnGetLineColor) then
    begin
      for I := 0 to Pred(ALinesCount) do
      begin
        ACanvas.Pen.Color := AOnGetLineColor(I, AColorIndex);
        Y1 := StartY + Trunc(I * HeightRatio);
        Y2 := Y1 + TruncedHeightRatio;
        for Y := Y1 to Y2 do
        begin
          ACanvas.MoveTo(X1, Y);
          ACanvas.LineTo(X2, Y);
        end;
      end;
    end;
  end;
end;

procedure TJVCSLineHistoryFrm.UpdateColorBars;
var
  W, CX, CurrentLineY: Integer;
  I: Integer;
begin
  W := 0;
  if Assigned(FSettings.ColorBarOrderList) then
  begin
    for I := 0 to Pred(FSettings.ColorBarOrderList.Count) do
    begin
      if FSettings.ColorBarOrderList[I] = Pointer(1) then
        Inc(W, 8)
      else
      if FSettings.ColorBarOrderList[I] = Pointer(2) then
        Inc(W, 8)
      else
      if FSettings.ColorBarOrderList[I] = Pointer(3) then
      {$IFDEF LINEINFOEX}
        Inc(W, 8)
      else
      if FSettings.ColorBarOrderList[I] = Pointer(4) then
        Inc(W, 8)
      else
      if FSettings.ColorBarOrderList[I] = Pointer(5) then
      {$ENDIF LINEINFOEX}
        Inc(W, 8);
    end;
    PaintBox1.Width := W;
    if (PaintBox1.Width <> FCachedColorBar.Width) or (PaintBox1.Height <> FCachedColorBar.Height) then
    begin
      FCachedColorBar.Width := PaintBox1.Width;
      FCachedColorBar.Height := PaintBox1.Height;
      if PaintBox1.Width > 0 then
      begin
        CX := 0;
        W := 8;
        for I := 0 to Pred(FSettings.ColorBarOrderList.Count) do
        begin
          if (FSettings.ColorBarOrderList[I] = Pointer(1)) and cbShowRevisionColorBar.Checked then
          begin
            PaintColorBar(FCachedColorBar.Canvas, Rect(CX, 0, CX + W, PaintBox1.Height),
              FLineHistory.Lines.Count, clNone, clWindow, GetLineColor, 1);
            Inc(CX, W);
          end
          else
          if (FSettings.ColorBarOrderList[I] = Pointer(2)) and cbShowDateColorBar.Checked then
          begin
            PaintColorBar(FCachedColorBar.Canvas, Rect(CX, 0, CX + W, PaintBox1.Height),
              FLineHistory.Lines.Count, clNone, clWindow, GetLineColor, 2);
            Inc(CX, W);
          end
          else
          if (FSettings.ColorBarOrderList[I] = Pointer(3)) and cbShowUserColorBar.Checked then
          begin
            PaintColorBar(FCachedColorBar.Canvas, Rect(CX, 0, PaintBox1.Width, PaintBox1.Height),
              FLineHistory.Lines.Count, clNone, clWindow, GetLineColor, 3);
            Inc(CX, W);
          {$IFDEF LINEINFOEX}
          end
          else
          if (FSettings.ColorBarOrderList[I] = Pointer(4)) and cbShowRevisionCountColorBar.Checked then
          begin
            PaintColorBar(FCachedColorBar.Canvas, Rect(CX, 0, PaintBox1.Width, PaintBox1.Height),
              FLineHistory.Lines.Count, clNone, clWindow, GetLineColor, 4);
            Inc(CX, W);
          end
          else
          if (FSettings.ColorBarOrderList[I] = Pointer(5)) and cbShowFirstRevisionColorBar.Checked then
          begin
            PaintColorBar(FCachedColorBar.Canvas, Rect(CX, 0, PaintBox1.Width, PaintBox1.Height),
              FLineHistory.Lines.Count, clNone, clWindow, GetLineColor, 5);
            Inc(CX, W);
          {$ENDIF LINEINFOEX}
          end;
        end;
      end;
    end;
    if PaintBox1.Width > 0 then
    begin
      CurrentLineY := -1;
      if FLineHistory.Lines.Count > 0 then
        CurrentLineY := ((PaintBox1.Height - 2) * FSynEdit.CaretY) div FLineHistory.Lines.Count + 1;
      with PaintBox1.Canvas do
      begin
        Draw(0, 0, FCachedColorBar);
        if CurrentLineY <> -1 then
        begin
          Pen.Color := clBlack;
          Pen.Width := 2;
          MoveTo(0, CurrentLineY);
          LineTo(PaintBox1.Width, CurrentLineY);
        end;
      end;
    end;
  end;
end;

procedure TJVCSLineHistoryFrm.UpdateRevisionInfo;
var
  CurrentComment: string;
  {$IFDEF LINEINFOEX}
  I: Integer;
  LineHistoryLineInfo: TJVCSLineHistoryLineInfo;
  {$ENDIF LINEINFOEX}  
  Idx: Integer;
  LineHistoryRevision: TJVCSLineHistoryRevision;
begin
  CurrentComment := '';
  Idx := FSynEdit.CaretY - 1;
  if (FLineHistory.Lines.Count > 0) and (Idx >= 0) and (Idx < FLineHistory.Lines.Count) and
    Assigned(FLineHistory.Lines.Objects[Idx]) then
  begin
    LineHistoryRevision := TJVCSLineHistoryRevision(FLineHistory.Lines.Objects[Idx]);
    CurrentComment := LineHistoryRevision.Comment;
    {$IFDEF LINEINFOEX}
    if Assigned(FLineHistory.LineInfos) and (FLineHistory.LineInfos.Count > 0) and (Idx >= 0) and
      (Idx < FLineHistory.LineInfos.Count) and Assigned(FLineHistory.LineInfos[Idx]) then
    begin
      LineHistoryLineInfo := TJVCSLineHistoryLineInfo(FLineHistory.LineInfos[Idx]);
      if LineHistoryLineInfo.Count > 1 then
      begin
        CurrentComment := '';
        for I := Pred(LineHistoryLineInfo.Count) downto 0 do
        begin
          if CurrentComment <> '' then
            CurrentComment := CurrentComment + #13#10;
          LineHistoryRevision := LineHistoryLineInfo.Revision[I];
          if Assigned(LineHistoryRevision) then
            CurrentComment := CurrentComment + Format('%s | %s | %s' + #13#10 + '%s',
              [LineHistoryRevision.RevisionStr, LineHistoryRevision.DateStr,
               LineHistoryRevision.UserStr, LineHistoryRevision.Comment]);
        end;
      end;
    end;
    {$ENDIF LINEINFOEX}
  end;
  memComment.Lines.Text := CurrentComment;
end;

procedure TJVCSLineHistoryFrm.cbLineColorModeChange(Sender: TObject);
begin
  if not FInSetSettings then
  begin
    FSettings.LineColorMode := cbLineColorMode.ItemIndex;
    FSynEdit.Invalidate;
    DoSettingsChanged;
  end;
end;

procedure TJVCSLineHistoryFrm.cbLineNumbersClick(Sender: TObject);
begin
  if not FInSetSettings then
  begin
    FSettings.ShowLineNumbers := cbLineNumbers.Checked;
    FSettings.ShowRevisionInfoText := cbShowRevisionText.Checked;
    FSettings.ShowRevisionInfoColor := cbShowRevisionColor.Checked;
    FSettings.SuppressRevisionTextZeroDot := cbSuppressRevisionTextZeroDot.Checked;
    FSettings.ShowDateInfoText := cbShowDateText.Checked;
    FSettings.ShowDateInfoColor := cbShowDateColor.Checked;
    FSettings.ShowUserInfoText := cbShowUserText.Checked;
    FSettings.ShowUserInfoColor := cbShowUserColor.Checked;
    {$IFDEF LINEINFOEX}
    FSettings.ShowRevisionCountInfoText := cbShowRevisionCountText.Checked;
    FSettings.ShowRevisionCountInfoColor := cbShowRevisionCountColor.Checked;
    FSettings.ShowFirstRevisionInfoText := cbShowFirstRevisionText.Checked;
    FSettings.ShowFirstRevisionInfoColor := cbShowFirstRevisionColor.Checked;
    {$ENDIF LINEINFOEX}
    FSettings.ShowOrderList.Clear;
    if FSettings.ShowLineNumbers then
      FSettings.ShowOrderList.Add(Pointer(1));
    if FSettings.ShowRevisionInfoText or FSettings.ShowRevisionInfoColor then
      FSettings.ShowOrderList.Add(Pointer(2));
    if FSettings.ShowDateInfoText or FSettings.ShowDateInfoColor then
      FSettings.ShowOrderList.Add(Pointer(3));
    if FSettings.ShowUserInfoText or FSettings.ShowUserInfoColor then
      FSettings.ShowOrderList.Add(Pointer(4));
    {$IFDEF LINEINFOEX}
    if FSettings.ShowRevisionCountInfoText or FSettings.ShowRevisionCountInfoColor then
      FSettings.ShowOrderList.Add(Pointer(5));
    if FSettings.ShowFirstRevisionInfoText or FSettings.ShowFirstRevisionInfoColor then
      FSettings.ShowOrderList.Add(Pointer(6));
    {$ENDIF LINEINFOEX}
    FLineHistory.Settings := FSettings;
    TGutterInfoPlugin(FSynEditPlugin).Settings := FSettings;
    FSynEdit.Invalidate;
    DoSettingsChanged;
  end;
end;

procedure TJVCSLineHistoryFrm.cbShowRevisionColorBarClick(Sender: TObject);
begin
  if not FInSetSettings then
  begin
    FSettings.ColorBarOrderList.Clear;
    if cbShowRevisionColorBar.Checked then
      FSettings.ColorBarOrderList.Add(Pointer(1));
    if cbShowDateColorBar.Checked then
      FSettings.ColorBarOrderList.Add(Pointer(2));
    if cbShowUserColorBar.Checked then
      FSettings.ColorBarOrderList.Add(Pointer(3));
    {$IFDEF LINEINFOEX}
    if cbShowRevisionCountColorBar.Checked then
      FSettings.ColorBarOrderList.Add(Pointer(4));
    if cbShowFirstRevisionColorBar.Checked then
      FSettings.ColorBarOrderList.Add(Pointer(5));
    {$ENDIF LINEINFOEX}
    UpdateColorBars;
    DoSettingsChanged;
  end;
end;

procedure TJVCSLineHistoryFrm.PaintBox1Paint(Sender: TObject);
begin
  UpdateColorBars;
end;

procedure TJVCSLineHistoryFrm.FrameResize(Sender: TObject);
begin
  if Assigned(FLineHistory) then
    UpdateColorBars;
end;

procedure TJVCSLineHistoryFrm.ShowLineHistory;
var
  FirstRevisionLink, LastRevisionLink: TJVCSLineHistoryRevisionLink;
  LineHistoryBuilder: TJVCSLineHistoryBuilder;
  LPreparedRevisionInfoProvider: TCustomPreparedRevisionInfoProvider;
  IsLocalFileOkay, CheckedOut: Boolean;
  ExtensionCRCList: TStringList;
  I: Integer;
begin
  IsLocalFileOkay := True;
  if cbLastRevision.ItemIndex <> -1 then
  begin
    LastRevisionLink := TJVCSLineHistoryRevisionLink(cbLastRevision.Items.Objects[cbLastRevision.ItemIndex]);
    if Assigned(LastRevisionLink) and (LastRevisionLink.Kind = lhrkLocalFile) then
    begin
      ExtensionCRCList := TStringList.Create;
      try
        if FProvider.GetModuleCheckoutState(FModuleName, CheckedOut, ExtensionCRCList) and (not CheckedOut) then
          for I := 0 to Pred(ExtensionCRCList.Count) do
            if SameText(FSelectedExtension, ExtensionCRCList[I]) then
            begin
              IsLocalFileOkay := not IsFileDirtyCRC(FModuleName, Integer(ExtensionCRCList.Objects[I]));
              Break;
            end;
      finally
        ExtensionCRCList.Free;
      end;
    end;
    if not IsLocalFileOkay and not NoYesWarnMessageBox('This module is not checked out by you and the local file does not match the latest revision.' +
      #13#10 + 'Do you want to use the local file anyway?') then
    begin
      for I := 0 to Pred(cbLastRevision.Items.Count) do
        if TJVCSLineHistoryRevisionLink(cbLastRevision.Items.Objects[I]).Kind = lhrkLatestRevision then
        begin
          cbLastRevision.ItemIndex := I;
          Break;
        end;
    end;
  end;
  FSynEdit.Lines.Clear;
  TGutterInfoPlugin(FSynEditPlugin).LineInformationList := nil;
  {$IFDEF LINEINFOEX}
  TGutterInfoPlugin(FSynEditPlugin).LineInformationListEx := nil;
  {$ENDIF LINEINFOEX}

  vstSummary.RootNodeCount := 0;
  FLineHistory.Clear;
  FLineHistorySummary.FillFromLineHistory(nil);
  FRevisionColorList.Clear;
  {$IFDEF LINEINFOEX}
  FMaxLineRevisionCount := -1;
  FRevisionCountColorList.Clear;
  {$ENDIF LINEINFOEX}

  btnCancel.Enabled := True;
  PB1.Visible := True;
  cbMember.Enabled := False;
  try
    FAbort := False;
    FirstRevisionLink := nil;
    LastRevisionLink := nil;
    if cbFirstRevision.ItemIndex <> -1 then
      FirstRevisionLink := TJVCSLineHistoryRevisionLink(cbFirstRevision.Items.Objects[cbFirstRevision.ItemIndex]);
    if cbLastRevision.ItemIndex <> -1 then
      LastRevisionLink := TJVCSLineHistoryRevisionLink(cbLastRevision.Items.Objects[cbLastRevision.ItemIndex]);
    FIsInBuildInfo := True;
    try
      SetButtonCaption;
      LineHistoryBuilder := TJVCSLineHistoryBuilder.Create;
      LPreparedRevisionInfoProvider := THybridStoragePreparedRevisionInfoProvider.Create;
      try
        if LPreparedRevisionInfoProvider is TLocalPreparedRevisionInfoProvider then
          TLocalPreparedRevisionInfoProvider(LPreparedRevisionInfoProvider).PrepareRevisionInfoPath :=
            PathAddSeparator(FPrepareRevisionInfoPath) + EncodeFileName(UpperCase(FProvider.ServerInfo));
        if LPreparedRevisionInfoProvider is THybridStoragePreparedRevisionInfoProvider then
          THybridStoragePreparedRevisionInfoProvider(LPreparedRevisionInfoProvider).PrepareRevisionInfoPath :=
            PathAddSeparator(FPrepareRevisionInfoPath) + EncodeFileName(UpperCase(FProvider.ServerInfo));
        LineHistoryBuilder.LineHistory := FLineHistory;
        LineHistoryBuilder.Provider := FProvider;
        LineHistoryBuilder.ModuleName := FModuleName;
        LineHistoryBuilder.ModuleExtension := FSelectedExtension;
        LineHistoryBuilder.FirstRevisionLink := FirstRevisionLink;
        LineHistoryBuilder.LastRevisionLink := LastRevisionLink;
        LineHistoryBuilder.OnProgress := HandleLineHistoryBuilderProgress;
        LineHistoryBuilder.PreparedRevisionInfoProvider := LPreparedRevisionInfoProvider;
        LineHistoryBuilder.BuildLineHistoryInfo;
      finally
        LineHistoryBuilder.Free;
        LPreparedRevisionInfoProvider.Free;
      end;
      FIsNewModule := False;
    finally
      FIsInBuildInfo := False;
    end;
  finally
    SetButtonCaption;
    cbMember.Enabled := True;
    PB1.Visible := False;
  end;
  FLineHistory.BuildInfo;
  FSynEdit.Lines.Assign(FLineHistory.Lines);
  TGutterInfoPlugin(FSynEditPlugin).LineInformationList := FLineHistory.Lines;
  {$IFDEF LINEINFOEX}
  TGutterInfoPlugin(FSynEditPlugin).LineInformationListEx := FLineHistory.LineInfos;
  {$ENDIF LINEINFOEX}
  FLineHistorySummary.FillFromLineHistory(FLineHistory);
  vstSummary.RootNodeCount := 2;

  FCachedColorBar.Width := 0;
  UpdateColorBars;
end;

procedure TJVCSLineHistoryFrm.FillDateFormatComboBox;
var
  I, Idx: Integer;

  procedure AddDateFormatToComboBox(AText, AFormat: string);
  begin
    cbDateFormat.Items.AddObject(AText, TObject(FDateFormatList.Count));
    FDateFormatList.Add(AFormat);
  end;

begin
  if FDateFormatList.Count = 0 then
  begin
    cbDateFormat.Items.Clear;
    AddDateFormatToComboBox('Age', AgeDateFormat);
    AddDateFormatToComboBox('Age2', Age2DateFormat);
    AddDateFormatToComboBox('System', '');
    AddDateFormatToComboBox('yyyy/mm/dd', 'yyyy"/"mm"/"dd');
    AddDateFormatToComboBox('yyyy/mm/dd hh:nn', 'yyyy"/"mm"/"dd hh:nn');
    AddDateFormatToComboBox('yyyy-mm-dd', 'yyyy"-"mm"-"dd');
    AddDateFormatToComboBox('yyyy-mm-dd hh:nn', 'yyyy"-"mm"-"dd hh:nn');
    Idx := -1;
    for I := 0 to Pred(cbDateFormat.Items.Count) do
      if cbDateFormat.Items[I] = FSettings.DateFormat then
      begin
        Idx := I;
        Break;
      end;
    if Idx <> -1 then
      cbDateFormat.ItemIndex := Idx;
  end;
end;

procedure TJVCSLineHistoryFrm.FillExtensionsList(ASelectedExtension: string);
var
  Idx: Integer;
begin
  if FProvider.GetModuleExtensions(FModuleName, cbMember.Items) then
  begin
    if cbMember.Items.Count > 0 then
    begin
      Idx := cbMember.Items.IndexOf(ASelectedExtension);
      if Idx <> -1 then
        cbMember.ItemIndex := Idx
      else
        cbMember.ItemIndex := 0;
    end;
  end
  else
    cbMember.Items.Clear;
  lblMemberCount.Caption := IntToStr(cbMember.Items.Count);
end;

procedure TJVCSLineHistoryFrm.FillHighlighterList;
var
  I, DefaultIdx: Integer;
begin
  cbxHighlighter.Items.Clear;
  cbxHighlighter.Items.Add('');
  DefaultIdx := 0;
  for I := 0 to Pred(FHighlighters.Count) do
  begin
    cbxHighlighter.Items.AddObject(FHighlighters[I].SynHighlighter.LanguageName, FHighlighters[I]);
    if FHighlighters[I] = FHighlighters.DefaultHighligther then
      DefaultIdx := cbxHighlighter.Items.Count - 1;
  end;
  cbxHighlighter.ItemIndex := DefaultIdx;
  cbxHighlighterChange(nil);
end;

procedure TJVCSLineHistoryFrm.FillRevisionLists(const AModulename, ASelectedExtension: string);
var
  ModuleRevisionList: TJVCSLineHistoryModuleRevisionList;
  I, LatestRevisionIdx, LocalFileIdx: Integer;
  S: string;
  CheckedOut: Boolean;
begin
  cbFirstRevision.Items.Clear;
  cbLastRevision.Items.Clear;
  FRevisionLinks.Clear;
  FFirstRevisionIDStr := '';
  ModuleRevisionList := TJVCSLineHistoryModuleRevisionList.Create(FProvider);
  try
    ModuleRevisionList.Fill(AModuleName, ASelectedExtension);
    FRevisionLinks.Add(TJVCSLineHistoryRevisionLink.Create(lhrkFirstRevision));
    cbFirstRevision.Items.AddObject('First Revision', FRevisionLinks.Last);
    for I := 0 to Pred(ModuleRevisionList.Count) do
    begin
      if I = 0 then
      begin
        if ModuleRevisionList[I].RevisionID > 0 then
          FFirstRevisionIDStr := IntToStr(ModuleRevisionList[I].RevisionID)
        else
          FFirstRevisionIDStr := ModuleRevisionList[I].RevisionStr;
      end;
      FRevisionLinks.Add(TJVCSLineHistoryRevisionLink.Create(lhrkRevision, ModuleRevisionList[I].RevisionID));
      S := Format('Ver: %s - %s', [ModuleRevisionList[I].RevisionStr, DateTimeToStr(ModuleRevisionList[I].TimeStamp)]);
      cbFirstRevision.Items.AddObject(S, FRevisionLinks.Last);
      cbLastRevision.Items.AddObject(S,FRevisionLinks.Last);
    end;
    FRevisionLinks.Add(TJVCSLineHistoryRevisionLink.Create(lhrkLatestRevision));
    LatestRevisionIdx := cbLastRevision.Items.AddObject('Latest Revision', FRevisionLinks.Last);
    FRevisionLinks.Add(TJVCSLineHistoryRevisionLink.Create(lhrkLocalFile));
    LocalFileIdx := cbLastRevision.Items.AddObject('Local File', FRevisionLinks.Last);
  finally
    ModuleRevisionList.Free;
  end;
  if cbFirstRevision.Items.Count > 0 then
    cbFirstRevision.ItemIndex := 0;
  if cbLastRevision.Items.Count > 0 then
  begin
    if FProvider.GetModuleCheckoutState(AModulename, CheckedOut, nil) and CheckedOut then
      cbLastRevision.ItemIndex := LocalFileIdx
    else
      cbLastRevision.ItemIndex := LatestRevisionIdx;
  end;
end;

procedure TJVCSLineHistoryFrm.Enable;
begin
  btnCancel.Enabled := True;
end;

procedure TJVCSLineHistoryFrm.btnCancelClick(Sender: TObject);
begin
  if FIsInBuildInfo then
    FAbort := True
  else
    ShowLineHistory;
end;

function TJVCSLineHistoryFrm.GetModuleName(AIndex: Integer): string;
begin
  case AIndex of
    1: Result := FModuleName;
    2: Result := FSelectedExtension;
    else
      Result := '';
  end;
end;

procedure TJVCSLineHistoryFrm.SetModuleName(AIndex: Integer; AValue: string);
var
  Idx: Integer;
  OldEnabled: Boolean;
begin
  if AValue <> GetModuleName(AIndex) then
  begin
    case AIndex of
      1: FModuleName := AValue;
      2: FSelectedExtension := AValue;
    end;
    OldEnabled := btnCancel.Enabled;
    btnCancel.Enabled := False;
    try
      if AIndex = 1 then
      begin
        FillExtensionsList(ExtractFileExt(FModuleName));
        FillRevisionLists(FModuleName, ExtractFileExt(FModuleName));
      end
      else
      begin
        if cbMember.Items.Count = 0 then
          FillExtensionsList(FSelectedExtension)
        else
        begin
          Idx := cbMember.Items.IndexOf(FSelectedExtension);
          if Idx = -1 then
            Idx := cbMember.Items.IndexOf(ExtractFileExt(FModuleName));
          if Idx = -1 then
            Idx := 0;
          cbMember.ItemIndex := Idx;
        end;
      end;
    finally
      btnCancel.Enabled := OldEnabled;
    end;
    FIsNewModule := True;
    SetButtonCaption;
    SetExtensionControls;
  end;
end;

procedure TJVCSLineHistoryFrm.SetButtonCaption;
begin
  if FIsInBuildInfo then
    btnCancel.Caption := '&Cancel'
  else
  if FIsNewModule then
    btnCancel.Caption := 'Show History'
  else
    btnCancel.Caption := '&Refresh';
end;

procedure TJVCSLineHistoryFrm.SetExtensionControls;
var
  I, Idx: Integer;
begin
  Idx := 0;
  for I := 0 to Pred(cbxHighlighter.Items.Count) do
    if cbxHighlighter.Items.Objects[I] = FHighlighters.GetHighlighterByExtension(FSelectedExtension) then
    begin
      Idx := I;
      Break;
    end;
  cbxHighlighter.ItemIndex := Idx;
  cbxHighlighterChange(nil);
end;

procedure TJVCSLineHistoryFrm.cbMemberChange(Sender: TObject);
begin
  if not FIsInBuildInfo then
    if FSelectedExtension <> cbMember.Text then
    begin
      FSelectedExtension := cbMember.Text;
      FIsNewModule := True;
      SetButtonCaption;
      SetExtensionControls;
    end;
end;

procedure TJVCSLineHistoryFrm.SpeedButton1Click(Sender: TObject);
begin
  Panel2.Visible := SpeedButton1.Down;
end;

procedure TJVCSLineHistoryFrm.cbDateFormatChange(Sender: TObject);
var
  Fmt: string;
  Idx: Integer;
begin
  if not FInSetSettings then
  begin
    Fmt := '';
    if (cbDateFormat.ItemIndex > -1) and (cbDateFormat.ItemIndex < cbDateFormat.Items.Count) then
    begin
      Idx := Integer(cbDateFormat.Items.Objects[cbDateFormat.ItemIndex]);
      if (Idx > -1) and (Idx < FDateFormatList.Count) then
        Fmt := FDateFormatList[Idx];
    end;
    FSettings.DateFormat := Fmt;
    FLineHistory.Settings := FSettings;
    with TGutterInfoPlugin(FSynEditPlugin) do
    begin
      UpdateGutterWidth;
    end;
    FSynEdit.Invalidate;
    DoSettingsChanged;
  end;
end;

procedure TJVCSLineHistoryFrm.Search(ABackwards: Boolean);
var
  Options: TSynSearchOptions;
begin
  actSearchNext.Enabled := FSearchText <> '';
  actSearchPrev.Enabled := actSearchNext.Enabled;
  if actSearchNext.Enabled then
  begin
    Options := [];
    if ABackwards then
      Include(Options, ssoBackwards);
    if frMatchCase in FindDialog1.Options then
      Include(Options, ssoMatchCase);
    if frWholeWord in FindDialog1.Options then
      Include(Options, ssoWholeWord);
    {
    if not fSearchFromCaret then
      Include(Options, ssoEntireScope);
    if gbSearchSelectionOnly then
      Include(Options, ssoSelectedOnly);
    }
    if FSynEdit.SearchReplace(FSearchText, '', Options) = 0 then
    begin
      MessageBeep(MB_ICONASTERISK);
      if ssoBackwards in Options then
        FSynEdit.BlockEnd := FSynEdit.BlockBegin
      else
        FSynEdit.BlockBegin := FSynEdit.BlockEnd;
      FSynEdit.CaretXY := FSynEdit.BlockBegin;
    end;
  end;
end;

procedure TJVCSLineHistoryFrm.actSearchExecute(Sender: TObject);
begin
  FindDialog1.Execute;
  actSearchNext.Enabled := FSearchText <> '';
  actSearchPrev.Enabled := actSearchNext.Enabled;
end;

procedure TJVCSLineHistoryFrm.actSearchNextExecute(Sender: TObject);
begin
  Search(False);
end;

procedure TJVCSLineHistoryFrm.actSearchPrevExecute(Sender: TObject);
begin
  Search(True);
end;

procedure TJVCSLineHistoryFrm.FindDialog1Find(Sender: TObject);
begin
  if FindDialog1.FindText <> '' then
  begin
    FSearchText := FindDialog1.FindText;
    Search(not (frDown in FindDialog1.Options));
  end;
end;

procedure TJVCSLineHistoryFrm.SpeedButton2Click(Sender: TObject);
begin
  if memComment.Visible and (memComment.Align = alTop) then
    FLastCommentHeight := memComment.Height;
  splComment.Visible := SpeedButton2.Down or SpeedButton3.Down;
  pnlRight.Visible := splComment.Visible;
  pnlRight.Left := splComment.Left + 1;
  memComment.Visible := SpeedButton2.Down;
  pnlSummary.Visible := SpeedButton3.Down;
  if not SpeedButton3.Down then
    memComment.Align := alClient
  else
  begin
    memComment.Align := alTop;
    if memComment.Height >= pnlRight.Height then
      memComment.Height := FLastCommentHeight;
  end;
  splCommentVst.Visible := SpeedButton2.Down and SpeedButton3.Down;
  splCommentVst.Top := memComment.Top + memComment.Height;
  pnlSummary.Top := splCommentVst.Top + 1;
end;

procedure TJVCSLineHistoryFrm.cbxHighlighterChange(Sender: TObject);
var
  CurrentHighlighter: TJVCSLineHistoryHighlighter;
begin
  CurrentHighlighter := nil;
  if cbxHighlighter.ItemIndex <> -1 then
    CurrentHighlighter := TJVCSLineHistoryHighlighter(cbxHighlighter.Items.Objects[cbxHighlighter.ItemIndex]);
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
end;

procedure TJVCSLineHistoryFrm.vstSummaryInitNode(Sender: TBaseVirtualTree;
  ParentNode, Node: PVirtualNode;
  var InitialStates: TVirtualNodeInitStates);
var
  NodeData: ^TObject;
  HasChildren: Boolean;
begin
  NodeData := Sender.GetNodeData(Node);
  if Sender.GetNodeLevel(Node) = 0 then
  begin
    NodeData^ := nil;
    case Node^.Index of
      0: HasChildren := FLineHistorySummary.RevisionCount > 0;
      1: HasChildren := FLineHistorySummary.UserCount > 0;
      else
        HasChildren := False;
    end;
    if HasChildren then
    begin
      Include(InitialStates, ivsHasChildren);
      Include(InitialStates, ivsExpanded);
    end;
  end
  else
  begin
    case Node^.Parent^.Index of
      0: NodeData^ := FLineHistorySummary.RevisionSummary[Node^.Index];
      1: NodeData^ := FLineHistorySummary.UserSummary[Node^.Index];
    end;
  end;
end;

procedure TJVCSLineHistoryFrm.vstSummaryInitChildren(
  Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
begin
  if Sender.GetNodeLevel(Node) = 0 then
    case Node^.Index of
      0: ChildCount := FLineHistorySummary.RevisionCount;
      1: ChildCount := FLineHistorySummary.UserCount;
    end;
end;

procedure TJVCSLineHistoryFrm.vstSummaryGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
var
  NodeData: ^TObject;
  RevisionSummary: TJVCSLineHistoryRevisionSummary;
  UserSummary: TJVCSLineHistoryUserSummary;
begin
  CellText := '';
  case Sender.GetNodeLevel(Node) of
    0:
    begin
      if Column = 0 then
        case Node^.Index of
          0: CellText := 'Revision summary';
          1: CellText := 'User summary';
        end;
    end;
    1:
    begin
      NodeData := Sender.GetNodeData(Node);
      if Assigned(NodeData^) then
        case Node^.Parent^.Index of
          0:
          begin
            RevisionSummary := TJVCSLineHistoryRevisionSummary(NodeData^);
            case Column of
              0: CellText := RevisionSummary.LineHistoryRevision.RevisionStr;
              1: CellText := IntToStr(RevisionSummary.LineCount);
              2: CellText := Format('%.1f', [RevisionSummary.Percent]);
            end;
          end;
          1:
          begin
            UserSummary := TJVCSLineHistoryUserSummary(NodeData^);
            case Column of
              0: CellText := UserSummary.VisibleUserName;
              1: CellText := IntToStr(UserSummary.LineCount);
              2: CellText := Format('%.1f', [UserSummary.Percent]);
            end;
          end;
        end;
    end;
  end;
end;

procedure TJVCSLineHistoryFrm.vstSummaryBeforeItemErase(
  Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
  ItemRect: TRect; var ItemColor: TColor;
  var EraseAction: TItemEraseAction);
var
  NodeData: ^TObject;
  Idx: Integer;
begin
  if Sender.GetNodeLevel(Node) = 0 then
  begin
    EraseAction := eaColor;
    ItemColor :=  clBtnFace;
  end
  else
  begin
    NodeData := Sender.GetNodeData(Node);
    if Assigned(NodeData) then
    begin
      if NodeData^ is TJVCSLineHistoryRevisionSummary then
      begin
        EraseAction := eaColor;
        ItemColor := GetRevisionColor(TJVCSLineHistoryRevisionSummary(NodeData^).LineHistoryRevision).RevisionColor;
      end
      else
      if NodeData^ is TJVCSLineHistoryUserSummary then
      begin
        Idx := FColorList.IndexOf(TJVCSLineHistoryUserSummary(NodeData^).UserName);
        if Idx <> -1 then
        begin
          EraseAction := eaColor;
          ItemColor := TColor(FColorList.Objects[Idx]);
        end;
      end;
    end;
  end;
end;

procedure TJVCSLineHistoryFrm.vstSummaryCompareNodes(
  Sender: TBaseVirtualTree; Node1, Node2: PVirtualNode;
  Column: TColumnIndex; var Result: Integer);
var
  NodeData1, NodeData2: ^TObject;
begin
  if Sender.GetNodeLevel(Node1) = 0 then
    Result := 0
  else
  begin
    NodeData1 := Sender.GetNodeData(Node1);
    NodeData2 := Sender.GetNodeData(Node2);
    if Assigned(NodeData1^) and Assigned(NodeData2^) and (NodeData1^.ClassType = NodeData2^.ClassType) then
    begin
      if NodeData1^ is TJVCSLineHistoryRevisionSummary then
      begin
        case Column of
          0: Result := TJVCSLineHistoryRevisionSummary(NodeData1^).LineHistoryRevision.RevisionID -
               TJVCSLineHistoryRevisionSummary(NodeData2^).LineHistoryRevision.RevisionID;
          1,2: begin
               Result := TJVCSLineHistoryRevisionSummary(NodeData1^).LineCount -
                 TJVCSLineHistoryRevisionSummary(NodeData2^).LineCount;
               if Result = 0 then
                 Result := TJVCSLineHistoryRevisionSummary(NodeData1^).LineHistoryRevision.RevisionID -
                   TJVCSLineHistoryRevisionSummary(NodeData2^).LineHistoryRevision.RevisionID;
             end;
        end;
      end
      else
      if NodeData1^ is TJVCSLineHistoryUserSummary then
      begin
        case Column of
          0: Result := CompareStr(TJVCSLineHistoryUserSummary(NodeData1^).UserName, TJVCSLineHistoryUserSummary(NodeData2^).UserName);
          1,2: Result := TJVCSLineHistoryUserSummary(NodeData1^).LineCount - TJVCSLineHistoryUserSummary(NodeData2^).LineCount;
        end;
      end;
    end
    else
      Result := 0;
  end;
end;

procedure TJVCSLineHistoryFrm.vstSummaryHeaderClick(Sender: TVTHeader;
  Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if Button = mbLeft then
  begin
    with Sender do
    begin
      if SortColumn <> Column then
      begin
        SortColumn := Column;
        SortDirection := sdAscending;
      end
      else
      case SortDirection of
        sdAscending:
          SortDirection := sdDescending;
        sdDescending:
          SortColumn := NoColumn;
      end;
    end;
  end;
end;

procedure TJVCSLineHistoryFrm.vstSummaryFocusChanged(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
begin
  SetSummaryNextLineButtonState;
end;

procedure TJVCSLineHistoryFrm.SetSettings(AValue: TJVCSLineHistorySettings);
var
  I, Idx: Integer;
  Fmt: string;
begin
  FInSetSettings := True;
  try
    if Assigned(AValue) then
    begin
      FSettings.Assign(AValue);
      cbShowRevisionColorBar.Checked := FSettings.ColorBarOrderList.IndexOf(Pointer(1)) <> -1;
      cbShowDateColorBar.Checked := FSettings.ColorBarOrderList.IndexOf(Pointer(2)) <> -1;
      cbShowUserColorBar.Checked := FSettings.ColorBarOrderList.IndexOf(Pointer(3)) <> -1;
      {$IFDEF LINEINFOEX}
      cbShowRevisionCountColorBar.Checked := FSettings.ColorBarOrderList.IndexOf(Pointer(4)) <> -1;
      cbShowFirstRevisionColorBar.Checked := FSettings.ColorBarOrderList.IndexOf(Pointer(5)) <> -1;
      {$ENDIF LINEINFOEX}
      cbLineNumbers.Checked := FSettings.ShowLineNumbers;
      cbShowRevisionText.Checked := FSettings.ShowRevisionInfoText;
      cbShowRevisionColor.Checked := FSettings.ShowRevisionInfoColor;
      cbSuppressRevisionTextZeroDot.Checked := FSettings.SuppressRevisionTextZeroDot;
      cbShowDateText.Checked := FSettings.ShowDateInfoText;
      cbShowDateColor.Checked := FSettings.ShowDateInfoColor;
      cbShowUserText.Checked := FSettings.ShowUserInfoText;
      cbShowUserColor.Checked := FSettings.ShowUserInfoColor;
      {$IFDEF LINEINFOEX}
      cbShowRevisionCountText.Checked := FSettings.ShowRevisionCountInfoText;
      cbShowRevisionCountColor.Checked := FSettings.ShowRevisionCountInfoColor;
      cbShowFirstRevisionText.Checked := FSettings.ShowFirstRevisionInfoText;
      cbShowFirstRevisionColor.Checked := FSettings.ShowFirstRevisionInfoColor;
      {$ENDIF LINEINFOEX}
      Fmt := '';
      Idx := FDateFormatList.IndexOf(FSettings.DateFormat);
      if Idx = -1 then
        Idx := 0;
      Fmt := FDateFormatList[Idx];
      for I := 0 to Pred(cbDateFormat.Items.Count) do
        if cbDateFormat.Items.Objects[I] = TObject(Idx) then
        begin
          cbDateFormat.ItemIndex := I;
          Break;
        end;
      FLineHistory.Settings := FSettings;
      if (FSettings.LineColorMode >= 0) and (FSettings.LineColorMode < cbLineColorMode.Items.Count) then
        cbLineColorMode.ItemIndex := FSettings.LineColorMode;
      if (FSettings.PaintMethod >= 0) and (FSettings.PaintMethod < cbPaintMethod.Items.Count) then
        cbPaintMethod.ItemIndex := FSettings.PaintMethod;
      UpdateAll;
    end;
  finally
    FInSetSettings := False;
  end;
end;

procedure TJVCSLineHistoryFrm.SetSummaryNextLineButtonState;
var
  NodeLevel: Integer;
  NodeData: ^TObject;
  S: string;
begin
  NodeLevel := vstSummary.GetNodeLevel(vstSummary.FocusedNode);
  spBtnPrevLine.Enabled := NodeLevel = 1;
  spBtnNextLine.Enabled := spBtnPrevLine.Enabled;
  if NodeLevel = 1 then
  begin
    NodeData := vstSummary.GetNodeData(vstSummary.FocusedNode);
    if Assigned(NodeData) then
    begin
      if TObject(NodeData^) is TJVCSLineHistoryRevisionSummary then
        S := TJVCSLineHistoryRevisionSummary(NodeData^).LineHistoryRevision.RevisionStr
      else
      if TObject(NodeData^) is TJVCSLineHistoryUserSummary then
        S := TJVCSLineHistoryUserSummary(NodeData^).UserName;
    end;
  end;
  lbJumpLineInfo.Caption := S;
end;

procedure TJVCSLineHistoryFrm.UpdateAll;
begin
  FRevisionColorList.Clear;
  {$IFDEF LINEINFOEX}
  FMaxLineRevisionCount := -1;
  FRevisionCountColorList.Clear;
  {$ENDIF LINEINFOEX}  
  FColorList.Clear;
  FColorList.AddObject('', TObject(GetNextColor));
  FLineHistory.Settings := FSettings;
  TGutterInfoPlugin(FSynEditPlugin).Settings := FSettings;
  FSynEdit.Invalidate;
  FCachedColorBar.Width := 0;
  UpdateColorBars;
  FLineHistorySummary.UpdateVisibleStrings(FLineHistory);
  vstSummary.Invalidate;
end;

procedure TJVCSLineHistoryFrm.spBtnPrevLineClick(Sender: TObject);
var
  NodeData: ^TObject;
  I, Direction: Integer;
  Found: Boolean;
begin
  if Assigned(vstSummary.FocusedNode) then
  begin
    NodeData := vstSummary.GetNodeData(vstSummary.FocusedNode);
    if Assigned(NodeData) then
    begin
      if Sender = spBtnPrevLine then
        Direction := -1
      else
        Direction := 1;
      I := FSynEdit.CaretY - 1;
      I := I + Direction;
      Found := False;
      while (not Found) and (I >= 0) and (I < FLineHistory.Lines.Count) do
      begin
        if Assigned(FLineHistory.Lines.Objects[I]) and
          (FLineHistory.Lines.Objects[I] is TJVCSLineHistoryRevision) then
        begin
          if NodeData^ is TJVCSLineHistoryRevisionSummary then
            Found := FLineHistory.Lines.Objects[I] = TJVCSLineHistoryRevisionSummary(NodeData^).LineHistoryRevision
          else
          if NodeData^ is TJVCSLineHistoryUserSummary then
            Found := TJVCSLineHistoryRevision(FLineHistory.Lines.Objects[I]).UserStr = TJVCSLineHistoryUserSummary(NodeData^).UserName
          else
            Found := True;
        end
        else
          Found := True;
        if not Found then
          I := I + Direction
        else
          I := I + 1;
      end;
      if Found and (I >= 0) and (I < FSynEdit.Lines.Count) then
        FSynEdit.CaretY := I;
    end;
  end;
end;

procedure TJVCSLineHistoryFrm.SpeedButton4Click(Sender: TObject);
var
  MRes: Integer;
  OldSettings: TJVCSLineHistorySettings;
begin
  JVCSLineHistorySettingsDlg := TJVCSLineHistorySettingsDlg.Create(Application);
  try
    OldSettings := TJVCSLineHistorySettings.Create;
    try
      OldSettings.Assign(FSettings);
      JVCSLineHistorySettingsDlg.Settings := FSettings;
      JVCSLineHistorySettingsDlg.OnApply := HandleApplySettings;
      MRes := JVCSLineHistorySettingsDlg.ShowModal;
      if MRes = mrOK then
      begin
        FSettings.Assign(JVCSLineHistorySettingsDlg.Settings);
        UpdateAll;
        DoSettingsChanged;
      end
      else
      if MRes = mrCancel then
      begin
        FSettings.Assign(OldSettings);
        UpdateAll;
      end;
    finally
      OldSettings.Free;
    end;
  finally
    JVCSLineHistorySettingsDlg.Free;
  end;
end;

procedure TJVCSLineHistoryFrm.PaintBox1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Line: Integer;
begin
  if (FLineHistory.Lines.Count > 0) and (PaintBox1.Height > 0) then
  begin
    Line := (FLineHistory.Lines.Count * Y) div PaintBox1.Height;
    FSynEdit.TopLine := Line;
    FSynEdit.CaretY := Line;
  end;
end;

procedure TJVCSLineHistoryFrm.cbPaintMethodChange(Sender: TObject);
begin
  if not FInSetSettings then
  begin
    FSettings.PaintMethod := cbPaintMethod.ItemIndex;
    TGutterInfoPlugin(FSynEditPlugin).Settings := FSettings;
    FSynEdit.Invalidate;
    DoSettingsChanged;
  end;
end;

end.

