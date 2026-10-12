(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSFunctions.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2004/01/08  USchuster - new unit (new home for some common functions)

-----------------------------------------------------------------------------*)
{$I JEDI.INC}

unit JVCSFunctions;

{$I COMPOPT.INC}

interface

uses
  Windows, SysUtils;

// Moved from VCSProcBase
function GetSelfFileName: string;
function GetSelfFileLocation: string;

implementation

function GetSelfFileName: string;
var
  ModName: array [0..MAX_PATH] of Char;
begin
  SetString(Result, ModName,
    Windows.GetModuleFileName(HInstance, ModName, SizeOf(ModName)));
end;

//------------------------------------------------------------------------------

function GetSelfFileLocation: string;
begin
  Result := ExtractFilePath(GetSelfFileName);
end;

end.
