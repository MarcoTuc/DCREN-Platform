import subprocess

import pandas as pd 
from toolbox.modules.DEB.DEB_pre import deb

from toolbox.settings import Settings

settings = Settings('PLSNNToolbox')

# indebpath = 'toolbox/modules/PLSNNToolbox/Data/1_topreprocess/virgin.csv'
indebpath = settings.prepath
exdebpath = 'toolbox/modules/PLSNNToolbox/data/1_topreprocess/debbed.csv'

deb(indebpath, exdebpath)
# calls a custom deb preprocessor for the plsnn toolbox that moves debbed.csv to input_data.csv
Rcommand = ["Rscript", "toolbox/modules/PLSNNToolbox/data/DEB_Preprocessing.R"]
subprocess.run(Rcommand, capture_output=True)
debbedpath = 'toolbox/modules/PLSNNToolbox/data/2_debpreprocessed/input_data.csv'
df = pd.read_csv(debbedpath)
try: df = df.drop('Unnamed: 0',axis=1)
except KeyError: pass
df.to_csv(debbedpath, index=False)

dfR = df[df['TCOMB_1'] == 'R']
dfS = df[df['TCOMB_1'] == 'RS']
dfG = df[df['TCOMB_1'] == 'RG']
dfM = df[df['TCOMB_1'] == 'RM']

dfR.to_csv('toolbox/modules/PLSNNToolbox/DebDataWithID_R.csv', index=False)
dfG.to_csv('toolbox/modules/PLSNNToolbox/DebDataWithID_G.csv', index=False)
dfM.to_csv('toolbox/modules/PLSNNToolbox/DebDataWithID_M.csv', index=False)
dfS.to_csv('toolbox/modules/PLSNNToolbox/DebDataWithID_S.csv', index=False)