# setup

Instalador do **JEDI VCS 2.5 Beta 2026** (Inno Setup 6) e arquivos `.reg` de desenvolvimento.

| Arquivo | O que é |
|---|---|
| `JediVCS2026.iss` | Script do instalador (gera `Output\JediVCS-2.5.0-Beta6-build2060-Setup.exe`) |
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
Depois confere que existem e têm **FileVersion 2.5.0.<Build>** (`tools\versao.ini`; beta 6 = 2.5.0.2060) `Jedivcs.exe`, `JEDIVCSDiff.exe`, `jvcs.exe`
(`bin\client\Win32`), `JvcsExternalDll.dll` e `JvcsExpertBDS<nn>.dll` (`bin\ideclient\Win32`), confere o
runtime em `3rdparty` e roda o ISCC. Avisos (não bloqueiam): último build Debug mais novo que o Release
(pelos logs de `tools\compilar.bat`), `.map` ausente, e `bin\ideclient\Win32\JvcsExternalDll.dll`
diferente da de `bin\client\Win32` (o pacote usa a de `bin\ideclient`, que é a que o expert testado usa).

- ISCC: `JVCS_ISCC`, ou `D:\Delphi\JediVCS\ferramentas\InnoSetup6\ISCC.exe` (Inno Setup 6.7.3), ou
  `%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe`. Direto: `ISCC.exe setup\JediVCS2026.iss`.
- Log: `tools\logs\gerar-instalador.log`. Código de saída 0 = OK, 1 = falha.
- Experts: entra no pacote todo `bin\ideclient\Win32\JvcsExpertBDS22.dll` / `23` / `37` que existir
  (pré-processador `#if FileExists`), **sem editar o `.iss`**. O `gerar-instalador.bat` compila o 22/23 só se
  o Delphi 11/12 estiver instalado e confere cada expert com `tools\verificar-expert.ps1` (só `rtl`/`vcl`/`xmlrtl`
  importados, todos os símbolos resolvidos). Em 17/10/2026: 22 (Delphi 11.3), 23 (Delphi 12) e 37 (Delphi 13.2).
- O expert é registrado só em `HKCU\...\BDS\<v>\Experts` (IDE de 32 bits); um valor nosso em `Experts x64`
  (IDE de 64 bits do 12.3/13) é removido na instalação.
- IDEs antigas (Delphi 7 a 10.4): os 21 experts **originais** 2.5.0.1030 vêm de
  `3rdparty\experts-originais-2.5.0.1030` (seção 4A). O `gerar-instalador.bat` confere os 21 contra o
  `SHA256SUMS.txt` da pasta e falha se algum mudar.
- Skill do Claude Code: `skills\pt\jedi-vcs` e `skills\en\jedi-vcs` (pastas inteiras) entram no componente **Ferramentas da IA**.

## 2. Instalar, reinstalar/reparar, desinstalar

- **Instalar:** feche o Delphi e execute `JediVCS-2.5.0-Beta6-build2060-Setup.exe`. Idioma: português (Brasil)
  ou inglês. Pede administrador; a primeira tela permite instalar **só para o usuário atual**
  (`PrivilegesRequiredOverridesAllowed=dialog`, ou `/CURRENTUSER` na linha de comando).
- Pasta padrão: `C:\Program Files (x86)\JEDI\JVCS 2026` (por usuário:
  `%LOCALAPPDATA%\Programs\JEDI\JVCS 2026`). O instalador **recusa** a pasta do JEDI VCS original
  (`...\JEDI\JVCS`, ou qualquer pasta com `JvcsExpertBDS21.dll`, `JvcsExpertD7.dll`, `JVCSSrv.exe` ou um
  `jedivcs.exe` de outra versão).
- **Reinstalar / reparar / atualizar:** rode o mesmo setup (ou um mais novo) de novo. O `AppId` é fixo
  (`{FA4F41D9-F23B-4C34-8186-DCBB5DD86E45}`): ele reaproveita a pasta, os componentes e as tarefas da vez
  anterior e substitui todos os arquivos (`ignoreversion`; os binários têm todos a versão 2.5.0.<Build> de `tools\versao.ini`).
  Desmarcar o expert ou a tarefa da IA numa reinstalação **desfaz** o registro/a gravação correspondentes.
- **Desinstalar:** Painel de Controle → Programas → "JEDI VCS 2.5 Beta 2026", ou o atalho no Menu
  Iniciar, ou `unins000.exe` na pasta. Feche o Delphi antes.
- Silencioso: `JediVCS-2.5.0-Beta6-build2060-Setup.exe /VERYSILENT /SUPPRESSMSGBOXES [/CURRENTUSER] [/DIR=...]
  [/COMPONENTS=client,ide,ideold\bds10,ideold\bds21,maps,ai] [/TASKS=desktopicon,aiconsole] [/LOG=arquivo]`;
  os nomes das IDEs antigas são `ideold\d7` e `ideold\bds<n>` (n = 1…12, 14…21). Sem `/COMPONENTS`, a
  reinstalação repete a seleção da vez anterior;
  `unins000.exe /VERYSILENT /SUPPRESSMSGBOXES`. Com o Delphi aberto, o silencioso **aborta**
  (setup: código 7; desinstalação: código 1) sem mudar nada.

## 3. Componentes e tarefas

Tudo marcado por padrão. A tarefa "Usar o console novo na IA" vem marcada desde o beta 6 (até o beta 5
vinha desmarcada).

| Componente / tarefa | Instala ou faz |
|---|---|
| **Cliente** (`client`) | `Jedivcs.exe`, `JEDIVCSDiff.exe`, `jvcs.exe`, `fvcscrypt.dll`, `jedivcs.chm`, `jedivcsdiff.chm`, `htm_rep.htm`, `ffdef.jvcs`, `ulist.jvcs`, `vcllist.jvcs`, `vcllistbcb.jvcs`, `verinf.jvcs`, `license.txt`. Menu Iniciar → "JEDI VCS 2026": cliente, Diff, as duas ajudas e desinstalar |
| tarefa `desktopicon` | Atalho "JEDI VCS 2026" na área de trabalho |
| **Expert** (`ide`) | `JvcsExpertBDS<nn>.dll` + `JvcsExternalDll.dll` (e o runtime acima, que a DLL procura na própria pasta, inclusive o `JEDIVCSDiff.exe` do Compare). Registra o expert nas IDEs detectadas (seção 4) |
| **IDEs antigas** (`ideold`, com subcomponentes `ideold\d7`, `ideold\bds1` … `ideold\bds21`) | Aparece só se alguma IDE antiga for detectada, com um subcomponente por IDE detectada (todos marcados). Instala o `JvcsExpertD7.dll`/`JvcsExpertBDS<n>.dll` **original** 2.5.0.1030 de cada IDE marcada, mais a `JvcsExternalDll.dll` **nova** e o runtime, e registra o expert na IDE (seção 4A) |
| **.map** (`maps`) | `Jedivcs.map` e `JvcsExternalDll.map` ao lado dos módulos: o log de erros (`%LOCALAPPDATA%\JEDI\JVCS\logs\jvcs-exe|dll-*.log`, JclDebug) passa a mostrar unit/rotina/linha. ~14 MB cada sem compressão, poucos MB no setup (texto comprime bem). Diff, console e expert não usam `.map` |
| **Ferramentas da IA** (`ai`) | `tools\ai` inteiro em `{app}\tools\ai`, byte a byte (os `.ps1` continuam UTF-8 com BOM e CRLF). Menu Iniciar: atalho para a pasta. Para usar num projeto: `{app}\tools\ai\instalar-no-projeto.ps1 -ProjectDir ...` (ver `tools\ai\LEIAME.md`). Também instala a **skill distribuível** nos dois idiomas, `skills\pt\jedi-vcs` e `skills\en\jedi-vcs` (SKILL.md, README.md, `references\`, `scripts\`), byte a byte, em `{app}\tools\ai\skills\pt\jedi-vcs` e `{app}\tools\ai\skills\en\jedi-vcs`; numa atualização, a pasta antiga `{app}\tools\ai\skills\jedi-vcs` (beta 4) é removida (ver "Skill do Claude Code" abaixo) |
| tarefa `aiconsole` (marcada desde o beta 6) | Grava `jvcsExe={app}\jvcs.exe` na seção `[ai]` de `%APPDATA%\JEDI\JVCS\config.ini`, com o mesmo algoritmo do `jvcs-ai.ps1 config set` (UTF-8 com BOM, CRLF, resto do arquivo preservado; `checkout=`/`checkin=` intactos). O valor anterior é guardado e volta na desinstalação (ou se a tarefa for desmarcada numa reinstalação); se o `config.ini` foi criado pelo instalador e ficou vazio, ele é apagado. Numa **atualização** de uma versão anterior ao build 2060 (betas 1 a 5, em que a tarefa vinha desmarcada e o Inno reaproveitaria essa escolha), ela é marcada uma vez ao entrar na página de tarefas, e pode ser desmarcada ali (voltar e avançar não a marca de novo). Com `/TASKS=`, `/MERGETASKS=` ou `/LOADINF=` na linha de comando, vale o que foi pedido. A atualização é reconhecida pela entrada de desinstalação (a mesma de onde o Inno tira as tarefas anteriores): a partir do beta 6, ela guarda o valor `AiTaskBuild`, e por isso a regra vale mesmo se a pasta mudar |

**Skill do Claude Code:** o instalador **não** copia a skill para o perfil do usuário. Para que o Claude
Code a use em todos os projetos, copie a pasta de **um** idioma (as duas se chamam `jedi-vcs`; feche o Claude
Code antes):

```
robocopy "C:\Program Files (x86)\JEDI\JVCS 2026\tools\ai\skills\pt\jedi-vcs" "%USERPROFILE%\.claude\skills\jedi-vcs" /E
rem em inglês: ...\tools\ai\skills\en\jedi-vcs
```

Troque o caminho de origem se instalou em outra pasta; com `/CURRENTUSER` ele fica em
`%LOCALAPPDATA%\Programs\JEDI\JVCS 2026`. Para usar a skill só num projeto, copie a pasta para
`<projeto>\.claude\skills\jedi-vcs`. A desinstalação não mexe nessas cópias.

**Não instalados de propósito:** `.drc`, `.dcu`, `zipdll.dll`/`unzdll.dll` (DelZip, trocado pelo
Abbrevia; só o About as listava, e nenhum expert original as usa), `borlndmm.dll` (sem ShareMem),
`JvcsVcsManagerD5.dll`/`JvcsVcsManagerD6.dll` (não são experts finos: cada uma é o cliente 2.5.0.1030
inteiro para Delphi/C++Builder 5 e 6 e não usa a DLL nova; para essas IDEs, use o instalador original), o `jedivcsdiff.exe` 2.5.0.1030 que o
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
desinstalar, se houver um `bds.exe` ou `delphi32.exe` (Delphi 7) rodando (WMI, e janela `TAppBuilder`
como reserva), o setup pede para fechar (Repetir/Cancelar). A IDE regrava `Experts` ao fechar e prende a
DLL do expert.

## 4A. IDEs antigas: expert original + núcleo novo

O JEDI VCS 2.5.0.1030 suportava Delphi 7 e BDS 1.0 a 21.0 (10.4 Sydney) com experts **finos**. Esses
experts só fazem a ponte com a ToolsAPI e carregam a `JvcsExternalDll.dll` da própria pasta, pela ABI de
4 exports (`JEDIVCSDLLINIT`/`FINALIZE`/`HISTORYINIT`/`OPERATIONINIT`), 24 callbacks e `PAnsiChar`. A
`JvcsExternalDll.dll` 2.5.0.2026 mantém essa ABI. Por isso o instalador põe o expert **original** de
cada IDE antiga ao lado da DLL **nova** em `{app}`, e essas IDEs passam a usar o cliente 2026. Os
binários, a origem, o SHA-256 e a licença estão em `3rdparty\experts-originais-2.5.0.1030\LEIAME.md`.

| IDE | Arquivo | Chave (HKCU), valor `JVCSIDEClient` |
|---|---|---|
| Delphi 7 | `JvcsExpertD7.dll` | `Software\Borland\Delphi\7.0\Experts` |
| C#Builder 1.0, Delphi 8, 2005, 2006, 2007 (BDS 1.0–5.0) | `JvcsExpertBDS1…5.dll` | `Software\Borland\BDS\<n>.0\Experts` |
| Delphi 2009, 2010 (BDS 6.0–7.0) | `JvcsExpertBDS6/7.dll` | `Software\CodeGear\BDS\<n>.0\Experts` |
| XE a 10.4 Sydney (BDS 8.0–12.0, 14.0–21.0) | `JvcsExpertBDS8…21.dll` | `Software\Embarcadero\BDS\<n>.0\Experts` |

As chaves e o nome do valor são **os mesmos do instalador original**, conferidos no `unins000.dat`
dele.

1. **Detecção:** a IDE conta como instalada se `HKCU` ou `HKLM` (32 bits, `WOW6432Node`), na chave
   acima sem o `\Experts`, tem `App` apontando para um executável existente, ou, na falta dele,
   `RootDir` com `bin\bds.exe` ou `bin\delphi32.exe`. Só as IDEs detectadas aparecem como
   subcomponentes de "IDEs antigas" (todas marcadas). Se nenhuma for detectada, o componente nem
   aparece.
2. **Arquivos:** para cada IDE marcada, o expert original correspondente vai para `{app}`, junto com a
   `JvcsExternalDll.dll` nova, `fvcscrypt.dll`, `*.jvcs`, `htm_rep.htm`, `*.chm` e `JEDIVCSDiff.exe` (o
   Diff portado; a DLL o procura como `jedivcsdiff.exe` na própria pasta). Não há outros arquivos
   (seção 3, "Não instalados").
3. **Registro:** valem as mesmas regras da seção 4. Se `HKCU\<chave da IDE>` não existe (IDE nunca
   aberta por este usuário), o setup não registra e avisa. O valor anterior (por exemplo, o
   `C:\Program Files (x86)\JEDI\JVCS\JvcsExpertBDS10.dll` do original) é guardado em
   `jvcs2026-setup.ini` (`old.<id>.*`) e **restaurado na desinstalação**. Desmarcar uma IDE numa
   reinstalação desfaz o registro dela. Nada é gravado em `Experts x64`.
4. A pasta desta versão contém `JvcsExpertBDS21.dll`/`JvcsExpertD7.dll`, mas não é confundida com a do
   JEDI VCS original: a recusa de pasta (seção 2) ignora uma pasta cuja `JvcsExternalDll.dll` ou cujo
   `jedivcs.exe` é 2.5.0.<build ≥ 2000> (2.5.0.2026 das betas 1–4, 2.5.0.2050 da beta 5, ...).

**Suporte por versão** (13/10/2026):

| IDE | Instalador (arquivos + registro) | Expert original + DLL nova numa IDE real |
|---|---|---|
| Delphi 7, 2007, XE3, 10.4 | testado com chaves falsas (seção 6) | **não testado** |
| Demais (C#Builder 1, Delphi 8, 2005, 2006, 2009, 2010, XE, XE2, XE4–XE8, 10–10.3) | mesmo código, não exercitado | **não testado** |
| Delphi 11/12/13 | expert **novo** (seção 4), não usa os originais | ver `doc\pt\client\Port-DLL-IDE.md` |

O teste da ABI fora da IDE (`src\jvcsideexpert\tests\testar-dll.bat nova`) passou com a DLL do pacote.
O teste real (XE3 em outro PC) está em `doc\pt\client\Port-DLL-IDE.md`, seção 5B.

Limitações herdadas do expert original, que a DLL nova não corrige:

- O conteúdo do editor chega em UTF-8 cru nas IDEs Unicode (2009+), afetando acentos na expansão de
  keywords.
- Os buffers de nomes têm 256 bytes.
- A DLL não recebe o tema da IDE (`JVCS_IDE_THEME` só vem do expert novo).

## 5. Convivência

- **JEDI VCS original** (`C:\Program Files (x86)\JEDI\JVCS`, cliente 2.5.0.1030 e servidor de teste):
  não é tocado. Os dois clientes podem ficar instalados; os atalhos novos têm "2026" no nome.
- **`HKCU\Software\JEDI\JEDIVCS`** (identidades, senhas, opções): nunca é lido nem gravado pelo
  instalador nem pela desinstalação. Ele é compartilhado entre o cliente original e o novo.
- **Expert de desenvolvimento** (`bin\ideclient\Win32`): o setup troca o `JVCSIDEClient` para a pasta
  instalada e devolve o valor de desenvolvimento ao desinstalar. Para voltar ao de desenvolvimento sem
  desinstalar: rode o setup de novo desmarcando o Expert, ou importe `Delphi13-JVCS-DLL-nova.reg`
  (Delphi fechado).
- **Automação por IA:** com a tarefa `aiconsole` (padrão desde o beta 6), o wrapper usa o `jvcs.exe`
  2026 desta instalação, que tem os comandos novos (`add`, `addproject`, `history`, labels, bugs, ToDo,
  administração etc.). Sem a tarefa, o wrapper continua com o `jvcs.exe` que estiver no
  `config.ini` (padrão: o original 2.5.0.1030, sem esses comandos). O `jvcs.exe` novo tem `OriginalFilename=jvcs.exe` e
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

### 6.1 IDEs antigas e skill (13/10/2026)

Há um terceiro parâmetro **só para teste**, `/OLDIDEROOT=Software\<chave de teste>`. Ele troca o
`Software` do início das chaves das IDEs antigas (`<raiz>\Borland\Delphi\7.0`,
`<raiz>\Borland|CodeGear|Embarcadero\BDS\<n>.0`), tanto em HKCU quanto em HKLM. A desinstalação usa a
chave guardada no `jvcs2026-setup.ini`.

O roteiro `teste-ideold.ps1` (scratchpad da sessão) roda o setup gerado com `--sem-build` em modo
silencioso, com `/CURRENTUSER`, numa pasta do scratchpad, com `/BDSKEY` e `/OLDIDEROOT` em
`HKCU\Software\JVCS2026Teste` e `/AICONFIG` no scratchpad. Ele cria estas IDEs falsas (`App`/`RootDir`
apontando para arquivos vazios do scratchpad):

- **XE3** (`Embarcadero\BDS\10.0`): `JVCSIDEClient` do original
  `C:\Program Files (x86)\JEDI\JVCS\JvcsExpertBDS10.dll` e mais um valor `OutroExpert`;
- **10.4** (`Embarcadero\BDS\21.0`): sem `Experts`;
- **2007** (`Borland\BDS\5.0`): `JVCSIDEClient` do original;
- **Delphi 7** (`Borland\Delphi\7.0`): só `RootDir` com `Bin\delphi32.exe`;
- **2010** (`CodeGear\BDS\7.0`): `App` apontando para um arquivo inexistente.

Resultado: **43 verificações, 0 falhas**.

| Cenário | Resultado |
|---|---|
| `delphi32.exe` rodando (cópia renomeada do `ping.exe`) | setup abortado (código 7), nada instalado, registro intacto |
| Instalação completa | `JvcsExpertBDS10/21/5.dll` e `JvcsExpertD7.dll` copiados, com hash igual ao de `3rdparty`; `JvcsExpertBDS7.dll` **não** copiado (2010 não detectado); `JvcsExternalDll.dll` nova e runtime na pasta; sem `zipdll`/`borlndmm` |
| Registro | XE3 e 2007 → `{app}\JvcsExpertBDS<n>.dll`, com o valor anterior guardado (`old.<id>.prev`); 10.4 e D7 criados; `OutroExpert` intacto; nada na chave do 2010 nem em `Experts x64` |
| Skill | os 6 arquivos de `skills\pt\jedi-vcs` e os 6 de `skills\en\jedi-vcs` em `{app}\tools\ai\skills\pt\jedi-vcs` e `{app}\tools\ai\skills\en\jedi-vcs`, byte a byte; nada copiado para `%USERPROFILE%\.claude\skills` |
| Reinstalar com `/COMPONENTS=…` sem `ideold\bds21` | `JVCSIDEClient` do 10.4 removido; XE3 continua registrado e o valor anterior dele não se perde |
| Reinstalar na mesma pasta (com `JvcsExpertBDS21.dll`) sem `/COMPONENTS` | aceito; repete a seleção anterior (10.4 continua fora); com `/COMPONENTS` incluindo `ideold\bds21`, o 10.4 volta a ser registrado |
| Desinstalar | XE3 e 2007 voltam ao expert **original** 2.5.0.1030; 10.4 e D7 removidos; `OutroExpert` intacto; arquivos removidos |
| Registro real | `HKCU\Software\Embarcadero` exportado antes e depois: **idêntico**; `HKCU\Software\Borland`/`CodeGear` não criados |

`tools\gerar-instalador.bat` com um hash alterado no `SHA256SUMS.txt`: `[FALHOU] experts originais
2.5.0.1030 ...: ERRO JvcsExpertD7.dll`, código 1, instalador não gerado.

**Skills por idioma (13/10/2026):** setup gerado com `--sem-build` (log do ISCC sem erro), instalado em
silêncio com `/CURRENTUSER /DIR=<scratchpad> /COMPONENTS="client,ai"`, `/AICONFIG`, `/BDSKEY` e
`/OLDIDEROOT` numa chave de teste: `tools\ai\skills\pt\jedi-vcs` e `tools\ai\skills\en\jedi-vcs` com hash
igual ao do repositório; reinstalado por cima de uma pasta `tools\ai\skills\jedi-vcs` simulada (beta 4),
que o `[InstallDelete]` removeu; desinstalado sem sobras (pasta, entrada de desinstalação e chave de teste).

### 6.2 Tarefa `aiconsole` e atualização (17/10/2026, beta 6)

Roteiro `teste-beta6.ps1` (scratchpad da sessão), no mesmo esquema da seção 6: instalação silenciosa com
`/CURRENTUSER`, pasta do scratchpad, `/BDSKEY`, `/OLDIDEROOT` e `/AICONFIG` numa cópia do `config.ini`
real. Usa o setup do beta 5 (`JediVCS-2.5.0-Beta5-build2050-Setup.exe`) para criar a instalação anterior.
Resultado com o setup final (SHA-256 `98D837B7…`): 40 verificações, 0 falhas.

| Cenário | Resultado |
|---|---|
| Beta 5 sem a tarefa → beta 6 por cima, sem `/TASKS` | tarefa marcada (log `tarefa aiconsole marcada`), `jvcsExe={app}\jvcs.exe`; `tools\ai` e skills iguais ao repositório |
| Reinstalar o beta 6 sem `/TASKS` | não força de novo (`AiTaskBuild=2060`); `jvcsExe` mantido |
| Reinstalar com `/TASKS=` e depois sem `/TASKS` | `jvcsExe` volta ao valor anterior (`config.ini` com o hash original); a escolha "desmarcada" é respeitada |
| `/MERGETASKS=aiconsole` e desinstalar | grava; a desinstalação restaura o `config.ini` (hash original) e remove os arquivos |
| Instalação nova | tarefa marcada pelo padrão, sem forçar |
| Beta 5 numa pasta → beta 6 em outra pasta | tarefa marcada; `jvcsExe` aponta para a pasta nova |
| Beta 5 → beta 6 com `/LOADINF` (`Tasks=`) | não força; vale o `.inf` |

Instalação real pelo Explorer, para todos os usuários (UAC), por cima do beta 5: tarefa marcada,
`config.ini` com `jvcsExe=C:\Program Files (x86)\JEDI\JVCS 2026\jvcs.exe`, e o expert 2.5.0.2060 carregado
dessa pasta no Delphi 11.3, 12 e 13.2 (log do expert, menu com 27 itens).

## Escolha por Delphi

Na página de componentes, **cada Delphi instalado aparece como uma opção**: o 11, o 12 e o 13 dentro de *Expert para o Delphi*
e as versões antigas (Delphi 7 a 10.4) dentro de *IDEs antigas*. Só os marcados recebem o expert; uma IDE desmarcada numa
reinstalação tem o registro desfeito. Em instalação silenciosa use `/COMPONENTS`, por exemplo
`/COMPONENTS="client,ide\bds23,ideold\bds10"` (Delphi 12 e XE3).
