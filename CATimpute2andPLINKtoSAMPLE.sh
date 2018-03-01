#!/bin/sh

#This script is for preparing post-imputed (using MIGNOT LAB IMPUTATION PIPELINE OUTPUTS) files snptest
#have the script in the directory above the directory containing the imputed files (e.g. 500K_imputed)

module load plink/1.90

echo "Enter name of study population (e.g. WSC, MrOS, APOE, EUR), followed by [ENTER]: "
read study

echo "Enter number of genotype/chip/array pseudocohorts (e.g. Ill, Affy6, 500K), followed by [ENTER]: "
read cohortnum

# gather genotype/chip/array pseudocohort(s) names into an array called "list"
for i in {1..$cohortnum}
do
	echo "Enter name(s) of genotype/chip/array pseudocohort(s) (e.g. Ill, Affy6, 500K), separated by spaces, followed by [ENTER]: "
	read cohortnames
	list=($cohortnames)
done

workDir=$PWD

for k in "${list[@]}"
do
	mkdir -p $workDir/${k}_imputed4snptest
	
	mkdir -p $workDir/${k}_imputed/impute_info
	
	for i in {1..22}
	do
		if [[ ${#i} -lt 2 ]] ; then
			inputNo="0${i}"
		else
			inputNo="${i}"
		fi
		plink --bfile $workDir/${k}_imputed/${k}_NOdups_aligned_CHR${i} --maf 0.05 --allow-no-sex --recode oxford --out $workDir/${k}_imputed4snptest/chr${inputNo}_${k}_${study}_impute2ed
		rm -rf $workDir/${k}_imputed4snptest/*.gen
		mv $workDir/${k}_imputed/CHR${i}_${k}_NOdups_aligned.*_* $workDir/${k}_imputed/impute_info/
		cat $workDir/${k}_imputed/CHR${i}_${k}_NOdups_aligned.* > $workDir/${k}_imputed4snptest/chr${inputNo}_${k}_${study}_impute2ed.gen
		sed -i "s/---/${i}/" $workDir/${k}_imputed4snptest/chr${inputNo}_${k}_${study}_impute2ed.gen
	done
done
