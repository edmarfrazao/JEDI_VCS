(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSLineHistoryUnit.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
ToDo
- load all Line History information (LINEINFOEX) from the .jvcsEx2 file
-----------------------------------------------------------------------------

Unit history:

2006/04/01  USchuster - new unit
2006/04/14  USchuster - changes for variable date format string
2006/04/16  USchuster - added summary classes
                      - changes for revision comment
2006/11/29  USchuster - added support for "DateFormat" AGE
2006/12/03  USchuster - added TJVCSLineHistorySettings
2006/12/10  USchuster - added percent to summary
2007/08/15  USchuster - first changes for extented line information
                      - changes for Age2
2007/10/28  USchuster - some more changes for extented line information
2007/11/14  USchuster - some more changes for extented line information
2007/11/21  USchuster - added extented line information parameter to TJVCSLineHistorySettings
2008/02/20  USchuster - changes for extended items in TJVCSLineHistoryModuleRevisionList
2008/10/29  USchuster - moved TJVCSLineHistoryRevisionKind, TJVCSLineHistoryRevisionLink,
                        BuildLineHistoryInfo and EncodeFileName from JVCSLineHistoryFrame.pas to this unit
2008/11/02  USchuster - turned BuildLineHistoryInfo into TJVCSLineHistoryBuilder
2008/11/06  USchuster - modularized cached history information handling
2008/12/21  USchuster - fixed storing of cached history if directory doesn't exists yet (broken in prior revision)
2009/01/12  USchuster - implemented zipped xml format for extented line information
2009/03/21  USchuster - changes for alternative visible user names and option to suppress "0." in the revision str
2009/04/03  USchuster - added missing binary .dfm decoding for local file
2009/04/11  USchuster - changes to prevent saving the same cached history information again
2009/09/07  USchuster - added VisibleUserName to TJVCSLineHistory*Summary to fix the color
                        in the summary treeview when the user color is clNone or clDefault
2010/01/10  USchuster - added TJVCSCustomLineHistoryModuleProvider.GetModuleCheckoutState (for Mantis #5083)
2010/02/06  USchuster - small fix for loading cached Line History information (LINEINFOEX)

-----------------------------------------------------------------------------*)

unit JVCSLineHistoryUnit;

{$I jedi.inc}

interface

uses
  SysUtils, Classes, Graphics, Contnrs, DiffUnit, HashUnit;

const
  AgeDateFormat = 'AGE';
  Age2DateFormat = 'AGE2';  

type
  TJVCSLineHistoryRevision = class(TObject)
  private
    FRevisionID: Integer;
    FRevisionStr: string;
    FOrgUserStr: string;
    FOrgRevisionStr: string;
    FUserStr: string;
    FDateStr: string;
    FDate: TDateTime;
    FComment: string;
    {$IFDEF LINEINFOEX}
    FLineInfos: TObjectList;
    {$ENDIF LINEINFOEX}
    FLines: TStringList;
  protected
    {$IFDEF LINEINFOEX}
    property LineInfos: TObjectList read FLineInfos;
    {$ENDIF LINEINFOEX}
    property Lines: TStringList read FLines;
  public
    constructor Create(ARevisionID: Integer; ALines: TStrings);
    destructor Destroy; override;
    property RevisionID: Integer read FRevisionID;
    property RevisionStr: string read FRevisionStr write FRevisionStr;
    property OrgUserStr: string read FOrgUserStr write FOrgUserStr;
    property OrgRevisionStr: string read FOrgRevisionStr write FOrgRevisionStr;
    property UserStr: string read FUserStr write FUserStr;
    property DateStr: string read FDateStr write FDateStr;
    property Date: TDateTime read FDate write FDate;
    property Comment: string read FComment write FComment;
  end;

  TJVCSLineHistorySummary = class;

  TJVCSLineHistoryRevisionSummary = class(TObject)
  private
    FLineHistoryRevision: TJVCSLineHistoryRevision;
    FLineCount: Integer;
    FParent: TJVCSLineHistorySummary;
    FPercent: Double;
  protected
    procedure IncLineCount;
  public
    constructor Create(AParent: TJVCSLineHistorySummary; ALineHistoryRevision: TJVCSLineHistoryRevision);
    property LineHistoryRevision: TJVCSLineHistoryRevision read FLineHistoryRevision;
    property LineCount: Integer read FLineCount;
    property Percent: Double read FPercent;
  end;

  TJVCSLineHistoryUserSummary = class(TObject)
  private
    FUserName: string;
    FLineCount: Integer;
    FParent: TJVCSLineHistorySummary;
    FPercent: Double;
    FVisibleUserName: string;
  protected
    procedure IncLineCount;
  public
    constructor Create(AParent: TJVCSLineHistorySummary; const AUserName: string);
    property UserName: string read FUserName;
    property LineCount: Integer read FLineCount;
    property Percent: Double read FPercent;
    property VisibleUserName: string read FVisibleUserName write FVisibleUserName;
  end;

  TJVCSLineHistory = class;

  TJVCSLineHistorySummary = class(TObject)
  private
    FLineCount: Integer;
    FRevisionItems: TObjectList;
    FUserItems: TObjectList;
    procedure Clear;
    function GetRevisionCount: Integer;
    function GetRevisionSummary(AIndex: Integer): TJVCSLineHistoryRevisionSummary;
    function GetUserCount: Integer;
    function GetUserSummary(AIndex: Integer): TJVCSLineHistoryUserSummary;
  public
    constructor Create;
    destructor Destroy; override;

    procedure FillFromLineHistory(ALineHistory: TJVCSLineHistory);
    function FindRevisionSummary(ALineHistoryRevision: TJVCSLineHistoryRevision): TJVCSLineHistoryRevisionSummary;
    function FindUserSummary(const AUserName, AVisibleUserName: string): TJVCSLineHistoryUserSummary;
    procedure UpdateVisibleStrings(ALineHistory: TJVCSLineHistory);

    property LineCount: Integer read FLineCount;
    property RevisionCount: Integer read GetRevisionCount;
    property RevisionSummary[AIndex: Integer]: TJVCSLineHistoryRevisionSummary read GetRevisionSummary;
    property UserCount: Integer read GetUserCount;
    property UserSummary[AIndex: Integer]: TJVCSLineHistoryUserSummary read GetUserSummary;
  end;

  {$IFDEF LINEINFOEX}
  TJVCSLineHistoryLineInfo = class(TObject)
  private
    FRevisions: TList;
    FLineNumbers: TList;
    function GetCount: Integer;
    function GetRevision(AIndex: Integer): TJVCSLineHistoryRevision;
    function GetLineNumber(AIndex: Integer): Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(ARevision: TJVCSLineHistoryRevision; ALineNumber: Integer);
    procedure Assign(ALineInfo: TJVCSLineHistoryLineInfo);
    property Count: Integer read GetCount;
    property Revision[AIndex: Integer]: TJVCSLineHistoryRevision read GetRevision; default;
    property LineNumber[AIndex: Integer]: Integer read GetLineNumber;
  end;
  {$ENDIF LINEINFOEX}

  {$IFDEF LINEINFOEX}
  TJVCSLineHistoryCompressedLineInfo = class(TObject)
  private
    FInfo: TJVCSLineHistoryLineInfo;
    FLineCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    property Info: TJVCSLineHistoryLineInfo read FInfo;
    property LineCount: Integer read FLineCount write FLineCount;
  end;

  TJVCSLineHistoryLineInfoCompressor = class(TObject)
  private
    FItems: TObjectList;
    function GetCount: Integer;
    function GetItems(AIndex: Integer): TJVCSLineHistoryCompressedLineInfo;
  public
    constructor Create;
    destructor Destroy; override;
    procedure CompressLineInfo(AList: TList);
    procedure DecompressLineInfo(AList: TList);
    procedure LoadFromCompressedStream(AStream: TStream);
    procedure LoadFromXMLFile(const AFileName: string);
    procedure LoadFromXMLStream(AStream: TStream);
    procedure SaveToCompressedStream(AStream: TStream);
    procedure SaveToXMLFile(const AFileName: string);
    procedure SaveToXMLStream(AStream: TStream);
    procedure ResolveRevisions(ALineHistory: TJVCSLineHistory);
    property Count: Integer read GetCount;
    property Items[AIndex: Integer]: TJVCSLineHistoryCompressedLineInfo read GetItems; default;
  end;
  {$ENDIF LINEINFOEX}

  TJVCSLineHistorySettings = class;

  TJVCSLineHistory = class(TObject)
  private
    FRevisionList: TObjectList;
    FLines: TStringList;
    {$IFDEF LINEINFOEX}
    FLineInfos: TObjectList;
    {$ENDIF LINEINFOEX}
    FNextRevisionIdx: Integer;
    FLastPreparedRevision: TJVCSLineHistoryRevision;
    FSettings: TJVCSLineHistorySettings;
    function GetCount: Integer;
    function GetItems(AIndex: Integer): TJVCSLineHistoryRevision;
    procedure SetSettings(AValue: TJVCSLineHistorySettings);
    procedure UpdateDateStr;
    procedure UpdateRevisionStr;    
    procedure UpdateUserStr;
  public
    constructor Create;
    destructor Destroy; override;

    procedure BuildInfo;
    procedure Clear;

    function AddRevision(ARevisionID: Integer; ALines: TStrings): TJVCSLineHistoryRevision;
    function AddPreparedRevision(ARevisionID: Integer; ALines: TStrings {$IFDEF LINEINFOEX} ; ALineInfo: TList {$ENDIF}): TJVCSLineHistoryRevision;

    property Settings: TJVCSLineHistorySettings read FSettings write SetSettings;
    property Lines: TStringList read FLines;
    {$IFDEF LINEINFOEX}
    property LineInfos: TObjectList read FLineInfos;
    {$ENDIF LINEINFOEX}
    property LastPreparedRevision: TJVCSLineHistoryRevision read FLastPreparedRevision;
    property RevisionCount: Integer read GetCount;
    property RevisionItems[AIndex: Integer]: TJVCSLineHistoryRevision read GetItems; default;
  end;

  TJVCSLineHistoryModuleRevisionList = class;
  TJVCSLineHistoryModuleRevision = class;

  TJVCSCustomLineHistoryModuleProvider = class(TObject)
  protected
    function GetServerInfo: string; virtual;
  public
    procedure FillRevisionList(AModuleRevisionList: TJVCSLineHistoryModuleRevisionList); virtual;
    function GetModuleCheckoutState(const AModuleName: string; var ACheckedOut: Boolean; ACRCList: TStrings): Boolean; virtual;
    function GetModuleExtensions(const AModuleName: string; AExtensions: TStrings): Boolean; virtual;
    procedure GetRevisionContent(AModuleRevision: TJVCSLineHistoryModuleRevision; AStream: TStream); virtual;
    property ServerInfo: string read GetServerInfo;
  end;

  TJVCSLineHistoryModuleRevision = class(TObject)
  private
    FList: TJVCSLineHistoryModuleRevisionList;
    FRevisionID: Integer;
    FRevisionStr: string;
    FUserStr: string;
    FTimeStamp: TDateTime;
    FCheckInComment: string;
  public
    constructor Create(AList: TJVCSLineHistoryModuleRevisionList);
    procedure GetContent(AStream: TStream);
    property List: TJVCSLineHistoryModuleRevisionList read FList;
    property RevisionID: Integer read FRevisionID write FRevisionID;
    property RevisionStr: string read FRevisionStr write FRevisionStr;
    property UserStr: string read FUserStr write FUserStr;
    property TimeStamp: TDateTime read FTimeStamp write FTimeStamp;
    property CheckInComment: string read FCheckInComment write FCheckInComment;
  end;

  TJVCSLineHistoryModuleRevisionClass = class of TJVCSLineHistoryModuleRevision;

  TJVCSLineHistoryModuleRevisionList = class(TObject)
  private
    FItems: TObjectList;
    FProvider: TJVCSCustomLineHistoryModuleProvider;
    FModuleName: string;
    FExtension: string;
    FModuleID: Integer;
    function GetCount: Integer;
    function GetItems(AIndex: Integer): TJVCSLineHistoryModuleRevision;
  public
    constructor Create(AProvider: TJVCSCustomLineHistoryModuleProvider);
    destructor Destroy; override;
    function AddRevision: TJVCSLineHistoryModuleRevision;
    function AddRevisionEx(AClass: TJVCSLineHistoryModuleRevisionClass): TJVCSLineHistoryModuleRevision;
    procedure Fill(const AModuleName, AExtension: string);
    property Count: Integer read GetCount;
    property Items[AIndex: Integer]: TJVCSLineHistoryModuleRevision read GetItems; default;
    property ModuleName: string read FModuleName;
    property ModuleID: Integer read FModuleID write FModuleID;
    property Extension: string read FExtension;
    property Provider: TJVCSCustomLineHistoryModuleProvider read FProvider;
  end;

  TJVCSLineHistoryUserSettingsItem = class(TPersistent)
  private
    FColor: TColor;
    FUserName: string;
    FVisibleName: string;
  public
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create;
    property Color: TColor read FColor write FColor;
    property UserName: string read FUserName write FUserName;
    property VisibleName: string read FVisibleName write FVisibleName;
  end;

  TJVCSLineHistoryUserSettings = class(TPersistent)
  private
    FItems: TObjectList;
    function GetCount: Integer;
    function GetItems(AIndex: Integer): TJVCSLineHistoryUserSettingsItem;
  public
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create;
    destructor Destroy; override;
    function Add: TJVCSLineHistoryUserSettingsItem;
    procedure Clear;
    procedure Delete(AIndex: Integer);
    function IndexOfUser(const AUserName: string): Integer;
    property Count: Integer read GetCount;
    property Items[AIndex: Integer]: TJVCSLineHistoryUserSettingsItem read GetItems; default;
  end;

  TJVCSLineHistorySettings = class(TObject)
  private
    FColorBarOrderList: TList;
    FDateEndColor: TColor;
    FDateFormat: string;
    FDateStartColor: TColor;
    FLineColorMode: Integer;
    FPaintMethod: Integer;
    FRevisionEndColor: TColor;
    FRevisionStartColor: TColor;
    FShowLineNumbers: Boolean;
    FShowRevisionInfoColor: Boolean;
    FShowRevisionInfoText: Boolean;
    FShowDateInfoColor: Boolean;
    FShowDateInfoText: Boolean;
    FShowUserInfoColor: Boolean;
    FShowUserInfoText: Boolean;
    {$IFDEF LINEINFOEX}
    FShowRevisionCountInfoColor: Boolean;
    FShowRevisionCountInfoText: Boolean;
    FShowFirstRevisionInfoColor: Boolean;
    FShowFirstRevisionInfoText: Boolean;
    {$ENDIF LINEINFOEX}
    FShowOrderList: TList;
    FStaticUserColorList: TStringList;
    FSuppressRevisionTextZeroDot: Boolean;
    FUserSettingsList: TJVCSLineHistoryUserSettings;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(AValue: TJVCSLineHistorySettings);
    property ColorBarOrderList: TList read FColorBarOrderList;
    property DateEndColor: TColor read FDateEndColor write FDateEndColor;
    property DateFormat: string read FDateFormat write FDateFormat;
    property DateStartColor: TColor read FDateStartColor write FDateStartColor;
    property LineColorMode: Integer read FLineColorMode write FLineColorMode;
    property PaintMethod: Integer read FPaintMethod write FPaintMethod;
    property RevisionEndColor: TColor read FRevisionEndColor write FRevisionEndColor;
    property RevisionStartColor: TColor read FRevisionStartColor write FRevisionStartColor;
    property ShowLineNumbers: Boolean read FShowLineNumbers write FShowLineNumbers;
    property ShowRevisionInfoColor: Boolean read FShowRevisionInfoColor write FShowRevisionInfoColor;
    property ShowRevisionInfoText: Boolean read FShowRevisionInfoText write FShowRevisionInfoText;
    property ShowDateInfoColor: Boolean read FShowDateInfoColor write FShowDateInfoColor;
    property ShowDateInfoText: Boolean read FShowDateInfoText write FShowDateInfoText;
    property ShowUserInfoColor: Boolean read FShowUserInfoColor write FShowUserInfoColor;
    property ShowUserInfoText: Boolean read FShowUserInfoText write FShowUserInfoText;
    {$IFDEF LINEINFOEX}
    property ShowRevisionCountInfoColor: Boolean read FShowRevisionCountInfoColor write FShowRevisionCountInfoColor;
    property ShowRevisionCountInfoText: Boolean read FShowRevisionCountInfoText write FShowRevisionCountInfoText;
    property ShowFirstRevisionInfoColor: Boolean read FShowFirstRevisionInfoColor write FShowFirstRevisionInfoColor;
    property ShowFirstRevisionInfoText: Boolean read FShowFirstRevisionInfoText write FShowFirstRevisionInfoText;
    {$ENDIF LINEINFOEX}
    property ShowOrderList: TList read FShowOrderList;
    property StaticUserColorList: TStringList read FStaticUserColorList;
    property SuppressRevisionTextZeroDot: Boolean read FSuppressRevisionTextZeroDot write FSuppressRevisionTextZeroDot; 
    property UserSettingsList: TJVCSLineHistoryUserSettings read FUserSettingsList;
  end;

  TJVCSLineHistoryRevisionKind = (lhrkFirstRevision, lhrkRevision, lhrkLatestRevision, lhrkLocalFile);

  TJVCSLineHistoryRevisionLink = class(TObject)
  private
    FKind: TJVCSLineHistoryRevisionKind;
    FRevisionID: Integer;
  public
    constructor Create(AKind: TJVCSLineHistoryRevisionKind; ARevisionID: Integer = 0);
    property Kind: TJVCSLineHistoryRevisionKind read FKind;
    property RevisionID: Integer read FRevisionID;
  end;

  TCustomPreparedRevisionInfoProvider = class(TObject)
  public
    function ApplyInfo(ALineHistory: TJVCSLineHistory; AModuleRevisionList: TJVCSLineHistoryModuleRevisionList; AIndex: Integer; ALines: TStrings): TJVCSLineHistoryRevision; virtual;
    function InfoExists(AModuleRevisionList: TJVCSLineHistoryModuleRevisionList; AFirstIndex, ALastIndex: Integer): Integer; virtual;
    procedure StoreInfo(ALineHistory: TJVCSLineHistory; AModuleRevisionList: TJVCSLineHistoryModuleRevisionList; ALastRevisionID: Integer); virtual;
  end;

  TLocalPreparedRevisionInfoProvider = class(TCustomPreparedRevisionInfoProvider)
  private
    FPrepareRevisionInfoPath: string;
    function GetPreparedInfoFileName(AModuleID, ARevisionID: Integer; AExtension: string): string;
  public
    function ApplyInfo(ALineHistory: TJVCSLineHistory; AModuleRevisionList: TJVCSLineHistoryModuleRevisionList; AIndex: Integer; ALines: TStrings): TJVCSLineHistoryRevision; override;
    function InfoExists(AModuleRevisionList: TJVCSLineHistoryModuleRevisionList; AFirstIndex, ALastIndex: Integer): Integer; override;
    procedure StoreInfo(ALineHistory: TJVCSLineHistory; AModuleRevisionList: TJVCSLineHistoryModuleRevisionList; ALastRevisionID: Integer); override;
    property PrepareRevisionInfoPath: string read FPrepareRevisionInfoPath write FPrepareRevisionInfoPath;
  end;

  TJVCSLineHistoryBuilderProgressEvent = procedure(ASender: TObject; APosition, AMax: Integer;
    var AAbort: Boolean) of object;

  TJVCSLineHistoryBuilder = class(TObject)
  private
    FFirstRevisionLink: TJVCSLineHistoryRevisionLink;
    FLastRevisionLink: TJVCSLineHistoryRevisionLink;
    FLineHistory: TJVCSLineHistory;
    FModuleExtension: string;
    FModuleName: string;
    FPreparedRevisionInfoProvider: TCustomPreparedRevisionInfoProvider;
    FProvider: TJVCSCustomLineHistoryModuleProvider;
    FOnProgress: TJVCSLineHistoryBuilderProgressEvent;
    procedure DoProgress(APosition, AMax: Integer; var AAbort: Boolean);
  public
    constructor Create;
    procedure BuildLineHistoryInfo;
    property FirstRevisionLink: TJVCSLineHistoryRevisionLink read FFirstRevisionLink write FFirstRevisionLink;
    property LastRevisionLink: TJVCSLineHistoryRevisionLink read FLastRevisionLink write FLastRevisionLink;
    property LineHistory: TJVCSLineHistory read FLineHistory write FLineHistory;
    property ModuleExtension: string read FModuleExtension write FModuleExtension;
    property ModuleName: string read FModuleName write FModuleName;
    property PreparedRevisionInfoProvider: TCustomPreparedRevisionInfoProvider read FPreparedRevisionInfoProvider write FPreparedRevisionInfoProvider;
    property Provider: TJVCSCustomLineHistoryModuleProvider read FProvider write FProvider;
    property OnProgress: TJVCSLineHistoryBuilderProgressEvent read FOnProgress write FOnProgress;
  end;

procedure RevisionInfoLoadFromStream(ALines: TStrings; AStream: TStream);
procedure RevisionInfoLoadFromFile(ALines: TStrings; AFileName: string);
procedure RevisionInfoSaveToStream(ALines: TStrings; AStream: TStream);
procedure RevisionInfoSaveToFile(ALines: TStrings; AFileName: string);
{$IFDEF LINEINFOEX}
procedure RevisionInfoExLoadFromStream(ALines: TList; AStream: TStream);
procedure RevisionInfoExLoadFromFile(ALines: TList; AFileName: string);
procedure RevisionInfoExSaveToStream(ALines: TList; AStream: TStream);
procedure RevisionInfoExSaveToFile(ALines: TList; AFileName: string);
procedure RevisionInfoExLoadFromZXMLStream(ALines: TList; AStream: TStream);
procedure RevisionInfoExLoadFromZXMLFile(ALines: TList; AFileName: string);
procedure RevisionInfoExSaveToZXMLStream(ALines: TList; AStream: TStream);
procedure RevisionInfoExSaveToZXMLFile(ALines: TList; AFileName: string);
{$ENDIF LINEINFOEX}

function EncodeFileName(AValue: string): string;

implementation

uses
  {$IFDEF LINEINFOEX}
  JclSimpleXml, AbArcTyp, AbZipTyp, AbUtils, AbUnzPrc, AbZipPrc,
  {$ENDIF LINEINFOEX}
  JVCSClientFunctions, JclFileUtils;

procedure RevisionInfoLoadFromStream(ALines: TStrings; AStream: TStream);
var
  I: Integer;
  RevisionID: Integer;
begin
  I := 0;
  while AStream.Size - AStream.Position >= SizeOf(RevisionID) do
  begin
    AStream.Read(RevisionID, SizeOf(RevisionID));
    if ALines.Count > I then
      ALines.Objects[I] := TObject(RevisionID);
    Inc(I);
  end;
end;

procedure RevisionInfoLoadFromFile(ALines: TStrings; AFileName: string);
var
  FS: TFileStream;
begin
  FS := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    RevisionInfoLoadFromStream(ALines, FS);
  finally
    FS.Free;
  end;
end;

procedure RevisionInfoSaveToStream(ALines: TStrings; AStream: TStream);
var
  I: Integer;
  RevisionID: Integer;
begin
  for I := 0 to Pred(ALines.Count) do
  begin
    RevisionID := 0;
    if Assigned(ALines.Objects[I]) and (ALines.Objects[I] is TJVCSLineHistoryRevision) then
      RevisionID := TJVCSLineHistoryRevision(ALines.Objects[I]).RevisionID;
    AStream.Write(RevisionID, SizeOf(RevisionID));
  end;
end;

procedure RevisionInfoSaveToFile(ALines: TStrings; AFileName: string);
var
  FS: TFileStream;
begin
  FS := TFileStream.Create(AFileName, fmCreate);
  try
    RevisionInfoSaveToStream(ALines, FS);
  finally
    FS.Free;
  end;
end;

{$IFDEF LINEINFOEX}
procedure RevisionInfoExLoadFromStream(ALines: TList; AStream: TStream);
var
  I: Integer;
  Count, RevisionID, LineNumber: Integer;
  LineInfo: TJVCSLineHistoryLineInfo;
begin
  while AStream.Size - AStream.Position >= SizeOf(Count) do
  begin
    AStream.Read(Count, SizeOf(Count));
    ALines.Add(TJVCSLineHistoryLineInfo.Create);
    LineInfo := ALines.Last;
    for I := 0 to Pred(Count) do
    begin
      AStream.Read(RevisionID, SizeOf(RevisionID));
      AStream.Read(LineNumber, SizeOf(LineNumber));
      LineInfo.Add(TJVCSLineHistoryRevision(RevisionID), LineNumber);
    end;
  end;
end;

procedure RevisionInfoExLoadFromFile(ALines: TList; AFileName: string);
var
  FS: TFileStream;
begin
  FS := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    RevisionInfoExLoadFromStream(ALines, FS);
  finally
    FS.Free;
  end;
end;

procedure RevisionInfoExSaveToStream(ALines: TList; AStream: TStream);
var
  I, J: Integer;
  Count, RevisionID, LineNumber: Integer;
  LineInfo: TJVCSLineHistoryLineInfo;
begin
  for I := 0 to Pred(ALines.Count) do
  begin
    if Assigned(ALines[I]) and (TObject(ALines[I]) is TJVCSLineHistoryLineInfo) then
      LineInfo := TJVCSLineHistoryLineInfo(ALines[I])
    else
      LineInfo := nil;
    if Assigned(LineInfo) then
    begin
      Count := LineInfo.Count;
      AStream.Write(Count, SizeOf(Count));
      for J := 0 to Pred(Count) do
      begin
        RevisionID := LineInfo[J].RevisionID;
        LineNumber := LineInfo.LineNumber[J];
        AStream.Write(RevisionID, SizeOf(RevisionID));
        AStream.Write(LineNumber, SizeOf(LineNumber));
      end;
    end
    else
    begin
      Count := 0;
      AStream.Write(Count, SizeOf(Count));
    end;
  end;
end;

procedure RevisionInfoExSaveToFile(ALines: TList; AFileName: string);
var
  FS: TFileStream;
begin
  FS := TFileStream.Create(AFileName, fmCreate);
  try
    RevisionInfoExSaveToStream(ALines, FS);
  finally
    FS.Free;
  end;
end;

procedure RevisionInfoExLoadFromZXMLStream(ALines: TList; AStream: TStream);
var
  LineHistoryLineInfoCompressor: TJVCSLineHistoryLineInfoCompressor;
begin
  LineHistoryLineInfoCompressor := TJVCSLineHistoryLineInfoCompressor.Create;
  try
    LineHistoryLineInfoCompressor.LoadFromCompressedStream(AStream);
    LineHistoryLineInfoCompressor.DecompressLineInfo(ALines);
  finally
    LineHistoryLineInfoCompressor.Free;
  end;
end;

procedure RevisionInfoExLoadFromZXMLFile(ALines: TList; AFileName: string);
var
  FS: TFileStream;
begin
  FS := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    RevisionInfoExLoadFromZXMLStream(ALines, FS);
  finally
    FS.Free;
  end;
end;

procedure RevisionInfoExSaveToZXMLStream(ALines: TList; AStream: TStream);
var
  LineHistoryLineInfoCompressor: TJVCSLineHistoryLineInfoCompressor;
begin
  LineHistoryLineInfoCompressor := TJVCSLineHistoryLineInfoCompressor.Create;
  try
    LineHistoryLineInfoCompressor.CompressLineInfo(ALines);
    LineHistoryLineInfoCompressor.SaveToCompressedStream(AStream);
  finally
    LineHistoryLineInfoCompressor.Free;
  end;
end;

procedure RevisionInfoExSaveToZXMLFile(ALines: TList; AFileName: string);
var
  FS: TFileStream;
begin
  FS := TFileStream.Create(AFileName, fmCreate);
  try
    RevisionInfoExSaveToZXMLStream(ALines, FS);
  finally
    FS.Free;
  end;
end;
{$ENDIF LINEINFOEX}

constructor TJVCSLineHistoryRevision.Create(ARevisionID: Integer; ALines: TStrings);
{$IFDEF LINEINFOEX}
var
  I: Integer;
{$ENDIF LINEINFOEX}
begin
  inherited Create;
  FRevisionID := ARevisionID;
  FLines := TStringList.Create;
  if Assigned(ALines) then
    FLines.Assign(ALines);
  {$IFDEF LINEINFOEX}
  FLineInfos := TObjectList.Create;
  for I := 0 to Pred(FLines.Count) do
    FLineInfos.Add(TJVCSLineHistoryLineInfo.Create);
  {$ENDIF LINEINFOEX}
  FRevisionStr := '';
  FOrgUserStr := '';
  FOrgRevisionStr := '';
  FUserStr := '';
  FDateStr := '';
  FDate := 0;
  FComment := '';
end;

destructor TJVCSLineHistoryRevision.Destroy;
begin
  {$IFDEF LINEINFOEX}
  FLineInfos.Free;
  {$ENDIF LINEINFOEX}
  FLines.Free;
  inherited Destroy;
end;

constructor TJVCSLineHistoryRevisionSummary.Create(AParent: TJVCSLineHistorySummary; ALineHistoryRevision: TJVCSLineHistoryRevision);
begin
  inherited Create;
  FLineHistoryRevision := ALineHistoryRevision;
  FLineCount := 0;
  FParent := AParent;
end;

procedure TJVCSLineHistoryRevisionSummary.IncLineCount;
begin
  Inc(FLineCount);
  if Assigned(FParent) then
  begin
    if FParent.LineCount = 0 then
      FPercent := 0
    else
      FPercent := (FLineCount / FParent.LineCount) * 100;
  end;
end;

constructor TJVCSLineHistoryUserSummary.Create(AParent: TJVCSLineHistorySummary; const AUserName: string);
begin
  inherited Create;
  FUserName := AUserName;
  FLineCount := 0;
  FPercent := 0;
  FParent := AParent;
  FVisibleUserName := AUserName;
end;

procedure TJVCSLineHistoryUserSummary.IncLineCount;
begin
  Inc(FLineCount);
  if Assigned(FParent) then
  begin
    if FParent.LineCount = 0 then
      FPercent := 0
    else
      FPercent := (FLineCount / FParent.LineCount) * 100;
  end;
end;

constructor TJVCSLineHistorySummary.Create;
begin
  inherited Create;
  FLineCount := 0;
  FRevisionItems := TObjectList.Create;
  FUserItems := TObjectList.Create;
end;

destructor TJVCSLineHistorySummary.Destroy;
begin
  FRevisionItems.Free;
  FUserItems.Free;
  inherited Destroy;
end;

procedure TJVCSLineHistorySummary.Clear;
begin
  FLineCount := 0;
  FRevisionItems.Clear;
  FUserItems.Clear;
end;

procedure TJVCSLineHistorySummary.FillFromLineHistory(ALineHistory: TJVCSLineHistory);
var
  LineRevision: TJVCSLineHistoryRevision;
  RevisionSummary: TJVCSLineHistoryRevisionSummary;
  UserSummary: TJVCSLineHistoryUserSummary;
  I: Integer;
begin
  Clear;
  if Assigned(ALineHistory) then
  begin
    FLineCount := ALineHistory.Lines.Count;
    for I := 0 to Pred(ALineHistory.Lines.Count) do
    begin
      LineRevision := TJVCSLineHistoryRevision(ALineHistory.Lines.Objects[I]);
      if Assigned(LineRevision) then
      begin
        RevisionSummary := FindRevisionSummary(LineRevision);
        RevisionSummary.IncLineCount;
        UserSummary := FindUserSummary(LineRevision.OrgUserStr, LineRevision.UserStr);
        UserSummary.IncLineCount;
      end;
    end;
  end;
end;

function TJVCSLineHistorySummary.FindRevisionSummary(ALineHistoryRevision: TJVCSLineHistoryRevision): TJVCSLineHistoryRevisionSummary;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Pred(RevisionCount) do
    if RevisionSummary[I].LineHistoryRevision = ALineHistoryRevision then
    begin
      Result := RevisionSummary[I];
      Break;
    end;
  if not Assigned(Result) then
  begin
    FRevisionItems.Add(TJVCSLineHistoryRevisionSummary.Create(Self, ALineHistoryRevision));
    Result := TJVCSLineHistoryRevisionSummary(FRevisionItems.Last);
  end;
end;

function TJVCSLineHistorySummary.FindUserSummary(const AUserName, AVisibleUserName: string): TJVCSLineHistoryUserSummary;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Pred(UserCount) do
    if UserSummary[I].UserName = AUserName then
    begin
      Result := UserSummary[I];
      Break;
    end;
  if not Assigned(Result) then
  begin
    FUserItems.Add(TJVCSLineHistoryUserSummary.Create(Self, AUserName));
    Result := TJVCSLineHistoryUserSummary(FUserItems.Last);
    Result.VisibleUserName := AVisibleUserName;
  end;
end;

function TJVCSLineHistorySummary.GetRevisionCount: Integer;
begin
  Result := FRevisionItems.Count;
end;

function TJVCSLineHistorySummary.GetRevisionSummary(AIndex: Integer): TJVCSLineHistoryRevisionSummary;
begin
  Result := TJVCSLineHistoryRevisionSummary(FRevisionItems[AIndex]);
end;

function TJVCSLineHistorySummary.GetUserCount: Integer;
begin
  Result := FUserItems.Count;
end;

function TJVCSLineHistorySummary.GetUserSummary(AIndex: Integer): TJVCSLineHistoryUserSummary;
begin
  Result := TJVCSLineHistoryUserSummary(FUserItems[AIndex]);
end;

procedure TJVCSLineHistorySummary.UpdateVisibleStrings(ALineHistory: TJVCSLineHistory);
var
  I, J: Integer;
begin
  for I := 0 to Pred(UserCount) do
    for J := 0 to Pred(ALineHistory.RevisionCount) do
      if ALineHistory[J].OrgUserStr = UserSummary[I].UserName then
      begin
        UserSummary[I].VisibleUserName := ALineHistory[J].UserStr;
        Break;
      end;
end;

{$IFDEF LINEINFOEX}
constructor TJVCSLineHistoryLineInfo.Create;
begin
  inherited Create;
  FRevisions := TList.Create;
  FLineNumbers := TList.Create;
end;

destructor TJVCSLineHistoryLineInfo.Destroy;
begin
  FRevisions.Free;
  FLineNumbers.Free;
  inherited Destroy;
end;

procedure TJVCSLineHistoryLineInfo.Add(ARevision: TJVCSLineHistoryRevision; ALineNumber: Integer);
begin
  FRevisions.Add(ARevision);
  FLineNumbers.Add(Pointer(ALineNumber));
end;

procedure TJVCSLineHistoryLineInfo.Assign(ALineInfo: TJVCSLineHistoryLineInfo);
var
  I: Integer;
begin
  FRevisions.Clear;
  FLineNumbers.Clear;
  if Assigned(ALineInfo) then
    for I := 0 to Pred(ALineInfo.Count) do
    begin
      FRevisions.Add(Pointer(ALineInfo[I]));
      FLineNumbers.Add(Pointer(ALineInfo.LineNumber[I]));
    end;
end;

function TJVCSLineHistoryLineInfo.GetCount: Integer;
begin
  Result := FRevisions.Count;
end;

function TJVCSLineHistoryLineInfo.GetRevision(AIndex: Integer): TJVCSLineHistoryRevision;
begin
  Result := FRevisions[AIndex];
end;

function TJVCSLineHistoryLineInfo.GetLineNumber(AIndex: Integer): Integer;
begin
  Result := Integer(FLineNumbers[AIndex]);
end;
{$ENDIF LINEINFOEX}

{$IFDEF LINEINFOEX}
constructor TJVCSLineHistoryCompressedLineInfo.Create;
begin
  inherited Create;
  FInfo := TJVCSLineHistoryLineInfo.Create;
  FLineCount := 0;
end;

destructor TJVCSLineHistoryCompressedLineInfo.Destroy;
begin
  FInfo.Free;
  inherited Destroy;
end;

constructor TJVCSLineHistoryLineInfoCompressor.Create;
begin
  inherited Create;
  FItems := TObjectList.Create;
end;

destructor TJVCSLineHistoryLineInfoCompressor.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TJVCSLineHistoryLineInfoCompressor.CompressLineInfo(AList: TList);

  function IsSameInfo(AInfo1, AInfo2: TJVCSLineHistoryLineInfo): Boolean;
  var
    I, Cnt: Integer;
  begin
    Result := False;
    if Assigned(AInfo1) and Assigned(AInfo2) and (AInfo1.Count = AInfo2.Count) then
    begin
      Cnt := 0;
      for I := 0 to Pred(AInfo1.Count) do
        if AInfo1[I] = AInfo2[I] then
          Inc(Cnt)
        else
          Break;
      Result := Cnt = AInfo1.Count;
    end;
  end;

var
  I: Integer;
  LastLineInfo: TJVCSLineHistoryLineInfo;
  NewLineInfo: TJVCSLineHistoryCompressedLineInfo;
begin
  FItems.Clear;
  LastLineInfo := nil;
  NewLineInfo := nil;
  for I := 0 to Pred(AList.Count) do
  begin
    if (LastLineInfo = nil) or not IsSameInfo(LastLineInfo, AList[I]) then
    begin
      LastLineInfo := AList[I];
      FItems.Add(TJVCSLineHistoryCompressedLineInfo.Create);
      NewLineInfo := TJVCSLineHistoryCompressedLineInfo(FItems.Last);
      NewLineInfo.Info.Assign(AList[I]);
      NewLineInfo.LineCount := 1;
    end
    else
    if Assigned(NewLineInfo) then
      NewLineInfo.LineCount := NewLineInfo.LineCount + 1;
  end;
end;

procedure TJVCSLineHistoryLineInfoCompressor.DecompressLineInfo(AList: TList);
var
  I, J, K: Integer;
  LineInfo: TJVCSLineHistoryLineInfo;
begin
  AList.Clear;
  for I := 0 to Pred(Count) do
  begin
    for J := 0 to Pred(Items[I].LineCount) do
    begin
      AList.Add(TJVCSLineHistoryLineInfo.Create);
      LineInfo := TJVCSLineHistoryLineInfo(AList.Last);
      for K := 0 to Pred(Items[I].Info.Count) do
        LineInfo.Add(Items[I].Info.Revision[K], Items[I].Info.LineNumber[K] + J);
    end;
  end;
end;

function DecompressLineHistory(AArchiveStream, AContentStream: TStream): Boolean;
var
  AbZipArchive: TAbZipArchive;
  AbZipItem: TAbZipItem;
begin
  Result := False;
  // IF is a ZipFile
  if VerifyZip(AArchiveStream) = atZip then
  begin
    AbZipArchive := TAbZipArchive.CreateFromStream(AArchiveStream, 'AbArchive');
    try
      AbZipArchive.Load;
      if AbZipArchive.ItemList.Count > 0 then
      begin
        AbZipItem := AbZipArchive.Items[0];
        AbUnzipToStream(AbZipArchive, AbZipItem, AContentStream);
        Result := True;
      end;
    finally
      AbZipArchive.Free;
    end;
  end;
end;

procedure TJVCSLineHistoryLineInfoCompressor.LoadFromCompressedStream(AStream: TStream);
var
  XMLStream: TMemoryStream;
begin
  XMLStream := TMemoryStream.Create;
  try
    DecompressLineHistory(AStream, XMLStream);
    XMLStream.Position := 0;
    LoadFromXMLStream(XMLStream);
  finally
    XMLStream.Free;
  end;
end;

procedure TJVCSLineHistoryLineInfoCompressor.LoadFromXMLFile(const AFileName: string);
var
  FS: TFileStream;
begin
  FS := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromXMLStream(FS);
  finally
    FS.Free;
  end;
end;

procedure TJVCSLineHistoryLineInfoCompressor.LoadFromXMLStream(AStream: TStream);
var
  XML: TJclSimpleXml;
  Elem, Elem2: TJclSimpleXMLElem;
  I, J: Integer;
  NewLineInfo: TJVCSLineHistoryCompressedLineInfo;
begin
  XML := TJclSimpleXML.Create;
  try
    XML.LoadFromStream(AStream);
    if XML.Root.Name = 'RevisionInfo' then
    begin
      FItems.Clear;
      for I := 0 to Pred(XML.Root.Items.Count) do
      begin
        Elem := XML.Root.Items[I];
        NewLineInfo := nil;
        if (Elem.Name = 'Line') and Assigned(Elem.Properties.ItemNamed['Nr']) then
        begin
          FItems.Add(TJVCSLineHistoryCompressedLineInfo.Create);
          NewLineInfo := TJVCSLineHistoryCompressedLineInfo(FItems.Last);
          NewLineInfo.LineCount := 1;
        end
        else
        if (Elem.Name = 'Block') and Assigned(Elem.Properties.ItemNamed['Nr']) and Assigned(Elem.Properties.ItemNamed['Count']) then
        begin
          FItems.Add(TJVCSLineHistoryCompressedLineInfo.Create);
          NewLineInfo := TJVCSLineHistoryCompressedLineInfo(FItems.Last);
          NewLineInfo.LineCount := Elem.Properties.ItemNamed['Count'].IntValue;
        end;
        if Assigned(NewLineInfo) then
          for J := 0 to Pred(Elem.Items.Count) do
          begin
            Elem2 := Elem.Items[J];
            if Assigned(Elem2.Properties.ItemNamed['Nr']) then
              NewLineInfo.Info.Add(TJVCSLineHistoryRevision(Elem2.IntValue), Elem2.Properties.ItemNamed['Nr'].IntValue);
          end;
        end;
    end;
  finally
    XML.Free;
  end;
end;

type
  TZipHelper = class(TObject)
  public
    procedure ZipFromStreamProc(Sender : TObject; Item : TAbArchiveItem;
      OutStream, InStream : TStream);
  end;

procedure TZipHelper.ZipFromStreamProc(Sender : TObject; Item : TAbArchiveItem;
  OutStream, InStream : TStream);
begin
  AbZipFromStream(TAbZipArchive(Sender), TAbZipItem(Item), OutStream, InStream);
end;

function CompressLineHistory(AContentStream, AArchiveStream: TStream): Boolean;
var
  AbZipArchive: TAbZipArchive;
  ZipHelper: TZipHelper;
  TemporaryArchiveStream: TMemoryStream;
  ArchiveStream: TStream;
begin
  Result := True;
  ZipHelper := TZipHelper.Create;
  ArchiveStream := AArchiveStream;
  if not (ArchiveStream is TMemoryStream) then
  begin
    TemporaryArchiveStream := TMemoryStream.Create;
    ArchiveStream := TemporaryArchiveStream;
  end
  else
    TemporaryArchiveStream := nil;
  AbZipArchive := TAbZipArchive.CreateFromStream(ArchiveStream, 'ArchiveName');
  try
    AbZipArchive.CompressionMethodToUse := smBestMethod;
    AbZipArchive.DeflationOption := doMaximum;
    AbZipArchive.InsertFromStreamHelper := ZipHelper.ZipFromStreamProc;
    AContentStream.Position := 0;
    AbZipArchive.AddFromStream('LineHistory', AContentStream);
    AbZipArchive.Save;
    if Assigned(TemporaryArchiveStream) then
      AArchiveStream.CopyFrom(TemporaryArchiveStream, 0);
  finally
    AbZipArchive.Free;
    ZipHelper.Free;
    TemporaryArchiveStream.Free;
  end;
end;

procedure TJVCSLineHistoryLineInfoCompressor.SaveToCompressedStream(AStream: TStream);
var
  XMLStream: TMemoryStream;
begin
  XMLStream := TMemoryStream.Create;
  try
    SaveToXMLStream(XMLStream);
    CompressLineHistory(XMLStream, AStream);
  finally
    XMLStream.Free;
  end;
end;

procedure TJVCSLineHistoryLineInfoCompressor.SaveToXMLFile(const AFileName: string);
var
  FS: TFileStream;
begin
  FS := TFileStream.Create(AFileName, fmCreate);
  try
    SaveToXMLStream(FS);
  finally
    FS.Free;
  end;
end;

procedure TJVCSLineHistoryLineInfoCompressor.SaveToXMLStream(AStream: TStream);
var
  XML: TJclSimpleXml;
  Elem, Elem2: TJclSimpleXMLElem;
  CurrentNr, I, J: Integer;
  LInfo: TJVCSLineHistoryLineInfo;
begin
  XML := TJclSimpleXML.Create;
  try
    XML.Root.Name := 'RevisionInfo';
    CurrentNr := 1;
    for I := 0 to Pred(Count) do
    begin
      LInfo := Items[I].Info;
      if Items[I].LineCount = 1 then
      begin
        Elem := XML.Root.Items.Add('Line');
        Elem.Properties.Add('Nr', CurrentNr);
        for J := 0 to Pred(LInfo.Count) do
        begin
          Elem2 := Elem.Items.Add('Revision', LInfo[J].RevisionID);
          Elem2.Properties.Add('Nr', LInfo.LineNumber[J]);
        end;
      end
      else
      begin
        Elem := XML.Root.Items.Add('Block');
        Elem.Properties.Add('Nr', CurrentNr);
        Elem.Properties.Add('Count', Items[I].LineCount);
        for J := 0 to Pred(LInfo.Count) do
        begin
          Elem2 := Elem.Items.Add('Revision', LInfo[J].RevisionID);
          Elem2.Properties.Add('Nr', LInfo.LineNumber[J]);
        end;
      end;
      Inc(CurrentNr, Items[I].LineCount);
    end;
    XML.SaveToStream(AStream);
  finally
    XML.Free;
  end;
end;

procedure TJVCSLineHistoryLineInfoCompressor.ResolveRevisions(ALineHistory: TJVCSLineHistory);
var
  ResolveList: TStringList;
  I, J, Idx: Integer;
begin
  ResolveList := TStringList.Create;
  try
    for I := 0 to Pred(ALineHistory.RevisionCount) do
      ResolveList.AddObject(IntToStr(ALineHistory[I].RevisionID), ALineHistory[I]);
    ResolveList.Sorted := True;
    for I := 0 to Pred(Count) do
      for J := 0 to Pred(Items[I].Info.Count) do
      begin
        Idx := ResolveList.IndexOf(IntToStr(Integer(Items[I].Info.Revision[J])));
        if Idx <> -1 then
          Items[I].Info.FRevisions[J] := ResolveList.Objects[Idx]
        else
          Items[I].Info.FRevisions[J] := nil;
      end;
  finally
    ResolveList.Free;
  end;
end;

function TJVCSLineHistoryLineInfoCompressor.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TJVCSLineHistoryLineInfoCompressor.GetItems(AIndex: Integer): TJVCSLineHistoryCompressedLineInfo;
begin
  Result := TJVCSLineHistoryCompressedLineInfo(FItems[AIndex]);
end;
{$ENDIF LINEINFOEX}

constructor TJVCSLineHistory.Create;
begin
  inherited Create;
  FRevisionList := TObjectList.Create;
  FLines := TStringList.Create;
  {$IFDEF LINEINFOEX}
  FLineInfos := TObjectList.Create;
  {$ENDIF LINEINFOEX}
  FSettings := nil;
  Clear;
end;

destructor TJVCSLineHistory.Destroy;
begin
  {$IFDEF LINEINFOEX}
  FLineInfos.Free;
  {$ENDIF LINEINFOEX}
  FLines.Free;
  FRevisionList.Free;
  inherited Destroy;
end;

function TJVCSLineHistory.AddRevision(ARevisionID: Integer; ALines: TStrings): TJVCSLineHistoryRevision;
begin
  FRevisionList.Add(TJVCSLineHistoryRevision.Create(ARevisionID, ALines));
  Result := TJVCSLineHistoryRevision(FRevisionList.Last);
end;

function TJVCSLineHistory.AddPreparedRevision(ARevisionID: Integer; ALines: TStrings {$IFDEF LINEINFOEX} ; ALineInfo: TList {$ENDIF}): TJVCSLineHistoryRevision;
var
  ResolveList: TStringList;
  I, Idx: Integer;
  LineHistoryRevision: TJVCSLineHistoryRevision;
  {$IFDEF LINEINFOEX}
  J: Integer;
  LineInfo, SaveLineInfo: TJVCSLineHistoryLineInfo;
  {$ENDIF LINEINFOEX}
begin
  FRevisionList.Add(TJVCSLineHistoryRevision.Create(ARevisionID, ALines));
  Result := TJVCSLineHistoryRevision(FRevisionList.Last);
  ResolveList := TStringList.Create;
  try
    for I := 0 to Pred(FRevisionList.Count) do
      ResolveList.AddObject(IntToStr(TJVCSLineHistoryRevision(FRevisionList[I]).RevisionID), FRevisionList[I]);
    ResolveList.Sorted := True;
    LineHistoryRevision := TJVCSLineHistoryRevision(FRevisionList[Pred(FRevisionList.Count)]);
    for I := 0 to Pred(LineHistoryRevision.Lines.Count) do
    begin
      Idx := ResolveList.IndexOf(IntToStr(Integer(LineHistoryRevision.Lines.Objects[I])));
      if Idx <> -1 then
        LineHistoryRevision.Lines.Objects[I] := ResolveList.Objects[Idx]
      else
        LineHistoryRevision.Lines.Objects[I] := nil;
    end;
    {$IFDEF LINEINFOEX}
    LineHistoryRevision.LineInfos.Clear;
    for I := 0 to Pred(LineHistoryRevision.Lines.Count) do
    begin
      LineHistoryRevision.LineInfos.Add(TJVCSLineHistoryLineInfo.Create);
      LineInfo := TJVCSLineHistoryLineInfo(LineHistoryRevision.LineInfos.Last);
      if (ALineInfo.Count > I) and Assigned(ALineInfo[I]) and (TObject(ALineInfo[I]) is TJVCSLineHistoryLineInfo) then
      begin
        SaveLineInfo := TJVCSLineHistoryLineInfo(ALineInfo[I]);
        for J := 0 to Pred(SaveLineInfo.Count) do
        begin
          Idx := ResolveList.IndexOf(IntToStr(Integer(SaveLineInfo[J])));
          if Idx <> -1 then
            LineInfo.Add(TJVCSLineHistoryRevision(ResolveList.Objects[Idx]), SaveLineInfo.LineNumber[J])
          else
            LineInfo.Add(nil, SaveLineInfo.LineNumber[J]);          
        end;
      end;
    end;
    {$ENDIF LINEINFOEX}
  finally
    ResolveList.Free;
  end;
end;

procedure TJVCSLineHistory.BuildInfo;
var
  Lines1, Lines2: TStringList;
  HashList1, HashList2: TList;
  I, J, K: Integer;
  NewRevision: TObject;
  Diff: TDiff;
  {$IFDEF LINEINFOEX}
  LineInfo: TJVCSLineHistoryLineInfo;
  LineInfos1, LineInfos2: TObjectList;
  {$ENDIF LINEINFOEX}
begin
  while FNextRevisionIdx < FRevisionList.Count do
  begin
    if FNextRevisionIdx = 0 then
    begin
      Lines1 := TJVCSLineHistoryRevision(FRevisionList[0]).Lines;
      for I := 0 to Pred(Lines1.Count) do
        Lines1.Objects[I] := FRevisionList[0];
      FLines.Assign(Lines1);

      {$IFDEF LINEINFOEX}
      LineInfos1 := TJVCSLineHistoryRevision(FRevisionList[0]).LineInfos;
      LineInfos1.Clear;
      for I := 0 to Pred(Lines1.Count) do
      begin
        LineInfos1.Add(TJVCSLineHistoryLineInfo.Create);
        LineInfo := TJVCSLineHistoryLineInfo(LineInfos1.Last);
        LineInfo.Add(TJVCSLineHistoryRevision(FRevisionList[0]), I + 1);
      end;
      FLineInfos.Clear;
      for I := 0 to Pred(LineInfos1.Count) do
      begin
        FLineInfos.Add(TJVCSLineHistoryLineInfo.Create);
        LineInfo := TJVCSLineHistoryLineInfo(FLineInfos.Last);
        LineInfo.Assign(TJVCSLineHistoryLineInfo(LineInfos1[I]));
      end;
      {$ENDIF LINEINFOEX}
    end
    else
    begin
      Lines1 := FLines;
      Lines2 := TJVCSLineHistoryRevision(FRevisionList[FNextRevisionIdx]).Lines;
      NewRevision := FRevisionList[FNextRevisionIdx];
      HashList1 := TList.Create;
      HashList2 := TList.Create;
      {$IFDEF LINEINFOEX}
      LineInfos1 := FLineInfos;
      LineInfos2 := TJVCSLineHistoryRevision(FRevisionList[FNextRevisionIdx]).LineInfos;
      {$ENDIF LINEINFOEX}
      Diff := TDiff.Create(nil);
      try
        for I := 0 to Lines1.Count - 1 do
          HashList1.Add(HashLine(Lines1[I], True, True));
        for I := 0 to Lines2.Count - 1 do
          HashList2.Add(HashLine(Lines2[I], True, True));
        Diff.Execute(PIntArray(HashList1.List), PIntArray(HashList2.List),
          HashList1.Count, HashList2.Count);
        J := 0;
        K := 0;
        with Diff do
          for I := 0 to ChangeCount-1 do
            with Changes[I] do
            begin
              while J < x do
              begin
                Lines2.Objects[K] := Lines1.Objects[J];
                {$IFDEF LINEINFOEX}
                TJVCSLineHistoryLineInfo(LineInfos2[K]).Assign(TJVCSLineHistoryLineInfo(LineInfos1[J]));
                {$ENDIF LINEINFOEX}
                Inc(J);
                Inc(K);
              end;
              if Kind = ckAdd then
              begin
                for J := K to K + Range - 1 do
                begin
                  Lines2.Objects[J] := NewRevision;
                  {$IFDEF LINEINFOEX}
                  TJVCSLineHistoryLineInfo(LineInfos2[J]).Add(TJVCSLineHistoryRevision(NewRevision), J + 1);
                  {$ENDIF LINEINFOEX}
                end;
                J := x;
                K := y + Range;
              end
              else
              if Kind = ckModify then
              begin
                for J := 0 to Range - 1 do
                begin
                  Lines2.Objects[K + J] := NewRevision;
                  {$IFDEF LINEINFOEX}
                  TJVCSLineHistoryLineInfo(LineInfos2[K + J]).Assign(TJVCSLineHistoryLineInfo(LineInfos1[x + J]));
                  TJVCSLineHistoryLineInfo(LineInfos2[K + J]).Add(TJVCSLineHistoryRevision(NewRevision), K + J + 1);
                  {$ENDIF LINEINFOEX}
                end;
                J := x + Range;
                K := y + Range;
              end
              else //Kind = ckDel
                J := x + Range;
            end;
        while J < Lines1.Count do
        begin
          Lines2.Objects[K] := Lines1.Objects[J];
          {$IFDEF LINEINFOEX}
          TJVCSLineHistoryLineInfo(LineInfos2[K]).Assign(TJVCSLineHistoryLineInfo(LineInfos1[J]));
          {$ENDIF LINEINFOEX}
          Inc(J);
          Inc(K);
        end;
      finally
        Diff.Free;
        HashList2.Free;
        HashList1.Free;
      end;
      Lines1.Assign(Lines2);
      {$IFDEF LINEINFOEX}
      LineInfos1.Clear;
      for I := 0 to Pred(LineInfos2.Count) do
      begin
        LineInfos1.Add(TJVCSLineHistoryLineInfo.Create);
        LineInfo := TJVCSLineHistoryLineInfo(LineInfos1.Last);
        LineInfo.Assign(TJVCSLineHistoryLineInfo(LineInfos2[I]));
      end;
      {$ENDIF LINEINFOEX}
    end;
    FLastPreparedRevision := TJVCSLineHistoryRevision(FRevisionList[FNextRevisionIdx]);
    TJVCSLineHistoryRevision(FRevisionList[FNextRevisionIdx]).Lines.Clear;
    {$IFDEF LINEINFOEX}
    TJVCSLineHistoryRevision(FRevisionList[FNextRevisionIdx]).LineInfos.Clear;
    {$ENDIF LINEINFOEX}
    Inc(FNextRevisionIdx);
  end;
  UpdateDateStr;
  UpdateRevisionStr;  
  UpdateUserStr;
end;

procedure TJVCSLineHistory.Clear;
begin
  FLines.Clear;
  FRevisionList.Clear;
  FNextRevisionIdx := 0;
  FLastPreparedRevision := nil;
end;

function TJVCSLineHistory.GetCount: Integer;
begin
  Result := FRevisionList.Count;
end;

function TJVCSLineHistory.GetItems(AIndex: Integer): TJVCSLineHistoryRevision;
begin
  Result := TJVCSLineHistoryRevision(FRevisionList[AIndex]);
end;

procedure TJVCSLineHistory.SetSettings(AValue: TJVCSLineHistorySettings);
begin
  FSettings := AValue;
  UpdateDateStr;
  UpdateRevisionStr;
  UpdateUserStr;
end;

procedure TJVCSLineHistory.UpdateDateStr;
var
  I: Integer;
  DateFormat: string;
begin
  if Assigned(FSettings) then
    DateFormat := FSettings.DateFormat
  else
    DateFormat := 'yyyy"/"mm"/"dd';
  for I := 0 to Pred(RevisionCount) do
  begin
    if DateFormat = AgeDateFormat then
      RevisionItems[I].DateStr := GetAgeStr(RevisionItems[I].Date)
    else
    if DateFormat = Age2DateFormat then
      RevisionItems[I].DateStr := GetAge2Str(RevisionItems[I].Date)
    else
      RevisionItems[I].DateStr := FormatDateTime(DateFormat, RevisionItems[I].Date);
  end;
end;

procedure TJVCSLineHistory.UpdateRevisionStr;
var
  I: Integer;
  SuppressZeroDot: Boolean;
  S: string;
begin
  if Assigned(FSettings) then
    SuppressZeroDot := FSettings.SuppressRevisionTextZeroDot
  else
    SuppressZeroDot := False;
  if SuppressZeroDot then
    for I := 0 to Pred(RevisionCount) do
    begin
      S := RevisionItems[I].OrgRevisionStr;
      if (Pos('.', S) > 0) and (Pos('0.', S) <> 1) then
      begin
        SuppressZeroDot := False;
        Break;
      end;
    end;
  for I := 0 to Pred(RevisionCount) do
  begin
    if SuppressZeroDot then
    begin
      S := RevisionItems[I].OrgRevisionStr;
      if Pos('0.', S) = 1 then
        Delete(S, 1, 2);
      RevisionItems[I].RevisionStr := S;
    end
    else
      RevisionItems[I].RevisionStr := RevisionItems[I].OrgRevisionStr;
  end;
end;

procedure TJVCSLineHistory.UpdateUserStr;
var
  I, Idx: Integer;
  S: string;
begin
  if Assigned(FSettings) then
  begin
    for I := 0 to Pred(RevisionCount) do
    begin
      S := RevisionItems[I].OrgUserStr;
      Idx := FSettings.UserSettingsList.IndexOfUser(S);
      if (Idx <> -1) and (FSettings.UserSettingsList[Idx].VisibleName <> '') then
        RevisionItems[I].UserStr := FSettings.UserSettingsList[Idx].VisibleName
      else
        RevisionItems[I].UserStr := S;
    end;
  end
  else
  for I := 0 to Pred(RevisionCount) do
    RevisionItems[I].UserStr := RevisionItems[I].OrgUserStr;
end;

procedure TJVCSCustomLineHistoryModuleProvider.FillRevisionList(AModuleRevisionList: TJVCSLineHistoryModuleRevisionList);
begin
//
end;

function TJVCSCustomLineHistoryModuleProvider.GetModuleCheckoutState(const AModuleName: string;
  var ACheckedOut: Boolean; ACRCList: TStrings): Boolean;
begin
  Result := False;
end;

function TJVCSCustomLineHistoryModuleProvider.GetModuleExtensions(const AModuleName: string; AExtensions: TStrings): Boolean;
begin
  Result := False;
end;

procedure TJVCSCustomLineHistoryModuleProvider.GetRevisionContent(AModuleRevision: TJVCSLineHistoryModuleRevision; AStream: TStream);
begin
//
end;

function TJVCSCustomLineHistoryModuleProvider.GetServerInfo: string;
begin
  Result := '';
end;

constructor TJVCSLineHistoryModuleRevision.Create(AList: TJVCSLineHistoryModuleRevisionList);
begin
  inherited Create;
  FList := AList;
  FRevisionID := -1;
  FRevisionStr := '';
  FUserStr := '';
  FCheckInComment := '';
end;

procedure TJVCSLineHistoryModuleRevision.GetContent(AStream: TStream);
begin
  if Assigned(FList) and Assigned(FList.Provider) then
    FList.Provider.GetRevisionContent(Self, AStream);
end;

constructor TJVCSLineHistoryModuleRevisionList.Create(AProvider: TJVCSCustomLineHistoryModuleProvider);
begin
  inherited Create;
  FProvider := AProvider;
  FItems := TObjectList.Create;
  FModuleName := '';
  FExtension := '';
  FModuleID := 0;
end;

destructor TJVCSLineHistoryModuleRevisionList.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

function TJVCSLineHistoryModuleRevisionList.AddRevision: TJVCSLineHistoryModuleRevision;
begin
  FItems.Add(TJVCSLineHistoryModuleRevision.Create(Self));
  Result := TJVCSLineHistoryModuleRevision(FItems.Last);
end;

function TJVCSLineHistoryModuleRevisionList.AddRevisionEx(AClass: TJVCSLineHistoryModuleRevisionClass): TJVCSLineHistoryModuleRevision;
begin
  FItems.Add(AClass.Create(Self));
  Result := TJVCSLineHistoryModuleRevision(FItems.Last);  
end;

{$IFDEF SAMPLEIMAGE}
function GetFixedUserName(const AStr: string): string;
begin
  if AStr = 'Uwe Schuster' then
    Result := 'Max Muster'
  else
  if AStr = 'Thomas Huber' then
    Result := 'John Doe'
  else
  if AStr = 'florixhu (Deleted)' then
    Result := 'JDoe (Deleted)'
  else
  if AStr = 'Fikret Hasovic' then
    Result := 'Rainer Zufall'
  else
  if AStr = 'Carsten Schuette' then
    Result := 'Ernst Eiswuerfel'
  else
    Result := AStr;
end;
{$ENDIF SAMPLEIMAGE}

procedure TJVCSLineHistoryModuleRevisionList.Fill(const AModuleName, AExtension: string);
{$IFDEF SAMPLEIMAGE}
var
  I, P: Integer;
  S1, S2: string;
{$ENDIF SAMPLEIMAGE}  
begin
  FItems.Clear;
  FModuleName := AModuleName;
  FExtension := AExtension;
  FModuleID := 0;
  if Assigned(FProvider) then
    FProvider.FillRevisionList(Self);
  {$IFDEF SAMPLEIMAGE}
  for I := 0 to Pred(Count) do
    Items[I].UserStr := GetFixedUserName(Items[I].UserStr);
  for I := Pred(Count) downto 0 do
  begin
    S2 := Items[I].RevisionStr;
    P := Pos('.', S2);
    if P > 0 then
    begin
      S1 := Copy(S2, 1, P - 1);
      Delete(S2, 1, P);
      if (StrToIntDef(S1, 0) > 0) or (StrToIntDef(S2, 0) > 89) then
        FItems.Delete(I);
    end;
  end;
  {$ENDIF SAMPLEIMAGE}
end;

function TJVCSLineHistoryModuleRevisionList.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TJVCSLineHistoryModuleRevisionList.GetItems(AIndex: Integer): TJVCSLineHistoryModuleRevision;
begin
  Result := TJVCSLineHistoryModuleRevision(FItems[AIndex]);
end;

constructor TJVCSLineHistoryUserSettingsItem.Create;
begin
  inherited Create;
  FColor := clNone;
  FUserName := '';
  FVisibleName := '';
end;

procedure TJVCSLineHistoryUserSettingsItem.AssignTo(Dest: TPersistent);
begin
  if Dest is TJVCSLineHistoryUserSettingsItem then
  begin
    TJVCSLineHistoryUserSettingsItem(Dest).Color := FColor;
    TJVCSLineHistoryUserSettingsItem(Dest).UserName := FUserName;
    TJVCSLineHistoryUserSettingsItem(Dest).VisibleName := FVisibleName;
  end
  else
    inherited AssignTo(Dest);
end;

constructor TJVCSLineHistoryUserSettings.Create;
begin
  inherited Create;
  FItems := TObjectList.Create;
end;

destructor TJVCSLineHistoryUserSettings.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

function TJVCSLineHistoryUserSettings.Add: TJVCSLineHistoryUserSettingsItem;
begin
  FItems.Add(TJVCSLineHistoryUserSettingsItem.Create);
  Result := TJVCSLineHistoryUserSettingsItem(FItems.Last);
end;

procedure TJVCSLineHistoryUserSettings.AssignTo(Dest: TPersistent);
var
  I: Integer;
begin
  if Dest is TJVCSLineHistoryUserSettings then
  begin
    TJVCSLineHistoryUserSettings(Dest).Clear;
    for I := 0 to Pred(Count) do
      TJVCSLineHistoryUserSettings(Dest).Add.Assign(Items[I]);
  end
  else
    inherited AssignTo(Dest);
end;

procedure TJVCSLineHistoryUserSettings.Clear;
begin
  FItems.Clear;
end;

procedure TJVCSLineHistoryUserSettings.Delete(AIndex: Integer);
begin
  FItems.Delete(AIndex);
end;

function TJVCSLineHistoryUserSettings.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TJVCSLineHistoryUserSettings.GetItems(AIndex: Integer): TJVCSLineHistoryUserSettingsItem;
begin
  Result := TJVCSLineHistoryUserSettingsItem(FItems[AIndex]);
end;

function TJVCSLineHistoryUserSettings.IndexOfUser(const AUserName: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Pred(Count) do
    if Items[I].UserName = AUserName then
    begin
      Result := I;
      Break;
    end;
end;

constructor TJVCSLineHistorySettings.Create;
begin
  inherited Create;
  FColorBarOrderList := TList.Create;
  FColorBarOrderList.Add(Pointer(1));
  FColorBarOrderList.Add(Pointer(2));
  FColorBarOrderList.Add(Pointer(3));
  FDateEndColor := clWhite;
  FDateFormat := 'yyyy"/"mm"/"dd';
  FDateStartColor := clRed;
  FLineColorMode := 0;
  FPaintMethod := 0;
  FRevisionEndColor := clWhite;
  FRevisionStartColor := clYellow;
  FShowLineNumbers := True;
  FShowRevisionInfoColor := True;
  FShowRevisionInfoText := True;
  FShowDateInfoColor := True;
  FShowDateInfoText := True;
  FShowUserInfoColor := True;
  FShowUserInfoText := True;
  {$IFDEF LINEINFOEX}
  FShowRevisionCountInfoColor := True;
  FShowRevisionCountInfoText := True;
  FShowFirstRevisionInfoColor := True;
  FShowFirstRevisionInfoText := True;
  {$ENDIF LINEINFOEX}
  FShowOrderList := TList.Create;
  FStaticUserColorList := TStringList.Create;
  FSuppressRevisionTextZeroDot := False;
  FUserSettingsList := TJVCSLineHistoryUserSettings.Create;
end;

destructor TJVCSLineHistorySettings.Destroy;
begin
  FColorBarOrderList.Free;
  FShowOrderList.Free;
  FStaticUserColorList.Free;
  FUserSettingsList.Free;
  inherited Destroy;
end;

{$IFNDEF DELPHI6_UP}
procedure AssignTList(ADest, ASource: TList);
var
  I: Integer;
begin
  ADest.Clear;
  for I := 0 to Pred(ASource.Count) do
    ADest.Add(ASource[I]);
end;
{$ENDIF ~DELPHI6_UP}

procedure TJVCSLineHistorySettings.Assign(AValue: TJVCSLineHistorySettings);
begin
  {$IFDEF DELPHI6_UP}
  FColorBarOrderList.Assign(AValue.ColorBarOrderList);
  {$ELSE}
  AssignTList(FColorBarOrderList, AValue.ColorBarOrderList);
  {$ENDIF DELPHI6_UP}
  FDateEndColor := AValue.DateEndColor;
  FDateFormat := AValue.DateFormat;
  FDateStartColor := AValue.DateStartColor;
  FLineColorMode := AValue.LineColorMode;
  FPaintMethod := AValue.PaintMethod;
  FRevisionEndColor := AValue.RevisionEndColor;
  FRevisionStartColor := AValue.RevisionStartColor;
  FShowLineNumbers := AValue.FShowLineNumbers;
  FShowRevisionInfoColor := AValue.ShowRevisionInfoColor;
  FShowRevisionInfoText := AValue.ShowRevisionInfoText;
  FShowDateInfoColor := AValue.ShowDateInfoColor;
  FShowDateInfoText := AValue.ShowDateInfoText;
  FShowUserInfoColor := AValue.ShowUserInfoColor;
  FShowUserInfoText := AValue.ShowUserInfoText;
  {$IFDEF LINEINFOEX}
  FShowRevisionCountInfoColor := AValue.ShowRevisionCountInfoColor;
  FShowRevisionCountInfoText := AValue.ShowRevisionCountInfoText;
  FShowFirstRevisionInfoColor := AValue.ShowFirstRevisionInfoColor;
  FShowFirstRevisionInfoText := AValue.ShowFirstRevisionInfoText;
  {$ENDIF LINEINFOEX}
  {$IFDEF DELPHI6_UP}
  FShowOrderList.Assign(AValue.ShowOrderList);
  {$ELSE}
  AssignTList(FShowOrderList, AValue.ShowOrderList);
  {$ENDIF DELPHI6_UP}
  FStaticUserColorList.Assign(AValue.StaticUserColorList);
  FSuppressRevisionTextZeroDot := AValue.SuppressRevisionTextZeroDot;
  FUserSettingsList.Assign(AValue.UserSettingsList);
end;

constructor TJVCSLineHistoryRevisionLink.Create(AKind: TJVCSLineHistoryRevisionKind; ARevisionID: Integer = 0);
begin
  inherited Create;
  FKind := AKind;
  FRevisionID := ARevisionID;
end;

function TCustomPreparedRevisionInfoProvider.ApplyInfo(ALineHistory: TJVCSLineHistory; AModuleRevisionList: TJVCSLineHistoryModuleRevisionList; AIndex: Integer; ALines: TStrings): TJVCSLineHistoryRevision;
begin
  Result := nil;
end;

function TCustomPreparedRevisionInfoProvider.InfoExists(AModuleRevisionList: TJVCSLineHistoryModuleRevisionList; AFirstIndex, ALastIndex: Integer): Integer;
begin
  Result := -1;
end;

procedure TCustomPreparedRevisionInfoProvider.StoreInfo(ALineHistory: TJVCSLineHistory; AModuleRevisionList: TJVCSLineHistoryModuleRevisionList; ALastRevisionID: Integer);
begin
end;

function TLocalPreparedRevisionInfoProvider.ApplyInfo(ALineHistory: TJVCSLineHistory; AModuleRevisionList: TJVCSLineHistoryModuleRevisionList; AIndex: Integer; ALines: TStrings): TJVCSLineHistoryRevision;
var
  S: string;
  {$IFDEF LINEINFOEX}
  LineInfo: TObjectList;
  {$ENDIF LINEINFOEX}
begin
  Result := nil;
  S := GetPreparedInfoFileName(AModuleRevisionList.ModuleID, AModuleRevisionList[AIndex].RevisionID, AModuleRevisionList.Extension);
  if {(I = FirstFullRevisionIndex) and }FileExists(S) then
  begin
    RevisionInfoLoadFromFile(ALines, S);
    {$IFDEF LINEINFOEX}
    LineInfo := TObjectList.Create;
    try
      if FileExists(S + 'Ex2') then
        RevisionInfoExLoadFromZXMLFile(LineInfo, S + 'Ex2')
      else
      if FileExists(S + 'Ex') then
        RevisionInfoExLoadFromFile(LineInfo, S + 'Ex');
    {$ENDIF LINEINFOEX}
    Result := ALineHistory.AddPreparedRevision(AModuleRevisionList[AIndex].RevisionID, ALines {$IFDEF LINEINFOEX} , LineInfo {$ENDIF});
    {$IFDEF LINEINFOEX}
    finally
      LineInfo.Free;
    end;
    {$ENDIF LINEINFOEX}
  end;
end;

function TLocalPreparedRevisionInfoProvider.GetPreparedInfoFileName(AModuleID, ARevisionID: Integer; AExtension: string): string;
begin
  //FProvider.ServerInfo is now part of FPrepareRevisionInfoPath in ...Frame.pas
  //Result := PathAddSeparator(FPrepareRevisionInfoPath) + EncodeFileName(UpperCase(FProvider.ServerInfo))
  Result := PathAddSeparator(FPrepareRevisionInfoPath)
    + Format('Module_%d_RevisionInfo_%d%s.jvcs', [AModuleID, ARevisionID, AExtension]);
end;

function TLocalPreparedRevisionInfoProvider.InfoExists(AModuleRevisionList: TJVCSLineHistoryModuleRevisionList; AFirstIndex, ALastIndex: Integer): Integer;
var
  I, LastRevisionID: Integer;
begin
  Result := -1;
  if Assigned(AModuleRevisionList) then
  begin
    LastRevisionID := -1;
    for I := AFirstIndex to ALastIndex do
    begin
      if (LastRevisionID <> AModuleRevisionList[I].RevisionID) then
      begin
        LastRevisionID := AModuleRevisionList[I].RevisionID;
        if FileExists(GetPreparedInfoFileName(AModuleRevisionList.ModuleID, AModuleRevisionList[I].RevisionID, AModuleRevisionList.Extension)) then
        {$IFDEF LINEINFOEX}
          if FileExists(GetPreparedInfoFileName(AModuleRevisionList.ModuleID, AModuleRevisionList[I].RevisionID, AModuleRevisionList.Extension)+ 'Ex2') then
        {$ENDIF LINEINFOEX}
          Result := I;
      end;
    end;
  end;
end;

procedure TLocalPreparedRevisionInfoProvider.StoreInfo(ALineHistory: TJVCSLineHistory; AModuleRevisionList: TJVCSLineHistoryModuleRevisionList; ALastRevisionID: Integer);
var
  S: string;
begin
  S := GetPreparedInfoFileName(AModuleRevisionList.ModuleID, ALastRevisionID, AModuleRevisionList.Extension);
  ForceDirectories(ExtractFilePath(S));
  RevisionInfoSaveToFile(ALineHistory.Lines, S);
  {$IFDEF LINEINFOEX}
  RevisionInfoExSaveToFile(ALineHistory.LineInfos, S + 'Ex');
  RevisionInfoExSaveToZXMLFile(ALineHistory.LineInfos, S + 'Ex2');
  {$ENDIF LINEINFOEX}
end;

constructor TJVCSLineHistoryBuilder.Create;
begin
  inherited Create;
  FFirstRevisionLink := nil;
  FLastRevisionLink := nil;
  FLineHistory := nil;
  FModuleExtension := '';
  FModuleName := '';
  FProvider := nil;
  FOnProgress := nil;
end;

function EncodeFileName(AValue: string): string;
const
  InvalidPMChars = ['"', '/', '\', '<', '>', '[', ']', ':', ';', '|', '{', '}', '*', '%', '?'];
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(AValue) do
    if (AValue[I] in InvalidPMChars) or (Ord(AValue[I]) < 32) then
      Result := Result + Format('%%%.2x', [Ord(AValue[I])])
    else
      Result := Result + AValue[I];
end;

procedure TJVCSLineHistoryBuilder.BuildLineHistoryInfo;

  procedure RevisionContentToStrings(AStringStream: TStringStream; AStrings: TStrings);
  var
    TextStream: Boolean;
    DFMStream: TStringStream;
  begin
    AStringStream.Position := 0;
    TextStream := IsTextStream(AStringStream);
    AStringStream.Position := 0;
    if TextStream then
      AStrings.Text := AStringStream.DataString
    else
    if SameText(FModuleExtension, '.dfm') and IsBinaryDFMStream(AStringStream) then
    begin
      DFMStream := TStringStream.Create('');
      try
        ObjectResourceToText(AStringStream, DFMStream);
        AStrings.Text := DFMStream.DataString;
      finally
        DFMStream.Free;
      end;
    end;
  end;

var
  TSL: TStringList;
  ModuleRevisionList: TJVCSLineHistoryModuleRevisionList;
  I, LastRevisionID, MaxUserNameLength: Integer;
  UserName: string;
  FirstFullRevisionIndex: Integer;
  RevisionInfo: TJVCSLineHistoryRevision;
  StringStream: TStringStream;
  FirstIndex, FirstVisibleIndex, LastIndex: Integer;
  S: string;
  LocalFileTimeStamp: TDateTime;
  Aborted: Boolean;
  LocalFileStream: TFileStream;
begin
  ModuleRevisionList := TJVCSLineHistoryModuleRevisionList.Create(FProvider);
  try
    ModuleRevisionList.Fill(FModuleName, FModuleExtension);
    if FFirstRevisionLink.Kind = lhrkFirstRevision then
    begin
      FirstIndex := 0;
      FirstVisibleIndex := 0;
    end
    else
    begin
      FirstIndex := 0;
      FirstVisibleIndex := 0;
      for I := 0 to Pred(ModuleRevisionList.Count) do
        if ModuleRevisionList[I].RevisionID = FFirstRevisionLink.RevisionID then
        begin
          FirstIndex := I;
          FirstVisibleIndex := I;
          if FirstIndex > 0 then
            Dec(FirstIndex);
          Break;
        end;
    end;
    if FLastRevisionLink.Kind in [lhrkLatestRevision, lhrkLocalFile] then
      LastIndex := Pred(ModuleRevisionList.Count)
    else
    begin
      LastIndex := Pred(ModuleRevisionList.Count);
      for I := 0 to Pred(ModuleRevisionList.Count) do
        if ModuleRevisionList[I].RevisionID = FLastRevisionLink.RevisionID then
        begin
          LastIndex := I;
          Break;
        end;
    end;
    LastRevisionID := -1;
    Aborted := False;
    DoProgress(0, ModuleRevisionList.Count, Aborted);
    MaxUserNameLength := 0;
    for I := FirstIndex to LastIndex do
    begin
      UserName := ModuleRevisionList[I].UserStr;
      if Length(UserName) > MaxUserNameLength then
        MaxUserNameLength := Length(UserName);
    end;
    FirstFullRevisionIndex := 0;
    if Assigned(FPreparedRevisionInfoProvider) then
      FirstFullRevisionIndex := FPreparedRevisionInfoProvider.InfoExists(ModuleRevisionList, FirstIndex, LastIndex);
    for I := FirstIndex to LastIndex do
      if not Aborted then
    begin
      if (LastRevisionID <> ModuleRevisionList[I].RevisionID) then
      begin
        LastRevisionID := ModuleRevisionList[I].RevisionID;
        if I >= FirstFullRevisionIndex then
        begin
          TSL := TStringList.Create;
          try
            StringStream := TStringStream.Create('');
            try
              ModuleRevisionList[I].GetContent(StringStream);
              RevisionContentToStrings(StringStream, TSL);
            finally
              StringStream.Free;
            end;
            UserName := ModuleRevisionList[I].UserStr;
            if Length(UserName) < MaxUserNameLength then
              UserName := StringOfChar(' ', MaxUserNameLength - Length(UserName)) + UserName;
            if (I = FirstFullRevisionIndex) and Assigned(FPreparedRevisionInfoProvider) then
              RevisionInfo := FPreparedRevisionInfoProvider.ApplyInfo(FLineHistory, ModuleRevisionList, FirstFullRevisionIndex, TSL)
            else
              RevisionInfo := nil;
            if not Assigned(RevisionInfo) then
              RevisionInfo := FLineHistory.AddRevision(ModuleRevisionList[I].RevisionID, TSL);
            FLineHistory.BuildInfo;
          finally
            TSL.Free;
          end;
        end
        else
        begin
          RevisionInfo := FLineHistory.AddRevision(ModuleRevisionList[I].RevisionID, nil);
          FLineHistory.BuildInfo;
        end;
        if Assigned(RevisionInfo) then
        begin
          //todo - suppressing revisions before the first selected needs another solution
          if (I = FirstIndex) and (FirstIndex < FirstVisibleIndex) then
          begin
            RevisionInfo.OrgRevisionStr := '';
            RevisionInfo.OrgUserStr := '';
            RevisionInfo.Date := 0;
            RevisionInfo.Comment := '';
          end
          else
          begin
            RevisionInfo.OrgRevisionStr := ModuleRevisionList[I].RevisionStr;
            RevisionInfo.OrgUserStr := ModuleRevisionList[I].UserStr;
            RevisionInfo.Date := ModuleRevisionList[I].Timestamp;
            RevisionInfo.Comment := ModuleRevisionList[I].CheckInComment;
          end;
        end;
      end;
      DoProgress(I + 1, ModuleRevisionList.Count, Aborted);
    end;
    if Assigned(FLineHistory.LastPreparedRevision) and (FirstIndex = 0) and Assigned(FPreparedRevisionInfoProvider) and
      (not ((FirstFullRevisionIndex > 0) and (FirstFullRevisionIndex = LastIndex))) then
      FPreparedRevisionInfoProvider.StoreInfo(FLineHistory, ModuleRevisionList, FLineHistory.LastPreparedRevision.RevisionID);
  finally
    ModuleRevisionList.Free;
  end;
  S := ChangeFileExt(FModuleName, FModuleExtension);
  if (FLastRevisionLink.Kind = lhrkLocalFile) and FileExists(S) then
  begin
    TSL := TStringList.Create;
    try
      StringStream := TStringStream.Create('');
      try
        LocalFileStream := TFileStream.Create(S, fmOpenRead);
        try
          StringStream.CopyFrom(LocalFileStream, 0);
        finally
          LocalFileStream.Free;
        end;
        RevisionContentToStrings(StringStream, TSL);
      finally
        StringStream.Free;
      end;
      RevisionInfo := FLineHistory.AddRevision(0, TSL);
    finally
      TSL.Free;
    end;
    RevisionInfo.OrgRevisionStr := 'File';
    try
      RevisionInfo.OrgUserStr := FileGetOwnerName(S);
    except
      on E:{$IFDEF COMPILER6_UP} EOSError{$ELSE} EWin32Error{$ENDIF} do
        RevisionInfo.OrgUserStr := ''
      else
        raise;
    end;
    if RevisionInfo.OrgUserStr = '' then
      RevisionInfo.OrgUserStr := '?';
    if not GetFileLastWrite(S, LocalFileTimeStamp) then
      LocalFileTimeStamp := 0;
    RevisionInfo.Date := LocalFileTimeStamp;
    RevisionInfo.Comment := 'Local file';
    FLineHistory.BuildInfo;
  end;
end;

procedure TJVCSLineHistoryBuilder.DoProgress(APosition, AMax: Integer; var AAbort: Boolean);
begin
  if Assigned(FOnProgress) then
    FOnProgress(Self, APosition, AMax, AAbort);
end;

end.
