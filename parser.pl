#!/usr/bin/perl
use Cwd;				# gets current path

use constant PI	=> 4*atan2(1,1);

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
$mat_ops    = <FUNCFILE>;

while (<FUNCFILE>) {
    $hashSource .= $_;
}

close(FUNCFILE);
 
$int_ops    =~ s/\s//g;
$float_ops  =~ s/\s//g;
$imm_ops    =~ s/\s//g;
$mat_ops    =~ s/\s//g;

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
	next;
    }   
   
    if ($func =~ m/$imm_ops/g) {
	$inst |= shift(@argarray) << 8;
    }
    printf ("%08X\n", $inst);  

    if ($func =~ m/glRotate/g) {
	
	$angle = $argarray[0];
	$x = $argarray[1];
	$y = $argarray[2];
	$z = $argarray[3];

	$mag = sqrt($x**2 + $y**2 + $z**2);

	$x = abs($x/$mag);
	$y = abs($y/$mag);
	$z = abs($z/$mag);

	$c = cos($angle*PI/180);
	$s = sin($angle*PI/180);

	$argarray[0] = $x**2*(1-$c)+$c;
	$argarray[1] = $x*$y*(1-$c)-$z*$s;
	$argarray[2] = $x*$z*(1-$c)+$y*$s;
        $argarray[3] = 0;
	$argarray[4] = $y*$x*(1-$c)+$z*$s;
	$argarray[5] = $y**2*(1-$c)+$c;
	$argarray[6] = $y*$z*(1-$c)-$x*$s;
	$argarray[7] = 0;
	$argarray[8] = $x*$z*(1-$c)-$y*$s;
	$argarray[9] = $y*$z*(1-$c)+$x*$s;
	$argarray[10] = $z**2*(1-$c)+$c;
	$argarray[11] = 0;
	$argarray[12] = 0;
	$argarray[13] = 0;
	$argarray[14] = 0;
	$argarray[15] = 1;
	
	for ($i = 0; $i < 4; $i++) {
	    for ($j = 0; $j < 4; $j++) {
		print qx(echo $argarray[$j*4+$i] | ./fp_hax) . "\n";
	    }
	}
    }	
    elsif ($func =~ m/glTranslate/g) {
	
	$x = $argarray[0];
	$y = $argarray[1];
	$z = $argarray[2];


	$argarray[0] = 1;
	$argarray[1] = 0;
	$argarray[2] = 0;
	$argarray[3] = $x;
	$argarray[4] = 0;
	$argarray[5] = 1;
	$argarray[6] = 0;
	$argarray[7] = $y;
	$argarray[8] = 0;
	$argarray[9] = 0;
	$argarray[10] = 1;
	$argarray[11] = $z;
	$argarray[12] = 0;
	$argarray[13] = 0;
	$argarray[14] = 0;
	$argarray[15] = 1;
	
	for ($i = 0; $i < 4; $i++) {
	    for ($j = 0; $j < 4; $j++) {
		print qx(echo $argarray[$j*4+$i] | ./fp_hax) . "\n";
	    }
	}
    }
    elsif ($func =~ m/glScale/g) {
	
	$x = $argarray[0];
	$y = $argarray[1];
	$z = $argarray[2];


	$argarray[0] = $x;
	$argarray[1] = 0;
	$argarray[2] = 0;
	$argarray[3] = 0;
	$argarray[4] = 0;
	$argarray[5] = $y;
	$argarray[6] = 0;
	$argarray[7] = 0;
	$argarray[8] = 0;
	$argarray[9] = 0;
	$argarray[10] = $z;
	$argarray[11] = 0;
	$argarray[12] = 0;
	$argarray[13] = 0;
	$argarray[14] = 0;
	$argarray[15] = 1;
	
	for ($i = 0; $i < 4; $i++) {
	    for ($j = 0; $j < 4; $j++) {
		print qx(echo $argarray[$j*4+$i] | ./fp_hax) . "\n";
	    }
	}
    }
    elsif ($func =~ m/glViewport/g) {

	$argarray[0] = $x    

    }
    elsif ($func =~ m/$mat_ops/g) {
	for ($i = 0; $i < 4; $i++) {
	    for ($j = 0; $j < 4; $j++) {
		print qx(echo $argarray[$j*4+$i] | ./fp_hax) . "\n";
	    }
	}
    } 
    elsif ($func =~ m/$float_ops/g) {
	foreach $x (@argarray) {
	    print qx(echo $x | ./fp_hax) . "\n";
	}
    }
    elsif ($func =~ m/$int_ops/g) {
  	foreach $x (@argarray) {
	    printf "%08X\n", $x;
	}
    }
}


