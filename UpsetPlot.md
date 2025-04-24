#### Upset plot ####
Upset plots are a great tool to visualize overlapping data within a dataset. Similar to a Venn diagram, an upset plot will show what overlaps between defined differences in your dataset. To learn more about how these plots work, see https://upset.app/. An example plot is below where we can see that the data present in multiple different samples, some data overlap between 2 or 3 of the samples while others are just present in 1. This upset plot helps us visualize how similar and/or different these datasets are.

![concept_4_sorting](https://github.com/user-attachments/assets/c78b4b4b-8c79-4939-9748-7770b25858ae)


To get started, first load in packages to R. 
```
library(DESeq2)
library(ComplexUpset)
library(dplyr)
```
# Load in DESeq data performed in class
We need the dds object generated in class (see week 15b)

```
dds <- DESeqDataSetFromMatrix(countData = gene_abundance_matrix_rounded,
                              colData = metadata,
                              design = ~ location + notes)



dds <- DESeq(dds)
```
# Define contrasts you want to compare
Contrasts can include multiple different variables within your metadata. Here we'll just compare between locations (San Diego vs. Honolulu) and depth (surface vs. deep chlorophyll maximum)
```
contrast_list <- list(
  location = c("location", "San Diego", "Honolulu"),
  depth = c("notes", "surface_water", "deep_chlorophyll_maximum")
)
```
# Subset by genes that are significantly (p<0.5) different between location and/or depth
```
get_sig_genes <- function(dds, contrast) {
  res <- results(dds, contrast = contrast)
  sig <- res[which(res$padj < 0.05 & !is.na(res$padj)), ]
  return(rownames(sig))
}
```
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
