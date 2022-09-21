#!/usr/bin/perl

use strict;

#open IN,$ARGV[0] or die "File with species not found\n";

open IN,$ARGV[0] or die "File with species names not found\n";

my @species;

my @l;

while(<IN>){
	chomp;
	next if(/^\s*$/);
	@l=split();
	push(@species,$l[0]);
}
close IN;

my @l;
my %size;

open IN,$ARGV[1] or die "No file with chrominfo given\n";
while(<IN>){
	@l=split();
	next if(/\#/);
	$size{$l[0]} = $l[1];
}
close IN;

my $chr=$ARGV[2] or die "chromosome file not found\n";

my $limit=$ARGV[3] or die "No file with max number of files given\n";

my $seq;

open IN,$ARGV[4] or die "No file with bridged maf given\n";


my ($id,$start,$len,$stop);

my %bridge=();
while(<IN>){
	chomp;
	if(/>$species[0].chr\w+\S\S\S:(\d+)-(\d+)/){
		$id=$species[0];
		$start=$1;
		$stop=$2;
		$len=$stop-$start;
		$bridge{$start}{'len'}=$len;
		$bridge{$start}{'end'}=$stop;
	}elsif(/>(\S+)/){
		$id=$1;
	}elsif(/\S/){
		$bridge{$start}{$id}=$_;
	}
}
close IN;


open OUT,">fused.maf.stitched" or die "could not create outfile\n";

my $tmpseq='';

my $last;
my $first;

foreach my $s(@species){
	$seq='';
	$last='';
	$first='';
	
	for(my $i=1;$i<=$limit;$i++){
		open IN,"$chr.maf.$i.stitched" or die "File $chr.maf.$i.stitched could not be opened: $!\n";
#		if($s eq $species[0] and $i ==1){
#			print OUT ">$s.$chr(+):0-91744696\n";
#		}elsif($i==1){
#			print OUT ">$s\n";
#		}
		while(<IN>){
			chomp;
			if(/>$species[0].chr\w+\S\S\S:\d+-(\d+)/){
				$last=$1;
			}
			if(/>$species[0].chr\w+\S\S\S:(\d+)-\d+/ and $i == 1){
				$first=$1;
			}
			
			if(/>$s/){
				$seq.=<IN>;
				chomp $seq;
				last;
			}
		}
		close IN;
	}
	print STDERR "$s\n";

	## replace in sequece when necessary
	for my $pos(sort {$a<=>$b} keys  %bridge){
		for(my $i=$pos;$i<$bridge{$pos}{'end'};$i++){				
			if(substr($seq,$i,1) eq '-'){
				substr($seq,$i,1,substr($bridge{$pos}{$s},$i-$pos,1));
			}
		}
	}
	

	if($s eq $species[0]){
		print OUT ">$s.$chr(+):$first-$last\n";
	}else{
		print OUT ">$s\n";
	}
	print OUT "$seq\n";
}
close OUT;
