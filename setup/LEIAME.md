# setup

Instalador do **JEDI VCS 2.5 Beta 2026** (Inno Setup 6) e arquivos `.reg` de desenvolvimento.

| Arquivo | O que é |
|---|---|
| `JediVCS2026.iss` | Script do instalador (gera `Output\JediVCS-2.5-Beta2026-Setup.exe`) |
| `Output\` | Saída do ISCC (fora do git, `.gitignore`) |
| `Delphi13-JVCS-v2026.reg` | **Só desenvolvimento** (esta máquina): SynEdit/VTV em `Known Packages`, Library Path, PATH da IDE e o expert apontando para `bin\ideclient\Win32` |
| `Delphi13-JVCS-DLL-nova.reg` | **Só desenvolvimento**: só o valor `JVCSIDEClient` → `bin\ideclient\Win32\JvcsExpertBDS37.dll` |

## 1. Gerar o instalador

```
tools\gerar-instalador.bat              (compila Release Win32 de tudo e empacota)
tools\gerar-instalador.bat --sem-build  (só empacota o que já está em bin\)
```

Sem `--sem-build` o script chama, nesta ordem, `tools\compilar.bat exe|dll|diff|console Release Win32` e
`tools\compilar-expert.bat Release nova` (feche o Delphi antes: o expert em uso não é sobrescrito).
Depois confere que existem e têm **FileVersion 2.5.0.2026** `Jedivcs.exe`, `JEDIVCSDiff.exe`, `jvcs.exe`
(`bin\client\Win32`), `JvcsExternalDll.dll` e `JvcsExpertBDS<nn>.dll` (`bin\ideclient\Win32`), confere o
runtime em `3rdparty` e roda o ISCC. Avisos (não bloqueiam): último build Debug mais novo que o Release
(pelos logs de `tools\compilar.bat`), `.map` ausente, e `bin\ideclient\Win32\JvcsExternalDll.dll`
diferente da de `bin\client\Win32` (o pacote usa a de `bin\ideclient`, que é a que o expert testado usa).

- ISCC: `JVCS_ISCC`, ou `D:\Delphi\JediVCS\ferramentas\InnoSetup6\ISCC.exe` (Inno Setup 6.7.3), ou
  `%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe`. Direto: `ISCC.exe setup\JediVCS2026.iss`.
- Log: `tools\logs\gerar-instalador.log`. Código de saída 0 = OK, 1 = falha.
- Experts: entra no pacote todo `bin\ideclient\Win32\JvcsExpertBDS22.dll` / `23` / `37` que existir
  (pré-processador `#if FileExists`), **sem editar o `.iss`**. Hoje só existe o 37 (Delphi 13).

## 2. Instalar, reinstalar/reparar, desinstalar

- **Instalar:** feche o Delphi e execute `JediVCS-2.5-Beta2026-Setup.exe`. Idioma: português (Brasil)
  ou inglês. Pede administrador; a primeira tela permite instalar **só para o usuário atual**
  (`PrivilegesRequiredOverridesAllowed=dialog`, ou `/CURRENTUSER` na linha de comando).
- Pasta padrão: `C:\Program Files (x86)\JEDI\JVCS 2026` (por usuário:
  `%LOCALAPPDATA%\Programs\JEDI\JVCS 2026`). O instalador **recusa** a pasta do JEDI VCS original
  (`...\JEDI\JVCS`, ou qualquer pasta com `JvcsExpertBDS21.dll`, `JvcsExpertD7.dll`, `JVCSSrv.exe` ou um
  `jedivcs.exe` de outra versão).
- **Reinstalar / reparar / atualizar:** rode o mesmo setup (ou um mais novo) de novo. O `AppId` é fixo
  (`{FA4F41D9-F23B-4C34-8186-DCBB5DD86E45}`): ele reaproveita a pasta, os componentes e as tarefas da vez
  anterior e substitui todos os arquivos (`ignoreversion`; os binários têm todos a versão 2.5.0.2026).
  Desmarcar o expert ou a tarefa da IA numa reinstalação **desfaz** o registro/a gravação correspondentes.
- **Desinstalar:** Painel de Controle → Programas → "JEDI VCS 2.5 Beta 2026", ou o atalho no Menu
  Iniciar, ou `unins000.exe` na pasta. Feche o Delphi antes.
- Silencioso: `JediVCS-2.5-Beta2026-Setup.exe /VERYSILENT /SUPPRESSMSGBOXES [/CURRENTUSER] [/DIR=...]
  [/COMPONENTS=client,ide,maps,ai] [/TASKS=desktopicon,aiconsole] [/LOG=arquivo]`;
  `unins000.exe /VERYSILENT /SUPPRESSMSGBOXES`. Com o Delphi aberto, o silencioso **aborta**
  (setup: código 7; desinstalação: código 1) sem mudar nada.

## 3. Componentes e tarefas

Tudo marcado por padrão, exceto a tarefa "Usar o console novo na IA".

| Componente / tarefa | Instala ou faz |
|---|---|
| **Cliente** (`client`) | `Jedivcs.exe`, `JEDIVCSDiff.exe`, `jvcs.exe`, `fvcscrypt.dll`, `jedivcs.chm`, `jedivcsdiff.chm`, `htm_rep.htm`, `ffdef.jvcs`, `ulist.jvcs`, `vcllist.jvcs`, `vcllistbcb.jvcs`, `verinf.jvcs`, `license.txt`. Menu Iniciar → "JEDI VCS 2026": cliente, Diff, as duas ajudas e desinstalar |
| tarefa `desktopicon` | Atalho "JEDI VCS 2026" na área de trabalho |
| **Expert** (`ide`) | `JvcsExpertBDS<nn>.dll` + `JvcsExternalDll.dll` (e o runtime acima, que a DLL procura na própria pasta, inclusive o `JEDIVCSDiff.exe` do Compare). Registra o expert nas IDEs detectadas (seção 4) |
| **.map** (`maps`) | `Jedivcs.map` e `JvcsExternalDll.map` ao lado dos módulos: o log de erros (`%LOCALAPPDATA%\JEDI\JVCS\logs\jvcs-exe|dll-*.log`, JclDebug) passa a mostrar unit/rotina/linha. ~14 MB cada sem compressão, poucos MB no setup (texto comprime bem). Diff, console e expert não usam `.map` |
| **Ferramentas da IA** (`ai`) | `tools\ai` inteiro em `{app}\tools\ai`, byte a byte (os `.ps1` continuam UTF-8 com BOM e CRLF). Menu Iniciar: atalho para a pasta. Para usar num projeto: `{app}\tools\ai\instalar-no-projeto.ps1 -ProjectDir ...` (ver `tools\ai\LEIAME.md`) |
| tarefa `aiconsole` (desmarcada) | Grava `jvcsExe={app}\jvcs.exe` na seção `[ai]` de `%APPDATA%\JEDI\JVCS\config.ini`, com o mesmo algoritmo do `jvcs-ai.ps1 config set` (UTF-8 com BOM, CRLF, resto do arquivo preservado; `checkout=`/`checkin=` intactos). O valor anterior é guardado e volta na desinstalação (ou se a tarefa for desmarcada numa reinstalação); se o `config.ini` foi criado pelo instalador e ficou vazio, ele é apagado |

**Não instalados de propósito:** `.drc`, `.dcu`, `zipdll.dll`/`unzdll.dll` (DelZip, trocado pelo
Abbrevia; só o About as listava), `borlndmm.dll` (sem ShareMem), o `jedivcsdiff.exe` 2.5.0.1030 que o
`compilar-expert.bat` copia para `bin\ideclient\Win32` (aqui a DLL usa o `JEDIVCSDiff.exe` novo da mesma
pasta) e os `.reg` de desenvolvimento.

**Layout:** uma pasta só, como no JEDI VCS original. O expert carrega a `JvcsExternalDll.dll` **da
própria pasta**, e a DLL procura `fvcscrypt.dll`, `*.jvcs`, `htm_rep.htm`, as ajudas e o `jedivcsdiff.exe`
na pasta dela; com tudo junto não há cópia duplicada (18 MB da DLL + runtime) e EXE e DLL usam o mesmo
Diff novo.

## 4. O que muda na IDE

Para cada versão cujo `JvcsExpertBDS<nn>.dll` está no pacote (22 = Delphi 11, 23 = Delphi 12, 37 = Delphi 13):

1. a IDE é considerada instalada se `HKCU` ou `HKLM` (32 bits) `\Software\Embarcadero\BDS\<nn>.0` tem
   `App` apontando para um `bds.exe` existente (a página de componentes mostra "detectado: ...");
2. se `HKCU\Software\Embarcadero\BDS\<nn>.0` não existe (a IDE nunca foi aberta por este usuário), **não
   registra** (gravar `Experts` antes da primeira execução impediria a IDE de criar a configuração
   padrão) e avisa: abra e feche o Delphi uma vez e rode o setup de novo;
3. grava `HKCU\Software\Embarcadero\BDS\<nn>.0\Experts`, valor `JVCSIDEClient` = `{app}\JvcsExpertBDS<nn>.dll`.
   Se já havia outro `JVCSIDEClient` (ex.: o de desenvolvimento,
   `D:\Delphi\JediVCS\v2026\bin\ideclient\Win32\JvcsExpertBDS37.dll`), ele é guardado em
   `{app}\jvcs2026-setup.ini` e **restaurado na desinstalação**.

Só isso. As demais chaves de `Delphi13-JVCS-v2026.reg` (`Known Packages` do SynEdit/VTV, `Library`,
`Environment Variables`) servem para **compilar** o port na IDE; o usuário final não precisa delas
(o expert é uma DLL com pacotes `rtl`/`vcl`/`designide` da própria IDE e a `JvcsExternalDll.dll` não usa
pacotes). Não grava em `Experts x64` (a IDE de 64 bits não carrega DLL de 32 bits).

Desinstalação: remove `JVCSIDEClient` **só se ele aponta para a pasta desta instalação** (outra
instalação ou o expert de desenvolvimento ficam como estão); se havia valor anterior, ele volta.

**Delphi aberto:** antes de instalar (com o expert marcado ou já instalado na pasta) e antes de
desinstalar, se houver um `bds.exe` rodando (WMI, e janela `TAppBuilder` como reserva), o setup pede para
fechar (Repetir/Cancelar). A IDE regrava `Experts` ao fechar e prende a DLL do expert.

## 5. Convivência

- **JEDI VCS original** (`C:\Program Files (x86)\JEDI\JVCS`, cliente 2.5.0.1030 e servidor de teste):
  não é tocado. Os dois clientes podem ficar instalados; os atalhos novos têm "2026" no nome.
- **`HKCU\Software\JEDI\JEDIVCS`** (identidades, senhas, opções): nunca é lido nem gravado pelo
  instalador nem pela desinstalação. Ele é compartilhado entre o cliente original e o novo.
- **Expert de desenvolvimento** (`bin\ideclient\Win32`): o setup troca o `JVCSIDEClient` para a pasta
  instalada e devolve o valor de desenvolvimento ao desinstalar. Para voltar ao de desenvolvimento sem
  desinstalar: rode o setup de novo desmarcando o Expert, ou importe `Delphi13-JVCS-DLL-nova.reg`
  (Delphi fechado).
- **Automação por IA:** sem a tarefa `aiconsole`, o wrapper continua com o `jvcs.exe` que estiver no
  `config.ini` (padrão: o original 2.5.0.1030). O `jvcs.exe` novo tem `OriginalFilename=jvcs.exe` e
  `ProductName` com "JEDI", como o wrapper exige.
- **Usuário de outro perfil:** em instalação para todos os usuários, as gravações em `HKCU` e
  `%APPDATA%` (expert e `config.ini`) valem para a conta que executou o setup elevado. Se o UAC pedir a
  senha de **outra** conta de administrador, use "instalar só para mim" ou rode o setup de novo em cada
  conta.

## 6. Testes (13/10/2026)

Feitos com `--sem-build`, instalação silenciosa por usuário numa pasta do scratchpad, sem tocar no
registro real da IDE nem no `config.ini` real. Dois parâmetros **só para teste** desviam as gravações:
`/BDSKEY=Software\<chave de teste>\BDS` (base das chaves `BDS\<nn>.0`) e `/AICONFIG=<arquivo>`
(o `config.ini`). Roteiro (`teste.ps1` no scratchpad da sessão):

| Cenário | Resultado |
|---|---|
| A. `Experts` falso com `JVCSIDEClient` de desenvolvimento + cópia do `config.ini` real; instalar com `/TASKS=aiconsole` | expert → pasta instalada, valor anterior guardado; `config.ini` com `jvcsExe=` **byte a byte igual** ao do `Set-JaConfigValue` do wrapper; `tools\ai` com hashes iguais à origem; Menu Iniciar com 6 atalhos; entrada no Painel de Controle |
| A. reinstalar por cima (sem `/TASKS`) | mesmas tarefas; valor anterior **não** é perdido |
| A. reinstalar com `/COMPONENTS=client,maps,ai /TASKS=` | `JVCSIDEClient` de desenvolvimento restaurado; `config.ini` volta ao hash original |
| A. reinstalar completo e desinstalar | tudo restaurado (`config.ini` com hash original), pasta, atalhos e entrada de desinstalação removidos |
| B. sem `JVCSIDEClient` e sem `config.ini`; instalar, reinstalar, desinstalar | valor criado e depois apagado; `config.ini` criado (igual ao do wrapper) e apagado |
| `bds.exe` rodando (cópia renomeada do `ping.exe`) | instalação silenciosa abortada (código 7) sem gravar nada; desinstalação abortada (código 1) com tudo intacto |
| Pasta "original" (com `JvcsExpertBDS21.dll`) | recusada (código 1) sem gravar |
| Registro real | `HKCU\Software\Embarcadero\BDS\37.0\Experts` exportado antes e depois: **idêntico** |

Não testados: instalação em modo administrador (pede UAC), assistente interativo, IDE nunca aberta
(precisa de chave em `HKLM`), Delphi 11/12.
