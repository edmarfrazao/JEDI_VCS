🇧🇷 Português · [🇺🇸 English](../en/README.md)

# Novidades — JEDI VCS 2.5 Beta 2026

> ⚠️ **Aviso:** este produto é fornecido sem garantia de funcionamento. Teste e valide em ambiente próprio, com backup e cópia do seu banco do JEDI VCS, e faça as correções locais necessárias antes de instalar em produção. Leia o [aviso completo](../../DISCLAIMER.md).

Notas de versão e anúncios de cada beta do **JEDI VCS 2.5 Beta 2026**, o cliente do JEDI VCS 2.5
portado para o Delphi moderno (servidor 2.5 Beta 3 sem alterações, protocolo idêntico).

> **English:** release notes for each beta of JEDI VCS 2.5 Beta 2026 — the JEDI VCS 2.5 client ported to modern
> Delphi (11, 12, 13), fully compatible with the existing 2.5 Beta 3 server. Each page has an English summary.

| Versão | Data | Situação | Destaques |
|---|---|---|---|
| [Beta 6](2026-10-17-beta6.md) | 17/10/2026 | [publicada](https://github.com/edmarfrazao/JEDI_VCS/releases/tag/v2.5.0.2026-beta6) | **build 2061**: console `jvcs.exe` 2026 no instalador (projeto e módulos sem IDE, histórico, busca, labels, ToDo, bugs, administração); wrapper da IA 1.4.0; a IA usa o console novo por padrão; S0002 (untracked, verify, doctor) |
| [Beta 5](2026-10-13-beta5.md) | 13/10/2026 | [publicada](https://github.com/edmarfrazao/JEDI_VCS/releases/tag/v2.5.0.2026-beta5) | **build 2050**: AV do XE3 corrigido; versão visível (título, About, Painel de Controle); docs e skills pt/en |
| [Beta 4](2026-10-13-beta4.md) | 13/10/2026 | [publicada](https://github.com/edmarfrazao/JEDI_VCS/releases/tag/v2.5.0.2026-beta4) | escolha por Delphi; IDEs antigas (7 a 10.4); skill de IA; docs pt/en — XE3: AV na barra (próxima beta) |
| [Beta 2](2026-10-13-beta2.md) | 13/10/2026 | [publicada](https://github.com/edmarfrazao/JEDI_VCS/releases/tag/v2.5.0.2026-beta2) | Delphi 11, 12 e 13 (qualquer atualização), tema escuro, correções, opções de aparência e IA |
| [Beta 1](2026-10-13-beta1.md) | 13/10/2026 | [publicada](https://github.com/edmarfrazao/JEDI_VCS/releases/tag/v2.5.0.2026-beta1) — substituída pela beta 2 | Primeiro instalador: cliente, Diff, console e expert do Delphi 13.2 |

Histórico técnico completo em [`CHANGELOG.md`](../../CHANGELOG.md). Como cada versão é testada e publicada:
[`doc/pt/processo/05-Processo-de-Release.md`](../../doc/pt/processo/05-Processo-de-Release.md).

## Política de publicação

1. Gerar o instalador com `tools\gerar-instalador.bat` (build Release completo).
2. Instalar e testar no PC de desenvolvimento (Delphi 11, 12 e 13) e no PC de testes remoto (Delphi 11, 12 e 13.1).
3. Só então publicar a release no GitHub (pre-release enquanto for beta) e a página de novidades.

## Download

Sempre pela página de [Releases](https://github.com/edmarfrazao/JEDI_VCS/releases). Confira o SHA-256 informado
na página de cada versão antes de instalar.
