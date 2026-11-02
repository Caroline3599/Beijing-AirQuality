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
date_check <- as.Date(paste(air$year, air$month, air$day, sep = "-"),
                      format = "%Y-%m-%d")
sum(is.na(date_check)) 
air$day[which(bad_day)] <- NA
air$day[which(is.na(date_check))] <- NA

# Q06: Flag `hour` values outside the range 0-23, and set them to NA.
bad_hour <- air$hour < 0 | air$hour > 23
sum(bad_hour, na.rm = TRUE)
air$hour[which(bad_hour)] <- NA

# Q07: Check `temp` values. Cap unusual temperatures outside the realistic range
# (-50 ~ +50 °C) or flag them.
bad_temp <- air$temp < -50 | air$temp > 50
sum(bad_temp, na.rm = TRUE)
air$temp[which(bad_temp)] <- NA


# Q08: Flag pollutant values (PM2.5, PM10, NO2, SO2, CO, O3, PRES) 
# that are zero or negative, and set them to NA.
positive_cols <- c("pm2_5", "pm10", "so2", "no2",
                   "co", "o3", "pres")     
bad_counts <- c()

for (col in positive_cols) {
  bad <- air[[col]] <= 0
  bad_counts[col] <- sum(bad, na.rm = TRUE)  
  air[[col]][which(bad)] <- NA
}

bad_counts


# Q09: Flag meteorological values (RAIN, WSPM) that are negative, and set them to NA.
pos_cols <- c("rain", "wspm")     
neg_counts <- c()

for (col in pos_cols) {
  bad <- air[[col]] < 0
  neg_counts[col] <- sum(bad, na.rm = TRUE)  
  air[[col]][which(bad)] <- NA
}

neg_counts

# Q10: Calculate and report the upper limit (maximum values) 
# for all numeric columns after handling impossible values.
sapply(air[num_cols], max, na.rm = TRUE)


# Q11: Using the 1.5 x IQR rule, how many values in each numeric column 
# are flagged as potential statistical outliers?
count_outliers <- function(x) {
  q     <- quantile(x, c(0.25, 0.75), na.rm = TRUE) 
  iqr   <- q[2] - q[1]                                
  lower <- q[1] - 1.5 * iqr                         
  upper <- q[2] + 1.5 * iqr                         
  sum(x < lower | x > upper, na.rm = TRUE)
}
measure_cols <- c("pm2_5", "pm10", "so2", "no2", "co", "o3",
                  "temp", "pres", "dewp", "rain", "wspm")

outlier_counts <- sapply(air[measure_cols], count_outliers)
outlier_counts

# Q12: What is the sum of potential-outlier counts across all numeric columns? 
# (Remember: unusual is not wrong, keep and flag).
sum(outlier_counts)


# Part 3: Cross-Field Validation & Baseline Export
# ---------------------------------------------------------------------
# Q01: Are all `no` values strictly continuous integers? 
# Check with summary statistics and duplicates.
tapply(air$no, air$station, function(v) all(sort(v) == seq_along(v)))
summary(air$no)
tapply(air$no, air$station, range)
sum(duplicated(air[c("station", "no")]))
all(air$no == round(air$no), na.rm = TRUE)

# Q02: Validate that for each `station`, row numbers (`no`) and datetimes 
# (`year`-`month`-`day`-`hour`) increase strictly and monotonically.
air$datetime <- as.POSIXct(paste(air$year, air$month, air$day, air$hour),
                           format = "%Y %m %d %H", tz = "Asia/Shanghai")
sum(is.na(air$datetime))
air <- air[order(air$station, air$no), ]
rownames(air) <- NULL 
sapply(split(air$no, air$station), function(x) all(diff(x) > 0))
sapply(split(as.numeric(air$datetime), air$station),
       function(x) all(diff(x) > 0, na.rm = TRUE))
sapply(split(as.numeric(air$datetime), air$station),
       function(x) all(diff(x) == 3600, na.rm = TRUE))

# Q03: Ensure all pollutants, rain, and wind speeds satisfy the non-negative constraint (>= 0).
nonneg_cols <- c("pm2_5", "pm10", "so2", "no2", "co", "o3", "rain", "wspm")
nonneg_check <- sapply(air[nonneg_cols], function(x) all(x >= 0, na.rm = TRUE))
nonneg_check
stopifnot(all(nonneg_check))

# Q04: Check that PM10 is greater than or equal to PM2.5 
# (PM2.5 must be a subset of PM10).
bad_pm <- air$pm10 < air$pm2_5
sum(bad_pm, na.rm = TRUE)
round(mean(bad_pm, na.rm = TRUE) * 100, 1)
summary((air$pm2_5 - air$pm10)[which(bad_pm)])
air$pm_flag <- !is.na(bad_pm) & bad_pm
sum(air$pm_flag)

# Q05: Verify that Dew Point (DEWP) does not exceed Air Temperature (TEMP) (DEWP <= TEMP).
sum(air$dewp > air$temp, na.rm = TRUE)

# Q06: Ensure meteorological precipitation (RAIN) is valid and non-negative.
stopifnot(all(air$rain >= 0, na.rm = TRUE))

# Q07: When RAIN > 0, check if DEWP and TEMP are closely aligned 
# (high moisture condition check).
spread <- air$temp - air$dewp     
tapply(spread, air$rain > 0, median, na.rm = TRUE)
sum(air$rain > 0 & spread > 5, na.rm = TRUE)

# Q08: Construct a clean `baseline` dataset by filtering out rows 
#with critical structural/date failures, and export it to an `.rds` file 
baseline <- air[!is.na(air$datetime), ]
nrow(baseline)
saveRDS(baseline, "b_airquality.rds")
check <- readRDS("b_airquality.rds")
dim(check)
identical(baseline, check)
