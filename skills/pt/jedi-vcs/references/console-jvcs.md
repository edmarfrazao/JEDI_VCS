# Console jvcs.exe (sem o wrapper)

Referência para **humanos** e scripts de build. A IA deve usar o wrapper `jvcs-ai.ps1`: o console
sozinho devolve 0 mesmo com erro, não mostra a recusa do servidor, muda o estado do servidor antes de
perguntar coisas que não consegue perguntar com a entrada redirecionada, e a forma documentada recebe
a senha na linha de comando.

Programa: `jvcs.exe` 2.5.0.1030 (original, `C:\Program Files (x86)\JEDI\JVCS`) ou 2.5.0.2026 (novo,
`C:\Program Files (x86)\JEDI\JVCS 2026`), com `fvcscrypt.dll` ao lado. Os comandos são os mesmos.

## Sintaxe

```text
jvcs servidor:porta /user Usuario /password Senha /comando argumentos...
jvcs servidor:porta -user Usuario -password Senha -comando argumentos...
```

- Sem `servidor:porta`: `localhost:2106`.
- Sem `/password` e com a entrada redirecionada, o console lê a senha da primeira linha da entrada
  padrão (é assim que o wrapper faz, sem expor a senha). **Evite `/password`**: a linha de comando
  aparece na lista de processos, no histórico do shell e em transcrições de IA.
- Sem comando: modo interativo (`jvcs>`), saia com `exit`.
- Vários comandos: arquivo de texto e `/input arquivo.txt` (dentro do arquivo, sem `/`).
- Comandos de módulo exigem `openproject` antes (na mesma sessão / no mesmo `/input`).
- Códigos de saída: 1 erro não especificado, 2 parâmetros inválidos, 3 nada sincronizado (só com
  `extexitcode`). Erros dentro de `/input` **não** mudam o código: leia a saída (linhas `[EClasse] ...`).

## Comandos

| Comando | Faz | Efeito |
|---|---|---|
| `listprojects` | lista projetos | leitura |
| `listproject <nome\|id> [includehidden]` | módulos do projeto (caminho truncado em 47 caracteres) | leitura |
| `listlocks [<usuário>\|all_users]` | módulos em checkout | leitura |
| `openproject <nome\|id>` | abre o projeto para os comandos seguintes | sessão |
| `checkout <módulo\|id>` | checkout | servidor e disco |
| `checkin <módulo\|id> [comentário]` | check-in; sem mudança não faz nada | servidor |
| `undocheckout <módulo\|id>` | desfaz o checkout | **sobrescreve o arquivo local** |
| `getmodule <módulo\|id> [rev=v.r] [dest="pasta"] [noprompt]` | baixa uma revisão | disco |
| `labelproject <projeto> <"label">` | aplica label | servidor |
| `syncproject <projeto> [noprompt] [stamp\|crc] [crossref] [includehidden\|deletehidden] [extexitcode] [label="nome"]` | sincroniza a pasta | **grava/apaga no disco** |
| `syncprojectgroup <grupo> [mesmas opções]` | sincroniza um grupo | **grava/apaga no disco** |
| `input <arquivo>` | executa comandos de um arquivo | |
| `help [<comando>]`, `exit` | ajuda, sair | |

Não existem no console: `add` (módulo novo), `diff`, `log`, `whoami`.

## Exemplo seguro (senha pelo stdin, sem /password)

```powershell
# cmds.txt (CP1252):
#   openproject exemplo01.dpr
#   listlocks
$exe = 'C:\Program Files (x86)\JEDI\JVCS 2026\jvcs.exe'
$cred = Get-Credential -UserName usuario -Message 'Senha do JEDI VCS'
$cred.GetNetworkCredential().Password | & $exe servidor:2106 /user usuario /input cmds.txt
```

Cuidados conhecidos:

- Com o console em UTF-8 (`chcp 65001`, ou dentro de ferramentas de IA) o .NET pode mandar um BOM
  antes da senha e o login falha; o wrapper contorna isso.
- `checkout`, `undocheckout` e `getmodule` podem mudar o estado (lock, arquivo) e **depois** perguntar
  algo; com a entrada redirecionada a pergunta falha e o lock pode ficar pendurado.
- `checkin` não mostra a recusa do servidor: confira a versão depois com `listproject`.
- `syncproject ... noprompt crc` sobrescreve qualquer arquivo local que não esteja em checkout seu.
- Comentário e caminhos em ANSI (CP1252); comentário sem aspas duplas.

Referência completa: `doc/pt/client/jvcs_params.txt` e `doc/pt/manual/06-Linha-de-Comando.md` do repositório.
