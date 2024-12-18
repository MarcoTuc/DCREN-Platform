import pandas as pd
import glob
import os
import json

from sklearn.metrics import confusion_matrix, mean_squared_error

class Oracle:
    """ 
    Ground truth extractor, takes the experiment path as input, reads the post and which dataset it comes from 
    and returns a ground truth dataframe about it if it exists. 

    
    ------ Old custom extraction methods ------
    
    -- MUW:
    def get_ground(idf: pd.DataFrame, tid, var, trp, val):
    place = idf[idf['AGGID'] == tid]
    if place['TCOMB'].item() == trp:
        if not place[var].isnull().values.any():
            if var == 'TC':
                return groundmap[place[var].item()]    
            else:
                return place[var].item()
    return None 
    newrow['GRD'] = get_ground(
        idf,
        newrow["TID"],
        newrow["VAR"],
        newrow["TRP"],
        newrow["VAL"]
    )
    newrows.append(newrow)

    -- OPAi: 
    'GRD': None if row['actual_TCOMB'] != therapies[therapy] else groundmap[row['future_TC']]}

    -- PLSNNToolbox:
    'GRD': row['yActual']

    -- Samir:
    "GRD": grdval if mappedvariable != 'TC' else tcmap[grdval]

    """

    def __init__(self, experiment_path):
        self.experiment_path = experiment_path

    def __call__(self):
        postpath = os.path.join(self.experiment_path, "post", "post.csv")
        if not os.path.exists(postpath):
            raise FileNotFoundError(f"post.csv not found in {postpath}")
        postdf = pd.read_csv(postpath)
        dbname = json.load(open(os.path.join(self.experiment_path, "datainfo.json")))["dbname"]
        dbf = pd.read_csv(os.path.join("data", "csv", dbname))
        if "GRD" in postdf.columns: postdf = postdf[postdf.columns.drop('GRD')]
        newrows = []
        for _, row in postdf.iterrows():
            datarow = dbf[dbf['AGGID'] == row['TID']]
            dataval = datarow[f"FUTURE_{row['VAR']}_1"]
            # current TC refers to next TC so I should use future_TC
            # current DEGFR refers to next DEGFR so I should pick the one of the next row
            try: row["TRF"] = datarow["TCOMB"].item()
            except ValueError: 
                row["GRD"] = None
                continue
            # print(row["TRP"], row["TRF"])
            if row["TRP"] == row["TRF"]:
                # if NaN values are found, then it means they are in the dataset itself.
                # Usually first visits have a NaN value because you know, they are the first visit.
                row["GRD"] = dataval.item()
            else:
                # if something is not observable, it is None
                row["GRD"] = None
            newrows.append(row)
        
        groundf = pd.DataFrame(newrows)
        groundf.loc[groundf["VAR"] == "TC", "VAL"] = groundf.loc[groundf["VAR"] == "TC", "VAL"].apply(self.int_not_nan)
        groundf.loc[groundf["VAR"] == "TC", "GRD"] = groundf.loc[groundf["VAR"] == "TC", "GRD"].apply(self.transform_tc)
                    
        # Create the 'ground' folder if it doesn't exist
        ground_folder = os.path.join(self.experiment_path, "ground")
        os.makedirs(ground_folder, exist_ok=True)
        print(ground_folder)
        # Save the ground truth DataFrame to a CSV file
        groundf.to_csv(os.path.join(ground_folder, "ground.csv"), index=False)

    @staticmethod
    def int_not_nan(x):
        try: return int(x)
        except: return x
    
    @staticmethod
    def transform_tc(x):
        tcmap = {
            "controlled": 0,
            "uncontrolled": 1,
            "inbetween": 0,
            "n/o": None,
            None: None
        }
        if isinstance(x, str):
            return tcmap[x]
        else: 
            return int(x) if pd.notnull(x) else x 

class Validator():
    
    def create_validation_report(self, postdf):
        df = postdf.dropna()
        validation = []
        for var in pd.unique(df['VAR']):
            out = {}
            out['variable'] = var
            subdf = df[df['VAR'] == var]
            if subdf['VAL'].map(lambda x: True if type(x) == int else x.is_integer()).all():
                subdf.loc[:,'VAL'] = subdf['VAL'].apply(lambda x: int(x))
                out['type'] = 'categorical'
                out['validation'] = {}
                out['validation']['accuracy'], out['validation']['sensitivity'], out['validation']['specificity'] = self.categorical_metrics(subdf['GRD'].to_numpy(), subdf['VAL'].to_numpy())
            else:
                out['type'] = 'continuous'
                out['validation'] = {}
                out['validation']['MSE'] = mean_squared_error(df['GRD'].to_numpy(), df['VAL'].to_numpy()) 
            validation.append(out)
        return validation
            
    @staticmethod
    def categorical_metrics(y_vals, x_vals):
            confmatrix = confusion_matrix(y_vals, x_vals)
            true_cd, false_ucd, false_cd, true_ucd = confmatrix.ravel()
            accuracy = (true_cd + true_ucd) / (true_cd + true_ucd + false_cd + false_ucd)
            specificity = (true_cd) / (true_cd + false_ucd)
            sensitivity = (true_ucd) / (true_ucd + false_cd)
            return accuracy, sensitivity, specificity

    def default_validation(self, experiment_path):
        post_csv_path = os.path.join(experiment_path, "post", "post.csv")
        if not os.path.exists(post_csv_path):
            raise FileNotFoundError(f"post.csv not found in {post_csv_path}")
        
        postdf = pd.read_csv(post_csv_path)
        try: 
            postdf["GRD"]
            validation_report = self.create_validation_report(postdf)
        except KeyError:
            try:
                post_csv_path = os.path.join(experiment_path, "ground", "ground.csv")
                grounddf = pd.read_csv(post_csv_path)
                validation_report = self.create_validation_report(grounddf)
            except FileNotFoundError:
                raise FileNotFoundError(f"ground.csv not found in {post_csv_path}")
        
        if validation_report:
            return validation_report  # Return the first (and usually only) validation result
        else:
            return {"variable": "N/A", "type": "N/A", "validation": {}}

    def custom_validation(self, experiment_path):
        # Placeholder for custom validation
        return {"variable": "Custom", "type": "N/A", "validation": {"message": "Custom validation not implemented yet"}}
