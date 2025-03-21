#===========================================================
# This document contains our data appendix script. It provides
# summary measures and visualizations for the main variables 
# used in our analysis. 
#===========================================================

library(ggplot2)

Data <- read.csv("/Users/Nata/Desktop/Cleaned Aviation Data Final.csv")

# Visualize Year Distribution
table(Data$Year)

ggplot(Data, aes(x=Year, fill=as.factor(Year))) + 
  geom_bar( ) +
  scale_fill_hue(c = 40) +
  theme(legend.position="none")

# Visualize Month distribution
table(Data$Month)

ggplot(Data, aes(x=Month, fill=as.factor(Month))) + 
  geom_bar( ) +
  scale_fill_hue(c = 40) +
  theme(legend.position="none")

# Visualize FatalInjuryCount
summary(Data$FatalInjuryCount)

hist(aviation_data$FatalInjuryCount, breaks=25, xlim=c(0,15), col=rgb(1,0,0,0.5), 
     xlab = "Fatal Injury Count",
     main="Distribution of Fatal Injury Count" )
