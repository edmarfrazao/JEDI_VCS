; ============================================================================
;  JediVCS2026.iss - instalador do JEDI VCS 2.5 Beta 2026 (Inno Setup 6.3+)
;
;  Gera setup\Output\JediVCS-2.5-Beta2026-Setup.exe. Use tools\gerar-instalador.bat
;  (compila Release Win32, confere versoes e chama o ISCC) ou, direto:
;    ISCC.exe setup\JediVCS2026.iss
;
;  Origem dos arquivos (pode ser trocada com /D no ISCC):
;    ClientSrc = bin\client\Win32     Jedivcs.exe, JEDIVCSDiff.exe, jvcs.exe (+ .map)
;    IdeSrc    = bin\ideclient\Win32  JvcsExpertBDS<nn>.dll + JvcsExternalDll.dll
;                                     (montada por tools\compilar-expert.bat Release nova)
;    RtSrc     = 3rdparty             fvcscrypt.dll, *.jvcs, htm_rep.htm, *.chm
;    AiSrc     = tools\ai             ferramentas da IA (copiadas byte a byte)
;
;  Expert: entra no pacote todo JvcsExpertBDS22/23/37.dll que existir em IdeSrc
;  (22 = Delphi 11, 23 = Delphi 12, 37 = Delphi 13), sem editar este arquivo.
;  Detalhes, decisoes e testes: setup\LEIAME.md.
; ============================================================================

#define AppName      "JEDI VCS 2.5 Beta 2026"
#define AppVersion   "2.5.0.2026"
#define AppVerText   "2.5 Beta 2026"
#define AppPublisher "Project JEDI - JEDI VCS (port 2026)"
#define AppGuid      "{FA4F41D9-F23B-4C34-8186-DCBB5DD86E45}"

#define Root SourcePath + ".."
#ifndef ClientSrc
  #define ClientSrc Root + "\bin\client\Win32"
#endif
#ifndef IdeSrc
  #define IdeSrc Root + "\bin\ideclient\Win32"
#endif
#ifndef RtSrc
  #define RtSrc Root + "\3rdparty"
#endif
#ifndef AiSrc
  #define AiSrc Root + "\tools\ai"
#endif

; ---- arquivos obrigatorios -------------------------------------------------
#define Req(str F) FileExists(F) ? "" : Error("Arquivo obrigatorio nao encontrado: " + F)
#expr Req(ClientSrc + "\Jedivcs.exe")
#expr Req(ClientSrc + "\JEDIVCSDiff.exe")
#expr Req(ClientSrc + "\jvcs.exe")
#expr Req(IdeSrc + "\JvcsExternalDll.dll")
#expr Req(RtSrc + "\fvcscrypt.dll")
#expr Req(RtSrc + "\jedivcs.chm")
#expr Req(RtSrc + "\jedivcsdiff.chm")
#expr Req(RtSrc + "\htm_rep.htm")
#expr Req(RtSrc + "\ffdef.jvcs")
#expr Req(AiSrc + "\jvcs-ai.ps1")

; ---- experts presentes no pacote (lista "22,23,37,") -----------------------
#define ExpertList ""
#if FileExists(IdeSrc + "\JvcsExpertBDS22.dll")
  #define ExpertList ExpertList + "22,"
#endif
#if FileExists(IdeSrc + "\JvcsExpertBDS23.dll")
  #define ExpertList ExpertList + "23,"
#endif
#if FileExists(IdeSrc + "\JvcsExpertBDS37.dll")
  #define ExpertList ExpertList + "37,"
#endif
#if ExpertList == ""
  #error Nenhum JvcsExpertBDS22/23/37.dll em IdeSrc (rode tools\compilar-expert.bat Release nova)
#endif
#pragma message "Experts no pacote: " + ExpertList

[Setup]
AppId={{#AppGuid}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName}
AppPublisher={#AppPublisher}
AppComments=Cliente JEDI VCS 2.5 portado para Delphi 13.2 (standalone, Diff, console, expert da IDE e ferramentas da IA)
DefaultDirName={autopf32}\JEDI\JVCS 2026
DefaultGroupName=JEDI VCS 2026
DisableProgramGroupPage=auto
DirExistsWarning=no
PrivilegesRequired=admin
PrivilegesRequiredOverridesAllowed=dialog commandline
UsedUserAreasWarning=no
OutputDir=Output
OutputBaseFilename=JediVCS-2.5-Beta2026-Setup
Compression=lzma2/max
SolidCompression=yes
LZMANumBlockThreads=4
WizardStyle=modern
SetupLogging=yes
CloseApplications=yes
RestartApplications=no
UninstallDisplayName={#AppName}
UninstallDisplayIcon={app}\Jedivcs.exe
VersionInfoVersion={#AppVersion}
VersionInfoProductName={#AppName}
VersionInfoProductVersion={#AppVersion}
VersionInfoProductTextVersion={#AppVerText}
VersionInfoTextVersion={#AppVerText}
VersionInfoDescription=Instalador do {#AppName}
VersionInfoCompany={#AppPublisher}

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[CustomMessages]
brazilianportuguese.TypeFull=Instalação completa
brazilianportuguese.TypeCompact=Somente o cliente (standalone, Diff e console)
brazilianportuguese.TypeCustom=Personalizada
brazilianportuguese.CompClient=Cliente standalone (Jedivcs.exe), Diff (JEDIVCSDiff.exe), console (jvcs.exe) e ajuda
brazilianportuguese.CompIde=Expert para o Delphi (menu JEDI VCS na IDE de 32 bits)
brazilianportuguese.CompMaps=Arquivos .map (o log de erros mostra unit e linha)
brazilianportuguese.CompAi=Ferramentas da IA (tools\ai: wrapper, hooks e skill do Claude Code)
brazilianportuguese.TaskAiConsole=Usar o console novo (jvcs.exe desta instalação) na automação por IA (grava jvcsExe no config.ini)
brazilianportuguese.TaskAiGroup=Automação por IA:
brazilianportuguese.IconClient=JEDI VCS 2026
brazilianportuguese.IconDiff=JEDI VCS Diff 2026
brazilianportuguese.IconHelp=Ajuda do JEDI VCS
brazilianportuguese.IconHelpDiff=Ajuda do JEDI VCS Diff
brazilianportuguese.IconToolsAi=Ferramentas da IA (pasta)
brazilianportuguese.RunClient=Abrir o JEDI VCS 2026
brazilianportuguese.IdeDetected=detectado: %1
brazilianportuguese.IdeNone=nenhum Delphi 11/12/13 detectado
brazilianportuguese.CloseDelphi=O Delphi (bds.exe) está aberto.%n%nFeche o Delphi antes de continuar: a IDE regrava o registro dos experts ao fechar e mantém a DLL do expert em uso.%n%nFeche o Delphi e clique em Repetir, ou em Cancelar para sair.
brazilianportuguese.CloseDelphiAbort=Operação cancelada: o Delphi (bds.exe) continua aberto.
brazilianportuguese.ErrOriginalDir=A pasta "%1" parece ser a instalação do JEDI VCS original (2.5.0.1030 ou servidor).%n%nEscolha outra pasta (padrão: JEDI\JVCS 2026). O JEDI VCS original não é alterado por este instalador.
brazilianportuguese.IdeNeverOpened=O %1 está instalado, mas ainda não foi aberto por este usuário do Windows (não existe HKCU\%2). O expert não foi registrado nele: abra e feche o Delphi uma vez e rode este instalador de novo (reparar).
brazilianportuguese.AiConfigSkipped=O config.ini da IA (%1) não está em UTF-8 válido e não foi alterado. Grave jvcsExe com: jvcs-ai.ps1 config set jvcsExe "%2"

english.TypeFull=Full installation
english.TypeCompact=Client only (standalone, Diff and console)
english.TypeCustom=Custom
english.CompClient=Standalone client (Jedivcs.exe), Diff (JEDIVCSDiff.exe), console (jvcs.exe) and help
english.CompIde=Delphi expert (JEDI VCS menu in the 32-bit IDE)
english.CompMaps=.map files (the error log shows unit and line)
english.CompAi=AI tools (tools\ai: wrapper, hooks and Claude Code skill)
english.TaskAiConsole=Use the new console (jvcs.exe of this installation) for the AI automation (writes jvcsExe to config.ini)
english.TaskAiGroup=AI automation:
english.IconClient=JEDI VCS 2026
english.IconDiff=JEDI VCS Diff 2026
english.IconHelp=JEDI VCS Help
english.IconHelpDiff=JEDI VCS Diff Help
english.IconToolsAi=AI tools (folder)
english.RunClient=Open JEDI VCS 2026
english.IdeDetected=detected: %1
english.IdeNone=no Delphi 11/12/13 detected
english.CloseDelphi=Delphi (bds.exe) is running.%n%nClose Delphi before continuing: the IDE rewrites the experts registry when it closes and keeps the expert DLL in use.%n%nClose Delphi and click Retry, or Cancel to quit.
english.CloseDelphiAbort=Cancelled: Delphi (bds.exe) is still running.
english.ErrOriginalDir=The folder "%1" looks like the original JEDI VCS installation (2.5.0.1030 or server).%n%nChoose another folder (default: JEDI\JVCS 2026). This setup does not change the original JEDI VCS.
english.IdeNeverOpened=%1 is installed but has not been started by this Windows user yet (HKCU\%2 does not exist). The expert was not registered there: start and close Delphi once and run this setup again (repair).
english.AiConfigSkipped=The AI config.ini (%1) is not valid UTF-8 and was not changed. Set jvcsExe with: jvcs-ai.ps1 config set jvcsExe "%2"

[Types]
Name: "full"; Description: "{cm:TypeFull}"
Name: "compact"; Description: "{cm:TypeCompact}"
Name: "custom"; Description: "{cm:TypeCustom}"; Flags: iscustom

[Components]
Name: "client"; Description: "{cm:CompClient}"; Types: full compact custom
Name: "ide"; Description: "{cm:CompIde}"; Types: full custom
Name: "maps"; Description: "{cm:CompMaps}"; Types: full custom
Name: "ai"; Description: "{cm:CompAi}"; Types: full custom

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Components: client
Name: "aiconsole"; Description: "{cm:TaskAiConsole}"; GroupDescription: "{cm:TaskAiGroup}"; Components: client and ai; Flags: unchecked

[Files]
; ---- cliente standalone, Diff e console ----
Source: "{#ClientSrc}\Jedivcs.exe"; DestDir: "{app}"; Components: client; Flags: ignoreversion
Source: "{#ClientSrc}\jvcs.exe"; DestDir: "{app}"; Components: client; Flags: ignoreversion
; o Diff tambem e usado pela DLL da IDE (Compare), que o procura na propria pasta
Source: "{#ClientSrc}\JEDIVCSDiff.exe"; DestDir: "{app}"; Components: client ide; Flags: ignoreversion
; ---- runtime comum (EXE e DLL procuram na propria pasta) ----
Source: "{#RtSrc}\fvcscrypt.dll"; DestDir: "{app}"; Components: client ide; Flags: ignoreversion
Source: "{#RtSrc}\jedivcs.chm"; DestDir: "{app}"; Components: client ide; Flags: ignoreversion
Source: "{#RtSrc}\jedivcsdiff.chm"; DestDir: "{app}"; Components: client ide; Flags: ignoreversion
Source: "{#RtSrc}\htm_rep.htm"; DestDir: "{app}"; Components: client ide; Flags: ignoreversion
Source: "{#RtSrc}\*.jvcs"; DestDir: "{app}"; Components: client ide; Flags: ignoreversion
Source: "{#Root}\doc\original\license.txt"; DestDir: "{app}"; Flags: ignoreversion
; ---- expert da IDE + DLL (mesma pasta: o expert so carrega a JvcsExternalDll.dll da propria pasta) ----
Source: "{#IdeSrc}\JvcsExternalDll.dll"; DestDir: "{app}"; Components: ide; Flags: ignoreversion
#if Pos("22,", ExpertList) > 0
Source: "{#IdeSrc}\JvcsExpertBDS22.dll"; DestDir: "{app}"; Components: ide; Flags: ignoreversion
#endif
#if Pos("23,", ExpertList) > 0
Source: "{#IdeSrc}\JvcsExpertBDS23.dll"; DestDir: "{app}"; Components: ide; Flags: ignoreversion
#endif
#if Pos("37,", ExpertList) > 0
Source: "{#IdeSrc}\JvcsExpertBDS37.dll"; DestDir: "{app}"; Components: ide; Flags: ignoreversion
#endif
; ---- .map ao lado do modulo (JclDebug no log de erros: unit/rotina/linha) ----
#if FileExists(ClientSrc + "\Jedivcs.map")
Source: "{#ClientSrc}\Jedivcs.map"; DestDir: "{app}"; Components: client and maps; Flags: ignoreversion
#endif
#if FileExists(IdeSrc + "\JvcsExternalDll.map")
Source: "{#IdeSrc}\JvcsExternalDll.map"; DestDir: "{app}"; Components: ide and maps; Flags: ignoreversion
#endif
; ---- ferramentas da IA (byte a byte: os .ps1 sao UTF-8 com BOM e CRLF) ----
Source: "{#AiSrc}\*"; DestDir: "{app}\tools\ai"; Components: ai; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{cm:IconClient}"; Filename: "{app}\Jedivcs.exe"; Components: client
Name: "{group}\{cm:IconDiff}"; Filename: "{app}\JEDIVCSDiff.exe"; Components: client
Name: "{group}\{cm:IconHelp}"; Filename: "{app}\jedivcs.chm"; Components: client
Name: "{group}\{cm:IconHelpDiff}"; Filename: "{app}\jedivcsdiff.chm"; Components: client
Name: "{group}\{cm:IconToolsAi}"; Filename: "{app}\tools\ai"; Components: ai
Name: "{group}\{cm:UninstallProgram,{#AppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{cm:IconClient}"; Filename: "{app}\Jedivcs.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\Jedivcs.exe"; Description: "{cm:RunClient}"; Components: client; Flags: postinstall nowait skipifsilent unchecked runasoriginaluser

[UninstallDelete]
Type: files; Name: "{app}\jvcs2026-setup.ini"

[Code]
const
  { experts presentes neste pacote ("22,23,37,"), calculado pelo pre-processador }
  ExpertsInPackage = '{#ExpertList}';
  AllBdsVersions = '22,23,37,';
  ExpertValueName = 'JVCSIDEClient';
  DefaultBdsBase = 'Software\Embarcadero\BDS';
  AiKeyJvcsExe = 'jvcsExe';

var
  State: TStringList;
  StateLoaded: Boolean;
  IdeNotes: String;

{ ---------------------------------------------------------------- utilitarios }

function SameDir(const A, B: String): Boolean;
begin
  Result := CompareText(RemoveBackslashUnlessRoot(A), RemoveBackslashUnlessRoot(B)) = 0;
end;

{ tira o primeiro item de uma lista "a,b,c," }
function NextItem(var List: String): String;
var
  P: Integer;
begin
  P := Pos(',', List);
  if P = 0 then
  begin
    Result := Trim(List);
    List := '';
  end
  else
  begin
    Result := Trim(Copy(List, 1, P - 1));
    List := Copy(List, P + 1, Length(List));
  end;
end;

function InList(const Item, List: String): Boolean;
begin
  Result := Pos(',' + Item + ',', ',' + List) > 0;
end;

function IdeName(const Ver: String): String;
begin
  if Ver = '22' then Result := 'Delphi 11 (BDS 22.0)'
  else if Ver = '23' then Result := 'Delphi 12 (BDS 23.0)'
  else if Ver = '37' then Result := 'Delphi 13 (BDS 37.0)'
  else Result := 'BDS ' + Ver + '.0';
end;

{ ------------------------------------------- estado da instalacao (app\jvcs2026-setup.ini)
  Linhas nome=valor (UTF-8). Guarda o que o instalador mudou fora da pasta app
  para a desinstalacao desfazer so isso:
    expert.<nn>.key      chave HKCU ...\Experts onde gravamos JVCSIDEClient
    expert.<nn>.hadprev  1 = havia outro JVCSIDEClient antes (restaurar)
    expert.<nn>.prev     valor anterior
    ai.path / ai.value / ai.hadprev / ai.prev   idem para jvcsExe do config.ini }

function StatePath: String;
begin
  Result := ExpandConstant('{app}\jvcs2026-setup.ini');
end;

procedure StateLoad;
var
  A: TArrayOfString;
  I: Integer;
begin
  if StateLoaded then
    Exit;
  State := TStringList.Create;
  if FileExists(StatePath) and LoadStringsFromFile(StatePath, A) then
    for I := 0 to GetArrayLength(A) - 1 do
      if (Trim(A[I]) <> '') and (Copy(Trim(A[I]), 1, 1) <> '#') and (Pos('=', A[I]) > 1) then
        State.Add(A[I]);
  StateLoaded := True;
end;

function StateIndex(const Name: String): Integer;
var
  I: Integer;
  P: String;
begin
  Result := -1;
  P := Lowercase(Name) + '=';
  for I := 0 to State.Count - 1 do
    if Pos(P, Lowercase(State[I])) = 1 then
    begin
      Result := I;
      Exit;
    end;
end;

function StateGet(const Name: String): String;
var
  I: Integer;
begin
  StateLoad;
  I := StateIndex(Name);
  if I >= 0 then
    Result := Copy(State[I], Length(Name) + 2, Length(State[I]))
  else
    Result := '';
end;

procedure StateSet(const Name, Value: String);
var
  I: Integer;
begin
  StateLoad;
  I := StateIndex(Name);
  if Value = '' then
  begin
    if I >= 0 then
      State.Delete(I);
  end
  else if I >= 0 then
    State[I] := Name + '=' + Value
  else
    State.Add(Name + '=' + Value);
end;

procedure StateSave;
var
  A: TArrayOfString;
  I: Integer;
begin
  if not StateLoaded then
    Exit;
  if State.Count = 0 then
  begin
    if FileExists(StatePath) then
      DeleteFile(StatePath);
    Exit;
  end;
  SetArrayLength(A, State.Count + 1);
  A[0] := '# JEDI VCS 2.5 Beta 2026 - estado do instalador (usado pela desinstalacao; nao edite)';
  for I := 0 to State.Count - 1 do
    A[I + 1] := State[I];
  if not SaveStringsToUTF8File(StatePath, A, False) then
    Log('Falha ao gravar ' + StatePath);
end;

{ ------------------------------------------------------------- Delphi aberto? }

function IsBdsRunning: Boolean;
var
  Locator, Service, Procs: Variant;
begin
  Result := False;
  try
    Locator := CreateOleObject('WbemScripting.SWbemLocator');
    Service := Locator.ConnectServer('.', 'root\CIMV2');
    Procs := Service.ExecQuery('SELECT ProcessId FROM Win32_Process WHERE Name = ''bds.exe''');
    Result := Procs.Count > 0;
  except
    Log('WMI indisponivel: ' + GetExceptionMessage);
  end;
  if not Result then
    Result := FindWindowByClassName('TAppBuilder') <> 0;
end;

{ True = pode continuar; False = usuario cancelou com o Delphi aberto }
function WaitDelphiClosed: Boolean;
begin
  Result := True;
  while IsBdsRunning do
    if SuppressibleMsgBox(CustomMessage('CloseDelphi'), mbError, MB_RETRYCANCEL, IDCANCEL) = IDCANCEL then
    begin
      Result := False;
      Exit;
    end;
end;

function ExpertFilesIn(const Dir: String): Boolean;
var
  F: TFindRec;
begin
  Result := FindFirst(AddBackslash(Dir) + 'JvcsExpertBDS*.dll', F);
  if Result then
    FindClose(F);
end;

{ ---------------------------------------------------------------- expert / IDE }

{ Parametro de TESTE /BDSKEY=Software\Outra\Chave troca a chave base
  (HKCU/HKLM\Software\Embarcadero\BDS); ver setup\LEIAME.md, secao Testes. }
function BdsBase: String;
begin
  Result := ExpandConstant('{param:BDSKEY|' + DefaultBdsBase + '}');
end;

function IdeExists(const Base, Ver: String): Boolean;
var
  K, S: String;
begin
  K := Base + '\' + Ver + '.0';
  Result := (RegQueryStringValue(HKCU, K, 'App', S) and FileExists(S)) or
            (RegQueryStringValue(HKLM32, K, 'App', S) and FileExists(S));
end;

function ExpertFileName(const Ver: String): String;
begin
  Result := ExpandConstant('{app}\JvcsExpertBDS' + Ver + '.dll');
end;

function IsOurExpert(const Value: String): Boolean;
begin
  Result := (Value <> '') and SameDir(ExtractFileDir(Value), ExpandConstant('{app}'));
end;

procedure UnregisterExpert(const Ver: String);
var
  ExpKey, Cur, Prev: String;
begin
  ExpKey := StateGet('expert.' + Ver + '.key');
  if ExpKey = '' then
    ExpKey := DefaultBdsBase + '\' + Ver + '.0\Experts';
  if RegQueryStringValue(HKCU, ExpKey, ExpertValueName, Cur) and IsOurExpert(Cur) then
  begin
    Prev := StateGet('expert.' + Ver + '.prev');
    if (StateGet('expert.' + Ver + '.hadprev') = '1') and (Prev <> '') then
    begin
      RegWriteStringValue(HKCU, ExpKey, ExpertValueName, Prev);
      Log('Expert ' + Ver + ': JVCSIDEClient restaurado para ' + Prev + ' (' + ExpKey + ')');
    end
    else
    begin
      RegDeleteValue(HKCU, ExpKey, ExpertValueName);
      Log('Expert ' + Ver + ': JVCSIDEClient removido (' + ExpKey + ')');
    end;
  end
  else
    Log('Expert ' + Ver + ': JVCSIDEClient em ' + ExpKey + ' nao aponta para esta instalacao; mantido');
  StateSet('expert.' + Ver + '.key', '');
  StateSet('expert.' + Ver + '.prev', '');
  StateSet('expert.' + Ver + '.hadprev', '');
end;

procedure UnregisterAllExperts;
var
  L, Ver: String;
begin
  L := AllBdsVersions;
  while L <> '' do
  begin
    Ver := NextItem(L);
    if Ver <> '' then
      UnregisterExpert(Ver);
  end;
end;

procedure RegisterExperts;
var
  Base, L, Ver, K, ExpKey, Cur, NewVal: String;
  Done: String;
begin
  Base := BdsBase;
  Done := '';
  L := ExpertsInPackage;
  while L <> '' do
  begin
    Ver := NextItem(L);
    if Ver = '' then
      Continue;
    K := Base + '\' + Ver + '.0';
    ExpKey := K + '\Experts';
    if not IdeExists(Base, Ver) then
    begin
      Log('Expert ' + Ver + ': ' + IdeName(Ver) + ' nao instalado (' + K + ', valor App); nao registrado');
      Continue;
    end;
    if not RegKeyExists(HKCU, K) then
    begin
      Log('Expert ' + Ver + ': HKCU\' + K + ' nao existe (IDE nunca aberta por este usuario); nao registrado');
      IdeNotes := IdeNotes + FmtMessage(CustomMessage('IdeNeverOpened'), [IdeName(Ver), K]) + #13#10#13#10;
      Continue;
    end;
    NewVal := ExpertFileName(Ver);
    if RegQueryStringValue(HKCU, ExpKey, ExpertValueName, Cur) then
    begin
      if not IsOurExpert(Cur) then
      begin
        StateSet('expert.' + Ver + '.prev', Cur);
        StateSet('expert.' + Ver + '.hadprev', '1');
        Log('Expert ' + Ver + ': valor anterior guardado para restaurar na desinstalacao: ' + Cur);
      end
      else if StateGet('expert.' + Ver + '.hadprev') = '' then
        StateSet('expert.' + Ver + '.hadprev', '0');
    end
    else
    begin
      StateSet('expert.' + Ver + '.prev', '');
      StateSet('expert.' + Ver + '.hadprev', '0');
    end;
    if RegWriteStringValue(HKCU, ExpKey, ExpertValueName, NewVal) then
    begin
      StateSet('expert.' + Ver + '.key', ExpKey);
      Done := Done + Ver + ',';
      Log('Expert ' + Ver + ': HKCU\' + ExpKey + ' JVCSIDEClient = ' + NewVal);
    end
    else
      Log('Expert ' + Ver + ': falha ao gravar HKCU\' + ExpKey);
  end;
  { versoes registradas por uma instalacao anterior e que nao valem mais }
  L := AllBdsVersions;
  while L <> '' do
  begin
    Ver := NextItem(L);
    if (Ver <> '') and not InList(Ver, Done) and (StateGet('expert.' + Ver + '.key') <> '') then
      UnregisterExpert(Ver);
  end;
end;

{ ------------------------------------------- config.ini da IA (%APPDATA%\JEDI\JVCS)
  Reproduz Read-JaIniSection / Set-JaConfigValue (tools\ai\lib\jvcs-ai-common.ps1)
  e JVCSAIConfig.pas: UTF-8 com BOM, CRLF (tambem no fim), preserva o resto do
  arquivo, troca a ultima linha "chave=" da ultima secao [ai] ou insere antes
  das linhas em branco do fim da secao, ou cria [ai] no fim. }

function AiStripBom(const S: String): String;
begin
  Result := S;
  while (Length(Result) > 0) and (Result[1] = #$FEFF) do
    Delete(Result, 1, 1);
end;

function AiIsSection(const T: String; var Name: String): Boolean;
begin
  Result := (Length(T) >= 3) and (T[1] = '[') and (T[Length(T)] = ']');
  if Result then
    Name := Trim(Copy(T, 2, Length(T) - 2));
end;

{ Le o arquivo como [IO.File]::ReadAllLines (quebra em CR, LF ou CRLF).
  Valid = False se o arquivo existe mas nao e UTF-8 valido (nao gravar). }
function AiLoadLines(const Path: String; Lines: TStringList; var Valid: Boolean): Boolean;
var
  Raw, Body: AnsiString;
  Text: String;
  I, Start, N: Integer;
begin
  Result := False;
  Valid := True;
  if not FileExists(Path) then
    Exit;
  if not LoadStringFromFile(Path, Raw) then
  begin
    Valid := False;
    Exit;
  end;
  Body := Raw;
  if (Length(Raw) >= 3) and (Ord(Raw[1]) = $EF) and (Ord(Raw[2]) = $BB) and (Ord(Raw[3]) = $BF) then
    Body := Copy(Raw, 4, Length(Raw));
  Text := Utf8Decode(Body);
  if Utf8Encode(Text) <> Body then
  begin
    Valid := False;
    Exit;
  end;
  N := Length(Text);
  I := 1;
  Start := 1;
  while I <= N do
  begin
    if (Text[I] = #13) or (Text[I] = #10) then
    begin
      Lines.Add(Copy(Text, Start, I - Start));
      if (Text[I] = #13) and (I < N) and (Text[I + 1] = #10) then
        I := I + 1;
      Start := I + 1;
    end;
    I := I + 1;
  end;
  if Start <= N then
    Lines.Add(Copy(Text, Start, N - Start + 1));
  Result := True;
end;

function AiSaveLines(const Path: String; Lines: TStringList): Boolean;
var
  Text: String;
  I: Integer;
begin
  Text := '';
  for I := 0 to Lines.Count - 1 do
    Text := Text + Lines[I] + #13#10;
  ForceDirectories(ExtractFileDir(Path));
  Result := SaveStringToFile(Path, Utf8Encode(#$FEFF + Text), False);
end;

{ chave da linha (texto antes do primeiro "="), ou '' se nao for "chave=" }
function AiLineKey(const T: String): String;
var
  P: Integer;
  Prefix: String;
begin
  Result := '';
  P := Pos('=', T);
  if P > 1 then
  begin
    Prefix := Copy(T, 1, P - 1);
    if (Pos(';', Prefix) = 0) and (Pos('#', Prefix) = 0) then
      Result := Trim(Prefix);
  end;
end;

{ valor efetivo como o wrapper le (ultima ocorrencia em qualquer secao [ai]) }
function AiReadValue(const Path, Key: String; var Value: String): Boolean;
var
  Lines: TStringList;
  I, P: Integer;
  Line, Sec: String;
  InSec, Valid: Boolean;
begin
  Result := False;
  Value := '';
  Lines := TStringList.Create;
  try
    if not AiLoadLines(Path, Lines, Valid) then
      Exit;
    InSec := False;
    for I := 0 to Lines.Count - 1 do
    begin
      Line := Trim(AiStripBom(Trim(Lines[I])));
      if (Line = '') or (Line[1] = ';') or (Line[1] = '#') then
        Continue;
      if AiIsSection(Line, Sec) then
      begin
        InSec := CompareText(Sec, 'ai') = 0;
        Continue;
      end;
      P := Pos('=', Line);
      if InSec and (P > 1) and (CompareText(Trim(Copy(Line, 1, P - 1)), Key) = 0) then
      begin
        Value := Trim(Copy(Line, P + 1, Length(Line)));
        Result := True;
      end;
    end;
  finally
    Lines.Free;
  end;
end;

function AiWriteValue(const Path, Key, Value: String): Boolean;
var
  Lines: TStringList;
  I, SecStart, SecEnd, KeyLine, InsertAt: Integer;
  T, Sec, NewLine: String;
  Exists, Valid: Boolean;
begin
  Result := False;
  Lines := TStringList.Create;
  try
    Exists := AiLoadLines(Path, Lines, Valid);
    if not Valid then
      Exit;
    if not Exists then
    begin
      Lines.Add('; JEDI VCS - automa' + #$00E7#$00E3 + 'o por IA (Claude Code). Sem segredos: a senha fica na identidade salva.');
      Lines.Add('; Edite pela interface (futura aba "IA / Automa' + #$00E7#$00E3 + 'o" em VCS Properties) ou com: jvcs-ai.ps1 config set <chave> <valor>');
      Lines.Add('; checkout/checkin = auto | confirm | manual   (padr' + #$00E3 + 'o: confirm)');
    end
    else
      for I := 0 to Lines.Count - 1 do
        Lines[I] := AiStripBom(Lines[I]);
    SecStart := -1;
    SecEnd := Lines.Count;
    KeyLine := -1;
    for I := 0 to Lines.Count - 1 do
    begin
      T := Trim(Lines[I]);
      if AiIsSection(T, Sec) then
      begin
        if (SecStart >= 0) and (SecEnd = Lines.Count) then
          SecEnd := I;
        if CompareText(Sec, 'ai') = 0 then
        begin
          SecStart := I;
          SecEnd := Lines.Count;
        end;
        Continue;
      end;
      if (SecStart >= 0) and (I > SecStart) and (I < SecEnd) and (CompareText(AiLineKey(T), Key) = 0) then
        KeyLine := I;
    end;
    NewLine := Key + '=' + Value;
    if KeyLine >= 0 then
      Lines[KeyLine] := NewLine
    else if SecStart >= 0 then
    begin
      InsertAt := SecEnd;
      while (InsertAt > SecStart + 1) and (Trim(Lines[InsertAt - 1]) = '') do
        InsertAt := InsertAt - 1;
      Lines.Insert(InsertAt, NewLine);
    end
    else
    begin
      if (Lines.Count > 0) and (Trim(Lines[Lines.Count - 1]) <> '') then
        Lines.Add('');
      Lines.Add('[ai]');
      Lines.Add(NewLine);
    end;
    Result := AiSaveLines(Path, Lines);
  finally
    Lines.Free;
  end;
end;

{ remove a chave de todas as secoes [ai] (o wrapper volta ao padrao) }
function AiRemoveKey(const Path, Key: String): Boolean;
var
  Lines: TStringList;
  I: Integer;
  T, Sec: String;
  InSec, Valid, Changed: Boolean;
begin
  Result := False;
  Lines := TStringList.Create;
  try
    if not AiLoadLines(Path, Lines, Valid) then
      Exit;
    InSec := False;
    Changed := False;
    I := 0;
    while I < Lines.Count do
    begin
      Lines[I] := AiStripBom(Lines[I]);
      T := Trim(Lines[I]);
      if AiIsSection(T, Sec) then
        InSec := CompareText(Sec, 'ai') = 0
      else if InSec and (CompareText(AiLineKey(T), Key) = 0) then
      begin
        Lines.Delete(I);
        Changed := True;
        Continue;
      end;
      I := I + 1;
    end;
    if Changed then
      Result := AiSaveLines(Path, Lines)
    else
      Result := True;
  finally
    Lines.Free;
  end;
end;

{ Parametro de TESTE /AICONFIG=<arquivo> troca o config.ini usado. }
function AiConfigPath: String;
begin
  Result := ExpandConstant('{param:AICONFIG|}');
  if Result = '' then
    Result := ExpandConstant('{userappdata}\JEDI\JVCS\config.ini');
end;

{ True se o arquivo so tem comentarios, linhas em branco e cabecalhos [ai]
  (o que sobra de um config.ini criado por este instalador) }
function AiIsEmptyConfig(const Path: String): Boolean;
var
  Lines: TStringList;
  I: Integer;
  T: String;
  Valid: Boolean;
begin
  Result := False;
  Lines := TStringList.Create;
  try
    if not AiLoadLines(Path, Lines, Valid) then
      Exit;
    for I := 0 to Lines.Count - 1 do
    begin
      T := Trim(AiStripBom(Lines[I]));
      if (T <> '') and (T[1] <> ';') and (T[1] <> '#') and (CompareText(T, '[ai]') <> 0) then
        Exit;
    end;
    Result := True;
  finally
    Lines.Free;
  end;
end;

procedure ApplyAiConsole;
var
  Path, NewExe, Cur: String;
  Found, Existed: Boolean;
begin
  Path := AiConfigPath;
  Existed := FileExists(Path);
  NewExe := ExpandConstant('{app}\jvcs.exe');
  Found := AiReadValue(Path, AiKeyJvcsExe, Cur);
  if not (Found and (CompareText(Cur, NewExe) = 0)) then
  begin
    if Found then
    begin
      StateSet('ai.prev', Cur);
      StateSet('ai.hadprev', '1');
    end
    else
    begin
      StateSet('ai.prev', '');
      StateSet('ai.hadprev', '0');
    end;
  end
  else if StateGet('ai.hadprev') = '' then
    StateSet('ai.hadprev', '0');
  if AiWriteValue(Path, AiKeyJvcsExe, NewExe) then
  begin
    StateSet('ai.path', Path);
    StateSet('ai.value', NewExe);
    if not Existed then
      StateSet('ai.created', '1');
    Log('IA: ' + Path + ' [ai] jvcsExe=' + NewExe);
  end
  else
  begin
    Log('IA: ' + Path + ' nao alterado (nao e UTF-8 valido ou falha de gravacao)');
    SuppressibleMsgBox(FmtMessage(CustomMessage('AiConfigSkipped'), [Path, NewExe]), mbInformation, MB_OK, IDOK);
  end;
end;

procedure RevertAiConsole;
var
  Path, Cur, Prev: String;
begin
  Path := StateGet('ai.path');
  if Path = '' then
    Exit;
  if AiReadValue(Path, AiKeyJvcsExe, Cur) and (CompareText(Cur, StateGet('ai.value')) = 0) then
  begin
    Prev := StateGet('ai.prev');
    if (StateGet('ai.hadprev') = '1') and (Prev <> '') then
    begin
      AiWriteValue(Path, AiKeyJvcsExe, Prev);
      Log('IA: jvcsExe restaurado para ' + Prev);
    end
    else
    begin
      AiRemoveKey(Path, AiKeyJvcsExe);
      Log('IA: jvcsExe removido (o wrapper volta ao console padrao)');
      if (StateGet('ai.created') = '1') and AiIsEmptyConfig(Path) then
      begin
        DeleteFile(Path);
        Log('IA: ' + Path + ' criado por este instalador e vazio; apagado');
      end;
    end;
  end
  else
    Log('IA: jvcsExe em ' + Path + ' nao aponta para esta instalacao; mantido');
  StateSet('ai.path', '');
  StateSet('ai.value', '');
  StateSet('ai.prev', '');
  StateSet('ai.hadprev', '');
  StateSet('ai.created', '');
end;

{ ---------------------------------------------------------------- pasta }

function IsOriginalJvcsDir(const Dir: String): Boolean;
var
  D, V: String;
begin
  D := RemoveBackslashUnlessRoot(Dir);
  Result := SameDir(D, ExpandConstant('{commonpf32}\JEDI\JVCS')) or
            FileExists(D + '\JvcsExpertBDS21.dll') or FileExists(D + '\JvcsExpertD7.dll') or
            FileExists(D + '\server\JVCSSrv.exe') or FileExists(D + '\JVCSSrv.exe');
  if not Result and FileExists(D + '\jedivcs.exe') then
    Result := GetVersionNumbersString(D + '\jedivcs.exe', V) and (V <> '{#AppVersion}');
end;

{ ---------------------------------------------------------------- eventos do assistente }

procedure InitializeWizard;
var
  I: Integer;
  L, Ver, Found, Base: String;
begin
  Base := BdsBase;
  Found := '';
  L := ExpertsInPackage;
  while L <> '' do
  begin
    Ver := NextItem(L);
    if (Ver <> '') and IdeExists(Base, Ver) then
    begin
      if Found <> '' then
        Found := Found + ', ';
      Found := Found + IdeName(Ver);
    end;
  end;
  if Found = '' then
    Found := CustomMessage('IdeNone')
  else
    Found := FmtMessage(CustomMessage('IdeDetected'), [Found]);
  for I := 0 to WizardForm.ComponentsList.Items.Count - 1 do
    if WizardForm.ComponentsList.ItemCaption[I] = CustomMessage('CompIde') then
      WizardForm.ComponentsList.ItemCaption[I] := CustomMessage('CompIde') + ' - ' + Found;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if (CurPageID = wpSelectDir) and IsOriginalJvcsDir(WizardDirValue) then
  begin
    SuppressibleMsgBox(FmtMessage(CustomMessage('ErrOriginalDir'), [WizardDirValue]), mbError, MB_OK, IDOK);
    Result := False;
  end;
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  Result := '';
  if IsOriginalJvcsDir(WizardDirValue) then
  begin
    Result := FmtMessage(CustomMessage('ErrOriginalDir'), [WizardDirValue]);
    Exit;
  end;
  if WizardIsComponentSelected('ide') or ExpertFilesIn(WizardDirValue) then
    if not WaitDelphiClosed then
      Result := CustomMessage('CloseDelphiAbort');
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    if WizardIsComponentSelected('ide') then
      RegisterExperts
    else
      UnregisterAllExperts;
    if WizardIsTaskSelected('aiconsole') then
      ApplyAiConsole
    else
      RevertAiConsole;
    StateSave;
    if IdeNotes <> '' then
      SuppressibleMsgBox(Trim(IdeNotes), mbInformation, MB_OK, IDOK);
  end;
end;

{ ---------------------------------------------------------------- desinstalacao }

function InitializeUninstall: Boolean;
begin
  Result := True;
  if ExpertFilesIn(ExpandConstant('{app}')) then
    Result := WaitDelphiClosed;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
  begin
    UnregisterAllExperts;
    RevertAiConsole;
    StateSave;
  end;
end;
