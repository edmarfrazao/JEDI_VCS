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
Code move to JEDI VCS: Thomas Huber (Thomas_D_Huber@gmx.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2004/01/08  USchuster - new unit (JVCSBaseAboutDialog.pas) derived from the
                        GUI client About.pas as common base about dialog
2004/01/24  USchuster - the internet links will now be taken from VCSCommon.pas
^^^^^^^^^^^^^^^^^ 2.40 RC1(Client) & RC3(Server) was released ^^^^^^^^^^^^^^^^
2005/02/27  THuber    #2516: update credits and contributors in About dialog,
                             now use TJvRichEdit to allow direct call of
                             web links.
^^^^^^^^^^^^^^^^^ 2.40 RC2(Client) & RC4(Server) was released ^^^^^^^^^^^^^^^^
2005/06/04  USchuster - set various charsets to DEFAULT_CHARSET(necessary for LANGUAGE version)
^^^^^^^^^^^^^^^^^ 2.40 RC3(Client) & Stable(Server) was released ^^^^^^^^^^^^^
2006/01/22  USchuster - updated contributors and credits
2006/10/31  USchuster - updated contributors and credits
2007/01/14  USchuster - increased dialog width for new issue tracker address
2007/04/28  USchuster - updated contributors and credits
2008/03/02  USchuster - typo
2008/12/22  THuber    - now decent of TJVCSForm for VISTA  
^^^^^^^^^^^^^^^^^ 2.50 B2 was released ^^^^^^^^^^^^^
2009/12/27  THuber   #5067 support for  D B I S A M removed

-----------------------------------------------------------------------------*)

unit JVCSBaseAboutDialog;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, SysUtils, Classes, Forms, StdCtrls, ExtCtrls, Controls, Graphics,
  ComCtrls, JvExStdCtrls, JvRichEdit, JVCSForms;

type
  TJVCSBaseAboutDlg = class(TJVCSForm)
    btnClose: TButton;
    PageControl1: TPageControl;
    tsAbout: TTabSheet;
    tsVersionInformation: TTabSheet;
    tsCredits: TTabSheet;
    memVersionInformation: TMemo;
    Memo3: TJvRichEdit;
    pnWarning: TPanel;
    tsLicense: TTabSheet;
    Memo1: TMemo;
    Panel2: TPanel;
    Label2: TLabel;
    lblWebSite: TLabel;
    Label5: TLabel;
    lblnewsgroup: TLabel;
    Label4: TLabel;
    lblIssueTracker: TLabel;
    Label7: TLabel;
    ListBox1: TListBox;
    Label6: TLabel;
    Image1: TImage;
    lblProductVersion: TLabel;
    Label1: TLabel;
    tsSupport: TTabSheet;
    Memo2: TMemo;
    Panel1: TPanel;
    Label3: TLabel;
    lblOnlineFAQ: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure lblWebSiteClick(Sender: TObject);
    procedure Memo3URLClick(Sender: TObject; const URLText: string;
      Button: TMouseButton);
  private
    { Private declarations }
    FRetrievedVersionInformation: Boolean;
  protected
    function GetVersionInformation(AwithFileDate: Boolean): string; virtual;
  public
    { Public declarations }
    AcceptDlg: Boolean;
    Accepted: Boolean;
  end;

var
  JVCSBaseAboutDlg: TJVCSBaseAboutDlg;

implementation

uses
  ShellAPI, JVCSFunctions, JclFileUtils, VCSCommon;

{$R *.dfm}

procedure TJVCSBaseAboutDlg.FormCreate(Sender: TObject);
var
  JclFileVersionInfo: TJclFileVersionInfo;
begin
  {$IFDEF BETA}
  // Beta warning -> should be done in the descendant for now
  {$ENDIF BETA}
  AcceptDlg := False;
  Accepted := False;

  if FileExists(GetSelfFileName) and VersionResourceAvailable(GetSelfFileName) then
  begin
    JclFileVersionInfo := TJclFileVersionInfo.Create(GetSelfFileName);
    try
      lblProductVersion.Caption := 'V ' + JclFileVersionInfo.ProductVersion +
        ' - Buildtime ' + JclFileVersionInfo.Items.Values['BuildTimestamp'];
      pnWarning.Visible := (Pos('dev', lblProductVersion.Caption) > 0);
    finally
      JclFileVersionInfo.Free;
    end;
  end
  else
    lblProductVersion.Caption := 'Unable to determine version...';
  lblWebSite.Caption := GetJVCSInternetLink(ilHomepage);
  lblnewsgroup.Caption := GetJVCSInternetLink(ilNewsgroup);
  lblIssueTracker.Caption := GetJVCSInternetLink(ilIssueTracker);
  lblOnlineFAQ.Caption := GetJVCSInternetLink(ilOnlineFAQ);
  FRetrievedVersionInformation := False;
end;

//------------------------------------------------------------------------------

procedure TJVCSBaseAboutDlg.FormShow(Sender: TObject);
begin
  if AcceptDlg then
  begin
    btnClose.Caption := '&Accept';
    btnClose.Cancel := False;
    btnClose.Default := False;
    PageControl1.ActivePage := tsLicense;
  end
  else //first start should show license tab
    PageControl1.ActivePage := tsAbout;
end;

//------------------------------------------------------------------------------

procedure TJVCSBaseAboutDlg.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Accepted := False;
    Close;
  end;
{
  if Key = vk_F1 then
    // show Help -> should be done in the descendant for now
}
end;

//------------------------------------------------------------------------------

procedure TJVCSBaseAboutDlg.btnCloseClick(Sender: TObject);
begin
  Accepted := True;
  Close;
end;

function TJVCSBaseAboutDlg.GetVersionInformation(AwithFileDate: Boolean): string;
begin
  Result := 'JEDI VCS ' + lblProductVersion.Caption + #13;
  if AwithFileDate then
    Result := Result + 'Filedate: ' + DateTimeToStr(FileDateToDateTime(FileAge(GetSelfFileName)))
           + #13;
  Result := Result + #13;
end;

procedure TJVCSBaseAboutDlg.PageControl1Change(Sender: TObject);
begin
  if (PageControl1.ActivePage = tsVersionInformation) and
    (not FRetrievedVersionInformation) then
  begin
    memVersionInformation.lines.Text := GetVersionInformation(True);
    FRetrievedVersionInformation := True;
  end;
end;

procedure TJVCSBaseAboutDlg.lblWebSiteClick(Sender: TObject);
begin
  if Sender is TLabel then
    ShellExecute(Handle, 'open', PChar(TLabel(Sender).Caption), nil, nil, SW_SHOW);
end;

procedure TJVCSBaseAboutDlg.Memo3URLClick(Sender: TObject;
  const URLText: string; Button: TMouseButton);
begin
  if Button = mbLeft then
    ShellExecute(Handle, nil, PChar(URLText), nil, nil, SW_SHOW);
end;

end.
