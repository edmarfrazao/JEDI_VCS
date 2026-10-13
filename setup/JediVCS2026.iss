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
;    SkillSrc  = skills               skill do Claude Code: skills\pt\jedi-vcs e skills\en\jedi-vcs
;                                     -> {app}\tools\ai\skills\pt\jedi-vcs e {app}\tools\ai\skills\en\jedi-vcs
;
;    OldSrc    = 3rdparty\experts-originais-2.5.0.1030
;                                     JvcsExpertD7.dll, JvcsExpertBDS1..21.dll ORIGINAIS
;                                     (2.5.0.1030), para as IDEs antigas
;
;  Expert: entra no pacote todo JvcsExpertBDS22/23/37.dll que existir em IdeSrc
;  (22 = Delphi 11, 23 = Delphi 12, 37 = Delphi 13), sem editar este arquivo.
;  IDEs antigas (Delphi 7 a 10.4): componente "ideold", um subcomponente por IDE,
;  visivel so se a IDE for detectada; usa o expert ORIGINAL (fino, mesma ABI) com
;  a JvcsExternalDll.dll nova na mesma pasta.
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
#ifndef SkillSrc
  #define SkillSrc Root + "\skills"
#endif
#ifndef OldSrc
  #define OldSrc Root + "\3rdparty\experts-originais-2.5.0.1030"
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
#expr Req(SkillSrc + "\pt\jedi-vcs\SKILL.md")
#expr Req(SkillSrc + "\en\jedi-vcs\SKILL.md")
#expr Req(OldSrc + "\JvcsExpertD7.dll")
#expr Req(OldSrc + "\JvcsExpertBDS21.dll")

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
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"; LicenseFile: "aviso-pt.txt"
Name: "english"; MessagesFile: "compiler:Default.isl"; LicenseFile: "aviso-en.txt"

[CustomMessages]
brazilianportuguese.TypeFull=Instalação completa
brazilianportuguese.TypeCompact=Somente o cliente (standalone, Diff e console)
brazilianportuguese.TypeCustom=Personalizada
brazilianportuguese.CompClient=Cliente standalone (Jedivcs.exe), Diff (JEDIVCSDiff.exe), console (jvcs.exe) e ajuda
brazilianportuguese.CompIde=Expert para o Delphi (menu JEDI VCS na IDE de 32 bits)
brazilianportuguese.CompIdeOld=IDEs antigas detectadas (expert original 2.5.0.1030 + núcleo novo JvcsExternalDll 2.5.0.2026)
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
brazilianportuguese.CloseDelphi=O Delphi (bds.exe ou delphi32.exe) está aberto.%n%nFeche o Delphi antes de continuar: a IDE regrava o registro dos experts ao fechar e mantém a DLL do expert em uso.%n%nFeche o Delphi e clique em Repetir, ou em Cancelar para sair.
brazilianportuguese.CloseDelphiAbort=Operação cancelada: o Delphi (bds.exe ou delphi32.exe) continua aberto.
brazilianportuguese.ErrOriginalDir=A pasta "%1" parece ser a instalação do JEDI VCS original (2.5.0.1030 ou servidor).%n%nEscolha outra pasta (padrão: JEDI\JVCS 2026). O JEDI VCS original não é alterado por este instalador.
brazilianportuguese.IdeNeverOpened=O %1 está instalado, mas ainda não foi aberto por este usuário do Windows (não existe HKCU\%2). O expert não foi registrado nele: abra e feche o Delphi uma vez e rode este instalador de novo (reparar).
brazilianportuguese.AiConfigSkipped=O config.ini da IA (%1) não está em UTF-8 válido e não foi alterado. Grave jvcsExe com: jvcs-ai.ps1 config set jvcsExe "%2"

english.TypeFull=Full installation
english.TypeCompact=Client only (standalone, Diff and console)
english.TypeCustom=Custom
english.CompClient=Standalone client (Jedivcs.exe), Diff (JEDIVCSDiff.exe), console (jvcs.exe) and help
english.CompIde=Delphi expert (JEDI VCS menu in the 32-bit IDE)
english.CompIdeOld=Older IDEs detected (original 2.5.0.1030 expert + new JvcsExternalDll 2.5.0.2026 core)
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
english.CloseDelphi=Delphi (bds.exe or delphi32.exe) is running.%n%nClose Delphi before continuing: the IDE rewrites the experts registry when it closes and keeps the expert DLL in use.%n%nClose Delphi and click Retry, or Cancel to quit.
english.CloseDelphiAbort=Cancelled: Delphi (bds.exe or delphi32.exe) is still running.
english.ErrOriginalDir=The folder "%1" looks like the original JEDI VCS installation (2.5.0.1030 or server).%n%nChoose another folder (default: JEDI\JVCS 2026). This setup does not change the original JEDI VCS.
english.IdeNeverOpened=%1 is installed but has not been started by this Windows user yet (HKCU\%2 does not exist). The expert was not registered there: start and close Delphi once and run this setup again (repair).
english.AiConfigSkipped=The AI config.ini (%1) is not valid UTF-8 and was not changed. Set jvcsExe with: jvcs-ai.ps1 config set jvcsExe "%2"

[Types]
Name: "full"; Description: "{cm:TypeFull}"
Name: "compact"; Description: "{cm:TypeCompact}"
Name: "custom"; Description: "{cm:TypeCustom}"; Flags: iscustom

[Components]
Name: "client"; Description: "{cm:CompClient}"; Types: full compact custom
Name: "ide"; Description: "{cm:CompIde}"; Types: full custom; Check: AnyNewIde
; Um subcomponente por IDE nova: so aparece se a IDE estiver instalada e o expert estiver no pacote.
#if Pos("22,", ExpertList) > 0
Name: "ide\bds22"; Description: "Delphi 11 Alexandria (BDS 22.0)"; Types: full custom; Check: NewIdeAvailable('22')
#endif
#if Pos("23,", ExpertList) > 0
Name: "ide\bds23"; Description: "Delphi 12 Athens (BDS 23.0)"; Types: full custom; Check: NewIdeAvailable('23')
#endif
#if Pos("37,", ExpertList) > 0
Name: "ide\bds37"; Description: "Delphi 13 Florence (BDS 37.0)"; Types: full custom; Check: NewIdeAvailable('37')
#endif
; IDEs antigas: so aparecem as detectadas (Check avaliado uma vez, no inicio).
; Nome do subcomponente = id da IDE (d7 ou bds<n>); tabela em OldIdeKey/OldIdeName.
Name: "ideold"; Description: "{cm:CompIdeOld}"; Types: full custom; Check: AnyOldIde
Name: "ideold\d7"; Description: "Delphi 7"; Types: full custom; Check: OldIdeExists('d7')
Name: "ideold\bds1"; Description: "C#Builder 1.0 (BDS 1.0)"; Types: full custom; Check: OldIdeExists('1')
Name: "ideold\bds2"; Description: "Delphi 8 for .NET (BDS 2.0)"; Types: full custom; Check: OldIdeExists('2')
Name: "ideold\bds3"; Description: "Delphi 2005 (BDS 3.0)"; Types: full custom; Check: OldIdeExists('3')
Name: "ideold\bds4"; Description: "Borland Developer Studio 2006 (BDS 4.0)"; Types: full custom; Check: OldIdeExists('4')
Name: "ideold\bds5"; Description: "Delphi 2007 / RAD Studio 2007 (BDS 5.0)"; Types: full custom; Check: OldIdeExists('5')
Name: "ideold\bds6"; Description: "Delphi 2009 (BDS 6.0)"; Types: full custom; Check: OldIdeExists('6')
Name: "ideold\bds7"; Description: "Delphi 2010 (BDS 7.0)"; Types: full custom; Check: OldIdeExists('7')
Name: "ideold\bds8"; Description: "Delphi XE (BDS 8.0)"; Types: full custom; Check: OldIdeExists('8')
Name: "ideold\bds9"; Description: "Delphi XE2 (BDS 9.0)"; Types: full custom; Check: OldIdeExists('9')
Name: "ideold\bds10"; Description: "Delphi XE3 (BDS 10.0)"; Types: full custom; Check: OldIdeExists('10')
Name: "ideold\bds11"; Description: "Delphi XE4 (BDS 11.0)"; Types: full custom; Check: OldIdeExists('11')
Name: "ideold\bds12"; Description: "Delphi XE5 (BDS 12.0)"; Types: full custom; Check: OldIdeExists('12')
Name: "ideold\bds14"; Description: "Delphi XE6 (BDS 14.0)"; Types: full custom; Check: OldIdeExists('14')
Name: "ideold\bds15"; Description: "Delphi XE7 (BDS 15.0)"; Types: full custom; Check: OldIdeExists('15')
Name: "ideold\bds16"; Description: "Delphi XE8 (BDS 16.0)"; Types: full custom; Check: OldIdeExists('16')
Name: "ideold\bds17"; Description: "Delphi 10 Seattle (BDS 17.0)"; Types: full custom; Check: OldIdeExists('17')
Name: "ideold\bds18"; Description: "Delphi 10.1 Berlin (BDS 18.0)"; Types: full custom; Check: OldIdeExists('18')
Name: "ideold\bds19"; Description: "Delphi 10.2 Tokyo (BDS 19.0)"; Types: full custom; Check: OldIdeExists('19')
Name: "ideold\bds20"; Description: "Delphi 10.3 Rio (BDS 20.0)"; Types: full custom; Check: OldIdeExists('20')
Name: "ideold\bds21"; Description: "Delphi 10.4 Sydney (BDS 21.0)"; Types: full custom; Check: OldIdeExists('21')
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
Source: "{#ClientSrc}\JEDIVCSDiff.exe"; DestDir: "{app}"; Components: client ide ideold; Flags: ignoreversion
; ---- runtime comum (EXE e DLL procuram na propria pasta) ----
Source: "{#RtSrc}\fvcscrypt.dll"; DestDir: "{app}"; Components: client ide ideold; Flags: ignoreversion
Source: "{#RtSrc}\jedivcs.chm"; DestDir: "{app}"; Components: client ide ideold; Flags: ignoreversion
Source: "{#RtSrc}\jedivcsdiff.chm"; DestDir: "{app}"; Components: client ide ideold; Flags: ignoreversion
Source: "{#RtSrc}\htm_rep.htm"; DestDir: "{app}"; Components: client ide ideold; Flags: ignoreversion
Source: "{#RtSrc}\*.jvcs"; DestDir: "{app}"; Components: client ide ideold; Flags: ignoreversion
Source: "{#Root}\doc\original\license.txt"; DestDir: "{app}"; Flags: ignoreversion
; ---- expert da IDE + DLL (mesma pasta: o expert so carrega a JvcsExternalDll.dll da propria pasta) ----
Source: "{#IdeSrc}\JvcsExternalDll.dll"; DestDir: "{app}"; Components: ide ideold; Flags: ignoreversion
; ---- experts ORIGINAIS 2.5.0.1030 (IDEs antigas), byte a byte; carregam a JvcsExternalDll.dll nova acima ----
Source: "{#OldSrc}\JvcsExpertD7.dll"; DestDir: "{app}"; Components: ideold\d7; Flags: ignoreversion
Source: "{#OldSrc}\JvcsExpertBDS1.dll"; DestDir: "{app}"; Components: ideold\bds1; Flags: ignoreversion
Source: "{#OldSrc}\JvcsExpertBDS2.dll"; DestDir: "{app}"; Components: ideold\bds2; Flags: ignoreversion
Source: "{#OldSrc}\JvcsExpertBDS3.dll"; DestDir: "{app}"; Components: ideold\bds3; Flags: ignoreversion
Source: "{#OldSrc}\JvcsExpertBDS4.dll"; DestDir: "{app}"; Components: ideold\bds4; Flags: ignoreversion
Source: "{#OldSrc}\JvcsExpertBDS5.dll"; DestDir: "{app}"; Components: ideold\bds5; Flags: ignoreversion
Source: "{#OldSrc}\JvcsExpertBDS6.dll"; DestDir: "{app}"; Components: ideold\bds6; Flags: ignoreversion
Source: "{#OldSrc}\JvcsExpertBDS7.dll"; DestDir: "{app}"; Components: ideold\bds7; Flags: ignoreversion
Source: "{#OldSrc}\JvcsExpertBDS8.dll"; DestDir: "{app}"; Components: ideold\bds8; Flags: ignoreversion
Source: "{#OldSrc}\JvcsExpertBDS9.dll"; DestDir: "{app}"; Components: ideold\bds9; Flags: ignoreversion
Source: "{#OldSrc}\JvcsExpertBDS10.dll"; DestDir: "{app}"; Components: ideold\bds10; Flags: ignoreversion
Source: "{#OldSrc}\JvcsExpertBDS11.dll"; DestDir: "{app}"; Components: ideold\bds11; Flags: ignoreversion
Source: "{#OldSrc}\JvcsExpertBDS12.dll"; DestDir: "{app}"; Components: ideold\bds12; Flags: ignoreversion
Source: "{#OldSrc}\JvcsExpertBDS14.dll"; DestDir: "{app}"; Components: ideold\bds14; Flags: ignoreversion
Source: "{#OldSrc}\JvcsExpertBDS15.dll"; DestDir: "{app}"; Components: ideold\bds15; Flags: ignoreversion
Source: "{#OldSrc}\JvcsExpertBDS16.dll"; DestDir: "{app}"; Components: ideold\bds16; Flags: ignoreversion
Source: "{#OldSrc}\JvcsExpertBDS17.dll"; DestDir: "{app}"; Components: ideold\bds17; Flags: ignoreversion
Source: "{#OldSrc}\JvcsExpertBDS18.dll"; DestDir: "{app}"; Components: ideold\bds18; Flags: ignoreversion
Source: "{#OldSrc}\JvcsExpertBDS19.dll"; DestDir: "{app}"; Components: ideold\bds19; Flags: ignoreversion
Source: "{#OldSrc}\JvcsExpertBDS20.dll"; DestDir: "{app}"; Components: ideold\bds20; Flags: ignoreversion
Source: "{#OldSrc}\JvcsExpertBDS21.dll"; DestDir: "{app}"; Components: ideold\bds21; Flags: ignoreversion
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
Source: "{#IdeSrc}\JvcsExternalDll.map"; DestDir: "{app}"; Components: (ide or ideold) and maps; Flags: ignoreversion
#endif
; ---- ferramentas da IA (byte a byte: os .ps1 sao UTF-8 com BOM e CRLF) ----
Source: "{#AiSrc}\*"; DestDir: "{app}\tools\ai"; Components: ai; Flags: ignoreversion recursesubdirs createallsubdirs
; skill distribuivel do Claude Code em portugues e em ingles (byte a byte; mesmo nome
; "jedi-vcs"); NAO e copiada para o perfil do usuario: ver setup\LEIAME.md (copiar UMA
; delas para %USERPROFILE%\.claude\skills\jedi-vcs)
Source: "{#SkillSrc}\pt\jedi-vcs\*"; DestDir: "{app}\tools\ai\skills\pt\jedi-vcs"; Components: ai; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#SkillSrc}\en\jedi-vcs\*"; DestDir: "{app}\tools\ai\skills\en\jedi-vcs"; Components: ai; Flags: ignoreversion recursesubdirs createallsubdirs

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

[InstallDelete]
; skill da beta 4 (antes da separacao por idioma): agora em tools\ai\skills\pt e \en
Type: filesandordirs; Name: "{app}\tools\ai\skills\jedi-vcs"

[UninstallDelete]
Type: files; Name: "{app}\jvcs2026-setup.ini"

[Code]
const
  { experts presentes neste pacote ("22,23,37,"), calculado pelo pre-processador }
  ExpertsInPackage = '{#ExpertList}';
  AllBdsVersions = '22,23,37,';
  ExpertValueName = 'JVCSIDEClient';
  DefaultBdsBase = 'Software\Embarcadero\BDS';
  { IDEs antigas com expert original 2.5.0.1030 (d7 = Delphi 7, n = BDS n.0; nao ha 13) }
  OldIdeIds = 'd7,1,2,3,4,5,6,7,8,9,10,11,12,14,15,16,17,18,19,20,21,';
  DefaultOldRoot = 'Software';
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
    old.<id>.key/.hadprev/.prev  idem para as IDEs antigas (id = d7, 1..21)
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
    { bds.exe: BDS 1.0 (C#Builder) a 37.0; delphi32.exe: Delphi 7 }
    Procs := Service.ExecQuery('SELECT ProcessId FROM Win32_Process WHERE Name = ''bds.exe'' OR Name = ''delphi32.exe''');
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
    FindClose(F)
  else
    Result := FileExists(AddBackslash(Dir) + 'JvcsExpertD7.dll');
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

function NewIdeAvailable(const Ver: String): Boolean;
begin
  Result := InList(Ver, ExpertsInPackage) and IdeExists(BdsBase, Ver);
end;

function AnyNewIde: Boolean;
var
  L, Ver: String;
begin
  Result := False;
  L := ExpertsInPackage;
  while (L <> '') and not Result do
  begin
    Ver := NextItem(L);
    if Ver <> '' then
      Result := IdeExists(BdsBase, Ver);
  end;
end;

function ExpertFileName(const Ver: String): String;
begin
  Result := ExpandConstant('{app}\JvcsExpertBDS' + Ver + '.dll');
end;

function IsOurExpert(const Value: String): Boolean;
begin
  Result := (Value <> '') and SameDir(ExtractFileDir(Value), ExpandConstant('{app}'));
end;

{ A IDE de 64 bits (bin64\bds.exe, Delphi 12.3+ e 13) le "Experts x64", separada
  da "Experts" da IDE de 32 bits. O expert e 32 bits (a JvcsExternalDll.dll e a
  fvcscrypt.dll tambem): registrado SO em "Experts". Se algum valor nosso tiver
  ido parar em "Experts x64" (registro manual), ele e removido. }
procedure RemoveFromExpertsX64(const Base, Ver: String);
var
  K, Cur: String;
begin
  K := Base + '\' + Ver + '.0\Experts x64';
  if RegQueryStringValue(HKCU, K, ExpertValueName, Cur) and IsOurExpert(Cur) then
  begin
    RegDeleteValue(HKCU, K, ExpertValueName);
    Log('Expert ' + Ver + ': JVCSIDEClient removido de HKCU\' + K + ' (DLL de 32 bits nao carrega na IDE de 64 bits)');
  end;
end;

{ Desfaz o JVCSIDEClient gravado por esta instalacao. Pfx = prefixo no estado
  ('expert.22' para os experts novos, 'old.10' para as IDEs antigas); DefExpKey
  = chave Experts usada se o estado nao tiver a chave (instalacao anterior). }
procedure UnregisterValue(const Pfx, DefExpKey, Lbl: String);
var
  ExpKey, Cur, Prev: String;
begin
  ExpKey := StateGet(Pfx + '.key');
  if ExpKey = '' then
    ExpKey := DefExpKey;
  if RegQueryStringValue(HKCU, ExpKey, ExpertValueName, Cur) and IsOurExpert(Cur) then
  begin
    Prev := StateGet(Pfx + '.prev');
    if (StateGet(Pfx + '.hadprev') = '1') and (Prev <> '') then
    begin
      RegWriteStringValue(HKCU, ExpKey, ExpertValueName, Prev);
      Log(Lbl + ': JVCSIDEClient restaurado para ' + Prev + ' (' + ExpKey + ')');
    end
    else
    begin
      RegDeleteValue(HKCU, ExpKey, ExpertValueName);
      Log(Lbl + ': JVCSIDEClient removido (' + ExpKey + ')');
    end;
  end
  else
    Log(Lbl + ': JVCSIDEClient em ' + ExpKey + ' nao aponta para esta instalacao; mantido');
  StateSet(Pfx + '.key', '');
  StateSet(Pfx + '.prev', '');
  StateSet(Pfx + '.hadprev', '');
end;

{ Grava HKCU\<IdeKey>\Experts JVCSIDEClient = NewVal, guardando o valor anterior
  (de outra instalacao) no estado. Nao grava se HKCU\<IdeKey> nao existe (IDE
  nunca aberta por este usuario: gravar Experts antes impediria a IDE de criar
  a configuracao padrao). True = gravado. }
function RegisterValue(const Pfx, IdeKey, NewVal, Lbl, Name: String): Boolean;
var
  ExpKey, Cur: String;
begin
  Result := False;
  ExpKey := IdeKey + '\Experts';
  if not RegKeyExists(HKCU, IdeKey) then
  begin
    Log(Lbl + ': HKCU\' + IdeKey + ' nao existe (IDE nunca aberta por este usuario); nao registrado');
    IdeNotes := IdeNotes + FmtMessage(CustomMessage('IdeNeverOpened'), [Name, IdeKey]) + #13#10#13#10;
    Exit;
  end;
  if RegQueryStringValue(HKCU, ExpKey, ExpertValueName, Cur) then
  begin
    if not IsOurExpert(Cur) then
    begin
      StateSet(Pfx + '.prev', Cur);
      StateSet(Pfx + '.hadprev', '1');
      Log(Lbl + ': valor anterior guardado para restaurar na desinstalacao: ' + Cur);
    end
    else if StateGet(Pfx + '.hadprev') = '' then
      StateSet(Pfx + '.hadprev', '0');
  end
  else
  begin
    StateSet(Pfx + '.prev', '');
    StateSet(Pfx + '.hadprev', '0');
  end;
  if RegWriteStringValue(HKCU, ExpKey, ExpertValueName, NewVal) then
  begin
    StateSet(Pfx + '.key', ExpKey);
    Result := True;
    Log(Lbl + ': HKCU\' + ExpKey + ' JVCSIDEClient = ' + NewVal);
  end
  else
    Log(Lbl + ': falha ao gravar HKCU\' + ExpKey);
end;

procedure UnregisterExpert(const Ver: String);
begin
  UnregisterValue('expert.' + Ver, DefaultBdsBase + '\' + Ver + '.0\Experts', 'Expert ' + Ver);
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
  Base, L, Ver, K: String;
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
    RemoveFromExpertsX64(Base, Ver);
    K := Base + '\' + Ver + '.0';
    if not WizardIsComponentSelected('ide\bds' + Ver) then
    begin
      Log('Expert ' + Ver + ': ' + IdeName(Ver) + ' desmarcado pelo usuario; nao registrado');
      Continue;
    end;
    if not IdeExists(Base, Ver) then
    begin
      Log('Expert ' + Ver + ': ' + IdeName(Ver) + ' nao instalado (' + K + ', valor App); nao registrado');
      Continue;
    end;
    if RegisterValue('expert.' + Ver, K, ExpertFileName(Ver), 'Expert ' + Ver, IdeName(Ver)) then
      Done := Done + Ver + ',';
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

{ ------------------------------------------- IDEs antigas (expert original 2.5.0.1030)
  O expert original (JvcsExpertD7.dll / JvcsExpertBDS<n>.dll, fino, ABI de 4 exports
  e 24 callbacks) carrega a JvcsExternalDll.dll da propria pasta; aqui ela e a nova
  (2.5.0.2026). Chaves e nome do valor iguais aos do instalador original 2.5.0.1030
  (unins000.dat): HKCU\Software\<fornecedor>\...\Experts, valor JVCSIDEClient.
  Parametro de TESTE /OLDIDEROOT=Software\Outra troca o "Software" do inicio das
  chaves (HKCU e HKLM); ver setup\LEIAME.md, secao Testes. }

function OldRoot: String;
begin
  Result := ExpandConstant('{param:OLDIDEROOT|' + DefaultOldRoot + '}');
end;

{ chave da IDE (sem HKCU/HKLM): Delphi 7 = Borland\Delphi\7.0; BDS 1-5 = Borland;
  6-7 = CodeGear; 8-21 = Embarcadero }
function OldIdeKey(const Id: String): String;
var
  N: Integer;
begin
  if Id = 'd7' then
    Result := OldRoot + '\Borland\Delphi\7.0'
  else
  begin
    N := StrToIntDef(Id, 0);
    if N <= 5 then
      Result := OldRoot + '\Borland\BDS\' + Id + '.0'
    else if N <= 7 then
      Result := OldRoot + '\CodeGear\BDS\' + Id + '.0'
    else
      Result := OldRoot + '\Embarcadero\BDS\' + Id + '.0';
  end;
end;

function OldIdeName(const Id: String): String;
begin
  case StrToIntDef(Id, 0) of
    1: Result := 'C#Builder 1.0 (BDS 1.0)';
    2: Result := 'Delphi 8 for .NET (BDS 2.0)';
    3: Result := 'Delphi 2005 (BDS 3.0)';
    4: Result := 'Borland Developer Studio 2006 (BDS 4.0)';
    5: Result := 'Delphi 2007 (BDS 5.0)';
    6: Result := 'Delphi 2009 (BDS 6.0)';
    7: Result := 'Delphi 2010 (BDS 7.0)';
    8: Result := 'Delphi XE (BDS 8.0)';
    9: Result := 'Delphi XE2 (BDS 9.0)';
    10: Result := 'Delphi XE3 (BDS 10.0)';
    11: Result := 'Delphi XE4 (BDS 11.0)';
    12: Result := 'Delphi XE5 (BDS 12.0)';
    14: Result := 'Delphi XE6 (BDS 14.0)';
    15: Result := 'Delphi XE7 (BDS 15.0)';
    16: Result := 'Delphi XE8 (BDS 16.0)';
    17: Result := 'Delphi 10 Seattle (BDS 17.0)';
    18: Result := 'Delphi 10.1 Berlin (BDS 18.0)';
    19: Result := 'Delphi 10.2 Tokyo (BDS 19.0)';
    20: Result := 'Delphi 10.3 Rio (BDS 20.0)';
    21: Result := 'Delphi 10.4 Sydney (BDS 21.0)';
  else
    Result := 'Delphi 7';
  end;
end;

function OldComponent(const Id: String): String;
begin
  if Id = 'd7' then
    Result := 'ideold\d7'
  else
    Result := 'ideold\bds' + Id;
end;

function OldExpertFileName(const Id: String): String;
begin
  if Id = 'd7' then
    Result := ExpandConstant('{app}\JvcsExpertD7.dll')
  else
    Result := ExpandConstant('{app}\JvcsExpertBDS' + Id + '.dll');
end;

{ IDE instalada: valor App (exe existente) em HKCU ou HKLM (32 bits) ou, na falta
  dele, RootDir com bin\bds.exe ou bin\delphi32.exe }
function OldIdeInstalledIn(const Root: Integer; const K: String): Boolean;
var
  S: String;
begin
  Result := RegQueryStringValue(Root, K, 'App', S) and FileExists(S);
  if not Result and RegQueryStringValue(Root, K, 'RootDir', S) and (S <> '') then
    Result := FileExists(AddBackslash(S) + 'bin\bds.exe') or FileExists(AddBackslash(S) + 'bin\delphi32.exe');
end;

function OldIdeExists(const Id: String): Boolean;
var
  K: String;
begin
  K := OldIdeKey(Id);
  Result := OldIdeInstalledIn(HKCU, K) or OldIdeInstalledIn(HKLM32, K);
end;

function AnyOldIde: Boolean;
var
  L, Id: String;
begin
  Result := False;
  L := OldIdeIds;
  while (L <> '') and not Result do
  begin
    Id := NextItem(L);
    if Id <> '' then
      Result := OldIdeExists(Id);
  end;
end;

procedure UnregisterOld(const Id: String);
begin
  UnregisterValue('old.' + Id, DefaultOldRoot + Copy(OldIdeKey(Id), Length(OldRoot) + 1, 255) + '\Experts',
    'Expert original ' + Id);
end;

procedure UnregisterAllOld;
var
  L, Id: String;
begin
  L := OldIdeIds;
  while L <> '' do
  begin
    Id := NextItem(L);
    if (Id <> '') and (StateGet('old.' + Id + '.key') <> '') then
      UnregisterOld(Id);
  end;
end;

{ registra as IDEs antigas marcadas; desfaz as desmarcadas/nao mais detectadas }
procedure RegisterOldExperts;
var
  L, Id: String;
  Done: Boolean;
begin
  L := OldIdeIds;
  while L <> '' do
  begin
    Id := NextItem(L);
    if Id = '' then
      Continue;
    Done := False;
    if WizardIsComponentSelected(OldComponent(Id)) then
    begin
      if OldIdeExists(Id) then
        Done := RegisterValue('old.' + Id, OldIdeKey(Id), OldExpertFileName(Id),
          'Expert original ' + Id, OldIdeName(Id))
      else
        Log('Expert original ' + Id + ': ' + OldIdeName(Id) + ' nao instalado (' + OldIdeKey(Id) + '); nao registrado');
    end;
    if not Done and (StateGet('old.' + Id + '.key') <> '') then
      UnregisterOld(Id);
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
  Result := SameDir(D, ExpandConstant('{commonpf32}\JEDI\JVCS'));
  if Result then
    Exit;
  { pasta desta versao (reinstalacao): tem os experts ORIGINAIS das IDEs antigas,
    mas a JvcsExternalDll.dll ou o jedivcs.exe sao 2.5.0.2026 }
  if (GetVersionNumbersString(D + '\JvcsExternalDll.dll', V) and (V = '{#AppVersion}')) or
     (GetVersionNumbersString(D + '\jedivcs.exe', V) and (V = '{#AppVersion}')) then
    Exit;
  Result := FileExists(D + '\JvcsExpertBDS21.dll') or FileExists(D + '\JvcsExpertD7.dll') or
            FileExists(D + '\server\JVCSSrv.exe') or FileExists(D + '\JVCSSrv.exe');
  if not Result and FileExists(D + '\jedivcs.exe') then
    Result := GetVersionNumbersString(D + '\jedivcs.exe', V) and (V <> '{#AppVersion}');
end;

{ ---------------------------------------------------------------- eventos do assistente }

procedure InitializeWizard;
begin
  { As IDEs detectadas ja aparecem como subcomponentes (ide\bds22/23/37 e ideold\*);
    o titulo do grupo nao repete a lista (beta 5). }
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
  if WizardIsComponentSelected('ide') or WizardIsComponentSelected('ideold') or
     ExpertFilesIn(WizardDirValue) then
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
    RegisterOldExperts;
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
    UnregisterAllOld;
    RevertAiConsole;
    StateSave;
  end;
end;
