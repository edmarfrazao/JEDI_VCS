# Manual de configuração do JEDI VCS 2.5 Beta 2026

Manual prático para instalar, configurar e usar o **servidor JEDI VCS 2.5 Beta 3 (Firebird)**, o **cliente** e o **expert do Delphi 13**. Escrito em 12/10/2026 a partir do que foi montado e testado nesta máquina e da ajuda oficial (`jedivcs.chm`).

Público: o administrador do JEDI VCS (você) e os colegas da empresa que vão usar o sistema.

## Por onde começar

| Situação | Leia, nesta ordem |
|---|---|
| Nunca montei o servidor | [01](01-Servidor-Instalacao-e-Configuracao.md) → [02](02-Cliente-Primeiro-Acesso.md) → [03](03-Integracao-com-o-Delphi.md) → [07](07-Senhas-Padrao-e-Seguranca.md) |
| O servidor já está de pé e quero só usar | [02](02-Cliente-Primeiro-Acesso.md) → [03](03-Integracao-com-o-Delphi.md) → [05](05-Familias-de-Arquivos.md) |
| Sou colega e vou usar na minha máquina | [09](09-Instalador-do-Cliente.md) (instalador) → [02](02-Cliente-Primeiro-Acesso.md) (identidade) → [03](03-Integracao-com-o-Delphi.md) (verificar o expert) → [04](04-Opcoes-do-Cliente.md) |
| Algo deu errado | [08 Solução de problemas](08-Solucao-de-Problemas.md) |
| Quero automatizar (build, scripts, IA) | [06 Linha de comando](06-Linha-de-Comando.md) e [07](07-Senhas-Padrao-e-Seguranca.md) |

## Índice

| Capítulo | Conteúdo |
|---|---|
| [01 Servidor: instalação e configuração](01-Servidor-Instalacao-e-Configuracao.md) | Servidor Firebird (aplicação × serviço), Firebird instalado × embutido, restaurar o banco com `gbak`, tela "Logon to Firebird", `jvcssrv.ini` e VirtualStore, porta 2106 e firewall, conferir que subiu, backup, menus do servidor, checklist de produção |
| [02 Cliente: primeiro acesso](02-Cliente-Primeiro-Acesso.md) | Identidade (Server Login), `sysdba`/`admin`, trocar senha, criar usuários (você e a IA), níveis de acesso, grupos, primeiro projeto e nomes proibidos |
| [03 Integração com o Delphi](03-Integracao-com-o-Delphi.md) | Expert "JEDI VCS 2.5 Beta 2026" no Delphi 13 (32 bits): pré-requisitos, registro, verificação, reverter, variáveis `JVCS_EXPERT_*`, limitações |
| [04 Opções do cliente](04-Opcoes-do-Cliente.md) | VCS Properties, página por página, com recomendações |
| [05 Famílias de arquivos](05-Familias-de-Arquivos.md) | `.pas` + `.dfm` + `.fmx`, File Families Manager, famílias recomendadas |
| [06 Linha de comando](06-Linha-de-Comando.md) | `jvcs.exe`: sintaxe, comandos, exemplos seguros, senha, o que não existe |
| [07 Senhas padrão e segurança](07-Senhas-Padrao-e-Seguranca.md) | Tabela de senhas padrão, o que trocar, boas práticas |
| [08 Solução de problemas](08-Solucao-de-Problemas.md) | Sintoma → causa → solução |
| [09 Instalador do cliente](09-Instalador-do-Cliente.md) | Setup do JEDI VCS 2.5 Beta 2026: instalar, reparar, desinstalar, componentes, o que muda no Delphi, convivência com o cliente original |
| [10 Delphi 11 e 12](10-Delphi-11-e-12.md) | Checklist depois de instalar o Delphi 11/12: GetIt, SynEdit/VTV fixados, compilar com `/delphi:NN`, expert por versão e por atualização |

## Como ler este manual

- Passos numerados são para executar na ordem. Comandos estão em blocos de código.
- `> **Atenção:**` marca risco de perder dados, derrubar usuários ou travar a IDE.
- `> **Só no ambiente de teste:**` marca valores que valem apenas para o servidor de teste desta máquina (senhas padrão, IP, caminhos dentro de `Program Files`). **Não copie para produção.**
- `(a validar)` marca o que veio da ajuda ou do código-fonte, mas ainda não foi exercitado nesta máquina.
- Comandos que mudam coisas (registro, firewall, `gsec`) foram escritos aqui como referência; **nenhum foi executado ao redigir o manual**, exceto as verificações de leitura citadas nos capítulos.

## Mapa de caminhos desta máquina

| O quê | Caminho |
|---|---|
| Servidor JEDI VCS (versão aplicação) | `C:\Program Files (x86)\JEDI\JVCS\Server` (`JVCSSrv.exe`) |
| Banco em uso | `C:\Program Files (x86)\JEDI\JVCS\Server\archive\db_fib\JEDIVCS.FDB` (ODS 11.2) |
| Backup oficial do banco em branco | `C:\Program Files (x86)\JEDI\JVCS\Server\archive\db_fib\jedivcs.fbk` |
| Configuração efetiva do servidor | `C:\Users\edmarfrazao\AppData\Local\VirtualStore\Program Files (x86)\JEDI\JVCS\Server\jvcssrv.ini` |
| Firebird 2.5.9 | `C:\Program Files\Firebird\Firebird_2_5` (`bin\gbak.exe`, `bin\gstat.exe`, `bin\isql.exe`) |
| Biblioteca cliente do Firebird (32 bits) | `C:\Windows\SysWOW64\fbclient.dll` (2.5.9) |
| Cliente oficial 2.5.0.1030 | `C:\Program Files (x86)\JEDI\JVCS` (`jedivcs.exe`, `jvcs.exe`, `jedivcsdiff.exe`, `jedivcs.chm`) |
| Expert para o Delphi 13 | `D:\Delphi\JediVCS\v2026\bin\ideclient\Win32\JvcsExpertBDS37.dll` |
| Registro do cliente | `HKCU\Software\JEDI\JEDIVCS` |
| Delphi 13.2 (IDE de 32 bits) | `C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\bds.exe` |
| Instalador do servidor | `D:\Delphi\JediVCS\Instalador_Servidor_2.50_Beta3_FIB\JVCSv2.50SalFIB.Beta 3.exe` |
| Instalador do cliente | `D:\Delphi\JediVCS\Instalador_2.50_Beta3_10.4Sydney\JVCSv2.50ClientSetupBeta3_Refresh_till_10_4Sydney.exe` |
| Bancos de reserva | `D:\Delphi\JediVCS\ServidorTeste\fb25\JEDIVCS.FDB` (ODS 11.2) e `D:\Delphi\JediVCS\ServidorTeste\JEDIVCS.FDB` (ODS 11.1) |
| Backup do registro/BPL do Delphi | `C:\Users\Public\Documents\Embarcadero\Studio\37.0\_backup_getit_20261012` |
| Ajuda oficial (CHM) | `C:\Program Files (x86)\JEDI\JVCS\jedivcs.chm` e `D:\Delphi\JediVCS\v2026\3rdparty\jedivcs.chm` |

## Documentos relacionados

- [Servidor de teste local](../server/Servidor-Teste-Local.md): registro de como o servidor de teste foi montado.
- [Credenciais](../common/Credenciais.md): análise de armazenamento de senhas e proposta para a CLI e para a IA.
- [Ambiente](../common/Ambiente.md): como o Delphi 13 e as bibliotecas foram instalados e como reverter.
- [Status](../common/Status.md): situação do port.
- [Requisito de tamanho de fonte](../client/Requisito-Tamanho-Fonte.md) e [Check-in de famílias FMX](../client/Checkin-Familias-FMX.md).
- [LEIAME do expert](../../src/jvcsideexpert/LEIAME.md).

## Versões cobertas

| Peça | Versão |
|---|---|
| Servidor | JEDI VCS Firebird Server 2.50 Beta 3 (versão aplicação) |
| Cliente oficial | 2.5.0.1030 (binários de referência; o port ainda não compila, ver [Status](../common/Status.md)) |
| Expert | JEDI VCS 2.5 Beta 2026 (2.5.0.2026) para BDS 37.0 (Delphi 13.2 Florence), IDE de 32 bits |
| Banco | Firebird 2.5.9 (ODS 11.2); alternativa embutida 2.1.3 (ODS 11.1) |
