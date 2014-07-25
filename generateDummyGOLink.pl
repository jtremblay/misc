#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;

my $usage=<<'ENDHERE';
NAME:
scriptName.pl

PURPOSE:

INPUT:
--infile <string> : GTF file
				
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
open(IN, "<".$infile) or die "Can't open file $infile\n";
while(<IN>){
	chomp;
	my @row = split(/\t/, $_);
	my $annotation = pop(@row);
	#print STDOUT $annotation."\n";

	my @el = split(/;/, $annotation);
	#my $geneId = $el[0];
	#my $geneName = $el[3];

	foreach my $el (@el){
		if($el =~ m/gene_id \"(.*)\"/){
			print STDOUT $1."\t";
		}
		if($el =~ m/gene_name \"(.*)\"/){
			print STDOUT $1."\n";
		}
	}
	
	#exit if($. == 20);
}
close(IN);




