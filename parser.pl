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
   
    if ($func =~ m/$imm_ops/) {
	$inst |= shift(@argarray) << 8;
    }
    printf ("%08X\n", $inst);  

    if ($func =~ m/glRotate/) {
	
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
    elsif ($func =~ m/glTranslate/) {
	
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
    elsif ($func =~ m/glScale/) {
	
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
    elsif ($func =~ m/glFrustum/) {
   	
	$left = $argarray[0];
	$right = $argarray[1];
	$bottom = $argarray[2];
	$top = $argarray[3];
	$zNear = $argarray[4];
	$zFar = $argarray[5];
		
	$argarray[0] = (2*$zNear)/($right-$left);
	$argarray[1] = 0;
	$argarray[2] = ($right+$left)/($right-$left);	
	$argarray[3] = 0;
	$argarray[4] = 0;
	$argarray[5] = (2*$zNear)/($top-$bottom);
	$argarray[6] = ($top+$bottom)/($top-$bottom);
	$argarray[7] = 0;
	$argarray[8] = 0;
	$argarray[9] = 0;
	$argarray[10] = -1*(($zFar+$zNear)/($zFar-$zNear));
	$argarray[11] = (-2*$zFar*$zNear)/($zFar-$zNear);	
	$argarray[12] = 0;
	$argarray[13] = 0;
	$argarray[14] = -1;
	$argarray[15] = 0;	

	for ($i = 0; $i < 4; $i++) {
	    for ($j = 0; $j < 4; $j++) {
		print qx(echo $argarray[$j*4+$i] | ./fp_hax) . "\n";
	    }
	}
    }
    elsif ($func =~ m/glOrtho/) {
	
	$left = $argarray[0];
	$right = $argarray[1];
	$bottom = $argarray[2];
	$top = $argarray[3];
	$zNear = $argarray[4];
	$zFar = $argarray[5];

	$argarray[0] = 2/($right-$left);
	$argarray[1] = 0;
	$argarray[2] = 0;
	$argarray[3] = -1*(($right+$left)/($right-$left));	
	$argarray[4] = 0;
	$argarray[5] = 2/($top-$bottom);
	$argarray[6] = 0;
	$argarray[7] = -1*(($top+$bottom)/($top-$bottom));
	$argarray[8] = 0;
	$argarray[9] = 0;
	$argarray[10] = -2/($zFar-$zNear);
	$argarray[11] = -1*(($zFar+$zNear)/($zFar-$zNear));	
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
    elsif ($func =~ m/glViewport/) {

	$x = $argarray[0];
	$y = $argarray[1];
	$width = $argarray[2];
	$height = $argarray[3];

	$argarray[0] = $x;
	$argarray[1] = $y;
	$argarray[2] = $width/2;
	$argarray[3] = $height/2;
		
	foreach $arg (@argarray) {
	    print qx(echo $arg | ./fp_hax) . "\n";
	}

    }
    elsif ($func =~ m/$mat_ops/) {
	for ($i = 0; $i < 4; $i++) {
	    for ($j = 0; $j < 4; $j++) {
		print qx(echo $argarray[$j*4+$i] | ./fp_hax) . "\n";
	    }
	}
    } 
    elsif ($func =~ m/$float_ops/) {
	foreach $x (@argarray) {
	    print qx(echo $x | ./fp_hax) . "\n";
	}
    }
    elsif ($func =~ m/$int_ops/) {
  	foreach $x (@argarray) {
	    printf "%08X\n", $x;
	}
    }
}


