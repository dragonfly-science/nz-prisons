library(tidyverse)
library(data.table)
library(here)

prison_pop <- read_csv("data/processed/prison_pop.csv")

age_bins <- c(
    `0 to 19` = "0-4 Years",
    `0 to 19` = "5-9 Years",
    `0 to 19` = "10-14 Years",
    `0 to 19` = "15-19 Years",
    `20 to 24` = "20-24 Years",
    `25 to 29` = "25-29 Years",
    `30 to 39` = "30-34 Years",
    `30 to 39` = "35-39 Years",
    `40 to 49` = "40-44 Years",
    `40 to 49` = "45-49 Years",
    `50 to 59` = "50-54 Years",
    `50 to 59` = "55-59 Years",
    `60 or older` = "60-64 Years",
    `60 or older` = "65 Years and over")

ethnicity_bins <- c(
    European = "European or Other ethnicity (including New Zealander)",
    Pacific = "Pacific peoples",
    Other = "Asian",
    Other = "Middle Eastern/Latin American/African"
)

pop_estimates <- fread(here("data/raw/pop_estimates.csv")) %>%
    as_tibble() %>%
    rename(`Age group` = Age) %>%
    mutate_if(is.character, as.factor) %>%
    rename(Year = `Year at 30 June`) %>%
    select(-Flags) %>%
    mutate(Ethnicity = fct_recode(`Ethnic group`, !!!ethnicity_bins)) %>%
    mutate(Age = fct_recode(`Age group`, !!!age_bins)) %>%
    rename(Estimated_Count = Value) %>%
    filter(Age %in% unique(prison_pop$Age),
           Sex %in% unique(prison_pop$Sex),
           Ethnicity %in% unique(prison_pop$Ethnicity)) %>%
    select(Age, Sex, Ethnicity, Year, Estimated_Count) %>%
    distinct()

write_csv(pop_estimates, here("data/processed/pop_estimates.csv"))
