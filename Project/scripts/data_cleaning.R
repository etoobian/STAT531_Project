# Project/scripts/data_cleaning.R
# ------------------------------------------------------------------
#  DATA CLEANING PIPELINE
# ------------------------------------------------------------------
# Purpose:
#   - Load raw ad bidding data (via `load_ad_data()` from `data_io.R`)
#   - Apply all team-agreed cleaning steps (same Logic/Order as Rmd)
#   - Leave a cleaned tibble in the environment (`ad_clean`)
#   - Optionally export cleaned data parquet file via `export_ad_data`
# ------------------------------------------------------------------

# =====================================================================
# clean_ad_data()
# =====================================================================

clean_ad_data <- function(ad_raw) {
  
  suppressPackageStartupMessages({
    library(dplyr)
    library(tidyr)
    library(stringr)
    library(lubridate)
  })
  
  message("Starting cleaning pipeline...")
  
  # ------------------------------------------------------------------
  # GLOBAL: Remove exact duplicates
  # ------------------------------------------------------------------
  ad_clean <- ad_raw %>% distinct()
  message(" - Exact duplicates removed.")
  
  # ------------------------------------------------------------------
  # TIME VARIABLES ----------------------------------------------------
  # ------------------------------------------------------------------
  message(" - Cleaning TIMESTAMP and DATE_UTC...")
  
  ad_clean <- ad_clean %>%
    mutate(
      ts_date_raw = str_extract(TIMESTAMP, "^[^ ]+"),
      ts_time_raw = str_extract(TIMESTAMP, "\\d{1,2}:\\d{1,2}:\\d{1,2}")
    ) %>%
    mutate(
      TIMESTAMP_fixed = case_when(
        ts_date_raw == "NA" &
          !is.na(DATE_UTC) &
          !is.na(ts_time_raw) ~ paste(DATE_UTC, ts_time_raw),
        TRUE ~ TIMESTAMP
      )
    ) %>%
    mutate(
      TIMESTAMP_clean = parse_date_time(
        TIMESTAMP_fixed,
        orders = c("ymd HMS", "mdy HMS"),
        tz = "UTC"
      ),
      DATE_UTC_clean = as.Date(DATE_UTC)
    )
  
  # ------------------------------------------------------------------
  # IDENTIFIERS -------------------------------------------------------
  # ------------------------------------------------------------------
  message(" - Cleaning AUCTION_ID / removing invalid auctions...")
  
  auction_win_summary <- ad_clean %>%
    group_by(AUCTION_ID) %>%
    summarise(
      n_rows = n(),
      n_won  = sum(BID_WON == "TRUE", na.rm = TRUE),
      n_lost = sum(BID_WON == "FALSE", na.rm = TRUE),
      .groups = "drop"
    )
  
  invalid_ids <- auction_win_summary %>%
    filter(n_won != 1) %>%
    pull(AUCTION_ID)
  
  ad_clean <- ad_clean %>%
    filter(!AUCTION_ID %in% invalid_ids) %>%
    mutate(
      AUCTION_ID_clean   = str_trim(AUCTION_ID),
      PUBLISHER_ID_clean = str_trim(PUBLISHER_ID)
    )
  
  # ------------------------------------------------------------------
  # DEVICE_TYPE -------------------------------------------------------
  # ------------------------------------------------------------------
  message(" - Passing through DEVICE_TYPE...")
  ad_clean <- ad_clean %>%
    mutate(DEVICE_TYPE_clean = DEVICE_TYPE)
  
  # ------------------------------------------------------------------
  # GEOLOCATION -------------------------------------------------------
  # ------------------------------------------------------------------
  message(" - Cleaning geolocation fields...")
  
  # REGION
  ad_clean <- ad_clean %>%
    mutate(
      DEVICE_GEO_REGION_clean = case_when(
        DEVICE_GEO_REGION %in% c("OR", "Or", "oregon", "xor") ~ "OR",
        TRUE ~ NA_character_
      )
    )
  
  # CITY (keep as-is)
  ad_clean <- ad_clean %>%
    mutate(DEVICE_GEO_CITY_clean = DEVICE_GEO_CITY)
  
  # ZIP (sentinels only)
  ad_clean <- ad_clean %>%
    mutate(
      DEVICE_GEO_ZIP_clean = case_when(
        DEVICE_GEO_ZIP %in% c("-999") ~ NA_character_,
        TRUE ~ DEVICE_GEO_ZIP
      )
    )
  
  # LAT & LONG (apply +10 correction)
  ad_clean <- ad_clean %>%
    mutate(
      DEVICE_GEO_LAT_clean = DEVICE_GEO_LAT,
      DEVICE_GEO_LONG_clean = case_when(
        DEVICE_GEO_LONG < -125 | DEVICE_GEO_LONG > -116 ~ DEVICE_GEO_LONG + 10,
        TRUE ~ DEVICE_GEO_LONG
      )
    )
  
  # ------------------------------------------------------------------
  # AD SIZES ----------------------------------------------------------
  # ------------------------------------------------------------------
  message(" - Passing through ad size fields...")
  
  ad_clean <- ad_clean %>%
    mutate(
      REQUESTED_SIZES_clean = REQUESTED_SIZES,
      SIZE_clean            = SIZE
    )
  
  # ------------------------------------------------------------------
  # PRICE -------------------------------------------------------------
  # ------------------------------------------------------------------
  message(" - Cleaning PRICE...")
  
  ad_clean <- ad_clean %>%
    mutate(
      PRICE_str = str_replace(PRICE, "^O", "0"),
      PRICE_num = suppressWarnings(as.numeric(PRICE_str)),
      PRICE_num = if_else(PRICE_num == -999, NA_real_, PRICE_num),
      PRICE_clean = case_when(
        is.na(PRICE_num) ~ NA_real_,
        PRICE_num < 0    ~ -PRICE_num,
        TRUE ~ PRICE_num
      )
    ) %>%
    select(-PRICE_str, -PRICE_num)
  
  # ------------------------------------------------------------------
  # RESPONSE_TIME -----------------------------------------------------
  # ------------------------------------------------------------------
  message(" - Cleaning RESPONSE_TIME...")
  
  ad_clean <- ad_clean %>%
    mutate(
      RESPONSE_TIME_clean = RESPONSE_TIME %>%
        str_replace("^[^0-9]+", "") %>%
        str_replace("[^0-9]+$", "") %>%
        as.numeric()
    )
  
  # ------------------------------------------------------------------
  # BID_WON -----------------------------------------------------------
  # ------------------------------------------------------------------
  message(" - Cleaning BID_WON / removing multi-winner auctions...")
  
  auction_win_summary2 <- ad_clean %>%
    group_by(AUCTION_ID) %>%
    summarise(
      n_won = sum(BID_WON %in% c("TRUE", "true"), na.rm = TRUE),
      .groups = "drop"
    )
  
  multiwin_ids <- auction_win_summary2 %>%
    filter(n_won > 1) %>%
    pull(AUCTION_ID)
  
  ad_clean <- ad_clean %>%
    mutate(
      BID_WON_clean = case_when(
        BID_WON %in% c("TRUE", "true") ~ TRUE,
        BID_WON %in% c("FALSE")        ~ FALSE,
        TRUE ~ NA
      )
    ) %>%
    filter(!AUCTION_ID %in% multiwin_ids)
  
  # ------------------------------------------------------------------
  # ASSEMBLE FINAL CLEAN DATASET -------------------------------------
  # ------------------------------------------------------------------
  message(" - Assembling final dataset...")
  
  clean_cols <- names(ad_clean)[str_detect(names(ad_clean), "_clean$")]
  
  ad_clean <- ad_clean %>%
    select(all_of(clean_cols))
  
  names(ad_clean) <- str_replace(names(ad_clean), "_clean$", "")
  
  message("Cleaning completed. Final rows: ", nrow(ad_clean))
  
  return(ad_clean)
}