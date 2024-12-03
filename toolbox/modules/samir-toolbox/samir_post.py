import numpy as np 
import pandas as pd 

from tqdm import tqdm
from itertools import pairwise

inpath = 'toolbox/modules/samir-toolbox/data/predict/input_data.csv'
outpath = 'toolbox/modules/samir-toolbox/outputs/TC_pred.csv'
postpath = 'toolbox/modules/samir-toolbox/post/post.csv'

idf = pd.read_csv(inpath)
odf = pd.read_csv(outpath)

postdf = pd.DataFrame()

actiondict = {
    "TC_pred": "TC",
    "Pred_delta": "DEGFR",
    "Pred_eGFR": 'EGFR'
}

tcmap = {
    'controlled': 0,
    'uncontrolled': 1,
    'inbetween': 1,
    None: np.nan,
    np.nan: np.nan
}

therapydict = {
    "rasi":   "R",
    "sglt2i": "RS",
    "mcra":   "RM",
}


for (o, outrow), ((i, inrow),(ni, nextrow)) in tqdm(zip(odf.iterrows(), pairwise(idf.iterrows()))):
    for col in outrow.index.drop(["AGGID", "Optimal_treatment"]):
        aggid = inrow["AGGID"]
        mappedvariable = actiondict['_'.join(col.split('_')[:2])]
        mappedtherapy = therapydict[col.split('_')[-1]]
        actualtherapy = inrow['TCOMB']
        groundexists = actualtherapy == mappedtherapy and inrow['SUID'] == nextrow['SUID']
        vartherapyvalue = outrow[col]
        if groundexists:
            grdval = nextrow[mappedvariable]
        else:
            grdval = None
        newrow = {
            "TID": aggid,
            "VAR": mappedvariable,
            "TRP": mappedtherapy,
            "VAL": vartherapyvalue if mappedvariable != 'TC' else tcmap[vartherapyvalue]
        }
        add = pd.DataFrame([newrow])
        postdf = pd.concat([postdf, add], ignore_index=True)

postdf.to_csv(postpath, index=False)

