---
editor_options: 
  markdown: 
    wrap: 72
---

# **Project Overview: Oregon Ad Bidding**

*STAT 531 — Ethics & Practice of Data Science, Portland State
University*

This repository contains all code, documentation, and analysis for the **Oregon Ad Bidding** project.

It is the team project repository for the team **TECK Squad** (formerly **Kentucky Thighed Chicken (KTC)**).


Our goals:

-   Load and clean the provided `.parquet` dataset
-   Identify issues intentionally inserted by the instructor
-   Perform clear, reproducible exploratory data analysis (EDA)
-   Produce cleaned / processed datasets
-   Generate visualizations, reports, and a final presentation

------------------------------------------------------------------------

# **Repository Structure**

**Important:**  
This repo does **NOT** contain datasets, nor should any data files be 
committed.  
All data must be stored **locally** by team members following 
the structure described below.

## **Remote Structure**
```
README.md                       # Current document


Project/
│
├── scripts/
│   ├── data_io.R               # Data loading/export utilities
│   └── data_cleaning.R         # Data cleaning pipeline
│
├── notebooks/
│   ├── data_cleaning.Rmd       # Data cleaning exploration/justifications
│   └── EDA.Rmd                 # Rmd file for EDA / analysis
│
├── results/
│   └── ...                     # Figures, tables, summaries
│
└── reports/
    └── ...                     # Final slideshow


TeamDocuments/
│
├── TeamCharter.md              # Copy of team charter for reference
│
├── GitWorkflow.md              # Detailed instructions & notes on Git Workflow
│
├── PR_Checklist.md             # List of checks prior to each pull request
│
├── TeamCheckInTeamplate.md     # Template for team check-in meeeting notetaker
│
└── TeamCheckInEntries/    
    └── ...                     # Dated .md files from each meeting
```

## **Expected Local Structure**

**DO NOT COMMIT DATA TO THIS REPO**

Only store data in local directory, structured as shown below:

```
README.md                       # Current document


Project/
│
├── data/
│   ├── bids_data_vDTR.parquet   # Raw project data .parquet file
│   ├── data_dictionary.md       # Data dictionary for project data
│   └── processed/
│       └── ...                  # Cleaned / processed data .parquet file
│
├── scripts/
│   ├── data_io.R               # Data loading/export utilities
│   └── data_cleaning.R         # Data cleaning pipeline
│
├── notebooks/
│   ├── data_cleaning.Rmd       # Data cleaning exploration/justifications
│   └── EDA.Rmd                 # Rmd file for EDA / analysis
│
├── results/
│   └── ...                     # Figures, tables, summaries
│
└── reports/
    └── ...                     # Final slideshow


TeamDocuments/
│
├── TeamCharter.md              # Copy of team charter for reference
│
├── GitWorkflow.md              # Detailed instructions & notes on Git Workflow
│
├── PR_Checklist.md             # List of checks prior to each pull request
│
├── TeamCheckInTeamplate.md     # Template for team check-in meeeting notetaker
│
└── TeamCheckInEntries/    
    └── ...                     # Dated .md files from each meeting
```

# **Setup Instructions**

## Clone the Repository
```
git clone https://github.com/etoobian/STAT531_Project.git
cd STAT531_Project
```

## Open the R Project

Open:
```
STAT531_Project.Rproj
```

This ensures correct working directory and project settings.

## Install Required Packages

Packages will normally auto-install when sourcing the scripts, but can also be installed manually:

```         
required_packages <- c("arrow", "tibble",
                       "dplyr", "stringr",
                       "jsonlite", "tidyverse")

install.packages(required_packages)
```

# **Data I/O Utilities: Loading, Summarizing, and Exporting Data**

Dataset I/O-related functions live in:

```         
Project/scripts/data_io.R
```

This script defines functions for loading, summarizing, and exporting the ad bids data.

## Setup

From the project root (inside STAT531_Project):

```
source("Project/scripts/data_io.R")
```

## Load Raw Dataset

Once sourced (shown above):

```
# By default, read:  "Project/data/bids_data_vDTR.parquet"
ad_raw <- load_ad_data(preview = TRUE)
```

## Summarize Dataset

Use to inspect column types, missingness, and unique values:

```         
summary_tbl_raw <- summarize_ad_data(ad_raw)
View(summary_tbl_raw)       # or print(summary_tbl_raw)
```

## Export Processed Data

Processed datasets exported using:

```
export_ad_data(
  df        = cleaned_df,                # df to export to .parquet
  version   = "clean_v1_description",    # char description / version number
  out_dir   = "Project/data/processed",  # omit to leave as default
  base_name = "bids_data",               # omit to leave as default
  overwrite = FALSE
)
```

**NOTES:**
-   `version` MUST be provided
-   existing files are NOT overwritten unless `overwrite = TRUE`

Exports are written to:

```         
Project/data/processed/
```

as:

```         
<base_name>_<version>.parquet
```

# **Data Cleaning: Identifying and Correcting Issues in the Raw Dataset**

The cleaning process fixes a series of inconsistencies in the dataset, including incorrect ZIP/CITY pairs, shifted longitude values, malformed fields, invalid price values, duplicated rows, and missingness patterns.

All data cleaning related files will be found in:

- `Project/notebooks/data_cleaning.Rmd` 
    - Details on investigation & error handling
- `Project/scripts/data_cleaning.R` 
    - Cleaning workflow via reusable function `clean_ad_data()`, which accepts **raw input data** and returns a **fully cleaned tibble**.


---

## Cleaning Workflow

### Load utilities and raw data

From the project root (`STAT531_Project`), run:

```
source("Project/scripts/data_io.R")
source("Project/scripts/data_cleaning.R")
```

Load raw dataset from Project/data/bids_data_vDTR.parquet

```
ad_raw <- load_ad_data(preview = TRUE)
```

Optional: Summarize columns

```
summary_tbl_raw <- summarize_ad_data(ad_raw)
View(summary_tbl_raw)
```

### Apply the cleaning pipeline

```
ad_clean <- clean_ad_data(ad_raw)
```

This function performs all cleaning steps, including:

  - Reconstructing missing ZIP/CITY values
  - Correcting out-of-range geographic fields
  - Cleaning malformed timestamps
  - Repairing inconsistent field values
  - Handling NAs
  - Removing duplicates
  - Enforcing consistent column types
  - Ensuring reproducible, well-structured final output

### Export the cleaned dataset (optional)

```
export_ad_data(
  df      = ad_clean,
  version = "clean_v1",
  out_dir = "Project/data/processed"
)
```
Exports a versioned parquet file:

```
Project/data/processed/bids_data_clean_v1.parquet
```

### Refer to the cleaning notebook

Detailed explanations, diagnostics, and examples of each problem and fix are documented in:

```
Project/notebooks/data_cleaning.Rmd
```

This notebook shows:

  - The original data issues
  - Why certain corrections were necessary
  - Before/after views of problematic fields
  - Justification for decisions in the cleaning pipeline


# **Script & Notebook Index**

This index summarizes all scripts, notebooks, and reports in the project.
Each entry includes a short description, location, and example usage (when
applicable). 

---

## `data_io.R`

**Type:** Script  

**Purpose:** Provides reusable utilities for loading, summarizing, and exporting datasets.  

**Location:** `Project/scripts/data_io.R`

**Functions Provided:**  

  - `load_ad_data()` — loads a dataset from a parquet file  
  - `summarize_ad_data()` — produces a column-level summary  
  - `export_ad_data()` — writes a safely versioned parquet file  

**Example Usage:**

```         
source("Project/scripts/data_io.R")

# Load raw dataset (default path: Project/data/bids_data_vDTR.parquet)
ad_raw <- load_ad_data(preview = TRUE)

# Summaries
summary_tbl <- summarize_ad_data(ad_raw)

# Export cleaned dataset
export_ad_data(ad_clean, version = "clean_v1")
```
---

## `data_cleaning.R`

**Type:** Script  

**Purpose:** Implements the full data cleaning pipeline via a reusable function.

**Location:** `Project/scripts/data_cleaning.R`

**Functions Provided:** 

  - `clean_ad_data()` - applies the complete cleaning workflow and returns a cleaned tibble
      - **NOTE:** Work is specific to raw project data.

**Example Usage:**

```
source("Project/scripts/data_io.R")
source("Project/scripts/data_cleaning.R")

ad_raw   <- load_ad_data()
ad_clean <- clean_ad_data(ad_raw)
```

After cleaning, users may export results using `export_ad_data()`.

---

## `data_cleaning.Rmd`

**Type:** Notebook

**Purpose:** Documents and justifies all cleaning steps, including diagnostics and demonstrations of issues in the raw dataset.

**Location:** `Project/notebooks/data_cleaning.Rmd`

**Usage:**

  - Open inside the `STAT531_Project.RProj`
  - Ensure *Knit Directory = “Project Directory”*
  - Knit to produce an HTML record of the cleaning workflow

This notebook serves as the narrative counterpart to `data_cleaning.R`.

---

## `EDA.Rmd`

**Type:** Notebook

**Purpose:** Performs exploratory data analysis (EDA) on the cleaned dataset. Includes summary tables, visualizations, and modeling insights supporting the final report.

**Location:** `Project/notebooks/EDA.Rmd`

**Usage:**

```
source("Project/scripts/data_io.R")

# Either re-clean from raw:
source("Project/scripts/data_cleaning.R")
ad_clean <- clean_ad_data(load_ad_data())

# Or load a previously exported cleaned dataset:
ad_clean <- load_ad_data(
  data_folder = "Project/data/processed",
  data_file   = "bids_data_clean_v1.parquet"
)
```

---

## `reports/` (Final Presentation)

**Type:** Report / Slides

**Purpose:** Final presentation summarizing cleaning, EDA, findings, and recommendations.

**Location:** `Project/reports/`

Example filenames:

  - `final_presentation.pdf`
  - `final_slideshow.`

These files are generated manually or exported from R Markdown/Slides tools.



<!-- NOTE TO TEAM:
Add new scripts below using the template. -->

Use this template exactly so our README stays cohesive:

**Template for Adding a Script**

Copy/paste and fill in:

```
### <script_name>.R 

**Type:** script/notebook/report/etc

**Purpose:** One-sentence description  

**Location:** Project/scripts/<script_name>.R  

**Functions Provided:**  
  - func1() – what it does  
  - func2() – what it does  

**Example Usage:**  
  # example usage commands here
```
------------------------------------------------------------------------


**Where to put new files**

| Type of File                           | Folder                    |
| -------------------------------------- | ------------------------- |
| Data cleaning / transformation scripts | `Project/scripts/`        |
| Helpers / utilities                    | `Project/scripts/`        |
| EDA notebooks                          | `Project/notebooks/`      |
| Plots / visualizations                 | `Project/results/`        |
| Processed datasets                     | `Project/data/processed/` |
| Report sections                        | `Project/reports/`        |


When adding a new script:

-   Place it in `Project/scripts/`
-   Use the **script index template** above to document it
-   Keep function names descriptive and consistent
-   Include example usage where possible

# **Notes for Completion** (Will Be Removed Later)

```{=html}
<!-- NOTE TO TEAM:
This section should NOT appear in the final deliverable.
It is only guidance during development. -->
```

-   Keep this README updated as scripts are added
-   Maintain consistent naming patterns
-   Keep examples short and copy/paste friendly
-   Do NOT add EDA results or report content here
-   Before final submission, we will prune placeholder notes

