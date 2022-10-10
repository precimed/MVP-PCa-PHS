#!/usr/bin/env bash
#BSUB -J phs_bootstrap
#BSUB -G mvp022
#BSUB -q short
#BSUB -M 20000
#BSUB -J phs_bootstrap[4-6]
#BSUB -o ./out/%J.%I.stdout
#BSUB -e ./err/%J.%I.stderr

date

# script to run PHS290 multivariable (FH, group) with race/ethnicity and genetic ancestry groups

groups=(all all all all all all all)
group=${groups[$LSB_JOBINDEX-1]}

vars=(PC met PC_death PC met PC_death)
var=${vars[$LSB_JOBINDEX-1]}

cats=(anc anc anc eth eth eth)
cat=${cats[$LSB_JOBINDEX-1]}

input=/group/research/mvp022/PHS/data/phs_files/phs290_$cat
output=/scratch/scratch10/mvp022/PHS290/data/phs290_$cat\_multi
release=release4

mkdir -p $output
mkdir -p $output/single
mkdir -p $output/compiled

# run with full dataset
Rscript a1_test_get_perf_multi_fh_$cat.R $input/$group.male.prs.fh.$release.tsv $var $output/single/$group.$release.$var.txt

# run with bootstraps
for i in {1..1000}
do 
echo $i
BSUB_CMD='bsub -J phs -G mvp022 -q short -n 1 -M 8000 -o ./out/%J.stdout -e ./err/%J.stderr'
$BSUB_CMD Rscript a1_test_get_perf_multi_fh_$cat.R $output/$group.male.$i.$var.tsv $var $output/single/$group.$release.$i.$var.txt
rm $output/$group.male.$i.$var.tsv
done

# compile boostrapping results
python compile-phs.py --dir $output/single/ --prefix $group --pc $var --out $output/compiled/$group.$var.compiled.bootstrap.tsv

date

