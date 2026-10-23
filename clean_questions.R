# =====================================================================
# BEIJING AIR QUALITY DATA CLEANING SCRIPT CHECKLIST
# =====================================================================

# Part 1: Standardize & Structure (Lecture 5A)
# ---------------------------------------------------------------------
# Q01: Import "2. Beijing_AirQuality.csv" without altering column names. 
# How many cols and rows exist in raw data?
beijing_airquality <- read.csv("./Instruction/2. Beijing_AirQuality.csv",
                               check.names = FALSE,
                               stringsAsFactors = FALSE)
names(beijing_airquality)
dim(beijing_airquality)


# Q02: Create a copy of the dataset for cleaning (`air`). 
# Clean column names to lowercase and replace spaces/punctuation with underscores.
air <- beijing_airquality
cols_clean <- tolower(names(air))
cols_clean <-gsub("[^a-z0-9]+", "_", cols_clean) 
cols_clean <- gsub("^_|_$", "", cols_clean)
names(air) <- cols_clean
names(air)

# Q03: Inspect dataset structure. Which columns are numeric in R? 
# Which are text? Create `num_cols` and `char_cols` variables.
str(air)
num_cols <- names(air)[sapply(air, is.numeric)]
char_cols <- names(air)[sapply(air, is.character)]

num_cols
char_cols

# Q04: Count the number of missing values (NA) for each column in the raw data.
na_counts <- colSums(is.na(air))
na_counts

# Q05: How many exact duplicated rows exist in the dataset? 
# Remove them and verify the new row count.
air_dup <- duplicated(air)
sum(air_dup)
air <- air[!air_dup, ]
nrow(air)

# 7900 duplicates with 175320 rows remaining

# Q06: Trim leading/trailing whitespace from all character columns, 
# and convert blank strings ("") to NA.
before <- air[char_cols]  
air[char_cols] <- lapply(air[char_cols], function(x) {
  x <- trimws(x)
  x[x == ""] <- NA
  x
})

sum(before != air[char_cols], na.rm = TRUE)
sum(is.na(air[char_cols])) - sum(is.na(before))

air$station

# Q07: Standardize the `station` column categories to lowercase to ensure consistency.
air$station <- tolower(air$station)
unique(air$station)
table(air$station)

# 5 stations, 35064 rows each

# Q08: Define the strict 16 compass wind directions (e.g., N, NNE, NE...). 
# How many `wd` values match these patterns? Set non-matching/invalid values to NA.
valid_wd <- c("N", "E", "S", "W", 
              "NE", "SE", "SW", "NW", 
              "NNE", "ENE", "ESE", "SSE", 
              "SSW", "WSW", "WNW", "NNW")
air$wd <- toupper(air$wd)
is_valid <- air$wd %in% valid_wd
sum(is_valid)
air$wd[!is_valid] <- NA


#checkk
length(valid_wd)
table(air$station)
sum(is.na(air$wd))

# Part 2: Cleaning Numbers (Lecture 5B)
# ---------------------------------------------------------------------
# Q01: Count missing values (NA) specifically across all numeric columns.
colSums(is.na(air[num_cols]))

# Q02: Flag `no` values that are zero or negative, and set them to NA.
bad_no <- air$no <= 0
sum(bad_no, na.rm = TRUE)
air$no[which(bad_no)] <- NA

# Q03: Flag `year` values that are zero, negative, or out of expected range 
# (e.g., < 2000 or > 2030), and set them to NA.
bad_year <- air$year < 2000 | air$year > 2030
sum(bad_year, na.rm = TRUE)
air$year[which(bad_year)] <- NA

# Q04: Flag `month` values outside the range 1-12, and set them to NA.
bad_month <- air$month < 1 | air$month > 12
sum(bad_month, na.rm = TRUE)
air$month[which(bad_month)] <- NA


# Q05: Flag `day` values outside the range 1-31 (or invalid for specific months), 
# and set them to NA.
bad_day <- air$day < 1 | air$day > 31
sum(bad_day, na.rm = TRUE)
air$day[which(bad_day)] <- NA


# Q06: Flag `hour` values outside the range 0-23, and set them to NA.
bad_hour <- air$hour < 0 | air$hour > 24
sum(bad_hour, na.rm = TRUE)
air$hour[which(bad_hour)] <- NA

# Q07: Check `temp` values. Cap unusual temperatures outside the realistic range
# (-50 ~ +50 °C) or flag them.
bad_temp <- air$temp < -50 | air$temp > 50
sum(bad_temp, na.rm = TRUE)
air$temp[which(bad_temp)] <- NA


# Q08: Flag pollutant values (PM2.5, PM10, NO2, SO2, CO, O3, PRES) 
# that are zero or negative, and set them to NA.
pollutants <- c("pm2_5", "pm10", "so2", "no2",
              "co", "o3", "temp",  "pres")
bad_poll <- pollutants <= 0
sum(bad_poll, na.rm = TRUE)
pollutants[which(bad_poll)] <- NA


# Q09: Flag meteorological values (RAIN, WSPM) that are negative, and set them to NA.

# Q10: Calculate and report the upper limit (maximum values) 
# for all numeric columns after handling impossible values.
sapply(air[num_cols], max, na.rm = TRUE)


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

