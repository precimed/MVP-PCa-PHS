RK_get_perf <- function(Age, status, group, fh, ref = NULL, swc.switch = TRUE, swc.caco = NULL){
  # Returns: 
  # list with following metrics: beta, p, swc, HR98_50, HR20_50, HR80_20 
  # beta values - numeric, coefficient of various variables in a multivariable Cox-PH model 
  # p - numeric, p-values of various variables in a multivariable Cox-PH model 
  # swc - logical indicator, whether sample-weight correction was applied 
  # HR80_50 - numeric, hazard-ratio between top 20% to middle 40% 
  # HR20_50 - numeric, hazard ratio between botton 20% to middle 40% 
  # HR80_20 - numeric, hazard ratio between top 20% to bottom 20%
  # HR95_50 - numeric, hazard ratio between top 5% to middle 40%
  # Inputs: 
  # group - categorical, HARE group
  # fh - categorical, family history of prostate cancer (1 x n)
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
  groupF = factor(group, levels=c('EUR','AFR','HIS','OTHER','NATIVE', 'ASN', 'UNKNOWN', 'PACIFIC'),ordered=FALSE)
  tmp.df = data.frame(Age = Age, status = status, group=groupF, fh=fh,  wvec = swc.wvec)
  if (swc.switch == TRUE){
    cxph = coxph(Surv(Age, status) ~ fh + group, data = tmp.df, weights = swc.wvec)
    print(summary(cxph))

  } else{
    print("no correction")
    cxph = coxph(Surv(Age, status) ~ fh + group, data = tmp.df)
    print(summary(cxph))
  }
  
   perf_list = list(beta_fh = as.numeric(cxph$coefficients[1]), p_fh = as.numeric(summary(cxph)$coefficients[,5][1]), cindex = as.numeric(cxph$concordance['concordance']), swc = as.logical(swc.switch))

  
  #get coeficients of race/ethnicity
  group_list = list(beta_afr = as.numeric(cxph$coefficients[2]), p_afr = as.numeric(summary(cxph)$coefficients[,5][2]), beta_his = as.numeric(cxph$coefficients[3]), p_his = as.numeric(summary(cxph)$coefficients[,5][3]), beta_oth = as.numeric(cxph$coefficients[4]), p_oth = as.numeric(summary(cxph)$coefficients[,5][4]),beta_native = as.numeric(cxph$coefficients[5]), p_native = as.numeric(summary(cxph)$coefficients[,5][5]),beta_asn = as.numeric(cxph$coefficients[6]), p_asn = as.numeric(summary(cxph)$coefficients[,5][6]),beta_unknown = as.numeric(cxph$coefficients[7]), p_unknown = as.numeric(summary(cxph)$coefficients[,5][7]), beta_pac = as.numeric(cxph$coefficients[8]), p_pac = as.numeric(summary(cxph)$coefficients[,5][8]))
  perf_list = c(perf_list, group_list)  
  return(perf_list)

  }
