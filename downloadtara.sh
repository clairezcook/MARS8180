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

# Array of FTP URLs for the desired datasets
urls=(
    "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR598/ERR598972/ERR598972.fastq.gz"
    "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR599/ERR599021/ERR599021.fastq.gz"
    # Add more URLs as needed
)

# Loop through URLs and download each file
for url in "${urls[@]}"; do
    echo "Downloading $url..."
    curl -o "$rawdata/$(basename $url)" "$url"
done

echo "Download complete. Files are stored in $rawdata."