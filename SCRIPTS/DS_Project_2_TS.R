library(mtsdi)
library(forecast)
library(ggplot2)
library(lubridate)
library(tidyverse)
library(ggfortify)
library(ggpubr)
library(tseries)

# Read the CSV file
aviation_data <- read.csv("~/Desktop/Cleaned Aviation Data Final.csv")

#create time series
aviation_data$EventDate <- as.Date(aviation_data$EventDate)  
head(aviation_data$EventDate)

#extract year
aviation_data$Year <- year(aviation_data$EventDate)
accident_counts <- aviation_data %>%
  group_by(Year) %>%
  summarise(Accidents = n())

aviation_data <- aviation_data %>%
  filter(year(EventDate) >= 2015 & year(EventDate) <= 2024)


#make time series
accident_ts <- ts(accident_counts$Accidents, start = 2015, end = 2024, frequency = 1)

#visualize the trends over time
autoplot(accident_ts) +
  ggtitle("Annual Civil Aviation Accidents (2015-2024)") +
  xlab("Year") + 
  ylab("Number of Accidents") +
  theme_minimal()

time.aviation <- c(1:(length(accident_ts)))
#linear model
accidents.trend.seasonal<-lm(accident_ts[time.aviation]~time.aviation + sin(2*pi*time.aviation) + cos(2*pi*time.aviation))

summary(accidents.trend.seasonal)



# time series residuals
e.ts.accidents<-ts(accidents.trend.seasonal$residuals)
autoplot(e.ts.accidents, ylab = "Residuals from Accidents")



#autocorrelation and partial autocorrelation plots by year



acc.acf <- ggAcf(e.ts.accidents) + ggtitle("ACF of Model Residuals: Aviation Accidents")
acc.pacf <- ggPacf(e.ts.accidents) + ggtitle("PACF of Model Residuals: Aviation Accidents")
ggarrange(acc.acf,acc.pacf,nrow=2,ncol=1)

#***no significant spikes (white noise)





# monthly 

# Extract year and month
aviation_data$Year <- year(aviation_data$EventDate)
aviation_data$Month <- month(aviation_data$EventDate)

# Aggregate counts by Year and Month
monthly_accidents <- aviation_data %>%
  group_by(Year, Month) %>%
  summarise(Accidents = n(), .groups = 'drop')

# Create a date column for monthly data (using the first day of the month)
monthly_accidents <- monthly_accidents %>%
  mutate(Date = as.Date(paste(Year, Month, "01", sep = "-")))

# Order the data by Date
monthly_accidents <- monthly_accidents %>%
  arrange(Date)

# Create a time series object with monthly frequency
accident_ts_monthly <- ts(monthly_accidents$Accidents, 
                          start = c(min(monthly_accidents$Year), min(monthly_accidents$Month)), 
                          frequency = 12)

# Visualize the monthly time series
autoplot(accident_ts_monthly) +
  ggtitle("Monthly Civil Aviation Accidents") +
  xlab("Year") + 
  ylab("Number of Accidents") +
  theme_minimal()


#autocorrelation and partial autocorrelation for monthly

time.aviation.monthly <- 1:length(accident_ts_monthly)

# Fit a linear model with seasonal components (12-month cycle)
accidents.trend.seasonal.monthly <- lm(accident_ts_monthly ~ time.aviation.monthly + 
                                         sin(2 * pi * time.aviation.monthly / 12) + 
                                         cos(2 * pi * time.aviation.monthly / 12))
# Summary of the model
summary(accidents.trend.seasonal.monthly)


# Convert residuals to a time series
e.ts.accidents.monthly <- ts(accidents.trend.seasonal.monthly$residuals, 
                             frequency = 12, 
                             start = c(min(monthly_accidents$Year), min(monthly_accidents$Month)))

# Plot residuals to check for patterns
autoplot(e.ts.accidents.monthly) +
  ggtitle("Residuals from Monthly Accident Model") +
  ylab("Residuals")


acc.acf.monthly <- ggAcf(e.ts.accidents.monthly)

# Partial autocorrelation function plot
acc.pacf.monthly <- ggPacf(e.ts.accidents.monthly)

# Arrange ACF and PACF plots together
ggarrange(acc.acf.monthly, acc.pacf.monthly, nrow = 2, ncol = 1)


Box.test(e.ts.accidents.monthly, lag = 12, type = "Ljung-Box")
# size p value is greater than 0.05, don't need ARIMA

# since we do not need ARIMA this shows that (according to this dataset), aviation accidents
#are relatively stable over time suggesting that our time series is either already stationary 
#or effectively modeled


##########FORECASTING
future_months <- (length(accident_ts_monthly) + 1):(length(accident_ts_monthly) + 12)

# Create a dataframe for prediction
future_data <- data.frame(time.aviation.monthly = future_months,
                          sin_term = sin(2 * pi * future_months / 12),
                          cos_term = cos(2 * pi * future_months / 12))

# Predict future values
future_forecast <- predict(accidents.trend.seasonal.monthly, newdata = future_data, interval = "confidence")

# Convert to dataframe for plotting
forecast_df <- data.frame(Month = future_months,
                          Forecast = future_forecast[, "fit"],
                          Lower_CI = future_forecast[, "lwr"],
                          Upper_CI = future_forecast[, "upr"])
actual_df <- data.frame(Month = time.aviation.monthly, Accidents = accident_ts_monthly)

# Plot actual data and forecast
ggplot() +
  geom_line(data = actual_df, aes(x = Month, y = Accidents), color = "blue", size = 1) +  # Actual data
  geom_line(data = forecast_df, aes(x = Month, y = Forecast), color = "red", size = 1, linetype = "dashed") +  # Forecast
  geom_ribbon(data = forecast_df, aes(x = Month, ymin = Lower_CI, ymax = Upper_CI), alpha = 0.2, fill = "red") +  # Confidence Interval
  ggtitle("Forecasted Monthly Civil Aviation Accidents") +
  xlab("Month (Time Index)") +
  ylab("Number of Accidents") +
  theme_minimal()





### We were considering doing 20 years of data to do our forecasting model off of b
###but it didn't make sense since the further away the data is from the less
###accurate of a job it does forecasting future data.


