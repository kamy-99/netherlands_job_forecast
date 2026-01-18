# Load the tidyverse package for data manipulation (readr, dplyr, tidyr)
library(tidyverse)

# Define the file path
file_path <- "estat_jvs_q_nace2.tsv"

raw <- read.csv("estat_jvs_q_nace2_cleaned.csv")

netherlands_raw <- raw %>%
  filter(Geo_Code == "NL")

netherlands_job_rate <- netherlands_raw %>%
  filter(Indicator == "Quarter_on_Quarter_Change_Percent")

write.csv(netherlands_job_rate, "netherlands_vacancy_rate.csv")
