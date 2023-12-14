# Generate-PRS

## Description
This Bash script is designed for processing a VCF file and generating a Polygenic Risk Score (PRS) for each individual in the file. It filters VCF files based on a provided GWAS table, converts the filtered VCF to PLINK format, and calculates PRS (Polygenic Risk Scores) using PLINK.

## Requirements
- bcftools
- htslib
- PLINK1.9 and PLINK2
- SLURM Workload Manager (for job memory and CPU allocation)

## Installation
Ensure that all required software (bcftools, htslib, PLINK1.9, PLINK2) is installed on your system. If you're using a cluster environment, these might already be available as modules. Also, change hard coded paths to PLINK executables to your correct path. If you are using a different GWAS table, you may need to change the numbers for the score PLINK function to select the correct columns in this order:
1. variant id
2. effect allele
3. effect size

## Usage
To run the script, provide it with two arguments: the input VCF file (compressed with .gz) and the GWAS table in text format. The VCF should be indexed as well.

```bash
./gwas_vcf_processor.sh <input_vcf>.vcf.gz <gwas_table>.txt
```

## Arguments
- <input_vcf>.vcf.gz - The input VCF file (compressed)
- <gwas_table>.txt - The GWAS table

## Output
The script will output a tsv file containing two columns: id and prs. The file is a list of the calculated PRS for each individual in the VCF file.

## References
- Bellenguez, C., Küçükali, F., Jansen, I.E., et al. (2022). New insights into the genetic etiology of Alzheimer’s disease and related dementias. *Nature Genetics*, 54, 412-436. [https://doi.org/10.1038/s41588-022-01024-z](https://doi.org/10.1038/s41588-022-01024-z)

## Contact
For support or contributions, please contact me at:

`jtaylor[at]hudsonalpha.org`
