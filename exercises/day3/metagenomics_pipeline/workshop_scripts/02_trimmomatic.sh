source local.env

mkdir -p ${outdir}/02_trimmomatic/

submit <<EOF
#!/bin/bash
#SBATCH --ntasks=2
#SBATCH --mail-type=ALL
#SBATCH --time=00:45:00
#SBATCH --mem=20000
#SBATCH --nodes=1
#SBATCH --mail-user=${email}
#SBATCH --job-name=02_trimmomatic
#SBATCH --output=${outdir}/02_trimmomatic/02_trimmomatic.out
#SBATCH --error=${outdir}/02_trimmomatic/02_trimmomatic.err

for sample in demo1 demo2; do

    # trim and filter raw reads so that only high quality data is used downstream

    ${TRIMMOMATIC} \
        PE \
        ${indir}/\${sample}_metageno_paired_fwd.fq \
        ${indir}/\${sample}_metageno_paired_rev.fq \
        ${outdir}/02_trimmomatic/\${sample}_clean_fwd_paired.fq \
        ${outdir}/02_trimmomatic/\${sample}_clean_fwd_unpaired.fq \
        ${outdir}/02_trimmomatic/\${sample}_clean_rev_paired.fq \
        ${outdir}/02_trimmomatic/\${sample}_clean_rev_unpaired.fq \
        ILLUMINACLIP:${TRIMMOMATIC_ADAPTERS}:2:30:10 \
        LEADING:3 \
        TRAILING:3 \
        SLIDINGWINDOW:4:15 \
        MINLEN:36

done


EOF
