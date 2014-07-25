#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;

my $usage=<<'ENDHERE';
NAME:
checkGTF.pl

PURPOSE:
Find inconsistencies in GTF file.

INPUT:
--infile <string> : Sequence file
				
OUTPUT:

NOTES:

BUGS/LIMITATIONS:
 
AUTHOR/SUPPORT:
Julien Tremblay - julien.tremblay@mail.mcgill.ca

ENDHERE

## OPTIONS
my ($help, $infile);
my $verbose = 0;

GetOptions(
    'infile=s' 	=> \$infile,
    'verbose' 	=> \$verbose,
    'help' 		=> \$help
);
if ($help) { print $usage; exit; }

## MAIN

open(IN, '<'.$infile) or die "Can't open file $infile\n";
while(<IN>){
	chomp;
	my @row = split(/\t/, $_);
	print STDOUT "Number of elements in row: ".@row."\n";
	my $lastEl = $row[8];
	print STDOUT "Last El: ".$lastEl."\n";

}
close(IN);
exit;


