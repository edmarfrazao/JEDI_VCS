(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: GetGlobalSettings.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDIVCS: Thomas Huber (Thomas_D_Huber@t-online.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FreeVCS code to JEDI-VCS
2003/03/05  THensle   - changes for "ConfigStorage" unit
2005/06/30  CSchuette - added option "check in comment required"

-----------------------------------------------------------------------------

   Next free global option ID is 19.
                           
-----------------------------------------------------------------------------*)
{$I JEDI.INC}

unit GetGlobalSettings;

{$I COMPOPT.INC}

interface

uses
  Windows, Classes, Forms;

procedure GetGlobalUserSettings(App : TApplication; WHandle : HWND);

implementation

uses SysUtils, VCSBase, VCSProcBase, DBModule, ConfigStorage;

procedure GetGlobalUserSettings;
var
  i : integer;
begin
  with DataModule1 do
  begin
    AppSrvClient1.Request.Rewrite;
    AppSrvClient1.FunctionCode := 'READ_CONFIG_DATA';
    AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
    AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
    for i := 1 to 18 do
      AppSrvClient1.Request.WriteFields(True, ['Option' + IntToStr(i)]);
    SetupTimeoutCounter;
    AppSrvClient1.Send;

    while WaitForAppSrvClient do
      App.ProcessMessages;
    if (AppSrvClientErr = -99) then
    begin
      ShowServerTimeOut(WHandle);
      Exit;
    end;
    if (AppSrvClientErr <> 0) or
      (AppSrvClient1.AnswerStatus <> '200') then
    begin
      ShowServerError(WHandle, AppSrvClient1.Answer.Fields[0],
        AppSrvClient1.AnswerStatus);
      Exit;
    end;

    AppSrvClient1.Answer.First;
    while not AppSrvClient1.Answer.EOF do
    begin
      if (AppSrvClient1.Answer.Fields[1] <> '???') then
        jvcsWriteString(sBaseRegistryKey + crbOptions + '\CCS',
          AppSrvClient1.Answer.Fields[0], AppSrvClient1.Answer.Fields[1]);
      AppSrvClient1.Answer.Next;
    end;
  end; // with DataModule1 do begin
end;

end.
