(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSDialogs.pas

The Initial Developer of the original code (JEDIVCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Purpose:
 This unit simulates the used functions and constants from DFS.DSAMSG
 with JvDSADialogs for an easy migration without big changes and an
 "go back" option.

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2003/02/12  USchuster - new unit - created to replace DFS.DSAIdentsMessageDlg
                      - add DSAIdentsClear because this is used in JediVCSDLL
2003/03/03  USchuster - changed for storage unit "ConfigStorage.pas"
2004/02/04  USchuster - added WarnMessageBox
2004/02/18  USchuster - added NoYesMessageBox
2004/02/27  USchuster - added ErrorMessageBox, NoYesWarnMessageBox, YesNoMessageBox
2004/07/25  USchuster - updated to current JVCL 3 from CVS
^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC1 was released ^^^^^^^^^^^^^^^^^^^^^^^^^^^
2005/02/26  THuber    - added InfoMessageBox
                                                                                                  
-----------------------------------------------------------------------------*)
{$I jedi.inc}

unit JVCSDialogs;

{$I compopt.inc}

interface

uses
  Windows, Dialogs, JvDSADialogs, ConfigStorage, Forms;

resourcestring
  SDontShow = '&Don''t show this message again';

const
  DontShowMsgText: string = SDontShow;
  UseRegistry: Boolean = True;

function DSAIdentsMessageDlg(const Msg: string; AType: TMsgDlgType;
  AButtons: TMsgDlgButtons; HelpCtx: Longint; Filename, ID: string;
  DefaultResult: Word): Word;
function DSAIdentsGetState(Filename, ID: string): Boolean;
procedure DSAIdentsSetState(Filename, ID: string; Value: Boolean);
procedure DSAIdentsClear(Filename, ID: string);

procedure InfoMessageBox(const AMessage: string);
procedure ErrorMessageBox(const AMessage: string);
procedure WarnMessageBox(const AMessage: string);
function NoYesMessageBox(const AMessage: string): Boolean;
function NoYesWarnMessageBox(const AMessage: string): Boolean;
function YesNoMessageBox(const AMessage: string): Boolean;

implementation

uses
  SysUtils, VCSBase;

const
  ctkOwnDSAMsg = 99;

type
  TDSAJVCSConfigStorage = class(TDSAStorage)
  private
    FKey: string;
    function FixKey(AKey: string): string;
  protected
    function GetCheckMarkTextSuffix: string; override;
    procedure SetCheckMarkTextSuffix(const Value: string); override;
  public
    constructor Create(const AKey: string);
    function ReadBool(const DSAInfo: TDSARegItem; const Key: string): Boolean; override;
    function ReadBoolDef(const DSAInfo: TDSARegItem; const Key: string;
      const Default: Boolean): Boolean; override;
    function ReadFloat(const DSAInfo: TDSARegItem; const Key: string): Extended; override;
    function ReadFloatDef(const DSAInfo: TDSARegItem; const Key: string;
      const Default: Extended): Extended; override;
    function ReadInt64(const DSAInfo: TDSARegItem; const Key: string): Int64; override;
    function ReadInt64Def(const DSAInfo: TDSARegItem; const Key: string;
      const Default: Int64): Int64; override;
    function ReadInteger(const DSAInfo: TDSARegItem; const Key: string): Integer; override;
    function ReadIntegerDef(const DSAInfo: TDSARegItem; const Key: string;
      const Default: Integer): Integer; override;
    function ReadString(const DSAInfo: TDSARegItem; const Key: string): string; override;
    function ReadStringDef(const DSAInfo: TDSARegItem; const Key: string;
      const Default: string): string; override;
    procedure WriteBool(const DSAInfo: TDSARegItem; const Key: string;
      const Value: Boolean); override;
    procedure WriteFloat(const DSAInfo: TDSARegItem; const Key: string;
      const Value: Extended); override;
    procedure WriteInt64(const DSAInfo: TDSARegItem; const Key: string;
      const Value: Int64); override;
    procedure WriteInteger(const DSAInfo: TDSARegItem; const Key: string;
      const Value: Integer); override;
    procedure WriteString(const DSAInfo: TDSARegItem; const Key: string;
      const Value: string); override;
    property Key: string read FKey write FKey;
  end;

//change the Key to the same DFS.DSA... did use
//  this is a bit dirty because when "DSA_State" in JvDSADialogs
//  will be changed this doesn't work any more !!
function TDSAJVCSConfigStorage.FixKey(AKey: string): string;
begin
  Result := AKey;
  if Result = 'DSA_State' then
    Result := 'DontShow';
end;

function TDSAJVCSConfigStorage.GetCheckMarkTextSuffix: string;
begin
  Result := '';
end;

procedure TDSAJVCSConfigStorage.SetCheckMarkTextSuffix(const Value: string);
begin
end;

constructor TDSAJVCSConfigStorage.Create(const AKey: string);
begin
  inherited Create;
  FKey := AKey;
end;

function TDSAJVCSConfigStorage.ReadBool(const DSAInfo: TDSARegItem; const Key: string): Boolean;
begin
//note - currently not used by JvDSADialogs
  Result := jvcsReadBool(Self.Key + '\' + DSAInfo.Name, Key, False);
end;

function TDSAJVCSConfigStorage.ReadBoolDef(const DSAInfo: TDSARegItem; const Key: string;
  const Default: Boolean): Boolean;
begin
  Result := jvcsReadBool(Self.Key + '\' + DSAInfo.Name, FixKey(Key), Default);
end;

function TDSAJVCSConfigStorage.ReadFloat(const DSAInfo: TDSARegItem; const Key: string): Extended;
begin
//note - currently not used by JvDSADialogs
  Result := jvcsReadFloat(Self.Key + '\' + DSAInfo.Name, Key, 0);
end;

function TDSAJVCSConfigStorage.ReadFloatDef(const DSAInfo: TDSARegItem; const Key: string;
  const Default: Extended): Extended;
begin
//note - currently not used by JvDSADialogs
  Result := jvcsReadFloat(Self.Key + '\' + DSAInfo.Name, Key, Default);
end;

function TDSAJVCSConfigStorage.ReadInt64(const DSAInfo: TDSARegItem; const Key: string): Int64;
begin
//note - currently not used by JvDSADialogs
  Result := 0;
end;

function TDSAJVCSConfigStorage.ReadInt64Def(const DSAInfo: TDSARegItem; const Key: string;
  const Default: Int64): Int64;
begin
//note - currently not used by JvDSADialogs
  Result := Default;
end;

function TDSAJVCSConfigStorage.ReadInteger(const DSAInfo: TDSARegItem; const Key: string): Integer;
begin
//note - currently not used by JvDSADialogs
  Result := jvcsReadInteger(Self.Key + '\' + DSAInfo.Name, Key, 0);
end;

function TDSAJVCSConfigStorage.ReadIntegerDef(const DSAInfo: TDSARegItem; const Key: string;
  const Default: Integer): Integer;
begin
  Result := jvcsReadInteger(Self.Key + '\' + DSAInfo.Name, Key, Default);
end;

function TDSAJVCSConfigStorage.ReadString(const DSAInfo: TDSARegItem; const Key: string): string;
begin
//note - currently not used by JvDSADialogs
  Result := jvcsReadString(Self.Key + '\' + DSAInfo.Name, Key, '');
end;

function TDSAJVCSConfigStorage.ReadStringDef(const DSAInfo: TDSARegItem; const Key: string;
  const Default: string): string;
begin
//note - currently not used by JvDSADialogs
  Result := jvcsReadString(Self.Key + '\' + DSAInfo.Name, Key, Default);
end;

procedure TDSAJVCSConfigStorage.WriteBool(const DSAInfo: TDSARegItem; const Key: string;
  const Value: Boolean);
begin
  jvcsWriteBool(Self.Key + '\' + DSAInfo.Name, FixKey(Key), Value);
end;

procedure TDSAJVCSConfigStorage.WriteFloat(const DSAInfo: TDSARegItem; const Key: string;
  const Value: Extended);
begin
//note - currently not used by JvDSADialogs
  jvcsWriteFloat(Self.Key + '\' + DSAInfo.Name, Key, Value);
end;

procedure TDSAJVCSConfigStorage.WriteInt64(const DSAInfo: TDSARegItem; const Key: string;
  const Value: Int64);
begin
//note - currently not used by JvDSADialogs
end;

procedure TDSAJVCSConfigStorage.WriteInteger(const DSAInfo: TDSARegItem; const Key: string;
  const Value: Integer);
begin
  jvcsWriteInteger(Self.Key + '\' + DSAInfo.Name, Key, Value);
end;

procedure TDSAJVCSConfigStorage.WriteString(const DSAInfo: TDSARegItem; const Key: string;
  const Value: string);
begin
//note - currently not used by JvDSADialogs
  jvcsWriteString(Self.Key + '\' + DSAInfo.Name, Key, Value);
end;

{ v2026: os dialogos DSA podem ser reentrantes (um TTimer - ex. LoginTimer,
  UpdateTimer do Project Manager - mostra outro dialogo enquanto um esta
  aberto). Antes todos usavam o ID 0 e o texto ctkOwnDSAMsg e o segundo
  levantava EJvDSADialog "CheckMarkText ID 99 already registered" / "DSA ID 0
  already registered". Agora cada uso pega um ID livre e o texto da marca e
  registrado uma vez (contador). }
var
  GDSACheckMarkRefs: Integer = 0;

const
  cDSAIDBase = 26000;

{ v2026 (F4, 3a etapa): o contador da 1a versao nao era seguro (IDs liberados
  fora de ordem) e o mesmo NOME reentrante (ex.: 'SyncRes' com o primeiro
  dialogo ainda aberto) levantava "DSA dialog named ... is already assigned to
  another dialog ID". Agora: ID = o primeiro realmente livre; nome ja
  registrado = reutiliza o registro existente (sem registrar/desregistrar). }

function DSAIDInUse(AID: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to DSACount - 1 do
    if DSAItem(I).ID = AID then
      Exit(True);
end;

function FindDSAByName(const AName: string): Integer;
var
  I: Integer;
begin
  for I := 0 to DSACount - 1 do
    if SameText(DSAItem(I).Name, AName) then
      Exit(DSAItem(I).ID);
  Result := -1;
end;

function UseDSA(const AName: string; AStorage: TDSAStorage; out AOwned: Boolean): Integer;
begin
  AOwned := False;
  Result := FindDSAByName(AName);
  if Result >= 0 then
    Exit;
  Result := cDSAIDBase;
  while DSAIDInUse(Result) do
    Inc(Result);
  RegisterDSA(Result, AName, '', AStorage, ctkOwnDSAMsg);
  AOwned := True;
end;

procedure AcquireCheckMarkText(const AText: string);
begin
  if GDSACheckMarkRefs = 0 then
    RegisterDSACheckMarkText(ctkOwnDSAMsg, AText);
  Inc(GDSACheckMarkRefs);
end;

procedure ReleaseCheckMarkText;
begin
  if GDSACheckMarkRefs > 0 then
  begin
    Dec(GDSACheckMarkRefs);
    if GDSACheckMarkRefs = 0 then
      UnregisterDSACheckMarkText(ctkOwnDSAMsg);
  end;
end;

function DSAIdentsMessageDlg(const Msg: string; AType: TMsgDlgType;
  AButtons: TMsgDlgButtons; HelpCtx: Longint; Filename, ID: string;
  DefaultResult: Word): Word;
var
  CStorage: TDSAJVCSConfigStorage;
  LID: Integer;
  Owned, MarkAcquired: Boolean;
begin
  CStorage := nil;
  Owned := False;
  MarkAcquired := False;
  LID := -1;
  try
    CStorage := TDSAJVCSConfigStorage.Create(Filename);

    if (Length(DontShowMsgText) > 0) and
      (DontShowMsgText[Length(DontShowMsgText)] = '.')
    then
      Delete(DontShowMsgText, Length(DontShowMsgText), 1);

    AcquireCheckMarkText(DontShowMsgText);
    MarkAcquired := True;
    LID := UseDSA(ID, CStorage, Owned);
    SetDSAState(LID, GetDSAState(LID), DefaultResult);

    Result := DSAMessageDlg(LID, Msg, AType, AButtons, HelpCtx);

  finally
    if Owned then
      UnRegisterDSA(LID);
    if MarkAcquired then
      ReleaseCheckMarkText;
    CStorage.Free;
  end;
end;

function DSAIdentsGetState(Filename, ID: string): Boolean;
var
  CStorage: TDSAJVCSConfigStorage;
  LID: Integer;
  Owned: Boolean;
begin
  CStorage := nil;
  Owned := False;
  LID := -1;
  try
    CStorage := TDSAJVCSConfigStorage.Create(Filename);
    LID := UseDSA(ID, CStorage, Owned);

    //why "not" ? - DFS.DSA... does the same and it seam to be the
    //same result
    Result := not GetDSAState(LID);

  finally
    if Owned then
      UnRegisterDSA(LID);
    CStorage.Free;
  end;
end;

procedure DSAIdentsSetState(Filename, ID: string; Value: Boolean);
var
  CStorage: TDSAJVCSConfigStorage;
  LID: Integer;
  DefaultResult: Integer;
  Owned: Boolean;
begin
  CStorage := nil;
  Owned := False;
  LID := -1;
  try
    CStorage := TDSAJVCSConfigStorage.Create(Filename);
    LID := UseDSA(ID, CStorage, Owned);

    GetDSAState(LID, DefaultResult);
    //why "not" ? - DFS.DSA... does the same and it seam to be the
    //same result
    SetDSAState(LID, not Value, DefaultResult);

  finally
    if Owned then
      UnRegisterDSA(LID);
    CStorage.Free;
  end;
end;

procedure DSAIdentsClear(Filename, ID: string);
begin
  DSAIdentsSetState(Filename, ID, True);
end;

procedure InfoMessageBox(const AMessage: string);
begin
  MessageBox(Application.Handle, PChar(AMessage), cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
end;

procedure ErrorMessageBox(const AMessage: string);
begin
  MessageBox(Application.Handle, PChar(AMessage), cMsgBoxCaption, MB_OK or MB_ICONSTOP);
end;

procedure WarnMessageBox(const AMessage: string);
begin
  MessageBox(Application.Handle, PChar(AMessage), cMsgBoxCaption, MB_OK or MB_ICONWARNING);
end;

function NoYesMessageBox(const AMessage: string): Boolean;
begin
  Result := MessageBox(Application.Handle, PChar(AMessage), cMsgBoxCaption,
    MB_YESNO or MB_DEFBUTTON2 or MB_ICONQUESTION) = IDYES;
end;

function NoYesWarnMessageBox(const AMessage: string): Boolean;
begin
  Result := MessageBox(Application.Handle, PChar(AMessage), cMsgBoxCaption,
    MB_YESNO or MB_DEFBUTTON2 or MB_ICONWARNING) = IDYES;
end;

function YesNoMessageBox(const AMessage: string): Boolean;
begin
  Result := MessageBox(Application.Handle, PChar(AMessage), cMsgBoxCaption,
    MB_YESNO or MB_ICONQUESTION) = IDYES;
end;

end.
