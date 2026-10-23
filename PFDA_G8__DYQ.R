# Duan Yuqing, TP114820

# Data Cleaning
# -------------
# No must be a whole number, 1 or more; problem: missing, zero or negative, with decimals
# year must be a valid 4-digit year; problem: missing, zero or negative, out of range
# month must be an integer from 1 to 12; problem: missing, zero or negative, outside the scale
# day must be an integer from 1 to 31; problem: missing, zero or negative, outside the scale
# hour must be an integer from 0 to 23; problem: missing, negative, outside the scale
# PM2.5 must be 0 or more; problem: missing, negative, extreme or very high
# PM10 must be 0 or more; problem: missing, negative, extreme or very high
# SO2 must be 0 or more; problem: missing, negative, extreme or very high
# NO2 must be 0 or more; problem: missing, negative, extreme or very high
# CO must be 0 or more; problem: missing, negative, extreme or very high
# O3 must be 0 or more; problem: missing, negative, extreme or very high
# TEMP must be within a realistic temperature range; problem: missing, extreme or unrealistic values
# PRES must be a positive value representing atmospheric pressure; problem: missing, zero or negative, extreme values
# DEWP must be within a realistic dew point range; problem: missing, extreme or unrealistic values
# RAIN must be 0 or more; problem: missing, negative, extreme or very high
# WSPM must be 0 or more; problem: missing, negative, extreme or very high

# Part 1: Standardize & Structure (Lecture 5A)
# ---------------------------------------------------------------------
# Q01: Import "2. Beijing_AirQuality.csv" without altering column names. 
# How many cols and rows exist in raw data?
air <- read.csv("./instruction/2. Beijing_AirQuality.csv")
dim(air) # [1] 183220     18
summary(air$TEMP)

# Q02: Create a copy of the dataset for cleaning (`air`). 
# Clean column names to lowercase and replace spaces/punctuation with underscores.
clean <- air
names(clean) <- trimws(tolower(names(clean)))


# Q03: Inspect dataset structure. Which columns are numeric in R? 
# Which are text? Create `num_cols` and `char_cols` variables.
num_cols <- sapply(clean, is.numeric)
char_cols <- sapply(clean, is.character)


# Q04: Count the number of missing values (NA) for each column in the raw data.
colSums(is.na(clean))
# no    year   month     day    hour   pm2.5    pm10     so2     no2 
# 0       0       0       0       0    3655    2770    3612    6498 
# co       o3      temp     pres    dewp    rain      wd    wspm station 
# 10281    6127     211     209     213     205     843     175       0 


# Q05: How many exact duplicated rows exist in the dataset? 
# Remove them and verify the new row count.
sum(duplicated(clean))
clean <- clean[!duplicated(clean), ]
dim(clean) # [1] 175320     18


# Q06: Trim leading/trailing whitespace from all character columns, 
# and convert blank strings ("") to NA.
clean[char_cols] <- lapply(clean[char_cols], function(x) {
  x <- trimws(x)
  x[x == ""] <- NA
  return(x)
})
colSums(is.na(clean))
# no    year   month     day    hour   pm2.5    pm10     so2     no2 
# 0       0       0       0       0    3510    2651    3455    6212 
# co      o3      temp    pres    dewp    rain      wd    wspm station 
# 9844    5865     195     193     197     189     802     162       0 


# Q07: Standardize the `station` column categories to lowercase to ensure consistency.
clean$station <- tolower(clean$station)
unique(clean$station)


# Q08: Define the strict 16 compass wind directions (e.g., N, NNE, NE...). 
# How many `wd` values match these patterns? Set non-matching/invalid values to NA.
clean$wd <- tolower(clean$wd)
unique(clean$wd)


# Part 2: Cleaning Numbers (Lecture 5B)
# ---------------------------------------------------------------------
# Q01: Count missing values (NA) specifically across all numeric columns.
colSums(is.na(clean[num_cols]))
# no  year month   day  hour pm2.5  pm10   so2   no2    co    o3  temp 
# 0     0     0     0     0  3510  2651  3455  6212  9844  5865   195 
# pres  dewp  rain  wspm 
# 193   197   189   162 

# Q02: Flag `no` values that are zero or negative, and set them to NA.
sum(clean[clean$no <= 0])


# Q03: Flag `year` values that are zero, negative, or out of expected range 
# (e.g., < 2000 or > 2030), and set them to NA.
summary(clean$year)
sort(unique(clean$year))

# Q04: Flag `month` values outside the range 1-12, and set them to NA.
sort(unique(clean$month), decreasing = FALSE)

# Q05: Flag `day` values outside the range 1-31 (or invalid for specific months), 
# and set them to NA.
sort(unique(clean$day))

# Q06: Flag `hour` values outside the range 0-23, and set them to NA.
sort(unique(clean$hour))
clean$flag_hour_invalid <- !is.na(clean$hour) & (clean$hour < 0 | clean$hour > 23)
sum(clean$flag_hour_invalid, na.rm = TRUE)
clean$hour[clean$flag_hour_invalid] <- NA
sum(is.na(clean$hour))

# Q07: Check `temp` values. Cap unusual temperatures outside the realistic range
# (-50 ~ +50 °C) or flag them.
summary(clean$temp) 
# Min.        1st Qu.   Median     Mean  3rd Qu.     Max.     NA's 
# -999.000    3.033   14.400   12.841   23.100   41.600      195 
sum(is.na(clean$temp)) # 195
clean$flag_temp_invalid <- (clean$temp < -50 | clean$temp > 50) & !is.na(clean$temp)
sum(clean$flag_temp_invalid) # 100
clean$temp[clean$flag_temp_invalid] <- NA
sum(is.na(clean$temp)) # 295
summary(clean$temp)


# Q08: Flag pollutant values (PM2.5, PM10, NO2, SO2, CO, O3, PRES) 
# that are zero or negative, and set them to NA.
target_cols <- c("pm2.5", "pm10", "no2", "so2", "co", "o3", "pres")
summary(clean[target_cols])

# Q09: Flag meteorological values (RAIN, WSPM) that are negative, and set them to NA.
summary(clean[c("rain", "wspm")])
sum(is.na(clean$wspm)) # 162
sort(unique(clean$wspm))
clean$flag_wspm_invalid <- !is.na(clean$wspm) & clean$wspm < 0
sum(clean$flag_wspm_invalid) # 329
clean$wspm[clean$flag_wspm_invalid] <- NA
sum(is.na(clean$wspm)) # 491
summary(clean$wspm)

# Q10: Calculate and report the upper limit (maximum values) 
# for all numeric columns after handling impossible values.
summary(clean[num_cols])
get_upper <- function(col) {
  q1 <- quantile(col, 0.25, na.rm = TRUE)
  q3 <- quantile(col, 0.75, na.rm = TRUE)
  iqr = q3 - q1
  upper <- q3 + 1.5*iqr
  return(upper)
}

for(name in names(num_cols)[num_cols == TRUE]) {
  print(paste(name, ":", get_upper(clean[[name]])))
}


# Q11: Using the 1.5 x IQR rule, how many values in each numeric column 
# are flagged as potential statistical outliers?
set_outlier <- function(col_name, df = clean) {
  col <- df[[col_name]]
  q1 <- quantile(col, 0.25, na.rm = TRUE)
  q3 <- quantile(col, 0.75, na.rm = TRUE)
  iqr = q3 - q1
  upper <- q3 + 1.5*iqr
  # outlier column name
  flag_name <- paste0("flag_", gsub("\\.", "", col_name), "_outlier")
  df[[flag_name]] <- !is.na(col) & col > upper
  print(paste(col_name, ":", sum(df[[flag_name]], na.rm = TRUE), "(no of outliers)"))
  
  return(df)
}
for(name in names(num_cols)[num_cols == TRUE]) {
  clean <- set_outlier(name, clean)
}
str(clean)

# Q12: What is the sum of potential-outlier counts across all numeric columns? 
# (Remember: unusual is not wrong, keep and flag).
outlier_col <- grep("_outlier$", names(clean), value = TRUE)
sum_outlier <- sum(sapply(clean[outlier_col], sum), na.rm = TRUE)
sum_outlier

# Part 3: Cross-Field Validation & Baseline Export
# ---------------------------------------------------------------------
# Q01: Are all `no` values strictly continuous integers? 
# Check with summary statistics and duplicates.
sum(duplicated(clean$no))
tapply(clean$no, clean$station, function(x) {
  all_unique <- length(unique(x)) == length(x)
  is_continous <- max(x) - min(x) + 1 == length(x)
  return(c(Unique = all_unique, Continous = is_continous))
})

# Q02: Validate that for each `station`, row numbers (`no`) and datetimes 
# (`year`-`month`-`day`-`hour`) increase strictly and monotonically.
clean$datetime <- as.POSIXct(paste(clean$year, clean$month, clean$day, clean$hour, sep = "-"), 
                             format = "%Y-%m-%d-%H", tz = "UTC")
clean <- clean[order(clean$station, clean$datetime), ]
time_seq_check <- aggregate(datetime ~ station, data = clean, function(x) {
  all(diff(x) > 0)
})
time_seq_check
sum(is.na(clean$datetime))

# Q03: Ensure all pollutants, rain, and wind speeds satisfy the non-negative constraint (>= 0).
summary(clean)
head(clean)

# Q04: Check that PM10 is greater than or equal to PM2.5 
# (PM2.5 must be a subset of PM10).
clean$flag_pm_conflict <- !is.na(clean$pm2.5) & !is.na(clean$pm10) & (clean$pm2.5 > clean$pm10)
sum(clean$flag_pm_conflict, na.rm = TRUE)
clean$pm10[clean$flag_pm_conflict] <- NA
clean$pm2.5[clean$flag_pm_conflict] <- NA


# Q05: Verify that Dew Point (DEWP) does not exceed Air Temperature (TEMP) (DEWP <= TEMP).
clean$flag_dewp_conflict <- !is.na(clean$dewp) & !is.na(clean$temp) & (clean$temp < clean$dewp)
sum(clean$flag_dewp_confilit, na.rm = TRUE)

# Q06: Ensure meteorological precipitation (RAIN) is valid and non-negative.
summary(clean$rain)
sum(clean$flag_rain_outlier)
sum(clean$rain, na.rm = TRUE)

# Q07: When RAIN > 0, check if DEWP and TEMP are closely aligned 
# (high moisture condition check).
clean$flag_temp_conflict <- (clean$temp - clean$dewp)
head(clean$flag_temp_conflict)
head(clean)

# Q08: Construct a clean `baseline` dataset by filtering out rows 
#with critical structural/date failures, and export it to an `.rds` file 

dim(clean)
clean[is.na(clean$datetime),]
baseline <- clean[!is.na(clean$datetime) & !is.na(clean$station), ]
baseline <- baseline[order(baseline$station, baseline$no), ]
str(baseline)
saveRDS(baseline, file = "clean_air_dyq.rds")

head(clean_air_dyq)


# colSums(is.na(b_airquality))
# colSums(is.na(clean_air_dyq))
# sum(duplicated(b_airquality))
# sum(duplicated(clean_air_dyq))
# ordered(clean_air_dyq$hour)
# ordered(b_airquality$hour)
# diff(b_airquality$hour, clean_air_dyq$hour)

# dim(b_airquality)
# dim(clean_air_dyq)
# test <- !duplicated(air)
# est2 <- air[test,]
# sum(test2$hour[test2$hour == 25], na.rm = TRUE)
# sum(is.na(clean$hour))
