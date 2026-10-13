(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JvcsExpertBDS.dpr (JEDI VCS v2026)

-----------------------------------------------------------------------------

JvcsExpertBDS - expert de IDE (wizard DLL) do JEDI VCS para Delphi 11/12/13

  Substitui JvcsExpertBDS21.dll (Delphi 10.4) e carrega a JvcsExternalDll.dll
  ORIGINAL do JEDI VCS 2.5.0.1030 (Delphi 2007, ANSI) da pasta do expert.

  Saida: JvcsExpertBDS<nn>.dll, nn = numero BDS (22 = Delphi 11, 23 = Delphi 12,
  37 = Delphi 13) via $LIBSUFFIX abaixo. Somente Win32 (IDE de 32 bits): a
  JvcsExternalDll.dll e 32 bits.

  Compilar: tools\compilar-expert.bat (dcc32 com runtime packages
  rtl;vcl;designide). Registrar: veja LEIAME.md.

  Historico:
  2026/10/12  v2026 - novo projeto
-----------------------------------------------------------------------------*)

library JvcsExpertBDS;

{$IFNDEF WIN32}
  {$MESSAGE FATAL 'JvcsExpertBDS: somente Win32 (IDE 32 bits) - a JvcsExternalDll.dll e 32 bits'}
{$ENDIF}

// Nome da DLL = JvcsExpertBDS + numero BDS do Delphi que compila
{$IF CompilerVersion >= 38.0}
  {$MESSAGE WARN 'JvcsExpertBDS: versao do Delphi nao mapeada - acrescente o numero BDS em $LIBSUFFIX'}
{$ELSEIF CompilerVersion >= 37.0}
  {$LIBSUFFIX '37'}
{$ELSEIF CompilerVersion >= 36.0}
  {$LIBSUFFIX '23'}
{$ELSEIF CompilerVersion >= 35.0}
  {$LIBSUFFIX '22'}
{$ELSE}
  {$MESSAGE FATAL 'JvcsExpertBDS requer Delphi 11 Alexandria (BDS 22) ou superior'}
{$ENDIF}

// VERSIONINFO (o dcc32 nao compila .rc: tools\compilar-expert.bat gera o .res)
{$R 'JvcsExpertBDS_ver.res' 'JvcsExpertBDS_ver.rc'}

uses
  ToolsAPI,
  JVCSExpertABI in 'JVCSExpertABI.pas',
  JVCSExpertUtils in 'JVCSExpertUtils.pas',
  JVCSAppVersion in '..\common\JVCSAppVersion.pas',
  JVCSExpertCallbacks in 'JVCSExpertCallbacks.pas',
  JVCSExpertDllBridge in 'JVCSExpertDllBridge.pas',
  JVCSExpertNotifiers in 'JVCSExpertNotifiers.pas',
  JVCSExpertHistory in 'JVCSExpertHistory.pas',
  JVCSExpertProjMenu in 'JVCSExpertProjMenu.pas',
  JVCSExpertWizard in 'JVCSExpertWizard.pas';

exports
  InitWizard name WizardEntryPoint;

begin
end.
