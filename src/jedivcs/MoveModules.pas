(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: MoveModules.pas

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
2003/02/12  USchuster - fixed mantis bugs #674 and #675
                        #674
                          reason: an exception avoided to set the Std ColWidths
                                  and thatswhy the filelist seemed to be empty
                                  although the list was filled (ColWidths were 0)
                          solution: avoid the exception
                        #675
                          reason: GetHitTestInfoAt seems to deliver always
                                  htOnItem in Ownerdraw mode
                          solution: ownerdraw is not necessary -
                                    RowSelect is a property and there is no need
                                    to use OwnDrawItem to set it
2003/02/18  MGosselink- emptied some .text props
2003/03/05  THensle   - changes for "ConfigStorage" unit
2003/10/05  THuber    - compiler hints & warnings
2003/12/28  USchuster - changed JEDI-VCS to JEDI VCS in unit header and
                        message boxes (use constant)
2004/04/17  USchuster - fixed minimum size
                      - minor style cleaning (casing and comments)
                      - moved some strings to JVCSGUIClientResources.pas
2004/09/17  FHasovic  - Added dxGetText support for localization
2004/10/01  THuber    #2147 - checkbox to hide hidden modules (default = true)
2004/10/26  USchuster - localization of Fikret Hasovic from newideas project
                        with over IFDEF LANGUAGE
                      - res strings and displayed strings changed to resourcestrings
2004/11/02  USchuster - moved resourcestrings to JVCSGUIClientResources.pas
2007/06/30  USchuster - changes for large fonts (contraints and default size depend now on PixelsPerInch; analog to Mantis #3710)                      
2008/12/22  THuber    - Baseclass changed to TJVCSForm
2011/01/15  USchuster - changed font to Tahoma

-----------------------------------------------------------------------------*)

unit MoveModules;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, ImgList, ExtCtrls, ComCtrls, Menus, EnhListView,
  ActnList, JVCSForms;

type
  TVCSModMove = class(TJVCSForm)
    Panel1: TPanel;
    btnReplace: TButton;
    btnClose: TButton;
    edNewPath: TEdit;
    spBtnBrowse: TSpeedButton;
    StateImageList: TImageList;
    SysImageList: TImageList;
    Help: TSpeedButton;
    PopupMenu1: TPopupMenu;
    SelectAll1: TMenuItem;
    UnselectAll1: TMenuItem;
    elvModules: TdfsEnhListView;
    SelectHighlighted1: TMenuItem;
    rbWhole: TRadioButton;
    edOldPart: TEdit;
    edNewPart: TEdit;
    rbPartly: TRadioButton;
    Label1: TLabel;
    Label2: TLabel;
    cbHideHiddenModules: TCheckBox;
    N1: TMenuItem;
    ActionList1: TActionList;
    acHideHiddenModules: TAction;
    acHideHiddenModules1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure spBtnBrowseClick(Sender: TObject);
    procedure btnReplaceClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnRefreshClick(Sender: TObject);
    procedure edNewPathChange(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);
    procedure UnselectAll1Click(Sender: TObject);
    procedure elvModulesKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure elvModulesMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SelectHighlighted1Click(Sender: TObject);
    procedure rbWholeClick(Sender: TObject);
    procedure acHideHiddenModulesExecute(Sender: TObject);
  private
    { Private declarations }
    FCreating: Boolean;
    FFilling : Boolean;
    procedure FillListView;
  public
    { Public declarations }
    ModulesMoved: Boolean;
    SelectedProjectID: Integer;
    procedure RestrictSize(var Msg: TMessage); message WM_GETMINMAXINFO;
  end;

var
  VCSModMove: TVCSModMove;

implementation

uses
  {$IFDEF LANGUAGE}
  JvGnugettext,
  {$ENDIF LANGUAGE}
  VCSBase, VCSProcBase, SelectFolder, DBModule, ShellAPI, Yes2allDlg, CommCtrl,
  ConfigStorage, JVCSDialogs, JVCSGUIClientResources;

{$R *.dfm}

procedure TVCSModMove.FormCreate(Sender: TObject);
var
  DlgWidth, DlgHeight: Integer;
  sfi: TSHFileInfo;
begin
  try
    FCreating := True;
    ModulesMoved := False;
    FFilling := False;

    ShowHint := jvcsReadBool(sBaseRegistryKey + crbOptions, 'ShowToolTip', True);

    if not jvcsReadWindowSize(sBaseRegistryKey + crbWindows, 'MoveModules',
      DlgWidth, DlgHeight) then
    begin
      DlgWidth := MulDiv(370, PixelsPerInch, 96);
      DlgHeight := MulDiv(320, PixelsPerInch, 96);
    end;
    Width := DlgWidth;
    Height := DlgHeight;

    with elvModules do
    begin
      Columns[0].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'MoveModules_Col1.0', 150);
      Columns[1].Width :=
        jvcsReadInteger(sBaseRegistryKey + crbWindows, 'MoveModules_Col1.1', 200);
      {$IFNDEF SHOWIDS}
      Columns[2].Width := 0;
      {$ENDIF ~SHOWIDS}
      RowSelect := True;
    end;

    edNewPath.Text :=
      jvcsReadString(sBaseRegistryKey + crbWindows, 'MoveModules_NewPath',
      JVCSRES_60enter_the_new_path62);
    edOldPart.Text :=
      jvcsReadString(sBaseRegistryKey + crbWindows, 'MoveModules_OldPath',
      JVCSRES_60part_to_exchange62);
    edNewPart.Text :=
      jvcsReadString(sBaseRegistryKey + crbWindows, 'MoveModules_NewPart',
      JVCSRES_60new_part62);

    //Systemsymbole in eine TImageList-Komponente einlesen
    SysImageList.Handle := SHGetFileInfo('', 0, sfi, SizeOf(TSHFileInfo),
      SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
    SysImageList.ShareImages := True;

    Screen.Cursors[cPopUpMCursor] := LoadCursor(hInstance, PChar('CURSORRM'));
    elvModules.Cursor := cPopUpMCursor;
    rbWhole.Checked := True;
  finally
    {$IFDEF LANGUAGE}
    //Translate form
    TranslateComponent(Self);
    {$ENDIF LANGUAGE}
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSModMove.FormActivate(Sender: TObject);
begin
  Application.ProcessMessages;
  if FCreating then 
  begin
    FCreating := False;
    FillListView;
  end; // if FCreating then begin
end;

//------------------------------------------------------------------------------

procedure TVCSModMove.FillListView;
var 
  sfi: TSHFileInfo;
  LVItem: TListItem;
begin
  if not FFilling then
  begin
    FFilling := True;
    try
      with DataModule1 do
      begin
        AppSrvClient1.Request.Rewrite;
        AppSrvClient1.FunctionCode := 'GET_PROJECT_MODULE_LIST';
        AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
        AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
        AppSrvClient1.Request.WriteFields(True, [SelectedProjectID]);
        AppSrvClient1.Request.WriteFields(False, [cbHideHiddenModules.Checked]);
        SetupTimeoutCounter;
        AppSrvClient1.Send;

        while WaitForAppSrvClient do
          Application.ProcessMessages;
        if (AppSrvClientErr = -99) then 
        begin
          ShowServerTimeOut(WindowHandle);
          Exit;
        end;
        if (AppSrvClientErr <> 0) or
          (AppSrvClient1.AnswerStatus <> '200') then 
        begin
          ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
            AppSrvClient1.AnswerStatus);
          Exit;
        end;

        AppSrvClient1.Answer.First;
        elvModules.BeginUpdate;
        try
          elvModules.Items.Clear;
          while not AppSrvClient1.Answer.Eof do
          begin
            LVItem := elvModules.Items.Add;
            // FileIcon
            if FileExists(AppSrvClient1.Answer.Fields[2] +
              AppSrvClient1.Answer.Fields[1]) then 
            begin
              LVItem.Caption := ExtractFileName(GetOriginalFileName(AppSrvClient1.Answer.Fields[2] +
                AppSrvClient1.Answer.Fields[1]));
              SHGetFileInfo(PChar(AppSrvClient1.Answer.Fields[2] +
                AppSrvClient1.Answer.Fields[1]), 0, sfi, SizeOf(sfi),
                SHGFI_SYSICONINDEX or SHGFI_SMALLICON or SHGFI_DISPLAYNAME);
              LVItem.ImageIndex := sfi.IIcon;
            end 
            else
            begin
              LVItem.Caption := AppSrvClient1.Answer.Fields[1];
              LVItem.ImageIndex := -1;
            end;
            LVItem.StateIndex := 0;
            LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[2]);
            LVItem.SubItems.Add(AppSrvClient1.Answer.Fields[0]);
            AppSrvClient1.Answer.Next;
          end;
        finally
          elvModules.EndUpdate;
        end;
      end; // with DataModule1 do begin}
    finally
      FFilling := False;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSModMove.spBtnBrowseClick(Sender: TObject);
begin
  VCSSelectFolder := TVCSSelectFolder.Create(Application);
  try
    VCSSelectFolder.SetStatusText(JVCSRES_New_38module_path58);
    VCSSelectFolder.EnableRecursive(False);    
    VCSSelectFolder.HelpContextID := IDH_Updating_moved_modules;
    if bProjectOpen then
      VCSSelectFolder.SetInitialDir(ExtractFilePath(sProjectName));
    VCSSelectFolder.EnableNewFolder(False);
    VCSSelectFolder.ShowModal;
    if VCSSelectFolder.Selection <> '' then 
    begin
      edNewPath.Text := SetBackSlash(AnsiLowerCase(VCSSelectFolder.Selection));
    end; // if VCSSelectFolder.Selection <> '' then begin
  finally
    VCSSelectFolder.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSModMove.btnReplaceClick(Sender: TObject);
var 
  Mess, NewPath: string;
  Yes2AllRes, I: Integer;
  Yes2All, Skip: Boolean;
begin
  Yes2All := False;
  with elvModules do 
  begin
    for I := 0 to Items.Count - 1 do
    begin
      if Items[I].StateIndex = 1 then 
      begin
        if rbWhole.Checked then
          NewPath := edNewPath.Text
        else
        begin
          if (edOldPart.Text = '') or (edNewPart.Text = '') then 
          begin
            MessageBox(WindowHandle, PChar(Format(JVCSRES_6037s6246_This_value_cannot_be_blank46,
              [JVCSRES_old_part47new_part])),
              cMsgBoxCaption, MB_OK or MB_ICONWARNING);
            Exit;
          end; // if (edOldPart.Text = '') or (edNewPart.Text = '') then begin
          NewPath := SearchAndChange(Items[I].SubItems[0], edOldPart.Text, edNewPart.Text);
        end;
        NewPath := SetBackSlash(NewPath);
        if not FileExists(NewPath + Items[I].Caption) then
        begin
          Mess := Format(JVCSRES_Module_6037s62_not_found_in + #13#10 +
            '<%s>.' + #13#10 +
            JVCSRES_First_move_the_modules44_then_update_the_archive46, [Items[I].Caption, NewPath]);
          MessageBox(WindowHandle, PChar(Mess), cMsgBoxCaption, MB_OK or MB_ICONWARNING);
          Exit;
        end; // if not FileExists(NewPath + CurrModule) then begin

        Skip := False;
        if not Yes2All then 
        begin
          VCSYes2AllDlg := TVCSYes2AllDlg.Create(Application);
          try
            VCSYes2AllDlg.EnableYes2All(True);
            VCSYes2AllDlg.SetMessageText(Format(JVCSRES_Are_you_sure_you_want_to_move_6037s62 + #13#10 +
              JVCSRES_to_6037s6263, [Items[I].Caption, NewPath]));
            Yes2AllRes := VCSYes2AllDlg.ShowModal;
          finally
            VCSYes2AllDlg.Free;
          end;
          case Yes2AllRes of
            mrYes :;
            mrAll: 
              Yes2All := True;
            mrNo: 
              Skip := True;
            mrCancel: 
              Exit;
          end; // case Yes2AllRes of
        end; // if not Yes2All then begin
        if not Skip then 
        begin
          with DataModule1 do 
          begin
            AppSrvClient1.Request.Rewrite;
            AppSrvClient1.FunctionCode := 'MOVE_MODULE';
            AppSrvClient1.Request.WriteFields(True, [TransactionNr]);
            AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
            AppSrvClient1.Request.WriteFields(True, [SelectedProjectID]);
            AppSrvClient1.Request.WriteFields(False, [ServerUserID]);
            AppSrvClient1.Request.WriteFields(False, [Items[I].SubItems[1]]);
            AppSrvClient1.Request.WriteFields(False, [NewPath]);
            AppSrvClient1.Request.WriteFields(False,
              [Items[I].SubItems[0] + LowerCase(Items[I].Caption)]);
            SetupTimeoutCounter;
            AppSrvClient1.Send;

            while WaitForAppSrvClient do 
              Application.ProcessMessages;
            if (AppSrvClientErr = -99) then 
            begin
              ShowServerTimeOut(WindowHandle);
              Exit;
            end;
            if (AppSrvClientErr <> 0) or
              (AppSrvClient1.AnswerStatus <> '200') then 
            begin
              ShowServerError(WindowHandle, AppSrvClient1.Answer.Fields[0],
                AppSrvClient1.AnswerStatus);
              Exit;
            end;

            AppSrvClient1.Answer.First;
            if not DecodeBoolStr(AppSrvClient1.Answer.Fields[0]) then 
            begin
              BeepIfSet;
              Mess := '<' + Items[I].Caption + '>' + #10#13 +
                Format(JVCSRES_This_is_a_37s46, [AppSrvClient1.Answer.Fields[1]]) +
                ' ' + JVCSRES_Access_denied46;
              WarnMessageBox(Mess);
            end 
            else
            begin
              ModulesMoved := True;
              Items[I].SubItems[0] := NewPath;
              Items[I].StateIndex := 0;
            end;
          end; // with DataModule1 do begin}
        end; // if not Skip then begin
      end; // if Items[I].StateIndex = 1 then begin
    end; // for I := 0 to Items.Count - 1 do begin
  end; // with elvModules do begin
end;

//------------------------------------------------------------------------------

procedure TVCSModMove.btnCloseClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------

procedure TVCSModMove.FormDestroy(Sender: TObject);
begin
end;

//------------------------------------------------------------------------------

procedure TVCSModMove.RestrictSize(var Msg: TMessage);
var
  P: PMinMaxInfo;
begin
  // The lParam contains a pointer on a structure of type TMinMaxInfo
  P := PMinMaxInfo(Msg.lParam);
  // This represents the size of the Window when Maximized
  P.ptMaxSize.x := trResDesktop.Right;
  P.ptMaxSize.y := trResDesktop.Bottom;
  // This represents the position of the Window when Maximized
  P.ptMaxPosition.x := 0;
  P.ptMaxPosition.y := 0;
  // This represents the minimum size of the Window
  P.ptMinTrackSize.x := MulDiv(360, PixelsPerInch, 96);
  P.ptMinTrackSize.y := MulDiv(240, PixelsPerInch, 96);
end;

//------------------------------------------------------------------------------

procedure TVCSModMove.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  jvcsWriteWindowSize(sBaseRegistryKey + crbWindows, 'MoveModules',
    Width, Height);

  with elvModules do
  begin
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'MoveModules_Col1.0',
      Columns[0].Width);
    jvcsWriteInteger(sBaseRegistryKey + crbWindows, 'MoveModules_Col1.1',
      Columns[1].Width);
  end;

  jvcsWriteString(sBaseRegistryKey + crbWindows, 'MoveModules_NewPath',
    edNewPath.Text);
  jvcsWriteString(sBaseRegistryKey + crbWindows, 'MoveModules_OldPath',
    edOldPart.Text);
  jvcsWriteString(sBaseRegistryKey + crbWindows, 'MoveModules_NewPart',
    edNewPart.Text);
end;

//------------------------------------------------------------------------------

procedure TVCSModMove.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    btnClose.Click;
    Key := 0;
  end;
  if Key = VK_F1 then
    PerformHelpCommand(Application, IDH_Updating_moved_modules);
end;

//------------------------------------------------------------------------------

procedure TVCSModMove.elvModulesMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var 
  HitTest: THitTests;
  HitItem: TListItem;
begin
  HitTest := elvModules.GetHitTestInfoAt(X, Y);
  if (Button = mbLeft) and (htOnStateIcon in HitTest) then 
  begin
    HitItem := elvModules.GetItemAt(X, Y);
    if HitItem.StateIndex = 0 then 
      HitItem.StateIndex := 1 
    else 
      HitItem.StateIndex := 0;
  end; // if (Button = mbLeft) and (htOnStateIcon in HitTest) then begin
end;

//------------------------------------------------------------------------------

procedure TVCSModMove.btnRefreshClick(Sender: TObject);
begin
  FillListView;
end;

//------------------------------------------------------------------------------

procedure TVCSModMove.edNewPathChange(Sender: TObject);
begin
  btnReplace.Enabled := edNewPath.Text <> '';
end;

//------------------------------------------------------------------------------

procedure TVCSModMove.elvModulesKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (elvModules.Selected <> nil) and (Key = VK_SPACE) then 
  begin
    if elvModules.Selected.StateIndex > 1 then 
      Exit;
    if elvModules.Selected.StateIndex = 0 then 
      elvModules.Selected.StateIndex := 1
    else 
      elvModules.Selected.StateIndex := 0;
  end;
end;

//------------------------------------------------------------------------------

procedure TVCSModMove.HelpClick(Sender: TObject);
var 
  HelpKey: Word;
begin
  HelpKey := VK_F1;
  FormKeyDown(Self, HelpKey, []);
end;

//------------------------------------------------------------------------------

procedure TVCSModMove.SelectAll1Click(Sender: TObject);
var 
  I: Integer;
begin
  with elvModules do
    for I := 0 to (Items.Count - 1) do 
      Items[I].StateIndex := 1;
end;

//------------------------------------------------------------------------------

procedure TVCSModMove.UnselectAll1Click(Sender: TObject);
var 
  I: Integer;
begin
  with elvModules do
    for I := 0 to (Items.Count - 1) do 
      Items[I].StateIndex := 0;
end;

//------------------------------------------------------------------------------

procedure TVCSModMove.SelectHighlighted1Click(Sender: TObject);
var 
  I: Integer;
begin
  with elvModules do
    for I := 0 to (Items.Count - 1) do
      if Items[I].Selected then 
        Items[I].StateIndex := 1;
end;

//------------------------------------------------------------------------------

procedure TVCSModMove.rbWholeClick(Sender: TObject);
begin
  edNewPath.Enabled := rbWhole.Checked;
  if edNewPath.Enabled then 
    edNewPath.Color := clWindow
  else 
    edNewPath.Color := clBtnFace;
  spBtnBrowse.Enabled := rbWhole.Checked;
  Label1.Enabled := not rbWhole.Checked;
  Label2.Enabled := not rbWhole.Checked;
  edOldPart.Enabled := not rbWhole.Checked;
  if edOldPart.Enabled then 
    edOldPart.Color := clWindow
  else 
    edOldPart.Color := clBtnFace;
  edNewPart.Enabled := not rbWhole.Checked;
  if edNewPart.Enabled then 
    edNewPart.Color := clWindow
  else 
    edNewPart.Color := clBtnFace;
end;

procedure TVCSModMove.acHideHiddenModulesExecute(Sender: TObject);
begin
  FillListView;
end;

end.
