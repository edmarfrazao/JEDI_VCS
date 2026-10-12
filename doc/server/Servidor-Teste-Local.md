# Servidor de teste local (montado em 12/10/2026)

| Item | Valor |
|---|---|
| Máquina | esta (IP `10.211.55.3`, Windows 11 ARM64) |
| Servidor | JEDI VCS Firebird Server **2.50 Beta 3, versão aplicação** (`JVCSv2.50SalFIB.Beta 3.exe`, SourceForge, SHA-256 `018989AB…D119A696D`) instalado em `C:\Program Files (x86)\JEDI\JVCS\Server` |
| Porta | **2106** (banner "Welcome to JEDI VCS Firebird Server") |
| SGBD | **Firebird 2.5.9 instalado** (serviço `FirebirdServerDefaultInstance`, porta 3050), **não** o embutido |
| Banco | `C:\Program Files (x86)\JEDI\JVCS\server\archive\db_fib\JEDIVCS.FDB` — ODS 11.2, página 4096 |
| Login do servidor no Firebird | `SYSDBA` / `masterkey`, Server `LOCALHOST`, Char Set `NONE`, "Use Firebird embedded" desmarcado |
| Configuração efetiva | `%LOCALAPPDATA%\VirtualStore\Program Files (x86)\JEDI\JVCS\Server\jvcssrv.ini` (o servidor não tem permissão em Program Files; senha gravada criptografada) |
| Usuário inicial do JEDI VCS | `sysdba` / `admin` (padrão do banco novo; trocar após o 1º login) |

## Problemas encontrados e solução
1. **"unsupported on-disk structure ... found 11.2, support 11.1"**: o instalador vem com Firebird **2.1 embutido** (`fbembed.dll` 2.1.3,
   `FirebirdUseEmbeded=1`), mas o `JEDIVCS.FDB` foi criado no formato do **2.5** porque o `gbak` do instalador usou o `fbclient.dll` 2.5
   do sistema (`C:\Windows\SysWOW64`). Solução: usar o Firebird 2.5 instalado (embedded desmarcado, Server `LOCALHOST`).
2. **"Your user name and password are not defined" (152)**: a senha do Firebird gravada no servidor estava errada; digitar `masterkey`.
   A mensagem "firebird.msg not found" é só o texto do erro (cliente 2.5 sem `FIREBIRD` definido) e pode ser ignorada.

## Bancos de reserva
- `D:\Delphi\JediVCS\ServidorTeste\fb25\JEDIVCS.FDB` — restaurado do `jedivcs.fbk` oficial com o gbak **2.5** (ODS 11.2).
- `D:\Delphi\JediVCS\ServidorTeste\JEDIVCS.FDB` — restaurado com o Firebird **2.1 embutido** (ODS 11.1), para o modo embedded;
  ferramentas 2.1 isoladas em `D:\Delphi\JediVCS\ServidorTeste\fb21embed\`.

## Próximos passos de teste
1. Cliente (Delphi 13 ou `jedivcs.exe`): identidade `10.211.55.3:2106`, usuário `sysdba`, senha `admin` → trocar a senha.
2. Criar usuário administrador pessoal e usuário **IA** com poucos direitos (ver `doc\common\Credenciais.md` §c.8/c.10).
3. Tools → File Families Manager: família `.pas` com Child `.dfm;.fmx;` (ver `doc\client\Checkin-Familias-FMX.md`).
4. Criar um projeto de teste, check-in/check-out, histórico; capturas "golden" de tráfego para o port.
5. Verificar se o servidor permite duas sessões do mesmo usuário (GUI + CLI) — ver `Credenciais.md`, achado de sessão única.
