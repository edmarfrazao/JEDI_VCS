# extrai blobs (#127 T 1 ...) de uma captura e mostra o cabecalho ZIP local + central
use strict; local $/; open(my $f,'<:raw',$ARGV[0]) or die; my $d=<$f>; my $out=$ARGV[1];
my $n=0;
while ($d =~ /\x7fT1((?:[^\x12\x14\x7f]|\x7f.)*)/gs) {
  my $e=$1; my %m=('F'=>"\x12",'R'=>"\x14",'C'=>"\r",'L'=>"\n",'N'=>"\0","\x7f"=>"\x7f");
  $e =~ s/\x7f(.)/$m{$1}/gs; $n++;
  if ($out) { open(my $o,'>:raw',"$out$n.zip"); print $o $e; close $o; }
  my ($sig,$ver,$flag,$meth,$time,$date,$crc,$csz,$usz,$fnl,$exl)=unpack('VvvvvvVVVvv',$e);
  my $fn=substr($e,30,$fnl); my $ex=substr($e,30+$fnl,$exl);
  my $h=$time>>11; my $mi=($time>>5)&63; my $s=($time&31)*2; my $y=($date>>9)+1980; my $mo=($date>>5)&15; my $dd=$date&31;
  printf "blob %d: %d bytes sig=%08X ver=%d flag=%04X meth=%d dos=%04d-%02d-%02d %02d:%02d:%02d crc=%08X csz=%d usz=%d nome=%s extra=%s\n", $n, length($e), $sig,$ver,$flag,$meth,$y,$mo,$dd,$h,$mi,$s,$crc,$csz,$usz,$fn, unpack('H*',$ex);
  if ($e =~ /PK\x01\x02(.{42})/s) { my ($vm,$vn,$fl,$me,$t,$dt,$c2,$cs,$us,$fl2,$el,$cl,$dn,$ia,$ea)=unpack('vvvvvvVVVvvvvvV',$1); printf "   central: made=%04X need=%d flag=%04X extl=%d ext_attr=%08X intattr=%d\n",$vm,$vn,$fl,$el,$ea,$ia; }
}
