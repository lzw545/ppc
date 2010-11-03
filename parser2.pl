#!/usr/bin/perl
use Cwd;
 
my $dir = cwd;
my $inFile  = $dir."/$ARGV[0]";

open(INFILE, $inFile) || die ("failed to open file: $inFile: $!\n");

while (<INFILE>) {
    $source .= $_;
}

@new_source = split('\n', $source);

foreach $x (@new_source) {
    print pack 'H*', $x; 
}

