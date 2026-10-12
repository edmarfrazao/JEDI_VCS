(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: SMTPSend

The Initial Developer of the original FreeVCS-Code (FreeVCS) is: Thomas Hensle (freevcs@thensle.de)
Code move to JEDIVCS: Thomas Huber (Thomas_D_Huber@t-online.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:                                                                                    }

2003/01/31  THuber    - 1st Migrationstep from FreeVCS code to JEDI-VCS
                                                                                                  }
-----------------------------------------------------------------------------*)
{$I JEDI.INC}

unit SMTPSend;

interface

function PrepareSMTP(const Source, Machine, Target, Subject, Project : string;
  Msg : string; const MsgType : word) : boolean;

function CountSMTPRecords(var Size : integer) : word;

implementation

uses VCSBase, VCSProcBase, IniFiles, SysUtils, TZHandling;

function PrepareSMTP(const Source, Machine, Target, Subject, Project : string;
  Msg : string; const MsgType : word) : boolean;
var 
  TargetFile, TargetPath, Num : string;
  i : integer;
begin
  Result := False;
  TargetPath := sDLLDirectory + 'SMTP\';
  TargetFile := 'fvcsmail_000.mail';
  i := 1;
  //get a filename
  while FileExists(TargetPath + TargetFile) do 
  begin
    Num := IntToStr(i);
    while Length(Num) < 3 do 
      Num := '0' + Num;
    TargetFile := 'fvcsmail_' + Num + '.mail';
    Inc(i);
    if i > 998 then
      Exit;
  end; // while FileExists(TargetPath + TargetFile) do begin
  if (Pos(#10, Msg) > 0) or (Pos(#13, Msg) > 0) then
    for i := 1 to Length(Msg) do
      if (Msg[i] = #10) or (Msg[i] = #13) then 
      begin
        Delete(Msg, i, 1);
        Insert(' ', Msg, i);
      end;

  with TIniFile.Create(TargetPath + TargetFile) do 
  begin
    try
      WriteInteger('FVCSMail', 'Type', MsgType);
      WriteFloat('FVCSMail', 'Timestamp', Now);
      WriteFloat('FVCSMail', 'GMTDiff', GetClientGMTDiff);
      WriteString('FVCSMail', 'To', Target);
      WriteString('FVCSMail', 'From', Source);
      WriteString('FVCSMail', 'Location', Machine);
      WriteString('FVCSMail', 'Subject', Subject);
      WriteString('FVCSMail', 'Project', Project);
      WriteString('FVCSMail', 'Message', Msg);
    finally
      Free;
    end;
  end;
  Result := True;
end;

function CountSMTPRecords(var Size : integer) : word;
var 
  Srec : TSearchrec;
  i : integer;
begin
  Result := 0;
  Size := 0;
  i := FindFirst(sDLLDirectory + 'SMTP\*_???.mail',
    faAnyFile and (not faDirectory), Srec);
  try
    while i = 0 do 
    begin
      if (SRec.Name <> '.') and (SRec.Name <> '..') then 
      begin
        Inc(Result);
        Size := Size + Srec.Size;
      end;
      i := FindNext(SRec);
    end;
  finally
    FindClose(SRec);
  end;
end;

end.
