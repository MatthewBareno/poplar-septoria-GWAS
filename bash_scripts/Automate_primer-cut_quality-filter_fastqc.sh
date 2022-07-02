#remember to enter the cutadapt environment with this command:
        #conda activate cutadaptenv

#run this file in the bash_scripts directory

#creates files of all fastq files in a directory
ls ../data/*.fastq > allfiles.txt
#cuts the file list by unique identifiers
cut -c 50-55 allfiles.txt  > files_by_code.txt

#for loop for defining and finding names of files
for k in {1..2}; 
do

name=$(sed -n $k{p} files_by_code.txt)

#cuts primers using paired-end reads, creates intermediate primer-cut fastqs
cutadapt -j 15 -a ATCGGAAGAGCACACGTCTGAACTCCAGTCACATTACTCGATCTCGTATG -A ATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGGCTATAGTGTAGATCTC -o intermediate$name*R1i.fastq  -p intermediate$name*R2i.fastq ../data/*$name*R1*.fastq ../data/*$name*R2*.fastq

#filters intermediate primer-cut fastqs by quality >=30. final cleaed output files are in the form UNIQUEIDENTIFIERR(1/2)_001.fastq
cutadapt -j 15 -q 30 -o ../cleaned-data/quality_filtered/$name.R1_001.fastq -p ../cleaned-data/quality_filtered/$name.R2_001.fastq intermediate$name*R1i.fastq intermediate$name*R2i.fastq

#performing fastqc on primer-cut, quality filtered file
fastqc  ../cleaned-data/quality_filtered/$name.R1_001.fastq
fastqc  ../cleaned-data/quality_filtered/$name.R2_001.fastq

done

#moves the fastqc htmls to another folder

mv ../cleaned-data/quality_filtered/*.html ../output/quality_filtered_fastqc_htmls/

#removes intermediate files for storage
rm -r intermediate*.fastq
rm -r ../cleaned-data/quality_filtered/*fastqc.zip
rm -r allfiles.txt
rm -r files_by_code.txt
	
#optional, removes the primer/quality filtered fastq files
#rm -r  ../output/quality_filtered_fastqc_htmls/*R1.fastq
#rm -r  ../output/quality_filtered_fastqc_htmls/*R2.fastq

#how to edit in different context
##change the range in the for loop to the amount of files
## change the range of the cut function in line 9 according to the location of the identifier of the data set
##change the directories depending on the organization of your code
