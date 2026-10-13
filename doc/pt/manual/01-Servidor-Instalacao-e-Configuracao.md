# 01. Servidor: instalação e configuração

Como instalar e configurar o **JEDI VCS Firebird Server 2.50 Beta 3** com Firebird 2.5.9. O que está aqui foi feito e verificado nesta máquina em 12/10/2026 (registro em [Servidor-Teste-Local.md](../server/Servidor-Teste-Local.md)); o que veio só da ajuda ou do código-fonte está marcado `(a validar)`.

## 1. Como as peças se encaixam

```
Cliente (IDE / jedivcs.exe / jvcs.exe)
   │  TCP 2106 (protocolo próprio, sem criptografia de transporte)
   ▼
JVCSSrv.exe  ── servidor de aplicação (32 bits)
   │  fbclient.dll (32 bits)  ──  TCP 3050 ou local
   ▼
Firebird 2.5.9 (serviço)  ──►  JEDIVCS.FDB  (o "arquivo de versões", ODS 11.2)
```

O cliente **nunca** fala com o banco. Ele envia pedidos abstratos (por exemplo `CHECKIN_MODULE`) ao servidor de aplicação, e só o servidor conversa com o Firebird. Por isso o banco precisa ser aberto pelo servidor, com usuário e senha **do Firebird** (não são os usuários do JEDI VCS).

| Peça | Valor nesta máquina |
|---|---|
| Servidor de aplicação | JEDI VCS Firebird Server 2.50 Beta 3, **versão aplicação** (`JVCSSrv.exe`, janela própria) em `C:\Program Files (x86)\JEDI\JVCS\Server` |
| Porta do servidor | **2106** (escuta em `0.0.0.0`, todas as interfaces) |
| Firebird | 2.5.9 x64, serviço `FirebirdServerDefaultInstance` (+ `FirebirdGuardianDefaultInstance`), porta 3050, em `C:\Program Files\Firebird\Firebird_2_5` |
| Biblioteca cliente usada pelo servidor | `C:\Windows\SysWOW64\fbclient.dll`, versão 2.5.9.27139 (32 bits) |
| Banco | `C:\Program Files (x86)\JEDI\JVCS\Server\archive\db_fib\JEDIVCS.FDB`, ODS 11.2, página 4096 |
| Usuário do servidor no Firebird | `SYSDBA` / `masterkey` |
| Usuário inicial do JEDI VCS | `sysdba` / `admin` (ver [capítulo 07](07-Senhas-Padrao-e-Seguranca.md)) |

> **Só no ambiente de teste:** `masterkey` e `admin` são as senhas padrão publicadas. Em produção troque as duas (capítulo 07).

## 2. Decisões antes de instalar

### 2.1 Versão aplicação × serviço do Windows

| | Aplicação (`JVCSSrv.exe` com janela) | Serviço NT |
|---|---|---|
| Janela com status, clientes e log | Sim | Não: erros e mensagens vão para o Visualizador de Eventos |
| Backup automático (Live Backup) | **Sim** | **Não** ("only available in executable server versions", ajuda) |
| "Log unauthorized client requests" e "DBMS auto log on" | Sim | Não |
| Sobe com o Windows | Só ao abrir o programa (o item "Autostart with Windows" grava `RunServices`, e a ajuda manda usar o serviço no Windows NT/2000 ou mais novo) | Sim, início Automático |
| Instalação | Instalador (feito aqui) | `JvcsSrv.exe` + applet `JvcsCpa.cpl` + `ServerCrypt.dll` em `system32`, depois botão **Install** no applet "JEDI VCS NT service" |

Recomendação (da própria ajuda): instalar primeiro a versão aplicação, ver tudo funcionando e só depois trocar para o serviço. Se for para serviço, o backup automático do servidor deixa de existir: use o `gbak` agendado (seção 8.3).

Nesta máquina há só a versão aplicação: não existe `JvcsCpa.cpl` na pasta do servidor nem em `System32`/`SysWOW64`, não há serviço do Windows do JEDI VCS e o atalho do Menu Iniciar é "JVCS Firebird applicationserver". A versão serviço não foi instalada nem testada aqui (a validar).

### 2.2 Firebird instalado × Firebird embutido

| | **Instalado** (usado aqui, recomendado) | Embutido |
|---|---|---|
| Motor | Firebird 2.5.9, serviço do Windows | `fbembed.dll` 2.1.3, na pasta do servidor |
| ODS do banco | **11.2** | **11.1** |
| Config no `jvcssrv.ini` | `FirebirdUseEmbeded=0` | `FirebirdUseEmbeded=1` |
| Tela Logon | Usuário, senha e Server preenchidos (`SYSDBA`, `masterkey`, `LOCALHOST`) | "Use Firebird embedded" marcado; usuário, senha e Server ficam ocultos |
| Ferramentas | `C:\Program Files\Firebird\Firebird_2_5\bin` (`gbak`, `gstat`, `gfix`, `isql`) | `gbak`/`gfix`/`isql` 2.1 na própria pasta do servidor |
| Acesso ao arquivo | Pelo serviço; vários programas podem usar o banco | Direto pelo processo do servidor; não abra o `.FDB` com outro programa enquanto ele roda |
| Quando usar | Produção e teste | Teste rápido sem instalar o Firebird |

> **Atenção, regra de ouro:** o `.FDB` tem de ser criado ou restaurado pelo `gbak` **da mesma versão do Firebird que vai abri-lo**. Um motor 2.1 não abre um banco ODS 11.2. Esse foi o primeiro erro do servidor de teste (seção 3.5 e [capítulo 08](08-Solucao-de-Problemas.md)).

O instalador do servidor traz o Firebird 2.1.3 embutido e vem com `FirebirdUseEmbeded=1` no `jvcssrv.ini` da pasta de instalação. Aqui o banco foi restaurado com o `fbclient.dll` 2.5 do sistema (formato 11.2), e o servidor foi mudado para o Firebird instalado.

## 3. Instalar, passo a passo

### 3.1 Instalar o servidor JEDI VCS

1. Execute `D:\Delphi\JediVCS\Instalador_Servidor_2.50_Beta3_FIB\JVCSv2.50SalFIB.Beta 3.exe` (SourceForge, versão aplicação, SHA-256 `018989AB…D119A696D`).
2. Resultado esperado:
   - Pasta `C:\Program Files (x86)\JEDI\JVCS\Server` com `JVCSSrv.exe`, `ServerCrypt.dll`, `JediVcsGlobalAdmin.exe` (Global VCS Settings Utility), `JediVcsDBTransfer.exe`, as ferramentas Firebird 2.1 (`gbak.exe`, `gfix.exe`, `isql.exe`, `fbembed.dll`) e a pasta `archive\db_fib` com `jedivcs.fbk`, `fib_ib_create.sql`, `fib_ib_defvalues.sql` e um `JEDIVCS.FDB`.
   - Atalhos em Menu Iniciar > JEDI > JEDI VCS: "JVCS Firebird applicationserver", "Global VCS Settings Utility", "DB Transfer Utility", "DB Design", "Release Notes" e "Standalone GUI client".

> **Atenção:** `Program Files` não é gravável por usuário comum. Por isso o Windows redireciona o `jvcssrv.ini` para o VirtualStore (seção 5). Em produção, prefira instalar o servidor numa pasta fora de `Program Files` (por exemplo `D:\JEDIVCS\Server`), assim o `.ini` fica ao lado do `.exe`.

### 3.2 Instalar o Firebird 2.5.9 (se for usar o motor instalado)

1. Instale o Firebird 2.5.9 como **serviço** (na máquina o resultado foi `FirebirdServerDefaultInstance`, partida Manual, iniciado pelo Guardian, que é Automático).
2. Instale também a biblioteca cliente **de 32 bits** (pasta `WOW64` do Firebird 2.5 x64) e deixe-a no diretório do sistema: o `JVCSSrv.exe` é de 32 bits e precisa de um `fbclient.dll` de 32 bits. Nesta máquina ela está em `C:\Windows\SysWOW64\fbclient.dll`.
3. Defina a senha do `SYSDBA` (aqui `masterkey`, só teste).
4. Confira:

```powershell
Get-Service Firebird*                                   # Server e Guardian em Running
(Get-Item C:\Windows\SysWOW64\fbclient.dll).VersionInfo.FileVersion   # 2.5.9...
```

> **Atenção:** se existir um `fbclient.dll` (ou `fbembed.dll`, no modo embutido) **na mesma pasta do `JVCSSrv.exe`**, o servidor usa esse (conforme o código-fonte do servidor, função `GetFirebirdClientLibrary`). Não copie um `fbclient.dll` antigo para lá.

### 3.3 Restaurar o banco em branco com o `gbak` (mesma versão do Firebird em uso)

O banco em branco oficial vem como backup: `C:\Program Files (x86)\JEDI\JVCS\Server\archive\db_fib\jedivcs.fbk`. Restaure-o com o `gbak` do Firebird que vai abri-lo.

1. Feche o `JVCSSrv.exe` se ele estiver apontando para o arquivo de destino (menu Server > Exit).
2. Escolha a pasta de destino e crie-a. Ela precisa ser gravável pelo **serviço do Firebird** (é ele quem cria o arquivo, por causa do prefixo `localhost:`).
3. Rode (PowerShell; ajuste o destino):

```powershell
& "C:\Program Files\Firebird\Firebird_2_5\bin\gbak.exe" -c -v -user SYSDBA -password masterkey `
  "C:\Program Files (x86)\JEDI\JVCS\Server\archive\db_fib\jedivcs.fbk" `
  "localhost:D:\JEDIVCS\Dados\JEDIVCS.FDB"
```

   No `cmd.exe`, a mesma linha sem o `&` e sem as crases:
   `"C:\Program Files\Firebird\Firebird_2_5\bin\gbak.exe" -c -v -user SYSDBA -password masterkey "<jedivcs.fbk>" "localhost:<destino.FDB>"`

| Opção | Efeito |
|---|---|
| `-c` | Cria um banco novo a partir do backup. **Não** sobrescreve arquivo existente: use outro nome ou renomeie o antigo |
| `-v` | Mostra o progresso |
| `localhost:` | Faz o serviço do Firebird criar o arquivo (motor 2.5, ODS 11.2) |

> **Atenção:** a senha vai na linha de comando e fica visível no histórico e no Gerenciador de Tarefas. No teste tudo bem. Em produção defina a senha só na sessão, com a variável padrão do Firebird, e não a escreva em scripts: `$env:ISC_PASSWORD = Read-Host` (a validar), e rode o `gbak` sem `-password`.

4. Confira a versão do formato (ODS) e a integridade (somente leitura):

```powershell
& "C:\Program Files\Firebird\Firebird_2_5\bin\gstat.exe" -h -user SYSDBA -password masterkey "localhost:D:\JEDIVCS\Dados\JEDIVCS.FDB"
```

   Na saída, procure `ODS version 11.2`. Opcionalmente `gfix.exe -v -full` valida o banco (a validar).

5. Aponte o servidor para o novo arquivo na tela de logon (seção 4).

Backups de reserva já prontos, ambos restaurados do `jedivcs.fbk` oficial:

| Arquivo | Como foi feito | ODS | Uso |
|---|---|---|---|
| `D:\Delphi\JediVCS\ServidorTeste\fb25\JEDIVCS.FDB` | `gbak` 2.5 | 11.2 | Cópia limpa para o Firebird instalado |
| `D:\Delphi\JediVCS\ServidorTeste\JEDIVCS.FDB` | `gbak` 2.1 embutido (ferramentas em `D:\Delphi\JediVCS\ServidorTeste\fb21embed`) | 11.1 | Só para o modo embutido |

> **Atenção:** esses arquivos **não** devem ser copiados por cima do banco em uso enquanto o servidor roda. Pare o servidor, guarde o arquivo atual e só então troque.

Os scripts `fib_ib_create.sql` e `fib_ib_defvalues.sql` (mesma pasta `db_fib`) criam as tabelas e inserem os dados iniciais (usuário `sysdba`, família "Delphi forms" `.pas` → `.dfm`, marcos de exemplo). Não foram usados aqui, o `jedivcs.fbk` é o caminho testado.

### 3.4 Subir o servidor

1. Abra o atalho **JVCS Firebird applicationserver** (ou `C:\Program Files (x86)\JEDI\JVCS\Server\JVCSSrv.exe`).
2. Se o logon automático estiver desligado, aparece a tela **Logon to Firebird** (seção 4). Preencha e confirme.
3. A janela do servidor mostra "Running" no título, a mensagem `[data/hora] - DBMS connected.` e a porta (`Port: 2106`).
4. Ao abrir o programa o servidor já inicia sozinho (menu Server > Start só é necessário depois de um Stop).

### 3.5 Se aparecer erro ao conectar no banco

| Mensagem | Causa | Solução |
|---|---|---|
| `unsupported on-disk structure ... found 11.2, support 11.1` | `FirebirdUseEmbeded=1`: o `fbembed.dll` 2.1 está abrindo um banco criado no formato 2.5 | Na tela Logon, **desmarque** "Use Firebird embedded" e deixe Server `LOCALHOST` |
| Erro 152 `Your user name and password are not defined` | A senha do Firebird gravada no servidor está errada | Digite a senha do `SYSDBA` (aqui `masterkey`) |
| `firebird.msg not found` (junto com outro erro) | Cliente 2.5 sem a variável `FIREBIRD`: só o texto da mensagem não foi achado | Ignorar; leia o erro real que vem junto |

Mais casos no [capítulo 08](08-Solucao-de-Problemas.md).

## 4. A tela "Logon to Firebird", campo a campo

Aparece ao iniciar o servidor (se "Log on automatically on start-up" estiver desmarcado) e pelo menu **Version Archive > Logon to database...** (nesse caso o servidor avisa quantos clientes estão conectados e **derruba todos** antes de reconectar).

| Campo | O que colocar | Valor nesta máquina |
|---|---|---|
| **Username** | Usuário do **Firebird** com acesso ao banco | `SYSDBA` |
| **Password** | Senha desse usuário (fica gravada criptografada no `jvcssrv.ini`) | `masterkey` (só teste) |
| **Server** | Máquina do Firebird. Vazio, `LOCAL` ou `LOCALHOST` = banco na própria máquina (o servidor usa só o caminho do arquivo). Outro nome ou IP: o servidor monta `servidor:caminho` | `LOCALHOST` |
| **Database** | Caminho do `.FDB` **como o Firebird o enxerga** (na máquina do Firebird). Tem botão de procurar | `C:\Program Files (x86)\JEDI\JVCS\server\archive\db_fib\JEDIVCS.FDB` |
| **Char Set** | Conjunto de caracteres do banco. Use o **mesmo** com que o banco foi criado, senão aparece erro no servidor | `NONE` (o banco do `jedivcs.fbk` oficial) |
| **Use Firebird embedded** | Marque só para o `fbembed.dll` da pasta do servidor (ODS 11.1). Marcado, oculta Username/Password/Server | **Desmarcado** |
| **Log on automatically on start-up** | Conecta ao banco sem mostrar a tela nas próximas vezes (`FirebirdDBAutoLogin=1`) | Marcado |
| OK / Cancel | | |

O campo "Use Trusted NT Connection" aparece só no servidor para MSSQL; não existe no Firebird.

## 5. Arquivo `jvcssrv.ini` e o VirtualStore

O servidor guarda tudo no `jvcssrv.ini`, ao lado do `JVCSSrv.exe`. Como o servidor roda sem permissão para gravar em `Program Files`, o Windows **redireciona** a gravação:

| Arquivo | Conteúdo | Vale para |
|---|---|---|
| `C:\Program Files (x86)\JEDI\JVCS\Server\jvcssrv.ini` | Cópia original do instalador: só chaves antigas `Firebird 1.xDB*` e `FirebirdUseEmbeded=1` | Quem roda **como administrador** (sem redirecionamento) (a validar) |
| `%USERPROFILE%\AppData\Local\VirtualStore\Program Files (x86)\JEDI\JVCS\Server\jvcssrv.ini` | Configuração **efetiva**: `FirebirdUseEmbeded=0`, porta, logon, timeouts | Quem roda como usuário comum (o caso aqui) |

> **Atenção:** editar o arquivo de `Program Files` não adianta enquanto existir a cópia do VirtualStore. E rodar o `JVCSSrv.exe` "como administrador" faz o servidor ler o arquivo original (embutido) e voltar o erro de ODS 11.2/11.1. Escolha um modo e use sempre o mesmo. Em produção, instale fora de `Program Files` e evite o problema.

Chaves relevantes (as de senha não estão listadas). Prefira mudar pelos menus; edite o arquivo só com o servidor **fechado**:

| Chave | Valor aqui | Corresponde a |
|---|---|---|
| `FirebirdPort` | `2106` | Server > Port... |
| `FirebirdUseEmbeded` | `0` | Logon: Use Firebird embedded |
| `FirebirdDBServer` / `FirebirdDBUser` / `FirebirdDBDatabase` / `FirebirdCharacterSet` | `LOCALHOST` / `SYSDBA` / caminho do `.FDB` / `NONE` | Logon: Server, Username, Database, Char Set |
| `FirebirdDBAutoLogin` | `1` | Logon: Log on automatically |
| `FirebirdAutoBackupActive` / `FirebirdAutoBackupTime` / `FirebirdBackupPath` | `0` / `0,0416666666666667` (01:00) / vazio | Live Backup (seção 8) |
| `CasuallyCheckin` | `1` | Check-in livre (não restritivo). Veja o capítulo 02 |
| `WriteVCSLog` / `WriteSrvLog` / `LogAccessFault` | `1` / `0` / `0` | Log (seção 9) |
| `CheckIPAddr` | `0` | "Login restricted to stored IP address" |
| `LocalLogin` | `0` | "Enable local login w/o password" (deixe `0`) |
| `FirebirdConnectTimeOut` | `60` (segundos) | Connection timeout |
| `LoginExpires` / `LoginTimeOut` | `0` / `0,0416666666666667` (1 hora) | Login idle timer / Login timeout |
| `DisableServerBanner` / `ServerBanner` | `0` / `Welcome to JEDI VCS Firebird Server` | Security |
| `DisableSQLDirekt` | `1` | "Disable SQL Server Object" (deixe `1`) |
| `VerifyClientTimestamp` | `0` | Clients > Verify Client Timestamp |
| `StartHidden` / `HideOnClose` / `HideWindow` | `0` / `0` / `0` | Server > Hide Window... |
| `[GlobalUserData] ForceGlobalSettings` | `0` | Clients > Force Global Settings |

Observações:
- Os valores com vírgula decimal (`0,0416...`) foram gravados no formato regional pt-BR. Não copie o arquivo para uma máquina com outro formato regional sem conferir (a validar).
- As chaves `Firebird 1.xDB*` no arquivo são resíduos antigos; o servidor 2.50 usa as chaves `FirebirdDB*`.
- `ForceGlobalSettings` e a ferramenta **Global VCS Settings Utility** (`JediVcsGlobalAdmin.exe`) permitem impor opções a todos os clientes (ver [capítulo 04](04-Opcoes-do-Cliente.md)).

## 6. Porta 2106 e firewall

1. A porta padrão é **2106** (Server > Port...). Cliente e servidor precisam usar a mesma. Só um programa pode escutar numa porta: se estiver ocupada o servidor mostra erro.
2. Situação nesta máquina (somente leitura):
   - `JVCSSrv.exe` escuta em `0.0.0.0:2106`; o Firebird, em `0.0.0.0:3050`.
   - Existem duas regras de entrada, nome **"JEDI VCS Application server"** (TCP e UDP), perfil **Público**, qualquer porta, programa `C:\program files (x86)\jedi\jvcs\server\jvcssrv.exe`. O Windows as criou quando o aviso do firewall foi aceito.
   - Não há regra de firewall com "Firebird" no nome.
3. Para colegas acessarem o servidor numa rede **Privada** ou de **Domínio**, a regra atual (só Público) não vale. Crie uma regra por porta, num PowerShell **como administrador** (comando de referência, não executado aqui):

```powershell
New-NetFirewallRule -DisplayName "JEDI VCS Application server - TCP 2106" `
  -Direction Inbound -Protocol TCP -LocalPort 2106 -Action Allow -Profile Domain,Private -RemoteAddress LocalSubnet
```

> **Atenção:** não abra a porta **3050** (Firebird) no firewall. Só o `JVCSSrv.exe`, na mesma máquina, precisa dela. Para o Firebird nem escutar fora da máquina, descomente e ajuste `RemoteBindAddress = 127.0.0.1` no `firebird.conf` (linha 574 do arquivo em `C:\Program Files\Firebird\Firebird_2_5`) e reinicie o serviço (a validar: teste o `gbak` e o servidor depois). Registre a alteração e faça cópia do arquivo antes.

4. A ajuda recomenda no cliente usar **IP numérico**, não nome DNS (o cliente refaz a consulta DNS a cada pedido). Use um IP fixo para o servidor.
5. O tráfego **não é criptografado**. Fora da LAN use VPN ou túnel (capítulo 07).

## 7. Conferir que o servidor subiu

Faça na ordem; pare no primeiro item que falhar.

1. Janela do servidor: título com "Running" e a mensagem `DBMS connected`.
2. A porta está escutando e é do `JVCSSrv`:

```powershell
Get-NetTCPConnection -State Listen -LocalPort 2106 |
  ForEach-Object { Get-Process -Id $_.OwningProcess | Select-Object Name, Id }
```

3. O banner (sem login). Resposta esperada: `Welcome to JEDI VCS Firebird Server`:

```powershell
$c = New-Object Net.Sockets.TcpClient('127.0.0.1',2106); $s = $c.GetStream(); Start-Sleep -Milliseconds 700
$b = New-Object byte[] 256; $n = $s.Read($b,0,256); $c.Close()
[Text.Encoding]::ASCII.GetString($b,0,$n) -replace '[^\x20-\x7E]',''
```

   (Testado aqui: devolve o banner mais dois bytes de controle. Se o banner foi desligado em Security, a resposta vem vazia.)
4. De outra máquina: `Test-NetConnection <IP do servidor> -Port 2106` deve dar `TcpTestSucceeded : True`.
5. Login com o cliente de linha de comando (confirmado em 12/10/2026 no servidor de teste):

```
jvcs 127.0.0.1:2106 /user sysdba /password admin /listprojects
```

   Saída esperada: `User accepted. Access level: 4 [Archive Admin] Branch: HEAD`.

> **Só no ambiente de teste:** o comando acima tem a senha padrão na linha de comando. Em produção veja o [capítulo 06](06-Linha-de-Comando.md).

## 8. Backup do servidor

O que proteger: o **banco** (`JEDIVCS.FDB`), o `jvcssrv.ini` efetivo e, se houver, a pasta `Config`. O banco **não** se copia como arquivo com o servidor ligado: use backup do Firebird (`gbak`).

### 8.1 Backup automático do próprio servidor (Live Backup)

Disponível só na versão aplicação. O servidor faz o backup com o serviço do Firebird, sem parar e com clientes conectados, mas **fica bloqueado durante o backup**.

1. Crie a pasta de destino **na máquina do servidor** (a ajuda exige que ela já exista). O melhor é outro disco.
2. Menu **Version Archive > Live Backup > Target Folder** e informe a pasta.
3. Menu **Version Archive > Live Backup > Auto Backup Settings...**, marque "Auto backup active" e escolha o horário (uma hora sem muito tráfego; a precisão é de um minuto).
4. Teste uma vez agora: **Version Archive > Live Backup > Execute** (ou, num cliente com direito de Archive Admin, Server > Administration > Server Properties > aba **Backup** > "Execute Now").
5. Resultado: um arquivo `<nome-do-banco>.fbk` na pasta (por exemplo `JEDIVCS.fbk`). O anterior é renomeado para `.~fbk` e apagado só depois de o novo terminar bem.

> **Atenção:** o arquivo é escrito pelo processo do Firebird; o serviço precisa ter permissão de gravação na pasta. Estado desta máquina: backup automático **desligado** e pasta de backup **vazia**. Falta configurar.

### 8.2 Restaurar um backup

1. Peça a todos que fechem o JEDI VCS; no servidor, Server > Exit.
2. Restaure para um arquivo **novo** (não sobrescreva o atual):

```powershell
& "C:\Program Files\Firebird\Firebird_2_5\bin\gbak.exe" -c -v -user SYSDBA -password <senha> `
  "D:\Backups\JEDIVCS.fbk" "localhost:D:\JEDIVCS\Dados\JEDIVCS_restaurado.FDB"
```

3. Abra o servidor, vá em **Version Archive > Logon to database...** e aponte o campo Database para o arquivo novo.
4. Faça login com o cliente e confira projetos e usuários.

### 8.3 Backup agendado fora do servidor (obrigatório se usar o serviço do Windows)

Crie uma tarefa agendada do Windows que rode todo dia, em horário calmo:

```powershell
& "C:\Program Files\Firebird\Firebird_2_5\bin\gbak.exe" -b -v -user SYSDBA -password <senha> `
  "localhost:D:\JEDIVCS\Dados\JEDIVCS.FDB" "E:\BackupJVCS\JEDIVCS_$(Get-Date -Format yyyyMMdd).fbk"
```

Copie o `.fbk` para outro disco ou máquina e teste a restauração de tempos em tempos (a validar). Guarde também uma cópia do `jvcssrv.ini` efetivo, mas **sem** deixá-lo em pasta compartilhada: ele contém a senha do Firebird, ainda que criptografada.

## 9. Menus do servidor

Menus da janela do `JVCSSrv.exe` (nomes do código do servidor; descrição da ajuda).

### Server

| Item | Para que serve |
|---|---|
| Start / Stop | Stop: não aceita novos clientes, mas **não** desconecta os que já estão. Start só é preciso depois de um Stop (ao abrir o programa ele já inicia) |
| Port... | Porta TCP (padrão 2106). Mude também nos clientes |
| Autostart with Windows | Grava `RunServices`. A ajuda recomenda o serviço NT no Windows moderno |
| Hide Window / Hide Window on Close / Start Hidden | Esconde a janela e deixa o ícone na bandeja; duplo clique volta |
| Exit | Fecha o servidor |

### Security

| Item | Para que serve |
|---|---|
| Disable Server Banner | O servidor responde com texto vazio ao conectar (esconde que é um JEDI VCS). Recomendado fora da LAN |
| Disable SQL Server Object | Bloqueia a "Direct SQL" dos clientes. **Mantenha marcado** (padrão) |
| Log unauthorized Client Requests | Registra pedidos sem permissão (usa o log do servidor; não existe no serviço NT) |
| Change Server Banner... | Troca o texto do banner (hoje `Welcome to JEDI VCS Firebird Server`) |

### Clients

| Item | Para que serve |
|---|---|
| Client Lists > All Clients / Logged In | Lista os clientes na janela do servidor |
| Disconnect All | Derruba a conexão TCP de todos |
| Log out All | Desloga todos; cada um precisa digitar usuário e senha de novo |
| Client Timeout... | Tempo ocioso antes de fechar a conexão física (padrão 60 s na LAN; aumente na WAN) |
| Verify Client Timestamp | Recusa cliente cujo relógio difira mais de ±2 h do servidor (em relação ao GMT) |
| Force Global Settings | Obriga todos os clientes a usar as opções definidas no Global VCS Settings Utility |

### Version Archive

| Item | Para que serve |
|---|---|
| Logon to database... | Reabre a tela "Logon to Firebird" (derruba os clientes). No servidor Firebird esse item substitui "Archive Folder/Alias" |
| Live Backup > Auto Backup Settings... / Target Folder / Execute | Backup do banco (seção 8) |
| Upgrade database archive | Atualiza a estrutura do banco quando o servidor detecta versão antiga; normalmente automático |

### Display, Log e Help

| Item | Para que serve |
|---|---|
| Display > Copy to Clipboard / Save to File... / Clear | A janela limpa sozinha depois de 1000 linhas. "Show Debug Messages" só existe em build de depuração |
| Log > Server Logfile active / Show Logfile... / Clear Logfile | Grava as mensagens da janela em `server.log` (texto) na pasta do servidor; "Clear" apaga o arquivo **no servidor** |
| Help > Function List / About | Lista os objetos de servidor disponíveis |

Também há opções de servidor **dentro do cliente** (login com Archive Admin): Server > Administration > **Server Properties**, com as abas Security (connection timeout, login timeout, restringir login ao IP gravado, idle timer, login local sem senha), **Checkin** (livre × restritivo), Log/Stat e Backup. Veja o capítulo 02.

## 10. Checklist para passar a produção

1. Instalar o servidor **fora** de `Program Files`, em disco com backup, com IP fixo na rede.
2. Firebird instalado (nada de embutido), banco restaurado com o `gbak` da mesma versão, arquivo `.FDB` em pasta própria.
3. Trocar a senha do `SYSDBA` do Firebird (comando `gsec` no capítulo 07) e atualizar a tela Logon.
4. Trocar a senha do `sysdba` do JEDI VCS e criar o seu usuário administrador (capítulo 02).
5. Regra de firewall pela porta 2106 só para a rede interna; 3050 fechada.
6. Server Properties: check-in **restritivo**, "VCS log active" ligado, login local sem senha **desligado**.
7. Security: Disable SQL Server Object marcado; considerar Disable Server Banner.
8. Backup automático ligado (aplicação) ou tarefa agendada com `gbak` (serviço), com cópia em outro disco e teste de restauração.
9. Relógios sincronizados (servidor e clientes); considere Verify Client Timestamp.
10. Se o acesso for de fora da LAN: VPN.
