#!/bin/zsh
# --diff mode
if [[ ${1:-} == --diff ]]; then
	A=${2:?usage: log-summary.sh --diff A B}; B=${3:?usage: log-summary.sh --diff A B}
	feat() { # movies / mdiag areas / fatal kinds, one "kind: value" per line
		grep -a 'Loading movie' $1 | sed -E "s/^@+ *Loading movie '([^']*)'.*/movie: \1/"
		grep -a 'MDIAG [0-9]* [a-z]*:' $1 | sed -E 's/.*MDIAG [0-9]+ ([a-z]+):.*/area: \1/'
		grep -aE 'Debugger started|Assertion failed|Uncaught Lingo error|no me object|Could not evaluate|Unhandled exception|Call to undefined handler' $1 | sed -E 's/0x[0-9a-f]+/H/g; s/[0-9]+/N/g' | cut -c1-100 | sed 's/^/fatal: /'
	}
	feat $A | sort | uniq -c | awk '{c=$1; $1=""; print substr($0,2) "\t" c}' | sort > ${TMPDIR:-/tmp}/ls-a.$$
	feat $B | sort | uniq -c | awk '{c=$1; $1=""; print substr($0,2) "\t" c}' | sort > ${TMPDIR:-/tmp}/ls-b.$$
	echo "== diff A=$A ($(grep -ac '' $A) lines)  B=$B ($(grep -ac '' $B) lines)"
	awk -F'\t' 'NR==FNR{a[$1]=$2; next} {b[$1]=$2} END{
		for(k in b) if(!(k in a)) print "NEW  " k " x" b[k];
		for(k in a) if(!(k in b)) print "GONE " k " x" a[k];
		for(k in a) if((k in b) && k ~ /^area:/ && a[k]!=b[k]) print "AREA " k "  " a[k] " -> " b[k] }' ${TMPDIR:-/tmp}/ls-a.$$ ${TMPDIR:-/tmp}/ls-b.$$ | sort | cut -c1-120 | head -30
	rm -f ${TMPDIR:-/tmp}/ls-a.$$ ${TMPDIR:-/tmp}/ls-b.$$
	exit
fi
# Compact (<60 lines) report on a ScummVM Lingo trace log, so nobody has to grep a multi-GB log.
# Usage: tools/log-summary.sh [logfile] | --diff A B   (default build/run.log)
# Reports: size, movies in load order, first fatal error + preceding unique call-stack frames,
# counts of distinct WARNING types, STUB/Unimplemented features. Read-only.
P=${0:A:h:h}
LOG=${1:-$P/build/run.log}
[[ -f $LOG ]] || { echo "no such log: $LOG"; exit 1; }
FATAL='Debugger started|Assertion failed|Uncaught Lingo error|Lingo error|no me object|Could not evaluate|Unhandled exception'

echo "== $LOG: $(du -h $LOG | cut -f1), $(grep -ac '' $LOG) lines"

echo "== movies loaded (in order)"
grep -a 'Loading movie' $LOG | sed -E "s/^@+ *Loading movie '([^']*)'.*/\1/" | awk '!s[$0]++{printf "%s ", $0} END{print ""}' | fold -w 100 -s

N=$(grep -anE "$FATAL" $LOG | head -1 | cut -d: -f1)
if [[ -n $N ]]; then
	echo "== FIRST FATAL at line $N"
	sed -n "${N}p" $LOG | cut -c1-200
	echo "-- last movie before it: $(head -n $N $LOG | grep -a 'Loading movie' | tail -1 | sed -E "s/^@+ *//" | cut -c1-80)"
	echo "-- ~15 unique call frames / messages before it (oldest first, dedup'd)"
	S=$(( N > 3000 ? N - 3000 : 1 ))
	sed -n "${S},$((N-1))p" $LOG | grep -aE '^#[0-9]+ |Lingo error|WARNING|Incorrect number|Call to undefined|no me' \
		| sed -E 's/^#[0-9]+ //' | cut -c1-110 | awk '!s[$0]++' | tail -15
else
	echo "== no fatal error found"
fi

echo "== WARNING types (count, numbers masked)"
grep -a '^WARNING' $LOG | grep -av 'Detection entry\|CloudIcon' | sed -E 's/0x[0-9a-f]+/H/g; s/[0-9]+/N/g' | cut -c1-110 \
	| sort | uniq -c | sort -rn | head -12

echo "== STUB / Unimplemented (count, numbers masked)"
grep -aE 'STUB|Unimplemented|unimplemented|Unhandled kParent' $LOG | sed -E 's/^WARNING: //; s/0x[0-9a-f]+/H/g; s/[0-9]+/N/g' | cut -c1-110 \
	| sort | uniq -c | sort -rn | head -10

echo "== lingo-level notes"
echo "undefined globals: $(grep -a 'global variable .* not defined' $LOG | sed -E 's/.*variable (.*) not defined/\1/' | sort | uniq -c | sort -rn | head -5 | awk '{printf "%s(%s) ",$2,$1}')"

echo "== MDIAG lines per area (patch 0030)"
grep -a 'MDIAG [0-9]* [a-z]*:' $LOG | sed -E 's/.*MDIAG [0-9]+ ([a-z]+):.*/\1/' | sort | uniq -c | sort -rn | awk '{printf "%s(%s) ",$2,$1} END{print ""}'
echo "== last 15 MDIAG lines before the first fatal (or end of log)"
grep -an 'MDIAG [0-9]* [a-z]*:' $LOG | awk -F: -v n=${N:-999999999} '$1<n' | tail -15 | sed -E 's/^([0-9]+):.*MDIAG /\1 /' | cut -c1-200
