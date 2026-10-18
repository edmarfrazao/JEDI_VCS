# Como gerar o instalador (beta) do JEDI VCS 2.5 Beta 2026

Guia prático para gerar à mão um setup novo, conferir, testar e, só no fim, publicar. Os scripts estão em
`instalador\bin`. Detalhes do instalador (componentes, tarefas, registro e testes): [setup/LEIAME.md](../../setup/LEIAME.md).
Numeração de versões: [doc/pt/common/Versoes.md](../../doc/pt/common/Versoes.md). Processo de release:
[doc/pt/processo/05-Processo-de-Release.md](../../doc/pt/processo/05-Processo-de-Release.md).

## 1. Pré-requisitos (uma vez)

- **Delphi:**
  - Delphi 13.2 com JCL, JVCL, ICS e Abbrevia pelo GetIt (ver [doc/pt/fontes/Compilacao.md](../../doc/pt/fontes/Compilacao.md));
  - Delphi 11 e 12 só para compilar os experts deles: sem eles, o pacote leva os experts que já estiverem em
    `bin\ideclient\Win32`.
- **Inno Setup 6:** em `%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe` ou no caminho da variável `JVCS_ISCC`.
- **Pasta de distribuição** (opcional, recomendada): copie `instalador\config\distribuicao.exemplo.bat` para
  `instalador\config\distribuicao.bat` e ajuste `JVCS_COPIA_SETUP`.
  - É a pasta compartilhada de onde o PC de testes instala.
  - O `distribuicao.bat` fica fora do git.

## 2. Versão

A versão sai **só** de `tools\versao.ini` (`Build`, `Stage`, `StageNumber`). Ela entra no VERSIONINFO de todos os
binários, no nome do setup e no Painel de Controle.

| Caso | Build | Comando |
|---|---|---|
| Beta nova N | 2000 + N×10 (beta 7 = 2070) | `versao.bat 2070 7` |
| Recompilação de correção da mesma beta | +1 (2061, 2062, …) | `versao.bat 2062` |
| Versão final | 2100, com `Stage=Release` | editar `tools\versao.ini` |

`versao.bat` sem argumento mostra a versão atual. O script recusa um build fora da regra.

## 3. Gerar

Feche o Delphi e rode:

```bat
instalador\bin\gerar.bat
```

O script faz, em ordem:

1. Compila em Release Win32, pelo `tools\gerar-instalador.bat`:
   - `Jedivcs.exe`, `JvcsExternalDll.dll`, `JEDIVCSDiff.exe` e `jvcs.exe` (Delphi 13);
   - os experts `JvcsExpertBDS37/22/23.dll` dos Delphi instalados, conferidos pelo `tools\verificar-expert.ps1`.
2. Confere se todos os binários têm a versão 2.5.0.`<Build>` e se o runtime e as ferramentas da IA estão presentes.
3. Empacota com o Inno Setup: `setup\Output\JediVCS-2.5.0-Beta<N>-build<Build>-Setup.exe`.
4. Com `JVCS_COPIA_SETUP` definida, copia o setup para a pasta de distribuição, confere o SHA-256 da cópia e regrava
   o `SHA256.txt` dela (`tools\copiar-setup.ps1`).
5. Mostra a conferência (`conferir.bat`).

Log: `tools\logs\gerar-instalador.log`. Código de saída: 0 = ok; 1 = falha (o log diz qual etapa).

Quando só mudou o que não é compilado (`tools\ai`, skills, textos do setup), use `gerar-sem-build.bat`. Ele empacota
o que já está em `bin\`, mas confere as versões do mesmo jeito.

**Atenção:** cada geração produz um setup com outro SHA-256, mesmo sem mudança no código, porque o Inno Setup grava
datas. Depois de gerar, atualize o hash nas novidades (`news\pt|en\...`).

## 4. Conferir

```bat
instalador\bin\conferir.bat
```

Mostra:

- a versão de `tools\versao.ini`;
- a versão e a data de cada binário em `bin\` (avisa se algum diverge);
- o setup, com o tamanho e o SHA-256;
- se a cópia na pasta de distribuição é igual ao setup gerado.

Para copiar de novo, ou para outra pasta: `copiar.bat [pasta]`.

## 5. Testar (antes de qualquer publicação)

1. **Teste isolado do instalador**, sem tocar no registro real nem no `config.ini` real. A instalação silenciosa usa
   os parâmetros de teste (`/CURRENTUSER`, `/BDSKEY`, `/OLDIDEROOT` e `/AICONFIG`), com os cenários descritos em
   `setup\LEIAME.md` §6.
2. **Instalar aqui pelo Explorer**, com o Delphi fechado. Um setup iniciado por uma ferramenta automática pode gravar o
   registro numa visão isolada, que o Delphi do usuário não vê. Depois:
   - abrir o Delphi 11, 12 e 13 e conferir o menu JEDI VCS e o log do expert
     (`%LOCALAPPDATA%\JEDI\JVCS\logs\jvcs-expert-*.log`: "JVCS Expert iniciando (versao 2.5.0.<Build> …)");
   - abrir o standalone e conferir o título e o About;
   - rodar a IA: `tools\ai\jvcs-ai.ps1 doctor`.
3. **PC de testes:** instalar a partir da pasta de distribuição, conferindo o SHA-256 pelo
   `SHA256.txt` da pasta.

## 6. Publicar (só depois dos testes no PC de desenvolvimento e no PC de testes)

- Novidades (`news\pt|en`), CHANGELOG, `doc\pt\common\Versoes.md` e READMEs com a versão e o SHA-256 do setup
  publicado.
- `git push` e a release no GitHub (pre-release enquanto for beta), com o setup e o SHA-256.

Ver [doc/pt/processo/05-Processo-de-Release.md](../../doc/pt/processo/05-Processo-de-Release.md).
