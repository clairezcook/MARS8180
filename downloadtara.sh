#!/bin/bash
#SBATCH --job-name=taradownload              
#SBATCH --partition=batch		                        
#SBATCH --ntasks=1			                           
#SBATCH --cpus-per-task=20                     
#SBATCH --mem=100gb			                           
#SBATCH --time=8:00:00  		                        
#SBATCH --output=/home/ccz99536/joboutput/download.%j.out
#SBATCH --error=/home/ccz99536/joboutput/download.%j.err
#SBATCH --mail-user=ccz99536@uga.edu                  
#SBATCH --mail-type=END,FAIL  

rawdata="/home/ccz99536/rawdata/"
mkdir -p "$rawdata"

urls=(
   "https://zenodo.org/api/records/7551644/files-archive"
)

# Loop through URLs and download each file
for url in "${urls[@]}"; do
    echo "Downloading $url..."
    curl -o "$rawdata/$(basename $url)" "$url"
done

echo "Download complete. Files are stored in $rawdata."

## Ideally downloads data in tsv format of DADA2 output from zenodo