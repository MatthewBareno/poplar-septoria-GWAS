#!/bin/bash

#base files
ls ../cleaned-data/Septoria/reads_quality_filtered/*.gz > ../output/intermediate/allfiles.txt
#cuts the files by unique identifiers
cut -d "/" -f 5 ../output/intermediate/allfiles.txt > ../output/intermediate/int.txt
rm -r ../output/intermediate/allfiles.txt
cut -d "_" -f 1 ../output/intermediate/int.txt | uniq -d > ../output/intermediate/identifier.txt
rm -r ../output/intermediate/int.txt

#for loop for defining and finding names of files
for k in {1..2};
do

name=$(sed -n $k{p} ../output/intermediate/identifier.txt)

#creates sam files
bwa mem -t 20 ../cleaned-data/Septoria/Reference_indexing/SeptoriaGenome.fasta ../cleaned-data/Septoria/reads_quality_filtered/*$name*R1*.gz ../cleaned-data/Septoria/reads_quality_filtered/*$name*R2*.gz > ../output/intermediate/unfiltered$name.sam

#adds read group to sam file
java -jar ../../../programs/picard.jar AddOrReplaceReadGroups -I ../output/intermediate/unfiltered$name.sam -O ../output/intermediate/$name.sam -RGLB lib1 -RGPL illumna -RGPU unit1 -RGSM 20

#converts sam to bam file format
samtools view -h -b -S ../output/intermediate/$name.sam > ../output/intermediate/unfiltered$namei.bam

##(OPTIONAL)deletes sam file for storage
#rm -r *.sam

#filters bam files for only sequences that were mapped to the reference genome
samtools view -b -F 4 ../output/intermediate/unfiltered$namei.bam > ../output/intermediate/$name.bam

##(OPTIONAL) deletes unfiltered bam file
#rm -r unfiltered*.bam

#index bam files
samtools index *$name.bam

#generates a length.genome file
samtools view -H ../output/intermediate/$name.bam | perl -ne 'if ($_ =~ m/^\@SQ/) { print $_ }' | perl -ne 'if ($_ =~ m/SN:(.+)\s+LN:(\d+)/) { print $1, "\t", $2, "\n"}' > ../output/intermediate/$name.lengths.genome 

#sorts BAM file
samtools sort ../output/intermediate/$name.bam > ../output/intermediate/$name.sorted.bam

#bedtools to calulcate depth and genome lengths
bedtools genomecov -ibam ../output/intermediate/$name.sorted.bam -d -g ../output/intermediate/$name.lengths.genome > ../output/intermediate/$name.cov

#count with >0 coverage
awk -F"\t" '$3>0{print $1}' ../output/intermediate/$name.cov | sort | uniq -c > ../output/intermediate/$name.count

##ONLY FOR DEBUGGING/TESTING, moves to a directory
mv ../output/intermediate/*$name* ../test/

done

#removes intermediate files for storage/organization
rm -r ../output/intermediate/identifier.txt

#organizes stuff into directories
mv ../output/intermediate/unfiltered*.sam ../output/Septoria/Unfiltered_sam/
mv ../output/intermediate/*.sam ../output/Septoria/sam/
mv ../output/intermediate/unfiltered*.bam ../output/Septoria/unfiltered_bam/
mv ../output/intermediate/*.bam ../output/Septoria/bam/
mv ../output/intermediate/*.bai ../output/Septoria/bam
mv ../output/intermediate/*.lengths.genome ../output/Septoria/lengths_genome/
mv ../output/intermediate/*.sorted.bam ../output/Septoria/sorted_bam/
mv ../output/intermediate/*.cov ../output/Septoria/cov/
mv ../output/intermediate/*.count ../output/Septoria/count/
