import pandas as pd
import os
import pandas as pd
import numpy as np
import argparse

def main(args):
	files=[x for x in os.listdir("./") if x.endswith(args.suffix)]
	print(files)
	compiled_df=pd.DataFrame()
	for file in files:
		df=pd.read_csv(file,delimiter="\t")
		df["group"]=file.split(".")[0].upper()
		compiled_df=compiled_df.append(df)
	compiled_df.to_csv("all.male"+args.suffix,index=None,sep="\t")

if __name__ == '__main__':
        parser=argparse.ArgumentParser()
        parser.add_argument('--suffix',type=str,help='suffix')
        args=parser.parse_args()
        main(args)

