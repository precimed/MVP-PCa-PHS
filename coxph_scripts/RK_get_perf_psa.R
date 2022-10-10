RK_get_perf <- function(Age, status, psa, ref = NULL, swc.switch = TRUE, swc.caco = NULL){
  # Returns: 
  # list with following metrics: beta, p, swc, HR98_50, HR20_50, HR80_20 
  # beta - numeric, coefficient of PSA value in a univariable Cox-PH model 
  # p - numeric, p-value of PSA coefficient in a univariable Cox-PH model 
  # swc - logical indicator, whether sample-weight correction was applied 
  # HR80_50 - numeric, hazard-ratio between top 20% to middle 40% 
  # HR20_50 - numeric, hazard ratio between botton 20% to middle 40% 
  # HR80_20 - numeric, hazard ratio between top 20% to bottom 20%
  # HR95_50 - numeric, hazard ratio between top 5% to middle 40%
  # Inputs: 
  # psa - numeric, vector of PSA values
  # Age - numeric, vector of age-at-diagnosis for cases / age-at-last-follow-up for controls (1 x n)
  # status -  numeric, vector of time-to-event status [0 - event censored, 1 - event occured] (1 x n) 
  # ref - numeric, vector of reference PHS values (1 x m), defaults to hard-coded values for PHS290
  # swc.switch - logical indicator, TRUE (default) - apply sample-weight correction | FALSE: estimate raw perforrmance metrics 
  # swc.caco - numeric, vector of case/control status for sample-weight correction, [0 - control, 1 - case], defaults to status 
  
  if (is.null(swc.caco)){
    swc.caco = status
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
  swc.wvec = swc.caco*(swc.popnumcases/swc.numcases) + (!swc.caco)*(swc.popnumcontrols/swc.numcontrols);
  
  # fit CoxPH, observations weighted by swc.wvec 
  tmp.df = data.frame(Age = Age, status = status, psa=psa,  wvec = swc.wvec)
  if (swc.switch == TRUE){
    cxph = coxph(Surv(Age, status) ~ psa, data = tmp.df, weights = swc.wvec)
    print(summary(cxph))
  } else{
    cxph = coxph(Surv(Age, status) ~ psa, data = tmp.df)
    print(summary(cxph))
  }
  
   perf_list = list(beta = as.numeric(cxph$coefficients[1]), p = as.numeric(summary(cxph)$coefficients[,5][1]), cindex = as.numeric(cxph$concordance['concordance']), swc = as.logical(swc.switch))
  return(perf_list)
  }
