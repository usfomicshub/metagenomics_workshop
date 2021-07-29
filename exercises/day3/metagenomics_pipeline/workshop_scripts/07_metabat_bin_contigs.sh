source local.env

mkdir -p ${outdir}/07_metabat

submit <<EOF
#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --mail-type=ALL
#SBATCH --time=00:45:00
#SBATCH --mem=20000
#SBATCH --nodes=1
#SBATCH --mail-user=${email}
#SBATCH --job-name=07_metabat
#SBATCH --output=${outdir}/07_metabat/07_metabat.out
#SBATCH --error=${outdir}/07_metabat/07_metabat.err

cd ${outdir}/07_metabat

for sample in demo1 demo2; do

    cp ${outdir}/05_megahit/\${sample}_assembled_genome/final.contigs.fa ./\${sample}_final.contigs.fa

    ${METABAT} -m 1500 \
        ./\${sample}_final.contigs.fa \
        ${outdir}/06_bowtie_map_reads/\${sample}_micro.assem_sorted.bam

done

EOF
