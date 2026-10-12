(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSCompressedDiffDialog.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
Jan/10
- USc: DiffMode is currently swapped
-----------------------------------------------------------------------------

Unit history:

2009/11/27  USchuster - new unit
2010/01/23  THuber    - close form on pressing ESC
2010/01/24  USchuster - added ShowCompressDiffDialogLocalToLatest (Mantis #5101)
                      - added progress and caption
2011/01/15  USchuster - changed font to Tahoma                      

-----------------------------------------------------------------------------*)

unit JVCSCompressedDiffDialog;

{$I jedi.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  {$IFDEF HAS_UNIT_VARIANTS}
  Variants,
  {$ENDIF HAS_UNIT_VARIANTS}
  Dialogs, JVCSCompressedDiffFrame, JVCSClientObj, StdCtrls, ExtCtrls,
  ComCtrls;

type
  TCompressedDiffMode = (cdmLatestToLocal, cdmLocalToLatest);

  TVCSCompressedDiff = class(TForm)
    CompressedDiffFrame: TJVCSCompressedDiffFrm;
    Panel1: TPanel;
    Button1: TButton;
    PB: TProgressBar;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    FDestRevisionID: Integer;
    FExtension: string;
    FInitialized: Boolean;
    FLines1: TStringList;
    FLines2: TStringList;
    FMode: TCompressedDiffMode;
    FSourceFile: string;
  public
    { Public declarations }
    property DestRevisionID: Integer read FDestRevisionID write FDestRevisionID;
    property Extension: string read FExtension write FExtension;
    property Mode: TCompressedDiffMode read FMode write FMode;
    property SourceFile: string read FSourceFile write FSourceFile;
  end;

var
  VCSCompressedDiff: TVCSCompressedDiff;

procedure ShowCompressDiffDialog(const ALocalFile: string; ARevisionID: Integer; const AExtension: string);
procedure ShowCompressDiffDialogLocalToLatest(const ALocalFile: string; const AExtension: string;
  AModuleID: Integer; ARevisionID: Integer = 0);

implementation

uses
  DBModule, JVCSClientFunctions, VCSBase, ConfigStorage;

{$R *.dfm}

procedure ShowCompressDiffDialog(const ALocalFile: string; ARevisionID: Integer; const AExtension: string);
begin
  VCSCompressedDiff := TVCSCompressedDiff.Create(Application);
  try
    VCSCompressedDiff.SourceFile := ALocalFile;
    VCSCompressedDiff.DestRevisionID := ARevisionID;
    VCSCompressedDiff.Extension := AExtension;
    VCSCompressedDiff.Mode := cdmLatestToLocal;    
    VCSCompressedDiff.ShowModal;
  finally
    VCSCompressedDiff.Free;
  end;
end;

procedure ShowCompressDiffDialogLocalToLatest(const ALocalFile: string; const AExtension: string;
  AModuleID: Integer; ARevisionID: Integer = 0);
var
  I, LatestRevisionID: Integer;
  GetRevisionListById: TJVCSGetRevisionListById;
begin
  if ARevisionID > 0 then
    LatestRevisionID := ARevisionID
  else
  begin
    GetRevisionListById := TJVCSGetRevisionListById.Create(nil);
    try
      GetRevisionListById.ModuleID := AModuleID;
      GetRevisionListById.ProjectID := ServerProjectID;
      DataModule1.ClientObjectSendRequest(GetRevisionListById);
      LatestRevisionID := -1;
      for I := 0 to Pred(GetRevisionListById.OutputItemCount) do
        LatestRevisionID := GetRevisionListById.OutputItems[I].RevisionID;
    finally
      GetRevisionListById.Free;
    end;
  end;
  if LatestRevisionID > 0 then
  begin
    VCSCompressedDiff := TVCSCompressedDiff.Create(Application);
    try
      VCSCompressedDiff.SourceFile := ALocalFile;
      VCSCompressedDiff.DestRevisionID := LatestRevisionID;
      VCSCompressedDiff.Extension := AExtension;
      VCSCompressedDiff.Mode := cdmLocalToLatest;
      VCSCompressedDiff.ShowModal;
    finally
      VCSCompressedDiff.Free;
    end;
  end;
end;

procedure TVCSCompressedDiff.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  jvcsWriteWindowPosAndSize(sBaseRegistryKey + crbWindows, 'CompressedDiff',
    Top, Left, Width, Height);
end;

procedure TVCSCompressedDiff.FormCreate(Sender: TObject);
var
  DlgTop,
  DlgLeft,
  DlgWidth,
  DlgHeight: Integer;
begin
  FInitialized := False;
  FLines1 := TStringList.Create;
  FLines2 := TStringList.Create;
  FMode := cdmLatestToLocal;

  if not jvcsReadWindowPosAndSize(sBaseRegistryKey + crbWindows, 'CompressedDiff',
    DlgTop, DlgLeft, DlgWidth, DlgHeight) then
  begin
    DlgTop := (Screen.Height - Height) div 2;
    DlgLeft := (Screen.Width - Width) div 2;
    DlgWidth := MulDiv(530, PixelsPerInch, 96);
    DlgHeight := MulDiv(280, PixelsPerInch, 96);
  end;
  Top := DlgTop;
  Left := DlgLeft;
  Width := DlgWidth;
  Height := DlgHeight;
end;

procedure TVCSCompressedDiff.FormDestroy(Sender: TObject);
begin
  FLines1.Free;
  FLines2.Free;
end;

procedure TVCSCompressedDiff.FormShow(Sender: TObject);

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
    if SameText(FExtension, '.dfm') and IsBinaryDFMStream(AStringStream) then
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
  ContentStream: TMemoryStream;
  StringStream: TStringStream;
  GetSingleBlob: TJVCSGetSingleBlob;
begin
  if not FInitialized then
  begin
    FInitialized := True;
    PB.Position := 0;
    PB.Max := 3;
    PB.Visible := True;
    StringStream := TStringStream.Create('');
    ContentStream := TMemoryStream.Create;
    try
      ContentStream.LoadFromFile(FSourceFile);
      StringStream.CopyFrom(ContentStream, 0);
      RevisionContentToStrings(StringStream, FLines1);
      PB.Position := 1;

      ContentStream.Size := 0;

      GetSingleBlob := TJVCSGetSingleBlob.Create(nil);
      try
        GetSingleBlob.RevisionID := FDestRevisionID;
        GetSingleBlob.Extension := FExtension;
        GetJvcsConnection.SendRequest(GetSingleBlob);
        GetSingleBlob.ExtractBlobToStream(GetSingleBlob.ModuleBinary, StringStream);
      finally
        GetSingleBlob.Free;
      end;
      RevisionContentToStrings(StringStream, FLines2);
      PB.Position := 2;
    finally
      ContentStream.Free;
      StringStream.Free;
    end;
    CompressedDiffFrame.Extension := FExtension;
    if FMode = cdmLatestToLocal then
    begin
      CompressedDiffFrame.Lines1 := FLines1;
      CompressedDiffFrame.Lines2 := FLines2;
      Caption := Format('Compressed Diff - %s (local to latest revision)', [FSourceFile]);
    end
    else
    begin
      CompressedDiffFrame.Lines1 := FLines2;
      CompressedDiffFrame.Lines2 := FLines1;
      Caption := Format('Compressed Diff - %s (latest revision to local)', [FSourceFile]);
    end;
    CompressedDiffFrame.Diff;
    PB.Position := 3;
    PB.Visible := False;
  end;
end;

procedure TVCSCompressedDiff.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Shift = []) and (Key = VK_ESCAPE) then
  begin
    ModalResult := mrCancel;
    Key := 0;
  end;
end;

end.
