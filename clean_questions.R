# =====================================================================
# BEIJING AIR QUALITY DATA CLEANING SCRIPT CHECKLIST
# =====================================================================

# Part 1: Standardize & Structure (Lecture 5A)
# ---------------------------------------------------------------------
# Q01: Import "2. Beijing_AirQuality.csv" without altering column names. 
# How many cols and rows exist in raw data?

# Q02: Create a copy of the dataset for cleaning (`air`). 
# Clean column names to lowercase and replace spaces/punctuation with underscores.

# Q03: Inspect dataset structure. Which columns are numeric in R? 
# Which are text? Create `num_cols` and `char_cols` variables.

# Q04: Count the number of missing values (NA) for each column in the raw data.

# Q05: How many exact duplicated rows exist in the dataset? 
# Remove them and verify the new row count.

# Q06: Trim leading/trailing whitespace from all character columns, 
# and convert blank strings ("") to NA.

# Q07: Standardize the `station` column categories to lowercase to ensure consistency.

# Q08: Define the strict 16 compass wind directions (e.g., N, NNE, NE...). 
# How many `wd` values match these patterns? Set non-matching/invalid values to NA.


# Part 2: Cleaning Numbers (Lecture 5B)
# ---------------------------------------------------------------------
# Q01: Count missing values (NA) specifically across all numeric columns.

# Q02: Flag `no` values that are zero or negative, and set them to NA.

# Q03: Flag `year` values that are zero, negative, or out of expected range 
# (e.g., < 2000 or > 2030), and set them to NA.

# Q04: Flag `month` values outside the range 1-12, and set them to NA.

# Q05: Flag `day` values outside the range 1-31 (or invalid for specific months), 
# and set them to NA.

# Q06: Flag `hour` values outside the range 0-23, and set them to NA.

# Q07: Check `temp` values. Cap unusual temperatures outside the realistic range
# (-50 ~ +50 °C) or flag them.

# Q08: Flag pollutant values (PM2.5, PM10, NO2, SO2, CO, O3, PRES) 
# that are zero or negative, and set them to NA.

# Q09: Flag meteorological values (RAIN, WSPM) that are negative, and set them to NA.

# Q10: Calculate and report the upper limit (maximum values) 
# for all numeric columns after handling impossible values.


# Q11: Using the 1.5 x IQR rule, how many values in each numeric column 
# are flagged as potential statistical outliers?

# Q12: What is the sum of potential-outlier counts across all numeric columns? 
# (Remember: unusual is not wrong, keep and flag).



# Part 3: Cross-Field Validation & Baseline Export
# ---------------------------------------------------------------------
# Q01: Are all `no` values strictly continuous integers? 
# Check with summary statistics and duplicates.

# Q02: Validate that for each `station`, row numbers (`no`) and datetimes 
# (`year`-`month`-`day`-`hour`) increase strictly and monotonically.

# Q03: Ensure all pollutants, rain, and wind speeds satisfy the non-negative constraint (>= 0).

# Q04: Check that PM10 is greater than or equal to PM2.5 
# (PM2.5 must be a subset of PM10).

# Q05: Verify that Dew Point (DEWP) does not exceed Air Temperature (TEMP) (DEWP <= TEMP).

# Q06: Ensure meteorological precipitation (RAIN) is valid and non-negative.

# Q07: When RAIN > 0, check if DEWP and TEMP are closely aligned 
# (high moisture condition check).

# Q08: Construct a clean `baseline` dataset by filtering out rows 
#with critical structural/date failures, and export it to an `.rds` file 

