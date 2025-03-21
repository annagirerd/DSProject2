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
![Project 2 Hierarchy (1)](https://github.com/user-attachments/assets/b11da1ec-5e84-4137-b707-16f922da51a2)


## Reproducing Results
1. Install R/R Studio and the above packages on your computer.
2. Download Aviation Data 2015-2025.csv from the DATA folder.
3. Download DataCleaningEDA.R from the SCRIPTS folder. Run this file, changing the dataset import line of code if necessary. This file will clean the data and convert it to a time series, as well as display important visualizations of key variables. This file also outputs the cleaned dataset, Cleaned Aviation Data Final.csv. 
4. Download the AviationAnalysisScript.R from the SCRIPTS folder. This file runs our analysis on the cleaned dataset, predicting aviation accidents for 2026. See the DataAppendix.pdf in the DATA folder for more information on variables used in our analysis. 
