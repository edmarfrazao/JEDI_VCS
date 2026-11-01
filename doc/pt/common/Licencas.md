# Licenças — pontos de atenção

Criadores, mantenedores, direitos dos autores e a exigência da `FVCSCrypt.dll`: [Creditos-e-Direitos.md](Creditos-e-Direitos.md).

| Componente | Licença | Impacto |
|---|---|---|
| JEDI VCS (código do cliente) | MPL 1.1 | Pode ser modificado e redistribuído; manter cabeçalhos MPL e disponibilizar o fonte das modificações. |
| **Midware** (ApsCli, RFormat, CBroker — F. Piette) | Freeware **somente para uso pessoal/não comercial** (texto original: "excluding commercial applications ... personal use only"). O uso dentro de empresas não está claramente coberto e depende de autorização do autor; não há oferta comercial pública confirmada em 2026 (o MidWare V7, de 2012, é a última versão). Versões alteradas devem ser marcadas como tal | **Decisão de projeto (13/10/2026): manter no repositório público e cumprir a licença.** A redistribuição é livre; a versão alterada está marcada ("JVCS edition") no cabeçalho de ApsCli, RFormat e CBroker e o aviso original foi mantido. **Os executáveis** (`Jedivcs.exe`, `JvcsExternalDll.dll`, `jvcs.exe`) contêm o MidWare e ficam sujeitos à mesma restrição até a troca do transporte; o código MPL pode ser reutilizado sem ela. O texto obrigatório "This product is based on MidWare. Freeware source code is available at http://www.overbyte.be." está no `README.md`, no `LICENSE`, na aba Credits do About (EXE e DLL, `JVCSBaseAboutDialog.dfm`) e no banner do console (`jvcs.dpr`). Portar agora, mas isolar o transporte atrás de uma interface própria (`JVCSTransport.pas`) para permitir trocar por ICS/Indy puro mantendo o mesmo formato de bytes. |
| CipherLz (Midware 1.01) | exclui uso comercial | Código morto no cliente (EncryptServerData forçado a False) → remover. |
| ICS V9 (Overbyte) | freeware | OK. |
| JCL / JVCL | MPL 1.1 | OK. |
| SynEdit | MPL 1.1 / GPL 2 | OK. |
| VirtualTreeView | MPL 1.1 / LGPL 2.1 | OK. |
| DFS (EnhListView, SystemTreeView, StatusBar — Brad Stowers) | proíbe redistribuir fonte modificado isolado | Não reaproveitar → controles nativos. |
| FastMM5 | GPL v3 ou comercial | Não usar em binário distribuído (FastMM4 MPL/LGPL só em depuração, ou o MM embutido). |
| EncryptedZipFile (Uwe Raabe) | MIT | OK (Backup com senha sem Abbrevia). |
| FVCSCrypt.dll | binário fechado do FreeVCS/JEDI VCS; **licença não declarada**, sem concessão escrita | Redistribuir o mesmo binário do instalador 2.50 Beta 3, sem alteração, como o Project JEDI fazia desde 2003. Se o autor se opuser, a DLL sai e o login deixa de funcionar até existir uma implementação própria. |
| Units MidWare em `src/comp/_legacy` | freeware não comercial, **inalteradas** | Cópia intacta só para referência, fora do build e do instalador ("distribute it freely untouched"); ver `src/comp/_legacy/LEIAME.md`. |
