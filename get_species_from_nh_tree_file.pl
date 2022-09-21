#!/usr/bin/perl

open IN,$ARGV[0] or die "File not found\n";

while(<IN>){
	while(/(\w+)_(\w+):\d+/g){
		print "$2\t$1\n";
	}
}
close IN;
