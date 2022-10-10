source("RK_get_perf_multi_fh_eth_psa.R")
library(data.table)

args<-commandArgs(TRUE)

file = fread(args[1],sep="\t")
phs = file$score
fh = file$FH
group = file$group
psa = file[[args[3]]]

if (args[2] == "PC"){
age = (as.numeric(file$PC_age))
status = (as.numeric(file$PC))

# calling RK_get_perf with sample-weight correction
p1 = RK_get_perf(phs, age, status, group, fh, psa, swc.switch = FALSE)
write.csv(as.data.frame(p1),args[4])

}

if (args[2] == "met"){
age = (as.numeric(file$met_age))
status = (as.numeric(file$met))


# calling RK_get_perf with sample-weight correction
p1 = RK_get_perf(phs, age, status, group, fh, psa, swc.switch = FALSE)
write.csv(as.data.frame(p1),args[4])

}

if (args[2] == "PC_death"){
age = (as.numeric(file$PC_death_age))
status = (as.numeric(file$PC_death))

# calling RK_get_perf with sample-weight correction
p1 = RK_get_perf(phs, age, status, group, fh, psa, swc.switch = FALSE)
write.csv(as.data.frame(p1),args[4])

}

