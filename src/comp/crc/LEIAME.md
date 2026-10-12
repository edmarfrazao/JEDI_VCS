# comp\crc

Destino de **Checksum.pas** (CRCInt/CRCString), ausente no clone. Precisa ser recriada com algoritmo **idêntico** ao antigo: o CRC é gravado no servidor (BLOBS.ORIGCRC) no check-in e comparado em checkout, sync, dirty-check e busca por CRC. Candidata: System.ZLib.crc32 (IEEE) lendo o arquivo em blocos, resultado Integer com sinal, CRCString = '$'+IntToHex(crc,8), unit com {$R-}{$Q-}. Validar contra CRCs reais do banco antes de adotar.
