#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
#use Iterator::FastaDb;
#use Iterator::FastqDb;

my $usage=<<'ENDHERE';
NAME:
generateDummyEnsembl2Symbol2.pl

PURPOSE:

INPUT:
--infile <string> : gtf file

OUTPUT:
STDOUT            : Dummy file having geneID\tgeneID\n

NOTES:

BUGS/LIMITATIONS:
 
AUTHOR/SUPPORT:
Julien Tremblay - julien.tremblay@mail.mcgill.ca

ENDHERE

## OPTIONS
my ($help, $exprFile, $refGenes);
my $verbose = 0;

GetOptions(
    'exprFile=s'      	=> \$exprFile,
	'refGenes=s'		=> \$refGenes,
    'verbose' 			=> \$verbose,
    'help' 				=> \$help
);
if ($help) { print $usage; exit; }

## MAIN
#die "--infile arg missing...\n" unless($infile);

my %hash;

open(IN, '<'.$refGenes) or die "Can't open file $refGenes\n";

while(<IN>){
	chomp;
	my @row = split(/\t/, $_);
	$hash{$row[0]} = $row[1];
	
}
close(IN);

open(IN, '<'.$exprFile) or die "Can't open file $exprFile\n";

while(<IN>){
	chomp;
	my @row = split(/\t/, $_);
	if(exists $hash{$row[1]}){
		print STDOUT $row[1]."\t".$hash{$row[1]}."\n";
	}
	
}
close(IN);


exit;
