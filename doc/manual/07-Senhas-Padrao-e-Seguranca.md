# 07. Senhas padrão e segurança

Quais senhas vêm de fábrica, o que trocar e como proteger o servidor e as credenciais. Análise detalhada e proposta de armazenamento seguro: [Credenciais.md](../common/Credenciais.md).

## 1. Senhas padrão

| Onde | Usuário | Senha padrão | Para quê | Trocar? |
|---|---|---|---|---|
| **Firebird** (servidor JEDI VCS → banco) | `SYSDBA` | `masterkey` | O `JVCSSrv.exe` abre o `.FDB` com esse login (tela "Logon to Firebird"). Também vale para `gbak`, `gstat`, `isql` | **Sim, em produção** |
| **JEDI VCS** (cliente → servidor) | `sysdba` | `admin` (tudo minúsculo) | Administrador de fábrica do arquivo (Archive Administrator). Vem do script `fib_ib_defvalues.sql` | **Sim, no primeiro acesso** |
| Usuários importados do FreeVCS/Paradox (conversão com o `PDX2DBISAM`) | cada usuário antigo | `freevcs` | Todos recebem esse login e ficam no grupo Read-Write | **Sim, imediatamente** (cada um ou o administrador) |
| Chave de criptografia dos módulos (Data Encryption) | n/a | Nenhuma: você a define | Blowfish, 16 a 56 caracteres | Nunca troque depois de usar (capítulo 04) |

O script de dados iniciais traz o aviso do próprio JEDI VCS: "create a new administrator and delete sysdba after installation or change the default password immediately!".

> **Só no ambiente de teste:** o servidor de teste desta máquina (`192.168.0.10:2106`) continua com `SYSDBA`/`masterkey` no Firebird e `sysdba`/`admin` no JEDI VCS. Não replique isso em produção.

Regras de senha do JEDI VCS: usuário de 2 a 50 caracteres e senha de **5 a 50**, ambos **diferenciam maiúsculas**.

## 2. O que trocar e como

### 2.1 Senha do `sysdba` do JEDI VCS

Cliente: **Server > Change Password...** (Old, New, Confirm). Passo a passo no [capítulo 02](02-Cliente-Primeiro-Acesso.md), seção 4. Depois crie o seu usuário administrador e use o `sysdba` só como conta de emergência.

### 2.2 Senha do `SYSDBA` do Firebird

Comando padrão do Firebird 2.5, com o **servidor JEDI VCS fechado** (não executado aqui; a validar):

```powershell
& "C:\Program Files\Firebird\Firebird_2_5\bin\gsec.exe" -user SYSDBA -password masterkey -modify SYSDBA -pw <nova-senha>
```

1. Depois, abra o servidor, **Version Archive > Logon to database...**, digite a nova senha e confirme (é gravada criptografada no `jvcssrv.ini`).
2. Atualize qualquer script de backup (`gbak`) que use a senha.
3. Use `ISC_PASSWORD` (variável de ambiente padrão do Firebird) na sessão, em vez de `-password`, para não deixar a senha na linha de comando.

### 2.3 Senhas de usuários importados do FreeVCS

Peça a cada um para trocar em **Server > Change Password...** ou troque você, em **Server > Administration > User List... > Change Password...**.

## 3. Onde cada segredo fica (e quem consegue ler)

| Segredo | Onde fica | Como é protegido | Risco |
|---|---|---|---|
| Senha do Firebird | `jvcssrv.ini` efetivo (`%LOCALAPPDATA%\VirtualStore\Program Files (x86)\JEDI\JVCS\Server\jvcssrv.ini`) | Criptografada pelo servidor | Quem lê o arquivo pode tentar quebrar; proteja a pasta |
| Senhas dos usuários do JEDI VCS | Tabela de usuários no banco | Reversível (o servidor consegue recuperar o texto) | Quem tem acesso ao banco ou a um backup pode recuperá-las. **Não reutilize** senha do Windows, domínio ou internet |
| Senha salva na **identidade** do cliente | `HKCU\Software\JEDI\JEDIVCS\Identities\<nome>\Password` | Só **Base64** (codificação, não criptografia) | Qualquer processo seu, administradores, backups e `reg export` leem em texto puro. Nesta máquina a identidade `DEFAULT` tem senha gravada |
| Chave de criptografia dos módulos | `Options\EncodeKey` (Base64) | Idem | Idem |
| Senha na linha de comando | Processo, histórico, auditoria, transcrição de IA | Nenhuma | Veja o [capítulo 06](06-Linha-de-Comando.md) |

Além disso, o **tráfego com o servidor não é criptografado**, e a senha cifrada do login vale cerca de um minuto (reenvio possível dentro desse tempo).

## 4. Boas práticas

### Contas e senhas
1. Uma conta **por pessoa** e uma por automação. Nunca compartilhe o `sysdba`.
2. Senhas longas e únicas, num gerenciador de senhas. Nada de papel/planilha no servidor de arquivos.
3. **Desmarque "Store Password with identity"** (Server Login > Options). Se precisar do auto-login, entenda que a senha fica em Base64 no registro.
4. Mantenha **"Enable local login w/o password" desligado** (Server Properties > Security): ele deixa o IP do próprio servidor entrar com senha em branco.
5. Usuário da IA com nível **Guest** + direito Read-Write só nos projetos necessários, e senha que a IA **nunca** vê (capítulo 02, seção 9). Regras `deny` para o Claude Code ler `reg query`/`Get-ItemProperty` em `HKCU\Software\JEDI\JEDIVCS\Identities` estão em [Credenciais.md](../common/Credenciais.md), seção c.10.

### Servidor
6. Instalar fora de `Program Files`, com permissão de pasta só para quem administra.
7. **Security > Disable SQL Server Object** marcado (padrão): a Direct SQL é só para administração e pode destruir o arquivo de versões.
8. Fora da LAN: **Disable Server Banner** e **Change Server Banner...**, para não anunciar o que é o serviço.
9. **Server Properties > Security**: "Login idle timer active" e "Login restricted to stored IP address" quando fizer sentido.
10. **Firewall**: 2106 só para a rede interna; 3050 (Firebird) fechada; considere `RemoteBindAddress = 127.0.0.1` no `firebird.conf` (capítulo 01, seção 6).
11. **Check-in restritivo** ligado: evita que alguém passe por cima de um módulo em check-out.
12. Mantenha o **VCS log** ligado: o histórico do projeto depende dele.
13. **Backups**: `gbak` diário em outro disco; guarde também o `jvcssrv.ini`; teste a restauração.
14. Rede: sem criptografia, **VPN/IPsec** ou túnel TLS (por exemplo `stunnel`) para qualquer acesso fora da LAN.
15. Relógios sincronizados; "Verify Client Timestamp" rejeita clientes com mais de ±2 h de diferença.

### Depois de um incidente ou migração
16. Se a senha ficou em Base64 em registro, backup ou transcrição, **troque-a**, pois a exposição já ocorreu.
17. Se o cliente 2.5 antigo ainda estiver instalado, ele volta a gravar Base64 (por isso o plano de migração em [Credenciais.md](../common/Credenciais.md), seção c.7).

## 5. O que vem no port (planejado)

O port vai guardar a senha da identidade no **Gerenciador de Credenciais do Windows** em vez de Base64, com a mesma experiência ("Store Password with identity" e auto-login continuam). A CLI passa a usar a identidade salva, sem aceitar `--password` por padrão. Detalhes e riscos residuais: [Credenciais.md](../common/Credenciais.md). Até lá, valem as práticas acima.
