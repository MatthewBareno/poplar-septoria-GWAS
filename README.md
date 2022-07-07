# poplar-septoria-GWAS

-steps
given fastq files
cut primers and quality filter for >30 (reaches statistical significance)
created a bash script that automated this
  - getting the for loop down, figuring out the bash syntax
  ![image](https://user-images.githubusercontent.com/108294550/177845983-29d04dbd-342d-4623-b289-60dc40128289.png)
  - issues with the cluster prevented the smoothest automation (storage space, permissions, etc) so i had to manually edit it a little
  - in the end we had read files that were filtered for quality and the primers cut

-steps of process
index refernce genome
convert fastq filtered to sam files
convert sam to bam files	
filter bam files to 



