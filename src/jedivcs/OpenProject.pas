(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: OpenProject.pas

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS: Thomas Huber (Thomas_D_Huber@gmx.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FreeVCS code to JEDI VCS
2003/02/12  USchuster - changed DSAMsg with JVCSDialogs in uses clause to use JvDSADialogs
2003/03/05  THensle   - changes for "ConfigStorage" unit
2003/11/19  USchuster - changed 'FreeVCS' in messageboxes to 'JEDI VCS'
                        with constant cMsgBoxCaption from VCSBase.pas
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/25  USchuster - style cleaning
                      - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/11/02  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit OpenProject;

// Added by F. Libaud
{$ifdef FPC}
  {$MODE DELPHI}
{$endif}

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, JVCSForms;

type
  TVCSOpenProject = class(TJVCSForm)
    edProjectName: TEdit;
    btnOK: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    Help: TSpeedButton;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure edProjectNameChange(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure HelpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    NewProjectName: string;
  end;

var
  VCSOpenProject: TVCSOpenProject;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSBase, VCSProcBase, JVCSDialogs, ConfigStorage, JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSOpenProject.FormCreate(Sender: TObject);
begin
  try
    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);
    NewProjectName := '';
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSOpenProject.btnOKClick(Sender: TObject);
var 
  Msg, TMPDirectory, TestFileName: string;
  I, DlgResult: Integer;
  TestFile: file;
begin
  if not IsValidProjectName(edProjectName.Text, Msg) then 
  begin
    MessageBox(WindowHandle, PChar(Format('<%s>' + #13#10 + '%s' + #13#10 +
      JVCSRES_See_help_topic_34Naming_conventions34_for_more_information46,
      [AnsiLowerCase(edProjectName.Text), Msg])),
      cMsgBoxCaption, MB_OK or MB_ICONEXCLAMATION);
    edProjectName.SetFocus;
    edProjectName.SelectAll;
    Exit;
  end;

  UseRegistry := True;
  DontShowMsgText := JVCSRES_38Don39t_show_this_message_again46;
  DlgResult := DSAIdentsMessageDlg(JVCSRES_Project_names_are_subject_to_the_naming_conventions_of_the_operating_system46 + #13#10 +
    JVCSRES_JEDI_VCS_can_check_for_you_if_the_project_name_matches_these_conditions46 + #13#10 +
    JVCSRES_Remember_that_the_test_will_overwrite_existing_files_with_the_same_name_in_your_temporary_foder46 + #13#10 +
    JVCSRES_Check_now63
    , mtConfirmation
    , [mbYes, mbNo, mbCancel]
    , 0
    , sBaseRegistryKey + crbMRU + 'Dlgs'
    , 'ChkPName'
    , idNo
    );
  Screen.Cursor := crHourGlass;
  case DlgResult of
    idNo :;
    idCancel :
      begin
        Screen.Cursor := crDefault;
        Exit;
      end;
    idYes :
      begin
        // TMP - Verzeichnis ?
        TMPDirectory :=
          jvcsReadString(sBaseRegistryKey + crbOptions, 'TempDirectory', '');
        if TMPDirectory = '' then
        begin
          I := 255;
          SetLength(TMPDirectory, I);
          I := GetTempPath(I, PChar(TMPDirectory));
          if I = 0 then
          begin
            BeepIfSet;
            MessageBox(WindowHandle, PChar(JVCSRES_JEDI_VCS_cannot_detect_the_name_of_the_local_temporary_directory46 + #13#10 +
              JVCSRES_Try_to_define_a_temporary_directory_in_34Properties124Folders34_and_retry46), cMsgBoxCaption,
              MB_OK or MB_ICONWARNING);
            Screen.Cursor := crDefault;
            Exit;
          end;
          SetLength(TMPDirectory, StrLen(PChar(TMPDirectory)));
        end; // if TMPDirectory = '' then begin
        TestFileName := SetBackSlash(TMPDirectory) + edProjectName.Text;
        if FileExists(TestFileName) then
          SysUtils.DeleteFile(TestFileName);
        AssignFile(TestFile, TestFileName);
        try
          Rewrite(TestFile);
          CloseFile(TestFile);
        except
          BeepIfSet;
          MessageBox(WindowHandle, PChar(Format('<%s>' + #13#10 +
            JVCSRES_JEDI_VCS_cannot_create_the_file_on_disk46 + #13#10 +
            JVCSRES_The_project_name_seems_to_be_invalid46, [TestFileName])),
            cMsgBoxCaption, MB_OK or MB_ICONWARNING);
          Screen.Cursor := crDefault;
          edProjectName.SetFocus;
          edProjectName.SelectAll;
          Exit;
        end;
        if FileExists(TestFileName) then
          SysUtils.DeleteFile(TestFileName);
        MessageBox(WindowHandle,
          PChar(JVCSRES_The_name_matches_the_naming_conventions_of_the_operating_system46),
          cMsgBoxCaption, MB_OK or MB_ICONINFORMATION);
      end; // idYes
  end; // case DlgResult of
  Screen.Cursor := crDefault;

  NewProjectName := edProjectName.Text;
  ModalResult := mrOk;
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSOpenProject.edProjectNameChange(Sender: TObject);
begin
  btnOK.Enabled := edProjectName.Text <> '';
end;

//------------------------------------------------------------------------------

procedure TVCSOpenProject.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then 
  begin
    btnCancel.Click;
    Key := 0;
  end;    
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Create_projects);
end;

//------------------------------------------------------------------------------

procedure TVCSOpenProject.HelpClick(Sender: TObject);
begin
  PerformHelpCommand(Application, IDH_Create_projects);
end;

end.
