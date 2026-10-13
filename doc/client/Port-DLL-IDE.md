# Port da DLL da IDE `JvcsExternalDll.dll` para Delphi 13.2 (F5)

Estado em **12/10/2026**. A DLL do cliente para a IDE (`src\jedivcs\JediVCSDLL.dpr`, as mesmas fontes
do `Jedivcs.exe` portado na F4) compila no Delphi 13.2 Win32 (Debug e Release, 0 erros) e gera
`bin\client\Win32\JvcsExternalDll.dll`. Ela substitui a `JvcsExternalDll.dll` 2.5.0.1030 (Delphi 2007)
atrás do expert novo `src\jvcsideexpert` (`JvcsExpertBDS37.dll`), com a mesma ABI.

O harness fora da IDE passou com a DLL nova e com a original (mesma sequência do expert, sem access
violation). **Ainda falta o teste dentro da IDE** (roteiro na seção 5).

Referências: [Plano-de-Port.md](../common/Plano-de-Port.md) (F5),
[Port-Standalone.md](Port-Standalone.md) (port do EXE), [Expert-IDE-Analise.md](Expert-IDE-Analise.md)
(ABI e callbacks), [`src\jvcsideexpert\LEIAME.md`](../../src/jvcsideexpert/LEIAME.md).

## 1. Como compilar

```
tools\compilar.bat dll Debug Win32
tools\compilar.bat dll Release Win32
tools\compilar-expert.bat Release nova        (expert + DLL nova em bin\ideclient\Win32)
tools\compilar-expert.bat Release original    (volta para a 2.5.0.1030)
```

- Saída: `bin\client\Win32\JvcsExternalDll.dll` (+ `.map`/`.drc`). O dcc32 gera `JediVCSDLL.dll` e o
  `compilar.bat` renomeia para o nome que o expert procura (novo campo `PRJ_dll_OUT` da tabela).
- DCUs em `dcu\Win32\<cfg>\dll` (separados do EXE). Log: `tools\logs\compilar_dll_Win32_<cfg>.log`.
- Resultado: 0 erros; 328 avisos (Debug) e 327 (Release), os mesmos tipos do EXE (`W1057`/`W1058` dos
  registros `ShortString`, `W1050`, `W1000`).
- Tamanho: 18,2 MB (Release; a 2.5.0.1030 tinha 5,9 MB). Sem runtime packages.
- Versão: o `jvcsver.res` do EXE (FileVersion 2.5.0.2026, ProductVersion "2.5 Beta 2026",
  pré-lançamento), como a original usava o mesmo recurso do EXE.

### Defines do alvo `dll`

`DEBUG`/`RELEASE`, `IDEDLL`, `EXT_IDE_INTF`, `USECLIENTDISPATCHER`, `BRANCHING`, `JVCS_NOBRANCHUI`,
`UNISYNEDIT` e `OVERBYTEV6_UP` (comum): os do EXE mais os dois da DLL. `LANGUAGE` saiu (era do `.dof`)
e `REPORTDLL` continua desligado (`JVCS_NOREPORTS`).

## 2. O que mudou

| Arquivo | Mudança |
|---|---|
| `tools\compilar.bat` | alvo `dll` com os defines acima; `PRJ_chave_OUT` + `:rename_out` (`JediVCSDLL.*` → `JvcsExternalDll.*`) |
| `JediVCSDLL.dpr` | sem `ShareMem` (a 2.5.0.1030 não importava `borlndmm.dll`; nada gerenciado atravessa a ABI) e sem `winxp.res` (a DLL roda no contexto de ativação da IDE); `JvDynControlEngineVCL` (diálogos DSA, como no EXE); exports `GetIDString`/`GetMenuName`/`GetVerb`/`FileNotification` com `PAnsiChar`; `AnsiCrLf` → `sLineBreak`; **relatórios**: `DoPrintReport` não faz nada e o verbo fica desabilitado sob `JVCS_NOREPORTS`; **`JVCS_NOBRANCHUI`**: `MapVerbIndex`/`GetVerbCount` sem o "Select Branch" (27 verbos, como sem `BRANCHING`; a original tem 29) |
| `JVCSIDEInterface.pas` | lado DLL das 24 callbacks: `PChar` (= `PWideChar` no Delphi 13) → `PAnsiChar`; string → ANSI (CP_ACP) **sem "best fit"**; buffers de saída de 1 KB zerados e terminados (o expert escreve no máximo 255 + #0); `SourceReadString` com `AnsiString` e os bytes exatos (`IDESource2Stream` gravava UTF-16 no stream); `GetModuleComponents` com o nome convertido uma vez |
| `JVCSDLLAnsi.pas` (nova) | `JvcsToAnsi`, `JvcsFromAnsi`, `JvcsAnsiCopy` (StrPCopy para o buffer do expert, com limite opcional) |
| `JVCSDLLFileHistoryImpl.pas` | 9 funções de History com `PAnsiChar`; comentário limitado a `AMaxCommentSize` bytes ANSI |
| `JVCSDLLOperations.pas` | 10 operações com `PAnsiChar` |
| `VerSet.pas` | `AnsiCrLf` → `sLineBreak` |
| `src\common\JVCSIDESettings.pas` | `{$ifdef WINDOWS}` → `MSWINDOWS` (sem isso o `JclRegistry` não entrava). Detecção do BDS 37 **não** foi acrescentada: continua `IDEUnknown`, tratado como Delphi (igual à original) |
| `src\common\client\JVCSClientFunctions.pas` | `GetSelfFileName`: `Length` no lugar de `SizeOf` no `GetModuleFileName` (estouro de buffer com `Char` = `WideChar`; afeta EXE, console e DLL) |
| `tools\compilar-expert.bat` | 2º parâmetro `nova` (padrão) ou `original`: qual `JvcsExternalDll.dll` vai para `bin\ideclient\Win32` |

O expert (`src\jvcsideexpert\*.pas`) **não mudou**: a ABI é a mesma, a DLL nova é procurada pelo mesmo
nome na mesma pasta e o expert não confere versão.

### 2.1 LOGIN

A versão enviada no `LOGIN` vem de `GetJVCSAppProductVersionInt` (`VCSProcBase.pas`), chamado em
`Create.pas:534`. Ela lê o **PRODUCTVERSION numérico do próprio módulo** (`GetSelfFileName` →
`GetModuleFileName(HInstance)`, ou seja, a DLL, não o `bds.exe`): 2,5,0,2026 → 2·100 + 5·10 + 0 =
**250**. A original tem PRODUCTVERSION 2.5.0.0 → também **250**. O servidor aceita 250 (mesmo valor do
EXE portado, conferido no proxy na F4). Não conferido no fio com a DLL (o harness não conecta).

## 3. ABI: exports

`tdump -ee` (Delphi 13.2):

| Export | Original 2.5.0.1030 | Nova 2.5.0.2026 |
|---|---|---|
| `JEDIVCSDLLINIT` | ord 4 | ord 7 |
| `JEDIVCSDLLFINALIZE` | ord 3 | ord 6 |
| `JEDIVCSDLLHISTORYINIT` | ord 2 | ord 5 |
| `JEDIVCSDLLOPERATIONINIT` | ord 1 | ord 4 |
| `dbkFCallWrapperAddr`, `__dbk_fcall_wrapper` | — | ords 1 e 2 (RTL do Delphi moderno, para o depurador) |
| `bz_internal_error` | — | ord 3 (bzip2 do Abbrevia, linkado estático) |

Os quatro exports da ABI têm os mesmos nomes. Os ordinais mudaram, mas o expert (antigo e novo) usa
`GetProcAddress` por nome. Os três exports extras são inofensivos. Assinaturas: os records e tipos
vêm de `src\common\JVCSIDEInterfaceCommon.pas`, sem alteração (`stdcall`, `PAnsiChar`, `{$Z1}`). O
teste F do expert já confere a cópia `JVCSExpertABI.pas` contra essa unit.

## 4. Harness fora da IDE

```
src\jvcsideexpert\tests\testar-dll.bat [nova|original|ambas] [verbos]
```

`JvcsDllHarness.dpr` é um host console com `rtl;vcl;designide` que usa o **`TJVCSDllBridge` e as 24
callbacks reais do expert**, com um `IBorlandIDEServices` vazio. Sequência:

1. `Load`: `LoadLibraryEx` na pasta do host, `JEDIVCSDLLINIT(@IDE,@VCS,@Notifier)`,
   `JEDIVCSDLLHISTORYINIT`, `JEDIVCSDLLOPERATIONINIT`;
2. `GetMenuName`, `GetVerbCount`, e para cada verbo `GetVerb`/`GetVerbState`/`GetVerbShortCut`/
   `GetVerbImageIndex`; `GetVerbImages` 16×16;
3. `FileNotification`, `EventNotification` (before/after compile), `ProjectChange`, `HistoryCount`;
4. `ExecuteVerb` em Connect Server, Project Manager, VCS Properties, Recent Projects e About (ou nos
   índices passados). Uma thread registra e fecha toda janela visível do processo;
5. `OpGetProjectID` sem conexão;
6. `Unload`: `JEDIVCSDLLFINALIZE` e depois `FreeLibrary`.

Um *vectored exception handler* conta **toda** `EXCEPTION_ACCESS_VIOLATION` do processo (primeira
chance, tratada ou não). O host tem VERSIONINFO porque, no login, a DLL lê a versão do executável
(`Application.ExeName`, o `bds.exe` na IDE). Saídas em `dcu\Win32\dll-harness\bin\<nova|original>\
harness.txt`.

Resultado (12/10/2026, Debug e Release da nova; original 2.5.0.1030):

| | Nova (2.5.0.2026) | Original (2.5.0.1030) |
|---|---|---|
| INIT / HISTORYINIT / OPERATIONINIT | True / 9 ponteiros preenchidos / OK | igual |
| Menu | `JEDI &VCS ` | igual |
| Verbos | 27 (sem "Select Branch") | 29 |
| Atalhos padrão | Ctrl+Shift+P/I/O/G/B | igual |
| Imagens 16×16 | BMP de 7734 bytes | igual |
| Connect Server | aviso "IDE returns no active IDE project" (o host não tem projeto) + `TVCSLoad` "Server Login" | igual |
| Project Manager sem conexão | "Application server not connected" | igual |
| VCS Properties / Recent Projects / About | `TVCSOptions` / `TVCSRecentProjects` / `TVCSAbout` | igual |
| FINALIZE + FreeLibrary | OK | OK |
| Access violations no processo | **0** | **0** |
| Falhas | 0 | 0 |

O harness não conecta ao servidor: login, check-in/out, History e operações com projeto ficam para o
teste na IDE.

## 5. Teste na IDE (usuário)

A pasta `bin\ideclient\Win32` já está montada com o expert e a **DLL nova** (`compilar-expert.bat
Release nova`, 12/10/2026). O registro do expert é o mesmo de antes (`JVCSIDEClient`).

1. **Feche o Delphi 13.**
2. Se o expert ainda não estiver registrado: importe `setup\Delphi13-JVCS-DLL-nova.reg` (duplo
   clique). Quem já importou `setup\Delphi13-JVCS-v2026.reg` não precisa (é o mesmo valor).
3. Opcional, para o log: num prompt, `set JVCS_EXPERT_LOG=%TEMP%\jvcs-expert.log` e abra
   `"C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\bds.exe"` desse prompt.
4. Abra o Delphi 13 (**32 bits**). Help > About deve mostrar o plugin; o menu **JEDI VCS** deve ter
   27 itens (sem "Select Branch").
5. **JEDI VCS > Connect Server…**: escolha a identidade do servidor de teste (127.0.0.1:2106,
   `sysdba`) e conecte. Use uma identidade própria de teste (ex.: `JVCS2026TEST`) se for mudar
   Host/Port: o Connect grava Host/Port na identidade selecionada.
6. Abra o projeto Exemplo01 (Ex1) já cadastrado. O **Project Manager** do JVCS deve listar os 4
   módulos.
7. Abra `uPrincipal.pas`, **Check Out** (Ctrl+Shift+O), altere um comentário (com acentos),
   salve e **Check In** (Ctrl+Shift+I) com comentário acentuado. Confira a nova revisão na aba
   **History** da unit e no `Module History` do JVCS.
8. Feche o projeto e a IDE: sem AV nem travamento. No log devem aparecer `JEDIVCSDLLINIT = True`,
   `JvcsExternalDll carregada: …bin\ideclient\Win32\JvcsExternalDll.dll` e, no fim,
   `JvcsExternalDll descarregada`.

Para voltar à DLL original: feche o Delphi e rode `tools\compilar-expert.bat Release original`.

## 6. Pendências

- **Teste na IDE** (seção 5), incluindo History, menu do Project Manager, Compare/Diff, fechamento com
  e sem sessão, e conferir o LOGIN 250 no fio (proxy `tools\golden\console\proxy.ps1`).
- Verbos: a nova tem 27 e a original 29. As ações do expert se chamam `JEDIVCS_A<índice>`; um atalho
  **personalizado na IDE** para um verbo depois do índice 0 muda de verbo ao trocar de DLL (os atalhos
  padrão vêm da DLL e não mudam).
- `JVCSIDESettings` sem BDS 22/23/37 (`IDEUnknown`, tratado como Delphi); `UsedUnits`, `ToDo`,
  `VerSet`, `Recent` e `UsedComponents` com caminhos e chaves do Delphi 7 (plano 5.3/5.4) não foram
  revistos.
- `JVCSIDEInterface` ainda tem o ramo `INTERNAL_OLDOTA` (não compilado); `JVCSDLLLineHistoryFrame` não
  entra (`LINEHISTORYFRAMEEXPORT` nunca definido).
- Finalização: `DllEntry(DLL_PROCESS_DETACH)` ainda chama `JediVCSDLLFinalize` se o expert não chamou
  (sob o loader lock). O expert novo sempre chama o `FINALIZE` antes do `FreeLibrary`.
- `.dproj` da DLL, builds D11/D12, Win64 (F6) e setup Inno (5.6).
- As opções de fonte/tema/aba IA (`JVCSUIScale`/`JVCSUITheme`) ainda não foram aplicadas na DLL.
