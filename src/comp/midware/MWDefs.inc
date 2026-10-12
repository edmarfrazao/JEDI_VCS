{$i IcsDefs.inc}    { Uses ICS definitions                }
{$IFDEF DELPHI6_UP}
    {$WARN SYMBOL_PLATFORM   OFF}
    {$WARN SYMBOL_LIBRARY    OFF}
    {$WARN SYMBOL_DEPRECATED OFF}
    {$WARN UNIT_PLATFORM     OFF}
{$ENDIF}
{$IFDEF BCB3_UP}
    {$ObjExportAll On}
{$ENDIF}
{$B-}               { Enable partial boolean evaluation   }
{$T-}               { Untyped pointers                    }
{$X+}               { Enable extended syntax              }
{$H+}               { Use long strings                    }
{$J+}               { Allow typed constant to be modified }
