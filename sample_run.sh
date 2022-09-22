#!/bin/bash

S=$HOME/micpdp_package/build_index/

echo I II III IV V M X|xargs -n1 -I{} wget http://hgdownload.soe.ucsc.edu/goldenPath/ce10/multiz7way/chr{}.maf.gz

wget http://hgdownload.soe.ucsc.edu/goldenPath/ce10/database/chromInfo.txt.gz

echo I II III IV V M X|xargs -n1 -I{} wget http://hgdownload.soe.ucsc.edu/goldenPath/ce10/chromosomes/chr{}.fa.gz

gunzip *.gz

echo I II III IV V M X|xargs -n1 -I{} sh -c 'a={};perl $S/make_fasta_file_from_fa_similar.pl chr$a.fa > chr$a.fa.ol'

## we do it here only for chrI now
perl $S/split_maf.pl   chrI.maf     ce10       4                chrI              chromInfo.txt

## get phylotree
wget http://hgdownload.soe.ucsc.edu/goldenPath/ce10/multiz7way/ce10.7way.nh

specs=$(perl -ane 'while(/(\w+):\d/g){push(@out,$1)};print join(",",@out)' ce10.7way.nh)
ref=$(perl -ane 'while(/(\w+):\d/g){push(@out,$1)};print $out[0]' ce10.7way.nh)

perl -ane 'while(/(\w+):\d/g){push(@out,$1)};END{print join("\n",@out)}' ce10.7way.nh > species_$ref

## we need bx python 
pip install bx-python

## interval maf and maf_utilities from galaxy
wget -O tmp.py https://raw.githubusercontent.com/galaxyproject/galaxy/dev/tools/maf/interval_maf_to_merged_fasta.py

## modify one line so it directly imports from file ## no need to download whole galaxy tools 
perl -ane 'if(/import maf_utilities/){print "import maf_utilities\n";}else{print;}' tmp.py > interval_maf_to_merged_fasta.py

## modify maf_utilities to open index file with wb
wget https://raw.githubusercontent.com/galaxyproject/galaxy/dev/lib/galaxy/datatypes/util/maf_utilities.tmp
perl -ane 'if(/(^.+tempfile.NamedTemporaryFile\(mode="w)(".+$)/){print "$1b$2"}else{print;}' maf_utilities.tmp > maf_utilities.py

export PYTHONPATH=$PYTHONPATH:$(pwd _LP)

## which chromosome

cd chrI
for x in {1..4} ;do
python ../interval_maf_to_merged_fasta.py -c 1 -s 2 -e 3 -S 6 -d $ref -p $specs  -i chrI.maf.${x}.bed -m chrI.maf.${x} -t user -o chrI.maf.${x}.stitched
done

## make bridge maf etc
cat *bridge* > chrI.maf.bed_bridges
python ../interval_maf_to_merged_fasta.py -c 1 -s 2 -e 3 -S 6 -d $ref -p $specs  -i chrI.maf.bed_bridges -m ../chrI.maf -t user -o chrI.maf.stitched.boundary

## now make full maf file
$S/finalize_stitch.sh ../species_ce10 ../chromInfo.txt  chrI 4 ce10 ../

cd ..
## build index now
for i in chrI.maf;do perl $S/make_maf_index_on_blocks_2.pl $i ce10 > $i.index;done
for i in chrI.maf.index;do sort -nk2,2 $i > $i.sorted;done

i=chrI
perl $S/build_index_on_index.pl $i.maf.index.sorted > $i.maf.index.sorted.i2
