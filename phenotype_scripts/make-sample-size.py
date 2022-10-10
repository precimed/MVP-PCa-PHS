import pandas as pd

df=pd.read_csv("all.male.prs.release4.tsv",delimiter="\t")
df_fh=pd.read_csv("all.male.prs.fh.release4.tsv",delimiter="\t")


group=[]
total_num=[]
pc_num=[]
met_num=[]
death_num=[]
age_diag=[]
age_fu=[]


group.append("all")
total_num.append(str(len(df))+" ("+str(len(df_fh))+")")
pc_num.append(str(len(df[df["PC"]==1]))+" ("+str(len(df_fh[df_fh["PC"]==1]))+")")
met_num.append(str(len(df[df["met"]==1]))+" ("+str(len(df_fh[df_fh["met"]==1]))+")")
death_num.append(str(len(df[df["PC_death"]==1]))+" ("+str(len(df_fh[df_fh["PC_death"]==1]))+")")
age_diag.append(str(df[df["PC"]==1]["PC_age"].mean())+" ["+str(df[df["PC"]==1]["PC_age"].quantile(0.25))+"-"+str(df[df["PC"]==1]["PC_age"].quantile(0.75))+"]")
age_fu.append(str(df[df["PC"]==0]["PC_age"].mean())+" ["+str(df[df["PC"]==0]["PC_age"].quantile(0.25))+"-"+str(df[df["PC"]==0]["PC_age"].quantile(0.75))+"]")

for x in df["group"].unique():
	df_group=df[df["group"]==x]
	df_fh_group=df_fh[df_fh["group"]==x]
	total_num.append(str(len(df_group))+" ("+str(len(df_fh_group))+")")
	group.append(x)
	pc_num.append(str(len(df_group[df_group["PC"]==1]))+" ("+str(len(df_fh_group[df_fh_group["PC"]==1]))+")")
	met_num.append(str(len(df_group[df_group["met"]==1]))+" ("+str(len(df_fh_group[df_fh_group["met"]==1]))+")")
	death_num.append(str(len(df_group[df_group["PC_death"]==1]))+" ("+str(len(df_fh_group[df_fh_group["PC_death"]==1]))+")")
	age_diag.append(str(df_group[df_group["PC"]==1]["PC_age"].mean())+" ["+str(df_group[df_group["PC"]==1]["PC_age"].quantile(0.25))+"-"+str(df_group[df_group["PC"]==1]["PC_age"].quantile(0.75))+"]")
	age_fu.append(str(df_group[df_group["PC"]==0]["PC_age"].mean())+" ["+str(df_group[df_group["PC"]==0]["PC_age"].quantile(0.25))+"-"+str(df_group[df_group["PC"]==0]["PC_age"].quantile(0.75))+"]")

pd.DataFrame({"group":group,"total":total_num,"PC":pc_num,"met":met_num,"death":death_num,"age_diag":age_diag,"age_fu":age_fu}).to_csv("supp_table_1.csv")
