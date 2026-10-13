(*-----------------------------------------------------------------------------
JEDI VCS 2.5 Beta 2026 (port Delphi 13) - mwPasLexTypes.pas

Reimplementacao minima (codigo novo, nao e o fonte de Martin Waldenburg nem o
CastaliaPasLex) dos tipos do lexer Pascal usado por UsedUnits, ProjDependencies,
ToDo e VerSet. So os tokens de que o cliente precisa tem nome proprio; as demais
palavras reservadas viram ptKeyword. Licenca: MPL 1.1.
-----------------------------------------------------------------------------*)

unit mwPasLexTypes;

interface

type
  TptTokenKind = (
    ptNull,            // fim do texto (#0)
    ptSpace, ptCRLF,
    ptAnsiComment, ptBorComment, ptSlashesComment,
    ptCompDirect, ptIncludeDirect, ptResourceDirect,
    ptIdentifier, ptKeyword,
    ptUnit, ptUses, ptProgram, ptLibrary, ptIn, ptExport, ptExports, ptExternal,
    ptString, ptAsciiChar, ptNumber, ptFloat, ptIntegerConst,
    ptSemiColon, ptComma, ptPoint, ptColon, ptRoundOpen, ptRoundClose,
    ptSquareOpen, ptSquareClose, ptEqual, ptSymbol, ptUnknown);

const
  JunkTokens = [ptSpace, ptCRLF, ptAnsiComment, ptBorComment, ptSlashesComment];

implementation

end.
