# Project/scripts/load_data.R
# ------------------------------------------------------------------
#  PROJECT DATA LOADER
# ------------------------------------------------------------------
# Purpose:
#   - Loads project dataset (single file) into CURRENT R session
#   - Stores data in variable -> `ad_data`
# 
# Usage (from repo root in R / RStudio):
#   ```
#   source("Project/scripts/load_data.r")
#   head(ad_data)
#   ```
#
# NOTES:
#  - Does NOT persist data across R sessions. 
#       (Restart R -> must run `source()` again.)
#  - Expected file: `Project/data/bids_data_vDTR.parquet`
#       If filename / folder changes, edit `data_folder` / `data_file` below.
# ------------------------------------------------------------------

# ---------------------------
# Install packages if missing
# ---------------------------
if (!requireNamespace("arrow", quietly = TRUE)) {
  install.packages("arrow")
}

library(arrow)

# -----------------------------------
# CONFIG: DEFAULTS (Change as needed)
# -----------------------------------
default_data_folder       <- "Project/data"              # Folder relative to repo root
default_input_data_file   <- "bids_data_vDTR.parquet"    # expected filename

# ----------------------------------------------
# HELPFUL CHECK: Set WD to repo root (if needed)
# ----------------------------------------------
# Check current working directory:
#   getwd()
# If not repo root, call:
#   setwd("<path/to/repo/root>")
# ----------------------------------------------


# ----------------------------------
# FUNCTION TO LOAD DATA FROM PARQUET
# ----------------------------------

load_ad_data <- function(data_folder = default_data_folder,
                         data_file   = default_input_data_file) {

  data_path <- file.path(data_folder, data_file)
  
  
  # ----- Validate data folder and file -----
  
  # Check the directory
  if (!dir.exists(data_folder)) {
    stop(
      "\n Data folder not found: '",
      data_folder,
      "Check working directory. Check that folder exists & contains dataset."
    )
  }
  
  # Check that the file exists
  if (!file.exists(data_path)) {
    stop(
      "\n Data file not found: ",
      data_path,
      "\n Check the file name and update `data_file` if needed."
    )
  }
  
  
  # ----- Load dataset -----
  
  message("\n Loading dataset: ", data_path, " ...")
  df <- tryCatch({
    arrow::read_parquet(data_path)
  }, error = function(e) {
    stop(
      "\n Failed to read parquet file: ",
      e$message,
      "\n Make sure the file is a valid parquet and not corrupted."
    )
  })
  
  
  # ----- Confirm success -----
  
  message("Load successful: ", data_file)
  message("Rows x Columns: ", paste(dim(df), collapse = " x "))
  print(utils::head(df, 5))
  
  return(df)
}

# ----- Make available in interactive session -----
df <- load_ad_data()
assign("ad_data", df, envir = .GlobalEnv)
invisible(df)
message("\n Data is now available as `ad_data` in this R session.\n")