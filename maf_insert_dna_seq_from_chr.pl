#!/usr/bin/perl

open IN,"$ARGV[0]" or die "no chr. file given\n";

$seq;

while(<IN>){
	chomp;
	next if(/^\s*$/);
	if(/>/){
		next;
	}else{
		$seq=$_;
	}
}
close IN;

open IN,"<$ARGV[1]" or die "no stiched maf file given\n";


$ref = $ARGV[3];
$chr = $ARGV[2];

while(<IN>){
	chomp;
	if(/^\s*$/){
		next;
	}
	if(/>${ref}.${chr}\((.)\):(\d+)-(\d+)/){
		$id=$_;
		$offset=$2;
		$id_new=">${ref}.${chr}\($1\):$offset-$3";
		$end=$3;
		$seqh=<IN>;
		chomp $seqh;
		print "$id_new\n",substr($seq,$offset,$end),"\n";## does not matter, because its complete genome seq, if everything went fine
	}else{
		print "$_\n";
	}
}
close IN;
print "\n";
