# 09. Instalador do cliente (JEDI VCS 2.5 Beta 2026)

Como instalar, reparar e remover o cliente portado (standalone, Diff, console, expert do Delphi e
ferramentas da IA) com o instalador `JediVCS-2.5-Beta2026-Setup.exe`. Detalhes técnicos, decisões e
testes: [setup\LEIAME.md](../../../setup/LEIAME.md).

## 1. Onde está o instalador

- Gerado em `D:\Delphi\JediVCS\v2026\setup\Output\JediVCS-2.5-Beta2026-Setup.exe` por
  `tools\gerar-instalador.bat` (compila Release de tudo) ou `tools\gerar-instalador.bat --sem-build`
  (empacota o que já está em `bin\`).
- Para os colegas: copie só o `.exe` do setup. Ele traz tudo (inclusive a `fvcscrypt.dll` e as ajudas).

## 2. Antes de instalar

1. **Feche o Delphi** (todas as janelas do `bds.exe`; no Delphi 7, `delphi32.exe`). Se ele estiver aberto, o instalador pede para
   fechar (Repetir/Cancelar).
2. Abra o Delphi **pelo menos uma vez** com o seu usuário antes de instalar: se a IDE nunca foi aberta,
   o expert não é registrado (aparece um aviso; abra e feche o Delphi e rode o setup de novo).
3. Não precisa desinstalar o JEDI VCS original (`C:\Program Files (x86)\JEDI\JVCS`): os dois convivem.

## 3. Instalar

1. Execute o setup. Escolha o idioma (português do Brasil ou inglês).
2. Escolha **para todos os usuários** (pede administrador) ou **só para mim** (sem administrador).
3. Pasta: deixe `C:\Program Files (x86)\JEDI\JVCS 2026` (ou `%LOCALAPPDATA%\Programs\JEDI\JVCS 2026`
   para "só para mim"). A pasta do JEDI VCS original é recusada.
4. Componentes (todos marcados):

   | Componente | Para quê |
   |---|---|
   | Cliente | `Jedivcs.exe` (standalone), `JEDIVCSDiff.exe`, `jvcs.exe` (console) e ajudas |
   | Expert para o Delphi | Menu **JEDI VCS** na IDE de 32 bits; a linha mostra os Delphi detectados |
   | IDEs antigas detectadas | Só aparece se houver um Delphi de 7 a 10.4 Sydney instalado, com uma linha por IDE detectada. Instala o expert **original** 2.5.0.1030 daquela IDE ligado ao cliente novo (seção 4A) |
   | Arquivos `.map` | O log de erros passa a dizer unit e linha (útil para relatar erro) |
   | Ferramentas da IA | `tools\ai` (wrapper, hooks) e a skill `jedi-vcs` do Claude Code em `tools\ai\skills\pt\jedi-vcs` (português) e `tools\ai\skills\en\jedi-vcs` (inglês), dentro da pasta instalada. Para usar a skill, copie **uma** delas para `%USERPROFILE%\.claude\skills\jedi-vcs` (ver [setup\LEIAME.md](../../../setup/LEIAME.md), seção 3) |

5. Tarefas: atalho na área de trabalho (marcado) e **"Usar o console novo na IA"** (desmarcado: marque
   só se quiser que a automação por IA use o `jvcs.exe` novo em vez do original).
6. Conclua. Menu Iniciar → **JEDI VCS 2026**: cliente, Diff, ajuda, ajuda do Diff, pasta das
   ferramentas da IA e desinstalar.

## 4. O que muda no Delphi

Só um valor de registro por versão do Delphi detectada:
`HKCU\Software\Embarcadero\BDS\37.0\Experts` → `JVCSIDEClient` = `<pasta>\JvcsExpertBDS37.dll`
(22.0 / 23.0 para Delphi 11 / 12, quando esses experts forem incluídos no pacote). Se já havia um
`JVCSIDEClient` (por exemplo, o expert de desenvolvimento em `D:\Delphi\JediVCS\v2026\bin\ideclient\Win32`),
ele é guardado e volta quando você desinstalar.

Library Path, pacotes (`Known Packages`) e variáveis da IDE **não** são alterados: isso só é necessário
para compilar o port (ver [capítulo 03](03-Integracao-com-o-Delphi.md), método A).

Abra o Delphi e confira como no [capítulo 03, seção 5](03-Integracao-com-o-Delphi.md#5-verificar-se-carregou).

## 4A. IDEs antigas (Delphi 7 a 10.4 Sydney)

O JEDI VCS original 2.5.0.1030 tinha um expert para cada Delphi, do 7 ao 10.4 Sydney. O instalador 2026
reaproveita esses experts **originais**. Eles são só a ponte com a IDE: o trabalho fica todo na
`JvcsExternalDll.dll`, que agora é a **nova**. Assim, um Delphi XE3, por exemplo, ganha o menu **JEDI
VCS** com o cliente 2026 (as mesmas janelas, correções e opções do `Jedivcs.exe` novo).

- Na tela de componentes, **IDEs antigas detectadas** lista só os Delphi antigos encontrados no
  computador, todos marcados. Desmarque os que não quiser.
- Para cada IDE marcada, o setup grava o mesmo valor que o instalador original gravava:
  `HKCU\Software\<Borland|CodeGear|Embarcadero>\...\Experts` → `JVCSIDEClient` =
  `<pasta>\JvcsExpertBDS<n>.dll` (no Delphi 7, `JvcsExpertD7.dll`). Se o JEDI VCS original estava
  registrado ali, o valor dele é guardado e **volta na desinstalação**.
- Versões cobertas: Delphi 7, 2005, 2006, 2007, 2009, 2010, XE a XE8, 10 Seattle, 10.1 Berlin, 10.2
  Tokyo, 10.3 Rio e 10.4 Sydney. Também C#Builder 1 e Delphi 8 for .NET, como no original.
- **Delphi 5 e 6 (e C++Builder 5/6) ficam de fora.** Para eles, o original usava um cliente completo
  antigo, que não usa o núcleo novo. Nessas IDEs, continue com o instalador original.
- **Status:** o instalador foi testado com IDEs simuladas. O expert original com a DLL nova ainda **não
  foi testado numa IDE antiga real**. Se algo falhar, desmarque a IDE numa reinstalação: o
  `JVCSIDEClient` volta ao valor anterior.
- Limitações herdadas do expert original:
  - acentos no conteúdo do editor podem sair errados nas operações que leem ou escrevem o fonte (por
    exemplo, na expansão de keywords);
  - as janelas não seguem o tema escuro da IDE.

## 5. Reinstalar, reparar ou atualizar

Rode o setup de novo (o mesmo ou um mais novo), com o Delphi fechado. Ele reaproveita a pasta e as
escolhas anteriores e substitui todos os arquivos. Para tirar o expert sem desinstalar o resto, rode o
setup de novo e desmarque **Expert para o Delphi** (ou a IDE, em **IDEs antigas detectadas**): o
`JVCSIDEClient` volta ao valor anterior.

## 6. Desinstalar

Com o Delphi fechado: **Configurações → Aplicativos** (ou Painel de Controle → Programas) →
"JEDI VCS 2.5 Beta 2026" → Desinstalar, ou Menu Iniciar → JEDI VCS 2026 → Desinstalar.

A desinstalação remove os arquivos e atalhos, o `JVCSIDEClient` **se ele aponta para esta instalação**
(restaurando o anterior, se havia) e o `jvcsExe` que a tarefa da IA gravou (restaurando o anterior).
**Não** apaga identidades, senhas e opções (`HKCU\Software\JEDI\JEDIVCS`), nem logs
(`%LOCALAPPDATA%\JEDI\JVCS\logs`), nem o resto do `config.ini`.

## 7. Linha de comando (administradores)

```
JediVCS-2.5-Beta2026-Setup.exe /VERYSILENT /SUPPRESSMSGBOXES /CURRENTUSER /COMPONENTS=client,ide,maps,ai /TASKS=desktopicon /LOG=%TEMP%\jvcs-setup.log
"<pasta>\unins000.exe" /VERYSILENT /SUPPRESSMSGBOXES
```

Sem `/CURRENTUSER` instala para todos (precisa de prompt elevado). Com o Delphi aberto, o modo silencioso
aborta sem mudar nada (setup: código 7; desinstalação: código 1).

Em `/COMPONENTS`, as IDEs antigas se chamam `ideold\d7` e `ideold\bds<n>` (por exemplo, `ideold\bds10` =
XE3 e `ideold\bds21` = 10.4). Sem `/COMPONENTS`, uma reinstalação repete as escolhas anteriores.

## 8. Problemas comuns

| Sintoma | Causa e solução |
|---|---|
| "O Delphi (bds.exe ou delphi32.exe) está aberto" | Feche todas as instâncias do Delphi (veja o Gerenciador de Tarefas) e clique em Repetir |
| Aviso "ainda não foi aberto por este usuário" | Abra e feche o Delphi uma vez e rode o setup de novo (reparar) |
| Menu JEDI VCS não aparece | Confira o `JVCSIDEClient` no registro e se a IDE é a de 32 bits (`bin\bds.exe`); veja o [capítulo 08](08-Solucao-de-Problemas.md) |
| O UAC pediu senha de outra conta e o expert não apareceu | O registro foi gravado no perfil da outra conta. Rode o setup escolhendo "só para mim" |
| Quer voltar ao expert de desenvolvimento | Desinstale (o valor anterior volta) ou importe `setup\Delphi13-JVCS-DLL-nova.reg` com o Delphi fechado |

## Escolha por Delphi

Na página de componentes, **cada Delphi instalado aparece como uma opção**: o 11, o 12 e o 13 dentro de *Expert para o Delphi*
e as versões antigas (Delphi 7 a 10.4) dentro de *IDEs antigas*. Só os marcados recebem o expert; uma IDE desmarcada numa
reinstalação tem o registro desfeito. Em instalação silenciosa use `/COMPONENTS`, por exemplo
`/COMPONENTS="client,ide\bds23,ideold\bds10"` (Delphi 12 e XE3).
