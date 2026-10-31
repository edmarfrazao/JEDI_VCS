unit JVCSModuleSearch;

{ v2026: relevancia da pesquisa de modulos (campo Find do gerenciador de projetos).
  Funcao pura, sem VCL, para ser testada isolada (tests\cliente\teste-pesquisa.dpr). }

interface

const
  msrNone = 0;     // nao casa
  msrContains = 1; // contem o texto (ou a mascara casa em parte)
  msrWord = 2;     // comeca o nome ou uma parte dele (depois de . _ - \ ou espaco)
  msrExact = 3;    // nome igual (ou mascara inteira)

{ Name: nome do modulo; Path: pasta (com "\" final) ou ''; Search: texto pesquisado.
  Sem diferenciar maiusculas. Com * ou ?: mascara (so esses dois sao curinga; "[" e literal).
  Com \: casa em Path + Name. }
function JVCSModuleSearchRank(const Name, Path, Search: string): Integer;

{ * = qualquer sequencia (inclusive vazia), ? = um caractere; o resto e literal.
  Compara como recebe (passe tudo em minusculas). }
function JVCSWildMatch(const Mask, S: string): Boolean;

{ Filtro de nomes (arvore de projetos): mesma regra do campo Find, sem diferenciar maiusculas.
  - texto simples: o nome contem o texto; com espacos, cada palavra tem de aparecer (em qualquer ordem);
  - com * ou ?: a mascara casa com o nome inteiro ou com parte dele (como no Find).
  Filter vazio casa tudo. Highlight recebe uma letra por caractere de Name: 'F' = trecho encontrado
  (para o negrito), 'N' = resto. }
function JVCSFilterMatch(const Name, Filter: string; out Highlight: string): Boolean;

implementation

uses
  SysUtils;

function JVCSWildMatch(const Mask, S: string): Boolean;
var
  M, I, StarM, StarI: Integer;
begin
  // algoritmo guloso com retrocesso para o ultimo "*": O(len(Mask) * len(S)) no pior caso
  M := 1;
  I := 1;
  StarM := 0;
  StarI := 0;
  while I <= Length(S) do
  begin
    if (M <= Length(Mask)) and ((Mask[M] = '?') or ((Mask[M] <> '*') and (Mask[M] = S[I]))) then
    begin
      Inc(M);
      Inc(I);
    end
    else
    if (M <= Length(Mask)) and (Mask[M] = '*') then
    begin
      StarM := M;
      StarI := I;
      Inc(M);
    end
    else
    if StarM > 0 then
    begin
      M := StarM + 1;
      Inc(StarI);
      I := StarI;
    end
    else
      Exit(False);
  end;
  while (M <= Length(Mask)) and (Mask[M] = '*') do
    Inc(M);
  Result := M > Length(Mask);
end;

function JVCSModuleSearchRank(const Name, Path, Search: string): Integer;
var
  S, Target: string;
  P: Integer;
begin
  Result := msrNone;
  S := AnsiLowerCase(Trim(Search));
  if S = '' then
    Exit;
  Target := AnsiLowerCase(Name);
  if Pos('\', S) > 0 then
    Target := AnsiLowerCase(Path) + Target;
  if (Pos('*', S) > 0) or (Pos('?', S) > 0) then
  begin
    if JVCSWildMatch(S, Target) then
      Result := msrExact
    else
    if JVCSWildMatch('*' + S + '*', Target) then
      Result := msrContains;
    Exit;
  end;
  if Target = S then
    Result := msrExact
  else
  begin
    P := Pos(S, Target);
    if P = 1 then
      Result := msrWord
    else
    if P > 1 then
    begin
      Result := msrContains;
      // comeca uma parte do nome: "notafiscal" em "estrutura.firma.notafiscalsaida.pas"
      repeat
        if CharInSet(Target[P - 1], ['.', '_', '-', '\', ' ']) then
        begin
          Result := msrWord;
          Break;
        end;
        P := Pos(S, Target, P + 1);
      until P = 0;
    end;
  end;
end;

// Mascara (* e ?) com as posicoes dos caracteres literais que casaram (Marks[i] = 'F').
// Programacao dinamica, O(Length(Mask) * Length(S)): Ok[M][I] = Mask[M..] casa com S[I..].
// Depois percorre do inicio marcando os literais; o "*" pega o minimo (1a ocorrencia).
function WildMatchMarks(const Mask, S: string; var Marks: string): Boolean;
var
  Ok: array of array of Boolean;
  NM, NS, M, I: Integer;
begin
  NM := Length(Mask);
  NS := Length(S);
  SetLength(Ok, NM + 2, NS + 2);
  Ok[NM + 1][NS + 1] := True;
  for M := NM downto 1 do
    for I := NS + 1 downto 1 do
      if Mask[M] = '*' then
        Ok[M][I] := Ok[M + 1][I] or ((I <= NS) and Ok[M][I + 1])
      else
        Ok[M][I] := (I <= NS) and ((Mask[M] = '?') or (Mask[M] = S[I])) and Ok[M + 1][I + 1];
  Result := Ok[1][1];
  if not Result then
    Exit;
  M := 1;
  I := 1;
  while M <= NM do
    if Mask[M] = '*' then
    begin
      if Ok[M + 1][I] then
        Inc(M)
      else
        Inc(I);
    end
    else
    begin
      if Mask[M] <> '?' then
        Marks[I] := 'F';
      Inc(M);
      Inc(I);
    end;
end;

function JVCSFilterMatch(const Name, Filter: string; out Highlight: string): Boolean;
var
  F, Target, Term, Marks: string;
  Terms: TArray<string>;
  P, I: Integer;
begin
  Highlight := StringOfChar('N', Length(Name));
  F := AnsiLowerCase(Trim(Filter));
  if F = '' then
    Exit(True);
  Target := AnsiLowerCase(Name);
  Marks := StringOfChar('N', Length(Target));
  if (Pos('*', F) > 0) or (Pos('?', F) > 0) then
  begin
    // mascara: o nome inteiro, senao parte dele (como no Find); o "*" das pontas nao marca nada
    Result := WildMatchMarks(F, Target, Marks);
    if not Result then
    begin
      Marks := StringOfChar('N', Length(Target));
      Result := WildMatchMarks('*' + F + '*', Target, Marks);
    end;
  end
  else
  begin
    Result := True;
    Terms := F.Split([' '], TStringSplitOptions.ExcludeEmpty);
    for Term in Terms do
    begin
      P := Pos(Term, Target);
      if P = 0 then
        Exit(False);
      // todas as ocorrencias da palavra em negrito
      while P > 0 do
      begin
        for I := P to P + Length(Term) - 1 do
          Marks[I] := 'F';
        P := Pos(Term, Target, P + Length(Term));
      end;
    end;
  end;
  // AnsiLowerCase mantem o tamanho; se um dia nao mantiver, fica sem negrito
  if Result and (Length(Marks) = Length(Name)) then
    Highlight := Marks;
end;

end.
