(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: FVCSTypes.pas

The Initial Developer of the original Code (JEDI FreeVCS) is:
  Ondrej Kelle (tondrej@t-online.de)
Code move to JEDI VCS: Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Purpose:
  This unit contains common JEDI VCS client type declarations.

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history (JEDI FreeVCS):

2002/05/08  TOndrej    - Initial implementation and commenting

Unit history (JEDI VCS):

2003/10/23  USchuster  - 1st Migrationstep from JEDI FreeVCS code to JEDI VCS
                       - renamed to JVCSTypes.pas
                       - changed ...FVCS... into ...JVCS...
2005/03/05  USchuster  - added Exception class EJVCSClientRequestError (mantis #2714)
2008/11/07  USchuster  - added JVCSString100

-----------------------------------------------------------------------------*)

unit JVCSTypes;

{$I jedi.inc}

interface

uses
  SysUtils, Classes;

type
  EJVCSClient = class(Exception);

  EJVCSClientRequestError = class(EJVCSClient)
  private
    FStatusCode: Integer;
  public
    constructor Create(const Msg: string; AStatusCode: Integer);
    constructor CreateFmt(const Msg: string; const Args: array of const;
      AStatusCode: Integer);
    property StatusCode: Integer read FStatusCode;
  end;

  JVCSString1 = string[1];
  JVCSString10 = string[10];
  JVCSString20 = string[20];
  JVCSString50 = string[50];
  JVCSString100 = string[100];
  JVCSString200 = string[200];
  JVCSString250 = string[250];
  JVCSString255 = string[255];

  PUserData = ^TUserData;
  TUserData = record
    UserID: Integer;
    TransactionID: Integer;
  end;

implementation

constructor EJVCSClientRequestError.Create(const Msg: string; AStatusCode: Integer);
begin
  FStatusCode := AStatusCode;
  inherited Create(Msg);
end;

constructor EJVCSClientRequestError.CreateFmt(const Msg: string; const Args: array of const;
  AStatusCode: Integer);
begin
  FStatusCode := AStatusCode;
  inherited CreateFmt(Msg, Args);
end;

end.
