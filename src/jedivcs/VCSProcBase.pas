(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: VCSProcBase.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS: Thomas Huber (Thomas_D_Huber@gmx.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
Oct/04
- USc: possible translation bug -> see ShowServerError
ToDo
- make strings in DecodeShellErr resourcestrings? (use SysErrorMessage?)
- better solution for D2005 project extensions
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FreeVCS code to JEDI VCS
2003/02/12  USchuster - changed DSAMsg with JVCSDialogs in uses clause to use JvDSADialogs
                      - D5 Fix in Set/ClearBackSlash
2003/03/06  THensle   - changes for "ConfigStorage" unit
2003/03/08  USchuster - added function for execution of TFavOpenDialog which
                        will do the Mru stuff
2003/03/10  USchuster - fixed Range Check Error in IsTextStream (mantis #772)
                      - new function IsBinaryDFMStream
2003/03/15  THuber    - platform compilerwarning removed
2003/03/16  THensle   - (GPL) HtmlHelpAPI unit replaced by (MPL) HtmlHlp
2003/03/26  USchuster - new function ExtractFileExtWithoutDot
2003/05/20  MGosselink- new function BroadcastMessage
2003/05/22  USchuster - new function SetDockClientToActivePage
2003/08/31  USchuster - new functions GetAcceleratedMenuName,
                        GetSelfFileName, GetSelfFileLocation,
                        GetProductAndOSVersionString and GetDelphiVersion
                      - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes
2003/09/15  USchuster - new function IsDockClientActivePage
2003/12/27  THuber    - moved two functions to JVCSClientFunctions
                      - new functions return Product-/Fileversion from App/Dll
                      - Aboutmenuitem & Mainmenuitem does no more show versionno.
                      - some cleanup
2003/12/27  USchuster - new function CleanCompareDirectories
2003/12/28  USchuster - fixed GetAcceleratedMenuName
                      - minor style cleaning
2004/04/10  USchuster - new function CompareDateTimeStrs (necessary for mantis #1557)
                      - minor style cleaning
2004/04/14  USchuster - added extension .JVCS in GetFileType
2004/10/30  USchuster - res strings and displayed strings changed to resourcestrings
2004/10/31  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
2004/11/27  USchuster - new functions ExistMutex and InitAndOpenConfigStorage
2005/01/16  USchuster - new functions BuildShortCut and ReadShortcutsFromStorage
                        for mantis #1956
2005/04/03  USchuster - fixed MatchWithFilter(uses now JclStrings.StrMatches)
                        because it failed for several strings(especially for
                        filenames with multiple dots) (mantis #2825)
2005/04/17  USchuster - temporary workaround for D2005 in order to support
                        Delphi.Net and C# Personality
2005/04/25  CSchuette - added ResolveFileFamilies which will change file extension
                        to match with the "main extension" of the defines file
                        families (mantis #2891)
2005/05/05  CSchuette - some changes to ResolveFileFamilies
2005/05/11  CSchuette - speeded up ResolveFileFamilies if called within 5000 msec
                        for the same file again (cache old result)
2005/05/12  CSchuette - fixed bug that ResolveFileFamilies will return a file
                        name which does not exists on local drive.
2005/06/04  USchuster - moved LANGUAGE stuff from ProjAdmin.pas into InitAndOpenConfigStorage
2005/06/28  USchuster - added new functions to save/restore a project state (for mantis #3033)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC3 was released ^^^^^^^^^^^^^^^^^^^^^^^^^^^
2006/01/01  USchuster - changes for more flexible shortcuts (mantis #3397)
2006/01/04  USchuster - fixed OpenProjectByName(Open Project in Search Modules didn't work)
2006/01/08  USchuster - fixed ResolveFileFamilies (mantis #3423; cached version didn't check
                        the full module name and previous calls without path could lead
                        to wrong results; now the full module name will be checked)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 released ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
2006/04/29  THuber    #3668 shell folder local appdata now used for compared files
2006/07/09  USchuster - fixed CleanCompareDirectories(separator was missing before JEDI\JVCS\COMPARE)
2006/12/10  USchuster - moved IsBinaryFile and IsBinaryDFMStream to JVCSClientFunctions.pas
                      - removed MatchWithFilter (is since 2006/04/12 in JVCSClientFunctions.pas)
2007/03/07  USchuster - added ShellOpenParentFolder (mantis #4079)
                      - changed GetJVCSAppFileVersion to cache to file version
2007/04/09  USchuster - fixed GetFileType (mantis #4095)
2007/04/26  USchuster - changes for D2007
2007/06/21  USchuster - changes for C++Builder 2007 (Mantis #4157)
2007/07/08  USchuster - removed the bProjectOpen check in ResolveFileFamilies and GetAdditionalFilesFromFileFamily
                        to get them working in all situations (necessary for Mantis #4075 [missing .dfm's in IDE backup])
2007/08/13  USchuster - Trace -> TraceMsg                        
2010/01/23  THuber    #5121 added overloaded version of GetJVCSAppFileVersion
2010/01/24  THuber  -  directive H T M L H L P  removed
-----------------------------------------------------------------------------*)

unit VCSProcBase;

{$I jedi.inc}
{$I compopt.inc}

{$IFDEF DELPHI6_UP}
  {$WARN UNIT_PLATFORM OFF}
  {$WARN SYMBOL_PLATFORM OFF}
{$ENDIF DELPHI6_UP}

// we need this unit to share a couple of functions during the project

interface

uses
  { TODO -oFL : Verify uses for FavOpenDialog }
  {$IFDEF DEBUG}
  JclDebug,
  {$ENDIF DEBUG}
  Windows, Forms, Classes, VCSBase,
  {$ifdef JCLVER_2_UP}
  JclOpenDialogFavorites,
  {$else}
  FavOpenDialog,
  {$endif}
  Messages, Controls, ComCtrls;

{$IFDEF CUSTOMDRIVE}
function ChangeDriveName(const Path, NewDrive: string): string;
{$ENDIF CUSTOMDRIVE}
function IsIDEProject(FileName, CurrentProjectName: string): Boolean;
function IsIDEPackage(FileName: string): Boolean;
function IsIDEUnit(FileName: string): Boolean;
function SettingIsGlobal(Nr: Integer): Boolean;
function GlobalSettingValue(Nr: Integer): Boolean;
procedure ShowGlobalSettingsWarning(const Hnd: HWND; ForcedState: Boolean);
function FastLowerCase(const S: string): string;
function RemoveCRLF(const InString: string): string;
function TrimRight(const InString: string): string;
function GetUpTimeStr: string;
procedure PerformHelpCommand(App: TApplication; Ctx: Integer);
function GetDllLocation(const DLLModule: HINST): string;
procedure BeepIfSet;
function GetFileType(FileName: string): string;
procedure ShowServerTimeOut(const Hnd: HWND);
procedure ShowServerError(const Hnd: HWND; Msg: string; const State: string);
function CtrlSCDisabled(const Hnd: HWND): Boolean;
procedure SetUpUserInfo;
function IsValidProjectName(const Project: string; var ErrMsg: string): Boolean;
function IsValidModuleName(const Module: string; var ErrMsg: string): Boolean;
function _GetFileSize(const Path: string): Longint;
function _GetFileSizeEx(const Path: string; var OriginalName: string): Longint;
function _StrToInt(Value: string): Integer;
function _StrToFloat(Value: string): Double;
function CreateTargetDir(const Target: string): Integer;
function HasAssociateFile(const FileName: string; var AssociateName: string): Boolean;
function CutPathStr(const S: string; const Len: Integer): string;
function MkDirEx(Bez: string): Boolean;
function GetFreeTempName: string;
function GetUniqueFileName: string;
function _CopyFile(const Source, Dest: string): Boolean;
function CheckDefaultPrinter: Boolean;
function SetBackSlash(const Value: string): string;
function ClearBackSlash(const Value: string): string;
function GetOriginalFileName(const FileName: string): string;
function DeleteToRecycleBin(WindowHandle: HWND; const FileName: string): Boolean;
function GetAttrStrEx(const FName: string): string;
function DecodeShellErr(const Index: Integer): string;
function WriteTimeLog(const FileName, Value: string): Boolean;
function SearchAndChange(const TextString, SearchString, ChangeString: string): string;
{$IFDEF DBGFILE}
procedure DebugFile(const Value: string);
{$ENDIF DBGFILE}
function ExecuteFavOpenDialogWithMru(AFavOpenDialog: TFavOpenDialog; AKey: string): Boolean;
function ExtractFileExtWithoutDot(AFileName: string): string;
procedure BroadcastMessage(Msg: Cardinal; wParam, lParam: Integer);
procedure SetDockClientToActivePage(APageControl: TPageControl; AClient: TControl);
function IsDockClientActivePage(APageControl: TPageControl; AClient: TControl): Boolean;
function GetAcceleratedMenuName(AAcceleratorIndex: Integer;
  AConfig: Boolean = False): string;
function GetProductAndOSVersionString: string;
{$IFDEF IDEDLL}
function GetDelphiVersion: Integer;
{$ENDIF IDEDLL}
procedure CleanCompareDirectories;

function GetJVCSAppProductVersion: string;
function GetJVCSAppProductVersionInt: Integer;
function GetJVCSAppFileVersion: string;overload;
function GetJVCSAppFileVersion(const sFileName : String) : String;overload;

function CompareDateTimeStrs(const ADateTimeStr1, ADateTimeStr2: string): Integer;
function ExistMutex(AMutex: string): Boolean;
procedure InitAndOpenConfigStorage;
function BuildShortCut(AChar: Char): Word;
procedure ReadShortcutsFromStorage;

function ResolveFileFamilies(var CurrentFile: string): Boolean;
function GetAdditionalFilesFromFileFamily(CurrentFile: string; S: TStrings): Boolean;

type
  TGUIClientProjectState = record
    ProjectID: Integer;
    ProjectName: string;
    ProjectOpen: Boolean;
  end;

function SaveProjectState: TGUIClientProjectState;
function OpenProjectByName(AProjectName: string): Integer;
procedure RestoreProjectState(AProjectState: TGUIClientProjectState);
function OpenFirstModuleProject(AModuleID: Integer; AMinimumAccessLevel: Integer = 1): Boolean;
procedure ShellOpenParentFolder(const AFileName: string);

implementation

uses
  HtmlHlp,
  {$IFDEF LANGUAGE}
  JvGnugettext, JVCSLanguage,
  {$ENDIF LANGUAGE}
  SysUtils, ShellAPI, Dialogs, Printers, FileCtrl, JVCSDialogs, ConfigStorage,
  JVCSMruList, Math, JclStrings, JclFileUtils, JclSysInfo, JVCSClientFunctions,
  JVCSGUIClientResources, Registry, Menus, DBModule, JVCSClientObj;

//------------------------------------------------------------------------------

function IsIDEProject(FileName, CurrentProjectName: string): Boolean;
var
  Ext: string;
begin
  Ext := AnsiLowerCase(ExtractFileExt(FileName));
  if bIsCppBuilder then
    Result := (Ext = '.bpr') or (Ext = '.bpg') or
      (LowerCase(ExtractFileName(FileName)) =
      LowerCase(ExtractFileName(CurrentProjectName)))
  else
    Result := (Ext = '.dpr') or (Ext = '.bpg') or (Ext = '.bdsproj') or (Ext = '.cbproj') or (Ext = '.dproj');
end;

//------------------------------------------------------------------------------

function IsIDEPackage(FileName: string): Boolean;
var
  Ext: string;
begin
  Ext := AnsiLowerCase(ExtractFileExt(FileName));
  if bIsCppBuilder then
    Result := (Ext = '.bpk')
  else
    Result := (Ext = '.dpk');
end;

//------------------------------------------------------------------------------

function IsIDEUnit(FileName: string): Boolean;
var
  Ext: string;
begin
  Ext := AnsiLowerCase(ExtractFileExt(FileName));
  if bIsCppBuilder then
    Result := (Ext = '.cpp')
  else
    Result := (Ext = '.pas');
end;

//------------------------------------------------------------------------------

function SettingIsGlobal(Nr: Integer): Boolean;
var 
  OptionValue: string;
begin
  if not bGlobalSettings then
  begin
    Result := False;
    Exit;
  end;
  OptionValue :=
    jvcsReadString(sBaseRegistryKey + crbOptions + '\CCS',
    'Option' + IntToStr(Nr), '0');
  Result := (OptionValue = '1') or (OptionValue = '2');
end;

//------------------------------------------------------------------------------

function GlobalSettingValue(Nr: Integer): Boolean;
begin
  Result :=
    (jvcsReadString(sBaseRegistryKey + crbOptions + '\CCS',
    'Option' + IntToStr(Nr), '1') = '2');
end;

//------------------------------------------------------------------------------

procedure ShowGlobalSettingsWarning(const Hnd: HWND; ForcedState: Boolean);
var
  State: string;
begin
  BeepIfSet;
  if ForcedState then
    State := JVCSRES_60On62
  else
    State := JVCSRES_60Off62;
  MessageBox(Hnd, PChar(Format(JVCSRES_This_option_is_forced_to_be_37s_on_the_current_application_server46 + #13#10 +
    JVCSRES_Your_changes_will_not_take_effect_as_long_as_you_are_connected_to_this_server46 + #13#10 +
    JVCSRES_Contact_your_archive_administrator_for_details46, [State])), cMsgBoxCaption,
    MB_OK or MB_ICONWARNING);
end;

//------------------------------------------------------------------------------

{$IFDEF CUSTOMDRIVE}
function ChangeDriveName(const Path, NewDrive: string): string;
begin
  Result := Path;
  if (NewDrive = '') or (Result = '') or
    (ExtractFileDrive(Result) = '') then
    Exit;
  Delete(Result, 1, Length(ExtractFileDrive(Result)));
  Result := NewDrive + Result;
end;
{$ENDIF CUSTOMDRIVE}

//------------------------------------------------------------------------------

function FastLowerCase(const S: string): string;
var
  I, J: Integer;
begin
  FastLowerCase := S;
  J := Length(S);
  for I := 1 to J do
    if (S[I] >= #65) and (S[I] <= #90) then
      FastLowerCase[I] := Char(Byte(S[I]) + 32);
end;

//------------------------------------------------------------------------------

function RemoveCRLF(const InString: string): string;
var 
  I: Integer;
begin
  Result := InString;
  I := Length(Result);
  while I > 0 do
  begin
    case Result[I] of
      #10, #13 :
        begin
          Delete(Result, I, 1);
          Insert(' ', Result, I)
        end;
      else
        Dec(I);
    end;
  end;
end;

//------------------------------------------------------------------------------

function TrimRight(const InString: string): string;
begin
  if InString = '' then
  begin
    Result := '';
    Exit;
  end;
  Result := InString;
  while (Result <> '') and (Result[Length(Result)] = ' ') do
    System.Delete(Result, Length(Result), 1);
end;

//------------------------------------------------------------------------------

function GetUpTimeStr: string;
var
  LoginTime: Double;
  LDays, LHours, LMinutes: Integer;
begin
  LoginTime := Now - dServerLogin;
  LDays := Trunc(LoginTime);
  LoginTime := LoginTime - LDays;
  LoginTime := LoginTime * 24;
  LHours := Trunc(LoginTime);
  LoginTime := LoginTime - LHours;
  LoginTime := LoginTime * 60;
  LMinutes := Trunc(LoginTime);
  Result := Format(JVCSRES_37d_d44_37d_h44_37d_m46, [LDays, LHours, LMinutes]);
end;

//------------------------------------------------------------------------------

procedure PerformHelpCommand(App: TApplication; Ctx: Integer);
begin
  App.HelpFile := sDLLDirectory + cJVCSHelpFile;
  HtmlHelp(0, PChar(App.HelpFile), HH_HELP_CONTEXT, Ctx);
end;

//------------------------------------------------------------------------------

function GetDllLocation(const DLLModule: HINST): string;
var
  DLLPath: array [0..MAX_PATH] of Char;
begin
  FillChar(DLLPath, SizeOf(DLLPath), #0);
  GetModuleFileName(DLLModule, DLLPath, SizeOf(DLLPath));
  Result := ExtractFilePath(DLLPath);
end;

//------------------------------------------------------------------------------

procedure BeepIfSet;
begin
  if (sBaseRegistryKey = '') or
    (jvcsReadBool(sBaseRegistryKey + crbOptions, 'DoBeep', True)) then
    Windows.Beep(cBeepFreq, cBeepDur);
end;

//------------------------------------------------------------------------------

function GetFileType(FileName: string): string;
var
  FileExtension: string;
  sfi: TSHFileInfo;
begin
  Result := '';
  if ExtractFileExt(FileName) = '' then
  begin
    Result := '?';
    Exit;
  end;
  FillChar(sfi, SizeOf(sfi), 0);
  SHGetFileInfo(PChar(FileName), 0, sfi, SizeOf(sfi),
    SHGFI_SYSICONINDEX or SHGFI_TYPENAME or
    SHGFI_LARGEICON or SHGFI_DISPLAYNAME);
  if sfi.szTypeName <> '' then
    Result := sfi.szTypeName
  else
  begin
    FileExtension := AnsiUpperCase(ExtractFileExt(FileName));
    if FileExtension[1] = '.' then
      Delete(FileExtension, 1, 1);
    if FileExtension = 'DOF' then
      Result := Format(JVCSRES_37s_compiler_options, [sIDEName]);
    if FileExtension = 'DSK' then
      Result := Format(JVCSRES_37s_desktop_file, [sIDEName]);
    if FileExtension = 'RES' then
      Result := JVCSRES_Resource_file;
    if FileExtension = 'RC' then
      Result := JVCSRES_Resource_script;
    if FileExtension = 'INC' then
      Result := JVCSRES_Include_file;
    if FileExtension = 'FVC' then
      Result := JVCSRES_FVCS_data_file;
    if FileExtension = 'JVCS' then
      Result := JVCSRES_JVCS_data_file;
    if FileExtension = 'BKP' then
      Result := JVCSRES_JVCS_backup_file;
    if Result = '' then
      Result := Format(JVCSRES_37s45File, [FileExtension]);
  end;
end;

//------------------------------------------------------------------------------

procedure ShowServerTimeOut(const Hnd: HWND);
var
  Msg: string;
begin
  BeepIfSet;
  Msg := JVCSRES_Request_timed_out46 + #10#13 +
    Format(JVCSRES_The_server_didn39t_answer_within_the_timeout_delay_4037d_sec4146,
      [SrvTimeOutVal div 1000]) + #10#13 +
    JVCSRES_Probably_the_server_connection_is_broken_or_too_slow + #10#13 +
    JVCSRES_or_you_need_to_increase_the_timeout_value46_40Properties_dialog41;
  MessageBox(Hnd, PChar(Msg), cMsgBoxCaption, MB_OK or MB_ICONWARNING);
end;

//------------------------------------------------------------------------------

procedure ShowServerError(const Hnd: HWND; Msg: string; const State: string);
var
  mbIcon: Integer;
  Mess: string;
begin
  BeepIfSet;
  if State = '403' then
  begin
    mbIcon := MB_ICONWARNING;
    Msg := Format(JVCSRES_Access_denied46_4037s41, [State]) + #10#13 + Msg;
    Mess := LowerCase(Msg);
    if Pos(JVCSRES_unknown_or_expired_user_account, Mess) > 0 then
    begin
      {$IFDEF IDEDLL}
      Msg := Msg + #10#13 +
        JVCSRES_Probably_the_server_has_you_logged_out_due_to_an_idle_timer_overflow46 +
        #10#13 + JVCSRES_Select_34JEDI_VCS124Connect_Server34_and_try_to_re45connect46;
      {$ELSE}
      Msg := Msg + #10#13 +
        JVCSRES_Probably_the_server_has_you_logged_out_due_to_an_idle_timer_overflow46 +
        #10#13 + JVCSRES_Select_34Server124Disconnect_Server34_and_try_to_re45connect46;
      {$ENDIF IDEDLL}
      TransactionNr := -1;
      ServerUserID := -1;
    end; // if Pos('granted level: none', Mess) > 0 then begin
  end
  else
  begin
    mbIcon := MB_ICONSTOP;
    Msg := Format(JVCSRES_Server_exception_4037s41_in_object_37s, [State, Msg]);
    if State = '401' then
      Msg := Msg + #10#13 + JVCSRES_No_such_object_available46;
  end;
  MessageBox(Hnd, PChar(Msg), PChar(JVCSRES_JEDI_VCS_Application_Server), MB_OK or mbIcon);
end;

//------------------------------------------------------------------------------

function CtrlSCDisabled(const Hnd: HWND): Boolean;
begin
  Result := jvcsReadBool(sBaseRegistryKey + crbOptions, 'DisableCtrl', False);
  if Result then
  begin
    UseRegistry := True;
    DontShowMsgText := JVCSRES_38Don39t_show_this_message_again;

    DSAIdentsMessageDlg(JVCSRES_Ctrl43_shortcuts_for_graphic_buttons_are_disabled46 + #10#13 +
      JVCSRES_You_may_re45enable_them_by_Options124Properties124Shortcut_Keys46
      , mtInformation
      , [mbOK]
      , 0
      , sBaseRegistryKey + crbMRU + 'Dlgs'
      , 'CtrlSC'
      , idOk
      );
  end;
end;

//------------------------------------------------------------------------------

procedure SetUpUserInfo;
var
  NetInfo, Dummy: string;
  NILenght: Cardinal;
begin
  NILenght := 254;
  SetLength(NetInfo, NILenght);
  // User
  if WNetGetUser(PChar(Dummy), PChar(NetInfo), NILenght) = NO_ERROR then
  begin
    SetLength(NetInfo, StrLen(PChar(NetInfo)));
    if Length(NetInfo) > 0 then
      sCurrentUser := NetInfo
    else
      sCurrentUser := JVCSRES_Default_User;
    // Computer
    SetLength(NetInfo, NILenght);
    GetComputerName(PChar(NetInfo), NILenght);
    SetLength(NetInfo, StrLen(PChar(NetInfo)));
    if Length(NetInfo) > 0 then
      sCurrentMachine := NetInfo
    else 
      sCurrentMachine := '';
  end // if WNetGetUser...
  else
  begin
    sCurrentUser := JVCSRES_Default_User;
    sCurrentMachine := '';
  end;
end;

//------------------------------------------------------------------------------

function IsValidProjectName(const Project: string; var ErrMsg: string): Boolean;
var
  FileName: string;
  I: Integer;
begin
  Result := False;
  ErrMsg := '';
  if Project = '' then
  begin
    ErrMsg := JVCSRES_Project_names_cannot_be_blank46;
    Exit;
  end;
  FileName := AnsiLowerCase(ExtractFileName(Project));
  Result := (FileName <> ('project1.' + sIDEProject)) and
    (FileName <> ('project1.bdsproj')) and
    (FileName <> ('project1.cbproj')) and
    (FileName <> ('project1.dproj')) and
    (FileName <> ('package1.' + sIDEPackage)) and
    (FileName <> 'projectgroup1.bpg') and
    (FileName <> ('unit1.' + sIDEUnit)) and
    (FileName <> 'unit1.dfm');
  if (not Result) then
    ErrMsg := JVCSRES_Project_names_cannot_be_one_of_the_following58 + #10#13 +
      'project1.' + sIDEProject + ', project1.bdsproj, project1.cbproj, project1.dproj, package1.' + sIDEPackage +
      ', projectgroup1.bpg, unit1.' + sIDEUnit + ', unit1.dfm.'
  else   // if (not Result) then begin
  begin
    for I := 1 to Length(FileName) do
      if FileName[I] in InvalidPMChars then
        Result := False;
    if not Result then
      ErrMsg := JVCSRES_Project_names_cannot_contain_any_of_the_following_characters58 + 
        #10#13 + Format(JVCSRES_37s44_or_the_tab_character46, [IPMCharsMsg]);
  end; // else if (not Result) then begin
end;

//------------------------------------------------------------------------------

function IsValidModuleName(const Module: string; var ErrMsg: string): Boolean;
var
  FileName: string;
  I: Integer;
begin
  Result := False;
  ErrMsg := '';
  if Module = '' then
  begin
    ErrMsg := JVCSRES_Module_names_cannot_be_blank46;
    Exit;
  end;
  {if ExtractFileExt(Module) = '' then begin
    ErrMsg := 'Module names without file extension are not allowed.';
    Exit;
  end;}
  if Length(ExtractFileExt(Module)) > 20 then
  begin
    ErrMsg := JVCSRES_File_extensions_can_be_up_to_20_characters_max46;
    Exit;
  end;

  FileName := AnsiLowerCase(ExtractFileName(Module));
  Result := (FileName <> ('project1.' + sIDEProject)) and
    (FileName <> ('project1.bdsproj')) and
    (FileName <> ('project1.cbproj')) and
    (FileName <> ('project1.dproj')) and
    (FileName <> ('package1.' + sIDEPackage)) and
    (FileName <> 'projectgroup1.bpg') and
    (FileName <> ('unit1.' + sIDEUnit)) and
    (FileName <> 'unit1.dfm');
  if (not Result) then
    ErrMsg := JVCSRES_Module_names_cannot_be_one_of_the_following58 + #10#13 +
      'project1.' + sIDEProject + ', project1.bdsproj, project1.cbproj, project1.dproj, package1.' + sIDEPackage +
      ', projectgroup1.bpg, unit1.' + sIDEUnit + ', unit1.dfm.'
  else   // if (not Result) then begin
  begin
    for I := 1 to Length(FileName) do
      if FileName[I] in InvalidPMChars then
        Result := False;
    if not Result then
      ErrMsg := JVCSRES_Module_names_cannot_contain_any_of_the_following_characters58 +
        #10#13 + Format(JVCSRES_37s44_or_the_tab_character46, [IPMCharsMsg]);
  end; // else if (not Result) then begin
end;

//------------------------------------------------------------------------------

function _GetFileSize(const Path: string): Longint;
var 
  SearchRec: TSearchRec;
begin
  if (FindFirst(Path, faAnyFile, SearchRec) = 0) then
    Result := SearchRec.Size
  else
    Result := 0;
  FindClose(SearchRec);
end;

//------------------------------------------------------------------------------

function _GetFileSizeEx(const Path: string; var OriginalName: string): Longint;
var
  SearchRec: TSearchRec;
begin
  if (FindFirst(Path, faAnyFile, SearchRec) = 0) then
  begin
    Result := SearchRec.Size;
    OriginalName := SearchRec.Name;
  end
  else 
  begin
    Result := 0;
    OriginalName := ExtractFileName(Path);
  end;
  FindClose(SearchRec);
end;

//------------------------------------------------------------------------------

function _StrToInt(Value: string): Integer;
var
  IntValue, Err: Integer;
begin
  Val(Value, IntValue, Err);
  if Err = 0 then
    Result := IntValue
  else
    Result := 0;
end;

//------------------------------------------------------------------------------

function _StrToFloat(Value: string): Double;
var
  I: Integer;
begin
  Result := 0;
  if Value = '' then
    Exit;
  for I := 1 to Length(Value) do
    if not (Value[I] in ['0'..'9', '+', '-']) then 
    begin
      Delete(Value, I, 1);
      Insert(DecimalSeparator, Value, I);
      Break;
    end;
  try
    Result := StrToFloat(Value);
  except
    Result := 0;
  end;
end;

//------------------------------------------------------------------------------

// Result: 0 = OK, 1 = Drive Error, 2 = Directory Error, 3 = Path Error
function CreateTargetDir(const Target: string): Integer;
var
  sNewPathBuff, sActDir, sTmpDir: string;
begin
  Result := 0;
  if DirectoryExists(Target) then 
    Exit;
  if Target = '' then
  begin
    Result := 3;
    Exit;
  end;
  // Verzeichnisstruktur erstellen
  GetDir(0, sActDir);
  sNewPathBuff := Target;
  try
    ChDir(ExtractFileDrive(sNewPathBuff) + '\');
  except
    Result := 1;
    Exit;
  end;
  Delete(sNewPathBuff, 1, Length(ExtractFileDrive(sNewPathBuff)));
  try
    repeat
      Delete(sNewPathBuff, 1, 1);
      sTmpDir := Copy(sNewPathBuff, 1, Pos('\', sNewPathBuff) - 1);
      Delete(sNewPathBuff, 1, Pos('\', sNewPathBuff) - 1);
      if not DirectoryExists(sTmpDir) then
      begin
        MkDir(sTmpDir);
        ChDir(sTmpDir);
      end
      else 
        ChDir(sTmpDir);
    until Length(sNewPathBuff) < 2;
  except
    Result := 2;
  end;
  ChDir(sActDir);
end;

//------------------------------------------------------------------------------

function HasAssociateFile(const FileName: string; var AssociateName: string): Boolean;
var
  Ext, BaseFile: string;
  HasAssociate: Boolean;
begin
  Ext := AnsiLowerCase(ExtractFileExt(FileName));
  if (Ext <> '.dfm') and (Ext <> ('.' + sIDEUnit)) then
  begin
    AssociateName := '';
    Result := False;
    Exit;
  end;
  HasAssociate := False;
  BaseFile := ChangeFileExt(FileName, '');
  if Ext = '.dfm' then
  begin
    HasAssociate := FileExists(BaseFile + '.' + sIDEUnit);
    if HasAssociate then
      AssociateName := BaseFile + '.' + sIDEUnit;
  end;
  if Ext = ('.' + sIDEUnit) then 
  begin
    HasAssociate := FileExists(BaseFile + '.dfm');
    if HasAssociate then 
      AssociateName := BaseFile + '.dfm';
  end;
  Result := HasAssociate;
end;

//------------------------------------------------------------------------------

function CutPathStr(const S: string; const Len: Integer): string;
var 
  FN, LW: string;
begin
  if Len < 3 then
  begin
    Result := S;
    Exit;
  end;
  if Length(S) <= Len then
  begin
    Result := S;
    Exit;
  end;
  FN := S;
  Delete(FN, 1, Length(ExtractFileDrive(FN)));
  if (Pos('\', FN) = 0) then 
  begin
    Result := ExtractFileDrive(S) + FN;
    Exit;
  end;
  while (Pos('\', FN) <> 0) and ((Length(FN) + Length(ExtractFileDrive(S))) > Len) do
    Delete(FN, 1, 1);
  while (Pos('\', FN) <> 0) and (FN[1] <> '\') do
    Delete(FN, 1, 1);
  LW := ExtractFileDrive(S);
  Result := LW + '\...' + FN;
end;

//------------------------------------------------------------------------------

function MkDirEx(Bez: string): Boolean;
var 
  Verz: string;
begin
  if Copy(Bez, Length(Bez), 1) <> '\' then
    Bez := Bez + '\';
  Result := False;
  Verz := Copy(Bez, 1, 2);
  Delete(Bez, 1, 3);
  while Length(Bez) > 0 do
  begin
    Verz := Verz + '\' + Copy(Bez, 1, Pos('\', Bez) - 1);
    Delete(Bez, 1, Pos('\', Bez));
    {$I-}
    MkDir(Verz);
    {$I+}
    case IOResult of
      0,
      183:
        begin
        end;
      else
        Exit;
    end;
  end; // while Length(Bez) > 0 do begin
  Result := True;
end;

//------------------------------------------------------------------------------

function GetFreeTempName: string;
var 
  I, Counter: Integer;
  TMPDirectory, TempFN: string;
begin
  Result := '';
  // TMP - Verzeichnis ?
  I := 255; //  // size, in characters, of the buffer
  SetLength(TMPDirectory, I);
  I := GetTempPath(I, PChar(TMPDirectory));
  if I = 0 then
    Exit; // Error
  SetLength(TMPDirectory, StrLen(PChar(TMPDirectory)));
  TMPDirectory := SetBackSlash(TMPDirectory);
  Counter := 0;
  repeat // until (not FileExists(TFN)) or Counter > 100;
    Inc(Counter);
    TempFN := '_FVCS' + IntToStr(Counter) + '.tmp';
  until (not FileExists(TMPDirectory + TempFN)) or (Counter >= 999);
  if Counter < 999 then 
    Result := TMPDirectory + TempFN
  else
    Result := '';
end;

//------------------------------------------------------------------------------

function GetUniqueFileName: string;
begin
  Result := Format('%8x', [DateTimeToFileDate(Now())]);
end;

//------------------------------------------------------------------------------

function _CopyFile(const Source, Dest: string): Boolean;
var
  f1, f2: file;
  Buffer: Pointer;
  Buffersize, CopyRead, CopyWrite: Integer;
  CFError: Word;
begin
  Buffersize := 4096;
  if (FileExists(Dest)) then 
  begin
    FileSetAttr(Dest, FileGetAttr(Dest) and not $00000001);
    SysUtils.DeleteFile(Dest);
  end;

  AssignFile(f1, Source);
  AssignFile(f2, Dest);
  {$I-}
  Reset(f1, 1);
  Rewrite(f2, 1);
  {$I+}
  CFError := IOResult;
  if CFError <> 0 then 
  begin
    ShowMessage(Format(JVCSRES_Error_37d_in_95CopyFile4041, [CFError]));
    Result := False;
    Exit;
  end;
  CopyRead := 0;
  CopyWrite := 0;
  GetMem(Buffer, Buffersize);
  try
    repeat;
      {$I-}
      BlockRead(f1, Buffer^, Buffersize, CopyRead);
      BlockWrite(f2, Buffer^, CopyRead, CopyWrite);
      {$I+}
      CFError := IOResult;
    until (CopyRead = 0) or (CopyWrite <> CopyRead) or (CFError <> 0);
    if CFError <> 0 then
    begin
      ShowMessage(Format(JVCSRES_Error_37d_in_95CopyFile4041, [CFError]));
      FreeMem(Buffer, Buffersize);
      Result := False;
      Exit;
    end;
    Result := True;
  finally
    CloseFile(f1);
    CloseFile(f2);
    FreeMem(Buffer, Buffersize);
  end;
end;

//------------------------------------------------------------------------------

function CheckDefaultPrinter: Boolean;
var
  FDevice, FDriver, FPort: PChar;
  FHandle: THandle;
  CurrentPrinterName: string;
begin
  Result := False;
  GetMem(FDevice, 255);
  GetMem(FDriver, 255);
  GetMem(FPort, 255);
  Printer.GetPrinter(FDevice, FDriver, FPort, FHandle);
  CurrentPrinterName := FDevice;
  if FDevice <> nil then
    FreeMem(FDevice, 255);
  if FDriver <> nil then 
    FreeMem(FDriver, 255);
  if FPort <> nil then
    FreeMem(FPort, 255);
  if CurrentPrinterName <> '' then
    Result := True;
end;

//------------------------------------------------------------------------------

function SetBackSlash(const Value: string): string;
begin
  {$IFDEF DELPHI6_UP}
  Result := IncludeTrailingPathDelimiter(Value);
  {$ELSE}
  Result := IncludeTrailingBackslash(Value);
  {$ENDIF DELPHI6_UP}
end;

//------------------------------------------------------------------------------

function ClearBackSlash(const Value: string): string;
begin
  {$IFDEF DELPHI6_UP}
  Result := ExcludeTrailingPathDelimiter(Value);
  {$ELSE}
  Result := ExcludeTrailingBackslash(Value);
  {$ENDIF DELPHI6_UP}
end;

//------------------------------------------------------------------------------

function GetOriginalFileName(const FileName: string): string;
var 
  SearchRec: TSearchRec;
begin
  Result := FileName;
  if FindFirst(FileName, faAnyFile, SearchRec) = 0 then
    Result := ExtractFilePath(FileName) + SearchRec.Name
  else
    Result := FileName;
  FindClose(SearchRec);
  {$IFDEF DEBUG}
  JclDebug.TraceMsg('GetOriginalFileName: ' + Result);
  {$ENDIF DEBUG}
end;

//------------------------------------------------------------------------------

function DeleteToRecycleBin(WindowHandle: HWND; const FileName: string): Boolean;
var 
  ShStruct: TSHFileOpStruct;
  P1: array [Byte] of Char;
begin
  Result := False;
  if FileExists(FileName) = False then
    Exit;
  FillChar(P1, SizeOf(P1), 0);
  StrPcopy(P1, ExpandFileName(FileName) + #0#0);
  ShStruct.wnd := 0;
  ShStruct.wFunc := FO_DELETE;
  ShStruct.pFrom := P1;
  ShStruct.pTo := nil;
  ShStruct.fFlags := FOF_ALLOWUNDO or FOF_NOCONFIRMATION;
  ShStruct.fAnyOperationsAborted := False;
  ShStruct.hNameMappings := nil;
  Result := (ShFileOperation(ShStruct) = 0);
  if not Result then
    Result := FileExists(FileName);
end;

//------------------------------------------------------------------------------

function GetAttrStrEx(const FName: string): string;
var
  FAttr: DWord;
begin
  Result := '';
  FAttr := GetFileAttributes(PChar(FName));
  if FAttr <> $FFFFFFFF then
  begin
    if (FAttr and FILE_ATTRIBUTE_ARCHIVE) = FILE_ATTRIBUTE_ARCHIVE then
      Result := Result + 'A';
    if (FAttr and FILE_ATTRIBUTE_COMPRESSED) = FILE_ATTRIBUTE_COMPRESSED then
      Result := Result + 'C';
    if (FAttr and FILE_ATTRIBUTE_DIRECTORY) = FILE_ATTRIBUTE_DIRECTORY then
      Result := Result + 'D';
    if (FAttr and FILE_ATTRIBUTE_HIDDEN) = FILE_ATTRIBUTE_HIDDEN then
      Result := Result + 'H';
    if (FAttr and FILE_ATTRIBUTE_NORMAL) = FILE_ATTRIBUTE_NORMAL then
      Result := Result + 'N';
    if (FAttr and FILE_ATTRIBUTE_OFFLINE) = FILE_ATTRIBUTE_OFFLINE then
      Result := Result + 'O';
    if (FAttr and FILE_ATTRIBUTE_READONLY) = FILE_ATTRIBUTE_READONLY then
      Result := Result + 'R';
    if (FAttr and FILE_ATTRIBUTE_SYSTEM) = FILE_ATTRIBUTE_SYSTEM then
      Result := Result + 'S';
    if (FAttr and FILE_ATTRIBUTE_TEMPORARY) = FILE_ATTRIBUTE_TEMPORARY then
      Result := Result + 'T';
  end // if FAttr <>  $FFFFFFFF then begin
  else
    Result := JVCSRES_Error;
end;

//------------------------------------------------------------------------------

function DecodeShellErr(const Index: Integer): string;
begin
  case Index of
    0:
      Result := 'The system is out of memory or resources.';
    ERROR_BAD_FORMAT:
      Result := 'The .EXE file is invalid (non-Win32 .EXE or error in .EXE image).';
    ERROR_FILE_NOT_FOUND:
      Result := 'The specified file was not found.';
    ERROR_PATH_NOT_FOUND:
      Result := 'The specified path was not found.';
    SE_ERR_ACCESSDENIED:
      Result := 'The operating system denied access to the specified file.';
    SE_ERR_ASSOCINCOMPLETE:
      Result := 'The filename association is incomplete or invalid.';
    SE_ERR_DDEBUSY:
      Result :=
        'The DDE transaction could not be completed because other DDE transactions were being processed.';
    SE_ERR_DDEFAIL:
      Result := 'The DDE transaction failed.';
    SE_ERR_DDETIMEOUT:
      Result := 'The DDE transaction could not be completed because the request timed out.';
    SE_ERR_DLLNOTFOUND:
      Result := 'The specified dynamic-link library was not found.';
    SE_ERR_NOASSOC:
      Result := 'There is no application associated with the given filename extension.';
    SE_ERR_OOM:
      Result := 'There was not enough memory to complete the operation.';
    SE_ERR_SHARE:
      Result := 'A sharing violation occurred.';
    else
      Result := 'Unknown Error occured';
  end;
end;

//------------------------------------------------------------------------------

function WriteTimeLog(const FileName, Value: string): Boolean;
var
  TLFile: TextFile;
begin
  {$IFDEF DEBUG}
  JclDebug.TraceMsg('WriteTimeLog: ' + FileName + ' - ' + Value);
  {$ENDIF DEBUG}
  Result := False;
  AssignFile(TLFile, FileName);
  try
    try
      if FileExists(FileName) then
        Append(TLFile) 
      else 
        Rewrite(TLFile);
      WriteLn(TLFile, Value);
    finally
      CloseFile(TLFile);
    end;
  except
    Exit;
  end;
  Result := True;
end;

//------------------------------------------------------------------------------

function SearchAndChange(const TextString, SearchString, ChangeString: string): string;
var
  Q: Integer;
  D: string;
begin
  D := '';
  Q := 0;
  repeat
    Inc(Q);
    if UpperCase(Copy(TextString, Q, Length(SearchString))) = UpperCase(SearchString) then
    begin
      D := D + ChangeString;
      Q := Q + Length(SearchString) - 1;
    end
    else
      D := D + Copy(TextString, Q, 1);
  until Q >= Length(TextString);
  Result := D;
end;

//------------------------------------------------------------------------------

{$IFDEF DBGFILE}
procedure DebugFile(Value: string);
var
  FileName: string;
  FileCont: TStringList;
begin
  FileName := sDLLDirectory + 'DebugInfo.txt';
  FileCont := TStringList.Create;
  try
    if FileExists(FileName) then
      FileCont.LoadFromFile(FileName);
    FileCont.Add(DateTimeToStr(Now) + ' - ' + Value);
    FileCont.SaveToFile(FileName);
  finally
    FileCont.Free;
  end;
end;
{$ENDIF DBGFILE}

//------------------------------------------------------------------------------

function ExecuteFavOpenDialogWithMru(AFavOpenDialog: TFavOpenDialog; AKey: string): Boolean;
var
  FAVDirectories: TJVCSMruList;
begin
  {$IFDEF DEBUG}
  Assert(AFavOpenDialog <> nil, 'AFavOpenDialog is nil');
  {$ENDIF DEBUG}
  with AFavOpenDialog do
  begin
    MaxCount := jvcsReadInteger(sBaseRegistryKey + crbMRU, 'FileDlgMRU', 10);

    FAVDirectories := TJVCSMruList.CreateEx(AKey, MaxCount);
    try
    { //done in CreateEx of TJVCSMruList
      FAVDirectories.MaxLen := AMaxSize;
      FAVDirectories.LoadFromReg(AKey);
    }
      Favorites.Assign(FAVDirectories);
      Result := Execute;
      FAVDirectories.Clear;
      FAVDirectories.Assign(Favorites);
    { //will be done in TJVCSMruList.Free, because CreateEx enabled AutoSave
      //on destroy
      // store recent list
      FAVDirectories.SaveToReg(AKey);
    }
    finally
      FAVDirectories.Free;
    end;
  end;
end;

//------------------------------------------------------------------------------

function ExtractFileExtWithoutDot(AFileName: string): string;
begin
  Result := ExtractFileExt(AFileName);
  if (Length(Result) > 0) and (Result[1] = '.') then
    Delete(Result, 1, 1);
end;

//------------------------------------------------------------------------------

procedure BroadcastMessage(Msg: Cardinal; wParam, lParam: Integer);
var
  I: Integer;
begin
  for I := 0 to Screen.CustomFormCount -1 do
    if Screen.CustomForms[I].Visible then
      SendMessage(Screen.CustomForms[I].Handle, Msg, wParam, lParam);
end;

//------------------------------------------------------------------------------

type
  TPageControlCracker = class(TPageControl);

procedure SetDockClientToActivePage(APageControl: TPageControl; AClient: TControl);
var
  LTabSheet: TTabSheet;
begin
  if Assigned(APageControl) and Assigned(AClient) then
  begin
    LTabSheet := TPageControlCracker(APageControl).GetPageFromDockClient(AClient);
    if Assigned(LTabSheet) then
      APageControl.ActivePage := LTabSheet;
  end;
end;

//------------------------------------------------------------------------------

function IsDockClientActivePage(APageControl: TPageControl; AClient: TControl): Boolean;
begin
  Result := Assigned(AClient) and AClient.Visible and Assigned(APageControl) and
    Assigned(APageControl.ActivePage) and
    (APageControl.ActivePage = TPageControlCracker(APageControl).GetPageFromDockClient(AClient));
end;

//------------------------------------------------------------------------------

function GetAcceleratedMenuName(AAcceleratorIndex: Integer;
  AConfig: Boolean = False): string;
begin
  // "_" is a placeholder for the spaces when GetAcceleratedMenuName is
  // used in Options.pas
  case AAcceleratorIndex of
    1 :
      Result := '&J_E_D_I_ _V_C_S ';
    2 :
      Result := 'J_&E_D_I_ _V_C_S ';
    3 :
      Result := 'J_E_&D_I_ _V_C_S ';
    4 :
      Result := 'J_E_D_&I_ _V_C_S ';
    5, 6 :
      Result := 'J_E_D_I_ _&V_C_S ';
    7 :
      Result := 'J_E_D_I_ _V_&C_S ';
    8, 9 :
      Result := 'J_E_D_I_ _V_C_&S ';
    else
      Result := 'J_E_D_I_ _&V_C_S ';
  end; // case AAcceleratorIndex of
  if AConfig then
    Result := StringReplace(Result, '_', ' ', [rfReplaceAll])
  else
    Result := StringReplace(Result, '_', '', [rfReplaceAll]);
end;

//------------------------------------------------------------------------------

function GetProductAndOSVersionString: string;
{$IFDEF IDEDLL}
var
  Mess, ProductTitle: string;
  JclFileVersionInfoIDE: TJclFileVersionInfo;
{$ENDIF IDEDLL}
begin
  {$IFDEF IDEDLL}
  // Don't change, this is for Delphi/C++...
  if FileExists(Application.ExeName) then
  begin
    JclFileVersionInfoIDE := TJclFileVersionInfo.Create(Application.ExeName);
    try
      Mess := sIDEName + ' ';
      Mess := Mess + JclFileVersionInfoIDE.ProductVersion + ' ';
      Mess := Mess + JclFileVersionInfoIDE.ProductName + ' ';

      ProductTitle := JclFileVersionInfoIDE.Items.Values['ProductTitle']; //do not localize
      if ProductTitle <> '' then
        Mess := Mess + '/ ' + ProductTitle;
    finally
      JclFileVersionInfoIDE.Free;
    end;
  end
  else
    Mess := JVCSRES_Unable_to_determine_IDE_version;
  Result := Mess + ' [' + GetWindowsVersionString + ']';
  {$ELSE}
  Result := Format(JVCSRES_Standalone_version_9137s93, [GetWindowsVersionString]);
  {$ENDIF IDEDLL}
end;

//------------------------------------------------------------------------------

{$IFDEF IDEDLL}
function GetDelphiVersion: Integer;
var
  JclFileVersionInfoIDE: TJclFileVersionInfo;
begin
  if FileExists(Application.ExeName) then
  begin
    JclFileVersionInfoIDE := TJclFileVersionInfo.Create(Application.ExeName);
    try
      if (JclFileVersionInfoIDE.ProductVersion = '7.0') then
      begin
        Result := 7;
      end
      else
      if (JclFileVersionInfoIDE.ProductVersion = '6.0') then
      begin
        Result := 6;
      end
      else
      if (JclFileVersionInfoIDE.ProductVersion = '5.0') then
      begin
        Result := 5;
      end
      else
      begin
        Result := 4;
      end;
    finally
      JclFileVersionInfoIDE.Free;
    end;
  end
  else
    Result := -1;
end;
{$ENDIF IDEDLL}

//------------------------------------------------------------------------------

procedure CleanCompareDirectories;

  procedure SearchFilesAndAddToList(APath: string; AList: TStrings);
  var
    LocalFileList: TStrings;
    I: Integer;
  begin
    LocalFileList := TStringList.Create;
    try
      APath := SetBackSlash(APath);
      BuildFileList(APath + '*.*', faAnyFile - faDirectory, LocalFileList);
      for I := 0 to Pred(LocalFileList.Count) do
        AList.Add(APath + LocalFileList[I]);
    finally
      LocalFileList.Free;
    end;
  end;

var
  FilesToDelete: TStringList;
  I: Integer;
begin
  FilesToDelete := TStringList.Create;
  try
    SearchFilesAndAddToList(PathAddSeparator(GetAppdataFolder) + 'JEDI\JVCS\COMPARE\1\', FilesToDelete);
    SearchFilesAndAddToList(PathAddSeparator(GetAppdataFolder) + 'JEDI\JVCS\COMPARE\2\', FilesToDelete);
    for I := 0 to Pred(FilesToDelete.Count) do
      DeleteFile(FilesToDelete[I]);
  finally
    FilesToDelete.Free;
  end;
end;

//------------------------------------------------------------------------------

function GetJVCSAppProductVersionInt: Integer;
var
  sVer: string;
  slVersions: TStringList;
begin
  sVer := GetJVCSAppProductVersion;
  slVersions := TStringList.Create;
  try
    StrToStrings(sVer, '.', slVersions);
    Assert(slVersions.Count > 3, JVCSRES_Wrong_product_version_resource_40needs_format_n46n46n9146n9333);
    Result := StrToInt(slVersions[0]) * 100 +
              StrToInt(slVersions[1]) * 10 +
              StrToInt(slVersions[2]);
  finally
    slVersions.Free;
  end;
end;

//------------------------------------------------------------------------------

function GetJVCSAppProductVersion: string;
var
  JclFileVersionInfo: TJclFileVersionInfo;
begin
  Result := '';
  JclFileVersionInfo := TJclFileVersionInfo.Create(GetSelfFileName);
  try
    Result := JclFileVersionInfo.ProductVersion;
  finally
    JclFileVersionInfo.Free;
  end;
end;

//------------------------------------------------------------------------------

var
  LAppFileVersion: string = '';
  LAppFileVersionReaded: Boolean = False;

function GetJVCSAppFileVersion(const sFileName : String) : String;
var
  JclFileVersionInfo: TJclFileVersionInfo;
begin
  JclFileVersionInfo := TJclFileVersionInfo.Create(sFileName);
  try
    result := JclFileVersionInfo.FileVersion;
  finally
    JclFileVersionInfo.Free;
  end;
end;

function GetJVCSAppFileVersion: string;
begin
  if not LAppFileVersionReaded then
  begin
    LAppFileVersion := GetJVCSAppFileVersion(GetSelfFileName);
    LAppFileVersionReaded := True;
  end;
  Result := LAppFileVersion;
end;

//------------------------------------------------------------------------------

function CompareDateTimeStrs(const ADateTimeStr1, ADateTimeStr2: string): Integer;

  {$IFNDEF DELPHI6_UP}
  function StrToDateTimeDef(const AColumnStr: string; const ADefaultValue: TDateTime): TDateTime;
  begin
    if (AColumnStr = '-') or (AColumnStr = '') then
      Result := ADefaultValue
    else
    try
      Result := StrToDateTime(AColumnStr);
    except
      Result := ADefaultValue;
    end;
  end;
  {$ENDIF ~DELPHI6_UP}

var
  DateTime1, DateTime2: TDateTime;
begin
  DateTime1 := StrToDateTimeDef(ADateTimeStr1, 0);
  DateTime2 := StrToDateTimeDef(ADateTimeStr2, 0);
  if DateTime1 < DateTime2 then
    Result := -1
  else
  if DateTime1 > DateTime2 then
    Result := 1
  else
    Result := 0;
end;

//------------------------------------------------------------------------------

function ExistMutex(AMutex: string): Boolean;
var
  MutexHandle: THandle;
begin
  MutexHandle := OpenMutex(MUTEX_ALL_ACCESS, False, PChar(AMutex));
  if MutexHandle <> 0 then
  begin
    CloseHandle(MutexHandle);
    Result := True;
  end
  else
    Result := False;
end;

//------------------------------------------------------------------------------

procedure InitAndOpenConfigStorage;
begin
  // App registry key
  sBaseRegistryKey := cRegSwJVCSBase;

  // Storage: Registry or IniFile?
  // this value is *always* stored in the registry!
  UseRegistryStorage := True;
  with TRegistry.Create do
  begin
    try
      if OpenKeyReadOnly(cRegSwJVCSBase) then
      begin
        if ValueExists('UseRegistry') then
          UseRegistryStorage := ReadBool('UseRegistry')
        else
          UseRegistryStorage := True;
        CloseKey;
      end
      else
        UseRegistryStorage := True;
    finally
      Free;
    end;
  end;
  // initialize
  if not jvcsOpenStorageObject then
  begin // Fatal!
    Windows.Beep(500, 100);
    ErrorMessageBox(JVCSRES_Fatal_Error33_Unable_to_open_the_file_storage_object33 + #10#13 +
      JVCSRES_Will_use_Registry_for_configuration_storage46);
    // error should only occur if file is selected...
    UseRegistryStorage := True;
  end;
  {$IFDEF LANGUAGE}
  TP_GlobalIgnoreClass(TListColumn);
  TextDomain('jedivcs');
  AddDomainForResourceString('jedivcs');
  UseLanguage(jvcsReadString(sBaseRegistryKey + crbOptions, 'Language', DefaultLanguageCode));
  {$ENDIF LANGUAGE}
end;

//------------------------------------------------------------------------------

function BuildShortCut(AChar: Char): Word;
begin
  Result := 0;
  if AChar <> '*' then
    Result := ShortCut(Word(AChar), [ssShift, ssCtrl]);
end;

//------------------------------------------------------------------------------

procedure ReadShortcutsFromStorage;

  function ReadShortCutFromStorage(const AName: string; ADefaultValue: TShortCut): TShortCut;
  var
    S: string;
  begin
    if jvcsValueExists(sBaseRegistryKey + crbOptions, 'SC' + AName) then
    begin
      S := jvcsReadString(sBaseRegistryKey + crbOptions, 'SC' + AName, '');
      if (Length(S) = 1) and (S[1] <> ' ') and (S[1] <> '*') then
        Result := scCtrl + scShift + Ord(S[1])
      else
        Result := ADefaultValue;
      jvcsWriteInteger(sBaseRegistryKey + crbOptions, 'ShortCut' + AName, Result);
      jvcsDeleteValue(sBaseRegistryKey + crbOptions, 'SC' + AName);
    end
    else
      Result := jvcsReadInteger(sBaseRegistryKey + crbOptions, 'ShortCut' + AName, ADefaultValue);
  end;

begin
  // Shortcuts
  cSCProjAdmin := ReadShortCutFromStorage('ProjAdmin', cSCProjAdmin);
  cSCChkIn := ReadShortCutFromStorage('ChkIn', cSCChkIn);
  cSCGet := ReadShortCutFromStorage('Get', cSCGet);
  cSCChkOut := ReadShortCutFromStorage('ChkOut', cSCChkOut);
  cSCSync := ReadShortCutFromStorage('Sync', cSCSync);
  cSCBckUp := ReadShortCutFromStorage('BckUp', cSCBckUp);
end;

//------------------------------------------------------------------------------

var
  LastResolveFileFamiliesInput: string;
  LastResolveFileFamiliesOutput: string;
  LastResolveFileFamiliesResult: Boolean;
  LastResolveFileFamiliesTick: Cardinal;

function ResolveFileFamilies(var CurrentFile: string): Boolean;
var
  CurrentFileExt,FamilyExt: string;
  T: TStringList;
  I: Integer;
begin
  Result := False;
  { USc 2007/07/08 removed the bProjectOpen check because for example in the function
    "Project Tree" bProjectOpen is False when no project is open at this time }
  if {bProjectOpen and }(CurrentFile <> '') and Assigned(DataModule1) and (ServerUserID > 0) then
  begin
    CurrentFileExt := AnsiLowerCase(ExtractFileExt(CurrentFile));
    if (GetTickCount - LastResolveFileFamiliesTick < 5000) and SameText(LastResolveFileFamiliesInput, CurrentFile) then
    begin
      LastResolveFileFamiliesTick := GetTickCount;
      CurrentFile := ChangeFileExt(CurrentFile, LastResolveFileFamiliesOutput);
      Result := LastResolveFileFamiliesResult;
    end
    else
    begin
      Result := False;
      LastResolveFileFamiliesInput := CurrentFile;
      try
        DataModule1.FileFamilyList.Load;
        for I := 0 to Pred(DataModule1.FileFamilyList.Count) do
        begin
          FamilyExt := AnsiLowerCase(DataModule1.FileFamilyList[I].Parent);
          if FamilyExt = CurrentFileExt then
          begin
            Result := True;
            Break;
          end;
          T := TStringList.Create;
          try
            StrTokenToStrings(AnsiLowerCase(DataModule1.FileFamilyList[I].Children), ';', T);
            if (T.IndexOf(CurrentFileExt) >= 0) and FileExists(ChangeFileExt(CurrentFile, FamilyExt)) then
            begin
              CurrentFile := ChangeFileExt(CurrentFile, FamilyExt);
              Result := True;
              Break;
            end;
          finally
            T.Free;
          end;
        end;
      finally
        LastResolveFileFamiliesTick := GetTickCount;
        LastResolveFileFamiliesOutput := ExtractFileExt(CurrentFile);
        LastResolveFileFamiliesResult := Result;
      end;
    end;
  end;
end;

function GetAdditionalFilesFromFileFamily(CurrentFile: string; S: TStrings): Boolean;
var
  CurrentFileExt, AdditionalFile, FamilyExt: string;
  T: TStringList;
  I, J: Integer;
begin
  Result := False;
  { USc 2007/07/08 removed the bProjectOpen check because in the IDE client bProjectOpen
    could be False when GetAdditionalFilesFromFileFamily is called in the backup procedure }
  if {bProjectOpen and }(CurrentFile <> '') then
  begin
    CurrentFileExt := AnsiLowerCase(ExtractFileExt(CurrentFile));
    if Assigned(DataModule1) and (ServerUserID > 0) then
    begin
      DataModule1.FileFamilyList.Load;
      for I := 0 to Pred(DataModule1.FileFamilyList.Count) do
      begin
        FamilyExt := AnsiLowerCase(DataModule1.FileFamilyList[I].Parent);
        if (FamilyExt = CurrentFileExt) then
        begin
          T := TStringList.Create;
          try
            StrTokenToStrings(AnsiLowerCase(DataModule1.FileFamilyList[I].Children), ';', T);
            for J := 0 to Pred(T.Count) do
            begin
              AdditionalFile := ChangeFileExt(CurrentFile, T[J]);
              if FileExists(AdditionalFile) then
              begin
                if S <> nil then
                  S.Add(AdditionalFile);
                Result := True;
              end;
            end;
          finally
            T.Free;
          end;
          Break;
        end;
      end;
    end;
  end;
end;

function SaveProjectState: TGUIClientProjectState;
begin
  Result.ProjectID := ServerProjectID;
  Result.ProjectName := sProjectName;
  Result.ProjectOpen := bProjectOpen;
end;

function OpenProjectByName(AProjectName: string): Integer;
var
  GetProjectId: TJVCSGetProjectId;
begin
  Result := -3;
  if ServerUserID > 0 then
  begin
    GetProjectId := TJVCSGetProjectId.Create(nil);
    try
      GetProjectId.ProjectName := AProjectName;
      DataModule1.ClientObjectSendRequest(GetProjectId);
      TransactionNr := GetProjectId.TransactionID;
      ServerProjectID := GetProjectId.ProjectID;
      if GetProjectId.ProjectDeleted then
        Result := -2
      else
        Result := GetProjectId.AccessLevel;
      if Result > 0 then
      begin
        sProjectName := AProjectName;
        bProjectOpen := True;
      end;
    finally
      GetProjectId.Free;
    end;
  end;
end;

procedure RestoreProjectState(AProjectState: TGUIClientProjectState);
begin
  if ((AProjectState.ProjectID > 0) and (ServerProjectID <> AProjectState.ProjectID)) or
    (AProjectState.ProjectOpen and (bProjectOpen <> AProjectState.ProjectOpen)) then
    OpenProjectByName(AProjectState.ProjectName);
  ServerProjectID := AProjectState.ProjectID;
  sProjectName := AProjectState.ProjectName;
  bProjectOpen := AProjectState.ProjectOpen;
end;

function OpenFirstModuleProject(AModuleID: Integer; AMinimumAccessLevel: Integer = 1): Boolean;
var
  GetSharedBy: TJVCSGetSharedBy;
  I, CurrentAccessLevel: Integer;
begin
  Result := False;
  if ServerUserID > 0 then
  begin
    GetSharedBy := TJVCSGetSharedBy.Create(nil);
    try
      GetSharedBy.ModuleID := AModuleID;
      DataModule1.ClientObjectSendRequest(GetSharedBy);
      for I := 0 to Pred(GetSharedBy.OutputItemCount) do
      begin
        CurrentAccessLevel := OpenProjectByName(GetSharedBy.OutputItems[I].ProjectName);
        if CurrentAccessLevel >= AMinimumAccessLevel then
        begin
          ServerProjectID := GetSharedBy.OutputItems[I].ProjectID;
          sProjectName := GetSharedBy.OutputItems[I].ProjectName;
          bProjectOpen := True;
          Result := True;
          Break;
        end;
      end;
    finally
      GetSharedBy.Free;
    end;
  end;
end;

procedure ShellOpenParentFolder(const AFileName: string);
var
  ParameterStr: string;
begin
  if jvcsReadBool(sBaseRegistryKey + crbOptions, 'ParentAsExplorer', False) then
    ParameterStr := '/e,/select,' + '"' + AFileName + '"'
  else
    ParameterStr := '/select,' + '"' + AFileName + '"';

  ShellExecute(Application.Handle, 'open', 'explorer.exe',
    PChar(ParameterStr), '', sw_ShowNormal);
end;

end.

