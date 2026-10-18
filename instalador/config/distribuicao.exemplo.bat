@echo off
rem ==========================================================================
rem  distribuicao.exemplo.bat - EXEMPLO. Copie para distribuicao.bat (mesma
rem  pasta) e ajuste o caminho. O distribuicao.bat NAO vai para o git
rem  (.gitignore): o repositorio e publico e o caminho e pessoal.
rem
rem  JVCS_COPIA_SETUP = pasta para onde todo setup gerado tambem e copiado,
rem  com o SHA256.txt regravado (tools\copiar-setup.ps1). Ex.: a pasta
rem  compartilhada de onde o PC de testes instala.
rem ==========================================================================
set "JVCS_COPIA_SETUP=%USERPROFILE%\<pasta compartilhada>\instaladores"
