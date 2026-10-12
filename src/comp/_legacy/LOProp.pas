{*_* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Author:       François PIETTE
Description:  Property editor for component TMWTable
Creation:     May 30, 1998
Version:      1.07
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
Jun 06, 1998  V1.01 Added an import function to get fields from a TTable
Jun 14, 1998  V1.02 Registered the property editor for TFieldLayout property
              only, avoiding interference with other string type properties.
Jun 20, 1998  V1.03 Added field type support
Jul 16, 1998  V1.04 Compute column width taking scrollbar into account.
              Fixed a spurious MessageBeep when tabbing
              Fixed empty line problem in import function
              Fixed the problem when the grid was completely emptied and
              the user clicks on the OK button.
Mar 06, 1999  V1.05 Changed atoi to use sign
Jul 15, 2002  V1.06 Adapted for Delphi 7
Aug 28, 2004  V1.07 Use MWDefs.inc. Removed unused units.


 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit LOProp;

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
  DB, StdCtrls, ExtCtrls, Grids, Buttons, IniFiles, LOPropIm, Menus;

const
  LOPropVersion      = 107;
  CopyRight : String = ' TLayoutProperty (c) 1998-2006 F. Piette V1.07 ';

type
  TLayoutProperty = class(TPropertyEditor)
  public
      function  GetAttributes : TPropertyAttributes; override;
      function  GetValue      : String; override;
      procedure Edit; override;
  end;

  TLayoutEditForm = class(TForm)
    LayoutStringGrid: TStringGrid;
    DelBitBtn: TBitBtn;
    AddBitBtn: TBitBtn;
    OkPanel: TPanel;
    OkButton: TButton;
    CancelButton: TButton;
    UpBitBtn: TBitBtn;
    DownBitBtn: TBitBtn;
    ImportButton: TButton;
    Label1: TLabel;
    Label2: TLabel;
    PopupMenu1: TPopupMenu;
    PopupChar: TMenuItem;
    PopupInteger: TMenuItem;
    PopupDatetime: TMenuItem;
    PopupFloat: TMenuItem;
    PopupBoolean: TMenuItem;
    Currency1: TMenuItem;
    Memo1: TMenuItem;
    Time1: TMenuItem;
    Date1: TMenuItem;
    procedure OkButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure LayoutStringGridKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure LayoutStringGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
{$IFDEF VER150}
    procedure LayoutStringGridKeyPress(Sender: TObject; var Key : AnsiChar);
{$ELSE}
    procedure LayoutStringGridKeyPress(Sender: TObject; var Key : Char);
{$ENDIF}
    procedure DelBitBtnClick(Sender: TObject);
    procedure AddBitBtnClick(Sender: TObject);
    procedure LayoutStringGridClick(Sender: TObject);
    procedure UpBitBtnClick(Sender: TObject);
    procedure DownBitBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ImportButtonClick(Sender: TObject);
    procedure LayoutStringGridMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure LayoutStringGridExit(Sender: TObject);
    procedure PopupIntegerClick(Sender: TObject);
    procedure PopupCharClick(Sender: TObject);
    procedure PopupFloatClick(Sender: TObject);
    procedure PopupBooleanClick(Sender: TObject);
    procedure PopupDatetimeClick(Sender: TObject);
    procedure Currency1Click(Sender: TObject);
    procedure Memo1Click(Sender: TObject);
    procedure Date1Click(Sender: TObject);
    procedure Time1Click(Sender: TObject);
  private
    FIniFileName : String;
    FRowBefore   : Integer;
    FRowAfter    : Integer;
    FColBefore   : Integer;
    FColAfter    : Integer;
    FRowMouseAfter    : Integer;
    FColMouseAfter    : Integer;
    FDeleteFlag  : Boolean;
    FKeyMove     : Boolean;
    FInvalidCell : Boolean;
    procedure InsertLine;
    procedure DeleteLine;
    procedure LineDown;
    procedure LineUp;
    procedure SetLayoutText(newValue : String);
    function  GetLayoutText : String;
    procedure OnGetMinMaxInfo(var Msg: TMessage); message WM_GETMINMAXINFO;
  public
    function CheckValidFieldType(nRow : Integer) : Boolean;
    function CheckValid : Boolean;
    property LayoutText : String  read GetLayoutText write SetLayoutText;
    property IniFileName : String read FIniFileName  write FIniFileName;
  end;

function stpblk(PValue : PChar) : PChar;
function atoi(value : string) : Integer;
function atof(value : string) : Extended;
function GetToken(Src : PChar; var Dst : String; var Delim : Char) : PChar;
function FieldTypeToString(FldType : TFieldType) : String;
procedure Register;

var
  LayoutEditForm: TLayoutEditForm;

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
function TLayoutProperty.GetAttributes : TPropertyAttributes;
begin
    Result := [paDialog];
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TLayoutProperty.GetValue : String;
begin
    Result := '(TFieldLayout)';
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TLayoutProperty.Edit;
var
    Dialog : TLayoutEditForm;
    x : TComponent;
begin
    Dialog := TLayoutEditForm.Create(nil);
    try
        Dialog.IniFileName := PrivateDirectory + '\LayoutPropertyEditor.ini';
        x := GetComponent(0) as TComponent;
        Dialog.Caption := x.Owner.Name + '.' +
                          x.Name + ' - ' + Dialog.Caption;
        Dialog.LayoutText := GetStrValue;
        if Dialog.ShowModal = mrOk then
            SetStrValue(Dialog.LayoutText);
    finally
        Dialog.Free;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TLayoutEditForm.FormShow(Sender: TObject);
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
    with LayoutStringGrid do begin
        Cells[1, 0] := 'NAME';
        Cells[2, 0] := 'TYPE';
        Cells[3, 0] := 'SIZE';
        Cells[0, 1] := '1';
    end;
    ActiveControl  := LayoutStringGrid;
    FRowMouseAfter := 1;
    FColMouseAfter := 1;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TLayoutEditForm.FormClose(Sender: TObject;
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
procedure TLayoutEditForm.OnGetMinMaxInfo(var Msg: TMessage);
var
   p : PMINMAXINFO;
begin
   p := PMINMAXINFO(Msg.lParam);
   if Assigned(DownBitBtn) and Assigned (OkPanel) then begin
       p^.ptMinTrackSize.X := OkPanel.Width * 4;
       p^.ptMinTrackSize.Y := DownBitBtn.Top + DownBitBtn.Height + 4 +
                              OkPanel.Height + GetSystemMetrics(SM_CYCAPTION) +
                              2 * GetSystemMetrics(SM_CYFRAME);
   end;
   Msg.Result := 0;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TLayoutEditForm.OkButtonClick(Sender: TObject);
begin
    if (LayoutStringGrid.RowCount = 2) and
       (Trim(LayoutStringGrid.Cells[1, 1]) = '') then
        ModalResult := mrOk
    else if CheckValid then
        ModalResult := mrOk;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TLayoutEditForm.CancelButtonClick(Sender: TObject);
begin
    ModalResult := mrCancel;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TLayoutEditForm.FormResize(Sender: TObject);
begin
    with LayoutStringGrid do begin
        ColWidths[0] := 32;
        ColWidths[2] := 48;
        ColWidths[3] := 48;
        ColWidths[1] := Width - ColWidths[0] - ColWidths[2] - ColWidths[3] -
                        8 - GetSystemMetrics(SM_CXVSCROLL);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TLayoutEditForm.PopupIntegerClick(Sender: TObject);
begin
    LayoutStringGrid.Cells[2, LayoutStringGrid.Row] :=
        FieldTypeToString(ftInteger);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TLayoutEditForm.PopupCharClick(Sender: TObject);
begin
    LayoutStringGrid.Cells[2, LayoutStringGrid.Row] :=
        FieldTypeToString(ftString);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TLayoutEditForm.PopupFloatClick(Sender: TObject);
begin
    LayoutStringGrid.Cells[2, LayoutStringGrid.Row] :=
        FieldTypeToString(ftFloat);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TLayoutEditForm.PopupBooleanClick(Sender: TObject);
begin
    LayoutStringGrid.Cells[2, LayoutStringGrid.Row] :=
        FieldTypeToString(ftBoolean);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TLayoutEditForm.PopupDatetimeClick(Sender: TObject);
begin
    LayoutStringGrid.Cells[2, LayoutStringGrid.Row] :=
        FieldTypeToString(ftDateTime);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TLayoutEditForm.LayoutStringGridMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     if FInvalidCell then begin
         FInvalidCell         := FALSE;
         LayoutStringGrid.Col := 2;
         LayoutStringGrid.Row := FRowMouseAfter;
     end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TLayoutEditForm.LayoutStringGridClick(Sender: TObject);
var
    nRow    : Integer;
    FldType : TFieldType;
begin
    FInvalidCell := FALSE;
    if not FKeyMove then begin
        if FColMouseAfter = 2 then begin
             FInvalidCell := not CheckValidFieldType(FRowMouseAfter);
             if FInvalidCell then begin
                 LayoutStringGrid.Row := FRowMouseAfter;
                 LayoutStringGrid.Col := 2;
                 Exit;
             end;
        end;
    end;

    FRowMouseAfter  := LayoutStringGrid.Row;
    FColMouseAfter  := LayoutStringGrid.Col;

    if FKeyMove then begin
        FKeyMove := FALSE;
        Exit;
    end;

    FRowAfter  := LayoutStringGrid.Row;
    FColAfter  := LayoutStringGrid.Col;

    if FRowAfter <> FRowBefore then begin
        with LayoutStringGrid do begin
            if FColBefore = 2 then begin
                FldType := StringToFieldType(Cells[2, FRowBefore]);
                if FldType = ftUnknown then
                    MessageBeep(MB_OK)
                else
                    Cells[2, FRowBefore] := FieldTypeToString(FldType);
            end;

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
    end;

    FRowBefore := LayoutStringGrid.Row;
    FColBefore := LayoutStringGrid.Col;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TLayoutEditForm.LayoutStringGridKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
    nRow    : Integer;
begin
    FKeyMove     := TRUE;
    FInvalidCell := FALSE;
    FRowBefore   := LayoutStringGrid.Row;
    FColBefore   := LayoutStringGrid.Col;
    FDeleteFlag  := FALSE;
    if ((Shift = []) and (Key in [VK_DOWN, VK_UP, VK_PRIOR, VK_NEXT])) or
       ((ssCtrl in Shift) and (Key in [VK_HOME, VK_END, VK_PRIOR, VK_NEXT])) then begin
        with LayoutStringGrid do begin
            if (Row < (RowCount - 1)) and
               (Trim(Cells[1, FRowBefore]) = '') then begin
                { Empty row, delete }
                for nRow := FRowBefore to RowCount - 2 do begin
                    Cells[0, nRow] := IntToStr(nRow);
                    Cells[1, nRow] := Cells[1, nRow + 1];
                    Cells[2, nRow] := Cells[2, nRow + 1];
                    Cells[3, nRow] := Cells[3, nRow + 1];
                end;
                RowCount := RowCount - 1;
                if Key = VK_DOWN then begin
                    Key      := 0;
                    FDeleteFlag := TRUE;
                end;
            end;
        end;
    end;

    if (Shift = []) and (Key in [VK_LEFT, VK_RIGHT, VK_DOWN, VK_UP, VK_PRIOR, VK_NEXT]) then begin
        with LayoutStringGrid do begin
//            if FColBefore = 2 then begin
                 FInvalidCell := not CheckValidFieldType(FRowBefore);
                 if FInvalidCell then begin
                     Key := 0;
                     Exit;
                 end;
//            end;
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TLayoutEditForm.LayoutStringGridKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
    FKeyMove  := FALSE;
    FRowAfter := LayoutStringGrid.Row;
    FColAfter := LayoutStringGrid.Col;
    if FDeleteFlag then begin
        LayoutStringGrid.Row := FRowBefore;
        Exit;
    end;

    if FInvalidCell then
        Exit;

    if Key = VK_DOWN then begin
        with LayoutStringGrid do begin
            if FRowAfter = FRowBefore then begin
                if CheckValidFieldType(FRowBefore) and
                   (Trim(Cells[1, RowCount - 1]) > '') then begin
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
    else if (Key = VK_UP) and (FRowAfter <> FRowBefore) then begin
        with LayoutStringGrid do begin
            if Trim(Cells[1, RowCount - 1]) = '' then
                RowCount := RowCount - 1;
        end;
        Key := 0;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TLayoutEditForm.LayoutStringGridKeyPress(
    Sender  : TObject;
{$IFDEF VER150}
    var Key : AnsiChar);
{$ELSE}
    var Key : Char);
{$ENDIF}
var
    Rect    : TRect;
    FldType : TFieldType;
begin
    if Key = Char(Ord('N') - Ord('@')) then begin
        { Insert a new line }
        InsertLine;
        Key := #0;
    end
    else if (Key = #9) and (LayoutStringGrid.Col <> 2) then begin
        FldType := StringToFieldType(LayoutStringGrid.Cells[2, FRowBefore]);
        if FldType = ftUnknown then begin
            MessageBeep(MB_OK);
            LayoutStringGrid.Col := 2;
            Key := #0;
        end
        else
            LayoutStringGrid.Cells[2, FRowBefore] := FieldTypeToString(FldType);
    end
    else if (Key = ' ') and (LayoutStringGrid.Col = 2) then begin
        Rect := LayoutStringGrid.CellRect(2, LayoutStringGrid.Row);
        PopupMenu1.Popup(Left + LayoutStringGrid.Left +
                         GetSystemMetrics(SM_CYBORDER) + Rect.Left,
                         Top + LayoutStringGrid.Top + Rect.Top + 4 +
                         GetSystemMetrics(SM_CYCAPTION) +
                         GetSystemMetrics(SM_CYBORDER) +
                         LayoutStringGrid.DefaultRowHeight);
        Key :=#0;
    end
    else if LayoutStringGrid.Col = 3 then begin
        { Do not accept invalid field size }
        Key := UpperCase(Key)[1];
        if not (Key in [#9, #8, '0'..'9']) then begin
            MessageBeep(MB_OK);
            Key := #0;
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TLayoutEditForm.DeleteLine;
var
    nRow : Integer;
begin
    with LayoutStringGrid do begin
        if RowCount = 2 then begin
            Cells[1, Row] := '';
            Cells[2, Row] := '';
            Cells[3, Row] := '';
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
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TLayoutEditForm.InsertLine;
var
    nRow : Integer;
begin
    with LayoutStringGrid do begin
        if CheckValidFieldType(Row) and
           (Trim(Cells[1, Row]) > '') then begin
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
procedure TLayoutEditForm.LineUp;
var
    Buf : String;
    nCol : Integer;
begin
    with LayoutStringGrid do begin
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
procedure TLayoutEditForm.LineDown;
var
    Buf : String;
    nCol : Integer;
begin
    with LayoutStringGrid do begin
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
procedure TLayoutEditForm.DelBitBtnClick(Sender: TObject);
begin
    DeleteLine;
    ActiveControl := LayoutStringGrid;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TLayoutEditForm.AddBitBtnClick(Sender: TObject);
begin
    InsertLine;
    ActiveControl := LayoutStringGrid;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TLayoutEditForm.UpBitBtnClick(Sender: TObject);
begin
    LineUp;
    ActiveControl := LayoutStringGrid;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TLayoutEditForm.DownBitBtnClick(Sender: TObject);
begin
    LineDown;
    ActiveControl := LayoutStringGrid;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TLayoutEditForm.GetLayoutText : String;
var
    nRow    : Integer;
    FldName : String;
begin
    Result := '';
    with LayoutStringGrid do begin
        for nRow := 1 to RowCount - 1 do begin
            FldName := Trim(Cells[1, nRow]);
            if FldName > '' then begin
                if Result > '' then
                    Result := Result + ';';
                Result := Result + Cells[1, nRow] + ';' +
                          Cells[2, nRow] + ';' +
                          IntToStr(atoi(Cells[3, nRow]));
            end;
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function FieldTypeToString(FldType : TFieldType) : String;
var
    I :Integer;
begin
     for I := Low(FieldTypesOrdinals) to High(FieldTypesOrdinals) do begin
         if FieldTypesOrdinals[I] = FldType then begin
              Result := FieldTypesNames[I];
              Exit;
         end;
     end;
     Result := '';
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TLayoutEditForm.SetLayoutText(newValue : String);
var
    FieldData : TList;
    FldNo     : Integer;
    pData     : PFieldData;
begin
    FieldData := TList.Create;
    try
        DecodeLayout(newValue, FieldData);
        for FldNo := 1 to FieldData.Count do begin
            pData := PFieldData(FieldData.Items[FldNo - 1]);
            with LayoutStringGrid do begin
                if RowCount <= FldNo then begin
                    RowCount := RowCount + 1;
                    Cells[0, FldNo] := IntToStr(FldNo);
                end;
                Cells[1, FldNo] := pData.FldName;
                Cells[2, FldNo] := FieldTypeToString(pData.FldType);
                Cells[3, FldNo] := IntToStr(pData.FldLen);
            end;
        end;
    finally
        ClearFieldData(FieldData);
        FieldData.FRee;
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
procedure TLayoutEditForm.ImportButtonClick(Sender: TObject);
var
    Form : TImportForm;
    Fld  : Integer;
    nRow : Integer;
begin
    Form := TImportForm.Create(nil);
    try
        Form.IniFileName := FIniFileName;
        if Form.ShowModal <> mrOk then
            Exit;
        if Form.Count <= 0 then
            Exit;
        if Trim(LayoutStringGrid.Cells[1, 1]) = '' then begin
            nRow := 1;
            LayoutStringGrid.RowCount := Form.Count + 1;
        end
        else begin
            nRow := LayoutStringGrid.RowCount;
            LayoutStringGrid.RowCount := LayoutStringGrid.RowCount + Form.Count;
        end;
        for Fld := 1 to Form.Count do begin
            LayoutStringGrid.Cells[0, nRow] := IntToStr(nRow);
            LayoutStringGrid.Cells[1, nRow] := Form.Names[Fld - 1];
            LayoutStringGrid.Cells[2, nRow] := FieldTypeToString(Form.Types[Fld - 1]);
            LayoutStringGrid.Cells[3, nRow] := IntToStr(Form.Sizes[Fld - 1]);
            Inc(nRow);
        end;
    finally
        Form.Destroy;
        ActiveControl := LayoutStringGrid;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure Register;
begin
    RegisterPropertyEditor(TypeInfo(TFieldLayout), TMWDataSet,
                           'FieldLayout', TLayoutProperty);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TLayoutEditForm.LayoutStringGridExit(Sender: TObject);
begin
    if (LayoutStringGrid.Col = 2) and
       (StringToFieldType(LayoutStringGrid.Cells[2, LayoutStringGrid.Row]) = ftUnknown) then begin
       MessageBeep(MB_OK);
       ActiveControl := LayoutStringGrid;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TLayoutEditForm.CheckValidFieldType(nRow : Integer) : Boolean;
var
    FldType: TFieldType;
begin
    with LayoutStringGrid do begin
         FldType := StringToFieldType(Cells[2, nRow]);
         Result  := (FldType <> ftUnknown);
         if Result then
             Cells[2, nRow] := FieldTypeToString(FldType)
         else
             MessageBeep(MB_OK);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TLayoutEditForm.CheckValid : Boolean;
var
    FldType : TFieldType;
    nRow    : Integer;
begin
    for nRow := 1 to LayoutStringGrid.RowCount - 1 do begin
        FldType := StringToFieldType(LayoutStringGrid.Cells[2, nRow]);
        if FldType = ftUnknown then begin
            MessageBeep(MB_OK);
            LayoutStringGrid.Col := 2;
            LayoutStringGrid.Row := nRow;
            ActiveControl        := LayoutStringGrid;
            Result               := FALSE;
            Exit;
        end
        else
            LayoutStringGrid.Cells[2, nRow] := FieldTypeToString(FldType);
    end;
    Result := TRUE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TLayoutEditForm.Currency1Click(Sender: TObject);
begin
    LayoutStringGrid.Cells[2, LayoutStringGrid.Row] :=
        FieldTypeToString(ftCurrency);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TLayoutEditForm.Memo1Click(Sender: TObject);
begin
    LayoutStringGrid.Cells[2, LayoutStringGrid.Row] :=
        FieldTypeToString(ftMemo);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TLayoutEditForm.Date1Click(Sender: TObject);
begin
    LayoutStringGrid.Cells[2, LayoutStringGrid.Row] :=
        FieldTypeToString(ftDate);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TLayoutEditForm.Time1Click(Sender: TObject);
begin
    LayoutStringGrid.Cells[2, LayoutStringGrid.Row] :=
        FieldTypeToString(ftTime);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

end.

