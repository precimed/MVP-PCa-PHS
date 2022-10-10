#!/usr/bin/env bash
#BSUB -G mvp022
#BSUB -q medium
#BSUB -M 2000
#BSUB -J phs[1-3]
#BSUB -o ./out/%J.%I.stdout
#BSUB -e ./err/%J.%I.stderr

date

# script to run multivariable (FH, group) with race/ethnicity groups

groups=(all all all)
group=${groups[$LSB_JOBINDEX-1]}

vars=(PC met PC_death)
var=${vars[$LSB_JOBINDEX-1]}

script=fh_eth
input=/group/research/mvp022/PHS/data/phs_files/phs290_eth
output=/scratch/scratch10/mvp022/PHS290/results/multivariable/ethnicity/$script
boot_input=/scratch/scratch10/mvp022/PHS290/bootstraps/eth/phs_fh_eth
release=release4

mkdir -p $output
mkdir -p $output/single
mkdir -p $output/compiled

# run with full dataset
Rscript a1_test_get_perf_multi_$script.R $input/$group.male.prs.fh.$release.tsv $var $output/single/$group.$release.$var.txt

# run with bootstraps
for i in {1..1001}
do 
echo $i
BSUB_CMD='bsub -J phs -G mvp022 -q short -n 1 -M 20000 -o ./out/%J.stdout -e ./err/%J.stderr'
$BSUB_CMD Rscript a1_test_get_perf_multi_$script.R $boot_input/$group.male.$i.$var.tsv $var $output/single/$group.$release.$i.$var.txt
done

# compile boostrapping results
python compile-phs.py --dir $output/single/ --prefix $group --pc $var --out $output/compiled/$group.$var.compiled.bootstrap.tsv

date
