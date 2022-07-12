# poplar-septoria-GWAS
Steps (attempt 1):

1. fastqc applied to given fastq R1/R2 files. Primer cutting and quality filtering above score of 30 accomplished with

`cutadapt -q 30 -a PRIMER_OF_R1 -A PRIMER_OF_R2 -o OUTPUT1  -p OUTPUT2 INPUT1 INPUT2`

**process verified by the html output of a separate fastqc analysis**
i created a bash script which automated this process over 60 samples.

2. Downloaded reference genome of septoria musiva from [here](https://www.ncbi.nlm.nih.gov/data-hub/genome/GCF_000320565.1/)

    - in download options, only **☐ Genomic Sequence** was selected

3. Using [this](https://gatk.broadinstitute.org/hc/en-us/articles/360035531652-FASTA-Reference-genome-format), a .dict file and .fai file were created from the reference file

`gatk CreateSequenceDictionary -R REFERENCE.fasta`

`samtools faidx REFERENCE.fasta`

4. Using [this](https://userweb.eng.gla.ac.uk/umer.ijaz/bioinformatics/BWA_tutorial.pdf) tutorial the reference genome was indexed with

`bwa index REFERENCE.FASTA`

5. Reads were combined into a SAM file using 

`bwa mem REFERENCE.fasta INPUT_R1.fastq INPUT_R2.fastq > OUTPUT.sam`

6. sam file converted to bam file using

`samtools view -h -b -S INPUT.sam > OUTPUT.bam`

7. filter bam file for only sequences that were mapped against reference genome

`samtools view -b -F 4 OUTPUT.bam > FILTERED.bam`

i created another bash script which automated steps 5-7 for the 60 samples given.

8. Using [this](https://gatk.broadinstitute.org/hc/en-us/articles/360035531892-GATK4-command-line-syntax) a vcf file creation was _attempted_ using

`gatk HaplotypeCaller -R REFERENCE.fasta -I FILTERED.bam -O OUTPUT.vcf`

but an error was returned:
![image](https://user-images.githubusercontent.com/108294550/178332364-c583023a-1213-458b-ba2d-736b13ad2f98.png)
the chief issue appears to be in the message:

"_java.lang.IllegalArgumentException: samples cannot be empty_"

.

Troubleshooting:

I googled the previous error and found [this](https://gatk.broadinstitute.org/hc/en-us/community/posts/360063062572-Not-getting-vcf-file) board. 

The answer suggested that it relates to an issue with the sam/bam file and encouraged [this](https://gatk.broadinstitute.org/hc/en-us/articles/360035891231-Errors-in-SAM-or-BAM-files-can-be-diagnosed-with-ValidateSamFile) tutorial.

Being that the sam file creation was the first step, i ran ValidateSamFile on the sam file as

`gatk ValidateSamFile -I OUTPUT.sam`

and got a long list of errors and warnings:

![image](https://user-images.githubusercontent.com/108294550/178347769-f32532c0-88a3-4809-9db4-bc6dfc4062d0.png)
the key information is:

ERROR:MISSING_READ_GROUP	1

WARNING:QUALITY_NOT_STORED	5

WARNING:RECORD_MISSING_READ_GROUP	11589713

I tried this over many different samples (not just Nisk1 as shown) and got the same issue. Ricardo suspected that this is due to the oringinal fastq files not actually being septoria. Someone could have misnamed them, leading to all these issues. This would make sense of the line "WARNING:RECORD_MISSING_READ_GROUP	11589713" where it seems to suggest that the given genomes do not posses any of the read groups relative to the reference genome (which we are more certain of). 

To test this, i practiced assembling a genome into a fasta file from two read files (that were primer and quality filtered) after step 1. the following command accomplsihed this:
`spades.py -1 INPUT.R1.fastq -2 INPUT.R2.fastq -o OUTPUT.fasta`

.

we then applied bbsketch to the reference genome and the newly generated fasta. the bbsketch results confirmed that the fastq dataset given was indeed septoria. 

.

We were then back at square one. We tried googling the error and realized the error "ERROR:MISSING_READ_GROUP	1" simply means that its missing a read group, so we have to add them! 

I installed picard.jar to accomplish this and used the [following](https://broadinstitute.github.io/picard/command-line-overview.html#AddOrReplaceReadGroups) tutorial.

I guessed that adding the read group needed to be done after step 5 in the steps for attempt 1 because doing it after would force us to work in binary, which is not what the addorreplacegroups function works in. Also, ricardo hinted at this. so i took an output file from step 5 (sam file) and added a read group using:

`java -jar PICARD.jar AddOrReplaceReadGroups -I INPUT.sam -O OUTPUT.sam -RGLB lib1 -RGPL illumna -RGPU unit1 -RGSM 20`

I got a successful output file and continued with steps 6-8 to get the filtered bam file. 

I attempted step 8 and got the following error:

"A USER ERROR has occurred: Traversal by intervals was requested but some input files are not indexed.
Please index all input files:"

And so i indexed the filtered bam file from the product of step 7 as:


`samtools index FILTERED.bam`


and reran step 8 and got a vcf file!

.

Troubleshooting (continued):

vcf errors!

The vcf file is not formatted correctly
. i suspect this is due to the java AddOrReplaceReadGroup function not actually adding a read group, but creating a separate read group file. This new separate file just contains the read group and not the rest of the genome, so it is lower in overall size. I then tried to merge the read group file (.sam format) with the original sam by using [merge](http://www.htslib.org/doc/samtools-merge.html)

`samtools merge -n ORIGINAL.sam -r READGROUP.sam -o CLEANED.sam`

before proceeding, i used ValidateSamFile on the Nisk1actual to see what potential sources of error could be

`gatk ValidateSamFile -I CLEANED.sam -MODE SUMMARY`

and got the following issues:
![image](https://user-images.githubusercontent.com/108294550/178591208-ba5f5032-3ac4-4b2c-b800-bd4236150262.png)


in short, nothing was fixed and a new error was added. the merge solution does not work. 

.

Ricardo suggested that i try a different reference genome file that he provided. I repeated steps 3-5, and used the addoreplacereadgroups function again because when he did it the file size wasn't reduced. 
