(* JEDI VCS Compileroptions
-----------------------------------------------------------------------------

Unit history:

// 2003/03/09  THuber     - introduced MEMCHECK directive for checking memleaks
//                          over memcheck.pas
// 2003/05/31  USchuster  - introduced EXT_IDE_INTF directive
// 2003/03/09  THuber     - added JVCS_DEFINE_IN_MAKEFILE part for use in makefile
// 2003/11/06  THuber     - no more compiler settings defined for JVCS_DEFINE_IN_MAKEFILE
// 2004/01/12  THuber     - added USE_JEDI_JCL together with memcheck 2.67
// 2010/01/24  THuber     - HTML_HLP directive no more supported
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

  {.$DEFINE IDEDLL}         (* IDE expert version *)

  {$IFDEF IDEDLL}
    {.$DEFINE EXT_IDE_INTF}  (* create external IDE Interface *)
  {$ENDIF}

  {$DEFINE REPORTDLL}       (* reports extern *)

  {$DEFINE BLOWFISH}
  //???
  {.$DEFINE CUSTOMDRIVE}

  {.$DEFINE REQTEST}

  {$DEFINE RELEASE}        (* release version *)
  {.$DEFINE BETA}           (* beta version *)
  {$DEFINE DEBUG}          (* basic debug informations *)
  {.$DEFINE DEBUGMSG}       (* basic debug informations *)

  {$IFDEF DEBUG}
    {$D+,C+,L+,O-,Q+,R+}
    {$HINTS ON}
    {$WARNINGS ON}
  {$ELSE}
    {$D-,C-,L-,O+,Q-,R-}
    {$UNDEF DETAIL_DEBUG}
  {$ENDIF}

  {$DEFINE MIDWARE}
  {.$DEFINE SHOWIDS}        (* Show record numbers in listviews *)

  {$IFDEF BETA}
    {$UNDEF DEBUG}
  {$ENDIF}

  {.$DEFINE DBGFILE}       (* debug information file *)
  {.$DEFINE CHIDEBUG}      (* check in debug informations *)
  {.$DEFINE CHODEBUG}      (* check out debug informations *)
  {.$DEFINE NOTFDBG}       (* debug information FreeVCS notifier *)
  {.$DEFINE SHCHANGENTFY}  (* debug information Register Table changed *)
  {$IFOPT d+}
   {$DEFINE MEMCHECK}      (* changable: let memcheck search for memory leaks *)
  {$ENDIF}
  {$IFDEF MEMCHECK}
    {$W+}
    {$DEFINE USE_JEDI_JCL}  (* needs memcheck v2.67 *)
  {$ENDIF}
{$ENDIF JVCS_INMAKE}



