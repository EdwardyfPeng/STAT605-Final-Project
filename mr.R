library(data.table)
library(dplyr)
library(TwoSampleMR)
library(MendelianRandomization)
setwd("/Users/tianche/Desktop/STAT605-Final-Project")
chronotype <- fread("./data/chronotype.tsv")
# create left column according to the right column
chronotype = chronotype %>%
  mutate(
    beta_exp = BETA, 
    p = P,
    se_exp = SE,
  ) %>%
  select(SNP, CHR, BP, A1, A2, beta_exp, se_exp, p)

# Strong instruments (P < 5e-8)
strong <- chronotype %>% filter(p < 5e-8)

# Format for clumping
formatted <- strong %>%
  rename(
    pval.exposure = p,
    beta.exposure = beta_exp,
    se.exposure = se_exp,
    effect_allele.exposure = A1,
    other_allele.exposure = A2
  ) %>%
  mutate(
    chr_name = CHR,
    chrom_start = BP,
    id.exposure = "Chronotype",
    samplesize.exposure = 449734 
  )

#==============================
# LD Clumping (locally)
#==============================
Chronotype_clumped <- clump_data(
  formatted,
  clump_kb = 10000,
  clump_r2 = 0.001,
  bfile = "1kg_hm3_QCed_noM/1kg_hm3_QCed_noM",
  plink_bin = "plink/plink"
)
Chronotype_clumped$exposure <- "Chronotype"

fwrite(
  Chronotype_clumped,
  file = "./txt/chronotype_clumped.txt",
  sep = "\t"
)
#==============================
# Outcome: other traitss
#==============================
outcome <- fread(paste0("./data/","insomnia",".tsv"))
outcome = outcome %>%
  mutate(
    outcome = "insomnia",
    id.outcome = "insomnia", 
  ) %>%
  rename(
    beta.outcome = BETA,
    se.outcome = SE,
    effect_allele.outcome = A1,
    other_allele.outcome = A2
  ) %>%
  select(SNP, beta.outcome, se.outcome, effect_allele.outcome, other_allele.outcome, outcome, id.outcome)


#==============================
# Harmonise exposure and outcome
#==============================
harmonised <- harmonise_data(
  exposure_dat = Chronotype_clumped,
  outcome_dat = outcome,
  action = 2
)

# MRInput 
mr_obj <- mr_input(
  bx = harmonised$beta.exposure,
  bxse = harmonised$se.exposure,
  by = harmonised$beta.outcome,
  byse = harmonised$se.outcome,
  snps = harmonised$SNP
)

# IVW 
res_ivw <- mr_ivw(mr_obj)

# run Egger regression
res_egger <- mr_egger(mr_obj)

# IVW result
sink(paste0("./txt/ivw_result_Chronotype_to_", "insomnia", "_strongIV.txt"))  
cat("Chronotype ➜ ", "insomnia", " - IVW Result\n\n")  
cat("Number of SNPs:   ", res_ivw@SNPs, "\n")
cat("Estimate:         ", res_ivw@Estimate, "\n")
cat("Std. Error:       ", res_ivw@StdError, "\n")
cat("95% CI:           (", res_ivw@CILower, ", ", res_ivw@CIUpper, ")\n")
cat("P-value:          ", res_ivw@Pvalue, "\n")
cat("Heterogeneity Q:  ", res_ivw@Heter.Stat[1], "\n")
cat("Heterogeneity p:  ", res_ivw@Heter.Stat[2], "\n")
cat("F-statistic:      ", res_ivw@Fstat, "\n")
sink()

# Egger result
sink(paste0("./txt/egger_result_Chronotype_to_", "insomnia", "_strongIV.txt"))
cat("Chronotype ➜ ", "insomnia", " - Egger Regression Result\n\n")
cat("Number of SNPs:   ", res_egger@SNPs, "\n")
cat("Causal Estimate:  ", res_egger@Estimate, "\n")
cat("Std. Error:       ", res_egger@StdError.Est, "\n")
cat("P-value:          ", res_egger@Pvalue.Est, "\n")
cat("Intercept (pleiotropy): ", res_egger@Intercept, "\n")
cat("Intercept SE:     ", res_egger@StdError.Int, "\n")
cat("Intercept P-value:", res_egger@Pvalue.Int, "\n")
sink()


# IVW scatter plots
top_df <- harmonised %>%
  arrange(se.exposure) %>%
  slice(1:500)  # Top 500 SNPs

top_mr_obj <- mr_input(
  bx = top_df$beta.exposure,
  bxse = top_df$se.exposure,
  by = top_df$beta.outcome,
  byse = top_df$se.outcome,
  snps = top_df$SNP
)

library(ggplot2)

p <- mr_plot(top_mr_obj, error = TRUE, line = "ivw", interactive = FALSE)

png(
  filename = paste0("./png/ivw_plot_top500_Chronotype_to_", "insomnia", "_labeled.png"),
  width = 8,        
  height = 6,
  units = "in",
  res = 300         # 300 dpi
)

print(
  p +
    labs(
      x = "SNP effect on Chronotype",
      y = paste0("SNP effect on ", "insomnia"),
      title = "IVW Scatter Plot"
    ) +
    theme_minimal()
)

dev.off()


