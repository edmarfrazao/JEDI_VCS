# 09. Instalador do cliente (JEDI VCS 2.5 Beta 2026)

Como instalar, reparar e remover o cliente portado (standalone, Diff, console, expert do Delphi e
ferramentas da IA) com o instalador `JediVCS-2.5-Beta2026-Setup.exe`. Detalhes técnicos, decisões e
testes: [setup\LEIAME.md](../../setup/LEIAME.md).

## 1. Onde está o instalador

- Gerado em `D:\Delphi\JediVCS\v2026\setup\Output\JediVCS-2.5-Beta2026-Setup.exe` por
  `tools\gerar-instalador.bat` (compila Release de tudo) ou `tools\gerar-instalador.bat --sem-build`
  (empacota o que já está em `bin\`).
- Para os colegas: copie só o `.exe` do setup. Ele traz tudo (inclusive a `fvcscrypt.dll` e as ajudas).

## 2. Antes de instalar

1. **Feche o Delphi** (todas as janelas do `bds.exe`). Se ele estiver aberto, o instalador pede para
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
   | Arquivos `.map` | O log de erros passa a dizer unit e linha (útil para relatar erro) |
   | Ferramentas da IA | `tools\ai` (wrapper, hooks e skill do Claude Code) dentro da pasta instalada |

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

## 5. Reinstalar, reparar ou atualizar

Rode o setup de novo (o mesmo ou um mais novo), com o Delphi fechado. Ele reaproveita a pasta e as
escolhas anteriores e substitui todos os arquivos. Para tirar o expert sem desinstalar o resto, rode de
novo e desmarque **Expert para o Delphi**: o `JVCSIDEClient` volta ao valor anterior.

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

## 8. Problemas comuns

| Sintoma | Causa e solução |
|---|---|
| "O Delphi (bds.exe) está aberto" | Feche todas as instâncias do Delphi (veja o Gerenciador de Tarefas) e clique em Repetir |
| Aviso "ainda não foi aberto por este usuário" | Abra e feche o Delphi uma vez e rode o setup de novo (reparar) |
| Menu JEDI VCS não aparece | Confira o `JVCSIDEClient` no registro e se a IDE é a de 32 bits (`bin\bds.exe`); veja o [capítulo 08](08-Solucao-de-Problemas.md) |
| O UAC pediu senha de outra conta e o expert não apareceu | O registro foi gravado no perfil da outra conta. Rode o setup escolhendo "só para mim" |
| Quer voltar ao expert de desenvolvimento | Desinstale (o valor anterior volta) ou importe `setup\Delphi13-JVCS-DLL-nova.reg` com o Delphi fechado |
