// generated with brms 2.13.0
functions {

  /* zero-inflated poisson log-PDF of a single response 
   * Args: 
   *   y: the response value 
   *   lambda: mean parameter of the poisson distribution
   *   zi: zero-inflation probability
   * Returns:  
   *   a scalar to be added to the log posterior 
   */ 
  real zero_inflated_poisson_lpmf(int y, real lambda, real zi) { 
    if (y == 0) { 
      return log_sum_exp(bernoulli_lpmf(1 | zi), 
                         bernoulli_lpmf(0 | zi) + 
                         poisson_lpmf(0 | lambda)); 
    } else { 
      return bernoulli_lpmf(0 | zi) +  
             poisson_lpmf(y | lambda); 
    } 
  }
  /* zero-inflated poisson log-PDF of a single response 
   * logit parameterization of the zero-inflation part
   * Args: 
   *   y: the response value 
   *   lambda: mean parameter of the poisson distribution
   *   zi: linear predictor for zero-inflation part 
   * Returns:  
   *   a scalar to be added to the log posterior 
   */ 
  real zero_inflated_poisson_logit_lpmf(int y, real lambda, real zi) { 
    if (y == 0) { 
      return log_sum_exp(bernoulli_logit_lpmf(1 | zi), 
                         bernoulli_logit_lpmf(0 | zi) + 
                         poisson_lpmf(0 | lambda)); 
    } else { 
      return bernoulli_logit_lpmf(0 | zi) +  
             poisson_lpmf(y | lambda); 
    } 
  }
  /* zero-inflated poisson log-PDF of a single response
   * log parameterization for the poisson part
   * Args: 
   *   y: the response value 
   *   eta: linear predictor for poisson distribution
   *   zi: zero-inflation probability
   * Returns:  
   *   a scalar to be added to the log posterior 
   */ 
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
  /* zero-inflated poisson log-PDF of a single response 
   * log parameterization for the poisson part
   * logit parameterization of the zero-inflation part
   * Args: 
   *   y: the response value 
   *   eta: linear predictor for poisson distribution
   *   zi: linear predictor for zero-inflation part 
   * Returns:  
   *   a scalar to be added to the log posterior 
   */ 
  real zero_inflated_poisson_log_logit_lpmf(int y, real eta, real zi) { 
    if (y == 0) { 
      return log_sum_exp(bernoulli_logit_lpmf(1 | zi), 
                         bernoulli_logit_lpmf(0 | zi) + 
                         poisson_log_lpmf(0 | eta)); 
    } else { 
      return bernoulli_logit_lpmf(0 | zi) +  
             poisson_log_lpmf(y | eta); 
    } 
  }
  // zero-inflated poisson log-CCDF and log-CDF functions
  real zero_inflated_poisson_lccdf(int y, real lambda, real zi) { 
    return bernoulli_lpmf(0 | zi) + poisson_lccdf(y | lambda); 
  }
  real zero_inflated_poisson_lcdf(int y, real lambda, real zi) { 
    return log1m_exp(zero_inflated_poisson_lccdf(y | lambda, zi));
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
  real<lower=0,upper=1> zi;  // zero-inflation probability
}
transformed parameters {
}
model {
  // initialize linear predictor term
  vector[N] mu = Intercept + XQ * bQ;
  // priors including all constants
  target += student_t_lpdf(Intercept | 3, 1.8, 4.6);
  target += beta_lpdf(zi | 1, 1);
  // likelihood including all constants
  if (!prior_only) {
    for (n in 1:N) {
      target += zero_inflated_poisson_log_lpmf(Y[n] | mu[n], zi);
    }
  }
}
generated quantities {
  // obtain the actual coefficients
  vector[Kc] b = XR_inv * bQ;
  // actual population-level intercept
  real b_Intercept = Intercept - dot_product(means_X, b);
}
