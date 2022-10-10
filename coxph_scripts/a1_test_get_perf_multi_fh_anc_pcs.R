source("RK_get_perf_multi_fh_pcs_anc.R")
library(data.table)

# get dataframe for model
#args<-commandArgs(TRUE)
args<-commandArgs(TRUE)

file = fread(args[1],sep="\t")
phs = file$score
fh = file$FH
group = file$group
pc1=file$pc1
pc2=file$pc2
pc3=file$pc3
pc4=file$pc4
pc5=file$pc5
pc6=file$pc6
pc7=file$pc7
pc8=file$pc8
pc9=file$pc9
pc10=file$pc10

if (args[2] == "PC"){
age = (as.numeric(file$PC_age))
status = (as.numeric(file$PC))

# calling RK_get_perf with sample-weight correction
p1 = RK_get_perf(phs, age, status, group, fh, pc1, pc2, pc3, pc4, pc5, pc6, pc7, pc8, pc9, pc10, swc.switch = FALSE)
write.csv(as.data.frame(p1),args[3])

}

if (args[2] == "met"){
age = (as.numeric(file$met_age))
status = (as.numeric(file$met))

# calling RK_get_perf with sample-weight correction
p1 = RK_get_perf(phs, age, status, group, fh, pc1, pc2, pc3, pc4, pc5, pc6, pc7, pc8, pc9, pc10, swc.switch = FALSE)
write.csv(as.data.frame(p1),args[3])

}

if (args[2] == "PC_death"){
age = (as.numeric(file$PC_death_age))
status = (as.numeric(file$PC_death))

# calling RK_get_perf with sample-weight correction
p1 = RK_get_perf(phs, age, status, group, fh, pc1, pc2, pc3, pc4, pc5, pc6, pc7, pc8, pc9, pc10, swc.switch = FALSE)
write.csv(as.data.frame(p1),args[3])

}

