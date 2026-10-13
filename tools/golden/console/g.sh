#!/bin/bash
# uso: JVCS_USER=... JVCS_PASS=... GOLDEN_DIR=<pasta> g.sh nome "comando..."  -> roda original e novo, compara saidas (sem a 1a linha do banner)
G=${GOLDEN_DIR:-$(pwd)}
NEW=/d/Delphi/JediVCS/v2026/bin/client/Win32/jvcs.exe
ORIG="/c/Program Files (x86)/JEDI/JVCS/jvcs.exe"
: "${JVCS_USER:?defina JVCS_USER}" "${JVCS_PASS:?defina JVCS_PASS (servidor de teste)}"
n=$1; shift
cd $G
timeout 120 "$ORIG" 127.0.0.1:2106 -user "$JVCS_USER" -password "$JVCS_PASS" "$@" > orig_$n.txt 2>&1; ro=$?
timeout 120 "$NEW" 127.0.0.1:2106 -user "$JVCS_USER" -password "$JVCS_PASS" "$@" > new_$n.txt 2>&1; rn=$?
tail -n +2 orig_$n.txt > orig_$n.body; tail -n +2 new_$n.txt > new_$n.body
if cmp -s orig_$n.body new_$n.body; then r=IGUAL; else r=DIFERENTE; fi
echo "[$n] exit orig=$ro novo=$rn  corpo: $r  ($(wc -c < orig_$n.body) / $(wc -c < new_$n.body) bytes)"
echo "  banner orig: $(head -1 orig_$n.txt)"; echo "  banner novo: $(head -1 new_$n.txt)"
[ $r = DIFERENTE ] && diff orig_$n.body new_$n.body | head -30
true
