(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSExpertHistory.pas (JEDI VCS v2026)

-----------------------------------------------------------------------------

Unit JVCSExpertHistory - aba History da IDE (FileHistoryAPI)

  IOTAFileHistoryProvider "JEDI VCS File History Provider" sobre as 9 funcoes
  de JEDIVCSDLLHISTORYINIT (doc\client\Expert-IDE-Analise.md, 3.6):

    Get_Count      -> GetModuleHistoryCount(nome)
    GetAuthor(i)   -> GetModuleHistoryAuthor
    GetIdent(i)    -> GetModuleHistoryVersionRevisionStr ("v.rrr")
    GetComment(i)  -> GetModuleHistoryComment
    GetDate(i)     -> GetModuleHistoryDate
    GetLabelCount/GetLabels -> GetModuleHistoryLabelCount/Label
    GetContent(i)  -> GetModuleHistoryContentSize + GetModuleHistoryContent
                      (TMemoryStream -> TStreamAdapter)
    GetHistoryStyle-> hsRemoteRevision

  Diferencas em relacao ao original: TInterfacedObject (contagem de
  referencia real) com stubs de IDispatch (E_NOTIMPL); indices validados
  antes de chamar a DLL (ela nao verifica limites); chamadas feitas na thread
  principal (a DLL usa sockets ICS orientados a mensagens).

  Historico:
  2026/10/12  v2026 - nova unit
-----------------------------------------------------------------------------*)

unit JVCSExpertHistory;

interface

uses
  Winapi.Windows, Winapi.ActiveX, System.SysUtils, System.Classes, FileHistoryAPI;

const
  cJVCSHistoryProviderIdent = 'PROJECT JEDI.JEDI VCS File History Provider';
  cJVCSHistoryProviderName = 'JEDI VCS File History Provider';

type
  TJVCSDispatchStub = class(TInterfacedObject, IDispatch)
  protected
    { IDispatch }
    function GetTypeInfoCount(out Count: Integer): HResult; stdcall;
    function GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult; stdcall;
    function GetIDsOfNames(const IID: TGUID; Names: Pointer;
      NameCount, LocaleID: Integer; DispIDs: Pointer): HResult; stdcall;
    function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
      Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult; stdcall;
  public
    function SafeCallException(ExceptObject: TObject; ExceptAddr: Pointer): HResult; override;
  end;

  TJVCSFileHistoryProvider = class(TJVCSDispatchStub, IOTAFileHistoryProvider)
  protected
    { IOTAFileHistoryProvider }
    function Get_Ident: WideString; safecall;
    function Get_Name: WideString; safecall;
    function GetFileHistory(const AFileName: WideString): IOTAFileHistory; safecall;
  end;

  TJVCSFileHistory = class(TJVCSDispatchStub, IOTAFileHistory)
  private
    FFileName: string;
    FModule: AnsiString;
    FCount: Integer;
    function ValidIndex(AIndex: Integer): Boolean;
  protected
    { IOTAFileHistory }
    function Get_Count: Integer; safecall;
    function GetAuthor(Index: Integer): WideString; safecall;
    function GetComment(Index: Integer): WideString; safecall;
    function GetContent(Index: Integer): IStream; safecall;
    function GetDate(Index: Integer): TDateTime; safecall;
    function GetIdent(Index: Integer): WideString; safecall;
    function GetHistoryStyle(Index: Integer): TOTAHistoryStyle; safecall;
    function GetLabelCount(Index: Integer): Integer; safecall;
    function GetLabels(Index, LabelIndex: Integer): WideString; safecall;
  public
    constructor Create(const AFileName: string);
  end;

implementation

uses
  JVCSExpertUtils, JVCSExpertDllBridge;

function HistoryReady: Boolean;
begin
  Result := Assigned(JVCSBridge) and JVCSBridge.Loaded and JVCSBridge.HasHistory;
end;

{ TJVCSDispatchStub }

function TJVCSDispatchStub.GetTypeInfoCount(out Count: Integer): HResult;
begin
  Count := 0;
  Result := E_NOTIMPL;
end;

function TJVCSDispatchStub.GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult;
begin
  Pointer(TypeInfo) := nil;
  Result := E_NOTIMPL;
end;

function TJVCSDispatchStub.GetIDsOfNames(const IID: TGUID; Names: Pointer;
  NameCount, LocaleID: Integer; DispIDs: Pointer): HResult;
begin
  Result := E_NOTIMPL;
end;

function TJVCSDispatchStub.Invoke(DispID: Integer; const IID: TGUID;
  LocaleID: Integer; Flags: Word; var Params; VarResult, ExcepInfo,
  ArgErr: Pointer): HResult;
begin
  Result := E_NOTIMPL;
end;

function TJVCSDispatchStub.SafeCallException(ExceptObject: TObject;
  ExceptAddr: Pointer): HResult;
begin
  JvcsLog('History: ' + JvcsDescribeException(ExceptObject));
  Result := E_UNEXPECTED;
end;

{ TJVCSFileHistoryProvider }

function TJVCSFileHistoryProvider.Get_Ident: WideString;
begin
  Result := cJVCSHistoryProviderIdent;
end;

function TJVCSFileHistoryProvider.Get_Name: WideString;
begin
  Result := cJVCSHistoryProviderName;
end;

function TJVCSFileHistoryProvider.GetFileHistory(
  const AFileName: WideString): IOTAFileHistory;
begin
  Result := nil;
  if HistoryReady and (AFileName <> '') then
    Result := TJVCSFileHistory.Create(AFileName);
end;

{ TJVCSFileHistory }

constructor TJVCSFileHistory.Create(const AFileName: string);
begin
  inherited Create;
  FFileName := AFileName;
  FModule := JvcsToAnsi(AFileName);
  FCount := -1;
end;

function TJVCSFileHistory.Get_Count: Integer;
var
  N: Integer;
begin
  if FCount < 0 then
  begin
    N := 0;
    if HistoryReady then
      JvcsRunInMainThread(
        procedure
        begin
          N := JVCSBridge.HistoryCount(FModule);
        end);
    FCount := N;
  end;
  Result := FCount;
end;

function TJVCSFileHistory.ValidIndex(AIndex: Integer): Boolean;
begin
  Result := HistoryReady and (AIndex >= 0) and (AIndex < Get_Count);
end;

function TJVCSFileHistory.GetAuthor(Index: Integer): WideString;
var
  S: string;
begin
  S := '';
  if ValidIndex(Index) then
    JvcsRunInMainThread(
      procedure
      begin
        S := JVCSBridge.HistoryAuthor(FModule, Index);
      end);
  Result := S;
end;

function TJVCSFileHistory.GetComment(Index: Integer): WideString;
var
  S: string;
begin
  S := '';
  if ValidIndex(Index) then
    JvcsRunInMainThread(
      procedure
      begin
        S := JVCSBridge.HistoryComment(FModule, Index);
      end);
  Result := S;
end;

function TJVCSFileHistory.GetContent(Index: Integer): IStream;
var
  MS: TMemoryStream;
begin
  MS := TMemoryStream.Create;
  try
    if ValidIndex(Index) then
      JvcsRunInMainThread(
        procedure
        begin
          JVCSBridge.HistoryContent(FModule, Index, MS);
        end);
    MS.Position := 0;
  except
    MS.Free;
    raise;
  end;
  Result := TStreamAdapter.Create(MS, soOwned);
end;

function TJVCSFileHistory.GetDate(Index: Integer): TDateTime;
var
  D: TDateTime;
begin
  D := 0;
  if ValidIndex(Index) then
    JvcsRunInMainThread(
      procedure
      begin
        if not JVCSBridge.HistoryDate(FModule, Index, D) then
          D := 0;
      end);
  Result := D;
end;

function TJVCSFileHistory.GetIdent(Index: Integer): WideString;
var
  S: string;
begin
  S := '';
  if ValidIndex(Index) then
    JvcsRunInMainThread(
      procedure
      begin
        S := JVCSBridge.HistoryVersionRevision(FModule, Index);
      end);
  Result := S;
end;

function TJVCSFileHistory.GetHistoryStyle(Index: Integer): TOTAHistoryStyle;
begin
  Result := hsRemoteRevision;
end;

function TJVCSFileHistory.GetLabelCount(Index: Integer): Integer;
var
  N: Integer;
begin
  N := 0;
  if ValidIndex(Index) then
    JvcsRunInMainThread(
      procedure
      begin
        N := JVCSBridge.HistoryLabelCount(FModule, Index);
      end);
  Result := N;
end;

function TJVCSFileHistory.GetLabels(Index, LabelIndex: Integer): WideString;
var
  S: string;
begin
  S := '';
  if ValidIndex(Index) and (LabelIndex >= 0) and (LabelIndex < GetLabelCount(Index)) then
    JvcsRunInMainThread(
      procedure
      begin
        S := JVCSBridge.HistoryLabel(FModule, Index, LabelIndex);
      end);
  Result := S;
end;

end.
