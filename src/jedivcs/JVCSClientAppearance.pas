(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSClientAppearance.pas

The Initial Developer of the original code (JEDI VCS v2026) is the JEDI VCS
port team (2026).

Purpose:
  Liga a aparencia (JVCSUIScale/JVCSUITheme + JVCSForms) no cliente GUI:
  - EXE (Jedivcs.exe): fonte/escala, menus, editores e tema global (VCL Style)
    seguindo o Windows ou fixo;
  - DLL da IDE (JvcsExternalDll.dll): fonte/escala, menus e editores; tema POR
    FORM (Form.StyleName), seguindo o tema da IDE lido do registro
    (HKCU\<chave base da IDE>\Theme\Theme); texto dos menus owner-draw
    corrigido para o hook de menus da IDE; forms com dono = janela principal
    da IDE (TAppBuilder).
  As preferencias ficam na ConfigStorage (sBaseRegistryKey + crbOptions).

Unit history:

2026/10/13  v2026      - nova unit (F4/F5)

-----------------------------------------------------------------------------*)

unit JVCSClientAppearance;

{$I jedi.inc}
{$I compopt.inc}

interface

{ chamar depois de InitAndOpenConfigStorage e antes de criar os forms.
  AIDEBaseKey: chave base da IDE (DLL; '' no EXE ou se desconhecida) }
procedure JVCSClientAppearanceInit(const AIDEBaseKey: string = '');
{ depois de gravar as opcoes de aparencia: reaplica em todas as janelas }
procedure JVCSClientAppearanceApplyAll;

implementation

uses
  Forms, JVCSForms, JVCSUIScale, JVCSUITheme, ConfigStorage, VCSBase;

procedure JVCSClientAppearanceInit(const AIDEBaseKey: string);
begin
  JVCSUIReadInteger := jvcsReadInteger;
  JVCSUIWriteInteger := jvcsWriteInteger;
  JVCSUIReadString := jvcsReadString;
  JVCSUIWriteString := jvcsWriteString;
  JVCSUIOptionsKey := sBaseRegistryKey + crbOptions;
  JVCSUIInitialize;
  {$IFDEF IDEDLL}
  // DLL dentro da IDE: nada de estilo global (ver JVCSUITheme/JVCSForms)
  JVCSUIFollowDelphiIDE(AIDEBaseKey);
  JVCSUIRefreshHostTheme;
  JVCSInstallHostMenuFix;
  JVCSFormsOwnerClass := 'TAppBuilder';
  {$ENDIF IDEDLL}
  JVCSUIThemeInitialize;
  {$IFNDEF IDEDLL}
  JVCSUIStartFollowingSystem;
  {$ENDIF ~IDEDLL}
  JVCSFormsApplyAppearance := True;
  JVCSInstallAppearanceHook;
end;

procedure JVCSClientAppearanceApplyAll;
begin
  JVCSUISetFontSettings(JVCSUILoadFontSettings, False);
  JVCSUIApplyTheme(JVCSUILoadThemeMode);
  JVCSApplyAppearanceToAllForms;
end;

end.
