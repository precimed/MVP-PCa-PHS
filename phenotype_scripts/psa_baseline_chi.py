import pandas as pd
import numpy as np
from scipy import stats
from scipy.stats import chi2_contingency
import statsmodels.api as sm
from collections import defaultdict
from patsy import dmatrices

oddsRatios=defaultdict(dict)

cases = np.zeros(3)
controls = np.zeros(3)

df_fh=pd.read_csv("/group/research/mvp022/PHS/data/phs_files/phs290_eth_psa/all.male.prs.fh.psa.release4.tsv",delimiter="\t")
mp_fh=dict(zip(df_fh["FID"],df_fh["FH"]))

df=pd.read_csv("/group/research/mvp022/PHS/data/phs_files/phs290_eth_psa/all.male.prs.psa.release4.tsv",delimiter="\t")
df["FH"]=df["FID"].map(mp_fh)
early=pd.read_csv("/group/research/mvp022/PHS/data/phs_files/phs290_eth_psa/all.male.prs.psa.early.baseline.prediag.exclude.release4.tsv",delimiter="\t")
df["early"]=np.where(df["FID"].isin(early["FID"].tolist()),1,0)
df_cases=df[df["early"]==1]
df_controls=df[df["early"]==0]

cases[2]=len(df_cases[df_cases["FH"].isnull()])
cases[1]=len(df_cases[df_cases["FH"]==1])
cases[0]=len(df_cases[df_cases["FH"]==0])

controls[2]=len(df_controls[df_controls["FH"].isnull()])
controls[1]=len(df_controls[df_controls["FH"]==1])
controls[0]=len(df_controls[df_controls["FH"]==0]) 

matrixForFisherExactTest = [controls, cases]
print(matrixForFisherExactTest)

chi2, chi2p, dof, ex = chi2_contingency(matrixForFisherExactTest)
print('The p-value for the chi-squared test of family history between cases and controls is: {}'.format(chi2p))

cases = np.zeros(2)
controls = np.zeros(2)

cases[1]=len(df_cases[df_cases["group"]=="AFR"])
cases[0]=len(df_cases[df_cases["group"]!="AFR"])

controls[1]=len(df_controls[df_controls["group"]=="AFR"])
controls[0]=len(df_controls[df_controls["group"]!="AFR"])

matrixForFisherExactTest = [controls, cases]
print(matrixForFisherExactTest)

chi2, chi2p, dof, ex = chi2_contingency(matrixForFisherExactTest)
print('The p-value for the chi-squared test of family history between cases and controls is: {}'.format(chi2p))

print("cases mean:{}".format(df_cases["score"].mean()))
print("controls mean:{}".format(df_controls["score"].mean()))
print(stats.ttest_ind(df_cases["score"].tolist(),df_controls["score"].tolist()))
