#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Iterator::FastaDb;
use Iterator::FastqDb;

my $usage=<<'ENDHERE';
NAME:
linkPoplarArabidopsis.pl

PURPOSE:

INPUT:
--infile <string>    : Diff. exp file
--reference <string> : Reference file [3] = Potri. [10] = AT.
				
OUTPUT:
STDOUT

NOTES:

BUGS/LIMITATIONS:
 
AUTHOR/SUPPORT:
Julien Tremblay - julien.tremblay@mail.mcgill.ca

ENDHERE

## OPTIONS
my ($help, $infile, $reference);
my $verbose = 0;

GetOptions(
    'infile=s' 	  => \$infile,
	'reference=s' => \$reference,
    'verbose' 	  => \$verbose,
    'help' 		  => \$help
);
if ($help) { print $usage; exit; }

## MAIN
die "--infile arg missing\n" unless($infile);
die "--reference arg missing\n" unless($reference);

my %hash;
open(IN, '<'.$reference) or die "Can't open $reference\n";
while(<IN>){
	chomp;

	my($value1, $value2, $value3);

	my @row = split(/\t/, $_);
	if(defined $row[10]){
		$value1 = $row[10]
	}else{
		$value1 = "NA";
	}
	if(defined $row[11]){
		$value2 = $row[11]
	}else{
		$value2 = "NA";
	}
	if(defined $row[12]){
		$value3 = $row[12]
	}else{
		$value3 = "NA";
	}
	#(defined($row[10])) ? $value1 = $row[10] : $value1 = "NA";
	#(defined($row[11]) )? $value2 = $row[11] : $value2 = "NA";
	#(defined($row[12])) ? $value3 = $row[12] : $value3 = "NA";
	$hash{$row[1]} = "$value1\t$value2\t$value3";
}
close(IN);


open(IN, '<'.$infile) or die "Can't open $infile\n";
while(<IN>){
	chomp;
	if($. == 1){
		print STDOUT "AT.ID\t".$_."\n";
		next;
	}
	my @row = split(/\t/, $_);
	
	#print STDOUT "$row[3]\n";

	if(exists $hash{$row[0]}){
		if(defined($hash{$row[0]})){
			print STDOUT $hash{$row[0]}."\t".$_."\n";

		}else{
			print STDOUT "NA\t".$_."\n";

		}
	}else{
		print STDOUT "NA\t".$_."\n";
	}

}
close(IN);

