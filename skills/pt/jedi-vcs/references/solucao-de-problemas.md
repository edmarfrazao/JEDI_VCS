# Solução de problemas (resumo para a IA)

Nunca contorne o problema mexendo em atributos, no registro, no `config.ini` ou no settings: explique
ao usuário e sugira o passo dele.

| Sintoma | Causa provável | O que fazer |
|---|---|---|
| `localizar-wrapper.ps1` → 12 | `tools\ai` não instalado | usuário instala o JEDI VCS 2.5 Beta 2026 com "Ferramentas da IA" ou define `JVCS_AI_TOOLS` |
| `[ERRO 2] informe -Project <projeto> (não há um único .dpr/.dpk na pasta atual)` | pasta com mais de um `.dpr`/`.dpk` (ex.: `X - Copia.dpr`) | repetir com `-Project X.dpr` |
| `[ERRO 2] informe -Project <projeto> (nenhum .jvcsproject nem mapa [projects] ...)` | pasta sem `.dpr`, sem marcador e sem mapa | `-Project <nome>`, ou `.jvcsproject` com `project=<nome>` (só se o usuário pedir), ou peça ao usuário `config set projectMap` |
| `[ERRO 2] parte dos arquivos está em ... e parte fora do mapa` | arquivos de identidades diferentes numa chamada | uma chamada por pasta |
| `[ERRO 4] a pasta declara identity=X em ... .jvcsproject` | o marcador pede outra identidade | o usuário registra com `config set identityMap "<pasta>" X`; a IA não usa `-Identity` por conta própria |
| `[ERRO 7] marcador ...\.jvcsproject inválido: ...` | linha ou nome inválido no marcador (inclusive `project: caractere especial de shell`) | avisar o usuário; corrigir o arquivo (`project=<nome>`) |
| `[ERRO 10] -Identity X, diferente da identidade registrada ...` | a IA tentou sair da identidade da pasta | só com a aprovação do usuário (`-Confirmed`) |
| `projeto '...' não existe no servidor` (5) | projeto não criado no JEDI VCS ou nome diferente | `projects` para listar; usuário cria pelo cliente |
| `notVersioned` | arquivo não é módulo | editar sem checkout; versionar só se o usuário pedir (`add`, console 2026) |
| `local=unknown -> pathTruncated` | caminho do servidor truncado (47 car.) e arquivo não achado sob a pasta do projeto | rodar `status "<arquivo>"` na pasta do projeto |
| `pathMismatch` (5) | o arquivo local não é o registrado no servidor: projeto em outra pasta (ex.: Documentos redirecionados para o OneDrive, outra letra de unidade, cópia) | não insistir; usuário abre o projeto no caminho registrado ou usa `subst`/junction |
| `Project1`/`Unit1` recusados | nomes padrão do Delphi são proibidos no JEDI VCS | usuário salva projeto e units com nomes próprios |
| 4 credencial | identidade ausente, sem senha salva ou login recusado | usuário conecta pela GUI com *Store Password with identity* |
| 6 `lockedByOther` | outro usuário tem o lock | não editar; avisar quem tem o lock (`lockedBy`) |
| 8 `localModified` | arquivo alterado fora do VCS | perguntar; com aprovação `checkout -Force -Confirmed` (mantém a alteração, faz backup) |
| 7 `notCheckedOut` | check-in sem checkout | fazer checkout antes (ou o usuário fez na IDE em outra máquina) |
| 7 `encodingChanged` | codificação/BOM/quebras mudaram (ex.: `Edit` em arquivo ANSI) | restaurar a codificação com `edit-preserve`; `-AllowEncodingChange -Confirmed` só se o usuário pedir |
| 7 `failedCompensated` | console falhou no checkout (ex.: arquivo aberto e bloqueado pela IDE) e o lock foi desfeito | pedir para fechar o arquivo na IDE e repetir |
| 9 `timeout` / conexão | servidor lento ou fora | `identity -Test`; repetir uma vez; conferir `status`/`locks` |
| 10 | modo `confirm` sem `-Confirmed`, ou modo `manual` | mostrar a ação e pedir aprovação; no manual, deixar com o usuário |
| 12 mutex | outra chamada da mesma identidade em andamento | esperar e repetir |
| 12 `jvcs.exe` | console ausente ou não reconhecido | usuário confere `config get jvcsExe` |
| hook negou o `Edit` | arquivo ANSI/UTF-16, ou ASCII recebendo acento, ou sem checkout | usar o comando que o hook indicou (edit-preserve ou checkout) |
| `Edit`: "arquivo modificado desde a leitura" | o checkout mudou atributo/data | reler e repetir |
| cada chamada pede aprovação | pasta não confiável, ou forma da chamada diferente da regra `allow` | usar a forma exata do `wrapperCommand`; usuário aceita a confiança da pasta |
| módulo ficou em checkout sem alteração | edição negada ou desistência | `undocheckout "<arq>"` |
