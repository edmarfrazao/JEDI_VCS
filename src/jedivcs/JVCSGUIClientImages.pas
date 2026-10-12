(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSGUIClientImages.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2006/12/10  USchuster - new unit
2010/01/28  USchuster - addded images for "Diff" menu items (Mantis #5101)

-----------------------------------------------------------------------------*)

unit JVCSGUIClientImages;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  SysUtils, Classes, Forms, ImgList, Controls;

type
  TJVCSGUIClientImagesDataModule = class(TDataModule)
    ToolImageList: TImageList;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  JVCSGUIClientImagesDataModule: TJVCSGUIClientImagesDataModule;

function GetToolImageList: TImageList;
function ShowMenuBitmaps: Boolean;

implementation

uses
  ConfigStorage, VCSBase;

{$R *.dfm}

function GetToolImageList: TImageList;
begin
  if not Assigned(JVCSGUIClientImagesDataModule) then
    Application.CreateForm(TJVCSGUIClientImagesDataModule, JVCSGUIClientImagesDataModule);
  Result := JVCSGUIClientImagesDataModule.ToolImageList;
end;

function ShowMenuBitmaps: Boolean;
begin
  Result := jvcsReadBool(sBaseRegistryKey + crbWindows, 'ProjMan_ShowMenuBitmaps', True);
end;

end.
