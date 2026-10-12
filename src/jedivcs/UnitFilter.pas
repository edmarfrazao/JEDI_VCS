(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: UnitFilter.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS: Thomas Huber (Thomas_D_Huber@t-online.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FreeVCS code to JEDI VCS
2003/03/09  THensle   - changes for "ConfigStorage" unit
2003/12/28  USchuster - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use constant)
2004/02/24  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/03/14  USchuster - 'vcllist.fvc' -> cDelphiVCLComponentListFile
                        'vcllistbcb.fvc' -> cBCBVCLComponentListFile
                        'ulist.fvc' -> cParserUnitSkipListFile
                      - minor style cleaning (casing and comments)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/08  USchuster - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/11/02  USchuster - moved resourcestrings to JVCSGUIClientResources.pas                      
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC3 released ^^^^^^^^^^^^^^^^^^^^^^^^^^^
2006/01/21  THuber    - warnings removed
2007/04/14  USchuster - removed fixed background color of the list box (mantis #4102)
2008/06/22  USchuster - changes for usage in Standalone client (Mantis #4380)
2011/01/15  USchuster - changed font to Tahoma 

-----------------------------------------------------------------------------*)

unit UnitFilter;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Menus, JvExStdCtrls, JvTextListBox;

type
  TVCSUnitFilter = class(TForm)
    lblInfo: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    PopupMenu1: TPopupMenu;
    Remove1: TMenuItem;
    GroupBox1: TGroupBox;
    edSearch: TEdit;
    btnAdd: TButton;
    Label1: TLabel;
    Label2: TLabel;
    lblItems: TLabel;
    extlbItems: TJvTextListBox;
    N1: TMenuItem;
    linedelimiter1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edSearchChange(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure Remove1Click(Sender: TObject);
    procedure extlbItemsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure linedelimiter1Click(Sender: TObject);
  private
    { Private-Deklarationen }
    FilterType: Integer;
    FCreating: Boolean;
  public
    { Public-Deklarationen }
    procedure SetFilterType(const Value: Integer);
  end;

var
  VCSUnitFilter: TVCSUnitFilter;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSBase, VCSProcBase, ConfigStorage, JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSUnitFilter.SetFilterType(const Value: Integer);
begin
  if (Value = 0) or (Value = 1) then
    FilterType := Value
  else
    FilterType := 0;
end;

//------------------------------------------------------------------------------

procedure TVCSUnitFilter.FormCreate(Sender: TObject);
begin
  try
    btnAdd.Enabled := False;
    FCreating := True;
    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);
    linedelimiter1.Checked :=
      jvcsReadBool(sBaseRegistryKey + crbWindows, 'UCFilterLD', True);
    //hu28.11.2002   if linedelimiter1.Checked then
    //hu28.11.2002     extlbItems.LineColorOdd := clBtnFace
    //hu28.11.2002   else
    //hu28.11.2002     extlbItems.LineColorOdd := clWindow;

    Screen.Cursors[cPopUpMCursor] := LoadCursor(hInstance, PChar('CURSORRM'));
    extlbItems.Cursor := cPopUpMCursor;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSUnitFilter.FormActivate(Sender: TObject);
var
  Filters: TStringList;
  I: Integer;
  FilterFN: string;
begin
  if FCreating then
  begin
    Screen.Cursor := crHourGlass;
    try
      Application.ProcessMessages;
      FCreating := False;
      Filters := TStringList.Create;
      try
        Filters.Sorted := True;
        Filters.Duplicates := dupIgnore;

        {$IFDEF IDEDLL}
        if FilterType = 0 then
        begin // Componentenfilter
          if bIsCppBuilder then
            FilterFN := sDLLDirectory + cBCBVCLComponentListFile
          else
            FilterFN := sDLLDirectory + cDelphiVCLComponentListFile;
          Caption := JVCSRES_Component_Filter;
          lblInfo.Caption := JVCSRES_Ignore_these_Components58;
        end
        else
        {$ENDIF IDEDLL}
        begin // Unitfilter
          FilterFN := sDLLDirectory + cParserUnitSkipListFile;
          Caption := JVCSRES_Module_Filter;
          lblInfo.Caption := JVCSRES_Ignore_these_modules58;
        end;

        if FileExists(FilterFN) then
        begin
          try
            Filters.LoadFromFile(FilterFN);
          except
            on E :
            Exception do
            begin
              Filters.Clear;
              BeepIfSet;

              MessageBox(Handle, PChar(Format(JVCSRES_Reading_file_6037s62 + #13#10 +
                JVCSRES_raised_exception58 + #13#10 + '%s.', [FilterFN, E.Message])),
                cMsgBoxCaption, MB_OK or MB_ICONSTOP);
            end;
          end;
        end;
        for I := 0 to Filters.Count - 1 do
          extlbItems.Items.Add(Filters.Strings[I]);
      finally
        Filters.Free;
      end;
      lblItems.Caption := IntToStr(extlbItems.Items.Count);
    finally
      Screen.Cursor := crDefault;
    end;
  end; // if FCreating then begin
end;

//------------------------------------------------------------------------------

procedure TVCSUnitFilter.btnOKClick(Sender: TObject);
var
  Filters: TStringList;
  I: Integer;
  FilterFN, Mess: string;
begin
  Filters := TStringList.Create;
  try
    {$IFDEF IDEDLL}
    if FilterType = 0 then
    begin // Componentenfilter
      if bIsCppBuilder then
        FilterFN := sDLLDirectory + cBCBVCLComponentListFile
      else
        FilterFN := sDLLDirectory + cDelphiVCLComponentListFile;
    end
    else
    {$ENDIF IDEDLL}
    begin // Unitfilter
      FilterFN := sDLLDirectory + cParserUnitSkipListFile;
    end;

    for I := 0 to extlbItems.Items.Count - 1 do
      Filters.Add(extlbItems.Items[I]);
    try
      Filters.SaveToFile(FilterFN);
    except
      // Error while trying to save the file <%s>!
      Mess := Format(JVCSRES_JEDI_VCS_cannot_save_the_file + #13#10 + '<%s>.' + #13#10 +
        JVCSRES_Be_sure_that_the_file_is_not_opened_by_another_application44 + #13#10 +
        JVCSRES_that_there_is_enough_free_space_on_the_disk + #13#10 +
        JVCSRES_and_that_you_have_the_required_access_rights46, [FilterFN]);
      MessageBox(Handle, PChar(Mess), cMsgBoxCaption, MB_OK or MB_ICONSTOP);
    end;
  finally
    Filters.Free;
  end;
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSUnitFilter.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    btnCancel.Click;
    Key := 0;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSUnitFilter.edSearchChange(Sender: TObject);
var
  I: Integer;
begin
  btnAdd.Enabled := edSearch.Text <> '';
  with extlbItems do
  begin
    for I := 0 to Items.Count - 1 do
    begin
      if AnsiLowerCase(edSearch.Text) =
        AnsiLowerCase(Copy(Items[I], 1, Length(edSearch.Text))) then
      begin
        TopIndex := I;
        Break;
      end;
    end; // for I := 0 to Items.Count - 1 do begin
  end; // with lbItems do begin
end;

//------------------------------------------------------------------------------

procedure TVCSUnitFilter.btnAddClick(Sender: TObject);
begin
  with extlbItems do
  begin
    Items.Add(edSearch.Text);
    ItemIndex := Items.Count - 1;
    TopIndex := ItemIndex;
    lblItems.Caption := IntToStr(Items.Count);
  end; // with lbItems do begin
end;

//------------------------------------------------------------------------------

procedure TVCSUnitFilter.Remove1Click(Sender: TObject);
begin
  with extlbItems do
    if ItemIndex <> -1 then
    begin
      Items.Delete(ItemIndex);
      lblItems.Caption := IntToStr(Items.Count);
    end;
end;

//------------------------------------------------------------------------------

procedure TVCSUnitFilter.extlbItemsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  ItemPos: TPoint;
  SelItem: Integer;
begin
  if Button = mbRight then
  begin
    ItemPos.X := X;
    ItemPos.Y := Y;
    SelItem := extlbItems.ItemAtPos(ItemPos, True);
    if SelItem <> -1 then
      extlbItems.ItemIndex := SelItem;
  end; // if Button = mbRight then begin
end;

//------------------------------------------------------------------------------

procedure TVCSUnitFilter.linedelimiter1Click(Sender: TObject);
begin
  linedelimiter1.Checked := not linedelimiter1.Checked;
  //hu28.11.2002   if linedelimiter1.Checked then
  //hu28.11.2002     extlbItems.LineColorOdd := clBtnFace
  //hu28.11.2002   else
  //hu28.11.2002     extlbItems.LineColorOdd := clWindow;

  jvcsWriteBool(sBaseRegistryKey + crbWindows, 'UCFilterLD',
    linedelimiter1.Checked);
  extlbItems.RePaint;
end;

end.
