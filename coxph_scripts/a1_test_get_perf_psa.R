source("RK_get_perf_psa.R")
library(data.table)

# get dataframe for model
#args<-commandArgs(TRUE)
args<-commandArgs(TRUE)

#age_var = as.character(args[2])
#status_var = as.character(args[3])

#print(age_var)
#print(status_var)

file = fread(args[1],sep="\t")
psa = file[[args[3]]]

if (args[2] == "PC"){
age = (as.numeric(file$PC_age))
status = (as.numeric(file$PC))

# calling RK_get_perf with sample-weight correction
p1 = RK_get_perf(age, status, psa, swc.switch = FALSE)
write.csv(as.data.frame(p1),args[4])

}

if (args[2] == "met"){
age = (as.numeric(file$met_age))
status = (as.numeric(file$met))

# calling RK_get_perf with sample-weight correction
p1 = RK_get_perf(age, status, psa, swc.switch = FALSE)
write.csv(as.data.frame(p1),args[4])

}

if (args[2] == "PC_death"){
age = (as.numeric(file$PC_death_age))
status = (as.numeric(file$PC_death))

# calling RK_get_perf with sample-weight correction
p1 = RK_get_perf(age, status, psa, swc.switch = FALSE)
write.csv(as.data.frame(p1),args[4])

}

