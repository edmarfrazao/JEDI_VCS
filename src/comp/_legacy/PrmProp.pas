{*_* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Author:       François PIETTE
Description:  Property editor for component TMWTable
Creation:     June 28, 1998
Version:      1.03
EMail:        francois.piette@overbyte.be   http://www.overbyte.be
Support:      Use the mailing list midware@elists.org
              Follow "support" link at http://www.overbyte.be for subscription.
Legal issues: Copyright (C) 1998-2006 by François PIETTE
              Rue de Grady 24, 4053 Embourg, Belgium. Fax: +32-4-365.74.56
              <francois.piette@overbyte.be>

              This software is provided 'as-is', without any express or
              implied warranty.  In no event will the author be held liable
              for any  damages arising from the use of this software.

              Permission is granted to anyone to use this software and or any
              derived or altered versions for any purpose, excluding commercial
              applications. You can use this software for personal use only.
              You may distribute it freely untouched.
              The following restrictions applies:

              1. The origin of this software must not be misrepresented, you
                 must not claim that you wrote the original software.

              2. If you use this software in a product, an acknowledgment in
                 the product documentation and displayed on screen is required.
                 The text must be: "This product is based on MidWare. Freeware
                 source code is available at http://www.overbyte.be."

              3. Altered source versions must be plainly marked as such, and
                 must not be misrepresented as being the original software.

              4. This notice may not be removed or altered from any source
                 distribution and must be added to the product documentation.

Updates:
Mar 06, 1999  V1.01 changed atoi to use sign
Jul 15, 2002  V1.02 Adapted for Delphi 7
Aug 28, 2004  V1.03 Use MWDefs.inc. Removed unused units.


 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit PrmProp;

{$ifdef FPC}
  {$MODE DELPHI}
{$endif}

{$I MWDEFS.INC}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
{$IFDEF DELPHI6_UP}
  // Add $(DELPHI)\Source\ToolsAPI to your library path
  // Add designide.dcp to the package
  DesignIntf, DesignEditors,
{$ELSE}
  DsgnIntf,
{$ENDIF}
  DB, StdCtrls, ExtCtrls, Grids, Buttons, IniFiles, LOPropIm, RFormat;

const
  PrmPropVersion = 103;
  CopyRight : String = ' TRequestParams (c) 1998-2006 F. Piette V1.03 ';

type
  TRequestParamsProperty = class(TPropertyEditor)
  public
      function  GetAttributes : TPropertyAttributes; override;
      function  GetValue      : String; override;
      procedure Edit; override;
  end;

  TRequestParamsEditForm = class(TForm)
    ParamsStringGrid: TStringGrid;
    OkPanel: TPanel;
    OkButton: TButton;
    CancelButton: TButton;
    RowGroupBox: TGroupBox;
    RowDownBitBtn: TBitBtn;
    RowUpBitBtn: TBitBtn;
    RowDelBitBtn: TBitBtn;
    RowAddBitBtn: TBitBtn;
    MWBuffer: TMWBuffer;
    ColGroupBox: TGroupBox;
    ColAddBitBtn: TBitBtn;
    ColDelBitBtn: TBitBtn;
    ColRightBitBtn: TBitBtn;
    ColLeftBitBtn: TBitBtn;
    procedure OkButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ParamsStringGridKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ParamsStringGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ParamsStringGridKeyPress(Sender: TObject; var Key: Char);
    procedure RowDelBitBtnClick(Sender: TObject);
    procedure RowAddBitBtnClick(Sender: TObject);
    procedure ParamsStringGridClick(Sender: TObject);
    procedure RowUpBitBtnClick(Sender: TObject);
    procedure RowDownBitBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ColAddBitBtnClick(Sender: TObject);
    procedure ColDelBitBtnClick(Sender: TObject);
    procedure ColLeftBitBtnClick(Sender: TObject);
    procedure ColRightBitBtnClick(Sender: TObject);
  private
    FIniFileName : String;
    FRowBefore   : Integer;
    FRowAfter    : Integer;
    FColBefore   : Integer;
    FColAfter    : Integer;
    FDeleteFlag  : Boolean;
    FKeyMove     : Boolean;
    procedure InsertLine;
    procedure DeleteLine;
    procedure LineDown;
    procedure LineUp;
    procedure SetParamsText(newValue : String);
    function  GetParamsText : String;
    procedure OnGetMinMaxInfo(var Msg: TMessage); message WM_GETMINMAXINFO;
    function  MaxGridCol(nRow : Integer): Integer;
    procedure AdjustColCount;
  public
    property ParamsText : String  read GetParamsText write SetParamsText;
    property IniFileName : String read FIniFileName  write FIniFileName;
  end;

function stpblk(PValue : PChar) : PChar;
function atoi(value : string) : Integer;
function atof(value : string) : Extended;
function GetToken(Src : PChar; var Dst : String; var Delim : Char) : PChar;
procedure Register;

var
  RequestParamsEditForm: TRequestParamsEditForm;


implementation

uses MwDatSet;

{$R *.DFM}
const
    SectionWindow       = 'Window';
    KeyTop              = 'Top';
    KeyLeft             = 'Left';
    KeyWidth            = 'Width';
    KeyHeight           = 'Height';

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TRequestParamsProperty.GetAttributes : TPropertyAttributes;
begin
    Result := [paDialog];
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TRequestParamsProperty.GetValue : String;
begin
    Result := '(TRequestParams)';
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestParamsProperty.Edit;
var
    Dialog : TRequestParamsEditForm;
    x      : TComponent;
begin
    Dialog := TRequestParamsEditForm.Create(nil);
    try
        Dialog.IniFileName := PrivateDirectory + '\RequestParamsPropertyEditor.ini';
        x := GetComponent(0) as TComponent;
        Dialog.Caption := x.Owner.Name + '.' +
                          x.Name + ' - ' + Dialog.Caption;
        Dialog.ParamsText := GetStrValue;
        if Dialog.ShowModal = mrOk then
            SetStrValue(Dialog.ParamsText);
    finally
        Dialog.Free;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestParamsEditForm.FormShow(Sender: TObject);
var
    IniFile : TIniFile;
begin
    if FIniFileName > '' then begin
        { Get screen position and size from inifile, center by default }
        IniFile := TIniFile.Create(FIniFileName);
        Top     := IniFile.ReadInteger(SectionWindow, KeyTop,
                                       (Screen.Height - Height) div 2);
        Left    := IniFile.ReadInteger(SectionWindow, KeyLeft,
                                       (Screen.Width - Width) div 2);
        Width   := IniFile.ReadInteger(SectionWindow, KeyWidth,  Width);
        Height  := IniFile.ReadInteger(SectionWindow, KeyHeight, Height);
        IniFile.Free;
    end
    else begin
        { No inifile specified, center form on screen }
        Top  := (Screen.Height - Height) div 2;
        Left := (Screen.Width - Width) div 2;
    end;
    with ParamsStringGrid do begin
        Cells[1, 0]  := 'A';
        Cells[2, 0]  := 'B';
        Cells[0, 1]  := '1';
        ColWidths[0] := 16;
    end;
    ActiveControl := ParamsStringGrid;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestParamsEditForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
    IniFile : TIniFile;
begin
    if FIniFileName > '' then begin
        IniFile := TIniFile.Create(FIniFileName);
        IniFile.WriteInteger(SectionWindow, KeyTop,    Top);
        IniFile.WriteInteger(SectionWindow, KeyLeft,   Left);
        IniFile.WriteInteger(SectionWindow, KeyWidth,  Width);
        IniFile.WriteInteger(SectionWindow, KeyHeight, Height);
        IniFile.Free;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestParamsEditForm.OnGetMinMaxInfo(var Msg: TMessage);
var
   p : PMINMAXINFO;
begin
   p := PMINMAXINFO(Msg.lParam);
   if Assigned(RowDownBitBtn) and Assigned (OkPanel) then begin
       p^.ptMinTrackSize.X := OkPanel.Width * 4;
       p^.ptMinTrackSize.Y := RowDownBitBtn.Top + RowDownBitBtn.Height + 4 +
                              OkPanel.Height + GetSystemMetrics(SM_CYCAPTION) +
                              2 * GetSystemMetrics(SM_CYFRAME);
   end;
   Msg.Result := 0;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestParamsEditForm.OkButtonClick(Sender: TObject);
begin
    ModalResult := mrOk;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestParamsEditForm.CancelButtonClick(Sender: TObject);
begin
    ModalResult := mrCancel;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestParamsEditForm.ParamsStringGridKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
    nRow : Integer;
begin
    FKeyMove   := TRUE;
    FRowBefore := ParamsStringGrid.Row;
    FColBefore := ParamsStringGrid.Col;
    FDeleteFlag := FALSE;
    if ((Shift = []) and (Key in [VK_DOWN, VK_UP, VK_PRIOR, VK_NEXT])) or
       ((ssCtrl in Shift) and (Key in [VK_HOME, VK_END, VK_PRIOR, VK_NEXT])) then begin
        with ParamsStringGrid do begin
            if (Row < (RowCount - 1)) and (Trim(Cells[1, FRowBefore]) = '') then begin
                { Empty row, delete }
                for nRow := FRowBefore to RowCount - 2 do begin
                    Cells[0, nRow] := IntToStr(nRow);
                    Cells[1, nRow] := Cells[1, nRow + 1];
                    Cells[2, nRow] := Cells[2, nRow + 1];
                    Cells[3, nRow] := Cells[3, nRow + 1];
                end;
                RowCount := RowCount - 1;
                if Key = VK_DOWN then begin
                    Key         := 0;
                    FDeleteFlag := TRUE;
                end;
            end;
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestParamsEditForm.ParamsStringGridKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
    FKeyMove   := FALSE;
    FRowAfter  := ParamsStringGrid.Row;
    FColAfter  := ParamsStringGrid.Col;
    if FDeleteFlag then begin
        ParamsStringGrid.Row := FRowBefore;
        Exit;
    end;

    if Key = VK_DOWN then begin
        with ParamsStringGrid do begin
            if FRowAfter = FRowBefore then begin
                if Trim(Cells[1, RowCount - 1]) > '' then begin
                    RowCount := RowCount + 1;
                    Cells[0, RowCount - 1] := IntToStr(RowCount - 1);
                    Cells[1, RowCount - 1] := '';
                    Cells[2, RowCount - 1] := '';
                    Cells[3, RowCount - 1] := '';
                    Row := RowCount - 1;
                    Col := 1;
                    Key := 0;
                end;
            end;
        end;
    end
    else if key = VK_RIGHT then begin
        with ParamsStringGrid do begin
            if FColAfter = FColBefore then begin
                Key      := 0;
                ColCount := ColCount + 1;
                Col      := ColCount - 1;
                Cells[ColCount - 1, 0] := Chr(Ord('A') + ColCount - 2);
            end;
        end;
    end
    else if (Key = VK_UP) and (FRowAfter <> FRowBefore) then begin
        with ParamsStringGrid do begin
            if Trim(Cells[1, RowCount - 1]) = '' then
                RowCount := RowCount - 1;
        end;
        Key := 0;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestParamsEditForm.ParamsStringGridKeyPress(Sender: TObject;
    var Key: Char);
begin
    if Key = Char(Ord('N') - Ord('@')) then begin
        { Ctrl-N inserts a new line }
        InsertLine;
        Key := #0;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestParamsEditForm.DeleteLine;
var
    nRow : Integer;
begin
    with ParamsStringGrid do begin
        if RowCount = 2 then begin
            Cells[1, Row] := '';
            Cells[2, Row] := '';
        end
        else begin
            for nRow := Row to RowCount - 2 do begin
                Cells[0, nRow] := IntToStr(nRow);
                Cells[1, nRow] := Cells[1, nRow + 1];
                Cells[2, nRow] := Cells[2, nRow + 1];
                Cells[3, nRow] := Cells[3, nRow + 1];
            end;
            RowCount := RowCount - 1;
        end;
        AdjustColCount;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestParamsEditForm.InsertLine;
var
    nRow : Integer;
begin
    with ParamsStringGrid do begin
        if Trim(Cells[1, Row]) > '' then begin
            RowCount := RowCount + 1;
            Cells[0, RowCount - 1] := IntToStr(RowCount - 1);
            for nRow := RowCount - 1 downto Row do begin
                Cells[0, nRow + 1] := IntToStr(nRow+ 1);
                Cells[1, nRow + 1] := Cells[1, nRow];
                Cells[2, nRow + 1] := Cells[2, nRow];
                Cells[3, nRow + 1] := Cells[3, nRow];
            end;
            Cells[1, Row] := '';
            Cells[2, Row] := '';
            Cells[3, Row] := '';
            Col           := 1;
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestParamsEditForm.LineUp;
var
    Buf : String;
    nCol : Integer;
begin
    with ParamsStringGrid do begin
        if Row <= 1 then
            Exit;
        for nCol := 1 to ColCount do begin
            Buf                  := Cells[nCol, Row];
            Cells[nCol, Row]     := Cells[nCol, Row - 1];
            Cells[nCol, Row - 1] := Buf;
        end;
        Row := Row - 1;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestParamsEditForm.LineDown;
var
    Buf : String;
    nCol : Integer;
begin
    with ParamsStringGrid do begin
        if Row >= (RowCount - 1) then
            Exit;
        for nCol := 1 to ColCount do begin
            Buf                  := Cells[nCol, Row];
            Cells[nCol, Row]     := Cells[nCol, Row + 1];
            Cells[nCol, Row + 1] := Buf;
        end;
        Row := Row + 1;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestParamsEditForm.RowDelBitBtnClick(Sender: TObject);
begin
    DeleteLine;
    ActiveControl := ParamsStringGrid;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestParamsEditForm.RowAddBitBtnClick(Sender: TObject);
begin
    InsertLine;
    ActiveControl := ParamsStringGrid;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestParamsEditForm.RowUpBitBtnClick(Sender: TObject);
begin
    LineUp;
    ActiveControl := ParamsStringGrid;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestParamsEditForm.RowDownBitBtnClick(Sender: TObject);
begin
    LineDown;
    ActiveControl := ParamsStringGrid;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestParamsEditForm.ParamsStringGridClick(Sender: TObject);
var
    nRow : Integer;
begin
    if FKeyMove then
        Exit;

    FRowAfter  := ParamsStringGrid.Row;
    if FRowAfter = FRowBefore then
        Exit;

    with ParamsStringGrid do begin
        if (Row < (RowCount - 1)) and (Trim(Cells[1, FRowBefore]) = '') then begin
            { Empty row, delete }
            for nRow := FRowBefore to RowCount - 2 do begin
                Cells[0, nRow] := IntToStr(nRow);
                Cells[1, nRow] := Cells[1, nRow + 1];
                Cells[2, nRow] := Cells[2, nRow + 1];
                Cells[3, nRow] := Cells[3, nRow + 1];
            end;
            RowCount := RowCount - 1;
        end;
    end;
    FRowBefore := ParamsStringGrid.Row;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function DoubleQuote(Value : String) : String;
var
    I : Integer;
begin
    Result := '';
    for I := 1 to Length(Value) do begin
        if Value[I] = '''' then
            Result := Result + ''''''
        else
            Result := Result + Value[I];
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
// Find last cell used in a given row
function TRequestParamsEditForm.MaxGridCol(nRow : Integer): Integer;
begin
    with ParamsStringGrid do begin
        Result := ColCount - 1;
        while Result >= 1 do begin
            if Cells[Result, nRow] > '' then
                break;
            Dec(Result);
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TRequestParamsEditForm.GetParamsText : String;
var
    nRow    : Integer;
    nCol    : Integer;
    MaxCol  : Integer;
begin
    Result := '';
    with ParamsStringGrid do begin
        for nRow := 1 to RowCount - 1 do begin
            // Find last cell used
            MaxCol := MaxGridCol(nRow);
            if MaxCol > 0 then begin
                if nRow > 1 then
                    Result := Result + ';';
                for nCol := 1 to MaxCol do begin
                    if nCol > 1 then
                        Result := Result + ',';
                    Result := Result + '''' + DoubleQuote(Cells[nCol, nRow]) + '''';
                end;
            end;
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestParamsEditForm.SetParamsText(newValue : String);
var
    nCol      : Integer;
    nRow      : Integer;
begin
    MWBuffer.Rewrite;
    MWBuffer.StringToRecords(newValue);
    MWBuffer.First;
    nRow := 1;
    while not MWBuffer.Eof do begin
        if ParamsStringGrid.RowCount < (nRow + 1) then
            ParamsStringGrid.RowCount := nRow + 1;
        if ParamsStringGrid.ColCount < (MWBuffer.FieldCount + 1) then begin
            nCol := ParamsStringGrid.ColCount;
            ParamsStringGrid.ColCount := MWBuffer.FieldCount + 1;
            while nCol < ParamsStringGrid.ColCount do begin
                ParamsStringGrid.Cells[nCol, 0] := Chr(Ord('A') + nCol - 1);
                Inc(nCol);
            end;
        end;
        ParamsStringGrid.Cells[0, nRow] := IntToStr(nRow);
        for nCol := 1 to MWBuffer.FieldCount do
            ParamsStringGrid.Cells[nCol, nRow] := MWBuffer.Fields[nCol - 1];
        Inc(nRow);
        MWBuffer.Next;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function stpblk(PValue : PChar) : PChar;
begin
    Result := PValue;
    while Result^ in [' ', #9, #10, #13] do
        Inc(Result);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function atof(value : string) : Extended;
begin
    if Value = '' then
        Result := 0
    else begin
        try
            Result := StrToFloat(Value);
        except
            Result := 0;
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function atoi(value : string) : Integer;
var
    i    : Integer;
    Sign : Char;
begin
    Result := 0;
    Sign   := '+';
    i      := 1;
    while (i <= Length(Value)) and (Value[i] = ' ') do
        i := i + 1;
    if (i <= Length(Value)) and (Value[i] in ['+', '-']) then begin
        Sign := Value[i];
        Inc(i);
    end;
    while (i <= Length(Value)) and (Value[i] >= '0') and (Value[i] <= '9')do begin
        Result := Result * 10 + ord(Value[i]) - ord('0');
        i := i + 1;
    end;
    if Sign = '-' then
        Result := -Result;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function GetToken(Src : PChar; var Dst : String; var Delim : Char) : PChar;
begin
    Result := StpBlk(Src);
    Dst    := '';
    while TRUE do begin
        Delim := Result^;
        if Delim in [';', #0] then
            break;
        Dst := Dst + UpperCase(Result^);
        Inc(Result);
    end;
    if Delim <> #0 then
        Inc(Result);
    Result := stpblk(Result);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure Register;
begin
    RegisterPropertyEditor(TypeInfo(TRequestParams), TMWTable,
                           'Params', TRequestParamsProperty);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestParamsEditForm.ColAddBitBtnClick(Sender: TObject);
var
    MaxCol : Integer;
    nCol   : Integer;
begin
    with ParamsStringGrid do begin
        MaxCol := MaxGridCol(Row);
        if MaxCol >= (ColCount - 1) then begin
            nCol     := ColCount;
            ColCount := ColCount + 1;
            Cells[nCol, 0] := Chr(Ord('A') + nCol - 1);
        end;
        for nCol := ColCount - 1 downto Col do
            Cells[nCol, Row] := Cells[nCol - 1, Row];
        Cells[Col, Row] := '';
    end;
    ActiveControl := ParamsStringGrid;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestParamsEditForm.AdjustColCount;
var
    nRow   : Integer;
    MaxCol : Integer;
    MaxMax : Integer;
begin
    with ParamsStringGrid do begin
        if ColCount > 2 then begin
            MaxMax := MaxGridCol(1);
            for nRow := 2 to RowCount - 1 do begin
                MaxCol := MaxGridCol(nRow);
                if MaxMax < MaxCol then
                    MaxMax := MaxCol;
            end;
            if MaxMax <= 1 then
                ColCount := 2
            else if MaxMax < (ColCount - 1) then
                ColCount := MaxMax + 1;
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestParamsEditForm.ColDelBitBtnClick(Sender: TObject);
var
    nCol   : Integer;
begin
    with ParamsStringGrid do begin
        for nCol := Col to ColCount - 2 do
            Cells[nCol, Row] := Cells[nCol + 1, Row];
        Cells[ColCount - 1, Row] := '';
        if (RowCount > 2) and (MaxGridCol(Row) <= 0) then
            DeleteLine
        else
            AdjustColCount;
    end;
    ActiveControl := ParamsStringGrid;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestParamsEditForm.ColLeftBitBtnClick(Sender: TObject);
var
    Temp : String;
begin
    with ParamsStringGrid do begin
        if Col <= 1 then
            MessageBeep(MB_OK)
        else begin
            Temp                := Cells[Col - 1, Row];
            Cells[Col - 1, Row] := Cells[Col, Row];
            Cells[Col, Row]     := Temp;
            Col                 := Col - 1;
        end;
    end;
    ActiveControl := ParamsStringGrid;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRequestParamsEditForm.ColRightBitBtnClick(Sender: TObject);
var
    Temp : String;
    nCol : Integer;
begin
    with ParamsStringGrid do begin
        if Col >= (ColCount - 1) then begin
            nCol     := ColCount;
            ColCount := ColCount + 1;
            Cells[nCol, 0] := Chr(Ord('A') + nCol - 1);
            Col      := nCol - 1;
        end;
        Temp                := Cells[Col + 1, Row];
        Cells[Col + 1, Row] := Cells[Col, Row];
        Cells[Col, Row]     := Temp;
        Col                 := Col + 1;
    end;
    ActiveControl := ParamsStringGrid;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

end.


