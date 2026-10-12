(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: WCViewFilter.pas

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
2003/03/06  THensle   - changes for "ConfigStorage" unit
2003/03/09  USchuster - exchanged TjvMruList with TJVCSMruList (mantis #727)
                      - disabled the AutoSave property in rcbxWildcards
                        and removed the regkeys (they where wrong and
                        loading and saving is no done with MruListWildcards)
                      - removed rcbxWildcards.AutoSave.SaveValue
2004/02/24  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2004/04/12  USchuster - AutoComplete in ComboBox now False
                      - minor style cleaning (casing and comments)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/05  USchuster - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/10/31  USchuster - moved resourcestrings to JVCSGUIClientResources.pas                      
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2009/12/28  THuber    - added JVCSClientConsts to uses (as some consts were moved from VCSBase there)
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit WCViewFilter;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Buttons, JvCombobox, JVCSMruList, JvExStdCtrls, JVCSForms;

type
  TVCSWCViewFilter = class(TJVCSForm)
    PageControl1: TPageControl;
    SheetWC: TTabSheet;
    SheetStatus: TTabSheet;
    btnClose: TButton;
    btnApply: TButton;
    Label1: TLabel;
    btnClear: TButton;
    Label3: TLabel;
    cbBugFilter: TComboBox;
    rbUseCustom: TRadioButton;
    rbUseDefined: TRadioButton;
    cbxFileFilters: TComboBox;
    spBtnSetFilter: TSpeedButton;
    Label2: TLabel;
    rcbxWildcards: TJvComboBox;
    procedure btnApplyClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure cbxFileFiltersChange(Sender: TObject);
    procedure spBtnSetFilterClick(Sender: TObject);
    procedure rbUseCustomClick(Sender: TObject);
  private
    { Private declarations }
    Filters: TStringList;
    MruListWildcards: TJVCSMruList;
    procedure GetFileFilters;
  public
    { Public declarations }
    WildCards: string;
    BugSeverity: Integer;
  end;

var
  VCSWCViewFilter: TVCSWCViewFilter;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSBase, VCSProcBase, JVCSClientConsts, Options, ConfigStorage, JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSWCViewFilter.FormCreate(Sender: TObject);
begin
  try
    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    WildCards := '';
    MruListWildcards := TJVCSMruList.CreateEx(sBaseRegistryKey + crbMRU + '12');
    rcbxWildcards.Items.Assign(MruListWildcards);

    PageControl1.ActivePage := SheetWC;
    Filters := TStringList.Create;
    GetFileFilters;
    rbUseCustomClick(Self);
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSWCViewFilter.FormActivate(Sender: TObject);
begin
  rcbxWildcards.SetFocus;
  if WildCards <> '' then
  begin
    if rcbxWildcards.Items.IndexOf(WildCards) <> -1 then
      rcbxWildcards.ItemIndex := rcbxWildcards.Items.IndexOf(WildCards);
  end;
  if BugSeverity > -1 then
    cbBugFilter.ItemIndex := BugSeverity + 1
  else
    cbBugFilter.ItemIndex := 0;
end;

//------------------------------------------------------------------------------

procedure TVCSWCViewFilter.FormDestroy(Sender: TObject);
begin
  Filters.Free;
  MruListWildcards.Free;
end;

//------------------------------------------------------------------------------

procedure TVCSWCViewFilter.btnApplyClick(Sender: TObject);
begin
  if rbUseCustom.Checked then
  begin
    WildCards := AnsiLowerCase(rcbxWildcards.Text);
    {  --hu
    rcbxWildcards.AddMRUString(rcbxWildcards.Text);
    rcbxWildcards.MRUSaveToReg;
     }
    MruListWildcards.AddString(rcbxWildcards.Text);
  end
  else
    WildCards := Filters.Values[cbxFileFilters.Text];

  if cbBugFilter.ItemIndex > 0 then
    BugSeverity := cbBugFilter.ItemIndex - 1
  else
    BugSeverity := -1;
  ModalResult := mrOk;
end;

//------------------------------------------------------------------------------

procedure TVCSWCViewFilter.btnCloseClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

//------------------------------------------------------------------------------

procedure TVCSWCViewFilter.btnClearClick(Sender: TObject);
begin
  WildCards := '';
  BugSeverity := -1;
  ModalResult := mrOk;
end;

//------------------------------------------------------------------------------

procedure TVCSWCViewFilter.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Wildcard_view_filter);
  if Key = VK_ESCAPE then
  begin
    btnClose.Click;
    Key := 0;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSWCViewFilter.GetFileFilters;
var
  Filter1, Filter2, CustomFilter, CurrentFilterName: string;
  I: Integer;
begin
  Filters.Clear;
  cbxFileFilters.Items.Clear;

  Filter1 :=
    jvcsReadString(sBaseRegistryKey + crbFilters, 'Delphi files', dfDelphiMod);
  Filter2 :=
    jvcsReadString(sBaseRegistryKey + crbFilters, 'AddProjectFiles', dfAddMod);

  CurrentFilterName := Format(JVCSRES_37s_source_files_4037s41, [sIDEName, Filter1]);
  cbxFileFilters.Items.Add(CurrentFilterName);
  Filters.Add(CurrentFilterName + '=' + Filter1);
  CurrentFilterName := Format(JVCSRES_Other_source_files_4037s41, [Filter2]); 
  cbxFileFilters.Items.Add(CurrentFilterName);
  Filters.Add(CurrentFilterName + '=' + Filter2);
  I := 0;
  repeat
    Inc(I);
    CustomFilter :=
      jvcsReadString(sBaseRegistryKey + crbFilters + '\Custom',
      'Custom' + IntToStr(I), '');
    if (CustomFilter <> '') then
    begin
      CurrentFilterName := Copy(CustomFilter, 1, Pos('|', CustomFilter) - 1);
      System.Delete(CustomFilter, 1, Pos('|', CustomFilter));
      cbxFileFilters.Items.Add(CurrentFilterName + ' (' + CustomFilter + ')');
      Filters.Add(CurrentFilterName + ' (' + CustomFilter + ')=' + CustomFilter);
    end;
  until (CustomFilter = '');
  cbxFileFilters.ItemIndex := 0;
  cbxFileFilters.Hint := cbxFileFilters.Text;
end;

//------------------------------------------------------------------------------

procedure TVCSWCViewFilter.cbxFileFiltersChange(Sender: TObject);
begin
  cbxFileFilters.Hint := cbxFileFilters.Text;
end;

//------------------------------------------------------------------------------

procedure TVCSWCViewFilter.spBtnSetFilterClick(Sender: TObject);
begin
  VCSOptions := TVCSOptions.Create(Application);
  try
    VCSOptions.DefaultSheet := cspFilter;
    VCSOptions.ShowModal;
  finally
    VCSOptions.Free;
  end;
  GetFileFilters;
end;

//------------------------------------------------------------------------------

procedure TVCSWCViewFilter.rbUseCustomClick(Sender: TObject);
begin
  rcbxWildcards.Enabled := rbUseCustom.Checked;
  cbxFileFilters.Enabled := not rcbxWildcards.Enabled;
  spBtnSetFilter.Enabled := not rcbxWildcards.Enabled;
end;

end.
