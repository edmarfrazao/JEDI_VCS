{ compopt.inc VAZIO - so para compilar src\common\JVCSIDEInterfaceCommon.pas no
  teste de ABI do expert (tests\JvcsAbiCrossCheck.pas), sem $IMAGEBASE,
  $APPTYPE GUI, DEBUG/MEMCHECK do compopt.inc real (src\jedivcs). As diretivas
  que afetam o layout ($A+ = $A8, $Z1) sao as padrao do compilador, as mesmas
  do compopt.inc real. IDEDLL fica indefinido -> FUNCTIONRECS (records da ABI). }
