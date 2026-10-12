(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JEDIVCSPluginMsgConst.inc

The Initial Developer of the original FreeVCS-Code (FreeVCS) is: Thomas Hensle (freevcs@thensle.de)
Code move to JEDIVCS: Thomas Huber (Thomas_D_Huber@t-online.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Purpose:
 Message identifier definitions for JEDIVCS Plug-in DLLs.
 This file should be included in any JEDIVCS Plug-in project.
 Do not use numerical message identifiers, they may change in further versions.

 Warning! Do *not* change this file or your Plug-in won't work correctly!

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2003/01/31  THuber    - 1st Migrationstep from FreeVCS code to JEDI-VCS

-----------------------------------------------------------------------------*)

const
  idFVCSPluginMsgConst = 100;

  pimsgServerInfo = 1000;
  pimsgClientInfo = 1001;
  pimsgClientVersion = 1005;
  pimsgClientType = 1010;
  pimsgClientBaseFolder = 1020;
  pimsgPluginBaseFolder = 1021;
  pimsgClientBaseRegistryKey = 1030;
  pimsgClientAppHandle = 1031;
  pimsgConnectedServerAddress = 1040;
  pimsgConnectedServerPort = 1050;
  pimsgCurrentUser = 1060;
  pimsgFVCSProject = 1200;
  pimsgFVCSProjectModulesClear = 1210;
  pimsgFVCSProjectModulesAdd = 1220;
  pimsgFVCSProjectModulesRemove = 1230;
  pimsgFVCSProjectSelectedModule = 1240;

