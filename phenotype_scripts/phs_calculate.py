import pandas as pd
import numpy as np
import argparse

def phs_extract(file):

	snps=pd.read_csv(file)
	snps["Chromosome"]=snps["Chromosome"].replace(23,"X")
	print(snps.shape)
	
	snps["variant"]=snps["Chromosome"].astype(str)+":"+snps["Position"].astype(str)+":"+snps[args.minor].astype(str)+":"+snps[args.major].astype(str)
	
	return(snps)

def phs_calculate(raw,snps,phs):
	
	missing_count=0
	raw=pd.read_csv(raw,delim_whitespace=True)
	adj_raw=raw[["FID","IID","PAT","MAT","SEX","PHENOTYPE"]].copy()
	params={}

	for i,row in snps.iterrows():
		try:
			col=[x for x in raw.columns if row["variant"].rsplit(":",2)[0] in x][0]
			raw_minor=col.split("_")[1]
			snp=col.split("_")[0]
			
			if raw_minor != row[args.minor]:
				print("switching snps column {}".format(row["variant"]))
				adj_raw[snp+"_"+row[args.minor]]=2-pd.to_numeric(raw[col])
			else:
				adj_raw[snp+"_"+row[args.minor]]=pd.to_numeric(raw[col])

			params[snp+"_"+row[args.minor]]=row[phs]	

		except:
			print(row["variant"])
			print("missing {}".format(row["variant"]))
			missing_count+=1

	adj_raw["score"]=adj_raw[params.keys()].mul(pd.Series(params),axis=1).sum(1)
	print("{} snps are missing".format(missing_count))
	return(adj_raw)

def add_clinical(raw,clinical):

	df=pd.read_csv(clinical,delimiter="\t")
	df=df.rename(columns={"mvp022_id":"FID"})
	print(df.shape)

	raw=raw[["FID","IID","score"]]
	print(raw.head())
	print(df.head())
	raw=pd.merge(raw,df,on="FID",how="left")
	print(raw.shape)
	return(raw)

def filter_pts(raw,pts):
	pts=pd.read_csv(pts,delim_whitespace=True,header=None)[0].tolist()
	raw_filt=raw[raw["FID"].isin(pts)]
	return(raw_filt)

def main(args):
	snps=phs_extract(args.phs_file)
	phs=phs_calculate(args.raw,snps,args.phs)

	phs=add_clinical(phs,args.clinical)
	phs=filter_pts(phs,args.patients)
	print(phs.shape)
	
	if "hli" not in args.clinical:
		phs_filt=phs.dropna()
		print(phs_filt.shape)
		phs_filt.to_csv(args.out,index=None,sep="\t")

	else:
		phs.to_csv(args.out,index=None,sep="\t")
if __name__ == '__main__':
	parser=argparse.ArgumentParser()
	parser.add_argument('--phs_file',type=str,help='phs score file')
	parser.add_argument('--raw',type=str,help='name of raw file')
	parser.add_argument('--phs',type=str,help='name of column with phs weights')
	parser.add_argument('--out',type=str,help='output file')
	parser.add_argument('--clinical',type=str,help='clinical phenotype file')
	parser.add_argument('--patients',type=str,help='patients to extract')
	parser.add_argument('--minor',type=str,help='effect allele column')
	parser.add_argument('--major',type=str,help='reference allele column')

	args=parser.parse_args()
	main(args)

