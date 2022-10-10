source("RK_get_perf_eth.R")
library(data.table)

# get dataframe for model
args<-commandArgs(TRUE)

file = fread(args[1],sep="\t")
group = file$group

if (args[2] == "PC"){
age = (as.numeric(file$PC_age))
status = (as.numeric(file$PC))

p1 = RK_get_perf(age, status, group,swc.switch=FALSE)
write.csv(as.data.frame(p1),args[3])

}


if (args[2] == "met"){
age = (as.numeric(file$met_age))
status = (as.numeric(file$met))

p1 = RK_get_perf(age, status, group,swc.switch=FALSE)
write.csv(as.data.frame(p1),args[3])
}

if (args[2] == "PC_death"){

age = (as.numeric(file$PC_death_age))
status = (as.numeric(file$PC_death))

p1 = RK_get_perf(age, status, group, swc.switch=FALSE)
write.csv(as.data.frame(p1),args[3])
}

