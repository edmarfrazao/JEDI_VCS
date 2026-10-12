{*_* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Author:       François PIETTE
Description:  Import form for property editor for component TMWTable
Creation:     June 06, 1998
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
Jun 20, 1998  V1.01 Added field type support
Jul 16, 1998  V1.02 Save DatabaseName and TableName in ini file between sessions
Aug 27, 2004  V1.03 Use IcsDefs.inc, revise compiler options
              Removed unused units.


 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit LOPropIm;

{$ifdef FPC}
  {$MODE DELPHI}
{$endif}

{$B-}             { Enable partial boolean evaluation   }
{$T-}             { Untyped pointers                    }
{$X+}             { Enable extended syntax              }
{$H+}             { Use long strings                    }
{$J+}             { Allow typed constant to be modified }
{$I ICSDEFS.INC}
{$IFDEF DELPHI6_UP}
    {$WARN SYMBOL_PLATFORM   OFF}
    {$WARN SYMBOL_LIBRARY    OFF}
    {$WARN SYMBOL_DEPRECATED OFF}
{$ENDIF}
{$IFDEF BCB3_UP}
    {$ObjExportAll On}
{$ENDIF}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, Grids, ExtCtrls, Db, DBTables, IniFiles;

const
  LOPropImVersion = 103;
  CopyRight : String = ' TRequestParams (c) 1998-2006 F. Piette V1.03 ';

type
  TImportForm = class(TForm)
    Table1: TTable;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    DatabaseEdit: TEdit;
    TableEdit: TEdit;
    FieldsStringGrid: TStringGrid;
    ImportButton: TButton;
    OkButton: TButton;
    CancelButton: TButton;
    Label3: TLabel;
    AllButton: TButton;
    ClearButton: TButton;
    procedure ImportButtonClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FieldsStringGridDblClick(Sender: TObject);
    procedure FieldsStringGridMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure OkButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
{$IFDEF VER150}
    procedure FieldsStringGridKeyPress(Sender: TObject; var Key: AnsiChar);
{$ELSE}
    procedure FieldsStringGridKeyPress(Sender: TObject; var Key: Char);
{$ENDIF}
    procedure ClearButtonClick(Sender: TObject);
    procedure AllButtonClick(Sender: TObject);
  private
    FIniFileName : String;
    FMouseX      : Integer;
    FMouseY      : Integer;
    FCount       : Integer;
    function  GetNames(nIndex : Integer) : String;
    function  GetSizes(nIndex : Integer) : Integer;
    function  GetTypes(nIndex : Integer) : TFieldType;
    procedure SelectRow(ARow : Integer);
  public
    property IniFileName : String                 read  FIniFileName
                                                  write FIniFileName;
    property Count : Integer                      read  FCount;
    property Names[nIndex : Integer] : String     read  GetNames;
    property Sizes[nIndex : Integer] : Integer    read  GetSizes;
    property Types[nIndex : Integer] : TFieldType read  GetTypes;
  end;

var
  ImportForm: TImportForm;

implementation

uses
    MwDatSet, LOProp;

{$R *.DFM}
const
    SectionWindow       = 'WindowImport';
    KeyTop              = 'Top';
    KeyLeft             = 'Left';
    KeyWidth            = 'Width';
    KeyHeight           = 'Height';
    KeyDataBase         = 'DatabaseName';
    KeyTable            = 'TableName';


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TImportForm.FormShow(Sender: TObject);
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
        { Get last edit content }
        DatabaseEdit.Text := IniFile.ReadString(SectionWindow, KeyDatabase, '');
        TableEdit.Text    := IniFile.ReadString(SectionWindow, KeyTable,    '');
        IniFile.Free;
    end
    else begin
        { No inifile specified, center form on screen }
        Top  := (Screen.Height - Height) div 2;
        Left := (Screen.Width - Width) div 2;
    end;
    with FieldsStringGrid do begin
        Cells[1, 0] := 'NAME';
        Cells[2, 0] := 'TYPE';
        Cells[3, 0] := 'SIZE';
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TImportForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
    IniFile : TIniFile;
begin
    if FIniFileName > '' then begin
        IniFile := TIniFile.Create(FIniFileName);
        IniFile.WriteInteger(SectionWindow, KeyTop,      Top);
        IniFile.WriteInteger(SectionWindow, KeyLeft,     Left);
        IniFile.WriteInteger(SectionWindow, KeyWidth,    Width);
        IniFile.WriteInteger(SectionWindow, KeyHeight,   Height);
        IniFile.WriteString(SectionWindow,  KeyDatabase, DatabaseEdit.Text);
        IniFile.WriteString(SectionWindow,  KeyTable,    TableEdit.Text);
        IniFile.Free;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TImportForm.ImportButtonClick(Sender: TObject);
var
    Fld : Integer;
begin
    Table1.DatabaseName := DatabaseEdit.Text;
    Table1.TableName    := TableEdit.text;
    Table1.Open;
    OkButton.Enabled    := FALSE;
    FCount              := 0;
    if Table1.FieldCount <= 0 then begin
        FieldsStringGrid.RowCount      := 2;
        FieldsStringGrid.Cells[0, 1] := '';
        FieldsStringGrid.Cells[1, 1] := '';
        FieldsStringGrid.Cells[2, 1] := '';
        FieldsStringGrid.Cells[3, 1] := '';
        Exit;
    end;
    FieldsStringGrid.RowCount := 1 + Table1.FieldCount;
    for Fld := 1 to Table1.FieldCount do begin
        FieldsStringGrid.Cells[0, Fld] := '';
        FieldsStringGrid.Cells[1, Fld] := Table1.FieldDefs.Items[Fld - 1].Name;
        FieldsStringGrid.Cells[2, Fld] := FieldTypeToString(Table1.FieldDefs.Items[Fld - 1].DataType);
        FieldsStringGrid.Cells[3, Fld] := IntToStr(Table1.FieldDefs.Items[Fld - 1].Size);
    end;
    Table1.Close;
    AllButton.Enabled   := TRUE;
    ClearButton.Enabled := TRUE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TImportForm.FormResize(Sender: TObject);
begin
    with FieldsStringGrid do begin
        ColWidths[0] := 16;
        ColWidths[2] := 32;
        ColWidths[3] := 48;
        ColWidths[1] := Width - ColWidths[0] - ColWidths[2] - ColWidths[3] - 8;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TImportForm.SelectRow(ARow : Integer);
begin
    if FieldsStringGrid.Cells[0, ARow] = 'X' then begin
        FieldsStringGrid.Cells[0, ARow] := '';
        Dec(FCount);
    end
    else begin
        FieldsStringGrid.Cells[0, ARow] := 'X';
        Inc(FCount);
    end;
    OkButton.Enabled := (FCount > 0);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TImportForm.FieldsStringGridDblClick(Sender: TObject);
var
    ACol, ARow : LongInt;
begin
    FieldsStringGrid.MouseToCell(FMouseX, FMouseY, ACol, ARow);
    if ARow < 1 then
        Exit;
    SelectRow(ARow);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TImportForm.FieldsStringGridKeyPress(
    Sender: TObject;
  {$IFDEF VER150}
    var Key: AnsiChar);
  {$ELSE}
    var Key: Char);
  {$ENDIF}
begin
    if Key <> ' ' then
        Exit;
    SelectRow(FieldsStringGrid.Row);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TImportForm.FieldsStringGridMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
    FMouseX := X;
    FMouseY := Y;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TImportForm.GetNames(nIndex : Integer) : String;
var
    nRow : Integer;
begin
    if (nIndex < 0) or (nIndex >= FieldsStringGrid.RowCount) then
        raise Exception.Create('GetNames: Invalid index');
        
    nRow := 0;
    while nIndex >= 0 do begin
        inc(nRow);
        if  FieldsStringGrid.Cells[0, nRow] = 'X' then
             Dec(nIndex);
    end;

    Result := FieldsStringGrid.Cells[1, nRow];
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TImportForm.GetSizes(nIndex : Integer) : Integer;
begin
    if (nIndex < 0) or (nIndex >= FieldsStringGrid.RowCount) then
        raise Exception.Create('GetSizes: Invalid index');
    Result := StrToInt(FieldsStringGrid.Cells[3, nIndex + 1]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TImportForm.GetTypes(nIndex : Integer) : TFieldType;
begin
    if (nIndex < 0) or (nIndex >= FieldsStringGrid.RowCount) then
        raise Exception.Create('GetTypes: Invalid index');
    Result := StringToFieldType(FieldsStringGrid.Cells[2, nIndex + 1]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TImportForm.OkButtonClick(Sender: TObject);
begin
    ModalResult := mrOk;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TImportForm.CancelButtonClick(Sender: TObject);
begin
    ModalResult := mrCancel;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TImportForm.ClearButtonClick(Sender: TObject);
var
    nRow : Integer;
begin
    FCount := 0;
    for nRow := 1 to FieldsStringGrid.RowCount - 1 do
        FieldsStringGrid.Cells[0, nRow] := '';
    OkButton.Enabled := FALSE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TImportForm.AllButtonClick(Sender: TObject);
var
    nRow : Integer;
begin
    FCount := 0;
    for nRow := 1 to FieldsStringGrid.RowCount - 1 do begin
        FieldsStringGrid.Cells[0, nRow] := 'X';
        Inc(FCount);
    end;
    OkButton.Enabled := TRUE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

end.


