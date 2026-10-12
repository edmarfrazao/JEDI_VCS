# Credenciais do JEDI VCS — diagnóstico e recomendação (como o Git, de forma segura)

Pedido do usuário (12/10/2026): "a senha poderia ser igual faz com git que fica em um arquivo na pasta do usuário — analise opções,
boas práticas, segurança, algo profissional". Análise somente leitura do código da v2026 e do servidor 2.5; nada foi alterado.

## Resumo
- **Hoje:** a GUI e a DLL da IDE gravam a senha em `HKCU\Software\JEDI\JEDIVCS\Identities\<identidade>\Password` só em **Base64**
  (codificação, não criptografia = texto puro). O console aceita `/password` na linha de comando.
- **O cliente precisa da senha em claro** a cada login: `fvcs_Encrypt2(senha, hora do servidor)`. Guardar um derivado não serve.
  A saída profissional é guardar a senha **protegida pelo sistema operacional**.
- **Recomendação:**
  - senha no **Gerenciador de Credenciais do Windows** (credencial genérica) — mesmo modelo do Git Credential Manager e do `gh`;
  - arquivo de configuração por usuário (como o `~/.gitconfig`) com **só** servidor, usuário e preferências — **nunca a senha**;
  - comandos `jvcs login`, `jvcs logout`, `jvcs credential ...`; senha na linha de comando **proibida** por padrão;
  - CI: `--password-stdin` ou `JVCS_PASSWORD_FILE`; IA: **usuário JVCS próprio** com poucos direitos, que nunca vê a senha.
- **Achados que mudam o desenho:**
  - servidor sem branching: novo LOGIN do mesmo usuário **derruba a sessão anterior** (`DELETE FROM transact WHERE accessid`,
    `SrvOBJMain.pas:506-520`) → GUI, CLI e IA com o mesmo usuário se derrubariam;
  - o servidor guarda senhas de forma **reversível** (`fvcsSrvDeCrypt`) → senha do JVCS nunca igual à do Windows/AD;
  - o tráfego não é cifrado; o LOGIN cifrado vale ~1 minuto (replay);
  - `Winapi.WinCred` do Delphi 13 declara `_CREDENTIALW.Comment` como `LPSTR` (deveria ser `LPWSTR`) — usar cast.

## (a) Como o cliente guarda a senha hoje
**GUI e DLL** (`src\jedivcs\Create.pas`, `VCSBase.pas:138,148,156`, `Create.pas:1194-1310`):
```
HKCU\Software\JEDI\JEDIVCS
  UseRegistry, CurrentServer, CurrentPort, BaseRegistryKey ...
  \Options        SavePassword, Autologin, EncodeKey (Base64), SrvTimeOut ...
  \Identities     ID0..IDn, LastUsedID
  \Identities\<Nome>   HostName, Port, User, Password (Base64)
```
- Gravação (`Create.pas:1300-1301`) só com "Store Password with identity" marcado: `Base64Encode(pwUserPasswordEdit.Text)`.
- Leitura (`Create.pas:1236-1239`): `Base64Decode` direto para o campo. Os autores já avisavam do risco (`Create.pas:1314-1331`).
- `Base64Encode` vem da `BFCrypt` (ausente no fonte; recuperada em `doc\client\Algoritmos-Recuperados.md`: Base64 sobre bytes ANSI).
- Não existe "Auto submit passwords"; os reais são `cbSavePW` (`Options\SavePassword`) e `cbAutologin` (`Options\Autologin`,
  `Create.pas:386-402`, timer que clica em Abrir).
- Modo INI (`UseRegistry=False`, `Options.pas:1912-1916`): tudo em `JVCS.ini` **na pasta do programa** (`ConfigStorage.pas:131-138`)
  — em `Program Files` qualquer usuário local lê (ou caiu no VirtualStore).
- A chave Blowfish dos módulos (`EncodeKey`) também fica em Base64 (`Options.pas:788-791,1857`, `ChkInSingle.pas:1187`, `HandleBlob.pas:143`).
- Login (`Create.pas:509-533`): `GET_SERVER_TIME` → `fvcsCliEncrypt2(Senha, ServerTime)` (ShortString ANSI ≤255; `JVCSCrypt.pas:107`
  subtrai 1 s) → `LOGIN [usuário, senha cifrada, versão, GetNowUTC]`. `TJVCSConnection.FUserPassword` fica na memória a conexão inteira.

**Console** (`src\jvcs\jvcs.dpr`): `/user` e `/password` de `ParamStr` (`:585-598`), incentivado pela doc. Peças boas já existentes:
`ReadPassword` sem eco (`:3366-3413`) e senha lida da entrada redirecionada (`:3673-3681`). Não lê as identidades do registro.

**Servidor 2.5** (`Fontes_JediVCS_2.5\Jedi VCS Server\2.5\`): senha cifrada vale ~1 min (`SrvOBJMain.pas:277-282`); compara com
`fvcsCryptCompare` (armazenamento reversível, `ServerCryptInt.pas:56-57`); build sem branching = uma sessão por usuário; com branching
há lista de sessões (`JVCSSrvOBJBranches.pas:10856`) — **confirmar qual build está instalado**; `LocalLogin` deixa 127.0.0.1 entrar
sem senha (padrão desligado, `SrvServiceUnit.pas:644`). `FVCSCrypt.dll` só 32 bits; Credential Manager/DPAPI funcionam em 32 e 64.

**Riscos atuais:** Base64 = texto puro (CWE-261: qualquer processo do usuário, admins, backups, `NTUSER.DAT`, `reg export`); modo INI
legível por todos; senha na linha de comando (CWE-214: Gerenciador de Tarefas, WMI, EDR, evento 4688, histórico do shell, **transcrição
do Claude Code** e contexto do modelo); Autologin com senha gravada; exposição antiga → **trocar a senha** após migrar.

## (b) Opções de armazenamento
| Opção | Proteção | Quem lê | Compartilha GUI/IDE/CLI | Esforço | Veredito |
|---|---|---|---|---|---|
| `/password` na linha de comando | nenhuma | processos, 4688, EDR, histórico, IA | não | zero | **Proibir** (escape explícito p/ legado) |
| Texto puro estilo `git credential-store` | só ACL | usuário, admins, backups | sim | muito baixo | Rejeitar |
| Registro em Base64 (atual) | nenhuma | idem + todos no modo INI | sim | zero | **Migrar e apagar** |
| DPAPI em arquivo (`%LOCALAPPDATA%\JEDI\JVCS\credentials.dat`) | chave do usuário + MAC | processos do usuário | sim | baixo/médio (RTL não declara a API) | **Reserva** (SSH, sem cofre) |
| **Gerenciador de Credenciais (genérica)** | cofre do SO | processos do usuário; visível no Painel/`cmdkey` | **sim, nativo** | **baixo** (`Winapi.WinCred`) | **Principal** |
| Helper externo (protocolo do Git) | depende do cofre (KeePassXC, 1Password…) | pode exigir aprovação | sim | médio | Opcional |
| `JVCS_PASSWORD` | nenhuma | usuário, filhos, dumps | não | trivial | **Só CI**, melhor `--password-stdin`/`JVCS_PASSWORD_FILE` |
| Prompt sem eco | memória | — | — | já existe | Último recurso |

O Gerenciador de Credenciais vence: é o 1º na ordem de preferência da Microsoft ("Handling Passwords"), o usuário vê/apaga pelo Painel
ou `cmdkey`, tem escopos sessão/máquina/perfil móvel e é o padrão do Git Credential Manager (`git:https://host`). Limite: não funciona em
logon de rede (SSH) → `ERROR_NO_SUCH_LOGON_SESSION` → cair para DPAPI/stdin.

## (c) Recomendação
### c.1 Camadas
```
config do usuário (sem segredo)  ->  resolvedor de credencial  ->  armazenamento
%APPDATA%\JEDI\JVCS\config.ini        JVCSCredentials.pas            1) Gerenciador de Credenciais (padrão)
.jvcs\config.ini (por projeto)        ordem fixa, auditoria          2) DPAPI em arquivo (reserva)
políticas em HKLM\...\Policies                                       3) helper externo (opcional)
GUI, DLL da IDE e jvcs.exe usam a MESMA unit, o MESMO TargetName e o MESMO config.
```

### c.2 Arquivo de configuração por usuário (sem senha)
`%APPDATA%\JEDI\JVCS\config.ini` (UTF-8, `TMemIniFile`; roama sem risco). Logs e reserva DPAPI em `%LOCALAPPDATA%\JEDI\JVCS\`.
Override: `JVCS_CONFIG` / `--config`.
```ini
; %APPDATA%\JEDI\JVCS\config.ini  -- NUNCA contém senha
[core]
defaultProfile = producao

[credential]
store   = wincred        ; wincred | dpapi | helper | none
persist = local          ; session | local | enterprise
maxAgeDays = 180

[profile "producao"]
server = vcsserver.empresa.local
port   = 2106
user   = edmar

[profile "ia"]
server = vcsserver.empresa.local
port   = 2106
user   = edmar.ia        ; usuário JVCS exclusivo da IA, poucos direitos
agentAllowed = true

[agent]
allowPrompt = false
requireConfirmation = checkin,undocheckout,remove
```
Por projeto: `<working copy>\.jvcs\config.ini` só com `project=` e `profile=` (o Claude Code na pasta do projeto acha o servidor).
Regras: o carregador recusa chaves `password/secret/token/key`; verifica o dono do arquivo (um helper configurado executa código);
políticas corporativas em `HKLM\SOFTWARE\Policies\JEDI\JVCS` (`CredentialStore`, `AllowPersist`, `AllowPasswordArgument=0`, `AllowEnvPassword`).

### c.3 Credencial no Windows
- `CRED_TYPE_GENERIC`, TargetName `JEDIVCS:jvcs://<user>@<host>:<port>` (ex.: `JEDIVCS:jvcs://edmar@vcsserver.empresa.local:2106`),
  sempre derivado do **perfil** (host minúsculo, porta explícita) — usuário no nome permite você e a IA no mesmo servidor.
- `UserName`, `Comment` ("JEDI VCS 2.5 – perfil producao"), atributos `JEDIVCS_Version=1`, `JEDIVCS_Profile`, `JEDIVCS_ExpiresUtc`.
- Blob: senha UTF-16LE sem terminador (≤2560 bytes) — formato do `cmdkey`, permitindo
  `cmdkey /generic:"JEDIVCS:jvcs://edmar@vcsserver:2106" /user:edmar` (confirmar na F2).
- Persist: `LOCAL_MACHINE` (padrão), `ENTERPRISE` (perfil móvel), `SESSION` (máquina compartilhada).
- No login: UTF-16 → ANSI com `WideCharToMultiByte(CP_ACP, WC_NO_BEST_FIT_CHARS, …)`; recusar caractere sem representação ou >255 bytes.

### c.4 Ordem de resolução da senha
1. `--password` na linha de comando: **recusado** (código 2), só com `JVCS_ALLOW_INSECURE_PASSWORD_ARG=1` e se a política permitir, com aviso.
2. `--password-stdin` (padrão de CI, como `docker login`).
3. `JVCS_PASSWORD_FILE`, depois `JVCS_PASSWORD` (só CI; aviso se detectar agente: `AI_AGENT`, `CLAUDECODE=1`, `CLAUDE_CODE_SESSION_ID`).
4. Armazenamentos: `wincred` → `dpapi` → helper (protocolo do Git `get/store/erase`); para no primeiro válido.
5. Prompt sem eco só com console, sem `--non-interactive` e fora de agente (opção `--gui`: `CredUIPromptForWindowsCredentials`).
6. Falha → código `AUTH_REQUIRED`: "execute `jvcs login --profile X` em um terminal seu".
Aprovar/rejeitar como o Git: login ok atualiza `JEDIVCS_LastVerified`; "Invalid Password" (`SrvOBJMain.pas:490`) apaga/pergunta.

### c.5 Comandos da CLI
| Comando | O que faz |
|---|---|
| `jvcs login [--profile P] [--server h:p --user U] [--gui] [--password-stdin] [--persist …] [--no-verify]` | pede a senha, testa e grava (`--no-verify` evita derrubar a sessão da GUI) |
| `jvcs logout [--profile P \| --all]` | apaga a credencial |
| `jvcs auth status` | perfil, servidor, usuário, origem da credencial, validade — **nunca a senha** |
| `jvcs credential list / remove / test / migrate [--dry-run]` | gerencia e migra o legado |
| `jvcs config get\|set\|unset\|list [--global\|--project]` | recusa chaves sensíveis |
Não implementar comando que imprima a senha.

### c.6 API Delphi (`src\common\client\JVCSCredentials.pas` + `JVCSConfig.pas`, sem VCL)
```pascal
type
  TJVCSPersist = (cpSession, cpLocalMachine, cpEnterprise);
  TJVCSCredSource = (csNone, csStdin, csEnvFile, csEnv, csWinCred, csDpapi, csHelper, csPrompt);
  TJVCSCredentialKey = record
    Host: string; Port: Word; User: string; Profile: string;
    function TargetName: string;                 // 'JEDIVCS:jvcs://user@host:port'
    class function FromProfile(const AProfile: string): TJVCSCredentialKey; static;
  end;
  TJVCSSecret = record                           // UTF-16 em TBytes; zerado após uso
    procedure Assign(const P: PWideChar; Len: Integer);
    function ToLegacyAnsi(out S: ShortString): Boolean; // CP_ACP, WC_NO_BEST_FIT_CHARS, <=255
    procedure Clear;
  end;
  IJVCSCredentialStore = interface
    function TryGet(const K: TJVCSCredentialKey; out S: TJVCSSecret): Boolean;
    procedure Store(const K: TJVCSCredentialKey; const S: TJVCSSecret; P: TJVCSPersist);
    function Erase(const K: TJVCSCredentialKey): Boolean;
    function List: TArray<TJVCSCredentialInfo>;
  end; // TWinCredStore, TDpapiFileStore, THelperStore
  TJVCSCredentialResolver = class
    function Resolve(const K: TJVCSCredentialKey; const Opt: TResolveOptions;
      out S: TJVCSSecret; out Source: TJVCSCredSource): Boolean;
    procedure Approve(const K: TJVCSCredentialKey);
    procedure Reject(const K: TJVCSCredentialKey);
  end;
function JVCSAgentContextDetected: Boolean;
function JVCSMigrateLegacyIdentities(DryRun: Boolean; out Report: string): Integer;
```
Cuidados: cast no `Comment` (defeito em `Winapi.WinCred.pas:464`); `CredFree` em `try/finally`; `ERROR_NOT_FOUND` não é erro;
`ERROR_NO_SUCH_LOGON_SESSION` → próxima opção; DPAPI declarado à mão (`crypt32.dll`, `CRYPTPROTECT_UI_FORBIDDEN`, entropia = constante +
TargetName, nunca `LOCAL_MACHINE`, `LocalFree`, DACL dono+SYSTEM); zerar a senha logo após o login (hoje `FUserPassword` fica a conexão inteira).

### c.7 GUI/IDE: compartilhamento e migração do legado
- Os três clientes calculam o mesmo TargetName pelo perfil; `CurrentServer/CurrentPort` vira "perfil atual".
- Tela de login: "Lembrar no Gerenciador de Credenciais do Windows", botão "Esquecer credencial"; Autologin usa o cofre.
- `jvcs credential migrate` (automático na 1ª execução): para cada identidade → perfil no `config.ini`; `Base64Decode` (UTF-16LE se os
  bytes ímpares forem zero, senão ANSI) → `CredWrite` → `CredRead` p/ conferir → **só então** `DeleteValue('Password')`; limpar `JVCS.ini`
  (inclusive VirtualStore); `EncodeKey` → `JEDIVCS:encodekey:<perfil>` **com backup obrigatório** (perdê-la torna módulos cifrados ilegíveis);
  auditoria sem segredo; avisar para **trocar a senha**. Cliente 2.5 antigo instalado volta a gravar Base64 → documentar/desinstalar.

### c.8 IA e MCP: usar o JVCS sem ver a senha
1. **Usuário JVCS próprio para a IA** (`edmar.ia`, direitos mínimos por projeto): histórico mostra quem fez cada check-in, menor privilégio,
   e evita IA e GUI derrubarem a sessão uma da outra.
2. MCP: `jvcs mcp serve --profile ia` (stdio); ferramentas sem parâmetro de senha (`status`, `list_projects`, `diff`, `get`, `checkout`,
   `checkin`, `undo_checkout`); credencial resolvida internamente com `allowPrompt=false`; sem credencial → `AUTH_REQUIRED`.
3. `.mcp.json` sem segredos.
4. `CLAUDE.md` do projeto: "nunca pedir nem aceitar a senha do JEDI VCS no chat".
5. Confirmação humana em camadas: regras `ask`/`deny` do Claude Code, p.ex.
   ```json
   "ask":  ["mcp__jvcs__checkin", "mcp__jvcs__undo_checkout", "Bash(jvcs checkin *)"],
   "deny": ["Bash(cmdkey *)", "PowerShell(cmdkey *)", "Bash(jvcs * /password *)"]
   ```
   + `[agent] requireConfirmation=checkin` no próprio jvcs (TaskDialog ou Windows Hello) + direitos do usuário `edmar.ia` no servidor
   (a única camada que o agente não contorna).
6. Limite honesto: qualquer processo do mesmo usuário Windows pode chamar `CredReadW`; se a ameaça for o próprio agente, rodá-lo em outra
   conta Windows/VM com só a credencial `edmar.ia`.

### c.9 Ambiente corporativo
`ENTERPRISE` roama com perfil móvel (opção, não padrão); reset de senha por admin em conta local invalida DPAPI/cofre → tratar como
"credencial ausente"; Credential Guard **não** protege credenciais genéricas; SSH: usar stdin/arquivo/DPAPI; UAC: `SESSION` não é
compartilhado entre token elevado e normal (`LOCAL_MACHINE` é); máquinas compartilhadas: `AllowPersist=session` via GPO e `jvcs logout --all`.

## (c.10) Modo compatível: a CLI/IA reaproveita a identidade já salva (proposta do usuário, 12/10/2026)
Uso real hoje: na tela **Server Login → Options** ficam marcados "Store Password with identity" e "Auto login"; a última identidade
(`Identities\LastUsedID`) já traz servidor, porta, usuário e senha, e ninguém digita nada. Nesta máquina: identidade `DEFAULT`,
`10.211.55.3:2106`, usuário `sysdba`, `SavePassword=1`, `Autologin=1`.

**Proposta:** a CLI (e o MCP) **não cria outro tipo de autenticação**: usa a **mesma identidade salva** que a GUI e a IDE usam.
- `jvcs <comando>` sem parâmetros de login → usa a identidade `LastUsedID`; `--identity <nome>` escolhe outra.
- O resolvedor da `JVCSCredentials.pas` ganha a fonte `csSavedIdentity` (lê `Identities\<nome>`: HostName, Port, User, Password).
- A CLI **nunca imprime** a senha; a IA só vê o nome da identidade.

**Já com os binários originais (antes do port):** o `jvcs.exe` 2.5.0.1030 não lê identidades, mas aceita a senha pela **entrada
padrão redirecionada** (`jvcs.dpr:3673-3681`). Um script pequeno (`tools\jvcs-identidade.ps1`) pode ler a identidade salva e passar a
senha por stdin ao `jvcs.exe` — sem senha na linha de comando, no histórico ou na transcrição da IA. Ex.: `jvcs-identidade.ps1 checkout Unit1.pas`.

**Evolução no port (mesma experiência, armazenamento seguro):** "Store Password with identity" passa a gravar no **Gerenciador de
Credenciais do Windows** (TargetName derivado da identidade) em vez de Base64 no registro. Para o usuário nada muda: escolhe a identidade
e conecta sem digitar. Durante a transição, opção de manter também o Base64 para clientes 2.5 antigos ainda instalados (desligada por padrão).

**Cuidados (validar na quinta, 15/10/2026):**
1. **Sessão única por usuário:** se o servidor for o build sem branching, a CLI/IA logando com o mesmo usuário da GUI **derruba a
   sessão da GUI** (e vice-versa). Testar: GUI conectada + `jvcs listprojects` com a mesma identidade. Se derrubar → identidade própria
   para a IA (continua sendo "identidade salva", só que outra).
2. **`sysdba` é administrador:** dar à IA a identidade `sysdba` dá a ela poder total (apagar projetos, usuários, labels). Recomendado:
   uma identidade salva separada, p.ex. `IA`, com um usuário de poucos direitos — mesma mecânica, sem autenticação nova.
3. **Rastreabilidade:** com a mesma identidade, o histórico do servidor não distingue você da IA; mitigação: prefixo automático
   `[IA]` no comentário do check-in feito pela CLI em contexto de agente.
4. **Segurança:** a senha em Base64 já é legível hoje por qualquer processo do usuário (inclusive a IA, se ela ler o registro);
   reaproveitar a identidade não aumenta essa exposição, mas também não a resolve — por isso a evolução para o Gerenciador de Credenciais.
   Regra no Claude Code: `deny` para `reg query`/`Get-ItemProperty` na chave `JEDI\JEDIVCS\Identities`.

## (d) Riscos residuais
1. Processo do mesmo usuário lê o cofre (malware, agente comprometido, plugin da IDE) → usuário separado para a IA, helper com aprovação.
2. Administrador/SYSTEM extrai segredos DPAPI → senha exclusiva do JVCS e rotação.
3. Rede sem cifra (replay ~1 min; `TANr` de 32 bits com `Random`) → VPN/IPsec/túnel TLS (stunnel) + `CheckIPAddr` no servidor.
4. Servidor guarda senhas reversíveis → nunca reutilizar senha do Windows/AD.
5. `LocalLogin` ligado dispensa senha para processos locais → auditar o INI do servidor.
6. Sessão única por usuário (sem branching) → usuários separados ou `--no-verify`; **testar qual build está em uso**.
7. Restos do legado (backups, perfis, VirtualStore, cliente 2.5 instalado) → trocar a senha.
8. Senha em memória (strings, `TEdit`, dumps) → zerar buffers, encurtar vida útil.
9. CI com variável de ambiente → `*_FILE` ou stdin, mascaramento.
10. Helper externo executa código via config → caminho absoluto, dono/ACL verificados.
11. Detecção de agente por variáveis é só indício.
12. Nomes divergentes (IP×DNS) e formato do blob × `cmdkey` → testes na F2.

## Fontes
- Git: [git-credential-store](https://git-scm.com/docs/git-credential-store), [git-credential](https://git-scm.com/docs/git-credential), [gitcredentials](https://git-scm.com/docs/gitcredentials); GCM: [credstores](https://github.com/git-ecosystem/git-credential-manager/blob/main/docs/credstores.md), [configuration](https://github.com/git-ecosystem/git-credential-manager/blob/main/docs/configuration.md)
- Outros CLIs: [gh auth login](https://cli.github.com/manual/gh_auth_login), [docker login](https://docs.docker.com/reference/cli/docker/login/), [docker-credential-helpers](https://github.com/docker/docker-credential-helpers)
- Microsoft: [CREDENTIALW](https://learn.microsoft.com/en-us/windows/win32/api/wincred/ns-wincred-credentialw), [CredWriteW](https://learn.microsoft.com/en-us/windows/win32/api/wincred/nf-wincred-credwritew), [CredReadW](https://learn.microsoft.com/en-us/windows/win32/api/wincred/nf-wincred-credreadw), [CredEnumerateW](https://learn.microsoft.com/en-us/windows/win32/api/wincred/nf-wincred-credenumeratew), [CREDENTIAL_ATTRIBUTEW](https://learn.microsoft.com/en-us/windows/win32/api/wincred/ns-wincred-credential_attributew), [cmdkey](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cmdkey), [CryptProtectData](https://learn.microsoft.com/en-us/windows/win32/api/dpapi/nf-dpapi-cryptprotectdata), [CryptProtectMemory](https://learn.microsoft.com/en-us/windows/win32/api/dpapi/nf-dpapi-cryptprotectmemory), [CryptUpdateProtectedState](https://learn.microsoft.com/en-us/windows/desktop/api/Dpapi/nf-dpapi-cryptupdateprotectedstate), [Handling Passwords](https://learn.microsoft.com/en-us/windows/win32/secbp/handling-passwords), [Credential Guard considerations](https://learn.microsoft.com/en-us/windows/security/identity-protection/credential-guard/considerations-known-issues), [Command line process auditing](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/component-updates/command-line-process-auditing), [about_PSReadLine](https://learn.microsoft.com/en-us/powershell/module/psreadline/about/about_psreadline)
- CWE: [CWE-214](https://cwe.mitre.org/data/definitions/214.html), [CWE-261](https://cwe.mitre.org/data/definitions/261.html)
- IA: [MCP Security Best Practices](https://modelcontextprotocol.io/specification/2025-06-18/basic/security_best_practices), [Claude Code permissions](https://code.claude.com/docs/en/permissions), [Claude Code settings](https://code.claude.com/docs/en/settings)
