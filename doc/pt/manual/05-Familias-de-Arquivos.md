# 05. Famílias de arquivos (`.pas` + `.dfm` + `.fmx`)

Uma **família de arquivos** diz ao JEDI VCS que um grupo de arquivos com o mesmo nome e extensões diferentes deve ser tratado como **um só** no check-in, check-out, get e backup. É o que faz o `Unit1.pas` levar o `Unit1.dfm` junto. Em projetos **FMX** (inclusive mobile) o `.fmx` precisa estar na família; senão ele não vai no check-in. Análise completa: [Checkin-Familias-FMX.md](../client/Checkin-Familias-FMX.md).

## 1. Como funciona

- As famílias ficam **no servidor**, uma lista única para todos os clientes (IDE, standalone, console, IA). O que você muda vale na hora para todos.
- Cada família tem uma extensão **pai** (Parent) e uma lista de extensões **filhas** (Child).
- No Project Manager só o **pai** aparece. Os filhos aparecem em **Get/ Version History**.
- No check-in, o cliente pergunta ao servidor quais são as filhas da extensão do módulo e inclui as que **existirem na mesma pasta**. Se a filha não existe no disco, é ignorada. Por isso a mesma família `.pas` → `.dfm;.fmx;` serve para units VCL (`.dfm`) e FMX (`.fmx`).
- A família é resolvida **pela extensão na hora do check-in**, não é guardada por módulo. Consequência (a validar): módulos já versionados sem o `.fmx` só passam a levá-lo no próximo check-in.
- A expansão de palavras-chave (keyword expansion) vale para o pai, não para os filhos.

## 2. Regras de escrita

| Regra | Exemplo |
|---|---|
| Cada extensão começa com **ponto** e termina com **`;`** | `.dfm;.fmx;` |
| **Sem curingas** (`*`, `?`) | `.dfm` correto, `*.dfm` errado |
| A **última** filha também leva `;`. O cliente ignora uma filha sem `;` no final | `.dfm;.fmx;` e não `.dfm;.fmx` |
| Nome da família até 50 caracteres; lista de filhas até 250 | |

## 3. Passo a passo: acrescentar `.fmx` à família `.pas`

Precisa de um usuário com direito de administração. **Faça primeiro no servidor de teste.**

1. Conecte (standalone ou **JEDI VCS > Project Manager...** na IDE).
2. Menu **Tools > File Families Manager...**
3. Na lista **File Families** (colunas Family, ID, Description, Changed, Parent, Child) selecione a família cujo **Parent** é `.pas`. No servidor novo ela se chama **Delphi forms** (`.pas` → `.dfm`).
4. Em **Child**, deixe `.dfm;.fmx;` (use o botão `...` para editar as extensões). Opcional: `.xfm;` (CLX antigo).
5. **OK**. Vale imediatamente para todos os clientes.
6. Teste: num projeto Dummy com uma unit FMX, faça o check-in do `.pas` e abra **Get/ Version History**: o `.fmx` deve aparecer junto.

> **Atenção:** a ajuda desaconselha **apagar ou mudar** a família "Delphi forms" por compatibilidade com versões antigas. Acrescentar `.fmx;` **mantém** `.dfm;` e é o que fazemos. Não retire o `.dfm`.

Para criar uma família nova: no File Families Manager clique com o botão direito e **Add...** (ou Ctrl+A). Campos: **Family name**, **Parent ext.**, **Child extensions** (separadas por `;`) e **Description**. O menu **Family used By** mostra quem usa a família.

## 4. Famílias recomendadas

Revise no servidor antes de aplicar.

| Parent | Child | Observação |
|---|---|---|
| `.pas` | `.dfm;.fmx;` | Units VCL e FMX |
| `.dpr` | `.dproj;.res;` | Projeto moderno (`.bdsproj`/`.dof` são de versões antigas) |
| `.dpk` | `.dproj;.res;` | Pacotes |
| `.groupproj` | (nenhuma) | Só ele |

Atenção com as famílias de `.dpr`/`.dpk` na **IDE**: o Project Manager monta a lista pela ToolsAPI. Se você cria uma família para o `.dpr` incluindo `.dproj`/`.res` e esses arquivos já estavam adicionados à mão ao projeto do JEDI VCS, eles **não somem sozinhos** da lista. Remova-os manualmente; se o JEDI VCS perguntar sobre readicioná-los, marque "Don't ask me further about.." e responda **No**.

**Nunca versionar:** `.dproj.local`, `.identcache`, `.dsk`, `.stat`, as pastas `__history\` e `__recovery\` e os `*.dcu`.

## 5. Arquivos que a IDE regrava

Depois do check-in os arquivos ficam **somente leitura**. O `.dpr`, o `.res` e (no Delphi atual) o `.dproj` são regravados pela IDE o tempo todo; se estiverem somente leitura, o Delphi não consegue salvar o projeto. Veja a lista **Always writeable** em [VCS Properties > Filter Values](04-Opcoes-do-Cliente.md) e, para alterá-los, faça Check Out antes (o Delphi deve ter ao menos `.dpr`, `.res` e `.dof` graváveis).

## 6. Quem mais usa isso

- O **expert** do Delphi trata `.fmx` como o `.pas` correspondente no menu de contexto do Project Manager.
- No **port**, a tela e o `HasAssociateFile` deixarão de ter `.dfm` fixo; a criação das famílias padrão com confirmação do administrador está planejada ([Checkin-Familias-FMX.md](../client/Checkin-Familias-FMX.md), seção 3). No cliente 2.5.0.1030 atual, só o procedimento manual acima.
- No `jvcs.exe`, `checkin` já inclui a família.
