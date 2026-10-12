(* JEDI VCS Console Compileroptions *)
// 2003/10/27  USchuster  - new include
// 2003/11/06  THuber     - no more compiler settings defined for JVCS_DEFINE_IN_MAKEFILE
// 2010/01/24  THuber  Shortened JVCS_DEFINE_IN_MAKEFILE to JVCS_INMAKE to avoid compiler error.

{$IFDEF JVCS_INMAKE}
  // ********************************************************************** //
  //                                                                        //
  //                   !!! Don't put here any DEFINE's !!!                  //
  //                                                                        //
  //    It's for use in makefile which DEFINE's JVCS_DEFINE_IN_MAKEFILE     //
  //    and all necessary other DEFINE's for the target server application  //
  //                                                                        //
  // ********************************************************************** //
{$ELSE}

  {$A+,B-,E-,F-,G+,H+,I+,J+,K-,M-,N+,P+,S-,T-,U-,V+,W-,X+,Y+,Z1}
  {$MINSTACKSIZE $00004000}
  {$MAXSTACKSIZE $00100000}
  {$IMAGEBASE $00400000}
  {$APPTYPE CONSOLE}

  {$DEFINE JVCSCONSOLECLIENT}

  {$DEFINE BETA}           (* beta version *)
  {.$DEFINE DEBUG}          (* basic debug informations *)

{$ENDIF JVCS_INMAKE}
