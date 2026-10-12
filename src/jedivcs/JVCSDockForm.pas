(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSDockForm.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2003/05/21  USchuster - new unit
2003/09/15  USchuster - changed FormClose
                      - changed ShowAndDockToControl - show is now after docking
                        to avoid flickering
2005/03/05  USchuster - added handler routine for TJVCSJobThread.OnJobException
                        to ignore appserver result 403 (mantis #2714)           
2006/01/02  THuber    #3404 changed handling for docked windows in projadmin
                      - default parameter for ShowAndDockToControl changed to alClient
2006/01/21  THuber    - hints removed
2011/01/15  USchuster - changed font to Tahoma
-----------------------------------------------------------------------------*)

unit JVCSDockForm;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls;

type
  TJVCSDockableForm = class(TForm)
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  protected
    procedure HandleThreadException(Sender: TObject; E: Exception; var AHandled: Boolean);
  public
    { Public declarations }
    procedure ShowAndDockToControl(NewDockSite: TWinControl;
      DropControl: TControl = nil; ControlSide: TAlign = alClient);
  end;

var
  JVCSDockableForm: TJVCSDockableForm;

implementation

uses
  JVCSTypes;

{$R *.dfm}

type
  TWinControlCracker = class(TWinControl);

procedure TJVCSDockableForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
{ //USc 15.09.2003 the dockhost should whats necessary when a client is removed
  //because calling ManualDock (Undock) here causes a FormShow of this form
  if (not Floating) and (not (HostDockSite is TPageControl)) then
    ManualDock(nil);
}
  if (not Floating) and Assigned(HostDockSite) then
    TWinControlCracker(HostDockSite).DoUnDock(nil, HostDockSite);  //self
end;

procedure TJVCSDockableForm.HandleThreadException(Sender: TObject; E: Exception; var AHandled: Boolean);
begin
  if (E is EJVCSClientRequestError) and (EJVCSClientRequestError(E).StatusCode = 403) then
    AHandled := True;
end;

procedure TJVCSDockableForm.ShowAndDockToControl(NewDockSite: TWinControl;
  DropControl: TControl = nil; ControlSide: TAlign = alClient);
begin
  if HostDockSite <> NewDockSite then
    ManualDock(NewDockSite, DropControl, ControlSide);
  Show;
  //#3404 Realign docked windows if windowstate is changed from hidden to visible
  if Assigned(HostDockSite) then
    HostDockSite.Realign;
end;

end.
