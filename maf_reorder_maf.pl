#!/usr/bin/perl 

open IN,$ARGV[0] or die "File with species not found\n";

while(<IN>){
	@l=split();
	next if(/^\s*$/);
	push(@species,$l[0]);
	$map{$l[0]} = $l[1];
}
close IN;

open OUT,">$ARGV[1].r" or die "Could not create output file $ARGV[0].r\n";

foreach my $s(@species){
	open IN,$ARGV[1] or die "File not found\n";
	while(<IN>){
		if(/>$s/){
			chomp;
			print OUT $_,":$map{$s}\n";
			$seq=<IN>;
			print OUT $seq;
			last;
		}
	}
	close IN;
}
close OUT;

