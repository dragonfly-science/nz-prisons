inv_logit <- function (x) exp(x)/(1+exp(x))

random_round <- function(y, base) {
    ndraws = length(y)
    seeds = runif(ndraws)
    threshold = (y %% base) / base
    y_down = y - y %% base
    ifelse(seeds < threshold, y_down, y_down + base)
}

bernoulli_lpmf <- function(y, zi) {
    y * log(zi) + (1 - y) * log(1 - zi)
}

random_rounding_lpmf <- function(y, base) {
    lambda = (y %% base) / base
    if (y %% base == 0) {
        y
    } else {
        (y - (y %% base) + base) * bernoulli_lpmf(1, lambda) +
            y - (y %% base) * bernoulli_lpmf(0, lambda)
    }
}

zero_inflated_poisson_lpmf <- function(y, eta, zi) {
    if (y == 0) {
        log_sum_exp(c(
            bernoulli_lpmf(1, zi),
            bernoulli_lpmf(0, zi) +
            dpois(0, exp(eta))
        ))
    } else {
        bernoulli_lpmf(0, zi) +
        dpois(y, exp(eta))
    }
}

zero_inflated_poisson_rr3_lpmf <- function (y, eta, zi) {
    zero_inflated_poisson_lpmf(y, eta, zi) +
        random_rounding_lpmf(y, 3)
}

log_lik_zero_inflated_poisson_rr3 <- function(i, prep = prep) {
    zi <- prep$dpars$zi[i]
    mu <- prep$dpars$mu[i]
    y <- prep$data$Y[i]
    zero_inflated_poisson_rr3_lpmf(y, mu, zi)
}

posterior_predict_zero_inflated_poisson <- function(i, prep, ...) {
    # theta is the bernoulli zero-inflation parameter
    theta <- get_dpar(prep, "zi", i = i)
    lambda <- get_dpar(prep, "mu", i = i)
    ndraws <- prep$nsamples
    # compare with theta to incorporate the zero-inflation process
    zi <- runif(ndraws, 0, 1)
    ifelse(zi < theta, 0, rpois(ndraws, lambda = exp(lambda)))
}

posterior_predict_zero_inflated_poisson_rr3 <- function(i, prep, ...) {
    theta <- prep$dpars$zi
    lambda <- prep$dpars$mu[i]
    ndraws <- prep$nsamples
    zi <- runif(ndraws, 0, 1)
    ifelse(zi < theta, 0, rpois(ndraws, lambda = exp(lambda)))
}

zero_inflated_poisson_rr3 <- custom_family(
    "zero_inflated_poisson_rr3", dpars = c("mu", "zi"),
    link = "log",
    lb = c(NA, 0), ub = c(NA, 1),
    type = "int"
)

stan_funs <- "
real random_rounding_lpmf(int y, int base) {
  real lambda = 1. * (y % base) / base;
  int y_down = y - (y % base);
  if (y % base == 0) {
    return y * bernoulli_lpmf(1 | 1);
  } else {
    return (y_down + base) * bernoulli_lpmf(1 | lambda) +
      y_down * bernoulli_lpmf(0 | lambda);
  }
}
real zero_inflated_poisson_log_lpmf(int y, real eta, real zi) {
  if (y == 0) {
    return log_sum_exp(bernoulli_lpmf(1 | zi),
                       bernoulli_lpmf(0 | zi) +
                       poisson_log_lpmf(0 | eta));
  } else {
    return bernoulli_lpmf(0 | zi) +
           poisson_log_lpmf(y | eta);
  }
}
real zero_inflated_poisson_log_rr3_lpmf(int y, real eta, real zi) {
  return zero_inflated_poisson_log_lpmf(y | eta, zi) +
         random_rounding_lpmf(y | 3);
}
"


if (sys.nframe() == 0){
    bform <- bf(Count ~ Sex + Age + Ethnicity + Offence + Duration, decomp = 'QR')

    stanvars <- stanvar(scode = stan_funs, block = "functions")

    stancode <- make_stancode(
        bform,
        data = prison_pop,
        family = zero_inflated_poisson_rr3,
        stanvars = stanvars,
        save_model = here('models/brms_zero_inflated_poisson_rr3.stan'))
}
