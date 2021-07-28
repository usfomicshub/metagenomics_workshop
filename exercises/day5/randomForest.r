## requires randomForest
# install.packages('randomForest')

## load the count data and rearrange it into a simple matrix

# without quote="", some lines break because the file has quotation characters within cells
counts_raw <- read.table('~/data/Metagenomics_workshop_USF/kaiju_species.tsv', header=T, sep='\t', quote="")
# clean up sample names but stripping all the extra info off of them
counts_raw[,1] <- gsub('_kaiju.*','',gsub('.*/','',counts_raw[,1]))
# transform the data from long format to wide
counts <- reshape(counts_raw, idvar='taxon_id', timevar='file', v.names='reads', direction='wide', drop=c('percent','taxon_name'))
# sample/taxon combinations that had no data in the original long format get NA's in the wide matrix. These are actually zeros, so let's change those
counts[is.na(counts)] <- 0
# make sure the taxon IDs look like character vectors by adding text, just to be safe, and make these rownames
rownames(counts) <- paste0('taxon_id_',counts[,1])
# get rid of the taxon ids from the actual data of the matrix
counts <- counts[,-1]
# clean up the sample names again
colnames(counts) <- sub('reads.','',colnames(counts))
# tell R that the data are all uniformly numeric rather than treating each column as an independent factor
counts <- as.matrix(counts)
# filter out taxa that are extremely rare
counts <- counts[apply(counts,1,function(x) sum(x>5)>5),]

##

## load the sample metadata and make sure the variables have the right types

meta <- read.table('~/data/Metagenomics_workshop_USF/meta_data_sra_acc.tsv', header=T, sep='\t')
rownames(meta) <- meta$Sample
# make sure the metadata table has samples in the same order as the counts table
meta <- meta[colnames(counts),]
#
meta$Gender <- as.factor(meta$Gender)
# there are three factor levels for 'group', and it makes most biological sense to compare to the baseline of 'Term'
meta$Group <- relevel(as.factor(meta$Group), 'Term')
meta$Individual <- as.factor(meta$Individual)
meta$DeliveryMode <- as.factor(meta$DeliveryMode)
meta$EnteralFeeds_2mo <- as.factor(meta$EnteralFeeds_2mo)
# some values of 'Breastmilk' have extra spaces in them for some reason, so we'll clean those up
levels(meta$EnteralFeeds_2mo)[gsub(' ', '', levels(meta$EnteralFeeds_2mo)) == 'Breastmilk'] <- 'Breastmilk'

##

# first we need to make our data easier for our human brains to understand, by converting to relative abundance
relabund <- apply(counts,2,function(x) x/sum(x))


library(randomForest)


res <- randomForest(y=meta$Group, x=t(counts), importance=T, mtry = ceiling(nrow(counts) / 3))

imp <- res$importance
imp <- imp[order(imp[,'MeanDecreaseAccuracy']),]

topdiff <- rownames(imp)[[2]]

relabund_0na <- relabund
relabund_0na[relabund_0na==0] <- NA
merged_rel_0na <- cbind(meta,t(relabund_0na))

beanplot::beanplot(as.formula(paste0(topdiff,' ~ Group')), merged_rel_0na, log='y', las=2, cex.axis=0.5)
