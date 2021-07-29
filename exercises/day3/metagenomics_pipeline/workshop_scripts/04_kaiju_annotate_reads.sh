source local.env

mkdir -p ${outdir}/04_kaiju_reads

submit <<EOF
#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --mail-type=ALL
#SBATCH --time=00:20:00
#SBATCH --mem=45000
#SBATCH --nodes=1
#SBATCH --mail-user=${email}
#SBATCH --job-name=04_kaiju_reads
#SBATCH --output=${outdir}/04_kaiju_reads/04_kaiju_reads.out
#SBATCH --error=${outdir}/04_kaiju_reads/04_kaiju_reads.err


for sample in demo1 demo2; do

    ${KAIJU} -z 4 \
        -t ${dbdir}/kaiju/nodes.dmp \
        -f ${dbdir}/kaiju/kaiju_db.fmi \
        -i ${outdir}/03_filter_out_human/\${sample}_microbiome.fastq \
        > ${outdir}/04_kaiju_reads/\${sample}_kaiju.out

done

${KAIJU}2table -e -p \
    -t ${dbdir}/kaiju/nodes.dmp \
    -n ${dbdir}/kaiju/names.dmp \
    -r species \
    -o ${outdir}/04_kaiju_reads/kaiju_species.tsv \
    ${outdir}/04_kaiju_reads/*_kaiju.out


EOF
