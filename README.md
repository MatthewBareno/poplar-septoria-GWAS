# poplar-septoria-GWAS

data directory contains reference genome

scripts are in bash_scripts

fastq reads are in shared community folder

relevant tutorials
https://userweb.eng.gla.ac.uk/umer.ijaz/bioinformatics/BWA_tutorial.pdf
https://gatk.broadinstitute.org/hc/en-us/articles/360037225632-HaplotypeCaller
https://gatk.broadinstitute.org/hc/en-us/articles/360035891231-Errors-in-SAM-or-BAM-files-can-be-diagnosed-with-ValidateSamFile

.

Steps:

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

8. Using [this](https://gatk.broadinstitute.org/hc/en-us/articles/360035531892-GATK4-command-line-syntax) a vcf file creation was _attempted_ using

`gatk HaplotypeCaller -R REFERENCE.fasta -I FILTERED.bam -O OUTPUT.vcf`

but an error was returned:
![image](https://user-images.githubusercontent.com/108294550/178332364-c583023a-1213-458b-ba2d-736b13ad2f98.png)
the chief issue appears to be in the message:

"_java.lang.IllegalArgumentException: samples cannot be empty_"

.

Troubleshooting:

I googled the previous error and found [this](https://gatk.broadinstitute.org/hc/en-us/community/posts/360063062572-Not-getting-vcf-file) board. 

The answer suggested that it relates to an issue with the sam/bam file and encouraged [this]([url](https://gatk.broadinstitute.org/hc/en-us/articles/360035891231-Errors-in-SAM-or-BAM-files-can-be-diagnosed-with-ValidateSamFile) tutorial.

Being that the sam file creation was the first step, i ran ValidateSamFile on the sam file as

`gatk ValidateSamFile -I OUTPUT.sam`

and got a long list of errors and warnings:

file:///home/matthewbareno/Pictures/Screenshots/Screenshot%20from%202022-07-11%2011-56-41.png![image](https://user-images.githubusercontent.com/108294550/178338005-820ae884-0d79-4618-8c97-a573154efbc1.png)

to simplify, i ran it in summary mode and got:
![image](https://user-images.githubusercontent.com/108294550/178347769-f32532c0-88a3-4809-9db4-bc6dfc4062d0.png)
the key information is:

ERROR:MISSING_READ_GROUP	1

WARNING:QUALITY_NOT_STORED	5

WARNING:RECORD_MISSING_READ_GROUP	11589713

I tried this over many different samples (not just Nisk1 as shown) and got the same issue. Ricardo suspected that this is due to the oringinal fastq files not actually being septoria. Someone could have misnamed them, leading to all these issues. This would make sense of the line "WARNING:RECORD_MISSING_READ_GROUP	11589713" where it seems to suggest that the given genomes do not posses any of the read groups relative to the reference genome (which we are more certain of). 

To test this, i practiced assembling a genome into a fasta file from two read files (that were primer and quality filtered) after step 1. the following command accomplsihed this:
`spades.py -1 INPUT.R1.fastq -2 INPUT.R2.fastq -o OUTPUT.fasta`

.

we then applied bbsketch to the reference genome and the newly generated fasta. the bbsketch results affirmed that the fastq dataset given was indeed septoria. 

.

We were then back at square one. We tried googling the error and realized the error "ERROR:MISSING_READ_GROUP	1" simply means that its missing a read group, so we have to add them! 

I installed picard.jar to accomplish this and used the [following](https://broadinstitute.github.io/picard/command-line-overview.html#AddOrReplaceReadGroups) tutorial.
