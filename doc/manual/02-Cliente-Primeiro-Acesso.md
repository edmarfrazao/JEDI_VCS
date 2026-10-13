# 02. Cliente: primeiro acesso

Como conectar ao servidor pela primeira vez, trocar a senha padrão, criar usuários (você e a IA), entender os níveis de acesso e criar o primeiro projeto. Pré-requisito: servidor no ar ([capítulo 01](01-Servidor-Instalacao-e-Configuracao.md)).

## 1. Os três clientes

| Cliente | Arquivo | Uso |
|---|---|---|
| Standalone | `C:\Program Files (x86)\JEDI\JVCS\jedivcs.exe` (Menu Iniciar > JEDI VCS > Standalone GUI client) | Administração, projetos de qualquer tipo, usuários |
| IDE (expert) | Menu **JEDI VCS** no Delphi 13 ([capítulo 03](03-Integracao-com-o-Delphi.md)) | Dia a dia dentro do Delphi |
| Console | `C:\Program Files (x86)\JEDI\JVCS\jvcs.exe` ([capítulo 06](06-Linha-de-Comando.md)) | Scripts e build |

Os três usam o mesmo servidor e o mesmo banco.

> **Atenção:** o servidor permite **uma sessão por nome de usuário** ao mesmo tempo: um novo login do mesmo usuário derruba o anterior (ajuda: "you need to connect with two different user names"). Se você usa a IDE e o standalone ao mesmo tempo, use usuários diferentes. Se isso também vale para IDE + `jvcs.exe` neste servidor ainda será testado (item 5 da lista de testes em [Servidor-Teste-Local.md](../server/Servidor-Teste-Local.md)).

## 2. Primeiro login

1. Abra o `jedivcs.exe`. Na primeira vez aparece o aviso (disclaimer) do programa; aceite.
2. Abre a janela **Server Login**. Ela tem três abas.

### Aba "Application server"

| Campo | Para que serve | Valor no servidor de teste |
|---|---|---|
| **Identity** | Conjunto salvo de servidor + porta + usuário (+ senha opcional). Botões: **Add/Update Identity** (Ctrl+A) e **Remove Identity** (Ctrl+R). O nome não aceita `[`, `]` nem `\` e não diferencia maiúsculas | `DEFAULT` (criada pela instalação) |
| **Host** | IP ou nome do servidor. A ajuda recomenda **IP numérico** (cada pedido refaz a consulta DNS) | `192.168.0.10` |
| **Port** | Porta do servidor; precisa ser igual à do servidor | `2106` |
| **User** | Usuário do JEDI VCS (**diferencia maiúsculas**) | `sysdba` |
| **Password** | Senha (**diferencia maiúsculas**) | `admin` |
| Botão **Ping** (Ctrl+P) | Testa se o servidor responde | |
| Botão **Connect** | Conecta | |

> **Só no ambiente de teste:** `sysdba`/`admin` e o IP `192.168.0.10` valem para o servidor de teste. Troque a senha logo no primeiro acesso (seção 4).

Se o servidor e o cliente estão na mesma máquina, a ajuda manda usar o IP real da máquina, não `localhost`/`127.0.0.1`. (No teste de 12/10/2026 o `jvcs.exe` também conectou em `127.0.0.1:2106`.)

### Aba "Socks server"

Só preencha se a rede exigir proxy SOCKS: **Server**, **Port**, **Usercode**, **Password** e a caixa **Authenticate**. Na LAN, deixe em branco.

### Aba "Options"

| Opção | O que faz | Recomendação |
|---|---|---|
| **Store Password with identity** | Grava a senha junto da identidade, em `HKCU\Software\JEDI\JEDIVCS\Identities\<nome>\Password`, só em **Base64** (legível por qualquer processo seu). A ajuda também desaconselha | **Desmarque** em produção. Hoje a identidade `DEFAULT` desta máquina tem senha gravada (`SavePassword=1`). Detalhes na seção (a) do [Credenciais.md](../common/Credenciais.md) e no capítulo 07 |
| **Auto login local clients (Host = local IP)** | Conecta sem mostrar a tela. Segundo a ajuda só funciona com cliente e servidor na mesma máquina e com "Enable local login w/o password" ligado no servidor. No código, o auto-login aciona o botão Connect sozinho, o que dispensa digitar quando a senha está gravada | Desmarcado (aqui `Autologin=0`) |
| **Use always current local IP as host name** | Troca o host pelo IP atual da máquina; só para instalação local | Aqui está marcado (`UseCurrentIP=1`), por isso o host aparece como `192.168.0.10`. Desmarque se o servidor for outra máquina |
| **Sync local time with server time** | Acerta o relógio do Windows pelo do servidor ao logar. Exige direito de mudar a hora do sistema (normalmente só administrador) | Desmarcado se você não é administrador local (aqui `SyncServerTime=0`); com vários usuários, mantenha os relógios sincronizados por NTP |

3. Clique **Ping**, depois **Connect**. O login do `sysdba` deve entrar como Archive Administrator (o `jvcs.exe` mostra `User accepted. Access level: 4 [Archive Admin]`).
4. Confira: menu **Server > Whoami** mostra usuário, nível de acesso padrão e atual, servidor, banco, hora de login e quando o login expira.

Onde fica a configuração (somente leitura, nesta máquina): `HKCU\Software\JEDI\JEDIVCS` com `CurrentServer`, `CurrentPort`, `Options` e `Identities\<nome>` (HostName, Port, User, Password em Base64) mais `LastUsedID`. Proteção das senhas: [capítulo 07](07-Senhas-Padrao-e-Seguranca.md).

## 3. Identidades: uma por servidor e por usuário

Crie uma identidade para cada combinação que você usa, em vez de editar a mesma: por exemplo uma para o servidor de teste e uma para produção, e outra para o usuário da IA (seção 9). Para criar: preencha os campos e clique **Add/Update Identity**; escolha pelo combo **Identity**. A última usada fica em `Identities\LastUsedID`.

## 4. Trocar a senha do `sysdba`

1. Conectado como `sysdba`, menu **Server > Change Password...**.
2. Preencha **Old password** (`admin`), **New password** e **Confirm new password**.
3. Regras: de **5 a 50 caracteres**, diferencia maiúsculas. Use uma frase longa e única, guardada em gerenciador de senhas.
4. Se a identidade guarda a senha, reabra o Server Login, digite a nova e clique **Add/Update Identity**.

> **Atenção:** o servidor guarda as senhas de forma reversível. Nunca use a mesma senha do Windows, do domínio ou de sites. Não perca a senha: a ajuda diz que você precisa da senha atual para trocá-la, e recuperar uma senha perdida exige mexer no banco (capítulo 08).

Não apague o `sysdba` antes de confirmar que o seu usuário administrador funciona. Depois, ou o apague, ou deixe-o como conta de emergência com senha longa e fora do uso diário.

## 5. Criar usuários

1. Logado como Archive Administrator: **Server > Administration > User List...**.
2. Clique com o botão direito e **Add...** (ou Ctrl+A). A janela **Add new User** tem:

| Campo | Regra |
|---|---|
| **User name** | 2 a 50 caracteres, diferencia maiúsculas |
| **Password** / **Confirm password** | 5 a 50 caracteres |
| **Access level** | Guest account, Read only access, Read write access, Project administrator, Archive administrator |
| **Description** | Texto livre (até 2000 caracteres) |
| **Client IP address (optional)** | Botão `...`: "Allow this user login from any client" ou "Restrict to IP address (IP mask)", aceita `*` e `?` (por exemplo `192.168.0.*`). Só vale se "Login restricted to stored IP address" estiver ligado em Server Properties > Security |

Outros itens do menu de contexto da lista: Edit, Delete (mostra/oculta excluídos com "Hide deleted Users"), **Log Out** (derruba a sessão do usuário), Change Password..., Insert E-Mail Address, Export SMTP Forwarder List, Modules locked by, Report.

3. Conjunto de usuários sugerido (os nomes são exemplos, ajuste):

| Usuário | Nível | Para quê |
|---|---|---|
| `sysdba` | Archive administrator | Conta de emergência, senha longa, fora do uso diário |
| `edmar` | Archive administrator | Seu uso diário como administrador |
| `edmar.ia` | **Guest account** + direito **Read-Write** só nos projetos liberados (seção 6) | CLI/IA. Poucos direitos, não cria projetos, não mexe em usuários. O histórico mostra o que foi feito pela IA |
| Colegas (um por pessoa) | Read write access | Desenvolvedores |
| `ci` (opcional) | Read only access | Build que só sincroniza (`syncproject`) |

> **Atenção:** crie um usuário **por cliente simultâneo** (IDE, standalone, CLI/IA), porque o servidor derruba a sessão anterior do mesmo usuário. A senha do usuário da IA não deve ser dada à IA: veja o capítulo 06 e o [Credenciais.md](../common/Credenciais.md) (seção c.8).

4. Teste cada usuário novo conectando com ele numa identidade própria.

## 6. Níveis de acesso e direitos por projeto

| Nível (grupo) | O que pode | Observações |
|---|---|---|
| **Guest account** | Só logar. Direitos nos projetos só pelos "Project based rights" | Não cria projetos. Serve para **esconder** projetos de certos usuários |
| **Read only access** | Ver e baixar (Get) tudo, menos lista de usuários, direitos por projeto e opções do servidor | Não cria projetos |
| **Read write access** | Ver e alterar tudo, menos usuários, direitos por projeto e opções do servidor. Cria projetos, adiciona/remove módulos, check-in/out, labels | Só faz check-in do que ele mesmo fez check-out |
| **Project administrator** | Tudo dentro do projeto, incluindo marcos (milestones) | |
| **Archive administrator** | Tudo, em todos os projetos: usuários, opções do servidor, check-in de módulo de outro usuário, logout de qualquer usuário | O seu `edmar` e o `sysdba` |

O número do nível aparece no login: `Access level: 4 [Archive Admin]` (confirmado). Os números 0 a 3 seguem a ordem da lista e a legenda da tela de direitos por projeto (`0 = None, 1 = Read-only, 2 = Read-Write, 3 = Project Admin`) (a validar).

### Direitos por projeto

1. **Server > Administration > Project based Rights...**
2. Selecione o usuário na lista da esquerda e um ou mais projetos na da direita.
3. Escolha o direito (em branco = padrão, 0 = None, 1 = Read-only, 2 = Read-Write, 3 = Project Admin) e clique **Apply**. **Clear All** limpa os direitos do usuário.
4. O usuário precisa **fechar e reabrir o projeto** para receber a mudança.

Regras: administradores do arquivo não aparecem nesta lista e ficam com o direito deles em qualquer projeto. Para **ocultar** projetos, o usuário tem de ser Guest e você só atribui os projetos liberados. "Oculto" significa que não dá para selecioná-los no Project Manager; o nome ainda pode aparecer.

### Opções do servidor no cliente (Server > Administration > Server Properties)

Exige Archive Administrator para mudar.

| Aba | Opção | Recomendação |
|---|---|---|
| Security | Connection timeout (s) | 60 na LAN; aumente na WAN |
| Security | Login timeout (min) e **Login idle timer active** | Ligue o idle timer em LAN/WAN |
| Security | Login restricted to stored IP address | Ligue se usar IP por usuário |
| Security | **Enable local login w/o password** | **Desligado.** Deixa o IP do próprio servidor entrar com senha em branco |
| Security | DBMS auto logon on server start | Só existe para Oracle; ignore |
| **Checkin** | Casually Check In (livre) × **Restrictive Check In** | **Restritivo** em equipe: só quem fez check-out faz check-in. O servidor de teste está em **livre** (`CasuallyCheckin=1`) |
| Log/Stat | VCS log active (recommended) | Ligado: o histórico do projeto depende dele |
| Log/Stat | Server log active, Log unauthorized client requests | Ligue enquanto estiver testando |
| Backup | Version archive backup folder, Execute Now | Ver capítulo 01, seção 8 |

## 7. Grupos

- **Grupos de usuários**: são os cinco níveis da tabela acima (campo "Access level"). Não há grupos de usuários personalizados.
- **Grupos de projetos** (hierarquia): na janela **Select Project** (menu Project > Open ou o diálogo de seleção) use a aba **Hierarchy**.
  1. Crie grupos raiz e subgrupos (**Add new Group**: Name, Description, Parent).
  2. Atribua projetos aos grupos na própria aba. Um projeto pode estar em vários grupos.
  3. A estrutura fica no servidor e vale para todos. O grupo `<Unassigned Projects>` é automático (projetos sem grupo).
  4. Criar/alterar grupos exige nível Read-Write. O comando `syncprojectgroup` do `jvcs.exe` sincroniza todos os projetos de um grupo.

## 8. Projetos

### 8.1 Regras importantes

- Um projeto do JEDI VCS é o conjunto de arquivos guardado sob um nome no servidor. No **Delphi**, o nome é sempre o do projeto do Delphi (`.dpr`/`.dpk`); você não "cria projeto" no menu, você usa um projeto existente. No **standalone** o nome é livre (até 50 caracteres).
- Cada módulo é guardado com o **caminho completo e a letra da unidade**. Todos os clientes precisam ter os arquivos **na mesma pasta e na mesma letra** (por exemplo `D:\Delphi\Projetos\Ex1\`). Diferenças de caminho se resolvem com `subst` ou junction. **Caminhos UNC não são aceitos** (use unidade mapeada).
- Limites: nome de projeto até 50 caracteres; nome de arquivo até 250; extensão até 20; módulos por projeto até 2048; um arquivo até 20 MB; comentários até 2000 caracteres.
- Não pode haver dois projetos com o mesmo nome no servidor (o nome é guardado **sem** o caminho).

### 8.2 Erro "Project names cannot be one of the following"

Ao criar o projeto aparece:

> Project names cannot be one of the following: project1.dpr, project1.bdsproj, project1.cbproj, project1.dproj, package1.dpk, projectgroup1.bpg, unit1.pas, unit1.dfm. See help topic 'Naming conventions'

**Causa.** Os nomes **padrão do Delphi** são proibidos. O JEDI VCS identifica o projeto só pelo nome (sem caminho) e cada módulo por nome e caminho, e esses nomes existiriam em qualquer computador: todos os "Project1" cairiam no mesmo projeto do servidor. Por isso o cliente os recusa (validação `IsValidProjectName`/`IsValidModuleName` em `src\jedivcs\VCSProcBase.pas`; ajuda: tópico "JEDI VCS Naming Syntax, Conventions and Limitations", arquivo `idh_jedivcs_naming_syntax_conventions_and_limitations.htm` do CHM). A comparação ignora maiúsculas.

**Solução**, no Delphi (projeto novo ou recém-criado):
1. **File > Save Project As...** e salve com nome próprio, por exemplo `Ex1.dproj` (o `.dpr` acompanha).
2. Para **cada** unit `UnitN`: **File > Save As...** com nome próprio, por exemplo `uEx1Principal.pas`. O `.dfm` (ou `.fmx`) acompanha o nome.
3. Feche e reabra o projeto: o JEDI VCS só reconhece o projeto novo pelos eventos de abrir e fechar.
4. **JEDI VCS > Project Manager...** e crie o projeto no servidor (o JEDI VCS oferece isso sozinho).

Outras regras de nome (ajuda e código):
- Caracteres proibidos: `"` `/` `\` `<` `>` `[` `]` `:` `;` `|` `{` `}` `*` `%` `?` e tabulação; nada de espaço no começo ou no fim.
- A ajuda também proíbe letras acentuadas e `ç` nos nomes. O código só confere os símbolos acima, mas **evite acentos** (e lembre que o expert converte nomes para ANSI, [capítulo 03](03-Integracao-com-o-Delphi.md)).
- Módulos precisam ter extensão.

### 8.3 Criar o primeiro projeto (recomendado: um projeto "Dummy")

A ajuda recomenda os primeiros passos num projeto sem importância (Dummy), que pode ser removido depois. Use por exemplo o `Ex1`.

**Pelo Delphi:**
1. Instale o expert ([capítulo 03](03-Integracao-com-o-Delphi.md)).
2. Abra o `.dproj` (nomes já corrigidos, seção 8.2) e use **JEDI VCS > Connect Server...**.
3. **JEDI VCS > Project Manager...** (Ctrl+Shift+P). O JEDI VCS pergunta se deve criar o projeto e adicionar os **módulos principais** do projeto: aceite.
4. Faça o **check-in de todos** os módulos como primeiro passo (isso deixa os arquivos somente leitura no disco).
5. Adicione outros arquivos que devam ser versionados (famílias: [capítulo 05](05-Familias-de-Arquivos.md)).

**Pelo standalone:** **Project > New...**, informe o nome, depois **Module > Add...**, selecione os arquivos e faça o check-in.

### 8.4 Rotina diária

| Quero | Faça |
|---|---|
| Editar um módulo | **Check Out** (Ctrl+Shift+O na IDE). O arquivo fica gravável e bloqueado para os outros |
| Gravar a alteração | **Check In** (Ctrl+Shift+I), com comentário |
| Desfazer | **Undo Check Out**: restaura o original e libera o módulo |
| Pegar a última versão | **Get** (Ctrl+Shift+G) ou **Project > Synchronize/ Restore...** |
| Marcar uma versão | Label (Merge/Stamp) |

Nunca tire o atributo somente leitura de um arquivo no Explorer: faça Check Out. Detalhes: [capítulo 04](04-Opcoes-do-Cliente.md).

## 9. Identidade e usuário para a IA

1. Crie o usuário `edmar.ia` (seção 5), nível Guest, com direitos Read-Write só nos projetos liberados.
2. No cliente, crie uma identidade separada (por exemplo `TESTE-IA`) apontando para esse usuário.
3. A IA não deve digitar nem ver a senha. Hoje isso só se garante usando a **identidade salva** ou a entrada padrão do `jvcs.exe` (capítulo 06, seção 5). Cuidado: com "Store Password" a senha fica em Base64 no registro, e a IA com acesso ao registro conseguiria lê-la; por isso a recomendação de regras `deny` no Claude Code está em [Credenciais.md](../common/Credenciais.md), seção c.10.

## 10. Checklist do primeiro acesso

1. Ping e login com `sysdba`/`admin`.
2. Server > Whoami: nível Archive Admin.
3. Trocar a senha do `sysdba`.
4. Criar `edmar` (admin), `edmar.ia` (Guest + projeto) e os colegas.
5. Server Properties: check-in **restritivo**, VCS log ligado, login local sem senha **desligado**.
6. Criar o projeto Dummy e fazer check-in/check-out de teste.
7. Desmarcar "Store Password" ou aceitar o risco conscientemente (capítulo 07).
