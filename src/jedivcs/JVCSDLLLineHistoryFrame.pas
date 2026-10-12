(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSDLLLineHistoryFrame.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2008/06/28  USchuster - new unit

-----------------------------------------------------------------------------*)

unit JVCSDLLLineHistoryFrame;

{$I jedi.inc}
{$I compopt.inc}

interface

uses
  Windows, SysUtils, Controls, ExtCtrls, Forms;

procedure AddLineHistoryControl(AApplicationHandle, AParentHandle: THandle); stdcall;
procedure SetLineHistoryControlParentHandle(AHandle: THandle); stdcall;
procedure SetLineHistoryControlModuleAndExtension(AModule, AExtension: PChar); stdcall;

implementation

uses
  DBModule, JVCSLineHistoryDefaultProvider, JVCSLineHistoryFrame;

var
  TempForm: TForm = nil;
  Panel: TPanel = nil;
  FLineHistoryProvider: TJVCSConnectionLineHistoryProvider = nil;
  LineHistoryFrame: TJVCSLineHistoryFrm = nil;
  
procedure AddLineHistoryControl(AApplicationHandle, AParentHandle: THandle); stdcall;
var
  ParentRect: TRect;
begin
  Application.Handle := AApplicationHandle;
  TempForm := TForm.Create(nil);
  Panel := TPanel.Create(TempForm);
  Panel.Parent := TempForm;
  Panel.Align := alClient;
  Panel.BevelOuter := bvNone;

  FLineHistoryProvider := TJVCSConnectionLineHistoryProvider.Create(GetJvcsConnection);

  LineHistoryFrame := TJVCSLineHistoryFrm.Create(Panel);
  LineHistoryFrame.Provider := FLineHistoryProvider;
  LineHistoryFrame.Enable;
  LineHistoryFrame.Parent := Panel;
  LineHistoryFrame.Align := alClient;
  //LineHistoryFrame.ModuleName := AModuleName;
  //LineHistoryFrame.SelectedExtension := ModuleExtension;
  //LineHistoryFrame.OnSettingsChanged := LineHistorySettingsChanged;
  //LineHistoryFrame.Settings := FLineHistorySettings;

  {
  Panel.Parent := nil;
  Panel.ParentWindow := AHandle;
  Windows.GetClientRect(AHandle, ParentRect);
  Panel.SetBounds(0, 0, ParentRect.Right, ParentRect.Bottom);
  }
  TempForm.BorderStyle := bsNone;
  TempForm.Parent := nil;
  TempForm.ParentWindow := AParentHandle;
  TempForm.Show;
  Windows.GetClientRect(AParentHandle, ParentRect);
  TempForm.SetBounds(0, 0, ParentRect.Right, ParentRect.Bottom);
end;

procedure SetLineHistoryControlParentHandle(AHandle: THandle); stdcall;
var
  ParentRect: TRect;
begin
  {
  Panel.ParentWindow := AHandle;
  //Form1.Panel1.Update;
  Application.ProcessMessages;
  GetClientRect(AHandle, ParentRect);
  Panel.SetBounds(0, 0, ParentRect.Right, ParentRect.Bottom);
  }
  TempForm.ParentWindow := AHandle;
  //Form1.Panel1.Update;
  Application.ProcessMessages;
  GetClientRect(AHandle, ParentRect);
  TempForm.SetBounds(0, 0, ParentRect.Right, ParentRect.Bottom);
end;

procedure SetLineHistoryControlModuleAndExtension(AModule, AExtension: PChar); stdcall;
begin
  if Assigned(LineHistoryFrame) then
  begin
    LineHistoryFrame.ModuleName := StrPas(AModule);
    LineHistoryFrame.SelectedExtension := StrPas(AExtension);
  end;
end;

end.