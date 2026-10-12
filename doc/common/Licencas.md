# Licenças — pontos de atenção

| Componente | Licença | Impacto |
|---|---|---|
| JEDI VCS (código do cliente) | MPL 1.1 | Pode ser modificado e redistribuído; manter cabeçalhos MPL e disponibilizar o fonte das modificações. |
| **Midware** (ApsCli, RFormat, CBroker — F. Piette) | Freeware **só para uso não comercial**; uso em empresa exige licença paga (o ReadMw cita 1100 EUR); versões alteradas devem ser marcadas como tal | **Decisão do usuário: decidir depois.** Portar agora, mas isolar o transporte atrás de uma interface própria (`JVCSTransport.pas`) para permitir trocar por ICS/Indy puro mantendo o mesmo formato de bytes. |
| CipherLz (Midware 1.01) | exclui uso comercial | Código morto no cliente (EncryptServerData forçado a False) → remover. |
| ICS V9 (Overbyte) | freeware | OK. |
| JCL / JVCL | MPL 1.1 | OK. |
| SynEdit | MPL 1.1 / GPL 2 | OK. |
| VirtualTreeView | MPL 1.1 / LGPL 2.1 | OK. |
| DFS (EnhListView, SystemTreeView, StatusBar — Brad Stowers) | proíbe redistribuir fonte modificado isolado | Não reaproveitar → controles nativos. |
| FastMM5 | GPL v3 ou comercial | Não usar em binário distribuído (FastMM4 MPL/LGPL só em depuração, ou o MM embutido). |
| EncryptedZipFile (Uwe Raabe) | MIT | OK (Backup com senha sem Abbrevia). |
| FVCSCrypt.dll | binário fechado do FreeVCS/JEDI VCS | Redistribuir o mesmo binário do instalador 2.50 Beta 3. |
