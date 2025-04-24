#### Upset plot ####
library(DESeq2)
library(ComplexUpset)
library(dplyr)


# Define your contrasts of interest
contrast_list <- list(
  location = c("location", "San Diego", "Honolulu"),
  depth = c("notes", "surface_water", "deep_chlorophyll_maximum")
)

# Extract significant gene lists per contrast (adjust p-value < 0.05)
get_sig_genes <- function(dds, contrast) {
  res <- results(dds, contrast = contrast)
  sig <- res[which(res$padj < 0.05 & !is.na(res$padj)), ]
  return(rownames(sig))
}

# Get DE genes for each contrast
sig_location <- get_sig_genes(dds, contrast_list$location)
sig_notes <- get_sig_genes(dds, contrast_list$depth)

# Create a binary presence/absence data frame for UpSet plotting
all_genes <- unique(c(sig_location, sig_notes))
upset_data <- data.frame(
  gene = all_genes,
  location = all_genes %in% sig_location,
  notes = all_genes %in% sig_notes
)

# UpSet plot
ComplexUpset::upset(
  upset_data,
  intersect = c("location", "notes"),
  name = "DE Genes",
  base_annotations=list(
    'Intersection size'=intersection_size()
  )
)

![image](https://github.com/user-attachments/assets/633bc6ac-8ff8-453c-b34d-f2c49433312e)
