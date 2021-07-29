source local.env

mkdir -p ${outdir}/06_bowtie_map_reads

submit <<EOF
#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --mail-type=ALL
#SBATCH --time=00:45:00
#SBATCH --mem=20000
#SBATCH --nodes=1
#SBATCH --mail-user=${email}
#SBATCH --job-name=06_bowtie_map_reads
#SBATCH --output=${outdir}/06_bowtie_map_reads/06_bowtie_map_reads.out
#SBATCH --error=${outdir}/06_bowtie_map_reads/06_bowtie_map_reads.err


for sample in demo1 demo2; do

    # build bowtie database
    ${BOWTIE}/bin/bowtie2-build --seed 250 \
        ${outdir}/05_megahit/\${sample}_assembled_genome/final.contigs.fa \
        ${outdir}/06_bowtie_map_reads/\${sample}_database

    # split interleaved fastq into fwd and reverse reads
    bash ~/metagenome_workshop/workshop_scripts/deinterleave_fastq.sh \
        < ${outdir}/03_filter_out_human/\${sample}_microbiome.fastq \
        ${outdir}/06_bowtie_map_reads/\${sample}_micro_R1_001.fastq \
        ${outdir}/06_bowtie_map_reads/\${sample}_micro_R2_001.fastq

    # map microbiome reads to contigs
    ${BOWTIE}/bin/bowtie2 \
        --sensitive-local -p 4 --seed 7564 \
        -x ${outdir}/06_bowtie_map_reads/\${sample}_database \
        -1 ${outdir}/06_bowtie_map_reads/\${sample}_micro_R1_001.fastq \
        -2 ${outdir}/06_bowtie_map_reads/\${sample}_micro_R2_001.fastq \
        -S ${outdir}/06_bowtie_map_reads/\${sample}_micro.sam

    # ?
    ${SAMTOOLS} faidx ${outdir}/05_megahit/\${sample}_assembled_genome/final.contigs.fa

    # convert sam to bam
    ${SAMTOOLS} view -@ 567 \
        -bS ${outdir}/06_bowtie_map_reads/\${sample}_micro.sam \
        > ${outdir}/06_bowtie_map_reads/\${sample}_micro.assem.bam

    # sort bam
    ${SAMTOOLS} sort \
        ${outdir}/06_bowtie_map_reads/\${sample}_micro.assem.bam -o \
        ${outdir}/06_bowtie_map_reads/\${sample}_micro.assem_sorted.bam

    # index the bam file (will be used by idxstats)
    ${SAMTOOLS} index ${outdir}/06_bowtie_map_reads/\${sample}_micro.assem_sorted.bam

    # calculate some summary stats
    ${SAMTOOLS} idxstats ${outdir}/06_bowtie_map_reads/\${sample}_micro.assem_sorted.bam \
        > ${outdir}/06_bowtie_map_reads/\${sample}_micro.assem_sorted.stats.txt

done


EOF
