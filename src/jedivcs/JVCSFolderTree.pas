(*-----------------------------------------------------------------------------
JEDI VCS 2.5 Beta 2026 (port Delphi 13) - JVCSFolderTree.pas

TJVCSFolderTreeView: substituto nativo da TdfsSystemTreeView 0.98.5 (DFS) no
SelectFolder, escrito sobre o TShellTreeView da VCL (Vcl.Shell.ShellCtrls).
Mantem a API usada pelo cliente: Selection (pasta), RootFolder, AddNewNode,
Reset e PopupMenuMethod (so para carregar o DFM).
Licenca: MPL 1.1.
-----------------------------------------------------------------------------*)

unit JVCSFolderTree;

interface

uses
  System.SysUtils, System.Classes, Vcl.ComCtrls, Vcl.Shell.ShellCtrls;

type
  TRootFolder = (rfDesktop, rfFileSystem);
  TPopupMenuMethod = (pmmNone, pmmSystem, pmmUser, pmmSystemAndUser);

  TJVCSFolderTreeView = class(TShellTreeView)
  private
    FRootFolder: TRootFolder;
    FPopupMenuMethod: TPopupMenuMethod;
    function GetSelection: string;
    procedure SetSelection(const Value: string);
    procedure SetRootFolder(const Value: TRootFolder);
  public
    constructor Create(AOwner: TComponent); override;
    function AddNewNode(ParentNode: TTreeNode; const AName: string;
      SelectNode: Boolean): Boolean;
    procedure Reset;
    property Selection: string read GetSelection write SetSelection;
    property RootFolder: TRootFolder read FRootFolder write SetRootFolder;
  published
    property ReadOnly;
    property PopupMenuMethod: TPopupMenuMethod read FPopupMenuMethod write FPopupMenuMethod default pmmUser;
  end;

implementation

constructor TJVCSFolderTreeView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPopupMenuMethod := pmmUser;
  FRootFolder := rfDesktop;
  ObjectTypes := [otFolders];
  HideSelection := False;
end;

function TJVCSFolderTreeView.GetSelection: string;
begin
  Result := Path;
  if (Result <> '') and not DirectoryExists(Result) then
    Result := '';
end;

procedure TJVCSFolderTreeView.SetSelection(const Value: string);
begin
  if (Value <> '') and DirectoryExists(Value) then
  try
    Path := ExcludeTrailingPathDelimiter(Value);
  except
    // pasta inacessivel: mantem a selecao atual
  end;
end;

procedure TJVCSFolderTreeView.SetRootFolder(const Value: TRootFolder);
begin
  FRootFolder := Value;
end;

function TJVCSFolderTreeView.AddNewNode(ParentNode: TTreeNode;
  const AName: string; SelectNode: Boolean): Boolean;
var
  Base, NewDir: string;
begin
  Result := False;
  Base := GetSelection;
  if Base = '' then
    Exit;
  NewDir := IncludeTrailingPathDelimiter(Base) + AName;
  if DirectoryExists(NewDir) then
    Exit;
  Result := CreateDir(NewDir);
  if Result then
  begin
    Reset;
    if SelectNode then
      SetSelection(NewDir);
  end;
end;

procedure TJVCSFolderTreeView.Reset;
begin
  if Selected <> nil then
    Refresh(Selected);
end;

end.
