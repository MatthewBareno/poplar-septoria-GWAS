ls *.fastq > allfiles.txt

cut -d "-" -f 7-9 allfiles.txt > dashdelimit.txt

cut -d "_" -f 1-2 dashdelimit.txt > identifier.txt
