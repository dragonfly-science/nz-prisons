 data{
  int n;

  int n_Sex;
  int n_Age;
  int n_Ethnicity;
  int n_Offence;
  int n_Duration;

  /* int Sex[n]; */
  /* int Age[n]; */
  /* int Ethnicity[n]; */
  /* int Offence[n]; */
  /* int Duration[n]; */

}
generated quantities {

  int y_Sex[n];
  int y_Age[n];
  int y_Ethnicity[n];
  int y_Offence[n];
  int y_Duration[n];

  real alpha = 1;

  simplex[n_Sex] thetaSex;
  simplex[n_Ethnicity] thetaEthnicity;
  simplex[n_Offence] thetaOffence;

  // Random intercepts
  vector[n_Age] b_Age;
  vector[n_Duration] b_Duration;

  // Cutpoints for ordered logistic regression
  ordered[n_Age-1] c_Age;
  ordered[n_Duration-1] c_Duration;

  int phi_Age[n];
  int phi_Duration[n];

  // Priors
  thetaSex = dirichlet_rng(rep_vector(alpha, n_Sex));
  thetaEthnicity = dirichlet_rng(rep_vector(alpha, n_Ethnicity));
  thetaOffence = dirichlet_rng(rep_vector(alpha, n_Offence));

  // Random intercepts
  for (i in 1:n) {
    y_Sex[i] = categorical_rng(thetaSex);
    y_Ethnicity[i] = categorical_rng(thetaEthnicity);
    y_Offence[i] = categorical_rng(thetaOffence);

    // Cutpoints for ordered logistic distributions
    c_Age[i] = normal_rng(0, 10);
    c_Duration[i] = normal_rng(0, 10);

  }

  print("b_Age: ", b_Age)
  print("Age: ", Age)
  print("c_Age: ", c_Age)

  /* for (i in 1:n) { */
  /*   phiAge[i] ~ ordered_logistic(b_Age * Age[i], c_Age); */
  /*   phiDuration[i] ~ ordered_logistic(b_Duration * Duration[i], c_Duration); */

  /* } */

}
