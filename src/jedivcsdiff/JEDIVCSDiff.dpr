(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: FVCSDiff.dpr

The Initial Developer of the original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Code move to JEDI VCS: Thomas Huber (Thomas_D_Huber@t-online.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2003/09/07  THuber    - added missing ListView.pas
                      - fixed wrong compiler definitions (memcheck) S+,T+ => $W+
                      - removed (by mistake) automatically created reportform
2003/09/07  THuber    - added missing HistoryList.pas
2004/01/05  USchuster - added missing units
2004/01/18  USchuster - added missing units
                      - added version info resource
2004/04/12  THuber    - use chm help instead of hlp help
2004/04/24  USchuster - IFDEFed unit MemCheck again and removed unit HtmlHlp from
                        uses (location is controlled over compsearch.mki)
2004/10/31  USchuster - added JVCSGUIClientResources.pas
2005/05/10  USchuster - added several units
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RC2 was released ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
2005/07/04  THuber    - removed unnessary units (reduces exe size ~200KB)
2005/12/21  THuber    - FastMM now default memory manager
2006/06/09  CSchuette - added missing units to dpr file

-----------------------------------------------------------------------------*)

program JEDIVCSDiff;

{$I jedi.inc}
{$I compopt.inc}

{%File '..\credits.txt'}
	
uses
  FastMM4,
  Windows,
  Forms,
  DiffMain in 'DiffMain.pas' {fm_Main},
  ListView in '..\jedivcs\listview.pas',
  VCSBase in '..\jedivcs\vcsbase.pas',
  JVCSClientFunctions in '..\common\client\JVCSClientFunctions.pas',
  JVCSClientConsts in '..\common\client\JVCSClientConsts.pas',
  JVCSConnect in '..\common\client\JVCSConnect.pas',
  JVCSTypes in '..\common\client\JVCSTypes.pas',
  JVCSClientObj in '..\common\client\JVCSClientObj.pas',
  JVCSClientObjBase in '..\common\client\JVCSClientObjBase.pas',
  JVCSClientDispatcher in '..\common\client\JVCSClientDispatcher.pas',
  JVCSForms in '..\common\JVCSForms.pas',
  JVCSCrypt in '..\common\client\JVCSCrypt.pas',
  TZHandling in '..\common\client\TZHandling.pas',
  ConfigStorage in '..\jedivcs\configstorage.pas',
  JVCSGUIClientResources in '..\jedivcs\JVCSGUIClientResources.pas',
  DiffEditorProp in 'DiffEditorProp.pas' {Tfm_EditorProp},
  DiffCustomKW in 'DiffCustomKW.pas' {TCustomKW},
  DiffSimpleReport in 'DiffSimpleReport.pas' {DiffSimpleReport},
  DiffHLProp in 'DiffHLProp.pas' {fm_HighLightProp};

{$R *.res}
{$R cursors.res}  // Cursor Resource
{$R jvcsver.res}
{$R \Projects\Jedivcs\src\comp\soft-gems\thememanager\Resources\winxp.res}   // Include Themingresource for WindowsXP

begin
  CreateMutex(nil, False, 'JEDIVCSDiffMutex');
  Application.Initialize;
  Application.Title := 'JEDI VCS Diff/Merge';
  Application.CreateForm(Tfm_Main, fm_Main);
  Application.Run;
end.
