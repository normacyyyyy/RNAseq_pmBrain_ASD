## Use this qsub: qsub -cwd -V -N SJrealign -S /bin/bash -q geschwind.q -l h_data=64G -pe shared 8 4_2pass.sh
#!/bin/bash

starCALL=/share/apps/STAR_2.4.0j/bin/Linux_x86_64/STAR
genomeDir=/geschwindlabshares/eQTL/data/FetalBrainRNASeq/2passStar/code/hg19_2pass #path to new genome created from SJ out
datadir=/geschwindlabshares/eQTL/data/FetalBrainRNASeq/2014-423-18765747 # path to bam files
outputdir=/geschwindlabshares/eQTL/data/FetalBrainRNASeq/2passStar #path to output directory


# Final alignments made with the index made from splice junctions "SJ.all.out.tab"
# This script goes through samples one at a time since writing sam and bam files
   

#Resulting index used to produce final alignment
cd $datadir

for dir in */; do
	if [ ! -d /geschwindlabshares/eQTL/data/FetalBrainRNASeq/2passStar/${dir} ]; then
		mkdir ${outputdir}/${dir} 
		cd ${dir}
		for readpair in `ls *R1_001.fastq.gz`; do
		 	echo $readpair
		 	basereadpair=$(basename $readpair _R1_001.fastq.gz)
		 	echo $basereadpair
		 	cd ${outputdir}/${dir}
		 	$starCALL --runThreadN 8 --genomeDir $genomeDir --outFileNamePrefix ${outputdir}/${dir}/${basereadpair} --readFilesCommand gunzip -c --readFilesIn ${datadir}/${dir}${basereadpair}_R1_001.fastq.gz ${datadir}/${dir}${basereadpair}_R2_001.fastq.gz
		 	$STAR --runMode alignReads --genomeDir $genomeDir --readFilesCommand zcat --readFilesIn $FF1 $FF2 
--outSAMstrandField intronMotif --outFilterIntronMotifs RemoveNoncanonical --outSAMtype BAM Unsorted --outFilterScoreMinOverLread 0.5
--outFilterMatchNminOverLread 0.5
			echo "STAR alignment complete"
		 	samtools view -bS ${basereadpair}Aligned.out.sam > ${basereadpair}Aligned.out.bam
		 	echo ".SAM now converted to .BAM"
		 	rm -f ${basereadpair}Aligned.out.sam
		 	cd $datadir
		done 	
	fi
done
