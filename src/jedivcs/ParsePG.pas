(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: ParsePG.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS: Thomas Huber (Thomas_D_Huber@t-online.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber     - 1st Migrationstep from FreeVCS code to JEDI VCS
2003/11/19  USchuster  - changed 'FreeVCS' in messageboxes to 'JEDI VCS'
                         with constant cMsgBoxCaption from VCSBase.pas
2004/10/24  USchuster  - style cleaning
                       - res strings and displayed strings changed to resourcestrings
2004/10/25  Victorious - fix bug with delphi packages bpl -> dpk
2004/11/02  USchuster  - moved resourcestrings to JVCSGUIClientResources.pas

-----------------------------------------------------------------------------*)
{$I jedi.inc}

unit ParsePG;

{$I compopt.inc}

interface

uses
  Windows;

function ParseProjectGroup(GroupName: string; const AppHandle: HWND): string;

implementation

uses
  SysUtils, Classes, VCSBase, JVCSGUIClientResources;

function ParseProjectGroup(GroupName: string; const AppHandle: HWND): string;
var 
  I, CurrentLine: Integer;
  ParseStr, CurrentToken: string;
  GroupList, ProjectList: TStringList;

  function GetToken(var SearchString: string): string;
  var 
    Token: string;
  begin
    Result := '';
    Token := '';
    while SearchString[1] = ' ' do 
      Delete(SearchString, 1, 1);
    repeat
      Token := Token + SearchString[1];
      Delete(SearchString, 1, 1);
    until (Length(SearchString) = 0) or (SearchString[1] = ' ');
    Result := Token;
  end;
begin
  Result := '';
  try
    GroupList := TStringList.Create;
    ProjectList := TStringList.Create;
    try
      try
        GroupList.LoadFromFile(GroupName);
      except
        on E: 
        Exception do 
        begin
          GroupList.Free;
          MessageBox(AppHandle, PChar(Format(JVCSRES_Reading_file_6037s62 + #13#10 +
            JVCSRES_raised_exception58 + #13#10 + '%s.', [GroupName, E.Message])),
            cMsgBoxCaption, MB_OK or MB_ICONSTOP);
          Exit;
        end;
      end;
      for I := 0 to GroupList.Count - 1 do 
      begin
        if Pos('PROJECTS =', GroupList.Strings[I]) <> 0 then 
        begin
          ParseStr := GroupList.Strings[I];
          CurrentLine := I;
          // PROJECTS entfernen
          repeat
            Delete(ParseStr, 1, 1);
          until (Length(ParseStr) = 0) or (ParseStr[1] = '=');
          if Length(ParseStr) = 0 then 
            Exit;
          // = entfernen
          Delete(ParseStr, 1, 1);
          repeat
            CurrentToken := GetToken(ParseStr);
            if CurrentToken <> '\' then 
              ProjectList.Add(LowerCase(CurrentToken));
          until Length(ParseStr) = 0;
          // folgende Zeilen
          while GroupList.Strings[CurrentLine][Length(GroupList.Strings[CurrentLine])] = '\' do 
          begin
            Inc(CurrentLine);
            ParseStr := GroupList.Strings[CurrentLine];
            repeat
              CurrentToken := GetToken(ParseStr);
              if CurrentToken <> '\' then 
                ProjectList.Add(LowerCase(CurrentToken));
            until Length(ParseStr) = 0;
          end; // while GroupList.Strings[CurrentLine][Length...
          Break;
        end; // if Pos('PROJECTS =', GroupList.Strings[I]) <> 0 then begin
      end; // for I := 0 to GroupList.Count - 1 do begin

      for I := 0 to ProjectList.Count - 1 do
      begin
        if (ExtractFileExt(ProjectList.Strings[I]) = '.exe') or
          (ExtractFileExt(ProjectList.Strings[I]) = '.dll') then
          ProjectList.Strings[I] := ChangeFileExt(ProjectList.Strings[I], '.dpr')
        else
        if (ExtractFileExt(ProjectList.Strings[I]) = '.bpl') then
          ProjectList.Strings[I] := ChangeFileExt(ProjectList.Strings[I], '.dpk');
        Result := Result + ProjectList.Strings[I] + '|';
      end; // for I := 0 to ProjectList.Count - 1 do begin

    finally
      GroupList.Free;
      ProjectList.Free;
    end;
  except
    on E: 
    Exception do
      MessageBox(AppHandle, PChar(E.Message), cMsgBoxCaption, MB_OK or MB_ICONSTOP);
  end;
end;

end.
