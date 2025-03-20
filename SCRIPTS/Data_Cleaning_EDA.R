#===========================================================
# This document contains our data cleaning and EDA where 
# we explored key variables and made relevant visualizations.
#===========================================================
Data <- read.csv("~/Downloads/Aviation Data 2015-2025.csv", header = TRUE, sep = ",")


library(mtsdi)
library(forecast)
library(ggplot2)
library(lubridate)
library(tidyverse)
library(ggfortify)
library(ggpubr)
library(tseries) ]
library(dplyr)
library(stringr)

################################################################
# Data Cleaning

# Delete unnecessary columns
Data$NtsbNo <- NULL 
Data$N <- NULL
Data$ReportNo <- NULL 
Data$OriginalPublishDate <- NULL 
Data$EventID <- NULL 
Data$AirportName <- NULL 
Data$Scheduled <- NULL 
Data$DocketUrl <- NULL 
Data$DocketPublishDate <- NULL 
Data$RepGenFlag <- NULL 
Data$Mkey <- NULL


head(Data)
summary(Data)


# NA for missing values
Data[Data == ""] <- NA
Data[Data == " "] <- NA
Data[Data == ","] <- NA

# Replace number of engines with ONE number only
df <- data.frame(
  Aircraft = c("A", "B", "C", "D"),
  NumberofEngines = c("1", "1,2", "2,3", "4")
)

# Modify the NumberofEngines column
df <- df %>%
  mutate(NumberofEngines = str_extract(NumberofEngines, "^[^,]+"))

# Print the updated dataframe
print(df)

# Splitting Date into different columns 
# Data$EventDate <- ymd_hms(data$EventDate)

Data <- Data %>%
  mutate(Year = year(EventDate),
         Month = month(EventDate),
         Day = day(EventDate),
         Hour = hour(EventDate))

# Change months to words
Data$Month <- factor(Data$Month, 
                     levels = 1:12, 
                     labels = c("January", "February", "March", "April", "May", "June",
                                "July", "August", "September", "October", "November", "December"))
table(Data$Month)  

head(Data)


# Categorize into different key words for cause of crash
Data <- Data %>%
  mutate(CauseCategory = case_when(
    str_detect(tolower(ProbableCause), "pilot|human error|failed to|inadequate control|decision-making|misjudged") ~ "Pilot Error",
    str_detect(tolower(ProbableCause), "engine|mechanical|failure|malfunction|hydraulic|fuel system|landing gear") ~ "Mechanical Failure",
    str_detect(tolower(ProbableCause), "thunderstorm|icing|turbulence|low visibility|strong winds|rain|fog") ~ "Weather Conditions",
    str_detect(tolower(ProbableCause), "ATC|air traffic control|miscommunication|clearance issue") ~ "Air Traffic Control",
    str_detect(tolower(ProbableCause), "bird|wildlife") ~ "Bird Strike",
    str_detect(tolower(ProbableCause), "runway|takeoff|hard landing|overran|skidded|collision on ground") ~ "Runway/Takeoff Issues",
    str_detect(tolower(ProbableCause), "collision|mid-air|aircraft separation") ~ "Mid-Air Collision",
    str_detect(tolower(ProbableCause), "unknown|undetermined|unconfirmed|classified") ~ "Unknown/Other",
    TRUE ~ "Other"  # Default category if none of the above match
  ))

# View categorized data
head(Data[, c("ProbableCause", "CauseCategory")])


Data$ProbableCause <- NULL


#*****serious versus minor injuries
SeriousInj <- sum(Data$SeriousInjuryCount)

number_of_days <- length(Data$SeriousInjuryCount)

# Calculate the average number of spam emails per day
average_inj_per_day <- SeriousInj / number_of_days

print(paste("Average Serious Injuries per day:", average_inj_per_day))

MinorInj <- sum(Data$MinorInjuryCount)

number_of_days <- length(Data$MinorInjuryCount)

# Calculate the average number of spam emails per day
average_m_inj_per_day <- MinorInj/number_of_days

print(paste("Average Serious Injuries per day:", average_m_inj_per_day))



################################################################
# Visualizations

### Yearly Aviation Accidents
Data %>%
  count(Year) %>%
  ggplot(aes(x = Year, y = n)) +
  geom_line(color = "blue", size = 1) +
  geom_point(color = "red") +
  labs(title = "Yearly Trend of Aviation Accidents (2015-2025)",
       x = "Year", y = "Number of Accidents") +
  theme_minimal()

#################################
### Number of accidents per month

Data %>%
  count(Month) %>%
  ggplot(aes(x = Month, y = n, fill = factor(Month))) +
  geom_bar(stat = "identity") +
  labs(title = "Aviation Accidents per Month", x = "Month", y = "Number of Accidents") +
  theme_minimal()

#################################
### Map heatmap of aviation incidents (helps visualize by state)

# Count the number of crashes by state using dplyr
state_crash_counts <- Data %>%
  count(State) %>%
  rename(crash_count = n)  # Rename the count column to "crash_count"

# Download the U.S. states shapefile (using 'maps' package as an example)
us_states <- map_data("state")

# Standardize the case of state names (if necessary)
state_crash_counts$State <- tolower(state_crash_counts$State)
us_states$region <- tolower(us_states$region)  # `region` in `map_data` corresponds to state names

# Merge the crash data with the shapefile
merged_data <- us_states %>%
  left_join(state_crash_counts, by = c("region" = "State"))

# Plot the map with ggplot2
ggplot(merged_data) +
  geom_polygon(aes(x = long, y = lat, group = group, fill = crash_count), color = "white") +
  coord_fixed(1.1) +
  scale_fill_viridis_c(option = "plasma", name = "Crash Count") +
  theme_minimal() +
  labs(title = "Airplane Crashes by State") +
  theme(legend.position = "right")

#################################
### Plotting each aviation incident in a map scatter plot

# Make sure that latitude and longitude are numeric
crash_data <- Data %>%
  mutate(latitude = as.numeric(Latitude), 
         longitude = as.numeric(Longitude))

ggplot() +
  # Plot the U.S. map with state boundaries
  geom_polygon(data=us_states, aes(x = long, y = lat, group = group), 
               fill = "white", color = "black", size = 0.2) +
  
  # Add the crash points
  geom_point(data=crash_data, aes(x = longitude, y = latitude), 
             color = "red", alpha = 0.5, size = 1.5) +
  
  coord_cartesian(xlim = c(-125, -66), ylim = c(24, 50)) +
  labs(title = "Airplane Crashes in the United States") +
  theme_minimal() +
  theme(legend.position = "none")

#################################
### Injury severity over time 

# Load necessary libraries
crash_data_clean <- crash_data %>%
  filter(!is.na(FatalInjuryCount) & 
           !is.na(SeriousInjuryCount) & 
           !is.na(MinorInjuryCount) &
           !is.na(Year))  # Filter out NA in the 'Year' column

# Group by Year and summarize injury counts
injuries_over_time <- crash_data_clean %>%
  group_by(Year) %>%
  summarise(
    fatal_injuries = sum(FatalInjuryCount, na.rm = TRUE),
    serious_injuries = sum(SeriousInjuryCount, na.rm = TRUE),
    minor_injuries = sum(MinorInjuryCount, na.rm = TRUE)
  )

head(injuries_over_time)

# Reshape the data into a long format for easier plotting
injuries_long <- injuries_over_time %>%
  pivot_longer(cols = c(fatal_injuries, serious_injuries, minor_injuries),
               names_to = "injury_type",
               values_to = "injury_count")

# Convert 'Year' to a factor so it appears as discrete categories on the x-axis
injuries_long$Year <- as.factor(injuries_long$Year)

head(injuries_long)

# Create a line plot for fatal, serious, and minor injuries over time
ggplot(injuries_long, aes(x = Year, y = injury_count, color = injury_type, group = injury_type)) +
  geom_line(size = 1.2) +
  geom_point(size = 3) +
  labs(
    title = "Trends in Airplane Injuries Over Time",
    x = "Year",
    y = "Number of Injuries",
    color = "Injury Type"
  ) +
  theme_minimal() +
  theme(legend.position = "top")

#################################
### Comparison of Airbus vs. Boeing 

Data$Make <- tolower(Data$Make)

# Assuming your dataset is called 'crash_data'
# Filter the dataset for Airbus and Boeing only
crash_data_filtered <- Data %>%
  
  # airbus isn't even in the top 10 most common makes in the dataset 
  # perhaps newer manufacturers are in the top 10? 
  filter(Make %in% c("airbus", "boeing")) %>%
  filter(!is.na(Year))  # Make sure Year is not NA

# Group by Year and Make to summarize the number of crashes
crash_counts <- crash_data_filtered %>%
  group_by(Year, Make) %>%
  summarise(crash_count = n(), .groups = 'drop')

# Convert 'Year' to a factor so it appears as discrete categories on the x-axis
crash_counts$Year <- as.factor(crash_counts$Year)

# Create a line plot comparing crashes for Airbus and Boeing over time
ggplot(crash_counts, aes(x = Year, y = crash_count, color = Make, group = Make)) +
  geom_line(size = 1.2) +
  geom_point(size = 3) +
  labs(
    title = "Comparison of Airplane Crashes for Airbus and Boeing Over Time",
    x = "Year",
    y = "Number of Crashes",
    color = "Aircraft Make"
  ) +
  theme_minimal() +
  theme(legend.position = "top")


#################################
# Cause of accident

Data %>%
  count(CauseCategory) %>%
  ggplot(aes(x = reorder(CauseCategory, n), y = n, fill = CauseCategory)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  labs(title = "Distribution of Probable Causes of Aviation Accidents",
       x = "Cause Category", y = "Count") +
  theme_minimal()





# Convert to time series formal
accident_ts <- ts(Data %>% count(Year) %>% pull(n), start = 2015, frequency = 1)
autoplot(accident_ts) +
  labs(title = "Time Series of Civil Aviation Accidents",
       x = "Year", y = "Number of Accidents")


# stationarity test
adf.test(accident_ts)  # Augmented Dickey-Fuller test
  #says that it is stationary


# autocorrelation and partial autocorrelation
acf(accident_ts)
pacf(accident_ts)

write.csv(Data, "~/Desktop/Cleaned Aviation Data.csv", row.names = FALSE)


