(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: LoadModule.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS: Thomas Huber (Thomas_D_Huber@t-online.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FreeVCS code to JEDI VCS
2003/03/05  THensle   - changes for "ConfigStorage" unit
2003/04/08  USchuster - changes for IDEInterface
2003/11/19  USchuster - changed 'FreeVCS' in messageboxes to 'JEDI VCS'
                        with constant cMsgBoxCaption from VCSBase.pas
2004/10/30  USchuster - style cleaning
                      - res strings and displayed strings changed to resourcestrings
2004/11/03  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
2006/12/10  USchuster - added JVCSClientFunctions to uses (as of now it is required for MatchWithFilter)
2009/12/28  THuber    - added JVCSClientConsts to uses (as some consts were moved from VCSBase there)

-----------------------------------------------------------------------------*)

unit LoadModule;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  {$IFDEF DEBUG}
  JclDebug,
  {$ENDIF DEBUG}
  Windows, Messages, SysUtils, Classes, Forms, Dialogs;


function ViewTheModule(const WH: HWND; const CurrentModule: string;
  var Msg: string): Boolean;

implementation

uses
  ShellAPI, JVCSClientConsts, VCSProcBase, VCSBase, ItemProp, Options, ConfigStorage, JVCSGUIClientResources,
  JVCSClientFunctions;

function ViewTheModule(const WH: HWND; const CurrentModule: string;
  var Msg: string): Boolean;
var
  RWSPath, BMPPath, TXTPath, UserEditorPath, ShortModulName: string;
  Loaded: Boolean;
  ExecResult, SMSize: Integer;

  procedure ShowEditorOptions;
  begin
    VCSOptions := TVCSOptions.Create(Application); // unit Options
    try
      VCSOptions.DefaultSheet := cspEditors;
      VCSOptions.ShowModal;
    finally
      VCSOptions.Free;
    end;
    MessageBox(WH, PChar(JVCSRES_Select_the_module_again_and_retry_if_you_have_defined_an_editor_now46),
      cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
  end;
begin
  Loaded := False;
  Result := False;
  if not FileExists(CurrentModule) then
  begin
    MessageBox(WH, PChar(Format(JVCSRES_Module_6037s62_is_not_available_on_the_local_disk46 + #13#10 +
      JVCSRES_You_must_Get_the_module_first_or_select_34View_latest_Archive_Version3446,
      [ExtractFileName(CurrentModule)])), cMsgBoxCaption, MB_OK or MB_ICONWARNING);
    Exit;
  end;
  {$IFDEF IDEDLL}
  if IsIDEProject(CurrentModule, sProjectName) or
    IsIDEPackage(CurrentModule) then
  begin
    MessageBox(WH, PChar(JVCSRES_Project_files_should_not_be_loaded_from_here46 + #13#10 +
      JVCSRES_Select_39Recent_Projects39_or_39File124Open_Project39_to_open_a_new_project46),
      cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
    Exit;
  end;
  {$ENDIF IDEDLL}

  // keine langen Dateinamen als Parameter?
  if jvcsReadBool(sBaseRegistryKey + crbOptions, 'UseShortFilenames', True) then
  begin
    SetLength(ShortModulName, MAX_PATH);
    SMSize := GetShortPathName(PChar(CurrentModule), PChar(ShortModulName), MAX_PATH);
    SetLength(ShortModulName, SMSize);
  end
  else
    ShortModulName := CurrentModule;

  // Nur Shell Extension?
  if not jvcsReadBool(sBaseRegistryKey + crbOptions, 'UseOnlyShellExt', True) then
  begin
    //nein
    // User Editor definiert?
    UserEditorPath :=
      jvcsReadString(sBaseRegistryKey + crbOptions, 'UserDefinedEditor', '');
    if UserEditorPath <> '' then
    begin
      if MatchWithFilter(ExtractFileName(CurrentModule),
        jvcsReadString(sBaseRegistryKey + crbFilters, 'User files', '')) then
      begin
        Loaded := True;
        ExecResult := ShellExecute(Application.Handle, 'open',
          PChar(UserEditorPath),
          PChar(ShortModulName),
          PChar(ExtractFileDir(ShortModulName)),
          sw_ShowNormal);
        if ExecResult < 32 then
        begin
          BeepIfSet;
          MessageBox(WH, PChar(Format(JVCSRES_ShellExecute_Error_6037s62,
            [ExtractFileName(UserEditorPath)]) + #10#13 +
            DecodeShellErr(ExecResult)),
            cMsgBoxCaption, MB_OK or MB_ICONWARNING);
        end // if ExecResult < 32 then begin
        else
        begin
          // Message Window
          Msg := Format(JVCSRES_Load_module58_37s_37s_45_Success, [UserEditorPath, ShortModulName]);
          Result := True;
        end;
      end; // if MatchWithFilter(Ext, UserEditorFilter) then begin
    end; // if UserEditorPath <> '' then begin
    if Loaded then
      Exit;
  end; // if not RegReadBool(HKCU, RegBaseKey, 'UseOnlyShellExt', false) then begin

  // IDE-Files
  {$IFDEF IDEDLL}
  if MatchWithFilter(ExtractFileName(CurrentModule),
    jvcsReadString(sBaseRegistryKey + crbFilters, 'IDE files', dfIDEEdit)) then
  begin
    Loaded := True;
    if not IDEInterface.OpenFile(GetOriginalFileName(CurrentModule)) then
    begin
      BeepIfSet;
      MessageBox(WH, PChar(Format(JVCSRES_JEDI_VCS_cannot_open_the_file46_40Invalid_path_or_access_denied4158 + #13#10 +
        '<%s>.' + #13#10 +
        JVCSRES_Make_sure_that_the_file_exists44_that_it_is_not_opened_by_another_application + #13#10 +
        JVCSRES_and_that_you_have_the_required_access_rights46, [CurrentModule])),
        cMsgBoxCaption, MB_OK or MB_ICONWARNING);
    end
    else
    begin
      // Message Window
      Msg := Format(JVCSRES_Load_module_40IDE4158_37s_45_Success, [CurrentModule]);
      Result := True;
    end;
  end; // if (Ext =.....
  if Loaded then
    Exit;
  {$ENDIF IDEDLL}

  // Nur Shell Extension?
  if not jvcsReadBool(sBaseRegistryKey + crbOptions, 'UseOnlyShellExt', True) then
  begin
    // Bitmapdateien mit Bitmapeditor starten
    if MatchWithFilter(ExtractFileName(CurrentModule),
      jvcsReadString(sBaseRegistryKey + crbFilters, 'Image files', dfBMPEdit)) then
    begin
      Loaded := True;
      BMPPath := jvcsReadString(sBaseRegistryKey + crbOptions, 'ImageEditor', '');
      if (BMPPath <> '') then
      begin
        ExecResult := ShellExecute(Application.Handle, 'open',
          PChar(BMPPath),
          PChar(ShortModulName),
          PChar(ExtractFileDir(ShortModulName)),
          sw_ShowNormal);
        if ExecResult < 32 then
        begin
          BeepIfSet;
          MessageBox(WH, PChar(Format(JVCSRES_ShellExecute_Error_6037s62,
            [ExtractFileName(BMPPath)]) + #10#13 +
            DecodeShellErr(ExecResult)),
            cMsgBoxCaption, MB_OK or MB_ICONWARNING);
        end // if ExecResult < 32 then begin
        else
        begin
          // Message Window
          Msg := Format(JVCSRES_Load_module58_37s_37s_45_Success, [BMPPath, ShortModulName]);
          Result := True;
        end;
      end // if (BMPPath <> '') then begin
      else
      begin
        case MessageBox(WH, PChar(Format(JVCSRES_You_do_not_have_a_JEDI_VCS_37s_editor_defined46 + #13#10 +
          JVCSRES_Would_you_like_to_do_this_now63, [JVCSRES_bitmap])),
          cMsgBoxCaption, MB_YESNOCANCEL or MB_ICONQUESTION) of
          id_Yes:
            ShowEditorOptions;
          id_No:
            Loaded := False;
          id_Cancel:
            Exit;
          else
            Exit;
        end;
      end; // else if (BMPPath <> '') then begin
    end; // if (Ext = '.bmp') then begin
    if Loaded then
      Exit;

    // Textdateien mit Texteditor starten
    if MatchWithFilter(ExtractFileName(CurrentModule),
       jvcsReadString(sBaseRegistryKey + crbFilters, 'Text files', dfTXTEdit)) then
    begin
      Loaded := True;
      TXTPath := jvcsReadString(sBaseRegistryKey + crbOptions, 'TextEditor', '');
      if (TXTPath <> '') then
      begin
        ExecResult := ShellExecute(Application.Handle, 'open',
          PChar(TXTPath),
          PChar(ShortModulName),
          PChar(ExtractFileDir(ShortModulName)),
          sw_ShowNormal);
        if ExecResult < 32 then
        begin
          BeepIfSet;
          MessageBox(WH, PChar(Format(JVCSRES_ShellExecute_Error_6037s62,
            [ExtractFileName(TXTPath)]) + #10#13 +
            DecodeShellErr(ExecResult)),
            cMsgBoxCaption, MB_OK or MB_ICONWARNING);
        end // if ExecResult < 32 then begin
        else
        begin
          // Message Window
          Msg := Format(JVCSRES_Load_module58_37s_37s_45_Success, [TXTPath, ShortModulName]);
          Result := True;
        end;
      end // if (TXTPath <> '') then begin
      else
      begin
        case MessageBox(WH, PChar(Format(JVCSRES_You_do_not_have_a_JEDI_VCS_37s_editor_defined46 + #13#10 +
          JVCSRES_Would_you_like_to_do_this_now63, [JVCSRES_text])),
          cMsgBoxCaption, MB_YESNOCANCEL or MB_ICONQUESTION) of
          id_Yes:
            ShowEditorOptions;
          id_No:
            Loaded := False;
          id_Cancel:
            Exit;
          else
            Exit;
        end;
      end; // if (TXTPath <> '') then begin
    end; // if (Ext = '.txt') then begin
    if Loaded then
      Exit;

    // Resourcendateien mit RWS starten
    if MatchWithFilter(ExtractFileName(CurrentModule),
      jvcsReadString(sBaseRegistryKey + crbFilters, 'Resource files', dfRWSEdit)) then
    begin
      Loaded := True;
      RWSPath := jvcsReadString(sBaseRegistryKey + crbOptions, 'ResourceEditor', '');
      if (RWSPath <> '') then
      begin
        // RWS verträgt keine langen Dateinamen als Parameter
        ExecResult := ShellExecute(Application.Handle, 'open',
          PChar(RWSPath),
          PChar(ShortModulName),
          PChar(ExtractFileDir(ShortModulName)),
          sw_ShowNormal);
        if ExecResult < 32 then
        begin
          BeepIfSet;
          MessageBox(WH, PChar(Format(JVCSRES_ShellExecute_Error_6037s62,
            [ExtractFileName(RWSPath)]) + #10#13 +
            DecodeShellErr(ExecResult)),
            cMsgBoxCaption, MB_OK or MB_ICONWARNING);
        end // if ExecResult < 32 then begin
        else 
        begin
          // Message Window
          Msg := Format(JVCSRES_Load_module58_37s_37s_45_Success, [RWSPath, ShortModulName]);
          Result := True;
        end;
      end // if (RWSPath <> '') then begin
      else 
      begin
        case MessageBox(WH, PChar(Format(JVCSRES_You_do_not_have_a_JEDI_VCS_37s_editor_defined46 + #13#10 +
          JVCSRES_Would_you_like_to_do_this_now63, [JVCSRES_resource])),
          cMsgBoxCaption, MB_YESNOCANCEL or MB_ICONQUESTION) of
          id_Yes:
            ShowEditorOptions;
          id_No:
            Loaded := False;
          id_Cancel: 
            Exit;
          else 
            Exit;
        end;
      end; // if (RWSPath <> '') then begin
    end; // if (Ext = '.res') then begin
    if Loaded then 
      Exit;
  end; // if not RegReadBool(HKCU, RegBaseKey, 'UseOnlyShellExt', false) then begin

  // Versuche, die Datei direkt zu starten
  if not Loaded then 
  begin
    ExecResult := ShellExecute(Application.Handle, 'open',
      PChar(ShortModulName),
      PChar(''),
      PChar(ExtractFileDir(ShortModulName)),
      sw_ShowNormal);
    if ExecResult < 32 then 
    begin
      if ExecResult <> SE_ERR_NOASSOC then 
      begin
        BeepIfSet;
        MessageBox(WH, PChar(Format(JVCSRES_ShellExecute_Error_6037s62,
          [ExtractFileName(ShortModulName)]) + #10#13 +
          DecodeShellErr(ExecResult)),
          cMsgBoxCaption, MB_OK or MB_ICONWARNING);
      end
      else 
      begin
        if MessageBox(WH, PChar(Format(JVCSRES_There_is_no_application_associated_with_the_given_file_extension_4037s4146 + #13#10 +
          JVCSRES_Would_you_like_to_select_an_application_now63, [ExtractFileExt(CurrentModule)])),
          cMsgBoxCaption, MB_YESNOCANCEL or MB_ICONQUESTION) <> idYes then 
          Exit;
        PerformDefaultAction(ShortModulName, WH);
      end;
    end // if ExecResult < 32 then begin
    else 
    begin
      // Message Window
      Msg := Format(JVCSRES_Load_module_40ShellExecute4158_37s_45_Success, [ShortModulName]);
      Result := True;
    end;
  end; // if not Loaded then begin
end;

end.
