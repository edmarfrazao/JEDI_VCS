(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSForms.pas

The Initial Developer of the original code (JEDI VCS) is:
  Thomas Huber (thomas_d_huber@gmx.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:
2008/12/22  THuber    introduced unit for various fixes:
                      - fixing z-order problem together with VISTA Taskbar code for Delphi<2007
2009/01/05  THuber    VISTA Taskbar fix needs to commented out for >= Delphi2007

-----------------------------------------------------------------------------*)

unit JVCSForms;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Forms, Controls;

type
  TJVCSForm = class(TForm)
  private
    { Private declarations }
  protected
    { Protected declarations }
{$IFNDEF IDEDLL}
    procedure CreateParams(var Params: TCreateParams); override;
{$ENDIF ~IDEDLL}
  public
    { Public declarations }
  end;

implementation

{$IFNDEF IDEDLL}
procedure TJVCSForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  {$IFNDEF DELPHI2007_UP}
  if Owner is TWinControl then
  begin
    Params.WndParent := TWinControl(Owner).Handle;
  end else if Owner is TApplication then
  begin
    Params.WndParent := Application.Mainform.Handle;
  end;
  {$ENDIF ~DELPHI2007_UP}
end;
{$ENDIF ~IDEDLL}

end.
