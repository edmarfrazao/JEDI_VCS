# Decisões do port (registro)

| Data | Tema | Decisão | Quem |
|---|---|---|---|
| 12/10/2026 | Escopo | Portar **só o cliente** (EXE, DLL da IDE, Diff, console). Servidor 2.5 Beta 3 (Firebird) permanece; protocolo idêntico. | usuário |
| 12/10/2026 | IDE alvo | Delphi 13.2 Professional; também compilar/instalar em Delphi 11 e 12. **Padronizar as 3 IDEs já** (mesmas fontes de terceiros). | usuário |
| 12/10/2026 | SynEdit | pyscripter/SynEdit `84391a3`, fixado em `src\comp\synedit` (compila em 11/12/13). Desinstalar o SynEdit TurboPack do GetIt. | usuário (via padronização) |
| 12/10/2026 | VirtualTreeView | JAM V8.5, fixado em `src\comp\virtualtreeview`. Desinstalar o VTV 8.3 do GetIt. | usuário (via padronização) |
| 12/10/2026 | JCL / JVCL / ICS / Abbrevia | D13: GetIt (JCL/JVCL 2026.08, ICS 9.7, Abbrevia 2026.10). D11/D12: mesma versão pelo GitHub/SVN quando essas IDEs forem instaladas. JVCL e Abbrevia são só ponte (saem nas fases F2–F4). | plano |
| 12/10/2026 | Recursos | **Só o básico.** Desligar: relatórios via `jedivcsreport.dll` (`REPORTDLL`), tradução (`LANGUAGE`/gettext), notificação entre estações (mailslot/SMTP), plugins (`TJvPluginManager`) e branching (`BRANCHING`). O código fica sob defines desligados ou é removido; nada disso afeta o protocolo. | usuário |
| 12/10/2026 | LZH / CipherLz | Remover (código morto dos dois lados; licença não comercial). Resposta iniciada por `#$FF` vira erro explícito. | plano |
| 12/10/2026 | Midware | Licença não comercial: **decidir depois**. Portar agora isolando o transporte em `JVCSTransport.pas`. | usuário |
| 12/10/2026 | Teste de protocolo | Usuário vai montar um **servidor 2.5 Beta 3 de teste** com cópia do banco; captura "golden" do cliente oficial 2.5.0.1030 (`3rdparty\referencia-2.5.0.1030`). | usuário |
| 12/10/2026 | Plataforma | Fase 1 só Win32 (FVCSCrypt.dll é 32 bits). Win64/ARM64EC opcionais (F6). | plano |
| 12/10/2026 | Git | Repositório local em `v2026`, sem conversão de fim de linha (`.gitattributes: * -text`). | usuário |
