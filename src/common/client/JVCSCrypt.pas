(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: FVCSCrypt.pas
Based on ClientCryptInt.pas - interface unit for FVCSCrypt.dll by Thomas Hensle

The Initial Developer of the original Code (JEDI FreeVCS) is:
  Ondrej Kelle (tondrej@t-online.de)
Code move to JEDI VCS: Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Purpose:
  This is the interface unit for FVCSCrypt.dll - FreeVCS / JEDI VCS client password
  encryption library.

Last Modified: see History

Known Issues:
Oct/2003:
- functionnames still contain FVCS and not JVCS because JEDI VCS still uses
  the FreeVCS encryption library which isn't scheduled for a migration
Dec/2003:
- static linking / call to CryptDLL in initialize will only succeed in GUI Exe 
-----------------------------------------------------------------------------

Unit history(JEDI FreeVCS):

1999/08/??  THensle    - Initial implementation in ClientCryptInt.pas
2002/05/08  TOndrej    - Renamed to FVCSCrypt.pas to better follow the project
                         naming convention
                       - Added code for dynamic vs. static loading of the DLL
                         (based on conditional compile directive)

Unit history(JEDI VCS):

2003/10/23  USchuster  - 1st Migrationstep from JEDI FreeVCS code to JEDI VCS
                       - renamed to JVCSCrypt.pas
2003/12/27  THuber     - const for CryptDLL now in JVCSClientConsts
2004/05/04  THuber     #1186 - a decrease in the TDateTime seems to fix it

-----------------------------------------------------------------------------*)

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  ClientCryptInt - Interface unit for FVCSCrypt.dll
  Password encryption for FreeVCS application client application.

  Aug '99 by Thomas Hensle - http://www.freevcs.de
  Apr '02 modified TOndrej }

{$I JEDI.INC}

unit JVCSCrypt;

interface

uses SysUtils, Windows;

function fvcsCliEncrypt1(Value: ShortString): ShortString;
function fvcsCliEncrypt2(Value: ShortString; Key: TDateTime): ShortString;

{$IFNDEF FVCSCRYPT_STATICDLL}

function LoadFVCSCrypt(const FileName: string): Boolean;
procedure UnloadFVCSCrypt;

{$ENDIF}

implementation
uses
  JVCSClientConsts;

{$IFDEF FVCSCRYPT_STATICDLL}

function fvcsCliEncrypt1; external cCryptDLLName name 'fvcs_Encrypt1';
function fvcsCliEncrypt2; external cCryptDLLName name 'fvcs_Encrypt2';

{$ELSE}

var
  _FVCSCrypt: HMODULE = 0;

  _CliEncrypt1: function(Value: ShortString): ShortString = nil;
  _CliEncrypt2: function(Value: ShortString; Key: TDateTime): ShortString = nil;

//----------------------------------------------------------------------------------------------------------------------

function fvcsCliEncrypt1(Value: ShortString): ShortString;

begin
  Result := _CliEncrypt1(Value);
end;

//----------------------------------------------------------------------------------------------------------------------

function fvcsCliEncrypt2(Value: ShortString; Key: TDateTime): ShortString;

begin
  Result := _CliEncrypt2(Value, Key-1/86400);
end;

//----------------------------------------------------------------------------------------------------------------------

function LoadFVCSCrypt(const FileName: string): Boolean;

begin
  if _FVCSCrypt = 0 then
    _FVCSCrypt := LoadLibrary(PChar(FileName));

  Result := _FVCSCrypt <> 0;
  if Result then
  begin
    @_CliEncrypt1 := GetProcAddress(_FVCSCrypt, 'fvcs_Encrypt1');
    @_CliEncrypt2 := GetProcAddress(_FVCSCrypt, 'fvcs_Encrypt2');
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure UnloadFVCSCrypt;

begin
  if _FVCSCrypt <> 0 then
  begin
    FreeLibrary(_FVCSCrypt);
    _FVCSCrypt := 0;
  end;
  @_CliEncrypt1 := nil;
  @_CliEncrypt2 := nil;
end;

//----------------------------------------------------------------------------------------------------------------------

initialization
  _FVCSCrypt := GetModuleHandle(cCryptDLLName);
  if _FVCSCrypt <> 0 then
  begin
    @_CliEncrypt1 := GetProcAddress(_FVCSCrypt, 'fvcs_Encrypt1');
    @_CliEncrypt2 := GetProcAddress(_FVCSCrypt, 'fvcs_Encrypt2');
  end;

finalization
  UnloadFVCSCrypt;

{$ENDIF}

end.
