 data{
  int N;
  int response[N];
  int action[N];
  int intention[N];
  int contact[N];
}
parameters{
  ordered[6] cutpoints;
  real bA;
  real bI;
  real bC;
  real bAI;
  real bCI;
}
model{
  vector[N] phi;
  target += normal_lpdf(cutpoints | 0 , 10 );
  for ( i in 1:N )
    phi[i] = bA * action[i] + bI * intention[i] + bC * contact[i] +
             bAI * action[i] * intention[i] + bCI * contact[i] * intention[i];
  for ( i in 1:N )
    target += ordered_logistic_lpmf(response[i] | phi[i] , cutpoints );
  target += normal_lpdf(bA | 0, 10);
  target += normal_lpdf(bI | 0, 10);
  target += normal_lpdf(bC | 0, 10);
  target += normal_lpdf(bAI | 0, 10);
  target += normal_lpdf(bCI | 0, 10);
}
generated quantities {
  vector[N] log_lik;
  {
  vector[N] phi;
    for ( i in 1:N )
      phi[i] = bA * action[i] + bI * intention[i] + bC * contact[i] +
               bAI * action[i] * intention[i] + bCI * contact[i] * intention[i];
    for ( i in 1:N )
      log_lik[i] = ordered_logistic_lpmf(response[i] | phi[i] , cutpoints );
  }
}
