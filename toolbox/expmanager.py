import os 
import glob
import json
import pandas as pd 

from datetime import datetime

from toolbox.settings import Settings
from toolbox.validator import Validator
from toolbox.jsonmanager import JsonManager


class Exp():
    
    def __init__(self):

        self.exp_path = Settings.general_settings['experiments_path']
        self.toolboxes = [box for box in os.listdir(self.exp_path)]
        self.expdb = pd.DataFrame()
        for toolbox in self.toolboxes: 
            if toolbox != "DEB":
                for exp_name in os.listdir(f"{self.exp_path}/{toolbox}"):
                    for date in os.listdir(f"{self.exp_path}/{toolbox}/{exp_name}"):
                        for timecode in os.listdir(f"{self.exp_path}/{toolbox}/{exp_name}/{date}"):
                            path = f"{self.exp_path}/{toolbox}/{exp_name}/{date}/{timecode}"
                            time, code = timecode.split('_')[0], timecode.split('_')[2]
                            validated = 'validation.json' in os.listdir(path)
                            newrow = {
                                'TOOL': toolbox,
                                'NAME': exp_name,
                                'DATE': date,
                                'TIME': time,
                                'CODE': code,
                                'PATH': path,
                                'VALD': validated,
                                'REPORT': json.load(open(f"{path}/validation.json")) if validated else None
                            }
                            self.expdb = pd.concat([self.expdb, pd.DataFrame([newrow])], ignore_index=True)
        try: self.expdb["DATE"] = pd.to_datetime(self.expdb["DATE"])
        except KeyError: print("expdb is empty")
    
    def pickle(self):
        self.expdb.to_pickle("toolbox/expdb.pkl")
    
    def read(self):
        return pd.read_pickle("toolbox/expdb.pkl")
        
    def validate(self, experiments: pd.DataFrame):
        for i, exp in experiments.iterrows():
            if not str(exp['NAME']).startswith('_'):
                validation = Validator().create_validation_report(pd.read_csv(self.get_postprocessed(exp['PATH'])))
                JsonManager().save_json(validation, f"{exp['PATH']}/validation.json")
    
    def get_validation(self, exp, fend=False):
        if fend:
            return json.load(open(f"{exp[5]}/validation.json"))
        return json.load(open(f"{exp['PATH']}/validation.json"))
    
    def validate_single(self, path):
        validation = Validator().create_validation_report(pd.read_csv(self.get_postprocessed(path)))
        JsonManager().save_json(validation, f"{path}/validation.json")
        self.pickle()

    def get_postprocessed(self, exp_path):
        """ Gets you the path to the postprocessed data from the general path of an experiment """
        return glob.glob(f"{exp_path}/post/*.csv")[0]

    @property
    def today(self):
        time = datetime.now()
        today = '-'.join(map(str,[time.year,time.month,time.day]))
        if len(self.expdb) > 0:
            return self.expdb[self.expdb['DATE'] == today]
        else:
            return None 

    def groupby(self, item):
        return self.expdb.groupby(by=item).apply(lambda x:x)

    def groupby_method(self):
        return self.expdb.groupby(by='TOOL').apply(lambda x:x)
    
    def groupby_expname(self):
        return self.expdb.groupby(by='NAME').apply(lambda x:x)
    
    def groupby_date(self):
        return self.expdb.groupby(by='DATE').apply(lambda x:x)
    
    def groupby_code(self):
        return self.expdb.groupby(by='CODE').apply(lambda x:x)

