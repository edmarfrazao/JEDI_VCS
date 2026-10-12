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

Example usage for SaveWIP
--------------------------
Command:  c:\7zip\7z.exe a "%USERPROFILE%\JVCS-Backup-#y##m##d#-#h##m##s#.7z" @"#vcslistfile#"

          since 7-Zip 9.20 does not preserve folders, I used "IZArc Command Line Add-On"

          c:\IZArc\IZARCC.EXE -a -cb -P "%USERPROFILE%\JVCS-Backup-#y##m##d#-#h##m##s#.zip" @"#vcslistfile#"

Last Modified: see History

-----------------------------------------------------------------------------

Unit history:

2012/07/08  AKröber     - First Implementation

-----------------------------------------------------------------------------*)

unit SaveWIP;

interface

uses
  Windows, Classes, SysUtils;

procedure DoSaveWIP;
procedure DoSaveWIPonclose;

implementation

uses
  VcsBase, JVCSClientObj, DBModule, JclSysInfo, VCSProcBase, ShellAPI;

procedure DoSaveWIP;
var
  GetLockedModules: TJVCSGetLockedModules;
  I,J: Integer;
  S,ListFile,Command: string;
  Files,Addi: TStringList;
  SI: TStartupInfo;
  PI: TProcessInformation;
begin
  if sSaveWIPcommand <> '' then
  begin
    Files := TStringList.Create;
    Addi  := TStringList.Create;
    try
      GetLockedModules := TJVCSGetLockedModules.Create(nil);
      try
        GetLockedModules.UserID := ServerUserID;
        DataModule1.ClientObjectSendRequest(GetLockedModules);

        with GetLockedModules do
          for I := 0 to Pred(OutputItemCount) do
          begin
            S := OutputItems[I].ModulePath + OutputItems[I].ModuleName;
            Files.Add(S);
            Addi.Clear;
            GetAdditionalFilesFromFileFamily(S, Addi);
            for J := 0 to Pred(Addi.Count) do
              Files.Add(Addi[J]);
          end;
      finally
        GetLockedModules.Free;
      end;

      if Files.Count > 0 then
      begin
        S := GetAppdataFolder + '\JEDI\JVCS';
        if not DirectoryExists(S) then
          ForceDirectories(S);

        ListFile := S + '\SaveWIP.lst';

        Files.SaveToFile(ListFile);

        Command := sSaveWIPcommand;

        Command := StringReplace(Command, '#y#', FormatDateTime('yyyy', Now), [rfReplaceAll, rfIgnoreCase]);
        Command := StringReplace(Command, '#m#', FormatDateTime('mm', Now), [rfReplaceAll, rfIgnoreCase]);
        Command := StringReplace(Command, '#d#', FormatDateTime('dd', Now), [rfReplaceAll, rfIgnoreCase]);
        Command := StringReplace(Command, '#h#', FormatDateTime('hh', Now), [rfReplaceAll, rfIgnoreCase]);
        Command := StringReplace(Command, '#n#', FormatDateTime('nn', Now), [rfReplaceAll, rfIgnoreCase]);
        Command := StringReplace(Command, '#s#', FormatDateTime('ss', Now), [rfReplaceAll, rfIgnoreCase]);

        Command := StringReplace(Command, '#vcsusername#', sCurrentUser, [rfReplaceAll, rfIgnoreCase]);
        Command := StringReplace(Command, '#vcslistfile#', ListFile, [rfReplaceAll, rfIgnoreCase]);

        ExpandEnvironmentVar(Command);

        FillChar(SI, SizeOf(SI), #0);
        SI.cb := SizeOf(SI);
        SI.dwFlags := STARTF_USESHOWWINDOW;
        SI.wShowWindow := SW_SHOWMINNOACTIVE;
        CreateProcess(nil, PChar(Command), nil, nil, False, 0, nil, nil, SI, PI);
      end;
    finally
      Files.Free;
      Addi.Free;
    end;
  end;
end;

procedure DoSaveWIPonclose;
begin
  if bSaveWIPauto then DoSaveWIP;
end;

end.

