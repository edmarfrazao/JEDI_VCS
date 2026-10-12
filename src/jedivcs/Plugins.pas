(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: Plugins.pas

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
2004/04/17  USchuster - restricted minimum size in form
                      - minor style cleaning (casing and comments)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/24  USchuster - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/11/02  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
2007/06/30  USchuster - changes for large fonts (contraints size depend now on PixelsPerInch; analog to Mantis #3710)                      
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit Plugins;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, JVCSForms;

type
  TVCSPlugin = class(TJVCSForm)
    Panel1: TPanel;
    Panel2: TPanel;
    lbPlugIns: TListBox;
    btnConfigure: TButton;
    btnClose: TButton;
    memDescr: TMemo;
    Splitter1: TSplitter;
    pnAuthor: TPanel;
    Help: TSpeedButton;
    lblVersion: TLabel;
    pnlCopyRight: TPanel;
    pnID: TPanel;
    procedure lbPlugInsClick(Sender: TObject);
    procedure btnConfigureClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  VCSPlugin: TVCSPlugin;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  ProjAdmin, VCSBase, VCSProcBase, JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSPlugin.FormShow(Sender: TObject);
begin
  lblVersion.Caption := JVCSRES_JVCL_Plugin_Manager;
end;

procedure TVCSPlugin.lbPlugInsClick(Sender: TObject);
begin
  if lbPlugIns.ItemIndex = -1 then 
    Exit;
  pnAuthor.Caption :=
    VCSProjAdmin.uilPluginManager1.Plugins[lbPlugIns.ItemIndex].Author;
  pnlCopyRight.Caption :=
    VCSProjAdmin.uilPluginManager1.Plugins[lbPlugIns.ItemIndex].Copyright;
  pnID.Caption :=
    VCSProjAdmin.uilPluginManager1.Plugins[lbPlugIns.ItemIndex].PlugInID;
  memDescr.Lines.Clear;
  memDescr.Lines.Add(VCSProjAdmin.uilPluginManager1.Plugins[lbPlugIns.ItemIndex].Description);
end;

procedure TVCSPlugin.btnConfigureClick(Sender: TObject);
begin
  if lbPlugIns.ItemIndex = -1 then 
    Exit;
  VCSProjAdmin.uilPluginManager1.Plugins[lbPlugIns.ItemIndex].Configure;
end;

procedure TVCSPlugin.HelpClick(Sender: TObject);
begin
  PerformHelpCommand(Application, IDH_Plug_In_s);
end;

procedure TVCSPlugin.FormCreate(Sender: TObject);
begin
  try
    Constraints.MinHeight := MulDiv(200, PixelsPerInch, 96);
    Constraints.MinWidth := MulDiv(350, PixelsPerInch, 96);
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

end.
