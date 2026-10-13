[🇺🇸 English](README.md) · 🇧🇷 Português

# JEDI VCS 2.5 Beta 2026

> ⚠️ **Aviso:** este produto é fornecido sem garantia de funcionamento. Teste e valide em ambiente próprio, com backup e cópia do seu banco do JEDI VCS, e faça as correções locais necessárias antes de instalar em produção. Leia o [aviso completo](DISCLAIMER.md).

Cliente do **JEDI VCS** (controle de versão cliente/servidor para equipes Delphi) portado para o
**Delphi 11, 12 e 13**, com integração à IDE, tema claro/escuro, escala de fonte e suporte a assistentes de
IA. Fala **exatamente o mesmo protocolo** do servidor JEDI VCS **2.5 Beta 3** (Firebird), que continua o
mesmo.

[Download](https://github.com/edmarfrazao/JEDI_VCS/releases) ·
[Novidades](news/pt/README.md) ·
[Manual](doc/pt/manual/README.md) ·
[Documentação](doc/pt/README.md) ·
[IA](doc/pt/ia/README.md) ·
[Licença](LICENSE)

## English summary

**JEDI VCS 2.5 Beta 2026** is a port of the JEDI VCS 2.5 *client* (standalone GUI, IDE integration DLL,
diff tool and console) to **Delphi 11 Alexandria, 12 Athens and 13 Florence**. It is wire-compatible with
the unchanged **JEDI VCS 2.5 Beta 3 server** (Firebird): the new client sends byte-identical requests,
verified by golden traffic captures against the original 2.5.0.1030 client. Highlights: a thin
ToolsAPI expert per Delphi version that loads in every update (it imports only `rtl`, `vcl` and `xmlrtl`),
one shared client core, UI scaling (100–200%), light/dark theme following Windows or the IDE, an Inno
Setup installer, and a safe workflow for AI coding agents (Claude Code). Status: **public beta (beta 5, build 2050)**,
Win32 only. Download the installer from
[Releases](https://github.com/edmarfrazao/JEDI_VCS/releases). Documentation is in Brazilian Portuguese.
License: MPL 1.1; the MidWare transport is free for **non-commercial use only** (see below).
Full English version: [README.md](README.md) · English user guide: [doc/en](doc/en/README.md).

## Status

| Item | Situação |
|---|---|
| Versão | **2.5 Beta 2026** (`2.5.0.2026`), quinta beta pública, **build 2050** (`2.5.0.2050`, tag `v2.5.0.2026-beta5`), Delphi 7 a 13 |
| Delphi | testado em **Delphi 11, 12 e 13** (IDE de 32 bits) |
| Plataforma | Win32 (roda em Windows x64 e ARM64 por emulação) |
| Servidor | JEDI VCS **2.5 Beta 3** (Firebird) — não portado, sem alteração |
| Fases | console, Diff, EXE, DLL da IDE, expert e instalador prontos; ver [Status](doc/pt/common/Status.md) |

É uma **beta**: use com um servidor de teste ou com backup do banco antes de adotar em produção.

## Recursos principais

- **Integração com o Delphi 11/12/13:** menu **JEDI VCS**, atalhos (Ctrl+Shift+P/I/O/G/B), check-in e
  checkout pela IDE, aba **History** do editor e menu de contexto do Project Manager.
- **Cliente standalone** (`Jedivcs.exe`) com todos os recursos do 2.5: projetos, check-in/checkout,
  histórico, Line History, Compressed Diff, labels, backup com senha, sincronização, usuários.
- **Compatível com o original:** convive com o cliente 2.5.0.1030 e usa as mesmas identidades.
- **Aparência:** escala 100–200%, escolha de fonte (interface, menus, editores), tema claro/escuro
  seguindo o Windows (standalone) ou o Delphi (integrado).
- **Recursos de 2012 mantidos:** External Bugtracker, Save WIP, Compare all local/archive.
- **Famílias de arquivos:** `.pas` + `.dfm` + `.fmx` no mesmo check-in.
- **Console** `jvcs.exe` para scripts e para a IA.
- **IA:** wrapper e skill para o Claude Code fazer checkout/check-in com aprovação humana e preservando a
  codificação ANSI dos fontes ([doc/pt/ia](doc/pt/ia/README.md)).
- **Instalador** Inno Setup (pt-BR/inglês) que registra o expert só nas IDEs instaladas e desfaz tudo na
  desinstalação.

## Requisitos

| Para | Precisa de |
|---|---|
| Usar o cliente | Windows 10/11; um servidor JEDI VCS 2.5 Beta 3 acessível (porta 2106) |
| Integração com a IDE | Delphi 11, 12 ou 13 (qualquer atualização), **IDE de 32 bits**; nenhum componente de terceiros |
| Compilar | Delphi 13 (referência) ou 11/12; JCL, JVCL, ICS 9.7 e Abbrevia (GetIt); SynEdit e VirtualTreeView vêm no repositório |
| Servidor (se ainda não tem) | JEDI VCS Firebird Server 2.50 Beta 3 + Firebird 2.5 — ver [manual 01](doc/pt/manual/01-Servidor-Instalacao-e-Configuracao.md) |

## Instalação rápida

1. Feche o Delphi.
2. Baixe `JediVCS-2.5-Beta2026-Setup.exe` em
   [Releases](https://github.com/edmarfrazao/JEDI_VCS/releases) e execute (português ou inglês; dá para
   instalar só para o usuário atual).
3. Abra o Delphi: o splash mostra "JEDI Version Control System 2.5 Beta 2026" e aparece o menu
   **JEDI VCS**.
4. **JEDI VCS → Connect Server**: informe servidor, porta `2106`, usuário e senha. Num banco novo o usuário
   inicial é `sysdba` / `admin` (padrão do banco novo, **troque após o 1º login**).
5. Abra seu projeto e use **Project Manager**, **Check In** e **Check Out**.

Passo a passo completo: [manual 09 — Instalador](doc/pt/manual/09-Instalador-do-Cliente.md),
[02 — Primeiro acesso](doc/pt/manual/02-Cliente-Primeiro-Acesso.md) e
[03 — Integração com o Delphi](doc/pt/manual/03-Integracao-com-o-Delphi.md).

## Compatibilidade com o servidor 2.5 Beta 3

- Mesmos bytes no fio: texto em **Windows-1252**, CRC-32, Blowfish, Base64 e blobs ZIP idênticos ao
  cliente 2.5.0.1030 (validado por captura de tráfego e leitura cruzada de revisões).
- O cliente original lê o que o novo grava e vice-versa; os dois podem ficar conectados ao mesmo tempo.
- Recursos do servidor que dependem de branching funcionam com o branch `HEAD`; a UI de branches está
  oculta.
- Não suportado: cifragem LZH do tráfego (se o servidor exigir, a conexão falha com mensagem explícita), relatórios externos,
  notificação entre estações.

## Como compilar

```
tools\compilar.bat libs Release Win32        (uma vez: SynEdit e VirtualTreeView)
tools\compilar.bat all Release Win32         (Jedivcs.exe, JvcsExternalDll.dll, JEDIVCSDiff.exe, jvcs.exe)
tools\compilar-expert.bat Release nova       (JvcsExpertBDS37.dll; use /delphi:11 ou /delphi:12 para os outros)
tools\gerar-instalador.bat                   (instalador)
```

Também é possível abrir `JediVCS2026.groupproj` na IDE. Detalhes: [Compilação](doc/pt/fontes/Compilacao.md) e
[tools/LEIAME-compilar.md](tools/LEIAME-compilar.md).

## Estrutura do repositório

| Pasta | Conteúdo |
|---|---|
| `src\jedivcs` | cliente GUI: `Jedivcs.dpr` (EXE) e `JediVCSDLL.dpr` (DLL da IDE) |
| `src\jedivcsdiff` | `JEDIVCSDiff.dpr` |
| `src\jvcs` | `jvcs.dpr` (console) |
| `src\jvcsideexpert` | expert ToolsAPI e testes |
| `src\common`, `src\common\client` | units compartilhadas e núcleo do cliente |
| `src\comp` | MidWare portado, CRC, textdiff, SynEdit e VirtualTreeView fixados |
| `tools` | scripts de build, verificação do expert, golden de protocolo, canal de testes, ferramentas de IA |
| `setup` | instalador Inno Setup e `.reg` de desenvolvimento |
| `3rdparty` | runtime do 2.5.0.1030 (`fvcscrypt.dll`, ajudas, listas) e binários de referência |
| `skills\pt`, `skills\en` | skill `jedi-vcs` para assistentes de IA, em português e em inglês ([skills](skills/README.md)) |
| `doc\pt`, `doc\en` | documentação por idioma (abaixo); `doc\original` = arquivos do JEDI VCS original |

Mapa detalhado: [doc/pt/fontes](doc/pt/fontes/README.md).

## Documentação

| Para | Leia |
|---|---|
| Instalar e usar (servidor, cliente, IDE) | [Manual](doc/pt/manual/README.md) |
| Usar com IA | [doc/pt/ia](doc/pt/ia/README.md) e a skill [skills/pt/jedi-vcs](skills/pt/jedi-vcs/) |
| Entender o código | [doc/pt/fontes](doc/pt/fontes/README.md) — arquitetura, units, compilação, convenções |
| História, decisões, testes e release | [doc/pt/processo](doc/pt/processo/README.md) |
| Situação atual e decisões datadas | [Status](doc/pt/common/Status.md), [Decisões](doc/pt/common/Decisoes.md) |
| O que mudou em cada versão | [Novidades](news/pt/README.md) e [CHANGELOG](CHANGELOG.md) |
| Índice completo | [doc/pt/README.md](doc/pt/README.md) |

## IA

O projeto inclui um fluxo para assistentes de IA (Claude Code e outros agentes) usarem o JEDI VCS com
segurança: checkout automático só quando o arquivo local é igual ao servidor, check-in com aprovação e
prefixo `[IA]`, e edição que preserva a codificação Windows-1252. Comece por
[doc/pt/ia/README.md](doc/pt/ia/README.md); a skill está em [skills/pt/jedi-vcs](skills/pt/jedi-vcs/) (versão em inglês: [skills/en/jedi-vcs](skills/en/jedi-vcs/); ver [skills](skills/README.md)).

## Licenças

- O código do JEDI VCS é distribuído sob a **Mozilla Public License 1.1** — ver [LICENSE](LICENSE) e
  [doc/original/license.txt](doc/original/license.txt). Algumas partes são doações ou derivações com
  licença própria, indicada no cabeçalho de cada arquivo; leia o aviso completo antes de reutilizar.
- **MidWare (François Piette) — somente uso não comercial.** O transporte do cliente
  (`src/comp/midware`: `ApsCli`, `CBroker`, `RFormat`) é uma versão **alterada** (port Unicode para
  Delphi 13 / ICS 9) do MidWare, freeware **somente para uso não comercial**; o aviso original foi mantido
  em cada arquivo. Uso em aplicação comercial exige acordo com o autor. A substituição por um transporte
  próprio está planejada.

  This product is based on MidWare. Freeware source code is available at http://www.overbyte.be.
- Componentes: JCL/JVCL (MPL 1.1), SynEdit (MPL 1.1/GPL 2), VirtualTreeView (MPL 1.1/LGPL 2.1), ICS
  (freeware), Abbrevia (MPL 1.1); `fvcscrypt.dll` é o binário original redistribuído do instalador 2.50
  Beta 3. Resumo: [Licenças](doc/pt/common/Licencas.md) e [Componentes](doc/pt/common/Componentes.md).

## Créditos

- **JEDI VCS original** (FreeVCS / JEDI VCS 2.x): **Thomas Huber**, **Uwe Schuster** e a equipe do
  Project JEDI — ver [doc/original/credits.txt](doc/original/credits.txt) e
  [credits_jedivcsdiff.txt](doc/original/credits_jedivcsdiff.txt).
- **MidWare e ICS:** François Piette (OverByte).
- **Port 2026:** **Edmar Frazão**, com o **Claude Code** (Anthropic) como par de programação.

## Contribuição

Issues e pull requests são bem-vindos. Antes de enviar: compile os quatro alvos em Debug e Release, rode os
testes da área que mudou (golden do console para protocolo; harness para DLL/expert; `-formsweep` para
forms) e descreva o que testou. Regras de codificação (fontes em Windows-1252, CRLF), defines e commits:
[Convenções](doc/pt/fontes/Convencoes.md).
