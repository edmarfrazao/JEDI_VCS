# 11. Pesquisa de módulos, filtro de projetos e menu Edit

Capítulo do cliente standalone (`Jedivcs.exe`) e da janela Project Manager do expert. Vale a partir do
build 2065 (Beta 6). Anterior: [10 Delphi 11 e 12](10-Delphi-11-e-12.md). Volta ao [índice](README.md).

Há três formas de achar alguma coisa:

| O que procurar | Onde | Atalho |
|---|---|---|
| Um módulo do projeto aberto | Campo **Find** da barra Module | `Ctrl+F` |
| Um projeto | Campo de filtro da **árvore de projetos** (à esquerda) | `Ctrl+Shift+P` |
| Um módulo em todos os projetos do servidor | **Edit > Search Modules in All Projects...** | `Ctrl+Shift+F` |

## 1. Campo Find (módulos do projeto aberto)

O campo **Find** fica na barra de ferramentas Module. `Ctrl+F` leva até ele de qualquer lugar da janela,
inclusive com o foco na árvore de projetos. Se a barra Module estiver oculta, ela reaparece.

A pesquisa começa sozinha 300 ms depois da última tecla. Números também pesquisam: `01` acha
`Exemplo01.dpr`. A espera pode ser mudada em **Options > Properties** (de 100 a 5000 ms).

| Você digita | O que acha |
|---|---|
| Texto simples, por exemplo `princ` | Módulos cujo nome **contém** o texto, sem diferenciar maiúsculas |
| `*` ou `?`, por exemplo `u*.pas` | Máscara: `*` é qualquer sequência, `?` é um caractere. Os outros caracteres valem literalmente; `[` não é curinga |
| Texto com `\`, por exemplo `firma\upri` | Procura também na pasta do módulo (pasta + nome) |

Ordem do resultado: primeiro o nome igual, depois o que começa o nome ou uma parte dele (depois de
`.`, `_`, `-`, `\` ou espaço), por fim o que só contém o texto. Exemplo: `notafiscal` vai antes para
`Estrutura.Firma.NotaFiscalSaida.pas` do que para `ImpostoNotaFiscal.pas`.

| Tecla no campo Find | Ação |
|---|---|
| `Enter` ou `F3` | Próximo módulo que casa |
| `Shift+Enter` ou `Shift+F3` | Anterior |
| `Ctrl+Enter` | Seleciona todos os que casam (para fazer check-out de todos, por exemplo) |
| `Esc` | Limpa o campo; com o campo vazio, volta para a lista de módulos |

A barra de status mostra `Find: 2 of 5` (posição e total) ou `Find: 5 selected`. Quando nada casa, o
campo fica destacado e a mensagem aparece uma vez por texto.

## 2. Filtro da árvore de projetos

A árvore de projetos fica à esquerda (**Options > Show Project Tree**). Acima dela há uma lista com o
tipo de filtro e o campo de texto. `Ctrl+Shift+P` (ou **Edit > Filter Projects**) mostra a árvore, se
estiver oculta, e leva ao campo.

O filtro usa a mesma regra do Find, sem diferenciar maiúsculas:

| Você digita | O que fica na árvore |
|---|---|
| `01` ou `ex` | Projetos cujo nome **contém** o texto |
| Várias palavras, por exemplo `teste mod` | Projetos com **todas** as palavras, em qualquer ordem |
| `ex*.dpr`, `*01*`, `plo?1` | Máscara com `*` e `?`, no nome inteiro ou em parte dele |

- O trecho encontrado aparece em **negrito**.
- Com filtro, os grupos que têm projetos encontrados abrem sozinhos. Ao limpar o filtro, os grupos voltam
  como você os tinha deixado.
- Tipos de filtro: **project filter** (padrão, nome do projeto), **group filter** (nome do grupo),
  **group and project filter** e **group or project filter**.

| Tecla no campo do filtro | Ação |
|---|---|
| `Enter` | Abre o projeto mais parecido (nome igual, depois o que começa com o texto); não reabre o que já está aberto |
| `Seta para baixo` | Vai para a árvore, no projeto mais parecido, **sem abrir** |
| `Esc` | Limpa o filtro; com o campo vazio, volta para a árvore |

> **Atenção:** na árvore, mudar a seleção com o mouse ou com as setas abre o projeto selecionado. Esse é
> o comportamento original do JEDI VCS. Para só olhar, use o filtro.

Antes do build 2065 o filtro aceitava só o nome inteiro (`01` não achava `exemplo01.dpr`) e diferenciava
maiúsculas no nome do projeto.

## 3. Menu Edit

Menu novo, entre **Server** e **Project**:

| Item | Atalho | O que faz |
|---|---|---|
| Find Module | `Ctrl+F` | Vai ao campo Find |
| Find Next | `F3` | Próximo módulo que casa com o Find; com o campo vazio, vai ao campo |
| Find Previous | `Shift+F3` | Anterior |
| Select All Matches | (`Ctrl+Enter` no Find) | Seleciona todos os módulos que casam com o Find |
| Filter Projects | `Ctrl+Shift+P` | Vai ao filtro da árvore de projetos (só no standalone) |
| Search Modules in All Projects... | `Ctrl+Shift+F` | Pesquisa no servidor inteiro, a mesma tela de **Server > Search Modules...**. Precisa de servidor conectado e do menu de expert ligado |
| Copy | `Ctrl+C` | Num campo de texto, copia o texto selecionado. Na lista de módulos, copia o nome dos módulos selecionados, um por linha. Na árvore de projetos, copia o nome do projeto ou do grupo |
| Copy Full Path | `Ctrl+Shift+C` | Copia pasta e nome dos módulos selecionados, um por linha |
| Select All | `Ctrl+A` | Num campo de texto, seleciona o texto. Fora dele, seleciona todos os módulos (como **Select > Select All**) |

Regras dos atalhos:

- `Ctrl+C` e `Ctrl+A` respeitam o foco. Num campo de texto, agem no texto, como em qualquer programa do
  Windows.
- Na aba **Line History**, `Ctrl+F`, `F3` e `Shift+F3` continuam sendo a pesquisa dentro do arquivo
  (as ações da aba valem antes do menu).
- O item antigo **Copy to clipboard** (`Ctrl+F2`) do menu de contexto da lista de módulos continua: copia os nomes separados por espaço.
- No Project Manager do expert, dentro do Delphi, o item Filter Projects não aparece. `Ctrl+Shift+P`
  continua sendo o atalho do expert para abrir o Project Manager
  ([04, seção 12](04-Opcoes-do-Cliente.md#12-shortcut-keys)).

## 4. Menu de contexto da lista de módulos

Itens novos no clique com o botão direito sobre os módulos:

| Item | Atalho | O que faz |
|---|---|---|
| Copy Full Path | `Ctrl+Shift+C` | Pasta e nome dos módulos selecionados, um por linha |
| Copy Path | | Pasta dos módulos selecionados, cada pasta uma vez |
| Open in Explorer | | Abre a pasta no Explorer com o arquivo do módulo selecionado (o mesmo que **Open Parent Folder**, `F6`, no fim do menu) |
| Search in All Projects... | | Abre **Search Modules** com o nome do módulo já pesquisado: mostra em quais projetos do servidor ele aparece. Precisa de um módulo selecionado e de servidor conectado; aparece com o menu de expert ligado |

O item antigo **Copy to clipboard** (`Ctrl+F2`) continua no mesmo lugar.

## 5. Conferência rápida

1. Abra um projeto e tecle `Ctrl+F`, `01`: o primeiro módulo com `01` no nome fica selecionado.
2. Tecle `F3` e `Shift+F3`: a seleção anda entre os módulos que casam.
3. Tecle `Ctrl+Shift+P`, `ex`: a árvore mostra só os projetos com `ex`, com o trecho em negrito.
4. Tecle `Enter`: abre o projeto mais parecido.
5. Selecione dois módulos e tecle `Ctrl+Shift+C`; cole num editor: pasta e nome, um por linha.
6. Clique com o botão direito num módulo e escolha **Search in All Projects...**: a pesquisa já abre com o nome dele.

Os casos da pesquisa e do filtro têm teste automático, sem servidor:

```
tests\executar.bat cliente
```
