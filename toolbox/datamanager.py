import os 
import json
# import yaml

import pandas as pd 
import numpy as np 
import reflex as rx 

from collections import namedtuple

STANDARD_DATABASE = 'dcren-datasocket.csv'
STANDARD_DATAPATH = 'data'

class DataBase():
    """ Class for handling the data in the database and made for ease of interaction with the Reflex front-end state classes """
    def __init__(self):
        self.datapath = STANDARD_DATAPATH
        self.formats = self.get_formats()
        self.format = str()
    
    def get_formats(self):
        return [format for format in os.listdir(self.datapath) if format != 'settings']

    def set_format(self, format):
        self.format = format
    
    def get_databases(self, format):
        return [database for database in os.listdir(f"{self.datapath}/{format}") if os.path.isfile(os.path.join(f"{self.datapath}/{format}", database))]
    
    def all_databases(self):
        return {
            format: self.get_databases(format) for format in self.formats
        }
    
    def app_databases(self):
        return{
            format: self.get_databases(format) for format in self.formats if format == 'csv'
        }

class DataManager(DataBase):

    def __init__(self, dbname=None, patients_set='all'):      
        # Empty init for reflex compatibility
        if dbname is not None:
            self.initialize(dbname, patients_set=patients_set)

    def initialize(self, dbname, patients_set='all'):

        self.dbname, self.extension = dbname.split('.')

        self.datapath = f"data/{self.extension}/{self.dbname}.{self.extension}"
        self.dbname = dbname 
        self.multiline = 'multiline' in self.dbname
        self.patients_set = patients_set

        if self.extension == 'json':
            self.database = json.load(open(self.datapath))
            self.schema = f"data/{self.extension}/schemas/{self.dbname}"
            # self.keys = self._convert_to_namedtuple(yaml.load(open(self.schema), Loader=yaml.Loader))
        elif self.extension == 'csv':
            self.database = pd.read_csv(self.datapath)
            # self.keys = self._convert_to_namedtuple(yaml.load(open(f"data/{self.extension}/{self.dbname}_schema.{self.extension}")))
        
        if self.patients_set != 'all':
            if isinstance(self.patients_set,(list,np.ndarray)):
                self.patsubset(self.patients_set)
            else: raise TypeError("Subset of patients has to be a list of patient_IDs")
        elif self.patients_set == 'all': 
            self.data = self.database
    
    def patsubset(self, patients_set):
        if not isinstance(patients_set, (list, np.ndarray)):
            raise TypeError("Subset of patients has to be a list of patient IDs")
        self.data = self.from_patients_list(patients_set)
                    
    def from_patients_list(self, patients_list):
        SUIDs = self._get_SUIDs()
        if self.extension == 'json':    
            data = []
            for patient in patients_list:
                if patient not in SUIDs:
                    raise ValueError(f"patient {patient} is not in the database")
                else:
                    data.append(self._get_patient_data(patient_id=patient))
            return data
        elif self.extension == 'csv':
            return self.database[self.database[self.keys.general.patient_ID].isin(patients_list)]

    def save_info(self, path):
        with open(path,'w+') as config:
            json.dump(
                {"dbname": self.dbname,
                "extension": self.extension,
                "patients_set": self.patients_set},
                config, 
                indent=4)
    
    
    ####################################################
    ############### DATA LOADING METHODS ###############

    # Return a list of patients unique IDs
    def get_SUIDs(self):
        if self.extension == 'json':
            return [patient[self.keys.general.patient_ID] for patient in self.data]
        elif self.extension == 'csv':
            # the unique makes this work both with multiline than vanilla csv databases
            return self.data[self.keys.general.patient_ID].unique()
    
    def get_patient_data(self, patient_id):
        if self.extension == 'json':
            for patient in self.data:
                if patient[self.keys.general.patient_ID] == patient_id:
                    return patient 
        elif self.extension == 'csv':
            return self.data[self.data[self.keys.general.patient_ID] == patient_id]

    def get_patient_visits(self, patient_id):
        patient = self.get_patient_data(patient_id)
        if self.extension == 'json':
            seqlen = len(patient['sequences'])
            if seqlen == 0:
                raise ValueError(f"{patient['sequences']} is empty")
            elif seqlen == 1:
                visits = patient['sequences'][0]['visits']
            else:
                visits = []
                for seq in patient['sequences']:
                    for visit in seq['visits']:
                        visits.append(visit)
            return visits

    def get_AGGIDs(self):
        if self.extension == 'json':        
            AGGIDs = []
            for patient in self.get_SUIDs():
                for visit in self.get_patient_visits(patient):
                    AGGIDs.append(visit[self.keys.general.visit_ID])
            return AGGIDs
        elif self.extension == 'csv':
            return self.data[self.keys.general.visit_ID].unique()
        
    ####################################################
    ############### DATA WRITING METHODS ###############
    
    def write_to_path(self, path):
        if self.extension == 'csv':
            self.data.to_csv(path, index=False)
    
    ##############################################
    ############### HELPER METHODS ###############

    def val_from_key(self, target_key, data=None, patient_id=None):
        if data == None:
            if patient_id != None:
                data = self.get_patient_data(patient_id=patient_id)
            else: data = self.database
        """
        This method helps you find the relative value from a key 
        in whatever data structure made of nested dicts and lists 
        """
        if isinstance(data, dict):
            for key, value in data.items():
                if key == target_key:
                    return value
                if isinstance(value, (dict, list)):
                    result = self.val_from_key(target_key, data=value)
                    if result is not None:
                        return result
        elif isinstance(data, list):
            for item in data:
                result = self.val_from_key(target_key, data=item)
                if result is not None:
                    return result
                
    def _get_SUIDs(self):
        if self.extension == 'json':
            return [patient[self.keys.general.patient_ID] for patient in self.database]
        elif self.extension == 'csv':
            return self.database[self.keys.general.patient_ID].unique()

    def _get_patient_data(self, patient_id):
        if self.extension == 'json':
            for patient in self.database:
                if patient[self.keys.general.patient_ID] == patient_id:
                    return patient 
        elif self.extension == 'csv':
            return self.database[self.database[self.keys.general.patient_ID] == patient_id]
    
    def _get_AGGIDs(self):
        if self.extension == 'json':        
            AGGIDs = []
            for patient in self._get_SUIDs():
                for visit in self.get_patient_visits(patient):
                    AGGIDs.append(visit[self.keys.general.visit_ID])
            return AGGIDs
        elif self.extension == 'csv':
            return self.database[self.keys.general.visit_ID].unique()

    def _convert_to_namedtuple(self, d):
        """
        Recursively converts keys nested yaml dictionary into a nested namedtuple.
        """
        if isinstance(d, dict):
            for key, value in d.items():
                d[key] = self._convert_to_namedtuple(value)
            return namedtuple('keys', d.keys())(**d)
        return d

   

class DataTranslator():
    """ Class for translation of non-canonical databases into canonical shape and variable name """
    def __init__(self) -> None:
        pass