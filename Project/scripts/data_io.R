# Project/scripts/data_io.R
# ----------------------------------------------------------------------------
#  PROJECT DATA I/O UTILITIES
# ----------------------------------------------------------------------------
# PURPOSE:
#   This script provides reusable tools for loading, summarizing, and exporting
#   the project dataset. Sourcing this file only defines functions.
#   To load data, call `load_ad_data()`.
#
#   1. `load_ad_data()`
#        - Loads a dataset from a parquet file.
#        - Defaults to loading the main project dataset (local copy only):
#            "Project/data/bids_data_vDTR.parquet"
#        - Optional: `preview = TRUE` prints first five rows.
#
#   2. `summarize_ad_data()`
#        - Returns a summary table for each column:
#            * column name
#            * data type
#            * number of missing / non-missing values
#            * number of unique values
#
#   3. `export_ad_data()`
#        - Writes a dataframe (typically a cleaned version) to a parquet file:
#            * requires a version name (e.g. "clean_v1")
#            * writes to "Project/data/processed" by default
#            * will NOT overwrite existing files unless `overwrite = TRUE`
#
# ----------------------------------------------------------------------------
# TYPICAL USAGE: (from repo root in R / RStudio)
#
#   1. Load utilities
#          `source("Project/scripts/data_io.R")`
#
#   2. Load raw data (with optional quick preview):
#          `ad_raw <- load_ad_data(preview = TRUE)`
#
#   3. Summarize columns
#          ```
#          summary_tbl <- summarize_ad_data(ad_raw)
#          View(summary_tbl) # or print(summary_tbl)
#          ```
#
#   4. Export a cleaned / processed dataset (after running cleaning pipeline)
#       - `version` MUST be provided
#       - existing files are NOT overwritten unless `overwrite = TRUE`
#          ```
#          export_ad_data(
#            df        = ad_clean,
#            version   = "clean_v1",                # choose unique version name
#            out_dir   = "Project/data/processed",  # omit to use default
#            base_name = "bids_data"                # omit to use default
#          )
#          ```
#       - To overwrite an existing file:
#          ```
#          export_ad_data(
#            df        = ad_clean,
#            version   = "clean_v1",        
#            overwrite = TRUE
#          )
#          ```
#
# ----------------------------------------------------------------------------
# NOTES:
#
#   - Working directory:
#       * Use `STAT531_Project.Rproj` and knit Rmds with Knit directory
#         set to the Project Directory.
#
#   - Default locations:
#       * Raw data:        `Project/data/bids_data_vDTR.parquet`
#       * Processed data:  `Project/data/processed/`
#
# ----------------------------------------------------------------------------


# -----------------------------
# Install packages if missing
# -----------------------------
needed_pkgs <- c("arrow", "tibble", "dplyr")

for (pkg in needed_pkgs) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}

# Attach arrow; Use `tibble::` and `dplyr::` explicitly
library(arrow) 

# ------------------------------------------
# CONFIG: DEFAULT PATHS (change as needed)
# ------------------------------------------
default_data_folder      <- "Project/data"       # Folder relative to repo root
default_input_data_file  <- "bids_data_vDTR.parquet"         # Raw project data

default_out_dir          <- "Project/data/processed"  # For exported/clean data
default_out_base_name    <- "bids_data"          # Base name for exported files

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
                         data_file   = default_input_data_file,
                         preview     = FALSE) {
  
  data_path <- file.path(data_folder, data_file)
  
  
  # ----- Validate data folder and file paths-----
  
  # Check the directory
  if (!dir.exists(data_folder)) {
    stop(
      "\nData folder not found: '", data_folder, "'",
      "\nCheck working directory. (Use `getwd()`.)"
    )
  }
  
  # Check that the file exists
  if (!file.exists(data_path)) {
    stop(
      "\nData file not found at: \n'", data_path, "'",
      "\nCheck filename and ensure parquet file is present locally."
    )
  }
  
  
  # ----- Load parquet dataset -----
  
  message("\nLoading dataset: ", data_path, " ...")
  df <- tryCatch({
    arrow::read_parquet(data_path)
  }, error = function(e) {
    stop(
      "\nFailed to read parquet file: ",
      e$message,
      "\nMake sure the file is a valid parquet and not corrupted."
    )
  })
  
  
  # ----- Confirm success -----
  
  message("Load successful: ", data_file)
  message("Rows x Columns: ", paste(dim(df), collapse = " x "))
  
  if (preview) {
    print(utils::head(df, 5))
  }
  
  df
}


# ----------------------------------------------
# FUNCTION: SUMMARIZE DATAFRAME COLUMNS
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

# ----------------------------------
# FUNCTION: EXPORT DATA TO PARQUET
# ----------------------------------

export_ad_data <- function(df,
                           version,
                           out_dir   = default_out_dir,
                           base_name = default_out_base_name,
                           overwrite = FALSE) {
  
  # ----- Validate `version` -----
  if (missing(version) || length(version) != 1L || !nzchar(version)) {
    stop(
      "`version` must be provided as a non-empty string, e.g. ",
      "`version = \"clean_v1\"`."
    )
  }
  
  # Clean version string (avoid unwanted filename chars)
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
      "\nExport aborted: file already exists:\n", out_path,
      "\n\nOptions:\n",
      "  - Choose a new `version` name (recommended), e.g. \"clean_v2\"\n",
      "  - Call again with `overwrite = TRUE` if intentionally replacing.\n"
    )
  }
  
  message("\nExporting dataset to: ", out_path, " ...")
  
  tryCatch({
    arrow::write_parquet(df, out_path)
    if (file_already_exists && overwrite) {
      message("Export successful (existing file overwritten): ", file_name)
    } else {
      message("Export successful: ", file_name)
    }
    invisible(out_path)
  }, error = function(e) {
    stop("\nFailed to export parquet file: ", e$message)
  })
}