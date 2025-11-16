# Project/scripts/load_data.R
# ------------------------------------------------------------------
#  PROJECT DATA LOADER
# ------------------------------------------------------------------
# PURPOSE:
#   - Defines function `load_ad_data() for loading project dataset.
#   - Automatically loads the dataset when this file is sourced.
#   - Stores the loaded dataframe in the global environment as `ad_data`.
#   - Helper Functions:
#        - `summarize_ad_data()`: 
#             summarizes columns (type, missingness, uniqueness)
#
#
# USAGE (from repo root in R / RStudio):
#   - Sourcing script (loads data into `ad_data`):
#        `source("Project/scripts/load_data.r")`
#   - Options:
#       - Inspect or work with data:  
#           `head(ad_data)`
#       - Get column-wise summary:  
#           ```
#           summary_tbl <- summary_tbl(ad_data)
#           View(summary_tbl)                   # or print(summary_tbl)
#           ```
#
# NOTES:
#   - Does NOT persist data across R sessions. 
#       (Restart R -> must run `source()` again.)
#   - Default expected file:  
#       `Project/data/bids_data_vDTR.parquet`
#        - Update `default_data_folder` or `default_input_data_file`
#          if the project data location changes.
#
#   - Working directory matters:
#       Use getwd() to confirm you are at the repo root.
# ------------------------------------------------------------------


# ---------------------------
# Install packages if missing
# ---------------------------
needed_pkgs < c("arrow", "tibble", "dplyr")

for (pkg in needed_pkgs) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
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


# ------------------
# HELPER FUNCTIONS
# ------------------

# ----- SUMMARIZE DATAFRAME COLUMNS -----

summarize_ad_data <- function(df) {
  tibble::tibble(
    column        = names(df),
    type          = vapply(df, function(x) class(x)[1], character(1)),
    n_missing     = vapply(df, function(x) sum(is.na(x)), integer(1)),
    n_non_missing = vapply(df, function(x) sum(!is.na(x)), integer(1)),
    n_unique      = vapply(df, function(x) dplyr::n_distinct(x), integer(1))
  )
}

# Example usage (after sourcing this file):
#   summary_tbl <- summarize_ad_data(ad_data)
#   View(summary_tbl)


# ----- Make available in interactive session -----
df <- load_ad_data()
assign("ad_data", df, envir = .GlobalEnv)
invisible(df)
message("\n Data is now available as `ad_data` in this R session.\n")