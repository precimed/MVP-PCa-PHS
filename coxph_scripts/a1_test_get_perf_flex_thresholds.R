source("RK_get_perf.R")
library(data.table)

# get dataframe for model
args<-commandArgs(TRUE)

file = fread(args[1],sep="\t")
phs = file$score

if (args[2] == "PC"){
age = (as.numeric(file$PC_age))
status = (as.numeric(file$PC))

# generate reference values
ref = phs[age < 70 & status == 0]
print(dim(ref))

# calling RK_get_perf with sample-weight correction
p1 = RK_get_perf(phs, age, status,ref)
write.csv(as.data.frame(p1),args[3])

}

if (args[2] == "met"){
age = (as.numeric(file$met_age))
status = (as.numeric(file$met))

# generate reference values
ref = phs[age < 70 & status == 0]
print(dim(ref))

# calling RK_get_perf with sample-weight correction
p1 = RK_get_perf(phs, age, status,ref)
write.csv(as.data.frame(p1),args[3])

}

if (args[2] == "PC_death"){
age = (as.numeric(file$PC_death_age))
status = (as.numeric(file$PC_death))

# generate reference values
ref = phs[age < 70 & status == 0]
print(dim(ref))

# calling RK_get_perf with sample-weight correction
p1 = RK_get_perf(phs, age, status,ref)
write.csv(as.data.frame(p1),args[3])

}

