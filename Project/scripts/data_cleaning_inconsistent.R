# Project/scripts/data_cleaning_inconsistent.R
# ------------------------------------------------------------------
#  PROJECT DATA CLEANER (inconsistencies)
# ------------------------------------------------------------------
# Purpose:
#   - Document noticeable errors/inconsistency with data types, formatting, prior data modifications (some of the 12 bombs), and spelling mistakes to name a few.
#
# NOTES:
#   - May otherwise miss some errors/inconsistencies.
# ------------------------------------------------------------------

# ------------------------------------------------------------------
#  NOTED ERRORS/INCONSITENCIES (KAN-18)
# ------------------------------------------------------------------
#   
#  Template:
#   - [KEY(S)] <DATATYPE(S)>: Error
#   + [Code if applicable]
#   + [Note if applicable]
#
#  Errors/Inconsistencies:
#   - PRICE <chr>: Should be of data type double.
#   - DEVICE_GEO_ZIP <chr>: Should be of data type integer.
#   - TIMESTAMP <chr>: Inconsistent formatting.
#   - TIMESTAMP <chr>: Data set is not sorted chronologically.
#   - DEVICE_GEO_LONG <dbl>: There exists exactly 100 points that lie beyond the border of Oregon.
#   + print(filter(.data=ad_data, DEVICE_GEO_LONG < -130), n=20)
#   + These points lie exactly 10 degrees to the west of corresponding city longitudinal values.
#   - PRICE <chr>: There exist prices that are negative.
#   - PRICE <chr>: There exist negative prices that have BID_WON==TRUE.
#   - PRICE <chr>: There exist prices that are close to -1000 (-999).
#   - BID_WON <chr>: Should be of data type logical.
#   - AUCTION_ID, BID_WON <chr, chr>: There are bids with multiple wins.
#   + filter(.data=summarise(.data=ad_data, won=sum(BID_WON=="TRUE"), lost=sum(BID_WON=="FALSE"), total=n()), won > 1)
#   + The existence of an auction have 6 winners can indicate that no shifting of columns occurred.
#   - TIMESTAMP, DATE_UTC <chr, chr>: DATE_UTC does not reflect days properly according to timezone differences.
#   + Helpful since DATE_UTC reflects PST, which we can utilize to correctly index existing TIMESTAMP values.
#   - DEVICE_GEO_REGION <chr>: Inconsistent formatting.
#   - DEVICE_GEO_CITY <chr>: Existence of non-cities (unincorporated communities, CDPs, etc.).
#   + print(unique(ad_data$DEVICE_GEO_CITY), n=100, na.print=".")
#   + Possibly negligible.
#   - DEVICE_GEO_ZIP <chr>: There exists a negative ZIP code (-999).
#   - RESPONSE_TIME <chr>: Should be of type integer.
#   + The last three-four characters should contain the desired information.
#   - RESPONSE_TIME <chr>: Inconsistent formatting.
#   + There exists at least one RESPONSE_TIME value that has the following delimiter RESSPONSE_TIME (as opposed to RESPONSE_TIME).
#   - REQUESTED_SIZE, SIZE <chr, chr>: There exists requested sizes of 0x0 and 1x1 that also do not meet requested size specifications despite have BID_WON==TRUE
#   + We would not be able to determine the actual size won for these invalid SIZE values if REQUESTED_SIZE contains more than 2 requested sizes. 
#
#  Tested for:
#   - Multiple time entries for distinct AUCTION_ID.
#   - Pattern in inconsistent formatting for TIMESTAMP
#   + Could be an issue with it being not in chronological order (error applied before scrambling).
#   - Noted that some cities encompass more than 20 zip codes in DEVICE_GEO_ZIP and DEVICE_GEO_ZIP
#   - Noted that at least some AUCTION_ID values are encompassed purely by one bider in PUBLISHER_ID (one bider bidding multiple times).
#   + For further exploration, we can potentially re-order these instances in chronological order potentially by ordering by RESPONSE_TIME
# ------------------------------------------------------------------

# ------------------------------------------------------------------
#  DETERMINATION OF IMPORTANCE FOR ERRORS/INCONSISTENCIES (KAN-19)
# ------------------------------------------------------------------
#   
#  Template:
#   - [KEY(S)] <DATATYPE(S)> <IMPORTANCE LEVEL in *'s>
#   + Notes on importance.
#
#  Importance:
#   - PRICE <chr> <*****> ✔️
#   + For ease of data processing, I believe that converting the column price in type double (after ensuring that all values follow a double type (i.e. no "five point eight" values)) will be highly beneficial.
#   - PRICE <chr> <*****> ✔️
#   + Removing outliers (negative values) will improve accuracy, therefore we should look to remove negative values as there is appears to be no pattern that would allow us to recover the underlying data without introducing error.
#   - DEVICE_GEO_ZIP <chr> <*****> ✔️
#   + The more numerical values we have, the easier it would be for us to find patterns we otherwise couldn't see.
#   - DEVICE_GEO_ZIP <chr> <*****> ✔️
#   + Removing outliers (negative values) will improve accuracy. We could not effectively deduce what value of DEVICE_GEO_ZIP based on DEVICE_GEO_CITY (Portland contains multiple ZIP codes, majority if not all -999 ZIP code values are from Portland).
#   - TIMESTAMP <chr> <****> ✔️
#   + Providing a consistent formating for TIMESTAMP would allow for ease of conversion into numerical representation.
#   - TIMESTAMP <chr> <***>
#   + Sorting TIMESTAMP into chronological order would allow for the creation of parameters that are typically seen in time-series data (moving averages, lag, etc.). However given we have 400k+ rows of data (~100k+ rows if you collapse by AUCTION_ID and BID_WON), it will take a while to sort.
#   - BID_WON <chr> <*>
#   + Converting BID_WON into type logical would not really make a difference as we can easily query through the three existing unique values of TRUE, true, and FALSE.
#   - DEVICE_GEO_LONG <dbl> <***>
#   + Given that only 100 data points out of the 400k+ contain invalid longitudinal points, these points can be thrown out. It is also easily deducible that these 100 points are exactly 10 degrees further to the west than their respective counterparts (when sorted by DEVICE_GEO_CITY, DEVICE_GEO_ZIP and DEVICE_GEO_LONG).
#   - AUCTION_ID, BID_WON <chr, chr> <****>
#   + Deducing whether or not it's possible for an auction to have multiple winners is going to be relatively important. If we deduce it is not important, there is no effective way of determining which bid actually won, and therefore we can throw them out.
#   - DEVICE_GEO_REGION <chr> <*>
#   + We know that this data exclusively comes from Oregon, therefore we can just set all values to Oregon (or OR).
#   - DEVICE_GEO_CITY <chr> <>
#   + I don't see why we would remove non-cities from DEVICE_GEO_CITY. Maybe a name change for the column would better reflect the data.
#   - RESPONSE_TIME <chr> <*****> ✔️
#   + Formatting then converting RESPONSE_TIME into type integer would improve accuracy.
#   - REQUESTED_SIZE, SIZE <chr, chr> <*****> ✔️
#   + Establishing correct SIZE values along with converting REQUESTED_SIZE back into an character array would allow us to establish select parameters like Price Per Pixel (price / width * height).
# ------------------------------------------------------------------

# ------------------------------------------------------------------
# Import additional dependencies.
# ------------------------------------------------------------------
library(stringr)
library(jsonlite)

# ------------------------------------------------------------------
# Install base unmodified bid data as ad_data.
# ------------------------------------------------------------------
base_data_path = file.path(getwd(), "Project/scripts/load_data.R")
source(base_data_path)

# ------------------------------------------------------------------
#  FINAL DECISIONS REGARDING THE FATE OF ERRORS/INCONSISTENCIES (KAN-20/KAN-21)
# ------------------------------------------------------------------
#
#  Template:
#   - [KEY(S)] <DATATYPE(S)>
#   + Decision
#   + Code
#   + Return Type
#
#  Decision:
#   - PRICE <chr> 
#   + After accounting for the all values that would result in NA when converting to doubles, PRICE shall now take on the double type.
idx <- which(substr(ad_data$PRICE, 1, 1)=="O")
ad_data$PRICE[idx][1] <- "0"
altered_price_data <- mutate(.data=ad_data, PRICE=as.double(PRICE))
#   + tibble of size n by 15
# 
#   - PRICE <double>
#   + Removing nonpositive nonzero values as there is no meaningful way of retrieving the original data.
altered_price_data <- filter(.data=altered_price_data, PRICE > 0)
#   + tibble of size n by 15
#
#   - DEVICE_GEO_ZIP <chr>
#   + DEVICE_GEO_ZIP shall now take on the integer type. We must note that NA values for DEVICE_GEO_ZIP are irretrievable given by:
#     print(summarize(.data=group_by(.data=ad_data, DEVICE_GEO_LAT, DEVICE_GEO_LONG, DEVICE_GEO_CITY, DEVICE_GEO_ZIP), count=n()), n=320)
altered_device_geo_zip_data <- mutate(.data=ad_data, DEVICE_GEO_ZIP=as.integer(DEVICE_GEO_ZIP))
#   + tibble of size n by 15
#
#   - DEVICE_GEO_ZIP <int>
#   + ZIPS with negative values (or values that exist below 9000 (doesn't exist)) are irretrievable given by:
#     print(summarize(.data=group_by(.data=ad_data, DEVICE_GEO_LAT, DEVICE_GEO_LONG, DEVICE_GEO_CITY, DEVICE_GEO_ZIP), count=n()), n=320)
altered_device_geo_zip_data <- filter(.data=altered_device_geo_zip_data, DEVICE_GEO_ZIP > 9000)
#   + tibble of size n by 15
#
#   - RESPONSE_TIME <chr>
#   + Reformating entries to have values given by the last characters of the initial values, then converted such that RESPONSE_TIME shall now take on type integer.
#     Utilizing regex: ^ = start of string, .*? = any characters, \\d = instance of a digit (extra \ to account for the fact that \ is a special character), 
#     + = continue whatever match case until it no longer matches (in this case, match digits until next character isn't a digit).
#     () = capturing group (what we want to capture),
#     .* = discard rest of string.
altered_response_time <- mutate(.data=ad_data, RESPONSE_TIME = sub("^.*?(\\d+).*", "\\1", ad_data$RESPONSE_TIME)) # Removes all but the numeric characters.
altered_response_time <- mutate(.data=altered_response_time, RESPONSE_TIME=as.integer(RESPONSE_TIME)) # Swaps the datatype over to integers.
#   + tibble of size n by 15
#
#   - TIMESTAMP, DATE_UTC <chr, chr>
#   + Providing a single format for which there will be better utilization later.
#   Utilizing regex: "^.*\\s(\\S+)$" looks for the first non-whitespace string starting from the back.
altered_timestamp <- mutate(.data=ad_data, TIMESTAMP = sub("^.*\\s(\\S+)$", "\\1", ad_data$TIMESTAMP))
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
altered_timestamp <- mutate(.data=altered_timestamp, TIMESTAMP=paste(DATE_UTC, TIMESTAMP, sep="~"))
#   + tibble of size n x 15
#
#   - REQUESTED_SIZE, SIZE <chr, chr>
#   + Changing all instances of "0x0" and "1x1" to intended size after converting REQUESTED_SIZES back into an array of character vectors.
#     This turns all "0x0" and "1x1" SIZE values into corresponding REQUESTED_SIZES value if REQUESTED_SIZES is of length 1. If not, it provides an NA value as there is no method of obtaining the actual size.
#     It is good to note that the form in which REQUESTED_SIZES value takes is that of a JSON string.
altered_req_size_size <- mutate(.data=rowwise(ad_data), REQUESTED_SIZES=list(fromJSON(REQUESTED_SIZES)))
incorrect_sizes <- c("1x1", "0x0")
altered_req_size_size <- mutate(.data=rowwise(altered_req_size_size), SIZE=if(SIZE %in% incorrect_sizes) { if (length(REQUESTED_SIZES) == 1) { REQUESTED_SIZES[[1]] } else { NA } } else { SIZE })
#   + tibble of size n x 15
