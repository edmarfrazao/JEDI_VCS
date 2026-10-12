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
- define PCRE_STATICLINK or supply pcre3.dll for RegEx
-----------------------------------------------------------------------------

Unit history:

2012/07/08  AKröber     - First Implementation

-----------------------------------------------------------------------------*)

unit ExtBugtracker;

interface

uses
  Windows, SysUtils, Menus, ComCtrls;

procedure CheckCommentForExternalBugtrackerReference(AListItem: TListItem; AMenuItem, ASeparator: TMenuItem);
procedure OpenExternalBugtracker;

implementation

uses
  JclPCRE, Dialogs, VcsBase, ShellAPI;

var
  LastBugReference: string = '';

procedure CheckCommentForExternalBugtrackerReference(AListItem: TListItem; AMenuItem, ASeparator: TMenuItem);
var
  R: TJclRegEx;
  S: string;
begin
  LastBugReference := '';
  if (sBugtrackerURL <> '') and (sBugtrackerRegEx <> '') and Assigned(AListItem) and (AListItem.SubItems.Count > 4) then
  begin
    S := AListItem.SubItems[4];
    if S <> '' then
    begin
      R := TJclRegEx.Create;
      try
        R.Compile(sBugtrackerRegEx, False, False);
        if R.Match(S) then
          LastBugReference := R.NamedCaptures['bug'];
      finally
        R.Free;
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
