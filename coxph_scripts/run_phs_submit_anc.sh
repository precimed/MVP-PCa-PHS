#!/usr/bin/env bash
#BSUB -J phs_bootstrap
#BSUB -G mvp022
#BSUB -q medium
#BSUB -M 20000
#BSUB -J phs_bootstrap[1-3]
#BSUB -o ./out/%J.%I.stdout
#BSUB -e ./err/%J.%I.stderr

date

# script to run PHS290 univariable for genetic ancestry groups

groups=(all all all EUR EUR EUR AFR AFR AFR AMR AMR AMR CSA CSA CSA EAS EAS EAS MID MID MID)
group=${groups[$LSB_JOBINDEX-1]}

vars=(PC met PC_death PC met PC_death PC met PC_death PC met PC_death PC met PC_death PC met PC_death PC met PC_death)
var=${vars[$LSB_JOBINDEX-1]}

input=/group/research/mvp022/PHS/data/phs_files/phs290_anc
output=/scratch/scratch10/mvp022/PHS290/data/swc_false_anc
release=release4

# run with full dataset
mkdir -p  $output/single/
Rscript a1_test_get_perf.R $input/$group.male.prs.$release.tsv $var $output/single/$group.$release.$var.txt

# run with bootstraps
for i in {1..1000}
do 
BSUB_CMD='bsub -J phs -G mvp022 -q medium -n 1 -M 8000 -o ./out/%J.stdout -e ./err/%J.stderr'
$BSUB_CMD Rscript a1_test_get_perf_noweight.R $output/$group.male.$i.$var.tsv $var $output/single/$group.$release.$i.$var.txt
rm $output/$group.male.$i.$var.tsv
done

# compile boostrapping results
mkdir $output/compiled
python compile-phs.py --dir $output/single/ --prefix $group --pc $var --out $output/compiled/$group.$var.genetic.ancestry.compiled.bootstrap.tsv

date
