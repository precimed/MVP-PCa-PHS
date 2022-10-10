library(survival)
library(data.table)

args<-commandArgs(TRUE)

#run comparison between cxph model with phs vs no phs

print("prostate cancer")
tmp.df <- read.table(args[1], sep='\t', header=TRUE)
cxph1 = coxph(Surv(PC_age, PC) ~ cleaned_psa, data = tmp.df)
cxph2 = coxph(Surv(PC_age, PC) ~ cleaned_psa + score, data = tmp.df)
print(anova(cxph1,cxph2))

cxph1 = coxph(Surv(PC_age, PC) ~ cleaned_psa + score, data = tmp.df)
cxph2 = coxph(Surv(PC_age, PC) ~ cleaned_psa + score + group, data = tmp.df)
print(anova(cxph1,cxph2))

cxph1 = coxph(Surv(PC_age, PC) ~ cleaned_psa + score, data = tmp.df)
cxph2 = coxph(Surv(PC_age, PC) ~ cleaned_psa + score + group + FH, data = tmp.df)
print(anova(cxph1,cxph2))

print("metastatic")
cxph1 = coxph(Surv(met_age, met) ~ cleaned_psa, data = tmp.df)
cxph2 = coxph(Surv(met_age, met) ~ cleaned_psa + score, data = tmp.df)
print(anova(cxph1,cxph2))

cxph1 = coxph(Surv(met_age, met) ~ cleaned_psa + score, data = tmp.df)
cxph2 = coxph(Surv(met_age, met) ~ cleaned_psa + score + group, data = tmp.df)
print(anova(cxph1,cxph2))

cxph1 = coxph(Surv(met_age, met) ~ cleaned_psa + score, data = tmp.df)
cxph2 = coxph(Surv(met_age, met) ~ cleaned_psa + score + group + FH, data = tmp.df)
print(anova(cxph1,cxph2))

print("fatal")
cxph1 = coxph(Surv(PC_death_age, PC_death) ~ cleaned_psa, data = tmp.df)
cxph2 = coxph(Surv(PC_death_age, PC_death) ~ cleaned_psa + score, data = tmp.df)
print(anova(cxph1,cxph2))

cxph1 = coxph(Surv(PC_death_age, PC_death) ~ cleaned_psa + score, data = tmp.df)
cxph2 = coxph(Surv(PC_death_age, PC_death) ~ cleaned_psa + score + group, data = tmp.df)
print(anova(cxph1,cxph2))

cxph1 = coxph(Surv(PC_death_age, PC_death) ~ cleaned_psa + score, data = tmp.df)
cxph2 = coxph(Surv(PC_death_age, PC_death) ~ cleaned_psa + score + group + FH, data = tmp.df)
print(anova(cxph1,cxph2))
