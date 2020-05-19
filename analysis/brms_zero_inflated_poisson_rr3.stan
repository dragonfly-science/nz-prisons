// generated with brms 2.12.11
functions {

real random_rounding_lpmf(int y, int base) {
  real lambda = 1. * (y % base) / base;
  if (y % base == 0) {
    return y * bernoulli_lpmf(1 | 1);
  } else {
    return (y - (y % base) + base) * bernoulli_lpmf(1 | lambda) +
      y - (y % base) * bernoulli_lpmf(0 | lambda);
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
real zero_inflated_poisson_rr3_lpmf(int y, real mu, real zi) {
  return zero_inflated_poisson_log_lpmf(y | mu, zi) +
         random_rounding_lpmf(y | 3);
}

}
data {
  int<lower=1> N;  // number of observations
  int Y[N];  // response variable
  int<lower=1> K;  // number of population-level effects
  matrix[N, K] X;  // population-level design matrix
  int prior_only;  // should the likelihood be ignored?
}
transformed data {
  int Kc = K - 1;
  matrix[N, Kc] Xc;  // centered version of X without an intercept
  vector[Kc] means_X;  // column means of X before centering
  // matrices for QR decomposition
  matrix[N, Kc] XQ;
  matrix[Kc, Kc] XR;
  matrix[Kc, Kc] XR_inv;
  for (i in 2:K) {
    means_X[i - 1] = mean(X[, i]);
    Xc[, i - 1] = X[, i] - means_X[i - 1];
  }
  // compute and scale QR decomposition
  XQ = qr_thin_Q(Xc) * sqrt(N - 1);
  XR = qr_thin_R(Xc) / sqrt(N - 1);
  XR_inv = inverse(XR);
}
parameters {
  vector[Kc] bQ;  // regression coefficients at QR scale
  real Intercept;  // temporary intercept for centered predictors
  real<lower=0,upper=1> zi;
}
transformed parameters {
}
model {
  // initialize linear predictor term
  vector[N] mu = Intercept + XQ * bQ;
  // priors including all constants
  target += student_t_lpdf(Intercept | 3, 0, 2.5);
  target += beta_lpdf(zi | 1, 1);
  // likelihood including all constants
  if (!prior_only) {
    for (n in 1:N) {
      target += zero_inflated_poisson_rr3_lpmf(Y[n] | mu[n], zi);
    }
  }
}
generated quantities {
  // obtain the actual coefficients
  vector[Kc] b = XR_inv * bQ;
  // actual population-level intercept
  real b_Intercept = Intercept - dot_product(means_X, b);
}
