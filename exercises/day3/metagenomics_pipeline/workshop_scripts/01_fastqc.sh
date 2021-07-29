source local.env

mkdir -p ${outdir}/01_fastqc/

submit <<EOF
#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --mail-type=ALL
#SBATCH --time=00:45:00
#SBATCH --mem=20000
#SBATCH --nodes=1
#SBATCH --mail-user=${email}
#SBATCH --job-name=01_fastqc
#SBATCH --output=${outdir}/01_fastqc/01_fastqc.out
#SBATCH --error=${outdir}/01_fastqc/01_fastqc.err

for sample in demo1 demo2; do

    for direction in fwd rev; do

        # produce quality control summaries and plots for raw data, separately for each sample and for forward and reverse reads

        ${FASTQC} ${indir}/\${sample}_metageno_paired_\${direction}.fq -o ${outdir}/01_fastqc/

    done

done

EOF