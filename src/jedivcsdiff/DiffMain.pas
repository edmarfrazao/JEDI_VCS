(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: DiffMain.pas

The Initial Developer of the original Code (FVCSDiff) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDIVCSDiff: Thomas Huber (Thomas_D_Huber@gmx.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:                                                                                    

2003/01/31  THuber    - 1st Migrationstep from FVCSDiff code to JEDIVCSDiff
                        now using synedit components
2003/03/09  THuber    - use latest synEdit CVS source from sourceforge
                      - introduced memchecker
2003/05/26  THuber    - fixed range check error for case:
                        * Ignore spaces checked
                        * String ends with (at least) 2 spaces
2004/01/17  THuber    - fixed dfm according to used synedit version from
                        demos.href.com.
2004/01/18  USchuster - replaced about message with new about dialog
                      - now with constant for message box caption
2004/02/24  USchuster - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
                      - minor style cleaning (casing)
2004/04/12  THuber    - use chm help instead of hlp help
2004/07/12  USchuster - TabWidth is now configurable (mantis #1945)
                      - minor style cleaning (casing and comments)
2004/11/12  USchuster - added dxGetText support for localization with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/11/14  USchuster - added language menu item below "Properties" and set the
                        default textdomain to "jedivcsdiff"
2005/06/04  USchuster - set memo charset to DEFAULT_CHARSET(necessary for LANGUAGE version)
2005/07/02  CSchuette - some minor changes to increase compare speed dramatically
2006/11/05  USchuster - changes for SynEdit 2.0.3
2006/11/06  USchuster - more changes for SynEdit 2.0.3(added missing search engine)
2007/04/06  USchuster - changes for SynEdit 2.0.5
2008/01/13  USchuster - applied fix for POSIX files by "Gergely" (Mantis #4330)
2008/12/27  THuber    - Introduced theming, better VISTA support, cosmetic changes
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit DiffMain;

{$I jedi.inc}
{$I compopt.inc}

{$IFDEF DELPHI6_UP}
  {$WARN UNIT_PLATFORM OFF}
  {$WARN SYMBOL_PLATFORM OFF}
{$ENDIF DELPHI6_UP}

interface

uses
  Windows, Messages, Forms, SysUtils, Graphics, Menus, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls, Buttons, ImgList, Controls, Classes, ActnList,
  JvCombobox, JvComponent, JvMRUList,
  SynHighlighterCss, SynHighlighterHtml,
  SynHighlighterGeneral,
  SynEditHighlighter, SynHighlighterJScript,
  SynHighlighterPas, SynEditTypes,
  SynEdit, ToolWin, dfsStatusBar, SynHighlighterXML,
  SynHighlighterAsm, SynHighlighterVB, SynHighlighterTclTk,
  SynHighlighterSQL, SynHighlighterPython, SynHighlighterProgress,
  SynHighlighterPHP, SynHighlighterPerl, SynHighlighterBat,
  SynHighlighterVBScript, SynHighlighterM3, SynHighlighterJava,
  SynHighlighterInno, SynHighlighterIni, SynHighlighterFoxpro,
  SynHighlighterFortran, SynHighlighterIDL, SynHighlighterCPM,
  SynHighlighterCAC, SynHighlighterCache, SynHighlighterCpp,
  SynHighlighterDfm, JvExStdCtrls, SynEditMiscClasses, SynEditSearch,
  {$IFNDEF  DELPHI7_UP}
    ThemeMgr,
  {$ENDIF}
  JvComponentBase;

const
  RegDiffBase     = 'Software\JEDI\JEDIVCSDiff\';
  RegDiffMRU      = RegDiffBase + 'MRU';
  RegDiffOptions  = RegDiffBase + 'Options';
  cMessageBoxCaption = 'JVCS Diff';

type
  Tfm_Main = class(TForm)
    OpenDialog1: TOpenDialog;
    StartTimer: TTimer;
    SaveDialog1: TSaveDialog;
    mwPasSyn1: TSynPasSyn;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Edit1: TMenuItem;
    Help1: TMenuItem;
    dfsStatusBar1: TdfsStatusBar;
    Panel7: TPanel;
    ActionList1: TActionList;
    acBrowseSource: TAction;
    acBrowseTarget: TAction;
    acNextDiff: TAction;
    acPreviousDiff: TAction;
    MarkImages: TImageList;
    ToolImages: TImageList;
    N7: TMenuItem;
    N8: TMenuItem;
    acSaveChanges: TAction;
    N9: TMenuItem;
    SaveAs2: TMenuItem;
    N10: TMenuItem;
    Bookmarks1: TMenuItem;
    ClearAll1: TMenuItem;
    N12: TMenuItem;
    GoTo1: TMenuItem;
    Bookmark91: TMenuItem;
    Bookmark81: TMenuItem;
    Bookmark71: TMenuItem;
    Bookmark61: TMenuItem;
    Bookmark51: TMenuItem;
    Bookmark41: TMenuItem;
    Bookmark31: TMenuItem;
    Bookmark11: TMenuItem;
    Bookmark01: TMenuItem;
    Define1: TMenuItem;
    Bookmark92: TMenuItem;
    Bookmark82: TMenuItem;
    Bookmark72: TMenuItem;
    Bookmark62: TMenuItem;
    Bookmark52: TMenuItem;
    Bookmark42: TMenuItem;
    Bookmark32: TMenuItem;
    Bookmark21: TMenuItem;
    Bookmark12: TMenuItem;
    Bookmark02: TMenuItem;
    Bookmark22: TMenuItem;
    N13: TMenuItem;
    GoTo2: TMenuItem;
    About1: TMenuItem;
    N14: TMenuItem;
    acFirstDiff: TAction;
    acLastDiff: TAction;
    FindDialog1: TFindDialog;
    N1: TMenuItem;
    mwGeneralSyn1: TSynGeneralSyn;
    hkHTMLSyn1: TSynHTMLSyn;
    mwCSSSyn1: TSynCssSyn;
    mwJScriptSyn1: TSynJScriptSyn;
    ReplaceDialog1: TReplaceDialog;
    DisableBinaryFileChecking1: TMenuItem;
    N2: TMenuItem;
    ToolBar1: TToolBar;
    tbEnableEditor: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton15: TToolButton;
    ToolButton16: TToolButton;
    ToolButton17: TToolButton;
    ToolButton19: TToolButton;
    ToolButton20: TToolButton;
    ToolButton21: TToolButton;
    cbxHighlighter: TComboBox;
    Panel2: TPanel;
    Bevel1: TBevel;
    Panel5: TPanel;
    Bevel2: TBevel;
    ToolBar3: TToolBar;
    ToolButton18: TToolButton;
    ToolButton22: TToolButton;
    ToolButton23: TToolButton;
    ToolButton24: TToolButton;
    ToolButton27: TToolButton;
    ToolButton33: TToolButton;
    ToolButton34: TToolButton;
    acFlip: TAction;
    acLastCompare: TAction;
    acEnableEditor: TAction;
    acUndo: TAction;
    acRedo: TAction;
    acSearch: TAction;
    acReplace: TAction;
    acSearchPrev: TAction;
    acSearchNext: TAction;
    acReport: TAction;
    acHighLightProp: TAction;
    acClose: TAction;
    acCompare: TAction;
    acIgWSpace: TAction;
    acIgCase: TAction;
    acIgLFCR: TAction;
    popmCompare: TPopupMenu;
    IgnoreWhiteSpace1: TMenuItem;
    IgnoreCase1: TMenuItem;
    acIgLFCR1: TMenuItem;
    popmSearch: TPopupMenu;
    SearchPrevious1: TMenuItem;
    SearchNext1: TMenuItem;
    SelectBaseVersion1: TMenuItem;
    SelectTarget1: TMenuItem;
    Compare1: TMenuItem;
    RepeatLastCompare1: TMenuItem;
    acEnableEditor1: TMenuItem;
    SaveChanges1: TMenuItem;
    IgnoreWhiteSpace2: TMenuItem;
    IgnoreCase2: TMenuItem;
    acIgLFCR2: TMenuItem;
    Exit1: TMenuItem;
    ReportDifference1: TMenuItem;
    Undo1: TMenuItem;
    Redo1: TMenuItem;
    CustomizeHighlighter1: TMenuItem;
    Search1: TMenuItem;
    SearchNext2: TMenuItem;
    SearchPrevious2: TMenuItem;
    Replace1: TMenuItem;
    FirstDifference1: TMenuItem;
    NextDifference1: TMenuItem;
    PreviousDifference1: TMenuItem;
    LastDifference1: TMenuItem;
    ToolButton1: TToolButton;
    ToolButton25: TToolButton;
    acHelp: TAction;
    HelpTopics1: TMenuItem;
    EditorProperties1: TMenuItem;
    popmEditor: TPopupMenu;
    acEditCopy: TAction;
    acEditCut: TAction;
    acEditPaste: TAction;
    Copy1: TMenuItem;
    Cut1: TMenuItem;
    Paste1: TMenuItem;
    Properties1: TMenuItem;
    Copy2: TMenuItem;
    Cut2: TMenuItem;
    Paste2: TMenuItem;
    N3: TMenuItem;
    Delete1: TMenuItem;
    N4: TMenuItem;
    ShowResultDialog1: TMenuItem;
    N5: TMenuItem;
    DeleteFile1: TMenuItem;
    ToolButton26: TToolButton;
    acSaveCompare: TAction;
    SaveRecompare1: TMenuItem;
    CopyLinetoleftEditor1: TMenuItem;
    N6: TMenuItem;
    acHardSpace: TAction;
    HardSpaceA0isWhiteSpace1: TMenuItem;
    HardSpaceA0isWhiteSpace2: TMenuItem;
    ShowDiffasHexCode1: TMenuItem;
    N11: TMenuItem;
    Panel6: TPanel;
    Panel4: TPanel;
    Splitter1: TSplitter;
    Panel1: TPanel;
    mwceSource: TSynEdit;
    SourceHeader: TPanel;
    SourceFooter: TPanel;
    Panel3: TPanel;
    mwceTarget: TSynEdit;
    TargetHeader: TPanel;
    TargetFooter: TPanel;
    HexViewPanel: TPanel;
    Panel8: TPanel;
    spBtnHexViewClose: TSpeedButton;
    HexView: TRichEdit;
    HexViewLabel: TLabel;
    spBtnHexViewRight: TSpeedButton;
    spBtnHexViewLeft: TSpeedButton;
    acIgHTML: TAction;
    IgnoreHTMLTags1: TMenuItem;
    IgnoreHTMLTags2: TMenuItem;
    WholeLinePanel: TPanel;
    Panel9: TPanel;
    spBtnLineViewClose: TSpeedButton;
    WholeLineLabel: TLabel;
    spBtnLineViewRight: TSpeedButton;
    spBtnLineViewLeft: TSpeedButton;
    LineView: TMemo;
    ShowcompleteLines1: TMenuItem;
    JvMruListSource: TJvMruList;
    SynDfmSyn1: TSynDfmSyn;
    SynCppSyn1: TSynCppSyn;
    SynCacheSyn1: TSynCacheSyn;
    SynCACSyn1: TSynCACSyn;
    SynCPMSyn1: TSynCPMSyn;
    SynIdlSyn1: TSynIdlSyn;
    SynFortranSyn1: TSynFortranSyn;
    SynFoxproSyn1: TSynFoxproSyn;
    SynIniSyn1: TSynIniSyn;
    SynInnoSyn1: TSynInnoSyn;
    SynJavaSyn1: TSynJavaSyn;
    SynM3Syn1: TSynM3Syn;
    SynVBScriptSyn1: TSynVBScriptSyn;
    SynBatSyn1: TSynBatSyn;
    SynPerlSyn1: TSynPerlSyn;
    SynPHPSyn1: TSynPHPSyn;
    SynProgressSyn1: TSynProgressSyn;
    SynPythonSyn1: TSynPythonSyn;
    SynSQLSyn1: TSynSQLSyn;
    SynTclTkSyn1: TSynTclTkSyn;
    SynVBSyn1: TSynVBSyn;
    SynAsmSyn1: TSynAsmSyn;
    SynXMLSyn1: TSynXMLSyn;
    rcbSource: TJvComboBox;
    rcbTarget: TJvComboBox;
    JvMruListTarget: TJvMruList;
    SynEditSearch1: TSynEditSearch;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure StartTimerTimer(Sender: TObject);
    procedure rcbSource_orgChange(Sender: TObject);
    procedure spBtnAboutClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure mwceSourcePaint(Sender: TObject; ACanvas: TCanvas);
    procedure mwceTargetPaint(Sender: TObject; ACanvas: TCanvas);
    procedure mwceSourceChange(Sender: TObject);
    procedure mwceSourceKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure acNextDiffExecute(Sender: TObject);
    procedure acPreviousDiffExecute(Sender: TObject);
    procedure mwceSourceClick(Sender: TObject);
    procedure acSaveChangesExecute(Sender: TObject);
    procedure acBrowseTargetExecute(Sender: TObject);
    procedure acBrowseSourceExecute(Sender: TObject);
    procedure mwceSourceEnter(Sender: TObject);
    procedure Bookmark02Click(Sender: TObject);
    procedure Bookmark01Click(Sender: TObject);
    procedure AlignSplitter1Click(Sender: TObject);
    procedure SaveAs2Click(Sender: TObject);
    procedure ClearAll1Click(Sender: TObject);
    procedure acLastDiffExecute(Sender: TObject);
    procedure acFirstDiffExecute(Sender: TObject);
    procedure cbxHighlighterChange(Sender: TObject);
    procedure FindDialog1Find(Sender: TObject);
    procedure ReplaceDialog1Replace(Sender: TObject);
    procedure DisableBinaryFileChecking1Click(Sender: TObject);
    procedure acEnableEditorExecute(Sender: TObject);
    procedure acUndoExecute(Sender: TObject);
    procedure acRedoExecute(Sender: TObject);
    procedure acCompareExecute(Sender: TObject);
    procedure acIgWSpaceExecute(Sender: TObject);
    procedure acIgCaseExecute(Sender: TObject);
    procedure acSearchExecute(Sender: TObject);
    procedure acSearchPrevExecute(Sender: TObject);
    procedure acReplaceExecute(Sender: TObject);
    procedure acReportExecute(Sender: TObject);
    procedure acHighLightPropExecute(Sender: TObject);
    procedure acCloseExecute(Sender: TObject);
    procedure acLastCompareExecute(Sender: TObject);
    procedure acFlipExecute(Sender: TObject);
    procedure acIgLFCRExecute(Sender: TObject);
    procedure acHelpExecute(Sender: TObject);
    procedure EditorProperties1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure acEditCopyExecute(Sender: TObject);
    procedure acEditCutExecute(Sender: TObject);
    procedure acEditPasteExecute(Sender: TObject);
    procedure popmEditorPopup(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure ShowResultDialog1Click(Sender: TObject);
    procedure acSaveCompareExecute(Sender: TObject);
    procedure CopyLinetoleftEditor1Click(Sender: TObject);
    procedure acHardSpaceExecute(Sender: TObject);
    procedure ShowDiffasHexCode1Click(Sender: TObject);
    procedure spBtnHexViewCloseClick(Sender: TObject);
    procedure spBtnHexViewRightClick(Sender: TObject);
    procedure spBtnHexViewLeftClick(Sender: TObject);
    procedure acIgHTMLExecute(Sender: TObject);
    procedure ShowcompleteLines1Click(Sender: TObject);
    procedure spBtnLineViewLeftClick(Sender: TObject);
    procedure spBtnLineViewRightClick(Sender: TObject);
    procedure spBtnLineViewCloseClick(Sender: TObject);
    procedure JvMruListSourceEnumText(Sender: TObject; Value: string;
      Index: Integer);
    procedure JvMruListTargetEnumText(Sender: TObject; Value: string;
      Index: Integer);
    procedure FormDestroy(Sender: TObject);
  private
    {$IFNDEF  DELPHI7_UP}
      FThemeManager : TThemeManager;
    {$ENDIF}
    ActiveEditorView: TSynEdit;
    FileNames: array [1..2] of string;
    SourceFiles: array [1..2] of Textfile;
    LastLine: array [1..2] of Integer;
    SyncMarker,
    SourceLineNr,
    SourceLineCount,
    DeltaLines,
    DeltaBlocks: Integer;
    ActDir,
    SourceComment,
    TargetComment: string;
    CompareInProgess,
    AutoCompare,
    EnableLeftEdit,
    EnableRightEdit: Boolean;
    function  SaveSourceChanges: Boolean;
    procedure SaveChanges(SaveEditor: TSynEdit; const FileName: string);
    procedure ClearEditorWindows;
    procedure EnumerateHighlighters;
    procedure SetHighLighter;
    procedure LoadInfo(const Sender: TObject);
    procedure EnableNavButtons;
    procedure ShowStatusBarGauge(const ShowGauge, Indeterminate: Boolean);
    procedure StatusBarGaugePos(Value: Word);
    function  GetCRCChkSum(const FileName: string): string;
    function  GetAttrStrEx(const FileName: string): string;
    function  StripString(const S: string): string;
    function  StripWhiteSpace(const S: string): string;
    function  StripCRLF(const S: string): string;
    function  StripHTMLTags(const S: string): string;
    procedure MarkDiffLine(const ALine: Integer);
    procedure ReadLines(EditorWin, N: Integer);
    procedure InsertEmptyLines(const EditorWin, AtLine, nLines: Integer);
    function  ReadUntilDiff: Boolean;
    function  SearchLines(c1, r1, c2, r2a, r2b, N: Integer): Integer;
    function  ReSync: Boolean;
    procedure GiveUp;
    function  GetPreviousDiff: Integer;
    function  GetNextDiff: Integer;
    function  IsTextFile(const FileName: string): Boolean;
    procedure DoCompare;
    procedure SaveSettings;
    procedure ShowHexDiff(const BaseLineText, TargetLineText: string);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WMSyscommand(var Message: TWmSysCommand); message WM_SYSCOMMAND;
    procedure WMActivate(var Message: TWMActivate);
  public
  end;

var
  fm_Main: Tfm_Main;
  WhiteSpace: set of Char = [#9, #32];
  LineEnd: set of Char = [#10, #13];

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext, JVCSLanguage,
  {$ENDIF LANGUAGE}
  ShellAPI, Registry, CheckSum, DiffSimpleReport, ItemProp,
  DiffHelp, DiffEditorProp, DiffHLProp, JclFileUtils, DiffAbout, JVCSDiffResources;

{$R *.dfm}

//------------------------------------------------------------------------------

procedure Tfm_Main.FormCreate(Sender: TObject);
var
  FontSize: Integer;
  FontName: string;
  CmntSet: TCommentStyles;
  JclFileVersionInfo: TJclFileVersionInfo;
begin
  try
    GetDir(0, ActDir);
    {$IFNDEF  DELPHI7_UP}
      FThemeManager := TThemeManager.Create(self);
    {$ENDIF ~DELPHI7_UP}
    // fixes VISTA Taskbarsupport
    ShowWindow(Application.Handle, SW_HIDE);
    SetWindowLong ( Application.Handle, GWL_EXSTYLE
                  , GetWindowLong(Application.Handle, GWL_EXSTYLE) and not WS_EX_APPWINDOW or WS_EX_TOOLWINDOW);
    ShowWindow(Application.Handle, SW_SHOW);
    with TRegistry.Create do
    begin
      try
        RootKey := HKEY_CURRENT_USER;
        OpenKeyReadOnly(RegDiffBase + 'Window');
        if ValueExists('X') then
        begin
          Top := ReadInteger('Y');
          Left := ReadInteger('X');
          Width := ReadInteger('W');
          Height := ReadInteger('H');
        end
        else
        begin
          Top := (Screen.Height - Height) div 2;
          Left := (Screen.Width - Width) div 2;
        end;
        if ValueExists('SplitterPos') then
          Panel3.Width := ReadInteger('SplitterPos')
        else
          Panel3.Width := Panel4.Width div 2;
        CloseKey;

        OpenKeyReadOnly(RegDiffOptions);
        if ValueExists('DisableBinaryFileChecking') then
          DisableBinaryFileChecking1.Checked :=
            ReadBool('DisableBinaryFileChecking')
        else
          DisableBinaryFileChecking1.Checked := False;
        if ValueExists('IgnoreWhiteSpace') then
          acIgWSpace.Checked := ReadBool('IgnoreWhiteSpace')
        else
          acIgWSpace.Checked := False;
        if ValueExists('IgnoreHTMLTag') then
          acIgHTML.Checked := ReadBool('IgnoreHTMLTag')
        else
          acIgHTML.Checked := False;
        acHardSpace.Enabled := acIgWSpace.Checked;
        if ValueExists('A0isWhiteSpace') then
          acHardSpace.Checked := ReadBool('A0isWhiteSpace')
        else
          acHardSpace.Checked := False;
        if acHardSpace.Checked then
          WhiteSpace := WhiteSpace + [#160];
        if ValueExists('IgnoreCase') then
          acIgCase.Checked := ReadBool('IgnoreCase')
        else
          acIgCase.Checked := False;
        if ValueExists('IgnoreCRLF') then
          acIgLFCR.Checked := ReadBool('IgnoreCRLF')
        else
          acIgLFCR.Checked := False;
        if ValueExists('FontSize') then
          FontSize := ReadInteger('FontSize')
        else
          FontSize := 10;
        if ValueExists('FontName') then
          FontName := ReadString('FontName')
        else
          FontName := 'Courier New';
        if ValueExists('MaxUndo') then
          mwceSource.MaxUndo := ReadInteger('MaxUndo')
        else
          mwceSource.MaxUndo := 10;
        if ValueExists('RightEdge') then
          mwceSource.RightEdge := ReadInteger('RightEdge')
        else
          mwceSource.RightEdge := 80;
        if ValueExists('ExtraLineSpacing') then
          mwceSource.ExtraLineSpacing := ReadInteger('ExtraLineSpacing')
        else
          mwceSource.ExtraLineSpacing := 0;
        if ValueExists('TabWidth') then
          mwceSource.TabWidth := ReadInteger('TabWidth');
        if ValueExists('EnableLeftEdit') then
          EnableLeftEdit := ReadBool('EnableLeftEdit')
        else
          EnableLeftEdit := False;
        if ValueExists('EnableRightEdit') then
          EnableRightEdit := ReadBool('EnableRightEdit')
        else
          EnableRightEdit := False;
        if ValueExists('ShowResultDialog') then
          ShowResultDialog1.Checked := ReadBool('ShowResultDialog')
        else
          ShowResultDialog1.Checked := True;
        if ValueExists('WinColor') then
          mwceSource.Color := ReadInteger('WinColor')
        else
          mwceSource.Color := clWindow;
        if ValueExists('TextColor') then
          mwceSource.Font.Color := ReadInteger('TextColor')
        else
          mwceSource.Font.Color := clWindowText;
        if ValueExists('SelForeground') then
          mwceSource.SelectedColor.Foreground := ReadInteger('SelForeground')
        else
          mwceSource.SelectedColor.Foreground := clHighLightText;
        if ValueExists('SelBackground') then
          mwceSource.SelectedColor.Background := ReadInteger('SelBackground')
        else
          mwceSource.SelectedColor.Background := clHighLight;
        CloseKey;

        OpenKey(RegDiffOptions + '\Highlighters\General', True);
        if ValueExists('DefaultFilter') then
          mwGeneralSyn1.DefaultFilter := ReadString('DefaultFilter')
        else
          mwGeneralSyn1.DefaultFilter := '';
        if ValueExists('CommentSet') then
        begin
          ReadBinaryData('CommentSet', CmntSet, SizeOf(CmntSet));
          mwGeneralSyn1.Comments := CmntSet;
        end;
        CloseKey;
      finally
        Free;
      end; // try finally
    end; // with Reg do begin

    mwceSource.ReadOnly :=  not EnableLeftEdit;
    mwceTarget.ReadOnly := not EnableRightEdit;
    tbEnableEditor.Down := not mwceSource.ReadOnly;
    acEnableEditor.Checked := tbEnableEditor.Down;
    tbEnableEditor.Enabled :=  not EnableLeftEdit;
    acEnableEditor.Enabled :=  not EnableLeftEdit;

    // Version
    JclFileVersionInfo := TJclFileVersionInfo.Create(Application.ExeName);
    try
      fm_Main.Caption := fm_Main.Caption + ' V' + JclFileVersionInfo.ProductVersion;
    finally
      JclFileVersionInfo.Free;
    end;

    EnumerateHighlighters;

    mwceSource.Font.Name := FontName;
    mwceSource.Font.Size := FontSize;
    mwceTarget.Font.Name := FontName;
    mwceTarget.Font.Size := FontSize;
    mwceTarget.RightEdge := mwceSource.RightEdge;
    mwceTarget.ExtraLineSpacing := mwceSource.ExtraLineSpacing;
    mwceTarget.TabWidth := mwceSource.TabWidth;  
    mwceTarget.Color := mwceSource.Color;
    mwceTarget.Font.Color := mwceSource.Font.Color;
    mwceTarget.SelectedColor.Foreground := mwceSource.SelectedColor.Foreground;
    mwceTarget.SelectedColor.Background := mwceSource.SelectedColor.Background;

    ClearEditorWindows;
    mwceSourceEnter(mwceSource);

    JvMruListSource.SubKey := RegDiffMRU + '\Base';
    JvMruListSource.EnumItems;

    JvMruListTarget.SubKey := RegDiffMRU + '\CompareTo';
    JvMruListTarget.EnumItems;

  finally
    {$IFDEF LANGUAGE}
    TextDomain('jedivcsdiff');
    AddDomainForResourceString('jedivcsdiff');
    //Translate form
    TranslateComponent(Self);
    AddLanguageMenuItem(Properties1, 'jedivcsdiff');
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.FormActivate(Sender: TObject);
var
  I: Integer;
  Msg,
  CurrentParameter: string;
begin
  Application.ProcessMessages;
  AutoCompare := False;
  Msg := '';
  for I := 1 to ParamCount do
  begin
    if Pos('/s:', LowerCase(ParamStr(I))) > 0 then
    begin
      CurrentParameter := ParamStr(I);
      Delete(CurrentParameter, 1, 3);
      rcbSource.Text := LowerCase(CurrentParameter);
    end;
    if Pos('/t:', LowerCase(ParamStr(I))) > 0 then
    begin
      CurrentParameter := ParamStr(I);
      Delete(CurrentParameter, 1, 3);
      rcbTarget.Text := LowerCase(CurrentParameter);
    end;
    if Pos('/sc:', LowerCase(ParamStr(I))) > 0 then
    begin
      CurrentParameter := ParamStr(I);
      Delete(CurrentParameter, 1, 4);
      SourceComment := CurrentParameter;
    end;
    if Pos('/tc:', LowerCase(ParamStr(I))) > 0 then
    begin
      CurrentParameter := ParamStr(I);
      Delete(CurrentParameter, 1, 4);
      TargetComment := CurrentParameter;
    end;
    if Pos('/autostart', LowerCase(ParamStr(I))) > 0 then
      AutoCompare := True;
  end; // for I := 1 to ParamCount do begin

  if AutoCompare then StartTimer.Enabled := True;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.StartTimerTimer(Sender: TObject);
begin
  StartTimer.Enabled := False;
  acCompareExecute(Self);
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.ClearEditorWindows;
var
  I: Integer;
begin
  LastLine[1] := 0;
  LastLine[2] := 0;
  SyncMarker := 0;
  SourceLineNr := 0;
  DeltaLines := 0;
  for I := 0 to mwceSource.Lines.Count - 1 do
    mwceSource.Marks.ClearLine(I);
  for I := 0 to 9 do
    mwceSource.ClearBookMark(I);
  mwceSource.Lines.Clear;
  mwceTarget.Lines.Clear;
  mwceSource.ClearUndo;
  mwceSource.ReadOnly := not EnableLeftEdit;
  mwceSource.Modified := False;
  mwceTarget.Modified := False;

  tbEnableEditor.Down := False;
  acEnableEditor.Checked := False;

  dfsStatusBar1.Panels[0].Text := '0 - 0/0';
  dfsStatusBar1.Panels[1].Text := JVCSRES_Deltas58_0;
  dfsStatusBar1.Panels[2].Text := '';

  LoadInfo(nil);
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.FormResize(Sender: TObject);
begin
  EnableNavButtons;
  Panel3.Width := Panel4.Width div 2;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.EnumerateHighlighters;
var
  I: Integer;
  F, S: string;
begin
  OpenDialog1.Filter := '';
  S := '';
  cbxHighlighter.Items.Clear;
  cbxHighlighter.Items.Add(JVCSRES_None);
  for I := 0 to ComponentCount - 1 do
    if Components[I] is TSynCustomHighlighter then
    begin
      if (Components[I] as TSynCustomHighlighter).DefaultFilter <> '' then
      begin
        cbxHighlighter.Items.AddObject(
          (Components[I] as TSynCustomHighlighter).LanguageName, Components[I]);
        if OpenDialog1.Filter <> '' then
          OpenDialog1.Filter := OpenDialog1.Filter + '|';

        OpenDialog1.Filter := OpenDialog1.Filter +
          (Components[I] as TSynCustomHighlighter).DefaultFilter;

        F := (Components[I] as TSynCustomHighlighter).DefaultFilter;
        S := S + Copy(F, Pos('|',F)+1, Length(F)) + ';';
      end;
    end;
  if OpenDialog1.Filter <> '' then
    OpenDialog1.Filter := OpenDialog1.Filter + '|';
  OpenDialog1.Filter := Format(JVCSRES_All_known_files12437s, [S]) + '|' + OpenDialog1.Filter +
    JVCSRES_All_files_4042464241124424642;
  SaveDialog1.Filter := OpenDialog1.Filter;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.ShowStatusBarGauge(const ShowGauge,
  Indeterminate: Boolean);
begin
  with dfsStatusBar1.Panels[2] do
  begin
    if ShowGauge then
    begin
      Text := '';
      Alignment := taCenter;
      Paneltype := sptGauge;
      if Indeterminate then
      begin
        GaugeAttrs.Position := 0;
        GaugeAttrs.Speed := 5;
        GaugeAttrs.Style := gsIndeterminate2;
      end
      else
        GaugeAttrs.Style := gsPercent;
      GaugeAttrs.Position := 0;
    end
    else
    begin
      GaugeAttrs.Position := 0;
      GaugeAttrs.Style := gsPercent;
      Paneltype := sptNormal;
      Alignment := taLeftJustify;
    end;
    dfsStatusBar1.Update;
  end;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.StatusBarGaugePos(Value: Word);
begin
  if Value > 100 then Value := 100;
  with dfsStatusBar1.Panels[2] do
    if (Paneltype = sptGauge) and
       (GaugeAttrs.Position <> Value) then
    begin
      GaugeAttrs.Position := Value;
      dfsStatusBar1.Update;
    end;
end;

//=== Ausgabe der Unterschiede in eine Datei. ==================================

procedure Tfm_Main.acReportExecute(Sender: TObject);
var
  I,
  LineCount: Integer;
  ResultString,
  SourceLine,
  TargetLine,
  CurrDiff,
  StatusBarBuffer: string;

  function TabLineNr(Value: string): string;
  begin
    while Length(Value) < 5 do Value := '0' + Value;
    Result := Value;
  end;

const
  cr = Chr(13) + Chr(10);

begin
  if DeltaLines = 0 then
  begin
    MessageBox(WindowHandle, PChar(JVCSRES_Nothing_to_do46), cMessageBoxCaption, MB_OK);
    Exit;
  end;

  Screen.Cursor := crHourGlass;
  ResultString := '';
  ResultString := ResultString + Format(JVCSRES_JVCS_Diff_Compare_result_45_37s,
    [DateTimeToStr(Now)]) + cr;
  ResultString := ResultString + Format(JVCSRES_Base58_37s, [FileNames[1]]) + cr;
  ResultString := ResultString + Format(JVCSRES_Compare_to58_37s, [FileNames[2]]) + cr;
  ResultString := ResultString + Format(JVCSRES_40New_or_changed_lines58_37d41,
    [DeltaLines]) + cr + cr;
  LineCount := 3;

  // Prepare progress bar
  StatusBarBuffer := dfsStatusBar1.Panels[2].Text;
  ShowStatusBarGauge(True, False);
  StatusBarGaugePos(0);

  mwceSource.BeginUpdate;
  mwceTarget.BeginUpdate;
  try
    for I := 0 to mwceSource.Marks.Count - 1 do
    begin
      if not mwceSource.Marks[I].IsBookmark then
      begin
        CurrDiff := IntToStr(mwceSource.Marks[I].Line);
        CurrDiff := TabLineNr(CurrDiff);
        mwceSource.CaretY := mwceSource.Marks[I].Line;
        mwceTarget.CaretY := mwceSource.Marks[I].Line;
        SourceLine := mwceSource.LineText;
        TargetLine := mwceTarget.LineText;
        ResultString :=
          ResultString + CurrDiff + Format(JVCSRES_____file58_37s, [SourceLine]) + cr;
        ResultString := ResultString + Format(JVCSRES_______archive58_37s, [TargetLine]) + cr + cr;
        Inc(LineCount, 3);
      end;
      StatusBarGaugePos(Round((I / mwceSource.Marks.Count) * 100));
    end;
  finally
    mwceSource.EndUpdate;
    mwceTarget.EndUpdate;
  end;
  ShowStatusBarGauge(False, False);
  dfsStatusBar1.Panels[2].Text := StatusBarBuffer;

  Screen.Cursor := crDefault;
  VCSSimpleReport := TVCSSimpleReport.Create(self);
  try
    VCSSimpleReport.Left := Left + 60;
    VCSSimpleReport.Top := Top + 60;
    VCSSimpleReport.ReportString := ResultString;
    VCSSimpleReport.SavePath := GetCurrentDir;
    VCSSimpleReport.SaveFileName := 'Deltas.txt';
    VCSSimpleReport.LineCount := LineCount + 8;
    VCSSimpleReport.ShowModal;
  finally
    VCSSimpleReport.Free;
  end;
end;

//------------------------------------------------------------------------------

function Tfm_Main.GetCRCChkSum(const FileName: string): string;
var
  CRCStr: string;
begin
  try
    CRCStr := CRCString(FileName);
    if Pos('$', CRCStr) = 0 then CRCStr := '';
  except
    CRCStr := '';
  end;
  Result := CRCStr;
end;

//------------------------------------------------------------------------------

function Tfm_Main.GetAttrStrEx(const FileName: string): string;
var
  FAttr: DWord;
begin
  Result := '';
  FAttr := GetFileAttributes(PChar(FileName));
  if FAttr <> $FFFFFFFF then
  begin
    if (FAttr and FILE_ATTRIBUTE_ARCHIVE) = FILE_ATTRIBUTE_ARCHIVE
      then Result := Result + 'A';
    if (FAttr and FILE_ATTRIBUTE_COMPRESSED) = FILE_ATTRIBUTE_COMPRESSED
      then Result := Result + 'C';
    if (FAttr and FILE_ATTRIBUTE_DIRECTORY) = FILE_ATTRIBUTE_DIRECTORY
      then Result := Result + 'D';
    if (FAttr and FILE_ATTRIBUTE_HIDDEN) = FILE_ATTRIBUTE_HIDDEN
      then Result := Result + 'H';
    if (FAttr and FILE_ATTRIBUTE_NORMAL) = FILE_ATTRIBUTE_NORMAL
      then Result := Result + 'N';
    if (FAttr and FILE_ATTRIBUTE_OFFLINE) = FILE_ATTRIBUTE_OFFLINE
      then Result := Result + 'O';
    if (FAttr and FILE_ATTRIBUTE_READONLY) = FILE_ATTRIBUTE_READONLY
      then Result := Result + 'R';
    if (FAttr and FILE_ATTRIBUTE_SYSTEM) = FILE_ATTRIBUTE_SYSTEM
      then Result := Result + 'A';
    if (FAttr and FILE_ATTRIBUTE_TEMPORARY) = FILE_ATTRIBUTE_TEMPORARY
      then Result := Result + 'T';
  end // if FAttr <>  $FFFFFFFF then begin
  else
    Result := JVCSRES_Error;
end;

//=== Need to strip anything from the string? ==================================

function Tfm_Main.StripString(const S: string): string;
begin
  Result := S;
  if acIgLFCR.Checked then
    Result := StripCRLF(Result);
  if acIgWSpace.Checked then
    Result := StripWhiteSpace(Result);
  if acIgCase.Checked then
    Result := LowerCase(Result);
  if acIgHTML.Checked then
    Result := StripHTMLTags(Result);
end;

//==============================================================================
// strip white space (space & TAB) if:
// - two or more spaces/TABs are one behind another
// - a space/TAB is the last char before CR or LF
// - a space/TAB is the last char before CRLF/LFCR
// - a single space/TAB is the first char in the string

function Tfm_Main.StripWhiteSpace(const S: string): string;
var
  I: Integer;
begin
  Result := S;
  I := Length(Result);
  while I > 0 do
  begin
    if Result[I] in WhiteSpace then
    begin
      if (I > 1) and
         (Result[I - 1] in WhiteSpace) then
      begin
        Delete(Result, I, 1);
        // IF last char deleted
        while I > Length(Result) do
          Dec(I); //Thu 26.05.2003 Range check error
      end
      else
      begin
        Dec(I);
      end;
    end // if Result[I] in...
    else
      Dec(I);
  end; // while I > 0 do

  if (Length(Result) > 0) and
     (Result[1] in WhiteSpace) then
    Delete(Result, 1, 1);

  I := Length(Result);
  if (I > 0) and
     (Result[I] in WhiteSpace) then
    Delete(Result, I, 1);

  // no need to search further if CR/LF is already stripped
  if not acIgLFCR.Checked then
  begin
    I := Length(Result);
    if I > 2 then
      if (Result[I] in LineEnd) and
         (Result[I - 1] in LineEnd) and
         (Result[I - 2] in WhiteSpace) then
        Delete(Result, I - 2, 1);

    I := Length(Result);
    if I > 1 then
      if (Result[I] in LineEnd) and
         (Result[I - 1] in WhiteSpace) then
        Delete(Result, I - 1, 1);
  end;
end;

//------------------------------------------------------------------------------

function Tfm_Main.StripCRLF(const S: string): string;
var
  I: Integer;
begin
  Result := S;
  I := Length(Result);
  while I > 0 do
  begin
    case Result[I] of
      #10, #13:
        Delete(Result, I, 1);
    end;
    Dec(I);
  end;
end;

//------------------------------------------------------------------------------

function Tfm_Main.StripHTMLTags(const S: string): string;
var
  I, J: Integer;
begin
  I := 1;
  J := Length(S);
  Result := '';
  while I <= J do
  begin
    if S[I]= '<' then
    repeat
      Inc(I);
    until (S[I]= '>') or (I >= J)
    else
      Result := Result + S[I];
    Inc(I);
  end;
end;

//=== Diese Methode setzt einen Diff-Marker (keine Bookmark!) auf Linie "ALine".

procedure Tfm_Main.MarkDiffLine(const ALine: Integer);
var
  Mark: TSynEditMark;
  DiffIndex: Integer;
  SourceLineText,
  TargetLineText: string;
begin
  if (ALine > mwceSource.Lines.Count - 1) or
     (ALine > mwceTarget.Lines.Count - 1) then
    Exit;

  mwceSource.CaretY := ALine;
  mwceTarget.CaretY := ALine;
  SourceLineText := StripString(mwceSource.LineText);
  TargetLineText := StripString(mwceTarget.LineText);

  // zwei Leerzeilen werden nicht markiert
  if (SourceLineText = '') and
     (TargetLineText = '') then
    Exit;

  if (SourceLineText = TargetLineText) then
    Exit;

  DiffIndex := 11;
  if (SourceLineText = '') and
     (TargetLineText <> '') then
    DiffIndex := 12;
  if (TargetLineText = '') and
     (SourceLineText <> '') then
    DiffIndex := 10;

  with mwceSource do
  begin
    Marks.ClearLine(CaretY);
    Mark := TSynEditMark.Create;
    with Mark do
    begin
      Line := ALine;
      Char := 0;
      ImageIndex := DiffIndex;
//hu30.12.2002       IsBookmark := False;
      Visible := True;
      InternalImage := False;
    end;
    Marks.Add(Mark);
  end;
end;

//==============================================================================
// Diese Methode liest 'n' Zeilen aus der Datei 'SourceFiles[EditorWin]' ein und
// fügt sie in das Gitter ein. Entsprechend wird 'LastLine[EditorWin]' erhöht.
// Falls Zeilen aus der ersten Datei gelesen werden, dann werden auch die
// Zeilennummern in Spalte 0 "fortgeschrieben".

procedure Tfm_Main.ReadLines(EditorWin, N: Integer);
var
  Line: string;
begin
  while not Eof(SourceFiles[EditorWin]) and (N > 0) do
  begin
    Readln(SourceFiles[EditorWin], Line);

    Inc(LastLine[EditorWin]);
    if EditorWin = 1 then
    begin
      Inc(SourceLineNr);
      mwceSource.Lines.Insert(LastLine[EditorWin] -1, Line)
    end
    else
      mwceTarget.Lines.Insert(LastLine[EditorWin] - 1, Line);

    Dec(N);
    StatusBarGaugePos(Round((SourceLineNr / SourceLineCount) * 80) + 20);
  end;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.InsertEmptyLines(const EditorWin, AtLine,
  nLines: Integer);
var
  I: Integer;
begin
  repeat
    mwceSource.Lines.Add('');
    mwceTarget.Lines.Add('');
  until (mwceSource.Lines.Count >= (LastLine[EditorWin] + nLines + 2));

  if (mwceTarget.Lines.Count > mwceSource.Lines.Count) then
    while (mwceTarget.Lines.Count > mwceSource.Lines.Count) do
      mwceSource.Lines.Add('');

  if (mwceTarget.Lines.Count < mwceSource.Lines.Count) then
    while (mwceTarget.Lines.Count < mwceSource.Lines.Count) do
      mwceTarget.Lines.Add('');

  for I := LastLine[EditorWin] downto AtLine do
  begin
    if EditorWin = 1 then
    begin
      mwceSource.Lines[(I + nLines) - 1] := mwceSource.Lines[I - 1];
      mwceSource.Lines[I - 1] := '';
    end
    else
    begin
      mwceTarget.Lines[(I + nLines) - 1] := mwceTarget.Lines[I - 1];
      mwceTarget.Lines[I - 1] := '';
    end;
  end;
  Inc(LastLine[EditorWin], nLines);
end;

//==============================================================================
// Wenn aus irgendeinem Grund nicht mehr weiter syncronisiert werden kann, dann
// schließt diese Methode den Dateivergleich ab: Alle Zeilen nach 'SyncMarker'
// werden als abweichend markiert. Außerdem muss sichergestellt werden, daß beide
// Edit-Windows die gkeiche Anzahl Zeilen enthalten.

procedure Tfm_Main.GiveUp;
var
  I: Integer;
begin
  if not Eof(SourceFiles[1]) then
    ReadLines(1, 30000);
  if not Eof(SourceFiles[2]) then
    ReadLines(2, 30000);

  if (mwceTarget.Lines.Count > mwceSource.Lines.Count) then
    while (mwceTarget.Lines.Count > mwceSource.Lines.Count) do
      mwceSource.Lines.Add('');

  if (mwceTarget.Lines.Count < mwceSource.Lines.Count) then
    while (mwceTarget.Lines.Count < mwceSource.Lines.Count) do
      mwceTarget.Lines.Add('');

  for I := SyncMarker + 1 to mwceSource.Lines.Count - 1 do
    MarkDiffLine(I);
end;

//==============================================================================
// Solange Zeilenweise mit der Marke 'SyncMarker' weiterlaufen, bis eine Abweichung
// entdeckt wird. 'SyncMarker' wird dann auf die letzte übereinstimmende Zeile
// gesetzt.
// Falls ein Syncronisieren der Dateien sicher nicht möglich ist (weil mindestens
// eine der Dateien endet), dann wird 'False' sonst 'True' zurückgegeben.

function Tfm_Main.ReadUntilDiff: Boolean;
var
  SourceLineText,
  TargetLineText: string;
begin
  Result := False;
  if (not Eof(SourceFiles[1]) or (SyncMarker < LastLine[1])) and
     (not Eof(SourceFiles[2]) or (SyncMarker < LastLine[2])) then
  begin
    repeat
      if SyncMarker = LastLine[1] then ReadLines(1, 1);
      if SyncMarker = LastLine[2] then ReadLines(2, 1);
      Inc(SyncMarker);
      SourceLineText := StripString(mwceSource.Lines[SyncMarker - 1]);
      TargetLineText := StripString(mwceTarget.Lines[SyncMarker - 1]);
    until (Eof(SourceFiles[1]) and (SyncMarker = LastLine[1])) or
          (Eof(SourceFiles[2]) and (SyncMarker = LastLine[2])) or
          (SourceLineText <> TargetLineText);

    //???
    {ShowMessage('mwceSource.LineText "' + SourceLineText + '"' + #10#13 +
                'mwceTarget.LineText "' + TargetLineText + '"');}

    {  Jetzt gibt's zwei Möglichkeiten:
       1) Es wurde eine Abweichung gefunden und es sind noch Zeilen in den
          Dateien, so das ein Versuch zum Syncronisieren gestartet werden kann.
       2) Die Schleife wurde beendet, aber weil in einer Datei keine Zeilen
          mehr sind.  }
    if (Eof(SourceFiles[1]) and (SyncMarker = LastLine[1])) or
       (Eof(SourceFiles[2]) and (SyncMarker = LastLine[2])) then
    begin
      if SourceLineText <> TargetLineText then
        Dec(SyncMarker);
    end
    else
    begin
      Dec(SyncMarker);
      Result := True;
    end;
  end;
end;

//=== Suche nach neuen Übereinstimmungen =======================================

function Tfm_Main.SearchLines(c1, r1, c2, r2a, r2b, N: Integer): Integer;
var
  K: Integer;
begin
  repeat
    K := 0;
    if c1 = 1 then
    begin
      while (K < N) and
            (StripString(mwceSource.Lines[(r1 + K) - 1]) =
             StripString(mwceTarget.Lines[(r2a + K) - 1])) do
        Inc(K);
    end
    else
    begin
      while (K < N) and
            (StripString(mwceTarget.Lines[(r1 + K) - 1]) =
             StripString(mwceSource.Lines[(r2a + K) - 1])) do
        Inc(K);
    end;
    Inc(r2a);
  until (K = N) or (r2a > r2b);
  if K = N then
    Result := r2a - 1
  else
    Result := -1;
end;

//==============================================================================
// Versuch, nach einer oder mehrer verschiedenen Zeilen die beiden Dateien wieder
// zu synchronisieren

function Tfm_Main.ReSync: Boolean;
const
  K = 2;
  inv: array [1..2] of Integer = (2, 1);
var
  SearchMark: array [1..2] of Integer;
  FileEnd: array [1..2] of Boolean;
  C, P: Integer;
begin
  Result := True;
  {  Die beiden "Marker" SearchMark[1] und SearchMark[2] geben an, bis zu
     welcher Zeile das Programm sucht, um 'K' übereinstimmende Zeilen nach der
     Zeile 'SyncMarker' zu finden.  }
  SearchMark[1] := SyncMarker + K;
  SearchMark[2] := SyncMarker + K;
  {  in den beiden Fenstern müssen sich mindestens soviele Zeilen finden, wie
     die Marker angeben; ggf. müssen weitere Zeilen eingelesen werden. Es ist
     aber (durch vorangegangenes Einfügen von Zeilen) auch möglich, daß sich in
     einer oder beiden Spalten schon genug oder sogar mehr Zeilen befinden.  }
  if SearchMark[1] > LastLine[1] then
    ReadLines(1, SearchMark[1] - LastLine[1]);
  if SearchMark[2] > LastLine[2] then
    ReadLines(2, SearchMark[2] - LastLine[2]);
  {  Wenn eine der Dateien nicht mehr genug Zeilen enthält, dann muß die Suche
     abgebrochen werden.  }
  if (SearchMark[1] > LastLine[1]) or
     (SearchMark[2] > LastLine[2]) then
  begin
    Result := False;
    Exit;
  end;

  FileEnd[1] := (SearchMark[1] = LastLine[1]) and Eof(SourceFiles[1]);
  FileEnd[2] := (SearchMark[2] = LastLine[2]) and Eof(SourceFiles[2]);
  if FileEnd[1] then C := 2 else C := 1;
  P := -1;

  while (P < 0) and (not FileEnd[1] or not FileEnd[2]) do
  begin
    // Marker eine Zeile weitersetzen; ggf. eine Zeile einlesen.
    Inc(SearchMark[C]);
    if SearchMark[C] > LastLine[C] then ReadLines(C,1);
    // Testen, ob das Ende der Datei erreicht ist.
    FileEnd[C] := (SearchMark[C] = LastLine[C]) and Eof(SourceFiles[C]);
    // Prüfen, ob syncronisiert werden kann.
    P := SearchLines(C, SearchMark[C] - K + 1,
      inv[C], SyncMarker + 1, SearchMark[inv[C]] - K + 1, K);
    // Wenn das Ende der anderen Datei noch nicht erreicht ist: Übergeben
    if (P < 0) and not FileEnd[inv[C]] then
      C := inv[C];
  end;

  if P > 0 then
  begin
    if SearchMark[C] - K + 1 - P > 0 then
      InsertEmptyLines(inv[C], P, SearchMark[C] - K + 1 - P);
    for P := SyncMarker + 1 to SearchMark[C] - K do
      MarkDiffLine(P);

    SyncMarker := SearchMark[C];
  end
  else
  begin
    for P := SyncMarker + 1 to mwceSource.Lines.Count - 1 do
      MarkDiffLine(P);
  end;
end;

//------------------------------------------------------------------------------

function Tfm_Main.SaveSourceChanges: Boolean;
var
  DlgResult: Integer;
begin
  Result := False;
  if mwceSource.Modified then
  begin
    ActiveEditorView := mwceSource;
    DlgResult := MessageBox(WindowHandle,
      PChar(JVCSRES_Left_editor_view58 + #10#13 +
      '<' + rcbSource.Text + '>' + #10#13 +
      JVCSRES_You_have_made_changes_that_have_not_been_applied46 + #10#13 +
      JVCSRES_Do_you_want_to_apply_these_now63),
      cMessageBoxCaption, MB_YESNOCANCEL or MB_ICONQUESTION);
    case DlgResult of
      id_Yes: acSaveChangesExecute(Self);
      id_No:
        begin
          mwceSource.Modified := False;
          SourceFooter.Caption := '';
          acSaveChanges.Enabled := False;
          acSaveCompare.Enabled := acSaveChanges.Enabled;
        end;
      id_Cancel: Exit;
    end;
  end;
  if mwceTarget.Modified then
  begin
    ActiveEditorView := mwceTarget;
    DlgResult := MessageBox(WindowHandle,
      PChar(JVCSRES_Right_editor_view58 + #10#13 +
      '<' + rcbTarget.Text + '>' + #10#13 +
      JVCSRES_You_have_made_changes_that_have_not_been_applied46 + #10#13 +
      JVCSRES_Do_you_want_to_apply_these_now63),
      cMessageBoxCaption, MB_YESNOCANCEL or MB_ICONQUESTION);
    case DlgResult of
      id_Yes: acSaveChangesExecute(Self);
      id_No:
        begin
          mwceTarget.Modified := False;
          TargetFooter.Caption := '';
          acSaveChanges.Enabled := False;
          acSaveCompare.Enabled := acSaveChanges.Enabled;
        end;
      id_Cancel: Exit;
    end;
  end;
  Result := True;
end;

//------------------------------------------------------------------------------
// This bit is stolen from stdivapi.pas
function Tfm_Main.IsTextFile(const FileName: string): Boolean;

    function IsTextStream(Stream: TStream): Boolean;
    const
      MaxLineLength = 255;
    var
      LineBuffer: array [0..MaxLineLength] of Char;
      CharFlags: array of Word;
      I, Count: Integer;
      P, S: PChar;
    begin
      Result := False;
      FillChar(LineBuffer, SizeOf(LineBuffer), 0);
      Stream.Position := 0;
      if Stream.Size > MaxLineLength then Count := MaxLineLength
      else Count := Stream.Size;
      Stream.Read(LineBuffer, Count);
      // see if we can come up with an EOL (unless we read the whole file)
      if Count < Stream.Size then
      begin
        P := StrPos(LineBuffer, #13);
        if P = nil then
          P := StrPos(LineBuffer, #10);
        if P = nil then
          Exit;
        // terminate the string here
        P^ := #0;
        // check if there are any terminators prior to where we expect the EOL
        S := @LineBuffer;
        while S < P do
        begin
          if S^ = #0 then
            Exit;
          Inc(S);
        end;
      end;
      Count := StrLen(LineBuffer);
      // some editors place a $1A (26) as an EOF marker
      if LineBuffer[Count - 1] = Char($1A) then
      begin
        LineBuffer[Count - 1] := #0;
        Dec(Count);
      end;
      // if first character is $FF, then it's likely not text
      if LineBuffer[0] = Char($FF) then
        Exit;
      // get the char flags
      SetLength(CharFlags, Count);
      GetStringTypeEx(LOCALE_USER_DEFAULT, CT_CTYPE1, LineBuffer, Count,
        CharFlags[0]);
      // check the CharFlags array to see if anything looks fishy
      for I := Low(CharFlags) to High(CharFlags) do
        if ((CharFlags[I] and C1_CNTRL) <> 0) and ((CharFlags[I] and $0F) = 0) then
          Exit;
      // best guess is that it looks reasonable
      Result := True;
    end; // function IsTextStream(Stream: TStream): Boolean;

var
  S: TStream;
begin
  Result := False;
  if not FileExists(FileName) then
    Exit;

  S := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  try
    Result := IsTextStream(S);
  finally
    S.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.acCompareExecute(Sender: TObject);
var
  TestFileName : String;
  MsgTxt,
  CRCVal1,
  CRCVal2: string;
  mbIcon: Integer;

  // Check if any files are specified
  function TestIfFilesExist : Boolean;
  begin
    result := not ((FileNames[1] = '') or (FileNames[2] = ''));
    if not result then
      MessageBox( WindowHandle
                , PChar(JVCSRES_You_must_enter_a_file_name_first46)
                , cMessageBoxCaption
                , MB_OK or MB_ICONINFORMATION
                );
  end;

  // Check if files are existing
  function TestIfFilesAvailable : Boolean;
  begin
    result := (FileExists(FileNames[1]) and FileExists(FileNames[2]));
    if not result then
      MessageBox( WindowHandle
                , PChar ( Format( JVCSRES_File_6037s_and47or_37s62_not_found46
                                , [FileNames[1], FileNames[2]]
                                )
                        )
                , cMessageBoxCaption
                , MB_OK or MB_ICONWARNING
                );
  end;

  // Check if files can be opened
  function TestIfCanOpenFiles : Boolean;
  var
    TestFileStream: TFileStream;
  begin
    TestFileName := '';
    try
      TestFileStream := TFileStream.Create( FileNames[1]
                                          , fmOpenRead or fmShareDenyWrite
                                          );
      TestFileStream.Free;
    except
      TestFileName := FileNames[1];
    end;
    try
      TestFileStream := TFileStream.Create( FileNames[2]
                                          , fmOpenRead or fmShareDenyWrite
                                          );
      TestFileStream.Free;
    except
      TestFileName := FileNames[2];
    end;

    result := (TestFileName = '');
    if not result then
      MessageBox( WindowHandle
                , PChar(JVCSRES_Could_not_open_file_for_reading58 + #10#13 +
                        '<' + TestFileName + '>')
                , cMessageBoxCaption
                , MB_OK or MB_ICONWARNING
                );
  end;

begin
  if SaveSourceChanges then
  begin
    Screen.Cursor := crHourGlass;
    try
      FileNames[1] := rcbSource.Text;
      FileNames[2] := rcbTarget.text;

      if not TestIfFilesExist then
        exit;
      if not TestIfFilesAvailable then
        exit;
      if not TestIfCanOpenFiles then
        exit;

      // Prepare progress bar
      ShowStatusBarGauge(True, False);
      StatusBarGaugePos(0);
      // Get line count for the base file to provide progress information
      AssignFile(SourceFiles[1], FileNames[1]);
      try
        Reset(SourceFiles[1]);
        SourceLineCount := 0;
        repeat
          Readln(SourceFiles[1], MsgTxt);
          Inc(SourceLineCount);
        until Eof(SourceFiles[1]);
      finally
        CloseFile(SourceFiles[1]);
      end;
      StatusBarGaugePos(10);

      // Check if the files are plain text
      TestFileName := '';
      if not IsTextFile(FileNames[1]) then
      begin
        StatusBarGaugePos(10);
        TestFileName := FileNames[1];
      end
      else
      begin
        StatusBarGaugePos(10);
        if not IsTextFile(FileNames[2]) then
          TestFileName := FileNames[2];
      end;
      StatusBarGaugePos(20);
      if TestFileName <> '' then
      begin
        CRCVal1 := GetCRCChkSum(FileNames[1]);
        CRCVal2 := GetCRCChkSum(FileNames[2]);
        MsgTxt := '<' + TestFileName + '>' + #10#13 +
          JVCSRES_This_is_a_binary_file46_Unable_to_do_visual_compare46 + #10#13 +
          Format(JVCSRES_CRC32_Base58_37s_45_CRC32_CompareTo58_37s, [CRCVal1, CRCVal2]) + #10#13;
        if CRCVal1 = CRCVal2 then
        begin
          MsgTxt := MsgTxt + JVCSRES_The_files_are_equal46;
          mbIcon := MB_ICONINFORMATION;
        end
        else
        begin
          MsgTxt := MsgTxt + JVCSRES_The_files_are_different46;
          mbIcon := MB_ICONWARNING;
        end;
        MessageBox(WindowHandle, PChar(MsgTxt), cMessageBoxCaption, MB_OK or mbIcon);
        ShowStatusBarGauge(False, False);
        Exit;
      end;

      SetHighLighter;

      with rcbSource do
      begin
        rcbSource.Items.Clear;
        JvMruListSource.AddString(FileNames[1]);
        JvMruListSource.EnumItems;
        rcbSource.Text := FileNames[1];
      end;
      with rcbTarget do
      begin
        rcbTarget.Items.Clear;
        JvMruListTarget.AddString(FileNames[2]);
        JvMruListTarget.EnumItems;
        rcbTarget.Text := FileNames[2];
      end;

      DoCompare;

      ShowStatusBarGauge(False, False);
      dfsStatusBar1.Panels[2].Text := Format(JVCSRES_Base58_37s_47_37s_bytes_124_Compare_to58_37s_47_37s_bytes,
        [DateTimeToStr(FileDateToDateTime(FileAge(FileNames[1]))),
         FormatFloat('#,', GetSizeOfFile(FileNames[1])),
         DateTimeToStr(FileDateToDateTime(FileAge(FileNames[2]))),
         FormatFloat('#,', GetSizeOfFile(FileNames[2]))]);

      Screen.Cursor := crDefault;

      if DeltaLines > 0 then
      begin
        MsgTxt := Format(JVCSRES_The_files_differ_by_37d_lines_4037d_Blocks4146,
          [DeltaLines, DeltaBlocks]);
        dfsStatusBar1.Panels[1].Text := Format(JVCSRES_Delta_37d_Lines47_37d_Blocks,
          [DeltaLines, DeltaBlocks]);
      end
      else
      begin
        MsgTxt := JVCSRES_The_files_are_equal;
        if acIgWSpace.Checked or
           acIgCase.Checked then
        begin
          MsgTxt := MsgTxt + JVCSRES__or_differ_by_;
          if acIgWSpace.Checked then
            MsgTxt := MsgTxt + JVCSRES_white_space_;
          if acIgWSpace.Checked and
             acIgCase.Checked then
            MsgTxt := MsgTxt + '/ ';
          if acIgCase.Checked then
            MsgTxt := MsgTxt + JVCSRES_case_;
          MsgTxt := MsgTxt + JVCSRES_only46;
        end
        else
          MsgTxt := MsgTxt + '.';

        if acIgCase.Checked then
          MsgTxt := MsgTxt + #10#13 + JVCSRES__45_Case58_ignored + '.';
        if acIgLFCR.Checked then
          MsgTxt := MsgTxt + #10#13 + JVCSRES__45_LFCR58_stripped + '.';
        if acIgWSpace.Checked then
        begin
          MsgTxt := MsgTxt + #10#13 + JVCSRES__45_Whitespace58_stripped + '.';
          if acHardSpace.Checked then
            MsgTxt := MsgTxt + #10#13 + JVCSRES__45_Hard_space58_stripped + '.';
        end;
        if acIgHTML.Checked then
          MsgTxt := MsgTxt + #10#13 + JVCSRES__45_HTML_Tags58_stripped + '.';

        dfsStatusBar1.Panels[1].Text :=  JVCSRES_Delta58_4547_45;
      end;
      if ShowResultDialog1.Checked then
        MessageBox(WindowHandle, PChar(MsgTxt), cMessageBoxCaption,
          MB_OK or MB_ICONINFORMATION);

      EnableNavButtons;
      Sleep(100);
      if (not acPreviousDiff.Enabled) then
        if acNextDiff.Enabled then
          acNextDiffExecute(Self);
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.DoCompare;
var
  I: Integer;
  GoAhead: Boolean;
begin
  CompareInProgess := True;
  mwceSource.BeginUpdate;
  mwceTarget.BeginUpdate;
  try
    ClearEditorWindows;

    if SourceComment <> '' then
      SourceHeader.Caption := ' ' + SourceComment
    else
      SourceHeader.Caption := Format(JVCSRES__File58_37s_4037s41_9137s93,
        [AnsiLowerCase(ExtractFileName(FileNames[1])), GetCRCChkSum(FileNames[1]),
         GetAttrStrEx(FileNames[1])]);
    if TargetComment <> '' then
      TargetHeader.Caption := ' ' + TargetComment
    else
      TargetHeader.Caption := Format(JVCSRES__File58_37s_4037s41_9137s93,
        [AnsiLowerCase(ExtractFileName(FileNames[2])), GetCRCChkSum(FileNames[2]),
         GetAttrStrEx(FileNames[2])]);
    SourceHeader.Hint := FileNames[1];
    TargetHeader.Hint := FileNames[2];

    AssignFile(SourceFiles[1], FileNames[1]);
    try
      AssignFile(SourceFiles[2], FileNames[2]);
      try
        Reset(SourceFiles[1]);
        Reset(SourceFiles[2]);
        //--- die eigentliche Compare Routine --------------------------------------
        GoAhead := True;
        while GoAhead and
              (not Eof(SourceFiles[1]) or not Eof(SourceFiles[2])) do
        begin
          GoAhead := ReadUntilDiff;
          if GoAhead and
             (not Eof(SourceFiles[1]) or not Eof(SourceFiles[2])) then
            GoAhead := ReSync;
        end;
        if not GoAhead then
          GiveUp;
      finally
        //--------------------------------------------------------------------------
        CloseFile(SourceFiles[2]);
      end;
    finally
      CloseFile(SourceFiles[1]);
    end;

    mwceSource.CaretY := 0;
    mwceTarget.CaretY := 0;

    DeltaLines := 0;
    for I := 0 to mwceSource.Marks.Count - 1 do
      if (not mwceSource.Marks[I].IsBookmark) then
        Inc(DeltaLines);

    DeltaBlocks := 0;
    I := 0;
    while (I < mwceSource.Marks.Count) do
    begin
      if (not mwceSource.Marks[I].IsBookmark) then
      begin
        Inc(DeltaBlocks);
        while (I < mwceSource.Marks.Count - 1) and
              (mwceSource.Marks[I].ImageIndex =
               mwceSource.Marks[I + 1].ImageIndex) and
              (mwceSource.Marks[I + 1].Line =
               mwceSource.Marks[I].Line + 1) do
          Inc(I);
        Inc(I);
      end;
    end;

  finally
    mwceSource.EndUpdate;
    mwceTarget.EndUpdate;
    CompareInProgess := False;
  end;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.EnableNavButtons;
begin
  acPreviousDiff.Enabled := (mwceSource.TopLine > 1) and
                            (GetPreviousDiff > 0);
  acNextDiff.Enabled := GetNextDiff > 0;
  acFirstDiff.Enabled := acPreviousDiff.Enabled;
  acLastDiff.Enabled := acNextDiff.Enabled;
end;

//------------------------------------------------------------------------------

function Tfm_Main.GetNextDiff: Integer;
var
  I,
  CurrPos,
  CurrDiffType: Integer;
begin
  Result := -1;
  if CompareInProgess then Exit;
  CurrDiffType := -1;
  CurrPos := mwceSource.TopLine + mwceSource.LinesInWindow div 2;
  // remember the current diff type
  for I := 0 to mwceSource.Marks.Count - 1 do
    if (not mwceSource.Marks[I].IsBookmark) and
       (mwceSource.Marks[I].Line = CurrPos) then
      CurrDiffType := mwceSource.Marks[I].ImageIndex;
  // search for following diffs
  for I := 0 to mwceSource.Marks.Count - 1 do
  begin
    if (not mwceSource.Marks[I].IsBookmark) and
       (mwceSource.Marks[I].Line > CurrPos) then
    begin
      // filter diffs from the same type in the next line
      if ((mwceSource.Marks[I].Line - 1) = CurrPos) and
         (mwceSource.Marks[I].ImageIndex = CurrDiffType) then
      begin
        CurrPos := mwceSource.Marks[I].Line;
        Continue;
      end;
      Result := mwceSource.Marks[I].Line;
      Break;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.acNextDiffExecute(Sender: TObject);
var
  NewPos: Integer;
begin
  NewPos := GetNextDiff;
  if NewPos > 0 then
    mwceSource.TopLine := NewPos - (mwceSource.LinesInWindow div 2);
end;

//------------------------------------------------------------------------------

function Tfm_Main.GetPreviousDiff: Integer;
var
  I,
  CurrPos,
  CurrDiffType: Integer;
begin
  Result := -1;
  if CompareInProgess then Exit;
  CurrDiffType := -1;
  CurrPos := mwceSource.TopLine + mwceSource.LinesInWindow div 2;
  // remember the current diff type
  for I := 0 to mwceSource.Marks.Count - 1 do
    if (not mwceSource.Marks[I].IsBookmark) and
       (mwceSource.Marks[I].Line = CurrPos) then
      CurrDiffType := mwceSource.Marks[I].ImageIndex;
  // search for previous diffs
  for I := mwceSource.Marks.Count - 1 downto 0 do
  begin
    if (not mwceSource.Marks[I].IsBookmark) and
       (mwceSource.Marks[I].Line < CurrPos) then
    begin
      // filter diffs from the same type in the line above
      if ((mwceSource.Marks[I].Line + 1) = CurrPos) and
         (mwceSource.Marks[I].ImageIndex = CurrDiffType) then
      begin
        CurrPos := mwceSource.Marks[I].Line;
        Continue;
      end;
      Result := mwceSource.Marks[I].Line;
      Break;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.acLastDiffExecute(Sender: TObject);
var
  I: Integer;
begin
  for I := mwceSource.Marks.Count - 1 downto 0 do
  begin
    if (not mwceSource.Marks[I].IsBookmark) then
    begin
      mwceSource.TopLine := mwceSource.Marks[I].Line -
                            (mwceSource.LinesInWindow div 2);
      Break;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.acFirstDiffExecute(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to mwceSource.Marks.Count - 1 do
  begin
    if (not mwceSource.Marks[I].IsBookmark) then
    begin
      mwceSource.TopLine := mwceSource.Marks[I].Line -
                            (mwceSource.LinesInWindow div 2);
      Break;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.acPreviousDiffExecute(Sender: TObject);
var
  NewPos: Integer;
begin
  NewPos := GetPreviousDiff;
  if NewPos > 0 then
    mwceSource.TopLine := NewPos - (mwceSource.LinesInWindow div 2);
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.acCloseExecute(Sender: TObject);
begin
  SaveSettings;
  Close;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.SaveSettings;
begin
  with TRegistry.Create do
  begin
    try
      RootKey := HKEY_CURRENT_USER;
      OpenKey(RegDiffBase + 'Window', True);
      WriteInteger('Y', Top);
      WriteInteger('X', Left);
      WriteInteger('W', Width);
      WriteInteger('H', Height);
      WriteInteger('SplitterPos', Panel3.Width);
      CloseKey;
      OpenKey(RegDiffOptions, True);
      if rcbSource.Text <> '' then
        WriteString('LastBaseFile', rcbSource.Text);
      if rcbTarget.Text <> '' then
        WriteString('LastCompareFile', rcbTarget.Text);
      WriteBool('DisableBinaryFileChecking', DisableBinaryFileChecking1.Checked);
      WriteBool('IgnoreWhiteSpace', acIgWSpace.Checked);
      WriteBool('IgnoreHTMLTag', acIgHTML.Checked);
      WriteBool('A0isWhiteSpace', acHardSpace.Checked);
      WriteBool('IgnoreCase', acIgCase.Checked);
      WriteBool('IgnoreCRLF', acIgLFCR.Checked);
      WriteInteger('FontSize', mwceSource.Font.Size);
      WriteString('FontName', mwceSource.Font.Name);
      WriteInteger('MaxUndo', mwceSource.MaxUndo);
      WriteInteger('RightEdge', mwceSource.RightEdge);
      WriteInteger('ExtraLineSpacing', mwceSource.ExtraLineSpacing);
      WriteInteger('TabWidth', mwceSource.TabWidth);      
      WriteBool('EnableLeftEdit', EnableLeftEdit);
      WriteBool('EnableRightEdit', EnableRightEdit);
      WriteBool('ShowResultDialog', ShowResultDialog1.Checked);
      WriteInteger('WinColor', mwceSource.Color);
      WriteInteger('TextColor', mwceSource.Font.Color);
      WriteInteger('SelForeground', mwceSource.SelectedColor.Foreground);
      WriteInteger('SelBackground', mwceSource.SelectedColor.Background);
      CloseKey;
    finally
      Free;
    end;
  end;
  // Aktuelles Verzeichnis wiederherstellen
  ChDir(ActDir);
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.acBrowseSourceExecute(Sender: TObject);
begin
  with OpenDialog1 do
  begin
    Title := JVCSRES_Base_version;
    if rcbSource.Text <> '' then
      InitialDir := ExtractFilePath(rcbSource.Text)
    else
      InitialDir := GetCurrentDir;
    FileName := ExtractFileName(rcbSource.Text);
    if Execute then
      rcbSource.Text := LowerCase(FileName);
  end;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.acBrowseTargetExecute(Sender: TObject);
begin
  with OpenDialog1 do
  begin
    Title := JVCSRES_Compare_to_version;
    if rcbTarget.Text <> '' then
      InitialDir := ExtractFilePath(rcbTarget.Text)
    else
      InitialDir := GetCurrentDir;
    FileName := ExtractFileName(rcbTarget.Text);
    if Execute then
      rcbTarget.Text := LowerCase(FileName);
  end;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.rcbSource_orgChange(Sender: TObject);
begin
  SourceComment := '';
  TargetComment := '';
//!!!  spBtnCompare.Enabled := (rcbSource.Text <> '') and
//!!!                          (rcbTarget.Text <> '');
//!!!  Compare1.Enabled := spBtnCompare.Enabled;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.spBtnAboutClick(Sender: TObject);
//var MsgTxt: string;
begin
  ShowDiffAboutForm;
{//USc 18.01.2004 is now in DiffAbout.pas
  MsgTxt := 'JEDIvcsdiff Diff/Merge Utility V ' +
    'This program is part of the Opensource JEDI version control system JEDI-VCS.'
    + #10#13 + #10#13 +
    'As an Opensource program, it is distributed in the hope that it will be useful,'
    + #10#13 +
    'but WITHOUT ANY WARRANTY AT ALL. Use it on your own risk.'
    + #10#13 + #10#13 +
    'Compare engine based on code by Armin L. Biernaczyk.'
    + #10#13 +
    'Edit controls/ Syntax Highlighter: Opensource TSynEdit 1.1.'
    + #10#13 + #10#13 +
    'call: JEDIvcsdiff.exe /s: /t: /autostart'  + #10#13 +
    '  /s: = source file'  + #10#13 +
    '  /t: = target file'  + #10#13 +
    '  /autostart = start compare immediately' + #10#13 + #10#13 +
    'See manuals for more information and license information.';
  MessageBox(WindowHandle, PChar(MsgTxt), 'JEDIvcsdiff', MB_OK);
}
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.SaveChanges(SaveEditor: TSynEdit;
  const FileName: string);
var
  EditorText: string;
  EditorLines: TStringList;
begin
  if SaveEditor.Lines.Count > 0 then
  begin
    EditorText := SaveEditor.Text;
    // strip additional blank lines added by the compare engine from the file
    while (Length(EditorText) > 0) and
          (EditorText[Length(EditorText)] in [' ', #10, #13]) do
      System.Delete(EditorText, Length(EditorText), 1);
    EditorText := EditorText + #10#13;

    // translate the text back into single lines
    EditorLines := TStringList.Create;
    try
      EditorLines.SetText(PChar(EditorText));
      try
        EditorLines.SaveToFile(FileName);
      except
        on E:Exception do
          MessageBox(WindowHandle,
            PChar(Format(JVCSRES_Unable_to_save58_37s, [FileName]) + #10#13 +
            Format(JVCSRES_Exception58_37s, [E.Message])), cMessageBoxCaption, MB_OK or MB_ICONSTOP);
      end;
    finally
      EditorLines.Free;
    end;
  end;
  SaveEditor.Modified := False;
  SaveEditor.ClearUndo;
  if SaveEditor = mwceSource then
    SourceFooter.Caption := ''
  else
    TargetFooter.Caption := '';

  acSaveChanges.Enabled := False;
  acSaveCompare.Enabled := acSaveChanges.Enabled;
end;

procedure Tfm_Main.acSaveChangesExecute(Sender: TObject);
var
  SaveFileName: string;
begin
  if ActiveEditorView = mwceSource then
    SaveFileName := rcbSource.Text
  else
    SaveFileName := rcbTarget.Text;

  if ActiveEditorView.ReadOnly then
    SaveAs2Click(Self)
  else
    SaveChanges(ActiveEditorView, SaveFileName);
end;

procedure Tfm_Main.SaveAs2Click(Sender: TObject);
var
  SaveFileName,
  DlgTitle: string;
begin
  if ActiveEditorView = mwceSource then
  begin
    DlgTitle := JVCSRES_Save_left_editor_view;
    SaveFileName := rcbSource.Text;
  end
  else
  begin
    DlgTitle := JVCSRES_Save_right_editor_view;
    SaveFileName := rcbTarget.Text;
  end;

  with SaveDialog1 do
  begin
    Title := DlgTitle;
    InitialDir := ExtractFilePath(SaveFileName);
    FileName := ExtractFileName(SaveFileName);
    if Execute then
    begin
      SaveChanges(ActiveEditorView, FileName);

      if ActiveEditorView = mwceSource then
      begin
        FileNames[1] := FileName;
        rcbSource.Text := FileName;
      end
      else
      begin
        FileNames[2] := FileName;
        rcbTarget.Text := FileName;
      end;
    end
    else
      Exit;
  end;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  SaveSettings;
  CanClose := SaveSourceChanges;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.mwceSourcePaint(Sender: TObject;
  ACanvas: TCanvas);
begin
  if not CompareInProgess then
  begin
    if mwceTarget.TopLine <> mwceSource.TopLine then
      mwceTarget.TopLine := mwceSource.TopLine;
    if mwceTarget.LeftChar <> mwceSource.LeftChar then
      mwceTarget.LeftChar := mwceSource.LeftChar;
    LoadInfo(Sender);
  end;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.mwceTargetPaint(Sender: TObject;
  ACanvas: TCanvas);
begin
  if not CompareInProgess then
  begin
    if mwceSource.TopLine <> mwceTarget.TopLine then
      mwceSource.TopLine := mwceTarget.TopLine;
    if mwceSource.LeftChar <> mwceTarget.LeftChar then
      mwceSource.LeftChar := mwceTarget.LeftChar;
    LoadInfo(Sender);
  end;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.mwceSourceChange(Sender: TObject);
var
  Mark: TSynEditMark;
begin
  if not CompareInProgess then
  begin
    if Sender is TSynEdit then
    begin
      if (Sender as TSynEdit) = mwceSource then
        mwceTarget.CaretY := mwceSource.CaretY
      else
        mwceSource.CaretY := mwceTarget.CaretY;
    end;

    with mwceSource do
    begin
      Marks.ClearLine(CaretY);
      if (StripString(LineText) <> StripString(mwceTarget.LineText)) then
      begin
        Mark := TSynEditMark.Create;
        with Mark do
        begin
          Line := CaretY;
          Char := 0;
          ImageIndex := 11;
  //hu30.12.2002         IsBookmark := False;
          Visible := True;
          InternalImage := False;
        end;
        Marks.Add(Mark);
      end;
    end;

    if Sender is TSynEdit then
    begin
      if (Sender as TSynEdit) = mwceSource then
        SourceFooter.Caption := JVCSRES__Modified
      else
        TargetFooter.Caption := JVCSRES__Modified;
    end;

    acSaveChanges.Enabled := True;
    acSaveCompare.Enabled := acSaveChanges.Enabled;
    LoadInfo(Sender);
  end;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.LoadInfo(const Sender: TObject);
begin
  if Sender <> nil then
  begin
    dfsStatusBar1.Panels[0].Text :=
      IntToStr((Sender as TSynEdit).CaretX) + ' - ' +
      IntToStr((Sender as TSynEdit).CaretY) + '/' +
      IntToStr((Sender as TSynEdit).Lines.Count);
    if Sender = mwceSource then
    begin
      if mwceSource.ReadOnly then
        SourceFooter.Caption := JVCSRES__ReadOnly
      else
        if mwceSource.Modified then
          SourceFooter.Caption := JVCSRES__Modified
        else
          SourceFooter.Caption := '';

      acEnableEditor.Enabled := not EnableLeftEdit;
      tbEnableEditor.Down := not mwceSource.ReadOnly;
      acSaveChanges.Enabled := mwceSource.Modified;
      acSaveCompare.Enabled := acSaveChanges.Enabled;
      acUndo.Enabled := mwceSource.CanUndo;
      acRedo.Enabled := mwceSource.CanRedo;
    end
    else
    begin
      if mwceTarget.ReadOnly then
        TargetFooter.Caption := JVCSRES__ReadOnly
      else
        if mwceTarget.Modified then
          TargetFooter.Caption := JVCSRES__Modified
        else
          TargetFooter.Caption := '';

      acEnableEditor.Enabled := not EnableLeftEdit;
      tbEnableEditor.Down := not mwceSource.ReadOnly;
      acSaveChanges.Enabled := mwceTarget.Modified;
      acSaveCompare.Enabled := acSaveChanges.Enabled;
      acUndo.Enabled := mwceTarget.CanUndo;
      acRedo.Enabled := mwceTarget.CanRedo;
    end;
  end;
  EnableNavButtons;
  Define1.Enabled := (fm_Main.ActiveControl = mwceSource);
  GoTo1.Enabled := Define1.Enabled;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.mwceSourceKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  LoadInfo(Sender);
end;

procedure Tfm_Main.mwceSourceClick(Sender: TObject);
begin
  LoadInfo(Sender);
end;

procedure Tfm_Main.mwceSourceEnter(Sender: TObject);
begin
  if not CompareInProgess then
  begin
    ActiveEditorView := Sender as TSynEdit;
    if ActiveEditorView = mwceSource then
    begin
      SourceHeader.Font.Style := [fsBold];
      SourceHeader.Font.Color := clNavy;
      TargetHeader.Font.Style := [];
      TargetHeader.Font.Color := clWindowText;
    end
    else
    begin
      SourceHeader.Font.Style := [];
      SourceHeader.Font.Color := clWindowText;
      TargetHeader.Font.Style := [fsBold];
      TargetHeader.Font.Color := clNavy;
    end;
    SourceFooter.Font := SourceHeader.Font;
    TargetFooter.Font := TargetHeader.Font;

    LoadInfo(Sender);
  end;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.acEnableEditorExecute(Sender: TObject);
begin
  mwceSource.ReadOnly := not mwceSource.ReadOnly;
  if not mwceSource.ReadOnly then
    if (Pos('compare\1\', FileNames[1]) > 0) or
       ((FileGetAttr(FileNames[1]) and faReadOnly) = faReadOnly) then
    begin
      MessageBox(WindowHandle, PChar(
        JVCSRES_This_is_a_read45only_file_or_just_a_temporary_file_copy_created_by_JEDI_VCS
        + #10#13 + JVCSRES_40probably_the_file_is_curently_checked_in4146 + #10#13 +
        JVCSRES_Therefore_this_file_cannot_be_edited46), cMessageBoxCaption,
        MB_OK or MB_ICONWARNING);
      mwceSource.ReadOnly := True
    end;

  tbEnableEditor.Down := not mwceSource.ReadOnly;
  acEnableEditor.Checked := tbEnableEditor.Down;
  if mwceSource.ReadOnly then
    SourceFooter.Caption := JVCSRES__ReadOnly
  else
   if mwceSource.Modified then
     SourceFooter.Caption := JVCSRES__Modified
   else
     SourceFooter.Caption := '';
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.acUndoExecute(Sender: TObject);
begin
  with ActiveEditorView do
  begin
    Undo;
    SetFocus;
  end;
end;

procedure Tfm_Main.acRedoExecute(Sender: TObject);
begin
  with ActiveEditorView do
  begin
    Redo;
    SetFocus;
  end;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.popmEditorPopup(Sender: TObject);
begin
  acEditCopy.Enabled := ActiveEditorView.SelAvail;
  acEditCut.Enabled := (not ActiveEditorView.ReadOnly) and
                       ActiveEditorView.SelAvail;
  acEditPaste.Enabled := not ActiveEditorView.ReadOnly;
  DeleteFile1.Enabled := acEditPaste.Enabled;
  CopyLinetoleftEditor1.Enabled := (ActiveEditorView.Name = 'mwceTarget'); //todo
end;

procedure Tfm_Main.acEditCopyExecute(Sender: TObject);
begin
  ActiveEditorView.CopyToClipboard;
end;

procedure Tfm_Main.acEditCutExecute(Sender: TObject);
begin
  ActiveEditorView.CutToClipboard;
end;

procedure Tfm_Main.acEditPasteExecute(Sender: TObject);
begin
  ActiveEditorView.PasteFromClipboard;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.Bookmark02Click(Sender: TObject);
begin
  with mwceSource do
  begin
    SetBookMark((Sender as TMenuItem).Tag, CaretX, CaretY);
    SetFocus;
  end;
end;

procedure Tfm_Main.Bookmark01Click(Sender: TObject);
begin
  with mwceSource do
  begin
    GotoBookMark((Sender as TMenuItem).Tag);
    SetFocus;
  end;
end;

//=== Assign the syntax highlighter to both editor views =======================

procedure Tfm_Main.cbxHighlighterChange(Sender: TObject);
begin
  if cbxHighlighter.ItemIndex > 0 then
  begin
    mwceSource.Highlighter :=
      cbxHighlighter.Items.Objects[cbxHighlighter.ItemIndex] as
      TSynCustomHighlighter;

    if mwceSource.Highlighter <> nil then
    begin
      mwceSource.Highlighter.LoadFromRegistry(HKEY_CURRENT_USER,
        RegDiffOptions + '\Highlighters\' + mwceSource.Highlighter.LanguageName);

      mwceTarget.Highlighter := mwceSource.Highlighter;
    end;
  end
  else
  begin
    mwceSource.Highlighter := nil;
    mwceTarget.Highlighter := mwceSource.Highlighter;
  end;
end;

procedure Tfm_Main.SetHighLighter;

  // This bit is stolen from EditU2.pas
  function MatchesExtension(ext: string; light: TSynCustomHighlighter): Boolean;
    var
    fext  : string;
    idx   : Integer;
    ucext : string;
    filter: string;
    P     : Integer;
  begin
    Result := False;
    ucext := AnsiUpperCase(ext);
    P := Pos('.',ucext);
    if P > 0 then ucext := Copy(ucext,P+1,Length(ucext)-P);
    P := Pos('|',light.DefaultFilter);
    if P > 0 then
    begin
      filter := Copy(light.DefaultFilter,P+1,Length(light.DefaultFilter)-P);
      while filter <> '' do
      begin
        P := Pos(';',filter);
        if P = 0 then P := Length(filter)+1;
        fext := Copy(filter,1,P-1);
        filter := Copy(filter,P+1,Length(filter)-P);
        P := Pos('.',fext);
        if P > 0 then fext := Copy(fext,P+1,Length(fext)-P);
        if UpperCase(fext) = ucext then
        begin
          idx := cbxHighlighter.Items.IndexOf(light.LanguageName);
          if idx >= 0 then cbxHighlighter.ItemIndex := idx;
          cbxHighlighterChange(Self);
          mwceSource.Highlighter := light;
          Result := True;
        end;
      end; //while
    end
  end; { MatchesExtension }

var
  I: Integer;
  ext: string;
  backCursor: TCursor;
begin
  backCursor := Cursor;
  try
    Cursor := crHourGlass;
    Windows.SetCursor(Screen.Cursors[crHourGlass]);
    ext := AnsiUpperCase(ExtractFileExt(FileNames[1]));
    mwceTarget.Highlighter := nil;
    mwceSource.Highlighter := nil;
    for I := 0 to ComponentCount - 1 do
      if Components[I] is TSynCustomHighlighter then
      begin
        if MatchesExtension(ext,Components[I] as TSynCustomHighlighter) then
          Break;
      end;
  finally
    Cursor := backCursor;
  end;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.AlignSplitter1Click(Sender: TObject);
begin
  Panel3.Width := Panel4.Width div 2;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.acFlipExecute(Sender: TObject);
var
  Buffer: string;
begin
  if not SaveSourceChanges then
    Exit;
  Buffer := rcbSource.Text;
  rcbSource.Text := rcbTarget.Text;
  rcbTarget.Text := Buffer;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.ClearAll1Click(Sender: TObject);
var
  I: Integer;
begin
  {for I := 0 to mwceSource.Lines.Count - 1 do
    mwceSource.Marks.ClearLine(I);}

  for I := mwceSource.Marks.Count - 1 downto 0 do
    if mwceSource.Marks[I].IsBookmark then
      mwceSource.Marks.Remove(mwceSource.Marks[I]);
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.acLastCompareExecute(Sender: TObject);
var
  BaseFile,
  CompareFile: string;
begin
  with TRegistry.Create do
  begin
    try
      RootKey := HKEY_CURRENT_USER;
      OpenKeyReadOnly(RegDiffOptions);
      if ValueExists('LastBaseFile') then
        BaseFile := ReadString('LastBaseFile')
      else
        BaseFile := '';
      if ValueExists('LastCompareFile') then
        CompareFile := ReadString('LastCompareFile')
      else
        CompareFile := '';
      CloseKey;
    finally
      Free;
    end;
  end;

  if (BaseFile = '') or (CompareFile = '') then
  begin
    MessageBox(WindowHandle, PChar(JVCSRES_MRU_items_are_blank46), cMessageBoxCaption,
      MB_OK or MB_ICONINFORMATION);
    Exit;
  end;
  rcbSource.Text := LowerCase(BaseFile);
  rcbTarget.Text := LowerCase(CompareFile);
  StartTimer.Enabled := True;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.acSearchExecute(Sender: TObject);
begin
  FindDialog1.Execute;
  acSearchNext.Enabled := True;
  acSearchPrev.Enabled := True;
end;

procedure Tfm_Main.acSearchPrevExecute(Sender: TObject);
begin
  if (Sender = acSearchNext) then
    FindDialog1.Options := FindDialog1.Options + [frDown]
  else
  if (Sender = acSearchPrev) then
    FindDialog1.Options := FindDialog1.Options - [frDown];
  FindDialog1Find(Sender);
  ActiveEditorView.SetFocus;
end;

procedure Tfm_Main.FindDialog1Find(Sender: TObject);
var
  rOptions: TSynSearchOptions;
  dlg: TFindDialog;
  sSearch: string;
begin
  if Sender = ReplaceDialog1 then
    dlg := ReplaceDialog1
  else
    dlg := FindDialog1;

  sSearch := dlg.FindText;
  if Length(sSearch) = 0 then
  begin
    MessageBox(WindowHandle, PChar(JVCSRES_Can39t_search_for_empty_text33), cMessageBoxCaption,
      MB_OK or MB_ICONINFORMATION);
  end
  else
  begin
    rOptions := [];
    if not (frDown in dlg.Options) then
      Include(rOptions, ssoBackwards);
    if frMatchCase in dlg.Options then
      Include(rOptions, ssoMatchCase);
    if frWholeWord in dlg.Options then
      Include(rOptions, ssoWholeWord);
    if ActiveEditorView.SearchReplace(sSearch, '', rOptions) = 0 then
    begin
      MessageBox(WindowHandle, PChar(Format(JVCSRES_SearchText_3937s39_not_found33,
        [sSearch])), cMessageBoxCaption, MB_OK or MB_ICONINFORMATION);
    end;
  end;
end;

procedure Tfm_Main.acReplaceExecute(Sender: TObject);
begin
  ReplaceDialog1.Execute;
end;

procedure Tfm_Main.ReplaceDialog1Replace(Sender: TObject);
var
  rOptions: TSynSearchOptions;
  sSearch: string;
begin
  sSearch := ReplaceDialog1.FindText;
  if Length(sSearch) = 0 then
  begin
    MessageBox(WindowHandle, PChar(JVCSRES_Can39t_replace_an_empty_text33),
      cMessageBoxCaption, MB_OK or MB_ICONINFORMATION);
  end
  else
  begin
    rOptions := [ssoReplace];
    if frMatchCase in ReplaceDialog1.Options then
      Include(rOptions, ssoMatchCase);
    if frWholeWord in ReplaceDialog1.Options then
      Include(rOptions, ssoWholeWord);
    if frReplaceAll in ReplaceDialog1.Options then
      Include(rOptions, ssoReplaceAll);
    if ActiveEditorView.SearchReplace(sSearch, ReplaceDialog1.ReplaceText, rOptions) = 0 then
    begin
      MessageBox(WindowHandle,
        PChar(Format(JVCSRES_SearchText_3437s34_could_not_be_replaced33, [sSearch])),
        cMessageBoxCaption, MB_OK or MB_ICONINFORMATION);
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.EditorProperties1Click(Sender: TObject);
begin
  fm_EditorProp := Tfm_EditorProp.Create(Application);
  try
    with fm_EditorProp do
    begin
      speMaxUndo.Value := mwceSource.MaxUndo;
      pnEditorFont.Font.Assign(mwceSource.Font);
      pnEditorFont.Caption := pnEditorFont.Font.Name + ', ' +
        IntToStr(pnEditorFont.Font.Size) + ' pt';
      speRightEdge.Value := mwceSource.RightEdge;
      speLineSpacing.Value := mwceSource.ExtraLineSpacing;
      speTabWidth.AsInteger := mwceSource.TabWidth;
      cbEnableLeftEditor.Checked := EnableLeftEdit;
      cbEnableRightEditor.Checked := EnableRightEdit;
      Top := fm_Main.Top + 100;
      Left := fm_Main.Left + 100;
      if ShowModal = mrOk then
      begin
        mwceSource.MaxUndo := speMaxUndo.AsInteger;
        mwceSource.Font.Assign(pnEditorFont.Font);
        mwceTarget.Font.Assign(pnEditorFont.Font);
        mwceSource.RightEdge := speRightEdge.AsInteger;
        mwceSource.ExtraLineSpacing := speLineSpacing.AsInteger;
        mwceSource.TabWidth := speTabWidth.AsInteger;
        mwceTarget.RightEdge := mwceSource.RightEdge;
        mwceTarget.ExtraLineSpacing := mwceSource.ExtraLineSpacing;
        mwceTarget.TabWidth := mwceSource.TabWidth;        
        EnableLeftEdit := cbEnableLeftEditor.Checked;
        EnableRightEdit := cbEnableRightEditor.Checked;
        mwceSource.ReadOnly :=  not EnableLeftEdit;
        mwceTarget.ReadOnly := not EnableRightEdit;
        tbEnableEditor.Down := not mwceSource.ReadOnly;
        acEnableEditor.Checked := tbEnableEditor.Down;
        tbEnableEditor.Enabled :=  not EnableLeftEdit;
        acEnableEditor.Enabled :=  not EnableLeftEdit;
      end;
    end;
  finally
    fm_EditorProp.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.acHighLightPropExecute(Sender: TObject);
begin
  if mwceSource.Highlighter = nil then
    mwceSource.Highlighter := mwGeneralSyn1;
  fm_HighLightProp := Tfm_HighLightProp.Create(self);
  try
    fm_HighLightProp.Top := Top + 100;
    fm_HighLightProp.Left := Left + 100;
    fm_HighLightProp.ShowModal;
  finally
    fm_HighLightProp.Free;
  end;
  EnumerateHighlighters;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.DisableBinaryFileChecking1Click(Sender: TObject);
begin
  DisableBinaryFileChecking1.Checked := not DisableBinaryFileChecking1.Checked;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.acIgWSpaceExecute(Sender: TObject);
begin
  acIgWSpace.Checked := not acIgWSpace.Checked;
  acHardSpace.Enabled := acIgWSpace.Checked;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.acIgHTMLExecute(Sender: TObject);
begin
  acIgHTML.Checked := not acIgHTML.Checked;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.acHardSpaceExecute(Sender: TObject);
begin
  acHardSpace.Checked := not acHardSpace.Checked;
  if acHardSpace.Checked then
    WhiteSpace := WhiteSpace + [#160]
  else
    WhiteSpace := WhiteSpace - [#160];
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.acIgCaseExecute(Sender: TObject);
begin
  acIgCase.Checked := not acIgCase.Checked;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.acIgLFCRExecute(Sender: TObject);
begin
  acIgLFCR.Checked := not acIgLFCR.Checked;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.ShowResultDialog1Click(Sender: TObject);
begin
  ShowResultDialog1.Checked := not ShowResultDialog1.Checked;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // set TForm.KeyPreview := true !
  if Key = VK_F1 then
    acHelpExecute(Self);
  if (ssCtrl in Shift) and (Key = VK_TAB) then
  begin
    if ActiveEditorView = mwceSource then
      mwceTarget.SetFocus
    else
      mwceSource.SetFocus;
  end;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.acHelpExecute(Sender: TObject);
begin
  ShowHelpContext(Application, IDH_jvcsdiff_welcome);
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.Delete1Click(Sender: TObject);
var
  FileName,
  DlgMsg: string;
begin
  if ActiveEditorView = mwceSource then
  begin
    DlgMsg := JVCSRES_Left_editor_view58 + #10#13;
    FileName := rcbSource.Text;
  end
  else
  begin
    DlgMsg := JVCSRES_Right_editor_view58 + #10#13;
    FileName := rcbTarget.Text;
  end;

  if MessageBox(WindowHandle,
      PChar(DlgMsg + JVCSRES_Are_you_sure_you_want_to_delete_the_file + #10#13 +
      '<' + FileName + '> ?' + #10#13 +
      JVCSRES_Remember_that_you_are_about_to_delete_the_file_on_disk33),
      cMessageBoxCaption, MB_YESNOCANCEL or MB_DEFBUTTON2 or
      MB_ICONQUESTION) <> id_Yes then Exit;

  if not DeleteFile(FileName) then
    MessageBox(WindowHandle,
      PChar(JVCSRES_Unable_to_delete_the_file + #10#13 +
      '<' + FileName + '>'), cMessageBoxCaption, MB_OK or MB_ICONWARNING);
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.acSaveCompareExecute(Sender: TObject);
begin
  acSaveChangesExecute(Self);
  Sleep(1000);
  acCompareExecute(Self);
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.CopyLinetoleftEditor1Click(Sender: TObject);
begin
  mwceSource.CaretY := mwceTarget.CaretY;
  mwceSource.LineText := mwceTarget.LineText;
  Sleep(100);
  mwceSource.Modified := True;
  mwceSourceChange(mwceSource);
  acSaveChanges.Enabled := True;
  acSaveCompare.Enabled := acSaveChanges.Enabled;
end;

//=== Hex Viewer ===============================================================

procedure Tfm_Main.ShowDiffasHexCode1Click(Sender: TObject);
begin
  if WholeLinePanel.Visible then
    WholeLinePanel.Visible := False;
  if not HexViewPanel.Visible then
    HexViewPanel.Visible := True;

  if (ActiveEditorView.Name = 'mwceTarget') then //todo
    mwceSource.CaretY := mwceTarget.CaretY
  else
    mwceTarget.CaretY := mwceSource.CaretY;

  HexViewLabel.Caption := JVCSRES_Hex_View;
  if acIgCase.Checked then
    HexViewLabel.Caption := HexViewLabel.Caption + JVCSRES__45_Case58_ignored;
  if acIgLFCR.Checked then
    HexViewLabel.Caption := HexViewLabel.Caption + JVCSRES__45_LFCR58_stripped;
  if acIgWSpace.Checked then
  begin
    HexViewLabel.Caption := HexViewLabel.Caption + JVCSRES__45_Whitespace58_stripped;
    if acHardSpace.Checked then
      HexViewLabel.Caption := HexViewLabel.Caption + JVCSRES__45_Hard_space58_stripped;
  end;
  if acIgHTML.Checked then
    HexViewLabel.Caption := HexViewLabel.Caption + JVCSRES__45_HTML_Tags58_stripped;

  ShowHexDiff(StripString(mwceSource.LineText), StripString(mwceTarget.LineText));
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.ShowHexDiff(const BaseLineText, TargetLineText: string);
var
  BaseHex,
  TargetHex: string;
  BaseHexPos,
  TargetHexPos,
  BaseHexLength,
  TargetHexLength,
  I: Integer;
const
  BLankSign = ' ';
begin
  Screen.Cursor := crHourGlass;
  LockWindowUpdate(HexView.Handle);
  with HexView do
  begin
    Clear;
    SelAttributes.Color := clNavy;
    SelStart := 0;
    Text := Text + JVCSRES__Base___ASCII62;
    for I := 1 to Length(BaseLineText) do
      Text := Text + '  ' + BaseLineText[I];
    Text := Text + #10;
    Text := Text + JVCSRES__Base_____Hex62;
    for I := 1 to Length(BaseLineText) do
      Text := Text + BLankSign + IntToHex(Ord(BaseLineText[I]), 2);
    Text := Text + #10;
    Text := Text + JVCSRES__Target_ASCII62;
    for I := 1 to Length(TargetLineText) do
      Text := Text + '  ' + TargetLineText[I];
    Text := Text + #10;
    Text := Text + JVCSRES__Target___Hex62;
    for I := 1 to Length(TargetLineText) do
      Text := Text + BLankSign + IntToHex(Ord(TargetLineText[I]), 2);

    SelStart := 0;
    SelLength := Length(JVCSRES__Base___ASCII62);
    SelAttributes.Color := clWindowText;
    I := Pos(JVCSRES__Target_ASCII62, Text) - 1;
    SelStart := I;
    SelLength := Length(JVCSRES__Target_ASCII62);
    SelAttributes.Color := clWindowText;
    BaseHexPos := Pos(JVCSRES__Base_____Hex62, Text) + Length(JVCSRES__Base_____Hex62) - 1;
    SelStart := BaseHexPos - Length(JVCSRES__Base_____Hex62);
    SelLength := Length(JVCSRES__Base_____Hex62);
    SelAttributes.Color := clWindowText;
    TargetHexPos := Pos(JVCSRES__Target___Hex62, Text) + Length(JVCSRES__Target___Hex62) - 1;
    SelStart := TargetHexPos - Length(JVCSRES__Target___Hex62);
    SelLength := Length(JVCSRES__Target___Hex62);
    SelAttributes.Color := clWindowText;

    BaseHex := Copy(Text, BaseHexPos, Pos(JVCSRES__Target_ASCII62, Text) - BaseHexPos);
    TargetHex := Copy(Text, TargetHexPos, Length(Text) - BaseHexPos);
    BaseHexLength := Length(BaseHex);
    TargetHexLength := Length(TargetHex);

    for I := 1 to BaseHexLength do
      if (BaseHex[I] <> BLankSign) and
         (BaseHex[I] <> #10) and
         ((I > TargetHexLength) or
          (BaseHex[I] <> TargetHex[I])) then
      begin
        if (I > 1) and (BaseHex[I - 1] = BLankSign) then
          SelStart := (BaseHexPos + I) - 2
        else
          SelStart := (BaseHexPos + I) - 3;
        SelLength := 2;
        SelAttributes.Color := clRed;
      end;

    for I := 1 to TargetHexLength do
      if (TargetHex[I] <> BLankSign) and
         (TargetHex[I] <> #10) and
         ((I > BaseHexLength) or
          (BaseHex[I] <> TargetHex[I])) then
      begin
        if (I > 1) and (TargetHex[I - 1] = BLankSign) then
          SelStart := (TargetHexPos + I) - 2
        else
          SelStart := (TargetHexPos + I) - 3;
        SelLength := 2;
        SelAttributes.Color := clRed;
      end;

    SelLength := 0;
  end; // with HexView do
  LockWindowUpdate(0);
  Screen.Cursor := crDefault;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.spBtnHexViewCloseClick(Sender: TObject);
begin
  HexViewPanel.Visible := False;
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.spBtnHexViewRightClick(Sender: TObject);
begin
  SendMessage(HexView.Handle, WM_HSCROLL, SB_PAGERIGHT, 0);
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.spBtnHexViewLeftClick(Sender: TObject);
begin
  SendMessage(HexView.Handle, WM_HSCROLL, SB_PAGELEFT, 0);
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.ShowcompleteLines1Click(Sender: TObject);
var
  Line: string;
  I: Integer;
begin
  if HexViewPanel.Visible then
    HexViewPanel.Visible := False;
  if not WholeLinePanel.Visible then
    WholeLinePanel.Visible := True;

  if (ActiveEditorView.Name = 'mwceTarget') then //todo
    mwceSource.CaretY := mwceTarget.CaretY
  else
    mwceTarget.CaretY := mwceSource.CaretY;

  LineView.Lines.Clear;
  Line := StripString(mwceSource.LineText);
  LineView.Text := LineView.Text + JVCSRES__Base___ASCII62+ ' ';
  for I := 1 to Length(Line) do
    if (not (Line[I] in LineEnd)) then
      LineView.Text := LineView.Text + Line[I];
  LineView.Text := LineView.Text + #13#10;
  Line := StripString(mwceTarget.LineText);
  LineView.Text := LineView.Text + JVCSRES__Target_ASCII62 + ' ';
  for I := 1 to Length(Line) do
    if (not (Line[I] in LineEnd)) then
      LineView.Text := LineView.Text + Line[I];
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.spBtnLineViewLeftClick(Sender: TObject);
begin
  SendMessage(LineView.Handle, WM_HSCROLL, SB_PAGELEFT, 0);
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.spBtnLineViewRightClick(Sender: TObject);
begin
  SendMessage(LineView.Handle, WM_HSCROLL, SB_PAGERIGHT, 0);
end;

//------------------------------------------------------------------------------

procedure Tfm_Main.spBtnLineViewCloseClick(Sender: TObject);
begin
  WholeLinePanel.Visible := False;
end;

procedure Tfm_Main.JvMruListSourceEnumText(Sender: TObject; Value: string;
  Index: Integer);
begin
  // Assign to source edit
  if Index = 0 then
  begin
    rcbSource.Text := Value;
  end;
  rcbSource.Items.Add(Value);
end;

procedure Tfm_Main.JvMruListTargetEnumText(Sender: TObject; Value: string;
  Index: Integer);
begin
  // Assign to target edit
  if Index = 0 then
  begin
    rcbTarget.Text := Value;
  end;
  rcbTarget.Items.Add(Value);
end;

procedure Tfm_Main.FormDestroy(Sender: TObject);
begin
  {$IFNDEF  DELPHI7_UP}
  FreeAndNil(FThemeManager);
  {$ENDIF ~DELPHI7_UP}
end;

procedure Tfm_Main.CreateParams(var Params: TCreateParams);
begin
  // fixes VISTA Taskbarsupport
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle and not WS_EX_TOOLWINDOW or WS_EX_APPWINDOW;
end;

procedure Tfm_Main.WMSyscommand(var Message: TWmSysCommand);
begin
  // fixes VISTA Taskbarsupport
  case (Message.CmdType and $FFF0) of
    SC_MINIMIZE:
    begin
      ShowWindow(Handle, SW_MINIMIZE);
      Message.Result := 0;
    end;
    SC_RESTORE:
    begin
      ShowWindow(Handle, SW_RESTORE);
      Message.Result := 0;
    end;
  else
    inherited;
  end;
end;

procedure Tfm_Main.WMActivate(var Message: TWMActivate);
begin
  // fixes VISTA Taskbarsupport
  if (Message.Active = WA_ACTIVE) and not IsWindowEnabled(Handle) then
  begin
    SetActiveWindow(Application.Handle);
    Message.Result := 0;
  end else
    inherited;
end;

end.

