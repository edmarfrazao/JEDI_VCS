(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: ConfigStorage.pas

The Initial Developer of the original code (JEDIVCS) is:
  Thomas Hensle (freevcs@thensle.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2003/03/01  THensle    - New unit
2003/03/02  THensle    - Support for Registry/ IniFile by compiler Def
2003/08/02  THuber     - introduced two new procedures for standard formstorage
                         handling: jvcsLoadFormPosSize, jvcsSaveFormPosSize
                         => jvcsRead/WriteWindowPos/Size should not be used further!
2007/08/13  USchuster  - Trace -> TraceMsg
                       - minor stylecleaning

-----------------------------------------------------------------------------*)

unit ConfigStorage;

{$I jedi.inc}
{$I compopt.inc}

{$DEFINE USE_INI}
{.$DEFINE USE_MEMINI} // Do not use! not working for now!
                      // JVSIniFile dont get initialised?

interface

uses
  Windows, Forms;

var
  UseRegistryStorage: Boolean = True; // decide whether to use reg/file for
                                      // configuration storage

{ *****************************************************************************
  ConfigStorage
 ***************************************************************************** }

{  because this should be a storage independent wrapper, other Reg keys
   than HKEY_CURRENT_USER are not supported. If you need to write to
   HKCR, HKLM, HKCC or HKU you must do this in the related source file directly,
   as there is no way to mimic this on another storage system, i.e Ini files  }


//THu 02.08.2003 preferred procedure for formstorage of VCS
//Call LoadForm in FormShow
//Call SaveForm in FormClose
procedure jvcsLoadFormPosSize(AForm: TForm);
procedure jvcsSaveFormPosSize(AForm: TForm);
//THu 02.08.2003

function jvcsOpenStorageObject: Boolean;
function jvcsUpdateStorageObject: Boolean;
function jvcsCloseStorageObject: Boolean;

function jvcsKeyExists(const Key: string): Boolean;
function jvcsValueExists(const Key, Name: string): Boolean;

function jvcsDeleteKey(const Key: string): Boolean;
function jvcsDeleteValue(const Key, Name: string): Boolean;

function jvcsWriteBool(const Key, Name: string; Value: Boolean): Boolean;
function jvcsReadBool(const Key, Name: string; Def: Boolean): Boolean;
function jvcsWriteInteger(const Key, Name: string; Value: Integer): Boolean;
function jvcsReadInteger(const Key, Name: string; Def: Integer): Integer;
function jvcsWriteFloat(const Key, Name: string; Value: Double): Boolean;
function jvcsReadFloat(const Key, Name: string; Def: Double): Double;
function jvcsWriteString(const Key, Name, Value: string): Boolean;
function jvcsReadString(const Key, Name: string; Def: string): string;

function jvcsWriteWindowPos(const Key, Name: string;
  const Top, Left: Integer): Boolean;
function jvcsReadWindowPos(const Key, Name: string;
  var Top, Left: Integer): Boolean;
function jvcsWriteWindowSize(const Key, Name: string;
  const Height, Width: Integer): Boolean;
function jvcsReadWindowSize(const Key, Name: string;
  var Height, Width: Integer): Boolean;
function jvcsWriteWindowPosAndSize(const Key, Name: string;
  const Top, Left, Height, Width: Integer): Boolean;
function jvcsReadWindowPosAndSize(const Key, Name: string;
  var Top, Left, Height, Width: Integer): Boolean;


implementation

uses
  {$IFDEF DEBUG}
  JclDebug,
  {$ENDIF DEBUG}
  Registry, VCSBase, IniFiles;

  type
    TJVCSRegistry = class(TRegistry)
    end;

  {$IFDEF USE_INI}
  type
    TJVCSIniFile = class(TIniFile)
    end;
  {$ENDIF USE_INI}

{$IFDEF USE_MEMINI}
  type
    TJVCSIniFile = class(TMemIniFile) // if your compiler stops here, you have
    end;                              // both conditionals (USE_INI/USE_MEMINI)
                                      // defined!
var
  JVCSIniFile: TJVCSIniFile = nil;}
{$ENDIF USE_MEMINI}

function jvcsGetIniFileName: string;
begin
  //avoid storing the file in /sys dir
  {$IFDEF DEBUG}
  Assert((sDLLDirectory <> ''), '"sDLLDirectory" is blank');
  {$ENDIF DEBUG}
  Result := sDLLDirectory + 'JVCS.ini';
end;

//------------------------------------------------------------------------------

procedure jvcsSaveFormPosSize(AForm: TForm);
var
  sKey, sName: string;
begin
  if Assigned(AForm) then
  begin
    sKey := sBaseRegistryKey + crbWindows;
    sName := AForm.Name;
    jvcsWriteWindowPosAndSize(sKey, sName, AForm.Top, AForm.Left, AForm.Width, AForm.Height);
  end;
end;

//------------------------------------------------------------------------------

procedure jvcsLoadFormPosSize(AForm: TForm);
var
  nTop, nLeft, nWidth, nHeight: Integer;
  sKey, sName: string;
begin
  if Assigned(AForm) then
  begin
    sKey := sBaseRegistryKey + crbWindows;
    sName := AForm.Name;
    if jvcsReadWindowPosAndSize(sKey, sName, nTop, nLeft, nWidth, nHeight) then
    begin
      AForm.Top := nTop;
      AForm.Left := nLeft;
      AForm.Width := nWidth;
      AForm.Height := nHeight;
    end;
  end;
end;


//------------------------------------------------------------------------------

function jvcsOpenStorageObject: Boolean;
begin
  if UseRegistryStorage then
    Result := True
  else
  begin
    {$IFDEF USE_MEMINI}
    Result := False;
    try
      if not Assigned(JVCSIniFile) then
        JVCSIniFile.Create(jvcsGetIniFileName);
      JVCSIniFile.CaseSensitive := False;
      Result := True;
    except
    {$IFDEF DEBUG}
    JclDebug.TraceMsg(PChar('E: jvcsOpenStorageObject' + #0));
    {$ENDIF DEBUG}
    end;
    {$ELSE}
    Result := True;
    {$ENDIF USE_MEMINI}
  end;
end;

//------------------------------------------------------------------------------

function jvcsUpdateStorageObject: Boolean;
begin
  if UseRegistryStorage then
    Result := True
  else
  begin
    {$IFDEF USE_MEMINI}
    Result := True;
    try
      if Assigned(JVCSIniFile) then
        JVCSIniFile.UpdateFile;
    except
      Result := False;
    {$IFDEF DEBUG}
      JclDebug.Trace(PChar('E: jvcsUpdateStorageObject' + #0));
    {$ENDIF DEBUG}
    end;
    {$ELSE}
    Result := True;
    {$ENDIF USE_MEMINI}
  end;
end;

//------------------------------------------------------------------------------

function jvcsCloseStorageObject: Boolean;
begin
  if UseRegistryStorage then
    Result := True
  else
  begin
    {$IFDEF USE_MEMINI}
    Result := True;
    try
      if Assigned(JVCSIniFile) then
      begin
        try
          JVCSIniFile.UpdateFile;
        finally
          JVCSIniFile.Free;
          JVCSIniFile := nil;
        end;
      end;
    except
      Result := False;
    {$IFDEF DEBUG}
      JclDebug.Trace(PChar('E: jvcsCloseStorageObject' + #0));
    {$ENDIF DEBUG}
    end;
    {$ELSE}
    Result := True;
    {$ENDIF USE_MEMINI}
  end;
end;

//------------------------------------------------------------------------------

function jvcsKeyExists(const Key: string): Boolean;
begin
  {$IFDEF DEBUG}
  Assert((Key <> ''), 'Parameter Key is blank');
  {$ENDIF DEBUG}
  if UseRegistryStorage then
  begin
    with TJVCSRegistry.Create do
    begin
      RootKey := HKEY_CURRENT_USER;
      try
        Result := KeyExists(Key);
      finally
        Free;
      end;
    end;
  end else
  begin
    {$IFDEF USE_INI}
    with TJVCSIniFile.Create(jvcsGetIniFileName) do
    begin
      try
        Result := SectionExists(Key);
      finally
        Free;
      end;
    end;
    {$ENDIF USE_INI}
    {$IFDEF USE_MEMINI}
    {$IFDEF DEBUG}
      Assert((JVCSIniFile <> nil), 'JVCSIniFile not initialised');
    {$ENDIF DEBUG}
    try
      Result := JVCSIniFile.SectionExists(Key);
    except
      Result := False;
      {$IFDEF DEBUG}
      JclDebug.Trace(PChar('E: jvcsKeyExists ' + Key + #0));
      {$ENDIF DEBUG}
    end;
    {$ENDIF USE_MEMINI}
  end;
end;

//------------------------------------------------------------------------------

function jvcsValueExists(const Key, Name: string): Boolean;
begin
  {$IFDEF DEBUG}
  Assert((Key <> ''), 'Parameter Key is blank');
  Assert((Name <> ''), 'Parameter Name is blank');
  {$ENDIF DEBUG}
  if UseRegistryStorage then
  begin
    with TJVCSRegistry.Create do
    begin
      RootKey := HKEY_CURRENT_USER;
      try
        Result := KeyExists(Key);
        if Result then
          Result := OpenKeyReadOnly(Key);
        if Result then
        begin
          Result := ValueExists(Name);
          CloseKey;
        end;
      finally
        Free;
      end;
    end;
  end else
  begin
    Result := False;
    {$IFDEF USE_INI}
    with TJVCSIniFile.Create(jvcsGetIniFileName) do
    begin
      try
        try
          Result := ValueExists(Key, Name);
        except
          {$IFDEF DEBUG}
          JclDebug.TraceMsg(PChar('E: jvcsValueExists ' + Key + '\' + Name + #0));
          {$ENDIF DEBUG}
        end;
      finally
        Free;
      end;
    end;
    {$ENDIF USE_INI}
    {$IFDEF USE_MEMINI}
    {$IFDEF DEBUG}
    Assert((JVCSIniFile <> nil), 'JVCSIniFile not initialised');
    {$ENDIF DEBUG}
    try
      Result := JVCSIniFile.ValueExists(Key, Name);
    except
      {$IFDEF DEBUG}
      JclDebug.TraceMsg(PChar('E: jvcsValueExists ' + Key + '\' + Name + #0));
      {$ENDIF DEBUG}
    end;
    {$ENDIF USE_MEMINI}
  end;
end;

//------------------------------------------------------------------------------

function jvcsDeleteKey(const Key: string): Boolean;
begin
  {$IFDEF DEBUG}
  Assert((Key <> ''), 'Parameter Key is blank');
  {$ENDIF DEBUG}
  if UseRegistryStorage then
  begin
    Result := False;
    with TJVCSRegistry.Create do
    begin
      RootKey := HKEY_CURRENT_USER;
      try
        if KeyExists(Key) then
        begin
          try
            Result := DeleteKey(Key);
          except
            {$IFDEF DEBUG}
            JclDebug.TraceMsg(PChar('E: jvcsDeleteKey ' + Key + #0));
            {$ENDIF DEBUG}
          end;
        end
        else
          Result := True;
      finally
        Free;
      end;
    end;
  end else
  begin
    {$IFDEF USE_INI}
    Result := False;
    with TJVCSIniFile.Create(jvcsGetIniFileName) do
    begin
      try
        try
          EraseSection(Key);
          Result := True;
        except
          {$IFDEF DEBUG}
          JclDebug.TraceMsg(PChar('E: jvcsDeleteKey ' + Key + #0));
          {$ENDIF DEBUG}
        end;
      finally
        Free;
      end;
    end;
    {$ENDIF USE_INI}
    {$IFDEF USE_MEMINI}
    {$IFDEF DEBUG}
      Assert((JVCSIniFile <> nil), 'JVCSIniFile not initialised');
    {$ENDIF DEBUG}
    Result := False;
    try
      JVCSIniFile.EraseSection(Key);
      Result := True;
    except
    {$IFDEF DEBUG}
      JclDebug.Trace(PChar('E: jvcsDeleteKey ' + Key + #0));
    {$ENDIF DEBUG}
    end;
    {$ENDIF USE_MEMINI}
  end;
end;

//------------------------------------------------------------------------------

function jvcsDeleteValue(const Key, Name: string): Boolean;
begin
  {$IFDEF DEBUG}
  Assert((Key <> ''), 'Parameter Key is blank');
  Assert((Name <> ''), 'Parameter Name is blank');
  {$ENDIF DEBUG}
  if UseRegistryStorage then
  begin
    Result := False;
    with TJVCSRegistry.Create do
    begin
      RootKey := HKEY_CURRENT_USER;    
      try
        if KeyExists(Key) then
        begin
          OpenKey(Key, False);
          if ValueExists(Name) then
          begin
            try
              Result := DeleteValue(Name);
            except
              {$IFDEF DEBUG}
              JclDebug.TraceMsg(PChar('E: jvcsDeleteValue ' + Key + #0));
              {$ENDIF DEBUG}
            end;
          end
          else
            Result := True;
          CloseKey;
        end
        else
          Result := True;
      finally
        Free;
      end;
    end;
  end else
  begin
    {$IFDEF USE_INI}
    Result := False;
    with TJVCSIniFile.Create(jvcsGetIniFileName) do
    begin
      try
        try
          DeleteKey(Key, Name);
          Result := True;
        except
          {$IFDEF DEBUG}
          JclDebug.TraceMsg(PChar('E: jvcsDeleteValue ' + Key + Name + #0));
          {$ENDIF DEBUG}
        end;
      finally
        Free;
      end;
    end;
    {$ENDIF USE_INI}
    {$IFDEF USE_MEMINI}
    {$IFDEF DEBUG}
    Assert((JVCSIniFile <> nil), 'JVCSIniFile not initialised');
    {$ENDIF DEBUG}
    Result := False;
    try
      JVCSIniFile.DeleteKey(Key, Name);
      Result := True;
    except
      {$IFDEF DEBUG}
      JclDebug.TraceMsg(PChar('E: jvcsDeleteValue ' + Key + '\' + Name + #0));
      {$ENDIF DEBUG}
    end;
    {$ENDIF USE_MEMINI}
  end;
end;

//------------------------------------------------------------------------------

function jvcsWriteBool(const Key, Name: string; Value: Boolean): Boolean;
begin
  {$IFDEF DEBUG}
  Assert((Key <> ''), 'Parameter Key is blank');
  Assert((Name <> ''), 'Parameter Name is blank');
  {$ENDIF DEBUG}
  Result := False;
  if UseRegistryStorage then
  begin
    with TJVCSRegistry.Create do
    begin
      RootKey := HKEY_CURRENT_USER;    
      try
        OpenKey(Key, True);
        try
          WriteBool(Name, Value);
          Result := True;
        except
          {$IFDEF DEBUG}
          JclDebug.TraceMsg(PChar('E: jvcsWriteBool ' + Key + Name + #0));
          {$ENDIF DEBUG}
        end;
        CloseKey;
      finally
        Free;
      end;
    end;
  end else
  begin
    {$IFDEF USE_INI}
    with TJVCSIniFile.Create(jvcsGetIniFileName) do
    begin
      try
        try
          WriteBool(Key, Name, Value);
          Result := True;
        except
          {$IFDEF DEBUG}
          JclDebug.TraceMsg(PChar('E: jvcsWriteBool ' + Key + Name + #0));
          {$ENDIF DEBUG}
        end;
      finally
        Free;
      end;
    end;
    {$ENDIF USE_INI}
    {$IFDEF USE_MEMINI}
    {$IFDEF DEBUG}
      Assert((JVCSIniFile <> nil), 'JVCSIniFile not initialised');
    {$ENDIF DEBUG}
    try
      JVCSIniFile.WriteBool(Key, Name, Value);
      Result := True;
    except
    {$IFDEF DEBUG}
      JclDebug.Trace(PChar('E: jvcsWriteBool ' + Key + '\' + Name + #0));
    {$ENDIF DEBUG}
    end;
    {$ENDIF USE_MEMINI}
  end;
end;

//------------------------------------------------------------------------------

function jvcsReadBool(const Key, Name: string; Def: Boolean): Boolean;
begin
  {$IFDEF DEBUG}
  Assert((Key <> ''), 'Parameter Key is blank');
  Assert((Name <> ''), 'Parameter Name is blank');
  {$ENDIF DEBUG}
  if UseRegistryStorage then
  begin
    with TJVCSRegistry.Create do
    begin
      RootKey := HKEY_CURRENT_USER;    
      try
        if OpenKeyReadOnly(Key) then
        begin
          if ValueExists(Name) then
            Result := ReadBool(Name)
          else
            Result := Def;
          CloseKey;
        end
        else
          Result := Def;
      finally
        Free;
      end;
    end;
  end else
  begin
    {$IFDEF USE_INI}
    with TJVCSIniFile.Create(jvcsGetIniFileName) do
    begin
      try
        Result := ReadBool(Key, Name, Def);
      finally
        Free;
      end;
    end;
    {$ENDIF USE_INI}
    {$IFDEF USE_MEMINI}
    {$IFDEF DEBUG}
      Assert((JVCSIniFile <> nil), 'JVCSIniFile not initialised');
    {$ENDIF DEBUG}
    try
      Result := JVCSIniFile.ReadBool(Key, Name, Def);
    except
    {$IFDEF DEBUG}
      JclDebug.Trace(PChar('E: jvcsReadBool ' + Key + '\' + Name + #0));
    {$ENDIF DEBUG}
    end;
    {$ENDIF USE_MEMINI}
  end;
end;

//------------------------------------------------------------------------------

function jvcsWriteInteger(const Key, Name: string; Value: Integer): Boolean;
begin
  {$IFDEF DEBUG}
  Assert((Key <> ''), 'Parameter Key is blank');
  Assert((Name <> ''), 'Parameter Name is blank');
  {$ENDIF DEBUG}
  Result := False;
  if UseRegistryStorage then
  begin
    with TJVCSRegistry.Create do
    begin
      RootKey := HKEY_CURRENT_USER;    
      try
        OpenKey(Key, True);
        try
          WriteInteger(Name, Value);
          Result := True;
        except
          {$IFDEF DEBUG}
          JclDebug.TraceMsg(PChar('E: jvcsWriteInteger ' + Key + Name + #0));
          {$ENDIF DEBUG}
        end;
        CloseKey;
      finally
        Free;
      end;
    end;
  end else
  begin
    {$IFDEF USE_INI}
    with TJVCSIniFile.Create(jvcsGetIniFileName) do
    begin
      try
        try
          WriteInteger(Key, Name, Value);
          Result := True;
        except
          {$IFDEF DEBUG}
          JclDebug.TraceMsg(PChar('E: jvcsWriteInteger ' + Key + '\' + Name + #0));
          {$ENDIF DEBUG}
        end;
      finally
        Free;
      end;
    end;
    {$ENDIF USE_INI}
    {$IFDEF USE_MEMINI}
    {$IFDEF DEBUG}
      Assert((JVCSIniFile <> nil), 'JVCSIniFile not initialised');
    {$ENDIF DEBUG}
    try
      JVCSIniFile.WriteInteger(Key, Name, Value);
      Result := True;
    except
    {$IFDEF DEBUG}
      JclDebug.Trace(PChar('E: jvcsWriteInteger ' + Key + '\' + Name + #0));
    {$ENDIF DEBUG}
    end;
    {$ENDIF USE_MEMINI}
  end;
end;

//------------------------------------------------------------------------------

function jvcsReadInteger(const Key, Name: string; Def: Integer): Integer;
begin
  {$IFDEF DEBUG}
  Assert((Key <> ''), 'Parameter Key is blank');
  Assert((Name <> ''), 'Parameter Name is blank');
  {$ENDIF DEBUG}
  if UseRegistryStorage then
  begin
    with TJVCSRegistry.Create do
    begin
      RootKey := HKEY_CURRENT_USER;    
      try
        if OpenKeyReadOnly(Key) then
        begin
          if ValueExists(Name) then
            Result := ReadInteger(Name)
          else
            Result := Def;
          CloseKey;
        end
        else
          Result := Def;
      finally
        Free;
      end;
    end;
  end else
  begin
    {$IFDEF USE_INI}
    with TJVCSIniFile.Create(jvcsGetIniFileName) do
    begin
      try
        Result := ReadInteger(Key, Name, Def);
      finally
        Free;
      end;
    end;
    {$ENDIF USE_INI}
    {$IFDEF USE_MEMINI}
    {$IFDEF DEBUG}
      Assert((JVCSIniFile <> nil), 'JVCSIniFile not initialised');
    {$ENDIF DEBUG}
    try
      Result := JVCSIniFile.ReadInteger(Key, Name, Def);
    except
    {$IFDEF DEBUG}
      JclDebug.Trace(PChar('E: jvcsReadInteger ' + Key + '\' + Name + #0));
    {$ENDIF DEBUG}
    end;
    {$ENDIF USE_MEMINI}
  end;
end;

//------------------------------------------------------------------------------

function jvcsWriteFloat(const Key, Name: string; Value: Double): Boolean;
begin
  {$IFDEF DEBUG}
  Assert((Key <> ''), 'Parameter Key is blank');
  Assert((Name <> ''), 'Parameter Name is blank');
  {$ENDIF DEBUG}
  Result := False;
  if UseRegistryStorage then
  begin
    with TJVCSRegistry.Create do
    begin
      RootKey := HKEY_CURRENT_USER;    
      try
        OpenKey(Key, True);
        try
          WriteFloat(Name, Value);
          Result := True;
        except
          {$IFDEF DEBUG}
          JclDebug.TraceMsg(PChar('E: jvcsWriteFloat ' + Key + Name + #0));
          {$ENDIF DEBUG}
        end;
        CloseKey;
      finally
        Free;
      end;
    end;
  end else
  begin
    {$IFDEF USE_INI}
    with TJVCSIniFile.Create(jvcsGetIniFileName) do
    begin
      try
        try
          WriteFloat(Key, Name, Value);
          Result := True;
        except
          {$IFDEF DEBUG}
          JclDebug.TraceMsg(PChar('E: jvcsWriteFloat ' + Key + Name + #0));
          {$ENDIF DEBUG}
        end;
      finally
        Free;
      end;
    end;
    {$ENDIF USE_INI}
    {$IFDEF USE_MEMINI}
    {$IFDEF DEBUG}
      Assert((JVCSIniFile <> nil), 'JVCSIniFile not initialised');
    {$ENDIF DEBUG}
    try
      JVCSIniFile.WriteFloat(Key, Name, Value);
      Result := True;
    except
    {$IFDEF DEBUG}
      JclDebug.Trace(PChar('E: jvcsWriteFloat ' + Key + '\' + Name + #0));
    {$ENDIF DEBUG}
    end;
    {$ENDIF USE_MEMINI}
  end;
end;

//------------------------------------------------------------------------------

function jvcsReadFloat(const Key, Name: string; Def: Double): Double;
begin
  {$IFDEF DEBUG}
  Assert((Key <> ''), 'Parameter Key is blank');
  Assert((Name <> ''), 'Parameter Name is blank');
  {$ENDIF DEBUG}
  if UseRegistryStorage then
  begin
    with TJVCSRegistry.Create do
    begin
      RootKey := HKEY_CURRENT_USER;    
      try
        if OpenKeyReadOnly(Key) then
        begin
          if ValueExists(Name) then
            Result := ReadFloat(Name)
          else
            Result := Def;
          CloseKey;
        end
        else
          Result := Def;
      finally
        Free;
      end;
    end;
  end else
  begin
    {$IFDEF USE_INI}
    with TJVCSIniFile.Create(jvcsGetIniFileName) do
    begin
      try
        Result := ReadFloat(Key, Name, Def);
      finally
        Free;
      end;
    end;
    {$ENDIF USE_INI}
    {$IFDEF USE_MEMINI}
    {$IFDEF DEBUG}
      Assert((JVCSIniFile <> nil), 'JVCSIniFile not initialised');
    {$ENDIF DEBUG}
    try
      Result := JVCSIniFile.ReadFloat(Key, Name, Def);
    except
    {$IFDEF DEBUG}
      JclDebug.Trace(PChar('E: jvcsReadFloat ' + Key + '\' + Name + #0));
    {$ENDIF DEBUG}
    end;
    {$ENDIF USE_MEMINI}
  end;
end;

//------------------------------------------------------------------------------

function jvcsWriteString(const Key, Name, Value: string): Boolean;
begin
  {$IFDEF DEBUG}
  Assert((Key <> ''), 'Parameter Key is blank');
  Assert((Name <> ''), 'Parameter Name is blank');
  {$ENDIF DEBUG}
  Result := False;
  if UseRegistryStorage then
  begin
    with TJVCSRegistry.Create do
    begin
      RootKey := HKEY_CURRENT_USER;    
      try
        OpenKey(Key, True);
        try
          WriteString(Name, Value);
          Result := True;
        except
          {$IFDEF DEBUG}
          JclDebug.TraceMsg(PChar('E: jvcsWriteString ' + Key + Name + #0));
          {$ENDIF DEBUG}
        end;
        CloseKey;
      finally
        Free;
      end;
    end;
  end else
  begin
    {$IFDEF USE_INI}
    with TJVCSIniFile.Create(jvcsGetIniFileName) do
    begin
      try
        try
          WriteString(Key, Name, Value);
          Result := True;
        except
          {$IFDEF DEBUG}
          JclDebug.TraceMsg(PChar('E: jvcsWriteString ' + Key + Name + #0));
          {$ENDIF DEBUG}
        end;
      finally
        Free;
      end;
    end;
    {$ENDIF USE_INI}
    {$IFDEF USE_MEMINI}
    {$IFDEF DEBUG}
      Assert((JVCSIniFile <> nil), 'JVCSIniFile not initialised');
    {$ENDIF DEBUG}
    try
      JVCSIniFile.WriteString(Key, Name, Value);
      Result := True;
    except
    {$IFDEF DEBUG}
      JclDebug.Trace(PChar('E: jvcsWriteString ' + Key + '\' + Name + #0));
    {$ENDIF DEBUG}
    end;
    {$ENDIF USE_MEMINI}
  end;
end;

//------------------------------------------------------------------------------

function jvcsReadString(const Key, Name: string; Def: string): string;
begin
  {$IFDEF DEBUG}
  Assert((Key <> ''), 'Parameter Key is blank');
  Assert((Name <> ''), 'Parameter Name is blank');
  {$ENDIF DEBUG}
  if UseRegistryStorage then
  begin
    with TJVCSRegistry.Create do
    begin
      RootKey := HKEY_CURRENT_USER;
      try
        if OpenKeyReadOnly(Key) then
        begin
          if ValueExists(Name) then
            Result := ReadString(Name)
          else
            Result := Def;
          CloseKey;
        end
        else
          Result := Def;
      finally
        Free;
      end;
    end;
  end else
  begin
    {$IFDEF USE_INI}
    with TJVCSIniFile.Create(jvcsGetIniFileName) do
    begin
      try
        Result := ReadString(Key, Name, Def);
      finally
        Free;
      end;
    end;
    {$ENDIF USE_INI}
    {$IFDEF USE_MEMINI}
    {$IFDEF DEBUG}
      Assert((JVCSIniFile <> nil), 'JVCSIniFile not initialised');
    {$ENDIF DEBUG}
    try
      Result := JVCSIniFile.ReadString(Key, Name, Def);
    except
    {$IFDEF DEBUG}
      JclDebug.Trace(PChar('E: jvcsReadString ' + Key + '\' + Name + #0));
    {$ENDIF DEBUG}
    end;
    {$ENDIF USE_MEMINI}
  end;
end;

//------------------------------------------------------------------------------

function jvcsWriteWindowPos(const Key, Name: string;
  const Top, Left: Integer): Boolean;
begin
  Result := jvcsWriteInteger(Key, Name + '_Top', Top);
  if Result then
    Result := jvcsWriteInteger(Key, Name + '_Left', Left);
end;

//------------------------------------------------------------------------------

function jvcsReadWindowPos(const Key, Name: string;
  var Top, Left: Integer): Boolean;
begin
  Top := jvcsReadInteger(Key, Name + '_Top', -999);
  Left := jvcsReadInteger(Key, Name + '_Left', -999);
  Result := (Top > -999) and (Left > -999);
end;

//------------------------------------------------------------------------------

function jvcsWriteWindowSize(const Key, Name: string;
  const Height, Width: Integer): Boolean;
begin
  Result := jvcsWriteInteger(Key, Name + '_Height', Height);
  if Result then
    Result := jvcsWriteInteger(Key, Name + '_Width', Width);
end;

//------------------------------------------------------------------------------

function jvcsReadWindowSize(const Key, Name: string;
  var Height, Width: Integer): Boolean;
begin
  Height := jvcsReadInteger(Key, Name + '_Height', -999);
  Width := jvcsReadInteger(Key, Name + '_Width', -999);
  Result := (Height > -999) and (Width > -999);
end;

//------------------------------------------------------------------------------

function jvcsWriteWindowPosAndSize(const Key, Name: string;
  const Top, Left, Height, Width: Integer): Boolean;
begin
  Result := jvcsWriteInteger(Key, Name + '_Top', Top);
  if Result then
    Result := jvcsWriteInteger(Key, Name + '_Left', Left);
  if Result then
    Result := jvcsWriteInteger(Key, Name + '_Height', Height);
  if Result then
    Result := jvcsWriteInteger(Key, Name + '_Width', Width);
end;

//------------------------------------------------------------------------------

function jvcsReadWindowPosAndSize(const Key, Name: string;
  var Top, Left, Height, Width: Integer): Boolean;
begin
  Top := jvcsReadInteger(Key, Name + '_Top', -999);
  Left := jvcsReadInteger(Key, Name + '_Left', -999);
  Height := jvcsReadInteger(Key, Name + '_Height', -999);
  Width := jvcsReadInteger(Key, Name + '_Width', -999);
  Result := (Top > -999) and (Left > -999) and
    (Height > -999) and (Width > -999);
end;



end.
