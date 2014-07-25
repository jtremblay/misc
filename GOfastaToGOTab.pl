#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Iterator::FastaDb;
use Iterator::FastqDb;
use Data::Dumper;

my $usage=<<'ENDHERE';
NAME:
scriptName.pl

PURPOSE:
Take fasta protein file from go_20140405-seqdb.fasta.gz and generate a tab file
Containing only GO and category.

INPUT:
--infile <string> : Sequence file
				
OUTPUT:
STDOUT

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
    'help' 		  => \$help
);
if ($help) { print $usage; exit; }

## MAIN
my %hash;
#my $ref_fastq_db = Iterator::FastqDb->new($infile) or die("Unable to open Fastq file, $infile\n");
my $ref_fasta_db = Iterator::FastaDb->new($infile) or die("Unable to open Fasta file, $infile\n");
while( my $curr = $ref_fasta_db->next_seq() ) {

  my $id;
  my $symbol;
  my $GO;
  my $desc;
    

  my $header = $curr->header();
  if($header =~ m/^>(\S+) /){
    $id = $1;
  }else{
    die "did not find \"header id\" key word...\n";
  }
  $hash{$id}{'2GO'} = "";
  $hash{$id}{'3desc'} = "";

  if($header =~ m/symbol:(\S+) /){
    $symbol = $1;
  }else{
    die "did not find \"symbol\" key word...\n";
  } 
  
  my @row = split(/\]/, $header);
  foreach(@row){
    if($_ =~ m/(GO:\S+) /){
      $GO = $1;
      $GO =~ s/GO:GO:/GO:/;
    }else{
     warn "did not find \"GO\" key word... at line $.\n";
    } 

    if($_ =~ m/GO:\S+ (".*")/){
      $desc = $1;
    }else{
      warn "did not find \"GO\" and description key words... at line $.\n";
    }

    $hash{$id}{'1symbol'} = $symbol;
    $hash{$id}{'3desc'} .= "$desc;";
    $hash{$id}{'2GO'} .= "$GO;";
  }
}

#print Dumper(\%hash);
for my $k1 (sort keys %hash) {
  for my $k2 (sort keys %{ $hash{$k1} }){
    print STDOUT $hash{$k1}{$k2}."\t";
  }
  print STDOUT "\n";
}


