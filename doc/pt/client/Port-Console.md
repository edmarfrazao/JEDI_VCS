# Port do console `jvcs.exe` para Delphi 13.2

Estado em **12/10/2026**. O console (`src\jvcs\jvcs.dpr`) compila no Delphi 13.2 (Win32 Debug e
Release) e foi validado contra o servidor de teste JEDI VCS 2.50 (127.0.0.1:2106, Firebird 2.5).
Nos comandos testados, a saída e o tráfego de rede ficaram **idênticos** aos do console original
2.5.0.1030 (`C:\Program Files (x86)\JEDI\JVCS\jvcs.exe`). As únicas diferenças são a linha de banner
(versão do arquivo) e os campos que variam legitimamente entre execuções (hora, TransactionID,
senha cifrada).

Referências: [Plano-de-Port.md](../common/Plano-de-Port.md) (F1, F2),
[Algoritmos-Recuperados.md](Algoritmos-Recuperados.md) (CRC, protocolo, LOGIN),
[Decisoes.md](../common/Decisoes.md), [tools\LEIAME-compilar.md](../../../tools/LEIAME-compilar.md).

## 1. Como compilar

```
tools\compilar.bat console Debug Win32
tools\compilar.bat console Release Win32
```

- Saída: `bin\client\Win32\jvcs.exe` (+ `.map`/`.drc`). Log: `tools\logs\compilar_console_Win32_<cfg>.log`.
- Depois de um build Win32 OK, o script copia `3rdparty\fvcscrypt.dll` para `bin\client\Win32`. A DLL
  é obrigatória: o console a verifica na partida e ela cifra a senha no LOGIN.
- Defines do console: `DEBUG`/`RELEASE`, `DelphiPersonalEdition`, `JVCSCONSOLECLIENT`, `BRANCHING` e
  `OVERBYTEV6_UP` (comum).
- O build usa os DCUs do GetIt: ICS 9.7, JCL 2026.08 (`JclFileUtils`, `JclStrings` e, em Debug,
  `JclDebug`) e Abbrevia 2026.10. O console não usa JVCL, SynEdit nem VirtualTreeView.
- Resultado atual: 0 erros e 248 avisos, quase todos `W1057`/`W1058` (conversão implícita entre
  `string` e os `ShortString` dos registros do núcleo). Ver a seção 4.
- Recurso de versão: `src\jvcs\jvcsver.rc`. O `.res` versionado é gerado com
  `brcc32 -fojvcsver.res jvcsver.rc` (na pasta `src\jvcs`).

## 2. O que mudou

| Arquivo | Mudança |
|---|---|
| `src\comp\crc\Checksum.pas` (novo) | Recriação de `CRCInt`/`CRCString` conforme Algoritmos-Recuperados §1: CRC-32 IEEE (`$EDB88320`, início `$FFFFFFFF`, `not` final), leitura em blocos de `$8000` com `fmOpenRead or fmShareDenyNone`, resultado `Integer` com sinal, `'$'+IntToHex(crc,8)` ou a mensagem (`'OK'` para arquivo vazio). `{$R-}{$Q-}`. O handle não é mais truncado para `Word` (defeito do original). |
| `src\comp\midware\RFormat.pas` | TMWBuffer 1.48 "JVCS edition": buffer `PAnsiChar`/`AnsiChar`; textos convertidos string↔bytes pela code page `MWCodePage` (variável global, padrão **1252**) em `GetFields`, `GetMetaData`, `SetFields` e `AppendFields`. `AppendFields` trata `vtUnicodeString`, `vtWideString`, `vtPWideChar`, `vtWideChar` e `vtInt64` pelo `Length` (não trunca no `#0`). `vtAnsiString`, `vtString` (ShortString), `vtPChar`, `vtChar` e blobs passam como bytes, sem conversão. Separadores (`#127 #18 #20`), escapes (`F R C L N`, Esc+Esc), blob (`#127 'T' '1'`) e `FloatToStrF(ffGeneral,18)` iguais. Bookmarks restaurados (edições `-oFL` revertidas). Funções novas: `MWStrToBytes`, `MWBytesToStr`, `MWBufToStr`. |
| `src\comp\midware\ApsCli.pas` | ApsCli 3.06 "JVCS edition": `OverbyteIcsWSocket`/`OverbyteIcsTypes` (ICS 9); `PAnsiChar` nos buffers e eventos; cabeçalho `FunctionCode + ' '` em `AnsiString`; `SendStr(RawByteString(#13#10))`; `AllocateHWnd`/`DeallocateHWnd` de `System.Classes`; `SocketFamily := sfIPv4`; `AnswerStatus` decodificado pela code page. |
| `src\comp\midware\CBroker.pas` | `Windows` no `uses` da interface (`MsgWaitForMultipleObjects`); `FUserData`/`UserData` como `NativeInt`. `WaitForAnswer` continua igual (polling, sem timeout). |
| `src\comp\midware\MWDefs.inc` | `OverbyteIcsDefs.inc` no lugar do `IcsDefs.inc`; `{$UNDEF USE_SSL}`. |
| `src\jvcs\jvcs.dpr` | Sem `FastMM4` (gerenciador de memória embutido). `RFormat` no `uses` e `DefaultSystemCodePage := MWCodePage` no início, para que as conversões implícitas para `ShortString` (registros do núcleo) também usem 1252. Check-in com `CRCInt` em vez de `StrToInt(CRCString(...))`, que quebrava com arquivo vazio. |
| `src\jvcs\COMPOPT.INC` | `BETA` desligado (o 2.5.0.1030 não mostra o aviso de beta). Sem `IMAGEBASE`. |
| `src\jvcs\jvcsver.rc/.res` | FileVersion 2.5.0.2026, ProductVersion "2.5 Beta 2026", `FILEFLAGS VS_FF_PRERELEASE`. |
| `src\common\client\JVCSClientObj.pas` | `TJVCSLogin.DoExecute`: a senha cifrada vai como `ShortString` (`vtString`, bytes crus da FVCSCrypt). A **versão do LOGIN continua 239** (fixa em `JVCSConnect.pas`; não depende do recurso de versão). |
| `src\common\client\JVCSClientObjBase.pas` | `SafeStrToFloat` com `FormatSettings`. `TJVCSAbZipper` instala um `InsertFromStreamHelper` que **mantém a data do arquivo no item do ZIP** (ver 3.4). |
| `src\common\client\JVCSConnect.pas` | `OverbyteIcsTypes` no `uses` (`socksNoAuthentication`). |
| `tools\compilar.bat` | Console com `JVCSCONSOLECLIENT;BRANCHING`; cópia da `fvcscrypt.dll`. |
| `tools\golden\console\` (novo) | Scripts do golden: `proxy.ps1` (proxy TCP de captura 2107→2106), `norm.pl` (normalizador do fio), `blobs.pl` (extrai e descreve os blobs ZIP), `g.sh` (roda original e novo e compara a saída). |

Decisões tomadas no port (para registrar):

- **`JVCSCONSOLECLIENT` vai no `-D`.** As units de `..\jedivcs` (ex.: `JVCSClasses.pas`) incluem o
  `compopt.inc` da própria pasta, não o do console. Sem o define elas puxavam `ConfigStorage` →
  `VCSProcBase` → `FavOpenDialog` (GUI). O build original fazia isso por makefile (`JVCS_INMAKE`).
- **`BRANCHING` ligado no console.** O jvcs.exe 2.5.0.1030 foi compilado com branching: imprime
  `Branch: HEAD` e aceita `branch=`. Isso diverge da decisão geral de desligar o branching, mas é
  necessário para a saída ser idêntica. Só o `jvcs.dpr` usa o define, e ele não muda nenhuma
  requisição quando não se passa `branch=`. **Confirmar com o usuário.**
- **JCL:** nenhuma correção foi necessária no caminho do console. `AnsiCrLf`, `{$ifdef WINDOWS}` e
  `Trace` não aparecem nas units que ele usa. O console ainda depende da JCL do GetIt.
- **Abbrevia:** a do GetIt (2026.10), sem alterações no fonte dela.

## 3. Teste golden contra o servidor de teste

Método: os dois consoles rodaram os mesmos comandos. Comparei:

- (a) a saída (stdout) byte a byte, sem a 1ª linha do banner;
- (b) o tráfego TCP, capturado por um proxy local (`tools\golden\console\proxy.ps1`, 127.0.0.1:2107 →
  2106) e normalizado por `norm.pl`. O normalizador mascara só a senha cifrada e o `GetNowUTC` do
  LOGIN, os TransactionIDs, a resposta do `GET_SERVER_TIME` e a pasta de destino;
- (c) os arquivos extraídos (`cmp`).

As evidências estão em `doc\pt\client\golden-console\` (`saida\` = stdout, `fio\` = tráfego
normalizado). As capturas brutas, que contêm a senha cifrada, não foram versionadas.

### 3.1 Leitura

| Comando | Saída (a) | Fio (b) | Arquivos (c) |
|---|---|---|---|
| `listprojects` | **igual** (850 bytes) | **igual** (`GET_SERVER_TIME`, `LOGIN … 239 …`, `GET_PROJECT_INFORMATION`, `LOGOUT`) | — |
| `listproject exemplo01.dpr` | **igual** (1412 bytes, incluindo os `#0` do `StrAlign`) | **igual** | — |
| `listlocks all_users` | **igual** (416 bytes) | **igual** (`GET_LOCKED_MODULES`) | — |
| `openproject` + `getmodule 1..4 dest=… noprompt` | **igual** | **igual** (83 KB de respostas com 5 blobs, incluindo o `.res` binário de 154 792 bytes) | **iguais** (`Exemplo01.dpr/.dproj/.res`, `uPrincipal.pas/.dfm`), com a mesma data de arquivo |
| Build Release: `listprojects`, `listproject` | **igual** | — | — |

### 3.2 Ciclo de escrita

O módulo 4 (`uPrincipal.pas` + `.dfm`) estava na 0.5, sem locks, e a cópia local era igual ao
servidor.

1. **Ciclo 1 (console novo):** `checkout 4` → arquivos graváveis e lock de `sysdba`. Troquei o
   comentário final do `uPrincipal.pas` por um texto com `ação, revisão, ç, ã` (cp1252, CRLF).
   `checkin 4 "teste console portado - ação, revisão (ç, ã)"` (arquivo de input em cp1252) →
   **versão 0.6**, lock liberado, arquivos somente leitura.
   - O original (`listproject`) mostra 0.6 com as colunas Stamp/CRC **vazias**: o CRC e o timestamp
     gravados pelo console novo batem com o cálculo do original sobre o arquivo local. A saída é
     idêntica à do novo.
   - `getmodule 4` pelo **original** traz `uPrincipal.pas` e `.dfm` byte a byte iguais ao arquivo
     enviado.
   - CRC gravado: `-763147432` = `$D2834B58`, igual ao `CRCInt` local e ao CRC do diretório central
     do ZIP.
   - **Achado:** o blob ZIP saiu com a **hora do check-in** no item, e não com a data do arquivo. O
     `AbZipFromStream` do Abbrevia 2026 grava `Now`. Corrigi em `JVCSClientObjBase.pas` (commit
     `b4d60e6`). O conteúdo e o CRC da 0.6 estão corretos; só a data DOS dentro do ZIP da 0.6 ficou
     diferente.
2. **Ciclo 2 (console novo, com a correção):** mesmo roteiro → **versão 0.7**. Os itens do ZIP agora
   têm a data do arquivo em hora DOS arredondada para cima (21:29:41.29 → 21:29:42; `.dfm`
   21:08:41.90 → 21:08:42), como nos blobs do original. O blob do `.dfm`, que não mudou, ficou
   **byte a byte igual** ao que o original gerou no ciclo 3. CRC gravado: `-532114478` = `$E04893D2`.
3. **Ciclo 3 (console original, referência):** checkout, alteração e check-in pelo jvcs.exe
   2.5.0.1030 → **versão 0.8**. Serve para comparar o fio da escrita.
   - `CHECKOUT_ONLY_MODULE`/`GET_CHECKOUT_MODULE` e `CHECKIN_MODULE` têm a mesma estrutura nos dois
     consoles. Mudam só os IDs de revisão, a versão, as datas, o CRC, os tamanhos e os blobs do
     `.pas`.
   - O registro do `.dfm` no `CHECKIN_MODULE` é idêntico nos dois, inclusive o timestamp
     `46308,006040520832` e o CRC `-1776181078`.
   - Arquivos: `fio\novo_co.txt` × `fio\orig_co.txt` e `fio\novo_checkin_ciclo2.txt` ×
     `fio\orig_checkin_ciclo3.txt`.
4. **Leitura cruzada:** `getmodule 4 rev=0.6`, `rev=0.7` e `rev=0.8` pelo **original** e pelo
   **novo** trazem os mesmos arquivos nos dois. As revisões 0.6 e 0.7 (gravadas pelo novo) são
   iguais aos arquivos enviados, e a 0.8 (gravada pelo original) é igual à cópia local. A saída dos
   dois consoles também é idêntica.

**Prova da code page 1252 no comentário.** O console 2.5 não tem comando que mostre o comentário
de check-in, e nenhuma resposta do servidor ao console o devolve. A prova, por isso, é no fio:

- no `CHECKIN_MODULE` do console novo, o comentário sai com `ç` = `E7` e `ã` = `E3` (cp1252);
- o console original codifica o comentário dele exatamente do mesmo jeito (`ê` = `EA`, `ç` = `E7`,
  `ã` = `E3`).

Como os bytes que chegam ao servidor são os mesmos que o original manda, o GUI/IDE 2.5 mostra o
comentário igual. Os ecos das linhas de comando na saída também ficam em cp1252 nos dois consoles.

**Estado final:** sem locks (`listlocks all_users` vazio, igual nos dois). A cópia local de
`uPrincipal.pas`/`.dfm` é igual à revisão 0.8 do servidor (somente leitura), e
`listproject` mostra Stamp/CRC vazios nos dois consoles.

Observações do teste:

- `getmodule` aceita no máximo 4 parâmetros: `rev=` + `dest=` + `noprompt` estoura o limite e o
  comando mostra a ajuda. É comportamento do original e foi mantido.
- Os TransactionIDs são renovados pelo servidor, não pelo cliente (o servidor devolveu um TID novo ao
  original no meio da sessão e manteve o do novo). O normalizador mascara todos.
- Floats no fio (`GetNowUTC`, timestamps) saem com `FloatToStrF(ffGeneral,18)` e vírgula decimal
  (locale pt-BR), como no original.

## 4. Pendências

- **Revisões de teste no servidor:** o módulo 4 foi de 0.5 para 0.8 (0.6 e 0.7 pelo console novo,
  0.8 pelo original). A 0.6 tem a data do item ZIP igual à hora do check-in. O conteúdo está correto.
- **Code page:** testado só com ACP 1252 e locale pt-BR. Ainda faltam ACP 65001 e locale en-US
  (Plano F1 1.8). `DefaultSystemCodePage := MWCodePage` no console alinha as conversões dos
  `ShortString`; no GUI/DLL (F3–F5) a mesma regra precisa ser aplicada.
- **Avisos `W1057`/`W1058`** (248): conversões implícitas `string`↔`ShortString` nos registros do
  núcleo. Com `DefaultSystemCodePage = 1252` o resultado é o mesmo do original. Limpar na F2 completa.
- **Dependências que o plano quer eliminar** ainda presentes no console: JCL (`JclFileUtils`
  `GetSizeOfFile`/`PathAddSeparator`/`TJclFileVersionInfo`, `JclStrings`, `JclDebug` em Debug) e
  Abbrevia (ZIP). Os substitutos nativos (`JVCSZipUtils`, `JVCSFileUtils`, `JVCSStrUtils`,
  `JVCSTrace`) e o `JVCSTransport.pas` (F1 1.6) não foram feitos, por estarem fora do escopo deste
  port.
- **VCL no executável:** o `CBroker` usa `StdCtrls` quando `NOFORMS` não está definido, e isso puxa
  a VCL. O EXE fica com cerca de 3 MB de código. O original também fazia isso.
- **Win64:** não testado (FVCSCrypt.dll é 32 bits).
- **Não testados:** `syncproject`, `syncprojectgroup`, `labelproject`, `undocheckout`, `listbranches`
  e arquivos vazios ou binários no check-in.
