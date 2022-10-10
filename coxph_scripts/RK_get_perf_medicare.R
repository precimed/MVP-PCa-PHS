RK_get_perf <- function(Age, status, medicare, ref = NULL, swc.switch = TRUE, swc.caco = NULL){
  # Returns: 
  # list with following metrics: beta, p, swc
  # beta - numeric, coefficient of medicare in a univariable Cox-PH model 
  # p - numeric, p-value of medicare coefficient in a univariable Cox-PH model 
  # swc - logical indicator, whether sample-weight correction was applied 
  # Inputs: 
  # medicare - categorical, vector of medicare status (1/0) 
  # Age - numeric, vector of age-at-diagnosis for cases / age-at-last-follow-up for controls (1 x n)
  # status -  numeric, vector of time-to-event status [0 - event censored, 1 - event occured] (1 x n) 
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
  tmp.df = data.frame(Age = Age, status = status, medicare = medicare, wvec = swc.wvec)
  if (swc.switch == TRUE){
    print("using sample weight correction")
    cxph = coxph(Surv(Age, status) ~ medicare, data = tmp.df, weights = swc.wvec)
  } else{
    print("no sample weight correction")
    cxph = coxph(Surv(Age, status) ~ medicare, data = tmp.df)
    print(summary(cxph))
  }

  perf_list = list(beta = as.numeric(cxph$coefficients[1]), p = as.numeric(summary(cxph)$coefficients[,5][1]), cindex = as.numeric(cxph$concordance['concordance']), swc = as.logical(swc.switch))

  return(perf_list)
}
