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
my ($help, $infile);
my $verbose = 0;

GetOptions(
    'infile_uniprot=s' 	=> \$infile,
    'verbose' 			=> \$verbose,
    'help' 				=> \$help
);
if ($help) { print $usage; exit; }

## MAIN
die "--infile arg missing...\n" unless($infile);

open(IN, '<'.$infile) or die "Can't open file $infile\n";
my %hash;
while(<IN>){
	chomp;
	if($_ =~ m/gene_id "(\S+)";/){
		$hash{$1} = $1;
		#print STDOUT $1."\t".$1."\n";
	}	
}
close(IN);

for my $key (sort{$a cmp $b} keys %hash){
	print STDOUT $key."\t".$hash{$key}."\n";
}

exit;
