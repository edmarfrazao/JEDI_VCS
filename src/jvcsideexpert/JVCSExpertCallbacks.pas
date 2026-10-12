(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSExpertCallbacks.pas (JEDI VCS v2026)

-----------------------------------------------------------------------------

Unit JVCSExpertCallbacks - as 24 callbacks de TExternalIDEFunctionRec

  Implementacao (DLL -> IDE) equivalente a do expert JvcsExpertBDS21.dll
  (doc\client\Expert-IDE-Analise.md, 3.4), com as correcoes da secao 6.3:
  - toda callback e stdcall e tem try/except: nenhuma excecao atravessa a
    fronteira; em erro devolve 0/False/'' ;
  - copias para os buffers de 256 bytes da DLL sao LIMITADAS a 255 bytes + #0
    (o original fazia StrPCopy sem limite). CAMINHOS (projeto, units, forms,
    arquivo atual) que nao cabem NAO sao truncados: a callback devolve '' e as
    listas de units/forms os omitem (um caminho cortado seria outro caminho
    valido para a DLL); texto (pacotes, componentes, chave) e truncado;
  - nomes: string <-> AnsiString em CP_ACP sem "best fit" (caractere fora da
    pagina de codigo vira '?', nunca um parecido);
  - SourceReadString/SourceWriteString convertem UTF-8 do editor <-> ANSI
    (o original passava UTF-8 cru); as posicoes vistas pela DLL sao posicoes
    no texto ANSI convertido;
  - cada callback entra no contexto de DPI da IDE (a DLL pode estar rodando
    em contexto "unaware").

  Historico:
  2026/10/12  v2026 - nova unit
-----------------------------------------------------------------------------*)

unit JVCSExpertCallbacks;

interface

uses
  JVCSExpertABI;

// Preenche os 24 ponteiros do record entregue a JEDIVCSDLLINIT
procedure JvcsFillIDEFunctionRec(var ARec: TExternalIDEFunctionRec);

// Nome do projeto ativo no formato que a DLL usa (.dpr/.dpk em Delphi);
// durante o fechamento do projeto devolve o nome guardado em cache.
function JvcsProjectNameForDll: string;
// Usado pelo TJVCSProjectCloseNotifier (cache durante ifnProjectClosing)
procedure JvcsSetClosingProject(AClosing: Boolean; const AName: string);
// Descarta o cache de SourceReadString (apos escrita no editor)
procedure JvcsInvalidateSourceCache;
// Libera listas/caches (chamado no shutdown do wizard)
procedure JvcsReleaseCallbackCaches;

implementation

uses
  Winapi.Windows, System.SysUtils, System.Classes, ToolsAPI, JVCSExpertUtils;

var
  GUnitList: TStringList = nil;
  GFormList: TStringList = nil;
  GClosingProject: Boolean = False;
  GClosingProjectName: string = '';

  GSrcCacheName: string = '';
  GSrcCacheData: AnsiString = '';
  GSrcCacheTick: UInt64 = 0;

  GLastRaiseMsg: string = '';
  GLastRaiseTick: UInt64 = 0;

const
  cSrcCacheTimeoutMs = 10000;
  cRaiseRepeatMs = 30000;

{ ---- helpers ---------------------------------------------------------------- }

function JvcsProjectNameForDll: string;
begin
  if GClosingProject then
    Exit(GClosingProjectName);
  Result := JvcsProjectSourceName(JvcsActiveProject);
end;

procedure JvcsSetClosingProject(AClosing: Boolean; const AName: string);
begin
  GClosingProject := AClosing;
  if AClosing then
    GClosingProjectName := AName;
end;

procedure JvcsInvalidateSourceCache;
begin
  GSrcCacheName := '';
  GSrcCacheData := '';
  GSrcCacheTick := 0;
end;

procedure JvcsReleaseCallbackCaches;
begin
  FreeAndNil(GUnitList);
  FreeAndNil(GFormList);
  JvcsInvalidateSourceCache;
  GClosingProject := False;
  GClosingProjectName := '';
  GLastRaiseMsg := '';
  GLastRaiseTick := 0;
end;

function NewSortedList: TStringList;
begin
  Result := TStringList.Create;
  Result.CaseSensitive := False;
  Result.Duplicates := dupIgnore;
  Result.Sorted := True;
end;

// Acrescenta AFileName a AList se ainda nao estiver la E se o caminho couber
// no buffer de 256 bytes da DLL; senao omite e registra no log (a DLL nunca
// recebe um caminho truncado nem um item vazio no meio da lista).
procedure AddDllPath(AList: TStringList; const AFileName: string);
begin
  if (AFileName = '') or (AList.IndexOf(AFileName) >= 0) then
    Exit;
  if JvcsPathFitsAnsiBuffer(AFileName, cDllNameBufferMaxLen) then
    AList.Add(AFileName)
  else
    JvcsLogFmt('aviso: "%s" omitido da lista de units/forms da DLL (caminho com mais de %d bytes)',
      [AFileName, cDllNameBufferMaxLen]);
end;

// Lista "units" como no expert BDS21 (0x408F50): arquivo do projeto, .res do
// projeto (se existir), arquivos dos editores do modulo do projeto (.dpr) e
// IOTAProject.GetModule(i).FileName. Ordenada, sem duplicatas.
procedure BuildUnitList;
var
  Project: IOTAProject;
  FN: string;
  I: Integer;
  Editor: IOTAEditor;
  Info: IOTAModuleInfo;
begin
  if GUnitList = nil then
    GUnitList := NewSortedList;
  GUnitList.Clear;
  Project := JvcsActiveProject;
  if Project = nil then
    Exit;
  FN := Project.FileName;
  if FN <> '' then
  begin
    AddDllPath(GUnitList, FN);
    FN := ChangeFileExt(FN, '.res');
    if (GUnitList.IndexOf(FN) < 0) and FileExists(FN) then
      AddDllPath(GUnitList, FN);
  end;
  for I := 0 to Project.ModuleFileCount - 1 do
  begin
    Editor := Project.ModuleFileEditors[I];
    if Editor <> nil then
      AddDllPath(GUnitList, Editor.FileName);
  end;
  for I := 0 to Project.GetModuleCount - 1 do
  begin
    Info := Project.GetModule(I);
    if Info <> nil then
      AddDllPath(GUnitList, Info.FileName);
  end;
end;

// Lista "forms" (0x409214): FileName dos modulos do projeto que tem FormName.
procedure BuildFormList;
var
  Project: IOTAProject;
  I: Integer;
  Info: IOTAModuleInfo;
  FN: string;
begin
  if GFormList = nil then
    GFormList := NewSortedList;
  GFormList.Clear;
  Project := JvcsActiveProject;
  if Project = nil then
    Exit;
  for I := 0 to Project.GetModuleCount - 1 do
  begin
    Info := Project.GetModule(I);
    if Info = nil then
      Continue;
    FN := Info.FileName;
    if (FN <> '') and (Info.FormName <> '') then
      AddDllPath(GFormList, FN);
  end;
end;

function ActionServices: IOTAActionServices;
begin
  if not Supports(BorlandIDEServices, IOTAActionServices, Result) then
    Result := nil;
end;

function FindModuleByName(const AName: string): IOTAModule;
var
  MS: IOTAModuleServices;
begin
  Result := nil;
  if AName = '' then
    Exit;
  MS := JvcsModuleServices;
  if MS <> nil then
    Result := MS.FindModule(AName);
end;

function ReadFileBytes(const AName: string): TBytes;
var
  FS: TFileStream;
begin
  Result := nil;
  FS := TFileStream.Create(AName, fmOpenRead or fmShareDenyNone);
  try
    SetLength(Result, FS.Size);
    if Length(Result) > 0 then
      FS.ReadBuffer(Result[0], Length(Result));
  finally
    FS.Free;
  end;
end;

// Texto ANSI (CP_ACP) do arquivo AName: do editor da IDE se o modulo estiver
// aberto e tiver um editor de fonte para o arquivo; senao do disco.
function LoadAnsiContent(const AName: string; out AContent: AnsiString): Boolean;
var
  Module: IOTAModule;
  Editor: IOTASourceEditor;
begin
  Result := False;
  AContent := '';
  Module := FindModuleByName(AName);
  if Module <> nil then
  begin
    Editor := JvcsFindSourceEditor(Module, AName, False);
    if (Editor = nil) and SameText(Module.FileName, AName) then
      Editor := JvcsFindSourceEditor(Module, '', True);
    if Editor <> nil then
    begin
      AContent := JvcsUtf8BytesToAnsi(JvcsReadEditorUtf8(Editor));
      Exit(True);
    end;
  end;
  if FileExists(AName) then
  begin
    AContent := JvcsFileBytesToAnsi(ReadFileBytes(AName));
    Result := True;
  end;
end;

{ ---- callbacks ---------------------------------------------------------------- }

function CB_CloseProject: Boolean; stdcall;
var
  Scope: TJvcsCallScope;
  Name: string;
  AS_: IOTAActionServices;
  Project: IOTAProject;
begin
  Result := False;
  Scope.Enter(ckIde);
  try
    try
      Name := JvcsProjectNameForDll;
      AS_ := ActionServices;
      if (Name <> '') and (AS_ <> nil) then
      begin
        // como o original: CloseFile(<.dpr>); se a IDE recusar, tenta o .dproj
        Result := AS_.CloseFile(Name);
        if not Result then
        begin
          Project := JvcsActiveProject;
          if (Project <> nil) and not SameText(Project.FileName, Name) then
            Result := AS_.CloseFile(Project.FileName);
        end;
      end;
    except
      JvcsLogCurrentException('CloseProject');
      Result := False;
    end;
  finally
    Scope.Leave;
  end;
end;

function CB_CloseFile(const AFileName: PAnsiChar): Boolean; stdcall;
var
  Scope: TJvcsCallScope;
  AS_: IOTAActionServices;
begin
  Result := False;
  Scope.Enter(ckIde);
  try
    try
      AS_ := ActionServices;
      if AS_ <> nil then
        Result := AS_.CloseFile(JvcsFromAnsi(AFileName));
    except
      JvcsLogCurrentException('CloseFile');
      Result := False;
    end;
  finally
    Scope.Leave;
  end;
end;

function CB_SaveFile(const AFileName: PAnsiChar): Boolean; stdcall;
var
  Scope: TJvcsCallScope;
  AS_: IOTAActionServices;
begin
  Result := False;
  Scope.Enter(ckIde);
  try
    try
      AS_ := ActionServices;
      if AS_ <> nil then
        Result := AS_.SaveFile(JvcsFromAnsi(AFileName));
      JvcsInvalidateSourceCache;
    except
      JvcsLogCurrentException('SaveFile');
      Result := False;
    end;
  finally
    Scope.Leave;
  end;
end;

function CB_OpenFile(const AFileName: PAnsiChar): Boolean; stdcall;
var
  Scope: TJvcsCallScope;
  AS_: IOTAActionServices;
begin
  Result := False;
  Scope.Enter(ckIde);
  try
    try
      AS_ := ActionServices;
      if AS_ <> nil then
        Result := AS_.OpenFile(JvcsFromAnsi(AFileName));
    except
      JvcsLogCurrentException('OpenFile');
      Result := False;
    end;
  finally
    Scope.Leave;
  end;
end;

function CB_GetParentHandle: HWND; stdcall;
var
  Scope: TJvcsCallScope;
begin
  Scope.Enter(ckIde);
  try
    try
      Result := JvcsIdeParentHandle;
    except
      JvcsLogCurrentException('GetParentHandle');
      Result := 0;
    end;
  finally
    Scope.Leave;
  end;
end;

procedure CB_GetProjectName(AProjectName: PAnsiChar); stdcall;
var
  Scope: TJvcsCallScope;
begin
  if AProjectName = nil then
    Exit;
  AProjectName^ := #0;
  Scope.Enter(ckIde);
  try
    try
      JvcsCopyPathToAnsiBuffer(AProjectName, JvcsProjectNameForDll, cDllNameBufferMaxLen);
    except
      JvcsLogCurrentException('GetProjectName');
      AProjectName^ := #0;
    end;
  finally
    Scope.Leave;
  end;
end;

function CB_GetUnitCount: Integer; stdcall;
var
  Scope: TJvcsCallScope;
begin
  Scope.Enter(ckIde);
  try
    try
      // como o original: GetUnitCount sempre reconstroi a lista
      BuildUnitList;
      Result := GUnitList.Count;
    except
      JvcsLogCurrentException('GetUnitCount');
      Result := 0;
    end;
  finally
    Scope.Leave;
  end;
end;

procedure CB_GetUnitName(const AIndex: Integer; AUnitName: PAnsiChar); stdcall;
var
  Scope: TJvcsCallScope;
begin
  if AUnitName = nil then
    Exit;
  AUnitName^ := #0;
  Scope.Enter(ckIde);
  try
    try
      // como o original: GetUnitName usa a lista da ultima GetUnitCount
      if GUnitList = nil then
        BuildUnitList;
      if (AIndex >= 0) and (AIndex < GUnitList.Count) then
        JvcsCopyPathToAnsiBuffer(AUnitName, GUnitList[AIndex], cDllNameBufferMaxLen);
    except
      JvcsLogCurrentException('GetUnitName');
      AUnitName^ := #0;
    end;
  finally
    Scope.Leave;
  end;
end;

function CB_GetFormCount: Integer; stdcall;
var
  Scope: TJvcsCallScope;
begin
  Scope.Enter(ckIde);
  try
    try
      BuildFormList;
      Result := GFormList.Count;
    except
      JvcsLogCurrentException('GetFormCount');
      Result := 0;
    end;
  finally
    Scope.Leave;
  end;
end;

procedure CB_GetFormName(const AIndex: Integer; AFormName: PAnsiChar); stdcall;
var
  Scope: TJvcsCallScope;
begin
  if AFormName = nil then
    Exit;
  AFormName^ := #0;
  Scope.Enter(ckIde);
  try
    try
      if GFormList = nil then
        BuildFormList;
      if (AIndex >= 0) and (AIndex < GFormList.Count) then
        JvcsCopyPathToAnsiBuffer(AFormName, GFormList[AIndex], cDllNameBufferMaxLen);
    except
      JvcsLogCurrentException('GetFormName');
      AFormName^ := #0;
    end;
  finally
    Scope.Leave;
  end;
end;

procedure CB_GetCurrentFile(ACurrentFile: PAnsiChar); stdcall;
var
  Scope: TJvcsCallScope;
  MS: IOTAModuleServices;
  Module: IOTAModule;
  FN: string;
begin
  if ACurrentFile = nil then
    Exit;
  ACurrentFile^ := #0;
  Scope.Enter(ckIde);
  try
    try
      FN := '';
      MS := JvcsModuleServices;
      if MS <> nil then
      begin
        Module := MS.CurrentModule;
        if Module <> nil then
          FN := Module.FileName;
      end;
      JvcsCopyPathToAnsiBuffer(ACurrentFile, FN, cDllNameBufferMaxLen);
    except
      JvcsLogCurrentException('GetCurrentFile');
      ACurrentFile^ := #0;
    end;
  finally
    Scope.Leave;
  end;
end;

function CB_IsFileOpen(const AFileName: PAnsiChar): Boolean; stdcall;
var
  Scope: TJvcsCallScope;
begin
  Scope.Enter(ckIde);
  try
    try
      Result := FindModuleByName(JvcsFromAnsi(AFileName)) <> nil;
    except
      JvcsLogCurrentException('IsFileOpen');
      Result := False;
    end;
  finally
    Scope.Leave;
  end;
end;

function PackageServices: IOTAPackageServices;
begin
  if not Supports(BorlandIDEServices, IOTAPackageServices, Result) then
    Result := nil;
end;

// GetModuleCount/Name e GetComponentCount/Name: semantica da antiga ToolIntf
// (pacotes instalados e seus componentes), como no original.
function CB_GetModuleCount: Integer; stdcall;
var
  Scope: TJvcsCallScope;
  PS: IOTAPackageServices;
begin
  Result := 0;
  Scope.Enter(ckIde);
  try
    try
      PS := PackageServices;
      if PS <> nil then
        Result := PS.PackageCount;
    except
      JvcsLogCurrentException('GetModuleCount');
      Result := 0;
    end;
  finally
    Scope.Leave;
  end;
end;

procedure CB_GetModuleName(const AIndex: Integer; AModuleName: PAnsiChar); stdcall;
var
  Scope: TJvcsCallScope;
  PS: IOTAPackageServices;
begin
  if AModuleName = nil then
    Exit;
  AModuleName^ := #0;
  Scope.Enter(ckIde);
  try
    try
      PS := PackageServices;
      if (PS <> nil) and (AIndex >= 0) and (AIndex < PS.PackageCount) then
        JvcsCopyToAnsiBuffer(AModuleName, PS.PackageNames[AIndex], cDllNameBufferMaxLen);
    except
      JvcsLogCurrentException('GetModuleName');
      AModuleName^ := #0;
    end;
  finally
    Scope.Leave;
  end;
end;

function CB_GetComponentCount(const AModIndex: Integer): Integer; stdcall;
var
  Scope: TJvcsCallScope;
  PS: IOTAPackageServices;
begin
  Result := 0;
  Scope.Enter(ckIde);
  try
    try
      PS := PackageServices;
      if (PS <> nil) and (AModIndex >= 0) and (AModIndex < PS.PackageCount) then
        Result := PS.ComponentCount[AModIndex];
    except
      JvcsLogCurrentException('GetComponentCount');
      Result := 0;
    end;
  finally
    Scope.Leave;
  end;
end;

procedure CB_GetComponentName(const AModIndex, ACompIndex: Integer;
  AComponentName: PAnsiChar); stdcall;
var
  Scope: TJvcsCallScope;
  PS: IOTAPackageServices;
begin
  if AComponentName = nil then
    Exit;
  AComponentName^ := #0;
  Scope.Enter(ckIde);
  try
    try
      PS := PackageServices;
      if (PS <> nil) and (AModIndex >= 0) and (AModIndex < PS.PackageCount) and
        (ACompIndex >= 0) and (ACompIndex < PS.ComponentCount[AModIndex]) then
        JvcsCopyToAnsiBuffer(AComponentName, PS.ComponentNames[AModIndex, ACompIndex],
          cDllNameBufferMaxLen);
    except
      JvcsLogCurrentException('GetComponentName');
      AComponentName^ := #0;
    end;
  finally
    Scope.Leave;
  end;
end;

// O original NAO levanta excecao: mostra MessageBox (a DLL chama isto a partir
// do seu HandleException). Mantido, mas a MESMA mensagem repetida em menos de
// cRaiseRepeatMs (contados do fechamento da caixa anterior) so vai para o log:
// um erro em GetVerbState, chamado pelo OnUpdate a cada segundo, geraria uma
// MessageBox atras da outra.
procedure CB_RaiseException(const AMessage: PAnsiChar); stdcall;
var
  Scope: TJvcsCallScope;
  Msg: string;
begin
  Scope.Enter(ckIde);
  try
    try
      Msg := JvcsFromAnsi(AMessage);
      if (GLastRaiseTick <> 0) and (Msg = GLastRaiseMsg) and
        (GetTickCount64 - GLastRaiseTick < cRaiseRepeatMs) then
      begin
        JvcsLog('RaiseException (DLL, repetida - sem MessageBox): ' + Msg);
        Exit;
      end;
      JvcsLog('RaiseException (DLL): ' + Msg);
      GLastRaiseMsg := Msg;
      GLastRaiseTick := GetTickCount64;
      MessageBox(JvcsIdeParentHandle, PChar(Msg), 'JEDI VCS - Application Error',
        MB_OK or MB_ICONERROR);
      GLastRaiseTick := GetTickCount64;
    except
      JvcsLogCurrentException('RaiseException');
    end;
  finally
    Scope.Leave;
  end;
end;

procedure CB_GetBaseRegistryKey(ABaseRegistryKey: PAnsiChar); stdcall;
var
  Scope: TJvcsCallScope;
  Services: IOTAServices;
begin
  if ABaseRegistryKey = nil then
    Exit;
  ABaseRegistryKey^ := #0;
  Scope.Enter(ckIde);
  try
    try
      if Supports(BorlandIDEServices, IOTAServices, Services) then
        JvcsCopyToAnsiBuffer(ABaseRegistryKey, Services.GetBaseRegistryKey,
          cDllNameBufferMaxLen);
    except
      JvcsLogCurrentException('GetBaseRegistryKey');
      ABaseRegistryKey^ := #0;
    end;
  finally
    Scope.Leave;
  end;
end;

function RootComponentOf(const AName: string): IOTAComponent;
var
  Module: IOTAModule;
  FormEditor: IOTAFormEditor;
begin
  Result := nil;
  Module := FindModuleByName(AName);
  if Module = nil then
    Exit;
  FormEditor := JvcsFindFormEditor(Module);
  if FormEditor <> nil then
    Result := FormEditor.GetRootComponent;
end;

function CB_GetModuleComponentCount(const AModuleName: PAnsiChar): Integer; stdcall;
var
  Scope: TJvcsCallScope;
  Root: IOTAComponent;
begin
  Result := 0;
  Scope.Enter(ckIde);
  try
    try
      Root := RootComponentOf(JvcsFromAnsi(AModuleName));
      if Root <> nil then
        Result := Root.GetComponentCount;
    except
      JvcsLogCurrentException('GetModuleComponentCount');
      Result := 0;
    end;
  finally
    Scope.Leave;
  end;
end;

function CB_GetModuleComponent(const AModuleName: PAnsiChar; const AIndex: Integer;
  ACompName, ACompType: PAnsiChar): Boolean; stdcall;
var
  Scope: TJvcsCallScope;
  Root, Comp: IOTAComponent;
  NTAComp: INTAComponent;
  CompName, CompType: string;
begin
  Result := False;
  if ACompName <> nil then
    ACompName^ := #0;
  if ACompType <> nil then
    ACompType^ := #0;
  Scope.Enter(ckIde);
  try
    try
      Root := RootComponentOf(JvcsFromAnsi(AModuleName));
      if (Root <> nil) and (AIndex >= 0) and (AIndex < Root.GetComponentCount) then
      begin
        Comp := Root.GetComponent(AIndex);
        if Comp <> nil then
        begin
          CompType := Comp.GetComponentType;
          CompName := '';
          if Supports(Comp, INTAComponent, NTAComp) and (NTAComp.GetComponent <> nil) then
            CompName := NTAComp.GetComponent.Name
          else if not Comp.GetPropValueByName('Name', CompName) then
            CompName := '';
          JvcsCopyToAnsiBuffer(ACompName, CompName, cDllNameBufferMaxLen);
          JvcsCopyToAnsiBuffer(ACompType, CompType, cDllNameBufferMaxLen);
          Result := True;
        end;
      end;
    except
      JvcsLogCurrentException('GetModuleComponent');
      Result := False;
    end;
  finally
    Scope.Leave;
  end;
end;

// A DLL insere sempre na posicao 0 (marcacao de check-in no inicio do fonte).
// APos (posicao no texto ANSI) e convertida para posicao em bytes UTF-8.
function CB_SourceWriteString(const AModuleName: PAnsiChar; const APos: Integer;
  const AContent: PAnsiChar): Boolean; stdcall;
var
  Scope: TJvcsCallScope;
  Name: string;
  Module: IOTAModule;
  Editor: IOTASourceEditor;
  Writer: IOTAEditWriter;
  Ansi, Prefix: AnsiString;
  Utf8Pos: Integer;
  Text: UTF8String;
begin
  Result := False;
  Scope.Enter(ckIde);
  try
    try
      Name := JvcsFromAnsi(AModuleName);
      Module := FindModuleByName(Name);
      if Module = nil then
        Exit;
      Editor := JvcsFindSourceEditor(Module, Name, SameText(Module.FileName, Name));
      if Editor = nil then
        Exit;
      Utf8Pos := 0;
      if APos > 0 then
      begin
        Ansi := JvcsUtf8BytesToAnsi(JvcsReadEditorUtf8(Editor));
        Prefix := Copy(Ansi, 1, APos);
        Utf8Pos := Length(UTF8Encode(string(Prefix)));
      end;
      Text := UTF8Encode(JvcsFromAnsi(AContent));
      Writer := Editor.CreateUndoableWriter;
      if Writer = nil then
        Exit;
      try
        Writer.CopyTo(Utf8Pos);
        Writer.Insert(PAnsiChar(Text));
      finally
        Writer := nil;
      end;
      JvcsInvalidateSourceCache;
      Result := True;
    except
      JvcsLogCurrentException('SourceWriteString');
      Result := False;
    end;
  finally
    Scope.Leave;
  end;
end;

// A DLL le em blocos (2048) a partir de APos = 0 ate receber menos que
// AReadSize. O buffer AContent tem AReadSize + 1 bytes.
function CB_SourceReadString(const AModuleName: PAnsiChar; const APos: Integer;
  AContent: PAnsiChar; const AReadSize: Integer): Integer; stdcall;
var
  Scope: TJvcsCallScope;
  Name: string;
  Data: AnsiString;
  Avail: Integer;
begin
  Result := 0;
  if AContent = nil then
    Exit;
  AContent^ := #0;
  if (AReadSize <= 0) or (APos < 0) then
    Exit;
  Scope.Enter(ckIde);
  try
    try
      Name := JvcsFromAnsi(AModuleName);
      if (APos = 0) or not SameText(Name, GSrcCacheName) or
        (GetTickCount64 - GSrcCacheTick > cSrcCacheTimeoutMs) then
      begin
        JvcsInvalidateSourceCache;
        if not LoadAnsiContent(Name, Data) then
          Exit;
        GSrcCacheName := Name;
        GSrcCacheData := Data;
      end;
      GSrcCacheTick := GetTickCount64;
      Avail := Length(GSrcCacheData) - APos;
      if Avail <= 0 then
        Exit(0);
      if Avail > AReadSize then
        Avail := AReadSize;
      Move(PAnsiChar(GSrcCacheData)[APos], AContent^, Avail);
      AContent[Avail] := #0;
      Result := Avail;
    except
      JvcsLogCurrentException('SourceReadString');
      AContent^ := #0;
      Result := 0;
    end;
  finally
    Scope.Leave;
  end;
end;

// [ioSupportsShortCuts]: a DLL nao instala o hook de teclado antigo
// (SetWindowsHookEx); os atalhos vem do IOTAKeyboardBinding do expert.
function CB_GetOptions: TIDEInterfaceOptions; stdcall;
begin
  Result := [ioSupportsShortCuts];
end;

function CB_IsFileOpenAndWriteable(const AFileName: PAnsiChar): Boolean; stdcall;
var
  Scope: TJvcsCallScope;
  Name: string;
  Module: IOTAModule;
  Editor: IOTASourceEditor;
  Buffer: IOTAEditBuffer;
  Attr: DWORD;
begin
  Result := False;
  Scope.Enter(ckIde);
  try
    try
      Name := JvcsFromAnsi(AFileName);
      Module := FindModuleByName(Name);
      if Module = nil then
        Exit;
      Editor := JvcsFindSourceEditor(Module, Name, SameText(Module.FileName, Name));
      if Supports(Editor, IOTAEditBuffer, Buffer) then
        Result := not Buffer.IsReadOnly
      else
      begin
        // sem buffer de edicao (ex.: .dfm aberto): atributo do arquivo
        Attr := GetFileAttributes(PChar(Name));
        Result := (Attr <> INVALID_FILE_ATTRIBUTES) and ((Attr and FILE_ATTRIBUTE_READONLY) = 0);
      end;
    except
      JvcsLogCurrentException('IsFileOpenAndWriteable');
      Result := False;
    end;
  finally
    Scope.Leave;
  end;
end;

procedure JvcsFillIDEFunctionRec(var ARec: TExternalIDEFunctionRec);
begin
  FillChar(ARec, SizeOf(ARec), 0);
  ARec.CloseProject := CB_CloseProject;
  ARec.CloseFile := CB_CloseFile;
  ARec.SaveFile := CB_SaveFile;
  ARec.OpenFile := CB_OpenFile;
  ARec.GetParentHandle := CB_GetParentHandle;
  ARec.GetProjectName := CB_GetProjectName;
  ARec.GetUnitCount := CB_GetUnitCount;
  ARec.GetUnitName := CB_GetUnitName;
  ARec.GetFormCount := CB_GetFormCount;
  ARec.GetFormName := CB_GetFormName;
  ARec.GetCurrentFile := CB_GetCurrentFile;
  ARec.IsFileOpen := CB_IsFileOpen;
  ARec.GetModuleCount := CB_GetModuleCount;
  ARec.GetModuleName := CB_GetModuleName;
  ARec.GetComponentCount := CB_GetComponentCount;
  ARec.GetComponentName := CB_GetComponentName;
  ARec.RaiseException := CB_RaiseException;
  ARec.GetBaseRegistryKey := CB_GetBaseRegistryKey;
  ARec.GetModuleComponentCount := CB_GetModuleComponentCount;
  ARec.GetModuleComponent := CB_GetModuleComponent;
  ARec.SourceWriteString := CB_SourceWriteString;
  ARec.SourceReadString := CB_SourceReadString;
  ARec.GetOptions := CB_GetOptions;
  ARec.IsFileOpenAndWriteable := CB_IsFileOpenAndWriteable;
end;

initialization

finalization
  JvcsReleaseCallbackCaches;

end.
