(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSLanguage.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2004/11/14  USchuster - new unit (factored out the language selection from ProjAdmin.pas
                        into a component; is based on Fikret Hasovic's language
                        selection from newideas project but heavily changed)
2005/01/03  USchuster - avoid insertion of break in AddLanguageMenuItem on top menu level
2005/06/04  USchuster - changes in order to store the selected language

-----------------------------------------------------------------------------*)

unit JVCSLanguage;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  SysUtils, Classes, Forms, Menus, JvGnugettext;

const
  DefaultLanguageCode = 'C'; //Dxgettext has no constant for it

type
  TLanguageChangedEvent = procedure(const ALanguageCode: string) of object;

  TCustomLanguageMenuItem = class(TMenuItem)
  private
    FAvailableLanguages: TStringList;
    FComponentsToRetranslate: TList;
    FOnAfterChangedLanguage: TLanguageChangedEvent;
    FOnChangeLanguage: TNotifyEvent;
    FTextDomain: string;
    procedure CreateLanguageMenu(AParentMenuItem: TMenuItem; ADomain: string = DefaultTextDomain);
    procedure DoOnAfterChangedLanguage(const ALanguageCode: string);
    procedure DoOnChangeLanguage;
    procedure LanguageMainMenuItemClick(Sender: TObject);
    procedure LanguageSubMenuItemClick(Sender: TObject);
    procedure SetTextDomain(AValue: string);
  protected
    procedure AddComponentToRetranslate(AComponent: TComponent);
    property OnAfterChangedLanguage: TLanguageChangedEvent read FOnAfterChangedLanguage write FOnAfterChangedLanguage;
    property OnChangeLanguage: TNotifyEvent read FOnChangeLanguage write FOnChangeLanguage;
  public
    constructor Create(AOwner: TComponent); override;
    constructor CreateWithDomain(AOwner: TComponent; ADomain: string = DefaultTextDomain);
    destructor Destroy; override;

    property TextDomain: string read FTextDomain write SetTextDomain;
  end;

  TLanguageMenuItem = class(TCustomLanguageMenuItem)
  private
    procedure RetranslateAllScreenForms(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    property OnAfterChangedLanguage;
  end;

procedure AddLanguageMenuItem(AParentMenuItem: TMenuItem; ADomain: string = DefaultTextDomain;
  AOnAfterChangedLanguage: TLanguageChangedEvent = nil);

implementation

uses
  LanguageCodes;

resourcestring
  JVCSRES_Languages = 'Languages';
  JVCSRES_Default_Language = 'Default Language';

constructor TCustomLanguageMenuItem.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAvailableLanguages := TStringList.Create;
  FComponentsToRetranslate := TList.Create;
  FOnAfterChangedLanguage := nil;
  FOnChangeLanguage := nil;
  FTextDomain := '';
  TextDomain := DefaultTextDomain;
  Caption := JVCSRES_Languages;
  OnClick := LanguageMainMenuItemClick;
end;

constructor TCustomLanguageMenuItem.CreateWithDomain(AOwner: TComponent; ADomain: string = DefaultTextDomain);
begin
  Create(AOwner);
  TextDomain := ADomain;
end;

destructor TCustomLanguageMenuItem.Destroy;
begin
  FAvailableLanguages.Free;
  FComponentsToRetranslate.Free;
  inherited Destroy;
end;

procedure TCustomLanguageMenuItem.AddComponentToRetranslate(AComponent: TComponent);
begin
  //todo - needs an notification handler and freenotification but that
  // doesn't matter it's not used so far
  if FComponentsToRetranslate.IndexOf(AComponent) = -1 then
    FComponentsToRetranslate.Add(AComponent);
end;

//This procedure will dynamically fill a Menu with languages in a specified directory
procedure TCustomLanguageMenuItem.CreateLanguageMenu(AParentMenuItem: TMenuItem;
  ADomain: string = DefaultTextDomain);
var
  LMItem: TMenuItem;
  I: Integer;
begin
  try
    //Clear the menu
    while AParentMenuItem.Count > 0 do
      AParentMenuItem.Delete(0);

    //Create and list languages
    DefaultInstance.GetListOfLanguages(ADomain, FAvailableLanguages);
    FAvailableLanguages.Insert(0, DefaultLanguageCode);

    for I := 0 to Pred(FAvailableLanguages.Count) do
    begin
      LMItem := TMenuItem.Create(AParentMenuItem);
      with LMItem do
      begin
        if FAvailableLanguages[I] = DefaultLanguageCode then
          Caption := JVCSRES_Default_Language
        else
          Caption := GetLanguageName(FAvailableLanguages[I]);
        Tag := I;
        Visible := True;
        OnClick := LanguageSubMenuItemClick; //Above declared procedure
        RadioItem := True;
      end;
      AParentMenuItem.Add(LMItem);
    end;
  except
  end;
  AParentMenuItem.Visible := AParentMenuItem.Count > 1;
end;

//This procedure will get the language in the menu item that was clicked
procedure TCustomLanguageMenuItem.LanguageSubMenuItemClick(Sender: TObject);
var
  NewLanguageCode: string;
begin
  NewLanguageCode := FAvailableLanguages[(Sender as TMenuItem).Tag];
  UseLanguage(NewLanguageCode);
  DoOnChangeLanguage;
  DoOnAfterChangedLanguage(NewLanguageCode);
end;

procedure TCustomLanguageMenuItem.DoOnAfterChangedLanguage(const ALanguageCode: string);
begin
  if Assigned(FOnAfterChangedLanguage) then
    FOnAfterChangedLanguage(ALanguageCode);
end;

procedure TCustomLanguageMenuItem.DoOnChangeLanguage;
var
  I: Integer;
begin
  for I := 0 to Pred(FComponentsToRetranslate.Count) do
    RetranslateComponent(FComponentsToRetranslate[I]);
  if Assigned(FOnChangeLanguage) then
    FOnChangeLanguage(Self);
end;

procedure TCustomLanguageMenuItem.LanguageMainMenuItemClick(Sender: TObject);
var
  I, Idx: Integer;
begin
  Idx := FAvailableLanguages.IndexOf(GetCurrentLanguage);
  if Idx <> -1 then
    for I := 0 to Pred(Count) do
      if Items[I].Tag = Idx then
      begin
        Items[I].Checked := True;
        System.Break;
      end;
end;

procedure TCustomLanguageMenuItem.SetTextDomain(AValue: string);
begin
  if FTextDomain <> AValue then
  begin
    FTextDomain := AValue;
    CreateLanguageMenu(Self, FTextDomain);
  end;
end;

constructor TLanguageMenuItem.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  OnChangeLanguage := RetranslateAllScreenForms;
end;

procedure TLanguageMenuItem.RetranslateAllScreenForms(Sender: TObject);
var
  I: Integer;
begin
  // Retranslate all translated properties on all visible forms
  for I := 0 to Pred(Screen.FormCount) do
    RetranslateComponent(Screen.Forms[I]);
end;

procedure AddLanguageMenuItem(AParentMenuItem: TMenuItem; ADomain: string = DefaultTextDomain;
  AOnAfterChangedLanguage: TLanguageChangedEvent = nil);
var
  LanguageMenuItem: TLanguageMenuItem;
  BreakMenuItem: TMenuItem;
begin
  LanguageMenuItem := TLanguageMenuItem.CreateWithDomain(AParentMenuItem, ADomain);
  LanguageMenuItem.OnAfterChangedLanguage := AOnAfterChangedLanguage;
  if Assigned(AParentMenuItem.Parent) and (AParentMenuItem.Count > 0) then
  begin
    BreakMenuItem := TMenuItem.Create(AParentMenuItem);
    BreakMenuItem.Caption := '-';
    AParentMenuItem.Add(BreakMenuItem);
  end;
  AParentMenuItem.Add(LanguageMenuItem);
end;

end.
