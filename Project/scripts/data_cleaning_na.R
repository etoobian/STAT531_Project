library(tidyverse)
library(arrow)


df <- read_parquet("Project/data/bids_data_vDTR.parquet")


na_by_col <- colSums(is.na(df))
na_by_col

cols_with_na <- names(na_by_col[na_by_col > 0])
cols_with_na

rows_with_na <- df %>% filter(if_any(everything(), is.na))
nrow(rows_with_na)

# Percentage of missing values by column
na_pct <- (na_by_col / nrow(df)) * 100
na_pct

na_pct[c("DEVICE_GEO_CITY", "DEVICE_GEO_ZIP")]
