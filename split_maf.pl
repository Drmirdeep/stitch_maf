#!/usr/bin/perl

use strict;
use warnings;

my @l;

my $usage="Usage: $0  maf_file    refspec    number_of_chunks    chr     chromsizes_file\n";

my $file=$ARGV[0] or die "maf file not given\n$usage";
my $ref=$ARGV[1] or die "no ref species given\n$usage";
my $chunks=$ARGV[2] or die "No size specified\n$usage";
my $chr=$ARGV[3] or die "Chromosome not given\n$usage";

if(not -d $chr){
	mkdir $chr;
}
	

my %chrs;

my $bridge=10000;

my $chromsizesf=$ARGV[4] or die "Usage: $0  maf_file    refspec    number_of_chunks    chr     chromsizes_file\n";

open IN,$ARGV[4] or die "File with chromsizes not given\n";
while(<IN>){
	@l=split();
	$chrs{$l[0]} = $l[1];
}
close IN;




my $chunkssize=int($chrs{$chr}/$chunks);

my %fh;

open IN,$file or die "no maf file given\n";
my @FH;
#push(@FH,);
for(my $i=1;$i<=$chunks;$i++){
	open my $f,">$chr/$file.$i" or die "File $file.$i could not be opened\n";
	push(@FH,$f);
}

my %starts;

foreach my $f(@FH){
	print $f "##maf version=1 scoring=autoMZ.v1\n";
}


for (my $i=1;$i<=$chunks+1;$i++){
    $starts{$i*$chunkssize}=$i;
	if($i < $chunks+1){
		open OUT ,">$chr/$file.$i.bed" or die "Cannot create bed file for chunk x\n";
		if($i == $chunks+1){
			print OUT "$chr\t",($i-1)*$chunkssize,"\t",$chrs{$chr},"\tna$i\t.\t+\n";
		}else{
			print OUT "$chr\t",($i-1)*$chunkssize,"\t",$i*$chunkssize,"\tna$i\t.\t+\n";
		}
		close OUT;
		
		if($i<$chunks){
			my $name="$chr/$file.$i.bed_bridge${i}-".($i+1);
			print STDERR "$name\n";
			open OUT ,">$name" or die "Cannot create bed file for chunk x\n";
			print OUT "$chr\t",($i*$chunkssize)-$bridge,"\t",($i*$chunkssize)+$bridge,"\tna$i\t.\t+\n";
			close OUT;
		}
	}
}

my $ofi=0;
my $f;
my @out;

while(<IN>){
   if(/a score/){
       @out=(); 
    }  
    if(/$ref\S+\s*(\d+)/){
        $ofi=int($1/$chunkssize);
    }

    push(@out,$_);
    if(/^\s*$/){
        $f=$FH[$ofi];
        print { $f } @out;
    }
}
close IN;
foreach my $f(@FH){
    print $f "##eof maf";
    close $f;
}

