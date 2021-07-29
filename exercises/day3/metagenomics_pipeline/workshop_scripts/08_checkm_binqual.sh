source local.env

mkdir ${outdir}/08_checkm

submit <<EOF
#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --mail-type=ALL
#SBATCH --time=1:00:00
#SBATCH --mem=20000
#SBATCH --nodes=1
#SBATCH --mail-user=${email}
#SBATCH --job-name=08_checkm
#SBATCH --output=${outdir}/08_checkm/08_checkm.out
#SBATCH --error=${outdir}/08_checkm/08_checkm.err


for sample in demo1 demo2; do

    ${CHECKM} lineage_wf -t 4 -x fa \
        ${outdir}/07_metabat/\${sample}_final.contigs.fa.metabat-bins1500-*/ \
        ${outdir}/08_checkm/\${sample}_checkm_res/

done

EOF
