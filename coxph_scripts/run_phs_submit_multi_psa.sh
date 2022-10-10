#!/usr/bin/env bash
#BSUB -G mvp022
#BSUB -q short
#BSUB -M 20000
#BSUB -J coxph[1-9]%2
#BSUB -o ./out/%J.%I.stdout
#BSUB -e ./err/%J.%I.stderr

date

# script to run PHS290 multivariable (psa, FH, group) with race/ethnicity

groups=(all all all all all all all all all)
group=${groups[$LSB_JOBINDEX-1]}

vars=(PC met PC_death PC met PC_death PC met PC_death)
var=${vars[$LSB_JOBINDEX-1]}

types=(psa_test psa_test psa_test psa_test_yr psa_test_yr psa_test_yr psa_first_year psa_first_year psa_first_year)
type=${types[$LSB_JOBINDEX-1]}

input=/group/research/mvp022/PHS/data/phs_files/phs290_eth_psa
output=/scratch/scratch10/mvp022/PHS290/data/multivariable/$type
boot_input=/scratch/scratch10/mvp022/PHS290/data/bootstraps/eth/psa_fh
release=release4

echo $echo
echo $var

# run with full dataset
mkdir -p  $output/single/
Rscript a1_test_get_perf_multi_fh_eth_psa.R $input/$group.male.prs.fh.psa.$release.tsv $var $type $output/single/$group.$release.$var.txt

# run with bootstraps
for i in {1..1000}
do 
echo $i
BSUB_CMD='bsub -J phs -G mvp022 -q short -n 1 -M 20000 -o ./out/%J.stdout -e ./err/%J.stderr'
$BSUB_CMD Rscript a1_test_get_perf_multi_fh_eth_psa.R $boot_input/$group.$i.$var.tsv $var $type $output/single/$group.$release.$i.$var.txt
done

# compile boostrapping results
mkdir $output/compiled
python compile-phs.py --dir $output/single/ --prefix $group --pc $var --out $output/compiled/$group.$var.ethnicity.compiled.bootstrap.tsv

date
