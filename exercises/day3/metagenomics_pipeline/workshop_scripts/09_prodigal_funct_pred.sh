source local.env

mkdir ${outdir}/09_prodigal

submit <<EOF
#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --mail-type=ALL
#SBATCH --time=00:30:00
#SBATCH --mem=15000
#SBATCH --nodes=1
#SBATCH --mail-user=${email}
#SBATCH --job-name=09_prodigal
#SBATCH --output=${outdir}/09_prodigal/09_prodigal.out
#SBATCH --error=${outdir}/09_prodigal/09_prodigal.err


for sample in demo1 demo2; do

    ${PRODIGAL} \
        -p meta \
        -i ${outdir}/07_metabat/\${sample}_final.contigs.fa \
        -a ${outdir}/09_prodigal/\${sample}_amino_acids.faa \
        -d ${outdir}/09_prodigal/\${sample}_nucleotides.ffn \
        -o ${outdir}/09_prodigal/\${sample}_gene_coordinates.gbk \
        -s ${outdir}/09_prodigal/\${sample}_genes_scores.gff

done

EOF
