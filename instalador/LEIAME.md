# instalador

Ponto de entrada para **gerar à mão o instalador (beta) do JEDI VCS 2.5 Beta 2026**. Os scripts daqui só chamam as
ferramentas de `tools\` (compilação, versão, Inno Setup) e o script do setup em `setup\JediVCS2026.iss`. O passo a
passo completo, com os testes e a publicação, está em [doc/COMO-GERAR.md](doc/COMO-GERAR.md).

## Estrutura

| Pasta / arquivo | O que é |
|---|---|
| `bin\gerar.bat` | gera o instalador completo: compila Release Win32, confere as versões, empacota e copia |
| `bin\gerar-sem-build.bat` | só empacota o que já está em `bin\` (não compila) |
| `bin\copiar.bat [pasta]` | copia o setup da versão atual para a pasta de distribuição, com o `SHA256.txt` |
| `bin\conferir.bat` | mostra a versão, os binários, o setup com o SHA-256 e a cópia na pasta de distribuição |
| `bin\versao.bat [build [beta]]` | mostra ou muda a versão em `tools\versao.ini` |
| `bin\_comum.bat`, `bin\*.ps1` | uso interno dos `.bat` |
| `config\distribuicao.exemplo.bat` | exemplo da configuração da pasta de distribuição |
| `config\distribuicao.bat` | a configuração deste PC (**fora do git**: o repositório é público e o caminho é pessoal) |
| `doc\COMO-GERAR.md` | como gerar, conferir, testar e publicar um beta |

## Uso rápido

```bat
rem 1. feche o Delphi
rem 2. (só uma vez) copie config\distribuicao.exemplo.bat para config\distribuicao.bat e ajuste a pasta
instalador\bin\versao.bat
instalador\bin\gerar.bat
```

O setup sai em `setup\Output\JediVCS-2.5.0-Beta<N>-build<Build>-Setup.exe`. Com a pasta de distribuição
configurada, **todo beta gerado também vai para ela**, com o `SHA256.txt` regravado.
