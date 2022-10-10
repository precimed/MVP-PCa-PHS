RK_get_perf <- function(lp, Age, status, ref = NULL, swc.switch = TRUE, swc.caco = NULL){
  # Returns: 
  # list with following metrics: beta, p, swc, HR98_50, HR20_50, HR80_20 
  # beta - numeric, coefficient of PHS in a univariable Cox-PH model 
  # p - numeric, p-value of PHS coefficient in a univariable Cox-PH model 
  # swc - logical indicator, whether sample-weight correction was applied 
  # HR80_50 - numeric, hazard-ratio between top 20% to middle 40% 
  # HR20_50 - numeric, hazard ratio between botton 20% to middle 40% 
  # HR80_20 - numeric, hazard ratio between top 20% to bottom 20%
  # HR95_50 - numeric, hazard ratio between top 5% to middle 40%
  # Inputs: 
  # lp - numeric, vector of PHS scores (1 x n) 
  # Age - numeric, vector of age-at-diagnosis for cases / age-at-last-follow-up for controls (1 x n)
  # status -  numeric, vector of time-to-event status [0 - event censored, 1 - event occured] (1 x n) 
  # ref - numeric, vector of reference PHS values (1 x m), defaults to hard-coded values for PHS290
  # swc.switch - logical indicator, TRUE (default) - apply sample-weight correction | FALSE: estimate raw perforrmance metrics 
  # swc.caco - numeric, vector of case/control status for sample-weight correction, [0 - control, 1 - case], defaults to status 
  
  if (is.null(swc.caco)){
    swc.caco = status
  }
  
  # set up numerator and denomiator groups and critical values
  if (is.null(ref)){
    hr_names = c('HR80_50', 'HR20_50', 'HR80_20', 'HR95_50')
    num_critvals = matrix(c(9.639068, Inf, 
                            -Inf,  9.004659,
                            9.639069, Inf, 
                            9.946332, Inf), 
                          nrow = 4, ncol = 2, byrow = TRUE)
    den_critvals = matrix(c(9.123500, 9.519703,
                            9.123500, 9.519703,
                            -Inf, 9.004659,
                            9.123500, 9.519703),
                          nrow = 4, ncol = 2, byrow = TRUE)
  } else{
    hr_names = c('HR80_50', 'HR20_50', 'HR80_20', 'HR95_50')
    num_critvals = matrix(c(quantile(ref, 0.8, names = FALSE), Inf, 
                            -Inf, quantile(ref, 0.2, names = FALSE), 
                            quantile(ref, 0.8, names = FALSE), Inf, 
                            quantile(ref, 0.95, names = FALSE), Inf),
                          nrow = 4, ncol = 2, byrow = TRUE)
    den_critvals = matrix(c(quantile(ref, 0.3, names = FALSE), quantile(ref, 0.7, names = FALSE), 
                            quantile(ref, 0.3, names = FALSE), quantile(ref, 0.7, names = FALSE),
                            -Inf, quantile(ref, 0.2, names = FALSE), 
                            quantile(ref, 0.3, names = FALSE), quantile(ref, 0.7, names = FALSE)),
                          nrow = 4, ncol = 2, byrow = TRUE) 
  }
  
  # dependencies 
  require(survival) 
  
  # statusvec 
  statusvec = status == 1 * 1.0
  
  # set default values for swc.numcases, numcontrols 
  swc.numcases = sum(swc.caco == 1)
  swc.numcontrols = sum(swc.caco == 0)
  
  # sample-weight correction parameters 
  swc.popnumcases = 9024
  swc.popnumcontrols = 1953203
  #swc.popnumcases = 2896;
  #swc.popnumcontrols = 79533; 
  swc.wvec = swc.caco*(swc.popnumcases/swc.numcases) + (!swc.caco)*(swc.popnumcontrols/swc.numcontrols);
  
  # fit CoxPH, observations weighted by swc.wvec 
  tmp.df = data.frame(Age = Age, status = status, lp = lp, wvec = swc.wvec)
  if (swc.switch == TRUE){
    print("using sample weight correction")
    cxph = coxph(Surv(Age, status) ~ lp, data = tmp.df, weights = swc.wvec)
  } else{
    print("no sample weight correction")
    cxph = coxph(Surv(Age, status) ~ lp, data = tmp.df)
  }
  perf_list = list(beta = as.numeric(cxph$coefficients), p = as.numeric(summary(cxph)$coefficients[length(summary(cxph)$coefficients)]), 
                   cindex = as.numeric(cxph$concordance['concordance']),
                   swc = as.logical(swc.switch))
  
  
  # iterate through eff/ref_ranges
  hr_list = list()
  for (id1 in 1:nrow(num_critvals)){
    # get indices for num/den groups in lp
    ix.num = which(lp >= num_critvals[id1,1] & lp <= num_critvals[id1,2])
    ix.den = which(lp >= den_critvals[id1,1] & lp <= den_critvals[id1,2]) 
    
    # estimate the HR between the different combinations of num/den groups
    beta_lp = perf_list$beta * lp
    beta_lp_num = mean(beta_lp[ix.num])
    beta_lp_den = mean(beta_lp[ix.den])
    HR = exp(beta_lp_num - beta_lp_den)
    hr_list[id1] = HR
  }  
  # set names of HR 
  names(hr_list) = hr_names
  # cat to perf_list
  perf_list = c(perf_list, hr_list)
  return(perf_list)
}
