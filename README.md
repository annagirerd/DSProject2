# DS4002 Project 2 - Predicting Aviation Accidents

## Software/Platform 

In our project, we used R/R Studio to run our code on a Mac computer. The following packages must be installed and loaded: 
- mtsdi
- forecast
- ggplot2
- lubridate
- tidyverse
- ggfortify
- ggpubr
- tseries
- dplyr
- stringr

## Map of Documentation 
![Project 2 Hierarchy (2)](https://github.com/user-attachments/assets/683c6a4a-5c6e-4a04-a123-9b64fbf277a4)


## Reproducing Results
1. Install R/R Studio and the above packages on your computer.
2. Download Aviation Data 2015-2025.csv from the DATA folder.
3. Download DataCleaningEDA.R from the SCRIPTS folder. Run this file, changing the dataset import line of code if necessary. This file will clean the data and convert it to a time series, as well as display important visualizations of key variables. This file also outputs the cleaned dataset, Cleaned Aviation Data Final.csv. 
4. Download the AviationAccidentsInPastDecade.R and FatalInjuriesOfAviationAccidentsInPastDecade.R from the SCRIPTS folder. These files runs our analysis on the cleaned dataset. In the first script, we ran statistical tests on aviation accidents from the past decade to see if it required ARIMA for forecasting. Since it did not require ARIMA, we ran a secondary test on another variable - Fatal Injury Count - to see if it would be better suited for ARIMA. This variable also did not require an ARIMA, so we continued to forecast aviation accidents for the next year with a simpler model. See the DataAppendix.pdf in the DATA folder for more information on variables used in our analysis. 
