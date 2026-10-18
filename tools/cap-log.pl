#!/usr/bin/perl
# Cap a log stream without stopping the writer: keep the first HEAD bytes,
# then a rolling buffer of the last TAIL lines, written out at EOF.
# Usage: cmd | cap-log.pl OUTFILE [HEAD_BYTES] [TAIL_LINES]
use strict; use warnings;
my ($out, $head, $tail) = (@ARGV, 50_000_000, 200_000)[0, 1, 2];
$head //= 50_000_000; $tail //= 200_000;
open(my $fh, '>', $out) or die "$out: $!";
my ($n, $dropped, $keep, @ring) = (0, 0, 0);
while (my $line = <STDIN>) {
	if ($n < $head) { print $fh $line; $n += length $line; next; }
	# diagnostics and movie loads survive the cap (the middle of long sessions)
	# and a few lines after each error, so its Lingo stack survives too
	if ($line =~ /MDIAG|Loading movie/) { print $fh $line; $keep = 6 if $line =~ /MDIAG \d+ error:/; next; }
	if ($keep > 0) { print $fh $line; $keep--; next; }
	push @ring, $line;
	if (@ring > $tail) { shift @ring; $dropped++; }
}
print $fh "\n[cap-log: dropped $dropped lines]\n" if $dropped;
print $fh @ring;
close $fh;
