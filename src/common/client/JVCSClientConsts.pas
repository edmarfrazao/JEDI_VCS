(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSClientConsts.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2003/12/13  USchuster - new unit (new home for some common client constants)
2003/12/27  THuber    - new const for CryptDLL (should be the only one)
2009/12/28  THuber    - moved some consts from VCSBase
-----------------------------------------------------------------------------*)
{$I JEDI.INC}

unit JVCSClientConsts;

interface

const
  // const for time conversion rounding issue (taken from original freevcs)
  cTimeConvErr = 0.000115741;

  // JVCS Encryption DLL
  cCryptDLLName = 'FVCSCrypt.dll';


  // consts for filters
  // changeable
  {
     ===========================================================================
     .bpg         : project group file (kind of make file)
     .mak         : standard makefile for make.exe

     .dpk         : component package project file (similar to .dpr)
     .dpr         : project file
     .dof         : option files (BCB/Delphi)

     .cpp         : code file (BCB)
     .h           : header file (BCB)
     .pas         : code file (Delphi)
     .dfm         : form file (BCB/Delphi)
     .ddp         : diagram portfolio file (BCB/Delphi)
     .cfg         : project configuration file
     .res         : compiled resource file (eg. out of .rc)
     
     .dcr         : resource source (icons, cursors, ...)
     .rc          : (version) resource source

     .cs          : code file (.net)
     .resx        : form file (.net)
     .resources   : resource file (.net)
     .rsp         : ?

     ===========================================================================
  }
  
  dfDelphiMod = '*.pas;*.cpp;*.dfm;*.dpr;*.bpr;*.dpk;*.bpk;*.res;*.dsk;*.dcr;*.inc;*.int;*.obj;*.asm;*.todo;*.bdsproj;*.cbproj;*.dproj;*.ddp;*.h';
  dfAddMod = '*.iwz;*.hpj;*.cnt;*.rtf;*.txt;*.doc;*.htm;*.html';
  dfCompMod = '*.pas;*.cpp;*.dpr;*.bpr;*.dof;*.dsk;*.txt;*.inc;*.htm;*.html;*.fvc;*.jvcs;*.hpj;*.ddp;*.bdsproj;*.cbproj;*.dproj;*.h';
  dfIDEEdit = '*.pas;*.cpp;*.h;*.dpr;*.bpr;*.dfm;*.inc;*.int;*.cs;*.bdsproj;*.cbproj;*.dproj;*.ddp;*.h';
  dfBMPEdit = '*.bmp;*.pcx;*.wmf';
  dfTXTEdit = '*.txt;*.fvc;*.jvcs;*.cmd;*.bat';
  dfRWSEdit = '*.rc;*.res;*.dll;*.drv;*.vbx;*.cpl;*.ico;*.rle;*.dlg;*.fnt;*.cur';
  dfKWExp = '*.pas;*.cpp;*.dpr;*.bpr;*.dpk;*.bpk;*.h;*.inc;*.htm;*.html';
  // Exclude list
  dfFolderExclude = '*.~*;*.dcu;*.dfm;*.exe;*.dll;*.map;*.drv;*.vbx';
  // fixed
  // following files are not set readonly after checkin
  dfNotReadOnly = '*.prl;*.pcr;*.dof;*.dpr;*.bpr;*.res;*.fvc;*.jvcs;*.dpk;*.bpk;*.dsk;*.cfg;*.todo;*.tlb;*_tlb.pas;*.bdsproj;*.cbproj;*.dproj';
  // following files do not belong to project
  dfNotAdd2Proj = '*.bkp;*.prl;*.pcr;*.tdo;*.pcf;*tlg';
  
implementation

end.
