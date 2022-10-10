#/usr/bin/env bash
#BSUB -G mvp022
#BSUB -q short
#BSUB -M 20000
#BSUB -J coxph[1-27]%2
#BSUB -o ./out/%J.%I.stdout
#BSUB -e ./err/%J.%I.stderr

date

# script to run early baseline univariable with race/ethnicity groups

groups=(eur eur eur afr afr afr his his his asn asn asn all all all unknown unknown unknown other other other native native native pacific pacific pacific)
group=${groups[$LSB_JOBINDEX-1]}

vars=(PC met PC_death PC met PC_death PC met PC_death PC met PC_death PC met PC_death PC met PC_death PC met PC_death PC met PC_death PC met PC_death)
var=${vars[$LSB_JOBINDEX-1]}

type=baseline
input=/group/research/mvp022/PHS/data/phs_files/phs290_eth_psa
output=/scratch/scratch10/mvp022/PHS290/data/univariable/ethnicity/early_$type
boot_input=/scratch/scratch10/mvp022/PHS290/data/bootstraps/eth/psa_early_$type
release=release4

# run with full dataset
mkdir -p  $output/single/
str=${type//_/.}
Rscript a1_test_get_perf_psa.R $input/$group.male.prs.psa.early.$str.$release.tsv $var cleaned_psa $output/single/$group.$release.$var.txt

# run with bootstraps
for i in {1..1000}
do 
echo $i
BSUB_CMD='bsub -J phs -G mvp022 -q short -n 1 -M 20000 -o ./out/%J.stdout -e ./err/%J.stderr'
$BSUB_CMD Rscript a1_test_get_perf_psa.R $boot_input/$group.$i.$var.tsv $var cleaned_psa $output/single/$group.$release.$i.$var.txt
done

# compile boostrapping results
mkdir $output/compiled
python compile-phs.py --dir $output/single/ --prefix $group --pc $var --out $output/compiled/$group.$var.ethnicity.compiled.bootstrap.tsv


date
