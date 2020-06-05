library(tidyverse)
library(data.table)
library(here)

prison_pop <- read_csv(here('data/interim/prison_pop.csv')) %>%
    select(-Flags) %>%
    mutate(Year = as.integer(str_extract(Year, "[0-9]+$")),
           Value = as.integer(Value)) %>%
    rename(Count = Value) %>%
    complete(Sex, Age, Ethnicity, Offence, Duration, Year, fill = list(Count = 0)) %>%
    mutate_if(is.character, function(x) factor(x, levels = unique(x)))

prison_pop_totals <- prison_pop %>%
    filter_if(is.factor, any_vars(str_detect(., "Total")))

prison_pop_margins <- prison_pop %>%
    filter_if(is.factor, any_vars(!str_detect(., "Total")))

add_totals <- function(margins, totals, var) {
    tot_var <- paste0(var, "_Total")
    totals %>%
        filter(str_detect(!!sym(var), "Total")) %>%
        select(-!!sym(var)) %>%
        rename(!!sym(tot_var) := Count) %>%
        right_join(margins) %>%
        filter(!str_detect(!!sym(var), "Total"))
}

prison_pop <- prison_pop_margins %>%
    add_totals(prison_pop_totals, "Sex") %>%
    add_totals(prison_pop_totals, "Age") %>%
    add_totals(prison_pop_totals, "Ethnicity") %>%
    add_totals(prison_pop_totals, "Offence") %>%
    add_totals(prison_pop_totals, "Duration") %>%
    rename(Prisoner_Count = Count) %>%
    select(Year, Sex, Age, Ethnicity, Offence, Duration,
           Sex_Total, Age_Total, Ethnicity_Total,
           Offence_Total, Duration_Total, Prisoner_Count) %>%
    mutate_if(is.factor, droplevels)

write_csv(prison_pop, here("data/processed/prison_pop.csv"))
