source local.env

mkdir -p ${outdir}/05_megahit

submit <<EOF
#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --mail-type=ALL
#SBATCH --time=00:40:00
#SBATCH --mem=40000
#SBATCH --nodes=1
#SBATCH --mail-user=${email}
#SBATCH --job-name=05_megahit
#SBATCH --output=${outdir}/05_megahit/05_megahit.out
#SBATCH --error=${outdir}/05_megahit/05_megahit.err


for sample in demo1 demo2; do

    ${MEGAHIT} \
        --k-step 10 \
        --12 ${outdir}/03_filter_out_human/\${sample}_microbiome.fastq \
        -o ${outdir}/05_megahit/\${sample}_assembled_genome

done

${METAQUAST} \
    -m 4 \
    -t 4 \
    ${outdir}/05_megahit/*_assembled_genome/final.contigs.fa \
    -o ${outdir}/05_megahit/metaquast


EOF
