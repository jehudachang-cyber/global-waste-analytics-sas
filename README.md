# From Plates to Plastic: Global Waste Analytics Engineering (SAS)

## 📌 Project Overview
Rapid urbanization and shifting consumption patterns have created a global waste management crisis, making **UN Sustainable Development Goal 12 (SDG 12: Responsible Consumption and Production)** a critical framework for policy intervention[cite: 46]. Food waste alone accounts for 8–10% of global greenhouse gas emissions, while mismanaged plastic waste contaminates ecosystems for centuries[cite: 46].

This analytics engineering project implements an end-to-end **SAS data validation, transformation, and statistical analysis pipeline** across multi-country datasets spanning **2010 to 2019**[cite: 45, 47, 48]. Aligned with **SDG Target 12.3** (halving per capita food waste) and **Target 12.5** (substantially reducing waste generation), this study investigates decadal trends in plastic mismanagement, sectoral food waste distributions, and cross-stream waste management inefficiencies[cite: 45, 46].

---

## 🔍 Key Analytical Findings & Visual Insights

### 1. Global & Regional Shifts in Mismanaged Plastic Waste (2010 vs. 2019)
Comparing per capita mismanaged plastic waste (`kg/year`) between 2010 and 2019 reveals rapid escalations in countries where plastic consumption outpaced collection infrastructure[cite: 46, 49]:

| Rank | Country | 2010 Per Capita (kg) | 2019 Per Capita (kg) | Net Increase (kg/cap) |
| :---: | :--- | :---: | :---: | :---: |
| **1** | **Comoros** | 0.17 | 69.52 | **+69.35**[cite: 49] |
| **2** | **Trinidad and Tobago** | 0.19 | 52.43 | **+52.24**[cite: 49] |
| **3** | **Suriname** | 0.03 | 39.47 | **+39.45**[cite: 49] |
| **4** | **Philippines** | 0.06 | 37.23 | **+37.17**[cite: 49] |
| **5** | **Guyana** | 0.22 | 35.20 | **+34.98**[cite: 49] |
| **6** | **Tanzania** | 0.02 | 29.59 | **+29.57**[cite: 49] |
| **7** | **Libya** | 0.04 | 27.82 | **+27.78**[cite: 49] |
| **8** | **Uruguay** | 0.02 | 26.75 | **+26.73**[cite: 49] |
| **9** | **Malaysia** | 0.11 | 25.49 | **+25.38**[cite: 49] |
| **10** | **Tunisia** | 0.09 | 24.76 | **+24.67**[cite: 49] |

### 2. Sectoral Contributions to Food Waste Across Top Global Regions
Restructuring wide country-level estimates into a long-format sectoral model across the top 5 regions ($n = 135$ countries across the 5 regions) demonstrates that **households are consistently the dominant driver of food waste** (accounting for **63.7% to 69.9%** of regional totals), followed by Food Service (**18.7% to 23.5%**) and Retail (**10.2% to 12.8%**)[cite: 47, 50]:

| Global Region (Countries) | Household Share (%) | Household Mean (kg/yr) | Food Service Share (%) | Food Service Mean (kg/yr) | Retail Share (%) | Retail Mean (kg/yr) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Sub-Saharan Africa (48)** | **69.91%** | 101.6 | 19.24% | 28.0 | 10.85% | 15.8[cite: 50] |
| **Southern Europe (15)** | **69.59%** | 85.6 | 20.16% | 24.8 | 10.24% | 12.6[cite: 50] |
| **Western Asia (18)** | **69.51%** | 101.1 | 18.69% | 27.2 | 11.81% | 17.2[cite: 50] |
| **Northern Europe (12)** | **66.87%** | 74.7 | 21.64% | 24.2 | 11.48% | 12.8[cite: 50] |
| **Latin America & Caribbean (42)** | **63.67%** | 73.6 | 23.53% | 27.2 | 12.80% | 14.8[cite: 50] |

### 3. Cross-Stream Correlation & Regression Analysis (2019)
To test whether high food waste predicts high plastic mismanagement due to broader systemic infrastructure failures, we conducted Pearson correlation (`PROC CORR`) and Ordinary Least Squares (OLS) linear regression (`PROC REG`) across **$n = 130$ complete-case countries**[cite: 48, 51, 63]:
* **Model Fit & Significance:** $R^2 = 0.0219$ (Adjusted $R^2 = 0.0143$), $F(1, 128) = 2.87$, $p = 0.0927$[cite: 51].
* **Slope Estimate ($\beta_1$):** $+0.06580 \pm 0.03884$ ($t = 1.69$, $p = 0.0927$)[cite: 51].
* **Systems Conclusion:** While there is a slight positive trend, the relationship is statistically insignificant at the $\alpha = 0.05$ level and explains only **2.19%** of variance[cite: 51]. Food waste generation (driven largely by domestic consumption habits) and plastic waste mismanagement (driven by municipal collection and recycling infrastructure) do not move in lockstep—requiring targeted, stream-specific circular economy policies such as Extended Producer Responsibility (EPR) and standardized food date labeling[cite: 50, 51, 52].

---

## 🏗️ Analytics Engineering & SAS ETL Pipeline

1. **Raw Data Ingestion (`INFILE` & `INPUT`):**
   * Imported raw CSV files using `DSD`, `FIRSTOBS=2`, `TRUNCOVER`, and `LRECL=32767` to handle embedded commas and prevent string truncation, applying `comma32.` and `8.3` numeric informats[cite: 47, 58, 59].
2. **Automated Data Validation & False-Zero Imputation (`ARRAY` & `DO` Loops):**
   * Exploratory validation via `PROC MEANS` and `PROC CONTENTS` uncovered a critical data quality issue: missing national reporting values were erroneously coded as `0`, which would artificially deflate global and regional averages[cite: 47, 48, 55].
   * Implemented iterative `ARRAY` and `DO` loops across all numeric waste variables to systematically recode implausible zeros (`0`) to SAS missing values (`.`), preserving statistical integrity[cite: 47, 58, 59].
3. **Wide-to-Long Restructuring & SQL Aggregation (`DATA` Step & `PROC SQL`):**
   * Standardized region strings via `STRIP(UPCASE(Region))` and reshaped wide sectoral columns (`Household_estimate_kg`, `Retail_estimate_kg`, `Food_service_estimate_kg`) into a normalized long-format structure[cite: 47, 59, 60].
   * Used `PROC SQL` subqueries and inner/left joins to compute dynamic country counts per region and sectoral percentage contributions (`waste_pct`)[cite: 59, 60].
4. **Relational Merging & Complete-Case Filtering (`MERGE`):**
   * Sorted datasets alphabetically (`PROC SORT BY Country`) and performed a relational `MERGE` (`IN=a`, `IN=b`)[cite: 47, 48, 62].
   * Applied strict complete-case array filtering to remove observations with partial coverage prior to running `PROC CORR` and `PROC REG`[cite: 48, 62, 63].

```sas
/* Example: Iterative False-Zero Cleaning & Relational Complete-Case Merge */
DATA work.food_plastic;
    MERGE fwaste_clean(IN=a) pwaste_clean(IN=b);
    BY Country;
    ARRAY nums(*) Combined_figures_food Total_Mismanaged_P_2010 Total_Mismanaged_P_2019 
                  PerCapita_P_2010 PerCapita_P_2019;
    DO i = 1 TO DIM(nums);
        IF nums(i) = . THEN DELETE;
    END;
    DROP i;
RUN;
```

---

## 🛠️ Tech Stack
* **Language & Environment:** SAS (Base SAS, SAS Studio / SAS Viya)[cite: 41, 45]
* **SAS Procedures Utilized:** `DATA` Step (Arrays, Loops, Wide-to-Long Reshaping, Relational Merges), `PROC SQL`, `PROC MEANS`, `PROC SORT`, `PROC CONTENTS`, `PROC PRINT`, `PROC SGPLOT`, `PROC CORR`, `PROC REG`[cite: 47, 48, 58, 59, 60, 63].
* **Domain Alignment:** UN Sustainable Development Goal 12 (Targets 12.3, 12.4, & 12.5)[cite: 46, 55].

## 📁 Repository Structure
* `raw-dataset/`
  * `Food Waste data and research by country.csv`: Country-level food waste estimates across Household, Retail, and Food Service sectors (`kg/capita` and `tonnes/year`)[cite: 46, 47, 59].
  * `mismanaged_plasticwaste.csv`: Total and per capita mismanaged plastic waste (`2010` vs. `2019`)[cite: 46, 58].
* `rq1_plastic_waste_trends.sas`: SAS script for cleaning plastic waste data, computing 2010–2019 per capita deltas, and plotting top 10 country increases[cite: 58].
* `rq2_sector_food_waste.sas`: SAS script for wide-to-long data reshaping, `PROC SQL` regional aggregations, and clustered bar chart visualizations[cite: 59, 60].
* `rq3_food_plastic_regression.sas`: SAS script for dataset merging, complete-case filtering, Pearson correlation (`PROC CORR`), and OLS regression (`PROC REG`)[cite: 61, 62, 63].
* `README.md`: Comprehensive documentation of the ETL pipeline, statistical outputs, and SDG 12 policy recommendations[cite: 45, 52].
