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
#  NOTED ERRORS/INCONSITENCIES
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
#  DETERMINATION OF IMPORTANCE FOR ERRORS/INCONSISTENCIES
# ------------------------------------------------------------------
#   
#  Template:
#   - [KEY(S)] <DATATYPE(S)>
#   + Notes on importance.
#
