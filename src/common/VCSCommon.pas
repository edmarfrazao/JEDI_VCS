(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTfY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: VCSCommon.pas

The Initial Developer of the Original FreeVCS-Code (FreeVCS) is:
  Thomas Hensle (freevcs@thensle.de)
Unit created by: Thomas Huber (Thomas_D_Huber@t-online.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2003/03/02  THuber     - unit created for sharing common consts/funcs
                         between jedivcs-client-/server
2003/03/08  THuber     - D B I S A M  upgrade to v3.x thus added server port
                         D B I S A M 3  with ServerVersion 300
2003/11/18  THuber     - removed D B I S A M 3  port as this will conflict with FreeVCS
                       - all server version set to 108 as indicator for first
                         jedi vcs version. This should give no conflicts when
                         using FreeVCS clients.
2003/12/26  THuber     - moved some version consts from SrvConst.pas here and
                         changed Src Version to 240.
2003/12/27  THuber     - removed Src Version const (no use)
2003/12/28  THuber     - updated cSrvInfo:
                         * all server versions now report 2.40
                         * Maintainerlist updated, deprecated db ports set to 'not named'
                         * I n f o r m i x  port deprecated
2004/01/03  THuber     - new const for upgrading db archive (database)
2004/01/24  USchuster  - new types/constants and functions for internet links
2004/06/27  THuber     - db archive now 2.41
2004/07/04  USchuster  - changes for mantis #1899 (expected server version can be a range now)
2004/07/06  THuber     - IB5 min version changed to 102 (same as IB6)
2004/07/10  USchuster  - changed IB5 min version to 106
2004/10/19  THuber     - added compression types (TJVCSCompressionType) for later
                         extension (until 2.40 only zip supported)
2005/06/12  THuber     - version strings in cSrvInfo corrected
2005/10/25  USchuster  - changed SrvVers to 241
2006/06/03  USchuster  - reintegrated changes for Firebird UIB port and set SrvVers to 250
2006/12/18  USchuster  - homepages.borland.com -> homepages.codegear.com
2007/07/15  USchuster  - db archive now 2.42 (Mantis #3573 and #3978)
2009/03/20  USchuster  - updated Issue Tracker URL

--- 2.50 Beta 2 was released...
2009/12/23  THuber    #5063 support for  I n f o r m i x  port removed
                      #5064 support for  I n t e r b a s e 6  port removed
                      #5066 support for  F l a s h F i l e r  port removed
                      #5065 support for  F i b p l u s  port removed
2009/12/27  THuber    #5067 support for  D B I S A M removed
                      #5077 support for  Oracle < 9x removed, also B D E  version
2010/01/30  THuber    Re-Added deprecated DBMS to support right user information 
-----------------------------------------------------------------------------*)

unit VCSCommon;

{$I jedi.inc}

interface

uses
  SysUtils, JclStrings;


//      Introduced server port information over following structures
//      added new server ports: Firebird, MYSQL
//--PL  added new server port: generic connection ADO
//      changed versionno's according to server (SrvConst)
type
  TSrvIdentifier = (svIdUnknown,
                    svIdFF, svIdDBISAM, svIdUIB, svIdIB5, svIdIB6, svIdFIB,
                    svIdOraOci, svIdOraBDE, svIdMSSQL, svIdInfx, svIdMySQL,
                    svIdDBISAM3,
                    svIdADO
                   );

  TSrvDescRec = record
    SrvId         : TSrvIdentifier;
    SrvPort       : string[50];     // returned from server on connect
    SrvDesc       : string[50];     // server description for about
    SrvMinVers    : Integer;        // minimal server version
    SrvVers       : Integer;        // server version
    SrvDeprecated : Boolean;        // true if stated as deprecated
    SrvMaintainer : string[80];     // maintainer of this server port
  end;

  TJVCSInternetLinkKind = (ilHomepage, ilSourceForgeProject, ilNewsgroup, ilOnlineFAQ,
    ilIssueTracker);

  TJVCSInternetLink = record
    Description: string;
    Link: string;
  end;

  TJVCSCompressionType = (jvcsZip, jvcsGZip, jvcsTar, jvcsCab);

const
  ExpectedSrvCryptVersion = 101;// expected ServerCrypt.dll version (100 = 1.00)
  ExpectedCliVersion = 220;     // expected JVCS Client version (100 = 1.00)

  BaseArchiveVersion = 110;       // first archive version checked for upgrading
                                  // this was FreeVCS / JVCS (till beta2)
{$IFDEF BRANCHOBJECTS}
  ExpectedArchiveVersion = 250;   // const for checking db version (dbversion table)
{$ELSE BRANCHOBJECTS}
  ExpectedArchiveVersion = 242;   // const for checking db version (dbversion table)
                                  // introduced with JVCS 2.40
{$ENDIF BRANCHOBJECTS}

const
  // SrvVers is from verconst.ExpectedXXXServer
  cSrvInfo: array [0..10] of TSrvDescRec =
  (
   (SrvId: svIdFF;      SrvPort: 'FLASHFILER';      SrvDesc: 'Flashfiler 2.13: ';      SrvMinVers: 100; SrvVers: 240; SrvDeprecated: True;  SrvMaintainer: 'Carsten Schütte'),
   (SrvId: svIdDBISAM;  SrvPort: 'DBISAM';          SrvDesc: 'DBISAM 3.x: ';           SrvMinVers: 107; SrvVers: 240; SrvDeprecated: True;  SrvMaintainer: 'Thomas Huber'),
   (SrvId: svIdUIB;     SrvPort: 'Firebird';        SrvDesc: 'Firebird: ';             SrvMinVers: 250; SrvVers: 250; SrvDeprecated: False; SrvMaintainer: 'Pierre Y.'),
   (SrvId: svIdIB6;     SrvPort: 'Interbase6';      SrvDesc: 'Interbase6: ';           SrvMinVers: 102; SrvVers: 240; SrvDeprecated: True;  SrvMaintainer: 'Thomas Huber'),
   (SrvId: svIdIB5;     SrvPort: 'Interbase';       SrvDesc: 'Interbase5: ';           SrvMinVers: 106; SrvVers: 240; SrvDeprecated: True;  SrvMaintainer: 'not named'),
   (SrvId: svIdFIB;     SrvPort: 'Firebird 1.x';    SrvDesc: 'Firebird 1.x: ';         SrvMinVers: 240; SrvVers: 240; SrvDeprecated: True;  SrvMaintainer: 'Thomas Huber'),
   (SrvId: svIdOraOci;  SrvPort: 'Oracle8 Native';  SrvDesc: 'Oracle 8/9/10 native: '; SrvMinVers: 100; SrvVers: 250; SrvDeprecated: False; SrvMaintainer: 'Uwe Schuster'),
   (SrvId: svIdOraBDE;  SrvPort: 'Oracle';          SrvDesc: 'Oracle 7/8.x BDE: ';     SrvMinVers: 106; SrvVers: 240; SrvDeprecated: True;  SrvMaintainer: 'not named'),
   (SrvId: svIdMSSQL;   SrvPort: 'MSSQL';           SrvDesc: 'MSSQL 7/8/200x: ';       SrvMinVers: 107; SrvVers: 250; SrvDeprecated: False; SrvMaintainer: 'Marco Gosselink'),
   (SrvId: svIdMySQL;   SrvPort: 'MYSQL';           SrvDesc: 'MySQL 3.23/4.x/5.x: ';   SrvMinVers: 100; SrvVers: 250; SrvDeprecated: False; SrvMaintainer: 'Ludo Brands'),
   (SrvId: svIdADO;     SrvPort: 'ADO Connection';  SrvDesc: 'ADO connection: ';       SrvMinVers: 240; SrvVers: 250; SrvDeprecated: False; SrvMaintainer: 'Pascal Lauret')
  );

  function GetSrvVersionString(const SrvId: TSrvIdentifier; const bOnlyVersion: Boolean = False): string;
  function GetSrvRequiredVersionString(const SrvId: TSrvIdentifier; const bOnlyVersion: Boolean = False): string;
  function GetSrvIsDeprecated (const SrvId: TSrvIdentifier): Boolean;
  function GetSrvMinimumVersion(const SrvId: TSrvIdentifier): Integer;
  function GetSrvVersion      (const SrvId: TSrvIdentifier): Integer;
  function GetSrvIdFromPort   (const SrvPort: string): TSrvIdentifier;
  function GetSrvPortFromId   (const SrvId: TSrvIdentifier): string;

const
  cInternetLinks: array [ilHomepage..ilIssueTracker] of TJVCSInternetLink =
  (
   (Description: 'JEDI VCS on the web';   Link: 'http://jedivcs.sourceforge.net/'),
   (Description: 'JEDI VCS @SourceForge'; Link: 'http://sourceforge.net/projects/jedivcs/'),
   (Description: 'JEDI VCS newsgroup';    Link: 'news://forums.talkto.net/jedi.vcs'),
   (Description: 'JEDI VCS Online FAQ';   Link: 'http://jedivcs.sourceforge.net/jvcsfaq/'),
   (Description: 'JEDI VCS Issue Tracker';Link: 'http://issuetracker.delphi-jedi.org')
  );

  function GetJVCSInternetLink(const ALinkKind: TJVCSInternetLinkKind): string;
  function GetJVCSInternetLinkDescription(const ALinkKind: TJVCSInternetLinkKind): string;

implementation

//------------------------------------------------------------------------------

function GetSrvVersionString(const SrvId: TSrvIdentifier; const bOnlyVersion: Boolean = False): string;
var
  ii: Integer;
begin
  Result := '';
  for ii := Low(cSrvInfo) to High(cSrvInfo) do
  begin
    if cSrvInfo[ii].SrvId = SrvId then
    begin
      try
        if bOnlyVersion then
        begin
          Result := Format( '%d.%2.2d'
                          , [cSrvInfo[ii].SrvVers div 100, cSrvInfo[ii].SrvVers mod 100]
                          );
        end
        else
        begin
          Result := Format( cSrvInfo[ii].SrvDesc + '%d.%2.2d'
                          , [cSrvInfo[ii].SrvVers div 100, cSrvInfo[ii].SrvVers mod 100]
                          );
        end;
      except
      end;
      Break;
    end;
  end;
end;

//------------------------------------------------------------------------------

function GetSrvRequiredVersionString(const SrvId: TSrvIdentifier; const bOnlyVersion: Boolean = False): string;
var
  ii: Integer;
  MinVersion, LatestVersion: Integer;
begin
  Result := '';
  for ii := Low(cSrvInfo) to High(cSrvInfo) do
  begin
    if cSrvInfo[ii].SrvId = SrvId then
    begin
      try
        MinVersion := cSrvInfo[ii].SrvMinVers;
        LatestVersion := cSrvInfo[ii].SrvVers;
        if MinVersion = LatestVersion then
          Result := Format(cSrvInfo[ii].SrvDesc + '%d.%2.2d',
            [LatestVersion div 100, LatestVersion mod 100])
        else
          Result := Format(cSrvInfo[ii].SrvDesc + '%d.%2.2d - %d.%2.2d',
            [MinVersion div 100, MinVersion mod 100, LatestVersion div 100, LatestVersion mod 100])
      except
      end;
      Break;
    end;
  end;
end;

//------------------------------------------------------------------------------

function GetSrvIsDeprecated(const SrvId: TSrvIdentifier): Boolean;
var
  ii: Integer;
begin
  Result := False;
  for ii := Low(cSrvInfo) to High(cSrvInfo) do
  begin
    if cSrvInfo[ii].SrvId = SrvId then
    begin
      try
        Result := cSrvInfo[ii].SrvDeprecated;
      except
      end;
      Break;
    end;
  end;
end;

//------------------------------------------------------------------------------

function GetSrvMinimumVersion(const SrvId: TSrvIdentifier): Integer;
var
  ii: Integer;
begin
  Result := -1;
  for ii := Low(cSrvInfo) to High(cSrvInfo) do
  begin
    if cSrvInfo[ii].SrvId = SrvId then
    begin
      Result := cSrvInfo[ii].SrvMinVers;
      Break;
    end;
  end;
end;

//------------------------------------------------------------------------------

function GetSrvVersion(const SrvId: TSrvIdentifier): Integer;
var
  ii: Integer;
begin
  Result := -1;
  for ii := Low(cSrvInfo) to High(cSrvInfo) do
  begin
    if cSrvInfo[ii].SrvId = SrvId then
    begin
      Result := cSrvInfo[ii].SrvVers;
      Break;
    end;
  end;
end;

//------------------------------------------------------------------------------

function GetSrvIdFromPort(const SrvPort: string): TSrvIdentifier;
var
  ii: Integer;
begin
  Result := svIdUnknown;
  for ii := Low(cSrvInfo) to High(cSrvInfo) do
  begin
    if StrSame(cSrvInfo[ii].SrvPort, SrvPort) then
    begin
      Result := cSrvInfo[ii].SrvId;
      Break;
    end;
  end;
end;

//------------------------------------------------------------------------------

function GetSrvPortFromId(const SrvId: TSrvIdentifier): string;
var
  ii: Integer;
begin
  Result := '';
  for ii := Low(cSrvInfo) to High(cSrvInfo) do
  begin
    if cSrvInfo[ii].SrvId = SrvId then
    begin
      try
        Result := cSrvInfo[ii].SrvPort;
      except
      end;
      Break;
    end;
  end;
end;

//------------------------------------------------------------------------------

function GetJVCSInternetLink(const ALinkKind: TJVCSInternetLinkKind): string;
begin
  Result := cInternetLinks[ALinkKind].Link;
end;

//------------------------------------------------------------------------------

function GetJVCSInternetLinkDescription(const ALinkKind: TJVCSInternetLinkKind): string;
begin
  Result := cInternetLinks[ALinkKind].Description;
end;

end.

