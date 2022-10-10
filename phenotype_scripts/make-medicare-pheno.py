import pandas as pd
import os
import numpy as np
import argparse

def main(args):
	# filter dataframes
	spat=pd.read_csv("/data/data1/mvp022/Vinci_Data/20220602/SpatFlags_V20_1.csv",delimiter="|")
	medicare_pts=spat[spat["medicareflag"]=="N"]["mvp022_id"].tolist()

	df=pd.read_csv(args.file,delimiter="\t")
	df=df[df["FID"].isin(medicare_pts)]
	df.to_csv(args.out,index=None,sep="\t")

if __name__ == '__main__':
	parser=argparse.ArgumentParser()
	parser.add_argument('--file',type=str,help='directory with files')
	parser.add_argument('--out',type=str,help='output file')
	args=parser.parse_args()
	main(args)
