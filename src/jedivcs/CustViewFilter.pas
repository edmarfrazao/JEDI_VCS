(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: CustViewFilter.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS: Thomas Huber (Thomas_D_Huber@gmx.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FreeVCS code to JEDI VCS
2003/03/04  THensle   - changes for "ConfigStorage" unit
2003/12/28  USchuster - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use constant)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/31  USchuster - style cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/11/05  USchuster - moved resourcestrings to JVCSGUIClientResources.pas                      
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 final released ^^^^^^^^^^^^^^^^^^^^^^^^^^
2006/04/30  THuber    #3611 config folder now windows user dependend (appdata shell folder)
2007/06/30  USchuster - changes for large fonts (contraints and default size depend now on PixelsPerInch; analog to Mantis #3710)
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit CustViewFilter;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, ExtCtrls, Menus, ImgList, Buttons, JVCSForms;

type
  TVCSCustomViewFilter = class(TJVCSForm)
    Panel1: TPanel;
    btnCancel: TButton;
    btnOK: TButton;
    btnRemove: TButton;
    lvFilter: TListView;
    PopupMenu1: TPopupMenu;
    Remove1: TMenuItem;
    SysImageList: TImageList;
    StateImageList: TImageList;
    Help: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnOKClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure lvFilterResize(Sender: TObject);
    procedure lvFilterChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure HelpClick(Sender: TObject);
  private
    { Private declarations }
    FCreating: Boolean;
  public
    { Public declarations }
    FilterChanged: Boolean;
  end;

var
  VCSCustomViewFilter: TVCSCustomViewFilter;

implementation

uses
  {$IFDEF DEBUG}
  JclDebug,
  {$ENDIF DEBUG}
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  ShellAPI, VCSBase, VCSProcBase, ConfigStorage, JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSCustomViewFilter.FormCreate(Sender: TObject);
var
  sfi: TSHFileInfo;
  DlgWidth, DlgHeight: Integer;
begin
  try
    Constraints.MinHeight := MulDiv(250, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(360, PixelsPerInch, 96);
    FCreating := True;
    FilterChanged := False;
    //Systemsymbole in eine TImageList-Komponente einlesen
    SysImageList.Handle := SHGetFileInfo('', 0, sfi, SizeOf(TSHFileInfo),
      SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
    SysImageList.ShareImages := True;

    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    if not jvcsReadWindowSize(sBaseRegistryKey + crbWindows, 'CustomViewFilter',
      DlgWidth, DlgHeight) then
    begin
      DlgWidth := MulDiv(310, PixelsPerInch, 96);
      DlgHeight := MulDiv(300, PixelsPerInch, 96);
    end;
    Width := DlgWidth;
    Height := DlgHeight;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSCustomViewFilter.FormActivate(Sender: TObject);
var
  I: Integer;
  CustFiltItems: TStringList;
  CustFiltFile: string;
  LVItem: TListItem;
  sfi: TSHFileInfo;
  FExists: Boolean;
begin
  Application.ProcessMessages;
  if not FCreating then
    Exit;
  FCreating := False;
  CustFiltItems := TStringList.Create;
  try
    CustFiltFile := sConfigFolder + ChangeFileExt(ExtractFileName(sProjectName), '.pcf');
    if FileExists(CustFiltFile) then
    begin
      try
        CustFiltItems.LoadFromFile(CustFiltFile);
      except
        on E: 
        Exception do 
        begin
          CustFiltItems.Clear;
          BeepIfSet;
          MessageBox(Handle, PChar(Format(JVCSRES_Reading_file_6037s62 + #13#10 +
            JVCSRES_raised_exception58 + #13#10 + '%s.', [CustFiltFile, E.Message])),
            cMsgBoxCaption, MB_OK or MB_ICONSTOP);
        end;
      end;
    end; // if FileExists(CustFiltFile) then begin
    for I := 0 to CustFiltItems.Count - 1 do 
    begin
      LVItem := lvFilter.Items.Add;
      LVItem.Caption := CustFiltItems.Strings[I];
      FExists := FileExists(CustFiltItems.Strings[I]);
      if FExists then 
      begin
        SHGetFileInfo(PChar(CustFiltItems.Strings[I]), 0, sfi, SizeOf(sfi),
          SHGFI_SYSICONINDEX or SHGFI_SMALLICON or SHGFI_DISPLAYNAME);
        LVItem.ImageIndex := sfi.IIcon;
        LVItem.StateIndex := -1;
      end 
      else 
      begin
        LVItem.ImageIndex := -1;
        LVItem.StateIndex := 0;
      end;
    end;
    Caption := Format(JVCSRES_Custom_view_filter_45_37s_45_37d_items,
      [AnsiLowerCase(ExtractFileName(sProjectName)), CustFiltItems.Count]);
  finally
    CustFiltItems.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSCustomViewFilter.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  jvcsWriteWindowSize(sBaseRegistryKey + crbWindows, 'CustomViewFilter',
    Width, Height);
end;

//------------------------------------------------------------------------------

procedure TVCSCustomViewFilter.btnOKClick(Sender: TObject);
var
  I: Integer;
  CustFiltItems: TStringList;
  CustFiltFile: string;
begin
  CustFiltItems := TStringList.Create;
  try
    for I := 0 to lvFilter.Items.Count - 1 do
      CustFiltItems.Add(lvFilter.Items[I].Caption);

    CustFiltFile := sConfigFolder + ChangeFileExt(ExtractFileName(sProjectName), '.pcf');
    try
      CustFiltItems.SaveToFile(CustFiltFile);
    except
      BeepIfSet;
      MessageBox(WindowHandle, PChar(Format(JVCSRES_JEDI_VCS_cannot_save_the_file + #13#10 +
        '<%s>.' + #13#10 +
        JVCSRES_Be_sure_that_the_file_is_not_opened_by_another_application44 + #13#10 +
        JVCSRES_that_there_is_enough_free_space_on_the_disk + #13#10 +
        JVCSRES_and_that_you_have_the_required_access_rights46, [CustFiltFile])),
        cMsgBoxCaption, MB_OK or MB_ICONSTOP);
    end;
  finally
    CustFiltItems.Free;
  end;
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSCustomViewFilter.btnRemoveClick(Sender: TObject);
var
  I: Integer;
begin
  if lvFilter.Selected = nil then
    Exit;
  I := 0;
  with lvFilter do
  begin
    while I <= Items.Count - 1 do
    begin
      if Items[I].Selected then
        Items[I].Delete
      else
        Inc(I);
    end; // while I <= lvFilter.Items.Count - 1 do begin
  end; // with lvToDo do begin
  Caption := Format(JVCSRES_Custom_view_filter_45_37s_45_37d_items,
    [ExtractFileName(sProjectName), lvFilter.Items.Count]);
  FilterChanged := True;
end;

//------------------------------------------------------------------------------

procedure TVCSCustomViewFilter.btnCancelClick(Sender: TObject);
begin
  FilterChanged := False;
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSCustomViewFilter.lvFilterResize(Sender: TObject);
begin
  lvFilter.Columns[0].Width := lvFilter.Width - 25;
end;

//------------------------------------------------------------------------------

procedure TVCSCustomViewFilter.lvFilterChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
begin
  btnRemove.Enabled := lvFilter.SelCount > 0;
  Remove1.Enabled := btnRemove.Enabled;
end;

//------------------------------------------------------------------------------

procedure TVCSCustomViewFilter.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Custom_view_filter);
  if Key = VK_ESCAPE then 
  begin
    btnCancel.Click;
    Key := 0;
  end;    
end;

//------------------------------------------------------------------------------

procedure TVCSCustomViewFilter.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

end.
