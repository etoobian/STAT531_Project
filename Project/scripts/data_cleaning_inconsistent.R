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
#   - PRICE <chr> <*****>
#   + For ease of data processing, I believe that converting the column price in type double (after ensuring that all values follow a double type (i.e. no "five point eight" values)) will be highly beneficial.
#   - PRICE <chr> <*****>
#   + Removing outliers (negative values) will improve accuracy, therefore we should look to remove negative values as there is appears to be no pattern that would allow us to recover the underlying data without introducing error.
#   - DEVICE_GEO_ZIP <chr> <*****> 
#   + The more numerical values we have, the easier it would be for us to find patterns we otherwise couldn't see.
#   - DEVICE_GEO_ZIP <chr> <*****>
#   + Removing outliers (negative values) will improve accuracy. We could not effectively deduce what value of DEVICE_GEO_ZIP based on DEVICE_GEO_CITY (Portland contains multiple ZIP codes, majority if not all -999 ZIP code values are from Portland).
#   - TIMESTAMP <chr> <****>
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
#   - RESPONSE_TIME <chr> <*****>
#   + Formatting then converting RESPONSE_TIME into type integer would improve accuracy.
#   - REQUESTED_SIZE, SIZE <chr, chr> <*****>
#   + Establishing correct SIZE values along with converting REQUESTED_SIZE back into an character array would allow us to establish select parameters like Price Per Pixel (price / width * height).
# ------------------------------------------------------------------

