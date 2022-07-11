# poplar-septoria-GWAS

data directory contains reference genome

scripts are in bash_scripts

fastq reads are in shared community folder

relevant tutorials
https://userweb.eng.gla.ac.uk/umer.ijaz/bioinformatics/BWA_tutorial.pdf
https://gatk.broadinstitute.org/hc/en-us/articles/360037225632-HaplotypeCaller
https://gatk.broadinstitute.org/hc/en-us/articles/360035891231-Errors-in-SAM-or-BAM-files-can-be-diagnosed-with-ValidateSamFile


1. fastqc applied to given fastq R1/R2 files. Primer cutting and quality filtering above score of 30 accomplished with

`cutadapt -q 30 -a PRIMER_OF_R1 -A PRIMER_OF_R2 -o OUTPUT1  -p OUTPUT2 INPUT1 INPUT2`

**process verified by the html output of a separate fastqc analysis**

2. Downloaded reference genome of septoria musiva from [here](https://www.ncbi.nlm.nih.gov/data-hub/genome/GCF_000320565.1/)

    - in download options only **☐ Genomic Sequence** was selected

3. Using [this](https://userweb.eng.gla.ac.uk/umer.ijaz/bioinformatics/BWA_tutorial.pdf) tutorial the reference genome was indexed with

`bwa index REFERENCE.FASTA`

4. Reads were combined into a SAM file using 

`bwa mem REFERENCE.fasta INPUT_R1.fastq INPUT_R2.fastq > OUTPUT.sam`

5. sam file converted to bam file using

`samtools view -h -b -S INPUT.sam > OUTPUT.bam`

6. filter bam file for only sequences that were mapped against reference genome

`samtools view -b -F 4 OUTPUT.bam > FILTERED.bam`

7. Using [this](https://gatk.broadinstitute.org/hc/en-us/articles/360035531652-FASTA-Reference-genome-format) a .dict file and .fai file were created from the reference file

`gatk CreateSequenceDictionary -R REFERENCE.fasta`

`samtools faidx REFERENCE.fasta`

8. Using [this](https://gatk.broadinstitute.org/hc/en-us/articles/360035531892-GATK4-command-line-syntax) a vcf file creation was _attempted_ using

`gatk HaplotypeCaller -R REFERENCE.fasta -I FILTERED.bam -O OUTPUT.vcf`

but an error was returned:
![image](https://user-images.githubusercontent.com/108294550/178332364-c583023a-1213-458b-ba2d-736b13ad2f98.png)
the chief issue appears to be in the message:

"_java.lang.IllegalArgumentException: samples cannot be empty_"
