#!/usr/bin/perl

open IN,$ARGV[0] or die "File not found\n";

my $out=1000;
my $sum=$out;

my $cur=0;

print "#pos\tfile_pos\n";

my $entry=0;

my $first=1;

while(<IN>){
	if(/\#/){
		$cur+=length();	
		next;
	}
	
	@l=split();
	if($first){
		$first=0;
		$sum=$l[1];
		$entry=1;
	}

	if($l[1] < $sum){
	}else{
		while($l[1] > $sum+$out){ ## increase sum as long as l[1] is too big to reduce index size
			$sum+=$out;
		}
		print "$sum\t$cur\n";
		$sum+=$out;
	}
	$cur+=length();	
}
close IN;
