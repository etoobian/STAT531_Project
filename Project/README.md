# Project Overview: Oregon Ad Bidding  
*STAT 531 — Ethics & Practice of Data Science, Portland State University*

This repository contains all code, documentation, and analysis for the **Oregon Ad Bidding** project.  
It is the team project repository for the team **Kentucky Thighed Chicken (KTC)**. 

Our goals:

  - Load and clean the provided `.parquet` dataset
  - Identify issues intentionally inserted by the instructor
  - Perform clear, reproducible exploratory data analysis (EDA)
  - Produce cleaned / processed datasets
  - Generate visualizations, reports, and a final presentation
  
**NOTE TO TEAM:** This is a *working document* which will be competed as we go. 
When you add to the repo, the README should be altered to reflect the repo's current functionality.

---

# Repository Structure


```
Project/
│
├── data/
│   ├── bids_data_vDTR.parquet        # Raw dataset (do not modify)
│   └── processed/                    # Saved cleaned/processed datasets
│
├── scripts/
│   ├── data_io.R                     # Data loading/export utilities
│   └── ...                           # (future scripts here)
│
├── notebooks/
│   └── ...                           # Rmd files for EDA / analysis
│
├── results/
│   └── ...                           # Figures, tables, summaries
│
├── reports/
│   └── ...                           # Final written deliverables
│
└── README.md                         # Currently a working document


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

**TEAM TO-DO:** Add files/folders into this doc's tree as created as well as to *Script Index* section below. Keep descriptions short and consistent.

**Important:**  
Do **not** rename or reorganize top-level folders without discussion on **Discord**.

---

# Setup Instructions

## Clone the Repository
```
git clone https://github.com/etoobian/EnP_2025Labs.git
cd ENP_2025Labs
```

## Open the R Project

Open:

```
EnP_2025Labs.Rproj
```

This ensures correct working directory and project settings.

## Install Required Packages

Packages will normally auto-install when sourcing the script, but can also be installed manually:

```
install.packages(c("arrow", "tibble", "dplyr"))
```
**TEAM TO-DO:** Add required packages for this script to this list.


# Data I/O: Loading, Summarizing, and Exporting Data

Dataset I/O-related functions live in:

```
Project/scripts/data_io.R
```

When you source this file, the dataset is automatically loaded and made available as `ad_data`.

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








# Adding New Work to the Codebase

**Where to put new files**

|-----------------------------------------|---------------------------|
|  Type of File                           |  Folder                   |
|-----------------------------------------|---------------------------|
| Data cleaning / transformation scripts  | `Project/scripts/`        | 
| Helpers / utilities	                    | `Project/scripts/`        |
| EDA notebooks	                          | `Project/notebooks/`      |
| Plots / visualizations	                | `Project/results/`        |
| Processed datasets	                    | `Project/data/processed/` |
| Report sections	                        | `Project/reports/`        |
|-----------------------------------------|---------------------------|

When adding a new script:

  - Place it in `Project/scripts/`
  - Use the **script index template** above 5 to document it
  - Keep function names descriptive and consistent
  - Include example usage where possible
  

# Notes for Completion (Will Be Removed Later)
<!-- NOTE TO TEAM:
This section should NOT appear in the final deliverable.
It is only guidance during development. -->

  - Keep this README updated as scripts are added
  - Maintain consistent naming patterns
  - Keep examples short and copy/paste friendly
  - Do NOT add EDA results or report content here
  - Before final submission, we will prune placeholder notes