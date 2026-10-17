# 06 - Solução de problemas

Para cada sintoma: a causa e o que fazer. Rode os comandos de diagnóstico no **seu** terminal, na pasta
do projeto (`$w` = caminho do `jvcs-ai.ps1`).

```powershell
$w = 'C:\Program Files (x86)\JEDI\JVCS 2026\tools\ai\jvcs-ai.ps1'
& $w identity -Test -Text
& $w config list -Text
& $w status -Project <Projeto>.dpr -Text
& $w locks -All -Text
```

## `local=unknown -> pathTruncated` no `status`

**Causa.** O console mostra só 47 caracteres do caminho registrado no servidor, seguidos de `...`. O
`status -Project` procura o arquivo sob a pasta do `.dpr` (e, se não achar, a partir do prefixo
visível). Quando não encontra, devolve `unknown`/`pathTruncated`.

**Solução.**
- Rode `status` dentro da pasta do projeto ou passe o arquivo: `status <arquivo>`.
- Confira se o projeto local está na **mesma pasta** registrada no servidor (ver "caminho diferente" abaixo).
- `pathCheck=prefix` em `status`/`list` é normal: checkout e check-in provam o caminho antes de agir.

## Projeto não encontrado / `informe -Project`

| Mensagem | Causa | Solução |
|---|---|---|
| `[ERRO 2] informe -Project <nome.dpr> (não há um único .dpr/.dpk na pasta atual)` | a pasta tem mais de um `.dpr`/`.dpk` com nome próprio (ex.: `Exemplo01.dpr` e `Exemplo01 - Copia.dpr`) ou nenhum | `-Project Exemplo01.dpr`, ou remova as cópias da pasta do projeto |
| `projeto '<nome>' não existe no servidor` (5) | o projeto não foi criado no JEDI VCS, ou o nome difere | crie pelo cliente (Project Manager); confira com `projects` |
| arquivo em dois projetos no mesmo nível (5) | ambiguidade | `-Project` |
| `notVersioned` | o arquivo não é módulo do projeto | se for o caso, `add <arq> -Comment "..."` (console 2026, modo de check-in) ou pelo cliente |

## Nomes padrão (`Project1`, `Unit1`) recusados

**Causa.** O JEDI VCS identifica o projeto só pelo nome e recusa os nomes padrão do Delphi
(`project1.dpr/.dproj`, `package1.dpk`, `projectgroup1.bpg`, `unit1.pas/.dfm`): todos os "Project1" de
todos os computadores cairiam no mesmo projeto. O wrapper ignora `Project1`/`Package1` na escolha
automática do projeto.

**Solução.** No Delphi, **Save Project As** e **Save As** de cada unit com nomes próprios; feche e
reabra o projeto e crie-o no servidor. Detalhes: `doc/pt/manual/02-Cliente-Primeiro-Acesso.md` §8.2.

## Caminho do projeto diferente do registrado no servidor (`pathMismatch`, 5)

**Causa.** O console lê e grava **no caminho registrado no servidor**, não no arquivo que você indicou.
Se a sua cópia está em outra pasta, o wrapper detecta (sonda de data) e recusa com 5 `pathMismatch`,
sem fazer nada. Situações típicas:

- a pasta **Documentos foi movida pelo OneDrive** (`C:\Users\<você>\OneDrive\Documentos\...` em vez de
  `C:\Users\<você>\Documents\...`): o Delphi passa a abrir os projetos no caminho novo e o servidor
  continua com o antigo;
- outra letra de unidade, outro usuário do Windows, cópia de trabalho em outra pasta;
- caminho UNC (não suportado pelo JEDI VCS).

**Solução.**
- Abra e edite o projeto no caminho registrado (veja-o no Project Manager do cliente).
- Ou faça o caminho registrado existir apontando para a cópia real: `subst`, junction
  (`mklink /J`) ou unidade mapeada.
- Sinais no `list`: `Stamp=N/A` (arquivo ausente no caminho do servidor) → `localState=missing`.
- Não tente "forçar": `pathMismatch` protege contra check-in de outra cópia.

## O Claude Code não aplica hooks nem regras

**Causa.** A pasta não foi marcada como confiável, ou o settings foi instalado em outro escopo.

**Solução.**
- Abra o projeto no Claude Code e aceite a **confiança da pasta**. Sem isso, hooks e `allow` do
  `.claude\settings.json` não valem (cada chamada ao wrapper pede aprovação).
- Confira se `<projeto>\.claude\settings.json` (ou `settings.local.json`, com `-Scope local`) tem os
  hooks `pretooluse.ps1`/`stop.ps1`. Rode o instalador de novo (é idempotente).
- Versão do Claude Code: 2.1.295 ou mais nova (`claude --version`).
- A IA usou outra forma de chamar o wrapper (barras invertidas, `&`, caminho relativo): a regra `allow`
  não casa e o Claude Code pergunta. A skill manda usar a forma canônica.

## O `Edit` converteu um arquivo ANSI para UTF-8 / acentos viraram `�`

**Causa.** O `Edit` do Claude Code não recusa arquivos Windows-1252: regrava em UTF-8 e troca acentos de
linhas não editadas por U+FFFD. O hook nega isso quando está instalado e a pasta é confiável.

**Solução.**
- Se ainda não fez check-in: `undocheckout <arq> -Discard -Confirmed` restaura a base (com backup), ou
  restaure o arquivo de um backup e refaça a edição com `edit-preserve.ps1`.
- Se tentou o check-in: o wrapper recusa com 7 `encodingChanged` e mantém o lock; corrija a codificação
  e tente de novo.
- Garanta hooks ativos (seção anterior).

## Locks pendurados (módulos em checkout esquecidos)

**Causa.** A IA fez checkout (modo `auto`) e a edição foi negada, falhou ou a sessão terminou.

**Solução.**
- O hook Stop lista os checkouts da sessão que ficaram presos (com ou sem alteração).
- `locks -Text` mostra os seus; `locks -All -Text`, os de todos.
- Sem alteração: `undocheckout <arq>`. Com alteração: check-in, ou `undocheckout <arq> -Discard -Confirmed`.
- Lock de outra máquina ou da IDE: resolva pelo cliente (Project Manager → Undo Check Out), copiando o
  arquivo antes se houver alteração.

## Timeout (9) ou mutex ocupado (12)

**Causa.** Servidor lento ou fora do ar, rede, ou outra chamada da mesma identidade em andamento (o
mutex serializa IA, hook e você).

**Solução.**
- `identity -Test -Text` para ver se o login funciona.
- Aumente `timeoutSec`/`lockWaitSec` (`config set`, no seu terminal) ou use `-TimeoutSec`/`-LockWaitSec`.
- Depois de timeout em checkout/check-in/undocheckout, o wrapper confere o servidor e compensa locks.
  Rode `status` e `locks` para confirmar o estado.

## Credencial (4)

| Mensagem | Solução |
|---|---|
| `nenhuma identidade salva` | conecte uma vez pela GUI com *Store Password with identity* |
| `identidade '<nome>' não existe` | confira `config get identity` e os nomes no Server Login |
| sem senha salva / login recusado | salve a senha de novo na identidade (cuidado: no cliente antigo, conectar com a opção desmarcada apagava a senha salva; corrigido no cliente 2026) |

## Ambiente (12)

`jvcs.exe` ausente ou não reconhecido: confira `config get jvcsExe`. O wrapper só aceita executável com
`OriginalFilename=jvcs.exe` e `ProductName` com "JEDI". O `fvcscrypt.dll` (32 bits) precisa estar ao lado.

## Comentário recusado (2)

O comentário deve ter **uma linha**, sem aspas duplas, até 2000 caracteres e só caracteres do
Windows-1252 (nada de emoji ou travessões especiais fora da tabela).

## Onde olhar

| Arquivo | Conteúdo |
|---|---|
| `%LOCALAPPDATA%\JEDI\JVCS\ai-audit.log` | uma linha JSON por comando do wrapper |
| `%LOCALAPPDATA%\JEDI\JVCS\backup\` | backups de `-Force`/`-Discard` |
| `%LOCALAPPDATA%\JEDI\JVCS\sessoes\` | checkouts por sessão (para o hook Stop) |
| `%APPDATA%\JEDI\JVCS\config.ini` | modos e opções |
| `-Raw` em qualquer comando | saída bruta do console no JSON |
