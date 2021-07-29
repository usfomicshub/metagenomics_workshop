source local.env

submit <<EOF
#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --mail-type=ALL
#SBATCH --time=03:00:00
#SBATCH --mem=10000
#SBATCH --nodes=1
#SBATCH --mail-user=${email}
#SBATCH --job-name=00_database_download
#SBATCH --output=${outdir}/00_database_download.out
#SBATCH --error=${outdir}/00_database_download.err

cd ${dbdir}

## if the human genome hasn't yet been downloaded, do that
if [ ! -d GRCh38_noalt_as ]
then
    wget https://genome-idx.s3.amazonaws.com/bt/GRCh38_noalt_as.zip

    unzip GRCh38_noalt_as.zip
fi


## if the kaiju database hasn't yet been downloaded, do that
if [ ! -d kaiju ]
then
    mkdir kaiju
    
    cd ${dbdir}/kaiju
    
    wget http://kaiju.binf.ku.dk/database/kaiju_index.tgz

    tar -zxvf kaiju_index.tgz
fi

## if the functional annotation database hasn't yet been dowloaded, do that
# https://microbiomejournal.biomedcentral.com/articles/10.1186/s40168-020-00971-1
if [ ! -d functional_hierarchy ]
then
    cd ${dbdir}
    
    wget https://static-content.springer.com/esm/art%3A10.1186%2Fs40168-020-00971-1/MediaObjects/40168_2020_971_MOESM7_ESM.gz
    
    tar -xzf 40168_2020_971_MOESM7_ESM.gz
    
fi


EOF
