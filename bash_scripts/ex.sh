#!/bin/bash

##Practice bash script for when onyl 2 files are given in a directory
#NOT fully generalizable

#remember to enter the cutadapt environment with this command:
	#conda activate cutadaptenv

#cutting the primers using paired-end reads
cutadapt -j 15 -a ATCGGAAGAGCACACGTCTGAACTCCAGTCACATTACTCGATCTCGTATG -A ATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGGCTATAGTGTAGATCTC -o ../output/quality_filtered_fastqc_htmls/$name*R1.fastq -p ../output/quality_filtered_fastqc_htmls/$name*R2.fastq ../data/*$name*R1*.fastq ../data/*$name*R2*.fastq

#quality filtering >= 30
cutadapt -j 15 -q 30 -o  ../cleaned-data/quality_filtered/$name*R1.fastq -p  ../cleaned-data/quality_filtered/$name*R2.fastq ../output/quality_filtered_fastqc_htmls/$name*R1_001.fastq ../output/quality_filtered_fastqc_htmls/$name*R2_001.fastq

#performing fastq on primer-cut, quality filtered file
fastqc  ../cleaned-data/quality_filtered/$name*R1_001.fastq
fastqc  ../cleaned-data/quality_filtered/$name*R2_001.fastq

#deletes the intermediate files for storage
rm -r  ../output/quality_filtered_fastqc_htmls/*.fastq
rm -r  ../cleaned-data/quality_filtered/*fastqc.zip
mv ../cleaned-data/quality_filtered/*.html ../output/quality_filtered_fastqc_htmls

#optional, removes the primer/quality filtered fastq files
#rm -r  ../output/quality_filtered_fastqc_htmls/*R1.fastq
$rm -r  ../output/quality_filtered_fastqc_htmls/*R2.fastq

#opening the output files
#open ../output/quality_filtered_fastqc_htmls/R2_fastqc.html
#open ../output/quality_filtered_fastqc_htmls/R1_fastqc.html

#resets the terminal

