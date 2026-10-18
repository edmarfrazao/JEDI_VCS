# 04. Testes e validação

Como o port foi validado: compatibilidade de protocolo, ABI da IDE, interface e instalação. Anterior:
[03 Decisões](03-Decisoes-de-Arquitetura.md). Próximo: [05 Release](05-Processo-de-Release.md).

## Visão geral

| Camada | Técnica | Ferramenta | Onde está o detalhe |
|---|---|---|---|
| Protocolo (fio) | golden: novo × original no mesmo servidor | `tools\golden\console` (proxy + normalizador) | [Port-Console §3](../client/Port-Console.md) |
| Algoritmos | vetores de teste e leitura cruzada | CRC-32, Blowfish, Base64 | [Algoritmos-Recuperados](../client/Algoritmos-Recuperados.md) |
| ABI expert↔DLL | harness fora da IDE com a DLL nova e a original | `src\jvcsideexpert\tests` | [Port-DLL-IDE §4](../client/Port-DLL-IDE.md) |
| Forms (EXE) | varredura automática de todos os forms | `Jedivcs.exe -formsweep` (Debug) | [Port-Standalone §5](../client/Port-Standalone.md) |
| Funcional (EXE) | automação por arquivo de comandos | `JVCS_DEBUG_AUTOMATION=1` (Debug) | [Port-Standalone §5.5](../client/Port-Standalone.md) |
| Diff | linha de comando com exit code | `JEDIVCSDiff /s: /t: /autostart /log: /close` | [Port-Diff §3](../client/Port-Diff.md) |
| Expert por atualização | leitura dos imports do PE contra os `.bpl` | `tools\verificar-expert.ps1` | [Port-DLL-IDE §5A](../client/Port-DLL-IDE.md) |
| IDEs reais | teste manual no Delphi 11, 12 e 13 | instalador + canal entre PCs | abaixo |
| Instalador | instalar/reinstalar/desinstalar silencioso com chaves desviadas | `/BDSKEY=`, `/AICONFIG=` | [setup/LEIAME §6](../../../setup/LEIAME.md) |

## 1. Servidor de teste

Um servidor **JEDI VCS 2.50 Beta 3 (Firebird)** com Firebird 2.5.9, banco atualizado para o esquema 2.5
(branch `HEAD`) e um projeto de exemplo (`Exemplo01`: `.dpr`, `.dproj`, `.res`, `uPrincipal.pas/.dfm`).
Montagem:
[manual 01](../manual/01-Servidor-Instalacao-e-Configuracao.md). Usuário inicial `sysdba` / `admin`
(padrão do banco novo; troque após o 1º login).

## 2. Golden do console (protocolo)

Os consoles **novo e original** rodam os mesmos comandos e três coisas são comparadas:

1. a **saída** (stdout) byte a byte;
2. o **tráfego TCP**, capturado por `tools\golden\console\proxy.ps1` (porta local → 2106) e normalizado por
   `norm.pl` (mascara só senha cifrada, hora, TransactionIDs e pasta de destino);
3. os **arquivos** extraídos (`cmp`).

Resultado (12/10): `listprojects`, `listproject`, `listlocks`, `getmodule` (inclusive `rev=`),
`checkout`/`checkin` com comentário acentuado — **iguais**. Leitura cruzada: o original lê as revisões
gravadas pelo novo e vice-versa. As evidências normalizadas
ficaram locais, fora do repositório (as capturas brutas, com a senha cifrada, também não
foram versionadas).

## 3. Harness da DLL (ABI)

```
src\jvcsideexpert\tests\testar-dll.bat [nova|original|ambas] [verbos]
src\jvcsideexpert\tests\testar-expert.bat
src\jvcsideexpert\tests\testar-dll-interativo.bat
```

| Teste | O que faz |
|---|---|
| `JvcsDllHarness` | host console com o **`TJVCSDllBridge` e as 24 callbacks reais do expert**: INIT, HISTORYINIT, OPERATIONINIT, menu, verbos, notificações, abre Connect/Properties/Recent/About, FINALIZE; um *vectored exception handler* conta toda access violation |
| `JvcsExpertSmokeTest` / `testar-expert.bat` | carrega o expert num host com a ToolsAPI **real** do `designide` (menus, ações, notificações, ABI) |
| `JvcsDllInterativo` | "Fake IDE" (`TAppBuilder`, VCL Style no host) para ver tema, menus e janelas como na IDE |
| `FakeJvcsExternalDll` | DLL falsa para testar o expert sem o cliente |
| `JvcsAbiCrossCheck` | confere a cópia `JVCSExpertABI.pas` contra `JVCSIDEInterfaceCommon.pas` |

Resultado: nova e original com **0 access violations e 0 falhas** (21 verificações por DLL).

## 4. Varredura de forms e automação (EXE, build Debug)

- `Jedivcs.exe -formsweep=<pasta> [-sweepscale=175] [-sweepfilter=X] [-sweepnoshow]` cria, mostra, fecha
  e destrói os **95 forms/frames** por RTTI, sem login, e registra: `EReadError`/AV com unit e linha,
  **assinatura de cada handler do DFM** comparada com o tipo do evento, cortes de layout na escala pedida
  e componentes JVCL restantes.
- Resultado (13/10): 0 `EReadError` e 0 handler com assinatura errada a 100/175/200%; cortes de layout a
  200% reduzidos de 67 para 22.
- `JVCS_DEBUG_AUTOMATION=1`: o EXE lê comandos de `%TEMP%\jvcs-debug-cmd.txt` (`click`, `set`, `check`,
  `index`, `get`, `dump`, `forms`, `stack`, `shot`, `colclick`, `popup`, `gauge`, `stateidx`,
  `checkitem`) e responde em `%TEMP%\jvcs-debug-out.txt`, inclusive com diálogos modais abertos. Foi
  assim que Save WIP, Compare all, Backup com/sem senha, Line History, Compressed Diff, Used Units,
  Synchronize, Labels e rollback foram testados contra o servidor.
- Nada disso existe no build Release.

## 5. Testes nas IDEs (Delphi 11, 12 e 13)

| IDE | Onde | O que foi conferido |
|---|---|---|
| Delphi 13.2 (BDS 37) | PC de desenvolvimento | expert carregado, menu **JEDI VCS**, atalhos Ctrl+Shift+P/I/O/G/B, check-in pela IDE do `Exemplo01`, tema seguindo a IDE |
| Delphi 11.3 (BDS 22) | PC de desenvolvimento | `compilar-expert.bat /delphi:11`, `verificar-expert.ps1`, `libs` e `.dproj` |
| Delphi 11, 12 e 13.1 | PC de testes, pelo canal | instalador da release, carga do expert por atualização (foi assim que o problema do `designide` no 13.1 apareceu), tema real da IDE |

Roteiro do teste na IDE: [Port-DLL-IDE §5](../client/Port-DLL-IDE.md) e
[manual 03](../manual/03-Integracao-com-o-Delphi.md).

## 6. Canal entre PCs

Para testar em IDEs que não estão na máquina de desenvolvimento, o Claude Code do PC de desenvolvimento
manda **pedidos assinados** ao Claude Code do PC de testes por uma pasta sincronizada:

- um script de canal local, não versionado (`enviar`, `pendentes`, `ler`, `responder`, `aguardar`, `status`);
- cada pedido e resposta é assinado com **HMAC-SHA256**; a chave fica fora da pasta compartilhada e pedido
  com assinatura inválida nunca é executado;
- o Claude remoto roda em `/loop`, executa só o que o pedido descreve e pergunta ao usuário local antes de
  qualquer ação fora do combinado.

## 7. verificar-expert

```
powershell -NoProfile -ExecutionPolicy Bypass -File tools\verificar-expert.ps1 ^
  -Expert bin\ideclient\Win32\JvcsExpertBDS37.dll -BplDir <pasta com rtl/vcl/xmlrtl .bpl da atualização> ^
  -Inits -Permitidos rtl,vcl,xmlrtl
```

Lê os imports (normais e delay-load) do expert e os exports dos `.bpl` com um leitor de PE próprio — a
mesma resolução do `LoadLibrary`. Código 0 = carrega. Roda a cada `compilar-expert.bat` e antes do ISCC no
`gerar-instalador.bat`.

## 8. O que ainda não tem teste automatizado

- Suíte golden automatizada (hoje é roteiro manual com proxy) em ACP 1252 e 65001, pt-BR e en-US.
- Teste completo do History e do menu do Project Manager dentro da IDE com a DLL nova.
- Restauração de backups antigos (Abbrevia 3.05/ZipMaster) com senha.
