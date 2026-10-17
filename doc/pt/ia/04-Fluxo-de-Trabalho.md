# 04 - Fluxo de trabalho

Como uma alteração feita pela IA passa pelo JEDI VCS, do pedido ao check-in.

## Passo a passo

```text
 status ──► checkout ──► editar ──► compilar/testar ──► check-in ──► locks
   │           │            │                              │
   │           │            └─ Edit (UTF-8) ou edit-preserve (ANSI, UTF-16, arquivo inteiro)
   │           └─ automático pelo hook (auto) ou checkout -Confirmed (confirm)
   └─ lock de outro? local alterado? caminho diferente? → parar e avisar
```

1. **Estado.** `jvcs-ai.ps1 status "<arq>"` (exato) ou `list -Project x.dpr` (rápido).
   - `lockedBy` com outro usuário → não editar, avisar.
   - `localState=modified` sem checkout → alguém alterou fora do VCS; perguntar antes de
     `checkout -Force -Confirmed`.
   - `notVersioned` → o arquivo não está no JEDI VCS; edite normalmente; para versioná-lo, `add` (só se você pedir; console 2026).
2. **Checkout.**
   - `checkout=auto`: o hook faz sozinho quando a IA usa o `Edit` (ou o `edit-preserve` faz).
   - `checkout=confirm`: `jvcs-ai.ps1 checkout "<arq>" -Confirmed`; você aprova no Claude Code.
   - `checkout=manual`: você faz o checkout na IDE ou no cliente.
   - Se o `Edit` disser que o arquivo mudou desde a leitura (o checkout mexe em atributo e data), a IA
     relê e repete.
3. **Editar.**
   - Arquivo UTF-8 (com ou sem BOM): o `Edit` do Claude Code serve (preserva BOM e CRLF).
   - Arquivo ANSI (Windows-1252), ASCII que vai receber acentos, UTF-16, ou regravação inteira:
     `edit-preserve.ps1`. O hook nega o `Edit`/`Write` nesses casos e mostra o comando certo.
   - Nunca `Write` sobre fonte Delphi existente.
4. **Compilar e testar** como o projeto pede.
5. **Check-in.** A IA mostra a lista de arquivos e o comentário; depois
   `jvcs-ai.ps1 checkin "<arq>" -Comment "Corrige ..."` (+ `-Confirmed` no modo confirm).
   - Código 3: não havia mudança; o checkout foi desfeito.
   - Código 7 `encodingChanged`: a codificação ou as quebras mudaram; corrigir com `edit-preserve`.
6. **Desistiu?** `jvcs-ai.ps1 undocheckout "<arq>"` (só se o arquivo voltou a ser igual ao servidor).
   Descartar a alteração: `undocheckout "<arq>" -Discard -Confirmed` (backup automático).
7. **Fim.** `jvcs-ai.ps1 locks` e informar o que ficou em checkout. O hook Stop também lembra.

## Exemplo real

Projeto `Exemplo01` (`uPrincipal.pas` em ANSI 1252 com CRLF), modo `auto`/`auto`.

**Prompt:**

```text
No uPrincipal.pas, troque o comentário final "// fim" por "// fim da unit principal".
Faça checkout e check-in pelo JEDI VCS com um comentário explicando a mudança.
```

**O que a IA fez** (sequência e resultados do teste de 12/10/2026, registrado em
`tools/ai/LEIAME.md` §9; o texto do comentário e o do check-in são ilustrativos):

| Etapa | Chamada | Resultado |
|---|---|---|
| estado | `jvcs-ai.ps1 status "uPrincipal.pas"` | `clean`, v0.3, sem lock, `pathCheck=prefix` |
| edição | `Edit` | **negado pelo hook**: arquivo ANSI, usar `edit-preserve` |
| edição | `edit-preserve.ps1 -Path "uPrincipal.pas" -Old "// fim" -New "// fim da unit principal"` | checkout automático (`verified`, 1,7 s) e 1 substituição; `encoding=ansi`, `eol=crlf` |
| check-in | `jvcs-ai.ps1 checkin "uPrincipal.pas" -Comment "Detalha o comentário final da unit"` | `[IA] Detalha ...`, **0.3 → 0.4**, lock liberado, `.pas`/`.dfm` somente leitura |
| fim | `jvcs-ai.ps1 locks` | 0 módulos em checkout |

**Resposta da IA (resumida):**

```text
Feito. uPrincipal.pas: comentário final alterado (codificação ANSI e CRLF preservadas).
Check-in 0.3 -> 0.4 com o comentário "[IA] Detalha o comentário final da unit".
Nenhum módulo ficou em checkout.
```

No mesmo teste, um checkout seguido de check-in **sem** mudança voltou com código 3
(`unchangedUndone`) e a versão continuou 0.4.

### Exemplo só de leitura

```text
Prompt: mostre o status do JEDI VCS deste projeto
```

```text
[OK 0] status (exemplo01.dpr)
  #4 uprincipal.pas v0.14 local=clean -> ok
  #3 exemplo01.res v0.1 local=clean -> ok
  #2 exemplo01.dproj v0.1 local=clean -> ok
  #1 exemplo01.dpr v0.1 local=clean -> ok
4 módulo(s) em exemplo01.dpr
```

## Boas práticas

- **Um módulo por vez.** Peça uma alteração, revise, faça o check-in e só então a próxima. Lotes grandes
  deixam locks presos por mais tempo e dificultam o `undocheckout`.
- **Comentário que explica o porquê**, numa linha, sem aspas duplas (`Corrige arredondamento do total
  quando há desconto`). O prefixo `[IA]` é automático; não o escreva.
- **Revise o diff antes do check-in.** O console não tem `diff`: peça à IA para mostrar o trecho
  alterado, use o *Compare* do cliente JEDI VCS, ou compare com uma cópia
  (`git diff --no-index base.pas uPrincipal.pas`).
- **Sem mudança, `undocheckout`.** Se a IA desistiu ou você negou a edição, o módulo fica travado sem
  motivo. O wrapper desfaz sozinho no check-in sem mudança (código 3); fora disso, peça
  `undocheckout`.
- **Não edite na IDE o que a IA travou** (e vice-versa). A IA usa a sua identidade: um checkout seu na
  IDE também conta como "meu" para ela.
- **Não rode sync com `noprompt`** enquanto a IA tiver locks.
- **Feche o arquivo na IDE** antes do checkout pela IA, se a IDE o mantiver aberto com bloqueio
  (o checkout falha e é compensado, código 7).
- **Prefira `confirm` no check-in** até se acostumar: você vê a lista e o comentário antes do envio.
- **Ao terminar a sessão**, peça `locks` e resolva o que ficou.
