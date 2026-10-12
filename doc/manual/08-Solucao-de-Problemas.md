# 08. Solução de problemas

Tabelas de **sintoma → causa → solução**, por área. Os casos marcados com a data 12/10/2026 foram vividos na montagem desta máquina. Os demais vêm da ajuda oficial e do código-fonte.

Primeiro, três conferências que resolvem boa parte dos casos:
1. O servidor está rodando e conectado ao banco? (janela "Running" + `DBMS connected`; capítulo 01, seção 7).
2. Ping e porta: `Test-NetConnection <servidor> -Port 2106`.
3. Cliente e servidor falam a mesma porta, com usuário e senha **em minúsculas/maiúsculas corretas**.

## 1. Servidor e Firebird

| Sintoma | Causa | Solução |
|---|---|---|
| `unsupported on-disk structure for file ..., found 11.2, support 11.1` ao conectar no banco (12/10/2026) | O `fbembed.dll` 2.1 (modo embutido, `FirebirdUseEmbeded=1`) está abrindo um `.FDB` criado no formato 2.5 (ODS 11.2). O instalador restaurou o banco com o `fbclient.dll` 2.5 do sistema | Na tela Logon desmarque **Use Firebird embedded** e use Server `LOCALHOST` (capítulo 01, seção 4). Ou use o banco ODS 11.1 de `D:\Delphi\JediVCS\ServidorTeste\JEDIVCS.FDB` com o modo embutido. Regra: restaure o banco com o `gbak` da **mesma versão** do Firebird que vai abri-lo |
| Erro **152**: `Your user name and password are not defined. Ask your database administrator to set up a Firebird login` (12/10/2026) | A senha do Firebird gravada no servidor está errada | Digite a senha do `SYSDBA` do Firebird (aqui `masterkey`) em **Version Archive > Logon to database...** |
| `firebird.msg not found` junto com outro erro (12/10/2026) | O cliente 2.5 não encontra o arquivo de mensagens porque a variável `FIREBIRD` não está definida. É só o **texto** do erro | Ignore e leia o erro real. Se quiser, aponte `FIREBIRD` para `C:\Program Files\Firebird\Firebird_2_5` (a validar) |
| Mudei o `jvcssrv.ini` em `Program Files` e nada mudou | O Windows redireciona a gravação para `%LOCALAPPDATA%\VirtualStore\Program Files (x86)\JEDI\JVCS\Server\jvcssrv.ini`, que é o arquivo efetivo | Edite o arquivo do VirtualStore (com o servidor fechado) ou, melhor, use os menus. Em produção, instale fora de `Program Files` |
| O erro de ODS voltou depois de abrir o servidor "como administrador" | Elevado, o servidor não é redirecionado e lê o `jvcssrv.ini` original de `Program Files` (`FirebirdUseEmbeded=1`) (a validar) | Não rode como administrador, ou ajuste o arquivo original também |
| `DBMS Login failed` / "Unable to connect DBMS" | Serviço do Firebird parado, caminho do banco errado, senha ou charset errados | `Get-Service Firebird*` (inicie o Guardian: `FirebirdGuardianDefaultInstance`); confira o campo Database; veja `C:\Program Files\Firebird\Firebird_2_5\firebird.log` |
| Erro de charset no servidor depois de conectar | O **Char Set** da tela Logon difere do usado ao criar o banco | Use o mesmo. Para o `jedivcs.fbk` oficial, **NONE** |
| `gbak` diz que o banco já existe | `-c` não sobrescreve arquivo existente | Restaure para outro nome ou renomeie/apague o arquivo antigo (com o servidor parado) |
| `gbak`/Firebird não consegue criar o arquivo | O serviço do Firebird não tem permissão de escrita na pasta de destino | Dê permissão ao usuário do serviço ou escolha outra pasta |
| Mensagem de que a porta já está em uso | Outro programa escuta na 2106 | `Get-NetTCPConnection -LocalPort 2106` para ver o processo; mude a porta em **Server > Port...** e nos clientes |
| Clientes ficam esperando e a janela do servidor parece travada | O servidor 2.5 trata um pedido por vez (a ajuda diz que ele é "blocked", sem threads); um backup ou operação grande bloqueia os outros | Aguarde; evite o Live Backup em horário de uso |
| Live Backup falha | A pasta de destino não existe, ou não está na máquina do servidor, ou o serviço do Firebird não pode gravar nela | Crie a pasta na máquina do servidor e dê permissão ao serviço do Firebird |
| Auto Backup não aparece / não roda | Só existe na versão aplicação, não no serviço do Windows | Use a versão aplicação ou agende o `gbak` (capítulo 01, seção 8.3) |
| Servidor não inicia com o Windows | O item "Autostart with Windows" não vale no Windows moderno | Use tarefa agendada ao fazer logon ou a versão serviço (a validar) |
| O banner não vem na conexão | Servidor parado, ou "Disable Server Banner" marcado | Confira o servidor; veja o menu Security |

## 2. Conexão e login do cliente

| Sintoma | Causa | Solução |
|---|---|---|
| "No response from application server" / não conecta | Servidor parado, IP/porta errados, firewall, rede | Siga a lista da ajuda: servidor "Running" e `DBMS connected`; mesma porta; porta livre; **ping** funcionando; IP em vez de nome; mesma sub-rede; firewall liberando a porta e o `delphi32/bds.exe`; teste do banner |
| Conecta de dentro do servidor, mas não de outra máquina | A regra de firewall criada é só do perfil **Público**, ou a rede é Privada/Domínio | Crie regra pela porta 2106 para o perfil certo (capítulo 01, seção 6) |
| Conexão lenta em cada pedido | Host por **nome DNS** (nova consulta a cada pedido) | Use IP numérico |
| Usuário ou senha recusados | Maiúsculas/minúsculas (os dois diferenciam), Caps Lock, senha trocada | Padrão de fábrica: `sysdba` / `admin`, tudo minúsculo |
| A sessão cai de repente ("deslogado") | O servidor aceita **uma sessão por usuário**: um novo login do mesmo usuário (IDE, standalone, `jvcs.exe`) derruba o anterior. Também há "Login idle timer" e o admin pode usar Log Out | Um usuário por cliente simultâneo; confira Server Properties > Security |
| "Sync local time with server time" dá erro | Mudar a hora do Windows exige direito de administrador | Desmarque a opção ou peça o direito; mantenha os relógios por NTP |
| Cliente rejeitado por horário | "Verify Client Timestamp" ligado e relógio com mais de ±2 h de diferença | Acerte o relógio |
| Auto login não conecta | Só vale com cliente e servidor na mesma máquina; sem senha gravada exige "Enable local login w/o password" no servidor | Grave a senha na identidade (risco: capítulo 07) ou conecte manualmente |
| Identidade não salva | O nome tem `[`, `]` ou `\` | Troque o nome |
| `jvcs.exe` conecta em servidor de versão diferente sem avisar | O console não confere a versão do servidor | Cuide da compatibilidade (todos 2.5 Beta 3) |
| Esqueci a senha do `sysdba` e de todos os administradores | Senhas só podem ser trocadas sabendo a atual | **Avançado, com backup e servidor parado:** substituir o valor da coluna `PW` do usuário (tabela `USERS`, coluna `LOGIN`) pelo valor de `admin` (procedimento da ajuda para DBISAM; no Firebird use o valor do `INSERT` do `sysdba` em `fib_ib_defvalues.sql`). Não testado aqui. Alternativa segura: restaurar um backup |

## 3. Usuários, direitos e check-in

| Sintoma | Causa | Solução |
|---|---|---|
| Usuário não vê um projeto | Ele é Guest e não tem direito no projeto, ou o direito foi dado com o projeto aberto | Server > Administration > Project based Rights; peça para fechar e reabrir o projeto |
| Não consigo criar projeto | Nível Guest ou Read only (ou direito só por projeto) | Nível Read write ou superior no arquivo |
| "Check in only modules checked out by yourself" | Check-in **restritivo** ligado, ou o módulo está com outro usuário | Faça check-out antes; um Archive Administrator pode fazer check-in de módulo de outro |
| Check-in livre deixou alguém sobrescrever | O servidor está em **Casually Check In** (`CasuallyCheckin=1`) | Server Properties > Checkin > **Restrictive Check In** |
| Alterei um arquivo somente leitura à força e o check-in falhou ou gerou conflito | Atributo mudado fora do JEDI VCS | Nunca altere o atributo: faça Check Out. Veja a ajuda "Version control and the read-only flag" |
| O Delphi não salva o projeto depois do check-in | `.dpr`/`.res`/`.dproj` ficaram somente leitura | Faça Check Out do arquivo; confira a lista **Always writeable** (capítulo 04) |

## 4. Projetos e módulos

| Sintoma | Causa | Solução |
|---|---|---|
| **"Project names cannot be one of the following: project1.dpr, project1.bdsproj, project1.cbproj, project1.dproj, package1.dpk, projectgroup1.bpg, unit1.pas, unit1.dfm. See help topic 'Naming conventions'"** ao criar o projeto | Os nomes **padrão do Delphi** são proibidos: o JEDI VCS identifica o projeto só pelo nome e o módulo por nome e caminho, e esses nomes existem em qualquer máquina | No Delphi: **File > Save Project As...** (por exemplo `Ex1.dproj`) e **File > Save As...** para cada UnitN (por exemplo `uEx1Principal.pas`; o `.dfm`/`.fmx` acompanha). Feche e reabra o projeto e crie-o em **JEDI VCS > Project Manager**. Detalhes e outras regras de nome: [capítulo 02, seção 8.2](02-Cliente-Primeiro-Acesso.md) |
| "Project names cannot contain any of the following characters" | Nome com `"` `/` `\` `<` `>` `[` `]` `:` `;` `|` `{` `}` `*` `%` `?` ou tabulação | Renomeie. Evite também acentos |
| O JEDI VCS não reconhece o projeto novo | Projeto não salvo com nome válido, ou a IDE não reabriu o projeto (o expert observa a abertura/fechamento) | Salve com nome válido, feche e reabra o projeto |
| Arquivos em lugares diferentes em cada máquina, "módulo não encontrado" | O módulo é guardado com **caminho completo e letra da unidade**; todos precisam ter a mesma estrutura | Mesma pasta e mesma letra em todos; `subst`/junction; **UNC não é aceito** (use unidade mapeada) |
| Dois "projetos" se misturam | O nome de projeto é guardado **sem** caminho; nomes iguais viram um só | Use nomes únicos por projeto |
| `.fmx` não vai no check-in com o `.pas` | A família `.pas` não tem `.fmx` nas filhas, ou falta o `;` no fim | File Families Manager: `.dfm;.fmx;` ([capítulo 05](05-Familias-de-Arquivos.md)) |
| Arquivos duplicados no Project Manager depois de criar família de `.dpr` | Arquivos que já estavam adicionados à mão continuam na lista | Remova-os à mão; se o JEDI VCS perguntar sobre readicionar, marque "Don't ask me further" e responda No |
| Arquivo binário corrompido | Keyword expansion em extensão binária | Tire a extensão da lista; ative "Check for binary files" (capítulo 04) |
| Arquivo recusado | Passa de **20 MB**, nome com mais de 250 caracteres, ou projeto com mais de 2048 módulos | Divida o projeto ou exclua o arquivo |
| Backup/projeto em `\\servidor\pasta` não funciona | Os componentes ZIP não aceitam UNC | Mapeie uma letra de unidade |
| Diferenças só de comentários nos fontes | "Include version history in source files" ligado | Desligue (capítulo 04) |
| `Notify Init - Exception: Mailslot already exists` | Dois programas JEDI VCS no mesmo computador: só o primeiro cria o mailslot | Normal; ignore |

## 5. IDE e expert (Delphi 13)

| Sintoma | Causa | Solução |
|---|---|---|
| O menu **JEDI VCS** não aparece, sem splash (12/10/2026) | As mudanças de registro **não chegaram à IDE**: foram feitas com o Delphi aberto e a IDE regravou o registro ao fechar | Feche o Delphi e importe o `.reg` (ou rode o `reg add`) **com ele fechado**; só então abra |
| Idem, mesmo com o registro certo | Valor `JVCSIDEClient` ausente ou com caminho errado em `HKCU\Software\Embarcadero\BDS\37.0\Experts`; ou aberta a IDE de 64 bits | Confira o valor e o caminho; abra `bin\bds.exe` (32 bits). **Não** registre em `Experts x64` |
| Menu aparece com "JvcsExternalDll.dll not loaded - details…" | A DLL do cliente não está na pasta do expert, ou é de outra versão | Deixe `JvcsExternalDll.dll` e as DLLs de apoio na mesma pasta (capítulo 03, seção 3) |
| Quero ver o que o expert faz | (diagnóstico) | Defina `JVCS_EXPERT_LOG=C:\temp\jvcs-expert.log` (crie `C:\temp`), reinicie a IDE e leia o arquivo; ou use o DebugView (`[JVCS Expert]`) |
| `DelphiLSP.exe` falha (violação de acesso em `dcc32370.dll`) | Problema do LSP/IDE nesta máquina; aconteceu **antes** do expert existir | Independe do JEDI VCS (nenhum arquivo do expert está envolvido). Reporte à Embarcadero; não é corrigido por este manual |
| Janelas do JEDI VCS minúsculas ou borradas | A DLL (Delphi 2007) não é DPI-aware; o expert usa `gdiscaled` | Veja a linha de fonte abaixo; teste `JVCS_EXPERT_DPI=off` |
| IDE escura, janelas do JEDI VCS claras | A DLL tem VCL própria e não segue o tema | Limitação conhecida (capítulo 03) |
| Tab, atalhos ou dicas estranhos no Project Manager | Duas VCLs e laço de mensagens da IDE | Limitação conhecida; use mouse ou os atalhos do menu |
| Erro aleatório (AV) dentro da DLL | `bds.exe` é LARGEADDRESSAWARE e a DLL antiga pode falhar com endereços acima de 2 GB | Reporte com o log do expert |
| Nome de arquivo com `?` ou unidade não achada | Caracteres fora do CP 1252 (a DLL é ANSI) | Nomes só em ASCII |
| Unit ou projeto "invisível" para o JEDI VCS | Caminho com mais de 255 bytes | Pastas mais curtas |
| Diálogo de login aparece sobre o splash | Comportamento do expert original com "Auto connect" ligado | O expert atual adia o login até a IDE aparecer; se algo travar, `JVCS_EXPERT_DEFERINIT=off` volta ao comportamento do original |
| **AndroidSDK**: `Java JDK not found` na instalação do Delphi 13 (12/10/2026) | Falta um JDK compatível | Instale o **JDK 21 (Temurin)** e repita a instalação do recurso em **Tools > Manage Features** |
| `EnvOptions.proj` volta ao Library Path antigo (builds por MSBuild) | A IDE regrava o arquivo ao abrir/fechar, ainda considerando o Virtual Treeview 8.3 do GetIt | Só afeta builds por MSBuild fora da IDE; o `tools\compilar.bat` usa caminhos próprios. Pendência em [Status.md](../common/Status.md) |
| Não consigo recompilar o expert | A `JvcsExpertBDS37.dll` está travada pela IDE aberta | Feche o Delphi e rode `tools\compilar-expert.bat` |

## 6. Aparência, fonte e desempenho

| Sintoma | Causa | Solução |
|---|---|---|
| Fonte e menus pequenos num monitor 32" QHD a 100% | Fontes fixas e sem DPI; em 100% o Windows não amplia | **Configurações > Acessibilidade > Tamanho do texto**; ou **Sistema > Tela > Escala 125%** (na IDE, o expert amplia as janelas da DLL com `JVCS_EXPERT_DPI=gdiscaled`); para o `jedivcs.exe`: Propriedades > Compatibilidade > Alterar configurações de DPI alto > Substituir comportamento = **Sistema (Avançado)**. A opção própria virá com o port ([Requisito-Tamanho-Fonte.md](../client/Requisito-Tamanho-Fonte.md)) |
| Project Manager lento ao abrir | Projeto grande, pasta de rede, "Show local info" e "detailed file type" ligados | Desligue as duas opções (capítulo 04) |
| Menu JEDI VCS lento | "Check module state automatic on menu pull down" ligado | Desligue |
| Fechar a IDE ou trocar de projeto demora 1 a 2 s | "GExperts Workaround" ligado sem GExperts | Desligue em Special/Debug |
| Check-in lento | Keyword expansion, "Undo Check Out unchanged", `$History`, criptografia | Desligue o que não precisa (capítulo 04) |
| Erro de "request timeout" | O servidor demorou mais que o limite (padrão 120 s) | Aumente em Special/Debug; verifique se o servidor está em backup |

## 7. Quando pedir ajuda

Junte: versão (`jvcs.exe`/`jedivcs.exe` 2.5.0.1030, servidor 2.50 Beta 3), mensagem completa, o trecho do `server.log` (Log > Show Logfile...), o log do expert (`JVCS_EXPERT_LOG`), `C:\Program Files\Firebird\Firebird_2_5\firebird.log` e o que você fez antes. **Não** envie senhas, o `jvcssrv.ini` nem exportações de registro com identidades.
