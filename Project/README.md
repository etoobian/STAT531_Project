# Project: Oregon Ad Bidding

## Quick start (R)

1. Install dependencies (once):
   `install.packages(c("arrow", "dplyr"))`

2. Ensure dataset file in:
    `Project/data/bids_data_vDTR.parquet`

3. To load data, in R or RStudio (from repo root), run:
   `source("Project/scripts/load_data.R")`

4. Data will be available as variable:
    `ad_data`

5. Inspect:
   dim(ad_data)
   head(ad_data)


**NOTE:**
This is a temporary README to get started and a brief example. 
Final version will be much more involved and, therefore, not this detailed for 
smaller tasks such as this.
