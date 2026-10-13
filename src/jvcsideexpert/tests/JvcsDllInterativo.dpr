program JvcsDllInterativo;
{ Host INTERATIVO (fora da IDE) da JvcsExternalDll.dll real, para reproduzir o
  que o usuario faz dentro do Delphi: usa o TJVCSDllBridge e as callbacks reais
  do expert (como o JvcsDllHarness), mas NAO fecha as janelas sozinho.

  - Cria uma janela "Fake IDE" da classe TAppBuilder (como a janela principal
    do Delphi): os forms da DLL devem ficar com ela como dona (GW_OWNER).
  - Opcional: ativa um VCL Style no host (como os temas da IDE), com os
    SystemHooks padrao (menus/dialogos): reproduz os menus da DLL pintados pelo
    hook de menus do host.
  - Executa os verbos pedidos (nomes ou indices), roda o laco de mensagens ate
    o arquivo de parada existir (ou o tempo acabar) e entao chama
    JEDIVCSDLLFINALIZE + FreeLibrary, como o expert ao fechar a IDE.
  - Conta access violations e excecoes Delphi (primeira chance) do processo.

  Uso: JvcsDllInterativo.exe [-style <arquivo.vsf>] [-verbs "Connect Server,Project Manager"]
                             [-stop <arquivo>] [-timeout <s>] [-wait <ms entre verbos>]
                             [-hostmsg <texto>]  (caixa de mensagem do proprio host
                             depois dos verbos: deve seguir o tema do host, nao o da DLL)
  Rodar com tests\testar-dll-interativo.bat. }
{$APPTYPE CONSOLE}
{$R JvcsDllHarness.res}
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, ToolsAPI,
  Vcl.Forms, Vcl.Themes, Vcl.Styles,
  JVCSExpertABI, JVCSExpertUtils, JVCSExpertDllBridge;

type
  TFakeServices = class(TInterfacedObject, IBorlandIDEServices70, IBorlandIDEServices)
    function SupportsService(const Service: TGUID): Boolean;
    function GetService(const Service: TGUID): IInterface; overload;
    function GetService(const Service: TGUID; out Svc): Boolean; overload;
  end;

  TAppBuilder = class(TForm)
  end;

function TFakeServices.SupportsService(const Service: TGUID): Boolean;
begin
  Result := False;
end;

function TFakeServices.GetService(const Service: TGUID): IInterface;
begin
  Result := nil;
end;

function TFakeServices.GetService(const Service: TGUID; out Svc): Boolean;
begin
  Pointer(Svc) := nil;
  Result := False;
end;

var
  AVCount: Integer = 0;
  DelphiExcCount: Integer = 0;

function VEHandler(ExceptionInfo: PExceptionPointers): Longint; stdcall;
begin
  if (ExceptionInfo <> nil) and (ExceptionInfo^.ExceptionRecord <> nil) then
    case ExceptionInfo^.ExceptionRecord^.ExceptionCode of
      EXCEPTION_ACCESS_VIOLATION: InterlockedIncrement(AVCount);
      $0EEDFADE: InterlockedIncrement(DelphiExcCount);
    end;
  Result := 0; // EXCEPTION_CONTINUE_SEARCH
end;

function AddVectoredExceptionHandler(First: ULONG; Handler: Pointer): Pointer; stdcall;
  external kernel32 name 'AddVectoredExceptionHandler';

function Arg(const AName, ADefault: string): string;
var
  I: Integer;
begin
  Result := ADefault;
  for I := 1 to ParamCount - 1 do
    if SameText(ParamStr(I), '-' + AName) then
      Exit(ParamStr(I + 1));
end;

function StripAccel(const S: string): string;
begin
  Result := Trim(StringReplace(S, '&', '', [rfReplaceAll]));
end;

procedure Pump(AMs: Cardinal; const AStopFile: string);
var
  T0: UInt64;
begin
  T0 := GetTickCount64;
  while (GetTickCount64 - T0 < AMs) and not ((AStopFile <> '') and FileExists(AStopFile)) do
  begin
    Application.ProcessMessages;
    Sleep(10);
  end;
end;

var
  Bridge: TJVCSDllBridge;
  Fake: TAppBuilder;
  Verbs: TStringList;
  StyleFile, StopFile, S: string;
  I, J, Idx, Timeout, WaitMs: Integer;
begin
  ExitCode := 0;
  AddVectoredExceptionHandler(1, @VEHandler);
  ToolsAPI.BorlandIDEServices := TFakeServices.Create;
  Application.Initialize;
  StyleFile := Arg('style', '');
  if StyleFile <> '' then
  begin
    TStyleManager.SetStyle(TStyleManager.LoadFromFile(StyleFile));
    Writeln('host: VCL Style "', TStyleManager.ActiveStyle.Name, '" (SystemHooks padrao)');
  end;
  StopFile := Arg('stop', '');
  Timeout := StrToIntDef(Arg('timeout', '120'), 120);
  WaitMs := StrToIntDef(Arg('wait', '3000'), 3000);
  if (StopFile <> '') and FileExists(StopFile) then
    DeleteFile(StopFile);

  Fake := TAppBuilder.CreateNew(nil);
  Fake.Caption := 'Fake IDE (TAppBuilder) - JvcsDllInterativo';
  Fake.SetBounds(40, 40, 900, 600);
  Fake.Show;
  Writeln('host: janela TAppBuilder = $', IntToHex(Fake.Handle, 8));

  Verbs := TStringList.Create;
  Bridge := TJVCSDllBridge.Create;
  JVCSBridge := Bridge;
  try
    try
      if not Bridge.Load then
      begin
        Writeln('Load falhou: ', Bridge.LoadError);
        ExitCode := 1;
        Exit;
      end;
      Writeln('DLL: ', Bridge.DllPath);
      for I := 0 to Bridge.GetVerbCount - 1 do
        Verbs.Add(StripAccel(Bridge.GetVerb(I)));
      with TStringList.Create do
      try
        StrictDelimiter := True;
        CommaText := Arg('verbs', '');
        for I := 0 to Count - 1 do
        begin
          S := Trim(Strings[I]);
          Idx := StrToIntDef(S, -1);
          if Idx < 0 then
            for J := 0 to Verbs.Count - 1 do
              if Pos(LowerCase(S), LowerCase(Verbs[J])) = 1 then
              begin
                Idx := J;
                Break;
              end;
          if (Idx < 0) or (Idx >= Verbs.Count) then
          begin
            Writeln('verbo nao encontrado: ', S);
            Continue;
          end;
          Writeln(Format('ExecuteVerb(%d) "%s"  (AVs=%d, exc. Delphi=%d)',
            [Idx, Verbs[Idx], AVCount, DelphiExcCount]));
          Bridge.ExecuteVerb(Idx);
          Pump(WaitMs, StopFile);
        end;
      finally
        Free;
      end;
      if Arg('hostmsg', '') <> '' then
        // caixa de mensagem do PROPRIO host: com a DLL em tema escuro e o host
        // sem estilo ela deve continuar clara (o estilo da DLL nao vaza)
        MessageBox(Fake.Handle, PChar(Arg('hostmsg', '')), 'Host', MB_OK);
      Writeln('laco de mensagens: crie "', StopFile, '" (ou feche a Fake IDE) para finalizar');
      while Fake.Visible and not ((StopFile <> '') and FileExists(StopFile)) and (Timeout > 0) do
      begin
        Pump(1000, StopFile);
        Dec(Timeout);
      end;
      Writeln(Format('antes do FINALIZE: AVs=%d, exc. Delphi=%d', [AVCount, DelphiExcCount]));
      Bridge.Unload;
      Writeln(Format('depois do FINALIZE/FreeLibrary: AVs=%d, exc. Delphi=%d', [AVCount, DelphiExcCount]));
    except
      on E: Exception do
      begin
        ExitCode := 1;
        Writeln('EXCECAO NO HOST: ', E.ClassName, ': ', E.Message);
      end;
    end;
  finally
    JVCSBridge := nil;
    Bridge.Free;
    Verbs.Free;
    Fake.Free;
    ToolsAPI.BorlandIDEServices := nil;
  end;
  if AVCount > 0 then
    ExitCode := ExitCode + AVCount;
  Writeln('RESULTADO AVs=', AVCount, ' excecoes Delphi (1a chance)=', DelphiExcCount);
end.
