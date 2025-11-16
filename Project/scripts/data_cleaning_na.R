# Project/scripts/data_cleaning_na.R
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
#  NOTED NA VALUES (KAN-14)
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
