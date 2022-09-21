#!/usr/bin/perl 

use strict;

#use Storable;

#$hashref = retrieve('file');


open IN,$ARGV[0] or die "no maf block file given\n";

my $refspec=$ARGV[1] or die "no refspec given\n";

my $i=0;
my $posref;

my %h=();

my ($pos,$len,$posref,$strand,$sizeChr,$posinref) = (0,0,0,0,0);
my @seq=();
my @l;
my $spec;
my $chr;
my %tmp=();

my @species;

print "#spec\tpos\tgaps\tins\n";
while(<IN>){
	@l=split();
	if($l[0] eq 's'){ ## next if we dont have a sequence
	($spec,$chr) = split(/\./,$l[1]);
	if($spec eq $refspec){
		$pos = $l[2];
		$len=$l[3];
		$posref=$pos;
		%tmp=();
	}


	$strand=$l[4];
	$sizeChr=$l[5];
	@seq=split("",$l[6]);
	
	$posinref=$posref;
	
	for($i=0;$i< scalar @seq;$i++){
		
		## here we count the insertions in other species than our ref species so we know that here are deletions in elegans maybe
		if($spec eq $refspec){
			if($seq[$i] ne '-'){ 		
				$posinref++;
			}else{
				$tmp{$i}=1; ## set a gap mark in this hash so for next species we know were the gap is
				$h{$spec}{$posinref}{'gaps'}++;
			}


		}else{  ## now we are not in refspecies
			if($seq[$i] ne '-'){             ## if we have a letter here
				if($tmp{$i}){ ## if we have a gap in the refspecies this is an insertion in this species
					$h{$spec}{$posinref}{'ins'}++;
				}else{ ## also no gap in ref so we continue
					$posinref++;
				}
			}else{ ## so now we have a gap in sequence and need to check if it is also in reference or a deletion in our current species
				if($tmp{$i}){ ## same gap in reference
					
				}else{ ## no gap in reference but in current species
					$h{$spec}{$posinref}{'gaps'}++;
					$posinref++;
				}


			}
		}
	}
	}
    ## this means we either have an insertion directly before the block or afterwards before is I 5 C 0, after would look like C 0 I 5
    if($l[0] eq 'i'){
		if($l[2] eq 'I'){
			($spec,$chr) = split(/\./,$l[1]);
			$h{$spec}{$posref}{'ins'}+=$l[3];
			 $h{$refspec}{$posref}{'gaps'} = $l[3] if($l[3] > $h{$refspec}{$posref}{'gaps'});
	}
	}
	
	
	if(/^\s*$/){
		@species=keys %h;
		#print "#spec\tpos\tgaps\tins\n";
		foreach my $s(@species){
			foreach my $k(sort {$a <=> $b} keys %{$h{$s}}){
				if($s eq $refspec){
					print "$s\t$k\t$h{$s}{$k}{'gaps'}\t0\n";
				}else{
					$h{$s}{$k}{'gaps'}=0 if(not $h{$s}{$k}{'gaps'});
					$h{$s}{$k}{'ins'}=0 if(not $h{$s}{$k}{'ins'});
					print "$s\t$k\t$h{$s}{$k}{'gaps'}\t$h{$s}{$k}{'ins'}\n";
				}
				
			}
		}
		%h=();
	}
}
close IN;

foreach my $s(@species){
	foreach my $k(sort {$a <=> $b} keys %{$h{$s}}){
		if($s eq $refspec){
			print "$s\t$k\t$h{$s}{$k}{'gaps'}\t0\n";
		}else{
			$h{$s}{$k}{'gaps'}=0 if(not $h{$s}{$k}{'gaps'});
			$h{$s}{$k}{'ins'}=0 if(not $h{$s}{$k}{'ins'});
			print "$s\t$k\t$h{$s}{$k}{'gaps'}\t$h{$s}{$k}{'ins'}\n";
		}
		
	}
}
