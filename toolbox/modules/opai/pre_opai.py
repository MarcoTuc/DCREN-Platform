from pandas import read_csv, DataFrame

table = read_csv('toolbox/modules/opai/input_files/temp/OPAi-prediction-control.csv')
data  = read_csv('toolbox/modules/opai/preprocess/preprocess.csv')
features = ['AGGID',*table["TSVARLIST"].to_list()]
opai_input = data[features]
refpath = 'toolbox/modules/opai/input_files/temp/OPAi-prediction-input-reference.csv'
opai_input.to_csv(refpath, index_label='TID')
inpath = 'toolbox/modules/opai/input_files/temp/OPAi-prediction-input.csv'
opai_input.drop('AGGID',axis=1).to_csv(inpath, index_label='TID')