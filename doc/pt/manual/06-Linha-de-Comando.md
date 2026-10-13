# 06. Linha de comando (`jvcs.exe`)

O cliente de console serve para automatizar sincronização e build e para consultas rápidas. É um **subconjunto** do que as versões gráficas fazem.

| Item | Valor |
|---|---|
| Programa | `C:\Program Files (x86)\JEDI\JVCS\jvcs.exe` (versão 2.5.0.1030; cópia de referência em `D:\Delphi\JediVCS\v2026\3rdparty\referencia-2.5.0.1030\jvcs.exe`) |
| Referência dos parâmetros | [jvcs_params.txt](../client/jvcs_params.txt) e o tópico "command line client" da ajuda |
| Compatibilidade | O `jvcs.exe` **não confere a versão do servidor**: a responsabilidade é sua |
| Código-fonte | `D:\Delphi\JediVCS\v2026\src\jvcs\jvcs.dpr` (o port ainda não compila, ver [Status](../common/Status.md)) |

## 1. Sintaxe

```
jvcs [servidor[:porta]] [/user Usuario] [/password Senha] /comando argumentos...
```

- Use `/` ou `-` como prefixo (`/user` ou `-user`).
- Sem `servidor:porta`, assume `localhost` e a porta `2106`.
- Sem `/user`, pergunta o usuário. Sem `/password`, pergunta a senha **sem eco** quando há console; se a entrada estiver **redirecionada** (pipe), lê usuário e senha das duas primeiras linhas da entrada (segundo o código, `jvcs.dpr` por volta da linha 3673; a validar).
- Sem nenhum comando, entra no **modo interativo** (prompt `jvcs> `). Saia com `exit`.
- Vários comandos: coloque-os num arquivo e use `/input arquivo.txt` (dentro do arquivo não se usa `/` nem `-`).
- Para guardar a saída: `jvcs ... > resultado.txt`.

Códigos de saída: `1` erro não especificado, `2` parâmetros inválidos, `3` nada foi sincronizado (só com `extexitcode`, útil para abortar um build se nada mudou).

Login confirmado em 12/10/2026 no servidor de teste: a saída traz `User accepted. Access level: 4 [Archive Admin] Branch: HEAD`.

## 2. Comandos

| Comando | O que faz | Tipo |
|---|---|---|
| `listprojects` | Lista os projetos do servidor | Leitura |
| `listproject <nome \| id> [includehidden]` | Lista os módulos do projeto | Leitura |
| `listlocks [<usuário> \| all_users]` | Módulos em check-out (padrão: o usuário atual) | Leitura |
| `listbranches` | Lista branches. Está no binário 2.5.0.1030 mas não na ajuda; este servidor mostra `Branch: HEAD` (a validar) | Leitura |
| `openproject <nome \| id>` | Abre o projeto (necessário antes de `checkin`, `checkout`, `undocheckout`, `getmodule`) | Estado da sessão |
| `checkout <módulo \| id>` | Check-out do módulo (nome e, se preciso, `unidade:\caminho`, ou o id) | **Grava no servidor e no disco** |
| `checkin <módulo \| id> [comentário]` | Check-in. Com check-in restritivo no servidor, só módulos que você já pôs em check-out. Sem alteração, não faz nada | **Grava no servidor** |
| `undocheckout <módulo \| id>` | Desfaz o check-out | **Sobrescreve o arquivo local** |
| `getmodule <módulo \| id> [rev=ver.rev] [dest="pasta"] [noprompt]` | Baixa uma revisão (a última, se omitir `rev`); `dest` escolhe outra pasta | **Grava no disco** |
| `labelproject <projeto> <"label">` | Marca o projeto com um label (cria o label se não existir; aspas se tiver espaço) | **Grava no servidor** |
| `syncproject <projeto> [noprompt] [stamp \| crc \| RO] [crossref] [includehidden \| deletehidden] [extexitcode] [label="nome"]` | Sincroniza a pasta local com o servidor | **Grava/apaga no disco** |
| `syncprojectgroup <grupo> [mesmas opções]` | Idem para todos os projetos (e subgrupos) de um grupo | **Grava/apaga no disco** |
| `input <arquivo>` | Executa os comandos de um arquivo | |
| `help [<comando>]` | Ajuda | |
| `exit` | Sai do modo interativo | |

Opções do `syncproject`:

| Opção | Efeito |
|---|---|
| `noprompt` | Cria pastas e sobrescreve arquivos **sem perguntar** |
| `stamp` (padrão) \| `crc` | Compara por data ou por CRC. `noprompt` + `crc` sobrescreve qualquer arquivo local, mesmo mais novo (exceto os que você tem em check-out) |
| `RO` | Também confere o atributo somente leitura (módulo não retirado deve estar somente leitura); mudanças só de atributo não são gravadas |
| `crossref` | Inclui os projetos referenciados |
| `includehidden` \| `deletehidden` | Trata módulos ocultos; `deletehidden` apaga os ocultos da pasta, menos os que alguém tem em check-out |
| `extexitcode` | Devolve o código 3 se nada foi sincronizado |
| `label="nome"` | Restaura o projeto ao estado desse label |

> **Atenção:** `sync` e `get` podem **sobrescrever o que você alterou** localmente se o módulo estiver em check-out e você sincronizar ou baixar por cima (aviso da própria ajuda). Teste sem `noprompt` primeiro.

## 3. O que o `jvcs.exe` original **não** faz

Os comandos acima são **todos** os que existem no 2.5.0.1030. Não há comando para **criar projeto**, **adicionar módulo novo** ao projeto, criar usuário, famílias de arquivos nem labels avulsos além do `labelproject`. A criação inicial do projeto e a adição dos arquivos é feita pela **GUI ou pela IDE** ([capítulo 02](02-Cliente-Primeiro-Acesso.md), seção 8.3).

No port, `createproject` e `addmodule` podem ser acrescentados: as classes de protocolo `TJVCSAddNewProject` e `TJVCSAddNewModule` já existem em `src\common\client\JVCSClientObj.pas`.

## 4. Exemplos seguros (somente leitura)

Modo interativo, **sem senha na linha de comando** (o programa pergunta, sem eco):

```
"C:\Program Files (x86)\JEDI\JVCS\jvcs.exe" 192.168.0.10:2106 /user edmar
jvcs> help
jvcs> listprojects
jvcs> listproject Ex1
jvcs> exit
```

Uma consulta direta, com a senha lida no console (sem `/password`):

```
"C:\Program Files (x86)\JEDI\JVCS\jvcs.exe" 192.168.0.10:2106 /user edmar /listlocks all_users
```

Vários comandos num arquivo, `C:\temp\verificar.txt`:

```
openproject Ex1
listproject Ex1
listlocks
```

```
"C:\Program Files (x86)\JEDI\JVCS\jvcs.exe" 192.168.0.10:2106 /user edmar /input C:\temp\verificar.txt > C:\temp\verificar-saida.txt
```

Fluxo com gravação (só depois de testar no projeto Dummy), arquivo `C:\temp\trabalho.txt`:

```
openproject Ex1
checkout uEx1Principal.pas
```

e, mais tarde, `checkin uEx1Principal.pas "ajuste do cálculo"` no mesmo formato.

Sincronização para build, sem perguntas, abortando se nada mudou:

```
jvcs <servidor>:2106 /user ci /syncproject Ex1 noprompt stamp extexitcode
```

(o usuário `ci` do capítulo 02 só precisa do nível Read only.)

> **Só no ambiente de teste:** este foi o comando de teste de 12/10/2026, com usuário e senha padrão na linha de comando:
> `jvcs 127.0.0.1:2106 /user sysdba /password admin /listprojects`
> Em produção **não use** `/password` (próxima seção).

## 5. Aviso sobre senha na linha de comando

`/password Senha` **expõe a senha** em: lista de processos (Gerenciador de Tarefas, WMI, antivírus/EDR), evento 4688 de auditoria, histórico do shell e **transcrições de ferramentas de IA** (o Claude Code, por exemplo, guarda o comando que roda). Também aparece em scripts e logs de build.

Alternativas com o cliente **atual**:
1. **Não passe `/password`**: o programa pergunta a senha sem eco.
2. **Entrada padrão redirecionada**, em PowerShell, sem escrever a senha em arquivo nem no histórico (segundo o código; a validar antes de usar em produção):

```powershell
$sec = Read-Host "Senha do JEDI VCS" -AsSecureString
$pw  = [System.Net.NetworkCredential]::new('', $sec).Password
$pw | & "C:\Program Files (x86)\JEDI\JVCS\jvcs.exe" 192.168.0.10:2106 /user edmar /listprojects
```

3. Um usuário **só para a automação**, com poucos direitos (capítulo 02, seção 5), para o estrago ser pequeno se a senha vazar.

> **Atenção:** o servidor deixa **uma sessão por usuário**. Se o `jvcs.exe` usar o mesmo usuário da IDE ou do standalone, ele pode derrubar a sessão do outro. Use usuários diferentes.

## 6. O que está planejado (não existe no `jvcs.exe` original)

Análise completa em [Credenciais.md](../common/Credenciais.md). Nada disto existe ainda; só passa a existir com o cliente portado.

| Plano | Resumo | Onde |
|---|---|---|
| **Identidade salva** | `jvcs <comando>` sem parâmetros de login usa a identidade `LastUsedID` do registro (a mesma da GUI e da IDE); `--identity <nome>` escolhe outra. A senha nunca é impressa | Credenciais.md, seção c.10 |
| Script provisório | `tools\jvcs-identidade.ps1` leria a identidade salva e passaria a senha por **stdin** ao `jvcs.exe` (ainda não existe em `tools\`) | Credenciais.md, seção c.10 |
| `jvcs login` / `logout` / `auth status` | Pede a senha, testa e guarda no **Gerenciador de Credenciais do Windows**; `jvcs credential migrate` limpa as senhas Base64 antigas | Credenciais.md, seções c.3 a c.5 |
| `--password-stdin`, `JVCS_PASSWORD_FILE` | Padrão de CI; `--password` na linha de comando **recusado** por padrão | Credenciais.md, seção c.4 |
| Saída **JSON** | Lista dos arquivos efetivamente enviados no `checkin` (inclui a família) | [Checkin-Familias-FMX.md](../client/Checkin-Familias-FMX.md), seção 3 |
| `checkin --changed`, `--dry-run`, `--bug`, `--label`, `add` | Check-in em lote e prévia dos arquivos da família | Checkin-Familias-FMX.md, seção 4 |
| `createproject`, `addmodule` | Criação de projeto e adição de módulos pela linha de comando | Seção 3 acima |
