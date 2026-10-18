# Testes do JEDI VCS 2026

Scripts PowerShell que conferem o console `jvcs.exe`, o wrapper da IA (`tools\ai\jvcs-ai.ps1`) e o
instalador. Rodam sem a IDE. Todos os caminhos do repositório saem da pasta do próprio script; os
arquivos de trabalho ficam em `-Trabalho` (padrão `%TEMP%\jvcs-testes`).

> **Só rode contra um servidor de TESTE.** Os testes do console e da IA criam projetos e módulos de
> verdade no servidor (nomes com o prefixo `zz-teste-`), fazem checkout/checkin e apagam módulos do
> arquivo. Num servidor de produção isso deixa lixo e revisões novas.

## Pré-requisitos

- Servidor JEDI VCS 2.5 de teste no ar.
- Identidade **DEFAULT** cadastrada pelo cliente JEDI VCS (`HKCU\Software\JEDI\JEDIVCS\Identities\DEFAULT`),
  apontando para o servidor de teste. Os scripts só leem essa identidade; nunca a alteram.
  A senha vai do registro direto para o stdin do console: não aparece na tela, na linha de comando,
  em arquivo nem em log, e não existe parâmetro de senha.
- Console compilado em `bin\client\Win32\jvcs.exe` (ou informe `-Console`).
- Para o teste do instalador: o setup em `setup\Output` e o **Delphi fechado**.
- `git.exe` no PATH para a parte de Git do teste da IA (sem ele, essa parte é pulada).

## Como rodar

```
tests\executar.bat              console e ia
tests\executar.bat console      só o console
tests\executar.bat ia           só a IA
tests\executar.bat instalador   só o instalador
tests\executar.bat tudo         todos
```

O `executar.bat` roda os scripts com os padrões. Para passar parâmetros, rode o `.ps1` direto:

```
powershell -NoProfile -ExecutionPolicy Bypass -File tests\console\teste-correcoes.ps1 -ProjetoExemplo exemplo.dpr -ModuloExemplo 4 -ArquivoExemplo C:\projetos\exemplo\uPrincipal.pas
```

Rode `console\teste-modulos.ps1` antes de `ia\teste-s0002.ps1`: o teste da IA reaproveita a pasta
criada por ele (untracked com a pasta gravada em 8.3). O `executar.bat` já segue essa ordem.

## Resultado

Cada verificação imprime `[OK]` ou `[FALHA]`; partes sem os pré-requisitos imprimem um aviso
`[PULADO]` com o motivo. No fim sai `==== OK: n  FALHA: n  PULADO: n`.

Código de saída: **0** = nenhuma falha, **1** = alguma falha. Testes pulados não contam como falha.
O `executar.bat` devolve 1 se qualquer script falhou.

As saídas do console ficam em `<Trabalho>\console\<nome>.txt` (cp1252) e o roteiro enviado em
`<nome>.in.txt`; os logs do setup em `<Trabalho>\setup\*.log`. Comece por eles ao investigar uma falha.

## Scripts

### console\golden.ps1

Auxiliar dos outros testes. Roda um `jvcs.exe` com `/input` (cp1252, ou UTF-8 com BOM com
`-Utf8Bom`) e a senha da identidade DEFAULT pelo stdin. Servidor e porta saem da identidade
(`-Servidor`/`-Porta` mudam isso, por exemplo para passar por um proxy de captura).

Parâmetros: `-Nome`, `-Linhas` (obrigatórios), `-Exe`, `-Servidor`, `-Porta`, `-Cwd`, `-Saida`,
`-Captura` (pasta do proxy de captura: grava `prefix.txt` com o nome do teste), `-Utf8Bom`.

### console\teste-modulos.ps1

- `addmodule` com a pasta atual na forma 8.3 cria o módulo e grava a pasta 8.3;
- `addmodule` de novo com a pasta na forma longa não duplica (`Module already in project`, mesmo ID);
- `addproject` de projeto existente (`Project already exists`, sem o bloco de ajuda);
- `addmodule` em outro projeto liga o módulo existente (`Module linked`) e `sharedby` mostra os dois;
- `removemodule <id> archive` sem `confirm` só mostra a sintaxe; com `confirm` apaga o módulo sem revisão.

Cria `zz-teste-mod<Sufixo>.dpr` e `zz-teste-mod<Sufixo>d.dpr` (módulos `x.txt` e `semrev.txt`).

Parâmetros: `-Trabalho`, `-Console`, `-Sufixo` (padrão: data e hora, para cada rodada usar projetos novos).

A forma 8.3 da pasta é pedida ao Windows na hora. Se o volume não tiver nomes 8.3, a conferência da
pasta 8.3 é pulada e o `addmodule` usa só a forma longa.

### console\teste-correcoes.ps1

- checkin com `/input` em cp1252 e depois em UTF-8 com BOM: revisões seguidas e acentos certos no eco;
- com o proxy de captura (`-Captura` e `-PortaCaptura`): o comentário chega em cp1252 no fio;
- com o console 2.5 original (`-ConsoleOriginal`, padrão `%ProgramFiles(x86)%\JEDI\JVCS\jvcs.exe`):
  `getmodule` da revisão nova é igual à cópia local e o `listproject` dele lê a revisão.

Usa um projeto que já existe no servidor de teste: `-ProjetoExemplo` (nome do projeto),
`-ModuloExemplo` (ID do módulo) e `-ArquivoExemplo` (arquivo local desse módulo). O teste acrescenta
duas linhas de comentário ao arquivo e grava duas revisões. **Sem esses três parâmetros, o ciclo
inteiro é pulado.**

### ia\teste-s0002.ps1

Testes do wrapper com um APPDATA temporário (`[ai] identity=DEFAULT`, checkout/checkin automáticos;
o `config.ini` real não é tocado):

- opções inválidas devolvem código 2;
- `doctor` e `ping` (config, jvcsExe, fvcscrypt.dll, identidade, porta, login);
- `Test-JaTcpPort` com uma porta fechada (`-PortaFechada`, padrão 2109) e com a porta do servidor;
- `status -AllProjects` e `-Only modified`;
- `untracked` numa pasta de projeto, com a pasta gravada em 8.3 e com `-FromXbp`;
- projeto `zz-teste-ia<Sufixo>.dpr`: `add`, `add -Preview`, `locks -OlderThan` com um lock recém-criado,
  `verify -FromGit`/`-Since`, `checkin -CommentFromGit`, `diff -Encoding oem`.

Parâmetros: `-Trabalho`, `-Console`, `-Sufixo`, `-ProjetoExemplo` (projeto existente com 2 ou mais
módulos), `-PastaExemplo`, `-UnitNaoVersionada`, `-UnitVersionada` (pasta local de um projeto e dois
`.pas` dela, um fora e um dentro do servidor), `-PastaModulos` (padrão: a pasta mais recente do
`teste-modulos.ps1` com nomes 8.3), `-PortaFechada`.

### instalador\teste-setup.ps1

Teste isolado do setup: tudo com `/CURRENTUSER` numa pasta temporária, `/BDSKEY` e `/OLDIDEROOT`
desviados para `HKCU\Software\JVCS2026Teste` e `/AICONFIG` numa cópia do `config.ini`. Não registra
o expert nas IDEs instaladas nem mexe no `config.ini` real.

- instalação, versão do `jvcs.exe`, wrapper e skills iguais aos do repositório;
- tarefa `aiconsole`: lembrada ao reinstalar, desmarcada com `/TASKS=`, marcada com `/MERGETASKS=aiconsole`;
- desinstalação devolve o `config.ini` ao hash original;
- com `-SetupAnterior`: atualização de um beta sem a tarefa (marca a tarefa, também em outra pasta)
  e `/LOADINF` com `Tasks=` vazio (vale o `.inf`).

Parâmetros: `-Trabalho`, `-Setup` (padrão: `setup\Output\JediVCS-*-build<Build>-Setup.exe` com o
Build de `tools\versao.ini`, ou o `JediVCS-*-Setup.exe` mais recente), `-SetupAnterior`
(**sem ele, os passos de atualização são pulados**).

Este teste não substitui a instalação real: para conferir o expert nas IDEs, instale o setup pelo
Explorer (duplo clique), com o Delphi fechado, e abra a IDE.

## Testes pulados por padrão

| Script | Parte | Para habilitar |
|---|---|---|
| teste-correcoes.ps1 | ciclo checkout/checkin inteiro | `-ProjetoExemplo`, `-ModuloExemplo`, `-ArquivoExemplo` |
| teste-correcoes.ps1 | conferência do fio | `-Captura`, `-PortaCaptura` |
| teste-correcoes.ps1 | leitura pelo console original | console 2.5 em `-ConsoleOriginal` |
| teste-modulos.ps1 | pasta gravada em 8.3 | volume com nomes 8.3 |
| teste-s0002.ps1 | `status -AllProjects`/`-Project` com projeto conhecido | `-ProjetoExemplo` |
| teste-s0002.ps1 | `untracked` numa pasta de projeto | `-PastaExemplo`, `-UnitNaoVersionada`, `-UnitVersionada` |
| teste-s0002.ps1 | `untracked` com pasta em 8.3 | rodar antes o `teste-modulos.ps1` ou `-PastaModulos` |
| teste-s0002.ps1 | `verify -FromGit`, `-CommentFromGit` | `git.exe` no PATH |
| teste-setup.ps1 | atualização de beta anterior | `-SetupAnterior` |

## Limpeza

Os projetos `zz-teste-*` ficam no servidor de teste; apague-os pelo cliente quando quiser. A pasta
`-Trabalho` pode ser apagada a qualquer momento. O teste do instalador deixa a chave
`HKCU\Software\JVCS2026Teste`, que também pode ser apagada.
