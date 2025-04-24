# Upset plot
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
# Edit factor levels to make contrasts easier
We are going to ultimately compare genes found in San Diego surface and DCM water to Honolulu surface and DCM water. We're going to create a group in our dds dataframe for each of our comparisons (San Diego surface, San Diego DCM, Honolulu surface, and Honolulu DCM). 

```
colData(dds)$site_depth <- factor(paste(dds$location, dds$notes, sep = "_"))
colData(dds)$group <- with(colData(dds), paste(location, notes, sep = "_"))
colData(dds)$group <- factor(colData(dds)$group)
design(dds) <- ~ group
dds$group <- relevel(dds$group, ref = "San_Diego_surface_water")
dds <- DESeq(dds)
resultsNames(dds)
```
# Define contrasts you want to compare
Contrasts can include multiple different variables within your metadata. Here we'll just compare between locations (San Diego vs. Honolulu) and depth (surface vs. deep chlorophyll maximum)
```
contrast_list <- list(
  SD_surface_vs_DCM = c("group", "San_Diego_surface_water", "San_Diego_deep_chlorophyll_maximum"),
  HNL_surface_vs_DCM = c("group", "Honolulu_surface_water", "Honolulu_deep_chlorophyll_maximum"),
  SD_surface_vs_HNL_surface = c("group", "San_Diego_surface_water", "Honolulu_surface_water"),
  SD_DCM_vs_HNL_DCM = c("group", "San_Diego_deep_chlorophyll_maximum", "Honolulu_deep_chlorophyll_maximum")
)
```
# Subset by genes that are significantly (p<0.5) different between location and/or depth
We want to compare genes that were significantly different between location and/or depth so we can create a function that will search through our dds and look for significant relationships between our defined contrasts. San Diego surface has to be added back in as it was used for the reference earlier. 
```

get_sig_genes <- function(dds, contrast) {
  res <- results(dds, contrast = contrast)
  sig <- res[which(res$padj < 0.05 & !is.na(res$padj)), ]
  return(rownames(sig))
}

sig_lists <- lapply(contrast_list, function(contrast) get_sig_genes(dds, contrast))
names(sig_lists) <- names(contrast_list)
all_genes <- unique(unlist(sig_lists))


sig_SanDiego_surface <- unique(unlist(sig_lists))
sig_lists$SanDiego_surface <- sig_SanDiego_surface
all_genes <- unique(unlist(sig_lists))

```
# Create a binary presence/absence data frame for UpSet plotting
UpSet plots require binary presence/absence data. To create that, we'll create a dataframe specific to the Upset plot looking at our significant contrasts. 

```
upset_data <- data.frame(
  gene = all_genes,
  SanDiego_surface = all_genes %in% sig_lists$SanDiego_surface,
  SanDiego_DCM     = all_genes %in% sig_lists$SanDiego_DCM,
  Honolulu_surface = all_genes %in% sig_lists$Honolulu_surface,
  Honolulu_DCM     = all_genes %in% sig_lists$Honolulu_DCM
)
```
# UpSet plot
Finally, we can plot the data! 21 genes are significantly shared between San Diego depths. Interestingly, no genes were shared only by Honolulu depths, meaning that these samples are not distinct from other regions. 

```
ComplexUpset::upset(
  upset_data,
  intersect = c("SanDiego_surface", "SanDiego_DCM", "Honolulu_surface", "Honolulu_DCM"),
  name = "DE Genes",
  base_annotations = list('Intersection size' = intersection_size())
)
```
![image](https://github.com/user-attachments/assets/2da9675f-8c8d-4351-9e79-c6e88a6c1ef0)

