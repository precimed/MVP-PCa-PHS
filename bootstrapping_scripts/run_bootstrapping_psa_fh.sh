#!/usr/bin/env bash
#BSUB -G mvp022
#BSUB -q medium
#BSUB -M 2500
#BSUB -J bootstrap[1-3]
#BSUB -o ./out/%J.%I.stdout
#BSUB -e ./err/%J.%I.stderr

date

# boostrapping script for psa analysis requiring multivariable covariates

groups=(all all all)
group=${groups[$LSB_JOBINDEX-1]}

vars=(PC met PC_death)
var=${vars[$LSB_JOBINDEX-1]}

type=psa_fh
input=/group/research/mvp022/PHS/data/phs_files/phs290_eth
output=/scratch/scratch10/mvp022/PHS290/data/bootstraps/eth/$type/$group

mkdir -p $output
	
sed "s|INSERTFILE|${input}/${group}.male.prs.fh.psa.release4.tsv|g" bootstrap.sh > bootstrap.$group.$type.$var.sh
sed -i "s|INSERTVAR|${var}|g" bootstrap.$group.$type.$var.sh
sed -i "s|INSERTOUT|${output}|g" bootstrap.$group.$type.$var.sh
	
bsub < bootstrap.$group.$type.$var.sh

type=psa_early_baseline
input=/group/research/mvp022/PHS/data/phs_files/phs290_eth
output=/scratch/scratch10/mvp022/PHS290/data/bootstraps/eth/$type/$group

mkdir -p $output

sed "s|INSERTFILE|${input}/${group}.male.prs.fh.psa.early.baseline.release4.tsv|g" bootstrap.sh > bootstrap.$group.$type.$var.sh
sed -i "s|INSERTVAR|${var}|g" bootstrap.$group.$type.$var.sh
sed -i "s|INSERTOUT|${output}|g" bootstrap.$group.$type.$var.sh

bsub < bootstrap.$group.$type.$var.sh

date
