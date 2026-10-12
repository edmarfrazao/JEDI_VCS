(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: BackupTreeOptions.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2003/04/16  USchuster - new unit
2003/04/29  USchuster - added icon to form (necessary for IDE Version)
                      - D5 fix
2004/03/20  USchuster - added caption for dialog and zip file label to GetBackupTreeOptions
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/31  USchuster - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/11/05  USchuster - moved resourcestrings to JVCSGUIClientResources.pas                      
2010/01/24  THuber    #4097 changed to sizable form design
2011/01/15  USchuster - changed font to Tahoma                       

-----------------------------------------------------------------------------*)

unit BackupTreeOptions;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, ExtCtrls;

type
  TJVCSBackupTreeOptions = class(TForm)
    gbOutputStructure: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    rbFormat2: TRadioButton;
    rbFormat1: TRadioButton;
    rbFormat3: TRadioButton;
    PanelBottom: TPanel;
    btnBackup: TButton;
    btnCancel: TButton;
    GroupBoxZipFile: TGroupBox;
    edbackupzipfile: TEdit;
    spBtnBackupZipFile: TSpeedButton;
    procedure spBtnBackupZipFileClick(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  JVCSBackupTreeOptions: TJVCSBackupTreeOptions;

function GetBackupTreeOptions(const ACaption: string; const AZipFileCaption: string;
  var ABackupZipFile, AOutputFormat: string): Boolean;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSBase, VCSProcBase, FavOpenDialog, JVCSGUIClientResources, ConfigStorage;

{$R *.dfm}

function GetBackupTreeOptions(const ACaption: string; const AZipFileCaption: string;
  var ABackupZipFile, AOutputFormat: string): Boolean;
begin
  JVCSBackupTreeOptions := TJVCSBackupTreeOptions.Create(Application);
  try
    with JVCSBackupTreeOptions do
    begin
      Caption := ACaption;
      GroupBoxZipFile.Caption := AZipFileCaption;
      edbackupzipfile.Text := ABackupZipFile;
      Result := ShowModal = mrOk;
      if Result then
      begin
        ABackupZipFile := edbackupzipfile.Text;
        if rbFormat1.Checked then
          AOutputFormat :=
            '%MODNAME%.%MODEXT%\Version%VER%\Revision%REV%\%MODNAME%.%REVEXT%'
        else
        if rbFormat2.Checked then
          AOutputFormat :=
            '%MODPATH%\%MODNAME%_%.2VER%_%.3REV%.%REVEXT%'
        else
        if rbFormat3.Checked then
          AOutputFormat :=
            '%MODPATH%\%MODNAME%.%REVEXT%.%.2VER%.%.3REV%';
      end;
    end;
  finally
    JVCSBackupTreeOptions.Free;
  end;
end;

procedure TJVCSBackupTreeOptions.spBtnBackupZipFileClick(Sender: TObject);
var
  FavSaveDialog: TFavSaveDialog;
  DlgResult: Boolean;
begin
  FavSaveDialog := TFavSaveDialog.Create(Application);
  try
    with FavSaveDialog do
    begin
      Title := JVCSRES_Development_state_backup_to_zip_file;
      Options := [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing];
      Filter := JVCSRES_Zip_files_404246zip411244246zip;
      FileName := edbackupzipfile.Text;
      DefaultExt := 'zip';

      //FavSaveDialog is inherited from FavOpenDialog and thatswhy
      //ExecuteFavOpenDialogWithMru also works here
      DlgResult := ExecuteFavOpenDialogWithMru(FavSaveDialog,
        sBaseRegistryKey + crbMRU + '17');

      if DlgResult then
        edbackupzipfile.Text := FileName;
    end; // with SaveDialog1 do begin
  finally
    FavSaveDialog.Free;
  end;
end;

procedure TJVCSBackupTreeOptions.Label1Click(Sender: TObject);
begin
  rbFormat1.Checked := True;
end;

procedure TJVCSBackupTreeOptions.Label2Click(Sender: TObject);
begin
  rbFormat2.Checked := True;
end;

procedure TJVCSBackupTreeOptions.Label3Click(Sender: TObject);
begin
  rbFormat3.Checked := True;
end;

procedure TJVCSBackupTreeOptions.FormCreate(Sender: TObject);
begin
  try
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

procedure TJVCSBackupTreeOptions.FormShow(Sender: TObject);
begin
  jvcsLoadFormPosSize(Self);
end;

procedure TJVCSBackupTreeOptions.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  jvcsSaveFormPosSize(Self); 
end;

end.
