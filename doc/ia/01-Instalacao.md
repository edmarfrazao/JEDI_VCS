# 01 - Instalação

Quatro passos: ter as ferramentas (`tools\ai`), ter uma identidade salva, instalar a integração no
projeto e aceitar a confiança da pasta no Claude Code. No fim, verifique com `identity` e `status`.

## 1. Ferramentas da IA

### Pelo instalador (recomendado)

No `JediVCS-2.5-Beta2026-Setup.exe`, deixe marcado o componente **Ferramentas da IA** (`ai`). Ele copia
`tools\ai` inteiro para:

| Instalação | Pasta |
|---|---|
| Para todos os usuários (padrão) | `C:\Program Files (x86)\JEDI\JVCS 2026\tools\ai` |
| Só para o usuário atual | `%LOCALAPPDATA%\Programs\JEDI\JVCS 2026\tools\ai` |

A tarefa opcional **"Usar o console novo na IA"** (`aiconsole`, desmarcada por padrão) grava
`jvcsExe=<pasta de instalação>\jvcs.exe` no `config.ini`. Sem ela, o wrapper usa o `jvcs.exe` que estiver
configurado (padrão: o console original em `C:\Program Files (x86)\JEDI\JVCS\jvcs.exe`). O valor
anterior volta na desinstalação.

Instalação silenciosa só com cliente e ferramentas da IA:

```text
JediVCS-2.5-Beta2026-Setup.exe /VERYSILENT /SUPPRESSMSGBOXES /COMPONENTS=client,ai /TASKS=aiconsole
```

### Manual (sem o instalador)

Copie a pasta `tools\ai` deste repositório para um lugar fixo (por exemplo `C:\Ferramentas\jvcs-ai`).
Copie **byte a byte** (Explorer, `robocopy` ou `git clone`): os `.ps1` são UTF-8 **com BOM** e CRLF, e
sem o BOM o Windows PowerShell 5.1 estraga as mensagens acentuadas.

Se o `jvcs.exe` não estiver no caminho padrão, informe-o (no **seu** terminal):

```powershell
& 'C:\Ferramentas\jvcs-ai\jvcs-ai.ps1' config set jvcsExe 'C:\caminho\do\jvcs.exe'
```

O wrapper só aceita um executável cujo recurso de versão diga `OriginalFilename=jvcs.exe` e um
`ProductName` com "JEDI" (o console recebe a senha).

## 2. Identidade salva

O wrapper não pede senha: usa a **identidade salva** do cliente JEDI VCS (a mesma da GUI e da IDE).

1. Abra o cliente JEDI VCS (standalone ou pela IDE) e vá em **Server Login**.
2. Escolha ou crie a identidade (servidor, porta, usuário), digite a senha e marque
   **Store Password with identity**.
3. Conecte uma vez.

Por padrão o wrapper usa a última identidade usada (`LastUsedID`). Para fixar outra:
`jvcs-ai.ps1 config set identity <nome>` (no seu terminal) ou `-Identity <nome>` por comando.

> Recomendação: para a IA, prefira uma identidade com um usuário JEDI VCS de poucos direitos (leitura
> geral, escrita só nos projetos liberados). Ver [05 - Segurança](05-Seguranca.md).

## 3. Instalar a integração no projeto (Claude Code)

Rode **no seu terminal** (a IA tem regra `deny` para o instalador):

```powershell
$i = 'C:\Program Files (x86)\JEDI\JVCS 2026\tools\ai\instalar-no-projeto.ps1'
& $i -ProjectDir 'C:\caminho\do\projeto'                      # hooks, regras e skill; não mexe no modo
& $i -ProjectDir 'C:\caminho\do\projeto' -Mode confirm        # e grava checkout=confirm, checkin=confirm
& $i -ProjectDir 'C:\caminho\do\projeto' -Mode auto -WhatIf   # só simula e mostra o settings resultante
& $i -ProjectDir 'C:\caminho\do\projeto' -Scope local         # grava em .claude\settings.local.json
```

| Opção | Efeito |
|---|---|
| `-Mode auto\|confirm\|manual` | grava `checkout` e `checkin` no `config.ini` (vale para todos os projetos do usuário). Sem `-Mode`, o modo não muda; sem nada gravado, vale `confirm` |
| `-CheckoutMode` / `-CheckinMode` | sobrepõem `-Mode` para cada operação |
| `-Scope project` (padrão) | grava em `<projeto>\.claude\settings.json` |
| `-Scope local` | grava em `<projeto>\.claude\settings.local.json` (só esta máquina). Use quando a pasta `.claude` for versionada: o settings leva caminhos absolutos desta máquina |
| `-AllowEditPreserve` | as edições pelo `edit-preserve.ps1` deixam de pedir aprovação |
| `-WhatIf` | não grava nada |

O instalador:

1. mescla hooks e regras no settings **sem apagar o que já existe** (guarda `settings*.json.bak-<data>`;
   pode rodar de novo);
2. copia a skill por projeto para `<projeto>\.claude\skills\jvcs\SKILL.md`, com os caminhos absolutos;
3. grava o modo no `config.ini` só se você passar `-Mode`/`-CheckoutMode`/`-CheckinMode`;
4. avisa se não achar `.dpr`/`.dpk`, o `jvcs.exe` ou uma identidade salva.

Use um projeto com nome próprio: o JEDI VCS recusa os nomes padrão do Delphi (`Project1`, `Package1`).

### Skill global (opcional)

Para ter o fluxo em qualquer projeto, sem hooks, instale a skill distribuível `jedi-vcs`
(ver [`skills/jedi-vcs/README.md`](../../skills/jedi-vcs/README.md)). Ela não substitui o instalador:
hooks e regras `allow`/`ask`/`deny` só vêm com `instalar-no-projeto.ps1`.

## 4. Confiança da pasta no Claude Code

Abra o projeto no Claude Code (`claude` na pasta do projeto, ou o app desktop) e **aceite a confiança da
pasta** quando ele perguntar. Hooks e regras `allow` do `.claude\settings.json` do projeto só valem
depois disso; as regras `deny` e `ask` valem sempre.

Se você recusou por engano, abra de novo e aceite, ou use `/permissions` para revisar.

## 5. Verificação

No terminal, dentro da pasta do projeto (troque o caminho do wrapper pelo seu):

```powershell
$w = 'C:\Program Files (x86)\JEDI\JVCS 2026\tools\ai\jvcs-ai.ps1'
& $w identity -Text            # identidade em uso (nunca mostra a senha)
& $w identity -Test -Text      # faz login de verdade
& $w config list -Text         # modos e de onde vem cada valor
& $w status -Text              # estado exato dos módulos do projeto
```

Resultado esperado (exemplo de 13/10/2026, valores pessoais trocados):

```text
[OK 0] identity
  name = DEFAULT
  host = servidor
  port = 2106
  user = usuario
  hasPassword = True
  source = LastUsedID=0
identidade 'DEFAULT': usuario@servidor:2106

[OK 0] status (exemplo01.dpr)
  #4 uprincipal.pas v0.14 local=clean -> ok
  #3 exemplo01.res v0.1 local=clean -> ok
  #2 exemplo01.dproj v0.1 local=clean -> ok
  #1 exemplo01.dpr v0.1 local=clean -> ok
4 módulo(s) em exemplo01.dpr
```

Se a pasta tiver mais de um `.dpr` (por exemplo uma cópia `Exemplo01 - Copia.dpr`), o `status` sem
argumento responde `[ERRO 2] informe -Project <nome.dpr>`; use `status -Project Exemplo01.dpr`.

Depois, no Claude Code: *"mostre o status do JEDI VCS deste projeto"*. A IA deve usar a skill e
responder com a tabela de módulos.
