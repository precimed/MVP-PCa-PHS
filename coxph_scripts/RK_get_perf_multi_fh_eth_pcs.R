RK_get_perf <- function(lp, Age, status, group, fh, pc1, pc2, pc3, pc4, pc5, pc6, pc7, pc8, pc9, pc10,ref = NULL, swc.switch = TRUE, swc.caco = NULL){


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
  # lp - numeric, vector of PHS scores (1 x n) 
  # group - categorical, race/ethnicity group
  # fh - categorical, family history of prostate cancer (1 x n)
  # pc1-10 - numeric, principal components of population stratification
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
  swc.wvec = swc.caco*(swc.popnumcases/swc.numcases) + (!swc.caco)*(swc.popnumcontrols/swc.numcontrols);
  
  # fit CoxPH, observations weighted by swc.wvec 
  groupF = factor(group, levels=c('EUR','AFR','HIS','OTHER','NATIVE', 'ASN', 'UNKNOWN', 'PACIFIC'),ordered=FALSE)
  tmp.df = data.frame(Age = Age, status = status, lp = lp, group=groupF, fh=fh, pc1=pc1, pc2=pc2, pc3=pc3, pc4=pc4, pc5=pc5, pc6=pc6, pc7=pc7, pc8=pc8, pc9=pc9, pc10=pc10, wvec = swc.wvec)
  if (swc.switch == TRUE){
    cxph = coxph(Surv(Age, status) ~ lp + group + fh + pc1 + pc2 + pc3 + pc4 + pc5 + pc6 + pc7 + pc8 + pc9 + pc10, data = tmp.df, weights = swc.wvec)
  } else{
    cxph = coxph(Surv(Age, status) ~ lp + group + fh +pc1 + pc2 + pc3 + pc4 + pc5 + pc6 + pc6 + pc7 + pc8 + pc9 + pc10, data = tmp.df)
    print(summary(cxph))
  }
  
  
   perf_list = list(beta = as.numeric(cxph$coefficients[1]), p = as.numeric(summary(cxph)$coefficients[,5][1]), cindex = as.numeric(cxph$concordance['concordance']), swc = as.logical(swc.switch))
  
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
  
  #get coeficients of HARE
  hare_list = hare_list = list(beta_afr = as.numeric(cxph$coefficients[2]), p_afr = as.numeric(summary(cxph)$coefficients[,5][2]), beta_his = as.numeric(cxph$coefficients[3]), p_his = as.numeric(summary(cxph)$coefficients[,5][3]), beta_oth = as.numeric(cxph$coefficients[4]), p_oth = as.numeric(summary(cxph)$coefficients[,5][4]),beta_native = as.numeric(cxph$coefficients[5]), p_native = as.numeric(summary(cxph)$coefficients[,5][5]),beta_asn = as.numeric(cxph$coefficients[6]), p_asn = as.numeric(summary(cxph)$coefficients[,5][6]),beta_unknown = as.numeric(cxph$coefficients[7]), p_unknown = as.numeric(summary(cxph)$coefficients[,5][7]), beta_pac = as.numeric(cxph$coefficients[8]), p_pac = as.numeric(summary(cxph)$coefficients[,5][8]))
   perf_list = c(perf_list, hare_list)  
  #get coefficients of FH
  fh_list = list(beta_fh = as.numeric(cxph$coefficients[9]), p_fh = as.numeric(summary(cxph)$coefficients[,5][9]))
  perf_list = c(perf_list, fh_list)

  #get coefficients of PC1-10
  pc_list = list(beta_pc1 = as.numeric(cxph$coefficients[10]), p_pc1 = as.numeric(summary(cxph)$coefficients[,5][10]), beta_pc2 = as.numeric(cxph$coefficients[11]), p_pc2 = as.numeric(summary(cxph)$coefficients[,5][11]),beta_pc3 = as.numeric(cxph$coefficients[12]), p_pc3 = as.numeric(summary(cxph)$coefficients[,5][12]), beta_pc4 = as.numeric(cxph$coefficients[13]), p_pc4 = as.numeric(summary(cxph)$coefficients[,5][13]), beta_pc5 = as.numeric(cxph$coefficients[14]), p_pc5 = as.numeric(summary(cxph)$coefficients[,5][14]), beta_pc6 = as.numeric(cxph$coefficients[15]), p_pc6 = as.numeric(summary(cxph)$coefficients[,5][15]), beta_pc7 = as.numeric(cxph$coefficients[16]), p_pc7 = as.numeric(summary(cxph)$coefficients[,5][16]), beta_pc8 = as.numeric(cxph$coefficients[17]), p_pc8 = as.numeric(summary(cxph)$coefficients[,5][17]), beta_pc9 = as.numeric(cxph$coefficients[18]), p_pc9 = as.numeric(summary(cxph)$coefficients[,5][18]),beta_pc10 = as.numeric(cxph$coefficients[19]), p_pc10 = as.numeric(summary(cxph)$coefficients[,5][19]))
  perf_list = c(perf_list, pc_list)
  print(perf_list)
  return(perf_list)
    
  }
