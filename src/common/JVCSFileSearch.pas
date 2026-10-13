(*-----------------------------------------------------------------------------
JEDI VCS 2.5 Beta 2026 (port Delphi 13) - JVCSFileSearch.pas

FindRecursive nativo, no lugar da unit RekScan (FreeVCS, sem fonte). Semantica
inferida dos chamadores (SelectFolder, CompareFolders):
  - Path sempre com barra final;
  - primeiro os arquivos da pasta, depois as subpastas (recursivo);
  - o callback recebe so arquivos; se devolver False, a busca inteira para.
Licenca: MPL 1.1.
-----------------------------------------------------------------------------*)

unit JVCSFileSearch;

interface

uses
  System.SysUtils;

type
  TJVCSFindFileCallback = function(const Path: string; const SRec: TSearchRec): Boolean of object;

function FindRecursive(const APath, AMask: string; ACallback: TJVCSFindFileCallback): Boolean;

implementation

function FindRecursive(const APath, AMask: string; ACallback: TJVCSFindFileCallback): Boolean;
var
  Path: string;
  SRec: TSearchRec;
begin
  Result := True;
  Path := IncludeTrailingPathDelimiter(APath);
  if FindFirst(Path + AMask, faAnyFile, SRec) = 0 then
  try
    repeat
      if (SRec.Attr and faDirectory) = 0 then
        if not ACallback(Path, SRec) then
        begin
          Result := False;
          Exit;
        end;
    until FindNext(SRec) <> 0;
  finally
    FindClose(SRec);
  end;
  if FindFirst(Path + '*.*', faDirectory, SRec) = 0 then
  try
    repeat
      if ((SRec.Attr and faDirectory) <> 0) and (SRec.Name <> '.') and (SRec.Name <> '..') then
        if not FindRecursive(Path + SRec.Name, AMask, ACallback) then
        begin
          Result := False;
          Exit;
        end;
    until FindNext(SRec) <> 0;
  finally
    FindClose(SRec);
  end;
end;

end.
