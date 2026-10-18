# Check-in de famílias de arquivos (.pas + .dfm / .fmx) e outras opções

Requisito (12/10/2026): no check-in, `.pas` + `.dfm` vão juntos por padrão, mas em projetos **FMX (mobile)** o `.fmx`
precisa ser marcado à mão. Deve funcionar igual: `.pas` + `.fmx`.

## 1. Como funciona hoje (evidências no código)
- As **File Families** ficam **no servidor**: cada família tem uma extensão **pai** e uma lista de extensões **filhas**
  (tela *Tools → File Families Manager...*, form `TVCSMaintainFFamilies`, `src\jedivcs\MaintainFFamilies.pas`; ação `acFileFamilies`).
- **Check-in na GUI/IDE** (`src\jedivcs\ChkInSingle.pas:1238-1264`): o servidor devolve as extensões da família do módulo
  (`Answer.Fields[0]`, ex. `.dfm;`) e o `FamilyID`; o cliente acrescenta cada filha que **existir** no disco ao lado do `.pas`.
- **Check-in no console** (`src\jvcs\jvcs.dpr:888-895`): `TJVCSGetFamilyExtensions` com `ParentExtension := ExtractFileExt(ModuleName)`
  — a família é resolvida **pela extensão no momento do check-in**, não guardada por módulo.
- **Checkout / get / backup**: `GetAdditionalFilesFromFileFamily` (`src\jedivcs\VCSProcBase.pas:1656`) usa a lista de famílias carregada
  do servidor (`DataModule1.FileFamilyList`).
- Único ponto com `.dfm` fixo no código: `HasAssociateFile` (`VCSProcBase.pas:774-801`), usado em `ProjAdmin.pas:4031` e `:4276`
  para mostrar/abrir o arquivo associado na interface (não afeta o que vai para o servidor).
- Atenção ao formato: o laço do `ChkInSingle` só considera filhas **terminadas por `;`** (uma filha sem `;` no final é ignorada).

## 2. Solução imediata — funciona JÁ com o cliente 2.5.0.1030 (sem código)
Com um usuário com direito de administração no servidor:
1. *JEDI VCS → Project Manager* (ou `jedivcs.exe`) → conectar → **Tools → File Families Manager...**
2. Abrir a família cujo **Parent** é `.pas` (normalmente a que já tem `.dfm`).
3. Em **Child**, deixar: `.dfm;.fmx;` (com `;` no final de cada uma). Opcional: `.xfm;` (CLX antigo).
4. OK. Vale na hora para todos os clientes (GUI, IDE, console/IA), porque a lista vem do servidor.
Como só entram filhas que **existem no disco**, a mesma família serve para units VCL (`.dfm`) e FMX (`.fmx`).
Teste no servidor de teste antes de alterar a produção (quinta-feira, 15/10/2026).

Famílias recomendadas (revisar no servidor):

| Parent | Child | Observação |
|---|---|---|
| `.pas` | `.dfm;.fmx;` | units VCL e FMX |
| `.dpr` | `.dproj;.res;` | projeto moderno (o `.bdsproj`/`.dof` são de versões antigas) |
| `.dpk` | `.dproj;.res;` | pacotes |
| `.groupproj` | — | só ele |
Nunca versionar: `.dproj.local`, `.identcache`, `.dsk`, `.stat`, `__history\`, `__recovery\`, `*.dcu`.

## 3. No port (v2026)
1. `HasAssociateFile` passa a usar as famílias do servidor (com fallback `.dfm`/`.fmx`), em vez de `.dfm` fixo.
2. **Famílias padrão**: na primeira conexão (ou em *File Families Manager*, botão "Restaurar padrões"), propor as famílias da tabela
   acima se não existirem — sempre com confirmação do administrador (é configuração do servidor).
3. Corrigir o parser do `ChkInSingle` para aceitar a última filha sem `;` (mesma rotina `StrTokenToStrings` usada em `VCSProcBase`).
4. Expert da IDE: quando o arquivo ativo for `.fmx`, tratar como o `.pas` correspondente (já feito em `src\jvcsideexpert`).
5. CLI/IA: o `checkin` do console já inclui a família; a saída JSON (ver ADR de CLI) deve listar os arquivos efetivamente enviados.

## 4. Outras opções de check-in analisadas

| Opção | Existe hoje? | Proposta |
|---|---|---|
| Check-in de vários módulos de uma vez | GUI: seleção múltipla no Project Manager | CLI: `checkin` múltiplo e `checkin --changed` (todos os módulos alterados do projeto) |
| "Check in all changed" do projeto | parcial (Synchronize/compare) | comando/menu que lista alterados (CRC/data) e faz check-in em lote com um comentário |
| Comentário obrigatório / modelo de comentário | opção "Prompt for description" | modelo com prefixo do ticket (`ExtBugtracker`/regex) e histórico de comentários recentes |
| Vincular bug/ticket | sim (`ExtBugtracker`, regex `(?<bug>...)`) | manter; na CLI `--bug 123` |
| Label no check-in | sim (labels) | CLI `--label` |
| Checkout automático ao editar na IDE | não | expert: ao modificar um arquivo read-only sob controle, oferecer checkout (notifier do editor) |
| Check-in ao salvar/fechar | não | opcional, desligado por padrão (risco de check-ins acidentais) |
| Undo checkout | sim | manter; CLI `undocheckout` |
| Check-in "restritivo" (só quem fez checkout) | configuração do servidor | respeitar; CLI mostra erro claro |
| Keyword expansion (`$Revision$` etc.) | sim | manter; cuidado com o CRC (`ORIGCRC`) e arquivos binários |
| Arquivos novos (adicionar + check-in) | sim ("Add") | CLI `add` + `checkin` com família automática |
| Pré-checagem (compila? units novas no `.dproj`?) | "Check for Build OK" | opcional antes do check-in na IDE |
| Dry-run | não | CLI `--dry-run` mostra os arquivos da família que seriam enviados |
