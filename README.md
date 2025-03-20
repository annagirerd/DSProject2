# DS4002 Project 2

The goal of our project is to predict the amount of civil aviation accidents in 2026 as well as investigate variables potentially correlated with civil aviation accidents. Our dataset includes civil aviation accident data from 2015-2025 from the National Transportation Security Board. After cleaning our dataset, we built our ARIMA model to forecast future civil aviation accidents and ran a regression analysis to determine if any variables were correlated with civil aviation accidents. Finally, we evaluated our ARIMA model based on its RMSE value (target value between 0.2-0.5). We evaluated the regression based on its p-value and MAE value. 

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
![Project 2 Hierarchy](https://github.com/user-attachments/assets/62292b04-cd69-464e-a757-cda97c35f3e4)


## Reproducing Results
1. Install R/R Studio and the above packages on your computer.
2. Download Aviation Data 2015-2025.csv from the DATA folder.
3. Download Data_Cleaning_EDA.R from the SCRIPTS folder. Run this file, changing the dataset import line of code if necessary. This file will clean the data and convert it to a time series, as well as display important visualizations of key variables. This file also outputs the cleaned dataset, Cleaned Aviation Data Final.csv. 
4. Download the AviationAnalysisScript.R from the SCRIPTS folder. This file runs our analysis on the cleaned dataset, predicting aviation accidents for 2026. See the DataAppendix.pdf in the DATA folder for more information on variables used in our analysis. 
