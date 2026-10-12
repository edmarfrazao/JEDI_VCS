(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSMruList.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:                                                                                    }

2003/03/08  USchuster - new unit - created to replace THistoryList and
                        TjvMruList to make the Mru stuff ConfigStorage
                        compatible
2003/03/09  USchuster - changed something in CreateEx
                        FCaseSensitive and MaxSize are now Assigned before
                        loading - necessary because loading would convert
                        everything to lowercase although ACaseSensitive is True
                        and would delete every entry which exceeds the standard
                        MaxSize although AMaxSize is bigger
2003/03/15  THuber    - warning removed
2004/02/23  THuber    - Update to JVCL 3.0 / JCL 1.90 (mantis #1353)
2008/06/30  USchuster - fixed saving of old Mode in AddStrings (by AK)
                      - minor style cleaning

-----------------------------------------------------------------------------*)

unit JVCSMruList;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  SysUtils, Classes, JvMRUManager, ConfigStorage;

type
  TJVCSMruList = class(TJvRecentStrings)
  protected
    FCaseSensitive,
    FAutoSave: Boolean;
    FAutoSaveKey: string;
  public
    constructor Create;
    constructor CreateEx(const AKey: string; AAutoLoad, AAutoSave,
      ACaseSensitive: Boolean; AMaxSize: Integer); overload;
    constructor CreateEx(const AKey: string); overload;
    constructor CreateEx(const AKey: string; AMaxSize: Integer); overload;
    destructor Destroy; override;

    function AddString(AString: string): Integer;
    procedure RemoveString(AString: string);

    procedure AddStrings(Strings: TStrings); override;

    procedure SaveToStorage(const AKey: string);
    procedure LoadFromStorage(const AKey: string);

    property CaseSensitive: Boolean read FCaseSensitive write FCaseSensitive;
    property AutoSave: Boolean read FAutoSave write FAutoSave;
    property AutoSaveKey: string read FAutoSaveKey write FAutoSaveKey;
  end;

implementation

constructor TJVCSMruList.Create;
begin
  inherited Create;

  FCaseSensitive := False;
  FAutoSave      := False;
  FAutoSaveKey   := '';
end;

constructor TJVCSMruList.CreateEx(const AKey: string; AAutoLoad, AAutoSave,
  ACaseSensitive: Boolean; AMaxSize: Integer);
begin
  inherited Create;

  FCaseSensitive := ACaseSensitive;
  MaxSize := AMaxSize;

  FAutoSaveKey := AKey;
  if AAutoLoad then
    LoadFromStorage(FAutoSaveKey);
  FAutoSave := AAutoSave;
end;

constructor TJVCSMruList.CreateEx(const AKey: string);
begin
  CreateEx(AKey, True, True, False, 10);
end;

constructor TJVCSMruList.CreateEx(const AKey: string; AMaxSize: Integer);
begin
  CreateEx(AKey, True, True, False, AMaxSize);
end;

destructor TJVCSMruList.Destroy;
begin
  if FAutoSave then
    SaveToStorage(FAutoSaveKey);

  inherited Destroy;
end;

function TJVCSMruList.AddString(AString: string): Integer;
begin
  if not FCaseSensitive then
    AString := AnsiLowerCase(AString);
  Result := Add(AString);
end;

procedure TJVCSMruList.RemoveString(AString: string);
var
  idx: Integer;
begin
  if not FCaseSensitive then
    AString := AnsiLowerCase(AString);
  idx := IndexOf(AString);
  if idx <> -1 then
    Delete(idx);
end;

procedure TJVCSMruList.AddStrings(Strings: TStrings);
var
  OldMode: TRecentMode;
begin
  OldMode:= Mode;
  try
    Mode := rmAppend;
    inherited AddStrings(Strings);
  finally
    Mode := OldMode;
  end;
end;

procedure TJVCSMruList.SaveToStorage(const AKey: string);
var
  I: Integer;
begin
  {$IFDEF DEBUG}
  Assert(AKey <> '', 'Parameter Key is blank');
  {$ENDIF DEBUG}
  if AKey <> '' then
  begin
    jvcsDeleteKey(AKey);
    for I := 0 to Pred(Count) do
      jvcsWriteString(AKey, IntToStr(I + 1), Strings[I]);
  end;
end;

procedure TJVCSMruList.LoadFromStorage(const AKey: string);
var
  I: Integer;
  S: string;
begin
  Clear;
  {$IFDEF DEBUG}
  Assert(AKey <> '', 'Parameter Key is blank');
  {$ENDIF DEBUG}
  if AKey <> '' then
  begin
    if jvcsKeyExists(AKey) then
      for I := 0 to Pred(MaxSize) do
        if jvcsValueExists(AKey, IntToStr(I + 1)) then
        begin
          S := jvcsReadString(AKey, IntToStr(I + 1), '');
          if not FCaseSensitive then
            S := AnsiLowerCase(S);
          if S <> '' then
            Insert(Count, S);
        end;
  end;
end;

end.
