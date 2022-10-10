#!/usr/bin/env bash
#BSUB -G mvp022
#BSUB -q medium
#BSUB -M 2500
#BSUB -J bootstrap[4-27]%3
#BSUB -o ./out/%J.%I.stdout
#BSUB -e ./err/%J.%I.stderr

date

# boostrapping script for PHS290 analysis and medicare annotation

groups=(all all all eur eur eur afr afr afr his his his asn asn asn native native native other other other pacific pacific pacific unknown unknown unknown)
group=${groups[$LSB_JOBINDEX-1]}

vars=(PC met PC_death PC met PC_death PC met PC_death PC met PC_death PC met PC_death PC met PC_death PC met PC_death PC met PC_death PC met PC_death)
var=${vars[$LSB_JOBINDEX-1]}

type=phs
input=/group/research/mvp022/PHS/data/phs_files/phs290_eth
output=/scratch/scratch10/mvp022/PHS290/data/bootstraps/eth/$type/$group

mkdir -p $output
	
sed "s|INSERTFILE|${input}/${group}.male.prs.release4.tsv|g" bootstrap.sh > bootstrap.$group.$type.$var.sh
sed -i "s|INSERTVAR|${var}|g" bootstrap.$group.$type.$var.sh
sed -i "s|INSERTOUT|${output}|g" bootstrap.$group.$type.$var.sh
	
bsub < bootstrap.$group.$type.$var.sh

date
