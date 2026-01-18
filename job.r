# Load the tidyverse package for data manipulation (readr, dplyr, tidyr)
library(tidyverse)

# Define the file path
file_path <- "estat_jvs_q_nace2.tsv"

# --- 1. Read the data and separate the first column ---
# Read the TSV file.
data_cleaned <- read_tsv(file_path, skip = 0, col_names = TRUE) %>%
  # Rename the complex first column header 
  rename(Metadata_Geo = `freq,s_adj,nace_r2,sizeclas,indic_em,geo\\TIME_PERIOD`) %>%
  
  # Separate the single metadata column into distinct logical columns based on the comma separator
  separate(
    col = Metadata_Geo, 
    into = c("Frequency", "Seasonal_Adjustment", "NACE_Rev2_Activity", "Size_Class", "Indicator", "Geo_Code"), 
    sep = ",",
    remove = TRUE # Remove the original column
  )

# --- 2. Convert to long format and clean values ---

data_long <- data_cleaned %>%
  # Pivot to long format: convert wide time-period columns into rows
  pivot_longer(
    # Selects columns starting with '20' (the time periods)
    cols = starts_with("20"), 
    names_to = "Time_Period", 
    values_to = "Value_Raw"
  ) %>%
  
  # Clean up the raw values by removing Eurostat flags and indicators
  mutate(
    # Remove all flags (p, b, u, d, @C) and surrounding whitespace
    Value_Clean = str_replace_all(Value_Raw, "[pbudo@C]", ""),
    Value_Clean = str_squish(Value_Clean),
    
    # Replace missing value indicator (:) with NA, then convert to numeric
    Value_Numeric = na_if(Value_Clean, ":"),
    Value_Numeric = as.numeric(Value_Numeric)
  ) %>%
  
  # Remove rows where the original value was missing (:) as they provide no data
  filter(Value_Raw != ":")

# --- 3. Rename indicator and activity codes to representative labels ---

data_final <- data_long %>%
  mutate(
    # Rename Indicator codes (indic_em) to descriptive names
    Indicator = case_when(
      Indicator == "CH_Q_Q" ~ "Quarter_on_Quarter_Change_Percent",
      Indicator == "JOBOCC" ~ "Number_of_Occupancies",
      Indicator == "JOBRATE" ~ "Job_Vacancy_Rate_Percent",
      Indicator == "JOBVAC" ~ "Number_of_Job_Vacancies",
      .default = Indicator
    ),
    
    # Rename Size_Class codes
    Size_Class = case_when(
      Size_Class == "GE10" ~ "10_or_more_employees",
      Size_Class == "TOTAL" ~ "Total_Enterprises",
      .default = Size_Class
    ),
    
    # Rename NACE_Rev2_Activity codes (nace_r2) to descriptive names
    NACE_Rev2_Activity = case_when(
      NACE_Rev2_Activity == "A" ~ "Agriculture_Forestry_Fishing",
      NACE_Rev2_Activity == "B" ~ "Mining_and_Quarrying",
      NACE_Rev2_Activity == "C" ~ "Manufacturing",
      NACE_Rev2_Activity == "D" ~ "Electricity_Gas_Steam_Air_Conditioning_Supply",
      NACE_Rev2_Activity == "E" ~ "Water_Supply_Sewerage_Waste_Management",
      NACE_Rev2_Activity == "F" ~ "Construction",
      NACE_Rev2_Activity == "G" ~ "Wholesale_and_Retail_Trade",
      NACE_Rev2_Activity == "H" ~ "Transport_and_Storage",
      NACE_Rev2_Activity == "I" ~ "Accommodation_and_Food_Service_Activities",
      NACE_Rev2_Activity == "J" ~ "Information_and_Communication",
      NACE_Rev2_Activity == "K" ~ "Financial_and_Insurance_Activities",
      NACE_Rev2_Activity == "L" ~ "Real_Estate_Activities",
      NACE_Rev2_Activity == "M" ~ "Professional_Scientific_and_Technical_Activities",
      NACE_Rev2_Activity == "N" ~ "Administrative_and_Support_Service_Activities",
      NACE_Rev2_Activity == "O-S" ~ "Public_Administration_Defence_Education_Health_Arts_and_other_Services",
      NACE_Rev2_Activity == "R_S" ~ "Arts_Entertainment_Recreation_and_other_Services",
      NACE_Rev2_Activity == "B-E" ~ "Industry_excluding_Construction", 
      NACE_Rev2_Activity == "B-F" ~ "Industry_and_Construction",
      NACE_Rev2_Activity == "TOTAL" ~ "Total_Economic_Activities",
      NACE_Rev2_Activity == "A-S" ~ "Total_Economy_Industry_Construction_Services",
      .default = NACE_Rev2_Activity
    )
  ) %>%
  # Final column selection and ordering
  select(
    Frequency,
    Seasonal_Adjustment,
    NACE_Rev2_Activity,
    Size_Class,
    Indicator,
    Geo_Code,
    Time_Period,
    Value = Value_Numeric # Use the cleaned, numeric value for the final column
  )

# The resulting cleaned and transformed tibble is stored in 'data_final'
# Display the first few rows and the structure
print(head(data_final))
print(glimpse(data_final))

# Optional: To save the cleaned file to a new CSV:
write_csv(data_final, "estat_jvs_q_nace2_cleaned.csv")
