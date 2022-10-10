#!/usr/bin/env bash

# script to extract PHS290 SNPs
# description: plink recode 299 PHS SNPs

plink2=/group/tools/plink2a/plink2a_dev_20190429
geno=/data/data1/mvp022/mvp_imputed/Release4_PGEN
extract=/group/research/mvp022/PHS/data/snps/extract_phs290_snp_list.txt
output_dir=/scratch/scratch2/mvp022/phs/release4/phs290

date

BSUB_CMD='bsub -J phs -G mvp022 -q short_bpgen -n 1 -M 8000 -R "rusage[mem=5600]" -o ./out/%J.stdout -e ./err/%J.stderr'

pgen_info () {

pfile=$(echo "${1}" | rev | cut -d"." -f 2- | rev)
out=$(echo "${1}" | rev | cut -d"/" -f 1 | cut -d"." -f 2- | rev)
echo $pfile
echo $out

$BSUB_CMD $plink2 --pfile $pfile --threads 1 --memory 8000 --extract $extract --recode A --out $output_dir/$out

}

for file in $(ls "${geno}"/*/*.pgen)
do
pgen_info $file
done

date


