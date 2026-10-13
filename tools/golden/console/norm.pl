# normaliza captura do proxy: perl norm.pl c2s.bin s2c.bin [dest]  -> stdout
# Mascara apenas o que varia legitimamente entre execucoes:
# - LOGIN: senha cifrada (depende da hora do servidor) e GetNowUTC -> <PWD> <NOW>
# - TransactionIDs (1o campo das requisicoes) -> <TID>
# - resposta do GET_SERVER_TIME (hora do servidor) -> <SRVTIME>/<SRVFLOAT>
# - pasta de destino do getmodule -> <DEST>
use strict; binmode STDOUT;
my ($c2s, $s2c, $dest) = @ARGV;
local $/;
open(my $f, '<:raw', $c2s) or die; my $c = <$f>; close $f;
open($f, '<:raw', $s2c) or die; my $s = <$f>; close $f;
my %tids = map { $_ => 1 } ($c =~ /\n[A-Z_]+ \x7f\x12\x14(\d{3,})\x12/g);
$c =~ s/(LOGIN \x7f\x12\x14[^\x12]*\x12)[^\x12]*\x12(\d+)\x12[^\x12\x14]*/$1<PWD>\x12$2\x12<NOW>/;
for my $tid (keys %tids) { $c =~ s/\b$tid\b/<TID>/g; $s =~ s/\b$tid\b/<TID>/g; }
my @r = split(/\r\n/, $s, -1);
if (@r > 1) {
  $r[1] =~ s/^(200 \x7f\x12\x14)[^\x12\x14]*/$1<SRVTIME>/;
  $r[1] =~ s/\d+[,.]\d+/<SRVFLOAT>/g;
}
$s = join("\r\n", @r);
if (defined $dest && $dest ne '') { s/\Q$dest\E/<DEST>/g for ($c, $s); }
print "=== C2S ===\n$c\n=== S2C ===\n$s\n";
