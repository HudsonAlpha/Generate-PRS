#!/bin/bash

# check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
	echo "Usage: $0 <input_vcf>.vcf.gz <gwas_table>.txt"
	exit 1
fi

module load cluster/bcftools
module load cluster/htslib

# extract variables from script arguments
input_vcf=$1
input_vcf_basename=$(basename "$1" .vcf.gz)
gwas_table=$2

# calculate memory for plink commands (80% of job memory)
job_mem=$SLURM_MEM_PER_NODE
job_mem=$((job_mem * 80 / 100))

# process the GWAS table to create a filter file for bcftools
tail -n +2 $gwas_table | while IFS=$'\t' read -r rsid chromosome position risk_allele other_allele beta se p_value risk_allele_freq maf; do
	# create bed file to filter vcf
	let "start = position - 1"
	printf "chr%s\t%d\t%d\n" "${chromosome}" "${start}" "${position}"
done | sort -k1,1 -k2,2n > vcf_filter.bed

# filter the input vcf for regions from the GWAS table
bcftools view -R vcf_filter.bed ${input_vcf} -Oz -o ${input_vcf_basename}.filtered.vcf.gz --threads ${SLURM_JOB_CPUS_PER_NODE}

# index the filtered vcf
tabix -p vcf ${input_vcf_basename}.filtered.vcf.gz

# convert the filtered vcf to PLINK format with PLINK2
/cluster/home/jtaylor/software/plink2_v2/plink2 \
	--vcf ${input_vcf_basename}.filtered.vcf.gz \
	--make-bed \
	--out ${input_vcf_basename}.filtered \
	--set-missing-var-ids @:#:\$r:\$a \
	--const-fid \
	--new-id-max-allele-len 50 truncate \
	--vcf-half-call missing \
	--max-alleles 2 \
	--memory ${job_mem}

# calculate prs using PLINK1.9
/cluster/home/jtaylor/software/plink1.9/plink \
	--bfile ${input_vcf_basename}.filtered \
	--score ${gwas_table} 1 4 6 header no-mean-imputation \
	--out ${input_vcf_basename}.filtered.prs \
	--memory ${job_mem}

# create an output file with id and prs
awk 'BEGIN {OFS="\t"}
	NR==1 {print "id", "prs"}
	NR>1 {print $2, $6}' ${input_vcf_basename}.filtered.prs.profile > ${input_vcf_basename}_prs.tsv

# clean up intermediate files
rm ${input_vcf_basename}.filtered*
rm vcf_filter.bed
