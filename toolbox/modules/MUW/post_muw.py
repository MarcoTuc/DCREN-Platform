import pandas as pd 
from toolbox.settings import Settings

settings = Settings('MUW')

idf = pd.read_csv(settings.inpath)
odf = pd.read_csv(settings.expath).drop("Unnamed: 0", axis=1)

therapies = {
    "RASI": "R",
    "RASI_SLGT2": "RS",
    "RASI_GLP1A": "RG",
    "RASI_MCRA": "RM"
}

variables = {
    "deltaEGFR": "DEGFR",
    "TC": "TC"
}

groundmap = {
    'controlled':   0,
    'uncontrolled': 1,
    'inbetween':    1,
    None:           None
}

postdf = pd.DataFrame()
newrows = []

for i, row in odf.iterrows():
    newrow = {
        "TID": row["test_id"],
        "VAR": variables[row['predicted_variable']],
        "TRP": therapies[row["therapy"]],
        "VAL": row["predicted_value"]
    }
    newrows.append(newrow)

postdf = pd.DataFrame(newrows)
postdf.to_csv(settings.postpath, index=False)

