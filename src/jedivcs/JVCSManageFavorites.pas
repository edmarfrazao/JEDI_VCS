(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: ManageFavorites.pas

The Initial Developer of the original code (JEDI VCS) is:
  Achim Kröber

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2008/06/29  AKroeber  - new unit
2008/07/06  USchuster - some minor changes (header, constants, resource strings)
2008/07/08  USchuster - D5 fix

-----------------------------------------------------------------------------*)

unit JVCSManageFavorites;

{$I jedi.inc}
{$I compopt.inc}

// contains ManageFavorites-Dialog and Favorites-Related stuff

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, JVCSMruList, VCSBase, ConfigStorage;

type
  TVCSManageFavorites = class(TForm)
    sbUp: TSpeedButton;
    sbDown: TSpeedButton;
    lbFav: TListBox;
    Label1: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    sbDel: TSpeedButton;
    sbAdd: TSpeedButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure sbUpClick(Sender: TObject);
    procedure sbDownClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lbFavClick(Sender: TObject);
    procedure sbAddClick(Sender: TObject);
    procedure sbDelClick(Sender: TObject);
  private
    { Private-Deklarationen }
    FavoritesChanged: Boolean;
    FavoriteProjectList: TJVCSMruList;
    procedure EnableButtons;
  public
    { Public-Deklarationen }
  end;

var
  VCSManageFavorites: TVCSManageFavorites;

function CurrentIdentity: string;
function DoManageFavorites: Boolean;

implementation

{$R *.dfm}

uses
  JvMRUManager, SelectProjectID, JVCSGUIClientResources;

function CurrentIdentity: string;
var
  I: Integer;
begin
  I := jvcsReadInteger(sBaseRegistryKey + crbIdentity, 'LastUsedID', 0);
  Result := jvcsReadString(sBaseRegistryKey + crbIdentity, 'ID' + IntToStr(I), '');
end;

function DoManageFavorites: Boolean;
begin
  if CurrentIdentity <> '' then
  begin
    Application.CreateForm(TVCSManageFavorites, VCSManageFavorites);
    try
      Result := (VCSManageFavorites.ShowModal = mrOK) and VCSManageFavorites.FavoritesChanged;
    finally
      VCSManageFavorites.Free;
    end;
  end else
    Result := False;
end;

procedure TVCSManageFavorites.btnOKClick(Sender: TObject);
begin
  if FavoritesChanged then
  begin
    FavoriteProjectList.Mode := rmAppend;
    FavoriteProjectList.Clear;
    FavoriteProjectList.AddStrings(lbFav.Items);
    FavoriteProjectList.SaveToStorage(sBaseRegistryKey + crbMRU + 'Favorites\' + CurrentIdentity);
  end;
end;

procedure TVCSManageFavorites.EnableButtons;
begin
  sbDel.Enabled := lbFav.ItemIndex >= 0;
  sbUp.Enabled := lbFav.ItemIndex > 0;
  sbDown.Enabled := sbDel.Enabled and (lbFav.ItemIndex < Pred(lbFav.Items.Count));
end;

procedure TVCSManageFavorites.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TVCSManageFavorites.FormCreate(Sender: TObject);
begin
  FavoritesChanged := False;
  FavoriteProjectList := TJVCSMruList.CreateEx(sBaseRegistryKey + crbMRU + 'Favorites\' + CurrentIdentity);
  lbFav.Items.Assign(FavoriteProjectList);
end;

procedure TVCSManageFavorites.FormDestroy(Sender: TObject);
begin
  FavoriteProjectList.Free;
end;

procedure TVCSManageFavorites.lbFavClick(Sender: TObject);
begin
  EnableButtons;
end;

procedure TVCSManageFavorites.sbAddClick(Sender: TObject);
var
  SelectedProjectID: Integer;
  SelectedProjectName: string;
begin
  VCSSelectProject := TVCSSelectProject.Create(Application);
  try
    VCSSelectProject.SetDlgCaption(JVCSRES_Add_project);
    VCSSelectProject.DefaultID := ServerProjectID;
    VCSSelectProject.ShowModal;
    SelectedProjectID := VCSSelectProject.SelectedID;
    SelectedProjectName := VCSSelectProject.SelectedName;
  finally
    VCSSelectProject.Free;
  end;
  if (SelectedProjectID <> 0) and (FavoriteProjectList.IndexOf(SelectedProjectName) < 0) then
  begin
    lbFav.Items.Add(SelectedProjectName);
    FavoritesChanged := True;
    EnableButtons;
  end;
end;

procedure TVCSManageFavorites.sbDelClick(Sender: TObject);
begin
  FavoritesChanged := True;
  lbFav.Items.Delete(lbFav.ItemIndex);
  EnableButtons;
end;

procedure TVCSManageFavorites.sbDownClick(Sender: TObject);
begin
  FavoritesChanged := True;
  lbFav.Items.Exchange(lbFav.ItemIndex, Succ(lbFav.ItemIndex));
  EnableButtons;
end;

procedure TVCSManageFavorites.sbUpClick(Sender: TObject);
begin
  FavoritesChanged := True;
  lbFav.Items.Exchange(lbFav.ItemIndex, Pred(lbFav.ItemIndex));
  EnableButtons;
end;

end.
