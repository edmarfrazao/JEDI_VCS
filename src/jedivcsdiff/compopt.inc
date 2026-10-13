(* JEDI VCS Diff Compileroptions
-----------------------------------------------------------------------------

Unit history:

// 2004/01/05  USchuster  - new include
// 2004/01/12  THuber     - added USE_JEDI_JCL together with memcheck 2.67
// 2010/01/24  THuber  Shortened JVCS_DEFINE_IN_MAKEFILE to JVCS_INMAKE to avoid compiler error.
// 2026/10/12  v2026      - port Delphi 13: sem IMAGEBASE e sem MEMCHECK
-----------------------------------------------------------------------------*)

{$IFDEF JVCS_INMAKE}
  // ********************************************************************** //
  //                                                                        //
  //                   !!! Don't put here any DEFINE's !!!                  //
  //                                                                        //
  //    It's for use in makefile which DEFINE's JVCS_DEFINE_IN_MAKEFILE     //
  //    and all necessary other DEFINE's for the target client application  //
  //                                                                        //
  // ********************************************************************** //
{$ELSE}

  {$A+,B-,E-,F-,G+,H+,I+,J+,K-,M-,N+,P+,S-,T-,U-,V+,W-,X+,Y+,Z1}
  {$MINSTACKSIZE $00004000}
  {$MAXSTACKSIZE $00100000}
  {$APPTYPE GUI}

  {.$DEFINE DEBUG}          // basic debug informations

  {$IFDEF DEBUG}
    {$D+,C+,L+,O-,Q+,R+}
    {$HINTS ON}
    {$WARNINGS ON}
  {$ELSE}
    {$D-,C-,L-,O+,Q-,R-}
    {$UNDEF DETAIL_DEBUG}
  {$ENDIF}

  // v2026: sem IMAGEBASE fixo e sem MemCheck/USE_JEDI_JCL (FastMM4 removido).
{$ENDIF JVCS_INMAKE}
