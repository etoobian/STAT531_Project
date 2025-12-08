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

**NOTE TO TEAM:** This is a *working document* which will be completed
as we go. When you add to the repo, the README should be altered to
reflect the repo's current functionality.

------------------------------------------------------------------------

# **Repository Structure**

**Important:**  
This repo does **NOT** contain datasets, nor should any data files be 
committed.  
All data must be stored **locally** by team members following 
the structure described below.

## **Remote Structure**
```
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
├── reports/
│   └── ...                     # Final slideshow
│
└── README.md                   # Currently a working document


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

Instead, create a local directory. 
Please copy the data files from the team's
Canvas page and add locally, structured as shown below:

```
data/
│
├── bids_data_vDTR.parquet      # Project data .parquet file
│
└── data_dictionary.md          # Data dictionary for project data


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
├── reports/
│   └── ...                     # Final slideshow
│
└── README.md                   # Currently a working document


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

**TEAM TO-DO:** Add files/folders into this doc's tree as created as
well as to *Script Index* section below. Keep descriptions short and
consistent.

**Important:**\
Do **not** rename or reorganize top-level folders without discussion on
**Discord**.

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
                       jsonlite", tidyverse")

install.packages(required_packages)
```

**TEAM TO-DO:** Add required packages for this script to this list.

# **Data I/O: Loading, Summarizing, and Exporting Data**

Dataset I/O-related functions live in:

```         
Project/scripts/data_io.R
```

When you source this file, the dataset is automatically loaded and made
available as `ad_data`.

## Load Dataset (Auto-load)

```         
source("Project/scripts/data_io.R")
head(ad_data)
```

This:
  - Validates the raw data exists
  - Loads it using `arrow::read_parquet()`
  - Prints a preview
  - Stores it as `ad_data` in your R session

**NOTE:** Once sourced, `load_ad_data()` can be run for other datasets as needed.

## Load Dataset (From function)
 
 Once sourced (shown above):
 ```
 load_ad_data(
   data_folder = "Project/data/processed",  # Location of data file
   data_file   = "Data_filename.parquet"    # Name of .parquet data file to load
 )
 ```

## Summarize Dataset

Use this to inspect column types, missingness, and unique values:

```         
summary_tbl <- summarize_ad_data(ad_data)
View(summary_tbl)
```

This is helpful before beginning cleaning tasks.

## Export Processed Data

All processed datasets should be exported using:

```
export_ad_data(
  df        = cleaned_df,                # df to export to .parquet
  version   = "clean_v1_description",    # char description / version number
  out_dir   = "Project/data/processed",  # omit to leave as default
  base_name = "bids_data",               # omit to leave as default
  overwrite = FALSE
)
```

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

# Data Cleaning: Identifying and mending inconsistencies, NA values, and other errors.

All data cleaning related files will be found in:

`Project/scripts/Final_Data_Cleaning/` - The R script that imports and
cleans the raw data is:

`Final_Data_Cleaning/final_data.cleaning.R` - When you source this file,
you will be left with a tibble that has been cleaned in your environment
named `cumulative_ad_data`.

Refer to `Final_Data_Cleaning/final_data.cleaning.Rmd` for more
information on the errors.

## Cleaning Data (Auto):

`# Given that getwd() returns "~/STAT531_Project" source(file.path(getwd(), "Project/scripts/Final_Data_Cleaning/final_data_cleaning.R"))`

**NOTE:** This process will take roughly 10-15 seconds to complete if
not sooner.

# **Script Index** (Add Here When Creating New Scripts)

Every new script added to the project should be briefly documented here.

Use this template exactly so our README stays cohesive:

**Template for Adding a Script**

Copy/paste and fill in:

```
### <script_name>.R 

**Purpose:** One-sentence description  

**Location:** Project/scripts/<script_name>.R  

**Functions Provided:**  
  - func1() – what it does  
  - func2() – what it does  

**Example Usage:**  
  # example usage commands here
```
------------------------------------------------------------------------

## Scripts

### `data_io.R`

**Purpose:** Utilities for loading the raw dataset, summarizing columns,
and exporting cleaned datasets.

**Location:** `Project/scripts/data_io.R`

**Functions Provided:**\
- `load_ad_data()` — loads the main dataset\
- `summarize_ad_data()` — creates a summary table\
- `export_ad_data()` — saves processed data safely

**Example Usage:**

```         
source("Project/scripts/data_io.R")
head(ad_data)
summary_tbl <- summarize_ad_data(ad_data)
export_ad_data(cleaned_df, version = "clean_v1")
```

```{=html}
<!-- NOTE TO TEAM:
Add new scripts below using the template. -->
```

### `final_data_cleaning.R`

**Purpose:** Cleans the raw data of inconsistencies, NA values and other
errors.

**Location:**
`Project/scripts/Final_Data_Cleaning/final_data_cleaning.R`

**Functions Provided:** No functions provided.

**Example Usage:**

`# Given that getwd() returns "~/STAT531_Project" source(file.path(getwd(), "Project/scripts/Final_Data_Cleaning/final_data_cleaning.R"))`

<!-- NOTE TO TEAM:
Add new scripts below using the template. -->

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

