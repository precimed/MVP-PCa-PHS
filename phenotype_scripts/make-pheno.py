import pandas as pd
import numpy as np
import argparse

#Get rishi dataframe

#contains variables related to:
	# prostate cancer diagnosis
	# age of prostate cancer diagnosis
	# age of last follow up

# for individuals without prostate cancer diagnosis, censor at age at last followup
rishi=pd.read_csv("/data/data1/mvp022/Vinci_Data/20201106/Dflt.rd_fullmvp22cohort2.csv",delimiter="|")
rishi["age_pc"]=rishi["ageatprostatecancerdiagnosis"]
rishi["age_pc"].fillna(rishi["ageatlastfollowup"],inplace=True)

mp_followup=dict(zip(rishi["mvp022_id"],rishi["ageatlastfollowup"])) 

mp_pc_status=dict(zip(rishi["mvp022_id"],rishi["prostatecancerdiagnosis"]))
mp_pc_age=dict(zip(rishi["mvp022_id"],rishi["age_pc"]))

# Get prostate cancer core dataframe

# contains variables related to:
	# age of metastatic diagnosis

pca=pd.read_csv("/data/data1/mvp022/Vinci_Data/20210121/VINCI_PCa_Data_Core.csv",delimiter="|")
mp_met_status=dict(zip(pca["mvp022_id"],pca["nlp_mpca_diagnosis"]))
pca["yomet"]=pca["nlp_initial_mpca_diagnosis_date"].str.split("-").str[0]
pca=pca[~(pca["yomet"].isnull())]
pca["yomet"]=pca["yomet"].astype(int)

# Get core dataframe

# contains variables related to:
	# year of birth

core=pd.read_csv("/data/data1/mvp022/Vinci_Data/20201230/MVP.CoreDemo_V19_2.csv",delimiter="|")
mp_yob=dict(zip(core["mvp022_id"],core["yob"]))

# calculate metastatic age by taking difference between year of birth and year of metastatic diagnosis
pca["yob"]=pca["mvp022_id"].map(mp_yob)
pca["age_met"]=pca["yomet"]-pca["yob"]
mp_met_age=dict(zip(pca["mvp022_id"],pca["age_met"]))

rishi["met"]=rishi["mvp022_id"].map(mp_met_status)
rishi["met_age"]=rishi["mvp022_id"].map(mp_met_age)

# get met at diagnosis
pca["met_time"]=pd.to_datetime(pca["date_first_dx"])-pd.to_datetime(pca["nlp_initial_mpca_diagnosis_date"])
pca["met_time"]=pca["met_time"].astype(int)/86400000000000
pca_met_diag=pca[abs(pca["met_time"])<365]
mp_met_diag_age=dict(zip(pca_met_diag["mvp022_id"],pca_met_diag["age_met"]))

# get clinically significant PC
core_gleason=pca[pca["first_gleason_value"]>=7]["mvp022_id"].tolist()
print(len(core_gleason))
rishi["PC_gleason"]=np.where(rishi["mvp022_id"].isin(core_gleason),1,0)
rishi["PC_gleason_age"]=np.where(rishi["mvp022_id"].isin(core_gleason),rishi["ageatprostatecancerdiagnosis"],rishi["ageatlastfollowup"])

mp_pc_gleason=dict(zip(rishi["mvp022_id"],rishi["PC_gleason"]))
mp_pc_gleason_age=dict(zip(rishi["mvp022_id"],rishi["PC_gleason_age"]))

#get death dataframe
death = pd.read_csv("/data/data1/mvp022/Vinci_Data/20210527/NDI_V19_2.csv",delimiter="|")
death["yod"]=death["dod_ndi2"].str.split("/").str[2]
death = death[~death["yod"].isnull()]
death["age_death"]=death["yod"].astype(int)-death["yob"]
death_pc=death[death["underlyingcause_ndi"]=="C61"]

mp_death=dict(zip(death_pc["mvp022_id"],death_pc["age_death"]))
rishi["Age_PC_death"]=rishi["mvp022_id"].map(mp_death)

rishi["PC_death"]=np.where(rishi["mvp022_id"].isin(death_pc["mvp022_id"].tolist()),1,0)
rishi["PC_death_age"]=np.where(rishi["mvp022_id"].isin(death_pc["mvp022_id"].tolist()),rishi["Age_PC_death"],rishi["ageatlastfollowup"])

mp_pc_death=dict(zip(rishi["mvp022_id"],rishi["PC_death"]))
mp_pc_death_age=dict(zip(rishi["mvp022_id"],rishi["PC_death_age"]))

# get baseline data
baseline=pd.read_csv("/data/data1/mvp022/Vinci_Data/20210805/Baseline_v20_1.csv",delimiter="|")
mp_fh=dict(zip(baseline["mvp022_id"],baseline["dadcapros"]))

# construct clean prostate cancer dataframe to use for PHS analysis

phs_dataframe=core[["mvp022_id"]].copy()
phs_dataframe["PC"]=phs_dataframe["mvp022_id"].map(mp_pc_status)
phs_dataframe["PC_age"]=phs_dataframe["mvp022_id"].map(mp_pc_age)

phs_dataframe["PC_gleason"]=phs_dataframe["mvp022_id"].map(mp_pc_gleason)
phs_dataframe["PC_gleason_age"]=phs_dataframe["mvp022_id"].map(mp_pc_gleason_age)

phs_dataframe["PC_death"]=phs_dataframe["mvp022_id"].map(mp_pc_death)
phs_dataframe["PC_death_age"]=phs_dataframe["mvp022_id"].map(mp_pc_death_age)

phs_dataframe["met"]=phs_dataframe["mvp022_id"].map(mp_met_status)
phs_dataframe["met_age"]=phs_dataframe["mvp022_id"].map(mp_met_age)
phs_dataframe["met"]=phs_dataframe["met"].fillna(0)
phs_dataframe["met_age"]=phs_dataframe["met_age"].fillna(phs_dataframe["mvp022_id"].map(mp_followup))

phs_dataframe["met_diag"]=np.where(phs_dataframe["mvp022_id"].isin(pca_met_diag["mvp022_id"].tolist()),1,0)
phs_dataframe["met_diag_age"]=phs_dataframe["mvp022_id"].map(mp_met_diag_age)
phs_dataframe["met_diag"]=phs_dataframe["met_diag"].fillna(0)
phs_dataframe["met_diag_age"]=phs_dataframe["met_diag_age"].fillna(phs_dataframe["mvp022_id"].map(mp_followup))

phs_dataframe["date_last_fu"]=phs_dataframe["mvp022_id"].map(mp_followup)

#get medicare patients
spat=pd.read_csv("/data/data1/mvp022/Vinci_Data/20220602/SpatFlags_V20_1.csv",delimiter="|")
medicare_pts=spat[spat["medicareflag"]=="Y"]["mvp022_id"].tolist()

phs_dataframe_pheno=phs_dataframe.dropna()
phs_dataframe_pheno["medicare"]=np.where(phs_dataframe_pheno["mvp022_id"].isin(medicare_pts),1,0)
phs_dataframe_pheno.to_csv("phs.pheno.tsv",sep="\t",index=None)

# family history
phs_dataframe_fh=phs_dataframe.dropna()
phs_dataframe_fh["FH"]=phs_dataframe_fh["mvp022_id"].map(mp_fh)
phs_dataframe_fh=phs_dataframe_fh.dropna()
phs_dataframe_fh["medicare"]=np.where(phs_dataframe_fh["mvp022_id"].isin(medicare_pts),1,0)
# add PCs
pcs=pd.read_csv("/data/data1/mvp022/Genotyping_Data/Release4/Hare_results/Release4.pcs",delimiter="\t")
pcs=pcs.rename(columns={"FID":"mvp022_id"})
del pcs["IID"]
phs_dataframe_fh=pd.merge(phs_dataframe_fh,pcs,on="mvp022_id",how="left")
phs_dataframe_fh.to_csv("phs.pheno.fh.tsv",sep="\t",index=None)

######################
# make psa dataframe #
######################

psa=pd.read_csv("/data/data1/mvp022/Vinci_Data/20220602/PSA_Labs_V19_2.csv",delimiter="|")
pca=pd.read_csv("/data/data1/mvp022/Vinci_Data/20210121/VINCI_PCa_Data_Core.csv",delimiter="|")
rishi=pd.read_csv("/data/data1/mvp022/Vinci_Data/20201106/Dflt.rd_fullmvp22cohort2.csv",delimiter="|")

mp_pca=dict(zip(pca["mvp022_id"],pca["date_first_dx"]))
mp_followup=dict(zip(rishi["mvp022_id"],rishi["lastfollowupdate"]))
mp_pc_status=dict(zip(rishi["mvp022_id"],rishi["prostatecancerdiagnosis"]))

psa["pca"]=psa["mvp022_id"].map(mp_pca)
psa["lastfu"]=psa["mvp022_id"].map(mp_followup)
psa["PC"]=psa["mvp022_id"].map(mp_pc_status)

psa=psa[~psa["PC"].isnull()]
print(psa.shape)

psa["labchemspecimendatetime"]=psa["labchemspecimendatetime"].str.split(" ").str[0]
psa["lastfu"]=psa["lastfu"].str.split(" ").str[0]
psa["pca"]=psa["pca"].str.split(" ").str[0]

psa["pca_time"]=pd.to_datetime(psa["pca"])-pd.to_datetime(psa["labchemspecimendatetime"])
psa["pca_time"]=pd.to_numeric(psa["pca_time"])/86400000000000

psa["lastfu_time"]=pd.to_datetime(psa["lastfu"])-pd.to_datetime(psa["labchemspecimendatetime"])
psa["lastfu_time"]=pd.to_numeric(psa["lastfu_time"])/86400000000000

#get number of test
psa_cases=psa[psa["PC"]==1]
psa_cases=psa_cases[psa_cases["pca_time"]>(356*2)]
psa_cases=psa_cases.drop_duplicates(subset=["mvp022_id","labchemspecimendatetime"],keep="first")
psa_cases=psa_cases["mvp022_id"].value_counts().reset_index()

psa_controls=psa[psa["PC"]==0]
psa_controls=psa_controls.drop_duplicates(subset=["mvp022_id","labchemspecimendatetime"],keep="first")
psa_controls=psa_controls["mvp022_id"].value_counts().reset_index()

psa_tests=psa_cases.append(psa_controls)
psa_tests.columns=["mvp022_id","num_tests"]
mp_psa_tests=dict(zip(psa_tests["mvp022_id"],psa_tests["num_tests"]))

# get calendar years
psa["psa_yr"]=psa["labchemspecimendatetime"].str.split("-").str[0]

psa_cases=psa[psa["PC"]==1]
psa_cases=psa_cases[psa_cases["pca_time"]>(356*2)]
psa_cases=psa_cases.drop_duplicates(subset=["mvp022_id","psa_yr"],keep="first")
psa_cases=psa_cases["mvp022_id"].value_counts().reset_index()

psa_controls=psa[psa["PC"]==0]
psa_controls=psa_controls.drop_duplicates(subset=["mvp022_id","psa_yr"],keep="first")
psa_controls=psa_controls["mvp022_id"].value_counts().reset_index()

psa_tests=psa_cases.append(psa_controls)
psa_tests.columns=["mvp022_id","num_tests_yr"]
mp_psa_tests_yr=dict(zip(psa_tests["mvp022_id"],psa_tests["num_tests_yr"]))

# get age at first PSA test
core=pd.read_csv("/data/data1/mvp022/Vinci_Data/20201230/MVP.CoreDemo_V19_2.csv",delimiter="|")
mp_yob=dict(zip(core["mvp022_id"],core["yob"]))
psa["yob"]=psa["mvp022_id"].map(mp_yob)

psa["age_psa"]=pd.to_numeric(psa["psa_yr"])-pd.to_numeric(psa["yob"])
psa_filt=psa[~psa["age_psa"].isnull()]
df_psa_age=psa_filt.loc[psa_filt.groupby("mvp022_id")["age_psa"].idxmin()]
mp_psa_age=dict(zip(df_psa_age["mvp022_id"],df_psa_age["age_psa"]))

pheno=pd.read_csv("phs.pheno.tsv",delimiter="\t")
pheno["psa_test"]=pheno["mvp022_id"].map(mp_psa_tests).fillna(0)
pheno["psa_test_yr"]=pheno["mvp022_id"].map(mp_psa_tests_yr).fillna(0)
pheno["psa_first_year"]=pheno["mvp022_id"].map(mp_psa_age)
pheno["psa_first_year"]=pheno["psa_first_year"].fillna(pheno["psa_first_year"].mean())

bins=[0,39,49,59,69,79,89,np.inf]
labels=["<40","40-50","50-60","60-70","70-80","80-90","90+"]
pheno["agerange"]=pd.cut(pheno["psa_first_year"],bins,labels=labels)

pheno=pheno.join(pd.get_dummies(pheno["agerange"]))
pheno.to_csv("phs.pheno.psa.tsv",sep="\t",index=None)

pheno=pd.read_csv("phs.pheno.fh.tsv",delimiter="\t")
pheno["psa_test"]=pheno["mvp022_id"].map(mp_psa_tests).fillna(0)
pheno["psa_test_yr"]=pheno["mvp022_id"].map(mp_psa_tests_yr).fillna(0)
pheno["psa_first_year"]=pheno["mvp022_id"].map(mp_psa_age)
pheno["psa_first_year"]=pheno["psa_first_year"].fillna(pheno["psa_first_year"].mean())

bins=[0,39,49,59,69,79,89,np.inf]
labels=["<40","40-50","50-60","60-70","70-80","80-90","90+"]
pheno["agerange"]=pd.cut(pheno["psa_first_year"],bins,labels=labels)
pheno=pheno.join(pd.get_dummies(pheno["agerange"]))
pheno.to_csv("phs.pheno.fh.psa.tsv",sep="\t",index=None)

# EARLY BASELINE #
#get first psa for early
psa_filt=psa[(psa["age_psa"]>=40)&(psa["age_psa"]<=49)]
print("{} individuals for early baseline".format(len(psa_filt)))
psa_filt["units"]=psa_filt["units"].str.lower()
psa_filt["cleaned_psa"]=np.where(psa_filt["units"]=="mg/dl", psa_filt["labchemresultnumericvalue"]*1000, psa_filt["labchemresultnumericvalue"])
psa_filt["cleaned_psa"]=np.where(psa_filt["units"]=="ng/dl", psa_filt["cleaned_psa"]*.01, psa_filt["cleaned_psa"])
psa_filt["cleaned_psa"]=np.where(psa_filt["units"]=="mg/ml", psa_filt["cleaned_psa"]*1000000, psa_filt["cleaned_psa"])

#get psa with no exclusions
psa_cases=psa_filt[psa_filt["PC"]==1]
psa_cases=psa_cases.loc[psa_cases.groupby("mvp022_id")["pca_time"].idxmax()]

psa_controls=psa_filt[psa_filt["PC"]==0]
psa_controls=psa_controls[psa_controls["lastfu_time"]>0]
psa_controls=psa_controls.loc[psa_controls.groupby("mvp022_id")["pca_time"].idxmax()]

psa_test=psa_cases.append(psa_controls)
psa_test["psa_first_yr"]=psa_test["mvp022_id"].map(mp_psa_age)
psa_test=psa_test[["mvp022_id","labchemresultnumericvalue","units","pca_time","age_psa","psa_first_yr","cleaned_psa"]]

psa_cases=psa_filt[psa_filt["PC"]==1]
psa_cases=psa_cases[psa_cases["pca_time"]>(365*2)]
psa_cases=psa_cases.loc[psa_cases.groupby("mvp022_id")["pca_time"].idxmax()]

psa_controls=psa_filt[psa_filt["PC"]==0]
psa_controls=psa_controls[psa_controls["lastfu_time"]>0]
psa_controls=psa_controls.loc[psa_controls.groupby("mvp022_id")["pca_time"].idxmax()]

psa_test_prediag=psa_cases.append(psa_controls)
psa_test_prediag["psa_first_yr"]=psa_test_prediag["mvp022_id"].map(mp_psa_age)
psa_test_prediag=psa_test_prediag[["mvp022_id","labchemresultnumericvalue","age_psa","psa_first_yr","units","pca_time","cleaned_psa"]]

# get number of monitors
psa_cases=psa_filt[psa_filt["PC"]==1]
psa_cases=psa_cases[psa_cases["pca_time"]>(356*2)]
psa_cases=psa_cases[psa_cases["age_psa"]<=55]
psa_cases=psa_cases.drop_duplicates(subset=["mvp022_id","psa_yr"],keep="first")
psa_cases=psa_cases["mvp022_id"].value_counts().reset_index()

psa_controls=psa_filt[psa_filt["PC"]==0]
psa_controls=psa_controls[psa_controls["age_psa"]<=55]
psa_controls=psa_controls.drop_duplicates(subset=["mvp022_id","psa_yr"],keep="first")
psa_controls=psa_controls["mvp022_id"].value_counts().reset_index()

psa_tests=psa_cases.append(psa_controls)
psa_tests.columns=["mvp022_id","num_tests_yr"]
mp_psa_tests_yr=dict(zip(psa_tests["mvp022_id"],psa_tests["num_tests_yr"]))

psa_test["psa_test_yr_monitor"]=psa_test["mvp022_id"].map(mp_psa_tests_yr).fillna(0)
psa_test_prediag["psa_test_yr_monitor"]=psa_test_prediag["mvp022_id"].map(mp_psa_tests_yr).fillna(0)

pheno=pd.read_csv("phs.pheno.tsv",delimiter="\t")
pheno=pd.merge(pheno,psa_test_prediag,on="mvp022_id",how="left")
pheno=pheno.dropna()
pheno[pheno["cleaned_psa"]<(20)].to_csv("phs.pheno.early.baseline.tsv",index=None,sep="\t")

pheno=pd.read_csv("phs.pheno.fh.tsv",delimiter="\t")
pheno=pd.merge(pheno,psa_test_prediag,on="mvp022_id",how="left")
pheno=pheno.dropna()
pheno[pheno["cleaned_psa"]<(20)].to_csv("phs.pheno.fh.early.baseline.tsv",index=None,sep="\t")



