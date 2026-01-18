# Netherlands Job Vacancy Forecasting (SARIMA)

Project Overview
This project provides a complete end-to-end pipeline to clean, process, and forecast job vacancy rates in the Netherlands, specifically focusing on the Professional, Scientific, and Technical Activities sector. Using Eurostat data, the project implements a SARIMA (Seasonal Autoregressive Integrated Moving Average) model to predict demand trends over a 2-year horizon.

# Repository Structure
The project is divided into three functional R scripts:

1. job.r (Data Engineering & ETL):
    Imports raw Eurostat .tsv data.

    Separates complex metadata strings into logical columns (Frequency, Adjustment, Activity, Size Class, Indicator, and Geo Code).

    Cleans numeric values by removing Eurostat flags (e.g., "p", "b", "u").

    Maps cryptic NACE codes to human-readable industry labels.
2. netherlandsv2.R (Data Filtering):
    Extracts records specifically for the Netherlands (Geo_Code == "NL").

    Filters for the "Quarter-on-Quarter Change Percent" indicator to analyze growth rates.

3. forecast_jobs.r (Time Series Analysis):

    Constructs a quarterly Time Series object (ts).

    Uses auto.arima() to select the mathematically optimal seasonal model based on AICc.

    Generates an 8-period (2-year) forecast with 80% and 95% confidence intervals.

# Technical Methodology

Data Cleaning
The raw data contains Eurostat-specific notation (e.g., : for missing values or @C for confidential data). The ETL script uses regular expressions to strip these flags and convert the values into a numeric format suitable for mathematical modeling.

# Forecasting Model
The project utilizes a SARIMA model, which is defined by the parameters $(p, d, q) \times (P, D, Q)_s$:

Non-seasonal components: $(p, d, q)$ handle the immediate trend and lag effects.

Seasonal components: $(P, D, Q)$ handle recurring patterns every 4 quarters.

Validation: The model's accuracy is verified using a Ljung-Box test via checkresiduals() to ensure that the error terms are random and contain no remaining patterns.

# Requirements
To run this project, you need R and the following libraries:

tidyverse (for data manipulation and visualization)

forecast (for SARIMA modeling and automated selection)

# How to Reproduce
Source Data: Place your estat_jvs_q_nace2.tsv file in the root directory.

Clean: Run job.r to generate estat_jvs_q_nace2_cleaned.csv.

Filter: Run netherlandsv2.R to isolate Netherlands-specific data.

Forecast: Run forecast_jobs.r to generate the final plots and the forecast_data_table.

# Key Results
The model outputs a 2-year forecast of the percentage change in job vacancies. A dashed red line at $y=0$ in the output plot signifies the threshold between vacancy growth and decline.