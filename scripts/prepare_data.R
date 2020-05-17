library(tidyverse)
library(here)

prison_pop <- read_csv(here('data/annual-sentenced-prisoner-population.csv')) %>%
    select(-Flags) %>%
    mutate(Year = as.integer(str_extract(Year, "[0-9]+$")),
           Value = as.integer(Value)) %>%
    rename(Count = Value) %>%
    complete(Sex, Age, Ethnicity, Offence, Duration, Year, fill = list(Count = 0)) %>%
    filter(Year == 2018) %>%
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

prison_pop_tidy <- prison_pop_margins %>%
    add_totals(prison_pop_totals, "Sex") %>%
    add_totals(prison_pop_totals, "Age") %>%
    add_totals(prison_pop_totals, "Ethnicity") %>%
    add_totals(prison_pop_totals, "Offence") %>%
    add_totals(prison_pop_totals, "Duration") %>%
    select(Year, Sex, Age, Ethnicity, Offence, Duration,
           Sex_Total, Age_Total, Ethnicity_Total,
           Offence_Total, Duration_Total, Count) %>%
    mutate_if(is.factor, droplevels)

write_csv(prison_pop_tidy, here("data/prison_pop_tidy.csv"))
