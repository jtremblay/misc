#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use IO::File;
use Env qw/TMPDIR/;
use Iterator::FastaDb;
use Iterator::FastqDb;
use Parallel::ForkManager;
use File::Temp;
use Cache::FastMmap;
use File::Basename;

$SIG{INT} = sub{exit}; #Handle ungraceful exits with CTRL-C.

my $usage=<<'ENDHERE';
NAME:
jgi_itaggerQscoreSheets.pl

PURPOSE:
This script generates Qscore sheets using fastx_quality_stats tool. 

INPUT:
--fastq <fastq>      :  Illumina fastq library in one file
                        Can be multiple fastqs.
--num_threads <int>  :  Number of threads. Default=1.
--phred <int>        :  Can be 33 or 64. Default 33. 

OUTPUT:
--outfile <outfile>    :  outfile having all qscores in separate files

NOTES:
Barcodes with a single base error will be corrected in the sequence header; 
all barcodes will be made uppercase

BUGS/LIMITATIONS:
Ambiguous nucleotides or multiple sequences per label are not supported

AUTHOR/SUPPORT:
Julien Tremblay - julien.tremblay@mail.mcgill.ca
Quality scores by fastx_quality_stats (FastX toolkit)
ENDHERE

## OPTIONS
my ($help, @fastq, $num_threads, $outfile, $phred);
my $verbose = 0;

## EXTERNAL TOOLS

my $qscore_tool = `which fastx_quality_stats`;

chomp $qscore_tool;
die "fastx_quality_stats executable not found!\n" unless $qscore_tool;

GetOptions(
    'fastq=s'		=> \@fastq,
	'outfile=s' 		=> \$outfile,
	'phred=i' 		=> \$phred,
	'num_threads=i' => \$num_threads,
    'verbose' 		=> \$verbose,
    'help' 			=> \$help,
	'debug' 		=> \$verbose
);
if ($help) { print $usage; exit; }

#VALIDATION
die("--phred provide a phred value (either 33 or 64)\n") unless $phred;
die("--fastq provide at least one fastq file\n") if @fastq == 0;
die("--outfile arg missing\n") unless $outfile;
$num_threads = 1 unless($num_threads);

my $tmpdir = $TMPDIR;
	
open(OUT_Q, ">".$outfile) or die "Can't open file ".$outfile."\n";
# Loop through all sequences and generate Qscore sheets.

# Create a hash using shared memory, because each
# Child has its own memory and "dies" outside of
# ForkManager.
my $index=0;
my $Cache = Cache::FastMmap->new();
$Cache->set('Qfiles', "");	
$Cache->set('IDs', "");	

##======== Parallel::ForkManager starts here ========##
my $pm = new Parallel::ForkManager($num_threads);
foreach(@fastq){
	$index++;
	my $pid = $pm->start($index) and next;
	print STDOUT "Executing Fork process ".$index." of ".$num_threads." threads\n" if($verbose);

	print STDOUT "Processing file \t".$_."\n" if($verbose);
	$pm->finish($index) if($_ =~ /^\.$/);
	$pm->finish($index) if($_ =~ /^\.\.$/);
	
	# Break if file don't exists or is empty
	if(! -e $_){
		print STDERR "File does not exists. ".$_."\n" if($verbose);
		$pm->finish($index); #replaces next in a ForkManager loop.
	}
	if(! -s $_){
		print STDERR "File is empty. ".$_."\n" if($verbose);
		$pm->finish($index);
	}
	
	my $id = basename($_);
	$id =~ s/\.fastq//;
	$id =~ s/\.fq//;
	#$content_qscores .= ">>".$id."\n";
	print ">>".$id."\n" if $verbose;
	
	# Run qscore command, add output to a variable and finally print the content of that variable to a file.
	print STDERR "Calculate qscores\n" if($verbose);
	print STDERR "Tempdirqscoresubstring:\t".$id."\n" if($verbose);
	system($qscore_tool." -Q ".$phred." -i ".$_." -o ".$tmpdir."/".$id."_qscore.tab");
	$? != 0 ? die "command failed: $!\n" : print STDERR "Succesfuly computed Qscores...\n" if($verbose);

	# Put file names and sample id in memory.
	my $file_string = $Cache->get('Qscore');
	my $id_string = $Cache->get('IDs');
	$Cache->set('Qscore', $file_string .= $tmpdir."/".$id."_qscore.tab;");
	$Cache->set('IDs', $id_string .= $id.";");
	
	# Terminate ForkManager
	$pm->finish($index);
}
print STDOUT (scalar localtime), " Waiting for some child process to finish.\n" if($verbose);
$pm->wait_all_children;
##======== Parallel::ForkManager ends here ========##
my @Qfiles;
my @IDs;
if(defined($Cache->get('Qscore'))){
	@Qfiles = split(/;/, $Cache->get('Qscore') );
	@IDs = split(/;/, $Cache->get('IDs') );
}

#CREATE FILES FOR MULTIPLE OUTPUT OPTION
my $content_qscores = "";
foreach my $file (@Qfiles){
	my $id = shift(@IDs);
	
	print STDOUT $id."\t".$file."\n" if($verbose);
	$content_qscores .= ">>".$id."\n";	

	open FH, '<'.$file or die "Can't open file ".$file."\n";
	my @lines = <FH>;
	foreach my $line (@lines){
		chomp($line);
		$content_qscores .= $line."\n";
	}
	$content_qscores .= "//\n";
	close(FH);
	#close $a_fh if($separate == 1);
}
print OUT_Q $content_qscores;
close(OUT_Q);

exit;

## REMOVE TEMP FILES
sub END{
	#system("rm ".$tmpdir." -rf");
}
