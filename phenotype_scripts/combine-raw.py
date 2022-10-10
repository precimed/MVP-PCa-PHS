import numpy as np
import pandas as pd
import os
import argparse

def combine(dir,files):
	raw=pd.read_csv(dir+files[0],delim_whitespace=True)
	for x in files[1:]:
		new_raw=pd.read_csv(dir+x,delim_whitespace=True)
		del new_raw["SEX"]
		raw=pd.merge(raw, new_raw,on=["FID","IID","PAT","MAT","PHENOTYPE"])
	return(raw)

def main(args):
	#get raw files
	files=[x for x in os.listdir(args.dir) if ".raw" in x]
	print(files)
	combined_raw=combine(args.dir,files)
	print(combined_raw.shape)
	combined_raw.to_csv(args.out,index=None,sep="\t")

if __name__ == '__main__':
	parser=argparse.ArgumentParser()
	parser.add_argument('--dir',type=str,help='directory with raw files')
	parser.add_argument('--out',type=str,help='output file')
	args=parser.parse_args()
	main(args)
	

