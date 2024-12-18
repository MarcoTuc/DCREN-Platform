import pandas as pd 

from toolbox.settings import Settings

settings = Settings('PLSNNToolbox')

# Set standard output path 
inpath = "toolbox/modules/PLSNNToolbox/data/2_debpreprocessed/input_data.csv"
expath = settings.expath

# Read the dataframes
xdf = pd.read_csv(f"{expath}/xD.csv", header=None)
xdf.columns = pd.read_csv(f"{expath}/xHeader.csv").columns
origin = pd.read_csv(inpath)[['AGGID_1',*xdf.columns.to_list()]]

# Find the shuffled suid order
int_xdf = xdf.map(lambda x: int(x))
int_origin = origin
int_origin[int_xdf.columns.to_list()] = int_origin[int_xdf.columns.to_list()].map(int)
int_merged = pd.merge(int_xdf, int_origin, on=xdf.columns.to_list(), how='left', indicator=True)
suidorder = int_merged['AGGID_1']

# Read the outputs and apply the suidorder
ydf = pd.read_csv(f"{expath}/yOut.csv", header=None)
ydf.columns = pd.read_csv(f"{expath}/yHeader.csv").columns.to_list()[:2]

ydf = pd.concat([suidorder,ydf], axis=1)

postdf = pd.DataFrame()

therapy = open('toolbox/modules/PLSNNToolbox/data/treatment.txt', 'r').read()
therapies = {'TR': 'R', 'TG': 'RG', 'TM': 'RM', 'TS': 'RS'}
action = 'DEGFR'

for i, row in ydf.iterrows():
    # print(row['AGGID_1'])
    newrow = {'TID': row['AGGID_1'], 
              'VAR': action, 
              'TRP': therapies[therapy], 
              'VAL': row['yPredicted']
              }
    postdf = pd.concat([postdf, pd.DataFrame([newrow])], ignore_index=True)

postdf.to_csv(settings.postpath, index=False)
