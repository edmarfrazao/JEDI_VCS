(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: DiffHelp.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS: Thomas Huber (Thomas_D_Huber@t-online.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2004/04/12  THuber    - Created during move from hlp => chm Online Help

-----------------------------------------------------------------------------*)
{$I JEDI.INC}

unit DiffHelp;

{$IFDEF DELPHI6_UP}
  {$WARN UNIT_PLATFORM OFF}
  {$WARN SYMBOL_PLATFORM OFF}
{$ENDIF}

interface

uses
  {$IFDEF DEBUG}
  JclDebug,
  {$ENDIF}
  Windows, Forms, Sysutils;

// include help context definitions
{$I jedivcsdiff.inc}


procedure ShowHelpContext(App: TApplication; Ctx: Integer);

implementation

uses
  HtmlHlp;

//------------------------------------------------------------------------------

procedure ShowHelpContext(App: TApplication; Ctx: Integer);
begin
  App.Helpfile := ChangeFileExt(App.ExeName,'.chm');
  HtmlHelp(0, PChar(App.HelpFile), HH_HELP_CONTEXT, Ctx);
end;


end.

