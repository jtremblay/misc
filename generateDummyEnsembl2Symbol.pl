#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Iterator::FastaDb;
use Iterator::FastqDb;

my $usage=<<'ENDHERE';
NAME:
extractUniprot.pl

PURPOSE:

INPUT:
--infile <string> : tab file having all 6 char uniprot ID 
                            in the 4th column.

OUTPUT:
STDOUT            : Dummy file having geneID\tgeneID\n

NOTES:

BUGS/LIMITATIONS:
 
AUTHOR/SUPPORT:
Julien Tremblay - julien.tremblay@mail.mcgill.ca

ENDHERE

## OPTIONS
my ($help, $infile_uniprot, $infile_embl);
my $verbose = 0;

GetOptions(
    'infile_uniprot=s' 	=> \$infile,
    'verbose' 			=> \$verbose,
    'help' 				=> \$help
);
if ($help) { print $usage; exit; }

## MAIN
die "--infile arg missing...\n" unless($infile);

open(UNIPROT, '<'.$infile) or die "Can't open file $infile\n";

while(<UNIPROT>){
	chomp;
	my @row = split(/\t/, $_);
	
}
close(UNIPROT);
exit;
