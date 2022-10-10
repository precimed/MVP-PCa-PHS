RK_get_perf <- function(Age, status, group, ref = NULL, swc.switch = TRUE, swc.caco = NULL){
  # Returns: 
  # list with following metrics: beta, p, swc
  # beta - numeric, coefficient of group in a univariable Cox-PH model 
  # p - numeric, p-value of group in a univariable Cox-PH model 
  # swc - logical indicator, whether sample-weight correction was applied 
  # Inputs: 
  # Age - numeric, vector of age-at-diagnosis for cases / age-at-last-follow-up for controls (1 x n)
  # status -  numeric, vector of time-to-event status [0 - event censored, 1 - event occured] (1 x n) 
  # group - categorical, vector of ethnicity groups 
  # ref - numeric, vector of reference PHS values (1 x m), defaults to hard-coded values for PHS290
  # swc.switch - logical indicator, TRUE (default) - apply sample-weight correction | FALSE: estimate raw perforrmance metrics 
  # swc.caco - numeric, vector of case/control status for sample-weight correction, [0 - control, 1 - case], defaults to status 
  
  if (is.null(swc.caco)){
    swc.caco = status
  }
  
  # set up numerator and denomiator groups and critical values
 
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
  groupF = factor(group, levels=c('EUR','AFR','HIS','OTHER','NATIVE', 'ASN', 'UNKNOWN', 'PACIFIC'),ordered=FALSE)
  tmp.df = data.frame(Age = Age, status = status, group=groupF,  wvec = swc.wvec)
  if (swc.switch == TRUE){
    cxph = coxph(Surv(Age, status) ~ group, data = tmp.df, weights = swc.wvec)
  } else{
    cxph = coxph(Surv(Age, status) ~ group, data = tmp.df)
    print(summary(cxph))
  }
 
  #get coefficients of ethnicity groups
  perf_list = list(beta_afr = as.numeric(cxph$coefficients[1]), p_afr = as.numeric(summary(cxph)$coefficients[,5][1]), beta_his = as.numeric(cxph$coefficients[2]), p_his = as.numeric(summary(cxph)$coefficients[,5][2]), beta_oth = as.numeric(cxph$coefficients[3]), p_oth = as.numeric(summary(cxph)$coefficients[,5][3]),beta_native = as.numeric(cxph$coefficients[4]), p_native = as.numeric(summary(cxph)$coefficients[,5][4]),beta_asn = as.numeric(cxph$coefficients[5]), p_asn = as.numeric(summary(cxph)$coefficients[,5][5]),beta_unknown = as.numeric(cxph$coefficients[6]), p_unknown = as.numeric(summary(cxph)$coefficients[,5][6]), beta_pac = as.numeric(cxph$coefficients[7]), p_pac = as.numeric(summary(cxph)$coefficients[,5][7]))  
  return(perf_list)
  }
