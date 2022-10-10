source("RK_get_perf_phs290.R")
library(data.table)

# get dataframe for model
args<-commandArgs(TRUE)

file = fread(args[1],sep="\t")
phs = file$score

if (args[2] == "PC"){
age = (as.numeric(file$PC_age))
status = (as.numeric(file$PC))


# calling RK_get_perf with sample-weight correction
p1 = RK_get_perf(phs, age, status, swc.switch = FALSE)
write.csv(as.data.frame(p1),args[3])

}

if (args[2] == "met"){
age = (as.numeric(file$met_age))
status = (as.numeric(file$met))


# calling RK_get_perf with sample-weight correction
p1 = RK_get_perf(phs, age, status, swc.switch = FALSE)
write.csv(as.data.frame(p1),args[3])

}

if (args[2] == "PC_death"){
age = (as.numeric(file$PC_death_age))
status = (as.numeric(file$PC_death))


# calling RK_get_perf with sample-weight correction
p1 = RK_get_perf(phs, age, status, swc.switch = FALSE)
write.csv(as.data.frame(p1),args[3])

}

if (args[2] == "met_diag"){
age = (as.numeric(file$met_diag_age))
status = (as.numeric(file$met_diag))

# generate reference values
ref = phs[age < 70 & status == 0]
print(dim(ref))

# calling RK_get_perf with sample-weight correction
p1 = RK_get_perf(phs, age, status, swc.switch = FALSE)
write.csv(as.data.frame(p1),args[3])

}

