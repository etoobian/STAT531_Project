# Project/scripts/data_io.R
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



# -----------------------------
# Install packages if missing
# -----------------------------
needed_pkgs <- c("arrow", "tibble", "dplyr")

for (pkg in needed_pkgs) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}

library(arrow) # Only need to attach arrow, use tibble:: and dplyr:: explicitly

# -------------------------------------
# CONFIG: DEFAULTS (Change as needed)
# -------------------------------------
default_data_folder      <- "Project/data"      # Folder relative to repo root
default_input_data_file  <- "bids_data_vDTR.parquet"    # Initial project data
default_out_dir          <- "Project/data/results"   # Loc. for new data files
default_out_base_name    <- "bids_data"           # Base of new file filenames

# ------------------------------------------------
# HELPFUL CHECK: Set WD to repo root (if needed)
# ------------------------------------------------
# Check current working directory:
#   getwd()
# If not repo root, call:
#   setwd("<path/to/repo/root>")
# ------------------------------------------------


# ------------------------------------------
# FUNCTION: LOAD PROJECT DATA FROM PARQUET
# ------------------------------------------

load_ad_data <- function(data_folder = default_data_folder,
                         data_file   = default_input_data_file) {

  data_path <- file.path(data_folder, data_file)
  
  
  # ----- Validate data folder and file paths-----
  
  # Check the directory
  if (!dir.exists(data_folder)) {
    stop(
      "\n Data folder not found: '", data_folder,
      "Check working directory. Use `getwd()`."
    )
  }
  
  # Check that the file exists
  if (!file.exists(data_path)) {
    stop(
      "\n Data file not found: ", data_path,
      "\n Check filename."
    )
  }
  
  
  # ----- Load parquet dataset -----
  
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


# ----------------------------------------------
# HELPER FUNCTION: SUMMARIZE DATAFRAME COLUMNS
# ----------------------------------------------

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


# ----------------------------------
# FUNCTION: EXPORT DATA TO PARQUET
# ----------------------------------

export_ad_data <- function(df,
                           version,
                           out_dir   = default_out_dir,
                           base_name = default_out_base_name,
                           overwrite = FALSE) {
  
  # ----- Validate `version` -----
  if (missing(version) || length(version) != 1L || !nzchar(version)){
    stop(
      "`version` must be provided as a non-empty string, e.g. ",
      "`version = \"clean_NA_v1\"`."
    )
  }
  
  # Clean version string a bit (avoid unwanted filename chars)
  safe_version <- gsub("[^A-Za-z0-9_-]", "_", version)
  
  if (!dir.exists(out_dir)) {
    dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  }
  
  file_name <- paste0(base_name, "_", safe_version, ".parquet")
  out_path  <- file.path(out_dir, file_name)
  
  # Check for existing file of same name
  file_already_exists <- file.exists(out_path)
  
  if (file_already_exists && !overwrite) {
    stop(
      "\nExport aborted: file already exists:\n  ", out_path,
      "\n\nOptions:\n",
      "  - Choose a new `version` name (recommended), e.g. \"clean_NA_v1\"`",
      "  - Call again with `overwrite = TRUE` if intentionally replacing.\n"
    )
  }
  
  message("\n Exporting dataset to: ", out_path, " ...")
  
  tryCatch({
    arrow::write_parquet(df, out_path)
    if (file_already_exists && overwrite) {
      message("Export successful (existing file overwritten): ", file_name)
    } else {
      message("Export successful: ", file_name)
    }
    invisible(out_path)
  }, error = function(e) {
    stop("\n Failed to export parquet file: ", e$message)
  })
}


# --------------------------------------------------------
# AUTO-LOAD DATA INTO SESSION WHEN FILE IS SOURCED
# --------------------------------------------------------
df <- load_ad_data()
assign("ad_data", df, envir = .GlobalEnv)
invisible(df)

message("\nData is now available as `ad_data` in this R session.\n")