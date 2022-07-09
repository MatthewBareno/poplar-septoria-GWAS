#!/bin/bash

#base files
ls ../mbareno/data/cleaned-data/*.gz > allfiles.txt
#cuts the files by unique identifiers
cut -d "/" -f 5 allfiles.txt > int.txt
rm -r allfiles.txt
cut -d "_" -f 1 int.txt | uniq -d > identifier.txt
rm -r int.txt

#for loop for defining and finding names of files
for k in {1..60};
do

name=$(sed -n $k{p} identifier.txt)

#creates sam files
bwa mem -t 20 SeptoriaReference/SeptoriaGenome.fasta ../mbareno/data/cleaned-data/*$name*R1*.gz ../mbareno/data/cleaned-data/*$name*R2*.gz > ../mbareno/intermediate/$name.sam

#converts sam to bam file format
samtools view -h -b -S ../mbareno/intermediate/$name.sam > ../mbareno/intermediate/unfiltered$name.bam

##(OPTIONAL)deletes sam file for storage
#rm -r *.sam

#filters bam files for only sequences that were mapped to the reference genome
samtools view -b -F 4 ../mbareno/intermediate/unfiltered$name.bam > ../mbareno/intermediate/$name.mapped.bam

##(OPTIONAL) deletes unfiltered bam file
#rm -r unfiltered*.bam

#generates a length.genome file
samtools view -H ../mbareno/intermediate/$name.mapped.bam | perl -ne 'if ($_ =~ m/^\@SQ/) { print $_ }' | perl -ne 'if ($_ =~ m/SN:(.+)\s+LN:(\d+)/) { print $1, "\t", $2, "\n"}' > ../mbareno/intermediate/$name.lengths.genome 

#sorts BAM file
samtools sort ../mbareno/intermediate/$name.mapped.bam > ../mbareno/intermediate/$name.mapped.sorted.bam

#bedtools to calulcate depth and genome lengths
bedtools genomecov -ibam ../mbareno/intermediate/$name.mapped.sorted.bam -d -g ../mbareno/intermediate/$name.lengths.genome > ../mbareno/intermediate/$name.mapped.sorted.bam.perbase.cov

#count with >0 coverage
awk -F"\t" '$3>0{print $1}' ../mbareno/intermediate/$name.mapped.sorted.bam.perbase.cov | sort | uniq -c > ../mbareno/intermediate/$name.mapped.bam.perbase.count

##ONLY FOR DEBUGGING/TESTING, moves to a directory
#mv ../mbareno/intermediate/*$name* ../mbareno/test_folder/

done

#organizes stuff into directories
mv ../mbareno/intermediate/*.sam ../mbareno/output/sam/
mv ../mbareno/intermediate/*unfiltered*.bam ../mbareno/output/unfiltered_bam/
mv ../mbareno/intermediate/*.mapped.bam ../mbareno/output/Mapped_Bam/
mv ../mbareno/intermediate/*.lengths.genome ../mbareno/output/lengths_genome/
mv ../mbareno/intermediate/*.mapped.sorted.bam ../mbareno/output/mapped_sorted_bam/
mv ../mbareno/intermediate/*.mapped.sorted.bam.perbase.cov ../mbareno/output/mapped_sorted_bam_perbase_cov/
mv ../mbareno/intermediate/*.mapped.bam.perbase.count ../mbareno/output/mapped_bam_perbase_count/

#removes intermediate files for storage/organization
rm -r identifier.txt
