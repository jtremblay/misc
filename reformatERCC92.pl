#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Iterator::FastaDb;
use Iterator::FastqDb;

my $usage=<<'ENDHERE';
NAME:
reformatERCC92.pl

PURPOSE:

INPUT:
--infile_fasta <string> : Sequence file
--infile_gtf <string>   : gtf file
				
OUTPUT:
--outfile_fasta   : <string> 
--outfile_gtf   : <string> 

NOTES:

BUGS/LIMITATIONS:
 
AUTHOR/SUPPORT:
Julien Tremblay - julien.tremblay@mail.mcgill.ca

ENDHERE

## OPTIONS
my ($help, $infile_fasta, $infile_gtf, $outfile_fasta, $outfile_gtf);
my $verbose = 0;

GetOptions(
    'infile_fasta=s' 	=> \$infile_fasta,
    'infile_gtf=s' 		=> \$infile_gtf,
    'outfile_fasta=s' 	=> \$outfile_fasta,
    'outfile_gtf=s' 	=> \$outfile_gtf,
    'verbose' 			=> \$verbose,
    'help' 				=> \$help
);
if ($help) { print $usage; exit; }

## MAIN
open(OUT_FASTA, ">".$outfile_fasta) or die "Can't open $outfile_fasta\n";
open(OUT_GTF, ">".$outfile_gtf) or die "Can't open $outfile_gtf\n";

# First loop through gtf.
my %hash;
open(IN, $infile_gtf) or die "Can't open file ".$infile_gtf."\n";
while(<IN>){
	chomp;
	my @row = split(/\t/, $_);
	my $name = shift(@row);
	shift(@row);
	
	$hash{$name} = \@row;
}
close(IN);

my $ref_fasta_db = Iterator::FastaDb->new($infile_fasta) or die("Unable to open Fasta file, $infile_fasta\n");
my $start = 0;
my $end = 0;
my $finalSeq = "";
my $totalLength = 0;
my $currLength = 0;
while( my $curr = $ref_fasta_db->next_seq() ) {
	my $header = $curr->header;
	$header =~ s/>//;
	my $seq = $curr->seq;

	my $length = length($seq);
	
	$totalLength += $length;
	$currLength = $totalLength - $length + 1;
	$finalSeq .= $curr->seq;

	if(exists $hash{$header}){
		print OUT_GTF "chrERCC\tERCC92\texon\t";
		my @row = @{$hash{$header}};
		print OUT_GTF $currLength."\t".$totalLength."\t".$row[3]."\t".$row[4]."\t".$row[5]."\t".$row[6]."\n";
	}else{
		die "problem with sequence, at least one entry is present in gtf file but absent in fasta file.\n";
	}
}

print OUT_FASTA ">chrERCC\n";
my @array = split("", $finalSeq);
my $i=0;
foreach(@array){
	if(($i !=0) && ($i % 60 == 0)){
		print OUT_FASTA "\n".$_;
	}else{
		print OUT_FASTA $_;
	}
	$i++;
	
}
close(OUT_FASTA);
close(OUT_GTF);
