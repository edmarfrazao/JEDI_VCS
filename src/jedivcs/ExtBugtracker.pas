(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Example usage for MantisBT
--------------------------
URL:     http://your.server.here/mantis/view.php?id={bug}
RegEx:   (?i)MANTIS +#*(?<bug>[\d]+)


Last Modified: see History

Known Issues:
- (v2026) System.RegularExpressions; pcre3.dll nao e mais necessaria
-----------------------------------------------------------------------------

Unit history:

2012/07/08  AKröber     - First Implementation
2026/10/13  v2026      - JclPCRE -> System.RegularExpressions.TRegEx

-----------------------------------------------------------------------------*)

unit ExtBugtracker;

interface

uses
  Windows, SysUtils, Menus, ComCtrls;

procedure CheckCommentForExternalBugtrackerReference(AListItem: TListItem; AMenuItem, ASeparator: TMenuItem);
procedure OpenExternalBugtracker;

implementation

uses
  System.RegularExpressions, Dialogs, VcsBase, ShellAPI;

var
  LastBugReference: string = '';

procedure CheckCommentForExternalBugtrackerReference(AListItem: TListItem; AMenuItem, ASeparator: TMenuItem);
var
  M: TMatch;
  S: string;
begin
  LastBugReference := '';
  if (sBugtrackerURL <> '') and (sBugtrackerRegEx <> '') and Assigned(AListItem) and (AListItem.SubItems.Count > 4) then
  begin
    S := AListItem.SubItems[4];
    if S <> '' then
    begin
      // v2026: System.RegularExpressions (PCRE da RTL) no lugar da JclPCRE.
      // Grupo nomeado "bug"; sem ele, o 1o grupo; sem grupos, o trecho todo.
      // Regex invalida nao derruba o historico (o item so fica oculto).
      try
        M := TRegEx.Match(S, sBugtrackerRegEx);
        if M.Success then
        begin
          try
            LastBugReference := M.Groups['bug'].Value;
          except
            if M.Groups.Count > 1 then
              LastBugReference := M.Groups[1].Value
            else
              LastBugReference := M.Value;
          end;
        end;
      except
        LastBugReference := '';
      end;
    end;
  end;

  if LastBugReference <> '' then
  begin
    AMenuItem.Caption := Format('Open Bug "%s" in external bugtracker', [LastBugReference]);
  end;
  AMenuItem.Visible  := LastBugReference <> '';
  ASeparator.Visible := AMenuItem.Visible;
end;

procedure OpenExternalBugtracker;
begin
  ShellExecute(0, 'open', PChar(StringReplace(sBugtrackerURL, '{bug}', LastBugReference, [])), nil, nil, sw_ShowNormal);
end;

end.
