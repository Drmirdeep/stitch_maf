#!/bin/bash

S=$( cd $(dirname $0) ; pwd -P )

## species file already reorderd to ucsc order liek mm9_species.reordered
SPECIES=$1
## chrominfor file from ucsc, like chrominfo
CHRINFO=$2
## chromosome to process right now, like chr10
CHR=$3
## how many single maf files we had like 15 or 10
LIM=$4
## ref species according to ucsc like mm9
REF=$5
## Absolute path to fasta files with complete chromosomes,
## the sequences must be on a single line e.g.
## make_fasta_from_fasta_similar.pl chr1.fa > chr1.fa.ol
P=$6

if [ -z "$6" ];then 
	echo
	echo usage: $0 species_file             chrominfo_file  chromosome_to_process  num_of_maf_chunks   refspecies   path_to_chrom_files
	echo    eg: $0 mm9_species_reordered    chrominfo       chr1                   15                  mm9          ./genome/
	echo
	exit
fi

## first fuse all segments
echo -e "fusing maf now with "
echo -e "$S/fuse_maf.pl $SPECIES $CHRINFO $CHR $LIM $CHR.maf.stitched.boundary"
echo 
$S/maf_fuse_maf.pl $SPECIES $CHRINFO $CHR $LIM $CHR.maf.stitched.boundary 

## insert full dna sequence now for genome
echo -e "inserting dna seq into maf now with" 
echo -e "$S/insert_dna_seq_from_chr.pl $P/genome/$CHR.fa.ol fused.maf.stitched $CHR $REF $P > $CHR.maf.stitched.cmpl.repeats_lc"
echo 
$S/maf_insert_dna_seq_from_chr.pl $P/$CHR.fa.ol fused.maf.stitched $CHR $REF > $CHR.maf.stitched.cmpl.repeats_lc

# exit

## no reorder according to ucsc genome browser
echo -e "reordering maf now with"
echo -e "$S/reorder_maf.pl $SPECIES $CHR.maf.stitched.cmpl.repeats_lc"
echo 
$S/maf_reorder_maf.pl $SPECIES $CHR.maf.stitched.cmpl.repeats_lc
