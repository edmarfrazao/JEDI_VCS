# Proxy TCP de captura (somente teste local): 127.0.0.1:2107 -> 127.0.0.1:2106
# Grava cada sessao em <dir>\<prefixo>_<n>_c2s.bin e _s2c.bin
param([string]$Dir, [int]$ListenPort = 2107, [int]$TargetPort = 2106)
$src = @'
using System; using System.IO; using System.Net; using System.Net.Sockets; using System.Threading;
public static class CapProxy {
  public static string Dir; public static string Prefix = "sess"; static int n = 0;
  public static void Run(int lp, int tp) {
    var l = new TcpListener(IPAddress.Loopback, lp); l.Start();
    while (true) {
      var c = l.AcceptTcpClient(); int id = Interlocked.Increment(ref n);
      string pf = File.Exists(Path.Combine(Dir, "prefix.txt")) ? File.ReadAllText(Path.Combine(Dir, "prefix.txt")).Trim() : Prefix;
      var s = new TcpClient("127.0.0.1", tp);
      string b = Path.Combine(Dir, pf + "_" + id);
      Pump(c.GetStream(), s.GetStream(), b + "_c2s.bin", c, s);
      Pump(s.GetStream(), c.GetStream(), b + "_s2c.bin", c, s);
    }
  }
  static void Pump(NetworkStream a, NetworkStream z, string f, TcpClient c1, TcpClient c2) {
    var t = new Thread(() => {
      var buf = new byte[65536];
      using (var fs = new FileStream(f, FileMode.Create, FileAccess.Write, FileShare.Read)) {
        try { int r; while ((r = a.Read(buf, 0, buf.Length)) > 0) { fs.Write(buf, 0, r); fs.Flush(); z.Write(buf, 0, r); } } catch {}
      }
      try { c1.Close(); } catch {} try { c2.Close(); } catch {}
    }); t.IsBackground = true; t.Start();
  }
}
'@
Add-Type -TypeDefinition $src
[CapProxy]::Dir = $Dir
[CapProxy]::Run($ListenPort, $TargetPort)
