# Project/scripts/Data_Cleaning_NA/data_cleaning_na.R
# ------------------------------------------------------------------
#  PROJECT DATA CLEANER (NA)
# ------------------------------------------------------------------
# Purpose:
#   - Document NA values within the data file.
# ------------------------------------------------------------------

# ---------------------------
# Install Dependencies
# ---------------------------
library(tidyverse)
library(arrow)

# ------------------------------------------------------------------
# Install base unmodified bid data as ad_data.
# ------------------------------------------------------------------
base_data_path = file.path(getwd(), "Project/scripts/load_data.R")
source(base_data_path)

# ------------------------------------------------------------------
#  NOTED NA VALUES
# ------------------------------------------------------------------
# List of KEYS with respective NA value count.
na_by_col <- colSums(is.na(ad_data))

# List of KEYS that have NA values.
cols_with_na <- names(na_by_col[na_by_col > 0])

# Returns tibble of rows that contain NA values.
rows_with_na <- ad_data %>% filter(if_any(everything(), is.na))
nrow(rows_with_na)

# Percentage of NA values by KEY
na_pct <- (na_by_col / nrow(ad_data)) * 100

# Percentage of NA values by KEYS that have NA values. 
na_pct[c("DEVICE_GEO_CITY", "DEVICE_GEO_ZIP")]

# ------------------------------------------------------------------
#  DETERMINATION OF IMPORTANCE FOR NA VALUES
# ------------------------------------------------------------------
importance_summary <- tibble(
  column = cols_with_na,
  na_percent = na_pct[cols_with_na],
  importance = case_when(
    na_pct[cols_with_na] < 5 ~ "Low impact, safe to keep",
    na_pct[cols_with_na] < 20 ~ "Moderate impact, consider imputation",
    TRUE ~ "High impact, consider removal"
  )
)

importance_summary
# Summary:
# DEVICE_GEO_CITY and DEVICE_GEO_ZIP both have ~4.77% missing values.
# Since the percentage is low, these columns are considered low impact.
# Recommendation: Keep the columns. If needed, use simple imputation
# such as replacing missing values with the mode or "Unknown".
