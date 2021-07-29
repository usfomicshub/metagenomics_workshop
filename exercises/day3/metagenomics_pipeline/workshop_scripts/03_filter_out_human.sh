source local.env

mkdir -p ${outdir}/03_filter_out_human/

submit <<EOF
#!/bin/bash
#SBATCH --ntasks=${nprocesses}
#SBATCH --mail-type=ALL
#SBATCH --time=4:30:00
#SBATCH --mem=20000
#SBATCH --nodes=1
#SBATCH --mail-user=${email}
#SBATCH --job-name=03_filter_out_human
#SBATCH --output=${outdir}/03_filter_out_human/03_filter_out_human.out
#SBATCH --error=${outdir}/03_filter_out_human/03_filter_out_human.err


for sample in demo1 demo2; do

    # map cleaned reads to host (human) genome
    ${BOWTIE}/bin/bowtie2 \
        --very-sensitive-local \
        -p ${nprocesses} \
        --seed 455 \
        -x ${dbdir}/GRCh38_noalt_as/GRCh38_noalt_as \
        -1 ${outdir}/02_trimmomatic/\${sample}_clean_fwd_paired.fq \
        -2 ${outdir}/02_trimmomatic/\${sample}_clean_rev_paired.fq \
        -S ${outdir}/03_filter_out_human/\${sample}_mapped_and_unmapped.sam

    # convert output from sam to bam
    ${SAMTOOLS} view \
        -@ ${nprocesses} \
        -bS ${outdir}/03_filter_out_human/\${sample}_mapped_and_unmapped.sam \
        > ${outdir}/03_filter_out_human/\${sample}.bam

    # extract the unmapped (thus theoretically microbial) sequences
    ${SAMTOOLS} view \
        -@ ${nprocesses} \
        -b -f 12 -F 256 \
        ${outdir}/03_filter_out_human/\${sample}.bam \
        > ${outdir}/03_filter_out_human/\${sample}.unmapped.bam

    # sort the unmapped (thus theoretically microbial) sequences
    ${SAMTOOLS} sort \
        -@ ${nprocesses} \
        -n ${outdir}/03_filter_out_human/\${sample}.unmapped.bam \
        -o ${outdir}/03_filter_out_human/\${sample}.unmap.sorted.bam

    # convert sorted sequences to fastq format
    ${SAMTOOLS} bam2fq \
        -@ ${nprocesses} \
        ${outdir}/03_filter_out_human/\${sample}.unmap.sorted.bam \
        > ${outdir}/03_filter_out_human/\${sample}_microbiome.fastq

done


EOF
