{ JVCS edition: ICS 9 (OverbyteIcsDefs.inc) no lugar do IcsDefs.inc V5 }
{$i OverbyteIcsDefs.inc}    { Uses ICS definitions                }
{$UNDEF USE_SSL}            { JVCS: Midware sem SSL (ApsCliIntfSsl.inc nao existe) }
{$WARN SYMBOL_PLATFORM   OFF}
{$WARN SYMBOL_LIBRARY    OFF}
{$WARN SYMBOL_DEPRECATED OFF}
{$WARN UNIT_PLATFORM     OFF}
{$B-}               { Enable partial boolean evaluation   }
{$T-}               { Untyped pointers                    }
{$X+}               { Enable extended syntax              }
{$H+}               { Use long strings                    }
{$J+}               { Allow typed constant to be modified }
