import pandas as pd 

def deb(inpath='standard',outpath='standard'):
    if inpath == 'standard':
            df = pd.read_csv('toolbox/modules/DEB/preprocess/preprocess.csv')
    else:   df = pd.read_csv(inpath)
    seqindex = df.columns.get_loc('SEQPOS')
    columnames = df.columns.tolist()
    newcolmap = {el:el+'_1' for el in columnames[seqindex:]}
    df['ID_match'] = df['SUID'].eq(df['SUID'].shift(-1))
    shdf = df.iloc[:,seqindex:].shift(-1).add_suffix('_2')
    df.rename(newcolmap, axis=1, inplace=True)
    resdf = pd.concat([df,shdf],axis=1)
    resdf = resdf[resdf['ID_match']]
    resdf = resdf.drop(['ID_match', 'ID_match_2'],axis=1)
    if outpath == 'standard':
            resdf.to_csv('toolbox/modules/DEB/preprocess/in_data_transformed.csv', index=False)
    else:   resdf.to_csv(outpath, index=False)

# If commandlined it calls standard paths from config files 
deb()

# If you want to check if the conversion is working out, uncomment here and check that 
# _2 elements are the same as _1 elements of the following visit. 
# pos = 1
# print(resdf[resdf['SUID'] == 'DC1119'].iloc[pos]['AGGID_2':'PP_2'])
# print(resdf[resdf['SUID'] == 'DC1119'].iloc[pos+1]['AGGID_1':'PP_1'])
