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
aviation_data$Year <- year(aviation_data$EventDate)

# Aggregate fatalities per year
fatality_counts <- aviation_data %>%
  group_by(Year) %>%
  summarise(Fatalities = sum(FatalInjuryCount, na.rm = TRUE))

aviation_data <- aviation_data %>%
  filter(year(EventDate) >= 2015 & year(EventDate) <= 2024)

# Create time series
total_fatalities_ts <- ts(fatality_counts$Fatalities, start = 2015, end = 2024, frequency = 1)

# Visualize trends
autoplot(total_fatalities_ts) +
  ggtitle("Annual Fatalities in Civil Aviation (2015-2024)") +
  xlab("Year") + 
  ylab("Number of Fatalities") +
  theme_minimal()

# Time variable
time.aviation <- 1:(length(total_fatalities_ts))

# Linear model with trend and seasonality
fatalities.trend.seasonal <- lm(total_fatalities_ts ~ time.aviation + sin(2*pi*time.aviation) + cos(2*pi*time.aviation))
summary(fatalities.trend.seasonal)

# Residual analysis
e.ts.fatalities <- ts(fatalities.trend.seasonal$residuals)
autoplot(e.ts.fatalities, ylab = "Residuals from Fatalities Model")

# Autocorrelation analysis by year
fatal.acf <- ggAcf(e.ts.fatalities) + ggtitle("ACF of Model Residuals: Fatalities")
fatal.pacf <- ggPacf(e.ts.fatalities) + ggtitle("PACF of Model Residuals: Fatalities")
ggarrange(fatal.acf, fatal.pacf, nrow=2, ncol=1)

# Monthly analysis
aviation_data$Month <- month(aviation_data$EventDate)
monthly_fatalities <- aviation_data %>%
  group_by(Year, Month) %>%
  summarise(Fatalities = sum(FatalInjuryCount, na.rm = TRUE), .groups = 'drop') %>%
  mutate(Date = as.Date(paste(Year, Month, "01", sep = "-"))) %>%
  arrange(Date)

# Create monthly time series
fatalities_ts_monthly <- ts(monthly_fatalities$Fatalities, 
                            start = c(min(monthly_fatalities$Year), min(monthly_fatalities$Month)), 
                            frequency = 12)

# Visualization
autoplot(fatalities_ts_monthly) +
  ggtitle("Monthly Fatalities in Civil Aviation") +
  xlab("Year") + 
  ylab("Number of Fatalities") +
  theme_minimal()

# Linear model with seasonal components
time.aviation.monthly <- 1:length(fatalities_ts_monthly)
fatalities.trend.seasonal.monthly <- lm(fatalities_ts_monthly ~ time.aviation.monthly + 
                                          sin(2 * pi * time.aviation.monthly / 12) + 
                                          cos(2 * pi * time.aviation.monthly / 12))
summary(fatalities.trend.seasonal.monthly)

# Residual analysis for monthly model
e.ts.fatalities.monthly <- ts(fatalities.trend.seasonal.monthly$residuals, 
                              frequency = 12, 
                              start = c(min(monthly_fatalities$Year), min(monthly_fatalities$Month)))

autoplot(e.ts.fatalities.monthly) +
  ggtitle("Residuals from Monthly Fatalities Model") +
  ylab("Residuals")

# ACF and PACF

$

ggarrange(ggAcf(e.ts.fatalities.monthly)+ ggtitle("ACF of Model Residuals: Fatalities"), ggPacf(e.ts.fatalities.monthly)+ ggtitle("PACF of Model Residuals: Fatalities"), nrow = 2, ncol = 1)

Box.test(e.ts.fatalities.monthly, lag = 12, type = "Ljung-Box")

#pvalue greater than 0.05

adf.test(e.ts.fatalities.monthly)

#pvalue is smaller than 0.01 --> shows stationarity


########## FORECASTING
future_months <- (length(fatalities_ts_monthly) + 1):(length(fatalities_ts_monthly) + 12)
future_data <- data.frame(time.aviation.monthly = future_months,
                          sin_term = sin(2 * pi * future_months / 12),
                          cos_term = cos(2 * pi * future_months / 12))

future_forecast <- predict(fatalities.trend.seasonal.monthly, newdata = future_data, interval = "confidence")

forecast_df <- data.frame(Month = future_months,
                          Forecast = future_forecast[, "fit"],
                          Lower_CI = future_forecast[, "lwr"],
                          Upper_CI = future_forecast[, "upr"])

actual_df <- data.frame(Month = time.aviation.monthly, Fatalities = fatalities_ts_monthly)

# Plot actual and forecasted fatalities
ggplot() +
  geom_line(data = actual_df, aes(x = Month, y = Fatalities), color = "blue", size = 1) +
  geom_line(data = forecast_df, aes(x = Month, y = Forecast), color = "red", size = 1, linetype = "dashed") +
  geom_ribbon(data = forecast_df, aes(x = Month, ymin = Lower_CI, ymax = Upper_CI), alpha = 0.2, fill = "red") +
  ggtitle("Forecasted Monthly Fatalities in Civil Aviation") +
  xlab("Month (Time Index)") +
  ylab("Number of Fatalities") +
  theme_minimal()



# size p value is greater than 0.05, don't need ARIMA

# since we do not need ARIMA this shows that (according to this dataset), fatal  accidents
#are relatively stable over time suggesting that our time series is either already stationary 
#or effectively modeled