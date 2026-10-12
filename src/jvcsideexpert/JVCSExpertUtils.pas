(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSExpertUtils.pas (JEDI VCS v2026)

-----------------------------------------------------------------------------

Unit JVCSExpertUtils - utilitarios do expert de IDE

  - log (OutputDebugString + arquivo opcional via JVCS_EXPERT_LOG);
  - conversoes UnicodeString <-> AnsiString (CP_ACP) e copia LIMITADA para os
    buffers PAnsiChar de 256 bytes da DLL (cDllNameBufferMaxLen + #0);
  - UTF-8 do editor -> ANSI (com fallback se o buffer nao for UTF-8 valido);
  - TJvcsCallScope: guarda de fronteira (palavra de controle da FPU/MXCSR e
    contexto de DPI por thread) para chamadas IDE -> DLL e DLL -> IDE;
  - descricao segura de excecoes (nao toca em objetos de excecao do RTL do
    Delphi 2007 que vem da JvcsExternalDll);
  - helpers de ToolsAPI (projeto ativo, .dproj -> .dpr/.dpk, editores).

  Historico:
  2026/10/12  v2026 - nova unit
-----------------------------------------------------------------------------*)

unit JVCSExpertUtils;

// Get8087CW/GetMXCSR e a guarda de FPU sao especificos de Win32 (x86) - o
// expert so existe para a IDE de 32 bits.
{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, ToolsAPI;

const
  cJvcsCaption = 'JEDI VCS';

{ ---- log ------------------------------------------------------------------ }

procedure JvcsLog(const AMsg: string);
procedure JvcsLogFmt(const AFmt: string; const AArgs: array of const);
// Registra a excecao corrente (ExceptObject) com o contexto AWhere.
procedure JvcsLogCurrentException(const AWhere: string);
// Descricao segura do objeto de excecao. Objetos cuja VMT esta na
// JvcsExternalDll (RTL do Delphi 2007) NAO sao inspecionados.
function JvcsDescribeException(AObj: TObject): string;

{ ---- strings / buffers ----------------------------------------------------- }

// PAnsiChar (CP_ACP) vindo da DLL -> string
function JvcsFromAnsi(P: PAnsiChar): string;
// string -> AnsiString (CP_ACP) SEM "best fit": caracteres fora da pagina de
// codigo viram '?' (invalido em caminho - a DLL falha em vez de operar em
// outro arquivo; AnsiString(S) trocaria 'L-barrado' por 'L', etc.).
// AExact = False se algum caractere virou '?' (ou a conversao falhou).
function JvcsToAnsiEx(const S: string; out AExact: Boolean): AnsiString;
function JvcsToAnsi(const S: string): AnsiString;
// Copia S (convertida para CP_ACP) para ADest, no maximo AMaxLen bytes + #0.
// Corta sem quebrar caractere DBCS. Devolve True se coube inteira.
// Para TEXTO (nomes de pacote/componente, chave de registro).
function JvcsCopyToAnsiBuffer(ADest: PAnsiChar; const S: string;
  AMaxLen: Integer): Boolean;
// True se o CAMINHO S cabe inteiro em AMaxLen bytes ANSI.
function JvcsPathFitsAnsiBuffer(const S: string; AMaxLen: Integer): Boolean;
// Copia um CAMINHO para ADest: se nao couber em AMaxLen bytes, escreve ''
// (e registra no log) em vez de truncar - um caminho cortado e OUTRO caminho
// valido para a DLL. Devolve True se copiou.
function JvcsCopyPathToAnsiBuffer(ADest: PAnsiChar; const S: string;
  AMaxLen: Integer): Boolean;
// Bytes UTF-8 (editor da IDE) -> AnsiString CP_ACP. Se os bytes nao forem
// UTF-8 valido, sao devolvidos sem conversao (ja eram ANSI).
function JvcsUtf8BytesToAnsi(const AUtf8: RawByteString): AnsiString;
// Bytes de um arquivo em disco -> AnsiString CP_ACP (detecta BOM UTF-8/UTF-16)
function JvcsFileBytesToAnsi(const ABytes: TBytes): AnsiString;

{ ---- fronteira IDE <-> DLL --------------------------------------------------- }

type
  // ckDll   = chamada para a DLL sem UI (verbos, estados, imagens)
  // ckDllUI = chamada para a DLL que pode criar janelas (ExecuteVerb,
  //           notificacoes, operacoes, INIT/FINALIZE)
  // ckIde   = callback da DLL entrando no expert/IDE
  TJvcsCallKind = (ckDll, ckDllUI, ckIde);

  TJvcsCallScope = record
  private
    FKind: TJvcsCallKind;
    FFpuCW: Word;
    FMXCSR: UInt32;
    FDpiPrev: THandle;
    FDpiChanged: Boolean;
  public
    procedure Enter(AKind: TJvcsCallKind);
    procedure Leave;
  end;

// Captura o contexto de DPI da IDE (chamar na thread principal, no init) e
// le JVCS_EXPERT_DPI (off | unaware | gdiscaled[padrao]).
procedure JvcsInitDpiSupport;
function JvcsDpiModeDescription: string;

var
  // HMODULE da JvcsExternalDll carregada (0 se nenhuma) - usado para nao
  // inspecionar objetos de excecao do RTL antigo.
  JvcsExternalModule: HMODULE = 0;

{ ---- thread principal ------------------------------------------------------ }

procedure JvcsRunInMainThread(const AProc: TThreadProcedure);

{ ---- ToolsAPI --------------------------------------------------------------- }

function JvcsModuleServices: IOTAModuleServices;
function JvcsIdeParentHandle: HWND;
// Projeto ativo (grupo -> ActiveProject; senao IOTAModuleServices.GetActiveProject;
// senao varre os modulos: grupo ou projeto unico) - como o expert BDS21.
function JvcsActiveProject: IOTAProject;
// Nome do projeto como a DLL espera: para Delphi.Personality o .dpr/.dpk
// (editor do modulo do projeto), senao IOTAProject.FileName (.dproj etc.).
function JvcsProjectSourceName(const AProject: IOTAProject): string;
// Modulo aberto cujo FileName = AFileName (varredura, como o original)
function JvcsFindOpenModule(const AFileName: string): IOTAModule;
// Editor de fonte do modulo: o que tem FileName = AFileName; senao, se
// AAllowFirst, o primeiro IOTASourceEditor do modulo.
function JvcsFindSourceEditor(const AModule: IOTAModule; const AFileName: string;
  AAllowFirst: Boolean): IOTASourceEditor;
function JvcsFindFormEditor(const AModule: IOTAModule): IOTAFormEditor;
// Conteudo completo de um editor (bytes UTF-8 de IOTAEditReader)
function JvcsReadEditorUtf8(const AEditor: IOTASourceEditor): RawByteString;

implementation

uses
  System.SyncObjs;

{ ---- log ------------------------------------------------------------------ }

var
  GLogLock: TCriticalSection = nil;
  GLogFile: string = '';
  GLogFileRead: Boolean = False;

procedure JvcsLog(const AMsg: string);
var
  Line: string;
  Bytes: TBytes;
  FS: TFileStream;
begin
  try
    Line := FormatDateTime('hh:nn:ss.zzz', Now) + ' [' + IntToStr(GetCurrentThreadId) + '] ' + AMsg;
    OutputDebugString(PChar('[JVCS Expert] ' + Line));
    if not GLogFileRead then
    begin
      GLogFile := Trim(GetEnvironmentVariable('JVCS_EXPERT_LOG'));
      GLogFileRead := True;
    end;
    if (GLogFile <> '') and Assigned(GLogLock) then
    begin
      GLogLock.Enter;
      try
        Bytes := TEncoding.UTF8.GetBytes(Line + sLineBreak);
        if FileExists(GLogFile) then
          FS := TFileStream.Create(GLogFile, fmOpenReadWrite or fmShareDenyNone)
        else
          FS := TFileStream.Create(GLogFile, fmCreate or fmShareDenyNone);
        try
          FS.Seek(0, soEnd);
          if Length(Bytes) > 0 then
            FS.WriteBuffer(Bytes[0], Length(Bytes));
        finally
          FS.Free;
        end;
      finally
        GLogLock.Leave;
      end;
    end;
  except
    // log nunca pode derrubar a IDE
  end;
end;

procedure JvcsLogFmt(const AFmt: string; const AArgs: array of const);
begin
  try
    JvcsLog(Format(AFmt, AArgs));
  except
    JvcsLog(AFmt);
  end;
end;

const
  cGET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT = $00000002;
  cGET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS = $00000004;

function GetModuleHandleEx(dwFlags: DWORD; lpModuleName: PWideChar;
  var phModule: HMODULE): BOOL; stdcall; external kernel32 name 'GetModuleHandleExW';

function JvcsDescribeException(AObj: TObject): string;
var
  VMT: Pointer;
  Module: HMODULE;
begin
  if AObj = nil then
    Exit('(excecao sem objeto)');
  try
    VMT := PPointer(AObj)^;
    Module := 0;
    if GetModuleHandleEx(cGET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS or
      cGET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT, PChar(VMT), Module) then
    begin
      if (JvcsExternalModule <> 0) and (Module = JvcsExternalModule) then
        Exit('excecao originada na JvcsExternalDll (objeto do RTL Delphi 2007 - nao inspecionado)');
    end
    else
      Exit('excecao com objeto de modulo desconhecido');
    // Objeto de outro RTL (ex.: Delphi 2007 de um terceiro modulo): o layout
    // da VMT e outro e vmtSelfPtr nao aponta para a propria VMT.
    if PPointer(PByte(VMT) + vmtSelfPtr)^ <> VMT then
      Exit('excecao com objeto de outro RTL (VMT incompativel - nao inspecionado)');
    if AObj is Exception then
      Result := AObj.ClassName + ': ' + Exception(AObj).Message
    else
      Result := AObj.ClassName;
  except
    Result := '(excecao nao identificavel)';
  end;
end;

procedure JvcsLogCurrentException(const AWhere: string);
begin
  try
    JvcsLog('ERRO em ' + AWhere + ': ' + JvcsDescribeException(ExceptObject));
  except
  end;
end;

{ ---- strings / buffers ----------------------------------------------------- }

function JvcsFromAnsi(P: PAnsiChar): string;
var
  A: AnsiString;
begin
  if (P = nil) or (P^ = #0) then
    Exit('');
  A := AnsiString(P);
  Result := string(A);
end;

const
  cWC_NO_BEST_FIT_CHARS = $00000400;

function JvcsToAnsiEx(const S: string; out AExact: Boolean): AnsiString;
var
  N: Integer;
  Flags: DWORD;
  UsedDefault: BOOL;
  PUsed: PBOOL;
begin
  Result := '';
  AExact := True;
  if S = '' then
    Exit;
  // CP_ACP = UTF-8 (opcao "Beta: UTF-8" do Windows) nao aceita flags nem
  // lpUsedDefaultChar; nesse caso tudo e representavel.
  if GetACP = CP_UTF8 then
  begin
    Flags := 0;
    PUsed := nil;
  end
  else
  begin
    Flags := cWC_NO_BEST_FIT_CHARS;
    PUsed := @UsedDefault;
  end;
  UsedDefault := False;
  N := WideCharToMultiByte(CP_ACP, Flags, PWideChar(S), Length(S), nil, 0, nil, PUsed);
  if (N <= 0) and (Flags <> 0) then
  begin
    // pagina de codigo que nao aceita a flag: conversao padrao
    Flags := 0;
    PUsed := nil;
    N := WideCharToMultiByte(CP_ACP, 0, PWideChar(S), Length(S), nil, 0, nil, nil);
  end;
  if N <= 0 then
  begin
    AExact := False;
    Exit;
  end;
  SetLength(Result, N);
  UsedDefault := False;
  N := WideCharToMultiByte(CP_ACP, Flags, PWideChar(S), Length(S),
    PAnsiChar(Result), N, nil, PUsed);
  if N <= 0 then
  begin
    Result := '';
    AExact := False;
    Exit;
  end;
  SetLength(Result, N);
  AExact := not UsedDefault;
end;

function JvcsToAnsi(const S: string): AnsiString;
var
  Exact: Boolean;
begin
  Result := JvcsToAnsiEx(S, Exact);
  if not Exact then
    JvcsLogFmt('aviso: caracteres fora de CP_ACP (%d) viraram "?" para a DLL: "%s"',
      [GetACP, Copy(S, 1, 200)]);
end;

// Maior prefixo de A (em bytes) <= AMaxLen que nao corta um caractere DBCS.
function DbcsSafePrefixLen(const A: AnsiString; AMaxLen: Integer): Integer;
var
  I, Step, Len: Integer;
begin
  Len := Length(A);
  if Len <= AMaxLen then
    Exit(Len);
  Result := 0;
  I := 1;
  while I <= Len do
  begin
    if IsDBCSLeadByte(Byte(A[I])) and (I < Len) then
      Step := 2
    else
      Step := 1;
    if Result + Step > AMaxLen then
      Break;
    Inc(Result, Step);
    Inc(I, Step);
  end;
end;

function JvcsCopyToAnsiBuffer(ADest: PAnsiChar; const S: string;
  AMaxLen: Integer): Boolean;
var
  A: AnsiString;
  L: Integer;
begin
  Result := False;
  if ADest = nil then
    Exit;
  if AMaxLen < 0 then
    AMaxLen := 0;
  A := JvcsToAnsi(S);
  L := DbcsSafePrefixLen(A, AMaxLen);
  if L > 0 then
    Move(PAnsiChar(A)^, ADest^, L);
  ADest[L] := #0;
  Result := L = Length(A);
  if not Result then
    JvcsLogFmt('aviso: texto de %d caracteres truncado em %d bytes para o buffer da DLL: "%s..."',
      [Length(S), AMaxLen, Copy(S, 1, 120)]);
end;

function JvcsPathFitsAnsiBuffer(const S: string; AMaxLen: Integer): Boolean;
var
  Exact: Boolean;
begin
  Result := Length(JvcsToAnsiEx(S, Exact)) <= AMaxLen;
end;

function JvcsCopyPathToAnsiBuffer(ADest: PAnsiChar; const S: string;
  AMaxLen: Integer): Boolean;
var
  A: AnsiString;
  L: Integer;
begin
  Result := False;
  if ADest = nil then
    Exit;
  ADest^ := #0;
  if AMaxLen < 0 then
    AMaxLen := 0;
  A := JvcsToAnsi(S);
  L := Length(A);
  if L > AMaxLen then
  begin
    JvcsLogFmt('aviso: caminho de %d bytes nao cabe no buffer de %d da DLL - devolvido vazio: "%s"',
      [L, AMaxLen + 1, S]);
    Exit;
  end;
  if L > 0 then
    Move(PAnsiChar(A)^, ADest^, L);
  ADest[L] := #0;
  Result := True;
end;

function WideToAnsi(P: PWideChar; Len: Integer): AnsiString;
var
  N: Integer;
begin
  Result := '';
  if Len <= 0 then
    Exit;
  N := WideCharToMultiByte(CP_ACP, 0, P, Len, nil, 0, nil, nil);
  if N <= 0 then
    Exit;
  SetLength(Result, N);
  WideCharToMultiByte(CP_ACP, 0, P, Len, PAnsiChar(Result), N, nil, nil);
end;

function JvcsUtf8BytesToAnsi(const AUtf8: RawByteString): AnsiString;
var
  WLen: Integer;
  W: UnicodeString;
  P: PAnsiChar;
  L: Integer;
begin
  Result := '';
  L := Length(AUtf8);
  if L = 0 then
    Exit;
  P := PAnsiChar(Pointer(AUtf8));
  // pula BOM UTF-8, se houver
  if (L >= 3) and (P[0] = #$EF) and (P[1] = #$BB) and (P[2] = #$BF) then
  begin
    Inc(P, 3);
    Dec(L, 3);
    if L = 0 then
      Exit;
  end;
  WLen := MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, P, L, nil, 0);
  if WLen <= 0 then
  begin
    // nao e UTF-8 valido: devolve os bytes como estao (ja eram ANSI)
    SetLength(Result, L);
    Move(P^, PAnsiChar(Result)^, L);
    Exit;
  end;
  SetLength(W, WLen);
  MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, P, L, PWideChar(W), WLen);
  Result := WideToAnsi(PWideChar(W), WLen);
end;

function JvcsFileBytesToAnsi(const ABytes: TBytes): AnsiString;
var
  L: Integer;
  Raw: RawByteString;
begin
  Result := '';
  L := Length(ABytes);
  if L = 0 then
    Exit;
  if (L >= 2) and (ABytes[0] = $FF) and (ABytes[1] = $FE) then
  begin
    // UTF-16 LE
    Result := WideToAnsi(PWideChar(@ABytes[2]), (L - 2) div 2);
    Exit;
  end;
  if (L >= 2) and (ABytes[0] = $FE) and (ABytes[1] = $FF) then
  begin
    // UTF-16 BE: converte via TEncoding
    Result := AnsiString(TEncoding.BigEndianUnicode.GetString(ABytes, 2, L - 2));
    Exit;
  end;
  if (L >= 3) and (ABytes[0] = $EF) and (ABytes[1] = $BB) and (ABytes[2] = $BF) then
  begin
    SetLength(Raw, L);
    Move(ABytes[0], PAnsiChar(Raw)^, L);
    Result := JvcsUtf8BytesToAnsi(Raw);
    Exit;
  end;
  // sem BOM: arquivo ANSI (comportamento do cliente original)
  SetLength(Result, L);
  Move(ABytes[0], PAnsiChar(Result)^, L);
end;

{ ---- FPU / DPI ------------------------------------------------------------- }

{$IFDEF CPUX86}
procedure LoadFpuCW(ACW: Word);
asm
  PUSH    EAX
  FNCLEX
  FLDCW   WORD PTR [ESP]
  POP     EAX
end;

procedure LoadMXCSR(AValue: UInt32);
asm
  PUSH    EAX
  LDMXCSR DWORD PTR [ESP]
  POP     EAX
end;
{$ENDIF CPUX86}

type
  TJvcsDpiContext = THandle;
  TSetThreadDpiAwarenessContext = function(AContext: TJvcsDpiContext): TJvcsDpiContext; stdcall;
  TGetThreadDpiAwarenessContext = function: TJvcsDpiContext; stdcall;
  TIsValidDpiAwarenessContext = function(AContext: TJvcsDpiContext): BOOL; stdcall;

const
  cDPI_AWARENESS_CONTEXT_UNAWARE = TJvcsDpiContext(-1);
  cDPI_AWARENESS_CONTEXT_UNAWARE_GDISCALED = TJvcsDpiContext(-5);

var
  GSetThreadDpiCtx: TSetThreadDpiAwarenessContext = nil;
  GGetThreadDpiCtx: TGetThreadDpiAwarenessContext = nil;
  GDpiEnabled: Boolean = False;
  GDpiDllContext: TJvcsDpiContext = 0;
  GDpiIdeContext: TJvcsDpiContext = 0;
  GDpiMode: string = 'off';

procedure JvcsInitDpiSupport;
var
  HUser32: HMODULE;
  IsValid: TIsValidDpiAwarenessContext;
  Mode: string;
begin
  GDpiEnabled := False;
  GDpiMode := 'off';
  try
    Mode := LowerCase(Trim(GetEnvironmentVariable('JVCS_EXPERT_DPI')));
    if (Mode = 'off') or (Mode = '0') or (Mode = 'no') or (Mode = 'false') then
    begin
      JvcsLog('DPI: troca de contexto desligada (JVCS_EXPERT_DPI=' + Mode + ')');
      Exit;
    end;
    HUser32 := GetModuleHandle(user32);
    if HUser32 = 0 then
      Exit;
    @GSetThreadDpiCtx := GetProcAddress(HUser32, 'SetThreadDpiAwarenessContext');
    @GGetThreadDpiCtx := GetProcAddress(HUser32, 'GetThreadDpiAwarenessContext');
    @IsValid := GetProcAddress(HUser32, 'IsValidDpiAwarenessContext');
    if not (Assigned(GSetThreadDpiCtx) and Assigned(GGetThreadDpiCtx)) then
    begin
      JvcsLog('DPI: SetThreadDpiAwarenessContext indisponivel (Windows antigo) - sem troca de contexto');
      Exit;
    end;
    GDpiIdeContext := GGetThreadDpiCtx();
    GDpiDllContext := cDPI_AWARENESS_CONTEXT_UNAWARE_GDISCALED;
    GDpiMode := 'gdiscaled';
    if (Mode = 'unaware') or (Assigned(IsValid) and not IsValid(GDpiDllContext)) then
    begin
      GDpiDllContext := cDPI_AWARENESS_CONTEXT_UNAWARE;
      GDpiMode := 'unaware';
    end;
    GDpiEnabled := True;
    JvcsLog('DPI: janelas da JvcsExternalDll em contexto ' + GDpiMode);
  except
    GDpiEnabled := False;
  end;
end;

function JvcsDpiModeDescription: string;
begin
  Result := GDpiMode;
end;

procedure TJvcsCallScope.Enter(AKind: TJvcsCallKind);
begin
  FKind := AKind;
  FDpiChanged := False;
  FDpiPrev := 0;
  {$IFDEF CPUX86}
  FFpuCW := Get8087CW;
  FMXCSR := GetMXCSR;
  {$ENDIF CPUX86}
  if GDpiEnabled and (GetCurrentThreadId = MainThreadID) then
  begin
    case AKind of
      ckDllUI:
        begin
          FDpiPrev := GSetThreadDpiCtx(GDpiDllContext);
          FDpiChanged := FDpiPrev <> 0;
        end;
      ckIde:
        begin
          FDpiPrev := GSetThreadDpiCtx(GDpiIdeContext);
          FDpiChanged := FDpiPrev <> 0;
        end;
    end;
  end;
end;

procedure TJvcsCallScope.Leave;
begin
  if FDpiChanged and Assigned(GSetThreadDpiCtx) then
    GSetThreadDpiCtx(FDpiPrev);
  FDpiChanged := False;
  {$IFDEF CPUX86}
  // A DLL (Delphi 2007) pode deixar a FPU com outra palavra de controle.
  if FKind <> ckIde then
  begin
    if Get8087CW <> FFpuCW then
      LoadFpuCW(FFpuCW);
    if GetMXCSR <> FMXCSR then
      LoadMXCSR(FMXCSR);
  end;
  {$ENDIF CPUX86}
end;

{ ---- thread principal ------------------------------------------------------ }

procedure JvcsRunInMainThread(const AProc: TThreadProcedure);
begin
  if GetCurrentThreadId = MainThreadID then
    AProc()
  else
    TThread.Synchronize(nil,
      procedure
      begin
        AProc();
      end);
end;

{ ---- ToolsAPI --------------------------------------------------------------- }

function JvcsModuleServices: IOTAModuleServices;
begin
  if not Supports(BorlandIDEServices, IOTAModuleServices, Result) then
    Result := nil;
end;

function JvcsIdeParentHandle: HWND;
var
  Services: IOTAServices;
begin
  Result := 0;
  try
    if Supports(BorlandIDEServices, IOTAServices, Services) then
      Result := Services.GetParentHandle;
  except
    Result := 0;
  end;
end;

function JvcsActiveProject: IOTAProject;
var
  MS: IOTAModuleServices;
  Group: IOTAProjectGroup;
  Module: IOTAModule;
  Project: IOTAProject;
  I: Integer;
  Multiple: Boolean;
begin
  Result := nil;
  MS := JvcsModuleServices;
  if MS = nil then
    Exit;
  Group := MS.MainProjectGroup;
  if Group <> nil then
    Result := Group.ActiveProject;
  if Result = nil then
    Result := MS.GetActiveProject;
  if Result <> nil then
    Exit;
  // fallback do expert original: grupo aberto -> projeto ativo; senao o
  // unico projeto aberto (mais de um sem grupo -> nenhum)
  Multiple := False;
  for I := 0 to MS.ModuleCount - 1 do
  begin
    Module := MS.Modules[I];
    if Supports(Module, IOTAProjectGroup, Group) then
    begin
      Result := Group.ActiveProject;
      Exit;
    end;
    if Supports(Module, IOTAProject, Project) then
    begin
      if Result = nil then
        Result := Project
      else
        Multiple := True;
    end;
  end;
  if Multiple then
    Result := nil;
end;

function JvcsProjectSourceName(const AProject: IOTAProject): string;
var
  I: Integer;
  Editor: IOTAEditor;
  Ext: string;
begin
  Result := '';
  if AProject = nil then
    Exit;
  Result := AProject.FileName;
  if SameText(AProject.Personality, sDelphiPersonality) then
    for I := 0 to AProject.ModuleFileCount - 1 do
    begin
      Editor := AProject.ModuleFileEditors[I];
      if Editor = nil then
        Continue;
      Ext := ExtractFileExt(Editor.FileName);
      if SameText(Ext, '.dpr') or SameText(Ext, '.dpk') then
      begin
        Result := Editor.FileName;
        Exit;
      end;
    end;
end;

function JvcsFindOpenModule(const AFileName: string): IOTAModule;
var
  MS: IOTAModuleServices;
  I: Integer;
  Module: IOTAModule;
begin
  Result := nil;
  if AFileName = '' then
    Exit;
  MS := JvcsModuleServices;
  if MS = nil then
    Exit;
  for I := 0 to MS.ModuleCount - 1 do
  begin
    Module := MS.Modules[I];
    if (Module <> nil) and SameText(Module.FileName, AFileName) then
    begin
      Result := Module;
      Exit;
    end;
  end;
end;

function JvcsFindSourceEditor(const AModule: IOTAModule; const AFileName: string;
  AAllowFirst: Boolean): IOTASourceEditor;
var
  I: Integer;
  Editor: IOTAEditor;
  SE, First: IOTASourceEditor;
begin
  Result := nil;
  First := nil;
  if AModule = nil then
    Exit;
  for I := 0 to AModule.ModuleFileCount - 1 do
  begin
    Editor := AModule.ModuleFileEditors[I];
    if Supports(Editor, IOTASourceEditor, SE) then
    begin
      if (AFileName <> '') and SameText(SE.FileName, AFileName) then
      begin
        Result := SE;
        Exit;
      end;
      if First = nil then
        First := SE;
    end;
  end;
  if AAllowFirst then
    Result := First;
end;

function JvcsFindFormEditor(const AModule: IOTAModule): IOTAFormEditor;
var
  I: Integer;
begin
  Result := nil;
  if AModule = nil then
    Exit;
  for I := 0 to AModule.ModuleFileCount - 1 do
    if Supports(AModule.ModuleFileEditors[I], IOTAFormEditor, Result) then
      Exit;
  Result := nil;
end;

function JvcsReadEditorUtf8(const AEditor: IOTASourceEditor): RawByteString;
const
  cChunk = 32768;
var
  Reader: IOTAEditReader;
  Pos, N: Integer;
begin
  Result := '';
  if AEditor = nil then
    Exit;
  Reader := AEditor.CreateReader;
  if Reader = nil then
    Exit;
  Pos := 0;
  repeat
    SetLength(Result, Pos + cChunk);
    N := Reader.GetText(Pos, PAnsiChar(Pointer(Result)) + Pos, cChunk);
    if N < 0 then
      N := 0;
    Inc(Pos, N);
  until N < cChunk;
  SetLength(Result, Pos);
  Reader := nil;
end;

initialization
  GLogLock := TCriticalSection.Create;

finalization
  FreeAndNil(GLogLock);

end.
