(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: About.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS: Thomas Huber (Thomas_D_Huber@t-online.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FreeVCS code to JEDI VCS
2003/02/17  USchuster - changed the layout and added credits
2003/03/01  THensle   - changed the layout/ removed some obsolete parts/
                        added license tab/ added contributers
                        shows license tab at first start
2003/08/31  USchuster - changed JEDI-VCS to JEDI VCS in unit header,
                        message boxes and in form
                      - removed GetVersionUserItem -> can be done with
                        TStrings.Values[]
                      - simplified retrieving of FileDate
2003/09/07  THuber    - extended contributors list:
                        Pasacl Lauret (jvcs console client)
                        Matej Golob (testing Firebirdserver port)
2003/10/17  USchuster - use SelfFileName for versioninformation
2003/12/27  THuber    - Updated Contributors list according to Releasenotes
                      - JVCSClientFunctions included in uses
                      - CryptDLLName now in JVCSClientConsts
2004/01/08  USchuster - moved main parts of the dialog to JVCSBaseAboutDialog.pas
2004/07/04  USchuster - changes for mantis #1899 (expected server version can be a range now)
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/03  THuber    - jedistyle cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/10/08  THuber    - use jvcl msgBoxes
                      - resource strings now in JVCSGUIClientResources
2009/12/28  THuber    - added JVCSClientConsts to uses (as some consts were moved from VCSBase there)

-----------------------------------------------------------------------------

Known Issues:

-----------------------------------------------------------------------------*)
{$I jedi.inc}

unit About;

{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  JVCSBaseAboutDialog, StdCtrls, ExtCtrls, ComCtrls, JvExStdCtrls,
  JvRichEdit;

type
  TVCSAbout = class(TJVCSBaseAboutDlg)
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  protected
    function GetVersionInformation(AwithFileDate: Boolean): string; override;
  public
    { Public declarations }
  end;

var
  VCSAbout: TVCSAbout;

implementation

uses
    VCSCommon
  , VCSBase
  , VCSProcBase
  , JVCSClientConsts
  , JclFileUtils
  , JvJVCLUtils
  , JVCSGUIClientResources
{$IFDEF LANGUAGE}
  , JvGnugettext
{$ENDIF LANGUAGE}
  ;

{$R *.dfm}

procedure TVCSAbout.FormCreate(Sender: TObject);
begin
  try
    {$IFDEF BETA}
    if cBetaDateTime >= Now then
    begin
      MsgOK ( WindowHandle
            , Format( JVCSRES_Beta_37s + #13+#10 +
                      JVCSRES_This_is_a_beta_version_for_test_and_debug_purposes33 + #13+#10 +
                      JVCSRES_Do_NOT_publish_or_distribute_this_version33 + #13+#10 +
                      JVCSRES_This_version_expires_after_37s33
                    , [cBetaVer, DateTimeToStr(cBetaDateTime)]
                    )
              , JVCSRES_JEDI_VCS_Beta_Version
              , MB_ICONWARNING
              );
    end; // if cBetaDateTime >= Now then begin
    {$ENDIF BETA}
    inherited;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(self);
    {$ENDIF LANGUAGE}
  end;
end;

procedure TVCSAbout.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Credits_Copyrights);
end;

function TVCSAbout.GetVersionInformation(AwithFileDate: Boolean): string;
var
  Msg: string;
  JclFileVersionInfo: TJclFileVersionInfo;
begin
  Msg := inherited GetVersionInformation(AwithFileDate);

  Msg := Msg + JVCSRES_Installed_versions58 + #13;

  // -- Version of crypt Dll
  if FileExists(sDLLDirectory + cCryptDLLName) then
  begin
    JclFileVersionInfo := TJclFileVersionInfo.Create(sDLLDirectory + cCryptDLLName);
    try
      Msg := Msg + cCryptDLLName + ' V ' + JclFileVersionInfo.ProductVersion + ' [' +
              JclFileVersionInfo.FileVersion + ']' + #13;
    finally
      JclFileVersionInfo.Free;
    end;
  end
  else
  begin
    Msg := Msg + cCryptDLLName + ' N/A' + #13;
  end;

  // -- Version of Diff Tool  
  if FileExists(sDLLDirectory + cVCSDiffName) then
  begin
    JclFileVersionInfo := TJclFileVersionInfo.Create(sDLLDirectory + cVCSDiffName);
    try
      Msg := Msg + cVCSDiffName + ' V ' + JclFileVersionInfo.ProductVersion + ' [' +
              JclFileVersionInfo.FileVersion + ']' + #13;
    finally
      JclFileVersionInfo.Free;
    end;
  end
  else
  begin
    Msg := Msg + cVCSDiffName + ' N/A' + #13;
  end;

  // -- Version of report-dll
  if FileExists(sDLLDirectory + cJVCSReportDll) then
  begin
    JclFileVersionInfo := TJclFileVersionInfo.Create(sDLLDirectory + cJVCSReportDll);
    try
      Msg := Msg + cJVCSReportDll + ' V ' + JclFileVersionInfo.ProductVersion + ' [' +
              JclFileVersionInfo.FileVersion + ']' + #13;
    finally
      JclFileVersionInfo.Free;
    end;
  end 
  else 
  begin
    Msg := Msg + cJVCSReportDll + ' N/A' + #13;
  end;

  // -- Version of DelZip Zip-dll
  if FileExists(sDLLDirectory + 'zipdll.dll') then 
  begin
    JclFileVersionInfo := TJclFileVersionInfo.Create(sDLLDirectory + 'zipdll.dll');
    try
      Msg := Msg + 'zipdll.dll' + ' V ' + JclFileVersionInfo.ProductVersion + ' [' +
              JclFileVersionInfo.FileVersion + ']' + #13;
    finally
      JclFileVersionInfo.Free;
    end;
  end
  else
  begin
    Msg := Msg + 'zipdll.dll' + ' N/A' + #13;
  end;

  // -- Version of DelZip Zip-dll
  if FileExists(sDLLDirectory + 'unzdll.dll') then
  begin
    JclFileVersionInfo := TJclFileVersionInfo.Create(sDLLDirectory + 'unzdll.dll');
    try
      Msg := Msg + 'unzdll.dll' + ' V ' + JclFileVersionInfo.ProductVersion + ' [' +
              JclFileVersionInfo.FileVersion + ']' + #13;
    finally
      JclFileVersionInfo.Free;
    end;
  end
  else
  begin
    Msg := Msg + 'unzdll.dll' + ' N/A' + #13;
  end;

  Msg := Msg + #13 + JVCSRES_Required_server47service_versions58 + #13 +
         GetSrvRequiredVersionString(svIdOraOci) + #13 +
         GetSrvRequiredVersionString(svIdUIB) + #13 +
         GetSrvRequiredVersionString(svIdMSSQL) + #13 +
         GetSrvRequiredVersionString(svIdMySQL);

  Result := Msg;
end;

end.
