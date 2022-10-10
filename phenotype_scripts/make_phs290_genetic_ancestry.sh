#!/usr/bin/env bash
#BSUB -G mvp022
#BSUB -q medium
#BSUB -M 20000
#BSUB -J make_phs[1-6]
#BSUB -o ../out/%J.%I.stdout
#BSUB -e ../err/%J.%I.stderr

date

groups=(AFR AMR CSA EAS EUR MID)
group=${groups[$LSB_JOBINDEX-1]}

input=/group/research/mvp022/PHS/data/raw_files
phs_input=/data/data1/mvp022/Other_Data/20210609/phs290.csv
output=/group/research/mvp022/PHS/data/phs_files/phs290_anc
mkdir $output

pts=/group/research/mvp022/data/ancestry_groups/$group.males.txt

echo "release4"

clinical=/group/research/mvp022/PHS/data/phenotypes/phs.pheno.tsv

python phs_calculate.py --major Ref --minor Effect --phs_file $phs_input --raw $input/combined.phs290.release4.raw --phs beta --clinical $clinical --patients $pts --out $output/$group.male.prs.release4.tsv

clinical=/group/research/mvp022/PHS/data/phenotypes/phs.pheno.fh.tsv

python phs_calculate.py --major Ref --minor Effect --phs_file $phs_input --raw $input/combined.phs290.release4.raw --phs beta --clinical $clinical --patients $pts --out $output/$group.male.prs.fh.release4.tsv

clinical=/group/research/mvp022/PHS/data/phenotypes/phs.pheno.psa.tsv

python phs_calculate.py --major Ref --minor Effect --phs_file $phs_input --raw $input/combined.phs290.release4.raw --phs beta --clinical $clinical --patients $pts --out $output/$group.male.prs.psa.release4.tsv

clinical=/group/research/mvp022/PHS/data/phenotypes/phs.pheno.fh.psa.tsv

python phs_calculate.py --major Ref --minor Effect --phs_file $phs_input --raw $input/combined.phs290.release4.raw --phs beta --clinical $clinical --patients $pts --out $output/$group.male.prs.fh.psa.release4.tsv

clinical=/group/research/mvp022/PHS/data/phenotypes/phs.pheno.early.baseline.tsv

python phs_calculate.py --major Ref --minor Effect --phs_file $phs_input --raw $input/combined.phs290.release4.raw --phs beta --clinical $clinical --patients $pts --out $output/$group.male.prs.psa.early.baseline.release4.tsv

clinical=/group/research/mvp022/PHS/data/phenotypes/phs.pheno.fh.early.baseline.tsv

python phs_calculate.py --major Ref --minor Effect --phs_file $phs_input --raw $input/combined.phs290.release4.raw --phs beta --clinical $clinical --patients $pts --out $output/$group.male.prs.fh.psa.early.baseline.release4.tsv

date
