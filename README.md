# Morningness and Related Traits: SNP-heritability, Genetic Correlation, and Causal Effects
**2025 Fall STAT 605 Final Project**

*Che Tian, Edward Peng, Huajun Gao, Thomas Li, Shu Cao*

## Questions of Interest
Morningness describes an individual’s preference of getting up early. Among 9 sleep/health traits (BMI, height, obesity, depression, education attainment, blood pressure, smoking, insomnia, and snoring) around morningness, what are  

- SNP-heritability of each trait,
- pairwise genetic correlations,
- causal effects of morningness?
<img src="https://github.com/user-attachments/assets/cfdd5bb4-9caa-49d9-848c-e88b9a2e95e1" width="400">


## Data
We plan to collect GWAS data of 10 traits we previously discussed. These GWAS data can be obtained from GWAS Catalog (https://www.ebi.ac.uk/gwas/home). 

<img src="https://github.com/user-attachments/assets/73bd0f11-1227-4f68-8f73-774b1bbc90cf" width="400">


## Methods
### 1. SNP-Heritability via LD Score Regression
SNP heritability quantifies how much of the trait variance can be explained by all common SNPs, it can be computed as the regression slope of LD Score Regression.

### 2. Pairwise Genetic Correlation via LD Score Regression
Genetic correlation measures the extent to which the same genetic variants influence both traits. It can also be computed by LD score regression.

### 3. Mendelian Randomization
Mendelian Randomization uses significant genetic variants as instrumental variables to infer the causal effect of an exposure on an outcome.

