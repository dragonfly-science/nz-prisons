library(tidyverse)

prison_pop <- read_csv(here("data/processed/prison_pop.csv"))
pop_estimates <- read_csv(here("data/processed/pop_estimates.csv"))
demographics <- read_csv(here("data/processed/demographics.csv"))%>%
    filter(!(Year %in% unique(demographics$Year)))

population <- demographics %>%
    bind_rows(pop_estimates) %>%
    mutate_if(is.character, factor) %>%
    mutate_if(is.numeric, as.integer) %>%
    arrange(Year, Sex, Ethnicity, Age)

population %>%
    ggplot(aes(x = Year, y = Population_Count)) +
    geom_point() +
    geom_line() +
    facet_wrap(Sex + Ethnicity ~ Age, scales = "free_y")

pop_form <- bf(Population_Count ~ 1 + Sex + Ethnicity + Age + arma(time = Year, p = 2, q = 1))

pop_fit <- brm(
    pop_form,
    data = population
)

population %>%
    add_fitted_draws(pop_fit) %>%
    select(-.chain, -.iteration, -.row) %>%
    ggplot(aes(x = Year, group = .draw)) +
    geom_point(aes(y = Population_Count)) +
    geom_line(aes(y = .value), alpha = 0.01) +
    facet_wrap(Sex + Ethnicity ~ Age)
