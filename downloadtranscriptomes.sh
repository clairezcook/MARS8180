#!/bin/bash
#SBATCH --job-name=taradownloadtranscriptome             
#SBATCH --partition=batch		                        
#SBATCH --ntasks=1			                           
#SBATCH --cpus-per-task=20                     
#SBATCH --mem=100gb			                           
#SBATCH --time=8:00:00  		                        
#SBATCH --output=/home/ccz99536/joboutput/transdownload.%j.out
#SBATCH --error=/home/ccz99536/joboutput/transdownload.%j.err
#SBATCH --mail-user=ccz99536@uga.edu                  
#SBATCH --mail-type=END,FAIL  

rawdata="/home/ccz99536/rawdata/"


urls=(
   "https://www.genoscope.cns.fr/tara/localdata/data/Geneset-v1/MATOU-v1.fna.gz", 
   "https://www.genoscope.cns.fr/tara/localdata/data/Geneset-v1/taxonomy.tsv.gz", 
   "https://www.genoscope.cns.fr/tara/localdata/data/Geneset-v1/metatranscriptomic_occurrences.tsv.gz"
)

# Loop through URLs and download each file
for url in "${urls[@]}"; do
    echo "Downloading $url..."
    curl -o "$rawdata/$(basename $url)" "$url"
done

echo "Download complete. Files are stored in $rawdata."
