# Duan Yuqing, TP114820
air <- read.csv("./instruction/2. Beijing_AirQuality.csv")
dim(air)

names(air)
str(air)
head(air)
colSums(is.na(air))
sum(duplicated(air))


pm <- air$PM2.5
sapply(names(air), function(x) air[!is.na(x) & x != ""])
nonblank <- pm[!is.na(pm) & pm != ""]



# based on lecture4

# based on lecture5A

# based on lecture5B

# delete duplicated rows


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



unique(tolower(air$station))
unique(tolower(air$wd))

max(air$SO2, na.rm = TRUE)
min(air$PM10, na.rm = TRUE)
