library(tidyverse)
library(data.table)
library(here)

source(here("scripts/utils.R"), local = TRUE)

prison_pop <- read_csv(here("data/processed/prison_pop.csv"))
idi_eth_l1 <- read_csv(here("data/interim/exp-pop-estimates-eth-l1-2006-16.csv"))

talb_concordance <- idi_eth_l1 %>%
    select(talb17, talb17desc) %>%
    distinct() %>%
    mutate_if(is.character, factor)

idi_erp <- idi_eth_l1 %>%
    select(-talb17) %>%
    mutate_if(is.character, factor) %>%
    complete(year, talb17desc, sex, agegrp, eth) %>%
    mutate(count = if_else(is.na(count), 0, count)) %>%
    left_join(talb_concordance) %>%
    select(year, talb17, talb17desc, sex, eth, agegrp, count) %>%
    arrange(year, talb17, sex, eth, agegrp, count) %>%
    rename(Year = year,
           TA_Code = talb17,
           TA_Name = talb17desc,
           Sex = sex,
           Ethnicity = eth,
           Age = agegrp,
           Count = count)

age_bins <- c(
    `0 to 19` = "00-04 years",
    `0 to 19` = "05-09 years",
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
    `60 or older` = "65-69 years",
    `60 or older` = "70-74 years",
    `60 or older` = "75-79 years",
    `60 or older` = "80-84 years",
    `60 or older` = "85+ years")

ethnicity_bins <- c(
    Other = "Asian",
    Other = "MELAA",
    Other = "Other Ethnicity",
    Other = "Unknown"
)

idi_erp <- idi_erp %>%
    mutate(Ethnicity = fct_recode(Ethnicity, !!!ethnicity_bins),
           Age = fct_recode(Age, !!!age_bins)) %>%
    arrange(Year, TA_Code, Sex, Ethnicity, Age) %>%
    filter(Age %in% unique(prison_pop$Age),
           Sex %in% unique(prison_pop$Sex),
           Ethnicity %in% unique(prison_pop$Ethnicity)) %>%
    mutate(Ethnicity = factor(Ethnicity, levels = fix_factor_levels(Ethnicity)),
           Age = factor(Age, levels = fix_factor_levels(Age))) %>%
    arrange(Year, Sex, Ethnicity, Age)

write_csv(idi_erp, here("data/processed/idi_erp.csv"))
