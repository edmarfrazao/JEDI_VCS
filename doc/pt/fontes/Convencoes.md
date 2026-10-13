# Convenções

Regras para mexer no código e na documentação do JEDI VCS 2.5 Beta 2026.

## 1. Codificação e fim de linha

| Tipo de arquivo | Codificação | Fim de linha |
|---|---|---|
| Fontes Delphi (`.pas`, `.dpr`, `.inc`, `.dfm` texto, `.rc`) | **Windows-1252 (ANSI)**, sem BOM — como os fontes originais | CRLF |
| `.dfm` binários e `.res` | binário (não converter) | — |
| `.bat` | ASCII puro | CRLF |
| `.ps1` | UTF-8 **com** BOM (exigência do Windows PowerShell 5.1 para acentos) | CRLF |
| Documentação `.md` | UTF-8 sem BOM | CRLF |

- O `.gitattributes` tem `* -text`: o git **não** converte fim de linha; os bytes ficam exatamente como
  foram gravados.
- O compilador é chamado com `--codepage:1252`.
- **Nunca** regrave um fonte ANSI com uma ferramenta que salva em UTF-8 (inclusive o `Edit`/`Write` de
  assistentes de IA): acentos viram U+FFFD em linhas não editadas. Para a IA há um editor que preserva
  bytes ([doc/pt/ia](../ia/README.md)). Confira com `file <arquivo>` ou um editor que mostre a codificação.
- No fio do protocolo, texto é sempre cp1252 (`MWCodePage`); na ABI da DLL, `PAnsiChar` sem "best fit".

## 2. Defines

| Define | Onde | Efeito |
|---|---|---|
| `IDEDLL`, `EXT_IDE_INTF` | `dll` | compila o cliente como DLL da IDE com a interface externa |
| `JVCSCONSOLECLIENT` | `console` | partes de `src\jedivcs` usadas pelo console |
| `BRANCHING` | `exe`, `dll`, `console` | código de branch (exigido pelo servidor 2.50) |
| `JVCS_NOBRANCHUI` | `exe`, `dll` | esconde o menu Branch; branch fixo `HEAD` |
| `USECLIENTDISPATCHER` | `exe`, `dll` | requisições pelo dispatcher |
| `UNISYNEDIT` | `exe`, `dll` | SynEdit Unicode |
| `OVERBYTEV6_UP` | todos | units `OverbyteIcs*` do ICS 9 |
| `JVCS_NOREPORTS` | `compopt.inc` | sem `jedivcsreport.dll` (`REPORTDLL` desligado) |
| `LANGUAGE`, `REPORTDLL` | — | **desligados** (tradução e relatórios) |
| `DEBUG` | Debug | inclui `JVCSFormSweep` e a automação de teste |

Regras: o `compopt.inc` de cada pasta **não** recebe defines de alvo (eles vêm do script/`.dproj`); use
`MSWINDOWS`, nunca `WINDOWS`; mudanças marcadas com comentário `// v2026: ...` para quem comparar com o
original.

## 3. Versão

| Campo | Valor |
|---|---|
| Nome | JEDI VCS 2.5 Beta 2026 |
| FileVersion | `2.5.0.<Build>` de `tools\versao.ini` (beta 5 = `2.5.0.2050`; regra em [Versoes.md](../common/Versoes.md#numeração-de-versões)); ProductVersion `2.5.0.0` fixo |
| ProductVersion | `2.5 Beta 2026` |
| Flag | pré-lançamento (`VS_FF_PRERELEASE`) |
| Fonte única | `jvcsver.rc` de cada projeto e `JvcsExpertBDS_ver.rc`; "Include version information" desligado nos `.dproj` |
| Tags de release | `v2.5.0.2026-beta1`, `v2.5.0.2026-beta2`, ... |

O EXE e a DLL enviam no LOGIN o valor calculado do PRODUCTVERSION numérico (2.5.0.x → **250**); não mude
o formato `n.n.n.n`. Ver [Versoes](../common/Versoes.md).

## 4. Estilo de código

- Siga o estilo do arquivo que está editando (o código é de 2003–2012; não reformate arquivos inteiros).
- Sem dependência nova de terceiros: prefira RTL/VCL nativas (a meta é tirar JVCL, JCL e Abbrevia).
- Nada de genéricos da RTL e de unit de design-time no **expert**; funcionalidade nova vai para a DLL.
- Exceções nas entradas exportadas da DLL e nos handlers de aparência: `try/except` + `JVCSErrorLog`.
- A ABI expert↔DLL **não muda**; informação nova vai por variável de ambiente do processo.

## 5. Commits

- Mensagens em **português**, curtas, no formato `área: o que mudou` (ex.: `cliente: ...`, `expert: ...`,
  `tools: ...`, `doc: ...`, `setup: ...`), corpo explicando causa e efeito quando não for óbvio.
- Commits **pequenos** e focados; `git add` com caminhos explícitos.
- Mensagem em arquivo UTF-8 sem BOM (`git commit -F arquivo`) para os acentos saírem certos.
- Commits feitos com ajuda de IA terminam com a linha `Co-Authored-By:` correspondente.
- Nunca versionar credenciais, logs, `bin\`, `dcu\`, `lib\` ou capturas de tráfego brutas (contêm a senha
  cifrada) — ver `.gitignore`.

## 6. Como contribuir

1. Abra uma *issue* descrevendo o problema ou a proposta (versão do Delphi, passos, log de
   `%LOCALAPPDATA%\JEDI\JVCS\logs`).
2. Faça um fork, crie um branch e compile com `tools\compilar.bat all Debug Win32` e `Release`
   (0 erros) — ver [Compilação](Compilacao.md).
3. Se mexer em protocolo, CRC, ZIP ou cripto: refaça o golden do console contra um servidor 2.5 Beta 3
   ([04 Testes](../processo/04-Testes-e-Validacao.md)).
4. Se mexer no expert ou na DLL: `testar-dll.bat ambas`, `testar-expert.bat` e `verificar-expert.ps1`.
5. Se mexer em forms: `Jedivcs.exe -formsweep=<pasta>` (Debug) a 100% e 200%.
6. Atualize a documentação (`doc\`) e abra o pull request explicando o que foi testado.

Contribuições ficam sob a **MPL 1.1** (ou a licença do arquivo, quando diferente). Não envie código de
terceiros com licença incompatível (DFS, FastMM5 GPL etc.; ver [Licencas](../common/Licencas.md)).
