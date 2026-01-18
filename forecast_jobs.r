# ----------------------------------------------------
# 1. Setup: Load Libraries
# ----------------------------------------------------

# Load necessary libraries
library(tidyverse)
library(forecast)

# Define the file path
file_path <- "netherlands_vacancy_rate.csv"

# ----------------------------------------------------
# 2. Data Preparation and Time Series Creation
# ----------------------------------------------------

# Read the data
df_raw <- read_csv(file_path)

# Filter for the specific, comprehensive time series: 
# Total Economy for all enterprise sizes (which is 'Total_Enterprises' in Size_Class)
df_ts <- df_raw %>%
  filter(
    NACE_Rev2_Activity == "Professional_Scientific_and_Technical_Activities", # <-- CORRECTED NACE CODE
    Size_Class == "Total_Enterprises",
    # It is best practice to use seasonally adjusted data (SA) for SARIMA modeling
    Seasonal_Adjustment == "NSA" 
  ) %>%
  # Arrange by Time_Period to ensure correct order
  arrange(Time_Period)

# Check if the filtered dataframe has observations
if (nrow(df_ts) == 0) {
  stop("Error: No data found after filtering. Check your NACE_Rev2_Activity and Size_Class names.")
}

# Extract start year and quarter from the first entry (e.g., "2001-Q2")
start_period <- df_ts$Time_Period[1]
# Get the first four characters for the year
start_year <- as.numeric(substr(start_period, 1, 4)) 
# Get the single digit for the quarter
start_quarter <- as.numeric(substr(start_period, 7, 7)) 

# Convert the 'Value' column (Quarter-on-Quarter Change Percent) into a Time Series object (ts)
# Frequency = 4 is used for quarterly data.
ts_data <- ts(
  df_ts$Value, 
  start = c(start_year, start_quarter), 
  frequency = 4
)

# ----------------------------------------------------
# 3. Model Fitting and Selection (SARIMA)
# ----------------------------------------------------

# Use auto.arima() to automatically select the optimal SARIMA(p,d,q)(P,D,Q)[4] model.
# The model will search for the best non-seasonal (p, d, q) and seasonal (P, D, Q) terms
# based on minimizing the AICc.
fit_sarima <- auto.arima(
  ts_data, 
  seasonal = TRUE,
  stepwise = FALSE,       
  approximation = FALSE    
)

# Print the model summary to see the chosen parameters (the SARIMA order)
print("--- SARIMA Model Summary ---")
print(summary(fit_sarima))

# ----------------------------------------------------
# 4. Forecasting and Visualization
# ----------------------------------------------------

# Generate a forecast for the next 8 periods (2 years)
forecast_sarima <- forecast(fit_sarima, h = 8)

# Print the forecast table
print("--- 2-Year Forecast ---")
print(forecast_sarima)

# Plot the time series, the fitted model, and the forecast 

autoplot(forecast_sarima) +
  labs(
    title = "Forecast of Professional,Scientific and Technical Activities (NL, Total Economy, SA)",
    y = "Quarter-on-Quarter Change (%)",
    x = "Year"
  ) +
  # Add a line for zero change, which indicates a flat vacancy rate
  geom_hline(yintercept = 0, linetype = "dashed", color = "red")

# Optional: Check residuals for model validation (Ljung-Box test for white noise)
checkresiduals(fit_sarima)


# Convert the forecast object into a data frame for easy viewing and export
forecast_data_table <- data.frame(
  Time_Period = time(forecast_sarima$mean),
  Point_Forecast = forecast_sarima$mean,
  Lower_95 = forecast_sarima$lower[, 2], # The second column of lower is 95%
  Upper_95 = forecast_sarima$upper[, 2]  # The second column of upper is 95%
)

# Print the final data frame
print("--- Forecast Data Frame ---")
print(forecast_data_table)

# Optional: Save the forecast to a CSV file
# write.csv(forecast_data_table, "sarima_forecast_data.csv", row.names = FALSE)