#!/bin/bash

#base files
ls ../data/Septoria/reads/*.gz > ../output/intermediate/allfiles.txt
#cuts the files by unique identifiers
cut -d "/" -f 5 ../output/intermediate/allfiles.txt > ../output/intermediate/int.txt
rm -r ../output/intermediate/allfiles.txt
cut -d "_" -f 1 ../output/intermediate/int.txt > ../output/intermediate/int2.txt
rm -r ../output/intermediate/int.txt 
cut -d "-" -f 7-9 ../output/intermediate/int2.txt | uniq -d  > ../output/intermediate/identifier.txt
rm -r ../output/intermediate/int2.txt

#for loop for defining and finding names of files
for k in {1..60};
do

name=$(sed -n $k{p} ../output/intermediate/identifier.txt)

#creates sam files
bwa mem -t 20 ../cleaned-data/Septoria/Reference_indexing/ref.fasta ../data/Septoria/reads/*$name*R1*.gz ../data/Septoria/reads/*$name*R2*.gz > ../output/intermediate/$name.sam

#adds read group to sam files
java -jar ../../../programs/picard.jar AddOrReplaceReadGroups -I ../output/intermediate/$name.sam -O ../output/intermediate/$name.rg.sam -RGID $name -RGLB $name -RGPL Illumna -RGPU $name -RGSM $name

#sort the sam file, conver to bam file, and index output
java -jar ../../../programs/picard.jar SortSam -I ../output/intermediate/$name.rg.sam -O ../output/intermediate/$name.bam -SORT_ORDER coordinate -CREATE_INDEX true

#Mark duplicates, write them out to .mdup, filter bam file, and index output
java -jar ../../../programs/picard.jar MarkDuplicates -I ../output/intermediate/$name.bam -O ../output/intermediate/$name.mdup.bam -M ../output/intermediate/$name.mdup -ASSUME_SORT_ORDER coordinate -CREATE_INDEX true

#Sort the marked up bam file and index output
java -jar ../../../programs/picard.jar SortSam -I ../output/intermediate/$name.mdup.bam -O ../output/intermediate/$name.sorted.bam -SORT_ORDER coordinate -CREATE_INDEX true

#produce vcf files from the .sorted.bam files
gatk HaplotypeCaller -R ../cleaned-data/Septoria/Reference_indexing/ref.fasta -I ../output/intermediate/$name.sorted.bam -O ../output/intermediate/$name.vcf

##ONLY FOR DEBUGGING/TESTING, moves to a directory
#mv ../output/intermediate/*$name* ../test/

done

#removes intermediate files for storage/organization
rm -r ../output/intermediate/identifier.txt
rm -r ../output/intermediate/*.bai
#organizes stuff into directories
#mv ../output/intermediate/*.sam ../output/Septoria/sam
#mv ../output/Septoria/*.rg.sam ../output/Septoria/rg_sam
#mv ../output/intermediate/*bam ../output/Septoria/bam
#mv ../output/intermediate/*.sorted.bai ../output/Septoria/Sorted_bam
#mv ../output/intermediate/*mdup.bai ../output/Septoria/mdup_bam
#mv ../output/intermediate/*bai ../output/Septoria/bam
#mv ../output/Septoria/bam/*mdup.bam ../output/Septoria/mdup_bam
#mv ../output/intermediate/*.mdup ../output/Septoria/mdup
#mv ../output/Septoria/bam/*.sorted.bam ../output/Septoria/Sorted_bam
#mv ../output/intermediate/*.vcf ../output/Septoria/vcf
#mv ../output/intermediate*.idx ../output/Septoria/vcf
