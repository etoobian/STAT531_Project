# Project/scripts/Final_Data_Cleaning/data_cleaning_final.R
# ------------------------------------------------------------------
#  PROJECT DATA CLEANER (inconsistencies and NA)
# ------------------------------------------------------------------
# Purpose:
#   - Mend noticeable errors/inconsistency with data types, formatting, prior data modifications (some of the 12 bombs), and spelling mistakes to name a few.
#   - Mend NA values seen within the 
#
# NOTES:
#   - May otherwise miss some errors/inconsistencies.
#   - Code with three pound signs are for individual alterations to the data.
#   - Any new NA's are put in place where data is otherwise irretrievable.
#   - Any remaining NA's at the end of execution will be removed as they have been deemed irretrievable.
# ------------------------------------------------------------------

# ------------------------------------------------------------------
# Import additional dependencies (if they are not already loaded in).
# ------------------------------------------------------------------
library(stringr)
library(jsonlite)
library(dplyr)
library(tidyverse)
library(arrow)

# ------------------------------------------------------------------
# Install base unmodified bid data as ad_data.
# ------------------------------------------------------------------
base_data_path = file.path(getwd(), "Project/scripts/data_io.R")
source(base_data_path)
cumulative_ad_data <- ad_data
rm(base_data_path, default_data_folder, default_input_data_file, default_out_base_name, df, pkg, needed_pkgs, default_out_dir, export_ad_data, load_ad_data, summarize_ad_data)

# ------------------------------------------------------------------
#  FINAL DECISIONS REGARDING THE FATE OF ERRORS/INCONSISTENCIES
# ------------------------------------------------------------------
#
#  Template:
#   - [KEY(S)] <DATATYPE(S)>
#   + Decision
#   + Code
#   + Return Type
#
message("\nStarted cleaning of inconsistencies and errors...")
#
#  Decision:
message("Truncating duplicates...")
#   - NO_KEY <NO_TYPE>
#   + It has been confirmed that the duplicates are not natural.
cumulative_ad_data <- unique(cumulative_ad_data)
#   + tibble of size n by 15
message("Finished truncating duplicates.")
#
message("Cleaning PRICE [1]...")
#   - PRICE <chr> 
#   + After accounting for the all values that would result in NA when converting to doubles, PRICE shall now take on the double type.
### idx <- which(substr(ad_data$PRICE, 1, 1)=="O")
### ad_data$PRICE[idx][1] <- "0"
### altered_price_data <- mutate(.data=ad_data, PRICE=as.double(PRICE))
idx <- which(substr(cumulative_ad_data$PRICE, 1, 1)=="O")
cumulative_ad_data$PRICE[idx][1] <- "0"
cumulative_ad_data <- mutate(.data=cumulative_ad_data, PRICE=as.double(PRICE))
rm(idx)
#   + tibble of size n by 15
# 
message("Cleaning PRICE [2]...")
#   - PRICE <double>
#   + Removing nonpositive nonzero values as there is no meaningful way of retrieving the original data.
###altered_price_data <- mutate(.data=ad_data, PRICE=if_else(PRICE < 0, NA, PRICE))
cumulative_ad_data <- mutate(.data=cumulative_ad_data, PRICE=if_else(PRICE==-999, NA, PRICE))
message("Cleaning PRICE [3]...")
###altered_price_data <- mutate(.data=altered_price_data, PRICE=if_else(PRICE < 0, -PRICE, PRICE))
cumulative_ad_data <- mutate(.data=cumulative_ad_data, PRICE=if_else(PRICE < 0, -PRICE, PRICE))
#   + tibble of size n by 15
message("Finished cleaning PRICE.")
#
message("Cleaning DEVICE_GEO_ZIP [1]...")
#   - DEVICE_GEO_ZIP <chr>
#   + DEVICE_GEO_ZIP shall now take on the integer type. We must note that NA values for DEVICE_GEO_ZIP are irretrievable given by:
#     print(summarize(.data=group_by(.data=ad_data, DEVICE_GEO_LAT, DEVICE_GEO_LONG, DEVICE_GEO_CITY, DEVICE_GEO_ZIP), count=n()), n=320)
###altered_device_geo_zip_data <- mutate(.data=ad_data, DEVICE_GEO_ZIP=as.integer(DEVICE_GEO_ZIP))
cumulative_ad_data <- mutate(.data=cumulative_ad_data, DEVICE_GEO_ZIP=as.integer(DEVICE_GEO_ZIP))
#   + tibble of size n by 15
#
message("Cleaning DEVICE_GEO_ZIP [2]...")
#   - DEVICE_GEO_ZIP <int>
#   + ZIPS with negative values (or values that exist below 9000 (doesn't exist)) are retrievable given by:
#     print(summarize(.data=group_by(.data=ad_data, DEVICE_GEO_LAT, DEVICE_GEO_LONG, DEVICE_GEO_CITY, DEVICE_GEO_ZIP), count=n()), n=320)
#     where DEVICE_GEO_LONG and DEVICE_GEO_LAT can be utilized to match zip codes.
###altered_device_geo_zip_data <- mutate(.data=group_by(.data=altered_device_geo_zip_data, DEVICE_GEO_LAT, DEVICE_GEO_LONG), DEVICE_GEO_ZIP=if_else(DEVICE_GEO_ZIP < 9000, first(DEVICE_GEO_ZIP[DEVICE_GEO_ZIP>9000]), DEVICE_GEO_ZIP))
cumulative_ad_data <- ungroup(mutate(.data=group_by(.data=cumulative_ad_data, DEVICE_GEO_LAT, DEVICE_GEO_LONG), DEVICE_GEO_ZIP=if_else(DEVICE_GEO_ZIP < 9000, first(DEVICE_GEO_ZIP[DEVICE_GEO_ZIP>9000]), DEVICE_GEO_ZIP)))
#   + tibble of size n by 15
message("Finished cleaning DEVICE_GEO_ZIP.")
#
message("Cleaning RESPONSE_TIME [1]...")
#   - RESPONSE_TIME <chr>
#   + Reformating entries to have values given by the digits characters of the initial values, then converted such that RESPONSE_TIME shall now take on type integer.
#     Utilizing regex: ^ = start of string, .*? = any characters, \\d = instance of a digit (extra \ to account for the fact that \ is a special character), 
#     + = continue whatever match case until it no longer matches (in this case, match digits until next character isn't a digit).
#     () = capturing group (what we want to capture),
#     .* = discard rest of string.
###altered_response_time_data <- mutate(.data=ad_data, RESPONSE_TIME = sub("^.*?(\\d+).*", "\\1", ad_data$RESPONSE_TIME)) # Removes all but the numeric characters.
###altered_response_time_data <- mutate(.data=altered_response_time, RESPONSE_TIME=as.integer(RESPONSE_TIME)) # Swaps the datatype over to integers.
cumulative_ad_data <- mutate(.data=cumulative_ad_data, RESPONSE_TIME = sub("^.*?(\\d+).*", "\\1", cumulative_ad_data$RESPONSE_TIME)) # Removes all but the numeric characters.
message("Cleaning RESPONSE_TIME [2]...")
cumulative_ad_data <- mutate(.data=cumulative_ad_data, RESPONSE_TIME=as.integer(RESPONSE_TIME)) # Swaps the datatype over to integers.
#   + tibble of size n by 15
message("Finished cleaning RESPONSE_TIME.")
#
message("Cleaning TIMESTAMP, DATE_UTC [1]...")
#   - TIMESTAMP, DATE_UTC <chr, chr>
#   + Providing a single format for which there will be better utilization later.
#   Utilizing regex: "^.*\\s(\\S+)$" looks for the first non-whitespace string starting from the back.
###altered_timestamp_data <- mutate(.data=ad_data, TIMESTAMP = sub("^.*\\s(\\S+)$", "\\1", ad_data$TIMESTAMP))
cumulative_ad_data <- mutate(.data=cumulative_ad_data, TIMESTAMP = sub("^.*\\s(\\S+)$", "\\1", cumulative_ad_data$TIMESTAMP))
# Verifies that all resulting values are of DD:DD:DD where D is a digit. 
# sanity_check <- str_extract(altered_timestamp$TIMESTAMP, "\\b\\d{1,2}:\\d{1,2}:\\d{1,2}\\b")
# Verifies that all resulting values are a valid time format given HH:MM:SS
# time_parts <- str_split(sanity_check, ":", simplify=TRUE)
# hours <- as.numeric(time_parts[,1])
# minutes <- as.numeric(time_parts[,2])
# seconds <- as.numeric(time_parts[,3])
# valid_time <- hours < 24 & hours >= 0 &
#              minutes < 60 & minutes >= 0 &
#              seconds < 60 & seconds >= 0
# unique(valid_time)
###altered_timestamp_data <- mutate(.data=altered_timestamp, TIMESTAMP=paste(DATE_UTC, TIMESTAMP, sep="~"))
message("Cleaning TIMESTAMP, DATE_UTC [2]...")
cumulative_ad_data <- mutate(.data=cumulative_ad_data, TIMESTAMP=paste(DATE_UTC, TIMESTAMP, sep="~"))
#   + tibble of size n x 15
message("Finished cleaning TIMESTAMP, DATE_UTC.")
#
message("Cleaning REQUESTED_SIZE, SIZE [1]...")
#   - REQUESTED_SIZE, SIZE <chr, chr>
#   + Changing all instances of "0x0" and "1x1" to intended size after converting REQUESTED_SIZES back into an array of character vectors.
#     This turns all "0x0" and "1x1" SIZE values into corresponding REQUESTED_SIZES value if REQUESTED_SIZES is of length 1. If not, it provides an NA value as there is no method of obtaining the actual size.
#     It is good to note that the form in which REQUESTED_SIZES value takes is that of a JSON string.
###altered_req_size_size_data <- mutate(.data=rowwise(ad_data), REQUESTED_SIZES=list(fromJSON(REQUESTED_SIZES)))
###incorrect_sizes <- c("1x1", "0x0")
###altered_req_size_size_data <- mutate(.data=rowwise(altered_req_size_size), SIZE=if(SIZE %in% incorrect_sizes) { if (length(REQUESTED_SIZES) == 1) { REQUESTED_SIZES[[1]] } else { NA } } else { SIZE })
cumulative_ad_data <- ungroup(mutate(.data=rowwise(cumulative_ad_data), REQUESTED_SIZES=list(fromJSON(REQUESTED_SIZES))))
message("Cleaning REQUESTED_SIZE, SIZE [2]...")
incorrect_sizes <- c("1x1", "0x0")
cumulative_ad_data <- ungroup(mutate(.data=rowwise(cumulative_ad_data), SIZE=if(SIZE %in% incorrect_sizes) { if (length(REQUESTED_SIZES) == 1) { REQUESTED_SIZES[[1]] } else { NA } } else { SIZE }))
rm(incorrect_sizes)
#   + tibble of size n x 15
message("Finished cleaning REQUESTED_SIZE, SIZE.")
#
message("Cleaning DEVICE_GEO_LONG [1]...")
#   - DEVICE_GEO_LONG <dbl>
#   + Modifying the invalid values in DEVICE_GEO_LONG.
###altered_device_geo_long_data <- mutate(.data=ad_data, DEVICE_GEO_LONG=if_else(DEVICE_GEO_LONG < -130, DEVICE_GEO_LONG + 10, DEVICE_GEO_LONG))
cumulative_ad_data <- mutate(.data=cumulative_ad_data, DEVICE_GEO_LONG=if_else(DEVICE_GEO_LONG < -130, DEVICE_GEO_LONG + 10, DEVICE_GEO_LONG))
#   + tibble of size n x 15
message("Finished cleaning DEVICE_GEO_LONG.")
#
message("Cleaning DEVICE_GEO_REGION [1]...")
#   - DEVICE_GEO_REGION <chr>
#   + Setting all values to OR.
###altered_device_geo_region <- mutate(.data=ad_data, DEVICE_GEO_REGION="OR")
cumulative_ad_data <- mutate(.data=cumulative_ad_data, DEVICE_GEO_REGION="OR")
#   + tibble of size n x 15
message("Finished cleaning DEVICE_GEO_REGION.")
#
message("Cleaning BID_WON [1] ...")
#   - BID_WON <chr>
#   + BID_WON shall now take on the logical type.
###altered_bid_won_data <- mutate(.data=ad_data, BID_WON=ifelse(tolower(BID_WON)=="TRUE", TRUE, FALSE))
cumulative_ad_data <- mutate(.data=cumulative_ad_data, BID_WON=ifelse(tolower(BID_WON)=="true", TRUE, FALSE))
#   + tibble of size n x 15
message("Finished cleaning BID_WON.")
message("\n Finished cleaning up inconsistencies and errors.")
message("\n Started cleaning up NA values...")
#
message("Cleaning DEVICE_GEO_ZIP [1]...")
#   - DEVICE_GEO_ZIP <int> 
#   + NA values that exist in DEVICE_GEO_ZIP will be recovered using DEVICE_GEO_LAT and DEVICE_GEO_LONG.
###altered_device_geo_zip_data <- ungroup(mutate(.data=group_by(.data=ad_data, DEVICE_GEO_LAT, DEVICE_GEO_LONG), DEVICE_GEO_ZIP=if_else(is.na(DEVICE_GEO_ZIP), first(DEVICE_GEO_ZIP[!is.na(DEVICE_GEO_ZIP)]), DEVICE_GEO_ZIP)))
cumulative_ad_data <- ungroup(mutate(.data=group_by(.data=cumulative_ad_data, DEVICE_GEO_LAT, DEVICE_GEO_LONG), DEVICE_GEO_ZIP=if_else(is.na(DEVICE_GEO_ZIP), first(DEVICE_GEO_ZIP[!is.na(DEVICE_GEO_ZIP)]), DEVICE_GEO_ZIP)))
#   + tibble of size n x 15
message("Finished cleaning DEVICE_GEO_ZIP.")
#
message("Cleaning DEVICE_GEO_CITY [1]...")
#   - DEVICE_GEO_CITY <chr>
#   + NA values that exist in DEVICE_GEO_CITY will be recovered using DEVICE_GEO_LAT and DEVICE_GEO_LONG
###altered_device_geo_city <- ungroup(mutate(.data=group_by(.data=ad_data, DEVICE_GEO_LAT, DEVICE_GEO_LONG), DEVICE_GEO_CITY=if_else(is.na(DEVICE_GEO_CITY), first(DEVICE_GEO_CITY[!is.na(DEVICE_GEO_CITY)]), DEVICE_GEO_CITY)))
cumulative_ad_data <- ungroup(mutate(.data=group_by(.data=cumulative_ad_data, DEVICE_GEO_LAT, DEVICE_GEO_LONG), DEVICE_GEO_CITY=if_else(is.na(DEVICE_GEO_CITY), first(DEVICE_GEO_CITY[!is.na(DEVICE_GEO_CITY)]), DEVICE_GEO_CITY)))
#   + tibble of size n x 15
message("Finished cleaning DEVICE_GEO_CITY.")
message("\n Finished cleaning up NA values.")
message("\n Truncating all remaining NA values...")
cumulative_ad_data <- na.omit(cumulative_ad_data)
message("\n Finished truncating all remaining NA values.")
message("\n Finished the cleaning procedure.")