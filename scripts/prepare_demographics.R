library(tidyverse)
library(data.table)
library(here)

prison_pop <- read_csv("data/processed/prison_pop.csv")

age_bins <- c(
    `0 to 19` = "0-4 years",
    `0 to 19` = "5-9 years",
    `0 to 19` = "10-14 years",
    `0 to 19` = "15-19 years",
    `20 to 24` = "20-24 years",
    `25 to 29` = "25-29 years",
    `30 to 39` = "30-34 years",
    `30 to 39` = "35-39 years",
    `40 to 49` = "40-44 years",
    `40 to 49` = "45-49 years",
    `50 to 59` = "50-54 years",
    `50 to 59` = "55-59 years",
    `60 or older` = "60-64 years",
    `60 or older` = "65 years and over")

ethnicity_bins <- c(
    Pacific = "Pacific Peoples",
    Other = "Asian",
    Other = "Middle Eastern/Latin American/African",
    Other = "Other ethnicity"
)

demographics <- fread(here("data/interim/demographics.csv")) %>%
    as_tibble() %>%
    mutate(Value = if_else(Flags != "", 0, Value)) %>%
    select(-Flags, -Area) %>%
    mutate(Ethnicity = fct_recode(`Ethnic group`, !!!ethnicity_bins)) %>%
    mutate(Age = fct_recode(`Age group`, !!!age_bins)) %>%
    select(Age, Sex, Ethnicity, Year, Value) %>%
    filter(Age %in% unique(prison_pop$Age),
           Sex %in% unique(prison_pop$Sex),
           Ethnicity %in% unique(prison_pop$Ethnicity)) %>%
    rename(Population_Count = Value) %>%
    distinct()

write_csv(demographics, here("data/processed/demographics.csv"))
