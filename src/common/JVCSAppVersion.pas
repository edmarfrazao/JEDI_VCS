(* JEDI VCS 2.5 Beta 2026 - JVCSAppVersion.pas. Licenca: MPL 1.1.

   Texto de versao para o usuario (titulo da janela, About, banner do console),
   lido em tempo de execucao do VERSIONINFO do proprio modulo - sem numero fixo
   no codigo. Os valores vem de tools\versao.ini (fonte unica), gravados nos
   jvcsver.rc pelo build (tools\gerar-versao.ps1):
     InternalVersion "2.5.0 Beta 5 (2026)" + FILEVERSION 2,5,0,2050
       -> JVCSVersionLabel = "2.5.0 Beta 5 - build 2050"
   A versao do LOGIN NAO vem daqui (VCSProcBase.GetJVCSAppProductVersionInt,
   PRODUCTVERSION fixo 2,5,0,0 = 250). So API do Windows: serve ao EXE, DLL,
   Diff e console. *)

unit JVCSAppVersion;

interface

{ valor de \StringFileInfo\<idioma><codepage>\AKey ('' se nao houver) }
function JVCSVersionString(const AFileName, AKey: string): string;
{ 4o campo do FILEVERSION numerico (2050); -1 se nao houver VERSIONINFO }
function JVCSFileBuild(const AFileName: string): Integer;
{ "2.5.0 Beta 5" + ASeparator + "build 2050": InternalVersion sem o sufixo
  "(2026)" + build do FILEVERSION. Sem InternalVersion: o FileVersion. }
function JVCSVersionLabel(const AFileName: string; const ASeparator: string = ' - '): string;
{ arquivo do modulo que contem esta unit (EXE ou DLL) }
function JVCSModuleFileName: string;

implementation

uses
  Windows, SysUtils;

type
  TJVCSLangCP = packed record
    Lang, CodePage: Word;
  end;
  PJVCSLangCP = ^TJVCSLangCP;

function ReadVersionBuffer(const AFileName: string; out ABuf: TBytes): Boolean;
var
  Size, Dummy: DWORD;
begin
  Result := False;
  SetLength(ABuf, 0);
  if AFileName = '' then
    Exit;
  Size := GetFileVersionInfoSize(PChar(AFileName), Dummy);
  if Size = 0 then
    Exit;
  SetLength(ABuf, Size);
  Result := GetFileVersionInfo(PChar(AFileName), 0, Size, @ABuf[0]);
end;

function JVCSVersionString(const AFileName, AKey: string): string;
var
  Buf: TBytes;
  Tr: PJVCSLangCP;
  P: PChar;
  L: UINT;
begin
  Result := '';
  if not ReadVersionBuffer(AFileName, Buf) then
    Exit;
  if VerQueryValue(@Buf[0], '\VarFileInfo\Translation', Pointer(Tr), L) and
    (L >= SizeOf(TJVCSLangCP)) and
    VerQueryValue(@Buf[0], PChar(Format('\StringFileInfo\%.4x%.4x\%s',
      [Tr^.Lang, Tr^.CodePage, AKey])), Pointer(P), L) and (L > 0) then
    Result := P;
end;

function JVCSFileBuild(const AFileName: string): Integer;
var
  Buf: TBytes;
  Fixed: PVSFixedFileInfo;
  L: UINT;
begin
  Result := -1;
  if ReadVersionBuffer(AFileName, Buf) and
    VerQueryValue(@Buf[0], '\', Pointer(Fixed), L) and (L >= SizeOf(TVSFixedFileInfo)) then
    Result := LoWord(Fixed^.dwFileVersionLS);
end;

function JVCSVersionLabel(const AFileName: string; const ASeparator: string): string;
var
  Internal: string;
  P, Build: Integer;
begin
  Internal := Trim(JVCSVersionString(AFileName, 'InternalVersion'));
  // "2.5.0 Beta 5 (2026)" -> "2.5.0 Beta 5"
  if (Internal <> '') and (Internal[Length(Internal)] = ')') then
  begin
    P := LastDelimiter('(', Internal);
    if P > 1 then
      Internal := TrimRight(Copy(Internal, 1, P - 1));
  end;
  if Internal = '' then
  begin
    Result := Trim(JVCSVersionString(AFileName, 'FileVersion'));
    Exit;
  end;
  Result := Internal;
  Build := JVCSFileBuild(AFileName);
  if Build >= 0 then
    Result := Result + ASeparator + 'build ' + IntToStr(Build);
end;

function JVCSModuleFileName: string;
begin
  Result := GetModuleName(HInstance);
end;

end.