#!/usr/bin/perl

use strict;

open IN,"<$ARGV[0]" or die "usage: $0 input file\n";

my $line;
my $id;
my $tmpid;
my $seq;
my $first = 1;

while($line = <IN>){
	next if($line =~ /^\s*$/);
    chomp $line;
    if($line =~ /^(>\S+)\s*\|*\s*(\S*)/){
        $tmpid = $1;
        if($2){
            $tmpid .= "_${2}";
        }
        if(!$first){
            print "$id\n$seq\n";
        }else{
            $first = 0;
        }
        $seq="";
        $id = $tmpid;
    }else{ ## line is sequence or empty
		##replace u with T
        $line =~ tr/uU/tT/;
		##remove whitespace in sequence if any
		$line =~ s/\s+//g;
		
        $seq .= $line;
    }

}
print "$id\n$seq\n";

close IN;

exit;
