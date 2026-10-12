(* JEDI VCS Diff Compileroptions
-----------------------------------------------------------------------------

Unit history:

// 2004/01/05  USchuster  - new include
// 2004/01/12  THuber     - added USE_JEDI_JCL together with memcheck 2.67
// 2010/01/24  THuber  Shortened JVCS_DEFINE_IN_MAKEFILE to JVCS_INMAKE to avoid compiler error.
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
  {$IMAGEBASE $00400000}
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

  {$IFOPT d+}
   {$DEFINE MEMCHECK}      // changable: let memcheck search for memory leaks
  {$ENDIF}
  {$IFDEF MEMCHECK}
    {$W+}
    {$DEFINE USE_JEDI_JCL}  (* needs memcheck v2.67 *)
  {$ENDIF}
{$ENDIF JVCS_INMAKE}
