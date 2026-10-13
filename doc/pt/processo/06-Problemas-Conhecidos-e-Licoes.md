# 06. Problemas conhecidos e lições aprendidas

Problemas que apareceram durante o port, a causa e o que ficou de lição. Para sintomas de uso do dia a dia
veja também o [manual 08 — Solução de problemas](../manual/08-Solucao-de-Problemas.md). Anterior:
[05 Release](05-Processo-de-Release.md).

## Ambiente e ferramentas

| Problema | Causa | Solução / lição |
|---|---|---|
| Testes do instalador podiam alterar o registro real da IDE e o `config.ini` da IA | o setup grava em `HKCU\...\BDS\<v>\Experts` e em `%APPDATA%` | parâmetros **só para teste** `/BDSKEY=` e `/AICONFIG=` desviam as gravações; instalação silenciosa numa pasta temporária; o registro real foi exportado antes e depois (idêntico). Lição: testar instaladores em "sandbox" de chaves, nunca na configuração de quem desenvolve |
| Alterações no registro da IDE feitas por automação seriam difíceis de revisar e reverter | o assistente roda com permissões restritas e regras de negação (`.claude/settings.json`) | mudanças de registro da IDE ficam em `.reg` para o **usuário** aplicar (`setup\*.reg`); `.claude/settings.json` bloqueia leitura de chaves e tokens |
| `compilar.bat` deixou de achar JCL/JVCL/ICS (`jedi.inc` não encontrado) | a pasta **Documentos foi redirecionada para o OneDrive** (KFM) e o script procurava em `%USERPROFILE%\Documents` | o script passou a achar a pasta Documentos real (commit `b59378b`); contorno: `JVCS_CATALOG=<CatalogRepository>`. Lição: nunca montar caminhos de "Documentos" à mão |
| Projeto registrado no servidor com o caminho antigo de Documentos | mesma causa | junção temporária para os testes; o servidor guarda caminhos absolutos |
| `dcc32` não acha bibliotecas que a IDE acha | o compilador de linha de comando não lê o Library Path da IDE | `compilar.bat` monta todos os caminhos (`tools\versoes.ini`); `.dproj` usam `tools\msbuild\JediVCS2026.props` |
| MSBuild recompilava ~70 units do ICS/Abbrevia | o `EnvOptions.proj` da IDE traz as **fontes** dessas bibliotecas | `ImportEnvOptions=false` na linha de comando |
| `E2203 $WEAKPACKAGEUNIT contains global data` no ICS | `-$J+` global | `{$J+}` só por unit (o `compopt.inc` já faz) |

## Servidor e banco

| Problema | Causa | Solução |
|---|---|---|
| "unsupported on-disk structure ... found **11.2**, support **11.1**" | campo *Server* = `LOCALHOST`/vazio faz o servidor abrir o banco **sem host**, caindo no Firebird **2.1 embutido**; o banco tinha sido restaurado com o `gbak` 2.5 | usar um **IP** (`127.0.0.1`) no *Server*: a conexão vai por TCP ao Firebird 2.5. Detalhe: [Servidor-Teste-Local](../server/Servidor-Teste-Local.md) |
| Configuração do servidor "some" ou muda conforme quem executa | o servidor sem permissão em Program Files grava o `jvcssrv.ini` no **VirtualStore**; como administrador lê o de Program Files | manter os dois iguais; ver [manual 01 §5](../manual/01-Servidor-Instalacao-e-Configuracao.md) |
| "Column unknown BRANCHID" | banco de 2003 atualizado pelo servidor só até 2.42; o `Upgrade250` pressupõe as tabelas de branch | aplicar `UpdateV25.sql` + branch `HEAD` e reiniciar o servidor |

## Código e Unicode

| Problema | Causa | Solução |
|---|---|---|
| Comentários acentuados corrompidos no fio | `string` = UTF-16 no Delphi moderno | MidWare com `PAnsiChar` e **cp1252 fixa**; ABI da DLL em ANSI sem "best fit" |
| Todo arquivo parecia binário (Compare all, Line History, KWExpansion) | `IsTextStream` lia `array of Char` como bytes | `AnsiChar`/`System.AnsiStrings` (commit `e6455e2`) |
| AV no Line History | aritmética de `PChar` (2 bytes) no `textdiff` | `PByte`; hash sobre todos os bytes da linha |
| Estouro em `GetSelfFileName` | `SizeOf` no lugar de `Length` com `Char` = `WideChar` | `Length` |
| Blob ZIP com a hora do check-in no item | `AbZipFromStream` do Abbrevia 2026 grava `Now` | data do arquivo no `TJVCSAbZipper` (commit `b4d60e6`) |
| `{$ifdef WINDOWS}` nunca verdadeiro | o Delphi moderno só define `MSWINDOWS` | trocado no fonte |
| **`Edit` do Claude Code convertendo ANSI → UTF-8** | o `Edit` grava arquivo Windows-1252 trocando acentos por U+FFFD, inclusive em linhas não editadas; o `Write` regrava em UTF-8 sem BOM e LF | hook nega `Edit`/`Write` em fonte ANSI e a IA usa um editor que preserva bytes. Lição: conferir a codificação de **todo** arquivo tocado por ferramenta |
| Login do console falhava quando chamado pelo PowerShell | o .NET grava BOM UTF-8 no stdin antes da senha | wrapper inicia o processo com codificação 1252 |
| Tabelas do console com `#0` | `StrAlign` grava `#0` após cada coluna (também no original) | quem lê a saída troca por espaço |

## IDE e expert

| Problema | Causa | Solução |
|---|---|---|
| **Expert do 13.2 não carrega no 13.1** ("Could not find Wizard", erro 127) | com runtime packages, a `initialization` de toda unit de pacote no grafo de `uses` vira import; o `DockForm` (designide) ganhou uma unit no 13.2 | ToolsAPI local sem `DockForm`; só `rtl`/`vcl`/`xmlrtl`; `verificar-expert.ps1`. Lição: **pacotes de design-time mudam entre updates**, o expert deve depender do mínimo |
| `TList<T>` no expert | genéricos importam `TListHelper` interno do `rtl<nn>.bpl` | arrays dinâmicos |
| Menus da DLL em branco no tema escuro (bug também da original) | o hook de menus da IDE pinta o fundo e o texto owner-draw não era repassado | texto entregue ao hook de menus da IDE |
| A DLL pintava a IDE inteira com o seu estilo | sys style hooks da VCL da DLL | hooks desregistrados; tema "contido" nas janelas da DLL |
| "Follow Delphi" errado (Delphi 11 claro com o registro em Dark) | o valor `Theme` do registro nem sempre reflete o tema aplicado | o expert lê o tema real pela ToolsAPI e passa `JVCS_IDE_THEME` (`Light` ou `Dark`) à DLL (commit `d0d9994`) |
| Janela do JEDI VCS sumia atrás da IDE no Alt+Tab | forms sem dono | dono = `TAppBuilder` |
| Dois modais ao mesmo tempo (login + "no active IDE project") | aviso no `OnActivate` do login | aviso antes do `ShowModal` (commit `37a15a6`) |
| Expert não aparece na IDE de 64 bits | DLL 32 bits não carrega em `bin64\bds.exe` | registrar só em `Experts`; o instalador remove valor nosso de `Experts x64` |
| Instalador registrava o expert numa IDE nunca aberta | `Experts` gravado antes da 1ª execução impede a IDE de criar a configuração padrão | só registra se `HKCU\...\BDS\<v>` existe; senão avisa |

## Interface

| Problema | Causa | Solução |
|---|---|---|
| Lentidão de 20+ s ao abrir projeto | `FillListView` copiava **todos** os ícones da lista do sistema | cópia sob demanda (209 → 49 ms) |
| Crash ao ler opção de aparência | valor gravado com outro tipo no registro | leitura tolerante + `try/except` + log |
| Senha salva da identidade apagada ao conectar | o Connect limpava a senha | só apaga por ação explícita |
| Cortes a 175–200% | forms restauram tamanho salvo em outra escala no `OnShow` | `TJVCSForm` aplica o tamanho mínimo também após `OnShow`/`OnActivate` |
| `PasswordChar = #207` virava "Ï" | DFM antigo lido como Unicode | `*` |

## Lições gerais

1. **Golden antes de refatorar:** comparar bytes no fio com o original pegou problemas que nenhum teste
   unitário pegaria (data no ZIP, code page).
2. **Engenharia reversa documentada vale ouro** quando o fonte se perdeu: cada algoritmo recuperado tem
   pseudocódigo e vetores de teste.
3. **O mínimo de dependências no que roda dentro da IDE.**
4. **Ferramentas de diagnóstico no próprio produto** (`-formsweep`, automação, log de erros) aceleram
   muito o teste com IA.
5. **Registrar cada decisão com data** ([Decisoes](../common/Decisoes.md)) evita rediscutir o escopo.
