program teste_pesquisa;

{ Testes da relevancia da pesquisa de modulos (campo Find do gerenciador de projetos):
  src\common\client\JVCSModuleSearch.pas. Compilar e rodar: tests\cliente\teste-pesquisa.ps1 }

{$APPTYPE CONSOLE}

uses
  SysUtils,
  JVCSModuleSearch in '..\..\src\common\client\JVCSModuleSearch.pas';

var
  OkN, FalhaN: Integer;

procedure Caso(const Nome, Path, Busca: string; Esperado: Integer);
var
  R: Integer;
begin
  R := JVCSModuleSearchRank(Nome, Path, Busca);
  if R = Esperado then
  begin
    Inc(OkN);
    Writeln('[OK] "', Busca, '" em ', Path, Nome, ' = ', R);
  end
  else
  begin
    Inc(FalhaN);
    Writeln('[FALHA] "', Busca, '" em ', Path, Nome, ': esperado ', Esperado, ', veio ', R);
  end;
end;

// Filtro da arvore de projetos (JVCSFilterMatch): casa ou nao, e as letras em negrito
// (Marcas: 'F' = em negrito; '' = nao conferir).
procedure Filtro(const Nome, Filtro: string; Esperado: Boolean; const Marcas: string = '');
var
  R: Boolean;
  H: string;
begin
  R := JVCSFilterMatch(Nome, Filtro, H);
  if (R = Esperado) and ((Marcas = '') or (H = Marcas)) and (Length(H) = Length(Nome)) then
  begin
    Inc(OkN);
    Writeln('[OK] filtro "', Filtro, '" em ', Nome, ' = ', R, ' ', H);
  end
  else
  begin
    Inc(FalhaN);
    Writeln('[FALHA] filtro "', Filtro, '" em ', Nome, ': esperado ', Esperado, ' ', Marcas, ', veio ', R, ' ', H);
  end;
end;

procedure TestesFiltro;
begin
  // o bug relatado: "01" e "ex" nao filtravam (antes era "igual ao nome inteiro")
  Filtro('exemplo01.dpr', '01', True,  'NNNNNNNFFNNNN');
  Filtro('exemplo01.dpr', 'EX', True,  'FFNNNNNNNNNNN');
  Filtro('ex2.dpr',       'ex', True,  'FFNNNNN');
  Filtro('zz-teste-ia.dpr', '01', False);
  // vazio e so espacos: tudo
  Filtro('ex2.dpr', '', True, 'NNNNNNN');
  Filtro('ex2.dpr', '   ', True, 'NNNNNNN');
  // varias palavras: todas, em qualquer ordem; todas as ocorrencias em negrito
  Filtro('zz-teste-mod.dpr', 'mod teste', True, 'NNNFFFFFNFFFNNNN');
  Filtro('zz-teste-mod.dpr', 'mod ia', False);
  Filtro('aaxaa.dpr', 'aa', True, 'FFNFFNNNN');
  // mascaras: o nome inteiro ou parte dele (como no Find)
  Filtro('exemplo01.dpr', 'ex*.dpr', True, 'FFNNNNNNNFFFF');
  Filtro('exemplo01.dpr', '*01*', True, 'NNNNNNNFFNNNN');
  Filtro('exemplo01.dpr', 'plo?1', True, 'NNNNFFFNFNNNN');
  Filtro('exemplo01.dpr', '*.dpk', False);
  Filtro('zz-ex2.dpr', 'ex*', True);
  Filtro('ab.pas', '**b?p*', True);
  Filtro('ab.pas', 'ab?.pas', False);
  // colchete e literal
  Filtro('proj[old].dpr', '[old]', True, 'NNNNFFFFFNNNN');
  // acentos sem diferenciar maiusculas
  Filtro('Ação.dpr', 'AÇÃO', True, 'FFFFNNNN');
end;

const
  P = 'c:\fontes\src\compartilhado\firma\';
begin
  OkN := 0;
  FalhaN := 0;
  // digitos (o bug relatado: "01" nunca pesquisava)
  Caso('Exemplo01.dpr', P, '01', msrContains);
  Caso('Exemplo01.dpr', P, 'exemplo01', msrWord);
  Caso('Exemplo01.dpr', P, 'EXEMPLO01.DPR', msrExact);
  Caso('uPrincipal.pas', P, '01', msrNone);
  // contem / comeco de parte do nome
  Caso('uPrincipal.pas', P, 'princ', msrContains);
  Caso('uPrincipal.pas', P, 'upri', msrWord);
  Caso('Estrutura.Firma.Sesiag.NotaFiscalSaida.pas', P, 'notafiscal', msrWord);
  Caso('Estrutura.Firma.Sesiag.NotaFiscalSaida.pas', P, 'fiscalsaida', msrContains);
  Caso('Estrutura.Firma.Sesiag.NotaFiscalSaida.pas', P, 'sesiag.nota', msrWord);
  Caso('u_cliente_dados.pas', P, 'dados', msrWord);
  Caso('meu-form.pas', P, 'form', msrWord);
  // a 1a ocorrencia no meio de palavra, a 2a no comeco de parte
  Caso('abcnota.nota.pas', P, 'nota', msrWord);
  // mascaras
  Caso('Exemplo01.res', P, '*.res', msrExact);
  Caso('Exemplo01.res', P, 'exemplo??.res', msrExact);
  Caso('Exemplo01.res', P, 'plo*', msrContains);
  Caso('uPrincipal.pas', P, '*.res', msrNone);
  Caso('uPrincipal.pas', P, '[abc', msrNone); // mascara invalida nao estoura
  // colchete e literal (so * e ? sao curinga)
  Caso('Relatorio[old].pas', P, 'relatorio[old]*', msrExact);
  Caso('Relatorio[old].pas', P, 'relatorio[old]', msrWord);
  Caso('form[x.pas', P, 'form[*', msrExact);
  // curingas: retrocesso, ? exige um caractere, * vazio
  Caso('abcabd.pas', P, 'a*bd.pas', msrExact);
  Caso('ab.pas', P, 'ab?.pas', msrNone);
  Caso('ab.pas', P, 'ab*.pas', msrExact);
  Caso('ab.pas', P, '*', msrExact);
  Caso('ab.pas', P, '**b?p*', msrExact);
  Caso('ab.pas', P, 'b?p', msrContains);
  // com \: caminho + nome
  Caso('uPrincipal.pas', P, 'firma\upri', msrWord); // logo apos a barra
  Caso('uPrincipal.pas', P, 'c:\fontes\', msrWord);
  Caso('uPrincipal.pas', P, 'outra\upri', msrNone);
  Caso('uPrincipal.pas', P, 'firma\*.pas', msrContains);
  // sem \ o caminho nao conta
  Caso('uPrincipal.pas', P, 'fontes', msrNone);
  // vazio e espacos
  Caso('uPrincipal.pas', P, '', msrNone);
  Caso('uPrincipal.pas', P, '  princ  ', msrContains);
  // acentos (ANSI/Unicode) sem diferenciar maiusculas
  Caso('Ação.pas', P, 'AÇÃO', msrWord);
  TestesFiltro;
  Writeln;
  Writeln(OkN, ' OK, ', FalhaN, ' falha(s)');
  if FalhaN > 0 then
    ExitCode := 1;
end.
