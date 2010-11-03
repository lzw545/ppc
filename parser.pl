#!/usr/bin/perl
use Cwd;				# gets current path

my $dir	      = cwd;			# get current working directory
my $inFile    = $dir."/$ARGV[0]";	# input file on cmd line
my $funcFile  = $dir.'/func.txt';	# ISA defines in 'func.txt'

open(INFILE, $inFile) || die ("failed to open file: $inFile: $!\n");

while (<INFILE>) {
    $source .= $_;
}

close(INFILE);

$source =~ s#/\*[^*]*\*+([^/*][^*]*\*+)*/|("(\\.|[^"\\])*"|'(\\.|[^'\\])*'|.[^/"'\\]*)#defined $2 ? $2 : ""#gse;

open(FUNCFILE, $funcFile) || die ("failed to open file: $funcFile: $!\n");

$int_ops    = <FUNCFILE>;
$float_ops  = <FUNCFILE>;
$imm_ops    = <FUNCFILE>;

while (<FUNCFILE>) {
    $hashSource .= $_;
}

close(FUNCFILE);

$int_ops    =~ s/\s//g;
$float_ops  =~ s/\s//g;
$imm_ops    =~ s/\s//g;

%func_hash  = ();

while ($hashSource =~ m/(gl.*[^\s])\s+(0x.*)\n/g) {
    $func_hash{$1} = hex $2;
}

while ($source =~ m/(gl.[^\(]*)\(\s*([^;]*)\);/sg) {
    $func = $1;
    $args = $2;
   
    $func =~ s/\s//g;
    $args =~ s/[\n\s]//g;
    $args =~ s/f,/,/g; 
    @argarray = split(",", $args); 

    $inst = $func_hash{$func};
  
    if ($inst == 0) {
	print "$func instruction does not exist in ISA!\n";
    }   
    
    if ($func =~ m/$imm_ops/g) {
	$inst |= shift(@argarray) << 8;
    }
  
    printf ("%08X\n", $inst);  
    if ($func =~ m/$float_ops/g) {
	foreach $x (@argarray) {
	    print qx(echo $x | ./fp_hax) . "\n";
	}
    }
    elsif ($func =~ m/$int_ops/g) {
  	foreach $x (@argarray) {
	    printf "%08X\n", $x;
	}
    }
    #print "---------$func----------@argarray----------------\n";
}


