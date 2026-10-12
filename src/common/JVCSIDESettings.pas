(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSIDESettings.pas

The Initial Developer of the original code (JEDI VCS) is:
  Thomas Huber (thomas_d_huber att gmx dot de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
- may have to include version checking
- use JclBorlandTools?
-----------------------------------------------------------------------------

Unit history:

2005/02/29  THuber    - new unit
2005/02/31  THuber    - property IDEAppFileDir added
2005/04/14  CSchuette - added missing target for BDS2
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC2 was released ^^^^^^^^^^^^^^^^^^^^^^^^^^^
2005/05/21  USchuster - added IDERootDir
                      - finished changes for Delphi 8
2008/09/16  USchuster - changes for BDS4 till BDS6 

-----------------------------------------------------------------------------*)

unit JVCSIDESettings;

{$I jedi.inc}
{$I compopt.inc}

interface

type
  TJVCSIDEProduct = ( IDEUnknown
                    , IDEDelphiUnknown
                    , IDEDelphi3
                    , IDEDelphi4
                    , IDEDelphi5
                    , IDEDelphi6
                    , IDEDelphi7
                    , IDECBuilderUnknown
                    , IDECBuilder5
                    , IDECBuilder6
                    , IDEDeveloperStudioUnknown
                    , IDEDeveloperStudio1 //AKA C#Builder
                    , IDEDeveloperStudio2 //AKA Delphi 8.NET
                    , IDEDeveloperStudio3 //AKA Delphi2005
                    , IDEDeveloperStudio4 //AKA Developer Studio 2006
                    , IDEDeveloperStudio5 //AKA RAD Studio 2007
                    , IDEDeveloperStudio6 //AKA Delphi/C++Builder 2009                    
                    );

  // ---------------------------------------------------------------------------
  // To have this class independend of JVCS version, there is no check
  // if IDE is supported. This has to implemented in the IDEInterface class
  // as it is likely that this will change in future JVCS versions
  TJVCSIDESettings = class(TObject)
  private
    fProduct: TJVCSIDEProduct;
    fsVersion: string;
    fsIDEAppFile: string;
    fsIDEAppFileDir: string;
    FIDERootDir: string;
    procedure SetIDEAppFile(const sValue: string);
  protected
    procedure Update;
  public
    constructor Create(const sIDEAppFile: string);
    function IsIDEDelphi: Boolean;         //Win32 based Delphi products, DOES NOT RETURN DELPHI8 AND DELPHI2005!!!
    function IsIDEBCB: Boolean;            //C++Builder5,6
    function IsIDEBDS: Boolean;            //C#Builder, Delphi8, Delphi2005
    function IsIDEUnknown: Boolean;
    property Product: TJVCSIDEProduct read fProduct;
    property Version: string read fsVersion;
    property IDEAppFile: string read fsIDEAppFile write SetIDEAppFile;
    property IDEAppFileDir: string read fsIDEAppFileDir;
    property IDERootDir: string read FIDERootDir;
  end;

implementation

uses
  {$ifdef WINDOWS}
  JclRegistry
  {$else}
  {$endif}
  , JclFileUtils
  , Classes
  , Windows
  , SysUtils
  ;

const
  REG_BORLAND = 'Software\Borland';
  REG_CODEGEAR = 'Software\CodeGear';  
  REG_BOR_DELPHI = REG_BORLAND + '\Delphi\';
  REG_BOR_BCB    = REG_BORLAND + '\C++Builder\';
  REG_BOR_BDS    = REG_BORLAND + '\BDS\';
  REG_BOR_BDS6UP = REG_CODEGEAR + '\BDS\';

  IDE_DELPHI_APPFILE = 'delphi32.exe';    //Delphi3,4,5,6,7
  IDE_BCB_APPFILE = 'bcb.exe';            //C++ Builder5,6
  IDE_BDS_APPFILE = 'bds.exe';            //C#Builder, Delphi8, Delphi2005

constructor TJVCSIDESettings.Create(const sIDEAppFile: string);
begin
  IDEAppFile := sIDEAppFile;
end;

procedure TJVCSIDESettings.SetIDEAppFile(const sValue: string);
begin
  fsIDEAppFile := sValue;
  Update;
end;

procedure TJVCSIDESettings.Update;
var
  sIDEFile: string;
  sRegProduct: string;

  function FindIDEVersion(const RootKey: DelphiHKEY; const Key, DefAppFile: string;
    var sVersion, ARootDir: string): Boolean;
  var
    slKeys: TStringList;
    sRegValue: string;
    ii: Integer;
  begin
    Result := False;
    sVersion := '';
    ARootDir := '';
    // Detect Version Delphi, BCB, BDS
    slKeys := TStringList.Create;
    try
      if RegKeyExists(RootKey, Key) and RegGetKeyNames(RootKey, Key, slKeys) then
      begin
        for ii := 0 to slKeys.Count - 1 do
        begin
          // check RootDir value
          try
            sRegValue := RegReadString(RootKey, Key+slKeys[ii], 'RootDir');
            if  sRegValue <> '' then
            begin
              // check path against RootDir
              if AnsiSameText(PathAddSeparator(sRegValue) + 'bin\' + DefAppFile, fsIDEAppFile) then
              begin
                sVersion := slKeys[ii];
                ARootDir := PathAddSeparator(sRegValue);
                Result := True;
                Break;
              end;
            end;
          except
          end;
        end;
      end;
    finally
      slKeys.Free;
    end;
  end;

begin
  fProduct := IDEUnknown;
  fsVersion := '';
  fsIDEAppFileDir := '';
  FIDERootDir := '';
  if FileExists(fsIDEAppFile) then
  begin
    fsIDEAppFileDir := PathAddSeparator(ExtractFileDir(fsIDEAppFile));
    // first search for valid appfile, start with delphi
    if Pos(IDE_DELPHI_APPFILE, fsIDEAppFile) > 0 then
    begin
      fProduct := IDEDelphiUnknown;
      sRegProduct := REG_BOR_DELPHI;
      sIDEFile := IDE_DELPHI_APPFILE;
    end
    else
    if Pos(IDE_BCB_APPFILE, fsIDEAppFile) > 0 then
    begin
      fProduct := IDECBuilderUnknown;
      sRegProduct := REG_BOR_BCB;
      sIDEFile := IDE_BCB_APPFILE;
    end
    else
    if Pos(IDE_BDS_APPFILE, fsIDEAppFile) > 0 then
    begin
      fProduct := IDEDeveloperStudioUnknown;
      sRegProduct := REG_BOR_BDS;
      sIDEFile := IDE_BDS_APPFILE;
    end;

    // Detect Version in HKLM
    if not IsIDEUnknown then
    begin
      fProduct := IDEUnknown;
      if FindIDEVersion(HKEY_LOCAL_MACHINE, sRegProduct, sIDEFile, fsVersion, FIDERootDir) then
      begin
        if (sRegProduct = REG_BOR_DELPHI) then
        begin
          if fsVersion = '3.0' then
          begin
            fProduct := IDEDelphi3;
          end
          else
          if fsVersion = '4.0' then
          begin
            fProduct := IDEDelphi4;
          end
          else
          if fsVersion = '5.0' then
          begin
            fProduct := IDEDelphi5;
          end
          else
          if fsVersion = '6.0' then
          begin
            fProduct := IDEDelphi6;
          end
          else
          if fsVersion = '7.0' then
          begin
            fProduct := IDEDelphi7;
          end;
        end
        else
        if (sRegProduct = REG_BOR_BCB) then
        begin
          if fsVersion = '5.0' then
          begin
            fProduct := IDECBuilder5;
          end
          else
          if fsVersion = '6.0' then
          begin
            fProduct := IDECBuilder6;
          end;
        end
        else
        if (sRegProduct = REG_BOR_BDS) then
        begin
          if fsVersion = '1.0' then
          begin
            fProduct := IDEDeveloperStudio1;
          end
          else
          if fsVersion = '2.0' then
          begin
            fProduct := IDEDeveloperStudio2;
          end
          else
          if fsVersion = '3.0' then
          begin
            fProduct := IDEDeveloperStudio3;
          end
          else
          if fsVersion = '4.0' then
          begin
            fProduct := IDEDeveloperStudio4;
          end
          else
          if fsVersion = '5.0' then
          begin
            fProduct := IDEDeveloperStudio5;
          end;
        end;
      end;
      if FindIDEVersion(HKEY_LOCAL_MACHINE, REG_BOR_BDS6UP, sIDEFile, fsVersion, FIDERootDir) then
      begin
        if fsVersion = '6.0' then
          fProduct := IDEDeveloperStudio6;
      end;
    end;
  end;
end;

function TJVCSIDESettings.IsIDEDelphi: Boolean;
begin
  Result := (fProduct in  [ IDEDelphiUnknown
                          , IDEDelphi3
                          , IDEDelphi4
                          , IDEDelphi5
                          , IDEDelphi6
                          , IDEDelphi7
                          ]);
end;

function TJVCSIDESettings.IsIDEBCB: Boolean;
begin
  Result := (fProduct in  [ IDECBuilderUnknown
                          , IDECBuilder5
                          , IDECBuilder6
                          ]);
end;

function TJVCSIDESettings.IsIDEBDS: Boolean;
begin
  Result := (fProduct in  [ IDEDeveloperStudioUnknown
                          , IDEDeveloperStudio1
                          , IDEDeveloperStudio2                          
                          , IDEDeveloperStudio3
                          , IDEDeveloperStudio4
                          , IDEDeveloperStudio5
                          , IDEDeveloperStudio6
                          ]);
end;

function TJVCSIDESettings.IsIDEUnknown: Boolean;
begin
  Result := (fProduct = IDEUnknown);
end;

end.
