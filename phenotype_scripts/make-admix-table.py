import pandas as pd
import os

# get genetic ancestry designations

df=pd.read_csv("/group/research/mvp022/PHS/data/phs_files/phs290_eth/all.male.prs.release4.tsv",delimiter="\t")

compiled_pt=pd.DataFrame()
ancestry_dir="/group/research/mvp022/data/ancestry_groups/"
for group in [x for x in os.listdir(ancestry_dir) if "males" in x]:
	pts=pd.read_csv(ancestry_dir+group,header=None,delimiter="\t")[0].tolist()
	pt_counts=df[df["FID"].isin(pts)]["group"].value_counts().reset_index()
	pt_counts["ancestry"]=group	
	compiled_pt=compiled_pt.append(pt_counts)

compiled_pt.to_csv("group.ancestry.counts.csv")

admix=pd.read_csv("/data/data1/mvp022/Genotyping_Data/Release4/20200917.Release4/20200917.GenotypeData.Release4.admixture.txt",delim_whitespace=True)

compiled_admix=pd.DataFrame()

for x in df["group"].unique():
	pts=df[df["group"]==x]["FID"].tolist()
	df_mean=admix[admix["ID"].isin(pts)].mean().reset_index()
	df_std=admix[admix["ID"].isin(pts)].std().reset_index()
	df_mean.columns=["ID","mean"]
	df_std.columns=["ID","std"]
	df_admix=pd.merge(df_mean, df_std,on="ID")
	df_admix["group"]=x
	compiled_admix=compiled_admix.append(df_admix)

compiled_admix.to_csv("group.admix.values.csv")
