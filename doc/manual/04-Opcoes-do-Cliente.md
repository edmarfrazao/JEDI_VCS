# 04. Opções do cliente (VCS Properties)

Página por página, com o que cada opção faz e o que recomendamos. Fontes: ajuda oficial (`jedivcs.chm`), formulário `TVCSOPTIONS` do 2.5.0.1030 e `src\jedivcs\Options.dfm`.

## Como abrir

| Cliente | Caminho |
|---|---|
| Delphi | **JEDI VCS > VCS Properties...** |
| Standalone | **Options > Properties** |

A janela tem uma lista de páginas à esquerda e os botões **OK**, **Apply** e **Cancel**. Imagem da página inicial: [options-user-interface-2.5.0.1030.png](../client/img/options-user-interface-2.5.0.1030.png).

- As opções ficam em `HKCU\Software\JEDI\JEDIVCS\Options` e são **compartilhadas** entre o standalone e a IDE. Cada um guarda só as próprias posições de janela.
- Algumas opções podem ser **impostas pelo administrador** (Global settings, ferramenta `JediVcsGlobalAdmin.exe` do servidor, e "Force Global Settings" no menu Clients). O cliente carrega essas opções a cada login e mostra que a opção "não pode ser alterada".
- O `jvcs.exe` (console) não usa estas opções.

> **Atenção:** a opção "Use file storage (JVCS.INI)" (página Folders) troca o registro por um arquivo `jvcs.ini` na pasta do programa. Você perde as configurações atuais e o arquivo (com senha em Base64, se gravada) fica em `Program Files`. **Não use.**

As 19 páginas do código-fonte (v2026) são: User Interface, Common Options, Comments, Folders, Time Stamps, Keyword Expansion, Project Backup, Internal Editors, Filter Values, Compare Tools, Notify, Shortcut Keys, DSA Dialogs, Internal Printer, MRU Lists, Data Encryption, Special/Debug, **External Bugtracker** e **Save WIP**. As duas últimas existem no código-fonte atual; o binário oficial 2.5.0.1030 mostra só as 17 primeiras (a validar quando o cliente portado compilar). O cliente portado (v2026) acrescenta **Appearance** e **AI / Automation** (seções 20 e 21).

## 1. User Interface

| Opção | O que faz | Recomendação |
|---|---|---|
| On module double click do | Ação do duplo clique num módulo no Project Manager: nothing, View module, Check In module, Check Out module, Get module, Compare module, Show history, Maintain labels, Open parent folder | `Show history` ou `nothing`. Evite Check In/Out para não agir por engano |
| Find module timer interval | Atraso (ms) entre a tecla e a busca no Project Manager (padrão da tela: 750) | Manter |
| Show local info (Original name/ Size/ Attr...) | Mostra nome, tamanho, data e atributos locais | **Desligue** em projetos grandes ou em pasta de rede: acelera muito a abertura |
| Show detailed file type information | Mostra o tipo do Windows ("Delphi Unit") em vez da extensão | Desligue pelo mesmo motivo |
| Show tooltips / Beep on error | Dicas e bipe de erro | Preferência pessoal |
| Show Listview colors/ fonts | Cores na lista: **New (not filed)**, **Modules in work by you** (padrão Maroon), **Modules in work by others** (padrão Gray) | Manter; ajuda a ver quem está com o módulo |

O tamanho da fonte e o tema ainda **não** são configuráveis (planejado em [Requisito-Tamanho-Fonte.md](../client/Requisito-Tamanho-Fonte.md)).

## 2. Common Options

| Opção | O que faz | Recomendação |
|---|---|---|
| Add automatic to project list: IDE's desktop file (`*.dsk`), configuration file (`*.cfg`), package/component list (`CompList.jvcs`) | Inclui esses arquivos na lista do projeto (só IDE; padrão desligado) | **Desligue.** Nunca versione `.dsk` (ver [capítulo 05](05-Familias-de-Arquivos.md)) |
| Auto synchronize when opening a new project | Abre o diálogo Synchronize ao abrir o projeto e fecha se tudo estiver em dia (padrão desligado) | Ligue em projetos compartilhados na rede |
| Auto refresh archive view (min) | Recarrega a lista do servidor a cada N minutos | Ligue em equipe com intervalo moderado; cada refresh é um pedido ao servidor |
| Auto connect server when starting the IDE | Conecta ao abrir a IDE ou um projeto (só IDE; padrão desligado) | Ligue se usa sempre; o expert adia a conexão até a IDE aparecer |
| Undo Check Out unchanged files when checking in | No check-in, o que não mudou só é destravado, sem criar revisão (compara CRC; um pouco mais lento) | Ligue, **a menos que** use keyword expansion (os dois conflitam: a expansão faz o arquivo diferir sempre) |
| Don't perform RO flag checks on Check In/Out/Sync... | Desliga a conferência do atributo somente leitura | Desligado (deixe a conferência ativa) |
| Check module state automatic on menu pull down | Consulta o servidor ao abrir o menu para habilitar os itens certos | **Desligue.** Deixa o menu lento e, no expert, o servidor é consultado dentro do ciclo de mensagens da IDE |

## 3. Comments

| Opção | O que faz | Recomendação |
|---|---|---|
| Confirm empty Check In comment / Confirm empty Check Out comment | Pergunta se o comentário foi deixado em branco (padrão ligado) | Ligue |
| Check In comment required | Não deixa fazer check-in sem comentário | **Ligue** (rastreabilidade) |
| Default Check In description = last Check Out descr. | Reaproveita o comentário do check-out | Ligue |
| Include client IP numbers in Check In/Out comments | Acrescenta o IP do cliente ao comentário | Opcional: mostra de qual máquina veio o check-in. Desligue se não precisar |
| Include version history/ timestamps in source files | Escreve o histórico no topo do `.pas`/`.dpr` como comentário (padrão ligado). Sub-opções: Include Check In information, Include Check Out information, Break lines after 80 chars | **Desligue** em projetos novos: altera o fonte a cada check-in, gera diferenças só de comentário e a tela avisa de problemas com Data Modules. Como a DLL é ANSI, acentos no comentário podem se perder |

## 4. Folders

| Opção | O que faz | Recomendação |
|---|---|---|
| JEDI VCS temporary directory | Pasta de arquivos temporários (log do servidor, versão do arquivo...) | Pasta local rápida e gravável |
| JEDI VCS base registry key (HKCU) | Chave de registro base. Não editável desde a 2.4.0 (`Software\JEDI\JEDIVCS`) | Manter |
| Local application server path | Caminho do `JVCSSrv.exe`. Para instalação local o cliente pode iniciar o servidor ao conectar | `C:\Program Files (x86)\JEDI\JVCS\Server\JVCSSrv.exe` no servidor de teste; em máquina de cliente, em branco |
| Show "Parent folders" as | Single pane view ou Explorer view | Preferência |
| Use file storage (JVCS.INI) instead of Registry | Veja o aviso acima | **Não use** |

## 5. Time Stamps

| Opção | O que faz | Recomendação |
|---|---|---|
| Set file's date/time stamp... when Check In a file to / when Check Out a file to | **Original date/time** ou **Current date/time** | A própria tela avisa: "usually it is not recommended to change the date/time stamps of source files". O Delphi e o `syncproject` (modo `stamp`) usam a data do arquivo para decidir o que mudou. Mantenha o padrão da instalação |

## 6. Keyword Expansion

Substitui palavras-chave nos fontes (`$Revision: $`, `$CheckInDate: $`, `$History: $`...) a cada Add/Check In/Check Out. Opções: expansão no check-in, no check-out e ao adicionar módulos novos; lista de extensões ("Search in files"); botão de inserir um **code template** com o cabeçalho na IDE (Ctrl+J); Backup of the file (`.~kw`); Check for binary files before expanding; Skip files without `$Keywords` in the first two lines.

| Recomendação | Motivo |
|---|---|
| **Deixe desligada** se não precisa | Deixa Add/Check In/Out mais lentos, conflita com "Undo Check Out unchanged files" e mexe no fonte |
| Se usar: marque "Check for binary files" e "Skip files without `$Keywords`..." e ponha `$NoKeywords` depois da última palavra-chave de cada arquivo | Evita corromper binários e acelera a leitura |
| Nunca inclua extensões de arquivos binários na lista | A expansão corrompe binários |
| Lembre que só vale para arquivo avulso e para o **pai** da família, não para os filhos | |

`$History: $` precisa estar sozinho numa linha, entre comentários, e causa um pedido extra ao servidor.

## 7. Project Backup

Backup local (zip) dos arquivos do projeto, **diferente** do backup do banco do servidor.

| Opção | O que faz | Recomendação |
|---|---|---|
| Show backup dialog automatic | Mostra o backup ao fechar o projeto ou a IDE (marcado como "Recommended"; padrão da ajuda: desligado) | Ligue |
| Select changed files automatic | Seleciona os arquivos com bit de arquivo alterado (marcado como "Recommended") | Ligue |
| Show progress sheet | Mostra o andamento | Preferência |
| Backup target folder | Pasta dos zips. **Precisa existir** e **não aceita UNC**: use letra de unidade mapeada | Pasta em **outro disco** |
| Backup file compression level | Slow/tightest, Fast/medium, Very fast/low | Fast/medium |
| Create sequential backups (`..000.zip` a `..999.zip`) | Um zip novo a cada backup, em vez de sobrescrever (usa mais espaço) | Ligue |
| Automatically erase backups more than N days old (keep the latest) | Limpa os antigos | Ligue (por exemplo 30 dias) |
| Show/ Clean | Lista e apaga backups | |

O backup precisa do arquivo `<projeto>.bkp`, criado em tempo de execução: não faça check-in, não altere nem apague.

## 8. Internal Editors

Define com que programa abrir os módulos no "View".

| Opção | O que faz | Recomendação |
|---|---|---|
| Use always Shell's namespace extension | Usa o programa associado do Windows | Ligue, é o mais simples |
| Use short (8+3) file names | Converte o nome para o formato 8+3 antes de chamar o editor | Desligue se o seu editor aceita nomes longos (nomes 8+3 podem não existir em volumes sem eles) (a validar) |
| Resource editor, Image editor, Text editor, User defined editor | Programas por tipo; o "User defined editor" tem prioridade sobre os outros. As extensões de cada um são definidas em Filter Values | Text editor: seu editor de texto |

## 9. Filter Values

Lista de filtros de extensão (separe por `;`, por exemplo `*.ext1;*.ext2`). Filtros internos (só editar as extensões) e filtros customizados.

| Filtro | Para que serve | Recomendação |
|---|---|---|
| **Compare files** | Extensões que o Visual Compare abre | **Só arquivos de texto** |
| **Always writeable** | Extensões que **não** ficam somente leitura após o check-in (arquivos que a IDE regrava sempre) | Não remova os padrões. A ajuda explica que `.dpr`, `.res` e `.dof` precisam ficar graváveis. No Delphi moderno o `.dproj` também é regravado: se a IDE reclamar de arquivo somente leitura ao salvar o projeto, confira se `.dproj` está na lista e adicione (a validar) |

## 10. Compare Tools

| Opção | O que faz |
|---|---|
| Lista (Name, Path, Param, Custom) | O comparador padrão é o `JEDIVCSDiff.exe`. **Add Custom** cadastra outro programa: nome único, caminho e parâmetros |
| Parâmetros | Precisam conter `%1` (arquivo a comparar) e `%2` (arquivo base), separados por espaço, por exemplo `%1 %2`. Os nomes são passados no formato 8+3 |
| Don't perform Binary check before Compare | Pula a conferência de binário. Deixe **desligado** |

Se você usa o Beyond Compare (há um pacote dele instalado no Delphi), cadastre-o aqui apontando para o `BComp.exe` e `%1 %2`.

## 11. Notify

Avisos entre desenvolvedores. As mensagens vão por **mailslot** (sem configuração) para o Project Manager dos colegas **no mesmo domínio ou grupo de trabalho**; não funcionam pela WAN (para isso, SMTP forwarder).

| Opção | O que faz |
|---|---|
| Send messages via mailslot (chave geral) / via SMTP forwarder | Liga o envio |
| if... connecting a project, disconnecting a project, Check In a module, Check Out a module | Quais eventos geram mensagem |
| Beep if a message was received, Notify text color | Aparência |
| Filter out messages not related to current project; Filter out Connecting/Disconnecting a project; Check Out; Check In | Filtros do que você recebe |
| Mailslot | Nome fixo `FVCSMail` (não editável) |

Se IDE e standalone rodam juntos no mesmo computador, a mensagem **"Notify Init - Exception: Mailslot already exists"** é normal: só o primeiro programa recebe os avisos. Recomendação: ligue para a equipe local, desligue para uso individual.

## 12. Shortcut Keys

| Opção | O que faz |
|---|---|
| IDE menu accelerator | Letra de acesso do menu JEDI VCS. Vale na **próxima** abertura da IDE |
| Project Manager, Get, Check In, Check Out, Backup/ Restore, Synchronize | Atalhos. Valem na hora. Padrão do expert: Ctrl+Shift+P/I/O/G/B |
| Disable all graphic button's Ctrl+ shortcuts | Desliga os Ctrl+ dos botões gráficos |

Se o Project Manager estiver na frente, Check In/Out atua nos módulos selecionados nele; senão, no módulo atual da IDE. Atenção a conflitos com atalhos do Delphi.

## 13. DSA Dialogs

Lista dos diálogos "Não mostrar de novo" (campo e entrada de registro). Marque ou desmarque cada um; **Enable All** volta a mostrar todos, **Disable All** esconde todos. A ajuda **não recomenda** esconder os avisos de alerta.

## 14. Internal Printer

Só vale para as rotinas internas de impressão (não para relatórios em QuickReport): **Print header**, **Top margin** (linhas), **Left margin** (caracteres) e **Printer font** (de preferência largura fixa).

## 15. MRU Lists

Listas de itens recentes. Escolha a lista no combo, ajuste o **Max count**, apague um item (**Remove**) ou todos (**Clear List**).

Listas: Save file dialog folder, Open file dialog folder, Check Out target folder, Project folder (Toolbar), Server name/address, Restore target path, Archive module search mask, New synchronize folder, To Do category, Wildcard view filter, Compare date module list, Recent projects, Select folder dialog, Compare folder (Base), Compare folder (Target), Touch folder, Source distribution file, Direct SQL queries, Label filter mask, **Check In comments**, **Check Out comments**.

Use **Clear List** em Server name/address e nos comentários se for devolver ou emprestar a máquina.

## 16. Data Encryption

Criptografa o **conteúdo** dos módulos (Blowfish de 16 rodadas, chave de 128 a 448 bits) antes de enviar ao servidor. Comentários, labels e nomes **não** são criptografados. Campos: **Key** (16 a 56 caracteres), **Confirm**, e **Store/transmit source files encrypted**.

> **Atenção:**
> - Se você **perder a chave**, os arquivos criptografados ficam **irrecuperáveis**. Não confie no armazenamento interno: a chave é gravada só em Base64 no registro (`EncodeKey`). Guarde-a também no gerenciador de senhas.
> - **Nunca troque a chave**: o servidor não registra com qual chave cada módulo foi gravado.
> - Todos os desenvolvedores do mesmo projeto precisam da **mesma** chave (e não por e-mail).
> - Deixa o check-in/out mais lento. Use só se necessário (WAN, código sensível). Na LAN com o servidor interno, **deixe desligado**.

## 17. Special/Debug

| Opção | O que faz | Recomendação |
|---|---|---|
| Wait until request timeout error (s) | Tempo máximo esperando o servidor (padrão 120) | 120; aumente em WAN ou banco muito grande |
| GExperts Workaround | Evita conflito com o GExperts (padrão ligado) | Se **não** usa GExperts, desligue para ganhar 1 a 2 s ao fechar a IDE ou trocar de projeto; com GExperts, deixe ligado |
| OutputDebugString active | Mensagens de depuração | Só para diagnóstico |
| Clean Up min. delay value, DataModule sync delay, Remote Debug settings | Ajustes de depuração ("not for public use") | Não mexa |

## 18. External Bugtracker (novo)

Liga o comentário do check-in a um sistema de chamados. O cliente procura, no comentário, o trecho que casa com a **expressão regular** e abre a **URL** com o número do chamado.

| Campo | Regra |
|---|---|
| Bugtracker URL | Use `{bug}` onde entra o número |
| Regular Expression | Marque o número com o grupo nomeado `?<bug>` |

Exemplo do próprio código-fonte (MantisBT): URL `http://seu.servidor/mantis/view.php?id={bug}` e expressão `(?i)MANTIS +#*(?<bug>[\d]+)`. Para outro sistema, o raciocínio é o mesmo (exemplo ilustrativo: URL `https://chamados.empresa/ticket/{bug}`, expressão `#(?<bug>\d+)`). Limitação conhecida no fonte: a expressão regular precisa do `pcre3.dll` (ou da versão com link estático).

## 19. Save WIP (novo)

Guarda o **trabalho em andamento** (WIP): roda um arquivador de arquivos sobre todos os módulos que **você** tem em check-out (respeitando as famílias). Campos: **Backup command** e a caixa **Execute on close**.

| Variável no comando | Valor |
|---|---|
| `%TEMP%`, `%USERPROFILE%` etc. | Variáveis de ambiente do Windows |
| `#y#`, `#m#`, `#d#`, `#h#`, `#n#`, `#s#` | Ano (4 dígitos), **mês**, dia, hora, **minuto**, segundo (2 dígitos) |
| `#vcsusername#` | Usuário do JEDI VCS |
| `#vcslistfile#` | Arquivo de texto com um módulo por linha (gravado em `%APPDATA%\JEDI\JVCS\SaveWIP.lst`) |

Exemplo com o 7-Zip desta máquina:

```
"C:\Program Files\7-Zip\7z.exe" a "%USERPROFILE%\JVCS-WIP-#y##m##d#-#h##n##s#.7z" @"#vcslistfile#"
```

O exemplo do código-fonte usa `#m#` também para os minutos, mas `#m#` é o **mês**; use `#n#` para minutos. O comando roda minimizado. Versões antigas do 7-Zip não preservavam as pastas com lista de arquivos; confira o resultado do seu (a validar). Com "Execute on close" o comando roda ao fechar.

## 20. Appearance (novo, v2026)

Tamanho e família das fontes e tema claro/escuro. Vale para o standalone e para as janelas abertas pelo menu **JEDI VCS** no Delphi (a preferência é a mesma, em `HKCU\Software\JEDI\JEDIVCS\Options`). Aplica ao clicar **OK** ou **Apply**, em todas as janelas abertas, sem reiniciar.

| Opção | O que faz | Recomendação |
|---|---|---|
| Interface font scale | Escala da fonte da interface: 100%, 125%, 150%, 175%, 200% (ou digite de 80 a 250). Diálogos e listas crescem junto | Monitor grande em 100% do Windows (ex.: 32" QHD): 125% ou 150% |
| Interface font: **Font...** / **Default** | Família e tamanho em pontos. Com tamanho escolhido, ele vale no lugar da escala (a escala fica desabilitada). **Default** volta à fonte do sistema | Use a escala; escolha a fonte só se quiser outra família |
| Menu font | Fonte dos menus; padrão = a da interface | Manter "Same as interface" |
| Editor font (Diff, Line History) | Fonte dos editores de texto; padrão Consolas 10 | Uma fonte monoespaçada (Consolas, Cascadia Mono) |
| Theme | **Follow Windows** (standalone) ou **Follow Delphi** (na IDE), **Light**, **Dark** | Seguir o Delphi/Windows |
| Restore defaults | Volta tudo ao padrão (100%, fontes do sistema, seguir o host) | |

- No Delphi, "Follow Delphi" lê o tema da IDE (Light, Dark, Mountain Mist) e é conferido a cada janela do JEDI VCS que abre. Os menus suspensos e as caixas de mensagem do JEDI VCS seguem o tema da IDE.
- Limitações: ícones da barra de ferramentas antigos no tema escuro; cores do realce de sintaxe do Diff/Line History não mudam; a barra de menu principal do standalone sem tema não cresce (só os submenus).

## 21. AI / Automation (novo, v2026)

Como o **Claude Code** pode fazer checkout e check-in pelo wrapper `tools\ai\jvcs-ai.ps1` (ver `tools\ai\LEIAME.md`). Cada operação tem três modos:

| Modo | O que acontece |
|---|---|
| **Manual** | A IA não faz a operação; você faz (IDE, JEDI VCS ou o wrapper no seu terminal) |
| **Ask for confirmation** (padrão) | O Claude Code pede sua aprovação antes de cada operação |
| **Automatic** | A IA faz sozinha; os comentários dos check-ins dela têm o prefixo `[IA]` |

- **Check out by AI** e **Check in by AI** são independentes.
- A escolha fica em `%APPDATA%\JEDI\JVCS\config.ini`, seção `[ai]`, chaves `checkout=` e `checkin=` (`manual`, `confirm` ou `auto`), o mesmo arquivo do `jvcs-ai.ps1 config set` (o resto do arquivo é preservado). Vale para todos os projetos do usuário do Windows.
- Conferir: `powershell -File tools\ai\jvcs-ai.ps1 config list -Text`.
- Desfazer checkout com descarte, checkout forçado e check-in que muda a codificação sempre pedem confirmação, em qualquer modo.

## Configuração recomendada, em resumo

| Página | Ajuste |
|---|---|
| User Interface | Desligar "Show local info" e "detailed file type" em projetos grandes |
| Common Options | Auto connect ligado se quiser; "Undo Check Out unchanged" ligado; "Check module state" desligado; `.dsk`/`.cfg` desligados |
| Comments | Comentário obrigatório; "Include version history in source" desligado |
| Folders | Registro (não usar `jvcs.ini`) |
| Time Stamps | Padrão |
| Keyword Expansion | Desligada, salvo necessidade |
| Project Backup | Ligado, em outro disco, sequencial com limpeza |
| Filter Values | `.dpr`, `.res`, `.dproj` graváveis |
| Data Encryption | Desligada na LAN |
| Save WIP | Ligar com o 7-Zip se quiser cópia local do que está em check-out |
| Appearance | Escala 125–150% em monitor grande a 100%; tema seguindo o Delphi/Windows |
| AI / Automation | Confirmação (padrão) para checkout e check-in |
